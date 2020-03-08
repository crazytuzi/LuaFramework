local Lplus = require("Lplus")
local ChatMsgBuilder = Lplus.Class("ChatMsgBuilder")
local def = ChatMsgBuilder.define
local OctetsStream = require("netio.OctetsStream")
local Octets = require("netio.Octets")
local ChatMsgData = require("Main.Chat.ChatMsgData")
local SpeechMgr = require("Main.Chat.SpeechMgr")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local ChatConsts = require("netio.protocol.mzm.gsp.chat.ChatConsts")
local json = require("Utility.json")
local ChatUtils = require("Main.Chat.ChatUtils")
local uniqueGenerator = 0
def.static("=>", "number").GetUnique = function()
  uniqueGenerator = uniqueGenerator + 1
  return uniqueGenerator
end
local hideqoute = function(cnt)
  return (string.gsub(cnt, "'", "&qout;"))
end
local showqoute = function(cnt)
  return (string.gsub(cnt, "&qout;", "'"))
end
def.static("table", "=>", "table").FriendMsgToLocalMsg = function(friendMsg)
  if friendMsg.note then
    return nil
  end
  local localMsg = {}
  localMsg[1] = friendMsg.roleId:tostring()
  localMsg[2] = friendMsg.roleName
  localMsg[3] = friendMsg.gender
  localMsg[4] = friendMsg.vipLevel
  localMsg[5] = friendMsg.level
  localMsg[6] = friendMsg.occupationId
  localMsg[7] = friendMsg.modelId
  localMsg[8] = friendMsg.badge
  localMsg[9] = friendMsg.contentType
  localMsg[10] = friendMsg.time
  localMsg[11] = friendMsg.type
  localMsg[12] = friendMsg.id:tostring()
  if friendMsg.contentType == ChatConsts.CONTENT_YY then
    localMsg[13] = friendMsg.fileId
    localMsg[14] = friendMsg.second
    localMsg[15] = friendMsg.text
    localMsg[16] = friendMsg.avatarId
    localMsg[17] = friendMsg.bubbleId
    localMsg[18] = friendMsg.avatarFrameId
    if friendMsg.timestamp then
      localMsg[19] = friendMsg.timestamp:tostring()
    else
      localMsg[19] = "0"
    end
  elseif friendMsg.contentType == ChatConsts.CONTENT_NORMAL then
    localMsg[13] = hideqoute(friendMsg.raw)
    localMsg[14] = friendMsg.avatarId
    localMsg[15] = friendMsg.bubbleId
    localMsg[16] = friendMsg.avatarFrameId
    if friendMsg.timestamp then
      localMsg[17] = friendMsg.timestamp:tostring()
    else
      localMsg[17] = "0"
    end
  end
  return localMsg
end
def.static("table", "=>", "table").LocalMsgToFriendMsg = function(localMsg)
  local FriendMsg = {}
  FriendMsg.roleId = Int64.new(localMsg[1])
  FriendMsg.roleName = localMsg[2]
  FriendMsg.gender = localMsg[3]
  FriendMsg.vipLevel = localMsg[4]
  FriendMsg.level = localMsg[5]
  FriendMsg.occupationId = localMsg[6]
  FriendMsg.modelId = localMsg[7]
  FriendMsg.badge = localMsg[8]
  FriendMsg.contentType = localMsg[9]
  FriendMsg.time = localMsg[10]
  FriendMsg.type = localMsg[11]
  FriendMsg.id = Int64.new(localMsg[12])
  FriendMsg.unique = ChatMsgBuilder.GetUnique()
  if FriendMsg.contentType == ChatConsts.CONTENT_YY then
    FriendMsg.content = nil
    FriendMsg.fileId = localMsg[13]
    FriendMsg.second = localMsg[14]
    FriendMsg.text = localMsg[15]
    FriendMsg.avatarId = localMsg[16]
    FriendMsg.bubbleId = localMsg[17]
    FriendMsg.avatarFrameId = localMsg[18]
    if localMsg[19] then
      FriendMsg.timestamp = Int64.new(localMsg[19])
    else
      FriendMsg.timestamp = Int64.new(0)
    end
    FriendMsg.plainHtml = HtmlHelper.ConvertYYJsonChat(FriendMsg, false)
    FriendMsg.mainHtml = FriendMsg.plainHtml
  elseif FriendMsg.contentType == ChatConsts.CONTENT_NORMAL then
    FriendMsg.raw = showqoute(localMsg[13])
    FriendMsg.avatarId = localMsg[14]
    FriendMsg.bubbleId = localMsg[15]
    FriendMsg.avatarFrameId = localMsg[16]
    if localMsg[17] then
      FriendMsg.timestamp = Int64.new(localMsg[17])
    else
      FriendMsg.timestamp = Int64.new(0)
    end
    FriendMsg.content = ChatMsgBuilder.CustomFilter(FriendMsg.raw)
    require("Utility/Utf8Helper")
    FriendMsg.content = _G.TrimIllegalChar(FriendMsg.content)
    FriendMsg.content = HtmlHelper.ConvertInfoPack(FriendMsg.content)
    FriendMsg.plainHtml = HtmlHelper.ConvertPlainChat(FriendMsg)
    FriendMsg.mainHtml = FriendMsg.plainHtml
  end
  return FriendMsg
