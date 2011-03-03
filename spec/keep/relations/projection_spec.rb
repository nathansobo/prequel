require 'spec_helper'

module Keep
  module Relations
    describe Projection do
      before do
        class Blog < Keep::Record
          column :id, :integer
          column :user_id, :integer
          column :title, :string
        end

        class Post < Keep::Record
          column :id, :integer
          column :blog_id, :integer
          column :title, :string
        end

        class Comment < Keep::Record
          column :id, :integer
          column :post_id, :integer
          column :body, :string
        end
      end

      describe "#initialize" do
        context "when given the name of a table in the projection's operand" do
          it "derives every column in that table on the projection, aliased to its unqualified name" do
            operand = Blog.where(:user_id => 1).join(Post, Blog[:id] => :blog_id).join(Comment, Post[:id] => :post_id)
            comments_projection = operand.project(:comments)

            derived_columns = comments_projection.columns
            derived_columns.size.should == Comment.columns.size
            derived_columns.each do |derived_column|
              origin = derived_column.origin
              origin.table.should == Comment.table
              derived_column.alias_name.should == origin.name
            end
          end
        end
      end
    end
  end
end
