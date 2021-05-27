EquipmentView = EquipmentView or BaseClass(XuiBaseView)

function EquipmentView:InitFulingView()
	self.main_eq_series = nil
	self.mate_eq_series = nil

	self:CreateAllFulingCells()

	XUI.AddClickEventListener(self.node_t_list.btn_fl_add_main.node, BindTool.Bind(self.OnClickAddMainEq, self))
	XUI.AddClickEventListener(self.node_t_list.btn_fl_add_mate.node, BindTool.Bind(self.OnClickAddMateEq, self))
	XUI.AddClickEventListener(self.node_t_list.btn_fuling_tips.node, BindTool.Bind(self.OnClickFulingTips, self))
	XUI.AddClickEventListener(self.node_t_list.btn_fl.node, BindTool.Bind(self.OnClickFuling, self))

	local prog_node = XUI.CreateLoadingBar(362.85, 92, ResPath.GetCommon("prog_104_progress"), XUI.IS_PLIST)
	self.node_t_list.layout_fuling.node:addChild(prog_node, 99)
	self.fuling_progressbar = ProgressBar.New()
	self.fuling_progressbar:SetView(prog_node)
	self.fuling_progressbar:SetTailEffect(991, nil, true)
	self.fuling_progressbar:SetEffectOffsetX(-20)

	self.node_t_list.lbl_fl_prog.node:setLocalZOrder(100)

	local ph = self.ph_list.ph_fl_cur_attr
	self.cur_attr_view = AttrView.New(ph.w, 28, 20, ResPath.GetCommon("img9_115"), true)
	self.cur_attr_view:SetTextAlignment(RichHAlignment.HA_LEFT, RichVAlignment.VA_CENTER)
	self.cur_attr_view:SetItemInterval(2)
	self.cur_attr_view:SetDefTitleText(Language.Common.No)
	self.cur_attr_view:GetView():setPosition(ph.x, ph.y)
	self.cur_attr_view:GetView():setAnchorPoint(0.5, 0.5)
	self.node_t_list.layout_fuling.node:addChild(self.cur_attr_view:GetView(), 10)

	ph = self.ph_list.ph_fl_now_attr
	self.fl_now_attr_view = AttrView.New(ph.w, 28, 20, ResPath.GetCommon("img9_115"), true)
	self.fl_now_attr_view:SetTextAlignment(RichHAlignment.HA_LEFT, RichVAlignment.VA_CENTER)
	self.fl_now_attr_view:SetItemInterval(2)
	self.fl_now_attr_view:SetDefTitleText(Language.Common.No)
	self.fl_now_attr_view:GetView():setPosition(ph.x, ph.y)
	self.fl_now_attr_view:GetView():setAnchorPoint(0.5, 0.5)
	self.node_t_list.layout_fuling.node:addChild(self.fl_now_attr_view:GetView(), 10)

	RichTextUtil.ParseRichText(self.node_t_list.rich_gold_need.node, string.format(Language.Equipment.FulingGoldNeed, "00ff00", 0))
	XUI.RichTextSetCenter(self.node_t_list.rich_fl_tip.node)
	self:FlushFulingPreview()
end

function EquipmentView:DeleteFulingView()
	if nil ~= self.cell_main_eq_select then
		self.cell_main_eq_select:DeleteMe()
		self.cell_main_eq_select = nil
	end
	if nil ~= self.cell_mate_eq_select then
		self.cell_mate_eq_select:DeleteMe()
		self.cell_mate_eq_select = nil
	end
	if nil ~= self.cell_fuling_preview then
		self.cell_fuling_preview:DeleteMe()
		self.cell_fuling_preview = nil
	end
	if nil ~= self.fuling_progressbar then
		self.fuling_progressbar:DeleteMe()
		self.fuling_progressbar = nil
	end
	if nil ~= self.cur_attr_view then
		self.cur_attr_view:DeleteMe()
		self.cur_attr_view = nil
	end
	if nil ~= self.fl_now_attr_view then
		self.fl_now_attr_view:DeleteMe()
		self.fl_now_attr_view = nil
	end

	self:CancelAnimTimer("fuling")

	self.main_eq_series = nil
	self.mate_eq_series = nil
end

