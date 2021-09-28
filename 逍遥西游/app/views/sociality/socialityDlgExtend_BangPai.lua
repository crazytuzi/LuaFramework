local g_MaxWordNumOfBpChat = 50
socialityDlgExtend_BangPai = {}
function socialityDlgExtend_BangPai.extend(object)
  function object:InitBangPai()
    local btnBatchListener = {
      btn_bpchat_insert = {
        listener = handler(object, object.Btn_BpChatInsert),
        variName = "btn_bpchat_insert"
      },
      btn_send_bpchat = {
        listener = handler(object, object.Btn_SendBpChat),
        variName = "btn_send_bpchat"
      },
      btn_voice_bp = {
        listener = handler(object, object.Btn_VoiceBp),
        variName = "btn_voice_bp"
      },
      btn_keyboard_bp = {
        listener = handler(object, object.Btn_KeyBoardBp),
        variName = "btn_keyboard_bp"
      }
    }
    object:addBatchBtnListener(btnBatchListener)
    object.list_bpchat = object:getNode("list_bpchat")
    object.input_bpchat = object:getNode("input_bpchat")
    object.inputbg_bpchat = object:getNode("inputbg_bpchat")
    object.m_HasBpState = nil
    object:resizeList(object.list_bpchat)
    object.btn_voicepress_bp = object:getNode("btn_voicepress_bp")
    VoiceRecordBtnExtend.extend(object.btn_voicepress_bp, CHANNEL_BP_MSG, nil, true)
    local pressBtnTxt = ui.newTTFLabel({
      text = "按住说话",
      size = 20,
      font = KANG_TTF_FONT,
      color = ccc3(236, 209, 76)
    })
    object.btn_voicepress_bp:addNode(pressBtnTxt)
    TextFieldEmoteExtend.extend(object.input_bpchat, object:getUINode())
    object.input_bpchat:setMaxLengthEnabled(false)
    object.input_bpchat:SetMaxInputLength(g_MaxWordNumOfBpChat)
    object.input_bpchat:SetKeyBoardListener(handler(object, object.onBpChatKeyBoardListener))
    object.input_bpchat:SetDailyWordType(DailyWordType_Private)
    object:ShowBangPaiChat()
    object:InitBpState()
    object:Btn_KeyBoardBp()
    object:ListenMessage(MsgID_BP)
  end
  function object:ShowBangPaiChat()
    if object.m_BpChatBox == nil then
      object.m_BpChatBox = CBangPaiChat.new(object.list_bpchat, handler(object, object.OnClickMessage))
    end
  end
  function object:onBpChatKeyBoardListener(event, param)
    if event == TEXTFIELDEXTEND_EVENT_SEND_TEXT then
      local chatText = param
      if string.len(chatText) > 0 then
        g_MessageMgr:sendBangPaiMessage(chatText)
      end
    end
  end
  function object:InitBpState()
    local hasBp = g_BpMgr:localPlayerHasBangPai()
    if object.m_HasBpState == hasBp then
      return
    end
    object.m_HasBpState = hasBp
    if object.m_HasBpState then
      object.list_bpchat:setTouchEnabled(true)
      object.list_bpchat:setVisible(true)
      object.input_bpchat:setTouchEnabled(true)
      object.input_bpchat:SetFieldText("")
      object.input_bpchat:SetFiledPlaceHolder("请点击输入", {fontSize = 22})
    else
      object.list_bpchat:removeAllItems()
      object.list_bpchat:setTouchEnabled(false)
      object.list_bpchat:setVisible(false)
      object.input_bpchat:setTouchEnabled(false)
      object.input_bpchat:SetFieldText("")
      object.input_bpchat:SetFiledPlaceHolder("加入帮之后可聊天", {fontSize = 21})
      object.input_bpchat:CloseTheKeyBoard()
    end
  end
  function object:onReceiveBpLocalInfo_BpExtend(info)
    object:InitBpState()
  end
  function object:onReceiveBpChannelCD(cd)
    if cd > 0 then
      object.btn_send_bpchat:setTitleText(string.format("%ds", cd))
    else
      object.btn_send_bpchat:setTitleText("发送")
    end
  end
  function object:OnClickPromulgateTeamOfBpList(teamId, pname)
    if object.m_LocalTeamId ~= 0 then
      ShowNotifyTips("你已经组队")
      return
    end
    g_TeamMgr:send_ApplyToTeam(teamId, pname)
  end
  function object:onReceiveNewPromulgateTeam_BpExtend(teamId, info)
    if object.m_LocalTeamId ~= 0 then
      return
    end
    if info.i_target ~= PromulgateTeamTarget_BangPai then
      return
    end
    if info.i_orgid ~= g_BpMgr:getLocalPlayerBpId() then
      print("-->>> 新增发布队伍不是本帮派的？！", info.i_orgid, g_BpMgr:getLocalPlayerBpId())
      return
    end
    if info.i_num ~= nil and info.i_num >= GetTeamPlayerNumLimit(info.i_target) then
      return
    end
    object:deleteTeamOfBpChatList(teamId)
    local newItem = CSocialityTeamItem.new(teamId, info, handler(object, object.OnClickPromulgateTeamOfBpList), handler(object, object.deleteTeamObjOfBpChatList))
    object.m_BpChatBox:AddBangPaiTeam(newItem:getUINode())
  end
  function object:onReceiveDelPromulgateTeam_BpExtend(teamId)
    object:deleteTeamOfBpChatList(teamId)
  end
  function object:onReceiveClearPromulgateTeam_BpExtend()
    local index = object.list_bpchat:getCount() - 1
    while index >= 0 do
      local temp = object.list_bpchat:getItem(index)
      local item = temp.m_UIViewParent
      if item and iskindof(item, "CSocialityTeamItem") then
        object.list_bpchat:removeItem(index)
      end
      index = index - 1
    end
  end
  function object:onReceivePromulgateEffectTeam_BpExtend(teamId, info)
    if object.m_LocalTeamId ~= 0 then
      return
    end
    if info.i_target ~= PromulgateTeamTarget_BangPai then
      return
    end
    if info.i_orgid ~= g_BpMgr:getLocalPlayerBpId() then
      print("-->>> 新增发布队伍不是本帮派的？！", info.i_orgid, g_BpMgr:getLocalPlayerBpId())
      return
    end
    local cnt = object.list_bpchat:getCount()
    for index = 0, cnt - 1 do
      local temp = object.list_bpchat:getItem(index)
      local item = temp.m_UIViewParent
      if item and iskindof(item, "CSocialityTeamItem") and item:getTeamId() == teamId then
        return
      end
    end
    object:onReceiveNewPromulgateTeam_BpExtend(teamId, info)
  end
  function object:deleteTeamOfBpChatList(teamId)
    local cnt = object.list_bpchat:getCount()
    for index = 0, cnt - 1 do
      local temp = object.list_bpchat:getItem(index)
      local item = temp.m_UIViewParent
      if item and iskindof(item, "CSocialityTeamItem") and item:getTeamId() == teamId and item:getIsEffect() then
        object.list_bpchat:removeItem(index)
        break
      end
    end
  end
  function object:deleteTeamObjOfBpChatList(teamObj)
    local cnt = object.list_bpchat:getCount()
    for index = 0, cnt - 1 do
      local temp = object.list_bpchat:getItem(index)
      local item = temp.m_UIViewParent
      if item and iskindof(item, "CSocialityTeamItem") and item == teamObj then
        object.list_bpchat:removeItem(index)
        break
      end
    end
  end
  function object:Btn_BpChatInsert(obj, t)
    if object.btn_voicepress_bp:isVisible() then
      object:Btn_KeyBoardBp()
    end
    if object.m_HasBpState then
      object.input_bpchat:openInsertBoard()
    else
      ShowNotifyTips("入帮后才可在帮派频道里聊天")
    end
  end
  function object:Btn_SendBpChat(obj, t)
    if object.btn_voicepress_bp:isVisible() then
      object:Btn_KeyBoardBp()
    end
    if object.m_HasBpState then
      local chatText = object.input_bpchat:GetFieldText()
      if string.len(chatText) > 0 then
        if g_MessageMgr:sendBangPaiMessage(chatText) then
          g_LocalPlayer:recordRecentChat(chatText)
          SendMessage(MsgID_Message_NewSendMsg, chatText)
          object.input_bpchat:SetFieldText("")
        end
      else
        ShowNotifyTips("请先输入聊天内容")
      end
    else
      ShowNotifyTips("入帮后才可在帮派频道里聊天")
    end
  end
  function object:Btn_VoiceBp(obj, t)
    object.btn_voice_bp:setVisible(false)
    object.btn_voice_bp:setTouchEnabled(false)
    object.btn_keyboard_bp:setVisible(true)
    object.btn_keyboard_bp:setTouchEnabled(true)
    object.input_bpchat:setVisible(false)
    object.input_bpchat:setTouchEnabled(false)
    object.inputbg_bpchat:setVisible(false)
    object.btn_voicepress_bp:setVisible(true)
    object.btn_voicepress_bp:setTouchEnabled(true)
    object.input_bpchat:CloseTheKeyBoard()
  end
  function object:Btn_KeyBoardBp(obj, t)
    object.btn_voice_bp:setVisible(true)
    object.btn_voice_bp:setTouchEnabled(true)
    object.btn_keyboard_bp:setVisible(false)
    object.btn_keyboard_bp:setTouchEnabled(false)
    object.input_bpchat:setVisible(true)
    if object.m_HasBpState then
      object.input_bpchat:setTouchEnabled(true)
    else
      object.input_bpchat:setTouchEnabled(false)
    end
    object.inputbg_bpchat:setVisible(true)
    object.btn_voicepress_bp:setVisible(false)
    object.btn_voicepress_bp:setTouchEnabled(false)
  end
  function object:Clear_BangPaiExtend()
    object.input_bpchat:ClearTextFieldExtend()
    if object.m_BpChatBox then
      object.m_BpChatBox:Clear()
      object.m_BpChatBox = nil
    end
    if object.btn_voicepress_bp._VR_ParamFetchFunc then
      object.btn_voicepress_bp._VR_ParamFetchFunc = nil
    end
  end
  object:InitBangPai()
end
