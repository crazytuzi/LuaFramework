RuneTowerView = RuneTowerView or BaseClass(BaseRender)

local TOP_CELL_SIZE = 343		-- 塔顶塔格子的大小
local BOTTOM_CELL_SIZE = 209	-- 塔底塔格子的大小
local NORMAL_CELL_SIZE = 192	-- 正常塔格子的大小

function RuneTowerView:__init()
	self.cell_list = {}
	self.cur_layer = -1
	self.is_cell_active = false
	self.is_first_set_offtime = true
	self.old_offline_time = 0

	self:ListenEvent("CloseWindow",BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("ClickEnter",BindTool.Bind(self.OnClickEnter, self))
	self:ListenEvent("ClickAdd",BindTool.Bind(self.OnClickAdd, self))
	self:ListenEvent("ClickHelp",BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("ClickGetOffline",BindTool.Bind(self.OnClickGetOffline, self))
	self:ListenEvent("ClickAuto",BindTool.Bind(self.OnClickAuto, self))

	self.is_onekey_saodang = false
	-- self.list_view = self:FindObj("ListView")
	-- local list_delegate = self.list_view.list_simple_delegate
	-- list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	-- list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshTowerCell, self)
	-- list_delegate.CellSizeDel = BindTool.Bind(self.CellSizeDel, self)

	-- self.list_view.scroller.scrollerScrolled = BindTool.Bind(self.ScrollerScrolledDelegate, self)
	-- self.list_view.scroller.cellViewVisibilityChanged = BindTool.Bind(self.CellViewVisibilityChanged, self)

	-- 	-- 把ScrollRect设置成不能拖动
	-- self.list_view.scroll_rect.horizontal = false
	-- self.list_view.scroll_rect.vertical = false

	-- self.offline_hour = self:FindVariable("OffLineHour")
	-- self.offline_min = self:FindVariable("OffLineMin")
	-- self.offline_sec = self:FindVariable("OffLineSec")
	self.cur_layer_index = self:FindVariable("CurLayer")
	self.extra_layer = self:FindVariable("ExtraLayer")
	self.is_all_finish = self:FindVariable("IsAllFinish")
	self.rec_cap = self:FindVariable("RecCap")
	self.show_red_point = self:FindVariable("ShowRedPoint")
	self.upgrade_btn = self:FindObj("UpgradeBtn")


	self.shake_ani = self:FindObj("Animator").animator
	self.show_had_get_imag = self:FindVariable("ShowHadGetIma")
	self.item_cells = {}
	self.show_reward_list = {}
	self.extra_item = {}
	for i = 1, 3 do
		self.item_cells[i] = ItemCell.New()
		self.item_cells[i]:SetInstanceParent(self:FindObj("Item"..i))
		self.show_reward_list[i] = self:FindVariable("ShowReward" .. i)
	end

	for i=1,2 do
		self.extra_item[i] = ItemCell.New()
		self.extra_item[i]:SetInstanceParent(self:FindObj("ExtraItem" .. i))
	end

	self.auto_btn = self:FindObj("AutoBtn")
	self.can_auto = self:FindVariable("CanAuto")
end

-- function RuneTowerView:GetNumberOfCells()
-- 	return GuaJiTaData.Instance:GetRuneMaxLayer() + 2
-- end

-- function RuneTowerView:RefreshTowerCell(cell, data_index)
-- 	local tower_view = self.cell_list[cell]
-- 	if tower_view == nil then
-- 		tower_view = RuneTowerListView.New(cell.gameObject)
-- 		self.cell_list[cell] = tower_view
-- 	end
-- 	local data = GuaJiTaData.Instance:GetRuneTowerLayerCfgByLayer(data_index)
-- 	tower_view:SetData(data, data_index)
-- 	tower_view:ListenClick(BindTool.Bind(self.OnClickEnter, self))

-- 	if self.is_onekey_saodang and data_index == self.cur_layer + 1 then
-- 		tower_view:SetSaodangEffectEnable(true)
-- 	end

-- 	self.is_cell_active = true
-- end

-- function RuneTowerView:CellSizeDel(data_index)
-- 	if data_index == 0 then
-- 		return TOP_CELL_SIZE
-- 	elseif data_index == (GuaJiTaData.Instance:GetRuneMaxLayer() + 1) then
-- 		return BOTTOM_CELL_SIZE
-- 	end
-- 	return NORMAL_CELL_SIZE
-- end

-- function RuneTowerView:JumpToIndex()
-- 	if self.list_view and self.list_view.scroller.isActiveAndEnabled then
-- 		local jump_index = GuaJiTaData.Instance:GetRuneTowerInfo().fb_today_layer or 0
-- 		jump_index = GuaJiTaData.Instance:GetRuneMaxLayer() - jump_index
-- 		local scrollerOffset = 0
-- 		local cellOffset = -1.7
-- 		local useSpacing = false
-- 		local scrollerTweenType = self.list_view.scroller.snapTweenType
-- 		local scrollerTweenTime = 0
-- 		local scroll_complete = function()
-- 			self.cur_layer = jump_index
-- 		end

-- 		self.list_view.scroller:JumpToDataIndex(
-- 			jump_index, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)
-- 	end
-- end

-- function RuneTowerView:ScrollerScrolledDelegate(go, param1, param2, param3)
-- 	local rune_info = GuaJiTaData.Instance:GetRuneTowerInfo()
-- 	local pass_layer = rune_info.fb_today_layer or 0
-- 	local cur_layer = GuaJiTaData.Instance:GetRuneMaxLayer() - pass_layer
-- 	if self.cur_layer ~= cur_layer and self.is_cell_active then
-- 		self:JumpToIndex()
-- 	end
-- end

-- function RuneTowerView:CellViewVisibilityChanged(obj, param1, param2)
-- end


function RuneTowerView:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self.is_cell_active = false

	for k, v in pairs(self.item_cells) do
		self.show_reward_list[k] = nil
		v:DeleteMe()
	end
	self.item_cells = {}

	for k, v in pairs(self.extra_item) do
		v:DeleteMe()
	end
	self.extra_item = {}

	-- 清理变量和对象
	self.list_view = nil
	-- self.offline_hour = nil
	-- self.offline_min = nil
	-- self.offline_sec = nil
	self.cur_layer_index = nil
	self.extra_layer = nil
	self.auto_btn = nil
	self.can_auto = nil
	self.shake_ani = nil
	self.show_had_get_imag = nil
	self.is_all_finish = nil
	self.rec_cap = nil
	self.show_red_point = nil
end

function RuneTowerView:InitView()
	self:FlushView()
end

function RuneTowerView:CloseCallBack()
	self.cur_layer = -1
	self.is_first_set_offtime = true

	if self.animtion_timer_quest then
		GlobalTimerQuest:CancelQuest(self.animtion_timer_quest)
		self.animtion_timer_quest = nil
	end
	self.is_cell_active = false
	self.is_onekey_saodang = false
	for _, v in pairs(self.cell_list) do
		v:SetSaodangEffectEnable(false)
	end
end

-- 领取离线时间
function RuneTowerView:OnClickGetOffline()
	local rune_info = GuaJiTaData.Instance:GetRuneTowerInfo()
	local fetch_count = rune_info.fetch_time_count or 999
	if fetch_count >= 1 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Rune.FetchOfflineTimeLimit)
		return
	end
	GuaJiTaCtrl.Instance:SendGetRuneTowerFetchBuff()
