require './lib/config/setup'
require './lib/scenario_loader'

namespace :performance do
  loader = ScenarioLoader.new

  task :clean_up do
    puts "Cleaning up reports....."
    rm_rf('./reports')
  end

  desc "To execute single tests pass the test file name within square brackets Eg: rake performance:test[project_summary.json]"
  task :test, [:spec_name] => :clean_up do |task, args|
    loader.run args[:spec_name]
  end

  desc "To execute all the tests pass the folder name within square brackets Eg: rake performance:test_all"
  task :test_all => :clean_up do
    loader.run_all
  end
end