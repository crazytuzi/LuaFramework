PlayerShenEquipView = PlayerShenEquipView or BaseClass(BaseRender)

local EFFECT_CD = 1

SELECT_INDEX = {
	[7] = 2,
	[6] = 7,
	[4] = 5,
	[9] = 10,
	[2] = 3,
	[1] = 2,
	[3] = 4,
	[8] = 9,
	[5] = 6,
	[0] = 1,
}

function PlayerShenEquipView:__init(instance, parent_view)
	PlayerShenEquipView.Instance = self
	self.parent_view = parent_view

	self.cur_select_index = 0
	self.equip_item_list = {}
	self.is_show_up_arrow = {}
	for i=1, EquipmentShenData.SHEN_EQUIP_NUM do
		self.equip_item_list[i] = ItemCell.New()
		self.equip_item_list[i]:SetInstanceParent(self:FindObj("Item"..i))
		self.equip_item_list[i]:SetToggleGroup(self.root_node.toggle_group)
		self.equip_item_list[i]:ListenClick(BindTool.Bind(self.OnClickItem, self, i - 1))
		self.equip_item_list[i].root_node.toggle.isOn = (self.cur_select_index == i - 1)
		self.equip_item_list[i]:SetInteractable(true)
		self.is_show_up_arrow[i] = self:FindVariable("is_show_up_arrow" .. i)
	end

	self.cur_equip_item = ItemCell.New()
	self.cur_equip_item:SetInstanceParent(self:FindObj("EquipItem"))

	self.consume_item = ItemCell.New()
	self.consume_item:SetInstanceParent(self:FindObj("ConsumeItem"))

	self.capability_text = self:FindVariable("ZhanLi")
	self.is_show_next_level = self:FindVariable("is_show_next_level")
	self.equip_name = self:FindVariable("equip_name")
	self.equip_level = self:FindVariable("equip_level")
	self.equip_index_name = self:FindVariable("equip_index_name")

	self.is_show_maxhp = self:FindVariable("is_show_maxhp")
	self.is_show_gongji = self:FindVariable("is_show_gongji")
	self.is_show_fangyu = self:FindVariable("is_show_fangyu")
	self.is_show_mingzhong = self:FindVariable("is_show_mingzhong")
	self.is_show_shanbi = self:FindVariable("is_show_shanbi")
	self.is_show_baoji = self:FindVariable("is_show_baoji")
	self.is_show_jianren = self:FindVariable("is_show_jianren")

	self.maxhp = self:FindVariable("maxhp")
	self.gongji = self:FindVariable("gongji")
	self.fangyu = self:FindVariable("fangyu")
	self.mingzhong = self:FindVariable("mingzhong")
	self.shanbi = self:FindVariable("shanbi")
	self.baoji = self:FindVariable("baoji")
	self.jianren = self:FindVariable("jianren")

	self.add_maxhp = self:FindVariable("add_maxhp")
	self.add_gongji = self:FindVariable("add_gongji")
	self.add_fangyu = self:FindVariable("add_fangyu")
	self.add_mingzhong = self:FindVariable("add_mingzhong")
	self.add_shanbi = self:FindVariable("add_shanbi")
	self.add_baoji = self:FindVariable("add_baoji")
	self.add_jianren = self:FindVariable("add_jianren")

	self.item_num = self:FindVariable("item_num")
	self.btn_name = self:FindVariable("btn_name")

	self.attr_list = {}
	self.attr_add_list = {}
	self.is_show_attr_add_list = {}
	for i=1, 4 do
		self.attr_list[i] = self:FindVariable("spc_attr_" .. i)
		self.attr_add_list[i] = self:FindVariable("spc_attr_add_" .. i)
		self.is_show_attr_add_list[i] = self:FindVariable("is_show_next_spc_attr" .. i)
	end

	self:ListenEvent("OnSwitchToEquip", BindTool.Bind(self.OnSwitchToEquip, self))
	self:ListenEvent("OnClickUpLevel", BindTool.Bind(self.OnClickUpLevel, self))
	self:ListenEvent("OnClickHelpBtn", BindTool.Bind(self.OnClickHelpBtn, self))
end

function PlayerShenEquipView:__delete()
	for k, v in pairs(self.equip_item_list) do
		v:DeleteMe()
	end
	self.equip_item_list = {}
	self.is_show_up_arrow = {}
	self.parent_view = nil

	self.capability_text = nil
	self.is_show_next_level = nil
	self.equip_level = nil
	self.maxhp = nil
	self.add_maxhp = nil
	self.gongji = nil
	self.add_gongji = nil
	self.fangyu = nil
	self.add_fangyu = nil
	self.item_num = nil
	if self.consume_item then
		self.consume_item:DeleteMe()
		self.consume_item = nil
	end

	if self.cur_equip_item then
		self.cur_equip_item:DeleteMe()
		self.cur_equip_item = nil
	end


	self.attr_list = {}
	self.attr_add_list = {}
