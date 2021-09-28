local g_MaxWordNumOfLocalChat = 50
socialityDlgExtend_Local = {}
function socialityDlgExtend_Local.extend(object)
  function object:InitLocal()
    local btnBatchListener = {
      btn_localchat_insert = {
        listener = handler(object, object.Btn_LocalChatInsert),
        variName = "btn_localchat_insert"
      },
      btn_send_localchat = {
        listener = handler(object, object.Btn_SendLocalChat),
        variName = "btn_send_localchat"
      },
      btn_voice_local = {
        listener = handler(object, object.Btn_VoiceLocal),
        variName = "btn_voice_local"
      },
      btn_keyboard_local = {
        listener = handler(object, object.Btn_KeyBoardLocal),
        variName = "btn_keyboard_local"
      }
    }
    object:addBatchBtnListener(btnBatchListener)
    object.list_localchat = object:getNode("list_localchat")
    object.input_localchat = object:getNode("input_localchat")
    object.inputbg_localchat = object:getNode("inputbg_localchat")
    object.m_LocalChatIsOpenFlag = nil
    object:resizeList(object.list_localchat)
    object.btn_voicepress_local = object:getNode("btn_voicepress_local")
    VoiceRecordBtnExtend.extend(object.btn_voicepress_local, CHANNEL_LOCAL, nil, true)
    local pressBtnTxt = ui.newTTFLabel({
      text = "按住说话",
      size = 20,
      font = KANG_TTF_FONT,
      color = ccc3(236, 209, 76)
    })
    object.btn_voicepress_local:addNode(pressBtnTxt)
    TextFieldEmoteExtend.extend(object.input_localchat, object:getUINode())
    object.input_localchat:setMaxLengthEnabled(false)
    object.input_localchat:SetMaxInputLength(g_MaxWordNumOfLocalChat)
    object.input_localchat:SetKeyBoardListener(handler(object, object.onLocalChatKeyBoardListener))
    object.input_localchat:SetDailyWordType(DailyWordType_Private)
    object:ShowLocalChat()
    object:checkLocalChatFuncIsOpen()
    object:Btn_KeyBoardLocal()
  end
  function object:ShowLocalChat()
    object.list_localchat:setEnabled(true)
    object.list_localchat:removeAllItems()
    object.btn_localchat_insert:setTouchEnabled(true)
    object.btn_send_localchat:setTouchEnabled(true)
    if object.m_LocalChatBox == nil then
      object.m_LocalChatBox = CLocalchat.new(object.list_localchat, handler(object, object.OnClickMessage))
    end
  end
  function object:onLocalChatKeyBoardListener(event, param)
    if event == TEXTFIELDEXTEND_EVENT_SEND_TEXT then
      local chatText = param
      if string.len(chatText) > 0 then
        g_MessageMgr:sendLocalMessage(chatText)
      end
    end
  end
  function object:onReceiveLocalChannelCD(cd)
    if cd > 0 then
      object.btn_send_localchat:setTitleText(string.format("%ds", cd))
    else
      object.btn_send_localchat:setTitleText("发送")
    end
  end
  function object:checkLocalChatFuncIsOpen()
    local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_LocalChat)
    if object.m_LocalChatIsOpenFlag == openFlag then
      return
    end
    object.m_LocalChatIsOpenFlag = openFlag
    if not openFlag then
      local data = data_FunctionUnlock[OPEN_Func_LocalChat]
      if data then
        object.input_localchat:SetFiledPlaceHolder(string.format("%d级后才可以发言", data.lv), {fontSize = 22})
      else
        object.input_localchat:SetFiledPlaceHolder(tips, {fontSize = 22})
      end
      object.input_localchat:setTouchEnabled(false)
    else
      object.input_localchat:SetFiledPlaceHolder("请点击输入", {fontSize = 22})
      object.input_localchat:setTouchEnabled(true)
    end
  end
  function object:Btn_LocalChatInsert(obj, t)
    if object.btn_voicepress_local:isVisible() then
      object:Btn_KeyBoardLocal()
    end
    local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_LocalChat)
    if not openFlag then
      ShowNotifyTips(tips)
    else
      object.input_localchat:openInsertBoard()
    end
  end
  function object:Btn_SendLocalChat(obj, t)
    if object.btn_voicepress_local:isVisible() then
      object:Btn_KeyBoardLocal()
    end
    local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_LocalChat)
    if not openFlag then
      ShowNotifyTips(tips)
    else
      local chatText = object.input_localchat:GetFieldText()
      if string.len(chatText) > 0 then
        if g_MessageMgr:sendLocalMessage(chatText) then
          g_LocalPlayer:recordRecentChat(chatText)
          SendMessage(MsgID_Message_NewSendMsg, chatText)
          object.input_localchat:SetFieldText("")
        end
      else
        ShowNotifyTips("请先输入聊天内容")
      end
    end
  end
  function object:Btn_VoiceLocal(obj, t)
    object.btn_voice_local:setVisible(false)
    object.btn_voice_local:setTouchEnabled(false)
    object.btn_keyboard_local:setVisible(true)
    object.btn_keyboard_local:setTouchEnabled(true)
    object.input_localchat:setVisible(false)
    object.input_localchat:setTouchEnabled(false)
    object.inputbg_localchat:setVisible(false)
    object.btn_voicepress_local:setVisible(true)
    object.btn_voicepress_local:setTouchEnabled(true)
    object.input_localchat:CloseTheKeyBoard()
  end
  function object:Btn_KeyBoardLocal(obj, t)
    object.btn_voice_local:setVisible(true)
    object.btn_voice_local:setTouchEnabled(true)
    object.btn_keyboard_local:setVisible(false)
    object.btn_keyboard_local:setTouchEnabled(false)
    object.input_localchat:setVisible(true)
    local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_LocalChat)
    if openFlag then
      object.input_localchat:setTouchEnabled(true)
    else
      object.input_localchat:setTouchEnabled(false)
    end
    object.inputbg_localchat:setVisible(true)
    object.btn_voicepress_local:setVisible(false)
    object.btn_voicepress_local:setTouchEnabled(false)
  end
  function object:Clear_LocalExtend()
    object.input_localchat:ClearTextFieldExtend()
    if object.m_LocalChatBox then
      object.m_LocalChatBox:Clear()
      object.m_LocalChatBox = nil
    end
    if object.btn_voicepress_local._VR_ParamFetchFunc then
      object.btn_voicepress_local._VR_ParamFetchFunc = nil
    end
  end
  object:InitLocal()
end
