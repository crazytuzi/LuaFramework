local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenCommercePanel = Lplus.Extend(Operation, CUR_CLASS_NAME)
local CommercePitchModule = require("Main.CommerceAndPitch.CommercePitchModule")
local CommercePitchPanel = require("Main.CommerceAndPitch.ui.CommercePitchPanel")
local CommerceData = require("Main.CommerceAndPitch.data.CommerceData")
local MallPanel = require("Main.Mall.ui.MallPanel")
local def = OpenCommercePanel.define
def.field("number").state = MallPanel.StateConst.Commerce
def.override("table", "=>", "boolean").Operate = function(self, params)
  local itemId = tonumber(params[1])
  if itemId then
    local bigIndex, smallIndex = CommerceData.Instance():GetGroupInfoByItemId(itemId)
    CommercePitchModule.Instance():ComemrceBuyItemByBigSmallIndex(bigIndex, smallIndex, itemId)
  else
    CommercePitchModule.RequireToShowPanel(self.state)
    CommercePitchModule.Instance().waitToShowState = MallPanel.StateConst.Commerce
  end
  return false
end
return OpenCommercePanel.Commit()
