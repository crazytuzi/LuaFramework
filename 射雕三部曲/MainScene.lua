--[[
    文件名：MainScene
	描述：游戏唯一场景（游戏中除了战斗场景外，只有一个场景）
	创建人：liaoyuangang
	创建时间：2015.12.07
-- ]]

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    local bgInfoList = {{pos=cc.p(display.cx+Adapter.MinScale*320, display.cy), anchor=cc.p(0, 0.5)},
        {pos=cc.p(display.cx-Adapter.MinScale*320, display.cy), anchor=cc.p(1, 0.5), flip = true},
        {pos=cc.p(display.cx, display.cy + Adapter.MinScale*568), anchor=cc.p(1, 0.5), rotate = 90},
        {pos=cc.p(display.cx, display.cy - Adapter.MinScale*568), anchor=cc.p(0, 0.5), rotate = 90},
    }
    for i,v in ipairs(bgInfoList) do
        local depthBgSprite = ui.newSprite("c_161.jpg")
        depthBgSprite:setPosition(v.pos)
        depthBgSprite:setScale(Adapter.AutoScaleX)
        depthBgSprite:setAnchorPoint(v.anchor)
        self:addChild(depthBgSprite, 1024)
        if v.flip then
            depthBgSprite:setFlippedX(true)
        end
        if v.rotate then
            depthBgSprite:setRotation(v.rotate)
        end
    end

    -- 创建打开调试信息开关窗体
    local tempLayer = ui.createDebugLayer()
    self:addChild(tempLayer, 1024)
end

return MainScene