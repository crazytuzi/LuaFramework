CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.ModScript = {}
CurrentSceneScript.Scene = nil
CurrentSceneScript.box_dir = 1.5 --宝箱朝向
CurrentSceneScript.box_id  = 132 --宝箱ID
CurrentSceneScript.box_pos = {x=44, z=-289}

CurrentSceneScript.killcnt = 0

--时间
CurrentSceneScript.lastTime = 15

CurrentSceneScript.timer_tid = 0
-----------------------------------------------------------

function CurrentSceneScript:Startup()
  self.SModDungeon = self.Scene:GetModDungeon()
  _RegSceneEventHandler(SceneEvents.SceneCreated, "OnSceneCreated")
  _RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnter")
  _RegSceneEventHandler(SceneEvents.HumanLeaveWorld,"OnHumanLeave")
  _RegSceneEventHandler(SceneEvents.MonsterKilled,"OnBossKilled")
  _RegSceneEventHandler(SceneEvents.HumanStoryStep,"OnHumanStoryStep")
  _RegSceneEventHandler(SceneEvents.DungeonEventResult,"OnDungeonEventResult")
  _RegSceneEventHandler(SceneEvents.StoryEnd,"OnStoryEnd") 
end

function CurrentSceneScript:OnSceneCreated(scene)
	self.ModScript = self.Scene:GetModScript()
end

function CurrentSceneScript:Cleanup() 
	
end

function CurrentSceneScript:OnHumanEnter(human)
   	local step = human:GetModZhuanZhi():GetStep()
	print("OnHumanEnter"..step)

	if step < 300000 then
		step = 303001
	end
	
	if step >= 303009 then
		step = 303001
	end
	
	if step == 303007 then
		self.Scene:GetModSpawn():SpawnBatch(10100082, 1, 54,-289,40)
	end

    self:OnNextStory(step)
end

function CurrentSceneScript:OnHumanLeave(human)  
	
end

function CurrentSceneScript:OnBossKilled(boss,killer,id)

	local killerPlayer = self.ModScript:Unit2Human(killer)
	if killerPlayer == nil then return end
   	local step = killerPlayer:GetModZhuanZhi():GetStep()
	local nextstep = step + 1
	self.killcnt = self.killcnt + 1
	
	print("OnBossKilled"..id)
	print("OnBossKilled"..self.killcnt)
	
	if id == 10100078 and self.killcnt == 15 then
		self:OnNextStory(nextstep)
	end
	
	if id == 10100079 and self.killcnt == 15 then
		self:OnNextStory(nextstep)
	end
	
	if id == 10100080 and self.killcnt == 15 then
		self:OnNextStory(nextstep)
	end
	
	if id == 10100083 then
		self:OnNextStory(nextstep)
	end	
end
--对话应签
function CurrentSceneScript:OnHumanStoryStep(step)

end

--对话应签
function CurrentSceneScript:OnDungeonEventResult(step)
	print("OnDungeonEventResult"..step)
	self:CurStepCompleteEvent(step)
	self:NextStroyClear()
end

--剧情应签
function CurrentSceneScript:OnStoryEnd(step)
	print("OnStoryEnd1"..step)
	if step ~= 303007 then
		return 
	end
	
	print("OnStoryEnd2"..step)
 	self.ModScript:CancelTimer(self.timer_tid)
	self:SpawnSBMonsterTimer(0)
end

function CurrentSceneScript:GetRandomEvent(step)
  return 0
end

--执行下一步剧情
function CurrentSceneScript:OnNextStory(step)
	print("OnNextStory"..step)
	self:CurStepCompleteEvent(step-1)
	self:NextStepEvent(step)
	self.SModDungeon:GetNextStory(step)
	self:NextStroyClear()
end

function CurrentSceneScript:NextStroyClear()
	self.killcnt = 0
end

--当前步骤完成触发
function CurrentSceneScript:CurStepCompleteEvent(step)
	print("CurStepCompleteEvent"..step)
	if step < 303001 then
		return
	end
	
	if step == 303001 then
		self.Scene:GetModSpawn():SpawnBatch(10100078, 15, -78,205,40)
	end
	
	if step == 303002 then
	    self.SModDungeon:PlayStory(1,"44") --剧情类型,id
	end
	
	if step == 303004 then
		self.SModDungeon:PlayStory(4,"zs103461") --剧情类型,id
		self.Scene:GetModSpawn():SpawnBatch(10100082, 1, 54,-289,40)
	end
	
	if step == 303005 then
	    self.SModDungeon:PlayStory(1,"47") --剧情类型,id
		self.ModScript:CreateTimer(10, "SpawnNbMonsterTimer")
	end

	if step == 303002 then
		self.Scene:GetModSpawn():SpawnBatch(10100079, 15, -17,46,40)
	end

	if step == 303003 then
		self.Scene:GetModSpawn():SpawnBatch(10100080, 15, 11,-116,40)
	end
	
	if step == 303006 then
	    self.SModDungeon:PlayStory(1,"48") --剧情类型,id
	end
	
	if step == 303007 then
	    self.SModDungeon:PlayStory(1,"45") --剧情类型,id
	    self.Scene:RemoveMonster(10100082)
		self.timer_tid = self.ModScript:CreateTimer(6, "SpawnSBMonsterTimer")	
	end
	
	if step == 303008 then
	    self.SModDungeon:PlayStory(4,"zs103463") --剧情类型,id
		self.SModDungeon:PlayStory(1,"46") --剧情类型,id
		self.Scene:GetModSpawn():SpawnCollection(self.box_id, self.box_pos.x, self.box_pos.z,self.box_dir)
	end

end

--下一步触发
function CurrentSceneScript:NextStepEvent(step)

end

function CurrentSceneScript:GetStep()
	for k,v in pairs(self.Humans) do
		return v:GetModZhuanZhi():GetStep()
	end
	
	return 0
end

function CurrentSceneScript:SpawnNbMonsterTimer(tid)
   	local step = self:GetStep()
	
	if step <=0 then
		return
	end
	
	local nextstep = step + 1
     self:OnNextStory(nextstep)
end

function CurrentSceneScript:SpawnSBMonsterTimer(tid)
	self.Scene:GetModSpawn():SpawnBatch(10100083, 1, 54,-289,40)
end