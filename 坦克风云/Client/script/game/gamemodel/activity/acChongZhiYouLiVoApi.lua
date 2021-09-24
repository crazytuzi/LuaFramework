acChongZhiYouLiVoApi={}

function acChongZhiYouLiVoApi:getAcVo()
	return activityVoApi:getActivityVo("chongzhiyouli")
end

function acChongZhiYouLiVoApi:getAcName( )
	local vo = self:getAcVo()
	local acName 
	if vo and vo.acName then
		acName = vo.acName
	else 
		acName = getlocal("rechargeGifts_defaultName")
	end
	return acName
end

function acChongZhiYouLiVoApi:getRechargeMone( )
	local vo = self:getAcVo()
	if vo and vo.rechargeMone then
		return vo.rechargeMone
	end
	return nil
end

function acChongZhiYouLiVoApi:getRecMone( )
	local vo = self:getAcVo()
	if vo and vo.recMone then
		return vo.recMone
	end
	return nil
end

function acChongZhiYouLiVoApi:getHadRecTime()--最后一次领奖凌晨时间戳
	local vo = self:getAcVo()
	if vo and vo.hadRecTime then
		return G_isToday(vo.hadRecTime)
	end
	return false
end
function acChongZhiYouLiVoApi:setHadRecTime()
	local  vo = self:getAcVo()
	self:updateLastTime()
	if vo  and vo.lastTime then
			 vo.hadRecTime=vo.lastTime

	end
end

function acChongZhiYouLiVoApi:getHadRechargeMone( )--充值的金币数
	local vo = self:getAcVo()
	if vo and vo.hadRechargeMone then
		return vo.hadRechargeMone
	end
	return 0 
end

function acChongZhiYouLiVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end
function acChongZhiYouLiVoApi:updateLastTime()
	local vo = self:getAcVo()
	if vo then
		vo.lastTime = G_getWeeTs(base.serverTime)
	end
end
function acChongZhiYouLiVoApi:refreshData()
	local vo = self:getAcVo()
	if vo then
		if G_isToday(vo.lastTime)==false then
			vo.hadRechargeMone=0
		end
	end
end


function acChongZhiYouLiVoApi:updateRecharge(money)
	local vo = self:getAcVo()
	if vo then
		if self:isToday()==false then
			vo.hadRechargeMone = 0
		 	self:setDailyRechargeNum(money)
			self:updateLastTime()
		end
		self:addAllRechargeNum(money)
	end
end
function acChongZhiYouLiVoApi:addAllRechargeNum(add)
	local vo = self:getAcVo()
	if vo then
		if vo.hadRechargeMone == nil then
			vo.hadRechargeMone = 0
		end
		-- if self:isToday() == false then
		-- 	vo.hadRechargeMone = 0
		-- end
		vo.hadRechargeMone = vo.hadRechargeMone + add
		self.addRechargeTrue=true
	end
end

function acChongZhiYouLiVoApi:setDailyRechargeNum(num)
	local vo = self:getAcVo()
	if vo then
		vo.addRechargeMone = num
	end
end
-- function acChongZhiYouLiVoApi:getZeroTime( )--重置充值金币的凌晨时间戳
-- 	local vo = self:getAcVo()
-- 	if vo and vo.zeroTime then
-- 		return vo.zeroTime
-- 	end
-- 	return nil
-- end

function acChongZhiYouLiVoApi:canReward()

	if self:getHadRecTime()==nil then
		if self:getHadRechargeMone() and self:getRechargeMone() then
			if self:getHadRechargeMone( ) >= self:getRechargeMone( )  then
				return true
			end
		end
		if self:getRechargeMone() and self:getHadRechargeMone() then
			if self:getRechargeMone( ) == 0 and self:getHadRechargeMone()>0 then
				return true
			end
		end 
	end

	return false
end