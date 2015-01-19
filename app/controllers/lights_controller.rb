class LightsController < ApplicationController
  def index 
    @lights = LIGHTS
  end

  def lights_on
    get_desired_lights
    @lights.each do |light|
      light.on!
    end
    redirect_to '/'
  end

  def lights_off
    get_desired_lights
    @lights.each do |light|
      light.off!
    end
    redirect_to '/'
  end

  def animate
    AnimateLightsJob.perform_later
    redirect_to '/'
  end


  private

  def stop_animation
    StopAnimationsJob.perform_later
  end

  def ids_to_lights(ids)
    if ids.class != Array
      ids = [ids]
    end
    lights = []
    ids.each do |id|
      lights << CLIENT.light(id)
    end
    return lights
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
