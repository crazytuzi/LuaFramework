CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.MainHuman = nil
CurrentSceneScript.Scene = nil
-----------------------------------------------------------
CurrentSceneScript.BaseMap = 11401101 --第一张世界boss活动地图 activity  mapid
CurrentSceneScript.BossID = {	--bossID
	10300010,
	10300001,
	10300011,
	10300002,
	10300012,
	10300003,
	10300004,
}

CurrentSceneScript.BossPos = {	--boss出生点
	{x=-65, y=29, dir=1.6},
	{x=132, y=74, dir=4.7},
	{x=-6, y=-42, dir=3.2},
	{x=-133, y=45, dir=1.6},
	{x=99, y=-67, dir=3.6},
	{x=-40, y=-5, dir=1.4},
	{x=-47, y=64, dir=1.7},
}
-----------------------------------------------------------
CurrentSceneScript.CurrLevel = 1

function CurrentSceneScript:Startup()
	self.SModScript = self.Scene:GetModScript()
	self.CurrLevel = self.Scene:GetBaseMapID() - self.BaseMap + 1
	if self.CurrLevel < 1 or self.CurrLevel > 9 then self.CurrLevel = 1 end

	_RegSceneEventHandler(SceneEvents.HalfHourTimerExpired,"OnHalfHourTimerExpired")
	_RegSceneEventHandler(SceneEvents.TimerExpired,"OnTimerExpired")
	_RegSceneEventHandler(SceneEvents.SpawnWorldBoss,"SpawnWorldBoss")
end

function CurrentSceneScript:Cleanup() 
	
end

function CurrentSceneScript:OnTimerExpired(curr)
	
end

function CurrentSceneScript:OnHalfHourTimerExpired(mo,dd,hh,mm)  
	-- 每半小时触发一次 todo:
  	local spawn = false

	if hh== 10 and mm == 30 then
		spawn = true
	elseif hh == 14 and mm == 30  then
		spawn = true
	elseif hh == 18 and mm == 30  then
		spawn = true
	elseif hh== 22 and mm == 30 then
		spawn = true
	end

	if spawn == true then
		self.SModScript:CreateTimer(10, "SpawnWorldBoss") -- N秒后刷boss

		if self.CurrLevel == 1 then 	
			_SendNotice(10008)   -- 发送开启公告
		end
	end
end

function CurrentSceneScript:SpawnWorldBoss(val)
	print("activity10400001 Spawn WorldBoss")
	local pos = self.BossPos[self.CurrLevel]
	local boosid = self.BossID[self.CurrLevel]
	return self.Scene:GetModSpawn():DirSpawn(boosid, pos.x, pos.y,  pos.dir, 2)
end


