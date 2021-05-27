
-- 圣物合成
HolySynthesisView = HolySynthesisView or BaseClass(BaseView)

function HolySynthesisView:__init()
	self:SetModal(true)
	self.texture_path_list = {
		'res/xui/godfurnace.png',
	}
	self.config_tab = {
		{"common2_ui_cfg", 1, {0}},
		{"common2_ui_cfg", 2, {0}, nil, 999},
		{"holy_synthesis_ui_cfg", 1, {0}},
	}
	self.holy_items = {}
	self.is_play_eff = false
end

function HolySynthesisView:__delete()
end

function HolySynthesisView:ReleaseCallBack()
	for k, v in pairs(self.holy_items) do
		v:DeleteMe()
	end
	self.holy_items = {}
	if self.play_eff then
		self.play_eff:setStop()
		self.play_eff = nil
	end
end

function HolySynthesisView:LoadCallBack(index, loaded_times)
	self:CreateTopTitle(ResPath.GetGodFurnace("word_ring_equip"), 275, 695)

	local content = "{image;res/xui/common/orn_100.png;20,18}圣物槽位根据特戒等级逐个免费激活\n{image;res/xui/common/orn_100.png;20,18}激活后放入槽位可注入相对应种类的圣物（青龙、白虎、朱雀、玄武、麒麟）\n{image;res/xui/common/orn_100.png;20,18}每种圣物都可增加对应的属性，圣物的品质越高，属性也越高\n{image;res/xui/common/orn_100.png;20,18}相同品质的圣物有几率合成更高品质的圣物，失败会随机扣除1至2个圣物\n{image;res/xui/common/orn_100.png;20,18}注入青龙圣物可获得：几率性触发超级防御\n{image;res/xui/common/orn_100.png;20,18}注入白虎圣物可获得：几率性触发超级防御\n{image;res/xui/common/orn_100.png;20,18}注入朱雀圣物可获得：防麻痹属性\n{image;res/xui/common/orn_100.png;20,18}注入玄武圣物可获得：防护身属性\n{image;res/xui/common/orn_100.png;20,18}注入麒麟圣物可获得：防复活属性\n{image;res/xui/common/orn_100.png;20,18}圣物来源：跨服圣兽宫、寻宝、特殊活动等\n"
	RichTextUtil.ParseRichText(self.node_t_list.rich_tip1.node, content, 17, COLOR3B.OLIVE)
	XUI.SetRichTextVerticalSpace(self.node_t_list.rich_tip1.node,2)
	local content = "{image;res/xui/common/part_117.png;20,18}消耗三个同品质圣物可随机合成一个新圣物\n{image;res/xui/common/part_117.png;20,18}合成圣物时有几率提升为更高品质的圣物"
	RichTextUtil.ParseRichText(self.node_t_list.rich_tip2.node, content, 18, COLOR3B.ORANGE)

	-- 按钮
	self.node_t_list.btn_opt.node:setTitleText("合成圣物")
	self.node_t_list.btn_opt.node:setTitleFontName(COMMON_CONSTS.FONT)
	self.node_t_list.btn_opt.node:setTitleFontSize(22)
	self.node_t_list.btn_opt.node:setTitleColor(COLOR3B.G_W2)
	XUI.AddClickEventListener(self.node_t_list.btn_opt.node, BindTool.Bind(self.OnClickOpt, self))

	-- 获取材料
	if not IS_AUDIT_VERSION then
		self.link_stuff = RichTextUtil.CreateLinkText("获取圣物", 20, COLOR3B.GREEN)
		self.link_stuff:setPosition(410, 70)
		self.node_t_list.layout_holy_synthesis.node:addChild(self.link_stuff, 99)
		XUI.AddClickEventListener(self.link_stuff, function()
			TipCtrl.Instance:OpenGetStuffTip(CLIENT_GAME_GLOBAL_CFG.shengwu_id)
		end, true)
	end
	
	self.holy_items = {}
	for i = GodFurnaceData.HOLY_POS.MATERIAL1, GodFurnaceData.HOLY_POS.SYNTHESIS do
		local ph = self.ph_list["ph_" .. i]
		local item = HolySynthesisView.HolyItemRender.New()
		item:SetIndex(i)
		item:GetView():setPosition(ph.x, ph.y)
		self.node_t_list.layout_holy_synthesis.node:addChild(item:GetView(), 99)
		self.holy_items[i] = item
	end

	EventProxy.New(GodFurnaceData.Instance, self):AddEventListener(GodFurnaceData.HOLY_SYNTHESIS_ITEM_CHANGE, BindTool.Bind(self.OnHolySynthesisItemChange, self))
	self:BindGlobalEvent(GodFurnaceData.SYNTHESISSUCC, BindTool.Bind(self.OnComposeSucced,self))
end

function HolySynthesisView:OpenCallBack()
	GodFurnaceData.Instance:InitHolySynthesis()
end

function HolySynthesisView:CloseCallBack(is_all)
	self.is_play_eff = false
end

function HolySynthesisView:ShowIndexCallBack(index)
	self:Flush()
end

function HolySynthesisView:OnFlush(param_t, index)
	self:FlushItems()
