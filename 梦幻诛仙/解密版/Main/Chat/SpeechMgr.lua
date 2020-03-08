local Lplus = require("Lplus")
local SpeechMgr = Lplus.Class("SpeechMgr")
local def = SpeechMgr.define
local ChatModule = Lplus.ForwardDeclare("ChatModule")
local json = require("Utility.json")
local SpeechTip = require("Main.Chat.ui.SpeechTip")
local SystemSettingModule = require("Main.SystemSetting.SystemSettingModule")
local instance
def.field("number").curChannel = -1
def.field("userdata").curRoleId = nil
def.field("userdata").m_GroupId = nil
def.field("table").voiceQueue = nil
def.field("table").audioFirstMap = nil
def.const("table").AudioFirstSetting = {
  [1] = 2000,
  [2] = 2000,
  [3] = 2000,
  [4] = 2000,
  [5] = 2000,
  [13] = 2000,
  ["private"] = 2000
}
def.static("=>", SpeechMgr).Instance = function()
  if instance == nil then
    instance = SpeechMgr()
    instance.voiceQueue = {}
    instance.audioFirstMap = {}
  end
  return instance
end
if not ClientCfg.IsSurportApollo() then
  do
    local ECSpeechUtil = require("Chat.ECSpeechUtil")
    local ECRecordUtil = require("Chat.ECRecordUtil")
    def.field("string").playing = ""
    def.method().Init = function(self)
      local setting = SystemSettingModule.Instance():GetSetting(SystemSettingModule.SystemSetting.VoiceSound)
      local volume = setting.mute and 0 or setting.volume
      self:SetVoiceVolume(volume)
      self.playing = ""
    end
    def.method("number").SetVoiceVolume = function(self, vol)
      ECSpeechUtil.Instance():SetVoiceVolume(vol)
    end
    def.method("string", "number").PlayInQueue = function(self, fileId, sec)
      table.insert(self.voiceQueue, {fileId, sec})
      if self.playing ~= "" then
        return
      else
        self:_playInQueue()
      end
    end
    def.method("string", "number").PlayInterrupt = function(self, fileId, sec)
      self.voiceQueue = {}
      self:_play(fileId, sec)
    end
    def.method()._playInQueue = function(self)
      if self.voiceQueue ~= nil and #self.voiceQueue > 0 then
        local voice = self.voiceQueue[1]
        local fileId = voice[1]
        local sec = voice[2]
        table.remove(self.voiceQueue, 1)
        self:_play(fileId, sec)
      end
    end
    def.method("string", "number", "boolean")._play = function(self, fileId, second, toastErr)
      if self.playing == fileId then
        ECSpeechUtil.Instance():StopAudio()
        self.playing = ""
      end
      self.playing = fileId
      local outPutPath = GameUtil.GetAssetsPath() .. "/Audio_arc/tempvoice.data"
      fileId = _NormalizeHttpURL(fileId)
      ECSpeechUtil.Instance():DownloadVoice(fileId, outPutPath, second, function()
        self.playing = ""
        self:_playInQueue()
      end)
    end
    local postIdGen = 0
    def.method("=>", "boolean").StartSpeech = function(self)
      local function OnFinish(speech)
        SpeechTip.Instance():Close()
        local timelapse = speech.endtime - speech.begintime
        postIdGen = postIdGen + 1
        local postId_ = tostring(postIdGen)
        local _, audioType = ECRecordUtil.getAudioInfo()
        local data = {
          audioType = audioType,
          audio = speech.voicedata
        }
        warn("ECRecordUtil.Instance():doHttpPost")
        ECRecordUtil.Instance():doHttpPost(postId_, data, function(success, url, postId, retdata)
          if not success or url == nil or url == "" then
            Toast(textRes.Voice[3])
          else
            local json = require("Utility.json")
            local result = json.decode(retdata.string)
            warn("Speech text:", result.text)
            warn("Speech url:", result.url)
            warn("Speech time:", timelapse)
            local text = _G.ClientCfg.IsSpeechTranslate() and (result.text or "") or "nil"
            self:SendSpeech(result.url, timelapse, text)
          end
        end)
      end
      local function OnVoiceChange(speech, volume)
        SpeechTip.Instance():Voice(volume / 50)
      end
      local ret = ECSpeechUtil.Instance():RecordVoice(OnFinish, OnVoiceChange)
      if ret then
        SpeechTip.Instance():Open()
      end
      warn("StartSpeech")
      return ret
    end
    def.method().EndSpeech = function(self)
      warn("EndSpeech")
      GameUtil.AddGlobalTimer(0.5, true, function()
        SpeechTip.Instance():Close()
        ECSpeechUtil.Instance():StopVoice()
      end)
    end
    def.method().CancelSpeech = function(self)
      warn("CancelSpeech")
      local function OnCancel()
        SpeechTip.Instance():Close()
      end
      ECSpeechUtil.Instance():CancelVoice(OnCancel)
    end
  end
