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
	{x=-77,y=26,z=1.6},  
	},
	[2] =
	{
	{x=-69,y=-19,z=1.6}, 
	{x=-65,y=68,z=1.6}, 
	},
	[3] =
	{
	{x=-92,y=30,z=1.6}, 
	{x=-49,y=70,z=1.6}, 
	{x=-54,y=1,z=1.6},
	},
	[4] =
	{
	{x=33,y=93,z=1.6}, 
	{x=36,y=-32,z=1.6}, 
	{x=161,y=95,z=1.6},
	{x=166,y=-29,z=1.6},
	},
}

CurrentSceneScript.nbMonsterPos = {	--精英怪出生点
	[1] = {
		{x=-57,y=92,z=0.0}, 
		{x=-31,y=93,z=0.0}, 
		{x=1,y=98,z=0.0}, 
		{x=24,y=102,z=0.0}, 
		{x=50,y=98,z=0.0}, 
		{x=73,y=104,z=0.0}, 
		{x=98,y=-43,z=3.0}, 
		{x=71,y=-41,z=3.0}, 
		{x=44,y=-39,z=3.0}, 
		{x=21,y=-39,z=3.0}, 
		{x=-3,y=-39,z=3.0}, 
		{x=-36,y=-39,z=3.0},
	},
	[2] = {
		{x=-10,y=79,z=1.6}, 
		{x=-8,y=52,z=1.6}, 
		{x=-9,y=29,z=1.6}, 
		{x=-6,y=5,z=1.6}, 
		{x=-11,y=-24,z=1.6}, 
		{x=35,y=81,z=1.6}, 
		{x=29,y=55,z=1.6}, 
		{x=35,y=26,z=1.6}, 
		{x=33,y=-1,z=1.6}, 
		{x=33,y=-28,z=1.6}, 
	},
	[3] = {
		{x=10,y=105,z=1.6}, 
		{x=33,y=60,z=1.6}, 
		{x=38,y=10,z=1.6}, 
		{x=8,y=-36,z=1.6}, 
		{x=-26,y=-78,z=1.6}, 
		{x=89,y=93,z=1.6}, 
		{x=89,y=-22,z=1.6}, 
	},
	[4] = {
		{x=24,y=103,z=1.6}, 
		{x=19,y=72,z=1.6}, 
		{x=22,y=31,z=1.6}, 
		{x=16,y=3,z=1.6}, 
		{x=23,y=-28,z=1.6}, 
		{x=26,y=-56,z=1.6}, 
		{x=167,y=103,z=1.6}, 
		{x=170,y=74,z=1.6}, 
		{x=168,y=45,z=1.6}, 
		{x=168,y=15,z=1.6}, 
		{x=171,y=-17,z=1.6}, 
		{x=172,y=-56,z=1.6}, 
		{x=54,y=104,z=1.6}, 
		{x=79,y=106,z=1.6}, 
		{x=110,y=105,z=1.6}, 
		{x=139,y=105,z=1.6}, 
		{x=58,y=-56,z=1.6}, 
		{x=89,y=-57,z=1.6}, 
		{x=115,y=-58,z=1.6}, 
		{x=148,y=-55,z=1.6}, 
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

