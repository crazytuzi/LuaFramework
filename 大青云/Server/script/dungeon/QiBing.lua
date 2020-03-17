--
-- 骑兵副本
--
CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.Scene = nil

CurrentSceneScript.CurrLayer = 0
CurrentSceneScript.TimerTid = 0
CurrentSceneScript.Status = 0
CurrentSceneScript.CounterTid = 0
CurrentSceneScript.CurrWave = 0
CurrentSceneScript.MaxWave = 0
CurrentSceneScript.WaveTimerId = 0

CurrentSceneScript.Monsters = {}
CurrentSceneScript.CurrBatch = 0

CurrentSceneScript.SpecailWaveTimerId = 0
CurrentSceneScript.SpecialCurrBatch = 0
CurrentSceneScript.SpecialMaxBatch = 0

CurrentSceneScript.KilledMonsters = {}

function CurrentSceneScript:Startup()
	self.SModScript = self.Scene:GetModScript()
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld, "OnHumanEnter")
	_RegSceneEventHandler(SceneEvents.HumanLeaveWorld, "OnHumanLeave")
	_RegSceneEventHandler(SceneEvents.TimerExpired, "OnTimerExpired")
	_RegSceneEventHandler(SceneEvents.MonsterKilled, "OnMonsterKilled")
end

function CurrentSceneScript:Cleanup() 
	if self.WaveTimerId > 0 then
		self.SModScript:CancelTimer(self.WaveTimerId)
		self.WaveTimerId = 0
	end
	if self.CounterTid > 0 then
		self.SModScript:CancelTimer(self.CounterTid)
		self.CounterTid = 0
	end
	if self.TimerTid > 0 then
		self.SModScript:CancelTimer(self.TimerTid)
		self.TimerTid = 0
	end
	if self.SpecailWaveTimerId > 0 then
		self.SModScript:CancelTimer(self.SpecailWaveTimerId)
		self.SpecailWaveTimerId = 0
	end
end

function CurrentSceneScript:OnHumanEnter(human)
end

function CurrentSceneScript:OnHumanLeave()

end

function CurrentSceneScript:SendMonsterIdNum(human)
	local data = {}
	for i, v in pairs(self.KilledMonsters) do
		print("id = ", i) 
		print("num = ", v)
		table.insert(data, i)
		table.insert(data, v)
	end
	
	if human ~= nil then
		human:GetRideDupl():SendMonster(data)
	else
		for k,v in pairs(self.Humans) do
			v:GetRideDupl():SendMonster(data)
		end
	end
end

--每秒一次
function CurrentSceneScript:OnTimerExpired(curr)
	if self.Status ~= 2 then return end

	local layerConf = RidedungeonConfig[tostring(self.CurrLayer)]
	if layerConf == nil then return end
	local spawnType = split(layerConf['monsterType'], ',')

	if self.Status == 2 then
		if spawnType[1] == "3" then --定时刷新特殊处理
			if self.CurrWave == self.MaxWave  and self.Scene:GetModObjects():GetMonsterSize() == 0  then
				self:QiBingSucc()
				return
			end
		elseif spawnType[1] == "4" then --特殊类型
			if self.SpecialCurrBatch >= self.SpecialMaxBatch  and self.Scene:GetModObjects():GetMonsterSize() == 0  then
				self:QiBingSucc()
				return
			end
		elseif spawnType[1] == "5" then --
			if self.SpecialCurrBatch == 1  and self.Scene:GetModObjects():GetMonsterSize() == 0  then
				self:QiBingSucc()
				return
			end
		else
			if self.Scene:GetModObjects():GetMonsterSize() == 0  then
				self:QiBingSucc()
				return
			end
		end
	end

	self:CheckHumanDead()
end

function CurrentSceneScript:CheckHumanDead()
	if getTableLen(self.Humans) < 1 then return end

	for k,v in pairs(self.Humans) do
		if v:GetBit(2) ~= 1 then
			return
		end
	end
	self:QiBingFail()
end

function CurrentSceneScript:QiBingStart(human, layer, spwan)
	if self.Status == 0 then
		self.CurrLayer = layer
		self.Status = 1

		if spwan > 0 then
			if self.CounterTid >  0 then
				self.SModScript:CancelTimer(self.CounterTid)
				self.CounterTid = 0
			end
			self.CounterTid = self.SModScript:CreateTimer(1, "OnQiBingStart")
		else
			self.Status = 3
			self:SpawnPortal()
		end
	end

	if spwan == 0 then
		human:GetRideDupl():OnDuplSucc(9999)
	else
		self:SendMonsterIdNum(human)
	end
