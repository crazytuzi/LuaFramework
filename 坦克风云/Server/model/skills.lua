function model_skills(uid,data)
    local self = {
        uid = uid,
        s101 = 0,
        s102 = 0,
        s103 = 0,
        s104 = 0,
        s105 = 0,
        s106 = 0,
        s107 = 0,
        s108 = 0,
        s109 = 0,
        s110 = 0,
        s111 = 0,
        s112 = 0,
        s201 = 0,
        s202 = 0,
        s203 = 0,
        s204 = 0,
        s205 = 0,
        s206 = 0,
        s207 = 0,
        s208 = 0,
        s209 = 0,
        s210 = 0,
        s301 = 0,
        s302 = 0,
        s303 = 0,
        s304 = 0,
        s305 = 0,
        s306 = 0,
        s307 = 0,
        s308 = 0,
        s309 = 0,
        s310 = 0,
        s311 = 0,
        s312 = 0,
        buy_at=0,
        updated_at = 0,
    }
	
    -- private fields are implemented using locals
    -- they are faster than table access, and are truly private, so the code that uses your class can't get them
    -- local test = uid

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
                else
                    self[k] = data[k]
                end
            end
        end

        return true
    end

    function self.toArray(format)
        local newSkill = {"s201","s202","s203","s204","s205","s206","s207","s208","s209","s210","s301","s302","s303","s304","s305","s306","s307","s308","s309","s310","s311","s312"}
        local open = moduleIsEnabled('nbs')
        local data = {}
            for k,v in pairs (self) do
                if type(v)~="function" and k~= 'uid' and k~= 'updated_at' and k~='buy_at' and not table.contains(newSkill,k) then              
                    if format then
                        if type(v) == 'table'  then
                            if next(v) then data[k] = v end
                        elseif v ~= 0 and v~= '0' and v~=''  and k~='buy_at'  then
                            data[k] = v
                        end
                    else
                        data[k] = v
                    end
                end
                if open == 1 and table.contains(newSkill,k) then
                    data[k] = self[k]
                end
            end

        if open == 1 and not format then
            data['buy_at'] = self.buy_at
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
  
    function self.getConfig (sid)
        local cfg
        if sid==nil then
            cfg = getConfig('skill.skillList')
        else
            cfg = getConfig('skill.skillList.'..sid)
        end  
        return cfg
    end
    
    function self.getLevel (sid)
        return self[sid]
    end
    
    function self.upgrade (sid)
        
        -- 当前技能等级不小于最大等级
        local cfg = self.getConfig(sid)
        if self[sid]  >= tonumber(cfg.maxLevel) then
            return false
        end
        self[sid] = self[sid] + 1

        -- 德国七日狂欢
        activity_setopt(self.uid,'sevendays',{act='sd5',v=self,n=1})
        return true
    end

    function self.reset()
        local iPropNums = 0
        local sid = 0
        local cfg = self.getConfig() 
        local pid="p19"
        local items={}
        for i=101,112 do
            sid = 's' .. i 
            if self[sid] and self[sid] > 0 then                 
                for l=self[sid],1,-1 do
                    if cfg[sid]['propRequire'] then
                        iPropNums = iPropNums + arrayGet(cfg,sid .. '>propRequire>' .. l,0)
                        items[pid] = iPropNums
                    else
                        if cfg[sid]['needPropID1']   then
                            for k,v in pairs(cfg[sid]['needPropID1']) do
                                items[k]=(items[k] or 0)+v[1]*l+v[2]
                            end 
                        end  
                    end
                end
                self[sid] = 0 
            end
        end

        for i=201,210 do
            sid = 's' .. i 
            if self[sid] and self[sid] > 0 then                 
                for l=self[sid],1,-1 do
                    if cfg[sid]['needPropID1']   then
                        for k,v in pairs(cfg[sid]['needPropID1']) do
                            items[k]=(items[k] or 0)+v[1]*l+v[2]
                        end
                            
                    end  
                end
                self[sid] = 0 
            end
        end
        for i=301,312 do
            sid = 's' .. i 
            if self[sid] and self[sid] > 0 then  
                local needPropID=cfg[sid]['needPropID1']
                local relationSkill=cfg[sid]['relationSkill']
                local id1=""
                if type(relationSkill)=='table' then
                    for k,id in pairs(relationSkill) do
                        if self[id]>=cfg[sid]['maxLevel'] then
                            if id~=sid then
                                --满级的id和本次id不相等
                                needPropID=cfg[sid]['needPropID2']
                            end
                            id1=id
                            break
                        end
                    end
                    -- 如果有满级的
                    if id1~="" then
                        for tk,tid in pairs(relationSkill) do
                            -- 等于本次最外层循环的不退换资源
                            if tid~=sid then
                                -- 资源1
                                if id1==tid then
                                    if self[tid] and self[tid] > 0 then
                                            for l=self[tid],1,-1 do
                                                local needPropID=cfg[tid]['needPropID1']
                                                if needPropID  then
                                                    for k,v in pairs(needPropID) do
                                                        items[k]=(items[k] or 0)+v[1]*l+v[2]
                                                    end
                                                        
                                                end  
                                            end

                                        self[tid]=0
                                    end
                                else--资源2 
                                    if self[tid] and self[tid] > 0 then
                                        
                                            for l=self[tid],1,-1 do
                                                local needPropID=cfg[tid]['needPropID2']
                                                if needPropID  then
                                                    for k,v in pairs(needPropID) do
                                                        items[k]=(items[k] or 0)+v[1]*l+v[2]
                                                    end
                                                        
                                                end  
                                            end
                                        self[tid]=0
                                    end
                                end
                            end 
                        end
                    end
                end
               
                for l=self[sid],1,-1 do
                    if needPropID  then
                        for k,v in pairs(needPropID) do
                            items[k]=(items[k] or 0)+v[1]*l+v[2]
                        end
                            
                    end  
                end
                self[sid] = 0 
            end
        end
        
        return items
    end

    -- 获取技能加成
    function self.getSkillRate(specialType)
        local rate=0
        local skillCfg=self.getConfig()
        for sid,v in pairs (skillCfg) do
            if v.specialType==specialType then
                if self[sid]>0 then
                    rate=self[sid]*v.skillValue
                end
            end
        end
        return rate
    end

    --获取战斗中技能属性
    function self.getNewSkill()
        local result={}
        local cfg = self.getConfig() 
        for i=301,312 do
            sid = 's' .. i 
            if cfg[sid]['getNewSkill'] and  self[sid]>0 then
                result[cfg[sid]['getNewSkill']]=self[sid]
            end
        end

        return result
    end
    
    return self
end	


