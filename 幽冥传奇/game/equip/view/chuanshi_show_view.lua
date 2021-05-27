------------------------------------------------------------
-- 装备合成 使用 ItemSynthesisConfig配置
------------------------------------------------------------
local CSShowView = BaseClass(SubView)

local Show_EffectId = {
--    id   特效id
	[EquipData.EquipSlot.itHandedDownWeaponPos] = 110,	-- 传世_武器
    [EquipData.EquipSlot.itHandedDownDressPos] = 111,	-- 传世_衣服
    [EquipData.EquipSlot.itHandedDownHelmetPos] = 112,	-- 传世_头盔
    [EquipData.EquipSlot.itHandedDownNecklacePos] = 113,	-- 传世_项链
    [EquipData.EquipSlot.itHandedDownLeftBraceletPos] = 114,	-- 传世_左手镯
    [EquipData.EquipSlot.itHandedDownRightBraceletPos] = 114,	-- 传世_右手镯
    [EquipData.EquipSlot.itHandedDownLeftRingPos] = 115,	-- 传世_左戒指
    [EquipData.EquipSlot.itHandedDownRightRingPos] = 115,	-- 传世_右戒指
    [EquipData.EquipSlot.itHandedDownGirdlePos] = 116,	-- 传世_腰带
    [EquipData.EquipSlot.itHandedDownShoesPos] = 117,	-- 传世_鞋子
}

-- 传世槽位
-- EquipData.EquipSlot.itHandedDownWeaponPos
-- EquipData.EquipSlot.itHandedDownShoesPos

function CSShowView:__init()
	self.texture_path_list[1] = "res/xui/chuang_shi_equip.png"
	self.config_tab = {
		{"chuanshi_equip_ui_cfg", 2, {0}},
	}
	self.need_del_objs = {
		objs = {},
		add = function (key)
			self.need_del_objs.objs[key] = true
		end,
		clear = function ()
			for k,v in pairs(self.need_del_objs.objs) do
				self[k]:DeleteMe()
				self[k] = nil
			end
			self.need_del_objs.objs = {}
		end
	}

	self.select_slot = EquipData.EquipSlot.itHandedDownWeaponPos
	self.eff = nil
end

function CSShowView:__delete()
end

function CSShowView:ReleaseCallBack()
	self.need_del_objs.clear()
    self.eff_node = nil
    if self.eff then
		self.eff:setStop()
		self.eff = nil
	end
end

