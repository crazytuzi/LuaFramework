CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.Scene = nil

CurrentSceneScript.killNum = 0
-----------------------------------------------------------

function CurrentSceneScript:Startup()
  self.SModDungeon = self.Scene:GetModDungeon()
  _RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnter")
  _RegSceneEventHandler(SceneEvents.HumanLeaveWorld,"OnHumanLeave")
  _RegSceneEventHandler(SceneEvents.DungeonRandomEvent,"OnDungeonRandomEvent")
  _RegSceneEventHandler(SceneEvents.MonsterKilled,"OnMonsterKilled")
  _RegSceneEventHandler(SceneEvents.MonsterKilled,"OnBossKilled",{param1 = 10202012})
  _RegSceneEventHandler(SceneEvents.MonsterKilled,"OnBossKilled",{param2 = 10202015})
	_RegSceneEventHandler(SceneEvents.HumanStoryStep,"OnHumanStoryStep")
end

function CurrentSceneScript:Cleanup() 
	
end

function CurrentSceneScript:OnHumanEnter(human)
   self.SModDungeon:LaunchStory(human)
end

function CurrentSceneScript:OnHumanLeave(human)  
	
end

function CurrentSceneScript:GetDropBloodPer(id)
   return 0
end

function CurrentSceneScript:GetRandomEvent(stepid)
   return 0
end

function CurrentSceneScript:OnDungeonRandomEvent(param)  
end

function CurrentSceneScript:OnMonsterKilled(monster,killer,id)
--第一波小怪被杀
  if id == 10202011 then
    self.killNum = self.killNum + 1

    if self.killNum >= 10 then
       --self:OnHumanStoryStep(3601002)
       self.killNum = 0
    end
  end
  
  --第二波小怪被杀
  if id == 10202013 then
    self.killNum = self.killNum + 1

    if self.killNum >= 10 then
       --self:OnHumanStoryStep(3601004)
       self.killNum = 0
    end
  end
  
  
  --第三波小怪被杀
  if id == 10202014 then
    self.killNum = self.killNum + 1

    if self.killNum >= 20 then
	   self.SModDungeon:DungeonBlock("block005",0,false)
	   self.SModDungeon:GetNextStory(601006)
       self:SpawnMuDianZhu()
       self.killNum = 0
    end
  end
end

function CurrentSceneScript:OnBossKilled(boss,killer,id)
--第一波boss被杀
    if id == 10202012 then
	   
    end
--最终大boss
	if id == 10202015 then
      self.SModDungeon:SendHideFallStar(id)
    end
    
end

function CurrentSceneScript:OnHumanStoryStep(id)
	-- 对话Npc后  打开第一个空气墙后 刷第一波怪
   if id == 3601011 then
      self.SModDungeon:DungeonBlock("block001",0,false)
	  local data = {}
      local params = 1

      data[1] = "10202011"  --怪物id  或者boss id
      data[2] = "5,5"		--随机数量
      data[3] = "-35,-577,50,0.0"	--怪物方向
      self.Scene:GetModScript():SpawnMonsterRandom(data,params)
      self.SModDungeon:GetNextStory(601002)
   end
   
	--第一波小怪被杀  打开第二个空气墙  刷第一波boss
   if id == 3601012 then
	  self.SModDungeon:DungeonBlock("block002",0,false)
      self.SModDungeon:GetNextStory(601003)
      local data = {}
      local params = 1

      data[1] = "10202012"
      data[2] = "1"
      data[3] = "108,-692,50,0.0"
      self.Scene:GetModScript():SpawnMonsterRandom(data,params)
   end
   
   --第一波boss 被杀  打开第三个空气墙后 刷第二波怪
   if id == 3601013 then
      self.SModDungeon:DungeonBlock("block003",0,false)
	  self.SModDungeon:GetNextStory(601004)
	  local data = {}
      local params = 1

      data[1] = "10202013"  --怪物id  或者boss id
      data[2] = "5,5"		--随机数量
      data[3] = "-87,-846,50,0.0"	--怪物方向
      self.Scene:GetModScript():SpawnMonsterRandom(data,params)
   end
   
   --第二波怪 被杀  打开第三个空气墙后 刷第三波怪
   if id == 3601014 then
      self.SModDungeon:DungeonBlock("block004",0,false)
	  self.SModDungeon:GetNextStory(601005)
	  local data = {}
      local params = 1

      data[1] = "10202014"  --怪物id  或者boss id
      data[2] = "10,10"		--随机数量
      data[3] = "97,-1056,50,0.0"	--怪物方向
      self.Scene:GetModScript():SpawnMonsterRandom(data,params)
   end

end

function CurrentSceneScript:SpawnMuDianZhu()
  --击杀木殿主
  local bossid = 10202015
  local xpos = 397
  local ypos = -1343
  self.Scene:GetModSpawn():Spawn(bossid, xpos, ypos, 0)
end