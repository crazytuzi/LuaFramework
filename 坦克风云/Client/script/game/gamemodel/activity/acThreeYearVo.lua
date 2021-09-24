acThreeYearVo=activityVo:new()
function acThreeYearVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acThreeYearVo:updateSpecialData(data)
    if data~=nil then
        if data.version then
            self.version=data.version
        end
        --历史足迹 等级限制
        if data.limitLv then
            self.limitLv=data.limitLv
        end
        --玩家是否有历史足迹的标记
        if data.flag then
            self.flag=data.flag
        end
        --历史足迹配置
        if data.footprize then
            self.footprize=data.footprize
        end
        --成长历史足迹奖励已领取对应的key
        if data.cz then
            self.cz=data.cz
        end
        --成长足迹的信息
        if data.t then
            self.historyInfo=data.t
        end
        --每日刷新商店次数
        if data.limitNum then
            self.limitNum=data.limitNum
        end
        --每次刷新需要消耗的金币数
        if data.needMoney then
            self.needMoney=data.needMoney
        end
        --商店自动刷新的间隔时间
        if data.time then
            self.time=data.time
        end
        --vip专属头像配置
        if data.topPrize then
            self.topPrize=data.topPrize
        end
        --vip专属头像是否领取的标记
        if data.vip then
            self.vip=data.vip
        end
        --今日刷新商店的次数
        if data.c then
            self.refreshNum=data.c
        end
        --手动刷新商店的时间戳，用于跨天清零刷新次数
        if data.r then
            self.r=data.r
        end
        --商店的购买数据
        if data.b then
            self.shopData=data.b
        end
        --商店上次免费刷新时间点
        if data.v then
            self.v=data.v
        end
        --七重福利buff配置
        if data.buff then
            self.buff=data.buff
        end
    end
end