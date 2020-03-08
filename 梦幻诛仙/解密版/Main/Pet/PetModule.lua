local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local PetModule = Lplus.Extend(ModuleBase, "PetModule")
require("Main.module.ModuleId")
local ECGame = Lplus.ForwardDeclare("ECGame")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local PetTuJianPage = require("consts.mzm.gsp.pet.confbean.PetPageName")
local PetSkillMgr = require("Main.Pet.mgr.PetSkillMgr")
local PetMgr = require("Main.Pet.mgr.PetMgr")
local PetUtility = require("Main.Pet.PetUtility")
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
local NodeId = require("Main.Pet.ui.PetPanelNodeEnum")
local GameUnitType = require("consts/mzm/gsp/common/confbean/GameUnitType")
local def = PetModule.define
def.const("table").PET_ITEM_TYPES = {
  [ItemType.PET_EQUIP] = true,
  [ItemType.PET_SKILL_BOOK] = true,
  [ItemType.PET_EXP_ITEM] = true,
  [ItemType.PET_LIFE_ITEM] = true,
  [ItemType.PET_DECORATE_ITEM] = false,
  [ItemType.PET_RESET_ITEM] = false,
  [ItemType.PET_GROW_ITEM] = true,
  [ItemType.PET_HUASHENG_ITEM] = false,
  [ItemType.PET_LIANGU_ITEM] = false,
  [ItemType.PET_PUTONG_FANSHENG_ITEM] = false,
  [ItemType.PET_HIGHTLEVEL_FANSHENG_ITEM] = false,
  [ItemType.PET_REMEBER_SKILL_ITEM] = false,
  [ItemType.PET_EQUIP_REFRESH] = true
}
def.const("number").PET_BAG_ID = 340600003
def.const("number").PET_STORAGE_BAG_ID = 340600004
def.const("number").PET_SHOP_BUY_SERVICE = 150200027
def.const("number").PET_SHOP_SELL_SERVICE = 150200028
def.const("number").PET_STORAGE_SERVICE = 150200100
def.const("number").PET_FREE_SERVICE = 150200101
def.const("number").PET_HUA_SHENG_TIP_ID = 701604005
def.const("number").PET_LIANGU_TIP_ID = 701604015
def.const("number").PET_INFO_TIP_ID = 701604016
def.const("number").PET_HUA_SHENG_PREVIEW_TIP_ID = 701604006
def.const("number").PET_ASSIGN_PROP_TIP_ID = 701604007
def.const("number").PET_STORAGE_NPC_ID = 150111305
def.const("table").SUPPLEMENT_LIFE_SIFT_IDS = {
  210202000,
  210202001,
  210202002
}
def.const("number").PET_COMPOSITE_EQUIPMENT_TIP_ID = 701604003
def.const("number").PET_REFRESH_AMULET_TIP_ID = 701604004
def.const("number").PET_TJ_OPEN_GT_ROLE_LEVEL = 10
def.const("number").PET_REMEMBER_SKILL_USE_ITEM_NUM = 1
def.const("number").PET_LIANGU_USE_ITEM_NUM = 1
def.const("number").PET_REFRESH_AMULET_USE_ITEM_NUM = 1
def.field("number")._tuJianLastHeroLevel = 0
def.field("table").tuJianCfg = nil
def.field("table").pendingPetInfoReqList = nil
def.field("number").notifyCount = -1
local _itemUseReqMap, instance
def.static("=>", PetModule).Instance = function()
  if instance == nil then
    instance = PetModule()
    instance.m_moduleId = ModuleId.PET
  end
  return instance
