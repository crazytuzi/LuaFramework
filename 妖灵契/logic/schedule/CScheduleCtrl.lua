local CScheduleCtrl = class("CScheduleCtrl", CCtrlBase)

function CScheduleCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:ResetCtrl()
end

function CScheduleCtrl.ResetCtrl(self)
	self.m_ActivePoint = 0
	self.m_RewardIdx = 0
	self.m_RightTag = nil
	self.m_TopTag = nil
	self.m_IDTag = nil
	self.m_OpenDay = 0
	self.m_Schedules = {}
	self.m_DayTask = {}
	self:CreateSchedule()
	self.m_LastSchedule = {}
	self.m_PopupList = {}
	g_AttrCtrl:AddCtrlEvent("CScheduleCtrl", callback(self, "OnCtrlAttrEvent"))
end

function CScheduleCtrl.OnCtrlAttrEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Attr.Event.Change then
    	if oCtrl.m_EventData["dAttr"]["grade"] then
    		self:AutoCheckRegionSchedule()
    	end
    end
end

function CScheduleCtrl.CreateSchedule(self)
	local dSchedule
	for k,v in pairs(data.scheduledata.SCHEDULE) do
		dSchedule = CSchedule.NewByScheuldID(v.id)
		self.m_Schedules[v.id] = dSchedule
	end
end

function CScheduleCtrl.UpdateDay(self)
	self:ResetCtrl()
	self:AutoCheckSchedule()
	self:AutoCheckRegionSchedule()
end
--~g_ScheduleCtrl:C2GSOpenScheduleUI(1,2)
--iRightTag:define.Schedule.SubTag
--iTopTag:define.Schedule.Tag
--IDTag:日程ID
function CScheduleCtrl.C2GSOpenScheduleUI(self, iRightTag, iTopTag, IDTag)
	self.m_RightTag = iRightTag
	self.m_TopTag = iTopTag
	self.m_IDTag = IDTag 
	netopenui.C2GSOpenScheduleUI()
end

function CScheduleCtrl.InitSchedule(self, activepoint, rewardidx, schlist, open_day)
	self.m_ActivePoint = activepoint 
	self.m_RewardIdx = rewardidx
	self.m_OpenDay = open_day + 1
	self:CombineData(schlist)
	self:OpenScheduleView()
end

function CScheduleCtrl.CombineData(self, schlist)
	local dSchedule
	for i,v in ipairs(schlist) do
		dSchedule = self.m_Schedules[v.scheduleid]
		dSchedule:UpdateSData(v)
	end
	table.print(g_ScheduleCtrl.m_Schedules)
end

function CScheduleCtrl.OpenScheduleView(self)
	CScheduleMainView:ShowView(function(oView)
		oView:Select(self.m_RightTag, self.m_TopTag, self.m_IDTag)
	end)
end

function CScheduleCtrl.RefreshSchedule(self, activepoint, schstate)
	local scheduleid = schstate.scheduleid
	for k,v in pairs(self.m_Schedules) do
		if v:GetValue("id") == scheduleid then
			v:UpdateSData(schstate)
		end
	end
	self.m_ActivePoint = activepoint
	self:OnEvent(define.Schedule.Event.Refresh)
end

function CScheduleCtrl.GetActivePoint(self)
	return self.m_ActivePoint
end

function CScheduleCtrl.GetOpenDay(self)
	return self.m_OpenDay
end

function CScheduleCtrl.SetRewardIdx(self, rewardidx)
	self.m_RewardIdx = rewardidx
	self:OnEvent(define.Schedule.Event.Refresh)
end

function CScheduleCtrl.GetRewardIdx(self)
	return self.m_RewardIdx 
end

function CScheduleCtrl.LoginScheduleReward(self, activepoint, rewardidx, day_task)
	self.m_ActivePoint = activepoint
	self.m_RewardIdx = rewardidx
	self.m_DayTask = day_task or {}
	self:OnEvent(define.Schedule.Event.Refresh)
end

function CScheduleCtrl.IsHasScheduleReward(self)
	local activerewards = data.scheduledata.ACTIVEREWARD
	local flag = 0
	for i=1,#activerewards do
		flag = 2 ^ i
		if MathBit.andOp(self.m_RewardIdx, flag) == 0 then
			if self.m_ActivePoint >= activerewards[i].active then
				return true
			end
		end
	end
	--没数据默认全部数据已领取
	return false
end

function CScheduleCtrl.IsOpen(self, scheduleid)
	local dData = self.m_Schedules[scheduleid]
	local state = dData:GetValue("state")
	return state == define.Schedule.State.Open
end

function CScheduleCtrl.GetSchedule(self, scheduleid)
	return self.m_Schedules[scheduleid]
