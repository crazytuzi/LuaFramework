CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.MainHuman = nil
CurrentSceneScript.Scene = nil
-----------------------------------------------------------

function CurrentSceneScript:Startup()
	self.SModScript = self.Scene:GetModScript()
    _RegSceneEventHandler(SceneEvents.SceneCreated,"OnSceneCreated")
    _RegSceneEventHandler(SceneEvents.SceneDestroy,"OnSceneDestroy")
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnterWorld")
    _RegSceneEventHandler(SceneEvents.HumanLeaveWorld,"OnHumanLeaveWorld")
	_RegSceneEventHandler(SceneEvents.HumanKilled,"OnHumanKilled")
	_RegSceneEventHandler(SceneEvents.MonsterKilled,"OnBoss1Killed") --1号boss
	--_RegSceneEventHandler(SceneEvents.MonsterKilled,"OnBoss2Killed") --2号boss
	_RegSceneEventHandler(SceneEvents.HitQuestBoss,"OnHitQuestBoss")
end

function CurrentSceneScript:Cleanup() 
	
end

function CurrentSceneScript:OnSceneCreated()
	-- 场景创建后 todo:
	print ("scene created, id=" .. self.Scene:GetBaseMapID())
end

function CurrentSceneScript:OnSceneDestroy()
	-- 场景销毁后 todo:
end

function CurrentSceneScript:OnHumanEnterWorld(human)
	-- 有玩家进来 todo:
	print ("human enter world, id=" .. human:GetID())
end

function CurrentSceneScript:OnHumanLeaveWorld(human)  
	-- 有玩家离开 todo:
	print ("human leave world, id=" .. human:GetID())
end

function CurrentSceneScript:OnHumanKilled(human,killer)  
	-- 玩家别杀死 todo:
end

function CurrentSceneScript:OnBoss1Killed(boss,killer,tid)  
	-- 1号boss被杀死 todo:
	print ("boss1 id=" .. boss:GetID())
end

function CurrentSceneScript:OnBoss2Killed(boss,killer)  
	-- 2号boss被杀死 todo:
	print ("boss2 killed by, id=" .. killer:GetID())
end

function CurrentSceneScript:OnHitQuestBoss(human,boss,curhp,maxhp)
	local perent = (curhp/maxhp)*100
	if perent <= 30 then --boss 30%血触发剧情
		print("OnHitQuestBoss,perent=" .. perent)
		local quest_id = 1001023
		local hasQuest = human:GetModQuest():IsActiveQuest(quest_id)
		if hasQuest then
		   self.Scene:GetModScript():QuestBossEvent(human,boss,quest_id,"q1001023") --param2任务id;param3剧情id
	    end
	end
end
