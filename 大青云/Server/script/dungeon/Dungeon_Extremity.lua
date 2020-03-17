
CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.Scene = nil

-----------------------------------------------------------
--最大怪物数 少于此数 重刷
CurrentSceneScript.MaxMonster = 20

--数据表里BOSS最大波数
CurrentSceneScript.TotalWaves = 50

--数据表里怪最大波数
CurrentSceneScript.TotalMonsterWaves = 50

--怪物出生点在英雄的多大范围内
CurrentSceneScript.Radius = 50

--当前第几波
CurrentSceneScript.Waves = 0

--限时时间
CurrentSceneScript.LimitSecs = 0

--结束
CurrentSceneScript.EndFlg = 0

--当前杀死的怪物
CurrentSceneScript.BrushMonster = 0

--怪物波数
CurrentSceneScript.MonsterWaves = 0

--BOSS出生点
CurrentSceneScript.BossPos = {x=22, z=-17}

--MonPos出生点
CurrentSceneScript.MonPos = {x=22, z=-17}

--副本类型 0 BOSS  1小怪
CurrentSceneScript.FBType = 0 

CurrentSceneScript.FBType_BOSS = 0 
-----------------------------------------------------------

function CurrentSceneScript:Startup()
	self.SModScript = self.Scene:GetModScript()
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnter")
	_RegSceneEventHandler(SceneEvents.MonsterKilled,"OnMonsterKilled")
	_RegSceneEventHandler(SceneEvents.TimerExpired,"OnTimerExpired")
	_RegSceneEventHandler(SceneEvents.HalfHourTimerExpired,"OnHalfHourTimerExpired")
end

function CurrentSceneScript:InitConsts()
	local index = tostring(84)
	local bossmintue = tonumber(ConstsConfig[index]['val2'])
	local monstermintue = tonumber(ConstsConfig[index]['val3'])
	self.LimitSecs = monstermintue * 60
	if self.FBType == self.FBType_BOSS then
		self.LimitSecs = bossmintue * 60
	end	
	
end

function CurrentSceneScript:Cleanup() 
end

function CurrentSceneScript:OnHumanEnter(human)
	self.Waves = 1
	self.EndFlg = 0
	self.MonsterWaves = 1

	self.FBType = human:GetModExtremity():GetType()
	if self.FBType == self.FBType_BOSS then
		--BOSS
		self:OnSpawnBoss()
	else
		for i = 1, self.MaxMonster, 1 do
			self:OnSpawnMon()
		end 
	end
	
	self:InitConsts()
	self.SModScript:CreateTimer(self.LimitSecs, "OnGameEnd") -- 限时到发放奖励
end

--怪物死亡
function CurrentSceneScript:OnMonsterKilled(monster,killer,tid)
	if self.EndFlg == 1 then
		return
	end
	
	local killerPlayer = self.SModScript:Unit2Human(killer)
	if killerPlayer == nil then
		return 
	end
	
	if self.FBType == self.FBType_BOSS then
		--BOSS
		self:OnNextWaves()
		self:OnSpawnBoss()
	else
		self:OnNextMonsterWaves()
		self:OnSpawnMon()
		killerPlayer:GetModExtremity():OnMonsterKill()
	end 
end

--计算BOSS波数
function CurrentSceneScript:OnNextWaves()
	self.Waves = self.Waves + 1
	if self.Waves > self.TotalWaves then
		self.Waves = 1 
	end
end

--计算Monster波数
function CurrentSceneScript:OnNextMonsterWaves()

	if self.BrushMonster >= self.MaxMonster then
		self.MonsterWaves = self.MonsterWaves + 1
		if self.MonsterWaves > self.TotalMonsterWaves then
			self.MonsterWaves =1 
		end
		self.BrushMonster = 0
	end
end

--刷BOSS
function CurrentSceneScript:OnSpawnBoss()
	if self.EndFlg == 1 then
		return
	end
	
	local id = tostring(self.Waves)
	local bossid = LimitfightConfig[id]['boss_id']
	
	for k,v in pairs(self.Humans) do
		self.Scene:GetModSpawn():Spawn(bossid, self.BossPos.x,self.BossPos.z,0)
	end
end

--刷怪
function CurrentSceneScript:OnSpawnMon()
	if self.EndFlg == 1 then
		return
	end
	
	local id = tostring(self.MonsterWaves)
	local monsterid = LimitfightConfig[id]['monster_id']

	for k,v in pairs(self.Humans) do
		self.BrushMonster = self.BrushMonster + 1
		self.Scene:GetModSpawn():SpawnBatch(monsterid,1,self.MonPos.x,self.MonPos.z,self.Radius)
	end
end

--游戏结束
function CurrentSceneScript:OnGameEnd()
	self.EndFlg = 1
	for k,v in pairs(self.Humans) do
		v:GetModExtremity():OnGameEnd()
	end
end

--每秒触发一次发送怪物数量信息
function CurrentSceneScript:OnTimerExpired(curr)
	for k,v in pairs(self.Humans) do
		if self.FBType == self.FBType_BOSS then
			v:GetModExtremity():SendExtremityBoss()
		else
			v:GetModExtremity():SendExtremityMonster()
		end
	 end
end

function CurrentSceneScript:OnHalfHourTimerExpired(mo,dd,hh,mm)  
	for k,v in pairs(self.Humans) do
		if v:GetModExtremity():GetEndHour() == hh then
			self:OnGameEnd()
		end
	 end
end
