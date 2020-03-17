CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.Scene = nil
CurrentSceneScript.RemoveMonster = false
CurrentSceneScript.RebirthInfo = {}

CurrentSceneScript.MonsterPos = {
	{id = 10000028, x = -467, z = -5, dir = 0.69},
	{id = 10000028, x = -158, z = -66, dir = 2.81},
	{id = 10000037, x = -322, z = -169, dir = 1.67},
	{id = 10000037, x = -156, z = 58, dir = 4.70},
	{id = 10000036, x = -162, z = 33, dir = 3.06},
	{id = 10000036, x = -187, z = -65, dir = 1.91},
	{id = 10000036, x = -303, z = -142, dir = 5.03},
	{id = 10000036, x = -437, z = -6, dir = 4.72},
	{id = 10000035, x = -477, z = -30, dir = 2.27},
	{id = 10000035, x = -477, z = 20, dir = 0.47},
	{id = 10000029, x = -339, z = -136, dir = 0},
	{id = 10000029, x = -159, z = -36, dir = 0},
	{id = 10000029, x = -180, z = 57, dir = 1.16},
}

CurrentSceneScript.BossPos = {
	id = 10100000, x = -304, z = -6, dir = 3.05
}

CurrentSceneScript.Rebirth = {
	[10000029] = {min = 500, max = 800},
	[10000035] = {min = 500, max = 800},
	[10000036] = {min = 500, max = 800},
}

CurrentSceneScript.CreateId = 1001002
CurrentSceneScript.QuitId = 1001029
CurrentSceneScript.QuitDelay = 30

function CurrentSceneScript:Startup()
	_RegSceneEventHandler(SceneEvents.SceneCreated, "OnSceneCreated")
	_RegSceneEventHandler(SceneEvents.QuestFinished, "OnQuestFinished")
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld, "OnHumanEnter")
	_RegSceneEventHandler(SceneEvents.QuestStoryEnd, "OnQuestStoryEnd", {param1 = self.QuitId})
	_RegSceneEventHandler(SceneEvents.MonsterKilled, "OnMonsterKilled")
end

function CurrentSceneScript:OnHumanEnter(human)
	human:GetModQuest():SatisfyQuestStatus(1001001,0)
end

function CurrentSceneScript:OnSceneCreated()
	local modSpan = self.Scene:GetModSpawn()
	
	for k, v in pairs(self.MonsterPos) do
		modSpan:NewMonster(v.id, v.x, v.z, v.dir, 0)
	end
end

function CurrentSceneScript:Cleanup() 
	self.RebirthInfo = nil
	self.MonsterPos = nil
	self.BossPos = nil
	self.Rebirth = nil
end

function CurrentSceneScript:OnQuestFinished(id)
	if id == self.CreateId then
		self.RemoveMonster = true
		self.Scene:RemoveAllMonster()
		self.Scene:GetModSpawn():NewMonster(self.BossPos.id, self.BossPos.x, self.BossPos.z, self.BossPos.dir, 0)
	elseif id == self.QuitId then
		self.Scene:GetModScript():CreateTimer(self.QuitDelay, "QuitQuestDugeon")
	end
end

function CurrentSceneScript:OnQuestStoryEnd(human, id)
	if id == self.QuitId then
		self:QuitQuestDugeon()
	end
end

function CurrentSceneScript:OnMonsterKilled(monster, killer)
	if self.RemoveMonster then return end

	local monsterId = monster:GetMonId()
	local birth = self.Rebirth[monsterId]
	if birth == nil then return end

	local randTime = math.random(birth.min, birth.max)
	local tid = self.Scene:GetModScript():CreateMsecTimer(randTime, "OnReBirth")
	self.Rebirth[tid] = {id = monsterId, pos = monster:GetSpawnPos(), dir = monster:GetSpawnDir()}
end

function CurrentSceneScript:OnReBirth(tid)
	if self.RemoveMonster then return end

	local birth = self.Rebirth[tid]
	if birth == nil then return end

	self.Scene:GetModSpawn():NewMonster(birth.id, birth.pos[1], birth.pos[3], birth.dir, 0)
	self.Rebirth[tid] = nil
end

function CurrentSceneScript:FinishQuest(human,id)
	human:GetModQuest():SatisfyQuestStatus(id,0)
end

function CurrentSceneScript:QuitQuestDugeon()
	for k, v in pairs(self.Humans) do
		v:GetModQuest():SendQuestBossQuit()
	end
end
