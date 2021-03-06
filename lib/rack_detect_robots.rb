module Rack
  class DetectRobotsResult
    def self.no_robot
      new(nil)
    end
    def initialize(robot_name)
      @robot_name=robot_name
      @is_robot = !!robot_name #no name no robot
    end
    attr_reader :robot_name
    def robot?
      @is_robot
    end
  end
  class DetectRobots
    #this is fast for upto ca. 200 crawlers then use something different (trie...)
    KNOWN_CRAWLERS = [
        'yahoo! slurp',
        'yahoo! de slurp',
        'googlebot',
        'bingbot',
        'aol',
        'scoutjet',
        'ask jeeves',
        'yanga worldsearch bot',
        'gigaboti',
        'ichiro',
        'msnbot',
        'crawler',
        'ia_archiver',
        'jobverifier',
        'twiceler',
        'eurobot',
        'adsbot-google',
        'speedy spider',
        'yacybot',
        'wget',
        'findlinks',
        'feedhub metadatafetcher',
        'jobrobot.de',
        'baiduspider']

    def initialize(app, crawler_regexp=nil)
      @app=app
      @crawler_regexp = (crawler_regexp || Regexp.new(KNOWN_CRAWLERS.map{|bot| Regexp.escape(bot)}.join('|'),"i"))
    end
    
    def call(env)
      env['rack_detect_robots']=test_for_robots(env)
      @app.call(env)
    end
    private
    
    def test_for_robots(env)
      user_agent=env["HTTP_USER_AGENT"]
      return DetectRobotsResult.no_robot if user_agent.nil? || user_agent.empty?
      match=@crawler_regexp.match( user_agent )
      return DetectRobotsResult.no_robot unless match
      DetectRobotsResult.new(match[0])
    end

  end
end
