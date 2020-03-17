CurrentSceneScript = {}
CurrentSceneScript.Scene = nil
CurrentSceneScript.Param = {}
CurrentSceneScript.ModAdventure = nil

CurrentSceneScript.NpcPos = {
	x = 56, y = 92, dir = 3.49
}

function CurrentSceneScript:Startup()
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnter")
	_RegSceneEventHandler(SceneEvents.HumanLeaveWorld,"OnHumanLeave")
	_RegSceneEventHandler(SceneEvents.AdventureStepComplete,"OnStepComplete")
end

function CurrentSceneScript:OnHumanEnter(human)
	self.ModAdventure = human:GetModAdventure()
	self.Param.zazenadd = self.ModAdventure:GetEventParam(0, false)
	self.Param.zazentime = self.ModAdventure:GetEventParam(1, false)
	self.Param.step = 1

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
		self.Param.tid = self.Scene:GetModScript():CreatePeriodTimer(1, 1, "OnZazenTimer");
		self.Param.secs = 0
		self.ModAdventure:SetZazenAdd(self.Param.zazenadd)
	end
end

function CurrentSceneScript:OnZazenTimer(tid)
	if self.ModAdventure == nil or self.Param.step >= 3 then return end
	
	self.Param.secs = self.Param.secs + 1

	if self.Param.secs >= self.Param.zazentime then
		self.ModAdventure:SendStepResult(self.Param.step, 0)
		self.Param.step = 3
		self.result = 1
		self.ModAdventure:SetZazenAdd(0)
		self.Scene:GetModScript():CancelTimer(self.Param.tid)
	end
end

function CurrentSceneScript:Cleanup() 
	
end