end

function CurrentSceneScript:SpawnPortal()
	local layerConf = RidedungeonConfig[tostring(self.CurrLayer)]
	if layerConf == nil then return end
	if #layerConf['door_point'] ~= 2 then return end
	self.Scene:GetModSpawn():SpawnPortal(layerConf['portal'], layerConf['door_point'][1], layerConf['door_point'][2], 0)
end

function CurrentSceneScript:OnQiBingStart(tid)
	self.CounterTid = 0

	self.Status = 2
	self:OnSpawnMon()
	local layerConf = RidedungeonConfig[tostring(self.CurrLayer)]
	if layerConf == nil then return end
	self.LastTime = layerConf['time']
	self.TimerTid = self.SModScript:CreateTimer(self.LastTime, "OnQiBingOver")
end

function CurrentSceneScript:QiBingSucc()
	self.Status = 3
	local remain = self.SModScript:GetTimerRemain(self.TimerTid)
	self.SModScript:CancelTimer(self.TimerTid)
	self.TimerTid = 0

	self:SpawnPortal()

	for k,v in pairs(self.Humans) do
		v:GetRideDupl():OnDuplSucc(remain)
	end
end

function CurrentSceneScript:QiBingFail()
	self.Status = 0
	for k,v in pairs(self.Humans) do
		v:GetRideDupl():OnDuplFail()
	end
	self.Scene:RemoveAllMonster()
end
-- Failed TimeOver 
function CurrentSceneScript:OnQiBingOver(tid)
	if self.WaveTimerId > 0 then
		self.SModScript:CancelTimer(self.WaveTimerId)
		self.WaveTimerId = 0
	end
	
	self.Scene:RemoveAllMonster()
	self:QiBingFail()
	return
end

--怪物死亡
function CurrentSceneScript:OnMonsterKilled(monster, killer, tid)
	local killerPlayer = self.SModScript:Unit2Human(killer)
	local layerConf = RidedungeonConfig[tostring(self.CurrLayer)]
	local spawnType = layerConf['monsterType']
	local monsterCfgs = layerConf['monster']
	local position = split(layerConf['position'], '#')
	local monsterCfgArray = split(monsterCfgs, '#')
	local range = layerConf['range']
	
	if self.KilledMonsters[tid] == nil then
		self.KilledMonsters[tid] = 1
	else
		self.KilledMonsters[tid] = self.KilledMonsters[tid] + 1 
	end
	
	self.Monsters[tid] = self.Monsters[tid] - 1

	if spawnType == "2" then --死亡刷新
		if self.Monsters[tid] <= 0 then
			self.CurrBatch = self.CurrBatch + 1
			if monsterCfgArray[self.CurrBatch] ~= nil then
				local monsterCfg = split(monsterCfgArray[self.CurrBatch], ',')
				local pos = split(position[self.CurrBatch], ',')
				local id = tonumber(monsterCfg[1])
				local num = tonumber(monsterCfg[2])
				self.Scene:GetModSpawn():SpawnBatch(id, num, tonumber(pos[1]), tonumber(pos[2]), range)
				self.Monsters[id] = num
			end
		end
	end
	
	if spawnType == "5" then --定时刷出小怪 check 第一个刷新出来的BOSS死亡后
		if tid == 10820035 then
			self:QiBingSucc()
		end
	end
	
	self:SendMonsterIdNum(nil)
end

