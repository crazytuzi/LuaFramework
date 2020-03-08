local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgChildPropTraining = Lplus.Extend(ECPanelBase, "DlgChildPropTraining")
local def = DlgChildPropTraining.define
local PetMgr = require("Main.Pet.mgr.PetMgr")
local PetData = Lplus.ForwardDeclare("PetData")
local PetQualityType = PetData.PetQualityType
local PetUtility = require("Main.Pet.PetUtility")
local PetModule = require("Main.Pet.PetModule")
local GUIUtils = require("GUI.GUIUtils")
local QualityType = require("consts.mzm.gsp.children.confbean.QualityType")
local EasyItemTipHelper = require("Main.Pet.EasyItemTipHelper")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local instance
def.field("userdata").childId = nil
def.field("number").selectedIndex = 1
def.field("table").qualityTable = nil
def.field(EasyItemTipHelper).easyItemTipHelper = nil
def.field("table").uiObjs = nil
def.static("=>", DlgChildPropTraining).Instance = function()
  if instance == nil then
    instance = DlgChildPropTraining()
  end
  return instance
end
def.method("userdata").ShowPanel = function(self, childId)
  if self:IsShow() then
    return
  end
  self.childId = childId
  self:CreatePanel(RESPATH.PREFAB_CHILD_ATTR, 2)
  self:SetModal(true)
end
def.method().HidePanel = function(self)
  self:DestroyPanel()
end
def.override().OnCreate = function(self)
  self:Init()
  self:Fill()
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Quality_Updated, DlgChildPropTraining.OnQualityUpdated)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.CHILD_SCORE_CHANGE, DlgChildPropTraining.OnChildScoreChange)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Quality_Updated, DlgChildPropTraining.OnQualityUpdated)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.CHILD_SCORE_CHANGE, DlgChildPropTraining.OnChildScoreChange)
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
  self.uiObjs.Group_Remember = self.uiObjs.Img_Bg1:FindDirect("Group_Remember")
  self.uiObjs.Group_Score = self.uiObjs.Img_Bg1:FindDirect("Img_BgPower/Group_Score")
  local uiToggle = self.m_panel:FindDirect("Img_Bg0/Img_Bg1/Img_BgAttribute/Group_Attribute/Img_BgAttribute1"):GetComponent("UIToggle")
  uiToggle.value = true
end
def.method("string").onClick = function(self, id)
  if string.find(id, "Img_BgAttribute") then
    local idx = tonumber(string.sub(id, #"Img_BgAttribute" + 1, -1))
    self.selectedIndex = idx
  elseif id == "Btn_Close" then
    self:HidePanel()
  elseif id == "Btn_Remember" then
    self:OnTrainButtonClick()
  end
end
def.method().OnTrainButtonClick = function(self)
  local qualityInfo = self.qualityTable[self.selectedIndex]
  if qualityInfo == nil then
    return
  end
  if qualityInfo.maxValue == qualityInfo.value then
    Toast(textRes.Pet[60])
  end
  local CommonUseItem = require("GUI.CommonUseItem")
  CommonUseItem.Instance().initPos = nil
  CommonUseItem.Instance().enableUseAll = false
  CommonUseItem.ShowCommonUse(textRes.Children[3080], {
    ItemType.CHILDREN_APTITUDE_ITEM
  }, function(itemCfgId, useAll)
    local itemCount = gmodule.moduleMgr:GetModule(ModuleId.ITEM):GetItemCountById(itemCfgId)
    if itemCount < 1 then
      Toast(textRes.Children[3009])
      self.easyItemTipHelper:CheckItem2ShowTip("Img_Item")
    else
      local selectedPropType = self:GetPropType(self.selectedIndex)
      if selectedPropType > 0 then
        gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.children.CAddAptitudeRep").new(self.childId, selectedPropType, itemCfgId))
      end
    end
  end, nil)
end
def.static("table", "table").OnChildInfoUpdate = function(params, context)
  local childId = params[1]
  local self = instance
  if childId ~= self.childId then
    printInfo("LianGu panel update faield : ", childId)
    return
  end
  self:UpdateChildQualityInfo()
end
def.static("table", "table").OnQualityUpdated = function()
  instance:UpdateChildQualityInfo()
end
def.static("table", "table").OnChildScoreChange = function(p1, p2)
  instance:TweenYouthChildScore(p1)
end
def.method().Fill = function(self)
  self:UpdateChildQualityInfo()
  self:ShowYouthChildScore()
end
def.method().UpdateChildQualityInfo = function(self)
  local childData = require("Main.Children.ChildrenDataMgr").Instance():GetChildById(self.childId)
  if childData == nil then
    return
  end
  local quality = childData.info.aptitudeInitMap
  local maxValues = {
    [QualityType.HP_APT] = constant.CChildrenConsts.child_hp_aptitude_max,
    [QualityType.PHYATK_APT] = constant.CChildrenConsts.child_phy_atk_aptitude_max,
    [QualityType.MAGATK_APT] = constant.CChildrenConsts.child_mag_atk_aptitude_max,
    [QualityType.PHYDEF_APT] = constant.CChildrenConsts.child_phy_def_aptitude_max,
    [QualityType.MAGDEF_APT] = constant.CChildrenConsts.child_mag_def_aptitude_max,
    [QualityType.SPEED_APT] = constant.CChildrenConsts.child_speed_aptitude_max
  }
  local function GetQualityTuple(qt)
    return {
      type = qt,
      value = quality[qt] or 0,
      maxValue = maxValues[qt],
      minValue = 0
    }
  end
  local qualityTable = {
    GetQualityTuple(QualityType.HP_APT),
    GetQualityTuple(QualityType.PHYATK_APT),
    GetQualityTuple(QualityType.MAGATK_APT),
    GetQualityTuple(QualityType.PHYDEF_APT),
    GetQualityTuple(QualityType.MAGDEF_APT),
    GetQualityTuple(QualityType.SPEED_APT)
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
      progress = value / maxValue
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
def.method().ShowYouthChildScore = function(self)
  local ChildrenUtils = require("Main.Children.ChildrenUtils")
  local childData = require("Main.Children.ChildrenDataMgr").Instance():GetChildById(self.childId)
  if childData == nil then
    ChildrenUtils.SetYouthChildScore(self.uiObjs.Group_Score, 0)
  else
    ChildrenUtils.SetYouthChildScore(self.uiObjs.Group_Score, childData:CalYouthChildScore())
  end
end
def.method("table").TweenYouthChildScore = function(self, params)
  if Int64.eq(self.childId, params.childId) then
    local ChildrenUtils = require("Main.Children.ChildrenUtils")
    ChildrenUtils.TweenYouthChildScore(self.uiObjs.Group_Score, params.preScore, params.nowScore)
  end
end
def.method().Clear = function(self)
  self.selectedIndex = 1
  self.qualityTable = nil
  self.uiObjs = nil
end
def.method("number", "=>", "number").GetPropType = function(self, index)
  if index == 1 then
    return QualityType.HP_APT
  elseif index == 2 then
    return QualityType.PHYATK_APT
  elseif index == 3 then
    return QualityType.MAGATK_APT
  elseif index == 4 then
    return QualityType.PHYDEF_APT
  elseif index == 5 then
    return QualityType.MAGDEF_APT
  elseif index == 6 then
    return QualityType.SPEED_APT
  end
  return -1
end
return DlgChildPropTraining.Commit()
