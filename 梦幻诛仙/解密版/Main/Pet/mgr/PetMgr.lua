local Lplus = require("Lplus")
local PetMgr = Lplus.Class("PetMgr")
local def = PetMgr.define
local PetModule = Lplus.ForwardDeclare("PetModule")
local PetData = require("Main.Pet.data.PetData")
local PetUtility = require("Main.Pet.PetUtility")
local QualityType = PetData.PetQualityType
local ActionType = require("netio.protocol.mzm.gsp.pet.CUseItemReq")
local FanShengType = require("netio.protocol.mzm.gsp.pet.CFanShengReq")
local ItemModule = require("Main.Item.ItemModule")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local ItemUtils = require("Main.Item.ItemUtils")
FanShengType.ZAISHENG = 2
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
local instance
local CResult = {
  SUCCESS = 0,
  FORBIDDEN_IN_FIGHT = 1,
  HERO_LEVEL_TOO_LOW = 2,
  LIFE_TOO_SHORT = 3,
  PET_IS_FIGHTING = 4,
  PET_IS_DISPLAYING = 5,
  PET_IS_NEVER_DIE = 6,
  PET_LIFE_REACH_MAX = 7,
  EFFECT_AFTER_FIGHT = 8,
  PET_IS_REST = 9,
  PET_IS_HIDE = 10,
  WILD_PET_IS_FORBID = 11,
  PET_NOT_EXIST = 12
}
def.const("table").CResult = CResult
def.const("number").SKILL_BOOK_SOURCE_ITEM_ID = 341400000
def.const("table").CostType = {UseItem = 0, UseYuanBao = 1}
local TU_JIAN_RECORD_TABLE_KEY = "PetTuJianRecords"
local FIRST_TIME_LEARN_SKILL_TIP = "FIRST_TIME_LEARN_SKILL_TIP"
local PET_NOT_SET = Int64.new(-1)
def.const("userdata").PET_NOT_SET = PET_NOT_SET
def.const("table").FanShengType = FanShengType
def.field("table").petList = nil
def.field("number").petNum = 0
def.field("userdata").selectedPetId = function()
  return PET_NOT_SET
end
def.field("userdata").fightPetId = function()
  return PET_NOT_SET
end
def.field("userdata").displayPetId = function()
  return PET_NOT_SET
end
def.field("userdata").inFightScenePetId = function()
  return PET_NOT_SET
end
def.field("number").bagSize = 0
def.field("number").expandCount = 0
def.field("table")._petSPLifeNotifyMap = nil
def.static("=>", PetMgr).Instance = function()
  if instance == nil then
    instance = PetMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self:Reset()
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function(reason)
    self:Reset()
  end)
end
def.method("table").SetPetList = function(self, petTable)
  self.petList = {}
  self.petNum = 0
  for k, pet in pairs(petTable) do
    local petData = PetData()
    petData:RawSet(pet)
    petData:ReCalcYaoLi()
    if self.fightPetId == petData.id then
      petData.isFighting = true
    end
    if self.displayPetId == petData.id then
      petData.isDisplay = true
    end
    self.petList[tostring(petData.id)] = petData
    self.petNum = self.petNum + 1
  end
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_LIST_UPDATE, nil)
end
def.method("table").UpdatePetInfo = function(self, petInfo)
  self.petList = self.petList or {}
  local pet = self:GetPet(petInfo.petId)
  if pet == nil then
    warn(string.format("In UpdatePetInfo, pet not exist: petID = %s", tostring(petInfo.petId)))
    return
  end
  local lastPetData = self:BackupPartPetData(pet)
  pet:RawSet(petInfo)
  pet:ReCalcYaoLi()
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_INFO_UPDATE, {
    petInfo.petId
  })
  if pet.isFighting then
    Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.FIGHTING_PET_INFO_UPDATE, {
      petInfo.petId
    })
    self:CheckFightingPetAssignPropEvent(lastPetData, pet)
  end
  self:CheckPetLevelUpEvent(lastPetData, pet)
  self:CheckPetAddLifeEvent(lastPetData, pet)
  self:CheckPetYaoLiChangeEvent(lastPetData, pet)
end
def.method("table").RawAddPet = function(self, pet)
  self.petList = self.petList or {}
  if self:GetPet(pet.petId) ~= nil then
    warn(string.format("In AddPet, pet already exist: petID = %s", tostring(pet.petId)))
    return
  end
  local petData = PetData()
  petData:RawSet(pet)
  self:AddPet(petData)
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_ADDED, {
    pet.petId
  })
  SafeLuckDog(function()
    local petCfg = petData:GetPetCfgData()
    return petCfg.type == PetData.PetType.SHENSHOU or petCfg.type == PetData.PetType.MOSHOU
  end)
end
def.method("table").AddPet = function(self, petData)
  self.petList[tostring(petData.id)] = petData
  self.petNum = self.petNum + 1
end
def.method("userdata").RemovePet = function(self, petId)
  if not self:CheckPet(petId) then
    return
  end
  if self.displayPetId == petId then
    self.displayPetId = PET_NOT_SET
  end
  if self.fightPetId == petId then
    self.fightPetId = PET_NOT_SET
  end
  self.petList[tostring(petId)] = nil
  self.petNum = self.petNum - 1
end
def.method("=>", "table").GetPetList = function(self)
  if self.petList == nil then
    return {}
  end
  return self.petList
end
def.method("=>", "table").GetPets = function(self)
  if self.petList == nil then
    return {}
  end
  return self.petList