end
def.override().Init = function(self)
  require("Main.Pet.PetUIMgr").Instance()
  require("Main.Pet.mgr.PetExchangeMgr").Instance():Init()
  require("Main.Pet.soul.PetSoulMgr").Instance():Init()
  require("Main.Pet.PetsArena.PetsArenaMgr").Instance():Init()
  require("Main.Pet.PetMark.PetMarkMgr").Instance():Init()
  self.pendingPetInfoReqList = {}
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, PetModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_PET_PROP_CLICK, PetModule.OnPetPropClick)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_USE_EQUIPMENT, PetModule.OnPetEquipmentUsed)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.OPEN_PET_PANEL_REQ, PetModule.OnAcceptOpenPetPanelReq)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.OPEN_PET_EQUIPMENT_OP_PANEL_REQ, PetModule.OnAcceptOpenPetEquipmentOPPanelReq)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_PROP_INIT, PetModule.OnHeroPropInit)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.OPEN_PET_EQUIPMENT_XILIAN_PANEL_REQ, PetModule.OnAcceptOpenPetEquipmentXILIANPanelReq)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE_WITH_REQUIREMENT, PetModule.OnAcceptTaskNPCService)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, PetModule.OnAcceptNPCService)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_TARGET_SERVICE, PetModule.OnAcceptNPCTargetService)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, PetModule.OnHeroLevelUp)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.SUMMON_PET, PetModule.OnSummonPet)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, PetModule.OnLeaveFight)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.OPEN_PET_BUY_PANEL, PetModule.OnReceiveOpenBuyPanelReq)
  Event.RegisterEvent(ModuleId.PETTEAM, gmodule.notifyId.PetTeam.PETTEAM_REDDOT_CHANGE, PetModule.OnPetTeamReddotChange)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.CLICK_PET_HEAD, PetModule.OnClickFightPetHead)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SSyncPetBagList", PetModule.OnSSyncPetBagList)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SSyncPetInfoChange", PetModule.OnSSyncPetInfoChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SSyncAddPet", PetModule.OnSSyncAddPet)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SExpandPetBagRes", PetModule.OnSExpandPetBagRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SSyncPetExpChange", PetModule.OnSSyncPetExpChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SSyncPetStateChange", PetModule.OnSSyncPetStateChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SPetNormalResult", PetModule.OnSPetNormalResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SSyncPetDepotInfo", PetModule.OnSSyncPetDepotInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.STransfomPetPlaceRes", PetModule.OnSTransfomPetPlaceRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SExpandPetDepotRes", PetModule.OnSExpandPetDepotRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SAutoAddPotentialPrefRes", PetModule.OnSAutoAddPotentialPrefRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SLianGuRes", PetModule.OnSLianGuRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SRemeberSkillRes", PetModule.OnSRememberSkillRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SRUnemeberSkillBookRes", PetModule.OnSUnremeberSkillBookRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SUseExpItemRes", PetModule.OnSUseExpItemRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SMergePetEquipRes", PetModule.OnSMergePetEquipRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SFanShengRes", PetModule.OnSFanShengRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SBuyPetRes", PetModule.OnSBuyPetRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SSellPetRes", PetModule.OnSSellPetRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SSyncPetShopCanSellNum", PetModule.OnSSyncPetShopCanSellNum)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SPetEquipItemRes", PetModule.OnSPetEquipItemRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SGetTargetPetInfoRes", PetModule.OnSGetPetInfoRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SGetPetItemLimitRes", PetModule.OnSGetPetItemLimitRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SReplacePetSkillSuccess", PetModule.OnSReplacePetSkillSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SPetStageLevelUpRes", PetModule.OnSPetStageLevelUpSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SSyncBanPetList", PetModule.OnSSyncBanPetList)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.STriggerMinimumGuarantee", PetModule.OnSTriggerMinimumGuarantee)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SHuaShengYuanBaoMakeUpViceInfoRsp", PetModule.OnSHuaShengYuanBaoMakeUpViceInfoRsp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SSWitchPetModelSuccess", PetModule.OnSSWitchPetModelSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SSWitchPetModelFailed", PetModule.OnSSWitchPetModelFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SDeletePetModelSuccess", PetModule.OnSDeletePetModelSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SDeletePetModelFailed", PetModule.OnSDeletePetModelFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SUsePetChangeModelItemSuccess", PetModule.OnSUsePetChangeModelItemSuccess)
  ModuleBase.Init(self)
end
def.static("table", "table").OnLeaveWorld = function(params, context)
  local self = instance
  self.notifyCount = -1
  _itemUseReqMap = nil
end
def.method("=>", "boolean").IsFightingPetCanAssignProp = function()
  local PetMgr = Lplus.ForwardDeclare("PetMgr")
  local pet = PetMgr.Instance():GetFightingPet()
  if pet == nil then
    return false
  end
  return pet:CanAssignProp()
