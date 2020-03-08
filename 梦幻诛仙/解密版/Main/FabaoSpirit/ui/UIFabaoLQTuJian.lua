local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UIFabaoLQTuJian = Lplus.Extend(ECPanelBase, "UIFabaoLQTuJian")
local instance
local def = UIFabaoLQTuJian.define
local GUIUtils = require("GUI.GUIUtils")
local FabaoSpiritUtils = require("Main.FabaoSpirit.FabaoSpiritUtils")
local FabaoSpiritInterface = require("Main.FabaoSpirit.FabaoSpiritInterface")
def.field("table")._uiModel = nil
def.field("table")._uiGOs = nil
def.field("table")._allDisplayLQInfos = nil
def.field("table")._uiStatus = nil
def.field("table")._effects = nil
def.const("number").MIN_SHOW_NUM = 15
def.static().ShowUI = function()
  UIFabaoLQTuJian.Instance():ShowPanel()
end
def.static().Close = function()
  UIFabaoLQTuJian.Instance():DestroyPanel()
end
def.static("=>", UIFabaoLQTuJian).Instance = function()
  if instance == nil then
    instance = UIFabaoLQTuJian()
  end
  return instance
end
def.override().OnCreate = function(self)
  self._uiStatus = self._uiStatus or {}
  self._uiStatus.bOpenStarList = false
  self._uiStatus.iSelectClsIdx = 1
  self._uiStatus.iStarIdx = 1
  self._effects = self._effects or {}
  self:InitUI()
end
def.override().OnDestroy = function(self)
  FabaoSpiritInterface._rmvModelEffects(self._effects)
  self._effects = nil
  if self._uiModel ~= nil then
    self._uiModel:Destroy()
    self._uiModel = nil
  end
  self._uiGOs = nil
  self._allDisplayLQInfos = nil
  self._uiStatus = nil
end
def.method().ShowPanel = function(self)
  if self:IsLoaded() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_LQ_PIC_MAP, 1)
  self:SetModal(true)
end
def.override("boolean").OnShow = function(self, bShow)
  if bShow then
    self:OnSelectLQ(1, 1)
    self:UpdateUIBtnStar(1)
    self._uiGOs.starList:FindDirect("Group_SmallSelected"):SetActive(false)
  end
end
def.method().InitUI = function(self)
  self._uiGOs = self._uiGOs or {}
  self._uiGOs.groupRight = self.m_panel:FindDirect("Img_Bg0/Group_Right")
  self._uiGOs.groupTitle = self.m_panel:FindDirect("Img_Bg0/Group_Title")
  self._uiGOs.listLQ = self.m_panel:FindDirect("Img_Bg0/List_LingQi")
  self._uiGOs.starList = self.m_panel:FindDirect("Img_Bg0/Group_StarChoose")
  self._uiGOs.groupInfo = self.m_panel:FindDirect("Img_Bg0/Group_Info")
  self._uiGOs.starsScroll = self._uiGOs.groupInfo:FindDirect("Group_Attribute/Scroll View")
  self._allDisplayLQInfos = FabaoSpiritUtils.GetAllLQTJInfo()
  self:InitUITujinaList(self._allDisplayLQInfos)
end
def.method("table").InitUITujinaList = function(self, allLQCfgInfos)
  local num = #allLQCfgInfos
  num = math.max(num, UIFabaoLQTuJian.MIN_SHOW_NUM)
  local ctrlScrollView = self._uiGOs.listLQ:FindDirect("Img_LingQiList/Scroll View")
  local ctrlUIList = ctrlScrollView:FindDirect("List_LQ")
  local ctrlLQList = GUIUtils.InitUIList(ctrlUIList, num)
  for i = 1, #ctrlLQList do
    local ctrlLQItm = ctrlLQList[i]
    local displayCfgInfo = allLQCfgInfos[i]
    if displayCfgInfo == nil then
      ctrlLQItm:FindDirect("Img_Select_" .. i):SetActive(false)
      ctrlLQItm:GetComponent("UIToggle").enabled = false
      ctrlLQItm:GetComponent("BoxCollider").enabled = false
    else
      self:FillLQItemInfo(ctrlLQItm, displayCfgInfo, i)
    end
  end
  ctrlLQList[1]:GetComponent("UIToggle").value = true
end
def.method("userdata", "table", "number").FillLQItemInfo = function(self, ctrl, itemInfo, idx)
  if itemInfo ~= nil and itemInfo.icon ~= nil then
    warn("itemInfo.icon", itemInfo.icon)
    local icon = ctrl:FindDirect("Icon_TJ_" .. idx)
    local imgNew = ctrl:FindDirect("Img_New_" .. idx)
    GUIUtils.SetTexture(icon, itemInfo.icon)
    imgNew:SetActive(false)
  end
