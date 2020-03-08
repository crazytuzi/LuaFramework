local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ManageSNSInfoPanel = Lplus.Extend(ECPanelBase, "ManageSNSInfoPanel")
local GUIUtils = require("GUI.GUIUtils")
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
local PersonalInfoModule = require("Main.PersonalInfo.PersonalInfoModule")
local SocialPlatformMgr = require("Main.PersonalInfo.mgr.SocialPlatformMgr")
local PersonalInfoInterface = require("Main.PersonalInfo.PersonalInfoInterface")
local Vector = require("Types.Vector")
local def = ManageSNSInfoPanel.define
local instance
def.field("table").uiObjs = nil
def.field("table").snsTypeCfgList = nil
def.field("boolean").isSendingContent = false
def.static("=>", ManageSNSInfoPanel).Instance = function()
  if instance == nil then
    instance = ManageSNSInfoPanel()
  end
  return instance
end
def.method().ShowManageSNSInfoPanel = function(self)
  if self.m_panel ~= nil then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_MANAGE_INFO_PANEL, 2)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:PullSelfSNSInfo()
  Event.RegisterEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.RECEIVE_SELF_SNS, ManageSNSInfoPanel.OnReceiveSelfSNSInfo)
  Event.RegisterEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.SELF_SNS_CHANGE, ManageSNSInfoPanel.OnSelfSNSInfoChange)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.ScrollView = self.uiObjs.Img_Bg0:FindDirect("Scroll View")
  self.uiObjs.Table_List = self.uiObjs.ScrollView:FindDirect("Table_List")
  local uiList = self.uiObjs.Table_List:GetComponent("UIList")
  uiList.itemCount = 0
  uiList:Resize()
end
def.method().PullSelfSNSInfo = function(self)
  Toast(textRes.Personal[207])
  SocialPlatformMgr.PullSelfSNSInfo()
end
def.method().UpdateSelfSNSInfo = function(self)
  local snsInfoList = SocialPlatformMgr.Instance():GetSelfSNSInfo()
  if snsInfoList ~= nil then
    local uiList = self.uiObjs.Table_List:GetComponent("UIList")
    local itemCount = #snsInfoList
    uiList.itemCount = itemCount
    uiList:Resize()
    local uiItems = uiList.children
    for i = 1, itemCount do
      local item = uiItems[i]
      self:FillSelfSNSInfo(item, snsInfoList[i])
    end
    GameUtil.AddGlobalTimer(0.1, true, function()
      self.uiObjs.ScrollView:GetComponent("UIScrollView"):ResetPosition()
    end)
  end
end
def.method("userdata", "table").FillSelfSNSInfo = function(self, item, SNSInfo)
  local Img_Bg = item:FindDirect("Img_Bg")
  local Label_Name = Img_Bg:FindDirect("Label_Name")
  local Img_HeadIcon = Img_Bg:FindDirect("Img_HeadIcon")
  local Img_Icon = Img_HeadIcon:FindDirect("Img_Icon")
  local Img_School = Img_Bg:FindDirect("Img_School")
  local LabeL_Level = Img_Bg:FindDirect("LabeL_Level")
  local Img_Type = Img_Bg:FindDirect("Img_Type")
  local LabeL_Content = Img_Bg:FindDirect("LabeL_Content")
  local Img_Boy = Img_Bg:FindDirect("Img_Boy")
  local Img_Girl = Img_Bg:FindDirect("Img_Girl")
  local Img_NoSex = Img_Bg:FindDirect("Img_NoSex")
  local AvatarInterface = require("Main.Avatar.AvatarInterface")
  _G.SetAvatarIcon(Img_Icon, AvatarInterface.Instance():getCurAvatarId())
  _G.SetAvatarFrameIcon(Img_HeadIcon, AvatarInterface.Instance():getCurAvatarFrameId())
  GUIUtils.SetActive(Img_Boy, false)
  GUIUtils.SetActive(Img_Girl, false)
  GUIUtils.SetActive(Img_NoSex, false)
  if SNSInfo.realGender == SocialPlatformMgr.SocialGender.MALE then
    GUIUtils.SetActive(Img_Boy, true)
  elseif SNSInfo.realGender == SocialPlatformMgr.SocialGender.FEMALE then
    GUIUtils.SetActive(Img_Girl, true)
  else
    GUIUtils.SetActive(Img_NoSex, true)
  end
  GUIUtils.SetSprite(Img_School, GUIUtils.GetOccupationSmallIcon(SNSInfo.occupationId))
  GUIUtils.SetText(Label_Name, _G.GetStringFromOcts(SNSInfo.name))
  GUIUtils.SetText(LabeL_Level, string.format(textRes.Personal[210], SNSInfo.level))
  GUIUtils.SetText(LabeL_Content, _G.GetStringFromOcts(SNSInfo.content))
  local typeCfg = PersonalInfoInterface.GetSNSSubTypeCfgById(SNSInfo.advertType)
  GUIUtils.SetSprite(Img_Type, typeCfg.icon)
  GUIUtils.SetActive(item:FindDirect("Img_Bg/Img_Selected/Btn_Top"), false)
  item.name = "SNS_TYPE_" .. SNSInfo.advertType
end
def.method("number").RemoveSNSInfoByType = function(self, advertType)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm(textRes.Personal[222], textRes.Personal[214], function(result)
    if result == 1 then
      SocialPlatformMgr.DeleteSelfSNSInfo(advertType)
    end
  end, nil)
end
def.method("userdata").onClickObj = function(self, obj)
  if obj.name == "Btn_Delete" then
    local item = obj.transform.parent.parent.parent.gameObject
    if item ~= nil and string.find(item.name, "SNS_TYPE_") then
      local advertType = tonumber(string.sub(item.name, 10))
      self:RemoveSNSInfoByType(advertType)
    end
  else
    self:onClick(obj.name)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:Close()
  end
end
def.method().Close = function(self)
  self:DestroyPanel()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.RECEIVE_SELF_SNS, ManageSNSInfoPanel.OnReceiveSelfSNSInfo)
  Event.UnregisterEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.SELF_SNS_CHANGE, ManageSNSInfoPanel.OnSelfSNSInfoChange)
end
def.static("table", "table").OnReceiveSelfSNSInfo = function(params, context)
  local self = instance
  self:UpdateSelfSNSInfo()
end
def.static("table", "table").OnSelfSNSInfoChange = function(params, context)
  local self = instance
  self:UpdateSelfSNSInfo()
end
ManageSNSInfoPanel.Commit()
return ManageSNSInfoPanel
