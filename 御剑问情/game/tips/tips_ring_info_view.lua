TipsRingInfoView = TipsRingInfoView or BaseClass(BaseView)

function TipsRingInfoView:__init()
	self.ui_config = {"uis/views/marriageview_prefab", "RingInfoView"}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
end

function TipsRingInfoView:__delete()

end

function TipsRingInfoView:OpenView()
	self:Open()
end

-- 创建完调用
function TipsRingInfoView:LoadCallBack()
	self:ListenEvent("CloseView", BindTool.Bind(self.CloseView, self))
	self.ring_name = self:FindVariable("Name")
	self.item_cell = ItemCellReward.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.item_cell:ListenClick(function()end)
	self.ring_power = self:FindVariable("Power")
	self.ring_star = self:FindVariable("Star")

	self.attr_list = {}
	local item_manager = self:FindObj("ItemManager")
	local child_number = item_manager.transform.childCount
	for i = 0, child_number - 1 do
		local attr_text = U3DObject(item_manager.transform:GetChild(i).gameObject)
		self.attr_list[i + 1] = attr_text
	end
end

function TipsRingInfoView:CloseView()
	self:Close()
end

function TipsRingInfoView:OpenCallBack()
	local ring_info = MarriageData.Instance:GetRingCfg()
	local attrs = CommonDataManager.GetAttributteByClass(ring_info, true)
	local capability = CommonDataManager.GetCapability(attrs)
	local item_cfg = ItemData.Instance:GetItemConfig(ring_info.equip_id)

	self.ring_power:SetValue(capability)
	self.ring_star:SetValue(ring_info.star)
	self.ring_name:SetValue(item_cfg.name)

	local item_cell_data = {}
	item_cell_data.item_id = ring_info.equip_id

	self.item_cell:SetData(item_cell_data)

	local count = 1
	for k,v in pairs(attrs) do
		if v > 0 then
			local attr_name = ToColorStr(CommonDataManager.GetAttrName(k)..":  ", TEXT_COLOR.YELLOW)
			local attr_value = ToColorStr(v, TEXT_COLOR.GREEN)
			self.attr_list[count].text.text = attr_name..attr_value
			count = count + 1
		end
	end
	if count <= #self.attr_list then
		for i=count,#self.attr_list do
			self.attr_list[i].text.text = ""
		end
	end
end