end
def.method("=>", "table").GetSortedPetList = function(self)
  if self.petList == nil then
    return {}
  end
  local list = {}
  for k, v in pairs(self.petList) do
    list[#list + 1] = v
  end
  table.sort(list, PetMgr.PetSortFunction)
  return list
end
def.method("userdata", "=>", PetData).GetPet = function(self, petId)
  return self.petList[tostring(petId)]
end
def.method("=>", "number").GetPetNum = function(self)
  return self.petNum
end
def.method("=>", "number").GetBagSize = function(self)
  return self.bagSize
end
def.method("=>", "boolean").IsPetFullest = function(self)
  if self.petNum >= self.bagSize then
    return true
  end
  return false
end
def.method("userdata", "number").UpdatePetState = function(self, petId, state)
  local SSyncPetStateChange = require("netio.protocol.mzm.gsp.pet.SSyncPetStateChange")
  if petId == nil then
    return
  end
  if state == SSyncPetStateChange.STATE_FIGHT then
    self:PetChangeToFighting(petId)
  elseif state == SSyncPetStateChange.STATE_SHOW then
    self:PetChangeToDisplay(petId)
  elseif state == SSyncPetStateChange.STATE_REST then
    self:PetChangeToRest(petId)
  elseif state == SSyncPetStateChange.STATE_HIDE then
    self:PetChangeToHide(petId)
  elseif state == SSyncPetStateChange.STATE_DELETE then
    self:PetBeDeleted(petId)
  end
  if state ~= SSyncPetStateChange.STATE_DELETE then
    Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_INFO_UPDATE, {petId})
  end
end
def.method("userdata").PetChangeToFighting = function(self, petId)
  if not self:CheckPet(petId) then
    return
  end
  if self.fightPetId ~= PET_NOT_SET and self:GetPet(self.fightPetId) then
    self:GetPet(self.fightPetId).isFighting = false
  end
  self:GetPet(petId).isFighting = true
  self.fightPetId = petId
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_CHANGE_TO_FIGHTING, {petId})
end
def.method("userdata").PetChangeToDisplay = function(self, petId)
  if not self:CheckPet(petId) then
    return
  end
  if self.displayPetId ~= PET_NOT_SET and self:GetPet(self.displayPetId) then
    self:GetPet(self.displayPetId).isDisplay = false
  end
  self:GetPet(petId).isDisplay = true
  self.displayPetId = petId
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_CHANGE_TO_DISPLAY, {petId})
end
def.method("userdata").PetChangeToRest = function(self, petId)
  if self.fightPetId ~= petId then
    warn(string.format("Attempt to change pet(id=%s) to reset state, but the fighting pet is %s", tostring(petId), tostring(self.fightPetId)))
    return
  end
  if not self:CheckPet(petId) then
    return
  end
  self:GetPet(self.fightPetId).isFighting = false
  self.fightPetId = PET_NOT_SET
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_CHANGE_TO_RESET, {petId})
end
def.method("userdata").PetChangeToHide = function(self, petId)
  if self.displayPetId ~= petId then
    warn(string.format("Attempt to change pet(id=%s) to hide state, but the displaying pet is %s", tostring(petId), tostring(self.displayPetId)))
    return
  end
  if not self:CheckPet(petId) then
    return
  end
  self:GetPet(self.displayPetId).isDisplay = false
  self.displayPetId = PET_NOT_SET
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_CHANGE_TO_HIDE, {petId})
end
def.method("userdata").PetBeDeleted = function(self, petId)
  self:RemovePet(petId)
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_DELETED, {petId})
end
def.method("=>", PetData).GetFightingPet = function(self)
  if self.fightPetId == PET_NOT_SET or self.petList == nil then
    return nil
  end
  return self:GetPet(self.fightPetId)
end
def.method("=>", PetData).GetDisplayPet = function(self)
  if self.fightPetId == PET_NOT_SET or self.petList == nil then
    return nil
  end
  return self:GetPet(self.displayPetId)
end
def.method("number", "=>", "table").GetPetsByTypeId = function(self, typeId)
  if self.petList == nil then
    return {}
  end
  local petList = {}
  for k, pet in pairs(self.petList) do
    if pet.typeId == typeId then
      table.insert(petList, pet)
    end
  end
  return petList
end
def.method("userdata", "userdata", "=>", "table").GetHuaShengMainPets = function(self, mainPetId, subPetId)
  if self.petList == nil then
    return {}
  end
  local petList = {}
  for k, pet in pairs(self.petList) do
    local petCfgData = pet:GetPetCfgData()
    if petCfgData.isCanBeHuaShengMainPet and not petCfgData.isSpecial and pet.id ~= subPetId and pet.id ~= mainPetId then
      table.insert(petList, pet)
    end
  end
  return petList
end
def.method("userdata", "userdata", "=>", "table").GetHuaShengSubPets = function(self, mainPetId, subPetId)
  if self.petList == nil then
    return {}
  end
  local petList = {}
  for k, pet in pairs(self.petList) do
    local petCfgData = pet:GetPetCfgData()
    if petCfgData.isCanBeHuaShengSubPet and not petCfgData.isSpecial and pet.id ~= subPetId and pet.id ~= mainPetId and #pet:GetSkillIdList() > 0 then
      table.insert(petList, pet)
    end
  end
  return petList
end
def.method("userdata", "=>", "boolean").CanPetGainExp = function(self, petId)
  local pet = self:GetPet(petId)
  local maxOverOwnerLevel = PetUtility.Instance():GetPetConstants("PET_LEVEL_MORE_THAN_OWNER_LIMIT")
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if pet.level < heroProp.level + maxOverOwnerLevel then
    return true
  else
    return false
  end
end
def.method("=>", "number").GetMaxOverOwnerLevel = function(self)
  return PetUtility.Instance():GetPetConstants("PET_LEVEL_MORE_THAN_OWNER_LIMIT")
end
def.method("=>", "boolean").CanExpandPetBag = function(self)
  local bagId = PetModule.PET_BAG_ID
  local bagCapacity = self.bagSize
  local expandBagCfg = PetUtility.Instance():GetExpandBagCfg(bagId, bagCapacity)
  return expandBagCfg.canExpand
