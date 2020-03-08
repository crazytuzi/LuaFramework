local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PetPanelNodeBase = require("Main.Pet.ui.PetPanelNodeBase")
local PetPanelBasicNode = Lplus.Extend(PetPanelNodeBase, "PetPanelBasicNode")
local PetMgr = require("Main.Pet.mgr.PetMgr")
local PetMgrInstance = PetMgr.Instance()
local PetUtility = require("Main.Pet.PetUtility")
local PetData = Lplus.ForwardDeclare("PetData")
local EC = require("Types.Vector3")
local Vector3 = EC.Vector3
local ECModel = require("Model.ECModel")
local GUIUtils = require("GUI.GUIUtils")
local PetModule = require("Main.Pet.PetModule")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local GameUnitType = require("consts.mzm.gsp.common.confbean.GameUnitType")
local FightMgr = require("Main.Fight.FightMgr")
local def = PetPanelBasicNode.define
local NOT_SELECTED = 0
def.field("table").cwModel = nil
def.field("table").cwModel1 = nil
def.field("boolean").cwIsDrag = false
def.const("table").equipmentSlotOrder = {
  PetData.PetEquipmentType.EQUIP_NECKLACE,
  PetData.PetEquipmentType.EQUIP_HELMET,
  PetData.PetEquipmentType.EQUIP_AMULET
}
def.field("number").lastSelectedPetIndex = 0
def.field("userdata").ui_Img_CW_Bg0 = nil
def.field("userdata").ui_Img_CW_BgPower = nil
def.field("userdata").ui_Img_CW_BgImage0 = nil
def.field("userdata").ui_Img_CW_BgBasic = nil
def.field("userdata").ui_Grid_CW_Skill = nil
def.field("userdata").ui_Img_ZB_Bg0 = nil
def.field("userdata").ui_Tab_Atttribute = nil
def.field("userdata").ui_Tab_Skill = nil
def.field("userdata").ui_Tab_Equip = nil
def.field("userdata").ui_SX_Img_FS_PetDept = nil
def.field("userdata").ui_ZB_Img_FS_PetDept = nil
def.field("number").lastPetTypeId = 0
def.field("boolean").lastPetDecorate = false
def.field("table").btnJinjieAndJiadianOriginPos = nil
local instance
def.static("=>", PetPanelBasicNode).Instance = function()
  if instance == nil then
    instance = PetPanelBasicNode()
  end
  return instance
end
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  PetPanelNodeBase.Init(self, base, node)
  local petSkill = require("main.pet.ui.PetPanelSkillNode")
  petSkill.Instance():Init(base, node)
end
def.override().OnShow = function(self)
  self.lastPetTypeId = 0
  self.lastPetDecorate = false
  local petSkill = require("main.pet.ui.PetPanelSkillNode")
  petSkill.Instance():OnShow()
  self.lastSelectedPetIndex = self.m_base.selectedPetIndex
  self:InitUI()
  self:UpdateUI()
  local petSkill = require("main.pet.ui.PetPanelSkillNode")
  petSkill.Instance():OnShow()
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_USE_EQUIPMENT_SUCCESS, PetPanelBasicNode.OnUseEquipmentSuccess)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.MODEL_PROP_CHANGED, PetPanelBasicNode.OnSyncFightProp)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, PetPanelBasicNode.OnLeaveFight)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_YAOLI_CHANGE, PetPanelBasicNode.OnPetYaoLiChange)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_USE_EQUIPMENT_SUCCESS, PetPanelBasicNode.OnUseEquipmentSuccess)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.MODEL_PROP_CHANGED, PetPanelBasicNode.OnSyncFightProp)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, PetPanelBasicNode.OnLeaveFight)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_YAOLI_CHANGE, PetPanelBasicNode.OnPetYaoLiChange)
  local petSkill = require("main.pet.ui.PetPanelSkillNode")
  petSkill.Instance():OnHide()
  self:Clear()
end
def.override().OnDestroy = function(self)
  self:Clear()
end
def.override().InitUI = function(self)
  PetPanelNodeBase.InitUI(self)
  self.ui_Img_CW_Bg0 = self.m_node:FindDirect("SX/Img_CW_Bg0")
  self.ui_Img_CW_BgPower = self.ui_Img_CW_Bg0:FindDirect("Img_BgPower")
  self.ui_Img_CW_BgImage0 = self.ui_Img_CW_Bg0:FindDirect("Img_CW_BgImage0")
  self.ui_Img_CW_BgBasic = self.ui_Img_CW_Bg0:FindDirect("Img_CW_BgBasic")
  self.ui_Img_ZB_Bg0 = self.m_node:FindDirect("ZB/Img_ZB_BgImage0")
  self.ui_SX_Img_FS_PetDept = self.m_node:FindDirect("SX/Img_FS_PetDept")
  self.ui_ZB_Img_FS_PetDept = self.m_node:FindDirect("ZB/Img_ZB_BgImage0/Img_FS_PetDept")
