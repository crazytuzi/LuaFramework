function model_areacrossinfo(uid,data)
    local self = {
        uid = uid,
        bid='',
        point=0,
        gems=0,
        usegems=0,
        usegems_at=0,
        pointlog={},
        info = {},
        updated_at =0,
    }


    function self.bind(data)
        if type(data) ~= 'table' then
            return false
        end
        
        for k,v in pairs (self) do
            local vType = type(v)
            if vType~="function"  then
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


    function self.init(bid)
        self.info={}
        self.gems=0
        self.usegems=0
        self.pointlog={}
        self.bid=bid
    end

    function self.getFirst()
        local key ="z" .. getZoneId() ..".areacross.winer"
        local redis = getRedis()
        return json.decode(redis:get(key))
    end

    function self.addAdminPoint(point)
        self.point=self.point+point
        return true
    end

    function self.addpoint(point,action)
        if type(self.pointlog)~="table" then self.pointlog={}  end
        if not self.pointlog['rc'] then
            self.pointlog['rc'] = {}
        end
        if not self.pointlog['rc']['add'] then
            self.pointlog['rc']['add'] = {}
        end
        table.insert(self.pointlog['rc']['add'],{getClientTs(),point,action} )
        self.point=self.point+point
        return true
    end   
    --使用积分
    function self.usePoint(matchId,point, tId, limitNum, rewardType, Num)
        --消费积分
       
        if self.point < point then
            return false,-20014
        end
        self.point = self.point - point
        if type(self.pointlog)~="table" then self.pointlog={}  end
        --验证购买数量
        if not self.pointlog['lm'] then
            self.pointlog['lm'] = {}
        end
        if not self.pointlog['lm'][tId] then
            self.pointlog['lm'][tId] = 0
        end
        if self.pointlog['lm'][tId] >= limitNum then
            
            return false,-20015
        end
        self.pointlog['lm'][tId] = self.pointlog['lm'][tId] + 1
        --记录消费信息
        if not self.pointlog['rc'] then
            self.pointlog['rc'] = {}
        end
        if not self.pointlog['rc']['buy'] then
            self.pointlog['rc']['buy'] = {}
        end
        table.insert(self.pointlog['rc']['buy'], {tId, getClientTs()})
        if #self.pointlog['rc']['buy']>Num then
            for i=1,#self.pointlog['rc']['buy']-Num do
                    table.remove(self.pointlog['rc']['buy'],1)
            end
        end
        return true
    end

    return self
end
