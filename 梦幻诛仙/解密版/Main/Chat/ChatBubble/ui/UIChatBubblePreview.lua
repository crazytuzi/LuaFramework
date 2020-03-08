local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UIChatBubblePreview = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Cls = UIChatBubblePreview
local def = UIChatBubblePreview.define
local instance
local GUIUtils = require("GUI.GUIUtils")
local ChatBubbleMgr = require("Main.Chat.ChatBubble.ChatBubbleMgr")
local ChatBubbleUtils = require("Main.Chat.ChatBubble.ChatBubbleUtils")
def.field("table")._uiGOs = nil
def.field("table")._bubbleCfg = nil
def.field("table")._uiModel = nil
def.field("table")._modelInfo = nil
def.static("=>", Cls).Instance = function()
  if instance == nil then
    instance = Cls()
  end
  return instance
end
def.override().OnCreate = function(self)
  self._uiGOs = {}
  self._uiGOs.tweenTimer = 0
  self._uiGOs.uiModel = self.m_panel:FindDirect("Img_0/Bg_Model/Model_CW")
  self._uiGOs.imgBubble = self.m_panel:FindDirect("Img_0/Bg_Model/Img_PaoPao")
  self._uiGOs.imgArrow = self.m_panel:FindDirect("Img_0/Bg_Model/Img_Arrow")
  self._uiGOs.lblTips = self.m_panel:FindDirect("Img_0/Bg_Model/Label_Tips")
  self:_updateUI()
end
def.override("boolean").OnShow = function(self, s)
  if s then
  end
end
def.override().OnDestroy = function(self)
  if self._uiGOs.tweenTimer ~= 0 then
    _G.GameUtil.RemoveGlobalTimer(self._uiGOs.tweenTimer)
  end
  self._uiGOs = nil
  self._bubbleCfg = nil
  if self._uiModel ~= nil then
    self._uiModel:Destroy()
  end
  self._modelInfo = nil
end
def.method()._updateUI = function(self)
  self:_updateUIModel()
  self:_updateUIBubble()
end
def.method("table", "=>", "number").GetRoleModelId = function(self, heroProp)
  local heroOccupation = heroProp.occupation
  local modelId = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyModelId()
  if heroOccupation ~= ocp then
    local gender = heroProp.gender
    local ocpCfg = _G.GetOccupationCfg(ocp, gender)
    if ocpCfg then
      modelId = ocpCfg.modelId
    end
  end
  return modelId
end
local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
local ECUIModel = require("Model.ECUIModel")
def.method("number", "=>", "table").GetOccupationModelInfo = function(self, ocp)
  local heroProp = _G.GetHeroProp()
  local heroOccupation = heroProp.occupation
  local tmodelInfo = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetRoleModelInfo(gmodule.moduleMgr:GetModule(ModuleId.HERO).roleId)
  local modelInfo = clone(tmodelInfo)
  if heroOccupation ~= ocp then
    local LoginUtility = require("Main.Login.LoginUtility")
    local createRoleCfg = LoginUtility.GetCreateRoleCfg(ocp, heroProp.gender)
    modelInfo.extraMap[ModelInfo.HAIR_COLOR_ID] = createRoleCfg.defaultHairDryId
    modelInfo.extraMap[ModelInfo.CLOTH_COLOR_ID] = createRoleCfg.defaultClothDryId
    modelInfo.extraMap[ModelInfo.FASHION_DRESS_ID] = FashionDressConst.NO_FASHION_DRESS
    modelInfo.extraMap[ModelInfo.QILING_EFFECT_LEVEL] = self:GetOcpQiLingEffectLevel(ocp)
    modelInfo.extraMap[ModelInfo.WEAPON] = nil
    local occupationBag = OcpEquipmentMgr.Instance():GetOccupationBag(ocp)
    if occupationBag then
      local item = occupationBag.items[WearPos.WEAPON]
      if item then
        modelInfo.extraMap[ModelInfo.WEAPON] = item.id
        modelInfo.extraMap[ModelInfo.QILING_LEVEL] = item.extraMap[ItemXStoreType.STRENGTH_LEVEL] or 0
      end
    end
    local try_evaluate = function(dst, src, key)
      dst[key] = src[key] and src[key] or dst[key]
    end
    local socpModelInfo = OcpEquipmentMgr.Instance():GetOccupationModelInfo(ocp)
    if socpModelInfo then
      try_evaluate(modelInfo.extraMap, socpModelInfo.extraMap, ModelInfo.HAIR_COLOR_ID)
      try_evaluate(modelInfo.extraMap, socpModelInfo.extraMap, ModelInfo.CLOTH_COLOR_ID)
      try_evaluate(modelInfo.extraMap, socpModelInfo.extraMap, ModelInfo.FASHION_DRESS_ID)
    end
  end
  return modelInfo
