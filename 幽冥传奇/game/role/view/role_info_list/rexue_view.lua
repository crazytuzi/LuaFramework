
local RexueView = BaseClass(SubView)

function RexueView:__init()
	self.texture_path_list = {
		-- 'res/xui/equipbg.png',
	}
	self.config_tab = {
		{"rexue_ui_cfg", 1, {0}},
	}

	self.equip_list = {}
	self.select_slot = EquipData.EquipSlot.itHandedDownWeaponPos
end

function RexueView:__delete()
end

function RexueView:ReleaseCallBack()
	for k, v in pairs(self.equip_list) do
		v:DeleteMe()
	end
	self.equip_list = {}
	self.equip_effect = nil
	self.txt_see_attr = nil
end

function RexueView:LoadCallBack(index, loaded_times)
	self:CreateEquipCells()

	self.node_t_list.btn_rexue.node:setTitleText("激活")
	self.node_t_list.btn_rexue.node:setTitleFontName(COMMON_CONSTS.FONT)
	self.node_t_list.btn_rexue.node:setTitleFontSize(22)
	self.node_t_list.btn_rexue.node:setTitleColor(COLOR3B.G_W2)
	self.node_t_list.btn_rexue.remind_eff = RenderUnit.CreateEffect(23, self.node_t_list.btn_rexue.node, 1)

	-- 获取材料
	self.link_stuff = RichTextUtil.CreateLinkText("获取热血装备", 20, COLOR3B.GREEN)
	local x, y = self.node_t_list.btn_rexue.node:getPosition()
	self.link_stuff:setPosition(x + 170, y - 8)
	self.node_t_list.layout_rexue.node:addChild(self.link_stuff, 99)
	XUI.AddClickEventListener(self.link_stuff, BindTool.Bind(self.OnClickLinkStuff, self), true)

	self.equip_effect = RenderUnit.CreateEffect(25, self.node_t_list.layout_center.node, 10)
	CommonAction.ShowJumpAction(self.equip_effect, 10)

	RenderUnit.CreateEffect(nil, self.node_t_list.img_big_bg.node, 10, FrameTime.Effect / 4)

    XUI.RichTextSetCenter(self.node_t_list.rich_btn_above.node)

	XUI.AddClickEventListener(self.node_t_list.btn_rexue.node, BindTool.Bind(self.OnClickBtn, self))

	XUI.AddClickEventListener(self.node_t_list.layout_center.node, BindTool.Bind(self.OnClickCenter, self))

	local equip_proxy = EventProxy.New(EquipData.Instance, self)
	equip_proxy:AddEventListener(EquipData.CHANGE_ONE_EQUIP, BindTool.Bind(self.OnChangeOneEquip, self))
	
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
	self:BindGlobalEvent(OtherEventType.REMINDGROUP_CAHANGE, BindTool.Bind(self.OnRemindGroupChange, self))
end

function RexueView:OpenCallBack()
	self.select_slot = EquipData.EquipSlot.itWarmBloodDivineswordPos
end

function RexueView:ShowIndexCallBack(index)
	self:Flush()
end

function RexueView:OnFlush(param_t, index)
	if param_t.flush_equips then
		for k, v in pairs(self.equip_list) do
			v:Flush()
		end
	end

	if param_t.all then
		self:FlushParts()
	end
end

----------------------------------------------------------------------------------
function RexueView:OnClickLinkStuff()
	if nil ~= self.need_item_id then
		TipCtrl.Instance:OpenGetStuffTip(self.need_item_id)
	end
end

function RexueView:OnRemindGroupChange(group_name, num)
	if group_name == self:GetViewDef().remind_group_name then
		self:Flush(0, "flush_equips")
	end
end

function RexueView:OnBagItemChange()
	self:Flush(0, "flush_equips")
	self:Flush()
end

function RexueView:OnChuanshiDataChange()
	self:Flush()
end

function RexueView:OnChangeOneEquip(vo)
	if vo.slot and self.equip_list[vo.slot] then
		self.equip_list[vo.slot]:Flush()
	end

	self:Flush()
end

