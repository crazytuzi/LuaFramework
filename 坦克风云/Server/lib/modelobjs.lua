-- modelobjs manage userdata in cache and db
function modelobjs(model,id,readOnly)
    -- the new instance
    local self = {}

    local private = {
        readOnly = readOnly,
        pk = id,
        dbData={},
        data={},
        tableName = "",
        modelName = model,
        isEmpty = true,
    }

    function self._getLockKey()
        return string.format("%s_model_lock",tostring(private.modelName))
    end

    function self._setReadOnlyFlag(readOnly)
        private.readOnly = readOnly
    end

    function self._lock()
        return commonLock(tostring(private.pk),self._getLockKey())
        -- if private.readOnly then 
        --     return true 
        -- else
        --     return commonLock(tostring(private.pk),self._getLockKey())
        -- end
    end

    function self._unlock()
        if private and not private.readOnly then
            commonUnlock(tostring(private.pk),self._getLockKey())
        end

        private = nil
    end

    function self._initPrivate(params)
        for k,v in pairs(params) do
            private[k] = v
        end

        private.dbData[private.pkName] = private.pk
    end
    
    -- fetch data from cache and db
    function self._dataGet()
        local result = self._getCache()
        if not next(result) then
            local db = getDbo()
            result = db:getRow(string.format("select * from %s where %s = :id  limit 1",private.tableName,private.pkName),{id=private.pk})
            if type(result) == "table" and next(result) then
                self._setCache(result)
            else
                self._setCache({_cache_not_hit=0})
            end
            -- print(db:getQueryString())
        end

        return result
    end

    function self._getCacheKey()
        return string.format("z%s.mdata.%s.%d",getZoneId(),private.modelName,private.pk)
    end

    function self._getCache()
        local redis = getRedis()
        local key = self._getCacheKey()
        local result = redis:hgetall(key)
        return result
    end

    function self._setCache(data)
        local redis = getRedis()
        local key = self._getCacheKey()
        ret = redis:hmset(key,data)
        redis:expire(key, 500)
        return ret
    end
    
    function self._delCache()
        local redis = getRedis()
        local key = self._getCacheKey()
        return redis:del(key)
    end
    
    -- create user data
    function self._dataCreate()
        local db = getDbo()
        local data = self._getCreateData()
        data.updated_at = os.time()
        local ret = db:insert(private.tableName,data) or 0

        self._delCache()
        if ret < 1 then
            error('save to db failed: '.. db:getQueryString() .. "|" .. tostring(db:getError()))
        end

        if not data[private.pkName] then
            private.pk = db:getlastautoid()
            private.dbData[private.pkName] = private.pk
        end

        self._setCache(data)

        for k,v in pairs(data) do
            if private.data[k] then
                private.dbData[k] = private.data[k]
                private.data[k] = nil
            end
        end

        return true
    end
    
    -- update user data
    function self._dataUpdate()
        local db = getDbo()
        local data = self._getEditedData()
        if next(data) then
            data[private.pkName] = private.dbData[private.pkName]
            data.updated_at = os.time()
            local ret = db:update(private.tableName,data,{private.pkName})
            if ret==nil or ret < 1 then
                writeLog('****save to db failed:\n' .. (ret or 0) .. (db:getError() or 'not error') .. (db:getQueryString() or ''))
                self._delCache()
                return false
            end

            self._setCache(data)

            for k,v in pairs(data) do
                private.dbData[k] = private.data[k] or v
                private.data[k] = nil
            end
        end
        return true
    end

    function self._bind()
        if private.pk then
            local data = self._dataGet()
            if type(data) == 'table' and next(data) and data[private.pkName] then
                local valueType
                for k,v in pairs (private.dbData) do
                    if data[k] == nil then
                        self._delCache()
                        error({code=-99,err=string.format("field invalid: %s_%s",tostring(private.modelName), tostring(k))}) 
                    end

                    valueType = type(v)

                    if valueType == 'number' then
                        private.dbData[k] = tonumber(data[k]) or data[k]
                    elseif valueType == 'table' then
                        private.dbData[k] = json.decode(data[k]) or data[k]
                    else
                        private.dbData[k] = tostring(data[k])
                    end
                end

                private.isEmpty = false
            end
        end
    end

    function self._getData()
        local data = {}
        -- ptb:p(private)
        for k,v in pairs (private.dbData) do
            data[k] = private.data[k] or v
        end

        return data
    end

    function self._getCreateData()
        local d = {}
        for k,v in pairs(private.dbData) do
            if private.data[k] then
                d[k] = private.data[k]
            else
                d[k] = v
            end

            if type(d[k]) == 'table' then
                d[k] = json.encode(d[k])
            end
        end

        return d
    end

    function self._getEditedData()
        local d = {}
        local diff = table_compare
        for k,v in pairs(private.dbData) do
            if k ~= "updated_at" then
                if private.data[k] and diff(private.data[k],v) then
                    if type(private.data[k]) == 'table' then
                        d[k] = json.encode(private.data[k])
                    else
                        d[k] = private.data[k]
                    end
                end
            end
        end

        return d
    end

    function self._isEmpty()
        return private.isEmpty
    end

    function self._save()
        assert(not private.readOnly, string.format("The model is readOnly: '%s'",tostring(private.modelName)))

        if self._isEmpty() then
            return self._dataCreate()
        else
            return self._dataUpdate()
        end
    end

    function self._loadModel()
        local m = 'model.'..private.modelName
        local mFunc = require (m)
        assert(type(mFunc) == "function",string.format("The model is not existed: %s",private.modelName))

        mFunc(self)
        self._bind()
        -- self.init()

        return self
    end

    -- --------------------------------------------------

    if not private.readOnly and not self._lock() then
        return false
    end

    self._loadModel()

    local copyTable = copyTable
    local meta = {
        __index = function(tb, key)
            if private.data[key] then 
                return private.data[key]
            elseif private.dbData[key] then
                if type(private.dbData[key]) == "table" then
                    private.data[key] = copyTable(private.dbData[key])
                    return private.data[key]
                else
                    return private.dbData[key]
                end
            end
        end,

        __newindex = function(tb,key,value)
            private.data[key] = value
        end
    }

    setmetatable(self, meta)
    self.init()

    -- --------------------------------------------------

    return self
end
