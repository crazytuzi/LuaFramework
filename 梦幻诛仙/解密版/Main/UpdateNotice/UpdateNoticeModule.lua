local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local ECGUIMan = require("GUI.ECGUIMan")
local UpdateNoticeModule = Lplus.Extend(ModuleBase, "UpdateNoticeModule")
local UpdateNoticeMgr = require("Main.UpdateNotice.UpdateNoticeMgr")
local NoticeMgrFactory = require("Main.UpdateNotice.NoticeMgrFactory")
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
local ECMSDK = require("ProxySDK.ECMSDK")
local EnterWorldAlertMgr = require("Main.Common.EnterWorldAlertMgr")
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
local NoticeData = require("Main.UpdateNotice.NoticeData")
local def = UpdateNoticeModule.define
local NOTICE_TIMESTAMP_KEY_NAME = "UpdateNoticeTimestamp"
local NOTICE_ID_CHAIN_KEY_NAME = "UpdateNoticeIDChain"
def.const("table").NoticeSceneType = {
  LoginAlert = 1,
  EnterWorldAlert = 2,
  EnterWorldBannerAlert = 3,
  LoginScroll = 101,
  EnterWorldScroll = 102,
  CloseServerScroll = 103
}
def.const("number").ENTER_WORLD_SCROLL_NOTICE_INTERVAL = 600
def.const("number").ENTER_WORLD_NOTICE_UPDATE_INTERVAL = 600
def.field("boolean").autoShow = true
def.field("table").notices = nil
def.field("number").timerId = 0
def.field(UpdateNoticeMgr).m_noticeMgr = nil
local instance
def.static("=>", UpdateNoticeModule).Instance = function()
  if instance == nil then
    instance = UpdateNoticeModule()
    instance.m_moduleId = ModuleId.UPDATE_NOTICE
    instance:InitNotice()
  end
  return instance
end
def.override().Init = function(self)
  require("Main.UpdateNotice.UpdateNoticeUIMgr").Instance()
  self.m_noticeMgr = NoticeMgrFactory.GetCurNoticeMgr()
  EnterWorldAlertMgr.Instance():Register(EnterWorldAlertMgr.CustomOrder.GameNotice, UpdateNoticeModule.OnEnterWorld, self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, UpdateNoticeModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_LOADING_START, UpdateNoticeModule.OnLoginLoadingStart)
end
def.method().InitNotice = function(self)
  self.notices = {}
end
def.method("number", "=>", "table").GetNotice = function(self, sceneType)
  return self.notices[sceneType] and self.notices[sceneType][1] or nil
end
def.method("number", "=>", "table").GetNotices = function(self, sceneType)
  return self.notices[sceneType]
end
def.method("number", "table").SetNotices = function(self, sceneType, notices)
  self.notices[sceneType] = notices
end
def.method("string", "function").QueryNoticeContent = function(self, noticeId, callback)
  self.m_noticeMgr:QueryNoticeContent(noticeId, callback)
end
def.method("=>", "boolean").HasRead = function(self)
  local sceneType = UpdateNoticeModule.NoticeSceneType.EnterWorldAlert
  return self:HasReadEx(sceneType)
end
def.method("number", "=>", "boolean").HasReadEx = function(self, sceneType)
  if self.notices[sceneType] == nil or #self.notices[sceneType] == 0 then
    return true
  end
  local key = self:GetNoticeStoreKey(sceneType)
  if LuaPlayerPrefs.HasAccountKey(key) then
    local lastidchain = LuaPlayerPrefs.GetAccountString(key)
    local idchain = self:CalcNoticesIDChain(self.notices[sceneType])
    if not self:HasNewNoticeID(lastidchain, idchain) then
      return true
    else
      return false
    end
  else
    return false
  end
end
def.method("string", "string", "=>", "boolean").HasNewNoticeID = function(self, oldIDChain, newIDChain)
  local oldIdList = string.split(oldIDChain, "_")
  local oldIdMap = {}
  for i, v in ipairs(oldIdList) do
    oldIdMap[v] = v
  end
  local newIdList = string.split(newIDChain, "_")
  for i, v in ipairs(newIdList) do
    if oldIdMap[v] == nil then
      return true
    end
  end
  return false
end
def.method("number").MarkAsReaded = function(self, sceneType)
  local key = self:GetNoticeStoreKey(sceneType)
  local idchain = self:CalcNoticesIDChain(self.notices[sceneType])
  LuaPlayerPrefs.SetAccountString(key, idchain)
  LuaPlayerPrefs.Save()
  if sceneType == UpdateNoticeModule.NoticeSceneType.EnterWorldAlert then
    Event.DispatchEvent(ModuleId.UPDATE_NOTICE, gmodule.notifyId.UpdateNotice.UPDATE_NOTICE_UPDATE, nil)
  end
