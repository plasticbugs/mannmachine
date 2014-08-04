feed_url = "https://gdata.youtube.com/feeds/api/users/#{@channel.name}"
xml_feed = Nokogiri::XML(open(feed_url).read)


title = xml_feed.css("entry yt|username").text
author = xml_feed.css("entry title").text
description = xml_feed.css("entry content").text
keywords = xml_feed.css("entry category").last.attributes["term"].value
image = xml_feed.css("media|thumbnail")[0].attributes["url"].value
ext = 'mp3'


xml.rss "xmlns:itunes" => "http://www.itunes.com/dtds/podcast-1.0.dtd",  "xmlns:media" => "http://search.yahoo.com/mrss/",  :version => "2.0" do
  xml.channel do
    xml.title title
    xml.link xml_feed.css("link").first.attributes["href"].value
    xml.description description
    xml.language 'en'
    xml.pubDate @posts.first.publish_date.to_s(:rfc822)
    xml.lastBuildDate @posts.first.publish_date.to_s(:rfc822)
    xml.itunes :author, author
    xml.itunes :keywords, keywords
    xml.itunes :explicit, 'clean'
    xml.itunes :image, :href => image
    xml.itunes :owner do
      xml.itunes :name, author
    end
    xml.itunes :block, 'no'
    xml.itunes :category, :text => 'Technology' do
      xml.itunes :category, :text => 'Software How-To'
    end
    xml.itunes :category, :text => 'Education' do
      xml.itunes :category, :text => 'Training'
    end

    @posts.each do  |post|

      if post.audio_path
        xml.item do
          xml.title post.title
          xml.description post.description
          xml.pubDate post.publish_date.to_s(:rfc822)
          xml.enclosure :url => (post.s3_permalink), :type => 'audio/mp3'
          xml.link post.video_id
          xml.guid post.video_id
          xml.itunes :author, author
          xml.itunes :subtitle, truncate(post.description, :length => 150)
          xml.itunes :summary, post.description
          xml.itunes :explicit, 'no'
          xml.itunes :duration, post.duration
        end
      end
    end
  end
end