end
def.method("userdata", "=>", "number").TogglePetFightingState = function(self, petId)
  if self.fightPetId ~= petId then
    return self:MakePetFighting(petId)
  else
    return self:MakePetRest(petId)
  end
end
def.method("userdata", "=>", "number").MakePetFighting = function(self, petId)
  if self.fightPetId == petId then
    return CResult.PET_IS_FIGHTING
  end
  local can, reason = self:PetCanFighting(petId)
  if not can then
    return reason
  end
  self:C2S_MakePetFighting(petId)
  return CResult.SUCCESS
end
def.method("userdata", "=>", "number").MakePetRest = function(self, petId)
  if self.fightPetId ~= petId then
    return CResult.PET_IS_REST
  end
  self:C2S_MakePetRest(petId)
  return CResult.SUCCESS
end
def.method("userdata", "=>", "number").TogglePetDisplayState = function(self, petId)
  if self.displayPetId ~= petId then
    return self:MakePetDisplay(petId)
  else
    return self:MakePetHide(petId)
  end
end
def.method("userdata", "=>", "number").MakePetDisplay = function(self, petId)
  if self.displayPetId == petId then
    return CResult.PET_IS_DISPLAYING
  end
  local can, reason = self:PetCanDisplay(petId)
  if not can then
    return reason
  end
  self:C2S_MakePetDisplay(petId)
  return CResult.SUCCESS
end
def.method("userdata", "=>", "number").MakePetHide = function(self, petId)
  if self.displayPetId ~= petId then
    return CResult.PET_IS_HIDE
  end
  self:C2S_MakePetHide(petId)
  return CResult.SUCCESS
end
def.method("userdata", "=>", "boolean", "number").PetCanFighting = function(self, petId)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local joinFightMinLife = PetUtility.Instance():GetPetConstants("PET_JOIN_FIGHT_MIN_LIFE")
  local pet = self:GetPet(petId)
  local petCfg = pet:GetPetCfgData()
  if heroProp.level < petCfg.carryLevel then
    return false, CResult.HERO_LEVEL_TOO_LOW
  elseif not pet:IsNeverDie() and joinFightMinLife > pet.life then
    return false, CResult.LIFE_TOO_SHORT
  end
  return true, CResult.SUCCESS
end
def.method("userdata", "=>", "boolean", "number").PetCanDisplay = function(self, petId)
  local pet = self:GetPet(petId)
  local petCfg = pet:GetPetCfgData()
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp.level < petCfg.carryLevel then
    return false, CResult.HERO_LEVEL_TOO_LOW
  elseif petId == self.displayPetId then
    return false, CResult.PET_IS_DISPLAYING
  end
  return true, CResult.SUCCESS
end
def.method("userdata").MakePetFree = function(self, petId)
  self:C2S_MakePetFree(petId)
end
def.method("userdata", "string").RenamePet = function(self, petId, petName)
  self:C2S_RenamePet(petId, petName)
end
def.method("userdata", "=>", "boolean", "number").CanLianGu = function(self, petId)
  local pet = self:GetPet(petId)
  local petCfg = pet:GetPetCfgData()
  if petCfg.type == PetData.PetType.WILD then
    return false, CResult.WILD_PET_IS_FORBID
  end
  return true, CResult.SUCCESS
end
def.method("userdata", "number", "=>", "number").LianGu = function(self, petId, qualityType)
  local success, reason = self:CanLianGu(petId)
  if not success then
    return reason
  end
  self:C2S_CLianGuReq(petId, qualityType)
  return CResult.SUCCESS
end
def.method("userdata", "number", "number").AddPetQualityValue = function(self, petId, qualityType, value)
  local pet = self:GetPet(petId)
  pet.petQuality:AddValue(qualityType, value)
  pet:ReCalcYaoLi()
end
def.method("number").ExpandPetBag = function(self, itemNum)
  local yuanBaoNum = ItemModule.Instance():GetAllYuanBao()
  self:C2S_ExpandPetBag(itemNum, yuanBaoNum)
end
def.method("userdata", "number").AddPetExp = function(self, petId, expNum)
  if not self:CheckPet(petId) then
    return
  end
  local pet = self:GetPet(petId)
  pet.exp = pet.exp + expNum
  if pet.isFighting then
    Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.FIGHTING_PET_INFO_UPDATE, {petId})
  end
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_EXP_CHANGED, {
    petId,
    expNum,
    pet.exp
  })
end
def.method("userdata", "=>", "boolean").CheckPet = function(self, petId)
  if self:GetPet(petId) == nil then
    warn(string.format("Pet(%s) not exist", tostring(petId)), debug.traceback())
    return false
  end
  return true
end
def.method("userdata", "number", "number", "=>", "number").UseItem = function(self, petId, itemKey, itemType)
  local actionType
  if itemType == ItemType.PET_EXP_ITEM then
    actionType = ActionType.ADD_EXP_ACTION
  elseif itemType == ItemType.PET_LIFE_ITEM then
    local pet = self:GetPet(petId)
    if pet:IsNeverDie() then
      return CResult.PET_IS_NEVER_DIE
    end
    local petCfgData = pet:GetPetCfgData()
    local bornMaxLife = petCfgData.bornMaxLife
    if bornMaxLife <= pet.life then
      return CResult.PET_LIFE_REACH_MAX
    end
    actionType = ActionType.ADD_LIFE_ACTION
  elseif itemType == ItemType.PET_GROW_ITEM then
    actionType = ActionType.ADD_GROW_ACTION
  end
  self:C2S_CUseItemReq(petId, itemKey, actionType)
  return CResult.SUCCESS
