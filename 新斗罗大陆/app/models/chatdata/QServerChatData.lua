-- Author: qinyuanji
-- This utility class is used to listen to XMPP client actions and store message 

local QChatData = import(".QChatData")
local QServerChatData = class("QServerChatData", QChatData)
local QLogFile = import("...utils.QLogFile")
local QVIPUtil = import("...utils.QVIPUtil")
local utf8 = import("....lib.utf8")
local QColorLabel = import("...utils.QColorLabel")

local global_channelId = CHANNEL_TYPE.GLOBAL_CHANNEL
local union_channelId = CHANNEL_TYPE.UNION_CHANNEL
local private_channelId = CHANNEL_TYPE.PRIVATE_CHANNEL
local team_channelId = CHANNEL_TYPE.TEAM_CHANNEL
local team_info_channelId = CHANNEL_TYPE.TEAM_INFO_CHANNEL
local user_dynamic_channelId = CHANNEL_TYPE.USER_DYNAMIC_CHANNEL

local team_silves_channelId = CHANNEL_TYPE.TEAM_SILVES_CHANNEL
local team_corss_channelId = CHANNEL_TYPE.TEAM_CROSS_CHANNEL

local forbidden_char = {"一","二","三","四","五","六","七","八","九","壹","贰","叁","肆","伍","陆","柒","捌","玖","零","1","2","3","4","5","6","7","8","9","0","㈠",
"㈡","㈢","㈣","㈤","㈥","㈦","㈧","㈨","㈩","①","②","③","④","⑤","⑥","⑦","⑧","⑨","⑩","⑪","⑫","⑬","⑭","⑮","⑯","⑰","⑱","⑲","⑳","㊀","㊁","㊂","㊃","㊄",
"㊅","㊆","①","②","③","④","⑤","⑥","⑦","⑧","⑨","⑩","⑪","⑫","⑬","⑭","⑮","⑯","⑰","⑱","⑲","⑳","㉑","㉒","㉓","㉔","㉕","㉖","㉗","㉘","㉙","㉚","㉛","㉜",
"㉝","㉞","㉟","㊱","㊲","㊳","㊴","㊵","㊶","㊷","㊸","㊹","㊺","㊻","㊼","㊽","㊾","㊿","⓪","❶","❷","❸","❹","❺","❻","❼","❽","❾","❿","⑴","⑵","⑶","⑷","⑸","⑹",
"⑺","⑻","⑼","⑽","㈠","㈡","㈢","㈣","㈤","㈥","㈦","㈧","㈨","㈩","㊀","㊁","㊂","㊃","㊄","㊅","㊆","㊇","㊈","㊉","１","２","３","４","５","６","７","８","９","０",
"Ⅰ","Ⅱ","Ⅲ","Ⅳ","Ⅴ","Ⅵ","Ⅶ","Ⅷ","Ⅸ","Ⅹ","Ⅺ","Ⅻ","ⅰ","ⅱ","ⅲ","ⅳ","ⅴ","ⅵ","ⅶ","ⅷ","ⅸ","ⅹ","ⅺ","ⅻ","㉈","㉉","㉊","㉋","㉌","㉍","㉎","㉏",
"⒈","⒉","⒊","⒋","⒌","⒍","⒎","⒏","⒐",
"º","¹","²","³","⁴","⁵","⁶","⁷","⁸","⁹", 
"₀","₁","₂","₃","₄","₅","₆","₇","₈","₉",
"｜","仈","氿","彡",
"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",}
local forbidden_count = 5
local replay_count = 5
local replay_silvermine_count = 5

QServerChatData.REFRESH_TEAM_CHAT_INFO = "REFRESH_TEAM_CHAT_INFO"

QServerChatData.DETAIL_INFO = "QUIWidgetChatBar_DETAIL_INFO"

