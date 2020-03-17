CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.Scene = nil
CurrentSceneScript.box_dir = 1.5 --宝箱朝向
CurrentSceneScript.box_id  = 131 --宝箱ID
CurrentSceneScript.box_pos = {x=-304, z=-8}

-----------------------------------------------------------

function CurrentSceneScript:Startup()
  self.SModDungeon = self.Scene:GetModDungeon()
  _RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnter")
  _RegSceneEventHandler(SceneEvents.HumanLeaveWorld,"OnHumanLeave")
  _RegSceneEventHandler(SceneEvents.MonsterKilled,"OnBossKilled")
  _RegSceneEventHandler(SceneEvents.HumanStoryStep,"OnHumanStoryStep")
  _RegSceneEventHandler(SceneEvents.DungeonEventResult,"OnDungeonEventResult")
end

function CurrentSceneScript:Cleanup() 
	
end

function CurrentSceneScript:OnHumanEnter(human)
   	local step = human:GetModZhuanZhi():GetStep()
	print("OnHumanEnter"..step)

	if step < 200000 then
		step = 203001
	end

    self:OnNextStory(step)
end

function CurrentSceneScript:OnHumanLeave(human)  
	
end

function CurrentSceneScript:OnBossKilled(boss,killer,id)
	if id == 15000002  then
	    self.SModDungeon:PlayStory(4,"profq1034001") --剧情类型,id
		self:OnNextStory(203002)
	end
end
--对话应签
function CurrentSceneScript:OnHumanStoryStep(step)

end

--对话应签
function CurrentSceneScript:OnDungeonEventResult(step)
	print("OnDungeonEventResult"..step)
	self:CurStepCompleteEvent(step)
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
end

--当前步骤完成触发
function CurrentSceneScript:CurStepCompleteEvent(step)
	if step < 203001 then
		return
	end
	
 	if step == 203002 then
	   --self.Scene:GetModSpawn():SpawnCollection(self.box_id, self.box_pos.x, self.box_pos.z,self.box_dir)
		self.SModDungeon:PlayStory(1,"39") --剧情类型,id
	end
end

--下一步触发
function CurrentSceneScript:NextStepEvent(step)
 	if step == 203001 then
		self.Scene:GetModSpawn():Spawn(15000002, -303,-140,0)
		self.SModDungeon:PlayStory(1,"40") --剧情类型,id
	end
end
