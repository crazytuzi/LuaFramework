CurrentSceneScript = {}
CurrentSceneScript.Scene = nil
CurrentSceneScript.Param = {}

CurrentSceneScript.NpcPos = {
	x = 302, y = -7, dir = 3.49
}

function CurrentSceneScript:Startup()
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnter")
	_RegSceneEventHandler(SceneEvents.HumanLeaveWorld,"OnHumanLeave")
	_RegSceneEventHandler(SceneEvents.AdventureStepComplete,"OnStepComplete")
	_RegSceneEventHandler(SceneEvents.AdventureStepReply,"OnStepReply")
end

function CurrentSceneScript:OnHumanEnter(human)
	self.ModAdventure = human:GetModAdventure()
	self.Param.cnt = self.ModAdventure:GetEventParam(0, false)
	self.Param.step = 1
	self.Param.ansercnt = 0

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
		self.Param.question = self.ModAdventure:GetRandQuestion(self.Param.cnt)
		self.ModAdventure:SendStepCont(1, self.Param.question[self.Param.ansercnt * 2 + 1])
	end
end

function CurrentSceneScript:OnStepReply(reply)
	if self.ModAdventure == nil or self.Param.step >= 3 then return end

	if reply == self.Param.question[self.Param.ansercnt * 2 + 2] then
		self.Param.ansercnt = self.Param.ansercnt + 1
		self.ModAdventure:SendStepProgress(self.Param.ansercnt)

		if self.Param.ansercnt >= self.Param.cnt then
			self.ModAdventure:SendStepResult(self.Param.step, 0)
			self.Param.step = 3
		else
			self.ModAdventure:SendStepCont(1, self.Param.question[self.Param.ansercnt * 2 + 1])
		end
	end
end

function CurrentSceneScript:Cleanup() 
	
end