function QServerChatData:ctor(maxCount)
	QServerChatData.super.ctor(self, "server", maxCount)

	self._msgReceived[global_channelId] = {}
	self._msgReceived[union_channelId] = {}
	self._msgReceived[private_channelId] = {}
	self._msgReceived[team_channelId] = {}
	self._msgReceived[team_info_channelId] = {}
	self._msgReceived[user_dynamic_channelId] = {}

	self._msgReceived[team_silves_channelId] = {}
	self._msgReceived[team_corss_channelId] = {}

	self._msgSent[global_channelId] = {}
	self._msgSent[union_channelId] = {}
	self._msgSent[private_channelId] = {}
	self._msgSent[team_channelId] = {}

	self._msgSent[team_silves_channelId] = {}
	self._msgSent[team_corss_channelId] = {}
	self._replaySentTime = {}
	self._replaySilverMineSentTime = {}

	self._isRetrieveHistoryData = false

	app:getClient():pushReqRegister("SEND_CHAT", handler(self, self._onNewMessageReceived))

end

function QServerChatData:retrieveHistoryData( ... )
	if not self._isRetrieveHistoryData then
		app:getClient():getChatHistory(handler(self, self._onHistoryMessageReceived))
		
		if app.unlock:checkLock("UNLOCK_BLACKROCK") then
			app:getClient():getTeamChatHistory(handler(self, self._onTeamHistoryMessageReceived))
		end
		self._isRetrieveHistoryData = true
	end
end

function QServerChatData:_onHistoryMessageReceived(data)
	if data.getChatResponse == nil then return end
	if data.getChatResponse.worldChatInfos then
		for k, v in ipairs(data.getChatResponse.worldChatInfos) do
			local misc = self:parseMisc(v.params)
			self:_onMessageReceived(global_channelId, misc.uid, misc.nickName, v.content, v.sendTime/1000, misc, true)
		end

		self:setLastMessageReadTime(global_channelId, q.OSTime())
	end
	if data.getChatResponse.consortiaChatInfos then
		for k, v in ipairs(data.getChatResponse.consortiaChatInfos) do
			local misc = self:parseMisc(v.params)
			self:_onMessageReceived(union_channelId, misc.uid, misc.nickName, v.content, v.sendTime/1000, misc, true)
		end

		self:setLastMessageReadTime(union_channelId, q.OSTime())
	end
	if data.getChatResponse.personChatInfos then
		for k, v in ipairs(data.getChatResponse.personChatInfos) do
			for k1, v1 in ipairs(v.personChatInfos or {}) do
				local misc = self:parseMisc(v1.params)
				self:_onMessageReceived(private_channelId, misc.uid, misc.nickName, v1.content, v1.sendTime/1000, misc, true)

				self:setLastMessageReadTime(misc.uid, 0)
			end			
		end
	end
	self._replaySentTime = data.getChatResponse.reportChatTimes or {}
	self._replaySilverMineSentTime = data.getChatResponse.silvermineChatTimes or {}
end

function QServerChatData:_onTeamHistoryMessageReceived(data)
	if data.blackRockChatListResponse and data.blackRockChatListResponse.chats then
		for k, v in ipairs(data.blackRockChatListResponse.chats) do
			local misc = self:parseMisc(v)
			misc.name = misc.nickName
			self:_onMessageReceived(team_channelId, misc.uid, misc.nickName, misc.chat_content, tonumber(misc.seq)/1000, misc, true, true)
		end
		self:setLastMessageReadTime(team_channelId, q.OSTime())
	end
end

function QServerChatData:_onNewMessageReceived(data)
	local misc = self:parseMisc(data.chatInfo.params)
	self:_onMessageReceived(data.chatInfo.type, misc.uid, misc.nickName, data.chatInfo.content, q.OSTime(), misc)
end
 
