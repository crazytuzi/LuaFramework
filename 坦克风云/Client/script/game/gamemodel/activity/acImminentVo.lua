acImminentVo = activityVo:new()

function activityVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end
function acImminentVo:updateSpecialData(data)

	if data.t then --上次抽奖时间戳
		self.lastTime=data.t
	end
	if data.c then
		self.deepDepth=data.c
	end
	if self.deepDepth ==nil or self.deepStep ==100 then--当前挖掘的深度
		self.deepDepth =0
	end
	if data.consume then --改装需要的道具
		self.consume = data.consume
	end

	-- value=1, -- 每日异星资源上限
 	-- addrate=0.3, -- 采集资源速度加成
	if data.value then 
		self.upperLimit =data.value
	end

	if data.addrate then
		self.increasePick = data.addrate
	end

	if data.cost1 then
		self.cost1 =data.cost1
	end
	if data.cost2 then
		self.cost2 = data.cost2
	end

	if data.deep1 then-- 普通探测 挖掘范围
		self.deep1 = data.deep1
	end
	if data.deep2 then-- 深度探测 探测范围
		self.deep2 = data.deep2
	end

	if data.free then-- 每日获得 免费次数
		self.free =data.free
	end

	if data.reCost then
		self.reCost =data.reCost
	end

	if data.deepStep then--岩层分布
		self.deepStep =data.deepStep
	end

	if data.clientShow then--岩层奖励池
		self.clientShow =data.clientShow
	end

	if data.deepStepClientReward then--完成岩层奖励
		self.deepStepClientReward =data.deepStepClientReward
	end

	if self.curReward==nil then--当前得到的奖励
		self.curReward ={}
	end
	if self.curBigReward==nil then--当前得到的大奖励
		self.curBigReward ={}
	end

	if self.curFloorNums==nil then
		self.curFloorNums=0
	end
end