
-- 神炉通用
GFCommonView = BaseClass(SubView)

function GFCommonView:__init()
	self.texture_path_list = {
		'res/xui/godfurnace.png',
	}
	self.config_tab = {
		{"god_furnace_ui_cfg", 1, {0}},
	}

	self.select_slot = GodFurnaceData.Slot.TheDragonPos

	self.gf_data = GodFurnaceData.Instance
	self.yb_check_box_check_flag = false 
end

function GFCommonView:__delete()
	self.gf_data = nil
end

function GFCommonView:SetSlot(slot)
	self.select_slot = slot
end

function GFCommonView:ReleaseCallBack()
	if self.fight_power then
		self.fight_power:DeleteMe()
		self.fight_power = nil
	end

	if self.num_img then
		self.num_img:DeleteMe()
		self.num_img = nil
	end

	if self.progressbar then
		self.progressbar:DeleteMe()
		self.progressbar = nil
	end

	if self.quick_buy then
		self.quick_buy:DeleteMe()
		self.quick_buy = nil
	end
	self.yb_check_box = nil

	self.equip_display = nil
	self.max_txt = nil
	self.play_eff = nil

	if self.cur_attr then
		self.cur_attr:DeleteMe()
		self.cur_attr = nil 
	end

	if self.next_attr then
		self.next_attr:DeleteMe()
		self.next_attr = nil 
	end

	self.skill_cell = nil
end

