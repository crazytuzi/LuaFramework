KaifuActivityPanelTwo = KaifuActivityPanelTwo or BaseClass(BaseRender)

function KaifuActivityPanelTwo:__init(instance)
	self.cell_list = {}
end

function KaifuActivityPanelTwo:LoadCallBack()
	self.list = self:FindObj("ListView")
	self.list_delegate = self.list.list_simple_delegate
	self.list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function KaifuActivityPanelTwo:__delete()
	self.temp_activity_type = nil
	self.activity_type = nil

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

function KaifuActivityPanelTwo:GetNumberOfCells()
	return #PlayerData.Instance:GetCurrentRandActivityConfig().item_collection
end

function KaifuActivityPanelTwo:RefreshCell(cell, data_index)
	local cell_item = self.cell_list[cell]
	if cell_item == nil then
		cell_item = PanelListCellTwo.New(cell.gameObject)
		self.cell_list[cell] = cell_item
	end

	local cfg = PlayerData.Instance:GetCurrentRandActivityConfig().item_collection
	cell_item:SetData(cfg[data_index + 1])
	cell_item:ListenClick(BindTool.Bind(self.OnClickGet, self, cfg[data_index + 1].seq))
end

function KaifuActivityPanelTwo:OnClickGet(index)
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(self.activity_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH, index)
end

function KaifuActivityPanelTwo:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	for k,v in pairs(PlayerData.Instance:GetCurrentRandActivityConfig().item_collection) do
		for i = 1, 4 do
			if v["stuff_id" .. i] and item_id == v["stuff_id" .. i].item_id then
				if self.list.scroller.isActiveAndEnabled then
					self.list.scroller:RefreshActiveCellViews()
				end
			end
		end
	end
end

function KaifuActivityPanelTwo:SetCurTyoe(cur_type)
	self.cur_type = cur_type
end

function KaifuActivityPanelTwo:OnFlush()
	local activity_type = self.cur_type
	self.activity_type = activity_type or self.activity_type

	if activity_type == self.temp_activity_type then
		self.list.scroller:RefreshActiveCellViews()
	else
		if self.list.scroller.isActiveAndEnabled then
			self.list.scroller:ReloadData(0)
		end
	end
	self.temp_activity_type = activity_type
end


PanelListCellTwo = PanelListCellTwo or BaseClass(BaseCell)

function PanelListCellTwo:__init(instance)
	self.exchange_count = self:FindVariable("ExchangeCount")
	self.show_item2 = self:FindVariable("ShowItem2")
	self.show_item3 = self:FindVariable("ShowItem3")
	self.show_item4 = self:FindVariable("ShowItem4")
	self.exchange_btn_enble = self:FindVariable("ExchangeBtnEnble")
	self.gray_get_button = self:FindObj("GetButton")

	self.item_list = {}
	self.text_list = {}
	for i = 1, 4 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("Item" .. i))
		self.text_list[i] = self:FindVariable("Text"..i)
	end
	self.reward_item = ItemCell.New()
	self.reward_item:SetInstanceParent(self:FindObj("RewardItem"))
end

function PanelListCellTwo:__delete()
	if self.reward_item ~= nil then
		self.reward_item:DeleteMe()
		self.reward_item = nil
	end
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function PanelListCellTwo:OnFlush()
	if self.data == nil then return end

	local times_t = KaifuActivityData.Instance:GetCollectExchangeInfo()
	local times = times_t[self.data.seq + 1] or 0
	local count = math.max(self.data.exchange_times_limit - times, 0)
	local color = count > 0 and COLOR.GREEN or COLOR.RED
	self.exchange_count:SetValue("<color=" .. color .. ">" .. count .. "</color>")
	self.show_item2:SetValue(true)
	self.show_item3:SetValue(true)
	self.show_item4:SetValue(true)

	local is_destory_effect = true
	for k, v in pairs(self.data.item_special or {}) do
		if v.item_id == self.data.reward_item.item_id then
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
	self.reward_item:SetData(self.data.reward_item)

	local can_reward = count > 0
	local index = 1
	local text_str = ""
	for i = 1, 4 do
		if self.data["stuff_id" .. i] and self.data["stuff_id" .. i].item_id > 0 and self.item_list[index] then
			local num = ItemData.Instance:GetItemNumInBagById(self.data["stuff_id" .. i].item_id)
			if num < self.data["stuff_id" .. i].num then
				can_reward = false
			end
			-- self.item_list[index]:SetShowNumTxtLessNum(0)
			self.item_list[index]:SetData({item_id = self.data["stuff_id" .. i].item_id})
			local color = num < self.data["stuff_id" .. i].num and "FF0000" or "00931F"

			text_str = "<color=#" .. color .. ">" .. num .. "</color>"  .. "<color=#532F1EFF>/" .. self.data["stuff_id" .. i].num .. "</color>"
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

function PanelListCellTwo:ListenClick(handler)
	self:ClearEvent("OnClickGet")
	self:ListenEvent("OnClickGet", handler)
	self:Flush()
end