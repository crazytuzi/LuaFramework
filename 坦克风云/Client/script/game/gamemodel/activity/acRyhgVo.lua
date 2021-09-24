--[[
活动荣耀回归 Vo

@author JNK
]]

acRyhgVo = activityVo:new()
function acRyhgVo:new()
	local nc = {}
	setmetatable(nc,self)
	self.__index = self

	return nc
end

function acRyhgVo:updateSpecialData(data)
    -- 配置
    if data._activeCfg then
        if data._activeCfg.returnReward then
            self.returnReward = data._activeCfg.returnReward
        end

        if data._activeCfg.newReward then
            self.newReward = data._activeCfg.newReward
        end

        if data._activeCfg.version then
            self.version = data._activeCfg.version
        end

        if data._activeCfg.returnVipItem then
            self.returnVipItem = data._activeCfg.returnVipItem
        end

        if data._activeCfg.notLoginDay then
            self.notLoginDay = data._activeCfg.notLoginDay
        end

        if data._activeCfg.type then
            self.acCfgType = data._activeCfg.type
        end
    end

    -- 数据返回
    if data.code then -- 激活码
        self.code = data.code
    end
    if data.hg then -- 回归状态
        self.hg = data.hg
    end
    if data.r then -- 领取状态
        self.r = data.r
    end
    if data.num then -- 返回数量
        self.num = data.num
    end
    if data.use then -- 使用状态即VIP因为vip肯定大于0
        self.use = data.use
    end
end