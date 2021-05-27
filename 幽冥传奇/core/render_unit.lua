
RenderUnit = RenderUnit or BaseClass()

function RenderUnit:__init()
	self.core_game_scene = nil

	self.world_size = cc.size(0, 0)
	self.world_logic_size = cc.size(0, 0)
	self.view_size = cc.size(0, 0)

	self.ui_root = nil
	self.event_layer = nil
	self.is_accelerometer_enabled = true
end

function RenderUnit:__delete()
	if nil ~= self.ui_root then
		self.ui_root:removeFromParent()
		self.ui_root = nil
	end

	if self.event_layer then
		self.event_layer:removeFromParent()
		self.event_layer = nil
	end

	self.core_game_scene = nil
end

function RenderUnit:AddUi(...)
	self.ui_root:addChild(...)
end

function RenderUnit:GetUiNode()
	return self.ui_root
end

function RenderUnit:InitAsMainStage()
	if nil ~= self.core_game_scene then
		return
	end

	Log("RenderUnit:InitAsMainStage")

	self.core_game_scene = AdapterToLua:GetGameScene()

	self.ui_root = cc.Node:create()
	self.core_game_scene:addChildToRenderGroup(self.ui_root, GRQ_UI)

	self:UpdateViewSize()

	-- 创建事件layer
	self.event_layer = cc.Layer:create()
	self.core_game_scene:addChildToRenderGroup(self.event_layer, GRQ_UI)

	local event_dispatcher = self.event_layer:getEventDispatcher()

	-- 按键事件监听
	local keyboard_listener = cc.EventListenerKeyboard:create()
	keyboard_listener:registerScriptHandler(function(key_code, event)
		GlobalEventSystem:Fire(LayerEventType.KEYBOARD_RELEASED, key_code, cc.Handler.EVENT_KEYBOARD_RELEASED)
	end, cc.Handler.EVENT_KEYBOARD_RELEASED)
	keyboard_listener:registerScriptHandler(function(key_code, event)
		GlobalEventSystem:Fire(LayerEventType.KEYBOARD_RELEASED, key_code, cc.Handler.EVENT_KEYBOARD_PRESSED)
	end, cc.Handler.EVENT_KEYBOARD_PRESSED)
	event_dispatcher:addEventListenerWithSceneGraphPriority(keyboard_listener, self.event_layer)

	-- touch事件监听
	local touch_listener = cc.EventListenerTouchOneByOne:create()
	touch_listener:setSwallowTouches(true)

	touch_listener:registerScriptHandler(function(touch, event)
		GlobalEventSystem:Fire(LayerEventType.TOUCH_BEGAN, touch, event)
		return 1
	end, cc.Handler.EVENT_TOUCH_BEGAN)

	touch_listener:registerScriptHandler(function(touch, event)
		GlobalEventSystem:Fire(LayerEventType.TOUCH_MOVED, touch, event)
	end, cc.Handler.EVENT_TOUCH_MOVED)

	touch_listener:registerScriptHandler(function(touch, event)
		GlobalEventSystem:Fire(LayerEventType.TOUCH_ENDED, touch, event)
	end, cc.Handler.EVENT_TOUCH_ENDED)

	touch_listener:registerScriptHandler(function(touch, event)
		GlobalEventSystem:Fire(LayerEventType.TOUCH_CANCELLED, touch, event)
	end, cc.Handler.EVENT_TOUCH_CANCELLED)

	event_dispatcher:addEventListenerWithFixedPriority(touch_listener, 127)

	-- 加速计事件监听
	self.event_layer:setAccelerometerInterval(0.1)
	local acce_listerner  = cc.EventListenerAcceleration:create(function(event, x, y, z, timestamp)
		GlobalEventSystem:Fire(LayerEventType.ACCELEROMETER, x, y, z)
	end)
	event_dispatcher:addEventListenerWithSceneGraphPriority(acce_listerner, self.event_layer)
	self:SetAccelerometerEnabled(false)
end

-- 加速计是否生效
function RenderUnit:SetAccelerometerEnabled(enabled)
	if self.is_accelerometer_enabled ~= enabled and nil ~= self.event_layer then
		self.is_accelerometer_enabled = enabled
		self.event_layer:setAccelerometerEnabled(enabled)
	end
end

function RenderUnit:GetCoreScene()
	return self.core_game_scene
end

function RenderUnit:UpdateWorldSize()
	self.world_size = self.core_game_scene:getWorldSize()

	self.world_logic_size.width = HandleGameMapHandler:GetGameMap():getLogicWidth()
	self.world_logic_size.height = HandleGameMapHandler:GetGameMap():getLogicHeight()
end

function RenderUnit:GetLogicWidth()
	return self.world_logic_size.width
end

function RenderUnit:GetLogicHeight()
	return self.world_logic_size.height
end

function RenderUnit:UpdateViewSize()
	self.view_size = cc.Director:getInstance():getWinSize()
	GlobalData.screen_w = self.view_size.width
	GlobalData.screen_h = self.view_size.height
end

