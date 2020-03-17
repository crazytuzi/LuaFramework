CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.Scene = nil

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
     print("haha--------------------------")
   	local step = human:GetModZhuanZhi():GetStep()
	if step == 0 then
		step = 501001
	end
	if step == 501005 then
		step = 502001
	end
	
    self:OnNextStory(step)
end

function CurrentSceneScript:OnHumanLeave(human)  
	
end

function CurrentSceneScript:OnBossKilled(boss,killer,id)
	
	if id == 15000001  then
		self:OnNextStory(501003)	
	end
	
	if id == 15000002  then
		self:OnNextStory(103004)
	end
	
    if id == 15000003  then
		self:OnNextStory(103005)
    end
	
end

function CurrentSceneScript:OnHumanStoryStep(id)
	print("OnHumanStoryStep"..id)
	if id == 502001  then
		for k,v in pairs(self.Humans) do
			v:GetModZhuanZhi():NextScence()
		end
	end
	if id == 503002 then
		self:OnNextStory(503002)
    end
end

--对话应签
function CurrentSceneScript:OnDungeonEventResult(step)
	print("OnDungeonEventResult"..step)
	self:CurStepCompleteEvent(step)
end

--执行下一步剧情
function CurrentSceneScript:OnNextStory(step)

	print("OnNextStory"..step)

	self:CurStepCompleteEvent(step-1)
	self:NextStepEvent(step)
	self.SModDungeon:GetNextStory(step)
end

function CurrentSceneScript:GetStep()
   	for k,v in pairs(self.Humans) do
		return v:GetModZhuanZhi():GetStep()
	end
end

--当前步骤完成触发
function CurrentSceneScript:CurStepCompleteEvent(step)
	if step < 501001 then
		return
	end
	if step == 103002 then
		self.Scene:GetModSpawn():Spawn(15000001,-299,115,0)
	    self.SModDungeon:PlayStory(1,"38") --剧情类型,id
	end
		if step == 103005 then
	    self.SModDungeon:PlayStory(1,"42") --剧情类型,id
	end
end

--下一步触发
function CurrentSceneScript:NextStepEvent(step)
	if step == 103004 then
		self.Scene:GetModSpawn():Spawn(15000002,-419,-6,0)
	end
		
	if step == 103005 then
		self.Scene:GetModSpawn():Spawn(15000003,-297,-157,0)
	end
end


