local Lplus = require("Lplus")
local ECApolloVoiceChat = Lplus.Class("ECApolloVoiceChat")
local def = ECApolloVoiceChat.define
local ECApollo = require("ProxySDK.ECApollo")
local OctetsStream = require("netio.OctetsStream")
local instance
def.static("=>", ECApolloVoiceChat).Instance = function()
  if instance == nil then
    instance = ECApolloVoiceChat()
  end
  return instance
end
def.const("table").RetCode = {
  SUCCESS = 0,
  STATEWRONG = -1,
  NOFILEID = -2,
  INTERRUPT = -3,
  STOPPED = -4,
  TRANSLATEFAIL = -5,
  AUTHEXPIRED = -6,
  TIMEOUT = -7,
  CONFLICT = -8,
  TIMETOOSHORT = -9,
  AUDIOFIRST = -10,
  TRANSLATEONLY = -11
}
def.const("table").ApolloChatMode = {ON = 1, OFF = 2}
def.const("table").RecordState = {
  AVAILABLE = 0,
  RECORDING = 1,
  UPLOADING = 2,
  TRANSLATE = 3
}
def.const("number").APOLLO_NETWORK_TIMEOUT = 16000
def.const("number").APOLLO_PORT = 80
def.field("boolean").inited = false
def.field("boolean").prepared = false
def.field("string").recordFilePath = ""
def.field("string").playFilePath = ""
def.field("number").delayTimer = 0
def.field("number").recordTimer = 0
def.field("number").uploadTimer = 0
def.field("number").playTimer = 0
def.field("string").curFileId = ""
def.field("number").maxVoiceTime = 16000
def.field("number").exprieSecond = 0
def.field("number").translateLimitTime = -1
def.field("number").translateTimeout = 16000
def.field("table").translateInfo = nil
def.field("function").volumeCallback = nil
def.field("function").recordResultCallback = nil
def.field("function").playFinishCallback = nil
def.field("number").recordState = 0
def.field("table").serviceInfo = nil
def.method("=>", "boolean").Init = function(self)
  if Apollo and not self.inited then
    ECApollo.InitApollo()
    if ECApollo.CreateApolloVoiceEngine() then
      local dir = Application.persistentDataPath .. "/apollo"
      self.recordFilePath = dir .. "/myvoice.apl"
      self.playFilePath = dir .. "/voice.apl"
      GameUtil.RemoveDirectory(dir, true)
      GameUtil.CreateDirectoryForFile(self.recordFilePath)
      gmodule.network.registerProtocol("netio.protocol.mzm.gsp.apollo.SSTTRsp", ECApolloVoiceChat.OnTranslateResult)
      gmodule.network.registerProtocol("netio.protocol.mzm.gsp.apollo.SGetAuthKeyRsp", ECApolloVoiceChat.OnAuthKeyResult)
      self.translateInfo = {}
      self.inited = true
    end
  end
  warn("ApolloSTT Init:", self.inited)
  return self.inited
end
def.method().ClearServiceInfo = function(self)
  self.serviceInfo = nil
  self.prepared = false
end
def.method().RequestServiceInfo = function(self)
  local p = require("netio.protocol.mzm.gsp.apollo.CGetAuthKeyReq").new()
  gmodule.network.sendProtocol(p)
end
def.method().SetServiceInfoInvalid = function(self)
  self.prepared = false
end
def.method("number", "=>", "boolean").SetExpireSecond = function(self, sec)
  self.exprieSecond = sec
end
def.method("number", "=>", "boolean").SetTranslateLimitTime = function(self, limitTime)
  if self.recordState == ECApolloVoiceChat.RecordState.TRANSLATE then
    warn("Can not change translateLimitTime when translate")
    return false
  elseif limitTime >= self.translateTimeout then
    warn("can not set a value bogger than timeout")
    return false
  else
    self.translateLimitTime = limitTime
    return true
  end
end
def.method("number", "number", "number", "number", "number", "number", "string").RecordApolloServerInfoAndAuthKey = function(self, ipInt1, ipInt2, ipInt3, ipInt4, port, timeout, authKey)
  self.serviceInfo = {}
  self.serviceInfo.ipInt1 = ipInt1
  self.serviceInfo.ipInt2 = ipInt2
  self.serviceInfo.ipInt3 = ipInt3
  self.serviceInfo.ipInt4 = ipInt4
  self.serviceInfo.port = port
  self.serviceInfo.timeout = timeout
  self.serviceInfo.authKey = authKey
  self.prepared = true
