module Restfulie::Client
  class Dsl

    def initialize
      @requests = []
      trait :base
      trait :verb
      request :base_request
      request :setup_header
      request :serialize_body
      request :enhance_response
      # request :cache
      request :follow_request
    end
    
    def request(what, *args)
      req = "Restfulie::Client::Feature::#{what.to_s.classify}".constantize
      @requests << {:type => req, :args => args}
      self
    end

    def trait(sym)
      t = "Restfulie::Client::Feature::#{sym.to_s.classify}".constantize
      self.extend t
      self
    end

    def method_missing(sym, *args)
      if Restfulie::Client::Feature.const_defined? sym.to_s.classify
        loaded = true
        trait sym
      end
      if Restfulie::Client::Feature.const_defined? "#{sym.to_s.classify}Request"
        loaded = true
        request "#{sym.to_s}Request", *args
      end
      if loaded
        self
      else
        super sym, *args
      end
    end
    
    def request_flow(env = {})
      Restfulie::Common::Logger.logger.debug "ready to execute request using stack #{@requests}"
      StackNavigator.new(@requests).continue(self, env)
    end

  end  

end