end
def.static("table", "=>", "table").BuildGroupMsg = function(rawMsg)
  local msg = {}
  msg.roleId = rawMsg.content.roleId
  msg.roleName = rawMsg.content.roleName
  msg.gender = rawMsg.content.gender
  msg.vipLevel = rawMsg.content.vipLevel
  msg.level = rawMsg.content.level
  msg.occupationId = rawMsg.content.occupationId
  msg.modelId = rawMsg.content.modelId
  msg.badge = rawMsg.content.badge
  msg.avatarId = rawMsg.content.avatarid
  msg.contentType = rawMsg.content.contentType
  msg.bubbleId = rawMsg.content.chatBubbleCfgId
  msg.avatarFrameId = rawMsg.content.avatar_frame_id
  msg.timestamp = rawMsg.content.timestamp
  msg.time = ChatUtils.GetTimeInSecFromStamp(msg.timestamp)
  msg.type = ChatMsgData.MsgType.GROUP
  msg.id = rawMsg.groupid
  msg.unique = ChatMsgBuilder.GetUnique()
  if msg.contentType == ChatConsts.CONTENT_YY then
    msg.content = ChatMsgBuilder.Unmarshal(rawMsg.content.content)
    local result = json.decode(msg.content)
    msg.fileId = result.fileId
    if result.audioOnly then
      result.text = textRes.Chat[73]
    else
      if result.text == nil then
        result.text = ""
      end
      result.text = ChatMsgBuilder.CustomFilter(result.text)
      result.text = (result.text == "" or result.text == " ") and textRes.Chat[23] or result.text
    end
    msg.second = result.second
    msg.text = result.text == "nil" and "" or result.text
    msg.plainHtml = HtmlHelper.ConvertYYJsonChat(msg, false)
    msg.mainHtml = msg.plainHtml
  elseif msg.contentType == ChatConsts.CONTENT_NORMAL then
    msg.raw = ChatMsgBuilder.Unmarshal(rawMsg.content.content)
    msg.content = ChatMsgBuilder.CustomFilter(msg.raw)
    require("Utility/Utf8Helper")
    msg.content = _G.TrimIllegalChar(msg.content)
    msg.content = HtmlHelper.ConvertInfoPack(msg.content)
    msg.plainHtml = HtmlHelper.ConvertPlainChat(msg)
    msg.mainHtml = msg.plainHtml
  elseif msg.contentType == ChatConsts.CONTENT_CHATGIFT then
    local _redGiftInfo = ChatMsgBuilder.UnmarshalRedGift(rawMsg.content.content)
    msg.redGiftId = _redGiftInfo.chatGiftId
    msg.content = ChatMsgBuilder.CustomFilter(_redGiftInfo.chatGiftStr)
    require("Utility/Utf8Helper")
    msg.content = _G.TrimIllegalChar(msg.content)
    msg.mainHtml = HtmlHelper.ConvertChatRedGiftMainChat(msg)
    msg.plainHtml = HtmlHelper.ConvertChatRedGiftPlainChat(msg)
    local _worldRedGiftInfo = {}
    _worldRedGiftInfo.roleInfo = {}
    _worldRedGiftInfo.content = msg.content
    _worldRedGiftInfo.channelType = msg.type
    _worldRedGiftInfo.channelSubType = ChatMsgData.Channel.GROUP
    _worldRedGiftInfo.redGiftId = msg.redGiftId
    _worldRedGiftInfo.roleInfo.name = msg.roleName
    _worldRedGiftInfo.roleInfo.roleId = msg.roleId
    _worldRedGiftInfo.roleInfo.menpai = msg.occupationId
    _worldRedGiftInfo.roleInfo.level = msg.level
    _worldRedGiftInfo.roleInfo.gender = msg.gender
    _worldRedGiftInfo.roleInfo.avatarId = msg.avatarId
    _worldRedGiftInfo.groupId = msg.id
    Event.DispatchEvent(ModuleId.CHATREDGIFT, gmodule.notifyId.ChatRedGift.New_ChatRedGift, {redGiftInfo = _worldRedGiftInfo})
  end
  return msg
