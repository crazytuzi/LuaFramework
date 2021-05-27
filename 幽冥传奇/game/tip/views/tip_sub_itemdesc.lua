TipSubItemDesc = TipSubItemDesc or BaseClass(TipSub)

TipSubItemDesc.SIZE = cc.size(0, 0)
TipSubItemDesc.MARGIN = 25
TipSubItemDesc.MIN_H = 80

function TipSubItemDesc:__init()
	self.view = XUI.CreateLayout(0, 0, TipSubItemDesc.SIZE.width, TipSubItemDesc.SIZE.height)
	self.view:setAnchorPoint(0, 0)
	self.y_order = 0

	self.content_height = 0
	self.total_h = 0

	self.is_created = false
end

function TipSubItemDesc:__delete()
	self.view = nil
	self.is_created = false

	self:Release()
end

function TipSubItemDesc:GetView()
	return self.view
end

function TipSubItemDesc:IsIgnoreHeight()
	return false
end

function TipSubItemDesc:ContentHeight()
	return self.total_h
end

function TipSubItemDesc:YOrder()
	return self.y_order
end

function TipSubItemDesc:SetData(data, fromView, param_t)
	self.data = data
	self.fromView = fromView or EquipTip.FROM_NORMAL
	self.handle_param_t = param_t or {}

	self.item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	self.item_color3b = Str2C3b(string.sub(string.format("%06x", self.item_cfg.color), 1, 6))
	self.content_height = 0

	if not self.is_created then
		self:CreateChild()
	end

	self:OnFlush()
end

function TipSubItemDesc:Release()
	self.line = nil
	self.title_rich = nil
	self.rich_desc = nil
end

function TipSubItemDesc:CreateChild()
	self.is_created = true

	self.title_rich = XUI.CreateRichText(30, 0, 200, 0)
	self.title_rich:setAnchorPoint(0, 0)
	local content_size = cc.size(22, 22)
	local img_path = XUI.CreateImageView(8, content_size.height / 2, ResPath.GetCommon("orn_100"), true)
	local empty_node = cc.Node:create()
	empty_node:setContentSize(content_size)
	empty_node:addChild(img_path)
	XUI.RichTextAddElement(self.title_rich, empty_node)
	XUI.RichTextAddText(self.title_rich, Language.Tip.ItemContent, COMMON_CONSTS.FONT, 22, COLOR3B.ORANGE2)
	self.view:addChild(self.title_rich)

	self.rich_desc = self:CreateRichText(30, 0, BaseTip.WIDTH - 20, 0)
	XUI.SetRichTextVerticalSpace(self.rich_desc,9)
	-- self.rich_desc:setVerticalSpace(9)

	self.line = XUI.CreateImageView(BaseTip.WIDTH / 2, 0, ResPath.GetCommon("line_05"), true)
	self.view:addChild(self.line)
end

function TipSubItemDesc:CreateRichText(...)
	local rich = XUI.CreateRichText(...)
	rich:setAnchorPoint(0, 1)
	self.view:addChild(rich)
	return rich
end

function TipSubItemDesc:OnFlush()
	self.total_h = 0
	self.total_h = self.total_h + TipSubItemDesc.MARGIN

	if self.item_cfg.type == 1002 then --特殊技能显示
		local config = ClientQieGeSkillCfg[self.data.virtual_type][self.data.virtual_level]
		local text = ""
		if config.value2 ~= nil then
			text = string.format(self.item_cfg.desc,config.value1, config.value2)
		else
			text = string.format(self.item_cfg.desc,config.value1)
		end
		RichTextUtil.ParseRichText(self.rich_desc, text, 20, self.item_color3b)
	else
		RichTextUtil.ParseRichText(self.rich_desc, self.item_cfg.desc, 20, self.item_color3b)
	end
	self.rich_desc:refreshView()

	self.content_height = math.max(TipSubItemDesc.MIN_H, self.rich_desc:getInnerContainerSize().height)
	self.total_h = self.total_h + self.content_height
	self.rich_desc:setPositionY(self.total_h)

	self.total_h = self.total_h + 8

	self.total_h = self.total_h + 26
	self.title_rich:setPosition(24, self.total_h)

	self.total_h = self.total_h + TipSubItemDesc.MARGIN

	self.line:setPositionY(self.total_h)
	self.total_h = self.total_h + 10
end

return TipSubItemDesc
