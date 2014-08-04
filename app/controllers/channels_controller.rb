class ChannelsController < ApplicationController
  def index
    unless Channel.find_by_name(params[:channel_name])
      @channel = Channel.new(:name => params[:channel_name])
      @channel.save
    else
      @channel = Channel.find_by_name(params[:channel_name])
    end

    Channel.delay.save_most_recent(params[:channel_name])
    @videos = @channel.videos.all.sort_by {|vid| vid.publish_date}.reverse!

  end


  def feed
    @channel = Channel.find_by_name(params[:channel_name])
    @posts = @channel.videos.all.sort_by{ |vid| vid.publish_date}.reverse!

    respond_to do |format|
      format.html
      format.rss { render :layout => false } #feed.rss.builder
    end
  end

end