end
def.override("string").onClick = function(self, id)
  if id == "Btn_Tips" then
    self:OnTipButtonClicked()
  end
  local petSkill = require("main.pet.ui.PetPanelSkillNode")
  if self.isEmpty then
    return
  end
  if id == "Btn_Fight" then
    self:OnFightingButtonClick()
  elseif id == "Btn_ChangName" then
    self:OnRenameButtonClick()
  elseif id == "Btn_Show" then
    self:OnDisplayButtonClick()
  elseif id == "Btn_Abandon" then
    self:OnFreeButtonClick()
  elseif id == "Btn_CW_Distribute" then
    self:OnAssignPropButtonClick()
  elseif id == "Btn_CW_Jinjie" then
    self:OnJinjieButtonClick()
  elseif id == "Btn_CW_Remenber" then
    self:OnRememberSkillButtonClick()
  elseif id == "Btn_CW_Bone" then
    self:OnLianGuButtonClick()
  elseif id == "Btn_Share" then
    self:OnShareButtonClicked()
  elseif string.sub(id, 1, 4) == "Pet_" then
    local index = tonumber(string.sub(id, 5, -1))
    self:OnPetItemClick(index)
  elseif string.sub(id, 1, 15) == "Img_CW_BgEquip0" then
    local index = tonumber(string.sub(id, 16, -1))
    self:OnPetEquipmentClick(index)
  elseif string.sub(id, 1, #"Btn_CW_Decoration0") == "Btn_CW_Decoration0" then
    local index = tonumber(string.sub(id, -2, -1))
    self:OnPetDecorationButtonClick(index)
  elseif id == "Model_CW" then
    self:OnClickPetModel()
  elseif id == "Btn_CW_Add" then
    self:OnAddPetExpButtonClicked()
  elseif id == "Btn_Promote" then
    self:OnPromoteButtonClicked()
  elseif id == "Tap_SX" then
    if self.cwModel ~= nil then
      self.cwModel:Play(_G.ActionName.Stand)
    end
    local PetPanel = Lplus.ForwardDeclare("PetPanel")
    PetPanel.Instance().SubNodeId = 1
  elseif id == "Tap_Equip" then
    if self.cwModel1 ~= nil then
      self.cwModel1:Play(_G.ActionName.Stand)
    end
    local PetPanel = Lplus.ForwardDeclare("PetPanel")
    PetPanel.Instance().SubNodeId = 3
  elseif id == "Tap_JN" then
    local PetPanel = Lplus.ForwardDeclare("PetPanel")
    PetPanel.Instance().SubNodeId = 2
  elseif id == "Img_JieWei" then
    self:OnPetStageLevelClick()
  elseif id == "Btn_Draw" then
    self:OnBtnDrawClicked()
  elseif id == "Btn_DrawTip" then
    self:OnBtnDrawTipClicked()
  elseif id == "Btn_Shape" then
    self:OnBtnShapeClicked()
  end
  local petSkill = require("main.pet.ui.PetPanelSkillNode")
  petSkill.Instance():onClick(id)
end
def.method().OnTipButtonClicked = function(self)
  local tipId = PetModule.PET_INFO_TIP_ID
  GUIUtils.ShowHoverTip(tipId)
end
def.override("string", "boolean").onPress = function(self, id, state)
  if string.sub(id, 1, #"Img_CW_BgAttribute") == "Img_CW_BgAttribute" then
    local index = tonumber(string.sub(id, #"Img_CW_BgAttribute" + 1, -1))
    self:OnAttrTipPressed(index, state)
  elseif id == "Img_BgPower" then
    self:OnYaoLiPress(state)
  end
  local petSkill = require("main.pet.ui.PetPanelSkillNode")
  petSkill.Instance():onPress(id, state)
end
def.method("number").OnPetItemClick = function(self, index)
  if index == self.m_base.selectedPetIndex then
    return
  end
  self:SetSelectedPet(index)
  if PetMgrInstance.petList == nil then
    warn("OnPetItemToggle petList = nil")
    return
  end
  local petId = self.m_base.petIdList[index]
  local pet = PetMgrInstance:GetPet(petId)
  self:SetPetInfo(pet, index)
  local petSkill = require("main.pet.ui.PetPanelSkillNode")
  petSkill.Instance():OnPetItemClick(index)
end
def.method().OnFightingButtonClick = function(self)
  local petId = self.m_base.petIdList[self.m_base.selectedPetIndex]
  PetModule.Instance():TogglePetFightingState(petId)
end
def.method().OnRenameButtonClick = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local CommonRenamePanel = require("GUI.CommonRenamePanel").Instance()
  CommonRenamePanel:ShowPanel(textRes.Pet[6], false, PetPanelBasicNode.OnRenamePanelCallback, self)
end
def.method().OnDisplayButtonClick = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local petId = self.m_base.petIdList[self.m_base.selectedPetIndex]
  PetModule.Instance():TogglePetDisplayState(petId)
end
def.method().OnFreeButtonClick = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local petId = self.m_base.petIdList[self.m_base.selectedPetIndex]
  PetModule.Instance():FreePet(petId)
end
def.method().OnAssignPropButtonClick = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local petId = self.m_base.petIdList[self.m_base.selectedPetIndex]
  require("Main.Pet.ui.PetAssignPropPanel").Instance():SetActivePet(petId)
  require("Main.Pet.ui.PetAssignPropPanel").Instance():ShowPanel()
end
def.method().OnRememberSkillButtonClick = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local petId = self.m_base.petIdList[self.m_base.selectedPetIndex]
  require("Main.Pet.ui.PetRememberSkillPanel").Instance():SetActivePet(petId)
  require("Main.Pet.ui.PetRememberSkillPanel").Instance():ShowPanel()
end
def.method().OnLianGuButtonClick = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local petId = self.m_base.petIdList[self.m_base.selectedPetIndex]
  require("Main.Pet.ui.PetLianGuPanel").Instance():SetActivePet(petId)
  require("Main.Pet.ui.PetLianGuPanel").Instance():ShowPanel()
end
def.method("number").OnPetEquipmentClick = function(self, index)
  local petId = self.m_base.petIdList[self.m_base.selectedPetIndex]
  local pet = PetMgrInstance:GetPet(petId)
  local equipments = pet.equipments or {}
  local slot = PetPanelBasicNode.equipmentSlotOrder[index]
  local equipment = equipments[slot]
  local ui_Img_CW_BgImage0 = self.m_node:FindDirect("ZB/Group_Equip")
  if equipment then
    local sourceObj = ui_Img_CW_BgImage0:FindDirect(string.format("Img_CW_BgEquip%02d", index))
    PetUtility.ShowPetRepEquipmentTip(equipment, sourceObj, slot)
  else
    if _G.CheckCrossServerAndToast() then
      return
    end
    local CommonUsePanel = require("GUI.CommonUsePanel")
    local itemIdList = require("Main.Pet.mgr.PetEquipmentMgr").Instance():GetEquipmentSourceItemIdList(slot)
    CommonUsePanel.Instance():SetItemIdList(itemIdList)
    CommonUsePanel.Instance():ShowPanel(PetMgr.PetEquipmentItemFilter, nil, CommonUsePanel.Source.PetItemBag, {slot})
  end
end
def.method("number").OnPetDecorationButtonClick = function(self, index)
  if index == 1 then
    if _G.CheckCrossServerAndToast() then
      return
    end
    local PetDecorationPanel = require("Main.Pet.ui.PetDecorationPanel")
    local petId = self.m_base.petIdList[self.m_base.selectedPetIndex]
    PetDecorationPanel.Instance():SetActivePet(petId)
    PetDecorationPanel.Instance():ShowPanel()
  elseif index == 2 then
    Toast(textRes.Pet[74])
  end
end
def.method().OnPetStageLevelClick = function(self)
  local petId = self.m_base.petIdList[self.m_base.selectedPetIndex]
  local pet = PetMgrInstance:GetPet(petId)
  PetUtility.ShowPetStageLevelTips(pet)
end
def.method().OnBtnDrawClicked = function(self)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_PET_CHANGE_MODEL) then
    Toast(textRes.Pet[219])
    return
  end
  local petId = self.m_base.petIdList[self.m_base.selectedPetIndex]
  if petId == nil then
    return
  end
  local pet = PetMgrInstance:GetPet(petId)
  if pet.extraModelCfgId <= 0 then
    self:ExtractPetModel(pet)
  else
    self:ClearPetExtraModel(pet)
  end
end
def.method("table").ExtractPetModel = function(self, pet)
  if pet == nil then
    return
  end
  if _G.PlayerIsInFight() then
    Toast(textRes.Pet[204])
    return
  end
  local petCfg = pet:GetPetCfgData()
  if petCfg.type == PetData.PetType.WILD then
    Toast(textRes.Pet[195])
    return
  end
  local fightPet = PetMgr.Instance():GetFightingPet()
  if fightPet ~= nil and fightPet.id == pet.id then
    Toast(textRes.Pet[196])
    return
  end
  local displayPet = PetMgr.Instance():GetDisplayPet()
  if displayPet ~= nil and displayPet.id == pet.id then
    Toast(textRes.Pet[197])
    return
  end
  local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr").Instance()
  local heroProp = HeroPropMgr.heroProp
  if petCfg.carryLevel > heroProp.level then
    Toast(textRes.Pet[198])
    return
  end
  self:ConfirmToExtractPetModel(pet)
end
def.method("table").ConfirmToExtractPetModel = function(self, pet)
  local petCfg = pet:GetPetCfgData()
  local extractCostCfg = PetUtility.GetPetHuiZhiCostCfgByPetType(petCfg.type)
  if extractCostCfg ~= nil then
    do
      local title = textRes.Pet[199]
      local itemBase = ItemUtils.GetItemBase(extractCostCfg.priceItemId)
      local name = itemBase.name
      local iconId = itemBase.icon
      local hasNum = 0
      local items = ItemModule.Instance():GetItemsByItemType(ItemModule.BAG, extractCostCfg.costType)
      for k, v in pairs(items) do
        hasNum = hasNum + v.number
      end
      local numStr = ""
      local hasEnoughItem = false
      if hasNum >= extractCostCfg.costNum then
        numStr = string.format("%d/%d", hasNum, extractCostCfg.costNum)
        hasEnoughItem = true
      else
        numStr = string.format("[ff0000]%d[-]/%d", hasNum, extractCostCfg.costNum)
        hasEnoughItem = false
      end
      local HtmlHelper = require("Main.Chat.HtmlHelper")
      local desc = string.format(textRes.Item[33], extractCostCfg.costNum, HtmlHelper.NameColor[itemBase.namecolor], name, string.format(textRes.Pet[200], pet.name, textRes.Pet.Type[petCfg.type]))
      local ItemConsumeDlg = require("Main.Item.ui.ItemConsumeDlg")
      ItemConsumeDlg.ShowItemConsume(extractCostCfg.priceItemId, title, name, numStr, desc, iconId, 0, function(select)
        if select < 0 then
        elseif select == 0 then
          if hasEnoughItem then
            self:TryToExtractPetModel(pet, false, 0)
          else
            Toast(textRes.Pet[222])
          end
        end
      end)
    end
  end
end
def.method("table", "boolean", "number").TryToExtractPetModel = function(self, pet, useYuanBao, needYuanbao)
  local function GetPetModelItemReq(petId, useYuanBao, needYuanbao)
    if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_PET_CHANGE_MODEL) then
      Toast(textRes.Pet[219])
      return
    end
    PetMgr.Instance():GetPetModelItemReq(petId, useYuanBao, needYuanbao)
  end
  local petCfg = pet:GetPetCfgData()
  local PetYaoLi = require("consts.mzm.gsp.pet.confbean.PetYaoLi")
  if pet.isBinded or petCfg.type == PetData.PetType.BIANYI or petCfg.type == PetData.PetType.SHENSHOU or petCfg.type == PetData.PetType.MOSHOU or pet:GetYaoLiLevel() <= PetYaoLi.A then
    local PetProtectionPanel = require("Main.Pet.ui.PetProtectionPanel")
    PetProtectionPanel.Instance():SetProtectOpertation(pet.id, function()
      GetPetModelItemReq(pet.id, useYuanBao, needYuanbao)
    end, textRes.Pet[212], textRes.Pet[213])
    PetProtectionPanel.Instance():ShowPanel()
  else
    GetPetModelItemReq(pet.id, useYuanBao, needYuanbao)
  end
end
def.method("table").ClearPetExtraModel = function(self, pet)
  if pet == nil then
    return
  end
  if _G.PlayerIsInFight() then
    Toast(textRes.Pet[205])
    return
  end
  local fightPet = PetMgr.Instance():GetFightingPet()
  if fightPet ~= nil and fightPet.id == pet.id then
    Toast(textRes.Pet[206])
    return
  end
  local displayPet = PetMgr.Instance():GetDisplayPet()
  if displayPet ~= nil and displayPet.id == pet.id then
    Toast(textRes.Pet[207])
    return
  end
  local petCfg = pet:GetPetCfgData()
  local needItemId = PetUtility.Instance():GetPetConstants("CANCEL_PET_CHANGEMODEL_ITEM_ID")
  local needItemNum = PetUtility.Instance():GetPetConstants("CANCEL_PET_CHANGEMODEL_ITEM_COST_NUM")
  local ItemConsumeHelper = require("Main.Item.ItemConsumeHelper")
  ItemConsumeHelper.Instance():ShowItemConsume(textRes.Pet[201], string.format(textRes.Pet[202], pet.name, textRes.Pet.Type[petCfg.type]), needItemId, needItemNum, function(select)
    local function CancelPetModelChangeItemReq(petId, useYuanBao, needYuanbao)
      if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_PET_CHANGE_MODEL) then
        Toast(textRes.Pet[219])
        return
      end
      PetMgr.Instance():CancelPetModelChangeItemReq(petId, useYuanBao, needYuanbao)
    end
    if select < 0 then
    elseif select == 0 then
      CancelPetModelChangeItemReq(pet.id, false, 0)
    else
      CancelPetModelChangeItemReq(pet.id, true, select)
    end
  end)
end
def.method().OnBtnDrawTipClicked = function(self)
  local tipId = 701605032
  GUIUtils.ShowHoverTip(tipId)
end
def.method().OnBtnShapeClicked = function(self)
  local petId = self.m_base.petIdList[self.m_base.selectedPetIndex]
  if petId == nil then
    return
  end
  if _G.CheckCrossServerAndToast() then
    return
  end
  require("Main.Pet.ui.PetExtraModelPanel").Instance():ShowPanel(petId)
end
def.override().UpdateUI = function(self)
  self.m_base.ui_PetList:SetActive(true)
  self.m_base:SetPetList(PetMgrInstance.petList, PetMgrInstance.petNum)
  self.m_base:UpdateTuJianNotice()
  if PetMgrInstance:GetPetNum() == 0 then
    self.isEmpty = true
    self:ShowEmptyPage()
    return
  end
  self.isEmpty = false
  self:UpdateSelectedIndex()
  self.m_base:SetSelectedListItem(self.m_base.selectedPetIndex)
  local petId = self.m_base.petIdList[self.m_base.selectedPetIndex]
  self:UpdatePetInfo(petId)
end
def.method().ShowEmptyPage = function(self)
  self.m_base:SetPetListEmpty()
  local fakePet = PetData()
  self:SetPetName("")
  self:SetBasicProp(fakePet)
  self:ClearExpBar()
  self:ClearYaoLi()
  self:ClearPetStageLevel()
  self.ui_Img_CW_BgImage0:FindDirect("Label_CW_PetType"):GetComponent("UISprite").spriteName = "nil"
  self.ui_Img_CW_BgBasic:FindDirect("Btn_CW_Distribute/Img_CW_RedDistribute"):SetActive(false)
  local ui_Image_ZB_BgImage = self.m_node:FindDirect("ZB/Img_ZB_BgImage0")
  ui_Image_ZB_BgImage:FindDirect("Label_CW_PetType"):GetComponent("UISprite").spriteName = "nil"
  local ui_Image_CW_BgImage0 = self.m_node:FindDirect("ZB/Group_Equip")
  ui_Image_CW_BgImage0:FindDirect("Btn_CW_Decoration02"):SetActive(false)
  self.ui_Img_CW_BgImage0:FindDirect("Label_LevelLimited"):GetComponent("UILabel").text = ""
  self.ui_Img_ZB_Bg0:FindDirect("Label_LevelLimited"):GetComponent("UILabel").text = ""
  self.m_node:FindDirect("ZB/Btn_Draw"):SetActive(false)
  self.m_node:FindDirect("ZB/Btn_DrawTip"):SetActive(false)
  local ui_Img_CW_BgImage0 = self.m_node:FindDirect("ZB/Group_Equip")
  for i = 1, 3 do
    local uiTexture = ui_Img_CW_BgImage0:FindDirect(string.format("Img_CW_BgEquip0%d/Img_CW_IconEquip0%d", i, i)):GetComponent("UITexture")
    uiTexture.mainTexture = nil
  end
  GUIUtils.SetTexture(self.ui_SX_Img_FS_PetDept, 0)
  GUIUtils.SetTexture(self.ui_ZB_Img_FS_PetDept, 0)
  self:ClearModel()
end
def.method().Clear = function(self)
  self:ClearModel()
  self.ui_Img_CW_Bg0 = nil
  self.ui_Img_CW_BgPower = nil
  self.ui_Img_CW_BgImage0 = nil
  self.ui_Img_CW_BgBasic = nil
  self.ui_Grid_CW_Skill = nil
  self.ui_SX_Img_FS_PetDept = nil
  self.ui_ZB_Img_FS_PetDept = nil
end
def.method().UpdateSelectedIndex = function(self)
  self.m_base.selectedPetIndex = NOT_SELECTED
  for index, petId in ipairs(self.m_base.petIdList) do
    if petId == self.m_base.selectedPetId then
      self.m_base.selectedPetIndex = index
      break
    end
  end
  local index
  if self.m_base.selectedPetIndex == NOT_SELECTED and self.m_base.petIdList[1] then
    index = 1
  else
    index = self.m_base.selectedPetIndex
  end
  self:SetSelectedPet(index)
  self.m_base:SetSelectedListItem(index)
  self.lastSelectedPetIndex = self.m_base.selectedPetIndex
end
def.override("userdata").UpdatePetInfo = function(self, petId)
  self.m_base.petIdList = self.m_base.petIdList or {}
  local index = 0
  for i, id in pairs(self.m_base.petIdList) do
    if id == petId then
      index = i
      break
    end
  end
  local pet = PetMgrInstance:GetPet(petId)
  if index ~= 0 and pet then
    self:SetPetInfo(pet, index)
    local petSkill = require("main.pet.ui.PetPanelSkillNode")
    petSkill.Instance():SetPetInfo(index, pet)
  end
end
def.override("userdata").OnPetAdded = function(self, petId)
  self.m_base.petIdList = self.m_base.petIdList or {}
  self.m_base:SetPetList(PetMgrInstance.petList, PetMgrInstance.petNum)
  if self.isEmpty then
    self.isEmpty = false
    self:SetSelectedPet(1)
    self.m_base:SetSelectedListItem(self.m_base.selectedPetIndex)
    local pet = PetMgrInstance:GetPet(petId)
    self:SetPetInfo(pet, self.m_base.selectedPetIndex)
  else
    local index = 0
    for i, id in pairs(self.m_base.petIdList) do
      if id == self.m_base.selectedPetId then
        index = i
        break
      end
    end
    self:SetSelectedPet(index)
    self.m_base:SetSelectedListItem(index)
  end
  local petSkill = require("main.pet.ui.PetPanelSkillNode")
  petSkill.Instance():OnPetAdded(petId)
end
def.override("userdata").OnPetDeleted = function(self, petId)
  self.m_base:SetPetList(PetMgrInstance.petList, PetMgrInstance.petNum)
  if PetMgrInstance.petList == nil or PetMgrInstance.petNum == 0 then
    self.isEmpty = true
    self:SetSelectedPet(NOT_SELECTED)
    self:ShowEmptyPage()
  else
    local index = self.m_base.selectedPetIndex
    local nextPetId = self.m_base.petIdList[index]
    if not nextPetId then
      index = index - 1
    end
    local nextPetId = self.m_base.petIdList[index]
    self:SetSelectedPet(index)
    self.m_base:SetSelectedListItem(index)
    local pet = PetMgrInstance:GetPet(nextPetId)
    self:SetPetInfo(pet, index)
  end
  local petSkill = require("main.pet.ui.PetPanelSkillNode")
  petSkill.Instance():OnPetDeleted(petId)
end
def.method("number").SetSelectedPet = function(self, index)
  self.lastSelectedPetIndex = self.m_base.selectedPetIndex
  self.m_base.selectedPetIndex = index
  self.m_base.selectedPetId = self.m_base.petIdList[index]
end
def.method("table", "number").SetPetInfo = function(self, pet, index)
  self.m_base:SetListItemInfo(index, pet)
  self:SetPetName(pet.name)
  self:SetCarrayLevel(pet)
  self:SetBasicProp(pet)
  self:SetExpBar(pet)
  self:SetYaoLi(pet)
  self:SetEquipment(pet)
  self:SetPetOPButtonsState(pet)
  self:SetPetJinjieAndJiaDianPos(pet)
  self:SetPetChangeModelCardType(pet)
  if pet:CanJinjie() then
    self:SetPetStageLevel(pet.stageLevel)
  else
    self:ClearPetStageLevel()
  end
  self:SetPetDisplayModelName(pet)
  local petCfgData = pet:GetPetCfgData()
  local spriteName = PetUtility.GetPetTypeSpriteName(petCfgData.type)
  self.ui_Img_CW_BgImage0:FindDirect("Label_CW_PetType"):GetComponent("UISprite").spriteName = spriteName
  local ui_Image_ZB_BgImage0 = self.m_node:FindDirect("ZB/Img_ZB_BgImage0")
  ui_Image_ZB_BgImage0:FindDirect("Label_CW_PetType"):GetComponent("UISprite").spriteName = spriteName
  if pet:NeedAssignProp() then
    self.ui_Img_CW_BgBasic:FindDirect("Btn_CW_Distribute/Img_CW_RedDistribute"):SetActive(true)
  else
    self.ui_Img_CW_BgBasic:FindDirect("Btn_CW_Distribute/Img_CW_RedDistribute"):SetActive(false)
  end
  local ui_Image_CW_BgImage0 = self.m_node:FindDirect("ZB/Group_Equip")
  if pet.isDecorated then
    ui_Image_CW_BgImage0:FindDirect("Btn_CW_Decoration01"):SetActive(false)
    ui_Image_CW_BgImage0:FindDirect("Btn_CW_Decoration02"):SetActive(true)
  else
    ui_Image_CW_BgImage0:FindDirect("Btn_CW_Decoration01"):SetActive(true)
    ui_Image_CW_BgImage0:FindDirect("Btn_CW_Decoration02"):SetActive(false)
  end
  self:UpdateModel(pet)
end
def.method("string").SetPetName = function(self, petName)
  self.ui_Img_CW_BgImage0:FindDirect("Label_PetName01"):GetComponent("UILabel").text = petName
  local ui_Img_CW_BgImage0 = self.m_node:FindDirect("ZB/Img_ZB_BgImage0")
  ui_Img_CW_BgImage0:FindDirect("Label_PetName01"):GetComponent("UILabel").text = petName
end
def.method("table").SetCarrayLevel = function(self, pet)
  local cfg = pet:GetPetCfgData()
  local levelStr = string.format(textRes.Pet[152], cfg.carryLevel)
  self.ui_Img_CW_BgImage0:FindDirect("Label_LevelLimited"):GetComponent("UILabel").text = levelStr
  self.ui_Img_ZB_Bg0:FindDirect("Label_LevelLimited"):GetComponent("UILabel").text = levelStr
end
def.method("table").SetBasicProp = function(self, pet)
  local rootObj = self.ui_Img_CW_BgBasic
  local hp, mp = pet.hp, pet.mp
  if FightMgr.Instance().isInFight and PetMgr.Instance():IsPetInFightScene(pet.id) then
    local hpMpInfo = FightMgr.Instance():GetHpMpInfo()
    local petInfo
    for k, v in pairs(hpMpInfo) do
      if v.type == GameUnitType.PET then
        hp, mp = v.hp, v.mp
        break
      end
    end
  end
  local value, maxValue = pet.secondProp and pet.secondProp.maxHp or hp, 0
  self:SetHPBar(value, maxValue)
  local value, maxValue = pet.secondProp and pet.secondProp.maxMp or mp, 0
  self:SetMPBar(value, maxValue)
  local propNameList = {
    "phyAtk",
    "magAtk",
    "phyDef",
    "magDef",
    "speed"
  }
  for i = 1, 5 do
    local propName = propNameList[i]
    local value = pet.secondProp and pet.secondProp[propName] or ""
    rootObj:FindDirect(string.format("Img_CW_BgAttribute0%d/Label_CW_AttributeNum0%d", i, i)):GetComponent("UILabel"):set_text(value)
  end
end
def.method("number", "number").SetHPBar = function(self, value, maxValue)
  local rootObj = self.ui_Img_CW_BgBasic
  local ui_Slider_CW_HP = rootObj:FindDirect("Slider_CW_HP")
  local ui_Label_CW_SliderHP = ui_Slider_CW_HP:FindDirect("Label_CW_SliderHP")
  self:SetProgressBar(ui_Slider_CW_HP, ui_Label_CW_SliderHP, value, maxValue)
end
def.method("number", "number").SetMPBar = function(self, value, maxValue)
  local rootObj = self.ui_Img_CW_BgBasic
  local ui_Slider_CW_MP = rootObj:FindDirect("Slider_CW_MP")
  local ui_Label_CW_SliderMP = ui_Slider_CW_MP:FindDirect("Label_CW_SliderMP")
  self:SetProgressBar(ui_Slider_CW_MP, ui_Label_CW_SliderMP, value, maxValue)
end
def.method("table").SetExpBar = function(self, pet)
  local neededExp = pet:GetLevelUpNeededExp()
  local ui_Slider_CW_Exp = self.ui_Img_CW_BgImage0:FindDirect("Slider_CW_Exp")
  local ui_Label_CW_Exp = ui_Slider_CW_Exp:FindDirect("Label_CW_Exp")
  self:SetProgressBar(ui_Slider_CW_Exp, ui_Label_CW_Exp, pet.exp, neededExp)
end
def.method().ClearExpBar = function(self)
  local ui_Slider_CW_Exp = self.ui_Img_CW_BgImage0:FindDirect("Slider_CW_Exp")
  local ui_Label_CW_Exp = ui_Slider_CW_Exp:FindDirect("Label_CW_Exp")
  self:SetProgressBar(ui_Slider_CW_Exp, ui_Label_CW_Exp, 0, 0)
end
def.method("table").SetYaoLi = function(self, pet)
  PetUtility.SetYaoLiUIFromPet(self.ui_Img_CW_BgPower, pet)
  local ui_Img_CW_BgImage0 = self.m_node:FindDirect("ZB/Img_ZB_BgImage0")
  PetUtility.SetYaoLiUIFromPet(ui_Img_CW_BgImage0:FindDirect("Img_BgPower"), pet)
end
def.method().ClearYaoLi = function(self)
  PetUtility.SetYaoLiUI(self.ui_Img_CW_BgPower, 0, -1, -1)
  local ui_Img_CW_BgImage0 = self.m_node:FindDirect("ZB/Img_ZB_BgImage0")
  PetUtility.SetYaoLiUI(ui_Img_CW_BgImage0:FindDirect("Img_BgPower"), 0, -1, -1)
end
def.method().ClearPetStageLevel = function(self)
  local stageStarSX = self.m_node:FindDirect("SX/Img_CW_Bg0/Img_CW_BgImage0/Img_JieWei")
  local stageStarZB = self.m_node:FindDirect("ZB/Img_ZB_BgImage0/Img_JieWei")
  if stageStarSX ~= nil then
    stageStarSX:SetActive(false)
  end
  if stageStarZB ~= nil then
    stageStarZB:SetActive(false)
  end
end
def.method("number").SetPetStageLevel = function(self, stageLevel)
  local stageStarSX = self.m_node:FindDirect("SX/Img_CW_Bg0/Img_CW_BgImage0/Img_JieWei")
  local stageStarZB = self.m_node:FindDirect("ZB/Img_ZB_BgImage0/Img_JieWei")
  if stageStarSX ~= nil then
    stageStarSX:SetActive(true)
    GUIUtils.SetSprite(stageStarSX, "Img_Jie" .. stageLevel)
    PetUtility.AddBoxCollider(stageStarSX)
  end
  if stageStarZB ~= nil then
    stageStarZB:SetActive(true)
    GUIUtils.SetSprite(stageStarZB, "Img_Jie" .. stageLevel)
    PetUtility.AddBoxCollider(stageStarZB)
  end
end
def.method("table").SetPetDisplayModelName = function(self, pet)
  local modelNameInZB = self.m_node:FindDirect("ZB/Label_ChangeName")
  local modelNameInSX = self.m_node:FindDirect("SX/Img_CW_Bg0/Img_CW_BgImage0/Label_ChangeName")
  GUIUtils.SetActive(modelNameInZB, true)
  GUIUtils.SetActive(modelNameInSX, true)
  if pet.extraModelCfgId ~= 0 then
    local displayModelInfo = ItemUtils.GetItemBase(pet.extraModelCfgId)
    if displayModelInfo ~= nil then
      GUIUtils.SetText(modelNameInZB, string.format(textRes.Pet[218], displayModelInfo.name))
      GUIUtils.SetText(modelNameInSX, string.format(textRes.Pet[218], displayModelInfo.name))
    else
      GUIUtils.SetText(modelNameInZB, "")
      GUIUtils.SetText(modelNameInSX, "")
    end
  else
    GUIUtils.SetText(modelNameInZB, "")
    GUIUtils.SetText(modelNameInSX, "")
  end
end
def.method("table").SetEquipment = function(self, pet)
  local equipments = pet.equipments or {}
  local equipmentSlotTable = {
    {
      equipments[PetPanelBasicNode.equipmentSlotOrder[1]]
    },
    {
      equipments[PetPanelBasicNode.equipmentSlotOrder[2]]
    },
    {
      equipments[PetPanelBasicNode.equipmentSlotOrder[3]]
    }
  }
  local ui_Img_CW_BgImage0 = self.m_node:FindDirect("ZB/Group_Equip")
  for i, value in ipairs(equipmentSlotTable) do
    local v = value[1]
    local Img_CW_BgEquip = ui_Img_CW_BgImage0:FindDirect(string.format("Img_CW_BgEquip0%d", i))
    local Img_CW_IconEquip = Img_CW_BgEquip:FindDirect(string.format("Img_CW_IconEquip0%d", i))
    local Img_CW_Empty = Img_CW_BgEquip:FindDirect("Img_CW_Empty")
    if v then
      local itemId = v.id
      local itemBase = ItemUtils.GetItemBase(itemId)
      GUIUtils.SetTexture(Img_CW_IconEquip, itemBase.icon)
      GUIUtils.SetActive(Img_CW_Empty, false)
    else
      GUIUtils.SetTexture(Img_CW_IconEquip, 0)
      GUIUtils.SetActive(Img_CW_Empty, true)
    end
  end
  local Btn_Draw = self.m_node:FindDirect("ZB/Btn_Draw")
  local Btn_DrawTip = self.m_node:FindDirect("ZB/Btn_DrawTip")
  local isDrawOpen = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_PET_CHANGE_MODEL)
  Btn_Draw:SetActive(isDrawOpen)
  Btn_DrawTip:SetActive(isDrawOpen)
  local Label = Btn_Draw:FindDirect("Label")
  if 0 >= pet.extraModelCfgId then
    GUIUtils.SetText(Label, textRes.Pet[194])
  else
    GUIUtils.SetText(Label, textRes.Pet[203])
  end
