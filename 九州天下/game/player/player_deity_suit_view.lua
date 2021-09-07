--征途套装
PlayerDeitySuitView = PlayerDeitySuitView or BaseClass(BaseRender)

local EFFECT_CD = 1

function PlayerDeitySuitView:__init(instance)
	PlayerDeitySuitView.Instance = self

	self.cur_select_index = 0
	self.equip_item_list = {}
	self.is_show_up_arrow = {}

	local bunble, asset = ResPath.GetImages("bg_cell_equip")

	for i=1, DeitySuitData.SHEN_EQUIP_NUM do
		local index = i - 1
		local equip_type = index == GameEnum.EQUIP_INDEX_JIEZHI and GameEnum.EQUIP_INDEX_YAODAI or index
		self.equip_item_list[i] = ItemCell.New()
		self.equip_item_list[i]:SetInstanceParent(self:FindObj("Item"..i))
		self.equip_item_list[i]:SetItemCellBg(bunble, asset)
		self.equip_item_list[i]:SetToggleGroup(self.root_node.toggle_group)
		self.equip_item_list[i]:ListenClick(BindTool.Bind(self.OnClickItem, self, equip_type))
		self.equip_item_list[i].root_node.toggle.isOn = (self.cur_select_index == equip_type)
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

	self.display = self:FindObj("Display")

	self:ListenEvent("OnSwitchToEquip", BindTool.Bind(self.OnSwitchToEquip, self))
	self:ListenEvent("OnClickUpLevel", BindTool.Bind(self.OnClickUpLevel, self))
	self:ListenEvent("OnClickHelpBtn", BindTool.Bind(self.OnClickHelpBtn, self))
end

function PlayerDeitySuitView:__delete()
	for k, v in pairs(self.equip_item_list) do
		v:DeleteMe()
	end
	self.equip_item_list = {}
	self.is_show_up_arrow = {}

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

	if nil ~= self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	self.attr_list = {}
	self.attr_add_list = {}
end

function PlayerDeitySuitView:OpenCallBack()
	if self.is_opening then
		return
	end
	self.is_opening = true
	self:Flush()
end

function PlayerDeitySuitView:OnSwitchToEquip()
	local player_view = PlayerCtrl.Instance:GetView()
	player_view:OnSwitchToShenEquip(false)
end

function PlayerDeitySuitView:OnClickUpLevel()
	DeitySuitCtrl.Instance:SendShenzhuangUpLevel(self.cur_select_index)
end

function PlayerDeitySuitView:OnClickHelpBtn()
	local tips_id = 218
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function PlayerDeitySuitView:OnClickItem(index)
	self.cur_select_index = index
	for k,v in pairs(self.equip_item_list) do
		v:ShowHighLight(index == self.cur_select_index)
	end
	self:FlushRightPanel()
end

function PlayerDeitySuitView:OnFlush(param_t)
	self:FlushLeftEquipList()
	self:FlushRightPanel()
end

