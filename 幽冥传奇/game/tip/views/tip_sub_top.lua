TipSubTop = TipSubTop or BaseClass(TipSub)

TipSubTop.SIZE = cc.size(200, 132)

function TipSubTop:__init()
	self.y_order = 999
	self.is_ignore_height = false

	-- self.view:setBackGroundColor(COLOR3B.RED)
	self.view:setContentSize(TipSubTop.SIZE)
end

function TipSubTop:__delete()
end

function TipSubTop:YOrder()
	return self.y_order
end

function TipSubTop:SetData(data, fromView, param_t)
	self.data = data
	self.fromView = fromView or EquipTip.FROM_NORMAL
	self.handle_param_t = param_t or {}

	self.item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	self.item_color3b = Str2C3b(string.sub(string.format("%06x", self.item_cfg.color), 1, 6))

	self:Flush()
	self:BindEvents()
end

function TipSubTop:Release()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function TipSubTop:BindEvents()
	if nil ~= self.item_use_suc_handler then
		return
	end

	self.item_use_suc_handler = GlobalEventSystem:Bind(KnapsackEventType.KNAPSACK_ITEM_USE, BindTool.Bind(self.OnItemUseSuc, self))
end

function TipSubTop:CloseCallBack()
	if self.item_use_suc_handler then
		GlobalEventSystem:UnBind(self.item_use_suc_handler)
		self.item_use_suc_handler = nil
	end
end

function TipSubTop:CreateChild()
	TipSubTop.super.CreateChild(self)

	self.cell = BaseCell.New()
	self.cell:SetIsShowTips(false)
	self.cell:SetEventEnabled(false)
	self.cell:SetAnchorPoint(0, 1)
	self.cell:SetPosition(12, TipSubTop.SIZE.height - 40)
	self.view:addChild(self.cell:GetView(), 10)

	self.self_equip_stamp = XUI.CreateImageView(420, TipSubTop.SIZE.height - 30, ResPath.GetCommon("stamp_2"))
	self.self_equip_stamp:setVisible(false)
	self.view:addChild(self.self_equip_stamp, 99)

	self.rich_name = self:CreateRichText(20, TipSubTop.SIZE.height - 12, 0, 18, true)
	self.rich_1 = self:CreateRichText(100, TipSubTop.SIZE.height - 50, 0, 18, true)
	self.rich_2 = self:CreateRichText(250, TipSubTop.SIZE.height - 50, 0, 18, true)
	self.rich_3 = self:CreateRichText(100, TipSubTop.SIZE.height - 90, 0, 18, true)
	self.rich_4 = self:CreateRichText(250, TipSubTop.SIZE.height - 90, 0, 18, true)
end

function TipSubTop:CreateRichText(...)
	local rich = XUI.CreateRichText(...)
	rich:setAnchorPoint(0, 1)
	self.view:addChild(rich)
	return rich
end