end
def.method("number").MarkAsUnReaded = function(self, sceneType)
  local key = self:GetNoticeStoreKey(sceneType)
  LuaPlayerPrefs.Delete(key)
  LuaPlayerPrefs.Save()
  if sceneType == UpdateNoticeModule.NoticeSceneType.EnterWorldAlert then
    Event.DispatchEvent(ModuleId.UPDATE_NOTICE, gmodule.notifyId.UpdateNotice.UPDATE_NOTICE_UPDATE, nil)
  end
end
def.method("table", "=>", "string").CalcNoticesIDChain = function(self, notices)
  if notices == nil then
    return ""
  end
  local idchaint = {}
  for i, v in ipairs(notices) do
    table.insert(idchaint, v.id)
  end
  return table.concat(idchaint, ",")
end
def.method("number", "=>", "string").GetNoticeStoreKey = function(self, sceneType)
  return NOTICE_ID_CHAIN_KEY_NAME .. "_" .. tostring(sceneType)
end
def.method("number", "function").FetchNotice = function(self, sceneType, callback)
  instance.m_noticeMgr:FetchNotice(sceneType, callback)
end
def.method().PrepareEnterWorldNotice = function(self)
  if _G.use_idip_notice then
    return
  end
  local sceneType = UpdateNoticeModule.NoticeSceneType.EnterWorldAlert
  if self.notices[sceneType] then
    return
  end
  instance:FetchNotice(sceneType, function(notices)
    self.notices[sceneType] = notices
    self.notices[sceneType].autoShow = true
    if gmodule.moduleMgr:GetModule(ModuleId.LOGIN).isEnteredWorld then
      self:CheckToShowEnterWorldNotice()
    end
  end)
end
def.method().CheckToShowEnterWorldNotice = function(self)
  local sceneType = UpdateNoticeModule.NoticeSceneType.EnterWorldBannerAlert
  instance:FetchNotice(sceneType, function(notices)
    self.notices[sceneType] = notices
    if #self.notices[sceneType] > 0 then
      do
        local index = 1
        local function showNoticePanel()
          local notice = notices[index]
          if notice == nil then
            self:CheckToShowGameNotice()
            return
          end
          require("Main.UpdateNotice.ui.GameBannerNoticePanel").ShowPanel(notice, function()
            index = index + 1
            self:MarkTodayAsShowed(notice.id)
            GameUtil.AddGlobalTimer(0, true, function()
              if gmodule.moduleMgr:GetModule(ModuleId.LOGIN).isEnteredWorld then
                showNoticePanel()
              end
            end)
          end)
        end
        showNoticePanel()
      end
    else
      self:CheckToShowGameNotice()
    end
  end)
end
def.method().CheckToShowGameNotice = function(self)
  if not _G.IsEnteredWorld() then
    return
  end
  local function needShow(notices)
    for i, notice in ipairs(notices) do
      if notice.popupPeriod == NoticeData.PopupPeriod.LOGIN then
        return true
      elseif not self:HasTodayShow(notice.id) then
        return true
      end
    end
    return false
  end
  local sceneType = UpdateNoticeModule.NoticeSceneType.EnterWorldAlert
  instance:FetchNotice(sceneType, function(notices)
    self.notices[sceneType] = notices
    if self.notices[sceneType] and #self.notices[sceneType] > 0 and needShow(notices) then
      self:ShowGameNotice(self.notices[sceneType], function(...)
        EnterWorldAlertMgr.Instance():Next()
      end)
      self:MarkAsReaded(sceneType)
      instance:StartFetchNoticeTimer({immediately = false})
    else
      EnterWorldAlertMgr.Instance():Next()
      instance:StartFetchNoticeTimer({immediately = true})
    end
  end)
end
def.static("number", "function").OpenNoticePanel = function(sceneType, onClose)
  instance.m_noticeMgr:FetchNotice(sceneType, function(notices)
    instance.notices[sceneType] = notices
    if sceneType == UpdateNoticeModule.NoticeSceneType.LoginAlert then
      instance:ShowNotice(notices, onClose)
    else
      instance:ShowGameNotice(notices, onClose)
    end
    instance:MarkAsReaded(sceneType)
  end)
end
def.method("table", "function").ShowNotice = function(self, alertNotics, onClose)
  if alertNotics and alertNotics[1] then
    do
      local index = 1
      local function showNoticePanel()
        local v = alertNotics[index]
        if v == nil then
          _G.SafeCallback(onClose, true)
          return
        end
        require("Main.UpdateNotice.UpdateNoticeUIMgr").OpenNoticePanelEx(v.title, v.content, v.url, function()
          index = index + 1
          GameUtil.AddGlobalTimer(0, true, function()
            showNoticePanel()
          end)
        end)
      end
      showNoticePanel()
    end
  else
    _G.SafeCallback(onClose, false)
  end
