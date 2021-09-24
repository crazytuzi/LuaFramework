acSweetTroubleVo=activityVo:new()

function acSweetTroubleVo:updateSpecialData(data)

	if data.ts then
		self.lastTime =data.ts
	end

	if data.ascount then	--抢夺次数
		self.asCounts=data.ascount
	end
	if data.cropcount then 	--种植次数
		self.cropCounts=data.cropcount
	end

	if data.asreward then	--抢夺奖励
		self.asReward = data.asreward
	end
	if self.seeReward ==nil then
		self.seeReward ={}
	end
	if data.reward then
		self.seeReward =data.reward
	end
	
	if self.seedrReward ==nil then
		self.seedrReward ={nil,nil,nil,nil}
	end
	if data.cropreward then	--种植奖励
		self.cropReward =data.cropreward
	end

	if data.sw then		--已经 抢夺次数
		self.snatchedCounts =data.sw
	end
	if self.recvedSnaReward ==nil then
		self.recvedSnaReward =0 
	end
	if data.swr then	--抢夺 是否已经领奖的标识
		self.recvedSnaReward = data.swr
	end
	if data.pc then		--已经 种植次数
		self.cropedCounts =data.pc
	end
	if self.isCroped ==nil then
		self.isCroped =0
	end
	if data.pcr then
		self.isCroped = data.pcr --称号领取标示
	end

	if data.needtime then --4个种子所有种植需要的小时数
		self.needTime = data.needtime 
	end
	if self.needTimesTab ==nil then
		self.needTimesTab={nil,nil,nil,nil,nil,nil}
	end
	if data.p  then
		self.seedGrowTimesTab=data.p
	end
	if self.seedGrowTimesTab ==nil then
		self.seedGrowTimesTab ={}
	end
	if self.dayreward ==nil then
		self.dayreward = {}
	end
	if data.dayreward then	--首充的充值奖励 --需展示
		self.dayReward = data.dayreward
	end

	if data.cost then
		self.cost = data.cost
	end
	if self.totalReward ==nil then
		self. totalReward = {}
	end
	if data.totalreward then	--每到cost领一次
		self.totalReward = data.totalreward
	end

	if self.tgSeedTab ==nil then
		self.tgSeedTab ={}
	end
	if data.tg then				--糖果信息
		self.tgSeedTab =data.tg
	end
	if self.addOrRecTab ==nil then --是否为加速 或是收获的标签 0 加速 1 是收获
		self.addOrRecTab ={nil,nil,nil,nil,nil,nil}
	end
	-- if data.cfg then			--???????
	-- 	self.  =data.cfg
	-- end
	if self.whiPosNum ==nil then --用于设置请求加速时的 第几个位置
		self.whiPosNum =0
	end
	if self.whiSweNum ==nil then--用于设置请求加速时的 第几种糖果
		self.whiSweNum =0
	end
	if self.firCounts ==nil then
		self.firCounts =0
	end
	if data.dc then				-- 每天能领取的奖励次数  首充
		self.firCounts = data.dc
	end
	if self.firRecedCounts ==nil then
		self.firRecedCounts =0
	end
	if data.drc then			-- 每天奖励的已领取次数  首充
		self.firRecedCounts =data.drc
	end

	if data.num then			-- 累计充值的金币数
		self.allRechaGolds = data.num
	end
	if data.c then				-- 已领取累计充值到n金币的次数
		self.countsByGolds=data.c
	end

	if self.gemsecond ==nil then
		self.gemsecond =0
	end
	if data.gemsecond then
		self.gemsecond =data.gemsecond ----加速价格，多少秒一金币 60->秒数
	end
	if self.tab1Data ==nil then
		self.tab1Data =false
	end
	if self.tab2Data ==nil then
		self.tab2Data =false
	end

	if self.isCrossToday ==nil then
		self.isCrossToday =true
	end
	-- if data.p then
	-- 	self.cropedTimesTab = data.p
	-- end
end