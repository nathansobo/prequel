require 'spec_helper'

module Keep
  describe Record do
    describe "when it is subclassed" do
      before do
        class Blog < Record
          column :id, :integer
          column :title, :string
        end
      end

      after do
        Keep.send(:remove_const, :Blog)
      end

      specify "the subclass gets associated with a table" do
        Blog.table.name.should == :blogs
        Blog.table.tuple_class.should == Blog
      end

      specify "accessor methods are assigned on the subclass for columns on the table" do
        b = Blog.new
        b.title = "Title"
        b.title.should == "Title"
      end
    end
  end
end
