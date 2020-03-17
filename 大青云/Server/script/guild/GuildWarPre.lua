CurrentSceneScript = {}
CurrentSceneScript.Close = false
CurrentSceneScript.Succ = false
CurrentSceneScript.GardInfo = {
	id = 10000017,
	x = 15,
	y = 103,
}

function CurrentSceneScript:Startup()
	_RegSceneEventHandler(SceneEvents.SceneCreated, "OnSceneCreated")
	_RegSceneEventHandler(SceneEvents.MonsterKilled,"OnMonsterKilled", {param1 = self.GardInfo.id})
	_RegSceneEventHandler(SceneEvents.GuildActivityClose, "OnGuildWarClosed")
	_RegSceneEventHandler(SceneEvents.HumanLeaveWorld, "OnHumanLeave");
end

function CurrentSceneScript:Cleanup() 
	
end

function CurrentSceneScript:OnSceneCreated(scene)
	self.Scene:GetModSpawn():Spawn(self.GardInfo.id, self.GardInfo.x, self.GardInfo.y, 0)
end

function CurrentSceneScript:OnMonsterKilled(monster, killer, id)
	if self.Succ then return end
	self.Succ = true;
	self.Scene:GetModScript():OnGuildPreWarResult(0)
end

function CurrentSceneScript:OnGuildWarClosed()
	self.Close = true
	_UnRegSceneEventHandler(self.Scene, SceneEvents.SceneCreated)
	_UnRegSceneEventHandler(self.Scene, SceneEvents.MonsterKilled)
end

function CurrentSceneScript:OnHumanLeave(human)
	if self.Succ then return end
	
	self.Scene:GetModScript():OnGuildPreWarLeave(human)
end

