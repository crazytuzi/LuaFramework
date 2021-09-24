acXssd2019Vo=activityVo:new()

function acXssd2019Vo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acXssd2019Vo:updateSpecialData(data)
	if data then
		if data._activeCfg then
            self.activeCfg=data._activeCfg
        end
        
        if data.st then
        	self.startTime=data.st
        end
		if data.et then
            self.endTime=data.et  -- 任务
        end
        if data.bf then
        	self.allReward=data.bf   -- 本服任务领取
        end
        if not self.allReward then
			self.allReward={}
		end
		if data.bt then
			self.allRewardNum=data.bt --本服当天任务完成次数
		end
		if not self.allRewardNum then
			self.allRewardNum=0
		end

		if data.pre then
			self.preDayRewardNum=data.pre   -- 前一天本服任务完成次数
		end
		if not self.preDayRewardNum then
			self.preDayRewardNum=0
		end

		if data.tr then
			self.selfReward=data.tr  -- 个人任务完成情况
		end
		if not self.selfReward then
			self.selfReward={}
		end
		if data.td then
			self.selfHaveReward=data.td  -- 个人任务领取
		end
		if not self.selfHaveReward then
			self.selfHaveReward={}
		end

		if data.c then
			self.lotterylreadyNum=data.c  -- 活动中抽奖次数总次数
		end
		if not self.lotterylreadyNum then
			self.lotterylreadyNum=0
		end
		
		
		if data.t then
			self.timeStamp=data.t  -- 跨天时间戳
			self.lastTime = data.t > 0 and data.t or base.serverTime
		end
		if data.p then
			self.integralPoint=data.p --积分
		end
		if not self.integralPoint then
			self.integralPoint=0
		end
		if data.ac then
			self.petalNum=data.ac --奖章数量
		end
		if not self.petalNum then
			self.petalNum=0
		end
		if data.g then
			self.goldLotteryNum=data.g --金币抽奖每日次数
		end
		if not self.goldLotteryNum then
			self.goldLotteryNum=0
		end


		if data.pw then
			self.secretCard=data.pw --密码
		end
		-- if not self.secretCard then
		-- 	self.secretCard={}
		-- end
		if data.d then
			self.secretReward=data.d --领取破译奖励
		end
		if not self.secretReward then
			self.secretReward={}
		end
		if data.tk3 then
			self.secretTask=data.tk3 --密码破译任务
		end
		if not self.secretTask then
			self.secretTask={}
		end

		if data.rp then
			self.pointReward=data.rp --积分奖励是否已领取
		end
		if not self.pointReward then
			self.pointReward=0
		end

		if data.redid then
			self.redid = data.redid
		end

		if not self.redid then
			self.redid=0
		end

		if data.redn then
			self.redBagNum=data.redn --军团红包还可以领取的次数
		end
		if not self.redBagNum then
			self.redBagNum=0
		end

		if data.sn then
			self.secretState=data.sn --当天神秘密码获取状态
		end
		if not self.secretState then
			self.secretState=0
		end

			--------------------------------红包
		if self.sendRedidTb ==nil then
			self.sendRedidTb ={}
		end

		if self.redBagRecordTb ==nil then-----接收当前点击的红包的信息
			self.redBagRecordTb = {}
		end
		if self.corpRedBagRecordTb ==nil then--接收当前点击的军团红包的信息
			self.corpRedBagRecordTb ={}
		end
		-- if data.numLimit then--世界频道相关，抢红包记录最多条数
		-- 	self.numLimit =data.numLimit
		-- end
		-- if self.numLimit ==nil then
		-- 	self.numLimit =10
		-- end

		-------军团红包相关信息
		
		if self.curFlag ==nil then--当前抢到红包返回的  目前只用2 4    flag =1 是抢红包成功   2 --已经领取过   3 -- 红包不存在  4 红包派发完了 
			self.curFlag =0
		end

		if self.receivedCorpRedBagTb ==nil then
			self.receivedCorpRedBagTb ={}
		end
		if self.isNewCorpTbReceived ==nil then
			self.isNewCorpTbReceived = 0
		end

		if self.redBagTagbaseIdx ==nil then
			self.redBagTagbaseIdx = 0
		end


	end
end