function GFCommonView:LoadCallBack(index, loaded_times)
	local ph_center = self.ph_list.ph_center
	local ph_checkbox = self.ph_list.ph_checkbox
	self.yb_check_box = XUI.CreateCheckBox(ph_checkbox.x, ph_checkbox.y, ResPath.GetCommon("img9_110"), ResPath.GetCommon("bg_checkbox_hook2"), bg_disable, cross, cross_disable, true)
	self.node_t_list.layout_gf_common.node:addChild(self.yb_check_box, 10)
	self.yb_check_box:setSelected(self.yb_check_box_check_flag)
	self.yb_check_box_check_flag = self.yb_check_box:isSelected()
	-- self.yb_check_box:setVisible(self.select_slot == GodFurnaceData.Slot.GemStonePos or self.select_slot == GodFurnaceData.Slot.DragonSpiritPos)
	self.yb_check_box:setVisible(false)
	-- 特效
	XUI.RichTextSetCenter(self.node_t_list.rich_consume.node)
	self.equip_display = RenderUnit.CreateEffect(nil, self.node_t_list.layout_gf_common.node, 99, nil, nil, ph_center.x, ph_center.y)
	CommonAction.ShowJumpAction(self.equip_display, 10)
	self.equip_display.SetAnimateRes = function(node, res_id)
		if nil ~= node.animate_res_id and node.animate_res_id == res_id then
			return
		end

		node.animate_res_id = res_id
		if res_id == 0 then
			node:setStop()
			return
		end

		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(res_id)
		node:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	end

	-- 战斗力
	-- self.fight_power = FightPowerView.New(self.ph_list.ph_fight_power.x, self.ph_list.ph_fight_power.y, self.node_t_list.layout_gf_common.node, 100, true)
	-- self.fight_power:SetScale(0.9)

	-- 按钮
	self.node_t_list.btn_up.node:setTitleText("升级")
	self.node_t_list.btn_up.node:setTitleFontName(COMMON_CONSTS.FONT)
	self.node_t_list.btn_up.node:setTitleFontSize(22)
	self.node_t_list.btn_up.node:setTitleColor(COLOR3B.G_W2)
	XUI.AddClickEventListener(self.node_t_list.btn_up.node, BindTool.Bind(self.OnClickUpBtn, self))

	---- 等级数字
	--local ph_level_num = self.ph_list.ph_level_num
	--self.num_img = XUI.CreateImageView(ph_level_num.x, ph_level_num.y, GetGodFurnace("jie_num_1"))
    ----self.num_img:Create(ph_level_num.x, ph_level_num.y, 0, 0, ResPath.GetGodFurnace("jie_num_1"))
    ----self.num_img:SetSpace(-2)
    --self.node_t_list.layout_gf_common.node:addChild(self.num_img:GetView(), 101)

	-- 星星
	local ph_stars = self.ph_list.ph_stars
	self.start_part = UiInstanceMgr.Instance:CreateStarsUi({x = ph_stars.x, y = ph_stars.y, star_num = GodFurnaceData.STAR_NUM,
		interval_x = 5, parent = self.node_t_list.layout_gf_common.node, zorder = 99})

	-- 获取材料
	if not IS_AUDIT_VERSION then
		self.link_stuff = RichTextUtil.CreateLinkText("前往", 20, COLOR3B.GREEN)
		self.link_stuff:setPosition(860, 87)
		self.node_t_list.layout_gf_common.node:addChild(self.link_stuff, 99)
		XUI.AddClickEventListener(self.link_stuff, BindTool.Bind(self.OnClickLinkStuff, self), true)

		self.link_shop_2 = RichTextUtil.CreateLinkText("前往", 20, COLOR3B.GREEN)
		self.link_shop_2:setPosition(860, 53)
		self.node_t_list.layout_gf_common.node:addChild(self.link_shop_2, 99)
		XUI.AddClickEventListener(self.link_shop_2, BindTool.Bind(self.OnClickLinkOther, self), true)


		self.link_shop = RichTextUtil.CreateLinkText("前往", 20, COLOR3B.GREEN)
		self.link_shop:setPosition(860, 23)
		self.node_t_list.layout_gf_common.node:addChild(self.link_shop, 99)
		XUI.AddClickEventListener(self.link_shop, BindTool.Bind(self.OnClickLinkShop, self), true)
	end

	local prog = XUI.CreateLoadingBar(336 / 2 + 20, 16, ResPath.GetCommon("prog_104_progress"), XUI.IS_PLIST, nil, true, 336, 14, cc.rect(15,2,14,6))
	--XUI.CreateLoadingBar(190, 75, ResPath.GetCommon("prog_104_progress"), true, ResPath.GetCommon("prog_104"))
	prog:setLocalZOrder(999)
	self.node_t_list.pro_bg.node:addChild(prog)
	self.progressbar = ProgressBar.New()
	self.progressbar:SetView(prog)
	self.progressbar:SetTailEffect(991, nil, true)
	self.progressbar:SetEffectOffsetX(-20)
	self.progressbar:SetPercent(0)

	-- 属性
	self.cur_attr = AttrItemRender.CreateAttrList(self.node_t_list.layout_gf_common.node, self.ph_list.ph_cur_attr)
	self.next_attr = AttrItemRender.CreateAttrList(self.node_t_list.layout_gf_common.node, self.ph_list.ph_next_attr)

	-- 事件
	local gf_data_proxy = EventProxy.New(self.gf_data, self)
	gf_data_proxy:AddEventListener(GodFurnaceData.SLOT_DATA_CHANGE, BindTool.Bind(self.OnSlotDataChange, self))
	gf_data_proxy:AddEventListener(GodFurnaceData.EQUIP_CHANGE, BindTool.Bind(self.OnEquipChange, self))
    EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
    self:BindGlobalEvent(OtherEventType.GODFURNACE_ACTIVE, BindTool.Bind(self.OnActiveSucced,self))
	--self:BindGlobalEvent(OtherEventType.GODFURNACE_UP_SUCCED, BindTool.Bind(self.OnUpSucced,self))
	local path = nil 
	if self.select_slot ==  GodFurnaceData.Slot.TheDragonPos then
		path = ResPath.GetGodFurnace("img_txt_1")
	elseif self.select_slot == GodFurnaceData.Slot.ShieldPos then
		path = ResPath.GetGodFurnace("img_txt_2")
	elseif self.select_slot == GodFurnaceData.Slot.DragonSpiritPos then
		path = ResPath.GetGodFurnace("img_txt_3")
	elseif self.select_slot == GodFurnaceData.Slot.GemStonePos then
		path = ResPath.GetGodFurnace("img_txt_4")
	elseif self.select_slot == GodFurnaceData.Slot.ShenDing then
		path = ResPath.GetGodFurnace("img_txt_5")
	end
	self.node_t_list.img_show_bg.node:loadTexture(path)

	XUI.AddClickEventListener(self.node_t_list.btn_help.node, function ()
		if self.select_slot ==  GodFurnaceData.Slot.TheDragonPos then
			DescTip.Instance:SetContent(Language.DescTip.GodFuncContent, Language.DescTip.GodFuncTitle)
		elseif self.select_slot ==  GodFurnaceData.Slot.ShieldPos then
			DescTip.Instance:SetContent(Language.DescTip.GodFuncShenDunContent, Language.DescTip.GodFuncShenDunTitle)
		elseif self.select_slot == GodFurnaceData.Slot.DragonSpiritPos  then
			DescTip.Instance:SetContent(Language.DescTip.GodFuncHunZhuContent, Language.DescTip.GodFuncHunZhuaTitle)
		elseif self.select_slot == GodFurnaceData.Slot.GemStonePos  then
			DescTip.Instance:SetContent(Language.DescTip.GodFuncBaoShiContent, Language.DescTip.GodFuncBaoShiTitle)
		elseif self.select_slot == GodFurnaceData.Slot.ShenDing  then
			DescTip.Instance:SetContent(Language.DescTip.GodFunShenDingContent, Language.DescTip.GodFuncShenDingTitle)
		end
		
	end)
