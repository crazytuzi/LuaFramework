local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SystemSettingPanel = Lplus.Extend(ECPanelBase, "SystemSettingPanel")
local def = SystemSettingPanel.define
local Vector = require("Types.Vector")
local ECGUIMan = require("GUI.ECGUIMan")
local SystemSettingModule = require("Main.SystemSetting.SystemSettingModule")
local SettingEnum = SystemSettingModule.SystemSetting
local GUIUtils = require("GUI.GUIUtils")
local ECMSDK = require("ProxySDK.ECMSDK")
local toggleUIMap = {
  Toggle_Music = SettingEnum.BGMusic,
  Toggle_MusicEffect = SettingEnum.EffectSound,
  Toggle_GameEffect = SettingEnum.LowFXNumbers,
  Toggle_PersonNum = SettingEnum.LowRoleNumbers,
  Toggle_NoPerson = SettingEnum.HideOtherPlayers,
  Toggle_Friend = SettingEnum.MakeFriendVarify,
  Toggle_Fly = SettingEnum.FlyingTrace,
  Toggle_XiPing = SettingEnum.DrakScreen,
  Toggle_Cicrle = SettingEnum.CirculateZhenYaoNotice,
  Toggle_SkillYell = SettingEnum.NO_SKILL_VOICE,
  Toggle_ShareEquipInfo = SettingEnum.NOT_SHARE_EQUIP_INFO,
  Toggle_FriendChat = SettingEnum.ChatWithFriendShrinkUI,
  Toggle_AddFriendLv = SettingEnum.ADD_FRIEND_LV,
  Toggle_TeamInvite = SettingEnum.BLOCK_STRANGER_INVITE,
  Toggle_OverlappingTarget = SettingEnum.CloseTouchListPanel,
  Toggle_Voice = SettingEnum.ANCHOR_SPEAKER,
  Toggle_RadioSwtich = SettingEnum.ANCHOR,
  Toggle_TeamChannel = SettingEnum.AUTO_JOIN_TEAM_VOICE,
  Toggle_HighRefreshRate = SettingEnum.FPS_HIGH,
  Toggle_MidRefreshRate = SettingEnum.FPS_MEDIUM,
  Toggle_LowRefreshRate = SettingEnum.FPS_LOW
}
local sliderUIMap = {
  SliderYinYue = SettingEnum.BGMusic,
  SliderYinXiao = SettingEnum.EffectSound,
  SliderYuYin = SettingEnum.VoiceSound,
  SliderSpeaker = SettingEnum.ANCHOR_SPEAKER
}
local inputUIMap = {
  Input_AddFriendLvNum = SettingEnum.ADD_FRIEND_LV_NUMBER
}
local customTipMap = {}
def.field("table").uiObjs = nil
def.field("string").toggleName = ""
def.field("string").selectionName = ""
def.field("table").confirmCfg = nil
local instance
def.static("=>", SystemSettingPanel).Instance = function()
  if instance == nil then
    instance = SystemSettingPanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.m_TrigGC = true
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
    return
  end
  self:CreatePanel(RESPATH.PREFAB_SYSTEM_SETTING_PANEL, 1)
  self:SetModal(true)
