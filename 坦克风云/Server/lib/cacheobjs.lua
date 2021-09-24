function cacheobjs(uid,readOnly)
    -- the new instance
    local self = {
        uid = uid,
        readOnly = readOnly,
        models = {},
        data_original = {},
        data = {}
    }

    if not readOnly and not cacheLock(self.uid) then
        writeLog(self.uid.." cache lock")
        return false
    end

    function self.getCacheKey()
        local key = "z"..getZoneId()..".cdata."..uid
        return key
    end

    function self.indexIs0 (str)
        str = tostring(str)
        local a = tostring(tonumber(str))
        return not (a:len() == str:len())
    end

    -- fetch data from cache and db
    function self.userGet(uid,params)
        local db = getDbo()
        local redis = getRedis()
        local data = {}
        local key
        local result
        local flag = false
        local string = string
        local ipairs = ipairs
        local pairs = pairs
        local type = type
        local table = table

        -- check params
        if type(params) == "string" then
            params = {params}
        elseif type(params) ~= "table" then
            return false
        end
        
        -- read from cache
        key = self.getCacheKey()
        result = redis:hgetall(key)
        
        if type(result) ~= "table" then
            error("bad cache result")
        end
        
        for _, name in ipairs(params) do
            -- process cache data to array
            data[name] = {}            
            local pattern = "^"..name.."%."
            for k, v in pairs(result) do
                local field,n = string.gsub(k,pattern,'',1)
                if n == 1 and v then
                    if tonumber(v) ~= nil and self.indexIs0(v) then
                        data[name][field] = v
                    else
                        local v4lower = string.lower(v) 
                        if v4lower == 'inf' or v4lower == 'infinity' or v4lower == 'nan' then
                        -- if v == 'inf' or v == 'infinity' or v == 'NaN' then
                            data[name][field] = v
                        else
                            data[name][field] = json.decode(v)  or v
                        end
                    end 
                end                
            end

            -- read from db when load failed from cache
            if not next(data[name]) then
                local result = db:getRow("select * from "..name.." where uid=:id",{id=uid})
                if type(result) == "table" and next(result) then
                    flag = true
                    for k,v in pairs(result) do  
                        if tonumber(v) ~= nil and self.indexIs0(v) then
                            data[name][k] = v
                        else
                            local v4lower = string.lower(v) 
                            if v4lower == 'inf' or v4lower == 'infinity' or v4lower == 'nan' then
                                data[name][k] = v
                            else
                                data[name][k] = json.decode(v)  or v
                            end
                        end 
                    end 
                end
           end
        end

        if flag then self.userSet(uid,data) end        
        
        return data
    end

    -- save user data to cache
    function self.userSet(uid,data)
        local redis = getRedis()
        if type(data) ~= 'table' then
            return false
        end

        local cachedata = {}
        local cachekey = self.getCacheKey()
        local ret

        for m,n in pairs(data) do
            for k,v in pairs(n) do
                key = m .. '.' .. k
                cachedata[key] = type(v) == 'table' and json.encode(v) or v
            end
        end

        ret = redis:hmset(cachekey,cachedata)
        redis:expire(cachekey, 86400)
        return ret
    end
    
    function self.userClearCache(uid)
        local redis = getRedis()
        local key = self.getCacheKey()

        --redis:expire(key, 172800)
        return redis:del(key)
    end
    
    -- create user data
    function self.userCreate(data)
        local db = getDbo()
        for k, v in pairs(data) do
           local ret = db:insert(k,v) or 0
           if ret < 1 then
               error('save to db failed'.. db:getQueryString())
           end
        end
        return true
    end
    
    -- update user data
    function self.userUpdate(data)
        local db = getDbo()
        local ret
        
        for k, v in pairs(data) do
            if next(v) then
                --writeLog('****data:'..json.encode(data))
                --local oldUpdateTime = (self.data_original[k]['updated_at'] or 0) + 30
                --debuglog = '###table:'..k..' last_save_ts:'..self.data_original[k]['updated_at']
                --writeLog(debuglog)
                ret = db:update(k,v,"uid="..self.uid.." and updated_at<="..self.data_original[k]['updated_at'])  
                --writeLog('****update'.. db:getQueryString() .. ' ------------------ '.. (ret or 0))              
                if ret==nil or ret < 1 then
                    writeLog('****save to db failed\n' .. (ret or 0) .. (db:getError() or '') .. (db:getQueryString() or ''))
                    return false
                end
            end
        end

        return true
    end
    
    -- load a model data
    function self.load(params)
        self.data_original = self.userGet(self.uid,params)

        if type(self.data_original) == 'table' then
              for k,v in pairs(self.data_original) do
                    self.getModel(k)
              end
        end
    end
        
    function self.getModel(name)
        if not self.models[name] then
            require ('model.'..name)
            if not self.data_original[name] then
                self.data_original[name] = self.userGet(self.uid,{name})[name]
            end
            local class = 'model_'..name
            self.models[name] = _G[class](self.uid,copyTable(self.data_original[name]))
            if next(self.data_original[name]) and (not self.models[name].bind(copyTable(self.data_original[name]))) then
                self.userClearCache(self.uid)
                writeLog("fatal error(Incomplete data): " .. (json.encode(copyTable(self.data_original[name])) or ''))
                error ({code=-99})
            end
        end
        
        return self.models[name]
    end
    
    function self.diff(t1, t2)
        local type = type
        local pairs = pairs
        
        if t1 == t2 then return false; end
        -- 这里可以排除123,"123"这种情况，如果程序中把int类型转成string后再保存，其实是没有必要的 
        -- if tonumber(t1) == tonumber(t2) and tostring(t1) == tostring(t2) then
        --     return false;
        -- end
        if type(t1) ~= 'table' or type(t2) ~= 'table' then return true; end
        
        for k, v in pairs(t1) do
            if type(v) == 'table' then
                if self.diff(v,t2[k]) then return true; end
            else
                if v ~= t2[k] then return true; end
            end
        end
        
        for k, v in pairs(t2) do
            if type(v) == 'table' then
                if self.diff(v,t1[k]) then return true; end
            else
                if v ~= t1[k] then return true; end
            end
        end
        
        return false
    end
    
    -- save user data to db and cache
    function self.save(dbsave)
        --writeLog("save user data"..self.uid)
        if self.models then
            for k,v in pairs (self.models) do
                self.data[k] = v.toArray()
                --self.data[k].updated_at = getClientTs()
                self.data[k].uid = self.uid
            end
            
            local data_insert = {}
            local data_update = {}
                        
            -- check user change data 
            for k,v in pairs (self.models) do
                if next(self.data_original[k]) then                   
                    local diff = {}
                    for m,n in pairs(self.data[k]) do
                        if dbsave or (self.diff(self.data_original[k][m], n) and m~= 'updated_at') then
                            if type(n) == 'table' then
                                diff[m] = json.encode(n)
                            else
                                diff[m] = n
                            end
                        end
                    end

                    if next(diff) then
                        --diff.updated_at = getClientTs()
                        diff.updated_at = os.time()
                        data_update[k] = diff
                    end
                    
                else
                    self.data[k].updated_at = os.time()
                    data_insert[k] = self.data[k]
                end
            end
            
            -- save new user data
            if next(data_insert) then
                if not self.userCreate(data_insert) then
                    return false
                end
                self.userSet(self.uid,data_insert)
            end

            -- update userdata
            if next(data_update) then
                if dbsave then
                    if not self.userUpdate(data_update) then
                        self.userClearCache(self.uid)
                        return false
                    end
                end
                self.userSet(self.uid,data_update)
            end
        end

        return true
    end

    return self
end
