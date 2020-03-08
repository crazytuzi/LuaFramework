local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local ECGUIMan = require("GUI.ECGUIMan")
local ISystemSetting = require("Main.SystemSetting.ISystemSetting")
local SystemSettingModule = Lplus.Extend(ModuleBase, "SystemSettingModule").Implement(ISystemSetting)
local LoginUtility = require("Main.Login.LoginUtility")
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
local SettingData = require("Main.SystemSetting.data.SettingData")
local SettingDataFactory = require("Main.SystemSetting.SettingDataFactory")
local SystemSettingBean = require("netio.protocol.mzm.gsp.systemsetting.SystemSetting")
local SystemSettingUIMgr = require("Main.SystemSetting.SystemSettingUIMgr")
local OnRoleQuitRes = Lplus.ForwardDeclare("ISystemSetting.OnRoleQuitRes")
local def = SystemSettingModule.define
local SystemSettingCfg = require("Main.SystemSetting.SystemSettingCfg")
local SystemSetting = SystemSettingCfg.SystemSetting
local SettingDataType = SystemSettingCfg.SettingDataType
local CSSettingMap = SystemSettingCfg.CSSettingMap
def.const("table").SystemSetting = SystemSetting
def.const("table").SettingDataType = SettingDataType
def.field("table").systemSettings = nil
def.field("table").m_quitHandlers = nil
def.field("function").m_confirmSettingReqCallback = nil
local LOCAL_DATA_KEY = "SystemSetting"
local CUR_SETTING_VERSION = SystemSettingCfg.CUR_SETTING_VERSION
local instance
def.static("=>", SystemSettingModule).Instance = function()
  if instance == nil then
    instance = SystemSettingModule()
    instance.m_moduleId = ModuleId.SYSTEM_SETTING
    instance:LoadSystemSetting()
  end
  return instance
end
def.override().Init = function(self)
  self.m_quitHandlers = self.m_quitHandlers or {}
  SystemSettingUIMgr.Instance():Init()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.systemsetting.SSyncSystemSetting", SystemSettingModule.OnSSyncSystemSetting)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.systemsetting.SSystemSettingRes", SystemSettingModule.OnSSystemSettingRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.confirm.SGetCustomConfirmInfoRep", SystemSettingModule.OnSGetCustomConfirmInfoRep)
  Event.RegisterEvent(ModuleId.SYSTEM_SETTING, gmodule.notifyId.SystemSetting.SETTING_CHANGED, SystemSettingModule.OnSettingChanged)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, SystemSettingModule.OnLeaveWorld)
end
def.override().LateInit = function(self)
  self:AddQuitHandler(self)
end
def.method("=>", "table").GetSettings = function(self)
  return self.systemSettings
end
def.method("number", "=>", SettingData).GetSetting = function(self, id)
  return self.systemSettings[id]
end
def.method().LoadSystemSetting = function(self)
  if not LuaPlayerPrefs.HasGlobalKey(LOCAL_DATA_KEY) then
    self.systemSettings = self:GetDefaultSystemSetting()
  else
    local setting = LuaPlayerPrefs.GetGlobalTable(LOCAL_DATA_KEY)
    self.systemSettings = self:Marshal(setting)
    if self.systemSettings.version ~= CUR_SETTING_VERSION then
      self.systemSettings = self:GetDefaultSystemSetting()
    else
      local defaultSettings = self:GetDefaultSystemSetting()
      for id, v in pairs(defaultSettings) do
        if self.systemSettings[id] == nil then
          self.systemSettings[id] = v
        end
      end
    end
  end
  self:InitChoiceSettingGroup()
end
def.method("=>", "table").GetDefaultSystemSetting = function(self)
  local systemSettingDefaults = SystemSettingCfg.SystemSettingDefaults
  local systemSettings = {}
  systemSettings.version = CUR_SETTING_VERSION
  for id, v in pairs(systemSettingDefaults) do
    local type = v[1]
    local param = clone(v)
    param[1] = id
    local settingData = SettingDataFactory.CreateSettingData(type)
    settingData:Ctor(unpack(param))
    systemSettings[id] = settingData
  end
  return systemSettings
end
def.method().InitChoiceSettingGroup = function(self)
  local GROUP_1 = 1
  self:GetSetting(SystemSetting.FPS_HIGH):SetGroup(GROUP_1)
  self:GetSetting(SystemSetting.FPS_MEDIUM):SetGroup(GROUP_1)
  self:GetSetting(SystemSetting.FPS_LOW):SetGroup(GROUP_1)
