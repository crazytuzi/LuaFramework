local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PetLianGuPanel = Lplus.Extend(ECPanelBase, "PetLianGuPanel")
local def = PetLianGuPanel.define
local PetMgr = require("Main.Pet.mgr.PetMgr")
local PetData = Lplus.ForwardDeclare("PetData")
local PetQualityType = PetData.PetQualityType
local PetUtility = require("Main.Pet.PetUtility")
local PetModule = require("Main.Pet.PetModule")
local GUIUtils = require("GUI.GUIUtils")
local QualityType = require("netio.protocol.mzm.gsp.pet.CLianGuReq")
local EasyItemTipHelper = require("Main.Pet.EasyItemTipHelper")
local instance
local NOT_SET = -1
def.field("userdata").petId = nil
def.field("number").selectedIndex = NOT_SET
def.field("table").qualityTable = nil
def.field("boolean").isLianGuItemReady = false
def.field("string").lianGuItemName = ""
def.field(EasyItemTipHelper).easyItemTipHelper = nil
def.field("table").uiObjs = nil
def.static("=>", PetLianGuPanel).Instance = function()
  if instance == nil then
    instance = PetLianGuPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_PET_LIAN_GU_PANEL_RES, 2)
  self:SetModal(true)
end
def.method().HidePanel = function(self)
  self:DestroyPanel()
end
def.override().OnCreate = function(self)
  self:Init()
  self:Fill()
  self:HideLianGuNeeded()
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_INFO_UPDATE, PetLianGuPanel.OnPetInfoUpdate)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_QUALITY_UPDATE, PetLianGuPanel.OnPetQualityUpdate)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, PetLianGuPanel.OnBagInfoSynchronized)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_YAOLI_CHANGE, PetLianGuPanel.OnPetYaoLiChange)
  PetModule.Instance():ReqPetItemUseLimit(self.petId, function(p)
    local panel = self
    local petId = p.petId
    if panel:IsShow() and panel.petId == petId then
      local leftTimes = p.lianguItemLeft
      panel:SetUseItemLeftTimes(leftTimes)
    end
  end)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_INFO_UPDATE, PetLianGuPanel.OnPetInfoUpdate)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_QUALITY_UPDATE, PetLianGuPanel.OnPetQualityUpdate)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, PetLianGuPanel.OnBagInfoSynchronized)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_YAOLI_CHANGE, PetLianGuPanel.OnPetYaoLiChange)
  self:Clear()
  self.easyItemTipHelper = nil
end
def.method().Init = function(self)
  self.easyItemTipHelper = EasyItemTipHelper()
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Img_Bg1 = self.uiObjs.Img_Bg0:FindDirect("Img_Bg1")
  self.uiObjs.Img_BgAttribute = self.uiObjs.Img_Bg1:FindDirect("Img_BgAttribute")
  self.uiObjs.Group_Attribute = self.uiObjs.Img_BgAttribute:FindDirect("Group_Attribute")
  self.uiObjs.Img_BgPower = self.uiObjs.Img_Bg1:FindDirect("Img_BgPower")
  self.uiObjs.Group_Remember = self.uiObjs.Img_Bg1:FindDirect("Group_Remember")
  self.uiObjs.Label_Number = self.uiObjs.Group_Remember:FindDirect("Label_Number")
  GUIUtils.SetText(self.uiObjs.Label_Number, "")
  local uiToggle = self.m_panel:FindDirect("Img_Bg0/Img_Bg1/Img_BgAttribute/Group_Attribute/Img_BgAttribute1"):GetComponent("UIToggle")
  uiToggle.value = true
end
def.method("string").onClick = function(self, id)
  print(string.format("%s click event: id = %s", tostring(self), id))
  if id == "Btn_Close" then
    self:HidePanel()
  elseif id == "Btn_Remember" then
    self:OnLianGuButtonClick()
  elseif self.easyItemTipHelper:CheckItem2ShowTip(id) then
  elseif id == "Btn_Promote" then
    self:OnPromoteButtonClicked()
  end