function CSShowView:LoadCallBack(index, loaded_times)
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
	EventProxy.New(EquipData.Instance, self):AddEventListener(EquipData.CHANGE_ONE_EQUIP, function (vo)
		self.cell_list.GetCell(vo.slot):SetData(EquipData.Instance:GetEquipDataBySolt(vo.slot))
	end)

	XUI.AddClickEventListener(self.node_t_list.btn_compose.node, function ()
		if nil == self.compose_data or not self.compose_data.can_compose then return end
		if not self.compose_data.is_curr_enough then
			TipCtrl.Instance:OpenGetStuffTip(self.compose_data.consum_cfg.consume[1].id)
		else
			BagCtrl.SendComposeItem(self.compose_data.synthesis_type, self.compose_data.item_index, 0)
		end
	end)

	XUI.AddClickEventListener(self.node_t_list.btn_explore.node, function ()
		ViewManager.Instance:OpenViewByDef(ViewDef.Explore)
	end)

	XUI.AddClickEventListener(self.node_t_list.btn_cloth_series.node, function ()	
		if nil == self.suit_tip then
			self.suit_tip = require("scripts/game/tip/cs_suit_tip").New()
			self.need_del_objs.add("suit_tip")
		end
		self.suit_tip:SetData(EquipData.Instance:GetCsSuitTxt())
	end)

	XUI.AddClickEventListener(self.node_t_list.btn_blood.node, function ()
		ViewManager.Instance:OpenViewByDef(ViewDef.ChuanShiEquip.Blood)
	end)
	XUI.AddClickEventListener(self.node_t_list.btn_up.node, function ()
		ViewManager.Instance:OpenViewByDef(ViewDef.ChuanShiEquip.Compose)
	end)
	XUI.AddClickEventListener(self.node_t_list.btn_decompose.node, function ()
		ViewManager.Instance:OpenViewByDef(ViewDef.ChuanShiEquip.Decompose)
	end)

    -- 合成生成
    self.compose_cell = BaseCell.New()
	self.compose_cell:SetPosition(self.ph_list.ph_cell.x, self.ph_list.ph_cell.y)
	self.compose_cell:SetAnchorPoint(0.5, 0.5)
	self.compose_cell:SetIsShowTips(true)
	self.node_t_list.layout_right.node:addChild(self.compose_cell:GetView(), 10)


    -- 合成生成
    self.icon = BaseCell.New()
	self.need_del_objs.add("icon")

	self.icon:SetPosition(self.ph_list.ph_comsum_icon.x, self.ph_list.ph_comsum_icon.y)
	self.icon:SetAnchorPoint(0.5, 0.5)
	self.icon:SetData{item_id = 265, num = 1, is_bind = 0}
	self.icon:SetScale(0.4)
	self.icon:SetCellBg()
	self.node_t_list.layout_cs_compose.node:addChild(self.icon:GetView(), 10)

	self:CreateAttrList()
	self.cell_list = self:CreateCSEquipList()
	self.need_del_objs.add("cell_list")

	--战力
	local cap_x, cap_y = self.node_t_list.img_wing_cap.node:getPosition()
    self.cap = NumberBar.New()
	self.need_del_objs.add("cap")

    self.cap:Create(cap_x + 60, cap_y - 20, 180, 30, ResPath.GetCommon("num_121_"))
    -- self.cap:SetGravity(NumberBarGravity.Center)
    -- self.cap:SetSpace(0)
    self.node_t_list.layout_right.node:addChild(self.cap:GetView(), 300, 300)

    local ph = self.ph_list.ph_eff
    if nil == self.eff then
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(1126)
	    self.eff = AnimateSprite:create(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	    self.eff:setPosition(ph.x + 33, ph.y+27)
	    self.eff:setScale(0.8)
	   self.node_t_list.layout_right.node:addChild(self.eff, 99)
	end
    
end

function CSShowView:OpenCallBack()
end

function CSShowView:ShowIndexCallBack(index)
	self:Flush()
end


local def_id = {
	[EquipData.EquipSlot.itHandedDownWeaponPos] = {[0] = 217, [1] = 217},	-- 传世_武器
	[EquipData.EquipSlot.itHandedDownDressPos] = {[0] = 218, [1] = 219},	-- 传世_衣服
}

function CSShowView:OnFlush(param_t, index)
	self.node_t_list.eq_name.node:loadTexture(ResPath.GetCS("name_" .. self.select_slot))

	self.cap:SetNumber(EquipData.Instance:GetCSCup())
	-- self.cap:SetNumber(0)

	local equip_data = EquipData.Instance:GetEquipDataBySolt(self.select_slot)
	self:SetEffect(Show_EffectId[self.select_slot])
	self.attr_list:SetDataList(EquipData.Instance:GetEquipAttrBySolt(self.select_slot))
	--award = {{type=0, id=219, count=1,bind=0},},consume = {{type = 0, id = 265, count=100,},},
	local consum_cfg, synthesis_type, item_index = EquipData.Instance:GetEquipComposeCfgBySolt(self.select_slot)
	local is_enough = false
	self.node_t_list.layout_explore_tip.node:setVisible(nil == consum_cfg)
	self.node_t_list.layout_cs_compose.node:setVisible(nil ~= consum_cfg)
	if nil == consum_cfg then
		self.compose_cell:SetData{item_id = def_id[self.select_slot][RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)], num = 1, is_bind = 0}
	else			
		self.compose_cell:SetData{item_id = consum_cfg.award[1].id, num = consum_cfg.award[1].count, is_bind = consum_cfg.award[1].bind}

		local item_id = consum_cfg.consume[1].id
		local bag_num = BagData.Instance:GetItemNumInBagById(item_id)
		is_enough = bag_num >= consum_cfg.consume[1].count
		local have_num_rich = string.format("{color;%s;%d}{color;%s;/%d}", is_enough and COLORSTR.GREEN or COLORSTR.RED, bag_num, "e29a45", consum_cfg.consume[1].count)
		RichTextUtil.ParseRichText(self.node_t_list.rich_consum.node, have_num_rich, 20)
	end

	self.compose_data = {
		can_compose = consum_cfg ~= nil,
		is_curr_enough = is_enough,
		consum_cfg = consum_cfg,
		synthesis_type = synthesis_type,
		item_index = item_index,
	}


	self.cell_list:Update()
