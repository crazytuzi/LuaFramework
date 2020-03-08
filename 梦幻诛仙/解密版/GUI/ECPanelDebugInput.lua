local Lplus = require("Lplus")
local EC = require("Types.Vector3")
local ECPanelBase = require("GUI.ECPanelBase")
local ECGame = require("Main.ECGame")
local UnityLogEvent = require("Event.SystemEvents").UnityLogEvent
local LogType = UnityLogEvent.LogType
local ECPanelDebugInput = Lplus.Extend(ECPanelBase, "ECPanelDebugInput")
local def = ECPanelDebugInput.define
def.field("table").history = nil
def.field("number").historyCursor = 1
def.field("userdata").textControl = nil
def.field("number").errorCount = 0
local m_Instance
def.static("=>", ECPanelDebugInput).Instance = function()
  if m_Instance == nil then
    m_Instance = ECPanelDebugInput()
    m_Instance:Init()
  end
  return m_Instance
end
def.method().Init = function(self)
  self.history = {}
  self.historyCursor = 1
  self.m_depthLayer = GUIDEPTH.DEBUG
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gm.SUserIsGM", ECPanelDebugInput.OnSUserIsGM)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gm.SGMMessageTipRes", ECPanelDebugInput.SGMMessageTipRes)
end
def.static("table").OnSUserIsGM = function(p)
  _G.IsGmOn = true
  Toast("GM\230\140\135\228\187\164\229\183\178\229\188\128\229\144\175")
end
def.static("table").SGMMessageTipRes = function(p)
  if p.result == p.ACTIVITY_ALREADY_IN_STAGE_0 then
    local str = "\230\180\187\229\138\168\229\188\128\229\144\175\229\183\178\231\187\143\229\164\132\228\186\1420\233\152\182\230\174\181\228\186\134\239\188\140\229\188\128\229\144\175\231\154\132\233\152\182\230\174\181\228\184\141\229\144\136\231\144\134"
    Toast(str)
    warn("SGMMessageTipRes:", str)
  elseif p.result == p.ACTIVITY_NOT_FINISH then
    local arg1 = p.args[1]
    if arg1 then
      local str = string.format("\230\180\187\229\138\168\232\191\152\230\178\161\230\156\137\230\137\167\232\161\140\231\187\147\230\157\159\239\188\140\228\184\141\232\131\189\229\188\128\229\167\139\229\133\182\228\187\150\233\152\182\230\174\181,\229\189\147\229\137\141\233\152\182\230\174\181%1$s", arg1)
      Toast(str)
      warn("SGMMessageTipRes:", str)
    end
  elseif p.result == p.ACTIVITY_STAGE_NOT_ALLOW then
    local arg1 = p.args[1]
    if arg1 then
      local str = string.format("Gm\230\140\135\228\187\164\228\184\141\229\133\129\232\174\184\232\183\179\232\183\131\233\152\182\230\174\181\230\137\167\232\161\140,\229\189\147\229\137\141\233\152\182\230\174\181\239\188\154%1$s", arg1)
      Toast(str)
      warn("SGMMessageTipRes:", str)
    end
  elseif p.result == p.CMD_MULTI_AWARD_ITEM_PARAM_WRONG then
    local str = "multiRole_awrd\228\188\160\233\128\146\231\154\132\229\143\130\230\149\176\230\156\137\233\148\153\232\175\175"
    Toast(str)
    warn("SGMMessageTipRes:", str)
  elseif p.result == p.ACTIVITY_ID_ERROR then
    local str = "\228\184\141\230\152\175\232\175\165\230\180\187\229\138\168\231\154\132\230\140\135\228\187\164"
    Toast(str)
    warn("SGMMessageTipRes:", str)
  elseif p.result == p.ONLINE_NUM then
    local arg1 = p.args[1]
    if arg1 then
      local str = string.format("\229\189\147\229\137\141\229\156\168\231\186\191\228\186\186\230\149\176\239\188\154%1$s", arg1)
      Toast(str)
      warn("SGMMessageTipRes:", str)
    end
  elseif p.result == p.CMD_COMMON_TIPS then
    local arg1 = p.args[1]
    if arg1 then
      local str = string.format("\233\128\154\231\148\168\230\143\144\231\164\186\239\188\154%1$s", arg1)
      Toast(str)
      warn("SGMMessageTipRes:", str)
    end
  end
end
local OnUnityLog
def.override().OnCreate = function(self)
  self:CheckOldLogError()
  self:RefreshErrNumber()
  function OnUnityLog(sender, arg)
    self:onUnityLog(arg.logType, arg.str)
  end
  ECGame.EventManager:addHandler(UnityLogEvent, OnUnityLog)
  self.textControl = self.m_panel:FindDirect("testinput"):GetComponent("UIInput")
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gm.CGMCommand").new("gm on"))
end
def.override().OnDestroy = function(self)
  ECGame.EventManager:removeHandler(UnityLogEvent, OnUnityLog)
end
def.method().ToggleShow = function(self)
  if self.m_panel then
    if self.m_panel.activeSelf then
      self:Show(false)
    else
      self:Show(true)
    end
  else
    local prefab = RESPATH.DebugInput
    self:CreatePanel(prefab, -1)
  end
end
local poperr = false
def.method("number").Popup = function(self, errorCount)
  self.errorCount = errorCount
  if self.m_panel == nil then
    if ECGame.Instance().m_bCreateConsole then
      local prefab = RESPATH.DebugInput
      self:CreatePanel(prefab, -1)
    end
  elseif self.m_panel.activeSelf then
    self:RefreshErrNumber()
  elseif ECGame.Instance().m_bCreateConsole then
    self:Show(true)
    self:RefreshErrNumber()
  end
