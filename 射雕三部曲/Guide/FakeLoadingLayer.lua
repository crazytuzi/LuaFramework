--[[
    filename: Guide.FakeLoadingLayer
    description: 假加载
    date: 2017.01.11

    author: 杨科
    email:  h3rvgo@gmail.com
-- ]]

local FakeLoadingLayer = class("FakeLoadingLayer", function(params)
    local layer = cc.Layer:create()
    layer:enableNodeEvents()
    return layer
end)


function FakeLoadingLayer:ctor(params)
    self.callback = params.callback

    --背景
    local bgList = bd.ui_config.loadingMapPic
    local sprite = cc.Sprite:create(bgList[math.random(1,#bgList)])
    if sprite then
        sprite:setScale(bd.ui_config.MaxScale)
        sprite:setPosition(bd.ui_config.cx , bd.ui_config.cy)
        self:addChild(sprite)
    end

    --创建进度条
    self.progress = bd.interface.newProgress({
        bgImage   = bd.ui_config.loadingBgPic,
        barImage  = bd.ui_config.loadingFrontPic,
        currValue = 0,
        maxValue  = 100,
        needLabel = true,
        font      = "Arial",
        color     = cc.c3b(255, 255, 100),
    })
    self.progress:setScaleY(1.2 * bd.ui_config.MinScale)
    self.progress:setScaleX(bd.ui_config.MinScale)
    self.progress:setAnchorPoint(cc.p(0.5, 0.5))
    self.progress:setPosition(cc.p(bd.ui_config.cx, 100*bd.ui_config.AutoScaleY))
    self.progress:setMaxValue(100)
    self:addChild(self.progress)
end


function FakeLoadingLayer:onEnterTransitionFinish()
    if self.mOnEnterTransitionFinished then
        return
    end

    local totalCnt = 100
    local totalTime = 0.5 -- 设定的加载时间
    local outtime = 0   -- 已耗时
    local doneCnt = 0   -- 已完成的数量

    self:onUpdate(function(delta)
        outtime = outtime + delta

        -- 应该加载完成的数量
        local outCnt = math.ceil(totalCnt * outtime / totalTime)
        -- 本帧需要完成的数量
        local cnt = outCnt - doneCnt
        if cnt <= 0 then
            cnt = 1 -- 保证至少加载一个文件
        end

        doneCnt = doneCnt + cnt

        if doneCnt >= totalCnt then
            self.progress:setCurrValue(100)
            self:unscheduleUpdate()

            if self.callback then
                bd.func.performWithDelay(self, function()
                    self.callback(self)
                    LayerManager.removeLayer(self)
                end, 0.001)
            end
        else
            self.progress:setCurrValue(doneCnt * 100 / totalCnt)
        end
    end)
end


return FakeLoadingLayer
