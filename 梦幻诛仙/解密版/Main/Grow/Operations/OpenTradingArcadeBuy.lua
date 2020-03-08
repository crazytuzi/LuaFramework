local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenTradingArcadeBuy = Lplus.Extend(Operation, CUR_CLASS_NAME)
local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
local def = OpenTradingArcadeBuy.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  if TradingArcadeUtils.CheckOpen() == false then
    return false
  end
  local CommercePitchModule = require("Main.CommerceAndPitch.CommercePitchModule")
  local CommercePitchPanel = require("Main.CommerceAndPitch.ui.CommercePitchPanel")
  local nodeId = CommercePitchPanel.StateConst.TradingArcade
  CommercePitchModule.Instance().afterShowCallback = function(...)
  end
  CommercePitchModule.RequireToShowPanel(nodeId)
  CommercePitchModule.Instance().waitToShowState = nodeId
  return false
end
return OpenTradingArcadeBuy.Commit()
