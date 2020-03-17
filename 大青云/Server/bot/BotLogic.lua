Bot = {}
local metaBot = {__index = Bot}

function Bot:Init( o )
	o = o or {}
	o.currScene = 0
	o.quests = {} -- mainline task
	o.currLoc = {}
	o.chatTxt = "++++++++"
	o.reKillNum = 0
	o.questnum = 0
	o.userdata.teamId = "0_0"
	setmetatable(o, metaBot)
	return o
end

function Bot:delay( t )
	_delay(self.owner, t)
end

function Bot:rtrace( info )
	_rtrace(self.owner, info)
end

function Bot:goscene( id, px, py )
	_goscene(self.owner, id)
	if px and py then
		_directto(self.owner, px, py)
	end
end

function Bot:runto( px, py )
	return _runto(self.owner, px, py)
end

function Bot:skill( id, px, py, tar )
	px = px or 0
	py = py or 0
	tar = tar or 0
	_skill(self.owner, id, px, py, tar)
end

function Bot:chat( chanel, info )
	chanel = 1 
	_chat(self.owner, chanel, info)
end

function Bot:godungeon( id )
	_godungeon(self.owner, id)
end

function Bot:quit( delete )
	delete = delete and true
	_quit(self.owner, delete)
end

function Bot:goline( id )
	_goline(self.owner, id)
end

function Bot:sendrpc( msg, resp, ntime)
	local data = msg:encode()
	ntime = ntime or 10000
	_sendrpc(self.owner, data, msg.msgId, resp, ntime)
end

function Bot:getMapId()
	local ret = _mapid(self.owner)
	return ret
end

function Bot:getLocation()
	local x, y = _location(self.owner)
	self.currLoc = {x, y}
end

function Bot:getline()
	return _lineid(self.owner)
end

function Bot:randompack(minid, maxid, size, ranhead)
	minid = minid or 1000
	maxid = maxid or 6000
	size = size or 512
	ranhead = ranhead or false
	_randompack(self.owner, minid, maxid, size, ranhead)
end

function Bot:block(block, bb, mapid)
	mapid = mapid or self:getMapId()
	_block(mapid, block, bb)
end

function Bot:connect(cross, host)
	cross = cross or false

	if host ~= nil then
		local hosts = split(host, ':')
		_connect(self.owner, cross, hosts[1], hosts[2])
	else
		_connect(self.owner, cross)
	end

end

function Bot:loginaccount(acc)
	_account(self.owner, acc)
end

function Bot:id()
	return _id(self.owner)
end

