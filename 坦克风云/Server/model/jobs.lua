function model_jobs(uid,data)
    local self = {
        uid=uid,
        aid=0, --军团 如果是奴隶这个是被设置的军团id
        job=0, --职位
        end_at=0, --结束时间
        updated_at=0,
    }



        local meta = {
            __index = function(tb, key)
                    return rawget(tb,tostring(key)) or rawget(tb,'h'..key) or 0
            end 
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
                else
                    self[k] = data[k]
                end
            end
        end

        return true
    end

    function self.toArray(format)
        local data = {}
            for k,v in pairs (self) do
                if type(v)~="function" and k~= 'uid' and k~= 'updated_at' then              
                    if format then
                        -- if type(v) == 'table'  then
                        --     if next(v) then data[k] = v end
                        -- elseif v ~= 0 and v~= '0' and v~='' then
                            data[k] = v
                        --end
                    else
                        data[k] = v
                    end
                end
            end

        return data
    end

    -- 获取自己的职位的加成

    function self.getjobaddvalue(id,oldts)
        local value=0
        local ts   =getClientTs()
        local to=false
        if self.job>0 and self.end_at>=ts then
            to=true
        end
        if oldts~=nil and self.end_at>=oldts then
            to=true
        end
        if to then
            local areaWarCfg = getConfig('areaWarCfg')
            if areaWarCfg.jobs[self.job] then
                local buffs=areaWarCfg.jobs[self.job].buff
                local flag=table.contains(buffs,id)
                if(flag)then
                    if areaWarCfg.buff[id] then
                        value=areaWarCfg.buff[id].value
                    end
                    
                end

            end
        end
        return value,self.end_at
    end

    -- 设置国王
    function self.setjob(job)
        self.aid=aid
        self.job=job
        local areaWarCfg = getConfig('areaWarCfg')
        self.end_at=self.getbuffend()
        local uobjs = getUserObjs(self.uid)  
        local mUserinfo = uobjs.getModel('userinfo')
        local execRet,code = M_alliance.setjob{uid=self.uid,aid=mUserinfo.alliance,jobid=job,memuid=uid,count=1,own_at=self.end_at,name=mUserinfo.nickname}
        if not execRet then
            response.ret = code
            return response
        end
        return true
    end


    function self.getbuffend()
        local ts = getClientTs()
        local date  = getWeeTs()
        local weekday=tonumber(getDateByTimeZone(ts,"%w"))
        local areaWarCfg = getConfig('areaWarCfg')
        local startWarTime=areaWarCfg.startWarTime
        local day=areaWarCfg.prepareTime
        if weekday~=day then 
            if weekday>=day then
                date=date-(weekday-day)*86400+day*86400+startWarTime[1]*3600+startWarTime[2]*60
            else
                date=date+(day-weekday)*86400+day*86400+startWarTime[1]*3600+startWarTime[2]*60
            end
        else
            date=date+day*86400+startWarTime[1]*3600+startWarTime[2]*60
        end
        if ts> date then
              date=date+(day+7)*86400  
        end

        return date
    
    end

    return self
end