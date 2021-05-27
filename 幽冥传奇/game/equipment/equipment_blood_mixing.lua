EquipmentView = EquipmentView or BaseClass(XuiBaseView)

function EquipmentView:CreateBMView()
	self:CreateBMUI()
end

function EquipmentView:ReleaseBMView()
	self:ReleaseBMUI()
end

function EquipmentView:ReleaseBMUI()
	if self.select_bm_cell then
		self.select_bm_cell:DeleteMe()
		self.select_bm_cell = nil
	end
	
	for k, v in pairs(self.bm_cell_list or {}) do
		v:DeleteMe()
	end
	self.bm_cell_list = nil
	
	if self.bm_cell1 then
		self.bm_cell1:DeleteMe()
		self.bm_cell1 = nil
	end
	
	if self.bm_cell2 then
		self.bm_cell2:DeleteMe()
		self.bm_cell2 = nil
	end
	
	if self.cur_bm_attr_view then
		self.cur_bm_attr_view:DeleteMe()
		self.cur_bm_attr_view = nil
	end
	
	if self.next_bm_attr_view then
		self.next_bm_attr_view:DeleteMe()
		self.next_bm_attr_view = nil
	end
	
end

function EquipmentView:CreateBMUI()
	local ph = self.ph_list.ph_bmcell_select
	self.select_bm_cell = self:CreateBMCell(ph, 1, true)
	self.select_bm_index = 1
	
	self.bm_cell_list = {}
	for i = 1, 10 do
		ph = self.ph_list["ph_bmcell_" .. i]
		local cell = self:CreateBMCell(ph, i, false)	
		cell:SetShowTips(false)
		cell:AddClickEventListener(BindTool.Bind(self.OnClickBMCell, self), true)
		table.insert(self.bm_cell_list, cell)
	end
	
	self.cur_bm_attr_view = AttrView.New(215, 25, 20, ResPath.GetCommon("img9_115"), true)
	self.cur_bm_attr_view:GetView():setPosition(85, 315)
	self.cur_bm_attr_view:SetDefTitleText(Language.Common.No)
	self.node_t_list.layout_blood_mixing.node:addChild(self.cur_bm_attr_view:GetView(), 10)
	
	self.next_bm_attr_view = AttrView.New(215, 25, 20, ResPath.GetCommon("img9_115"), true)
	self.next_bm_attr_view:GetView():setPosition(400, 315)
	self.next_bm_attr_view:SetDefTitleText(Language.Common.MaxLevel)
	self.node_t_list.layout_blood_mixing.node:addChild(self.next_bm_attr_view:GetView(), 10)
	
	self.txt_get_bm_stuff = RichTextUtil.CreateLinkText("", 20, COLOR3B.GREEN)
	self.txt_get_bm_stuff:setPosition(350, 110)
	self.node_t_list.layout_blood_mixing.node:addChild(self.txt_get_bm_stuff, 20)
	
	self.node_t_list.btn_bm_upgrade.node:setTitleFontSize(22)
	self.node_t_list.btn_bm_upgrade.node:setTitleText(Language.Equipment.UpGradeBtnTxt[2])
	XUI.AddClickEventListener(self.node_t_list.btn_bm_upgrade.node, BindTool.Bind(self.OnClickBMUpgrade, self))
	XUI.AddClickEventListener(self.node_t_list.img_bm_plus.node, BindTool.Bind(self.OnClickBMPlus, self))
	XUI.AddClickEventListener(self.txt_get_bm_stuff, BindTool.Bind(self.OnClickGetBMStuff, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_bm_tips.node, function()
		DescTip.Instance:SetContent(Language.Equipment.XuelianDetail, Language.Equipment.XuelianTitle)
	end)
	
	self.node_t_list.rich_need_upgrade.node:setVisible(false)
	self.node_t_list.rich_need_upgrade.node:setVerticalSpace(5)
end

function EquipmentView:CreateBMCell(ph, slot, show_tip)
	local cell = EqBMItem.New()
	cell:SetAnchorPoint(0.5, 0.5)
	cell:SetIndex(slot)
	cell:SetUiConfig(ph, true)
	cell:SetPosition(ph.x, ph.y)
	cell:SetShowTips(show_tip)
	self.node_t_list.layout_blood_mixing.node:addChild(cell:GetView(), 20)
	return cell
end

function EquipmentView:OnFlushBMView(param_t)
	for k, v in pairs(param_t) do
		if k == "all" then
			self:FlushAllBmCell()
			self:FlushBmAttrView()
			self:FlushBmConsume()
			self.node_t_list.img_bm_plus.node:setGrey(RoleRuleData.GetXueLianTipsLevel() <= 0)
		end
	end
end

function EquipmentView:FlushBmConsume()
	local bm_level = self.select_bm_cell:GetData().bm_level
	local cfg = EquipmentData.GetBmStrengthenSlotCfg(self.select_bm_index, bm_level + 1)
	if cfg then
		self:ShowMaxLevelText(false)
		self.node_t_list.btn_bm_upgrade.node:setVisible(true)
		self.txt_get_bm_stuff:setVisible(false)
		local equip = self.select_bm_cell:GetData().equip
		if bm_level == 10 and not EquipmentData.IsWangPeerless(equip and equip.item_id or 0) then
			self.node_t_list.layout_blood_consume.node:setVisible(false)
			XUI.SetButtonEnabled(self.node_t_list.btn_bm_upgrade.node, true)
			self.node_t_list.btn_bm_upgrade.node:setTitleText(Language.Equipment.UpGradeBtnTxt[3])
			if equip and ItemData.Instance:GetItemConfig(equip.item_id) then
				self.node_t_list.rich_need_upgrade.node:setVisible(true)
				local equip_config = ItemData.Instance:GetItemConfig(equip.item_id)
				RichTextUtil.ParseRichText(self.node_t_list.rich_need_upgrade.node, string.format(Language.Equipment.NeedUpgradPeerl, equip_config.name, equip_config.name, equip_config.name))
			else
				self.node_t_list.rich_need_upgrade.node:setVisible(false)
			end
		else
			self.node_t_list.layout_blood_consume.node:setVisible(true)
			self.node_t_list.rich_need_upgrade.node:setVisible(false)
			self.txt_get_bm_stuff:setVisible(true)
			local item_cfg = ItemData.Instance:GetItemConfig(cfg[1])
			if item_cfg then
				self.node_t_list.lbl_bm_need.node:setString(string.format("%s*%d", item_cfg.name, cfg[2]))
				self.txt_get_bm_stuff:setString(Language.Equipment.Obtain .. item_cfg.name)
			end
			local has_count = BagData.Instance:GetItemNumInBagById(cfg[1])
			self.node_t_list.lbl_bm_have.node:setString(tostring(has_count))
			self.node_t_list.lbl_bm_have.node:setColor(has_count >= cfg[2] and COLOR3B.GREEN or COLOR3B.RED)
			self.node_t_list.btn_bm_upgrade.node:setTitleText(bm_level >= 10 and Language.Equipment.UpGradeBtnTxt[4] or Language.Equipment.UpGradeBtnTxt[2])
			XUI.SetButtonEnabled(self.node_t_list.btn_bm_upgrade.node, has_count >= cfg[2] and equip ~= nil)
		end
	else
		self:ShowMaxLevelText(true, 620, 130)
		self.node_t_list.layout_blood_consume.node:setVisible(false)
		self.node_t_list.btn_bm_upgrade.node:setVisible(false)
		self.txt_get_bm_stuff:setVisible(false)
		self.node_t_list.rich_need_upgrade.node:setVisible(false)
	end
end

function EquipmentView:FlushAllBmCell()
	for i, v in ipairs(EquipmentData.Instance:GetEqBmShowData()) do
		self.bm_cell_list[i]:SetData(v)
		self.bm_cell_list[i]:ShowRemind(v.remind)
		if i == self.select_bm_index then
			self.select_bm_cell:SetData(v)
			self.bm_cell_list[i]:SetSelect(true)
		end
	end
end

function EquipmentView:FlushBmAttrView()
	local attr_data = EquipmentData.GetBmStrengthenAttrCfg(self.select_bm_index, self.select_bm_cell:GetData().bm_level)
	local n_attr_data = EquipmentData.GetBmStrengthenAttrCfg(self.select_bm_index, self.select_bm_cell:GetData().bm_level + 1)
	self.cur_bm_attr_view:SetData(attr_data)
	self.next_bm_attr_view:SetData(n_attr_data)
end

function EquipmentView:OnClickBMCell(cell)
	self.bm_cell1 = self.bm_cell1 or self:CreateBMCell(self.ph_list.ph_bmcell_select, 1, false)
	self.bm_cell2 = self.bm_cell2 or self:CreateBMCell(self.ph_list.ph_bmcell_select, 1, false)
	self.bm_cell1:SetVisible(false)
	self.bm_cell2:SetVisible(false)
	
	if self.bm_cell1:GetView():getNumberOfRunningActions() > 0 or
	cell:GetIndex() == self.select_bm_index then
		return
	end
	
	self.bm_cell1:SetPosition(cell:GetView():getPosition())
	self.bm_cell1:SetIndex(cell:GetIndex())
	self.bm_cell1:SetData(cell:GetData())
	
	self.bm_cell2:SetPosition(self.select_bm_cell:GetView():getPosition())
	self.bm_cell2:SetIndex(self.select_bm_cell:GetIndex())
	self.bm_cell2:SetData(self.select_bm_cell:GetData())
	
	self:TransitionCell(self.bm_cell1:GetView(), self.bm_cell2:GetView(),
	cc.p(self.select_bm_cell:GetView():getPosition()),
	cc.p(self.bm_cell_list[self.select_bm_index]:GetView():getPosition()),
	function()
		self.bm_cell1:SetVisible(false)
		self.bm_cell2:SetVisible(false)
		self.bm_cell_list[self.select_bm_index]:SetSelect(false)
		self.select_bm_index = cell:GetIndex()
		self.select_bm_cell:SetIndex(cell:GetIndex())
		self.select_bm_cell:SetData(cell:GetData())
		cell:SetSelect(true)
		self:FlushBmAttrView()
		self:FlushBmConsume()
	end)
end

function EquipmentView:OnClickGetBMStuff()
	TipCtrl.Instance:OpenStuffTip(Language.Equipment.AdvanceStuffGetWay, EquipmentData.GetAdvStuffWayConfig() [TabIndex.equipment_molding_soul])
end


function EquipmentView:OnClickBMPlus()
	local data = {}
	local blood_tip_level = RoleRuleData.GetXueLianTipsLevel()
	local level = EquipData.Instance:GetPeerlessEquipLevel()
	if level > 0 then
		local blood_level = EquipmentData.Instance:GetAllBmStrengthLevel()
		data = {tiptype = 4, level = blood_tip_level, blood_mixing_level = blood_level}
	else
		local min_count = RoleRuleData.GetPeerlessSuitNum(level)
		local tab = RoleRuleData.Instance:GetPeerlessSuitData(level)
		local tab_1 = RoleRuleData.Instance:GetPeerlessSuitData(level)
		data = {tiptype = 5, level = level, min_count = min_count, max_count = 10, next_count = 10, tab = tab, tab_1 = tab_1}
	end
	ViewManager.Instance:Open(ViewName.RoleRule)
	ViewManager.Instance:FlushView(ViewName.RoleRule, 0, nil, data)
end


function EquipmentView:OnClickBMUpgrade()
	local text = self.node_t_list.btn_bm_upgrade.node:getTitleText()
	if text == Language.Equipment.UpGradeBtnTxt[2] or text == Language.Equipment.UpGradeBtnTxt[4] then
		if self.select_bm_index then
			EquipmentCtrl.SendBmStrengthen(self.select_bm_index - 1)
		end
	elseif text == Language.Equipment.UpGradeBtnTxt[3] then
		ViewManager.Instance:Open(ViewName.EqCompose, TabIndex.eqcompose_cp_extant)
		self:Close()
	end
end

EqBMItem = EqBMItem or BaseClass(BaseRender)
function EqBMItem:__delete()
	self.cell:DeleteMe()
	self.cell = nil
	
	self.number_level:DeleteMe()
	self.number_level = nil
end

function EqBMItem:CreateChild()
	BaseRender.CreateChild(self)
	
	local cs = self.view:getContentSize()
	
	self.cell = BaseCell.New()
	self.cell:SetAnchorPoint(0.5, 0.5)
	self.cell:SetPosition(cs.width / 2, cs.height / 2)
	self.cell:SetRightBottomTexVisible(false)
	self.cell:SetProfIconVisible(false)
	self.view:addChild(self.cell:GetView())
	
	self.number_level = NumberBar.New()
	self.number_level:Create(5, cs.height - 12, 30, 15, ResPath.GetEquipment("perfect_"))
	self.number_level:SetHasPlus(true)
	self.number_level:SetAnchorPoint(0, 1)
	self.number_level:SetGravity(NumberBarGravity.Right)
	self.view:addChild(self.number_level:GetView())
end

function EqBMItem:OnFlush()
	if not self.data then
		return
	end
	
	self.cell:SetData(self.data.equip)
	self.cell:SetBgTa(ResPath.GetEquipBg("cs_ta_" .. tostring(self.index)))
	self.cell:SetBgTaVisible(not self.data.equip)
	self.cell:SetRightTopNumText(0)
	
	self.number_level:SetNumber(self.data.bm_level)
end

function EqBMItem:SetShowTips(is_show)
	if self.cell then
		self.cell:SetEventEnabled(is_show)
		self.cell:SetIsShowTips(is_show)
	end
end

function EqBMItem:ShowRemind(remind)
	if not self.img_remind and remind then
		local cs = self.view:getContentSize()
		self.img_remind = XImage:create()
		self.img_remind:setAnchorPoint(1, 1)
		self.img_remind:setPosition(cs.width + 5, cs.height + 5)
		self.img_remind:loadTexture(ResPath.GetMainui("remind_flag"))
		self.view:addChild(self.img_remind, 9999)
	end
	
	if self.img_remind then
		self.img_remind:setVisible(remind)
	end
end 