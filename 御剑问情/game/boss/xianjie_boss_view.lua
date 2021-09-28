XianJieBossView = XianJieBossView or BaseClass(BaseRender)

function XianJieBossView:__init()
	self.select_boss_id = 0

	self.left_count = self:FindVariable("LeftCount")
	self.max_count = self:FindVariable("MaxCount")

	self.boss_data = BossData.Instance:GetXianJieBossCfg()
	self.boss_cell_list = {}
	self.list_view = self:FindObj("BossList")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.reward_data = {}
	self.reward_cell_list = {}
	self.reward_list = self:FindObj("RewardList")
	self.reward_view_delegate = self.reward_list.list_simple_delegate
	self.reward_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetRewardNumberOfCells, self)
	self.reward_view_delegate.CellRefreshDel = BindTool.Bind(self.ReRewardfreshView, self)

	self:ListenEvent("QuestionClick",
		BindTool.Bind(self.QuestionClick, self))
	self:ListenEvent("OpenKillRecord",
		BindTool.Bind(self.OpenKillRecord, self))
	self:ListenEvent("ToActtack",
		BindTool.Bind(self.ToActtack, self))

	local model_display = self:FindObj("display")
	self.model_view = RoleModel.New("boss_panel")
	self.model_view:SetDisplay(model_display.ui3d_display)
end

function XianJieBossView:__delete()
	if self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
	end

	for _, v in pairs(self.boss_cell_list) do
		v:DeleteMe()
	end
	self.boss_cell_list = {}

	for _, v in pairs(self.reward_cell_list) do
		v:DeleteMe()
	end
	self.reward_cell_list = {}
end

function XianJieBossView:QuestionClick()
	TipsCtrl.Instance:ShowHelpTipView(242)
end

function XianJieBossView:OpenKillRecord()
end

function XianJieBossView:ToActtack()
	local pos_cfg = BossData.Instance:GetXianJieBossPosCfgByBossId(self.select_boss_id)
	if pos_cfg then
		local scene_id = pos_cfg.scene_id
		local scene_config = ConfigManager.Instance:GetSceneConfig(scene_id)
		BossData.Instance:SetCurInfo(scene_id, self.select_boss_id)
		BossCtrl.SendEnterBossFamily(BOSS_ENTER_TYPE.XIAN_JIE_BOSS, scene_id, 0, self.select_boss_id)
		ViewManager.Instance:Close(ViewName.Boss)
	end
end

function XianJieBossView:GetNumberOfCells()
	return 2
end

function XianJieBossView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local boss_cell = self.boss_cell_list[cell]
	if nil == boss_cell then
		boss_cell = XianJieBossCell.New(cell.gameObject)
		boss_cell:SetClickCallBack(BindTool.Bind(self.ClickBossCallBack, self))
		boss_cell:SetToggleGroup(self.list_view.toggle_group)
		self.boss_cell_list[cell] = boss_cell
	end

	local data = self.boss_data[data_index]
	boss_cell:SetData(data)

	if nil ~= data and data.boss_id == self.select_boss_id then
		boss_cell:SetToggleIsOn(true)
	else
		boss_cell:SetToggleIsOn(false)
	end
end

function XianJieBossView:ClickBossCallBack(cell)
	if nil == cell then
		return
	end

	local data = cell:GetData()
	if nil == data then
		return
	end

	if self.select_boss_id == data.boss_id then
		return
	end

	self.select_boss_id = data.boss_id

	self.reward_data = BossData.Instance:GetXianJieBossRewardList(self.select_boss_id) or {}

	self:FlushRight()
end

function XianJieBossView:GetRewardNumberOfCells()
	return #self.reward_data
end

function XianJieBossView:ReRewardfreshView(cell, data_index)
	data_index = data_index + 1
	local reward_cell = self.reward_cell_list[cell]
	if nil == reward_cell then
		reward_cell = XianJieRewardCell.New(cell.gameObject)
		self.reward_cell_list[cell] = reward_cell
	end

	reward_cell:SetData(self.reward_data[data_index])
end

function XianJieBossView:InitView()
	--获取当前选择的bossid
	local first_boss_info = self.boss_data[1]
	if first_boss_info then
		self.select_boss_id = first_boss_info.boss_id
	end

	--设置数据
	self.reward_data = BossData.Instance:GetXianJieBossRewardList(self.select_boss_id) or {}

	--刷新boss列表
	self:FlushBossList(true)

	--刷新右边
	self:FlushRight()
end

function XianJieBossView:FlushBossList(is_init)
	if is_init then
		self.list_view.scroller:ReloadData(0)
	else
		self.list_view.scroller:RefreshActiveCellViews()
	end
end

function XianJieBossView:FlushRewardList()
	self.reward_list.scroller:ReloadData(0)
end

function XianJieBossView:FlushModel()
	local boss_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.select_boss_id]
	if boss_cfg then
		local res_id = boss_cfg.resid
		local bundle, asset = ResPath.GetMonsterModel(res_id)
		local function load_callback()
			self.model_view:SetTrigger("rest1")
		end
		local display_name = BossData.Instance:DisplayName(res_id)
		self.model_view:SetPanelName(display_name)
		self.model_view:SetMainAsset(bundle, asset, load_callback)
	end