end
def.method("=>", "boolean").IsFightingPetNeedAssignProp = function()
  local PetMgr = Lplus.ForwardDeclare("PetMgr")
  local pet = PetMgr.Instance():GetFightingPet()
  if pet == nil then
    return false
  end
  return pet:NeedAssignProp()
end
def.method("userdata", "userdata", "function").ReqPetInfo = function(self, roleId, petId, onResPetInfo)
  local strPetId = tostring(petId)
  local alreadyReq = false
  if self.pendingPetInfoReqList[strPetId] then
    alreadyReq = true
    local alreadyAdded = false
    for i, callback in ipairs(self.pendingPetInfoReqList) do
      if callback == onResPetInfo then
        alreadyAdded = true
        break
      end
    end
    if not alreadyAdded then
      table.insert(self.pendingPetInfoReqList[strPetId], onResPetInfo)
    end
    self:C2S_CGetTargetPetInfoReq(roleId, petId)
  else
    self.pendingPetInfoReqList[strPetId] = {}
    table.insert(self.pendingPetInfoReqList[strPetId], onResPetInfo)
    self:C2S_CGetTargetPetInfoReq(roleId, petId)
  end
end
def.method("userdata", "function").ReqPetItemUseLimit = function(self, petId, callback)
  _itemUseReqMap = _itemUseReqMap or {}
  local key = tostring(petId)
  if _itemUseReqMap[key] == nil then
    _itemUseReqMap[key] = {callback}
    print("CGetPetItemLimitReq", petId)
    local p = require("netio.protocol.mzm.gsp.pet.CGetPetItemLimitReq").new(petId)
    gmodule.network.sendProtocol(p)
  else
    table.insert(_itemUseReqMap[key], callback)
  end
end
def.method("userdata", "number", "table").RememberSkill = function(self, petId, skillId, extraParams)
  local rs = PetSkillMgr.Instance():RememberSkill(petId, skillId, extraParams)
  if rs == PetSkillMgr.CResult.HasRememberedSkill then
    Toast(textRes.Pet[10])
  end
end
def.method("userdata", "number").UnrememberSkill = function(self, petId, skillId)
  local rs = PetSkillMgr.Instance():UnrememberSkill(petId, skillId)
end
def.method("userdata").TogglePetFightingState = function(self, petId)
  local rs = PetMgr.Instance():TogglePetFightingState(petId)
  if rs == PetMgr.CResult.HERO_LEVEL_TOO_LOW then
    Toast(textRes.Pet[42])
  elseif rs == PetMgr.CResult.LIFE_TOO_SHORT then
    Toast(textRes.Pet[47])
  end
end
def.method("userdata").TogglePetDisplayState = function(self, petId)
  local rs = PetMgr.Instance():TogglePetDisplayState(petId)
  if rs == PetMgr.CResult.HERO_LEVEL_TOO_LOW then
    Toast(textRes.Pet[43])
  end
end
def.method("userdata").FreePet = function(self, petId)
  local pet = PetMgr.Instance():GetPet(petId)
  if pet == nil then
    warn(string.format("Attempt to free pet(%s), but it is not exist.", tostring(petId)))
    return
  end
  local petCfg = pet:GetPetCfgData()
  local function makePetFree(petId)
    PetMgr.Instance():MakePetFree(petId)
  end
  local function onConfirm(state, context)
    if state == 0 then
      return
    end
    local petId = context.petId
    local pet = PetMgr.Instance():GetPet(petId)
    if pet == nil then
      return
    end
    if PetMgr.Instance():IsNeededFreeProtection(petId) then
      local PetProtectionPanel = require("Main.Pet.ui.PetProtectionPanel")
      PetProtectionPanel.Instance():SetProtectOpertation(petId, makePetFree, textRes.Pet[160], textRes.Pet[158])
      PetProtectionPanel.Instance():ShowPanel()
    else
      makePetFree(petId)
    end
  end
  if pet.isFighting then
    Toast(textRes.Pet[56])
  elseif PetMgr.Instance():IsNeededFreeConfirm(petId) then
    require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Common[8], textRes.Pet[48], onConfirm, {petId = petId})
  else
    makePetFree(petId)
  end