function TipSubTop:OnFlush()
	local top_height = TipSubTop.SIZE.height
	

	self.self_equip_stamp:setVisible(self.fromView == EquipTip.FROM_BAG_EQUIP or self.fromView == EquipTip.FROM_EQUIP_GODFURANCE or self.fromView == EquipTip.FROM_EQUIP_COMPARE)

	local text = ""
	if self.data.strengthen_level and self.data.strengthen_level > 0 then
		text = string.format("{wordcolor;00ff00;%s}", "+" .. self.data.strengthen_level)
	elseif self.fromView == EquipTip.FROM_HOROSCOPE then -- 星魂强化，来自星魂槽
		local config = ItemData.Instance:GetItemConfig(self.data.item_id)
        local strength_data =  HoroscopeData.Instance:GetSlotInfoDataList(config.stype)
        local max_level = HoroscopeData.Instance:GetCanJiHuoShuXingLevel(config.stype, self.data.item_id)
        local level = (strength_data and strength_data.level or 0)
        if (strength_data and strength_data.level or 0) > max_level then
        	level = max_level
        end
        text = string.format("{wordcolor;00ff00;%s}", "+" .. level)
        self.data.xinghun_level = level
	end
	self.cell:SetData(self.data)
	RichTextUtil.ParseRichText(self.rich_name, self:GetItemName() .. " ".. text, 22, self.item_color3b)

	self.limit_level = 0  --默认是一级
	self.circle_level = 0
	self.item_prof_limit = 0
	local str_1, str_2, str_3, str_4
	if self.item_cfg.type == ItemData.ItemType.itSpecialRing then
		str_1, str_2, str_3, str_4 = self:GetSpecialRingStr()
	elseif self.data.type == ItemData.ItemType.itGlove then
		str_1, str_2, str_3, str_4 = self:GetMeiBaStr()
	else
		if self.item_cfg.type >= ItemData.ItemType.itHandedDownDress and self.item_cfg.type <= ItemData.ItemType.itHandedDownWeapon then
			str_1 = string.format("类型：{color;%s;%s}", "e5e3cb", "传世")
		else
			str_1 = string.format("类型：{color;%s;%s}", "e5e3cb", Language.EquipTypeName[self.item_cfg.type] or "")
		end

		local level_str = ""
		local level_color = "e5e3cb"
		local prof_str = Language.Common.ProfName[0]
		local prof_color = "e5e3cb"
		local sex_str = Language.Common.No
		local sex_color = "e5e3cb"
		for k,v in pairs(self.item_cfg.conds or{}) do
			if v.cond == ItemData.UseCondition.ucLevel then
				self.limit_level = v.value
				if not RoleData.Instance:IsEnoughLevelZhuan(v.value) then
					level_color = COLORSTR.RED
				end
			end
			if v.cond == ItemData.UseCondition.ucMinCircle then
				self.circle_level = v.value
				if v.value > RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE) then
					level_color = COLORSTR.RED
				end
			end
			if v.cond == ItemData.UseCondition.ucGender then
				sex_str = Language.Common.SexName[v.value]
				if v.value ~= RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX) then
					sex_color = COLORSTR.RED
				end
			end
			if v.cond == ItemData.UseCondition.ucJob then
				-- self.item_prof_limit = v.value
				-- prof_str = Language.Common.ProfName[v.value]
				-- if v.value ~= 0 and v.value ~= RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF) then
				-- 	prof_color = COLORSTR.RED
				-- end
			end
		end

		level_str = (self.circle_level > 0 and self.circle_level .. "转" or "") 
		if self.limit_level > 0 then
			
			level_str = level_str.. self.limit_level .. "级"
		
		end
		if self.item_cfg.type >= ItemData.ItemType.itHandedDownDress and self.item_cfg.type <= ItemData.ItemType.itHandedDownWeapon then
			str_3 = string.format("部位：{color;%s;%s}", prof_color, Language.EquipTypeName[self.item_cfg.type])
			str_2 = string.format("等级：{color;%s;%s}", level_color, level_str)
		else
			if ItemData.GetIsFashion(self.data.item_id) or ItemData.GetIsHuanWu(self.data.item_id) then
				str_2 = string.format("等级：{color;%s;%s}", level_color, level_str)
			else
				str_2 = string.format("阶数：{color;%s;%s}", prof_color, (self.item_cfg.orderType or 0).."阶")
			end
			str_3 = string.format("性别：{color;%s;%s}", sex_color, sex_str)
		end

		

		if (ItemData.GetIsFashion(self.data.item_id) or ItemData.GetIsHuanWu(self.data.item_id)) then
			local desc = self.item_cfg.time == 0 and Language.NewFashion.remain_desc1 or math.floor(self.item_cfg.time/86400).."天"
			str_4 = string.format("限时：{color;%s;%s}", "dcb73d", desc)
		else
			if self.item_cfg.type >= ItemData.ItemType.itHandedDownDress and self.item_cfg.type <= ItemData.ItemType.itHandedDownWeapon then
				str_4 = string.format("性别：{color;%s;%s}", sex_color, sex_str)
			else
				if ItemData.IsReXueEquip(self.data.item_id) or ItemData.IsZhanShenEquip(self.data.item_id) or ItemData.IsShaShenEquip(self.data.item_id)  then
					if self.limit_level == 0 then
						str_4 = string.format("等级：{color;%s;%s}", COLORSTR.GREEN, "无限制")
					else
						str_4 = string.format("等级：{color;%s;%s}", level_color, level_str)
					end
				else
					str_4 = string.format("等级：{color;%s;%s}", level_color, level_str)
				end
			end

		end
	end

	-- 神炉阶数
	local god_slot = GodFurnaceData.ItemType2Slot[self.item_cfg.type]
	if god_slot then
		local god_lv = GodFurnaceData.Instance:GetSlotData(god_slot).level
		str_2 = string.format("阶数：{color;e5e3cb;%s}", GodFurnaceData.Instance:GetGradeNum(god_lv).."阶") 
	end

	local normal_color = Str2C3b("dcb73d")
	RichTextUtil.ParseRichText(self.rich_1, str_1, 20, normal_color)
	RichTextUtil.ParseRichText(self.rich_2, str_2, 20, normal_color)
	RichTextUtil.ParseRichText(self.rich_3, str_3, 20, normal_color)
	RichTextUtil.ParseRichText(self.rich_4, str_4, 20, normal_color)

	self.content_height = top_height
end

