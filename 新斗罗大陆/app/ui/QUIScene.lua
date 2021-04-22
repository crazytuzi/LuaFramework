
local QUIScene = class("QUIScene", function()
    return display.newScene("UIScene")
end)

function QUIScene:onEnter()
    if device.platform == "android" then
        if not self._layer then
            local layer = CCLayer:create()
            self:addChild(layer)
            layer:setKeypadEnabled(true)
            layer:addKeypadEventListener(function(event)
                if event == "back" then 
                	app:onClickBackButton()
                end
            end)
            self._layer = layer
        end
    end
end

function QUIScene:onExit()
    if device.platform == "android" then
        -- self._layer = nil
    end
end

function QUIScene:hibernate(...)
    if CCNode.hibernate then
        CCNode.hibernate(self, ...)
    end
end

function QUIScene:wakeup(...)
    if CCNode.wakeup then
        CCNode.wakeup(self, ...)
    end
end

return QUIScene

