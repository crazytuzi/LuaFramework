local Lplus = require("Lplus")
local ECApollo = require("ProxySDK.ECApollo")
local ModuleBase = require("Main.module.ModuleBase")
local MainUIModule = Lplus.Extend(ModuleBase, "MainUIModule")
require("Main.module.ModuleId")
local MainUIPanel = require("Main.MainUI.ui.MainUIPanel")
local ECPanelBase = require("GUI.ECPanelBase")
local BitMap = require("Types.BitMap")
local mainuiConfig = require("Main.MainUI.data.config")
local OutFightTargetPanel = require("Main.MainUI.ui.OutFightTargetPanel")
local def = MainUIModule.define
local instance
local SceneDef = mainuiConfig.SceneId
def.const("table").SceneDef = SceneDef
def.field(BitMap).sceneBitMap = nil
def.field("boolean").hideIncomplete = false
def.field("table").m_tlBtnsNotifyCounts = nil
def.static("=>", MainUIModule).Instance = function()
  if instance == nil then
    instance = MainUIModule()
    instance.m_moduleId = ModuleId.MAINUI
  end
  return instance
end
def.override().Init = function(self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, MainUIModule.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, MainUIModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.QQECStatusChange, MainUIModule.OnQQECStatusChange)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_GAME_COMMUNITY_CLICK, MainUIModule.OnClickGameCommunityBtn)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, MainUIModule.OnFeatureInit)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.paynewyear.SReceivePayNewYear", OutFightTargetPanel.OnRecvPayNewYear)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, OutFightTargetPanel.OnFeatureInit)
  self:SetDefaultScene()
  ModuleBase.Init(self)
  ECPanelBase.SetModalAction(MainUIModule.HideIncomplete)
  self:BindSceneChangeEvents()
end
def.method().BindSceneChangeEvents = function(self)
  for sceneId, binding in pairs(mainuiConfig.EventBinding) do
    if binding.enter then
      local moduleId, notifyId = binding.enter[1], binding.enter[2]
      Event.RegisterEventWithContext(moduleId, notifyId, MainUIModule.OnSceneChange, {sceneId = sceneId, action = "enter"})
    else
      error(string.format("Must bind enter scene event!"))
    end
    if binding.leave then
      local moduleId, notifyId = binding.leave[1], binding.leave[2]
      Event.RegisterEventWithContext(moduleId, notifyId, MainUIModule.OnSceneChange, {sceneId = sceneId, action = "leave"})
    else
      error(string.format("Must bind leave scene event!"))
    end
  end
end
def.method().ToggleMainUI = function(self)
  MainUIPanel.Instance():ToggleMainUI()
end
def.method().SetDefaultScene = function(self)
  self.sceneBitMap = BitMap.New(0)
  self.sceneBitMap:SetBit(SceneDef.Default, 1)
end
def.method("boolean").SetTopBtnGroupOpposite = function(self, isOpposite)
  MainUIPanel.Instance():SetTopBtnGroupOpposite(isOpposite)
end
def.method("=>", "boolean").IsHideIncomplete = function(self)
  return self.hideIncomplete
end
def.method("userdata", "number").SetTopLeftBtnsNotifyCount = function(self, btn, count)
  if _G.IsNil(btn) then
    return
  end
  local btnName = btn.name
  self.m_tlBtnsNotifyCounts = self.m_tlBtnsNotifyCounts or {}
  if count > 0 then
    self.m_tlBtnsNotifyCounts[btnName] = {btn = btn, count = count}
  else
    self.m_tlBtnsNotifyCounts[btnName] = nil
  end
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.TOP_LEFT_BTNS_NOTIFY_UPDATE, nil)
end
def.method("=>", "table").GetTopLeftBtnsNotifyCounts = function(self)
  return self.m_tlBtnsNotifyCounts or {}
end
def.method("=>", "boolean").IsTopLeftBtnsHasNotify = function(self)
  local btnNotifyCounts = self:GetTopLeftBtnsNotifyCounts()
  for btnName, v in pairs(btnNotifyCounts) do
    local btn = v.btn
    if not _G.IsNil(btn) and btn:get_activeSelf() then
      return true
    end
  end
  return false
end
def.static("table", "table").OnEnterWorld = function(p1, p2)
  local mainui = MainUIPanel.Instance()
  mainui:ShowPanel()
  if ClientCfg.IsSurportApollo() and ECApollo.IsNewPackage() and not _G.IsCrossingServer() then
    local FMShow = require("Main.Chat.ui.FMShow")
    FMShow.Instance():ShowPanel()
  end
