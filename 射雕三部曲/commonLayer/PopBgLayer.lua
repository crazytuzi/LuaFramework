--[[
    文件名：PopBgLayer.lua
	描述：公共的弹窗背景创建
	创建人：shuaixitao
	创建时间：2016.3.16
--]]

PopBgLayer = class("PopBgLayer", function(params)
    return display.newLayer(params and params.color4B or cc.c4b(0, 0, 0, 128))
end)

--[[
-- params参数说明
    { 
        bgImage:  背景图片，默认为：c_30.png
        bgSize: 背景的大小 默认为：cc.size(590, 950)
        closeImg: 关闭按钮图片名, 为nil，表示使用默认关闭按钮图片，为 “” 表示不需要关闭按钮，
        closeBtnPos: 关闭按钮的位置，为nil时，使用默认位置
        title: 页面的标题图片名或title文字
        titlePos: 标题的显示位置
        popAction: 是否显示弹出动画，默认为true
        color4B: 带透明度的颜色值 默认为：cc.c4b(0, 0, 0, 128)  
        isCloseOnTouch: 是否需要触摸屏幕的任何位置调用关闭按钮的回调
        
        closeAction: 关闭按钮点击事件 closeAction(layerObj)
    }

-- 子类可以访问的对象
     self.mBgSprite： 背景对象
     self.mTitle：title控件
     self.mCloseButton：关闭按钮
--]]
function PopBgLayer:ctor(params)
    params = params or {}

    -- 注册屏蔽下层页面事件
    ui.registerSwallowTouch({
        node = self,
        allowTouch = true,
        beganEvent = function(touch, event)
            return self:isVisible()
        end,
        endedEvent = function(touch, event)
            if params.isCloseOnTouch then
                if params.closeAction then
                    params.closeAction(self)
                else
                    LayerManager.removeLayer(self)
                end
            end
        end,
    })

    self.mBgImage = params.bgImage or "c_30.png"
    -- 是否是默认的背景图片
    self.mIsDefaultBg = self.mBgImage == "c_30.png"
    -- 背景大小优先使用传入参数的大小; 其次如果是默认背景图片则使用默认大小；再次使用背景图片的大小
    self.mBgSize = params.bgSize or self.mIsDefaultBg and cc.size(572, 950) or ui.getImageSize(params.bgImage)

    -- 创建背景图片
    self.mBgSprite = ui.newScale9Sprite(self.mBgImage, self.mBgSize)
    self.mBgSprite:setPosition(cc.p(display.cx, display.cy))
    self.mBgSprite:setScale(Adapter.MinScale)
    self:addChild(self.mBgSprite)

    -- 创建关闭按钮
    if params.closeFile ~= "" then
        local closeBtnPos = params.closeBtnPos or cc.p(self.mBgSize.width - 35, self.mBgSize.height - 32)
        self.mCloseButton = ui.newButton({
            normalImage = params.closeImg or "c_29.png",
            position = closeBtnPos,
            clickAction = function()
                if params.closeAction then
                    params.closeAction(self)
                else
                    LayerManager.removeLayer(self)
                end
            end
        })
        self.mBgSprite:addChild(self.mCloseButton)
    end

    -- 创建Title
    if params.title and params.title ~= "" then
        -- 标题的位置
        local titlePos = params.titlePos or cc.p(self.mBgSize.width / 2, self.mBgSize.height - 35)
        -- 标题的锚点
        local titleAnchorPoint = cc.p(0.5, 0.5)
        -- 
        if string.isImageFile(params.title) then
            self.mTitle = ui.newSprite(params.title)
            self.mTitle:setPosition(titlePos)
            self.mTitle:setAnchorPoint(titleAnchorPoint)
            self.mBgSprite:addChild(self.mTitle)
        else
            self.mTitle = ui.newLabel({
                text = params.title,
                size = 30,
                color = cc.c3b(0xff, 0xee, 0xd0),
                outlineColor = cc.c3b(0x3a, 0x24, 0x18),
                outlineSize = 2,
            })
            self.mTitle:setAnchorPoint(titleAnchorPoint)
            self.mTitle:setPosition(titlePos)
            self.mBgSprite:addChild(self.mTitle)
        end
    end

    -- 显示弹出动画
    if (params.popAction == nil) or (params.popAction == true) then
        self:runPopAction()
    end
end

-- 显示弹出动画
function PopBgLayer:runPopAction()
    self.mBgSprite:setScale(0)
    self.mBgSprite:runAction(cc.ScaleTo:create(0.2, Adapter.MinScale))
end

-- 门派声望进阶弹窗
--[[
    sectId  门派id
    rankId  职阶id
]]
function PopBgLayer.sectRankAdvanced(sectId, rankId)
    local bgSize = cc.size(420, 268)

    local popLayer = LayerManager.addLayer({
            name = "commonLayer.PopBgLayer",
            data = {
                bgImage = "mp_87.png",
                bgSize = bgSize,
                title = "",
                closeImg = "",
                isCloseOnTouch = true,
                popAction = false,
            },
            cleanUp = false,
            zOrder = Enums.ZOrderType.eMessageBox+1,
        })
    -- 背景
    local bgSprite = popLayer.mBgSprite
    -- 提示文字
    local hintLabel = ui.newLabel({
            text = TR("您在%s的称号进阶为", SectModel.items[sectId].name),
            size = 26,
            color = Enums.Color.eBlack,
        })
    hintLabel:setPosition(bgSize.width*0.5, bgSize.height*0.6)
    bgSprite:addChild(hintLabel)
    -- 阶位图标
    local sectSprite = ui.newSprite(SectRankModel.items[rankId].pic..".png")
    sectSprite:setPosition(bgSize.width*0.5, bgSize.height*0.4)
    bgSprite:addChild(sectSprite)

    -- 弹窗动画
    -- 背面图
    local backSprite = ui.newScale9Sprite("sy_25.png", boxSize)
    backSprite:setPosition(bgSprite:getContentSize().width*0.5, bgSprite:getContentSize().height*0.5)
    bgSprite:addChild(backSprite)
    -- 旋转圈数
    local rotateCount = 1
    -- 循环次数
    local loopCount = rotateCount*2
    -- 当前背面
    local isCurBeimian = false
    -- 先隐藏背面显示
    backSprite:setVisible(isCurBeimian)
    -- 动作总时间
    local allTime = 0.2
    -- x最小Scale
    local minScaleX = 0.05
    -- 动作列表
    local actionList = {}
    -- 循环创建动作
    for i = 1, loopCount do
        local curScale = Adapter.MinScale * (i / loopCount )
        local actionTime = allTime / (loopCount*2)

        local scaleAction = cc.ScaleTo:create(actionTime, minScaleX, curScale)

        local callAction = cc.CallFunc:create(function (node)
            isCurBeimian = not isCurBeimian
            backSprite:setVisible(isCurBeimian)
        end)
        local scaleAction2 = cc.ScaleTo:create(actionTime, curScale, curScale)

        table.insert(actionList, scaleAction)
        table.insert(actionList, callAction)
        table.insert(actionList, scaleAction2)
    end
    -- 创建序列动作
    local seqAction = cc.Sequence:create(actionList)
    bgSprite:runAction(seqAction)

    return popLayer
end

return PopBgLayer
