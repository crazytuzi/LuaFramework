local Lplus = require("Lplus")
local UpdateNoticeMgr = require("Main.UpdateNotice.UpdateNoticeMgr")
local ECMSDKNoticeMgr = Lplus.Extend(UpdateNoticeMgr, "ECMSDKNoticeMgr")
local UpdateNoticeModule = Lplus.ForwardDeclare("UpdateNoticeModule")
local ECMSDK = require("ProxySDK.ECMSDK")
local NoticeData = require("Main.UpdateNotice.NoticeData")
local def = ECMSDKNoticeMgr.define
local instance
def.final("=>", ECMSDKNoticeMgr).Instance = function()
  if instance == nil then
    instance = ECMSDKNoticeMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.override("number", "function").FetchNotice = function(self, sceneType, callback)
  local scene = ""
  if sceneType == UpdateNoticeModule.NoticeSceneType.LoginAlert then
    scene = ECMSDK.BEFOR_LOGIN_ALERT_SCENE
  elseif sceneType == UpdateNoticeModule.NoticeSceneType.EnterWorldAlert then
    scene = ECMSDK.LOGIN_ALERT_SCENE
  elseif sceneType == UpdateNoticeModule.NoticeSceneType.LoginScroll then
    scene = ECMSDK.BEFOR_LOGIN_SCROLL_SCENE
  elseif sceneType == UpdateNoticeModule.NoticeSceneType.EnterWorldScroll then
    scene = ECMSDK.LOGIN_SCROLL_SCENE
  else
    warn("OpenNoticePanel failed (no such sceneType: " .. sceneType .. ")")
    _G.SafeCallback(callback)
  end
  local notEvaluation = not GameUtil.IsEvaluation()
  if scene ~= "" and notEvaluation then
    self:_FetchNotice(scene, callback)
  else
    _G.SafeCallback(callback, {})
  end
end
def.method("string", "function")._FetchNotice = function(self, scene, callback)
  ECMSDK.FetchNoticeInfo(scene, function(scene, info)
    self:OnNoticeInfo(info, callback)
  end)
end
def.method("table", "function").OnNoticeInfo = function(self, info, callback)
  local notices = {}
  for i, v in ipairs(info) do
    local notice = NoticeData()
    notice.id = v.msg_id
    notice.title = v.msg_title
    notice.content = v.msg_content
    notice.url = v.msg_url
    notice.picArray = {}
    for i, v in ipairs(v.picArray) do
      local picInfo = {}
      picInfo.path = v.picPath
      table.insert(notice.picArray, picInfo)
    end
    table.insert(notices, notice)
  end
  _G.SafeCallback(callback, notices)
end
return ECMSDKNoticeMgr.Commit()
