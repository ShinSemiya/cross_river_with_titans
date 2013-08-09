require 'spec_helper'

describe Coast do
  let!(:coast){ Coast.new(3, 2) }

  describe "#initialize" do
    it "max_number is 3" do
      coast.max_number.should == 3
    end

    it "matrix is initialized" do
      coast.matrix.should == [[1, 0, 0, 1], [1, 1, 0, 1], [1, 0, 1, 1], [1, 0, 0, 1]]
    end
  end

  describe "#set_up_matrix" do
    let!(:boat_payload){ 1 }

    context "max_number is 5" do
      let!(:max_size)    { 2 }

      it "matrix is initialized" do
        coast = Coast.new(max_size, boat_payload)
        coast.set_up_matrix(max_size).should == [[1, 0, 1], [1, 1, 1], [1, 0, 1]]
      end
    end

    context "max_number is 5" do
      let!(:max_size){ 5 }

      it "matrix is initialized" do
        coast = Coast.new(max_size, boat_payload)
        coast.set_up_matrix(max_size).should == [[1, 0, 0, 0, 0, 1], [1, 1, 0, 0, 0, 1], [1, 0, 1, 0, 0, 1],
                                                 [1, 0, 0, 1, 0, 1], [1, 0, 0, 0, 1, 1], [1, 0, 0, 0, 0, 1]]
      end
    end
  end

  describe "#is_ok?" do
    context "y is 0" do
      it "return true" do
        coast.matrix[1][0].should == 1
        coast.is_ok?(0, 1).should be_true
      end
    end

    context "y is max_number" do
      it "return true" do
        coast.matrix[2][3].should == 1
        coast.is_ok?(3, 2).should be_true
      end
    end

    context "x = y" do
      it "return true" do
        coast.is_ok?(1, 1).should be_true
        coast.is_ok?(2, 2).should be_true
      end
    end

    context "others" do
      it "return false" do
        coast.is_ok?(1, 0).should be_false
      end
    end

    context "out of matrix" do
      it "return false" do
        coast.is_ok?(6, 4).should be_false
      end
    end
  end

  describe "#is_ok_to_right?" do
    context "assrot in NG" do
      it "return false" do
        params =
            {   :log  => "",
                :from =>{ :t => 3, :s => 0 },
                :to   =>{ :t => 0, :s => 1 },
            }
        coast.is_ok_to_right?(params).should be_false
      end
    end

    context "over range" do
      it "return false" do
        params =
            {   :log  => "",
                :from =>{ :t => 3, :s => 0 },
                :to   =>{ :t => 1, :s => 0 },
            }
        coast.is_ok_to_right?(params).should be_false
      end
    end
  end

  describe "#is_ok_to_left?" do
    context "assrot in NG" do
      it "return false" do
        params =
            {   :log  => "",
                :from =>{ :t => 3, :s => 0 },
                :to   =>{ :t => 1, :s => 1 },
            }
        coast.is_ok_to_left?(params).should be_false
      end
    end

    context "under range" do
      it "return false" do
        params =
            {   :log  => "",
                :from =>{ :t => 3, :s => 0 },
                :to   =>{ :t => 1, :s => 1 },
            }
        coast.is_ok_to_left?(params).should be_false
      end
    end
  end



  describe "#edit_params_in_right" do
    it "return editted_params" do
      params =
          {   :log  => "11,",
              :from => { :t => 1, :s => 1 },
              :to   => { :t => 1, :s => 1 },
          }
      result = coast.edit_params_in_right(params)
      result[:log].should  == '11,22,'
      result[:from].should == { :t => 2, :s => 2 }
      result[:to].should   be_nil
    end
  end

  describe "#edit_params_in_left" do
    it "return editted_params" do
      params =
          {   :log  => "33,",
              :from => { :t => 3, :s => 3 },
              :to   => { :t => 2, :s => 0 },
          }
      result = coast.edit_params_in_left(params)
      result[:log].should  == '33,31,'
      result[:from].should == { :t => 1, :s => 3 }
      result[:to].should   be_nil
    end
  end

  describe "#to_right_coast" do
    it "return editted_params" do
      params =
          {   :log  => "22,",
              :from => { :t => 2, :s => 2 },
          }
      result = coast.to_right_coast(params)
    end
  end

  describe "#cross_all?" do
    context "all in right" do
      it "return true" do
        params =
            {   :log  => "22,,11,33,",
                :from => { :t => 3, :s => 3 },
            }
        coast.cross_all?(params).should be_true
      end
    end

    context "NOT all in right" do
      it "return false" do
        params =
            {   :log  => "22,,11,33,22,",
                :from => { :t => 2, :s => 2 },
            }
        coast.cross_all?(params).should be_false
      end
    end
  end

  describe "#is_ok_to_right?" do
    context "to OK_cell" do
      it "return true" do
        params =
            {   :log  => "22,,11,20,",
                :from => { :t => 2, :s => 0 },
                :to   => { :t => 1, :s => 0 },
            }
        coast.is_ok_to_right?(params).should be_true
      end
    end

    context "to NG_cell" do
      it "return false" do
        params =
            {   :log  => "31,,",
                :from => { :t => 1, :s => 1 },
                :to   => { :t => 1, :s => 0 },
            }
        coast.is_ok_to_right?(params).should be_false
      end
    end
  end

  describe "#is_ok_to_left?" do
    context "to OK_cell" do
      it "return true" do
        params =
            {   :log  => "22,,11,20,",
                :from => { :t => 3, :s => 0 },
                :to   => { :t => 1, :s => 0 },
            }
        coast.is_ok_to_left?(params).should be_true
      end
    end

    context "to NG_cell" do
      it "return false" do
        params =
            {   :log  => "31,,",
                :from => { :t => 3, :s => 0 },
                :to   => { :t => 0, :s => 1 },
            }
        coast.is_ok_to_left?(params).should be_false
      end
    end
  end

  describe "#is_ok?" do
    context "in OK_cell" do
      it "return true" do
        coast.is_ok?(3, 0).should be_true
      end
    end

    context "in NG_cell" do
      it "return false" do
        coast.is_ok?(1, 2).should be_false
      end
    end
  end
end