end

function XianJieBossView:FlushOther()
	local other_cfg = BossData.Instance:GetXianJieBossOtherCfg()

	local day_count = BossData.Instance:GetXianJieBossDayCount()
	local day_count_color = TEXT_COLOR.YELLOW1
	local left_count = other_cfg.role_reward_limit - day_count
	left_count = left_count < 0 and 0 or left_count
	if left_count == 0 then
		day_count_color = TEXT_COLOR.RED
	end
	local day_count_str = ToColorStr(left_count, day_count_color)
	self.left_count:SetValue(day_count_str)
	self.max_count:SetValue(other_cfg.role_reward_limit)
end

function XianJieBossView:FlushRight()
	self:FlushModel()
	self:FlushRewardList()
	self:FlushOther()
end

function XianJieBossView:FlushView()
	self:FlushBossList()
	self:FlushRight()
end

----------------------------------------------------------
-----------------XianJieBossCell--------------------------
----------------------------------------------------------

XianJieBossCell = XianJieBossCell or BaseClass(BaseCell)

function XianJieBossCell:__init()
	self.level = self:FindVariable("Level")
	self.icon = self:FindVariable("Icon")
	self.name = self:FindVariable("Name")
	self.time = self:FindVariable("Time")
	self.ispk = self:FindVariable("is_pk")
	self.canKill = self:FindVariable("canKill")
	self.show_labelrare = self:FindVariable("show_label_rare")
	self.icon_image = self:FindVariable("icon_image")
	self:ListenEvent("ClickItem", BindTool.Bind(self.OnClick, self))
end

function XianJieBossCell:__delete()
	self:StopCountDown()
	self:RemoveDelayTime()
end

function XianJieBossCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function XianJieBossCell:SetToggleIsOn(is_on)
	self.root_node.toggle.isOn = is_on
end

function XianJieBossCell:StopCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function XianJieBossCell:RemoveDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

function XianJieBossCell:OnFlush()
	if nil == self.data then
		return
	end
	self:StopCountDown()

	local boss_id = self.data.boss_id

	local boss_info = BossData.Instance:GetXianJieBossInfoByBossId(boss_id)
	if boss_info then
		self.canKill:SetValue(boss_info.status == BOSS_STATUS.EXISTENT)

		if boss_info.status == BOSS_STATUS.NOT_EXISTENT then
			--不存在就显示倒计时
			local next_refresh_time = boss_info.next_refresh_time
			local left_time = next_refresh_time - TimeCtrl.Instance:GetServerTime()
			left_time = math.ceil(left_time)
			if left_time > 0 then
				local function timer_func(elapse_time, total_time)
					if elapse_time >= total_time then
						self:StopCountDown()
						self.delay_time = GlobalTimerQuest:AddDelayTimer(function()
							BossCtrl.Instance:RequestXianjieBossInfo()
						end, 1)
						return
					end

					local temp_time = total_time - elapse_time
					temp_time = math.ceil(temp_time)
					local time_str = TimeUtil.FormatSecond(temp_time)
					time_str = string.format(Language.Boss.LimitTimeFlush, time_str)
					self.time:SetValue(time_str)
				end

				self.count_down = CountDown.Instance:AddCountDown(left_time, 1, timer_func)

				local time_str = TimeUtil.FormatSecond(left_time)
				time_str = string.format(Language.Boss.LimitTimeFlush, time_str)
				self.time:SetValue(time_str)
			end
		end
	end

	local boss_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[boss_id]
	local pos_cfg = BossData.Instance:GetXianJieBossPosCfgByBossId(boss_id)
	if boss_cfg and pos_cfg then
		--设置资源
		local head_id = boss_cfg.headid
		local bundle, asset = ResPath.GetBossItemIcon(boss_cfg.headid)
		self.icon_image:SetAsset(bundle, asset)
		self.icon:SetAsset(ResPath.GetBoss("bg_rare_02"))
		--设置名字
		local name = boss_cfg.name
		self.name:SetValue(name)

		local level_str = ToColorStr("Lv." .. boss_cfg.level, SOUL_NAME_COLOR[1])
		self.level:SetValue(level_str)

		local scene_id = pos_cfg.scene_id
		self.show_labelrare:SetValue(false)
		local is_forbid_pk = ConfigManager.Instance:GetSceneConfig(scene_id).is_forbid_pk or 0
		if is_forbid_pk ~= 1 then
			self.ispk:SetValue(true)
			self.icon:SetAsset(ResPath.GetBoss("bg_rare_01"))
			self.show_labelrare:SetValue(true)
		end
	end
end

----------------------------------------------------------
-----------------XianJieRewardCell--------------------------
----------------------------------------------------------

XianJieRewardCell = XianJieRewardCell or BaseClass(BaseCell)

function XianJieRewardCell:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.root_node)
end

function XianJieRewardCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function XianJieRewardCell:OnFlush()
	if nil == self.data then
		return
	end

	self.item_cell:SetData(self.data)
end