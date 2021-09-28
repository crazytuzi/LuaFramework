-- tweentype
require "utils.tween.eases.tweenback"
require "utils.tween.eases.tweenlinear"
require "utils.tween.eases.tweenbounce"
require "utils.tween.eases.tweeneases"

--
require "utils.tween.tweentarget"
require "utils.tween.tween"

require "utils.tween.delay.tweendelay"
--[[
	example:
		local tw = TweenNano.to(wnd, 2, {x = 200, ease = {type=TweenBack.type, fun = TweenBack.easeOut},
								onUpdate = MainControlDlg.HandleTweenOutUpdate, callbackTarget = MainControlDlg})
]]
--*****************************************
-- NOTICE:
-- IMPORTANT: 同一个target同一个时间段，多次添加缓动时，如果后面添加的缓动和前面添加的缓动含有相同的缓动变量（x, y, alpha），
--			  则前面添加的缓动会被顶替掉（此规则可以改变，待定）
--*****************************************
local T = {
	m_tList = {},		-- tween list
	m_tRenderList = {},	-- render list
	m_tDelayCall = {}
}

--*************************************
--添加一个 tween 渐变
--************************************
--public:
function T.to(target, duration, vars)
	if target then
		local tw =  Tween:new(target, duration, vars)
		T.addTween(tw)
		return tw
	end
	return nil
end

--public:
function T.addTween(tw)
  	-- print("addTween" ..  tw:tostring() .. ", type:" .. tw:getType())
  	local key = tostring(tw.target:getTarget())

	if T.m_tList[key] then
		for k, oldtween in pairs(T.m_tList[key]) do
			if bit.band(k, tw:getType()) ~= 0 then --attention this
				oldtween:delete()
			end
		end
		if not T.m_tList[key] then
			T.m_tList[key] = {}
		end
		T.m_tList[key][tw:getType()] = tw
	else
		T.m_tList[key] = {}
		T.m_tList[key][tw:getType()] = tw
	end
end

--public:
function T.removeTween(tw)
	if not tw then return end
  	-- print("removeTween" ..  tw:tostring() .. ", type:" .. tw:getType())
  	local key = tostring(tw.target:getTarget())

	if T.m_tList[key] and T.m_tList[key][tw:getType()] then
		T.m_tList[key][tw:getType()] = nil
	end
	if T.m_tList[key] then
		if TableUtil.tablelength(T.m_tList[key]) == 0 then
			T.m_tList[key] = nil
		end
	end
	tw = nil
end

function T.killTweenOfTarget(target)
	if not target or not target:getTarget() then return end
	local key = tostring(target:getTarget())
	if T.m_tList[key] then
		for k, t in pairs(T.m_tList[key]) do
			t:delete()
		end
	end
end

--*************************************
--	添加一个ticker
--*************************************
--public:
function T.addRender(target)
	if target then
		local key = tostring(target)
		T.m_tRenderList[key] = target
	end
end

--public:
function T.removeRender(target)
	if target then
		local key = tostring(target)
		if T.m_tRenderList[key] then
			T.m_tRenderList[key] = nil
		end
	end
end

--*********************************
-- 延迟回调
--*********************************
function T.addDelayCall(target)
	if target then
		local key = tostring(target)
		T.m_tDelayCall[key] = target
	end
end

function T.removeDelayCall(target)
	if target then
		local key = tostring(target)
		if T.m_tDelayCall[key] then
			T.m_tDelayCall[key] = nil
		end
	end
end

--------------------------------------
--dont call this function
function T.run(delta)
	for _, v in pairs(T.m_tList) do
		for _, tw in pairs(v) do
			tw:run(delta)
		end
	end

	for _, v in pairs(T.m_tRenderList) do
		v:run(delta)
	end

	for _,v in pairs(T.m_tDelayCall) do
		v:run(delta)
	end
end

function T.Destory()
  T.m_tRenderList = {}
  T.m_tList = {}
  T.m_tDelayCall = {}
end
------///////////////
TweenNano = T
return TweenNano