end
def.method("number").GoToCatchPet = function(self, mapId)
  local myRole = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if myRole and myRole:IsInState(RoleState.UNTRANPORTABLE) then
    Toast(textRes.Hero[50])
    return
  end
  Toast(textRes.Pet[126])
  local OnHookModule = Lplus.ForwardDeclare("OnHookModule")
  OnHookModule.EnterOneMapToOnHook(mapId)
end
def.method("number", "=>", "number").GetPetCanBeCatchedMapId = function(self, petTemplateId)
  local petCfg = PetUtility.Instance():GetPetCfg(petTemplateId)
  local cfg = PetUtility.FindPetTuJianCfgByTypeRefId(petCfg.typeRefId)
  return cfg.mapId
end
def.method("number").OpenBuyPetPanelWithPetId = function(self, petTemplateId)
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.OPEN_PET_BUY_PANEL, {petTemplateId})
end
def.method("number").GoToBuyPet = function(self, petTemplateId)
  local myRole = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if myRole and myRole:IsInState(RoleState.UNTRANPORTABLE) then
    Toast(textRes.Hero[50])
    return
  end
  local ServiceType = require("consts.mzm.gsp.npc.confbean.ServiceType")
  local npcId = PetUtility.Instance():GetPetConstants("PETSHOP_NPC_ID")
  Event.DispatchEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_GOTO_TARGET_SERVICE, {
    npcId,
    ServiceType.Function,
    {petTemplateId}
  })
end
def.method("number", "=>", "boolean").GoToExchangePet = function(self, petTemplateId)
  local petCfg = PetUtility.Instance():GetPetCfg(petTemplateId)
  if petCfg.type == PetData.PetType.SHENSHOU then
    return self:GoToExchangeShenShou()
  elseif petCfg.type == PetData.PetType.MOSHOU then
    return self:GoToExchangeMoShou()
  end
end
def.method("=>", "boolean").GoToExchangeShenShou = function(self)
  local ServiceType = require("consts.mzm.gsp.npc.confbean.ServiceType")
  local npcId = PetUtility.Instance():GetPetConstants("GOLD_PET_REDEEM_NPCID")
  Event.DispatchEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_GOTO_TARGET_SERVICE, {
    npcId,
    ServiceType.Function,
    {
      petexchange = PetData.PetType.SHENSHOU
    }
  })
  return true
end
def.method("=>", "boolean").GoToExchangeMoShou = function(self)
  local ServiceType = require("consts.mzm.gsp.npc.confbean.ServiceType")
  local npcId = PetUtility.Instance():GetPetConstants("MOSHOU_PET_REDEEM_NPCID")
  Event.DispatchEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_GOTO_TARGET_SERVICE, {
    npcId,
    ServiceType.Function,
    {
      petexchange = PetData.PetType.MOSHOU
    }
  })
  return true
end
def.static(PetData, PetData, "=>", "boolean").PetSortFunction = function(left, right)
  local PetType = require("consts.mzm.gsp.pet.confbean.PetType")
  local leftCfg = left:GetPetCfgData()
  local rightCfg = right:GetPetCfgData()
  if leftCfg.type == PetType.MOSHOU and rightCfg.type ~= PetType.MOSHOU then
    return true
  elseif leftCfg.type ~= PetType.MOSHOU and rightCfg.type == PetType.MOSHOU then
    return false
  elseif leftCfg.type == PetType.SHENSHOU and rightCfg.type ~= PetType.SHENSHOU then
    return true
  elseif leftCfg.type ~= PetType.SHENSHOU and rightCfg.type == PetType.SHENSHOU then
    return false
  elseif leftCfg.carryLevel > rightCfg.carryLevel then
    return true
  elseif leftCfg.carryLevel == rightCfg.carryLevel and left.id > right.id then
    return true
  else
    return false
  end
end
def.method("userdata", "=>", "boolean").IsNeededFreeConfirm = function(self, petId)
  if not self:CheckPet(petId) then
    return false
  end
  local pet = self:GetPet(petId)
  return pet.isBinded or pet:GetPetCfgData().type ~= PetData.PetType.WILD
end
def.method("userdata", "=>", "boolean").IsNeededFreeProtection = function(self, petId)
  if not self:CheckPet(petId) then
    return false
  end
  local pet = self:GetPet(petId)
  if pet.isBinded then
    return true
  end
  local petCfg = pet:GetPetCfgData()
  if petCfg.type >= PetData.PetType.BIANYI then
    return true
  end
  local PetYaoLi = require("consts.mzm.gsp.pet.confbean.PetYaoLi")
  local yaoLiCfg = pet:GetPetYaoLiCfg()
  if yaoLiCfg.petYaoLiLevel <= PetYaoLi.A then
    return true
  end
  return false
end
def.method("=>", "table").GetPetSkillBooks = function(self)
  local ItemUtils = require("Main.Item.ItemUtils")
  local itemList = {}
  local items = ItemModule.Instance():GetOrderedItemsByBagId(ItemModule.BAG)
  for i, item in ipairs(items) do
    local itemBase = ItemUtils.GetItemBase(item.id)
    if itemBase.itemType == ItemType.PET_SKILL_BOOK then
      table.insert(itemList, item)
    end
  end
  return itemList
end
def.method("userdata", "number", "number").FanShengReq = function(self, petId, fanShengType, costType)
  local yuanBaoNum = ItemModule.Instance():GetAllYuanBao()
  self:C2S_CFanShengReq(petId, fanShengType, costType, yuanBaoNum)
end
def.method("userdata", "boolean", "number").ZaiShengReq = function(self, petId, isCostYuanbao, needYuanbao)
  local yuanBaoNum = ItemModule.Instance():GetAllYuanBao()
  self:C2S_CZaiShengReq(petId, isCostYuanbao, needYuanbao, yuanBaoNum)