function PlayerDeitySuitView:FlushRightPanel()
	local equip_info = DeitySuitData.Instance:GetEquipData(self.cur_select_index)
	if nil == equip_info then return end

	local color = math.ceil(equip_info.level / 5)
	color = color <= 6 and color or 6
	color = color > 0 and color or 1

	local cfg = DeitySuitData.Instance:GetShenzhuangCfg(self.cur_select_index, equip_info.level)
	local attr = CommonDataManager.GetAttributteByClass(cfg)

	self.maxhp:SetValue(attr.max_hp)
	self.gongji:SetValue(attr.gong_ji)
	self.fangyu:SetValue(attr.fang_yu)
	self.mingzhong:SetValue(attr.ming_zhong)
	self.shanbi:SetValue(attr.shan_bi)
	self.baoji:SetValue(attr.bao_ji)
	self.jianren:SetValue(attr.jian_ren)

	for i=1, 4 do
		local cur_value
		if i < 4 then
			cur_value = (cfg and cfg["red_ratio_" .. i] or 0) / 100
		else
			cur_value = (cfg and cfg["pink_ratio"] or 0) / 100
		end
		self.attr_list[i]:SetValue(cur_value)
	end
	   
	local next_cfg = DeitySuitData.Instance:GetShenzhuangCfg(self.cur_select_index, equip_info.level + 1)
	local next_attr = CommonDataManager.GetAttributteByClass(next_cfg)

	local name = nil ~= cfg and cfg.name or next_cfg.name
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

	-- if nil == next_cfg then
	-- 	return
	-- end

	local dif_attr = CommonDataManager.LerpAttributeAttr(attr, next_attr)
	self.add_maxhp:SetValue(dif_attr.max_hp)
	self.add_gongji:SetValue(dif_attr.gong_ji)
	self.add_fangyu:SetValue(dif_attr.fang_yu)
	self.add_mingzhong:SetValue(dif_attr.ming_zhong)
	self.add_shanbi:SetValue(dif_attr.shan_bi)
	self.add_baoji:SetValue(dif_attr.bao_ji)
	self.add_jianren:SetValue(dif_attr.jian_ren)

	for i=1, 4 do
		local dif, to_level = DeitySuitData.Instance:GetNextUpSpecialAttr(self.cur_select_index, equip_info.level, i)
		self.is_show_attr_add_list[i]:SetValue(dif > 0)
		local str = "<color=#551800FF>".. dif / 100 .. "%</color>" .. "(" .. "<color=" .. TEXT_COLOR.RED .. ">" .. equip_info.level .. "</color>" ..  "/" .. to_level .. Language.Common.Ji ..")"
		self.attr_add_list[i]:SetValue(str)
	end

	local data = {}
	data.item_id = cfg and cfg.stuff_id or next_cfg.stuff_id
	data.num = 0
	local num = ItemData.Instance:GetItemNumInBagById(data.item_id)
	self.consume_item:SetShowNumTxtLessNum(0)
	self.consume_item:SetData(data)
	--self.consume_item:SetAsset(ResPath.GetItemIcon(data.item_id))

	self.cur_equip_item:SetAsset(ResPath.GetItemIcon(data.item_id))
	self.cur_equip_item:ShowStrengthLable(equip_info.level > 0)
	self.cur_equip_item:SetStrength(equip_info.level)
	self.cur_equip_item:QualityColor(color > 0 and color or 1)
	self.cur_equip_item:ShowQuality(color > 0)

	if next_cfg then
		local txt_color = num >= next_cfg.stuff_num and TEXT_COLOR.GREEN or TEXT_COLOR.RED
		self.item_num:SetValue("<color=" .. txt_color .. ">" .. "(" .. num .. "/" .. next_cfg.stuff_num .. ")" .. "</color>")
		self.btn_name:SetValue(equip_info.level > 0 and Language.Common.Up or Language.Common.Activate)
	end
end

function PlayerDeitySuitView:FlushLeftEquipList()
	if not self.role_model then
		self.role_model = RoleModel.New()
		self.role_model:SetDisplay(self.display.ui3d_display)
	end
	if self.role_model then
		local role_vo = GameVoManager.Instance:GetMainRoleVo()
		self.role_model:RemoveMount()
		self.role_model:ResetRotation()
		self.role_model:SetModelResInfo(role_vo, nil, true, nil, nil, true)
	end

	for i = 1, DeitySuitData.SHEN_EQUIP_NUM do
		local index = i - 1
		local equip_type = index == GameEnum.EQUIP_INDEX_JIEZHI and GameEnum.EQUIP_INDEX_YAODAI or index
		if self.equip_item_list[i] then
			local equip_info = DeitySuitData.Instance:GetEquipData(equip_type)
			local next_cfg = DeitySuitData.Instance:GetShenzhuangCfg(equip_type, equip_info.level + 1)
			local last_cfg = DeitySuitData.Instance:GetShenzhuangCfg(equip_type, equip_info.level)

			self.equip_item_list[i]:ShowStrengthLable(equip_info.level > 0)
			self.equip_item_list[i]:SetStrength(equip_info.level)

			local color = math.ceil(equip_info.level / 5)
			color = color <= 6 and color or 6
			self.equip_item_list[i]:ShowQuality(color > 0)
			self.equip_item_list[i]:QualityColor(color > 0 and color or 1)
			self.equip_item_list[i]:SetIconGrayScale(equip_info.level <= 0)

			if nil ~= next_cfg then
				local num = ItemData.Instance:GetItemNumInBagById(next_cfg.stuff_id)
				local role_vo = GameVoManager.Instance:GetMainRoleVo()
				self.is_show_up_arrow[i]:SetValue(num >= next_cfg.stuff_num and role_vo.level >= 50)
				self.equip_item_list[i]:SetAsset(ResPath.GetItemIcon(next_cfg.stuff_id))
			else
				self.is_show_up_arrow[i]:SetValue(false)
				self.equip_item_list[i]:SetAsset(ResPath.GetItemIcon(last_cfg.stuff_id))
			end
		end
	end
	local capability = DeitySuitData.Instance:GetShenEquipTotalCapability()
	self.capability_text:SetValue(capability)
end