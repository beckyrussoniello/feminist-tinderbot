# encoding: UTF-8

require 'net_http_ssl_fix'
require 'mechanize'
require 'faraday'
require 'faraday_middleware'
require 'json'
require 'classifier-reborn'
require 'pry'
require './profile.rb'
require './swiper.rb'

class FeministTinderbot

  TINDER_OAUTH_URL = 'https://www.facebook.com/v2.6/dialog/oauth?redirect_uri=fb464891386855067%3A%2F%2Fauthorize%2F&scope=user_birthday,user_photos,user_education_history,email,user_relationship_details,user_friends,user_work_history,user_likes&response_type=token%2Csigned_request&client_id=464891386855067'.freeze
  MOZILLA_USER_AGENT = 'Mozilla/5.0 (Linux; U; en-gb; KFTHWI Build/JDQ39) AppleWebKit/535.19 (KHTML, like Gecko) Silk/3.16 Safari/535.19'.freeze
  TINDER_USER_AGENT = 'Tinder/4.0.9 (iPhone; iOS 8.1.1; Scale/2.00)'

  attr_accessor :fb_token, :tinder_token, :swiper, :targets, :file_targets, :profile_text

  def initialize(fb_login:, fb_password:)
    get_facebook_auth_token(fb_login: fb_login, fb_password: fb_password)
    establish_tinder_connection
    @targets = []
    @swiper = Swiper.new(connection: @conn)
  end

  def get_facebook_auth_token(fb_login:, fb_password:)
    mechanize = Mechanize.new
    mechanize.user_agent = MOZILLA_USER_AGENT

    login_form = mechanize.get(TINDER_OAUTH_URL).form do |f|
      f.email = fb_login
      f.pass = fb_password
    end

    @fb_token = login_form.submit.form.submit.body.split('access_token=')[1].split('&')[0]
  end

  def establish_tinder_connection
    @conn = Faraday.new(url: 'https://api.gotinder.com') do |faraday|
      faraday.request :json                    # form-encode POST params
      faraday.response  :logger                # log requests to STDOUT
      faraday.adapter Faraday.default_adapter  # make requests with Net::HTTP
    end

    @conn.headers['User-Agent'] = TINDER_USER_AGENT
    rsp = @conn.post '/auth', { facebook_token: fb_token }
    jrsp = JSON.parse(rsp.body)
    @tinder_token = jrsp["token"]
    @conn.token_auth(tinder_token)
    @conn.headers['X-Auth-Token'] = tinder_token
  end

  def get_nearby_users
    response = @conn.post 'user/recs'
    parsed_response = JSON.parse(response.body)
    parsed_response['results']
  end

  def auto_swipe(log_targets: true) # RIGHT NOW THIS JUST LOGS NEARBY USERS' PROFILE DATA. TODO: SWIPING CRITERIA / ACTUAL SWIPING.
    @file_targets = File.open('targets.txt', 'a') if log_targets
    @profile_text = File.open('profile_text.txt', 'a')

    begin
      nearby_users = get_nearby_users
      while(nearby_users.present?)
        nearby_users.each { |target| evaluate_profile(target) }
        nearby_users = get_nearby_users
      end
    rescue IOError => e
      # some error
    ensure
      file_targets.close if file_targets
      profile_text.close if profile_text
    end
  end

  def evaluate_profile(target)
    profile = Profile.new(profile_hash: target)
    targets.push(profile)
    file_targets.write(target.inspect + "\n")
    profile_text.write(profile.all_text + "\n\n")
    swiper.swipe(profile)
  end
end