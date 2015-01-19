class StopAnimationsJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    # Does nothing
    # It adds another job to the queue that other jobs
    # look for to know when to stop.
  end
end
