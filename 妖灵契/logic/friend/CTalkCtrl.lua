local CTalkCtrl = class("CTalkCtrl", CCtrlBase)

function CTalkCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_Notify = {}
	self.m_TotalNotify = 0
	--msgdata={pid={聊天记录}}  
	--recordindex={pid={msgdata里保存数据与否的分界}} 
	--lastrecord={pid=filename} 读取聊天文件，读取到数据块
	--lasttime 两条消息间是否需要时间串
	--messageid 消息ID
	self.m_MsgData = {}
	self.m_RecordIndex = {}
	self.m_LastRecord = {}
	self.m_LastTime = {}
	self.m_MessageID = {}
end

function CTalkCtrl.ResetCtrl(self)
	self.m_Notify = {}
	self.m_TotalNotify = 0
	self.m_MsgData = {}
	self.m_RecordIndex = {}
	self.m_LastRecord = {}
	self.m_LastTime = {}
	self.m_MessageID = {}
end

function CTalkCtrl.AddNotify(self, pid)
	if not self.m_Notify[pid] then
		self.m_Notify[pid] = 0
	end
	self.m_Notify[pid] = self.m_Notify[pid] + 1
	self.m_TotalNotify = self.m_TotalNotify + 1
	self:OnEvent(define.Talk.Event.AddNotify, pid)
end

function CTalkCtrl.GetNotify(self, pid)
	if not self.m_Notify[pid] then
		self.m_Notify[pid] = 0
	end
	return self.m_Notify[pid]
end

function CTalkCtrl.GetTotalNotify(self)
	return self.m_TotalNotify
end

function CTalkCtrl.InitMsg(self, pid)
	if not self.m_MsgData[pid] then
		self.m_MsgData[pid] = {}
	end

	if not self.m_RecordIndex[pid] then
		self.m_RecordIndex[pid] = 0
	end
end

function CTalkCtrl.GetMsg(self, pid)
	self:InitMsg(pid)
	self.m_TotalNotify = self.m_TotalNotify - self:GetNotify(pid)
	self.m_TotalNotify = math.max(self.m_TotalNotify, 0)
	self.m_Notify[pid] = 0
	self:OnEvent(define.Talk.Event.DelNotify, pid)
	if g_FriendCtrl:IsBlackFriend(pid) then
		return {}
	end
	if #self.m_MsgData[pid] == 0 then
		self:LoadMsgRecord(pid)
	end

	return self.m_MsgData[pid]
end

function CTalkCtrl.AddMsg(self, pid, msg, msgid)
	if pid ~= g_AttrCtrl.pid then
		if g_MaskWordCtrl:IsContainHideStr(msg) then
			return
		end
	end
	self:InitMsg(pid)
	local oMsg = CTalkMsg.New(pid, msg)
	local lasttime = self.m_LastTime[pid]
	local iAmount = 1
	if not lasttime then
		lasttime = 0
	end
	
	if g_TimeCtrl:GetTimeS() - lasttime > 300 then
		iAmount = 2
		local timemsg = CTalkMsg.New("time", g_TimeCtrl:GetTimeS())
		table.insert(self.m_MsgData[pid], 1, timemsg)
		self.m_RecordIndex[pid] = self.m_RecordIndex[pid] + 1
		self.m_LastTime[pid] = g_TimeCtrl:GetTimeS()
	end
	
	table.insert(self.m_MsgData[pid], 1, oMsg)
	self.m_RecordIndex[pid] = self.m_RecordIndex[pid] + 1
	g_FriendCtrl:RefreshRecent(pid)
	self:AddNotify(pid)
	self:OnEvent(define.Talk.Event.AddMsg, {pid=pid, amount=iAmount})
end

