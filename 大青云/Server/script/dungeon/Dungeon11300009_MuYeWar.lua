CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.Scene = nil

-----------------------------------------------------------

CurrentSceneScript.SpawnMonsterTimerId = nil	
CurrentSceneScript.SpawnRound = 0			--第几波怪出生
CurrentSceneScript.CurrentKillRound = 1		--当前击杀第几波
CurrentSceneScript.SpawnDoorId = 10230001  --城门id
CurrentSceneScript.SpawnMonsterPos = {
[1]={x=-5,y=260
},
[2]={x=7,y=236
},
[3]={x=-17,y=234
},
[4]={x=-17,y=266
},
[5]={x=7,y=268
},
}	 --怪物出生点
CurrentSceneScript.SpawnMonsterTime = 30   -- 每波刷新时间
CurrentSceneScript.SpawnBossId = {10230003, 10230003,10230003,10230003,10230003, 10230003} --boss id
CurrentSceneScript.CurrentCount = 0  --当前波数怪物数量
CurrentSceneScript.TotalCount = {}	 --怪物总数量
CurrentSceneScript.CurrentSec = 0 --当前杀怪秒数
CurrentSceneScript.HumanCounts = 0
-----------------------------------------------------------

function CurrentSceneScript:Startup()
  _RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnter")
  _RegSceneEventHandler(SceneEvents.HumanLeaveWorld,"OnHumanLeave")
  _RegSceneEventHandler(SceneEvents.MonsterKilled,"OnMonsterKilled")
  _RegSceneEventHandler(SceneEvents.MonsterHitMonster, "OnMonsterHited")
  _RegSceneEventHandler(SceneEvents.MonsterEnterWorld, "OnMonsterEnter")
  
  self.SModScript = self.Scene:GetModScript()
  self.SModDungeon = self.Scene:GetModDungeon()
  self.SModScript:CreateTimer(10, "OnSpawnMonsterTimer")
  self.SModScript:CreateTimer(10, "OnRefreshSpawn")

end

function CurrentSceneScript:Cleanup()

end

function CurrentSceneScript:OnHumanEnter(human)
   if human == nil then
		return 
   end
   --给客户端发消息
   human:GetModMuYeWar():OnHumanEnter(10230001)
   self.HumanCounts = self.HumanCounts + 1
end

function CurrentSceneScript:OnHumanLeave(human)  
	--离开发奖励
	if human == nil then
		return 
	end
	human:GetModMuYeWar():OnHumanLeave(false)
	self.HumanCounts = self.HumanCounts - 1
end

--NPC 受到攻击
function CurrentSceneScript:OnMonsterHited(monster)
	if monster == nil then
		return 
	end
	
	if monster:GetMonId() == 10230001  then
		for k,v in pairs(self.Humans) do
			if v ~= nil then
			v:GetModMuYeWar():OnNPCHited(monster:GetIntAttr(19))
			
			end
		end
		
	end
	
end

