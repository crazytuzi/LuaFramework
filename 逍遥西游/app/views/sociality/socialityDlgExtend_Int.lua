local g_MaxWordNumOfIntChat = 50
socialityDlgExtend_Int = {}
function socialityDlgExtend_Int.extend(object)
  function object:InitInt()
    local btnBatchListener = {
      btn_intchat_insert = {
        listener = handler(object, object.Btn_IntChatInsert),
        variName = "btn_intchat_insert"
      },
      btn_send_intchat = {
        listener = handler(object, object.Btn_SendIntChat),
        variName = "btn_send_intchat"
      },
      btn_voice_int = {
        listener = handler(object, object.Btn_VoiceInt),
        variName = "btn_voice_int"
      },
      btn_keyboard_int = {
        listener = handler(object, object.Btn_KeyBoardInt),
        variName = "btn_keyboard_int"
      }
    }
    object:addBatchBtnListener(btnBatchListener)
    object.list_intchat = object:getNode("list_intchat")
    object.input_intchat = object:getNode("input_intchat")
    object.inputbg_intchat = object:getNode("inputbg_intchat")
    object.m_WorldChatIsOpenFlag = nil
    object:resizeList(object.list_intchat)
    object.btn_voicepress_int = object:getNode("btn_voicepress_int")
    VoiceRecordBtnExtend.extend(object.btn_voicepress_int, CHANNEL_WOLRD, nil, true)
    local pressBtnTxt = ui.newTTFLabel({
      text = "按住说话",
      size = 20,
      font = KANG_TTF_FONT,
      color = ccc3(236, 209, 76)
    })
    object.btn_voicepress_int:addNode(pressBtnTxt)
    TextFieldEmoteExtend.extend(object.input_intchat, object:getUINode())
    object.input_intchat:setMaxLengthEnabled(false)
    object.input_intchat:SetMaxInputLength(g_MaxWordNumOfIntChat)
    object.input_intchat:SetKeyBoardListener(handler(object, object.onIntChatKeyBoardListener))
    object.input_intchat:SetDailyWordType(DailyWordType_Private)
    object:ShowWorldChat()
    object:checkWorldChatFuncIsOpen()
    object:Btn_KeyBoardInt()
  end
  function object:ShowWorldChat()
    object.list_intchat:setEnabled(true)
    object.list_intchat:removeAllItems()
    object.btn_intchat_insert:setTouchEnabled(true)
    object.btn_send_intchat:setTouchEnabled(true)
    if object.m_IntChatBox == nil then
      object.m_IntChatBox = CIntchat.new(object.list_intchat, handler(object, object.OnClickMessage))
    end
  end
  function object:onIntChatKeyBoardListener(event, param)
    if event == TEXTFIELDEXTEND_EVENT_SEND_TEXT then
      local chatText = param
      if string.len(chatText) > 0 then
        g_MessageMgr:sendWorldMessage(chatText)
      end
    end
  end
  function object:onReceiveWorldChannelCD(cd)
    if cd > 0 then
      object.btn_send_intchat:setTitleText(string.format("%ds", cd))
    else
      object.btn_send_intchat:setTitleText("发送")
    end
  end
  function object:checkWorldChatFuncIsOpen()
    local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_WorldChat)
    if object.m_WorldChatIsOpenFlag == openFlag then
      return
    end
    object.m_WorldChatIsOpenFlag = openFlag
    if not openFlag then
      local data = data_FunctionUnlock[OPEN_Func_WorldChat]
      if data then
        object.input_intchat:SetFiledPlaceHolder(string.format("%d级后才可以发言", data.lv), {fontSize = 22})
      else
        object.input_intchat:SetFiledPlaceHolder(tips, {fontSize = 22})
      end
      object.input_intchat:setTouchEnabled(false)
    else
      object.input_intchat:SetFiledPlaceHolder("请点击输入", {fontSize = 22})
      object.input_intchat:setTouchEnabled(true)
    end
  end
  function object:Btn_IntChatInsert(obj, t)
    if object.btn_voicepress_int:isVisible() then
      object:Btn_KeyBoardInt()
    end
    local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_WorldChat)
    if not openFlag then
      ShowNotifyTips(tips)
    else
      object.input_intchat:openInsertBoard()
    end
  end
  function object:Btn_SendIntChat(obj, t)
    if object.btn_voicepress_int:isVisible() then
      object:Btn_KeyBoardInt()
    end
    local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_WorldChat)
    if not openFlag then
      ShowNotifyTips(tips)
    else
      local chatText = object.input_intchat:GetFieldText()
      if string.len(chatText) > 0 then
        if g_MessageMgr:sendWorldMessage(chatText) then
          g_LocalPlayer:recordRecentChat(chatText)
          SendMessage(MsgID_Message_NewSendMsg, chatText)
          object.input_intchat:SetFieldText("")
        end
      else
        ShowNotifyTips("请先输入聊天内容")
      end
    end
  end
  function object:Btn_VoiceInt(obj, t)
    object.btn_voice_int:setVisible(false)
    object.btn_voice_int:setTouchEnabled(false)
    object.btn_keyboard_int:setVisible(true)
    object.btn_keyboard_int:setTouchEnabled(true)
    object.input_intchat:setVisible(false)
    object.input_intchat:setTouchEnabled(false)
    object.inputbg_intchat:setVisible(false)
    object.btn_voicepress_int:setVisible(true)
    object.btn_voicepress_int:setTouchEnabled(true)
    object.input_intchat:CloseTheKeyBoard()
  end
  function object:Btn_KeyBoardInt(obj, t)
    object.btn_voice_int:setVisible(true)
    object.btn_voice_int:setTouchEnabled(true)
    object.btn_keyboard_int:setVisible(false)
    object.btn_keyboard_int:setTouchEnabled(false)
    object.input_intchat:setVisible(true)
    local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_WorldChat)
    if openFlag then
      object.input_intchat:setTouchEnabled(true)
    else
      object.input_intchat:setTouchEnabled(false)
    end
    object.inputbg_intchat:setVisible(true)
    object.btn_voicepress_int:setVisible(false)
    object.btn_voicepress_int:setTouchEnabled(false)
  end
  function object:Clear_IntExtend()
    object.input_intchat:ClearTextFieldExtend()
    if object.m_IntChatBox then
      object.m_IntChatBox:Clear()
      object.m_IntChatBox = nil
    end
    if object.btn_voicepress_int._VR_ParamFetchFunc then
      object.btn_voicepress_int._VR_ParamFetchFunc = nil
    end
  end
  object:InitInt()
end
