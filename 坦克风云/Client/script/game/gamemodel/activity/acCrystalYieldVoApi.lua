acCrystalYieldVoApi = {

}

function acCrystalYieldVoApi:clearAll()

end

function acCrystalYieldVoApi:getAcVo()
	return activityVoApi:getActivityVo("crystalHarvest")
end

function acCrystalYieldVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acCrystalYieldVoApi:updateShow()
    local vo=self:getAcVo()
    activityVoApi:updateShowState(vo)
end


--今日是否领取水晶
function acCrystalYieldVoApi:isTodayReceive()
   if self:getAcVo().t==G_getWeeTs(base.serverTime) then
      --凌晨时间跟当前凌晨时间相同则表示领过 不能领取
      return false
   else
      return true
   end
end
function acCrystalYieldVoApi:setIsReceive()
    self:getAcVo().t=G_getWeeTs(base.serverTime)
end
--超量水晶已购买次数
function acCrystalYieldVoApi:getBuyCount()
    if self:getAcVo().d==nil then
        self:getAcVo().d={p96=0}
    end
    return self:getAcVo().d.p96
end
--设置超量水晶已购买次数
function acCrystalYieldVoApi:setBuyCount(count)
    self:getAcVo().d.p96=count
end


function acCrystalYieldVoApi:getRouletteCfg()
	return activityCfg.wheelFortune.serverreward
end

function acCrystalYieldVoApi:getFlag(idx)
	return self.flag[idx]
end
function acCrystalYieldVoApi:setFlag(idx,value)
	if idx then
		if value then
			self.flag[idx]=value
		else
			self.flag[idx]=1
		end
	else
		if value then
			self.flag={value,value,value}
		else
			self.flag={1,1,1}
		end

	end
end

function acCrystalYieldVoApi:getLastListTime()
	return self.lastListTime
end
function acCrystalYieldVoApi:setLastListTime(time)
	self.lastListTime=time
end

function acCrystalYieldVoApi:getCostRewardNum()
	local cfg=self:getRouletteCfg()
	local vo=self:getAcVo()
	local consume=0
	if vo and vo.consume then
		consume=vo.consume
	end
	local num=math.floor(consume/cfg.lotteryConsume)
	return num
end
function acCrystalYieldVoApi:getUsedNum()
	local vo=self:getAcVo()
	local usedNum=0
	if vo and vo.hasUsedFreeNum and vo.hasUsedNum then
		usedNum=vo.hasUsedFreeNum+vo.hasUsedNum
	end
	return usedNum
end
function acCrystalYieldVoApi:getLeftNum()
	local totleNum=self:getCostRewardNum()
	local vo=self:getAcVo()
	local leftNum=0
	local freeNum=0
	if acCrystalYieldVoApi:acIsStop()==false then 
		local hasUsedNum=self:getUsedNum()
		if vo and vo.hasUsedFreeNum and vo.hasUsedNum then
			if playerVoApi:getVipLevel()~=nil and playerVoApi:getVipLevel()>0 then
				freeNum=2-vo.hasUsedFreeNum
				-- freeNum=freeNum+1
			else
				freeNum=1-vo.hasUsedFreeNum
			end
			if freeNum<0 then
				freeNum=0
			end
			-- if G_isToday(vo.lastTime)==false then
			-- 	freeNum=freeNum+1
			-- end
			leftNum=totleNum+freeNum-vo.hasUsedNum--hasUsedNum
		end
		if leftNum<0 then
			leftNum=0
		end
	else
		leftNum=0
	end
	return leftNum
end

function acCrystalYieldVoApi:checkCanPlay()
	local vo=self:getAcVo()
	local leftNum=self:getLeftNum()
	if leftNum>0 and self:acIsStop()==false and activityVoApi:isStart(vo) then
		return true
	end
	return false
end

function acCrystalYieldVoApi:pointRewardUpdate(num)
	local vo=self:getAcVo()
	if vo and num then
		vo.pointRewardNum=num
		activityVoApi:updateShowState(vo)
	end
end

function acCrystalYieldVoApi:canReward()
	if acCrystalYieldVoApi:isTodayReceive() then
		return true
	end
	return false
end

function acCrystalYieldVoApi:isRouletteToday()
	local vo=self:getAcVo()
	if vo and vo.lastTime then
		if self.isToday~=G_isToday(vo.lastTime) and G_isToday(vo.lastTime)==false then	
			vo.consume=0
	        vo.hasUsedNum=0
	        vo.point=0
	        vo.hasUsedFreeNum=0
	        vo.pointRewardNum=0

        	self.isToday=false
        	self:setFlag(nil,0)

        	activityVoApi:updateShowState(vo)

        	return false
		end
	end
	return true
end


function acCrystalYieldVoApi:acIsStop()
	local vo=self:getAcVo()
	if vo and base.serverTime<(vo.et-24*3600) then
		return false
	end
	return true
end
function acCrystalYieldVoApi:isEnd()
	local vo=self:getAcVo()
	if vo and base.serverTime<vo.et then
		return false
	end
	return true
end

