    
local HeroXiaHunEndLayer = class("HeroXiaHunEndLayer", function()
    return display.newColorLayer(ccc4(0, 0, 0, 170))
end)

function HeroXiaHunEndLayer:ctor(param)
	local nextXiaHun = param.nextXiaHun
    -- local data = param.data
    -- print("kdsdf")
    -- dump(data)


    self:setTouchEnabled(true)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT,
        function(event, x, y)
            if "began" == event.name then
                -- printf("================ touch __cname = %s", self.__cname)
                nextXiaHun()
                self:removeSelf()
                return true
            end
        end, 1)
    self:setTouchSwallowEnabled(true)
end

return HeroXiaHunEndLayer