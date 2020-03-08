local _FlashTip = function(tip, category, duration)
  tip = tip or "FlashTip"
  duration = duration or 3
  category = category or ""
  local ECFlashTipMan = require("GUI.FlashTipMan")
  ECFlashTipMan.FlashTip(duration, tip, category)
end
local _ResetFlashTipCache = function()
  local ECFlashTipMan = require("GUI.FlashTipMan")
  ECFlashTipMan.ResetFlashTipCache()
end
_G.FlashTipMan = {FlashTip = _FlashTip, ResetFlashTipCache = _ResetFlashTipCache}
return FlashTipMan