function CTalkCtrl.AddSelfMsg(self, pid, msg)
	self:InitMsg(pid)
	local oMsg = CTalkMsg.New(g_AttrCtrl.pid, msg)
	local lasttime = self.m_LastTime[pid]
	local iAmount = 1
	if not lasttime then
		lasttime = 0
	end
	if g_TimeCtrl:GetTimeS() - lasttime > 300 then
		iAmount = 2
		local timemsg = CTalkMsg.New("time", g_TimeCtrl:GetTimeS())
		table.insert(self.m_MsgData[pid], 1, timemsg)
		self.m_RecordIndex[pid] = self.m_RecordIndex[pid] + 1
		self.m_LastTime[pid] = g_TimeCtrl:GetTimeS()
	end
	
	table.insert(self.m_MsgData[pid], 1, oMsg)
	self.m_RecordIndex[pid] = self.m_RecordIndex[pid] + 1
	g_FriendCtrl:RefreshRecent(pid)
	self:OnEvent(define.Talk.Event.AddMsg, {pid=pid, amount=iAmount})
end

function CTalkCtrl.GetMsgID(self, pid)
	if not self.m_MessageID[pid] then
		self.m_MessageID[pid] = 0
	end
	self.m_MessageID[pid] = self.m_MessageID[pid] + 1
	return g_TimeCtrl:GetTimeS() * 100 + self.m_MessageID[pid]%100
end

function CTalkCtrl.GetRecentTalk(self)
	local list = g_FriendCtrl:GetRecentFriend()
	for k, pid in pairs(list) do
		if self.m_Notify[pid] and self.m_Notify[pid] > 0 then
			return pid
		end
	end
end

function CTalkCtrl.GetLastMsg(self, pid)
	local list = self.m_MsgData[pid]
	if list and #list > 0 then
		return list[1]
	end
end

function CTalkCtrl.SendChat(self, pid, msg)
	netfriend.C2GSChatTo(pid, msg, tostring(self:GetMsgID(pid)))
end

function CTalkCtrl.LoadMsgRecord(self, pid)
	local path = string.format("/role/%d/msgrecord/%d/", g_AttrCtrl.pid, pid)
	if not IOTools.IsExist(IOTools.GetPersistentDataPath(path)) then
		return
	end
	
	local pathList = IOTools.GetFiles(IOTools.GetPersistentDataPath(path), "*.txt", false)
	table.sort(pathList)
	local lastname = self.m_LastRecord[pid]
	local resultpath = nil
	
	if #pathList > 0 then
		if pathList[1] == lastname then
			return
		end
		if not lastname then
			resultpath = pathList[#pathList]
		end
	end
	
	for i = 2, #pathList do
		if pathList[i] == lastname then
			resultpath = pathList[i-1]
			break
		end
	end
	
	local recordList = nil
	if resultpath then
		recordList = IOTools.LoadJsonFile(resultpath, true)
	else
		return
	end
	
	if not recordList or type(recordList) ~= type({}) then
		recordList = {}
	end
	
	self.m_LastRecord[pid] = resultpath
	for k, oRecord in pairs(recordList) do
		table.insert(self.m_MsgData[pid], CTalkMsg.New(oRecord[1], oRecord[2]))
	end
	return true
end

function CTalkCtrl.SaveMsgRecord(self, pid)
	self:InitMsg(pid)
	local filename = self:GetSaveFile(pid)
	local recordList = IOTools.LoadJsonFile(filename, true)
	if not recordList or type(recordList) ~= type({}) then
		recordList = {}
	end
	
	local msgList = self.m_MsgData[pid]
	for i = self.m_RecordIndex[pid] , 1, -1 do
		table.insert(recordList, 1, {msgList[i]:GetID(), msgList[i]:GetText()})
	end

	IOTools.SaveJsonFile(filename, recordList, true)
	self.m_RecordIndex[pid] = 0
end

function CTalkCtrl.GetSaveFile(self, pid)
	local path = string.format("/role/%d/msgrecord/%d/", g_AttrCtrl.pid, pid)
	local filename = "1"
	if IOTools.IsExist(IOTools.GetPersistentDataPath(path)) then
		local pathList = IOTools.GetFiles(IOTools.GetPersistentDataPath(path), "*.txt", false)
		if #pathList > 0 then
			local path = pathList[#pathList]
			local oldData = IOTools.LoadJsonFile(path, true) or {}
			if #oldData > 100 then
				filename = tostring(tonumber(IOTools.GetFileName(path, true))+1)
			else
				filename = IOTools.GetFileName(path, true)
			end
		end
	end
	return IOTools.GetPersistentDataPath(string.format("%s%s.txt", path, filename))
end

return CTalkCtrl