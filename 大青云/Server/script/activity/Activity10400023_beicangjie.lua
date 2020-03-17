CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.Scene = nil
-----------------------------------------------------------
--北仓界怪物表ID
CurrentSceneScript.BeiCangJieMonster_ID = 1
--初始怪物出生点 
CurrentSceneScript.MonsterBirthPos = 
 {
	 {x=403, z=-502,group=1,boss=1,monster=4},
	 {x=444, z=-456,group=1,boss=1,monster=3},
	 {x=452, z=-426,group=1,boss=1,monster=2},
	 {x=436, z=-355,group=1,boss=0,monster=2},
	 {x=391, z=-330,group=1,boss=0,monster=2},
	 {x=309, z=-334,group=1,boss=0,monster=1},
	 {x=267, z=-381,group=1,boss=0,monster=1},
	 {x=257, z=-452,group=1,boss=0,monster=1},
	 
	 {x=595, z=352,group=2,boss=1,monster=4},
	 {x=682, z=443,group=2,boss=1,monster=3},
	 {x=689, z=540,group=2,boss=1,monster=2},
	 {x=580, z=576,group=2,boss=0,monster=2},
	 {x=511, z=534,group=2,boss=0,monster=2},
	 {x=477, z=483,group=2,boss=0,monster=1},
	 {x=494, z=410,group=2,boss=0,monster=1},
	 {x=575, z=384,group=2,boss=0,monster=1},
	 
	 {x=-446, z=521,group=3,boss=1,monster=4},
	 {x=-396, z=576,group=3,boss=1,monster=3},
	 {x=-390, z=666,group=3,boss=1,monster=2},
	 {x=-460, z=732,group=3,boss=0,monster=2},
	 {x=-532, z=710,group=3,boss=0,monster=2},
	 {x=-566, z=654,group=3,boss=0,monster=1},
	 {x=-583, z=551,group=3,boss=0,monster=1},
	 {x=-526, z=525,group=3,boss=0,monster=1},
 }
 
CurrentSceneScript.teleportPosition = 
 {
	{x = 567, z = 438},
	{x = 354, z = -423},
	{x = -489, z = 583},
}

CurrentSceneScript.birth =
{
	{x=-479,y=619},
	{x=-573,y=555},
	{x=-403,y=693},
	{x=-386,y=587},
	{x=-488,y=726},
	{x=-576,y=661},
	{x=-471,y=517},
	{x=574,y=455},
	{x=575,y=367},
	{x=568,y=555},
	{x=474,y=397},
	{x=472,y=498},
	{x=664,y=399},
	{x=673,y=492},	
	{x=351,y=-514},
	{x=351,y=-344},
	{x=276,y=-466},
	{x=259,y=-341},
	{x=442,y=-465},
	{x=439,y=-383},
	{x=357,y=-423},
}

CurrentSceneScript.Radius = 50
--杀死玩家个数
CurrentSceneScript.KillHumanCnt = 0
--初始的精英怪ID
CurrentSceneScript.InitSmallBossID = 0
-----------------------------------------------------------
math.randomseed(_GetServerTime())
-----------------------------------------------------------
function CurrentSceneScript:Startup()
	self.SModScript = self.Scene:GetModScript()
    _RegSceneEventHandler(SceneEvents.SceneCreated,"OnSceneCreated")
    _RegSceneEventHandler(SceneEvents.SceneDestroy,"OnSceneDestroy")
    _RegSceneEventHandler(SceneEvents.ActivityClose,"OnActivityClose")
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnterWorld")
    _RegSceneEventHandler(SceneEvents.HumanLeaveWorld,"OnHumanLeaveWorld")
    _RegSceneEventHandler(SceneEvents.HumanKilled,"OnHumanKilled")
	_RegSceneEventHandler(SceneEvents.MonsterKilled,"OnMonsterKilled")
	_RegSceneEventHandler(SceneEvents.TimerExpired,"OnTimerExpired")
	_RegSceneEventHandler(SceneEvents.HumanTeleport, "OnHumanTeleport")
	_RegSceneEventHandler(SceneEvents.HumanGatherMushroom, "OnHumanGatherMushroom")
	_RegSceneEventHandler(SceneEvents.HumanRelive, "OnHumanRelive")	
end

function CurrentSceneScript:Cleanup() 
end