function CurrentSceneScript:OnMonsterKilled(boss,killer,id)

	--城门被破坏
	if id == self.SpawnDoorId then
		if self.SpawnMonsterTimerId ~= nil then
			self.Scene:RemoveAllMonster()
			self.SModScript:CancelTimer(self.SpawnMonsterTimerId)
			self.SpawnMonsterTimerId = nil
		end

		--发奖励通知客户端失败退出
		for k,v in pairs(self.Humans) do
			if v ~= nil then
			v:GetModMuYeWar():OnSuccess(1)
			end
		end
		
		return
	end
	
	--最后一波取消定时器
	if self.SpawnRound == 50 then
		if self.SpawnMonsterTimerId ~= nil then
			self.SModScript:CancelTimer(self.SpawnMonsterTimerId)
			self.SpawnMonsterTimerId = nil
		end
	end
	
	--杀完一波
	self.CurrentCount = self.CurrentCount + 1
	if self.CurrentCount == self.TotalCount[self.CurrentKillRound].number then
		self.CurrentCount = 0
		--给客户端发消息 奖励
		for k,v in pairs(self.Humans) do
			if v ~= nil then
				v:GetModMuYeWar():OnKillWave(self.CurrentKillRound)
			end
		end
		self.CurrentKillRound = self.CurrentKillRound + 1
		
		-- 如果当前玩家杀怪时间短 3秒后刷下波怪
		if os.time() - self.CurrentSec  < 25 and self.CurrentKillRound - 1 == self.SpawnRound then
			if self.SpawnMonsterTimerId ~= nil then
				self.SModScript:CancelTimer(self.SpawnMonsterTimerId)
				self.SpawnMonsterTimerId = nil
			end
			
			for k,v in pairs(self.Humans) do
				if v ~= nil then
					v:GetModMuYeWar():OnSpawnUpdate(3)
				end
			end
			--3秒后刷一波怪
			if self.SpawnRound < 50 then
				self:OnStartSpawn()
			end
		end
		
		
		
	end
	
	-- 全部杀完 给客户端发消息 
	if self.CurrentKillRound == 51  then
		for k,v in pairs(self.Humans) do
			if v ~= nil then
				v:GetModMuYeWar():OnSuccess(0)
			end
		end
		return
	end
	
	--Boss被杀
	for i = 1,#self.SpawnBossId do
		if id == self.SpawnBossId[i] then
		 ---增加每个人的积分
			for k,v in pairs(self.Humans) do
				if v ~= nil then
					v:GetModMuYeWar():OnUpdateScore(1)
				end
			end
			
			return
		 end
	end
	
	--小怪被杀
	---增加每个人的积分
	for k,v in pairs(self.Humans) do
		if v ~= nil then
			v:GetModMuYeWar():OnUpdateScore(2)
		end
	end
	
end

function CurrentSceneScript:OnSpawnMonsterTimer() --定时刷怪
    self.CurrentSec =  os.time()
	self.SpawnRound = self.SpawnRound + 1
	if self.SpawnRound == 51 then
		return
	end
	local monster = MuyewarConfig[tostring(self.SpawnRound)]['monsterId']
	local arrayString
	local monsterArray
	if monster ~= nil then
		 arrayString = split(monster, '#')
		if  arrayString ~= nil then
		    local num = #arrayString
			local total = 0
			for i =1,num do
			
		     monsterArray = split(arrayString[i], ',')
				if monsterArray ~= nil then
					total = total + monsterArray[2]
					for j =1,monsterArray[2] do
						local Index = math.random(1, #self.SpawnMonsterPos)
						self.Scene:GetModSpawn():SpawnBatch(monsterArray[1], 1, self.SpawnMonsterPos[Index].x, self.SpawnMonsterPos[Index].y, 20)
					end
				end
			end
			local record = {}
			record.index  = self.SpawnRound
			record.number = total
			table.insert(self.TotalCount, record)
		end
	end
end

function CurrentSceneScript:OnStartSpawn()
	self.SModScript:CreateTimer(3, "OnSpawnMonsterTimer")
	self.SModScript:CreateTimer(3, "OnRefreshSpawn")
	
end

function CurrentSceneScript:OnRefreshSpawn()
	if self.SpawnMonsterTimerId == nil then
		self.SpawnMonsterTimerId = self.SModScript:CreatePeriodTimer(self.SpawnMonsterTime, self.SpawnMonsterTime, "OnSpawnMonsterTimer")
	end
end

function CurrentSceneScript:OnMonsterEnter(monster)
	if monster == nil then
		return
	end
	--必须每次都取  因为玩家数量可能发生变化
	if self.HumanCounts > 0 and self.HumanCounts < 5 then
		local param = ConstsConfig['325']['param']
		local fator = split(param, '#')
		local MaxHPfator = split(fator[1], ',')
		local MaxATTfator = split(fator[2], ',')
		local hp = monster:GetIntAttr(20)
		local attr = monster:GetIntAttr(28)
		monster:SetInitAttr(20, hp * MaxHPfator[self.HumanCounts])	-- maxHp
		monster:SetInitAttr(28, attr * MaxATTfator[self.HumanCounts]);	-- atk
	end
end
