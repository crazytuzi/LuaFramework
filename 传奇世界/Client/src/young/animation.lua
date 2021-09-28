local Myoung = require "src/young/young"; local M = Myoung.beginModule(...)
local Mnode = require "src/young/node"
local Mmisc = require "src/young/util/misc"
---------------------------------------------------------------------------
-- 默认的动画时间
eDuration = 0.25

-- 默认缩放的最小比列
eSizeLower = 0.001
-- 默认缩放的最大比列
eSizeUpper = 1

-- 默认旋转的最小角度
eAngleLower = 0
-- 默认旋转的最大角度
eAngleUpper = 360
---------------------------------------------------------------------------
--[[ 变速动作 ]]

-- 指数缓冲
eExpoIn = 1
eExpoOut = - eExpoIn
eExpoInOut = 3

-- Sine 缓冲
eSineIn = 4
eSineOut = - eSineIn
eSineInOut = 6

-- 弹性缓冲
eElasticIn = 7
eElasticOut = - eElasticIn
eElasticInOut = 9

-- 跳跃缓冲
eBounceIn = 10
eBounceOut = - eBounceIn
eBounceInOut = 12

-- 回震缓冲
eBackIn = 13
eBackOut = - eBackIn
eBackInOut = 15

-- 进入场景
eEnterStage = 16
-- 退出场景
eExitStage = - eEnterStage

local tBuffering = {
	[eExpoIn] = cc.EaseExponentialOut,
	[eExpoOut] = cc.EaseExponentialIn,
	[eExpoInOut] = cc.EaseExponentialInOut,
	----------------------------------
	[eSineIn] = cc.EaseSineOut,
	[eSineOut] = cc.EaseSineIn,
	[eSineInOut] = cc.EaseSineInOut,
	----------------------------------
	[eElasticIn] = cc.EaseElasticOut,
	[eElasticOut] = cc.EaseElasticIn,
	[eElasticInOut] = cc.EaseElasticInOut,
	----------------------------------
	[eBounceIn] = cc.EaseBounceOut,
	[eBounceOut] = cc.EaseBounceIn,
	[eBounceInOut] = cc.EaseBounceInOut,
	----------------------------------
	[eBackIn] = cc.EaseBackOut,
	[eBackOut] = cc.EaseBackIn,
	[eBackInOut] = cc.EaseBackInOut,
	----------------------------------
	[eEnterStage] = cc.EaseExponentialOut,
	[eExitStage] = cc.EaseExponentialIn,
}
---------------------------------------------------------------------------
local swapValue = function(params, key1, key2)
	local tmp = params[key2]
	params[key2] = params[key1]
	params[key1] = tmp
end
---------------------------------------------------------------------------
-- 构建速度变化动作
buffer = function(self, params)
	
	local bufferId = params.buffer
	
	if type(bufferId) ~= "number" or not tBuffering[bufferId] then
		bufferId = Mmisc:isDefaultValue(params, "stage", "->", "<-") and self.eEnterStage or self.eExitStage
		params.buffer = bufferId
	end
	
	local reverse = tBuffering[-bufferId] and -bufferId or bufferId
	
	return tBuffering[params.reverse and reverse or bufferId]:create(params.action)
end
---------------------------------------------------------------------------
-- 构建位置(position)变化动作
MoveTo = function(self, params)

	-- 执行动作的 node
	local node = params.node
	----------------------------------------------------------
	-- 动画持续时间
	local duration = Mmisc:getValue(params, "duration", self.eDuration)
	----------------------------------------
	-- 入场 "->" | 出场 "<-"
	local enter = Mmisc:isDefaultValue(params, "stage", "->", "<-")
	----------------------------------------------------------
	-- 参考系
	local ref = Mmisc:getValue( params, "ref", enter and getRunScene() or node:getParent() )

	-- 参考系内容大小
	local refSize = ref:getContentSize()
	----------------------------------------------------------
	local reverse = params.reverse
	
	-- 起始位置, 最终位置
	if reverse then swapValue(params, "sp", "ep") end
	
	local sp = Mmisc:getValue( params, "sp", cc.p(node:getPosition()) )
	local ep = params.ep
	
	if enter then
		Mnode.setAnchorAndPosition(node, nil, sp)
		ep = ep or cc.p(refSize.width/2, refSize.height/2)
	else
		ep = ep or cc.p(0, 0)
	end
	----------------------------------------
	
	local bezier = params.bezier
	if type(bezier) == "table" and #bezier == 2 then
		if reverse then swapValue(bezier, 1, 2) end
	else
		-- 起点到终点的向量
		local vector = cc.p(ep.x - sp.x, ep.y - sp.y)
		----------------------------------------
		-- 直线 "-", 贝塞尔曲线 "~"
		local isLine = not Mmisc:isDefaultValue(params, "curve", "~", "-")
		if vector.x == 0 or vector.y == 0 or isLine then
			return cc.MoveTo:create(duration, ep)
		end
		----------------------------------------
		bezier = {}
		
		-- 水平走势 "-" |  垂直走势 "|"
		local vertical = Mmisc:isDefaultValue(params, "trend", "|", "-")
		----------------------------------------------------------
		if vertical then
			-- 结束时有垂直方向的惯性
			bezier[1] = cc.p(sp.x, sp.y + vector.y) -- 第一个控制点
			bezier[2] = cc.p(ep.x, ep.y - vector.y) -- 第二个控制点
		else
			-- 结束时有水平方向的惯性
			bezier[1] = cc.p(sp.x + vector.x, sp.y) -- 第一个控制点
			bezier[2] = cc.p(ep.x - vector.x, ep.y) -- 第二个控制点
		end
	end
	
	bezier[3] = ep -- 终点
	
	return cc.BezierTo:create(duration, bezier)
