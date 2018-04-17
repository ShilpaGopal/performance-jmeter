require './lib/Config/setup'
require 'fileutils'
require 'pry'
require './lib/scenario'
require './lib/thread_group_user'
require 'ruby-jmeter'
require 'nokogiri'
require 'json'
include FileUtils

module RubyJmeter
  class BackendListener
    attr_accessor :doc
    include Helper

    def initialize(params={})
      @doc = Nokogiri::XML(<<-EOS.strip_heredoc)
      <BackendListener guiclass="BackendListenerGui" testclass="BackendListener" testname="Backend Listener" enabled="true">
        <elementProp name="arguments" elementType="Arguments" guiclass="ArgumentsPanel" testclass="Arguments" enabled="true">
          <collectionProp name="Arguments.arguments">
            <elementProp name="influxdbMetricsSender" elementType="Argument">
              <stringProp name="Argument.name">influxdbMetricsSender</stringProp>
              <stringProp name="Argument.value">org.apache.jmeter.visualizers.backend.influxdb.HttpMetricsSender</stringProp>
              <stringProp name="Argument.metadata">=</stringProp>
            </elementProp>
            <elementProp name="influxdbUrl" elementType="Argument">
              <stringProp name="Argument.name">influxdbUrl</stringProp>
              <stringProp name="Argument.value">#{params[:db_url]}</stringProp>
              <stringProp name="Argument.metadata">=</stringProp>
            </elementProp>
            <elementProp name="application" elementType="Argument">
              <stringProp name="Argument.name">application</stringProp>
              <stringProp name="Argument.value">#{params[:application_name]}</stringProp>
              <stringProp name="Argument.metadata">=</stringProp>
            </elementProp>
            <elementProp name="measurement" elementType="Argument">
              <stringProp name="Argument.name">measurement</stringProp>
              <stringProp name="Argument.value">#{params[:measurements]}</stringProp>
              <stringProp name="Argument.metadata">=</stringProp>
            </elementProp>
            <elementProp name="summaryOnly" elementType="Argument">
              <stringProp name="Argument.name">summaryOnly</stringProp>
              <stringProp name="Argument.value">true</stringProp>
              <stringProp name="Argument.metadata">=</stringProp>
            </elementProp>
             <elementProp name="samplersRegex" elementType="Argument">
              <stringProp name="Argument.name">samplersRegex</stringProp>
              <stringProp name="Argument.value">.*</stringProp>
              <stringProp name="Argument.metadata">=</stringProp>
            </elementProp>
            <elementProp name="testTitle" elementType="Argument">
              <stringProp name="Argument.name">testTitle</stringProp>
              <stringProp name="Argument.value">#{params[:test_title]}</stringProp>
              <stringProp name="Argument.metadata">=</stringProp>
            </elementProp>
            <elementProp name="percentiles" elementType="Argument">
              <stringProp name="Argument.name">percentiles</stringProp>
              <stringProp name="Argument.value">90;95;99</stringProp>
              <stringProp name="Argument.metadata">=</stringProp>
            </elementProp>
          </collectionProp>
        </elementProp>
        <stringProp name="classname">org.apache.jmeter.visualizers.backend.influxdb.InfluxdbBackendListenerClient</stringProp>
      </BackendListener>)
      EOS
      update params
      update_at_xpath params if params.is_a?(Hash) && params[:update_at_xpath]
    end
  end

  class ResponseAssertion
    attr_accessor :doc
    include Helper

    def initialize(params={})
      testname = params.kind_of?(Array) ? 'ResponseAssertion' : (params[:name] || 'ResponseAssertion')
      @doc = Nokogiri::XML(<<-EOS.strip_heredoc)
          <ResponseAssertion guiclass="AssertionGui" testclass="ResponseAssertion" testname="#{testname}" enabled="true">
            <collectionProp name="Asserion.test_strings">
              <stringProp name="49586">200</stringProp>
              <stringProp name="50549">302</stringProp>
            </collectionProp>
            <stringProp name="Assertion.test_field">Assertion.response_code</stringProp>
            <boolProp name="Assertion.assume_success">false</boolProp>
            <intProp name="Assertion.test_type">34</intProp>
            <stringProp name="Assertion.scope">all</stringProp>
            <stringProp name="Assertion.custom_message"></stringProp>
          </ResponseAssertion>)
      EOS
      update params
      update_at_xpath params if params.is_a?(Hash) && params[:update_at_xpath]
    end
  end


  class ExtendedDSL < DSL
    def backend_listener(*args, &block)
      params = args.shift || {}
      node = RubyJmeter::BackendListener.new(params)
      attach_node(node, &block)
    end

    def response_assertion(*args, &block)
      params = args.shift || {}
      node = RubyJmeter::ResponseAssertion.new(params)
      attach_node(node, &block)
    end
  end
end

class ScenarioLoader

  def initialize
    @thread_groups = []
  end

  def run(file_name)
    parse_file(file_name)
    create_execute_test_plan
  end

  def run_all
    parse_dir
    create_execute_test_plan
  end

  private
  def create_execute_test_plan
    @thread_groups.each do |thread_group|
      thread_group.scenarios.each do |scenario|
        test do
          constant_throughput_timer value: Config::Setup.throughput_per_minute, calcMode: 4
          threads count: thread_group.thread_users, rampup: thread_group.ramp_up_period, loop: thread_group.loop_count do
            Once do
              auth url: '/', username: Config::Server.site_username , password: Config::Server.site_password
            end
            visit method: scenario.request.method, always_encode: 'true' , name: scenario.name, url: scenario.request.path do
              response_assertion
            end
          end
          backend_listener db_url: Config::Setup.influxdb_url,
                           application_name: Config::Setup.environment,
                           measurements: "#{scenario.name}",
                           test_title: "#{thread_group.name}"
          reports_dir = "reports/#{scenario.name}"
          FileUtils.mkdir_p reports_dir
        end.run(file: "reports/#{scenario.name}/jmeter.jmx",
                log: "reports/#{scenario.name}/jmeter.log",
                jtl: "reports/#{scenario.name}/jmeter.jtl")
      end
    end
  end

  def parse_dir
    Dir.foreach("./scenarios") do |file|
      next if file == '.' or file == '..'
      parse_file("#{file}")
    end
  end

  def parse_file(file)
    filename = file.split('.')[0]

    thread_group = ThreadGroupUser.new({'name' => filename,
                                        'thread_users' => Config::Setup.thread_count,
                                        'ramp_up_period' => Config::Setup.users_rampup_time,
                                        'loop_count' => Config::Setup.loop_count})
    scenario_file = File.read("./scenarios/#{file}")
    scenario_params = JSON.parse(scenario_file)
    scenario_params["scenarios"].each do|k,v|
      thread_group.add_scenario(Scenario.new(v))
    end
    @thread_groups << thread_group
  end

end