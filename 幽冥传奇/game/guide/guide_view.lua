GuideView = GuideView or BaseClass()

GuideView.RectColor = cc.c4f(1, 1, 0, 1)

function GuideView:__init()
	self.is_modal = true
	self.arrow = ""
	self.showing_remind_eff = false

	self.root_node = nil
	self.layout_left = nil
	self.layout_right = nil
	self.layout_top = nil
	self.layout_bottom = nil
	self.layout_center = nil
	self.draw_node = nil

	self.touch_begin = {x = 0, y = 0}
	self.touch_end = {x = 0, y = 0}
	self.touch_move_distance = {x = 0, y = 0}
end

function GuideView:__delete()
end

function GuideView:Open(guide_cfg)
	self.is_modal = guide_cfg.is_modal

	if nil == self.root_node then
		self.root_node = cc.Node:create()
		HandleRenderUnit:AddUi(self.root_node, COMMON_CONSTS.ZORDER_GUIDE, COMMON_CONSTS.ZORDER_GUIDE)

		self.layout_left = self:CreateBlackLayout()
		self.layout_right = self:CreateBlackLayout()
		self.layout_top = self:CreateBlackLayout()
		self.layout_bottom = self:CreateBlackLayout()

		self.layout_center = XLayout:create()
		self.layout_center:setSwallowTouches(false)
		self.root_node:addChild(self.layout_center)
		self.layout_center:addTouchEventListener(BindTool.Bind(self.OnTouchView, self))
		self.layout_center:setTouchEnabled(true)

		self:ShowRemindImg(true)	

		self.draw_node = cc.DrawNode:create()
		self.root_node:addChild(self.draw_node)
	end

	self:FlushVisible()
	if self.arrow ~= guide_cfg.arrow then
		self.arrow = guide_cfg.arrow
		self:FlushArrow()
	end
	if nil ~= self.arrow_frame then
		self.arrow_frame:setTitleText(guide_cfg.arrow_text)
	end
end

function GuideView:IsOpen()
	return nil ~= self.root_node
end

function GuideView:CreateBlackLayout()
	local layout = XLayout:create()
	-- layout:setBackGroundColor(COLOR3B.BLACK)
	-- layout:setBackGroundColorOpacity(100)
	self.root_node:addChild(layout)
	-- XUI.AddClickEventListener(layout, BindTool.Bind(self.OnClickBlackLayout, self))
	return layout
end

function GuideView:Close()
	if nil ~= self.root_node then
		NodeCleaner.Instance:AddNode(self.root_node)
		self.root_node = nil
	end
	self.arrow = ""
	self.arrow_root = nil
	self.remind_img = nil
end

function GuideView:SetIsModal(is_modal)
	self.is_modal = is_modal
	self:FlushVisible()
end

function GuideView:FlushVisible()
	if nil ~= self.root_node then
		self.layout_left:setVisible(self.is_modal)
		self.layout_right:setVisible(self.is_modal)
		self.layout_top:setVisible(self.is_modal)
		self.layout_bottom:setVisible(self.is_modal)
	end
end

function GuideView:FlushArrow()
	if nil == self.arrow_root then
		self.arrow_root = cc.Node:create()
		self.root_node:addChild(self.arrow_root, 1)
		self.arrow_node = cc.Node:create()
		self.arrow_root:addChild(self.arrow_node)
		self.arrow_frame = XButton:create(ResPath.GetGuide("arrow_frame"), "", "")
		self.arrow_frame:setTitleFontSize(25)
		self.arrow_frame:setTouchEnabled(false)
		self.arrow_node:addChild(self.arrow_frame)
		self.arrow_frame:setTitleFontName(COMMON_CONSTS.FONT)
		local label = self.arrow_frame:getTitleLabel()
		if label then
			label:setColor(COLOR3B.G_Y)
			label:enableOutline(cc.c4b(0, 0, 0, 100), 1.5)
		end
		self.arrow_point = XUI.CreateImageView(0, 0, ResPath.GetGuide("arrow_point"))
		self.arrow_point:setAnchorPoint(1, 0.5)
		self.arrow_node:addChild(self.arrow_point)
	end

	local offset_x = 35
	local rotation, anc_x, anc_y, x, y = -90, 0.5, 1, 0, -offset_x
	local move1, move2 = nil, nil
	if self.arrow == "up" then
		rotation, anc_x, anc_y, x, y = -90, 0.5, 1, 0, -offset_x
		move1 = cc.MoveTo:create(0.5, cc.p(0, -10))
		move2 = cc.MoveTo:create(0.5, cc.p(0, 0))
	elseif self.arrow == "down" then
		rotation, anc_x, anc_y, x, y = 90, 0.5, 0, 0, offset_x
		move1 = cc.MoveTo:create(0.5, cc.p(0, 10))
		move2 = cc.MoveTo:create(0.5, cc.p(0, 0))
	elseif self.arrow == "left" then
		rotation, anc_x, anc_y, x, y = 180, 0, 0.5, offset_x, 0
		move1 = cc.MoveTo:create(0.5, cc.p(10, 0))
		move2 = cc.MoveTo:create(0.5, cc.p(0, 0))
	else
		rotation, anc_x, anc_y, x, y = 0, 1, 0.5, -offset_x, 0
		move1 = cc.MoveTo:create(0.5, cc.p(-10, 0))
		move2 = cc.MoveTo:create(0.5, cc.p(0, 0))
	end

	self.arrow_point:setRotation(rotation)
	self.arrow_frame:setAnchorPoint(anc_x, anc_y)
	self.arrow_frame:setPosition(x, y)
	local action = cc.RepeatForever:create(cc.Sequence:create(move1, move2))
	self.arrow_node:stopAllActions()
	self.arrow_node:runAction(action)
