--重写战纹tip使用的render
local TipCurrAttr = BaseClass(TipSubAttr) 
local TipNextAttr = BaseClass(TipSubAttr) 
local TipDesc = BaseClass(TipSubItemDesc) 
local TipTop = BaseClass(TipSubTop) 

-- 当前属性
function TipCurrAttr:OnFlush()
	-- 先清空所有单元
	self.scroll_view:removeAllChildren()
	self.line_tag = 0
	self.attrslist = {}

	self:CreateTextRichCell({x = TipSubAttr.INDENT, height = 8}) -- 空行
	self:CreateAttrShow()
	self:CreateTextRichCell({x = TipSubAttr.INDENT, height = 8}) -- 空行

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
	self.scroll_view:setContentWH(TipSubAttr.SIZE.width, base_y > TipSubAttr.SIZE.height and TipSubAttr.SIZE.height or base_y)
	self.scroll_view:setInnerContainerSize(cc.size(TipSubAttr.SIZE.width, base_y))
	self.scroll_view:jumpToTop()
	local scroll_v_height = self.scroll_view:getContentSize().height

	-- 战斗力
	local fight_power_view_h = 58
	local total_score = CommonDataManager.GetAttrSetScore(BattleFuwenData.GetShowAttr(self.data), self.item_prof_limit)
	self.fight_power_view:GetView():setPositionY(scroll_v_height + fight_power_view_h / 2 + 10)
	self.fight_power_view:SetNumber(total_score)
	-- self.line:setPositionY(scroll_v_height + 0)

	-- 内容总高度
	self.content_height = scroll_v_height + fight_power_view_h + 10
end

function TipCurrAttr:CreateAttrShow()
	local base_attr = BattleFuwenData.GetShowAttr(self.data) or {}
	local base_attr_t = RoleData.FormatRoleAttrStr(base_attr, nil, self.item_prof_limit)

	self:CreateTextRichCell({height = TipSubAttr.LINE_HEIGHT + 4, title = Language.Tip.CurrAttr,})

	for i = 1, #base_attr_t do
		local v = base_attr_t[i]
		if v == nil then break end
		local attr_name = v.type_str
		local attr_value = v.value_str
		local attr_color = nil
		if v.type < 32 then
			if v.type == GAME_ATTRIBUTE_TYPE.MAX_HP_POWER then
				attr_color = COLOR3B.RED
			else
				attr_color = COLOR3B.GRAY3
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
end

-- 下级属性
function TipNextAttr:OnFlush()
	-- 先清空所有单元
	self.scroll_view:removeAllChildren()

	if nil == BattleFuwenData.GetNextShowAttr(self.data) then self.view:setVisible(false) return end --满级不显示下级属性
	self.fight_power_view:GetView():setVisible(false)	--不显示下级战力

	self.line_tag = 0
	self.attrslist = {}

	self:CreateTextRichCell({x = TipSubAttr.INDENT, height = 8}) -- 空行
	self:CreateAttrShow()
	self:CreateTextRichCell({x = TipSubAttr.INDENT, height = 8}) -- 空行

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
	self.scroll_view:setContentWH(TipSubAttr.SIZE.width, base_y > TipSubAttr.SIZE.height and TipSubAttr.SIZE.height or base_y)
	self.scroll_view:setInnerContainerSize(cc.size(TipSubAttr.SIZE.width, base_y))
	self.scroll_view:jumpToTop()
	local scroll_v_height = self.scroll_view:getContentSize().height


	-- 内容总高度
	self.content_height = scroll_v_height + 10
end

function TipNextAttr:CreateAttrShow()
	local base_attr = BattleFuwenData.GetNextShowAttr(self.data)
	local base_attr_t = RoleData.FormatRoleAttrStr(base_attr, nil, self.item_prof_limit)

	self:CreateTextRichCell({height = TipSubAttr.LINE_HEIGHT + 4, title = Language.Tip.NextAttr,})

	for i = 1, #base_attr_t do
		local v = base_attr_t[i]
		if v == nil then break end
		local attr_name = v.type_str
		local attr_value = v.value_str
		local attr_color = nil
		if v.type < 32 then
			if v.type == GAME_ATTRIBUTE_TYPE.MAX_HP_POWER then
				attr_color = COLOR3B.RED
			else
				attr_color = COLOR3B.GRAY3
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
end

--物品描述
function TipDesc:OnFlush()
	self.total_h = 0
	self.total_h = self.total_h + TipSubItemDesc.MARGIN

	local desc = string.format(Language.BattleLine.ItemTipDesc, BattleFuwenData.GetUpNeed(self.data), BattleFuwenData.GetDecomposeObtian(self.data))
	RichTextUtil.ParseRichText(self.rich_desc, desc, 20, self.item_color3b)
	self.rich_desc:refreshView()
	self.content_height = self.rich_desc:getInnerContainerSize().height
	self.total_h = self.total_h + self.content_height
	self.rich_desc:setPositionY(self.total_h)

	self.total_h = self.total_h + 8

	self.total_h = self.total_h + 26
	self.title_rich:setPosition(24, self.total_h)

	self.total_h = self.total_h + TipSubItemDesc.MARGIN

	self.line:setPositionY(self.total_h)
	self.total_h = self.total_h + 10
end

--顶部提示
function TipTop:OnFlush()
	local top_height = TipSubTop.SIZE.height
	self.cell:SetData(self.data)

	self.self_equip_stamp:setVisible(self.fromView == EquipTip.FROM_BAG_EQUIP or self.fromView == EquipTip.FROM_EQUIP_GODFURANCE or self.fromView == EquipTip.FROM_EQUIP_COMPARE)

	RichTextUtil.ParseRichText(self.rich_name, self:GetItemName() .. "LV." .. (self.data.durability or 1), 22, self.item_color3b)

	local normal_color = COLOR3B.YELLOW
	local type_str = string.format("类型：{color;%s;%s}", COLORSTR.YELLOW, Language.EquipTypeName[self.item_cfg.type] or "")
	RichTextUtil.ParseRichText(self.rich_1, type_str, 20, normal_color)


	local quality = {
		[1] = "绿",
		[2] = "蓝",
		[3] = "紫",
		[4] = "橙",
		[5] = "红",
	}
	local prof_str = string.format("品质：{color;%s;%s}", COLORSTR.YELLOW, quality[self.item_cfg.quality + 1])
	RichTextUtil.ParseRichText(self.rich_3, prof_str, 20, normal_color)

	self.content_height = top_height
end

return {TipCurrAttr = TipCurrAttr , TipNextAttr = TipNextAttr , TipDesc = TipDesc, TipTop = TipTop }