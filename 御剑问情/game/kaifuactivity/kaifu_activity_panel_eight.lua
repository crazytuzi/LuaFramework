KaifuActivityPanelEight = KaifuActivityPanelEight or BaseClass(BaseRender)

local TOGGLE_NUM = 4

function KaifuActivityPanelEight:__init(instance)
	-- self.list = self:FindObj("ListView")
	-- self.list_delegate = self.list.page_simple_delegate
	-- list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	-- list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	-- self.list.scroll_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChanged, self))

	self.toggle_list = {}
	self.red_point_list = {}
	self:ListenEvent("OnClickGetReward", BindTool.Bind(self.OnClickGetReward, self))
	for  i = 1, TOGGLE_NUM do
		self:ListenEvent("OnClickToggle"..i, BindTool.Bind(self.OnClickToggle, self, i))
		self.toggle_list[i] = self:FindObj("Toggle"..i).toggle
		self.red_point_list[i] = self:FindVariable("ShowRedPoint"..i)
	end

	-- self:ListenEvent("OnClickLeft", BindTool.Bind(self.OnClickLeft, self))
	-- self:ListenEvent("OnClickRight", BindTool.Bind(self.OnClickRight, self))

	self.reward_item_list = {
		ItemCell.New(),
		ItemCell.New(),
		ItemCell.New(),
		ItemCell.New(),
	}
	self.reward_item_list[1]:SetInstanceParent(self:FindObj("RewardItem1"))
	self.reward_item_list[2]:SetInstanceParent(self:FindObj("RewardItem2"))
	self.reward_item_list[3]:SetInstanceParent(self:FindObj("RewardItem3"))
	self.reward_item_list[4]:SetInstanceParent(self:FindObj("RewardItem4"))

	self.get_rewar_btn = self:FindObj("GetRewardBtn")
	self.boss_item_cell = PanelEightListCell.New(self:FindObj("BossItemCell"))
	-- self.xinshou_toggle = self:FindObj("XinShouToggle").toggle
	-- self.jinjie_toggle = self:FindObj("JinJieToggle").toggle
	-- self.rongyao_toggle = self:FindObj("RongYaoToggle").toggle
	-- self.wangzhe_toggle = self:FindObj("WangZheToggle").toggle

	self.title = self:FindVariable("Title")

	self.show_get_reward_btn = self:FindVariable("ShowGetBtn")
	self.been_gray = self:FindVariable("BeenGray")
	self.show_effect = self:FindVariable("ShowEffect")
	-- self.show_left_btn = self:FindVariable("ShowLeftBtn")
	-- self.show_right_btn = self:FindVariable("ShowRightBtn")

	-- self.cell_list = {}

	self.boss_list = {}
	self.cur_index = 0

	-- self.xinshou_toggle.isOn = true
	self.toggle_list[1].isOn = true
	self:SetBossInfo(1)
end

function KaifuActivityPanelEight:__delete()
	self.temp_activity_type = nil
	self.activity_type = nil

	-- for k, v in pairs(self.cell_list) do
	-- 	v:DeleteMe()
	-- end
	-- self.cell_list = {}

	for k, v in pairs(self.reward_item_list) do
		v:DeleteMe()
	end
	self.reward_item_list = {}

	self.boss_list = {}
	self.cur_index = nil

	if self.boss_item_cell then
		self.boss_item_cell:DeleteMe()
		self.boss_item_cell = nil
	end
end

-- function KaifuActivityPanelEight:GetNumberOfCells()
-- 	return KaifuActivityData.Instance:MaxBossPageNum()
-- end

-- function KaifuActivityPanelEight:RefreshCell(data_index, cell)
-- 	local cell_item = self.cell_list[cell]
-- 	if cell_item == nil then
-- 		cell_item = PanelEightListCell.New(cell.gameObject)
-- 		self.cell_list[cell] = cell_item
-- 	end
-- 	local cfg_list = KaifuActivityData.Instance:GetShowBossList(data_index)
-- 	cell_item:SetData(cfg_list)
-- 	for i = 1, 4 do
-- 		cell_item:ListenClick(i, BindTool.Bind(self.OnClickBossItem, self, i))
-- 	end
-- end

function KaifuActivityPanelEight:OnClickToggle(index)
	self.cur_index = index - 1
	self:SetBossInfo(index)
end

function KaifuActivityPanelEight:SetBossInfo(index)
	local cfg_list = KaifuActivityData.Instance:GetShowBossList(index - 1)
	self.boss_item_cell:SetData(cfg_list)
	self.boss_list = KaifuActivityData.Instance:GetShowBossList(index - 1)
	for i = 1, 4 do
		self.boss_item_cell:ListenClick(i, BindTool.Bind(self.OnClickBossItem, self, i))
	end
	self:SetGetRewardBtnState(index - 1)
	self:SetRewardItemData(index - 1)
	local reward_cfg = KaifuActivityData.Instance:GetShowBossList(index - 1, true) or {}
	self.title:SetValue(reward_cfg.title or "")
