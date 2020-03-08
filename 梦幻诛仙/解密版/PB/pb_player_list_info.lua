local Lplus = require("Lplus")
local pb_helper = require("PB.pb_helper")
local on_player_list_info = function(sender, msg)
  print("on_player_list_info", msg)
  local ECPlayerProfileCache = require("Main.ECPlayerProfileCache")
  ECPlayerProfileCache.Instance():RespondFightCapacity(msg)
  local PlayerListInfoEvt = require("Event.PlayerListInfoEvt")
  local ECGame = require("Main.ECGame")
  local p = PlayerListInfoEvt.new()
  p.msg = msg
  ECGame.EventManager:raiseEvent(nil, p)
end
pb_helper.AddHandler("gp_player_list_info", on_player_list_info)
