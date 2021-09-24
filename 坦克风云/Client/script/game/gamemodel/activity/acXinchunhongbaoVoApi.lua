acXinchunhongbaoVoApi={}

function acXinchunhongbaoVoApi:getAcVo()
	return activityVoApi:getActivityVo("xinchunhongbao")
end

function acXinchunhongbaoVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	return timeStr
end

function acXinchunhongbaoVoApi:updateShow()
    local vo=self:getAcVo()
    activityVoApi:updateShowState(vo)
end

function acXinchunhongbaoVoApi:getSmallPool()
	local vo=self:getAcVo()
	if vo and vo.smallPool then
		return vo.smallPool
	end
	return {}
end
function acXinchunhongbaoVoApi:getBigPool()
	local vo=self:getAcVo()
	if vo and vo.bigPool then
		return vo.bigPool
	end
	return {}
end

function acXinchunhongbaoVoApi:getLoginGems()
	local vo=self:getAcVo()
	if vo and vo.loginGems then
		return vo.loginGems
	end
	return 0
end

function acXinchunhongbaoVoApi:getSmallGiftGems()
	local vo=self:getAcVo()
	if vo and vo.smallGiftGems then
		return vo.smallGiftGems
	end
	return 999999
end

function acXinchunhongbaoVoApi:getBigGiftGems()
	local vo=self:getAcVo()
	if vo and vo.bigGiftGems then
		return vo.bigGiftGems
	end
	return 999999
end

function acXinchunhongbaoVoApi:getDailyTimes()
	local vo=self:getAcVo()
	if vo and vo.dailyTimes then
		return vo.dailyTimes
	end
	return 0
end

function acXinchunhongbaoVoApi:getSmallCost()
	local vo=self:getAcVo()
	if vo and vo.smallCost then
		return vo.smallCost
	end
	return 0
end

function acXinchunhongbaoVoApi:getBigCost()
	local vo=self:getAcVo()
	if vo and vo.bigCost then
		return vo.bigCost
	end
	return 0
end

function acXinchunhongbaoVoApi:getOpenSmall()
	local vo=self:getAcVo()
	if vo and vo.openSmall then
		return vo.openSmall
	end
	return 0
end

function acXinchunhongbaoVoApi:getOpenBig()
	local vo=self:getAcVo()
	if vo and vo.openBig then
		return vo.openBig
	end
	return 0
end


function acXinchunhongbaoVoApi:getShowlist()
	local vo=self:getAcVo()
	if vo and vo.showlist then
		return vo.showlist
	end
	return {}
end

function acXinchunhongbaoVoApi:getRecordNum()
	local vo=self:getAcVo()
	if vo and vo.recordNum then
		return vo.recordNum
	end
	return 0
end

function acXinchunhongbaoVoApi:getGiveFriendsList()
	local vo=self:getAcVo()
	if vo and vo.giveFriendList then
		return vo.giveFriendList
	end
	return {}
end

function acXinchunhongbaoVoApi:getGiveGiftNum()
	local giveFriendList = self:getGiveFriendsList()
	if giveFriendList then
		return SizeOfTable(giveFriendList)
	end
	return 0
end

function acXinchunhongbaoVoApi:addGiveFriendsList(uid)
	local vo=self:getAcVo()
	if vo then
		if vo.giveFriendList==nil then
			vo.giveFriendList={}
		end
		table.insert(vo.giveFriendList,uid)
	end
end

function acXinchunhongbaoVoApi:checkIsCanGiveGiftByID(uid)
	local giveFriendList = self:getGiveFriendsList()
	if giveFriendList and type(giveFriendList)=="table" then
		if SizeOfTable(giveFriendList)>=self:getDailyTimes() then
			return false
		else
			for k,v in pairs(giveFriendList) do
				if v and tonumber(v) == tonumber(uid) then
					return false
				end
			end
		end
	end	
	return true
end

function acXinchunhongbaoVoApi:getHasMedals()
	local vo=self:getAcVo()
	if vo and vo.HasMedal then
		return vo.HasMedal
	end
	return 0
end

function acXinchunhongbaoVoApi:addHasMedals(num)
	local vo=self:getAcVo()
	if vo then
		if  vo.HasMedal ==nil then
			vo.HasMedal =0
		end
		vo.HasMedal =vo.HasMedal + num
	end
end

function acXinchunhongbaoVoApi:reduceHasMedals(num)
	local vo=self:getAcVo()
	if vo then
		if  vo.HasMedal ==nil then
			vo.HasMedal =0
		end
		if vo.HasMedal>= num then
			vo.HasMedal =vo.HasMedal - num
		end
	end
end

function acXinchunhongbaoVoApi:getHadGiftNumTb()
	local vo=self:getAcVo()
	if vo and vo.giftNumTb then
		return vo.giftNumTb
	end
	return {}
end

function acXinchunhongbaoVoApi:addHasGiftNumTb(ktype)
	local vo=self:getAcVo()
	if vo then
		if  vo.giftNumTb ==nil then
			vo.giftNumTb ={}
		end
		if vo.giftNumTb[ktype] then
			vo.giftNumTb[ktype] =vo.giftNumTb[ktype] + 1
		else
			vo.giftNumTb[ktype]=1
		end
	end
end

function acXinchunhongbaoVoApi:reduceHasGiftNumTb(ktype)
	local vo=self:getAcVo()
	if vo then
		if  vo.giftNumTb ==nil then
			vo.giftNumTb ={}
		end
		for k,v in pairs(vo.giftNumTb) do
			if k == ktype and v and v>=1 then
				vo.giftNumTb[ktype] = v-1
			end
		end
	end
end

function acXinchunhongbaoVoApi:getGiftNumByType(ktype)
	local giftNumTb = self:getHadGiftNumTb()
	if giftNumTb then
		for k,v in pairs(giftNumTb) do
			if k == ktype and v then
				return v
			end
		end
	end
	return 0
end
function acXinchunhongbaoVoApi:checkIsChatByID(ptype,pid,pnum)
	local chatList = self:getShowlist()
	if chatList then
		local award = FormatItem(chatList)
		if award then
			for k,v in pairs(award) do
				if v and v.type == ptype and v.key == pid and v.num == pnum then
					return true
				end
			end
		end
	end
	return false

end

function acXinchunhongbaoVoApi:isRefreshMedalTime()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.medalTime then
		isToday=G_isToday(vo.medalTime)
	end
	return isToday
end

function acXinchunhongbaoVoApi:refreshDataToday()
	local vo = self:getAcVo()
	if vo then
		if G_isToday(vo.medalTime)==false then
	    	vo.giveFriendList = {}
	    	--vo.HasMedal=vo.HasMedal+vo.loginGems
	    	vo.medalTime= G_getWeeTs(base.serverTime)
	    end
	end
end



function acXinchunhongbaoVoApi:updateLastTime()
	local vo = self:getAcVo()
	if vo then
		vo.lastTime = G_getWeeTs(base.serverTime)
	end
end

function acXinchunhongbaoVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acXinchunhongbaoVoApi:canReward()
	local isfree=true							--是否是第一次免费
	if self:isToday()==true then
		isfree=false
	end
	return isfree
end

function acXinchunhongbaoVoApi:canReward()
	return false
end