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
CurrentSceneScript.Monsters = {}
CurrentSceneScript.KilledMonsters = {}

CurrentSceneScript.SpecailWaveTimerId = 0
CurrentSceneScript.SpecialCurrBatch = 0
CurrentSceneScript.SpecialMaxBatch = 0

CurrentSceneScript.ExplodeWaveTimerId = 0
CurrentSceneScript.ExplodeCurrBatch = 0
CurrentSceneScript.ExplodeMaxBatch = 0

CurrentSceneScript.DoubleLiveMonsters = {}
CurrentSceneScript.DoubleLiveTimerId = {}
CurrentSceneScript.DoubleLiveMonster2Monster = {}

CurrentSceneScript.RecoverBoss = 0

function CurrentSceneScript:Startup()
	self.SModScript = self.Scene:GetModScript()
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld, "OnHumanEnter")
	_RegSceneEventHandler(SceneEvents.HumanLeaveWorld, "OnHumanLeave")
	_RegSceneEventHandler(SceneEvents.TimerExpired, "OnTimerExpired")
	_RegSceneEventHandler(SceneEvents.MonsterKilled, "OnMonsterKilled")
end

function CurrentSceneScript:Cleanup() 
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
	
	if self.ExplodeWaveTimerId > 0 then
		self.SModScript:CancelTimer(self.ExplodeWaveTimerId)
		self.ExplodeWaveTimerId = 0
	end
	
	for k, v in pairs(self.DoubleLiveTimerId) do
		if v > 0 then
			self.SModScript:CancelTimer(v)
			self.DoubleLiveTimerId[k] = 0
		end
	end
	
	self.Status = 0
	self.Monsters = {}
	self.KilledMonsters = {}
end

function CurrentSceneScript:OnHumanEnter(human)
end

function CurrentSceneScript:OnHumanLeave()

end

function CurrentSceneScript:SendMonsterIdNum(human)
	local data = {}
	for i, v in pairs(self.KilledMonsters) do
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

	if spawnType[1] == "0" then
		if self.Scene:GetModObjects():GetMonsterSize() == 0  then
			self:QiBingSucc()
			return
		end
	elseif spawnType[1] == "4" or spawnType[1] == "3" then
		if self.SpecialCurrBatch >= self.SpecialMaxBatch  and self.Scene:GetModObjects():GetMonsterSize() == 0  then
			self:QiBingSucc()
			return
		end
	elseif spawnType[1] == "2" then
		if self.ExplodeCurrBatch >= self.ExplodeMaxBatch  and self.Scene:GetModObjects():GetMonsterSize() == 0  then
			self:QiBingSucc()
			return
		end
	elseif spawnType[1] == "1" then
		if self.Scene:GetModObjects():GetMonsterSize() == 0  then
			self:QiBingSucc()
			return
		end
	end
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
			
			if layer == 1 then
				self:OnQiBingStart()				
			else
				self.CounterTid = self.SModScript:CreateTimer(4, "OnQiBingStart")			
			end
		else
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
	self:Cleanup()
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
	self.Status = 0
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
	
	if self.Monsters[tid] then	
		self.Monsters[tid] = self.Monsters[tid] - 1
	end

	if spawnType == "1" then
		-- 双生
		self.DoubleLiveMonsters[tid] = 0
		self.DoubleLiveTimerId[tid] = self.SModScript:CreateTimer(30, "OnDoubleLiveTimer")		
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
	if spawnType[1] == "0" then -- 默认 
		for i,v in pairs(monsterCfgArray)do
			local monsterCfg = split(v, ',')
			local pos = split(position[1], ',')
			local id = tonumber(monsterCfg[1])
			local num = tonumber(monsterCfg[2])
			self.Scene:GetModSpawn():SpawnBatch(id, num, tonumber(pos[1]), tonumber(pos[2]), range)
			self.Monsters[id] = num
		end
	elseif spawnType[1] == "1" then -- 同时刷出
		local tempMonster = {}
		
		for i,v in pairs(monsterCfgArray)do
			local monsterCfg = split(v, ',')
			local pos = split(position[i], ',')
			local id = tonumber(monsterCfg[1])
			local num = tonumber(monsterCfg[2])
			self.Scene:GetModSpawn():SpawnBatch(id, num, tonumber(pos[1]), tonumber(pos[2]), range)
			self.Monsters[id] = num
			
			self.DoubleLiveMonsters[id] = 1
			tempMonster[i] = id
		end
		
		self.DoubleLiveMonster2Monster[tempMonster[1]] = tempMonster[2]	
		self.DoubleLiveMonster2Monster[tempMonster[2]] = tempMonster[1]
	elseif spawnType[1] == "4" or spawnType[1] == "3" then -- 特殊类型
		local param = layerConf['param']
		local paramArrays = split(param, "#")
		self.SpecialCurrBatch = 1
		self.SpecialMaxBatch = #monsterCfgArray
		local cmd = split(paramArrays[self.SpecialCurrBatch], ",")
		if cmd[1] == "0" then
			local monsterCfg = split(monsterCfgArray[self.SpecialCurrBatch], ',')
			local pos = split(position[1], ',')
			local id = tonumber(monsterCfg[1])
			local num = tonumber(monsterCfg[2])
			self.Scene:GetModSpawn():SpawnBatch(id, num, tonumber(pos[1]), tonumber(pos[2]), range)
			self.Monsters[id] = num
			
			if spawnType[1] == "3" then
				self.RecoverBoss = id
			end
		end
		cmd = split(paramArrays[self.SpecialCurrBatch+1], ",")
		if cmd[1] == "3" then
			local waveGap = cmd[2]
			self.SpecailWaveTimerId = self.SModScript:CreateTimer(waveGap, "OnSpecailWaveTimer")
		end
	elseif spawnType[1] == "2" then -- 自爆类型
		local param = layerConf['param']
		local paramArrays = split(param, "#")
		self.ExplodeCurrBatch = 1
		self.ExplodeMaxBatch = #monsterCfgArray / 2
		local cmd = split(paramArrays[self.ExplodeCurrBatch], ",")
		if cmd[1] == "0" then
			for i = 1, 2 do
				local monsterCfg = split(monsterCfgArray[(self.ExplodeCurrBatch-1)*2+i], ',')
				local pos = split(position[1], ',')
				local id = tonumber(monsterCfg[1])
				local num = tonumber(monsterCfg[2])
				self.Scene:GetModSpawn():SpawnBatch(id, num, tonumber(pos[1]), tonumber(pos[2]), range)
				self.Monsters[id] = num
			end
		end
		cmd = split(paramArrays[self.ExplodeCurrBatch+1], ",")
		if cmd[1] == "3" then
			local waveGap = cmd[2]
			self.SpecailWaveTimerId = self.SModScript:CreateTimer(waveGap, "OnExplodeWaveTimer")
		end
	
	end
