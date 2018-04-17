require './lib/scenario_request'

class Scenario
  attr_reader :request, :name
  def initialize(params)
    @name = params['name']
    @request = ScenarioRequest.new(params)
  end
end