end

function KaifuActivityPanelEight:OnClickBossItem(index)
	if not index then return end

	for k, v in pairs(self.boss_list) do
		if k == index then
			TipsCtrl.Instance:ShowBossInfoView(v.boss_id)
			return
		end
	end
end

-- function KaifuActivityPanelEight:OnValueChanged()
-- 	local page = self.list.page_view.ActiveCellsMiddleIndex

-- 	if self.cur_index ~= page then
-- 		self.cur_index = page
-- 		self.boss_list = KaifuActivityData.Instance:GetShowBossList(self.cur_index)
-- 		local reward_cfg = KaifuActivityData.Instance:GetShowBossList(self.cur_index, true) or {}
-- 		self.title:SetValue(reward_cfg.title or "")
-- 		self:ShowArrowBtnState(self.cur_index)
-- 		self:SetGetRewardBtnState(self.cur_index)
-- 		self:SetRewardItemData(self.cur_index)
-- 	end
-- end

-- function KaifuActivityPanelEight:OnClickLeft()
-- 	if self.cur_index <= 0 then
-- 		return
-- 	end
-- 	self.cur_index = self.cur_index - 1
-- 	self.boss_list = KaifuActivityData.Instance:GetShowBossList(self.cur_index)
-- 	self:ShowArrowBtnState(self.cur_index)
-- 	self:SetRewardItemData(self.cur_index)
-- 	self:SetGetRewardBtnState(self.cur_index)
-- 	if self.list.page_view.isActiveAndEnabled then
-- 		self.list.page_view:JumpToIndex(self.cur_index, 0, 1)
-- 	end
-- end

-- function KaifuActivityPanelEight:OnClickRight()
-- 	if self.cur_index >= KaifuActivityData.Instance:MaxBossPageNum() - 1 then
-- 		return
-- 	end
-- 	self.cur_index = self.cur_index + 1
-- 	self.boss_list = KaifuActivityData.Instance:GetShowBossList(self.cur_index)
-- 	self:ShowArrowBtnState(self.cur_index)
-- 	self:SetRewardItemData(self.cur_index)
-- 	self:SetGetRewardBtnState(self.cur_index)
-- 	if self.list.page_view.isActiveAndEnabled then
-- 		self.list.page_view:JumpToIndex(self.cur_index, 0, 1)
-- 	end
-- end

-- 设置左右按钮状态
function KaifuActivityPanelEight:ShowArrowBtnState(cur_index)
	-- local cur_index = cur_index or self.cur_index
	-- self.show_left_btn:SetValue(cur_index > 0)
	-- self.show_right_btn:SetValue(cur_index < KaifuActivityData.Instance:MaxBossPageNum() - 1)
end

function KaifuActivityPanelEight:SetRewardItemData(cur_index)
	local cur_index = cur_index or self.cur_index
	local reward_cfg = KaifuActivityData.Instance:GetShowBossList(cur_index, true) or {}
	local gift_list = ItemData.Instance:GetGiftItemList(reward_cfg.reward_item and reward_cfg.reward_item.item_id or 0)
	local count = 0

	if next(gift_list) then
		local is_destory_effect = true

		for k, v in pairs(gift_list) do
			if self.reward_item_list[k] then
				for _, v2 in pairs(reward_cfg.item_special or {}) do
					if v2.item_id == v.item_id then
						self.reward_item_list[k]:IsDestoryActivityEffect(false)
						self.reward_item_list[k]:SetActivityEffect()
						is_destory_effect = false
						break
					end
				end

				if is_destory_effect then
					self.reward_item_list[k]:IsDestoryActivityEffect(is_destory_effect)
					self.reward_item_list[k]:SetActivityEffect()
				end

				self.reward_item_list[k]:SetGiftItemId(reward_cfg.reward_item.item_id)
				self.reward_item_list[k]:SetActive(true)
				self.reward_item_list[k]:SetData(v)
				count = count + 1
			end
		end
	else
		for k, v in pairs(reward_cfg) do
			if k == "reward_item" then
				count = count + 1
				self.reward_item_list[count]:SetActive(true)
				self.reward_item_list[count]:SetData(v)
			end
		end
	end
	for i = count + 1, #self.reward_item_list do
		if self.reward_item_list[i] then
			self.reward_item_list[i]:SetActive(false)
		end
	end
	self.title:SetValue(reward_cfg.title)
