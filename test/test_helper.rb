ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'factory_girl'

class ActiveSupport::TestCase

  include FactoryGirl::Syntax::Methods
  FactoryGirl.find_definitions

end
