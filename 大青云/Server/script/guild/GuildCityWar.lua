CurrentSceneScript = {}
CurrentSceneScript.Scene = nil
CurrentSceneScript.ModScript = {}
CurrentSceneScript.MonStatus = {}
CurrentSceneScript.RecordKill = {}
CurrentSceneScript.ExtraInfo = {}
CurrentSceneScript.Close = false
CurrentSceneScript.HumanIdx = 1
CurrentSceneScript.AtkSide = 1
CurrentSceneScript.DefSide = 2
CurrentSceneScript.BirthPos = {
	[CurrentSceneScript.AtkSide] = {x = 829, y = 792},
	[CurrentSceneScript.DefSide] = {x = -937, y = -659},
}
CurrentSceneScript.AtkGid = 0
CurrentSceneScript.DefGid = 0
CurrentSceneScript.Humans = {
	[CurrentSceneScript.AtkSide] = {},
	[CurrentSceneScript.DefSide] = {},
}
CurrentSceneScript.hasSend = false

function CurrentSceneScript:Startup()
	_RegSceneEventHandler(SceneEvents.SceneCreated, "OnSceneCreated")
	_RegSceneEventHandler(SceneEvents.SceneDestroy, "OnSceneDestroy")
	_RegSceneEventHandler(SceneEvents.GuildActivityClose, "OnClosed")
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld, "OnHumanEnter")
	_RegSceneEventHandler(SceneEvents.HumanLeaveWorld, "OnHumanLeave")
	_RegSceneEventHandler(SceneEvents.HumanKilled, "OnHumanKilled")
	_RegSceneEventHandler(SceneEvents.HumanRelive, "OnHumanRelive")
	_RegSceneEventHandler(SceneEvents.MonsterKilled, "OnMonsterKilled")
	_RegSceneEventHandler(SceneEvents.MonsterEnterWorld, "OnMonsterEnter")
	_RegSceneEventHandler(SceneEvents.MonsterHited, "OnMonsterThroneHited", {param1 = unionCityWarbuilding[5].id})
end

function CurrentSceneScript:Cleanup() 
	
end

function CurrentSceneScript:CreateMonster(i, id, x, y, dir)

	if i == 5 then
		self.MonStatus[i] = {idx = i, mid = id, side = self.DefSide, hp = 10000, maxhp = 10000}
	else
		self.MonStatus[i] = {idx = i, mid = id, side = self.ModScript:GetInitStatueSide(i)}
	end
	
	self.Scene:GetModSpawn():NewMonster(id, x, y, dir, 0)
end

function CurrentSceneScript:OnMonsterEnter(monster)
	local monsterInfo = self:GetMonStatus(monster)
	if monsterInfo.idx ~= 5 then
		-- 神像血量 = 最高玩家等级*100000
		monster:SetInitAttr(20, 100000 * self.ModScript:GetCityWarParam(1))	
		monster:InitAttr()
	else
		monsterInfo.hp = monster:GetIntAttr(19)
		monsterInfo.maxhp = monster:GetIntAttr(20)
	end
	local gid = self.ModScript:GetCityWarGuildBySide(monsterInfo.side)
	monster:SetBelong(MonsterBelongType.Belong_Guild, gid, true)
end

function CurrentSceneScript:OnSceneCreated(scene)
	self.ModScript = self.Scene:GetModScript()

	for i,v in pairs(unionCityWarbuilding) do
		self:CreateMonster(i, v.id, v.x, v.y, v.dir or 0)
	end
	
	self.AtkGid = self.ModScript:GetCityWarGuildBySide(self.AtkSide)
	self.DefGid = self.ModScript:GetCityWarGuildBySide(self.DefSide)
end

function CurrentSceneScript:OnSceneDestroy()
	self.ExtraInfo = nil
	self.ModScript = nil
	self.RecordKill = nil
	self.MonStatus = nil
	self.Humans = nil
end

