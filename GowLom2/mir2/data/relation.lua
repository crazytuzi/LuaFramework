local relation = {
	listeners_ = {},
	chatRecords = {},
	relationType = {
		attention = "attention",
		blackList = "blackList",
		request = "request",
		near = "near",
		battleReport = "battleReport",
		friend = "friend"
	},
	chatMsgType = {
		[0] = "whisper",
		"gild",
		"corp",
		"team",
		"near",
		"loudspeaker",
		"voiceTransfer",
		"system"
	}
}
local notifier = {
	addNotifyListener = function (self, func)
		self.listeners_ = self.listeners_ or {}
		self.listeners_[#self.listeners_ + 1] = func

		return 
	end,
	removeNotifyListener = function (self, func)
		for k, v in ipairs(self.listeners_) do
			if v == func then
				table.remove(self.listeners_, k)
			end
		end

		return 
	end,
	notify = function (self, t, ...)
		slot2 = ipairs
		slot3 = self.listeners_ or {}

		for k, v in slot2(slot3) do
			v("relation", t, ...)
		end

		return 
	end
}

table.merge(slot0, notifier)

relation.sort_ = function (self, list)
	if list.sorted__ then
		return list
	end

	local function compare(l, r)
		local lonline = (l.FIsOnline and 1) or 0
		local ronline = (r.FIsOnline and 1) or 0
		local llevel = l.FLevel
		local rlevel = r.FLevel
		local lname = ""
		local rname = ""

		if l.FName and r.FName then
			rname = ycFunction:u2a(r.FName, string.len(r.FName))
			lname = ycFunction:u2a(l.FName, string.len(l.FName))
		end

		if lonline ~= ronline then
			return ronline < lonline
		elseif llevel ~= rlevel then
			return rlevel < llevel
		else
			return lname < rname
		end

		return 
	end

	table.sort(slot1, compare)

	list.sorted__ = true

	return list
end
relation.getItemByName = function (self, arr, name)
	if arr == nil then
		print("relation:getItemByName: arr is nil!")

		return 
	end

	for k, v in ipairs(arr) do
		if v.FName == name then
			return v, k
		end
	end

	return 
end
relation.getFriends = function (self)
	if self.friends then
		self.sort_(self, self.friends)

		return self.friends
	else
		return {}
	end

	return 
end
relation.getBattleReportList = function (self)
	if self.battleReport then
		return self.battleReport
	else
		return {}
	end

	return 
end
relation.getAttentions = function (self)
	if self.attentions then
		self.sort_(self, self.attentions)

		return self.attentions
	else
		return {}
	end

	return 
end
relation.getBlackList = function (self)
	if self.blackList then
		self.sort_(self, self.blackList)

		return self.blackList
	else
		return {}
	end

	return 
end
relation.getNearList = function (self)
	local list = {}

	if main_scene.ground.map then
		list = main_scene.ground.map:getHeroInfoList()
	end

	for i, v in ipairs(list) do
		v.FIsOnline = true
	end

	self.sort_(self, list)

	self.nearList = list

	return list
end
relation.getRequestList = function (self)
	if self.requestList == nil then
		return {}
	end

	return self.requestList
end
relation.getFriendRequestList = function (self)
	local list = {}

	self.sort_(self, list)

	self.nearList = list

	return list
end
relation.setAttentionColor = function (self, playername, coloridx)
	local att = self.getAttention(self, playername)

	if att then
		local rsb = DefaultClientMessage(CM_UpdateRelationColor)
		rsb.FRelationMark = 1
		rsb.FTargetName = playername
		rsb.FColor = coloridx

		MirTcpClient:getInstance():postRsb(rsb)

		att.FFocusColor = coloridx

		self.notify(self, "attentionColor", att, att)
	end

	return 
end
relation.isInAttentions = function (self, name)
	if not self.attentions then
		return false
	end

	for i, v in ipairs(self.attentions) do
		if v.FName == name then
			return true
		end
	end

	return false
end
relation.isInBlackList = function (self, name)
	if not self.blackList then
		return false
	end

	for i, v in ipairs(self.blackList) do
		if v.FName == name then
			return true
		end
	end

	return false
end
relation.getRelationShip = function (self, name)
	local r = {}

	if self.getItemByName(self, self.friends, name) then
		r.isFriend = true
	end

	if self.getItemByName(self, self.attentions, name) then
		r.isAttention = true
	end

	if self.getItemByName(self, self.blackList, name) then
		r.isBlack = true
	end

	return r
end
relation.getFriend = function (self, name)
	return self.friends and self.getItemByName(self, self.friends, name)
end
relation.getAttention = function (self, name)
	return self.attentions and self.getItemByName(self, self.attentions, name)
end
relation.getBlack = function (self, name)
	return self.blackList and self.getItemByName(self, self.blackList, name)
end
relation.getRequest = function (self, name)
	return self.requestList and self.getItemByName(self, self.requestList, name)
end
relation.addRequest = function (self, msg)
	if self.requestList == nil then
		self.requestList = {}
	end

	for i, v in ipairs(self.requestList) do
		if msg.FUserId == v.FUserId then
			v = msg

			return 
		end
	end

	g_data.pointTip:set("relation", true)
	table.insert(self.requestList, msg)

	return 
end
relation.removeRequest = function (self, msg)
	if type(msg) == "table" then
		for i, v in ipairs(self.requestList) do
			if v.FUserId == msg.FUserId then
				table.remove(self.requestList, i)
			end
		end
	end

	g_data.pointTip:set("relation", 0 < #self.requestList)

	return 
end
relation.removeAllRequest = function (self, msg)
	self.requestList = nil
	self.newQuest = false

	return 
end
local maxRecord = 99
local chatRecord = class("relation.chatRecord", slot1)
chatRecord.ctor = function (self, player, target, size)
	self.data = cache.getFriendChatRecord(player, target)
	self.data.pos = self.data.pos or 1
	self.data.maxSize = self.data.maxSize or size
	self.data.curSize = self.data.curSize or 0
	self.data.record = self.data.record or {}
	self.data.unread = self.data.unread or 0

	return 
end
chatRecord.add = function (self, content)
	local data = self.data
	data.record[data.pos] = content

	if data.maxSize <= data.pos then
		data.pos = 1
	else
		data.pos = data.pos + 1

		if data.curSize < data.maxSize then
			data.curSize = data.curSize + 1
		end
	end

	self.notify(self, "newItem", content)

	return 
end
chatRecord.readed = function (self)
	self.data.unread = 0

	return 
end
chatRecord.getUnreadCnt = function (self)
	return self.data.unread
end
chatRecord.get = function (self, pos)
	local data = self.data

	if data.maxSize <= data.curSize then
		pos = (data.pos + pos) - 1
	end

	if data.maxSize < pos then
		pos = pos - data.maxSize
	end

	return data.record[pos]
end
chatRecord.iterator = function (self)
	local pos = 1

	return function ()
		if self.data.curSize < pos then
			return nil
		end

		local re = self:get(pos)
		pos = pos + 1

		return re
	end
end
chatRecord.rIterator = function (self)
	local pos = self.data.pos - 1

	return function ()
		if self.data.curSize < pos then
			return nil
		end

		local re = self:get(pos)
		pos = pos - 1

		return re
	end
end

local function testChatRecord()
	local r1 = chatRecord.new(10)

	for k = 1, 5, 1 do
		r1.add(r1, k)
	end

	local exp = 1

	for v in r1.iterator(r1) do
		assert(v == exp, "should be equal")

		exp = exp + 1
	end

	local r2 = chatRecord.new(10)

	for k = 1, 10, 1 do
		r2.add(r2, k)
	end

	local exp = 1

	for v in r2.iterator(r2) do
		assert(v == exp, "should be equal")

		exp = exp + 1
	end

	local r3 = chatRecord.new(10)

	for k = 1, 20, 1 do
		r3.add(r3, k)
	end

	local exp = 11

	for v, k in r3.iterator(r3) do
		assert(v == exp, "should be equal")

		exp = exp + 1
	end

	return 
end

relation.recordChat = function (self, target, text, playerName)
	self.getRecords(self, playerName, target):add({
		isOther = false,
		name = playerName,
		text = text,
		time = os.time()
	})

	return 
end
relation.getRecords = function (self, playerName, target)
	if not self.chatRecords[target] then
		self.chatRecords[target] = chatRecord.new(playerName, target, maxRecord)
	end

	return self.chatRecords[target]
end
relation.filterChat = function (self, playername, text, ident, msg)
	local name = msg.FSendName

	if self.getBlack(self, name) then
		return false
	end

	if ident == "whisper" and self.getFriend(self, name) then
		local record = self.getRecords(self, playername, name)
		record.data.unread = record.data.unread + 1

		if maxRecord < record.data.unread then
			record.data.unread = maxRecord
		end

		record.add(record, {
			isOther = true,
			name = name,
			text = msg.FSayBuf,
			user = playername,
			time = os.time()
		})
	end

	return true
end
relation.setOnline = function (self, result)
	local name = result.FName
	local list, typeName = nil

	if result.Flag == 0 then
		list = self.friends
		typeName = self.relationType.friend
	elseif result.Flag == 1 then
		list = self.attentions
		typeName = self.relationType.attention
	elseif result.Flag == 2 then
		list = self.blackList
		typeName = self.relationType.blackList
	end

	if not list then
		return 
	end

	list.sorted__ = false
	local item = self.getItemByName(self, list, name)

	if item then
		item.FIsOnline = result.FIsOnline
	end

	self.notify(self, typeName)

	return 
end
relation.onSM_RelationMemberOnline = function (result, protoId)
	result.FIsOnline = true

	g_data.relation:setOnline(result)

	return 
end
relation.onSM_RelationMemberOffline = function (result, protoId)
	result.FIsOnline = false

	g_data.relation:setOnline(result)

	return 
end
relation.updateSMFriendInfo = function (self, arr, record)
	local act = record.Flag

	if act == 0 then
		arr.sorted__ = false
		arr[#arr + 1] = record

		return record
	elseif act == 1 then
		local item, idx = self.getItemByName(self, arr, record.FName)

		if idx then
			table.remove(arr, idx)
		end

		return item
	elseif act == 2 then
		arr.sorted__ = false
		local item, index = self.getItemByName(self, arr, record.FName)

		if index then
			arr[index] = record
		end

		return item, record
	end

	return 
end
relation.onSM_ClientFriendRelation = function (result, protoId)
	if not g_data.relation.friends then
		return 
	end

	if not result then
		return 
	end

	g_data.relation:updateSMFriendInfo(g_data.relation.friends, result.FClientFriendRelation)

	for i, v in ipairs(g_data.relation.friends) do
		print("relation:updateFriend", v.FName)
		g_data.mark:addFriend(v.FName)
	end

	g_data.relation:notify(g_data.relation.relationType.friend)

	return 
end
relation.onSM_ClientNormBlackListRelation = function (result, protoId)
	if not g_data.relation.blackList then
		return 
	end

	g_data.relation:updateSMFriendInfo(g_data.relation.blackList, result.FClientNormBlackListRelation)

	for i, v in ipairs(g_data.relation.blackList) do
		print("relation:updateBlackList", v.FName)
		g_data.mark:addFriend(v.FName)
	end

	g_data.relation:notify(g_data.relation.relationType.blackList)

	return 
end
relation.onSM_ClientAttentionRelation = function (result, protoId)
	if not g_data.relation.attentions then
		return 
	end

	g_data.relation:updateSMFriendInfo(g_data.relation.attentions, result.FClientAttentionRelation)

	for i, v in ipairs(g_data.relation.attentions) do
		print("relation:updateBlackList", v.FName)
		g_data.mark:addFriend(v.FName)
	end

	g_data.relation:notify(g_data.relation.relationType.attention)

	return 
end
relation.onSM_ClientFriendRelationList = function (result, protoId)
	if not result then
		return 
	end

	g_data.relation.friends = result.FRelationList

	for i, v in ipairs(g_data.relation.friends) do
		print("relation:setFriends", v.FName)
		g_data.mark:addFriend(v.FName)
	end

	g_data.relation:notify(g_data.relation.relationType.friend)

	return 
end
relation.onSM_ClientNormBlackListRelationList = function (result, protoId)
	if not result then
		return 
	end

	g_data.relation.blackList = result.FRelationList

	for i, v in ipairs(g_data.relation.blackList) do
		print("relation:setFriends", v.FName)
		g_data.mark:addFriend(v.FName)
	end

	g_data.relation:notify(g_data.relation.relationType.blackList)

	return 
end
relation.onSM_ClientAttentionRelationList = function (result, protoId)
	if not result then
		return 
	end

	g_data.relation.attentions = result.FRelationList

	for i, v in ipairs(g_data.relation.attentions) do
		print("relation:setFriends", v.FName)
		g_data.mark:addFriend(v.FName)
	end

	g_data.relation:notify(g_data.relation.relationType.attention)

	return 
end

return relation
