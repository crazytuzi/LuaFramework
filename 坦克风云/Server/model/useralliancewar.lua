function model_useralliancewar(uid,data)
    -- the new instance
    local self = {
        uid= uid,
        aid=0,  -- 军团id
        bid= "", -- 改版的bid
        b1 = 0, -- 冶炼专家  战斗强度   攻击&血量&防护&穿透
        b2 = 0, -- 指挥专家  战斗天运   命中&闪避&暴击&韧性
        b3 = 0, -- 采集专家 采集加成    占领据点后生产的积分效率增加
        b4 = 0, -- 统计专家 荣誉加成    战斗中产生的贡献增加 

        -- 记下详细的升级信息，升级的等级和升级的时间戳
        upgradeinfo = {},   
        binfo={},  -- 改版的设置的部队的信息
        info={},  -- 前段的部队和将领
        rank=0,   -- 军团战中的排名
        cdtime_at=0,
        battle_at=0,

        -- 任务
        task = {},

        -- 更新buff的时间,buff效果只在当天有效，以此字段为标准重置buff
        buff_at = 0,    

        updated_at=0,
    }

    function self.bind(data)
        if type(data) ~= 'table' then
            return false
        end

        for k,v in pairs (self) do
            local vType = type(v)
            if vType~="function" then
                if data[k] == nil then return false end
                if vType == 'number' then
                    self[k] = tonumber(data[k]) or data[k]
                elseif vType == 'table' and type(data[k]) ~= 'table' then                    
                else
                    self[k] = data[k]
                end
            end
        end
        
        -- 初始化一下
        self.init()

        return true
    end

    function self.toArray(format)
        local data = {}
        if format then
            for k,v in pairs (self) do
                if type(v)~="function" and k~= 'updated_at' and k~= 'binfo' and k~= 'upgradeinfo' then
                    data[k] = v
                end
            end
        else
            for k,v in pairs (self) do
                if type(v)~="function" and k~= 'updated_at' then
                    data[k] = v
                end
            end
        end

        return data
    end
  
    function self.getKeys()
        local data = {}
        for k,v in pairs (self) do
            if type(v)~="function" then
                table.insert(data,k)
            end
        end
        return data
    end
  
------------------------------------------------------------------------------------------------------------------
    
    function self.init()
        if self.buff_at > 0 then
            local weets = getWeeTs()
            local lastSetBuffWeets = getWeeTs(self.buff_at)
            
            if weets ~= lastSetBuffWeets then
                self.reset()
                self.buff_at=weets
            end
        end
    end

    -- 重置所有buff
    function self.reset()
        self.b1 = 0
        self.b2 = 0
        self.b3 = 0
        self.b4 = 0
        self.upgradeinfo = {}
        self.info = {}
        self.binfo = {}
        self.rank =0
        self.task = {}
        self.buff_at = getClientTs()
    end
    
    -- 获取战斗状态
    function self.getBattleStatus()
        local allianceWarCfg = getConfig('allianceWarCfg')

        local ts = getClientTs()

        local cdts = allianceWarCfg.cdTime - (ts - self.cdtime_at)
        -- 战斗冷却CD中
        if cdts > 0 then
            return -4006,cdts
        end

        return 0
    end

    -- 获取战斗状态
    function self.getNewBattleStatus()
        local allianceWarCfg = getConfig('allianceWar2Cfg')

        local ts = getClientTs()

        local cdts = allianceWarCfg.cdTime - (ts - self.cdtime_at)
        -- 战斗冷却CD中
        if cdts > 0 then
            return -4006,cdts
        end

        return 0
    end

    -- 获取buff
    -- params int t 1/2 1是取战斗相关，2是取积分与分值相关，不传取所有
    function self.getBattleBuff(t)
        local buff = {}

        if t == 1 then
            buff.b1=self.b1
            buff.b2=self.b2
        elseif t == 2 then            
            buff.b3=self.b3
            buff.b4=self.b4
        else
            buff.b1=self.b1
            buff.b2=self.b2
            buff.b3=self.b3
            buff.b4=self.b4
        end

        return buff
    end
    
    -- buff 升级
    -- 记录升级的详细信息(b3是采集专家)
    function self.upgradeBuff(buff,level)
        if self[buff] then
            local ts  = getClientTs()

            self[buff] = level
            self.buff_at = ts
            
            if buff == 'b3' then
                if type(self.upgradeinfo[buff]) ~= 'table' then
                    self.upgradeinfo[buff] = {}
                end
                
                self.upgradeinfo[buff][level] = ts
            end 
        end
    end

    -- 设置战斗时间
    function self.setCdTimeAt(ts)
        ts = ts or getClientTs()
        self.cdtime_at = ts
    end

    -- 设置任务
    function self.setTask(taskInfo)
        local allianceWarCfg = getConfig('allianceWar2Cfg')
        for taskId,value in pairs(taskInfo) do
            value = tonumber(value) or 0
            if (value > 0) and ((self.task[taskId] or 0) < allianceWarCfg.task[taskId][1]) then
                self.task[taskId] = (self.task[taskId] or 0) + value

                if self.task[taskId] > allianceWarCfg.task[taskId][1] then
                    self.task[taskId] = allianceWarCfg.task[taskId][1]
                end
            end
        end
    end

------------------------------------------------------------------------------------------------------------------

    return self
end