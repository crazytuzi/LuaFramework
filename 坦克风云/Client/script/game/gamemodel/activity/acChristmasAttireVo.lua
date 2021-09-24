acChristmasAttireVo=activityVo:new()
function acChristmasAttireVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acChristmasAttireVo:updateSpecialData(data)
    if data~=nil then
        --活动配置数据
        if data._activeCfg then
            if data._activeCfg.version then
                self.version=data._activeCfg.version
            end
            if data._activeCfg.cost1 then --单次装扮消耗
                self.cost1=data._activeCfg.cost1
            end
            if data._activeCfg.cost2 then --多次装扮消耗
                self.cost2=data._activeCfg.cost2
            end
            if data._activeCfg.materialNum then --每层材料数量,由低至高对应1--6层
                self.materialNum=data._activeCfg.materialNum
            end
            if data._activeCfg.flickReward then --闪框格式，对应层数
                self.flickReward=data._activeCfg.flickReward
            end
            --对应每层能兑换的奖励, 由下往上对应1至6层
            --need：每次兑换所需材料数量，随着兑换次数不断增加，超过上限则取上限值
            if data._activeCfg.rewardList then
                self.rewardList=data._activeCfg.rewardList
            end
            --进入排行榜分数限制
            if data._activeCfg.rankLimit then
                self.rankLimit=data._activeCfg.rankLimit
            end
            if data._activeCfg.rankReward then ----排行榜奖励
                self.rankReward=data._activeCfg.rankReward
            end
        end
        --活动玩家数据
        if data.item then --圣诞树当前材料数据
            self.materials=data.item
        end
        if data.r then --礼包兑换数据 key为层数，value为当前已兑换数
            self.exchanges=data.r
        end
        if data.free then --已用的免费次数
            self.free=data.free
        end
        if data.score then --当前圣诞花环数
            self.score=data.score
        end
        if data.t then --上次装扮的时间，用于跨天重置免费次数
            self.lastTime=data.t
        end
        if data.r1 then--是否已经领取过排行榜奖励(记录的是名次,可以查这个值来确定领奖时的名次)
            self.rankRewardFlag=data.r1
        end
    end
end