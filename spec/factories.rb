FactoryGirl.define do
  factory :user do
    organizations [1]
    email 'fake@fake.com'
    password 'fakePW'
    password_confirmation 'fakePW'
  end
end