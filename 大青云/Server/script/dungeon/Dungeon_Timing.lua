CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.Scene = nil

-----------------------------------------------------------
CurrentSceneScript.MonPos = {  		--四个刷怪点
	{x=-109, z=51},
	{x=33, z=180},
	{x=-61, z=-80},
	{x=111, z=53},
}

CurrentSceneScript.LastTime = 15*60
CurrentSceneScript.TotalWaves = 6
CurrentSceneScript.DiffMon = 
{
	[1] = 10206000,
	[2] = 10226000,
	[3] = 10246000,
	[4] = 10266000,
	[5] = 10286000,
}
CurrentSceneScript.DiffBoss = 
{
	[1] = 10216000,
	[2] = 10236000,
	[3] = 10256000,
	[4] = 10276000,
	[5] = 10296000,
}
CurrentSceneScript.SpawnDelay = 3
CurrentSceneScript.Per1SecMonNum = 2   --每秒刷多少个怪
-----------------------------------------------------------
CurrentSceneScript.Waves = 0
CurrentSceneScript.Status = 0
CurrentSceneScript.TimingLv = 0
CurrentSceneScript.TimerTid = 0
CurrentSceneScript.CounterTid = 0
CurrentSceneScript.DelayTimer = 0
CurrentSceneScript.TotalMon = 0
CurrentSceneScript.CurHumanNum = 0
CurrentSceneScript.CurMonID = 0
CurrentSceneScript.IsBoss = false
-----------------------------------------------------------

function CurrentSceneScript:Startup()
	self.SModScript = self.Scene:GetModScript()
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnter")
	_RegSceneEventHandler(SceneEvents.HumanLeaveWorld, "OnHumanLeave")
	_RegSceneEventHandler(SceneEvents.TimerExpired,"OnTimerExpired")
end

function CurrentSceneScript:Cleanup() 
	if self.DelayTimer > 0 then
		self.SModScript:CancelTimer(self.DelayTimer)
		self.DelayTimer = 0
	end
end

function CurrentSceneScript:OnHumanEnter(human)
	if self.Status == 0 then
		self.Status = 1
		self.TimingLv = human:GetLevel()
		self.CounterTid = self.SModScript:CreateTimer(6, "OnTimingStart")
	end

	if human:GetLevel() > self.TimingLv then 
		self.TimingLv = human:GetLevel() 
	end

	local counter_sec = 0 
	if self.CounterTid > 0 then
		counter_sec = self.SModScript:GetTimerRemain(self.CounterTid)
		counter_sec = counter_sec + self.LastTime
	else
		counter_sec = self.SModScript:GetTimerRemain(self.TimerTid)
	end
	human:GetModTiming():SendCounter(counter_sec)
end

function CurrentSceneScript:OnHumanLeave(human)
	
end

function CurrentSceneScript:OnTimerExpired(curr)
	if self.Status ~= 2 then return end
	
	if self.TotalMon > 0 then
		local curNum = self.Per1SecMonNum
		if self.TotalMon < curNum then
			curNum = self.TotalMon
		end
		if self.IsBoss then
			self.Scene:GetModSpawn():SpawnBatch(self.CurMonID, 1, self.MonPos[1].x, self.MonPos[1].z, 40)
		else
			for i,v in ipairs(self.MonPos) do
				if i <= self.CurHumanNum then
					self.Scene:GetModSpawn():SpawnBatch(self.CurMonID, curNum, v.x, v.z, 40)
				end
			end
		end
		
		self.TotalMon = self.TotalMon - curNum
	elseif self.Scene:GetModObjects():GetMonsterSize() == 0  and self.DelayTimer == 0 then
		if self.Waves + 1 > self.TotalWaves then
			self.DelayTimer = 0
			self:TimingSucc()
		else
			self.DelayTimer = self.SModScript:CreateTimer(self.SpawnDelay, "OnSpawnMon")
		end
	end
end

function CurrentSceneScript:OnTimingStart(tid)
	self.CounterTid = 0
	self.Status = 2
	self:OnSpawnMon()
	self.TimerTid = self.SModScript:CreateTimer(self.LastTime, "TimingEnd")
end

function CurrentSceneScript:OnSpawnMon()
	if self.Status ~= 2 then return end
	self.DelayTimer = 0
	self.Waves = self.Waves + 1
	
	self.CurHumanNum = getTableLen(self.Humans)
	if self.Waves%6 ~= 0 then
		self.IsBoss = false
		self.TotalMon = self:GetMonNum()
		self.CurMonID = self:GetMonID()
		self:SendWaves(self.CurHumanNum*self.TotalMon)
	else
		self.IsBoss = true
		self.TotalMon = 1
		self.CurMonID = self:GetBossID()
		self:SendWaves(self.TotalMon)
	end
end

function CurrentSceneScript:GetMonNum()
	local monNum = 0
	local humanCnt = getTableLen(self.Humans)
	local timingID = tostring(self.Scene:GetTimingID())
	
	if MonkeytimeConfig[timingID] ~= nil then
		local cntTb = split(MonkeytimeConfig[timingID]['group_num'], '#')
		monNum = tonumber(cntTb[humanCnt])
	end
	return monNum or 0
end

function CurrentSceneScript:GetMonID()
	local dungeonLevel = math.ceil(self.TimingLv/5)
	local timingID = self.Scene:GetTimingID()
	return self.DiffMon[timingID] + dungeonLevel
end

function CurrentSceneScript:GetBossID()
	local dungeonLevel = math.ceil(self.TimingLv/5)
	local timingID = self.Scene:GetTimingID()
	return self.DiffBoss[timingID] + dungeonLevel
end

function CurrentSceneScript:SendWaves(num)
	local waves = self.Waves - math.floor(self.Waves/6)
	local monID = 0
	if self.Waves%6 ~= 0 then
	else
		waves = 21
	end
	for k,v in pairs(self.Humans) do
		v:GetModTiming():SendWaves(waves, self.CurMonID, num)
	end
end

function CurrentSceneScript:TimingEnd(tid)
	self.Status = 4
	if self.DelayTimer > 0 then
		self.SModScript:CancelTimer(self.DelayTimer)
		self.DelayTimer = 0
	end
	for k,v in pairs(self.Humans) do
		v:GetModTiming():OnTimingEnd(false, 0)
	end
	self.Scene:RemoveAllMonster()
end

function CurrentSceneScript:TimingSucc()
	self.Status = 3
	local remain = self.SModScript:GetTimerRemain(self.TimerTid)
	self.SModScript:CancelTimer(self.TimerTid)
	remain = self.LastTime-remain
	for k,v in pairs(self.Humans) do
		v:GetModTiming():OnTimingEnd(true, remain)
	end
end
