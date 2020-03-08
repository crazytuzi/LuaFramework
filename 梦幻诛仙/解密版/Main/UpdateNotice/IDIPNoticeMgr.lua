local Lplus = require("Lplus")
local UpdateNoticeMgr = require("Main.UpdateNotice.UpdateNoticeMgr")
local IDIPNoticeMgr = Lplus.Extend(UpdateNoticeMgr, "IDIPNoticeMgr")
local UpdateNoticeModule = Lplus.ForwardDeclare("UpdateNoticeModule")
local NoticeData = require("Main.UpdateNotice.NoticeData")
local NoticeSceneType = UpdateNoticeModule.NoticeSceneType
local def = IDIPNoticeMgr.define
local NoticeType = NoticeData.NoticeType
local PopupPeriod = NoticeData.PopupPeriod
local LinkType = NoticeData.LinkType
local TagType = NoticeData.TagType
def.field("table").m_notices = nil
def.field("table").m_preloadNotices = nil
local log = function(...)
  return print(...)
end
local instance
def.final("=>", IDIPNoticeMgr).Instance = function()
  if instance == nil then
    instance = IDIPNoticeMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.idip.SSyncNotices", IDIPNoticeMgr.OnSSyncNotices)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.idip.SSyncNoticeContent", IDIPNoticeMgr.OnSSyncNoticeContent)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.idip.SSyncNotice", IDIPNoticeMgr.OnSSyncNotice)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.idip.SSyncDelNotice", IDIPNoticeMgr.OnSSyncDelNotice)
end
def.override("number", "function").FetchNotice = function(self, sceneType, callback)
  if sceneType == NoticeSceneType.LoginAlert or sceneType == NoticeSceneType.LoginScroll or sceneType == NoticeSceneType.EnterWorldScroll then
    if ClientCfg.GetSDKType() == ClientCfg.SDKTYPE.MSDK then
      require("Main.UpdateNotice.ECMSDKNoticeMgr").Instance():FetchNotice(sceneType, callback)
    else
      require("Main.UpdateNotice.ECDefaultNoticeMgr").Instance():FetchNotice(sceneType, callback)
    end
  else
    self:_FetchNotice(sceneType, callback)
  end
end
def.method("number", "function")._FetchNotice = function(self, sceneType, callback)
  local noticeList = {}
  local notices = self.m_notices or {}
  for k, v in pairs(notices) do
    if self:CanShow(v) then
      if sceneType == NoticeSceneType.EnterWorldBannerAlert then
        if v.type == NoticeType.SINGLE_UI_BANNER then
          table.insert(noticeList, v)
        end
      elseif v.type ~= NoticeType.SINGLE_UI_BANNER then
        table.insert(noticeList, v)
      end
    end
  end
  table.sort(noticeList, function(l, r)
    if l.sortId ~= r.sortId then
      return l.sortId < r.sortId
    else
      return l.startTime > r.startTime
    end
  end)
  _G.SafeCallback(callback, noticeList)
