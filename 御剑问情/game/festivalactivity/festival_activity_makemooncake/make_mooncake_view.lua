MakeMoonCakeView = MakeMoonCakeView or BaseClass(BaseRender)

local MAX_MOOM_CAKE_TYPE = 5
function MakeMoonCakeView:__init(instance)
	self.activity_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION_2
	self.moon_data_list = {}
	self.select_index = 1
	self.exchange_count = self:FindVariable("ExchangeCount")
	self.show_item2 = self:FindVariable("ShowItem2")
	self.show_item3 = self:FindVariable("ShowItem3")
	self.show_item4 = self:FindVariable("ShowItem4")
	self.exchange_btn_enble = self:FindVariable("ExchangeBtnEnble")
	self.gray_get_button = self:FindObj("GetButton")
	self.show_red_point = self:FindVariable("ShowRedPoint")
	self.count_down_time = self:FindVariable("CountDownTime")

	self.cell_list = {}
	self.list = self:FindObj("ListView")
	self.list_delegate = self.list.list_simple_delegate
	self.list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.item_list = {}
	self.text_list = {}
	for i = 1, 4 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("Item" .. i))
		self.text_list[i] = self:FindVariable("Text"..i)
	end
	self.reward_item = ItemCell.New()
	self.reward_item:SetInstanceParent(self:FindObj("RewardItem"))

	self:ListenEvent("OnClickMake", BindTool.Bind(self.OnClickMake, self))
	self:ListenEvent("GetMaterialsButton", BindTool.Bind(self.ClickYeWaiGuaJi, self))
end

function MakeMoonCakeView:__delete()
	self.activity_type = nil
	self.moon_data_list = nil
	self.exchange_count = nil
	self.show_item2 = nil
	self.show_item3 = nil
	self.show_item4 = nil
	self.exchange_btn_enble = nil
	self.gray_get_button = nil
	self.show_red_point = nil
	self.list = nil
	self.list_delegate = nil
	self.count_down_time = nil

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.reward_item then
		self.reward_item:DeleteMe()
		self.reward_item = nil
	end

	if self.count_down then
        CountDown.Instance:RemoveCountDown(self.count_down)
        self.count_down = nil
    end
end

function MakeMoonCakeView:OpenCallBack()
	self.select_index = 1
	self:Flush()
end

function MakeMoonCakeView:CloseCallBack()

end

function MakeMoonCakeView:GetNumberOfCells()
	local count = 0
	count = #self.moon_data_list 
	return count
end

function MakeMoonCakeView:RefreshCell(cell, data_index)
	local data_list = PlayerData.Instance:GetCurrentRandActivityConfig().item_collection_2
	data_index = data_index + 1
	local cell_item = self.cell_list[cell]
	if cell_item == nil then
		cell_item = MoonCakeItem.New(cell.gameObject)
		cell_item:SetToggleGroup(self.list.toggle_group)
		cell_item:SetClickCallBack(BindTool.Bind(self.OnChooseMoonType, self))
		self.cell_list[cell] = cell_item
	end
	cell_item:SetIndex(data_index)
	cell_item:SetData(data_list[data_index])
	cell_item:SetHighLight(data_index == self.select_index)
end

function MakeMoonCakeView:GetMoonCakeDataList()
	self.moon_data_list = PlayerData.Instance:GetCurrentRandActivityConfig().item_collection_2
end

--选择月饼类型
function MakeMoonCakeView:OnChooseMoonType(cell)
	if cell == nil then return end

	local index = cell:GetIndex()
	if index == self.select_index then return end
	self.select_index = index
	self:FlushMoonCakeItem()
	self:FlushAllHightLight()
	self:SetRedPoint()
end

function MakeMoonCakeView:FlushAllHightLight()
	for k,v in pairs(self.cell_list) do
		local index = v:GetIndex()
		v:SetHighLight(index == self.select_index)
	end
end

--制作按钮
function MakeMoonCakeView:OnClickMake()
	local index = self.moon_data_list[self.select_index].seq
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(self.activity_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH, index)
end

function MakeMoonCakeView:OnFlush(param_t)
	self.list.scroller:RefreshAndReloadActiveCellViews(false)
	for k,v in pairs(param_t) do
		if k ~= "make_moon_cake" then
			self.select_index = 1
			self:FlushAllHightLight()
		end
	end
	self:GetMoonCakeDataList()
	self:FlushMoonCakeItem()
	self:SetRedPoint()

	-- 刷新倒计时
	local activity_end_time = FestivalActivityData.Instance:GetActivityActTimeLeftById(self.activity_type)
    if self.count_down then
        CountDown.Instance:RemoveCountDown(self.count_down)
        self.count_down = nil
    end

    self.count_down = CountDown.Instance:AddCountDown(activity_end_time, 1, function ()
        activity_end_time = activity_end_time - 1
        self.count_down_time:SetValue(TimeUtil.FormatBySituation(activity_end_time))
    end)

    self:FlushRedPoint()
