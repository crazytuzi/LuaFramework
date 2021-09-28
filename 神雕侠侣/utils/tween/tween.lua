--********************************************
-- how to use:
--      Cretae:
--        local tw = TweenNano.to(...)
--      Dispose:
--        tw:delete()
--      Name:
--        tw:tostring()
--      
--      that's all
--*********************************************
require "utils.tween.core.proptween"
require "utils.tween.plugin.bezierplugin"
require "utils.tween.plugin.bezierthroughplugin"
require "utils.tween.plugin.physics2dplugin"

Tween = {}

--////
Tween.easetypes = {}
Tween.easetypes[Linear.type] = Linear
Tween.easetypes[TweenBack.type] = TweenBack
Tween.easetypes[TweenBounce.type] = TweenBounce
Tween.easetypes[TweenQuart.type] = TweenQuart
Tween.easetypes[TweenQuint.type] = TweenQuint
Tween.easetypes[TweenSine.type] = TweenSine
Tween.easetypes[TweenExpo.type] = TweenExpo
Tween.easetypes[TweenCirc.type] = TweenCirc
Tween.easetypes[TweenElastic.type] = TweenElastic
----------------------------------------
Tween.plugintypes = {}
Tween.plugintypes[BezierPlugin.type] = BezierPlugin
Tween.plugintypes[BezierThroughPlugin.type] = BezierThroughPlugin
Tween.plugintypes[Physics2dPlugin.type] = Physics2dPlugin
----------------------------------------
Tween.__index = Tween

local tweenindex = 1
function Tween:new(target, duration, vars)
	local self = {}
	setmetatable(self, Tween)
	self:init(target, duration, vars)
	target:SetTweenOwner(self)
	return self
end

function Tween:init(target, duration, vars)
	tweenindex = tweenindex + 1
	self.m_pName = "tween  " .. tweenindex
	self.target = target
	self.m_duration = duration * 1000
	self.m_vars = vars
	if self.m_vars.delay then
		self.m_vars.delay = self.m_vars.delay * 1000
	end
	self.m_count = 0
	self.m_bStart = false
	self.cachedTime = 0
	if self.m_vars then
		self:makeType()

		if self.m_vars.plugin then
			local plugin = Tween.plugintypes[self.m_vars.plugin]:new()
			plugin:initTween(self.target, self.m_vars["value"], self)
			self.m_pPropTween = PropTween:new(plugin, "changeFactor", 0, 1, "_MULTOPLE_", true)
		end
	end
end

-- IMPORTANT:
function Tween:makeType()
	self.m_type = 0
	if self.m_vars.x then
		self.m_type = bit.bor(self.m_type, 1)
	end
	if self.m_vars.y then
		local t = bit.blshift(1, 2)
		self.m_type = bit.bor(self.m_type, t)
	end
	if self.m_vars.alpha then
		local t = bit.blshift(1, 3)
		self.m_type = bit.bor(self.m_type, t)
	end
	if self.m_vars.plugin then  --FIXME:
		local t = bit.blshift(1, 4)
		self.m_type = bit.bor(self.m_type, t)
	end
	if self.m_vars.scale then
		local t = bit.blshift(1, 5)
		self.m_type = bit.bor(self.m_type, t)
	end
	if self.m_vars.rotationy then
		local t = bit.blshift(1, 6)
		self.m_type = bit.bor(self.m_type, t)
	end
end

function Tween:run(delta)
	if not self.target then
		return 
	end
	self.cachedTime = self.cachedTime + delta
	-------------------tween start----------------------
	local vars = self.m_vars
	if not self.m_bStart then
		self.m_bStart = true
		-- call onstart function 
		if vars.onStart and vars.callbackTarget then
			local target = vars.callbackTarget
			local func = vars.onStart
			local params = vars.onStartParams
			func(target, params)
		end
	end

	--------------------tween delay--------------------
	if vars.delay then
		if vars.delay > 0 then
			vars.delay = vars.delay - delta
			return
		end
	end
	-------------------tween properties-----------------
	self.m_count = self.m_count + delta
	-- functions
	local ratio = 1
	------///////////////////////////////////////////////
	local tweentype = Tween.easetypes[vars.ease.type]
	if not tweentype then
		tweentype = Linear
	end
	if not vars.ease.fun then
		vars.ease.fun = 1
	end
	local tweenmetond = tweentype[vars.ease.fun] 
	if tweenmetond then
		if self.m_count > self.m_duration then
			ratio = tweenmetond(self.m_duration, 0, 1, self.m_duration)
		else
			ratio = tweenmetond(self.m_count, 0, 1, self.m_duration)
		end
	end

	--properties
	if vars.x then
		if not vars.oldx then 
			vars.oldx = self.target:getX()
			vars.deltax = vars.oldx  - vars.x
		end
		self.target:setX(vars.oldx - ratio * vars.deltax)
	end

	if vars.y then
		if not vars.oldy then 
			vars.oldy = self.target:getY()
			vars.deltay = vars.oldy  - vars.y
		end
		self.target:setY(vars.oldy - ratio * vars.deltay)
	end

	if vars.alpha then
		if not vars.oldalpha then
			vars.oldalpha = self.target:getAlpha()
			vars.deltaAlpha = vars.oldalpha - vars.alpha
		end
		self.target:setAlpha(vars.oldalpha - ratio * vars.deltaAlpha)
	end

	if vars.scale then
		if not vars.oldscale then
			vars.oldscale = self.target:getScale()
			vars.deltaScale = vars.oldscale - vars.scale
		end
		self.target:setScale(vars.oldscale - ratio * vars.deltaScale)
	end

	if vars.rotationy then
		if not vars.oldrotationy then
			vars.oldrotationy = self.target:getRotationY()
			vars.deltaRotationy = vars.oldrotationy - vars.rotationy
		end
		self.target:setRotationY(vars.oldrotationy - ratio * vars.deltaRotationy)
	end

	if self.m_pPropTween then
		self.m_pPropTween.target:SetChangeFactor(self.m_pPropTween.start + ratio * self.m_pPropTween.change)
	end
	--call update function
	if vars.onUpdate and vars.callbackTarget then
		local target = vars.callbackTarget
		local func = vars.onUpdate
		local params = vars.onUpdateParams
		func(target, params)
	end

	-------------------tween end---------------------
	if self.m_count > self.m_duration then
		-- 数据强制校正
		if vars.x then
			self.target:setX(vars.x)
		end
		if vars.y then
			self.target:setY(vars.y)
		end

		if vars.alpha then
			self.target:setAlpha(vars.alpha)
		end

		self:delete()
		-- call on complete function 
		if vars.onComplete and vars.callbackTarget then
			local target = vars.callbackTarget
			local func = vars.onComplete
			local params = vars.onCompleteParams
			func(target, params)
		end
	end
end

function Tween:tostring()
	return self.m_pName
end

function Tween:delete()
	TweenNano.removeTween(self)
end

function Tween:getType()
	return self.m_type
end