function CurrentSceneScript:OnHumanEnter(human)
	local side = self:GetSide(human)
	local pos = self.BirthPos[side]
	local id = human:GetID()
	
	human:LuaChangePos(pos.x, pos.y)
	self:AddKill(human)
	self.Humans[side][id] = {ptr = human, pk = {human:GetModPK():GetPKMod(), human:GetModPK():GetPKFlag()} }
	human:GetModPK():SetPKMod(2, 5);
	
	if side == self.AtkSide then
		for i,v in pairs(self.MonStatus) do
			if v.side == side then
				local buffid = unionCityWarbuilding[v.idx].buff
				if buffid ~= nil then
					self.ModScript:AddAura(human, buffid)
				end
			end
		end
	end
	self.ModScript:SendCityWarInfo(human, self.MonStatus[5].maxhp)
	self.ModScript:BcGuildCityWarStatus(self:GetStatus(), id)
	self.ModScript:BcGuildCityWarRank(self:GetRank(), id)
end

function CurrentSceneScript:OnHumanLeave(human)
	local side = self:GetSide(human)
	local pkInfo = self.Humans[side][human:GetID()].pk
	human:GetModPK():SetPKMod(pkInfo[1], pkInfo[2]);
	self.Humans[side][human:GetID()] = nil
	
	self.ModScript:OnCityWarLeave(human)
end

function CurrentSceneScript:OnHumanKilled(human, killer)
	killerPlayer = self.ModScript:Unit2Human(killer)
	if killerPlayer == nil then return end
	
	self:UpdateKill(killerPlayer)
end

function CurrentSceneScript:GetRelivePos(human)
	local side = self:GetSide(human)
	if side == self.DefSide then
		return self.BirthPos[side]
	end
	
	local posVec = {}
	table.insert(posVec, self.BirthPos[side])
	for i,v in pairs(self.MonStatus) do
		if v.side == side then
			table.insert(posVec, {
				x = unioncityWarlifePoint[i].x, 
				y = unioncityWarlifePoint[i].y,
			})
		end
	end
	
	local selfPos = human:GetPos()
	local dist = 99999999
	local idx = 1
	for i,v in pairs(posVec) do
		curdist =	(v.x - selfPos[1]) * (v.x - selfPos[1]) + 
					(v.y - selfPos[3]) * (v.y - selfPos[3])
		if curdist < dist then
			dist = curdist
			idx = i
		end
	end
	
	return posVec[idx] 
end

function CurrentSceneScript:OnHumanRelive(human)
	local pos = self:GetRelivePos(human)
	human:LuaChangePos(pos.x, pos.y)
end

function CurrentSceneScript:OnMonsterKilled(monster, killer, id)
	killerPlayer = self.ModScript:Unit2Human(killer)
	if killerPlayer == nil then return end

	local monsterInfo = self:GetMonStatus(monster)
	if monsterInfo.idx == 5 then
		self.ModScript:EndGuildCityWar(self.AtkSide)
		return
	end
	
	monsterInfo.side = self:GetSide(killerPlayer)
	local gid	= killerPlayer:GetModGuild():GetGuildID()
	local gname	= killerPlayer:GetModGuild():GetGuildName()
	local statname	= unionCityWarbuilding[monsterInfo.idx].name
	local rebname	= unioncityWarlifePoint[monsterInfo.idx].name
	
	if monsterInfo.side == self.AtkSide then
		self:OnTakenStatue(monsterInfo.idx)
		
		self:SendNotice(10203, "10," .. gid .. "," .. gname .. "#5," .. statname .. "#5," .. rebname)
	elseif monsterInfo.side == self.DefSide then
		self:OnBeTakenStatue(monsterInfo.idx)
		
		self:SendNotice(10204, "10," .. gid .. "," .. gname .. "#5," .. statname .. "#5," .. rebname)
	end
	
	self.ModScript:BcGuildCityWarStatus(self:GetStatus(), 0)
end

