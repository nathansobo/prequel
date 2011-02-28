require 'spec_helper'

module Keep
  describe "SQL generation" do
    attr_reader :blogs, :posts
    before do
      @blogs = Keep.table(:blogs) do
        column :id, :key
        column :user_id, :key
        column :title, :string
      end

      @posts = Keep.table(:posts) do
        column :id, :key
        column :blog_id, :key
        column :title, :string
      end
    end

    specify "tables" do
      posts.to_sql.should be_like_query("select * from posts")
    end

    specify "selections" do
      posts.where(:blog_id => 1).to_sql.should be_like_query(%{
        select * from posts posts.blog_id = :v1
      }, :v1 => 1)
    end

    specify "inner joins" do
      blogs.join(posts, blogs[:id] => :blog_id).to_sql.should be_like_query(%{
        select * from blogs inner join posts on blogs.id = posts.blog_id
      })

      p blogs.where(:user_id => 1).join(posts, blogs[:id] => :blog_id).to_sql
    end
  end
end