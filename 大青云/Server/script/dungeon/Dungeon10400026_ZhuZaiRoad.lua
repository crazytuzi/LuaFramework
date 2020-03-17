CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.Scene = nil

-----------------------------------------------------------
CurrentSceneScript.MonPos = {
	{x=-4, z=25}
}

--挑战关卡
CurrentSceneScript.ChallengeId = 0

--怪物波数
CurrentSceneScript.Waves = 0

--怪物总波数
CurrentSceneScript.TotalWaves = 0

--挑战每波怪数量
CurrentSceneScript.CurWaveMonNum = 0
CurrentSceneScript.CurWaveBossNum = 0

CurrentSceneScript.TimerTid = 0

--挑战当前怪物
CurrentSceneScript.CurMonId = 0
CurrentSceneScript.CurMonNum = 0

--挑战当前boss
CurrentSceneScript.CurBossId = 0
CurrentSceneScript.CurBossNum = 0

--延时刷怪
CurrentSceneScript.SpawnDelayedSec = 2

--boss朝向
CurrentSceneScript.boss_dir = 2.7
-----------------------------------------------------------
function CurrentSceneScript:Startup()
	self.SModScript = self.Scene:GetModScript()
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnter")
	_RegSceneEventHandler(SceneEvents.HumanLeaveWorld, "OnHumanLeave")
	_RegSceneEventHandler(SceneEvents.MonsterKilled,"OnMonsterKilled")
	_RegSceneEventHandler(SceneEvents.ZhuZaiRoadChallenge, "OnHumanChallenge")
end

function CurrentSceneScript:Cleanup() 
    
end

function CurrentSceneScript:OnHumanEnter(human)
	human:GetModZhuZaiRoad():OnEnterResult()
end

function CurrentSceneScript:OnHumanLeave(human)
	
end

function CurrentSceneScript:OnMonsterKilled(boss,killer,id)    
    if id == tonumber(self.CurBossId) then
       self.CurWaveBossNum = self.CurWaveBossNum+1
    
    elseif id == tonumber(self.CurMonId) then
       self.CurWaveMonNum = self.CurWaveMonNum+1
    end

	if self.CurWaveMonNum >= tonumber(self.CurMonNum) and 
		self.CurWaveBossNum >= tonumber(self.CurBossNum) then

		self:OnSpawnMon()
	end
end

function CurrentSceneScript:OnHumanChallenge(id)
	self.ChallengeId = tostring(id)
	self.TimerTid = self.SModScript:CreateTimer(self:GetChallengeTime(), "ChallengeEnd")
	self.SModScript:CreateTimer(self.SpawnDelayedSec, "OnSpawnMon")
end

function CurrentSceneScript:OnSpawnMon()
	self.Waves = self.Waves + 1

	self:GetRoadMonster()
	self:GetRoadBoss()

	if self.Waves > self.TotalWaves then
		self:ChallengeSucc()
		return
	end

	for k,v in pairs(self.MonPos) do
		self.Scene:GetModSpawn():SpawnBatch(self.CurMonId, self.CurMonNum, v.x, v.z, 30)
		self.Scene:GetModSpawn():SpawnExt(self.CurBossId, v.x, v.z, self.boss_dir, 0)
	end

	self.CurWaveMonNum = 0
end

function CurrentSceneScript:GetRoadMonster()
	if ZhuzairoadConfig[self.ChallengeId] == nil then
		return
	end

	local zhuzairoadData = split(ZhuzairoadConfig[self.ChallengeId]['monster'], '#')

	if zhuzairoadData[self.Waves] ~= nil then
		local zhuzairoadMon  = split(zhuzairoadData[self.Waves], ',')
	    self.CurMonId   = zhuzairoadMon[1]
	    self.CurMonNum  = zhuzairoadMon[2]
	    self.TotalWaves = getTableLen(zhuzairoadData)
	end
end

function CurrentSceneScript:GetRoadBoss()
	if ZhuzairoadConfig[self.ChallengeId] == nil then
		return
	end

	local zhuzairoadData = split(ZhuzairoadConfig[self.ChallengeId]['boss'], '#')
	
    if zhuzairoadData[self.Waves] ~= nil then
    	local zhuzairoadBoss = split(zhuzairoadData[self.Waves], ',')
    	self.CurBossId  = zhuzairoadBoss[1]
        self.CurBossNum = zhuzairoadBoss[2]
    end
end

function CurrentSceneScript:GetChallengeTime()
	local challengeTime = 0
	if ZhuzairoadConfig[self.ChallengeId] ~= nil then
		challengeTime = ZhuzairoadConfig[self.ChallengeId]['level_limit']
	end
	return challengeTime
end

function CurrentSceneScript:ChallengeSucc()
	self.SModScript:CancelTimer(self.TimerTid)
	self:ChallengeResult(1)
end

function CurrentSceneScript:ChallengeEnd(val)
	self.Scene:RemoveAllMonster()
	self:ChallengeResult(0)
end

function CurrentSceneScript:ChallengeResult(result)
	for k,v in pairs(self.Humans) do
		v:GetModZhuZaiRoad():ChallengeResult(self.ChallengeId,result)
		--v:GetModZhuZaiRoad():ChallengeQuit()
	end
end
