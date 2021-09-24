acTacticalDiscussVo = activityVo:new()

function acTacticalDiscussVo:updateSpecialData(data)


	if data.reStartTime then --抗议上限次数
		self.reStartTime =data.reStartTime
	end
	if self.reStartTime ==nil then
		self.reStartTime =0
	end
	if data.t then
		self.lastTime =data.t
	end
	if data.goldCost1 then
		self.goldCost1 =data.goldCost1
	end

	if data.goldCost2 then
		self.goldCost2 = data.goldCost2
	end

	if data.reward then
		for k,v in pairs(data.reward) do
			self.rewardTb[tonumber(k)+1]=v
		end
	end
	if self.rewardTb ==nil then
		self.rewardTb ={}
	end

	if data.reStartGoldCost then
		self.reStartGoldCostTb = data.reStartGoldCost
	end

	if data.m then --上次抽到的奖励Tb但是未领取 如果有 不走跨天免费，先把这次的给领了 才能走跨天
		self.lastAwardTb =data.m
	end

	if data.t then
		self.lastTime =data.t
	end

	if data.n then --当前的已经抗议过的次数
		self.currRestartTime =data.n
	end

	if self.currRestartTime ==nil then
		self.currRestartTime =0
	end

	if data.f then
		self.freeTime =data.f
	end
	-- if self.freeTime ==nil then
	-- 	self.freeTime=0
	-- end


	if self.clickTag ==nil then
		self.clickTag =0
	end



	if self.needCostNow==nil then
		self.needCostNow =0
	end

	if self.currBigAwardIdx ==nil then
		self.currBigAwardIdx =0
	end




















end