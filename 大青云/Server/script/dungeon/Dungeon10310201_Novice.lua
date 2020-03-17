CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.Scene = nil

--分裂小怪标记
CurrentSceneScript.split_flag = 0

--随机事件类型
CurrentSceneScript.random_event = 0

--随机事件开始时间
CurrentSceneScript.start_time = 0

--随机事件状态
CurrentSceneScript.event_state = false

--Boss是否被击杀
CurrentSceneScript.boss_killed = false

--击杀定身怪
CurrentSceneScript.monster_hold_flag = 0
CurrentSceneScript.monster_hold_num = 0
CurrentSceneScript.monster_hold_first_max = 10
CurrentSceneScript.monster_hold_second_max = 6

math.randomseed(_GetServerTime())
-----------------------------------------------------------

function CurrentSceneScript:Startup()
    self.SModDungeon = self.Scene:GetModDungeon()
    self.SModScript = self.Scene:GetModScript()
    _RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnter")
    _RegSceneEventHandler(SceneEvents.HumanLeaveWorld,"OnHumanLeave")
	_RegSceneEventHandler(SceneEvents.HumanKilled,"OnHumanKilled")
    _RegSceneEventHandler(SceneEvents.MonsterKilled,"OnBossKilled")
	_RegSceneEventHandler(SceneEvents.HumanStoryStep,"OnHumanStoryStep")
	_RegSceneEventHandler(SceneEvents.DungeonMonster,"OnDungeonMonster")
    _RegSceneEventHandler(SceneEvents.DungeonRandomEvent,"OnDungeonRandomEvent")
    _RegSceneEventHandler(SceneEvents.DungeonEventResult,"OnDungeonEventResult")
end

function CurrentSceneScript:Cleanup() 
	
end

function CurrentSceneScript:OnHumanEnter(human)
    local r_state = 1
    self.SModDungeon:LaunchStory(human)
    
    if self.random_event == 1 then
        r_state = 2
        self:RandomEventInfo(self.random_event,r_state,0,0)
    end
end

function CurrentSceneScript:OnHumanLeave(human)  
	--self.leave_time = _GetServerTime()
end

function CurrentSceneScript:OnHumanKilled(human,killer)  
	
end

function CurrentSceneScript:OnBossKilled(boss,killer,id)
    --击杀boss事件
    if id == 10200201 or id == 10200202 or id == 10200203 then
        --boss隐藏BOSS星级界面
        self.SModDungeon:SendHideFallStar(id)
        --boss死亡随机事件触发
        if not self.event_state then return end
        self.boss_killed = true
        self:RandomEventResult()
    end

    --击杀定身怪事件
    if id == 10200204 then
        self.monster_hold_num = self.monster_hold_num + 1
        if self.monster_hold_num >= self.monster_hold_first_max then
            if self.monster_hold_flag == 0 then
               self.monster_hold_flag = 1
               self.monster_hold_num = 0
               self.SModScript:SpawnMonsterBit(10200213,false)
            end
        end

        if self.monster_hold_num >= self.monster_hold_second_max then
            if self.monster_hold_flag == 1 then
                self.SModScript:SpawnMonsterBit(10200213,false)
            end
        end
    end
end

function CurrentSceneScript:OnHumanStoryStep(id)
    if id == 1101002 then
        self.SModScript:SpawnMonsterBit(10200008,false) --无敌生物,true为无敌状态，false解除无敌状态
    end
    if id == 3101001 then
        self.SModScript:SpawnMonsterBit(10200213,true)
        self.SModDungeon:DungeonBlock("block001",7001,false) --false关闭阻挡
    end
    if id == 3101003 then
        self.SModDungeon:DungeonBlock("block003",7003,false)

        local data = {}
        local monster_id = "10200206" --怪物id
        local monster_count = "10,10,10" --每波怪物数目
        local spawn_pos = "-258,-85,1,0.0#-239,-85,1,0.0#-220,-85,1,0.0#-192,-85,1,0.0#-282,-271,1,3.0#-208,-271,1,3.0#-300,-271,1,3.0#-243,-271,1,3.0#-195,-271,1,3.0#-260,-271,1,3.0" --出生坐标,随机出生范围
        local params = 4 --其它刷怪

        data[1] = monster_id
        data[2] = monster_count
        data[3] = spawn_pos
        self.SModScript:SpawnMonsterRandom(data,params)
    end
    if id == 1101004 then
        --随机事件3.
        if self.random_event == 3 then
           self:RandomEventInfo(self.random_event,2,0,0)
        end
	end
    if id == 2101005 then
        local data = {}
        local monster_dir = 3.09--dir
        data[1] = 10200203 --boss_id
        data[2] = 1 --count
        data[3] = -70 --xpos
        data[4] = -318 --ypos
        self.SModScript:SpawnMonster(data,monster_dir)
    end
    if id == 3101006 then
        self.SModScript:SpawnMonsterBit(10200010,false)
    end
    if id == 3101007 then
        self.SModScript:SpawnMonsterBit(10200213,true)
        self.SModDungeon:DungeonBlock("block005",7003,false)
    end
    if id == 1101008 then
        local data = {}
        local monster_id = "10200205"
    	local monster_count = "10,10,10"
        local spawn_pos = "-83,109,50,0.0"
    	local params = 1 --分批刷怪

        data[1] = monster_id
        data[2] = monster_count
        data[3] = spawn_pos
    	self.SModScript:SpawnMonsterRandom(data,params)
    end
    if id == 3101009 then
        self.SModDungeon:DungeonBlock("block002",7007,false)
        self.SModDungeon:GetNextStory(101010)
    end
    if id == 3101010 then
        --self.SModScript:DungeonBlock("block006",false)
    end
    if id == 2101010 then
        local data = {}
        local monster_dir = 3.09
        data[1] = 10200202 --半血刷小怪
        data[2] = 1
        data[3] = 131
        data[4] = -66
		self.SModScript:SpawnMonster(data,monster_dir)
        self.SModDungeon:GetNextStory(101011)
    end
    if id == 2010011 then
        self.SModScript:SpawnMonsterBit(10200012,false)
    end
    if id == 10200207 then -- 分裂小怪id
        self.SModScript:SpawnMonsterBit(10200202,false)
        self.split_flag = 2
    end
    if id == 3101012 then
        self.SModDungeon:DungeonBlock("block007",7003,false)
    end
    if id == 3101013 then
        self.SModScript:SpawnMonsterBit(10200011,false)
    end
    if id == 3101014 then
        self.SModDungeon:DungeonBlock("block008",7003,false)
    end
    if id == 2101016 then
        --播放动画
        --刷怪
        local data = {}
        local params = 5

        data[1] = "10200201"
        data[2] = "1"
        data[3] = "566,-693,10,3.09"
        self.SModScript:SpawnMonsterRandom(data,params)
        --随机事件2.
        if self.random_event == 2 then
           self:RandomEventInfo(self.random_event,2,0,0)
        end
    end
	end

