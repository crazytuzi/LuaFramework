local CFriendCtrl = class("CFrienCtrl", CCtrlBase)

function CFriendCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_Version = 1
	--本次缓存好友信息时间间隔
	self.m_UpdateTime = 300
	self:ResetCtrl()
end

function CFriendCtrl.ResetCtrl(self)
	self.m_FriendDict = {}
	self.m_Friend = {all = {}, teamer = {}, recent = {}, black = {}}
	self.m_Online = {}
	self.m_ApplyList = {}
	self.m_ApplyInfo = {}
	self.m_Settting = {}
	if self.m_FriendTimer then
		Utils.DelTimer(self.m_FriendTimer)
		self.m_FriendTimer = nil
	end
end

function CFriendCtrl.IsOpen(self)
	return g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.friend.open_grade
end

function CFriendCtrl.InitFriend(self, pidlist)
	self.m_Friend = {all = {}, teamer = {}, recent = {}, black = {}}
	local queryList = {}
	local querySimpleList = {}
	self:LoadFriendList()
	self:LoadRecentList()
	self.m_Friend["all"] = {}
	local iCurTime = g_TimeCtrl:GetTimeS()
	for k, obj in ipairs(pidlist) do
		local pid = obj.pid
		table.insert(self.m_Friend["all"], pid)
		if not self.m_FriendDict[pid] then
			table.insert(queryList, pid)
		else
			local iTime = self.m_FriendDict[pid]["update_time"] or 0
			if iCurTime - iTime >= self.m_UpdateTime then
				table.insert(querySimpleList, pid)
			end
		end
	end
	
	local broadList = {}
	--查询最近联系人的玩家数据
	for k,v in ipairs(self.m_Friend["recent"]) do
		local pid = tonumber(v)
		table.insert(broadList, pid)
		if not self.m_FriendDict[pid] then
			table.insert(queryList, pid)
		end
	end

	if #queryList > 0 then
		netfriend.C2GSQueryFriendProfile(queryList)
	end
	if #broadList > 0 then
		netfriend.C2GSBroadcastList(broadList)
	end
	if #querySimpleList > 0 then
		netfriend.C2GSSimpleFriendList(querySimpleList)
	end
	if not self.m_FriendTimer then
		self.m_FriendTimer = Utils.AddTimer(callback(self, "TrySaveFriendList"), self.m_UpdateTime, self.m_UpdateTime)
	end
end

--设置pid对应的online状态的列表
function CFriendCtrl.InitOnlineState(self, onlinelist)
	self.m_Online = {}
	for _, onlineinfo in pairs(onlinelist) do
		self.m_Online[onlineinfo.pid] = onlineinfo.onlinestatus
	end
end

--设置黑名单black的list
function CFriendCtrl.InitBlackList(self, pidlist)
	local queryList = {}
	for k, pid in pairs(pidlist) do
		table.insert(self.m_Friend["black"], pid)
		if not self.m_FriendDict[pid] then
			table.insert(queryList, pid)
		end
	end
	if #queryList > 0 then
		netfriend.C2GSQueryFriendProfile(queryList)
	end
end

function CFriendCtrl.AddFriendList(self, friendlist)
	local updateList = {}
	local addList = {}
	local iTime = g_TimeCtrl:GetTimeS()
	for k, frdobj in pairs(friendlist) do
		if self.m_FriendDict[frdobj.pid] then
			table.update(self.m_FriendDict[frdobj.pid], frdobj)
		else
			frdobj = self:CreateObj(frdobj)
			self.m_FriendDict[frdobj.pid] = frdobj
		end
		self.m_FriendDict[frdobj.pid]["update_time"] = iTime
		table.insert(updateList, frdobj.pid)
		if not self:IsMyFriend(frdobj.pid) then
			table.insert(self.m_Friend["all"], frdobj.pid)
			table.insert(addList, frdobj.pid)
		end
	end
	if #addList > 0 then
		self:OnEvent(define.Friend.Event.Add, addList)
	end
	self:OnEvent(define.Friend.Event.Update, updateList)
	self:SaveFriendList()
