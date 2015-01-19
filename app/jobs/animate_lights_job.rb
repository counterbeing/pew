class AnimateLightsJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    starting_length = Delayed::Job.all.length
    while starting_length == Delayed::Job.all.length do 
      Animation.send(args[0])
    end
  end
end