end
def.method("userdata", "boolean", "number").JinjieReq = function(self, petId, isCostYuanbao, needYuanbao)
  local yuanBaoNum = ItemModule.Instance():GetAllYuanBao()
  self:C2S_CJinjieReq(petId, isCostYuanbao, needYuanbao, yuanBaoNum)
end
def.method("userdata", "table").PetFanSheng = function(self, oldPetId, petInfo)
  local petData = PetData()
  petData:RawSet(petInfo)
  local oldPetData = self:GetPet(oldPetId)
  self.petList[tostring(oldPetId)] = nil
  local newPetId = petData.id
  self.petList[tostring(newPetId)] = petData
  if self.displayPetId == oldPetId then
    self.displayPetId = PET_NOT_SET
  end
  if self.fightPetId == oldPetId then
    self.fightPetId = PET_NOT_SET
  end
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_FAN_SHENG_RESPONSE, {oldPetId, newPetId})
  if oldPetData then
    local lastPetData = self:BackupPartPetData(oldPetData)
    self:CheckPetYaoLiChangeEvent(lastPetData, petData)
    SafeLuckDog(function()
      local PetType = require("consts.mzm.gsp.pet.confbean.PetType")
      local oldPetCfg = oldPetData:GetPetCfgData()
      local newPetCfg = petData:GetPetCfgData()
      return newPetCfg.type == PetType.BIANYI and oldPetCfg.type ~= PetType.BIANYI
    end)
  end
end
def.method("userdata", "userdata", "number", "number").HuaShengReq = function(self, mainPetId, subPetId, costType, needYuanbao)
  local yuanBaoNum = ItemModule.Instance():GetAllYuanBao()
  local CHuaShengReq = require("netio.protocol.mzm.gsp.pet.CHuaShengReq")
  self:C2S_CHuaShengReq(mainPetId, subPetId, costType, yuanBaoNum, CHuaShengReq.NO_USE_HUA_SHENG_MIMMUM_GUARANTEE, needYuanbao)
end
def.method("userdata", "userdata", "number", "number").GeneralEnsureHuaShengReq = function(self, mainPetId, subPetId, costType, needYuanbao)
  local yuanBaoNum = ItemModule.Instance():GetAllYuanBao()
  local CHuaShengReq = require("netio.protocol.mzm.gsp.pet.CHuaShengReq")
  self:C2S_CHuaShengReq(mainPetId, subPetId, costType, yuanBaoNum, CHuaShengReq.USE_LOW_HUA_SHENG_MIMMUM_GUARANTEE, needYuanbao)
end
def.method("userdata", "userdata", "number", "number").HighEnsureHuaShengReq = function(self, mainPetId, subPetId, costType, needYuanbao)
  local yuanBaoNum = ItemModule.Instance():GetAllYuanBao()
  local CHuaShengReq = require("netio.protocol.mzm.gsp.pet.CHuaShengReq")
  self:C2S_CHuaShengReq(mainPetId, subPetId, costType, yuanBaoNum, CHuaShengReq.USE_HIGH_HUA_SHENG_MIMMUM_GUARANTEE, needYuanbao)
end
def.method("userdata", "number").EquipItemReq = function(self, petId, itemKey)
  self:C2S_CEquipItemReq(petId, itemKey)
end
def.method("userdata", "number").EquipDecorateItemReq = function(self, petId, itemKey)
  self:C2S_CEquipDecorateItemReq(petId, itemKey)
end
def.method("userdata", "number").AllUsePetExpItem = function(self, petId, itemKey)
  self:C2S_CUsePetExpItemAutoReq(petId, itemKey)
end
def.method("number").UsePetBabyBag = function(self, itemKey)
  self:C2S_CUsePetBagItemReq(itemKey)
end
def.method("userdata", "boolean", "number").GetPetModelItemReq = function(self, petId, isCostYuanbao, needYuanbao)
  local yuanBaoNum = ItemModule.Instance():GetAllYuanBao()
  self:C2S_CGetPetModelItemReq(petId, isCostYuanbao, needYuanbao, yuanBaoNum)
end
def.method("userdata", "number").UsePetChangeModelItemReq = function(self, petId, itemKey)
  self:C2S_CUsePetChangeModelItemReq(petId, itemKey)
end
def.method("userdata", "boolean", "number").CancelPetModelChangeItemReq = function(self, petId, isCostYuanbao, needYuanbao)
  local yuanBaoNum = ItemModule.Instance():GetAllYuanBao()
  self:C2S_CCancelPetModelChangeItemReq(petId, isCostYuanbao, needYuanbao, yuanBaoNum)
end
def.method("=>", "table").GetPetTuJianRecords = function(self)
  local records = {}
  if LuaPlayerPrefs.HasRoleKey(TU_JIAN_RECORD_TABLE_KEY) then
    records = LuaPlayerPrefs.GetRoleTable(TU_JIAN_RECORD_TABLE_KEY)
  end
  return records
end
def.method("table").SetPetTuJianRecords = function(self, records)
  records = LuaPlayerPrefs.SetRoleTable(TU_JIAN_RECORD_TABLE_KEY, records)
end
def.method().SavePetTuJianRecords = function(self)
  LuaPlayerPrefs.Save()
end
def.method("=>", "boolean").IsFirstTimeLearnSkill = function(self)
  if LuaPlayerPrefs.HasRoleKey(FIRST_TIME_LEARN_SKILL_TIP) then
    return false
  end
  return true
end
def.method().MarkLearnSkillTipAsReaded = function(self)
  LuaPlayerPrefs.SetRoleInt(FIRST_TIME_LEARN_SKILL_TIP, 0)
  LuaPlayerPrefs.Save()
