--2018春节充值活动春福临门
--author: Liang Qi
acCflmVoApi={}

function acCflmVoApi:getAcVo()
	return activityVoApi:getActivityVo("cflm")
end

function acCflmVoApi:setActiveName(name)
	self.name=name
end

function acCflmVoApi:getActiveName()
	return self.name
end

--当前是活动时间还是领奖时间
--活动时间可以购买充值，领奖时间不能
--1是活动时间
--2是领奖时间
function acCflmVoApi:checkActiveStatus()
	local endTs=self:getActiveEndTs()
	if(base.serverTime<endTs)then
		return 1
	else
		return 2
	end
end

--检查充值奖励中某一天的某个档位是否已经领取过奖励
--param day: 第几天
--param num: 要检查的充值档位，此处是档位的具体金币数
--return: true or false, true是已经领取过，false是没有领取过
function acCflmVoApi:checkRechargeRewardGet(day,num)
	local acVo=self:getAcVo()
	if(acVo==nil)then
		return false
	else
		if(acVo.rechargetRewardTb and acVo.rechargetRewardTb[tostring(num)])then
			for k,v in pairs(acVo.rechargetRewardTb[tostring(num)]) do
				if(v==day)then
					return true
				end
			end
			return false
		else
			return false
		end
	end
end

--检查最终充值大奖中的某个档位是否已经领取过奖励
--param num: 要检查的充值档位，此处是档位的具体金币数
--return: true or false, true是已经领取过，false是没有领取过
function acCflmVoApi:checkFinalRewardGet(num)
	local acVo=self:getAcVo()
	if(acVo==nil or acVo.finalRewardGetTb==nil)then
		return false
	else
		for k,v in pairs(acVo.finalRewardGetTb) do
			if(v==num)then
				return true
			end
		end
		return false
	end
end

--获取某一天的基金奖励的状态
--param day: 第几天, 1~5
--return: 0是时间没到不能领，1是可领取，2是已领取，3是已过期, 4是奖励中心发的
function acCflmVoApi:checkInvestStatusByDay(day)
	local acVo=self:getAcVo()
	if(acVo==nil or acVo.investType==nil or acVo.investGetTb==nil)then
		return 0
	end
	if(acVo.investGetTb[day] and acVo.investGetTb[day]==1)then
		return 2
	elseif(acVo.investGetTb[day] and acVo.investGetTb[day]==2)then
		return 4
	else
		local buyTime=G_getWeeTs(acCflmVoApi:getBuyInvestTime())
		local curDay=math.floor((G_getWeeTs(base.serverTime) - buyTime)/86400) + 1
		if(day>curDay)then
			return 0
		elseif(day<curDay)then
			return 3
		else
			return 1
		end
	end
end

--检查是否可以购买某个基金
--param index: 基金的ID，1或者2
--return: 0条件不满足，1可以购买，2已经购买过, 3已经过期
function acCflmVoApi:checkCanBuyInvest(index)
	local acVo=self:getAcVo()
	if(acVo==nil)then
		return 0
	else
		if(acVo.investType)then
			return 2
		end
		if(acCflmVoApi:checkActiveStatus()~=1)then
			return 3
		end
		if(index==1)then
			if(playerVoApi:getVipLevel()>=acVo.cfg.vipLimit)then
				return 1
			else
				return 0
			end
		else
			if(acVo.totalRecharge>=acVo.cfg.rechargeLimit)then
				return 1
			else
				return 0
			end
		end
	end
end

--检查某一天是否有没领取的充值奖励可以领取
--param day: 要检查哪一天
--return: true or false
function acCflmVoApi:checkCanRechargeRewardByDay(day)
	local acVo=self:getAcVo()
	if(acVo==nil or acVo.rechargeTb==nil)then
		return false
	end
	local dayRecharge=acVo.rechargeTb[day]
	if(dayRecharge and dayRecharge>0)then
		for k,v in pairs(acVo.cfg.rechargereward) do
			if(dayRecharge>=v[1] and acCflmVoApi:checkRechargeRewardGet(day,v[1])==false)then
				return true
			end
		end
	end
	return false
end

--检查终极充值大奖是否可以领取
--return: true or false
function acCflmVoApi:checkCanRechargeFinalReward()
	local rechargeNum=acCflmVoApi:getFinalRechargeNum()
	local cfg=acCflmVoApi:getCfg().finalreward
	for k,v in pairs(cfg) do
		if(rechargeNum>=v[1] and acCflmVoApi:checkFinalRewardGet(v[1])==false)then
			return true
		end
	end
	return false
end