end
def.method("table", "=>", "boolean").CanShow = function(self, notice)
  if notice == nil then
    return false
  end
  local IsInValid = function(minVal, maxVal, curVal, initVal)
    if initVal and minVal == initVal and maxVal == initVal then
      return false
    end
    if curVal < minVal or maxVal < curVal then
      return true
    end
    return false
  end
  if notice.type == NoticeType.SINGLE_UI_BANNER and notice.popupPeriod == PopupPeriod.DAILY_FIRST_LOGIN and UpdateNoticeModule.Instance():HasTodayShow(notice.id) then
    log(string.format("Ignore notice[%s], today has show.", notice.id))
    return false
  end
  local curTime = Int64.new(_G.GetServerTime())
  if notice.endTime ~= Int64.new(0) and IsInValid(notice.startTime, notice.endTime, curTime, Int64.new(0)) then
    log(string.format("Ignore notice[%s], not in valid period, startTime=%s, endTime=%s, curTime=%s.", notice.id, notice.startTime:tostring(), notice.endTime:tostring(), curTime:tostring()))
    return false
  end
  local displayConds = notice.displayConds
  if displayConds then
    local severOpenedDays = require("Main.Server.ServerModule").Instance():GetServerOpenDays()
    if IsInValid(displayConds.minOpenServerDays, displayConds.maxOpenServerDays, severOpenedDays, 0) then
      log(string.format("Ignore notice[%s], not in valid server open days, minOpenServerDays=%s, maxOpenServerDays=%s, severOpenedDays=%s.", notice.id, displayConds.minOpenServerDays, displayConds.maxOpenServerDays, severOpenedDays))
      return false
    end
    local heroProp = _G.GetHeroProp()
    if heroProp == nil then
      warn("Attempt to fetch notice, but heroProp is nil!")
      return false
    end
    local roleCreateDuration = Int64.ToNumber(curTime - heroProp.createTime)
    local roleCreateDays = math.ceil(roleCreateDuration / 86400)
    if IsInValid(displayConds.minCreatRoleDays, displayConds.maxCreatRoleDays, roleCreateDays, 0) then
      log(string.format("Ignore notice[%s], not in valid role create days, minCreatRoleDays=%s, maxCreatRoleDays=%s, roleCreateDays=%s.", notice.id, displayConds.minCreatRoleDays, displayConds.maxCreatRoleDays, roleCreateDays))
      return false
    end
    local roleLevel = heroProp.level
    if IsInValid(displayConds.minRoleLevel, displayConds.maxRoleLevel, roleLevel, 0) then
      log(string.format("Ignore notice[%s], not in valid role level, minRoleLevel=%s, maxRoleLevel=%s, roleLevel=%s.", notice.id, displayConds.minRoleLevel, displayConds.maxRoleLevel, roleLevel))
      return false
    end
    local ItemModule = require("Main.Item.ItemModule")
    local saveAmt = ItemModule.Instance():GetYuanbao(ItemModule.CASH_SAVE_AMT)
    if IsInValid(displayConds.minSaveAmt, displayConds.maxSaveAmt, saveAmt, Int64.new(0)) then
      log(string.format("Ignore notice[%s], not in valid saveAmt, minSaveAmt=%s, maxSaveAmt=%s, saveAmt=%s.", notice.id, displayConds.minSaveAmt:tostring(), displayConds.maxSaveAmt:tostring(), saveAmt:tostring()))
      return false
    end
  end
  return true
end
def.method("table").PreloadNoticeContentOrPic = function(self, noticeList)
  if #noticeList == 0 then
    return
  end
  local loadContentCount = 0
  for i, notice in ipairs(noticeList) do
    if notice.type == NoticeType.NORMAL then
      loadContentCount = loadContentCount + 1
    end
  end
  require("Main.Login.LoginPreloadMgr").Instance():IncProtocolCount(loadContentCount)
  local onGetNoticeContent = function()
    require("Main.Login.LoginPreloadMgr").Instance():IncProtocolFinishCount(1)
  end
  for i, notice in ipairs(noticeList) do
    local noticeId = notice.id
    if notice.type == NoticeType.NORMAL then
      self:QueryNoticeContent(noticeId, onGetNoticeContent)
    elseif #notice.pictureUrl > 3 then
      print("Pre download picture url", notice.pictureUrl)
      _G.DownLoadDataFromURL(notice.pictureUrl, nil)
    end
  end
end
local _noticeReqMap = {}
def.method("string", "function").QueryNoticeContent = function(self, noticeId, callback)
  local req = {noticeId = noticeId, callback = callback}
  local key = tostring(req.noticeId)
  if _noticeReqMap[key] == nil then
    _noticeReqMap[key] = {req}
    noticeId = Int64.ParseString(noticeId)
    local p = require("netio.protocol.mzm.gsp.idip.CQueryNoticeContent").new(noticeId)
    gmodule.network.sendProtocol(p)
  else
    table.insert(_noticeReqMap[key], req)
  end
