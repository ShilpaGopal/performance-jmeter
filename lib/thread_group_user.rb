class ThreadGroupUser
  attr_reader :scenarios, :name, :thread_users, :ramp_up_period, :loop_count

  def initialize(params={})
    @name = params['name']
    @thread_users = params['thread_users']
    @ramp_up_period = params['ramp_up_period']
    @loop_count = params['loop_count']
    @forever = params['loop_count'] ? false: true
    @scenarios = []
  end

  def add_scenario(scenario)
    @scenarios << scenario
  end
end