--获取活动时间的结束时间戳，本活动分为两个状态，前面几天是活动时间，此时可以充值或者购买金币，后面几天是领奖时间，只能领奖。该方法返回的就是活动时间的结束点。由于后台不支持多天领奖时间，因此从逻辑上做一个区分。
function acCflmVoApi:getActiveEndTs()
	local acVo=self:getAcVo()
	if(acVo==nil or acVo.et==nil)then
		return 0
	end
	local cfg=self:getCfg()
	if(cfg.prolongTime==nil)then
		return 0
	end
	local endZeroTime=G_getWeeTs(acVo.et)
	if(endZeroTime~=acVo.et)then
		return endZeroTime - 86400*(cfg.prolongTime - 1)
	else
		return endZeroTime - 86400*cfg.prolongTime
	end
end

--获取领奖时间的结束时间戳, 详情见上面getActiveEndTs方法的注释
function acCflmVoApi:getRewardEndTs()
	local acVo=self:getAcVo()
	if(acVo==nil or acVo.et==nil)then
		return 0
	end
	return acVo.et
end

--获取当前购买的基金
--return: 1 or 2 or nil
function acCflmVoApi:getCurBuyInvest()
	local acVo=self:getAcVo()
	if(acVo==nil or acVo.investType==nil)then
		return nil
	end
	--investType的服务器值是A或者B, 客户端用1,2，做一个转换
	local num=string.byte(acVo.investType) - 64
	if(num~=1 and num~=2)then
		return nil
	end
	return num
end

--获取活动配置
function acCflmVoApi:getCfg()
	local acVo=self:getAcVo()
	if(acVo==nil or acVo.cfg==nil)then
		return {}
	else
		return acVo.cfg
	end
end

--当前是活动的第几天
function acCflmVoApi:getCurrentDay()
	local acVo=self:getAcVo()
	if(acVo==nil)then
		return 0
	end
	local startTs=G_getWeeTs(acVo.st)
	local curTs=G_getWeeTs(base.serverTime)
	return (curTs - startTs)/86400 + 1
end

--获取当前连续充值大奖可以领取的档位
--return: 连续充值大奖可以领取哪个档位，返回值是具体档位的金币数额
function acCflmVoApi:getFinalRechargeNum()
	local acVo=self:getAcVo()
	if(acVo==nil or acVo.cfg==nil or acVo.rechargeTb==nil)then
		return 0
	end
	local curDay=acCflmVoApi:getCurrentDay()
	local canReward=nil
	local continuousDay=acVo.cfg.rechargDay
	local loopEndDay=curDay - continuousDay + 1
	for i=1,loopEndDay do
		local rechargeNum=acVo.rechargeTb[i]
		if(rechargeNum and rechargeNum>0)then
			local minTmp=rechargeNum
			for j=1,continuousDay - 1 do
				local dayNum=acVo.rechargeTb[i + j]
				if(dayNum==nil or dayNum==0)then
					minTmp=nil
					break
				elseif(dayNum<minTmp)then
					minTmp=dayNum
				end
			end
			if(minTmp and (canReward==nil or minTmp>canReward))then
				canReward=minTmp
			end
		end
	end
	return canReward or 0
end

--获取某个档位的连续充值天数
--param num: 要检测的充值档位，此处传具体金币数额
--return: 截止到目前为止连续充值该档位的天数
function acCflmVoApi:getContinuoursRechargeDay(num)
	local acVo=self:getAcVo()
	if(acVo==nil or acVo.cfg==nil or acVo.rechargeTb==nil)then
		return 0
	end
	local curDay=acCflmVoApi:getCurrentDay()
	local todayRecharge=acVo.rechargeTb[curDay]
	local result
	if(todayRecharge and todayRecharge>=num)then
		result=1
	else
		result=0
	end
	if(curDay<=1)then
		return result
	end
	local endDay=math.max(1,curDay - acVo.cfg.rechargDay + 1)
	for i=curDay - 1,endDay,-1 do
		local dayRecharge=acVo.rechargeTb[i]
		if(dayRecharge and dayRecharge>=num)then
			result=result + 1
		else
			break
		end
	end
	return result
end

--获取某一天充值的数额
--param day: 要获取哪一天
function acCflmVoApi:getRechargeNumByDay(day)
	local acVo=self:getAcVo()
	if(acVo==nil)then
		return 0
	end
	return acVo.rechargeTb[day] or 0
end