end

function GFCommonView:OpenCallBack()
end

function GFCommonView:CloseCallBack()
	if self.yb_check_box then
		self.yb_check_box_check_flag = self.yb_check_box:isSelected()
	end
end

function GFCommonView:ShowIndexCallBack(index)
	self:Flush()
end

function GFCommonView:OnFlush(param_t, index)

	-- DragonSpiritPos
	-- if self.select_slot = GodFurnaceData.Slot.GemStonePos or self.select_slot == GodFurnaceData.Slot.TheDragonPos
	local prof = RoleData.Instance:GetRoleBaseProf()
	local godfurance_cfg = self.gf_data:GetProfCfg(self.select_slot, prof)
	--if nil == godfurance_cfg then return end
	local godfurnace_data = self.gf_data:GetSlotData(self.select_slot)
	local res_info = self.gf_data:GetSlotResInfo(self.select_slot, godfurnace_data.level)
	local is_act = self.gf_data:IsActSlot(self.select_slot)
	local cur_attr, next_attr = self.gf_data:GetAttrCfg(godfurance_cfg, godfurnace_data.level)
	self.equip_display:SetAnimateRes(res_info.eff_res_id)
	XUI.MakeGrey(self.equip_display, not is_act)

	-- self.node_t_list.img_name.node:loadTexture(ResPath.GetGodFurnace(res_info.name_path))
	local jie = self.gf_data:GetGradeNum(godfurnace_data.level)
	if jie > 0 then
		self.node_t_list.img_autoname_4.node:loadTexture(ResPath.GetGodFurnace("jie_num_" ..  jie))
	end



	local star_num = self.gf_data:GetStarNum(godfurnace_data.level)
	local is_max_star = star_num == GodFurnaceData.STAR_NUM
	self.start_part:SetStarActNum(star_num)
	self.start_part:GetView():setVisible(is_act and not is_max_star)

	local rich_param = {
		type_str_color = COLOR3B.OLIVE,
		value_str_color = COLOR3B.OLIVE
	}

	if cur_attr  then
		--PrintTable(cur_attr)
		local cur_attr_data = RoleData.FormatRoleAttrStr(cur_attr)
		--PrintTable(cur_attr_data)
		self.cur_attr:SetDataList(cur_attr_data)
		
	end

	if next_attr then
		local next_attr_data = RoleData.FormatRoleAttrStr(next_attr)
		self.next_attr:SetDataList(next_attr_data)
	else
		self.next_attr:SetDataList({})
	end
	XUI.SetButtonEnabled(self.node_t_list.btn_up.node, next_attr ~= nil)
	--RichTextUtil.ParseRichText(self.node_t_list.rich_cur_attr.node, cur_attr and RoleData.FormatAttrContent(cur_attr, rich_param) or "")
	--RichTextUtil.ParseRichText(self.node_t_list.rich_next_attr.node, next_attr and RoleData.FormatAttrContent(next_attr, rich_param) or "")

	local is_max = nil == next_attr
	if is_max and nil == self.max_txt then
		self.max_txt = XUI.CreateText(640, 224, 300, 26, cc.TEXT_ALIGNMENT_LEFT, "已经是最高级了", nil, 24, Str2C3b("d8d800"))
		self.node_t_list.layout_gf_common.node:addChild(self.max_txt, 99)
		self.max_txt:setAnchorPoint(0, 0.5)
	elseif nil ~= self.max_txt then
		self.max_txt:setVisible(is_max)	
	end

	-- 消耗文字
	local consume_cfg = self.gf_data:GetNextConsume(godfurance_cfg, godfurnace_data.level)
	local consume_str = ""
	if nil ~= consume_cfg then
		local consume_item = consume_cfg[1]
		local bag_num = BagData.Instance:GetItemNumInBagById(consume_item.id)
		local is_enought = bag_num >= consume_item.count
		local color = is_enought and COLORSTR.GREEN or COLORSTR.RED
		-- consume_str = string.format("消耗%s:({color;%s;%d}/%d)", ItemData.Instance:GetItemNameRich(consume_item.id), color, bag_num, consume_item.count)
		consume_str = string.format("{color;%s;%d}/%d", color, bag_num, consume_item.count)
		self.consume_item_id = consume_item.id

		self.node_t_list.btn_up.node:setTitleText(is_act and (consume_item.count > 0 and "升级" or "免费进阶") or "激活")
		local precent = (bag_num / consume_item.count) * 100
		self.progressbar:SetPercent(precent >= 100 and 100 or precent)
	end
	RichTextUtil.ParseRichText(self.node_t_list.rich_consume.node, (not is_max_star and consume_str or ""), 20, COLOR3B.OLIVE)

	--local total_attr = cur_attr
	-- self.fight_power:SetNumber(CommonDataManager.GetAttrSetScore(total_attr or {}))
	-- self.fight_power:GetView():setVisible(is_act)
	

	if not IS_AUDIT_VERSION then
		self.link_stuff:setVisible(not is_max_star and nil ~= consume_cfg)
		self.link_shop:setVisible(not is_max_star and nil ~= consume_cfg)
	end
	if self.select_slot ==  GodFurnaceData.Slot.TheDragonPos then
		for i = 1, 3 do
			self.node_t_list["text_name_"..i].node:setString(Language.Compose.LinkStuffName[1][i])
		end
	elseif self.select_slot == GodFurnaceData.Slot.ShieldPos then
		for i = 1, 3 do
			self.node_t_list["text_name_"..i].node:setString(Language.Compose.LinkStuffName[2][i])
		end
	elseif self.select_slot == GodFurnaceData.Slot.DragonSpiritPos then
		for i = 1, 3 do
			self.node_t_list["text_name_"..i].node:setString(Language.Compose.LinkStuffName[3][i])
		end
	elseif self.select_slot == GodFurnaceData.Slot.GemStonePos then
		for i = 1, 3 do
			self.node_t_list["text_name_"..i].node:setString(Language.Compose.LinkStuffName[4][i])
		end
	elseif self.select_slot == GodFurnaceData.Slot.ShenDing then
		for i = 1, 3 do
			self.node_t_list["text_name_"..i].node:setString("")
		end
		self.link_stuff:setVisible(false)
		self.link_shop:setVisible(false)
		self.link_shop_2:setVisible(false)
		self.node_t_list["img_txt_tip"].node:loadTexture(ResPath.GetGodFurnace("img_shending_skill"))
		self:FlushShengdingSkill()
	end
