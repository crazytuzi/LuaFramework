local Lplus = require("Lplus")
local pb_helper = require("PB.pb_helper")
local ECGame = require("Main.ECGame")
local function on_combine_respond(sender, msg)
  print("on_combine_respond", msg.stamp, msg.result, type(msg))
  local CombineUpdateEvent = require("Event.CombineUpdateEvent")
  local p = CombineUpdateEvent()
  p.msg = msg
  ECGame.EventManager:raiseEvent(nil, p)
end
pb_helper.AddHandler("gp_item_combine_result", on_combine_respond)
