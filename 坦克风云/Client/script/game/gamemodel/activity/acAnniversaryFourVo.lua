--2017四周年周年庆典活动
--author: Liang Qi
acAnniversaryFourVo=activityVo:new()
function acAnniversaryFourVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	nc.rechargeNum=0			--累计充值数额
	nc.rechargeReward={}		--充值奖励的领取情况, 
	nc.experienceReward={}		--历程奖励的领取情况
	nc.experienceData={}		--历程的数据
	nc.totalPeople=0 			--全服总人数
	nc.achievementReward={}		--成就奖励的领取情况
	return nc
end

function acAnniversaryFourVo:init(type)
	self.type=type
	self.canRewardFlag = false -- 是否有可领取的奖励
	self.stateChanged = false  -- 可领取奖励状态是否发生了改变
	self.over = false -- 是否活动结束（不是活动时间到，是活动的所有操作完成导致的）
	self.hasData=false --useractive里是否返回了该活动的用户数据
	self.initCfg=false --activelist里是否返回了该活动的用户数据,配置数据
	self.isShow=1		--是否显示面板，默认1是显示
	self:initRefresh()

	if(self.paymentListener==nil)then
		local function listener(event,data)
			if(data.num)then
				if(self.rechargeNum==nil)then
					self.rechargeNum=tonumber(data.num)
				else
					self.rechargeNum=self.rechargeNum + tonumber(data.num)
				end
			end
		end
		self.paymentListener=listener
	end
	if(eventDispatcher:hasEventHandler("user.pay",self.paymentListener)==false)then
		eventDispatcher:addEventListener("user.pay",self.paymentListener)
	end
end

function acAnniversaryFourVo:updateSpecialData(data)
	if(data.n)then
		self.rechargeNum=tonumber(data.n)
	end
	if(data.r)then
		self.rechargeReward=data.r
	end
	if(data.pr)then
		self.experienceReward=data.pr
	end
	if(data.usercount)then
		self.totalPeople=tonumber(data.usercount)
	end
	if(self.experienceData==nil)then
		self.experienceData={}
	end
	local keyMap={pj=1,jl=2,jh=3,zj=4,zl=5}
	if(data.per)then
		for k,v in pairs(data.per) do
			if(self.experienceData[keyMap[k]]==nil)then
				self.experienceData[keyMap[k]]={}
			end
			self.experienceData[keyMap[k]][1]=tonumber(v)
			if(self.experienceData[keyMap[k]][1]<=0)then
				self.experienceData[keyMap[k]][1]=0.01
			elseif(self.experienceData[keyMap[k]][1]>=100)then
				self.experienceData[keyMap[k]][1]=99.99
			end
		end
	end
	if(data.s)then
		for k,v in pairs(data.s) do
			if(self.experienceData[keyMap[k]]==nil)then
				self.experienceData[keyMap[k]]={}
			end
			self.experienceData[keyMap[k]][2]=tonumber(v)
		end
	end
	if(data.ar)then
		self.achievementReward=data.ar
	end
	if(data._activeCfg)then
		local cfg=data._activeCfg
		if(cfg.achieveReward)then
			self.achieveCfg=cfg.achieveReward
		end
		if(cfg.progressReward)then
			self.experienceRewardCfg=cfg.progressReward
		end
		if(cfg.reward)then
			self.rechargeCfg=cfg.reward
		end
		if(cfg.openLevel)then
			self.limitLv=tonumber(cfg.openLevel)
		end
	end
end

function acAnniversaryFourVo:clear()
	if(eventDispatcher:hasEventHandler("user.pay",self.paymentListener))then
		eventDispatcher:removeEventListener("user.pay",self.paymentListener)
	end
end