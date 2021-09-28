CYYIcon = class(".CYYIcon", function()
  return Widget:create()
end)
function CYYIcon:ctor(yyData, yyType, iconPath)
  self.m_YYData = yyData
  self.m_YYId = yyData.id
  if iconPath == nil then
    iconPath = "xiyou/ani/yyother.plist"
  end
  self.m_YYIcon = CreateSeqAnimation(iconPath)
  self:addNode(self.m_YYIcon)
  if yyType == 0 then
    self.m_YYIcon:setScaleX(-1)
  end
  self.m_YYIcon:setAnchorPoint(ccp(0, 0))
  self.m_YYIcon:playAniWithName("stop", 1, nil, false)
  self.m_YYIcon.__play = false
  local size = self.m_YYIcon:getContentSize()
  if yyData.read == 0 then
    self.m_UnreadIcon = display.newSprite("views/pic/pic_newtip.png")
    self:addNode(self.m_UnreadIcon)
    self.m_UnreadIcon:setPosition(ccp(size.width + 8, size.height - 5))
  end
  self:ignoreContentAdaptWithSize(false)
  self:setSize(CCSize(size.width, size.height))
  self:setNodeEventEnabled(true)
  MessageEventExtend.extend(self)
  self:ListenMessage(MsgID_Voice)
end
function CYYIcon:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_Voice_Play then
    if arg[1] == self.m_YYId and self.m_YYId ~= nil then
      if self.m_YYIcon and self.m_YYIcon.__play == false then
        self.m_YYIcon.__play = true
        self.m_YYIcon:playAniWithName("play", -1, nil, false)
        if self.m_UnreadIcon then
          self.m_UnreadIcon:removeFromParentAndCleanup(true)
          self.m_UnreadIcon = nil
        end
      end
      self.m_YYData.read = 1
    end
  elseif msgSID == MsgID_Voice_Stop and arg[1] == self.m_YYId and self.m_YYId ~= nil and self.m_YYIcon and self.m_YYIcon.__play == true then
    self.m_YYIcon.__play = false
    self.m_YYIcon:playAniWithName("stop", 1, nil, false)
  end
end
function CYYIcon:onCleanup()
  self:RemoveAllMessageListener()