function QServerChatData:onNewTeamMessageReceived(data)
	local misc = self:parseMisc(data.params)

	misc.name = misc.nickName


	if misc.uid == remote.user.userId then 
		self:dispatchEvent({name = QChatData.NEW_MESSAGE_RECEIVED, channelId = team_channelId, from = misc.uid, nickName = misc.nickName, message =  misc.chat_content, stamp = q.OSTime(), misc = misc})
		return 
	end
	self:_onMessageReceived(team_channelId, misc.uid, misc.nickName, misc.chat_content, q.OSTime(), misc)
end

function QServerChatData:_onMessageReceived(channelId, from, nickName, message, stamp, misc, delayed, noDispatchEvent)
	-- Private chat channel is not 3, it is stored by user's uid
	if channelId == 3 then
		if not self._msgReceived[from] then self._msgReceived[from] = {} end
		table.insert(self._msgReceived[from], {from = from, message = message, nickName = nickName, stamp = stamp, misc = misc, delayed = delayed})
		self._lastReceiveMsgTime[from] = stamp

		if table.getn(self._msgReceived[from]) > self._maxCount then
			table.remove(self._msgReceived[from], 1)
		end
	end
	self._lastReceiveMsgTime[channelId] = stamp

	self.super._onMessageReceived(self, channelId, from, nickName, message, stamp, misc, delayed, noDispatchEvent)
end

function QServerChatData:_onSilvesTeamMessageIsNew(channelId, misc)
	local isNew = true
	if self._msgReceived[channelId] then 
		for i,v in pairs(self._msgReceived[channelId]) do
			if v then
				local oldMisc = v.misc
				if oldMisc.uid == misc.uid and oldMisc.chat_content == misc.chat_content and oldMisc.seq == misc.seq then
					isNew = false
					break
				end
			end
		end
	end
	return isNew
end

function QServerChatData:_onSilvesTeamMessageReceived(channelId, to, from, nickName, message, stamp, misc, delayed, noDispatchEvent)
	-- if channelId == 3 then
	-- 	if not self._msgReceived[from] then self._msgReceived[from] = {} end
	-- 	table.insert(self._msgReceived[from], {from = from,to = to, message = message, nickName = nickName, stamp = stamp, misc = misc, delayed = delayed})
	-- 	self._lastReceiveMsgTime[from] = stamp

	-- 	if table.getn(self._msgReceived[from]) > self._maxCount then
	-- 		table.remove(self._msgReceived[from], 1)
	-- 	end
	-- end
	if not self._msgReceived[channelId] then self._msgReceived[channelId] = {} end
	local info =  {from = from, message = message, nickName = nickName, stamp = stamp, misc = misc, delayed = delayed}
	if from then
		self._lastReceiveMsgTime[from] = stamp
		info.from = from
	end
	if to then
		self._lastReceiveMsgTime[to] = stamp
		info.to = to
	end

	table.insert(self._msgReceived[channelId],info)

	-- if table.getn(self._msgReceived[channelId]) > self._maxCount then
	-- 	table.remove(self._msgReceived[channelId], 1)
	-- end

	self._lastReceiveMsgTime[channelId] = stamp
end

function QServerChatData:_onMessageSent(channel, to, nickName, avatar, message, stamp, misc)
	-- Private chat channel is not 3, it is stored by user's uid
	local misc = type(misc) == "string" and self:parseMisc(misc) or misc
	if to then
		if not self._msgSent[to] then self._msgSent[to] = {} end
		table.insert(self._msgSent[to], {to = to, message = message, nickName = nickName, avatar = avatar, stamp = stamp, misc = misc})

		if table.getn(self._msgSent[to]) > self._maxCount then
			table.remove(self._msgSent[to], 1)
		end
	end

	self.super._onMessageSent(self, channel, to, nickName, avatar, message, stamp, misc)
end