function EquipmentView:CreateAllFulingCells()
	self.cell_main_eq_select = self:CreateFulingCell(self.ph_list.ph_cell_fuling_main)
	self.cell_main_eq_select:SetIsShowTips(false)
	self.cell_main_eq_select:SetClickCallBack(BindTool.Bind(self.OnMainEqCellClick, self))
	self.node_t_list.layout_fuling.node:addChild(self.cell_main_eq_select:GetView(), 100)
	self.node_t_list.btn_fl_add_main.node:setLocalZOrder(101)

	self.cell_mate_eq_select = self:CreateFulingCell(self.ph_list.ph_cell_fuling_mate)
	self.cell_mate_eq_select:SetIsShowTips(false)
	self.cell_mate_eq_select:SetClickCallBack(BindTool.Bind(self.OnMateEqCellClick, self))
	self.node_t_list.layout_fuling.node:addChild(self.cell_mate_eq_select:GetView(), 100)
	self.node_t_list.btn_fl_add_mate.node:setLocalZOrder(101)

	self.cell_fuling_preview = self:CreateFulingCell(self.ph_list.ph_cell_fuling_preview)
	self.node_t_list.layout_fuling.node:addChild(self.cell_fuling_preview:GetView(), 100)
	self.node_t_list.img_fl_preview.node:setLocalZOrder(101)
end

function EquipmentView:OnMainEqCellClick()
	TipCtrl.Instance:OpenItem(self.cell_main_eq_select:GetData(), EquipTip.FROM_FULING_TAKE_MAIN)
end

function EquipmentView:OnMateEqCellClick()
	TipCtrl.Instance:OpenItem(self.cell_mate_eq_select:GetData(), EquipTip.FROM_FULING_TAKE_MATE)
end

function EquipmentView:GetCurSelectFulingMainEquipData()
	if self:IsOpen() then
		return self.cell_main_eq_select and self.cell_main_eq_select:GetData()
	end
end

function EquipmentView:OnClickFuling()
	local main_eq_data = self.cell_main_eq_select and self.cell_main_eq_select:GetData()
	local mate_eq_data = self.cell_mate_eq_select and self.cell_mate_eq_select:GetData()

	if nil == main_eq_data then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Equipment.FulingNoMainEquip)
		return
	end

	if nil == mate_eq_data then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Equipment.FulingNoMateEquip)
		return
	end

	local equip_data = EquipData.Instance:GetEquipBySeries(main_eq_data.series)
	local is_in_bag = nil ~= equip_data and 0 or 1
	local fl_exp = EquipmentData.GetEqFulingAllExp(mate_eq_data)
	local has_stone = EquipData.GetEquipHasStone(mate_eq_data)
	local has_god = false
	if 0 < fl_exp or has_stone or has_god then
		self.fuling_shift_alert = self.fuling_shift_alert or Alert.New()
		self.fuling_shift_alert:SetLableString(Language.Equipment.FulingMateEquipHaveExpTip)
		self.fuling_shift_alert:SetOkFunc(function()
			EquipmentCtrl.SentEquipFulingReq(is_in_bag, main_eq_data.series, mate_eq_data.series)
		end)
		self.fuling_shift_alert:SetShowCheckBox(false)
		self.fuling_shift_alert:Open()
		return
	end

	EquipmentCtrl.SentEquipFulingReq(is_in_bag, main_eq_data.series, mate_eq_data.series)
end

function EquipmentView:CreateFulingCell(ph)
	local cell = BaseCell.New()
	cell:SetPosition(ph.x, ph.y)
	cell:SetAnchorPoint(0.5, 0.5)
	cell:SetSkinStyle({bg = ResPath.GetCommon("cell_107")})
	return cell
end

function EquipmentView:OnClickAddMainEq()
	EquipmentCtrl.Instance:OpenItem(EquipTip.FROM_FULING_TO_MAIN, self.cell_mate_eq_select:GetData())
end

function EquipmentView:OnClickAddMateEq()
	EquipmentCtrl.Instance:OpenItem(EquipTip.FROM_FULING_TO_MATE, self.cell_main_eq_select:GetData())
end

function EquipmentView:OnClickFulingTips()
	DescTip.Instance:SetContent(Language.Equipment.FulingDetail, Language.Equipment.FulingTitle)
end

