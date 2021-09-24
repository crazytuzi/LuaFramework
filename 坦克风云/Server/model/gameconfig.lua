function model_gameconfig()
    local self = {
        rkey = '',
        appkey = '',
    }

    function self.bind()
        local gameconfigs = self.getValidgameconfigs()
        if type(gameconfigs) == 'table' then
            for k,v in pairs(gameconfigs) do
                self[v.name] = v 
            end
        end
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
    function self.getgameconfigs(name)

        local gameconfigs = {}

        local db = getDbo()
        local result = db:getAllRows("select * from gameconfig where status = 1 and name = :name ",{name=name})
            
        if result then
            gameconfigs = result
        end       
        return gameconfigs 
    end


       --获取同一名字的所有活动
    function self.getUsegameconfigs(name,ts)
        
        local gameconfigs = {}

        local db = getDbo()
        local result = db:getAllRows("select * from gameconfig ")
            
        if result then
            gameconfigs = result
        end       
        return gameconfigs 
    end

    function self.getValidgameconfigs( appid )    
        local ts = getClientTs()
        local forwardNum = 7200
        
        local redis = getRedis()
        local gameconfigs = redis:hgetall(self.rkey)
        local data = {}
        if type(gameconfigs) ~= 'table' or not(next(gameconfigs)) then
            local db = getDbo()
            local result = db:getAllRows("select * from gameconfig ")
            
            if result then
                gameconfigs = result
                for k,v in pairs(result) do
                    data[v.name]=v
                    redis:hmset(self.rkey,v.id,json.encode(v))
                end
                redis:expire(self.rkey,forwardNum/2)
            else
                return false
            end    
        else
            
            for k,v in pairs(gameconfigs) do
                v=json.decode(v)  or v
                data[v.name]=v
            end
        end

        if appid then
            local gameconfigByappid = self.getgameconfigbyappid()
            if gameconfigByappid then
                for kname, value in pairs(gameconfigByappid) do
                    if value[tostring(appid)] then 
                        data[kname] = { name=kname, value=value[tostring(appid)] }
                    end
                end
            end
        end        

        return data 
    end

    -- 更新功能开启
    function self.setgameconfig(id,params)
        params.updated_at = getClientTs()    

        local db = getDbo()            
        local ret = db:update("gameconfig",params,"id='".. (db.conn:escape(id) or 0) .. "'")        

        if ret and ret > 0 then
            local redis = getRedis()
            if redis:del(self.rkey) == 1 then
                return true
            end
        end
    end

    --更新功能 

    function self.setgameconfigname(name,params)
        params.updated_at = getClientTs()    

        local db = getDbo()            
        local ret = db:update("gameconfig",params,"name='".. (db.conn:escape(name) or '') .. "'")        

        if ret and ret > 0 then
            local redis = getRedis()
            if redis:del(self.rkey) == 1 then
                return true
            end
        end
    end

    -- 创建新活动数据
    function self.creategameconfig(params)
        params.updated_at = getClientTs()    

        local db = getDbo()
        local ret = db:insert("gameconfig",params)
        if ret and ret > 0 then
            local redis = getRedis()
            if redis:del(self.rkey) == 1 then
                return true
            end
        end
    end

    function self.setRkey()
        local zoneid = 'z' .. getZoneId()
        self.rkey = zoneid .. ".gameconfig"
        self.appkey = zoneid .. ".gameconfig.appid"
        self.paykey = zoneid .. ".paythird-gameconfig"
    end

    -- loginAt 登陆时间
    function self.getTitleList(loginAt,uid)
        local data = {}
        local newgameconfigNum = 0
        local ts = getClientTs()
        local gameconfigCfg = getConfig("gameconfig") 

        for k,v in pairs (self) do
            if type(v)~="function" and k~= 'updated_at' and k~= 'rkey' then
                data[k] = {
                    sortId=v.sortId,
                    st=v.st,
                    et=v.et,                    
                }

                if tonumber(v.type) == 10 then
                    data[k].data = gameconfigCfg[k].data
                end

                if (tonumber(v.st) or 0) > loginAt and tonumber(v.st) <= ts then
                    newgameconfigNum = newgameconfigNum + 1
                end
            end
        end

        -- if uid == 1009218 or uid == 1003172 then
        --     data.fbReward = {
        --         st = 1394957400,
        --         et = 1395287400,
        --     }
        -- end

        return data,newgameconfigNum
    end

    -- 通过渠道id设置开关
    function self.setgameconfigbyappid(name, subappids, flag) 
        local gameconfigkey =  'gameconfig.' .. name

        local gameconfigData = getFreeData( gameconfigkey )
        local info = {}
        if gameconfigData and gameconfigData.info then
            info = gameconfigData.info
        end

        for k, vappid in pairs(subappids or {}) do
            info[tostring(vappid)] = flag
        end

        if setFreeData(gameconfigkey, info) then
            local redis = getRedis()
            redis:hset(self.appkey, name, json.encode(info))
            return true
        end

        return false
    end

    function self.getgameconfigbyappid()
        local redis = getRedis()
        local data = redis:hgetall(self.appkey)

        if type(data) ~= 'table' or not next(data) then
            local db = getDbo()
            local result = db:getAllRows("select name, info from freedata where name like '%.gameconfig.%'")
            data = {}
            if result then
                for k, v in pairs(result) do
                    local allname = v["name"]:split(".gameconfig.")
                    if allname[2] then
                        data[allname[2]] = json.decode( v["info"] )
                        redis:hset(self.appkey, allname[2], v["info"])
                    end
                end
            else
                return false
            end
        else
            for k, v in pairs(data) do
                data[k] = json.decode(v)
            end
        end

        return data
    end

    -- 第三方支付开关,特殊处理
    function self.setgameconfigpay(info)
        if setFreeData(self.paykey, info) then
            local redis = getRedis()
            redis:set(self.paykey, json.encode(info))
            return true
        end

        return false
    end

    function self.getgameconfigpay()
        local redis = getRedis()
        local data = redis:get(self.paykey)

        if not data then
            data = getFreeData(self.paykey)
            if type(data) == 'table' then
                data = data.info
            else
                data = {}
            end
        else
            data = json.decode(data) or {}
        end

        return data
    end

    self.setRkey()
    self.bind()

    return self

end