end
def.method("string", "string").ShowPanelToSelection = function(self, toggleName, selectionName)
  if toggleName == "" then
    self.toggleName = ""
    self.selectionName = ""
  end
  self.toggleName = toggleName
  self.selectionName = selectionName
  if self:IsShow() then
    self:GoToTargetUI()
    return
  end
  self:CreatePanel(RESPATH.PREFAB_SYSTEM_SETTING_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
  self:GoToTargetUI()
  self:SetUsetCenter()
end
def.method().SetUsetCenter = function(self)
  if ClientCfg.GetSDKType() == ClientCfg.SDKTYPE.UNISDK then
    local ECUniSDK = require("ProxySDK.ECUniSDK")
    if ECUniSDK.Instance():SDKIS(ECUniSDK.CHANNELTYPE.LOONG) then
      local switchAccountBtn = self.m_panel:FindChild("Img_Bg0/Group_Common/Btn_Account")
      local usercenterBtn = self.m_panel:FindChild("Img_Bg0/Group_Common/Btn_UserCenter")
      switchAccountBtn:SetActive(false)
      usercenterBtn:SetActive(true)
    end
  end
end
def.override().OnDestroy = function(self)
  self:Clear()
  SystemSettingModule.Instance():SaveSystemSetting()
end
def.method().GoToTargetUI = function(self)
  if self.toggleName ~= "" then
    GameUtil.AddGlobalLateTimer(0.01, true, function()
      if self:IsShow() then
        GUIUtils.Toggle(GUIUtils.FindDirect(self.uiObjs.Tab_List, self.toggleName), true)
        if self.selectionName ~= "" then
          local selectionObj = self.uiObjs.ContentScrollView:FindChild(self.selectionName)
          GUIUtils.DragToMakeVisible(self.uiObjs.ContentScrollView, selectionObj, false, 1024)
          if selectionObj then
            GUIUtils.AddLightEffectToObj(selectionObj, GUIUtils.Light.Square, {
              "onClick",
              "onToggle",
              "onScroll"
            })
          end
        end
      end
      self.toggleName = ""
      self.selectionName = ""
    end)
  end
end
def.method("string").onClick = function(self, id)
  print(string.format("%s click event: id = %s", tostring(self), id))
  if id == "SettingClass3" then
    self.uiObjs.Group_Service:SetActive(true)
  elseif string.sub(id, 1, 12) == "SettingClass" then
    self.uiObjs.Group_Service:SetActive(false)
  end
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_Account" then
    self:OnSwitchAccountButtonClick()
  elseif id == "Btn_Role" then
    self:OnSwitchRoleButtonClick()
  elseif id == "Btn_Quite" then
    self:OnExitGameButtonClick()
  elseif toggleUIMap[id] then
    local isToggle = GUIUtils.IsToggle(self.m_panel:FindChild(id))
    local settingId = toggleUIMap[id]
    self:OnGameSettingClicked(settingId, isToggle)
  elseif id == "Btn_YuYinSet" then
    self:OnVoiceSettingButtonClicked()
  elseif id == "Btn_LunTan" then
    self:openUrl(textRes.Common.qq_bbs)
  elseif id == "Btn_Report" then
    self:openUrl(textRes.Common.qq_feedback)
  elseif id == "Item1" then
    self:openUrl(textRes.Common.qq_services)
  elseif id == "Item2" then
    self:openUrl(textRes.Common.qq_pravcy)
  elseif id == "Item3" then
    self:openUrl(textRes.Common.qq_contract)
  elseif id == "Btn_LockScreen" then
    self:OnLockScreenButtonClicked()
  elseif id == "Btn_SystemAnno" then
    self:OnGameNoticeBtnClick()
  elseif id == "Btn_UserCenter" then
    if ClientCfg.GetSDKType() == ClientCfg.SDKTYPE.UNISDK then
      local ECUniSDK = require("ProxySDK.ECUniSDK")
      if ECUniSDK.Instance():SDKIS(ECUniSDK.CHANNELTYPE.LOONG) then
        ECUniSDK.Instance():UserCenter()
      end
    end
  elseif string.sub(id, 1, 13) == "Group_Select_" then
    local index = tonumber(string.sub(id, 14))
    if index and self.confirmCfg then
      local cfg = self.confirmCfg[index]
      local go = self.uiObjs.Group_FBSet:FindDirect(string.format("Container/Group_FBObject_%d/%s", index, id))
      if go then
        local active = go:GetComponent("UIToggleEx").value
        SystemSettingModule.Instance():C2S_SetCustomConfirmInfoReq(cfg.type, active and 1 or 0)
      end
    end
  end
end
def.method("string", "boolean").onToggle = function(self, id, active)
  if active then
    if id == "SettingClass5" then
      self:SetConfirmSetting()
    end
    if string.sub(id, 1, 12) == "SettingClass" then
      local scroll = self.uiObjs.ContentScrollView:GetComponent("UIScrollView")
      local drag = scroll:GetDragAmount()
      self.uiObjs.ContentScrollView.localPosition = Vector.Vector3.zero
      scroll:get_panel():set_clipOffset(Vector.Vector2.zero)
      scroll:ResetPosition()
    end
  end
end
def.method("string", "userdata").onSubmit = function(self, id, ctrl)
  if inputUIMap[id] then
    local input = self.m_panel:FindChild(id)
    local content = input:GetComponent("UIInput"):get_value()
    local num = tonumber(content)
    if num == nil then
      return
    else
      local settingId = inputUIMap[id]
      local systemSettings = SystemSettingModule.Instance():GetSettings()
      local setting = systemSettings[settingId]
      if not setting:Check(num) then
        local inputObj = self.uiObjs.ContentScrollView:FindChild(id)
        if inputObj then
          inputObj:GetComponent("UIInput"):set_value(tostring(setting.num))
        end
      else
        self:OnNumSettingInput(settingId, num)
      end
    end
  end
end
def.method("string").openUrl = function(self, url)
  require("Main.ECGame").Instance():OpenUrl(url)
end
def.method("string", "number").onScroll = function(self, id, value)
  local settingId = sliderUIMap[id]
  if settingId then
    self:OnSoundSettingScroll(settingId, value)
  end
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.TabScrollView = GUIUtils.FindDirect(self.uiObjs.Img_Bg0, "TabScrollView")
  self.uiObjs.Tab_List = GUIUtils.FindDirect(self.uiObjs.TabScrollView, "Tab_List")
  GUIUtils.Toggle(GUIUtils.FindDirect(self.uiObjs.Tab_List, "SettingClass1"), true)
  self.uiObjs.ContentScrollView = GUIUtils.FindDirect(self.uiObjs.Img_Bg0, "ScrollViewContainer/ContentScrollView")
  self.uiObjs.Group_BasicSet = GUIUtils.FindDirect(self.uiObjs.ContentScrollView, "Group_BasicSet")
  self.uiObjs.Group_GameSet = GUIUtils.FindDirect(self.uiObjs.ContentScrollView, "Group_GameSet")
  if _G.platform == _G.Platform.android then
    self.uiObjs.Group_Service = GUIUtils.FindDirect(self.uiObjs.ContentScrollView, "Group_Service_Android")
  else
    self.uiObjs.Group_Service = GUIUtils.FindDirect(self.uiObjs.ContentScrollView, "Group_Service")
  end
  self.uiObjs.Group_FMSet = GUIUtils.FindDirect(self.uiObjs.ContentScrollView, "Group_FMSet")
  self.uiObjs.Group_FBSet = GUIUtils.FindDirect(self.uiObjs.ContentScrollView, "Group_FBSet")
  self.uiObjs.Group_Common = GUIUtils.FindDirect(self.uiObjs.Img_Bg0, "Group_Common")
  self.uiObjs.Img_Head = GUIUtils.FindDirect(self.uiObjs.Group_Common, "Img_Head")
  self.uiObjs.Label_Name = GUIUtils.FindDirect(self.uiObjs.Group_Common, "Label_Name")
  self.uiObjs.Label_Server = GUIUtils.FindDirect(self.uiObjs.Group_Common, "Label_Server")
  self.uiObjs.SliderYinYue = GUIUtils.FindDirect(self.uiObjs.Group_BasicSet, "Toggle_Music/Slider_Bg")
  if self.uiObjs.SliderYinYue then
    self.uiObjs.SliderYinYue.name = "SliderYinYue"
  end
  self.uiObjs.SliderYinXiao = GUIUtils.FindDirect(self.uiObjs.Group_BasicSet, "Toggle_MusicEffect/Slider_Bg")
  if self.uiObjs.SliderYinXiao then
    self.uiObjs.SliderYinXiao.name = "SliderYinXiao"
  end
  self.uiObjs.SliderYuYin = GUIUtils.FindDirect(self.uiObjs.Group_BasicSet, "Group_YuYin/Slider_Bg")
  if self.uiObjs.SliderYuYin then
    self.uiObjs.SliderYuYin.name = "SliderYuYin"
  end
  self.uiObjs.SliderSpeaker = GUIUtils.FindDirect(self.uiObjs.Group_FMSet, "Toggle_Voice/Slider_Bg")
  if self.uiObjs.SliderSpeaker then
    self.uiObjs.SliderSpeaker.name = "SliderSpeaker"
  end
  if _G.platform == Platform.ios then
    local Btn_Quite = self.uiObjs.Group_Common:FindDirect("Btn_Quite")
    GUIUtils.SetActive(Btn_Quite, false)
    local Btn_Account = self.uiObjs.Group_Common:FindDirect("Btn_Account")
    local Btn_Role = self.uiObjs.Group_Common:FindDirect("Btn_Role")
    local Btn_LockScreen = self.uiObjs.Group_Common:FindDirect("Btn_LockScreen")
    Btn_Account.localPosition = Vector.Vector3.new(-130, Btn_Account.localPosition.y, 0)
    Btn_Role.localPosition = Vector.Vector3.new(40, Btn_Role.localPosition.y, 0)
    Btn_LockScreen.localPosition = Vector.Vector3.new(210, Btn_LockScreen.localPosition.y, 0)
  end
  self:SetCustomTip(toggleUIMap)
  self:SetCustomTip(sliderUIMap)
end
def.method("table").SetCustomTip = function(self, uiDef)
  for k, v in pairs(uiDef) do
    if customTipMap[v] then
      local tipCnt = customTipMap[v]
      local text
      if type(tipCnt) == "function" then
        text = tipCnt()
      elseif type(tipCnt) == "string" then
        text = tipCnt()
      end
      if text then
        self:SetChildLabelText(self.uiObjs.ContentScrollView:FindChild(k), text)
      end
    end
  end
end
def.method("userdata", "string").SetChildLabelText = function(self, go, text)
  if go then
    local lbl = go:FindChild("Label")
    if lbl then
      local cmp = lbl:GetComponent("UILabel")
      if cmp then
        cmp:set_text(text)
      end
    end
  end
end
def.method().UpdateUI = function(self)
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  self:SetRoleHeadImage()
  self:SetRoleName(heroProp.name)
  self:SetRoleOccupation(heroProp.occupation)
  self:SetRoleGender(heroProp.gender)
  local ServerListMgr = require("Main.Login.ServerListMgr")
  local cfg = gmodule.moduleMgr:GetModule(ModuleId.LOGIN):GetConnectedServerCfg()
  local serverName = cfg and cfg.name or "unknown"
  self:SetServerName(serverName)
  self:UpdateSystemSettings()
end
def.method().SetRoleHeadImage = function(self)
  local AvatarInterface = require("Main.Avatar.AvatarInterface")
  local avatarId = AvatarInterface.Instance():getCurAvatarId()
  local avatarFrameId = AvatarInterface.Instance():getCurAvatarFrameId()
  _G.SetAvatarIcon(self.uiObjs.Img_Head, avatarId, avatarFrameId)
  local Sprite = self.uiObjs.Img_Head:FindDirect("Sprite")
  GUIUtils.SetActive(Sprite, false)
end
def.method("string").SetRoleName = function(self, name)
  GUIUtils.SetText(self.uiObjs.Label_Name, name)
end
def.method("number").SetRoleOccupation = function(self, occupation)
  local Img_School = self.uiObjs.Group_Common:FindDirect("Img_School")
  local occupationSprite = GUIUtils.GetOccupationSmallIcon(occupation)
  GUIUtils.SetSprite(Img_School, occupationSprite)
end
def.method("number").SetRoleGender = function(self, gender)
  local Img_Sex = self.uiObjs.Group_Common:FindDirect("Img_Sex")
  local genderSprite = GUIUtils.GetSexIcon(gender)
  GUIUtils.SetSprite(Img_Sex, genderSprite)
end
def.method("string").SetServerName = function(self, serverName)
  GUIUtils.SetText(self.uiObjs.Label_Server, serverName)
end
def.method().Clear = function(self)
  self.uiObjs = nil
  self.confirmCfg = nil
end
def.method().OnSwitchAccountButtonClick = function(self)
  SystemSettingModule.Instance():SwitchAccount()
end
def.method().OnSwitchRoleButtonClick = function(self)
  SystemSettingModule.Instance():SwitchRole()
end
def.method().OnExitGameButtonClick = function(self)
  SystemSettingModule.Instance():Quit()
end
def.method("number", "boolean").OnGameSettingClicked = function(self, settingId, isToggle)
  local setting = SystemSettingModule.Instance():GetSetting(settingId)
  if isToggle then
    setting:Enable()
  else
    setting:Disable()
  end
end
def.method("number", "number").OnSoundSettingScroll = function(self, settingId, value)
  local setting = SystemSettingModule.Instance():GetSetting(settingId)
  setting:SetVolume(value)
end
def.method("number", "number").OnNumSettingInput = function(self, settingId, value)
  local setting = SystemSettingModule.Instance():GetSetting(settingId)
  setting:SetNum(value)
end
def.method().UpdateSystemSettings = function(self)
  if self.uiObjs.ContentScrollView == nil then
    return
  end
  local systemSettings = SystemSettingModule.Instance():GetSettings()
  self:SetToggleSetting(systemSettings)
  self:SetSliderSetting(systemSettings)
  self:SetNumSetting(systemSettings)
end
def.method("table").SetToggleSetting = function(self, settings)
  for uiName, settingId in pairs(toggleUIMap) do
    local setting = settings[settingId]
    local toggleObj = self.uiObjs.ContentScrollView:FindChild(uiName)
    if toggleObj then
      local value = false
      if setting:tryget("isEnabled") ~= nil then
        value = setting.isEnabled
      elseif setting:tryget("mute") ~= nil then
        value = not setting.mute
      end
      GUIUtils.Toggle(toggleObj, value)
    else
      warn("can't find toggle \"" .. uiName .. "\"")
    end
  end
end
def.method("table").SetSliderSetting = function(self, settings)
  for uiName, settingId in pairs(sliderUIMap) do
    local setting = settings[settingId]
    local sliderObj = self.uiObjs.ContentScrollView:FindChild(uiName)
    if sliderObj then
      GUIUtils.SetProgress(sliderObj, "UISlider", setting.volume)
    else
      warn("can't find slider \"" .. uiName .. "\"")
    end
  end
end
def.method("table").SetNumSetting = function(self, settings)
  for uiName, settingId in pairs(inputUIMap) do
    local setting = settings[settingId]
    local inputObj = self.uiObjs.ContentScrollView:FindChild(uiName)
    if inputObj then
      inputObj:GetComponent("UIInput"):set_value(tostring(setting.num))
    else
      warn("can't find input \"" .. uiName .. "\"")
    end
  end
end
def.method().OnVoiceSettingButtonClicked = function(self)
  Event.DispatchEvent(ModuleId.SYSTEM_SETTING, gmodule.notifyId.SystemSetting.OPEN_VOICE_SETTING_PANEL, nil)
end
def.method().OnLockScreenButtonClicked = function(self)
  require("GUI.LockScreenUIPanel").Instance():ShowPanel()
  self:DestroyPanel()
end
def.method().OnGameNoticeBtnClick = function(self)
  local UpdateNoticeModule = require("Main.UpdateNotice.UpdateNoticeModule")
  UpdateNoticeModule.OpenNoticePanel(UpdateNoticeModule.NoticeSceneType.EnterWorldAlert, function(ret)
    if ret == false then
      Toast(textRes.UpdateNotice[1])
    end
  end)
end
def.method().SetConfirmSetting = function(self)
  local list = self.uiObjs.Group_FBSet:FindChild("Container")
  list:SetActive(false)
  self.confirmCfg = nil
  SystemSettingModule.Instance():ReqConfirmSetting(function(data)
    if list.isnil then
      return
    end
    list:SetActive(true)
    self.confirmCfg = SystemSettingModule.GetConfirmSettingCfg()
    local count = #self.confirmCfg
    local listCmp = list:GetComponent("UIList")
    listCmp:set_itemCount(count)
    listCmp:Resize()
    local items = listCmp:get_children()
    for i = 1, #items do
      local uiGo = items[i]
      local info = self.confirmCfg[i]
      local name = uiGo:FindDirect(string.format("Label_Desc_%d", i))
      name:GetComponent("UILabel"):set_text(info.desc)
      local value = data[info.type] and data[info.type] > 0 and true or not info.defaultRefuse
      local toggle = uiGo:FindChild(string.format("Group_Select_%d", i))
      toggle:GetComponent("UIToggleEx").value = value
      self.m_msgHandler:Touch(uiGo)
    end
  end)
end
return SystemSettingPanel.Commit()
