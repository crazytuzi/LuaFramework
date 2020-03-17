CurrentSceneScript = {}
CurrentSceneScript.RecordScore = {}
CurrentSceneScript.RecordKill = {}
CurrentSceneScript.RecordHumanScore = {}
CurrentSceneScript.Monster = {}
CurrentSceneScript.ModScript = nil
CurrentSceneScript.RankNum = 10
CurrentSceneScript.Close = false
CurrentSceneScript.HumanIdx = 1
CurrentSceneScript.HumanInfos = {}
CurrentSceneScript.CurTreasureRound = 0

CurrentSceneScript.Totems = {
	id = 10000018,
	occupyScore = 3,
	pos = UnionWarConfig.Totems,
	owner = 0,
	ownerName = "",
	tid = -1,
}
CurrentSceneScript.Statue = {
	id = 10000019,
	hitScore = 5,
	pos = UnionWarConfig.Statue
}
CurrentSceneScript.Throne = {
	id = 10000020,
	hitScore = 3,
	pos = UnionWarConfig.Throne
}

CurrentSceneScript.BuffItems = {								--BUFF位置
	[707] = {x = -255, y = -270, z = 0, dir = 0, buffid = 1013018},
	[708] = {x = 250, y = -284, z = 0, dir = 0, buffid = 1013019},
	[709] = {x = 269, y = 275, z = 0, dir = 0, buffid = 1013020},
	[710] = {x = -226, y = 261, z = 0, dir = 0, buffid = 1013021},
	[711] = {x = 9, y = 66, z = 0, dir = 0, buffid = 1013022},
}
CurrentSceneScript.TreasureId = 706								--宝箱ID
CurrentSceneScript.TreasureNum = 5							--宝箱数量
CurrentSceneScript.TreasureInteral = 10*60						--宝箱刷新间隔
CurrentSceneScript.TreasureScore = 30							--宝箱增加积分
CurrentSceneScript.TreasureTotalRound = 3 						--宝箱总次数
CurrentSceneScript.TreasurePos = {								--宝箱位置
	{x=-230,y=420,z=0,dir=0},
	{x=255,y=-421,z=0,dir=0},
	{x=410,y=245,z=0,dir=0},
	{x=409,y=-252,z=0,dir=0},
	{x=234,y=-446,z=0,dir=0},
	{x=-233,y=-428,z=0,dir=0},
	{x=-390,y=-267,z=0,dir=0},
	{x=-389,y=276,z=0,dir=0},
	{x=-294,y=630,z=0,dir=0},
	{x=346,y=623,z=0,dir=0},
	{x=621,y=622,z=0,dir=0},
	{x=531,y=617,z=0,dir=0},

}


function CurrentSceneScript:UpdateScore(curgid, curgname, score)
	local record = self:GetScore(curgid)
	record.val = record.val + score
end

function CurrentSceneScript:UpdateScoreHuman(human, score)
	local curgid = human:GetModGuild():GetGuildID()
	local curgname = human:GetModGuild():GetGuildName()
	local uid = human:GetID()

	local record = self:GetScore(curgid)
	record.val = record.val + score

	local recordHuman = self:GetHumanScore(uid)
	recordHuman.val = recordHuman.val + score
end

function CurrentSceneScript:UpdateKill(human)
	local curgid = human:GetModGuild():GetGuildID()
	local curgname = human:GetModGuild():GetGuildName()
	
	local record = self:GetKill(curgid)
	record.val	= record.val + 1

	self:UpdateScoreHuman(human, 1)
end

function CurrentSceneScript:RankScore()
	table.sort(self.RecordScore, function(a, b)
		if a.val ~= b.val then
			return a.val > b.val
		else
			return a.idx < b.idx
		end
	end)
	for i,v in pairs(self.RecordScore) do
		v.rank = i
	end
	
	self.ModScript:BcGuildWarRank(self:GetGuildWarScoreRank(), 1, 0)
end

function CurrentSceneScript:RankKill()
	table.sort(self.RecordKill, function(a, b)
		if a.val ~= b.val then
			return a.val > b.val
		else
			return a.idx < b.idx
		end
	end)
	for i,v in pairs(self.RecordKill) do
		v.rank = i
	end
	
	self.ModScript:BcGuildWarRank(self:GetGuildWarKillRank(), 2, 0)
