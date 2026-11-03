class CreateIssueComments < ActiveRecord::Migration[7.2]
  def change
    create_table :issue_comments do |t|
      t.integer :issue_id, null: false
      t.integer :user_id, null: false
      t.integer :parent_id
      t.text :content, null: false
      t.datetime :created_on, null: false
      t.datetime :updated_on, null: false
    end
    add_index :issue_comments, :issue_id
    add_index :issue_comments, :user_id
    add_index :issue_comments, :parent_id
  end
end