end
def.method("=>", "boolean").IsPetHuaShengUnlock = function(self)
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  return heroProp.level >= self:GetPetHuaShengUnlockLevel()
end
def.method("=>", "number").GetPetHuaShengUnlockLevel = function(self)
  local PET_HUA_SHENG_UNLOCK_LEVEL = PetUtility.Instance():GetPetConstants("PET_HUASHENG_OPEN_LEVEL") or 45
  return PET_HUA_SHENG_UNLOCK_LEVEL
end
def.method("=>", "boolean").CheckPetHuaShengUnlockOK = function(self)
  if self:IsPetHuaShengUnlock() then
    return true
  end
  local text = string.format(textRes.Pet[130], self:GetPetHuaShengUnlockLevel())
  Toast(text)
  return false
end
local key = "PET_HUA_SHENG_FUNC_OPEN"
def.method("boolean").MarkPetHuaShengJustUnlock = function(self, state)
  local val = state and 1 or 0
  LuaPlayerPrefs.SetRoleInt(key, val)
end
def.method("=>", "boolean").IsPetHuaShengJustUnlock = function(self)
  return false
end
def.method("userdata", "userdata").C2S_CGetTargetPetInfoReq = function(self, roleId, petId)
  local p = require("netio.protocol.mzm.gsp.pet.CGetTargetPetInfoReq").new(roleId, petId)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSGetPetInfoRes = function(p)
  local reqList = instance.pendingPetInfoReqList[tostring(p.petInfo.petId)]
  if reqList == nil then
    return
  end
  for i, callback in ipairs(reqList) do
    callback(p.petInfo)
  end
  instance.pendingPetInfoReqList[tostring(p.petInfo.petId)] = nil
end
def.static("table").OnSGetPetItemLimitRes = function(p)
  print("OnSGetPetItemLimitRes", p.petId)
  if _itemUseReqMap == nil then
    return
  end
  local key = tostring(p.petId)
  if _itemUseReqMap[key] == nil then
    return
  end
  for i, v in ipairs(_itemUseReqMap[key]) do
    v(p)
  end
  _itemUseReqMap[key] = nil
end
def.static("table").OnSReplacePetSkillSuccess = function(p)
  local pet = PetMgr.Instance():GetPet(p.petId)
  if pet ~= nil then
    local petName = pet.name
    Toast(string.format(textRes.Pet[163], petName))
  end
end
def.static("table").OnSPetStageLevelUpSuccess = function(p)
  local pet = PetMgr.Instance():GetPet(p.petId)
  if pet ~= nil then
    local petName = pet.name
    Toast(string.format(textRes.Pet[177], petName))
  end
end
def.method().InitTuJianCfg = function(self)
  if self.tuJianCfg then
    return
  end
  local HUGE_LEVEL = 999999
  local tujianPets = PetUtility.GetTuJianPets(PetTuJianPage.NORMAL_PAGE, HUGE_LEVEL)
  self.tuJianCfg = {}
  for i, v in ipairs(tujianPets) do
    local petRefIdList = self.tuJianCfg[v.carrayLevel]
    petRefIdList = petRefIdList or {}
    table.insert(petRefIdList, v.petTypeRefId)
    self.tuJianCfg[v.carrayLevel] = petRefIdList
  end
end
def.method("=>", "number").GetNotifyCount = function(self)
  if self.notifyCount == -1 then
    self:CheckNotify()
  end
  return self.notifyCount
end
def.method("=>", "boolean").HasNotify = function(self)
  return self:GetNotifyCount() > 0
end
def.method().CheckNotify = function(self)
  local notifyCount = 0
  if self:IsFightingPetNeedAssignProp() then
    notifyCount = notifyCount + 1
  end
  if self:IsPetHuaShengJustUnlock() then
    notifyCount = notifyCount + 1
  end
  if require("Main.PetTeam.PetTeamModule").Instance():NeedReddot() then
    notifyCount = notifyCount + 1
  end
  if notifyCount ~= self.notifyCount then
    local lastNotifyCount = self.notifyCount
    self.notifyCount = notifyCount
    Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_NOTIFY_COUNT_UPDATE, {notifyCount, lastNotifyCount})
  end
