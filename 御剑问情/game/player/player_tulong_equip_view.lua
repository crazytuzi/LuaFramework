TulongEquipView = TulongEquipView or BaseClass(BaseRender)
local TOGGLE_TL = 1
local TOGGLE_CS = 2
function TulongEquipView:__init(instance, parent_view)
	TulongEquipView.Instance = self
	self.parent_view = parent_view
	self.tab_index = TOGGLE_TL
	self.cur_select_index = 0
	self.equip_item_list = {}
	self.is_show_up_arrow = {}
	self.equipicon = {}
	for i=1, TulongEquipData.EQUIP_MAX_PART do
		self.equip_item_list[i] = ItemCell.New()
		self.equip_item_list[i]:SetInstanceParent(self:FindObj("Item"..i))
		self.equip_item_list[i]:SetToggleGroup(self.root_node.toggle_group)
		self.equip_item_list[i]:ListenClick(BindTool.Bind(self.OnClickItem, self, i - 1))
		self.equip_item_list[i].root_node.toggle.isOn = (self.cur_select_index == i - 1)
		self.equip_item_list[i]:SetInteractable(true)
		self.is_show_up_arrow[i] = self:FindVariable("is_show_up_arrow" .. i)
		self.equipicon[i] = self:FindVariable("equipicon" .. i)
	end

	self.cur_equip_item = ItemCell.New()
	self.cur_equip_item:SetInstanceParent(self:FindObj("EquipItem"))

	self.consume_item = ItemCell.New()
	self.consume_item:SetInstanceParent(self:FindObj("ConsumeItem"))

	self.tab1 = self:FindObj("Tab1")
	self.tab2 = self:FindObj("Tab2")

	self.capability_text = self:FindVariable("ZhanLi")
	self.is_show_next_level = self:FindVariable("is_show_next_level")
	self.equip_name = self:FindVariable("equip_name")
	self.equip_level = self:FindVariable("equip_level")

	self.is_show_maxhp = self:FindVariable("is_show_maxhp")
	self.is_show_gongji = self:FindVariable("is_show_gongji")
	self.is_show_fangyu = self:FindVariable("is_show_fangyu")
	self.is_show_mingzhong = self:FindVariable("is_show_mingzhong")
	self.is_show_shanbi = self:FindVariable("is_show_shanbi")
	self.is_show_baoji = self:FindVariable("is_show_baoji")
	self.is_show_jianren = self:FindVariable("is_show_jianren")
	self.tulong_red = self:FindVariable("TulongRed")
	self.chuanshi_red = self:FindVariable("ChuanshiRed")
	self.show_special_attr = self:FindVariable("ShowSpecialAttr")
	self.special_title_name = self:FindVariable("SpecialTitleName")
	self.show_sp_attr_bg = self:FindVariable("ShowSpAttrBg")
	self.is_show_sp_title_bg = self:FindVariable("is_show_sp_title_bg")

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
	self:FlushRemind()

	self.attr_list = {}
	self.attr_add_list = {}
	self.is_show_attr_add_list = {}
	self.special_name_list = {}
	for i=1, 3 do
		self.attr_list[i] = self:FindVariable("spc_attr_" .. i)
		self.attr_add_list[i] = self:FindVariable("spc_attr_add_" .. i)
		self.is_show_attr_add_list[i] = self:FindVariable("is_show_next_spc_attr" .. i)
		self.special_name_list[i] = self:FindVariable("SpecialAttrName" .. i)
	end

	self:ListenEvent("OnClickUpLevel", BindTool.Bind(self.OnClickUpLevel, self))
	self:ListenEvent("OnClickHelpBtn", BindTool.Bind(self.OnClickHelpBtn, self))
	self:ListenEvent("OnClickTulong", BindTool.Bind(self.OnClickTulong, self))
	self:ListenEvent("OnClickChuanshi", BindTool.Bind(self.OnClickChuanshi, self))
end

function TulongEquipView:__delete()
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

function TulongEquipView:OpenCallBack(show_index)
	if show_index == TabIndex.role_chuanshi_equip then
		self.tab_index = TOGGLE_CS
		self.tab2.toggle.isOn = true
	else
		self.tab_index = TOGGLE_TL
		self.tab1.toggle.isOn = true
	end
	self:Flush()
end

function TulongEquipView:OnClickUpLevel()
	if self.tab_index == TOGGLE_TL then
		TulongEquipCtrl.Instance:SendTulongUpLevel(self.cur_select_index)
	elseif self.tab_index == TOGGLE_CS then
		TulongEquipCtrl.Instance:SendChuanshiUpLevel(self.cur_select_index)
	end
end

function TulongEquipView:OnClickTulong()
	self.tab_index = TOGGLE_TL
	self:Flush()
end

function TulongEquipView:OnClickChuanshi()
	self.tab_index = TOGGLE_CS
	self:Flush()
end

function TulongEquipView:OnClickHelpBtn()
	local tips_id = 234
	if self.tab_index == TOGGLE_CS then
		tips_id = 235
	end
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function TulongEquipView:OnClickItem(index)
	self.cur_select_index = index
	for k,v in pairs(self.equip_item_list) do
		v:ShowHighLight(index == self.cur_select_index)
	end
	self:FlushRightPanel()
end

function TulongEquipView:OnFlush(param_t)
	self:FlushLeftEquipList()
	self:FlushRightPanel()
end

function TulongEquipView:FlushRemind()
	self.tulong_red:SetValue(RemindManager.Instance:GetRemind(RemindName.TulongEquip))
	self.chuanshi_red:SetValue(RemindManager.Instance:GetRemind(RemindName.CSTulongEquip))
end

