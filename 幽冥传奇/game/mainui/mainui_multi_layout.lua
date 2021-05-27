----------------------------------------------------------
--分层次布局，减少渲染提交批次
----------------------------------------------------------

MainuiMultiLayout = MainuiMultiLayout or BaseClass()
function MainuiMultiLayout:__init()
	self.data = nil
	self.layout_list = {}

	self.is_visible = true
end

function MainuiMultiLayout:__delete()

end

function MainuiMultiLayout:GetData(data)
	return self.data
end

function MainuiMultiLayout:SetData(data)
	self.data = data
end

function MainuiMultiLayout:CreateByParent(parent, zorder_begin)
	zorder_begin = zorder_begin or 0
	self.layout_list.bg_layout = self:CreateLayout(parent, zorder_begin)
	self.layout_list.texture_layout = self:CreateLayout(parent, zorder_begin + 1)
	self.layout_list.text_layout = self:CreateLayout(parent, zorder_begin + 2)
	self.layout_list.effect_layout = self:CreateLayout(parent, zorder_begin + 3)
end

function MainuiMultiLayout:CreateByMultiLayout(multi_layout, zorder)
	zorder = zorder or 0
	self.layout_list.bg_layout = self:CreateLayout(multi_layout:BgLayout(), zorder)
	self.layout_list.texture_layout = self:CreateLayout(multi_layout:TextureLayout(), zorder)
	self.layout_list.text_layout = self:CreateLayout(multi_layout:TextLayout(), zorder)
	self.layout_list.effect_layout = self:CreateLayout(multi_layout:EffectLayout(), zorder)
end

-- 根据需要选择性创建
function MainuiMultiLayout:CreateHalf(multi_layout, exist_text, exist_eff, exist_bg)
	self.layout_list.texture_layout = self:CreateLayout(multi_layout:TextureLayout(), 0, true)

	if exist_text then
		self.layout_list.text_layout = self:CreateLayout(multi_layout:TextLayout(), 0)
	end
	if exist_eff then
		self.layout_list.effect_layout = self:CreateLayout(multi_layout:EffectLayout(), 0)
	end
	if exist_bg then
		self.layout_list.bg_layout = self:CreateLayout(multi_layout:BgLayout(), 0)
	end
end

function MainuiMultiLayout:CreateLayout(parent, zorder)
	local layout = XLayout:create()
	layout:setAnchorPoint(0.5, 0.5)
	parent:addChild(layout, zorder, zorder)
	return layout
end

function MainuiMultiLayout:BgLayout()
	return self.layout_list.bg_layout
end

function MainuiMultiLayout:TextureLayout()
	return self.layout_list.texture_layout
end

function MainuiMultiLayout:TextLayout()
	return self.layout_list.text_layout
end

function MainuiMultiLayout:EffectLayout()
	return self.layout_list.effect_layout
end

function MainuiMultiLayout:SetBgColor(color)
	self.layout_list.texture_layout:setBackGroundColor(color or cc.c3b(0, 0, 255))
	self.layout_list.texture_layout:setBackGroundColorOpacity(128)
end

function MainuiMultiLayout:AddClickEventListener(click_callback)
	if nil == self.layout_list.texture_layout then
		return
	end
	
	local old_scale = 1
	local is_scale = true
	local touch_times = 0
	local function touch_event(sender, event_type)
		if event_type == XuiTouchEventType.Began then
			if touch_times == 0 then
				old_scale = self:getScale()
				touch_times = touch_times + 1
			end
			self:setScale(old_scale + 0.1)
		elseif event_type == XuiTouchEventType.Moved then
			if is_scale and not sender:isHitted() then
				is_scale = false
				self:setScale(old_scale)
			elseif not is_scale and sender:isHitted() then
				is_scale = true
				self:setScale(old_scale + 0.1)
			end
		elseif event_type == XuiTouchEventType.Ended then
			self:setScale(old_scale)
			if nil ~= click_callback then
				click_callback(self)
			end
			touch_times = math.max(touch_times - 1, 0)
		elseif event_type == XuiTouchEventType.Canceled then
			self:setScale(old_scale)
			touch_times = math.max(touch_times - 1, 0)
		end
	end

	self.layout_list.texture_layout:setTouchEnabled(true)
	self.layout_list.texture_layout:addTouchEventListener(touch_event)
end

function MainuiMultiLayout:MoveTo(move_time, x, y)
	local target_pos = cc.p(x, y)
	for k, v in pairs(self.layout_list) do
		v:stopAllActions()
		local moveto = cc.MoveTo:create(move_time, target_pos)
		v:runAction(moveto)
	end
end

function MainuiMultiLayout:MoveBy(move_time, x, y)
	local target_pos = cc.p(x, y)
	for k, v in pairs(self.layout_list) do
		v:stopAllActions()
		local moveto = cc.MoveBy:create(move_time, target_pos)
		v:runAction(moveto)
	end
