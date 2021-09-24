acLoversDayVo=activityVo:new()
function acLoversDayVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acLoversDayVo:updateSpecialData(data)
    if data~=nil then
        --活动配置数据
        if data._activeCfg then
            self.activeCfg=data._activeCfg
        end

        if data.free then --已用的免费次数
            self.free=data.free
        end
        if data.t then --上次挖掘的时间，用于跨天重置免费次数
            self.lastTime=data.t
        end
        if data.v then --代币数量
            self.score=data.v
        end
        
        if data.b then --商店数据
            self.shop=data.b
        end

        if self.curPoint == nil then--当前抽奖得到的配对值
            self.curPoint = 0
        end
        if self.curAwardTb == nil then --当前抽奖得到的奖励id表，用于配对使用
            self.curAwardTb = {}
        end
        if self.curOldAwardTb ==nil then
            self.curOldAwardTb ={}
        end
        if self.curReward ==nil then
            self.curReward = {}
        end
    end
end