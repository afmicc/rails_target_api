# == Schema Information
#
# Table name: targets
#
#  id          :bigint           not null, primary key
#  user_id     :bigint           not null
#  area_lenght :integer          not null
#  title       :string           not null
#  topic       :integer          not null
#  latitude    :float            not null
#  longitude   :float            not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  location    :text
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
  validate :validate_target_limit, on: :create

  reverse_geocoded_by :latitude, :longitude, address: :location

  after_validation :reverse_geocode
  after_create_commit :notify_compatible

  delegate :targets, to: :user, prefix: true

  scope :near_targets, lambda { |target|
    where(topic: target.topic)
      .where.not(user_id: target.user_id)
      .near([target.latitude, target.longitude], :area_lenght, radius: target.area_lenght)
  }

  private

  def validate_target_limit
    return if user_targets.count < MAX_TARGETS_PER_USER

    errors.add(:targets, I18n.t('model.targets.errors.to_many'))
  end

  def notify_compatible
    users = User.where(id: Target.near_targets(self).reorder('').distinct.pluck(:user_id))

    NotificationService.new.send_compatible_target(users, self) unless users.empty?
  end
end
