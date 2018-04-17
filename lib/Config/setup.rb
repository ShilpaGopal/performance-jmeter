require 'net/http'
require 'uri'

def env(variable, default=nil)
  default = yield if block_given?
  ENV[variable] || default
end

module Config
  class Setup
    def self.throughput_per_minute
      env('THROUGHPUT_PER_MINUTE', '30').to_f
    end

    def self.thread_count
      env('THREAD_COUNT', '2').to_i
    end

    def self.users_rampup_time
      env('USERS_RAMPUP_TIME', '1').to_i
    end

    def self.loop_count
      env('LOOP_COUNT', '1').to_i
    end

    def self.db_host
      env('DB_HOST', '127.0.0.1')
    end

    def self.environment
      env('TEST_ENV','test')
    end

    def self.db_port
      env('DB_PORT', '8086')
    end

    def self.database_name
      env('DATABASE_NAME', 'default')
    end

    def self.check_db_configuration(db_url)
      uri = URI.parse("#{db_url}/write?db=#{database_name}")
      request = Net::HTTP::Post.new(uri)
      req_options = {
          use_ssl: uri.scheme == "https",
      }
      Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
    end

    def self.influxdb_url
      db_url = "http://#{db_host}:#{db_port}"
      puts "checking for db connection: db_url: #{db_url} database name: #{database_name}"
      response = check_db_configuration(db_url)
      raise 'Database not found' if response.code == '404'
      "#{db_url}/write?db=#{database_name}"
    end
  end
end
