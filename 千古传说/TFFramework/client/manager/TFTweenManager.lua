--[[--
	缓动引擎管理器:
	Example:
		
		local tween = {
			target = obj, -- target属性指向目标对象
			repeated = 3, -- 重复次数, 小于1则无限循环, 不设置则默认执行一次
			{ -- 这里开始是一个缓动的节, 最外层的节与节之间是先后执行的,
				 节内的属性时执行

				duration = 5, -- 缓动的时间, 每一个节必须有此属性
				--delay = 0.5, -- 此节生成的Action延迟delay秒后启动
				x = 480, 	-- x坐标
				y = 320,	-- y坐标
				px = 1, 	-- 百分比x坐标
				py = 1,		-- 百分比y坐标
				color = 0x00FF00, -- 颜色遮罩
				scale = 2,  -- x/y缩放
				width = 200,
				height = 200,
				pwidth = 1.5,
				pheight = 1.2,

				-- xBy = 480, 	-- x坐标
				-- yBy = 320,	-- y坐标
				-- pxBy = 1, 	-- 百分比x坐标
				-- pyBy = 1,		-- 百分比y坐标
				-- colorBy = 0x00FF00, -- 颜色遮罩
				-- scaleBy = 2,  -- x/y缩放
				-- widthBy = 200,
				-- heightBy = 200,
				-- pwidthBy = 1.5,
				-- pheightBy = 1.2,
				-- jumpBy = {
					-- x = 200,
					-- y = 100,
				-- }
				-- bezierBy = {
				-- 	ccp(200, 500), -- control position 1
				-- 	ccp(500, 700), -- control position 2
				-- 	ccp(1000, 700) -- end position
				-- }
				-- skewBy = 10
				-- skewXBy = 123
				-- skewYBy = 123
				
				-- Ease缓动效果:
				-- 引用类型实体:local TFEaseType = require('TFFramework.client.entity.TFEaseType')
				-- ease包含2部分:type 以及 rate, type为ease的类型, rate为强度(部分效果支持:in, out, inout, elastic)
				ease = {type=TFEaseType.EASE_ELASTIC_IN_OUT, rate=0.3},
				{ -- 这是一个嵌套的节, 属性和外部的节的属性相同,
					 嵌套的层次没有限制
					duration = 2,
					scaleX = 2, -- 只缩放x轴
					scaleY = 2, -- 只缩放y轴
					--skew = 90,  -- x/y  偏转
					--skewX = 90, -- x 偏转
					--skewY = 90, -- y 偏转
					jump = {x=750, y=320, count=4, height=100}, -- 跳跃:x,y表示目的坐标,count为跳跃次数
																   height为跳跃高度
					--alpha = 0.2, -- 透明值, 范围为 [0, 1]
				}, 
				{
					duration = 3,
					rotate = 1800, -- 对象绕注册点旋转
				},
				--onComplete = onComplete -- 当前节完成后触发的事件回调
				--onUpdate = onUpdate -- tween绑定控件的每帧的事件回调, 一个tween同时只能存在一个update
			},
			{ -- 此节实现节与节之间的延时
				duration = 0,
				delay = 3	
			},
			{ -- 此节实现节与节之间的函数调用
				duration = 0,
				onComplete = onComplete	
			},
			{
				duration = 5,
				--rotate = 1800,
				onComplete = function()  end
			},
			progress = {				-- 进度动画，用于TFImage，此动画不能与图片状态变灰，高亮共存
				to = 100,				-- 动画开始时自身显示的百分比
				from = 0,				-- 动画结束时自身显示的百分比，可选项，没有这个值时创建progressTo动画，即从0开始
				type = 0, 				-- 0：圆形，1：长方形
				midPoint = ccp(0, 0),	-- 设置动画开始的中点([0, 1], [0, 1])
				rate = ccp(0, 0),		-- 设置变化的速率，0为不变
				reverse = true,			-- 设置进度条动画是否反向进行 
			},
			effect = { -- 特效
				type = "waves3d",
				size = {5, 5},
				waves = 11,
				amplitude = 40,
			},
			effect = {
				type = "waves",
				size = {5, 5},
				waves = 11,
				amplitude = 40,
				isHorizontal = true,
				isVertical = true,
			},
			effect = {
				type = "shaky3d",
				size = {7, 5},
				range = 5,
				shakeZ = true,
			},
			effect = {
				type = "shaky3d",
				size = {7, 5},
				range = 5,
				shakeZ = false,
			},
			effect = {
				type = "flipX3d",
				reverse = true,
			},
			effect = {
				type = "flipY3d",
				reverse = true,
			},
			effect = {
				type = "lens3d",
				size = {30, 20},
				position = {650, 350},
				radius = 400,
			},
			effect = {
				type = "ripple3D",
				size = {30, 20},
				position = {650, 350},
				radius = 600,
				waves = 20,
				amplitude = 100,
			},
			effect = {
				type = "liquid",
				size = {2, 2},
				waves = 3,
				amplitude = 35,
			},
			effect = {
				type = "twirl",
				size = {5, 5},
				position = {650, 390},
				twirls = 2,
				amplitude = 3,
			},
			follow = { -- 跟随某个控件移动
				followedWidget = img1,  -- 跟随目标
				size = {2000, 700}  --  宽高限制
			},
			blink = 4,
		}
		TFDirector:fromTween(tween)

	--By: yun.bo
	--2013/7/8
]]

