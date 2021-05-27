AlertConsumTip = AlertConsumTip or BaseClass(Alert)

function AlertConsumTip:__init()
	self.config_tab = {
		{"dialog_ui_cfg", 6, {0},},
	}
end

function AlertConsumTip:ShowIndexCallBack()
	local item_cfg = ItemData.Instance:GetItemConfig(self.consume_id)
	if item_cfg then
		self.node_t_list.img_icon.node:loadTexture(ResPath.GetItem(item_cfg.icon))
		self.node_t_list.img_icon.node:setScale(0.4)
		local have_num = BagData.Instance:GetItemNumInBagById(item_cfg.item_id)
		self.node_t_list.lbl_consume.node:setString(have_num .. "/" .. self.need_num)
	end
end

function AlertConsumTip:SetConsume(id, num)
	self.consume_id = id
	self.need_num = num
end
