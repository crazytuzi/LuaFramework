acThanksGivingVo = activityVo:new()

function acThanksGivingVo:updateSpecialData(data)
	
	-- if data.ts then
	-- 	self.lastTime =data.ts
	-- end
	if data.taskList then --三个任务通关 的详细内容
		self.taskList = data.taskList
	end

	-- if self.lastRewardTime ==nil then--操作时间戳 
	-- 	self.lastRewardTime =0
	-- end
	if data.t then
		self.lastTime =data.t
	end

	if self.merit == nil then --自己的得到军功数量
		self.merit =0
	end

	if data.j then
		self.merit =data.j
	end

	if self.cargo ==nil then--自己的得到资源数量
		self.cargo =0
	end
	if data.r then
		self.cargo = data.r
	end

	if self.gameLevel ==nil then--自己的通过的关卡数量
		self.gameLevel =0
	end
	if data.c then
		self.gameLevel =data.c
	end

	if self.recAward ==nil then--已经领取的奖励 Tb
		self.recAward ={}
	end
	if data.f then
		self.recAward =data.f
	end
	if data.f then
		self.recAwardq =data.f3
	end
	if data.f2 then
		self.rechargedLogTb = data.f2
	end
	if self.rechargedGold ==nil then--自己的得到数量
		self.rechargedGold =0
	end
	if data.g then
		self.rechargedGold = data.g
	end

	if data.reward then
		self.rechargeAward = data.reward--充值给的奖励信息
	end
	if self.changeData ==nil then
		self.changeData ={}
	end

	if self.rechargeTb ==nil then
		self.rechargeTb={}
	end
	if data.cost then
		self.rechargeTb =data.cost
	end

	if self.sureIdTb ==nil then
		self.sureIdTb={nil,nil,nil}
	end
	if self.sureId==nil then
		self.sureId =0
	end
	if self.cellId ==nil then
		self.cellId =0
	end

	if self.collectEnergyTb ==nil then
		self.collectEnergyTb ={}
	end
	if data.serverTask then
		self.collectEnergyTb =data.serverTask
	end

	if self.energyNum ==nil then
		self.energyNum =0
	end
	if data.globalServerData then
		self.energyNum =data.globalServerData
	end

	if self.isRefresh ==nil then
		self.isRefresh =false
	end

	if self.currTime ==nil then
		self.currTime =0
	end
	if self.isCurr ==nil then
		self.isCurr =false
	end

	if self.rechargeAwardTb ==nil then
		self.rechargeAwardTb = {}
	end
	if data.m  then
		self.rechargeAwardTb = data.m
	end
end