local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local PetUIMgr = Lplus.Class("PetUIMgr")
local PetUtility = require("Main.Pet.PetUtility")
local PetMgr = require("Main.Pet.mgr.PetMgr")
local PersonalHelper = require("Main.Chat.PersonalHelper")
local def = PetUIMgr.define
local UISet = {
  PetShopBuy = "PetShopBuyPanel",
  PetShopSell = "PetShopSellPanel",
  PetSupplementLife = "PetSupplementLifePanel"
}
def.const("table").UISet = UISet
def.const("table").UIPath = {
  AddExpBtn = "panel_pet/Img_Bg0/CW/SX/Img_CW_Bg0/Img_CW_BgImage0/Slider_CW_Exp/Btn_CW_Add",
  AddGrowValueBtn = "panel_pet/Img_Bg0/CW/JN/Img_JN_Bg0/Group_Grown/Img_JN_BgGrown/Btn_JN_Add",
  AddLifeBtn = "panel_pet/Img_Bg0/CW/JN/Img_JN_Bg0/Group_Grown/Img_JN_BgAge/Btn_JN_Tips",
  LianGuBtn = "panel_pet/Img_Bg0/CW/JN/Img_JN_Bg0/Btn_JN_Bone",
  LearnSkillBtn = "panel_pet/Img_Bg0/CW/JN/Img_JN_Bg0/Btn_JN_Use",
  FreePetBtn = "panel_pet/Img_Bg0/CW/SX/Btn_Abandon",
  DecorateBtn = "panel_pet/Img_Bg0/CW/ZB/Group_Equip/Btn_CW_Decoration01",
  FanShengBtn = "panel_pet/Img_Bg0/FS/Img_FS_Bg0/Img_FS_Skill/Btn_FS_Use",
  ChangeModelBtn = "panel_pet/Img_Bg0/CW/ZB/Btn_Draw"
}
def.field("string").modulePrefix = ""
local instance
def.static("=>", PetUIMgr).Instance = function()
  if instance == nil then
    instance = PetUIMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self:InitModulePrefix()
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_SHOP_BUY_PET_SUCCESS, PetUIMgr.OnBuyPetSuccess)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_SHOP_SELL_PET_SUCCESS, PetUIMgr.OnSellPetSuccess)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_LEVEL_UP, PetUIMgr.OnPetLevelUp)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_EXP_CHANGED, PetUIMgr.OnPetExpChanged)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_LIFE_ADDED, PetUIMgr.OnPetLifeAdded)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_CHANGE_TO_FIGHTING, PetUIMgr.OnPetChangeToFighting)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_CHANGE_TO_DISPLAY, PetUIMgr.OnPetChangeToDisplay)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_ADDED, PetUIMgr.OnPetAdded)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_LIFE_NEED_SUPPLEMENT, PetUIMgr.OnNeedSupplementPetLife)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_REMEMBERED_SKILL_SUCCESS, PetUIMgr.OnPetRememberedSkillSuccess)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_UNREMEMBERED_SKILL_SUCCESS, PetUIMgr.OnPetUnrememberedSkillSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SUseLifeItemRes", PetUIMgr.OnSUseLifeItemRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SUseGrowItemRes", PetUIMgr.OnSUseGrowItemRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SUsePetBagItemRes", PetUIMgr.OnSUsePetBagItemRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SSyncAddSkill", PetUIMgr.OnSSyncAddSkill)
end
def.method().InitModulePrefix = function(self)
  local sPos, ePos = string.find(MODULE_NAME, ".[%w_]+$")
  self.modulePrefix = string.sub(MODULE_NAME, 1, sPos - 1)
end
def.method("string", "=>", "table").GetUI = function(self, uiName)
  return require(self.modulePrefix .. ".ui." .. uiName)
end
def.static("table", "table").OnBuyPetSuccess = function(params)
end
def.static("table", "table").OnSellPetSuccess = function(params)
  local petCfgId = params.petCfgId
  local addMoney = params.addMoney
  local petCfg = PetUtility.Instance():GetPetCfg(petCfgId)
  local petName = petCfg.templateName
  local addMoneyStr = PersonalHelper.ToString(PersonalHelper.Type.Silver, addMoney)
  local text = string.format(textRes.Pet[79], petName, addMoneyStr)
  PersonalHelper.CommonMsg(PersonalHelper.Type.Text, text)
end
def.static("table", "table").OnPetLevelUp = function(params)
  local petId = params[1]
  local lastLevel = params[2]
  local curLevel = params[3]
  local PetMgr = require("Main.Pet.mgr.PetMgr")
  local pet = PetMgr.Instance():GetPet(petId)
  require("Main.Chat.PersonalHelper").PetLevelUp(pet.name, curLevel)
end
def.static("table", "table").OnPetExpChanged = function(params)
  local petId = params[1]
  local addExp = params[2]
  local curExp = params[3]
end
def.static("userdata", "number").ShowPetGetExpMessage = function(petId, addExp)
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  local PetExpMap = {
    [petId] = addExp
  }
  PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.PersonalTip[2], PersonalHelper.Type.PetExpMap, PetExpMap)
