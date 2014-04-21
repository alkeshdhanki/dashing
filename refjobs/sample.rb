#require 'dotenv'
#Dotenv.load

SCHEDULER.every '20s', :first_in => 0 do |job|
puts "Hi"
puts "http_proxy" + ENV['http_proxy']
puts "Env USer:" + ENV['User']
puts "Env App" + ENV['App']
end





#current_valuation = 0
#current_karma = 0

#SCHEDULER.every '20s' do
  #last_valuation = current_valuation
  #last_karma     = current_karma
  #current_valuation = rand(100)
  #current_karma     = rand(200000)

  #send_event('valuation', { current: current_valuation })
  #send_event('karma', { current: current_karma, last: last_karma })
  #send_event('synergy',   { value: rand(100) })
#end