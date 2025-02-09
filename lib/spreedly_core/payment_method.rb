module SpreedlyCore
  class PaymentMethod < Base
    attr_reader( :address1, :address2, :card_type, :city, :country, :created_at,
                 :data, :email, :errors, :first_name, :last_four_digits,
                 :last_name, :month, :number, :payment_method_type, :phone_number,
                 :state, :token, :updated_at, :verification_value, :year, :zip)

    attr_reader :raw_body

    # configure additional required fiels. Like :address1, :city, :state
    def self.additional_required_cc_fields *fields
      @@additional_required_fields ||= Set.new
      @@additional_required_fields += fields
    end

    # clear the configured additional required fields
    def self.reset_additional_required_cc_fields
      @@additional_required_fields = Set.new
    end

    # Lookup the PaymentMethod by token
    def self.find(token)
      return nil if token.nil? 
      verify_get("/payment_methods/#{token}.xml") do |response|
        new(response.parsed_response["payment_method"], response.body)
      end
    end

    # Create a new PaymentMethod based on the attrs hash and then validate
    def initialize(attrs={}, raw_body = nil)
      super(attrs)
      @raw_body = raw_body
      validate
    end

    # Retain the payment method
    def retain
      self.class.verify_put("/payment_methods/#{token}/retain.xml", :body => {}) do |response|
        RetainTransaction.new(response.parsed_response["transaction"])
      end
    end

    # Redact the payment method
    def redact
      self.class.verify_put("/payment_methods/#{token}/redact.xml", :body => {}) do |response|
        RedactTransaction.new(response.parsed_response["transaction"])
      end
    end

    # Make a purchase against the payment method
    def purchase(amount, currency=nil, _gateway_token=nil, ip_address=nil)
      purchase_or_authorize(:purchase, amount, currency, _gateway_token, ip_address)
    end

    # Make an authorize against payment method. You can then later capture against the authorize
    def authorize(amount, currency=nil,  _gateway_token=nil, ip_address=nil)
      purchase_or_authorize(:authorize, amount, currency, _gateway_token, ip_address)
    end

    # Returns the URL that CC data should be submitted to.
    def self.submit_url
      Base.base_uri + '/payment_methods'
    end

    def valid?
      @errors.empty?
    end

    protected

    # Validate additional cc fields like first_name, last_name, etc when
    # configured to do so
    def validate
      return if @has_been_validated
      @has_been_validated = true
      self.class.additional_required_cc_fields.each do |field|
        if instance_variable_get("@#{field}").blank?
          str_field= field.to_s
          friendly_name = if str_field.respond_to?(:humanize)
                            str_field.humanize
                          else
                            str_field.split("_").join(" ")
                          end
                            
          @errors << "#{friendly_name.capitalize} can't be blank"
        end
      end
      @errors = @errors.sort
    end

    def purchase_or_authorize(tran_type, amount, currency, _gateway_token, ip_address)
      transaction_type = tran_type.to_s
      raise "Unknown transaction type" unless %w{purchase authorize}.include?(transaction_type)

      currency ||= "USD"
      _gateway_token ||= self.class.gateway_token
      path = "/gateways/#{_gateway_token}/#{transaction_type}.xml"
      data = {
        :transaction => {
          :transaction_type => transaction_type, 
          :payment_method_token => token,
          :amount => amount,
          :currency_code => currency,
          :ip => ip_address
        }
      }
      self.class.verify_post(path, :body => data) do |response|
        klass = SpreedlyCore.const_get("#{transaction_type.capitalize}Transaction")
        klass.new(response.parsed_response["transaction"])
      end
    end
  end
end