function EquipmentView:SetFulingMainCellData(data)
	self.main_eq_series = data and data.series
	self:FlushFulingPreview()
end

function EquipmentView:SetFulingMateCellData(data)
	self.mate_eq_series = data and data.series
	self:FlushFulingPreview()
end

function EquipmentView:FlushFulingPreview(flush_progress)
	if nil == flush_progress then
		flush_progress = true
	end

	local main_data = EquipData.GetEquipInBagOrEquip(self.main_eq_series)
	local mate_data = EquipData.GetEquipInBagOrEquip(self.mate_eq_series)
	local preview_data = EquipmentData.GetMateFulingPreviewData(main_data, mate_data)
	local money = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BIND_COIN)
	local circles = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	self.cell_main_eq_select:SetData(main_data)
	self.cell_mate_eq_select:SetData(mate_data)
	self.node_t_list.btn_fl_add_main.node:setVisible(nil == main_data)
	self.node_t_list.btn_fl_add_mate.node:setVisible(nil == mate_data)

	local rich_gold_need_txt = string.format(Language.Equipment.FulingGoldNeed, "00ff00", 0)
	local rich_fl_tip_txt = ""
	local rich_fl_cur_attr_txt = Language.Common.No
	local rich_fl_now_attr_txt = Language.Common.No
	local rich_zs_need_txt = ""
	local cur_attr_cfg = nil
	local now_attr_cfg = nil

	if nil == mate_data then
		self.mate_eq_series = nil
	end

	if nil ~= main_data then
		local item_cfg = ItemData.Instance:GetItemConfig(main_data.item_id)
		local equip_name = EquipTip.GetEquipName(item_cfg, main_data)
		local limit_level, circle_level = ItemData.GetItemLevel(main_data.item_id)
		local is_max_level = EquipmentData.IsFulingLevelMax(main_data)

		local need_money = EquipmentData.GetFulingConsumeMoney(1, item_cfg.type, circle_level, main_data.fuling_level)

		rich_gold_need_txt = string.format(Language.Equipment.FulingGoldNeed, money >= need_money and "00ff00" or "ff0000", need_money)
		if nil ~= item_cfg then
			cur_attr_cfg = EquipmentData.GetSpiritSlotStrongAttrsCfg(main_data)
			now_attr_cfg = EquipmentData.GetSpiritSlotStrongAttrsCfg(preview_data)
			if true == is_max_level then
				rich_fl_tip_txt = string.format(Language.Equipment.FulingEquipMaxTip, string.format("%06x", item_cfg.color), equip_name)
			else
				rich_fl_tip_txt = string.format(Language.Equipment.FulingTip, string.format("%06x", item_cfg.color), equip_name)
			end
			local _, need_circle = ItemData.GetItemLevel(main_data.item_id)
			rich_zs_need_txt = string.format(Language.Equipment.FulingZSNeed, circles >= need_circle and "00ff00" or "ff0000", need_circle)
		end

		if nil ~= cur_attr_cfg then
			rich_fl_cur_attr_txt = RoleData.FormatAttrContent(cur_attr_cfg)
		end

		if nil ~= now_attr_cfg then
			rich_fl_now_attr_txt = RoleData.FormatAttrContent(now_attr_cfg, {value_str_color = COLOR3B.GREEN})
		end
	else
		self.main_eq_series = nil
	end

	self.cell_fuling_preview:SetData(preview_data)
	self.node_t_list.img_fl_preview.node:setVisible(nil == preview_data)
	RichTextUtil.ParseRichText(self.node_t_list.rich_gold_need.node, rich_gold_need_txt)
	RichTextUtil.ParseRichText(self.node_t_list.rich_fl_tip.node, rich_fl_tip_txt)
	-- RichTextUtil.ParseRichText(self.node_t_list.rich_fl_cur_attr.node, rich_fl_cur_attr_txt, 22, COLOR3B.OLIVE)
	-- RichTextUtil.ParseRichText(self.node_t_list.rich_fl_now_attr.node, rich_fl_now_attr_txt, 22, COLOR3B.OLIVE)
	RichTextUtil.ParseRichText(self.node_t_list.rich_zs_need.node, rich_zs_need_txt)
	self.cur_attr_view:SetData(cur_attr_cfg)
	self.fl_now_attr_view:SetData(now_attr_cfg)

	if flush_progress then
		self:ShowProgressAnim("fuling", main_data, preview_data, self.fuling_progressbar, self.node_t_list.lbl_fl_prog.node)
	end
