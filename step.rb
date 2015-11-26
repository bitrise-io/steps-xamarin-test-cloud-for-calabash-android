require 'optparse'
require_relative 'utils/logger'

# -----------------------
# --- functions
# -----------------------

def to_bool(value)
  return true if value == true || value =~ (/^(true|t|yes|y|1)$/i)
  return false if value == false || value.nil? || value =~ (/^(false|f|no|n|0)$/i)
  fail_with_message("Invalid value for Boolean: \"#{value}\"")
end

# -----------------------
# --- main
# -----------------------

#
# Input validation
options = {
  features: nil,
  apk_path: nil,
  dsym_path: nil,
  api_key: nil,
  user: nil,
  devices: nil,
  async: true,
  series: 'master',
  other_parameters: nil
}

parser = OptionParser.new do|opts|
  opts.banner = 'Usage: step.rb [options]'
  opts.on('-a', '--feautes calabash', 'Calabash features') { |a| options[:features] = a unless a.to_s == '' }
  opts.on('-c', '--api key', 'API key') { |c| options[:api_key] = c unless c.to_s == '' }
  opts.on('-b', '--user user', 'User') { |b| options[:user] = b unless b.to_s == '' }
  opts.on('-d', '--devices devices', 'Devices') { |d| options[:devices] = d unless d.to_s == '' }
  opts.on('-e', '--async async', 'Async') { |e| options[:async] = false if to_bool(e) == false }
  opts.on('-f', '--series series', 'Series') { |f| options[:series] = f unless f.to_s == '' }
  opts.on('-g', '--other parameters', 'Other') { |g| options[:other_parameters] = g unless g.to_s == '' }
  opts.on('-i', '--apk path', 'APK') { |i| options[:apk_path] = i unless i.to_s == '' }
  opts.on('-h', '--help', 'Displays Help') do
    exit
  end
end
parser.parse!

fail_with_message('No features folder found') unless options[:features] && File.exist?(options[:features])
fail_with_message('No apk found') unless options[:apk_path] && File.exist?(options[:apk_path])
fail_with_message('api_key not specified') unless options[:api_key]
fail_with_message('user not specified') unless options[:user]
fail_with_message('devices not specified') unless options[:devices]

#
# Print configs
puts
puts '========== Configs =========='
puts " * features: #{options[:features]}"
puts " * apk_path: #{options[:apk_path]}"
puts " * dsym_path: #{options[:dsym_path]}"
puts ' * api_key: ***'
puts " * user: #{options[:user]}"
puts " * devices: #{options[:devices]}"
puts " * async: #{options[:async]}"
puts " * series: #{options[:series]}"
puts " * other_parameters: #{options[:other_parameters]}"

#
# Build Request
request = "test-cloud submit #{options[:apk_path]} #{options[:api_key]}"
request += " --user #{options[:user]}"
request += " --devices #{options[:devices]}"
request += ' --async' if options[:async]
request += " --series #{options[:series]}" if options[:series]
request += " #{options[:other_parameters]}" if options[:other_parameters]

puts
puts "request: #{request}"

base_directory = File.dirname(options[:features])
Dir.chdir(base_directory) do
  puts
  puts "calabash-android resign #{options[:apk_path]} -v"
  system("calabash-android resign #{options[:apk_path]} -v")

  puts
  puts "calabash-android build #{options[:apk_path]}"
  system("calabash-android build #{options[:apk_path]}")

  system(request)
  fail_with_message('test-cloud -- failed') unless $?.success?
end

puts
puts '(i) The result is: succeeded'
system('envman add --key BITRISE_XAMARIN_TEST_RESULT --value succeeded')
