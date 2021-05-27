--------------------------------------------------------
-- 日常活动数据  配置 StdActivityCfg
--------------------------------------------------------
ActivityData = ActivityData or BaseClass()

function ActivityData:__init()
	if ActivityData.Instance then
		ErrorLog("[ActivityData]:Attempt to create singleton twice!")
	end
	ActivityData.Instance = self
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()


	self:InitGuideData()
	self.paodian_time = 0

	-- 押镖状态
	self.escort_state = 2
	-- 是否自动押镖
	self.is_auto_yabiao = false
	self.practice_top_tip = {}
end

function ActivityData:__delete()
	ActivityData.Instance = nil
end

--获取某一类活动奖励显示图标配置
function ActivityData.GetOneTypeActivityAwardCfg(type_id)
	local award_t = {}
	for k,v in pairs(RichTextUtil.Parse2Table(StdActivityCfg[type_id].rewardicon)) do
		local data_t = {item_id = tonumber(v[3]), num = tonumber(v[4]), is_bind = 0}
		table.insert(award_t, data_t)
	end
	return award_t
end

--获取某一类活动配置
function ActivityData.GetOneTypeActivityCfg(type_id)
	return StdActivityCfg[type_id]
end

--获取所有时间段活动配置（每个时间段作为一个）
function ActivityData.AllActivitiesOpenTimeCfg()
	local activity_data_list = {}
	--每周开放日
	local function OpenWDayStr(data)
		local weekStr = "(" .. Language.Common.Week		--(周
		for k2,v2 in pairs(data) do
			if v2 == 0 then
				weekStr = Language.Common.CHNWeekDays[0]
				break
			else
				local str = ""
				if k2 < #data then
					str = Language.Common.CHNWeekDays[v2] .. "、"
				else
					str = Language.Common.CHNWeekDays[v2]
				end
				weekStr = weekStr .. str 
			end
		end
		if weekStr ~= "" then
			weekStr = weekStr .. ")"
		end
		return weekStr
	end

	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)		-- 自身的等级
	for k,v in pairs(StdActivityCfg) do
		for k2,v2 in pairs(v.tOpenTime.times) do
			if nil == v.level or v.level <= role_level then
				table.insert(activity_data_list, {
					type = v.id,
					wdays = v.tOpenTime.weeks,
					time_str = v2[1] .. ":" .. v2[2] .. "-" .. v2[3] .. ":" .. v2[4],
					open_day_str = OpenWDayStr(v.tOpenTime.weeks),
				})
			end
		end
	end
	ActivityData.SortActivityList(activity_data_list)
	return activity_data_list
end

--获得某个活动是否当天开放
function ActivityData.IsTodayOpen(act)
	local open_day_list = act.wdays

	if open_day_list[1] == 0 then return true end

	local server_time = TimeCtrl.Instance:GetServerTime()
	-- local update_time = math.max(server_time - 6 * 3600, 0)		--6点刷新时间
	local w_day = tonumber(os.date("%w", server_time))
	if 0 == w_day then w_day = 7 end

	local is_open_day = false
	for k,v in pairs(open_day_list) do
		if tonumber(v) == w_day then
			is_open_day = true
			break
		end
	end
	return is_open_day
end

