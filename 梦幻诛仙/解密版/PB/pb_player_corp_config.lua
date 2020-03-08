local Lplus = require("Lplus")
local pb_helper = require("PB.pb_helper")
local net_common = require("PB.net_common")
local ECGame = require("Main.ECGame")
local NotifyFaction = require("Event.NotifyFaction")
local function on_gp_player_corp_config(sender, msg)
  local config = msg.config
  local faction = ECGame.Instance().m_HostPlayer.Faction
  faction._activefactionskill = config.active_level * 5 + config.active_index
  ECGame.EventManager:raiseEvent(nil, NotifyFaction.NotifyFactionInfo())
end
pb_helper.AddHandler("gp_player_corp_config", on_gp_player_corp_config)
