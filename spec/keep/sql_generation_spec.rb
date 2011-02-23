require 'spec_helper'

module Keep
  describe "SQL generation" do
    specify "tables" do
      posts = Keep.table(:posts) do
        column :id, :key
        column :blog_id, :key
        column :title, :string
      end

      p posts.to_sql

    end
  end
end