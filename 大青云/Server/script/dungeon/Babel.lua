CurrentSceneScript = {}
CurrentSceneScript.Scene = nil
CurrentSceneScript.Humans = {}
CurrentSceneScript.ModBabel = nil
-----------------------------------------------------------
CurrentSceneScript.TotalPos = 3
CurrentSceneScript.Pos = {
	[1] = {
		["Boss"] = { x = 3, y = 0, dir = 1.2},
		["Human"]  = { x = 67, y = 27, dir = 4.6},
	},
	[2] = {
		["Boss"] = { x = 3, y = 0, dir = 1.2},
		["Human"]  = { x = 67, y = 27, dir = 4.6},
	},
	[3] = {
		["Boss"] = { x = 3, y = 0, dir = 1.2},
		["Human"]  = { x = 67, y = 27, dir = 4.6},
	},
}
-----------------------------------------------------------
CurrentSceneScript.CurrLevel = nil
CurrentSceneScript.Boss = nil
-----------------------------------------------------------

function CurrentSceneScript:Startup()
	self.SModScript = self.Scene:GetModScript()
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnter")
	_RegSceneEventHandler(SceneEvents.SceneStoryEnd, "OnStoryEnd")
	_RegSceneEventHandler(SceneEvents.HumanKilled,"OnHumanKilled")
	_RegSceneEventHandler(SceneEvents.MonsterKilled,"OnBossKilled")
	_RegSceneEventHandler(SceneEvents.HumanLeaveWorld, "OnHumanLeave")
	_RegSceneEventHandler(SceneEvents.MonsterLeaveWorld, "OnMonsterLeave")
end

function CurrentSceneScript:Cleanup() 
	self.Boss = nil
end

function CurrentSceneScript:OnHumanEnter(human)
	self.ModBabel = human:GetModBabel()
end

function CurrentSceneScript:OnBabelStart(human, level)
	if self.Boss ~= nil then return end
	self.CurrLevel = level
	local idx = (level -1)%self.TotalPos + 1
	if self.Pos[idx] ~= nil then
		human:LuaChangePos(self.Pos[idx]["Human"].x, self.Pos[idx]["Human"].y)
		self.Boss = self.Scene:GetModSpawn():NewMonster(self.ModBabel:GetBossId(), 
			self.Pos[idx]["Boss"].x, self.Pos[idx]["Boss"].y, self.Pos[idx]["Boss"].dir, 0)
		if self.Boss then
			self.Boss:SetBit(4, 1)
			self.Boss:SetBit(8, 1)
		end
	end
end

function CurrentSceneScript:OnStoryEnd(human)
	-- local idx = (self.CurrLevel - 1)%self.TotalPos + 1
	-- if self.Pos[idx] ~= nil then
	-- 	human:LuaChangePos(self.Pos[idx]["Human"].x, self.Pos[idx]["Human"].y)
	-- end
	if self.Boss then
		self.Boss:SetBit(4, 0)
		self.Boss:SetBit(8, 0)
	end
end

function CurrentSceneScript:OnBossKilled(boss, killer)
	self.ModBabel:QuitBabel(1)
	self.Boss = nil
end	

function CurrentSceneScript:OnHumanKilled(human, killer)
	if self.Boss then
		self.ModBabel:QuitBabel(0)
		self.Boss = nil
	end
end

function CurrentSceneScript:OnHumanLeave(human)
	--self.ModBabel:QuitBabel(2)
	self.Boss = nil
end

function CurrentSceneScript:OnMonsterLeave(mon)
	self.Boss = nil
end