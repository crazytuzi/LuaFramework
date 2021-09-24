acBanzhangshilianVo=activityVo:new()
function acBanzhangshilianVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

    --配置数据
    self.rewardCfg={}       --奖励配置
    self.scoreLimit=nil     --多少颗星可以上榜配置
    self.firstAward=nil     --第一次通关倍率配置
    self.cost=nil           --花费金币配置
    self.challengeCfg={}    --关卡配置
    self.dailyAtt=0         --每日最大攻击关卡次数配置
    self.charpter=0         --每章关卡数配置
    self.peakNum=0          --抽取每组tank数量配置

    --玩家活动数据
    self.selectTank=1       --当前选择获得的位置，决定tank种类
    self.lastRefreshTime=0  --上一次抽取tank时间
    self.useTankInfo={}     --可以使用的tank种类
    self.star=0             --获得总星星数
    self.attackNum=0        --今日攻击关卡次数
    self.lastAttackTime=0   --上次攻击关卡时间
    self.challengeInfo={}   --通关信息

	return nc
end

function acBanzhangshilianVo:updateSpecialData(data)
    self.acEt=self.et-86400
    
    --配置数据
    if data.reward then
        self.rewardCfg=data.reward
    end
    if data.scoreLimit then
        self.scoreLimit=tonumber(data.scoreLimit)
    end
    if data.firstAward then
        self.firstAward=tonumber(data.firstAward)
    end
    if data.cost then
        self.cost=tonumber(data.cost)
    end
    if data.challenge then
        self.challengeCfg=data.challenge
    end
    if data.dailyAtt then
        self.dailyAtt=tonumber(data.dailyAtt)
    end
    if data.charpter then
        self.charpter=tonumber(data.charpter)
    end
    if data.peakNum then
        self.peakNum=tonumber(data.peakNum)
    end

    --玩家活动数据
    if data.gt then
        self.selectTank=tonumber(data.gt)
    end
    if data.t then
        self.lastRefreshTime=tonumber(data.t)
    end
    if data.r then
        self.useTankInfo=data.r
    end
    if data.star then
        self.star=tonumber(data.star)
    end
    if data.atc then
        self.attackNum=tonumber(data.atc)
    end
    if data.ats then
        self.lastAttackTime=tonumber(data.ats)
    end
    if data.at then
        self.challengeInfo=data.at
    end
    if data.m then 
        self.isReceive=data.m
    end 
 
end
