require 'spec_helper'

describe Coast do
  let!(:coast){ Coast.new(3) }
  describe "#initialize" do
    it "max_number is 3" do
      coast.max_number.should == 3
    end
  end
end