function QServerChatData:getMsgAll(channelId)
	if channelId then
		local msgAll = {}
		msgAll[channelId] = {}
		for k, v in pairs(self._msgReceived[channelId] or {}) do
			table.insert(msgAll[channelId], v)
		end
		for k, v in pairs(self._msgSent[channelId] or {}) do
			table.insert(msgAll[channelId], v)
		end

		table.sort(msgAll[channelId], function (x, y)
			return x.stamp < y.stamp
		end)

		return msgAll[channelId]
	else
		local msgAll = {}
		for k, v in pairs(self._msgReceived) do
			if next(v) then
				if not msgAll[k] then msgAll[k] = {} end
				for k1, v1 in ipairs(v) do
					table.insert(msgAll[k], v1)
				end
			end
		end
		for k, v in pairs(self._msgSent) do
			if next(v) then
				if not msgAll[k] then msgAll[k] = {} end
				for k1, v1 in ipairs(v) do
					table.insert(msgAll[k], v1)
				end
			end
		end

		for k, v in pairs(msgAll) do
			table.sort(v, function (x, y)
				return x.stamp < y.stamp
			end)
		end

		return msgAll
	end
end

function QServerChatData:getMsgReceived(channelId)
	return channelId and (self._msgReceived[channelId] or {}) or self._msgReceived
end

function QServerChatData:getMsgSent(channelId)
	return channelId and (self._msgSent[channelId] or {}) or self._msgSent
end

function QServerChatData:onlyReceiveMessage(channelId)
	if channelId == team_info_channelId or channelId == user_dynamic_channelId then
		return true
	end
	return false
end

function QServerChatData:canSendMessage(channelId)
	if channelId == global_channelId or channelId == private_channelId then
		return true
	elseif channelId == union_channelId then
		if remote.user.userConsortia.consortiaId then
			return true
		end
	elseif channelId == team_channelId then
		return true
	elseif channelId == team_corss_channelId then
		if remote.silvesArena:checkUnlock() then
			return true
		end
	end

	return false
end

function QServerChatData:messageValid(msg, channelId)
	if channelId ~= global_channelId then
		return true
	end

	local count = 0
	for _, v in ipairs(forbidden_char) do
		for w in string.gmatch(msg, v) do
  			count = count + 1
		end
	end

	if count >= forbidden_count then
		return false
	else
		return true
	end
end

function QServerChatData:saveSendTimeInfo(channelId, userId)
	if userId then
		self._lastSentMsgTime[userId] = q.OSTime()
	end
	self._lastSentMsgTime[channelId] = q.OSTime()	
end

function QServerChatData:sendMessage(msg, channelId, userId, nickName, avatar, misc, callback)	
	local misc = self:_constructMisc(misc)

	if channelId == team_channelId then
		app:getClient():sendTeamChatMessage(msg, 1,function ()
			if userId then
				self._lastSentMsgTime[userId] = q.OSTime()
			end
			self._lastSentMsgTime[channelId] = q.OSTime()

			if callback then
				callback(0)
			end

			self:_onMessageSent(channelId, userId, nickName, avatar, msg, q.OSTime(), misc)
		end, function (data)
			if callback then
				callback(data.error)
			end
		end)
	else
		app:getClient():sendChatMessage(channelId, msg, userId, misc, function ()
			if userId then
				self._lastSentMsgTime[userId] = q.OSTime()
			end
			self._lastSentMsgTime[channelId] = q.OSTime()

			if callback then
				callback(0)
			end

			self:_onMessageSent(channelId, userId, nickName, avatar, msg, q.OSTime(), misc)
		end, function (data)
			if callback then
				callback(data.error)
			end
		end)
	end
end

-- userId is to delete message in global/union channel
function QServerChatData:deleteMessage(channelId, userId)
	assert(channelId, "channelId can't be nil.")

	if channelId == global_channelId or channelId == union_channelId then
		assert(nil, "can not delete global channel or union channel")
		return
	end

	if channelId then
		self._msgSent[channelId] = {}
		self._msgReceived[channelId] = {}
	end

	if userId then
		for k, v in pairs(self._msgReceived[global_channelId]) do
			if v.from == userId then
				self._msgReceived[global_channelId][k] = nil
			end
		end
		for k, v in pairs(self._msgReceived[union_channelId]) do
			if v.from == userId then
				self._msgReceived[union_channelId][k] = nil
			end
		end
		for k, v in pairs(self._msgReceived[private_channelId]) do
			if v.from == userId then
				self._msgReceived[private_channelId][k] = nil
			end
		end
	end

	self:serializePrivateChannel()
