class User < ActiveRecord::Base
  serialize :collect_novels
  serialize :download_novels
end
