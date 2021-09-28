local g_MaxWordNumOfTeamChat = 50
socialityDlgExtend_Team = {}
function socialityDlgExtend_Team.extend(object)
  function object:InitTeam()
    local btnBatchListener = {
      btn_teamchat_insert = {
        listener = handler(object, object.Btn_TeamChatInsert),
        variName = "btn_teamchat_insert"
      },
      btn_send_teamchat = {
        listener = handler(object, object.Btn_SendTeamChat),
        variName = "btn_send_teamchat"
      },
      btn_voice_team = {
        listener = handler(object, object.Btn_VoiceTeam),
        variName = "btn_voice_team"
      },
      btn_keyboard_team = {
        listener = handler(object, object.Btn_KeyBoardTeam),
        variName = "btn_keyboard_team"
      }
    }
    object:addBatchBtnListener(btnBatchListener)
    object.list_teams = object:getNode("list_teams")
    object.list_teamchat = object:getNode("list_teamchat")
    object.input_teamchat = object:getNode("input_teamchat")
    object.inputbg_teamchat = object:getNode("inputbg_teamchat")
    object:resizeList(object.list_teams)
    object:resizeList(object.list_teamchat)
    object.btn_voicepress_team = object:getNode("btn_voicepress_team")
    VoiceRecordBtnExtend.extend(object.btn_voicepress_team, CHANNEL_TEAM, nil, true)
    local pressBtnTxt = ui.newTTFLabel({
      text = "按住说话",
      size = 20,
      font = KANG_TTF_FONT,
      color = ccc3(236, 209, 76)
    })
    object.btn_voicepress_team:addNode(pressBtnTxt)
    TextFieldEmoteExtend.extend(object.input_teamchat, object:getUINode())
    object.input_teamchat:setMaxLengthEnabled(false)
    object.input_teamchat:SetMaxInputLength(g_MaxWordNumOfTeamChat)
    object.input_teamchat:SetKeyBoardListener(handler(object, object.onTeamChatKeyBoardListener))
    object.input_teamchat:SetDailyWordType(DailyWordType_Team)
    object.m_EverOpenPromulgateTeamInfoDlg = false
    object:SetTeamBase()
    object:Btn_KeyBoardTeam()
    object:ListenMessage(MsgID_Team)
  end
  function object:SetTeamBase()
    object.m_LocalTeamId = g_TeamMgr:getLocalPlayerTeamId()
    if object.m_LocalTeamId == 0 then
      object:ShowPromulgateList()
      object:StartUpdatingPromulgateTeamInfo()
    else
      object:ShowTeamChat()
      object:EndUpdatingPromulgateTeamInfo()
    end
  end
  function object:OnShowDlg_TeamExtend()
    object:CheckNeedUpdatingPromulgateTeamInfo_TeamExtend()
    for _, item in pairs(object.m_PromulgateTeamItemList) do
      item:UpdateTime()
      item:startTimer()
    end
  end
  function object:OnHideDlg_TeamExtend()
    object:CheckNeedEndUpdatingPromulgateTeamInfo_TeamExtend()
    for _, item in pairs(object.m_PromulgateTeamItemList) do
      item:stopTimer()
    end
  end
  function object:onReceiveNewTeam_TeamExtend(teamId)
    if object.m_LocalTeamId == 0 then
      local localPlayerId = g_LocalPlayer:getPlayerId()
      if g_TeamMgr:IsPlayerOfTeam(localPlayerId, teamId) then
        object:SetTeamBase()
      end
    elseif object.m_LocalTeamId == teamId then
      object:SetTeamBase()
    end
  end
  function object:onReceivePlayerJoinTeam_TeamExtend(teamId, pid)
    if object.m_LocalTeamId == 0 then
      if pid == g_LocalPlayer:getPlayerId() then
        object:SetTeamBase()
      end
    elseif object.m_LocalTeamId == teamId then
      object:SetTeamTip_PlayerJoinMyTeam(pid)
    end
  end
  function object:onReceivePlayerLeaveTeam_TeamExtend(teamId, pid)
    if object.m_LocalTeamId ~= 0 and object.m_LocalTeamId == teamId then
      if pid == g_LocalPlayer:getPlayerId() then
        object:SetTeamBase()
      else
        object:SetTeamTip_PlayerLeaveMyTeam(pid)
      end
    end
  end
  function object:onReceiveCaptainChanged_TeamExtend(teamId, captainId)
    if object.m_LocalTeamId ~= 0 and object.m_LocalTeamId == teamId then
      object:SetTeamTip_NewCaptain(captainId)
    end
  end
  function object:ShowPromulgateList()
    if object.m_CurrShowTeamList == object.list_teams then
      return
    end
    object.m_CurrShowTeamList = object.list_teams
    object.list_teams:setEnabled(true)
    object.list_teams:removeAllItems()
    object.list_teamchat:setEnabled(false)
    object.list_teamchat:removeAllItems()
    object.input_teamchat:SetFiledPlaceHolder("组队之后可聊天", {fontSize = 21})
    object.input_teamchat:setTouchEnabled(false)
    object.input_teamchat:CloseTheKeyBoard()
    object.input_teamchat:SetFieldText("")
    object.m_PromulgateTeamItemList = {}
    local teamList = g_TeamMgr:getPromulgateTeams()
    for _, d in pairs(teamList) do
      local teamId = d[1]
      local info = d[2]
      local item = CSocialityTeamItem.new(teamId, info, handler(object, object.OnClickPromulgateTeam), handler(object, object.deleteTeamObjFromPromulgateList))
      object.list_teams:pushBackCustomItem(item:getUINode())
      object.m_PromulgateTeamItemList[#object.m_PromulgateTeamItemList + 1] = item
    end
    object.list_teams:jumpToTop()
    object.list_teams:sizeChangedForShowMoreTips()
  end
  function object:OnClickPromulgateTeam(teamId, pname)
    if object.m_LocalTeamId ~= 0 then
      ShowNotifyTips("你已经组队")
      object:SetTeamBase()
      return
    end
    g_TeamMgr:send_ApplyToTeam(teamId, pname)
  end
  function object:onReceiveNewPromulgateTeam_TeamExtend(teamId, info)
    if object.m_LocalTeamId ~= 0 then
      return
    end
    if info.i_num ~= nil and info.i_num >= GetTeamPlayerNumLimit(info.i_target) then
      return
    end
    if object.m_CurrShowTeamList == object.list_teams then
      object:deleteTeamFromPromulgateList(teamId)
      local ftime = info.i_time or 0
      local newItem = CSocialityTeamItem.new(teamId, info, handler(object, object.OnClickPromulgateTeam), handler(object, object.deleteTeamObjFromPromulgateList))
      for index, item in pairs(object.m_PromulgateTeamItemList) do
        local t = item:getTime() or 0
        if ftime < t then
          object.list_teams:insertCustomItem(newItem:getUINode(), index - 1)
          table.insert(object.m_PromulgateTeamItemList, index, newItem)
          object.list_teams:sizeChangedForShowMoreTips()
          return
        end
      end
      object.list_teams:pushBackCustomItem(newItem:getUINode())
      object.m_PromulgateTeamItemList[#object.m_PromulgateTeamItemList + 1] = newItem
      object.list_teams:sizeChangedForShowMoreTips()
    end
  end
  function object:onReceiveDelPromulgateTeam_TeamExtend(teamId)
    object:deleteTeamFromPromulgateList(teamId)
  end
  function object:onReceiveClearPromulgateTeam_TeamExtend()
    object.m_PromulgateTeamItemList = {}
    object.list_teams:removeAllItems()
    object.list_teams:sizeChangedForShowMoreTips()
  end
  function object:onReceivePromulgateEffectTeam_TeamExtend(teamId, info)
    if object.m_LocalTeamId ~= 0 then
      return
    end
    if object.m_CurrShowTeamList == object.list_teams then
      for index, item in pairs(object.m_PromulgateTeamItemList) do
        if item:getTeamId() == teamId then
          return
        end
      end
      object:onReceiveNewPromulgateTeam_TeamExtend(teamId, info)
    end
  end
  function object:deleteTeamFromPromulgateList(teamId)
    if object.m_CurrShowTeamList == object.list_teams then
      for index, item in pairs(object.m_PromulgateTeamItemList) do
        if item:getTeamId() == teamId and item:getIsEffect() then
          table.remove(object.m_PromulgateTeamItemList, index)
          object.list_teams:removeItem(index - 1)
          object.list_teams:sizeChangedForShowMoreTips()
          break
        end
      end
    end
  end
  function object:deleteTeamObjFromPromulgateList(teamObj)
    if object.m_CurrShowTeamList == object.list_teams then
      for index, item in pairs(object.m_PromulgateTeamItemList) do
        if item == teamObj then
          table.remove(object.m_PromulgateTeamItemList, index)
          object.list_teams:removeItem(index - 1)
          object.list_teams:sizeChangedForShowMoreTips()
          break
        end
      end
    end
  end
  function object:StartUpdatingPromulgateTeamInfo()
    if object.m_IsDlgShow and not object.m_EverOpenPromulgateTeamInfoDlg then
      g_TeamMgr:OnOpenPromulgateTeamInfo()
      object.m_EverOpenPromulgateTeamInfoDlg = true
    end
  end
  function object:EndUpdatingPromulgateTeamInfo()
    if object.m_EverOpenPromulgateTeamInfoDlg then
      g_TeamMgr:OnClosePromulgateTeamInfo()
      object.m_EverOpenPromulgateTeamInfoDlg = false
    end
  end
  function object:CheckNeedUpdatingPromulgateTeamInfo_TeamExtend()
    if object.m_IsDlgShow and (object.layerteam:isVisible() or object.layerbangpai:isVisible()) and object.list_teams:isEnabled() then
      object:StartUpdatingPromulgateTeamInfo()
    end
  end
  function object:CheckNeedEndUpdatingPromulgateTeamInfo_TeamExtend()
    object:EndUpdatingPromulgateTeamInfo()
  end
  function object:ShowTeamChat()
    if object.m_CurrShowTeamList == object.list_teamchat then
      return
    end
    object.m_CurrShowTeamList = object.list_teamchat
    object.list_teams:setEnabled(false)
    object.list_teams:removeAllItems()
    object.list_teams:sizeChangedForShowMoreTips()
    object.list_teamchat:setEnabled(true)
    object.list_teamchat:removeAllItems()
    object.input_teamchat:SetFiledPlaceHolder("请点击输入", {fontSize = 22})
    object.input_teamchat:SetFieldText("")
    if object.input_teamchat:isVisible() then
      object.input_teamchat:setTouchEnabled(true)
    end
    object.m_PromulgateTeamItemList = {}
    if object.m_TeamChatBox == nil then
      object.m_TeamChatBox = CTeamChat.new(object.list_teamchat, handler(object, object.OnClickMessage))
    end
  end
  function object:onTeamChatKeyBoardListener(event, param)
    if event == TEXTFIELDEXTEND_EVENT_SEND_TEXT then
      local chatText = param
      if string.len(chatText) > 0 then
        if g_TeamMgr:getLocalPlayerTeamId() ~= 0 then
          g_MessageMgr:sendTeamMessage(chatText)
        else
          ShowNotifyTips("组队后才能在队伍频道里聊天")
        end
      end
    end
  end
  function object:SetTeamTip_PlayerJoinMyTeam(pid)
    if object.m_TeamChatBox then
      local pname = g_TeamMgr:getPlayerName(pid)
      if string.len(pname) > 0 then
        local info = g_TeamMgr:getPlayerInfo(pid)
        local zs = 0
        if info ~= nil then
          zs = info.zs
        end
        local color = NameColor_MainHero[zs] or ccc3(255, 255, 255)
        object.m_TeamChatBox:AddTeamTip(string.format("#<W>玩家# #<r:%d,g:%d,b:%d>%s# #<W>加入了队伍#", color.r, color.g, color.b, pname))
      end
    end
  end
  function object:SetTeamTip_PlayerLeaveMyTeam(pid)
    if object.m_TeamChatBox then
      local pname = g_TeamMgr:getPlayerName(pid)
      if string.len(pname) > 0 then
        local info = g_TeamMgr:getPlayerInfo(pid)
        local zs = 0
        if info ~= nil then
          zs = info.zs
        end
        local color = NameColor_MainHero[zs] or ccc3(255, 255, 255)
        object.m_TeamChatBox:AddTeamTip(string.format("#<W>玩家# #<r:%d,g:%d,b:%d>%s# #<W>离开了队伍#", color.r, color.g, color.b, pname))
      end
    end
  end
  function object:SetTeamTip_NewCaptain(pid)
    if object.m_TeamChatBox then
      local pname = g_TeamMgr:getPlayerName(pid)
      if string.len(pname) > 0 then
        local info = g_TeamMgr:getPlayerInfo(pid)
        local zs = 0
        if info ~= nil then
          zs = info.zs
        end
        local color = NameColor_MainHero[zs] or ccc3(255, 255, 255)
        object.m_TeamChatBox:AddTeamTip(string.format("#<W>玩家# #<r:%d,g:%d,b:%d>%s# #<W>成为了队长#", color.r, color.g, color.b, pname))
      end
    end
  end
  function object:Btn_TeamChatInsert(obj, t)
    if object.btn_voicepress_team:isVisible() then
      object:Btn_KeyBoardTeam()
    end
    if g_TeamMgr:getLocalPlayerTeamId() ~= 0 then
      object.input_teamchat:openInsertBoard()
    else
      ShowNotifyTips("组队后才能在队伍频道里聊天")
    end
  end
  function object:Btn_SendTeamChat(obj, t)
    if object.btn_voicepress_team:isVisible() then
      object:Btn_KeyBoardTeam()
    end
    if g_TeamMgr:getLocalPlayerTeamId() ~= 0 then
      local chatText = object.input_teamchat:GetFieldText()
      if 0 < string.len(chatText) then
        if g_MessageMgr:sendTeamMessage(chatText) then
          g_LocalPlayer:recordRecentChat(chatText)
          SendMessage(MsgID_Message_NewSendMsg, chatText)
          object.input_teamchat:SetFieldText("")
        end
      else
        ShowNotifyTips("请先输入聊天内容")
      end
    else
      ShowNotifyTips("组队后才能在队伍频道里聊天")
    end
  end
  function object:Btn_VoiceTeam(obj, t)
    object.btn_voice_team:setVisible(false)
    object.btn_voice_team:setTouchEnabled(false)
    object.btn_keyboard_team:setVisible(true)
    object.btn_keyboard_team:setTouchEnabled(true)
    object.input_teamchat:setVisible(false)
    object.input_teamchat:setTouchEnabled(false)
    object.inputbg_teamchat:setVisible(false)
    object.btn_voicepress_team:setVisible(true)
    object.btn_voicepress_team:setTouchEnabled(true)
    object.input_teamchat:CloseTheKeyBoard()
  end
  function object:Btn_KeyBoardTeam(obj, t)
    object.btn_voice_team:setVisible(true)
    object.btn_voice_team:setTouchEnabled(true)
    object.btn_keyboard_team:setVisible(false)
    object.btn_keyboard_team:setTouchEnabled(false)
    object.input_teamchat:setVisible(true)
    if object.m_LocalTeamId == 0 then
      object.input_teamchat:setTouchEnabled(false)
    else
      object.input_teamchat:setTouchEnabled(true)
    end
    object.inputbg_teamchat:setVisible(true)
    object.btn_voicepress_team:setVisible(false)
    object.btn_voicepress_team:setTouchEnabled(false)
  end
  function object:Clear_TeamExtend()
    object.input_teamchat:ClearTextFieldExtend()
    if object.m_TeamChatBox then
      object.m_TeamChatBox:Clear()
      object.m_TeamChatBox = nil
    end
    if object.btn_voicepress_team._VR_ParamFetchFunc then
      object.btn_voicepress_team._VR_ParamFetchFunc = nil
    end
    object:EndUpdatingPromulgateTeamInfo()
  end
  object:InitTeam()
end
