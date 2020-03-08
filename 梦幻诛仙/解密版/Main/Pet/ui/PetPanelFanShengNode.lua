local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PetPanelNodeBase = require("Main.Pet.ui.PetPanelNodeBase")
local PetPanelFanShengNode = Lplus.Extend(PetPanelNodeBase, "PetPanelFanShengNode")
local PetMgr = require("Main.Pet.mgr.PetMgr")
local PetMgrInstance = PetMgr.Instance()
local PetUtility = require("Main.Pet.PetUtility")
local PetData = Lplus.ForwardDeclare("PetData")
local EC = require("Types.Vector3")
local Vector3 = EC.Vector3
local ECModel = require("Model.ECModel")
local GUIUtils = require("GUI.GUIUtils")
local PetModule = require("Main.Pet.PetModule")
local PetType = require("consts.mzm.gsp.pet.confbean.PetType")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local EasyItemTipHelper = require("Main.Pet.EasyItemTipHelper")
local Vector = require("Types.Vector")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local MountsMgr = require("Main.Mounts.mgr.MountsMgr")
local DISABLE_ZAISHENG_YUANBAO = false
local def = PetPanelFanShengNode.define
local NOT_SELECTED = 0
def.field("table").fsModel = nil
def.field("boolean").fsIsDrag = false
def.field("boolean").canOperate = false
def.field("table").fanShengConsume = nil
def.field("number").selectedFanShengType = 0
def.field(EasyItemTipHelper).easyItemTipHelper = nil
def.field("table").uiObjs = nil
def.field("userdata").ui_Img_FS_Bg0 = nil
def.field("userdata").ui_Img_FS_BgImage0 = nil
def.field("userdata").ui_Img_FS_BgAttribute = nil
def.field("userdata").ui_Grid_FS_Skill = nil
local instance
def.static("=>", PetPanelFanShengNode).Instance = function()
  if instance == nil then
    instance = PetPanelFanShengNode()
  end
  return instance
end
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  PetPanelNodeBase.Init(self, base, node)
end
def.override().OnShow = function(self)
  self:InitUI()
  self:UpdateUI()
  self:UpdateFSBtnState()
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_YAOLI_CHANGE, PetPanelFanShengNode.OnPetYaoLiChange)
end
def.override().OnHide = function(self)
  self:ClearModel()
  self.easyItemTipHelper = nil
  self.uiObjs.useGold:GetComponent("UIToggle").value = false
  self.uiObjs = nil
  self.selectedFanShengType = 0
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_YAOLI_CHANGE, PetPanelFanShengNode.OnPetYaoLiChange)
end
def.override().InitUI = function(self)
  PetPanelNodeBase.InitUI(self)
  self.uiObjs = {}
  self.uiObjs.Img_FS_Bg0 = self.m_node:FindDirect("Img_FS_Bg0")
  self.uiObjs.Img_FS_BgImage0 = self.uiObjs.Img_FS_Bg0:FindDirect("Img_FS_BgImage0")
  self.uiObjs.Img_FS_BgAttribute = self.uiObjs.Img_FS_Bg0:FindDirect("Img_FS_BgAttribute")
  self.uiObjs.Img_FS_BgExpend02 = self.uiObjs.Img_FS_Bg0:FindDirect("Img_FS_BgExpend02")
  self.uiObjs.Img_FS_Skill = self.uiObjs.Img_FS_Bg0:FindDirect("Img_FS_Skill")
  self.uiObjs.Grid_FS_Skill = self.uiObjs.Img_FS_Skill:FindDirect("Img_FS_BgSkillGroup/Scroll View_FS_Skill/Grid_FS_Skill")
  self.uiObjs.yuanbaoGroup = self.m_node:FindDirect("Img_FS_Bg0/Img_FS_Skill/Btn_FS_Use/Group_Yuanbao")
  self.uiObjs.FSBtnLabel = self.m_node:FindDirect("Img_FS_Bg0/Img_FS_Skill/Btn_FS_Use/Label_FS_Use")
  self.uiObjs.useGold = self.m_node:FindDirect("Img_UseGold")
  self.uiObjs.Label_LevelLimited = self.m_node:FindDirect("Label_LevelLimited")
  self.uiObjs.Label_ShenshouInfo = self.m_node:FindDirect("Label_ShenshouInfo")
  self.uiObjs.Label_ShenshouInfo:SetActive(false)
  self.uiObjs.Img_FS_PetDept = self.uiObjs.Img_FS_BgImage0:FindDirect("Img_FS_PetDept")
  self.easyItemTipHelper = EasyItemTipHelper()
  local Btn_Switch = self.uiObjs.Img_FS_Bg0:FindDirect("Btn_Switch")
  require("GUI.GUIUtils").BindClickableWidget(Btn_Switch)
  local Btn_Zaisheng = self.uiObjs.Img_FS_Skill:FindDirect("Btn_Zaisheng")
  Btn_Zaisheng:SetActive(false)
end
def.method("userdata", "userdata").BindClickableWidget = function(self, obj, template)
  local cwName = obj.name .. "_Clickable"
  if obj:FindDirect(cwName) then
    return
  end
  local clickableWidget = GameObject.Instantiate(template)
  clickableWidget:SetActive(true)
  local uiWidget = clickableWidget:GetComponent("UIWidget")
  local parentUIWidget = obj:GetComponent("UIWidget")
  uiWidget.width, uiWidget.height = parentUIWidget.width, parentUIWidget.height
  uiWidget.depth = parentUIWidget.depth - 1
  uiWidget:ResizeCollider()
  clickableWidget.transform.parent = obj.transform
  clickableWidget.transform.localPosition = Vector.Vector3.zero
  clickableWidget.transform.localScale = Vector.Vector3.one
  clickableWidget.name = cwName