end

function QServerChatData:getLastMessageReceiveTime(channelId)
	return channelId and (self._lastReceiveMsgTime[channelId] or 0) or self._lastReceiveMsgTime
end

function QServerChatData:getLastMessageSentTime(channelId)
	return channelId and (self._lastSentMsgTime[channelId] or 0) or self._lastSentMsgTime
end

function QServerChatData:getLastMessageReadTime(channelId)
	return channelId and (self._lastReadMsgTime[channelId] or 0) or self._lastReadMsgTime
end

function QServerChatData:setLastMessageReadTime(channelId, stamp)
	if channelId then 
		self._lastReadMsgTime[channelId] = stamp
	end
	if channelId ~= global_channelId and channelId ~= union_channelId and channelId ~= team_silves_channelId and channelId ~= team_corss_channelId and 
		channelId ~= team_corss_channelId and channelId ~= team_channelId and channelId ~= team_info_channelId and channelId ~= user_dynamic_channelId then
		self._lastReadMsgTime[private_channelId] = stamp
	end
end

function QServerChatData:globalChannelId()
	return global_channelId
end

function QServerChatData:unionChannelId()
	return union_channelId
end

function QServerChatData:privateChannelId()
	return private_channelId
end

function QServerChatData:teamChannelId()
	return team_channelId
end

function QServerChatData:teamSilvesChannelId()
	return team_silves_channelId
end

function QServerChatData:crossTeamChannelId()
	return team_corss_channelId
end

function QServerChatData:teamInfoChannelId()
	return team_info_channelId
end

function QServerChatData:userDynamicChannelId()
	return user_dynamic_channelId
end

function QServerChatData:getEarliestReplaySentTime()
	local earliestTime = q.serverTime()
	for k, v in ipairs(self._replaySentTime) do
		if v/1000 < earliestTime then
			earliestTime = v/1000
		end
	end

	return math.floor(earliestTime), #self._replaySentTime
end

function QServerChatData:setEarliestReplaySentTime(value)
	if #self._replaySentTime < replay_count then
		table.insert(self._replaySentTime, value * 1000)
	else
		local index = 1
		local earliestTime = q.serverTime()
		for k, v in ipairs(self._replaySentTime) do
			if v/1000 < earliestTime then
				earliestTime = v/1000
				index = k
			end
		end

		self._replaySentTime[index] = value * 1000
	end
end


function QServerChatData:getEarliestReplaySilverMineSentTime()
	local earliestTime = q.serverTime()
	for k, v in ipairs(self._replaySilverMineSentTime) do
		if v/1000 < earliestTime then
			earliestTime = v/1000
		end
	end

	return math.floor(earliestTime), #self._replaySilverMineSentTime
end

function QServerChatData:setEarliestReplaySilverMineSentTime(value)
	if #self._replaySilverMineSentTime < replay_silvermine_count then
		table.insert(self._replaySilverMineSentTime, value * 1000)
	else
		local index = 1
		local earliestTime = q.serverTime()
		for k, v in ipairs(self._replaySilverMineSentTime) do
			if v/1000 < earliestTime then
				earliestTime = v/1000
				index = k
			end
		end

		self._replaySilverMineSentTime[index] = value * 1000
	end
end

