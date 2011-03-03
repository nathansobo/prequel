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

      describe "#get_column" do
        it "returns a derived column on the projection by name or qualified name" do
          projection = Blog.join(Post, Blog[:id] => :blog_id).project(Post)

          derived_column = projection.get_column(:id)
          derived_column.origin.should == Post.get_column(:id)
          projection.get_column(Post[:id]).should == derived_column
        end
      end

      describe "#all" do
        before do
          Blog.create_table
          Post.create_table
        end

        context "when projecting a table" do
          it "returns instances of that table's tuple class" do
            DB[:blogs] << { :id => 1, :user_id => 1, :title => "Blog 1"}
            DB[:blogs] << { :id => 2, :user_id => 2, :title => "Blog 2"}
            DB[:posts] << { :id => 1, :blog_id => 1, :title => "Blog 1, Post 1"}
            DB[:posts] << { :id => 2, :blog_id => 1, :title => "Blog 1, Post 2"}
            DB[:posts] << { :id => 3, :blog_id => 2, :title => "Blog 2, Post 1"}

            projection = Blog.where(:user_id => 1).join(Post, Blog[:id] => :blog_id).project(Post)

            results = projection.all
            results.size.should == 2
            results[0].should == Post.find(1)
            results[1].should == Post.find(2)
          end
        end

        context "when projecting individual columns" do
          it "returns instances of the projection's custom tuple class, with accessors for the particular fields" do
            DB[:blogs] << { :id => 1, :user_id => 1, :title => "Blog 1"}
            DB[:posts] << { :id => 1, :blog_id => 1, :title => "Blog 1, Post 1"}

            projection = Blog.join(Post, Blog[:id] => :blog_id).project(Blog[:title].as(:blog_title), Post[:title].as(:post_title))

            results = projection.all
            results.size.should == 1
            results.first.should be_an_instance_of(projection.tuple_class)
            results.first.blog_title.should == "Blog 1"
            results.first.post_title.should == "Blog 1, Post 1"
          end
        end
      end

      describe "#to_sql" do
        describe "a projection of particular columns, some with aliases" do
          it "generates the appropriate sql" do
            Blog.project(:user_id, :title.as(:name)).to_sql.should be_like_query(%{
              select blogs.user_id as user_id, blogs.title as name from blogs
            })
          end
        end

        describe "a projection of a set function" do
          it "generates the appropriate sql" do
            Blog.project(:id.count.as(:blog_count)).to_sql.should be_like_query(%{
              select count(blogs.id) as blog_count from blogs
            })
          end
        end

        describe "a projection of all columns in a table on top of a simple inner join" do
          it "generates the appropriate sql" do
            Blog.join(Post, Blog[:id] => :blog_id).project(:posts).to_sql.should be_like_query(%{
              select posts.id      as id,
                     posts.blog_id as blog_id,
                     posts.title   as title
              from   blogs
                     inner join posts
                       on blogs.id = posts.blog_id
            })
          end
        end

        describe "a projection of all columns in a table on top of a right-associative 3-table join, projecting columns from the subquery" do
          it "generates the appropriate sql, aliasing columns from subqueries back to their natural names" do
            Blog.join(Post.join(Comment, Post[:id] => :post_id), Blog[:id] => :blog_id).project(:comments).to_sql.should be_like_query(%{
              select t1.comments__id      as id,
                     t1.comments__post_id as post_id,
                     t1.comments__body    as body
              from   blogs
                     inner join (select posts.id         as posts__id,
                                        posts.blog_id    as posts__blog_id,
                                        posts.title      as posts__title,
                                        comments.id      as comments__id,
                                        comments.post_id as comments__post_id,
                                        comments.body    as comments__body
                                 from   posts
                                        inner join comments
                                          on posts.id = comments.post_id) as t1
                       on blogs.id = t1.posts__blog_id
            })
          end
        end
      end
    end
  end
end