end

function MakeMoonCakeView:FlushMoonCakeItem()
	if next(self.moon_data_list) ~= nil then
		local data = self.moon_data_list[self.select_index]
		if data == nil then return end
		local time_t = MakeMoonCakeData.Instance:GetCollectExchangeInfo()
		local times = time_t[data.seq + 1] or 0
		local count = math.max(data.exchange_times_limit  - times, 0)
		self.exchange_count:SetValue(count)

		self.show_item2:SetValue(true)
		self.show_item3:SetValue(true)
		self.show_item4:SetValue(true)

		local is_destory_effect = true
		for k, v in pairs(data.item_special or {}) do
			if v.item_id == data.reward_item.item_id then
				self.reward_item:IsDestoryActivityEffect(false)
				self.reward_item:SetActivityEffect()
				is_destory_effect = false
				break
			end
		end
		if is_destory_effect then
			self.reward_item:IsDestoryActivityEffect(is_destory_effect)
			self.reward_item:SetActivityEffect()
		end
		self.reward_item:SetData(data.reward_item)
		local can_reward = true
		local index = 1
		local text_str = ""
		local stuff_id = "stuff_id"
		for i = 1, 4 do
			if data[stuff_id .. i] and data[stuff_id .. i].item_id > 0 and self.item_list[index] then
				local num = ItemData.Instance:GetItemNumInBagById(data[stuff_id .. i].item_id)
				if num < data[stuff_id .. i].num then
					can_reward = false
				end
				self.item_list[index]:SetData({item_id = data[stuff_id .. i].item_id})					
				if num >= data[stuff_id..i].num then
					text_str = string.format("%s / %s", ToColorStr(num, TEXT_COLOR.GREEN_4), data[stuff_id..i].num)
				else
					text_str = string.format("%s / %s", ToColorStr(num, TEXT_COLOR.WHITE), data[stuff_id..i].num)
				end
				self.text_list[index]:SetValue(text_str)
				index = index + 1
			end
		end
		if index <= 4 then
			for i = index, 4 do
				if self["show_item" .. i] then
					self["show_item" .. i]:SetValue(false)
				end
			end
		end
		self.gray_get_button.button.interactable = can_reward
		self.exchange_btn_enble:SetValue(can_reward)
	end
end

function MakeMoonCakeView:FlushRedPoint()
	self:FlushMoonCakeItem()
	self.list.scroller:RefreshAndReloadActiveCellViews(false)
	self:SetRedPoint()
end

function MakeMoonCakeView:SetRedPoint()
	index = self.select_index - 1
	local can_get = MakeMoonCakeData.Instance:SingleMakeMoonCakeRedPoint(index)
	self.show_red_point:SetValue(can_get)
end

function MakeMoonCakeView:ClickYeWaiGuaJi()
	ViewManager.Instance:Open(ViewName.YewaiGuajiView)
end

--------------------MoonCakeItem--------------------------------------
MoonCakeItem = MoonCakeItem or BaseClass(BaseCell)

function MoonCakeItem:__init(instance)
	self.name = self:FindVariable("name")
	self.cake_image = self:FindVariable("image")
	self.show_red_point = self:FindVariable("ShowRedPoint")
	self:ListenEvent("onclick", BindTool.Bind(self.OnClick, self))
end

function MoonCakeItem:__delete()

end

function MoonCakeItem:SetData(data)
	if data == nil then return end
	local str_type = FestivalActivityData.Instance:GetBgCfg()

	self.cake_image:SetAsset(ResPath.GetMoonCakeTypeImage(str_type.str_type, data.item_id))
	self.name:SetAsset(ResPath.GetMoonCakeTypeName(str_type.str_type, data.reward_name_id))
	local can_get = MakeMoonCakeData.Instance:SingleMakeMoonCakeRedPoint(data.seq)
	self.show_red_point:SetValue(can_get)
end

function MoonCakeItem:OnFlush()

end

function MoonCakeItem:OnClick(handler)
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

function MoonCakeItem:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function MoonCakeItem:SetHighLight(enable)
	self.root_node.toggle.isOn = enable
end