local attr_extra_t = {"extra_gongji", "extra_fangyu", "extra_maxhp", }
function TulongEquipView:FlushRightPanel()
	self.show_special_attr:SetValue(self.tab_index == TOGGLE_TL)
	self.is_show_sp_title_bg:SetValue(self.tab_index == TOGGLE_TL)
	-- self.special_title_name:SetValue(Language.Role.TulongSpecialTitleName[self.tab_index] or Language.Role.TulongSpecialTitleName[1])
	local equip_info = TulongEquipData.Instance:GetEquipData(self.tab_index, self.cur_select_index)
	if nil == equip_info then return end
	local asset, bundle = TulongEquipData.Instance:GetTulongEquipIconRes(self.tab_index, self.cur_select_index)
	self.cur_equip_item:SetAsset(asset, bundle)

	local color = math.ceil(equip_info.level / 5)
	color = color <= 6 and color or 6
	color = color > 0 and color or 1
	self.cur_equip_item:SetQualityByColor(color > 0 and color or 1)
	self.cur_equip_item:ShowQuality(color > 0)
	--self.cur_equip_item:SetIconGrayScale(equip_info.level <= 0)

	local cfg = TulongEquipData.Instance:GetShenzhuangCfg(self.tab_index, self.cur_select_index, equip_info.level)
	local attr = CommonDataManager.GetAttributteByClass(cfg)

	self.maxhp:SetValue(attr.max_hp)
	self.gongji:SetValue(attr.gong_ji)
	self.fangyu:SetValue(attr.fang_yu)
	self.mingzhong:SetValue(attr.ming_zhong)
	self.shanbi:SetValue(attr.shan_bi)
	self.baoji:SetValue(attr.bao_ji)
	self.jianren:SetValue(attr.jian_ren)

	for i=1, 3 do
		local spec_key = attr_extra_t[i] or attr_extra_t[1]
		local cur_value = (cfg and cfg[spec_key] or 0)
		self.attr_list[i]:SetValue(cur_value)
	end

	local next_cfg = TulongEquipData.Instance:GetShenzhuangCfg(self.tab_index, self.cur_select_index, equip_info.level + 1)
	local next_attr = CommonDataManager.GetAttributteByClass(next_cfg)

	local name = nil ~= cfg and cfg.name or next_cfg.name
	local name_str = "<color=" .. SOUL_NAME_COLOR[color] .. ">" .. name .. "</color>"
	self.equip_name:SetValue(name_str)
	self.equip_level:SetValue(equip_info.level > 0 and  "+" .. equip_info.level or "")

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

	if self.tab_index == TOGGLE_TL then
		for i=1, 3 do
			local spec_key = attr_extra_t[i] or attr_extra_t[1]
			local dif, to_level = TulongEquipData.Instance:GetNextUpSpecialAttr(self.cur_select_index, equip_info.level, spec_key)
			self.is_show_attr_add_list[i]:SetValue(dif > 0)
			local str = "<color=#0000F1FF>".. dif .. "</color> (<color=" .. TEXT_COLOR.RED .. ">" .. equip_info.level .. "</color> / " .. to_level .. Language.Common.Ji ..")"
			self.attr_add_list[i]:SetValue(str)
			self.special_name_list[i]:SetValue(Language.Role.TulongSpecialNameList[spec_key] or "")
		end
	end

	local data = {}
	data.item_id = cfg and cfg.stuff_id or next_cfg.stuff_id
	data.num = 0
	local num = ItemData.Instance:GetItemNumInBagById(data.item_id)
	self.consume_item:SetShowNumTxtLessNum(0)
	self.consume_item:SetData(data)

	local txt_color = num >= next_cfg.stuff_num and TEXT_COLOR.TONGYONG_TS or TEXT_COLOR.RED
	self.item_num:SetValue("(<color=" .. txt_color .. ">" ..  num .. "</color>" .. " / " .. next_cfg.stuff_num .. ")" )
	self.btn_name:SetValue(equip_info.level > 0 and Language.Common.Up or Language.Common.Activate)
end

function TulongEquipView:FlushLeftEquipList()
	for i = 1, TulongEquipData.EQUIP_MAX_PART do
		local index = i - 1
		if self.equip_item_list[i] then
			local equip_info = TulongEquipData.Instance:GetEquipData(self.tab_index, index)
			self.equip_item_list[i]:ShowStrengthLable(equip_info.level > 0)
			self.equip_item_list[i]:SetStrength(equip_info.level)

			local color = math.ceil(equip_info.level / 5)
			color = color <= 6 and color or 6
			self.equip_item_list[i]:SetQualityByColor(color > 0 and color or 1)
			self.equip_item_list[i]:ShowQuality(color > 0)
			self.equip_item_list[i]:SetIconGrayScale(equip_info.level <= 0)
			self.equip_item_list[i]:SetDefualtBgState(equip_info.level > 0)

			if equip_info.level > 0 then
				local asset, bundle = TulongEquipData.Instance:GetTulongEquipIconRes(self.tab_index, index)
				self.equip_item_list[i]:SetAsset(asset, bundle)
			else
				self.equip_item_list[i]:ResetIconAsset()
			end

			self.equipicon[i]:SetValue(equip_info.level <= 0)

			local next_cfg = TulongEquipData.Instance:GetShenzhuangCfg(self.tab_index, index, equip_info.level + 1)
			if nil ~= next_cfg then
				local num = ItemData.Instance:GetItemNumInBagById(next_cfg.stuff_id)
				self.is_show_up_arrow[i]:SetValue(num >= next_cfg.stuff_num)
			else
				self.is_show_up_arrow[i]:SetValue(false)
			end
		end
	end
	local capability = TulongEquipData.Instance:GetShenEquipTotalCapability(self.tab_index)
	self.capability_text:SetValue(capability)
end

