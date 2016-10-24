require_relative './conversation.rb'
require 'date'

class Group_Data
  attr_accessor :chats, :top_messages, :top_images, :top_likers, :top_posters, :average_likes,
                :average_message_length, :datetime, :hall_of_fame, :names

  # creates a dictionary of conversations to their data
  # @param [parsed JSON data] conversations
  # @param token
  # @param base_url
  def initialize(conversations, token, base_url)
    @chats = Array.new
    conversations["response"].each do |conversation|
      convo = Conversation.new conversation, token, base_url
      if !convo.id.nil?
        @chats.push convo
      end
    end

    # print @chats.length
    # @top_messages = get_top_messages
    # @top_images = get_top_images
    # @top_likers = get_top_likers
    # @top_posters = get_top_posters
    # @average_likes = get_average_likes
    # @average_message_length = get_average_message_length
    # @datetime = get_datetime
    # @hall_of_fame = get_hall_of_fame
    @names = get_names

  end

  # @param [int] amount - the amount messages desired
  # @return hash of each chat's id mapped to the list of most liked messages
  def get_top_messages
    top_hash = {}
    @chats.each do |chat|
      temp_hash = {chat.id => chat.messages_sorted_by_likes}
      top_hash.merge!(temp_hash)
    end
    return top_hash
  end

  # @param [int] amount - the amount messages desired
  # @return hash of each chat's id mapped to the list of most liked images
  def get_top_images
    top_hash = {}
    @chats.each do |chat|
      messages = chat.messages_sorted_by_likes
      top_images = Array.new
      messages.each do |message|
        if !message['attachments'].nil?
          flag = false
          message['attachments'].each do |attachment|
            if attachment['type'] == 'image'
              top_images.push(message)
              flag = true
            end
            next if flag
          end
        end
      end
      top_hash_to_add = {chat.id => top_images}
      top_hash.merge!(top_hash_to_add)
    end
    return top_hash
  end

  # @return hash of each chat's id mapped to the list users ranked by likes given vs the average
  def get_top_likers
    chat_ranks = {}
    # initialize members' like count to 0
    @chats.each do |chat|
      members = {}
      id_to_nickname = {}
      chat.members.each do |member|
        member_to_add = {member['nickname'] => 0}
        members.merge!(member_to_add)
        id_to_nickname_to_add = {member['user_id'] => member['nickname']}
        id_to_nickname.merge!(id_to_nickname_to_add)
      end
      chat.messages.each do |message|
        if !message['favorited_by'].nil?
          message['favorited_by'].each do |favorite|
            members[id_to_nickname[favorite]] = members[id_to_nickname[favorite]].to_i + 1
          end
        end
      end
      members.sort_by {|_key, value| value}.reverse
      # compute and add the average to the end of the hash
      average = 0
      members.each do |_nickname, likes|
        average += likes
      end
      average /= members.length
      # TODO: make this edge case avoidance not so hacky
      member_to_add = {'average_the' => average}
      members.merge!(member_to_add)
      chat_ranks_to_add = {chat.id => members}
      chat_ranks.merge!(chat_ranks_to_add)
    end
    return chat_ranks
  end

  # @return hash of each chat's id mapped to the list users ranked by messages posted
  def get_top_posters
    chat_ranks = {}
    # initialize members' like count to 0
    @chats.each do |chat|
      message_count = {}
      id_to_nickname = {}
      chat.members.each do |member|
        message_count_to_add = {member['nickname'] => 0}
        message_count.merge!(message_count_to_add)
        id_to_nickname_to_add = {member['user_id'] => member['nickname']}
        id_to_nickname.merge!(id_to_nickname_to_add)
      end
      chat.messages.each do |message|
        #if chat.members['user_id'].include?(message['user_id'].to_i)
        message_count[id_to_nickname[message['user_id']]] = message_count[id_to_nickname[message['user_id']]].to_i + 1
        #end
      end
      total = 0
      message_count.each do |_nickname, number|
        total += number.to_i
      end
      total_average = total/message_count.length
      message_count.sort_by {|_key, value| value}.reverse
      avg_to_add = {'average_the' => total_average}
      message_count.merge!(avg_to_add)
      chat_ranks_to_add = {chat.id => message_count}
      chat_ranks.merge!(chat_ranks_to_add)
    end
    return chat_ranks
  end

  # @return hash of each chat's id mapped to the list users ranked by likes received vs the average
  def get_average_likes
    chat_ranks = {}
    # initialize members' like count to 0
    @chats.each do |chat|
      likes = {}
      message_count = {}
      average = {}
      id_to_nickname = {}
      chat.members.each do |member|
        like_to_add = {member['nickname'] => 0}
        likes.merge!(like_to_add)
        message_count_to_add = {member['nickname'] => 0}
        message_count.merge!(message_count_to_add)
        average_to_add = {member['nickname'] => 0}
        average.merge!(average_to_add)
        id_to_nickname_to_add = {member['user_id'] => member['nickname']}
        id_to_nickname.merge!(id_to_nickname_to_add)
      end
      chat.messages.each do |message|
        #if chat.members['user_id'].include?(message['user_id'].to_i)
          message_count[id_to_nickname[message['user_id']]] = message_count[id_to_nickname[message['user_id']]].to_i + 1
          if !message['favorited_by'].nil?
            likes[id_to_nickname[message['user_id']]] = likes[id_to_nickname[message['user_id']]].to_i + message['favorited_by'].length
          end
        #end
      end
      total_average = 0
      average.each do |nickname, _average_value|
        avg = likes[nickname].to_i / message_count[nickname].to_i
        total_average += avg
        average[nickname] = avg
      end
      total_average /= average.length
      average.sort_by {|_key, value| value}.reverse
      avg_to_add = {'average_the' => total_average}
      average.merge!(avg_to_add)
      chat_ranks_to_add = {chat.id => average}
      chat_ranks.merge!(chat_ranks_to_add)
    end
    return chat_ranks
  end

  # @return hash of each chat's id mapped to the list users ranked by message length received vs the average
  def get_average_message_length
    chat_ranks = {}
    # initialize members' like count to 0
    @chats.each do |chat|
      message_length = {}
      message_count = {}
      average = {}
      id_to_nickname = {}
      chat.members.each do |member|
        length_to_add = {member['nickname'] => 0}
        message_length.merge!(length_to_add)
        message_count_to_add = {member['nickname'] => 0}
        message_count.merge!(message_count_to_add)
        average_to_add = {member['nickname'] => 0}
        average.merge!(average_to_add)
        id_to_nickname_to_add = {member['user_id'] => member['nickname']}
        id_to_nickname.merge!(id_to_nickname_to_add)
      end
      chat.messages.each do |message|
        #if chat.members['user_id'].include?(message['user_id'].to_i)
        message_count[id_to_nickname[message['user_id']]] = message_count[id_to_nickname[message['user_id']]].to_i + 1
        if !message['text'].nil?
          message_length[id_to_nickname[message['user_id']]] = message_length[id_to_nickname[message['user_id']]].to_i + message['text'].length
        end
      end
      total_average = 0
      average.each do |nickname, _average_value|
        avg = message_length[nickname].to_i / message_count[nickname].to_i
        total_average += avg
        average[nickname] = avg
      end
      total_average /= average.length
      average.sort_by {|_key, value| value}.reverse!
      avg_to_add = {'average_the' => total_average}
      average.merge!(avg_to_add)
      chat_ranks_to_add = {chat.id => average}
      chat_ranks.merge!(chat_ranks_to_add)
    end
    return chat_ranks
  end

  # @return hash of hash containing each message's year, date, day of week, time per chat
  def get_datetime
    datetime_all_chats = {}
    @chats.each do |chat|
      datetime = Array.new
      chat.messages.each do |message|
        if !message['created_at'].nil?
          dt = Time.at(message['created_at']).to_datetime
          datetime_to_add = {'year'=>dt.strftime("%Y"), 'month'=>dt.strftime("%m"), 'day'=>dt.strftime("%d"),
                             'hour'=>dt.strftime("%H"), 'minute'=>dt.strftime("%M"), 'second'=>dt.strftime("%S")}
          datetime.push(datetime_to_add)
        end
      end
      datetime_to_add = {chat.id=>datetime}
      datetime_all_chats.merge!(datetime_to_add)
    end
    return datetime_all_chats
  end

  # @return list of messages receiving likes from every member
  def get_hall_of_fame
    hall_of_fame_all_chats = {}
    @chats.each do |chat|
      hall_of_fame = Array.new
      if !chat.nil? and !chat.messages_sorted_by_likes.nil?
        index = 0
        while chat.messages_sorted_by_likes[index]['favorited_by'].length == chat.members.length
          hall_of_fame.push(chat.messages_sorted_by_likes[index])
          index += 1
        end
      end
      hall_of_fame_to_add = {chat.id=>hall_of_fame}
      hall_of_fame_all_chats.merge! hall_of_fame_to_add
    return hall_of_fame_all_chats
    end
  end



  # get groupme usernames historically


  def get_names
    chat_names = {}
    @chats.each do |chat|
      names = {}
      id_to_nickname = {}
      chat.members.each do |member|
        message_count_to_add = {member['nickname'] => Array.new}
        names.merge!(message_count_to_add)
        id_to_nickname_to_add = {member['user_id'] => member['nickname']}
        id_to_nickname.merge!(id_to_nickname_to_add)
      end
      chat.messages.each do |message|
        if !(names[id_to_nickname[message['user_id']]].nil?)
          if !(names[id_to_nickname[message['user_id']]].include?(message['name']))
            names[id_to_nickname[message['user_id']]].push(message['name'])
          end
        end
      end
      chat_names.merge!(names)
    end
    return chat_names
  end





end