end
def.static("table", "=>", "table").BuildFriendMsg = function(rawMsg)
  local msg = {}
  msg.roleId = rawMsg.chatContent.roleId
  msg.roleName = rawMsg.chatContent.roleName
  msg.gender = rawMsg.chatContent.gender
  msg.vipLevel = rawMsg.chatContent.vipLevel
  msg.level = rawMsg.chatContent.level
  msg.occupationId = rawMsg.chatContent.occupationId
  msg.modelId = rawMsg.chatContent.modelId
  msg.badge = rawMsg.chatContent.badge
  msg.avatarId = rawMsg.chatContent.avatarid
  msg.contentType = rawMsg.chatContent.contentType
  msg.bubbleId = rawMsg.chatContent.chatBubbleCfgId
  msg.avatarFrameId = rawMsg.chatContent.avatar_frame_id
  msg.timestamp = rawMsg.chatContent.timestamp
  msg.time = ChatUtils.GetTimeInSecFromStamp(msg.timestamp)
  msg.type = ChatMsgData.MsgType.FRIEND
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp.id == rawMsg.listenerId then
    msg.id = rawMsg.senderId
  else
    msg.id = rawMsg.listenerId
  end
  msg.unique = ChatMsgBuilder.GetUnique()
  if msg.contentType == ChatConsts.CONTENT_YY then
    msg.content = ChatMsgBuilder.Unmarshal(rawMsg.chatContent.content)
    local result = json.decode(msg.content)
    msg.fileId = result.fileId
    if result.audioOnly then
      result.text = textRes.Chat[73]
    else
      if result.text == nil then
        result.text = ""
      end
      result.text = ChatMsgBuilder.CustomFilter(result.text)
      result.text = (result.text == "" or result.text == " ") and textRes.Chat[23] or result.text
    end
    msg.second = result.second
    msg.text = result.text == "nil" and "" or result.text
    msg.plainHtml = HtmlHelper.ConvertYYJsonChat(msg, false)
    msg.mainHtml = msg.plainHtml
  elseif msg.contentType == ChatConsts.CONTENT_NORMAL then
    msg.raw = ChatMsgBuilder.Unmarshal(rawMsg.chatContent.content)
    msg.content = ChatMsgBuilder.CustomFilter(msg.raw)
    require("Utility/Utf8Helper")
    msg.content = _G.TrimIllegalChar(msg.content)
    msg.content = HtmlHelper.ConvertInfoPack(msg.content)
    msg.plainHtml = HtmlHelper.ConvertPlainChat(msg)
    msg.mainHtml = msg.plainHtml
  end
  return msg
