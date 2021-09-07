require("game/beauty/beauty_item")
BeautyPrayView = BeautyPrayView or BaseClass(BaseRender)
local ROW = 3
local LOW = 5
local MAX_NUM = 15
local ONE_PUMPING = 2 --单次抽奖
local TEN_PUMPING = 3 --10次抽奖
function BeautyPrayView:__init(instance)
	self.depot_list = {}
	self.model_list = {}
	self.display_list = {}
	self.is_buy_quick = false
end

function BeautyPrayView:__delete()
	if self.reward_cell_list then
		for k,v in pairs(self.reward_cell_list) do
			v:DeleteMe()
		end
		self.reward_cell_list = {}
	end
	if self.depot_list then
		for k,v in pairs(self.depot_list) do
			v:DeleteMe()
		end
		self.depot_list = {}
	end

	if self.model_list then
		for k,v in pairs(self.model_list) do
			v:DeleteMe()
		end
		self.model_list = {}
	end

	self.show_depot_red = nil

	local other_cfg = BeautyData.Instance:GetBeautyOther()
	if other_cfg and TipsCommonBuyView.AUTO_LIST[other_cfg.draw_1_item_id] then
		TipsCommonBuyView.AUTO_LIST[other_cfg.draw_1_item_id] = nil
	end
end

function BeautyPrayView:LoadCallBack(instance)
	self:ListenEvent("OnOnceBtn", BindTool.Bind(self.OnPumpingBtnHandle, self, ONE_PUMPING))
	self:ListenEvent("OnTenBtn", BindTool.Bind(self.OnPumpingBtnHandle, self, TEN_PUMPING))
	self:ListenEvent("OnOpenRewardTips", BindTool.Bind(self.OnOpenRewardTipsHandle, self))
	self:ListenEvent("OnOpenYouhui", BindTool.Bind(self.OnOpenYouhui, self))
	self:ListenEvent("OnClickDescTips", BindTool.Bind(self.OnClickDescTips, self))
	self:ListenEvent("OnClicDrawReward", BindTool.Bind(self.OnClickDrawReward, self))

	self:ListenEvent("OnOpenDepot", BindTool.Bind(self.OnOpenDepotHandle, self))
	self:ListenEvent("OnDepotBg", BindTool.Bind(self.OnCloseHandle, self))
	self:ListenEvent("OnCloseDepot", BindTool.Bind(self.OnCloseHandle, self))
	self:ListenEvent("OnCloseRewardTips", BindTool.Bind(self.OnCloseRewardTips, self))

	self:ListenEvent("OnekeyTakeOut", BindTool.Bind(self.OnekeyTakeOutHandle, self))

	self.show_depot = self:FindVariable("ShowDepot")
	self.show_reward_tips = self:FindVariable("ShowRewardTips")
	self.free_text = self:FindVariable("FreeText")
	self.ten_text = self:FindVariable("TenText")
	self.draw_reward_text = self:FindVariable("DrawRewardText")
	self.item_count = self:FindVariable("ItemCount")
	self.page_toggle_1 = self:FindObj("page_toggle_1")

	self.show_youhui_red = self:FindVariable("ShowYouHuiRed")
	self.show_one_red = self:FindVariable("ShowOneRed")
	self.show_ten_red = self:FindVariable("ShowTenRed")
	self.show_roll_reward_red = self:FindVariable("ShowRollRewardRed")
	self.show_depot_red = self:FindVariable("DepotRedPoint")

	self.reward_obj = self:FindObj("RewardObj")

	self.reward_cell_list = {}
	--self.reward_list_data = BeautyData.Instance:GetBeautyDrawCfg()
	self.reward_list_view = self:FindObj("RewardTipsList")
	local reward_list_delegate = self.reward_list_view.list_simple_delegate

	reward_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberRewardCells, self)
	reward_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshRewardCell, self)

	for i = 1, 3 do
		self.display_list[i] = self:FindObj("Display" .. i)
	end

	self:InitListView()
	self:InitModel()
