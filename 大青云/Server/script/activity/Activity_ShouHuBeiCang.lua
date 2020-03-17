CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.MainHuman = nil
CurrentSceneScript.Scene = nil
-----------------------------------------------------------
CurrentSceneScript.BossPos = {	--boss出生点
	x=-338;
	z=7;
}

CurrentSceneScript.RevivePos = { -- 复活点
	[1] = {503, 11},
	[2] = {433, 3},
}

------------------------------------------------------------
CurrentSceneScript.ActivityClose = false

--活动通关时间
CurrentSceneScript.lastTime = 30*60

--活动总波数
CurrentSceneScript.total_waves = 10

--当前波数索引
CurrentSceneScript.cur_wave = 0

--当前波击杀怪累计
CurrentSceneScript.curwave_killmonster = 0

--当前波怪总数
CurrentSceneScript.curwave_totalmonster = 0

--当前波数与玩家等级组id
CurrentSceneScript.cur_siegewave = 0

--场景内击杀普通怪总数
CurrentSceneScript.total_normalmonster = 0

--场景内击杀精英怪总数
CurrentSceneScript.total_nbmonster = 0

--场景内击杀boss总数
CurrentSceneScript.total_boss = 0

--boss朝向
CurrentSceneScript.boss_dir = 3.2

--当前波数怪id,num
CurrentSceneScript.curwave_monster = {}

--玩家死亡次数
CurrentSceneScript.dead_count = {}

--个人击杀玩家数
CurrentSceneScript.kill_human = {}

--个人击杀怪物数
CurrentSceneScript.kill_monster = {}

--击杀boss榜
CurrentSceneScript.killboss_list = {}

-- 随机刷怪点
CurrentSceneScript.rand_spawn_points = 
{
    [1] = { PosX = -469, PosY = 383, Dir = 0 },
    [2] = { PosX = -433, PosY = 315, Dir = 0 },
    [3] = { PosX = -433, PosY = 180, Dir = 0 },
    [4] = { PosX = -335, PosY = 139, Dir = 0 },
    [5] = { PosX = -371, PosY = 185, Dir = 0 },
	[6] = { PosX = -421, PosY = -251, Dir = 0 },
	[7] = { PosX = -440, PosY = -342, Dir = 0 },
	[8] = { PosX = -550, PosY = -383, Dir = 0 },
	[9] = { PosX = -123, PosY = -129, Dir = 0 },
	[10] = { PosX = -123, PosY = -1, Dir = 0 },
	[11] = { PosX = -110, PosY = 150, Dir = 0 },
	[12] = { PosX = -10, PosY = 103, Dir = 0 },
	[13] = { PosX = 64, PosY = 83, Dir = 0 },
	[14] = { PosX = 42, PosY = -67, Dir = 0 },
	[15] = { PosX = 251, PosY = -95, Dir = 0 },
	[16] = { PosX = 324, PosY = -51, Dir = 0 },
	[17] = { PosX = 282, PosY = 129, Dir = 0 },
	[18] = { PosX = 506, PosY = 20, Dir = 0 },
	[19] = { PosX = 584, PosY = 105, Dir = 0 },
	[20] = { PosX = 672, PosY = 5, Dir = 0 },
	[21] = { PosX = 587, PosY = -83, Dir = 0 },
	[22] = { PosX = 746, PosY = 5, Dir = 0 },
	[23] = { PosX = 886, PosY = 2, Dir = 0 },
	[24] = { PosX = 1024, PosY = 4, Dir = 0 },
	[25] = { PosX = 1090, PosY = 38, Dir = 0 },
	[26] = { PosX = 1160, PosY = 40, Dir = 0 },
	[27] = { PosX = 1160, PosY = -26, Dir = 0 },
	[28] = { PosX = 1098, PosY = -35, Dir = 0 },
	[29] = { PosX = -16, PosY = -83, Dir = 0 },
	[30] = { PosX = -56, PosY = 77, Dir = 0 },
	[31] = { PosX = -284, PosY = 128, Dir = 0 },
	[32] = { PosX = -215, PosY = 131, Dir = 0 },
	[33] = { PosX = -215, PosY = 133, Dir = 0 },
	[34] = { PosX = -276, PosY = -133, Dir = 0 },
	[35] = { PosX = -494, PosY = 12, Dir = 0 },
	[36] = { PosX = -489, PosY = 252, Dir = 0 },
	[37] = { PosX = -480, PosY = -191, Dir = 0 },
	[38] = { PosX = 246, PosY = 59, Dir = 0 },
	[39] = { PosX = 177, PosY = -47, Dir = 0 },
	[40] = { PosX = 175, PosY = 69, Dir = 0 },
}

