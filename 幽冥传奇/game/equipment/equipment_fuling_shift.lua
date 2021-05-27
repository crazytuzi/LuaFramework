EquipmentView = EquipmentView or BaseClass(XuiBaseView)

function EquipmentView:InitFulingShiftView()
	self.shift_eq_series = nil
	self.aim_eq_series = nil

	self:CreateAllShiftCells()

	XUI.AddClickEventListener(self.node_t_list.btn_shift_eq.node, BindTool.Bind(self.OnClickAddMainShiftEq, self))
	XUI.AddClickEventListener(self.node_t_list.btn_shift_aim_eq.node, BindTool.Bind(self.OnClickAddMateShiftEq, self))
	XUI.AddClickEventListener(self.node_t_list.btn_shift_tips.node, BindTool.Bind(self.OnClickShiftTips, self))
	XUI.AddClickEventListener(self.node_t_list.btn_fl_shift.node, BindTool.Bind(self.OnClickShift, self))

	local prog_node = XUI.CreateLoadingBar(362.85, 92, ResPath.GetCommon("prog_104_progress"), XUI.IS_PLIST)
	self.node_t_list.layout_fl_shift.node:addChild(prog_node, 99)
	self.shift_progressbar = ProgressBar.New()
	self.shift_progressbar:SetView(prog_node)
	self.shift_progressbar:SetTailEffect(991, nil, true)
	self.shift_progressbar:SetEffectOffsetX(-20)

	self.node_t_list.lbl_shift_prog.node:setLocalZOrder(100)

	local ph = self.ph_list.ph_shift_cur_attr
	self.shift_cur_attr_view = AttrView.New(ph.w, 28, 20, ResPath.GetCommon("img9_115"), true)
	self.shift_cur_attr_view:SetTextAlignment(RichHAlignment.HA_LEFT, RichVAlignment.VA_CENTER)
	self.shift_cur_attr_view:SetItemInterval(2)
	self.shift_cur_attr_view:SetDefTitleText(Language.Common.No)
	self.shift_cur_attr_view:GetView():setPosition(ph.x, ph.y)
	self.shift_cur_attr_view:GetView():setAnchorPoint(0.5, 0.5)
	self.node_t_list.layout_fl_shift.node:addChild(self.shift_cur_attr_view:GetView(), 10)

	ph = self.ph_list.ph_shift_now_attr
	self.shift_now_attr_view = AttrView.New(ph.w, 28, 20, ResPath.GetCommon("img9_115"), true)
	self.shift_now_attr_view:SetTextAlignment(RichHAlignment.HA_LEFT, RichVAlignment.VA_CENTER)
	self.shift_now_attr_view:SetItemInterval(2)
	self.shift_now_attr_view:SetDefTitleText(Language.Common.No)
	self.shift_now_attr_view:GetView():setPosition(ph.x, ph.y)
	self.shift_now_attr_view:GetView():setAnchorPoint(0.5, 0.5)
	self.node_t_list.layout_fl_shift.node:addChild(self.shift_now_attr_view:GetView(), 10)

	RichTextUtil.ParseRichText(self.node_t_list.rich_shift_gold_need.node, string.format(Language.Equipment.FulingGoldNeed, "00ff00", 0))
	XUI.RichTextSetCenter(self.node_t_list.rich_shift_tip.node)
	self:FlushShiftPreview()
end

function EquipmentView:DeleteFulingShiftView()
	if nil ~= self.cell_shift_eq then
		self.cell_shift_eq:DeleteMe()
		self.cell_shift_eq = nil
	end
	if nil ~= self.cell_shift_aim_eq then
		self.cell_shift_aim_eq:DeleteMe()
		self.cell_shift_aim_eq = nil
	end
	if nil ~= self.cell_shift_preview then
		self.cell_shift_preview:DeleteMe()
		self.cell_shift_preview = nil
	end
	
	if nil ~= self.shift_progressbar then
		self.shift_progressbar:DeleteMe()
		self.shift_progressbar = nil
	end
	
	if nil ~= self.fuling_shift_alert then
		self.fuling_shift_alert:DeleteMe()
		self.fuling_shift_alert = nil
	end
	
	if nil ~= self.shift_cur_attr_view then
		self.shift_cur_attr_view:DeleteMe()
		self.shift_cur_attr_view = nil
	end
	
	if nil ~= self.shift_now_attr_view then
		self.shift_now_attr_view:DeleteMe()
		self.shift_now_attr_view = nil
	end

	self:CancelAnimTimer("fuling_shift")

	self.shift_eq_series = nil
	self.aim_eq_series = nil