end
def.method("table", "function").ShowGameNotice = function(self, alertNotics, onClose)
  if alertNotics == nil or #alertNotics == 0 then
    _G.SafeCallback(onClose, false)
    return
  end
  require("Main.UpdateNotice.UpdateNoticeUIMgr").OpenGameNoticePanel(alertNotics, onClose)
end
def.static("number").OpenScrollNotice = function(sceneType)
  instance.m_noticeMgr:FetchNotice(sceneType, function(notices)
    instance.notices[sceneType] = notices
    instance:ShowScrollNotice(notices)
    instance:MarkAsReaded(sceneType)
  end)
end
def.method("table").ShowScrollNotice = function(self, notices)
  if notices == nil then
    return
  end
  self:ShowScrollNoticeEx(notices, "")
end
def.method("table", "string").ShowScrollNoticeEx = function(self, notices, color)
  if notices == nil then
    return
  end
  for i, v in ipairs(notices) do
    require("GUI.ScrollNotice").Notice(string.format("[%s]%s[-]", color, v.content))
  end
end
def.method().ShowEnterWorldScrollNotice = function(self)
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local ChatModule = require("Main.Chat.ChatModule")
  local sceneType = UpdateNoticeModule.NoticeSceneType.EnterWorldScroll
  instance.m_noticeMgr:FetchNotice(sceneType, function(notices)
    if notices then
      instance.notices[sceneType] = notices
      for i = 1, 2 do
        instance:ShowScrollNoticeEx(notices, "ffff00")
      end
      local isShowInChat = true
      for i, notice in ipairs(notices) do
        local text = notice.content
        ChatModule.Instance():SendSystemMsgEx(ChatMsgData.System.SYS, HtmlHelper.Style.System, {text = text}, isShowInChat)
      end
    end
  end)
end
def.static("string", "=>", "string").HtmlToNGUIHtml = function(html)
  local nguiHtml = html
  nguiHtml = string.gsub(nguiHtml, "<(.-)>", function(...)
    local params = {
      ...
    }
    local param = params[1]
    if param:byte(1) ~= string.byte("/") then
      param = string.gsub(param, "&quot;", "\"")
      if param:sub(1, 3) == "div" then
        local attrs = {}
        local align = string.match(param, "text%-align:%s*(%a*)")
        if align == nil then
          align = string.match(param, "align=\"?(%a+)\"?") or "left"
        end
        if align then
          table.insert(attrs, string.format("align=\"%s\"", align))
        end
        return string.format("<p linespacing=6 %s>", table.concat(attrs, " "))
      elseif param:sub(1, 4) == "font" then
        local attrs = {}
        local size = tonumber(string.match(param, "size=\"?(%d+)\"?"))
        if size then
          local px = size
          if size <= 7 then
            local x = size
            local em = 0.00223611 * x ^ 6 - 0.0530417 * x ^ 5 + 0.496319 * x ^ 4 - 2.30479 * x ^ 3 + 5.51644 * x ^ 2 - 6.16717 * x + 3.14
            px = math.floor(em * 16 + 0.5) + 8
          end
          table.insert(attrs, string.format("size=\"%d\"", px))
        end
        local color = string.match(param, "color=\"?([%#%a%d]+)\"?")
        if color then
          table.insert(attrs, string.format("color=\"%s\"", color))
        end
        return string.format("<font %s>", table.concat(attrs, " "))
      else
        return "<" .. param .. ">"
      end
    elseif param:sub(1, 4) == "/div" then
      return "</p>"
    else
      return "<" .. param .. ">"
    end
  end)
  nguiHtml = string.format("<font size=18>%s</font>", nguiHtml)
  return nguiHtml
end
def.method("table").StartFetchNoticeTimer = function(self, params)
  if _G.use_idip_notice then
    return
  end
  local function fetch()
    local sceneType = UpdateNoticeModule.NoticeSceneType.EnterWorldAlert
    instance:FetchNotice(sceneType, function(notices)
      local idchain = self:CalcNoticesIDChain(self.notices[sceneType])
      local newidchain = self:CalcNoticesIDChain(notices)
      self.notices[sceneType] = notices
      if self:HasNewNoticeID(idchain, newidchain) then
        Event.DispatchEvent(ModuleId.UPDATE_NOTICE, gmodule.notifyId.UpdateNotice.UPDATE_NOTICE_UPDATE, nil)
      end
    end)
  end
  if params.immediately then
    fetch()
  end
  if self.timerId ~= 0 then
    return
  end
  self.timerId = GameUtil.AddGlobalTimer(UpdateNoticeModule.ENTER_WORLD_NOTICE_UPDATE_INTERVAL, false, function(...)
    fetch()
  end)
