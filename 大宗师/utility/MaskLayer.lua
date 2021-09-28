--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 14-6-18
-- Time: 下午1:44
-- To change this template use File | Settings | File Templates.
--

local MaskLayer = class("MaskLayer", function(param)
    local color = param.color
    return display.newColorLayer(color or ccc4(0, 0, 0, 170))
end)

local ii = 0

function MaskLayer:ctor(param)
    self.touchFunc = nil 
    self:setNodeEventEnabled(true)
    if param ~= nil then
        self.touchFunc = param.touchFunc
    end

    self.removeTime = param.removeTime 

    self.notice = param.notice

    self.isReg = false
    if self.notice ~= nil and self.notice ~= "" then
        if self.isReg == false then
            self.isReg = true
             RegNotice(self, function()
                    self:removeSelf()
                    end, self.notice)
        end
    end

    if self.removeTime ~= nil then
        ResMgr.delayFunc(self.removeTime,function()
            self:removeSelf()
            end, self)
    end

    self:setTouchEnabled(true)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT,
        function(event, x, y)
            if "began" == event.name then
                -- printf("================ touch __cname = %s,notice = %s", self.__cname,self.notice)
                if self.touchFunc ~= nil then
                    self.touchFunc()
                end
                return true
            end
        end, 1)
    self:setTouchSwallowEnabled(true)
end

-- function MaskLayer:setNotice(str)
--     self.notice = str
--     RegNotice(self, function()
--         self:removeSelf()
--         end, str)

-- end

function MaskLayer:onEnter()
    if self.notice ~= nil and self.notice ~= "" then
        if self.isReg == false then
            self.isReg = true
             RegNotice(self, function()
                    self:removeSelf()
                    end, self.notice)
        end
    end

end

function MaskLayer:resetTime(reTime)
    local loreTime = reTime
    if reTime == nil then
        if self.removeTime ~= nil then
            loreTime = self.removeTime
        end
    else
        loreTime = reTime        
    end

     ResMgr.delayFunc(loreTime,function()
                self:removeSelf()
                end, self)
end

function MaskLayer:onExit()
    if self.notice ~= nil and self.notice ~= "" then
        UnRegNotice(self, self.notice)
        self.isReg = false 
        -- self.notice = "nonotice"
    end
end

function MaskLayer:setTouchFunc(func)
    self.touchFunc = func
end

return MaskLayer

