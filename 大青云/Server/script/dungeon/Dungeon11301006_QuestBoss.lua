CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.Scene = nil

CurrentSceneScript.BossID = nil
CurrentSceneScript.MonsterTotalCount = 5
CurrentSceneScript.WaveTimerID = 0

function CurrentSceneScript:Startup()
	self.SModDungeon = self.Scene:GetModDungeon()
	self.SModScript = self.Scene:GetModScript()
    _RegSceneEventHandler(SceneEvents.MonsterKilled,"OnMonsterKilled")
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnter")
	_RegSceneEventHandler(SceneEvents.HumanLeaveWorld, "OnHumanLeave")
	_RegSceneEventHandler(SceneEvents.QuestFinished, "OnQuestFinished")
end

function CurrentSceneScript:Cleanup() 
end

function CurrentSceneScript:OnHumanEnter(human)
	self:OnSpawnMon()
end

function CurrentSceneScript:OnHumanLeave(human)
	human:GetModDungeon():OnHumanLeave()
end

function CurrentSceneScript:OnQuestFinished(id)
end

function CurrentSceneScript:OnMonsterKilled(boss, killer,id)
	human = self.SModScript:Unit2Human(killer)
    
	if human == nil then 
		return 
	end
	
	if id == self.BossID then
		self:FinishQuest(human, 1410005)
	end
end

function CurrentSceneScript:OnSpawnMon()
	local dungeonConfig = QuestdungeonConfig[tostring(4)]
	local monster = dungeonConfig['monster']
	local position = split(dungeonConfig['position'], '#')
	local range = dungeonConfig['range']
	local monsterArray = split(monster, '#')
	
	local boss = monsterArray[1]
	local bossArray = split(boss, ',')
	local id = tonumber(bossArray[1])
	local num = tonumber(bossArray[2])
	local positionArray = split(position[1], ',')
	self.Scene:GetModSpawn():SpawnBatch(id, num, tonumber(positionArray[1]), tonumber(positionArray[2]), range)
	
	self.BossID = id
	local param = dungeonConfig['param']
	local paramArray = split(param, "#")
	local paramSubArray = split(paramArray[2], ",")
	local time = paramSubArray[2]
	self.WaveTimerID = self.SModScript:CreateTimer(time, "OnWaveTimer")
end

function CurrentSceneScript:OnWaveTimer(tid)
	if self.MonsterTotalCount == 0 then
		return
	end
	
	local dungeonConfig = QuestdungeonConfig[tostring(2)]
	local monster = dungeonConfig['monster']
	local position = split(dungeonConfig['position'], '#')
	local range = dungeonConfig['range']
	local monsterArray = split(monster, '#')
	
	local randMonsterNum = #monsterArray - 1
	
	if randMonsterNum < 1 then
		return
	end
	
	local randID = math.random(1, randMonsterNum)
	local randMonster = monsterArray[1+randID]
	local randMonsterArray = split(randMonster, ',')
	local id = tonumber(randMonsterArray[1])
	local num = tonumber(randMonsterArray[2])
	local positionArray = split(position[1], ',')
	--self.Scene:GetModSpawn():SpawnBatch(id, num, tonumber(positionArray[1]), tonumber(positionArray[2]), range)
	
	local param = dungeonConfig['param']
	local paramArray = split(param, "#")
	local paramSubArray = split(paramArray[2], ",")
	local time = paramSubArray[2]
	self.WaveTimerID = self.SModScript:CreateTimer(time, "OnWaveTimer")
	
	self.MonsterTotalCount = self.MonsterTotalCount - 1
end

function CurrentSceneScript:FinishQuest(human, id)
	human:GetModQuest():SatisfyQuestStatus(id, 0)
	
	if self.WaveTimerID > 0 then
		self.SModScript:CancelTimer(self.WaveTimerID)		
	end
end