end
def.method("=>", "boolean").HasNewPetNotice = function(self)
  self:InitTuJianCfg()
  local PetMgr = require("Main.Pet.mgr.PetMgr")
  local tuJianRecords = PetMgr.Instance():GetPetTuJianRecords()
  local heroLevel = require("Main.Hero.Interface").GetHeroProp().level
  for carrayLevel, v in pairs(self.tuJianCfg) do
    if carrayLevel <= heroLevel then
      for i, petTypeRefId in ipairs(v) do
        if tuJianRecords[petTypeRefId] == nil then
          return true
        end
      end
    end
  end
  return false
end
def.method("number").TryToExpandPetBag = function(self, bagId)
  local PetUtility = require("Main.Pet.PetUtility")
  local curCapacity
  if bagId == PetModule.PET_BAG_ID then
    local PetMgr = require("Main.Pet.mgr.PetMgr")
    curCapacity = PetMgr.Instance():GetBagSize()
  elseif bagId == PetModule.PET_STORAGE_BAG_ID then
    local PetStorageMgr = require("Main.Pet.mgr.PetStorageMgr")
    curCapacity = PetStorageMgr.Instance():GetStorageCapacity()
  end
  PetUtility.TryToExpandPetBag(bagId, curCapacity)
end
def.method().GoToPetStorageNPC = function(self)
  local npcId = PetModule.PET_STORAGE_NPC_ID
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_NPC, {npcId})
end
def.method().ShowPetBagIsFullConfirm = function(self)
  require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Common[8], textRes.Pet[134], function(s)
    if s == 1 then
      require("GUI.ECGUIMan").Instance():DestroyUIAtLevel(1)
      self:GoToPetStorageNPC()
    end
  end, {
    unique = self.ShowPetBagIsFullConfirm
  })
end
def.static("table", "table").OnPetPropClick = function()
  require("Main.Pet.ui.PetPanel").Instance():ShowPanel()
end
def.static("table", "table").OnPetEquipmentUsed = function(param1, param2)
  require("Main.Pet.ui.PetPanel").Instance():ShowPanel()
end
def.static("table", "table").OnAcceptOpenPetPanelReq = function(params, param2)
  local nodeId = params.nodeId or NodeId.BasicNode
  local subNodeId = params.subNodeId or NodeId.SubNode.None
  local uiPath = params.uiPath
  local PetPanel = require("Main.Pet.ui.PetPanel")
  PetPanel.Instance():ShowPanelExWithSubNode(nodeId, subNodeId)
  if uiPath then
    local GUIUtils = require("GUI.GUIUtils")
    local light = params.light or GUIUtils.Light.Square
    GUIUtils.AddLightEffectToPanel(uiPath, light)
  end
end
def.static("table", "table").OnAcceptOpenPetEquipmentOPPanelReq = function(param1, param2)
  require("Main.Pet.ui.PetEquipmentOPPanel").Instance():ShowPanel()
end
def.static("table", "table").OnAcceptOpenPetEquipmentXILIANPanelReq = function(param1, param2)
  local PetEquipmentOPPanel = require("Main.Pet.ui.PetEquipmentOPPanel")
  PetEquipmentOPPanel.Instance():SetActivePage(PetEquipmentOPPanel.Page.Refresh)
  PetEquipmentOPPanel.Instance():ShowPanel()
end
def.static("table", "table").OnAcceptTaskNPCService = function(params, param2)
  local PetUtility = require("Main.Pet.PetUtility")
  local npcId = PetUtility.Instance():GetPetConstants("PETSHOP_NPC_ID")
  local serviceID = params[1]
  local npcID = params[2]
  local taskFindPathRequirementID = params[3]
  local taskFindPathNeedCount = params[4]
  if serviceID == PetModule.PET_SHOP_BUY_SERVICE then
    require("Main.Pet.ui.PetShopBuyPanel").Instance():SetNeededPetTemplateId(taskFindPathRequirementID, true)
    require("Main.Pet.ui.PetShopBuyPanel").Instance():ShowPanel()
  elseif serviceID == PetModule.PET_SHOP_SELL_SERVICE then
    require("Main.Pet.ui.PetShopSellPanel").Instance():ShowPanel()
  end