function CurrentSceneScript:OnTakenStatue(idx)
	local buffid = unionCityWarbuilding[idx].buff
	if buffid == nil then return end
	
	for id,human in pairs(self.Humans[self.AtkSide]) do
		self.ModScript:AddAura(human.ptr, buffid)
	end
end

function CurrentSceneScript:OnBeTakenStatue(idx)
	local buffid = unionCityWarbuilding[idx].buff
	if buffid == nil then return end
	
	for id,human in pairs(self.Humans[self.AtkSide]) do
		self.ModScript:DelAura(human.ptr, buffid)
	end
end

function CurrentSceneScript:OnMonsterThroneHited(monster, human)
	local monsterInfo = self:GetMonStatus(monster)
	local cuhp = monster:GetIntAttr(19)
	if cuhp ~= monsterInfo.hp then
		monsterInfo.hp = cuhp
		self.ModScript:BcGuildCityWarStatus(self:GetStatus(), 0)
	end
	
	if not self.hasSend then
		self.hasSend = true
		self:SendNotice(10201)
		self.ModScript:CreateTimer(3, "OnNoticeInteralEnd")
	end
end

function CurrentSceneScript:OnNoticeInteralEnd(tid)
	self.hasSend = false
end

function CurrentSceneScript:OnClosed()
	self.Close = true

	self.Scene:StopAllMonster()
	
	_UnRegSceneEventHandler(self.Scene, SceneEvents.SceneCreated)
	_UnRegSceneEventHandler(self.Scene, SceneEvents.HumanEnterWorld)
	_UnRegSceneEventHandler(self.Scene, SceneEvents.HumanKilled)
	_UnRegSceneEventHandler(self.Scene, SceneEvents.MonsterKilled)
	_UnRegSceneEventHandler(self.Scene, SceneEvents.MonsterHited)
	
	self.ModScript:BcGuildCityWarResult(self:GetStatus(), self:GetRank())
end
-----------------------------------------------------
function CurrentSceneScript:SendNotice(id, param)
	param = param or ""
	_SendNotice(id, param, self.Scene:GetGameMapID())
end

function CurrentSceneScript:RankKill(curgid)
	table.sort(self.RecordKill, function(a, b)
		if a.val ~= b.val then
			return a.val > b.val
		else
			return a.idx < b.idx
		end
	end)
	
	self.ModScript:BcGuildCityWarRank(self:GetRank(), 0)
end

function CurrentSceneScript:GetKill(uid)
	for i,v in pairs(self.RecordKill) do
		if v and v.uid == uid then
			return v
		end
	end
	
	return nil
end

function CurrentSceneScript:AddKill(human)
	local curuid = human:GetID()
	if self:GetKill(curuid) == nil then
		self.HumanIdx = self.HumanIdx + 1
		table.insert(self.RecordKill, {
			idx = self.HumanIdx, 
			val = 0, 
			uid = curuid, 
			name = human:GetName(),
			side = self:GetSide(human)
		})
		self:RankKill(curuid)	
	end
end

function CurrentSceneScript:UpdateKill(human)
	local curuid = human:GetID()
	local curname = human:GetName()
	
	local record = self:GetKill(curuid)
	if record == nil then return end
	
	record.val	= record.val + 1
	self:RankKill(curuid)
end

function CurrentSceneScript:GetSide(human)
	local gid = human:GetModGuild():GetGuildID()
	
	if gid == self.DefGid then
		return self.DefSide
	else
		return self.AtkSide
	end	
end

function CurrentSceneScript:GetRank()
	return self.RecordKill
end

function CurrentSceneScript:GetMonStatus(monster)
	local monId = monster:GetMonId()
	for i,v in pairs(self.MonStatus) do
		if v.mid == monId then
			return v
		end
	end
	return nil
end

function CurrentSceneScript:GetStatus()
	local retInfo = {}
	retInfo.hp = self.MonStatus[5].hp
	retInfo.status = {}
	for i,v in pairs(self.MonStatus) do
		table.insert(retInfo.status, v.side)
	end
	return retInfo
end
----------------------------------------------------