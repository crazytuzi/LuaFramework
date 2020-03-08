local Lplus = require("Lplus")
local GUIUtils = require("GUI.GUIUtils")
local ChatConsts = require("netio.protocol.mzm.gsp.chat.ChatConsts")
local ChatRole = require("Main.Chat.At.data.ChatRole")
local AtData = require("Main.Chat.At.data.AtData")
local ChatMsgData = require("Main.Chat.ChatMsgData")
local AtUtils = Lplus.Class("AtUtils")
local def = AtUtils.define
def.const("string").AT_PREFIX = "role@"
local _atColor
local _atEffectId = 0
local InvalidChars = {"@", " "}
local _atRolenameFormat
def.static("=>", "string").GetHTMLAtPrefix = function()
  return AtUtils.AT_PREFIX .. "_"
end
def.static("=>", "string").GetChatAtInfoPackFormat = function()
  return "{" .. AtUtils.AT_PREFIX .. ":%w+,.-,.-,.-}"
end
def.static("=>", "string").GetChatAtRolenameFormat = function()
  if nil == _atRolenameFormat then
    local invalidStr = ""
    if InvalidChars and #InvalidChars > 0 then
      for _, invalidChar in ipairs(InvalidChars) do
        invalidStr = invalidStr .. invalidChar
      end
    end
    _atRolenameFormat = string.format("@[^%s]+", invalidStr)
  end
  return _atRolenameFormat
end
def.static("=>", "number").GetCurrentChannel = function()
  local result = -1
  local channelChatPanel = require("Main.Chat.ui.ChannelChatPanel").Instance()
  if channelChatPanel:IsShow() then
    result = channelChatPanel.channelSubType
  elseif AtUtils.GetCurrentChatGroupId() then
    result = ChatConsts.CHANNEL_GROUP
  end
  return result
end
def.static("number", "=>", "userdata").GetChannelOrgId = function(channel)
  local orgId
  if ChatConsts.CHANNEL_FACTION == channel then
    local GangData = require("Main.Gang.data.GangData")
    orgId = GangData.Instance():GetGangId()
  elseif ChatConsts.CHANNEL_TEAM == channel then
    local TeamData = require("Main.Team.TeamData")
    orgId = TeamData.Instance().teamId
  elseif ChatConsts.CHANNEL_GROUP == channel then
    orgId = AtUtils.GetCurrentChatGroupId()
  end
  return orgId
end
def.static("=>", "userdata").GetCurrentChatGroupId = function()
  local result
  local SocialDlg = require("Main.friend.ui.SocialDlg")
  if SocialDlg.Instance():IsShow() and SocialDlg.Instance().curNode == SocialDlg.NodeId.Group then
    result = SocialDlg.Instance().m_GroupId
  end
  return result
end
def.static("=>", "table").GetChannelMemberList = function()
  local result = {}
  local channel = AtUtils.GetCurrentChannel()
  local selfRoleId = _G.GetMyRoleID()
  if ChatConsts.CHANNEL_FACTION == channel then
    local GangData = require("Main.Gang.data.GangData")
    local memberList = GangData.Instance():GetMemberList()
    local gangId = GangData.Instance():GetGangId()
    if gangId and memberList and #memberList > 0 then
      for _, gangMember in pairs(memberList) do
        if not Int64.eq(selfRoleId, gangMember.roleId) and (nil == gangMember.offlineTime or 0 > gangMember.offlineTime) then
          local member = ChatRole.CreateFromGangMember(gangId, gangMember)
          table.insert(result, member)
        end
      end
    end
  elseif ChatConsts.CHANNEL_TEAM == channel then
    local TeamData = require("Main.Team.TeamData")
    local memberList = TeamData.Instance():GetAllTeamMembers()
    local teamId = TeamData.Instance().teamId
    if memberList and #memberList > 0 then
      local TeamMember = require("netio.protocol.mzm.gsp.team.TeamMember")
      for idx, teamMember in ipairs(memberList) do
        if not Int64.eq(selfRoleId, teamMember.roleid) and teamMember.status ~= TeamMember.ST_OFFLINE then
          local member = ChatRole.CreateFromTeamMember(teamId, teamMember, idx)
          table.insert(result, member)
        end
      end
    end
  elseif ChatConsts.CHANNEL_GROUP == channel then
    local groupId = AtUtils.GetCurrentChatGroupId()
    local GroupModule = require("Main.Group.GroupModule")
    local memberList = GroupModule.Instance():GetGroupMemberList(groupId)
    if memberList and #memberList > 0 then
      local FriendConsts = require("netio.protocol.mzm.gsp.friend.FriendConsts")
      for _, groupMember in ipairs(memberList) do
        if not Int64.eq(selfRoleId, groupMember.roleId) and FriendConsts.STATUS_ONLINE == groupMember.onlineStatus then
          local member = ChatRole.CreateFromGroupMember(groupId, groupMember)
          table.insert(result, member)
        end
      end
    end
  end
  if result and #result > 0 then
    table.sort(result, function(a, b)
      if a == nil then
        return true
      elseif b == nil then
        return false
      elseif a.pinyinName ~= b.pinyinName then
        return a.pinyinName < b.pinyinName
      else
        return Int64.lt(a.roleId, b.roleId)
      end
    end)
  end
  return result
