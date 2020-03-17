CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.Scene = nil

--活动关闭标记
CurrentSceneScript.ActivityClose = false

--采集事件
CurrentSceneScript.GatherEvents = {}

--采集总次数累计
CurrentSceneScript.CurGatherCounter = 0
CurrentSceneScript.TotalGatherCounter = 200

--首次触发该事件时间
CurrentSceneScript.FirstRandomTime = 0

--cd时间内出现次数
CurrentSceneScript.AppearTimesInCD = 0
--CurrentSceneScript.BirthPos = {
	 --[1] = {226,57},
	-- [2] = {152,0},
--}

local maxgather = 30
local currTime = _GetServerTime()
math.randomseed(currTime)

function CurrentSceneScript:Startup()
	self.SModScript = self.Scene:GetModScript()
    _RegSceneEventHandler(SceneEvents.SceneCreated,"OnSceneCreated")
    _RegSceneEventHandler(SceneEvents.SceneDestroy,"OnSceneDestroy")
    _RegSceneEventHandler(SceneEvents.ActivityClose,"OnActivityClose")
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnterWorld")
    _RegSceneEventHandler(SceneEvents.HumanLeaveWorld,"OnHumanLeaveWorld")
    _RegSceneEventHandler(SceneEvents.HumanLoginScene,"OnHumanLogin")
    _RegSceneEventHandler(SceneEvents.HumanKilled,"OnHumanKilled")
    _RegSceneEventHandler(SceneEvents.HumanGatherMushroom,"OnHumanGatherMushroom")
end

function CurrentSceneScript:Cleanup() 
	
end

function CurrentSceneScript:OnSceneCreated()
	-- 场景创建后 todo:
	--print ("scene created, id=" .. self.Scene:GetBaseMapID())
end

function CurrentSceneScript:OnSceneDestroy()
	-- 场景销毁后 todo:
	self.GatherEvents = {}
end

function CurrentSceneScript:OnHumanEnterWorld(human)
	-- 有玩家进来 todo:
	human:GetModActivity():InitGatherProduct()
end

function CurrentSceneScript:OnHumanLeaveWorld(human)  
	-- 有玩家离开 todo:
	--print ("human leave world, id=" .. human:GetID())
	--human:GetModPK():SetPKMod(0, 0)
end

function CurrentSceneScript:OnHumanLogin(human)
	--local idx = math.random(1,2)
	--human:LuaSetPos(self.BirthPos[idx][1], self.BirthPos[idx][2])
	--human:GetModPK():SetPKMod(6, 0)
end

function CurrentSceneScript:OnHumanKilled(human,killer)  
	-- 玩家被杀死 todo:
end

function CurrentSceneScript:OnActivityClose()
	self.ActivityClose = true
end