end
def.method(PetData, "=>", "table").BackupPartPetData = function(self, petData)
  local backupData = {}
  backupData.id = petData.id
  backupData.level = petData.level
  backupData.life = petData.life
  backupData.yaoli = petData:GetYaoLi()
  backupData.levelScore = petData:GetLevelScore()
  backupData.assignPropScheme = {}
  backupData.assignPropScheme.potentialPoint = petData.assignPropScheme.potentialPoint
  backupData.assignPropScheme.isEnableAutoAssign = petData.assignPropScheme.isEnableAutoAssign
  return backupData
end
def.method("table", PetData).CheckPetLevelUpEvent = function(self, lastPetData, petData)
  if petData.level > lastPetData.level then
    Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_LEVEL_UP, {
      petData.id,
      lastPetData.level,
      petData.level
    })
  end
end
def.method("table", PetData).CheckPetAddLifeEvent = function(self, lastPetData, petData)
  if petData.life > lastPetData.life then
    Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_LIFE_ADDED, {
      petData.id,
      lastPetData.life,
      petData.life
    })
    local limit = PetUtility.Instance():GetPetConstants("ADD_LIFE_TIPS_LIMIT")
    if limit <= petData.life then
      local strPetId = tostring(petData.id)
      self._petSPLifeNotifyMap[strPetId] = nil
    end
  end
end
def.method("table", PetData).CheckPetYaoLiChangeEvent = function(self, lastPetData, petData)
  if petData:GetYaoLi() ~= lastPetData.yaoli then
    local from = lastPetData.yaoli
    local to = petData:GetYaoLi()
    local scoreFrom = lastPetData.levelScore
    local scoreTo = petData:GetLevelScore()
    Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_YAOLI_CHANGE, {
      petId = petData.id,
      from = from,
      to = to,
      scoreFrom = scoreFrom,
      scoreTo = scoreTo
    })
  end
end
def.method("table", PetData).CheckFightingPetAssignPropEvent = function(self, lastPetData, petData)
  if petData.assignPropScheme.potentialPoint == 0 and lastPetData.assignPropScheme.potentialPoint ~= 0 or petData.assignPropScheme.potentialPoint ~= 0 and lastPetData.assignPropScheme.potentialPoint == 0 or petData.assignPropScheme.isEnableAutoAssign ~= lastPetData.assignPropScheme.isEnableAutoAssign then
    PetModule.Instance():CheckNotify()
  end
end
def.method().CheckSupplementPetLifeEvent = function(self)
  local petData = self:GetFightingPet()
  if petData == nil then
    return
  end
  if petData:IsNeverDie() then
    return
  end
  local limit = PetUtility.Instance():GetPetConstants("ADD_LIFE_TIPS_LIMIT")
  if limit > petData.life then
    local strPetId = tostring(petData.id)
    if self._petSPLifeNotifyMap[strPetId] == nil then
      require("Main.Common.OutFightDo").Instance():Do(function()
        Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_LIFE_NEED_SUPPLEMENT, {
          petData.id
        })
      end, nil)
      self._petSPLifeNotifyMap[strPetId] = true
    end
  end
end
def.method("=>", "table").GetSupplementLifeFilterCfgs = function(self)
  local ItemUtils = require("Main.Item.ItemUtils")
  local cfgs = {}
  for i, siftId in ipairs(PetModule.SUPPLEMENT_LIFE_SIFT_IDS) do
    local filterCfg = ItemUtils.GetItemFilterCfg(siftId)
    table.insert(cfgs, filterCfg)
  end
  return cfgs
end
def.method("table", "number", "number", "number", "=>", "table").CalcQualityIncBound = function(self, petLianGuItemCfg, minValue, value, maxValue)
  local bound = {down = 0, up = 0}
  local expectAddValue = (maxValue - value) * petLianGuItemCfg.expectAddRate / 10000
  local floatValue = math.min(expectAddValue * petLianGuItemCfg.floatExpectRate / 10000, petLianGuItemCfg.floatMaxNum)
  bound.down = math.max(expectAddValue - floatValue, petLianGuItemCfg.minAddNum)
  bound.up = math.max(expectAddValue + floatValue, petLianGuItemCfg.minAddNum)
  return bound
end
def.method("table").OnSLianGuRes = function(self, data)
  local pet = self:GetPet(data.petId)
  if pet == nil then
    return
  end
  local lastPetData = self:BackupPartPetData(pet)
  for k, v in pairs(data.aptMap) do
    self:AddPetQualityValue(data.petId, k, v)
  end
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_QUALITY_UPDATE, {
    data.petId,
    data.aptMap,
    data.lianguItemLeft
  })
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_INFO_UPDATE, {
    data.petId
  })
  self:CheckPetYaoLiChangeEvent(lastPetData, pet)
end
def.static("table", "table", "=>", "boolean").PetEquipmentItemFilter = function(item, params)
  local slot = params[1]
  local itemBase = ItemUtils.GetItemBase(item.id)
  if itemBase.itemType == ItemType.PET_EQUIP then
    local equipmentCfg = PetUtility.GetPetEquipmentCfg(item.id)
    if equipmentCfg.equipType == slot then
      return true
    end
  end
  return false
end
def.static("table", "table", "=>", "boolean").PetExpItemFilter = function(item, params)
  local itemBase = ItemUtils.GetItemBase(item.id)
  return itemBase.itemType == ItemType.PET_EXP_ITEM
end
def.static("table", "table", "=>", "boolean").PetGrowItemFilter = function(item, params)
  local itemBase = ItemUtils.GetItemBase(item.id)
  return itemBase.itemType == ItemType.PET_GROW_ITEM
end
def.static("table", "table", "=>", "boolean").PetLifeItemFilter = function(item, params)
  local itemBase = ItemUtils.GetItemBase(item.id)
  return itemBase.itemType == ItemType.PET_LIFE_ITEM
