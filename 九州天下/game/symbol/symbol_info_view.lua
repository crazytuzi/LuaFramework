-- 喂养界面
SymbolInfoView = SymbolInfoView or BaseClass(BaseRender)

function SymbolInfoView:__init()
	self.cur_food_index = 1
	self.cur_act = false
	self.model_res = 0
	-- 监听UI事件
	self:ListenEvent("OnClickAutoFeed",
		BindTool.Bind(self.OnClickAutoFeed, self))
	self:ListenEvent("OnClickAccelerate",
		BindTool.Bind(self.OnClickAccelerate, self))
	self:ListenEvent("OnClickChange",
		BindTool.Bind(self.OnClickChange, self))
	self:ListenEvent("OnClickActive",
		BindTool.Bind(self.OnClickActive, self))
	self:ListenEvent("OnClickFeed",
		BindTool.Bind(self.OnClickFeed, self))
	self:ListenEvent("OnClickReward",
		BindTool.Bind(self.OnClickReward, self))
	self:ListenEvent("OnClickHelp",
		BindTool.Bind(self.OnClickHelp, self))

	-- 获取变量
	self.level = self:FindVariable("Level")
	self.name = self:FindVariable("Name")
	self.prop = self:FindVariable("Prog")
	self.prop_txt = self:FindVariable("ProgTxt")
	self.cap = self:FindVariable("Cap")
	self.can_reward = self:FindVariable("CanReward")
	self.reward_time = self:FindVariable("RewardTime")
	self.active_limit = self:FindVariable("ActiveLimit")
	self.is_active = self:FindVariable("IsActive")
	self.feed_tip = self:FindVariable("FeedTip")
	self.element = self:FindVariable("Element")
	self.feed_tip:SetValue(Language.Symbol.FeedTips)

	self.reward_btn_ani = self:FindObj("Rewardbtn").animator

	self.display = self:FindObj("Display")
	self.cell_list = {}
	self.food_list = {}
	self.left_select = 0
	self:InitLeftScroller()
	self:InitMidScroller()
	self:InitRightScroller()
end

function SymbolInfoView:__delete()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
	end
	self.cell_list = {}
	if self.food_list then
		for k,v in pairs(self.food_list) do
			v:DeleteMe()
		end
	end
	self.food_list = {}
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

function SymbolInfoView:FlushModel(info)
	if info and info.element_level > 0 then
		if nil == self.model then
			self.model = RoleModel.New("symbol_panel")
			self.model:SetDisplay(self.display.ui3d_display)
			self.model:SetModelScale(Vector3(1.3, 1.3, 1.3))
		end
		local model_res = SymbolData.Instance:GetModelResIdByElementId(info.wuxing_type)
		if self.model_res ~= model_res then
			self.model_res = model_res
			local asset, bundle = ResPath.GetWuXinZhiLingModel(model_res)
			self.model:SetMainAsset(asset, bundle)
		end
	elseif self.model then
		self.model_res = 0
		self.model:ClearModel()
	end
end

function SymbolInfoView:InitLeftScroller()
	self.left_scroller = self:FindObj("LeftList")
	local delegate = self.left_scroller.list_simple_delegate
	-- 生成数量
	self.left_data = SymbolData.Instance:GetElementHeartOpencCfg()
	delegate.NumberOfCellsDel = function()
		return #self.left_data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index
		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			self.cell_list[cell] = YuanshuLeftCell.New(cell.gameObject)
			target_cell = self.cell_list[cell]
			target_cell:SetToggleGroup(self.left_scroller.toggle_group)
		end
		target_cell:SetData(self.left_data[data_index + 1])
		target_cell:SetIndex(data_index)
		target_cell:IsOn(data_index == self.left_select)
		target_cell:SetClickCallBack(BindTool.Bind(self.ClickLeftListCell, self, target_cell))
	end
end

function SymbolInfoView:ClickLeftListCell(cell)
	if self.left_select ~= cell.index then
		self.left_select = cell.index
		self.is_first = true
		self:Flush()
	end
end

