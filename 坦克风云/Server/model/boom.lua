function model_boom(uid,data)
    local self = {
        uid = uid,
        boom=0,
        boom_max=0,
        boom_ts=0,
        updated_at = 0,
    }
	
  -- private fields are implemented using locals
  -- they are faster than table access, and are truly private, so the code that uses your class can't get them
  -- local test = uid

    local meta = {
            __index = function(tb, key)
                    return rawget(tb,tostring(key)) or rawget(tb,'p'..key) or 0
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
        if self.boom_ts <= 0 then
            self.boom_ts =  getClientTs()
        end
        if self.updated_at==0 then
            regEventAfterSave(uid,'e8',{})
        end
        return true
    end

    function self.toArray(format)
        local data = {}
            for k,v in pairs (self) do
                if type(v)~="function" and k~= 'uid' and k~= 'updated_at' then              
                    if format then
                        data[k] = v
                    else
                        data[k] = v
                    end
                end
            end

        return data
    end

    -------------------------繁荣度系统------------------------
    --增加繁荣度
    function self.addBoom(nType, params)
        -- body
        if not self.checksys() then
            return false
        end

        local cfg = getConfig('boom')

        local ts = getClientTs()
        local boom_max = 0
        local nCount = 0
        local add = 0
        if nType == 1 then
            --时间增加
            if self.boom_ts == 0 then
                self.boom_ts = ts
            end

            if self.boom >= self.boom_max then
                --更新下时间戳
                return true
            end
            if (ts - self.boom_ts) < 60 then
                return false
            end

            nCount = math.floor( (ts - self.boom_ts) / 60 )
            add = cfg.timeGetBoom * nCount
            boom_max = self.boom_max

            --更新时间点
            self.boom_ts = self.boom_ts + nCount*60

        elseif nType == 2 then
            if type(params) ~= 'table' then
                return false
            end

            --带回资源增加, 四种资源
            -- for i=1, 4 do
            --     local res = "r" .. i 

            --     if params[res] then
            --         nCount =  math.floor( params[res] / cfg.resGetBoom[res].count )
            --         add = add + nCount*cfg.resGetBoom[res].value
            --     end
            -- end
            for k, v in pairs(cfg.resGetBoom) do 
                if params[k] then
                    nCount =  math.floor( params[k] / v.count )
                    add = add + nCount * v.value
                end
            end
           
            boom_max = math.floor( self.boom_max * (1 + cfg.overflowRate))
        elseif nType == 3 then
            --钻石购买
            add = params.add
            boom_max = self.boom_max
        end
        --超出最大值
        if (self.boom + add) > boom_max then
            add = boom_max - self.boom
        end

        if add > 0 then
            self.boom = self.boom + add
            regEventAfterSave(self.uid,'e8',{})
        end

        if add < 0 then add = 0 end
        
        return add
    end

    --减少繁荣度, nRate - 损失对方比例
    function self.decBoom(nRate, rateAdd)
        -- body
        if not self.checksys() then
            return 
        end        
        
        --writeLog( self.uid ..'  dec boom ----> ' .. self.boom, 'boom')
        --遭受攻击损失
        local cfg = getConfig('boom')
        self.update()
        
        local lostRate  = (1 - nRate) / (2*( 1 + nRate))

        if lostRate > 1 or lostRate <= 0 then
            return false
        end 

        -- 损失繁荣度检测
        if self.boom >= self.boom_max then
            self.boom_ts = getClientTs()
        end

        local delBooms = 0
        if rateAdd and rateAdd>0 and rateAdd<=1 then
            delBooms = math.floor( self.boom * lostRate * rateAdd)
        end

        self.boom = math.floor( self.boom *(1 - lostRate) )
        self.boom = self.boom - delBooms
        if self.boom < 0 then self.boom=0 end
        --writeLog( self.uid .. '  dec ::  ' .. self.boom, 'boom' )
        regEventAfterSave(self.uid,'e8',{})
    end

    --繁荣度效果
    function self.effectBoom(nType)
        -- body
        if not self.checksys() then
            return 0
        end
        self.update()

        local cfg = getConfig('boom')
        local add = 0

        if nType == 1 then
            if self.checksys(nType) then
                --带兵量
                add = math.floor(self.boom / cfg.effect.troops.count) * cfg.effect.troops.value
            end
        elseif nType == 2 then
            if self.checksys(nType) then
                --资源产量
                add = math.floor(self.boom / cfg.effect.resource.count) * cfg.effect.resource.value
            end
        elseif nType == 3 then
            --超出最大繁荣度，提高掠夺值 
            if self.boom > self.boom_max then
                add = cfg.pillageRate  
            end
        end

        return add

    end

    -- 计算最大繁荣度
    function self.calcBoom_max()
        -- body
        local cfg = getConfig('boom')
        local uobjs = getUserObjs(self.uid)
        local mBuildings = uobjs.getModel('buildings')

        local boom_max = 0
        -- for k, v in pairs(cfg.maxBoom) do
        --     if mBuildings[k] and next( mBuildings[k] ) and mBuildings[k][2] > 0 then
        --         local add = v.base + v.add * mBuildings[k][2]
        --         boom_max = boom_max + add
        --     end
        -- end

        for k, v in pairs(mBuildings) do
            local build = string.sub(k, 1, 1) 
            if build == 'b' and type(v) == 'table' and next(v) then
                local item = cfg.maxBoom['t' .. v[1]]
                if item then
                    local add = item.base + item.add * v[2]
                    boom_max = boom_max + add
                end                
            end
        end

        if self.boom_max ~= boom_max and self.boom >= self.boom_max then
            self.boom_ts = getClientTs()
            regEventAfterSave(self.uid,'e8',{})
        end

        self.boom_max = boom_max

        return self.boom_max
    end

    --系统开关
    function self.checksys(nType)
        -- body
        local boomSwitch = getModuleIs().boom

        if not nType and boomSwitch and boomSwitch.enable == 1 then
            return true
        elseif nType==1 and boomSwitch and boomSwitch.troops == 1 then
            return true
        elseif nType==2 and boomSwitch and boomSwitch.resource == 1 then
            return true 
        end

        return false
    end

    --更新繁荣度
    function self.update( )
        -- body
        self.calcBoom_max()        
        --检测时间增加繁荣度
        self.addBoom(1)
    end

    return self
end	
