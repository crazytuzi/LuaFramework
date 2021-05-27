TipSubAttr = TipSubAttr or BaseClass(TipSub)

TipSubAttr.SIZE = cc.size(462, 370)
TipSubAttr.SIZE2 = cc.size(462, 220)	-- 展示特效时最大宽高，避免溢出屏幕

TipSubAttr.LINE_HEIGHT = 25	-- 单元行高度
TipSubAttr.LINE_WIDTH = 430	-- 单元行宽度
TipSubAttr.INDENT = 30		-- 缩进

TipSubAttr.ATTRS = {
	"ATTR_BASE",
	--"ATTR_QIANGHUA", --强化属性与基础属性房子一起，不做单独处理
	-- "ATTR_JIANDING",
	"ATTR_GANGWEN",
	"ATTR_MEIBA",
	"ATTR_APOTHEOSIS",
	"ATTR_SOUL",
	"ATTR_BAOSHI",
	"ATTR_SHENQI",
	"ATTR_FUSION",
	"ATTR_SHENZHU",
	"ATTR_SHENGE",
	"ATTR_SUIT",
	"ATTR_SPECIALRING",
	"ATTR_RECYCLE",
}

function TipSubAttr:__init()
	self.y_order = 10
	self.is_ignore_height = false
	self.cell_list = {}
end

function TipSubAttr:__delete()
end

function TipSubAttr:SetData(data, fromView, param_t)
	self.data = data
	self.fromView = fromView or EquipTip.FROM_NORMAL
	self.handle_param_t = param_t or {}
	self.item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	self.item_color3b = Str2C3b(string.sub(string.format("%06x", self.item_cfg.color), 1, 6))
	self.item_prof_limit = self.data.pro or ItemData.Instance:GetItemLimit(self.data.item_id, ItemData.UseCondition.ucJob)
	self.limit_level = ItemData.Instance:GetItemLimit(self.data.item_id, ItemData.UseCondition.ucLevel) or 0
	self.circle_level = ItemData.Instance:GetItemLimit(self.data.item_id, ItemData.UseCondition.ucMinCircle) or 0


	self:Flush()
	if ItemData.GetIsFashion(data.item_id) or ItemData.GetIsHuanWu(data.item_id) then
		local item_type = {[120] = 1, [121] = 1} -- 暂时屏蔽 时装幻武
		if item_type[self.item_cfg.type] == nil then
			self.cd_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.UpdateCdTime, self),1)
		end
	end

	if ItemData.IsJinYanZhuUseItemType(self.item_cfg.type) then
		EventProxy.New(BagData.Instance, self):AddEventListener(BagData.DURABILITY_CHANGE, BindTool.Bind(self.OnItemDurabilityChange, self))
	end
end

function TipSubAttr:Release()
	self.scroll_view = nil
	if self.fight_power_view then
		self.fight_power_view:DeleteMe()
		self.fight_power_view = nil
	end
	self.time_layout = nil

	if self.cell_list then
		for i,v in ipairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = nil
	end

	if self.cd_timer then
		GlobalTimerQuest:CancelQuest(self.cd_timer) -- 取消计时器任务
		self.cd_timer = nil
	end
	self.rich_content = nil
	self.rich_cell2 = nil
end

function TipSubAttr:CreateChild()
	TipSubAttr.super.CreateChild(self)

	self.scroll_view = XUI.CreateScrollView(0, 10, 0, 0, ScrollDir.Vertical)
	self.scroll_view:setAnchorPoint(0, 0)
	self.scroll_view:setBounceEnabled(true)
	self.view:addChild(self.scroll_view)

	self.fight_power_view = FightPowerView.New(BaseTip.WIDTH / 2, 0, self.view, 11, false)
	self.fight_power_view:SetScale(1)
	local power_view = self.fight_power_view:GetView()
	local bg = XUI.CreateImageView(0, 0, ResPath.GetCommon("bg_4"), true)
	bg:setScale(1.1)
	power_view:addChild(bg, 0)

end

function TipSubAttr:CreateRichText(...)
	local rich = XUI.CreateRichText(...)
	rich:setAnchorPoint(0, 1)
	self.view:addChild(rich)
	return rich
end