function SymbolInfoView:InitMidScroller()
	self.mid_scroller = self:FindObj("MidList")
	local delegate = self.mid_scroller.list_simple_delegate
	-- 生成数量
	self.mid_data = {}
	delegate.NumberOfCellsDel = function()
		return 4
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell,data_index)
		local index = 4 - data_index
		local target_cell = self.food_list[index]

		if nil == target_cell then
			self.food_list[index] = FoodCell.New(cell.gameObject)
			target_cell = self.food_list[index]
			target_cell:GetItemCell():SetToggleGroup(self.mid_scroller.toggle_group)
		end

		local data = self.mid_data[index]
		self:SetMidData(target_cell, data, index)
		target_cell:GetItemCell():ListenClick(BindTool.Bind(self.MidItemClick, self, target_cell, index))
	end

	if self.mid_scroller.list_view then
		self.mid_scroller.list_view:JumpToIndex(0)
		self.mid_scroller.list_view:Reload()
	end
end

function SymbolInfoView:SetMidData(cell, data, index)
	cell:ShowTuiJian(index == 1 and data ~= nil)
	cell:SetIndex(index)

	local item_cell = cell:GetItemCell()
	item_cell:SetData(data)
	item_cell:SetInteractable(data ~= nil)
	item_cell:SetIconGrayScale(false)
	item_cell:ShowHighLight(self.cur_food_index == index and data ~= nil)
	item_cell:SetToggle(self.cur_food_index == index and data ~= nil)
	item_cell:SetItemNumVisible(data ~= nil)
	local num = data and data.num or 0
	item_cell:SetItemNum(num)
end

function SymbolInfoView:MidItemClick(cell, index)
	local item_cell = cell:GetItemCell()

	item_cell:ShowHighLight(true)
	item_cell:SetToggle(true)
	self.cur_food_index = index
end

function SymbolInfoView:InitRightScroller()
	self.right_scroller = self:FindObj("RightList")
	local delegate = self.right_scroller.list_simple_delegate
	-- 生成数量
	self.right_data = {}
	delegate.NumberOfCellsDel = function()
		return #self.right_data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			self.cell_list[cell] =  YuanshuAttrcell.New(cell.gameObject)
			target_cell = self.cell_list[cell]
		end
		target_cell:SetData(self.right_data[data_index])
	end
end

function SymbolInfoView:OpenCallBack()
	self.is_first = true

	self.model_res = 0

	SymbolData.Instance:UpdateFoodList()

	self:Flush()
end

function SymbolInfoView:CloseCallBack()
	self.cur_food_index = 1
	TipsCtrl.Instance:ChangeAutoViewAuto(false)
	TipsCommonAutoView.AUTO_VIEW_STR_T.change_element = nil
end

function SymbolInfoView:OnClickAutoFeed()
	local food_data =self.mid_data[self.cur_food_index]
	if food_data then
		if food_data.num <= 0 then
			GlobalEventSystem:Fire(KnapsackEventType.KNAPSACK_LECK_ITEM, food_data.item_id)
			return
		end
		SymbolCtrl.Instance:SendFeedElementHeartReq(self.left_select, food_data.item_id, food_data.num)
	end
end

function SymbolInfoView:OnClickFeed()
	local food_data =self.mid_data[self.cur_food_index]
	if food_data then
		if food_data.num <= 0 then
			GlobalEventSystem:Fire(KnapsackEventType.KNAPSACK_LECK_ITEM, food_data.item_id)
			return
		end
		SymbolCtrl.Instance:SendFeedElementHeartReq(self.left_select, food_data.item_id, 1)
	end
end


function SymbolInfoView:OnClickReward()
	SymbolCtrl.Instance:SendRewardElementHeartReq(self.left_select)
end

function SymbolInfoView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(267)
end

function SymbolInfoView:OnClickAccelerate()
	if not self.cur_act then
		TipsCtrl.Instance:ShowSystemMsg(Language.Symbol.NotActivitySymbol)
		return
	end
	local func = function ()
		SymbolCtrl.Instance:SendProductElementHeartReq(self.left_select)
	end
	local t = math.max(self.time - TimeCtrl.Instance:GetServerTime(), 0)
	local other = ConfigManager.Instance:GetAutoConfig("element_heart_cfg_auto").other[1]
	local consume_interval = other.ghost_product_up_speed_consume_interval
	local gold = other.ghost_product_up_speed_interval_consume_gold
	t = math.ceil(t / (consume_interval*60))
	TipsCtrl.Instance:ShowCommonTip(func, nil, string.format(Language.Symbol.AccelerateDescription, gold * t))
end

