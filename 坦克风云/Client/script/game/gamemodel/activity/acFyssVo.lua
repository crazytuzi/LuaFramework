acFyssVo=activityVo:new()

function acFyssVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acFyssVo:updateSpecialData(data)
	if data==nil then
		return
	end

	if self.version == nil then
    	self.version = 1
    end
    if data.version ~= nil then
    	self.version = data.version
    end

    if data.flag ~= nil then
    	self.flag = data.flag
    end

    --奖池状态 1:有瓜分资格 2:已领取瓜分奖励
    if data.crow ~= nil then
    	self.acStatus = data.crow
    end

    --已拥有的道具及数量
    if data.words ~= nil then
        self.existingItem = data.words
    end

    --参与活动的道具及数量
    if data.acProp ~= nil then
        self.acProp = data.acProp
    end

    --单次抽奖所需金币数
    if self.oneLotterPrice == nil then
    	self.oneLotterPrice = 0
    end
    if data.cost1 ~= nil then
    	self.oneLotterPrice = data.cost1
    end

    --十连抽所需金币数
    if self.tenLotterPrice == nil then
    	self.tenLotterPrice = 0
    end
    if data.cost2 ~= nil then
    	self.tenLotterPrice = data.cost2
    end

    --兑换奖励列表数据
    if data.trade ~= nil then
        self.exchangeList = data.trade
        for k,v in pairs(self.exchangeList) do
        	self.exchangeList[k].index=k
        end
        local function sortAsc(a, b)
            if a.needNum and b.needNum and tonumber(a.needNum) and tonumber(b.needNum) then
                return a.needNum > b.needNum
            end
        end
        table.sort(self.exchangeList,sortAsc)
    end

    --每日最大免费抽奖次数
    if self.maxFreeLotteryNum == nil then
    	self.maxFreeLotteryNum = 0
    end
    if data.freeNum ~= nil then
    	self.maxFreeLotteryNum = data.freeNum
    end

    --已使用的免费抽奖次数
    if self.useFreeLotteryNum == nil then
        self.useFreeLotteryNum = 0
    end
    if data.f ~= nil then
        self.useFreeLotteryNum = data.f
    end

    --上次抽奖的时间戳
    if data.t ~= nil then
        self.lastTime = data.t
    end

    --单次抽奖次数
    if self.oneLotterNum == nil then
    	self.oneLotterNum = 0
    end
    if data.rewardNum1 ~= nil then
    	self.oneLotterNum = data.rewardNum1
    end

    --十连抽次数
    if self.tenLotterNum == nil then
    	self.tenLotterNum = 0
    end
    if data.rewardNum2 ~= nil then
    	self.tenLotterNum = data.rewardNum2
    end

    --抽奖奖池数据
    if data.pool ~= nil then
        self.lotteryPool = FormatItem(data.pool,nil,true)
    end

    --奖池数据中需要加高亮特效的数据
    if data.flicker ~= nil then
    	self.flicker = data.flicker
    end

    if data.advPropsId ~= nil then
        self.advPropsId = data.advPropsId
    end

    --赠送等级限制
    if data.giftlevel ~= nil then
    	self.giveUpLevel = data.giftlevel
    end

    --最大赠送次数
    if data.presentcount ~= nil then
    	self.maxGiveUpCount = data.presentcount
    end

    if data.lNum then--兑换列表里 最高兑换奖项的兑换次数上线
        self.lNum = data.lNum
    end
    if data.c then--兑换列表里 当前玩家已兑换的次数
        self.hadExNum = data.c
    end
    if not self.hadExNum then
        self.hadExNum = 0
    end

    --最大瓜分上限
    if data.maxbonus ~= nil then
    	self.maxbonus = data.maxbonus
    end

    --和谐版
    if data.hxcfg ~= nil and data.hxcfg.reward then
    	self.hxReward = data.hxcfg.reward
    end

end