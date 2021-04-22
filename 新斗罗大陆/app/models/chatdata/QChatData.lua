-- Author: qinyuanji
-- This utility class is the base class for chat data
-- Any class derived from it is applicable in Chat dialog

local QChatData = class("QChatData")

QChatData.NEW_MESSAGE_RECEIVED = "QChatData_NEW_MESSAGE_RECEIVED"
QChatData.NEW_MESSAGE_SENT = "QChatData_NEW_MESSAGE_SENT"
QChatData.PRIVATE_CHAT = "PrivateChat"
QChatData.PRIVATE_CHAT_VERSION = "PrivateChatVersion"

function QChatData:ctor(type, maxCount)
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

	self._msgReceived = {}
	self._msgSent = {}
	self._type = type
	self._maxCount = maxCount or 20

	self._lastSentMsgTime = {}
	self._lastReceiveMsgTime = {}
	self._lastReadMsgTime = {}
end

function QChatData:setMaxCount(maxCount)
	self._maxCount = maxCount
end

function QChatData:getMaxCount()
	return self._maxCount
end

function QChatData:getMsgAll(channelId)
	local msgAll = {}
	for k, v in ipairs(self._msgReceived) do
		table.insert(msgAll, v)
	end
	for k, v in ipairs(self._msgSent) do
		table.insert(msgAll, v)
	end

	return msgAll
end

-- All message received are stored here
function QChatData:getMsgReceived(channelId)
	return self._msgReceived
end

-- All message sent are stored here
function QChatData:getMsgSent(channelId)
	return self._msgSent
end

-- Get data type, can be xmpp, bulletin, etc..
function QChatData:getType()
	return self._type
end

function QChatData:deleteMessage(channelId, nickName)
	assert(nil, "deleteMessage is not implemented")
end

function QChatData:getLastMessageReceiveTime(channelId)
	return 0
end

function QChatData:getLastMessageSentTime(channelId)
	return 0
end

function QChatData:getLastMessageReadTime(channelId)
	return 0
end

function QChatData:setLastMessageReadTime(channelId, stamp)
	return 0
end

-- Update the refresh frequency 
function QChatData:setSensitivity(value)
end

-- If this data is only for receiving data, not for sending data
function QChatData:onlyReceiveMessage()
	return true
end

-- Check if sending message out is available
function QChatData:canSendMessage(channelId)
	return true
end

-- Check if message is forbidden or not
function QChatData:messageValid(msg)
	return true
end

function QChatData:sendMessage(msg, channelId, userId, nickName, misc, callback)
	-- body
end

function QChatData:saveSendTimeInfo(channelId, userId)
	-- body
end

function QChatData:globalChannelId()
	return -1
end

function QChatData:unionChannelId()
	return -1
end

function QChatData:privateChannelId()
	return -1
end

function QChatData:teamChannelId()
	return -1
end

function QChatData:teamInfoChannelId()
	return -1
end

function QChatData:userDynamicChannelId()
	return -1
end

function QChatData:teamSilvesChannelId()
	return -1
end

function QChatData:crossTeamChannelId()
	return -1
end

function QChatData:serializePrivateChannel()
end

function QChatData:deserializePrivateChannel()
end

function QChatData:_onSilvesTeamMessageIsNew()
end

function QChatData:messgeReceivedToString(channelId)
	return outputTable(channelId and self._msgReceived[channelId] or self._msgReceived)
end

-- Triggered when new message is received
function QChatData:_onMessageReceived(channelId, from, nickName, message, stamp, misc, delayed, noDispatchEvent)
	local t = channelId and self._msgReceived[channelId] or self._msgReceived
	table.insert(t, {from = from, message = message, nickName = nickName, stamp = stamp, misc = misc, delayed = delayed})
	if table.getn(t) > self._maxCount then
		table.remove(t, 1)
	end

	if noDispatchEvent ~= true then
		self:dispatchEvent({name = QChatData.NEW_MESSAGE_RECEIVED, channelId = channelId, from = from, nickName = nickName, message = message, stamp = stamp, misc = misc, delayed = delayed})
	end
 	self:serializePrivateChannel()
end

function QChatData:_onMessageSent(channelId, to, nickName, avatar, message, stamp, misc)
	local t = channelId and self._msgSent[channelId] or self._msgSent
	table.insert(t, {to = to, message = message, nickName = nickName, avatar = avatar, stamp = stamp, misc = misc})
	if table.getn(t) > self._maxCount then
		table.remove(t, 1)
	end

	self:dispatchEvent({name = QChatData.NEW_MESSAGE_SENT, channelId = channelId, to = to, nickName = nickName, message = message, stamp = stamp, misc = misc})
 	self:serializePrivateChannel()
end

function QChatData:updateLocalReceivedMessage(channelId, seq, content)
end

-- Construct misc
function QChatData:parseMisc(misc)
	local ret = misc or {}
	return ret
end


return QChatData