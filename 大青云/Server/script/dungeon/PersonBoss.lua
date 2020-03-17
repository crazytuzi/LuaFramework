CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.Scene = nil

-----------------------------------------------------------
CurrentSceneScript.BossPos = {
	x = -7;
	y = -11;
}

CurrentSceneScript.TimerTid = 0

--个人boss id
CurrentSceneScript.CurPersonBoss = 0

--当前boss
CurrentSceneScript.CurBossId = 0

--通关时间
CurrentSceneScript.LastTime = 0

--boss朝向
CurrentSceneScript.boss_dir = 2.7

-----------------------------------------------------------
function CurrentSceneScript:Startup()
	self.SModScript = self.Scene:GetModScript()
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnter")
	_RegSceneEventHandler(SceneEvents.HumanLeaveWorld, "OnHumanLeave")
	_RegSceneEventHandler(SceneEvents.MonsterKilled,"OnMonsterKilled")
	_RegSceneEventHandler(SceneEvents.StartPersonBoss,"OnStartPersonBoss")
end

function CurrentSceneScript:InitPersonBoss()
	local index = tostring(136)
	local personboss_time = tonumber(ConstsConfig[index]['val2'])
	self.LastTime = personboss_time*60

	if PersonalbossConfig[tostring(self.CurPersonBoss)] ~= nil then
		self.CurBossId = tonumber(PersonalbossConfig[tostring(self.CurPersonBoss)]['bossId'])
	end
end

function CurrentSceneScript:Cleanup()
    
end

function CurrentSceneScript:OnHumanEnter(human)
	human:GetModPersonBoss():OnEnterResult()
end

function CurrentSceneScript:OnHumanLeave(human)
	self:PersonBossResult(1)
end

function CurrentSceneScript:OnMonsterKilled(boss,killer,id)
	 if id == tonumber(self.CurBossId) then
	 	self:PersonBossResult(0)

	 	if self.TimerTid > 0 then
		   self.SModScript:CancelTimer(self.TimerTid)
	    end
	 end
end

function CurrentSceneScript:OnStartPersonBoss(id)
	-- body
	self.CurPersonBoss = id
	self:InitPersonBoss()

	self.TimerTid = self.SModScript:CreateTimer(self.LastTime, "PersonBossOver")
	self.Scene:GetModSpawn():SpawnExt(self.CurBossId, self.BossPos.x, self.BossPos.y, self.boss_dir, 0)
end

function CurrentSceneScript:PersonBossOver(val)
	self:PersonBossResult(1)
end

function CurrentSceneScript:PersonBossResult(result)
	for k,v in pairs(self.Humans) do
		v:GetModPersonBoss():OnPersonBossResult(self.CurPersonBoss,result)
	end

	if result == 1 then
		self.Scene:RemoveAllMonster()
	end
end