elseif Apollo and Apollo.Dummy then
  do
    local ECApolloVoiceChat = require("ProxySDK.ECApolloVoiceChat")
    def.method().Init = function(self)
      if ECApolloVoiceChat.Instance():Init() then
        local setting = SystemSettingModule.Instance():GetSetting(SystemSettingModule.SystemSetting.VoiceSound)
        local volume = setting.mute and 0 or setting.volume
        self:SetVoiceVolume(volume)
        ECApolloVoiceChat.Instance():RequestServiceInfo()
        ECApolloVoiceChat.Instance():RegisterVolumeUpdate(SpeechMgr.volumeCallback)
        ECApolloVoiceChat.Instance():RegisterRecordResult(SpeechMgr.recordCallback)
        ECApolloVoiceChat.Instance():RegisterPlayFinishCallback(SpeechMgr.playCallback)
      end
    end
    def.static("number").volumeCallback = function(volume)
      SpeechTip.Instance():Voice(volume)
    end
    def.static("number", "string", "number", "string").recordCallback = function(ret, fileId, time, text)
      if ret == 0 then
        SpeechTip.Instance():Close()
        instance:SendSpeech(fileId, time, text)
      elseif ret == -10 then
        SpeechTip.Instance():Close()
        instance:SendSpeechWithoutText(fileId, time)
      elseif ret == -11 then
        instance:SendSpeech(fileId, time, text)
      elseif ret == -5 then
        SpeechTip.Instance():Close()
        Toast(textRes.Chat.ApolloError[3])
        instance:SendSpeech(fileId, time, text)
      else
        SpeechTip.Instance():Close()
        Toast(textRes.Chat.ApolloError[8])
      end
    end
    def.static("number", "string").playCallback = function(ret, fileId)
      if ret == 0 then
        instance:_playInQueue()
      elseif ret ~= -4 then
        Toast(textRes.Chat.ApolloError[7])
      end
    end
    def.method("number").SetVoiceVolume = function(self, vol)
      local ret = ECApolloVoiceChat.Instance():SetSpeakerVolume(vol)
      if ret ~= 0 then
      end
    end
    def.method("string", "number").PlayInQueue = function(self, fileId, sec)
      table.insert(self.voiceQueue, {fileId, sec})
      if not ECApolloVoiceChat.Instance():IsAvailable() or ECApolloVoiceChat.Instance():IsPlaying() then
        return
      else
        self:_playInQueue()
      end
    end
    def.method("string", "number").PlayInterrupt = function(self, fileId, sec)
      self.voiceQueue = {}
      self:_play(fileId, sec, true)
    end
    def.method()._playInQueue = function(self)
      if self.voiceQueue ~= nil and #self.voiceQueue > 0 then
        local voice = self.voiceQueue[1]
        local fileId = voice[1]
        local sec = voice[2]
        table.remove(self.voiceQueue, 1)
        self:_play(fileId, sec, false)
      end
    end
    def.method("string", "number", "boolean")._play = function(self, fileId, second, toastErr)
      local ret = ECApolloVoiceChat.Instance():Play(fileId, second)
      if ret ~= 0 then
        if toastErr then
          Toast(textRes.Chat.ApolloError[7])
        end
        self:_playInQueue()
      end
    end
    def.method("=>", "boolean").StartSpeech = function(self)
      local ret = ECApolloVoiceChat.Instance():BeginRecord()
      if ret == 0 then
        SpeechTip.Instance():Open()
        return true
      else
        if ret == -1 then
          Toast(textRes.Chat[74])
        elseif ret == -6 then
          Toast(textRes.Chat.ApolloError[4])
        elseif ret == -8 then
          Toast(textRes.Chat.ApolloError[9])
        else
          Toast(textRes.Chat.ApolloError[2])
        end
        return false
      end
    end
    def.method().EndSpeech = function(self)
      GameUtil.AddGlobalTimer(0.2, true, function()
        local limitTranslateRet = true
        if self.curChannel > 0 then
          local ms = SpeechMgr.AudioFirstSetting[self.curChannel] or -1
          limitTranslateRet = ECApolloVoiceChat.Instance():SetTranslateLimitTime(ms)
        elseif self.curRoleId then
          local ms = SpeechMgr.AudioFirstSetting.private or -1
          limitTranslateRet = ECApolloVoiceChat.Instance():SetTranslateLimitTime(ms)
        elseif self.m_GroupId then
          local ms = SpeechMgr.AudioFirstSetting.private or -1
          limitTranslateRet = ECApolloVoiceChat.Instance():SetTranslateLimitTime(ms)
        else
          local ms = -1
          limitTranslateRet = ECApolloVoiceChat.Instance():SetTranslateLimitTime(ms)
        end
        if limitTranslateRet then
          local ret = ECApolloVoiceChat.Instance():EndRecord()
          if ret == -9 then
            Toast(textRes.Voice[1])
          end
          SpeechTip.Instance():Close()
        else
          self:CancelSpeech()
        end
      end)
    end
    def.method().CancelSpeech = function(self)
      local ret = ECApolloVoiceChat.Instance():CancelRecord()
      if ret ~= 0 then
      end
      SpeechTip.Instance():Close()
      self:ClearInfo()
    end
  end
