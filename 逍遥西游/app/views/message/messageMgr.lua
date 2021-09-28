local DefineMaxPrivateMsgCache = 50
local DefineMaxYYMsgCache = 50
local DefineHelpTipCD = 300
local msgArchivePath = device.writablePath .. "msgdata/"
os.mkdir(msgArchivePath)
local CMessageMgr = class(".CMessageMgr", nil)
function CMessageMgr:ctor()
  self.m_PrivateMessage = {}
  self.m_BangPaiMsgCache = {}
  self.m_YYMsgCache = {}
  self.m_WorldPlayerInfo = {}
  self.m_LocalPlayerInfo = {}
  self.m_BpPlayerInfo = {}
  self.m_LaBaPlayerInfo = {}
  self.m_WorldChatTimeRestTime = 0
  self.m_BangPaiChatTimeRestTime = 0
  self.m_LastTimeRecordOfWolrd = 0
  self.m_LastTimeRecordOfBangPai = 0
  self.m_LocalChatTimeRestTime = 0
  self.m_LastTimeRecordOfLocal = 0
  local tempData = data_FunctionUnlock[OPEN_Func_WorldChat] or {}
  self.Level_SendWorldMsg = tempData.lv
  local tempData = data_FunctionUnlock[OPEN_Func_LocalChat] or {}
  self.Level_SendLocalMsg = tempData.lv
  self.m_CacheShowMessageForIntchat = {}
  self.m_PingBiUsers = {}
  self.m_AE_XxteaKeys = "lk>-=45L"
  MessageEventExtend.extend(self)
  self:ListenMessage(MsgID_Device)
  self:ListenMessage(MsgID_Friends)
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_BP)
  self:ListenMessage(MsgID_Scene)
  self.m_ScheduleHandler = scheduler.scheduleGlobal(handler(self, self.RandomHelpTip), DefineHelpTipCD)
end
function CMessageMgr:testHelpTip()
  if self.m_ScheduleHandler then
    scheduler.unscheduleGlobal(self.m_ScheduleHandler)
    self.m_ScheduleHandler = nil
  end
  self.m_ScheduleHandler = scheduler.scheduleGlobal(handler(self, self.RandomHelpTip), 5)
end
function CMessageMgr:getPrivateMessage(pid)
  local msgInfo = self.m_PrivateMessage[pid]
  if msgInfo == nil then
    msgInfo = self:LoadLocalFriendChatMsg(pid)
    self.m_PrivateMessage[pid] = msgInfo
    self:setReadPrivateMessage(pid)
  end
  return msgInfo
end
function CMessageMgr:existUnreadPrivateMessage(pid)
  local msgList = self.m_PrivateMessage[pid]
  if msgList == nil then
    return 0
  else
    local unreadCnt = 0
    for i = #msgList, 1, -1 do
      local temp = msgList[i]
      if temp[4] == 0 then
        unreadCnt = unreadCnt + 1
      elseif temp[3] == pid then
        break
      end
    end
    return unreadCnt
  end
end
function CMessageMgr:setReadPrivateMessage(pid)
  local msgList = self.m_PrivateMessage[pid]
  if msgList == nil then
    return
  end
  for i = #msgList, 1, -1 do
    local temp = msgList[i]
    if temp[4] == 0 then
      temp[4] = 1
    elseif temp[3] == pid then
      break
    end
  end
end
function CMessageMgr:getPlayerInfo(pid)
  return self.m_WorldPlayerInfo[pid]
end
function CMessageMgr:getLaBaPlayerInfo(pid)
  return self.m_LaBaPlayerInfo[pid]
end
function CMessageMgr:getPlayerInfoOfLocal(pid)
  return self.m_LocalPlayerInfo[pid]
end
function CMessageMgr:getBpPlayerInfo(pid)
  return self.m_BpPlayerInfo[pid]
end
function CMessageMgr:isEnabledLocalChannelOfCurrMap()
  if g_MapMgr == nil then
    return false
  end
  if g_MapMgr:IsInBangPaiWarMap() or g_MapMgr:IsInYiZhanDaoDiMap() or g_MapMgr:IsInXueZhanShaChangMap() or g_MapMgr:IsInDuelMap() then
    return true
  else
    return false
  end
