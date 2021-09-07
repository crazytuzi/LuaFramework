KaifuActivityPanelBossReward = KaifuActivityPanelBossReward or BaseClass(BaseRender)
local TOGGLE_NUM = 4

function KaifuActivityPanelBossReward:__init(instance)
	self.cur_index = 0
	self.has_check = false
	self.cell_list = {}
	self.reward_list = {}
	self.toggle_list = {}
	self.chapter_name_t = {}
	self.show_red_point = {}
end

function KaifuActivityPanelBossReward:LoadCallBack()
	for i = 1, 3 do
		self.reward_list[i] = ItemCell.New()
		self.reward_list[i]:SetInstanceParent(self:FindObj("RewardItem" .. i))
	end

	for i = 1, TOGGLE_NUM do
		self.chapter_name_t[i] = self:FindVariable("ChapteName" .. i)
		self.show_red_point[i] = self:FindVariable("ShowRedPoint" .. i)
		self.toggle_list[i] = self:FindObj("Toggle"..i).toggle
		self.toggle_list[i]:AddValueChangedListener(BindTool.Bind(self.OnClickToggle,self, i))
	end

	self.boss_list = self:FindObj("BossList")
	self.boss_list_view_delegate = self.boss_list.list_simple_delegate
	self.boss_list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.boss_list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	self.can_receive = self:FindVariable("CanReceive")
	self.has_receive = self:FindVariable("HasReceive")
	self.reward_text = self:FindVariable("RewardDesc")

	self:ListenEvent("OnClickGetReward", BindTool.Bind(self.OnClickGetReward, self))

	self:FlushBossInfo(self.cur_index)
end

function KaifuActivityPanelBossReward:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for k,v in pairs(self.reward_list) do
		v:DeleteMe()
	end
	self.reward_list = {}
	self.cur_index = 0
	self.has_check = false
end

function KaifuActivityPanelBossReward:CheckToggleIsOn()
	local info = KaifuActivityData.Instance:GetBossXuanshangInfo()
	local chose_index = info.cur_phase + 1
	if info and info.cur_phase and not self.has_check then
		for i=1, TOGGLE_NUM do
		local can_receive = KaifuActivityData.Instance:GetBossRewardCanReceive(i - 1)
		local has_receive = KaifuActivityData.Instance:GetBossIsKillByPhase(i - 1, 0)
			if can_receive and not has_receive then
				chose_index = i
			else
				self.toggle_list[i].isOn = false
			end
		end
		self.toggle_list[chose_index].isOn = true
		self:OnClickToggle(chose_index, true)
		self.has_check = true
	end
end

function KaifuActivityPanelBossReward:GetNumberOfCells()
	return 3
end

function KaifuActivityPanelBossReward:RefreshView(cell, data_index)
	data_index = data_index + 1

	local boss_reward_cell = self.cell_list[cell]
	if boss_reward_cell == nil then
		boss_reward_cell = BossRewardItemCell.New(cell.gameObject)
		self.cell_list[cell] = boss_reward_cell
	end
	boss_reward_cell:SetData(KaifuActivityData.Instance:GetBossRewardCfgByPhase(self.cur_index, data_index))
	boss_reward_cell:SetIndex(data_index)
end

function KaifuActivityPanelBossReward:OnClickToggle(index, is_on)
	if self.delay then return end
	if is_on then
		local info = KaifuActivityData.Instance:GetBossXuanshangInfo()
		if index > info.cur_phase + 1 then
			self.delay = GlobalTimerQuest:AddDelayTimer(function()
				self.toggle_list[self.cur_index + 1].isOn = true
				self.delay = nil
			end, 0)

			SysMsgCtrl.Instance:ErrorRemind(Language.BossXuanShang.TaskNotFinish)
		else
			self.cur_index = index - 1
			-- self.boss_list.scroller:RefreshAndReloadActiveCellViews(true)
			self.boss_list.scroller:ReloadData(0)
			self:FlushBossInfo(self.cur_index)
			self:FlushRewardState()
		end
	end
end

function KaifuActivityPanelBossReward:OnClickGetReward()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BOSS_XUANSHANG, RA_BOSS_XUANSHANG_REQ_TYPE.RA_BOSS_XUANSHANG_REQ_TYP_FETCH_PHASE_REWARD, self.cur_index)
end