end
CMsgBox = class("CMsgBox", CcsSubView)
function CMsgBox:ctor()
  CMsgBox.super.ctor(self, "views/msgbox.json")
  local btnBatchListener = {
    btn_chat_zoom = {
      listener = handler(self, self.OnBtn_Zoom),
      variName = "btn_chat_zoom"
    },
    btn_chat_setting = {
      listener = handler(self, self.OnBtn_Setting),
      variName = "btn_chat_setting"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_MsgsysEnabled = true
  self.m_SmallMode = true
  self.m_AddHeight = 120
  local x, y = self.btn_chat_zoom:getPosition()
  self.btn_chat_zoom.__initPos = ccp(x, y)
  self.chatbox_list = self:getNode("chatbox_list")
  local size = self.chatbox_list:getSize()
  self.chatbox_list.__initSize = CCSize(size.width, size.height)
  self.chatbox_list:setTouchEnabled(false)
  self.m_TextList = {}
  self.chatbox = self:getNode("chatbox")
  local size_2 = self.chatbox:getSize()
  self.chatbox.__initSize = CCSize(size_2.width, size_2.height)
  self.chatbox:setTouchEnabled(true)
  self.chatbox:addTouchEventListener(function(touchObj, t)
    if self.m_UINode == nil then
      return
    end
    if t == TOUCH_EVENT_BEGAN then
      self.chatbox:setScale(1.01)
      self.m_HasTouchMoved = false
    elseif t == TOUCH_EVENT_MOVED then
      local startPos = touchObj:getTouchStartPos()
      local movePos = touchObj:getTouchMovePos()
      if not self.m_HasTouchMoved and math.abs(startPos.x - movePos.x) + math.abs(startPos.y - movePos.y) > 40 then
        self.m_HasTouchMoved = true
        self.chatbox:setScale(1)
      end
    elseif t == TOUCH_EVENT_ENDED or t == TOUCH_EVENT_CANCELED then
      if not self.m_HasTouchMoved and g_SocialityDlg then
        if g_SocialityDlg:IsInChannel_Sys() then
          g_SocialityDlg:Btn_Group_Integration()
        end
        g_SocialityDlg:ShowDlg()
      end
      self.chatbox:setScale(1)
    end
  end)
  self:InitSetChannel()
  clickArea_check.extend(self)
  self:ListenMessage(MsgID_Message)
  self:ListenMessage(MsgID_Voice)
  self:ListenMessage(MsgID_Scene)
end
function CMsgBox:AddTxt(channelTxt, msg, msgColor, ftSize, channel, extraParam)
  local w = self.chatbox_list:getContentSize().width
  ftSize = ftSize or 18
  local content = CRichText.new({
    width = w,
    color = msgColor,
    fontSize = ftSize,
    clickTextHandler = handler(self, self.OnClickMessage)
  })
  content:addRichText(channelTxt)
  if extraParam and extraParam.yy ~= nil then
    do
      local yyIcon = CYYIcon.new(extraParam.yy, 1, "xiyou/ani/yyicon.plist")
      content:addOneNode({
        obj = yyIcon,
        isWidget = true,
        offXY = ccp(0, 0)
      })
      local yyData = extraParam.yy
      self:click_check_withObj(content, function()
        self:OnClickYY(yyIcon, yyData, channel)
      end, nil, nil, true)
      content:addRichTextEmpty(5)
      content:addRichText(string.format("%.1fs", yyData.time))
      content:addRichTextEmpty(5)
    end
  else
    self:click_check_withObj(content, function()
      self:CheckOpenSocialityDlg(channel)
    end, handler(self, self.OnTouchContent), nil, true)
  end
  content:addRichText(msg)
  self.chatbox_list:pushBackCustomItem(content)
  content.__channel = channel
  if channel == CHANNEL_EXTRA_TEAM then
    content.__teamId = extraParam.teamId
    content.__targetId = extraParam.targetId
  end
  self.m_TextList[#self.m_TextList + 1] = {
    channelTxt,
    msg,
    msgColor,
    ftSize,
    channel,
    extraParam
  }
  if self.chatbox_list:getCount() > 15 then
    self.chatbox_list:removeItem(0)
    table.remove(self.m_TextList, 1)
  end
end
function CMsgBox:OnClickYY(yyIcon, yyData, channel)
  if self.m_UINode == nil then
    return
  end
  if yyIcon == nil or yyIcon.__play == true then
    self:CheckOpenSocialityDlg(channel)
    return
  end
  local pcmString = yyData.voice
  local time = yyData.time
  local yyid = yyData.id
  if pcmString ~= nil and time ~= nil and yyid ~= nil then
    g_VoiceMgr:playPCMString(pcmString, yyid, time, nil, channel)
  else
    self:CheckOpenSocialityDlg(channel)
  end
end
function CMsgBox:CheckOpenSocialityDlg(channel)
  if self.m_UINode == nil then
    return
  end
  if g_SocialityDlg then
    g_SocialityDlg:ShowDlg()
    if channel == CHANNEL_TEAM or channel == CHANNEL_EXTRA_TEAM then
      g_SocialityDlg:Btn_Group_Team()
    elseif channel == CHANNEL_BP_MSG or channel == CHANNEL_BP_TIP then
      g_SocialityDlg:Btn_Group_Faction()
    else
      g_SocialityDlg:Btn_Group_Integration()
    end
  end
end
function CMsgBox:OnTouchContent(touch)
  if self.m_UINode == nil then
    return
  end
  if touch then
    self.chatbox:setScale(1.01)
  else
    self.chatbox:setScale(1)
  end
end
function CMsgBox:OnMessage(msgSID, ...)
  if self.m_MsgsysEnabled ~= true then
    return
  end
  local arg = {
    ...
  }
  if msgSID == MsgID_Message_TeamMsg then
    self:onReceiveTeamMsg(arg[1], arg[2], arg[4], arg[5])
  elseif msgSID == MsgID_Message_WorldMsg then
    self:onReceiveWorldMsg(arg[1], arg[2], arg[3], arg[5], arg[6])
  elseif msgSID == MsgID_Message_LocalMsg then
    self:onReceiveLocalMsg(arg[1], arg[2], arg[3], arg[5], arg[6])
  elseif msgSID == MsgID_Message_LocalChannelSysMsg then
    print("bbbbb")
    self:onReceiveLocalChannelSysMsg(arg[1], arg[2])
  elseif msgSID == MsgID_Message_SysMsg then
    self:onReceiveSysMsg(arg[1])
  elseif msgSID == MsgID_Message_HelpTip then
    self:onReceiveHelpTip(arg[1])
  elseif msgSID == MsgID_Message_NewPromulgateTeam then
    self:onReceiveNewPromulgateTeam(arg[1], arg[2], arg[3])
  elseif msgSID == MsgID_Message_UpdatePromulgateTeam then
    self:onReceiveUpdatePromulgateTeam(arg[1], arg[2], arg[3])
  elseif msgSID == MsgID_Message_CommonTip then
    self:onReceiveCommonTip(arg[1])
  elseif msgSID == MsgID_Message_BangPaiMsg then
    self:onReceiveBpMsg(arg[1], arg[2], arg[3], arg[5], arg[6])
  elseif msgSID == MsgID_Message_BangPaiTip then
    self:onReceiveBpTip(arg[1])
  elseif msgSID == MsgID_Message_KuaiXunTip then
    self:onReceiveKuaixunTip(arg[1])
  elseif msgSID == MsgID_Message_XinXiTip then
  elseif msgSID == MsgID_Message_XiaoLaBa then
    print(" 收到小喇叭信息*******", arg[1])
  elseif msgSID == MsgID_Scene_MsgBoxSmallMode then
    self:checkSmallMode(arg[1])
  elseif msgSID == MsgID_Scene_SelChannel then
    self:InitSetChannel()
  end
end
function CMsgBox:AddNewMainMsg(channel, param)
  local channelTxt = ""
  local msg, msgColor
  local ftSize = 18
  local extraParam = {}
  if channel == CHANNEL_TEAM then
    if not self.m_ShowMsg_Team then
      return
    end
    local pid = param.i_pid
    msg = param.s_msg
    local name = g_TeamMgr:getPlayerName(pid)
    local zs = g_TeamMgr:getPlayerZhuanSheng(pid)
    local color = NameColor_MainHero[zs] or ccc3(255, 255, 255)
    msgColor = MsgColor_TeamChannel
    if param.vip == VIP_LELVEL_ZHUBO then
      channelTxt = string.format("#<Channel:%d,r:%d,g:%d,b:%d>【%s】#", CHANNEL_ZHUBO, color.r, color.g, color.b, name)
    else
      channelTxt = string.format("#<Channel:%d,r:%d,g:%d,b:%d>【%s】#", channel, color.r, color.g, color.b, name)
    end
    extraParam.yy = param.yy
  elseif channel == CHANNEL_WOLRD then
    if not self.m_ShowMsg_World then
      return
    end
    msg = param.s_msg
    local name = param.t_pInfo.name or ""
    local zs = param.t_pInfo.zs or 0
    local color = NameColor_MainHero[zs] or ccc3(255, 255, 255)
    msgColor = MsgColor_WolrdChannel
    if param.vip == VIP_LELVEL_ZHUBO then
      channelTxt = string.format("#<Channel:%d,r:%d,g:%d,b:%d>【%s】#", CHANNEL_ZHUBO, color.r, color.g, color.b, name)
    else
      channelTxt = string.format("#<Channel:%d,r:%d,g:%d,b:%d>【%s】#", channel, color.r, color.g, color.b, name)
    end
    extraParam.yy = param.yy
  elseif channel == CHANNEL_LOCAL then
    if not self.m_ShowMsg_Local then
      return
    end
    msg = param.s_msg
    local name = param.t_pInfo.name or ""
    local zs = param.t_pInfo.zs or 0
    local color = NameColor_MainHero[zs] or ccc3(255, 255, 255)
    msgColor = MsgColor_LocalChannel
    if param.vip == VIP_LELVEL_ZHUBO then
      channelTxt = string.format("#<Channel:%d,r:%d,g:%d,b:%d>【%s】#", CHANNEL_ZHUBO, color.r, color.g, color.b, name)
    else
      channelTxt = string.format("#<Channel:%d,r:%d,g:%d,b:%d>【%s】#", channel, color.r, color.g, color.b, name)
    end
    extraParam.yy = param.yy
  elseif channel == CHANNEL_LOCALSYS then
    if not self.m_ShowMsg_Local then
      return
    end
    msg = param.s_msg
    msgColor = MsgColor_LocalChannel
    channelTxt = string.format("#<Channel:%d># ", channel)
  elseif channel == CHANNEL_SYS then
    msg = param.s_msg
    msgColor = MsgColor_SysChannel
    channelTxt = string.format("#<Channel:%d># ", channel)
  elseif channel == CHANNEL_HELP then
    msg = param.s_msg
    msgColor = MsgColor_HelpChannel
    channelTxt = string.format("#<Channel:%d># ", channel)
  elseif channel == CHANNEL_KUAI_XUN then
    msg = param.s_msg
    msgColor = MsgColor_KuaixunChannel
    channelTxt = string.format("#<Channel:%d># ", channel)
  elseif channel == CHANNEL_EXTRA_TEAM then
    if not self.m_ShowMsg_Team then
      return
    end
    local teamId = param.teamId
    msg = param.s_msg
    local targetId = param.tId
    if targetId == PromulgateTeamTarget_BangPai then
      msgColor = MsgColor_BpChannel
      channelTxt = string.format("#<Channel:%d># ", CHANNEL_BP_TIP)
    else
      msgColor = MsgColor_TeamChannel
      channelTxt = string.format("#<Channel:%d># ", CHANNEL_TEAM)
    end
    if param.isUpdate == true then
      self:checkUpdateExistTeamMsg(teamId, targetId, channel, channelTxt, msg, msgColor, ftSize)
      return
    end
    extraParam.teamId = teamId
    extraParam.targetId = targetId
  elseif channel == CHANNEL_COMMON then
    channelTxt = string.format("#<Channel:%d># ", CHANNEL_COMMON)
    msg = param.s_msg
  elseif channel == CHANNEL_BP_MSG then
    if not self.m_ShowMsg_Bp then
      return
    end
    msg = param.s_msg
    local name = param.t_pInfo.name or ""
    local zs = param.t_pInfo.zs or 0
    local color = NameColor_MainHero[zs] or ccc3(255, 255, 255)
    msgColor = MsgColor_BpChannel
    if param.vip == VIP_LELVEL_ZHUBO then
      channelTxt = string.format("#<Channel:%d,r:%d,g:%d,b:%d>【%s】#", CHANNEL_ZHUBO, color.r, color.g, color.b, name)
    else
      channelTxt = string.format("#<Channel:%d,r:%d,g:%d,b:%d>【%s】#", channel, color.r, color.g, color.b, name)
    end
    extraParam.yy = param.yy
  elseif channel == CHANNEL_BP_TIP then
    if not self.m_ShowMsg_Bp then
      return
    end
    msg = param.s_msg
    msgColor = MsgColor_BpChannel
    channelTxt = string.format("#<Channel:%d># ", CHANNEL_BP_TIP)
  end
  if msg ~= nil then
    self:AddTxt(channelTxt, msg, msgColor, ftSize, channel, extraParam)
    local act1 = CCDelayTime:create(0.01)
    local act2 = CCCallFunc:create(function()
      self.chatbox_list:refreshView()
      self.chatbox_list:jumpToBottom()
    end)
    self:stopAllActions()
    self:runAction(transition.sequence({act1, act2}))
  end
end
function CMsgBox:onReceiveTeamMsg(pid, msg, yy, vip)
  if g_TeamMgr:getLocalPlayerTeamId() ~= 0 then
    self:AddNewMainMsg(CHANNEL_TEAM, {
      s_msg = msg,
      i_pid = pid,
      yy = yy,
      vip = vip
    })
  end
end
function CMsgBox:onReceiveWorldMsg(pid, pInfo, msg, yy, vip)
  self:AddNewMainMsg(CHANNEL_WOLRD, {
    s_msg = msg,
    i_pid = pid,
    t_pInfo = pInfo,
    yy = yy,
    vip = vip
  })
end
function CMsgBox:onReceiveLocalMsg(pid, pInfo, msg, yy, vip)
  self:AddNewMainMsg(CHANNEL_LOCAL, {
    s_msg = msg,
    i_pid = pid,
    t_pInfo = pInfo,
    yy = yy,
    vip = vip
  })
end
function CMsgBox:onReceiveLocalChannelSysMsg(msg, npcId)
  self:AddNewMainMsg(CHANNEL_LOCALSYS, {s_msg = msg, npcId = npcId})
end
function CMsgBox:onReceiveSysMsg(msg)
  self:AddNewMainMsg(CHANNEL_SYS, {s_msg = msg})
end
function CMsgBox:onReceiveHelpTip(msg)
  self:AddNewMainMsg(CHANNEL_HELP, {s_msg = msg})
end
function CMsgBox:onReceiveKuaixunTip(msg)
  self:AddNewMainMsg(CHANNEL_KUAI_XUN, {s_msg = msg})
end
function CMsgBox:onReceiveNewPromulgateTeam(teamId, msg, targetId)
  self:AddNewMainMsg(CHANNEL_EXTRA_TEAM, {
    teamId = teamId,
    s_msg = msg,
    tId = targetId
  })
end
function CMsgBox:onReceiveUpdatePromulgateTeam(teamId, msg, targetId)
  self:AddNewMainMsg(CHANNEL_EXTRA_TEAM, {
    teamId = teamId,
    s_msg = msg,
    tId = targetId,
    isUpdate = true
  })
end
function CMsgBox:onReceiveCommonTip(msg)
  self:AddNewMainMsg(CHANNEL_COMMON, {s_msg = msg})
end
function CMsgBox:onReceiveBpMsg(pid, pInfo, msg, yy, vip)
  self:AddNewMainMsg(CHANNEL_BP_MSG, {
    s_msg = msg,
    i_pid = pid,
    t_pInfo = pInfo,
    yy = yy,
    vip = vip
  })
end
function CMsgBox:onReceiveBpTip(msg)
  self:AddNewMainMsg(CHANNEL_BP_TIP, {s_msg = msg})
end
function CMsgBox:GetContent()
  return self.m_TextList
end
function CMsgBox:SetContent(textList)
  self.chatbox_list:removeAllItems()
  self.m_TextList = {}
  for _, d in pairs(textList) do
    self:AddTxt(d[1], d[2], d[3], d[4], d[5], d[6])
  end
  local act1 = CCDelayTime:create(0.01)
  local act2 = CCCallFunc:create(function()
    self.chatbox_list:refreshView()
    self.chatbox_list:jumpToBottom()
  end)
  self:stopAllActions()
  self:runAction(transition.sequence({act1, act2}))
end
function CMsgBox:checkUpdateExistTeamMsg(teamId, targetId, channel, channelTxt, msg, msgColor, ftSize)
  local cnt = self.chatbox_list:getCount()
  for index = cnt - 1, 0, -1 do
    local item = self.chatbox_list:getItem(index)
    if item.__channel == channel and item.__teamId == teamId and item.__targetId == targetId then
      local w = self.chatbox_list:getContentSize().width
      ftSize = ftSize or 18
      local content = CRichText.new({
        width = w,
        color = msgColor,
        fontSize = ftSize,
        clickTextHandler = handler(self, self.OnClickMessage)
      })
      content:addRichText(channelTxt)
      content:addRichText(msg)
      content.__channel = channel
      content.__teamId = teamId
      content.__targetId = targetId
      self.chatbox_list:insertCustomItem(content, index)
      self.chatbox_list:removeItem(index + 1)
      local oldData = self.m_TextList[index + 1]
      if oldData then
        oldData[1] = channelTxt
        oldData[2] = msg
        oldData[3] = msgColor
        oldData[4] = ftSize
      end
      break
    end
  end
end
function CMsgBox:InitSetChannel()
  local data = g_LocalPlayer:getSelectChannel() or {}
  self.m_ShowMsg_Team = data[1] ~= 0
  self.m_ShowMsg_Bp = data[2] ~= 0
  self.m_ShowMsg_World = data[3] ~= 0
  self.m_ShowMsg_Local = data[4] ~= 0
end
function CMsgBox:OnClickMessage(obj, msgType, msgPram)
  if msgType == CRichText_MessageType_MakeTeam then
    g_TeamMgr:send_ApplyToTeam(msgPram.teamId)
  elseif msgType == CRichText_MessageType_Item then
    if msgPram then
      local playerId = msgPram.playerId
      local itemId = msgPram.itemId
      local itemTypeId = msgPram.itemTypeId
      self:onCheckItemInMsg(playerId, itemId, itemTypeId)
    end
  elseif msgType == CRichText_MessageType_Pet then
    if msgPram then
      local playerId = msgPram.playerId
      local petId = msgPram.petId
      local petTypeId = msgPram.petTypeId
      self:onCheckPetInMsg(playerId, petId)
    end
  elseif msgType == CRichText_MessageType_Skill then
    if msgPram then
      local playerId = msgPram.playerId
      local petId = msgPram.petId
      local skillId = msgPram.itemTypeId
      local petTypeId = msgPram.petTypeId
      local size = self:getSize()
      local x, y = self:getPosition()
      local delBtnFlag = false
      local isChatSys = true
      if g_Click_Skill_View ~= nil then
        g_Click_Skill_View:removeFromParentAndCleanup(true)
      end
      g_Click_Skill_View = CSkillDetailView.new(petId, skillId, false, {
        x = x + size.width / 2,
        y = y + size.height / 2,
        w = size.width,
        h = size.height
      }, petTypeId, playerId, delBtnFlag, isBaitanPlayer, isChatSys)
      if g_Click_Skill_View then
        self.m_isOpenSkillView = true
      end
    end
  elseif msgType == CRichText_MessageType_BpVote then
    netsend.netbangpai.voteRejectBpLeader()
  elseif msgType == CRichText_MessageType_WatchWar then
    if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
      ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
      return
    end
    if msgPram then
      local warId = msgPram.warId
      local playerId = msgPram.playerId
      if warId and playerId then
        netsend.netteamwar.requestWatchPlayerWar(playerId, warId)
      end
    end
  elseif msgType == CRichText_MessageType_ToNPC then
    if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
      ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
      return
    end
    if g_WarScene then
      ShowNotifyTips("战斗中，不能跳转")
      return
    end
    if msgPram then
      local npcID = msgPram.npcId
      local param = msgPram.itemId
      local missType = msgPram.itemTypeId
      self:onCheckToNPCInMsg(npcID, param, missType)
    end
  end
end
function CMsgBox:onCheckToNPCInMsg(npcId, param, missType)
  if missType == CRichText_MessageNPC_MarryTree then
    g_MapMgr:AutoRouteToNpc(npcId, function(isSucceed)
      if isSucceed then
        openMarryTreeView(param)
      end
    end)
  elseif missType == CRichText_MessageNPC_HunChe then
    if g_HunyinMgr and not g_HunyinMgr:IsInXunYouTime() then
      ShowNotifyTips("#<E:16>#你来晚了，巡游已结束。")
      return
    end
    if g_MapMgr and g_HunyinMgr then
      if g_MapMgr:getCurMapId() == MapId_Changan then
        local x, y = GetHuochePostition()
        if x ~= nil and y ~= nil then
          local mapView = g_MapMgr:getMapViewIns()
          if mapView then
            local gx, gy = mapView:getGridByPos(x, y)
            g_MapMgr:AutoRoute(MapId_Changan, {
              gx,
              128 - gy
            }, function(isSucceed)
            end)
          end
        end
      else
        g_MapMgr:AutoRouteToNpc(NPC_HongNiang_ID, function(isSucceed)
          if isSucceed then
            local mapView = g_MapMgr:getMapViewIns()
            local x, y = GetHuochePostition()
            if x ~= nil and y ~= nil and mapView then
              local gx, gy = mapView:getGridByPos(x, y)
              g_MapMgr:AutoRoute(MapId_Changan, {
                gx,
                128 - gy
              }, function(isSucceed)
              end)
            end
          end
        end, true)
      end
    end
  else
    print("前往到某个npc ---> 还没定义该类型任务：", param)
  end
end
function CMsgBox:onCheckItemInMsg(playerId, itemId, itemTypeId)
  print("-->>onCheckItemInMsg:", playerId, itemId, itemTypeId)
  ShowChatDetail_Item(playerId, itemId, itemTypeId)
end
function CMsgBox:onCheckPetInMsg(playerId, petId)
  print("-->>onCheckPetInMsg:", playerId, petId)
  ShowChatDetail_Pet(playerId, petId)
end
function CMsgBox:setCheckDetailDlg(dlg)
  if dlg == nil then
    return
  end
  local size = self.m_UINode:getContentSize()
  local x, y = self.m_UINode:getPosition()
  dlg:setPosition(ccp(size.width, 10))
end
function CMsgBox:OnBtn_Zoom()
  self.m_SmallMode = not self.m_SmallMode
  self:SetSmallModeAdjust(self.m_SmallMode)
end
function CMsgBox:getIsSmallMode()
  return self.m_SmallMode
end
function CMsgBox:SetSmallModeAdjust(isSmallMode, msgFlag)
  self.m_SmallMode = isSmallMode
  if isSmallMode == true then
    self.chatbox_list:ignoreContentAdaptWithSize(false)
    self.chatbox_list:setSize(self.chatbox_list.__initSize)
    self.chatbox:ignoreContentAdaptWithSize(false)
    self.chatbox:setSize(self.chatbox.__initSize)
    self.chatbox_list:refreshView()
    self.chatbox_list:jumpToBottom()
    self.btn_chat_zoom:setPosition(self.btn_chat_zoom.__initPos)
    self.btn_chat_zoom:setScaleY(1)
    if msgFlag ~= false then
      SendMessage(MsgID_Scene_MsgBoxSmallMode, true, self.m_AddHeight)
    end
  else
    self.chatbox_list:ignoreContentAdaptWithSize(false)
    self.chatbox_list:setSize(CCSize(self.chatbox_list.__initSize.width, self.chatbox_list.__initSize.height + self.m_AddHeight))
    self.chatbox:ignoreContentAdaptWithSize(false)
    self.chatbox:setSize(CCSize(self.chatbox.__initSize.width, self.chatbox.__initSize.height + self.m_AddHeight))
    self.chatbox_list:refreshView()
    self.chatbox_list:jumpToBottom()
    self.btn_chat_zoom:setPosition(ccp(self.btn_chat_zoom.__initPos.x, self.btn_chat_zoom.__initPos.y + self.m_AddHeight))
    self.btn_chat_zoom:setScaleY(-1)
    if msgFlag ~= false then
      SendMessage(MsgID_Scene_MsgBoxSmallMode, false, self.m_AddHeight)
    end
  end
end
function CMsgBox:checkSmallMode(isSmallMode)
  if self.m_SmallMode == isSmallMode then
    return
  end
  self:SetSmallModeAdjust(isSmallMode, false)
end
function CMsgBox:getAddHeight()
  return self.m_AddHeight
end
function CMsgBox:OnBtn_Setting()
  g_selectChannel = CSelectChannel.new()
  getCurSceneView():addSubView({
    subView = g_selectChannel,
    zOrder = MainUISceneZOrder.menuView
  })
end
function CMsgBox:ClearBox()
  self.chatbox_list:removeAllItems()
  self.m_MsgsysEnabled = false
end
function CMsgBox:reloadBox()
  self:InitSetChannel()
  self.m_MsgsysEnabled = true
end
function CMsgBox:Clear()
end
CSelectChannel = class("CSelectChannel", CcsSubView)
function CSelectChannel:ctor()
  CSelectChannel.super.ctor(self, "views/selectchannel.json", {isAutoCenter = true})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close"
    },
    btn_back = {
      listener = handler(self, self.OnBtn_Back),
      variName = "btn_back"
    },
    btn_ok = {
      listener = handler(self, self.OnBtn_Ok),
      variName = "btn_ok"
    },
    btn_show_name = {
      listener = handler(self, self.OnShowName),
      variName = "btn_show_name"
    },
    btn_team = {
      listener = handler(self, self.OnBtn_Team),
      variName = "btn_team"
    },
    btn_bp = {
      listener = handler(self, self.OnBtn_Bp),
      variName = "btn_bp"
    },
    btn_world = {
      listener = handler(self, self.OnBtn_World),
      variName = "btn_world"
    },
    btn_local = {
      listener = handler(self, self.OnBtn_Local),
      variName = "btn_local"
    },
    btn_team_voice = {
      listener = handler(self, self.OnBtn_Team_voice),
      variName = "btn_team_voice"
    },
    btn_bp_voice = {
      listener = handler(self, self.OnBtn_Bp_voice),
      variName = "btn_bp_voice"
    },
    btn_world_voice = {
      listener = handler(self, self.OnBtn_World_voice),
      variName = "btn_world_voice"
    },
    btn_local_voice = {
      listener = handler(self, self.OnBtn_Local_voice),
      variName = "btn_local_voice"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  local data = g_LocalPlayer:getSelectChannel() or {}
  self.m_SelChannel = DeepCopyTable(data)
  self.sel_team = self:getNode("sel_team")
  self.sel_bp = self:getNode("sel_bp")
  self.sel_world = self:getNode("sel_world")
  self.sel_local = self:getNode("sel_local")
  self.sel_team:setVisible(self.m_SelChannel[1] ~= 0)
  self.sel_bp:setVisible(self.m_SelChannel[2] ~= 0)
  self.sel_world:setVisible(self.m_SelChannel[3] ~= 0)
  self.sel_local:setVisible(self.m_SelChannel[4] ~= 0)
  self.sel_team_voice = self:getNode("sel_team_voice")
  self.sel_bp_voice = self:getNode("sel_bp_voice")
  self.sel_world_voice = self:getNode("sel_world_voice")
  self.sel_local_voice = self:getNode("sel_local_voice")
  local initSysSetting = g_LocalPlayer:getSysSetting()
  self.sel_team_voice:setVisible(initSysSetting.teamvoice ~= false)
  self.sel_bp_voice:setVisible(initSysSetting.bpvoice ~= false)
  self.sel_world_voice:setVisible(initSysSetting.worldvoice ~= false)
  self.sel_local_voice:setVisible(initSysSetting.localvoice ~= false)
  self.ly_name_list = self:getNode("ly_name_list")
  self.ly_setting = self:getNode("ly_setting")
  self.ly_name_list:setEnabled(false)
  self.ly_name_list:setVisible(false)
  self.name_list = self:getNode("name_list")
  self.isShowNameList = false
  self:enableCloseWhenTouchOutside(self:getNode("bg"), true)
end
function CSelectChannel:OnBtn_Close()
  self:CloseSelf()
end
function CSelectChannel:OnBtn_Ok()
  local bpvoice = self.sel_bp_voice:isVisible()
  local teamvoice = self.sel_team_voice:isVisible()
  local worldvoice = self.sel_world_voice:isVisible()
  local localvoice = self.sel_local_voice:isVisible()
  local initSysSetting = g_LocalPlayer:getSysSetting()
  initSysSetting.teamvoice = teamvoice
  initSysSetting.bpvoice = bpvoice
  initSysSetting.worldvoice = worldvoice
  initSysSetting.localvoice = localvoice
  g_LocalPlayer:recordPushSetting(initSysSetting)
  local v1, v2, v3, v4 = 0, 0, 0, 0
  if self.sel_team:isVisible() then
    v1 = 1
  end
  if self.sel_bp:isVisible() then
    v2 = 1
  end
  if self.sel_world:isVisible() then
    v3 = 1
  end
  if self.sel_local:isVisible() then
    v4 = 1
  end
  g_LocalPlayer:selectChannel({
    v1,
    v2,
    v3,
    v4
  })
  g_LocalPlayer:SaveArchive()
  self:CloseSelf()
  SendMessage(MsgID_Scene_SelChannel)
  ShowNotifyTips("设置成功")
end
function CSelectChannel:OnShowName()
  local hasitem = false
  if g_MessageMgr then
    local nameList = g_MessageMgr:getPingBiList()
    if nameList then
      for k, v in pairs(nameList) do
        if v ~= nil then
          hasitem = true
          break
        end
      end
    end
  end
  self.ly_setting:setVisible(hasitem == false)
  self.ly_setting:setEnabled(hasitem == false)
  self.ly_name_list:setEnabled(hasitem)
  self.ly_name_list:setVisible(hasitem)
  self.isShowNameList = hasitem
  if hasitem == false then
    ShowNotifyTips("你没有屏蔽过任何人")
  else
    self:flushNameList()
  end
end
function CSelectChannel:OnBtn_Back()
  self.ly_setting:setVisible(true)
  self.ly_setting:setEnabled(true)
  self.ly_name_list:setEnabled(false)
  self.ly_name_list:setVisible(false)
  self.isShowNameList = false
end
function CSelectChannel:flushNameList()
  if g_MessageMgr == nil or self.isShowNameList == false then
    return
  end
  local nameList = g_MessageMgr:getPingBiList()
  if nameList then
    self.name_list:removeAllItems()
    for pid, pinfo in pairs(nameList) do
      if pinfo then
        do
          local nameColor = NameColor_MainHero[pinfo.zs]
          local item = CShieldPlayerItem.new(pinfo, function(mpid)
            local dlg = CPopWarning.new({
              title = "提示",
              text = string.format(" 你确定要移除屏蔽玩家#<r:%d,g:%d,b:%d>%s#吗？ ", nameColor.r, nameColor.g, nameColor.b, pinfo.name),
              confirmFunc = function(...)
                netsend.netbaseptc.removePingbiName(mpid)
              end,
              confirmText = "确定",
              cancelText = "取消"
            })
            dlg:ShowCloseBtn(false)
          end, nil)
          self.name_list:insertCustomItem(item:getUINode(), 0)
        end
      end
    end
  end
end
function CSelectChannel:removeOnePingBiUser(pid)
  if self.name_list then
    for i = 0, self.name_list:getCount() - 1 do
      local item = self.name_list:getItem(i)
      if item ~= nil and item.m_UIViewParent ~= nil and item.m_UIViewParent.m_pid == pid then
        self.name_list:removeItem(i)
      end
    end
  end
  if self.name_list and 0 >= self.name_list:getCount() then
    self:OnBtn_Back()
  end
end
function CSelectChannel:OnBtn_Team()
  self.sel_team:setVisible(not self.sel_team:isVisible())
end
function CSelectChannel:OnBtn_Bp()
  self.sel_bp:setVisible(not self.sel_bp:isVisible())
end
function CSelectChannel:OnBtn_World()
  self.sel_world:setVisible(not self.sel_world:isVisible())
end
function CSelectChannel:OnBtn_Local()
  self.sel_local:setVisible(not self.sel_local:isVisible())
end
function CSelectChannel:OnBtn_Team_voice()
  self.sel_team_voice:setVisible(not self.sel_team_voice:isVisible())
end
function CSelectChannel:OnBtn_Bp_voice()
  self.sel_bp_voice:setVisible(not self.sel_bp_voice:isVisible())
end
function CSelectChannel:OnBtn_World_voice()
  self.sel_world_voice:setVisible(not self.sel_world_voice:isVisible())
end
function CSelectChannel:OnBtn_Local_voice()
  self.sel_local_voice:setVisible(not self.sel_local_voice:isVisible())
end
function CSelectChannel:Clear()
  if g_selectChannel == self then
    g_selectChannel = nil
  end
end
CShieldPlayerItem = class("CShieldPlayerItem", CcsSubView)
function CShieldPlayerItem:ctor(pif, deleteListener)
  CShieldPlayerItem.super.ctor(self, "views/noteam_item.json")
  local btnBatchListener = {
    btn_delete = {
      listener = handler(self, self.OnBtn_Delete),
      variName = "btn_delete"
    }
  }
  dump(pif, "CShieldPlayerItem:ctor")
  pif = pif or {}
  self.m_pid = pif.pid
  self.m_lv = pif.lv
  self.m_zs = pif.zs
  self.m_rtype = pif.rtype
  self.m_name = pif.name
  self.m_deleteListener = deleteListener
  self:addBatchBtnListener(btnBatchListener)
  self.headpos = self:getNode("headpos")
  self.txt_name = self:getNode("txt_name")
  self.txt_zs = self:getNode("txt_zs")
  self.txt_lv = self:getNode("txt_lv")
  self.txt_lv_title = self:getNode("txt_lv_title")
  self.headpos:setVisible(false)
  self:SetRace()
  self:setBaseInfo()
end
function CShieldPlayerItem:setBaseInfo()
  local headParent = self.headpos:getParent()
  local hx, hy = self.headpos:getPosition()
  local zOrder = self.headpos:getZOrder()
  local headIcon = createClickHead({
    roleTypeId = self.m_rtype,
    autoSize = nil,
    clickListener = nil,
    noBgFlag = nil,
    offx = nil,
    offy = nil,
    clickDel = nil,
    LongPressTime = nil,
    LongPressListener = nil,
    LongPressEndListner = nil
  })
  headParent:addChild(headIcon, zOrder)
  headIcon:setPosition(ccp(hx, hy + 7))
  headIcon:setTouchEnabled(touchEnabled)
  self.m_HeadIcon = headIcon
  self.txt_name:setText(self.m_name)
  local nameColor = NameColor_MainHero[zs]
  if nameColor then
    self.txt_name:setColor(nameColor)
  end
  self.txt_zs:setText(tostring(self.m_zs))
  self.txt_lv:setText(tostring(self.m_lv))
  local x, y = self.txt_lv:getPosition()
  local size = self.txt_lv:getContentSize()
  self.txt_lv_title:setPosition(ccp(x + size.width + 4, y))
end
function CShieldPlayerItem:OnBtn_Delete()
  if self.m_deleteListener ~= nil and type(self.m_deleteListener) == "function" then
    self.m_deleteListener(self.m_pid)
  end
end
function CShieldPlayerItem:SetRace()
  self.txt_race = self:getNode("txt_race")
  local herodata = data_Hero[self.m_rtype]
  if herodata ~= nil then
    local race = herodata.RACE
    if race ~= nil then
      local raceTxt = RACENAME_DICT[race] or "-族"
      self.txt_race:setText(raceTxt)
    else
      self.txt_race:setText("-族")
    end
  else
    self.txt_race:setText("-族")
  end
end
