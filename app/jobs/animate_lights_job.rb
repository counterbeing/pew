class AnimateLightsJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    starting_length = Delayed::Job.all.length
    while starting_length == Delayed::Job.all.length do 
      LIGHTS.each {|light| light.set_state(:hue => rand(0...65535))}
      Delayed::Job.last
      sleep 1
    end
  end
end