end
def.static("table", "table").OnAcceptNPCService = function(params, param2)
  local PetUtility = require("Main.Pet.PetUtility")
  local serviceID = params[1]
  local NPCID = params[2]
  if serviceID == PetModule.PET_SHOP_BUY_SERVICE then
    require("Main.Pet.ui.PetShopBuyPanel").Instance():ShowPanel()
  elseif serviceID == PetModule.PET_SHOP_SELL_SERVICE then
    require("Main.Pet.ui.PetShopSellPanel").Instance():ShowPanel()
  elseif serviceID == PetModule.PET_STORAGE_SERVICE then
    require("Main.Pet.ui.PetStoragePanel").Instance():ShowPanel()
  elseif serviceID == PetModule.PET_FREE_SERVICE then
    local PetUIMgr = require("Main.Pet.PetUIMgr")
    local params = {}
    params.nodeId = NodeId.BasicNode
    params.uiPath = PetUIMgr.UIPath.FreePetBtn
    Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.OPEN_PET_PANEL_REQ, params)
  end
end
def.static("table", "table").OnAcceptNPCTargetService = function(params, param2)
  local PetUtility = require("Main.Pet.PetUtility")
  local neededNpcId = PetUtility.Instance():GetPetConstants("PETSHOP_NPC_ID")
  local serviceID = params[1]
  local NPCID = params[2]
  local userParam = params[3]
  if NPCID ~= neededNpcId then
    return
  end
  if serviceID == PetModule.PET_SHOP_BUY_SERVICE then
    require("Main.Pet.ui.PetShopBuyPanel").Instance():SetNeededPetTemplateId(userParam[1], false)
    require("Main.Pet.ui.PetShopBuyPanel").Instance():ShowPanel()
  elseif serviceID == PetModule.PET_SHOP_SELL_SERVICE then
    require("Main.Pet.ui.PetShopSellPanel").Instance():ShowPanel()
  end
end
def.static("table", "table").OnHeroPropInit = function(param1, param2)
  local self = instance
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  self._tuJianLastHeroLevel = heroProp.level
end
def.static("table", "table").OnHeroLevelUp = function(param1, param2)
  local self = instance
  local curLevel, lastLevel = param1.level, param1.lastLevel
  local unlockLevel = self:GetPetHuaShengUnlockLevel()
  if lastLevel < unlockLevel and curLevel >= unlockLevel then
    self:MarkPetHuaShengJustUnlock(true)
  end
  self:CheckNotify()
end
def.static("table", "table").OnSummonPet = function(param1, param2)
  local PetMgr = require("Main.Pet.mgr.PetMgr")
  if param1 ~= nil and param1.unit_type == GameUnitType.PET then
    PetMgr.Instance():SetInFightScenePet(param1.unit_id)
  end
end
def.static("table", "table").OnLeaveFight = function(param1, param2)
  local PetMgr = require("Main.Pet.mgr.PetMgr")
  PetMgr.Instance():CheckSupplementPetLifeEvent()
  PetMgr.Instance():ClearInFightScenePet()
end
def.static("table", "table").OnReceiveOpenBuyPanelReq = function(params, context)
  if params ~= nil then
    local petTemplateId = params[1]
    if petTemplateId ~= nil then
      require("Main.Pet.ui.PetShopBuyPanel").Instance():SetNeededPetTemplateId(petTemplateId, false)
    end
  end
  require("Main.Pet.ui.PetShopBuyPanel").Instance():ShowPanel()
end
def.static("table", "table").OnPetTeamReddotChange = function(param, context)
  local self = instance
  if self then
    self:CheckNotify()
  end
end
def.static("table", "table").OnClickFightPetHead = function(param, context)
  local petId = param.id
  local PetMgr = require("Main.Pet.mgr.PetMgr")
  if petId ~= nil and PetMgr.Instance():GetPet(petId) then
    require("Main.Pet.ui.PetPanel").Instance():ShowPanelWithPetId(petId)
  else
    warn("Click fight pet not exist", petId)
  end
end
def.static("table").OnSSyncPetBagList = function(data)
  local PetMgr = require("Main.Pet.mgr.PetMgr").Instance()
  PetMgr.fightPetId = data.fightPetId
  PetMgr.displayPetId = data.showPetId
  PetMgr.bagSize = data.bagSize
  PetMgr.expandCount = data.expandCount or 0
  PetMgr:SetPetList(data.petList)
