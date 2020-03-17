CurrentSceneScript = {}

CurrentSceneScript.EnterPos = {
	[FactionTypes.FactionCrossScene1] = {x = -1213, y = -324, dir = 0},
	[FactionTypes.FactionCrossScene2] = {x = 58, y = -1292, dir = 0},
	[FactionTypes.FactionCrossScene3] = {x = 1211, y = -451, dir = 0},
	[FactionTypes.FactionCrossScene4] = {x = 1073, y = 1090, dir = 0},
	[FactionTypes.FactionCrossScene5] = {x = -662, y = 1119, dir = 0},
}

CurrentSceneScript.BrithPos = {
	[FactionTypes.FactionCrossScene1] = {x = -1213, y = -324, dir = 0},
	[FactionTypes.FactionCrossScene2] = {x = 58, y = -1292, dir = 0},
	[FactionTypes.FactionCrossScene3] = {x = 1211, y = -451, dir = 0},
	[FactionTypes.FactionCrossScene4] = {x = 1073, y = 1090, dir = 0},
	[FactionTypes.FactionCrossScene5] = {x = -662, y = 1119, dir = 0},
}

CurrentSceneScript.BossPos = {
	[1] = {id = 14000011, x= -46, y = -545, dir = 40},
	[2] = {id = 14000012, x = 495, y = -91, dir = 40},
	[3] = {id = 14000013, x = -264, y = 400, dir = 40},
}

CurrentSceneScript.LastTime = 28800					--活动持续时间
CurrentSceneScript.BrithTime = 120					--复活时间

CurrentSceneScript.LastTid = nil
CurrentSceneScript.StartTid = nil
CurrentSceneScript.ModScript = nil
CurrentSceneScript.Close = false

CurrentSceneScript.MonsterState = {}


function CurrentSceneScript:Startup()
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld, "OnHumanEnter")
	_RegSceneEventHandler(SceneEvents.HumanKilled,"OnHumanKilled")
	_RegSceneEventHandler(SceneEvents.HumanLeaveWorld, "OnHumanLeave")
	_RegSceneEventHandler(SceneEvents.HumanRelive, "OnHumanRelive")
	_RegSceneEventHandler(SceneEvents.MonsterEnterWorld, "OnMonsterEnter")
	_RegSceneEventHandler(SceneEvents.MonsterKilled, "OnMonsterKilled")

	self.ModScript = self.Scene:GetModScript()
	self.LastTid = self.ModScript:CreateTimer(self.LastTime, "OnEndTimer");
	self.StartTid = self.ModScript:CreateTimer(0, "OnStartTimer")
end

function CurrentSceneScript:Cleanup() 
	
end

function CurrentSceneScript:OnHumanEnter(human)
	
	human:GetModCrossTask():OnEnter()

	local pos = self.EnterPos[human:GetFaction()]
	if pos ~= nil then
		human:LuaChangePos(pos.x, pos.y)
		human:LuaChangeDir(pos.dir)
	end

	self.ModScript:BcCrossTaskBossInfo(self:GetMonsterState(), human:GetID())
end

