TipsGetNewitemView = TipsGetNewitemView or BaseClass(BaseView)

function TipsGetNewitemView:__init()
	self.ui_config = {"uis/views/tips/getnewitemtips", "GetNewItemTips"}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self.data_list = {}
	self.quick_use_tab = {}
end

function TipsGetNewitemView:__delete()
end

function TipsGetNewitemView:LoadCallBack()
	self:ListenEvent("CloseView", BindTool.Bind(self.CloseView, self))
	self:ListenEvent("ReduceClick", BindTool.Bind(self.ChangeNumber, self, -1))
	self:ListenEvent("AddClick", BindTool.Bind(self.ChangeNumber, self, 1))
	self:ListenEvent("UseClick", BindTool.Bind(self.UseClick, self))

	self.item_cell = ItemCellReward.New()
	self.item_cell:SetInstanceParent(self:FindObj('ItemCell'))
	self.item_num = self:FindVariable('ItemNumber')
	self.item_name = self:FindVariable('ItemName')
	self.use_text = self:FindVariable("UseText")
end

function TipsGetNewitemView:ReleaseCallBack()
	if self.scene_load_enter ~= nil then
		GlobalEventSystem:UnBind(self.scene_load_enter)
		self.scene_load_enter = nil
	end

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	-- 清理变量和对象
	self.item_num = nil
	self.item_name = nil
	self.use_text = nil
end

function TipsGetNewitemView:OpenView(item_id)
	self.item_data = {}

	local bag_data = ItemData.Instance:GetItem(item_id)
	self.number_value = bag_data.num
	self.max_number = self.number_value
	self.item_data.item_id = item_id
	self.item_data.num = self.number_value

	local is_insert = true
	for k, v in pairs(self.data_list) do
		if item_id == v.item_id then
			is_insert = false
			return
		end
	end
	if is_insert then
		table.insert(self.data_list, self.item_data)
	end
	self:Open()
end

function TipsGetNewitemView:OpenCallBack()
	self.scene_load_enter = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER,
		BindTool.Bind(self.OnChangeScene, self))

	self.item_cfg = ItemData.Instance:GetItemConfig(self.data_list[1].item_id)
	self.item_name:SetValue(self.item_cfg.name)
	-- self.item_cell:SetData(self.item_data)
	-- self.item_num:SetValue(self.number_value)
	self.item_cell:SetData(self.data_list[1])
	
	local str = ""
	if self.item_cfg and self.item_cfg.gift_type == GameEnum.ITEM_GIFT_TYPE.WEAPON then
		str = Language.Common.ItemFastUse[GameEnum.ITEM_GIFT_TYPE.WEAPON]
	else
		str = Language.Common.ItemFastUse[GameEnum.ITEM_GIFT_TYPE.COMMON]
	end
	self.use_text:SetValue(str)

	if self:IsQuickUseItemId(self.data_list[1].item_id) ~= nil and next(self:IsQuickUseItemId(self.data_list[1].item_id)) and PlayerData.Instance.role_vo.level < self:IsQuickUseItemId(self.data_list[1].item_id).level then
		if self.timer_quest then
			if next(self.quick_use_tab) then
				local is_close =  self.quick_use_tab.item_id == self.data_list[1].item_id and true or false
				self:QuickUseClick(is_close)
		 		self.quick_use_tab = {}
		 		if is_close then return end
			end
			GlobalTimerQuest:CancelQuest(self.timer_quest)
		end
		self.quick_use_tab.item_id = self.data_list[1].item_id
		self.quick_use_tab.need_gold = self.item_cfg.need_gold
		local time = 3
		self.timer_quest = GlobalTimerQuest:AddRunQuest(function()
			time = time - UnityEngine.Time.deltaTime
			if time < 0 and next(self.quick_use_tab) then
		 		self:QuickUseClick(true)
		 		self.quick_use_tab = {}
		 		if self.timer_quest then
					GlobalTimerQuest:CancelQuest(self.timer_quest)
				end
		 	end
		end, 0)
	end
end

function TipsGetNewitemView:CloseCallBack()
	table.remove(self.data_list, 1)
	if next(self.data_list) then
		self:Open()
	end
	if self.scene_load_enter ~= nil then
		GlobalEventSystem:UnBind(self.scene_load_enter)
		self.scene_load_enter = nil
	end
end

function TipsGetNewitemView:OnChangeScene()
	if self:IsOpen() then
		self:Close()
	end
end

function TipsGetNewitemView:UseClick()
	if self.data_list[1] then
		local bag_data = ItemData.Instance:GetItem(self.data_list[1].item_id)
		local gift_item, item_type = ItemData.Instance:GetItemConfig(self.data_list[1].item_id)
		-- if gift_item and gift_item.dynamic_show == 1 then
		-- 	TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_RANK_GIFT, nil, nil, self.data_list[1].item_id)
		-- end
		if gift_item.is_display_role then
			local is_grade = AdvanceData.Instance:GetSpecialImageIsActive(gift_item.is_display_role, gift_item.param1)
			if is_grade then 
				self:Close()
				return 
			end
		end

		if item_type == GameEnum.ITEM_BIGTYPE_EXPENSE then
			--如果已激活时装就升级
			local types, index = FashionData.Instance:GetFashionTypeAndIndexById(self.data_list[1].item_id)
			if types and index then
				local level = FashionData.Instance:GetCurLevel(index, types)
				if level >= 1 then
					FashionCtrl.Instance:SendFashionUpgradeReq(types, index)
					self:Close()
					return
				end
			end
		end

		if bag_data then
			PackageCtrl.Instance:SendUseItem(bag_data.index, bag_data.num, bag_data.sub_type, self.item_cfg.need_gold)
		end
		self:Close()
		return
	end
end

function TipsGetNewitemView:QuickUseClick(is_close_window)
	if next(self.quick_use_tab) then
		local bag_data = ItemData.Instance:GetItem(self.quick_use_tab.item_id)
		if bag_data then
			PackageCtrl.Instance:SendUseItem(bag_data.index, bag_data.num, bag_data.sub_type, self.quick_use_tab.need_gold)
		end
	end
	if is_close_window then
		self:Close()
	end
end

function TipsGetNewitemView:ChangeNumber(number)
	local try_number = self.number_value
	try_number = try_number + number
	if try_number > 0 and try_number <= self.max_number then
		self.number_value = try_number
		self.item_num:SetValue(self.number_value)
	end
end

function TipsGetNewitemView:CloseView()
	self:Close()
end

-- 是否自动使用物品
function TipsGetNewitemView:IsQuickUseItemId(item_id) 
	local tab = {
		[22020] = {["level"] = 31},
		[28525] = {["level"] = 50},
	}
	return tab[item_id]
end