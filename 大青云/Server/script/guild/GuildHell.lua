CurrentSceneScript = {}
CurrentSceneScript.ModGuildHell = nil
CurrentSceneScript.BossPos = {
	x = -3;
	y = -27;      -- BOSS出生坐标
}

function CurrentSceneScript:Startup()
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld, "OnHumanEnter")
	_RegSceneEventHandler(SceneEvents.HumanKilled,"OnHumanKilled")
	_RegSceneEventHandler(SceneEvents.MonsterEnterWorld, "OnMonsterEnter")
	_RegSceneEventHandler(SceneEvents.MonsterKilled,"OnBossKilled")
	_RegSceneEventHandler(SceneEvents.HumanLeaveWorld, "OnHumanLeave")
end

function CurrentSceneScript:Cleanup() 
	
end

function CurrentSceneScript:OnHumanEnter(human)
	self.ModGuildHell = human:GetModGuildHell()
	self.Scene:GetModSpawn():Spawn(self.ModGuildHell:GetBossId(), self.BossPos.x, self.BossPos.y, 0)
end

function CurrentSceneScript:OnHumanKilled(human, killer)
	self.ModGuildHell:EndGuildHell(1)
end

function CurrentSceneScript:OnMonsterEnter(monster)
	local reducePer = self.ModGuildHell:GetAttrReduce() / 100.0
	monster:ModAttr(20, 1, reducePer, false)	-- maxHp
	monster:ModAttr(28, 1, reducePer, false);	-- atk
end

function CurrentSceneScript:OnBossKilled(boss, killer)
	self.ModGuildHell:EndGuildHell(0)
end
function CurrentSceneScript:OnHumanLeave(human)
	self.ModGuildHell:OnLeave()
end