function SymbolInfoView:OnClickChange()
	if not self.cur_act then
		TipsCtrl.Instance:ShowSystemMsg(Language.Symbol.NotActivitySymbol)
		return
	end
	local role_gold = GameVoManager.Instance:GetMainRoleVo().gold
	local price = ConfigManager.Instance:GetAutoConfig("element_heart_cfg_auto").other[1].change_wuxing_type_need_gold
	local func = function ()
		if role_gold >= price then
			SymbolCtrl.Instance:SendChangeElementHeartReq(self.left_select)
		else
			TipsCtrl.Instance:ShowLackDiamondView()
		end
	end
	local str = string.format(Language.Symbol.ChangeElementDescription, price)
	TipsCtrl.Instance:ShowCommonAutoView("change_element", str, func, nil, nil, nil, nil, nil, true)
end

function SymbolInfoView:OnClickActive()
	SymbolCtrl.Instance:SendActiveElementHeartReq(self.left_select)
end

function SymbolInfoView:SetCanReward(value)
	self.can_reward:SetValue(value)
	if value and not self.reward_btn_ani:GetBool("Shake") then
		self.reward_btn_ani:SetBool("Shake", value)
	end
end

function SymbolInfoView:OnFlush(param_t)
	local data = SymbolData.Instance
	local info = data:GetElementInfo(self.left_select)
	if info == nil then
		return
	end

	-- 刷新模型
	self:FlushModel(info)

	--是否已激活
	self.cur_act = info.element_level > 0
	self.is_active:SetValue(self.cur_act)
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
	end
	-- 激活
	if self.cur_act then
		self.level:SetValue(info.element_level)
		self.name:SetValue(Language.Symbol.ElementsName[info.wuxing_type])
		self.element:SetAsset(ResPath.GetSymbolImage("Element_" .. info.wuxing_type))
		-- 产出时间
		self.time = info.next_product_timestamp
		if self.time > TimeCtrl.Instance:GetServerTime() then
			self:SetCanReward(false)
			self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
			self:FlushNextTime()
		else
			self:SetCanReward(true)
		end

		local level_cfg = data:GetElementHeartLevelCfg(info.element_level)
		if level_cfg == nil then
			return
		end

		self.mid_data = data:GetElementFoodsByType(info.wuxing_type)

		local next_level_cfg = data:GetElementHeartLevelCfg(info.element_level + 1)
		local cur_attr = CommonDataManager.GetAttributteByClass(level_cfg)
		local next_attr = CommonDataManager.GetAttributteByClass(next_level_cfg)
		local add = data:GetElementXiLianAttrAdditionValue(self.left_select)
		self.cap:SetValue(CommonDataManager.GetCapability(cur_attr) * (1 + add / 100))
		if next_level_cfg then
			local wuxing_max = level_cfg.wuxing_max - level_cfg.wuxing_min + 1
			local cur_value = math.max(info.wuxing_bless - level_cfg.wuxing_min, 0)
			if self.is_first then
				self.is_first = false
				self.prop:InitValue(cur_value / wuxing_max)
			else
				self.prop:SetValue(cur_value / wuxing_max)
			end
			self.prop_txt:SetValue(cur_value .. "/" .. wuxing_max)
		else
			-- 满级
			self.prop:SetValue(1)
			self.prop_txt:SetValue(Language.Common.MaxLevel)
		end
		self.right_data = {}
		for k,v in ipairs(CommonDataManager.attrview_t) do
			local cur_val = cur_attr[v[2]] or 0
			local next_val = next_attr[v[2]] or 0
			if cur_val > 0 or next_val > 0 then
				table.insert(self.right_data, {key = v[2], cur_value = cur_val, next_value = next_val})
			end
		end
	--未激活
	else
		self.level:SetValue(0)
		self.prop:SetValue(0)
		self.prop_txt:SetValue("")
		self.name:SetValue("")
		self.name:SetValue("")
		self.cap:SetValue(0)
		self.element:SetAsset("", "")
		self.mid_data = {}
		self.right_data = {}
		self.active_limit:SetValue(data:GetElementLimitString(self.left_select))
	end
	-- 自动选择材料
	if self.mid_data[self.cur_food_index] == nil or self.mid_data[self.cur_food_index].num <= 0 then
		for i,v in ipairs(self.mid_data) do
			if v.num > 0 then
				self.cur_food_index = i
				break
			end
		end
	end

	if self.left_scroller.scroller.isActiveAndEnabled then
		self.left_scroller.scroller:RefreshAndReloadActiveCellViews(true)
	end
	for k,v in pairs(self.food_list) do
		if self.mid_data[k] then
			self:SetMidData(v, self.mid_data[k], k)
		else
			self:SetMidData(v, nil, k)
		end
	end
	if self.right_scroller.scroller.isActiveAndEnabled then
		self.right_scroller.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function SymbolInfoView:FlushNextTime()
	local time = self.time - TimeCtrl.Instance:GetServerTime()
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
		self:SetCanReward(true)
	end
	if time > 3600 * 24 then
		self.reward_time:SetValue("<color='#00ff00'>" .. TimeUtil.FormatSecond(time, 6) .. "</color>")
	elseif time > 3600 then
		self.reward_time:SetValue("<color='#00ff00'>" .. TimeUtil.FormatSecond(time, 1) .. "</color>")
	else
		self.reward_time:SetValue("<color='#00ff00'>" .. TimeUtil.FormatSecond(time, 2) .. "</color>")
	end
