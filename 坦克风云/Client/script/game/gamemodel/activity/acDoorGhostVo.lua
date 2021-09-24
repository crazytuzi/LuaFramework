acDoorGhostVo=activityVo:new()

function acDoorGhostVo:updateSpecialData(data)
	-- v =是鬼的个数
	if data.v ~=nil then
		self.v = data.v
	end

	-- c =是每个鬼到的档次
	if data.c ~=nil then
		self.c = data.c
	end
	-- l =是今天的花钱抽奖次数 没有默认是0
	if data.l then
		self.refreshCostNum = data.l
	end
	-- l =是今天的免费抽奖次数 没有默认是0
	if data.lf then
		self.free = data.lf
	end

	-- r  是 翻牌的 table  存的几档
	if self.openDoor == nil then
		self.openDoor = {}
	end
	if data.r then
		self.openDoor =data.r
	end

	-- t 是刷新的凌晨时间戳
	if data.t ~=nil then
		self.refreshTime = data.t
	end

	-- info  .q 是前台的六个格子的奖励 gt_g1  是鬼的id
	if self.doorReward == nil then
		self.doorReward = {}
	end
	if data.info and data.info.q then
		self.doorReward = data.info.q
	end



	if data.time~=nil then
		self.MaxOpenDoor = data.time
	end
	if data.refreshCost ~=nil then
		self.refreshCost = data.refreshCost
	end
	if data.vipLv ~=nil then
		self.vipFreeLv = data.vipLv
	end
	if data.maxghost ~=nil then
		self.maxghost = data.maxghost
	end
	if self.ghostReward ==nil then
		self.ghostReward = {}
	end
	if data.ghostReward ~=nil then
		self.ghostReward = data.ghostReward
	end
	
end

function acDoorGhostVo:refreshData(data)
	-- body
end