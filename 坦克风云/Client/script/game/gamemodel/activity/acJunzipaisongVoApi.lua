acJunzipaisongVoApi={}

function acJunzipaisongVoApi:getAcVo()
	return activityVoApi:getActivityVo("junzipaisong")
end
function acJunzipaisongVoApi:getVersion( )
	local vo = self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return nil
end
function acJunzipaisongVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	return timeStr
end

function acJunzipaisongVoApi:updateShow()
    local vo=self:getAcVo()
    activityVoApi:updateShowState(vo)
end

function acJunzipaisongVoApi:getCircleListCfg()
	local vo = self:getAcVo()
	if vo and vo.circleList then
		return vo.circleList
	end
	return {}
end

function acJunzipaisongVoApi:getLotteryOnceCost()
	local vo = self:getAcVo()
	if vo and vo.cost then
		return tonumber(vo.cost)
	end
	return 999999 
end

function acJunzipaisongVoApi:getLotteryTenCost()
	local vo = self:getAcVo()
	if vo and vo.mulCost then
		return tonumber(vo.mulCost)
	end
	return 999999 
end

function acJunzipaisongVoApi:getShowListCfg()
	local vo = self:getAcVo()
	if vo and vo.showlist then
		return vo.showlist
	end
	return {}
end

function acJunzipaisongVoApi:checkIsChatByID(ptype,pid,pnum)
	local chatList = self:getShowListCfg()
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

function acJunzipaisongVoApi:updateLastTime()
	local vo = self:getAcVo()
	if vo then
		vo.lastTime = G_getWeeTs(base.serverTime)
	end
end

function acJunzipaisongVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acJunzipaisongVoApi:canReward()
	local isfree=true							--是否是第一次免费
	if self:isToday()==true then
		isfree=false
	end
	return isfree
end