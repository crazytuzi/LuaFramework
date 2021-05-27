-- VIP-特权
VipView = VipView or BaseClass(XuiBaseView)

function VipView:InitPrivilegeView()
	self:CreatePrivilegeList()
end

function VipView:DeletePrivilegeView()
	if self.privilege_list then
		self.privilege_list:DeleteMe()
		self.privilege_list = nil
	end
end

function VipView:OnFlushPrivilegeView()
end

function VipView:CreatePrivilegeList()
	if self.privilege_list ~= nil then return end

	local ph = self.ph_list.ph_privilege_list
	local privilege_list = ListView.New()
	privilege_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, VipPrivilegeRender, nil, nil, self.ph_list.ph_privilege_item)
	privilege_list:SetItemsInterval(0)
	privilege_list:SetMargin(1)
	self.node_t_list.layout_vip_privilege.node:addChild(privilege_list:GetView(), 9)
	self.privilege_list = privilege_list
	-- 层次修复
	self.node_t_list.img_vip_repair_1.node:setLocalZOrder(10)
	self.node_t_list.img_vip_repair_2.node:setLocalZOrder(10)

	local data = {}
	for k,v in ipairs(VipPrivilegesCfg) do
		for k_2,v_2 in pairs(v) do
			if data[k_2] == nil then
				data[k_2] = {}
			end
			data[k_2][k] = v_2
		end
	end
	local privilege_data = {}
	for k,v in pairs(data) do
		if PrivilegeDescFormat[k] then
			local item_data = {type = k, param = v, order = PrivilegeDescFormat[k].order}
			table.insert(privilege_data, item_data)
		end
	end
	table.sort(privilege_data, SortTools.KeyLowerSorter("order"))

	privilege_list:SetDataList(privilege_data)
	privilege_list:SetJumpDirection(ListView.Top)
end



----------------------------------------------------
-- VipPrivilegeRender
----------------------------------------------------
VipPrivilegeRender = VipPrivilegeRender or BaseClass(BaseRender)

function VipPrivilegeRender:__init(w, h)
	self.param_num = nil
	self.bg_img_list = {}
	self.show_list = {}
end

function VipPrivilegeRender:__delete()
	self.bg_img_list = {}
	self.show_list = {}

	if self.param_num then
		self.param_num:DeleteMe()
		self.param_num = nil
	end
end

function VipPrivilegeRender:CreateChild()
	BaseRender.CreateChild(self)

	self.lbl_list_begin = self.node_tree.lbl_list_begin.node
	self:ShowDesc()
end

function VipPrivilegeRender:OnFlush()
	if self.data == nil then return end

end

function VipPrivilegeRender:CreateSelectEffect()
end

function VipPrivilegeRender:ShowDesc()
	if self.data == nil or PrivilegeDescFormat == nil then return end

	local privilege_cfg = PrivilegeDescFormat[self.data.type]
	if privilege_cfg == nil then return end

	self.lbl_list_begin:setString(privilege_cfg.title)
	self.lbl_list_begin:setColor(COLOR3B.DULL_GOLD)
	
	for i,v in ipairs(self.data.param) do
		if self.bg_img_list[i] == nil then
			local bg = XUI.CreateImageView(167 + 67 * (i - 1), 23, ResPath.GetVipResPath("vip_privilege_block"), true)
			self.view:addChild(bg, -1)
			self.bg_img_list[i] = bg
		end

		local x, y = self.bg_img_list[i]:getPosition()
		if self.show_list[i] ~= nil then
			self.show_list[i]:removefromparent()
			self.show_list[i] = nil
		end

		local show_node = nil
		if privilege_cfg.show_type == 1 then
			local res_path = ""
			if v == 1 then
				res_path = ResPath.GetVipResPath("vip_img_right")
			else
				res_path = ResPath.GetVipResPath("vip_img_error")
			end
			
			show_node = XUI.CreateImageView(x, y, res_path, true)
			
		elseif privilege_cfg.show_type == 2 then
			show_node = XUI.CreateText(x, y, 68, 20, 1, "", nil, 18, COLOR3B.OLIVE)
			show_node:setString(string.format(privilege_cfg.format_str, v))

		elseif privilege_cfg.show_type == 3 then
			show_node = XUI.CreateText(x, y, 68, 40, 1, "", nil, 18, COLOR3B.OLIVE)
			local buff_cfg = StdBuff[v.id]
			if buff_cfg then
				show_node:setString(string.format(privilege_cfg.format_str, buff_cfg.value + 1, buff_cfg.interval / 3600))
			end
		end

		if show_node ~= nil then
			self.view:addChild(show_node, 100)
			self.show_list[i] = show_node
		end
	end
end