-- 特戒标题
function TipSubTop:GetSpecialRingStr()
	local color = "e5e3cb"
	local fusion_num = 0
	for i,v in ipairs(self.data.special_ring or {}) do
		if v.type ~= 0 then
			fusion_num = fusion_num + 1
		end
	end
	local cfg = SpecialRingHandleCfg or {}
	local type_name = cfg.type_name and cfg.type_name[self.item_cfg.useType or 0] or ""
	local fusion_num_name = cfg.fusion_num_name and cfg.fusion_num_name[fusion_num] or "无"

	local level_color = color
	for k,v in pairs(self.item_cfg.conds or{}) do
		if v.cond == ItemData.UseCondition.ucLevel then
			self.limit_level = v.value
			if not RoleData.Instance:IsEnoughLevelZhuan(v.value) then
				level_color = COLORSTR.RED
			end
		end
		if v.cond == ItemData.UseCondition.ucMinCircle then
			self.circle_level = v.value
			if v.value > RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE) then
				level_color = COLORSTR.RED
			end
		end
	end
	local level_str = (self.circle_level > 0 and self.circle_level .. "转" or "") .. self.limit_level .. "级"

	str_1 = string.format("部位：{color;%s;%s}", color, Language.EquipTypeName[self.item_cfg.type] or "")
	str_2 = string.format("类型：{color;%s;%s}", color, type_name)
	str_3 = string.format("融合：{color;%s;%s}", color, fusion_num_name)
	str_4 = string.format("等级：{color;%s;%s}", level_color, level_str)

	return str_1, str_2, str_3, str_4
end

-- 特戒标题
function TipSubTop:GetMeiBaStr()
	local color = "e5e3cb"
	local fusion_num = 0
	for i,v in ipairs(self.data.special_ring or {}) do
		if v.type ~= 0 then
			fusion_num = fusion_num + 1
		end
	end

	local level_color = color
	for k,v in pairs(self.item_cfg.conds or{}) do
		if v.cond == ItemData.UseCondition.ucLevel then
			self.limit_level = v.value
			if not RoleData.Instance:IsEnoughLevelZhuan(v.value) then
				level_color = COLORSTR.RED
			end
		end
		if v.cond == ItemData.UseCondition.ucMinCircle then
			self.circle_level = v.value
			if v.value > RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE) then
				level_color = COLORSTR.RED
			end
		end
	end
	str_1 = string.format("等级：{color;%s;%s}", level_color, self.limit_level .. "级")
	str_2 = string.format("转生：{color;%s;%s}", color, self.circle_level .. "转")
	str_3 = string.format("类型：{color;%s;%s}", color, Language.EquipTypeName[self.item_cfg.type] or "")
	str_4 = string.format("品质：{color;%s;%s}", color, Language.MeiBaPingZhiName[self.item_cfg.item_id] or "")

	return str_1, str_2, str_3, str_4
end

function TipSubTop:OnItemUseSuc(param)
	if param.item_id == self.data.item_id then
		if param.result ~= 0 then
			self:Flush()
		end
	end
end

function TipSubTop:GetItemName()
	local name = self.item_cfg.name
	if self.item_cfg.type >= ItemData.ItemType.itHandedDownDress and self.item_cfg.type <= ItemData.ItemType.itHandedDownWeapon then
		local chuan_data = self.fromView == EquipTip.FROM_BROWSE_ROlE_CHUANG_SHI  and BrowseData.Instance:GetChuanShiEquipByIndex(self.handle_param_t.chuanshi_slot) or EquipData.Instance:GetChuanShiInfo(self.handle_param_t.chuanshi_slot)
		local level = chuan_data and chuan_data.level or 0
		if level > 0 then
			local level_cfg = EquipData.GetChuanShiLevelCfg(EquipData.ChuanShiCfgIndex(self.handle_param_t.chuanshi_slot), level)
			name = name .."·" ..string.format("{wordcolor;%s;%s}", level_cfg.color,level_cfg.tips)
		end
	end
	-- 屏蔽鉴定
	-- if ItemData.IsBaseEquipType(self.item_cfg.type) then
	-- 	local text = ""
	-- 	local jianding_qaulity = self.data and self.data.authenticate and self.data.authenticate.quality or 0
	-- 	text = Language.Tip.JibngDianName[jianding_qaulity] or ""
	-- 	name = text .. ""..name
	-- end
	-- 特戒增加融合前缀
	if self.item_cfg.type == ItemData.ItemType.itSpecialRing then
		if self.data.special_ring then
			local fusion_num = 0
			for i,v in ipairs(self.data.special_ring) do
				if v.type ~= 0 then
					fusion_num = fusion_num + 1
				end
			end
			local cfg = SpecialRingHandleCfg or {}
			local fusion_num_name = cfg.fusion_num_name and cfg.fusion_num_name[fusion_num]
			fusion_num_name = fusion_num_name and string.format("【%s】", fusion_num_name) or ""
			name = fusion_num_name .. name
		end
	end
	
	-- "神格"后缀
	local shenge_level = self.data.shenge_level
	if shenge_level and shenge_level > 0 then
		name = name .. Language.Tip.ShenzhuName[shenge_level]
	end

	return name
end

return TipSubTop
