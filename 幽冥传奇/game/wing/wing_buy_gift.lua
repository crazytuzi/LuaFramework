
WindBuyGiftView = WindBuyGiftView or BaseClass(XuiBaseView)

function WindBuyGiftView:__init()
	self.config_tab = {
		{"wing_ui_cfg", 4, {0}}
	}
	self.item_id = nil
	self.item_cell = nil
	self.on_cfg_listen = false
	self.ok_call_back = nil
	self.item_config_bind = BindTool.Bind(self.ItemConfigCallBack, self)

	self:SetIsAnyClickClose(true)
	self:SetModal(true)
end

function WindBuyGiftView:__delete()
	WindBuyGiftView.Instance = nil
end

function WindBuyGiftView:ReleaseCallBack()
	self.item_id = nil
	self.on_cfg_listen = false
	self.ok_call_back = nil

	if nil ~= self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	if ItemData.Instance then
		ItemData.Instance:UnNotifyItemConfigCallBack(self.item_config_bind)
	end
end

function WindBuyGiftView:OpenCallBack()
end

function WindBuyGiftView:CloseCallBack()
	self.ok_call_back = nil
end

function WindBuyGiftView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateItemCell()
		XUI.RichTextSetCenter(self.node_t_list.rich_text.node)
		XUI.AddClickEventListener(self.node_t_list.btn_OK.node, BindTool.Bind1(self.OnClickOK, self))
		XUI.AddClickEventListener(self.node_t_list.btn_cancel.node, BindTool.Bind1(self.OnClickCancel, self))
	end
end

function WindBuyGiftView:OnFlush(param_t, index)
	local item_config = ItemData.Instance:GetItemConfig(self.item_id)
	if nil == item_config then
		if self.on_cfg_listen == false then
			ItemData.Instance:NotifyItemConfigCallBack(self.item_config_bind)
			self.on_cfg_listen = true
		end
		return
	end

	self.node_t_list.img_cost_type.node:loadTexture(ResPath.GetCommon("gold"))

	local item_data = {item_id = self.item_id, num = 0, is_bind = 0}
	self.item_cell:SetData(item_data)

	self.node_t_list.lbl_item_name.node:setString(item_config.name)
	self.node_t_list.lbl_item_name.node:setColor(Str2C3b(string.sub(string.format("%06x", item_config.color), 1, 6)))

	self.node_t_list.label_cost.node:setString(self.cost)
	RichTextUtil.ParseRichText(self.node_t_list.rich_text.node, self.text)
end

function WindBuyGiftView:SetViewData(item_id, cost, ok_call_back, text)
	XuiBaseView.Open(self)
	self.item_id = item_id
	self.cost = cost
	self.text = text
	self.ok_call_back = ok_call_back
	self:Flush()
end

--创建物品格子
function WindBuyGiftView:CreateItemCell()
	if self.item_cell then return end

	local item_cell = BaseCell.New()
	item_cell:SetPosition(self.ph_list.ph_cell.x, self.ph_list.ph_cell.y)
	item_cell:SetCellBg(ResPath.GetCommon("cell_100"))
	item_cell:GetCell():setAnchorPoint(0.5, 0.5)
	item_cell:SetIsShowTips(true)
	self.node_t_list.layout_buy_wing_gift.node:addChild(item_cell:GetCell(), 200, 200)
	self.item_cell = item_cell
end

--点击OK
function WindBuyGiftView:OnClickOK()
	if self.ok_call_back then
		self.ok_call_back()
	end
	self:Close()
end

function WindBuyGiftView:OnClickCancel()
	self:Close()
end

function WindBuyGiftView:ItemConfigCallBack(item_config_t)
	for k,v in pairs(item_config_t) do
		if v.item_id == self.item_id then
			self:Flush()
			ItemData.Instance:UnNotifyItemConfigCallBack(self.item_config_bind)
			self.on_cfg_listen = false
			break
		end
	end
end