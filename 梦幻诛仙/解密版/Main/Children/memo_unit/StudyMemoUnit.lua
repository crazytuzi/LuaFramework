local MODULE_NAME = (...)
local Lplus = require("Lplus")
local BaseMemoUnit = import(".BaseMemoUnit")
local StudyMemoUnit = Lplus.Extend(BaseMemoUnit, MODULE_NAME)
local GrowthSubType = require("netio.protocol.mzm.gsp.children.GrowthSubType")
local ChildrenUtils = require("Main.Children.ChildrenUtils")
local def = StudyMemoUnit.define
local PropertyColor = {positive = "009a01", negative = "ff0f0f"}
def.field("number").m_courseType = 0
def.field("boolean").m_isCrit = false
def.override("number", "userdata", "table").Init = function(self, type, occurtime, params)
  BaseMemoUnit.Init(self, type, occurtime, params)
  self.m_courseType = self.m_intParams[GrowthSubType.COURSE_TYPE] or self.m_courseType
  self.m_isCrit = self.m_intParams[GrowthSubType.IS_CRIT] == 1 and true or false
end
def.override("=>", "string").GetFormattedText = function(self)
  local courseCfg = ChildrenUtils.GetCourseCfg(self.m_courseType)
  if courseCfg == nil then
    return "GetFormattedTextError: see details above"
  end
  local props = {}
  local critValue
  for i, v in ipairs(courseCfg.props) do
    critValue = 0
    if self.m_isCrit then
      critValue = v.critValue
    end
    table.insert(props, {
      prop = v.prop,
      value = v.value,
      critValue = critValue
    })
  end
  local strTable = {}
  local operateName = courseCfg.name
  table.insert(strTable, operateName)
  table.insert(strTable, BaseMemoUnit.SYMBOL_DELIMITER)
  local result = ChildrenUtils.PropsToStringV2(props, BaseMemoUnit.SYMBOL_DELIMITER)
  table.insert(strTable, result)
  return table.concat(strTable)
end
return StudyMemoUnit.Commit()