end

local prog_anim_cache = {
}
function EquipmentView:ShowProgressAnim(key, main_data, preview_data, progressbar, prog_txt)
	if nil == key then
		return
	end

	if nil == main_data then
		self:CancelAnimTimer(key)
		progressbar:SetPercent(0)
		prog_txt:setString("")
		return false
	end

	local item_cfg = ItemData.Instance:GetItemConfig(main_data.item_id)
	if nil == item_cfg then
		return false
	end

	local start_level = main_data.fuling_level
	local start_exp = main_data.fuling_exp
	
	local limit_level, circle_level = ItemData.GetItemLevel(main_data.item_id)
	local need_exp = EquipmentData.GetFulingNextExp(item_cfg.type, circle_level, start_level)

	if nil == preview_data or nil == need_exp then
		self:CancelAnimTimer(key)
		local str = need_exp and start_exp .. "/" .. need_exp or Language.Common.MaxLv
		local lbl_fl_prog_txt = string.format("Lv.%d (%s)", start_level, str)
		progressbar:SetPercent(need_exp and math.floor(start_exp * 100 / need_exp) or 100)
		prog_txt:setString(lbl_fl_prog_txt)
		return false
	end

	local end_level = preview_data.fuling_level
	local end_exp = preview_data.fuling_exp
	if prog_anim_cache[key]
		and prog_anim_cache[key].start_level == main_data.fuling_level
		and prog_anim_cache[key].start_exp == main_data.fuling_exp
		and prog_anim_cache[key].end_level == preview_data.fuling_level
		and prog_anim_cache[key].end_exp == preview_data.fuling_exp
		and prog_anim_cache[key].item_id == main_data.item_id then
		return true
	end

	local cur_percent = math.floor(start_exp * 100 / need_exp)
	local add_val = 5		-- 每帧增加的经验进度

	self:CancelAnimTimer(key)
	if nil == prog_anim_cache[key] then
		prog_anim_cache[key] = {}
	end
	prog_anim_cache[key].timer = GlobalTimerQuest:AddTimesTimer(function()
		cur_percent = cur_percent + add_val
		if 100 <= cur_percent then
			cur_percent = cur_percent - 100
			start_level = start_level + 1
			if start_level > end_level then
				self:CancelAnimTimer(key)
				return
			end
		end
		local need_exp = EquipmentData.GetFulingNextExp(item_cfg.type, circle_level, start_level)
		if need_exp then
			start_exp = math.floor(cur_percent / 100 * need_exp)
			if start_level == end_level and start_exp >= end_exp then
				start_exp = end_exp
				cur_percent = math.floor(start_exp * 100 / need_exp)
				self:CancelAnimTimer(key)
			end
		else
			start_exp = 0
			cur_percent = 100
			self:CancelAnimTimer(key)
		end
		local str = need_exp and start_exp .. "/" .. need_exp or Language.Common.MaxLv
		local lbl_fl_prog_txt = string.format("Lv.%d (%s)", start_level, str)
		progressbar:SetPercent(cur_percent)
		prog_txt:setString(lbl_fl_prog_txt)
	end, 0, 9999999)

	prog_anim_cache[key].start_level = main_data.fuling_level
	prog_anim_cache[key].start_exp = main_data.fuling_exp
	prog_anim_cache[key].end_level = preview_data.fuling_level
	prog_anim_cache[key].end_exp = preview_data.fuling_exp
	prog_anim_cache[key].item_id = main_data.item_id

	return true
end

function EquipmentView:CancelAnimTimer(key)
	if prog_anim_cache[key] and prog_anim_cache[key].timer then
		GlobalTimerQuest:CancelQuest(prog_anim_cache[key].timer)
		prog_anim_cache[key] = nil
	end
end

function EquipmentView:OnFlushFuling(param_t)
	for k,v in pairs(param_t) do
		if k == "all" or k == "eq_change" or k == "bag_item_change" then
			self:FlushFulingPreview()
		elseif "item_config" or "bing_coin_change" then
			self:FlushFulingPreview(false)
		end
	end
end
