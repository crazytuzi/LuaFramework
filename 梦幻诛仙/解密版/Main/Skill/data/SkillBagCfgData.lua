local Lplus = require("Lplus")
local SkillBagCfgData = Lplus.Class("SkillBagCfgData")
local def = SkillBagCfgData.define
local NOT_SET = -1
def.field("number").id = NOT_SET
def.field("number").iconId = NOT_SET
def.field("string").name = ""
def.field("string").description = ""
def.field("string").propText = ""
def.field("number").levelUpCfgId = NOT_SET
def.field("table").skillList = nil
local SkillBagSkillData = Lplus.Class("SkillBagSkillData")
do
  local def = SkillBagSkillData.define
  def.field("number").id = NOT_SET
  def.field("number").unlockLevel = NOT_SET
  def.static("=>", SkillBagSkillData).New = function()
    local obj = SkillBagSkillData()
    return obj
  end
  SkillBagSkillData.Commit()
end
def.const("table").SkillData = SkillBagSkillData
def.static("=>", SkillBagCfgData).New = function()
  local obj = SkillBagCfgData()
  obj:_Init()
  return obj
end
def.method()._Init = function(self)
  self.skillList = {}
end
return SkillBagCfgData.Commit()
