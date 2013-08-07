require 'spec_helper'

describe Boat do
  let!(:boat){ Boat.new(2) }
  describe "#initialize" do
    it "payload is 2" do
      boat.payload.should == 2
    end
  end
end