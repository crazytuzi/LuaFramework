--无双装备boss
TianshenhutiBossView = TianshenhutiBossView or BaseClass(BaseRender)
local old_res = 0
function TianshenhutiBossView:__init()
	self.award_items = {}

	for i = 1, 4 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self:FindObj("Item_"..i))
		self.award_items[i] = item_cell
	end

	self.model_display = self:FindObj("Display")
	self.model_view = RoleModel.New("boss_panel")
	self.model_view:SetDisplay(self.model_display.ui3d_display)
	self.is_first_open = true

	self.explain = self:FindVariable("explain")
	self.boss_info = self:FindVariable("boss_info")
	self.count_down = self:FindVariable("boss_countdown")
	self.no_boss = self:FindVariable("no_boss")
	self:ListenEvent("MoveToBoss", BindTool.Bind(self.ClickMoveTo, self))

	self.least_time_timer = 0
	self.res_time = {}
end

function TianshenhutiBossView:__delete()
	if self.model_view ~= nil then
		self.model_view:DeleteMe()
		self.model_view = nil
	end

	if self.flush_timer then
		GlobalTimerQuest:CancelQuest(self.flush_timer)
		self.flush_timer = nil
	end

	old_res = 0
end

function TianshenhutiBossView:OpenCallBack()
	self:Flush()
	self:SetCountDown()
end

function TianshenhutiBossView:CloseCallBack()
	if self.least_time_timer then
    	CountDown.Instance:RemoveCountDown(self.least_time_timer)
    	self.least_time_timer = nil
  	end
end

function TianshenhutiBossView:OnFlush()
	local act_info = TianshenhutiData.Instance:GetWeekendBossCfg().other
	local boss_info = TianshenhutiData.Instance:GetWeekendBossInfo()
	local boss_num = TianshenhutiData.Instance:GetWeekendBossCount(boss_info[1].scene_id) or 0
	local scene_config = nil
	if next(boss_info) ~= nil and boss_info[1].scene_id ~= 0 then
		scene_config = ConfigManager.Instance:GetSceneConfig(boss_info[1].scene_id)
	end
	local text = ""

	self:FlushModel()
	self:SetExplain()

	if scene_config and next(boss_info) ~= nil and boss_num > 0 then
		text = string.format(Language.WeekendBoss.HaveBoss, scene_config.name, boss_num)
		self.no_boss:SetValue(false)
		self.boss_info:SetValue(text)
	else
		self.no_boss:SetValue(true)
	end

	for i = 1, 4 do
		self.award_items[i]:SetData(act_info[1].show_item[i - 1])
		if act_info[1].show_item[i - 1] == nil then
			self.award_items[i]:SetItemActive(false)
		else
			self.award_items[i]:SetItemActive(true)
		end
	end

	self:SetCountDown()
end

function TianshenhutiBossView:ClickMoveTo()
	local boss_info = TianshenhutiData.Instance:GetWeekendBossInfo()
	local boss_list = TianshenhutiData.Instance:GetBossStatu()

	local random = boss_list[math.random(1, #boss_list)]

	if #boss_list <= 0 then
		TipsCtrl.Instance:ShowSystemMsg(Language.WeekendBoss.NoBoss)
		return
	end

	ViewManager.Instance:Close(ViewName.TianshenhutiView)

	GuajiCtrl.Instance:FlyToScenePos(boss_info[random].scene_id, boss_info[random].pos_x, boss_info[random].pos_y)
end

function TianshenhutiBossView:SetExplain()
	local act_info = TianshenhutiData.Instance:GetWeekendBossCfg().other
	local min_level = act_info[1].min_level or 0
	local level_str = PlayerData.GetLevelString(min_level)
	local time_des = ""

	time_des = string.format("%s:00 - %s:00", act_info[1].equip_boss_refresh_start_time, act_info[1].equip_boss_refresh_end_time)  --时间

	local explain = string.format(Language.Activity.DetailExplain, level_str, time_des, act_info[1].play_dec)

	self.explain:SetValue(explain)
end

function TianshenhutiBossView:SetTime()
	local time = TianshenhutiData.Instance:GetBossRefreshTime() - TimeCtrl.Instance:GetServerTime()

	if time > 0 then 
		local text = string.format(Language.WeekendBoss.FlushBoss, TimeUtil.FormatSecond(time))
		self.count_down:SetValue(text)
	else
		self:Flush()
	end
end

function TianshenhutiBossView:SetCountDown()
    if self.flush_timer == nil then
		self.flush_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.SetTime, self), 1)
		self:SetTime()
	end
end

function TianshenhutiBossView:FlushModel()
	local boss_info = TianshenhutiData.Instance:GetBossID(1)
	local monster_info = TianshenhutiData.Instance:GetMonsterCfg()
	if self.model_view == nil or nil == boss_info then
		return
	end

	local res_id = monster_info[boss_info].resid
	if old_res ~= res_id then
		old_res = res_id
		self.model_view:SetPanelName("tianshen_boss_panel")
		self.model_view:SetMainAsset(ResPath.GetMonsterModel(res_id))
	end
end