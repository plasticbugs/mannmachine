class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.string :title
      t.text :description
      t.string :thumb_url
      t.datetime :publish_date
      t.string :video_id
      t.text :download_link
      t.boolean :converted
      t.string :audio_path
      t.integer :duration
      t.string :s3_permalink
      t.integer :channel_id

      t.timestamps
    end
  end
end