end

-- 初始化模型处理函数
function BeautyPrayView:InitModel()
	local draw_show = BeautyData.Instance:GetBeautyDrawShow()
	if draw_show then
		for i = 1, 3 do
			if not self.model_list[i] then
				self.model_list[i] = RoleModel.New("beauty_panel")
				self.model_list[i]:SetDisplay(self.display_list[i].ui3d_display)
				local bundle, asset = ResPath.GetGoddessNotLModel(draw_show[i].model)
				self.model_list[i]:SetMainAsset(bundle, asset)
				self.model_list[i].draw_obj:GetPart(SceneObjPart.Main):EnableEffect(false)
			end
		end
	end
	
end

function BeautyPrayView:GetNumberRewardCells()
	return MAX_NUM / ROW
end

function BeautyPrayView:RefreshRewardCell(cell, cell_index)
	local reward_cell = self.reward_cell_list[cell]
	if reward_cell == nil then
		reward_cell = PrayRewardCellItem.New(cell.gameObject,self)
		self.reward_cell_list[cell] = reward_cell
	end
	cell_index = cell_index + 1
	local cell_index_list = {}
	cell_index_list = PetData.Instance:GetCellIndexList(cell_index)
	reward_cell:SetGridIndex(cell_index_list)
	reward_cell:SetToggleGroup(self.reward_list_view.toggle_group)

end

function BeautyPrayView:InitListView()
	self.list_view = self:FindObj("DepotList")
	
	local list_delegate = self.list_view.list_simple_delegate
	--生成数量
	list_delegate.NumberOfCellsDel = function()
		return BEAUTY_ALL_ROW
	end
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function BeautyPrayView:OnFlush(param_list)
	self:FlushItemCount()
	self:ReloadData()
	self:FlushRed()
	--self:CheckIsCanGet()
end

function BeautyPrayView:FlushItemCount()
	local other_cfg = BeautyData.Instance:GetBeautyOther()
	if other_cfg then
		self.item_count:SetValue(ItemData.Instance:GetItemNumInBagById(other_cfg.draw_1_item_id))

		local stuff_num = ItemData.Instance:GetItemNumInBagById(other_cfg.draw_1_item_id)
		self.free_text:SetValue(BeautyData:GetStuffNumStr(stuff_num, other_cfg.draw_1_item_num))
		self.ten_text:SetValue(BeautyData:GetStuffNumStr(stuff_num, other_cfg.draw_10_item_num))

		
		local other_cfg = BeautyData.Instance:GetBeautyOther()
		if other_cfg then
			self.draw_reward_text:SetValue(string.format(Language.Beaut.DrawRewardNum, BeautyData.Instance:GetStuffNumStr(BeautyData.Instance:GetDrawCount(), other_cfg.phase_reward_need_draw_times)))
		end
	end
end

function BeautyPrayView:ReloadData()
	GlobalTimerQuest:AddDelayTimer(function()
		local page = self.list_view.list_page_scroll:GetNowPage()
		if page < 1 then
			self.list_view.scroller:ReloadData(0)
		else
			self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
		end
	end, 0)
end

function BeautyPrayView:OnOpenRewardTipsHandle()
	self.show_reward_tips:SetValue(true)
end

function BeautyPrayView:OnCloseRewardTips()
	self.show_reward_tips:SetValue(false)
end

