
local GodEquipView = BaseClass(SubView)

function GodEquipView:__init()
	self.texture_path_list = {
		'res/xui/equipbg.png',
		-- 'res/xui/role_btn.png',
	}
	self.config_tab = {
		{"role1_ui_cfg", 5, {0}},
	}

	self.equip_list = {}
	self.need_del_objs = {}
	self.select_slot = EquipData.EquipSlot.itWeaponPos
end

function GodEquipView:__delete()
end

function GodEquipView:ReleaseCallBack()
	for k, v in pairs(self.need_del_objs) do
		v:DeleteMe()
	end
	self.need_del_objs = {}
	self.equip_list = {}
	self.equip_img_bg = nil
end

function GodEquipView:LoadCallBack(index, loaded_times)
	self:CreateEquipCells()

	self.cur_god_equip = self:CreateGodEquipCell(self.node_t_list.layout_up_god_equip.node, self.ph_list.ph_god_equip)
	self.next_god_equip = self:CreateGodEquipCell(self.node_t_list.layout_up_god_equip.node, self.ph_list.ph_god_equip2)
	self.make_god_equip = self:CreateGodEquipCell(self.node_t_list.layout_make_equip.node, self.ph_list.ph_god_equip3)

	self.cur_god_attr = self:CreateGodEquipAttrView(self.node_t_list.layout_up_god_equip.node, self.ph_list.ph_attr1)
	self.next_god_attr = self:CreateGodEquipAttrView(self.node_t_list.layout_up_god_equip.node, self.ph_list.ph_attr2)
	self.make_god_attr = self:CreateGodEquipAttrView(self.node_t_list.layout_make_equip.node, self.ph_list.ph_attr3)

	self.node_t_list.btn_god_btn1.node:setTitleText("")
	self.node_t_list.btn_god_btn1.node:setTitleFontName(COMMON_CONSTS.FONT)
	self.node_t_list.btn_god_btn1.node:setTitleFontSize(22)
	self.node_t_list.btn_god_btn1.node:setTitleColor(COLOR3B.G_W2)
	self.node_t_list.btn_god_btn1.remind_eff = RenderUnit.CreateEffect(23, self.node_t_list.btn_god_btn1.node, 1)

	-- 获取材料link txt
	local stuff_name = ItemData.Instance:GetItemConfig(GodEquipData.GetConsumeItemId()).name
	self.other_attr_txt = RichTextUtil.CreateLinkText("获取" .. stuff_name, 20, COLOR3B.GREEN, nil, true)
	self.other_attr_txt:setPosition(self.node_t_list.btn_god_btn1.node:getPositionX() + 160, 28)
	XUI.AddClickEventListener(self.other_attr_txt, function() ViewManager.Instance:OpenViewByDef(ViewDef.GodEqDecompose) end, true)
	self.node_t_list.layout_god_equip.node:addChild(self.other_attr_txt, 10)

	XUI.AddClickEventListener(self.node_t_list.btn_god_btn1.node, BindTool.Bind(self.OnClickGodBtn, self), true)
	XUI.RichTextSetCenter(self.node_t_list.rich_btn_desc.node)

	local x, y = self.node_t_list.img9_bg.node:getPosition()
	self.equip_img_bg = XUI.CreateImageView(x, y, "")
	self.node_t_list.layout_god_equip.node:addChild(self.equip_img_bg, 1)

	EventProxy.New(EquipData.Instance, self):AddEventListener(EquipData.CHANGE_ONE_EQUIP, BindTool.Bind(self.OnChangeOneEquip, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
end

function GodEquipView:OnBagItemChange()
	self:FlushConsumeDesc()
	self:Flush(0, "all_equips")
end

function GodEquipView:OnChangeOneEquip(vo)
	if vo.slot and self.equip_list[vo.slot] then
		self.equip_list[vo.slot]:Flush()
	end
	self:Flush()

	if vo.reason == EquipData.CHANGE_EQUIP_REASON.DEL then
		self.last_task_off_equip = vo.last_equip
	elseif vo.reason == EquipData.CHANGE_EQUIP_REASON.PUT_ON then
		local last_equip = self.last_task_off_equip
		local new_equip = EquipData.Instance:GetEquipDataBySolt(vo.slot)

		local old_is_god_equip = nil ~= last_equip and ItemData.Instance:IsGodEquip(last_equip.item_id) or false
		local new_is_god_equip = nil ~= new_equip and ItemData.Instance:IsGodEquip(new_equip.item_id) or false
		if new_is_god_equip then
			local size = self.node_t_list.layout_god_equip.node:getContentSize()
			if not old_is_god_equip then
				RenderUnit.PlayEffectOnce(12, self.node_t_list.layout_god_equip.node, 999, size.width / 2, size.height / 2, true)
			else
				RenderUnit.PlayEffectOnce(17, self.node_t_list.layout_god_equip.node, 999, size.width / 2, size.height / 2, true)
			end
		end
		self.last_task_off_equip = nil
	end
end

function GodEquipView:OpenCallBack()
	self.select_slot = EquipData.EquipSlot.itWeaponPos
end

function GodEquipView:ShowIndexCallBack(index)
	self:Flush()
end

function GodEquipView:OnFlush(param_t, index)
	for key, param in pairs(param_t) do
		if key == "all_equips" then
			for k, v in pairs(self.equip_list) do
				v:Flush()
			end
		elseif key == "all" then
			self:FlushParts()
		end
	end
end

-- 面板显示变化
function GodEquipView:FlushParts()
	local equip_data = EquipData.Instance:GetEquipDataBySolt(self.select_slot)
	local is_god_equip = false
	if equip_data then
		is_god_equip = ItemData.Instance:IsGodEquip(equip_data.item_id)
	end

	self.node_t_list.layout_up_god_equip.node:setVisible(is_god_equip)
	self.node_t_list.layout_make_equip.node:setVisible(not is_god_equip)

	local next_equip, equip_cfg = GodEquipData.Instance:GetNextGodEquip(self.select_slot)
	local next_item_cfg = next_equip and ItemData.Instance:GetItemConfig(next_equip.item_id) or nil
	if is_god_equip then
		local item_cfg = ItemData.Instance:GetItemConfig(equip_data.item_id)
		
		self.cur_god_equip:SetData(equip_data)
		self.cur_god_attr:SetData(item_cfg.staitcAttrs)

		self.next_god_equip:SetData(next_equip)
		self.next_god_attr:SetData(next_item_cfg and next_item_cfg.staitcAttrs or nil)
	else
		self.make_god_equip:SetData(next_equip)
		self.make_god_attr:SetData(next_item_cfg and next_item_cfg.staitcAttrs or nil)
	end

	self.node_t_list.btn_god_btn1.node:setTitleText(not is_god_equip and "铸造神装" or "升级神装")
	self.equip_img_bg:loadTexture(is_god_equip and ResPath.GetBigPainting("equip_bg_100", true) or ResPath.GetBigPainting("equip_bg_101", true))

	for k, v in pairs(self.equip_list) do
		v:SetSelect(self.select_slot == k)
	end

	self:FlushConsumeDesc()
end

function GodEquipView:FlushConsumeDesc()
	local equip_data = EquipData.Instance:GetEquipDataBySolt(self.select_slot)
	local is_god_equip = false
	if equip_data then
		is_god_equip = ItemData.Instance:IsGodEquip(equip_data.item_id)
	end
	local next_equip, equip_cfg = GodEquipData.Instance:GetNextGodEquip(self.select_slot)

	local desc = ""
	local is_enough = false
	if equip_cfg then
		local consume_cfg = is_god_equip and equip_cfg.upConsume or equip_cfg.forgeConsume
		if consume_cfg and consume_cfg[1] then
			local item_cfg = ItemData.Instance:GetItemConfig(consume_cfg[1].id)
			local item_color = string.format("%06x", item_cfg.color)
			local need_num = consume_cfg[1].count
			local bag_num = BagData.Instance:GetItemNumInBagById(consume_cfg[1].id)
			is_enough = bag_num >= need_num
			desc = string.format("消耗{color;%s;%s}：{color;%s;%d}/%d", item_color, item_cfg.name, is_enough and COLORSTR.GREEN or COLORSTR.RED, bag_num, need_num)
		end
	end

	self.node_t_list.btn_god_btn1.remind_eff:setVisible(is_enough)

	RichTextUtil.ParseRichText(self.node_t_list.rich_btn_desc.node, desc)
	
	-- 可分解神装提醒
	local can_decompose = GodEquipData.Instance:GetAnyEquipCanDecompose()
	if can_decompose > 0 then
		UiInstanceMgr.AddRectEffect({node = self.other_attr_txt, init_size_scale = 1.2, time = 0.5, offset_w = - 20})
		self.other_attr_txt.rect_effect:setColor(COLOR3B.GREEN)
	else
		UiInstanceMgr.DelRectEffect(self.other_attr_txt)
	end
end

GodEquipView.GodEquipView = {
	{equip_slot = EquipData.EquipSlot.itWeaponPos, row = 5, col = 1, cell_img = {ResPath.EquipImg.WuQi, ResPath.EquipWord.WuQi}},	-- 武器
	{equip_slot = EquipData.EquipSlot.itHelmetPos, row = 5, col = 2, cell_img = {ResPath.EquipImg.TouKui, ResPath.EquipWord.TouKui}},	-- 头盔
	{equip_slot = EquipData.EquipSlot.itDressPos, row = 4, col = 1, cell_img = {ResPath.EquipImg.KuiJia, ResPath.EquipWord.KuiJia}},	-- 衣服
	{equip_slot = EquipData.EquipSlot.itNecklacePos, row = 4, col = 2, cell_img = {ResPath.EquipImg.XiangLian, ResPath.EquipWord.XiangLian}},	-- 项链
	{equip_slot = EquipData.EquipSlot.itLeftBraceletPos, row = 3, col = 1, cell_img = {ResPath.EquipImg.ShouZhuo, ResPath.EquipWord.ShouZhuo}},	-- 手镯左
	{equip_slot = EquipData.EquipSlot.itRightBraceletPos, row = 3, col = 2, cell_img = {ResPath.EquipImg.ShouZhuo, ResPath.EquipWord.ShouZhuo}},	-- 手镯右
	{equip_slot = EquipData.EquipSlot.itLeftRingPos, row = 2, col = 1, cell_img = {ResPath.EquipImg.JieZhi, ResPath.EquipWord.JieZhi}},	-- 戒指左
	{equip_slot = EquipData.EquipSlot.itRightRingPos, row = 2, col = 2, cell_img = {ResPath.EquipImg.JieZhi, ResPath.EquipWord.JieZhi}},	-- 戒指右
	{equip_slot = EquipData.EquipSlot.itGirdlePos, row = 1, col = 1, cell_img = {ResPath.EquipImg.YaoDai, ResPath.EquipWord.YaoDai}},	-- 腰带
	{equip_slot = EquipData.EquipSlot.itShoesPos, row = 1, col = 2, cell_img = {ResPath.EquipImg.XieZi, ResPath.EquipWord.XieZi}},	-- 鞋子
}
-- 基础装备格子
function GodEquipView:CreateEquipCells()
	self.equip_list = {}
	local BaseGodEquipRender = GodEquipView.BaseGodEquipRender
	local container_size = self.node_t_list.layout_god_equip.node:getContentSize()
	for k, v in pairs(GodEquipView.GodEquipView) do
		local x = (v.col == 1) and (65) or (container_size.width - 65)
		local y = (v.row - 1) * (15 + BaseGodEquipRender.size.height) + 60
		local equip = BaseGodEquipRender.New()
		self.need_del_objs[#self.need_del_objs + 1] = equip
		self.equip_list[v.equip_slot] = equip
		local bg_ta = ResPath.GetEquipImg(v.cell_img[1])
		local bg_ta2 = ResPath.GetEquipWord(v.cell_img[2])
		equip:SetPosition(x, y)
		equip:SetSkinStyle({bg_ta = bg_ta, bg_ta2 = bg_ta2})
		equip:SetData(v)
		equip:GetView():setAnchorPoint(0.5, 0.5)
		equip:SetClickCellCallBack(BindTool.Bind(self.SelectCellCallBack, self))
		self.node_t_list.layout_god_equip.node:addChild(equip:GetView(), 10)
	end
end

function GodEquipView:OnClickGodBtn()
	EquipCtrl.SendGodEquipReq(self.select_slot)
end

function GodEquipView:SelectCellCallBack(cell)
	local slot = cell:GetData().equip_slot
	if self.select_slot ~= slot then
		self.select_slot = slot
		self:FlushParts()
	end
end

function GodEquipView:CreateGodEquipAttrView(parent_node, ph)
	local attr_view = AttrView.New(300, 25, 20)
	self.need_del_objs[#self.need_del_objs + 1] = attr_view
	attr_view:SetDefTitleText("已达到最高级")
	attr_view:SetTextAlignment(RichHAlignment.HA_LEFT, RichVAlignment.VA_CENTER)
	attr_view:GetView():setPosition(ph.x, ph.y)
	attr_view:GetView():setAnchorPoint(0.5, 0.5)
	attr_view:SetContentWH(ph.w, ph.h)
	parent_node:addChild(attr_view:GetView(), 50)
	return attr_view
end

function GodEquipView:CreateGodEquipCell(parent_node, ph)
	local ph_god_equip = ph or self.ph_list.ph_god_equip
	local god_equip = GodEquipView.GodEquipRender.New()
	self.need_del_objs[#self.need_del_objs + 1] = god_equip
	god_equip:SetUiConfig(ph_god_equip, true)
	god_equip:SetPosition(ph_god_equip.x, ph_god_equip.y)
	-- god_equip:AddClickEventListener(BindTool.Bind(self.SelectCellCallBack, self))
	parent_node:addChild(god_equip:GetView(), 10)
	return god_equip
end

----------------------------------
-- 神装格子
----------------------------------
local GodEquipRender = BaseClass(BaseRender)
GodEquipView.GodEquipRender = GodEquipRender
function GodEquipRender:__init()
end

function GodEquipRender:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function GodEquipRender:CreateChild()
	GodEquipRender.super.CreateChild(self)

	XUI.RichTextSetCenter(self.node_tree.rich_item_name.node)
	self.cell = BaseCell.New()
	self.cell:SetPosition(self.ph_list.ph_cell.x, self.ph_list.ph_cell.y)
	self.cell:SetAnchorPoint(0.5, 0.5)
	-- self.cell:SetIsShowTips(false)
	self.view:addChild(self.cell:GetView(), 10)
	self.click_cell_callback = nil
	self.cell:AddClickEventListener(function()
		if self.click_cell_callback then
			self.click_cell_callback(self)
		end
	end)

	self.text = XUI.CreateText(self.view:getContentSize().width / 2, -20, 100, 16, nil, "", nil, 16, COLOR3B.WHITE, cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM)
	self.text:setAnchorPoint(0.5, 0)
	self.view:addChild(self.text, 10)
end

function GodEquipRender:OnFlush()
	self.cell:SetData(self.data)

	local rich_content = ""
	if self.data then
		local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
		local item_color = string.format("%06x", item_cfg.color)
		rich_content = string.format("{color;%s;%s}", item_color, item_cfg.name)
	end
	
	RichTextUtil.ParseRichText(self.node_tree.rich_item_name.node, rich_content)

	local equip_level = ""
	if nil ~= self.data then
		local ji, zhuan = ItemData.GetItemLevel(self.data.item_id)
		local text = ""
		if zhuan > 0 then
			equip_level = zhuan .. Language.Common.Zhuan
		else
			equip_level = ji .. Language.Common.Ji
		end
	end
	self.text:setString(equip_level)
end

----------------------------------
-- 基础装备格子
----------------------------------
local BaseGodEquipRender = BaseClass(BaseRender)
GodEquipView.BaseGodEquipRender = BaseGodEquipRender
BaseGodEquipRender.size = cc.size(80, 92)
function BaseGodEquipRender:__init()
	self:SetIsUseStepCalc(true)
	self.view:setContentSize(BaseGodEquipRender.size)

	self.cell = BaseCell.New()
	self.cell:SetPosition(BaseGodEquipRender.size.width / 2, BaseGodEquipRender.size.height - BaseCell.SIZE / 2)
	self.cell:SetAnchorPoint(0.5, 0.5)
	self.cell:SetIsShowTips(false)
	self.view:addChild(self.cell:GetView(), 10)
	self.click_cell_callback = nil
	self.cell:AddClickEventListener(function()
		if self.click_cell_callback then
			self.click_cell_callback(self)
		end
	end)
end

function BaseGodEquipRender:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
	self.click_cell_callback = nil
end

function BaseGodEquipRender:CreateChild()
	BaseGodEquipRender.super.CreateChild(self)

	self.text = XUI.CreateText(BaseGodEquipRender.size.width / 2, 0, 100, 16, nil, "", nil, 16, COLOR3B.WHITE, cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM)
	self.text:setAnchorPoint(0.5, 0)
	self.view:addChild(self.text, 10)
end

function BaseGodEquipRender:OnFlush()
	local equip_data = EquipData.Instance:GetEquipDataBySolt(self.data.equip_slot)
	self.cell:SetData(equip_data)
	self.cell:SetRemind(GodEquipData.Instance:IsEnoughToUp(self.data.equip_slot))
	if nil == equip_data then
		self.text:setString("")
	else
		local ji, zhuan = ItemData.GetItemLevel(equip_data.item_id)
		local text = ""
		if zhuan > 0 then
			text = zhuan .. Language.Common.Zhuan
		else
			text = ji .. Language.Common.Ji
		end
		self.text:setString(text)
	end
end

function BaseGodEquipRender:SetClickCellCallBack(func)
	self.click_cell_callback = func
end

function BaseGodEquipRender:SetSkinStyle(...)
	if self.cell then
		self.cell:SetSkinStyle(...)
	end
end

return GodEquipView