function TipSubAttr:OnFlush()
	-- 先清空所有单元
	self.scroll_view:removeAllChildren()
	self.line_tag = 0
	self.attrslist = {}

	local total_attrs = {}
	self:CreateTextRichCell({x = TipSubAttr.INDENT, height = 8}) -- 空行
	for i, v in ipairs(TipSubAttr.ATTRS) do
		local attrs = self["Parse_" .. v](self)	-- 解析内容
		if nil ~= attrs then
			total_attrs = CommonDataManager.AddAttr(total_attrs, attrs) -- 累加属性
		end
	end
	self:CreateTextRichCell({x = TipSubAttr.INDENT, height = 8}) -- 空行

	
	if ItemData.GetIsFashion(self.data.item_id) or ItemData.GetIsHuanWu(self.data.item_id) then
		local item_type = {[120] = 1, [121] = 1} -- 暂时屏蔽 时装幻武
		if item_type[self.item_cfg.type] == nil then
			self.rich_content = self:CreateTextRichCell({x = TipSubAttr.INDENT, height = TipSubAttr.LINE_HEIGHT + 4}) -- 空行
			self:UpdateCdTime()
		end
	end
	-- 排列所有单元行内容
	table.sort(self.attrslist, function(a, b) return a.line_tag > b.line_tag end)
	local base_y = 0
	local one_h = 0
	for k, v in pairs(self.attrslist) do
		if nil ~= v.align_data.height then-- 有指定高度
			one_h = v.align_data.height
		else-- 没有指定高度的用富文本计算的高度
			v:refreshView()
			one_h = v:getInnerContainerSize().height
		end
		base_y = base_y + one_h + 0
		v:setPosition(v.align_data.x, base_y)
	end

	-- 计算滚动列表的内容大小
	local is_show_top_eff = self.item_cfg.showQualityBg == 9
	local max_h = is_show_top_eff and TipSubAttr.SIZE2.height or TipSubAttr.SIZE.height
	self.scroll_view:setContentWH(TipSubAttr.SIZE.width, base_y > max_h and max_h or base_y)
	self.scroll_view:setInnerContainerSize(cc.size(TipSubAttr.SIZE.width, base_y))
	self.scroll_view:jumpToTop()
	local scroll_v_height = self.scroll_view:getContentSize().height
	-- 战斗力
	local fight_power_view_h = 58
	if ItemData.IsJinYanZhuUseItemType(self.item_cfg.type) then
		fight_power_view_h = 0
		self.fight_power_view:GetView():setVisible(false)
	else
		self.fight_power_view:GetView():setVisible(true)
		local total_score = CommonDataManager.GetAttrSetScore(total_attrs, self.item_prof_limit)

		local f_off_y = is_show_top_eff and 20 or 0
		self.fight_power_view:GetView():setPositionY(scroll_v_height + fight_power_view_h / 2 + f_off_y)
		self.fight_power_view:SetNumber(total_score)

		--神器调用特殊获取战力方法
		if self.data.socre then
			self.fight_power_view:SetNumber(self.data.socre)
		end

		if self.data.type == ItemData.ItemType.itSpecialRing then
			self.fight_power_view:SetNumber(SpecialRingData.GetSpecialRingPower(self.data))
		end
	end
	-- 内容总高度
	self.content_height = scroll_v_height + fight_power_view_h + 10
end

