acZnkhVo=activityVo:new()

function acZnkhVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acZnkhVo:updateSpecialData(data)
	if data==nil then
		return
	end

    --当天零点时间戳 跨天要把c清除变成0
    if data.t ~= nil then
        self.todayTimer = data.t
    end

    --是否使用了免费次数 1:已使用
    if data.c ~= nil then
        self.isUseFree=data.c
    end

    --抽奖获得的积分
    if data.v ~= nil then
        self.lotteryScore=data.v
    end

    --总共抽了几次奖励
    if data.f ~= nil then
        self.totalLotteryNum=data.f
    end

    --领取了排行榜的奖励 1:已领取
    if data.r ~= nil then
        self.isGetRankReward=data.r
    end

    --领取了次数奖励的标识 （存数配置的次数）
    if data.fr ~= nil then
        self.fr=data.fr
    end



	if data._activeCfg==nil then
		return
	end
	local activitCfg=data._activeCfg

	if self.version == nil then
    	self.version = 1
    end
    if activitCfg.version ~= nil then
    	self.version = activitCfg.version
    end

    if activitCfg.openLevel ~= nil then
        self.openLevel = activitCfg.openLevel
    end

    --和谐版
    if activitCfg.hxcfg ~= nil and activitCfg.hxcfg.reward then
    	self.hxReward = activitCfg.hxcfg.reward
    end

    if activitCfg.rankLimit ~= nil then
        self.rankLimit=activitCfg.rankLimit
    end

    --单抽所需要的金币数
    if activitCfg.cost ~= nil then
        self.oneLotteryCost=activitCfg.cost
    end

    --五抽所需要的金币数
    if activitCfg.cost5 ~= nil then
        self.fiveLotteryCost=activitCfg.cost5
    end

    --抽奖次数奖励
    if activitCfg.rndNumReward ~= nil then
    	self.rndNumReward = activitCfg.rndNumReward
    end

    --抽奖的奖励 1:普通抽奖,2:连号奖,3:年份奖
    if activitCfg.reward ~= nil then
    	self.reward = activitCfg.reward
    end

    if activitCfg.point ~= nil then
        self.point = activitCfg.point
    end

    --排行榜奖励
    if activitCfg.rankReward ~= nil then
    	self.rankReward = activitCfg.rankReward
    end
end