end

function EquipmentView:OnFlushFulingShift(param_t)
	for k,v in pairs(param_t) do
		if k == "all" or k == "eq_change" or k == "bag_item_change" then
			self:FlushShiftPreview()
		elseif "item_config" or "bing_coin_change" then
			self:FlushShiftPreview(false)
		end
	end
end

function EquipmentView:CreateAllShiftCells()
	self.cell_shift_eq = self:CreateShiftCell(self.ph_list.ph_cell_fl_shift_eq)
	self.cell_shift_eq:SetIsShowTips(false)
	self.cell_shift_eq:SetClickCallBack(BindTool.Bind(self.OnMainShiftEqCellClick, self))
	self.node_t_list.layout_fl_shift.node:addChild(self.cell_shift_eq:GetView(), 100)
	self.node_t_list.btn_shift_eq.node:setLocalZOrder(101)

	self.cell_shift_aim_eq = self:CreateShiftCell(self.ph_list.ph_cell_fl_shift_aim_eq)
	self.cell_shift_aim_eq:SetIsShowTips(false)
	self.cell_shift_aim_eq:SetClickCallBack(BindTool.Bind(self.OnMateShiftEqCellClick, self))
	self.node_t_list.layout_fl_shift.node:addChild(self.cell_shift_aim_eq:GetView(), 100)
	self.node_t_list.btn_shift_aim_eq.node:setLocalZOrder(101)

	self.cell_shift_preview = self:CreateShiftCell(self.ph_list.ph_cell_fl_shift_preview)
	self.node_t_list.layout_fl_shift.node:addChild(self.cell_shift_preview:GetView(), 100)
	self.node_t_list.img_shift_preview.node:setLocalZOrder(101)
end

function EquipmentView:OnMainShiftEqCellClick()
	TipCtrl.Instance:OpenItem(self.cell_shift_eq:GetData(), EquipTip.FROM_FULING_SHIFT_TAKE_MAIN)
end

function EquipmentView:OnMateShiftEqCellClick()
	TipCtrl.Instance:OpenItem(self.cell_shift_aim_eq:GetData(), EquipTip.FROM_FULING_SHIFT_TAKE_MATE)
end

function EquipmentView:CreateShiftCell(ph)
	local cell = BaseCell.New()
	cell:SetPosition(ph.x, ph.y)
	cell:SetAnchorPoint(0.5, 0.5)
	cell:SetSkinStyle({bg = ResPath.GetCommon("cell_107")})
	return cell
end

function EquipmentView:OnClickAddMainShiftEq()
	EquipmentCtrl.Instance:OpenItem(EquipTip.FROM_FULING_SHIFT_TO_MAIN, self.cell_shift_aim_eq:GetData())
end

function EquipmentView:OnClickAddMateShiftEq()
	EquipmentCtrl.Instance:OpenItem(EquipTip.FROM_FULING_SHIFT_TO_MATE, self.cell_shift_eq:GetData())
end

function EquipmentView:OnClickShiftTips()
	DescTip.Instance:SetContent(Language.Equipment.ShiftDetail, Language.Equipment.ShiftTitle)
end

function EquipmentView:OnClickShift()
	local shift_eq_data = self.cell_shift_eq and self.cell_shift_eq:GetData()
	local shift_aim_eq_data = self.cell_shift_aim_eq and self.cell_shift_aim_eq:GetData()

	if nil == shift_eq_data then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Equipment.FulingNoShiftEquip)
		return
	end

	if nil == shift_aim_eq_data then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Equipment.FulingNoShiftAimEquip)
		return
	end

	local equip_data = EquipData.Instance:GetEquipBySeries(shift_aim_eq_data.series)
	local is_in_bag = nil ~= equip_data and 0 or 1	
	local fl_exp = EquipmentData.GetEqFulingAllExp(shift_aim_eq_data)
	if 0 < fl_exp then
		self.fuling_shift_alert = self.fuling_shift_alert or Alert.New()
		self.fuling_shift_alert:SetLableString(Language.Equipment.FulingAimEquipHaveExpTip)
		self.fuling_shift_alert:SetOkFunc(function()
			EquipmentCtrl.SentEquipFulingShiftReq(is_in_bag, shift_aim_eq_data.series, shift_eq_data.series)
		end)
		self.fuling_shift_alert:SetShowCheckBox(false)
		self.fuling_shift_alert:Open()
		return
	end
	EquipmentCtrl.SentEquipFulingShiftReq(is_in_bag, shift_aim_eq_data.series, shift_eq_data.series)
end

