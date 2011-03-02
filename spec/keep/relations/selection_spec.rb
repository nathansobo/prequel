require 'spec_helper'

module Keep
  module Relations
    describe Selection do
      before do
        class Blog < Keep::Record
          column :id, :integer
          column :user_id, :integer
        end
      end

      describe "#initialize" do
        it "resolves symbols in the selection's predicate to columns derived from the selection's operand, not the selection itself" do
          selection = Blog.where(:user_id => 1)
          selection.predicate.left.should == Blog.table.get_column(:user_id)
        end
      end
    end
  end
end
