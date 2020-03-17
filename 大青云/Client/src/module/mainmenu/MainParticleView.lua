--[[
飘粒子(经验etc)
2015年8月6日11:03:40
haohu
]]
--------------------------------------------------------------

_G.UIParticle = BaseUI:new("UIParticle")

UIParticle.flyingNum = 0
UIParticle.particlePool = {}

UIParticle.DISPERSE_TIME = 0.5 -- 四散时间
UIParticle.FLUTTER_TIME  = 1 -- 飘时间
UIParticle.DELAY         = 0.03 -- 间隔
UIParticle.RADIUS        = 50  -- 四散最小半径
UIParticle.SCOPE         = 20  -- 四散最大、最小半径之差

function UIParticle:Create()
	self:AddSWF("mainParticle.swf", true, "center")
end

function UIParticle:OnLoaded( objSwf )
	for i = 1, 20 do
		local boom = objSwf['boom'..i]
		boom.complete = function(e) self:ReturnBoom( e.target ) end
		if boom then
			self:ReturnBoom(boom)
		end
	end
end

function UIParticle:GetWidth()
	return 1
end

function UIParticle:GetHeight()
	return 1
end

function UIParticle:Play(num, ease)
	-- if num < 3 then return end
	if self.flyingNum > 0 then return end
	if not ease then
		ease = Cubic.easeOut
	end

	for i = 1, num do
		local p = self:GetParticle()
		local rotation = math.random() * math.pi * 2
		local dis = UIParticle.RADIUS + math.random() * UIParticle.SCOPE
		local tarX = math.cos( rotation ) * dis
		local tarY = math.sin( rotation ) * dis
		self.Disperse( p, tarX, tarY, i * UIParticle.DELAY, ease )
		self.flyingNum = self.flyingNum + 1
	end
end

function UIParticle.Disperse( p, tarX, tarY, delay, ease )
	Tween:To( p, UIParticle.DISPERSE_TIME, { _alpha = 100, _y = tarY, _x = tarX, ease = ease, delay = delay }, { onComplete = function()
		UIParticle.Flutter( p, delay )
	end} )
end

function UIParticle.Flutter( p, delay, callBack )
	local x, y = UIParticle:GetTarPos()
	Tween:To( p, UIParticle.FLUTTER_TIME, { _y = y, _x = x, ease = Cubic.easeOut, delay = delay }, { onComplete = function()
		UIParticle.Boom( p )
	end} )
end

function UIParticle.Boom(p)
	local x, y = p._x, p._y
	UIParticle:ReturnParticle( p )
	local boom = UIParticle:GetBoom()
	if boom then
		boom._x = x
		boom._y = y
		boom:playEffect(1)
	end
	UIParticle.flyingNum = UIParticle.flyingNum - 1
end

UIParticle.boomPool = {}

function UIParticle:GetBoom()
	return table.remove( self.boomPool )
end

function UIParticle:ReturnBoom(mc)
	mc._visible = false
	if #self.boomPool < 20 then
		table.push( self.boomPool, mc )
		return
	end
	mc:removeMovieClip()
end

---------------------------------------------------------------------------------------------------------------

function UIParticle:GetParticle()
	local mc = table.remove( self.particlePool )
	if mc then
		mc._visible = true
	else
		local objSwf = self.objSwf
		if not objSwf then return end
		local depth = objSwf:getNextHighestDepth()
		mc = objSwf:attachMovie( "ExpParticle", self:GetMcName("ExpParticle"), depth )
		mc.hitTestDisable = true
	end
	mc._alpha = 0
	return mc
end

local count = 0
function UIParticle:GetMcName(prefix)
	count = count + 1
	return prefix .. count
end

function UIParticle:ReturnParticle(particle)
	particle._x       = 0
	particle._y       = 0
	particle._visible = false
	if #self.particlePool < 20 then
		table.push( self.particlePool, particle )
		return
	end
	particle:removeMovieClip()
end

function UIParticle:GetTarPos()
	local objSwf = self.objSwf
	if not objSwf then return end
	local posg = UIMainSkill:GetExpPosG()
	if not posg then return end
	local posl = UIManager:PosGtoL( objSwf, posg.x, posg.y )
	return posl.x, posl.y
end

--[[
function UIParticle:GetParticleNumByExp(exp)
	local level = MainPlayerModel.humanDetailInfo.eaLevel
	local lvlCfg = _G.t_lvup[level]
	if not lvlCfg then return 0 end
	local expPerParticle = lvlCfg.exp * lvlCfg.expParticle
	return exp / expPerParticle
end
]]

function UIParticle:CheckPlayParticle(exp)
	local level = MainPlayerModel.humanDetailInfo.eaLevel
	local lvlCfg = _G.t_lvup[level]
	if not lvlCfg then return false end
	local expPerParticle = lvlCfg.exp * lvlCfg.expParticle
	return exp>=expPerParticle;
end

function UIParticle:ListNotificationInterests()
	return {
		NotifyConsts.PlayerAttrChange,
	}
end

--处理消息
function UIParticle:HandleNotification(name, body)
	if name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaExp then
			local expAdd = body.val - body.oldVal
			--[[
			local num = self:GetParticleNumByExp( expAdd )
			self:Play( num )
			]]
			if self:CheckPlayParticle(expAdd) then
				self:Play(8)
			end
		end
	end
end