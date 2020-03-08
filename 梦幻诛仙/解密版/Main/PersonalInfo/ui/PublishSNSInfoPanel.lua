local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PublishSNSInfoPanel = Lplus.Extend(ECPanelBase, "PublishSNSInfoPanel")
local GUIUtils = require("GUI.GUIUtils")
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
local PersonalInfoModule = require("Main.PersonalInfo.PersonalInfoModule")
local SocialPlatformMgr = require("Main.PersonalInfo.mgr.SocialPlatformMgr")
local PersonalInfoInterface = require("Main.PersonalInfo.PersonalInfoInterface")
local PublishSNSConfirmPanel = require("Main.PersonalInfo.ui.PublishSNSConfirmPanel")
local Vector = require("Types.Vector")
local def = PublishSNSInfoPanel.define
local instance
def.field("table").uiObjs = nil
def.field("table").snsTypeCfgList = nil
def.field("boolean").isSendingContent = false
def.field("number").initSubTypeId = 0
def.static("=>", PublishSNSInfoPanel).Instance = function()
  if instance == nil then
    instance = PublishSNSInfoPanel()
  end
  return instance
end
def.method("number").ShowPublishSNSInfoPanel = function(self, subTypeId)
  if self.m_panel ~= nil then
    return
  end
  self.initSubTypeId = subTypeId
  self:CreatePanel(RESPATH.PREFAB_PUBLISH_INFO_PANEL, 2)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:InitTypeTab()
  self:SetInfoCompletePercentage()
  Event.RegisterEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.PUBLISH_INFO_SUCCESS, PublishSNSInfoPanel.OnPublishInfoSuccess)
  Event.RegisterEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.PUBLISH_INFO_FAIL, PublishSNSInfoPanel.OnPublishInfoFail)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Group_Tab = self.uiObjs.Img_Bg0:FindDirect("Group_Tab")
  self.uiObjs.TabTemplate = self.uiObjs.Group_Tab:FindDirect("Tab_FindTeacher")
  self.uiObjs.TabTemplate.name = "SubTab_0"
  self.uiObjs.TabTemplate:SetActive(false)
  self.uiObjs.Label_CompleteDegree = self.uiObjs.Img_Bg0:FindDirect("Label_CompleteDegree")
  self.uiObjs.Btn_PublishInfo = self.uiObjs.Img_Bg0:FindDirect("Btn_PublishInfo")
  self.uiObjs.Img_InputBg = self.uiObjs.Img_Bg0:FindDirect("Img_InputBg")
  self.uiObjs.Label_AdContent = self.uiObjs.Img_InputBg:FindDirect("Label_AdContent")
  self.uiObjs.Btn_Talk = self.uiObjs.Img_Bg0:FindDirect("Btn_Talk")
  self.uiObjs.Btn_Talk:SetActive(false)
end
def.method().InitTypeTab = function(self)
  local transform = self.uiObjs.Group_Tab.transform
  local childCount = transform.childCount
  for i = 2, childCount do
    local child = transform:GetChild(i - 1).gameObject
    child:Destroy()
  end
  self.snsTypeCfgList = SocialPlatformMgr.Instance():GetSNSTypeCfg()
  local tabCount = 0
  if self.snsTypeCfgList ~= nil then
    tabCount = #self.snsTypeCfgList
  end
  for i = 1, tabCount do
    if SocialPlatformMgr.IsSocialTypeFunctionOpen(self.snsTypeCfgList[i].id) then
      local subCount = 0
      if self.snsTypeCfgList[i].subTypeList ~= nil then
        subCount = #self.snsTypeCfgList[i].subTypeList
      end
      for j = 1, subCount do
        local subTypeCfg = self.snsTypeCfgList[i].subTypeList[j]
        if subTypeCfg.id ~= constant.SNSConsts.ALL_SUB_TYPE_ID then
          do
            local gridItem = GameObject.Instantiate(self.uiObjs.TabTemplate)
            gridItem.name = "SubTab_" .. subTypeCfg.id
            gridItem.transform.parent = transform
            gridItem.transform.localScale = Vector.Vector3.one
            gridItem:SetActive(true)
            local tabName = gridItem:FindDirect("Label")
            GUIUtils.SetText(tabName, subTypeCfg.typeName)
            if subTypeCfg.id == self.initSubTypeId then
              GameUtil.AddGlobalTimer(0, true, function()
                GameUtil.AddGlobalTimer(0, true, function()
                  gridItem:GetComponent("UIToggle").value = true
                  self:SetSNSContentOfType(self:GetSelectTabType())
                end)
              end)
            end
          end
        end
      end
    end
  end
  GameUtil.AddGlobalTimer(0, true, function()
    GameUtil.AddGlobalTimer(0, true, function()
      self.uiObjs.Group_Tab:GetComponent("UIGrid"):Reposition()
    end)
  end)
  self:SetSNSContentOfType(self:GetSelectTabType())
