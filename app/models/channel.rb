class Channel < ActiveRecord::Base
  attr_accessible :custom_author, :custom_category, :custom_description, :custom_keywords, :custom_subcategory, :name
end