end

function GFCommonView:FlushShengdingSkill()
	local cfg = RestraintSeparationConfig or {} -- 配置文件名:GodFurnaceSlotLvConfig
	local skill_lv = 0
	local cfg_index = 0 -- 用于取下一级的技能配置
	local skill_data = {}
	local godfurnace_data = self.gf_data:GetSlotData(self.select_slot)
	for i, v in ipairs(cfg) do
		if type(v.GodTripodLv) == "number" and godfurnace_data.level >= v.GodTripodLv then
			if type(v.level) == "number" and skill_lv < v.level then
				skill_lv = v.level
				cfg_index = i
				skill_data = v
			end
		end
	end

	local bool = true
	if next(skill_data) == nil then
		skill_data = cfg[1]
		skill_lv = 1
		bool = false
	end

	local name = skill_data.name or "克制分身术"
	local icon = skill_data.icon or ""
	self.node_t_list["text_name"].node:setString(name .."Lv.".. skill_lv)
	local path = ResPath.GetItem(icon)
	if self.skill_cell == nil then
		local parent = self.node_t_list["layout_shending_skill"].node
		local ph = self.ph_list["ph_skill"] or {x = 0, y = 0, w = 10, h = 10}
		local img = XUI.CreateImageView(ph.x, ph.y, path, XUI.IS_PLIST)
		local path = ResPath.GetCommon("cell_100")
		parent:addChild(img, 20)
		self.skill_cell = img

		local bg = XUI.CreateImageView(ph.x, ph.y, path, XUI.IS_PLIST)
		parent:addChild(bg, 19)
	else
		self.skill_cell:loadTexture(path)
	end

	local desc = skill_data.desc or ""
	local rich = self.node_t_list["rich_text_desc"].node
	RichTextUtil.ParseRichText(rich, desc, 16)
	rich:refreshView()

	local next_skill_cfg = cfg[cfg_index + 1]
	local text = ""
	if next_skill_cfg then
		local god_tripod_lv = next_skill_cfg.GodTripodLv or 0
		local jie = self.gf_data:GetGradeNum(god_tripod_lv)
		if bool then
			text = string.format("神鼎等级达到%d阶可激活下一级", jie)
		else
			text = string.format("神鼎等级达到%d阶可激活", jie)
		end
	end
	self.node_t_list["text_condition"].node:setString(text)
