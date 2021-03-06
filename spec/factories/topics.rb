# == Schema Information
#
# Table name: topics
#
#  id         :bigint           not null, primary key
#  title      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :topic do
    title { Faker::Lorem.unique.word }
  end
end
