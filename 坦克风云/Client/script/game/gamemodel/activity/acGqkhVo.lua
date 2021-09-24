acGqkhVo=activityVo:new()

function acGqkhVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acGqkhVo:updateSpecialData(data)
    if data then
    	if data.t then
	      self.lastTime=data.t
	    end
        if data.f then
            self.f=data.f
        end
    	if data.cost1 then
    		self.cost1=data.cost1 --普通骰子消耗
    	end
    	if data.cost2 then
    		self.cost2=data.cost2 --遥控骰子消耗
    	end
        if data.topPrize then
            self.topPrize=data.topPrize --地图上的大奖格子号  
        end
        if data.double then
            self.double=data.double --双倍奖励金币消耗*2.5   cost1和cost2都乘
        end
        if data.limit then
            self.limit=data.limit --每天20次限制次数
        end
        if data.lvUp then
            self.lvUp=data.lvUp --奖励升级圈数
        end
        if data.version then
            self.version=data.version
        end
        if data.b then
            self.b=data.b --商店购买记录
        end
        if data.s then
            self.s=data.s --第几个格子
        end
        if data.v then
            self.v=data.v --代币数
        end
        if data.point then
            self.point=data.point --本次骰子数
        end
        if data.c then
            self.c=data.c --今天玩了多少次了
        end
        if data.r then
            self.r=data.r -- 第几轮
        end
        if data.log then
            self.log=data.log
        end
    end
end