-- 创建单元行
-- value = 
-- {
-- label = { key, color} 
-- img = path 
-- imgs = {path, ...} 
-- }
function TipSubAttr:CreateTextRichCell(value)
	value.x = value.x or TipSubAttr.INDENT
	value.height = value.height or TipSubAttr.LINE_HEIGHT

	local rich_content = XUI.CreateRichText(0, 0, TipSubAttr.LINE_WIDTH, 0)
	rich_content:setAnchorPoint(cc.p(0, 0))

	if value.img then 
		local sprite = XImage:create(value.img.path, true)
		if nil ~= sprite then
			if value.img.is_grey then
				sprite:setGrey(true)
			end
			local x = value.img.x or 0
			local y = value.img.y or 0
			sprite:setPosition(x, y)
			local layout = XUI.CreateLayout(20, 0, 20, value.height)
			layout:addChild(sprite, 99, 99)
			XUI.RichTextAddElement(rich_content, layout)
		end
	end

	if value.imgs then 
		local layout = XUI.CreateLayout(0, 0, 0, 2 * TipSubAttr.LINE_HEIGHT)
		for k, v in pairs(value.imgs) do
			local sprite = XImage:create(v, true)
			if nil ~= sprite then
				sprite:setScale(0.8)
				sprite:setPosition(30 + (k - 1) * 30, 1.5 * TipSubAttr.LINE_HEIGHT)
				layout:addChild(sprite, 99, 99)
			end
		end
		XUI.RichTextAddElement(rich_content, layout)
	end

	if value.line then
		value.height = 14
		local layout = XUI.CreateLayout(0, 0, 0, value.height)
		local sprite = XImage:create(ResPath.GetCommon("line_05"), true)
		sprite:setPosition(BaseTip.WIDTH / 2, value.height / 2)
		layout:addChild(sprite)
		XUI.RichTextAddElement(rich_content, layout)
	end

	if value.title then
		value.height = TipSubAttr.LINE_HEIGHT + 4
		value.title = "{image;".. ResPath.GetCommon("orn_123") ..";0, 20;1;-10}" .. value.title
		RichTextUtil.ParseRichText(rich_content, value.title,  20, Str2C3b("dcb73d"))
	end

	if value.label then
		local len = #value.label
		for i = 1, len do
			local temp = value.label[i]
			if temp and temp.key then
				XUI.RichTextAddText(rich_content, temp.key, COMMON_CONSTS.FONT, 18, temp.color or Str2C3b("9c9181"))
			end
		end
	end
	if value.title_text  then
		value.title_text = "{image;".. ResPath.GetCommon("orn_123") ..";0, 20;1;-10}" .. value.title_text
		RichTextUtil.ParseRichText(rich_content, value.title_text,  20, Str2C3b("dcb73d"))
	end

	if value.dec  then

		RichTextUtil.ParseRichText(rich_content, value.dec.key, value.dec.size or 20, Str2C3b("dcb73d"))
		-- rich_content:setVerticalSpace(TipSubAttr.LINE_HEIGHT - 20)
	end

	if value.special_ring then
		local layout = XUI.CreateLayout(0, 0, 0, 60)
		local cell = BaseCell.New()
		cell:SetIsShowTips(false)
		cell:SetData(value.special_ring)
		cell:GetView():setScale(0.75)
		layout:addChild(cell:GetView(), 2)

		local rich_name = XUI.CreateRichText()
		local rich_type = XUI.CreateRichText()
		local item_color3b = Str2C3b(string.sub(string.format("%06x", value.special_ring.color), 1, 6))
		local cfg = SpecialRingHandleCfg or {}
		local type_name = cfg.type_name and cfg.type_name[value.special_ring.useType or 0] or ""
		local color = "e5e3cb"
		local normal_color = Str2C3b("dcb73d")
		local str_type = string.format("类型：{color;%s;%s}", color, type_name or "")
		rich_name = RichTextUtil.ParseRichText(rich_name, value.special_ring.name, 18, item_color3b)
		rich_type = RichTextUtil.ParseRichText(rich_type, str_type, 18, normal_color)
		rich_name:refreshView()
		rich_type:refreshView()
		rich_name:setPosition(65, 58)
		rich_type:setPosition(65, 26)		
		layout:addChild(rich_name, 2)
		layout:addChild(rich_type, 2)

		self.cell_list[#self.cell_list + 1] = cell
		XUI.RichTextAddElement(rich_content, layout)
	end

	self:AddLineContent(rich_content, value.x, value.height)

	return rich_content
end

function TipSubAttr:AddLineContent(rich_content, x, height)
	self.line_tag = self.line_tag + 1
	rich_content.line_tag = self.line_tag
	rich_content.align_data = {x = x, height = height}
	table.insert(self.attrslist, rich_content)
	self.scroll_view:addChild(rich_content)
end

-- 筛选不显示属性
function TipSubAttr.ScreenNotShowAttr(attrs)
	local t = {}
	local is_s_attr_meiba = function (a_type)
		return a_type == GAME_ATTRIBUTE_TYPE.HOLY_WORDS or a_type == GAME_ATTRIBUTE_TYPE.HOLY_WORDPOWER
	end

	for i,v in ipairs(attrs) do
		if not is_s_attr_meiba(v.type) then
			t[i] = v
		end
	end
	return t
end

-- 基础属性
function TipSubAttr:Parse_ATTR_BASE()
	local total_attrs = {}

	local base_attr = {}
	if self.data.item_id >= 10000 and self.item_cfg.type == 1000 then
		base_attr = PrestigeData.Instance:GetAttrDataByItemId(self.data.item_id)
	else
		base_attr = ItemData.GetRealAttrs(self.item_cfg)
		base_attr = CommonDataManager.ScreenJobOtherAttr(base_attr, self.item_prof_limit) -- 筛选职业属性
	end
	-- local base_attr = ItemData.GetStaitcAttrs(self.item_cfg)
	
	total_attrs = CommonDataManager.AddAttr(total_attrs, base_attr)	--先加入配置中基础属性战力

 	-- 筛选不显示属性
	base_attr = TipSubAttr.ScreenNotShowAttr(base_attr)
	
	local base_attr_t = RoleData.FormatRoleAttrStr(base_attr, nil, self.item_prof_limit)

	--强化属性
	local qianghua_attrs = {}
	local qianghua_attr_str_t = {}
	local title_text = Language.Tip.BaseAttr
	if self.data.strengthen_level and self.data.strengthen_level > 0 then
		 qianghua_attrs = QianghuaData.GetStrengthenAttrCfg(EquipData.Instance:GetEquipSlotByType(self.data.type, self.data.hand_pos),
			self.data.strengthen_level, self.item_prof_limit) or {}
		 qianghua_attr_str_t = RoleData.FormatRoleAttrStr(qianghua_attrs, nil, self.item_prof_limit)
	elseif self.fromView == EquipTip.FROM_HOROSCOPE then -- 星魂强化，来自星魂槽
		 local config = ItemData.Instance:GetItemConfig(self.data.item_id)

        local strength_data =  HoroscopeData.Instance:GetSlotInfoDataList(config.stype) 
        if strength_data then
	        local strength_cfg = HoroscopeData.GetSlotAttrCfg(config.stype)
	        local max_level = HoroscopeData.Instance:GetCanJiHuoShuXingLevel(config.stype, self.data.item_id)
	        local level = strength_data.level
	        if strength_data.level > max_level then
	        	level = max_level
	        end

	        qianghua_attrs = strength_cfg[level] and strength_cfg[level].attrs or {}
	        qianghua_attr_str_t = RoleData.FormatRoleAttrStr(qianghua_attrs, nil, self.item_prof_limit)
	        title_text = Language.Tip.BaseAttr.. "  ".. string.format(Language.Tip.QianghuaTipShow, strength_data.level, level)
	     end
	end

	if ItemData.IsJinYanZhuUseItemType(self.data.type) then
		
		self.rich_cell2 = self:CreateTextRichCell({x = TipSubAttr.INDENT, height = TipSubAttr.LINE_HEIGHT + 4}) -- 空行
		self:FlushJinYanShow()
	else
		self:CreateTextRichCell({height = TipSubAttr.LINE_HEIGHT + 4, title_text = title_text,})
	end
	total_attrs = CommonDataManager.AddAttr(total_attrs, qianghua_attrs)

	for i = 1, #base_attr_t do
		local v = base_attr_t[i]
		if v == nil then break end
		local attr_name = v.type_str
		local attr_value = v.value_str
		local attr_color = nil
		if v.type < 32 then
			if v.type == GAME_ATTRIBUTE_TYPE.MAX_HP_POWER or  v.type == GAME_ATTRIBUTE_TYPE.PHYSICAL_ATTACK_MAX_POWER then
				attr_color = COLOR3B.RED
			else
				attr_color = COLOR3B.WHITE
			end
		else
			attr_color = COLOR3B.RED
		end
		local s_attr_value = ""
		for k1,v1 in pairs(qianghua_attr_str_t) do
			if v.type == v1.type then
				s_attr_value = v1.value_str
			end
		end
		local value = {
			x = TipSubAttr.INDENT, height = TipSubAttr.LINE_HEIGHT,
			label = {{key = attr_name .. ":" .. attr_value, color = attr_color}}
		}


		if s_attr_value ~= "" then
			table.insert(value.label, {key = "  " .. "强化(+".. s_attr_value..")", color = COLOR3B.GREEN})
		end
		-- 极品属性
		-- if nil ~= jp_attrs_map then
		-- 	local jp_attr = jp_attrs_map[v.type]
		-- 	if jp_attr and ((jp_attr.value + (jp_attr.value_r or 0)) > 0) then
		-- 		table.insert(value.label, {key = "	极品:" .. jp_attr.value_str, color = self.item_color3b})
		-- 	end
		-- end

		self:CreateTextRichCell(value)
	end
	return total_attrs
end

function TipSubAttr:Parse_ATTR_GANGWEN( ... )
	local attrs = {}
	if self.item_cfg.type >= ItemData.ItemType.itHandedDownDress and self.item_cfg.type <= ItemData.ItemType.itHandedDownWeapon then
		local chuan_data =  self.fromView == EquipTip.FROM_BROWSE_ROlE_CHUANG_SHI  and BrowseData.Instance:GetChuanShiEquipByIndex(self.handle_param_t.chuanshi_slot) or EquipData.Instance:GetChuanShiInfo(self.handle_param_t.chuanshi_slot)
		local level = chuan_data and chuan_data.level or 0
		local text = string.format("{wordcolor;%s;%s %d}", "00ff00", "+", level) .. " "
		if level > 0 then
			local level_cfg = EquipData.GetChuanShiLevelCfg(EquipData.ChuanShiCfgIndex(self.handle_param_t.chuanshi_slot), level)
			text = text .. string.format("{wordcolor;%s;(%s)}", level_cfg.color,level_cfg.tips)
			self:CreateTextRichCell({title_text = "钢纹属性:".."  "..text})

			local attr = EquipData.GetChuanShiLevelAttr(EquipData.ChuanShiCfgIndex(self.handle_param_t.chuanshi_slot), level, prof)
			attrs = attr
			local attr_t = RoleData.FormatRoleAttrStr(attr, nil, self.item_prof_limit)
			for i= 1,  #attr_t do
				local v = attr_t[i]
				if v ~= nil then
					local value = {
						x = TipSubAttr.INDENT, height = TipSubAttr.LINE_HEIGHT,
						label = {{key = v.type_str .. ":" .. v.value_str, color = COLOR3B.WHITE}}
					}
					self:CreateTextRichCell(value)
				end
			end
		end
	end
	return attrs
end

function TipSubAttr:Parse_ATTR_MEIBA( ... )
	local meiba_attr = {}
	if self.item_cfg.type == ItemData.ItemType.itGlove then

		local blood_lv = nil
		if self.fromView == EquipTip.FROM_ROLE_HAND then
			blood_lv = MeiBaShouTaoData.Instance:GetAddData().level
		elseif self.fromView == EquipTip.FROME_BROWSE_ROLE then

		end

		if blood_lv and blood_lv > 0 then	
			self:CreateTextRichCell({line = ""})
			self:CreateTextRichCell({height = TipSubAttr.LINE_HEIGHT + 4, title = "增幅属性 LV" .. blood_lv,})
			local attr = MeiBaShouTaoData.GetUpCfg()[blood_lv].attr
			meiba_attr = CommonDataManager.AddAttr(meiba_attr, attr)
			local attr_t = RoleData.FormatRoleAttrStr(attr, nil, self.item_prof_limit)
			for i= 1,  #attr_t do
				local v = attr_t[i]
				if v ~= nil then
					local value = {
						x = TipSubAttr.INDENT, height = TipSubAttr.LINE_HEIGHT,
						label = {{key = v.type_str .. ":" .. v.value_str, color = COLOR3B.BLUE}}
					}
					self:CreateTextRichCell(value)
				end
			end
		end

		self:CreateTextRichCell({line = ""})
		-- 属性说明
		-- self:CreateTextRichCell({height = TipSubAttr.LINE_HEIGHT + 4, title = "圣言术 LV" .. (self.item_cfg.orderType or 1),})
		-- 灭霸手套属性
		local base_attr = ItemData.GetRealAttrs(self.item_cfg)
		local rate = 0
		local num = 0
		local s_attr_t = {}
		for i,v in ipairs(base_attr) do
			if v.type == GAME_ATTRIBUTE_TYPE.HOLY_WORDPOWER  then
				num = v.value / 100
				table.insert(s_attr_t, v)
			end
			if v.type == GAME_ATTRIBUTE_TYPE.HOLY_WORDS  then
				rate = v.value / 100
				table.insert(s_attr_t, v)
			end
		end

		-- self:CreateTextRichCell({height = TipSubAttr.LINE_HEIGHT * 2, label = {{key = string.format("圣者之言，可诛灭天地：有%s%%的几率灭杀当前怪物%s%%的最大血量", rate, num), color = COLOR3B.RED}}})
		
	end
	return meiba_attr
end

function TipSubAttr:Parse_ATTR_FUSION()
	local fusion_lv = EquipmentFusionData.GetFusionLv(self.data)
	if fusion_lv > 0 then
		self:CreateTextRichCell({line = ""})
		self:CreateTextRichCell({title = "融合属性"})
		local text = EquipmentFusionData.GetFusionText(self.data)
		self:CreateTextRichCell({dec = {key = text, size = 18}, height = 110})

		local attrs = ItemData.GetStaitcAttrs(self.item_cfg)
		local equip_type = ItemData.GetIsBasisEquip(self.data.item_id) and 1 or 2
		local cfg = EquipMeltCfg or {}
		local meltcfg = cfg.meltcfg and cfg.meltcfg[equip_type] or {}
		local cur_meltcfg = meltcfg[fusion_lv] or {}
		local attrrate = cur_meltcfg.attrrate or 0
		return CommonDataManager.MulAtt(attrs, attrrate / 10000)
	end
end

function TipSubAttr:Parse_ATTR_SHENZHU()
	-- 神铸与神格,槽位字段相同,等级字段不同
	local shenzhu_level = self.data.shenzhu_level
	if shenzhu_level and shenzhu_level > 0 then
		local suffix = string.format("{color;36c4ff; +%d}", self.data.shenzhu_level)

		self:CreateTextRichCell({line = ""})
		self:CreateTextRichCell({title = "神铸属性" .. suffix})

		local shenzhu_slot = self.data.shenzhu_slot
		local attr_content, cur_attr, line = ReXueGodEquipData.GetShenzhuText(shenzhu_slot, shenzhu_level)
		self:CreateTextRichCell({dec = {key = attr_content, size = 18}, height = line * (TipSubAttr.LINE_HEIGHT - 3)})

		return cur_attr
	end
end

function TipSubAttr:Parse_ATTR_SHENGE()
	local shenge_level = self.data.shenge_level
	if shenge_level and shenge_level > 0 then
		local suffix = string.format("{color;36c4ff; %d阶}", self.data.shenge_level)

		self:CreateTextRichCell({line = ""})
		self:CreateTextRichCell({title = "神格属性" .. suffix})

		local shenzhu_slot = self.data.shenzhu_slot
		local attr_content, cur_attr, line = ReXueGodEquipData.GetShengeText(shenzhu_slot, shenge_level)
		self:CreateTextRichCell({dec = {key = attr_content, size = 18}, height = line * (TipSubAttr.LINE_HEIGHT - 3)})

		return cur_attr
	end
end

function TipSubAttr:Parse_ATTR_SUIT()
	if self.item_cfg.type >=ItemData.ItemType.itHandedDownDress  and self.item_cfg.type <= ItemData.ItemType.itHandedDownWeapon then
		-- local suitlevel = EquipData.Instance:GetChuanShiSuitLevel()
		-- local suittype = self.item_cfg.suitType
		-- --total_attrs = SuitPlusConfig[9].list[suitlevel] and SuitPlusConfig[9].list[suitlevel].attrs or {}
		-- local text = EquipData.Instance:GetChuanShiAllShowText(suitlevel, suittype)
		-- self:CreateTextRichCell({line = ""})
		-- self:CreateTextRichCell({title = "套装属性"})
		-- self:CreateTextRichCell({dec = {key = text, size = 18}, height = 200})
	elseif self.item_cfg.type == ItemData.ItemType.itConstellationItem then
		local suitlevel = HoroscopeData.Instance:GetSuitId()
		local suittype = self.item_cfg.suitType
		local config = SuitPlusConfig[8]

		local text = HoroscopeData.Instance:GetText(suittype, suitlevel, config, true)
		self:CreateTextRichCell({line = ""})
		self:CreateTextRichCell({title = "套装属性"})
		self:CreateTextRichCell({dec = {key = text, size = 18}, height = 130})
	elseif self.item_cfg.type >= ItemData.ItemType.itSubmachineGun and self.item_cfg.type <= ItemData.ItemType.itGentlemenBoots then
		local suittype = self.item_cfg.suitType
		local level_data = EquipData.Instance:GetCurDataByType(suittype)
		local suitlevel = level_data.suitlevel or 0 

		local  config = SuitPlusConfig[suittype]
		local index = HaoZhuangindexByType[self.item_cfg.type]
		local h = 120
		if index == 1 then
			h = 200
		elseif index == 2 then
			h= 150
		end
		local text = LuxuryEquipTipData.Instance:GetText(suittype, suitlevel, config, index, true, false)
		self:CreateTextRichCell({line = ""})
		self:CreateTextRichCell({title = "套装属性"})
		self:CreateTextRichCell({dec = {key = text, size = 18}, height = h})
	elseif self.item_cfg.type >=ItemData.ItemType.itWeapon  and self.item_cfg.type <= ItemData.ItemType.itShoes then
		if self.item_cfg.suitId > 0 then
			local suittype = self.item_cfg.suitType 
			local level_data = EquipData.Instance:GetCurNomalDataByType(suittype)
			local suitlevel = self.item_cfg.suitId
			local  config = SuitPlusConfig[suittype]
			if suittype == 1 then
				h = 160
			else
				h = 120
			end
			local text = EquipData.Instance:GetNormalText(suittype, suitlevel, config)
			self:CreateTextRichCell({line = ""})
			self:CreateTextRichCell({title = "套装属性"})
			self:CreateTextRichCell({dec = {key = text, size = 18}, height = h})
		end
	elseif self.item_cfg.type >= ItemData.ItemType.itWarmBloodDivinesword and self.item_cfg.type <= ItemData.ItemType.itWarmBloodGodNail then
		if  self.item_cfg.suitId > 0 then
			local suittype = self.item_cfg.suitType  --至尊套装
			local suitId = self.item_cfg.suitId
			local level_data = EquipData.Instance:GetZunZhiSuitData()
			local text = ReXueGodEquipData.Instance:GetTextByTypeData(suitId, suittype, level_data, true, false, true)
			self:CreateTextRichCell({line = ""})
			self:CreateTextRichCell({title = "套装属性"})
			self:CreateTextRichCell({dec = {key = text, size = 18}, height = 140})
		end
	elseif self.item_cfg.type >= ItemData.ItemType.itWarmBloodElbowPads and self.item_cfg.type <= ItemData.ItemType.itWarmBloodKneecap then
		if  self.item_cfg.suitId > 0 then
			local suittype = self.item_cfg.suitType --霸者套装
			local suitId = self.item_cfg.suitId
			local level_data = EquipData.Instance:GetBaZheSuitLevel()
			local text = ReXueGodEquipData.Instance:GetTextByTypeData(suitId, suittype, level_data, true, false, true)
			self:CreateTextRichCell({line = ""})
			self:CreateTextRichCell({title = "套装属性"})
			self:CreateTextRichCell({dec = {key = text, size = 18}, height = 150})
		end
	elseif ItemData.IsZhanShenEquip(self.data.item_id) then
		local suittype = self.item_cfg.suitType --战神套装
		local suitId = self.item_cfg.suitId
		local level_data = EquipData.Instance:GetZhanShenSuitLevel()
		local text = ReXueGodEquipData.Instance:GetTextByTypeData(suitId, suittype, level_data, true)
		self:CreateTextRichCell({line = ""})
		self:CreateTextRichCell({title = "套装属性"})
		self:CreateTextRichCell({dec = {key = text, size = 18}, height = 140})
	elseif ItemData.IsShaShenEquip(self.data.item_id) then --杀神套装
		local suittype = self.item_cfg.suitType
		local suitId = self.item_cfg.suitId
		local level_data = EquipData.Instance:GetSheShenSuitLevel()
		local text = ReXueGodEquipData.Instance:GetTextByTypeData(suitId, suittype, level_data, true)
		self:CreateTextRichCell({line = ""})
		self:CreateTextRichCell({title = "套装属性"})
		self:CreateTextRichCell({dec = {key = text, size = 18}, height = 180})
	elseif ItemData.IsWingEquip(self.data.item_id) then --翅膀套装
		local suittype = self.item_cfg.suitType
		local suitlevel = self.item_cfg.suitId
		local config = SuitPlusConfig[suittype] or 0
		local text = WingData.Instance:GetTextByTypeData(suittype, suitlevel, config, true)
		self:CreateTextRichCell({line = ""})
		self:CreateTextRichCell({title = "套装属性"})
		self:CreateTextRichCell({dec = {key = text, size = 18}, height = 105})
	elseif ItemData.GetIsHeroEquip(self.data.item_id) then
		local suittype = self.item_cfg.suitType
		local suitlevel = self.item_cfg.suitId
		local data = ZhanjiangCtrl.Instance:GetData(HERO_TYPE.ZC)
		local config = SuitPlusConfig[suittype] or 0
		local text = data:GetTextByTypeData(suittype, suitlevel, config, true)
		self:CreateTextRichCell({line = ""})
		self:CreateTextRichCell({title = "套装属性"})
		self:CreateTextRichCell({dec = {key = text, size = 18}, height = 105})
	end
end

-- 铸魂
function TipSubAttr:Parse_ATTR_SOUL()
	if not StoneData.IsStoneEquip(self.item_cfg.type) then
		return
	end

	if nil == self.data.slot_soul or self.data.slot_soul <= 0 then
		return
	end

	-- local limit_ms_lv = MoldingSoulData.GetLimitSoulLevel(self.limit_level, self.circle_level)
	-- if not limit_ms_lv then
	-- 	return
	-- end

	local soul_lv = self.data.slot_soul
	local slot = EquipData.Instance:GetEquipSlotByType(self.data.type, self.data.hand_pos)
	local attr_cfg = MoldingSoulData.GetMoldingSoulAttrCfg(slot + 1, soul_lv, self.item_prof_limit)
	local attr_str = attr_cfg and RoleData.FormatRoleAttrStr(attr_cfg, nil, self.item_prof_limit)
	if attr_str == nil then
		return
	end

	local add_num = soul_lv
	self:CreateTextRichCell({line = ""})
	self:CreateTextRichCell({title = "铸魂属性", label = {{key = " (+" .. add_num .. ")", color = COLOR3B.YELLOW}},})

	for i = 1, #attr_str do
		local v = attr_str[i]
		if v == nil then break end
		local value = {label = {[1] = {key = v.type_str .. "：" .. v.value_str}}}
		self:CreateTextRichCell(value)
	end

	return attr_cfg
end

--镶嵌宝石
function TipSubAttr:Parse_ATTR_BAOSHI()
	if not StoneData.IsStoneEquip(self.item_cfg.type) then
		return
	end
		
	local total_attrs = {}
	local have_stone = false
	local cell_val_t = {}
	for i = 1, 6 do
		local item_id = StoneData.GetStoneItemID(self.data["slot_" .. i])
		local label = {}
		if item_id then
			have_stone = true
			local stone_cfg = ItemData.Instance:GetItemConfig(item_id)
			total_attrs = CommonDataManager.AddAttr(total_attrs, stone_cfg.staitcAttrs)
			local stone_attr = RoleData.FormatRoleAttrStr(stone_cfg.staitcAttrs, nil, RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF))[1] or {}
			local attr_name = stone_attr.type_str or ""
			local attr_value = stone_attr.value_str or ""
			label = {[1] = {key = "  " .. stone_cfg.name .. "    ", color = COLOR3B.WHITE},
					[2] = {key = attr_name .. "：" .. attr_value, color = COLOR3B.WHITE}}
		else
			label = {[1] = {key = "  未镶嵌"}}
		end
		
		local img_path = ResPath.GetCommon(nil ~= item_id and "orn_102" or "orn_102_grey")
		table.insert(cell_val_t, {height = 23, label = label, img = {path = img_path, x = 10, y = 23 / 2 - 2}})
	end

	-- 没有一个宝石不显示
	if not have_stone then
		return
	end

	self:CreateTextRichCell({line = ""})
	self:CreateTextRichCell({title = Language.Tip.StoneInlay})
	for k, v in pairs(cell_val_t) do
		self:CreateTextRichCell(v)
	end

	return total_attrs