function BeautyPrayView:OnPumpingBtnHandle(index)
	local index = index
	local other_cfg = BeautyData.Instance:GetBeautyOther()
	if other_cfg then
		local draw_num = index == ONE_PUMPING and other_cfg.draw_1_item_num or other_cfg.draw_10_item_num
		local item_num = ItemData.Instance:GetItemNumInBagById(other_cfg.draw_1_item_id)
		if item_num < draw_num and not self.is_buy_quick then
		-- 物品不足，弹出TIP框
			local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[other_cfg.draw_1_item_id]
			if item_cfg == nil then
				TipsCtrl.Instance:ShowSystemMsg(Language.Beaut.NoPumpingTips)
				return
			end
			local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
				local item_cfg = ItemData.Instance:GetItemConfig(item_id)
				local is_limlit = item_cfg ~= nil and item_cfg.buy_limit or 0
				MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use, is_limlit)
				self.is_buy_quick = is_buy_quick
			end
			TipsCtrl.Instance:ShowCommonBuyView(func, other_cfg.draw_1_item_id, nil, (draw_num - item_num))
			return
		end
	end
	local auto_buy = self.is_buy_quick and 1 or 0
	BeautyCtrl.Instance:SendBeautyCommonReq(BEAUTY_COMMON_REQ_TYPE.BEAUTY_COMMON_REQ_TYPE_DRAW, index, auto_buy)
end

function BeautyPrayView:OnekeyTakeOutHandle()
	TreasureCtrl.Instance:SendQuchuItemReq(0, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP, 1)
end

function BeautyPrayView:GetNumberOfCells()
	return BEAUTY_ALL_ROW
end

function BeautyPrayView:RefreshCell(cell, cell_index)
	cell_index = cell_index + 1

	local depot_cell = self.depot_list[cell]
	if depot_cell == nil then
		depot_cell = PrayDepotCellItem.New(cell.gameObject, self)
		self.depot_list[cell] = depot_cell
		depot_cell:SetToggleGroup(self.list_view.toggle_group)
	end
	local cell_index_list = {}
	cell_index_list = BeautyData.Instance:GetCellIndexList(cell_index)
	depot_cell:SetGridIndex(cell_index_list)
end

function BeautyPrayView:OnOpenDepotHandle()
	self.show_depot:SetValue(true)
end

function BeautyPrayView:OnCloseHandle()
	self.show_depot:SetValue(false)
end

function BeautyPrayView:OnOpenYouhui()
	ViewManager.Instance:Open(ViewName.BeautyTryst)
end

function BeautyPrayView:OnClickDescTips()
	TipsCtrl.Instance:ShowHelpTipView(195)
end

function BeautyPrayView:OnClickDrawReward()
	local other_cfg = BeautyData.Instance:GetBeautyOther()
	if other_cfg then
		local cur = BeautyData.Instance:GetDrawCount()
		local need = other_cfg.phase_reward_need_draw_times
		if cur < need then
			TipsCtrl.Instance:OpenItem(other_cfg.draw_phase_reward or 0)
			return
		end
	end

	BeautyCtrl.Instance:SendBeautyCommonReq(BEAUTY_COMMON_REQ_TYPE.BEAUTY_COMMON_REQ_TYPE_DRQW_REWARD)
end

function BeautyPrayView:FlushRed()
	if self.show_youhui_red ~= nil then
		self.show_youhui_red:SetValue(BeautyData.Instance:GetIsCanYouHui())
	end

	if self.show_one_red ~= nil then
		self.show_one_red:SetValue(BeautyData.Instance:GetIsCanRoll(false))
	end

	if self.show_ten_red ~= nil then
		self.show_ten_red:SetValue(BeautyData.Instance:GetIsCanRoll(true))
	end

	if self.show_roll_reward_red ~= nil then
		self.show_roll_reward_red:SetValue(BeautyData.Instance:GetIsCanGetRollReward())
	end

	if self.show_depot_red ~= nil then
		local count = TreasureData.Instance:GetChestCount() or 0
		self.show_depot_red:SetValue(count > 0)
	end
end

function BeautyPrayView:CheckIsCanGet()
	if self.reward_obj ~= nil then
		local animator = self.reward_obj:GetComponent(typeof(UnityEngine.Animator))
		if animator ~= nil then
			local enabled = BeautyData.Instance:GetIsCanGetRollReward()
			animator.enabled = enabled
			if not enabled then
				self.reward_obj.transform.localRotation = Quaternion.Euler(0, 0, 0)
			end
		end
	end
end