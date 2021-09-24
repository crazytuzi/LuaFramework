acChrisEveVo = activityVo:new()

function acChrisEveVo:updateSpecialData(data)
	if(data.version)then
		self.version=tonumber(data.version)
	end
	if data.reward then
		local reward = data.reward
		self.reward={nil,nil,nil}
		self.rewardIdxBigTb={nil,nil,nil}
		local index = 0
		for k,v in pairs(reward) do
			for m,n in pairs(v) do
				index =index+1
			end
		end
		local needbegin = 0
		for k,v in pairs(reward) do
			local nums = SizeOfTable(v)
			local tb = {}
			local tbIdx = {}
			for i=1,nums do
				needbegin =needbegin+1
				-- print("i----->",needbegin)
				table.insert(tb,v["i"..needbegin])
				table.insert(tbIdx,"i"..needbegin)
			end
			self.reward[k]=tb
			self.rewardIdxBigTb[k]=tbIdx
		end
	end
	if self.reward ==nil then
		self.reward ={}
	end
	if self.chooseRewardIdx ==nil then--三个奖励池的Idx :选择的哪一个奖励池
		self.chooseRewardIdx =1
	end
	if self.chooseReward ==nil then
		self.chooseReward ={}
	end

	if self.selectIconIdx ==nil then
		self.selectIconIdx =0
	end

	if self.selectTb ==nil then
		self.selectTb ={}
	end
	if self.clickTag ==nil then
		self.clickTag =0
	end

	if self.friendTb ==nil then
		self.friendTb ={}
	end
	if self.SureFriend ==nil then
		self.SureFriend ={}
	end

	if data.s then
		self.sendGiftTimesTb =data.s
	end
	if self.sendGiftTimesTb ==nil then-- 送出物品的次数
		self.sendGiftTimesTb ={}
	end

	if data.ds then -- 今天送礼的次数 
		self.sendAllTimes =data.ds
	end
	if self.sendAllTimes ==nil then
		self.sendAllTimes =0
	end

	if data.g then --我的礼品 无玩家信息 只有礼品信息
		self.recGiftTbNoName =data.g
	end
	if self.recGiftTbNoName ==nil then
		self.recGiftTbNoName ={}
	end
	if self.recGiftTb ==nil then
		self.recGiftTb ={}
	end
	if data.t then
		self.lastTime =data.t
	end

	if data.v then--慷慨值 ==爱心值 总共的
		self.loveGems =data.v
	end

	if data.daysend then--每天赠送上限
		self.daysend =data.daysend
	end
	if data.usercount then--接收的礼物上限
		self.usercount =data.usercount
	end

	if data.firstreward then
		self.firstReward =data.firstreward
	end

	if self.choosePayType ==nil then--1  是 用物品抵扣   =0是 用金币代替  3 什么都不是
		self.choosePayType =3 
	end

	if self.tuid ==nil then
		self.tuid =nil
	end
	if self.singleGiftAllData ==nil then
		self.singleGiftAllData ={}
	end

	if self.costType ==nil then
		self.costType ="0"
	end
	if self.firstT ==nil then
		self.firstT =0
	end
	if data.f then
		self.firstT =data.f
	end

	if data.shop then
		self.shop =data.shop
	end
	if self.shop ==nil then
		self.shop ={}
	end
	if data.conditiongems then
		self.conditiongems =data.conditiongems
	end

	if data.buy then
		self.buy = data.buy
	end
	if self.buy ==nil then
		self.buy ={}
	end

	if self.expendLoveGems ==nil then --已消耗的慷慨值
		self.expendLoveGems =0
	end
	if data.d then
		self.expendLoveGems =data.d
	end
	if self.curBuyId ==nil then
		-- self.curBuyId ="0"
	end
	if data.rankPoint then
		self.rankPoint =data.rankPoint
	end
	if self.rankPoint ==nil then
		self.rankPoint =9999999
	end
	if self.rankList ==nil then
		self.rankList ={}
	end

	if self.isCurr ==nil then
		self.isCurr =false
	end
	if self.currTime ==nil then
		self.currTime =0
	end
	if self.recId ==nil then
	end
	if self.recNeedLoves ==nil then
		self.recNeedLoves=0
	end
	if data.rankReward then
		self.rankReward =data.rankReward
	end

	if self.isNewData ==nil then
		self.isNewData =0
	end
	if self.refrInSmallDia ==nil then
		self.refrInSmallDia =0
	end

	if self.gAndListInTb ==nil then
		self.gAndListInTb ={}
	end
	if self.iMax ==nil then
		self.iMax =0
	end
	if data.r then
		self.rewardedhas =data.r
	end
	if self.rewardedhas==nil then
		self.rewardedhas =0
	end
	-- if self.friendName==nil then
	-- end	
end