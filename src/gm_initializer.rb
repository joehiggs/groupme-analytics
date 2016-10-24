require_relative './group_data.rb'
require 'json'
require 'net/http'


# initializes the GroupMe GMData putting it into the data structure
class Gm_Initializer

  attr_reader :data

  # starts the process of pulling the data
  # TODO: change my token from the default upon release
  # @param [String] token_in -- the user's token which they input
  def initialize(token_in= '000000000'
                     )
    # TODO: token validation
    @base_url = 'https://api.groupme.com/v3/'
    @token = '?token=' + token_in
    @conversations = get_conversations
    @data = Group_Data.new @conversations, @token, @base_url
  end

  # @return parse_data containing 2 "responses" (dm's(chats) and groups)
  def get_conversations
    response_length = -1
    response_code = 0
    while response_code != 200
      parse_data = JSON.parse(gm_get('groups'))
      response_length = parse_data["response"].length
      response_code = parse_data["meta"]["code"]
    end
    return parse_data
  end

  # @param [String] request
  # @return the get request response's data
  def gm_get(request)
    uri = URI(@base_url + request + @token)
    result =  Net::HTTP.get(uri)
    #print result
    return result
  end

end