local Lplus = require("Lplus")
local net_common = require("PB.net_common")
local pb_helper = require("PB.pb_helper")
local ECGame = require("Main.ECGame")
local function on_gp_ipt_container(sender, msg)
  local hp = ECGame.Instance().m_HostPlayer
  local ID = hp.ID
  local faction = hp.Faction
  if ID == msg.corps_info.roleid then
    local oldValue = faction._factionmoney
    local newValue = tonumber(LuaUInt64.ToString(msg.corps_info.money))
    if oldValue < newValue then
      FlashTipMan.FlashTip(StringTable.Get(2123):format(newValue - oldValue))
    end
    oldValue = faction._factioncontribution
    newValue = tonumber(LuaUInt64.ToString(msg.corps_info.contribution))
    if oldValue < newValue then
      FlashTipMan.FlashTip(StringTable.Get(2124):format(newValue - oldValue))
    end
  end
end
pb_helper.AddHandler("gp_ipt_container", on_gp_ipt_container)