function RexueView:FlushParts()
	local item_type = EquipData.Instance:GetTypeByEquipSlot(self.select_slot)
	local equip = EquipData.Instance:GetEquipDataBySolt(self.select_slot)

	local consume_str = ""
	local equip_item_id
	local is_act = nil ~= equip
	local is_enough
	if nil == equip then
		local item_list = {}
		for k, v in pairs(BagData.Instance:GetItemDataList(item_type)) do
			item_list[#item_list + 1] = v
		end

		local equip_name = Language.EquipTypeName[item_type]
		local need_num = 1
		local equip_num = #item_list
		is_enough = equip_num >= need_num
		consume_str = string.format("消耗：%s({color;%s;%d}/%d)", equip_name, is_enough and COLORSTR.GREEN or COLORSTR.RED, equip_num, need_num)

		local first_equip_id = EquipData.GetRexueFirstEquip(self.select_slot)
		equip_item_id = first_equip_id
	else
		equip_item_id = equip.item_id
	end
    RichTextUtil.ParseRichText(self.node_t_list.rich_btn_above.node, consume_str)
	self.node_t_list.btn_rexue.node:setVisible(nil == equip)
	self.node_t_list.btn_rexue.remind_eff:setVisible(is_enough)
	self.link_stuff:setVisible(self.node_t_list.btn_rexue.node:isVisible())
    if IS_AUDIT_VERSION then
        self.link_stuff:setVisible(false)
    end

	self.need_item_id = equip_item_id

	local equip_client_cfg = EquipData.GetRexueEquipClientCfg(self.select_slot, equip_item_id)
	if equip_client_cfg then
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(equip_client_cfg.effect_id)
		self.equip_effect:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
		XUI.MakeGrey(self.equip_effect, nil == equip)
	end

	if nil == self.txt_see_attr and is_act then
		local x, y = self.node_t_list.btn_rexue.node:getPosition()
		self.txt_see_attr = XUI.CreateText(x, y + 20, 0, 0, nil, "点击装备图可查看属性", nil, 20, COLOR3B.OLIVE)
		self.node_t_list.layout_rexue.node:addChild(self.txt_see_attr, 99)
	elseif self.txt_see_attr then
		self.txt_see_attr:setVisible(is_act)
	end
end

function RexueView:FlushConsumeDesc()
end

RexueView.EQUIP_POS = {
	{equip_slot = EquipData.EquipSlot.itWarmBloodDivineswordPos, row = 4, col = 1, cell_img = {ResPath.EquipImg.KuiJia, ResPath.EquipWord.KuiJia}},
	{equip_slot = EquipData.EquipSlot.itWarmBloodGodNailPos, row = 4, col = 2, cell_img = {ResPath.EquipImg.XiangLian, ResPath.EquipWord.XiangLian}},
	{equip_slot = EquipData.EquipSlot.itWarmBloodElbowPadsPos, row = 3, col = 1, cell_img = {ResPath.EquipImg.ShouZhuo, ResPath.EquipWord.ShouZhuo}},
	{equip_slot = EquipData.EquipSlot.itWarmBloodShoulderPadsPos, row = 3, col = 2, cell_img = {ResPath.EquipImg.ShouZhuo, ResPath.EquipWord.ShouZhuo}},
	{equip_slot = EquipData.EquipSlot.itWarmBloodHatsPos, row = 2, col = 1, cell_img = {ResPath.EquipImg.JieZhi, ResPath.EquipWord.JieZhi}},
	{equip_slot = EquipData.EquipSlot.itWarmBloodWarDrumPos, row = 2, col = 2, cell_img = {ResPath.EquipImg.JieZhi, ResPath.EquipWord.JieZhi}},
	{equip_slot = EquipData.EquipSlot.itWarmBloodPendantPos, row = 1, col = 1, cell_img = {ResPath.EquipImg.YaoDai, ResPath.EquipWord.YaoDai}},
	{equip_slot = EquipData.EquipSlot.itWarmBloodKneecapPos, row = 1, col = 2, cell_img = {ResPath.EquipImg.XieZi, ResPath.EquipWord.XieZi}},
}
-- 基础装备格子
function RexueView:CreateEquipCells()
	self.equip_list = {}
	local RexueEquipRender = RexueView.RexueEquipRender
	local container_size = self.node_t_list.layout_rexue.node:getContentSize()
	for k, v in pairs(RexueView.EQUIP_POS) do
		local x = (v.col == 1) and (130) or (container_size.width - 130)
		local y = (v.row - 1) * (20 + RexueEquipRender.size.height) + 90
		local equip = RexueEquipRender.New()
		self.equip_list[v.equip_slot] = equip
		equip:SetPosition(x, y)
		equip:SetData(v)
		equip:GetView():setAnchorPoint(0.5, 0.5)
		equip:SetClickCellCallBack(BindTool.Bind(self.SelectCellCallBack, self))
		self.node_t_list.layout_rexue.node:addChild(equip:GetView(), 10)

		equip:SetSelect(v.equip_slot == self.select_slot)
	end
end

function RexueView:SelectCellCallBack(cell)
	for k, v in pairs(self.equip_list) do
		v:SetSelect(v == cell)
	end
	local slot = cell:GetData().equip_slot
	if self.select_slot ~= slot then
		self.select_slot = slot
		self:Flush()
	else
		ViewManager.Instance:OpenViewByDef(ViewDef.ReXueShiEquip)
	end
	ViewDef.ReXueShiEquip._select_slot = self.select_slot
end

function RexueView:OnClickCenter()
	ViewManager.Instance:OpenViewByDef(ViewDef.ReXueShiEquip)
	ViewDef.ReXueShiEquip._select_slot = self.select_slot
end

function RexueView:OnClickBtn()
	local item_type = EquipData.Instance:GetTypeByEquipSlot(self.select_slot)
	local item_list = {}
	for k, v in pairs(BagData.Instance:GetItemDataList(item_type)) do
		item_list[#item_list + 1] = v
	end

	local function get_item_score(item_data)
		return ItemData.Instance:GetItemScore(ItemData.Instance:GetItemConfig(item_data.item_id), item_data)
	end
	table.sort(item_list, function(a, b)
		if get_item_score(a) > get_item_score(b) then
			return true
		end
	end)

	if #item_list > 0 then
		EquipCtrl.SendActRexueEquipReq(item_list[1].series)
	else
        if not IS_AUDIT_VERSION then
		    self:OnClickLinkStuff()
        end
		SysMsgCtrl.Instance:FloatingTopRightText("{color;ff2828;材料不足}")
	end
end

----------------------------------
-- 基础装备格子
----------------------------------
local RexueEquipRender = BaseClass(BaseRender)
RexueView.RexueEquipRender = RexueEquipRender
RexueEquipRender.size = cc.size(80, 102)
function RexueEquipRender:__init()
	self:SetIsUseStepCalc(true)
	self.view:setContentSize(RexueEquipRender.size)

	self.cell = BaseCell.New()
	self.cell:SetPosition(RexueEquipRender.size.width / 2, RexueEquipRender.size.height - BaseCell.SIZE / 2)
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

function RexueEquipRender:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
	self.click_cell_callback = nil
end

function RexueEquipRender:CreateChild()
	RexueEquipRender.super.CreateChild(self)

	self.rich_under = XUI.CreateRichText(RexueEquipRender.size.width / 2, 0, 300, 20)
	XUI.RichTextSetCenter(self.rich_under)
	self.rich_under:setAnchorPoint(0.5, 0)
	self.view:addChild(self.rich_under, 10)
end

function RexueEquipRender:OnFlush()
	local equip_data = EquipData.Instance:GetEquipDataBySolt(self.data.equip_slot)
	local item_id

	self.cell:SetRemind(EquipData.Instance:GetRexueCanUp(self.data.equip_slot) > 0)
	if equip_data then
		item_id = equip_data.item_id
		self.cell:SetData(equip_data)
		self.cell:SetCfgEffVis(true)
		self.cell:MakeGray(false)
	else
		local first_equip_id = EquipData.GetRexueFirstEquip(self.data.equip_slot)
		item_id = first_equip_id
		if item_id then
			self.cell:SetData({item_id = item_id, num = 1, is_bind = 0})
			self.cell:SetCfgEffVis(false)
			self.cell:MakeGray(true)
		end
	end

	local under_content = item_id and ItemData.Instance:GetItemNameRich(item_id) or ""
	RichTextUtil.ParseRichText(self.rich_under, under_content)
end

function RexueEquipRender:SetClickCellCallBack(func)
	self.click_cell_callback = func
end

function RexueEquipRender:SetSkinStyle(...)
	if self.cell then
		self.cell:SetSkinStyle(...)
	end
end

function RexueEquipRender:CreateSelectEffect()
	self.select_effect = XUI.CreateImageViewScale9(RexueEquipRender.size.width / 2, RexueEquipRender.size.height - BaseCell.SIZE / 2,
		BaseCell.SIZE, BaseCell.SIZE, ResPath.GetCommon("img9_120"), true)
	self.view:addChild(self.select_effect, 999)
end

return RexueView
