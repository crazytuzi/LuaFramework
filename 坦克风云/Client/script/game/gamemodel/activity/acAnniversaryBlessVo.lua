acAnniversaryBlessVo = activityVo:new()

function acAnniversaryBlessVo:new()
	local nc = {}
	--以下是配置数据
	nc.version=0 --当前版本
	nc.donateLv=0 --赠送好友功能要求的等级
	nc.invite={} --邀请人数和赠送福字个数的配置
	nc.totalGem=0 --每个服务器平分的总钱数
	nc.taskCfg={} --周年狂欢第二个页签的任务配置
	nc.shop={} --第二个页签的礼包配置
	nc.wordCfg={} --活动福字id
	--以上是配置数据

	--以下是动态数据
	nc.words={} --当前玩家拥有的五福数据
	nc.inviteCount=0 --每天邀请的好友数
	nc.get=nil --当天玩家是否已经领取了邀请礼包奖励（nil是没有领取，否则是已领取）
	nc.taskData={} --任务数据
	nc.report={} --本次领取邀请礼包五福数据（存储福字key）
	nc.record={} --当天玩家赠送记录数据{type,name,word,ts} 其中word是福字key，ts是赠送时间；当type=1时 name是接收者 ，type=2时 name是赠送者
	nc.buyData={} --商店购买道具次数的信息
	nc.finishNum=nil --当前已经集齐五福的玩家个数

	setmetatable(nc,self)
	self.__index = self

	return nc
end

--解析来自服务器的活动配置数据
function acAnniversaryBlessVo:updateSpecialData(data)
	if data then
		if data.version then
			self.version=data.version
		end
		if data.friendLv then
			self.donateLv=data.friendLv
		end
		if data.invite then
			self.invite=data.invite
		end
		if data.totalGem then
			self.totalGem=data.totalGem
		end
		if data.task then
			self.taskCfg=data.task
		end
		if data.shop then
			self.shop=data.shop
		end
		if data.word then
			self.wordCfg=data.word
		end
		if data.d and data.d.invite then
			self.inviteCount=data.d.invite
		end
		if data.get then
			self.get=data.get
		end
		if data.d and data.d.task then
			self.taskData=data.d.task
		end
		if data.d and data.d.items then
			self.buyData=data.d.items
		end
		if data.words then
			self.words=data.words
		end
		if data.report then
			self.report=data.report
		end
		if data.record then
			self.record=data.record
		end
		if data.finishNum then
			self.finishNum=data.finishNum
		end
	end
end