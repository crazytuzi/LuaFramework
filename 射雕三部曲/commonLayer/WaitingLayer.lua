--[[
    文件名: WaitingLayer.lua
    描述：UI屏蔽等待页面
    创建人：liaoyuangang
    创建时间：2016.03.30
-- ]]

local sharedDirector = cc.Director:getInstance()
local scheduler = sharedDirector:getScheduler()
local loadingTexture  -- loading 缓存资源

local WaitingLayer = class("WaitingLayer", function()
    return cc.LayerColor:create(cc.c4b(0, 0, 0, 128))
end)

function WaitingLayer:ctor(params)
    -- 设置屏蔽事件
    ui.registerSwallowTouch({
        node = self,
        allowTouch = true,
        beganEvent = function(touch, event)
            return self:isVisible()
        end,
    })

    -- 等待效果图不能异步加载，因为有可能一步加载完成后，WaitingLayer 对象已经被销毁，为了提高效率，改为永久缓存动画资源
    if not loadingTexture then
        local tempCache = sharedDirector:getTextureCache()
        loadingTexture = tempCache:addImage("hero_loading.png")
        loadingTexture:retain()
    end

    -- loading动画
    --local niaoOriPos = Adapter.AutoPos(370, 500)
    local qiuOriPos = Adapter.AutoPos(320, 500)

    local qiuAnim = ui.newEffect({
        parent = self,
        effectName = "hero_loading",
        --animation = "qiudaiji",
        scale = 0.4 * Adapter.MinScale,
        position = qiuOriPos,
        loop = true,
        endRelease = false,
    })

    -- loading 的提示文字
    local tempCount = 1
    -- local tempSize = cc.size(150, 40)
    -- local tempSprite = ui.newScale9Sprite("c_39.png", tempSize)
    -- tempSprite:setScale(Adapter.MinScale)
    -- tempSprite:setPosition(Adapter.AutoPos(320, 465))
    -- self:addChild(tempSprite)

    local loadingLabel = ui.newLabel({
        text = TR("等待中 ") .. ".",          -- 显示的内容
        color = Enums.Color.eWhite,
        align = cc.TEXT_ALIGNMENT_LEFT,
    })
    loadingLabel:setAnchorPoint(cc.p(0.5, 0.5))
    loadingLabel:setPosition(Adapter.AutoPos(320, 465))
    self:addChild(loadingLabel)

    Utility.schedule(loadingLabel, function()
        if not self:isVisible() then
            return
        end

        local tempStr = TR("等待中 ")
        tempCount = math.mod(tempCount + 1, 5)
        for index = 1, tempCount do
            tempStr = tempStr .. "."
        end
        loadingLabel:setString(tempStr)
    end, 1)
end

return WaitingLayer