end
def.method("table").UpdateUIDropList = function(self, LQCfgInfo)
  local totalStarNum = #LQCfgInfo.arrCfgId
  local ctrlScrollView = self._uiGOs.starList:FindDirect("Group_SmallSelected/Img_Bg2/Group_Btn/Scroll View")
  local ctrlUIList = ctrlScrollView:FindDirect("List_Item")
  local ctrlLQList = GUIUtils.InitUIList(ctrlUIList, totalStarNum)
  local btnStar = self._uiGOs.starList:FindDirect("Btn_Star")
  for i = 1, #ctrlLQList do
    local ctrlLQItm = ctrlLQList[i]
    local lblName = ctrlLQItm:FindDirect("Label_Name2_" .. i)
    GUIUtils.SetText(lblName, textRes.FabaoSpirit[1]:format(i))
  end
  ctrlUIList:GetComponent("UIList"):DragToMakeVisible(0, 1000)
end
def.method("table", "table").UpdateUIAttr = function(self, attrCfgInfo, LQBasicCfg)
  local attrNum = 0
  local ctrlScrollView = self._uiGOs.groupInfo:FindDirect("Group_Attribute/Scroll View")
  local ctrlUIList = ctrlScrollView:FindDirect("List_Attribute")
  if attrCfgInfo ~= nil and attrCfgInfo.arrPropValues ~= nil then
    attrNum = #attrCfgInfo.arrPropValues
  end
  local ctrlAttrList = GUIUtils.InitUIList(ctrlUIList, attrNum)
  ctrlUIList:GetComponent("UIList"):DragToMakeVisible(0, 100)
  for i = 1, #ctrlAttrList do
    local ctrlattr = ctrlAttrList[i]
    local attr = attrCfgInfo.arrPropValues[i]
    self:FillAttrInfo(ctrlattr, attr, i)
  end
  _G.GameUtil.AddGlobalTimer(0.1, true, function()
    ctrlUIList:GetComponent("UIList"):DragToMakeVisible(0, 100)
  end)
  local lblSkill = self._uiGOs.groupInfo:FindDirect("Label_Skill")
  GUIUtils.SetText(lblSkill, textRes.FabaoSpirit[3])
  local skillCfg = FabaoSpiritUtils.GetSkillCfgById(LQBasicCfg.skillId)
  lblSkill:SetActive(skillCfg ~= nil)
  local ctrlHtmlTxt = lblSkill:FindDirect("Html_Text")
  self._uiStatus.selSkillId = LQBasicCfg.skillId
  ctrlHtmlTxt:GetComponent("NGUIHTML"):ForceHtmlText(textRes.FabaoSpirit[16]:format(skillCfg and skillCfg.name or ""))
  local lblHowGet = self._uiGOs.groupInfo:FindDirect("Label_GetWay/Label")
  local displayCfgInfo = self._allDisplayLQInfos[self._uiStatus.iSelectClsIdx or 1]
  GUIUtils.SetText(lblHowGet, displayCfgInfo.strGetMethod)
end
def.method("userdata", "table", "number").FillAttrInfo = function(self, ctrl, attrInfo, idx)
  local lblName, lblVal
  if attrInfo and attrInfo.dstVal == 0 or attrInfo.propType == 0 then
    ctrl:SetActive(false)
    return
  end
  lblName = ctrl:FindDirect("Label_AttributeName_" .. idx)
  lblVal = ctrl:FindDirect("Label_AttributeNumber_" .. idx)
  local comProgres = ctrl:FindDirect("Slider_JN_Attribute01_" .. idx):GetComponent("UIProgressBar")
  local propName = FabaoSpiritUtils.GetFabaoSpiritProName(attrInfo.propType)
  GUIUtils.SetText(lblName, textRes.FabaoSpirit[5]:format(propName))
  GUIUtils.SetText(lblVal, textRes.FabaoSpirit[4]:format(attrInfo.initVal, attrInfo.dstVal))
  comProgres.value = attrInfo.initVal / attrInfo.dstVal
end
def.method("number").UpdateUIBtnStar = function(self, i)
  local btnStar = self._uiGOs.starList:FindDirect("Btn_Star")
  local lblStar = btnStar:FindDirect("Label_Jiewei")
  GUIUtils.SetText(lblStar, textRes.FabaoSpirit[1]:format(i))
  self:ToggleImgUpDown(false)
