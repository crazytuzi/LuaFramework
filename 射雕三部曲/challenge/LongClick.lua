-- 实现长按事件的节点
local LongClick = class('LongClick', function ()
    return display.newNode()
end)

--[[
params --node  传入的控件
params --callBack  执行的回调
]]--
function LongClick:ctor(params)
    self.mNode = params.node
    self.mCallBack = params.callBack
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(function(touch, event)
        self.beganPoint = touch:getLocation()
        local point = params.node:convertToNodeSpace(self.beganPoint)
        local rect = cc.rect(0, 0, params.node:getContentSize().width, params.node:getContentSize().height)
        if cc.rectContainsPoint(rect,point) then
            self.moved = false
            self.ended = false
           Utility.schedule(
                params.node,
                function()
                    if not self.ended then
                        params.callBack()
                    else
                        params.node:stopAllActions()
                    end
                end,
                0.2
            )
        end
        return true
    end,cc.Handler.EVENT_TOUCH_BEGAN)

     listener:registerScriptHandler(function(touch,event)
        self.moved = true
    end,cc.Handler.EVENT_TOUCH_MOVED)

     listener:registerScriptHandler(function(touch,event)
        params.node:stopAllActions()
        self.ended = true
    end,cc.Handler.EVENT_TOUCH_ENDED)

    self.mNode:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.mNode)
    local function onNodeEvent(event)
        if event == 'exit' then
            params.node:getEventDispatcher():removeEventListener(listener)
        end
    end
    params.node:registerScriptHandler(onNodeEvent)
end



return LongClick
