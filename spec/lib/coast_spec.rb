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
        coast.is_ok?(1, 0).should be_true
      end
    end

    context "y is max_number" do
      it "return true" do
        coast.matrix[2][3].should == 1
        coast.is_ok?(2, 3).should be_true
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
        coast.is_ok?(0, 1).should be_false
      end
    end

    context "out of matrix" do
      it "return false" do
        coast.is_ok?(4, 6).should be_false
      end
    end
  end

  describe "#ship?" do
    context "dead rock" do
      it "return false" do
        coast.ship?(3, 3).should be_false
      end

      it "return false" do
        coast.ship?(3, 3).should be_false
      end
    end
  end

  describe "#ship_to_right?" do
    context "dead rock" do
      it "return false" do
        coast.ship_to_right?(0, 0).should be_false
      end

      it "return true" do
        coast.ship_to_right?(3, 3).should be_true
      end

      it "return true" do
        coast.ship_to_right?(3, 5).should be_false
      end

      it "return true" do
        coast.ship_to_right?(1, 2).should be_false
      end
    end
  end

  describe "#ship_for_return?" do
    context "dead rock" do
      it "return false" do
        coast.ship_return_from?(0, 0).should be_false
      end

      it "return false" do
        coast.ship_return_from?(3, 3).should be_true
      end
    end
  end

  describe "#try?" do
    it "try!!" do
      coast.try
    end
  end

  describe "#back_to_left" do
    it "try" do
      2.downto(1) do |num|
        puts "num:#{num}"
      end

      #coast.back_to_left(3,3,"00,00,",:from=>{:t=>2, :s=>2})
    end
  end

  describe "#edit_params_to_right" do
    it "try" do
      hash =
          { :from     => { :t => 2, :s => 2, :log => "00,00," }, }

      result = coast.edit_params_to_right(hash, 1, 1)
      result[:from].should     == { :t => 2, :s => 2, :log => "00,00," }
      result[:to_right].should == { :t => 1, :s => 1 }
    end
  end

  describe "#edit_params_for_recursive" do
    it "try" do
      hash =
      { :from     => { :t => 2, :s => 2, :log => "00,00," },
        :to_left  => { :t => 1, :s => 1 },
        :to_right => { :t => 1, :s => 0 },
      }
      result = coast.edit_params_for_recursive(hash)

      result[:from].should     == { :t => 2, :s => 3, :log => "00,00,33,32," }
      result[:to_left].should  be_null
      result[:to_right].should be_null
    end
  end

  describe "#to_left" do
    it "try" do
      hash =
          { :from     => { :t => 2, :s => 2, :log => "00,00," },
            :to_right => { :t => 1, :s => 1 },
          }
      coast.to_left(hash)
    end
  end

  describe "#to_right" do
    it "try" do
      hash =
          { :from => { :t => 0, :s => 0, },
            :log  => "00," ,
          }
      coast.to_right_first(hash)
    end
  end
end