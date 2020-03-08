local pb_helper = require("PB.pb_helper")
local NotifyMoneyChange = require("Event.NotifyMoneyChange")
local ECGame = require("Main.ECGame")
local function on_get_midas_info(sender, msg)
  local pack = ECGame.Instance().m_HostPlayer.Package.NormalPack
  pack.Money = LuaUInt64.ToDouble(msg.midas_total_amount) or 0
  pack.DimaondTotal = LuaUInt64.ToDouble(msg.midas_total_amount) or 0
  pack.BindDimaond = LuaUInt64.ToDouble(msg.midas_bind_amount) or 0
  local p = NotifyMoneyChange()
  ECGame.EventManager:raiseEvent(nil, p)
end
pb_helper.AddHandler("npt_send_client_midas_info", on_get_midas_info)
