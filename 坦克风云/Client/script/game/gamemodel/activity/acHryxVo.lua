
acHryxVo = activityVo:new()
function acHryxVo:new()
	local nc = {}
	setmetatable(nc,self)
	self.__index = self

	return nc
end

function acHryxVo:updateSpecialData(data)
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

        if data._activeCfg.picket then--门票
            self.picket = data._activeCfg.picket
        end

        if data._activeCfg.rankReward then
            self.rankReward = data._activeCfg.rankReward
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

    if not self.rankList then
        self.rankList = {}
    end
    if data.rankList then
        self.rankList = data.rankList
    end
end