function RenderUnit:GetWidth()
	return self.view_size.width
end

function RenderUnit:GetHeight()
	return self.view_size.height
end

function RenderUnit:GetSize()
	return self.view_size
end

-- 逻辑坐标转世界坐标（世界坐标为格子中点）
function RenderUnit:LogicToWorld(logic_pos)
	return cc.p(math.floor(logic_pos.x) * Config.SCENE_TILE_WIDTH + Config.SCENE_TILE_WIDTH / 2, 
		math.floor(logic_pos.y) * Config.SCENE_TILE_HEIGHT + Config.SCENE_TILE_HEIGHT / 2)
end

function RenderUnit:LogicToWorldXY(x, y)
	return math.floor(x) * Config.SCENE_TILE_WIDTH + Config.SCENE_TILE_WIDTH / 2, 
		math.floor(y) * Config.SCENE_TILE_HEIGHT + Config.SCENE_TILE_HEIGHT / 2
end

-- 世界坐标转逻辑坐标（逻辑坐标为整数）
function RenderUnit:WorldToLogic(wpos)
	return cc.p(math.floor(wpos.x / Config.SCENE_TILE_WIDTH), math.floor(wpos.y / Config.SCENE_TILE_HEIGHT))
end

function RenderUnit:WorldToLogicXY(x, y)
	return math.floor(x / Config.SCENE_TILE_WIDTH), math.floor(y / Config.SCENE_TILE_HEIGHT)
end

function RenderUnit:LogicToWorldEx(x, y)
	return x * Config.SCENE_TILE_WIDTH, y * Config.SCENE_TILE_HEIGHT
end

function RenderUnit:WorldToLogicEx(wx, wy)
	return wx / Config.SCENE_TILE_WIDTH, wy / Config.SCENE_TILE_HEIGHT
end

function RenderUnit:ScreenToWorld(screen_pos)
	return self.core_game_scene:screenToWorld(screen_pos)
end

function RenderUnit:WorldToScreen(world_pos)
	return self.core_game_scene:worldToScreen(world_pos)
end

-- 设置动画回调
function RenderUnit.SetAnimateCallback(frame_animate, callback_func)
	if nil ~= frame_animate and nil ~= callback_func then
		frame_animate:setEndEventFlag(true)

		ScriptHandlerMgr:getInstance():registerScriptHandler(frame_animate, function(sender)
			GlobalTimerQuest:AddDelayTimer(function() callback_func() end, 0)	-- 延迟到下一帧，防止嵌套
		end, cc.Handler.CALLFUNC)
	end
end

AnimateEventType = {
	AsyncLoadFail = -1,
	Start = 0,
	Update = 1,
	Stop = 2,
}
-- 创建动画精灵
function RenderUnit.CreateAnimSprite(anim_path, anim_name, frame_interval, loops, is_flip_x, callback_func)
	loops = loops or COMMON_CONSTS.MAX_LOOPS
	if loops >= 10 then loops = COMMON_CONSTS.MAX_LOOPS end
	frame_interval = frame_interval or FrameTime.Effect
	if nil == is_flip_x then is_flip_x = false end

	local anim_aprite = AnimateSprite:create(anim_path, anim_name, loops, frame_interval, is_flip_x)
	if nil ~= callback_func then
		anim_aprite:addEventListener(function(sender, event_type, frame)
			if event_type == AnimateEventType.Stop then
				callback_func()
			end
		end)
	end
	return anim_aprite
end

-- 创建特效
function RenderUnit.CreateEffect(effect_id, parent, zorder, frame_interval, loops, x, y)
	local anim_aprite = nil
	if nil ~= effect_id then
		loops = loops or COMMON_CONSTS.MAX_LOOPS
		if loops >= 10 then loops = COMMON_CONSTS.MAX_LOOPS end
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(effect_id)
		anim_aprite = AnimateSprite:create(anim_path, anim_name, loops, frame_interval or FrameTime.Effect, false)
	else
		anim_aprite = AnimateSprite:create()
	end

	if nil ~= parent then
		parent:addChild(anim_aprite, zorder or 100, zorder or 100)
		if nil == x or nil == y then
			local size = parent:getContentSize()
			x, y = size.width / 2, size.height / 2
		end
	end
	if nil ~= x and nil ~= y then
		anim_aprite:setPosition(x, y)
	end
	return anim_aprite
end

function RenderUnit.PlayEffectOnce(effect_id, parent, zorder, x, y, remove_on_finished, on_complete, frame_interval)
	if parent == nil then return end

	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(effect_id)
	local anim_sprite = AnimateSprite:create(anim_path, anim_name, 1, frame_interval or FrameTime.Effect, false)
	anim_sprite:setPosition(x, y)
	parent:addChild(anim_sprite, zorder or 100, zorder or 100)

	anim_sprite:addEventListener(function(sender, event_type, frame)
		if event_type == AnimateEventType.Stop then
			if remove_on_finished then
				anim_sprite:removeFromParent()
			end

			if type(on_complete) == "function" then
				on_complete()
			end
		end
	end)

	return anim_aprite
end
