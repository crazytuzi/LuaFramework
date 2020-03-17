CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.MainHuman = nil
CurrentSceneScript.Scene = nil
----------------------------------------------------------
CurrentSceneScript.BaseMap = 10410001  --第一层地图
CurrentSceneScript.MaxLevel = 5
CurrentSceneScript.BossID = {	--bossID
	10901001,
	10901002,
	10901003,
	10901004,
	10901005,
}

CurrentSceneScript.BossPos = {	--boss出生点
	{x=1102, y=22},
	{x=1102, y=22},
	{x=1102, y=22},
	{x=1102, y=22},
	{x=1102, y=22},
}

CurrentSceneScript.BossSpawntime = {
	-- 只能是整点或者半点,按顺序
	{hh = 8, mm = 00},
	{hh = 8, mm = 30},
	{hh = 9, mm = 00},
	{hh = 9, mm = 30},
	{hh = 10, mm = 00},
	{hh = 10, mm = 30},
	{hh = 11, mm = 00},
	{hh = 11, mm = 30},
	{hh = 12, mm = 00},
	{hh = 12, mm = 30},
	{hh = 13, mm = 00},
	{hh = 13, mm = 30},
	{hh = 14, mm = 00},
	{hh = 14, mm = 30},
	{hh = 15, mm = 00},
	{hh = 15, mm = 30},
	{hh = 16, mm = 00},
	{hh = 16, mm = 30},
	{hh = 17, mm = 00},
	{hh = 17, mm = 30},
	{hh = 18, mm = 00},
	{hh = 18, mm = 30},
	{hh = 19, mm = 00},
	{hh = 19, mm = 30},
	{hh = 20, mm = 00},
	{hh = 20, mm = 30},
	{hh = 21, mm = 00},
	{hh = 21, mm = 30},
	{hh = 22, mm = 00},
	{hh = 22, mm = 30},
	{hh = 23, mm = 00},
	{hh = 23, mm = 30},
}

CurrentSceneScript.BossAlive = false
CurrentSceneScript.NextSpawnTime = {}
CurrentSceneScript.CurrLevel = 1

function CurrentSceneScript:SpawnBoss()
	local pos = self.BossPos[self.CurrLevel]
	self.Scene:GetModSpawn():Spawn(self.BossID[self.CurrLevel], pos.x, pos.y, 6)
	self.BossAlive = true
end

function CurrentSceneScript:Startup()
	self.SModScript = self.Scene:GetModScript()
	self.CurrLevel = self.Scene:GetBaseMapID() - self.BaseMap + 1
	if self.CurrLevel < 1 or self.CurrLevel > self.MaxLevel then self.CurrLevel = 1 end
	_RegSceneEventHandler(SceneEvents.SceneCreated,"OnSceneCreated")
	_RegSceneEventHandler(SceneEvents.SceneDestroy, "OnSceneDestroy")
	_RegSceneEventHandler(SceneEvents.HalfHourTimerExpired,"OnHalfHourTimerExpired")
	-- _RegSceneEventHandler(SceneEvents.TimerExpired,"OnTimerExpired")
	_RegSceneEventHandler(SceneEvents.MonsterKilled,"OnBossKilled", {param1=self.BossID[self.CurrLevel]})
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnter")
end

function CurrentSceneScript:Cleanup() 
	
end

function CurrentSceneScript:OnSceneDestroy()
	self.nbMonRecords = {}
end

function CurrentSceneScript:OnHalfHourTimerExpired(mo,dd,hh,mm)  
	-- 每半小时触发一次 todo:
	for i,v in ipairs(self.BossSpawntime) do
		if hh == v.hh and mm == v.mm then 
			if self.CurrLevel == 1 then 	
				_SendNotice(10501)   -- 发送开启公告
			end

			if self.BossAlive == false then
				self:SpawnBoss()
				self:SendHangBossInfo()
			end
		end
	end
end

function CurrentSceneScript:OnSceneCreated()
	self:SpawnBoss()
end

function CurrentSceneScript:OnHumanEnter(human)
	self:SendHangBossInfo(human:GetID())
end


function CurrentSceneScript:OnBossKilled(mon, killer)
	self.BossAlive = false
	--local tab = os.date("*t")
	--self:CalcBossSpawn(tab.hour, tab.min)
	self:SendHangBossInfo()
end

function CurrentSceneScript:GetNextSpawnTime()
	-- body    
	local tab = os.date("*t")
	for i,v in ipairs(self.BossSpawntime) do
		if tab.hour < v.hh or (tab.hour == v.hh and tab.min < v.mm) then
			print("Next:", v.hh, v.mm)
			return v
		end
	end
	return self.BossSpawntime[1]
end

function CurrentSceneScript:SendHangBossInfo(humanid)
	local data = {}
	data[1] = self.BossID[self.CurrLevel]
	if self.BossAlive == false then
		local tab = os.date("*t")

		local time = self:GetNextSpawnTime()
		if time.hh == nil or time.mm == nil then return end
		local sec = (0 - tab.sec) + (time.mm - tab.min)*60 + (time.hh - tab.hour)*60*60
		if sec < 0 then sec = sec + 24*60*60 end
		data[2] = sec
	else
		data[2] = -1
	end
	self.Scene:GetModScript():SendHangBoss(data, humanid or 0)
end