end

---------------------------------------------------------------
--滚动条格子
YuanshuLeftCell = YuanshuLeftCell or BaseClass(BaseCell)

function YuanshuLeftCell:__init()
	self.icon = self:FindVariable("Icon")
	self.name = self:FindVariable("Name")
	self.remind = self:FindVariable("Remind")
	self.lock = self:FindVariable("Lock")
	self:ListenEvent("OnClick",
		BindTool.Bind(self.OnClick, self))
	self:ListenEvent("OnLockClick",
		BindTool.Bind(self.OnLockClick,self))
end

function YuanshuLeftCell:__delete()

end

function YuanshuLeftCell:IsOn(value)
	self.root_node.toggle.isOn = value
end

function YuanshuLeftCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function YuanshuLeftCell:Lock(value)
	self.lock:SetValue(value)
end

function YuanshuLeftCell:OnLockClick()
	local l_info = SymbolData.Instance:GetElementInfo(self.index - 1)
	if l_info and l_info.element_level > 0 then
		TipsCtrl.Instance:ShowSystemMsg(SymbolData.Instance:GetElementLimitString(self.index))
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Symbol.TheLastNoActived)
	end
end

function YuanshuLeftCell:OnFlush()
	if nil == self.data then return end

	local element_data = SymbolData.Instance
	local info = element_data:GetElementInfo(self.data.id)

	if info then
		local can_act = element_data:GetSymbolYuanSuCanActive(self.data.id)
		self.icon:SetAsset(ResPath.GetSymbolImage("yuansu_icon_" .. self.data.id))
		if info.element_level > 0 then
			self:Lock(false)
			self.name:SetValue("LV." .. info.element_level)
			local has_tuijian_food = element_data:GetHasTuijianElementFoods(info.wuxing_type) and element_data:GetElementMaxLevel() > info.element_level
			local can_reward = info.next_product_timestamp <= TimeCtrl.Instance:GetServerTime()
			self.remind:SetValue(can_act or has_tuijian_food or can_reward)
		else
			self.remind:SetValue(can_act)
			self:Lock(true)
			self.name:SetValue("")
		end
	end
end


---------------

YuanshuAttrcell = YuanshuAttrcell or BaseClass(BaseCell)

function YuanshuAttrcell:__init()
	self.attr_name = self:FindVariable("AttrName")
	self.attr = self:FindVariable("Attr")
	self.attr_add = self:FindVariable("AttrAdd")
	self.have_add = self:FindVariable("HaveAdd")
end

function YuanshuAttrcell:__delete()

end

function YuanshuAttrcell:OnFlush()
	if nil == self.data then return end
	local name = Language.Common.AttrName[self.data.key]
	self.attr_name:SetValue(name)
	self.attr:SetValue(self.data.cur_value)
	self.attr_add:SetValue(self.data.next_value or 0)
	self.have_add:SetValue(self.data.next_value and self.data.next_value > 0)
end

FoodCell = FoodCell or BaseClass(BaseCell)
function FoodCell:__init()
	self.show_tuijian = self:FindVariable("show_tuijian")

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
end

function FoodCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function FoodCell:ShowTuiJian(state)
	self.show_tuijian:SetValue(state)
end

function FoodCell:GetItemCell()
	return self.item_cell
end
