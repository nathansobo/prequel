require 'spec_helper'

module Keep
  module Relations
    describe InnerJoin do
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
        it "evaluates the join predicate in terms of columns derived from the underlying tables" do
          simple_join = Blog.join(Post, Blog[:id] => Post[:blog_id])
          simple_join.predicate.left.should == Blog.table.get_column(:id)
          simple_join.predicate.right.should == Post.table.get_column(:blog_id)

          compound_join = simple_join.join(Comment, Post[:id] => Comment[:post_id])
          compound_join.predicate.left.should == simple_join.get_column(Post[:id])
          compound_join.predicate.right.should == Comment.table.get_column(:post_id)
        end
      end

      describe "#all" do
        before do
          Blog.create_table
          Post.create_table
          Comment.create_table
        end

        it "returns instances of CompositeTuple that contain instances of the underlying tables' tuple classes" do
          DB[:blogs] << { :id => 1, :user_id => 1, :title => "Blog 1" }
          DB[:blogs] << { :id => 2, :user_id => 2, :title => "Blog 2" }
          DB[:posts] << { :id => 1, :blog_id => 1, :title => "Blog 1, Post 1" }
          DB[:posts] << { :id => 2, :blog_id => 1, :title => "Blog 1, Post 2" }
          DB[:posts] << { :id => 3, :blog_id => 2, :title => "Blog 2, Post 1" }
          DB[:comments] << { :id => 1, :post_id => 1, :body => "Post 1 comment." }
          DB[:comments] << { :id => 2, :post_id => 2, :body => "Post 2 comment." }
          DB[:comments] << { :id => 3, :post_id => 3, :body => "Post 3 comment." }

          relation = Blog.join(Post, Blog[:id] => :blog_id).join(Comment, Post[:id] => :post_id)
          blogs_posts_comments = relation.all
          blogs_posts_comments.size.should == 3

          blogs_posts_comments[0][:blogs].should be_a(Blog)
          blogs_posts_comments[0][:blogs].user_id.should == 1
          blogs_posts_comments[0][:blogs].title.should == "Blog 1"
          blogs_posts_comments[0][:posts].should be_a(Post)
          blogs_posts_comments[0][:posts].title.should == "Blog 1, Post 1"
          blogs_posts_comments[0][:comments].should be_a(Comment)
          blogs_posts_comments[0][:comments].body == "Post 1 comment."
          
          blogs_posts_comments[1][:blogs].should be_a(Blog)
          blogs_posts_comments[1][:blogs].user_id.should == 1
          blogs_posts_comments[1][:blogs].title.should == "Blog 1"
          blogs_posts_comments[1][:posts].should be_a(Post)
          blogs_posts_comments[1][:posts].title.should == "Blog 1, Post 2"
          blogs_posts_comments[1][:comments].should be_a(Comment)
          blogs_posts_comments[1][:comments].body == "Post 2 comment."

          blogs_posts_comments[2][:blogs].should be_a(Blog)
          blogs_posts_comments[2][:blogs].user_id.should == 2
          blogs_posts_comments[2][:blogs].title.should == "Blog 2"
          blogs_posts_comments[2][:posts].should be_a(Post)
          blogs_posts_comments[2][:posts].title.should == "Blog 2, Post 1"
          blogs_posts_comments[2][:comments].should be_a(Comment)
          blogs_posts_comments[2][:comments].body == "Post 3 comment."
        end
      end
    end
  end
end
