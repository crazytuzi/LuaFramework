CurrentSceneScript = {}
CurrentSceneScript.Scene = nil
CurrentSceneScript.Humans = {}
-----------------------------------------------------------
CurrentSceneScript.TotalPos = 3
CurrentSceneScript.Pos = {
	[1] = {
		["Boss"] = { x = -34, y = -13, dir = 2.3},
		["Human"]  = { x = 67, y = 27, dir = 4.6},
	},
	[2] = {
		["Boss"] = { x = -34, y = -13, dir = 2.3},
		["Human"]  = { x = 67, y = 27, dir = 4.6},
	},
	[3] = {
		["Boss"] = { x = -34, y = -13, dir = 2.3},
		["Human"]  = { x = 67, y = 27, dir = 4.6},
	},
}
-----------------------------------------------------------
CurrentSceneScript.CurrLevel = 0
CurrentSceneScript.CurrentCount = 0
CurrentSceneScript.TotalCount = 0
CurrentSceneScript.TimerID = 0
-----------------------------------------------------------

function CurrentSceneScript:Startup()
	self.SModScript = self.Scene:GetModScript()
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnter")
	_RegSceneEventHandler(SceneEvents.SceneStoryEnd, "OnStoryEnd")
	_RegSceneEventHandler(SceneEvents.HumanKilled,"OnHumanKilled")
	_RegSceneEventHandler(SceneEvents.MonsterKilled,"OnBossKilled")
	_RegSceneEventHandler(SceneEvents.HumanLeaveWorld, "OnHumanLeave")
end

function CurrentSceneScript:Cleanup() 
end

function CurrentSceneScript:OnHumanEnter(human)
	if human == nil then
		return	
	end
end

function CurrentSceneScript:OnZhuXianZhenStart(human, level)
	self.CurrentCount = 0
	self.TotalCount = 0
	if human == nil then return end
	self.CurrLevel = level
	--self.TimerID = self.SModScript:CreateTimer(5, "OnTimingStart")
	self:OnTimingStart()
	human:GetModZhuXianZhen():OnStartTimer(0)
end

function CurrentSceneScript:OnStoryEnd(human)
end

function CurrentSceneScript:OnBossKilled(boss, killer)
	local human = self.SModScript:Unit2Human(killer)
	if human == nil then return end
	self.CurrentCount = self.CurrentCount + 1;
	if self.CurrentCount == self.TotalCount then
		human:GetModZhuXianZhen():QuitZhuXianZhen(1)
		--if self.TimerID ~= nil then
			--self.SModScript:CancelTimer(self.TimerID)
		--end
		self.CurrentCount = 0
		self.TotalCount = 0
	end
end	

function CurrentSceneScript:OnHumanKilled(human, killer)
end

function CurrentSceneScript:OnHumanLeave(human)
	
	self.TotalCount = 0
	self.CurrentCount = 0
	self.Scene:RemoveAllMonster()
	if self.TimerID ~= nil  then
		self.SModScript:CancelTimer(self.TimerID)
	end
end

function CurrentSceneScript:OnTimingStart()
	self.CurrentCount = 0
	local monster = ZhuxianzhenConfig[tostring(self.CurrLevel)]['monsterId']
	if monster ~= nil then
		local monsterArray = split(monster, '#')
		local monsterNum = #monsterArray
		local monsterVec
		for j = 1,monsterNum do
			monsterVec = split(monsterArray[j], ',')
			self.TotalCount = self.TotalCount + monsterVec[2]
			self.Scene:GetModSpawn():SpawnBatch(monsterVec[1], monsterVec[2], self.Pos[1]["Boss"].x, self.Pos[1]["Boss"].y, self.Pos[1]["Boss"].dir)
		end
	end
	
end