end
def.override("string").onClick = function(self, id)
  if id == "Btn_FS_Tips" then
    self:OnFanShengTipClicked()
  end
  if self.isEmpty then
    return
  end
  if id == "Btn_FS_Use" then
    self:OnFanShengButtonClick()
  elseif string.sub(id, 1, 15) == "Img_FS_BgEquip0" then
    local index = tonumber(string.sub(id, 16, -1))
    self:OnPetEquipmentClick(index)
  elseif string.sub(id, 1, 4) == "Pet_" then
    local index = tonumber(string.sub(id, 5, -1))
    self:OnPetItemClick(index)
  elseif string.sub(id, 1, 14) == "Img_FS_BgSkill" then
    local index = tonumber(string.sub(id, 15, -1))
    self:OnSkillIconClick(index)
  elseif string.sub(id, 1, #"Btn_FS_Decoration0") == "Btn_FS_Decoration0" then
    local index = tonumber(string.sub(id, -2, -1))
    self:OnPetDecorationButtonClick(index)
  elseif self.easyItemTipHelper:CheckItem2ShowTip(id) then
  elseif id == "Model_FS" then
    self:OnClickPetModel()
  elseif id == "Btn_Switch" then
    self:OnSwitchToFanShengTypeButtonClicked()
  elseif id == "Btn_Switch_Clickable" then
    self:OnDisabledSwitchToFanShengTypeButtonClicked()
  elseif id == "Btn_Promote" then
    self:OnPromoteButtonClicked()
  elseif id == "Img_UseGold" then
    self:OnClickNeedYuanBaoBtn()
  elseif id == "Img_JieWei" then
    self:OnPetStageLevelClick()
  end
end
def.override("string", "boolean").onPress = function(self, id, state)
  if string.sub(id, 1, #"Img_FS_Attribute") == "Img_FS_Attribute" then
    local index = tonumber(string.sub(id, #"Img_FS_Attribute" + 1, -1))
    self:OnAttrTipPressed(index, state)
  elseif id == "Img_BgPower" then
    self:OnYaoLiPressFS(state)
  end
end
def.method().OnClickNeedYuanBaoBtn = function(self)
  local toggleBtn = self.uiObjs.useGold
  if toggleBtn and not toggleBtn.isnil then
    do
      local uiToggle = toggleBtn:GetComponent("UIToggle")
      local curValue = uiToggle.value
      if curValue then
        local needItemId = self.fanShengConsume.itemId
        local needItemNum = self.fanShengConsume.itemNeededNum
        local haveItemNum = ItemModule.Instance():GetItemCountById(needItemId)
        if needItemNum <= haveItemNum then
          Toast(textRes.Pet[149])
          uiToggle.value = false
          self:UpdateFSBtnState()
          return
        end
        local function callback(select, tag)
          if 0 == select then
            uiToggle.value = false
          elseif 1 == select then
            uiToggle.value = true
          end
          self:UpdateFSBtnState()
        end
        local confirmStr = textRes.Pet[150]
        if self.selectedFanShengType == PetMgr.FanShengType.ZAISHENG then
          confirmStr = textRes.Pet[153]
        end
        CommonConfirmDlg.ShowConfirm("", confirmStr, callback, nil)
      else
        self:UpdateFSBtnState()
      end
    end
  end
end
def.method("boolean").OnYaoLiPressFS = function(self, state)
  local CommonUISmallTip = require("GUI.CommonUISmallTip")
  if state == false then
    CommonUISmallTip.Instance():HideTip()
    return
  end
  local sourceObj = self.uiObjs.Img_FS_BgImage0:FindDirect("Img_BgPower")
  local position = UICamera.lastWorldPosition
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = sourceObj:GetComponent("UIWidget")
  local CommonUISmallTip = require("GUI.CommonUISmallTip")
  CommonUISmallTip.Instance():ShowTip(textRes.Pet[139], screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), -1)
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
  if pet:CanChongSheng() then
    self.selectedFanShengType = PetMgr.FanShengType.ZAISHENG
  else
    self.selectedFanShengType = PetMgr.FanShengType.GAOJI_FANSHENG
  end
  self:SetPetInfo(index, pet)
  self.uiObjs.useGold:GetComponent("UIToggle").value = false
  self:UpdateFSBtnState()
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
    self:SetPetInfo(index, pet)
  end
end
def.override("userdata").OnPetAdded = function(self, petId)
  self.m_base.petIdList = self.m_base.petIdList or {}
  self.m_base:SetPetList(PetMgrInstance.petList, PetMgrInstance.petNum)
  if self.isEmpty then
    self.isEmpty = false
    self:SetSelectedPet(1)
    self.m_base:SetSelectedListItem(1)
    local pet = PetMgrInstance:GetPet(petId)
    self:SetPetInfo(1, pet)
  else
    local origionPetId = self.m_base.selectedPetId
    local index = 0
    for i, id in pairs(self.m_base.petIdList) do
      if id == origionPetId then
        index = i
        break
      end
    end
    self:SetSelectedPet(index)
    self.m_base:SetSelectedListItem(index)
  end
end
def.override("userdata").OnPetDeleted = function(self, petId)
  self.m_base:SetPetList(PetMgrInstance.petList, PetMgrInstance.petNum)
  if PetMgrInstance.petList == nil or PetMgrInstance.petNum == 0 then
    self.isEmpty = true
    self:SetSelectedPet(NOT_SELECTED)
    self:ShowEmptyPage()
  else
    local index = self.m_base.selectedPetIndex
    local petId = self.m_base.petIdList[index]
    if not petId then
      index = index - 1
    end
    local petId = self.m_base.petIdList[index]
    self:SetSelectedPet(index)
    self.m_base:SetSelectedListItem(index)
    local pet = PetMgrInstance:GetPet(petId)
    self:SetPetInfo(index, pet)
  end
end
def.method().OnPetStageLevelClick = function(self)
  local petId = self.m_base.petIdList[self.m_base.selectedPetIndex]
  local pet = PetMgrInstance:GetPet(petId)
  PetUtility.ShowPetStageLevelTips(pet)
end
def.method("number").SetSelectedPet = function(self, index)
  self.m_base.selectedPetIndex = index
  self.m_base.selectedPetId = self.m_base.petIdList[index]
end
def.override().UpdateUI = function(self)
  self.selectedFanShengType = 0
  self.m_panel:FindDirect("Img_Bg0/PetList"):SetActive(true)
  self.m_base:SetPetList(PetMgrInstance.petList, PetMgrInstance.petNum)
  self.m_base:UpdateTuJianNotice()
  if PetMgrInstance:GetPetNum() == 0 then
    self.isEmpty = true
    self:ShowEmptyPage()
    return
  end
  self.isEmpty = false
  self:UpdateSelectedIndex()
  local petId = self.m_base.petIdList[self.m_base.selectedPetIndex]
  local pet = PetMgr.Instance():GetPet(petId)
  local index = self.m_base.selectedPetIndex
  self:SetPetInfo(index, pet)
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
end
def.method("number", "table").SetPetInfo = function(self, index, pet)
  self.m_base:SetListItemInfo(index, pet)
  self:SetQualityValueFromPetData(pet)
  self:SetSkillList(pet)
  self:SetYaoLi(pet)
  self:SetGrowValue(pet)
  self:SetLife(pet)
  self:SetPetTypeImage(pet)
  self:SetPetName(pet.name)
  self:SetCarrayLevel(pet)
  self:UpdateModel(pet)
  self:SetPetFanShengType(pet)
  self:EnabledFanShengBtn(true)
  self:SetPetChangeModelCardType(pet)
  if pet:CanJinjie() then
    self:SetPetStageLevel(pet.stageLevel)
  else
    self:ClearPetStageLevel()
  end
  self:SetPetDisplayModelName(pet)
end
def.method("table").SetQualityValueFromPetData = function(self, pet)
  local PetQualityType = PetData.PetQualityType
  local petQuality = pet.petQuality
  local petCfgData = pet:GetPetCfgData()
  local function GetQualityTuple(petQualityType)
    return {
      value = petQuality:GetQuality(petQualityType) or 0,
      minValue = petCfgData:GetMinQuality(petQualityType) or 0,
      maxValue = petQuality:GetMaxQuality(petQualityType) or 0
    }
  end
  local qualityTable = {
    GetQualityTuple(PetQualityType.HP_APT),
    GetQualityTuple(PetQualityType.PHYATK_APT),
    GetQualityTuple(PetQualityType.MAGATK_APT),
    GetQualityTuple(PetQualityType.PHYDEF_APT),
    GetQualityTuple(PetQualityType.MAGDEF_APT),
    GetQualityTuple(PetQualityType.SPEED_APT)
  }
  self:SetQualityValue(qualityTable)
end
def.method("table").SetQualityValue = function(self, qualityTable)
  if qualityTable == nil then
    local qualityCount = 6
    qualityTable = {}
    for i = 1, qualityCount do
      qualityTable[i] = {}
    end
  end
  for i, v in ipairs(qualityTable) do
    local ui_Slider = self.uiObjs.Img_FS_BgAttribute:FindDirect(string.format("Slider_FS_Attribute%02d", i))
    local ui_Label = GUIUtils.FindDirect(ui_Slider, "Label_FS_AttributeSlider05")
    local value, maxValue, minValue = v.value, v.maxValue, v.minValue
    local progress = 0
    if value and maxValue and minValue then
      progress = PetUtility.GetPetQualityProgress(value, minValue, maxValue)
    end
    GUIUtils.SetProgress(ui_Slider, "UIProgressBar", progress)
    local text = ""
    if value and maxValue then
      text = string.format("%d/%d", value, maxValue)
    end
    GUIUtils.SetText(ui_Label, text)
  end
end
def.method("table").SetSkillList = function(self, pet)
  local grid = self.uiObjs.Grid_FS_Skill:GetComponent("UIGrid")
  self.m_base.addSkillIconIndex = PetUtility.SetSkillList(pet, grid, "Img_FS_IconSkill", "Img_FS_Sign", "Img_FS_Sign0", "Img_JN_RidingSign", "Img_JN_ImpressSign", nil, true)
end
def.method("table").SetYaoLi = function(self, pet)
  PetUtility.SetYaoLiUIFromPet(self.uiObjs.Img_FS_BgImage0:FindDirect("Img_BgPower"), pet)
end
def.method("table").SetGrowValue = function(self, pet)
  local viewData = PetUtility.GetPetGrowValueViewData(pet)
  local text = string.format("[%s]%s(%s)[-]", viewData.color, viewData.value, viewData.meaning)
  self.uiObjs.Img_FS_BgAttribute:FindDirect("Img_FS_BgGrown/Label_FS_GrownNum"):GetComponent("UILabel"):set_text(text)
end
def.method("table").SetLife = function(self, pet)
  if pet:IsNeverDie() then
    self.uiObjs.Img_FS_BgAttribute:FindDirect("Img_FS_BgAge/Label_FS_AgeNum"):GetComponent("UILabel"):set_text(textRes.Pet[45])
  else
    self.uiObjs.Img_FS_BgAttribute:FindDirect("Img_FS_BgAge/Label_FS_AgeNum"):GetComponent("UILabel"):set_text(pet.life)
  end
end
def.method("table").SetPetTypeImage = function(self, pet)
  local petCfgData = pet:GetPetCfgData()
  local spriteName = PetUtility.GetPetTypeSpriteName(petCfgData.type)
  self.uiObjs.Img_FS_BgImage0:FindDirect("Label_FS_PetType"):GetComponent("UISprite").spriteName = spriteName
end
def.method("table").SetPetChangeModelCardType = function(self, pet)
  if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_CHANGE_MODEL_CARD) then
    GUIUtils.SetTexture(self.uiObjs.Img_FS_PetDept, 0)
  else
    local petCfgData = pet:GetPetCfgData()
    local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
    local classCfg = TurnedCardUtils.GetCardClassCfg(petCfgData.changeModelCardClassType)
    GUIUtils.SetTexture(self.uiObjs.Img_FS_PetDept, classCfg.smallIconId)
  end
end
def.method(PetData).UpdateModel = function(self, pet)
  local objModel = self.uiObjs.Img_FS_BgImage0:FindDirect("Model_FS")
  local uiModel = objModel:GetComponent("UIModel")
  if self.fsModel ~= nil then
    self.fsModel:Destroy()
  end
  self.fsModel = PetUtility.CreateAndAttachPetUIModel(pet, uiModel, nil)
end
def.method("string").SetPetName = function(self, petName)
  local label = self.uiObjs.Img_FS_BgImage0:FindDirect("Label_PetName01"):GetComponent("UILabel")
  label.text = petName
end
def.method("table").SetCarrayLevel = function(self, pet)
  local cfg = pet:GetPetCfgData()
  local levelStr = string.format(textRes.Pet[152], cfg.carryLevel)
  self.uiObjs.Label_LevelLimited:GetComponent("UILabel").text = levelStr
end
def.override("string").onDragStart = function(self, id)
  if id == "Model_FS" then
    self.fsIsDrag = true
  end
end
def.override("string").onDragEnd = function(self, id)
  self.fsIsDrag = false
end
def.override("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.fsIsDrag == true and self.fsModel then
    self.fsModel:SetDir(self.fsModel.m_ang - dx / 2)
  end
end
def.method().ClearModel = function(self)
  if self.fsModel then
    self.fsModel:Destroy()
    self.fsModel = nil
  end
end
def.method("table").SetPetFanShengType = function(self, pet)
  local petCfgData = pet:GetPetCfgData()
  local Btn_Switch = self.uiObjs.Img_FS_Bg0:FindDirect("Btn_Switch")
  if petCfgData.type == PetType.BIANYI then
    Btn_Switch:GetComponent("UIButton").isEnabled = true
  else
    Btn_Switch:GetComponent("UIButton").isEnabled = false
  end
  local fanShengType = PetMgr.FanShengType.GAOJI_FANSHENG
  if pet:CanChongSheng() then
    fanShengType = PetMgr.FanShengType.ZAISHENG
  elseif petCfgData.type == PetType.BIANYI then
    fanShengType = PetMgr.FanShengType.GAOJI_FANSHENG
  else
    fanShengType = PetMgr.FanShengType.PUTONG_FANSHENG
  end
  self:SwitchToFanShengType(fanShengType)
  self:UpdateFSBtnState()
end
def.method("number").SwitchToFanShengType = function(self, type)
  local petId = self.m_base.petIdList[self.m_base.selectedPetIndex]
  local pet = PetMgrInstance:GetPet(petId)
  local petCfgData = pet:GetPetCfgData()
  local fanshengCfg = PetUtility.GetPetFanShengNeedCfg(petCfgData.fanShengCfgId)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local needItemType = ItemType.PET_HIGHTLEVEL_FANSHENG_ITEM
  local needItemId = PetUtility.Instance():GetPetConstants("PET_GAOJI_FANSHENGDAN_ID")
  local itemNeedNum = 0
  local Btn_Switch = self.uiObjs.Img_FS_Bg0:FindDirect("Btn_Switch")
  local Btn_FS_Use = self.m_node:FindDirect("Img_FS_Bg0/Img_FS_Skill/Btn_FS_Use")
  local Label_ShenshouInfo = self.uiObjs.Label_ShenshouInfo
  local Label_FanShengInfo = self.m_node:FindDirect("Img_FS_Bg0/Img_FS_BgImage0/Label")
  if type == PetMgr.FanShengType.GAOJI_FANSHENG then
    Btn_Switch:GetComponent("UIToggle").value = true
    needItemType = ItemType.PET_HIGHTLEVEL_FANSHENG_ITEM
    needItemId = PetUtility.Instance():GetPetConstants("PET_GAOJI_FANSHENGDAN_ID")
    itemNeedNum = fanshengCfg.advanceNeedItemNum
  elseif type == PetMgr.FanShengType.PUTONG_FANSHENG then
    Btn_Switch:GetComponent("UIToggle").value = false
    needItemType = ItemType.PET_PUTONG_FANSHENG_ITEM
    needItemId = PetUtility.Instance():GetPetConstants("PET_PUTONG_FANSHENGDAN_ID")
    itemNeedNum = fanshengCfg.normalNeedItemNum
  else
    local condition = PetUtility.GetPetReplaceSkillCondition(petCfgData.templateId)
    local itemBase = ItemUtils.GetItemBase(condition.itemId)
    needItemId = condition.itemId
    itemNeedNum = condition.itemNum
    needItemType = itemBase.itemType
  end
  if type ~= PetMgr.FanShengType.ZAISHENG then
    Btn_Switch:SetActive(true)
    Label_ShenshouInfo:SetActive(false)
    Label_FanShengInfo:SetActive(true)
    self.uiObjs.useGold:SetActive(true)
    self.uiObjs.Img_FS_Bg0:FindDirect("Label"):SetActive(true)
    GUIUtils.SetText(Btn_Switch:FindDirect("Label_FS_Use"), textRes.Pet.FanShengType[type])
    Btn_FS_Use:FindDirect("Label_FS_Use"):GetComponent("UILabel").text = textRes.Pet[154]
    Btn_FS_Use:FindDirect("Group_Yuanbao/Label_Money"):GetComponent("UILabel").text = textRes.Pet[154]
  else
    Btn_Switch:SetActive(false)
    Label_ShenshouInfo:SetActive(true)
    Label_FanShengInfo:SetActive(false)
    if DISABLE_ZAISHENG_YUANBAO then
      self.uiObjs.useGold:GetComponent("UIToggle").value = false
      self.uiObjs.useGold:SetActive(false)
      self.uiObjs.Img_FS_Bg0:FindDirect("Label"):SetActive(false)
    end
    Btn_FS_Use:FindDirect("Label_FS_Use"):GetComponent("UILabel").text = textRes.Pet[155]
    Btn_FS_Use:FindDirect("Group_Yuanbao/Label_Money"):GetComponent("UILabel").text = textRes.Pet[155]
  end
  self:FillNeededItem(needItemType, needItemId, itemNeedNum)
  self.selectedFanShengType = type
end
def.method().UpdateFSBtnState = function(self)
  local toggleBtn = self.uiObjs.useGold
  local uiToggle = toggleBtn:GetComponent("UIToggle")
  local curValue = uiToggle.value
  if curValue then
    local needItemId = self.fanShengConsume.itemId
    local needItemNum = self.fanShengConsume.itemNeededNum
    local haveItemNum = ItemModule.Instance():GetItemCountById(needItemId)
    if needItemNum <= haveItemNum then
      uiToggle.value = false
      self.uiObjs.yuanbaoGroup:SetActive(false)
      self.uiObjs.FSBtnLabel:SetActive(true)
      return
    end
    self.uiObjs.yuanbaoGroup:SetActive(true)
    self.uiObjs.FSBtnLabel:SetActive(false)
    local needYuanbao = (needItemNum - haveItemNum) * PetUtility.GetPetFSItemPrice(needItemId)
    self.uiObjs.yuanbaoGroup:FindDirect("Label_Money"):GetComponent("UILabel"):set_text(tostring(needYuanbao))
  else
    self.uiObjs.yuanbaoGroup:SetActive(false)
    self.uiObjs.FSBtnLabel:SetActive(true)
  end
end
def.method("number", "number", "number").FillNeededItem = function(self, itemType, itemId, itemNeededNum)
  local label_itemNum = "Label_FS_ExpendNum02"
  local label_itemName = "Label_FS_Use"
  local texture_itemIcon = "Img_FS_IconExpend02"
  local ItemModule = require("Main.Item.ItemModule")
  local items = ItemModule.Instance():GetItemsByItemType(ItemModule.BAG, itemType)
  local count = 0
  for k, v in pairs(items) do
    count = count + v.number
  end
  self.fanShengConsume = self.fanShengConsume or {}
  self.fanShengConsume.itemType = itemType
  self.fanShengConsume.itemId = itemId
  self.fanShengConsume.itemNeededNum = itemNeededNum
  local itemNum = count
  local USE_ITEM_NUM = itemNeededNum
  local numText = _G.GetFormatItemNumString(itemNum, USE_ITEM_NUM)
  self.uiObjs.Img_FS_BgExpend02:FindDirect(label_itemNum):GetComponent("UILabel"):set_text(numText)
  local itemBase = require("Main.Item.ItemUtils").GetItemBase(itemId)
  local iconId = itemBase.icon
  self.uiObjs.Img_FS_Bg0:FindDirect(label_itemName):GetComponent("UILabel"):set_text(itemBase.name)
  local uiTexture = self.uiObjs.Img_FS_BgExpend02:FindDirect(texture_itemIcon):GetComponent("UITexture")
  if uiTexture then
    GUIUtils.FillIcon(uiTexture, iconId)
  end
  local clickedObj = uiTexture.gameObject.transform.parent.gameObject
  self.easyItemTipHelper:RegisterItem2ShowTip(itemId, clickedObj)
  if itemNum >= USE_ITEM_NUM then
    self.canOperate = true
  else
    self.canOperate = false
  end
end
def.method().OnFanShengButtonClick = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local petId = self.m_base.petIdList[self.m_base.selectedPetIndex]
  if self.selectedFanShengType == PetMgr.FanShengType.ZAISHENG and not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_PET_REPLACE_SKILL) then
    Toast(textRes.Pet[184])
    return
  end
  if self:EvalFanShengConditions(petId, self.selectedFanShengType) then
    self:TryToFanSheng(petId, self.selectedFanShengType)
  end
end
def.method("userdata", "number", "=>", "boolean").EvalFanShengConditions = function(self, petId, fanShengType)
  local pet = PetMgrInstance:GetPet(petId)
  local petCfgData = pet:GetPetCfgData()
  local fanShengMaxLevel = PetUtility.Instance():GetPetConstants("CAN_FANSHENG_MAX_LEVEL")
  local zaiShengMaxLevel = PetUtility.Instance():GetPetConstants("PET_REPLACE_SKILL_LEVELLIMIT")
  if pet == nil then
    return false
  elseif fanShengType ~= PetMgr.FanShengType.ZAISHENG and fanShengMaxLevel < pet.level and petCfgData.type ~= PetType.WILD then
    Toast(string.format(textRes.Pet[49], fanShengMaxLevel))
    return false
  elseif fanShengType == PetMgr.FanShengType.ZAISHENG and zaiShengMaxLevel < pet.level then
    Toast(string.format(textRes.Pet[156], zaiShengMaxLevel))
    return false
  elseif pet.isFighting then
    Toast(string.format(textRes.Pet[50], fanShengMaxLevel))
    return false
  elseif petCfgData.isSpecial then
    Toast(string.format(textRes.Pet[51], fanShengMaxLevel))
    return false
  elseif pet.isBinded and fanShengType ~= PetMgr.FanShengType.ZAISHENG then
    require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Common[8], textRes.Pet[52], PetPanelFanShengNode.FanShengConfirmCallback, {petId, fanShengType})
    return false
  elseif petCfgData.type == PetType.BIANYI then
    require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Common[8], textRes.Pet[53], PetPanelFanShengNode.FanShengConfirmCallback, {petId, fanShengType})
    return false
  elseif pet:IsSkillSameWithOrigin() and fanShengType == PetMgr.FanShengType.ZAISHENG then
    Toast(textRes.Pet[161])
    return false
  else
    return true
  end
