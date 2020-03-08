local MODULE_NAME = (...)
local Lplus = require("Lplus")
local BaseMemoUnit = import(".BaseMemoUnit")
local ZhuazhouMemoUnit = Lplus.Extend(BaseMemoUnit, MODULE_NAME)
local GrowthSubType = require("netio.protocol.mzm.gsp.children.GrowthSubType")
local ChildrenUtils = require("Main.Children.ChildrenUtils")
local def = ZhuazhouMemoUnit.define
def.field("number").m_zhuazhouCfgId = 0
def.override("number", "userdata", "table").Init = function(self, type, occurtime, params)
  BaseMemoUnit.Init(self, type, occurtime, params)
  self.m_zhuazhouCfgId = self.m_intParams[GrowthSubType.DRAW_LOTS_CFG_ID] or self.m_zhuazhouCfgId
end
def.override("=>", "string").GetFormattedText = function(self)
  local interestCfg = ChildrenUtils.GetInterestCfg(self.m_zhuazhouCfgId)
  if interestCfg == nil then
    return "GetFormattedTextError: see details above"
  end
  local propMap = {}
  for i, v in ipairs(interestCfg.props) do
    propMap[v.prop] = v.value
  end
  local strTable = {}
  table.insert(strTable, textRes.Children[4211])
  table.insert(strTable, BaseMemoUnit.SYMBOL_DELIMITER)
  local result = ChildrenUtils.PropsToString(propMap, BaseMemoUnit.SYMBOL_DELIMITER)
  table.insert(strTable, result)
  return table.concat(strTable)
end
return ZhuazhouMemoUnit.Commit()