function CurrentSceneScript:OnMonsterEnter(monster)
	local idx = monster:GetSpawnParam()
	if idx <= 0 then
		return 
	end

	self.MonsterState[idx] = {}
	self.MonsterState[idx].id = monster:GetMonId()
	self.MonsterState[idx].state = 1
	self.MonsterState[idx].tid = nil

	monster:SetInitAttr(28, self.ModScript:GetCrossTaskParam(0, 28)) --eaAtk
	monster:SetInitAttr(20, self.ModScript:GetCrossTaskParam(1, 20)) --eaMaxHp
	monster:SetInitAttr(30, self.ModScript:GetCrossTaskParam(2, 30)) --eaHit
	monster:SetInitAttr(31, self.ModScript:GetCrossTaskParam(3, 31)) --eaDodge
	monster:SetInitAttr(29, self.ModScript:GetCrossTaskParam(5, 29)) --eaDef
	monster:SetInitAttr(32, self.ModScript:GetCrossTaskParam(6, 32)) --eaCri
	monster:SetInitAttr(36, self.ModScript:GetCrossTaskParam(7, 36)) --eaCriValue
	monster:SetInitAttr(38, self.ModScript:GetCrossTaskParam(8, 38)) --eaAbsAtt
	monster:SetInitAttr(33, self.ModScript:GetCrossTaskParam(9, 33)) --eaDefCri
	monster:SetInitAttr(37, self.ModScript:GetCrossTaskParam(10, 37)) --eaSubCri
	monster:SetInitAttr(42, self.ModScript:GetCrossTaskParam(11, 42)) --eaParryRate
	monster:SetInitAttr(39, self.ModScript:GetCrossTaskParam(12, 39)) --eaParryValue
	monster:SetInitAttr(40, self.ModScript:GetCrossTaskParam(14, 40)) --eaDmgAdd

end

function CurrentSceneScript:OnMonsterKilled(monster, killer, id)
	local idx = monster:GetSpawnParam()
	if idx <= 0 then
		return 
	end

	local info = KuafuscenebossConfig[tostring(id)]
	if info ~= nil then
		local killerPlayer = self.ModScript:Unit2Human(killer)
		if killerPlayer ~= nil then
			killerPlayer:GetModCrossTask():AddScore(info.score)
		end
	end

	self.MonsterState[idx] = {}
	self.MonsterState[idx].id = monster:GetMonId()
	self.MonsterState[idx].state = 2
	self.MonsterState[idx].tid = self.ModScript:CreateTimer(self.BrithTime, "OnBirth")

	self.ModScript:BcCrossTaskBossInfo(self:GetMonsterState(), 0)

end

function CurrentSceneScript:GetMonsterState()
	local retInfo = {}
	for i = 1, #self.MonsterState do
		local val = {}
		val.id = self.MonsterState[i].id
		val.state = self.MonsterState[i].state
		val.tid = self.MonsterState[i].tid
		val.time = 0
		if val.tid ~= nil then
			val.time = self.ModScript:GetTimerRemain(val.tid)
		end
		table.insert(retInfo, val)
	end
	return retInfo
end

function CurrentSceneScript:GetMonsterByTid(tid)
	for i = 1, #self.MonsterState do
		if self.MonsterState[i].tid == tid then
			return i
		end
	end

	return 0
end

function CurrentSceneScript:OnHumanKilled(human, killer)

end

function CurrentSceneScript:OnHumanLeave(human)
	human:GetModCrossTask():OnLeave()
end

function CurrentSceneScript:OnHumanRelive(human)
	local pos = self.BrithPos[human:GetFaction()]
	if pos ~= nil then
		human:LuaChangePos(pos.x, pos.y)
	end
end

function CurrentSceneScript:OnStartTimer(tid)
	for k, v in pairs(self.BossPos) do
		self.Scene:GetModSpawn():SpawnExt(v.id, v.x, v.y, v.dir, k)
	end
end

function CurrentSceneScript:OnEndTimer(tid)
	self:OnEnd()
end

function CurrentSceneScript:OnBirth(tid)
	local idx = self:GetMonsterByTid(tid)
	if idx <= 0 then
		return
	end

	local v = self.BossPos[idx]
	if v == nil then
		return
	end

	self.Scene:GetModSpawn():SpawnExt(v.id, v.x, v.y, v.dir, idx)

	self.MonsterState[idx].tid = nil

	self.ModScript:BcCrossTaskBossInfo(self:GetMonsterState(), 0)
end

function CurrentSceneScript:OnEnd()
	if self.Close then return end

	self.ModScript:CreateTimer(30, "OnLeaveTimer")

	self.Close = true
end

function CurrentSceneScript:OnLeaveTimer(tid)
	self.ModScript:OnCrossLeave()
end