end
def.method("table").SetPetOPButtonsState = function(self, pet)
  local fightingStateText
  if pet.isFighting then
    fightingStateText = textRes.Pet[3]
  else
    fightingStateText = textRes.Pet[2]
  end
  self.m_node:FindDirect("SX/Btn_Fight/Label_Fight"):GetComponent("UILabel"):set_text(fightingStateText)
  local displayStateText
  if pet.isDisplay then
    displayStateText = textRes.Pet[5]
  else
    displayStateText = textRes.Pet[4]
  end
  self.m_node:FindDirect("SX/Btn_Show/Label_Show"):GetComponent("UILabel"):set_text(displayStateText)
end
def.method("table").SetPetJinjieAndJiaDianPos = function(self, pet)
  local btnJiadian = self.ui_Img_CW_BgBasic:FindDirect("Btn_CW_Distribute")
  local btnJinjie = self.ui_Img_CW_BgBasic:FindDirect("Btn_CW_Jinjie")
  if self.btnJinjieAndJiadianOriginPos == nil then
    self.btnJinjieAndJiadianOriginPos = {}
    self.btnJinjieAndJiadianOriginPos.jinjiePos = btnJinjie.localPosition
    self.btnJinjieAndJiadianOriginPos.jiadianPos = btnJiadian.localPosition
  end
  local jinjiePos = self.btnJinjieAndJiadianOriginPos.jinjiePos
  local jiadianPos = self.btnJinjieAndJiadianOriginPos.jiadianPos
  if pet:CanJinjie() and IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_PET_STAGE_LEVELUP) then
    btnJiadian.localPosition = jiadianPos
    btnJinjie:SetActive(true)
  else
    btnJinjie:SetActive(false)
    btnJiadian.localPosition = EC.Vector3.new((jinjiePos.x + jiadianPos.x) / 2, jinjiePos.y, 0)
  end