function EquipmentView:FlushShiftPreview(flush_progress)
	if nil == flush_progress then
		flush_progress = true
	end

	local aim_data = EquipData.GetEquipInBagOrEquip(self.aim_eq_series)
	local shift_data = EquipData.GetEquipInBagOrEquip(self.shift_eq_series)
	local preview_data = EquipmentData.GetShiftFulingPreviewData(aim_data, shift_data)
	local money = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BIND_COIN)
	local circles = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	self.cell_shift_aim_eq:SetData(aim_data)
	self.cell_shift_eq:SetData(shift_data)
	self.node_t_list.btn_shift_eq.node:setVisible(nil == shift_data)
	self.node_t_list.btn_shift_aim_eq.node:setVisible(nil == aim_data)

	local rich_shift_gold_need_txt = string.format(Language.Equipment.FulingGoldNeed, "00ff00", 0)
	local rich_shift_tip_txt = ""
	local rich_shift_cur_attr_txt = Language.Common.No
	local rich_shift_now_attr_txt = Language.Common.No
	local rich_shift_zs_need_txt = ""
	local cur_attr_cfg = nil
	local now_attr_cfg = nil

	if nil == shift_data then
		self.shift_eq_series = nil
	end

	if nil ~= aim_data then
		local item_cfg = ItemData.Instance:GetItemConfig(aim_data.item_id)
		local equip_name = EquipTip.GetEquipName(item_cfg, aim_data)
		local limit_level, circle_level = ItemData.GetItemLevel(aim_data.item_id)
		local is_max_level = EquipmentData.IsFulingLevelMax(aim_data)

		local need_money = EquipmentData.GetFulingConsumeMoney(2, item_cfg.type, circle_level, aim_data.fuling_level)

		rich_shift_gold_need_txt = string.format(Language.Equipment.FulingGoldNeed, money >= need_money and "00ff00" or "ff0000", need_money)
		if nil ~= item_cfg then
			cur_attr_cfg = EquipmentData.GetSpiritSlotStrongAttrsCfg(aim_data)
			now_attr_cfg = EquipmentData.GetSpiritSlotStrongAttrsCfg(preview_data)
			if true == is_max_level then
				rich_shift_tip_txt = string.format(Language.Equipment.FulingEquipMaxTip, string.format("%06x", item_cfg.color), equip_name)
			else
				rich_shift_tip_txt = string.format(Language.Equipment.FulingShiftTip, string.format("%06x", item_cfg.color), equip_name)
			end

			local _, need_circle = ItemData.GetItemLevel(aim_data.item_id)
			rich_shift_zs_need_txt = string.format(Language.Equipment.FulingZSNeed, circles >= need_circle and "00ff00" or "ff0000", need_circle)
		end

		if nil ~= cur_attr_cfg then
			rich_shift_cur_attr_txt = RoleData.FormatAttrContent(cur_attr_cfg)
		end
		
		if nil ~= now_attr_cfg then
			rich_shift_now_attr_txt = RoleData.FormatAttrContent(now_attr_cfg, {value_str_color = COLOR3B.GREEN})
		end
	else
		self.aim_eq_series = nil
	end

	self.cell_shift_preview:SetData(preview_data)
	self.node_t_list.img_shift_preview.node:setVisible(nil == preview_data)
	RichTextUtil.ParseRichText(self.node_t_list.rich_shift_gold_need.node, rich_shift_gold_need_txt)
	RichTextUtil.ParseRichText(self.node_t_list.rich_shift_tip.node, rich_shift_tip_txt)
	-- RichTextUtil.ParseRichText(self.node_t_list.rich_shift_cur_attr.node, rich_shift_cur_attr_txt, 22, COLOR3B.OLIVE)
	-- RichTextUtil.ParseRichText(self.node_t_list.rich_shift_now_attr.node, rich_shift_now_attr_txt, 22, COLOR3B.OLIVE)
	RichTextUtil.ParseRichText(self.node_t_list.rich_shift_zs_need.node, rich_shift_zs_need_txt)
	self.shift_cur_attr_view:SetData(cur_attr_cfg)
	self.shift_now_attr_view:SetData(now_attr_cfg)

	if flush_progress then
		self:ShowProgressAnim("fuling_shift", aim_data, preview_data, self.shift_progressbar, self.node_t_list.lbl_shift_prog.node)
	end
end

function EquipmentView:SetFulingShiftMainCellData(data)
	self.shift_eq_series = data and data.series
	self:FlushShiftPreview()
end

function EquipmentView:SetFulingMateShiftCellData(data)
	self.aim_eq_series = data and data.series
	self:FlushShiftPreview()
end