end

function PlayerShenEquipView:OpenCallBack()
	if self.is_opening then
		return
	end
	self.is_opening = true
	self:Flush()
end

function PlayerShenEquipView:CloseCallBack()
	EquipmentShenData.Instance:SetSelectedIndex(-1)
end

function PlayerShenEquipView:OnSwitchToEquip()
	self.parent_view:OnSwitchToShenEquip(false)
end

function PlayerShenEquipView:OnClickUpLevel()
	EquipmentShenCtrl.Instance:SendShenzhuangUpLevel(self.cur_select_index)
end

function PlayerShenEquipView:OnClickHelpBtn()
	local tips_id = 220
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function PlayerShenEquipView:OnClickItem(index)
	self.cur_select_index = index
	-- for k,v in pairs(self.equip_item_list) do
	-- 	v:ShowHighLight(index == self.cur_select_index)
	-- end
	self:FlushRightPanel()
end

function PlayerShenEquipView:FlushSelectItem(index)
	self.cur_select_index = index
	local grid_index = SELECT_INDEX[self.cur_select_index]
	self.equip_item_list[grid_index]:SetHighLight(true)
	self:FlushRightPanel()
	EquipmentShenData.Instance:SetSelectedIndex(-1)
end

function PlayerShenEquipView:OnFlush(param_t)
	local index = EquipmentShenData.Instance:GetSelectedIndex() or -1
	self:FlushLeftEquipList()
	self:FlushRightPanel()
	if index ~= -1 then
		self:FlushSelectItem(index)
	end
end

function PlayerShenEquipView:FlushRightPanel()
	local equip_info = EquipmentShenData.Instance:GetEquipData(self.cur_select_index)
	if nil == equip_info then return end

	local equip_info = EquipmentShenData.Instance:GetEquipData(self.cur_select_index)
	local next_cfg = EquipmentShenData.Instance:GetShenzhuangCfg(self.cur_select_index, equip_info.level + 1)
	local cfg = EquipmentShenData.Instance:GetShenzhuangCfg(self.cur_select_index, equip_info.level)
	local cur_select_item_stuff_id = cfg and cfg.stuff_id or (next_cfg and next_cfg.stuff_id) or 0
	local cur_select_item_id = cfg and cfg.pic_id or (next_cfg and next_cfg.pic_id) or 0
	local stuff_item_cfg, stuff_big_type = ItemData.Instance:GetItemConfig(cur_select_item_stuff_id)
	local cur_item_cfg, big_type = ItemData.Instance:GetItemConfig(cur_select_item_id)
	if cur_item_cfg then
		self.cur_equip_item:SetAsset(ResPath.GetItemIcon(cur_item_cfg.icon_id))
	end
	if stuff_item_cfg then
		self.consume_item:SetAsset(ResPath.GetItemIcon(stuff_item_cfg.icon_id))
	end

	-- self.cur_equip_item:ShowStrengthLable(equip_info.level > 0)
	-- self.cur_equip_item:SetStrength(equip_info.level)

	local color = math.ceil(equip_info.level / 5)
	color = color <= 6 and color or 6
	color = color > 0 and color or 1
	self.cur_equip_item:SetQualityByColor(color > 0 and color or 1)
	self.cur_equip_item:ShowQuality(color > 0)
	--self.cur_equip_item:SetIconGrayScale(equip_info.level <= 0)

	local cfg = EquipmentShenData.Instance:GetShenzhuangCfg(self.cur_select_index, equip_info.level)
	local attr = CommonDataManager.GetAttributteByClass(cfg)

	self.maxhp:SetValue(attr.max_hp)
	self.gongji:SetValue(attr.gong_ji)
	self.fangyu:SetValue(attr.fang_yu)
	self.mingzhong:SetValue(attr.ming_zhong)
	self.shanbi:SetValue(attr.shan_bi)
	self.baoji:SetValue(attr.bao_ji)
	self.jianren:SetValue(attr.jian_ren)

	for i=1, 4 do
		local str = "red_ratio_" .. i
		if i > 3 then
			str = "pink_ratio"
		end
		local cur_value = (cfg and cfg[str] or 0) / 100
		self.attr_list[i]:SetValue(cur_value)
	end

	local next_cfg = EquipmentShenData.Instance:GetShenzhuangCfg(self.cur_select_index, equip_info.level + 1)
	local next_attr = CommonDataManager.GetAttributteByClass(next_cfg)

	local name = nil ~= cfg and cfg.name or (next_cfg and next_cfg.name) or ""
	local name_str = "<color=" .. SOUL_NAME_COLOR[color] .. ">" .. name .. "</color>"
	self.equip_name:SetValue(name_str)
	self.equip_level:SetValue(equip_info.level > 0 and  "+" .. equip_info.level or "")
	self.equip_index_name:SetValue(Language.Forge.EquipName[self.cur_select_index])

	self.is_show_next_level:SetValue(nil ~= next_cfg)
	self.is_show_maxhp:SetValue(attr.max_hp > 0 or next_attr.max_hp > 0)
	self.is_show_gongji:SetValue(attr.gong_ji > 0 or next_attr.gong_ji > 0)
	self.is_show_fangyu:SetValue(attr.fang_yu > 0 or next_attr.fang_yu > 0)
	self.is_show_mingzhong:SetValue(attr.ming_zhong > 0 or next_attr.ming_zhong > 0)
	self.is_show_shanbi:SetValue(attr.shan_bi > 0 or next_attr.shan_bi > 0)
	self.is_show_baoji:SetValue(attr.bao_ji > 0 or next_attr.bao_ji > 0)
	self.is_show_jianren:SetValue(attr.jian_ren > 0 or next_attr.jian_ren > 0)

	if nil == next_cfg then
		return
	end

	local dif_attr = CommonDataManager.LerpAttributeAttr(attr, next_attr)
	self.add_maxhp:SetValue(dif_attr.max_hp)
	self.add_gongji:SetValue(dif_attr.gong_ji)
	self.add_fangyu:SetValue(dif_attr.fang_yu)
	self.add_mingzhong:SetValue(dif_attr.ming_zhong)
	self.add_shanbi:SetValue(dif_attr.shan_bi)
	self.add_baoji:SetValue(dif_attr.bao_ji)
	self.add_jianren:SetValue(dif_attr.jian_ren)

	for i=1, 4 do
		local dif, to_level = EquipmentShenData.Instance:GetNextUpSpecialAttr(self.cur_select_index, equip_info.level, i)
		self.is_show_attr_add_list[i]:SetValue(dif > 0)
		local str ="<color=" .. TEXT_COLOR.BLUE_4 ..">" .. dif / 100 .. "%</color>" .. "(" .. "<color=" .. TEXT_COLOR.RED .. ">" .. equip_info.level .. "</color>" ..  " / " .. to_level .. Language.Common.Ji ..")"
		self.attr_add_list[i]:SetValue(str)
	end

	local data = {}
	data.item_id = cfg and cfg.stuff_id or next_cfg.stuff_id
	data.num = 0
	local num = ItemData.Instance:GetItemNumInBagById(data.item_id)
	self.consume_item:SetShowNumTxtLessNum(0)
	self.consume_item:SetData(data)
	--self.consume_item:SetIconGrayScale(num <= 0)
	--self.consume_item:ShowQuality(num > 0)

	local txt_color = num >= next_cfg.stuff_num and TEXT_COLOR.BLUE_5 or TEXT_COLOR.RED
	self.item_num:SetValue( "(" .. "<color=" .. txt_color .. ">" .. num .. "</color>".. " / " .. next_cfg.stuff_num .. ")" )
	self.btn_name:SetValue(equip_info.level > 0 and Language.Common.Up or Language.Common.Activate)
