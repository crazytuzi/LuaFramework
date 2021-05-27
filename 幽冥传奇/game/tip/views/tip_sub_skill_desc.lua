TipSubSkillDesc = TipSubSkillDesc or BaseClass(TipSub)

TipSubSkillDesc.SIZE = cc.size(0, 110)

function TipSubSkillDesc:__init()
	self.view:setContentSize(TipSubSkillDesc.SIZE)
	self.content_height = TipSubSkillDesc.SIZE.height
	self.is_ignore_height = false
	self.y_order = 0
	self.icon_id = 0
	self.desc = ""
end

function TipSubSkillDesc:__delete()
end

function TipSubSkillDesc:SetData(data, fromView, param_t)
	self.data = data
	self.fromView = fromView or EquipTip.FROM_NORMAL
	self.handle_param_t = param_t or {}

	if nil == VirtualSkillCfg[self.data.item_id] then
		self.is_ignore_height = true
		self.view:setVisible(false)
		return
	end
	self.is_ignore_height = false
	self.view:setVisible(true)
	self.icon_id = VirtualSkillCfg[self.data.item_id].icon 
	-- {colorandsize;ff00ff;28;柔弱女子} model
	self.desc = string.format("{colorandsize;45a7e5;22;%s}", VirtualSkillCfg[self.data.item_id].name).. "\n" .. VirtualSkillCfg[self.data.item_id].desc

	self:Flush()
end

function TipSubSkillDesc:Release()
	self.scroll_view = nil
	self.bg = nil
	self.rich_desc = nil
	self.icon = nil

	self.desc = ""
	self.icon_id = 0
end

function TipSubSkillDesc:CreateChild()
	TipSubSkillDesc.super.CreateChild(self)
	local margine = 8
	self.scroll_view = XUI.CreateScrollView(0, TipSubSkillDesc.SIZE.height-margine, BaseTip.WIDTH, TipSubSkillDesc.SIZE.height-3*margine, ScrollDir.Vertical)
	self.scroll_view:setAnchorPoint(0, 1)
	self.scroll_view:setBounceEnabled(true)
	self.view:addChild(self.scroll_view, 2)
	self.bg = XUI.CreateImageView(BaseTip.WIDTH / 2, TipSubSkillDesc.SIZE.height, ResPath.GetCommon("line_05"), true)
	self.bg:setAnchorPoint(0.5, 1)	

	self.icon = XUI.CreateImageView(65, TipSubSkillDesc.SIZE.height - 13, ResPath.GetItem(self.icon_id), true)
	self.icon:setAnchorPoint(0.5, 1)	
	-- self.icon:setScale(0.9)

	self.view:addChild(self.icon, 2)
	self.view:addChild(self.bg)

	local cell_bg = XUI.CreateImageView(64, TipSubSkillDesc.SIZE.height - 10, ResPath.GetCommon("cell_100"), true)
	cell_bg:setAnchorPoint(0.5, 1)
	self.view:addChild(cell_bg, 1)

	self.rich_desc = self:CreateRichText(114, 0, 350, 0)
end

function TipSubSkillDesc:CreateRichText(...)
	local rich = XUI.CreateRichText(...)
	XUI.SetRichTextVerticalSpace(rich,6)
	rich:setAnchorPoint(0, 1)
	self.scroll_view:addChild(rich)
	return rich
end

function TipSubSkillDesc:OnFlush()
	RichTextUtil.ParseRichText(self.rich_desc, self.desc, 19, self.item_color3b)
	self.rich_desc:refreshView()
	local content_size = self.rich_desc:getInnerContainerSize()
	local scroll_size = self.scroll_view:getContentSize()
	local inner_h = math.max(content_size.height, scroll_size.height)
	self.scroll_view:setInnerContainerSize(cc.size(scroll_size.width, inner_h))
	self.rich_desc:setPositionY(inner_h)
	self.scroll_view:jumpToTop()

	self.icon:loadTexture(ResPath.GetItem(self.icon_id))
end

return TipSubSkillDesc
