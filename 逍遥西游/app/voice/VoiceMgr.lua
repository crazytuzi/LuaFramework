local VoiceMgr = class("VoiceMgr")
Baidu_Voice_Appkey = "jgfVO8vnljvsjG7cveXP1ph2"
Baidu_Voice_Secretkey = "NsbxIHps87DbQLFFux5cjw00tKUIjczB"
Baidu_Voice_SampleRateInHz = 16000
local AccessToken_URL = "https://192.168.1.102/oauth/2.0/token"
local Recognize_URL = "http://192.168.1.102/server_api"
local OpenUDID = device.getOpenUDID()
local MinRecognizeTime = 2
local MaxRecognizeTime = 12
local MinVolumeDb = 30
local VolumnShowRange = {25, 60}
local Static_Sound_Data = "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"
function VoiceMgr:ctor()
  self.m_VoiceDataString = ""
  self.m_VoiceDataTimeSec = 0
  self.m_VoiceDataLen = 0
  self.m_IsRecognizing = false
  self.m_RecognizListener = nil
  self.m_RecognizeUpdateTimer = 0
  self.m_StopRecognizeListener = nil
  VoiceInter.setMessageListener(handler(self, self.MessageCallBack))
  self:InitSDK()
  self.m_RecognizChannel = nil
  self.m_RecognizeNormalObj = nil
  self.m_RecognizeVolumnNum = 7
  self.m_RecognizeVolumnObjs = nil
  self.m_RecognizeVolomnShowDb = {
    1,
    10,
    20,
    25,
    30,
    45,
    80
  }
  dump(self.m_RecognizeVolomnShowDb, "self.m_RecognizeVolomnShowDb")
  self.m_NeedDownloadVoiceData = {}
  self.m_NeedDownloadVoiceDataIdx = 0
  self.m_DownloadVoiceDataHadPlayedIdx = 0
  self.m_LastVolumn = 0
  self.m_IsUpdateVolumn = false
  self.m_VolumnUpdateTimer = 0
  self.m_UpdateHandler = scheduler.scheduleGlobal(handler(self, self.updateFrame), 0.1)
  MessageEventExtend.extend(self)
  self:ListenMessage(MsgID_Device)
end
function VoiceMgr:OnMessage(msgSID, ...)
  if msgSID == MsgID_EnterBackground then
    print("----> 退后台，取消录音")
    self:ButtonReqCancel()
  end
end
function VoiceMgr:InitSDK()
  VoiceInter.InitSDK(Baidu_Voice_Appkey, Baidu_Voice_Secretkey)
  VoiceInter.enableGetVoiceVolumn(true)
end
function VoiceMgr:MessageCallBack(data, isSucceed)
  print("MessageCallBack:", data, isSucceed)
  if data == nil then
    printLog("ERROR", "回调参数出错")
    return
  end
  local typ = checkint(data.type)
  local param = data.param
  print([[


 typ:]], typ)
  if typ == 1 then
    print("-->> 初始化出错，结束录音")
    self:_recognizeEnd()
    self:_recognizeFinish(2)
  elseif typ == 2 then
    print("-->> 开始说话")
    self.m_VoiceDataString = ""
    self.m_VoiceDataTimeSec = 0
    self:_recognizeFinish(1)
  elseif typ == 3 then
    print("-->> 获取到数据")
  elseif typ == 4 then
    print("-->> 录音完成")
    self:_recognizeEnd()
    self.m_VoiceDataString = param.data
    self.m_VoiceDataTimeSec = param.timeSec
    self:_recognizeFinish(8)
  elseif typ == 5 then
    print("-->> 识别出错")
    self:_recognizeEnd()
    self:_recognizeFinish(2)
  elseif typ == 6 then
    print("-->> 识别成功 ")
    self:_recognizeEnd()
    self:_recognizeFinish(0, param)
  elseif typ == 7 then
    print("-->> 说话过短 ")
    self:_recognizeEnd()
    self:_recognizeFinish(3)
  elseif typ == 8 then
    print("-->> 更新音量 ")
    self:_recognizeFinish(5, param)
  elseif typ == 9 then
    print("-->> 音量过低不识别")
    self:_recognizeEnd()
    self:_recognizeFinish(6)
  elseif typ == 10 then
    print("-->> 底层异常")
    self:_recognizeEnd()
    self:_recognizeFinish(2)
  elseif typ == 11 then
    print("-->> 网络异常")
    self:_recognizeEnd()
    self:_recognizeFinish(2)
  elseif typ == 12 then
    print("-->> 手动取消识别")
    self:_recognizeEnd()
    self:_recognizeFinish(7)
  end
