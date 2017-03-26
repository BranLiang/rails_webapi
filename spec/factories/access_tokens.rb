FactoryGirl.define do
  factory :access_token do
    token_digest nil
    accessed_at "2017-03-26 14:51:05"
    user
    api_key
  end
end
