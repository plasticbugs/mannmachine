class Video < ActiveRecord::Base
  attr_accessible :audio_path, :channel_id, :converted, :description, :download_link, :duration, :publish_date, :s3_permalink, :thumb_url, :title, :video_id
  belongs_to :channel
end
