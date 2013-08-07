require 'spec_helper'

describe Coast do
  let!(:coast){ Coast.new(3) }

  describe "#initialize" do
    it "max_number is 3" do
      coast.max_number.should == 3
    end

    it "matrix is initialized" do
      coast.matrix.should == [[1, 1, 1, 1],
                              [0, 1, 0, 0],
                              [0, 0, 1, 0],
                              [1, 1, 1, 1],]
    end
  end

  describe "#set_up_matrix" do
    context "max_number is 5" do
      let!(:max_size){ 2 }

      it "matrix is initialized" do
        coast = Coast.new(max_size)
        coast.set_up_matrix(max_size).should == [[1, 1, 1],
                                                 [0, 1, 0],
                                                 [1, 1, 1],]
      end
    end

    context "max_number is 5" do
      let!(:max_size){ 5 }

      it "matrix is initialized" do
        coast = Coast.new(max_size)
        coast.set_up_matrix(max_size).should == [[1, 1, 1, 1, 1, 1],
                                                 [0, 1, 0, 0, 0, 0],
                                                 [0, 0, 1, 0, 0, 0],
                                                 [0, 0, 0, 1, 0, 0],
                                                 [0, 0, 0, 0, 1, 0],
                                                 [1, 1, 1, 1, 1, 1],]
      end
    end
  end
end