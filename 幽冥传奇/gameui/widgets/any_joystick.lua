
-- 可以在任意位置出现的摇杆

AnyJoystick = AnyJoystick or BaseClass()

JoystickEvent = {
	Began = 0,
	Update = 1,
	Ended = 2,
}

function AnyJoystick:__init()
	self.view = XLayout:create()
	self.view:setVisible(true)

	self.img_bg = nil
	self.img_ball = nil
	self.radius = 0

	self.is_start = false
	self.touch_id = nil
	self.began_time = 0
	self.began_point = cc.p(0, 0)
	self.last_event_time = 0
	self.touch_timer = nil

	self.callback = nil

	self:RegisterAllEvents()
end

function AnyJoystick:__delete()
	self.view = nil
	self:UnRegisterAllEvents()
	self:EndTimer()
end

function AnyJoystick:RegisterAllEvents()
	self.eh_began = GlobalEventSystem:Bind(LayerEventType.TOUCH_BEGAN, BindTool.Bind(self.OnTouchBegan, self))
	self.eh_moved = GlobalEventSystem:Bind(LayerEventType.TOUCH_MOVED, BindTool.Bind(self.OnTouchMoved, self))
	self.eh_ended = GlobalEventSystem:Bind(LayerEventType.TOUCH_ENDED, BindTool.Bind(self.OnTouchEnded, self))
	self.eh_cancelled = GlobalEventSystem:Bind(LayerEventType.TOUCH_CANCELLED, BindTool.Bind(self.OnTouchCancelled, self))
end

function AnyJoystick:UnRegisterAllEvents()
	GlobalEventSystem:UnBind(self.eh_began)
	GlobalEventSystem:UnBind(self.eh_moved)
	GlobalEventSystem:UnBind(self.eh_ended)
	GlobalEventSystem:UnBind(self.eh_cancelled)
end

function AnyJoystick:GetView()
	return self.view
end

function AnyJoystick:Create(bg_path, ball_path)
	self.img_bg = XUI.CreateImageView(0, 0, bg_path, is_plist)
	self.view:addChild(self.img_bg)
	self.radius = self.img_bg:getContentSize().width / 2

	self.img_ball = XUI.CreateImageView(0, 0, ball_path, is_plist)
	self.view:addChild(self.img_ball)

	self:NormalShow()
end

function AnyJoystick:SetCallback(callback)
	self.callback = callback
end

function AnyJoystick:NormalShow()
	self.view:setVisible(true)
	self.view:setOpacity(180)
end

function AnyJoystick:MovingShow()
	self.view:setVisible(true)
	self.view:setOpacity(255)
end

function AnyJoystick:OnTouchBegan(touch, event)
	if nil ~= self.touch_id then
		return
	end
	self.touch_id = touch:getId()

	self.is_start = false
	self.began_time = Status.NowTime
	self.began_point = touch:getLocation()

	self:StartTimer()
end

function AnyJoystick:OnTouchMoved(touch, event)
	if self.touch_id ~= touch:getId() then
		return
	end

	local now_point = touch:getLocation()
	self:MoveBall(now_point.x - self.began_point.x, now_point.y - self.began_point.y)
end

function AnyJoystick:OnTouchEnded(touch, event)
	if self.touch_id ~= touch:getId() then
		return
	end
	self.touch_id = nil

	self:EndTimer()
	self:MoveBall(0, 0, true)

	if self.is_start then
		self.is_start = false
		self:PushEvent(JoystickEvent.Ended)

		self:NormalShow()

		local fadeout = cc.FadeTo:create(0.2, 180)
		local callback = cc.CallFunc:create(function()
			self:NormalShow()
		end)
		local action = cc.Sequence:create(fadeout, callback)
		self.view:stopAllActions()
		self.view:runAction(action)
	end
end

function AnyJoystick:OnTouchCancelled(touch, event)
	self:OnTouchEnded(touch, event)
end

function AnyJoystick:StartTimer()
	if nil == self.touch_timer then
		self.touch_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.OnTimerUpdate, self), 0.1)
	end
end

function AnyJoystick:OnTimerUpdate()
	if Status.NowTime - self.began_time <= 0.2 then
		return
	end

	if not self.is_start then
		self.is_start = true

		local parent = self.view:getParent()
		if nil ~= parent then
			local node_pos = parent:convertToNodeSpace(self.began_point)
			-- self.view:setPosition(node_pos)
		end

		self:PushEvent(JoystickEvent.Began)
	else
		if Status.NowTime - self.last_event_time >= 0.1 then
			local opacity = math.min(self.view:getOpacity() + 10, 255)
			self.view:setOpacity(opacity)
			self:PushEvent(JoystickEvent.Update)
		end
	end
end

function AnyJoystick:EndTimer()
	if nil ~= self.touch_timer then
		GlobalTimerQuest:CancelQuest(self.touch_timer)
		self.touch_timer = nil
	end
end

function AnyJoystick:MoveBall(x, y, is_animation)
	self.img_ball:stopAllActions()

	local real_x, real_y = x, y
	local dis = GameMath.GetDistance(x, y, 0, 0, true)
	if dis > self.radius then
		real_x = x / dis * self.radius
		real_y = y / dis * self.radius
	end

	if is_animation then
		local move_to = cc.MoveTo:create(0.2, cc.p(real_x, real_y))
		self.img_ball:runAction(move_to)
	else
		self.img_ball:setPosition(real_x, real_y)
	end
end

function AnyJoystick:PushEvent(event_type)
	self.last_event_time = Status.NowTime
	if nil ~= self.callback then
		local x, y = self.img_ball:getPosition()
		self.callback(event_type, x, y)
	end
end
