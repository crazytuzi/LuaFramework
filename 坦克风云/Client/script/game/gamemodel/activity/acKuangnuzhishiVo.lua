acKuangnuzhishiVo=activityVo:new()

function acKuangnuzhishiVo:updateSpecialData(data)
	-- self.c 代表是否已经领取过奖励  -1 代表已经领取过
	self.acEt = self.acEt - 86400
	self.refreshTs = self.et - 86400 -- 刷新时间（比如排行结束时间）

	if data.cost then
		self.cost = data.cost
	end
	if data.mul then  -- 10连抽
		self.mul = data.mul
	end
	if data.mulc then --9折
		self.mulc = data.mulc
	end

	if data.t then
		self.lastTime = data.t
	end
	if data.scoreLimit then
		self.scoreLimit = data.scoreLimit
	end
	if data.ranklimit then
		self.ranklimit = data.ranklimit
	end

	if data.l then
		self.myScores = data.l
	end

	if self.rewardlist ==nil then   --{军功量，奖励}
		self.rewardlist = {}
	end
	if data.rewardlist~=nil then
		self.rewardlist= data.rewardlist
	end

	if self.rankReward ==nil then    --{排名，奖励}
		self.rankReward = {}
	end
	if data.rankReward~=nil then
		self.rankReward= data.rankReward
	end

	if data.m then
		self.hadRankReward = data.m
	end

end


function acKuangnuzhishiVo:initRefresh()
    self.needRefresh = true -- 活动结束后是否需要刷新数据（比如排行结束后）
    self.refresh = false -- 活动结束后是否已刷新过数据
end