end
def.method("function").RegisterVolumeUpdate = function(self, func)
  self.volumeCallback = func
end
def.method("function").RegisterRecordResult = function(self, func)
  self.recordResultCallback = func
end
def.method("function").RegisterPlayFinishCallback = function(self, func)
  self.playFinishCallback = func
end
def.method("=>", "number").SetApolloServerInfoAndAuthKey = function(self)
  local ret = Apollo.SetServiceInfo(self.serviceInfo.ipInt1, self.serviceInfo.ipInt2, self.serviceInfo.ipInt3, self.serviceInfo.ipInt4, self.serviceInfo.port, self.serviceInfo.timeout)
  if ret ~= 0 then
    warn("Apollo SetServiceInfo:", self.serviceInfo.ipInt1, self.serviceInfo.ipInt2, self.serviceInfo.ipInt3, self.serviceInfo.ipInt4, self.serviceInfo.port, self.serviceInfo.timeout, "fail", ret)
    return ret
  end
  ret = Apollo.SetAuthkey(self.serviceInfo.authKey, #self.serviceInfo.authKey)
  if ret ~= 0 then
    warn("Apollo SetAuthkey:", self.serviceInfo.authKey, #self.serviceInfo.authKey, "fail", ret)
    return ret
  end
  return ret
end
def.method("number", "=>", "number").SetApolloChatMode = function(self, mode)
  local apolloMode = 0
  if mode == ECApolloVoiceChat.ApolloChatMode.ON then
    apolloMode = 2
  elseif mode == ECApolloVoiceChat.ApolloChatMode.OFF then
    apolloMode = ECApollo.IsJoinRoom() and 0 or 2
  end
  local ret = Apollo.SetMode(apolloMode)
  if ret ~= 0 then
    warn("Apollo SetMode:", apolloMode, "fail:", ret)
    return ret
  end
  return 0
end
def.method("=>", "boolean").IsReady = function(self)
  return self.inited and self.prepared
end
def.method("=>", "boolean").IsAvailable = function(self)
  return self.recordState == ECApolloVoiceChat.RecordState.AVAILABLE
end
def.method("=>", "number").BeginRecord = function(self)
  if require("ProxySDK.ECReplayKit").GetStatus() == 1 then
    return -8
  end
  if not self.inited or not self.prepared then
    warn("Apollo is not ready!")
    return -1
  end
  if self.curFileId ~= "" then
    self:StopPlay()
  end
  if self.recordState ~= ECApolloVoiceChat.RecordState.AVAILABLE then
    warn("ECApolloVoiceChat is busy")
    return -1
  end
  local ret = 0
  ret = self:SetApolloChatMode(ECApolloVoiceChat.ApolloChatMode.ON)
  if ret ~= 0 then
    return ret
  end
  ret = self:SetApolloServerInfoAndAuthKey()
  if ret ~= 0 then
    self:SetApolloChatMode(ECApolloVoiceChat.ApolloChatMode.OFF)
    warn("Apollo SetApolloServerInfoAndAuthKey", "fail:", ret)
    return ret
  end
  self:PauseBackgroundMusic(true)
  self.recordState = ECApolloVoiceChat.RecordState.RECORDING
  self.delayTimer = GameUtil.AddGlobalTimer(0.2, true, function()
    if self.recordState ~= ECApolloVoiceChat.RecordState.RECORDING then
      return
    end
    local ret = Apollo.StartRecord(self.recordFilePath)
    if ret ~= 0 then
      self:SetApolloChatMode(ECApolloVoiceChat.ApolloChatMode.OFF)
      warn("Apollo StartRecord:", self.recordFilePath, "fail:", ret)
      self.recordState = ECApolloVoiceChat.RecordState.AVAILABLE
      if self.recordResultCallback then
        self.recordResultCallback(ret, "", 0, "")
      end
      return
    end
    self.recordTimer = self:RemoveTimer(self.recordTimer)
    local startTick = GameUtil.GetTickCount()
    self.recordTimer = GameUtil.AddGlobalTimer(0, false, function()
      local volume = Apollo.GetMicLevel()
      if self.volumeCallback then
        self.volumeCallback(volume / 65535)
      end
      local curTick = GameUtil.GetTickCount()
      if curTick - startTick > self.maxVoiceTime then
        self:EndRecord()
      end
    end)
  end)
  return 0
end
def.method("=>", "number").EndRecord = function(self)
  if not self.inited or not self.prepared then
    warn("Apollo is not ready!")
    return -1
  end
  self.delayTimer = self:RemoveTimer(self.delayTimer)
  self.recordTimer = self:RemoveTimer(self.recordTimer)
  if self.recordState == ECApolloVoiceChat.RecordState.RECORDING then
    self:PauseBackgroundMusic(false)
    do
      local ret = 0
      ret = Apollo.StopRecord(false)
      if ret ~= 0 then
        self:SetApolloChatMode(ECApolloVoiceChat.ApolloChatMode.OFF)
        self.recordState = ECApolloVoiceChat.RecordState.AVAILABLE
        warn("Apollo StopRecord:", false, "fail:", ret)
        return ret
      end
      ret = self:SetApolloChatMode(ECApolloVoiceChat.ApolloChatMode.OFF)
      if ret ~= 0 then
        self.recordState = ECApolloVoiceChat.RecordState.AVAILABLE
        return ret
      end
      ret = Apollo.SendRecFile(self.recordFilePath)
      if ret ~= 0 then
        self.recordState = ECApolloVoiceChat.RecordState.AVAILABLE
        warn("Apollo SendRecFile:", self.recordFilePath, "fail:", ret)
        return ret
      end
      self.recordState = ECApolloVoiceChat.RecordState.UPLOADING
      local fileTime = Apollo.GetOfflineFileTime()
      if fileTime < 1 then
        self.recordState = ECApolloVoiceChat.RecordState.AVAILABLE
        warn("record time to short", fileTime)
        return ECApolloVoiceChat.RetCode.TIMETOOSHORT
      end
      self.uploadTimer = self:RemoveTimer(self.uploadTimer)
      local startTick = GameUtil.GetTickCount()
      self.uploadTimer = GameUtil.AddGlobalTimer(0, false, function()
        local success = Apollo.GetVoiceUploadState()
        if success == 0 then
          do
            local r, fileId = Apollo.GetFileID()
            if r == 0 then
              self.recordState = ECApolloVoiceChat.RecordState.TRANSLATE
              self.uploadTimer = self:RemoveTimer(self.uploadTimer)
              self:Translate(fileId, function(ret, fid, text)
                if ret == 0 and text ~= nil then
                  self.recordState = ECApolloVoiceChat.RecordState.AVAILABLE
                  self.recordResultCallback(ECApolloVoiceChat.RetCode.SUCCESS, fileId, fileTime, text)
                elseif ret == ECApolloVoiceChat.RetCode.AUDIOFIRST then
                  self.recordState = ECApolloVoiceChat.RecordState.AVAILABLE
                  self.recordResultCallback(ECApolloVoiceChat.RetCode.AUDIOFIRST, fileId, fileTime, "")
                elseif ret == ECApolloVoiceChat.RetCode.TRANSLATEONLY then
                  self.recordResultCallback(ECApolloVoiceChat.RetCode.TRANSLATEONLY, fileId, fileTime, text)
                else
                  self.recordState = ECApolloVoiceChat.RecordState.AVAILABLE
                  self.recordResultCallback(ECApolloVoiceChat.RetCode.TRANSLATEFAIL, fileId, fileTime, "")
                end
              end)
            else
              warn("no fileId error", ret)
              self.recordState = ECApolloVoiceChat.RecordState.AVAILABLE
              self.uploadTimer = self:RemoveTimer(self.uploadTimer)
              self.recordResultCallback(ECApolloVoiceChat.RetCode.NOFILEID, "", 0, "")
            end
            return
          end
        elseif success == 11 then
        elseif success == 121 then
          self.recordState = ECApolloVoiceChat.RecordState.AVAILABLE
          self.uploadTimer = self:RemoveTimer(self.uploadTimer)
          self.recordResultCallback(ECApolloVoiceChat.RetCode.TIMEOUT, "", 0, "")
        elseif success == 405 then
          self.recordState = ECApolloVoiceChat.RecordState.AVAILABLE
          self.uploadTimer = self:RemoveTimer(self.uploadTimer)
          self:RequestServiceInfo()
          self.recordResultCallback(ECApolloVoiceChat.RetCode.AUTHEXPIRED, "", 0, "")
        else
          self.recordState = ECApolloVoiceChat.RecordState.AVAILABLE
          self.uploadTimer = self:RemoveTimer(self.uploadTimer)
          self.recordResultCallback(success, "", 0, nil)
        end
      end)
      return ret
    end
  else
    warn("Apollo is not recording")
    return -1
  end
end
def.method("=>", "number").CancelRecord = function(self)
  if not self.inited or not self.prepared then
    warn("Apollo is not ready!")
    return -1
  end
  self.delayTimer = self:RemoveTimer(self.delayTimer)
  self.recordTimer = self:RemoveTimer(self.recordTimer)
  if self.recordState == ECApolloVoiceChat.RecordState.RECORDING then
    self:PauseBackgroundMusic(false)
    local ret = 0
    ret = Apollo.StopRecord(false)
    if ret ~= 0 then
      self:SetApolloChatMode(ECApolloVoiceChat.ApolloChatMode.OFF)
      self.recordState = ECApolloVoiceChat.RecordState.AVAILABLE
      warn("Apollo StopRecord:", false, "fail:", ret)
      return ret
    end
    ret = self:SetApolloChatMode(ECApolloVoiceChat.ApolloChatMode.OFF)
    if ret ~= 0 then
      self.recordState = ECApolloVoiceChat.RecordState.AVAILABLE
      return ret
    end
    self.recordState = ECApolloVoiceChat.RecordState.AVAILABLE
    return ret
  else
    warn("Apollo is not recording")
    return -1
  end
end
def.method("string", "number", "=>", "number").Play = function(self, fileId, time)
  if not self.inited or not self.prepared then
    warn("Apollo is not ready!")
    return -1
  end
  if self.recordState ~= ECApolloVoiceChat.RecordState.AVAILABLE then
    warn("ECApolloVoiceChat is busy")
    return -1
  end
  if self.curFileId ~= "" then
    if self.curFileId == fileId then
      return 0
    else
      self:StopPlay()
    end
  end
  local ret = 0
  ret = self:SetApolloChatMode(ECApolloVoiceChat.ApolloChatMode.ON)
  if ret ~= 0 then
    warn("Apollo SetMode:", ECApolloVoiceChat.ApolloChatMode.ON, "fail:", ret)
    return ret
  end
  ret = self:SetApolloServerInfoAndAuthKey()
  if ret ~= 0 then
    self:SetApolloChatMode(ECApolloVoiceChat.ApolloChatMode.OFF)
    warn("Apollo SetApolloServerInfoAndAuthKey", "fail:", ret)
    return ret
  end
  ret = Apollo.DownloadVoiceFile(self.playFilePath, fileId, false)
  if ret ~= 0 then
    self:SetApolloChatMode(ECApolloVoiceChat.ApolloChatMode.OFF)
    warn("Apollo DownloadVoiceFile:", self.playFilePath, fileId, false, "fail:", ret)
    return ret
  end
  self.curFileId = fileId
  local ms = time * 1000 + 1000
  local startTick = GameUtil.GetTickCount()
  local downloadFinish = false
  self.playTimer = GameUtil.AddGlobalTimer(0, false, function()
    if not downloadFinish then
      local success = Apollo.GetVoiceDownloadState()
      if success == 0 then
        downloadFinish = true
        startTick = GameUtil.GetTickCount()
        self:PauseBackgroundMusic(true)
        ret = Apollo.PlayFile(self.playFilePath)
        if ret ~= 0 then
          self:SetApolloChatMode(ECApolloVoiceChat.ApolloChatMode.OFF)
          self.curFileId = ""
          self.playTimer = self:RemoveTimer(self.playTimer)
          self:PauseBackgroundMusic(false)
          if self.playFinishCallback then
            self.playFinishCallback(ret, fileId)
          end
          warn("Apollo PlayFile:", self.playFilePath, "fail:", ret)
        end
        return
      elseif success == 11 then
      elseif success == 121 then
        self:SetApolloChatMode(ECApolloVoiceChat.ApolloChatMode.OFF)
        self.curFileId = ""
        self.playTimer = self:RemoveTimer(self.playTimer)
        if self.playFinishCallback then
          self.playFinishCallback(success, fileId)
        end
      else
        self:SetApolloChatMode(ECApolloVoiceChat.ApolloChatMode.OFF)
        self.curFileId = ""
        self.playTimer = self:RemoveTimer(self.playTimer)
        if self.playFinishCallback then
          self.playFinishCallback(success, fileId)
        end
      end
    else
      local curTick = GameUtil.GetTickCount()
      if curTick - startTick > ms then
        self:SetApolloChatMode(ECApolloVoiceChat.ApolloChatMode.OFF)
        self.curFileId = ""
        self.playTimer = self:RemoveTimer(self.playTimer)
        self:PauseBackgroundMusic(false)
        if self.playFinishCallback then
          self.playFinishCallback(ECApolloVoiceChat.RetCode.SUCCESS, fileId)
        end
      end
    end
  end)
  return ret
end
def.method("=>", "number").StopPlay = function(self)
  if not self.inited or not self.prepared then
    warn("Apollo is not ready!")
    return -1
  end
  local fileId = self.curFileId
  self.curFileId = ""
  self.playTimer = self:RemoveTimer(self.playTimer)
  if fileId ~= "" then
    self:PauseBackgroundMusic(false)
    if self.playFinishCallback then
      self.playFinishCallback(ECApolloVoiceChat.RetCode.STOPPED, fileId)
    end
  end
  local ret = Apollo.StopPlayFile()
  if ret ~= 0 then
    self:SetApolloChatMode(ECApolloVoiceChat.ApolloChatMode.OFF)
    warn("Apollo StopPlayFile:", "fail", ret)
    return ret
  end
  ret = self:SetApolloChatMode(ECApolloVoiceChat.ApolloChatMode.OFF)
  if ret ~= 0 then
    return ret
  end
  return ret
end
def.method("number", "=>", "number").SetSpeakerVolume = function(self, volume)
  if not self.inited then
    warn("Apollo is not ready!")
    return -1
  end
  if volume < 0 then
    volume = 0
  end
  if volume > 1 then
    volume = 1
  end
  local volumeInt = math.floor(volume * 65535)
  local ret = Apollo.SetSpeakerVolume(volumeInt)
  if ret ~= 0 then
    warn("Apollo SetSpeakerVolume", volumeInt, "fail:", ret)
  end
  return ret
end
def.method("=>", "boolean").IsPlaying = function(self)
  return self.curFileId ~= ""
end
def.method("string", "function").Translate = function(self, fileId, callback)
  self:_translateByServer(fileId)
  local startTick = GameUtil.GetTickCount()
  local translateLimit = self.translateLimitTime >= 0
  local limitTime = self.translateLimitTime
  local translateTimer = GameUtil.AddGlobalTimer(0, false, function()
    local curTick = GameUtil.GetTickCount()
    local msPass = curTick - startTick
    if translateLimit and msPass > limitTime then
      warn("Client audio first")
      local info = self.translateInfo[fileId]
      if info then
        translateLimit = false
        info.aduioFirst = true
        if info.callback then
          info.callback(ECApolloVoiceChat.RetCode.AUDIOFIRST, fileId, nil)
        end
      end
    end
    if msPass > self.translateTimeout then
      warn("Client translate timeout")
      local info = self.translateInfo[fileId]
      if info then
        self:RemoveTimer(info.timer)
        self.translateInfo[fileId] = nil
        if info.callback then
          info.callback(require("netio.protocol.mzm.gsp.apollo.ErrorCodes").ERROR_STT_LOCAL_TIMEOUT, fileId, nil)
        end
      end
    end
  end)
  self.translateInfo[fileId] = {callback = callback, timer = translateTimer}
end
def.method("number", "=>", "number").RemoveTimer = function(self, timer)
  if timer > 0 then
    GameUtil.RemoveGlobalTimer(timer)
  end
  return 0
end
def.method("string")._translateByServer = function(self, fileId)
  warn("_translateByServer", fileId)
  local fileIdOctets = require("netio.Octets").rawFromString(fileId)
  local p = require("netio.protocol.mzm.gsp.apollo.CSTTReq").new(fileIdOctets)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnTranslateResult = function(p)
  local self = ECApolloVoiceChat.Instance()
  local fileIdStr = ECApolloVoiceChat.OctetsToString(p.file_id)
  warn("OnTranslateResult", p.retcode, fileIdStr)
  local info = self.translateInfo[fileIdStr]
  if info then
    local ErrorCodes = require("netio.protocol.mzm.gsp.apollo.ErrorCodes")
    local ret = p.retcode
    self:RemoveTimer(info.timer)
    self.translateInfo[fileIdStr] = nil
    if ret == ErrorCodes.ERROR_SUCCEED then
      local textStr = ECApolloVoiceChat.OctetsToString(p.file_text)
      if info.aduioFirst then
        if info.callback then
          info.callback(ECApolloVoiceChat.RetCode.TRANSLATEONLY, fileIdStr, textStr)
        end
      elseif info.callback then
        info.callback(ret, fileIdStr, textStr)
      end
    elseif ret == ErrorCodes.ERROR_STT_LOCAL_TIMEOUT then
      warn("server timeout", fileIdStr)
      if info.callback then
        info.callback(ret, fileIdStr, nil)
      end
    elseif info.callback then
      info.callback(ret, fileIdStr, nil)
    end
  end
end
def.static("table").OnAuthKeyResult = function(p)
  local ret = p.retcode
  if ret == 0 then
    local ips = {}
    for k, v in ipairs(p.main_svr_urls) do
      local url = ECApolloVoiceChat.OctetsToString(v.url)
      table.insert(ips, url)
    end
    for k, v in ipairs(p.slave_svr_urls) do
      local url = ECApolloVoiceChat.OctetsToString(v.url)
      table.insert(ips, url)
    end
    local ipInt1 = ips[1] and ECApolloVoiceChat.IpStringToInt(ips[1]) or 0
    local ipInt2 = ips[2] and ECApolloVoiceChat.IpStringToInt(ips[2]) or 0
    local ipInt3 = ips[3] and ECApolloVoiceChat.IpStringToInt(ips[3]) or 0
    local ipInt4 = ips[4] and ECApolloVoiceChat.IpStringToInt(ips[4]) or 0
    local authKey = ECApolloVoiceChat.OctetsToString(p.auth_key)
    local exprieSecond = p.expire_in
    ECApolloVoiceChat.Instance():SetExpireSecond(exprieSecond)
    ECApolloVoiceChat.Instance():RecordApolloServerInfoAndAuthKey(ipInt1, ipInt2, ipInt3, ipInt4, ECApolloVoiceChat.APOLLO_PORT, ECApolloVoiceChat.APOLLO_NETWORK_TIMEOUT, authKey)
  else
    warn("GetAuthKey Fail", ret)
  end
end
def.static("string", "=>", "number").IpStringToInt = function(ipStr)
  local sections = string.split(ipStr, ".")
  if sections and #sections == 4 then
    local ret = 0
    for i = 1, 4 do
      local section = sections[i]
      local sectionNum = tonumber(section)
      local numAfterShift = bit.lshift(sectionNum, (i - 1) * 8)
      ret = bit.bor(ret, numAfterShift)
    end
    return ret
  else
    warn(ipStr, "is not a valid ip str")
    return 0
  end
end
def.static("userdata", "=>", "string").OctetsToString = function(content)
  local key, os = OctetsStream.beginTempStream()
  os:marshalOctets(content)
  local msg = os:unmarshalStringFromOctets()
  OctetsStream.endTempStream(key)
  return msg
end
def.method("boolean").PauseBackgroundMusic = function(self, pause)
  if pause then
    gmodule.moduleMgr:GetModule(ModuleId.SOUND):SetGlobalVolume(0.01)
  else
    gmodule.moduleMgr:GetModule(ModuleId.SOUND):SetGlobalVolume(1)
  end
end
ECApolloVoiceChat.Commit()
return ECApolloVoiceChat