function CurrentSceneScript:OnSpawnMon()
	if self.Status ~= 2 then return end
	local layerConf = RidedungeonConfig[tostring(self.CurrLayer)]
	local spawnType = split(layerConf['monsterType'], ',')
	local monsterCfgs = layerConf['monster']
	local position = split(layerConf['position'], '#')
	local monsterCfgArray = split(monsterCfgs, '#')
	local range = layerConf['range']
	if spawnType[1] == "0" then --默认
		for i,v in pairs(monsterCfgArray)do
			local monsterCfg = split(v, ',')
			local pos = split(position[1], ',')
			local id = tonumber(monsterCfg[1])
			local num = tonumber(monsterCfg[2])
			self.Scene:GetModSpawn():SpawnBatch(id, num, tonumber(pos[1]), tonumber(pos[2]), range)
			self.Monsters[id] = num
		end
	elseif spawnType[1] == "1" then --同时刷出
		for i,v in pairs(monsterCfgArray)do
			local monsterCfg = split(v, ',')
			local pos = split(position[i], ',')
			local id = tonumber(monsterCfg[1])
			local num = tonumber(monsterCfg[2])
			self.Scene:GetModSpawn():SpawnBatch(id, num, tonumber(pos[1]), tonumber(pos[2]), range)
			self.Monsters[id] = num
		end
	
	elseif spawnType[1] == "2" then --死亡刷新
		self.CurrBatch = 1
		local monsterCfg = split(monsterCfgArray[self.CurrBatch], ',')
		local pos = split(position[self.CurrBatch], ',')
		local id = tonumber(monsterCfg[1])
		local num = tonumber(monsterCfg[2])
		self.Scene:GetModSpawn():SpawnBatch(id, num, tonumber(pos[1]), tonumber(pos[2]), range)
		self.Monsters[id] = num
		
	elseif spawnType[1] == "3" then --定时刷新
		local waveGap = tonumber(spawnType[2])
		self.CurrWave = 1
		local timerMonsterCfg = split(monsterCfgArray[self.CurrWave], ',')
		local id = tonumber(timerMonsterCfg[1])
		local num = tonumber(timerMonsterCfg[2])
		local pos = split(position[self.CurrWave], ',')
		self.MaxWave = #monsterCfgArray
		self.Scene:GetModSpawn():SpawnBatch(id, num, tonumber(pos[1]), tonumber(pos[2]), range)
		self.Monsters[id] = num
		self.WaveTimerId = self.SModScript:CreateTimer(waveGap, "OnWaveTimer")
	elseif spawnType[1] == "4" then --特殊类型
		local param = layerConf['param']
		local paramArrays = split(param, "#")
		self.SpecialCurrBatch = 1
		self.SpecialMaxBatch = #monsterCfgArray
		local cmd = split(paramArrays[self.SpecialCurrBatch], ",")
		if cmd[1] == "0" then
			local monsterCfg = split(monsterCfgArray[self.SpecialCurrBatch], ',')
			local pos = split(position[self.SpecialCurrBatch], ',')
			local id = tonumber(monsterCfg[1])
			local num = tonumber(monsterCfg[2])
			self.Scene:GetModSpawn():SpawnBatch(id, num, tonumber(pos[1]), tonumber(pos[2]), range)
			self.Monsters[id] = num
		end
		cmd = split(paramArrays[self.SpecialCurrBatch+1], ",")
		if cmd[1] == "3" then
			local waveGap = cmd[2]
			self.SpecailWaveTimerId = self.SModScript:CreateTimer(waveGap, "OnSpecailWaveTimer")
		end
	elseif spawnType[1] == "5" then --定时刷出小怪 check 第一个刷新出来的BOSS死亡否
		local param = layerConf['param']
		local paramArrays = split(param, "#")
		self.SpecialCurrBatch = 1
		self.SpecialMaxBatch = #monsterCfgArray
		local cmd = split(paramArrays[self.SpecialCurrBatch], ",")
		if cmd[1] == "0" then
			local monsterCfg = split(monsterCfgArray[self.SpecialCurrBatch], ',')
			local pos = split(position[self.SpecialCurrBatch], ',')
			local id = tonumber(monsterCfg[1])
			local num = tonumber(monsterCfg[2])
			self.Scene:GetModSpawn():SpawnBatch(id, num, tonumber(pos[1]), tonumber(pos[2]), range)
			self.Monsters[id] = num
		end
		cmd = split(paramArrays[self.SpecialCurrBatch+1], ",")
		if cmd[1] == "3" then
			local waveGap = cmd[2]
			self.SpecailWaveTimerId = self.SModScript:CreateTimer(waveGap, "OnSpecailWaveTimer")
		end
	end
end