--给活动排序
function ActivityData.SortActivityList(data_t)
	local server_time = TimeCtrl.Instance:GetServerTime() or 0
	local format_time = os.date("*t", server_time)		--获取年月日时分秒的表
	local now_time = (format_time.hour * 60 + format_time.min) * 60 + format_time.sec
	for k,v in pairs(data_t) do
		local time_list = Split(v.time_str, "##")
		for k_2,v_2 in pairs(time_list) do
			if nil == v.is_open or 1 == v.is_open then
				v.open_time = ActivityData.GetDayTimeByStr(Split(v_2, "-")[1])
				local end_time = ActivityData.GetDayTimeByStr(Split(v_2, "-")[2])
				v.is_open = (now_time >= v.open_time + 30 and now_time < end_time) and 1 or 0
				v.is_over = now_time > end_time and 1 or 0
			end
		end
		v.is_open_today = ActivityData.IsTodayOpen(v) and 1 or 0

		if v.type == DAILY_ACTIVITY_TYPE.GONG_CHENG then
			local is_now_gc, is_over_gc = WangChengZhengBaData.GetIsNowGCOpen(false)
			v.is_open = is_now_gc and 1 or 0
			v.is_over = is_over_gc and 1 or 0
			v.is_open_today = WangChengZhengBaData.GetIsTodayGC() and 1 or 0
		end
	end
	local function sort_fun()
		return function(a, b)
			local order_a = 100000
			local order_b = 100000

			if a.is_open_today > b.is_open_today then
				order_a = order_a + 10000
			elseif a.is_open_today < b.is_open_today then
				order_b = order_b + 10000
			end

			if a.is_open > b.is_open then
				order_a = order_a + 1000
			elseif a.is_open < b.is_open then
				order_b = order_b + 1000
			elseif a.is_open == 1 and b.is_open == 1 then
				if a.open_time > b.open_time then
					order_a = order_a + 100
				elseif a.open_time < b.open_time then
					order_b = order_b + 100
				end
			end

			if a.is_over < b.is_over then
				order_a = order_a + 100
			elseif a.is_over > b.is_over then
				order_b = order_b + 100
			end

			if a.open_time < b.open_time then
				order_a = order_a + 10
			elseif a.open_time > b.open_time then
				order_b = order_b + 10
			end

			return order_a > order_b
		end
	end

	table.sort(data_t, sort_fun())
end

function ActivityData.GetDayTimeByStr(str)
	if str == nil then return 0 end
	local time_list = Split(str, ":")
	-- 6点刷新
	-- local hour = time_list[1] - 6 >= 0 and time_list[1] - 6 or (time_list[1] - 6) + 24
	--0点刷新
	local hour = (time_list[1] - 0 > 0 and time_list[2] - 0 >= 0 ) and time_list[1] or 24
	local minute = time_list[2] 
	return (hour * 60 + minute) * 60
end

function ActivityData.ShowZhenyingFuhuoCountdown()
	-- 背景
	local bg = XUI.CreateImageView(0, 0, ResPath.GetScene("fb_bg_101"), true)
	local bg_size = bg:getContentSize()
	bg:setPosition(bg_size.width * 0.5, bg_size.height * 0.5)

	-- 文字
	local word = XUI.CreateImageView(bg_size.width * 0.5, bg_size.height * 0.5, ResPath.GetScene("zyz_fuhuo_word"), true)

	-- 图片数字节点
	local rich_num = CommonDataManager.CreateLabelAtlasImage(0)
	rich_num:setPosition(bg_size.width * 0.5 - 130, bg_size.height * 0.5)

	local layout_t = {x = HandleRenderUnit:GetWidth() * 0.5, y = HandleRenderUnit:GetHeight() * 0.5, anchor_point = cc.p(0.5, 0.5), content_size = bg_size}
	local num_t = {num_node = rich_num, num_type = "zdl_y_", folder_name = "scene"}
	local img_t = {bg, word}

	local function out()
		FuhuoCtrl.SendFuhuoReq(REALIVE_TYPE.REALIVE_TYPE_BACK_HOME)
	end
	GlobalTimerQuest:AddDelayTimer(out, 5)
	UiInstanceMgr.Instance:CreateOneCountdownView("zhenying_middle", 5, layout_t, num_t, img_t)
end

--某一活动是否处于开放状态
function ActivityData.IsSomeActOpenNow(act_type)
	local activity_data_t = ActivityData.AllActivitiesOpenTimeCfg()
	for k,v in pairs(activity_data_t) do
		if v.type == act_type and v.is_open == 1 then
			return true
		end
	end
	return false
end

function ActivityData:SetEscortState(escort_state)
	self.escort_state = escort_state
end

function ActivityData:GetEscortState()
	return self.escort_state
end

function ActivityData:IsAutoYabiao()
	return self.is_auto_yabiao
end

function ActivityData:SetAutoYabiao(bool)
	self.is_auto_yabiao = bool
end

function ActivityData:IsEscort()
	return self.escort_state == 1
end