end

function KaifuActivityPanelEight:SetGetRewardBtnState(cur_index)
	local cur_index = cur_index or self.cur_index
	-- local is_get_reward = KaifuActivityData.Instance:GetBossRewardIsGet(cur_index)
	-- local is_complete = KaifuActivityData.Instance:GetBossIsComplete(cur_index)
	local flag = KaifuActivityData.Instance:GetShowBossList(cur_index).flag or -1
	self.show_get_reward_btn:SetValue(flag ~= 0) -- (is_complete and not is_get_reward) or not is_complete
	self.been_gray:SetValue(flag == 2)
	self.get_rewar_btn.button.interactable = flag == 2
	self.show_effect:SetValue(flag == 2)
end

function KaifuActivityPanelEight:OnClickGetReward()
	local cfg = KaifuActivityData.Instance:GetShowBossList(self.cur_index) or {}
	-- if KaifuActivityData.Instance:GetBossIsComplete(self.cur_index) then
	if cfg.flag and cfg.flag == 2 then
		-- local reward_cfg = KaifuActivityData.Instance:GetShowBossList(cfg.seq, true)
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(self.temp_activity_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH_BOSS, cfg.seq)
		return
	end

	TipsCtrl.Instance:ShowSystemMsg(Language.Common.NoComplete)
end

function KaifuActivityPanelEight:Flush(activity_type)
	if not KaifuActivityData.Instance:IsBossLieshouType(activity_type) then print_error("不是boss猎命类型", activity_type) return end

	self.boss_list = KaifuActivityData.Instance:GetShowBossList(self.cur_index)

	for i = 0, 3 do
		local cfg = KaifuActivityData.Instance:GetShowBossList(i)
		local flag = cfg and cfg.flag or 0
		self.red_point_list[i + 1]:SetValue(flag == 2)
	end

	-- self.list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	-- self.list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	-- if activity_type == self.temp_activity_type then
	-- 	self.list.page_view:RefreshActiveCellViews()
	-- else
	-- 	if self.list.page_view.isActiveAndEnabled then
	-- 		self.list.page_view:ReloadData(0)
	-- 	end
	-- end

	-- if self.list.page_view.isActiveAndEnabled then
	-- 	self.list.page_view:Reload()
	-- end
	local toggle_index = self.boss_list.seq and (self.boss_list.seq + 1) or 1
	if self.toggle_list[toggle_index] then
		self.toggle_list[toggle_index].isOn = true
	end
	self:ShowArrowBtnState(self.cur_index)
	self:SetRewardItemData(self.cur_index)
	self:SetGetRewardBtnState(self.cur_index)

	-- self.list.page_view:JumpToIndex(0)

	self.temp_activity_type = activity_type
end


PanelEightListCell = PanelEightListCell or BaseClass(BaseRender)

function PanelEightListCell:__init(instance)
	self.icon_list = {
			self:FindVariable("Icon1"),
			self:FindVariable("Icon2"),
			self:FindVariable("Icon3"),
			self:FindVariable("Icon4"),
	}
	self.name_list = {
			self:FindVariable("Name1"),
			self:FindVariable("Name2"),
			self:FindVariable("Name3"),
			self:FindVariable("Name4"),
	}
	self.level_list = {
			self:FindVariable("Level1"),
			self:FindVariable("Level2"),
			self:FindVariable("Level3"),
			self:FindVariable("Level4"),
	}

	self.show_had_kill = {
			self:FindVariable("ShowHadKill1"),
			self:FindVariable("ShowHadKill2"),
			self:FindVariable("ShowHadKill3"),
			self:FindVariable("ShowHadKill4"),
	}
	self.monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
end

function PanelEightListCell:__delete()
	self.monster_cfg = {}
end

function PanelEightListCell:SetData(data_list)
	if not data_list then return end

	for k, v in pairs(data_list) do
		if type(v) == "table" then
			local cfg = self.monster_cfg[v.boss_id]
			if not cfg then print_error("没有此怪物配置  monster_id :", v.boss_id) return end
			local boss_cfg = KaifuActivityData.Instance:GetBossInfoById(v.boss_id)
			if cfg.headid > 0 then
				local bundle, asset = ResPath.GetBossIcon(cfg.headid)
				self.icon_list[k]:SetAsset(bundle, asset)
			end

			self.name_list[k]:SetValue(cfg.name)
			self.level_list[k]:SetValue(cfg.level)
			self.show_had_kill[k]:SetValue(KaifuActivityData.Instance:BossIsKill(v.seq))
		end
	end
end

function PanelEightListCell:ListenClick(i, handler)
	self:ClearEvent("Click"..i)
	self:ListenEvent("Click"..i, handler)
end