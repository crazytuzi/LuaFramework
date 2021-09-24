--
-- 禁言
-- User: luoning
-- Date: 14-10-30
-- Time: 下午4:44
--
function model_blacklist(uid,data)

    local self = {
        uid = uid,
        info = "",
        count = 0,
        st = 0,
        et = 0,
        fresh = 0,
        config = {},
        updated_at = 0,
    }

    function self.bind(data)
        if type(data) ~= 'table' then
            return false
        end

        for k,v in pairs (self) do
            local vType = type(v)
            if vType~="function" and k ~= 'config' then
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
            if type(v)~="function" and k~= 'uid' and k~= 'updated_at' and k~= 'config' then
                if format then
                    if type(v) == 'table'  then
                        data[k] = v
                        -- if next(v) then data[k] = v end
                    elseif v ~= 0 and v~= '0' and v~='' then
                        data[k] = v
                    end
                else
                    data[k] = v
                end
            end
        end

        return data
    end

    --禁言用户
    function self.addBlackList(nickname)

        local nowWeelTime = getWeeTs()
        local nowTime = getClientTs()
        --每日重置禁言次数
        if self.fresh < nowWeelTime then
            self.count = 0
            self.st = 0
            self.fresh = nowWeelTime
        end
        --用户在禁言期间不记录次数
        if nowTime < self.et then
            return false
        end
        self.count = self.count + 1
        self.info = nickname
        --检查次数
        local cfg = self.getCustomCfg()
        if cfg[1] <= self.count then
            self.et = nowTime + cfg[2] * 3600
            self.count = 0
            self.st = nowTime
        end
        return true
    end

    --禁言用户
    function self.limitUser(nowTime, nickname)

        self.info = nickname
        self.count = 0
        self.fresh = 0
        self.et = 0
        self.st = 0

        local cfg = self.getCustomCfg()
        if nowTime~=nil then
             self.et = nowTime
             self.st = getClientTs()
        else
            local nowTime = getClientTs()
            self.et = nowTime + cfg[2] * 3600
            self.st = nowTime
        end
       
        return true
    end

    --解除禁言
    function self.removeLimit()
        self.count = 0
        self.fresh = 0
        self.et = 0
        self.st = 0
        return true
    end

    --禁言的时间
    function self.getBlackTime()

        local nowTime = getClientTs()
        if self.et > nowTime then
            return self.et
        end
        return false
    end

    --获取配置
    function self.getCustomCfg()

        if next(self.config) then
            return self.config
        end

        require 'model.customconfig'
        local mCoutomconfig = model_customconfig()
        local config = mCoutomconfig.getCustomConfig('blacklist')
        if config then
            self.config = config
            return config
        end
        self.config = {7,10,10}
        return self.config
    end

    self.bind(data)
    --------------------------------------------------------------
    return self
end

