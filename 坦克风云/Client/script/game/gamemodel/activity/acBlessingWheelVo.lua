acBlessingWheelVo = activityVo:new()

function acBlessingWheelVo:new()
	local nc = {}
	--以下是配置数据
	nc.version=0 --当前版本
	nc.cost1=0 --单抽花费的价格
	nc.cost10=0 --10连抽花费的价格
	nc.rewardlist={} --抽奖的奖池

	nc.free=nil-- 抽奖是否免费的数据(为nil或者0时表示有免费次数，大于0表示没有免费次数)

	setmetatable(nc,self)
	self.__index = self

	return nc
end

--解析来自服务器的活动配置数据
function acBlessingWheelVo:updateSpecialData(data)
	if data then
		if data.version then
			self.version=data.version
		end
		if data.cost1 then
			self.cost1=data.cost1
		end
		if data.cost10 then
			self.cost10=data.cost10
		end
		if data.pool then
			self.rewardlist=data.pool
		end
		if data.fn then
			-- print("data.fn==================",data.fn)
			self.free=data.fn
			-- print("self.free==================",self.free)
			
		end
		if data.t then
			self.t=data.t
		end
	end
end