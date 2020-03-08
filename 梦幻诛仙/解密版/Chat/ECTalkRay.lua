local Lplus = require("Lplus")
local ECGame = Lplus.ForwardDeclare("ECGame")
local talkray = ZLFtp
local ECTalkRay = Lplus.Class("ECTalkRay")
local s_inst
local def = ECTalkRay.define
def.field("userdata").mEngine = nil
def.field("boolean").mbInit = false
def.field("table").mUploadCalls = function()
  return {}
end
def.field("table").mDownloadCalls = function()
  return {}
end
def.field("table").mUploadStatus = function()
  return {}
end
def.field("table").mDownloadStatus = function()
  return {}
end
def.field("string").accountCredential = ""
def.static("=>", ECTalkRay).Instance = function()
  return s_inst
end
def.method("=>", "string").GetAudioFolder = function(self)
  return GameUtil.GetAssetsPath() .. "/Audio_arc"
end
def.method("string").InitTalkRay = function(self, accountCredential)
  if not talkray then
    self:setServerUrl(accountCredential)
    self.mbInit = true
  else
    local _callref = {
      onInit = function(success)
        self:onInit(success)
      end,
      onError = function(type, msg)
        self:onError(type, msg)
      end,
      onUpload = function(filename, url, success)
        self:onUpload(filename, url, success)
      end,
      onDownload = function(filename, success)
        self:onDownload(filename, success)
      end
    }
    local appid = "PWWARWAR"
    local userid = GameUtil.NewGUID()
    local area = 0
    local messageFolder = self:GetAudioFolder()
    self.mEngine = talkray.init(_callref, appid, accountCredential, userid, area, messageFolder)
  end
  self:CheckFloder()
end
def.method().RemoveTalkRay = function(self)
  if talkray and self.mEngine then
    talkray.fini(self.mEngine)
  end
  self.mEngine = nil
  self.mbInit = false
end
def.method("string").setServerUrl = function(self, accountCredential)
  self.accountCredential = accountCredential
  if talkray and self.mEngine then
    talkray.setServerUrl(self.mEngine, accountCredential)
  end
  local ECSpeechUtil = require("Chat.ECSpeechUtil")
  ECSpeechUtil.Instance():EmptyAudioFolder()
end
def.method("=>", "boolean").IsTalkRegesitered = function(self)
  if not talkray then
    return self.mbInit
  else
    return self.mbInit and self.mEngine and true or false
  end
end
def.method("boolean").onInit = function(self, success)
  if success then
    self.mbInit = true
  else
    self.mEngine = nil
    self.mbInit = false
    MsgBox.ShowMsgBox(nil, StringTable.Get(15002))
  end
  local ECSpeechUtil = require("Chat.ECSpeechUtil")
  ECSpeechUtil.Instance():EmptyAudioFolder()
end
def.method("number", "string").onError = function(self, type, msg)
  MsgBox.ShowMsgBox(nil, (StringTable.Get(15003)))
end
def.method("string", "string", "boolean").onUpload = function(self, filename, url, success)
  local cb = self.mUploadCalls[filename]
  if cb then
    cb(filename, url, success)
    self.mUploadCalls[filename] = nil
  end
  self.mUploadStatus[filename] = nil
end
def.method("string", "boolean").onDownload = function(self, filename, success)
  local cb = self.mDownloadCalls[filename]
  if cb then
    cb(filename, success, nil)
    self.mDownloadCalls[filename] = nil
  end
  self.mDownloadStatus[filename] = nil
end
def.method().CheckFloder = function(self)
  local ECSpeechUtil = require("Chat.ECSpeechUtil")
  if not ECSpeechUtil.Instance():FileExists(self:GetAudioFolder()) then
    GameUtil.CreateDirectoryForFile(self:GetAudioFolder() .. "/1.txt")
  end
end
def.method("string", "function").UploadFile = function(self, filename, cb)
  print("uploadFile:", filename)
  if not talkray then
    if self:IsUploading(filename) then
      return
    end
    do
      local updata = SpeechChat.ReadFile(filename)
      if not updata then
        return
      end
      self.mUploadStatus[filename] = true
      local json = require("Utility.json")
      GameUtil.upLoadFile(self.accountCredential, filename, updata, function(success, url, path, retdata)
        if cb then
          if success then
            cb(path, json.decode(retdata).url, true)
          else
            cb(path, retdata, false)
          end
        end
        self.mUploadStatus[filename] = nil
      end)
    end
  else
    if self:IsUploading(filename) then
      self.mUploadCalls[filename] = cb
      return
    end
    if self.mEngine then
      self.mUploadCalls[filename] = cb
      self.mUploadStatus[filename] = true
      talkray.uploadfile(self.mEngine, filename)
    end
  end
end
def.method("string", "string", "function").DownloadFile = function(self, url, filename, cb)
  print("downloadFile:", url, filename)
  self:CheckFloder()
  if self:IsDownloading(filename) then
    return
  end
  self.mDownloadStatus[filename] = true
  GameUtil.downLoadUrl(url, filename, function(success, url, path, data)
    if cb then
      cb(path, success, data)
    end
    self.mDownloadStatus[filename] = nil
  end)
end
def.method("string", "=>", "boolean").IsUploading = function(self, filename)
  return self.mUploadStatus[filename] ~= nil
end
def.method("string", "=>", "boolean").IsDownloading = function(self, filename)
  return self.mDownloadStatus[filename] ~= nil
end
def.method().InitZLFtp = function(self)
  if _G.platform == 0 then
    return
  end
  local accountCredential
  if _G.ClientCfg.IsTecent() then
    if _G.LoginPlatform == MSDK_LOGIN_PLATFORM.QQ then
      if _G.platform == 2 then
      elseif _G.platform == 1 then
      end
    elseif _G.LoginPlatform == MSDK_LOGIN_PLATFORM.WX then
      if _G.platform == 2 then
      else
      end
    elseif _G.platform ~= 1 or _G.LoginPlatform == MSDK_LOGIN_PLATFORM.GUEST then
    end
  else
  end
  if accountCredential then
    if self:IsTalkRegesitered() then
      self:setServerUrl(accountCredential)
    else
      self:InitTalkRay(accountCredential)
    end
    warn(("InitTalkRay url:%s,channel:%s,login-platform:%d,platform:%d"):format(accountCredential, _G.ClientCfg.GetChannel(), _G.LoginPlatform, _G.platform))
  end
end
ECTalkRay.Commit()
s_inst = ECTalkRay()
return ECTalkRay