function KaifuActivityPanelBossReward:FlushBossInfo(index)
	local cfg = KaifuActivityData.Instance:GetBossRewardCfgByPhase(index, 0)
	if cfg.reward_item then
		local data = ItemData.Instance:GetGiftItemList(cfg.reward_item.item_id)
		for k,v in pairs(self.reward_list) do
			v:SetData(data[k])
		end
	end
end

function KaifuActivityPanelBossReward:SetCurTyoe(cur_type)
	self.cur_type = cur_type
end

function KaifuActivityPanelBossReward:OnFlush()
	local activity_type = self.cur_type
	local info = KaifuActivityData.Instance:GetBossXuanshangInfo()
	for k,v in pairs(self.chapter_name_t) do
		if info.cur_phase < k - 1 then
			v:SetValue("????")
		else
			v:SetValue(Language.BossXuanShang.ChapterName[k])
		end
		self.show_red_point[k]:SetValue(not KaifuActivityData.Instance:GetBossIsKillByPhase(k - 1, 0) and KaifuActivityData.Instance:GetBossRewardCanReceive(k - 1))
	end

	self:FlushRewardState()
	self:CheckToggleIsOn()
end

function KaifuActivityPanelBossReward:FlushRewardState()
	local can_receive = KaifuActivityData.Instance:GetBossRewardCanReceive(self.cur_index)
	self.can_receive:SetValue(can_receive)

	local has_receive = KaifuActivityData.Instance:GetBossIsKillByPhase(self.cur_index, 0)
	self.has_receive:SetValue(has_receive)

	local finish_num = KaifuActivityData.Instance:GetBossRewardFinishNum(self.cur_index)
	if finish_num < 3 then
		self.reward_text:SetValue(string.format(Language.BossXuanShang.RewardDesc1 ,finish_num, 3))
	else
		self.reward_text:SetValue(string.format(Language.BossXuanShang.RewardDesc2 ,finish_num, 3))
	end
end

----------------------BossRewardItemCell------------------------------
BossRewardItemCell = BossRewardItemCell or BaseClass(BaseCell)

function BossRewardItemCell:__init()
	self:ListenEvent("Click", BindTool.Bind(self.ClickItem, self))
end

function BossRewardItemCell:__delete()
	for i = 1, 3 do
		if self.item_list[i] then
			self.item_list[i]:DeleteMe()
			self.item_list[i] = nil
		end
	end
end

function BossRewardItemCell:LoadCallBack()
	self.boss_name = self:FindVariable("BossName")
	self.boss_degree = self:FindVariable("BossDegree")
	self.boss_type = self:FindVariable("BossType")
	self.boss_fight = self:FindVariable("RecommendFighting")
	self.boss_introduce = self:FindVariable("BossIntroduce")
	self.boss_icon = self:FindVariable("BossIcon")
	self.is_kill = self:FindVariable("is_kill")

	self.item_list = {}
	for i = 1, 3 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("BossItemCell" .. i))
	end
end

function BossRewardItemCell:ClickItem()
	if nil == self.data or nil == next(self.data) then return end
	if self.data.is_kill then return end
	if self.data.skip and self.data.skip ~= "" then
		local param_list = Split(self.data.skip, "#")
		if param_list[2] then
			ViewManager.Instance:OpenByCfg(self.data.skip, nil, param_list[2] .. "_index")
		end
	end
end

function BossRewardItemCell:OnFlush()
	if nil == self.data or nil == next(self.data) then return end

	self.boss_name:SetValue(string.format(Language.BossXuanShang.BossName, self.data.boss_name))
	self.boss_degree:SetValue(string.format(Language.BossXuanShang.BossDegree, self.data.difficulty))
	self.boss_type:SetValue(string.format(Language.BossXuanShang.BossType, self.data.boss_type))
	self.boss_fight:SetValue(string.format(Language.BossXuanShang.BossPower, self.data.tuijian_capability))
	self.boss_introduce:SetValue(string.format(Language.BossXuanShang.BossIntro, self.data.description))
	self.is_kill:SetValue(self.data.is_kill)

	local boss_cfg = BossData.Instance:GetMonsterInfo(self.data.kill_boss_id)
	if boss_cfg.headid > 0 then
		local bundle, asset = ResPath.GetBossIcon(boss_cfg.headid)
		self.boss_icon:SetAsset(bundle, asset)
	end

	for i = 1, 3 do
		self.item_list[i]:SetData(self.data.reward_list[i])
	end
end