function CurrentSceneScript:OnSceneCreated()
	-- 场景创建后 todo:
	local world_lvl = self.SModScript:GetWorldLvl()
	
	if world_lvl == 0 then
		world_lvl = 1
	end

	for i, v in pairs(BeicangjiemonsterConfig) do  
		local worldlvl_start = tonumber(BeicangjiemonsterConfig[i]['worldlvl_start']) 
		local worldlvl_end = tonumber(BeicangjiemonsterConfig[i]['worldlvl_end']) 
		
		if world_lvl >= worldlvl_start and world_lvl <= worldlvl_end then
			self.BeiCangJieMonster_ID = tonumber(i)
			print(self.BeiCangJieMonster_ID)  
		end
    end  
	
	self:InitMonster()
end

--初始化怪物
function CurrentSceneScript:InitMonster()
	local strid = tostring(self.BeiCangJieMonster_ID)
	
	for k,v in pairs(self.MonsterBirthPos) do
		
		local smallbossid_key = 'smallboss'..v.group
		local smallbossid = tonumber(BeicangjiemonsterConfig[strid][tostring(smallbossid_key)])
		local smallboss_num = tonumber(v.boss)	
		
		self.Scene:GetModSpawn():SpawnBatch(smallbossid,smallboss_num,v.x,v.z, self.Radius)		 
		 
		local monsterid_key = 'monster'..v.group	
		local monsterid = tonumber(BeicangjiemonsterConfig[strid][tostring(monsterid_key)])
		local monster_num = tonumber(v.monster)	
		
		self.InitSmallBossID = smallbossid
		self.Scene:GetModSpawn():SpawnBatch(monsterid,monster_num,v.x,v.z, self.Radius) 
	end
end

function CurrentSceneScript:OnSceneDestroy()
end

function CurrentSceneScript:OnHumanEnterWorld(human)
	--设置PK状态
	human:GetModPK():SetPKMod(1, 0)
	--发送最新分数
	human:GetModBeiCangJie():SendBeiCangJieIntegral()
	--发送最新积分数据
	human:GetModBeiCangJie():SendLingZhi()
	--计算BUFF
	human:GetModBeiCangJie():CheckBuff()
	self:OnTimerExpired(0)
end

function CurrentSceneScript:OnHumanLeaveWorld(human)
end

function CurrentSceneScript:OnHumanKilled(human,killer)  
	local killerPlayer = self.SModScript:Unit2Human(killer)
	
	if killerPlayer == nil then
		return 
	end
	
	self.KillHumanCnt = self.KillHumanCnt + 1
	-- 玩家被杀死 
	killerPlayer:GetModBeiCangJie():OnKillHuman(human:GetID(),killer:GetID(),self.KillHumanCnt)
	
end

function CurrentSceneScript:OnActivityClose()
	for k,v in pairs(self.Humans) do
		v:GetModBeiCangJie():OnActivityClose(1)
		--设置PK状态
		v:GetModPK():SetPKMod(0, 0)
	end
	
	--移除所有怪
	self.Scene:RemoveAllMonster()
end

-- 杀怪 
function CurrentSceneScript:OnMonsterKilled(monster,killer,tid)
	local killerPlayer = self.SModScript:Unit2Human(killer)
	
	if killerPlayer == nil then
		return 
	end

	local monstertype = 0
	
	if self.InitSmallBossID == tid then
		monstertype = 2
	else
		monstertype = 1
	end	

	killerPlayer:GetModBeiCangJie():OnKillMonster(tid,monstertype)
end

--每秒触发一次发送怪物数量信息
function CurrentSceneScript:OnTimerExpired(curr)
	for k,v in pairs(self.Humans) do
		v:GetModBeiCangJie():SendMonsterInfo(0,0)
		v:GetModBeiCangJie():SendMapMemInfo()
		break
	end
end

function CurrentSceneScript:OnHumanTeleport(human, x, z)
	local randTeleport = {x , z}
	local teleport = math.random(1, 2)
	human:LuaChangePos(self.teleportPosition[randTeleport[teleport]].x, self.teleportPosition[randTeleport[teleport]].z, self.Radius)
end

function CurrentSceneScript:OnHumanGatherMushroom(human, gatherObject)
	local gatherObjectID = gatherObject:GetConfigID()
	human:GetModBeiCangJie():OnGatherTreasureBox(gatherObjectID)
end

function CurrentSceneScript:OnHumanRelive(human)
	human:GetModBeiCangJie():LuaAddBuff()
	local birthNum = #self.birth
	local birthID = math.random(1, birthNum)	
	human:LuaChangePos(self.birth[birthID].x, self.birth[birthID].y)
end