end

---------------------------------------------------------------------------
function GFCommonView:OnClickLinkStuff()
	if self.select_slot ==  GodFurnaceData.Slot.TheDragonPos then
		ViewManager.Instance:OpenViewByDef(ViewDef.Experiment)
	elseif self.select_slot == GodFurnaceData.Slot.ShieldPos then
		ViewManager.Instance:OpenViewByDef(ViewDef.NewlyBossView )
	elseif self.select_slot == GodFurnaceData.Slot.DragonSpiritPos
		or self.select_slot == GodFurnaceData.Slot.GemStonePos
		or self.select_slot == GodFurnaceData.Slot.ShenDing
		then
		MoveCache.end_type = MoveEndType.Normal
		GuajiCtrl.Instance:FlyByIndex(48)
		ViewManager.Instance:CloseAllView()
	end
end

function GFCommonView:OnClickLinkShop(num)
	num = num or 1
	num =  num >= 60000 and 60000 or num
	local item_id = 272
	if self.select_slot ==  GodFurnaceData.Slot.TheDragonPos then
		item_id = 272
	elseif self.select_slot == GodFurnaceData.Slot.ShieldPos then
		item_id = 273
	elseif self.select_slot == GodFurnaceData.Slot.DragonSpiritPos then
		item_id = 274
	elseif self.select_slot == GodFurnaceData.Slot.GemStonePos then
		item_id = 2510
	elseif self.select_slot == GodFurnaceData.Slot.ShenDing then
		item_id = 261
	end
	-- TipCtrl.Instance:OpenQuickBuyItem({item_id})

	TipCtrl.Instance:OpenGetNewStuffTip(item_id, num)
end