-- 用来存储随机下标集合的全局数组
CurrentSceneScript.GRandSortArray = {}
-- 对从1到一个指定长度的数组下标进行乱序
-- 注意：只能使用全局变量作为返回结果
function CurrentSceneScript:Random_GRandSortArray(length)
    if length <= 0 then 
        return
    end

    -- 清空idx使用表
    local rand_idx_use = {}
    for i=1,length do
	    rand_idx_use[i] = false
    end

    local useRandCnt = 1
    while (useRandCnt <= length) do
        local rand_idx = math.random(1, length)
        if rand_idx_use[rand_idx] == false
        then
            self.GRandSortArray[useRandCnt] = rand_idx

            rand_idx_use[rand_idx] = true
            useRandCnt = useRandCnt + 1
        end
    end
end



function CurrentSceneScript:Startup()
	self.SModScript = self.Scene:GetModScript()

    _RegSceneEventHandler(SceneEvents.SceneCreated,"OnSceneCreated")
    _RegSceneEventHandler(SceneEvents.SceneDestroy,"OnSceneDestroy")
    _RegSceneEventHandler(SceneEvents.ActivityClose,"OnActivityClose")
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnterWorld")
	_RegSceneEventHandler(SceneEvents.HumanLeaveWorld,"OnHumanLeaveWorld")
    _RegSceneEventHandler(SceneEvents.HumanLoginScene,"OnHumanLogin")
	_RegSceneEventHandler(SceneEvents.HumanKilled,"OnHumanKilled")
	_RegSceneEventHandler(SceneEvents.MonsterKilled,"OnMonsterKilled")
	--_RegSceneEventHandler(SceneEvents.HumanRelive, "OnHumanRelive")
end

function CurrentSceneScript:Cleanup() 
	
end

function CurrentSceneScript:OnSceneCreated()
	-- 场景创建后 todo:
	self:OnSpawnMonster()

	--开始攻城boss计时
	self.SModScript:CreateTimer(self.lastTime, "ShouHuBeiCangEnd")
end

function CurrentSceneScript:OnSceneDestroy()
	-- 场景销毁后 todo:
	self.dead_count = {}
	self.kill_human = {}

	self.kill_monster  = {}
	self.killboss_list = {}
	self.curwave_monster = {}
end

function CurrentSceneScript:OnActivityClose()
	self.ActivityClose = true
end

function CurrentSceneScript:OnHumanEnterWorld(human)
	-- 有玩家进来 todo:

	self:NotifyKillWave(human,2)
	self:NotifyClient(human,0)
	self:NotifyKillSceneMon(human,0)

	human:GetModMonSiege():MonSiegeReward()
end

function CurrentSceneScript:OnHumanLeaveWorld(human)  
	-- 有玩家离开 todo:
	human:GetModPK():SetPKMod(0, 0)
end

function CurrentSceneScript:OnHumanLogin(human)
	human:GetModPK():SetPKMod(6, 0)
end

function CurrentSceneScript:OnHumanKilled(human,killer)
	if self.ActivityClose then return end
	killer = self.SModScript:Unit2Human(killer)
    if killer == nil then return end

	if killer:GetObjType() ~= 4 then
		return
	end
    
    local killdata = self:GetKillNumById(killer:GetID(), 1)
    if killdata ~= nil then
    	killdata.num = killdata.num + 1
    	self.kill_human[killer:GetID()] = killdata
    else
    	local newdata = {}
    	newdata.num = 1
    	self.kill_human[killer:GetID()] = newdata
    end

	self:NotifyKillWave(killer,1)
	self:SetDeadCount(human)
end

function CurrentSceneScript:OnMonsterKilled(monster,killer,id)
	human = self.SModScript:Unit2Human(killer)
    if human == nil then return end
    
    self.curwave_killmonster = self.curwave_killmonster + 1
    local monType = monster:GetMonType()
    if monType == 1 then
    	self.total_normalmonster = self.total_normalmonster + 1

    elseif monType == 2 then
        self.total_nbmonster = self.total_nbmonster + 1

    elseif monType == 7 then
     	self.total_boss = self.total_boss + 1
        
        local str = ""
     	local bossdata = {}
     	bossdata.wave = self.cur_wave
     	bossdata.name = human:GetName()
     	self.killboss_list[self.cur_wave] = bossdata

     	self:NotifyClient(human,1)

     	str = str .. "1," .. human:GetID() .. "," .. human:GetName() .. "#" .. "8," .. tostring(monster:GetMonId())
     	_SendNotice(11301, str, self.Scene:GetGameMapID())
    end
     
    local killdata = self:GetKillNumById(human:GetID(), 0)
    if killdata ~= nil then
    	killdata.num = killdata.num + 1
    	self.kill_monster[human:GetID()] = killdata
    else
    	local newdata = {}
    	newdata.num = 1
    	self.kill_monster[human:GetID()] = newdata
    end

    self:NotifyKillWave(human,0)
    self:NotifyKillSceneMon(human,1)

    if self.curwave_killmonster >= tonumber(self.curwave_totalmonster + 1) then
    	self.SModScript:CreateTimer(2, "SpawnMonsterNext")
    end
