--无双装备领主
TianshenhutiBigBossView = TianshenhutiBigBossView or BaseClass(BaseRender)
local old_res = 0
function TianshenhutiBigBossView:__init()
	self.award_items = {}

	for i = 1, 4 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self:FindObj("Item_"..i))
		self.award_items[i] = item_cell
	end

	self.model_display = self:FindObj("Display")
	self.model_view = RoleModel.New()
	self.model_view:SetDisplay(self.model_display.ui3d_display)
	self.is_first_open = true

	self.explain = self:FindVariable("explain")
	self.boss_name = self:FindVariable("boss_name")

	self:ListenEvent("MoveToBoss", BindTool.Bind(self.ClickMoveTo, self))
end

function TianshenhutiBigBossView:__delete()
	if self.model_view ~= nil then
		self.model_view:DeleteMe()
		self.model_view = nil
	end

	if self.award_items then
		for k,v in pairs(self.award_items) do
			v:DeleteMe()
		end
	end
	self.award_items = {}
	old_res = 0
end

function TianshenhutiBigBossView:OpenCallBack()
	self:Flush()
end

function TianshenhutiBigBossView:CloseCallBack()

end

function TianshenhutiBigBossView:OnFlush()
	self:FlushModel()
	self:SetExplain()
end

function TianshenhutiBigBossView:ClickMoveTo()
	local boss_info = TianshenhutiData.Instance:GetWeekendBigBossInfo()
	
	if boss_info[1] == nil or boss_info[1].boss_status == 0 then  
		TipsCtrl.Instance:ShowSystemMsg(Language.WeekendBoss.NoAct)
		return
	end

	GuajiCtrl.Instance:FlyToScenePos(boss_info[1].scene_id, boss_info[1].pos_x, boss_info[1].pos_y)
	ViewManager.Instance:Close(ViewName.TianshenhutiView)
end

function TianshenhutiBigBossView:SetExplain()
	local act_info = ActivityData.Instance:GetActivityInfoById(ACTIVITY_TYPE.ACTIVITY_TYPE_WEEKEND_BOSS) --获取活动信息
	local open_day = Split(act_info.open_day, ":")
	local open_tiem = Split(act_info.open_time, "|")
	local end_time = Split(act_info.end_time, "|")
	local min_level = tonumber(act_info.min_level)  --最低等级
	local level_str = PlayerData.GetLevelString(min_level)
	local time_des = ""

	time_des = string.format(Language.WeekendBoss.Time, Language.Common.DayToChs[tonumber(open_day[1])], Language.Common.DayToChs[tonumber(open_day[2])],
		open_tiem[1], end_time[1],  open_tiem[2], end_time[2])  --开启时间

	local explain = string.format(Language.Activity.DetailExplain, level_str, time_des, act_info.dec)

	self.explain:SetValue(explain)

	for i = 1, 4 do
		self.award_items[i]:SetData(act_info["reward_item"..i])
		if act_info["reward_item"..i] == nil then
			self.award_items[i]:SetItemActive(false)
		else
			self.award_items[i]:SetItemActive(true)
		end
	end
end

function TianshenhutiBigBossView:FlushModel()
	local boss_info = TianshenhutiData.Instance:GetBossID(0)
	local monster_info = TianshenhutiData.Instance:GetMonsterCfg()
	if self.model_view == nil or boss_info == nil then
		return
	end
	local res_id = monster_info[boss_info].resid
	if old_res ~= res_id then
		old_res = res_id
		self.boss_name:SetValue(monster_info[boss_info].name)
		self.model_view:SetPanelName("tianshen_bigboss_panel")
		self.model_view:SetMainAsset(ResPath.GetMonsterModel(res_id))
		self.model_view:SetTrigger("rest1")
	end
end