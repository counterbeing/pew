class Animation
  @max_hue = 65535
  @@hue    = 0

  def self.list_all
    [
      "slow_shift",
      "random"
    ]
  end

  def self.slow_shift
    Animation.increment_hue(5000)
    CLIENT.lights.each do |light|
      light.set_state(:hue => (@@hue))
    end
    sleep 1
  end

  def self.random
    LIGHTS.each {|light| light.set_state(:hue => rand(30000...@max_hue))}
    sleep 1
  end

  def self.increment_hue(increment=5000)
    if @@hue > (@max_hue - increment)
      @@hue = ((@@hue + increment) - @max_hue).abs
    else
      @@hue = @@hue + increment
    end
  end
end
