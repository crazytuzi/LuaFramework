GlobalKeybordEvent = GlobalKeybordEvent or BaseClass()

-- 获取单例
function GlobalKeybordEvent:getInstance()
    if not self.is_init then 
        self.event_list = {}
        self.is_init = true
        self.keydown_list = {}
        self.keyup_list = {}

        local function onKeyPressed(keyCode, event)
            self:onKeyPressed(keyCode)
            if not self.keyCode then self.keyCode = keyCode end
            if DEBUG_MODE then
                print("按了", keyCode)
            end
        end

        local function onKeyReleased(keyCode, event)
            if DEBUG_MODE then
                print("松开", keyCode)
            end
            if self.keyCode == keyCode then self.keyCode = nil end
            self:onKeyReleased(keyCode)
        end

        local listener = cc.EventListenerKeyboard:create()
        listener:registerScriptHandler(onKeyPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
        listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED)
        
        local lay = ViewManager:getInstance():getLayerByTag(ViewMgrTag.WIN_TAG)
        local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, lay)
    end
    return self
end

-- 添加键盘监听回调
-- call_back            -- 回调函数
-- type                 -- 按键类型     
--      cc.Handler.EVENT_KEYBOARD_PRESSED     按下
--      cc.Handler.EVENT_KEYBOARD_RELEASED    弹起
-- keycode              -- 键值，参考cc.KeyCode
-- limit_time           -- 生效次数，默认生效1次,0无限次
-- with_name            -- 唯一标识，用于remove
function GlobalKeybordEvent:add(call_back, type, keycode, limit_time, with_name)
    if cc.PLATFORM_OS_WINDOWS ~= PLATFORM  and cc.PLATFORM_OS_MAC ~= PLATFORM then return end
    if nil == call_back then return end
    limit_time = limit_time or 1
    with_name = with_name or autoId()
    keycode = keycode or cc.Handler.EVENT_CONTROLLER_KEYUP
    type = type or cc.Handler.EVENT_KEYBOARD_PRESSED
    self.event_list[with_name] = {call_back=call_back, limit_time=limit_time, type=type, keycode=keycode}
    return with_name
end

-- 删除键盘监听
function GlobalKeybordEvent:remove(with_name)
    self.event_list[with_name] = nil
end

function GlobalKeybordEvent:inKeyCode(keycode)
    return self.keyCode == keycode
end

function GlobalKeybordEvent:onKeyPressed(keycode)
	if cc.PLATFORM_OS_WINDOWS ~= PLATFORM  and cc.PLATFORM_OS_MAC ~= PLATFORM then return end
    for key, event in pairs(self.event_list) do 
        if event.type == cc.Handler.EVENT_KEYBOARD_PRESSED and keycode == event.keycode then 
            event.call_back()
            if event.limit_time == 0 then
            elseif event.limit_time == 1 then 
                self.event_list[key] = nil
            elseif event.limit_time > 1 then 
                event.limit_time = event.limit_time - 1
            end
        end
    end
end

function GlobalKeybordEvent:onKeyReleased(keycode)
	if cc.PLATFORM_OS_WINDOWS ~= PLATFORM and cc.PLATFORM_OS_MAC ~= PLATFORM then return end
    for key, event in pairs(self.event_list) do 
        if event.type == cc.Handler.EVENT_KEYBOARD_RELEASED and keycode == event.keycode then 
            event.call_back()
            if event.limit_time == 0 then
            elseif event.limit_time == 1 then 
                self.event_list[key] = nil
            elseif event.limit_time > 1 then 
                event.limit_time = event.limit_time - 1
            end
        end
    end
end
