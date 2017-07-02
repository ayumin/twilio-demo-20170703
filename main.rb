require 'sinatra'
require 'sinatra/base'
require 'twilio-ruby'
require 'rubygems'
require 'net/http'
require 'uri'
require 'faraday'

class MainApp < Sinatra::Base
  before do
    @rootPath = "https://#{ENV['HEROKU_APP_NAME']}.herokuapp.com"
  end

  post '/call' do
    content_type = 'text/xml'
    fromNumber = params[:From]
    Twilio::TwiML::Response.new do |r|
      r.Say "Twilioのサンプル。SMSメッセージをおくります。"
      r.Pause
      r.Redirect "#{@rootPath}/postmsm/#{fromNumber}", method: 'post'
    end.text
  end

  post '/postsms/:fromNumber' do
    contect_type 'text/xml'
    fromNumber = params[:fromNumber]

    Twilio::TwiML::Response.new do |r|
      conn = Faraday.new(:url => @rootPath) do |faraday|
        faraday.request :url_encode
        faraday.respose :logger
        faraday.adapter Faraday.default_adapter
      end
      conn.post "/sendsms/#{fromNumber}"

      r.Hangup
    end.text
  end

  post '/sendsms/:postPhoneNumber' do
    content_type = 'text/xml'

    postPhoneNumber = params[:postPhoneNumber]

    if postPhoneNumber != nil
      postPhoneNumber = postPhoneNumber.gsub(/\A0/, "+81")

      account_sid = ENV['TWILIO_ACCOUNT_SID']
      auth_token = ENV['TWILIO_AUTH_TOKEN']

      client = Twilio::REST::Client.new account_sid, auth_token

      from = ENV['TWILIO_PHONE']

      client.account.messages.create(
        :from => from,
        :to   => postPhoneNumber,
        :body => "SMSメッセージを送信しました"
      )
    end
  end

  get '/' do
    'Hello, World!'
  end
end