end

function PlayerShenEquipView:FlushLeftEquipList()

	for i = 1, EquipmentShenData.SHEN_EQUIP_NUM do
		local index = i - 1
		if self.equip_item_list[i] then


			local equip_info = EquipmentShenData.Instance:GetEquipData(index)
			self.equip_item_list[i]:ShowStrengthLable(equip_info.level > 0)
			self.equip_item_list[i]:SetStrength(equip_info.level)

			local color = math.ceil(equip_info.level / 5)
			color = color <= 6 and color or 6
			self.equip_item_list[i]:SetQualityByColor(color > 0 and color or 1)
			self.equip_item_list[i]:ShowQuality(color > 0)
			self.equip_item_list[i]:SetIconGrayScale(equip_info.level <= 0)
			self.equip_item_list[i]:SetDefualtBgState(equip_info.level > 0)

			local next_cfg = EquipmentShenData.Instance:GetShenzhuangCfg(index, equip_info.level + 1)
			if nil ~= next_cfg then
				local num = ItemData.Instance:GetItemNumInBagById(next_cfg.stuff_id)
				self.is_show_up_arrow[i]:SetValue(num >= next_cfg.stuff_num)
			else
				self.is_show_up_arrow[i]:SetValue(false)
			end
			local cfg = EquipmentShenData.Instance:GetShenzhuangCfg(index, equip_info.level)
			local item_id = (cfg and cfg.pic_id) or (next_cfg and next_cfg.pic_id) or 0

			local item_cfg, big_type = ItemData.Instance:GetItemConfig(item_id)
			if item_cfg and equip_info.level > 0 then
				self.equip_item_list[i]:SetAsset(ResPath.GetItemIcon(item_cfg.icon_id))
			end
		end
	end
	local capability = EquipmentShenData.Instance:GetShenEquipTotalCapability()
	self.capability_text:SetValue(capability)
end