FactoryGirl.define do
  factory :publisher do
    name "O'reilly"
  end

  factory :dev_media, class: Publisher do
    name 'Dev Media'
  end

  factory :super_books, class: Publisher do
    name 'Super Books'
  end
end