function CurrentSceneScript:OnWaveTimer(tid)
	self.WaveTimerId = 0
	self.CurrWave = self.CurrWave + 1
	local layerConf = RidedungeonConfig[tostring(self.CurrLayer)]
	local spawnType = split(layerConf['monsterType'], ',')
	local monsterCfgs = layerConf['monster']
	local position = split(layerConf['position'], '#')
	local monsterCfgArray = split(monsterCfgs, '#')
	local range = layerConf['range']
	if spawnType[1] == "3" and monsterCfgArray[self.CurrWave] ~= nil then
		local waveGap = tonumber(spawnType[2])
		local timerMonsterCfg = split(monsterCfgArray[self.CurrWave], ',')
		local id = tonumber(timerMonsterCfg[1])
		local num = tonumber(timerMonsterCfg[2])
		local pos = split(position[self.CurrWave], ',')
		self.Scene:GetModSpawn():SpawnBatch(id, num, tonumber(pos[1]), tonumber(pos[2]), range)
		self.WaveTimerId = self.SModScript:CreateTimer(waveGap, "OnWaveTimer")
		if self.Monsters[id] ~= nil then
			self.Monsters[id] = self.Monsters[id] + num
		else
			self.Monsters[id] = num
		end
	end
end
-- 4, 5特殊类型
function CurrentSceneScript:OnSpecailWaveTimer(tid)
	self.SpecailWaveTimerId = 0
	local layerConf = RidedungeonConfig[tostring(self.CurrLayer)]
	local spawnType = split(layerConf['monsterType'], ',')
	local monsterCfgs = layerConf['monster']
	local position = split(layerConf['position'], '#')
	local monsterCfgArray = split(monsterCfgs, '#')
	local range = layerConf['range']
	
	if (spawnType[1] == "4") and (monsterCfgArray[self.SpecialCurrBatch+1] ~= nil) then --特殊类型
		local param = layerConf['param']
		local paramArrays = split(param, "#")
		
		self.SpecialCurrBatch = self.SpecialCurrBatch + 1
		
		cmd = split(paramArrays[self.SpecialCurrBatch], ",")
		if cmd[1] == "3" then
			local monsterCfg = split(monsterCfgArray[self.SpecialCurrBatch], ',')
			local pos = split(position[self.SpecialCurrBatch], ',')
			local id = tonumber(monsterCfg[1])
			local num = tonumber(monsterCfg[2])
			self.Scene:GetModSpawn():SpawnBatch(id, num, tonumber(pos[1]), tonumber(pos[2]), range)
			if self.Monsters[id] ~= nil then
				self.Monsters[id] = self.Monsters[id] + num
			else
				self.Monsters[id] = num
			end
		
		end
		if paramArrays[self.SpecialCurrBatch+1] == nil then return end
		cmd = split(paramArrays[self.SpecialCurrBatch+1], ",")
		if cmd[1] == "3" then
			local waveGap = cmd[2]
			self.SpecailWaveTimerId = self.SModScript:CreateTimer(waveGap, "OnSpecailWaveTimer")
		end
		
	end
	
	if (spawnType[1] == "5") and (monsterCfgArray[self.SpecialCurrBatch+1] ~= nil) then --定时刷出小怪 check 第一个刷新出来的BOSS死亡否
		
		if self.KilledMonsters[10820035] == 1 then return end;
		local param = layerConf['param']
		local paramArrays = split(param, "#")
		
		self.SpecialCurrBatch = self.SpecialCurrBatch + 1
		
		cmd = split(paramArrays[self.SpecialCurrBatch], ",")
		if cmd[1] == "3" then
			local monsterCfg = split(monsterCfgArray[self.SpecialCurrBatch], ',')
			local pos = split(position[self.SpecialCurrBatch], ',')
			local id = tonumber(monsterCfg[1])
			local num = tonumber(monsterCfg[2])
			self.Scene:GetModSpawn():SpawnBatch(id, num, tonumber(pos[1]), tonumber(pos[2]), range)
			if self.Monsters[id] ~= nil then
				self.Monsters[id] = self.Monsters[id] + num
			else
				self.Monsters[id] = num
			end
		
		end
		if paramArrays[self.SpecialCurrBatch+1] == nil then return end
		cmd = split(paramArrays[self.SpecialCurrBatch+1], ",")
		if cmd[1] == "3" then
			local waveGap = cmd[2]
			self.SpecailWaveTimerId = self.SModScript:CreateTimer(waveGap, "OnSpecailWaveTimer")
		end
		
	end
	
end