end

function CurrentSceneScript:OnSpecailWaveTimer(tid)
	self.SpecailWaveTimerId = 0
	local layerConf = RidedungeonConfig[tostring(self.CurrLayer)]
	local spawnType = split(layerConf['monsterType'], ',')
	local monsterCfgs = layerConf['monster']
	local position = split(layerConf['position'], '#')
	local monsterCfgArray = split(monsterCfgs, '#')
	local range = layerConf['range']
	
	if (spawnType[1] == "4" or spawnType[1] == "3") and (monsterCfgArray[self.SpecialCurrBatch+1] ~= nil) then --特殊类型
		local param = layerConf['param']
		local paramArrays = split(param, "#")
		
		self.SpecialCurrBatch = self.SpecialCurrBatch + 1
		
		cmd = split(paramArrays[self.SpecialCurrBatch], ",")
		if cmd[1] == "3" then
			local monsterCfg = split(monsterCfgArray[self.SpecialCurrBatch], ',')
			local pos = split(position[1], ',')
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

function CurrentSceneScript:OnExplodeWaveTimer(tid)
	self.ExplodeWaveTimerId = 0
	local layerConf = RidedungeonConfig[tostring(self.CurrLayer)]
	local spawnType = split(layerConf['monsterType'], ',')
	local monsterCfgs = layerConf['monster']
	local position = split(layerConf['position'], '#')
	local monsterCfgArray = split(monsterCfgs, '#')
	local range = layerConf['range']
	
	if (spawnType[1] == "2") and (monsterCfgArray[self.ExplodeCurrBatch*2-1] ~= nil) and  (monsterCfgArray[self.ExplodeCurrBatch*2] ~= nil) then --特殊类型
		local param = layerConf['param']
		local paramArrays = split(param, "#")
		
		self.ExplodeCurrBatch = self.ExplodeCurrBatch + 1
		
		cmd = split(paramArrays[self.ExplodeCurrBatch], ",")
		if cmd[1] == "3" then
			for i = 1, 2 do
				local monsterCfg = split(monsterCfgArray[(self.ExplodeCurrBatch-1)*2+i], ',')
				local pos = split(position[1], ',')
				local id = tonumber(monsterCfg[1])
				local num = tonumber(monsterCfg[2])
				self.Scene:GetModSpawn():SpawnBatch(id, num, tonumber(pos[1]), tonumber(pos[2]), range)
				if self.Monsters[id] ~= nil then
					self.Monsters[id] = self.Monsters[id] + num
				else
					self.Monsters[id] = num
				end
			end
		end
		if paramArrays[self.ExplodeCurrBatch+1] == nil then return end
		cmd = split(paramArrays[self.ExplodeCurrBatch+1], ",")
		if cmd[1] == "3" then
			local waveGap = cmd[2]
			self.ExplodeWaveTimerId = self.SModScript:CreateTimer(waveGap, "OnExplodeWaveTimer")
		end
		
	end
end

function CurrentSceneScript:OnDoubleLiveTimer(tid)
	local monsterID = 0
	
	for i, v in pairs(self.DoubleLiveTimerId) do
		if v == tid then
			monsterID = i
		end
	end
	
	local anotherMonster = self.DoubleLiveMonster2Monster[monsterID]
	
	if self.DoubleLiveMonsters[anotherMonster] == 0 then
		return
	end
	
	local layerConf = RidedungeonConfig[tostring(self.CurrLayer)]
	local spawnType = split(layerConf['monsterType'], ',')
	local monsterCfgs = layerConf['monster']
	local position = split(layerConf['position'], '#')
	local monsterCfgArray = split(monsterCfgs, '#')
	local range = layerConf['range']
	
	for i,v in pairs(monsterCfgArray)do
		local monsterCfg = split(v, ',')
		local pos = split(position[i], ',')
		local id = tonumber(monsterCfg[1])
		local num = tonumber(monsterCfg[2])
		
		if id == monsterID then
			self.Scene:GetModSpawn():SpawnBatch(id, num, tonumber(pos[1]), tonumber(pos[2]), range)
			
			self.KilledMonsters[id] = 0
			self.Monsters[id] = num
		end
	end
	
	self.DoubleLiveMonsters[monsterID] = 1
	self.DoubleLiveTimerId[monsterID] = 0

	self:SendMonsterIdNum(nil)
end

function CurrentSceneScript:OnHumanEnterEXT(human, layer)
	for k,v in pairs(self.Humans) do
		v:GetRideDupl():OnHumanEnterEXT(layer)
	end
end