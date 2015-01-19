class Animation
  @max_hue = 65535

  def self.list_all
    [
      "slow_shift",
      "random"
    ]
  end

  def self.slow_shift
    CLIENT.lights.each do |light|
      light.set_state(:hue => (light.hue + 500))
    end
    sleep 1
  end

  def self.random
    LIGHTS.each {|light| light.set_state(:hue => rand(30000...@max_hue))}
    sleep 1
  end

end