end
def.method().SaveSystemSetting = function(self)
  local localData = self:Unmarshal()
  LuaPlayerPrefs.SetGlobalTable(LOCAL_DATA_KEY, localData)
  LuaPlayerPrefs.Save()
end
def.method("table", "=>", "table").Marshal = function(self, localData)
  local systemSettingDefaults = SystemSettingCfg.SystemSettingDefaults
  local data = {}
  data.version = localData.version or 0
  for i, v in ipairs(localData) do
    local settingData = SettingDataFactory.CreateSettingData(v.type)
    local default = systemSettingDefaults[v.id]
    if default then
      local param = clone(default)
      param[1] = v.id
      settingData:Ctor(unpack(param))
    end
    settingData:Marshal(v)
    data[v.id] = settingData
  end
  return data
end
def.method("=>", "table").Unmarshal = function(self)
  local localData = {}
  localData.version = CUR_SETTING_VERSION
  local count = 1
  for id, v in pairs(self.systemSettings) do
    if type(v) == "table" and Lplus.is(v, SettingData) then
      localData[count] = v:Unmarshal()
      count = count + 1
    end
  end
  return localData
end
def.method().SwitchAccount = function(self)
  self:CheckExQuitConfirm(function(...)
    gmodule.moduleMgr:GetModule(ModuleId.LOGIN):ReLogin()
  end)
end
def.method().SwitchRole = function(self)
  local CrossServerLoginMgr = require("Main.Login.CrossServerLoginMgr")
  if CrossServerLoginMgr.Instance():IsCrossingServer() then
    Toast(textRes.Login[61])
    return
  end
  self:CheckExQuitConfirm(function(...)
    gmodule.moduleMgr:GetModule(ModuleId.LOGIN):Back2SelectRole()
  end)
end
local confirmDlg
def.method("boolean").ShowQuitInfo = function(self, needRestart)
  self:CheckExQuitConfirm(function(hasYield)
    if hasYield then
      self:RealQuit(needRestart)
      return
    end
    local title = textRes.Login[39]
    local desc = textRes.Login[40]
    confirmDlg = require("GUI.CommonConfirmDlg").ShowConfirm(title, desc, function(s)
      confirmDlg = nil
      if s == 1 then
        self:RealQuit(needRestart)
      end
    end, nil)
    confirmDlg:SetDepth(GUIDEPTH.TOPMOST2)
  end)
end
def.method().Quit = function(self)
  local ECQQEC = require("ProxySDK.ECQQEC")
  if ECQQEC.OnBackPressed() and platform == 2 then
    Debug.LogWarning("\233\128\128\229\135\186\231\148\181\231\171\158\231\154\132\231\149\140\233\157\162")
    return
  end
  self:QuitEx(false)
end
def.method().Restart = function(self)
  self:QuitEx(true)
end
def.method("boolean").QuitEx = function(self, needRestart)
  if confirmDlg == nil then
    self:ShowQuitInfo(needRestart)
  else
    confirmDlg:DestroyPanel()
    confirmDlg = nil
  end
end
def.method("boolean").RealQuit = function(self, needRestart)
  self:SaveSystemSetting()
  local game = require("Main.ECGame").Instance()
  if needRestart then
    warn("game:Restart")
    game:Restart()
  else
    warn("game:Quit")
    game:Quit()
  end
end
def.method("function", "=>", "boolean").CheckExQuitConfirm = function(self, callback)
  local function showConfirm(wraper, desc)
    GameUtil.AddGlobalTimer(0, true, function(...)
      confirmDlg = require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Login[39], desc, function(s)
        confirmDlg = nil
        if s == 1 then
          wraper()
        end
      end, nil)
    end)
  end
  local wraper = coroutine.wrap(function(wraper)
    local hasYield = false
    for i, handler in ipairs(self.m_quitHandlers) do
      local res = handler:OnRoleQuit()
      if res.canelQuit then
        Toast(res.reason)
        coroutine.yield(true)
      end
      if res.canQuit == false then
        showConfirm(wraper, res.reason)
        hasYield = true
        coroutine.yield(true)
      end
    end
    GameUtil.AddGlobalTimer(0, true, function(...)
      callback(hasYield)
    end)
    return false
  end)
  local ret = wraper(wraper)
  return ret
end
def.method("table").AddQuitHandler = function(self, handler)
  self.m_quitHandlers = self.m_quitHandlers or {}
  for i, v in ipairs(self.m_quitHandlers) do
    if v == handler then
      return
    end
  end
  table.insert(self.m_quitHandlers, handler)
