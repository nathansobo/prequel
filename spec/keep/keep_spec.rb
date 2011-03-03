require 'spec_helper'

describe Keep do
  describe "when the DB constant is referenced for the first time" do
    it "assigns it to Sequel::DATABASES.first" do
      Keep::DB.should == Sequel::DATABASES.first
    end
  end

  describe "when any other constant is referenced" do
    it "raises an error as usual" do
      expect { Keep::JUNK }.to raise_error(NameError)
    end
  end
end