end
function VoiceMgr:getLastRecordData()
  return self.m_VoiceDataString
end
function VoiceMgr:getLastRecordTime()
  return self.m_VoiceDataTimeSec
end
function VoiceMgr:startRecognize(listener)
  if self.m_IsRecognizing == true then
    if listener then
      listener(-1)
    end
    return false
  end
  self.m_IsRecognizing = true
  self.m_RecognizeUpdateTimer = 0
  self:startSchedulerGetVolumn()
  self.m_RecognizListener = listener
  VoiceInter.startRecognize(Baidu_Voice_SampleRateInHz)
  return true
end
function VoiceMgr:_recognizeEnd()
  self.m_IsRecognizing = false
  self:stopSchedulerGetVolumn()
end
function VoiceMgr:_recognizeFinish(result, param)
  if self.m_RecognizListener then
    self.m_RecognizListener(result, param)
  end
end
function VoiceMgr:startSchedulerGetVolumn()
  self.m_IsUpdateVolumn = true
  self.m_LastVolumn = -1
  self.m_VolumnUpdateTimer = 0
  VoiceInter.enableGetVoiceVolumn(true)
end
function VoiceMgr:stopSchedulerGetVolumn()
  self.m_IsUpdateVolumn = false
  VoiceInter.enableGetVoiceVolumn(false)
end
function VoiceMgr:updateFrame(dt)
  if self.m_IsUpdateVolumn then
    self.m_VolumnUpdateTimer = self.m_VolumnUpdateTimer + dt
    if self.m_VolumnUpdateTimer >= 1 then
      local v = VoiceInter.getCurrentDBLevelMeter()
      if v ~= nil and v ~= self.m_LastVolumn then
        self.m_LastVolumn = v
        self:MessageCallBack({
          type = 8,
          param = {v = v}
        }, true)
      end
      self.m_VolumnUpdateTimer = 0
    end
  end
  if self.m_IsRecognizing then
    self.m_RecognizeUpdateTimer = self.m_RecognizeUpdateTimer + dt
    if self.m_RecognizeUpdateTimer >= MaxRecognizeTime then
      self.m_RecognizeUpdateTimer = 0
      self:ButtonReqStop()
    end
  end
end
function VoiceMgr:playPCMString(pcmString, yyid, time, callback, channel, param)
  local typ = type(pcmString)
  if typ == "string" then
    self:ClearDownloadVoiceData()
    return self:playPCMString_(pcmString, yyid, time, callback, channel, param)
  elseif typ == "table" then
    self:downloadNewVoiceData(pcmString, yyid, time, callback, channel, param)
  end
  return false
