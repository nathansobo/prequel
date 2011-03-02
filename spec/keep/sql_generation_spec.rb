require 'spec_helper'

module Keep
  describe "SQL generation" do
    attr_reader :blogs, :posts, :comments
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

      @comments = Keep.table(:comments) do
        column :id, :integer
        column :post_id, :integer
        column :body, :string
      end
    end

    describe "a table" do
      it "generates the appropriate SQL" do
        posts.to_sql.should be_like_query("select * from posts")
      end
    end

    describe "a selection" do
      it "generates the appropriate SQL" do
        posts.where(:blog_id => 1).to_sql.should be_like_query(%{
          select * from posts where posts.blog_id = :v1
        }, :v1 => 1)
      end
    end

    describe "a simple inner join" do
      it "generates appropriate sql, aliasing select list columns to their fully qualified names" do
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
      end
    end

    describe "an inner join containing a subquery" do
      it "generates appropriate sql, aliasing columns to their qualified names and correctly referencing columns derived from the subquery" do
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
              where blogs.user_id = :v1
            ) as t1
            inner join posts on t1.id = posts.blog_id
          }, :v1 => 1)
      end
    end

    describe "a left-associative 3-table inner join with a subquery" do
      it "generates the appropriate sql" do
        blogs.where(:user_id => 1).join(posts, blogs[:id] => :blog_id).join(comments, posts[:id] => :post_id).to_sql.should be_like_query(%{
          select
            t1.id as t1__id,
            t1.user_id as t1__user_id,
            t1.title as t1__title,
            posts.id as posts__id,
            posts.blog_id as posts__blog_id,
            posts.title as posts__title,
            comments.id as comments__id,
            comments.post_id as comments__post_id,
            comments.body as comments__body
          from
            (
              select *
              from blogs
              where blogs.user_id = :v1
            ) as t1
            inner join posts on t1.id = posts.blog_id
            inner join comments on posts.id = comments.post_id
          }, :v1 => 1)
      end
    end

    describe "a right-associative 3-table inner join, with subqueries on either side" do
      it "generates the appropriate sql" do
        posts_comments = posts.join(comments, posts[:id] => :post_id)
        rel = blogs.where(:user_id => 1).join(posts_comments, blogs[:id] => :blog_id)

        rel.to_sql.should be_like_query(%{
          select t1.id                as t1__id,
                 t1.user_id           as t1__user_id,
                 t1.title             as t1__title,
                 t2.posts__id         as t2__posts__id,
                 t2.posts__blog_id    as t2__posts__blog_id,
                 t2.posts__title      as t2__posts__title,
                 t2.comments__id      as t2__comments__id,
                 t2.comments__post_id as t2__comments__post_id,
                 t2.comments__body    as t2__comments__body
          from   (select *
                  from   blogs
                  where  blogs.user_id = :v1) as t1
                 inner join (select posts.id         as posts__id,
                                    posts.blog_id    as posts__blog_id,
                                    posts.title      as posts__title,
                                    comments.id      as comments__id,
                                    comments.post_id as comments__post_id,
                                    comments.body    as comments__body
                             from   posts
                                    inner join comments
                                      on posts.id = comments.post_id) as t2
                   on t1.id = t2.posts__blog_id
        }, :v1 => 1)
      end
    end
  end
end