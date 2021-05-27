require("scripts/game/activity/activity_guide_ctrl")
require("scripts/game/activity/activity_data")
require("scripts/game/activity/activity_guide_data")
require("scripts/game/activity/activity_view")
require("scripts/game/activity/activity_open_remind_view")
require("scripts/game/activity/activity_ranking_view")
require("scripts/game/activity/act_zhen_ying_view")
require("scripts/game/activity/act_boss_inspire_view")
require("scripts/game/activity/act_world_boss_view")
require("scripts/game/activity/act_guild_boss_view")

--------------------------------------------------------
-- 日常活动
--------------------------------------------------------

ActivityCtrl = ActivityCtrl or BaseClass(BaseController)

function ActivityCtrl:__init()
	if ActivityCtrl.Instance then
		ErrorLog("[ActivityCtrl] attempt to create singleton twice!")
		return
	end
	
	ActivityCtrl.Instance = self
	self.data = ActivityData.New()
	self.view = ActivityView.New(ViewDef.Activity)
	self.open_remind_view = ActivityOpenRemindView.New(ViewDef.ActOpenRemind)
	self.act_ranking_view = ActivityRankingView.New(ViewDef.ActRanking)
	self.act_zhen_ying_view = ActZhenYingView.New(ViewDef.ActZhenYing)
	self.act_boss_inspire_view = ActBossInspireView.New(ViewDef.ActBossInspire)
	self.act_world_boss_view = ActWorldBossView.New(ViewDef.ActWorldBoss)
	self.act_guild_boss_view = ActGuildBossView.New(ViewDef.ActGuildBoss)

	self:RegisterGuideProtocols()
	self:RegisterAllEvents()
	self.last_act_type = nil
end

function ActivityCtrl:__delete()
	if nil ~= self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	
	if nil ~= self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if nil ~= self.open_remind_view then
		self.open_remind_view:DeleteMe()
		self.open_remind_view = nil
	end

	if nil ~= self.act_ranking_view then
		self.act_ranking_view:DeleteMe()
		self.act_ranking_view = nil
	end
	if nil ~= self.act_zhen_ying_view then
		self.act_zhen_ying_view:DeleteMe()
		self.act_zhen_ying_view = nil
	end
	if nil ~= self.act_boss_inspire_view then
		self.act_boss_inspire_view:DeleteMe()
		self.act_boss_inspire_view = nil
	end
	if nil ~= self.act_world_boss_view then
		self.act_world_boss_view:DeleteMe()
		self.act_world_boss_view = nil
	end
	if nil ~= self.act_guild_boss_view then
		self.act_guild_boss_view:DeleteMe()
		self.act_guild_boss_view = nil
	end

	ActivityCtrl.Instance = nil
end

function ActivityCtrl:RegisterAllProtocols()
end

function ActivityCtrl:RegisterAllEvents()
	self:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.GetActivityRemindNum, self))
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetActivityRemindNum, self), RemindName.DailyActivity, true, 4)
end

function ActivityCtrl:GetActivityRemindNum(remind_name)
	if not ViewManager.Instance:CanShowUi(ViewName.Activity) then return 0 end
	
	local opened_view_list = ViewManager.Instance:GetEverOpenedViewList()
	local is_opened = opened_view_list[ViewName.Activity]
	
	local allActStateCfg = ActivityData.AllActivitiesOpenTimeCfg()
	local has_open_act = false
	local cur_open_act_info = nil
	local temp_t = {}
	local data_count_max = 3
	local last_type_index = nil
	for k, v in ipairs(allActStateCfg) do
		local temp_data = nil
		if v.is_open_today == 1 and v.is_open == 1 then
			has_open_act = true
			temp_data = v
			last_type_index = k
		end
		
		if #temp_t < data_count_max then
			if temp_data then table.insert(temp_t, temp_data) end
		else
			break
		end
	end
	
	if last_type_index and self.last_act_type ~= allActStateCfg[last_type_index].type then
		self.last_act_type = allActStateCfg[last_type_index].type
		is_opened = false
	end
	
	if #temp_t > 0 then cur_open_act_info = temp_t end
	-- self:ActOpenRemindViewShowState(has_open_act, cur_open_act_info)
	for type = 1, 12 do
		local tip_type = MAINUI_TIP_TYPE["DAILY_ACT_" .. tostring(type)]
		local open = false
		if tip_type then
			for _, v in pairs(cur_open_act_info or {}) do
				if v.type == type then
					open = true
					MainuiCtrl.Instance:InvateTip(tip_type, 1, function(icon)
						icon:RemoveIconEffect()
						ViewManager.Instance:OpenViewByDef(ViewDef.Activity.Activity)
						ViewManager.Instance:FlushViewByDef(ViewDef.Activity.Activity, 0, "all", {select_type = v.type})
					end)
					break
				end
			end
			if not open then
				MainuiCtrl.Instance:InvateTip(tip_type, 0)
			end
		end
	end
	
	if has_open_act and not is_opened then
		return 1
	end
	return 0
end


function ActivityCtrl:ActOpenRemindViewShowState(need_open, param_t)
	local viewName = ViewName.ActOpenRemind
	if need_open and ViewManager.Instance:CanShowUi(ViewName.ActOpenRemind) then
		self.open_remind_view:SetFlushData(param_t)
		ViewManager.Instance:FlushView(viewName)
		ViewManager.Instance:Open(viewName)
	else
		ViewManager.Instance:Close(viewName)
	end
end
