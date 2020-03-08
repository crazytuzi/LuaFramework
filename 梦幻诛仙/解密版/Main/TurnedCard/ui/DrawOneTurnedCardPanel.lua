local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DrawOneTurnedCardPanel = Lplus.Extend(ECPanelBase, "DrawOneTurnedCardPanel")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local Vector = require("Types.Vector")
local TurnedCardInterface = require("Main.TurnedCard.TurnedCardInterface")
local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
local TokenType = require("consts.mzm.gsp.item.confbean.TokenType")
local ECModel = require("Model.ECModel")
local UIModelWrap = require("Model.UIModelWrap")
local def = DrawOneTurnedCardPanel.define
local instance
def.field("table").itemInfo = nil
def.field(UIModelWrap)._UIModelWrap = nil
def.static("=>", DrawOneTurnedCardPanel).Instance = function()
  if instance == nil then
    instance = DrawOneTurnedCardPanel()
  end
  return instance
end
def.method("table").ShowPanel = function(self, itemInfo)
  if self:IsShow() then
    return
  end
  self.itemInfo = itemInfo
  self:CreatePanel(RESPATH.PREFAB_SHAPESHIFT_ONE_CARD, 0)
  self:SetModal(true)
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:setItemInfo()
  else
  end
end
def.override().OnCreate = function(self)
end
def.override().OnDestroy = function(self)
  if self._UIModelWrap then
    self._UIModelWrap:Destroy()
    self._UIModelWrap = nil
  end
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("--------DrawOneTurnedCardPanel onClick:", id)
  local strs = string.split(id, "_")
  if id == "Btn_Conform" then
    self:Hide()
  elseif id == "Btn_Again" then
    self:Hide()
    gmodule.moduleMgr:GetModule(ModuleId.TURNED_CARD):playEffectAndLottery(1)
  end
end
def.method().setItemInfo = function(self)
  if self.itemInfo == nil then
    return
  end
  local itemId = self.itemInfo.item_cfg_id
  local Group_Items = self.m_panel:FindDirect("Img_Bg0/Group_One/Group_Items")
  local Label_Name = Group_Items:FindDirect("Label_Name")
  local Label_Num = self.m_panel:FindDirect("Img_Bg0/Group_Out/Btn_Again/Label_Num")
  local Img_Card = Group_Items:FindDirect("Img_Card")
  local Img_Type = Group_Items:FindDirect("Img_Type")
  Label_Num:GetComponent("UILabel"):set_text(constant.CChangeModelCardConsts.LOTTERY_COST)
  local cardItemCfg = TurnedCardUtils.GetChangeModelCardItemCfg(itemId)
  if cardItemCfg == nil then
    return
  end
  Img_Card:GetComponent("UISprite"):set_spriteName(TurnedCardUtils.TurnedCardModelFrame[cardItemCfg.cardLevel])
  local itemBase = ItemUtils.GetItemBase(itemId)
  Label_Name:GetComponent("UILabel"):set_text(itemBase.name)
  if self._UIModelWrap == nil then
    local Model_Card = Group_Items:FindDirect("Model_Card")
    local uiModel = Model_Card:GetComponent("UIModel")
    uiModel.mCanOverflow = true
    self._UIModelWrap = UIModelWrap.new(uiModel)
  end
  local cardCfg = TurnedCardUtils.GetChangeModelCardCfg(cardItemCfg.cardCfgId)
  local classCfg = TurnedCardUtils.GetCardClassCfg(cardCfg.classType)
  GUIUtils.FillIcon(Img_Type:GetComponent("UITexture"), classCfg.smallIconId)
  local changeModelCfg = _G.GetModelChangeCfg(cardCfg.changeModelId)
  local modelId = changeModelCfg.modelId
  local modelinfo = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, modelId)
  local headidx = DynamicRecord.GetIntValue(modelinfo, "halfBodyIconId")
  local iconRecord = DynamicData.GetRecord(CFG_PATH.DATA_ICONRES, headidx)
  if iconRecord == nil then
    warn("Icon res get nil record for id: ", headidx)
    return
  end
  local resourceType = iconRecord:GetIntValue("iconType")
  if resourceType == 1 then
    local resourcePath = iconRecord:GetStringValue("path")
    if resourcePath and resourcePath ~= "" then
      self._UIModelWrap:Load(resourcePath .. ".u3dext")
    else
      warn(" resourcePath == \"\" iconId = " .. headidx)
    end
  end
end
DrawOneTurnedCardPanel.Commit()
return DrawOneTurnedCardPanel
