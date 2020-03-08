local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local OperationBase = import(".OperationBase")
local UnrememberSkill = Lplus.Extend(OperationBase, CUR_CLASS_NAME)
local def = UnrememberSkill.define
def.override("table", "=>", "boolean").CanDispaly = function(self, context)
  if context == nil or not context.needRemember then
    return false
  end
  if not context.skill or not context.pet then
    return false
  end
  if not context.skill.isOwnSkill then
    return false
  end
  if context.pet.rememberedSkillId ~= context.skill.id then
    return false
  end
  return true
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Pet[109]
end
def.override("table", "=>", "boolean").Operate = function(self, context)
  local PetSkillMgr = require("Main.Pet.mgr.PetSkillMgr")
  local ItemModule = require("Main.Item.ItemModule")
  local cost = PetSkillMgr.Instance():GetUnrememberSkillCost()
  local moneySilver = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER) or Int64.new(0)
  if moneySilver:lt(cost.silver) then
    local PersonalHelper = require("Main.Chat.PersonalHelper")
    local silverText = PersonalHelper.ToString(PersonalHelper.Type.Silver, cost.silver)
    Toast(string.format(textRes.Pet[115], silverText))
    return true
  end
  local PetMgr = require("Main.Pet.mgr.PetMgr")
  local PetUtility = require("Main.Pet.PetUtility")
  local petId, skillId = context.pet.id, context.skill.id
  local pet = PetMgr.Instance():GetPet(petId)
  local cRememberedSkillName = PetUtility.GetColoredSkillNameBBCode(pet.rememberedSkillId)
  local function unremember()
    gmodule.moduleMgr:GetModule(ModuleId.PET):UnrememberSkill(petId, skillId)
  end
  if context.needConfirm ~= false then
    local title = textRes.Pet[127]
    local askStr = string.format(textRes.Pet[119], cRememberedSkillName)
    require("GUI.CommonConfirmDlg").ShowConfirm(title, askStr, function(selection, tag)
      if selection == 1 then
        unremember()
      end
    end, nil)
  else
    unremember()
  end
  return true
end
UnrememberSkill.Commit()
return UnrememberSkill