end

function CScheduleCtrl.GoToWay(self, scheduleid)
	if g_WarCtrl:IsWar() then
		g_NotifyCtrl:FloatMsg("战斗中无法进行该操作")
		return
	end
	local dData = self.m_Schedules[scheduleid]
	local blockkey = dData:GetValue("blockkey")
	if blockkey and blockkey ~= "" then
		if not g_ActivityCtrl:ActivityBlockContrl(blockkey) then
			return false
		end
	end
	local function gotufunc()
		if g_MapCtrl:IsVirtualScene() then
			if dData:GetValue("banvirtual") == 0 then
				g_NotifyCtrl:FloatMsg("当前场景无法前往")
				return false
			end
		end
		local gotoway = dData:GetValue("gotoway")
		if gotoway == 0 then --客户端弹前往提示
			self:ShowGototips(scheduleid)
		elseif gotoway == 1 then --服务器
			netopenui.C2GSClickSchedule(scheduleid)
			CScheduleMainView:CloseView()
		elseif gotoway == 2 then --客户端打开界面
			local func
			if dData:GetValue("close") then
				func = function ()
					CScheduleMainView:CloseView()
				end
			end
			if scheduleid == define.Schedule.ID.Chapter then
				g_ChapterFuBenCtrl.m_WarAfterReshow = true
			end
			g_OpenUICtrl:OpenUI(dData:GetValue("open_view"), func)
		end
	end
	gotufunc()
	return true
end

function CScheduleCtrl.ShowGototips(self, scheduleid)
	local dSchedule = g_ScheduleCtrl:GetSchedule(scheduleid) or {}
	g_NotifyCtrl:FloatMsg(dSchedule:GetValue("notopentips"))
end

function CScheduleCtrl.LoadScheduleTexture(self, scheduleid, oTexture)
	local path = string.format("Texture/Schedule/bg_schedule_%d.png", scheduleid)
	if path == nil or oTexture.m_LoadingPath == path then
		return
	end
	local function cb() end
	oTexture:LoadPath(path, cb)
end

function CScheduleCtrl.SaveLastSchedule(self, iRightTag, iTopTag, IDTag)
	self.m_LastSchedule = {
		iRightTag = iRightTag,
		iTopTag = iTopTag,
		IDTag = IDTag,
	}
end

function CScheduleCtrl.GetLastSchedule(self)
	return self.m_LastSchedule
end

function CScheduleCtrl.SetPopupSchedule(self, scheduleid, bClose)
	if bClose then
		local oView = CSchedulePopupView:GetView()
		if oView and oView.m_ScheduleID == scheduleid then
			CSchedulePopupView:CloseView()
		end
		return
	end
	--临时加过滤，避免服务发错日程id
	local list = {2002, 1020, 2003, 1021, 1015, 2005}
	if not table.index(list, scheduleid) then
		return
	end
	local dData = data.scheduledata.SCHEDULE[scheduleid]
	if g_AttrCtrl.grade < dData.grade.min then
		return
	end
	if g_WarCtrl:IsWar() then
		return
	end
	if g_MapCtrl:IsVirtualScene() then
		return
	end
	if CPaTaView:GetView() then
		return
	end
	if scheduleid == define.Schedule.ID.OrgWar then
		if not g_OrgCtrl:HasOrg() then
			return
		end
	end
	if table.index(self.m_PopupList, scheduleid) then
		return
	end
	--table.insert(self.m_PopupList, scheduleid)
	CSchedulePopupView:ShowView(function (oView)
		oView:SetScheduleID(scheduleid)
	end)
end