end

function HolySynthesisView:OnComposeSucced()
	self:SetShowPlayEff(13,  250, 300)
end

--------------------------------------------------------------------
function HolySynthesisView:OnHolySynthesisItemChange(pos)
	if pos then
		if self.holy_items[pos] then
			self.holy_items[pos]:Flush()
		end
	else
		self:Flush()
	end
end

function HolySynthesisView:FlushItems()
	for k, v in pairs(self.holy_items) do
		v:Flush()
	end
end

function HolySynthesisView:OnClickOpt()
	local item_list = {}
	for i = GodFurnaceData.HOLY_POS.MATERIAL1, GodFurnaceData.HOLY_POS.MATERIAL3 do
		local data = GodFurnaceData.Instance:GetHolySynthesisItem(i)
		if data then
			table.insert(item_list, data)
		end
	end
	if #item_list == GodFurnaceData.HOLY_POS.MATERIAL3 then
		GodFurnaceCtrl.SendSynthesisGodItemReq(item_list)
	else
		-- SysMsgCtrl.Instance:FloatingTopRightText("{color;ff2828;合成圣物不足}")
		if IS_AUDIT_VERSION then
			SysMsgCtrl.Instance:FloatingTopRightText("{color;ff2828;合成圣物不足}")
		else
			TipCtrl.Instance:OpenGetStuffTip(CLIENT_GAME_GLOBAL_CFG.shengwu_id)
		end
	end
end

function HolySynthesisView:SetShowPlayEff(eff_id, x, y)
	if self.play_eff == nil then
		self.play_eff = AnimateSprite:create()
		self.node_t_list.layout_holy_synthesis.node:addChild(self.play_eff, 999)
	end
	self.play_eff:setPosition(x, y)
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(eff_id)
	self.play_eff:setAnimate(anim_path, anim_name, 1, FrameTime.Effect, false)
end

--------------------------------------------------------------------
local HolyItemRender = BaseClass()
HolySynthesisView.HolyItemRender = HolyItemRender

HolyItemRender.size = cc.size(80, 90)
function HolyItemRender:__init()
	self.index = 0
	self.view = XUI.CreateLayout(0, 0, HolyItemRender.size.width, HolyItemRender.size.height)

	self.item_cell = BaseCell.New()
	self.item_cell:SetPosition(HolyItemRender.size.width / 2, HolyItemRender.size.height / 2 + 5)
	self.item_cell:SetCellBgVis(false)
	self.item_cell:SetAnchorPoint(0.5, 0.5)
	self.item_cell:SetScale(0.7)
	self.item_cell:SetEventEnabled(false)
	self.item_cell:SetCfgEffVis(false)
	self.view:addChild(self.item_cell:GetView(), 100)

	self.bg = XUI.CreateImageView(HolyItemRender.size.width / 2, HolyItemRender.size.height / 2, ResPath.GetGodFurnace("ring_equip_bg"), true)
	self.view:addChild(self.bg, 0)

	self.add_img = nil

	 self.name = XUI.CreateRichText(HolyItemRender.size.width / 2, 13, 200, 20, true)
	 XUI.RichTextSetCenter(self.name)
	self.view:addChild(self.name, 200)

	XUI.AddClickEventListener(self.view, BindTool.Bind(self.OnClick, self))
end
	
function HolyItemRender:__delete()
end

function HolyItemRender:OnClick()
	local equip_data = GodFurnaceData.Instance:GetHolySynthesisItem(self.index)
	if equip_data then
		-- if self.index == GodFurnaceData.HOLY_POS.SYNTHESIS then
		-- 	TipCtrl.Instance:OpenItem(equip_data)
		-- else
			TipCtrl.Instance:OpenItem(equip_data, EquipTip.FROM_HOLY_SYNTHESIS)
		-- end
	else
		if self.index ~= GodFurnaceData.HOLY_POS.SYNTHESIS then
			ViewManager.Instance:OpenViewByDef(ViewDef.SelectHolyItem)
		end
	end
end

function HolyItemRender:GetView()
	return self.view
end

function HolyItemRender:SetIndex(index)
	self.index = index
end

function HolyItemRender:Flush()
	local equip_data = GodFurnaceData.Instance:GetHolySynthesisItem(self.index)
	self.item_cell:SetData(equip_data)

	self:ShowAddImg(nil == equip_data and self.index ~= GodFurnaceData.HOLY_POS.SYNTHESIS)

	local item_name = ""
	if equip_data then
		item_name = ItemData.Instance:GetItemNameRich(equip_data.item_id, 17)
	end
	RichTextUtil.ParseRichText(self.name, item_name, 17, COLOR3B.YELLOW)
end

function HolyItemRender:ShowAddImg(is_show)
	if is_show and nil == self.add_img then
		self.add_img = XUI.CreateImageView(HolyItemRender.size.width / 2, HolyItemRender.size.height / 2 + 5, ResPath.GetGodFurnace("img_add"), true)
		self.view:addChild(self.add_img, 888)
	elseif nil ~= self.add_img then
		self.add_img:setVisible(is_show)
	end
end

return HolySynthesisView