end
function VoiceMgr:playPCMString_(pcmString, yyid, time, callback, channel, param)
  print("---->>>>>playPCMString:", yyid)
  if self.m_IsRecognizing then
    if self.m_CacheAutoPlayVoiceParam == nil then
      self.m_CacheAutoPlayVoiceParam = {yyid, true}
    end
    return false
  end
  if pcmString == nil then
    print(" pcmString == nil")
    return false
  end
  if self.m_PlayVoiceId ~= nil and self.m_PlayVoiceId == yyid then
    return
  end
  self:lastPCMStringFinish(self.m_PlayVoiceId)
  self:_stopAllSound()
  self.m_PlayVoiceId = yyid
  if time == nil then
    time = 0
  end
  time = math.max(1, time + 1)
  local autoVoiceCheck = g_MessageMgr:setReadPlayVoice(yyid, channel, param)
  self.m_PlayFinishCallBack = callback
  self.m_PlayScheduler = scheduler.performWithDelayGlobal(function()
    self:_resumnAllSound()
    self:lastPCMStringFinish(yyid)
    if autoVoiceCheck then
      g_MessageMgr:checkAutoPlayVoice(yyid)
    end
  end, time)
  self.m_IsAutoVoiceCheck = autoVoiceCheck
  SendMessage(MsgID_Voice_Play, self.m_PlayVoiceId)
  return VoiceInter.playPCMString(pcmString, Baidu_Voice_SampleRateInHz)
end
function VoiceMgr:downloadNewVoiceData(pcmString, yyid, time, callback, channel, param)
  local savePathAndName, bucket, md5String = unpack(pcmString, 1, 3)
  if savePathAndName == nil or bucket == nil or md5String == nil then
    return
  end
  self.m_NeedDownloadVoiceDataIdx = self.m_NeedDownloadVoiceDataIdx + 1
  self.m_NeedDownloadVoiceData[md5String] = {
    self.m_NeedDownloadVoiceDataIdx,
    yyid,
    time,
    callback,
    channel,
    param
  }
  g_VoiceOssInter:DownlaodVoiceData(bucket, savePathAndName, md5String, handler(self, self.DownVoiceDataListener))
end
function VoiceMgr:DownVoiceDataListener(isSucceed, pcmData, md5String)
  if isSucceed then
    local dataInfo = self.m_NeedDownloadVoiceData[md5String]
    if dataInfo then
      local idx, yyid, time, callback, channel, param = unpack(dataInfo, 1, 6)
      if idx >= self.m_NeedDownloadVoiceDataIdx then
        self.m_NeedDownloadVoiceDataIdx = idx
        self:playPCMString_(pcmData, yyid, time, callback, channel, param)
      end
    end
  else
  end
end
function VoiceMgr:ClearDownloadVoiceData()
  self.m_NeedDownloadVoiceData = {}
  self.m_NeedDownloadVoiceDataIdx = 0
  self.m_DownloadVoiceDataHadPlayedIdx = 0
end
function VoiceMgr:lastPCMStringFinish(yyid)
  if self.m_PlayFinishCallBack ~= nil then
    self.m_PlayFinishCallBack(yyid)
    self.m_PlayFinishCallBack = nil
  end
  if self.m_PlayScheduler ~= nil then
    scheduler.unscheduleGlobal(self.m_PlayScheduler)
    self.m_PlayScheduler = nil
  end
  self.m_PlayVoiceId = nil
  self.m_IsAutoVoiceCheck = nil
  SendMessage(MsgID_Voice_Stop, yyid)
end
function VoiceMgr:isPlayingPCMString()
  return self.m_PlayVoiceId ~= nil
end
function VoiceMgr:playStaticVoiceWhileStartRecord()
  if self.m_PlayVoiceId ~= nil then
    self.m_CacheAutoPlayVoiceParam = {
      self.m_PlayVoiceId,
      self.m_IsAutoVoiceCheck
    }
    self:lastPCMStringFinish(self.m_PlayVoiceId)
  else
    self.m_CacheAutoPlayVoiceParam = nil
  end
  VoiceInter.playPCMString(Static_Sound_Data, 16000)
end
function VoiceMgr:resumeAutoPlayStatus()
  print("resumeAutoPlayStatus----->>>")
  dump(self.m_CacheAutoPlayVoiceParam, "m_CacheAutoPlayVoiceParam")
  if type(self.m_CacheAutoPlayVoiceParam) ~= "table" then
    return
  end
  local playVoiceId = self.m_CacheAutoPlayVoiceParam[1]
  local autoCheck = self.m_CacheAutoPlayVoiceParam[2]
  print("playVoiceId, autoCheck:", playVoiceId, autoCheck)
  if playVoiceId ~= nil and autoCheck then
    g_MessageMgr:checkAutoPlayVoice(playVoiceId)
  end
  self.m_CacheAutoPlayVoiceParam = nil
