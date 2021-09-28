-- 手柄 功能：1.设置触控拖放区域，2.设置活动拖动区 3.是否拖动才显示状态, 4.是否固定位置
CustomJoystick =BaseClass(LuaUI)

CustomJoystick.mainJoystick = nil -- 主UI手柄 作用于行走，这里做静态存储
CustomJoystick.skillJoystick = nil -- 技能手柄 作用于技能选择方向或点位，这里做静态存储
-- Automatic code generation, don't change this function (Constructor) use .New(...)
	function CustomJoystick:__init(x, y, isAllwayShow, isFreezePos)
		self.URL = "ui://0tyncec1ppo026";
		self:__property( x,y, isAllwayShow, isFreezePos )
		self.onDown = nil -- 按下代理
		self:Config()
	end

	-- 手柄中心位置，， 是否常显示,如果不显示将在碰触区时显示
	function CustomJoystick:SetProperty(x, y, isAllwayShow, isFreezePos)
		self.x, self.y = x, y
		if isAllwayShow == nil then
			isAllwayShow = true
		end
		self.isAllwayShow = isAllwayShow == true
		self.isFreezePos = isFreezePos == true
		self.radius = 100
	end

function CustomJoystick:SetTouchTarget(skillBtn)
	self.onDown = function (context)
		if not self.isAllwayShow then
			self.bg.visible = true
			self.joystick.visible = true
		end
		self:onTouchDown(context)
	end
	skillBtn.onTouchBegin:Add(self.onDown)
end

-- Logic Starting
function CustomJoystick:Config()
	self.bg.visible = self.isAllwayShow
	self.joystick.visible = self.isAllwayShow

	self.touchId = -1
	self:SetXY(self.x, self.y)
	
	local v2 = self.joystick.xy-- 手柄
	self.srcX = v2.x
	self.srcY = v2.y

	self.preX = self.srcX
	self.preY = self.srcY

	self.preMoveX = 0
	self.preMoveY = 0

	self.width = self.joystick.width
	self.height = self.joystick.height
	self.root = layerMgr:GetUILayer()

	self.onMove = EventListener.New(self.ui,"onMove")
	self.onEnd = EventListener.New(self.ui,"onEnd")
	self.onDown = function (context)
		if not self.isAllwayShow then
			self.bg.visible = true
			self.joystick.visible = true
		end

		self:onTouchDown(context)
	end
	self.joystick_touch.onTouchBegin:Add(self.onDown)

	self.posScale = Vector2.zero

	self.innerRadius = 45 --内圈半径 
	self.useInner = false --是否使用内圈
	self.defaultPos = Vector2.New(0, 0) --默认起始位置
end

-- 设置碰触区大小
function CustomJoystick:SetTouchSize(w, h )
	if self.isFreezePos then return end
	self.joystick_touch:SetSize(w, h)
end
--设置技能操纵杆位置
function CustomJoystick:SetSkillJoystickPos(skillBtn)
	local joystickW = 222*0.5 + 10
	local joystickH = 221*0.5 + 10

	self.skillJoyPos = skillBtn.position
	self.skillJoyWid = skillBtn.width *0.5
	self.skillJoyHei = skillBtn.height *0.5
	
	local xx = self.skillJoyPos.x + self.skillJoyWid
	local yy = self.skillJoyPos.y + self.skillJoyHei

	if xx + joystickW >  layerMgr.WIDTH then
		xx = xx - (xx + joystickW - layerMgr.WIDTH)
	end

	if yy + joystickH >  layerMgr.HEIGHT then
		yy = yy - (yy + joystickH - layerMgr.HEIGHT)
	end

	self:SetXY(xx, yy)
	self.preX = xx
	self.preY = yy
	self:SetJoyPos(Vector2.New(xx, yy))
	self.defaultPos = Vector2.New(self.joystick.x, self.joystick.y)
end

function CustomJoystick:onTouchDown( context )
	if self.touchId == -1 then
		self.joystick.selected = true
		local evt = context.data

		self.touchId = evt.touchId
		local pt = self.root:GlobalToLocal(Vector2.New(evt.x, evt.y))
		if not self.isFreezePos then
			self:SetXY(pt.x,pt.y)
		end

		local v2 = self.joystick.xy
		self.preX = pt.x
		self.preY = pt.y

		if self.skillJoyPos ~= nil then
			local xx = self.skillJoyPos.x + self.skillJoyWid
			local yy = self.skillJoyPos.y + self.skillJoyHei
			self:SetXY(xx, yy)
			self.preX = xx
			self.preY = yy
			self:SetJoyPos(Vector2.New(xx, yy))
			self.defaultPos = Vector2.New(self.joystick.x, self.joystick.y)
		end

		Stage.inst.onTouchMove:Add(self.onTouchMove,self)
		Stage.inst.onTouchEnd:Add(self.onTouchEnd, self)
	end
