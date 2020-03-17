CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.ModScript = {}
CurrentSceneScript.Scene = nil
CurrentSceneScript.box_dir = 1.5 --宝箱朝向
CurrentSceneScript.box_id  = 132 --宝箱ID
CurrentSceneScript.box_pos = {x=54, z=-289}

CurrentSceneScript.killcnt = 0

--时间
CurrentSceneScript.lastTime = 15
-----------------------------------------------------------

function CurrentSceneScript:Startup()
  self.SModDungeon = self.Scene:GetModDungeon()
  _RegSceneEventHandler(SceneEvents.SceneCreated, "OnSceneCreated")
  _RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnter")
  _RegSceneEventHandler(SceneEvents.HumanLeaveWorld,"OnHumanLeave")
  _RegSceneEventHandler(SceneEvents.MonsterKilled,"OnBossKilled")
  _RegSceneEventHandler(SceneEvents.HumanStoryStep,"OnHumanStoryStep")
  _RegSceneEventHandler(SceneEvents.DungeonEventResult,"OnDungeonEventResult")
end

function CurrentSceneScript:OnSceneCreated(scene)
	self.ModScript = self.Scene:GetModScript()
end

function CurrentSceneScript:Cleanup() 
	
end

function CurrentSceneScript:OnHumanEnter(human)
   	local step = human:GetModZhuanZhi():GetStep()
	print("OnHumanEnter"..step)

	if step < 400000 then
		step = 403001
	end
	
	if step < 403005 then
		self.Scene:GetModSpawn():SpawnNpc(20300082,36,19,0)
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
	
	if id == 10100084 and self.killcnt == 10 then
		self:OnNextStory(nextstep)
	end
	
	if id == 10100085 and self.killcnt == 10 then
		self:OnNextStory(nextstep)
	end
	
	if id == 10100085 and self.killcnt == 10 then
		self:OnNextStory(nextstep)
	end
	
	if id == 10100086 then
		self:OnNextStory(nextstep)
	end	
end

function CurrentSceneScript:OnHumanStoryStep(step)

end

--对话应签
function CurrentSceneScript:OnDungeonEventResult(step)
	print("OnDungeonEventResult"..step)
	self:CurStepCompleteEvent(step)
	self:NextStroyClear()
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
	
	if step == 403001 then
		self.Scene:GetModSpawn():SpawnBatch(10100084, 10, -47,124,30)
		self.SModDungeon:PlayStory(1,"49") --剧情类型,id
	end
	
	if step == 403003 then
		self.Scene:GetModSpawn():SpawnBatch(10100085, 10, 109,113,30)
	end
	
	if step == 403009 then
		self.Scene:GetModSpawn():SpawnBatch(10100085, 10, 176,-12,30)
	end
	
	if step == 403010 then
		self.Scene:GetModSpawn():SpawnBatch(10100086, 1, 297,0,20)
	end
	
	if step == 403005 then
		self.Scene:RemoveNpc(20300082)
	end
	
	if step == 403007 then
		self.Scene:GetModSpawn():SpawnNpc(20300090,-186,29,1.12)
		self.SModDungeon:PlayStory(1,"50") --剧情类型,id
	end
	
	if step == 403008 then
		self.Scene:GetModSpawn():SpawnNpc(20300089,-68,-242,2.96)
	end
	
	if step == 403009 then
		self.Scene:GetModSpawn():SpawnNpc(20300091,72,-137,3.17)
		self.SModDungeon:PlayStory(1,"51") --剧情类型,id
	end
	-- if step == 303005 then
		-- self.Scene:GetModSpawn():SpawnBatch(10100084, 1, 54,-289,20)
		-- self.ModScript:CreateTimer(15, "SpawnNbMonsterTimer")
	-- end

	-- if step == 303002 then
		-- self.Scene:GetModSpawn():SpawnBatch(10100079, 15, -17,46,20)
	-- end

	-- if step == 303003 then
		-- self.Scene:GetModSpawn():SpawnBatch(10100080, 15, 11,-116,20)
	-- end
	
	-- if step == 303007 then
		-- self.Scene:GetModSpawn():SpawnBatch(10100085, 1, 54,-289,20)
	-- end
	
	-- if step == 303008 then
		-- self.Scene:GetModSpawn():SpawnCollection(self.box_id, self.box_pos.x, self.box_pos.z,self.box_dir)
	-- end

end

--下一步触发
function CurrentSceneScript:NextStepEvent(step)


end

function CurrentSceneScript:GetStep()
	self.killcnt = self.killcnt + 1
	for k,v in pairs(self.Humans) do
		return v:GetModZhuanZhi():GetStep()
	end
	
	return 0
end

-- function CurrentSceneScript:SpawnNbMonsterTimer(tid)
	-- self.Scene:RemoveAllMonster(10100084)

   	-- local step = self:GetStep()
	-- local nextstep = step + 1
     -- self:OnNextStory(nextstep)
-- end