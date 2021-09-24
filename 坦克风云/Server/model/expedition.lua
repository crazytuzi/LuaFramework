function model_expedition()
    local self = {
        rkey = '',
    }

   

    function self.toArray(format)
        local data = {}
        for k,v in pairs (self) do
            if type(v)~="function" and k~= 'updated_at' and k~= 'rkey' then              
                data[k] = v
            end
        end

        return data
    end
    --获取同一档次的所有的远程军
    function self.getExpeditions(grade,limit)

        local Expeditions = {}
        local limit =limit or 0
        local db = getDbo()
        local result = db:getAllRows("select * from expedition where grade = :grade order by updated_at desc limit :limit",{grade=grade,limit=limit})
        if result then
            Expeditions = result
            local uids={}
            for k,v in pairs (result) do
                table.insert(uids,v.uid)
            end
            if next(uids) then    
                self.delExpedition(uids,grade)   
            end
            
        end       
        return Expeditions 
    end


    --获取不同的远征军入库
    function self.getValidExpeditions(grade)    
        local ts = getClientTs()
        local forwardNum = 86400
        local memkey = self.rkey.."grade."..grade
        local redis = getRedis()
        local expeditions = redis:hgetall(memkey)
        if type(expeditions) ~= 'table' or not(next(expeditions)) then
            local db = getDbo()
            local result = db:getAllRows("select * from expedition where  grade =:grade  order by updated_at ASC",{grade=grade})
            
            if result then
                expeditions = result
                for k,v in pairs(result) do
                    redis:hmset(memkey,v.id,json.encode(v))
                end
                redis:expire(memkey,86400)
            else
                return false
            end    
        else
            for k,v in pairs(expeditions) do
                expeditions[k] = json.decode(v)  or v
            end
        end
        
        return expeditions 
    end

    -- 更新远征军
    function self.setExpedition(uid,grade,params)
        params.updated_at = getClientTs() 
        local db = getDbo()            
        local ret = db:update("expedition",params,"uid='".. (db.conn:escape(uid) or 0) .. "' and grade="..grade)        
        if ret and ret > 0 then
            local redis = getRedis()
            if redis:del(self.rkey.."grade."..grade) == 1 then
                return true
            end
            return true
        end

        return false
    end
    -- 删除不是这些uids同一档多余的数据
    function self.delExpedition(uids,grade)
        local db,result = getDbo()
        local str=table.concat( uids, ",")
        result = db:query("delete from expedition where uid not in (" .. str .. ") and grade=" .. grade)
        local key=self.rkey.."grade."..grade
        local redis = getRedis()
        redis:del(key)

        return result

        
    end

    -- 创建新远征军数据
    function self.createExpedition(params)
        params.updated_at = getClientTs()    
        local grade =params.grade
        local db = getDbo()
        local flag =self.getGradeUser(params.uid,grade)
        if flag then 
            local ret= self.setExpedition(params.uid,params.grade,params)
            return ret
        else
            local ret = db:insert("expedition",params)
            if ret and ret > 0 then
                local redis = getRedis()
                if redis:del(self.rkey.."grade."..grade) == 1 then
                    return true
                end
                return true
            end
        end
       
        
    end
    --  获取远征单人单挡的数据
    function self.getGradeUser(uid,grade)

        local db = getDbo()
        local result = db:getRow("select * from expedition where  grade =:grade and uid=:uid ",{grade=grade,uid=uid})
        if result then
            return result
        end     

        return false
    end

    function self.setRkey()
        local zoneid = 'z' .. getZoneId()
        self.rkey = zoneid .. ".expedition"
    end

    self.setRkey()
    return self

end