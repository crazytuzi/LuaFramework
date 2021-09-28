TEXTFIELDEXTEND_EVENT_ATTACH_WITH_IME = 0
TEXTFIELDEXTEND_EVENT_DETACH_WITH_IME = 1
TEXTFIELDEXTEND_EVENT_TEXT_CHANGE = 2
TEXTFIELDEXTEND_EVENT_SEND_TEXT = 3
TEXTFIELD_EVENT_ATTACH_WITH_IME = 0
TEXTFIELD_EVENT_DETACH_WITH_IME = 1
TEXTFIELD_EVENT_INSERT_TEXT = 2
TEXTFIELD_EVENT_DELETE_BACKWARD = 3
kKeyboardReturnTypeDefault = 0
kKeyboardReturnTypeDone = 1
kKeyboardReturnTypeSend = 2
kKeyboardReturnTypeSearch = 3
kKeyboardReturnTypeGo = 4
Define_OpenSpeedKeyboard = 0.25
Define_CloseSpeedKeyboard = 0.15
TextFieldOpenCloseExtend = {}
function TextFieldOpenCloseExtend.extend(object, adjustLayer)
  function object:_onKeyBoardEventListener(obj, event)
    print("-->>_onKeyBoardEventListener", tostring(obj), event)
    if event == TEXTFIELD_EVENT_DETACH_WITH_IME then
      print("--->>>键盘关闭", tostring(object))
      if not object.m_SysKeyBoardOpen then
        return
      end
      print("--->>>键盘关闭2", tostring(object))
      object.m_SysKeyBoardOpen = false
      object:_setOpenCnt(object.m_OpenCnt - 1)
      object:_recoverHeight()
      object:didNotSelectSelf()
    elseif event == TEXTFIELD_EVENT_INSERT_TEXT then
      object._CheckEnterIsLegal()
      object:_OnEnterChanged()
      object.m_OldEnterText = object:getStringValue()
    elseif event == TEXTFIELD_EVENT_DELETE_BACKWARD then
      object:_OnEnterChanged()
      object.m_OldEnterText = object:getStringValue()
    elseif event == TEXTFIELD_EVENT_ATTACH_WITH_IME then
      print("--->>>键盘打开", tostring(object))
      if object.m_SysKeyBoardOpen then
        return
      end
      print("--->>>键盘打开2", tostring(object))
      object.m_SysKeyBoardOpen = true
      SendMessage(MsgID_KeyBoard_SysShow)
      object:_setOpenCnt(object.m_OpenCnt + 1)
      object:_onKeyboardOpen()
      object.m_OldEnterText = object:getStringValue()
    end
  end
  function object:_onKeyBoardEventListener_Android(param)
    print("---->>>>安卓键盘特殊消息:", param)
    if param and param.k_s == 0 then
      object:_onKeyBoardEventListener(object, TEXTFIELD_EVENT_DETACH_WITH_IME)
    end
  end
  function object:_CheckEnterIsLegal()
    local newText = object:getStringValue()
    local newLen = string.len(newText)
    local oldText = object.m_OldEnterText
    local oldLen = string.len(oldText)
    local diffIdx
    for i = 1, newLen do
      if i > oldLen then
        diffIdx = oldLen + 1
        break
      else
        local nchar = string.sub(newText, i, i)
        local ochar = string.sub(object.m_OldEnterText, i, i)
        if nchar ~= ochar then
          diffIdx = i
          break
        end
      end
    end
    if diffIdx == nil then
      return
    end
    local addStr = string.sub(newText, diffIdx, newLen)
    local text, validFlag = CheckStringIsLegal(addStr, object.m_EnableChinese, "")
    if validFlag == false then
      if diffIdx > 1 then
        local oldStr = string.sub(newText, 1, diffIdx - 1)
        text = string.format("%s%s", oldStr, text)
      end
      object:setText(text)
    end
  end
  function object:_OnEnterChanged()
    if object._OnEnterChangedEx then
      object._OnEnterChangedEx()
    end
    if object.m_KeyBoardListener then
      object.m_KeyBoardListener(TEXTFIELDEXTEND_EVENT_TEXT_CHANGE)
    end
  end
  function object:_onKeyboardOpen()
    local keyboardHeight = display.height * 0.75
    local act1 = CCDelayTime:create(0.05)
    local act2 = CCCallFunc:create(function()
      if object.m_OpenCnt > 0 then
        object:_AdjustHeight(keyboardHeight)
      end
    end)
    object:runAction(transition.sequence({act1, act2}))
  end
  function object:_AdjustHeight(keyboardHeight)
    if keyboardHeight ~= nil then
      object.m_KeyBoardHeight = keyboardHeight
    end
    object.m_MsgCaptureLayer:setTouchEnabled(true)
    local scene = object.m_AdjustLayer
    local pos
    local mx = 0
    if scene == nil then
      scene = display.getRunningScene()
    else
      local oriPos = scene.__oriPos
      mx = oriPos.x
    end
    local _, sy = scene:getPosition()
    if object.m_Cursor == nil then
      local size = object:getContentSize()
      local ap = object:getAnchorPoint()
      pos = object:convertToWorldSpace(ccp(0, -size.height * ap.y))
    else
      local size = object.m_Cursor:getContentSize()
      local ap = object.m_Cursor:getAnchorPoint()
      pos = object.m_Cursor:convertToWorldSpace(ccp(0, -size.height * ap.y))
    end
    if pos.y >= object.m_KeyBoardHeight and sy <= 0 then
      if scene.m_SceneAdjustAction ~= nil then
        scene:stopAction(scene.m_SceneAdjustAction)
        scene.m_SceneAdjustAction = nil
      end
      if object._AdjustHeightEx then
        object:_AdjustHeightEx(sy)
      end
      return sy
    end
    local p1 = scene:convertToNodeSpace(ccp(0, pos.y))
    local p2 = scene:convertToNodeSpace(ccp(0, object.m_KeyBoardHeight))
    local offy = p2.y - p1.y + sy
    if offy < 0 then
      offy = 0
    end
    if scene.m_SceneAdjustAction ~= nil then
      scene:stopAction(scene.m_SceneAdjustAction)
      scene.m_SceneAdjustAction = nil
    end
    local act1 = CCMoveTo:create(Define_OpenSpeedKeyboard, ccp(mx, offy))
    local act2 = CCCallFunc:create(function()
      scene.m_SceneAdjustAction = nil
    end)
    scene.m_SceneAdjustAction = transition.sequence({act1, act2})
    scene:runAction(scene.m_SceneAdjustAction)
    if object._AdjustHeightEx then
      object:_AdjustHeightEx(offy)
    end
    object:ShowBlackScreenLayer(true)
    return offy
  end
  function object:_recoverHeight()
    if object.m_OpenCnt > 0 then
      return
    end
    object.m_MsgCaptureLayer:setTouchEnabled(false)
    local scene = object.m_AdjustLayer
    local pos = ccp(0, 0)
    if scene == nil then
      scene = display.getRunningScene()
    else
      pos = object.m_AdjustLayer.__oriPos
    end
    if scene.m_SceneAdjustAction ~= nil then
      scene:stopAction(scene.m_SceneAdjustAction)
      scene.m_SceneAdjustAction = nil
    end
    local act1 = CCMoveTo:create(Define_CloseSpeedKeyboard, pos)
    local act2 = CCCallFunc:create(function()
      scene.m_SceneAdjustAction = nil
      if object ~= nil and object.ShowBlackScreenLayer ~= nil then
        object:ShowBlackScreenLayer(false)
      end
    end)
    scene.m_SceneAdjustAction = transition.sequence({act1, act2})
    scene:runAction(scene.m_SceneAdjustAction)
  end
  function object:_openKeyBoard()
    object:attachWithIME()
  end
  function object:_closeKeyBoard()
    object:didNotSelectSelf()
    object:_recoverHeight()
  end
  function object:CloseTheKeyBoard()
    object:_setOpenCnt(0)
    if object.m_InsertBoardShow then
      object:closeInsertBoard()
    else
      object:_closeKeyBoard()
    end
  end
  function object:_setOpenCnt(cnt)
    if cnt < 0 then
      cnt = 0
    end
    object.m_OpenCnt = cnt
    if object._setOpenCntEx then
      object._setOpenCntEx()
    end
    if object.m_KeyBoardListener then
      if cnt == 0 then
        object.m_KeyBoardListener(TEXTFIELD_EVENT_DETACH_WITH_IME)
      else
        object.m_KeyBoardListener(TEXTFIELD_EVENT_ATTACH_WITH_IME)
      end
    end
  end
  function object:GetInputLength()
    return object.m_CurInputLength
  end
  function object:SetMaxInputLength(maxLen)
    object.m_MaxInputLength = maxLen
  end
  function object:SetKeyBoardListener(keyBoardListener)
    object.m_KeyBoardListener = keyBoardListener
  end
  function object:SetEnableChinese(eable)
    object.m_EnableChinese = eable
  end
  function object:ShowBlackScreenLayer(ishow)
    if ishow then
      if object.m_AdjustLayer ~= nil then
        if object.m_BlackScreenLayer == nil then
          local parent = object.m_AdjustLayer:getParent()
          local zOrder = object.m_AdjustLayer:getZOrder()
          object.m_BlackScreenLayer = display.newColorLayer(ccc4(0, 0, 0, 120))
          if parent.addNode ~= nil then
            parent:addNode(object.m_BlackScreenLayer, zOrder - 1)
          else
            parent:addChild(object.m_BlackScreenLayer, zOrder - 1)
          end
        else
          object.m_BlackScreenLayer:setVisible(true)
        end
      end
    elseif object.m_BlackScreenLayer then
      object.m_BlackScreenLayer:setVisible(false)
    end
  end
  function object:ClearTextFieldExtend()
    object.m_KeyBoardListener = nil
    object.m_AdjustLayer = nil
    if object.ClearTextFieldExtendEx then
      object.ClearTextFieldExtendEx()
    end
    SyNative.unRegSoftKeyBoardEvent(handler(object, object._onKeyBoardEventListener_Android))
  end
  object.m_OldEnterText = object:getStringValue()
  object.m_EnableChinese = true
  object.m_CurInputLength = 0
  object.m_AdjustLayer = adjustLayer
  if object.m_AdjustLayer ~= nil then
    local x, y = object.m_AdjustLayer:getPosition()
    object.m_AdjustLayer.__oriPos = ccp(x, y)
  end
  object:addEventListenerTextField(handler(object, object._onKeyBoardEventListener))
  SyNative.regSoftKeyBoardEvent(handler(object, object._onKeyBoardEventListener_Android))
  object.m_OpenCnt = 0
  object.m_SysKeyBoardOpen = false
  local msgCaptureLayer = Widget:create()
  object.m_MsgCaptureLayer = msgCaptureLayer
  object.m_KeyBoardHeight = 0
  local p = object:getParent()
  local zOrder = object:getZOrder()
  local w, h = 10000, 10000
  p:addChild(msgCaptureLayer, zOrder - 1)
  msgCaptureLayer:setAnchorPoint(ccp(0, 0))
  msgCaptureLayer:setPosition(ccp(-w / 2, -h / 2))
  msgCaptureLayer:ignoreContentAdaptWithSize(false)
  msgCaptureLayer:setSize(CCSize(w, h))
  msgCaptureLayer:setTouchEnabled(false)
  msgCaptureLayer:addTouchEventListener(function(touchObj, t)
    if t == TOUCH_EVENT_BEGAN then
      object:CloseTheKeyBoard()
    end
  end)
end