end

function CFriendCtrl.UpdateFriendInfo(self, pid, key, value)
	local frdobj = self.m_FriendDict[pid]
	if frdobj then
		frdobj[key] = value
		frdobj["update_time"] = g_TimeCtrl:GetTimeS()
		self.m_SaveFlag = true
		self:OnEvent(define.Friend.Event.Update, {pid})
	end
end

function CFriendCtrl.UpdateSimpleInfo(self, dFriendList)
	local dUpdateList = {}
	local iTime = g_TimeCtrl:GetTimeS()
	for _, dInfo in ipairs(dFriendList) do
		local frdobj = self.m_FriendDict[dInfo.pid]
		if frdobj then
			frdobj["name"] = dInfo.name
			frdobj["grade"] = dInfo.grade
			frdobj["update_time"] = iTime
			table.insert(dUpdateList, dInfo.pid)
		end
	end
	if #dUpdateList > 0 then
		self:OnEvent(define.Friend.Event.Update, dUpdateList)
	end
end

function CFriendCtrl.CreateObj(self, frdobj)
	local frdlist = {
		grade = 0,
		shape = 1110,
		school = 1, 
		school_branch = 1, 
		orgid = 0, 
		friend_degree = 0,
		relation = 0,
		update_time = 0,
	}
	return table.update(frdlist, frdobj)	
end

function CFriendCtrl.AddStranger(self, friendlist)
	local pidList = {}
	for k, frdobj in pairs(friendlist) do
		table.insert(pidList, frdobj.pid)
		frdobj = self:CreateObj(frdobj)
		self.m_FriendDict[frdobj.pid] = frdobj
	end
	self:OnEvent(define.Friend.Event.Update, pidList)
end

function CFriendCtrl.DelFriendList(self, pidlist)
	for k, pid in pairs(pidlist) do
		local index = table.index(self.m_Friend["all"], pid)
		if index then
			table.remove(self.m_Friend["all"], index)
		end
	end
	self:OnEvent(define.Friend.Event.Del, pidlist)
end

function CFriendCtrl.AddBlackFriend(self, pidlist)
	local queryList = {}
	for k, pid in pairs(pidlist) do
		if not table.index(self.m_Friend["black"], pid) then
			table.insert(self.m_Friend["black"], pid)
		end
		if not self.m_FriendDict[pid] then
			table.insert(queryList, pid)
		end
	end
	if #queryList > 0 then
		netfriend.C2GSQueryFriendProfile(queryList)
	end
	self:OnEvent(define.Friend.Event.AddBlack, pidlist)
end

function CFriendCtrl.DelBlackFriend(self, pidlist)
	for k, pid in pairs(pidlist) do
		local index = table.index(self.m_Friend["black"], pid)
		if index then
			table.remove(self.m_Friend["black"], index)
		end
	end
	self:OnEvent(define.Friend.Event.DelBlack, pidlist)
end

function CFriendCtrl.GetFriend(self, pid)
	return self.m_FriendDict[pid]
end

function CFriendCtrl.IsMyFriend(self, pid)
	return table.index(self.m_Friend["all"], pid)
end

function CFriendCtrl.QueryFriend(self, pidlist)
	netfriend.C2GSQueryFriendProfile(pidlist)
end

function CFriendCtrl.GetMyFriend(self)

	return self.m_Friend["all"]
end

function CFriendCtrl.Sort(a, b)
	local frdobjA = g_FriendCtrl:GetFriend(a)
	local frdobjB = g_FriendCtrl:GetFriend(b)
	local onlineA = g_FriendCtrl:GetOnlineState(a)
	local onlineB = g_FriendCtrl:GetOnlineState(b)
	if onlineA ~= onlineB then
		if onlineA then 
			return true
		else
			return false
		end
	end
	local sortkeyList = {
		{"friend_degree", true},
		{"pid", false},
	}
	for _, v in ipairs(sortkeyList) do
		local key = v[1]
		local upsort = v[2]
		if frdobjA[key] ~= frdobjB[key] then
			if not frdobjA[key] then
				return false
			elseif not frdobjB[key] then
				return true
			end
			if frdobjA[key] > frdobjB[key] == upsort then
				return true
			else
				return false
			end
		end
	end
