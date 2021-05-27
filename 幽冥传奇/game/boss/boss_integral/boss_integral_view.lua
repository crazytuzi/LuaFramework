local BossIntegralView = BaseClass(SubView)

function BossIntegralView:__init()
	self.texture_path_list = {
		'res/xui/boss.png',
	}
    self.config_tab = {
    	{"boss_ui_cfg", 1, {0}},
		{"boss_ui_cfg", 6, {0}},
	}
	self.property_item_list = nil
	self.property_num = nil
	self.property_attr = nil
	self.power_effect = nil
end

function BossIntegralView:__delete()
end

function BossIntegralView:LoadCallBack(index, loaded_times)
	self:CreatePropertyItem()
	self:CreateNumberBar()
	self:CreateAffinageAttrList()
	self:CreatePowerNumEffect()
	
	EventProxy.New(BossIntegralData.Instance, self):AddEventListener(BossIntegralData.GET_CREST_INFO, BindTool.Bind(self.OnCrestInfoFlush, self))
	EventProxy.New(BossIntegralData.Instance, self):AddEventListener(BossIntegralData.CREST_UP_LEVEL, BindTool.Bind(self.OnCrestUpLevel, self))
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleAttrChange, self))

	XUI.AddClickEventListener(self.node_t_list.btn_tip.node, BindTool.Bind(self.OnClickTipHanddler, self))

	BossIntegralCtrl.SendCrestInfoReq()
end

function BossIntegralView:ReleaseCallBack()
	if self.property_item_list then
		for k,v in pairs(self.property_item_list) do
			v:DeleteMe()
		end
		self.property_item_list = nil
	end

	if self.property_num then
		self.property_num:DeleteMe()
		self.property_num = nil 
	end
	if self.property_attr then
		self.property_attr:DeleteMe()
		self.property_attr = nil 
	end
	self.power_effect = nil
	self.play_eff = nil
end

function BossIntegralView:CreatePropertyItem()
	if nil ~= self.property_item_list then
		return
	end

	self.property_item_list = {}
	for i = 1, 4 do
		local ph = self.ph_list["ph_property_" .. i]
		local cell = BossIntegralView.BossIntegralRander.New()
		cell:SetAnchorPoint(0.5, 0.5)
		cell:SetPosition(ph.x, ph.y)
		cell:SetUiConfig(self.ph_list.ph_property_item, true)
		cell:SetIndex(i)
		cell:AddClickEventListener(BindTool.Bind(self.OnSelectCrestItem, self), false)
		self.node_t_list.layout_boss_integral.node:addChild(cell:GetView(), 20)
		table.insert(self.property_item_list, cell)
	end
end

function BossIntegralView:CreateNumberBar()
	if nil == self.property_num then 
		local ph = self.ph_list.ph_property_num
		self.property_num = NumberBar.New()
		self.property_num:SetRootPath(ResPath.GetCommon("num_121_"))
		self.property_num:SetPosition(ph.x, ph.y)
		self.property_num:SetGravity(NumberBarGravity.Left)
		self.node_t_list.layout_boss_integral.node:addChild(self.property_num:GetView(), 300, 300)
	end
end

function BossIntegralView:CreateAffinageAttrList()
	local ph = self.ph_list.ph_property_attr
	self.property_attr = ListView.New()
	self.property_attr:Create(ph.x + 10, ph.y, ph.w, ph.h, ScrollDir.Vertical, AttrTextRender, nil, nil, self.ph_list.ph_property_attr_item)
	self.property_attr:SetItemsInterval(2)
	self.property_attr:SetMargin(2)
	self.node_t_list.layout_boss_integral.node:addChild(self.property_attr:GetView(), 50)
end

function BossIntegralView:CreatePowerNumEffect()
	if nil == self.power_effect then
		self.power_effect = RenderUnit.CreateEffect(21, self.node_t_list.layout_boss_integral.node, 4)
	end
	local ph = self.ph_list.ph_property_num
	self.power_effect:setPosition(ph.x + 15, ph.y + 20)
end

function BossIntegralView:SetShowPlayEff(eff_id, x, y, slot)
	if self.play_eff == nil then
		self.play_eff = AnimateSprite:create()
		self.node_t_list.layout_boss_integral.node:addChild(self.play_eff, 999)
	end
	-- if slot == 3 then 
	-- 	y = y + 40
	-- end
	self.play_eff:setPosition(x, y)
	-- local rotation = {5, 290, 190, 90}
	-- self.play_eff:setRotation(rotation[slot or 1])
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(eff_id)
	self.play_eff:setAnimate(anim_path, anim_name, 1, FrameTime.Effect, false)
end

function BossIntegralView:OnFlush()
end

function BossIntegralView:OnCrestInfoFlush()
	self:FlushCrestInfo()
end

function BossIntegralView:OnCrestUpLevel(slot)
	self:SetShowPlayEff(17, 480, 300, slot)
	self:FlushCrestInfo()
end

function BossIntegralView:FlushCrestInfo()
	local property_list = BossIntegralData.Instance:GetPropertyList()
	for i,v in ipairs(self.property_item_list) do
		v:SetData(property_list[i])
	end
	local property_attr = BossIntegralData.Instance:GetPropertyAttr()
	self:FlushCrestAttr(property_attr)