end

function GuideView:SetCenterRect(x, y, w, h)
	if nil ~= self.root_node then
		local screen_w, screen_h = HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()

		self.layout_left:setPosition(0, 0)
		self.layout_left:setContentWH(x, screen_h)

		self.layout_right:setPosition(x + w, 0)
		self.layout_right:setContentWH(screen_w - (x + w), screen_h)

		self.layout_top:setPosition(x, y + h)
		self.layout_top:setContentWH(w, screen_h - (y + h))

		self.layout_bottom:setPosition(x, 0)
		self.layout_bottom:setContentWH(w, y)

		self.layout_center:setPosition(x, y)
		self.layout_center:setContentWH(w, h)

		self:ShowRemindImg(true)

		if self.arrow == "up" then
			self.arrow_root:setPosition(x + w / 2, y)
		elseif self.arrow == "down" then
			self.arrow_root:setPosition(x + w / 2, y + h)
		elseif self.arrow == "left" then
			self.arrow_root:setPosition(x + w, y + h / 2)
		else
			self.arrow_root:setPosition(x, y + h / 2)
		end
	end
end

function GuideView:OnClickBlackLayout()
	if not self.showing_remind_eff then
		self:ShowRemindEff()
	end
end

function GuideView:ShowRemindEff()
	self.showing_remind_eff = true
	self:ShowRemindImg(false)
	self:PlayRemindEff()
	CountDown.Instance:AddCountDown(0.5, 0.2, function(elapse_time, total_time)
		if elapse_time < total_time then
			self:PlayRemindEff()
		else
			self.showing_remind_eff = false
			self:ShowRemindImg(true)
		end
	end)
end

function GuideView:PlayRemindEff()
	if not self:IsOpen() then
		return
	end

	local x, y = self.layout_center:getPosition()
	local size = self.layout_center:getContentSize()

	local img = XUI.CreateImageView(x + size.width / 2, y + size.height / 2, ResPath.GetCommon("common_exterior_effect"))
	img:setScale(1.3)
	self.root_node:addChild(img, 999)

	local scale_to = cc.ScaleTo:create(0.4, 0)
	local fade_out = cc.FadeOut:create(0.7)
	local clean_func = cc.CallFunc:create(function() img:removeFromParent() end)
	local act_seq = cc.Sequence:create(cc.EaseSineInOut:create(cc.Spawn:create(scale_to, fade_out)), clean_func)
	img:runAction(act_seq)
end

function GuideView:ShowRemindImg(vis)
	if not self:IsOpen() then
		return
	end

	local x, y = self.layout_center:getPosition()
	local size = self.layout_center:getContentSize()

	if nil == self.remind_img then
		local img = XUI.CreateImageView(x + size.width / 2, y + size.height / 2, ResPath.GetCommon("common_exterior_effect"))
		self.root_node:addChild(img, 999)
		self.remind_img = img

		local scale_to = cc.ScaleTo:create(0.4, 0.5)
		local fade_out = cc.FadeOut:create(0.3)
		local init_func = cc.CallFunc:create(function() 
			img:setScale(1)
			img:setOpacity(255)
		end)
		local act_seq = cc.Sequence:create(init_func, cc.Spawn:create(scale_to, fade_out), cc.DelayTime:create(0.3))
		img:runAction(cc.RepeatForever:create(act_seq))
	end

	self.remind_img:setVisible(vis)
	self.remind_img:setPosition(x + size.width / 2, y + size.height / 2)
end

function GuideView:OnTouchView(sender, event_type, touch)
	if event_type == XuiTouchEventType.Began then
		self.touch_begin = touch:getLocation()
	elseif event_type == XuiTouchEventType.Moved then
		GuideCtrl.Instance:OnGuideTouch()
	elseif event_type == XuiTouchEventType.Ended then
		self.touch_end = touch:getLocation()
		if sender:isContainsPoint(self.touch_end) then
			self:OnClickCenterLayout()
		end
	end
end

function GuideView:OnClickCenterLayout()
	if self.next_click_time == nil or self.next_click_time < Status.NowTime then
		self.next_click_time = Status.NowTime + 0.5
		GuideCtrl.Instance:OnClick()
	end
end
