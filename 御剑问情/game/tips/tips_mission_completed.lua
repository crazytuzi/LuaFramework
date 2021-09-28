TipsMissionCompletedView = TipsMissionCompletedView or BaseClass(BaseView)

function TipsMissionCompletedView:__init()
	self.ui_config = {"uis/views/tips/missioncompletedtips_prefab", "MissionCompletedTips"}
	self.again_call_back = nil
	self.close_call_back = nil
	self.item_info_list = {}
	self.need_money = 0
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self.item_list ={}
	self.show_item = {}
	self.reset_list = {}
	self.show_reset_item = {}
end

function TipsMissionCompletedView:__delete()

end

function TipsMissionCompletedView:ReleaseCallBack()
	self.reward_list = nil
	self.money_text = nil 
	self.again_btn = nil 
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	for k,v in pairs(self.reset_list) do
		v:DeleteMe()
	end
	self.reset_list = {}
	
	for i=1,3 do
		self.show_item[i] = nil
	end
	
	for i=1,4 do
		self.show_reset_item[i] = nil
	end
end

function TipsMissionCompletedView:LoadCallBack()
	self:ListenEvent("again_click",BindTool.Bind(self.AgainClick, self))
	self:ListenEvent("sure_click",BindTool.Bind(self.SureClick, self))
	self.again_btn = self:FindObj("again_btn")
	self.money_text = self:FindVariable("money_text")
	self.text_gray = self:FindVariable("text_gray")

	self.reward_list = self:FindObj("RewardList")
	for i=1,3 do
		self.item_list[i] = ItemCell.New() 
		self.item_list[i]:SetInstanceParent(self:FindObj("item_"..i))
		-- self.item_list[i] = MissionCompletedItem.New(self:FindObj("item_"..i))
		-- self.item_list[i]:SetToggleGroup(self.reward_list.toggle_group)
		self.show_item[i] = self:FindVariable("show_item" .. i)
	end

	for i = 1,4 do
		self.reset_list[i] = ItemCell.New() 
		self.reset_list[i]:SetInstanceParent(self:FindObj("ResetRewardItem"..i))
		self.show_reset_item[i] = self:FindVariable("show_reward_item_" .. i)
	end
end

function TipsMissionCompletedView:OpenCallBack()
	-- 平常奖励
	for k = 1, 3 do
		if self.item_info_list and self.item_info_list[k] then
			-- v:SetItemInfo(self.item_info_list[k])
			self.item_list[k]:SetData(self.item_info_list[k])
			self.show_item[k]:SetValue(true)
		end
	end
	-- 重置的奖励	
	local itemId = self.item_info_list[4].item_id
	local re_item_list = ItemData.Instance:GetGiftItemList(itemId)
	if re_item_list and next(re_item_list) then
		-- 礼包奖励
		for k,v in pairs(self.reset_list) do
			if re_item_list[k] then
				v:SetData(re_item_list[k])
				self.show_reset_item[k]:SetValue(true)
			end
		end
	else
		-- 非礼包奖励
		self.reset_list[1]:SetData(self.item_info_list[4])
		self.show_reset_item[1]:SetValue(true)
	end

	self.money_text:SetValue(self.need_money)
	local move_info = GoPawnData.Instance:GetChessInfo()
	if move_info.move_chess_reset_times >= 2 then
		self.again_btn.grayscale.GrayScale = 255
		self.text_gray:SetValue(true)
		self.again_btn.button.interactable = false
	else
		self.text_gray:SetValue(false)
		self.again_btn.grayscale.GrayScale = 0
		self.again_btn.button.interactable = true
	end
end

function TipsMissionCompletedView:Init(item_info_list, need_money, again_call_back,close_call_back)
	self.item_info_list = item_info_list
	self.need_money = need_money
	self.again_call_back = again_call_back
	self.close_call_back = close_call_back
end

function TipsMissionCompletedView:CloseCallBack()
	if self.close_call_back ~= nil then
		self.close_call_back()
	end
end

function TipsMissionCompletedView:AgainClick()
	self:Close()
	if self.again_call_back ~= nil then
		self.again_call_back()
	end
end

function TipsMissionCompletedView:SureClick()
	self:Close()
end
 
-------------------------------------------------------------------------------
MissionCompletedItem = MissionCompletedItem  or BaseClass(BaseCell)

function MissionCompletedItem:__init()
	self.item_info = {}
	self.icon = self:FindVariable("Icon")
	self.show_number = self:FindVariable("ShowNumber")
	self.number_text = self:FindVariable("Number")
	self.show_bind = self:FindVariable("Bind")
	self:ListenEvent("Click",BindTool.Bind(self.OnItemClick, self))
end

function MissionCompletedItem:SetItemInfo(item_info)
	self.item_info = item_info
	if self.item_info then
		local bundle, asset = ResPath.GetItemIcon(ItemData.Instance:GetItemConfig(self.item_info.item_id).icon_id)
		self.icon:SetAsset(bundle, asset)
		if self.item_info.num == 1 then
			self.show_number:SetValue(false)
		else
			self.show_number:SetValue(true)
			self.number_text:SetValue(self.item_info.num)
		end
		if  self.item_info.is_bind == 0 then
			self.show_bind:SetValue(false)
		else
			self.show_bind:SetValue(true)
		end
	end
end

function MissionCompletedItem:OnItemClick()
	if self.root_node.toggle.isOn then
		local data = {}
		data.is_bind = self.item_info.is_bind
		data.item_id = self.item_info.item_id
		TipsCtrl.Instance:OpenItem(data, nil, nil, nil)
	end
end

function MissionCompletedItem:SetToggleGroup(group)
	self.root_node.toggle.group = group
end
