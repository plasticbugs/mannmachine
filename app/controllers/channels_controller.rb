class ChannelsController < ApplicationController
  def index
    unless Channel.find_by_name(params[:channel_name])
      @channel = Channel.new(:name => params[:channel_name])
      @channel.save
    else
      @channel = Channel.find_by_name(params[:channel_name])
    end
  end

end