--根据本机时间自动计算各活动的开启时间与结束时间
--并根据与下一活动开启时间的差距改变提示
--不影响self.m_Schedules
--~g_ScheduleCtrl:AutoCheckSchedule()
function CScheduleCtrl.AutoCheckSchedule(self)
	if self.m_AutoCheckTimer then
		Utils.DelTimer(self.m_AutoCheckTimer)
		self.m_AutoCheckTimer = nil
	end
	local lCheck = {} --需要检测的日程，只有限时活动需要检测
	local dSchedule, timeInfo, bWeek
	for k,v in pairs(data.scheduledata.SCHEDULE) do
		dSchedule = CSchedule.NewByScheuldID(v.id)
		timeInfo = dSchedule:GetScheduleTimeInfo()
		bWeek = not dSchedule:CheckOpenWeek()
		if timeInfo and bWeek then
			dSchedule:SetValue("timeInfo", timeInfo)
			table.insert(lCheck, dSchedule)
		end
	end
	local lBefore = {}   --存储日程预告
	for i,v in ipairs(lCheck) do
		lBefore[v:GetValue("id")] = {}
	end
	local lOpen = {} --存储正在开始的日程 
	local time, txt, countdown, id
	local function autocheck()
		txt = nil
		countdown = 0
		time = g_TimeCtrl:GetTimeS() 
		for i,v in ipairs(lCheck) do
			id = v:GetValue("id")
			for _,t in ipairs(v:GetValue("timeInfo")) do
				local iBefore = t.iBefore
				local name = v:GetValue("name")
				if time >= iBefore and time <  t.iOpen and not lBefore[id][iBefore] then
					lBefore[id][iBefore] = true
					if time < iBefore + 30 then
						local min = g_TimeCtrl:GetTimeInfo(t.iOpen - iBefore).min
						txt = string.format("%s\n%d分钟后开启", name, min)
						countdown = 30
					end
					t.iBefore = t.iBefore + 300 --下一次预告时间
					break
				elseif time >=t.iOpen and time < t.iEnd and not lOpen[id] then
					--[[
					lOpen[id] = true
					txt = name.."\n".."正在开启"
					countdown = t.iEnd - time
					]]
					break
				elseif time > t.iEnd then
					lBefore[id] = false
					lOpen[id] = false
				end
			end
			if txt and countdown > 0 and g_AttrCtrl.grade >= v:GetValue("mingrade") then
				self:OnEvent(define.Schedule.Event.RefreshUITip, {txt=txt, countdown=countdown})
			end
		end
		return true
	end
	self.m_AutoCheckTimer = Utils.AddTimer(autocheck, 1, 1)	
end

function CScheduleCtrl.GetTag(self, scheduleid)
	local dData = data.scheduledata.SCHEDULE[scheduleid]
	if dData then
		return dData.tag
	end
end

function CScheduleCtrl.AutoCheckRegionSchedule(self)
	if self.m_AutoCheckRegionTimer then
		Utils.DelTimer(self.m_AutoCheckRegionTimer)
		self.m_AutoCheckRegionTimer = nil
	end

	local lCheck = {}
	local time, txt, countdown, id
	local function autocheck()
		txt = nil
		countdown = 0
		if not time then
			local lRegionShow = {} --需要检测预告等级段
			local dRegionShow = data.scheduledata.REGIONSHOW
			for i,v in ipairs(dRegionShow) do
				if v.grade then
					local arr = string.split(v.grade, ",")
					table.print(arr)
					printc(g_AttrCtrl.grade, tonumber(arr[1]), tonumber(arr[2]))
					if g_AttrCtrl.grade >= tonumber(arr[1]) and g_AttrCtrl.grade <= tonumber(arr[2]) then
						table.insert(lRegionShow, v)
					end
				end
			end
			local dSchedule, timeInfo, bWeek
			for i,v in ipairs(lRegionShow) do
				for _,id in ipairs(v.idlist) do
					dSchedule = CSchedule.NewByScheuldID(id)
					timeInfo = dSchedule:GetScheduleTimeInfo()
					bWeek = not dSchedule:CheckOpenWeek()
					if timeInfo and bWeek then
						table.insert(lCheck, dSchedule)
					end
				end
			end
			for i,v in ipairs(lCheck) do
				local timeInfo = dSchedule:GetScheduleTimeInfo()
				v:SetValue("timeInfo", timeInfo)
			end
		end
		time = g_TimeCtrl:GetTimeS() 
		for i,v in ipairs(lCheck) do
			id = v:GetValue("id")
			for _,t in ipairs(v:GetValue("timeInfo")) do
				local iBefore = t.iBefore
				local name = v:GetValue("name")
				--printc(g_TimeCtrl:Convert(time), g_TimeCtrl:Convert(iBefore), time <= iBefore)
				if time <= iBefore then
					local dDate = g_TimeCtrl:GetTimeInfo(time)
					--允许一秒误差
					--printc(dDate.min, dDate.sec)
					if (dDate.min == 0 and (dDate.sec == 0 or dDate.sec == 1)) or (dDate.min == 30 and (dDate.sec == 0 or dDate.sec == 1)) then
						local opentime = v:GetValue("times")[1].opentime
						txt = string.format("%s\n%s开启", v:GetValue("name"), opentime)
						countdown = 30
					end
				end
			end
			if txt and countdown > 0 and g_AttrCtrl.grade >= v:GetValue("mingrade") then
				self:OnEvent(define.Schedule.Event.RefreshUITip, {txt=txt, countdown=countdown})
			end
		end
		return true
	end
	self.m_AutoCheckRegionTimer = Utils.AddTimer(autocheck, 1, 1)	
end


return CScheduleCtrl