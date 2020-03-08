local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PublishSNSConfirmPanel = Lplus.Extend(ECPanelBase, "PublishSNSConfirmPanel")
local GUIUtils = require("GUI.GUIUtils")
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
local PersonalInfoModule = require("Main.PersonalInfo.PersonalInfoModule")
local SocialPlatformMgr = require("Main.PersonalInfo.mgr.SocialPlatformMgr")
local PersonalInfoInterface = require("Main.PersonalInfo.PersonalInfoInterface")
local Vector = require("Types.Vector")
local def = PublishSNSConfirmPanel.define
local instance
def.field("table").uiObjs = nil
def.field("boolean").isSendingContent = false
def.field("string").content = ""
def.field("number").advertType = -1
def.static("=>", PublishSNSConfirmPanel).Instance = function()
  if instance == nil then
    instance = PublishSNSConfirmPanel()
  end
  return instance
end
def.method("string", "number").Confirm = function(self, content, advertType)
  if self.m_panel ~= nil then
    return
  end
  self.content = content
  self.advertType = advertType
  self:CreatePanel(RESPATH.PREFAB_PUBLISH_CONFIRM_PANEL, 2)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:SetPreviewSNS()
  Event.RegisterEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.PUBLISH_INFO_SUCCESS, PublishSNSConfirmPanel.OnPublishInfoSuccess)
  Event.RegisterEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.PUBLISH_INFO_FAIL, PublishSNSConfirmPanel.OnPublishInfoFail)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Label_Confirm = self.uiObjs.Img_Bg0:FindDirect("Label_Confirm")
  self.uiObjs.Img_LabelBg = self.uiObjs.Img_Bg0:FindDirect("Img_LabelBg")
  self.uiObjs.Img_IconBg = self.uiObjs.Img_LabelBg:FindDirect("Img_IconBg")
  self.uiObjs.Img_HeadIcon = self.uiObjs.Img_IconBg:FindDirect("Img_HeadIcon")
  self.uiObjs.Label_Name = self.uiObjs.Img_LabelBg:FindDirect("Label_Name")
  self.uiObjs.Label_Level = self.uiObjs.Img_LabelBg:FindDirect("Label_Level")
  self.uiObjs.Label_Content = self.uiObjs.Img_LabelBg:FindDirect("Label_Content")
  self.uiObjs.Img_School = self.uiObjs.Img_LabelBg:FindDirect("Img_School")
  self.uiObjs.Img_Boy = self.uiObjs.Img_LabelBg:FindDirect("Img_Boy")
  self.uiObjs.Img_Girl = self.uiObjs.Img_LabelBg:FindDirect("Img_Girl")
  self.uiObjs.Img_NoSex = self.uiObjs.Img_LabelBg:FindDirect("Img_NoSex")
end
def.method().SetPreviewSNS = function(self)
  local subType = PersonalInfoInterface.GetSNSSubTypeCfgById(self.advertType)
  local confirmStr = string.format(textRes.Personal[209], subType.typeName)
  GUIUtils.SetText(self.uiObjs.Label_Confirm, confirmStr)
  GUIUtils.SetText(self.uiObjs.Label_Content, self.content)
  local heroProp = require("Main.Hero.mgr.HeroPropMgr").Instance():GetHeroProp()
  if heroProp ~= nil then
    local roleId = heroProp.id
    local personalInfo = PersonalInfoInterface.Instance():getPersonalInfo(roleId)
    GUIUtils.SetText(self.uiObjs.Label_Name, heroProp.name)
    GUIUtils.SetText(self.uiObjs.Label_Level, string.format(textRes.Personal[210], heroProp.level))
    GUIUtils.SetSprite(self.uiObjs.Img_School, GUIUtils.GetOccupationSmallIcon(heroProp.occupation))
    local AvatarInterface = require("Main.Avatar.AvatarInterface")
    _G.SetAvatarIcon(self.uiObjs.Img_HeadIcon, AvatarInterface.Instance():getCurAvatarId())
    _G.SetAvatarFrameIcon(self.uiObjs.Img_IconBg, AvatarInterface.Instance():getCurAvatarFrameId())
    GUIUtils.SetActive(self.uiObjs.Img_Boy, false)
    GUIUtils.SetActive(self.uiObjs.Img_Girl, false)
    GUIUtils.SetActive(self.uiObjs.Img_NoSex, false)
    local realGender = personalInfo.info.gender
    if realGender == SocialPlatformMgr.SocialGender.MALE then
      GUIUtils.SetActive(self.uiObjs.Img_Boy, true)
    elseif realGender == SocialPlatformMgr.SocialGender.FEMALE then
      GUIUtils.SetActive(self.uiObjs.Img_Girl, true)
    else
      GUIUtils.SetActive(self.uiObjs.Img_NoSex, true)
    end
  end
end
def.method().PublishSNSInfo = function(self)
  if not self.isSendingContent then
    self.isSendingContent = true
    SocialPlatformMgr.PublicshSNSInfo(self.advertType, self.content)
  else
    Toast(textRes.Personal[202])
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Cancel" then
    self:Close()
  elseif id == "Btn_Confirm" then
    self:PublishSNSInfo()
  end
end
def.method().Close = function(self)
  self:DestroyPanel()
end
def.override().OnDestroy = function(self)
  self.isSendingContent = false
  Event.UnregisterEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.PUBLISH_INFO_SUCCESS, PublishSNSConfirmPanel.OnPublishInfoSuccess)
  Event.UnregisterEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.PUBLISH_INFO_FAIL, PublishSNSConfirmPanel.OnPublishInfoFail)
end
def.static("table", "table").OnPublishInfoSuccess = function(params, context)
  local self = instance
  self:Close()
end
def.static("table", "table").OnPublishInfoFail = function(params, context)
  local self = instance
  self.isSendingContent = false
  self:Close()
end
PublishSNSConfirmPanel.Commit()
return PublishSNSConfirmPanel