end
def.static("number", "table").FanShengConfirmCallback = function(state, tag)
  if state == 0 then
    return
  end
  local petId, fanShengType = tag[1], tag[2]
  local self = instance
  if self.uiObjs == nil then
    warn("FanShengConfirmCallback failed, because pet FanSheng page is closed!!!")
    return
  end
  self:TryToFanSheng(petId, fanShengType)
end
def.method("userdata", "number").TryToFanSheng = function(self, petId, fanShengType)
  if not self.canOperate then
    if fanShengType == PetMgr.FanShengType.ZAISHENG and DISABLE_ZAISHENG_YUANBAO then
      Toast(textRes.Pet[1000])
      return
    end
    self:AskYuanBaoSupplement(petId, fanShengType)
  else
    self:StartFanSheng(petId, fanShengType, PetMgr.CostType.UseItem)
  end
end
def.method("userdata", "number").AskYuanBaoSupplement = function(self, petId, fanShengType)
  local function FanShengReq(extraParams)
    local costType = PetMgr.CostType.UseItem
    if extraParams and extraParams.isYuanBaoBuZu then
      costType = PetMgr.CostType.UseYuanBao
    end
    self:StartFanSheng(petId, fanShengType, costType)
  end
  local needItemId, needItemNum = self.fanShengConsume.itemId, self.fanShengConsume.itemNeededNum
  local haveItemNum = ItemModule.Instance():GetItemCountById(needItemId)
  local uiToggle = self.uiObjs.useGold:GetComponent("UIToggle")
  local curValue = uiToggle.value
  if not curValue then
    uiToggle.value = true
    self:OnClickNeedYuanBaoBtn()
  else
    local needYuanbao = (needItemNum - haveItemNum) * PetUtility.GetPetFSItemPrice(needItemId)
    local allYuanBao = ItemModule.Instance():GetAllYuanBao()
    if allYuanBao:lt(needYuanbao) then
      Toast(textRes.Common[15])
      return
    end
    FanShengReq({isYuanBaoBuZu = true})
  end