function QServerChatData:serializePrivateChannel()
	local msgAll = clone(self:getMsgAll())
	msgAll[global_channelId] = nil
	msgAll[union_channelId] = nil
	msgAll[private_channelId] = nil
	msgAll[team_channelId] = nil
	msgAll[team_info_channelId] = nil
	msgAll[user_dynamic_channelId] = nil
	msgAll[team_silves_channelId] = nil
	msgAll[team_corss_channelId] = nil

	for k, v in pairs(msgAll) do
		for i = 1, #v - self._maxCount do
			v[i] = nil
		end
	end
	app:getUserData():setUserValueForKey(QChatData.PRIVATE_CHAT, json.encode(msgAll))
	app:getUserData():setUserValueForKey(QChatData.PRIVATE_CHAT_VERSION, GAME_BUILD_TIME)
end

-- Delete obsolete data of sliver mine assist - http://jira.joybest.com.cn/browse/WOW-16722?filter=-1
function QServerChatData:_validAssistTime(assistTime)
	local date, hour = tonumber(q.date("%d", assistTime)), tonumber(q.date("%H", assistTime))
	local today, today_hour = tonumber(q.date("%d", q.serverTime())), tonumber(q.date("%H", q.serverTime()))
	print("date", date, "hour", hour, "today", today, "today_hour", today_hour)
	if date ~= today then
		if today_hour < 5 then
			return (today - 1) == date
		end
		return false
	elseif hour < 5 and today_hour >= 5 then
		return false
	else
		return true
	end
end

function QServerChatData:deserializePrivateChannel()
	local str = app:getUserData():getUserValueForKey(QChatData.PRIVATE_CHAT)
	if not str or str == "" then
		return 
	end
	    
	local version = app:getUserData():getUserValueForKey(QChatData.PRIVATE_CHAT_VERSION)
	if version ~= GAME_BUILD_TIME then
		QLogFile:info("Private chat format is not compatible.")
		-- return 
	end

	-- local t1 = loadstring("return " .. str)
	-- if not t1 then 
	-- 	QLogFile:error("Failed to deserialize private chat. str: " .. str)
	-- 	return 
	-- end

	local privateMsg = json.decode(str)--t1()
	QPrintTable(privateMsg)
	for k, v in pairs(privateMsg) do
		local hasData = false
		for k1, v1 in pairs(v) do
			local isAssist = v1.misc.assist ~= nil
			local isSelf = v1.misc.name == remote.user.name
			local isVoildAssistTime = self:_validAssistTime(v1.stamp)
			local isAssistVoild = v1.misc.assist == 0 or v1.misc.assist == -1

			if isAssist and isVoildAssistTime == false and ( isSelf or isAssistVoild ) then
				print("This assist log is out of date")
				QPrintTable(v1)
			else
				if v1.to then
					self:_onMessageSent(3, v1.to, v1.nickName, v1.avatar, v1.message, v1.stamp, v1.misc)
					if (self._lastSentMsgTime[k] or 0) < v1.stamp then
						self._lastSentMsgTime[k] = v1.stamp
					end
				elseif v1.from then
					self:_onMessageReceived(3, v1.from, v1.nickName, v1.message, v1.stamp, v1.misc, true)
					if (self._lastReceiveMsgTime[k] or 0) < v1.stamp then
						self._lastReceiveMsgTime[k] = v1.stamp
					end
				end

				hasData = true
			end
		end

		if hasData then
			self:setLastMessageReadTime(k, q.OSTime())
		end
	end
	self:serializePrivateChannel()
end

function QServerChatData:updateLocalReceivedMessage(channelId, seq, content)
	local t = self:getMsgReceived(channelId)
	for k, v in ipairs(t) do
		if seq == nil or seq == v.misc.seq then
			if content.message then
				v.message = content.message
			end
			if content.misc then
				for k1, v1 in pairs(content.misc) do
					v.misc[k1] = v1
				end
			end
		end
	end

	if channelId ~= self:globalChannelId() and channelId ~= self:unionChannelId() then
		self:serializePrivateChannel()
	end
end

