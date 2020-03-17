CurrentSceneScript = {}
CurrentSceneScript.Close = false
CurrentSceneScript.Succ = false
CurrentSceneScript.ModScript = nil
CurrentSceneScript.BossPos = {
	id = 0,
	x = -100,
	y = 0,
}
CurrentSceneScript.RecordDamage = {}

function CurrentSceneScript:Startup()
	_RegSceneEventHandler(SceneEvents.SceneCreated, "OnSceneCreated")
	_RegSceneEventHandler(SceneEvents.MonsterKilled,"OnMonsterKilled")
	_RegSceneEventHandler(SceneEvents.GuildActivityClose, "OnBossClose");
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld, "OnHumanEnter");
	_RegSceneEventHandler(SceneEvents.HumanLeaveWorld, "OnHumanLeave");
end

function CurrentSceneScript:Cleanup() 
	self.Humans = nil
	self.ModScript = nil
end

function CurrentSceneScript:OnSceneCreated(scene)
	self.ModScript = self.Scene:GetModScript()
	self.BossPos.id = self.ModScript:GetBossId()
	self.Scene:GetModSpawn():Spawn(self.BossPos.id, self.BossPos.x, self.BossPos.y, 0)
end

function CurrentSceneScript:OnMonsterKilled(monster, killer, id)
	if self.Succ then return end
	if self.BossPos.id ~= id then return end

	self.Succ = true;
	self.ModScript:OnGuildBossKilled(monster)
end

function CurrentSceneScript:OnBossClose()
	self.Close = true
	_UnRegSceneEventHandler(self.Scene, SceneEvents.SceneCreated)
	_UnRegSceneEventHandler(self.Scene, SceneEvents.MonsterKilled)
end

function CurrentSceneScript:OnHumanEnter(human)
	if self.Succ then return end
	
	self.ModScript:OnGuildBossEnter(human)
end

function CurrentSceneScript:OnHumanLeave(human)
	self.ModScript:OnGuildBossLeave(human)
end