end
function VoiceMgr:ButtonReqStartRecord(stopListener, chatChannel, param)
  local ret = self:startRecognize(handler(self, self.RecordCallback))
  if ret ~= true then
    return false
  end
  self:playStaticVoiceWhileStartRecord()
  self.m_RecognizChannel = chatChannel
  self.m_StopRecognizeListener = stopListener
  self.m_RecognizParam = param
  self:setRecognizeVolumn(0)
  self:setShowRecognizeNormal(true)
  self:_stopAllSound()
  return true
end
function VoiceMgr:_stopAllSound()
  self.m_soundsVolume = audio.getSoundsVolume()
  self.m_musicVolume = audio.getMusicVolume()
  soundManager.DisabledSoundTemp()
  soundManager.pauseMusic()
end
function VoiceMgr:_resumnAllSound()
  if g_DataMgr and g_DataMgr.m_IsBackGroud ~= true then
    soundManager.resumeSoundTemp()
    audio.resumeMusic()
    if self.m_soundsVolume ~= nil then
      audio.setSoundsVolume(1)
      self.m_soundsVolume = nil
    end
    if self.m_musicVolume ~= nil then
      audio.setMusicVolume(1)
      self.m_musicVolume = nil
    end
  end
end
function VoiceMgr:RecordCallback(typ, param)
  print("--->> callback:", typ)
  if typ == 0 then
    local resultStr = param.result
    local len = #resultStr
    if string.sub(resultStr, len, len) == "," then
      resultStr = string.sub(resultStr, 1, len - 1)
    end
    self:SendRecognize(resultStr, self:getLastRecordData(), self:getLastRecordTime(), 0)
  elseif typ == 1 then
    print("开始说话")
  elseif typ == 3 then
    self:setShowRecognizeTimeShortage()
  elseif typ == 4 then
  elseif typ == 5 then
    local v = param.v
    self:setRecognizeVolumn(v)
  elseif typ == 6 then
    self:setShowRecognizeVolumnTooLow()
  elseif typ == 8 then
    self:setShowRecognizeNormal(false)
    self:setShowRecognizeWaitingCancel(false)
    self:_resumnAllSound()
  elseif typ ~= 2 and typ ~= -1 and typ ~= 7 then
    self:SendRecognize("[语音无法识别!]", self:getLastRecordData(), self:getLastRecordTime(), 0)
  end
  if typ ~= 1 and typ ~= 5 then
    if self.m_StopRecognizeListener then
      self.m_StopRecognizeListener()
    end
    self:setShowRecognizeNormal(false)
    self:setShowRecognizeWaitingCancel(false)
    if self:isPlayingPCMString() ~= true then
      self:_resumnAllSound()
    end
    self:resumeAutoPlayStatus()
  end