end
---------------------------------------------------------------------------
-- 构建角度(angle)变化动作
RotateTo = function(self, params)

	-- local node = params.node
	-- local stage = params.stage
	-- local duration = params.duration or self.eDuration
	
	-- local sa = params.sa
	-- if sa and node then node:setRotate(sa) end
	-- local ea = params.ea or (stage == "->" and self.eAngleUpper or self.eAngleLower)
	
	-- return cc.RotateTo:create(duration, ea)
end
---------------------------------------------------------------------------
-- 构建大小(size)变化动作
ScaleTo = function(self, params)
	
	-- 执行动作的 node
	local node = params.node
	----------------------------------------------------------
	-- 动画持续时间
	local duration = Mmisc:getValue(params, "duration", self.eDuration)
	----------------------------------------------------------
	-- 入场 "->" | 出场 "<-"
	local enter = Mmisc:isDefaultValue(params, "stage", "->", "<-")
	----------------------------------------------------------
	-- 起始大小, 最终大小
	if params.reverse then swapValue(params, "ss", "es") end
	
	local ss, es = params.ss, params.es
	
	if enter then
		ss = ss or self.eSizeLower
		params.ss = ss
		if node then node:setScale(ss) end
		es = es or self.eSizeUpper
	else
		es = es or self.eSizeLower
	end
	
	return cc.ScaleTo:create(duration, es)
end

FadeOut = function(self, params)
	
	-- 执行动作的 node
	local node = params.node
	----------------------------------------------------------
	-- 动画持续时间
	local duration = Mmisc:getValue(params, "duration", self.eDuration)
	----------------------------------------------------------
	return cc.FadeOut:create(duration)
end
---------------------------------------------------------------------------
transit = function(self, params)
	params.sp = g_scrCenter
	local move = self:MoveTo(params)
	local scale = self:ScaleTo(params)
	local fadeout = self:FadeOut(params)
	---------------------------------
	local node = params.node
	local enter = params.stage == "->"
	---------------------------------
	if not enter then
		self.eDuration = 0.3
		params.action = cc.Spawn:create(move, scale,fadeout)
	else
		self.eDuration = 0.25
		params.action = cc.Spawn:create(move, scale)
	end
	---------------------------------
	local buffer = self:buffer(params)
	params.action = nil
	---------------------------------
	local callback = params.cb
	---------------------------------
	local final = nil
	
	if not enter then
		if node.__cname then
			print("close *****  "..tostring(node.__cname))
		end
		local func = cc.CallFunc:create(function(node)
			if node then
				node:removeFromParent()
				node = nil
			end
			if callback then callback() end
		end)
		final = cc.Sequence:create(buffer, func)
		node:runAction(final)
	else
		if node.__cname then
			print("open *****  "..tostring(node.__cname))
		end
		-------------------------
		-- 手动出场?
		if not params.manual then
			node.OnExitTransition = {
				node = node,
				stage = "<-",
				reverse = true,
				duration = params.duration * 0.7,
				----------------
				sp = params.sp,
				bezier = params.bezier,
				curve = params.curve,
				trend = params.trend,
				----------------
				ss = params.ss,
				----------------
				buffer = params.buffer,
				----------------
			}
		end
		-------------------------
		final = callback and cc.Sequence:create(buffer, cc.CallFunc:create(callback)) or buffer
		node:runAction(final)
		-------------------------
		local ref = params.ref
		if ref then
			params.parent = params.ref
			params.child = params.node
			params.pos = params.sp
			-------------------------
			Mnode.addChild(params)
		end
	end
end
---------------------------------------------------------------------------

_G.Manimation = M
---------------------------------------------------------------------------