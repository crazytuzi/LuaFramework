acLuckyCatVo = activityVo:new()

function acLuckyCatVo:updateSpecialData(data)

	if self.lastResult == nil then
      self.lastResult = {0,0,0,0}
      -- self.lastResult = {4,4,4,4}
    end

	-- if data.ls ~= nil then
 --      self.lastResult = data.ls
 --    end
 	if data.t then --已抽取奖励次数
 		self.numTime =data.t
 		self.loclotteryTimes = data.t--当前的抽奖的次数
 	end

	if self.numTime==nil or self.numTime == 0 then--下一次抽奖的次数
		self.numTime =1
	end


	if self.currLargeTimes ==nil then --当前抽的金币数量
		self.currLargeTimes =0
	end

	if data.recordPoint then --上榜的最低限制
		self.recordPoint =data.recordPoint
	end
	if self.recordPoint ==nil then
		self.recordPoint =9999
	end

	if data.recordNum then --显示榜单的最大条目
		self.recordNum =data.recordNum
	end

	if data.pool then --
		self.rewardPool =data.pool
	end

	if self.recordList ==nil then
		self.recordList ={}
	end

	if self.isShow==nil then --是否需要显示新的
		self.isShow =false
	end


end