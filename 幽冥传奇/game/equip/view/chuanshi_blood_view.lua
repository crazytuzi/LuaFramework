------------------------------------------------------------
-- 装备合成 使用 ItemSynthesisConfig配置
------------------------------------------------------------
local CSBloodView = BaseClass(SubView)
local CSLvRender = CSLvRender or BaseClass(BaseRender)

function CSBloodView:__init()
	self.texture_path_list = {
	}
	self.config_tab = {
		{"chuanshi_equip_ui_cfg", 3, {0}},
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
end

function CSBloodView:__delete()
end

function CSBloodView:ReleaseCallBack()
	self.need_del_objs.clear()
end

function CSBloodView:LoadCallBack(index, loaded_times)
	XUI.AddClickEventListener(self.node_t_list.btn_back.node, function ()
		ViewManager.Instance:OpenViewByDef(ViewDef.ChuanShiEquip.Show)
	end)

	XUI.AddClickEventListener(self.node_t_list.btn_up.node, function ()
		if self.is_bullet_window then
			-- local cfg = ConfigManager.Instance:GetClientConfig("item_synthesis_view_cfg") and ConfigManager.Instance:GetClientConfig("item_synthesis_view_cfg")[ITEM_SYNTHESIS_TYPES.CHUANSHI]
			-- TipCtrl.Instance:OpenGetStuffTip(cfg.get_item_id)
		else
			-- EquipCtrl.SendChuanShiOptReq(CSChuanShiOptReq.OPT_TYPE.UP_LEVEL, EquipData.ChuanShiCfgIndex(self.select_slot))
		end
		EquipCtrl.SendChuanShiOptReq(CSChuanShiOptReq.OPT_TYPE.UP_LEVEL, EquipData.ChuanShiCfgIndex(self.select_slot))
	end)

	XUI.AddClickEventListener(self.node_t_list.btn_cloth_series.node, function ()	
		if nil == self.suit_tip then
			self.suit_tip = require("scripts/game/tip/cs_blood_tip").New()
			self.need_del_objs.add("suit_tip")
		end
		self.suit_tip:SetData(EquipData.Instance:GetCsBloodTxt())
	end)

	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
	EventProxy.New(EquipData.Instance, self):AddEventListener(EquipData.CHUANSHI_DATA_CHANGE, BindTool.Bind(self.Flush, self))
	self.lv_view = self:CreateLvView()
	self.need_del_objs.add("lv_view")
	self:CreateAttrList()
	self:CreatePreAttrList()
	self.cell_list = self:CreateCSEquipList()
	self.need_del_objs.add("cell_list")

	-- 合成生成
    self.icon = BaseCell.New()
	self.need_del_objs.add("icon")
	self.icon:SetPosition(self.ph_list.ph_comsum_icon.x, self.ph_list.ph_comsum_icon.y)
	self.icon:SetAnchorPoint(0.5, 0.5)
	self.icon:SetData{item_id = 265, num = 1, is_bind = 0}
	self.icon:SetScale(0.4)
	self.icon:SetCellBg()
	self.node_t_list.layout_cs_compose.node:addChild(self.icon:GetView(), 10)

	RenderUnit.CreateEffect(1109, self.node_t_list.layout_cs_compose.node, 10, nil, nil, 142, 292)
end

function CSBloodView:OpenCallBack()
end

function CSBloodView:ShowIndexCallBack(index)
	self:Flush()
	self.cell_list.Update()
end

function CSBloodView:OnFlush(param_t, index)
	self.node_t_list.eq_name.node:loadTexture(ResPath.GetCS("name_" .. self.select_slot))

	local equip_data = EquipData.Instance:GetEquipDataBySolt(slot)
	local cs_info = EquipData.Instance:GetChuanShiInfo(self.select_slot)

	self.lv_view.SetLevel(EquipData.Instance:GetChuanShiInfo(self.select_slot).level)

	-- 属性数据
	local lv = cs_info.level > 0 and cs_info.level or 1
	local attr = EquipData.GetChuanShiLevelAttr(EquipData.ChuanShiCfgIndex(self.select_slot), lv)
	local next_attr = EquipData.GetChuanShiLevelAttr(EquipData.ChuanShiCfgIndex(self.select_slot), lv + 1)
	self.attr_list:SetDataList(RoleData.FormatRoleAttrStr(attr, nil, 0))
	self.pre_attr_list:SetDataList(RoleData.FormatRoleAttrStr(next_attr or attr, nil, 0))

	self.attr_list:GetView():setVisible(cs_info.level > 0)
	self.pre_attr_list:GetView():setVisible(next_attr ~= nil)

	if self.node_t_list._tip_txt then
		self.node_t_list._tip_txt:setVisible(cs_info.level == 0)
	else
		self.node_t_list._tip_txt = XUI.CreateText(144, 430, 100, 50, nil, "未血炼")
		self.node_t_list.layout_right.node:addChild(self.node_t_list._tip_txt, 999)
		self.node_t_list._tip_txt:setVisible(cs_info.level == 0)
	end

	if self.node_t_list._pre_tip_txt then
		self.node_t_list._pre_tip_txt:setVisible(next_attr == nil)
	else
		self.node_t_list._pre_tip_txt = XUI.CreateText(144, 200, 200, 50, nil, "已到达最高级")
		self.node_t_list.layout_right.node:addChild(self.node_t_list._pre_tip_txt, 999)
		self.node_t_list._pre_tip_txt:setVisible(next_attr == nil)
	end

	self.node_t_list.layout_cs_compose.node:setVisible(next_attr ~= nil)
	self.lv_view.SetLevel(EquipData.Instance:GetChuanShiInfo(self.select_slot).level)


	local consum_cfg = EquipData.GetChuanShiLevelCfg(EquipData.ChuanShiCfgIndex(self.select_slot), cs_info.level + 1)
	local is_enough = false
	-- self.node_t_list.layout_explore_tip.node:setVisible(nil == consum_cfg)
	-- self.node_t_list.layout_cs_compose.node:setVisible(nil ~= consum_cfg)
	if nil == consum_cfg then
	else			
		local item_id = consum_cfg.consume[1].id
		local bag_num = BagData.Instance:GetItemNumInBagById(item_id)
		is_enough = bag_num >= consum_cfg.consume[1].count
		local have_num_rich = string.format("{color;%s;%d}{color;%s;/%d}", is_enough and COLORSTR.GREEN or COLORSTR.RED, bag_num, "e29a45", consum_cfg.consume[1].count)
		RichTextUtil.ParseRichText(self.node_t_list.rich_consum.node, have_num_rich, 20)
	end
end

function CSBloodView:CreateLvView()
	local view = {}
	local lv_list = {}
	local create_c_item = function (idx)
		local angle = 90 - (idx - 1) * (360 / 7)
		local x = 202 + 104 * math.cos(math.rad(angle))
		local y = 305 + 104 * math.sin(math.rad(angle))
		local lv_view = CSLvRender.New()
		lv_view:SetUiConfig(self.ph_list.ph_pro_item, true)
		lv_view:SetAnchorPoint(0.5, 0.5)
		lv_view:GetView():setRotation((idx - 1) * (360 / 7))
		if idx == 4 or idx == 5 then
			y = y + 3
		end
		lv_view:SetPosition(x, y)
		self.node_t_list.layout_show_c.node:addChild(lv_view:GetView(), 999)
		lv_list[idx] = lv_view
	end

	for i = 1, 7 do
		create_c_item(i)
	end

	view.DeleteMe = function ()
		for i,v in pairs(lv_list) do
			v:DeleteMe()
		end
		lv_list = nil
	end

	view.SetLevel = function (lv)
		for idx = 1, 7 do
			for j = 1, 5 do
				lv_list[idx].node_tree["lv" .. j].node:setVisible(lv >= ((idx-1)*5 + j))
			end
		end	
	end

	return view
end


function CSBloodView:CreateAttrList()
	self.attr_list = ListView.New()
	self.need_del_objs.add("attr_list")
	local positionHelper = self.ph_list.ph_curshuxing_list
	self.attr_list:Create(positionHelper.x, positionHelper.y, positionHelper.w, positionHelper.h, nil, ZhanjiangAttrItem, nil, nil, self.ph_list.ph_zhanjiang_attr_item)
	self.node_t_list.layout_right.node:addChild(self.attr_list:GetView(), 100, 100)
	self.attr_list:GetView():setAnchorPoint(0,0)
	self.attr_list:SetItemsInterval(3)
	self.attr_list:JumpToTop(true)
end

function CSBloodView:CreatePreAttrList()
	self.pre_attr_list = ListView.New()
	self.need_del_objs.add("pre_attr_list")
	local positionHelper = self.ph_list.ph_next_attr
	self.pre_attr_list:Create(positionHelper.x, positionHelper.y, positionHelper.w, positionHelper.h, nil, ZhanjiangAttrItem, nil, nil, self.ph_list.ph_zhanjiang_attr_item)
	self.node_t_list.layout_right.node:addChild(self.pre_attr_list:GetView(), 100, 100)
	self.pre_attr_list:GetView():setAnchorPoint(0,0)
	self.pre_attr_list:SetItemsInterval(3)
	self.pre_attr_list:JumpToTop(true)
end

function CSBloodView:CreateCSEquipList()
	local view = {}
	local cell_list = {}

	for i = EquipData.EquipSlot.itHandedDownWeaponPos, EquipData.EquipSlot.itHandedDownShoesPos do
		local cell = BaseCell.New()
		local ph = self.ph_list["ph_cell_" .. i]
		cell:SetPosition(ph.x, ph.y)
		cell:SetAnchorPoint(0.5, 0.5)
		XUI.AddClickEventListener(cell:GetView(), function ()
			self.select_slot = i
			self:Flush()
			if nil == cell.select_effect then
				local size = cell:GetView():getContentSize()
				cell.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("img9_285"), true)
				cell:GetView():addChild(cell.select_effect, 999)
			end

			for slot,cell in pairs(cell_list) do
				if cell.select_effect then
					cell.select_effect:setVisible(slot == i)
				end
			end	
		end)
		self.node_t_list.layout_blood.node:addChild(cell:GetView(), 999, 999)
		cell_list[i] = cell
	end

	view.DeleteMe = function ()
		if cell_list then
			for k,v in pairs(cell_list) do
				v:DeleteMe()
			end
			cell_list = nil
		end
	end

	view.Update = function ()
		for slot,cell in pairs(cell_list) do
			cell:SetData(EquipData.Instance:GetEquipDataBySolt(slot))
			-- cell:SetRemind(nil ~= EquipData.Instance:GetBestCSEquip(EquipData.Instance:GetEquipDataBySolt(slot), slot))
		end	
	end

	return view
end

function CSBloodView:OnBagItemChange()
	self:Flush()
end


function CSLvRender:__init()
end

function CSLvRender:__delete()
end

function CSLvRender:CreateChild()
	BaseRender.CreateChild(self)
end

function CSLvRender:OnFlush()
	if self.data == nil then
		return 
	end
end

return CSBloodView