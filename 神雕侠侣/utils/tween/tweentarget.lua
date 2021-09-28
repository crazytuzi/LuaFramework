--**************************
-- TweenNano 使用的target 
-- example1：
--  	local t = TweenTarget:new(wnd, TweenTarget.Window)
-- 		TweenNano.to(t, 0.3, {x = 100, alpha = 0.4, onUpdate = func, callbackTarget = self})
--
-- example2:
--		local t = TweenTarget:new(uiSprite, TweenTarget.Sprite)
--		TweenNano.to(t, 0.5, {x=100, y = 100, onUpdate = func, onComplete = func, callbackTarget = self})
--		

-- NOTICE: UISprite: 还没有实现alpha的支持
--**************************
TweenTarget = {
	m_ptype = "",
	m_x = 0,
	m_y = 0,
	m_alpha = 1,
	
}
TweenTarget.__index = TweenTarget

TweenTarget.Sprite = 1  --CUISprite
TweenTarget.Window = 2  --CEGUIWindow

function TweenTarget:new(target, mtype)
	if not target then return nil end
	if not mtype then mtype = TweenTarget.Window end

	local self = {}
	setmetatable(self, TweenTarget)
	self.__index = self

	function init()
		self.m_target = target
		self.m_ptype = mtype
		if mtype == TweenTarget.Sprite then
			local loc = self.m_target:GetUILocation()
			self.m_x = loc.x
			self.m_y = loc.y
			self.m_alpha = 1
		elseif mtype == TweenTarget.Window then
			local pos = target:getPosition()
			self.m_x = pos.x.offset
			self.m_y = pos.y.offset
			self.m_alpha = self.m_target:getAlpha()
			self.m_pWindowName = self.m_target:getName()
			self.m_pScale = 1
			self.m_pRotationY = 0.00001 
		else

		end
	end
	init()
	return self
end

-- 设置坐标x
function TweenTarget:setX(x)
	if not self.m_target then return end
	if self.m_x == x then return end 
	self.m_x = x
	if self.m_ptype == TweenTarget.Sprite then
		local loc = XiaoPang.CPOINT(self.m_x, self.m_y)
		self.m_target:SetUILocation(loc)
	elseif self.m_ptype == TweenTarget.Window then
		if CEGUI.WindowManager:getSingleton():isWindowPresent(self.m_pWindowName) then
			self.m_target:setXPosition(CEGUI.UDim(0, self.m_x))
		else
			if self.m_pTweenOwner then
				TweenNano.removeTween(self.m_pTweenOwner)
			end
			print("【Red Error】:try to update position of " .. tostring(self.m_pWindowName))
		end
	else

	end
end

function TweenTarget:getX()
	return self.m_x
end

-- 设置坐标y
function TweenTarget:setY(y)
	if not self.m_target then return end
	if self.m_y == y then return end
	self.m_y = y
	if self.m_ptype == TweenTarget.Sprite then
		local loc = XiaoPang.CPOINT(self.m_x, self.m_y)
		self.m_target:SetUILocation(loc)
	elseif self.m_ptype == TweenTarget.Window then
		if CEGUI.WindowManager:getSingleton():isWindowPresent(self.m_pWindowName) then
			self.m_target:setYPosition(CEGUI.UDim(0, self.m_y))
		else
			if self.m_pTweenOwner then
				TweenNano.removeTween(self.m_pTweenOwner)
			end
			print("【Red Error】:try to update position of " .. tostring(self.m_pWindowName))
		end
	else

	end
end

function TweenTarget:getY()
	return self.m_y
end

function TweenTarget:setAlpha(alpha)
	if not self.m_target then return end
	if self.m_alpha == alpha then return end
	self.m_alpha = alpha
	if self.m_ptype == TweenTarget.Sprite then
--TODO:
	elseif self.m_ptype == TweenTarget.Window then
		if CEGUI.WindowManager:getSingleton():isWindowPresent(self.m_pWindowName) then
			self.m_target:setAlpha(self.m_alpha)
		else
			if self.m_pTweenOwner then
				TweenNano.removeTween(self.m_pTweenOwner)
			end
			print("【Red Error】:try to update alpha of " .. tostring(self.m_pWindowName))
		end
	else

	end
end

function TweenTarget:getAlpha()
	return self.m_alpha
end

function TweenTarget:setRotation(num)
--TODO:
end

function TweenTarget:getTarget()
	return self.m_target
end

function TweenTarget:getScale()
	return self.m_pScale
end

function TweenTarget:setScale(scale)
	if not self.m_target then return end
	if self.m_pScale == scale then return end
	if self.m_ptype == TweenTarget.Window then
		if CEGUI.WindowManager:getSingleton():isWindowPresent(self.m_pWindowName) then
			self.m_pScale = scale
			self.m_target:setScale(CEGUI.Vector3(scale, scale, 1))
		else
			if self.m_pTweenOwner then
				TweenNano.removeTween(self.m_pTweenOwner)
			end
			print("【Red Error】:try to update scale of " .. tostring(self.m_pWindowName))
		end
		
	end
end

function TweenTarget:getRotationY()
	if not self.m_target then return 0 end
	return self.m_target:getRotation().y
end

function TweenTarget:setRotationY(r)
	if not self.m_target then return end
	if self.m_pRotationY == r then return end
	self.m_pRotationY = r
	if self.m_ptype == TweenTarget.Window then
		if CEGUI.WindowManager:getSingleton():isWindowPresent(self.m_pWindowName) then
			self.m_target:setRotation(CEGUI.Vector3(0, r, 0))
		else
			if self.m_pTweenOwner then
				TweenNano.removeTween(self.m_pTweenOwner)
			end
		end
	end
end

function TweenTarget:SetTweenOwner(tween)
	self.m_pTweenOwner = tween
end

function TweenTarget:tostring()
	return "TweenTarget:" .. tostring(self)
end

------//////////
return TweenTarget