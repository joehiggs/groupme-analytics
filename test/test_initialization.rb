require_relative './../src/gm_initializer.rb'
require_relative './../src/group_data.rb'
require 'minitest/autorun'

class Test_initialization < Minitest::Test

  def setup
    @data = Gm_Initializer.new.data
    #print @data
  end

  def test_names
    names =  @data.names
    print names
  end

  # def test_top_messages
  #   top =  @data.top_messages["20399144"]
  #   assert_equal 13, top[0]["favorited_by"].length
  # end
  #
  # def test_top_images
  #   top =  @data.top_images(3)["20399144"]
  #   assert_equal "https://i.groupme.com/844x1500.jpeg.129c14dd33f24e9a87f5216f03ddafa3", top[0]["attachments"][0]["url"]
  # end
  #
  # def test_top_likers
  #   top =  @data.top_likers["20399144"]
  #   assert_equal 62, top["Bikerdude12"]
  #   assert_equal 42, top["average_the"]
  # end
  #
  # def test_average_posts
  #   top =  @data.top_posters["20399144"]
  #   assert_equal 36, top["Bikerdude12"]
  #   assert_equal 26, top["average_the"]
  # end
  #
  # def test_average_likes
  #   top =  @data.average_likes["20399144"]
  #   assert_equal 1, top["Bikerdude12"]
  #   assert_equal 1, top["average_the"]
  # end
  #
  # def test_average_message_length
  #   top =  @data.average_message_length["20399144"]
  #   assert_equal 32, top["Bikerdude12"]
  #   assert_equal 37, top["average_the"]
  # end
  #
  # def test_datetime
  #   datetime = @data.datetime["20399144"]
  #   assert_equal 23, datetime[0]['hour'].to_i
  # end
  #
  # def test_hall_of_fame
  #   hof = @data.hall_of_fame["20399144"]
  #   assert_equal 0, hof.length
  # end

    # def test_words
    #   words = @data.get_words
    #   print words
    # end

end