end
def.method("string", "userdata").onSubmit = function(self, id, textControl)
  local text = textControl.value
  if text == "" then
    textControl.selected = false
    return
  end
  textControl.value = ""
  local count = #self.history
  self.history[count + 1] = text
  self.historyCursor = #self.history + 1
  self:SyncCmd()
  DebugString(text)
end
def.method("number").moveHistoryCursor = function(self, amount)
  if not self.textControl or self.textControl.isnil then
    return
  end
  local historyCursor = self.historyCursor + amount
  if historyCursor < 1 then
    historyCursor = 1
  end
  if historyCursor > #self.history then
    if amount >= 0 then
      historyCursor = #self.history + 1
    else
      historyCursor = #self.history
    end
  end
  local text = self.history[historyCursor] or ""
  self.textControl.value = self.history[historyCursor]
  self.historyCursor = historyCursor
end
def.method().SyncCmd = function(self)
  local limit = 8
  local cmdList = {}
  local hisCount = #self.history
  for i = 1, limit do
    local cmd = self.history[hisCount - i + 1]
    if cmd ~= nil then
      table.insert(cmdList, cmd)
    else
      break
    end
  end
  local popList = self.m_panel:FindDirect("testinput/cmd_list"):GetComponent("UIPopupList")
  if popList then
    popList:set_items(cmdList)
  end
end
def.method("string", "number").onKey = function(self, id, key)
  if key == KeyCode.UpArrow then
    self:moveHistoryCursor(-1)
  elseif key == KeyCode.DownArrow then
    self:moveHistoryCursor(1)
  end
end
def.method("string").onClick = function(self, id)
  if id == "clear_log" then
    ECGame.Instance():ClearUnityLogs()
    self.errorCount = 0
    self:refreshLog(true)
    self:RefreshErrNumber()
  elseif id == "prev_input" then
    self:moveHistoryCursor(-1)
  elseif id == "next_input" then
    self:moveHistoryCursor(1)
  elseif id == "close_log" then
    local toggle = self.m_panel:FindDirect("showlog")
    local log = self.m_panel:FindDirect("log")
    log:SetActive(false)
    toggle:GetComponent("UIToggle"):set_isChecked(false)
  end
end
def.method("string", "boolean").onToggle = function(self, id, active)
  if id == "showlog" then
    if active then
      self:refreshLog(true)
    end
  elseif id == "prof" then
  end
end
def.method("string", "string", "number").onSelect = function(self, id, selected, index)
  if id == "cmd_list" then
    DebugString(selected)
  end
end
local function makeColorLogText(logType, str)
  local str = str:gsub("%\\", "\\\\")
  local str = str:gsub("\t", "  ")
  if logType == LogType.Log then
    return str
  elseif logType == LogType.Warning then
    return "[ffff00]" .. str .. "[-]"
  else
    return "[ff0000]" .. str .. "[-]"
  end
end
local function isCriticalLog(logType, str)
  do return false end
  if ECGame.Instance().m_bCreateConsole then
    return logType ~= LogType.Log and logType ~= LogType.Warning
  end
  return false
end
local function isError(logType)
  return logType ~= LogType.Log and logType ~= LogType.Warning
end
def.method().CheckOldLogError = function(self)
  local allLogs = ECGame.Instance():GetUnityLogs()
  for i = 1, #allLogs, 2 do
    local logType, str = allLogs[i], allLogs[i + 1]
    if isCriticalLog(logType, str) then
      self.m_panel:FindDirect("showlog"):GetComponent("UIToggle").value = true
      self:refreshLog(true)
    end
  end
end
def.method("number", "string").onUnityLog = function(self, logType, str)
  local log = self.m_panel:FindDirect("log")
  if log.activeSelf then
    self:refreshLog(false)
  end
end
def.method("boolean").refreshLog = function(self, bRebuild)
  GameUtil.SetDeadLockDetectActive(false)
  local log = self.m_panel:FindDirect("log")
  local allLogs = ECGame.Instance():GetUnityLogs()
  local text_list = log:FindDirect("text_list"):GetComponent("UITextList")
  if bRebuild then
    text_list:Clear()
    for i = 1, #allLogs, 2 do
      local logType, str = allLogs[i], allLogs[i + 1]
      text_list:Add(makeColorLogText(logType, str))
    end
  else
    local logType, str = allLogs[#allLogs - 1], allLogs[#allLogs]
    if logType and str then
      text_list:Add(makeColorLogText(logType, str))
    end
  end
  if log:FindDirect("auto_scroll"):GetComponent("UIToggle").value then
    log:FindDirect("log_scrollbar"):GetComponent("UIScrollBar").value = 1
  end
  local gameinfogo = log:FindDirect("info_label")
  if gameinfogo then
    local gameinfolabel = gameinfogo:GetComponent("UILabel")
    gameinfolabel:set_text(ECGame.Instance():GetGameInfo())
    GameUtil.SetDeadLockDetectActive(true)
  end
end
def.method().RefreshErrNumber = function(self)
  if self.errorCount > 0 then
    local err = self.m_panel:FindDirect("Error")
    err:SetActive(true)
    err:FindDirect("ErrorNumber"):GetComponent("UILabel"):set_text(string.format("%d", self.errorCount))
  else
    local err = self.m_panel:FindDirect("Error")
    err:SetActive(false)
  end
end
def.override("=>", "boolean").IsDebugUI = function(self)
  return true
end
ECPanelDebugInput.Commit()
return ECPanelDebugInput