end
def.method("=>", "table").OnRoleQuit = function(self)
  local res = OnRoleQuitRes()
  if _G.PlayerIsInFight() then
    res.canelQuit = true
    res.reason = textRes.SystemSetting[4] or "forbidden quit"
  elseif gmodule.moduleMgr:GetModule(ModuleId.HERO):IsInState(_G.RoleState.ESCORT) then
    res.canQuit = false
    res.reason = textRes.SystemSetting[3] or "OnRoleQuit"
  end
  return res
end
def.static("table", "table").OnSettingChanged = function(params)
  local id = params[1]
  local isSilence = params.silence or false
  if CSSettingMap[id] then
    instance:SendSystemSettingReq(id)
  else
    local settingData = instance:GetSetting(id)
    if settingData.type == SettingDataType.Toggle then
      if settingData.isEnabled then
        SystemSettingUIMgr.ShowSetSuccessMessage()
      elseif not isSilence then
        SystemSettingUIMgr.ShowUnsetSuccessMessage()
      end
    elseif settingData.type == SettingDataType.Sound then
      if not settingData.mute and not isSilence then
        SystemSettingUIMgr.ShowSetSuccessMessage()
      elseif not isSilence then
        SystemSettingUIMgr.ShowUnsetSuccessMessage()
      end
    elseif settingData.type == SettingDataType.Num and not isSilence then
      SystemSettingUIMgr.ShowSetSuccessMessage()
    end
  end
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  local self = SystemSettingModule.Instance()
  self.m_confirmSettingReqCallback = nil
end
def.method("number").SendSystemSettingReq = function(self, id)
  local sstid = CSSettingMap[id]
  if sstid == nil then
    warn("SendSystemSettingReq missing sstid", id)
    return
  end
  local setting = self:GetSetting(id)
  local type = sstid
  local value
  if setting.type == SettingDataType.Num then
    value = setting.num
  else
    value = setting.isEnabled and SystemSettingBean.STATE_SETTING or SystemSettingBean.STATE_NOT_SETTING
  end
  self:C2S_SystemSettingReq(type, value)
end
def.method("number", "number").C2S_SystemSettingReq = function(self, settingType, settingValue)
  local p = require("netio.protocol.mzm.gsp.systemsetting.CSystemSettingReq").new(settingType, settingValue)
  gmodule.network.sendProtocol(p)
end
def.method("number", "number").C2S_SetCustomConfirmInfoReq = function(self, type, agree)
  local set = {
    [type] = agree
  }
  local p = require("netio.protocol.mzm.gsp.confirm.CSetCustomConfirmInfoReq").new(set)
  gmodule.network.sendProtocol(p)
end
def.method().C2S_GetCustomConfirmInfoReq = function(self)
  local p = require("netio.protocol.mzm.gsp.confirm.CGetCustomConfirmInfoReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSSyncSystemSetting = function(p)
  for type, value in pairs(p.settingMap) do
    instance:SyncSystemSetting(type, value)
  end
end
def.method("number", "number").SyncSystemSetting = function(self, type, value)
  for id, sstid in pairs(CSSettingMap) do
    if type == sstid then
      local setting = self:GetSetting(id)
      if setting.type == SettingDataType.Num then
        setting.num = value
      else
        setting.isEnabled = value == SystemSettingBean.STATE_SETTING
      end
    end
  end
end
def.static("table").OnSSystemSettingRes = function(p)
  local type, value = p.settingType, p.settingValue
  instance:SyncSystemSetting(type, value)
  if value >= SystemSettingBean.STATE_SETTING then
    SystemSettingUIMgr.ShowSetSuccessMessage()
  else
    SystemSettingUIMgr.ShowUnsetSuccessMessage()
  end
end
def.method("function").ReqConfirmSetting = function(self, callback)
  self:C2S_GetCustomConfirmInfoReq()
  self.m_confirmSettingReqCallback = callback
end
def.static("table").OnSGetCustomConfirmInfoRep = function(p)
  local self = SystemSettingModule.Instance()
  if self.m_confirmSettingReqCallback then
    self.m_confirmSettingReqCallback(p.confirmInfos)
    self.m_confirmSettingReqCallback = nil
  end
end
def.static("=>", "table").GetConfirmSettingCfg = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_TEAM_CONFIRM)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local list = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local canSet = entry:GetCharValue("canSet") ~= 0
    if canSet then
      local cfg = {}
      cfg.type = entry:GetIntValue("confirmType")
      cfg.defaultRefuse = entry:GetCharValue("defaultRefuse") ~= 0
      cfg.desc = entry:GetStringValue("desc")
      cfg.sortId = entry:GetIntValue("sortId")
      table.insert(list, cfg)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(list, function(a, b)
    return a.sortId < b.sortId
  end)
  return list
end
SystemSettingModule.Commit()
return SystemSettingModule