function Bot:test_skill()

	local skills = {
		[1] = {
			1001001,
			1002001,
			1003001,
			1004001,
			1005001,
			1006001,
			1000101,
			7010001,
			9000001,
			7000101,
		},
		[2] = {
			2001001,
			2002001,
			2003001,
			2004001,
			2005001,
			2006001,
			1000101,
			7010001,
			9000001,
			7000101,
		},
		[3] = {
			3001001,
			3002001,
			3003001,
			3004001,
			3005001,
			3006001,
			1000101,
			7010001,
			9000001,
			7000101,
		},
		[4] = {
			4001001,
			4002001,
			4003001,
			4004001,
			4005001,
			4006001,
			1000101,
			7010001,
			9000001,
			7000101,
		}
		
	}
	Debug("self.prof ", self.prof)
	id = math.random(1, #(skills[self.prof]))
	Debug(skills[self.prof][id])
	self:skill( skills[self.prof][id] )
end

function Bot:goTo(pos, id)
	local posArrays
	local posArray
	local finishLink
	local targetSen 
	local targetX
	local targetY 
	posArrays = split(pos, '|')
	if posArrays then 
		pos = posArrays[1]
	end
	posArray = split(pos, ',')
	targetSen = tonumber(posArray[1])
	targetX = tonumber(posArray[2])
	targetY = tonumber(posArray[3])
	--Debug('pos Array ', targetSen, targetX, targetY)
	if targetSen ~= self.currScene then
		Debug('1 goscene', targetSen)
		--/telport/x/y/mapid
		local telportCmd = "/telport/" .. targetX .. '/' .. targetY .. '/' .. targetSen
		self:chat(2, telportCmd)
		Debug(telportCmd)
	else
		self:getLocation()
		local nowX = self.currLoc[1]
		local nowY = self.currLoc[2]
		
		Debug("1 runto: ", targetX, targetY, nowX, nowY, targetSen, id)
		ret = self:runto(targetX, targetY) 
		if ret == -1 then
			local telportCmd = "/telport/" .. targetX .. '/' .. targetY .. '/' .. targetSen
			self:chat(2, telportCmd)
			Debug(telportCmd)
		else
			Debug("2 runto: ", targetX, targetY, nowX, nowY, targetSen, id)
		end
	end
	
end

function Bot:activityInfo(actid)
	if self.userdata.actinfo == nil then
		local reqAct = ReqWorldBossMsg:new()
		self:sendrpc( reqAct, MsgType.WC_ActivityState )
		return nil
	end
	
	for k, v in pairs(self.userdata.actinfo) do
		if actid == k then
			return v
		end
	end
	
	return nil
end

function Bot:wuhun(active)
	if self.userdata.wuHuId ~= nil then
		local reqmsg = ReqAdjunctionWuHunMsg:new()
		reqmsg.wuhunId = self.userdata.wuHuId
		reqmsg.wuhunFlag = active
		self:sendrpc(reqmsg, 0)
	else
		self:chat(1, '/funcopen/4')
		self:delay(1000)
		local reqmsg = ReqAdjunctionWuHunMsg:new()
		reqmsg.wuhunId = self.userdata.wuHuId
		reqmsg.wuhunFlag = active
		self:sendrpc(reqmsg, 0)
	end
end

function Bot:outguildop(op)
	if self.userdata.guildId ~= '0_0' then return end

	local op = op or math.random(1, 2)

	if op == 1 then						--创建帮派
		self:chat(1, '/levelup/100')
		self:chat(1, '/createitem/140633039/10')
		self:delay( 2000 )

		local msg = ReqCreateGuild:new()
		msg.name = '帮派'..self.account
		msg.notice = '公告'..self.account
		self:sendrpc( msg, MsgType.WC_CreateGuildRet )
		Debug('create guid ', self.account)
	elseif op == 2 then					--加入帮派
		self:chat(1, '/levelup/100')
		self:delay( 2000 )

		local msgReqList = ReqGuildList:new()
		msgReqList.page = math.random(1,10)
		msgReqList.onlyAutoAgree = 1
		self:sendrpc( msgReqList, MsgType.WC_GuildList )

		local guildList = self.userdata.guildlist
		if guildList and guildList ~= {} then
			for k,guild in pairs(guildList) do
				local msgApply = ReqApplyGuild:new()
				msgApply.guildId = guild.guildId
				print(msgApply.guildId)
				msgApply.bApply = 1
				self:sendrpc( msgApply, MsgType.WC_ApplyGuild )
				Debug('join guid ', self.account, guild.guildId)
			end
		end
	end
end

function Bot:inguildop(op)
	if self.userdata.guildId == '0_0' then return end

	local op = op or math.random(1, 12)

	if op == 1 then						--退出帮派
		--local msg = ReqQuitGuild:new()
		--self:sendrpc(msg, 0)
		--Debug('exit guid ', self.account, self.userdata.guildId)
	elseif op == 2 then					--解散帮派
		--local msg = ReqDismissGuild:new()
		--self:sendrpc(msg, 0)
		--Debug('dismiss guid ', self.account, self.userdata.guildId)
	elseif op == 3 then					--升级帮派
		local msg = ReqLvUpGuild:new()
		self:sendrpc(msg, 0)
		Debug('lvup guid ', self.account, self.userdata.guildId)
	elseif op == 4 then					--改变职位
		self:reqguildmem()
		if self.userdata.guildmemlist ~= nil then
			for k, mem in pairs(self.userdata.guildmemlist) do
				local msg = ReqChangeGuildPos:new()
				msg.memGid = mem.id
				msg.pos = math.random(-10, 10)
				self:sendrpc(msg, 0)
				Debug('change pos ', self.account, self.userdata.guildId, msg.pos, msg.memGid)
			end
		end
	elseif op == 5 then					--改变帮派公告
		local msg = ReqChangeGuildNotice:new()
		msg.notice = 'hh'
		self:sendrpc(msg, 0)
		Debug('guild notice ', self.account, self.userdata.guildId, msg.notice)
	elseif op == 6 then					--审核申请
		self:reqguildapply()
		if self.userdata.guildapplys ~= nil then
			local msg = ReqVerifyGuildApply:new()
			msg.verify = math.random(1, 2) - 1
			for k, mem in pairs(self.userdata.guildapplys) do
				table.insert(msg.GuildApplyList, {memGid = mem.id})
			end
			self:sendrpc(msg, 0)
			Debug('verify guid ', self.account, self.userdata.guildId)
		end
	elseif op == 7 then					--踢出帮派成员
		--self:reqguildmem()
		if self.userdata.guildmemlist ~= nil then
			for k, mem in pairs(self.userdata.guildmemlist) do
				local msg = ReqKickGuildMem:new()
				msg.memGid = mem.id
				self:sendrpc(msg, 0)
				Debug('kick guid mem ', self.account, self.userdata.guildId, mem.id)
			end
		end
	elseif op == 8 then					--设置自动审核
		local msg = ReqSetAutoVerify:new()
		msg.bAuto = math.random(1, 2) - 1
		msg.level = math.random(-10, 10)
		self:sendrpc(msg, 0)
		Debug('set auto verify', self.account, self.userdata.guildId, msg.bAuto, msg.level)
	elseif op == 9 then					--禅让帮主
		self:reqguildmem()
		if self.userdata.guildmemlist ~= nil then
			for k, mem in pairs(self.userdata.guildmemlist) do
				local msg = ReqChangeLeader:new()
				msg.memGid = mem.id
				self:sendrpc(msg, 0)
				Debug('change leader', self.account, self.userdata.guildId, mem.id)
			end
		end
	elseif op == 10 then				--捐献
		self:chat(1, '/createitem/140620006/100')
		self:chat(1, '/createitem/140620007/100')
		self:chat(1, '/createitem/140620008/100')
		self:chat(1, '/createitem/11/2000000')
		self:chat(1, '/guildop/5/100')

		local ran_items = {140620006, 140620007, 140620008, 11}
		local msg = ReqGuildContribute:new()
		msg.itemId = ran_items[math.random(1, #ran_items)]
		if msg.itemId == 11 then
			msg.count = math.random(1000000, 2000000)
		else
			msg.count = math.random(1, 100)
		end
		
		self:sendrpc(msg, 0)

		Debug('guild contribute', self.account, self.userdata.guildId, msg.itemId, msg.count)
	end
end

function Bot:reqguildmem()
	if self.userdata.guildId == '0_0' then return end

	local msg = ReqMyGuildMems:new()
	self:sendrpc(msg, MsgType.WC_QueryMyGuildMems)
end

function Bot:reqguildapply()
	if self.userdata.guildId == '0_0' then return end

	local msg = ReqMyGuildApplys:new()
	self:sendrpc(msg, MsgType.WC_QueryMyGuildApplys)
end

function Bot:outteamop(op, id)
	if self.userdata.teamId ~= '0_0' then return end

	op = op or math.random(1, 3)
	id = id or "0_0"
	
	if op == 1 then
		local msgCreate = ReqTeamCreateMsg:new()
		msgCreate.targetRoleID = "0_0"
		self:sendrpc(msgCreate, 0)
		Debug('create team ' .. self.account)
	elseif op == 2 then
		self:runto(0, 0)
		local msgNearby = ReqTeamNearbyTeamMsg:new()
		self:sendrpc(msgNearby, MsgType.WC_TeamNearbyTeam)
		
		if self.userdata.nearby and self.userdata.nearby ~= {} then
			for k, team in pairs(self.userdata.nearby) do
				local msgApply = ReqTeamApplyMsg:new()
				msgApply.teamId = team.teamId
				self:sendrpc(msgApply, 0)
			end
		end
		Debug('req near by' .. self.account)
	elseif op == 3 then
		for k, v in pairs(self.userdata.invites) do
			local msgInvApprove = ReqTeamInviteApprove:new()
			msgInvApprove.teamId = v
			msgInvApprove.operate =  math.random(1, 2) - 1
			self:sendrpc(msgInvApprove, MsgType.WC_TeamInfo)
		end
	end
end

function Bot:inteamop(op)
	if self.userdata.teamId == '0_0' then return end

	op = op or math.random(1, 5)

	if op == 1 then
		if self.userdata.applys ~= {} then
			for k, v in pairs(self.userdata.applys) do
				local msgApprove = ReqTeamJoinApproveMsg:new()
				msgApprove.targetRoleID = v
				msgApprove.operate = math.random(1, 2) - 1
				self:sendrpc(msgApprove, 0)
			end
		end
		self.userdata.applys = {}
		Debug('join approve ' .. self.account)
	elseif op == 2 then
		local msgQuit = ReqTeamQuitMsg:new()
		self:sendrpc(msgQuit, MsgType.WC_TeamRoleExit)
		Debug('quit team ' .. self.account)
	elseif op == 3 then
		for k, v in pairs(self.userdata.teamMem) do
			local msgFire = ReqTeamFireMsg:new()
			msgFire.targetRoleID = v.roleID
			self:sendrpc(msgFire, MsgType.WC_TeamRoleExit)
		end
		Debug('fire mem ' .. self.account)
	elseif op == 4 then
		for k, v in pairs(self.userdata.teamMem) do
			if v.roleID ~= self.guid then
				local msgTransfer = ReqTeamTransferMsg:new()
				msgTransfer.targetRoleID = v.roleID
				self:sendrpc(msgTransfer, 0)
			end
		end
		Debug('transfer leader ' .. self.account)
	elseif op == 5 then
		local msgReqRole = ReqTeamNearbyRoleMsg:new()
		self:sendrpc(msgReqRole, MsgType.WC_TeamNearbyRole)
		
		if self.userdata.nearbyRole and self.userdata.nearbyRole ~= {} then
			for k, v in pairs(self.userdata.nearbyRole) do
				local msgInvite = ReqTeamInviteMsg:new()
				msgInvite.targetRoleID = v.roleID
				self:sendrpc(msgInvite, 0)
			end
		end
		Debug('invite ' .. self.account)
	end

end

function Bot:myprocess(msg)
	if msg.msgId == MsgType.SC_WuHunLingshouInfoResult then
		self.userdata.wuHuId = msg.wuhunId
	elseif msg.msgId == MsgType.WC_QueryMyGuildInfo then
		self.userdata.guildId = msg.guildId
		self.userdata.pos = msg.pos
	elseif msg.msgId == MsgType.WC_GuildList then
		self.userdata.guildlist = {}
		self.userdata.guildlist = msg.GuildList
	elseif msg.msgId == MsgType.WC_QueryMyGuildMems then
		self.userdata.guildmemlist = {}
		self.userdata.guildmemlist = msg.GuildMemList
	elseif msg.msgId == MsgType.WC_QueryMyGuildApplys then
		self.userdata.guildapplys = {}
		self.userdata.guildapplys = msg.GuildApplysList
	elseif msg.msgId == MsgType.WC_TeamInfo then
		bot.userdata.teamId = msg.teamId
		bot.userdata.teamMem = msg.roleList
	elseif msg.msgId == MsgType.WC_TeamNearbyTeam then
		bot.userdata.nearby = msg.teamList
	elseif msg.msgId == MsgType.WC_TeamJoinRequest then
		bot.userdata.applys[msg.roleID] = msg.roleID
	elseif msg.msgId == MsgType.WC_TeamInviteRequest then
		bot.userdata.invites[msg.teamId] = msg.teamId
	elseif msg.msgId == MsgType.WC_TeamNearbyRole then
		bot.userdata.nearbyRole = msg.roleList
	end
end

function Bot:process(msg)
	if msg.msgId == MsgType.SC_QueryQuestResult then
		Debug("questlist", Utils.dump(msg))
		self.quests = msg.quests
	elseif msg.msgId == MsgType.SC_QuestAdd then
		Debug("questadd", msg.id, Utils.dump(msg))
		local item = {}
		item.id = msg.id
		item.state = msg.state
		item.flag = msg.flag
		item.goals = msg.goals
		table.insert(self.quests, item)
	elseif msg.msgId == MsgType.SC_QuestDel then
		Debug("1 questDel ", msg.id, Utils.dump(self.quests))
		local toDel = 0
		for i, item in pairs(self.quests) do
			if item.id == msg.id then
				toDel = i
				break
			end
		end
		if toDel then 
			Debug("2 questDel ", msg.id)
			table.remove(self.quests, toDel)
		end
	elseif msg.msgId == MsgType.SC_QuestUpdate then
		Debug("questUpdate", msg.id, Utils.dump(self.quests))
		local result = 0
		for i, item in pairs(self.quests) do
			if item.id == msg.id then
				result = i
				break
			end
		end
		local item = {}
		item.id = msg.id
		item.state = msg.state
		item.flag = msg.flag
		item.goals = msg.goals
		self.quests[result] = item
		
	elseif msg.msgId == MsgType.SC_BackSetSystem then --系统设置

	elseif msg.msgId == MsgType.SC_OBJ_ATTR_INFO then
		if msg.roleId == self.guid then
			Debug("attr info ", msg.roleId, self.guid)
			local attrList = msg.attrData
			local info = self.info
			for k, v in pairs(attrList) do
				info[v.type] = v.value
			end
			--Debug(Utils.dump(info))
		end
	elseif msg.msgId == MsgType.SC_AcceptQuestResult then
		Debug("SC_AcceptQuestResult ", msg.result)
		
	end
	
end

function Bot:test()
	self:delay( 1000 )
	self.currScene = self:getMapId()
	self:getLocation()
	local req = ReqSetSystemInfoMsg:new();
	req.showInfo =  32768;
	self:sendrpc(req, 0)
	self:chat(1, '/addskill/1002001')
	self:chat(1, '/addskill/1003001')
	self:chat(1, '/addskill/1004001')
	self:chat(1, '/addskill/2002001')
	self:chat(1, '/addskill/2003001')
	self:chat(1, '/addskill/2004001')
	self:chat(1, '/addskill/3002001')
	self:chat(1, '/addskill/3003001')
	self:chat(1, '/addskill/3004001')
	self:chat(1, '/addskill/4002001')
	self:chat(1, '/addskill/4003001')
	self:chat(1, '/addskill/4004001')
	self:chat(1, '/levelup/80')
	while true do
	randnum = math.random(1, 10)
	if  randnum % 2 == 1 then
	self.currLoc[1] = self.currLoc[1] + randnum
	self.currLoc[2] = self.currLoc[2] - randnum
	end 
	if  randnum % 2 == 0 then
	self.currLoc[1] = self.currLoc[1] - randnum
	self.currLoc[2] = self.currLoc[2] + randnum
	end 
	self:runto(self.currLoc[1], self.currLoc[2])
	self:test_skill()
	randnum = math.random(1, 10)
			if  randnum % 2 == 1 then
			Debug("********************************************************************************************************")
			--self:chat(2, self.chatTxt)
			self:test_skill()
			self:chat(1, "小伙子,问问题之前先想一想你冲了多少钱!")
			end 
			if randnum % 2 == 0 then
			self:test_skill()
			self:chat(1, "小伙子,想一想不充钱你能变得更强吗？")
			end
			self:delay( 1000 )
			
	end


end

function Bot:script()
	self:delay( 1000 )
	self.currScene = self:getMapId()
	self:getLocation()
	Debug("--------------------------------------------------------------------")
	Debug('me: ', self.currScene, self.currLoc[1], self.currLoc[2], type(self.currScene))
	--self:delay( 1000 )
	Debug("--------------------------------------------------------------------")
	--设置自动加点
	local req = ReqSetSystemInfoMsg:new();
	req.showInfo =  32768;
	self:sendrpc(req, 0)
	
	--self:goscene(self.currScene, self.currLoc[1], self.currLoc[2])
	self:runto(self.currLoc[1], self.currLoc[2])	
	
	-- --增加法宝------------------------------------
	-- self:chat(1, '/addcallfabao/1')
	-- ----------------------------------------------
	local questnum = 0
	local randnum = 0
	while true do
		Debug(self.chatTxt)
    	self:chat(2, self.chatTxt)
		self.currScene = self:getMapId()
			questnum = questnum + 1
		local questLen = #(self.quests)
		local questItem
		local guideParam
		local pos
		local finishLink
		local questGoals
		Debug("questLen", questLen, self.currScene, self.currLoc[1], self.currLoc[2])
		if questLen > 0 then
			questItem = self.quests[1]
			Debug("Get one Quest ", Utils.dump(questItem), type(self.info[enAttrType.eaLevel]))
			
			questItemCfg = t_quest[questItem.id]
			if questItemCfg == nil then 
				questItemCfg = t_dailyquest[questItem.id]
			end
			if questItemCfg == nil then
				table.remove(self.quests, 1)
			else
				guideParam = questItemCfg.guideParam
				finishLink	= questItemCfg.finishLink
				questGoals =  questItemCfg.questGoals
				
				local minLevel = questItemCfg.minLevel
				local meLevel = self.info[enAttrType.eaLevel] 
				if minLevel > meLevel then
					local levelupCmd = "/levelup/" .. (minLevel - meLevel) 
					Debug(levelupCmd)
					self:chat(2, levelupCmd)
				end
				if questItemCfg.acceptNpc ~= 0 and questItem.state == 0 then
					local req = ReqAcceptQuestMsg:new();
					req.id =  questItem.id;
					waittime = math.random(500, 3000)
					self:delay( waittime )
					self:sendrpc(req, MsgType.SC_AcceptQuestResult)
					Debug("ReqAcceptQuestMsg ", req.id)
				end
				
				if questItemCfg.kind == 1 then 	--对话任务
					Debug("--对话任务", self.guid)
					local arr = split(finishLink, '#')
					local idx = arr[2]
					pos = t_position[tonumber(idx)].pos
					self:goTo(pos)
					waittime = math.random(500, 3000)
					self:delay( waittime )
					local finishCmd = "/finishquest/" .. questItem.id
					Debug(finishCmd)
					self:chat(2, finishCmd)
					--local req = ReqFinishQuestMsg:new()
					--req.id = questItem.id
					--self:sendrpc(req, MsgType.CS_FinishQuest)
					Debug('conversation finished ', questItem.id, self.guid)
							
				elseif questItemCfg.kind == 2 or questItemCfg.kind == 13 then  --杀怪任务
					Debug("杀怪任务 ", questItem.id, guideParam, self.guid)
					pos = t_position[tonumber(guideParam)].pos
					local tmp = split(pos, "|")
					pos = tmp[1]
					--self:delay(2000)
					self:goTo(pos)
					local fin = true
					local times = math.random(3, 5)
					for i = times,1,-1
					do
					waittime = math.random(500, 3000)
					self:delay( waittime )
					self:test_skill()
					self.reKillNum = self.reKillNum + 1
					end
					
					if questItem.state == 2 or self.reKillNum > 2 then
						self.reKillNum = 0
						local finishCmd = "/finishquest/" .. questItem.id
						Debug(finishCmd)
						self:chat(2, finishCmd)
					end
						
			
				elseif questItemCfg.kind == 4 then  --地面采集
					Debug("地面采集 ", guideParam, self.guid)
					pos = t_position[tonumber(guideParam)].pos
					self:goTo(pos, questItem.id)
					waittime = math.random(500, 3000)
					self:delay( waittime )
					local finishCmd = "/finishquest/" .. questItem.id
					self:chat(2, finishCmd)
					--local req = ReqFinishQuestMsg:new()
					--req.id = questItem.id
					--self:sendrpc(req, MsgType.CS_FinishQuest)
					Debug('Caiji finished ', questItem.id)
				
				
				elseif questItemCfg.kind == 6 then  --穿装备
					Debug("equip obj ")
					local finishCmd = "/finishquest/" .. questItem.id
					self:chat(2, finishCmd)
					--local req = ReqFinishQuestMsg:new()
					--req.id = questItem.id
					--self:sendrpc(req, MsgType.CS_FinishQuest)
					Debug('equip obj finished ', questItem.id)
				
				
				elseif questItemCfg.kind == 9 then  --达到坐标
					Debug("达到坐标 ", questItem.id, guideParam)
					pos = t_position[tonumber(guideParam)].pos
					
					if questItem.id == 1001202 then
						local targetSen 
						local targetX
						local targetY 
						local posArray = split(pos, ',')
						targetSen = tonumber(posArray[1])
						targetX = tonumber(posArray[2])
						targetY = tonumber(posArray[3])
						local telportCmd = "/telport/" .. targetX .. '/' .. targetY .. '/' .. targetSen
						waittime = math.random(500, 3000)
						self:delay(waittime)
						self:chat(2, telportCmd)
						Debug(telportCmd)
						local finishCmd = "/finishquest/" .. questItem.id
						self:chat(2, finishCmd)
						Debug(finishCmd)
						
					else
						self:goTo(pos)
					end		
				elseif questItemCfg.kind == 10 then --特殊打怪副本
					Debug("dragon: ")
					--引导副本特殊处理
					if questItem.id == 1001001 then
						Debug("Babe Entry point : ", questItemCfg.fubenMap)
						local mapid = questItemCfg.fubenMap
						local telportCmd = "/telport/" .. 0 .. '/' .. 0 .. '/' .. mapid
						waittime = math.random(500, 3000)
						self:delay( waittime )
						self:chat(2, telportCmd)
						Debug(telportCmd)
						
					else
						pos = t_position[tonumber(guideParam)].pos
						self:goTo(pos)
						
					end
					
					local finishCmd = "/finishquest/" .. questItem.id
					self:chat(2, finishCmd)
					Debug(finishCmd)
					
				elseif questItemCfg.kind == 11 then --传送任务
					Debug("传送任务")
					pos = t_position[tonumber(guideParam)].pos
					self:goTo(pos)
					waittime = math.random(500, 3000)
					self:delay( waittime )
					--local req = ReqFinishQuestMsg:new()
					--req.cID = questItem.id
					--self:sendrpc(req, MsgType.CS_TriggerObject)
					local finishCmd = "/finishquest/" .. questItem.id
					self:chat(2, finishCmd)
					
					local arr = split(questGoals, ",")
					local portalId = arr[2]
					local portalVo = t_portal[tonumber(portalId)]
					local targetMap = portalVo.targetMap
					local targetPos = portalVo.target_pos
					--/telport/x/y/mapid
					local telportCmd = "/telport/" .. targetPos[1] .. '/' .. targetPos[2] .. '/' .. targetMap
					self:chat(2, telportCmd)
							
				elseif questItemCfg.kind == 12 then --引导任务
					Debug("引导任务")
					local arr = split(questGoals, ",")
					local funcId = arr[1]
					local count =  arr[2]
					waittime = math.random(500, 2000)
					self:delay( waittime )
					local req = ReqQuestClickMsg:new();
					req.id =  questItem.id;
					for i=1, tonumber(count), 1 do
						self:sendrpc(req, 0)
						Debug('click once ', funcId)
					end
					if questItem.state == 2 then
						local finishCmd = "/finishquest/" .. questItem.id
						Debug(finishCmd)
						waittime = math.random(500, 2000)
						self:delay( waittime )
						self:chat(2, finishCmd)
					end
					
				end
			end
			
		else
			
			self:quit()	
		
		end
    end
	
    
end


