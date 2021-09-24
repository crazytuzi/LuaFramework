acGeneralRecallVo=activityVo:new()

function acGeneralRecallVo:updateSpecialData(baseData)
	local data = {}
	if baseData and baseData._activeCfg then
		data = baseData._activeCfg
		self.data=data
	end


	if baseData.t then
		self.lastTime =baseData.t
	end

	if baseData.u then -- 1 流失玩家 2 活跃玩家
		self.playertype =baseData.u
	end

	if baseData.bd then --目前只用于流失玩家的绑定信息
		self.bd = baseData.bd
	end

	if baseData.bn then--只用于活跃玩家 累计召回的人数
		self.addRecallNum = baseData.bn
	end

	if baseData.ds then--只用于活跃玩家 每天赠送的次数
		self.handselNum =baseData.ds
	end
	if baseData.dsu then --每天赠送的玩家uid列表
		self.dsu=baseData.dsu
	end
	if self.handselNum ==nil then
		self.handselNum = 0
	end

	if baseData.donateLimit then--只用于活跃玩家 每天赠送的次数上限
		self.handselLimit = baseData.donateLimit
	end

	if baseData.br then
		self.receivedRewardTb = baseData.br
	end

	if baseData.ic then
		self.inviteCode = baseData.ic
	end
----------------------------------------------------
----第一个面板的相关数据信息
	if data.needVip then
		self.needVipTb =data.needVip
	end
	if data.needPeople then
		self.needPeopleTb = data.needPeople
	end

	if self.payPropKeyTb ==nil then
		self.payPropKeyTb = {}
	end

	if data.donateReward then --赠送的礼物数据
		self.donateReward = data.donateReward
	end

	if data.bindReward then
		self.bindReward =data.bindReward
	end
	if data.vipReward then
		self.vipReward =data.vipReward
	end

	if self.receivedRewardTb ==nil then
		self.receivedRewardTb ={}
	end

	if self.lastChatTime ==nil then
		self.lastChatTime =0
	end

	if self.curSid ==nil then--礼物的sid : "i"..5
		self.curSid =0
	end
	if self.curGiftNum ==nil then--礼物的数量
		self.curGiftNum =0
	end
	if self.isNeedGem ==nil then--送礼物是否需要消耗金币，
		self.isNeedGem =0
	end
	if self.curPayGem ==nil then--送礼物消耗的具体金钱
		self.curPayGem =0
	end
	if self.needCurPayProp ==nil then
		self.needCurPayProp =0
	end
	if self.needCurPayPropNum ==nil then
		self.needCurPayPropNum =0
	end
	if self.singleNum ==nil then
		self.singleNum =0 
	end
	if self.myFriend ==nil then--玩家选择的战友:7000093
		self.myFriend =0
	end
	if self.myFriendName ==nil then
		self.myFriendName =""
	end
	----第二个面板的相关数据信息
	if self.isFixGift ==nil then
		self.isFixGift =false
	end
	if self.lastToSend ==nil then
		self.lastToSend ={}
	end

----第二个面板的相关数据信息
	if data.exchange then--任务大奖相关数据
		self.exchange =data.exchange
	end

	if data.task1 then--流失玩家日常任务奖励相关信息
		self.task1 = data.task1
	end
	if data.task2 then--活跃玩家回归日常任务奖励相关信息
		self.task2 = data.task2
	end

	if baseData.v then --当前的任务点数
		self.score=baseData.v
	end
	if baseData.d then --当前已经使用的任务点
		self.d=baseData.d
	end

	if baseData.ex then --任务页面已经兑换的次数
		self.ex=baseData.ex
	end

	if baseData.task then --玩家任务进度
		self.task=baseData.task
	end
	if baseData.tf then --流失或者活跃玩家任务领取次数
		self.tf=baseData.tf
	end
	if baseData.g then --玩家收到的礼物列表
		self.g=baseData.g
	end
	if baseData.s then --玩家当前所有已赠送的物品数量
		self.s=baseData.s
	end
end