end
def.method("table").SetPetChangeModelCardType = function(self, pet)
  if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_CHANGE_MODEL_CARD) then
    GUIUtils.SetTexture(self.ui_SX_Img_FS_PetDept, 0)
    GUIUtils.SetTexture(self.ui_ZB_Img_FS_PetDept, 0)
  else
    local petCfgData = pet:GetPetCfgData()
    local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
    local classCfg = TurnedCardUtils.GetCardClassCfg(petCfgData.changeModelCardClassType)
    GUIUtils.SetTexture(self.ui_SX_Img_FS_PetDept, classCfg.smallIconId)
    GUIUtils.SetTexture(self.ui_ZB_Img_FS_PetDept, classCfg.smallIconId)
  end
end
def.static("string", "table", "=>", "boolean").OnRenamePanelCallback = function(name, self)
  if not self:ValidEnteredName(name) then
    return true
  elseif SensitiveWordsFilter.ContainsSensitiveWord(name) then
    Toast(textRes.Pet[18])
    return true
  elseif SensitiveWordsFilter.ContainsSensitiveWord(name, "Name") then
    Toast(textRes.Pet[44])
    return true
  elseif name == "" then
    Toast(textRes.Pet[17])
    return true
  else
    local petId = self.m_base.petIdList[self.m_base.selectedPetIndex]
    PetMgrInstance:RenamePet(petId, name)
    return false
  end
