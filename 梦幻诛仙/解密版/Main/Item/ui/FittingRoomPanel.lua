local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local HeroModule = require("Main.Hero.HeroModule")
local ItemModule = require("Main.Item.ItemModule")
local ECUIModel = require("Model.ECUIModel")
local ItemUtils = require("Main.Item.ItemUtils")
local FashionUtils = require("Main.Fashion.FashionUtils")
local FittingRoomPanel = Lplus.Extend(ECPanelBase, "FittingRoomPanel")
local def = FittingRoomPanel.define
def.field("number").mItemId = -1
def.field("number").mItemType = -1
def.field("table").mExtInfo = nil
def.field("number").mWingId = -1
def.field("number").mDyeId = -1
def.field(ECUIModel).mUIModel = nil
def.field("function").closeCallback = nil
local instance
def.static("=>", FittingRoomPanel).Instance = function()
  if instance == nil then
    instance = FittingRoomPanel()
  end
  return instance
end
def.method("number", "number", "table").ShowPanel = function(self, itemType, itemId, itemInfo)
  if self:IsShow() then
    self:DestroyHeroModel()
    self:DestroyPanel()
  end
  self.closeCallback = nil
  self:SetData(itemType, itemId, itemInfo)
  self:CreatePanel(RESPATH.PREFAB_FITTING_ROOM_PANEL, 2)
end
def.method("number", "number", "function").ShowWingsPanel = function(self, wingsId, dyeId, cb)
  if self:IsShow() then
    self:DestroyHeroModel()
    self:DestroyPanel()
  end
  self.closeCallback = cb
  self:SetWingsData(wingsId, dyeId)
  self:CreatePanel(RESPATH.PREFAB_FITTING_ROOM_PANEL, 2)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:FillPanelInfo()
end
def.method().FillPanelInfo = function(self)
  self:SetHeroName()
  self:UpdateHeroModel()
end
def.method().SetHeroName = function(self)
  local heroProp = HeroModule.Instance():GetHeroProp()
  local heroName = heroProp.name
  local nameLabel = self.m_panel:FindDirect("Img_Bg/Label_PlayerName"):GetComponent("UILabel")
  if nameLabel == nil then
    return
  end
  nameLabel.text = heroName
end
def.method().UpdateHeroModel = function(self)
  local uiModel = self.m_panel:FindDirect("Img_Bg/Model"):GetComponent("UIModel")
  if uiModel == nil or uiModel.isnil then
    return
  end
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return
  end
  local tryModelInfo = self:GetTryModelInfo()
  if tryModelInfo == nil then
    return
  end
  local function AfterModelLoad()
    local m = self.mUIModel.m_model
    uiModel.modelGameObject = m
    uiModel.mCanOverflow = true
  end
  if self.mUIModel then
    self.mUIModel:Destroy()
    self.mUIModel = nil
  end
  self.mUIModel = ECUIModel.new(tryModelInfo.modelid)
  self.mUIModel.m_bUncache = true
  self.mUIModel:AddOnLoadCallback("FittingRoomPanel", AfterModelLoad)
  _G.LoadModel(self.mUIModel, tryModelInfo, 0, 0, 180, false, false)
end
def.method("=>", "table").GetTryModelInfo = function(self)
  local modelInfo = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetRoleModelInfo(gmodule.moduleMgr:GetModule(ModuleId.HERO).roleId)
  if modelInfo == nil then
    return nil
  end
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
  if self.mItemType == ItemType.FASHION_DRESS_ITEM then
    modelInfo.extraMap[ModelInfo.EXTERIOR_ID] = nil
    local fashionItem = FashionUtils.GetFashionItemByUnlockItemId(self.mItemId)
    modelInfo.extraMap[ModelInfo.FASHION_DRESS_ID] = fashionItem.id
    local dyeColor = FashionUtils.GetFashionDyeColor(fashionItem.id)
    if dyeColor then
      modelInfo.extraMap[ModelInfo.HAIR_COLOR_ID] = dyeColor.hairId
      modelInfo.extraMap[ModelInfo.CLOTH_COLOR_ID] = dyeColor.clothId
    else
      modelInfo.extraMap[ModelInfo.HAIR_COLOR_ID] = nil
      modelInfo.extraMap[ModelInfo.CLOTH_COLOR_ID] = nil
    end
  elseif self.mItemType == ItemType.FABAO_ITEM then
    modelInfo.extraMap[ModelInfo.FABAO] = self.mItemId
  elseif self.mItemType == ItemType.WING_VIEW_ITEM then
    local outlookId, dyeId = ItemUtils.MapItemId2WingViewId(self.mItemId)
    if outlookId <= 0 then
      modelInfo.extraMap[ModelInfo.WING] = nil
      modelInfo.extraMap[ModelInfo.WING_COLOR_ID] = nil
    else
      modelInfo.extraMap[ModelInfo.WING] = outlookId
      modelInfo.extraMap[ModelInfo.WING_COLOR_ID] = dyeId
    end
  elseif self.mWingId ~= -1 then
    modelInfo.extraMap[ModelInfo.WING] = self.mWingId
    modelInfo.extraMap[ModelInfo.WING_COLOR_ID] = self.mDyeId
  end
  return modelInfo
end
def.method("number", "number", "table").SetData = function(self, itemType, itemId, itemInfo)
  self.mItemType = itemType
  self.mItemId = itemId
  self.mExtInfo = itemInfo
end
def.method("number", "number").SetWingsData = function(self, wingsId, dyeId)
  self.mWingId = wingsId
  self.mDyeId = dyeId
end
def.method().ReSetData = function(self)
  self.mItemId = -1
  self.mItemType = -1
  self.mExtInfo = nil
  self.mWingId = -1
  self.mDyeId = -1
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if id == "Model" and self.mUIModel ~= nil and self.mUIModel.m_model ~= nil then
    self.mUIModel:SetDir(self.mUIModel.m_ang - dx / 2)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyHeroModel()
    self:DestroyPanel()
  end
end
def.method().DestroyHeroModel = function(self)
  self:ReSetData()
  if self.mUIModel then
    self.mUIModel:Destroy()
    self.mUIModel = nil
  end
end
def.override().OnDestroy = function(self)
  if self.closeCallback then
    self.closeCallback()
    self.closeCallback = nil
  end
end
FittingRoomPanel.Commit()
return FittingRoomPanel
