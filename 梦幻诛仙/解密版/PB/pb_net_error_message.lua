local Lplus = require("Lplus")
local pb_helper = require("PB.pb_helper")
local on_gp_net_error_message = function(sender, msg)
  warn("@@@@@@@@@@@@@\230\156\141\229\138\161\229\153\168\229\143\141\233\166\136\231\154\132\233\148\153\232\175\175\231\160\129", msg.for_ipt_proto_type, msg.error_code)
  local desc = ""
  if msg.error_code == 516 then
    desc = StringTable.Get(7800)
  elseif msg.error_code == 517 then
    desc = StringTable.Get(7801)
  elseif msg.error_code == 617 then
    desc = StringTable.Get(153)
  end
  FlashTipMan.FlashTip(desc)
end
pb_helper.AddHandler("gp_net_error_message", on_gp_net_error_message)