end
def.method("string", "=>", "boolean").ValidEnteredName = function(self, enteredName)
  local NameValidator = require("Main.Common.NameValidator")
  local isValid, reason, _ = NameValidator.Instance():IsValid(enteredName)
  if isValid then
    return true
  else
    if reason == NameValidator.InvalidReason.TooShort then
      Toast(textRes.Login[15])
    elseif reason == NameValidator.InvalidReason.TooLong then
      Toast(textRes.Login[14])
    elseif reason == NameValidator.InvalidReason.NotInSection then
      Toast(textRes.Pet[46])
    end
    return false
  end
end
def.method(PetData).UpdateModel = function(self, pet)
  if self.lastPetTypeId == pet.typeId and self.lastPetDecorate == pet.isDecorated then
    return
  end
  local objModel = self.ui_Img_CW_BgImage0:FindDirect("Model_CW")
  local uiModel = objModel:GetComponent("UIModel")
  if self.cwModel ~= nil then
    self.cwModel:Destroy()
    self.cwModel = nil
  end
  self.cwModel = PetUtility.CreateAndAttachPetUIModel(pet, uiModel, nil)
  local ui_Image_CW_BgImage0 = self.m_node:FindDirect("ZB/Img_ZB_BgImage0")
  local objModel1 = ui_Image_CW_BgImage0:FindDirect("Model_CW")
  local uiModel1 = objModel1:GetComponent("UIModel")
  if self.cwModel1 ~= nil then
    self.cwModel1:Destroy()
    self.cwModel1 = nil
  end
  self.cwModel1 = PetUtility.CreateAndAttachPetUIModel(pet, uiModel1, nil)
  self.lastPetTypeId = pet.typeId
  self.lastPetDecorate = pet.isDecorated
