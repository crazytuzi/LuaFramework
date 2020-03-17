

_G.UIFalieffect = BaseUI:new("UIFalieffect")
UIFalieffect.FLUTTER_TIME  = 0.6 -- 飘时间
UIFalieffect.IsPlaying = false
function UIFalieffect:Create()
	self:AddSWF("faliEffectPanel.swf", true, "center")
end

function UIFalieffect:OnLoaded( objSwf )
	objSwf.hitTestDisable = true
	for i = 1, 10 do
		local boom = objSwf['boom'..i]
		boom.complete = function(e) self:ReturnBoom( e.target ) end
		if boom then
			self:ReturnBoom(boom)
		end
	end
end
function UIFalieffect:GetWidth()
	return 1
end

function UIFalieffect:GetHeight()
	return 1
end

function UIFalieffect:Play()

	local objSwf = self.objSwf
	if not objSwf then return end

	if not self:IsShow() then return false end
	if self.IsPlaying then return false end
	self.IsPlaying = true	
	
	local ease = Cubic.easeOut
	local p = self:GetFaliEffect()
	p.complete = function() 	
		self:Flutter() 
		self:ReturnFaliEffect(p)
	end
	p:playEffect(1)
	return true
end

local flyingNum = 0
function UIFalieffect:Flutter()
	
	for i = 1, 6 do
		local p = UIFalieffect:GetFaliqiu()
		local rotation = math.random() * math.pi * 2
		local dis = UIParticle.RADIUS + math.random() * UIParticle.SCOPE
		local tarX = math.cos( rotation ) * dis
		local tarY = math.sin( rotation ) * dis
		p._x = tarX
		p._y = tarY
		local x, y = UIFalieffect:GetTarPos()
		local onStart = function()
			p._visible = true
		end
	

		Tween:To( p, UIFalieffect.FLUTTER_TIME, { delay = i * 0.08, _y = y, _x = x, ease = Cubic.easeOut}, { onStart = onStart, onComplete = function()
			self:Boom(p)
		end} )
		flyingNum = flyingNum + 1
	end
end

function UIFalieffect:Boom(p)

	local x, y = p._x, p._y;
	local boom = UIFalieffect:GetBoom()
	if boom then
		boom._x = x;
		boom._y = y
		boom:playEffect(1)
	end
	self:ReturnFaliqiu(p)
	flyingNum = flyingNum - 1
	if flyingNum == 0 then
		--UIMainHead:PlayEffectLingli()
		self.IsPlaying = false
	end
end

UIFalieffect.boomPool = {}

function UIFalieffect:GetBoom()
	return table.remove( self.boomPool )
end

function UIFalieffect:ReturnBoom(mc)
	mc._visible = false
	if #self.boomPool < 20 then
		table.push( self.boomPool, mc )
		return
	end
	mc:removeMovieClip()
	mc = nil;
end

function UIFalieffect:GetFaliEffect()		
	local objSwf = self.objSwf
	if not objSwf then return end
	
	objSwf.mcFaliEffect.visible = true
	return objSwf.mcFaliEffect
end
function UIFalieffect:ReturnFaliEffect(mc)
	local objSwf = self.objSwf
	if not objSwf then return end

	objSwf.mcFaliEffect.visible = false
end

local count = 0
function UIFalieffect:GetMcName(prefix)
	count = count + 1
	return prefix .. count
end

--------------------------------------------------------
local faliqiuPool = {}
function UIFalieffect:GetFaliqiu()
	local mc = table.remove( faliqiuPool )
	if mc then
		-- mc._visible = true
	else
		local objSwf = self.objSwf
		if not objSwf then return end
		local depth = objSwf:getNextHighestDepth()
		mc = objSwf:attachMovie( "mcFaliqiu", self:GetMcName("faliqiu"), depth )
		mc.hitTestDisable = true
		mc._visible = false
	end
	return mc
end

function UIFalieffect:ReturnFaliqiu(mc)
	mc._visible = false
	if #faliqiuPool < 10 then
		table.push( faliqiuPool, mc )
		return
	end
	mc:removeMovieClip()
	mc = nil;
	local objSwf = self.objSwf
	if not objSwf then return end

end

local count = 0
function UIFalieffect:GetMcLingliqiuName(prefix)
	count = count + 1
	return prefix .. count
end

--------------------------------------------------------

function UIFalieffect:GetTarPos()
	local objSwf = self.objSwf
	if not objSwf then return end

	local posg = UIMainSkill:GetFaliPosG()
	if not posg then return end
	local posl = UIManager:PosGtoL( objSwf, posg.x, posg.y )
	return posl.x, posl.y
end

function UIFalieffect:ListNotificationInterests()
	return {
		NotifyConsts.PlayerAttrChange,
	}
end

--处理消息
function UIFalieffect:HandleNotification(name, body)
	if name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaMp or body.type == enAttrType.eaMaxMp then			
			self:Play()		

		end
	end
end