end

function CSShowView:OnBagItemChange()
	self:Flush()
end

function CSShowView:SetEffect(eff_id)
	local ph = self.ph_list.ph_eff
	if eff_id > 0 then
		if nil == self.eff_node then
			self.eff_node = RenderUnit.CreateEffect(eff_id, self.node_t_list.layout_show_c.node, 999, nil, nil, nil, nil)
			-- self.need_del_objs[#self.need_del_objs + 1] = self.eff_node
		else
			local anim_path, anim_name = ResPath.GetEffectUiAnimPath(eff_id)
			self.eff_node:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
			self.eff_node:setVisible(true)
		end
	elseif nil ~= self.eff_node then
		self.eff_node:setStop()
		self.eff_node:setVisible(false)
	end
	self.eff_node:setPosition(ph.x, ph.y)
end

function CSShowView:CreateAttrList()
	self.attr_list = ListView.New()
	self.need_del_objs.add("attr_list")

	local positionHelper = self.ph_list.ph_curshuxing_list
	self.attr_list:Create(positionHelper.x, positionHelper.y, positionHelper.w, positionHelper.h, nil, ZhanjiangAttrItem, nil, nil, self.ph_list.ph_zhanjiang_attr_item)
	self.node_t_list.layout_right.node:addChild(self.attr_list:GetView(), 100, 100)
	self.attr_list:GetView():setAnchorPoint(0,0)
	self.attr_list:SetItemsInterval(3)
	self.attr_list:JumpToTop(true)
end

local slot2handPos = {
	[EquipData.EquipSlot.itHandedDownLeftBraceletPos] = 0,	-- 传世_左手镯
    [EquipData.EquipSlot.itHandedDownRightBraceletPos] = 1,	-- 传世_右手镯
    [EquipData.EquipSlot.itHandedDownLeftRingPos] = 0,	-- 传世_左戒指
    [EquipData.EquipSlot.itHandedDownRightRingPos] = 1,	-- 传世_右戒指
}
function CSShowView:CreateCSEquipList()
	local view = {}
	local cell_list = {}

	for i = EquipData.EquipSlot.itHandedDownWeaponPos, EquipData.EquipSlot.itHandedDownShoesPos do
		local cell = BaseCell.New()
		local ph = self.ph_list["ph_cell_" .. i]
		cell:SetPosition(ph.x, ph.y)
		cell:SetAnchorPoint(0.5, 0.5)
		local this = self
		XUI.AddClickEventListener(cell:GetView(), function ()
			self.select_slot = i
			self:Flush()
			if true then
				local best_eq = EquipData.Instance:GetBestCSEquip(cell_list[self.select_slot]:GetData(), self.select_slot)
				if best_eq then
					EquipCtrl.SendFitOutEquip(best_eq.series, slot2handPos[self.select_slot])
				else				
					TipCtrl.Instance:OpenItem(cell_list[self.select_slot]:GetData(), EquipTip.FROM_BAG_EQUIP, {chuanshi_slot = i})
				end
			end
		end)

		self.node_t_list.layout_show.node:addChild(cell:GetView(), 999, 999)
		cell_list[i] = cell
	end

	view.GetCell = function (idx)
		return cell_list[idx]
	end

	view.DeleteMe = function ()
		for k,v in pairs(cell_list) do
			v:DeleteMe()
		end
		cell_list = nil
	end

	view.FlushCurrSlot = function ()
		click_func(self.select_slot)
	end

	view.Update = function ()
		for slot,cell in pairs(cell_list) do
			cell:SetData(EquipData.Instance:GetEquipDataBySolt(slot))
			cell:SetRemind(nil ~= EquipData.Instance:GetBestCSEquip(EquipData.Instance:GetEquipDataBySolt(slot), slot))
		end	
	end

	view:Update()

	return view
end

return CSShowView