function acCflmVoApi:canReward()
	local acVo=self:getAcVo()
	if(acVo==nil or acVo.st==nil)then
		return false
	end
	local curDay=acCflmVoApi:getCurrentDay()
	local totalRechargeDay=(acCflmVoApi:getActiveEndTs() - G_getWeeTs(acVo.st))/86400 
	totalRechargeDay=math.min(curDay,totalRechargeDay)
	for i=1,totalRechargeDay do
		if(acCflmVoApi:checkCanRechargeRewardByDay(i))then
			return true
		end
	end
	if(acCflmVoApi:checkCanRechargeFinalReward())then
		return true
	end
	for i=1,acCflmVoApi:getCfg().prolongTime + 1 do
		if(acCflmVoApi:checkInvestStatusByDay(i)==1)then
			return true
		end
	end	
	return false
end

--获取购买基金的时间戳
function acCflmVoApi:getBuyInvestTime()
	local acVo=self:getAcVo()
	if(acVo==nil)then
		return 0
	end
	return acVo.buyTs
end

--领取充值奖励
--param act: final是领取最终奖励，否则根据day参数来判断
--param day: 要领取的是第几天的奖励
--param num: 要领取的是哪一档奖励，具体的档位金币数值
--param callback: 领取成功之后的回调函数
function acCflmVoApi:getRechargeReward(act,day,num,callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if(sData and sData.data and sData.data.cflm)then
				local acVo=acCflmVoApi:getAcVo()
				if(acVo)then
					acVo:updateData(sData.data.cflm)
					local rewardCfg
					local cfg=acCflmVoApi:getCfg()
					if(act=="final" and cfg.finalreward)then
						for k,v in pairs(cfg.finalreward) do
							if(v[1]==num)then
								rewardCfg=v[2]
								break
							end
						end
					elseif(cfg.rechargereward)then
						for k,v in pairs(cfg.rechargereward) do
							if(v[1]==num)then
								rewardCfg=v[2]
								break
							end
						end						
					end
					if(rewardCfg)then
						local rewardTb=FormatItem(rewardCfg)
						for k,v in pairs(rewardTb) do
							G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
						end
						G_showRewardTip(rewardTb)
					end
					activityVoApi:updateShowState(acVo)
					if(callback)then
						callback()
					end
				end
			end
		end
	end
	socketHelper:activeCflmRecharge(day,num,act,onRequestEnd)
end

--购买基金
--param type: 购买哪个基金，1 or 2
--param callback: 购买成功的回调
function acCflmVoApi:buyInvest(type,callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if(sData and sData.data and sData.data.cflm)then
				local acVo=acCflmVoApi:getAcVo()
				if(acVo)then
					local cost
					if(type==1)then
						cost=acCflmVoApi:getCfg().fundA
					else
						cost=acCflmVoApi:getCfg().fundB
					end
					playerVoApi:setGems(playerVoApi:getGems() - cost)
					acVo:updateData(sData.data.cflm)
					local message={key="activity_cflm_chatmsg",param={playerVoApi:getPlayerName()}}
					local paramTab={}
					paramTab.functionStr="cflm"
					paramTab.addStr="goTo_see_see"
					chatVoApi:sendSystemMessage(message,paramTab)
					if(callback)then
						callback()
					end
				end
			end
		end
	end
	--investType的服务器值是A或者B, 客户端用1,2，做一个转换
	socketHelper:activeCflmBuy(string.char(type + 64),onRequestEnd)
end

--领取基金奖励
--param day: 要领取第几天的奖励
--param callback: 领取成功的奖励回调
function acCflmVoApi:getInvestReward(day,callback)
	local acVo=acCflmVoApi:getAcVo()
	if(acVo==nil or acVo.investType==nil)then
		return
	end
	local investType=acVo.investType
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if(sData and sData.data and sData.data.cflm)then
				local acVo=acCflmVoApi:getAcVo()
				if(acVo and acVo.investType)then
					acVo:updateData(sData.data.cflm)
					local rewardCfg=acCflmVoApi:getCfg()["fund"..acVo.investType.."reward"]
					if(rewardCfg and rewardCfg[day])then
						rewardCfg=rewardCfg[day][2]
						local rewardTb=FormatItem(rewardCfg)
						for k,v in pairs(rewardTb) do
							if not (v.type=="u" and v.key=="gems") then
								v.num=v.num*acCflmVoApi:getCfg().needValue
							end
							G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
						end
						G_showRewardTip(rewardTb)
					end
					activityVoApi:updateShowState(acVo)
					if(callback)then
						callback()
					end
				end
			end
		end
	end
	socketHelper:activeCflmInvest(investType,day,onRequestEnd)
end

function acCflmVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage1.plist")
	spriteController:addTexture("public/activeCommonImage1.png")
end

function acCflmVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage1.plist")
	spriteController:removeTexture("public/activeCommonImage1.png")
end

function acCflmVoApi:clearAll()
end