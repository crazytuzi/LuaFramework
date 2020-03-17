CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.MainHuman = nil
CurrentSceneScript.Scene = nil

CurrentSceneScript.RandBirthPos = 
 {
	 {x=327, z=36},
	 {x=327, z=36},
	 {x=327, z=36},
 }

CurrentSceneScript.Radius = 30
CurrentSceneScript.TimerID = 0

-- 每波怪物的数量
CurrentSceneScript.monsterCountPerWave = 10
-- 击杀几波小怪刷boss
CurrentSceneScript.monsterRefreshBossNum = 0

-- Boss总波数
CurrentSceneScript.TotalBossWave = 0
-- 怪物总波数
CurrentSceneScript.TotalMonsterWave = 0
-- 当前小怪波数
CurrentSceneScript.currentWaveNum = 0
-- 玩家等级
CurrentSceneScript.humanLevel = 0

-- 本波击杀的小怪数量
CurrentSceneScript.currentKillMonsterCount = 0

-- 累计击杀的小怪数量
CurrentSceneScript.totalKillMonsterCount = 0
-- 累计击杀BOSS数量
CurrentSceneScript.KillbossCount = 0
--  当前剩余小怪数量
CurrentSceneScript.currentMonsterCount = 0
--  boss状态
CurrentSceneScript.status = false

function CurrentSceneScript:Startup()
	self.SModScript = self.Scene:GetModScript()
	_RegSceneEventHandler(SceneEvents.SceneCreated,"OnSceneCreated")
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnter")
	_RegSceneEventHandler(SceneEvents.HumanLeaveWorld, "OnHumanLeave")
	_RegSceneEventHandler(SceneEvents.MonsterKilled,"OnMonsterKilled")
	_RegSceneEventHandler(SceneEvents.MonsterLeaveWorld,"OnMonsterLeaveWorld")
end

function CurrentSceneScript:OnSceneCreated()
end

function CurrentSceneScript:Cleanup() 
end

function CurrentSceneScript:OnHumanEnter(human)
	human:GetModWaterDungeon():SendWaterDupResult()
	human:GetModWaterDungeon():SendWaves(1, 0, 0)
	
	local id = tostring(79)
	local totalTime = tonumber(ConstsConfig[id]['val3'])
	self.TimerID = self.SModScript:CreateTimer(totalTime*60, "WaterDupEnd") 
	--Boss总波数
	self.TotalBossWave = tonumber(ConstsConfig[id]['val1']) 
	--小怪总波数
	self.TotalMonsterWave = tonumber(ConstsConfig[id]['val1'])  * tonumber(ConstsConfig[id]['val2']) / self.monsterCountPerWave
	--击杀多少只小怪刷新boss
	self.monsterRefreshBossNum = tonumber(ConstsConfig[id]['val2'])
	
	self.humanLevel = human:GetLevel()
	self:OnStartWave()
end

function CurrentSceneScript:OnHumanLeave(human)
	self:WaterDupFail()
end

function CurrentSceneScript:OnMonsterKilled(monster,killer,id)
	if killer == nil or monster == nil then
		return
	end
	local human = self.SModScript:Unit2Human(killer)
	if human == nil then
		return 
	end
	
	local monsterType = monster:GetMonType()
	local id = tostring(79)
	local bossWave = tonumber(ConstsConfig[id]['val1'])
	local totalWave = bossWave * 2
	
	if monsterType == 1 then
		-- 普通怪
		self.currentKillMonsterCount = self.currentKillMonsterCount + 1
		self.totalKillMonsterCount = self.totalKillMonsterCount + 1 
		self.currentMonsterCount = self.currentMonsterCount - 1
		
		--这个消息跟客户端确认下
		human:GetModWaterDungeon():SendWaves(self.KillbossCount + 1, self.currentKillMonsterCount, self.totalKillMonsterCount)
		
		--小怪小于3个再来一波小怪
		if self.totalKillMonsterCount % self.monsterRefreshBossNum ~= 0  and   self.currentMonsterCount < 3  and  self.currentWaveNum < self.TotalMonsterWave and self.status ~= true then
			self:OnSpawnMon()
			return
		end 
		--刷boss了
		if self.totalKillMonsterCount % self.monsterRefreshBossNum == 0  and self.totalKillMonsterCount ~= 0  then
			self.currentKillMonsterCount = 0
			self:OnSpawnBoss()
			return
		end
		
	-- Boss怪
	elseif monsterType == 7 then
		self.KillbossCount = self.KillbossCount + 1
		--杀完一波重置小怪数量 
		self.status = false
		--杀完所有boss 跟小怪向客户端发送成功消息
		if self.KillbossCount == self.TotalBossWave and  self.totalKillMonsterCount >= self.TotalMonsterWave * self.monsterCountPerWave  and self.currentWaveNum ==  self.TotalMonsterWave  then
			human:GetModWaterDungeon():SendWaves(self.KillbossCount, self.currentKillMonsterCount, self.totalKillMonsterCount)
			self:WaterDupSucc(true)
			return
		end
		
		if self.KillbossCount < self.TotalBossWave then
			--刷一波小怪
			self:OnSpawnMon()
			--这个消息跟客户端确认下
			human:GetModWaterDungeon():SendWaves(self.KillbossCount + 1, self.currentKillMonsterCount, self.totalKillMonsterCount)
		end
	end
	