end
def.method("string", "boolean").onToggle = function(self, id, isActive)
  if string.sub(id, 1, -2) == "Img_BgAttribute" then
    self:OnQualityItemToggle(id, isActive)
  end
end
def.method("userdata").SetActivePet = function(self, petId)
  self.petId = petId
end
def.method().OnLianGuButtonClick = function(self)
  if self.selectedIndex == NOT_SET then
    return
  end
  local success, reason = PetMgr.Instance():CanLianGu(self.petId)
  if reason == PetMgr.CResult.WILD_PET_IS_FORBID then
    Toast(textRes.Pet.SPetNormalResult[21])
    return
  end
  local qualityInfo = self.qualityTable[self.selectedIndex]
  if qualityInfo.maxValue == qualityInfo.value then
    Toast(textRes.Pet[60])
  elseif not self.isLianGuItemReady then
    Toast(textRes.Pet[61])
    self.easyItemTipHelper:CheckItem2ShowTip("Img_Item")
  else
    PetMgr.Instance():LianGu(self.petId, qualityInfo.type)
  end
end
def.method("string", "boolean").OnQualityItemToggle = function(self, id, isActive)
  local index = tonumber(string.sub(id, -1, -1))
  if isActive then
    self.selectedIndex = index
  elseif self.selectedIndex == index then
    self.selectedIndex = NOT_SET
  end
  self:UpdateLianGuNeeded()
end
def.static("table", "table").OnPetInfoUpdate = function(params, context)
  local petId = params[1]
  local self = instance
  if petId ~= self.petId then
    printInfo("LianGu panel update faield", petId, self.petId)
    return
  end
  self:UpdatePetQualityInfo()
  self:UpdateLianGuNeeded()
end
def.static("table", "table").OnPetQualityUpdate = function(params, context)
  PetLianGuPanel.OnPetInfoUpdate(params, context)
  local petId = params[1]
  local aptMap = params[2]
  local leftTimes = params[3] or -1
  for k, v in pairs(aptMap) do
    if v > 0 then
      local text = string.format(textRes.Pet[59], textRes.Pet.SLianGuRes[k], v, leftTimes)
      Toast(text)
    end
  end
  instance:SetUseItemLeftTimes(leftTimes)
end
def.static("table", "table").OnBagInfoSynchronized = function()
  local self = instance
  instance:UpdateLianGuNeeded()
end
def.method().UpdateLianGuNeeded = function(self)
  if self.selectedIndex ~= NOT_SET then
    self:SetLianGuNeeded()
  else
    self:HideLianGuNeeded()
  end
end
def.method().UpdatePetYaoLi = function(self)
  local pet = PetMgr.Instance():GetPet(self.petId)
  if pet == nil then
    return
  end
  PetUtility.SetYaoLiUIFromPet(self.uiObjs.Img_BgPower, pet)
end
def.method().Fill = function(self)
  self:UpdatePetQualityInfo()
  self:UpdatePetYaoLi()