end

function RuneTowerView:OnClickClose()
	if ViewManager.Instance:IsOpen(ViewName.TipWarmView) then
		ViewManager.Instance:Close(ViewName.TipWarmView)
	end
	self:Close()
end

-- 点击 加号
function RuneTowerView:OnClickAdd()
	local other_cfg = GuaJiTaData.Instance:GetRuneOtherCfg()
	local rune_info = GuaJiTaData.Instance:GetRuneTowerInfo()

	local can_use = true
	if next(other_cfg) and next(rune_info) and other_cfg.offline_time_max <= rune_info.offline_time then
		can_use = false
	end

	if ItemData.Instance:GetItemNumInBagById(GUAJI_TA_TIME_CARD_ITEM_ID) > 0 then
		local data = ItemData.Instance:GetItem(GUAJI_TA_TIME_CARD_ITEM_ID) or {}
		if next(data) then
			if not can_use then
				TipsCtrl.Instance:ShowSystemMsg(Language.Rune.OfflineLimit)
			else
				PackageCtrl.Instance:SendUseItem(data.index, 1, 0, 0)
			end
		end
	else
		local callback = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
			local use_flag = can_use and 1 or 0
			if not can_use then
				TipsCtrl.Instance:ShowSystemMsg(Language.Rune.OfflineLimit)
			end
			MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, use_flag)
		end
		TipsCtrl.Instance:ShowCommonBuyView(callback, GUAJI_TA_TIME_CARD_ITEM_ID, nil, 1)
	end
end