end
def.static("table", "number", "=>", "table").BuildChannelMsg = function(rawMsg, id)
  local msg = {}
  msg.roleId = rawMsg.chatContent.roleId
  msg.roleName = rawMsg.chatContent.roleName
  msg.gender = rawMsg.chatContent.gender
  msg.vipLevel = rawMsg.chatContent.vipLevel
  msg.level = rawMsg.chatContent.level
  msg.occupationId = rawMsg.chatContent.occupationId
  msg.modelId = rawMsg.chatContent.modelId
  msg.badge = rawMsg.chatContent.badge
  msg.avatarId = rawMsg.chatContent.avatarid
  msg.contentType = rawMsg.chatContent.contentType
  msg.bubbleId = rawMsg.chatContent.chatBubbleCfgId
  msg.avatarFrameId = rawMsg.chatContent.avatar_frame_id
  msg.type = ChatMsgData.MsgType.CHANNEL
  msg.timestamp = rawMsg.chatContent.timestamp
  msg.time = ChatUtils.GetTimeInSecFromStamp(msg.timestamp)
  msg.id = id
  if msg.id == ChatMsgData.Channel.TEAM and rawMsg.position == 1 then
    msg.isCaptain = true
  elseif msg.id == ChatMsgData.Channel.FACTION then
    msg.position = rawMsg.position
  elseif msg.id == ChatMsgData.Channel.LIVE then
    msg.server = rawMsg.senderZoneId
  elseif msg.id == ChatMsgData.Channel.CITY then
    msg.server = rawMsg.sender_zoneId
  elseif msg.id == ChatMsgData.Channel.TRUMPET then
    msg.trumpetId = rawMsg.trumpet_cfg_id
  end
  msg.unique = ChatMsgBuilder.GetUnique()
  if msg.contentType == ChatConsts.CONTENT_YY then
    msg.content = ChatMsgBuilder.Unmarshal(rawMsg.chatContent.content)
    local result = json.decode(msg.content)
    msg.fileId = result.fileId
    if result.audioOnly then
      result.text = textRes.Chat[73]
    else
      if result.text == nil then
        result.text = ""
      end
      result.text = ChatMsgBuilder.CustomFilter(result.text)
      result.text = (result.text == "" or result.text == " ") and textRes.Chat[23] or result.text
    end
    msg.second = result.second
    msg.text = result.text == "nil" and "" or result.text
    msg.mainHtml = HtmlHelper.ConvertYYJsonMain(msg)
    msg.plainHtml = HtmlHelper.ConvertYYJsonChat(msg, false)
  elseif msg.contentType == ChatConsts.CONTENT_NORMAL then
    msg.content = ChatMsgBuilder.CustomFilter(ChatMsgBuilder.Unmarshal(rawMsg.chatContent.content))
    require("Utility/Utf8Helper")
    msg.content = _G.TrimIllegalChar(msg.content)
    msg.content = HtmlHelper.ConvertInfoPack(msg.content)
    msg.mainHtml = HtmlHelper.ConvertMainChat(msg)
    msg.plainHtml = HtmlHelper.ConvertPlainChat(msg)
  elseif msg.contentType == ChatConsts.CONTENT_CHATGIFT then
    local _redGiftInfo = ChatMsgBuilder.UnmarshalRedGift(rawMsg.chatContent.content)
    msg.redGiftId = _redGiftInfo.chatGiftId
    msg.content = ChatMsgBuilder.CustomFilter(_redGiftInfo.chatGiftStr)
    require("Utility/Utf8Helper")
    msg.content = _G.TrimIllegalChar(msg.content)
    msg.mainHtml = HtmlHelper.ConvertChatRedGiftMainChat(msg)
    msg.plainHtml = HtmlHelper.ConvertChatRedGiftPlainChat(msg)
    local _worldRedGiftInfo = {}
    _worldRedGiftInfo.roleInfo = {}
    _worldRedGiftInfo.content = msg.content
    _worldRedGiftInfo.channelType = msg.type
    _worldRedGiftInfo.channelSubType = msg.id
    _worldRedGiftInfo.redGiftId = msg.redGiftId
    _worldRedGiftInfo.roleInfo.name = msg.roleName
    _worldRedGiftInfo.roleInfo.roleId = msg.roleId
    _worldRedGiftInfo.roleInfo.menpai = msg.occupationId
    _worldRedGiftInfo.roleInfo.level = msg.level
    _worldRedGiftInfo.roleInfo.gender = msg.gender
    _worldRedGiftInfo.roleInfo.avatarId = msg.avatarId
    _worldRedGiftInfo.roleInfo.avatarFrameId = msg.avatarFrameId
    Event.DispatchEvent(ModuleId.CHATREDGIFT, gmodule.notifyId.ChatRedGift.New_ChatRedGift, {redGiftInfo = _worldRedGiftInfo})
  end
  return msg
end
def.static("string", "string", "string", "number", "=>", "table").BuildWorldQuestionMsg = function(questionContent, mainChatTips, plainChatRoleName, plainCharRoleIconId)
  local msg = {}
  msg.roleId = 1
  msg.roleName = plainChatRoleName
  msg.publishIcon = plainCharRoleIconId
  msg.type = ChatMsgData.MsgType.CHANNEL
  msg.id = ChatMsgData.Channel.WORLD
  msg.contentType = ChatConsts.CONTENT_NORMAL
  msg.unique = ChatMsgBuilder.GetUnique()
  msg.mainChatTips = mainChatTips
  msg.plainChatRoleName = plainChatRoleName
  msg.questionContent = questionContent
  msg.mainHtml = HtmlHelper.ConvertWorldQuestionMainChat(msg)
  msg.plainHtml = HtmlHelper.ConvertWorldQuestionPlainChat(msg)
  return msg