end

-- 精炼
function TipSubAttr:Parse_ATTR_APOTHEOSIS()
	if not StoneData.IsStoneEquip(self.item_cfg.type) then
		return
	end

	if nil == self.data.slot_apotheosis or self.data.slot_apotheosis <= 0 then
		return
	end

	local god_lv = self.data.slot_apotheosis
	local equip_slot = EquipData.Instance:GetEquipSlotByType(self.data.type, self.data.hand_pos)
	local attr_cfg = AffinageData.GetAffinageAttrCfg(equip_slot, god_lv, self.item_prof_limit)
	local attr_str = attr_cfg and RoleData.FormatRoleAttrStr(attr_cfg, nil, self.item_prof_limit)
	if attr_str == nil then
		return
	end

	self:CreateTextRichCell({line = ""})
	self:CreateTextRichCell({title = "精炼属性", label = {{key = " (+" .. self.data.slot_apotheosis .. ")", color = COLOR3B.BLUE}},})

	for i = 1, #attr_str do
		local v = attr_str[i]
		if v == nil then break end
		local value = {label = {[1] = {key = v.type_str .. "：" .. v.value_str}}}
		self:CreateTextRichCell(value)
	end

	return attr_cfg
end


function TipSubAttr:Parse_ATTR_RECYCLE()
	if self.item_cfg.type >=ItemData.ItemType.itWeapon  and self.item_cfg.type <= ItemData.ItemType.itShoes then
		-- local smelt_data = BaseEquipMeltingConfig.equipList[self.data.item_id]
		-- local text = Language.Tip.TipShow1
		-- if smelt_data then
		-- 	local count = smelt_data.award[1] and smelt_data.award[1].count or 0
		-- 	text = string.format(Language.Tip.TipShow2, count)
		-- end
		-- self:CreateTextRichCell({line = ""})
		-- self:CreateTextRichCell({title = "回收"})
		-- self:CreateTextRichCell({dec = {key = text}})
	end
