# == Schema Information
#
# Table name: targets
#
#  id          :bigint           not null, primary key
#  user_id     :bigint
#  area_lenght :integer          not null
#  title       :string           not null
#  topic       :integer          not null
#  latitude    :decimal(10, 6)   not null
#  longitude   :decimal(10, 6)   not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Target < ActiveRecord::Base
  MAX_TARGETS_PER_USER = 10

  enum topic:
  {
    football: 0,
    travel: 1,
    politics: 2,
    art: 3,
    dating: 4,
    music: 5,
    movies: 6,
    series: 7,
    food: 8
  }

  belongs_to :user

  validates :area_lenght, :title, presence: true
  validates :topic, presence: true, inclusion: { in: topics.keys }
  validates :latitude, presence: true,
                       numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitude, presence: true,
                        numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }
  validate :validate_target_limit

  private

  def validate_target_limit
    errors.add(:targets, 'are too many') if user && user.targets.count >= MAX_TARGETS_PER_USER
  end
end
