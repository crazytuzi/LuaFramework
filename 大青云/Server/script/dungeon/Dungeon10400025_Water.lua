CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.Scene = nil

-----------------------------------------------------------
CurrentSceneScript.RandBirthPos = 
 {
	 {x=275, z=360},
	 {x=299, z=332},
	 {x=320, z=303},
 }

CurrentSceneScript.TimerTid = 0
CurrentSceneScript.Waves = 0
CurrentSceneScript.kill_monster = 0
CurrentSceneScript.Radius = 50

--总波数
CurrentSceneScript.TotalWaves = 0

--每波怪数量
CurrentSceneScript.EveryWaves = 10

--每波怪总数量
CurrentSceneScript.EveryWavesTotal = 0

--通关时间
CurrentSceneScript.LastTime = 0

--每波怪物索引
CurrentSceneScript.WaveIndex = 0

--当前玩家等级
CurrentSceneScript.WaterLevel = 0
CurrentSceneScript.WaveMonsterNum = 0
-----------------------------------------------------------

function CurrentSceneScript:Startup()
	self.SModScript = self.Scene:GetModScript()
	_RegSceneEventHandler(SceneEvents.SceneCreated,"OnSceneCreated")
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnter")
	_RegSceneEventHandler(SceneEvents.HumanLeaveWorld, "OnHumanLeave")
	_RegSceneEventHandler(SceneEvents.MonsterKilled,"OnMonsterKilled")
end

function CurrentSceneScript:OnSceneCreated()
	self:InitWaterConsts()
end

function CurrentSceneScript:Cleanup() 

end

function CurrentSceneScript:OnHumanEnter(human)
	human:GetModWaterDungeon():SendWaterDupResult()
	self.TimerTid = self.SModScript:CreateTimer(self.LastTime, "WaterDupEnd")
    self.WaterLevel = human:GetLevel()

    self:OnStartWave()
end

function CurrentSceneScript:OnHumanLeave(human)
	self:WaterDupFail()
end

function CurrentSceneScript:OnMonsterKilled(monster,killer,id)
	human = self.SModScript:Unit2Human(killer)
    if human == nil then return end

    self.kill_monster = self.kill_monster + 1
    self.WaveMonsterNum = self.WaveMonsterNum + 1

    if monster:GetMonType() == 1 then 
    	human:GetModWaterDungeon():SendWaves(self.Waves,self.kill_monster)
    end
    
    self.WaterLevel = human:GetLevel()
    if self.kill_monster == self.EveryWavesTotal then
    	self:OnSpawnBoss()

    elseif self.kill_monster > self.EveryWavesTotal then
		self:OnStartWave()

	elseif self.WaveMonsterNum >= self.EveryWaves then
		self.WaveMonsterNum = 0
		self:OnSpawnMon()
	end
end

function CurrentSceneScript:InitWaterConsts()
	local index = tostring(79)

	local water_totalwaves = tonumber(ConstsConfig[index]['val1'])
	local water_everywavenum = tonumber(ConstsConfig[index]['val2'])
	local water_time = tonumber(ConstsConfig[index]['val3'])

	self.TotalWaves = water_totalwaves
	self.EveryWavesTotal = water_everywavenum
	self.LastTime = water_time*60
end

function CurrentSceneScript:OnStartWave()
	self.Waves = self.Waves + 1
	if self.Waves%5 == 0 then
		self.WaveIndex = 0
	end

	self.kill_monster = 0
    self.WaveMonsterNum = 0
    
	self.WaveIndex = self.WaveIndex + 1
	if self.Waves > self.TotalWaves then
		self:WaterDupSucc()
		return
	end

	self:OnSpawnMon()
end

function CurrentSceneScript:OnSpawnMon()
    if self.WaveIndex > 5 then 
		return
	end
    
    local rand_pos = math.random(1, 3)
    local posx = self.RandBirthPos[rand_pos].x
    local posz = self.RandBirthPos[rand_pos].z

	self.Scene:GetModSpawn():SpawnBatch(self:GetMonsterID(), self.EveryWaves, posx, posz, self.Radius)
end

function CurrentSceneScript:OnSpawnBoss()
    if self.WaveIndex > 5 then 
		return
	end

    local rand_pos = math.random(1, 3)
    local posx = self.RandBirthPos[rand_pos].x
    local posz = self.RandBirthPos[rand_pos].z

	self.Scene:GetModSpawn():Spawn(self:GetBossID(), posx, posz, 0)
end

function CurrentSceneScript:GetMonsterID()
	local monsterid = 0
	local watermonster_key = 'water_monster'..self.WaveIndex
    
	if LiushuifubenConfig[tostring(self.WaterLevel)] ~= nil then
		monsterid = tonumber(LiushuifubenConfig[tostring(self.WaterLevel)][tostring(watermonster_key)])
	end

	return monsterid
end

function CurrentSceneScript:GetBossID()
	local bossid = 0
	local waterbossid_key = 'water_boss'..self.WaveIndex
    
	if LiushuifubenConfig[tostring(self.WaterLevel)] ~= nil then
		bossid = tonumber(LiushuifubenConfig[tostring(self.WaterLevel)][tostring(waterbossid_key)])
	end

	return bossid
end

function CurrentSceneScript:WaterDupEnd(tid)
	--local RewardParam = tonumber(LiushuifubenConfig[tostring(self.WaterLevel)]['award_coe'])
	self:WaterDupResult(true)
end

function CurrentSceneScript:WaterDupSucc()
	if self.TimerTid > 0 then
		self.SModScript:CancelTimer(self.TimerTid)
	end

	self:WaterDupResult(true)
end

function CurrentSceneScript:WaterDupFail()
	if self.TimerTid > 0 then
		self.SModScript:CancelTimer(self.TimerTid)
	end

	--self:WaterDupResult(false)
end

function CurrentSceneScript:WaterDupResult(result)
	local RewardParam = tonumber(LiushuifubenConfig[tostring(self.WaterLevel)]['award_coe'])

	for k,v in pairs(self.Humans) do
		v:GetModWaterDungeon():SendWaterDupEnd(result, RewardParam)
	end
	--移除所有怪
	self.Scene:RemoveAllMonster()
end
