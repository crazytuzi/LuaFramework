CurrentSceneScript = {}
CurrentSceneScript.Scene = nil
CurrentSceneScript.Param = {}
CurrentSceneScript.ModAdventure = nil


CurrentSceneScript.GatherPos = {
	{x = -62, y = 7, dir = 0},
	{x = -94, y = -28, dir = 0},
	{x = -73, y = -42, dir = 0},
	{x = -34, y = -77, dir = 0},
	{x = 42, y = -69, dir = 0},
	{x = 64, y = -102, dir = 0},
	{x = 53, y = -146, dir = 0},
	{x = 16, y = -137, dir = 0},
	{x = -4, y = -182, dir = 0},
	{x = -40, y = -128, dir = 0},
	{x = -75, y = -78, dir = 0},
	{x = -110, y = -54, dir = 0},
	{x = -15, y = 47, dir = 0},
}

CurrentSceneScript.NpcPos = {
	x = 7, y = -81, dir = 2.21
}

function CurrentSceneScript:Startup()
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnter")
	_RegSceneEventHandler(SceneEvents.HumanLeaveWorld,"OnHumanLeave")
	_RegSceneEventHandler(SceneEvents.AdventureStepComplete,"OnStepComplete")
	_RegSceneEventHandler(SceneEvents.AdventureGather,"OnGather")
end

function CurrentSceneScript:OnHumanEnter(human)
	self.ModAdventure = human:GetModAdventure()
	self.Param.gatherid = self.ModAdventure:GetEventParam(0, true)
	self.Param.num = self.ModAdventure:GetEventParam(1, false)
	self.Param.rate = self.ModAdventure:GetEventParam(2, false)
	self.Param.step = 1
	self.Param.currate = self.Param.rate

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

		local gatherPos = self.GatherPos
		local getGatherPos = function()
			local idx = math.random(1, #gatherPos)
			local pos = gatherPos[idx]
			table.remove(gatherPos, idx)
			return pos
		end

		local modSpawn = self.Scene:GetModSpawn()
		for i = 1, self.Param.num do
			local pos = getGatherPos()
			if pos ~= nil then
				modSpawn:SpawnCollection(
					self.Param.gatherid, 
					pos.x, 
					pos.y,
					pos.dir)
			end
		end
	end
end

function CurrentSceneScript:OnGather(id)
	if self.ModAdventure == nil or self.Param.step >= 3 then return end

	if id == self.Param.gatherid then
		local ranidx = math.random(1, 100000)
		if ranidx <= self.Param.currate then
			self.ModAdventure:SendStepProgress(1)
			self.ModAdventure:SendStepResult(self.Param.step, 0)
			self.Param.step = 3
		else
			self.Param.currate = self.Param.currate + self.Param.rate
			self.ModAdventure:SendStepProgress(0)
		end
	end
end

function CurrentSceneScript:Cleanup() 
	
end

