require 'spec_helper'

module Keep
  describe "SQL generation" do
    attr_reader :blogs, :posts
    before do
      @blogs = Keep.table(:blogs) do
        column :id, :integer
        column :user_id, :integer
        column :title, :string
      end

      @posts = Keep.table(:posts) do
        column :id, :integer
        column :blog_id, :integer
        column :title, :string
      end
    end

    specify "tables" do
      posts.to_sql.should be_like_query("select * from posts")
    end

    specify "selections" do
      posts.where(:blog_id => 1).to_sql.should be_like_query(%{
        select * from posts where posts.blog_id = :v1
      }, :v1 => 1)
    end

    specify "inner joins" do
      blogs.join(posts, blogs[:id] => :blog_id).to_sql.should be_like_query(%{
        select
          blogs.id as blogs__id,
          blogs.user_id as blogs__user_id,
          blogs.title as blogs__title,
          posts.id as posts__id,
          posts.blog_id as posts__blog_id,
          posts.title as posts__title
        from
          blogs inner join posts on blogs.id = posts.blog_id
      })

      blogs.where(:user_id => 1).join(posts, blogs[:id] => :blog_id).to_sql.should be_like_query(%{
        select
          t1.id as t1__id,
          t1.user_id as t1__user_id,
          t1.title as t1__title,
          posts.id as posts__id,
          posts.blog_id as posts__blog_id,
          posts.title as posts__title
        from (
            select *
            from blogs
            where t1.user_id = :v1
          ) as t1
          inner join posts on t1.id = posts.blog_id
      }, :v1 => 1)
    end
  end
end