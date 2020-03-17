CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.Scene = nil

--bossID 
CurrentSceneScript.BossID = {
	10266000,
	10267000,
	10268000,
}
-----------------------------------------------------------

function CurrentSceneScript:Startup()
	self.SModScript = self.Scene:GetModScript()
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnter")
	_RegSceneEventHandler(SceneEvents.HumanLeaveWorld, "OnHumanLeave")
	_RegSceneEventHandler(SceneEvents.HumanStoryStep,"OnHumanStoryStep")
end

function CurrentSceneScript:Cleanup() 
    
end

function CurrentSceneScript:OnHumanEnter(human)
	self.SModScript:LaunchStory(human)

	local monster_id = "10261000,10262000"
	self:OnSpawnMonster(monster_id)
end

function CurrentSceneScript:OnHumanLeave(human)

end

function CurrentSceneScript:OnHumanStoryStep(id)
	if id == 1102001 then
		self:OnSpawnBoss(self.BossID[1])

	elseif id == 1102002 then
		local monster_id = "10263000,10264000"
		self:OnSpawnMonster(monster_id)

	elseif id == 1102003 then
		self:OnSpawnBoss(self.BossID[2])

	elseif id == 1102004 then
		local monster_id = "10265000"
		self:OnSpawnMonster(monster_id)

	elseif id == 1102005 then
		self:OnSpawnBoss(self.BossID[3])
	end
end

function CurrentSceneScript:OnSpawnMonster(monster_id)
	local data = {}
    local monster_count = "10,10,10,10,10,10,10,10,10,10" 
    local spawn_pos = "283,358,30,0.0#306,323,30,0.0#332,289,30,0.0"
	local params = 6

    data[1] = monster_id
    data[2] = monster_count
    data[3] = spawn_pos
	self.SModScript:SpawnMonsterRandom(data,params)
end

function CurrentSceneScript:OnSpawnBoss(boss_id)
	--print("OnSpawnBoss:" .. boss_id)
    local spawn_pos = "283,358,30,0.0#306,323,30,0.0#332,289,30,0.0"
	local params = 6
    
    local data = {}
    data[1] = boss_id
    data[2] = 1
    data[3] = spawn_pos
	self.SModScript:SpawnMonsterRandom(data,params)
end