function CurrentSceneScript:OnHumanGatherMushroom( human, mushroom )
	if self.ActivityClose then return end
	if self:GetFree( human ) then
	else
		_SendNotice(2015001, "", self.Scene:GetGameMapID()) --采蘑菇次数上限通知
		return
	end

    --采蘑菇随机事件
    local data = {}
    local eSuccess = false
    local eType = 0
    --local eParam1 = 0
    --local eParam2 = 0
 --[[      
    local apearRate = math.random(0,1000)
    if apearRate <= 4 then --出现随机事件概率
        eType = math.random(1,4)
        if eType == 2 then eType = 1 end
        local eCD = self:CheckCD(eType)
        print("eType: " .. eType .. "eCD=" .. eCD)

		if eCD == 'ok' then
			if eType == 1 then      --冰封事件
			   eParam1 = 1001003    --buffid
			   eParam2 = 50         --冰封范围
			   self:SendGatherEventNotice(10150,human)

		    elseif eType == 3 then   --爆炸事件
		    	eParam1 = 6100001    --技能id
		    	self:SendGatherEventNotice(10152,human)

		    elseif eType == 4 then   --狂乱事件
		    	eParam1 = 10230001   --怪物id
		    	self.Scene:GetModSpawn():SeniorMonster(eParam1,human:GetPos(),0)

		    	self.SModScript:CreateTimer(20, "KillGatherMonster") -- N秒后消失
		    	self:SendGatherEventNotice(10153,human)
		    end

		    local events = {}
		    events.gathertype = eType
		    events.gathertime = _GetServerTime()
		    self.GatherEvents[eType] = events

		    --随机事件触发
		    if eType == 1 or eType == 3 then --狂乱事件无需处理
		        data[1] = eType
		        data[2] = eParam1
		        data[3] = eParam2

			    self.Scene:GetModScript():SendGatherRandomEvent(data,human:GetID())
			end

		    eSuccess = true
		end
	end
    
    self.CurGatherCounter = self.CurGatherCounter+1
	--玩家累计采集200次必触发一次活物事件
    if self.CurGatherCounter>=self.TotalGatherCounter  then
        if  eSuccess ~= true and self:CheckCD(eType) == 'ok' then 
    		self:TriggerHuoWu(human)

    		local events = {}
			events.gathertype = 2
			events.gathertime = _GetServerTime()
		 	self.GatherEvents[eType] = events
	    end
	    self.CurGatherCounter = 0
    end
  ]]
    --消耗采集次数(活物事件例外)
    if eSuccess == false or eType == 2 then
	    local gatherScore = human:GetModActivity():GetGatherScore()+1
		human:GetModActivity():SetGatherScore(gatherScore)

		--采蘑菇结算
	    self.Scene:GetModScript():SendGatherProduct(mushroom:GetConfigID(),human:GetID())
	end
end

function CurrentSceneScript:GetFree( human )
	return human:GetModActivity():GetGatherScore()<maxgather
end

function CurrentSceneScript:TriggerHuoWu( human )
	local huowuid = 10230002 --怪物id
	if self.FirstRandomTime==0 then
	   self.FirstRandomTime=_GetServerTime()
	end
    
    --cd时间内事件次数
	self.AppearTimesInCD = self.AppearTimesInCD+1
	self.Scene:GetModSpawn():SeniorMonster(huowuid,human:GetPos(),0,1)
	self:SendGatherEventNotice(10151,human)
end

function CurrentSceneScript:CheckCD(etype)
	local rGatherCD = 'ok'
	local e = self.GatherEvents[etype]
	if not e then
		local event = {}
		event.gathertype = etype
		event.gathertime = 0
		self.GatherEvents[etype] = event
	end

	local _Currtime = _GetServerTime()
	local time = _Currtime - self.GatherEvents[etype].gathertime
	local minutes = self:timeToMinute ( time ) --内置cd时间，单位分钟

	if etype == 1 and minutes<3 then
	    rGatherCD = 'err'

	elseif etype == 2 and minutes<2 then
		local diffTime = self:timeToMinute(_Currtime - self.FirstRandomTime)
		if diffTime <10 and self.AppearTimesInCD <=3 then
			rGatherCD = 'err'
		else
			self.FirstRandomTime = 0
		end
	elseif etype == 3 and minutes<10 then
		rGatherCD = 'err'

	elseif etype == 4 and minutes<2 then
		rGatherCD = 'err'
	end

	return rGatherCD
end

function CurrentSceneScript:timeToMinute ( time )
    local res = time/60
    return res
end

function CurrentSceneScript:KillGatherMonster(val)
	--local data = {}
	--data[1] = 4
	--data[2] = 10230001
	--data[3] = 0
    
    --杀死蘑菇怪
	--self.Scene:GetModScript():SendGatherRandomEvent(data,self.CurGatherHumanID)
	local id = 10230001
	self.Scene:GetModScript():SecKillMonster(id)
end

function CurrentSceneScript:SendGatherEventNotice(notice, human)
	local str = ""
	if human ~= nil then
		str = str .. "1," .. human:GetID() .. "," .. human:GetName() .. "#"
		_SendNotice(notice, str, self.Scene:GetGameMapID())
	end
end
