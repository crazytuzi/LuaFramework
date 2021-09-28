local DefineMaxNum_InsertItem = 3
local DefineMaxNum_InsertPet = 3
local InsertType_Text = 0
local InsertType_Emotion = 1
local InsertType_Item = 2
local InsertType_Pet = 3
DailyWordType_Private = 1
DailyWordType_Team = 2
TextFieldEmoteExtend = {}
function TextFieldEmoteExtend.extend(object, topUiNode, tfParam, adjustLayer)
  function object:_updateShowText()
    object.m_ShowRichText:clearAll()
    if object.m_EnablePassWord then
      local sLen = string.len(object.m_RealSendText)
      local pwStr = string.rep("*", sLen)
      object.m_ShowRichText:addRichText(pwStr)
    else
      object.m_ShowRichText:addRichText(object.m_RealSendText)
    end
    local fontSize = object:getFontSize()
    local w = 3
    local cursor = display.newColorLayer(ccc4(0, 0, 0, 255))
    cursor:setContentSize(CCSize(w, fontSize + 2))
    local act1 = CCFadeOut:create(0.5)
    local act2 = CCFadeIn:create(0.5)
    cursor:runAction(CCRepeatForever:create(transition.sequence({act1, act2})))
    local param = {
      obj = cursor,
      ignoreSizeFlag = false,
      isWidget = false
    }
    object.m_ShowRichText:addOneNode(param)
    local size = object.m_MaskLayer:getContentSize()
    local textSize = object.m_ShowRichText:getContentSize()
    local y = 0
    if object.m_EnableMulti then
      y = size.height - textSize.height
    else
      y = (size.height - textSize.height) / 2
    end
    object.m_ShowRichText:setPosition(ccp(0, y + object.m_OffY))
    local cpos = cursor:convertToWorldSpace(ccp(w, 0))
    local pos = object.m_MaskLayer:convertToNodeSpace(ccp(cpos.x, 0))
    if pos.x > size.width then
      object.m_ShowRichText:setPosition(ccp(size.width - pos.x, y + object.m_OffY))
    end
    object.m_Cursor = cursor
    object:_checkCursorShow()
    if 0 < object.m_OpenCnt and object.m_EnableMulti then
      object:_AdjustHeight(nil)
    end
  end
  function object:_checkCursorShow()
    if object.m_Cursor then
      object.m_Cursor:setVisible(object.m_OpenCnt > 0)
    end
    object:checkFiledPlaceHolder()
  end
  function object:checkFiledPlaceHolder()
    if object.m_FiledPlaceHolder ~= nil then
      if object.m_OpenCnt > 0 then
        object.m_FiledPlaceHolder:setVisible(false)
      elseif 0 < string.len(object.m_RealSendText) then
        object.m_FiledPlaceHolder:setVisible(false)
      else
        object.m_FiledPlaceHolder:setVisible(true)
      end
    end
  end
  function object:_setOpenCntEx()
    object:_checkCursorShow()
  end
  function object:_OnEnterChangedEx()
    local newText = object:getStringValue()
    local updateFlag = false
    local newLen = string.len(newText)
    local oldLen = string.len(object.m_OldEnterText)
    local sameIdx = 0
    for i = 1, newLen do
      if i > oldLen then
        break
      else
        local nchar = string.sub(newText, i, i)
        local ochar = string.sub(object.m_OldEnterText, i, i)
        if nchar == ochar then
          sameIdx = i
        else
          break
        end
      end
    end
    local difDix = sameIdx + 1
    if oldLen >= difDix then
      local delStr = string.sub(object.m_OldEnterText, difDix, oldLen)
      updateFlag = object:_getSubStr(delStr) or updateFlag
      if sameIdx >= 1 then
        object.m_OldEnterText = string.sub(object.m_OldEnterText, 1, sameIdx)
      else
        object.m_OldEnterText = ""
      end
    end
    if newLen >= difDix then
      local addStr = string.sub(newText, difDix, newLen)
      updateFlag = object:_getAddStr(addStr, newText) or updateFlag
    end
    if updateFlag then
      object:_updateShowText()
    end
    object:setText("")
    object:setText(object.m_OldEnterText)
  end
  function object:_getAddStr(addStr, newText)
    local n = GetMyUTF8Len_ex(addStr)
    local len_charCN = 1
    local oldText = object.m_OldEnterText
    if object.m_MaxInputLength ~= nil and n + object.m_CurInputLength > object.m_MaxInputLength then
      local inputN = object.m_MaxInputLength - object.m_CurInputLength
      if inputN <= 0 then
        return false
      end
      local i = 1
      local sptIdx = 0
      local sptLen = 0
      for i = 1, string.len(addStr) do
        local bt = string.byte(addStr, i)
        if bt < 128 then
          sptIdx = i
          sptLen = sptLen + 1
        elseif bt >= 192 then
          if sptLen <= inputN - len_charCN then
            sptLen = sptLen + len_charCN
          else
            break
          end
        else
          sptIdx = i
        end
      end
      if sptIdx <= 0 then
        return false
      end
      addStr = string.sub(addStr, 1, sptIdx)
      object.m_OldEnterText = string.format("%s%s", object.m_OldEnterText, addStr)
      object.m_CurInputLength = object.m_CurInputLength + sptLen
    else
      object.m_CurInputLength = object.m_CurInputLength + n
      object.m_OldEnterText = newText
    end
    if string.sub(addStr, 1, 1) == "<" then
      local oldLen = string.len(oldText)
      if oldLen >= 1 then
        local tempStr = string.sub(oldText, oldLen, oldLen)
        if tempStr == "#" then
          addStr = string.gsub(addStr, "<", "_", 1)
        end
      end
    end
    addStr = string.gsub(addStr, "#<", "#_")
    object.m_RealSendText = string.format("%s%s", object.m_RealSendText, addStr)
    for i = 1, string.len(addStr) do
      object.m_InsertType[#object.m_InsertType + 1] = InsertType_Text
    end
    return true
  end
  function object:_getSubStr(delStr)
    local exN = 0
    object.m_CurInputLength = object.m_CurInputLength - GetMyUTF8Len_ex(delStr)
    local subLen = string.len(delStr)
    for i = subLen, 1, -1 do
      local insertType = object.m_InsertType[#object.m_InsertType]
      if insertType == InsertType_Text then
        object.m_RealSendText = string.sub(object.m_RealSendText, 1, -2)
        table.remove(object.m_InsertType, #object.m_InsertType)
      elseif insertType == InsertType_Emotion or insertType == InsertType_Item or insertType == InsertType_Pet then
        local char = string.sub(object.m_RealSendText, -1, -1)
        if char == "#" then
          local delIndex
          local sLen = string.len(object.m_RealSendText) - 3
          while sLen > 0 do
            local prechar = string.sub(object.m_RealSendText, sLen, sLen + 1)
            if prechar == "#<" then
              delIndex = sLen
              break
            end
            sLen = sLen - 1
          end
          if delIndex ~= nil then
            object.m_RealSendText = string.sub(object.m_RealSendText, 1, sLen - 1)
            table.remove(object.m_InsertType, #object.m_InsertType)
            exN = exN + 1
          else
            print("--->>删除表情时，找不到格式化字符串的起点", object.m_RealSendText)
          end
        else
          print("--->>删除表情时，结束字符串不正确", char, object.m_RealSendText)
        end
      end
    end
    object.m_CurInputLength = object.m_CurInputLength - exN
    return true
  end
  function object:openKeyBoard()
    object:_openKeyBoard()
  end
  function object:_AdjustHeightEx(offy)
    if not object.m_InsertBoardShow or object.m_TopUiNode == nil then
      return
    end
    local size = object.m_InsertBoard:getContentSize()
    local pos = object.m_TopUiNode:convertToNodeSpace(ccp((display.width - size.width) / 2, 0))
    local _, py = object.m_TopUiNode:getPosition()
    object.m_InsertBoard:stopAllActions()
    object.m_InsertBoard:runAction(transition.sequence({
      CCShow:create(),
      CCMoveTo:create(Define_OpenSpeedKeyboard, ccp(pos.x, -py - offy)),
      object.m_InsertBoard:setBoardShow(true)
    }))
  end
  function object:openInsertBoard(param)
    if object.m_InsertBoardShow then
      return
    end
    if object.m_InsertBoard == nil then
      object.m_InsertBoard = object:_createInsertBoard(param)
    else
      object.m_InsertBoard:SetEmotionBoardRecently()
    end
    object.m_InsertBoardShow = true
    object:_setOpenCnt(object.m_OpenCnt + 1)
    local size = object.m_InsertBoard:getContentSize()
    object:_AdjustHeight(size.height + 30)
    SendMessage(MsgID_KeyBoard_EmotionShow)
  end
  function object:_createInsertBoard(param)
    if object.m_TopUiNode == nil then
      return
    end
    local insertboard = CChatInsert.new(object, object.m_DailyWordType, param)
    local size = insertboard:getContentSize()
    local pos = object.m_TopUiNode:convertToNodeSpace(ccp((display.width - size.width) / 2, -size.height - 50))
    insertboard:setPosition(ccp(pos.x, pos.y))
    object.m_TopUiNode:addChild(insertboard:getUINode(), 9999)
    return insertboard
  end
  function object:closeInsertBoard()
    if object.m_InsertBoardShow then
      object.m_InsertBoardShow = false
      object:_setOpenCnt(object.m_OpenCnt - 1)
      local size = object.m_InsertBoard:getContentSize()
      local pos = object.m_TopUiNode:convertToNodeSpace(ccp((display.width - size.width) / 2, 0))
      local _, py = object.m_TopUiNode:getPosition()
      object.m_InsertBoard:stopAllActions()
      object.m_InsertBoard:runAction(transition.sequence({
        CCMoveTo:create(Define_CloseSpeedKeyboard, ccp(pos.x, -py - size.height - 50)),
        CCHide:create(),
        CCCallFunc:create(function()
          object.m_InsertBoard:setBoardShow(false)
        end)
      }))
      object:_recoverHeight()
    end
  end
  function object:_onInsertBoardDestroy()
    print("--->>> _onInsertBoardDestroy!!!!!")
    object.m_InsertBoard = nil
    object.m_InsertBoardShow = false
  end
  function object:_insertEmotion(emotionNumber)
    if object:isMaxLengthEnabled() then
      local maxLen = object:getMaxLength()
      local inputText = object:getStringValue()
      local inputLen = string.len(inputText)
      if maxLen > 0 and maxLen <= inputLen then
        return
      end
    end
    local n = 2
    if object.m_MaxInputLength ~= nil and object.m_CurInputLength + n > object.m_MaxInputLength then
      return
    end
    object.m_CurInputLength = object.m_CurInputLength + n
    local emotFormatStr = string.format("#<E:%d>#", emotionNumber)
    object.m_RealSendText = string.format("%s%s", object.m_RealSendText, emotFormatStr)
    object.m_OldEnterText = string.format("%s%s", object.m_OldEnterText, "e")
    object:setText(object.m_OldEnterText)
    object:_updateShowText()
    object.m_InsertType[#object.m_InsertType + 1] = InsertType_Emotion
    if object.m_KeyBoardListener then
      object.m_KeyBoardListener(TEXTFIELDEXTEND_EVENT_TEXT_CHANGE)
    end
  end
  function object:_insertItem(itemId)
    if object:isMaxLengthEnabled() then
      local maxLen = object:getMaxLength()
      local inputText = object:getStringValue()
      local inputLen = string.len(inputText)
      if maxLen > 0 and maxLen <= inputLen then
        return
      end
    end
    if object:_getInsertTypeAmount(InsertType_Item) >= DefineMaxNum_InsertItem then
      ShowNotifyTips("一次最多只能发送3个物品链接")
      return
    end
    local localPlayerId = g_LocalPlayer:getPlayerId()
    local itemObj = g_LocalPlayer:GetOneItem(itemId)
    if itemObj == nil then
      return
    end
    local n = 2
    if object.m_MaxInputLength ~= nil and object.m_CurInputLength + n > object.m_MaxInputLength then
      return
    end
    object.m_CurInputLength = object.m_CurInputLength + n
    local itemName = itemObj:getProperty(ITEM_PRO_NAME)
    local itemTypeId = itemObj:getTypeId()
    local itemFormatStr = string.format("#<MI:%d,M:%d,MP:%s,MT:%d,CI:%d>【%s】#", itemId, CRichText_MessageType_Item, tostring(localPlayerId), itemTypeId, itemTypeId, itemName)
    object.m_RealSendText = string.format("%s%s", object.m_RealSendText, itemFormatStr)
    object.m_OldEnterText = string.format("%s%s", object.m_OldEnterText, "i")
    object:setText(object.m_OldEnterText)
    object:_updateShowText()
    object.m_InsertType[#object.m_InsertType + 1] = InsertType_Item
    if object.m_KeyBoardListener then
      object.m_KeyBoardListener(TEXTFIELDEXTEND_EVENT_TEXT_CHANGE)
    end
  end
  function object:_insertPet(petId)
    if object:isMaxLengthEnabled() then
      local maxLen = object:getMaxLength()
      local inputText = object:getStringValue()
      local inputLen = string.len(inputText)
      if maxLen > 0 and maxLen <= inputLen then
        return
      end
    end
    if object:_getInsertTypeAmount(InsertType_Pet) >= DefineMaxNum_InsertPet then
      ShowNotifyTips("一次最多只能发送3个召唤兽链接")
      return
    end
    local localPlayerId = g_LocalPlayer:getPlayerId()
    local petObj = g_LocalPlayer:getObjById(petId)
    if petObj == nil then
      return
    end
    local n = 2
    if object.m_MaxInputLength ~= nil and object.m_CurInputLength + n > object.m_MaxInputLength then
      return
    end
    object.m_CurInputLength = object.m_CurInputLength + n
    local petName = petObj:getProperty(PROPERTY_NAME)
    local petColor = NameColor_Pet[petObj:getProperty(PROPERTY_ZHUANSHENG)] or ccc3(247, 162, 28)
    local petFormatStr = string.format("#<MM:%d,M:%d,MP:%s,r:%d,g:%d,b:%d>【%s】#", petId, CRichText_MessageType_Pet, tostring(localPlayerId), petColor.r, petColor.g, petColor.b, petName)
    object.m_RealSendText = string.format("%s%s", object.m_RealSendText, petFormatStr)
    object.m_OldEnterText = string.format("%s%s", object.m_OldEnterText, "p")
    object:setText(object.m_OldEnterText)
    object:_updateShowText()
    object.m_InsertType[#object.m_InsertType + 1] = InsertType_Pet
    if object.m_KeyBoardListener then
      object.m_KeyBoardListener(TEXTFIELDEXTEND_EVENT_TEXT_CHANGE)
    end
  end
  function object:_onInsertSendText(text)
    if object.m_KeyBoardListener then
      object.m_KeyBoardListener(TEXTFIELDEXTEND_EVENT_SEND_TEXT, text)
    end
    if object and object.CloseTheKeyBoard ~= nil then
      object:CloseTheKeyBoard()
    end
  end
  function object:_getInsertTypeAmount(insertType)
    local n = 0
    for _, iType in pairs(object.m_InsertType) do
      if iType == insertType then
        n = n + 1
      end
    end
    return n
  end
  function object:_adjustFiledPlaceHolderPos()
    local size = object.m_MaskLayer:getContentSize()
    local textSize = object.m_FiledPlaceHolder:getContentSize()
    local y = 0
    if object.m_EnableMulti then
      y = size.height - textSize.height
    else
      y = (size.height - textSize.height) / 2
    end
    if object.m_TextFieldAlign == CRichText_AlignType_Center then
      object.m_FiledPlaceHolder:setAnchorPoint(ccp(0.5, 0))
      object.m_FiledPlaceHolder:setPosition(ccp(object.m_TextFieldWidth / 2, y + object.m_OffY))
    elseif object.m_TextFieldAlign == CRichText_AlignType_Right then
      object.m_FiledPlaceHolder:setAnchorPoint(ccp(1, 0))
      object.m_FiledPlaceHolder:setPosition(ccp(object.m_TextFieldWidth, y + object.m_OffY))
    else
      object.m_FiledPlaceHolder:setAnchorPoint(ccp(0, 0))
      object.m_FiledPlaceHolder:setPosition(ccp(0, y + object.m_OffY))
    end
  end
  function object:OnMessage(msgSID, ...)
    if msgSID == MsgID_KeyBoard_SysShow then
      object:closeInsertBoard()
    elseif msgSID == MsgID_KeyBoard_EmotionShow then
      object:didNotSelectSelf()
    end
  end
  function object:SetFieldText(txt)
    if txt == nil then
      txt = ""
    end
    object.m_RealSendText = txt
    object.m_OldEnterText = ""
    object.m_InsertType = {}
    local txtLen = string.len(txt)
    local index = 1
    local speIdx, speInsertType
    local exLen = 0
    while txtLen >= index do
      local addStr = string.sub(txt, index, index)
      if addStr == "#" then
        if speInsertType ~= nil then
          if speInsertType == InsertType_Emotion then
            object.m_OldEnterText = string.format("%s%s", object.m_OldEnterText, "e")
            object.m_InsertType[#object.m_InsertType + 1] = InsertType_Emotion
            exLen = exLen + 1
          elseif speInsertType == InsertType_Item then
            object.m_OldEnterText = string.format("%s%s", object.m_OldEnterText, "i")
            object.m_InsertType[#object.m_InsertType + 1] = InsertType_Item
            exLen = exLen + 1
          elseif speInsertType == InsertType_Pet then
            object.m_OldEnterText = string.format("%s%s", object.m_OldEnterText, "p")
            object.m_InsertType[#object.m_InsertType + 1] = InsertType_Pet
            exLen = exLen + 1
          end
          speInsertType = nil
          speIdx = nil
          index = index + 1
        elseif string.sub(txt, index, index + 3) == "#<E:" then
          if speIdx ~= nil then
            lastStr = string.sub(txt, speIdx, index - 1)
            object.m_OldEnterText = string.format("%s%s", object.m_OldEnterText, lastStr)
            for i = 1, string.len(lastStr) do
              object.m_InsertType[#object.m_InsertType + 1] = InsertType_Text
            end
          end
          speIdx = index
          index = index + 4
          speInsertType = InsertType_Emotion
        elseif string.sub(txt, index, index + 4) == "#<MI:" then
          if speIdx ~= nil then
            lastStr = string.sub(txt, speIdx, index - 1)
            object.m_OldEnterText = string.format("%s%s", object.m_OldEnterText, lastStr)
            for i = 1, string.len(lastStr) do
              object.m_InsertType[#object.m_InsertType + 1] = InsertType_Text
            end
          end
          speIdx = index
          index = index + 5
          speInsertType = InsertType_Item
        elseif string.sub(txt, index, index + 4) == "#<MM:" then
          if speIdx ~= nil then
            lastStr = string.sub(txt, speIdx, index - 1)
            object.m_OldEnterText = string.format("%s%s", object.m_OldEnterText, lastStr)
            for i = 1, string.len(lastStr) do
              object.m_InsertType[#object.m_InsertType + 1] = InsertType_Text
            end
          end
          speIdx = index
          index = index + 5
          speInsertType = InsertType_Pet
        else
          object.m_OldEnterText = string.format("%s%s", object.m_OldEnterText, addStr)
          object.m_InsertType[#object.m_InsertType + 1] = InsertType_Text
          index = index + 1
        end
      elseif speIdx == nil then
        object.m_OldEnterText = string.format("%s%s", object.m_OldEnterText, addStr)
        object.m_InsertType[#object.m_InsertType + 1] = InsertType_Text
        index = index + 1
      else
        index = index + 1
      end
    end
    if speIdx ~= nil then
      lastStr = string.sub(txt, speIdx, txtLen)
      object.m_OldEnterText = string.format("%s%s", object.m_OldEnterText, lastStr)
      for i = 1, string.len(lastStr) do
        object.m_InsertType[#object.m_InsertType + 1] = InsertType_Text
      end
    end
    object.m_CurInputLength = GetMyUTF8Len_ex(object.m_OldEnterText) + exLen
    object:setText(object.m_OldEnterText)
    object:_updateShowText()
    if object.m_KeyBoardListener then
      object.m_KeyBoardListener(TEXTFIELDEXTEND_EVENT_TEXT_CHANGE)
    end
  end
  function object:GetFieldText()
    return object.m_RealSendText
  end
  function object:SetFiledPlaceHolder(txt, param)
    if object.m_FiledPlaceHolder ~= nil then
      object.m_FiledPlaceHolder:removeFromParentAndCleanup(true)
      object.m_FiledPlaceHolder = nil
    end
    local ocsize = object:getContentSize()
    if object.getSize then
      ocsize = object:getSize()
    end
    param = param or {}
    local ft = param.font or object:getFontName()
    local ftSize = param.fontSize or object:getFontSize()
    local ftColor = param.color or object:getColor()
    object.m_FiledPlaceHolder = ui.newTTFLabel({
      text = txt,
      size = ftSize,
      font = ft,
      color = ftColor,
      dimensions = CCSize(ocsize.width - 6, 0)
    })
    object.m_MaskLayer:addNode(object.m_FiledPlaceHolder)
    object:_adjustFiledPlaceHolderPos()
  end
  function object:SetFieldTextOffY(offy)
    object.m_OffY = offy or 0
    object:_updateShowText()
    object:_adjustFiledPlaceHolderPos()
  end
  function object:SetDailyWordType(dtype)
    object.m_DailyWordType = dtype
  end
  function object:SetEnableMulti(flag)
    object.m_EnableMulti = flag
    object:_updateShowText()
    object:_adjustFiledPlaceHolderPos()
  end
  function object:SetnablePassWord(flag)
    object.m_EnablePassWord = flag
  end
  function object:ClearTextFieldExtendEx()
    object.m_TopUiNode = nil
    object.m_InsertBoard = nil
    object:RemoveAllMessageListener()
  end
  TextFieldOpenCloseExtend.extend(object, adjustLayer)
  tfParam = tfParam or {}
  object.m_TextFieldWidth = tfParam.width or 10000
  object.m_TextFieldAlign = tfParam.align or CRichText_AlignType_Left
  local ap = object:getAnchorPoint()
  local size = object:getContentSize()
  if object.getSize then
    size = object:getSize()
  end
  object.m_MaskLayer = Layout:create()
  object:addChild(object.m_MaskLayer)
  object.m_MaskLayer:ignoreContentAdaptWithSize(false)
  object.m_MaskLayer:setSize(CCSize(size.width + 4, size.height))
  object.m_MaskLayer:setAnchorPoint(ccp(0, 0))
  object.m_MaskLayer:setPosition(ccp(-size.width * ap.x, -size.height * ap.y))
  object.m_MaskLayer:setClippingEnabled(true)
  local rtParam = {
    width = object.m_TextFieldWidth,
    fontSize = object:getFontSize(),
    font = object:getFontName(),
    color = ccc3(255, 255, 255),
    align = object.m_TextFieldAlign
  }
  object.m_ShowRichText = CRichText.new(rtParam)
  object.m_MaskLayer:addChild(object.m_ShowRichText)
  object.m_DailyWordType = DailyWordType_Private
  object.m_OffY = 0
  object.m_RealSendText = ""
  object:setText("")
  object:setInsertText(false)
  object.m_InsertType = {}
  object:_updateShowText()
  object.m_TopUiNode = topUiNode
  object.m_EnableMulti = false
  object.m_EnablePassWord = false
  object.m_FiledPlaceHolder = nil
  local txt = object:getPlaceHolder()
  object:SetFiledPlaceHolder(txt)
  object.m_InsertBoardShow = false
  object.m_MsgCaptureLayer:addTouchEventListener(function(touchObj, t)
    if t == TOUCH_EVENT_BEGAN then
      object:CloseTheKeyBoard()
    end
  end)
  MessageEventExtend.extend(object)
  object:ListenMessage(MsgID_KeyBoard)
end