local pairs 				= pairs
local table 				= table
local next 					= next
local type 					= type
local tolua					= tolua

local INT_MAXVALUE 			= INT_MAXVALUE

local TFVector 				= TFVector
local TFFunction 			= TFFunction
local CCSequence 			= CCSequence
local CCSpawn 				= CCSpawn
local CCCallFuncN 			= CCCallFuncN
local CCDelayTime 			= CCDelayTime
local CCRepeat 				= CCRepeat

local TFTween 				= require('TFFramework.client.tween.TFTween')
local TFBaseManager 		= require('TFFramework.client.manager.TFBaseManager')
local tGetActionFunction	= require('TFFramework.client.manager.tween.ActionFunction')

local TFTweenManager 		= class('TFTweenManager', TFBaseManager)
local TFTweenManagerModel 	= {}

local MT = {
	__mode = 'k'
}

local tActionFunctions = {
	["Position"]	 = tGetActionFunction.getPosAction,
	["Scale"]	 = tGetActionFunction.getScaleAction,
	["Rotate"]	 = tGetActionFunction.getRotateAction,
	["Jump"]	 = tGetActionFunction.getJumpAction,
	["Progress"]	 = tGetActionFunction.getProgressAction,
	["Size"]		 = tGetActionFunction.getSizeAction,
	["Effect"]	 = tGetActionFunction.getEffectAction,
	["Alpha"]	 = tGetActionFunction.getAlphaAction,
	["Bezier"]	 = tGetActionFunction.getBezierAction,
	["Color"]	 = tGetActionFunction.getColorAction,
	["Skew"]	 = tGetActionFunction.getSkewAction,
	["Blink"]		 = tGetActionFunction.getBlinkAction
}

function TFTweenManager:reset()
	TFTweenManagerModel.nCount 		= 0xFF
	TFTweenManagerModel.tweens 		= setmetatable({}, MT)
end

function TFTweenManager:ctor()
	TFTweenManagerModel.nCount 		= 0xFF
	TFTweenManagerModel.tweens 		= setmetatable({}, MT)
end

function TFTweenManager:getCount()
	TFTweenManagerModel.nCount = TFTweenManagerModel.nCount + 1
	return TFTweenManagerModel.nCount
end

function TFTweenManager:getTweenTag(tween)
	local nTag = TFTweenManagerModel.tweens[tween] or -1
	return nTag
end

function TFTweenManager:createTween(args)
	local tween = args
	if not tween.target then return end
	TFTweenManagerModel.tweens[tween] = self:getCount()
	return tween
end

