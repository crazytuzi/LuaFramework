
-- userobjs manage userdata in cache and db
function userobjs(uid,readOnly)
    
    -- the new instance
    local self = {
        uid = uid,
        readOnly=readOnly,
        models = {},
        data_original = {},
        data = {}
    }
    
    
    if not readOnly and not userLock(self.uid) then
        writeLog(self.uid.." lock")
        return false
    end
    
    function self.reset()
        self.models = {}
        self.data_original = {}
        self.data = {}
    end
    
    function self.indexIs0 (str)
        str = tostring(str)
        local a = tostring(tonumber(str))
        return not (a:len() == str:len())
    end

    local function splitField(p)
        local d = "."
        local l=string.find(p,d,0,true)
        if l~=nil then
            return string.sub(p,0,l-1),string.sub(p,l+1)
        end
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
        key = "z"..getZoneId()..".udata."..uid
        result = redis:hgetall(key)
        
        if type(result) ~= "table" then
            error("bad cache result")
        end

        -- 无穷大非数字串,经decode后会处理为数值,encode时会崩溃
        local specialStr = {
            ["-nan"]=1,
            ["-inf"]=1,
            ["-infinity"]=1,
            ["+nan"]=1,
            ["+inf"]=1,
            ["+infinity"]=1,
            ["nan"]=1,
            ["inf"]=1,
            ["infinity"]=1,
        }
        
        for k, v in pairs(result) do
            local name,field = splitField(k)
            if name and field and v then
                if not data[name] then data[name] = {} end

                if tonumber(v) ~= nil and self.indexIs0(v) then
                    data[name][field] = v
                else
                    local v4lower = string.lower(v) 
                    if specialStr[v4lower] then
                        data[name][field] = v
                    else
                        data[name][field] = json.decode(v)  or v
                    end
                end 
            end                
        end

        for _, name in ipairs(params) do   
            if not data[name] then data[name] = {} end

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
                            if specialStr[v4lower] then
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
        local key
        local ret

        for m,n in pairs(data) do
            for k,v in pairs(n) do
                key = m .. '.' .. k
                cachedata[key] = type(v) == 'table' and json.encode(v) or v
            end
        end
        key = "z"..getZoneId()..".udata."..uid
        
        ret = redis:hmset(key,cachedata)
        --redis:expire(key, 172800)
        redis:expire(key, 500)
        return ret
    end
    
    function self.userClearCache(uid)
        local redis = getRedis()
        local key

        key = "z"..getZoneId()..".udata."..uid
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
    
    -- 判断一下只有原数据没有的时候才设置原始数据
    -- 加载数据有load和直接getModel两个方法
    -- 要避免不同的方法查出来的新数据覆盖,userGet方法改造后会把所有数据按model名分类后返回
    local function setOriginalData(data)
        for k,v in pairs(data) do
            if not self.data_original[k] then
                self.data_original[k] = v
            end
        end
    end

    -- load a model data
    function self.load(params)
        for _,name in pairs(params) do
            if not self.data_original[name] then
                setOriginalData(self.userGet(self.uid,params))
                break
            end
        end

        if type(self.data_original) == 'table' then
            for k,v in pairs(self.data_original) do
                self.getModel(k)
            end
        end
    end
        
    function self.getModel(name)
        if not self.models[name] then
            if not self.data_original[name] then
                setOriginalData(self.userGet(self.uid,{name}))
            end

            require ('model.'..name)
            local class = 'model_'..name
            local moduleData = copyTable(self.data_original[name])

            self.models[name] = _G[class](self.uid,moduleData)
            if next(self.data_original[name]) and (not self.models[name].bind(moduleData)) then
                self.userClearCache(self.uid)
                writeLog(tostring(name) .. " model fatal error(Incomplete data): " .. tostring(json.encode(copyTable(self.data_original[name]))))
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
    function self.save()
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
                        if self.diff(self.data_original[k][m], n) and m~= 'updated_at' then
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
                if not self.userUpdate(data_update) then
                    --writeLog("[fucking save]"..json.encode(self.data_original).."\n\n",'save')

                    ------------------------------------------------------------
                    --[[
                    local db = getDbo()
                    local redis = getRedis()
                    local params = {'userinfo'}

                    local data = {}
                    local key
                    local result
                    local flag = flase
                    local uid = self.uid

                    key = "z"..getZoneId()..".udata."..uid
                    result = redis:hgetall(key)

                    if type(result) ~= "table" then
                        error("bad cache result")
                    end
                    
                    for _, name in ipairs(params) do
                        -- process cache data to array
                        data[name] = {}
                        for k, v in pairs(result) do
                            if (string.find(k,"^"..name.."%.")) then
                                k = string.gsub(k,name..'%.','',1)
                                if type(v)=="string" then
                                    local tmpvar = json.decode(v)
                                    if tmpvar then
                                        data[name][k] = tmpvar
                                    else
                                        data[name][k] = v
                                    end
                                else
                                    data[name][k] = v
                                end
                            end
                        end
                    end

                --writeLog("[redis save] : "..json.encode(data)..'\n\n','save')
                data = nil
                data = {userinfo={}}

                local result = db:getRow("select * from userinfo where uid=:id",{id=self.uid})
                --writeLog("[query string] : "..db:getQueryString().."\n\n",'save')
                local name = 'userinfo'
                if type(result) == "table" and next(result) then
                    flag = true
                    for k,v in pairs(result) do  
                        if type(v)=="string" then
                            local tmpvar = json.decode(v)
                            if tmpvar then                                
                                data[name][k] = tmpvar
                            else
                                data[name][k] = v
                            end
                        else
                            data[name][k] = v
                        end
                    end 
                end
                ]]
                --writeLog("[mysql save] : "..json.encode(data),'save')

                    -------------------------------------------------------------

                    self.userClearCache(self.uid)
                    return false
                end
                self.userSet(self.uid,data_update)
            end
        end
        -- return dataCommit()
        
        for name,model in pairs(self.models) do
            if type(model.saveAfter) == "function" then
                model.saveAfter()
            end
        end
        -- actionLog 可以记了
        setActionLogsStatus()
        return true
    end
    
    -- save user data to db and cache
    function self.commit()

    end
        
    return self
end
