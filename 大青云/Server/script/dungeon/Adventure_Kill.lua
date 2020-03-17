CurrentSceneScript = {}
CurrentSceneScript.Scene = nil
CurrentSceneScript.Param = {}
CurrentSceneScript.ModAdventure = nil


CurrentSceneScript.MonsterPos = {
	x = -111, y = 58, radius = 20
}

CurrentSceneScript.NpcPos = {
	x = -74, y = 10, dir = 1.92
}

function CurrentSceneScript:Startup()
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnter")
	_RegSceneEventHandler(SceneEvents.HumanLeaveWorld,"OnHumanLeave")
	_RegSceneEventHandler(SceneEvents.AdventureStepComplete,"OnStepComplete")
	_RegSceneEventHandler(SceneEvents.MonsterKilled,"OnMonsterKilled")
end

function CurrentSceneScript:OnHumanEnter(human)
	self.ModAdventure = human:GetModAdventure()
	self.Param.monsterid = self.ModAdventure:GetEventParam(0, true)
	self.Param.num = self.ModAdventure:GetEventParam(1, false)
	self.Param.step = 1
	self.Param.killcnt = 0

	self.Scene:GetModSpawn():SpawnNpc(
		self.ModAdventure:GetNpcId(),
		self.NpcPos.x,
		self.NpcPos.y,
		self.NpcPos.dir
	)
	
	self.ModAdventure:OnEnter()
end

function CurrentSceneScript:OnHumanLeave(human)
	human:GetModAdventure():OnLeave(1)
	self.ModAdventure = nil
end

function CurrentSceneScript:OnStepComplete(step)
	if self.ModAdventure == nil or self.Param.step >= 3 then return end

	if step == 1  and self.Param.step == 1 then
		self.ModAdventure:SendStepResult(self.Param.step, 0)
		self.Param.step = 2
		self.Scene:GetModSpawn():SpawnBatch(
			self.Param.monsterid, 
			self.Param.num, 
			self.MonsterPos.x, 
			self.MonsterPos.y, 
			self.MonsterPos.radius)
	end
end

function CurrentSceneScript:OnMonsterKilled(monster, killer)
	if self.ModAdventure == nil or self.Param.step >= 3 then return end
	
	if monster:GetMonId() == self.Param.monsterid then
		self.Param.killcnt = self.Param.killcnt + 1
		self.ModAdventure:SendStepProgress(self.Param.killcnt)
		
		if self.Param.killcnt >= self.Param.num then
			self.ModAdventure:SendStepResult(self.Param.step, 0)
			self.Param.step = 3
		end
	end
end

function CurrentSceneScript:Cleanup() 
	
end

