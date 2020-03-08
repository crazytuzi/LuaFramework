local Lplus = require("Lplus")
local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
local WingsSkillData = require("Main.Wings.data.WingsSkillData")
local WingsPropData = require("Main.Wings.data.WingsPropData")
local WingsViewData = require("Main.Wings.data.WingsViewData")
local WingsData = Lplus.Class("WingsData")
local def = WingsData.define
def.field("number").schemaId = 0
def.field("number").exp = 0
def.field("number").level = 0
def.field("number").phase = 0
def.field("table").skillList = nil
def.field("table").propList = nil
def.field(WingsViewData).curWingsView = nil
def.method("table", "number").RawSet = function(self, data, schemaId)
  self.schemaId = schemaId
  self.exp = data.exp
  self.level = data.level
  self.phase = data.phase
  self.curWingsView = WingsViewData()
  self.curWingsView:RawSet(data.modelId2dyeid)
  self.propList = {}
  for i = 1, #data.propertyList do
    local propData = WingsPropData()
    propData:RawSet(data.propertyList[i])
    table.insert(self.propList, propData)
  end
  self.skillList = {}
  for i = 1, #data.skillList do
    local skillData = WingsSkillData()
    skillData:RawSet(data.skillList[i])
    table.insert(self.skillList, skillData)
  end
end
return WingsData.Commit()