else
  def.field("string").playing = ""
  def.method().Init = function(self)
  end
  def.method("number").SetVoiceVolume = function(self, vol)
  end
  def.method("string", "number").PlayInQueue = function(self, fileId, sec)
  end
  def.method("string", "number").PlayInterrupt = function(self, fileId, sec)
  end
  def.method()._playInQueue = function(self)
  end
  def.method("string", "number", "boolean")._play = function(self, fileId, second, toastErr)
  end
  def.method("=>", "boolean").StartSpeech = function(self)
    warn("PC:StartSpeech")
    SpeechTip.Instance():Open()
    return true
  end
  def.method().EndSpeech = function(self)
    warn("PC:EndSpeech")
    SpeechTip.Instance():Close()
  end
  def.method().CancelSpeech = function(self)
    warn("PC:CancelSpeech")
    SpeechTip.Instance():Close()
    self:ClearInfo()
  end
end
def.method("boolean").Pause = function(self, pause)
  warn("PC:PauseSpeech", pause)
  SpeechTip.Instance():Pause(pause)
end
def.method("number").SetChannel = function(self, channel)
  self.curChannel = channel
  self.curRoleId = nil
  self.m_GroupId = nil
end
def.method("userdata").SetRole = function(self, roleId)
  self.curRoleId = roleId
  self.curChannel = -1
  self.m_GroupId = nil
end
def.method("userdata").SetGroup = function(self, groupId)
  self.m_GroupId = groupId
  self.curChannel = -1
  self.curRoleId = nil
end
def.method().ClearInfo = function(self)
  self.m_GroupId = nil
  self.curChannel = -1
  self.curRoleId = nil
