TipSubDesc = TipSubDesc or BaseClass(TipSub)

TipSubDesc.SIZE = cc.size(0, 94)

function TipSubDesc:__init()
	self.view:setContentSize(TipSubDesc.SIZE)
	self.content_height = TipSubDesc.SIZE.height
	self.is_ignore_height = false
	self.y_order = 0
end

function TipSubDesc:__delete()
end

function TipSubDesc:SetData(data, fromView, param_t)
	self.data = data
	self.fromView = fromView or EquipTip.FROM_NORMAL
	self.handle_param_t = param_t or {}

	self.item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	self.item_color3b = Str2C3b(string.sub(string.format("%06x", self.item_cfg.color), 1, 6))

	self:Flush()

	if IS_NOT_SHOW_DESC[self.item_cfg.type] then
		self.is_ignore_height = true
		self.view:setVisible(false)
		return
	end
	self.is_ignore_height = false
	self.view:setVisible(true)
end

function TipSubDesc:Release()
	self.scroll_view = nil
	-- self.bg = nil
	self.rich_desc = nil
end

function TipSubDesc:CreateChild()
	TipSubDesc.super.CreateChild(self)
	local margine = 8
	self.scroll_view = XUI.CreateScrollView(0, TipSubDesc.SIZE.height-margine, BaseTip.WIDTH, TipSubDesc.SIZE.height-3*margine, ScrollDir.Vertical)
	self.scroll_view:setAnchorPoint(0, 1)
	self.scroll_view:setBounceEnabled(true)
	self.view:addChild(self.scroll_view, 2)
	self.bg = XUI.CreateImageView(BaseTip.WIDTH / 2, TipSubDesc.SIZE.height, ResPath.GetCommon("line_05"), true)
	self.bg:setAnchorPoint(0.5, 1)
	self.view:addChild(self.bg)

	self.rich_desc = self:CreateRichText(30, 0, 428, 0)
end

function TipSubDesc:CreateRichText(...)
	local rich = XUI.CreateRichText(...)
	XUI.SetRichTextVerticalSpace(rich,6)
	rich:setAnchorPoint(0, 1)
	self.scroll_view:addChild(rich)
	return rich
end

function TipSubDesc:OnFlush()
	RichTextUtil.ParseRichText(self.rich_desc, self.item_cfg.desc, 19, self.item_color3b)
	self.rich_desc:refreshView()
	local content_size = self.rich_desc:getInnerContainerSize()
	local scroll_size = self.scroll_view:getContentSize()
	local inner_h = math.max(content_size.height, scroll_size.height)
	self.scroll_view:setInnerContainerSize(cc.size(scroll_size.width, inner_h))
	self.rich_desc:setPositionY(inner_h)
	self.scroll_view:jumpToTop()
end

return TipSubDesc