local function generateAction(target, tween)
	local nDuration = tween.duration
	if not nDuration then return nil end
	local carr = TFVector:create()
	local seqArr = TFVector:create()
	local act

	for i, v in pairs(tActionFunctions) do
		local actions = TFFunction.call(v, nil, target, tween)
		if next(actions) then
			for j, k in pairs(actions) do
				carr:addObject(k)
			end
		end
	end

	-- Nested Actions
	for k, v in pairs(tween) do
		if type(v) == 'table' and v.duration then
			local innerTarget = v.target or target
			act = generateAction(innerTarget, v)
			if innerTarget ~= target then 
				act = CCTargetedAction:create(innerTarget, act)
			end
			carr:addObject(act)
		end
	end

	if carr:count() > 0 then
		carr = CCSpawn:create(carr)
	end

	if tween.repeated then
		if type(tween.repeated) ~= 'number' then tween.repeated = 1 end
		local nRepeatCount = tween.repeated
		if tween.repeated < 1 then
			nRepeatCount = INT_MAXVALUE
		end
		carr = CCRepeat:create(carr, nRepeatCount)
	end

	-- Delay
	if tween.delay then
		act = CCDelayTime:create(tween.delay)
		seqArr:addObject(act)
	end
	
	if (carr.count and carr:count() > 0) or not carr.count then
		if tween.reverse then
			carr = carr:reverse()
		end
		seqArr:addObject(carr)
	end

	-- onComplete
	if tween.onComplete and type(tween.onComplete) == 'function' then
		act = CCCallFuncN:create(function () 
			tween.onComplete(target)
		end)
		seqArr:addObject(act)
	end

	-- onUpdate
	if tween.onUpdate and type(tween.onUpdate) == 'function' then
		target:addMEListener(TFWIDGET_ENTERFRAME, function(self, nDt)
			if tween and tween.onUpdate then 
				tween.onUpdate(target, nDt)
			else
				target:removeMEListener(TFWIDGET_ENTERFRAME)
			end
		end)

		act = CCCallFuncN:create(function()  
			target:removeMEListener(TFWIDGET_ENTERFRAME)
		end)
		seqArr:addObject(act)
	end

	local seq = CCSequence:create(seqArr)
	return seq
end

