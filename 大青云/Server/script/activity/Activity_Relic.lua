CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.Scene = nil
----------------------------------------------------------
CurrentSceneScript.LayerT = {
	['10420003'] = 3,
	['10420006'] = 3,
	['10420009'] = 3,
	['10420001'] = 1,
	['10420004'] = 1,
	['10420007'] = 1,
	['10420005'] = 2,
	['10420002'] = 2,
	['10420008'] = 2,
	['10420010'] = 4,
	['10420011'] = 4,
	['10420012'] = 4,
}

CurrentSceneScript.BossPos ={
	['10420010'] = {id = 10900021, x = -24, y = -345},
	['10420010'] = {id = 10900021, x = 412, y = -381},
	['10420010'] = {id = 10900021, x = 405, y = 451},
	['10420010'] = {id = 10900021, x = -27, y = 418},
	['10420011'] = {id = 10910021, x = -24, y = -345},
	['10420011'] = {id = 10910021, x = 412, y = -381},
	['10420011'] = {id = 10910021, x = 405, y = 451},
	['10420011'] = {id = 10910021, x = -27, y = 418},
	['10420012'] = {id = 10920021, x = -24, y = -345},
	['10420012'] = {id = 10920021, x = 412, y = -381},
	['10420012'] = {id = 10920021, x = 405, y = 451},
	['10420012'] = {id = 10920021, x = -27, y = 418},

}

CurrentSceneScript.StatueID = 20300103  --正常
CurrentSceneScript.BrokenID = 20300104	--破坏
CurrentSceneScript.BattleID = 10000027	--战斗怪

CurrentSceneScript.SpawnStart = 10
CurrentSceneScript.SpawnEnd = 23
CurrentSceneScript.SpawnMin = 10
----------------------------------------------------------
CurrentSceneScript.MapID = 0
CurrentSceneScript.layer = 1
----------------------------------------------------------

function CurrentSceneScript:Startup()
	self.SModScript = self.Scene:GetModScript()
	_RegSceneEventHandler(SceneEvents.SceneCreated,"OnSceneCreated")
	_RegSceneEventHandler(SceneEvents.TimerExpired,"OnTimerExpired")
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnter")
	_RegSceneEventHandler(SceneEvents.HalfHourTimerExpired,"OnHalfHourTimerExpired")
end

function CurrentSceneScript:Cleanup() 
	
end


function CurrentSceneScript:OnSceneCreated()
	self.MapID = self.Scene:GetBaseMapID()
	local layer = self.LayerT[tostring(self.MapID)]
	if layer then
		self.layer = layer
	end

	if self.layer == 3 then
		local boss = self.BossPos[tostring(self.MapID)]
		if boss ~= nil then
			self.Scene:GetModSpawn():Spawn(boss.id, boss.x, boss.y, 2)
		end
	end
end


function CurrentSceneScript:OnHalfHourTimerExpired(mo,dd,hh,mm)  
	-- 每半小时触发一次 todo
	if self.layer == 3 then
		if hh >= self.SpawnStart and hh < self.SpawnEnd  then
			if mm == 0 then
				self.SModScript:CreateTimer(10*60, "SpawnBoss") -- N秒后刷boss
			end
		end
	end
end


function CurrentSceneScript:OnHumanEnter(human)
	if human then
		self.Scene:SendRelicInfo(human:GetID())
	end
end

function CurrentSceneScript:OnTimerExpired(cur)
	self.Scene:SendRelicInfo(0)
end


function CurrentSceneScript:SpawnBoss()
	local boss = self.BossPos[tostring(self.MapID)]
	if boss ~= nil then
		self.Scene:GetModSpawn():Spawn(boss.id, boss.x, boss.y, 2)
	end
end


