local Lplus = require("Lplus")
local UpdateNoticeMgr = require("Main.UpdateNotice.UpdateNoticeMgr")
local ECDefaultNoticeMgr = Lplus.Extend(UpdateNoticeMgr, "ECDefaultNoticeMgr")
local UpdateNoticeModule = Lplus.ForwardDeclare("UpdateNoticeModule")
local NoticeData = require("Main.UpdateNotice.NoticeData")
local def = ECDefaultNoticeMgr.define
local NoticeSceneType = UpdateNoticeModule.NoticeSceneType
local DirVersionXMLHelper = require("Common.DirVersionXMLHelper")
local CONNECT_TIMEOUT_SEC = 15
def.const("string").LOGIN_ALERT_NOTICE_FILENAME = "login_announcement.xml"
local instance
def.final("=>", ECDefaultNoticeMgr).Instance = function()
  if instance == nil then
    instance = ECDefaultNoticeMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.override("number", "function").FetchNotice = function(self, sceneType, callback)
  if _G.IsEfunVersion() then
    _G.SafeCallback(callback)
    return
  end
  if sceneType == NoticeSceneType.LoginAlert then
    self:FetchLoginAlertNotice(callback)
  else
    _G.SafeCallback(callback)
  end
end
def.method("function").FetchLoginAlertNotice = function(self, callback)
  local noticeUrl = self:GetNoticeUrl()
  if noticeUrl == "" then
    _G.SafeCallback(callback)
    return
  end
  local isTimeout = false
  local isFinish = false
  GameUtil.AddGlobalTimer(CONNECT_TIMEOUT_SEC, true, function(...)
    if isFinish then
      return
    end
    print(string.format("FetchLoginAlertNotice: timeout after %d seconds", CONNECT_TIMEOUT_SEC))
    isTimeout = true
    _G.SafeCallback(callback)
  end)
  local noticeSavePath = Application.temporaryCachePath .. "/" .. ECDefaultNoticeMgr.LOGIN_ALERT_NOTICE_FILENAME
  local function onDownloadCallback(state, url, path, bytes)
    if isTimeout then
      return
    end
    isFinish = true
    if state == false then
      _G.SafeCallback(callback)
      return
    end
    local notice = NoticeData()
    notice.title = textRes.UpdateNotice[3] or ""
    notice.content = bytes:get_string()
    notice.id = tostring(os.time())
    local notices = {}
    table.insert(notices, notice)
    _G.SafeCallback(callback, notices)
  end
  GameUtil.downLoadUrl(noticeUrl, noticeSavePath, onDownloadCallback)
end
def.method("=>", "string").GetNoticeUrl = function(self)
  local doc = DirVersionXMLHelper.GetXmlDoc()
  if doc == nil then
    return ""
  end
  local noticeUrl
  for i, elem in ipairs(doc.root.el) do
    if elem.name == "resource_update" then
      noticeUrl = elem.attr.announcement_address
      break
    end
  end
  if noticeUrl == nil or noticeUrl == "" then
    return ""
  end
  if not noticeUrl:find("/$") then
    noticeUrl = noticeUrl .. "/"
  end
  noticeUrl = noticeUrl .. ECDefaultNoticeMgr.LOGIN_ALERT_NOTICE_FILENAME
  return noticeUrl
end
return ECDefaultNoticeMgr.Commit()