end

--神器
function TipSubAttr:Parse_ATTR_SHENQI()
	if nil == self.data.shenqi_attr then
		return
	end

	self:CreateTextRichCell{line = ""}
	self:CreateTextRichCell{title = Language.Tip.SpecialAttr}
	for i,v in ipairs(self.data.shenqi_attr) do
		self:CreateTextRichCell{label = {{key = v},}}
	end
end

function TipSubAttr:UpdateCdTime()
	if self.rich_content then
		local time = (self.data.use_time or 0) - TimeCtrl.Instance:GetServerTime()
		if self.item_cfg.time == 0 then
			if self.cd_timer then
				GlobalTimerQuest:CancelQuest(self.cd_timer) -- 取消计时器任务
				self.cd_timer = nil
			end
			local text = string.format(Language.NewFashion.remain_desc, Language.NewFashion.remain_desc1)
			RichTextUtil.ParseRichText(self.rich_content, text, 20, COLOR3B.RED)
		elseif time <= 0  and  (self.item_cfg.time or 0) > 0  then
			if self.cd_timer then
				GlobalTimerQuest:CancelQuest(self.cd_timer) -- 取消计时器任务
				self.cd_timer = nil
			end
			local text = ""
			if (self.data.use_time or 0) <= (COMMON_CONSTS.SERVER_TIME_OFFSET + self.item_cfg.time) then --说明服务器未加上标记
				 text = string.format(Language.NewFashion.remain_desc, Language.NewFashion.Tips_show)
			else
				 text = string.format(Language.NewFashion.remain_desc, Language.NewFashion.remain_desc2)
			end
			
			RichTextUtil.ParseRichText(self.rich_content, text, 20, COLOR3B.RED)
		else
			local text =  string.format(Language.NewFashion.remain_desc, TimeUtil.FormatSecond(time, 3))
			RichTextUtil.ParseRichText(self.rich_content, text, 20, COLOR3B.RED)
		end 
	end
