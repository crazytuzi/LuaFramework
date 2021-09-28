module(..., package.seeall)

local require = require

local ui = require("ui/base")

wnd_spyStory = i3k_class("wnd_spyStory", ui.wnd_base)

local DAY_SCORE = 1
local FINISH_COUNT = 2
function wnd_spyStory:ctor()
end

function wnd_spyStory:configure()
	local widget = self._layout.vars
	local info = g_i3k_game_context:getSpyStoryInfo()
	self.close_btn = widget.close_btn
	self.close_btn:onClick(self, self.onCloseUI)
	
	self.help_btn = widget.help_btn
	self.help_btn:onClick(self, self.onHelpBtnClick)
	
	self.enter_btn = widget.enter_btn
	self.enter_btn:onClick(self, self.onEnterBtnClick)
	
	self.team_enter_btn = widget.team_enter_btn
	self.team_enter_btn:onClick(self, self.onTeamEnterBtnClick)
	self.need_lvl = widget.need_lvl
	self.need_lvl:setText(i3k_get_string(18649, i3k_db_spy_story_base.openLvl))
	
	self.activity_time = widget.activity_time
	if info.index == 0 then
		self.activity_time:setText(i3k_get_string(18669))
	else
		self.activity_time:setText(i3k_get_string(18650, g_i3k_get_YearAndMonthAndDayTime(i3k_db_spy_story_base.batch[info.index].openDate), g_i3k_get_YearAndMonthAndDayTime(i3k_db_spy_story_base.batch[info.index].endDate)))	
	end
	
	self.open_time = widget.open_time
	self.open_time:setText(i3k_get_string(18651, g_i3k_get_HourAndMin(i3k_db_spy_story_base.openTime.startTime), g_i3k_get_HourAndMin(i3k_db_spy_story_base.openTime.endTime)))
	
	self.residue_times = widget.residue_times
	
	self.activity_day = widget.activity_day
	
	local weekDayStr = i3k_get_activity_open_desc(i3k_db_spy_story_base.openWeekDay)
	self.week_day = widget.week_day
	self.week_day:setText(i3k_get_string(18670, weekDayStr))
	self.desc1 = widget.desc1
	self.desc2 = widget.desc2
	
		end
function wnd_spyStory:refresh()
	local info = g_i3k_game_context:getSpyStoryInfo()
	self.residue_times:setText(i3k_get_string(18652, i3k_db_spy_story_base.countTimes - info.dayEnterTimes))
	if info.index == 0 then
		self.activity_day:setText(i3k_get_string(18664))
	else
		local openDay = math.floor(i3k_db_spy_story_base.batch[info.index].openDate / 86400)
		local today = g_i3k_get_day(i3k_game_get_time())
		self.activity_day:setText(i3k_get_string(18663, today - openDay))
	end
	self.desc1:setText(i3k_get_string(18653, info.dayScore))
	self.desc2:setText(i3k_get_string(18654, info.finishCount))
	local widget = self._layout.vars
	for i = 1, #i3k_db_spy_story_reward do
		for j = 1, #i3k_db_spy_story_reward[i] do
			widget['box' .. i .. j]:setVisible(true)
			widget['box_used' .. i .. j]:setVisible(false)
			widget['box_btn' .. i ..j]:onClick(self, self.onBoxBtnClick, {i, j})
			local score = i == DAY_SCORE and info.dayScore or info.finishCount
			local reward = i == DAY_SCORE and info.dayRewards or info.activityRewards
			local isOpen = false
			for k, v in ipairs(reward) do
				if v == i3k_db_spy_story_reward[i][j].id then
					isOpen = true
					break
end
			end
			widget['box' .. i .. j]:setVisible(not isOpen)
			widget['box_used' .. i .. j]:setVisible(isOpen)
			widget['text' .. i .. j]:setText(i3k_db_spy_story_reward[i][j].score)
			if score >= i3k_db_spy_story_reward[i][j].score and not isOpen then
				self._layout.anis['c_bx' .. i .. j]:play()
			else
				self._layout.anis['c_bx' .. i .. j]:stop()
			end
		end
		local num = i == DAY_SCORE and info.dayScore or info.finishCount
		local percentNum = self:getSliderProcess(i, num)
		widget['slider' .. i]:setPercent(percentNum)
		widget['score' .. i]:setText(i == DAY_SCORE and info.dayScore or info.finishCount)
	end
