-- @Author hj
-- @Date 2018-12-12
-- @Description 月度回馈数据处理模型

dailyYdhkVoApi = {}

function dailyYdhkVoApi:updateData(data)
	local vo = self:getVo()
	if vo then
		vo:updateData(data)
	end
end

function dailyYdhkVoApi:getVo( ... )
	if self.vo==nil then
		self.vo=dailyActivityVoApi:getActivityVo("ydhk")
	end
	return self.vo
end

function dailyYdhkVoApi:showDialog(layerNum)

	local function callback(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData and sData.data then
				dailyYdhkVoApi:updateData(sData.data)
				local titleStr = getlocal("daily_ydhk_title")
			    local sd = dailyYdhkDialog:new()
			    local dialog = sd:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,titleStr,true,layerNum+1);
			    sceneGame:addChild(dialog,layerNum+1)
			end
		end
	end
    socketHelper:dailyYdhkGetData(callback)
end

function dailyYdhkVoApi:getLogList( ... )
	local logList = {}
	local vo=self:getVo()
	if vo and vo.log then
		logList = vo.log
	end
	return logList
end

function dailyYdhkVoApi:getNowCost( ... )
	local vo=self:getVo()
	if vo and vo.cost then
		return vo.cost
	end
	return 0
end

-- 获取领取的金币总数
function dailyYdhkVoApi:getAllReward( ... )
	local vo=self:getVo()
	if vo and vo.reward then
		return vo.reward
	end
	return 0
end

-- 当天领取的金币
function dailyYdhkVoApi:getDailyReward( ... )
	local vo=self:getVo()
	if vo and vo.dreward then
		return vo.dreward
	end
	return 0
end

-- 判断是否可以领取
function dailyYdhkVoApi:judgeCanReward( ... )
	local cfg = self:getCfg()
	-- 不满足条件
	if self:getNowCost() < cfg.monthCost then
		return 1
	-- 已领取
	elseif self:getDailyReward() > 0 then
		return 2
	elseif self:getDailyReward() == 0 then
		if G_isToday(self:getLastRewardTime()) == true then
			-- 有可能世界金矿采满了 但是还可以领 领了0金币
			return 2
		else
			-- 未领取
			return 3
		end
	end

end

function dailyYdhkVoApi:getTimeStr( ... )

	local activeTime = G_getIntervalTimeEOM()
	return getlocal("activityCountdown")..":"..G_formatActiveDate(activeTime)

end


function dailyYdhkVoApi:getFreshFlag( ... )
	local vo=self:getVo()
	if vo and vo.needRefresh then
		return vo.needRefresh
	end
end

function dailyYdhkVoApi:setFreshFlag( ... )
	local vo=self:getVo()
	if vo and vo.needRefresh then
		vo.needRefresh = true
	end
end


function dailyYdhkVoApi:getCts( ... )
	local vo=self:getVo()
	if vo and vo.cts then
		return vo.cts
	end
end

function dailyYdhkVoApi:getLastRewardTime( ... )
	local vo=self:getVo()
	if vo and vo.rts then
		return vo.rts
	end
end

function dailyYdhkVoApi:getCfg( ... )
	local ydhkCfg=G_requireLua("config/gameconfig/monthgive")
	return ydhkCfg
end

function dailyYdhkVoApi:canReward()
	if self:judgeCanReward() == 3 then
		return true
	end
	return false
end

function dailyYdhkVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage2.plist")
	spriteController:addTexture("public/activeCommonImage2.png")
end

function dailyYdhkVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage2.plist")
	spriteController:removeTexture("public/activeCommonImage2.png")
end

--获取每日可领取金币的上限
function dailyYdhkVoApi:getDailyGemsFinalLimit()
	local cfg=dailyYdhkVoApi:getCfg()

	local added = planeRefitVoApi:getSkvByType(65) --战机改装技能加成

	local gemsFinalLimit = cfg.goldDayLimit + added
	
	return gemsFinalLimit, added
end

function dailyYdhkVoApi:clear()
	self.vo=nil
end

