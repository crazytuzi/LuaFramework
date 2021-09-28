--爬塔
FuBenTowerView = FuBenTowerView or BaseClass(BaseRender)

local TOP_CELL_SIZE = 0
local BOTTOM_CELL_SIZE = 0
local NORMAL_CELL_SIZE = 100
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
	self:ListenEvent("zhuanpanclick",
		BindTool.Bind(self.ZhuanPanClick, self))
	self:ListenEvent("OpenTowerMoJieView",
		BindTool.Bind(self.OpenTowerMoJieView, self))

	self.saodang_btn_text = self:FindVariable("SaodangBtnText")
	self.fight_power_text = self:FindVariable("FightPower")
	self.title_level = self:FindVariable("TitleLevel")
	self.reward_title = self:FindVariable("RewardTitle")

	self.show_challenge_ben = self:FindVariable("ShowChallegeBtn")
	self.show_arrow_image = self:FindVariable("ShowArrowIma")
	self.show_click_mask = self:FindVariable("ShowClickMask")
	self.show_max_tip = self:FindVariable("ShowMaxLevel")
	self.is_max_saodang = self:FindVariable("MaxSaodang")

	self.isclick = false
	self.saodang_btn = self:FindObj("SaodangBtn")
	self.title_root = self:FindObj("TitleRoot")
	self.CanSaoDang = self:FindVariable("CanSaoDang")

	self.title_get_func_des = self:FindVariable("TitleGetFuncDes")	
	self.mojie_icon = self:FindVariable("MojieIcon") 							--魔戒Icon
	self.tower_mojie_skill_des = self:FindVariable("TowerMojieSkillDes") 		--魔戒技能描述
	self.mojie_next_reward_floor = self:FindVariable("MojieNextRewardFloor") 	--下一个魔戒获得层数
	self.show_mojie = self:FindVariable("ShowMojie") 							--展示魔戒还是展示特殊层数奖励物品
	self.mojie_name = self:FindVariable("MoJieName") 							--魔戒名称
	self.lingpai_next_reward_floor = self:FindVariable("LingPaiNextRewardFloor")	--下一个令牌奖励获得层数
	self.special_item = ItemCell.New()
	self.special_item:SetInstanceParent(self:FindObj("SpecialItem"))
 
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

	for k, v in pairs(self.list) do
		if v then
			v:DeleteMe()
		end
	end
	self.list = {}
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

	if self.special_item then
		self.special_item:DeleteMe()
	end
	self.special_item = nil

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
	local fb_info = FuBenData.Instance:GetTowerFBInfo()
	local pass_index = fb_info.pass_level or 0
	pass_index = FuBenData.Instance:MaxTowerFB() - pass_index
	tower_view:SetData(tower_cfg[data_index], data_index)
	tower_view:ListenClick(BindTool.Bind(self.OnClickChallenge, self))
	tower_view:HideEffect()

	if self.is_onekey_saodang
		and data_index == self.cur_layer + 1
		and pass_index + 1 == data_index then

		tower_view:SetSaodangEffectEnable(true)
		self.is_onekey_saodang = false
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
	self.isclick = true
	self.is_onekey_saodang = true
	FuBenCtrl.Instance:SendAutoFBReq(GameEnum.FB_CHECK_TYPE.FBCT_PATAFB)
end

function FuBenTowerView:JumpToIndex()
	if self.list_view and self.list_view.scroller.isActiveAndEnabled then
		local index = FuBenData.Instance:GetTowerFBInfo().today_level
		if index <= 1 then
			index = 1
		end	
		index = FuBenData.Instance:MaxTowerFB() - index

		local scrollerOffset = 0
		local cellOffset = -2.3
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
	self.title_level:SetValue(special_level_cfg.level)

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
				transform:SetParent(self.title_root.transform, false)
				self.title_obj = obj.gameObject
				self.is_load_tittle = false
			end
		end)

		self.temp_title_level = special_level_cfg.level
	end
end

--设置特殊层数奖励
function FuBenTowerView:SetSpecialItem(cfg)
	if not cfg or not self.special_item then return end
	self.special_item:SetData(cfg.show_item_list[0])
	self.lingpai_next_reward_floor:SetValue(cfg.level)
end


--设置爬塔魔戒信息
function FuBenTowerView:SetMojie(cfg)
	if not cfg then return end
	--魔戒获得层数
	self.mojie_next_reward_floor:SetValue(cfg.pata_layer)
	--魔戒名称
	self.mojie_name:SetValue(cfg.mojie_name)
	--技能描述
	local skill_param = FuBenData.Instance:GetSkillParamById(cfg.skill_id)
	local skill_des = string.format(Language.FubenTower.TowerMoJieSkillDes_2[cfg.skill_id + 1], skill_param[1], skill_param[2], skill_param[3], skill_param[4])
	self.tower_mojie_skill_des:SetValue(skill_des)
	--魔戒Icon
    local bundle, asset = ResPath.GetTowerMojieIcon(cfg.skill_id + 1)
    self.mojie_icon:SetAsset(bundle, asset)
end

function FuBenTowerView:OpenTowerMoJieView()
	ViewManager.Instance:Open(ViewName.TowerMoJieView)
end