end
def.static("table").OnSSyncPetInfoChange = function(data)
  local pet = require("Main.Pet.mgr.PetStorageMgr").Instance():GetPet(data.petInfo.petId)
  if pet ~= nil then
    pet:RawSet(data.petInfo)
  else
    local PetMgr = require("Main.Pet.mgr.PetMgr").Instance()
    PetMgr:UpdatePetInfo(data.petInfo)
    Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_INFO_UPDATE, {
      data.petInfo.petId
    })
  end
end
def.static("table").OnSSyncAddPet = function(data)
  local PetMgr = require("Main.Pet.mgr.PetMgr").Instance()
  PetMgr:RawAddPet(data.petInfo)
end
def.static("table").OnSSyncPetStateChange = function(data)
  local PetMgr = require("Main.Pet.mgr.PetMgr").Instance()
  PetMgr:UpdatePetState(data.petId, data.state)
end
def.static("table").OnSPetNormalResult = function(data)
  if data.result == data.class.PET_DECORATE_SUCCESS then
    Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_DECORATE_SUCCESS, nil)
  elseif data.result == data.class.PET_BAG_FULL then
    instance:ShowPetBagIsFullConfirm()
  else
    if data.class.PET_REFRESH_AMULET_SUCCESS == data.result then
      Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_REFRESH_AMULET_SUCCESS, nil)
    end
    if data.class.PET_HUASHENG_SUCCESS == data.result then
      Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_HUASHENG_SUCCESS, nil)
    end
    local text = textRes.Pet.SPetNormalResult[data.result]
    if text then
      Toast(text)
    end
  end
end
def.static("table").OnSSyncPetDepotInfo = function(data)
  local PetStorageMgr = require("Main.Pet.mgr.PetStorageMgr").Instance()
  PetStorageMgr.storageCapacity = data.depotSize
  PetStorageMgr:SetPetList(data.petList)
end
def.static("table").OnSTransfomPetPlaceRes = function(data)
  local PetStorageMgr = require("Main.Pet.mgr.PetStorageMgr").Instance()
  local PetMgr = require("Main.Pet.mgr.PetMgr").Instance()
  if data.target == data.class.TARGET_BAG then
    local pet = PetStorageMgr:GetPet(data.petId)
    PetMgr:AddPet(pet)
    PetStorageMgr:RemovePet(data.petId)
  elseif data.target == data.class.TARGET_DEPOT then
    local pet = PetMgr:GetPet(data.petId)
    PetStorageMgr:AddPet(pet)
    PetMgr:RemovePet(data.petId)
  end
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_STORE_POS_UPDATE, {
    data.petId
  })
end
def.static("table").OnSExpandPetDepotRes = function(data)
  local PetStorageMgr = require("Main.Pet.mgr.PetStorageMgr").Instance()
  PetStorageMgr.storageCapacity = data.depotSize
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_STORAGE_CAPACITY_CHANGE, {
    data.depotSize
  })
  Toast(textRes.Pet[91])
end
def.static("table").OnSAutoAddPotentialPrefRes = function(data)
  require("Main.Pet.mgr.PetAssignPropMgr").Instance():OnSAutoAddPotentialPrefRes(data)
end
def.static("table").OnSLianGuRes = function(data)
  require("Main.Pet.mgr.PetMgr").Instance():OnSLianGuRes(data)
end
def.static("table").OnSExpandPetBagRes = function(data)
  local PetMgr = require("Main.Pet.mgr.PetMgr").Instance()
  PetMgr.bagSize = data.bagSize
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_BAG_CAPACITY_CHANGE, {
    data.bagSize
  })
  Toast(textRes.Pet[91])
end
def.static("table").OnSRememberSkillRes = function(data)
  local PetSkillMgr = require("Main.Pet.mgr.PetSkillMgr").Instance()
  PetSkillMgr:SetSkillRemembered(data.petId, data.skillId)
end
def.static("table").OnSUnremeberSkillBookRes = function(data)
  local PetSkillMgr = require("Main.Pet.mgr.PetSkillMgr").Instance()
  PetSkillMgr:SetSkillUnremembered(data.petId, data.skillId)
end
def.static("table").OnSUseExpItemRes = function(data)
  local pet = PetMgr.Instance():GetPet(data.petId)
  if pet then
    local petName = pet.name
    local exp = data.addExp
    require("Main.Chat.PersonalHelper").GetPetExp(petName, exp)
  else
    warn(string.format("OnSUseExpItemRes petId = %s not exist", tostring(data.petId)))
  end