end
def.static("=>", "string").GetAtRolePackColor = function()
  return textRes.Chat.At.AT_PACK_COLOR
end
def.static("=>", "number").GetAtEffectId = function()
  if 0 == _atEffectId then
    local record = DynamicData.GetRecord(CFG_PATH.DATA_CHAT_CONST, "atEffectid")
    if record then
      _atEffectId = record:GetIntValue("value")
    else
      warn("[ERROR][AtUtils:GetAtEffectId] record for atEffectid nil!")
    end
  end
  return _atEffectId
end
def.static("string", "string", "string", "string", "=>", "string").GetAtInfoPackHTMLId = function(channelStr, nameStr, RoleIdStr, GroupIdStr)
  return string.format("%s%s_%s_%s_%s", AtUtils.GetHTMLAtPrefix(), channelStr, nameStr, RoleIdStr, GroupIdStr)
end
def.static("string", "=>", "string").GetAtRolenameHTMLId = function(atRolenameStr)
  return string.format("%s%s", AtUtils.GetHTMLAtPrefix(), atRolenameStr)
end
def.static("table").AddAtInfoPack = function(roleInfo)
  if nil == roleInfo then
    warn("[ERROR][AtUtils:AddAtInfoPack] roleInfo nil!")
    return
  end
  local channel = 0
  local input
  local channelChatPanel = require("Main.Chat.ui.ChannelChatPanel").Instance()
  local SocialDlg = require("Main.friend.ui.SocialDlg")
  local SlideState = SocialDlg.SlideState
  if channelChatPanel:IsShow() then
    channel = channelChatPanel.channelSubType
    input = channelChatPanel.inputViewCtrl
  elseif SocialDlg.Instance():IsShow() then
    if AtUtils.GetCurrentChatGroupId() then
      channel = ChatConsts.CHANNEL_GROUP
      input = SocialDlg.Instance().m_GroupInputViewCtrl
    elseif SocialDlg.Instance().slideState == SlideState.ChatLeft or SocialDlg.Instance().slideState == SlideState.ChatRight then
      channel = ChatConsts.CHANNEL_SOMEONE
      input = SocialDlg.Instance().inputViewCtrl
    end
  end
  if channel > 0 and input then
    local orgId = AtUtils.GetChannelOrgId(channel)
    local memberInfo = ChatRole.CreateFromRoleInfo(channel, orgId, roleInfo)
    local name = memberInfo.name
    input:AddInfoPack(string.format("@%s", name), memberInfo:GetInfoPack())
  else
    warn("[ERROR][AtUtils:AddAtInfoPack] AddAtInfoPack fail! channel, input:", channel, input)
  end
end
def.static("number", "=>", "boolean").CanChannelSendReceiveAt = function(channel)
  local result = false
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CHANEL_CFG, channel)
  if record then
    local openAtFunction = record:GetCharValue("openAtFunction")
    result = openAtFunction ~= 0
  end
  return result
end
def.static("number", "table", "table", "=>", "boolean", "userdata").IsRawMsgAtMe = function(channel, chatContent, msgData)
  local result = false
  local orgId
  if not Int64.eq(msgData.roleId, _G.GetMyRoleID()) and chatContent and chatContent.contentType == ChatConsts.CONTENT_NORMAL and AtUtils.CanChannelSendReceiveAt(channel) then
    local ChatMsgBuilder = require("Main.Chat.ChatMsgBuilder")
    local content = AtUtils.CustomFilter(ChatMsgBuilder.Unmarshal(chatContent.content))
    local infoPackIter = string.gfind(content, AtUtils.GetChatAtInfoPackFormat())
    for atPack in infoPackIter, nil, nil do
      local prefixLen = string.len(AtUtils.AT_PREFIX)
      local strs = string.split(string.sub(atPack, prefixLen + 3, -2), ",")
      local roleId = strs[3] and Int64.new(strs[3]) or nil
      if roleId and Int64.eq(roleId, _G.GetMyRoleID()) then
        result = true
        orgId = strs[4] and Int64.new(strs[4]) or nil
        break
      end
    end
    if not result then
      local heroName = _G.GetHeroProp() and _G.GetHeroProp().name
      local atRolenameIter = string.gfind(content, AtUtils.GetChatAtRolenameFormat())
      for atRolename in atRolenameIter, nil, nil do
        local rolename = string.sub(atRolename, 2)
        if rolename and rolename == heroName then
          result = true
          if channel == ChatConsts.CHANNEL_GROUP then
            orgId = msgData and msgData.id or nil
            break
          end
          orgId = AtUtils.GetChannelOrgId(channel)
          break
        end
      end
    end
  end
  return result, orgId