end

function CurrentSceneScript:SpawnMonsterNext(tid)
	self:OnSpawnMonster()
	
	if self.total_normalmonster < 0 or self.total_nbmonster < 0 or self.total_boss < 0
    then
        print("self.total_normalmonster: "..tostring(self.total_normalmonster)..", self.total_nbmonster: "..tostring(self.total_nbmonster)..", self.total_boss: "..tostring(self.total_boss))
        print( debug.traceback() )
    end

	for i,v in pairs(self.Humans) do
		self:NotifyKillWave(v,2)
		v:GetModMonSiege():MonSiegeInfo(self.total_normalmonster,self.total_nbmonster,self.total_boss)
	end
end

function CurrentSceneScript:NotifyClient(human,send_all)
	local userdata = {}
	for i,v in pairs(self.killboss_list) do
		local kill_list = {}
		kill_list.wave = v.wave
		kill_list.name = v.name
		table.insert(userdata, kill_list)
	end
    
    if send_all == 0 then
    	if human ~= nil then
    		human:GetModMonSiege():MonSiegeKillBossList(userdata)
    	end
    else
		for k,v in pairs(self.Humans) do
			v:GetModMonSiege():MonSiegeKillBossList(userdata)
		end
	end
end

function CurrentSceneScript:NotifyKillWave(human,type)
	if self.cur_wave > self.total_waves then return end
	if type == 0 or type == 1 then
	    human:GetModMonSiege():MonSiegeKillType(type)
	end

    local monster_num = 0
    local human_num   = 0

	local monster_kill = self:GetKillNumById(human:GetID(), 0)
	if monster_kill ~= nil then
		monster_num = monster_kill.num
	end

    local human_kill = self:GetKillNumById(human:GetID(), 1)
	if human_kill ~= nil then
		human_num = human_kill.num
	end
    
    local groupId = self:GetMonGrpID()
    human:GetModMonSiege():MonSiegeWave(self.cur_wave,groupId,monster_num,human_num)
end

function CurrentSceneScript:NotifyKillSceneMon(human,send_all)
    local normal_num    = self.total_normalmonster
    local nbmonster_num = self.total_nbmonster
    local boss_num      = self.total_boss
	
	if normal_num < 0 or nbmonster_num < 0 or boss_num < 0
    then
        print("normal_num: "..tostring(normal_num)..", nbmonster_num: "..tostring(nbmonster_num)..", boss_num: "..tostring(boss_num))
        print( debug.traceback() )
    end

	if send_all == 0 then
		if human ~= nil then
		   human:GetModMonSiege():MonSiegeInfo(normal_num,nbmonster_num,boss_num)
		end
	else
		for k,v in pairs(self.Humans) do
			v:GetModMonSiege():MonSiegeInfo(normal_num,nbmonster_num,boss_num)
		end
	end
end

