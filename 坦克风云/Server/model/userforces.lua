--   用户攻击叛军信息

function model_userforces(uid,data)
    local self = {
        uid = uid,
        info ={},
        energy=getConfig('rebelCfg.energyMax'),-- 体力值
        energyts=0,--体力恢复时间
        energybuy=0,--体力购买次数
        buyts=0,  --购买时间
        updated_at = 0,
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


    -- 获取打击叛军是不是连击超过一定次数有加成
    -- id  地图id
    -- exts 叛军过期时间
    function self.getAttackRate(id,exts)
        local ts = getClientTs()
        local count =0
        local flag=true
        if next(self.info) then
            if self.info[1]==id and self.info[2]==exts  and  self.info[3]>=ts then
                flag=false
                count=self.info[4] or 1
                self.info[4]=(self.info[4] or 1) +1
            end
        end
        if flag then
            self.info={id,exts,ts+getConfig('rebelCfg.buffTime'),1}
            count=0
        end
        return count
    end
    -- 移除自己的过期攻打记录
    function self.removeAttackForces()
        local ts = getClientTs()
        local flag=false
        for k,v  in pairs (self.info)  do
            if v[3]<=ts then
                table.remove(self.info,1)
                flag=true
            end
        end
        return flag
      
    end


     -- 恢复体力
    function self.checkEnergy()
        local ts = getClientTs()
        local config = getConfig('rebelCfg')
        local limit = config.energyMax

        if self.energy < limit then
            local add = 1
            local energyts = self.energyts > 0 and self.energyts or ts
            local rtime = config.recoverTime -- energyRecoverySpeed
        
            if ts < energyts then
                ts = energyts
            end
            local rt = ts - energyts --经过时间
            local copies = math.floor(rt / rtime) --份数
            local addEnergy = copies * add -- 份数*产量

            self.energy = self.energy + math.floor(addEnergy)
            if self.energy > limit then
                self.energy = limit
                self.energyts = 0
            else
                self.energyts = ts - (rt - copies * rtime) -- 当前时间 - ( 经过时间 - (份数 * 时间) )
            end
        else
            self.energyts = 0
        end
    end


    -- 购买体力值
    function self.buyEnergy(energy,maxenergy)
        self.checkEnergy()
        self.energy=self.energy+energy
        if self.energy>=maxenergy then
            self.energy=maxenergy
            self.energyts=0
        end
        self.energybuy=self.energybuy+energy
        self.buyts=getClientTs()
    end

    -- 使用体力值
    function self.useEnergy(energy)
        -- body
        self.checkEnergy()
        local energy = energy or 1
        local oldenergy=self.energy
        local energy=self.energy-energy
        if energy<0 then
            return false
        end
        local energyMax=getConfig('rebelCfg.energyMax')
        self.energy=energy
        if self.energy<energyMax and energyMax==oldenergy then
            self.energyts=getClientTs()
        end
        
        return true
    end

    function self.getEnergy()
        self.checkEnergy()
        return self.energy
    end

    
    




    return self

end