end
def.method().SetInfoCompletePercentage = function(self)
  local roleId = require("Main.Hero.mgr.HeroPropMgr").Instance():GetHeroProp().id
  local personalInfo = PersonalInfoInterface.Instance():getPersonalInfo(roleId)
  local percentage = personalInfo:getInfoPercent() / 100
  GUIUtils.SetText(self.uiObjs.Label_CompleteDegree, string.format(textRes.Personal[201], percentage))
end
def.method().PublishSNSInfo = function(self)
  if not self:CanPublishSNS(self:GetSelectTabType()) then
    Toast(textRes.Personal[239])
    return
  end
  local leftCDTime = SocialPlatformMgr.GetLeftTimeBeforeSendSNS(self:GetSelectTabType())
  if leftCDTime <= 0 then
    local content = self:GetSNSContent()
    if SensitiveWordsFilter.ContainsSensitiveWord(content) then
      Toast(textRes.Personal[230])
      return
    end
    local length = _G.Strlen(content)
    if length < constant.SNSConsts.CONTENT_MIN_LEN or length > constant.SNSConsts.CONTENT_MAX_LEN then
      Toast(string.format(textRes.Personal[224], constant.SNSConsts.CONTENT_MIN_LEN, constant.SNSConsts.CONTENT_MAX_LEN))
      return
    end
    content = _G.TrimIllegalChar(content)
    PublishSNSConfirmPanel.Instance():Confirm(content, self:GetSelectTabType())
  else
    local hour = leftCDTime / 3600
    local minute = leftCDTime % 3600 / 60
    local second = leftCDTime % 60
    local t = string.format("%02d:%02d:%02d", hour, minute, second)
    Toast(string.format(textRes.Personal[226], t))
  end
end
def.method("number", "=>", "boolean").CanPublishSNS = function(self, subTypeId)
  local tabCount = 0
  if self.snsTypeCfgList ~= nil then
    tabCount = #self.snsTypeCfgList
  end
  for i = 1, tabCount do
    local subCount = 0
    if self.snsTypeCfgList[i].subTypeList ~= nil then
      subCount = #self.snsTypeCfgList[i].subTypeList
    end
    for j = 1, subCount do
      local subTypeCfg = self.snsTypeCfgList[i].subTypeList[j]
      if subTypeCfg.id == subTypeId then
        return SocialPlatformMgr.IsSocialTypeFunctionOpen(self.snsTypeCfgList[i].id)
      end
    end
  end
  return true
end
def.method("=>", "number").GetSelectTabType = function(self)
  local transform = self.uiObjs.Group_Tab.transform
  local childCount = transform.childCount
  for i = 2, childCount do
    local child = transform:GetChild(i - 1).gameObject
    if child:GetComponent("UIToggle").value == true then
      local typeId = tonumber(string.sub(child.name, 8))
      return typeId
    end
  end
  return 0
end
def.method("=>", "string").GetSNSContent = function(self)
  return self.uiObjs.Label_AdContent:GetComponent("UILabel").text
end
def.method("number").SetSNSContentOfType = function(self, advertType)
  local cfg = PersonalInfoInterface.GetSNSSubTypeCfgById(advertType)
  if cfg ~= nil then
    local defaultContents = cfg.defaultContents
    local str = defaultContents[math.random(#defaultContents)]
    self.uiObjs.Img_InputBg:GetComponent("UIInput").defaultText = str
  else
    self.uiObjs.Img_InputBg:GetComponent("UIInput").defaultText = ""
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:ConfirmCancel()
  elseif id == "Btn_Edit" then
    self:Close()
    PersonalInfoModule.QuickEditPersonalInfo()
  elseif id == "Btn_PublishInfo" then
    self:PublishSNSInfo()
  elseif string.find(id, "SubTab_") then
    local advertType = tonumber(string.sub(id, 8))
    self:SetSNSContentOfType(advertType)
  end
end
def.method().ConfirmCancel = function(self)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm(textRes.Personal[222], textRes.Personal[233], function(result)
    if result == 1 then
      self:Close()
    end
  end, nil)
end
def.method().Close = function(self)
  self:DestroyPanel()
end
def.override().OnDestroy = function(self)
  self.isSendingContent = false
  self.initSubTypeId = 0
  Event.UnregisterEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.PUBLISH_INFO_SUCCESS, PublishSNSInfoPanel.OnPublishInfoSuccess)
  Event.UnregisterEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.PUBLISH_INFO_FAIL, PublishSNSInfoPanel.OnPublishInfoFail)
end
def.static("table", "table").OnPublishInfoSuccess = function(params, context)
  local self = instance
  self:Close()
end
def.static("table", "table").OnPublishInfoFail = function(params, context)
  local self = instance
  self.isSendingContent = false
end
PublishSNSInfoPanel.Commit()
return PublishSNSInfoPanel
