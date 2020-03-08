local Lplus = require("Lplus")
local pb_helper = require("PB.pb_helper")
local ECGame = require("Main.ECGame")
local function on_get_player_profile(sender, msg)
  local ECPlayerProfileCache = require("Main.ECPlayerProfileCache")
  ECPlayerProfileCache.Instance():Respond(msg, msg.get_profile_mask)
  local OtherPlayerInfo = require("Event.OtherPlayerInfo")
  local p = OtherPlayerInfo()
  p.msg = msg
  ECGame.EventManager:raiseEvent(nil, p)
end
pb_helper.AddHandler("npt_get_player_profile", on_get_player_profile)
