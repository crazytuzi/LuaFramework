local Lplus = require("Lplus")
local pb_helper = require("PB.pb_helper")
local on_search_player = function(sender, msg)
  local ECGame = require("Main.ECGame")
  local NotifySearchPlayer = require("Event.NotifySearchPlayer")
  local p = NotifySearchPlayer.new(msg)
  ECGame.EventManager:raiseEvent(nil, p)
end
pb_helper.AddHandler("npt_common_search", on_search_player)
