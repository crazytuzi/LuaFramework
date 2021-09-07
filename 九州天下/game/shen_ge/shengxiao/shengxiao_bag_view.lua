ShengXiaoBagView = ShengXiaoBagView or BaseClass(BaseView)

function ShengXiaoBagView:__init()
	self.ui_config = {"uis/views/shengeview", "ShengXiaoBagView"}
	self.view_layer = UiLayer.Pop
end

function ShengXiaoBagView:__delete()

end

function ShengXiaoBagView:ReleaseCallBack()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
		v = nil
	end
	self.item_cell_list = {}
	self.bottom = nil
	self.compose_desc = nil
	self.button = nil
	self.can_compose = nil

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	self.select_index = 0
end

function ShengXiaoBagView:LoadCallBack()
	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("OnClickCompose", BindTool.Bind(self.OnClickCompose, self))
	self:ListenEvent("OnClickUse", BindTool.Bind(self.OnClickUse, self))
	self.bottom = self:FindObj("Bottom").toggle_group
	self.button = self:FindObj("BtnCompose")
	self.item_cell_list = {}
	for i = 1, 4 do
		local item_cell = self:FindObj("Item" .. i)
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(item_cell)
		self.item_cell_list[i].root_node.toggle.group = self.bottom
		self.item_cell_list[i]:ListenClick(BindTool.Bind(self.ClickItem, self, i))
	end
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
	self.compose_desc = self:FindVariable("compose_desc")
	self.can_compose = self:FindVariable("can_compose")
	self.can_compose:SetValue(true)
	self.select_index = 0
	self:Flush()
end


function ShengXiaoBagView:ItemDataChangeCallback()
	self:Flush()
end

function ShengXiaoBagView:OpenCallBack()
	self:Flush()

end

function ShengXiaoBagView:ClickItem(i)
	self.select_index = i
	self:FlushDesc()
end

function ShengXiaoBagView:FlushDesc()
	local bag_list = ShengXiaoData.Instance:GetBeadInBagList()
	if self.select_index > 0 and self.select_index < 4 then
		local chose_data = bag_list[self.select_index + 1]
		local compose_item = ComposeData.Instance:GetComposeItem(chose_data.item_id)
		local item_cfg = ItemData.Instance:GetItemConfig(chose_data.item_id)
		local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..item_cfg.name .."</color>"
		local desc = string.format(Language.ShengXiao.PieceCompose, compose_item.stuff_count_1, name_str)
		self.compose_desc:SetValue(desc)
	else
		self.compose_desc:SetValue("")
	end
	self.button.grayscale.GrayScale = self.select_index < 4 and 0 or 255
	self.can_compose:SetValue(self.select_index < 4)
end

function ShengXiaoBagView:OnFlush()
	local bag_list = ShengXiaoData.Instance:GetBeadInBagList()
	for k,v in pairs(bag_list) do
		self.item_cell_list[k]:SetData(v)
		if v.num <= 0 then
			self.item_cell_list[k]:SetIconGrayScale(true)
			self.item_cell_list[k]:ShowQuality(false)
		else
			self.item_cell_list[k]:SetIconGrayScale(false)
			self.item_cell_list[k]:ShowQuality(true)
		end
	end
end

function ShengXiaoBagView:CloseWindow()
	self:Close()
end

function ShengXiaoBagView:OnClickCompose()
	if self.select_index == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.ChoseFirst)
	end
	if self.select_index < 4 then
		local bag_list = ShengXiaoData.Instance:GetBeadInBagList()
		local chose_data = bag_list[self.select_index + 1]
		local compose_item = ComposeData.Instance:GetComposeItem(chose_data.item_id)
		local bag_num = bag_list[self.select_index].num
		-- if bag_num >= compose_item.stuff_count_1 then
			ComposeCtrl.Instance:SendItemCompose(compose_item.producd_seq, 1, 0)
		-- else
			-- SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.NoStuff)
		-- end
	end
end

function ShengXiaoBagView:OnClickUse()
	if self.select_index == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.ChoseFirst)
	end
	local bag_list = ShengXiaoData.Instance:GetBeadInBagList()
	local chose_data = bag_list[self.select_index]
	if chose_data.num > 0 then
		local bag_index = ItemData.Instance:GetItemIndex(chose_data.item_id)
		PackageCtrl.Instance:SendUseItem(bag_index, 1)
	else
		TipsCtrl.Instance:ShowItemGetWayView(chose_data.item_id)
	end
end