end
def.static("string", "string", "string", "string", "number", "=>", "table").BuildWorldQuestionNotice = function(mainChatRoleName, mainChatText, plainChatRoleName, plainChatText, plainCharRoleIconId)
  local msg = {}
  msg.roleId = 1
  msg.roleName = plainChatRoleName
  msg.publishIcon = plainCharRoleIconId
  msg.type = ChatMsgData.MsgType.CHANNEL
  msg.id = ChatMsgData.Channel.WORLD
  msg.contentType = ChatConsts.CONTENT_NORMAL
  msg.unique = ChatMsgBuilder.GetUnique()
  msg.mainChatRoleName = mainChatRoleName
  msg.mainChatText = mainChatText
  msg.plainChatRoleName = plainChatRoleName
  msg.plainChatText = plainChatText
  msg.mainHtml = HtmlHelper.ConvertWorldQuestionNoticeMainChat(msg)
  msg.plainHtml = HtmlHelper.ConvertWorldQuestionNoticePlainChat(msg)
  return msg
end
def.static("number", "number", "table", "=>", "table").BuildWorldQuestionSystemMsg = function(id, style, content)
  local msg = {}
  content = HtmlHelper.ConvertWorldQuestionSystemMsg(content)
  msg.content = content
  msg.mainHtml = HtmlHelper.ConvertSystemMsg(style, content)
  msg.plainHtml = msg.mainHtml
  msg.type = ChatMsgData.MsgType.SYSTEM
  msg.id = id
  msg.unique = ChatMsgBuilder.GetUnique()
  return msg
end
def.static("table", "=>", "table").BuildTeamPlatformMsg = function(info)
  local msg = {}
  msg.roleId = info.roleId
  msg.roleName = info.roleName
  msg.gender = info.gender
  msg.vipLevel = info.vipLevel
  msg.level = info.level
  msg.occupationId = info.occupationId
  msg.avatarId = info.avatarid
  msg.bubbleId = info.chatBubbleCfgId
  msg.avatarFrameId = info.avatar_frame_id
  msg.badge = info.badge
  msg.content = HtmlHelper.ConvertInfoPack(info.content)
  msg.type = ChatMsgData.MsgType.CHANNEL
  msg.id = ChatMsgData.Channel.TEAM
  msg.contentType = ChatConsts.CONTENT_NORMAL
  msg.unique = ChatMsgBuilder.GetUnique()
  msg.mainHtml = HtmlHelper.ConvertMainChat(msg)
  msg.plainHtml = HtmlHelper.ConvertPlainChat(msg)
  return msg
end
def.static("number", "number", "table", "=>", "table").BuildSystemMsg = function(id, style, content)
  local msg = {}
  msg.content = content
  msg.mainHtml = HtmlHelper.ConvertSystemMsg(style, content)
  msg.plainHtml = msg.mainHtml
  msg.type = ChatMsgData.MsgType.SYSTEM
  msg.id = id
  msg.unique = ChatMsgBuilder.GetUnique()
  return msg
end
def.static("number", "number", "string", "=>", "table").BuildNoteMsg = function(type, id, content)
  local msg = {}
  msg.note = true
  msg.content = HtmlHelper.ConvertEmoji(content)
  msg.type = type
  msg.id = id
  msg.mainHtml = HtmlHelper.ConvertNoteMainChat(msg)
  msg.plainHtml = HtmlHelper.ConvertNotePlainChat(msg)
  msg.unique = ChatMsgBuilder.GetUnique()
  return msg
end
def.static("number", "userdata", "string", "=>", "table").BuildNoteMsg64 = function(type, id, content)
  local msg = {}
  msg.note = true
  msg.content = HtmlHelper.ConvertEmoji(content)
  msg.type = type
  msg.id = id
  msg.time = GetServerTime()
  msg.plainHtml = HtmlHelper.ConvertNotePlainChat(msg)
  msg.mainHtml = msg.plainHtml
  msg.unique = ChatMsgBuilder.GetUnique()
  return msg
end
def.static("userdata", "=>", "string").Unmarshal = function(content)
  local key, os = OctetsStream.beginTempStream()
  os:marshalOctets(content)
  local msg = os:unmarshalStringFromOctets()
  OctetsStream.endTempStream(key)
  return msg
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
def.static("userdata", "=>", "table").UnmarshalRedGift = function(content)
  local key, os = OctetsStream.beginTempStream()
  local ChatGiftOctets = require("netio.protocol.mzm.gsp.chat.ChatGiftOctets")
  local _chatOctet = ChatGiftOctets.new()
  Octets.unmarshalBean(content, _chatOctet)
  return _chatOctet
end
ChatMsgBuilder.Commit()
return ChatMsgBuilder
