local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local OperationBase = import(".OperationBase")
local RememberSkill = Lplus.Extend(OperationBase, CUR_CLASS_NAME)
local def = RememberSkill.define
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
  if context.pet.rememberedSkillId == context.skill.id then
    return false
  end
  return true
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Pet[108]
end
def.override("table", "=>", "boolean").Operate = function(self, context)
  local petId, skillId = context.pet.id, context.skill.id
  local PetMgr = require("Main.Pet.mgr.PetMgr")
  local PetUtility = require("Main.Pet.PetUtility")
  local pet = PetMgr.Instance():GetPet(petId)
  if pet:HasRememberdSkill() then
    local title = textRes.Pet[121]
    local coloredPetName = PetUtility.GetColoredPetNameBBCode(pet)
    local cRememberedSkillName = PetUtility.GetColoredSkillNameBBCode(pet.rememberedSkillId)
    local cSkillName = PetUtility.GetColoredSkillNameBBCode(skillId)
    local askStr = string.format(textRes.Pet[120], coloredPetName, cRememberedSkillName, cSkillName)
    require("GUI.CommonConfirmDlg").ShowConfirm(title, askStr, function(selection, tag)
      if selection == 1 then
        self:RememberSkill(context)
      end
    end, nil)
    return true
  else
    return self:RememberSkill(context)
  end
end
def.method("table", "=>", "boolean").RememberSkill = function(self, context)
  local petId, skillId = context.pet.id, context.skill.id
  local itemType = require("consts.mzm.gsp.item.confbean.ItemType").PET_REMEBER_SKILL_ITEM
  local ItemModule = require("Main.Item.ItemModule")
  local PetUtility = require("Main.Pet.PetUtility")
  local PetMgr = require("Main.Pet.mgr.PetMgr")
  local itemId = PetUtility.Instance():GetPetConstants("PET_REMEBER_SKILL_ITEM_ID")
  local items = ItemModule.Instance():GetItemsByItemType(ItemModule.BAG, itemType)
  local count = 0
  for k, v in pairs(items) do
    count = count + v.number
  end
  local itemNum = count
  local consumeItemNum = require("Main.Pet.PetModule").PET_REMEMBER_SKILL_USE_ITEM_NUM
  local pet = PetMgr.Instance():GetPet(petId)
  local coloredPetName = PetUtility.GetColoredPetNameBBCode(pet)
  local coloredskillName = PetUtility.GetColoredSkillNameBBCode(skillId)
  local desc = string.format(textRes.Pet[118], coloredPetName, coloredskillName)
  local title, extendItemId, itemNeed = textRes.Pet[117], itemId, consumeItemNum
  local ItemConsumeHelper = require("Main.Item.ItemConsumeHelper")
  ItemConsumeHelper.Instance():ShowItemConsume(title, desc, extendItemId, itemNeed, function(select)
    local function RememberSkill(extraParams)
      if pet:HasRememberdSkill() then
        local context = {
          pet = pet,
          skill = {
            id = pet.rememberedSkillId,
            isOwnSkill = true
          },
          needRemember = true,
          needConfirm = false
        }
        require("Main.Skill.operations.UnrememberSkill")():Operate(context)
      end
      gmodule.moduleMgr:GetModule(ModuleId.PET):RememberSkill(petId, skillId, extraParams)
    end
    if select < 0 then
    elseif select == 0 then
      RememberSkill({isYuanBaoBuZu = false})
    else
      RememberSkill({isYuanBaoBuZu = true})
    end
  end)
  return true
end
RememberSkill.Commit()
return RememberSkill