end
def.method("string", "number", "string").SendSpeech = function(self, fileId, time, text)
  local audioFirst = self.audioFirstMap[fileId]
  if audioFirst then
    self:SendSpeechTranslate(fileId, text, audioFirst.channel, audioFirst.roleId, audioFirst.groupId)
    self.audioFirstMap[fileId] = nil
    return
  end
  local time = math.floor(time / 0.1) / 10
  local data = {}
  data.fileId = fileId
  data.second = time
  data.text = text
  local content = json.encode(data)
  if self.curChannel >= 0 then
    ChatModule.Instance():SendChannelMsg(content, self.curChannel, true)
    self.curChannel = -1
  elseif self.curRoleId then
    ChatModule.Instance():SendPrivateMsg(self.curRoleId, content, true)
    self.curRoleId = nil
  elseif self.m_GroupId then
    ChatModule.Instance():SendGroupChatMsg(self.m_GroupId, content, true)
    self.m_GroupId = nil
  end
end
def.method("string", "number").SendSpeechWithoutText = function(self, fileId, time)
  local time = math.floor(time / 0.1) / 10
  local data = {}
  data.fileId = fileId
  data.second = time
  data.audioOnly = true
  self.audioFirstMap[fileId] = {
    channel = self.curChannel,
    roleId = self.curRoleId,
    groupId = self.m_GroupId
  }
  local content = json.encode(data)
  if self.curChannel >= 0 then
    local ret = ChatModule.Instance():SendChannelMsg(content, self.curChannel, true)
    if not ret then
      self.audioFirstMap[fileId] = nil
    end
    self.curChannel = -1
  elseif self.curRoleId then
    ChatModule.Instance():SendPrivateMsg(self.curRoleId, content, true)
    self.curRoleId = nil
  elseif self.m_GroupId then
    ChatModule.Instance():SendGroupChatMsg(self.m_GroupId, content, true)
    self.m_GroupId = nil
  end
end
def.method("string", "string", "number", "userdata", "userdata").SendSpeechTranslate = function(self, fileId, text, channel, roleId, groupId)
  warn("SendSpeechTranslate", fileId, text, channel, roleId, groupId)
  local data = {}
  data.translate = true
  data.fileId = fileId
  data.text = text
  local content = json.encode(data)
  if channel >= 0 then
    ChatModule.Instance():SendChannelSecret(content, channel)
  elseif roleId then
    ChatModule.Instance():SendPrivateSecret(roleId, content)
  elseif groupId then
    ChatModule.Instance():SendGroupSecrect(groupId, content)
  end
end
def.method("number", "number").TestSpeech1 = function(self, roleIdNumber, channel)
  local timeStr = tostring(os.time())
  if timeStr then
    if roleIdNumber > 0 then
      self.curRoleId = Int64.new(roleIdNumber)
      self:SendSpeech(timeStr, 3, "\233\187\145\231\136\170\228\188\154\233\135\141\229\187\186\228\189\160\231\136\182\228\186\178\231\154\132\229\184\157\229\155\189.")
      self.curRoleId = nil
    elseif channel > 0 then
      self.curChannel = channel
      self:SendSpeech(timeStr, 3, "\233\187\145\231\136\170\228\188\154\233\135\141\229\187\186\228\189\160\231\136\182\228\186\178\231\154\132\229\184\157\229\155\189.")
      self.curChannel = -1
    end
  end
end
def.method("number", "number").TestSpeech2 = function(self, roleIdNumber, channel)
  local timeStr = tostring(GameUtil.GetTickCount() % 65536)
  if timeStr then
    if roleIdNumber > 0 then
      self.curRoleId = Int64.new(roleIdNumber)
      self:SendSpeechWithoutText(timeStr, 3)
      self.curRoleId = nil
      GameUtil.AddGlobalTimer(4, true, function()
        self:SendSpeech(timeStr, 3, "\228\189\134\228\187\163\228\187\183\230\152\175\228\187\128\228\185\136\229\145\162?")
      end)
    elseif channel > 0 then
      self.curChannel = channel
      self:SendSpeechWithoutText(timeStr, 3)
      self.curChannel = -1
      GameUtil.AddGlobalTimer(4, true, function()
        self:SendSpeech(timeStr, 3, "")
      end)
    end
  end
end
SpeechMgr.Commit()
return SpeechMgr