end
function CMessageMgr:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_EnterBackground then
    self:SaveMsgToLocal()
  elseif msgSID == MsgID_Friends_DeleteFirend then
    local pid = arg[1]
    self.m_PrivateMessage[pid] = nil
    self:DeleteFriendChatMsgToLocal(pid)
  elseif msgSID == MsgID_HeroUpdate then
    local param = arg[1]
    if param.pid == g_LocalPlayer:getPlayerId() and param.heroId == g_LocalPlayer:getMainHeroId() then
      local pro = param.pro
      if pro[PROPERTY_ROLELEVEL] ~= nil then
        self:InitHelpTip()
      end
    end
  elseif msgSID == MsgID_BP_LocalInfo then
    local info = arg[1]
    if info.i_bpid == 0 then
      self.m_BpPlayerInfo = {}
    end
  elseif msgSID == MsgID_Scene_War_Exit and 0 < #self.m_BangPaiMsgCache then
    local autoVoiceCheck
    for _, data in pairs(self.m_BangPaiMsgCache) do
      if #data == 1 then
        SendMessage(MsgID_Message_BangPaiTip, data[1])
      elseif #data == 5 then
        local yyData = data[5]
        if yyData ~= nil then
          yyData.id = g_LocalPlayer:getUniqueVoiceId()
          self.m_YYMsgCache[#self.m_YYMsgCache + 1] = {yyData, CHANNEL_BP_MSG}
          if #self.m_YYMsgCache > DefineMaxYYMsgCache then
            table.remove(self.m_YYMsgCache, 1)
          end
          if autoVoiceCheck == nil then
            autoVoiceCheck = yyData.id
          end
        end
        SendMessage(MsgID_Message_BangPaiMsg, data[1], data[2], data[3], data[4], data[5])
      end
    end
    self.m_BangPaiMsgCache = {}
    if autoVoiceCheck ~= nil then
      self:checkAutoPlayVoice(autoVoiceCheck)
    end
  end
end
function CMessageMgr:setReadPlayVoice(yyid, channel, param)
  if channel == CHANNEL_BP_MSG or channel == CHANNEL_TEAM or channel == CHANNEL_WOLRD or channel == CHANNEL_LOCAL then
    for index, data in pairs(self.m_YYMsgCache) do
      local yyData = data[1]
      if yyData.id == yyid then
        table.remove(self.m_YYMsgCache, index)
        return true
      end
    end
    return false
  elseif channel == CHANNEL_FRIEND then
    local pid = param.pid
    local msgList = self.m_PrivateMessage[pid]
    if msgList ~= nil then
      for i = #msgList, 1, -1 do
        local data = msgList[i]
        local yyData = data[5]
        if yyData and yyData.id == yyid then
          yyData.read = 1
          break
        end
      end
    end
    return false
  else
    return false
  end
end
function CMessageMgr:checkAutoPlayVoice(startId)
  if g_VoiceMgr:isPlayingPCMString() then
    return
  end
  if #self.m_YYMsgCache <= 0 then
    return
  end
  local initSysSetting = g_LocalPlayer:getSysSetting()
  local bpEnabled = initSysSetting.bpvoice ~= false
  local teamEnabled = initSysSetting.teamvoice ~= false
  local worldEnabled = initSysSetting.worldvoice ~= false
  local localEnabled = initSysSetting.localvoice ~= false
  if not bpEnabled and not teamEnabled and not worldEnabled and not localEnabled then
    return
  end
  if g_SocialityDlg and g_SocialityDlg:getIsDlgShow() then
    if g_SocialityDlg.layerbangpai:isVisible() then
      teamEnabled = false
      worldEnabled = false
      localEnabled = false
    end
    if g_SocialityDlg.layerteam:isVisible() then
      bpEnabled = false
      worldEnabled = false
      localEnabled = false
    end
    if g_SocialityDlg.layerintegration:isVisible() then
      teamEnabled = false
      bpEnabled = false
      localEnabled = false
    end
    if g_SocialityDlg.layerlocal:isVisible() then
      teamEnabled = false
      bpEnabled = false
      worldEnabled = false
    end
  end
  if not bpEnabled and not teamEnabled and not worldEnabled and not localEnabled then
    return
  end
  if startId == nil then
    startId = -1
  end
  for _, data in pairs(self.m_YYMsgCache) do
    local yyData = data[1]
    local yyChannel = data[2]
    if yyChannel == CHANNEL_TEAM and teamEnabled and startId <= yyData.id then
      g_VoiceMgr:playPCMString(yyData.voice, yyData.id, yyData.time, nil, CHANNEL_TEAM)
      break
    elseif yyChannel == CHANNEL_BP_MSG and bpEnabled and startId <= yyData.id then
      g_VoiceMgr:playPCMString(yyData.voice, yyData.id, yyData.time, nil, CHANNEL_BP_MSG)
      break
    elseif yyChannel == CHANNEL_WOLRD and worldEnabled and startId <= yyData.id then
      g_VoiceMgr:playPCMString(yyData.voice, yyData.id, yyData.time, nil, CHANNEL_WOLRD)
      break
    elseif yyChannel == CHANNEL_LOCAL and localEnabled and startId <= yyData.id then
      g_VoiceMgr:playPCMString(yyData.voice, yyData.id, yyData.time, nil, CHANNEL_LOCAL)
      break
    end
  end
end
function CMessageMgr:InitHelpTip()
  if g_LocalPlayer == nil then
    return {}
  end
  local mainHeroIns = g_LocalPlayer:getMainHero()
  if mainHeroIns == nil then
    return {}
  end
  local allTips = {}
  local zs = mainHeroIns:getProperty(PROPERTY_ZHUANSHENG)
  local lv = mainHeroIns:getProperty(PROPERTY_ROLELEVEL)
  for k, v in pairs(data_MapLoadingTips) do
    if zs >= v.zs and zs <= v.zsmax and (zs ~= v.zs or not (lv < v.lv)) and (zs ~= v.zsmax or not (lv > v.lvmax)) then
      local okFlag = true
      if v.week ~= 0 and v.week ~= nil then
        local temp = {}
        if type(v.week) == "table" then
          temp = v.week
        elseif type(v.week) == "number" then
          temp[#temp + 1] = v.week
        end
        if #temp > 0 then
          local weekDay = checkint(os.date("%w"))
          local todayIsOk = false
          for _, d in pairs(temp) do
            d = d % 7
            if d == weekDay then
              todayIsOk = true
              break
            end
          end
          if not todayIsOk then
            print("----->>kk星期不满足:", weekDay, v.tips)
            okFlag = false
          end
        end
      end
      if okFlag == true and v.time ~= 0 and v.time ~= nil and type(v.time) == "table" then
        local st = v.time[1]
        local et = v.time[2]
        if st ~= nil and et ~= nil then
          local hour = checkint(os.date("%H"))
          local min = checkint(os.date("%M"))
          hour = hour + min / 60
          if st > hour or et < hour then
            print("----->>kk时间段不满足:", st, et, hour, v.tips)
            okFlag = false
          end
        end
      end
      if okFlag == true then
        allTips[#allTips + 1] = v.tips
      end
    end
  end
  return allTips
end
function CMessageMgr:RandomHelpTip()
  local allTips = self:InitHelpTip()
  if allTips ~= nil and #allTips > 0 then
    tipsStr = allTips[math.random(1, #allTips)]
    self:receiveSysHelpTip(tipsStr)
  end
end
function CMessageMgr:_loadSaveData(savePath)
  local dataStr
  local file = io.open(savePath, "rb")
  if file then
    dataStr = file:read("*a")
    io.close(file)
  else
    return {}
  end
  if dataStr ~= nil then
    dataStr = crypto.decodeBase64(dataStr) or ""
    dataStr = crypto.decryptXXTEA(dataStr, self.m_AE_XxteaKeys)
  end
  if dataStr == nil then
    return {}
  else
    dataStr = json.decode(dataStr) or {}
    return dataStr
  end
end
function CMessageMgr:_getLocalSaveDir()
  if self.m_LocalSaveDir == nil then
    local localPlayerId = g_LocalPlayer:getPlayerId()
    local temp = crypto.md5(tostring(localPlayerId), false)
    self.m_LocalSaveDir = msgArchivePath .. temp .. "/"
    os.mkdir(self.m_LocalSaveDir)
  end
  return self.m_LocalSaveDir
end
function CMessageMgr:SaveMsgToLocal()
  for pid, msgInfo in pairs(self.m_PrivateMessage) do
    self:SaveFriendChatMsgToLocal(pid, msgInfo)
  end
end
function CMessageMgr:SavePrivateMsgToLocal(pid)
  if pid == nil then
    return
  end
  print("======>>>>>> 请求保存聊天记录:", pid)
  local msgInfo = self.m_PrivateMessage[pid]
  if msgInfo ~= nil then
    print("======>>>>>> 正在保存聊天记录:", pid)
    self:SaveFriendChatMsgToLocal(pid, msgInfo)
  end
end
function CMessageMgr:_getSavePathOfFriendChat(pid)
  local saveDir = self:_getLocalSaveDir()
  local fileName = crypto.md5(tostring(pid), false)
  local savePath = saveDir .. fileName
  return savePath
end
function CMessageMgr:LoadLocalFriendChatMsg(pid)
  local savePath = self:_getSavePathOfFriendChat(pid)
  return self:_loadSaveData(savePath)
end
function CMessageMgr:SaveFriendChatMsgToLocal(pid, msgInfo)
  local dataStr = json.encode(msgInfo)
  dataStr = crypto.encryptXXTEA(dataStr, self.m_AE_XxteaKeys)
  dataStr = crypto.encodeBase64(dataStr)
  local savePath = self:_getSavePathOfFriendChat(pid)
  io.writefile(savePath, dataStr, "wb")
end
function CMessageMgr:DeleteFriendChatMsgToLocal(pid)
  local savePath = self:_getSavePathOfFriendChat(pid)
  if os.exists(savePath) then
    os.remove(savePath)
  end
end
function CMessageMgr:_getLocalSaveDirOfTeam(mkFlag)
  local saveDir = self:_getLocalSaveDir()
  saveDir = saveDir .. "team/"
  if mkFlag ~= false then
    os.mkdir(saveDir)
  end
  return saveDir
end
function CMessageMgr:_getSavePathOfTeamChat(teamId)
  local saveDir = self:_getLocalSaveDirOfTeam()
  local fileName = crypto.md5(tostring(teamId), false)
  local savePath = saveDir .. fileName
  return savePath
end
function CMessageMgr:SaveTeamChatMsgToLocal(teamId, msgInfo)
end
function CMessageMgr:receivePrivateMessage(pid, chatpid, msg, yy, vip)
  msg = filterChatText_DFAFilter(msg)
  if yy ~= nil then
    yy.id = g_LocalPlayer:getUniqueVoiceId()
    if chatpid == g_LocalPlayer:getPlayerId() then
      yy.read = 1
    else
      yy.read = 0
    end
  end
  local msgList = self:getPrivateMessage(pid)
  local curTime = os.time()
  if chatpid == g_LocalPlayer:getPlayerId() then
    msgList[#msgList + 1] = {
      msg,
      curTime,
      chatpid,
      1,
      yy,
      vip
    }
  else
    msgList[#msgList + 1] = {
      msg,
      curTime,
      chatpid,
      0,
      yy,
      vip
    }
  end
  if #msgList > DefineMaxPrivateMsgCache then
    for i = 1, #msgList - DefineMaxPrivateMsgCache do
      table.remove(msgList, 1)
    end
  end
  g_LocalPlayer:recordPrivateChatTimeInfo(pid)
  SendMessage(MsgID_Message_PrivateMsg, pid, chatpid, msg, curTime, yy, vip)
end
function CMessageMgr:receiveTeamMessage(pid, msg, yy, vip)
  msg = filterChatText_DFAFilter(msg)
  local autoVoiceCheck
  if yy ~= nil then
    yy.id = g_LocalPlayer:getUniqueVoiceId()
    if pid ~= g_LocalPlayer:getPlayerId() then
      yy.read = 0
      self.m_YYMsgCache[#self.m_YYMsgCache + 1] = {yy, CHANNEL_TEAM}
      if #self.m_YYMsgCache > DefineMaxYYMsgCache then
        table.remove(self.m_YYMsgCache, 1)
      end
      autoVoiceCheck = yy.id
    else
      yy.read = 1
    end
  end
  local role = g_MapMgr:getRole(pid)
  if role then
    role:addTalkMsg(msg, yy)
  end
  local curTime = os.time()
  SendMessage(MsgID_Message_TeamMsg, pid, msg, curTime, yy, vip)
  if autoVoiceCheck ~= nil then
    self:checkAutoPlayVoice(autoVoiceCheck)
  end
end
function CMessageMgr:receiveWorldMessage(pid, pInfo, msg, yy, vip)
  if self.m_PingBiUsers[pid] ~= nil then
    print(" 该玩家的世界频道数据已经被本地屏蔽掉 ", pid, msg)
    return
  end
  msg = filterChatText_DFAFilter(msg)
  local autoVoiceCheck
  if yy ~= nil then
    yy.id = g_LocalPlayer:getUniqueVoiceId()
    if pid ~= g_LocalPlayer:getPlayerId() then
      yy.read = 0
      self.m_YYMsgCache[#self.m_YYMsgCache + 1] = {yy, CHANNEL_WOLRD}
      if #self.m_YYMsgCache > DefineMaxYYMsgCache then
        table.remove(self.m_YYMsgCache, 1)
      end
      autoVoiceCheck = yy.id
    else
      yy.read = 1
    end
  end
  local curTime = os.time()
  self.m_WorldPlayerInfo[pid] = pInfo
  SendMessage(MsgID_Message_WorldMsg, pid, pInfo, msg, curTime, yy, vip)
  if autoVoiceCheck ~= nil then
    self:checkAutoPlayVoice(autoVoiceCheck)
  end
end
function CMessageMgr:receiveLaBaMessage(pid, pInfo, msg, yy, vip)
  self.m_LaBaPlayerInfo[pid] = pInfo
  local curTime = os.time()
  SendMessage(MsgID_Message_XiaoLaBa, pid, pInfo, msg, curTime, yy, vip)
end
function CMessageMgr:receiveLocalMessage(pid, pInfo, msg, yy, vip)
  if not self:isEnabledLocalChannelOfCurrMap() then
    return
  end
  msg = filterChatText_DFAFilter(msg)
  local autoVoiceCheck
  if yy ~= nil then
    yy.id = g_LocalPlayer:getUniqueVoiceId()
    if pid ~= g_LocalPlayer:getPlayerId() then
      yy.read = 0
      self.m_YYMsgCache[#self.m_YYMsgCache + 1] = {yy, CHANNEL_LOCAL}
      if #self.m_YYMsgCache > DefineMaxYYMsgCache then
        table.remove(self.m_YYMsgCache, 1)
      end
      autoVoiceCheck = yy.id
    else
      yy.read = 1
    end
  end
  local setData = g_LocalPlayer:getSelectChannel() or {}
  local showMsg = setData[4] ~= 0
  local role = g_MapMgr:getRole(pid)
  if role and showMsg then
    role:addTalkMsg(msg, yy)
  end
  local curTime = os.time()
  self.m_LocalPlayerInfo[pid] = pInfo
  SendMessage(MsgID_Message_LocalMsg, pid, pInfo, msg, curTime, yy, vip)
  if autoVoiceCheck ~= nil then
    self:checkAutoPlayVoice(autoVoiceCheck)
  end
end
function CMessageMgr:receiveLocalChannelSysMessage(sysmsg, npcId)
  local setData = g_LocalPlayer:getSelectChannel() or {}
  local showMsg = setData[4] ~= 0
  if showMsg and npcId ~= nil and g_MapMgr then
    local mapViewIns = g_MapMgr:getMapViewIns()
    if mapViewIns then
      local npcIns = mapViewIns:getNpcIns(npcId)
      if npcIns then
        npcIns:addTalkMsg(sysmsg)
      end
    end
  end
  if not self:isEnabledLocalChannelOfCurrMap() then
    return
  end
  SendMessage(MsgID_Message_LocalChannelSysMsg, sysmsg, npcId)
end
function CMessageMgr:receiveSysMessage(sysmsg)
  SendMessage(MsgID_Message_SysMsg, sysmsg)
end
function CMessageMgr:receiveSysHelpTip(tipmsg)
  SendMessage(MsgID_Message_HelpTip, tipmsg)
end
function CMessageMgr:receiveKuaixunMessage(kxmsg)
  SendMessage(MsgID_Message_KuaiXunTip, kxmsg)
  ShowDownNotifyViews(kxmsg)
end
function CMessageMgr:receivePersonXinxiMessage(xxmsg)
  if not g_SocialityDlg then
    self.m_CacheShowMessageForIntchat[#self.m_CacheShowMessageForIntchat + 1] = {
      MsgID_Message_XinXiTip,
      {xxmsg}
    }
  end
  SendMessage(MsgID_Message_XinXiTip, xxmsg)
end
function CMessageMgr:newPromulgateTeam(teamId, num, cName, zs, cLevel, targetId, taskId, isUpdate)
  local desc = data_getPromulgateDesc(targetId)
  local lv = math.floor(cLevel / 10) * 10 + math.ceil(math.max(cLevel % 10 - 4, 0) / 10) * 10
  local minLv = math.max(lv - 20, 0)
  local maxLv = math.min(lv + 20, 180)
  local info = data_getPromulgateInfo(targetId)
  if info and minLv < info.level then
    minLv = info.level
    if maxLv < minLv then
      maxLv = minLv
    end
  end
  local msg
  local localTeamId = g_TeamMgr:getLocalPlayerTeamId()
  if localTeamId == teamId then
    if targetId == PromulgateTeamTarget_BangPai then
      local nameColor = NameColor_MainHero[zs] or ccc3(255, 0, 0)
      if taskId == nil then
        msg = string.format("#<r:%d,g:%d,b:%d>%s# #<r:%d,g:%d,b:%d>%s##<Y>(%d/%d)#", MsgColor_BpChannel.r, MsgColor_BpChannel.g, MsgColor_BpChannel.b, desc, nameColor.r, nameColor.g, nameColor.b, cName, num, GetTeamPlayerNumLimit(targetId))
      elseif taskId == 1 then
        desc = "帮派求助"
        local tdesc = "宝图怪物"
        msg = string.format("#<r:%d,g:%d,b:%d>%s# #<Y>%s (%d/%d)#", MsgColor_BpChannel.r, MsgColor_BpChannel.g, MsgColor_BpChannel.b, desc, tdesc, num, GetTeamPlayerNumLimit(targetId))
      elseif taskId >= 2 and taskId <= 7 then
        desc = "帮派求助"
        local tdesc = "历练怪物"
        msg = string.format("#<r:%d,g:%d,b:%d>%s# #<Y>%s (%d/%d)#", MsgColor_BpChannel.r, MsgColor_BpChannel.g, MsgColor_BpChannel.b, desc, tdesc, num, GetTeamPlayerNumLimit(targetId))
      elseif taskId == 8 then
        desc = "帮派求助"
        local tdesc = "帮派暗战"
        msg = string.format("#<r:%d,g:%d,b:%d>%s# #<Y>%s (%d/%d)#", MsgColor_BpChannel.r, MsgColor_BpChannel.g, MsgColor_BpChannel.b, desc, tdesc, num, GetTeamPlayerNumLimit(targetId))
      elseif taskId == 9 then
        desc = "帮派求助"
        local tdesc = "帮派除奸"
        msg = string.format("#<r:%d,g:%d,b:%d>%s# #<Y>%s (%d/%d)#", MsgColor_BpChannel.r, MsgColor_BpChannel.g, MsgColor_BpChannel.b, desc, tdesc, num, GetTeamPlayerNumLimit(targetId))
      else
        desc = "帮派求助"
        local tdesc = data_getMainMissionName(taskId)
        msg = string.format("#<r:%d,g:%d,b:%d>%s# #<Y>%s (%d/%d)#", MsgColor_BpChannel.r, MsgColor_BpChannel.g, MsgColor_BpChannel.b, desc, tdesc, num, GetTeamPlayerNumLimit(targetId))
      end
    elseif targetId == PromulgateTeamTarget_ZXJQ then
      if taskId ~= nil then
        local taskName = data_getMainMissionName(taskId)
        msg = string.format("#<G>%s# #<Y>%s (%d/%d)#", desc, taskName, num, GetTeamPlayerNumLimit(targetId))
      else
        msg = string.format("#<G>%s# #<Y>(%d/%d)#", desc, num, GetTeamPlayerNumLimit(targetId))
      end
    else
      msg = string.format("#<G>%s# #<Y>%d-%d级队伍(%d/%d)#", desc, minLv, maxLv, num, GetTeamPlayerNumLimit(targetId))
    end
  elseif localTeamId == 0 then
    if targetId == PromulgateTeamTarget_BangPai then
      local nameColor = NameColor_MainHero[zs] or ccc3(255, 0, 0)
      if taskId == nil then
        msg = string.format("#<r:%d,g:%d,b:%d>%s# #<r:%d,g:%d,b:%d>%s##<Y>(%d/%d)# #<G,M:%d,MD:%d,F:22>[加入]#", MsgColor_BpChannel.r, MsgColor_BpChannel.g, MsgColor_BpChannel.b, desc, nameColor.r, nameColor.g, nameColor.b, cName, num, GetTeamPlayerNumLimit(targetId), CRichText_MessageType_MakeTeam, teamId)
      elseif taskId == 1 then
        desc = "帮派求助"
        local tdesc = "宝图怪物"
        msg = string.format("#<r:%d,g:%d,b:%d>%s# #<Y>%s (%d/%d)# #<G,M:%d,MD:%d,F:22>[加入]#", MsgColor_BpChannel.r, MsgColor_BpChannel.g, MsgColor_BpChannel.b, desc, tdesc, num, GetTeamPlayerNumLimit(targetId), CRichText_MessageType_MakeTeam, teamId)
      elseif taskId >= 2 and taskId <= 7 then
        desc = "帮派求助"
        local tdesc = "历练怪物"
        msg = string.format("#<r:%d,g:%d,b:%d>%s# #<Y>%s (%d/%d)# #<G,M:%d,MD:%d,F:22>[加入]#", MsgColor_BpChannel.r, MsgColor_BpChannel.g, MsgColor_BpChannel.b, desc, tdesc, num, GetTeamPlayerNumLimit(targetId), CRichText_MessageType_MakeTeam, teamId)
      elseif taskId == 8 then
        desc = "帮派求助"
        local tdesc = "帮派暗战"
        msg = string.format("#<r:%d,g:%d,b:%d>%s# #<Y>%s (%d/%d)# #<G,M:%d,MD:%d,F:22>[加入]#", MsgColor_BpChannel.r, MsgColor_BpChannel.g, MsgColor_BpChannel.b, desc, tdesc, num, GetTeamPlayerNumLimit(targetId), CRichText_MessageType_MakeTeam, teamId)
      elseif taskId == 9 then
        desc = "帮派求助"
        local tdesc = "帮派除奸"
        msg = string.format("#<r:%d,g:%d,b:%d>%s# #<Y>%s (%d/%d)# #<G,M:%d,MD:%d,F:22>[加入]#", MsgColor_BpChannel.r, MsgColor_BpChannel.g, MsgColor_BpChannel.b, desc, tdesc, num, GetTeamPlayerNumLimit(targetId), CRichText_MessageType_MakeTeam, teamId)
      else
        desc = "帮派求助"
        local tdesc = data_getMainMissionName(taskId)
        msg = string.format("#<r:%d,g:%d,b:%d>%s# #<Y>%s (%d/%d)# #<G,M:%d,MD:%d,F:22>[加入]#", MsgColor_BpChannel.r, MsgColor_BpChannel.g, MsgColor_BpChannel.b, desc, tdesc, num, GetTeamPlayerNumLimit(targetId), CRichText_MessageType_MakeTeam, teamId)
      end
    elseif targetId == PromulgateTeamTarget_ZXJQ then
      if taskId ~= nil then
        local taskName = data_getMainMissionName(taskId)
        msg = string.format("#<G>%s# #<Y>%s (%d/%d)# #<G,M:%d,MD:%d,F:22>[加入]#", desc, taskName, num, GetTeamPlayerNumLimit(targetId), CRichText_MessageType_MakeTeam, teamId)
      else
        msg = string.format("#<G>%s# #<Y>(%d/%d)# #<G,M:%d,MD:%d,F:22>[加入]#", desc, num, GetTeamPlayerNumLimit(targetId), CRichText_MessageType_MakeTeam, teamId)
      end
    else
      msg = string.format("#<G>%s# #<Y>%d-%d级(%d/%d)# #<G,M:%d,MD:%d,F:22>[加入]#", desc, minLv, maxLv, num, GetTeamPlayerNumLimit(targetId), CRichText_MessageType_MakeTeam, teamId)
    end
  else
    printLog("CMessageMgr", "自己有队伍了，还能收到其他队伍的发布信息?!")
  end
  if msg then
    if isUpdate == true then
      SendMessage(MsgID_Message_UpdatePromulgateTeam, teamId, msg, targetId)
    else
      SendMessage(MsgID_Message_NewPromulgateTeam, teamId, msg, targetId)
    end
  end
end
function CMessageMgr:receiveBpMessage(msgList)
  local autoVoiceCheck
  for _, data in pairs(msgList) do
    local msg = data.msg or ""
    local yy = data.yy
    local vip = data.vip
    local curTime = os.time()
    local pid = data.pid
    if pid ~= nil and pid ~= 0 then
      if data.place ~= nil and pid ~= g_LocalPlayer:getPlayerId() then
        local mapViewIns = g_MapMgr:getMapViewIns()
        if mapViewIns then
          local bpName = g_BpMgr:getLocalBpName()
          mapViewIns:PlayerChangBpName(pid, bpName, data.place)
        end
      end
      local pInfo = {
        rtype = data.typeid or 11001,
        zs = data.rbnum or 0,
        level = data.lv or 0,
        name = data.name or "",
        place = data.place or BP_PLACE_XUETU
      }
      self.m_BpPlayerInfo[pid] = pInfo
      msg = filterChatText_DFAFilter(msg)
      if yy ~= nil then
        yy.id = g_LocalPlayer:getUniqueVoiceId()
        if pid == g_LocalPlayer:getPlayerId() then
          yy.read = 1
        else
          yy.read = 0
        end
      end
      if data.delay == 1 then
        if g_WarScene ~= nil then
          self.m_BangPaiMsgCache[#self.m_BangPaiMsgCache + 1] = {
            pid,
            pInfo,
            msg,
            curTime,
            yy,
            vip
          }
        else
          if yy ~= nil and yy.read == 0 then
            self.m_YYMsgCache[#self.m_YYMsgCache + 1] = {yy, CHANNEL_BP_MSG}
            if #self.m_YYMsgCache > DefineMaxYYMsgCache then
              table.remove(self.m_YYMsgCache, 1)
            end
            if autoVoiceCheck == nil then
              autoVoiceCheck = yy.id
            end
          end
          SendMessage(MsgID_Message_BangPaiMsg, pid, pInfo, msg, curTime, yy, vip)
        end
      else
        if yy ~= nil and yy.read == 0 then
          self.m_YYMsgCache[#self.m_YYMsgCache + 1] = {yy, CHANNEL_BP_MSG}
          if #self.m_YYMsgCache > DefineMaxYYMsgCache then
            table.remove(self.m_YYMsgCache, 1)
          end
          if autoVoiceCheck == nil then
            autoVoiceCheck = yy.id
          end
        end
        SendMessage(MsgID_Message_BangPaiMsg, pid, pInfo, msg, curTime, yy, vip)
      end
    elseif data.delay == 1 then
      if g_WarScene ~= nil then
        self.m_BangPaiMsgCache[#self.m_BangPaiMsgCache + 1] = {msg}
      else
        SendMessage(MsgID_Message_BangPaiTip, msg)
      end
    else
      SendMessage(MsgID_Message_BangPaiTip, msg)
    end
  end
  if autoVoiceCheck ~= nil then
    self:checkAutoPlayVoice(autoVoiceCheck)
  end
end
function CMessageMgr:OnWolrdMessageRestTime(restTime)
  self.m_WorldChatTimeRestTime = restTime
  self.m_LastTimeRecordOfWolrd = os.time()
  SendMessage(MsgID_Message_CD_WorldChannel, restTime)
  if self.m_WorldScheduler ~= nil then
    scheduler.unscheduleGlobal(self.m_WorldScheduler)
  end
  self.m_WorldScheduler = scheduler.scheduleGlobal(handler(self, self.updateWorldCD), 1)
end
function CMessageMgr:OnLocalMessageRestTime(restTime)
  self.m_LocalChatTimeRestTime = restTime
  self.m_LastTimeRecordOfLocal = os.time()
  SendMessage(MsgID_Message_CD_LocalChannel, restTime)
  if self.m_LocalScheduler ~= nil then
    scheduler.unscheduleGlobal(self.m_LocalScheduler)
  end
  self.m_LocalScheduler = scheduler.scheduleGlobal(handler(self, self.updateLocalCD), 1)
end
function CMessageMgr:OnBangpaiMessageRestTime(restTime)
  self.m_BangPaiChatTimeRestTime = restTime
  self.m_LastTimeRecordOfBangPai = os.time()
  SendMessage(MsgID_Message_CD_BpChannel, restTime)
  if self.m_BpScheduler ~= nil then
    scheduler.unscheduleGlobal(self.m_BpScheduler)
  end
  self.m_BpScheduler = scheduler.scheduleGlobal(handler(self, self.updateBpCD), 1)
end
function CMessageMgr:OnFriendOnLine(pid, zs, friendName)
  if zs == nil or friendName == nil then
    return
  end
  local color = NameColor_MainHero[zs] or NameColor_MainHero[0]
  local msg
  local mainHero = g_LocalPlayer:getMainHero()
  if g_FriendsMgr:getIsBanLv(pid) then
    if mainHero ~= nil then
      if mainHero:getProperty(PROPERTY_GENDER) == HERO_MALE then
        msg = string.format("#<r:247,g:247,b:115>您的妻子##<r:%d,g:%d,b:%d>%s##<r:247,g:247,b:115>上线了#", color.r, color.g, color.b, friendName)
      elseif mainHero:getProperty(PROPERTY_GENDER) == HERO_FEMALE then
        msg = string.format("#<r:247,g:247,b:115>您的夫君##<r:%d,g:%d,b:%d>%s##<r:247,g:247,b:115>上线了#", color.r, color.g, color.b, friendName)
      end
    end
  elseif g_FriendsMgr:getIsJiYou(pid) and mainHero ~= nil then
    if mainHero:getProperty(PROPERTY_GENDER) == HERO_MALE then
      msg = string.format("#<r:247,g:247,b:115>您的兄弟##<r:%d,g:%d,b:%d>%s##<r:247,g:247,b:115>上线了#", color.r, color.g, color.b, friendName)
    elseif mainHero:getProperty(PROPERTY_GENDER) == HERO_FEMALE then
      msg = string.format("#<r:247,g:247,b:115>您的姐妹##<r:%d,g:%d,b:%d>%s##<r:247,g:247,b:115>上线了#", color.r, color.g, color.b, friendName)
    end
  end
  if msg == nil then
    msg = string.format("#<r:247,g:247,b:115>好友##<r:%d,g:%d,b:%d>%s##<r:247,g:247,b:115>上线了#", color.r, color.g, color.b, friendName)
  end
  SendMessage(MsgID_Message_CommonTip, msg)
end
function CMessageMgr:OnFriendOutLine(pid, zs, friendName)
  if zs == nil or friendName == nil then
    return
  end
  local color = NameColor_MainHero[zs] or NameColor_MainHero[0]
  local msg
  local mainHero = g_LocalPlayer:getMainHero()
  if g_FriendsMgr:getIsBanLv(pid) then
    if mainHero ~= nil then
      if mainHero:getProperty(PROPERTY_GENDER) == HERO_MALE then
        msg = string.format("#<r:247,g:247,b:115>您的妻子##<r:%d,g:%d,b:%d>%s##<r:247,g:247,b:115>下线了#", color.r, color.g, color.b, friendName)
      elseif mainHero:getProperty(PROPERTY_GENDER) == HERO_FEMALE then
        msg = string.format("#<r:247,g:247,b:115>您的夫君##<r:%d,g:%d,b:%d>%s##<r:247,g:247,b:115>下线了#", color.r, color.g, color.b, friendName)
      end
    end
  elseif g_FriendsMgr:getIsJiYou(pid) and mainHero ~= nil then
    if mainHero:getProperty(PROPERTY_GENDER) == HERO_MALE then
      msg = string.format("#<r:247,g:247,b:115>您的兄弟##<r:%d,g:%d,b:%d>%s##<r:247,g:247,b:115>下线了#", color.r, color.g, color.b, friendName)
    elseif mainHero:getProperty(PROPERTY_GENDER) == HERO_FEMALE then
      msg = string.format("#<r:247,g:247,b:115>您的姐妹##<r:%d,g:%d,b:%d>%s##<r:247,g:247,b:115>下线了#", color.r, color.g, color.b, friendName)
    end
  end
  if msg == nil then
    msg = string.format("#<r:247,g:247,b:115>好友##<r:%d,g:%d,b:%d>%s##<r:247,g:247,b:115>下线了#", color.r, color.g, color.b, friendName)
  end
  SendMessage(MsgID_Message_CommonTip, msg)
end
function CMessageMgr:OnLoginTipMessage()
  if g_NetConnectMgr.getIpAndPort then
    local msg
    local ip, port = g_NetConnectMgr:getIpAndPort()
    for _, data in pairs(channel.serverList) do
      if data.ip == ip and data.port == port then
        local svrName = data.name
        msg = string.format("#<r:247,g:247,b:115>欢迎进入##<r:94,g:222,b:35>%s##<r:247,g:247,b:115>服务器#", svrName)
        break
      end
    end
    if msg == nil then
      msg = "#<r:247,g:247,b:115>欢迎进入游戏#"
    end
    SendMessage(MsgID_Message_CommonTip, msg)
    self.m_LoginTip = msg
  else
    local serverName = g_DataMgr:getLoginServerName()
    local msg = ""
    if serverName then
      msg = string.format("#<r:247,g:247,b:115>欢迎进入##<r:94,g:222,b:35>%s##<r:247,g:247,b:115>服务器#", serverName)
    else
      msg = "#<r:247,g:247,b:115>欢迎进入游戏#"
    end
    SendMessage(MsgID_Message_CommonTip, msg)
    self.m_LoginTip = msg
  end
end
function CMessageMgr:getLoginTip()
  return self.m_LoginTip
end
function CMessageMgr:sendPrivateMessage(pid, msg, yy)
  msg = string.gsub(msg, "\t", "")
  msg = string.gsub(msg, "\r", "")
  netsend.netmessage.sendPrivateMessage(pid, msg, yy)
  local localPid = g_LocalPlayer:getPlayerId()
  local vip = g_LocalPlayer:getVipLv()
  self:receivePrivateMessage(pid, localPid, msg, yy, vip)
  return true
end
function CMessageMgr:sendTeamMessage(msg, yy)
  msg = string.gsub(msg, "\t", "")
  msg = string.gsub(msg, "\r", "")
  netsend.netmessage.sendTeamMessage(msg, yy)
  local localPid = g_LocalPlayer:getPlayerId()
  local vip = g_LocalPlayer:getVipLv()
  self:receiveTeamMessage(localPid, msg, yy, vip)
  return true
end
function CMessageMgr:sendWorldMessage(msg, yy)
  local mainHero = g_LocalPlayer:getMainHero()
  if mainHero == nil then
    return false
  end
  local lv = mainHero:getProperty(PROPERTY_ROLELEVEL)
  if lv < self.Level_SendWorldMsg then
    ShowNotifyTips(string.format("在世界频道里发言需要%d级", self.Level_SendWorldMsg))
    return false
  end
  local curTime = os.time()
  local dt = math.max(curTime - self.m_LastTimeRecordOfWolrd, 0)
  local restTime = math.ceil(self.m_WorldChatTimeRestTime - dt)
  if restTime > 0 then
    ShowNotifyTips(string.format("还剩下%d秒才可以发言", restTime))
    return false
  end
  msg = string.gsub(msg, "\t", "")
  msg = string.gsub(msg, "\r", "")
  netsend.netmessage.sendWorldMessage(msg, yy)
  return true
end
function CMessageMgr:updateWorldCD()
  local curTime = os.time()
  local dt = math.max(curTime - self.m_LastTimeRecordOfWolrd, 0)
  local restTime = math.ceil(self.m_WorldChatTimeRestTime - dt)
  SendMessage(MsgID_Message_CD_WorldChannel, restTime)
  if restTime <= 0 then
    scheduler.unscheduleGlobal(self.m_WorldScheduler)
    self.m_WorldScheduler = nil
  end
end
function CMessageMgr:sendLocalMessage(msg, yy)
  local mainHero = g_LocalPlayer:getMainHero()
  if mainHero == nil then
    return false
  end
  local lv = mainHero:getProperty(PROPERTY_ROLELEVEL)
  if lv < self.Level_SendLocalMsg then
    ShowNotifyTips(string.format("在当前频道里发言需要%d级", self.Level_SendLocalMsg))
    return false
  end
  local curTime = os.time()
  local dt = math.max(curTime - self.m_LastTimeRecordOfLocal, 0)
  local restTime = math.ceil(self.m_LocalChatTimeRestTime - dt)
  if restTime > 0 then
    ShowNotifyTips(string.format("还剩下%d秒才可以发言", restTime))
    return false
  end
  msg = string.gsub(msg, "\t", "")
  msg = string.gsub(msg, "\r", "")
  netsend.netmessage.sendLocalMessage(msg, yy)
  return true
end
function CMessageMgr:updateLocalCD()
  local curTime = os.time()
  local dt = math.max(curTime - self.m_LastTimeRecordOfLocal, 0)
  local restTime = math.ceil(self.m_LocalChatTimeRestTime - dt)
  SendMessage(MsgID_Message_CD_LocalChannel, restTime)
  if restTime <= 0 then
    scheduler.unscheduleGlobal(self.m_LocalScheduler)
    self.m_LocalScheduler = nil
  end
end
function CMessageMgr:sendBangPaiMessage(msg, yy)
  if not g_BpMgr:localPlayerHasBangPai() then
    ShowNotifyTips("需要先加入帮派才能在帮派频道里发言")
    return false
  end
  local curTime = os.time()
  local dt = math.max(curTime - self.m_LastTimeRecordOfBangPai, 0)
  local restTime = math.ceil(self.m_BangPaiChatTimeRestTime - dt)
  if restTime > 0 then
    ShowNotifyTips(string.format("还剩下%d秒才可以发言", restTime))
    return false
  end
  msg = string.gsub(msg, "\t", "")
  msg = string.gsub(msg, "\r", "")
  netsend.netmessage.sendBangPaiMessage(msg, yy)
  return true
end
function CMessageMgr:updateBpCD()
  local curTime = os.time()
  local dt = math.max(curTime - self.m_LastTimeRecordOfBangPai, 0)
  local restTime = math.ceil(self.m_BangPaiChatTimeRestTime - dt)
  SendMessage(MsgID_Message_CD_BpChannel, restTime)
  if restTime <= 0 then
    scheduler.unscheduleGlobal(self.m_BpScheduler)
    self.m_BpScheduler = nil
  end
end
function CMessageMgr:getCacheForIntchatAndClean()
  local temp = self.m_CacheShowMessageForIntchat
  self.m_CacheShowMessageForIntchat = {}
  return temp
end
function CMessageMgr:getLocalLeaveWord(msg)
  SendMessage(MsgID_Message_LocalLeaveWord, msg)
end
function CMessageMgr:getRandomLeaveWord(lst)
  SendMessage(MsgID_Message_RandomLeaveWord, lst)
end
function CMessageMgr:flushPingBiList(list)
  dump(list, "CMessageMgr:flushPingBiList")
  if list == nil then
    return
  end
  self.m_PingBiUsers = {}
  for k, v in pairs(list) do
    self.m_PingBiUsers[v.pid] = DeepCopyTable(v)
  end
end
function CMessageMgr:addOnePingBiName(info)
  dump(info, "CMessageMgr:addOnePingBiName")
  self.m_PingBiUsers = self.m_PingBiUsers or {}
  if info == nil or info.pid == nil then
    return
  end
  self.m_PingBiUsers[info.pid] = DeepCopyTable(info)
  local zs = info.zs or 0
  local ncolor = NameColor_MainHero[zs]
  ShowNotifyTips(string.format("屏蔽玩家#<r:%d,g:%d,b:%d>%s#成功", ncolor.r, ncolor.g, ncolor.b, info.name or ""))
  dump(self.m_PingBiUsers, "CMessageMgr:addOnePingBiName 333 ")
  if g_selectChannel then
    g_selectChannel:flushNameList()
  end
end
function CMessageMgr:removeOnePingBiName(pid)
  print("========>>>>>　服务器通知删除一位屏蔽玩家 ", pid, g_selectChannel == nil)
  self.m_PingBiUsers = self.m_PingBiUsers or {}
  self.m_PingBiUsers[pid] = self.m_PingBiUsers[pid] or {}
  local name = self.m_PingBiUsers[pid].name or ""
  local zs = self.m_PingBiUsers[pid].zs or 0
  self.m_PingBiUsers[pid] = nil
  local ncolor = NameColor_MainHero[zs]
  ShowNotifyTips(string.format("你已把玩家#<r:%d,g:%d,b:%d>%s#移除出屏蔽名单", ncolor.r, ncolor.g, ncolor.b, name))
  if g_selectChannel then
    g_selectChannel:removeOnePingBiUser(pid)
  end
end
function CMessageMgr:getPingBiList()
  return self.m_PingBiUsers or {}
end
function CMessageMgr:getPlayerIsPintBi(pid)
  self.m_PingBiUsers = self.m_PingBiUsers or {}
  return self.m_PingBiUsers[pid] ~= nil
end
function CMessageMgr:Clear()
  if self.m_ScheduleHandler then
    scheduler.unscheduleGlobal(self.m_ScheduleHandler)
    self.m_ScheduleHandler = nil
  end
  if self.m_WorldScheduler ~= nil then
    scheduler.unscheduleGlobal(self.m_WorldScheduler)
    self.m_WorldScheduler = nil
  end
  if self.m_BpScheduler ~= nil then
    scheduler.unscheduleGlobal(self.m_BpScheduler)
    self.m_BpScheduler = nil
  end
  if self.m_LocalScheduler ~= nil then
    scheduler.unscheduleGlobal(self.m_LocalScheduler)
    self.m_LocalScheduler = nil
  end
  self:RemoveAllMessageListener()
end
g_MessageMgr = CMessageMgr.new()
gamereset.registerResetFunc(function()
  if g_MessageMgr then
    g_MessageMgr:Clear()
  end
  g_MessageMgr = CMessageMgr.new()
end)
