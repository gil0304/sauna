require 'bundler/setup'
Bundler.require

ActiveRecord::Base.establish_connection

class User < ActiveRecord::Base
  has_secure_password
  has_many :contents
  has_many :comments
  has_many :contents, through: :comments
  
  validates :name, presence: true, uniqueness: true
  
  validates :mail, presence: true, uniqueness: true

  validates :password, presence: true, format: { with: /\A(?=.*[a-zA-Z])(?=.*[0-9]).+\z/ }
end

class Content < ActiveRecord::Base
  belongs_to :user
  has_many :comments
  has_many :users, through: :comments
  
  validates :title, presence: true
  validates :body, presence: true
end

class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :content
  
  validates :body, presence: true
end
