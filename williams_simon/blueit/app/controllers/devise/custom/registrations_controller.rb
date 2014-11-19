class Devise::Custom::RegistrationsController < Devise::RegistrationsController
  def new
    super # no customization, simply call the devise implementation
  end

  def create
      super # this calls Devise::RegistrationsController#create
      # put your own credentials here
      account_sid = 'ACb0f38752b43817ddc39aa6852394586c'
      auth_token = '1edc984260649edfec8e70b339777112'

      # set up a client to talk to the Twilio REST API
      @client = Twilio::REST::Client.new account_sid, auth_token
      @client.messages.create(
            from: '+19253504323',
            to: "#{current_user.mobile_number}",
            body: "Welcome to Blueit #{current_user.email}"
          ) 

  end

  def update
    super # no customization, simply call the devise implementation 
  end

end