end
def.method().StopFetchNoticeTimer = function(self)
  if self.timerId ~= 0 then
    GameUtil.RemoveGlobalTimer(self.timerId)
    self.timerId = 0
  end
end
def.method().Clear = function(self)
  self.autoShow = true
  self.notices = {}
  self:StopFetchNoticeTimer()
end
def.static("table").OnSSyncNotice = function(p)
  instance.notice.title = p.title
  instance.notice.content = p.content
  instance.notice.timestamp = p.timestamp
  Event.DispatchEvent(ModuleId.UPDATE_NOTICE, gmodule.notifyId.UpdateNotice.UPDATE_NOTICE_UPDATE, nil)
end
def.static("table", "table").OnLoginLoadingStart = function(params)
  instance:PrepareEnterWorldNotice()
end
local scrollStartTimer = 0
def.method().OnEnterWorld = function(self)
  instance:CheckToShowEnterWorldNotice()
  local function ShowScrollNotice()
    scrollStartTimer = GameUtil.AddGlobalTimer(3, true, function(...)
      scrollStartTimer = 0
      if not _G.CGPlay then
        instance:ShowEnterWorldScrollNotice()
        scrollStartTimer = GameUtil.AddGlobalTimer(UpdateNoticeModule.ENTER_WORLD_SCROLL_NOTICE_INTERVAL, true, function()
          scrollStartTimer = 0
          ShowScrollNotice()
        end)
      else
        return ShowScrollNotice()
      end
    end)
  end
  ShowScrollNotice()
end
def.static("table", "table").OnLeaveWorld = function(params)
  local reason = params and params.reason or 0
  if reason ~= _G.LeaveWorldReason.RECONNECT and reason ~= _G.LeaveWorldReason.CHANGE_ROLE then
    instance.notices = {}
  end
  if reason ~= _G.LeaveWorldReason.RECONNECT then
    if scrollStartTimer ~= 0 then
      GameUtil.RemoveGlobalTimer(scrollStartTimer)
      scrollStartTimer = 0
    end
    instance:StopFetchNoticeTimer()
  end
end
def.method("=>", "number").GetDateKey = function(self)
  local serverTime = _G.GetServerTime()
  local key = tonumber(os.date("%Y%m%d", serverTime))
  return key
end
local keyPrefix = "NOTICE_DAILY_FIRST_TIME_"
def.method("string", "=>", "boolean").HasNoticeShow = function(self, noticeId)
  local key = keyPrefix .. noticeId
  if LuaPlayerPrefs.HasRoleKey(key) then
    return true
  end
  return false
end
def.method("string", "=>", "boolean").HasTodayShow = function(self, noticeId)
  local key = keyPrefix .. noticeId
  if LuaPlayerPrefs.HasRoleKey(key) then
    local dateKey = LuaPlayerPrefs.GetRoleNumber(key)
    local todayKey = self:GetDateKey()
    return dateKey == todayKey
  end
  return false
end
def.method("string").MarkTodayAsShowed = function(self, noticeId)
  local key = keyPrefix .. noticeId
  local todayKey = self:GetDateKey()
  LuaPlayerPrefs.SetRoleNumber(key, todayKey)
  LuaPlayerPrefs.Save()
end
def.method("table").OperateNoticeUrl = function(self, notice)
  local url = notice.url
  if notice.hrefType == NoticeData.LinkType.URL then
    self:OpenUrl(url)
  elseif notice.hrefType == NoticeData.LinkType.JUMP then
    url = url:trim()
    local params = url:split(" ")
    local processedParams = {}
    for i, v in ipairs(params) do
      local pv = v:trim()
      if pv ~= "" then
        table.insert(processedParams, pv)
      end
    end
    local operationId = tonumber(processedParams[1])
    if operationId then
      table.remove(processedParams, 1)
      self:ApplyClientOperation(operationId, processedParams)
    else
      warn(string.format("[error] url:%s{encodedUrl:%s} must has a operationId!", url, url:urlencode()))
    end
  else
    warn(string.format("OperateNoticeUrl: not supported hrefType(%d)", notice.hrefType))
  end
end
def.method("string").OpenUrl = function(self, url)
  require("Main.ECGame").Instance():OpenUrl(url)
end
def.method("number", "table").ApplyClientOperation = function(self, operationId, params)
  require("Main.Grow.GrowUtils").ApplyOperationWithParams(operationId, params)
end
return UpdateNoticeModule.Commit()