end
def.method()._updateUIModel = function(self)
  local comUIModel = self._uiGOs.uiModel:GetComponent("UIModel")
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return
  end
  local ocp = _G.GetHeroProp().occupation
  local modelId = self:GetRoleModelId(heroProp)
  if self._uiModel ~= nil then
    self._uiModel:Destroy()
  end
  self._uiModel = ECUIModel.new(modelId)
  if self._modelInfo == nil then
    self._modelInfo = self:GetOccupationModelInfo(ocp)
  end
  local modelInfo = self._modelInfo
  modelInfo.modelid = modelId
  _G.LoadModelWithCallBack(self._uiModel, modelInfo, false, false, function()
    if self.m_panel == nil or self.m_panel.isnil then
      if self._uiModel then
        self._uiModel:Destroy()
        self._uiModel = nil
      end
      return
    end
    if self._uiModel == nil or self._uiModel.m_model == nil or self._uiModel.m_model.isnil or comUIModel == nil or comUIModel.isnil then
      return
    end
    self._uiModel:SetDir(180)
    self._uiModel:Play(ActionName.Stand)
    comUIModel.modelGameObject = self._uiModel:GetMainModel()
    if comUIModel.mCanOverflow ~= nil then
      comUIModel.mCanOverflow = true
      local camera = comUIModel:get_modelCamera()
      if camera then
        camera:set_orthographic(true)
      end
    end
  end)
end
def.method()._updateUIBubble = function(self)
  ChatBubbleUtils.SetSprite(self._uiGOs.imgBubble, self._bubbleCfg.sceneResource)
  ChatBubbleUtils.SetSprite(self._uiGOs.imgArrow, self._bubbleCfg.arrowResource)
  if self._uiGOs.tweenTimer ~= 0 then
    _G.GameUtil.RemoveGlobalTimer(self._uiGOs.tweenTimer)
    self._uiGOs.tweenTimer = 0
  end
  local time = 5
  local function funcTween()
    local tween = _G.TweenAlpha.Begin(self._uiGOs.imgBubble, 1, 0)
    tween:set_delay(time - 1)
    local tweenArrow = _G.TweenAlpha.Begin(self._uiGOs.imgArrow, 1, 0)
    tweenArrow:set_delay(time - 1)
    local tweenTxt = _G.TweenAlpha.Begin(self._uiGOs.lblTips, 1, 0)
    tweenTxt:set_delay(time - 1)
  end
  funcTween()
  self._uiGOs.tweenTimer = _G.GameUtil.AddGlobalTimer(time, false, function()
    if self and not _G.IsNil(self._uiGOs.imgBubble) then
      local color = self._uiGOs.lblTips:GetComponent("UILabel").color
      color.a = 1
      self._uiGOs.lblTips:GetComponent("UILabel").color = color
      color = self._uiGOs.imgBubble:GetComponent("UISprite").color
      color.a = 1
      self._uiGOs.imgBubble:GetComponent("UISprite").color = color
      color = self._uiGOs.imgArrow:GetComponent("UISprite").color
      color.a = 1
      self._uiGOs.imgArrow:GetComponent("UISprite").color = color
      funcTween()
    end
  end)
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  end
end
def.method("table").ShowPanel = function(self, bubbleCfg)
  if self:IsLoaded() then
    return
  end
  self._bubbleCfg = bubbleCfg
  self:CreatePanel(RESPATH.PREFAB_CHATBUBBLE_PREVIEW, 2)
  self:SetModal(true)
end
def.method("string").onDragStart = function(self, id)
  if id == "Model_CW" then
    self._uiGOs.isDrag = true
  end
end
def.method("string").onDragEnd = function(self, id)
  self._uiGOs.isDrag = false
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self._uiGOs.isDrag then
    self._uiModel:SetDir(self._uiModel.m_ang - dx * 0.5)
  end
end
return UIChatBubblePreview.Commit()
