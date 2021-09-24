acRechargeBagVo = activityVo:new()

function acRechargeBagVo:new()
	local nc={}

	nc.version=0 --当前版本
	nc.limit=0 --累计充值最高限额
	nc.need=0 --达到累计上限后每充值 need 个金币后获取一个红包
	nc.needPoint=0 --进榜所需
	nc.extra={} --达到限额后充值送红包的奖励
	nc.rankReward={} --慷慨榜奖励
	nc.cost={} --充值额度
	nc.reward={} --对应充值额度的奖励
	nc.point=0 --赠送礼包获取的慷慨值

	nc.gemsCount=0 --当前累计充值的金币数
	nc.hasRewardTb={} --当前领取过的礼包的标记
	nc.rankRwardFlag=0 --当前领取慷慨榜奖励的标记
	nc.extraBag=0 --可以领取的红包数量
	nc.dl=0 --已经领取的额外红包的数量
	nc.generosity=0 --当前慷慨值

	setmetatable(nc,self)
	self.__index=self

	return nc
end

--解析来自服务器的活动配置数据
function acRechargeBagVo:updateSpecialData(data)
	if data then
		if data.version then
			self.version=data.version
		end
		if data.limit then
			self.limit=data.limit
		end
		if data.need then
			self.need=data.need
		end
		if data.extra then
			self.extra=data.extra
		end
		if data.rankReward then
			self.rankReward=data.rankReward
		end
		if data.cost then
			self.cost=data.cost
		end
		if data.reward then
			self.reward=data.reward
		end
		if data.v then
			self.gemsCount=data.v
		end	
		if data.r then
			self.rankRwardFlag=data.r
		end
		if data.l then
			self.extraBag=data.l
		end
		if data.dl then
			self.dl=data.dl
		end
		if data.d then
			self.hasRewardTb=data.d
		end
		if data.c then
			self.generosity=data.c
		end
		if data.needPoint then
			self.needPoint=data.needPoint
		end
		if data.point then
			self.point=data.point
		end
	end
end