end
def.override("string").onDragStart = function(self, id)
  print("onDragStart", id)
  if id == "Model_CW" then
    self.cwIsDrag = true
  end
end
def.override("string").onDragEnd = function(self, id)
  self.cwIsDrag = false
end
def.override("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.cwIsDrag == true and self.cwModel then
    self.cwModel:SetDir(self.cwModel.m_ang - dx / 2)
  end
  if self.cwIsDrag == true and self.cwModel1 then
    self.cwModel1:SetDir(self.cwModel.m_ang - dx / 2)
  end
end
def.method().ClearModel = function(self)
  if self.cwModel then
    self.cwModel:Destroy()
    self.cwModel = nil
  end
  if self.cwModel1 then
    self.cwModel1:Destroy()
    self.cwModel1 = nil
  end
  if self.ui_Img_CW_BgImage0 then
    local objModel = self.ui_Img_CW_BgImage0:FindDirect("Model_CW")
    local uiModel = objModel:GetComponent("UIModel")
    uiModel.modelGameObject = nil
  end
  local ui_Image_CW_BgImage0 = self.m_node:FindDirect("ZB/Img_ZB_BgImage0")
  if ui_Img_CW_BgImage0 then
    local objModel1 = ui_Img_CW_BgImage0:FindDirect("Model_CW")
    local uiModel1 = objModel1:GetComponent("UIModel")
    uiModel1.modelGameObject = nil
  end
end
def.override().OnBagInfoSynchronized = function(self)
end
def.static("table", "table").OnPetBagCapacityChange = function(params)
  local self = instance
  local cap = params[1]
  self.m_base:SetPetBagCapacityInfo(PetMgrInstance.petNum, PetMgrInstance.bagSize)
end
def.static("table", "table").OnPetRememberedSkillSuccess = function(params)
  local self = instance
  self:UpdateSkillList()
end
def.static("table", "table").OnPetUnrememberedSkillSuccess = function(params)
  local self = instance
  self:UpdateSkillList()
end
def.static("table", "table").OnSPetEquipItemRes = function(params)
  local self = instance
  self:UpdateSkillList()
end
def.method().UpdateSkillList = function(self)
  local petId = self.m_base.petIdList[self.m_base.selectedPetIndex]
  local pet = PetMgrInstance:GetPet(petId)
  self:SetSkillList(pet)
end
def.method().OnClickPetModel = function(self)
  PetUtility.PlayPetClickedAnimation(self.cwModel)
  PetUtility.PlayPetClickedAnimation(self.cwModel1)
end
def.method().OnAddPetExpButtonClicked = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local petId = self.m_base.petIdList[self.m_base.selectedPetIndex]
  local CommonUsePanel = require("GUI.CommonUsePanel")
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local itemIdList = ItemUtils.GetNotProprietaryItemIdsByType(ItemType.PET_EXP_ITEM)
  itemIdList[2] = nil
  CommonUsePanel.Instance():SetItemIdList(itemIdList)
  CommonUsePanel.Instance():ShowPanel(PetMgr.PetExpItemFilter, nil, CommonUsePanel.Source.PetItemBag, {petId})
end
def.method().OnShareButtonClicked = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local petId = self.m_base.petIdList[self.m_base.selectedPetIndex]
  local params = {}
  params.petId = petId
  Event.DispatchEvent(ModuleId.SHARE, gmodule.notifyId.Share.SharePet, params)
end
def.static("table", "table").OnSyncFightProp = function(params)
  local self = instance
  local petId = self.m_base.petIdList[self.m_base.selectedPetIndex]
  local pet = PetMgrInstance:GetPet(petId)
  if pet == nil then
    return
  end
  if PetMgr.Instance():IsPetInFightScene(pet.id) and params.type == GameUnitType.PET then
    self:SetFightProp(pet, params)
  end
end
def.method("table", "table").SetFightProp = function(self, pet, data)
  local maxHp = data.hpmax or pet.secondProp.maxHp
  self:SetHPBar(data.hp, maxHp)
  self:SetMPBar(data.mp, pet.secondProp.maxMp)
end
def.static("table", "table").OnLeaveFight = function(params)
  local self = instance
  local petId = self.m_base.petIdList[self.m_base.selectedPetIndex]
  local pet = PetMgrInstance:GetPet(petId)
  if pet == nil then
    return
  end
  self:SetHPBar(pet.hp, pet.secondProp.maxHp)
  self:SetMPBar(pet.mp, pet.secondProp.maxMp)
end
def.method("boolean").OnYaoLiPress = function(self, state)
  local CommonUISmallTip = require("GUI.CommonUISmallTip")
  if state == false then
    CommonUISmallTip.Instance():HideTip()
    return
  end
  local sourceObj = self.ui_Img_CW_BgPower
  local position = UICamera.lastWorldPosition
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = sourceObj:GetComponent("UIWidget")
  local CommonUISmallTip = require("GUI.CommonUISmallTip")
  CommonUISmallTip.Instance():ShowTip(textRes.Pet[139], screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), -1)
