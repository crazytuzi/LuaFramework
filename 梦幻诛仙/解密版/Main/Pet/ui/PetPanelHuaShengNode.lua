local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PetPanelNodeBase = require("Main.Pet.ui.PetPanelNodeBase")
local PetPanelHuaShengNode = Lplus.Extend(PetPanelNodeBase, "PetPanelHuaShengNode")
local PetMgr = require("Main.Pet.mgr.PetMgr")
local PetUtility = require("Main.Pet.PetUtility")
local PetData = Lplus.ForwardDeclare("PetData")
local EC = require("Types.Vector3")
local Vector3 = EC.Vector3
local ECModel = require("Model.ECModel")
local GUIUtils = require("GUI.GUIUtils")
local PetModule = require("Main.Pet.PetModule")
local PetType = require("consts.mzm.gsp.pet.confbean.PetType")
local PetSkillMgr = require("Main.Pet.mgr.PetSkillMgr")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local EasyItemTipHelper = require("Main.Pet.EasyItemTipHelper")
local MountsMgr = require("Main.Mounts.mgr.MountsMgr")
local PetFastLearnSkillPanel = require("Main.Pet.ui.PetFastLearnSkillPanel")
local def = PetPanelHuaShengNode.define
local HSListType = {
  NOT_SET = 0,
  MAIN_PET_LIST = 1,
  SUB_PET_LIST = 2
}
def.const("table").equipmentSlotOrder = {
  PetData.PetEquipmentType.EQUIP_NECKLACE,
  PetData.PetEquipmentType.EQUIP_HELMET,
  PetData.PetEquipmentType.EQUIP_AMULET
}
def.field("table").hsPetList = nil
def.field("number").hsSelectedPetIndex = 0
def.field("number").hsListType = HSListType.NOT_SET
def.field(PetData).hsMainPet = nil
def.field(PetData).hsSubPet = nil
def.field("table").hsMainPetModel = nil
def.field("table").hsSubPetModel = nil
def.field("number").selectedMSkillId = 0
def.field("userdata").displaySilverMoney = nil
def.field("number").displayHuaShengItemNum = 0
def.field("table").huaShengConsume = nil
def.field("table").catchedHuaShengNeed = nil
def.field(EasyItemTipHelper).easyItemTipHelper = nil
def.field("table").uiObjs = nil
def.field("boolean").canRemember = false
def.field("boolean").canUnremember = false
def.field("boolean").isShowing = false
def.field("number").needYuanBao = 0
def.field("boolean").useYuanBao = false
def.field("number").needFanShengCount = 0
def.field("boolean").useGeneralEnsure = false
def.field("number").needGeneralEnsureCount = 0
def.field("boolean").useHighEnsure = false
def.field("number").needHighEnsureCount = 0
def.field("table").yuanbaoItemPrice = nil
def.field("boolean").useYuanBaoMakePet = false
def.field("number").makePetPrice = 0
local instance
def.static("=>", PetPanelHuaShengNode).Instance = function()
  if instance == nil then
    instance = PetPanelHuaShengNode()
  end
  return instance
end
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  PetPanelNodeBase.Init(self, base, node)
end
def.override("=>", "boolean").HasNotify = function(self)
  return PetModule.Instance():IsPetHuaShengJustUnlock()
end
def.method().CheckAndReadNotify = function(self)
  if self:HasNotify() then
    PetModule.Instance():MarkPetHuaShengJustUnlock(false)
    PetModule.Instance():CheckNotify()
  end
end
def.override().OnShow = function(self)
  local PetPanelBasicNode = require("Main.Pet.ui.PetPanelBasicNode")
  if self.isShowing then
    self.uiObjs.hsFX:SetActive(false)
    self.uiObjs.LearnSkillFX:SetActive(false)
    GUIUtils.SetActive(self.uiObjs.HuaShengGuaranteeFX, false)
    return
  end
  self:CheckAndReadNotify()
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, PetPanelHuaShengNode.OnBagSilverMoneyChanged)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_REMEMBERED_SKILL_SUCCESS, PetPanelHuaShengNode.OnPetRememberedSkillSuccess)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_UNREMEMBERED_SKILL_SUCCESS, PetPanelHuaShengNode.OnPetUnrememberedSkillSuccess)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_YAOLI_CHANGE, PetPanelHuaShengNode.OnPetYaoLiChange)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_INFO_UPDATE, PetPanelHuaShengNode.OnPetInfoUpdate)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_LEARN_SKILL_SUCCESS, PetPanelHuaShengNode.OnPetLearnSkillSuccess)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_HUASHENG_GUARANTEE, PetPanelHuaShengNode.OnPetHuaShengGuarantee)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_YUANBAO_MAKE_PRICE, PetPanelHuaShengNode.OnPetYuanBaoMakePrice)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_HUASHENG_SUCCESS, PetPanelHuaShengNode.OnPetHuaShengSuccess)
  self.isShowing = true
end
def.override().OnHide = function(self)
  self.isShowing = false
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, PetPanelHuaShengNode.OnBagSilverMoneyChanged)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_REMEMBERED_SKILL_SUCCESS, PetPanelHuaShengNode.OnPetRememberedSkillSuccess)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_UNREMEMBERED_SKILL_SUCCESS, PetPanelHuaShengNode.OnPetUnrememberedSkillSuccess)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_YAOLI_CHANGE, PetPanelHuaShengNode.OnPetYaoLiChange)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_INFO_UPDATE, PetPanelHuaShengNode.OnPetInfoUpdate)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_LEARN_SKILL_SUCCESS, PetPanelHuaShengNode.OnPetLearnSkillSuccess)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_HUASHENG_GUARANTEE, PetPanelHuaShengNode.OnPetHuaShengGuarantee)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_YUANBAO_MAKE_PRICE, PetPanelHuaShengNode.OnPetYuanBaoMakePrice)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_HUASHENG_SUCCESS, PetPanelHuaShengNode.OnPetHuaShengSuccess)
  self.easyItemTipHelper = nil
  self.uiObjs = nil
  self.needYuanBao = 0
  self.useYuanBao = false
  self.needFanShengCount = 0
  self.useGeneralEnsure = false
  self.needGeneralEnsureCount = 0
  self.useHighEnsure = false
  self.needHighEnsureCount = 0
  self.yuanbaoItemPrice = nil
  self.useYuanBaoMakePet = false
  self.makePetPrice = 0
  self:CheckAndReadNotify()
end
def.override().InitUI = function(self)
  PetPanelNodeBase.InitUI(self)
  self.uiObjs = {}
  self.uiObjs.Img_HS_BgHS = self.m_node:FindDirect("Img_HS_BgHS")
  self.uiObjs.Img_HS_BgCompare = self.m_node:FindDirect("Img_HS_BgCompare")
  self.uiObjs.Img_HS_Bg01 = self.uiObjs.Img_HS_BgCompare:FindDirect("Img_HS_Bg01")
  self.uiObjs.Group_Empty1 = self.uiObjs.Img_HS_Bg01:FindDirect("Group_Empty01")
  self.uiObjs.Img_HS_BgPetInfo01 = self.uiObjs.Img_HS_Bg01:FindDirect("Img_HS_BgPetInfo01")
  self.uiObjs.Img_HS_BgSkillGroup01 = self.uiObjs.Img_HS_Bg01:FindDirect("Img_HS_BgSkillGroup01/Scroll View_Hs1")
  self.uiObjs.Btn_Preview = self.uiObjs.Img_HS_BgPetInfo01:FindDirect("Btn_Preview")
  self.uiObjs.Img_HS_Bg02 = self.uiObjs.Img_HS_BgCompare:FindDirect("Img_HS_Bg02")
  self.uiObjs.Group_Empty2 = self.uiObjs.Img_HS_Bg02:FindDirect("Group_Empty02")
  self.uiObjs.Img_HS_BgPetInfo02 = self.uiObjs.Img_HS_Bg02:FindDirect("Img_HS_BgPetInfo02")
  self.uiObjs.Img_HS_BgSkillGroup02 = self.uiObjs.Img_HS_Bg02:FindDirect("Img_HS_BgSkillGroup02/Scroll View")
  self.uiObjs.Btn_HS_MingJi = self.uiObjs.Img_HS_BgHS:FindDirect("Btn_HS_MingJi")
  self.uiObjs.Img_HS_BgMJItem01 = self.uiObjs.Img_HS_BgHS:FindDirect("Img_HS_BgMJItem01")
  self.uiObjs.Group_Remove = self.uiObjs.Img_HS_BgHS:FindDirect("Group_Remove")
  self.uiObjs.hsFX = self.m_node:FindDirect("UI_Panel_Pet_HS")
  self.uiObjs.hsFX:SetActive(false)
  self.uiObjs.LearnSkillFX = self.m_node:FindDirect("UI_Panel_PetSkill_ChongWuDaShu")
  self.uiObjs.LearnSkillFX:SetActive(false)
  self.uiObjs.Img_HS_BgHSBDItem01 = self.uiObjs.Img_HS_BgHS:FindDirect("Img_HS_BgHSBDItem01")
  self.uiObjs.Group_UseDep = self.uiObjs.Img_HS_BgHS:FindDirect("Group_UseDep")
  self.uiObjs.Group_SkillInfo = self.uiObjs.Img_HS_BgHS:FindDirect("Group_SkillInfo")
  self.uiObjs.Btn_LowUseGold = self.uiObjs.Img_HS_BgHSBDItem01:FindDirect("Group_LowItem/Btn_LowUseGold")
  self.uiObjs.Btn_HighUseGold = self.uiObjs.Img_HS_BgHSBDItem01:FindDirect("Group_HighItem/Btn_HighUseGold")
  self.uiObjs.Btn_HS_Make = self.uiObjs.Img_HS_BgHS:FindDirect("Btn_HS_Make")
  self.uiObjs.Group_UseDep = self.uiObjs.Img_HS_BgHS:FindDirect("Group_UseDep")
  self.uiObjs.Btn_UseDep = self.uiObjs.Group_UseDep:FindDirect("Btn_UseDep")
  self.uiObjs.Group_UseDep2ndPet = self.uiObjs.Img_HS_BgHS:FindDirect("Group_UseDep2ndPet")
  self.uiObjs.Btn_UseDep2ndPet = self.uiObjs.Group_UseDep2ndPet:FindDirect("Btn_UseDep2ndPet")
  self.uiObjs.HuaShengGuaranteeFX = self.m_node:FindDirect("UI_Fx_ChengGong")
  GUIUtils.SetActive(self.uiObjs.HuaShengGuaranteeFX, false)
  self.easyItemTipHelper = EasyItemTipHelper()