function CurrentSceneScript:OnSpawnMonster()
	self.cur_wave = self.cur_wave + 1
	if self.cur_wave > self.total_waves then
		--10波怪杀完,结算
		self:OnMonSiegeResult(0)
		return
	end
    
    self.curwave_killmonster = 0
    self.curwave_totalmonster= 0

    self.total_normalmonster = 0
    self.total_nbmonster = 0
    self.total_boss = 0

    self:GetMonsterID()

	local posx = self.BossPos.x
    local posz = self.BossPos.z


    -- 先统计这波怪总数量 curwave_totalmonster，刷怪点数量不能少于这个数量
    for iCurwave,vCurwave in pairs(self.curwave_monster) do
        self.curwave_totalmonster = self.curwave_totalmonster + vCurwave.num
    end

    local randLen = #self.rand_spawn_points
    if randLen < self.curwave_totalmonster then
        print("self.rand_spawn_points: "..tostring(randLen).." is less than curwave_totalmonster: "..tostring(self.curwave_totalmonster).." !")
        return
    end

    -- 对指定刷怪坐标点集合进行乱序
    self:Random_GRandSortArray(randLen)
    -- 刷普通怪和精英怪，注意每个随机位置不能重复
    local GRandSortArrayUse = 1
    for iCurwave,vCurwave in pairs(self.curwave_monster) do
        for iMonster=1, vCurwave.num do
            local rand_idx = self.GRandSortArray[GRandSortArrayUse]
            
            local randPosX  = self.rand_spawn_points[rand_idx].PosX
            local randPosY  = self.rand_spawn_points[rand_idx].PosY
            local randDir   = self.rand_spawn_points[rand_idx].Dir

            self.Scene:GetModSpawn():SpawnExt(vCurwave.id, randPosX, randPosY, randDir, 0)

            GRandSortArrayUse = GRandSortArrayUse + 1

            -- 不能超过随机点的个数
            if GRandSortArrayUse > randLen
            then
                print("for iMonster: GRandSortArrayUse > randLen")
                break
            end
        end -- end for: iMonster

        -- 不能超过随机点的个数
        if GRandSortArrayUse > randLen
        then
            print("for iCurwave: GRandSortArrayUse > randLen")
            break
        end

    end --end for: iCurwave,vCurwave

    local boss_id = self:GetBossID()
    if boss_id > 0 then
    	self.Scene:GetModSpawn():SpawnExt(boss_id, posx, posz, self.boss_dir, 0)
    end
end

function CurrentSceneScript:GetMonGrpID()
	local groupid = 1
	local worldlevel = self.Scene:GetModScript():GetWorldLvl()
	if BeicanggroupConfig[tostring(worldlevel)] ~= nil then
		groupid = tonumber(BeicanggroupConfig[tostring(worldlevel)][tostring('goupId')])
	end

	return groupid
end

function CurrentSceneScript:GetMonsterID()
	local monsterdata = {}
	local nbmonsterdata = {}
    
    self.cur_siegewave = self:GetMonGrpID()*10 + self.cur_wave

    if ShouweibeicangConfig[tostring(self.cur_siegewave)] ~= nil then
    	local normalmonTb = split(ShouweibeicangConfig[tostring(self.cur_siegewave)][tostring('monsterId')], ',')
    	if normalmonTb[1] and normalmonTb[2] then
    		monsterdata.id  = tonumber(normalmonTb[1])
	        monsterdata.num = tonumber(normalmonTb[2])

		    self.curwave_monster[1] = monsterdata
    	end

	    local nbmonTb = split(ShouweibeicangConfig[tostring(self.cur_siegewave)][tostring('nbmonsterId')], ',')
	    if nbmonTb[1] and nbmonTb[2] then
	    	nbmonsterdata.id  = tonumber(nbmonTb[1])
			nbmonsterdata.num = tonumber(nbmonTb[2])

			self.curwave_monster[2] = nbmonsterdata
	    end
	end
end

function CurrentSceneScript:GetBossID()
	local bossid = 0
	if ShouweibeicangConfig[tostring(self.cur_siegewave)] ~= nil then
		local bossTb = split(ShouweibeicangConfig[tostring(self.cur_siegewave)][tostring('bossId')], ',')
		bossid = tonumber(bossTb[1])
	end
    
	return bossid
end

function CurrentSceneScript:GetKillNumById(id,type)
	if type == 1 then
		return self.kill_human[id]
	else
		return self.kill_monster[id]
	end
end

function CurrentSceneScript:ShouHuBeiCangEnd(tid)
	self:OnMonSiegeResult(1)
end

--function CurrentSceneScript:OnHumanRelive(human)
	--local idx = math.random(1, 2)
	--human:LuaChangePos(self.RevivePos[idx][1], self.RevivePos[idx][2])
--end

function CurrentSceneScript:SetDeadCount(human)
    local count = self:GetDeadCount(human:GetID())
    if count <= 5 then
	   --死亡礼包
	   --human:GetModMonSiege():HumanDeadReward()
    end
end

function CurrentSceneScript:GetDeadCount(id)
    local dead_count = 1

	local data = self.dead_count[id]
	if data ~= nil then
		data.count = data.count + 1
		dead_count = data.count
	else
		local newdata = {}
		newdata.count = 1
		self.dead_count[id] = newdata
	end

	return dead_count
end

function CurrentSceneScript:OnMonSiegeResult(result)
	for k,v in pairs(self.Humans) do
		v:GetModMonSiege():MonSiegeResult(self.cur_siegewave,result)
	end

	if result == 0 then
		--活动强制关闭
		self.Scene:ForceCloseAct()
	end
end
