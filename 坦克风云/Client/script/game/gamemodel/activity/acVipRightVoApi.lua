acVipRightVoApi={}

function acVipRightVoApi:getAcVo()
	return activityVoApi:getActivityVo("vipRight")
end

function acVipRightVoApi:getAcCfg()
	local acVo=self:getAcVo()
	if acVo and acVo.acCfg then
		return acVo.acCfg
	end
	return {}
end

function acVipRightVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.et)
	return timeStr
end

function acVipRightVoApi:canBuy(pid)
	local maxNum=-1
	local acCfg=self:getAcCfg()
	local vipLevel=playerVoApi:getVipLevel()
	for k,v in pairs(acCfg) do
		if v and v.pid and v.pid==pid then
			if v.num4Vip and tonumber(v.num4Vip[vipLevel+1]) then
				maxNum=tonumber(v.num4Vip[vipLevel+1])
			end
		end
	end
	local num=0
	local acVo=self:getAcVo()
	local buyNum=acVo.buyItems or {}
	for k,v in pairs(buyNum) do
		if v and v.key and pid and v.key==pid then
			if tonumber(v.num) then
				num=tonumber(v.num) or 0
			end
		end
	end
	if maxNum>0 and num<maxNum then
		return true
	end
	return false
end
function acVipRightVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
	return vo
end
function acVipRightVoApi:setBuyNum(pid,ts)
	local acVo=self:getAcVo()
	local buyNum=acVo.buyItems or {}
	local isHas=false
	for k,v in pairs(buyNum) do
		if v and v.key and pid and v.key==pid then
			if acVo.buyItems[k].num and acVo.buyItems[k].num>0 then
				isHas=true
				acVo.buyItems[k].num=acVo.buyItems[k].num+1
			end
		end
	end
	local upData={ts=ts}
	if isHas==false then
		upData.d={}
		upData.d[pid]=1
	end
	self:updateData(upData)
end

function acVipRightVoApi:isToday()
	local vo=self:getAcVo()
	return G_isToday(vo.lastBuyTime)
end

function acVipRightVoApi:resetNum()
	local acVo=self:getAcVo()
	if acVo.buyItems==nil then
		acVo.buyItems={}
	end
	for k,v in pairs(acVo.buyItems) do
		if acVo.buyItems[k] and acVo.buyItems[k].num then
			acVo.buyItems[k].num=0
		end
	end
end

function acVipRightVoApi:getVoByPid(pid)
	local acVo=self:getAcVo()
	local buyNum=acVo.buyItems or {}
	-- local isHas=false
	for k,v in pairs(buyNum) do
		if v and v.key and pid and v.key==pid then
			-- isHas=true
			do return v end
		end
	end
	-- if isHas==false then
		local upData={d={}}
		upData.d[pid]=0
		local vo=self:updateData(upData)
	-- end
	local buyNum1=acVo.buyItems or {}
	for k,v in pairs(buyNum1) do
		if v and v.key and pid and v.key==pid then
			do return v end
		end
	end
	return nil
end

function acVipRightVoApi:canReward()
	return false
end