end
def.override("string").onClick = function(self, id)
  if id == "Img_HS_BgChoose01" then
    self:OnMainPetSelected()
  elseif id == "Img_HS_BgChoose02" then
    self:OnSubPetSelected()
  elseif id == "Btn_HS_Make" then
    self:OnHuaShengButtonClick()
  elseif id == "Btn_HS_Cancel" then
    self:OnCancelPetSelect()
  elseif id == "Btn_HS_Confirm" then
    self:OnConfirmPetSelect()
  elseif string.sub(id, 1, 7) == "Pet_HS_" then
    self:OnPetClick(id)
  elseif id == "Img_HS_BgPet01" then
    self:OnMainPetSelected()
  elseif id == "Img_HS_BgPet02" then
    self:OnSubPetSelected()
  elseif id == "Btn_HS_Close01" then
    self:OnMainPetUnselected()
  elseif id == "Btn_HS_Close02" then
    self:OnSubPetUnselected()
  elseif id == "Btn_HS_Tips" then
    self:OnHuaShengTipButtonClicked()
  elseif string.sub(id, 1, #"Img_HS_BgSkill01_") == "Img_HS_BgSkill01_" then
    local index = tonumber(string.sub(id, #"Img_HS_BgSkill01_" + 1, -1))
    self:OnMainPetSkillClicked(index)
  elseif string.sub(id, 1, #"Img_HS_BgSkill02_") == "Img_HS_BgSkill02_" then
    local index = tonumber(string.sub(id, #"Img_HS_BgSkill02_" + 1, -1))
    self:OnSubPetSkillClicked(index)
  elseif self.easyItemTipHelper:CheckItem2ShowTip(id) then
  elseif id == "Btn_HS_MingJi" then
    self:OnRemenberSkillButtonClicked()
  elseif id == "Btn_Remove" then
    self:OnUnrememberButtonClicked()
  elseif id == "Btn_Preview" then
    self:OnPreviewButtonClicked()
  elseif id == "Btn_FastLearn" then
    self:OnFastLearnButtonClicked()
  elseif id == "Btn_LowUseGold" then
    self:OnLowEnsureButtonClicked()
  elseif id == "Btn_HighUseGold" then
    self:OnHighEnsureButtonClicked()
  elseif id == "Btn_UseDep" then
    self:OnUseYuanbaoButtonClicked()
  elseif id == "Btn_UseDep2ndPet" then
    self:OnUseYuanbaoMakePetClicked()
  end
end
def.method().OnMainPetSelected = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  if not PetModule.Instance():CheckPetHuaShengUnlockOK() then
    return
  end
  self.hsListType = HSListType.MAIN_PET_LIST
  self:OpenPetList()
  self:UpdateAvailablePetList()
end
def.method().OnSubPetSelected = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  if not PetModule.Instance():CheckPetHuaShengUnlockOK() then
    return
  end
  self.hsListType = HSListType.SUB_PET_LIST
  self:OpenPetList()
  self:UpdateAvailablePetList()
end
def.method().OnMainPetUnselected = function(self)
  self.hsMainPet = nil
  self:UpdateHuaShengNeeded()
  self:UpdateHuaShengEnsureInfo()
  self:UpdateHuaShengYuanBao()
  self:UpdateMainPet()
  self:UpdateAvailablePetList()
end
def.method().OnSubPetUnselected = function(self)
  self.hsSubPet = nil
  self:UpdateHuaShengNeeded()
  self:UpdateHuaShengEnsureInfo()
  self:UpdateHuaShengYuanBao()
  self:UpdateSubPet()
  self:UpdateAvailablePetList()
end
def.method().UpdateAvailablePetList = function(self)
  local mainPetId
  if self.hsMainPet then
    mainPetId = self.hsMainPet.id
  end
  local subPetId
  if self.hsSubPet then
    subPetId = self.hsSubPet.id
  end
  local titleText
  if self.hsListType == HSListType.MAIN_PET_LIST then
    self.hsPetList = PetMgr.Instance():GetHuaShengMainPets(mainPetId, subPetId)
    titleText = textRes.Pet[99]
  else
    self.hsPetList = PetMgr.Instance():GetHuaShengSubPets(mainPetId, subPetId)
    titleText = textRes.Pet[100]
  end
  require("Main.Pet.ui.PetSelectPanel").Instance():ShowPanel(self.hsPetList, titleText, function(index, pet, userParams)
    self.hsSelectedPetIndex = index
    self:OnConfirmPetSelect()
  end, nil)
end
def.method().OnCancelPetSelect = function(self)
  self.hsSelectedPetIndex = 0
  self.m_panel:FindChild("PetList_HS"):SetActive(false)
  self.m_panel:FindChild("Pannel_HS_PetInfo"):SetActive(false)
end
def.method().OnConfirmPetSelect = function(self)
  if self.uiObjs == nil then
    return
  end
  if self.hsSelectedPetIndex == 0 then
    return
  end
  if self.hsListType == HSListType.MAIN_PET_LIST then
    self.hsMainPet = self.hsPetList[self.hsSelectedPetIndex]
    self.m_base.selectedPetId = self.hsMainPet.id
    self:UpdateMainPet()
    if self.hsMainPet ~= nil and #self.hsMainPet:GetSkillIdList() == 10 then
      self:RemoveFakeSubPet()
    end
  elseif self.hsListType == HSListType.SUB_PET_LIST then
    self.hsSubPet = self.hsPetList[self.hsSelectedPetIndex]
    self.useYuanBaoMakePet = false
    self.makePetPrice = 0
    self:UpdateSubPet()
  end
  self.hsPetList = nil
  self.hsSelectedPetIndex = 0
  self:UpdateHuaShengNeeded()
  self:UpdateHuaShengEnsureInfo()
  self:UpdateHuaShengYuanBao()
  self:UpdatePreviewBtnVisibility()
end
def.method().OpenPetList = function(self)
end
def.method("string").OnPetClick = function(self, id)
end
def.method().OnHuaShengButtonClick = function(self, id)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local function HuaShengReq(extraParams)
    local costType = PetMgr.CostType.UseItem
    local needYuanbao = 0
    if extraParams and extraParams.isYuanBaoBuZu then
      costType = PetMgr.CostType.UseYuanBao
    end
    if extraParams and extraParams.needYuanbao then
      needYuanbao = extraParams.needYuanbao
    end
    if self.useYuanBaoMakePet then
      costType = PetMgr.CostType.UseYuanBao
      needYuanbao = needYuanbao + self.makePetPrice
    end
    local yuanBaoNum = ItemModule.Instance():GetAllYuanBao()
    if Int64.lt(yuanBaoNum, needYuanbao) then
      _G.GotoBuyYuanbao()
      return
    end
    PetMgr.Instance():HuaShengReq(self.hsMainPet.id, self.hsSubPet.id, costType, needYuanbao)
  end
  local function AskYuanBaoSupplement()
    local desc = string.format(textRes.Pet[125])
    local title, extendItemId, itemNeed = textRes.Pet[124], self.huaShengConsume.itemId, self.huaShengConsume.useItemNum
    local ItemConsumeHelper = require("Main.Item.ItemConsumeHelper")
    ItemConsumeHelper.Instance():ShowItemConsume(title, desc, extendItemId, itemNeed, function(select)
      if self.uiObjs == nil then
        warn("AskYuanBaoSupplement failed, because pet HuaSheng page is closed!!!")
        return
      end
      if select < 0 then
      elseif select == 0 then
        HuaShengReq({isYuanBaoBuZu = false, needYuanbao = select})
      else
        HuaShengReq({isYuanBaoBuZu = true, needYuanbao = select})
      end
    end)
  end
  local function AskLowSuccessRateConfirm(difflevel)
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    local title = textRes.Pet[124]
    local desc = textRes.Pet[133]
    CommonConfirmDlg.ShowConfirm(title, desc, function(s)
      if self.uiObjs == nil then
        warn("AskLowSuccessRateConfirm failed, because pet HuaSheng page is closed!!!")
        return
      end
      if s == 1 then
        if self.displayHuaShengItemNum < self:GetHuaShengNeededItemNum() then
          AskYuanBaoSupplement()
        else
          HuaShengReq()
        end
      end
    end, nil)
  end
  local function HuaSheng()
    local mainCfg = self.hsMainPet:GetPetCfgData()
    local subPetCarrayLevel = 0
    local pet = self.hsSubPet
    if pet == nil then
      return
    end
    if self.useYuanBaoMakePet then
      local fakePetCfg = PetUtility.GetFakePetCfgById(pet.typeId)
      if fakePetCfg == nil then
        return
      end
      subPetCarrayLevel = fakePetCfg.vicePetMinRoleLevel
    else
      local subCfg = self.hsSubPet:GetPetCfgData()
      subPetCarrayLevel = subCfg.carryLevel
    end
    local difflevel = PetUtility.Instance():GetPetConstants("PET_HUASHENG_LEVEL_DIFFER") or 10
    if subPetCarrayLevel <= mainCfg.carryLevel - difflevel then
      AskLowSuccessRateConfirm()
    elseif self.displayHuaShengItemNum < self:GetHuaShengNeededItemNum() then
      AskYuanBaoSupplement()
    else
      HuaShengReq()
    end
  end
  local function HuaShengOperation()
    if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_HUA_SHENG_MINIMUM_GUARANEE) then
      HuaSheng()
    else
      self:NewGuaranteeHuaSheng()
    end
  end
  local function ConfirmYuanBaoMakePetAndHuaSheng()
    local pet = self.hsSubPet
    if pet == nil then
      return
    end
    local fakePetCfg = PetUtility.GetFakePetCfgById(pet.typeId)
    if fakePetCfg == nil then
      return
    end
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    local title = textRes.Pet[241]
    local desc = string.format(textRes.Pet[240], fakePetCfg.vicePetMinRoleLevel, #pet:GetSkillIdList(), self.makePetPrice)
    CommonConfirmDlg.ShowConfirm(title, desc, function(s)
      if self.uiObjs == nil then
        warn("ConfirmYuanBaoMakePetAndHuaSheng failed, because pet HuaSheng page is closed!!!")
        return
      end
      if s == 1 then
        HuaShengOperation()
      end
    end, nil)
  end
  if self.hsMainPet == nil then
    Toast(textRes.Pet[21])
  elseif self.hsSubPet == nil then
    Toast(textRes.Pet[22])
  elseif self.hsSubPet.isFighting then
    Toast(textRes.Pet[65])
  elseif self.hsSubPet:HasRememberdSkill() then
    Toast(textRes.Pet[69])
  elseif self.hsMainPet.isFighting and _G.PlayerIsInFight() then
    Toast(textRes.Pet[66])
  else
    if _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_HUA_SHENG_MINIMUM_GUARANEE) and not self:CheckHuaShengMaterialAndConfirm() then
      return
    end
    if not self.useYuanBaoMakePet then
      HuaShengOperation()
    else
      ConfirmYuanBaoMakePetAndHuaSheng()
    end
  end
end
def.method().NewGuaranteeHuaSheng = function(self)
  if not self:CheckEnsurePetCatchLevelAndToast() then
    return
  end
  local function HuaSheng()
    local costType = PetMgr.CostType.UseItem
    if self.useYuanBao or self.useYuanBaoMakePet then
      costType = PetMgr.CostType.UseYuanBao
    end
    if costType == PetMgr.CostType.UseYuanBao then
      if self.needYuanBao <= 0 then
        return
      end
      local yuanBaoNum = ItemModule.Instance():GetAllYuanBao()
      if Int64.lt(yuanBaoNum, self.needYuanBao) then
        _G.GotoBuyYuanbao()
        return
      end
    end
    if self.useGeneralEnsure then
      PetMgr.Instance():GeneralEnsureHuaShengReq(self.hsMainPet.id, self.hsSubPet.id, costType, self.needYuanBao)
    elseif self.useHighEnsure then
      PetMgr.Instance():HighEnsureHuaShengReq(self.hsMainPet.id, self.hsSubPet.id, costType, self.needYuanBao)
    else
      PetMgr.Instance():HuaShengReq(self.hsMainPet.id, self.hsSubPet.id, costType, self.needYuanBao)
    end
  end
  local function CheckLowRateAndHuaSheng()
    local mainCfg = self.hsMainPet:GetPetCfgData()
    local subPetCarrayLevel = 0
    local pet = self.hsSubPet
    if pet == nil then
      return
    end
    if self.useYuanBaoMakePet then
      local fakePetCfg = PetUtility.GetFakePetCfgById(pet.typeId)
      if fakePetCfg == nil then
        return
      end
      subPetCarrayLevel = fakePetCfg.vicePetMinRoleLevel
    else
      local subCfg = self.hsSubPet:GetPetCfgData()
      subPetCarrayLevel = subCfg.carryLevel
    end
    local difflevel = PetUtility.Instance():GetPetConstants("PET_HUASHENG_LEVEL_DIFFER") or 10
    if subPetCarrayLevel <= mainCfg.carryLevel - difflevel then
      local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
      local title = textRes.Pet[124]
      local desc = textRes.Pet[133]
      CommonConfirmDlg.ShowConfirm(title, desc, function(s)
        if self.uiObjs == nil then
          return
        end
        if s == 1 then
          HuaSheng()
        end
      end, nil)
    else
      HuaSheng()
    end
  end
  local function GuaranteeHuaSheng()
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    local title = textRes.Pet[124]
    local desc = ""
    if self.useGeneralEnsure then
      desc = string.format(textRes.Pet[230], self:GetLowEnsureSkillNum())
    else
      desc = string.format(textRes.Pet[231], self:GetHighEnsureSkillNum())
    end
    CommonConfirmDlg.ShowConfirm(title, desc, function(s)
      if self.uiObjs == nil then
        return
      end
      if s == 1 then
        CheckLowRateAndHuaSheng()
      end
    end, nil)
  end
  if self.useGeneralEnsure or self.useHighEnsure then
    GuaranteeHuaSheng()
  else
    CheckLowRateAndHuaSheng()
  end
end
def.method("=>", "boolean").CheckHuaShengMaterialAndConfirm = function(self)
  if not self:IsMaterialEnough() and not self.useYuanBao then
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    local title = textRes.Pet[124]
    local desc = textRes.Pet[228]
    CommonConfirmDlg.ShowConfirm(title, desc, function(s)
      if self.uiObjs == nil then
        return
      end
      if s == 1 then
        self:UseYuanbao()
      end
    end, nil)
    return false
  else
    return true
  end
end
def.method("=>", "boolean").CheckEnsurePetCatchLevelAndToast = function(self)
  if self.hsMainPet ~= nil and self.hsSubPet ~= nil then
    local mainCfg = self.hsMainPet:GetPetCfgData()
    local subPetCarrayLevel = 0
    local pet = self.hsSubPet
    if pet == nil then
      return
    end
    if self.useYuanBaoMakePet then
      local fakePetCfg = PetUtility.GetFakePetCfgById(pet.typeId)
      if fakePetCfg == nil then
        return
      end
      subPetCarrayLevel = fakePetCfg.vicePetMinRoleLevel
    else
      local subCfg = self.hsSubPet:GetPetCfgData()
      subPetCarrayLevel = subCfg.carryLevel
    end
    local difflevel = PetUtility.Instance():GetPetConstants("PET_HUASHENG_LEVEL_DIFFER") or 10
    if subPetCarrayLevel <= mainCfg.carryLevel - difflevel and (self.useGeneralEnsure or self.useHighEnsure) then
      Toast(textRes.Pet[229])
      return false
    else
      return true
    end
  else
    Toast(textRes.Pet[226])
    return false
  end
end
def.override("userdata").UpdatePetInfo = function(self, petId)
  if self.hsMainPet == nil then
    return
  end
  if petId == self.hsMainPet.id then
    do
      local oldPetSkillNum = self.hsMainPet:GetSkillIdList() and #self.hsMainPet:GetSkillIdList() or 0
      self.hsMainPet = PetMgr.Instance():GetPet(petId)
      local newPetSkillNum = self.hsMainPet:GetSkillIdList() and #self.hsMainPet:GetSkillIdList() or 0
      SafeLuckDog(function()
        return newPetSkillNum >= oldPetSkillNum and newPetSkillNum >= 6
      end)
      self:UpdateMainPet()
      if self.hsMainPet ~= nil and #self.hsMainPet:GetSkillIdList() == 10 then
        self:RemoveFakeSubPet()
      end
      self:UpdateHuaShengEnsureInfo()
      self:UpdateHuaShengYuanBao()
    end
  end
end
def.override("userdata").OnPetDeleted = function(self, petId)
  if self.hsSubPet and petId == self.hsSubPet.id and PetMgr.Instance():GetPet(petId) == nil then
    self.hsSubPet = nil
    self.useYuanBao = false
    self.useYuanBaoMakePet = false
    self.makePetPrice = 0
    self:UpdateSubPet()
    self:UpdatePreviewBtnVisibility()
    self.uiObjs.hsFX:SetActive(false)
    self.uiObjs.hsFX:SetActive(true)
  end
end
def.override().UpdateUI = function(self)
  self:InitData()
  GUIUtils.SetActive(self.m_panel:FindChild("Img_Bg0/PetList"), false)
  GUIUtils.SetActive(self.uiObjs.Img_HS_BgPetInfo01, false)
  GUIUtils.SetActive(self.uiObjs.Img_HS_BgPetInfo02, false)
  GUIUtils.SetActive(self.uiObjs.Img_HS_BgSkillGroup01, false)
  GUIUtils.SetActive(self.uiObjs.Img_HS_BgSkillGroup02, false)
  GUIUtils.SetActive(self.uiObjs.Group_Empty1, true)
  GUIUtils.SetActive(self.uiObjs.Group_Empty2, true)
  GUIUtils.SetActive(self.uiObjs.Img_HS_BgMJItem01, false)
  GUIUtils.SetActive(self.uiObjs.Group_Remove, false)
  self:UpdateHuaShengNeeded()
  self:UpdateHuaShengEnsureInfo()
  self:UpdateHuaShengYuanBao()
end
def.method().InitData = function(self)
  self.hsMainPet = nil
  self.hsSubPet = nil
end
def.method().UpdateMainPet = function(self)
  local pet = self.hsMainPet
  if pet ~= nil then
    self.uiObjs.Group_Empty1:SetActive(false)
    self.uiObjs.Img_HS_BgPetInfo01:SetActive(true)
    self.uiObjs.Img_HS_BgSkillGroup01:SetActive(true)
    self:SetPetInfo(pet, 1)
  else
    self.uiObjs.Group_Empty1:SetActive(true)
    self.uiObjs.Img_HS_BgPetInfo01:SetActive(false)
    self.uiObjs.Img_HS_BgSkillGroup01:SetActive(false)
    self.uiObjs.Group_Remove:SetActive(false)
  end
end
def.method().UpdateSubPet = function(self)
  local pet = self.hsSubPet
  if pet ~= nil then
    self.uiObjs.Group_Empty2:SetActive(false)
    self.uiObjs.Img_HS_BgPetInfo02:SetActive(true)
    self.uiObjs.Img_HS_BgSkillGroup02:SetActive(true)
    if Int64.eq(pet.id, -1) then
      self:SetFakePetInfo(pet, 2)
    else
      self:SetPetInfo(pet, 2)
    end
  else
    self.uiObjs.Group_Empty2:SetActive(true)
    self.uiObjs.Img_HS_BgPetInfo02:SetActive(false)
    self.uiObjs.Img_HS_BgSkillGroup02:SetActive(false)
  end
end
def.method("table", "number").SetPetInfo = function(self, pet, num)
  local Img_HS_BgPetInfo = self.uiObjs["Img_HS_BgPetInfo0" .. num]
  Img_HS_BgPetInfo:FindDirect("Label_HS_PetName0" .. num):GetComponent("UILabel").text = pet.name
  Img_HS_BgPetInfo:FindDirect("Label_HS_PetLv0" .. num):GetComponent("UILabel").text = string.format(textRes.Common[3], pet.level)
  GUIUtils.SetActive(Img_HS_BgPetInfo:FindDirect("Label_HS_PetLevel"), false)
  GUIUtils.SetActive(Img_HS_BgPetInfo:FindDirect("Label_HS_PetLevelNum"), false)
  local petCfg = pet:GetPetCfgData()
  Img_HS_BgPetInfo:FindDirect("Label_HS_PetType0" .. num):GetComponent("UILabel").text = textRes.Pet.Type[petCfg.type]
  PetUtility.SetYaoLiUIFromPet(Img_HS_BgPetInfo:FindDirect("Img_BgPower"), pet)
  GUIUtils.SetActive(Img_HS_BgPetInfo:FindDirect("Img_BgPower"), true)
  local iconId = pet:GetHeadIconId()
  local Img_HS_BgPet = Img_HS_BgPetInfo:FindDirect("Img_HS_BgPet0" .. num)
  local uiTexture = Img_HS_BgPet:FindDirect("Img_HS_IconPet0" .. num):GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, iconId)
  local spriteName = pet:GetHeadIconBGSpriteName()
  GUIUtils.SetSprite(Img_HS_BgPet, spriteName)
  local uiSprite = Img_HS_BgPet:GetComponent("UISprite")
  if uiSprite then
    uiSprite:MakePixelPerfect()
  end
  self:SetSkillList(pet, num)
  self:GrayDuplicatedAndCanNotHuaShengSkill()
  GUIUtils.SetActive(Img_HS_BgPetInfo:FindDirect("Btn_FastLearn"), true)
end
def.method("table", "number").SetFakePetInfo = function(self, pet, num)
  local Img_HS_BgPetInfo = self.uiObjs["Img_HS_BgPetInfo0" .. num]
  local fakePetCfg = PetUtility.GetFakePetCfgById(pet.typeId)
  Img_HS_BgPetInfo:FindDirect("Label_HS_PetName0" .. num):GetComponent("UILabel").text = fakePetCfg.vicePetName
  Img_HS_BgPetInfo:FindDirect("Label_HS_PetLv0" .. num):GetComponent("UILabel").text = ""
  Img_HS_BgPetInfo:FindDirect("Label_HS_PetType0" .. num):GetComponent("UILabel").text = ""
  GUIUtils.SetActive(Img_HS_BgPetInfo:FindDirect("Label_HS_PetLevel"), true)
  GUIUtils.SetActive(Img_HS_BgPetInfo:FindDirect("Label_HS_PetLevelNum"), true)
  GUIUtils.SetText(Img_HS_BgPetInfo:FindDirect("Label_HS_PetLevel"), textRes.Pet[238])
  GUIUtils.SetText(Img_HS_BgPetInfo:FindDirect("Label_HS_PetLevelNum"), string.format(textRes.Pet[239], fakePetCfg.vicePetMinRoleLevel))
  GUIUtils.SetActive(Img_HS_BgPetInfo:FindDirect("Img_BgPower"), false)
  local iconId = fakePetCfg.vicePetAvatarIconId
  local Img_HS_BgPet = Img_HS_BgPetInfo:FindDirect("Img_HS_BgPet0" .. num)
  local uiTexture = Img_HS_BgPet:FindDirect("Img_HS_IconPet0" .. num):GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, iconId)
  local bgCfg = PetUtility.Instance():GetPetIconBgCfg(fakePetCfg.vicePetAvatarFrameColorId)
  local spriteName = bgCfg and bgCfg.spriteName or ""
  GUIUtils.SetSprite(Img_HS_BgPet, spriteName)
  local uiSprite = Img_HS_BgPet:GetComponent("UISprite")
  if uiSprite then
    uiSprite:MakePixelPerfect()
  end
  self:SetSkillList(pet, num)
  self:GrayDuplicatedAndCanNotHuaShengSkill()
  GUIUtils.SetActive(Img_HS_BgPetInfo:FindDirect("Btn_FastLearn"), false)
end
def.method("table", "number").SetSkillList = function(self, pet, num)
  if num == 1 then
    self.selectedMSkillId = -1
    self:UpdateSkillRemenberInfo()
  end
  local gridItemCount = 16
  local skillIconName = "Img_HS_IconSkill0" .. num
  local rememberIconName = "Img_HS_Sign"
  local amuletIconName = "Img_HS_Sign0"
  local rideIconName = "Img_HS_RidingSign"
  local petMarkIconName = "Img_HS_ImpressSign"
  local skillForbidName = "Img_Forbidden"
  local addIconName
  local parentObj = self.uiObjs["Img_HS_BgSkillGroup0" .. num]
  parentObj:SetActive(true)
  local selfSkillIdList = pet:GetSkillIdList()
  local selfSkillAmount = selfSkillIdList and #selfSkillIdList or 0
  local skillIdList = pet:GetConcatSkillIdList() or {}
  local concatSkillAmount = #skillIdList
  local skillMountsIdList = pet:GetProtectMountsSkillIdList() or {}
  for _, v in ipairs(skillMountsIdList) do
    table.insert(skillIdList, v)
  end
  local mountsSkillEnd = concatSkillAmount + #skillMountsIdList
  local petMarkSkillId = pet:GetPetMarkSkillId()
  if petMarkSkillId > 0 then
    table.insert(skillIdList, petMarkSkillId)
  end
  for i = 1, gridItemCount do
    local skillId = skillIdList[i]
    local objIndex = string.format("%02d", i)
    local itemObj = parentObj:FindDirect(string.format("Img_HS_BgSkill0%d_%02d", num, i))
    if not itemObj then
      break
    end
    itemObj:GetComponent("UIToggle").value = false
    PetUtility.SafeSetActive(itemObj, string.format("%s_%02d", skillIconName, i), false)
    PetUtility.SafeSetActive(itemObj, rememberIconName, false)
    PetUtility.SafeSetActive(itemObj, amuletIconName, false)
    PetUtility.SafeSetActive(itemObj, skillForbidName, false)
    PetUtility.SafeSetActive(itemObj, rideIconName, false)
    PetUtility.SafeSetActive(itemObj, petMarkIconName, false)
    if addIconName then
      PetUtility.SafeSetActive(itemObj, addIconName, false)
    end
    if skillId then
      if skillId > 0 then
        PetUtility.SetPetSkillBgColor(itemObj, skillId)
        PetUtility.SafeSetActive(itemObj, string.format("%s_%02d", skillIconName, i), true)
        if skillId == pet.rememberedSkillId and selfSkillAmount >= i then
          local Img_Sign = itemObj:FindDirect(rememberIconName)
          GUIUtils.SetActive(Img_Sign, true)
          local uiSprite = Img_Sign:GetComponent("UISprite")
          self:SetSprite(uiSprite, "Img_SignMJ")
        end
        if selfSkillAmount < i and concatSkillAmount >= i then
          PetUtility.SafeSetActive(itemObj, amuletIconName, true)
        end
        if concatSkillAmount < i and i <= mountsSkillEnd then
          PetUtility.SafeSetActive(itemObj, rideIconName, true)
        end
        if i > mountsSkillEnd then
          PetUtility.SafeSetActive(itemObj, petMarkIconName, true)
        end
        local skillCfg = PetUtility.Instance():GetPetSkillCfg(skillId)
        if skillCfg.iconId == 0 then
          warn(string.format("skill(%s)'s iconId == 0", skillCfg.name))
        end
        local uiTexture = itemObj:FindDirect(string.format("%s_%02d", skillIconName, i)):GetComponent("UITexture")
        GUIUtils.FillIcon(uiTexture, skillCfg.iconId)
      else
        local fakeSkillId = constant.CPetHuaShengYuanBaoMakeUpViceConsts.VICE_PET_SKILL_ID
        PetUtility.SetPetSkillBgColor(itemObj, fakeSkillId)
        PetUtility.SafeSetActive(itemObj, string.format("%s_%02d", skillIconName, i), true)
        local skillCfg = PetUtility.Instance():GetPetSkillCfg(fakeSkillId)
        if skillCfg.iconId == 0 then
          warn(string.format("skill(%s)'s iconId == 0", skillCfg.name))
        end
        local uiTexture = itemObj:FindDirect(string.format("%s_%02d", skillIconName, i)):GetComponent("UITexture")
        GUIUtils.FillIcon(uiTexture, skillCfg.iconId)
      end
    else
      PetUtility.SetOriginPetSkillBg(itemObj, "Img_SkillFg")
    end
  end
end
def.method("userdata", "string").SetSprite = function(self, sprite, spriteName)
  local path = RESPATH.COMMONATLAS
  if spriteName == "Img_Repeat" then
    path = RESPATH.FUNCTION1_ATLAS
  end
  GameUtil.AsyncLoad(path, function(obj)
    local atlas = obj:GetComponent("UIAtlas")
    if sprite == nil or sprite.isnil then
      return
    end
    sprite:set_atlas(atlas)
    sprite:set_spriteName(spriteName)
    sprite:MakePixelPerfect()
  end)
end
def.method("userdata", "table", "userdata", "number").OnSkillIconClick = function(self, sourceObj, context, anchorObj, hPrefer)
  local skillId, level = context.skill.id, context.pet.level
  local uiToggle = sourceObj:GetComponent("UIToggle")
  if uiToggle then
    uiToggle.value = true
  end
  if skillId == 0 then
    return
  end
  if skillId < 0 then
    skillId = constant.CPetHuaShengYuanBaoMakeUpViceConsts.VICE_PET_SKILL_ID
  end
  PetUtility.ShowPetSkillTipEx(skillId, level, anchorObj, hPrefer, context)
end
def.method().UpdateHuaShengNeeded = function(self)
  self:UpdateSkillRemenberInfo()
  local neededCfg = self:GetHuaShengNeededCfg()
  self.catchedHuaShengNeed = neededCfg
  local neededMoney = neededCfg.neededMoney
  local useItemNum = neededCfg.neededItemNum
  local ItemModule = require("Main.Item.ItemModule")
  local moneySilver = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER) or Int64.new(0)
  self.displaySilverMoney = moneySilver
  local itemType = require("consts.mzm.gsp.item.confbean.ItemType").PET_HUASHENG_ITEM
  local ItemModule = require("Main.Item.ItemModule")
  local items = ItemModule.Instance():GetItemsByItemType(ItemModule.BAG, itemType)
  local count = 0
  for k, v in pairs(items) do
    count = count + v.number
  end
  local itemNum = count
  self.displayHuaShengItemNum = itemNum
  local numText = _G.GetFormatItemNumString(itemNum, useItemNum)
  local Img_HS_BgHSItem01 = self.uiObjs.Img_HS_BgHS:FindChild("Img_HS_BgHSItem01")
  Img_HS_BgHSItem01:FindDirect("Label_HS_HSItem01"):GetComponent("UILabel"):set_text(numText)
  local itemId = PetUtility.Instance():GetPetConstants("PET_HUASHENG_ITEM_ID")
  local itemBase = require("Main.Item.ItemUtils").GetItemBase(itemId)
  local iconId = itemBase.icon
  self.huaShengConsume = self.huaShengConsume or {}
  self.huaShengConsume.itemType = itemType
  self.huaShengConsume.itemId = itemId
  self.huaShengConsume.useItemNum = useItemNum
  self.huaShengConsume.haveItemNum = count
  local uiTexture = Img_HS_BgHSItem01:FindDirect("Icon_HS_HSItem01"):GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, iconId)
  local clickedObj = uiTexture.gameObject.transform.parent.gameObject
  self.easyItemTipHelper:RegisterItem2ShowTip(itemId, clickedObj)
end
def.method("=>", "table").GetHuaShengNeededCfg = function(self)
  if self.hsMainPet == nil or self.hsSubPet == nil then
    return {
      neededMoney = 0,
      neededItemNum = 0,
      lowEnsureCfg = {},
      highEnsureCfg = {}
    }
  end
  local petCfgData = self.hsMainPet:GetPetCfgData()
  local cfg = PetUtility.GetPetHuaShengNeedCfg(petCfgData.type, petCfgData.carryLevel)
  return {
    neededMoney = cfg.costCopper,
    neededItemNum = cfg.needItemNum,
    lowEnsureCfg = cfg.lowEnsureCfg,
    highEnsureCfg = cfg.highEnsureCfg
  }
end
def.method("=>", "number").GetHuaShengNeededItemNum = function(self)
  return self.catchedHuaShengNeed.neededItemNum or 0
end
def.method("=>", "number").GetHuaShengNeededMoney = function(self)
  return self.catchedHuaShengNeed.neededMoney or 0
end
def.method().UpdateHuaShengEnsureInfo = function(self)
  if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_HUA_SHENG_MINIMUM_GUARANEE) then
    GUIUtils.SetActive(self.uiObjs.Img_HS_BgHSBDItem01, false)
    GUIUtils.SetActive(self.uiObjs.Group_SkillInfo, false)
    return
  else
    GUIUtils.SetActive(self.uiObjs.Img_HS_BgHSBDItem01, true)
  end
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local ItemModule = require("Main.Item.ItemModule")
  local Icon_HS_HSBDItem01 = self.uiObjs.Img_HS_BgHSBDItem01:FindDirect("Icon_HS_HSBDItem01")
  local Label_HS_HSBDItem01 = self.uiObjs.Img_HS_BgHSBDItem01:FindDirect("Label_HS_HSBDItem01")
  local showItemId = PetUtility.Instance():GetPetConstants("hua_sheng_low_minimum_guarantee_item_id")
  if self.hsMainPet ~= nil and self.hsSubPet ~= nil then
    local huashengCfg = self:GetHuaShengNeededCfg()
    local unionSkills = PetSkillMgr.Instance():GetHuaShengUnionSkillList(self.hsMainPet, self.hsSubPet)
    local MAX_SKILL_NUM = PetUtility.Instance():GetPetConstants("PET_SHELF_SKILL_NUM_LIMIT")
    if self.useGeneralEnsure then
      showItemId = PetUtility.Instance():GetPetConstants("hua_sheng_low_minimum_guarantee_item_id")
      local ensureSkillNum = self:GetLowEnsureSkillNum()
      local hasNum = ItemModule.Instance():GetNumByItemType(ItemModule.BAG, ItemType.PET_HUA_SHENG_LOW_MINMUM_GUARANTEE_ITEM)
      local needNum = huashengCfg.lowEnsureCfg[ensureSkillNum] or 0
      self.needGeneralEnsureCount = math.max(0, needNum - hasNum)
      self.needHighEnsureCount = 0
      if 0 < self.needGeneralEnsureCount then
        GUIUtils.SetText(Label_HS_HSBDItem01, string.format(textRes.Pet[224], hasNum, needNum))
      else
        GUIUtils.SetText(Label_HS_HSBDItem01, string.format(textRes.Pet[223], hasNum, needNum))
      end
      GUIUtils.SetActive(self.uiObjs.Group_SkillInfo, true)
      GUIUtils.SetText(self.uiObjs.Group_SkillInfo:FindDirect("Label"), string.format(textRes.Pet[235], ensureSkillNum, math.min(MAX_SKILL_NUM, #unionSkills)))
    elseif self.useHighEnsure then
      showItemId = PetUtility.Instance():GetPetConstants("hua_sheng_hign_minimum_guarantee_item_id")
      local ensureSkillNum = self:GetHighEnsureSkillNum()
      local hasNum = ItemModule.Instance():GetNumByItemType(ItemModule.BAG, ItemType.PET_HUA_SHENG_HIGH_MINMUM_GUARANTEE_ITEM)
      local needNum = huashengCfg.highEnsureCfg[ensureSkillNum] or 0
      self.needGeneralEnsureCount = 0
      self.needHighEnsureCount = math.max(0, needNum - hasNum)
      if 0 < self.needHighEnsureCount then
        GUIUtils.SetText(Label_HS_HSBDItem01, string.format(textRes.Pet[224], hasNum, needNum))
      else
        GUIUtils.SetText(Label_HS_HSBDItem01, string.format(textRes.Pet[223], hasNum, needNum))
      end
      GUIUtils.SetActive(self.uiObjs.Group_SkillInfo, true)
      GUIUtils.SetText(self.uiObjs.Group_SkillInfo:FindDirect("Label"), string.format(textRes.Pet[236], ensureSkillNum, math.min(MAX_SKILL_NUM, #unionSkills)))
    else
      self.needGeneralEnsureCount = 0
      self.needHighEnsureCount = 0
      local hasNum = ItemModule.Instance():GetNumByItemType(ItemModule.BAG, ItemType.PET_HUA_SHENG_LOW_MINMUM_GUARANTEE_ITEM)
      GUIUtils.SetText(Label_HS_HSBDItem01, string.format(textRes.Pet[223], hasNum, 0))
      GUIUtils.SetActive(self.uiObjs.Group_SkillInfo, true)
      GUIUtils.SetText(self.uiObjs.Group_SkillInfo:FindDirect("Label"), string.format(textRes.Pet[234], 0, math.min(MAX_SKILL_NUM, #unionSkills)))
    end
  else
    self.needGeneralEnsureCount = 0
    self.needHighEnsureCount = 0
    self.useGeneralEnsure = false
    self.useHighEnsure = false
    local hasNum = ItemModule.Instance():GetNumByItemType(ItemModule.BAG, ItemType.PET_HUA_SHENG_LOW_MINMUM_GUARANTEE_ITEM)
    GUIUtils.SetText(Label_HS_HSBDItem01, string.format(textRes.Pet[223], hasNum, 0))
    GUIUtils.SetActive(self.uiObjs.Group_SkillInfo, false)
  end
  self.uiObjs.Btn_LowUseGold:GetComponent("UIToggle").value = self.useGeneralEnsure
  self.uiObjs.Btn_HighUseGold:GetComponent("UIToggle").value = self.useHighEnsure
  local itemBase = ItemUtils.GetItemBase(showItemId)
  GUIUtils.FillIcon(Icon_HS_HSBDItem01:GetComponent("UITexture"), itemBase.icon)
  self.easyItemTipHelper:RegisterItem2ShowTip(showItemId, self.uiObjs.Img_HS_BgHSBDItem01)
end
def.method("=>", "number").GetLowEnsureSkillNum = function(self)
  local skillNum = 0
  if self.hsMainPet ~= nil and self.hsSubPet ~= nil then
    local skills = PetSkillMgr.Instance():GetHuaShengUnionSkillList(self.hsMainPet, self.hsSubPet)
    skillNum = math.floor(#skills / 2)
  end
  return skillNum
end
def.method("=>", "number").GetHighEnsureSkillNum = function(self)
  local skillNum = 0
  if self.hsMainPet ~= nil and self.hsSubPet ~= nil then
    local skills = PetSkillMgr.Instance():GetHuaShengUnionSkillList(self.hsMainPet, self.hsSubPet)
    local MAX_SKILL_NUM = PetUtility.Instance():GetPetConstants("PET_SHELF_SKILL_NUM_LIMIT")
    if #skills == 0 then
      skillNum = 0
    else
      skillNum = math.min(math.floor(#skills / 2 + 1), MAX_SKILL_NUM)
    end
  end
  return skillNum
end
def.method().UpdateHuaShengYuanBao = function(self)
  local Label_HS_Make = self.uiObjs.Btn_HS_Make:FindDirect("Label_HS_Make")
  local Group_Dep = self.uiObjs.Btn_HS_Make:FindDirect("Group_Dep")
  if self:IsMaterialEnough() then
    self.useYuanBao = false
  end
  if not self.useYuanBao and not self.useYuanBaoMakePet then
    GUIUtils.SetActive(Label_HS_Make, true)
    GUIUtils.SetActive(Group_Dep, false)
  else
    GUIUtils.SetActive(Label_HS_Make, false)
    GUIUtils.SetActive(Group_Dep, true)
  end
  self:UpdateItemYuanBaoInfo()
  self:UpdateMakeSubPetYuanBaoInfo()
end
def.method().UpdateItemYuanBaoInfo = function(self)
  local Label_HS_Make = self.uiObjs.Btn_HS_Make:FindDirect("Label_HS_Make")
  local Group_Dep = self.uiObjs.Btn_HS_Make:FindDirect("Group_Dep")
  local Label_Money = Group_Dep:FindDirect("Label_Money")
  if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_HUA_SHENG_MINIMUM_GUARANEE) then
    GUIUtils.SetActive(self.uiObjs.Group_UseDep, false)
    return
  else
    GUIUtils.SetActive(self.uiObjs.Group_UseDep, true)
  end
  self.uiObjs.Btn_UseDep:GetComponent("UIToggle").value = self.useYuanBao
  if self.useYuanBao then
    GUIUtils.SetText(Label_Money, string.format(textRes.Pet[225], math.max(0, self.needYuanBao)))
    if self.huaShengConsume and self.huaShengConsume.haveItemNum < self.huaShengConsume.useItemNum then
      self:QueryItemPrice(self.huaShengConsume.itemId)
    end
    if self.useGeneralEnsure and 0 < self.needGeneralEnsureCount then
      self:QueryItemPrice(PetUtility.Instance():GetPetConstants("hua_sheng_low_minimum_guarantee_item_id"))
    end
    if self.useHighEnsure and 0 < self.needHighEnsureCount then
      self:QueryItemPrice(PetUtility.Instance():GetPetConstants("hua_sheng_hign_minimum_guarantee_item_id"))
    end
  end
end
def.method("number").QueryItemPrice = function(self, itemId)
  require("Main.Item.ItemConsumeHelper").Instance():GetItemYuanBaoPrice(itemId, function(result)
    if not self.isShowing then
      return
    end
    self:UpdateItemPrice(itemId, result)
    self:CalculateNeedYuanbao()
  end)
end
def.method("number", "number").UpdateItemPrice = function(self, itemId, itemPrice)
  self.yuanbaoItemPrice = self.yuanbaoItemPrice or {}
  self.yuanbaoItemPrice[itemId] = itemPrice
end
def.method().CalculateNeedYuanbao = function(self)
  self.yuanbaoItemPrice = self.yuanbaoItemPrice or {}
  local totalYuanbao = 0
  if self.useYuanBao and self.huaShengConsume and self.huaShengConsume.haveItemNum < self.huaShengConsume.useItemNum then
    local itemId = self.huaShengConsume.itemId
    local price = self.yuanbaoItemPrice[itemId] or 0
    totalYuanbao = totalYuanbao + (self.huaShengConsume.useItemNum - self.huaShengConsume.haveItemNum) * price
  end
  if self.useYuanBao and self.useGeneralEnsure and 0 < self.needGeneralEnsureCount then
    local itemId = PetUtility.Instance():GetPetConstants("hua_sheng_low_minimum_guarantee_item_id")
    local price = self.yuanbaoItemPrice[itemId] or 0
    totalYuanbao = totalYuanbao + self.needGeneralEnsureCount * price
  end
  if self.useYuanBao and self.useHighEnsure and 0 < self.needHighEnsureCount then
    local itemId = PetUtility.Instance():GetPetConstants("hua_sheng_hign_minimum_guarantee_item_id")
    local price = self.yuanbaoItemPrice[itemId] or 0
    totalYuanbao = totalYuanbao + self.needHighEnsureCount * price
  end
  if self.useYuanBaoMakePet then
    totalYuanbao = totalYuanbao + self.makePetPrice
  end
  self:SetNeedYuanbaoNum(totalYuanbao)
end
def.method("number").SetNeedYuanbaoNum = function(self, yuanbao)
  self.needYuanBao = yuanbao
  local Group_Dep = self.uiObjs.Btn_HS_Make:FindDirect("Group_Dep")
  local Label_Money = Group_Dep:FindDirect("Label_Money")
  GUIUtils.SetText(Label_Money, string.format(textRes.Pet[225], yuanbao))
end
def.method("=>", "boolean").IsMaterialEnough = function(self)
  if self.huaShengConsume and self.huaShengConsume.haveItemNum < self.huaShengConsume.useItemNum then
    return false
  end
  if self.useGeneralEnsure and self.needGeneralEnsureCount > 0 then
    return false
  end
  if self.useHighEnsure and 0 < self.needHighEnsureCount then
    return false
  end
  return true
end
def.method().UseYuanbao = function(self)
  self.useYuanBao = true
  self.uiObjs.Btn_UseDep:GetComponent("UIToggle").value = true
  self:UpdateHuaShengYuanBao()
end
def.method().UpdateMakeSubPetYuanBaoInfo = function(self)
  if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_PET_HUA_SHENG_YUAN_BAO_MAKE_UP_VICE_PET) then
    GUIUtils.SetActive(self.uiObjs.Group_UseDep2ndPet, false)
    return
  else
    GUIUtils.SetActive(self.uiObjs.Group_UseDep2ndPet, true)
  end
  self.uiObjs.Btn_UseDep2ndPet:GetComponent("UIToggle").value = self.useYuanBaoMakePet
  local Label_HS_Make = self.uiObjs.Btn_HS_Make:FindDirect("Label_HS_Make")
  local Group_Dep = self.uiObjs.Btn_HS_Make:FindDirect("Group_Dep")
  local Label_Money = Group_Dep:FindDirect("Label_Money")
  if self.useYuanBaoMakePet then
    GUIUtils.SetText(Label_Money, string.format(textRes.Pet[225], math.max(0, self.needYuanBao)))
    self:QuerySubPetPrice()
  end
end
def.method().QuerySubPetPrice = function(self)
  if self.hsMainPet ~= nil then
    PetMgr.Instance():QueryYuanBaoMakePetPrice(self.hsMainPet.id)
  end
end
def.method("number").UpdateSubPetPrice = function(self, price)
  self.makePetPrice = price
end
def.method("table").MakeSubPetData = function(self, petInfo)
  if petInfo == nil then
    return
  end
  self.hsSubPet = PetData()
  self.hsSubPet.id = Int64.new(-1)
  self.hsSubPet.typeId = petInfo.viceCfgId
  local skills = {}
  for i = 1, petInfo.skillCount do
    table.insert(skills, -i)
  end
  self.hsSubPet.skillIdList = skills
  self.hsSubPet.amuletSkillIdList = {}
  self.hsSubPet.combinedSkillIdList = skills
  self:UpdateSubPet()
  self.hsPetList = nil
  self.hsSelectedPetIndex = 0
  self:UpdateHuaShengNeeded()
  self:UpdateHuaShengEnsureInfo()
  self:UpdatePreviewBtnVisibility()
end
def.method().RemoveFakeSubPet = function(self)
  self.hsSubPet = nil
  self.hsPetList = nil
  self.hsSelectedPetIndex = 0
  self.useYuanBao = false
  self.useYuanBaoMakePet = false
  self.makePetPrice = 0
  self:UpdateSubPet()
  self:UpdateHuaShengNeeded()
  self:UpdateHuaShengEnsureInfo()
  self:UpdateHuaShengYuanBao()
  self:UpdatePreviewBtnVisibility()
end
def.method().UpdatePreviewBtnVisibility = function(self)
  if self.hsMainPet and self.hsSubPet then
    GUIUtils.SetActive(self.uiObjs.Btn_Preview, true)
  else
    GUIUtils.SetActive(self.uiObjs.Btn_Preview, false)
  end
end
def.override().OnBagInfoSynchronized = function(self)
  self:UpdateHuaShengNeeded()
  self:UpdateHuaShengEnsureInfo()
  self:UpdateHuaShengYuanBao()
end
def.static("table", "table").OnBagSilverMoneyChanged = function(params)
  local self = instance
  self:UpdateHuaShengNeeded()
  self:UpdateHuaShengEnsureInfo()
  self:UpdateHuaShengYuanBao()
end
def.method("number").OnMainPetSkillClicked = function(self, index)
  local pet = self.hsMainPet
  local skillIdList = pet:GetSkillIdList()
  self.selectedMSkillId = skillIdList[index] or -1
  self:UpdateSkillRemenberInfo()
  local concatSkillIdList = pet:GetConcatSkillIdList()
  local skillMountsIdList = pet:GetProtectMountsSkillIdList() or {}
  for _, v in ipairs(skillMountsIdList) do
    table.insert(concatSkillIdList, v)
  end
  local petMarkSkillId = pet:GetPetMarkSkillId()
  if petMarkSkillId > 0 then
    table.insert(concatSkillIdList, petMarkSkillId)
  end
  local skillId = concatSkillIdList[index] or 0
  local isOwnSkill = self.selectedMSkillId == skillId and true or false
  local context = {
    pet = pet,
    skill = {id = skillId, isOwnSkill = isOwnSkill},
    needRemember = true
  }
  local sourceObj = self.uiObjs.Img_HS_BgSkillGroup01:FindDirect(string.format("Img_HS_BgSkill01_%02d", index))
  local anchorObj = self.uiObjs.Img_HS_BgSkillGroup01:FindDirect(string.format("Img_HS_BgSkill01_%02d", 12))
  self:OnSkillIconClick(sourceObj, context, anchorObj, 1)
end
def.method("number").OnSubPetSkillClicked = function(self, index)
  self.selectedMSkillId = -1
  self:UpdateSkillRemenberInfo()
  local pet = self.hsSubPet
  local concatSkillIdList = pet:GetConcatSkillIdList()
  local skillMountsIdList = pet:GetProtectMountsSkillIdList() or {}
  for _, v in ipairs(skillMountsIdList) do
    table.insert(concatSkillIdList, v)
  end
  local skillId = concatSkillIdList[index] or 0
  local context = {
    pet = pet,
    skill = {id = skillId},
    needRemember = false
  }
  local sourceObj = self.uiObjs.Img_HS_BgSkillGroup02:FindDirect(string.format("Img_HS_BgSkill02_%02d", index))
  local anchorObj = self.uiObjs.Img_HS_BgSkillGroup02:FindDirect(string.format("Img_HS_BgSkill02_%02d", 9))
  self:OnSkillIconClick(sourceObj, context, anchorObj, -1)
end
def.method().UpdateSkillRemenberInfo = function(self)
  self:HideSkillRemenberInfo()
end
def.method().ShowSkillRemenberInfo = function(self)
  self:SetSkillRemenberInfoVisible(true)
  local skillId = self.selectedMSkillId
  self:ShowRemenberSkillNeed()
end
def.method().HideSkillRemenberInfo = function(self)
  self:SetSkillRemenberInfoVisible(false)
end
def.method("boolean").SetSkillRemenberInfoVisible = function(self, isShow)
  GUIUtils.SetActive(self.uiObjs.Img_HS_BgMJItem01, isShow)
  GUIUtils.SetActive(self.uiObjs.Group_Remove, isShow)
end
def.method().ShowRemenberSkillNeed = function(self)
  GUIUtils.SetActive(self.uiObjs.Img_HS_BgMJItem01, true)
  GUIUtils.SetActive(self.uiObjs.Group_Remove, false)
  local itemType = require("consts.mzm.gsp.item.confbean.ItemType").PET_REMEBER_SKILL_ITEM
  local ItemModule = require("Main.Item.ItemModule")
  local itemId = PetUtility.Instance():GetPetConstants("PET_REMEBER_SKILL_ITEM_ID")
  local items = ItemModule.Instance():GetItemsByItemType(ItemModule.BAG, itemType)
  local count = 0
  for k, v in pairs(items) do
    count = count + v.number
  end
  local itemNum = count
  local useNum = PetModule.PET_REMEMBER_SKILL_USE_ITEM_NUM
  local itemBase = require("Main.Item.ItemUtils").GetItemBase(itemId)
  local iconId = itemBase.icon
  local numText = _G.GetFormatItemNumString(itemNum, useNum)
  local label = self.uiObjs.Img_HS_BgMJItem01:FindDirect("Label_HS_MJItem01"):GetComponent("UILabel")
  label.text = numText
  local uiTexture = self.uiObjs.Img_HS_BgMJItem01:FindDirect("Icon_HS_MJItem01"):GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, iconId)
  local clickedObj = self.uiObjs.Img_HS_BgMJItem01
  self.easyItemTipHelper:RegisterItem2ShowTip(itemId, clickedObj)
  if itemNum >= useNum then
    self.canRemember = true
  else
    self.canRemember = false
  end
end
def.method().ShowUnremenberSkillNeed = function(self)
  GUIUtils.SetActive(self.uiObjs.Img_HS_BgMJItem01, false)
  GUIUtils.SetActive(self.uiObjs.Group_Remove, true)
  local costSilver = PetUtility.Instance():GetPetConstants("PET_UNREMEMBER_SKILL_COST_SILVER")
  local ItemModule = require("Main.Item.ItemModule")
  local moneySilver = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER) or Int64.new(0)
  local Label_CostNum = self.uiObjs.Group_Remove:FindDirect("Img_HS_BgUseMoney/Label_HS_UseMoneyNum"):GetComponent("UILabel")
  Label_CostNum:set_text(costSilver)
  self.uiObjs.Group_Remove:FindDirect("Img_HS_BgHaveMoney/Label_HS_HaveMoneyNum"):GetComponent("UILabel"):set_text(tostring(moneySilver))
  if moneySilver:lt(costSilver) then
    self.canUnremember = false
    Label_CostNum:set_color(Color.red)
  else
    self.canUnremember = true
    Label_CostNum:set_color(Color.white)
  end
end
def.method().HideRemenberSkillNeed = function(self)
  self.uiObjs.Btn_HS_MingJi:SetActive(false)
  self.uiObjs.Img_HS_BgMJItem01:SetActive(false)
end
def.method().GrayDuplicatedAndCanNotHuaShengSkill = function(self)
  if not self.hsMainPet or not self.hsSubPet then
    return
  end
  local num = 2
  local gridItemCount = 12
  local skillIconName = "Img_HS_IconSkill0" .. num
  local rememberIconName = "Img_HS_Sign"
  local amuletIconName = "Img_HS_Sign0"
  local skillForbidName = "Img_Forbidden"
  local addIconName
  local parentObj = self.uiObjs["Img_HS_BgSkillGroup0" .. num]
  parentObj:SetActive(true)
  local FindDuplicatedSkill = function(mainPet, subPet)
    local dup = {
      own = {},
      amulet = {}
    }
    local mainList = mainPet:GetSkillIdList() or {}
    local subList = subPet:GetSkillIdList() or {}
    for i, id in ipairs(subList) do
      if table.indexof(mainList, id) ~= false then
        dup.own[id] = id
      end
    end
    local mainList = mainPet:GetAmuletSkillIdList() or {}
    local subList = subPet:GetAmuletSkillIdList() or {}
    for i, id in ipairs(subList) do
      if table.indexof(mainList, id) ~= false then
        dup.amulet[id] = id
      end
    end
    return dup
  end
  local dup = FindDuplicatedSkill(self.hsMainPet, self.hsSubPet)
  local pet = self.hsSubPet
  local selfSkillIdList = pet:GetSkillIdList()
  local selfSkillAmount = selfSkillIdList and #selfSkillIdList or 0
  local skillIdList = pet:GetConcatSkillIdList() or {}
  for i = 1, gridItemCount do
    local skillId = skillIdList[i]
    local objIndex = string.format("%02d", i)
    local itemObj = parentObj:FindDirect(string.format("Img_HS_BgSkill0%d_%02d", num, i))
    if skillId then
      local uiTexture = itemObj:FindDirect(string.format("%s_%02d", skillIconName, i)):GetComponent("UITexture")
      local isDuplicated
      if i <= selfSkillAmount and dup.own[skillId] then
        isDuplicated = true
      elseif i > selfSkillAmount and dup.amulet[skillId] then
        isDuplicated = true
      else
        isDuplicated = false
      end
      if isDuplicated then
        GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Gray)
        local Img_Sign = itemObj:FindDirect(rememberIconName)
        GUIUtils.SetActive(Img_Sign, true)
        local uiSprite = Img_Sign:GetComponent("UISprite")
        self:SetSprite(uiSprite, "Img_Repeat")
      else
        local Img_Sign = itemObj:FindDirect(rememberIconName)
        GUIUtils.SetActive(Img_Sign, false)
        GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Normal)
      end
      local canNotBeHuaSheng = not PetSkillMgr.Instance():CanSkillBeHuaSheng(skillId)
      if canNotBeHuaSheng then
        GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Gray)
        PetUtility.SafeSetActive(itemObj, skillForbidName, true)
      end
    end
  end
end
def.method().OnRemenberSkillButtonClicked = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  if self.selectedMSkillId == -1 then
    return
  end
  local petId = self.hsMainPet.id
  if self.canRemember then
    PetModule.Instance():RememberSkill(petId, self.selectedMSkillId, {})
  else
    Toast(textRes.Pet[63])
  end
end
def.method().OnUnrememberButtonClicked = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  if self.selectedMSkillId == -1 then
    return
  end
  local petId = self.hsMainPet.id
  if self.canUnremember then
    PetSkillMgr.Instance():UnrememberSkill(petId, self.selectedMSkillId)
  else
    Toast(textRes.Pet[23])
  end
end
def.method().OnHuaShengTipButtonClicked = function(self)
  local tipId = PetModule.PET_HUA_SHENG_TIP_ID
  GUIUtils.ShowHoverScrollTip(tipId, 0, 0)
end
def.method().OnPreviewButtonClicked = function(self)
  require("Main.Pet.ui.PetHuaShengPreviewPanel").Instance():ShowPanel(self.hsMainPet, self.hsSubPet)
end
def.method().OnFastLearnButtonClicked = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  self:ShowFastLearnSkillBooks()
end
def.method().ShowFastLearnSkillBooks = function(self)
  if self.hsSubPet then
    local mainPetSkills = {}
    if self.hsMainPet ~= nil then
      mainPetSkills = self.hsMainPet.skillIdList
    end
    require("Main.Pet.ui.PetFastLearnSkillPanel").Instance():ShowFastLearnForPetHuaSheng(self.hsSubPet.id, mainPetSkills)
  end
end
def.method().OnLowEnsureButtonClicked = function(self)
  if _G.CheckCrossServerAndToast() then
    self.uiObjs.Btn_LowUseGold:GetComponent("UIToggle").value = self.useGeneralEnsure
    return
  end
  if self.hsMainPet == nil or self.hsSubPet == nil then
    self.uiObjs.Btn_LowUseGold:GetComponent("UIToggle").value = false
    self.uiObjs.Btn_HighUseGold:GetComponent("UIToggle").value = self.useHighEnsure
    self.useGeneralEnsure = false
    Toast(textRes.Pet[226])
    return
  end
  self.useGeneralEnsure = self.uiObjs.Btn_LowUseGold:GetComponent("UIToggle").value
  self.useHighEnsure = self.uiObjs.Btn_HighUseGold:GetComponent("UIToggle").value
  self:UpdateHuaShengEnsureInfo()
  self:UpdateHuaShengYuanBao()
end
def.method().OnHighEnsureButtonClicked = function(self)
  if _G.CheckCrossServerAndToast() then
    self.uiObjs.Btn_HighUseGold:GetComponent("UIToggle").value = self.useHighEnsure
    return
  end
  if self.hsMainPet == nil or self.hsSubPet == nil then
    self.uiObjs.Btn_LowUseGold:GetComponent("UIToggle").value = self.useGeneralEnsure
    self.uiObjs.Btn_HighUseGold:GetComponent("UIToggle").value = false
    self.useHighEnsure = false
    Toast(textRes.Pet[226])
    return
  end
  local skills = PetSkillMgr.Instance():GetHuaShengUnionSkillList(self.hsMainPet, self.hsSubPet)
  local MAX_SKILL_NUM = PetUtility.Instance():GetPetConstants("PET_SHELF_SKILL_NUM_LIMIT")
  if #skills >= 2 * MAX_SKILL_NUM then
    self.uiObjs.Btn_LowUseGold:GetComponent("UIToggle").value = self.useGeneralEnsure
    self.uiObjs.Btn_HighUseGold:GetComponent("UIToggle").value = false
    self.useHighEnsure = false
    Toast(textRes.Pet[233])
    return
  end
  self.useGeneralEnsure = self.uiObjs.Btn_LowUseGold:GetComponent("UIToggle").value
  self.useHighEnsure = self.uiObjs.Btn_HighUseGold:GetComponent("UIToggle").value
  self:UpdateHuaShengEnsureInfo()
  self:UpdateHuaShengYuanBao()
end
def.method().OnUseYuanbaoButtonClicked = function(self)
  if _G.CheckCrossServerAndToast() then
    self.uiObjs.Btn_UseDep:GetComponent("UIToggle").value = self.useYuanBao
    return
  end
  if self.hsMainPet ~= nil and self.hsSubPet ~= nil then
    if not self:IsMaterialEnough() then
      self.useYuanBao = self.uiObjs.Btn_UseDep:GetComponent("UIToggle").value
    else
      self.uiObjs.Btn_UseDep:GetComponent("UIToggle").value = false
      self.useYuanBao = false
      Toast(textRes.Pet[227])
    end
  else
    if self.uiObjs.Btn_UseDep:GetComponent("UIToggle").value then
      Toast(textRes.Pet[226])
    end
    self.uiObjs.Btn_UseDep:GetComponent("UIToggle").value = false
    self.useYuanBao = false
  end
  self:UpdateHuaShengYuanBao()
end
def.method().OnUseYuanbaoMakePetClicked = function(self)
  if _G.CheckCrossServerAndToast() then
    self.useYuanBaoMakePet = false
    self.uiObjs.Btn_UseDep2ndPet:GetComponent("UIToggle").value = false
    return
  end
  if self.hsMainPet == nil then
    Toast(textRes.Pet[237])
    self.useYuanBaoMakePet = false
    self.uiObjs.Btn_UseDep2ndPet:GetComponent("UIToggle").value = false
    return
  end
  if self.hsMainPet ~= nil and #self.hsMainPet:GetSkillIdList() == 10 then
    Toast(textRes.Pet[242])
    self.useYuanBaoMakePet = false
    self.uiObjs.Btn_UseDep2ndPet:GetComponent("UIToggle").value = false
    return
  end
  self.useYuanBaoMakePet = self.uiObjs.Btn_UseDep2ndPet:GetComponent("UIToggle").value
  if self.useYuanBaoMakePet then
    self:UpdateHuaShengYuanBao()
  else
    self:RemoveFakeSubPet()
  end
end
def.static("table", "table").OnPetRememberedSkillSuccess = function()
  local self = instance
  self:UpdateMainPet()
  self:UpdateSkillRemenberInfo()
end
def.static("table", "table").OnPetUnrememberedSkillSuccess = function()
  local self = instance
  self:UpdateMainPet()
  self:UpdateSkillRemenberInfo()
end
def.static("table", "table").OnPetYaoLiChange = function(params, context)
  local self = instance
  if self.hsMainPet == nil or self.hsMainPet.id ~= params.petId then
    return
  end
  local pet = PetMgr.Instance():GetPet(params.petId)
  local Img_BgPower = self.uiObjs.Img_HS_BgPetInfo01:FindDirect("Img_BgPower")
  PetUtility.TweenYaoLiUIFromPet(Img_BgPower, pet, params)
end
def.static("table", "table").OnPetInfoUpdate = function(params, context)
  local petId = params[1]
  local self = instance
  local subPetId
  if self.hsSubPet then
    subPetId = self.hsSubPet.id
  end
  if petId == subPetId then
    self:UpdateSubPet()
  end
end
def.static("table", "table").OnPetLearnSkillSuccess = function(params, context)
  local petId = params.petId
  local self = instance
  local subPetId
  if self.hsSubPet then
    subPetId = self.hsSubPet.id
  end
  if petId == subPetId then
    self:PlayLearnSkillFX(params.skillId)
  end
end
def.method("number").PlayLearnSkillFX = function(self, skillId)
  if self.hsSubPet == nil then
    return
  end
  local pet = self.hsSubPet
  local skillList = pet.skillIdList
  local newSkillIdx = 0
  for i = 1, #skillList do
    if skillList[i] == skillId then
      newSkillIdx = i
      break
    end
  end
  local skillItem = self.uiObjs.Img_HS_BgSkillGroup02:FindDirect(string.format("Img_HS_BgSkill02_%02d", newSkillIdx))
  if skillItem ~= nil then
    local worldPos = skillItem.transform:TransformPoint(EC.Vector3.new(0, 0, 0))
    local pos = self.m_node.transform:InverseTransformPoint(worldPos)
    self.uiObjs.LearnSkillFX.localPosition = pos
    self.uiObjs.LearnSkillFX:SetActive(false)
    self.uiObjs.LearnSkillFX:SetActive(true)
  end
end
def.static("table", "table").OnPetHuaShengGuarantee = function(params, context)
  local self = instance
  self:PlayHuaShengGuaranteeEffect()
end
def.static("table", "table").OnPetYuanBaoMakePrice = function(params, context)
  local self = instance
  local petInfo = params
  if self.useYuanBaoMakePet and self.hsMainPet ~= nil and self.hsMainPet.id == petInfo.petId then
    self:UpdateSubPetPrice(petInfo.needYuanBaoCount)
    self:MakeSubPetData(petInfo)
    self:UpdateHuaShengEnsureInfo()
    self:CalculateNeedYuanbao()
  end
end
def.static("table", "table").OnPetHuaShengSuccess = function(params, context)
  local self = instance
  local petInfo = params
  if self.useYuanBaoMakePet then
  end
end
def.method().PlayHuaShengGuaranteeEffect = function(self)
  self.uiObjs.HuaShengGuaranteeFX:SetActive(false)
  self.uiObjs.HuaShengGuaranteeFX:SetActive(true)
end
def.override("string", "boolean").onPress = function(self, id, state)
  if id == "Img_BgPower" then
    self:OnYaoLiPressHS(state)
  end
end
def.method("boolean").OnYaoLiPressHS = function(self, state)
  local CommonUISmallTip = require("GUI.CommonUISmallTip")
  if state == false then
    CommonUISmallTip.Instance():HideTip()
    return
  end
  local sourceObj = self.uiObjs.Img_HS_BgPetInfo01:FindDirect("Img_BgPower")
  local position = UICamera.lastWorldPosition
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = sourceObj:GetComponent("UIWidget")
  local CommonUISmallTip = require("GUI.CommonUISmallTip")
  CommonUISmallTip.Instance():ShowTip(textRes.Pet[139], screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), -1)
end
return PetPanelHuaShengNode.Commit()
