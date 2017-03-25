class AddColumnConfirmationRedirectUrlOnUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :confirmation_redirect_url, :text
  end
end
