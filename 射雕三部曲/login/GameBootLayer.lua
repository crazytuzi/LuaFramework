--[[
    文件名：GameBootLayer.lua
	描述：游戏启动显示页
	创建人：liaoyuangang
	创建时间：2016.3.29
-- ]]
local scheduler = cc.Director:getInstance():getScheduler()
local GameBootLayer = class("GameBootLayer", function()
    return display.newLayer(cc.c4b(255, 255, 255, 255))
end)

--[[
-- 参数 params为 {thirdLogo1, thirdLogo2, thirdLogo3, ...}
 ]]
function GameBootLayer:ctor(params)
    self.mThirdLogoList = params or {}

    for idx = #self.mThirdLogoList, 1, -1 do
        if not cc.FileUtils:getInstance():isFileExist(self.mThirdLogoList[idx]) then
            table.remove(self.mThirdLogoList, idx)
        end
    end

    if #self.mThirdLogoList > 0 then
	    self.logoSprite = cc.Sprite:create(self.mThirdLogoList[1])
	    self.logoSprite:setPosition(cc.p(display.cx, display.cy))
	    self.logoSprite:setScaleX(Adapter.AutoScaleX)
	    self.logoSprite:setScaleY(Adapter.AutoScaleY)
	    self:addChild(self.logoSprite)
        
	    table.remove(self.mThirdLogoList, 1)
	    self:createTimer()
    end
end

function GameBootLayer:onExit()
	self:closeTimer()
end

function GameBootLayer:createTimer()
	if self.mScheduleHandle then
        return
    end

    local onScheduler = function()
        if #self.mThirdLogoList == 0 then
            self:closeTimer()
            LayerManager.addLayer({name = "login.GameLoginLayer"})
            return
        end

        if self.logoSprite then
            self:removeChild(self.logoSprite)
        end

        local tempSprite = cc.Sprite:create(self.mThirdLogoList[1])
        table.remove(self.mThirdLogoList, 1)

        tempSprite:setPosition(cc.p(display.cx, display.cy))
        tempSprite:setScaleX(Adapter.AutoScaleX)
        tempSprite:setScaleY(Adapter.AutoScaleY)
        self:addChild(tempSprite)
    end
    self.mScheduleHandle = scheduler:scheduleScriptFunc(onScheduler, 2.0, false)
end

function GameBootLayer:closeTimer()
	if self.mScheduleHandle then 
		scheduler:unscheduleScriptEntry(self.mScheduleHandle)
        self.mScheduleHandle = nil
	end
end

return GameBootLayer