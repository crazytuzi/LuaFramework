local MainScene = class("MainScene", function()
  return display.newScene("MainScene")
end)
local getScoreByNumber = function(number)
  local n = math.log(number / 3) / math.log(2) + 1
  return checkint(3 ^ n)
end
function MainScene:ctor()
  require("testScripts/testShape")
  testShape(self)
end
function MainScene:onEnter()
  if device.platform == "android" then
    self:performWithDelay(function()
      local layer = Pannel.create()
      layer:addKeypadEventListener(function(event)
        if event == "back" then
          app.exit()
        end
      end)
      self:addChild(layer)
      layer:setKeypadEnabled(true)
    end, 0.5)
  end
end
function MainScene:onExit()
end
return MainScene