-- 进入挂机塔
function RuneTowerView:OnClickEnter()
	FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_GUAJI_TA)
	ViewManager.Instance:CloseAll()
end

-- 扫荡
function RuneTowerView:OnClickAuto()
	GuaJiTaCtrl.Instance:SendRuneTowerAuto()
	self.is_onekey_saodang = true
end

function RuneTowerView:OnClickHelp()
	local tip_id = 161
	TipsCtrl.Instance:ShowHelpTipView(tip_id)
end

-- -- 设置领取离线时间按钮动画
-- function RuneTowerView:PlayButtonShakeAnimation(fetch_time_count)
-- 	if nil == self.shake_ani then
-- 		return
-- 	end
-- 	if fetch_time_count <= 0 then
-- 		self.shake_ani:SetBool("Shake", true)
-- 	else
-- 		self.shake_ani:SetBool("Shake", false)
-- 	end
-- end

-- -- 设置离线时间
-- function RuneTowerView:SetOffLineTime(offline_time)
-- 	if not offline_time then return end

-- 	local left_hour = math.floor(offline_time / 3600)
-- 	local left_min = math.floor((offline_time - left_hour * 3600) / 60)
-- 	local left_sec = math.floor(offline_time - left_hour * 3600 - left_min * 60)

-- 	if (offline_time - self.old_offline_time > 0) and not self.is_first_set_offtime then

-- 		local old_time = self.old_offline_time
-- 		local animtion_time = 1

-- 		if not self.animtion_timer_quest then
-- 			self.animtion_timer_quest = GlobalTimerQuest:AddRunQuest(function()
-- 				animtion_time = animtion_time - 0.085

-- 				-- self.offline_hour:SetValue(math.random(0, 28))
-- 				-- self.offline_min:SetValue(math.random(0, 59))
-- 				-- self.offline_sec:SetValue(math.random(0, 59))
-- 				if animtion_time <= 0 then
-- 					if self.animtion_timer_quest then
-- 						GlobalTimerQuest:CancelQuest(self.animtion_timer_quest)
-- 						self.animtion_timer_quest = nil
-- 					end
-- 					-- self.offline_hour:SetValue(left_hour)
-- 					-- self.offline_min:SetValue(left_min)
-- 					-- self.offline_sec:SetValue(left_sec)

-- 					self.old_offline_time = offline_time
-- 				end
-- 			end, 0.085)
-- 		end
-- 	else
-- 		-- self.offline_hour:SetValue(left_hour)
-- 		-- self.offline_min:SetValue(left_min)
-- 		-- self.offline_sec:SetValue(left_sec)
-- 		self.old_offline_time = offline_time
-- 	end

-- 	self.is_first_set_offtime = false
-- end

function RuneTowerView:FlushView()
	local rune_info = GuaJiTaData.Instance:GetRuneTowerInfo()
	local pass_layer = rune_info.pass_layer or 0

	self.show_had_get_imag:SetValue(rune_info.fetch_time_count > 0)

	-- 领取离线时间按钮动画
	-- self:PlayButtonShakeAnimation(rune_info.fetch_time_count)

	-- 离线时间
	-- self:SetOffLineTime(rune_info.offline_time)
	-- if self.list_view and self.list_view.scroller.isActiveAndEnabled then
	-- 	self.list_view.scroller:RefreshActiveCellViews()
	-- end

	-- -- 跳转到目标层
	-- if self.is_cell_active then
	-- 	self:JumpToIndex()
	-- end
	self.is_all_finish:SetValue(pass_layer == GuaJiTaData.Instance:GetRuneMaxLayer())
	if pass_layer == GuaJiTaData.Instance:GetRuneMaxLayer() then
		self.upgrade_btn.grayscale.GrayScale = 255
	else
		self.upgrade_btn.grayscale.GrayScale = 0
	end

	if (pass_layer + 1) >= GuaJiTaData.Instance:GetRuneMaxLayer() then
		pass_layer = GuaJiTaData.Instance:GetRuneMaxLayer() - 1
	end
	self.cur_layer_index:SetValue(pass_layer + 1)
	local cur_cfg = GuaJiTaData.Instance:GetRuneTowerLayerCfgByLayer(pass_layer + 1)
	local fuben_cfg = GuaJiTaData.Instance:GetRuneTowerFBLevelCfg()
	local reward_cfg = fuben_cfg[pass_layer + 1].first_reward_item
	local capability = fuben_cfg[pass_layer + 1].capability or 0
	self.rec_cap:SetValue(capability)
	for i = 2, 3 do
		self.show_reward_list[i]:SetValue(false)
		self.item_cells[i]:SetActive(false)
		if reward_cfg[i - 2] then
			self.show_reward_list[i]:SetValue(true)
			self.item_cells[i]:SetActive(true)
			self.item_cells[i]:SetData(reward_cfg[i - 2])
		end
	end
	self.show_reward_list[1]:SetValue(true)
	self.item_cells[1]:SetActive(true)
	self.item_cells[1]:SetData({item_id = ResPath.CurrencyToIconId.rune_jinghua, num = fuben_cfg[pass_layer + 1].first_reward_rune_exp, is_bind = 1})

	local special_level_cfg = GuaJiTaData.Instance:GetSpecialRewardLevel()
	if special_level_cfg and next(special_level_cfg) ~= nil then
		local spe_reward_cfg = fuben_cfg[special_level_cfg.fb_layer].first_reward_item
		for i=1, 2 do
			if special_level_cfg and spe_reward_cfg then
				self.extra_layer:SetValue(special_level_cfg.fb_layer)
				self.extra_item[i]:SetData(spe_reward_cfg[i -1])
			end
		end
	end

	if rune_info.pass_layer == rune_info.fb_today_layer then
		self.can_auto:SetValue(false)
	else
		self.can_auto:SetValue(true)
	end
	self.auto_btn.grayscale.GrayScale = rune_info.pass_layer == rune_info.fb_today_layer and 255 or 0

	-- local is_show_point = GuaJiTaData.Instance:IsShowRedPoint()
	self.show_red_point:SetValue(pass_layer == GuaJiTaData.Instance:GetRuneMaxLayer())
