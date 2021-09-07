TipsStarRewardView = TipsStarRewardView or BaseClass(BaseView)

function TipsStarRewardView:__init()
	self.ui_config = {"uis/views/tips/rewardtips", "StarRewardTips"}
	self.item_list = {}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self:SetMaskBg(true)
end

function TipsStarRewardView:__delete()
	self.data_list = nil
	for k, v in pairs(self.item_list) do
		if v ~= nil and v.item_cell ~= nil then
			v.item_cell:DeleteMe()
		end
	end
	self.item_list = {}
end

function TipsStarRewardView:SetData(items, show_gray, ok_callback, show_button)
	self.data_list = items
	self.show_gray_data = show_gray
	self.ok_callback = ok_callback
	self.show_button_value = show_button
end

function TipsStarRewardView:LoadCallBack()
	self:ListenEvent("CloseView", BindTool.Bind(self.CloseView, self))
	self:ListenEvent("ClickOK", BindTool.Bind(self.ClickOK, self))

	self.item_list = {}
	for i = 1, 3 do
		local item_obj = self:FindObj("Item"..i)
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(item_obj)
		self.item_list[i - 1] = {item_obj = item_obj, item_cell = item_cell}
	end

	self.show_gray = self:FindVariable("ShowGray")
	self.show_button = self:FindVariable("ShowButton")
end

function TipsStarRewardView:CloseView()
	self:Close()
end

function TipsStarRewardView:ClickOK()
	if self.ok_callback then
		self.ok_callback()
	end
	self:Close()
end

function TipsStarRewardView:OpenCallBack()
	self:Flush()
end
function TipsStarRewardView:OnFlush()
	if self.data_list ~= nil then
		for k, v in pairs(self.item_list) do
			if self.data_list[k] then
				v.item_cell:SetData(self.data_list[k])
				v.item_obj:SetActive(true)
			else
				v.item_obj:SetActive(false)
			end
		end

		self.show_gray:SetValue(self.show_gray_data)
		if self.show_button_value == nil then
			self.show_button:SetValue(true)
		else
			self.show_button:SetValue(self.show_button_value)
		end
	end
end

function TipsStarRewardView:ReleaseCallBack()
	self.data_list = nil
	for k,v in pairs(self.item_list) do
		if v.item_cell then
			v.item_cell:DeleteMe()
		end
	end
	self.item_list = {}
	self.show_gray = nil
	self.show_button = nil
end
