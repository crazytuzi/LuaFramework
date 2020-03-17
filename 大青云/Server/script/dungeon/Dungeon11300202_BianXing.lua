CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.MainHuman = nil
CurrentSceneScript.Scene = nil

----------------------------------------------------------

CurrentSceneScript.BornInfo = {
	[1] = {x=305, y=-93, r=50, num=10, id=10203020}, 	-- 第1关怪物出生点信息
	[2] = {x=305, y=-93, r=50, num=10, id=10203021},	-- 第1关怪物出生点信息
	[3] = {x=305, y=-93, r=50, num=10, id=10203022}, 		-- 第1关怪物出生点信息
	[4] = {num=4, id=10203024,x1=95, y1=-160,x2=12, y2=-158, x3=9, y3=-73, x4=94, y4=-73}, -- 第2关怪物出生点信息
	[5] = {x=70, y=-110, r=50, num=2, id=10203025},		-- 第2关怪物出生点信息
	[6] = {x=70, y=-110, r=0, num=1, id=10203026}, 	-- 第2关怪物出生点信息
	[7] = {x=-432, y=179, r=0, num=1, id=10203023}, -- 第3关怪物出生点信息
}

----------------------------------------------------------

function CurrentSceneScript:Startup()
	self.SModDungeon = self.Scene:GetModDungeon()
	self.SModScript = self.Scene:GetModScript()
	self.Triggered = {}
	self.KillMonsterNum = {}
	self.CurrSpawnRound = 0
	self.CurrSpawnCount = 0
	self.Ended = 0
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnter")
	_RegSceneEventHandler(SceneEvents.HumanLeaveWorld,"OnHumanLeave")
	_RegSceneEventHandler(SceneEvents.MonsterKilled,"OnMonsterKilled")
	_RegSceneEventHandler(SceneEvents.JiGuanTrigger,"OnJiGuanTrigger")
	_RegSceneEventHandler(SceneEvents.DungeonEnded,"OnDungeonEnded")
end

function CurrentSceneScript:Cleanup() 
	
end

function CurrentSceneScript:OnHumanEnter(human)
   self.SModDungeon:LaunchStory(human)
end

function CurrentSceneScript:OnHumanLeave(human)  	
end

function CurrentSceneScript:OnDungeonEnded(succ)
	self.Ended = 1;
	self.Scene:RemoveAllMonster();
end

function CurrentSceneScript:GetDropBloodPer(id)
   return 0
end

function CurrentSceneScript:OnMonsterKilled(monster,killer,id)
	if self.Ended == 1 then
		return
	end
	
	-- 对箱子进行处理
	if id == 10203027 then
		self.SModDungeon:DungeonJiGuanBlock("block001",7001,true,0)
		return
	end
	
	if self.KillMonsterNum[id] == nil then
		return
	end
	
	-- 怪物消灭个数减1
	self.KillMonsterNum[id] = self.KillMonsterNum[id] - 1
	if self.KillMonsterNum[id] > 0 then
		return
	end
	
	-- 怪物全部杀光
	
	--第一关
	if self.CurrSpawnRound >= 1 and self.CurrSpawnRound <= 3 then
		if self.BornInfo[1].id == id then
			self:SpawnMonster(2)	
		elseif self.BornInfo[2].id == id then
			self:SpawnMonster(3)
		elseif self.BornInfo[3].id == id then
			self.SModDungeon:DungeonBlock("block005",7001,false)
		end
	--第二关	
	elseif self.CurrSpawnRound >= 4 and self.CurrSpawnRound <= 6 then
		if self.BornInfo[4].id == id then
			self:SpawnMonster(6)
		elseif self.BornInfo[6].id == id then
			self.SModDungeon:DungeonBlock("block003",7001,false)
		end
	--第三关
	elseif self.CurrSpawnRound == 7 then
		if self.BornInfo[7].id == id then
			--self.SModDungeon:EndedDungeon(true);
		end
	end
end

function CurrentSceneScript:OnJiGuanTrigger(human,id)
	if self.Ended == 1 then
		return
	end
	if self.Triggered[id] then
		return
	end
	local info = JiguanConfig[tostring(id)]
	if info == nil then
		return
	end

	self.Triggered[id] = true
	
	local status = (info.air_wall_status == 1 and true or false)
	self.SModDungeon:DungeonJiGuanBlock(info.air_wall,7001,status,id)

	if info.id == 205 then
		self:SpawnMonster(1)
	elseif info.id == 202 then
		self:SpawnMonster(4)
		self.SModScript:CreateTimer(3, "OnSpawnMonster5Timer")
	elseif info.id == 207 then
		self:SpawnMonster(7)
	end
end

function CurrentSceneScript:OnSpawnMonster5Timer()
	if self.Ended == 1 then
		return
	end
	if self.CurrSpawnRound >= 6 or self.CurrSpawnCount >= 5 then
		return
	end
	self:SpawnMonster(5)
	self.CurrSpawnCount = self.CurrSpawnCount + 1
	self.SModScript:CreateTimer(3, "OnSpawnMonster5Timer")
end

function CurrentSceneScript:SpawnMonster(id)
	if self.Ended == 1 then
		return
	end
	local info = self.BornInfo[id]
	if info then
		if id == 4 then
			self.Scene:GetModSpawn():SpawnExt(info.id, info.x1, info.y1, 3.967, 0)
			self.Scene:GetModSpawn():SpawnExt(info.id, info.x2, info.y2, 2.101, 0)
			self.Scene:GetModSpawn():SpawnExt(info.id, info.x3, info.y3, 0.664, 0)
			self.Scene:GetModSpawn():SpawnExt(info.id, info.x4, info.y4, 4.901, 0)
		elseif info.id == 6 then
			self.Scene:GetModSpawn():SpawnExt(info.id, info.x, info.y, 1.643, 0)
		elseif info.id == 7 then
			self.Scene:GetModSpawn():SpawnExt(info.id, info.x, info.y, 1.643, 0)
		else
			self.Scene:GetModSpawn():SpawnBatchExt(info.id, info.num, info.x, info.y, info.r)
		end
		if self.KillMonsterNum[info.id] == nil then
			self.KillMonsterNum[info.id] = info.num
		else
			self.KillMonsterNum[info.id] = self.KillMonsterNum[info.id] + info.num
		end
		self.CurrSpawnRound = id
		self.SModDungeon:MonsterSpawnNotify(info.id)
	end
end
