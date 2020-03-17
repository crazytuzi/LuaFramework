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
  _RegSceneEventHandler(SceneEvents.MonsterKilled,"OnBossKilled",{param1 = 10202405})
  _RegSceneEventHandler(SceneEvents.MonsterKilled,"OnBossKilled",{param2 = 10202406})
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
  if id == 10202404 then
    self.killNum = self.killNum + 1

    if self.killNum >= 20 then
       self:SpawnMuDianZhu()
       self.killNum = 0
    end
  end
end

function CurrentSceneScript:OnBossKilled(boss,killer,id)
    if id == 10202406 then
       self.SModDungeon:GetNextStory(301005)
    end

    self.SModDungeon:SendHideFallStar(id)
end

function CurrentSceneScript:OnHumanStoryStep(id)
   if id == 3301001 then
      self.SModDungeon:DungeonBlock("block001",0,false)
      self.SModDungeon:GetNextStory(301002)
   end
   if id == 1301002 then
      local data = {}
      local params = 1

      data[1] = "10202401"
      data[2] = "10,10"
      data[3] = "288,572,50,0.0"
      self.Scene:GetModScript():SpawnMonsterRandom(data,params)
   end
   if id == 1301003 then
      local data = {}
      local params = 1

      data[1] = "10202402"
      data[2] = "10,10"
      data[3] = "586,222,50,0.0"
      self.Scene:GetModScript():SpawnMonsterRandom(data,params)
   end
   if id == 1301004 then
      local data = {}
      local monster_dir = 3.09
      data[1] = 10202406
      data[2] = 1
      data[3] = 238
      data[4] = -637
      self.Scene:GetModScript():SpawnMonster(data,monster_dir)
   end
   if id == 3201005 then
      self.SModDungeon:DungeonBlock("block002",0,false)
      self.SModDungeon:GetNextStory(301006)
   end
   if id == 1201006 then
      local data = {}
      local params = 1

      data[1] = "10202403"
      data[2] = "10,10"
      data[3] = "-79,-186,50,0.0"
      self.Scene:GetModScript():SpawnMonsterRandom(data,params)
   end
   if id == 1201007 then
      local data = {}
      local params = 1

      data[1] = "10202404"
      data[2] = "10,10"
      data[3] = "-624,-208,50,0.0"
      self.Scene:GetModScript():SpawnMonsterRandom(data,params)
   end
end

function CurrentSceneScript:SpawnMuDianZhu()
  --击杀木殿主
  local bossid = 10202405
  local xpos = -509
  local ypos = 526
  self.Scene:GetModSpawn():Spawn(bossid, xpos, ypos, 0)
end