end

function CFriendCtrl.GetRecentFriend(self)
	return self.m_Friend["recent"]
end

function CFriendCtrl.GetTeamerFriend(self)
	return self.m_Friend["teamer"]
end

function CFriendCtrl.GetBlackList(self)
	return self.m_Friend["black"]
end

function CFriendCtrl.IsBlackFriend(self, pid)
	return table.index(self.m_Friend["black"], pid)
end

function CFriendCtrl.IsRecentFriend(self, pid)
	return table.index(self.m_Friend["recent"], pid)
end

function CFriendCtrl.RefreshRecent(self, pid)
	local iAmount = 30
	local t = self.m_Friend["recent"]
	local i = table.index(t, pid)
	if i then
		t[i] = t[1]
		t[1] = pid
	else
		if #t >= iAmount then
			table.remove(t, #t)
		end
		table.insert(t, 1, pid)
	end
	
	if not self:GetFriend(pid) then
		netfriend.C2GSQueryFriendProfile({pid})
	end
	self:OnEvent(define.Friend.Event.AddRecent, pid)
	self:SaveRecentList()
end

function CFriendCtrl.SetOnlineState(self, onlineList)
	local pidList = {}
	for _, v in ipairs(onlineList) do
		self.m_Online[v.pid] = v.onlinestatus
		table.insert(pidList, v.pid)
	end
	self:OnEvent(define.Friend.Event.Update, pidList)
end

function CFriendCtrl.GetOnlineState(self, pid)
	if self.m_Online[pid] then
		return self.m_Online[pid] == 1
	else
		return true
	end
end

function CFriendCtrl.GetFriendDegree(self, pid)
	local frdobj = g_FriendCtrl:GetFriend(pid)
	if frdobj then
		return frdobj["friend_degree"] or 0
	end
	return 0
end

function CFriendCtrl.UpdateTeamerFriend(self)
	local iAmount = 15
	local list = g_TeamCtrl:GetMemberList()
	local teamlist = self.m_Friend["teamer"]
	for k, teamobj in pairs(list) do
		local pid = teamobj.pid
		if teamobj and pid ~= g_AttrCtrl.pid then
			local i = table.index(teamlist, pid)
			if i then
				teamlist[i] = teamlist[1]
				teamlist[1] = pid
			else
				if #teamlist >= iAmount then
					table.remove(teamlist, #teamlist)
				end
				table.insert(teamlist, 1, pid)
			end
			self.m_FriendDict[pid] = self:CreateTeamerFriend(teamobj)
		end	
	end
	
	self:OnEvent(define.Friend.Event.Update, list)
	self:OnEvent(define.Friend.Event.UpdateTeamer)
end

function CFriendCtrl.CreateTeamerFriend(self, info)
	local pid = info.pid
	local dict = {
		pid = info.pid,
		name = info.name,
		shape = info.model_info.shape,
		grade = info.grade,
		school = info.school,
		school_branch = info.school_branch,
		orgid = 0, 
		friend_degree = 0,
		relation = 0,
		update_time = 0,
	}
	local frdobj = self.m_FriendDict[pid]
	if frdobj and self:IsMyFriend(pid) then
		table.update(frdobj, dict)
	else
		frdobj = dict
	end
	return frdobj
end


function CFriendCtrl.SetRecommendFriends(self, recommendfrdlist)
	local t = {}
	for i = 1, 48 do
		table.insert(t, {name=string.format("名字%d", 1000+i), pid=1000+i})
	end
	recommendfrdlist = t
	self.m_RecommendFrdList = recommendfrdlist
end

function CFriendCtrl.GetRecommendFriends(self)
	local newfrdList = {}
	for k, frdobj in pairs(self.m_RecommendFrdList) do
		if table.index(self.m_Friend["all"], frdobj.pid) then
			--continue
		elseif self.m_LastRecommend and table.index(self.m_LastRecommend, frdobj.pid) then			
			--continue
		else
			table.insert(newfrdList, frdobj)
		end
	end
	
	self.m_LastRecommend = {}
	table.shuffle(newfrdList)
	newfrdList =table.slice(newfrdList, 1, 8)
	for k, frdobj in pairs(newfrdList) do
		table.insert(self.m_LastRecommend, frdobj.pid)
	end

	return newfrdList
end

function CFriendCtrl.GetApplyAmount(self)
	return #self.m_ApplyList
end

function CFriendCtrl.GetApplyList(self)
	return self.m_ApplyList
end

function CFriendCtrl.GetApplyInfo(self, pid)
	return self.m_ApplyInfo[pid]	
end

function CFriendCtrl.UpdateApplyList(self, applylist)
	self.m_ApplyList = {}
	local queryList = {}
	for _, pid in ipairs(applylist) do
		if not self:IsBlackFriend(pid) then
			table.insert(self.m_ApplyList, pid)
			if not self.m_ApplyInfo[pid] then
				table.insert(queryList, pid)
			end
		end
	end
	if #queryList > 0 then
		netfriend.C2GSQueryFriendApply(queryList)
	end
	self:OnEvent(define.Friend.Event.UpdateApply, applylist)
end

function CFriendCtrl.UpdateApplyInfo(self, profile_list)
	for _, applyunit in ipairs(profile_list) do
		local proinfo = g_NetCtrl:DecodeMaskData(applyunit.pro, "friend")
		proinfo.labal = applyunit.labal
		proinfo.addr = applyunit.addr
		self.m_ApplyInfo[proinfo.pid] = proinfo
	end
	self:OnEvent(define.Friend.Event.UpdateApply, self.m_ApplyList)
end

function CFriendCtrl.UpdateFriendSeting(self, setting)
	self.m_Settting = setting
end

function CFriendCtrl.GetFriendSetting(self)
	return self.m_Settting
end

function CFriendCtrl.ShowSearchResult(self, list)
	self:OnEvent(define.Friend.Event.UpdateSearch, list)
end

function CFriendCtrl.ShowRecommandResult(self, list)
	self:OnEvent(define.Friend.Event.UpdateRecommand, list)
end

-----------------------下边的函数是好友ui相关--------------------------------

function CFriendCtrl.ShowBlackTip(self, pid)
	local sMsg = nil
	if self:IsMyFriend(pid) then
		local frdobj = self:GetFriend(pid)
		sMsg = frdobj["name"].."是你的好友，确定要将他加入到黑名单吗？将好友加入到黑名单后好友关系将被删除"
	else
		sMsg = "确定要将他加入到黑名单吗？"
	end
	
	local windowConfirmInfo = {
		msg = sMsg,
		title = "拉黑",
		okCallback = function () netfriend.C2GSFriendShield(pid) end,	
		okStr = "确定",
		cancelStr = "取消",
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CFriendCtrl.ApplyDelBlackFriend(self, pid)
	local windowConfirmInfo = {
		msg = "确定要解除黑名单",
		title = "解除黑名单",
		okCallback = function () netfriend.C2GSFriendUnshield(pid) end,	
		okStr = "确定",
		cancelStr = "取消",
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CFriendCtrl.ApplyDelFriend(self, pid)
	local frdobj = self.m_FriendDict[pid]
	local sMsg = "你确定要将此好友删除？#n"
	local windowConfirmInfo = {
		msg = sMsg,
		title = "删除好友",
		okCallback = function () 
			netfriend.C2GSDeleteFriend(pid)
		end,	
		okStr = "确定",
		cancelStr = "取消",
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CFriendCtrl.ApplyFriend(self, pid)
	local t = g_TimeCtrl:GetTimeS()
	if self.m_ApplyTime and t - self.m_ApplyTime < 1 then
		g_NotifyCtrl:FloatMsg("你的操作过于频繁")
		return false
	else
		netfriend.C2GSApplyAddFriend(pid)
		self.m_ApplyTime = t
		return true
	end
end

--------------------下边的函数是保存all、black、recent数据到本地--------------------------------

--保存all、black、recent数据到本地
function CFriendCtrl.SaveFriendList(self)
	local frdDict = {}
	local file = IOTools.GetPersistentDataPath(string.format("/role/%d/friends", g_AttrCtrl.pid))
	for pid, frdobj in pairs(self.m_FriendDict) do
		if self:IsMyFriend(pid) or self:IsBlackFriend(pid) or self:IsRecentFriend(pid) then
			frdDict[tostring(pid)] = frdobj
		end
	end
	frdDict["version"] = 1
	IOTools.SaveJsonFile(file, frdDict, true)
end

--保存all、black、recent数据到本地
function CFriendCtrl.TrySaveFriendList(self)
	if not self.m_SaveFlag then
		return
	end
	local frdDict = {}
	self:SaveFriendList()
	self.m_SaveFlag = false
end

function CFriendCtrl.LoadFriendList(self)
	local file = IOTools.GetPersistentDataPath(string.format("/role/%d/friends", g_AttrCtrl.pid))
	local frdDict = IOTools.LoadJsonFile(file, true)
	if not frdDict or type(frdDict) ~= type({}) then
		frdDict = {}
	end

	if frdDict["version"] and frdDict["version"] ~= self.m_Version then
		self:ClearFriendList()
		return
	else
		printc("好友版本一致，无需更新")
	end

	for pid, data in pairs(frdDict) do
		if tonumber(pid) then
			self.m_FriendDict[tonumber(pid)] = data
		end
	end
end

--删除本地all、black、recent数据
function CFriendCtrl.ClearFriendList(self)
	local path = IOTools.GetPersistentDataPath(string.format("/role/%d/friends", g_AttrCtrl.pid))
	IOTools.Delete(path)
end

--保存最近联系人数据到本地
function CFriendCtrl.SaveRecentList(self)
	-- if not self.m_SaveRecentTime then
	-- 	self.m_SaveRecentTime = 0
	-- end
	-- local iTime = g_TimeCtrl:GetTimeS()
	-- if iTime - self.m_SaveRecentTime > 60 then
		
	-- 	self.m_SaveRecentTime = iTime
	-- end
	local file = IOTools.GetPersistentDataPath(string.format("/role/%d/recent", g_AttrCtrl.pid))	
	IOTools.SaveJsonFile(file, self:GetRecentFriend(), true)
end

function CFriendCtrl.LoadRecentList(self)
	local iAmount = 30
	self.m_Friend["recent"] = {}
	local file = IOTools.GetPersistentDataPath(string.format("/role/%d/recent", g_AttrCtrl.pid))
	local recentList = IOTools.LoadJsonFile(file, true)
	if not recentList or type(recentList) ~= type({}) then
		recentList = {}
	end
	for k, pid in ipairs(recentList) do
		if k > iAmount then
			break
		end
		table.insert(self.m_Friend["recent"], tonumber(pid))
	end
end

function CFriendCtrl.GetRelationString(self, relation)
	relation = relation or 0
	local lRelationData = {
		[1] = {sortID = 1, name = "小两口"},
		[2] = {sortID = 8, name = "同盟"},
		[3] = {sortID = 5, name = "师徒"},
		[4] = {sortID = 4, name = "同伴"},
		[5] = {sortID = 3, name = "基友"},
		[6] = {sortID = 7, name = "公会成员"},
		[7] = {sortID = 9, name = "路人"},
		[8] = {sortID = 6, name = "学生"},
		[9] = {sortID = 2, name = "恋人"},
	}
	local lRelation = {}
	for i,v in ipairs(lRelationData) do
		if MathBit.andOp(relation, 2 ^ (i - 1)) ~= 0 then
			table.insert(lRelation, v)
		end
	end
	if #lRelation > 0 then
		local function sortFunc(v1, v2)
			return v1.sortID < v2.sortID
		end
		table.sort(lRelation, sortFunc)
		return lRelation[1].name
	else
		return "路人"
	end
end


return CFriendCtrl