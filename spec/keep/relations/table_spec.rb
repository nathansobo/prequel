require 'spec_helper'

module Keep
  module Relations
    describe Table do
      attr_reader :blogs

      before do
        @blogs = Keep.table(:blogs) do
          column :id, :integer
        end
      end

      describe "#get_column(name)" do
        it "handles qualified column names" do
          blogs.get_column(:blogs__id).should == blogs.columns_by_name[:id]
          blogs.get_column(:posts__id).should be_nil
          blogs.get_column(:blogs__garbage).should be_nil
        end

        it "handles unqualified column names" do
          blogs.get_column(:id).should == blogs.columns_by_name[:id]
          blogs.get_column(:garbage).should be_nil
        end
      end

      describe "#all" do
        before do
          class Blog < Keep::Record
            column :id, :integer
            column :user_id, :integer
            column :title, :string
          end
          Blog.table.create_table
        end

        it "returns all records as instances of the table's tuple class"
      end
    end
  end
end