end

function MainuiMultiLayout:FadeIn(fade_time)
	for k, v in pairs(self.layout_list) do
		v:stopAllActions()
		local fadein = cc.FadeIn:create(fade_time)
		v:runAction(fadein)
	end
end

function MainuiMultiLayout:FadeOut(fade_time)
	for k, v in pairs(self.layout_list) do
		v:stopAllActions()
		local fadeout = cc.FadeOut:create(fade_time)
		v:runAction(fadeout)
	end
end

function MainuiMultiLayout:AnyLayout()
	for k, v in pairs(self.layout_list) do
		return v
	end

	return nil
end

----------------------------------------------------
-- 模拟Node接口 begin
----------------------------------------------------
function MainuiMultiLayout:getPositionX()
	return self:AnyLayout():getPositionX()
end

function MainuiMultiLayout:getPositionY()
	return self:AnyLayout():getPositionY()
end

function MainuiMultiLayout:getPosition()
	return self:AnyLayout():getPosition()
end

function MainuiMultiLayout:setPosition(x, y)
	for k, v in pairs(self.layout_list) do
		v:setPosition(x, y)
	end
end

function MainuiMultiLayout:setPositionX(x)
	for k, v in pairs(self.layout_list) do
		v:setPositionX(x)
	end
end

function MainuiMultiLayout:setPositionY(y)
	for k, v in pairs(self.layout_list) do
		v:setPositionY(y)
	end
end

function MainuiMultiLayout:getAnchorPoint()
	return self:AnyLayout():getAnchorPoint()
end

function MainuiMultiLayout:setAnchorPoint(anchor_point)
	for k, v in pairs(self.layout_list) do
		v:setAnchorPoint(anchor_point)
	end
end

function MainuiMultiLayout:getContentSize()
	return self:AnyLayout():getContentSize()
end

function MainuiMultiLayout:setContentSize(size)
	for k, v in pairs(self.layout_list) do
		v:setContentSize(size)
	end
end

function MainuiMultiLayout:isVisible()
	return self:AnyLayout():isVisible()
end

function MainuiMultiLayout:setVisible(is_visible)
	self.is_visible = is_visible

	for k, v in pairs(self.layout_list) do
		v:setVisible(is_visible)
	end
end

function MainuiMultiLayout:getScale()
	return self:AnyLayout():getScale()
end

function MainuiMultiLayout:setScale(scale)
	for k, v in pairs(self.layout_list) do
		v:setScale(scale)
	end
end

function MainuiMultiLayout:getScaleX()
	return self:AnyLayout():getScaleX()
end

function MainuiMultiLayout:setScaleX(scale)
	for k, v in pairs(self.layout_list) do
		v:setScaleX(scale)
	end
end

function MainuiMultiLayout:getScaleY()
	return self:AnyLayout():getScaleY()
end

function MainuiMultiLayout:setScaleY(scale)
	for k, v in pairs(self.layout_list) do
		v:setScaleY(scale)
	end
end

function MainuiMultiLayout:getOpacity()
	return self:AnyLayout():getOpacity()
end

function MainuiMultiLayout:setOpacity(opacity)
	if opacity <= 0 and self.is_visible then
		for k, v in pairs(self.layout_list) do
			v:setVisible(false)
		end
	elseif opacity > 0 and self.is_visible then
		for k, v in pairs(self.layout_list) do
			v:setVisible(self.is_visible)
		end
	end

	for k, v in pairs(self.layout_list) do
		v:setOpacity(opacity)
	end
end

function MainuiMultiLayout:runAction(action)
	for k, v in pairs(self.layout_list) do
		v:runAction(action:clone())
	end
end

function MainuiMultiLayout:stopAllActions()
	for k, v in pairs(self.layout_list) do
		v:stopAllActions()
	end
end

function MainuiMultiLayout:removeFromParent()
	for k, v in pairs(self.layout_list) do
		v:removeAllChildren()
		v:removeFromParent()
	end
end

function MainuiMultiLayout:convertToWorldSpace(pos)
	return self:AnyLayout():convertToWorldSpace(pos)
end

function MainuiMultiLayout:getParent()
	return self:AnyLayout():getParent()
end

function MainuiMultiLayout:getChildren()
	local child_list = {}
	for k, v in pairs(self.layout_list) do
		local children = v:getChildren()
		for k,v in pairs(children) do
			table.insert(child_list, v)
		end
	end
	return child_list
end

----------------------------------------------------
-- 模拟Node接口 end
----------------------------------------------------

function MainuiMultiLayout.CreateMultiLayout(x, y, anchor_point, size, parent, zorder)
	local multi_layout = MainuiMultiLayout.New()
	multi_layout:CreateByMultiLayout(parent, zorder)
	multi_layout:setPosition(x, y)
	multi_layout:setAnchorPoint(anchor_point)
	multi_layout:setContentSize(size)
	return multi_layout
end
