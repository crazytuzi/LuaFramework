local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UIPreview = Lplus.Extend(ECPanelBase, MODULE_NAME)
local instance
local def = UIPreview.define
local FabaoSpiritInterface = require("Main.FabaoSpirit.FabaoSpiritInterface")
local GUIUtils = require("GUI.GUIUtils")
local FabaoSpiritUtils = require("Main.FabaoSpirit.FabaoSpiritUtils")
def.field("table")._allLQInfos = nil
def.field("table")._uiStatus = nil
def.field("table")._uiGOs = nil
def.static("=>", UIPreview).Instance = function(...)
  if instance == nil then
    instance = UIPreview()
  end
  return instance
end
def.override().OnCreate = function(self)
  self._uiGOs = {}
  self._uiStatus = {}
  local allInfos, propsNum = FabaoSpiritInterface.GetOwnedLQsAllInfos()
  self._allLQInfos = allInfos
  self._uiStatus.propsNum = propsNum
  self:InitUI()
end
def.method().InitUI = function(self)
  self._uiGOs.groupProps = self.m_panel:FindDirect("Img_Bg/Group_AttributeInfo")
  self._uiGOs.groupSkills = self.m_panel:FindDirect("Img_Bg/Group_Attribute")
  self:UpdateUISkills()
  self:UpdateUIAttrs()
end
def.override().OnDestroy = function(self)
  self._allLQInfos = nil
  self._uiGOs = nil
  self._uiStatus = nil
end
def.method().UpdateUISkills = function(self)
  local group_skill = self._uiGOs.groupSkills:FindDirect("Group_Skill")
  local ctrlScrollView = group_skill:FindDirect("Scroll View")
  local ctrlUIList = ctrlScrollView:FindDirect("List_Skill")
  local ctrlAttrList = GUIUtils.InitUIList(ctrlUIList, #(self._allLQInfos and self._allLQInfos.arrSkillIds or {}))
  for i = 1, #ctrlAttrList do
    local comHtml = ctrlAttrList[i]:GetComponent("NGUIHTML")
    local skillCfg = FabaoSpiritUtils.GetSkillCfgById(self._allLQInfos.arrSkillIds[i])
    comHtml:ForceHtmlText(textRes.FabaoSpirit[16]:format(skillCfg and skillCfg.name or ""))
  end
  ctrlScrollView:GetComponent("UIScrollView"):ResetPosition()
end
def.method().UpdateUIAttrs = function(self)
  local group_attr = self._uiGOs.groupProps:FindDirect("Group_Attribute")
  local ctrlScrollView = group_attr:FindDirect("Scroll View")
  local ctrlUIList = ctrlScrollView:FindDirect("List_Attribute")
  local ctrlAttrList = GUIUtils.InitUIList(ctrlUIList, self._uiStatus.propsNum)
  local i = 1
  for propType, prop in pairs(self._allLQInfos.tblProps) do
    local lblName = ctrlAttrList[i]:FindDirect("Label_AttributeName_" .. i)
    local lblVal = ctrlAttrList[i]:FindDirect("Label_AttributeNumber_" .. i)
    local comProgress = ctrlAttrList[i]:FindDirect("Slider_JN_Attribute01_" .. i):GetComponent("UIProgressBar")
    GUIUtils.SetText(lblName, FabaoSpiritUtils.GetFabaoSpiritProName(propType))
    GUIUtils.SetText(lblVal, textRes.FabaoSpirit[4]:format(prop.curVal, prop.dstVal))
    comProgress.value = prop.curVal / prop.dstVal
    i = i + 1
  end
  ctrlScrollView:GetComponent("UIScrollView"):ResetPosition()
end
def.method().ShowPanel = function(self)
  if self:IsLoaded() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_LQ_PREVIEW, 1)
  self:SetModal(true)
end
def.method().ClosePanel = function(self)
  self:DestroyPanel()
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Close" then
    self:ClosePanel()
  elseif string.find(id, "Html_Text_%d") then
    local idx = tonumber(string.sub(id, #"Html_Text_" + 1, #id))
    local skillId = self._allLQInfos.arrSkillIds[idx]
    require("Main.Skill.SkillTipMgr").Instance():ShowTipByIdEx(skillId, clickObj, 0)
  end
end
return UIPreview.Commit()
