local Lplus = require("Lplus")
local ECGame = Lplus.ForwardDeclare("ECGame")
local ECRecordUtil = require("Chat.ECRecordUtil")
local ECTalkRay = require("Chat.ECTalkRay")
local ECSpeechUtil = Lplus.Class("ECSpeechUtil")
local speechUtil
do
  local def = ECSpeechUtil.define
  def.field("boolean").mCalled = false
  def.field("userdata").mSCObj = nil
  def.field("userdata").mSCComp = nil
  def.field("userdata").engine = nil
  def.field("string").voicetext = ""
  def.field("userdata").voicedata = nil
  def.field("boolean").isrecording = false
  def.field("number").timeid = 0
  def.field("number").pass = 0
  def.field("function").finish_call = nil
  def.field("number").bgvolume = 0
  def.field("number").soundvolume = 0
  def.field("number").guivolume = 0
  def.field("number").voicevolume = 1
  def.field("number").msgId = 0
  def.field("number").volume_time = 0
  def.field("function").volume_call = nil
  def.field("boolean").mTextOK = false
  def.field("boolean").mVoiceOK = false
  def.field("number").begintime = 0
  def.field("number").endtime = 0
  def.field("boolean").mDelayStop = false
  def.field("string").random_prewords = ""
  def.field("boolean").bEverPrompt = false
  def.field("string").device = ""
  def.field("string").testUrl = ""
  local _max_time_ = 16
  local _freq_ = 8000
  def.static("=>", ECSpeechUtil).Instance = function()
    if speechUtil == nil then
      speechUtil = ECSpeechUtil()
    end
    return speechUtil
  end
  def.method("boolean").onInit = function(self, success)
    if success then
    else
      self.engine = nil
      warn("[Audio]Failed to init SpeechEngine")
    end
  end
  def.method("number").onStop = function(self, stoptype)
    local audioFile = GameUtil.GetAssetsPath() .. "/" .. self:getAudioFileName()
    if not ECRecordUtil.opusValid() then
      self.voicedata = self.mSCComp.ReadSoundData(audioFile, 0)
    else
      local _, _, bitrate = ECRecordUtil.getAudioInfo()
      self.voicedata = self.mSCComp.opus_ReadSoundData(audioFile, 0, bitrate)
    end
    if self.voicedata ~= nil then
      self.mVoiceOK = true
    else
      self.mVoiceOK = false
      warn("[Audio]Failed to read " .. self:getAudioFileName())
    end
    self:TryFinishCall()
  end
  def.method("string", "number").onVolume = function(self, recid, v)
    if self.volume_call then
      self.volume_call(self, v)
    end
    if v > 0 and self.volume_time == 0 then
      self.volume_time = os.time()
    end
    if not self.isrecording or not (v > 0) or not (os.time() - self.volume_time >= 1) or not self.mDelayStop then
    end
  end
  def.method("string", "string").onText = function(self, recid, text)
    self.voicetext = self.voicetext .. text
    if string.len(text) == 0 then
      self.mTextOK = true
      warn("Speech text:", self.voicetext)
      self:TryFinishCall()
    end
  end
  def.method("number", "string", "string").onError = function(self, errCode, recid, errmsg)
    warn("[Audio]Speech onError errmsg=" .. errmsg .. ",errCode=" .. errCode)
  end
  def.method().TryFinishCall = function(self)
    if self:NeedTranslate() then
      if self.mTextOK and self.mVoiceOK then
        if self.finish_call then
          self.finish_call(self)
        end
        self:Clear()
      else
      end
    else
      if self.mVoiceOK then
        if self.finish_call then
          self.finish_call(self)
        end
        self:Clear()
      else
      end
    end
  end
  def.method().createObj = function(self)
    if nil ~= self.mSCObj then
      return
    end
    local EC = require("Types.Vector")
    local obj = GameObject.GameObject("SpeechChat")
    obj.localPosition = EC.Vector3.zero
    obj.localScale = EC.Vector3.one
    local comp = obj:GetComponent("SpeechChat")
    comp = comp or obj:AddComponent("SpeechChat")
    self.mSCComp = comp
    self.mSCObj = obj
    local _callref = {
      onSpeechStop = function(data, length)
        self:onSpeechStop(data, length)
      end,
      onSpeechCancel = function()
        self:onSpeechCancel()
      end
    }
    self.mSCComp:SetLuaCallback(_callref)
  end
  def.method().releaseObj = function(self)
    if self.mSCObj ~= nil then
      Object.Destroy(self.mSCObj)
    end
    self.mSCObj = nil
    self.mSCComp = nil
  end
  def.method("boolean").ChangeAudioEngine = function(self, value)
    if _G.ClientCfg.IsSpeechTranslate() then
    end
  end
  def.method("=>", "boolean").StartRecording = function(self)
    if self.mSCComp then
      local _, _, freq = ECRecordUtil.getAudioInfo()
      return self.mSCComp:StartRecording(self.device, false, _max_time_ + 5, freq)
    end
    return false
  end
  def.method().StopRecording = function(self)
    if self.mSCComp then
      local audioType, _, _, bitrate = ECRecordUtil.getAudioInfo()
      self.mSCComp:StopRecording(self.device, _max_time_, audioType, bitrate)
    end
  end
  def.method().CancelRecording = function(self)
    if self.mSCComp then
      self.mSCComp:StopRecording(self.device, -1)
    end
  end
  def.method("userdata", "number").onSpeechStop = function(self, data, length)
    if data and length > 0 then
      self.voicedata = data
      self.mVoiceOK = true
    else
      self.mVoiceOK = false
      warn("[Audio] voicedata is nil ")
    end
    self:TryFinishCall()
  end
  def.method().onSpeechCancel = function(self)
  end
  def.method("number").onSpeechVolume = function(self, v)
    if self.volume_call then
      self.volume_call(self, v)
    end
    if v > 0 and self.volume_time == 0 then
      self.volume_time = os.time()
    end
    if not self.isrecording or not (v > 0) or not (os.time() - self.volume_time >= 1) or not self.mDelayStop then
    end
  end
  def.method("=>", "number").getSpeechVolume = function(self)
    if self.mSCComp then
      return self.mSCComp:GetVolume(self.device)
    end
    return 0
  end
  def.method("string").PlayAudioFile = function(self, fullpath)
    if self:FileExists(fullpath) then
      local audioData = self:ReadFile(fullpath)
      if audioData and self.mSCComp then
        local pt = self:ParseAudioType(fullpath)
        self:PlayAudio(audioData, pt)
      end
    end
  end
  def.method("userdata", "string").PlayAudio = function(self, data, pt)
    if self.mSCComp then
      local audioType, freq = ECRecordUtil.getPlayInfo(pt)
      self.mSCComp:PlayAudio(data:getBytes(), freq, audioType)
      self:PauseBackgroundMusic()
    end
  end
  def.method().StopAudio = function(self)
    if self.mSCComp then
      self.mSCComp:StopAudio()
      self:ResumeBackgroundMusic()
    end
  end
  def.method().speech_init = function(self)
    local audioFile = GameUtil.GetAssetsPath() .. "/" .. self:getAudioFileName()
    if not ECRecordUtil.isValid() then
      local param = ""
      if platform == 1 then
        param = ";575d3605;20000"
      elseif platform == 2 then
        param = ";56fa455b;20000"
      end
      local _callref = {
        onInit = function(success)
          self:onInit(success)
        end,
        onStop = function(stoptype)
          self:onStop(stoptype)
        end,
        onVolume = function(recid, v)
          self:onVolume(recid, v)
        end,
        onText = function(recid, text)
          self:onText(recid, text)
        end,
        onError = function(errCode, recid, errmsg)
          self:onError(errCode, recid, errmsg)
        end
      }
      local _, _, freq = ECRecordUtil.getAudioInfo()
      self.engine = speech.init(0, _callref, freq, 0, audioFile .. param)
    end
    self:createObj()
    self.mCalled = true
    self:RemoveAudioFile(audioFile)
  end
  def.method().speech_fini = function(self)
    self:releaseObj()
    if not ECRecordUtil.isValid() and self.engine then
      speech.fini(self.engine)
      self.engine = nil
    end
    self.mDelayStop = false
    self.random_prewords = ""
  end
  def.method("=>", "string").speech_start = function(self)
    if self.engine then
      local recId = speech.start(self.engine)
      return recId
    end
    return ""
  end
  def.method().speech_stop = function(self)
    if self.engine then
      speech.stop(self.engine)
    end
  end
  def.method().speech_cancel = function(self)
    if self.engine then
      speech.cancel(self.engine)
    end
  end
  def.method().PauseBackgroundMusic = function(self)
    gmodule.moduleMgr:GetModule(ModuleId.SOUND):SetGlobalVolume(0.01)
  end
  def.method().ResumeBackgroundMusic = function(self)
    gmodule.moduleMgr:GetModule(ModuleId.SOUND):SetGlobalVolume(1)
  end
  def.method("=>", "boolean").IsFrequence = function(self)
    return Time.realtimeSinceStartup - self.endtime < 1
  end
  def.method("=>", "boolean").IsRecording = function(self)
    return self.isrecording
  end
  def.method("=>", "boolean").IsWirelessNetwork = function(self)
    return Application.internetReachability == NetworkReachability.ReachableViaLocalAreaNetwork
  end
  def.method("=>", "boolean").NeedTranslate = function(self)
    if ECRecordUtil.isValid() then
      return false
    end
    if _G.ClientCfg.IsSpeechTranslate() then
      local b1 = false
      if b1 then
        return self:IsWirelessNetwork()
      else
        return true
      end
    else
      return false
    end
  end
  def.method("function", "function", "=>", "boolean").RecordVoice = function(self, _finishcall, _volumecall)
    if not self.mCalled and self:NeedTranslate() then
      self:speech_init()
      return false
    end
    if not self.engine and self:NeedTranslate() then
      local err = "[Audio]Failed to start SpeechEngine"
      warn(err)
      return false
    end
    local function start_record(self)
      if self.isrecording then
        return true
      end
      self.voicetext = ""
      self.voicedata = nil
      self.mTextOK = false
      self.mVoiceOK = false
      self.isrecording = true
      self:PauseBackgroundMusic()
      if self:NeedTranslate() then
        local recId = self:speech_start()
        if recId == "" then
          self.isrecording = false
          self:ResumeBackgroundMusic()
          return false
        end
      else
        local bsuccess = self:StartRecording()
        if not bsuccess then
          self.isrecording = false
          self:ResumeBackgroundMusic()
          return false
        end
      end
      self.volume_time = 0
      self.volume_call = _volumecall
      self.finish_call = _finishcall
      self.begintime = Time.realtimeSinceStartup
      self:StartTimer()
      return true
    end
    return start_record(self)
  end
  def.method().StopVoice = function(self)
    if not self.isrecording then
      return
    end
    self:StopTimer()
    self.isrecording = false
    self.endtime = Time.realtimeSinceStartup
    self:ResumeBackgroundMusic()
    if self:NeedTranslate() then
      self:speech_stop()
    else
      self:StopRecording()
    end
    self:TryFinishCall()
  end
  def.method("function").CancelVoice = function(self, _call)
    if not self.isrecording then
      return
    end
    self:StopTimer()
    self.isrecording = false
    self.endtime = Time.realtimeSinceStartup
    if self:NeedTranslate() then
      self:speech_cancel()
    else
      self:CancelRecording()
    end
    self:Clear()
    self:ResumeBackgroundMusic()
    if _call then
      _call()
    end
  end
  def.method().EnterDelayStop = function(self)
    self.mDelayStop = true
  end
  def.method().LeaveDelayStop = function(self)
    self.mDelayStop = false
  end
  def.method("=>", "boolean").IsDelayStop = function(self)
    return self.mDelayStop
  end
  def.method().StartTimer = function(self)
    if not self.isrecording then
      return
    end
    self.pass = 0
    self.timeid = GameUtil.AddGlobalTimer(0.5, false, function()
      if self.isrecording then
        self.pass = self.pass + 0.5
        if not self:NeedTranslate() then
          self:onSpeechVolume(self:getSpeechVolume())
        end
        if self.pass >= _max_time_ then
          self:StopVoice()
        end
      end
    end)
  end
  def.method().StopTimer = function(self)
    if not self.isrecording then
      return
    end
    if self.timeid ~= 0 then
      GameUtil.RemoveGlobalTimer(self.timeid)
    end
    self.timeid = 0
    self.pass = 0
  end
  def.method().Clear = function(self)
    self.voicedata = nil
    self.voicetext = ""
    self.mTextOK = false
    self.mVoiceOK = false
  end
  def.method("=>", "string").getAudioFileName = function(self)
    return self.random_prewords .. "_voice.data"
  end
  def.method("boolean", "=>", "string", "number").getAudioFilePreWords = function(self, isSend)
    local pre
    if isSend then
      pre = self.random_prewords .. "_audio_my_"
    else
      pre = self.random_prewords .. "_audio_"
    end
    return pre, string.len(pre)
  end
  def.method("number", "boolean", "=>", "string").MakeFullPath = function(self, uniqueId, isSend)
    local pre, len = self:getAudioFilePreWords(isSend)
    local filename = string.format("/Audio_arc/%s%d", pre, uniqueId)
    return GameUtil.GetAssetsPath() .. filename
  end
  def.method("string", "boolean", "=>", "number").FullPath2UniqueID = function(self, fullpath, isSend)
    local str = fullpath
    local bFind = false
    local uniqueId = 0
    local pre, len = self:getAudioFilePreWords(isSend)
    string.gsub(str, "%/" .. pre .. "%d+%.", function(sub)
      bFind = true
      local idstr = sub
      local _, _, n = idstr:find(pre .. "(%d+)%.")
      uniqueId = tonumber(n)
      return sub
    end)
    return uniqueId
  end
  def.method("string", "=>", "string").ParseAudioType = function(self, url_filename)
    local _, _, _, audioType = string.find(url_filename, "([%w_]+)%.([%w_]+)$")
    return ECRecordUtil.checkAudioType(audioType or "")
  end
  def.method("string").RemoveAudioFile = function(self, fullpath)
    if self:FileExists(fullpath) then
      os.remove(fullpath)
    end
  end
  def.method().EmptyAudioFolder = function(self)
    local audioFolder = ECTalkRay.Instance():GetAudioFolder()
    local ret = SpeechChat.EmptyFolder(audioFolder)
    if not ret and self:FileExists(audioFolder) then
      warn("[Audio]EmptyFolder failure:" .. audioFolder)
    end
  end
  def.method("userdata", "string", "=>", "boolean").WriteFile = function(self, data, fullpath)
    if self.mSCComp then
      return self.mSCComp.WriteFile(data:getBytes(), fullpath)
    end
    return false
  end
  def.method("string", "=>", "userdata").ReadFile = function(self, fullpath)
    if self.mSCComp then
      local d = self.mSCComp.ReadFile(fullpath)
      if d then
        local os = Octets.Octets()
        os:replace(d)
        return os
      else
        warn(("[Audio]Failed to read filename:%s"):format(fullpath))
      end
    end
    return nil
  end
  def.method("string", "=>", "boolean").FileExists = function(self, fullpath)
    if string.len(fullpath) == 0 then
      return false
    end
    local file, _ = io.open(fullpath, "rb")
    if file then
      file:close()
    end
    return file ~= nil
  end
  def.method("=>", "number").GetVoiceVolume = function(self)
    return self.voicevolume
  end
  def.method("number", "=>", "number").SetVoiceVolume = function(self, v)
    local oldv = self.voicevolume
    self.voicevolume = v
    self.mSCComp.volume = v
    return oldv
  end
  def.method("table").UploadAudioFile = function(self, themsg)
    local fullpath = themsg.audioFile
    if not self:FileExists(fullpath) then
      warn("[Audio] file not exists,path=" .. fullpath)
      return
    end
    ECTalkRay.Instance():UploadFile(fullpath, function(filename, url, success)
      if not success then
        warn(("[Audio] Failed Upload File:%s,Reason:%s"):format(filename, url))
        themsg.result = SendStatus.Failure
      else
        themsg.audioURL = url
      end
    end)
  end
  def.method("table").UploadAudio = function(self, themsg)
    local uniqueMsgID = themsg.uniqueHpMsgID
    local _, audioType = ECRecordUtil.getAudioInfo()
    local fullpath = self:MakeFullPath(uniqueMsgID, true) .. "." .. audioType
    if self:WriteFile(themsg.audioData, fullpath) then
      themsg.audioFile = fullpath
      themsg.audioData = nil
      ECTalkRay.Instance():UploadFile(fullpath, function(filename, url, success)
        if not success then
          warn(("[Audio] Failed Upload File:%s,Reason:%s"):format(filename, url))
          themsg.result = SendStatus.Failure
        else
          themsg.audioURL = url
        end
      end)
    else
      themsg.result = SendStatus.Failure
      warn(("[Audio]Failed Write File :%s"):format(fullpath))
    end
  end
  def.method("table", "function").DownloadAudio = function(self, themsg, cb)
    local uniqueMsgID = themsg.uniqueMsgID
    local fullpath = self:MakeFullPath(uniqueMsgID, false)
    local url = themsg.audioURL
    local audioType = self:ParseAudioType(url)
    fullpath = fullpath .. "." .. audioType
    ECTalkRay.Instance():DownloadFile(url, fullpath, function(filename, success, downdata)
      local uniqueId = self:FullPath2UniqueID(filename, false)
      local audioData
      if success then
        if downdata then
          local os = Octets.Octets()
          os:replace(downdata)
          audioData = os
        end
        audioData = audioData or self:ReadFile(filename)
      else
        warn(("[Audio] Failed Download url:%s"):format(url))
      end
      if cb then
        cb(uniqueId, success, audioData, audioType)
      end
    end)
  end
  def.method("number", "string", "string").SendVoice = function(self, channel, roleid, name)
    if self.endtime - self.begintime < 1 then
      return
    end
    if self:NeedTranslate() then
      if self.voicetext == "" or self.voicedata == nil then
        return
      end
    elseif self.voicedata == nil then
      return
    end
    local timelapse = math.floor(self.endtime - self.begintime)
    if timelapse < 1 then
      timelapse = 1
    end
    if not ECRecordUtil.isValid() then
    else
      self.msgId = self.msgId + 1
      local postId_ = tostring(self.msgId)
      local _, audioType = ECRecordUtil.getAudioInfo()
      local data = {
        audioType = audioType,
        audio = self.voicedata
      }
      local uniqueMsgID = self.msgId
      local fullpath = self:MakeFullPath(uniqueMsgID, true) .. "." .. audioType
      warn("audioType = ", audioType)
      warn("msgId = ", self.msgId)
      warn("HttpPost!")
      ECRecordUtil.Instance():doHttpPost(postId_, data, function(success, url, postId, retdata)
        if not success then
          warn(("[Audio] Failed doHttpPost postId:%s,Reason:%s"):format(postId, retdata))
        else
          warn(("[Audio] Success Upload postId:%s,url:%s"):format(postId, url))
          local json = require("Utility.json")
          warn(" retdata =", retdata)
          warn(" retdata.string =", retdata.string)
          local result = json.decode(retdata.string)
          self.testUrl = result.url
          warn("text:", result.text)
          warn("url:", result.url)
        end
      end)
      do break end
      warn(("[Audio]Failed Write File :%s"):format(fullpath))
    end
  end
  def.method("table").SendVoiceInner = function(self, msg)
  end
  def.method("string", "string", "number", "function").DownloadVoice = function(self, url, fullpath, second, cb)
    warn("url,fullpath = ", url, fullpath)
    ECTalkRay.Instance():DownloadFile(url, fullpath, function(filename, success, downdata)
      if not success then
        warn(("[Audio] Failed Download url:%s"):format(url))
        if cb then
          cb()
        end
      else
        warn(("[Audio] Success Download File:%s"):format(filename))
        if not downdata then
          warn(("ReadFile failure filename:%s"):format(filename))
          if cb then
            cb()
          end
        else
          warn("Start Play...")
          if self.mSCComp then
            self.mSCComp:StopAudio()
          end
          if self.mSCComp then
            local _, Type = ECRecordUtil.getAudioInfo()
            local audioType, freq = ECRecordUtil.getPlayInfo(Type)
            warn("play audioType =", Type)
            self:PauseBackgroundMusic()
            GameUtil.AddGlobalTimer(second + 1, true, function()
              self:ResumeBackgroundMusic()
              if cb then
                cb()
              end
            end)
            self.mSCComp:PlayAudio(downdata, freq, audioType)
          end
        end
        self:RemoveAudioFile(filename)
      end
    end)
  end
  def.static("=>", "table").PlayQueueMgr = function()
  end
  def.method().PlayTest = function(self)
    local _, audioType = ECRecordUtil.getAudioInfo()
    self:PlayAudio(self.voicedata, audioType)
    local tt = math.floor(self.endtime - self.begintime)
    MsgBox.ShowMsgBox(nil, self.voicetext .. StringTable.Get(15060) .. ":" .. tt, nil, MsgBox.MsgBoxType.MBBT_OK)
    local mTimerID = GameUtil.AddGlobalTimer(tt + 1, true, function()
      self:StopAudio()
    end)
  end
  def.method().TestTalkRay = function(self)
    local function stop_()
      if self.mSCComp then
        self.mSCComp:StopAudio()
      end
    end
    local function play_(audio)
      stop_()
      if self.mSCComp then
        local _, audioType = ECRecordUtil.getAudioInfo()
        self.mSCComp:PlayAudio(audio:getBytes(), freq, audioType)
      end
    end
    local function download_(url, fullpath)
      ECTalkRay.Instance():DownloadFile(url, fullpath, function(filename, success, downdata)
        if not success then
          warn(("[Audio] Failed Download url:%s"):format(url))
        else
          print(("[Audio] Success Download File:%s"):format(filename))
          if not downdata then
            print(("ReadFile failure filename:%s"):format(filename))
          else
            print("Start Play...")
            play_(downdata)
          end
          self:RemoveAudioFile(filename)
        end
      end)
    end
    local function upload_(audio, fullpath)
      if self:WriteFile(audio, fullpath) then
        ECTalkRay.Instance():UploadFile(fullpath, function(filename, url, success)
          if not success then
            warn(("[Audio] Failed Upload File:%s"):format(filename))
          else
            print(("[Audio] Success Upload File:%s,url:%s"):format(filename, url))
            local downpath = GameUtil.GetAssetsPath() .. "/Audio_arc/andriod_test_down.data"
            download_(url, downpath)
            self:RemoveAudioFile(filename)
          end
        end)
      else
        warn(("[Audio] Failed Write File:%s"):format(fullpath))
      end
    end
    local tt = math.floor(self.endtime - self.begintime)
    MsgBox.ShowMsgBox(nil, self.voicetext .. StringTable.Get(15060) .. ":" .. tt, nil, MsgBox.MsgBoxType.MBBT_OK)
    if not self.voicedata then
      print("self.voicedata invalid")
      return
    end
    local fullpath = GameUtil.GetAssetsPath() .. "/Audio_arc/andriod_test_up.data"
    local osAudio = Octets.Octets()
    osAudio:replace(self.voicedata)
    play_(osAudio)
    print("Start Upload...")
    upload_(osAudio, fullpath)
  end
end
ECSpeechUtil.Commit()
return ECSpeechUtil
