function model_userareawar(uid,data)
    -- the new instance
    local self = {
        uid= uid,
        aid=0,  -- 军团id
        bid='',
        info={},  -- 前段的部队和将领
        -- 任务
        task = {},
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

    -- 重置所有buff
    function self.reset()
        self.info = {}
        self.aid  =0
        self.bid  ='' 
        self.task = {}
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