end
def.method("boolean").ToggleImgUpDown = function(self, bShowUp)
  local btnStar = self._uiGOs.starList:FindDirect("Btn_Star")
  local Img_Up = btnStar:FindDirect("Img_Up")
  local Img_Down = btnStar:FindDirect("Img_Down")
  Img_Up:SetActive(bShowUp)
  Img_Down:SetActive(not bShowUp)
end
local ECUIModel = require("Model.ECUIModel")
def.method("number", "number").UpdateUIModel = function(self, model_id, effectId)
  local comUIModel = self._uiGOs.groupRight:FindDirect("Group_Center/Model_LQ"):GetComponent("UIModel")
  local modelPath, modelColor = _G.GetModelPath(model_id)
  if modelPath == nil or modelPath == "" then
    return
  end
  FabaoSpiritInterface._rmvModelEffects(self._effects)
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
  self._uiModel.m_bUncache = true
  self._uiModel:LoadUIModel(modelPath, function(ret)
    if not self._uiModel or not self._uiModel.m_model or self._uiModel.m_model.isnil then
      return
    end
    fun_afterload()
  end)
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  self._uiStatus.bOpenStarList = false
  if id ~= "Btn_Star" then
    self._uiGOs.starsScroll:GetComponent("UIScrollView"):ResetPosition()
    self._uiGOs.starList:FindDirect("Group_SmallSelected"):SetActive(false)
  end
  if id == "Btn_Star" then
    self._uiStatus.bOpenStarList = not self._uiStatus.bOpenStarList
    self:ShowStarList(self._uiStatus.bOpenStarList)
  elseif id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Html_Text" then
    require("Main.Skill.SkillTipMgr").Instance():ShowTipByIdEx(self._uiStatus.selSkillId or 0, clickObj, 0)
  elseif string.find(id, "Img_TJ_BgLingQi_%d") then
    local strs = string.split(id, "_")
    local idx = tonumber(strs[4])
    self:OnSelectLQCls(idx)
    self:UpdateUIBtnStar(1)
  elseif string.find(id, "Bg_Item_%d") then
    local idx = tonumber(string.sub(id, #"Bg_Item_" + 1, #id))
    self._uiStatus.iStarIdx = idx
    self:OnSelectLQ(self._uiStatus.iSelectClsIdx, idx)
    self:UpdateUIBtnStar(idx)
  end
end
def.method("number", "number").OnSelectLQ = function(self, clsIdx, idx)
  local LQInfo = self._allDisplayLQInfos[clsIdx]
  self._uiGOs.starList:SetActive(LQInfo ~= nil)
  self._uiGOs.groupInfo:SetActive(LQInfo ~= nil)
  self._uiGOs.groupRight:SetActive(LQInfo ~= nil)
  if LQInfo ~= nil then
    self._uiGOs.starList:FindDirect("Group_SmallSelected"):SetActive(self._uiStatus.bOpenStarList)
    local LQClsCfg = FabaoSpiritUtils.GetLQClsCfgByClsId(LQInfo.classId)
    local cfgId = LQClsCfg.arrCfgId[idx]
    local attrInfo = FabaoSpiritUtils.GetFabaoLQPropCfgById(cfgId)
    local LQBasicCfg = FabaoSpiritUtils.GetFabaoLQCfg(cfgId)
    self:UpdateUIAttr(attrInfo, LQBasicCfg)
    self:UpdateUIModel(LQBasicCfg.modelId, LQBasicCfg.boneEffectId)
    local lblLQName = self._uiGOs.groupRight:FindDirect("Group_Top/Img_BgName/Label_Name")
    GUIUtils.SetText(lblLQName, LQBasicCfg.name)
  end
end
def.method("number").OnSelectLQCls = function(self, idx)
  self._uiStatus.iSelectClsIdx = idx
  self._uiStatus.iStarIdx = 1
  self:OnSelectLQ(idx, 1)
end
def.method("boolean").ShowStarList = function(self, bShow)
  self._uiGOs.starList:FindDirect("Group_SmallSelected"):SetActive(bShow)
  self:ToggleImgUpDown(bShow)
  if bShow then
    local LQInfo = self._allDisplayLQInfos[self._uiStatus.iSelectClsIdx]
    local LQClsCfg = FabaoSpiritUtils.GetLQClsCfgByClsId(LQInfo.classId)
    self:UpdateUIDropList(LQClsCfg)
  else
    self:UpdateUIBtnStar(self._uiStatus.iStarIdx)
  end
end
return UIFabaoLQTuJian.Commit()
