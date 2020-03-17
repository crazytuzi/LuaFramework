

_G.UILingliEffect = BaseUI:new("UILingliEffect")
UILingliEffect.FLUTTER_TIME  = 0.6 -- 飘时间
UILingliEffect.IsPlaying = false
function UILingliEffect:Create()
	self:AddSWF("lingliEffectPanel.swf", true, "center")
end

function UILingliEffect:OnLoaded( objSwf )
	objSwf.hitTestDisable = true
	for i = 1, 10 do
		local boom = objSwf['boom'..i]
		boom.complete = function(e) self:ReturnBoom( e.target ) end
		if boom then
			self:ReturnBoom(boom)
		end
	end
end

function UILingliEffect:GetWidth()
	return 1
end

function UILingliEffect:GetHeight()
	return 1
end

function UILingliEffect:Play()
	if not self:IsShow() then return false end
	if self.IsPlaying then return false end
	self.IsPlaying = true	
	
	local ease = Cubic.easeOut
	local p = self:GetLingliEffect()
	p.complete = function() 	
		self:Flutter() 
		self:ReturnLingliEffect(p)
	end
	p:playEffect(1)
	return true
end

local flyingNum = 0
function UILingliEffect:Flutter()
	for i = 1, 6 do
		local p = UILingliEffect:GetLingliqiu()
		local rotation = math.random() * math.pi * 2
		local dis = UIParticle.RADIUS + math.random() * UIParticle.SCOPE
		local tarX = math.cos( rotation ) * dis
		local tarY = math.sin( rotation ) * dis
		p._x = tarX
		p._y = tarY
		local x, y = UILingliEffect:GetTarPos()
		local onStart = function()
			p._visible = true
		end
		Tween:To( p, UILingliEffect.FLUTTER_TIME, { delay = i * 0.08, _y = y, _x = x, ease = Cubic.easeOut}, { onStart = onStart, onComplete = function()
			self:Boom(p)
		end} )
		flyingNum = flyingNum + 1
	end
end

function UILingliEffect:Boom(p)
	local x, y = p._x, p._y
	local boom = UILingliEffect:GetBoom()
	if boom then
		boom._x = x
		boom._y = y
		boom:playEffect(1)
	end
	self:ReturnLingliqiu(p)
	flyingNum = flyingNum - 1
	if flyingNum == 0 then
		UIMainHead:PlayEffectLingli()
		self.IsPlaying = false
	end
end

UILingliEffect.boomPool = {}

function UILingliEffect:GetBoom()
	return table.remove( self.boomPool )
end

function UILingliEffect:ReturnBoom(mc)
	mc._visible = false
	if #self.boomPool < 20 then
		table.push( self.boomPool, mc )
		return
	end
	mc:removeMovieClip()
	mc = nil;
end
---------------------------------------------------------------------------------------------------------------
local lingliMcPool = {}
function UILingliEffect:GetLingliEffect()		
	local objSwf = self.objSwf
	if not objSwf then return end
	-- local depth = objSwf:getNextHighestDepth()
	-- local mc = table.remove( lingliMcPool ) or objSwf:attachMovie( "McLingliEffect",
		-- self:GetMcName("McLingliEffect"), depth )
	-- mc.hitTestDisable = true
	
	objSwf.mcLingliEffect.visible = true
	return objSwf.mcLingliEffect
end

function UILingliEffect:ReturnLingliEffect(mc)
	local objSwf = self.objSwf
	if not objSwf then return end
	-- if #lingliMcPool < 10 then
		-- table.push( lingliMcPool, mc )
		-- return
	-- end
	-- mc:removeMovieClip()
	objSwf.mcLingliEffect.visible = false
end

local count = 0
function UILingliEffect:GetMcName(prefix)
	count = count + 1
	return prefix .. count
end

--------------------------------------------------------
local lingliqiuPool = {}
function UILingliEffect:GetLingliqiu()
	local mc = table.remove( lingliqiuPool )
	if mc then
		-- mc._visible = true
	else
		local objSwf = self.objSwf
		if not objSwf then return end
		local depth = objSwf:getNextHighestDepth()
		mc = objSwf:attachMovie( "McLingliqiu", self:GetMcName("lingliqiu"), depth )
		mc.hitTestDisable = true
		mc._visible = false
	end
	return mc
end

function UILingliEffect:ReturnLingliqiu(mc)
	mc._visible = false
	if #lingliqiuPool < 10 then
		table.push( lingliqiuPool, mc )
		return
	end
	mc:removeMovieClip()
	mc = nil;
	local objSwf = self.objSwf
	if not objSwf then return end
	-- objSwf.mcLingliEffect.hitTestDisable = true
	-- objSwf.mcLingliqiu._visible = false
end

local count = 0
function UILingliEffect:GetMcLingliqiuName(prefix)
	count = count + 1
	return prefix .. count
end

--------------------------------------------------------

function UILingliEffect:GetTarPos()
	local objSwf = self.objSwf
	if not objSwf then return end
	local posg = UIMainHead:GetLingliPosG()
	if not posg then return end
	local posl = UIManager:PosGtoL( objSwf, posg.x, posg.y )
	return posl.x, posl.y
end

function UILingliEffect:ListNotificationInterests()
	-- return {
		-- NotifyConsts.PlayerAttrChange,
	-- }
end

--处理消息
function UILingliEffect:HandleNotification(name, body)
	-- if name == NotifyConsts.PlayerAttrChange then
		-- if body.type == enAttrType.eaExp then
			-- local expAdd = body.val - body.oldVal			
			-- self:Play()			
		-- end
	-- end
end