end

-- -- 符文塔格子
-- RuneTowerListView = RuneTowerListView or BaseClass(BaseRender)

-- function RuneTowerListView:__init(instance)
-- 	self.is_first = self:FindVariable("ShowFirstContent")
-- 	self.level = self:FindVariable("CurLevel")
-- 	self.fight_power = self:FindVariable("FightPower")

-- 	self.show_cur_challenge = self:FindVariable("ShowCurChallenge")
-- 	self.show_top = self:FindVariable("ShowTop")
-- 	self.show_bottom = self:FindVariable("ShowBottom")
-- 	self.show_normal = self:FindVariable("ShowNormal")
-- 	self.show_saodang_effect = self:FindVariable("ShowSaodangEffect")
-- 	self.show_fight_power = self:FindVariable("ShowFightPower")

-- 	self.is_cur_challenge = false
-- end

-- function RuneTowerListView:__delete()
-- end

-- function RuneTowerListView:SetData(data, data_index)
-- 	local is_top = data_index == 0
-- 	local is_bottom = data_index == (GuaJiTaData.Instance:GetRuneMaxLayer() + 1)

-- 	if data.fb_layer then
-- 		local pass_layer = GuaJiTaData.Instance:GetRuneTowerInfo().fb_today_layer or 0
-- 		local level = GuaJiTaData.Instance:GetRuneMaxLayer() - data.fb_layer + 1
-- 		local temp_data = GuaJiTaData.Instance:GetRuneTowerLayerCfgByLayer(level)

-- 		self.level:SetValue(level)
-- 		self.is_first:SetValue(level > pass_layer)
-- 		self.show_cur_challenge:SetValue((pass_layer + 1) == level)
-- 		self.fight_power:SetValue(temp_data.capability)
-- 		self.show_fight_power:SetValue(not is_top and not is_bottom and (pass_layer + 1) == level)
-- 		self.is_cur_challenge = (pass_layer + 1) == level
-- 	end
-- 	self.show_normal:SetValue(nil ~= data.fb_layer)
-- 	self.show_top:SetValue(is_top)
-- 	self.show_bottom:SetValue(is_bottom)

-- end

-- function RuneTowerListView:ListenClick(handler)
-- 	self:ClearEvent("OnClickChallenge")
-- 	if not self.is_cur_challenge then return end

-- 	self:ListenEvent("OnClickChallenge", handler)
-- end

-- function RuneTowerListView:GetContents()
-- 	return self.contents
-- end

-- function RuneTowerListView:SetIndex(index)
-- 	self.index = index
-- end

-- function RuneTowerListView:GetIndex()
-- 	return self.index
-- end

-- function RuneTowerListView:GetHeight()
-- 	return self.root_node.rect.rect.height
-- end

-- function RuneTowerListView:SetSaodangEffectEnable(value)
-- 	self.show_saodang_effect:SetValue(value)
-- end