end
def.static("table", "table").OnPetLifeAdded = function(params)
end
def.static("table").OnSUseLifeItemRes = function(data)
  local petId = data.petId
  local PetMgr = require("Main.Pet.mgr.PetMgr")
  local pet = PetMgr.Instance():GetPet(petId)
  local addLife = data.addLife
  PersonalHelper.PetPropIncCommon(pet.name, textRes.Pet[94], tostring(addLife))
end
def.static("table").OnSUseGrowItemRes = function(data)
  local petId = data.petId
  local PetMgr = require("Main.Pet.mgr.PetMgr")
  local pet = PetMgr.Instance():GetPet(petId)
  if pet == nil then
    warn(string.format("OnSUseGrowItemRes petId=%s, pet not found!", tostring(petId)))
    return
  end
  local addGrow = data.addGrow
  addGrow = string.format("%.3f", addGrow)
  local leftTimes = data.growItemLeft or -1
  local text = string.format(textRes.Pet[143], pet.name, tostring(addGrow), leftTimes)
  PersonalHelper.SendOut(text)
  local CommonUsePanel = require("GUI.CommonUsePanel")
  local panel = CommonUsePanel.Instance()
  if panel.tag and panel:IsShow() and panel.tag.petId == petId then
    local text = string.format(textRes.Pet[145], leftTimes)
    panel:SetDescText(text)
  end
end
def.static("table").OnSUsePetBagItemRes = function(data)
  if _G.PlayerIsInFight() then
    local petCfgId = data.petCfgId
    PetUtility.ShowGetPetInfo(petCfgId)
  end
end
def.static("table").OnSSyncAddSkill = function(data)
  local petId = data.petId
  local skillId = data.skillId
  local removeSkillId = data.removeSkillId or 0
  local reason = data.reason
  local pet = PetMgr.Instance():GetPet(petId)
  if pet == nil then
    warn(string.format("Attempt to add skill to pet(%s), but this pet don't exist!", tostring(petId)))
    return
  end
  local petCfg = pet:GetPetCfgData()
  local color = PetUtility.GetPetTypeColor(petCfg.type)
  local coloredPetName = string.format("<font color=#%s>%s</font>", color, pet.name)
  local skillName = PetUtility.Instance():GetPetSkillCfg(skillId).name
  local color = PetUtility.GetPetSkillQualityColor(skillId)
  local coloredskillName = string.format("<font color=#%s>%s</font>", color, skillName)
  local text = ""
  if removeSkillId == 0 then
    text = string.format(textRes.Pet.AddSkillReason[reason], coloredPetName, coloredskillName)
  else
    local skillName = PetUtility.Instance():GetPetSkillCfg(removeSkillId).name
    local color = PetUtility.GetPetSkillQualityColor(skillId)
    local coloredskillName2 = string.format("<font color=#%s>%s</font>", color, skillName)
    text = string.format(textRes.Pet.AddAndRemoveSkillReason[reason], coloredPetName, coloredskillName, coloredskillName2)
  end
  PersonalHelper.CommonMsg(PersonalHelper.Type.Text, text)
  if reason == data.class.FROM_BOOK then
    Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_LEARN_SKILL_SUCCESS, {
      petId = petId,
      skillId = skillId,
      removeSkillId = removeSkillId
    })
  end
  SafeLuckDog(function()
    return reason == data.class.FROM_LEVELUP
  end)
end
def.static("table", "table").OnPetChangeToFighting = function(params)
  local petId = params[1]
  if _G.PlayerIsInFight() then
    return
  end
  local pet = PetMgr.Instance():GetPet(petId)
  local petCfg = pet:GetPetCfgData()
  local color = PetUtility.GetPetTypeColor(petCfg.type)
  local coloredPetName = string.format("<font color=\"#%s\">%s</font>", color, pet.name)
  Toast(string.format(textRes.Pet[58], coloredPetName))
end
def.static("table", "table").OnPetChangeToDisplay = function(params)
  local petId = params[1]
  local pet = PetMgr.Instance():GetPet(petId)
  local petCfg = pet:GetPetCfgData()
  local color = PetUtility.GetPetTypeColor(petCfg.type)
  local coloredPetName = string.format("<font color=\"#%s\">%s</font>", color, pet.name)
  Toast(string.format(textRes.Pet[105], coloredPetName))
end
def.static("table", "table").OnPetAdded = function(params)
  local petId = params[1]
  local pet = PetMgr.Instance():GetPet(petId)
  PetUtility.ShowGetPetInfo(pet.typeId)
end
def.static("table", "table").OnNeedSupplementPetLife = function(params)
  local pet = PetMgr.Instance():GetFightingPet()
  if pet == nil then
    return
  end
  instance:GetUI(UISet.PetSupplementLife).Instance():ShowPanel()
end
def.static("table", "table").OnPetRememberedSkillSuccess = function(params)
  warn("OnPetRememberedSkillSuccess")
  local skillId = params.skillId
  local cSkillName = PetUtility.GetColoredSkillNameHtml(skillId)
  local text = string.format(textRes.Pet[62], cSkillName)
  Toast(text)
end
def.static("table", "table").OnPetUnrememberedSkillSuccess = function(params)
  local skillId = params.skillId
  local cSkillName = PetUtility.GetColoredSkillNameHtml(skillId)
  local text = string.format(textRes.Pet[64], cSkillName)
  Toast(text)
end
return PetUIMgr.Commit()
