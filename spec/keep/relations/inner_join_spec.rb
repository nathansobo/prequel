require 'spec_helper'

module Keep
  module Relations
    describe InnerJoin do
      describe "#all" do

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

          Blog.create_table
          Post.create_table
        end


        it "returns instances of CompositeTuple that contain instances of the underlying tables' tuple classes" do
          DB[:blogs] << { :user_id => 1, :title => "Blog 1" }
          DB[:blogs] << { :user_id => 2, :title => "Blog 2" }
          DB[:posts] << { :blog_id => 1, :title => "Blog 1, Post 1" }
          DB[:posts] << { :blog_id => 1, :title => "Blog 1, Post 2" }
          DB[:posts] << { :blog_id => 2, :title => "Blog 2, Post 1" }

          blogs_posts = Blog.join(Post, Blog[:id] => :blog_id).all
          blogs_posts.size.should == 3

          blogs_posts[0][:blogs].should be_a(Blog)
          blogs_posts[0][:blogs].user_id.should == 1
          blogs_posts[0][:blogs].title.should == "Blog 1"
          blogs_posts[0][:posts].should be_a(Post)
          blogs_posts[0][:posts].title.should == "Blog 1, Post 1"

          blogs_posts[1][:blogs].should be_a(Blog)
          blogs_posts[1][:blogs].user_id.should == 1
          blogs_posts[1][:blogs].title.should == "Blog 1"
          blogs_posts[1][:posts].should be_a(Post)
          blogs_posts[1][:posts].title.should == "Blog 1, Post 2"

          blogs_posts[2][:blogs].should be_a(Blog)
          blogs_posts[2][:blogs].user_id.should == 2
          blogs_posts[2][:blogs].title.should == "Blog 2"
          blogs_posts[2][:posts].should be_a(Post)
          blogs_posts[2][:posts].title.should == "Blog 2, Post 1"
        end
      end
    end
  end
end