end
def.static("string", "=>", "string").CustomFilter = function(str)
  local find = string.find(str, "{%a+:.-}")
  if find ~= nil then
    local retStr = string.gsub(str, "[^}]+{", function(pattern)
      return SensitiveWordsFilter.FilterContent(pattern, "*")
    end)
    retStr = string.gsub(retStr, "}[^{]+", function(pattern)
      return SensitiveWordsFilter.FilterContent(pattern, "*")
    end)
    return retStr
  else
    return SensitiveWordsFilter.FilterContent(str, "*")
  end
end
def.static("number", "=>", "number").GetChannelMaxAt = function(channel)
  local result = 0
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CHANEL_CFG, channel)
  if record then
    result = record:GetIntValue("atNumUpperLimit")
  end
  return result
end
def.static("=>", "number").GetMaxGroupNum = function()
  local GroupUtils = require("Main.Group.GroupUtils")
  local maxGroupNum = GroupUtils.GetGroupMaxJoinNum()
  return maxGroupNum
end
def.static("table", "=>", "number", "table").FindInChatMsgData = function(atMsgData)
  local resultIdx = -1
  local resultMsg
  if atMsgData then
    local chatRecordList
    if atMsgData.channel == ChatConsts.CHANNEL_GROUP then
      chatRecordList = ChatMsgData.Instance():GetMsg64(ChatMsgData.MsgType.GROUP, atMsgData.orgId, ChatMsgData.MSGLIMIT)
    else
      chatRecordList = ChatMsgData.Instance():GetMsg(ChatMsgData.MsgType.CHANNEL, atMsgData.channel, ChatMsgData.MSGLIMIT)
    end
    if chatRecordList and #chatRecordList > 0 then
      for i = 1, #chatRecordList do
        local msg = chatRecordList[i]
        if atMsgData:EqualWithMsg(msg) then
          resultIdx = i
          resultMsg = msg
          break
        end
      end
    end
  end
  return resultIdx, resultMsg
end
def.static("number", "number", "=>", "number").GetChatRecordCount = function(type, id)
  local chatRecordList = ChatMsgData.Instance():GetMsg(type, id, ChatMsgData.MSGLIMIT)
  return chatRecordList and #chatRecordList or 0
end
def.static("number", "userdata", "=>", "number").GetChatRecordCount64 = function(type, id)
  local chatRecordList = ChatMsgData.Instance():GetMsg64(type, id, ChatMsgData.MSGLIMIT)
  return chatRecordList and #chatRecordList or 0
end
def.static("number", "number", "number", "=>", "number").GetUniqueIdx = function(type, id, unique)
  local chatRecordList = ChatMsgData.Instance():GetMsg(type, id, ChatMsgData.MSGLIMIT)
  return AtUtils._DoGetUniqueIdx(chatRecordList, unique)
end
def.static("number", "userdata", "number", "=>", "number").GetUniqueIdx64 = function(type, id, unique)
  local chatRecordList = ChatMsgData.Instance():GetMsg64(type, id, ChatMsgData.MSGLIMIT)
  return AtUtils._DoGetUniqueIdx(chatRecordList, unique)
end
def.static("table", "number", "=>", "number")._DoGetUniqueIdx = function(chatRecordList, unique)
  local resultIdx = -1
  if chatRecordList and #chatRecordList > 0 then
    for i = 1, #chatRecordList do
      local msg = chatRecordList[i]
      if msg.unique == unique then
        resultIdx = i
        break
      end
    end
  end
  return resultIdx
end
def.static("number", "=>", "string").GetChannelName = function(channel)
  local channelName = textRes.Chat.At.ChannelName[channel]
  if not channelName or not channelName then
    channelName = ""
  end
  return channelName
