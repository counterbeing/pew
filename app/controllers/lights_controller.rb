class LightsController < ApplicationController
  def index 
    @animations = Animation.list_all
    @lights = LIGHTS
    Hue::Light.start_anim_thread
  end

  def lights_on
    get_desired_lights
    @lights.each do |light| 
      light.on!
      light.set_state(:hue => 30000)
    end
    redirect_to '/'
  end

  def lights_off
    get_desired_lights
    @lights.each { |light| light.off! }
    redirect_to '/'
  end

  def lights_random
    get_desired_lights
    @lights.each { |light| light.random! }
    redirect_to '/'
  end

  def lights_off_animation
    get_desired_lights
    @lights.each { |light| light.off_anim! }
    redirect_to '/'
  end

  def lights_pause_unpause
    Hue::Light.pause_anim
    redirect_to '/'
  end

  def animate
    animation_name = params[:animation]
    AnimateLightsJob.perform_later animation_name
    redirect_to '/'
  end

  private

  def stop_animation
    StopAnimationsJob.perform_later
  end

  def ids_to_lights(ids)
    ids = [ids] unless ids.class == Array
    ids.collect { |id| CLIENT.light(id) }
  end
  
  def get_desired_lights
    desired_ids = params[:desired_ids]
    if desired_ids.present?
      desired_ids = desired_ids.split(',')
      @lights = ids_to_lights(desired_ids)
    else
      stop_animation
      @lights = LIGHTS
    end
  end

end

class Hue::Light
  $Max_hue = 65535
  @@Max_range = 0...@@Max_hue
  @@FPS = 25 #Animations executed every 1000/@@FPS ms
  @@anim_paused = false

  @anim_delay = 0
  @last_anim_frame = 0
  @anim_type = nil
  @color_range = @@Max_range

  def self.start_anim_thread
    Thread.new {
      while true do
        LIGHTS.each do |light|
          light.next_anim_frame unless @@anim_paused
        end
        sleep 1.0 / @@FPS
      end
    }
  end

  def self.pause_anim
    @@anim_paused = !@@anim_paused
  end

  def random!(delay = 1, range = @@Max_range) #Specify delay in ms or use default
    @anim_type = "random"
    @anim_delay = delay
    @color_range = range
    @last_anim_frame = Time.now
  end

  def off_anim!
    @anim_type = nil
  end

  def next_anim_frame
    case @anim_type
    when "random"
      if Time.now - @last_anim_frame > @anim_delay
        set_state(:hue => rand(@color_range))
        @last_anim_frame = Time.now
      end
    end
  end
end
