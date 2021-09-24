acShengdankuanghuanVo=activityVo:new()

function acShengdankuanghuanVo:updateSpecialData(data)

	if data.goldVate then
		self.goldVate = data.goldVate
	end

	if data.resourceVate then
		self.resourceVate = data.resourceVate
	end
	if data.smallPoint then
		self.smallPoint = data.smallPoint
	end
	if data.goldVate then
		self.bigPoint = data.bigPoint
	end

	if data.treeReward ==nil then
		self.treeReward = {}
	end
	if data.treeReward then
		self.treeReward = data.treeReward
	end

	if self.hadTreeReward == nil then
		self.hadTreeReward = {}
	end
	if data.t and type(data.t)=="table"  then
		self.hadTreeReward = data.t
	end

	if self.rechargeReward ==nil then
		self.rechargeReward = {}
	end
	if data.v and type(data.v)=="table" then
		self.rechargeReward = data.v
	end
	if data.goods then
		self.goods = data.goods
	end
	if data.version then
		self.version =data.version
	end

end