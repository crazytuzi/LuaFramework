acRechargeDoubleVoApi={}

function acRechargeDoubleVoApi:getAcVo()
	return activityVoApi:getActivityVo("rechargeDouble")
end

function acRechargeDoubleVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	return timeStr
end

function acRechargeDoubleVoApi:init(callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			local vo=self:getAcVo()
			vo:updateSpecialData(sData.data.useractive.rechargeDouble)
			if(callback)then
				callback()
			end
		end
	end
	socketHelper:getRechargeDouble(1,nil,onRequestEnd)
end

--获取某档次的充值状态
--param type: 要获取的充值档
--return <0: 已领取
--return >0: 可领取
--return 0: 未充值
function acRechargeDoubleVoApi:getChargeStatus(type)
	local vo=self:getAcVo()
	if(vo.rewardTb and vo.rewardTb[type])then
		return vo.rewardTb[type]
	else
		return 0
	end
end

--领奖
--param type: 充值档的id
function acRechargeDoubleVoApi:getReward(type,callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			local vo=self:getAcVo()
			vo.rewardTb[type]=-1
			local gem=tonumber(string.sub(type,2))
			if(gem)then
				local playerGem=playerVoApi:getGems()
				playerGem=playerGem+gem
				playerVoApi:setGems(playerGem)
			end
			activityVoApi:updateShowState(vo)
			if(callback)then
				callback()
			end
		end
	end
	socketHelper:getRechargeDouble(2,type,onRequestEnd)
end

function acRechargeDoubleVoApi:canReward()
	local vo=self:getAcVo()
	if(vo.rewardTb)then
		for k,v in pairs(vo.rewardTb) do
			if(v>0)then
				local storeCfg=G_getPlatStoreCfg()
				local flag=false
				for kk,vv in pairs(storeCfg.gold) do
					if(tonumber(vv)==tonumber(v))then
						flag=true
						break
					end
				end
				if(flag==true)then
					return true
				end
			end
		end	
	end
	return false
end

function acRechargeDoubleVoApi:clearAll()
	local vo=self:getAcVo()
	if(vo and vo.clear)then
		vo:clear()
	end
end