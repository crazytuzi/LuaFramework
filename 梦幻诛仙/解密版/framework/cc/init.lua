local CURRENT_MODULE_NAME = (...)
cc.Registry = import(".Registry")
cc.GameObject = import(".GameObject")
cc.EventProxy = import(".EventProxy")
local components = {
  "components.behavior.StateMachine",
  "components.behavior.EventProtocol",
  "components.ui.BasicLayoutProtocol",
  "components.ui.LayoutProtocol"
}
for _, packageName in ipairs(components) do
  cc.Registry.add(import("." .. packageName, CURRENT_MODULE_NAME), packageName)
end
local GameObject = cc.GameObject
local ccmt = {}
function ccmt:__call(target)
  if target then
    return GameObject.extend(target)
  end
  printError("cc() - invalid target")
end
setmetatable(cc, ccmt)
cc.mvc = import(".mvc.init")
cc.ui = import(".ui.init")
cc.ad = import(".ad.init").new()
cc.push = import(".push.init").new()
cc.analytics = import(".analytics.init").new()
cc.share = import(".share.init").new()
cc.feedback = import(".feedback.init").new()
cc.update = import(".update.init").new()