end
def.method("table", "=>", "table").ConvertToNoticeData = function(self, noticeBean)
  local v = noticeBean
  local notice = NoticeData()
  notice.id = tostring(v.noticeId)
  notice.type = v.noticeType
  notice.title = _G.GetStringFromOcts(v.noticeTitle)
  notice.popupPeriod = v.displayType or 2
  notice.sortId = v.noticeSortID
  notice.content = v.content or ""
  notice.pictureUrl = _G.GetStringFromOcts(v.pictureUrl) or ""
  notice.url = _G.GetStringFromOcts(v.hrefUrl) or ""
  notice.hrefType = v.hrefType or 1
  notice.hrefText = _G.GetStringFromOcts(v.hrefText) or ""
  notice.sendType = v.sendType or 1
  notice.tag = v.noticeTag or 1
  notice.badge = v.badge == 1 and true or false
  notice.startTime = v.startTime or Int64.new(0)
  notice.endTime = v.endTime or Int64.new(0)
  v.minOpenServerDays = v.minOpenServerDays or 0
  v.maxOpenServerDays = v.maxOpenServerDays or 0
  v.minCreatRoleDays = v.minCreatRoleDays or 0
  v.maxCreatRoleDays = v.maxCreatRoleDays or 0
  v.minRoleLevel = v.minRoleLevel or 0
  v.maxRoleLevel = v.maxRoleLevel or 0
  v.minSaveAmt = v.minSaveAmt or Int64.new(0)
  v.maxSaveAmt = v.maxSaveAmt or Int64.new(0)
  notice.displayConds = v
  notice.pictureUrl = _G.NormalizeHttpURL(notice.pictureUrl)
  if notice.hrefType == LinkType.URL then
    notice.url = _G.NormalizeHttpURL(notice.url)
    notice.url = _G.AttachGameData2URL(notice.url)
  end
  return notice
end
def.static("table").OnSSyncNotices = function(p)
  warn("OnSSyncNotices #p.notices", #p.notices)
  instance.m_notices = {}
  local preloadNoticeList = {}
  local sortableNoticeList = {}
  for i, v in ipairs(p.notices) do
    local notice = instance:ConvertToNoticeData(v)
    if v.noticeType == NoticeType.UNIQUE_BANNER or v.noticeType == NoticeType.NORMAL then
      table.insert(sortableNoticeList, notice)
    else
      table.insert(preloadNoticeList, notice)
    end
    instance.m_notices[notice.id] = notice
  end
  table.sort(sortableNoticeList, function(l, r)
    return l.sortId < r.sortId
  end)
  local _, firstSortNotice = next(sortableNoticeList)
  if firstSortNotice then
    table.insert(preloadNoticeList, firstSortNotice)
  end
  instance:PreloadNoticeContentOrPic(preloadNoticeList)
  Event.DispatchEvent(ModuleId.UPDATE_NOTICE, gmodule.notifyId.UpdateNotice.UPDATE_NOTICE_UPDATE, nil)
end
def.static("table").OnSSyncNoticeContent = function(p)
  local noticeInfo = instance.m_notices[tostring(p.noticeId)]
  if noticeInfo == nil then
    warn(string.format("OnSSyncNoticeContent noticeId=%s not found!", tostring(p.noticeId)))
    return
  end
  noticeInfo.content = _G.GetStringFromOcts(p.noticeContent)
  if noticeInfo.content == "" then
    noticeInfo.content = " "
  end
  local key = tostring(p.noticeId)
  if _noticeReqMap[key] then
    for i, v in ipairs(_noticeReqMap[key]) do
      if v.callback then
        v.callback(v.noticeId, noticeInfo)
      end
    end
    _noticeReqMap[key] = nil
  end
end
def.static("table").OnSSyncNotice = function(p)
  local noticeId = p.notice.noticeId
  print("OnSSyncNotice p.notice.noticeId", tostring(noticeId))
  local notice = instance:ConvertToNoticeData(p.notice)
  instance.m_notices[tostring(noticeId)] = notice
  instance:_FetchNotice(NoticeSceneType.EnterWorldAlert, function(notices)
    UpdateNoticeModule.Instance():SetNotices(NoticeSceneType.EnterWorldAlert, notices)
  end)
  Event.DispatchEvent(ModuleId.UPDATE_NOTICE, gmodule.notifyId.UpdateNotice.UPDATE_NOTICE_UPDATE, nil)
end
def.static("table").OnSSyncDelNotice = function(p)
  local noticeId = tostring(p.noticeId)
  print("OnSSyncDelNotice p.noticeId", tostring(noticeId))
  instance.m_notices[tostring(noticeId)] = nil
  Event.DispatchEvent(ModuleId.UPDATE_NOTICE, gmodule.notifyId.UpdateNotice.UPDATE_NOTICE_UPDATE, nil)
end
return IDIPNoticeMgr.Commit()
