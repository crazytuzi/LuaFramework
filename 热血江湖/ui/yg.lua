-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_yg = i3k_class("wnd_yg", ui.wnd_base)

function wnd_yg:ctor()
end

function wnd_yg:configure(...)
	local screenSize = cc.Director:getInstance():getWinSize();
	local rootSize = self._layout.root:getContentSize();

	local control=self._layout.vars.control
	local direct=self._layout.vars.direct

	if control then control:onTouchEvent(self, self.controlClick) end
	if direct then direct:onTouchEvent(self, self.controlClick) end 
	
	local usercfg = g_i3k_game_context:GetUserCfg()
	local usercontrol = usercfg:GetUserControl()
	if usercontrol==1 then
		self:hide()
	else
		self:show()
	end

	local logic = i3k_game_get_logic();
	self._mainCamera = logic:GetMainCamera();
end

function wnd_yg:onShow()
	local direct = self._layout.vars.direct
	local control = self._layout.vars.control
	self._directPos = direct:getPosition()
	self._radius=direct:getContentSize().width/2
end

function wnd_yg:onHide()
	self:setControlDirect(0, 0)
end

function wnd_yg:controlControler(touchPos, player, force)
	local control = self._layout.vars.control
	-------摇杆运动范围的控制---------
	local distance=math.sqrt(((self._directPos.x-touchPos.x)*(self._directPos.x-touchPos.x))+((self._directPos.y-touchPos.y)*(self._directPos.y-touchPos.y)))
	local x = touchPos.x - self._directPos.x
	local y = touchPos.y - self._directPos.y
	if distance<self._radius then
		control:setPosition(touchPos.x, touchPos.y)
	else
		x=self._radius*(x)/distance
		y=self._radius*(y)/distance
		control:setPosition(self._directPos.x+x, self._directPos.y+y)
	end
	-------下面是随摇杆运动伴随的人物的运动--------
	if force or self.lastTick % 5 == 0 then
		local angle = math.atan(y/x) - self._mainCamera._angle;
		if x < 0 then
			angle = angle + 3.14159
		end
		local vel = { x = math.cos(angle), y = 0, z = math.sin(angle) }
		player:SetVelocity(vel);
	end
end

function wnd_yg:setControlDirect(x, y)
	local distance=x*x + y*y
	if distance < 0.002 then
		self:handleControl(ccui.TouchEventType.ended, nil)
		return
	end
	local pos = {x = self._directPos.x + x * self._radius, y = self._directPos.y + y * self._radius * -1}
	self:handleControl(ccui.TouchEventType.began, pos)
end

function wnd_yg:handleControl(eventType, pos)
	local player = i3k_game_get_logic():GetPlayer()
	local hero = player:GetHero()
	if eventType==ccui.TouchEventType.moved then
		if self.lastTick ~= i3k_get_update_tick() then
			self.lastTick = i3k_get_update_tick()
			hero._PreCommand = ePreTypeJoystickMove;
			self:controlControler(pos, player, true)
		end
	elseif eventType==ccui.TouchEventType.began then
		hero._PreCommand = ePreTypeJoystickMove;
		g_i3k_game_context:SetjoystickMoveState(true);
		g_i3k_game_context:SetFindPathData()
		if hero._AutoFight then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(114))	
		end
		self._layout.vars.control:stateToPressed()
		self._layout.vars.direct:stateToPressed()
		self:controlControler(pos, player, true)
	else
		local control = self._layout.vars.control
		hero._PreCommand = -1;
		g_i3k_game_context:SetjoystickMoveState(false);

		control:stateToNormal()
		self._layout.vars.direct:stateToNormal()
		control:setPosition(self._directPos.x, self._directPos.y)

		player:StopMove()
	end
end

function wnd_yg:controlClick(sender, eventType)
	local pos = nil
	if eventType==ccui.TouchEventType.moved or eventType==ccui.TouchEventType.began then
		pos = sender:getParent():convertToNodeSpace(g_i3k_ui_mgr:GetMousePos())
	end
	self:handleControl(eventType, pos)
end

function wnd_create(layout, ...)
	local wnd = wnd_yg.new();
		wnd:create(layout, ...);

	return wnd;
end

