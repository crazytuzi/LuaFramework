--
-- 自定义配置
-- User: luoning
-- Date: 14-10-30
-- Time: 下午5:56
--

function model_customconfig()

    local self = {
        rkey = '',
    }

    function self.bind()
        local customconfigs = self.getValidcustomconfigs()
        if type(customconfigs) == 'table' then
            for k,v in pairs(customconfigs) do
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
    function self.getcustomconfigs(name)

        local customconfigs = {}

        local db = getDbo()
        local result = db:getAllRows("select * from customconfig where status = 1 and name = :name ",{name=name})

        if result then
            customconfigs = result
        end
        return customconfigs
    end


    --获取同一名字的所有活动
    function self.getUsecustomconfigs(name,ts)

        local customconfigs = {}

        local db = getDbo()
        local result = db:getAllRows("select * from customconfig ")

        if result then
            customconfigs = result
        end
        return customconfigs
    end

    function self.getValidcustomconfigs()
        local ts = getClientTs()
        local forwardNum = 7200

        local redis = getRedis()
        local customconfigs = redis:hgetall(self.rkey)
        local data = {}
        if type(customconfigs) ~= 'table' or not(next(customconfigs)) then
            local db = getDbo()
            local result = db:getAllRows("select * from customconfig ")

            if result then
                customconfigs = result
                for k,v in pairs(result) do
                    data[v.name]=v
                    redis:hmset(self.rkey,v.id,json.encode(v))
                end
                redis:expire(self.rkey,forwardNum/2)
            else
                return false
            end
        else

            for k,v in pairs(customconfigs) do
                v=json.decode(v)  or v
                data[v.name]=v
            end
        end

        return data
    end

    -- 更新功能开启
    function self.setcustomconfig(id,params)
        params.updated_at = getClientTs()

        local db = getDbo()
        local ret = db:update("customconfig",params,"id='".. (db.conn:escape(id) or 0) .. "'")

        if ret and ret > 0 then
            local redis = getRedis()
            if redis:del(self.rkey) == 1 then
                return true
            end
        end
    end

    --更新功能

    function self.setcustomconfigname(name,params)
        params.updated_at = getClientTs()

        local db = getDbo()
        local ret = db:update("customconfig",params,"name='".. (db.conn:escape(name) or '') .. "'")

        if ret and ret > 0 then
            local redis = getRedis()
            if redis:del(self.rkey) == 1 then
                return true
            end
        end
    end

    --更新黑名单聊天配置
    function self.createBlacklistCfg(people, limitHour, level)
        local params = {}
        params.value = json.encode({people, limitHour, level})
        if not self.blacklist then
            params.name = 'blacklist'
            self.createcustomconfig(params)
        else
            self.setcustomconfig(self.blacklist.id, params)
        end
        return true
    end

    -- 创建新活动数据
    function self.createcustomconfig(params)
        params.updated_at = getClientTs()

        local db = getDbo()
        local ret = db:insert("customconfig",params)
        if ret and ret > 0 then
            local redis = getRedis()
            if redis:del(self.rkey) == 1 then
                return true
            end
        end
    end

    function self.setRkey()
        local zoneid = 'z' .. getZoneId()
        self.rkey = zoneid .. ".customconfig"
    end

    function self.getCustomConfig(name)
        local config = {}
        local defaultConfig = {
            ["blacklist"] = {7,10,10},
        }
        if self[name] then
            config = json.decode(self[name].value)
        end
        if not next(config) then
            if defaultConfig[name] then
                return defaultConfig[name]
            end
            return false
        end
        return config
    end

    self.setRkey()
    self.bind()
    return self

end

