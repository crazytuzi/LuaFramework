CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.Scene = nil

-----------------------------------------------------------

function CurrentSceneScript:Startup()
  self.SModDungeon = self.Scene:GetModDungeon()
  _RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnter")
  _RegSceneEventHandler(SceneEvents.HumanLeaveWorld,"OnHumanLeave")
  local param = {}
  param.param1 = 10201306
  _RegSceneEventHandler(SceneEvents.MonsterKilled,"OnBossKilled",param)
	_RegSceneEventHandler(SceneEvents.HumanStoryStep,"OnHumanStoryStep")
  _RegSceneEventHandler(SceneEvents.DungeonRandomEvent,"OnDungeonRandomEvent")
end

function CurrentSceneScript:Cleanup() 
	
end

function CurrentSceneScript:OnHumanEnter(human)
   self.SModDungeon:LaunchStory(human)
end

function CurrentSceneScript:OnHumanLeave(human)  
	
end

function CurrentSceneScript:OnBossKilled(boss,killer,id)
    self.SModDungeon:SendHideFallStar(id)
    self.SModDungeon:GetNextStory(201005)
end

function CurrentSceneScript:GetDropBloodPer(id)
   -- body
   return 0
end

function CurrentSceneScript:OnHumanStoryStep(id)
   if id == 1201001 then
      local data = {}
      local params = 1 --分批刷怪

      data[1] = "10201301" --怪物id
      data[2] = "5,5,5" --怪物数目
      data[3] = "273,424,0,2.16#258,429,0,2.16#275,435,0,2.16#262,442,0,2.16"--出生坐标,随机出生范围
      self.Scene:GetModScript():SpawnMonsterRandom(data,params)
   end
   if id == 3201002 then
       self.SModDungeon:DungeonBlock("block001",0,false)
   end
   if id == 1201003 then
      local data = {}
      local params = 1

      data[1] = "10201302"
      data[2] = "10,10"
      data[3] = "-484,311,50,0.0"
      self.Scene:GetModScript():SpawnMonsterRandom(data,params)      
   end
   if id == 2201004 then
      local data = {}
      local monster_dir = 1.07
      data[1] = 10201306
      data[2] = 1
      data[3] = -579
      data[4] = -140
      self.Scene:GetModScript():SpawnMonster(data,monster_dir)
   end
   if id == 1201005 then
      local data = {}
      local params = 1

      data[1] = "10201303"
      data[2] = "10,10"
      data[3] = "-430,-438,50,0.0"
      self.Scene:GetModScript():SpawnMonsterRandom(data,params)
   end
   if id == 3201006 then
      self.SModDungeon:DungeonBlock("block002",0,false)
   end
   if id == 1201007 then
      local data = {}
      local params = 1

      data[1] = "10201304"
      data[2] = "10,10"
      data[3] = "515,-183,0,1.73#540,-209,0,2.01#562,-182,0,1.07#578,-212,0,2.87#605,-183,0,3.13#621,-207,0,2.21#659,-96,0,0.0#690,-93,0,5.41#701,-70,0,5.84#670,-74,0,4.98"
      self.Scene:GetModScript():SpawnMonsterRandom(data,params)
   end
   if id == 1201008 then
      local data = {}
      local monster_dir = 3.09 --dir
       local params = 5
      data[1] = "10201305"
      data[2] = "1"
      data[3] = "12,-60,1,3.09"
      self.Scene:GetModScript():SpawnMonsterRandom(data,params)
   end
end

--function CurrentSceneScript:OnMonsterBitState(id)
	--设置怪物状态,无敌...
	--self.Scene:GetModScript():SpawnMonsterBit(id,false)
--end

function CurrentSceneScript:GetRandomEvent(stepid)
  return 0
end

function CurrentSceneScript:OnDungeonRandomEvent(param)
  --body
end