end

function BossIntegralView:FlushCrestAttr(attr_data)
	self.property_num:SetNumber(CommonDataManager.GetAttrSetScore(attr_data))
	self.property_attr:SetDataList(RoleData.FormatRoleAttrStr(attr_data))
end

function BossIntegralView:RoleAttrChange(vo)
	if vo.key == OBJ_ATTR.ACTOR_ENERGY then 
		self:FlushCrestInfo()
	end
end

function BossIntegralView:OnSelectCrestItem(item)
	local data = item:GetData()
	for k,v in pairs(self.property_item_list) do
		v:SetSelect(false)
	end
	item:SetSelect(true)
	local property_attr = BossIntegralData.Instance:GetPropertyAttrBySlot(data.slot)
	self:FlushCrestAttr(property_attr)
end

function BossIntegralView:OnClickTipHanddler()
	DescTip.Instance:SetContent(Language.Boss.BossIntegralTips, Language.Boss.BossIntegralTipsName)
end

function BossIntegralView:OnGetUiNode(node_name)
	local property_item_index = string.match(node_name, "^BossIntegral(%d+)$")
	property_item_index = tonumber(property_item_index)
	if nil ~= property_item_index then
		return (self.property_item_list and self.property_item_list[property_item_index]
			and self.property_item_list[property_item_index].node_tree.btn_up_level
			and self.property_item_list[property_item_index].node_tree.btn_up_level.node), true
	end

	return BossIntegralView.super.OnGetUiNode(self, node_name)
end

BossIntegralView.BossIntegralRander = BaseClass(BaseRender)
local BossIntegralRander = BossIntegralView.BossIntegralRander

function BossIntegralRander:__init()
	self.property_level = nil
	self.sx_progressbar = nil
end

function BossIntegralRander:__delete()
	if self.property_level then 
		self.property_level:DeleteMe()
		self.property_level = nil
	end
	if self.sx_progressbar then
		self.sx_progressbar:DeleteMe()
		self.sx_progressbar = nil
	end

end

function BossIntegralRander:CreateChild()
	BaseRender.CreateChild(self)
	XUI.AddClickEventListener(self.node_tree.btn_up_level.node, BindTool.Bind(self.OnClickUpLevel, self))
	self:CreateProperNumberBar()
	self:CreateUpProgressbar()
	self.node_tree.btn_up_level.remind_eff = RenderUnit.CreateEffect(23, self.node_tree.btn_up_level.node, 1)
end

function BossIntegralRander:CreateProperNumberBar()
	local ph = self.ph_list.ph_property_level
	self.property_level = NumberBar.New()
	self.property_level:SetRootPath(ResPath.GetBoss("boss_num_"))
	self.property_level:SetPosition(ph.x, ph.y)
	self.property_level:SetSpace(-6)
	self.property_level:SetGravity(NumberBarGravity.Left)
	self.view:addChild(self.property_level:GetView(), 50)
end

function BossIntegralRander:CreateUpProgressbar()	
	self.sx_progressbar = ProgressBar.New()
	self.sx_progressbar:SetView(self.node_tree.prog9_up_progress.node)
	self.sx_progressbar:SetEffectOffsetX(-20)
	self.sx_progressbar:SetPercent(0,false)
end

function BossIntegralRander:OnFlush()
	if nil == self.data then return end

	self.node_tree.img_property.node:loadTexture(ResPath.GetBoss("img_property_" .. self.data.slot))
	self.node_tree.img_property_name.node:loadTexture(ResPath.GetBoss("img_property_name_" .. self.data.slot))
	self.node_tree.img_property_bg.node:loadTexture(ResPath.GetBoss("img_property_bg_" .. self.data.slot))
	local scale_to1 = cc.ScaleTo:create(0.5, 1.1, 1.1)
	local scale_to2 = cc.ScaleTo:create(0.5, 1, 1)
	local sequence = cc.Sequence:create(scale_to1, scale_to2)
	local forever = cc.RepeatForever:create(sequence)
	self.node_tree.img_property_name.node:runAction(forever)

	self.property_level:SetNumber(self.data.level)

	local boss_integral = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_ENERGY)
	if 0 == self.data.next_level then 
		boss_integral = 0
		self.sx_progressbar:SetPercent(100, true)
	else
		self.sx_progressbar:SetPercent(boss_integral / self.data.next_level * 100, true)
	end

	local prog_str = string.format(Language.Boss.BossIntegralProgStr, boss_integral >= self.data.next_level and COLORSTR.YELLOW or COLORSTR.RED, boss_integral, self.data.next_level) 
	XUI.RichTextSetCenter(self.node_tree.rich_prog_value.node)
	RichTextUtil.ParseRichText(self.node_tree.rich_prog_value.node, prog_str, 18, COLOR3B.OLIVE)
	self.node_tree.btn_up_level.remind_eff:setVisible(boss_integral >= self.data.next_level)
end

function BossIntegralRander:OnClickUpLevel()
	if nil == self.data then return end
	BossIntegralCtrl.SendUpCrestSlotReq(self.data.slot)
end

function BossIntegralRander:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height - 65, 145, 125, ResPath.GetBoss("select_bg"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end
	self.view:addChild(self.select_effect, 6)
end


return BossIntegralView