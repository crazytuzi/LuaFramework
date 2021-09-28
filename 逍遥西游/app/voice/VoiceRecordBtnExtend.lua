local VoiceRecordBtnExtend = {}
function VoiceRecordBtnExtend.extend(btn, chatChannel, paramFetchFunc, touchGray)
  function btn:_VR_Init()
    self._VR_ChatChannel = chatChannel
    self._VR_IsRecording = false
    self._VR_IsTouchInsize = true
    self._VR_ParamFetchFunc = paramFetchFunc
    self._VR_TouchGray = touchGray
    btn:setTouchEnabled(true)
    btn:addTouchEventListener(handler(self, self._VR_TouchEvent))
  end
  function btn:_VR_TouchEvent(touchObj, t)
    print("--->>Event:", t, btn, chatChannel)
    if t == TOUCH_EVENT_BEGAN then
      if self._VR_TouchGray and self.setColor then
        self:setColor(ccc3(180, 180, 180))
      end
      self:_VR_Start()
    elseif t == TOUCH_EVENT_MOVED then
      if self._VR_IsRecording then
        local movePos = self:getTouchMovePos()
        local tx, ty = movePos.x, movePos.y
        local p = self:convertToWorldSpace(ccp(0, 0))
        local s = self:getSize()
        local anchorPoint = self:getAnchorPoint()
        local w = s.width * self:getScaleX()
        local h = s.height * self:getScaleY()
        local isInTouchBtn = true
        local off = 20
        if tx < p.x - w * anchorPoint.x - off or tx > p.x + w * anchorPoint.x + off or ty < p.y - h * anchorPoint.y - off or ty > p.y + h * anchorPoint.y + off then
          isInTouchBtn = false
        end
        self:_VR_TouchOutsizeChanged(isInTouchBtn)
      end
    elseif t == TOUCH_EVENT_ENDED or t == TOUCH_EVENT_CANCELED then
      if self._VR_TouchGray and self.setColor then
        self:setColor(ccc3(255, 255, 255))
      end
      if self._VR_IsRecording then
        if self._VR_IsTouchInsize then
          g_VoiceMgr:ButtonReqStop()
        else
          g_VoiceMgr:ButtonReqCancel()
        end
      end
    end
    if not self._VR_IsRecording then
      local isTouch = self:isTouchEnabled()
      if isTouch then
        self:setTouchEnabled(false)
        self:setTouchEnabled(true)
      end
    end
  end
  function btn:_VR_Start()
    local param
    if self._VR_ParamFetchFunc then
      param = self._VR_ParamFetchFunc()
    end
    if self._VR_ChatChannel == CHANNEL_TEAM then
      local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Duiwu)
      if not openFlag then
        self._VR_IsRecording = false
        ShowNotifyTips(tips)
        return
      end
      if g_TeamMgr:getLocalPlayerTeamId() == 0 then
        self._VR_IsRecording = false
        ShowNotifyTips("组队后才能在队伍频道里聊天")
        return
      end
    elseif self._VR_ChatChannel == CHANNEL_BP_MSG then
      local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_BangPai)
      if not openFlag then
        self._VR_IsRecording = false
        ShowNotifyTips(tips)
        return
      end
      if not g_BpMgr:localPlayerHasBangPai() then
        self._VR_IsRecording = false
        ShowNotifyTips("入帮后才可在帮派频道里聊天")
        return
      end
    elseif self._VR_ChatChannel == CHANNEL_WOLRD then
      local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_WorldChat)
      if not openFlag then
        self._VR_IsRecording = false
        ShowNotifyTips(tips)
        return
      end
    elseif self._VR_ChatChannel == CHANNEL_LOCAL then
      local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_LocalChat)
      if not openFlag then
        self._VR_IsRecording = false
        ShowNotifyTips(tips)
        return
      end
    end
    if g_VoiceMgr:ButtonReqStartRecord(handler(self, self._VR_HadStop), self._VR_ChatChannel, param) then
      print("----->> 开始语言识别", self._VR_ChatChannel)
      self._VR_IsRecording = true
      self._VR_IsTouchInsize = true
    else
      self._VR_IsRecording = false
    end
  end
  function btn:_VR_HadStop()
    self._VR_IsRecording = false
  end
  function btn:_VR_TouchOutsizeChanged(isInTouchBtn)
    if self._VR_IsTouchInsize ~= isInTouchBtn then
      self._VR_IsTouchInsize = isInTouchBtn
      if self._VR_IsTouchInsize then
        g_VoiceMgr:ButtonReqTouchInsize()
      else
        g_VoiceMgr:ButtonReqTouchOutsize()
      end
    end
  end
  btn:_VR_Init()
end
return VoiceRecordBtnExtend