function CurrentSceneScript:GetDropBloodPer(id)
    local result = 0
    if self.split_flag == 1 and id == 10200202 then
        result = 1
    end
    return result
end

function CurrentSceneScript:OnDungeonMonster(id,hp_per,pos_x,pos_y)
    local data = {}
	if id == 10200202 then
        if hp_per>0 and hp_per <= 50  then  --BOSS 50%血量分裂出一批20只小怪
            if self.split_flag > 0 then return end
            local params = 3 --播放剧情后召唤小怪
            local spawn_pos = tostring(pos_x) .. "," .. tostring(pos_y) .. "," .. tostring(50) .. "," .. tostring(0.0)                                
            data[1] = "10200207" --monsterid
            data[2] = "15" --monsternum
            data[3] = spawn_pos

            self.split_flag = 1
            self.SModScript:SpawnMonsterBit(id,true)
            self.SModDungeon:PlayStory(4,"dun101002")
            self.SModScript:SpawnMonsterRandom(data,params)
        end
    end
end

function CurrentSceneScript:OnDungeonRandomEvent(param)
    local rate = math.random(1,100)
    if rate <= 0 then
        local r_event = math.random(1,3)
        self.random_event = r_event
        --print("OnDungeonRandomEvent: r_event=" .. r_event)
    end
end

function CurrentSceneScript:OnDungeonEventResult(id)
    if self.random_event == 3 then
        if id == 101004 and self.event_state then
           self:RandomEventResult()
        end
    end
end

function CurrentSceneScript:RandomEventResult()
    local data = {}
    local fight_success = false
    local fight_state = 0
    local box_reward = ""
    local box_count = 10
    local time = _GetServerTime() - self:GetRandomStartTime()
    local minutes = time/60
    local etype = self.random_event

    if etype == 1 then
        --争分夺秒,经验(params:经验值)
        if self.boss_killed == true and minutes <= 3 then
           fight_success =true
        end
    elseif etype == 2 then
        --秒杀的快感,道具(params:道具id,数量)
        if self.boss_killed == true and time <= 10 then
           fight_success = true
        end
    elseif etype == 3 and time < 60 then
        fight_success = true
        local box_id = 110220007
        box_count = box_count - tonumber(time/6)
        --遗失的宝藏,宝箱(box_id:宝箱id)
        box_reward = tostring(box_id) .. "," .. tostring(box_count)
    end
    
    if fight_success == true then
       fight_state = 3
       data[1] = etype
       data[2] = box_reward
       self.SModDungeon:RandomEventResult(data) --挑战结果
    else
        fight_state = 4
    end
    self:RandomEventInfo(etype,fight_state,box_count,0)
    self.event_state = false
end

function CurrentSceneScript:RandomEventInfo(eid,state,param1,param2)
    local data = {}
    local time = _GetServerTime()
    data[1] = eid
    data[2] = state --1,事件通知2,事件开始3,事件成功4,事件失败
    data[3] = param1
    data[4] = param2

    if eid<=0 then return end
    if state==2 then
        self:RandomEventCD(eid)
    end

    self:SetRandomStartTime(time)
    self.SModDungeon:SendRandomInfo(data,params)
end

function CurrentSceneScript:SetRandomStartTime(time)
    if time ~= nil then
       self.start_time = time
       self.event_state = true
   end
end

function CurrentSceneScript:GetRandomStartTime()
    return self.start_time
end

function CurrentSceneScript:RandomEventCD(id)
    --创建副本随机事件计时器
    local sec
    if id == 1 then sec = 3*60
    elseif  id == 2 then sec = 10
    elseif id == 3 then sec = 60
    end
    
    --print("RandomEventCD:" .. sec)
    self.SModScript:CreateTimer(sec, "RandomEventClose")
end

function CurrentSceneScript:RandomEventClose(val)
    --关闭副本随机事件
    if self.event_state then
        self:RandomEventResult()
    end
end