end

function CurrentSceneScript:RankHumanScore()
	table.sort(self.RecordHumanScore, function(a, b)
		if a.val ~= b.val then
			return a.val > b.val
		else
			return a.idx < b.idx
		end
	end)

	local rankInfo = self:GetHumanScoreRank()
	for i,v in pairs(self.RecordHumanScore) do
		v.rank = i
		local infos = self.HumanInfos[v.gid]
		if infos ~= nil and infos[3] ~= nil then
			self.ModScript:SendGuildWarScore(rankInfo, v.rank, v.val, infos[3])
		end
	end
end

function CurrentSceneScript:RankAll()
	self:RankScore()
	self:RankKill()
	self:RankHumanScore()
end

function CurrentSceneScript:GetScore(curgid)
	for i,v in pairs(self.RecordScore) do
		if v and v.gid == curgid then
			return v
		end
	end
	
	return nil
end

function CurrentSceneScript:GetKill(curgid)
	for i,v in pairs(self.RecordKill) do
		if v and v.gid == curgid then
			return v
		end
	end
	
	return nil
end

function CurrentSceneScript:GetHumanScore(uid)
	for i,v in pairs(self.RecordHumanScore) do
		if v and v.gid == uid then
			return v
		end
	end
	
	return nil
end

function CurrentSceneScript:GetMyGuildWarStatus(curgid, uid)
	local recordScore = self:GetScore(curgid)
	local recordKill = self:GetKill(curgid)
	local recordSelfScore = self:GetHumanScore(uid)
	local retInfo = {}
	retInfo.gid		= curgid
	retInfo.rank	= recordScore.rank
	retInfo.score	= recordScore.val
	retInfo.kill	= recordKill.val 
	retInfo.selfran	= recordSelfScore.rank
	
	return retInfo
end

function CurrentSceneScript:GetGuildWarStatus()
	local retInfo = {}
	retInfo.gname	= self.Totems.ownerName
	retInfo.status	= {}
	for i = 1, #self.Monster do
		if self.Monster[i].id == 0 then
			table.insert(retInfo.status, 0)
		else
			table.insert(retInfo.status, 1)
		end
	end
	return retInfo
end

function CurrentSceneScript:GetGuildWarScoreRank()
	return self.RecordScore
end

function CurrentSceneScript:GetGuildWarKillRank()
	local retInfo = {}
	
	for i,v in pairs(self.RecordKill) do
		if i > self.RankNum then break end
		table.insert(retInfo, v)
	end
	return retInfo
end

function CurrentSceneScript:GetHumanScoreRank(uid)
	local retInfo = {}
	
	for i,v in pairs(self.RecordHumanScore) do
		if i > self.RankNum then break end
		table.insert(retInfo, v)
	end
	return retInfo
end

function CurrentSceneScript:SendNotice(id, param)
	param = param or ""
	_SendNotice(id, param, self.Scene:GetGameMapID())
end

function CurrentSceneScript:Startup()
	_RegSceneEventHandler(SceneEvents.SceneCreated, "OnSceneCreated")
	_RegSceneEventHandler(SceneEvents.SceneDestroy, "OnSceneDestroy")
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld, "OnHumanEnter")
	_RegSceneEventHandler(SceneEvents.HumanLeaveWorld, "OnHumanLeave");
	_RegSceneEventHandler(SceneEvents.HumanKilled, "OnHumanKilled")
	_RegSceneEventHandler(SceneEvents.MonsterKilled, "OnMonsterKilled")
	_RegSceneEventHandler(SceneEvents.GuildActivityClose, "OnGuildWarClosed")
	_RegSceneEventHandler(SceneEvents.MonsterEnterWorld, "OnMonsterEnter")
	_RegSceneEventHandler(SceneEvents.MonsterHited, "OnMonsterStatueHited", {param1 = self.Statue.id})
	_RegSceneEventHandler(SceneEvents.MonsterHited, "OnMonsterThroneHited", {param1 = self.Throne.id})
	_RegSceneEventHandler(SceneEvents.GuildActivityGather, "OnHumanGater")
end