end
def.method("userdata", "number", "number").StartFanSheng = function(self, petId, fanShengType, costType)
  local function FanShengReq()
    self:EnabledFanShengBtn(false)
    PetMgr.Instance():FanShengReq(petId, fanShengType, costType)
  end
  local function CheckToFanSheng()
    local pet = PetMgr.Instance():GetPet(petId)
    if pet == nil then
      return
    end
    if pet:HasAnyExtraModel() then
      CommonConfirmDlg.ShowConfirm("", textRes.Pet[216], function(result)
        if result == 1 then
          FanShengReq()
        end
      end, nil)
    else
      FanShengReq()
    end
  end
  local function ZaiShengReq()
    if fanShengType == PetMgr.FanShengType.ZAISHENG then
      self:EnabledFanShengBtn(false)
      local needItemId, needItemNum = self.fanShengConsume.itemId, self.fanShengConsume.itemNeededNum
      local haveItemNum = ItemModule.Instance():GetItemCountById(needItemId)
      local isCostYuanBao = costType == PetMgr.CostType.UseYuanBao
      local needYuanbao = (needItemNum - haveItemNum) * PetUtility.GetPetFSItemPrice(needItemId)
      PetMgr.Instance():ZaiShengReq(petId, isCostYuanBao, needYuanbao)
    end
  end
  local function CheckToZaiSheng()
    local pet = PetMgr.Instance():GetPet(petId)
    if pet == nil then
      return
    end
    if pet:HasAnyExtraModel() then
      CommonConfirmDlg.ShowConfirm("", textRes.Pet[217], function(result)
        if result == 1 then
          ZaiShengReq()
        end
      end, nil)
    else
      ZaiShengReq()
    end
  end
  if fanShengType == PetMgr.FanShengType.ZAISHENG then
    self:ChongShengProcess(petId, CheckToZaiSheng)
  else
    local petData = PetMgr.Instance():GetPet(petId)
    if petData == nil then
      return
    end
    local petCfg = petData:GetPetCfgData()
    local curSkills = petData:GetSkillIdList()
    local skillIdList = require("Main.Skill.SkillUtility").GetMonsterSkillCfg(petCfg.skillPropTabId) or {}
    if petCfg.type ~= PetData.PetType.WILD and curSkills ~= nil and #curSkills >= #skillIdList then
      CommonConfirmDlg.ShowConfirm("", string.format(textRes.Pet[187], #curSkills), function(result)
        if result == 1 then
          CheckToFanSheng()
        end
      end, nil)
    else
      CheckToFanSheng()
    end
  end
end
def.method("userdata", "function").ChongShengProcess = function(self, petId, callback)
  local pet = PetMgrInstance:GetPet(petId)
  local function digitalVerify(state)
    if state == 0 then
      return
    end
    local PetProtectionPanel = require("Main.Pet.ui.PetProtectionPanel")
    PetProtectionPanel.Instance():SetProtectOpertation(petId, callback, textRes.Pet[155], textRes.Pet[159])
    PetProtectionPanel.Instance():ShowPanel()
  end
  CommonConfirmDlg.ShowConfirm("", string.format(textRes.Pet[157], pet.name), digitalVerify, nil)
end
def.method().ShowEmptyPage = function(self)
  self.m_base:SetPetListEmpty()
  self:SetPetName("")
  self:SetQualityValue(nil)
  self:ClearPetStageLevel()
  self.uiObjs.Img_FS_BgAttribute:FindDirect("Img_FS_BgGrown/Label_FS_GrownNum"):GetComponent("UILabel"):set_text("")
  self.uiObjs.Img_FS_BgAttribute:FindDirect("Img_FS_BgAge/Label_FS_AgeNum"):GetComponent("UILabel"):set_text("")
  self.uiObjs.Img_FS_BgImage0:FindDirect("Label_FS_PetType"):GetComponent("UISprite"):set_spriteName("nil")
  PetUtility.SetYaoLiUI(self.uiObjs.Img_FS_BgImage0:FindDirect("Img_BgPower"), 0, -1, -1)
  self.uiObjs.Label_LevelLimited:GetComponent("UILabel").text = ""
  local grid = self.uiObjs.Grid_FS_Skill:GetComponent("UIGrid")
  local gridItemCount = grid:GetChildListCount()
  local gridChildList = grid:GetChildList()
  for i = 1, gridItemCount do
    local objIndex = string.format("%02d", i)
    local girdItem = gridChildList[i].gameObject
    local uiTexture = girdItem:FindDirect("Img_FS_IconSkill" .. objIndex):GetComponent("UITexture")
    uiTexture.mainTexture = nil
    girdItem:FindDirect("Img_FS_SkillAdd" .. objIndex):SetActive(false)
    girdItem:FindDirect("Img_FS_Sign"):SetActive(false)
    girdItem:FindDirect("Img_FS_Sign0"):SetActive(false)
    PetUtility.SetOriginPetSkillBg(girdItem, "Img_SkillFg")
  end
  local uiTexture = self.uiObjs.Img_FS_BgExpend02:FindDirect("Img_FS_IconExpend02"):GetComponent("UITexture")
  uiTexture.mainTexture = nil
  self.uiObjs.Img_FS_BgExpend02:FindDirect("Label_FS_ExpendNum02"):GetComponent("UILabel").text = ""
  self.uiObjs.Img_FS_Bg0:FindDirect("Label_FS_Use"):GetComponent("UILabel").text = nil
  GUIUtils.SetTexture(self.uiObjs.Img_FS_PetDept, 0)
  self:ClearModel()
end
def.method().ClearPetStageLevel = function(self)
  local stageStar = self.uiObjs.Img_FS_BgImage0:FindDirect("Img_JieWei")
  if stageStar ~= nil then
    stageStar:SetActive(false)
  end
end
def.method("number").SetPetStageLevel = function(self, stageLevel)
  local stageStar = self.uiObjs.Img_FS_BgImage0:FindDirect("Img_JieWei")
  if stageStar ~= nil then
    stageStar:SetActive(true)
    GUIUtils.SetSprite(stageStar, "Img_Jie" .. stageLevel)
    PetUtility.AddBoxCollider(stageStar)
  end
end
def.method("table").SetPetDisplayModelName = function(self, pet)
  local modelName = self.m_node:FindDirect("Label_ChangeName")
  GUIUtils.SetActive(modelName, true)
  if pet.extraModelCfgId ~= 0 then
    local displayModelInfo = ItemUtils.GetItemBase(pet.extraModelCfgId)
    if displayModelInfo ~= nil then
      GUIUtils.SetText(modelName, string.format(textRes.Pet[218], displayModelInfo.name))
    else
      GUIUtils.SetText(modelName, "")
    end
  else
    GUIUtils.SetText(modelName, "")
  end
end
def.override().OnBagInfoSynchronized = function(self)
  self:UpdatePetFanShengType()
  self:UpdateFSBtnState()
end
def.method().UpdatePetFanShengType = function(self)
  local pet = PetMgrInstance:GetPet(self.m_base.selectedPetId)
  if pet == nil then
    return
  end
  self:SetPetFanShengType(pet)
end
def.static("table", "table").OnPetFanShengSuccess = function()
end
def.method("number").OnPetDecorationButtonClick = function(self, index)
  if index == 1 then
    local PetDecorationPanel = require("Main.Pet.ui.PetDecorationPanel")
    local petId = self.m_base.petIdList[self.m_base.selectedPetIndex]
    PetDecorationPanel.Instance():SetActivePet(petId)
    PetDecorationPanel.Instance():ShowPanel()
  elseif index == 2 then
    Toast(textRes.Pet[74])
  end
end
def.method().OnClickPetModel = function(self)
  PetUtility.PlayPetClickedAnimation(self.fsModel)
end
def.method().OnSwitchToFanShengTypeButtonClicked = function(self)
  local petId = self.m_base.petIdList[self.m_base.selectedPetIndex]
  local pet = PetMgrInstance:GetPet(petId)
  local petCfgData = pet:GetPetCfgData()
  local Btn_Switch = self.uiObjs.Img_FS_Bg0:FindDirect("Btn_Switch")
  if petCfgData.type == PetType.BIANYI and Btn_Switch:GetComponent("UIToggle").value == true then
    self:SwitchToFanShengType(PetMgr.FanShengType.GAOJI_FANSHENG)
  else
    self:SwitchToFanShengType(PetMgr.FanShengType.PUTONG_FANSHENG)
  end
  self:UpdateFSBtnState()
end
def.method().OnDisabledSwitchToFanShengTypeButtonClicked = function(self)
  Toast(textRes.Pet[103])
end
def.method("number").OnSkillIconClick = function(self, index)
  local petId = self.m_base.petIdList[self.m_base.selectedPetIndex]
  local pet = PetMgrInstance:GetPet(petId)
  local skillIdList = pet:GetConcatSkillIdList()
  local skillMountsIdList = pet:GetProtectMountsSkillIdList() or {}
  for _, v in ipairs(skillMountsIdList) do
    table.insert(skillIdList, v)
  end
  local petMarkSkillId = pet:GetPetMarkSkillId()
  if petMarkSkillId > 0 then
    table.insert(skillIdList, petMarkSkillId)
  end
  local skillId = skillIdList[index]
  if skillId ~= nil then
    local skillCfg = require("Main.Pet.PetUtility").Instance():GetPetSkillCfg(skillId)
    local sourceObj = self.uiObjs.Grid_FS_Skill:FindDirect(string.format("Img_FS_BgSkill%02d", 1))
    PetUtility.ShowPetSkillTipEx(skillId, pet.level, sourceObj, -1)
  end
end
def.method().OnFanShengTipClicked = function(self)
  local tipId = PetUtility.Instance():GetPetConstants("FANSHENG_TIPS")
  require("GUI.GUIUtils").ShowHoverTip(tipId)
end
def.method("number", "boolean").OnAttrTipPressed = function(self, index, state)
  local CommonUISmallTip = require("GUI.CommonUISmallTip")
  if state == false then
    CommonUISmallTip.Instance():HideTip()
    return
  end
  local sourceObjName = string.format("Slider_FS_Attribute%02d/Img_FS_Attribute%02d", index, index)
  local ui_Img_FS_BgAttribute = self.uiObjs.Img_FS_BgAttribute
  local sourceObj = ui_Img_FS_BgAttribute:FindDirect(sourceObjName)
  local PetPanel = Lplus.ForwardDeclare("PetPanel")
  local propKey = PetPanel.PropNameCfgKeyList[index]
end
def.method("boolean").EnabledFanShengBtn = function(self, isEnable)
  local btn = self.uiObjs.Img_FS_Skill:FindDirect("Btn_FS_Use")
  if btn then
    btn:GetComponent("UIButton").isEnabled = isEnable
  end
end
def.method().OnPromoteButtonClicked = function(self)
  PetUtility.OpenPetBianqingDlg()
end
def.static("table", "table").OnPetYaoLiChange = function(params, context)
  local self = instance
  if self.m_base.selectedPetId ~= params.petId then
    return
  end
  local pet = PetMgr.Instance():GetPet(params.petId)
  local Img_BgPower = self.uiObjs.Img_FS_BgImage0:FindDirect("Img_BgPower")
  PetUtility.TweenYaoLiUIFromPet(Img_BgPower, pet, params)
end
return PetPanelFanShengNode.Commit()
