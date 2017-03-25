class AddAccessKeyToApiKeys < ActiveRecord::Migration[5.1]
  def change
    add_column :api_keys, :access_key, :string, index: true, unique:true
  end
end