end
def.static("table").OnSSyncPetExpChange = function(data)
  local PetMgr = require("Main.Pet.mgr.PetMgr").Instance()
  PetMgr:AddPetExp(data.petId, data.addExp)
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_INFO_UPDATE, {
    data.petId
  })
end
def.static("table").OnSMergePetEquipRes = function(data)
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.SUCCESS_COMPOSITE_EQUIPMENT, {
    data.itemKey
  })
end
def.static("table").OnSFanShengRes = function(data)
  local PetMgr = require("Main.Pet.mgr.PetMgr").Instance()
  PetMgr:PetFanSheng(data.oldPetId, data.newPetInfo)
  Toast(textRes.Pet.SPetNormalResult[13])
end
def.static("table").OnSBuyPetRes = function(data)
  require("Main.Pet.mgr.PetShopMgr").Instance():BuyPetSuccess(data)
end
def.static("table").OnSSellPetRes = function(data)
  require("Main.Pet.mgr.PetShopMgr").Instance():SellPetSuccess(data)
end
def.static("table").OnSSyncPetShopCanSellNum = function(data)
  require("Main.Pet.mgr.PetShopMgr").Instance():SetCanSellPetAmount(data.canSellNum)
end
def.static("table").OnSPetEquipItemRes = function(p)
  local petId, wearPos = p.petId, p.wearPos
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_USE_EQUIPMENT_SUCCESS, {petId, wearPos})
end
def.static("table").OnSSyncBanPetList = function(p)
  require("Main.Pet.mgr.PetShopMgr").Instance():SetBanPetList(p.banPetList)
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_SELL_LIST_CHANGED, nil)
end
def.static("table").OnSTriggerMinimumGuarantee = function(p)
  Toast(string.format(textRes.Pet[232], p.guarantee_skill_num))
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_HUASHENG_GUARANTEE, nil)
end
def.static("table").OnSHuaShengYuanBaoMakeUpViceInfoRsp = function(p)
  local petInfo = {}
  petInfo.petId = p.mainPetId
  petInfo.viceCfgId = p.viceCfgId
  petInfo.needYuanBaoCount = p.needYuanBaoCount
  petInfo.skillCount = p.skillCount
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_YUANBAO_MAKE_PRICE, petInfo)
end
def.static("table").OnSSWitchPetModelSuccess = function(p)
  local pet = PetMgr.Instance():GetPet(p.pet_id)
  if pet == nil then
    return
  end
  pet:SwitchToExtraModel(p.item_cfg_id)
  Toast(textRes.Pet[254])
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_INFO_UPDATE, {
    p.pet_id
  })
end
def.static("table").OnSSWitchPetModelFailed = function(p)
  if textRes.Pet.SSWitchPetModelFailed[p.retcode] then
    Toast(textRes.Pet.SSWitchPetModelFailed[p.retcode])
  else
    Toast(string.format(textRes.Pet.SSWitchPetModelFailed[0], p.retcode))
  end
end
def.static("table").OnSDeletePetModelSuccess = function(p)
  local pet = PetMgr.Instance():GetPet(p.pet_id)
  if pet == nil then
    return
  end
  pet:DeleteExtraModel(p.item_cfg_id)
  Toast(textRes.Pet[255])
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_INFO_UPDATE, {
    p.pet_id
  })
end
def.static("table").OnSDeletePetModelFailed = function(p)
  if textRes.Pet.SDeletePetModelFailed[p.retcode] then
    Toast(textRes.Pet.SDeletePetModelFailed[p.retcode])
  else
    Toast(string.format(textRes.Pet.SDeletePetModelFailed[0], p.retcode))
  end
end
def.static("table").OnSUsePetChangeModelItemSuccess = function(p)
  local pet = PetMgr.Instance():GetPet(p.pet_id)
  if pet == nil then
    return
  end
  require("Main.Pet.ui.PetExtraModelPanel").Instance():ShowPanel(p.pet_id)
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_UNLOCK_NEW_EXTRAM_MODEL, {
    p.pet_id
  })
end
PetModule.Commit()
return PetModule
