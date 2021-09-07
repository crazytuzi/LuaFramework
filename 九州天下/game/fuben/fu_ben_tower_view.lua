FuBenTowerView = FuBenTowerView or BaseClass(BaseRender)

local TOP_CELL_SIZE = 243
local BOTTOM_CELL_SIZE = 209
local NORMAL_CELL_SIZE = 182
local CENTER_POINT_OFFSET = 60
local TOP_INDEX = 0

function FuBenTowerView:__init(instance)
	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshTowerCell, self)
	list_delegate.CellSizeDel = BindTool.Bind(self.CellSizeDel, self)

	local enhance_scroller = self.list_view.scroller
	enhance_scroller.scrollerScrolled = BindTool.Bind(self.ScrollerScrolledDelegate, self)

	-- 把ScrollRect设置成不能拖动
	self.list_view.scroll_rect.horizontal = false
	self.list_view.scroll_rect.vertical = false

	self:ListenEvent("OnClickChallenge",
		BindTool.Bind(self.OnClickChallenge, self))
	self:ListenEvent("OnClickOneKey",
		BindTool.Bind(self.OnClickOneKey, self))
	self:ListenEvent("BtnHelpTip",
		BindTool.Bind(self.BtnHelpTip, self))

	-- self.saodang_btn_text = self:FindVariable("SaodangBtnText")
	self.chanllge_text = self:FindVariable("ChallengeText")
	self.fight_power_text = self:FindVariable("FightPower")
	self.title_level = self:FindVariable("TitleLevel")
	self.reward_title = self:FindVariable("RewardTitle")

	self.show_challenge_ben = self:FindVariable("ShowChallegeBtn")
	self.show_arrow_image = self:FindVariable("ShowArrowIma")
	self.show_click_mask = self:FindVariable("ShowClickMask")
	self.show_max_tip = self:FindVariable("ShowMaxLevel")
	self.is_max_saodang = self:FindVariable("MaxSaodang")
	self.grade_curr = self:FindVariable("GradeCurr")	
	self.show_red_point = self:FindVariable("ShowRedPoint")

	-- self.saodang_btn = self:FindObj("SaodangBtn")
	self.chanllge_btn = self:FindObj("ChallengeBtn")
	self.title_root = self:FindObj("TitleRoot")

	-- self.item_cells = {}

	self.first_item_cell = {}
	self.first_item_cells = {}
	self.first_item_cells[1] = ItemCell.New()
	self.first_item_cells[1]:SetInstanceParent(self:FindObj("FirstItem1"))
	self.first_item_cells[2] = ItemCell.New()
	self.first_item_cells[2]:SetInstanceParent(self:FindObj("FirstItem2"))
	self.first_item_cells[3] = ItemCell.New()
	self.first_item_cells[3]:SetInstanceParent(self:FindObj("FirstItem3"))
	self.first_item_cells[4] = ItemCell.New()
	self.first_item_cells[4]:SetInstanceParent(self:FindObj("FirstItem4"))

	self.day_reward_cell = {}
	for i=1,4 do
		self.day_reward_cell[i] = ItemCell.New()
		self.day_reward_cell[i]:SetInstanceParent(self:FindObj("DayRewardCell"..i))
	end

	self.list = {}
	self.touch_up_time = 0
	self.is_onekey_saodang = false
	self.cur_layer = 0

	--引导用按钮
	self.tower_challenge = self:FindObj("TowerChallenge")
end

function FuBenTowerView:__delete()
	if self.jump_to_index ~= nil then
		GlobalTimerQuest:CancelQuest(self.jump_to_index)
		self.jump_to_index = nil
	end

	if self.day_reward_cell then
		for k, v in pairs(self.day_reward_cell) do
			v:DeleteMe()
		end
	end

	for k, v in pairs(self.list) do
		if v then
			v:DeleteMe()
		end
	end
	self.list = {}
	self.is_onekey_saodang = nil
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
		self.is_onekey_saodang = false
	end
	if self.first_item_cell then
		for k, v in pairs(self.first_item_cells) do
			v:DeleteMe()
		end
		self.first_item_cells = {}
	end

	if self.title_obj then
		GameObject.Destroy(self.title_obj)
		self.title_obj = nil
	end
end

function FuBenTowerView:ScrollerScrolledDelegate(go, position, lenght)
	local fb_info = FuBenData.Instance:GetTowerFBInfo()
	if not fb_info or nil == next(fb_info) then
		return
	end

	local today_level = fb_info.today_level or 0
	local cur_layer = FuBenData.Instance:MaxTowerFB() - today_level

	if self.cur_layer ~= cur_layer and self.is_cell_active then
		self:JumpToIndex()
	end
end

function FuBenTowerView:CloseCallBack()
	for _, v in pairs(self.list) do
		v:SetSaodangEffectEnable(false)
	end
	self.is_onekey_saodang = false

	if self.title_obj then
		GameObject.Destroy(self.title_obj)
		self.title_obj = nil
	end
	self.cur_layer = -1

	self.is_cell_active = false
