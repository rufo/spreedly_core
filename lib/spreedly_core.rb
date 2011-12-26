require 'set'

require 'active_support'
require 'active_support/core_ext/object/blank'
require 'httparty'

require 'spreedly_core/base'
require 'spreedly_core/payment_method'
require 'spreedly_core/gateway'
require 'spreedly_core/transactions'

module SpreedlyCore
  # Hash of user friendly credit card name to SpreedlyCore API name
  CARD_TYPES = {
    "Visa" => "visa",
    "MasterCard" => "master",
    "American Express" => "american_express",
    "Discover" => "discover"
  }

  # Custom exception which occurs when a request to SpreedlyCore times out
  # See SpreedlyCore::Base.default_timeout 
  class TimeOutError < RuntimeError; end

  # Configure SpreedlyCore with a particular account and default gateway
  def self.configure(login, secret, gateway_token)
    Base.configure(login, secret, gateway_token)
  end

  # returns the configured SpreedlyCore login
  def self.login; Base.login; end

  # A container for a response from a payment gateway
  class Response < Base
    attr_reader(:success, :message, :avs_code, :avs_message, :cvv_code,
                :cvv_message, :error_code, :error_detail, :created_at,
                :updated_at) 
  end
end
