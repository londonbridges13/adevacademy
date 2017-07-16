require "open-uri"

module ResourcesHelper

  def test_resource(resource)
    # search the url for articles, but don't create anything
    check_resource(resource)
  end

  def check_resource(resource) #should be the same as ArticlesHelper
    if resource.resource_type == "error"
      #do nothing
      present "This resoruce has it's own error"
    elsif resource.resource_type == "article-xml" #or resource.resource_url.include? "autoimmunewellness.com" or
      # the weird articles that cause errors
      get_other_articles(resource)
    elsif resource.resource_url.include? "youtube.com" or resource.resource_type == "video"
      # Check for videos in this resource
      get_youtube_videos(resource)
    else
      # Check for articles in this resource
      get_articles(resource)
    end
  end



  #Check Resource Functions

    def get_youtube_videos(resource)
      # this gets the other a youtube channel's videos using Feedjira::fetch_and_parse
      # resource.resource_url.include? "youtube.com" , should be true
        # Check for videos in this resource
        #able_to_parse
        url =  resource.resource_url#"http://feeds.feedburner.com/MinimalistBaker?format=xml"
        #xml = Faraday.get(url).body.force_encoding('utf-8')
        feed = Feedjira::Feed.fetch_and_parse url #for munchies  #resource.resource_url#force_encoding('UTF-8')
        if feed.entries.count > 0
          present "Successful Test"

        else
          present "Found Nothing, but still Successful"
        end
    end

    def get_articles(resource)
      # this gets the other articles using Feedjira::parse
      # Check for articles in this resource
      url =  resource.resource_url#"http://feeds.feedburner.com/MinimalistBaker?format=xml"
      xml = Faraday.get(url).body.force_encoding('utf-8')
      puts url
      feed = Feedjira::Feed.parse xml#url#resource.resource_url#force_encoding('UTF-8')
      if feed.entries.count > 0
        present "Successful Test"

      else
        present "Found Nothing, but still Successful"
      end
    end



    def get_other_articles(resource)
      # this gets the other articles using Feedjira::fetch_and_parse

      url =  resource.resource_url#"http://feeds.feedburner.com/MinimalistBaker?format=xml"
      # xml = Faraday.get(url).body.force_encoding('utf-8')
      puts url
      feed = Feedjira::Feed.fetch_and_parse url#resource.resource_url#force_encoding('UTF-8')
      if feed.entries.count > 0
        present "Successful Test"

      else
        present "Found Nothing, but still Successful"
      end
    end



    # Channel Functions

    def recommend_channels_by_topics(topics)
      # present channels based on the topics that the user follows
      @channels = []

      topics.each do |t|
        recommend_channel t
      end


      # change channel to article, for the image
      channels = []
      @channels.each do |c|
        display = Article.new(id: c.id, title: c.title, article_image_url: c.image.url)
        channels.push display
      end
      present channels
    end

    def recommend_channel(topic)
      # from this one topic, suggest 3 channels that are not yset in the @channels
      # find the channels with the must content under this topic (within last 30 days)

      x_days = 30
      # Grab content from the last 30 days
      articles = topic.articles.where('article_date > ?', x_days.days.ago).where(:publish_it => true)

      potential_channels = []
      articles.each do |a|
        potential_channels.push a.resource
      end

      counts = {}
      potential_channels.group_by(&:itself).each { |k,v| counts[k] = v.length }

      counts.sort_by{|x,y| y}.reverse # order by number of appearances, highest to lowest

      added_channels = 0 #number of channels added by this topic
      counts.each do |c|
        # add channels to the @channels
        # stop when you've added 3 channels
        unless added_channels == 3
          unless @channels.include? c[0]
            @channels.push c[0]
            added_channels += 1
          end
        end
      end

    end




# For Adding Youtube Channels

  def add_channel_by_url(url)
    if url.include? "youtube"
      add_youtube_channel_by(url)
    else

    end
  end


  def add_youtube_channel_by(url)
    channel = Resource.new
    channel.about_url = "#{url}/about"
    channel.resource_type = "video"
    # get title, feed url, etc
    xml = Faraday.get(url).body.force_encoding('utf-8')

    # xml = Feedjira::Feed.parse url

    copy_xml = "#{xml}" # for title
    copy_xml_2 = "#{xml}" # for feed url and channel_id
    copy_xml_3 = "#{xml}" # for photo (use Linkobject)
    copy_xml_4 = "#{xml}" # for description

    # get title
    title = "title"
    channel.title = title
    # title_index = copy_xml.index()


    photo_index = copy_xml_3.index("channel-header-profile-image") # still got trash between
    # clear to photo_index
    copy_xml_3 = copy_xml_3[photo_index...copy_xml_3.length]
    # remove 'src='
    src_index = copy_xml_3.index("src=\"")
    copy_xml_3 = copy_xml_3[src_index + 5...copy_xml_3.length]
    ending_src_index = copy_xml_3.index("\"")

    # remove all after the end of url
    photo_url = copy_xml_3[0...ending_src_index]
    channel.image = open("#{photo_url}")



    # get feed url (channel_id)
    if url.include? "channel"
      channel_id_index = url.index("channel/")
      channel_id = url[channel_id_index + 8 ...url.length]
      feed_url = "https://www.youtube.com/feeds/videos.xml?channel_id=#{channel_id}"
      channel.resource_url = feed_url
    else
      channel_id_index = copy_xml_2.index("channel_id=")
      copy_xml_2 = copy_xml_2[channel_id_index + 11...copy_xml_2.length]
      ending_src_index = copy_xml_2.index("\"")
      channel_id = copy_xml_2[0...ending_src_index]

      feed_url = "https://www.youtube.com/feeds/videos.xml?channel_id=#{channel_id}"
      channel.resource_url = feed_url
    end

    #get title
    feed = Feedjira::Feed.fetch_and_parse feed_url
    channel.title = feed.title

    desc_index = copy_xml_4.index("\"description\"")
    copy_xml_4 = copy_xml_4[desc_index ...copy_xml_4.length]
    content_index = copy_xml_4.index("content")
    copy_xml_4 = copy_xml_4[content_index + 9...copy_xml_4.length]

    ending_src_index = copy_xml_4.index("\"")
    description = copy_xml_4[0...ending_src_index]
    description.gsub! "&#39;", "'"
    channel.desc = description

    channel.save
    return channel

  end




end