function CurrentSceneScript:OnMonsterEnter(monster)
	local idx = monster:GetSpawnParam();
	self.Monster[idx].id = monster:GetID();
	
	local owner = self.Monster[idx].owner
	if owner ~= nil and owner ~= 0 and idx == 1 then
		monster:SetBelong(MonsterBelongType.Belong_Guild, owner, true)
	end
	
	self.ModScript:BcGuildWarStatus(self:GetGuildWarStatus(), 0)
	if idx ~= 1 then
		self:SendNotice(10211, "8," .. tostring(monster:GetMonId()))
	end
end

function CurrentSceneScript:OnSceneCreated(scene)
	self.ModScript = self.Scene:GetModScript()
	
	for i,v in pairs(self.Totems.pos) do
		table.insert(self.Monster, {owner = 0})
		self.Scene:GetModSpawn():SpawnExt(self.Totems.id, v.x, v.y, v.dir or 0, #self.Monster)
	end
	
	for i,v in pairs(self.Statue.pos) do
		table.insert(self.Monster, {owner = 0})
		self.Scene:GetModSpawn():SpawnExt(self.Statue.id, v.x, v.y, v.dir or 0, #self.Monster)
	end
	
	for i,v in pairs(self.Throne.pos) do
		table.insert(self.Monster, {owner = 0})
		self.Scene:GetModSpawn():SpawnExt(self.Throne.id, v.x, v.y, v.dir or 0, #self.Monster)
	end

	local tid = self.ModScript:CreatePeriodTimer(1, 1, "OnSecondsTimer");

	for i,v in pairs(self.BuffItems) do
		self.Scene:GetModSpawn():SpawnCollection(i, v.x, v.y, v.z, v.dir or 0)
	end

	self.ModScript:CreatePeriodTimer(self.TreasureInteral, self.TreasureInteral, "RefreshTreasure")

	self:RefreshTreasure(0)
end

function CurrentSceneScript:OnSceneDestroy()
	self.RecordScore = nil
	self.RecordKill = nil
	self.RecordHumanScore = nil
	self.Monster = nil
	self.Totems = nil
	self.Statue = nil
	self.Throne = nil
	self.ModScript = nil
	self.HumanInfos = nil
	self.BuffItems = nil
	self.TreasurePos = nil
end

function CurrentSceneScript:Cleanup() 
	
end


function CurrentSceneScript:OnSecondsTimer(tid)
	if self.Close then return end

	self:RankAll()
end

function CurrentSceneScript:RefreshTreasure(tid)
	if self.Close then return end

	self.CurTreasureRound = self.CurTreasureRound + 1
	if self.CurTreasureRound > self.TreasureTotalRound then
		return
	end

	local getGatherPos = function()
			if #self.TreasurePos <= 0 then return nil end
			local idx = math.random(1, #self.TreasurePos)
			local pos = self.TreasurePos[idx]
			table.remove(self.TreasurePos, idx)
			return pos
	end

	local modSpawn = self.Scene:GetModSpawn()
	for i = 1, self.TreasureNum do
		local pos = getGatherPos()
		if pos ~= nil then
			modSpawn:SpawnCollection(
				self.TreasureId, 
				pos.x, 
				pos.y,
				pos.dir)
		end
	end
end

function CurrentSceneScript:OnHumanEnter(human)
	local nUid = human:GetID()
	local curgid = human:GetModGuild():GetGuildID()
	local curgname = human:GetModGuild():GetGuildName()
	local name = human:GetName()
	
	self.HumanInfos[nUid] = {human:GetModPK():GetPKMod(), human:GetModPK():GetPKFlag(), human}
	human:GetModPK():SetPKMod(2, 5);

	if self:GetScore(curgid) == nil then
		self.HumanIdx = self.HumanIdx + 1
		table.insert(self.RecordScore, {idx = self.HumanIdx, val = 0, gid = curgid, gname = curgname})
		self:RankScore()
	else
		self.ModScript:BcGuildWarRank(self:GetGuildWarScoreRank(), 1, nUid)
	end

	if self:GetKill(curgid) == nil then
		self.HumanIdx = self.HumanIdx + 1
		table.insert(self.RecordKill, {idx = self.HumanIdx, val = 0, gid = curgid, gname = curgname})
		self:RankKill()
	else
		self.ModScript:BcGuildWarRank(self:GetGuildWarKillRank(), 2, nUid)
	end

	local record = self:GetHumanScore(nUid)
	if  record == nil then
		self.HumanIdx = self.HumanIdx + 1
		table.insert(self.RecordHumanScore, {idx = self.HumanIdx, val = 0, guild = curgid, gid = nUid, gname = name})
		self:RankHumanScore()
	else
		self.ModScript:SendGuildWarScore(self:GetHumanScoreRank(), record.rank, record.val, human)
	end

	self.ModScript:BcMyGuildWarStatus(self:GetMyGuildWarStatus(curgid, nUid), nUid)
	self.ModScript:BcGuildWarStatus(self:GetGuildWarStatus(), nUid)
end

function CurrentSceneScript:OnHumanLeave(human)
	local nUid = human:GetID()
	local curgid = human:GetModGuild():GetGuildID()
	self.ModScript:OnGuildWarLeave(self:GetMyGuildWarStatus(curgid, nUid), human)
	
	local pkInfo = self.HumanInfos[nUid]
	human:GetModPK():SetPKMod(pkInfo[1], pkInfo[2]);
	self.HumanInfos[nUid] = nil
end

function CurrentSceneScript:OnHumanKilled(human, killer)
	killerPlayer = self.ModScript:Unit2Human(killer)
	if killerPlayer == nil then return end
	self:UpdateKill(killerPlayer)
end

function CurrentSceneScript:OnMonsterStatueHited(monster, human)
	self:UpdateScoreHuman(human, self.Statue.hitScore)
end

function CurrentSceneScript:OnMonsterThroneHited(monster, human)
	self:UpdateScoreHuman(human, self.Throne.hitScore)
end

function CurrentSceneScript:OnMonsterKilled(monster, killer, id)
	local killerPlayer = self.ModScript:Unit2Human(killer)
	if killerPlayer == nil then return end
	
	local idx = monster:GetSpawnParam();
	self.Monster[idx].owner	= killerPlayer:GetModGuild():GetGuildID();
	self.Monster[idx].id	= 0;
	
	if id == self.Totems.id then
		self.ModScript:CancelTimer(self.Totems.tid);	
		self.Totems.owner		= killerPlayer:GetModGuild():GetGuildID()
		self.Totems.ownerName	= killerPlayer:GetModGuild():GetGuildName()
		self.Totems.tid			= self.ModScript:CreatePeriodTimer(1, 1, "OnTotemTimer");
		self.ModScript:BcGuildWarStatus(self:GetGuildWarStatus(), 0)
		
		self:SendNotice(10212, "10," .. self.Totems.owner .. "," .. self.Totems.ownerName)
		return
	end
		
	self.ModScript:BcGuildWarStatus(self:GetGuildWarStatus(), 0)	
end

function CurrentSceneScript:OnTotemTimer(tid)
	self:UpdateScore(self.Totems.owner, self.Totems.ownerName, self.Totems.occupyScore)
end

function CurrentSceneScript:OnGuildWarClosed()
	self.Close = true

	self:RankAll()

	self.Scene:StopAllMonster()

	_UnRegSceneEventHandler(self.Scene, SceneEvents.SceneCreated)
	_UnRegSceneEventHandler(self.Scene, SceneEvents.HumanEnterWorld)
	_UnRegSceneEventHandler(self.Scene, SceneEvents.HumanKilled)
	_UnRegSceneEventHandler(self.Scene, SceneEvents.MonsterKilled)
	_UnRegSceneEventHandler(self.Scene, SceneEvents.MonsterHited)
	_UnRegSceneEventHandler(self.Scene, SceneEvents.GuildActivityGather)
	
	self.ModScript:BcGuildWarReward(self:GetGuildWarScoreRank())
end

function CurrentSceneScript:OnHumanGater(human, id)
	if self.Close then return end

	local gid = human:GetModGuild():GetGuildID()
	local buffit = self.BuffItems[id]
	if buffit then
		for k,v in pairs(self.HumanInfos) do
			local curHuman = v[3]
			if curHuman ~= nil then
				local curgid = curHuman:GetModGuild():GetGuildID()
				if curgid == gid then
					self.ModScript:AddAura(curHuman, buffit.buffid)
				end
			end
		end
	elseif id == self.TreasureId then
		self:UpdateScoreHuman(human, self.TreasureScore)
	end
end
