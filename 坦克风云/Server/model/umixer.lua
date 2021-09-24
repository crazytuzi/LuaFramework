--[[
    极品融合器玩家模块  
]]
function model_umixer(uid,data)
    local self = {
        uid = uid,
        crystal=0,  -- 晶体(代币)
        sequipnum=0,   -- 超级装备投入数
        armornum=0,    -- 海兵方阵投入数
        accessorynum=0,    -- 配件投入数
        alienweaponnum=0,  -- 异星武器投入数
        shop={},    -- 商店已购信息
        day_at = 0, -- 当日时间戳,以此为依据跨天清数据
        updated_at=0,
    }

    -- 重置当天所有数据
    local function resetDailyData()
        self.sequipnum=0
        self.armornum=0
        self.accessorynum=0
        self.alienweaponnum=0
        self.shop={}
    end

    local bean = {}

    function bean.bind(data)
        if type(data) ~= 'table' then
            return false
        end

        for k,v in pairs (self) do
            if data[k] == nil then return false end

            if type(v) == 'number' then
                self[k] = tonumber(data[k]) or data[k]
            else
                self[k] = data[k]
            end
        end

        -- 重置与天相关的数据
        local weeTs = getWeeTs()
        if self.day_at < weeTs then
            self.day_at = weeTs
            resetDailyData()
        end

        return true
    end

    function bean.toArray(format)
        local data = {}
        for k,v in pairs (self) do
            if k~= 'uid' and k~= 'updated_at' then
                data[k] = v
            end
        end

        return data
    end

    function bean.incrSequipNum(num)
        self.sequipnum=self.sequipnum+num
    end

    function bean.incrArmorNum(num)
        self.armornum=self.armornum+num
    end

    function bean.incrAccessoryNum(num)
        self.accessorynum=self.accessorynum+num
    end

    function bean.incrAlienweaponNum(num)
        self.alienweaponnum=self.alienweaponnum+num
    end

    function bean.getCrystal()
        return self.crystal
    end

    function bean.getSequipNum()
        return self.sequipnum
    end

    function bean.getArmorNum()
        return self.armornum
    end

    function bean.getAccessoryNum()
        return self.accessorynum
    end
    
    function bean.getAlienweaponNum()
        return self.alienweaponnum
    end

    -- 商店购买设置次数
    function bean.setShop(item,num)
        if num < 0 then return end
        self.shop[item] = (self.shop[item] or 0) + math.ceil(num)
    end

    -- 获取商品购买次数
    function bean.getPurchases(item)
        return self.shop[item] or 0
    end

    -- 增加晶体
    function bean.addCrystal(num)
        if num > 0 then
            self.crystal = self.crystal + num
            return self.crystal
        end
    end

    -- 使用晶体
    function bean.useCrystal(num)
        if num > 0 and num <= self.crystal then
            self.crystal = self.crystal - num
            return self.crystal
        end
    end

    -- 直接设置晶体值
    function bean.setCrystal(num)
        self.crystal = num
    end

    return bean
end