end

function FuBenTowerView:ResetEffect()
	for _, v in pairs(self.list) do
		v:SetSaodangEffectEnable(false)
	end
	self.is_onekey_saodang = false
	self.cur_layer = -1
end

function FuBenTowerView:BtnHelpTip()
	TipsCtrl.Instance:ShowHelpTipView(173)
end

-- 设置每个Cell的大小
function FuBenTowerView:CellSizeDel(data_index)
	if data_index == 0 then
		return TOP_CELL_SIZE
	elseif data_index == 101 then
		return BOTTOM_CELL_SIZE
	end
	return NORMAL_CELL_SIZE
end

function FuBenTowerView:GetNumberOfCells()
	return FuBenData.Instance:MaxTowerFB() + 2
end

function FuBenTowerView:RefreshTowerCell(cell, data_index)
	local tower_view = self.list[cell]
	if tower_view == nil then
		tower_view = TowerListView.New(cell.gameObject)
		self.list[cell] = tower_view
	end
	tower_view:SetIndex(data_index)

	local tower_cfg = FuBenData.Instance:GetTowerFBLevelCfg()
	tower_view:SetData(tower_cfg[data_index], data_index)
	tower_view:ListenClick(BindTool.Bind(self.OnClickChallenge, self))

	if self.is_onekey_saodang and data_index == self.cur_layer + 1 then
		tower_view:SetSaodangEffectEnable(true)
	end
	self.is_cell_active = true
end

function FuBenTowerView:OnClickChallenge()
	if FuBenData.Instance:IsShowTowerFBRedPoint() then
		FuBenCtrl.Instance:SetRedPointCountDown("tower")
		RemindManager.Instance:Fire(RemindName.FuBenSingle)
	end
	FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_PATAFB)
	ViewManager.Instance:Close(ViewName.FuBen)
end

function FuBenTowerView:OnClickOneKey()
	if not FuBenData.Instance:IsShowTowerFBRedPoint() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Dungeon.TowerSaoDangCompelet)
		return
	end
	FuBenCtrl.Instance:SendAutoFBReq(GameEnum.FB_CHECK_TYPE.FBCT_PATAFB)
	self.is_onekey_saodang = true
end

function FuBenTowerView:JumpToIndex()
	if self.list_view and self.list_view.scroller.isActiveAndEnabled then
		local index = FuBenData.Instance:GetTowerFBInfo().pass_level
		index = FuBenData.Instance:MaxTowerFB() - index

		local scrollerOffset = 0
		local cellOffset = -1.7
		local useSpacing = false
		local scrollerTweenType = self.list_view.scroller.snapTweenType
		local scrollerTweenTime = 0
		local scroll_complete = function()
			self.cur_layer = index
		end

		self.list_view.scroller:JumpToDataIndex(
			index, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)
	end
end

function FuBenTowerView:SetTitle(special_level_cfg)
	if not special_level_cfg then
		return
	end

	if self.temp_title_level ~= special_level_cfg.level then
		if self.title_obj then
			GameObject.Destroy(self.title_obj)
			self.title_obj = nil
			self.is_load_tittle = false
		end
	end

	if not self.is_load_tittle and not self.title_obj then
		local bundle, asset = ResPath.GetTitleModel(special_level_cfg.title_id)
		self.is_load_tittle = true

		PrefabPool.Instance:Load(AssetID(bundle, asset), function(prefab)
			if prefab then
				local obj = GameObject.Instantiate(prefab)
				PrefabPool.Instance:Free(prefab)

				local transform = obj.transform
				self.title_obj = obj.gameObject
				self.is_load_tittle = false
			end
		end)

		self.temp_title_level = special_level_cfg.level
	end
end

function FuBenTowerView:SetRightPanelData(tower_cfg, fb_info)
	if tower_cfg then
		self.show_max_tip:SetValue(false)
		self.fight_power_text:SetValue(tower_cfg.capability_show)

		local is_first = fb_info.pass_level == 0 or fb_info.pass_level < fb_info.today_level + 1
		local reward_cfg = tower_cfg.first_reward
		local reward_title = Language.KuaFuFuBen.ShouTong
		local item_index_offset = 1

		if fb_info.pass_level >= FuBenData.Instance:MaxTowerFB() then
			reward_title = Language.KuaFuFuBen.SaoDangReward
			reward_cfg = FuBenData:GetTowerFbSaoDangAllReward()
			item_index_offset = 0
		end

		self.reward_title:SetValue(reward_title)

		local first_cell_count = 0
		for k, v in pairs(reward_cfg) do
			if v and self.first_item_cells[k + item_index_offset] then
				self.first_item_cells[k + item_index_offset]:SetParentActive(true)
				self.first_item_cells[k + item_index_offset]:SetData(v)
				first_cell_count = first_cell_count + 1
			end
		end
		if self.first_item_cells[first_cell_count + 1] and tower_cfg.reward_exp then
			first_cell_count = first_cell_count + 1
			local exp_data = {item_id = FuBenDataExpItemId.ItemId, num = tower_cfg.reward_exp}
			self.first_item_cells[first_cell_count]:SetParentActive(true)
			self.first_item_cells[first_cell_count]:SetData(exp_data)
		end
		for i = first_cell_count + 1, #self.first_item_cells do
			if self.first_item_cells[i] then
				self.first_item_cells[i]:SetParentActive(false)
			end
		end
	else
		self.show_max_tip:SetValue(true)
	end
