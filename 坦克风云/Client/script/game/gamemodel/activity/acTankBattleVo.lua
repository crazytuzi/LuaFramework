acTankBattleVo = activityVo:new()

function acTankBattleVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acTankBattleVo:updateSpecialData(data)
	if data~=nil then
    	if data.version then
    		self.version = data.version
    	end
        if data.tpoint then -- 坦克得分
            self.tpoint = data.tpoint
        end
        if data.free then -- 免费次数
            self.free = data.free
        end
        if data.vcost then -- vip购买一次消耗金币
            self.vcost = data.vcost
        end
        if data.vipC then -- vip购买次数
            self.vipC = data.vipC
        end
        if data.level then -- 等级限制
            self.level = data.level
        end
        if data.rankReward then -- 排行榜奖励
            self.rankReward = data.rankReward
        end
        if data.reward then -- 无将领列表默认奖励
            self.reward = data.reward
        end
        if data.c then -- 当天攻击的次数
            self.c = data.c
        end
        if data.t then -- 攻击的凌晨时间戳 ，跨天清除v，c
            self.lastTime = data.t
        end
        if data.v then -- 跨天清除v，c
            self.v = data.v
        end
        if data.sid then 
            self.sid = data.sid
        end
        if data.p then
            self.point=data.p
        end
        if data.rpoint then -- 获得积分的比列奖励数
            self.rpoint=data.rpoint
        end
        if data.limit then -- 获得积分的比列奖励数
            self.limit=data.limit
        end
        if data.r then -- 已领取排行榜奖励 1
            self.r=data.r
        end
    end
end