CurrentSceneScript = {}
CurrentSceneScript.Scene = nil
CurrentSceneScript.Param = {}
CurrentSceneScript.ModAdventure = nil


CurrentSceneScript.GatherPos = {
	{x = -86, y = 61, dir = 0},
	{x = -109, y = 73, dir = 0},
	{x = -97, y = 121, dir = 0},
	{x = -59, y = 103, dir = 0},
	{x = 20, y = 69, dir = 0},
	{x = -1, y = 50, dir = 0},
	{x = 41, y = 121, dir = 0},
	{x = 66, y = 155, dir = 0},
	{x = 108, y = 122, dir = 0},
	{x = 76, y = 108, dir = 0},
	{x = 64, y = 80, dir = 0},
	{x = 31, y = 67, dir = 0},
}

CurrentSceneScript.NpcPos = {
	x = 14, y = 94, dir = 3.26
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
	self.Param.step = 1
	self.Param.gathernum = 0

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
		self.Param.gathernum = self.Param.gathernum + 1
		self.ModAdventure:SendStepProgress(self.Param.gathernum)
		
		if self.Param.gathernum >= self.Param.num then
			self.ModAdventure:SendStepResult(self.Param.step, 0)
			self.Param.step = 3
		end
	end
end

function CurrentSceneScript:Cleanup() 
	
end

