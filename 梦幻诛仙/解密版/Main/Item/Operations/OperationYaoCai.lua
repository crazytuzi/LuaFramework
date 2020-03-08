local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OperationYaoCai = Lplus.Extend(OperationBase, "OperationYaoCai")
local def = OperationYaoCai.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.DRUG_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local LivingSkillUtility = require("Main.Skill.LivingSkillUtility")
  local livingSkillData = require("Main.Skill.data.LivingSkillData").Instance()
  local LifeSkillBagShowTypeEnum = require("consts.mzm.gsp.skill.confbean.LifeSkillBagShowTypeEnum")
  local skillBag = livingSkillData:GetSkillBagByType(LifeSkillBagShowTypeEnum.type3)
  local skillTbl = livingSkillData:GetUnLockSkill(skillBag.id)
  if 0 == #skillTbl then
    local minUnlockLevel = livingSkillData:GetSkillMinUnlockLevel(skillBag.id)
    Toast(string.format(textRes.Skill[73], minUnlockLevel))
    return false
  end
  local costVigor = LivingSkillUtility.GetCostVigor(skillBag.id, skillBag.level)
  require("Main.Skill.ui.MakeMedicine").ShowMakeMedicinePanel(nil, nil, costVigor, skillBag.id)
  return true
end
OperationYaoCai.Commit()
return OperationYaoCai