end
def.method().Reset = function(self)
  self.petList = {}
  self._petSPLifeNotifyMap = {}
  self.inFightScenePetId = PET_NOT_SET
end
def.method("userdata").SetInFightScenePet = function(self, petId)
  if petId == nil then
    self.inFightScenePetId = PET_NOT_SET
    Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_IN_FIGHT_SCENE_CHANGED, nil)
  elseif self:GetPet(petId) ~= nil then
    self.inFightScenePetId = petId
    Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_IN_FIGHT_SCENE_CHANGED, nil)
  end
end
def.method().ClearInFightScenePet = function(self)
  self.inFightScenePetId = PET_NOT_SET
end
def.method("=>", PetData).GetInFightScenePet = function(self)
  if self.inFightScenePetId == PET_NOT_SET or self.petList == nil then
    return nil
  end
  return self:GetPet(self.inFightScenePetId)
end
def.method("userdata", "=>", "boolean").IsPetInFightScene = function(self, petId)
  if self.inFightScenePetId == PET_NOT_SET or self.petList == nil then
    return false
  end
  return self.inFightScenePetId == petId
end
def.method("userdata").C2S_MakePetFighting = function(self, petId)
  local PetInterface = require("Main.Pet.Interface")
  local pet = PetInterface.GetPet(petId)
  if pet ~= nil and pet.isBinded == false then
    require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Common[8], textRes.Pet[142], function(s)
      if s == 1 then
        local p = require("netio.protocol.mzm.gsp.pet.CJoinFightReq").new(petId)
        gmodule.network.sendProtocol(p)
      end
    end, {
      unique = self.C2S_MakePetFighting
    })
  else
    local p = require("netio.protocol.mzm.gsp.pet.CJoinFightReq").new(petId)
    gmodule.network.sendProtocol(p)
  end
end
def.method("userdata").C2S_MakePetDisplay = function(self, petId)
  local p = require("netio.protocol.mzm.gsp.pet.CShowPetReq").new(petId)
  gmodule.network.sendProtocol(p)
end
def.method("userdata").C2S_MakePetRest = function(self, petId)
  local p = require("netio.protocol.mzm.gsp.pet.CPetRestReq").new(petId)
  gmodule.network.sendProtocol(p)
end
def.method("userdata").C2S_MakePetHide = function(self, petId)
  local p = require("netio.protocol.mzm.gsp.pet.CHidePetReq").new(petId)
  gmodule.network.sendProtocol(p)
end
def.method("userdata").C2S_MakePetFree = function(self, petId)
  local p = require("netio.protocol.mzm.gsp.pet.CReleasePetReq").new(petId)
  gmodule.network.sendProtocol(p)
end
def.method("userdata", "string").C2S_RenamePet = function(self, petId, petName)
  local p = require("netio.protocol.mzm.gsp.pet.CRenamePetReq").new(petId, petName)
  gmodule.network.sendProtocol(p)
end
def.method("number", "userdata").C2S_ExpandPetBag = function(self, itemNum, yuanBaoNum)
  local p = require("netio.protocol.mzm.gsp.pet.CExpandPetBagReq").new(itemNum, yuanBaoNum)
  gmodule.network.sendProtocol(p)
end
def.method("userdata", "number").C2S_CLianGuReq = function(self, petId, qualityType)
  local PetInterface = require("Main.Pet.Interface")
  local pet = PetInterface.GetPet(petId)
  if pet ~= nil and pet.isBinded == false then
    require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Common[8], textRes.Pet[142], function(s)
      if s == 1 then
        local p = require("netio.protocol.mzm.gsp.pet.CLianGuReq").new(petId, qualityType)
        gmodule.network.sendProtocol(p)
      end
    end, {
      unique = self.C2S_CLianGuReq
    })
  else
    local p = require("netio.protocol.mzm.gsp.pet.CLianGuReq").new(petId, qualityType)
    gmodule.network.sendProtocol(p)
  end
end
def.method("userdata", "number", "number").C2S_CUseItemReq = function(self, petId, itemKey, actionType)
  local PetInterface = require("Main.Pet.Interface")
  local pet = PetInterface.GetPet(petId)
  if pet ~= nil and pet.isBinded == false then
    require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Common[8], textRes.Pet[142], function(s)
      if s == 1 then
        local p = require("netio.protocol.mzm.gsp.pet.CUseItemReq").new(petId, itemKey, actionType)
        gmodule.network.sendProtocol(p)
      end
    end, {
      unique = self.C2S_CUseItemReq
    })
  else
    local p = require("netio.protocol.mzm.gsp.pet.CUseItemReq").new(petId, itemKey, actionType)
    gmodule.network.sendProtocol(p)
  end
end
def.method("userdata", "number").C2S_CEquipItemReq = function(self, petId, itemKey)
  local PetInterface = require("Main.Pet.Interface")
  local pet = PetInterface.GetPet(petId)
  if pet ~= nil and pet.isBinded == false then
    require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Common[8], textRes.Pet[142], function(s)
      if s == 1 then
        local p = require("netio.protocol.mzm.gsp.pet.CEquipItemReq").new(petId, itemKey)
        gmodule.network.sendProtocol(p)
      end
    end, {
      unique = self.C2S_CEquipItemReq
    })
  else
    local p = require("netio.protocol.mzm.gsp.pet.CEquipItemReq").new(petId, itemKey)
    gmodule.network.sendProtocol(p)
  end
end
def.method("userdata", "number", "number", "userdata").C2S_CFanShengReq = function(self, petId, fanShengType, costType, yuanBaoNum)
  local p = require("netio.protocol.mzm.gsp.pet.CFanShengReq").new(petId, fanShengType, costType, yuanBaoNum)
  gmodule.network.sendProtocol(p)
