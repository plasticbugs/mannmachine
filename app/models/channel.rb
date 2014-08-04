class Channel < ActiveRecord::Base
  attr_accessible :custom_author, :custom_category, :custom_description, :custom_keywords, :custom_subcategory, :name
  has_many :videos

  def self.save_most_recent(channel_name)
    feed_url = "https://gdata.youtube.com/feeds/api/users/#{channel_name}/uploads"
    xml_feed = Nokogiri::XML(open(feed_url).read)

    xml_feed.css("entry").each do |item|


      # unless video already exists in DB, add it
      unless Video.find_by_video_id(item.css("media|player").first["url"])
        @video = Video.new
        @video.title = item.css("title").text
        @video.description = item.css("content").text
        @video.thumb_url = item.css("media|thumbnail").first["url"]
        @video.publish_date = item.css("published").text
        @video.video_id = item.css("media|player").first["url"]
        @video.download_link = ViddlRb.get_urls(@video.video_id)[0]
        @video.duration = item.css("yt|duration")[0].attributes["seconds"].value.to_i
        @video.channel_id = Channel.find_by_name(channel_name).id
        @video.save

        logger.info "Added #{@video.title} to the DB"

      end

    end
    Channel.generate_mp3s(channel_name)
  end

  def self.generate_mp3s(channel_name)
    logger.info "Generating MP3s"
    @videos = Channel.find_by_name(channel_name).videos


    @service = S3::Service.new(
      :access_key_id => ENV["AWS_ACCESS_KEY_ID"],
      :secret_access_key => ENV["AWS_SECRET_ACCESS_KEY"])

    @bucket = @service.buckets.find("mannmachine")

    @videos.each do |video|
      unless video.converted
        logger.info "Generating #{video.title}"
        video_file = open(video.download_link)

        sanitized_title = video.title.gsub(/\s+/, "").gsub(/[^0-9a-z ]/i, '')[0,20]

        video.audio_path = "#{sanitized_title}.mp3"
        video.save
        system "ffmpeg -i #{video_file.path} tmp/#{video.audio_path}"
        video.save
        File.delete(video_file.path)
        new_object = @bucket.objects.build(video.audio_path)
        new_object.content = open("tmp/#{video.audio_path}")
        new_object.save
        video.s3_permalink = new_object.url
        video.converted = true
        video.save
      end
    end
  end

end