end
function VoiceMgr:SendRecognize(txt, pcmString, timeSec, recognizeType)
  print("-->>SendRecognize：", self.m_RecognizChannel, txt, timeSec, recognizeType)
  print("-->> pcmString len:", #pcmString)
  local canUpload, savePathAndName, bucket, md5Str = g_VoiceOssInter:UploadVoiceData(pcmString, nil)
  if canUpload ~= true then
    AwardPrompt.addPrompt("识别失败，请重新录音")
    return
  end
  local yyData = {
    voice = {
      savePathAndName,
      bucket,
      md5Str
    },
    time = timeSec,
    rec = recognizeType
  }
  if self.m_RecognizChannel == CHANNEL_FRIEND then
    g_MessageMgr:sendPrivateMessage(self.m_RecognizParam, txt, yyData)
  elseif self.m_RecognizChannel == CHANNEL_TEAM then
    g_MessageMgr:sendTeamMessage(txt, yyData)
  elseif self.m_RecognizChannel == CHANNEL_BP_MSG then
    g_MessageMgr:sendBangPaiMessage(txt, yyData)
  elseif self.m_RecognizChannel == CHANNEL_WOLRD then
    g_MessageMgr:sendWorldMessage(txt, yyData)
  elseif self.m_RecognizChannel == CHANNEL_LOCAL then
    g_MessageMgr:sendLocalMessage(txt, yyData)
  else
    print("---->> 找不到对应的频道号:", type(self.m_RecognizChannel), self.m_RecognizChannel)
  end
end
function VoiceMgr:ButtonReqStop()
  print("------>>> 语言识别正常结束")
  self:onVoiceFinish()
  VoiceInter.stopRecord()
end
function VoiceMgr:ButtonReqCancel()
  print("------>>> 取消语言识别")
  self:onVoiceFinish()
  VoiceInter.cancelRecord()
end
function VoiceMgr:ButtonReqTouchInsize()
  print("------>>> 移动手指从外面回到按钮范围内")
  self:setShowRecognizeNormal(true)
  self:setShowRecognizeWaitingCancel(false)
end
function VoiceMgr:ButtonReqTouchOutsize()
  print("------>>> 移动手指到按钮范围外")
  self:setShowRecognizeNormal(false)
  self:setShowRecognizeWaitingCancel(true)
end
function VoiceMgr:setButtonStopRecognize()
  if self.m_StopRecognizeListener then
    self.m_StopRecognizeListener()
  end
end
function VoiceMgr:onVoiceFinish()
  self:setShowRecognizeNormal(false)
  self:setShowRecognizeWaitingCancel(false)
  self:_resumnAllSound()
end
function VoiceMgr:setShowRecognizeNormal(isShow)
  if isShow then
    if self.m_RecognizeNormalObj == nil then
      self.m_RecognizeNormalObj = display.newSprite("xiyou/voice/pic_voicestatus_normal.png")
      addNodeToTopLayer(self.m_RecognizeNormalObj, TopLayerZ_VoiceRecognize)
      self.m_RecognizeNormalObj:setAnchorPoint(ccp(0.5, 0.5))
      self.m_RecognizeNormalObj:setPosition(display.width / 2, display.height / 2)
      local x = 147
      local y = 91
      local dx = 0
      local dy = 2
      self.m_RecognizeVolumnObjs = {}
      local num = self.m_RecognizeVolumnNum
      for i = 1, num do
        local p = display.newSprite("xiyou/voice/pic_voicestatus_volumn.png")
        p:setVisible(false)
        p:setAnchorPoint(ccp(0, 0))
        local s = p:getContentSize()
        local w = s.width
        p:setScaleX((w - (num - i)) / w)
        p:setPosition(x, y)
        x = x + dx
        y = y + dy + s.height
        self.m_RecognizeNormalObj:addChild(p)
        self.m_RecognizeVolumnObjs[i] = p
      end
    else
      self.m_RecognizeNormalObj:setVisible(true)
    end
  elseif self.m_RecognizeNormalObj then
    self.m_RecognizeNormalObj:setVisible(false)
  end
end
function VoiceMgr:setRecognizeVolumn(db)
  print("\t\t setRecognizeVolumn:", db)
  if self.m_RecognizeVolumnObjs then
    for i = 1, self.m_RecognizeVolumnNum do
      print("\t\t\t\t db, show:", db, self.m_RecognizeVolomnShowDb[i], db >= self.m_RecognizeVolomnShowDb[i])
      self.m_RecognizeVolumnObjs[i]:setVisible(db >= self.m_RecognizeVolomnShowDb[i])
    end
  end
end
function VoiceMgr:setShowRecognizeWaitingCancel(isShow)
  if isShow then
    if self.m_RecognizeWaitCancelObj == nil then
      self.m_RecognizeWaitCancelObj = display.newSprite("xiyou/voice/pic_voicestatus_waitcancel.png")
      addNodeToTopLayer(self.m_RecognizeWaitCancelObj, TopLayerZ_VoiceRecognize)
      self.m_RecognizeWaitCancelObj:setAnchorPoint(ccp(0.5, 0.5))
      self.m_RecognizeWaitCancelObj:setPosition(display.width / 2, display.height / 2)
    else
      self.m_RecognizeWaitCancelObj:setVisible(true)
    end
  elseif self.m_RecognizeWaitCancelObj then
    self.m_RecognizeWaitCancelObj:setVisible(false)
  end
end
function VoiceMgr:setShowRecognizeTimeShortage()
  if self.m_RecognizeTimeShortageObj == nil then
    self.m_RecognizeTimeShortageObj = display.newSprite("xiyou/voice/pic_voicestatus_timeshortage.png")
    addNodeToTopLayer(self.m_RecognizeTimeShortageObj, TopLayerZ_VoiceRecognize)
    self.m_RecognizeTimeShortageObj:setAnchorPoint(ccp(0.5, 0.5))
    self.m_RecognizeTimeShortageObj:setPosition(display.width / 2, display.height / 2)
  end
  self.m_RecognizeTimeShortageObj:setVisible(true)
  local action1 = CCDelayTime:create(1)
  local action2 = CCHide:create()
  self.m_RecognizeTimeShortageObj:runAction(transition.sequence({action1, action2}))
end
function VoiceMgr:setShowRecognizeVolumnTooLow()
  if self.m_RecognizeTimeVolumnTooLowObj == nil then
    self.m_RecognizeTimeVolumnTooLowObj = display.newSprite("xiyou/voice/pic_voicestatus_volumntoolow.png")
    addNodeToTopLayer(self.m_RecognizeTimeVolumnTooLowObj, TopLayerZ_VoiceRecognize)
    self.m_RecognizeTimeVolumnTooLowObj:setAnchorPoint(ccp(0.5, 0.5))
    self.m_RecognizeTimeVolumnTooLowObj:setPosition(display.width / 2, display.height / 2)
  end
  self.m_RecognizeTimeVolumnTooLowObj:setVisible(true)
  local action1 = CCDelayTime:create(1)
  local action2 = CCHide:create()
  self.m_RecognizeTimeVolumnTooLowObj:runAction(transition.sequence({action1, action2}))
end
function VoiceMgr:Clean()
  self.m_StopRecognizeListener = nil
  if self.m_RecognizeNormalObj then
    self.m_RecognizeNormalObj:removeSelf()
    self.m_RecognizeNormalObj = nil
    self.m_RecognizeVolumnObjs = nil
  end
  if self.m_RecognizeTimeShortageObj then
    self.m_RecognizeTimeShortageObj:removeSelf()
    self.m_RecognizeTimeShortageObj = nil
  end
  if self.m_RecognizeTimeVolumnTooLowObj then
    self.m_RecognizeTimeVolumnTooLowObj:removeSelf()
    self.m_RecognizeTimeVolumnTooLowObj = nil
  end
  if self.m_RecognizeWaitCancelObj then
    self.m_RecognizeWaitCancelObj:removeSelf()
    self.m_RecognizeWaitCancelObj = nil
  end
  if self.m_PlayScheduler ~= nil then
    scheduler.unscheduleGlobal(self.m_PlayScheduler)
    self.m_PlayScheduler = nil
  end
  if self.m_UpdateHandler then
    scheduler.unscheduleGlobal(self.m_UpdateHandler)
    self.m_UpdateHandler = nil
  end
  self:RemoveAllMessageListener()
end
g_VoiceMgr = VoiceMgr.new()
gamereset.registerResetFunc(function()
  g_VoiceMgr:Clean()
  g_VoiceMgr = VoiceMgr.new()
end)