function QServerChatData:refreshTeamChatInfo(success)
	self._lastReceiveMsgTime[team_channelId] = 0
	self._lastReadMsgTime[team_channelId] = 0
	self:deleteMessage(team_channelId)
	app:getClient():getTeamChatHistory(function(data)
			self:_onTeamHistoryMessageReceived(data)
			self:dispatchEvent({name = QServerChatData.REFRESH_TEAM_CHAT_INFO})
		end)
end

function QServerChatData:refreshSilvesTeamChatHistory(must, callback)
	must = must or false
	if not remote.silvesArena:getCompleteTeam() or not remote.silvesArena:checkCanChat() then
		if callback then
			callback(must)
		end
		return
	end
	if self._currentChannelId == self:teamSilvesChannelId() or must then
		local typeChat = SILVES_ARENA_CHAT_TYPE.SILVERS_ARENA_TEAM
		remote.silvesArena:silvesArenaChatHistoryRequest(typeChat, function ( data )
			if self.class and callback then
				callback(must)
			end
		end,function ()
			if self.class and callback then
				callback(must)
			end
		end)
	end
end

function QServerChatData:refreshSilvesCorssTeamChatHistory(must, callback)
	must = must or false
	if not remote.silvesArena:checkCanChat() then
		if callback then
			callback(must)
		end
		return
	end
	if self._currentChannelId == self:crossTeamChannelId() or must then
		local typeChat = SILVES_ARENA_CHAT_TYPE.SILVERS_ARENA_GLOBAL
		remote.silvesArena:silvesArenaChatHistoryRequest(typeChat, function ( data )
			if self.class and callback then
				self:_onTeamHistoryMessageReceived(data)
				callback(must)
			end
		end,function ()
			if self.class and callback then
				callback(must)
			end
		end)
	end
end

-- Misc should be in the form of nickName|Level|Avatar|VIP
function QServerChatData:parseMisc(misc)
	local details = {}
	local ret = {}
	if misc ~= nil then
		details = string.split(misc, "|")

		for _, v in ipairs(details) do
			local name = ""
			local value = ""
			local index = string.find(v, "=")
			if index ~= nil then
				name = string.sub(v, 0, index - 1)
				value = string.sub(v, index + 1)
			end

			if value == "" then value = nil end
			ret[name] = value
		end
	end

	return ret
end

function QServerChatData:_constructMisc(misc)
	local extra = ""
	for k, v in pairs(misc or {}) do
		extra = extra .. "|" .. k .. "=" .. v
	end
	local msg = string.format("seq=%d|nickName=%s|level=%s|avatar=%d|vip=%s|name=%s|uid=%s|union=%s|soulTrial=%d|badge=%d|userType=%d|societyOP=%d|championCount=%d", 
		os.time(), remote.user.nickname, remote.user.level, remote.user.avatar or 1, QVIPUtil:VIPLevel(), remote.user.name, 
		remote.user.userId, remote.user.userConsortia.consortiaName or "", remote.user.soulTrial or "", remote.user.nightmareDungeonPassCount or 0, remote.user.userType or 0,
		remote.user.userConsortia.rank or 0, remote.user.championCount or 0)
	msg = msg .. extra
	print("construct misc " .. msg)
	return msg
end

function QServerChatData:checkMessageLength(message)

	-- local newMessage = message
 --    local faceTble = QColorLabel.FACE_NAME
 --    for index, v in ipairs(faceTble) do
 --        for w in string.gmatch(newMessage, v) do
 --            newMessage = string.gsub(newMessage or "", w, "#"..index)
 --        end
 --    end
 --    local faceStr,faceScale,haveFace = QColorLabel:parseStringToFace(newMessage)

 --    if haveFace and not faceScale then
 --    	return message
 --    end

    local messageLen = string.utf8len(message)
    local str = message
    if messageLen > 49 then
        str = utf8.sub(message, 1, 49)
    end

    return str
end


return QServerChatData