end

function CurrentSceneScript:OnMonsterLeaveWorld(monster)
end

--时间到了
function CurrentSceneScript:WaterDupEnd(tid)
	if self.KillbossCount == self.TotalBossWave and  self.totalKillMonsterCount == self.TotalMonsterWave * self.monsterCountPerWave then
 		self:WaterDupResult(true)
	else 
		self:WaterDupResult(false)
	end
end

function CurrentSceneScript:WaterDupResult(result)
	local dungeonLevel = math.ceil(self.humanLevel/5)
	local RewardParam = tonumber(LiushuifubenConfig[tostring(dungeonLevel)]['award_coe'])
	
	for k, v in pairs(self.Humans) do
		v:GetModWaterDungeon():SendWaterDupEnd(result, RewardParam)
	end
	
	self.Scene:RemoveAllMonster()
end

function CurrentSceneScript:OnStartWave()
	-- 船上刷出10个小怪
	self:OnSpawnMon()
end

function CurrentSceneScript:OnSpawnMon()
	
	local dungeonLevel = math.ceil(self.humanLevel/5)
	if LiushuifubenConfig[tostring(dungeonLevel)] == nil then
		return
	end
	
	-- 普通怪都一样
	local monsterKey = 'water_monster1'
	local monsterID = tonumber(LiushuifubenConfig[tostring(dungeonLevel)][tostring(monsterKey)])
	if monsterID == nil then
		return 
	end
    local rand_pos = math.random(1, 3)
    local posx = self.RandBirthPos[rand_pos].x
    local posz = self.RandBirthPos[rand_pos].z
	self.Scene:GetModSpawn():SpawnBatch(monsterID, self.monsterCountPerWave, posx, posz, self.Radius)
	--加一波小怪
	self.currentWaveNum = self.currentWaveNum + 1
	self.currentMonsterCount = self.currentMonsterCount + 10
end

function CurrentSceneScript:OnSpawnSpecialMon()
	local dungeonLevel = math.ceil(self.humanLevel/5)
		
	if LiushuifubenConfig[tostring(dungeonLevel)] == nil then
		return
	end
		
	local monsterKey = 'water_special_monster'..self.currentWaveNum
	local monsterString = LiushuifubenConfig[tostring(dungeonLevel)][tostring(monsterKey)]
	local mosterArray = split(monsterString, ',')
	
	for i = 1, 2 do
		local rand_pos = math.random(1, 3)
		local posx = self.RandBirthPos[rand_pos].x
		local posz = self.RandBirthPos[rand_pos].z
		
		local randMonster = math.random(1, 2)
		local monsterID = tonumber(mosterArray[randMonster])
		if monsterID == nil then
			return 
		end
		self.Scene:GetModSpawn():SpawnBatch(monsterID, 1, posx, posz, self.Radius)
	end
	
	if self.MainHuman then
		_SendSysNotice(2060001, self.MainHuman:GetID())
	end
end

function CurrentSceneScript:OnSpawnBoss()
	local dungeonLevel = math.ceil(self.humanLevel/5)
	if LiushuifubenConfig[tostring(dungeonLevel)] == nil then
		return
	end
	local num = (self.KillbossCount + 1) * 2
	local monsterKey = 'water_boss'..num
	local monsterID = tonumber(LiushuifubenConfig[tostring(dungeonLevel)][tostring(monsterKey)])
	if monsterID == nil then
		return 
	end		
	local rand_pos = math.random(1, 3)
	local posx = self.RandBirthPos[rand_pos].x
	local posz = self.RandBirthPos[rand_pos].z
	self.Scene:GetModSpawn():SpawnBatch(monsterID, 1, posx, posz, self.Radius)
	self.status = true
end

function CurrentSceneScript:WaterDupFail()
	if self.TimerID > 0 then
		self.SModScript:CancelTimer(self.TimerID)
	end
end

function CurrentSceneScript:WaterDupSucc()
	if self.TimerID > 0 then
		self.SModScript:CancelTimer(self.TimerID)
	end

	self:WaterDupResult(true)
end