--[[--
	Create
]]
function TFTweenManager:createAction(tween, bIsByAction)
	if not tween then return end

	if not TFTweenManagerModel.tweens[tween] then
		self:createTween(tween)
	end

	if tween.follow then -- this action can only be used alone
		local follow = tween.follow
		local act = TFFollow:create(follow.followedWidget, CCRectMake(follow.rect[1], follow.rect[2], follow.rect[3], follow.rect[4]))
		if follow.update then
			act:addMEListener(TFWIDGET_ENTERFRAME,follow.update)
		end
		return act
	end

	local seq	local tActions = {}
	for k, v in pairs(tween) do
		if type(v) == 'table' and v.duration then
			local innerTarget = v.target or tween.target
			local objAction = generateAction(innerTarget, v)
			if innerTarget ~= tween.target then 
				objAction = CCTargetedAction:create(innerTarget, objAction)
			end
			tActions[#tActions + 1] = objAction
		end
	end
	local seqArr = TFVector:create()
	for nIdx = 1, #tActions do
		seqArr:addObject(tActions[nIdx])
	end
	seq = CCSequence:create(seqArr)

	--repeated
	if tween.repeated then
		if type(tween.repeated) ~= 'number' then tween.repeated = 1 end
		local nRepeatCount = tween.repeated
		if tween.repeated < 1 then
			nRepeatCount = INT_MAXVALUE
		end
		seq = CCRepeat:create(seq, nRepeatCount)
	end

	--onComplete
	if tween.onComplete and type(tween.onComplete) == 'function' then
		act = CCCallFuncN:create(tween.onComplete)
		seqArr = TFVector:create()
		seqArr:addObject(seq)
		seqArr:addObject(act)
		seq = CCSequence:create(seqArr)
	end

	if tween.speed then -- this action can only be used at top
		seq = CCSpeed:create(seq, tween.speed)
		return seq
	end

	local nTag = TFTweenManagerModel.tweens[tween] or self:getCount()
	seq:setTag(nTag)
	tween.action = seq
	return seq
end

--[[--
	To
]]
function TFTweenManager:to(tween)
	local seq = TFTweenManager:createAction(tween)
	if tween.target and seq then
		tween.target:runAction(seq)
	end
	return seq
end

--[[--
	By
]]
-- function TFTweenManager:By(tween)
-- 	local seq = TFTweenManager:createAction(tween, true)
-- 	if tween.target and seq then
-- 		tween.target:runAction(seq)
-- 	end
-- 	return seq
-- end

--[[--
	Run
]]
function TFTweenManager:run(tween)
	if tween.target and tween.action then
		tween.target:runAction(tween.action)
	end
end

local function reverseTween(tween, target)
	local ta, tb
	for k, v in pairs(tween) do
		if type(v) == 'table' and v.duration then
			for _, vv in pairs(v) do
				if type(vv) == 'table' then
					reverseTween(vv, target)
				end
			end
			
			local pos = target:getPosition()
			if v.x then 
				ta = pos.x
				target:setPosition(ccp(v.x, pos.y)) 
				v.x = ta
			else
				v.x = pos.x
			end
			if v.y then 
				ta = pos.y
				target:setPosition(ccp(pos.x, v.y)) 
				v.y = ta
			else
				v.y = pos.y
			end
			if v.scale then 
				ta = target:getScale()
				target:setScale(v.scale) 
				v.scale = ta
			end
			if v.scaleX then 
				ta = target:getScaleX()
				target:setScaleX(v.scaleX) 
				v.scaleX = ta
			end
			if v.scaleY then 
				ta = target:getScaleY()
				target:setScaleY(v.scaleY) 
				v.scaleY = ta
			end
			if v.jump then 
				ta = ccp(target:getPosition())
				tb = ccp(v.jump.x, v.jump.y)
				target:setPosition(tb)
				v.jump.x, v.jump.y = ta.x, ta.y
			end
			if v.alpha then 
				ta = target:getOpacity()
				target:setOpacity(v.alpha)
				v.alpha = ta
			end
			if v.color then 
				ta = target:getColor()
				local R, G, B, color = 0, 0, 0, v.color
				R = bit_and(color, 0x00FF0000)
				R = bit_rshift(R, 16)
				G = bit_and(color, 0x0000FF00)
				G = bit_rshift(G, 8)
				B = bit_and(color, 0x000000FF)
				target:setColor(ccc3(R, G, B))
				R, G, B = ta.r, ta.g, ta.b
				R = bit_lshift(R, 16)
				G = bit_lshift(G, 8)
				v.color = R + G + B
			end
			-- by action
			if v.xBy then 
				v.xBy = v.xBy * -1
			end
			if v.yBy then 
				v.yBy = v.yBy * -1
			end
			if v.scaleBy then 
				v.scaleBy = v.scaleBy * -1
			end
			if v.scaleXBy then 
				v.scaleXBy = v.scaleXBy * -1
			end
			if v.scaleYBy then 
				v.scaleYBy = v.scaleYBy * -1
			end
			if v.jumpBy then 
				v.jumpBy.x, v.jumpBy.y = v.jumpBy.x * -1, v.jumpBy.y * -1
			end
			-- if v.alpha then 
			-- 	ta = target:getOpacity()
			-- 	target:setOpacity(v.alpha)
			-- 	v.alpha = ta
			-- end
			if v.colorBy then 
				v.colorBy = v.colorBy * -1
			end
		end
	end
end

--[[--
	From
]]
function TFTweenManager:from(tween)
	local tw = clone(tween)
	reverseTween(tw, tw.target)
	self:to(tw)
end

--[[--
	 删除指定的缓动
]]
function TFTweenManager:kill(tween)
	if tween and tween.target then 
		if not tolua.isnull(tween.action) and not tolua.isnull(tween.target) then
			tween.target:stopAction(tween.action)
		end
		TFTweenManagerModel.tweens[tween] = nil
	end
end

--[[--
	 删除指定对象的所有缓动效果, 如果未指定对象, 则删除所有缓动
]]
function TFTweenManager:killAll(target)
	for tween, _ in pairs(TFTweenManagerModel.tweens) do
		if tween and tween.target == target then
			self:kill(tween)
		end
	end
	if not tolua.isnull(target) then target:stopAllActions() end
end

--[[--
	清除指定对象的所有缓动效果, 如果未指定对象, 则清除所有缓动
]]
function TFTweenManager:clearAll(target)
	for tween, _ in pairs(TFTweenManagerModel.tweens) do
		if tween and tween.target == target then
			TFTweenManagerModel.tweens[tween] = nil
		end
	end
end

return TFTweenManager:new()