end
local RAD = 180 / Mathf.PI
function CustomJoystick:SetJoyPos(pt)
	local moveX = pt.x - self.preX
	local moveY = pt.y - self.preY
	local rad = Mathf.Atan2(moveY, moveX)
	local degree = rad * RAD
	self.joystick.rotation = degree + 90

	local maxX = self.radius * Mathf.Cos(rad)
	local maxY = self.radius * Mathf.Sin(rad)

	if math.abs(moveX) < math.abs(maxX) then maxX = moveX end
	if math.abs(moveY) < math.abs(maxY) then maxY = moveY end

	local dx = maxX+self.srcX
	local dy = maxY+self.srcY
	self.joystick:SetXY(dx, dy)
	self.posScale = Vector2.New(maxX/self.radius, -maxY/self.radius)
end

function CustomJoystick:onTouchMove(context)
	local evt = context.data
	if evt and self.touchId ~= -1 and evt.touchId == self.touchId then
		local pt = self.root:GlobalToLocal(Vector2.New(evt.x, evt.y))
		local moveX = pt.x - self.preX
		local moveY = pt.y - self.preY
		if math.abs(self.preMoveX - moveX) + math.abs(self.preMoveY - moveY) < 0.001 then return end
		self.preMoveX = moveX
		self.preMoveY = moveY
		local rad = Mathf.Atan2(moveY, moveX)
		local maxX = self.radius * Mathf.Cos(rad)
		local maxY = self.radius * Mathf.Sin(rad)
		if math.abs(moveX) < math.abs(maxX) then maxX = moveX end
		if math.abs(moveY) < math.abs(maxY) then maxY = moveY end
		local dx = maxX+self.srcX
		local dy = maxY+self.srcY
		if not self.joystick then return end

		self.joystick:SetXY(dx, dy)

		local canUpdate = false
		if self.useInner then
	  		if Vector2.Distance(Vector2.New(self.joystick.x, self.joystick.y), self.defaultPos) >= self.innerRadius then
	  			canUpdate = true
	  		end
	  	else
	  		canUpdate = true
		end

		if canUpdate then
	  		self.posScale = Vector2.New(maxX/self.radius, -maxY/self.radius)
			local degree = rad * RAD
			local joyRot = degree + 90
			self.onMove:Call(joyRot)
			self.joystick.rotation = joyRot
		end
	end
end

function CustomJoystick:onTouchEnd(context)
	local inputEvt = context.data
	GlobalDispatcher:DispatchEvent(EventName.Player_StopWorldNavigation)
	GlobalDispatcher:DispatchEvent(EventName.Player_AutoRunEnd)
	 --玩家自动寻路结束
	GlobalDispatcher:DispatchEvent(EventName.StopReturnMainCity) -- 停止回城动作
	if inputEvt and self.touchId ~= -1 and inputEvt.touchId == self.touchId then
		self:EndDrag()
		self.onEnd:Call()
	end
end

function CustomJoystick:EndDrag()
	self.joystick.selected = false
	self.touchId = -1
	Stage.inst.onTouchMove:Remove(self.onTouchMove,self)
	Stage.inst.onTouchEnd:Remove(self.onTouchEnd,self)
	self.preMoveX = 0
	self.preMoveY = 0
	self.joystick.x = self.srcX
	self.joystick.y = self.srcY
	if not self.isFreezePos then
		self.ui.x = self.x
		self.ui.y = self.y
	end
	-- self.onEnd:Call()
	if not self.isAllwayShow then
		self.bg.visible = false
		self.joystick.visible = false
	end
end

-- Register UI classes to lua
function CustomJoystick:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Common","CustomJoystick");

	self.bg = self.ui:GetChildAt(0)
	self.joystick = self.ui:GetChildAt(1)
	self.joystick_touch = self.ui:GetChildAt(2)
end

-- 改变底图(212*212)或手把图资源 assetbundle
function CustomJoystick:ResetRes( bg, thumb )
	if bg then
		self.bg.url = bg -- "Icon/xxx/xxxx/xxx" -- 不带 .unity3d
	end
	if thumb then
		self.joystick.icon = thumb
	end
end

-- Combining existing UI generates a class
function CustomJoystick.Create( ui, ...)
	return CustomJoystick.New(ui, "#", {...})
end

-- Dispose use CustomJoystick obj:Destroy()
function CustomJoystick:__delete()
	if self.onTouchMove then
		Stage.inst.onTouchMove:Clear()
	end
	if self.onTouchEnd then
		Stage.inst.onTouchEnd:Clear()
	end
	if self.joystick_touch then
		self.joystick_touch.onTouchBegin:Clear()
	end
	self.bg = nil
	self.joystick_touch = nil
	self.onTouchMove = nil
	self.onTouchEnd = nil
	self.joystick = nil
end