end

function wnd_spyStory:getSliderProcess(sliderType, num)
	local cfg = i3k_db_spy_story_reward[sliderType]
	local totalNum = #cfg
	for i, e in ipairs(cfg) do
		if num <= e.score then
			local preScore = cfg[i - 1] and cfg[i - 1].score or 0
			return ((num - preScore) / (e.score - preScore) + (i - 1)) * 100 / totalNum
		end
	end
	return 100
end
function wnd_spyStory:onEnterBtnClick(sender)
	local canEnter = self:checkOpenTime()
	if not canEnter then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18664))
		return
	end
	local info = g_i3k_game_context:getSpyStoryInfo()
	if info.dayEnterTimes >= i3k_db_spy_story_base.countTimes then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18665))
		return
	end
	local func = function ()
		g_i3k_ui_mgr:OpenUI(eUIID_SignWait)
		g_i3k_ui_mgr:RefreshUI(eUIID_SignWait, i3k_game_get_time(), g_TOURNAMENT_MATCH, g_SPY_STORY_MATCH)
		i3k_sbean.mate_alone(g_SPY_STORY_MATCH)
		g_i3k_game_context:InMatchingState(i3k_game_get_time(), g_TOURNAMENT_MATCH, g_SPY_STORY_MATCH)
	end
	local canJoin = i3k_can_dungeon_join(false, i3k_get_string(18648), i3k_db_spy_story_base.teamPersonNum, i3k_db_spy_story_base.openLvl)
	if canJoin then
		g_i3k_game_context:CheckMulHorse(func)
	end
end

function wnd_spyStory:onTeamEnterBtnClick(sender)
	local canEnter = self:checkOpenTime()
	if not canEnter then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18664))
		return
	end
	local info = g_i3k_game_context:getSpyStoryInfo()
	if info.dayEnterTimes >= i3k_db_spy_story_base.countTimes then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18665))
		return
	end
	local canJoin = i3k_can_dungeon_join(true, i3k_get_string(18648), i3k_db_spy_story_base.teamPersonNum, i3k_db_spy_story_base.openLvl)
	if canJoin then
		i3k_sbean.create_arena_room(g_SPY_STORY_MATCH)
	end
end
function wnd_spyStory:onBoxBtnClick(sender, args)
	local i, j = args[1], args[2]
	local info = g_i3k_game_context:getSpyStoryInfo()
	local score = i == DAY_SCORE and info.dayScore or info.finishCount
	local reward = i == DAY_SCORE and info.dayRewards or info.activityRewards
	local cfg = i3k_db_spy_story_reward[i][j]
	local isOpen = false
	for k, v in ipairs(reward) do
		if v == i3k_db_spy_story_reward[i][j].id then
			isOpen = true
			break
		end
	end
	if score >= cfg.score and not isOpen then
		if g_i3k_game_context:checkBagCanAddCell(cfg.bagNeedCell, true) then
			if i == DAY_SCORE then
				i3k_sbean.spy_world_day_reward(j)
	else
				i3k_sbean.spy_world_activity_reward(j)
			end
		end
	else
		g_i3k_ui_mgr:OpenUI(eUIID_Schedule_Tips)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Schedule_Tips, "showSpyStoryReward", cfg, i == DAY_SCORE)
	end
end

function wnd_spyStory:onHelpBtnClick(sender)
	g_i3k_ui_mgr:OpenAndRefresh(eUIID_SpyStoryHelp)
end

function wnd_spyStory:checkOpenTime()
	local weekDay = g_i3k_get_current_weekday()
	local isToday = false
	for k, v in ipairs(i3k_db_spy_story_base.openWeekDay) do
		if v == weekDay then
			isToday = true
		end
	end
	local info = g_i3k_game_context:getSpyStoryInfo()
	if i3k_db_spy_story_base.batch[info.index] then
		local cfg = i3k_db_spy_story_base.batch[info.index]
		return g_i3k_checkIsInDate(cfg.openDate, cfg.endDate) and isToday and g_i3k_checkIsInTodayTime(i3k_db_spy_story_base.openTime.startTime, i3k_db_spy_story_base.openTime.endTime)
	else
		return false
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_spyStory.new()
	wnd:create(layout)
	return wnd
end