end
def.method().UpdatePetQualityInfo = function(self)
  local pet = PetMgr.Instance():GetPet(self.petId)
  if pet == nil then
    return
  end
  local PetQualityType = PetData.PetQualityType
  local petQuality = pet.petQuality
  local petCfgData = pet:GetPetCfgData()
  local function GetQualityTuple(petQualityType)
    return {
      type = petQualityType,
      value = petQuality:GetQuality(petQualityType) or 0,
      maxValue = petQuality:GetMaxQuality(petQualityType) or 0,
      minValue = petCfgData:GetMinQuality(petQualityType) or 0
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
  self.qualityTable = qualityTable
  local itemId = PetUtility.Instance():GetPetConstants("PET_LIANGU_ITEM_ID")
  local petLianGuItemCfg = PetUtility.GetPetLianGuItemCfg(itemId)
  for i, v in ipairs(qualityTable) do
    local ui_Slider = self.uiObjs.Group_Attribute:FindDirect(string.format("Img_BgAttribute%d/Slider_Attribute%d", i, i))
    local ui_Label = GUIUtils.FindDirect(ui_Slider, string.format("Label_AttributeSlider%d", i))
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
    local text
    if v.value == v.maxValue then
      text = textRes.Pet[20]
    else
      local bound = PetMgr.Instance():CalcQualityIncBound(petLianGuItemCfg, v.minValue, v.value, v.maxValue)
      text = string.format(textRes.Pet[19], bound.down, bound.up)
    end
    local Label_Increase = GUIUtils.FindDirect(ui_Slider, string.format("Img_BgIncrease%d/Label_Increase%d", i, i))
    GUIUtils.SetText(Label_Increase, text)
  end
end
def.method().SetLianGuNeeded = function(self)
  local itemType = require("consts.mzm.gsp.item.confbean.ItemType").PET_LIANGU_ITEM
  local ItemModule = require("Main.Item.ItemModule")
  local items = ItemModule.Instance():GetItemsByItemType(ItemModule.BAG, itemType)
  local count = 0
  for k, v in pairs(items) do
    count = count + v.number
  end
  local itemNum = count
  local USE_ITEM_NUM = PetModule.PET_LIANGU_USE_ITEM_NUM
  local itemId = PetUtility.Instance():GetPetConstants("PET_LIANGU_ITEM_ID")
  local itemBase = require("Main.Item.ItemUtils").GetItemBase(itemId)
  local iconId = itemBase.icon
  self.m_panel:FindChild("Label_ItemName"):GetComponent("UILabel"):set_text(itemBase.name)
  self.lianGuItemName = itemBase.name
  local numText
  if itemNum >= USE_ITEM_NUM then
    numText = textRes.Common[12]
    self.isLianGuItemReady = true
  else
    numText = textRes.Common[11]
    self.isLianGuItemReady = false
  end
  local value = string.format(numText, itemNum, USE_ITEM_NUM)
  self.m_panel:FindChild("Label_ItemNum"):GetComponent("UILabel"):set_text(value)
  local uiTexture = self.m_panel:FindChild("Icon_Item"):GetComponent("UITexture")
  require("GUI.GUIUtils").FillIcon(uiTexture, iconId)
  local clickedObj = uiTexture.gameObject.transform.parent.gameObject
  self.easyItemTipHelper:RegisterItem2ShowTip(itemId, clickedObj)
  self.uiObjs.Group_Remember:SetActive(true)
end
def.method().HideLianGuNeeded = function(self)
  self.uiObjs.Group_Remember:SetActive(false)
end
def.method().OnPromoteButtonClicked = function(self)
  PetUtility.OpenPetBianqingDlg()
end
def.static("table", "table").OnPetYaoLiChange = function(params, context)
  local self = instance
  if self.petId ~= params.petId then
    return
  end
  local pet = PetMgr.Instance():GetPet(params.petId)
  local Img_BgPower = self.uiObjs.Img_BgPower
  PetUtility.TweenYaoLiUIFromPet(Img_BgPower, pet, params)
end
def.method().Clear = function(self)
  self.selectedIndex = NOT_SET
  self.qualityTable = nil
  self.uiObjs = nil
end
def.method("string", "boolean").onPress = function(self, id, state)
  if id == "Img_BgPower" then
    self:OnYaoLiPressLG(state)
  end
end
def.method("boolean").OnYaoLiPressLG = function(self, state)
  local CommonUISmallTip = require("GUI.CommonUISmallTip")
  if state == false then
    CommonUISmallTip.Instance():HideTip()
    return
  end
  local sourceObj = self.uiObjs.Img_Bg1:FindDirect("Img_BgPower")
  local position = UICamera.lastWorldPosition
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = sourceObj:GetComponent("UIWidget")
  local CommonUISmallTip = require("GUI.CommonUISmallTip")
  CommonUISmallTip.Instance():ShowTip(textRes.Pet[139], screenPos.x, screenPos.y, 10, 10, -1)
end
def.method("number").SetUseItemLeftTimes = function(self, leftTimes)
  local text = string.format(textRes.Pet[145], leftTimes)
  GUIUtils.SetText(self.uiObjs.Label_Number, text)
end
return PetLianGuPanel.Commit()