end
def.static("table", "table").OnQQECStatusChange = function(p1, p2)
  warn("OnQQECStatusChange", p1.status)
  local ECQQEC = require("ProxySDK.ECQQEC")
  if ECQQEC.IsSurportQQEC() then
    local GameLivePanel = require("Main.Chat.ui.GameLivePanel")
    if p1.status == ECQQEC.STATE.LIVESTAR then
      GameLivePanel.Instance():ShowPanel()
    elseif p1.status == ECQQEC.STATE.LIVESTOPPED then
      GameLivePanel.Instance():DestroyPanel()
    end
  end
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  instance:SetDefaultScene()
  instance.hideIncomplete = false
  instance.m_tlBtnsNotifyCounts = nil
end
def.static("table", "table").OnFeatureInit = function(p1, p2)
  local TopFloatBtnGroup = require("Main.MainUI.ui.TopFloatBtnGroup")
  TopFloatBtnGroup.Instance():ShowPanel()
end
def.static("boolean").HideIncomplete = function(isHide)
  instance.hideIncomplete = isHide
  if not _G.PlayerIsInFight() then
    local mainui = MainUIPanel.Instance()
    _G.SafeCall(mainui.HideIncomplete, mainui, isHide)
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.HIDE_INCOMPLETE, {isHide = isHide})
  end
end
def.static("number", "number", "=>", "table").AddFunction = function(funcType, aniDuration)
  return MainUIPanel.Instance():AddFunction(funcType, aniDuration)
end
def.static().RefreshFunctions = function()
  MainUIPanel.Instance():Refresh()
end
def.static("=>", "boolean").MainUIIsReady = function()
  return MainUIPanel.Instance():IsReady()
end
def.static("table", "table").OnSceneChange = function(context, params)
  local sceneId = context.sceneId
  local action = context.action
  local val = action == "enter" and 1 or 0
  instance.sceneBitMap:SetBit(sceneId, val)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.SCENE_CHANGE, context)
end
def.static("table", "table").OnClickGameCommunityBtn = function(context, params)
  local anchorGO = context[1]
  local panel = require("Main.MainUI.ui.GameCommunityBtnPanel").Instance()
  if panel:IsShow() then
    panel:DestroyPanel()
  elseif panel:IsJustDestroy() then
  else
    panel:ShowPanel(anchorGO)
  end
end
def.static("string", "=>", "boolean").AddMenuBtnEffect = function(uiPath)
  if not MainUIModule.MainUIIsReady() then
    return false
  end
  local strs = string.split(uiPath, "/")
  local targetName = strs[#strs]
  local btnNames = MainUIModule.GetMenuBtns()
  local isMainBtn = false
  for k, v in pairs(btnNames) do
    if targetName == v then
      isMainBtn = true
      break
    end
  end
  if not isMainBtn then
    return false
  end
  local MenuUI = require("Main.MainUI.ui.MainUIMainMenu")
  local addRes = MenuUI.Instance():SetMenuBtnEffect(uiPath)
  return addRes
end
def.static("=>", "table").GetMenuBtns = function()
  local panelinstance = MainUIPanel.Instance()
  local btns = panelinstance:GetMainMenuBtns()
  local btnNames = {}
  for k, v in pairs(btns) do
    if v.name ~= nil and v.type ~= nil then
      table.insert(btnNames, v.name)
    end
  end
  return btnNames
end
def.static("string", "=>", "boolean").IsMenuBtn = function(btnName)
  local panelinstance = MainUIPanel.Instance()
  local btns = panelinstance:GetMainMenuBtns()
  for k, v in pairs(btns) do
    if v.name ~= nil and v.type ~= nil and v.name == btnName then
      return true
    end
  end
  return false
end
def.static("string", "=>", "boolean").IsMainInfoBtn = function(btnName)
  local panelinstance = MainUIPanel.Instance()
  local btns = panelinstance:GetMainInfoBtns()
  for k, v in pairs(btns) do
    if v.name ~= nil and v.name == btnName then
      return true
    end
  end
  return false
end
def.static("string").OpenAssociatedMenu = function(uiPath)
  if not string.sub(uiPath, 1, 11) == "panel_main/" then
    return
  end
  local strs = uiPath:split("/")
  local endObjName = strs[#strs]
  if MainUIModule.IsMenuBtn(endObjName) then
    require("Main.MainUI.ui.MainUIMainMenu").Instance():ManualOpenMenuList()
  elseif MainUIModule.IsMainInfoBtn(endObjName) then
    MainUIPanel.Instance():OpenMainInfoUI()
  end
end
MainUIModule.Commit()
return MainUIModule
