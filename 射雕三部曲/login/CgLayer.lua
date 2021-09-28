--[[
    文件名: CgLayer.lua
	描述：片头动画
	创建人：yanweicai
	创建时间：2015.10.22
-- ]]

local CgLayer = class("CgLayer", function(params)
    local layer = cc.Layer:create()

    local function onNodeEvent(event)
        if "cleanup" == event then
            if layer.cleanup then
                layer:cleanup()
            end
        elseif "enter" == event then
            -- 停止所有音效(避免跳过时还有音效)
            MqAudio.stopAllEffect()
        end
    end

    layer:registerScriptHandler(onNodeEvent)
    return layer
end)


local aniSpeed = 1

--[[
-- 字幕
local zimuLabel = nil
local captions ={
    [1]  = {audio = "dh_01.mp3",  caption = "在很久很久以前，苍茫星空中有一个修仙者的圣地"},
    [2]  = {audio = "dh_02.mp3",  caption = "它的名字叫做至尊仙界，这里灵力浓郁，适合修炼"},
    [3]  = {audio = "dh_03.mp3",  caption = "所有修士，皆为仙人"},
    [4]  = {audio = "dh_04.mp3",  caption = "仙人术法高强，统领三千星空下界"},
    [5]  = {audio = "dh_05.mp3",  caption = "然而，众多下界心有不甘，欲反抗仙界。"},
    [6]  = {caption = "大战一触即发…"},
    [7]  = {audio = "cg_effect_bird.mp3"},
    [8]  = {audio = "cg_effect_sword.mp3"},
}

local cgEventHandler = function(p)
    if p.event.stringValue == "startmusic1" then
        MqAudio.playMusic("manhua.mp3", false)
    elseif p.event.stringValue == "sound" then
        local soundid = p.event.intValue
        if captions[soundid] and captions[soundid].audio then
            MqAudio.playEffect(captions[soundid].audio)
        end
    elseif p.event.stringValue == "empty" then
        zimuLabel:setString("")
    elseif p.event.stringValue == "caption" then
        local captionIndex = p.event.intValue
        zimuLabel:setString(captions[captionIndex].caption)
    end
end
--]]

--[[
    callback(true, false):动画播放完成后的完成回调(是否是跳过)
]]
function CgLayer:ctor(params)
    self.mEndCallback = params.callback

    -- 加个裁剪
    local bgClippingNode = cc.ClippingNode:create()
    self.bgClippingNode = bgClippingNode
    bgClippingNode:setAlphaThreshold(1.0)

    local stencilNode = cc.LayerColor:create(cc.c4b(255, 255, 255, 255))
    stencilNode:setContentSize(Adapter.AutoSize(640, 1136))
    bgClippingNode:setStencil(stencilNode)
    bgClippingNode:setAnchorPoint(cc.p(0.5, 0.5))
    self:addChild(bgClippingNode)

    -- 跳过按钮
    local posx, posy = display.cx + 250 * Adapter.MinScale, display.top - 80 * Adapter.HeightScale
    self.tiaoguoButton = ui.newButton({
        normalImage = "xsyd_04.png",
        clickAction = function(value , pSender)
            self.tiaoguoButton:setEnabled(false)
            -- 停止所有音效
            MqAudio.stopAllEffect()
            -- 跳过时打点
            HttpClient:hitPoint(10000, 1)

            if self.mEndCallback then
                self.mEndCallback(true)
            end
        end,
        scale = Adapter.MinScale,
        position = cc.p(posx, posy),
    })
    bgClippingNode:addChild(self.tiaoguoButton, 1)

    -- 监听点击事件
    local function bgLayerTouchBegin(touch, event)
       local isVisible = self.tiaoguoButton:isVisible()
       self.tiaoguoButton:setVisible(not isVisible)

        -- 加快播放速度
        -- if self.aniObj then
            -- self.aniObj:setTimeScale(10)
        -- end
        return false
    end

    local tempListener = cc.EventListenerTouchOneByOne:create()
    tempListener:setSwallowTouches(false)
    tempListener:registerScriptHandler(bgLayerTouchBegin, cc.Handler.EVENT_TOUCH_BEGAN )

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(tempListener, self)

    self.aniObj = nil

    --[[
    -- 添加字幕背景
    local zimuBgSprite = cc.Sprite:create("xsyd_06.png")
    zimuBgSprite:setPosition(cc.p(display.cx, 30 * Adapter.MinScale))
    zimuBgSprite:setScale(Adapter.MinScale)
    bgClippingNode:addChild(zimuBgSprite, 1)
    local zimuBgSize = zimuBgSprite:getContentSize()

    -- 字幕label
    zimuLabel = ui.newLabel{
        text = "",
        size = 26,
        color = Enums.Color.eWhite,
        align = cc.TEXT_ALIGNMENT_CENTER,
    }
    zimuLabel:setPosition(zimuBgSize.width / 2, zimuBgSize.height / 2)
    zimuBgSprite:addChild(zimuLabel)--]]

    self.curIndex = 1
    self:playScene(self.curIndex)
    -- 同时播放音效
    local musictype = Utility.getMusicType()
    -- 国语
    if musictype == Enums.MusicType.eML then
        MqAudio.playMusic("manhua.mp3", false)
    -- 粤语
    elseif musictype == Enums.MusicType.eHK then
        MqAudio.playMusic("manhua_tw.mp3", false)
    end
end

-- 场景1
function CgLayer:playScene(index)
    self.cgNameList = {"1_qietu_tw", "2_qietu_tw", "3_qietu_tw"}
    self.aniObj = ui.newEffect({
        parent = self.bgClippingNode,
        speed = aniSpeed,
        effectName = self.cgNameList[index],
        position = cc.p(display.cx, display.cy),
        endRelease = true,
        scale = Adapter.MinScale,
        startListener = function()
        end,
        completeListener = function(p)
            if self.curIndex < #self.cgNameList then
                -- 循环播放cg
                self.curIndex = self.curIndex + 1
                self:playScene(self.curIndex)
            elseif self.mEndCallback then
                -- 非跳过时打点
                HttpClient:hitPoint(10000, 0)
                self.mEndCallback(false)
            end
    	end,
    	-- eventListener = cgEventHandler,
    })
end


function CgLayer:cleanup( ... )
    cc.Director:getInstance():purgeCachedData()
end

return CgLayer