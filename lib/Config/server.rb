module Config
  class Server
    def self.base_url
      env('SITE_URL')
    end

    def self.site_username
      env('SITE_USERNAME')
    end

    def self.site_password
      env('SITE_PASSWORD')
    end

    private
    def self.env(variable)
      if ENV[variable]
        ENV[variable]
      else
        raise "No value found for required ENV variable: #{variable}"
      end
    end
  end
end