end
def.method("number", "boolean").OnAttrTipPressed = function(self, index, state)
  local CommonUISmallTip = require("GUI.CommonUISmallTip")
  if state == false then
    CommonUISmallTip.Instance():HideTip()
    return
  end
  local sourceObjName = string.format("Img_CW_BgAttribute%02d/Sprite", index)
  local ui_Img_CW_BgBasic = self.ui_Img_CW_BgBasic
  local sourceObj = ui_Img_CW_BgBasic:FindDirect(sourceObjName)
  local PetPanel = Lplus.ForwardDeclare("PetPanel")
  local propKey = PetPanel.PropNameCfgKeyList[index]
  self:ShowPropHoverTip(propKey, sourceObj, -1)
end
def.method().OnPromoteButtonClicked = function(self)
  PetUtility.OpenPetBianqingDlg()
end
def.method().OnJinjieButtonClick = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local petId = self.m_base.petIdList[self.m_base.selectedPetIndex]
  local pet = PetMgrInstance:GetPet(petId)
  if pet == nil then
    return
  end
  if not pet:CanJinjie() then
    Toast(textRes.Pet[171])
    return
  end
  local curStage = pet.stageLevel
  local maxStage = PetUtility.Instance():GetPetConstants("PET_MAX_STAGE") or 3
  local nextStageCfg = PetUtility.GetPetNextStateCfg(pet:GetPetCfgData().templateId, curStage)
  if curStage >= maxStage or nextStageCfg == nil then
    Toast(textRes.Pet[172])
    return
  end
  local PetJinjiePanel = require("Main.Pet.ui.PetJinjiePanel")
  PetJinjiePanel.Instance():ShowPanel(pet)
