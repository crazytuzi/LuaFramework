function model_active()
    local self = {
        rkey = '',
    }

    function self.bind()
        local actives = self.getValidActives()
        if type(actives) == 'table' then
            for k,v in pairs(actives) do
                self[v.name] = v 
            end
        end
    end

    --自定义配置文件
    function self.selfCfg(activeName, flag)

        local config = getConfig('active.'.. activeName)
        --多份配置时选择
        if config.multiSelectType then
            config = config[tonumber(self[activeName]["cfg"])]
        end
        self[activeName]['selfcfg'] = json.decode(self[activeName]['selfcfg'])
        --充值返利活动 假如平台名称不是日本 用默认配置
        if activeName == 'rechargeRebate' and getClientPlat() ~= 'gNet_jp' then
            return config
        end
        if type(self[activeName]['selfcfg']) ~= 'table' or (not next(self[activeName]['selfcfg'])) then
            return config
        end
        for item, info in pairs(self[activeName]['selfcfg']) do
            config[item] = info
        end
        --飞流-真情回馈活动 屏蔽可以获奖用户的名单
        if flag and activeName == "zhenqinghuikui" then
            if config["userlist"] then
                config["userlist"] = nil
            end
        end

        if type(self['_'..activeName]) == 'function' and flag then
            config = self['_'..activeName](config)
        end
        return config
    end

    function self.toArray(format)
        local data = {}
        for k,v in pairs (self) do
            if type(v)~="function" and k~= 'updated_at' and k~= 'rkey' then              
                data[k] = v
            end
        end

        return data
    end
    --获取同一名字的所有活动
    function self.getActives(name)

        local actives = {}

        local db = getDbo()
        local result = db:getAllRows("select * from active where status = 1 and name = :name ",{name=name})
            
        if result then
            actives = result
        end       
        return actives 
    end


       --获取同一名字的所有活动
    function self.getUseActives(name,ts)
        
        local actives = {}

        local db = getDbo()
        local result = db:getAllRows("select * from active where status = 1 and name = :name ",{name=name,et>=ts,st<=ts})
            
        if result then
            actives = result
        end       
        return actives 
    end

    function self.getValidActives()    
        local ts = getClientTs()
        local forwardNum = 7200
        
        local redis = getRedis()
        local actives = redis:hgetall(self.rkey)

        if type(actives) ~= 'table' or not(next(actives)) then
            local db = getDbo()
            local result = db:getAllRows("select * from active where status = 1 and st <= :st and et > :currTs ",{currTs=ts,st=ts+forwardNum})
            
            if result then
                actives = result
                for k,v in pairs(result) do
                    redis:hmset(self.rkey,v.id,json.encode(v))
                end
                redis:expire(self.rkey,forwardNum/2)
            else
                return false
            end    
        else
            for k,v in pairs(actives) do
                actives[k] = json.decode(v)  or v
            end
        end
        
        return actives 
    end

    -- 更新活动
    function self.setActive(id,params)
        params.updated_at = getClientTs()    

        local db = getDbo()            
        local ret = db:update("active",params,"id='".. (db.conn:escape(id) or 0) .. "'")        

        if ret and ret > 0 then
            local redis = getRedis()
            redis:del(self.rkey)
            return true
        end
    end

    -- 创建新活动数据
    function self.createActive(params)
        params.updated_at = getClientTs()    

        local db = getDbo()
        local ret = db:insert("active",params)

        if ret and ret > 0 then
            local redis = getRedis()
            redis:del(self.rkey) 
            return true
        end
    end

    function self.setRkey()
        local zoneid = 'z' .. getZoneId()
        self.rkey = zoneid .. ".active"
    end

    -- loginAt 登陆时间
    function self.getTitleList(loginAt,uid)
        local data = {}
        local newActiveNum = 0
        local ts = getClientTs()
        local activeCfg = getConfig("active") 

        for k,v in pairs (self) do
            if type(v)~="function" and k~= 'updated_at' and k~= 'rkey' then
                data[k] = {
                    sortId=v.sortId,
                    st=v.st,
                    et=v.et,                    
                }

                if tonumber(v.type) == 10 then
                    data[k].data = activeCfg[k].data
                end

                if (tonumber(v.st) or 0) > loginAt and tonumber(v.st) <= ts then
                    newActiveNum = newActiveNum + 1
                end
            end
        end

        -- if uid == 1009218 or uid == 1003172 then
        --     data.fbReward = {
        --         st = 1394957400,
        --         et = 1395287400,
        --     }
        -- end

        return data,newActiveNum
    end

    --格式化配置文件，前台接口用
    --自定义抽奖配置文件
    function self._customLottery(config)
        local serverToClient = function(type)
            local tmpData = type:split("_")
            local tmpType = tmpData[2]
            local tmpPrefix = string.sub(type, 1, 1)
            if tmpPrefix == 't' then tmpPrefix = 'o' end
            if tmpPrefix == 'a' then tmpPrefix = 'e' end
            return tmpPrefix, tmpType
        end
        config['list'] = {}
        for _,info in pairs(config.pool[3]) do
            local prefix, type = serverToClient(info[1])
            table.insert(config['list'], {[prefix]=type, num=info[2]})
        end
        local tmpGood = config['good']
        config['good'] = {}
        for _,info in pairs(tmpGood) do
            local prefix, type = serverToClient(info)
            table.insert(config['good'], {[prefix]=type})
        end
        config['pool'] = nil
        return config
    end

    self.setRkey()
    self.bind()

    return self

end