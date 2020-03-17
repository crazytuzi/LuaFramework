CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.Scene = nil

CurrentSceneScript.BossTotalCount = 0
CurrentSceneScript.CurrentBossID = 0
CurrentSceneScript.KillMosterCount = 0
CurrentSceneScript.MosterCount = 0

CurrentSceneScript.BossPos = { --boss  出生点
	[1] = 
	{
	{x=-6,y=-53,z=1.6},  
	},
	[2] =
	{
	{x=-62,y=-48,z=1.6}, 
	{x=53,y=-50,z=1.6}, 
	},
	[3] =
	{
	{x=-62,y=-48,z=1.6}, 
	{x=53,y=-50,z=1.6},
	{x=-6,y=-100,z=1.6},
	},
	[4] =
	{
	{x=-81,y=-51,z=1.6}, 
	{x=75,y=67,z=1.6}, 
	{x=75,y=-52,z=1.6},
	{x=-82,y=67,z=1.6},
	},
}

CurrentSceneScript.nbMonsterPos = {	--精英怪出生点
	[1] = {
		{x=-90,y=73,z=0.0}, 
		{x=-91,y=51,z=0.0}, 
		{x=-90,y=27,z=0.0}, 
		{x=-90,y=0,z=0.0}, 
		{x=-89,y=-26,z=0.0}, 
		{x=-89,y=-54,z=0.0}, 
		{x=87,y=78,z=3.0}, 
		{x=87,y=52,z=3.0}, 
		{x=87,y=29,z=3.0}, 
		{x=87,y=1,z=3.0}, 
		{x=87,y=-29,z=3.0}, 
		{x=87,y=-58,z=3.0},
	},
	[2] = {
		{x=-90,y=73,z=0.0}, 
		{x=-91,y=51,z=0.0}, 
		{x=-90,y=27,z=0.0}, 
		{x=-90,y=0,z=0.0}, 
		{x=-89,y=-26,z=0.0}, 
		{x=-89,y=-54,z=0.0}, 
		{x=87,y=78,z=3.0}, 
		{x=87,y=52,z=3.0}, 
		{x=87,y=29,z=3.0}, 
		{x=87,y=1,z=3.0}, 
		{x=87,y=-29,z=3.0}, 
		{x=87,y=-58,z=3.0},
		{x=-57,y=-57,z=3.0},
		{x=-30,y=-58,z=3.0},
		{x=-5,y=-59,z=3.0},
		{x=23,y=-59,z=3.0},
		{x=53,y=-60,z=3.0},
	},
	[3] = {
		{x=-89,y=-54,z=0.0}, 
		{x=87,y=-58,z=3.0},
		{x=-57,y=-57,z=3.0},
		{x=-30,y=-58,z=3.0},
		{x=-5,y=-59,z=3.0},
		{x=23,y=-59,z=3.0},
		{x=53,y=-60,z=3.0},
		{x=-90,y=-20,z=0.0}, 
		{x=-57,y=-21,z=3.0},
		{x=-28,y=-21,z=3.0},
		{x=-3,y=-22,z=3.0},
		{x=25,y=-23,z=3.0},
		{x=57,y=-23,z=3.0},
		{x=86,y=-23,z=3.0},
	},
	[4] = {
		{x=-89,y=14,z=1.6}, 
		{x=89,y=11,z=1.6}, 
		{x=-72,y=-4,z=1.6}, 
		{x=-55,y=-25,z=1.6}, 
		{x=-35,y=-43,z=1.6}, 
		{x=55,y=-23,z=1.6}, 
		{x=73,y=-7,z=1.6}, 
		{x=32,y=-42,z=1.6}, 
	},
}
----------------------------------------------------------
function CurrentSceneScript:Startup()
	self.SModScript = self.Scene:GetModScript()
    _RegSceneEventHandler(SceneEvents.MonsterKilled,"OnMonsterKilled")
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnter")
	_RegSceneEventHandler(SceneEvents.HumanLeaveWorld, "OnHumanLeave")
end

function CurrentSceneScript:Cleanup() 
end

function CurrentSceneScript:OnHumanEnter(human)
	self.KillMosterCount = 0
	self:OnSpawnMonster(human)
end

function CurrentSceneScript:OnHumanLeave(human)
	if human == nil then 
		return 
	end
	human:GetModTaoFaTask():OnHumanLeave()
end

function CurrentSceneScript:OnMonsterKilled(boss, killer,id)
	human = self.SModScript:Unit2Human(killer)
    
	if human == nil then 
		return 
	end
	
	self.KillMosterCount = self.KillMosterCount + 1
	local status = false
	if id == tonumber(self.CurrentBossID)  then
		print("xxxxxxxxxxxxxx", self.CurrentBossID,id)
		status = true
	end
	
	human:GetModTaoFaTask():OnMonsterKill(status)
	
	if self.KillMosterCount == self.MosterCount then
		human:GetModTaoFaTask():OnSuccess()
		return
	end
	
end

function CurrentSceneScript:OnSpawnMonster(human)
	if human == nil then 
		return 
	end
	local id  = math.floor(human:GetLevel() / 10)
	if id < 1 then
		return
	end
	--1 刷小怪 2 刷 boss  3 都刷
	local status = math.random(1, 3)
	local monster = TaofaConfig[tostring(id)]['monster']
	local boss = TaofaConfig[tostring(id)]['boss']
	
	local monsterArray = split(monster, '#')
	local bossArray = split(boss, '#')
	
	local monsterIndex = math.random(1, #self.BossPos)
	local bossIndex = math.random(1, #self.nbMonsterPos)
	local monsterNum = #self.nbMonsterPos[monsterIndex]
	local bossNum = #self.BossPos[bossIndex]
	local bossId = bossArray[math.random(1, #bossArray)]
	local monsterId = monsterArray[math.random(1, #monsterArray)]
	self.CurrentBossID = bossId
	self.BossTotalCount = bossNum
	
	if status == 1  then
		self.MosterCount = monsterNum
		human:GetModTaoFaTask():OnMonsterSpawn(0, monsterNum, 0, monsterId)
	end 
	
	if status == 2  then
		self.MosterCount = bossNum
		human:GetModTaoFaTask():OnMonsterSpawn(bossNum, 0, bossId, 0)
	end 
	
	if status == 3  then
		self.MosterCount = bossNum + monsterNum
		human:GetModTaoFaTask():OnMonsterSpawn(bossNum, monsterNum, bossId, monsterId)
	end 
	
	if status == 2 or status == 3 then
		for j = 1,bossNum do
			self.Scene:GetModSpawn():SpawnExt(bossId, self.BossPos[bossIndex][j].x, self.BossPos[bossIndex][j].y, self.BossPos[bossIndex][j].z, 0)
		end
	end
	
	if status == 1 or status == 3 then
		for j = 1,monsterNum do
			self.Scene:GetModSpawn():SpawnExt(monsterId, self.nbMonsterPos[monsterIndex][j].x, self.nbMonsterPos[monsterIndex][j].y, self.nbMonsterPos[monsterIndex][j].z, 0)
		end
	end
	
end