end
def.static("userdata", "=>", "string").GetTimeStampString = function(timeStamp)
  local nYear = 0
  local nMonth = 0
  local nDay = 0
  local nHour = 0
  if timeStamp then
    local timeInSec = Int64.ToNumber(timeStamp / 1000)
    nYear = tonumber(os.date("%Y", timeInSec))
    nMonth = tonumber(os.date("%m", timeInSec))
    nDay = tonumber(os.date("%d", timeInSec))
    nHour = tonumber(os.date("%H", timeInSec))
  end
  return string.format(textRes.Chat.At.TIME_STAMP_FORMAT, nYear, nMonth, nDay, nHour)
end
def.static("table").ReplyAtMsg = function(atMsgData)
  if nil == atMsgData then
    warn("[ERROR][AtUtils:ReplyAtMsg] atMsgData nil!")
    return
  end
  local function openCallBack(panel)
    local input
    if atMsgData.channel == ChatConsts.CHANNEL_GROUP then
      input = panel and panel.m_GroupInputViewCtrl
    elseif atMsgData.channel == ChatConsts.CHANNEL_FACTION or atMsgData.channel == ChatConsts.CHANNEL_TEAM then
      input = panel and panel.inputViewCtrl
    end
    if input then
      local name = atMsgData:GetRoleName()
      local infoPack = AtUtils.GetInfoPack(atMsgData.channel, name, atMsgData:GetRoleId(), atMsgData.orgId)
      input:AddInfoPack(string.format("@%s", name), infoPack)
    else
      warn("[ERROR][AtUtils:ReplyAtMsg] AddAtInfoPack fail! input nil for atMsgData.channel:", atMsgData.channel)
    end
  end
  if atMsgData.channel == ChatConsts.CHANNEL_GROUP then
    local GroupData = require("Main.Group.data.GroupData")
    if not GroupData.Instance():IsGroupExist(atMsgData.orgId) then
      Toast(textRes.Chat.At.REPLY_FAIL_NO_GROUP)
      return
    end
    local SocialDlg = require("Main.friend.ui.SocialDlg")
    SocialDlg.ShowGroupChatWithCallback(atMsgData.orgId, function(dlg)
      GameUtil.AddGlobalLateTimer(0.01, true, function()
        openCallBack(dlg)
      end)
    end)
  elseif atMsgData.channel == ChatConsts.CHANNEL_FACTION or atMsgData.channel == ChatConsts.CHANNEL_TEAM then
    if atMsgData.channel == ChatConsts.CHANNEL_TEAM then
      local TeamData = require("Main.Team.TeamData")
      local teamId = TeamData.Instance().teamId
      if nil == teamId or not Int64.eq(teamId, atMsgData.orgId) then
        Toast(textRes.Chat.At.REPLY_FAIL_NO_TEAM)
        return
      end
    else
      local GangData = require("Main.Gang.data.GangData")
      local gangId = GangData.Instance():GetGangId()
      if nil == gangId or not Int64.eq(gangId, atMsgData.orgId) then
        Toast(textRes.Chat.At.REPLY_FAIL_NO_GANG)
        return
      end
    end
    local ChannelChatPanel = require("Main.Chat.ui.ChannelChatPanel")
    ChannelChatPanel.ShowChannelChatPanelWithCallback(ChatConsts.CONTENT_NORMAL, atMsgData.channel, function(dlg)
      GameUtil.AddGlobalLateTimer(0.01, true, function()
        openCallBack(dlg)
      end)
    end)
  else
    warn("[ERROR][AtUtils:ReplyAtMsg] wrong channel, atMsgData.channel:", atMsgData.channel)
  end
end
def.static("number", "string", "userdata", "userdata", "=>", "string").GetInfoPack = function(channel, name, roleId, orgnizationId)
  local pack = string.format("{%s:%d,%s,%s,%s}", AtUtils.AT_PREFIX, channel, name, roleId and Int64.tostring(roleId) or "0", orgnizationId and Int64.tostring(orgnizationId) or "0")
  return pack
end
def.static("number", "number", "number", "=>", "string").GetRecordKey = function(channel, orgRecordIdx, msgRecordIdx)
  return string.format(textRes.Chat.At.AT_RECORD_KEY_FORMAT, AtUtils.AT_PREFIX, channel, orgRecordIdx, msgRecordIdx)
end
def.static("string", "=>", "boolean").ValidRolename = function(rolename)
  local NameValidator = require("Main.Common.NameValidator")
  local isValid, reason, _ = NameValidator.Instance():IsValid(rolename)
  if isValid then
    return true
  else
    warn("[ERROR][AtUtils:ValidRolename] rolename not valid, reason:", reason)
    return false
  end
end
AtUtils.Commit()
return AtUtils