function FuBenTowerView:SetRightPanelData(tower_cfg, fb_info)
	local capability = GameVoManager.Instance:GetMainRoleVo().capability
	if tower_cfg then
		self.show_max_tip:SetValue(false)
		-- local power_str = capability < tower_cfg.capability and string.format(Language.Mount.ShowRedNum, tower_cfg.capability)
		-- 		or string.format(Language.Mount.ShowGreenNum, tower_cfg.capability)
		self.fight_power_text:SetValue(tower_cfg.capability)

		local is_first = fb_info.pass_level == 0 or fb_info.pass_level < fb_info.today_level + 1
		local reward_cfg = is_first and tower_cfg.first_reward or tower_cfg.normal_reward
		local reward_title = is_first and Language.KuaFuFuBen.ShouTong or Language.KuaFuFuBen.TongGuan
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
		for i = first_cell_count + 1, #self.first_item_cells do
			if self.first_item_cells[i] then
				self.first_item_cells[i]:SetParentActive(false)
			end
		end
		self.is_max_saodang:SetValue(fb_info.pass_level >= FuBenData.Instance:MaxTowerFB())
	else
		self.show_max_tip:SetValue(true)
	end
end

function FuBenTowerView:Flush()
	local fb_info = FuBenData.Instance:GetTowerFBInfo()

	if not fb_info or nil == next(fb_info) then
		return
	end

	self.show_challenge_ben:SetValue(fb_info.pass_level < FuBenData.Instance:MaxTowerFB())
	-- self.show_click_mask:SetValue(self.is_onekey_saodang or false)

	if self.list_view and self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshActiveCellViews()--ReloadData(1)
	end

	local tower_cfg = FuBenData.Instance:GetTowerFBLevelCfg()

	-- 设置称号
	--local special_level_cfg = FuBenData.Instance:GetSpecialRewardLevel()
	--self:SetTitle(special_level_cfg)

	-- 设置特殊奖励（令牌）
	local special_reward_cfg = FuBenData.Instance:GetSpecialRewardItemCfg()
	if special_reward_cfg then
		self:SetSpecialItem(special_reward_cfg)
	end

	--设置魔戒
	local next_reward_mojie_cfg = FuBenData.Instance:GetNextRewardTowerMojieCfg()
	if next_reward_mojie_cfg then
		self:SetMojie(next_reward_mojie_cfg)
	end

	--比较将会先获得令牌还是先获得魔戒
	if special_reward_cfg and next_reward_mojie_cfg then
		self.show_mojie:SetValue(next_reward_mojie_cfg.pata_layer <= special_reward_cfg.level)
	elseif special_reward_cfg then
		self.show_mojie:SetValue(false)
	elseif next_reward_mojie_cfg then
		self.show_mojie:SetValue(true)
	end

	-- 设置右边面板数据
	self:SetRightPanelData(tower_cfg[fb_info.today_level + 1], fb_info)

	local index = fb_info.today_level
	if index == 0 then
		self.isclick = false
	end

	if not self.isclick then
		self.saodang_btn_text:SetValue(Language.Common.OneKeySaoDang)
	else
		self.saodang_btn_text:SetValue(Language.Common.HadSaoDang)
	end

--	self.saodang_btn_text:SetValue((index >= fb_info.pass_level and fb_info.pass_level > 0)	and Language.Common.HadSaoDang or Language.Common.OneKeySaoDang)
	local flag = index < fb_info.pass_level
	self.CanSaoDang:SetValue(flag)
	self.show_arrow_image:SetValue(index < fb_info.pass_level)

	-- 跳转到目标层
	if self.is_cell_active then
		self:JumpToIndex()
	end
end

function FuBenTowerView:ZhuanPanClick()
	ViewManager.Instance:Open(ViewName.Welfare, TabIndex.welfare_goldturn)
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
	self.show_arrow = self:FindVariable("ShowArrow")
	self.first_reward = self:FindObj("FirstReward")
	self.reward_cell = ItemCell.New()
	self.reward_cell:SetInstanceParent(self.first_reward)
	
	self.show_fight_power:SetValue(false)

	self.is_cur_challenge = false
	self.is_active_effect = false
end

function TowerListView:__delete()
	if self.reward_cell then
		self.reward_cell:DeleteMe()
		self.reward_cell = nil
	end
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
	-- self.power_str = 0
	-- if data.level then
	-- 	self.level:SetValue(data.level)
	-- 	self.is_first:SetValue(data.is_first)
	-- 	-- local index = FuBenData.Instance:GetTowerFBInfo().pass_level
	-- 	self.show_cur_challenge:SetValue(index == (data.level - 1))
	-- 	self.show_fight_power:SetValue(not data.show_top and not data.show_bottom and (data.level + 1) == level)
	-- end
	-- self.show_normal:SetValue(data.show_normal)
	-- self.show_top:SetValue(data.show_top)
	-- self.show_bottom:SetValue(data.show_bottom)
	local tower_cfg = FuBenData.Instance:GetTowerFBLevelCfg()
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
		local capability = GameVoManager.Instance:GetMainRoleVo().capability
		local cap_str = tower_cfg[level].capability
		if capability and tower_cfg[level].capability > capability then
			cap_str = ToColorStr(cap_str, TEXT_COLOR.RED)
		end
		self.fight_power:SetValue(cap_str)
		self.show_arrow:SetValue(today_level == level - 1)
		self.is_cur_challenge = (pass_level + 1) == level
		-- self.show_fight_power:SetValue(not is_top and not is_bottom and (pass_level + 1) == level)

		local reward_data = tower_cfg[level].first_reward[0]
		if reward_data and self.first_reward then
			self.reward_cell:SetData(reward_data)
		end
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

function TowerListView:HideEffect()
	if self.is_active_effect then
		self.show_saodang_effect:SetValue(false)
	end
end

function TowerListView:SetSaodangEffectEnable(value)
	self.show_saodang_effect:SetValue(value)
	self.is_active_effect = value
end