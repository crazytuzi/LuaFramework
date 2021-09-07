TipsMissionCompletedView = TipsMissionCompletedView or BaseClass(BaseView)

function TipsMissionCompletedView:__init()
	self.ui_config = {"uis/views/tips/missioncompletedtips", "MissionCompletedTips"}
	self.again_call_back = nil
	self.close_call_back = nil
	self.item_info_list = {}
	self.need_money = 0
	self.play_audio = true
	self.view_layer = UiLayer.Pop
end

function TipsMissionCompletedView:__delete()
end

function TipsMissionCompletedView:LoadCallBack()
	self:ListenEvent("again_click",BindTool.Bind(self.AgainClick, self))
	self:ListenEvent("sure_click",BindTool.Bind(self.SureClick, self))
	self.again_btn = self:FindObj("again_btn")
	self.money_text = self:FindVariable("money_text")
	self.item_list ={}
	for i=1,4 do
		self.item_list[i] = MissionCompletedItem.New(self:FindObj("item_"..i))
	end
end

function TipsMissionCompletedView:OpenCallBack()
	for k,v in pairs(self.item_list) do
		v:SetItemInfo(self.item_info_list[k])
	end
	self.money_text:SetValue(self.need_money)
	local move_info = GoPawnData.Instance:GetChessInfo()
	if move_info.move_chess_reset_times >=2 then
		self.again_btn.grayscale.GrayScale = 255
		self.again_btn.button.interactable = false
	else
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
	self.show_number = self:FindVariable("Show_number")
	self.number_text = self:FindVariable("Number_text")
	self.show_bind = self:FindVariable("Bind")
	self:ListenEvent("Click",BindTool.Bind(self.OnItemClick, self))
end

function MissionCompletedItem:SetItemInfo(item_info)
	self.item_info = item_info
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

function MissionCompletedItem:OnItemClick(is_click)
	if is_click then
		local data = {}
		data.is_bind = self.item_info.is_bind
		data.item_id = self.item_info.item_id
		TipsCtrl.Instance:OpenItem(data, nil, nil, nil)
	end
end

