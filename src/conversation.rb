require 'json'
require 'net/http'

class Conversation
  attr_reader :id, :name, :count, :members, :description, :img, :type, :messages, :messages_sorted_by_likes

  # @param [parsed JSON object] conversation
  def initialize(conversation, token, base_url)
    #print conversation['name']
    #TODO: remove filter for highschool groupchat
    # to get a specific group ==> conversation['name'] == '[GROUP NAME]')and
    if (conversation['messages']['count'] > 0)
      @id = conversation['id']
      @name = conversation['name']
      @count = Integer(conversation['messages']['count'])
      @members = conversation['members']
      @description = conversation['description']
      @img = conversation['image_url']
      @type = 'group'
      last_message_id = conversation['last_message_id']
      @messages = get_all_messages_group token, base_url, last_message_id
      @messages_sorted_by_likes = order_messages_by_likes
    else
      @id = nil
    end
  end

  # initializes class messages variable
  # @param token
  # @param base_url
  # @param [String] last_message_id
  # @return [array] messages
  def get_all_messages_group(token, base_url, last_message_id)
    messages = Array.new
    message_count = 0
    while message_count < @count
      uri = URI(base_url + 'groups/'+@id+'/messages'+ token + '&before_id=' + last_message_id.to_s +
                    '&per_page=99')
      response = Net::HTTP.get(uri)
      message =  JSON.parse(response)['response']['messages']
      message.each do |msg|
        messages.push(msg)
      end
      message_count += message.length
      last_message_id = message[-1]['id']
    end
    return messages
  end

  # @return [array] messages sorted by likes
  def order_messages_by_likes
    return @messages.sort_by { |message| message["favorited_by"].length }.reverse!
  end

  # # @param [string] user id
  # # @return the member's nickname or -1 if not found
  # def get_nickname_from_id(id)
  #   @members.each do |member|
  #     if member['user_id'] == id
  #       return member['nickname']
  #     end
  #   end
  # end

end