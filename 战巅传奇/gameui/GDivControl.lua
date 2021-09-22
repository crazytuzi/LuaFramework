--触摸层，手势操作
GDivControl = {}
local var  = {}

local function getTouchInfo(touchId)
	for i,v in ipairs(var.multiTouches) do
		if v.id == touchId then
			return v
		end
	end
end

-- 内滑动
local function onSlideIn()
	local tid, ts = GameSocket:checkTaskState(1000)
	if tid >= 10055 then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SWITCH_UI_MODE, mode = GameConst.UI_COMPLETE})
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_REMOVE_GESTURE_GUIDE, slideGuide = "slideIn"})
	end
end

--外滑动
local function onSildeOut()
	local tid, ts = GameSocket:checkTaskState(1000)
	if tid >= 10055 then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SWITCH_UI_MODE, mode = GameConst.UI_SIMPLIFIED})
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_REMOVE_GESTURE_GUIDE, slideGuide = "slideOut"})
	end
end

-- local touchId
local function onTouchesBegan(touches, event)
	-- print("////////////////onTouchesBegan////////////////", #touches)
	if not touches[1] then return end
	if #var.multiTouches == 0 then var.slideType = nil end
	local touchId = touches[1]:getId()
	for i,v in ipairs(var.multiTouches) do
		if v.id == touchId then
			return
		end
	end
	if table.nums(var.multiTouches) >= 2 then return end
	table.insert(var.multiTouches, {id=touchId, location=touches[1]:getLocation()})
	if #var.multiTouches == 2 then
		-- print(GameUtilSenior.encode(var.multiTouches))
		var.touchesSpace = math.abs(var.multiTouches[1].location.x - var.multiTouches[2].location.x)
	end
end

local function onTouchesMoved(touches, event)
	-- print("////////////////onTouchesMoved////////////////", #touches)
	local touchId, touchInfo
	local posX1,posX2
	if #var.multiTouches < 2 then return end
	for i,v in ipairs(touches) do
		touchId = v:getId()
		touchInfo = getTouchInfo(touchId)
		if touchInfo then
			if not posX1 then
				posX1 = v:getLocation().x
			elseif not posX2 then
				posX2 = v:getLocation().x
			end
		end
	end
	if posX1 and posX2 then
		local space = math.abs(posX1 - posX2)
		if space > var.touchesSpace + 50 then
			--外滑
			var.slideType = "slideOut"
			-- onSildeOut()
			-- print("////////////////onTouchesMoved////////////////111111111", space)
		elseif space < var.touchesSpace - 50 then
			--内滑
			-- onSlideIn()
			var.slideType = "slideIn"
			-- print("////////////////onTouchesMoved////////////////222222222", space)
		end
	end
end

local function onTouchesEnded(touches, event)
	if not touches[1] then return end
	local touchId = touches[1]:getId()
	for i,v in ipairs(var.multiTouches) do
		if v.id == touchId then
			table.remove(var.multiTouches, i)
			break
		end
	end
	-- print("////////////////onTouchesEnded////////////////", #touches, GameUtilSenior.encode(var.multiTouches))
	-- GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SCREEN_TOUCHED})
	-- GameSocket:dispatchEvent({name = GameMessageCode.EVENT_REMOVE_GESTURE_GUIDE})
	if #var.multiTouches == 0 then
		if var.slideType == "slideIn" then
			onSlideIn()
		elseif var.slideType == "slideOut" then
			onSildeOut()
		end
		var.slideType = nil
	end
end

local function initSingleTouch( ... )
	local function onTouchBegan(touch,event)
		-- print("GDivControl onTouchBegan")
		return true
	end

	local function onTouchMoved(touch, event)
		-- print("GDivControl onTouchMoved")
	end

	local function onTouchEnded(touch, event)
		-- print("GDivControl onTouchEnded")
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SCREEN_TOUCHED})
	end

	local layer = cc.Layer:create()

	layer:setTouchEnabled(true)
	local _touchListener = cc.EventListenerTouchOneByOne:create()
	_touchListener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	_touchListener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
	_touchListener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
	_touchListener:setSwallowTouches(false)
	local eventDispatcher = layer:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(_touchListener, layer)

	var.layerTouch:addChild(layer)
end

function GDivControl.init()
	var = {
		layerTouch,
		touchesSpace = 0,
		multiTouches = {}, -- 多点触摸
		slideType = nil,
	}
	var.layerTouch = cc.Layer:create()
	local listener = cc.EventListenerTouchAllAtOnce:create()    
    listener:registerScriptHandler(onTouchesBegan, cc.Handler.EVENT_TOUCHES_BEGAN )
    listener:registerScriptHandler(onTouchesMoved, cc.Handler.EVENT_TOUCHES_MOVED )
    listener:registerScriptHandler(onTouchesEnded, cc.Handler.EVENT_TOUCHES_ENDED )

    local eventDispatcher = var.layerTouch:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, var.layerTouch)

    initSingleTouch()

	return var.layerTouch
end

return GDivControl