function GFCommonView:OnClickLinkOther( ... )
	if self.select_slot ==  GodFurnaceData.Slot.TheDragonPos or self.select_slot == GodFurnaceData.Slot.ShieldPos  then
		MoveCache.end_type = MoveEndType.Normal
		GuajiCtrl.Instance:FlyByIndex(48)
		ViewManager.Instance:CloseAllView()
	-- elseif self.select_slot == GodFurnaceData.Slot.ShieldPos then
	-- 	MoveCache.end_type = MoveEndType.Normal
	-- 	GuajiCtrl.Instance:FlyByIndex(48)
	-- 	ViewManager.Instance:CloseAllView()
	elseif self.select_slot == GodFurnaceData.Slot.DragonSpiritPos then
		ViewManager.Instance:OpenViewByDef(ViewDef.Explore.Exchange)
	elseif self.select_slot == GodFurnaceData.Slot.GemStonePos then
		MoveCache.end_type = MoveEndType.Normal
		GuajiCtrl.Instance:FlyByIndex(9)
		ViewManager.Instance:CloseAllView()
	end
end

function GFCommonView:OnClickUpBtn()
	local prof = RoleData.Instance:GetRoleBaseProf()
	local ring_cfg = self.gf_data:GetProfCfg(self.select_slot, prof)
	if nil == ring_cfg then return end
	local ring_data = self.gf_data:GetSlotData(self.select_slot)
	local consume_cfg = self.gf_data:GetNextConsume(ring_cfg, ring_data.level)
	local consume_str = ""
	local is_enought = true
	local count = 0
	local bag_num = 0 
	if consume_cfg then
		local consume_item = consume_cfg[1]
		count = consume_item.count
		bag_num = BagData.Instance:GetItemNumInBagById(consume_item.id)
		is_enought = bag_num >= consume_item.count
	end
	if not is_enought then
		count = count - bag_num
		if self.yb_check_box:isSelected() then
			self.quick_buy = self.quick_buy or QuickBuy.New()
			self.quick_buy:SetItemCount(count)
			self.quick_buy:Open()
			self.quick_buy:SetOnceAutoUse(1)
			local item_id = 0
			if self.select_slot == GodFurnaceData.Slot.GemStonePos then
				item_id = 3493
			elseif self.select_slot == GodFurnaceData.Slot.DragonSpiritPos then
				item_id = 3496
			end
			
			self.quick_buy:SetItemId(item_id)
		else
			if IS_AUDIT_VERSION then
				GodFurnaceCtrl.SendGodFurnaceUpReq(self.select_slot)
			else
				self:OnClickLinkShop(count)
			end	
		end
	else
		GodFurnaceCtrl.SendGodFurnaceUpReq(self.select_slot)
	end
end

function GFCommonView:OnEquipChange()
	self:Flush()
end

function GFCommonView:OnSlotDataChange(slot, slot_data)
	if slot == self.select_slot then
		self:Flush()

		if nil ~= slot_data then
			if self.gf_data:GetStarNum(slot_data.level) == 0 then
				RenderUnit.PlayEffectOnce(15, self.node_t_list.layout_gf_common.node, 999, 480, 300, true)
			else
				self:SetShowPlayEff(17,  480, 300)
			end
		end
	end
end

function GFCommonView:OnBagItemChange()
    self:Flush()
end

function GFCommonView:OnActiveSucced(slot)
	if self.select_slot == slot then
		self:SetShowPlayEff(14,  480, 300)
	end
end

function GFCommonView:OnUpSucced(slot)
	if self.select_slot == slot then
		self:SetShowPlayEff(17,  480, 300)
	end
end

function GFCommonView:SetShowPlayEff(eff_id, x, y)
	if self.play_eff == nil then
		self.play_eff = AnimateSprite:create()
		self.node_t_list.layout_gf_common.node:addChild(self.play_eff, 999)
	end
	self.play_eff:setPosition(x, y)
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(eff_id)
	self.play_eff:setAnimate(anim_path, anim_name, 1, FrameTime.Effect, false)
end

return GFCommonView
