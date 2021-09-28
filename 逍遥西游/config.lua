DEBUG = 1
DEBUG_FPS = false
DEBUG_MEM = false
CONFIG_SCREEN_WIDTH = 960
CONFIG_SCREEN_HEIGHT = 640
function CONFIG_SCREEN_AUTOSCALE_CALLBACK(pixelW, pixelH, model)
  local sx = CONFIG_SCREEN_WIDTH / pixelW
  local sy = CONFIG_SCREEN_HEIGHT / pixelH
  local realX, realY, s
  if sx <= sy then
    CONFIG_SCREEN_AUTOSCALE = "FIXED_HEIGHT"
    s = sy
    realY = CONFIG_SCREEN_HEIGHT
    realX = pixelH * realY / pixelW
  else
    CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH"
    s = sx
    realX = CONFIG_SCREEN_WIDTH
    realY = pixelW * realX / pixelH
  end
  print("==>> sx, sy:", sx, sy, CONFIG_SCREEN_AUTOSCALE)
  return pixelW / realX, pixelH / realY
end
