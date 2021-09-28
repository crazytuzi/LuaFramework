
ActivityModel =BaseClass(LuaModel)

function ActivityModel:GetInstance()
	if ActivityModel.inst == nil then
		ActivityModel.inst = ActivityModel.New()
	end
	return ActivityModel.inst
end

function ActivityModel:__init()
	self:InitData()
	self:SetDayLimitActivityTimer() --限时活动红点显示定时器
end

function ActivityModel:InitData()
	self.activityDynamicData = nil
	self.DayLimitActivityKey = "DayLimitActivityKey"
	self.lastShowRedTipsFlag = false
	self.isNeedShowDayActivityPanel = false
	self.lastServerTime = {hour = 0 , min = 0}
end

function ActivityModel:SetDayLimitActivityTimer()
	RenderMgr.Add(function() 
		self:ShowRedTips()
	end , self.DayLimitActivityKey)
end

function ActivityModel:SetShowDayActivityPanelFlag(bl)
	if bl ~= nil then
		self.isNeedShowDayActivityPanel = bl
	end
end

function ActivityModel:GetShowDayActivityPanelFlag()
	return self.isNeedShowDayActivityPanel
end

function ActivityModel:ParseSynActivityData(data)
	self.activityDynamicData = nil
	self.activityDynamicData = {}
	SerialiseProtobufList(data.activitys, function(item)
			local vo = ActivityDynamicVo.New()
			vo.id = item.id
			vo.enterCount = item.enterCount	
			vo.state = item.state
			self.activityDynamicData[vo.id] = vo
	end)
end

function ActivityModel:GetActivityDataById(activityId)
	return self.activityDynamicData[activityId]
end

function ActivityModel:GetVipLevelAdd( id )
	local viplevel = VipModel:GetInstance():GetPlayerVipLV()
	if viplevel > 0 then
		if id == 101 then
			local date = GetCfgData("vipPrivilege"):Get(16)
			local index = "vip"..viplevel
			viplevel = date[index]
		elseif id == 104 then
			local date = GetCfgData("vipPrivilege"):Get(17)
			local index = "vip"..viplevel
			viplevel = date[index]
		end
	end
	return viplevel
end

--获取日常任务数据
function ActivityModel:GetDayNormalActivity()
	local dataSource = GetCfgData("weekActivity")
	local result = {}
	for k, v in pairs(dataSource) do 
		if type(v) ~= "function" and v.type == 1 then
			table.insert(result, v)
		end
	end
	SortTableByKey(result, "id", true)
	return result
end

--获取限时活动数据
function ActivityModel:GetDayLimitActivity()
	local day = TimeTool.GetWeekDay()

	local dataSource = GetCfgData("weekActivity")
	local result = {}
	for k, v in pairs(dataSource) do 
		if type(v) ~= "function" and v.type == 2 and tonumber(v.week) == tonumber(day) then
			table.insert(result, v)
		end
	end
	SortTableBy2Key(result, "startHour", "startMin", true, true)

	return result
end

--获取周活动数据
function ActivityModel:GetWeekActivity()
	local dataSource = GetCfgData("weekActivity")
	local weekData = {}
	local timeDic = {}
	local timeAry = {}
	local tiemStr = nil
	for k, v in pairs(dataSource) do 
		if type(v) ~= "function" and v.type == 2 then
			tiemStr = v.startHour.."_"..v.startMin
			if timeDic[tiemStr] == nil then
				local timeVo = {}
				timeVo.startHour = v.startHour
				timeVo.startMin = v.startMin
				timeDic[tiemStr] = true
				table.insert(timeAry, timeVo)
			end
			table.insert(weekData, v)
		end
	end

	SortTableBy2Key(timeAry, "startHour", "startMin", true, true)

	local result = {}
	for i = 1, #timeAry do
		local hourMapping = nil
		for j = 1, #weekData do
			if timeAry[i].startHour == weekData[j].startHour and timeAry[i].startMin == weekData[j].startMin then
				if hourMapping == nil then
					hourMapping = {}
					hourMapping[0] = {timeAry[i].startHour, timeAry[i].startMin}
				end
				hourMapping[weekData[j].week] = weekData[j]
			end
		end
		table.insert(result, hourMapping)
	end

	return result
end


--显示活动红点提示
function ActivityModel:ShowRedTips()
	local isNeedShow = self:IsHasNewDayLimitActivity()
	if self.lastShowRedTipsFlag ~= isNeedShow then
		if isNeedShow == true then
			GlobalDispatcher:DispatchEvent(EventName.MAINUI_RED_TIPS, {moduleId = FunctionConst.FunEnum.activity , state = isNeedShow })
			GlobalDispatcher:DispatchEvent(EventName.RefershDayLimitActivityRedTips , isNeedShow)
			self.lastShowRedTipsFlag = isNeedShow
		end
	end
end

function ActivityModel:GetLastShowRedTipsFlag()
	return self.lastShowRedTipsFlag
end

function ActivityModel:SetLastShowRedTipsFlag(bl)
	if bl ~= nil then
		self.lastShowRedTipsFlag = bl
	end
end

function ActivityModel:IsHasNewDayLimitActivity()
	local rtnIsHas = false
	local splitServerTime = splitByFormat(TimeTool.GetServerTimeHMS() , ":")
	local curServerHour = tonumber(splitServerTime[1] or 0)
	local curServerMin = tonumber(splitServerTime[2] or 0)

	--if not TableIsEmpty(self.lastServerTime) and self.lastServerTime.hour ~= curServerHour and self.lastServerTime.min ~= curServerMin and self.activityDynamicData ~= nil then
	if self.activityDynamicData ~= nil then
		local mainPlayerLev = 0
		local mainPlayerVo = SceneModel:GetInstance():GetMainPlayer()
		if mainPlayerVo then mainPlayerLev = mainPlayerVo.level end

		local limitDayActivity = self:GetDayLimitActivity()

		for idx , activityInfo in pairs(limitDayActivity) do
			local activityDynamicVo = self:GetActivityDataById(activityInfo.id)
			if activityDynamicVo ~= nil then
				if activityDynamicVo.state == 1 and activityInfo.maxCount > activityDynamicVo.enterCount and mainPlayerLev >= activityInfo.limitLevel then -- 处于关闭状态的显示活动
					if (TimeTool.DiffTimeHM(activityInfo.startHour , activityInfo.startMin , curServerHour , curServerMin)) and 
						( not TimeTool.DiffTimeHM( activityInfo.endHour , activityInfo.endMin , curServerHour , curServerMin )) then
						rtnIsHas = true
						break
					end
				end
			end
		end

		self.lastServerTime.hour = curServerHour
		self.lastServerTime.min = curServerMin
	end
	return rtnIsHas
end

function ActivityModel:Reset()
	self.lastShowRedTipsFlag = false
	self.isNeedShowDayActivityPanel = false
	self.lastServerTime = {}
end

function ActivityModel:__delete()
	RenderMgr.Remove(self.DayLimitActivityKey)
	self.lastShowRedTipsFlag = false
	self.isNeedShowDayActivityPanel = false
	self.lastServerTime = nil
	self.activityDynamicData = nil
	ActivityModel.inst = nil
end