end

function TipSubAttr:Parse_ATTR_SPECIALRING()
	if nil == self.data.special_ring then
		return
	end
	local list = {}
	local cfg = SpecialRingHandleCfg or {}
	for i,v in ipairs(self.data.special_ring) do
		local _type = v.type
		local index = v.index
		if _type > 0 then
			local item_id_list = cfg.ItemIdIndxs and cfg.ItemIdIndxs[_type] and cfg.ItemIdIndxs[_type].ids or {}
			local item_id = item_id_list[index] or 1
			local item_cfg = ItemData.Instance:GetItemConfig(item_id)
			list[#list +1] = item_cfg
		end
	end
	if #list > 0 then
		self:CreateTextRichCell({line = ""})
		self:CreateTextRichCell({title = Language.Tip.FusionAttr})
	end
	for i,v in ipairs(list) do
		self:CreateTextRichCell({special_ring = v, height = 60})
		
		local attr = ItemData.GetStaitcAttrs(v)
		local fusion_attr = RoleData.FormatRoleAttrStr(attr, nil, self.item_prof_limit)
		for i = 1, #fusion_attr do
			local v = fusion_attr[i]
			if v == nil then break end
			local attr_name = v.type_str
			local attr_value = v.value_str
			local attr_color = nil
			if v.type < 32 then
				if v.type == GAME_ATTRIBUTE_TYPE.MAX_HP_POWER then
					attr_color = COLOR3B.RED
				else
					attr_color = COLOR3B.WHITE
				end
			else
				attr_color = COLOR3B.RED
			end
			local value = {
				x = TipSubAttr.INDENT, height = TipSubAttr.LINE_HEIGHT,
				label = {{key = attr_name .. ":" .. attr_value, color = attr_color}}
			}

			self:CreateTextRichCell(value)
		end
		if i ~= #list then
			self:CreateTextRichCell({line = ""})
		end
	end
end


function TipSubAttr:OnItemDurabilityChange()
	self:FlushJinYanShow()
end

function TipSubAttr:FlushJinYanShow()
	if self.rich_cell2 then
		local cur_exp = self.data.durability or 0
		local max_exp = self.data.durability_max or 0 
		local color = cur_exp >= max_exp and COLOR3B.GREEN or COLOR3B.RED

		local text = string.format(Language.Tip.TipShow3, cur_exp, max_exp)
		RichTextUtil.ParseRichText(self.rich_cell2, text, 20, COLOR3B.RED)
	end
end

return TipSubAttr
