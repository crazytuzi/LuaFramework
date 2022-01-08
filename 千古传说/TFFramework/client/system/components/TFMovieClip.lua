--[[--
	序列帧动画控件:

	--By: yun.bo
	--2013/8/20
]]

--[[
帧动画实现死亡效果，参数
pParam = {
	rect = {
		x = 0,
		y = 0,
		width = 400,
		height = 200,
	}, -- 粒子的显示范围
	minVelX = 0, 					-- 粒子X方向最小速度
	maxVelX = 30,					-- 粒子X方向最大速度
	minVelY = 0, 					-- 粒子Y方向最小速度
	maxVelY = 20,					-- 粒子Y方向最大速度
	reverse = false，               -- 粒子在X轴反方向散开
	aX = 0,   						-- 粒子X方向加速度
	aY = 0,   						-- 粒子Y方向加速度
	crushTime = 1.0,				-- 死亡刷黑的时间
	deadTime = 1.5, 				-- 死亡总时间（包括刷黑跟打散）
	func = lua_function             -- 结束回调函数
	display = {                     -- 播放死忙效果的帧
		mov = "defualt",
		index = 0,
	}
}
]]--

local function SQDie(obj, pParam)
	local func = nil
	local render = obj:getRender()
	if not obj.pTextureBreak then
			obj.pTextureBreak = TFTextureBreak:create()
			obj:addChild(obj.pTextureBreak)
			obj.pTextureBreak:setAnchorPoint(ccp(0, 1))
			obj.pTextureBreak:setScale(obj:getScale() * 1.0 / obj:getRate())
	end
	if pParam then
		if pParam.func then
			func = pParam.func
		end
		if pParam.rect then
			local rect = CCRectMake(pParam.rect.x, pParam.rect.y, pParam.rect.width, pParam.rect.height)
			obj.pTextureBreak:setParticleRect(rect)
		end
		if pParam.minVelX then
			obj.pTextureBreak:setMinVelX(pParam.minVelX)
		end
		if pParam.maxVelX then
			obj.pTextureBreak:setMaxVelX(pParam.maxVelX)
		end
		if pParam.minVelY then
			obj.pTextureBreak:setMinVelY(pParam.minVelY)
		end
		if pParam.maxVelY then
			obj.pTextureBreak:setMaxVelY(pParam.maxVelY)
		end
		if pParam.aX then
			obj.pTextureBreak:setAccelerateX(pParam.aX)
		end
		if pParam.aY then
			obj.pTextureBreak:setAccelerateY(pParam.aY)
		end
		if pParam.crushTime then
			obj.pTextureBreak:setCrushTime(pParam.crushTime)
		end
		if pParam.deadTime then
			obj.pTextureBreak:setDeadTime(pParam.deadTime)
		end
		if pParam.reverse then
			obj.pTextureBreak:setReverseXEnabled(pParam.reverse)
		end

		if pParam.display then
			local mov = pParam.display.mov or "default"
			local  index = pParam.display.index or 0
			local display = obj:getFrameTexture(mov, index)
			if display then
				obj.pTextureBreak:setDisplayFrame(display)
			end
		else
			--todo
			obj.pTextureBreak:setDisplayFrame(render:displayFrame())
		end
	else
		obj.pTextureBreak:setDisplayFrame(render:displayFrame())
	end
	obj.pTextureBreak:setPosition(render:getPosition())
	obj.pTextureBreak:start()
	render:setVisible(false)
	obj.pTextureBreak:addMEListener(TFTEXTUREBREAK_COMPLETE, function(target)
		if not tolua.isnull(render) then render:setVisible(true) end
		if func and not tolua.isnull(obj) then
			func(obj)
		end
	end)
end
rawset(TFMovieClip, "SQDie", SQDie)

local _create = TFMovieClip.create
function TFMovieClip:create(path, ...)
	local obj
	if path then 
		local acts = ...
		if acts then 
			obj = _create(TFMovieClip, path, ...) 
		else 
			if path[{#path - 2}] == '.mc' then 
				obj = me.MCManager:addMEMovieClipWithMC(path):copy()
			else 
				obj = _create(TFMovieClip, path) 
			end
		end
	else
		obj = _create(TFMovieClip) 
	end
	if  not obj then return end
	TFUIBase:extends(obj)
	return obj
end

local function new(val, parent)
	local obj
	if val.movieClipModel and val.movieClipModel.MovieClipPath ~= '' then
		obj = TFMovieClip:create(val.movieClipModel.MovieClipPath)
	elseif val.path then
		obj = TFMovieClip:create(val.path)
	elseif val.tMovieClipProperty and val.tMovieClipProperty.szFileName ~= "" then
		obj = TFMovieClip:create(val.tMovieClipProperty.szFileName)
	end
	if parent and obj then
		parent:addChild(obj)
	end
	return obj
end

local function initControl(_, val, parent)
	local obj = new(val, parent)
	if not obj then return false end
	obj:initMEMovieClip(val, parent)
	return true, obj
end
rawset(TFMovieClip, "initControl", initControl)

return TFMovieClip