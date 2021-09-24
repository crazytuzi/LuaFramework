acCuikulaxiuVo=activityVo:new()

function acCuikulaxiuVo:updateSpecialData(data)
	-- self.c 代表是否已经领取过奖励  -1 代表已经领取过
	self.acEt = self.acEt - 86400
	self.refreshTs = self.et - 86400 -- 刷新时间（比如排行结束时间）

	if self.pointReward ==nil then   --{军功量，奖励}
		self.pointReward = {}
	end
	if data.pointReward~=nil then
		self.pointReward= data.pointReward
	end

	if self.rankReward ==nil then    --{排名，奖励}
		self.rankReward = {}
	end
	if data.rankReward~=nil then
		self.rankReward= data.rankReward
	end

	if data.minPoint~=nil then
		self.minPoint = data.minPoint
	end

	if self.hadRewardTb == nil then
		self.hadRewardTb = {}
	end
	if data.p and data.p ~=0 then
		self.hadRewardTb = data.p
	end

	if data.l then
		self.hadRankReward = data.l
	end

end


function acCuikulaxiuVo:initRefresh()
    self.needRefresh = true -- 活动结束后是否需要刷新数据（比如排行结束后）
    self.refresh = false -- 活动结束后是否已刷新过数据
end