local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UIGetAndUpgradeHint = Lplus.Extend(ECPanelBase, MODULE_NAME)
local instance
local def = UIGetAndUpgradeHint.define
local FabaoSpiritUtils = require("Main.FabaoSpirit.FabaoSpiritUtils")
local FabaoSpiritInterface = require("Main.FabaoSpirit.FabaoSpiritInterface")
local GUIUtils = require("GUI.GUIUtils")
local ECUIModel = require("Model.ECUIModel")
local ENUM_OPERA = {GET_LQ = 1, UPGRADE = 2}
def.field("table")._uiStatus = nil
def.field("table")._LQInfo = nil
def.field("table")._uiModel = nil
def.field("table")._uiGOs = nil
def.field("table")._effects = nil
def.static("=>", UIGetAndUpgradeHint).Instance = function()
  if instance == nil then
    instance = UIGetAndUpgradeHint()
  end
  return instance
end
def.override().OnCreate = function(self)
  self._effects = self._effects or {}
  self:InitUI()
end
def.override().OnDestroy = function(self)
  self._uiStatus = nil
  self._LQInfo = nil
  FabaoSpiritInterface._rmvModelEffects(self._effects)
  self._effects = nil
  if self._uiModel ~= nil then
    self._uiModel:Destroy()
    self._uiModel = nil
  end
end
def.method().InitUI = function(self)
  self._uiGOs = self._uiGOs or {}
  self._uiGOs.comUIModel = self.m_panel:FindDirect("Img_Bg1/WingModel"):GetComponent("UIModel")
  self._uiGOs.titleUpgrade = self.m_panel:FindDirect("Img_Bg1/Title_UpgradeSuccess")
  self._uiGOs.titleGetNew = self.m_panel:FindDirect("Img_Bg1/Title_GetLingQi")
  self._uiGOs.groupAttr = self.m_panel:FindDirect("Img_Bg1/Group_Info")
  if self._uiStatus.operaType == ENUM_OPERA.GET_LQ then
    self._uiGOs.titleUpgrade:SetActive(false)
    self._uiGOs.titleGetNew:SetActive(true)
  else
    self._uiGOs.titleUpgrade:SetActive(true)
    self._uiGOs.titleGetNew:SetActive(false)
  end
  self:UpdateUIAttr()
end
def.method().UpdateUIAttr = function(self)
  local LQClsCfg = FabaoSpiritUtils.GetLQClsCfgByClsId(self._LQInfo.class_id)
  local cfgId = self:GetLQCfgIdByClsCfg(self._LQInfo, LQClsCfg)
  local LQBasicCfg = FabaoSpiritUtils.GetFabaoLQCfg(cfgId)
  local LQPropCfg = FabaoSpiritUtils.GetFabaoLQPropCfgById(cfgId)
  local ctrlRoot = self._uiGOs.groupAttr
  local lblLQName = ctrlRoot:FindDirect("Label_Name")
  GUIUtils.SetText(lblLQName, LQBasicCfg.name)
  local ctrlScrollView = ctrlRoot:FindDirect("Group_Attribute/Scroll View")
  local ctrlUIList = ctrlScrollView:FindDirect("List_Attribute")
  local ctrlAttrList = GUIUtils.InitUIList(ctrlUIList, #LQPropCfg.arrPropValues)
  for i = 1, #ctrlAttrList do
    local ctrlattr = ctrlAttrList[i]
    local attr = LQPropCfg.arrPropValues[i]
    local propVal = self._LQInfo.properties[attr.propType]
    if propVal ~= nil then
      attr.initVal = propVal
    end
    self:FillAttrInfo(ctrlattr, attr, i)
  end
  self:SetUIModel(LQBasicCfg.modelId, LQBasicCfg.boneEffectId)
  local lblSkill = ctrlRoot:FindDirect("Label_Skill")
  local skillCfg = FabaoSpiritUtils.GetSkillCfgById(LQBasicCfg.skillId)
  lblSkill:SetActive(skillCfg ~= nil)
  if skillCfg ~= nil then
    local lblHtmlSkill = lblSkill:FindDirect("Html_Text")
    lblHtmlSkill:GetComponent("NGUIHTML"):ForceHtmlText(textRes.FabaoSpirit[16]:format(skillCfg.name))
  end
end
def.method("table", "table", "=>", "number").GetLQCfgIdByClsCfg = function(self, ownLQInfo, LQClsCfg)
  if LQClsCfg == nil then
    return 0
  end
  local lv = 1
  if #LQClsCfg.arrCfgId ~= 1 then
    lv = ownLQInfo.level
  end
  warn("LQClsCfg.arrCfgId size", #LQClsCfg.arrCfgId, "lv", lv)
  return LQClsCfg.arrCfgId[lv] or 0
end
def.method("userdata", "table", "number").FillAttrInfo = function(self, ctrl, LQAttrInfo, idx)
  local lblName = ctrl:FindDirect("Label_AttributeName_" .. idx)
  local lblVal = ctrl:FindDirect("Label_AttributeNumber_" .. idx)
  GUIUtils.SetText(lblName, FabaoSpiritUtils.GetFabaoSpiritProName(LQAttrInfo.propType))
  GUIUtils.SetText(lblVal, textRes.FabaoSpirit[4]:format(LQAttrInfo.initVal, LQAttrInfo.dstVal))
end
def.method("number", "number").SetUIModel = function(self, model_id, effectId)
  local comUIModel = self._uiGOs.comUIModel
  local modelPath, modelColor = _G.GetModelPath(model_id)
  if modelPath == nil or modelPath == "" then
    return
  end
  if self._uiModel then
    self._uiModel:Destroy()
  end
  local function fun_afterload()
    comUIModel.modelGameObject = self._uiModel.m_model
    self._effects = {}
    FabaoSpiritInterface._addBoneEffect(effectId, self._uiModel.m_model, self._effects)
    if comUIModel.mCanOverflow ~= nil then
      comUIModel.mCanOverflow = true
      local cam = comUIModel:get_modelCamera()
      cam:set_orthographic(true)
    end
  end
  self._uiModel = ECUIModel.new(model_id)
  local uiModel = self._uiModel
  uiModel.m_bUncache = true
  uiModel:LoadUIModel(modelPath, function(ret)
    if not uiModel or not uiModel.m_model or uiModel.m_model.isnil then
      return
    end
    fun_afterload()
  end)
end
def.method("number", "table").ShowPanel = function(self, operaType, LQInfo)
  self._uiStatus = self._uiStatus or {}
  self._uiStatus.operaType = operaType
  self._LQInfo = LQInfo
  if self:IsLoaded() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_LQ_GET, 1)
  self:SetModal(true)
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Conform" then
    if self._uiStatus.operaType == ENUM_OPERA.GET_LQ then
      local FabaoSpiritNode = require("Main.FabaoSpirit.ui.FabaoSpiritNode")
      FabaoSpiritNode.SetSelectClsId(self._LQInfo.class_id or 1)
      local FabaoSocialPanel = require("Main.Fabao.ui.FabaoSocialPanel")
      FabaoSocialPanel.Instance():ShowPanel(FabaoSocialPanel.NodeId.FabaoSpirit)
    end
    self:DestroyPanel()
  end
end
return UIGetAndUpgradeHint.Commit()
