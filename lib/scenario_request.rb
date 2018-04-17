require './lib/Config/server'

class ScenarioRequest
    attr_reader :method, :url, :path

    def initialize(params)
      @method = params['method']
      @url = params['url']
      @path=request_path
    end

    def request_path
      Config::Server.base_url+@url
    end

end