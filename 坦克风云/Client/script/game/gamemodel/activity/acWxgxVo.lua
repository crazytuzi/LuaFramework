--[[
活动万象更新 Vo

@author JNK
]]

acWxgxVo = activityVo:new()
function acWxgxVo:new()
	local nc = {}
	setmetatable(nc,self)
	self.__index = self

	return nc
end

function acWxgxVo:updateSpecialData(data)
    -- 配置
    if data._activeCfg then
        if data._activeCfg.shoplist then
            self.shoplist = data._activeCfg.shoplist
        end

        if data._activeCfg.recharge then
            self.recharge = data._activeCfg.recharge
        end

        if data._activeCfg.exteriorId then
            self.exteriorId = data._activeCfg.exteriorId
        end

        if data._activeCfg.exteriorCost then
            self.exteriorCost = data._activeCfg.exteriorCost
        end

        if data._activeCfg.unlockNeedPlayerlv then
            self.unlockNeedPlayerlv = data._activeCfg.unlockNeedPlayerlv
        end
        if data._activeCfg.version then
            self.version = data._activeCfg.version
        end
    end

    -- 记录数据
    if data.rd then
        self.rd = data.rd
    end

    if data.v then
        self.v = data.v
    end
end