end

function FuBenTowerView:OnFlush()
	local fb_info = FuBenData.Instance:GetTowerFBInfo()

	if not fb_info or nil == next(fb_info) then
		return
	end
	self.grade_curr:SetValue(fb_info.pass_level)
	self.show_challenge_ben:SetValue(fb_info.pass_level < FuBenData.Instance:MaxTowerFB())
	-- self.show_click_mask:SetValue(self.is_onekey_saodang or false)

	if self.list_view and self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshActiveCellViews()--ReloadData(1)
	end

	local tower_cfg = FuBenData.Instance:GetTowerFBLevelCfg()
	local special_level_cfg = FuBenData.Instance:GetSpecialRewardLevel()

	-- 设置称号
	self:SetTitle(special_level_cfg)

	-- 设置右边面板数据
	self:SetRightPanelData(tower_cfg[fb_info.pass_level + 1], fb_info)

	self.is_max_saodang:SetValue(fb_info.pass_level >= FuBenData.Instance:MaxTowerFB())

	local index = fb_info.today_level + 1
	local max_level = #tower_cfg
	self.chanllge_text:SetValue(fb_info.pass_level == max_level and "已通关" or "挑战" )
	self.chanllge_btn.button.interactable = fb_info.pass_level ~= max_level
	self.show_arrow_image:SetValue(index < fb_info.pass_level)

	-- 跳转到目标层
	if self.is_cell_active then
		self:JumpToIndex()
	end

	local day_reward = FuBenData.Instance:GetTowerReward()
	for i = 1, #day_reward.rewards + 1 do
		self.day_reward_cell[i]:SetData(day_reward.rewards[i - 1])
	end

	self.show_red_point:SetValue(FuBenData.Instance:IsShowTowerFBRedPoint())
end


TowerListView = TowerListView or BaseClass(BaseRender)

function TowerListView:__init(instance)
	self.fight_power = self:FindVariable("FightPower")
	self.is_first = self:FindVariable("ShowFirstContent")
	self.level = self:FindVariable("CurLevel")
	self.show_cur_challenge = self:FindVariable("ShowCurChallenge")
	self.show_top = self:FindVariable("ShowTop")
	self.show_bottom = self:FindVariable("ShowBottom")
	self.show_normal = self:FindVariable("ShowNormal")
	self.show_saodang_effect = self:FindVariable("ShowSaodangEffect")
	self.show_fight_power = self:FindVariable("ShowFightPower")

	self.show_fight_power:SetValue(false)

	self.is_cur_challenge = false
end

function TowerListView:__delete()
end

function TowerListView:SetItemCellData(index, data)
	if not index or not data then return end
	if not self.item_cells[index] then return end
end

function TowerListView:SetFirstItemCellData(index, data)
	if not index or not data then return end
	if not self.first_item_cells[index] then return end
end

function TowerListView:ListenClick(handler)
	self:ClearEvent("OnClickChallenge")
	if not self.is_cur_challenge then return end

	self:ListenEvent("OnClickChallenge", handler)
end

function TowerListView:SetData(data, data_index)
	local is_top = data_index == 0
	local is_bottom = data_index == (FuBenData.Instance:MaxTowerFB() + 1)

	if data and data.level then
		local fb_info = FuBenData.Instance:GetTowerFBInfo()
		local pass_level = fb_info.pass_level or 0
		local today_level = fb_info.today_level or 0
		local level = FuBenData.Instance:MaxTowerFB() - data.level + 1

		self.level:SetValue(level)
		self.is_first:SetValue(level > pass_level)
		self.show_cur_challenge:SetValue((pass_level + 1) == level)
		self.fight_power:SetValue(data.capability)

		self.is_cur_challenge = (pass_level + 1) == level
		-- self.show_fight_power:SetValue(not is_top and not is_bottom and (pass_level + 1) == level)
	else
		-- self.show_fight_power:SetValue(false)
	end
	self.show_normal:SetValue(nil ~= data)
	self.show_top:SetValue(is_top)
	self.show_bottom:SetValue(is_bottom)
end

function TowerListView:GetContents()
	return self.contents
end

function TowerListView:SetIndex(index)
	self.index = index
end

function TowerListView:GetIndex()
	return self.index
end

function TowerListView:SetScale(value)
	-- self.contents.transform.localScale = Vector3(value, value, value)
end

function TowerListView:GetHeight()
	return self.root_node.rect.rect.height
end

function TowerListView:SetSaodangEffectEnable(value)
	self.show_saodang_effect:SetValue(value)
end