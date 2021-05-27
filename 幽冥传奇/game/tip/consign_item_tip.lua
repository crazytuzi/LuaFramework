-- 寄售tips
ConsignTipView = ConsignTipView or BaseClass(XuiBaseView)

ConsignTipView.EditBoxInitNum = 2

function ConsignTipView:__init()
	--self.texture_path_list[1] = 'res/xui/guide.png'
	self.config_tab = {
		{"itemtip_ui_cfg", 21, {0}}
	}
	self.series = nil
	self.type = 1
	self.is_any_click_close = true
end

function ConsignTipView:__delete()

	if nil ~= self.consign_cell_data then
		self.consign_cell_data = nil
	end

end

function ConsignTipView:ReleaseCallBack()
	if nil ~= self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end

	if self.edit_libaoid then
		self.edit_libaoid:removeFromParent()
		self.edit_libaoid = nil
	end

end

function ConsignTipView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateEditYuanbao()

		self.lbl_item_name = self.node_t_list.itemname_txt.node
		self.lbl_type = self.node_t_list.top_txt1.node
		self.lbl_level = self.node_t_list.top_txt2.node
		self.layout_content_down = self.node_t_list.layout_content_down.node
		self.layout_content_top = self.node_t_list.layout_content_top.node
		self.cell = BaseCell.New()
		self.layout_content_top:addChild(self.cell:GetCell(), 200)
		local ph_itemcell = self.ph_list.ph_itemcell --占位符
		self.cell:GetCell():setPosition(ph_itemcell.x, ph_itemcell.y)
		self.cell:SetIsShowTips(false)


		XUI.AddClickEventListener(self.node_t_list.btn_shelves.node, BindTool.Bind1(self.OnClickShelvesItemHandler, self))
		XUI.AddClickEventListener(self.node_t_list.btn_remove.node, BindTool.Bind1(self.OnClickRemoveHandler, self))
	end
end


function ConsignTipView:CloseCallback()
	self.fromView = EquipTip.FROM_BAG_ON_BAG_SALE
end

function ConsignTipView:SetData(data, fromView, param_t)
	if not data then
		return
	end
	
	self.data = data
	self.type = param_t.data
	self:Open()
	self.fromView = fromView or EquipTip.FROM_BAG_ON_BAG_SALE
	self:Flush()
end

function ConsignTipView:OnFlush(param_t, index)
	self.consign_cell_data = self.data
	self.cell:SetData(self.data)
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	-- print(item_cfg.desc)
	self.lbl_item_name:setString(item_cfg.name)
	self.lbl_item_name:setColor(Str2C3b(string.format("%06x", item_cfg.color)))
	self.lbl_level:setString(string.format(Language.Tip.DengJi, 0))
	self.lbl_level:setColor(COLOR3B.GREEN)
	RichTextUtil.ParseRichText(self.node_t_list.rich_item_dec.node, item_cfg.desc)
	self.lbl_type:setString(string.format(Language.Tip.ZhuangBeiLeiXing, ItemData.GetItemTypeName(item_cfg.type)))
	if item_cfg.conds then
			for k,v in pairs(item_cfg.conds) do
				if v.cond == ItemData.UseCondition.ucMinCircle then
					if v.value > 0 then
						self.lbl_level:setString(string.format(Language.Tip.ZhuanDengJi, v.value))
						if not RoleData.Instance:IsEnoughZhuan(v.value) then
							self.lbl_level:setColor(COLOR3B.RED)
						else
							self.lbl_level:setColor(COLOR3B.GREEN)
						end
					end
				else
					if v.cond == ItemData.UseCondition.ucLevel then
						self.lbl_level:setString(string.format(Language.Tip.DengJi, v.value))
						if not RoleData.Instance:IsEnoughLevelZhuan(v.value) then
							self.lbl_level:setColor(COLOR3B.RED)
						else
							self.lbl_level:setColor(COLOR3B.GREEN)
						end
					end
				end
			end
		end
	
	
	self.node_t_list.layout_down_shelf.node:setVisible(self.type ~= 1)
	self.node_t_list.layout_stall.node:setVisible(self.type == 1)
	self.edit_libaoid:setVisible(self.type == 1)


	local txt_time = ""
	if self.type ~= 1 then
		if self.type.remain_time <= TimeCtrl.Instance:GetServerTime() then
			txt_time = Language.Consign.TimeOut
		else
			local time_tab = TimeUtil.Format2TableDHM(self.type.remain_time - TimeCtrl.Instance:GetServerTime())
			txt_time = string.format(Language.Consign.TimeTips, time_tab.day, time_tab.hour, time_tab.min)
		end
	end
	self.node_t_list.txt_remaind_time.node:setString(txt_time)

end

function ConsignTipView:CreateEditYuanbao()
	--设置用户名输入框
	self.view = view
	local ph = self.ph_list.ph_edit_box
	self.edit_libaoid = XUI.CreateEditBox(ph.x + 120, ph.y + 10, ph.w, ph.h, font, input_mode, input_flag, ResPath.GetCommon("img9_101"), is_plist, cap_rec)	--cc.rect(6, 12, 7, 3)self.view.node_t_list.edit_serial_number.node
	self.edit_libaoid:setPlaceHolder(ConsignTipView.EditBoxInitNum)
	self.node_t_list.layout_consign_tips.node:addChild(self.edit_libaoid, 9)
	--self.edit_yuanbao = self.node_t_list.edit_yuanbao.node
	--self.edit_yuanbao:setFontSize(22)
	--self.edit_yuanbao:setFontColor(COLOR3B.G_W)
	--self.edit_yuanbao:setText(ConsignTipView.EditBoxInitNum)
	--self.edit_yuanbao:registerScriptEditBoxHandler(BindTool.Bind(self.ExamineEditYuanbaoNum, self, self.edit_yuanbao, 9))
end

-- 上架商品
function ConsignTipView:OnClickShelvesItemHandler()
	if nil == self.consign_cell_data then
		SysMsgCtrl.Instance:ErrorRemind(Language.Consign.ConsignDataNil)
		return
	end

	local my_consign_data = ConsignData.Instance:GetMyConsignItemsData()
	if my_consign_data.item_num >= ConsignData.MaxConsignNum then
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Consign.ConsignMax, my_consign_data.item_num))
		return
	end

	local price = tonumber(self.edit_libaoid:getText()) or ConsignTipView.EditBoxInitNum
	if price <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Consign.PriceIsZero)
	else
		ConsignCtrl.Instance:SendConsignItemReq(self.consign_cell_data.series, price)
		ConsignCtrl.Instance:SendSearchConsignItemsReq()
		ConsignCtrl.Instance:SendGetMyConsignItemsReq()
	end

	self:Close()
end

function ConsignTipView:OnClickRemoveHandler()
	if nil == self.data then return end
	local operation = 0
	if self.type.remain_time <= TimeCtrl.Instance:GetServerTime() then operation = 1 end
	ConsignCtrl.Instance:SendCancelConsignItemReq(self.type.item_data.series, self.type.item_handle, operation)

	self:Close()
end

