local Lplus = require("Lplus")
local MultiXmlHelper = Lplus.Class("MultiXmlHelper")
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local def = MultiXmlHelper.define
def.const("number").NOT_FOUND = -1
def.const("number").NOT_OPEN = -2
def.static("=>", "boolean").IsOpen = function()
  local isOpen = FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_MULTI_XML)
  return isOpen
end
def.static("=>", "number").GetXmlDataType = function()
  if not MultiXmlHelper.IsOpen() then
    return MultiXmlHelper.NOT_OPEN
  end
  local zoneid = gmodule.network.m_mainZoneId
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MULTI_XML_CFG, zoneid)
  if record == nil then
    return MultiXmlHelper.NOT_FOUND
  end
  local xmlDataType = record:GetIntValue("xml_data_type")
  return xmlDataType
end
return MultiXmlHelper.Commit()