end
def.static("table", "table").OnUseEquipmentSuccess = function(params, context)
  local petId, wearPos = unpack(params)
  require("GUI.CommonUsePanel").Instance():DestroyPanel()
  local pet = PetMgr.Instance():GetPet(petId)
  local coloredPetName = PetUtility.GetColoredPetNameHtml(pet)
  local equipTypeName = textRes.Pet.EquipmentType[wearPos]
  local text = string.format(textRes.Pet[110], coloredPetName, equipTypeName)
  Toast(text)
end
def.static("table", "table").OnPetYaoLiChange = function(params, context)
  local self = instance
  if self.m_base.selectedPetId ~= params.petId then
    return
  end
  local pet = PetMgr.Instance():GetPet(params.petId)
  local PetPanel = Lplus.ForwardDeclare("PetPanel")
  if PetPanel.Instance().SubNodeId == 1 then
    local Img_BgPower = self.ui_Img_CW_BgPower
    PetUtility.TweenYaoLiUIFromPet(Img_BgPower, pet, params)
  elseif PetPanel.Instance().SubNodeId == 3 then
    local ui_Img_CW_BgImage0 = self.m_node:FindDirect("ZB/Img_ZB_BgImage0")
    PetUtility.TweenYaoLiUIFromPet(ui_Img_CW_BgImage0:FindDirect("Img_BgPower"), pet, params)
  end
end
return PetPanelBasicNode.Commit()
