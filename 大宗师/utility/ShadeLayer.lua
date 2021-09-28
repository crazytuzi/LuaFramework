--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 14-6-18
-- Time: 下午1:44
-- To change this template use File | Settings | File Templates.
--

local ShadeLayer = class("ShadeLayer", function(color)
    return display.newColorLayer(color or ccc4(0, 0, 0, 170))
end)

function ShadeLayer:ctor(param)
    self.touchFunc = nil 
    self:setNodeEventEnabled(true)
    if param ~= nil then
        self.touchFunc = param.touchFunc
    end

    self.notice = ""

    self:setTouchEnabled(true)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT,
        function(event, x, y)
            if "began" == event.name then
                -- printf("================ touch __cname = %s", self.__cname)
                if self.touchFunc ~= nil then
                    self.touchFunc()
                end
                return true
            end
        end, 1)
    self:setTouchSwallowEnabled(true)
end

function ShadeLayer:setNotice(str)
    self.notice = str
    RegNotice(self, function()
        self:removeSelf()
        end, str)

end

function ShadeLayer:onExit()
    if self.notice ~= "" then
        UnRegNotice(self, self.notice)
    end
end

function ShadeLayer:setTouchFunc(func)
    self.touchFunc = func
end

return ShadeLayer