end
def.method("userdata", "boolean", "number", "userdata").C2S_CZaiShengReq = function(self, petId, isCostYuanbao, needYuanbao, yuanBaoNum)
  isCostYuanbao = isCostYuanbao == true and 1 or 0
  local p = require("netio.protocol.mzm.gsp.pet.CReplacePetSkillReq").new(petId, isCostYuanbao, yuanBaoNum, needYuanbao)
  gmodule.network.sendProtocol(p)
end
def.method("userdata", "boolean", "number", "userdata").C2S_CJinjieReq = function(self, petId, isCostYuanbao, needYuanbao, yuanBaoNum)
  isCostYuanbao = isCostYuanbao == true and 1 or 0
  local p = require("netio.protocol.mzm.gsp.pet.CPetStageLevelUpReq").new(petId, isCostYuanbao, yuanBaoNum, needYuanbao)
  gmodule.network.sendProtocol(p)
end
def.method("userdata", "userdata", "number", "userdata", "number", "number").C2S_CHuaShengReq = function(self, mainPetId, subPetId, costType, yuanBaoNum, opType, needYuanbao)
  local p = require("netio.protocol.mzm.gsp.pet.CHuaShengReq").new(mainPetId, subPetId, costType, yuanBaoNum, opType, needYuanbao)
  gmodule.network.sendProtocol(p)
end
def.method("userdata", "number").C2S_CEquipDecorateItemReq = function(self, petId, itemKey)
  local PetInterface = require("Main.Pet.Interface")
  local pet = PetInterface.GetPet(petId)
  if pet ~= nil and pet.isBinded == false then
    require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Common[8], textRes.Pet[142], function(s)
      if s == 1 then
        local p = require("netio.protocol.mzm.gsp.pet.CEquipDecorateItemReq").new(petId, itemKey)
        gmodule.network.sendProtocol(p)
      end
    end, {
      unique = self.C2S_CEquipDecorateItemReq
    })
  else
    local p = require("netio.protocol.mzm.gsp.pet.CEquipDecorateItemReq").new(petId, itemKey)
    gmodule.network.sendProtocol(p)
  end
end
def.method("userdata", "number").C2S_CUsePetExpItemAutoReq = function(self, petId, itemKey)
  local p = require("netio.protocol.mzm.gsp.pet.CUsePetExpItemAutoReq").new(petId, itemKey)
  gmodule.network.sendProtocol(p)
end
def.method("number").C2S_CUsePetBagItemReq = function(self, itemKey)
  local p = require("netio.protocol.mzm.gsp.pet.CUsePetBagItemReq").new(itemKey)
  gmodule.network.sendProtocol(p)
end
def.method("userdata", "boolean", "number", "userdata").C2S_CGetPetModelItemReq = function(self, petId, isCostYuanbao, costYuanBao, hasYuanBao)
  isCostYuanbao = isCostYuanbao == true and 1 or 0
  local p = require("netio.protocol.mzm.gsp.pet.CGetPetModelItemReq").new(petId, isCostYuanbao, hasYuanBao, costYuanBao)
  gmodule.network.sendProtocol(p)
end
def.method("userdata", "number").C2S_CUsePetChangeModelItemReq = function(self, petId, itemKey)
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.BAG, itemKey)
  if item == nil then
    warn("item not exist, itemKey:" .. itemKey)
    return
  end
  local pet = PetMgr.Instance():GetPet(petId)
  if pet == nil then
    warn("pet not exist")
    return
  end
  local petCfg = pet:GetPetCfgData()
  if petCfg.type == PetData.PetType.WILD then
    Toast(textRes.Pet[249])
    return
  end
  local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr").Instance()
  local heroProp = HeroPropMgr.heroProp
  if petCfg.carryLevel > heroProp.level then
    Toast(textRes.Pet[251])
    return
  end
  if pet:IsFullExtraModel() then
    Toast(textRes.Pet[248])
    return
  end
  local itemDetail = ItemUtils.GetPetHuiZhiItemCfg(item.id)
  local cannotUsePet = itemDetail.cannotUsePet
  for i = 1, #cannotUsePet do
    if cannotUsePet[i] == pet.typeId then
      Toast(textRes.Pet[250])
      return
    end
  end
  if pet:HasExtraModel(item.id) then
    Toast(textRes.Pet[258])
    return
  end
  local p = require("netio.protocol.mzm.gsp.pet.CUsePetChangeModelItemReq").new(petId, itemKey)
  gmodule.network.sendProtocol(p)
end
def.method("userdata", "boolean", "number", "userdata").C2S_CCancelPetModelChangeItemReq = function(self, petId, isCostYuanbao, costYuanBao, hasYuanBao)
  isCostYuanbao = isCostYuanbao == true and 1 or 0
  local p = require("netio.protocol.mzm.gsp.pet.CCancelPetModelChangeItemReq").new(petId, isCostYuanbao, hasYuanBao, costYuanBao)
  gmodule.network.sendProtocol(p)
end
def.method("userdata", "number").C2S_CSWitchPetModel = function(self, petId, itemId)
  local p = require("netio.protocol.mzm.gsp.pet.CSWitchPetModel").new(petId, itemId)
  gmodule.network.sendProtocol(p)
end
def.method("userdata", "number").C2S_CDeletePetModel = function(self, petId, itemId)
  local p = require("netio.protocol.mzm.gsp.pet.CDeletePetModel").new(petId, itemId)
  gmodule.network.sendProtocol(p)
end
def.method("userdata").QueryYuanBaoMakePetPrice = function(self, petId)
  local p = require("netio.protocol.mzm.gsp.pet.CHuaShengYuanBaoMakeUpViceInfoReq").new(petId)
  gmodule.network.sendProtocol(p)
end
return PetMgr.Commit()
