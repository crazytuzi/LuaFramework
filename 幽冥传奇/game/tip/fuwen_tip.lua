FuwenTip = FuwenTip or BaseClass(EquipTip)
local SCROLLVIEWWIDTH = 500
local SCROLLVIEWHEIGHT = 400

local RICHCELLHEIGHT = 20

--基础 
local ITEM_CONTENT = 1
local ATTR_BASE = 2
--解析装备tips
function FuwenTip:ParseEquip(item_cfg)
	self:ResetUi()
	self.attrslist = {}
	if self.data == nil or item_cfg == nil then
		return
	end

	self.scroll_view = XUI.CreateLayout(SCROLLVIEWWIDTH/2 - 16, SCROLLVIEWHEIGHT/2 + 55,
		SCROLLVIEWWIDTH, SCROLLVIEWHEIGHT)
	self.node_t_list.layout_itemtip.node:addChild(self.scroll_view, 10, 10)

	local attribute = {} 
	attribute[ITEM_CONTENT] = true
	attribute[ATTR_BASE] = true

	local loop = 0
	local height_offset = 0
	local rich = nil
	local value = {}
	local rich_x = 35
	for i = 1, #attribute, 1 do
		if ITEM_CONTENT == i then
			loop = loop + 1
			value = {dec = {key = item_cfg.desc}}
			rich = self:CreateTextRichCell(loop, value)
			rich:setPosition(GetCenterPoint(rich).x + 40, RICHCELLHEIGHT * loop)
			self.scroll_view:addChild(rich)

			loop = loop + 1
			value = {title = Language.Tip.ItemContent}
			rich = self:CreateTextRichCell(loop, value)
			rich:setPosition(GetCenterPoint(rich).x + rich_x, RICHCELLHEIGHT * loop)
			self.scroll_view:addChild(rich)

			-- if #self.data.rand_base_attr > 0 then
			-- 	loop = loop + 1
			-- 	rich = self:CreateTextRichCell(loop, {label = {[1] = {key = ""}}})
			-- 	rich:setPosition(GetCenterPoint(rich).x + 15, RICHCELLHEIGHT * loop)
			-- 	self.scroll_view:addChild(rich)
			-- end
		elseif ATTR_BASE == i then
			--基础属性
			local base_attr_t = item_cfg.staitcAttrs	
			-- local base_attrs = 
			-- base_attrs = FuwenData.Instance:GetFuwenAttrCfg(item_cfg.item_id)
			-- base_attr_t = CommonDataManager.AddAttr(base_attr_t, base_attrs)
			base_attr_t = RoleData.FormatRoleAttrStr(base_attr_t)
			for i = #base_attr_t, 1, -1 do
				local v = base_attr_t[i]
				if v == nil then break end
				loop = loop + 1
				local attr_name = ""
				local attr_value = ""
				local s_attr_name = ""
				local s_attr_value = ""
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
				value = {label = {[1] = {key = attr_name .. "：" .. attr_value, color = attr_color}}}
				if s_attr_name ~= "" then
					table.insert(value.label, {key = "     " .. s_attr_name .. "：" .. s_attr_value, color = COLOR3B.YELLOW})
				end
				rich = self:CreateTextRichCell(loop, value)
				rich:setPosition(GetCenterPoint(rich).x + 40, RICHCELLHEIGHT * loop)
				self.scroll_view:addChild(rich)
			end

			loop = loop + 1
			value = {title = Language.Tip.BaseAttr}
			rich = self:CreateTextRichCell(loop, value)
			rich:setPosition(GetCenterPoint(rich).x + rich_x, RICHCELLHEIGHT * loop)
			self.scroll_view:addChild(rich)
		end
	end
	local hig = 0
	table.sort(self.attrslist, function(a, b) return a.tag < b.tag end )
	for k,v in pairs(self.attrslist) do
		v:refreshView()
		local inner_h = math.max(v:getInnerContainerSize().height, RICHCELLHEIGHT)
		hig = hig + inner_h + 5
		v:setPosition(v:getPositionX(), hig)
	end
	self.scroll_view:setContentWH(SCROLLVIEWWIDTH, hig + 20)
	self.scroll_view:setPosition(SCROLLVIEWWIDTH/2 - 16, hig / 2 + 20)
	local item_tips_h = 170 + hig
	self.itemtips_bg:setContentWH(455, item_tips_h)
	local out_height = math.min(HandleRenderUnit:GetHeight() - item_tips_h, 0)
	self.itemtips_bg:setPositionY((item_tips_h + out_height) / 2 )
	self.layout_content_top:setPositionY(item_tips_h - 130 + out_height / 2)
	self.layout_btns:setPositionY(30 + out_height / 2)
	self.node_t_list.btn_close_window.node:setPositionY(item_tips_h - 25 + out_height / 2)
	self.root_node:setContentWH(self.root_node:getContentSize().width, item_tips_h + out_height)
end