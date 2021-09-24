acMidAutumnVo=activityVo:new()
function acMidAutumnVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acMidAutumnVo:updateSpecialData(data)
    if data~=nil then
        if data.version then
            self.version=data.version
        end
        -- 当前福点数
        if data.p then
            self.blessPoint=data.p
        end
        --单次祈福的道具消耗
        if data.need1 and data.need1[2] then
            self.blessCost=data.need1[2]
        end
        --十次祈福道具消耗的翻倍数
        if data.need2 then
            self.multiplier=data.need2
        end
        --祈福页面的奖励展示
        if data.showList then
            self.showList=data.showList
        end
        --排行榜上榜限制，达到 rankLimit 点才能上榜
        if data.rankLimit then
            self.rankLimit=data.rankLimit
        end
        --刷新任务消耗的金币数
        if data.change then
            self.change=data.change
        end
        --固定的任务
        if data.fixedTask then
            self.fixedTask=data.fixedTask
        end
        if data.changedTask then
            self.changedTaskCfg=data.changedTask
        end
        --随机的任务
        if data.tk then
            self.changedTask=data.tk
        end
        --排行奖励
        if data.rankReward then
            self.rankReward=data.rankReward
        end
        --每天免费刷新已使用 为0或者是nil没有使用
        if data.r then
            self.r=data.r
        end
        --今日充值金币数
        if data.v then
            self.chargeCount=data.v
        end
        --是否已经领取了充值礼包
        if data.c then
            self.c=data.c
        end
        --是否已经领取了排行版的奖励
        if data.rk then
            self.rankRewardFlag=data.rk
        end
        if data.t then
            self.lastTime=data.t
        end
        if data.flick then
            self.flick=data.flick
        end
        --中秋攻击月兔叛军掉落的奖励池
        if data.getProp and data.getProp[2] then
            self.rebelReward=data.getProp[2]
        end
        if data.rd then
            self.rd=data.rd
        end
        if data.re then
            self.re=data.re
        end
        if data.gu then
            self.gu=data.gu
        end
        if data.changeTaskLimit then
            self.changeTaskLimit=data.changeTaskLimit
        end
        if data.giftLimit then
            self.giftLimit=data.giftLimit
        end
    end
end