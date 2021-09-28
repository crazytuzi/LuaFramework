--[[
    文件名：Guide.GuideLayer.lua
    描述：引导页面
    创建人：杨科
    创建时间：2015.8.19
-- ]]

local GuideLayer = class("GuideLayer", function(params)
    return display.newLayer(cc.c4b(0, 0, 0, 0))
end)

local CONFIG_SCREEN_WIDTH = CC_DESIGN_RESOLUTION.width
local CONFIG_SCREEN_HEIGHT = CC_DESIGN_RESOLUTION.height

local function scaleRect(rect, scaleX, scaleY)
    if not rect then
        return
    end
    scaleX = scaleX or 1
    scaleY = scaleY or 1
    rect.x = rect.x + rect.width * (1 - scaleX) / 2
    rect.y = rect.y + rect.height * (1 - scaleY) / 2
    rect.width = rect.width * scaleX
    rect.height = rect.height * scaleY
    return rect
end

--[[
params:
{
    <eventID>
    <clickNode | clickRect>
        [clickNode] [dragToNode]
        [clickRect] [dragToRect]
    [arrowPos]
    [showArrow]
    [hintPos]
    [clickScaleX]
    [clickScaleY]
    [nextStep]
    [mute]
}

eventID:              指引事件ID
clickNode/clickRect   GuideEventType.ePoint类型时传入其中一个,用于指定点击穿透位置
                      如果传入clickRect,且长或者宽为0，此时需要传入nextStep，用于点
                      击回调。长或者宽为0时，showArrow不为true,则只限时气泡不显示
                      手指。
dragToNode/dragToRect 传入该参数，手指会在click区域和drag区域来回移动，提示拖动
hintPos               GuideEventType.ePoint类型时,气泡位置
clickScaleX/Y         点击区域缩放
nextStep              对话引导:对话结束后回调。指引类型:没有穿透区域时点击回调。
mute                  静音，默认false
--]]
function GuideLayer:ctor(params)
    self.mParams = params and clone(params) or {}

    self.mBaseNode = ccui.Widget:create()
    self.mBaseNode:setPosition(cc.p(0, 0))
    self:addChild(self.mBaseNode)

    local clickTime = 0  -- 点击次数
    local lastClickTick = 0 -- 上次点击时间戳

    ui.registerSwallowTouch({
        node       = self,
        beganEvent = function(touch, event)
            if not self.mClickRect then
                return true
            end

            -- 是否在点击范围
            local isContain = cc.rectContainsPoint(self.mClickRect, touch:getLocation())

            -------- 短时间内重复点击则重新获取位置 --------
            if clickTime >= 2 then
                if not tolua.isnull(self.mParams.clickNode) then
                    self.mSecondAnalysis = true
                    self:analysisGuideInfo()
                end
                clickTime = 0
            end

            if os.time() - lastClickTick <= 2 then
                clickTime = clickTime + 1
            else
                clickTime = 0
            end
            lastClickTick = os.time()

            --------------------------------------------
            -- 如点击非引导区域，显示引导点光效
            if not isContain then
                self:createActionHalo()
            end
            return not isContain
        end,
        endedEvent = function()
            if not self.mClickRect then
                return
            end

            if self.mClickRect.width == 0 and self.mClickRect.height == 0 then
                self:callNext()
            end
        end,
    })

    self:analysisGuideInfo()
end


function GuideLayer:playSound(...)
    if (not self.mParams.mute) and (not self.mSecondAnalysis) then
        return Guide.manager:playSound(...)
    end
end


-- 解析新手引导信息
function GuideLayer:analysisGuideInfo()
    self.mBaseNode:removeAllChildren()
    self.haloSprites = {}

    self.mNextCallQueue = {}
    if self.mParams.nextStep then
        table.insert(self.mNextCallQueue, self.mParams.nextStep)
    end

    local eventModel = GuideEventModel.items[self.mParams.eventID]
    if not eventModel then
        if self.mParams.eventID then
            dump("---------------------------------------")
            dump(string.format("Can not found %s!!!", self.mParams.eventID), "GuideEventModel Error!!")
        end
        return
    end

    if self.mParams.eventID == 1020003 then
        self:showGuideHero(eventModel)
    -- 指引
    elseif eventModel.eventTypeEnum == GuideEventType.ePoint then
        self:analysisPoint(eventModel)

    -- 对话
    elseif eventModel.eventTypeEnum == GuideEventType.eDailog then
        self:analysisDialog(eventModel)

    -- 功能开启
    elseif eventModel.eventTypeEnum == GuideEventType.eGoto then
        self:analysisGoto(eventModel)

    -- 发放物品
    elseif eventModel.eventTypeEnum == GuideEventType.eGift then
        self:analysisGift(eventModel)
    end
end

-- 解析指引类型
function GuideLayer:analysisPoint(eventModel)
    local clickNode = self.mParams.clickNode

    -- 可点击区域（使用clickRect 或通过clickNode获取）
    local clickRect = self.mParams.clickRect
                    or scaleRect(ui.getControlWorldSpaceRect(clickNode), self.mParams.clickScaleX, self.mParams.clickScaleY)
    self.mClickRect = clickRect

    -- showArrow为true，强制显示手指
    -- clickRect可穿透，显示手指
    if (self.mParams.showArrow == true or (clickRect.width > 0 and clickRect.height > 0))
        and self.mParams.showArrow ~= false then
        -- 点击位置（使用arrowPos 或点击区域中心）
        local clickPos = self.mParams.arrowPos
                    or cc.p(cc.rectGetMidX(clickRect), cc.rectGetMidY(clickRect))
        -- 拖动区域（使用dragToRect 或通过dragToNode获取）
        local dragToRect = self.mParams.dragToRect
                or (self.mParams.dragToNode and ui.getControlWorldSpaceRect(self.mParams.dragToNode))

        local dragToPos
        if dragToRect then
            -- 拖动位置
            dragToPos = cc.p(cc.rectGetMidX(dragToRect), cc.rectGetMidY(dragToRect))
        end
        -- 创建手指
        self:createArrow(clickPos, dragToPos, self.mParams.hideFlash, self.mParams.rotation)
    end

    if eventModel.dialogList and eventModel.dialogList ~= "" then
        -- 手指大小
        local arrowSize = cc.size(88, 88)

        self:createHintNode(eventModel.dialogList, clickRect, arrowSize)
    end

    if eventModel.sound and eventModel.sound ~= "" then
        local sound = Utility.getEventSound(eventModel)
        self:playSound(sound)
    end
end

-- 在指定位置创建手指
function GuideLayer:createArrow(clickPos, dragToPos, hideFlash, rotaion)
    -- 手指节点 用于放置手指和光圈
    local arrowNode = cc.Node:create()
    self.mBaseNode:addChild(arrowNode)

    -- 添加拖动提示光圈
    if not hideFlash and dragToPos then
        local flashCircle = ui.newEffect({
            parent     = arrowNode,
            position   = dragToPos,
            scale      = Adapter.MinScale,
            effectName = "effect_ui_xinshouyindao",
            animation  = "dianji",
            loop       = true,    -- 是否循环显示
            endRelease = false
        })
    end
    -- 创建光圈和手指
    local arrowSprite = ui.addGuideArrowEffect(arrowNode, clickPos, not hideFlash)
    -- 需要拖动
    if dragToPos then
        arrowSprite:stopAllActions()
        arrowSprite:runAction(cc.RepeatForever:create(
            cc.Sequence:create(
                cc.CallFunc:create(function()
                    arrowSprite:setVisible(false)
                end),
                cc.MoveTo:create(0.2, clickPos),
                cc.CallFunc:create(function()
                    arrowSprite:setVisible(true)
                end),
                cc.DelayTime:create(0.2),
                cc.MoveTo:create(1.1, dragToPos),
                cc.DelayTime:create(0.25)
            )
        ))
    elseif rotaion then
        arrowSprite:setRotation(rotaion)
    else
        -- 假如在四个脚则旋转手指（避免超出屏幕）
        arrowSprite:setRotation(self:getArrowRotation(clickPos))
    end

    -- 显示引导点光效(仅传入显示位置)
    self:createActionHalo(clickPos)
    return arrowNode
end

-- 显示引导位置的光圈特效
-- clickPos: 有值时表示仅传位置
function GuideLayer:createActionHalo(clickPos)
    -- 全屏点击界面不显示光圈
    if self.mClickRect.width == 0 and self.mClickRect.height == 0 then
        return
    end

    self.haloSprites = self.haloSprites or {}
    if #self.haloSprites == 0 then
        for i=1,3 do
            local haloSprite = ui.newSprite("xsyd_11.png")
            self.mBaseNode:addChild(haloSprite)
            table.insert(self.haloSprites, haloSprite)
        end
    end
    for i,halo in ipairs(self.haloSprites) do
        if clickPos then
            halo:setPosition(clickPos)
            halo:setVisible(false)
        else
            halo:setScale(1.5)
            halo:setVisible(true)
            halo:stopAllActions()
            local actionList = {cc.DelayTime:create((i-1) * 0.3),
                cc.ScaleTo:create(0.4, 0.75), 
                cc.ScaleTo:create(0.4, 0.01), 
                cc.Hide:create()}
            halo:runAction(cc.Sequence:create(actionList))
        end
    end
end

-- 根据点击位置获取点击手指的旋转角度
function GuideLayer:getArrowRotation(clickPos)
    if not clickPos then
        return 0
    end
    local minPosX = 100 * Adapter.AutoScaleX
    local minPosY = 100 * Adapter.AutoScaleY
    local maxPosX = 540 * Adapter.AutoScaleX
    local maxPosY = 1000 * Adapter.AutoScaleY

    local ret = 0
    if clickPos.x <= minPosX then
        if clickPos.y < minPosY then -- 在左下角
            ret = -90
        end
    elseif clickPos.x >= maxPosX then
        if clickPos.y <= minPosY then -- 在右下角
            ret = 180
        elseif clickPos.y >= maxPosY then -- 在右上角
            ret = 90
        else -- 右侧
            ret = 45
        end
    else
        if clickPos.y <= minPosY then -- 底部
            ret = -135
        elseif clickPos.y >= maxPosY then -- 顶部
            ret = 45
        end
    end
    return ret
end

-- 创建指引气泡
function GuideLayer:createHintNode(text, clickRect, arrowSize)
    local node = cc.Node:create()
    local nodeSize = cc.size(393, 225)
    node:setContentSize(nodeSize)
    node:setScale(Adapter.MinScale)
    node:setAnchorPoint(cc.p(0.5, 0.5))
    self.mBaseNode:addChild(node)

    -- local girlEffect = ui.newEffect{
    --     effectName = "effect_ui_xiaobixinshouyindao",
    --     animation  = "animation",
    --     anchor     = cc.p(0, 0),
    --     position   = cc.p(nodeSize.width + 65, -15),
    --     scale      = 0.35,
    --     loop       = true,
    --     endRelease = true,
    -- }
    -- girlEffect:setLocalZOrder(2)
    -- node:addChild(girlEffect)

    -- 创建气泡
    local hintBgSprite = ui.newSprite("xsyd_09.png")
    hintBgSprite:setAnchorPoint(cc.p(0.5, 0))
    hintBgSprite:setPosition(nodeSize.width / 2, 0)
    node:addChild(hintBgSprite, 1)

    local hintBgSize = hintBgSprite:getContentSize()

    -- 小三角
    local hintSize = hintBgSprite:getContentSize()
    local trangleSprite = ui.newSprite("xsyd_08.png")
    trangleSprite:setPosition(hintSize.width - 95, 22)
    hintBgSprite:addChild(trangleSprite)

    -- 替换玩家名
    local text = string.gsub(text, "__name__",
        string.format("#100000%s#87561F", PlayerAttrObj:getPlayerAttrByName("PlayerName")))

    -- 引导人
    local nameLabel = ui.newLabel{
        text       = TR("黄蓉"),
        font       = _FONT_PANGWA,
        size       = 26,
        color      = cc.c3b(0xff, 0xcc, 0x7c),
        x          = hintBgSize.width * 0.5 + 76,
        y          = hintBgSize.height * 0.4,
    }
    hintBgSprite:addChild(nameLabel)

    -- 指引文字
    local hintLabel = ui.newLabel{
        text       = text,
        font       = _FONT_PANGWA,
        size       = 22,
        color      = cc.c3b(0xf4, 0xd9, 0xae),
        align      = cc.TEXT_ALIGNMENT_LEFT,
        valign     = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
        x          = hintBgSize.width * 0.5 + 76,
        y          = hintBgSize.height * 0.23,
        anchorPoint= cc.p(0.5, 0.5),
        dimensions = cc.size(hintBgSize.width * 0.55, 0)
    }
    hintBgSprite:addChild(hintLabel)

    local hintBgHeight = nodeSize.height * Adapter.MinScale
    local arrowHeight = arrowSize.height * Adapter.MinScale
    local clickPos = cc.p(cc.rectGetMidX(clickRect), cc.rectGetMidY(clickRect))

    if self.mParams.hintPos then
        node:setPosition(self.mParams.hintPos)
    elseif clickPos.y > Adapter.HeightScale * (CONFIG_SCREEN_HEIGHT / 2) then
        -- 点击在屏幕上方则气泡显示在下方
        node:setPosition(display.cx, clickPos.y - hintBgHeight / 2 - arrowHeight)
    else
        -- 点击在屏幕下方则气泡显示在上方
        node:setPosition(display.cx, clickPos.y + hintBgHeight / 2 + math.max(clickRect.height / 2, arrowHeight))
    end

    if clickPos.x > display.cx then
        -- 点击在右边
        -- hintBgSprite:setRotationSkewY(180)
    end

    return node
end

-- 解析对话引导
function GuideLayer:analysisDialog(eventModel)
    self.mBaseNode:addChild(require("Guide.TalkView.TalkLayer").new{
        map      = tostring(eventModel.ID),
        pickedCB = function(id, callback)
            if id then
                self.mParams.nextStep(eventModel.ID, id, callback)
            else
                local _ = callback and callback()
            end
        end,
        closedCB = function(isSkip)
            self:callNext(isSkip)
        end,
    })
end

-- 根据对话数据创建人物模型（暂未使用）
function GuideLayer:createDialog(dialog, noMusic)
    local baseNode = cc.Node:create()
    local bgLayer = display.newLayer(cc.c4b(0, 0, 0, 150))
    baseNode:addChild(bgLayer)

    self.mClickRect = cc.rect(0, 0, 0, 0)
    local dialogID = dialog.modelID

    local dialogModel = GuideDialogModel.items[dialogID]
    if not dialogModel then
        dump(string.format("WTF? DialogModel not found <%s>.", dialogID))
    end

    -- 对话人物模型ID
    local heroModelID = dialogModel.heroModelID
    local soundName = dialog.mp3
    if not heroModelID or heroModelID == 0 or dialogModel.heroName == "" then
    end

    -- 对话人物名字
    local heroName = dialogModel.heroName
    if heroName == "" then
        heroName = PlayerAttrObj:getPlayerAttrByName("PlayerName")
    end

    -- 对话框底图大小
    local bgFrameSize = ui.getImageSize("c_154.png")
    local dialogNode = cc.Node:create()
    dialogNode:setContentSize(bgFrameSize)
    dialogNode:setAnchorPoint(cc.p(0.5, 0.5))
    dialogNode:setScale(Adapter.MinScale)
    dialogNode:setPosition(Adapter.AutoPos(CONFIG_SCREEN_WIDTH / 2,
            bgFrameSize.height / 2 + (CONFIG_SCREEN_HEIGHT - LayerManager.heightNoBottom)))
    baseNode:addChild(dialogNode, 2)

    local offsetY = 60

    -- 对话框底图
    local bgFrame = ui.newSprite("c_154.png")
    bgFrame:setPosition(bgFrameSize.width / 2, bgFrameSize.height / 2 + offsetY)
    dialogNode:addChild(bgFrame)

    -- 小三角
    local sprite = ui.newSprite("c_235.png")
    sprite:setPosition(bgFrameSize.width / 2, 20 + offsetY)
    dialogNode:addChild(sprite)

    -- 替换主角名
    local text = string.gsub(dialog.data, ";&@",
        string.format("{EE5C42, %s}%s{111111, %s}", _FONT_DEFAULT, PlayerAttrObj:getPlayerAttrByName("PlayerName"), _FONT_PANGWA))

    -- 对话内容
    local dialogLabel = ui.newLabel{
        text       = text,
        font       = _FONT_PANGWA,
        size       = 24,
        color      = Enums.Color.eBlack,
        align      = cc.TEXT_ALIGNMENT_LEFT,
        valign     = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
        dimensions = cc.size(bgFrameSize.width - 40, bgFrameSize.height - 20),
    }
    dialogLabel:align(display.LEFT_TOP, 30, bgFrameSize.height - 25 + offsetY)
    dialogNode:addChild(dialogLabel)

    -- 角色名
    local nameSprite = ui.newSprite("jzzyk_13.png")
    dialogNode:addChild(nameSprite)
    local nameLabel = ui.newLabel{
        text  = heroName,
        color = cc.c3b(0xE9, 0xE0, 0x95),
        size  = 24,
        dimensions = cc.size(24, 300),
    }
    nameLabel:align(display.CENTER, 14, 105)
    nameSprite:addChild(nameLabel)

    -- 计算位置
    local heroPos
    if dialogModel.dialogTypeEnum == 2 then
        -- 放在右边
        heroPos = cc.p(display.cx + (bgFrameSize.width / 2 - 80) * Adapter.MinScale,
                        (CONFIG_SCREEN_HEIGHT - LayerManager.heightNoBottom) * Adapter.MinScale)
        nameSprite:setPosition(bgFrameSize.width + 20, 200)
    else
        -- 放在左边
        heroPos = cc.p(display.cx - (bgFrameSize.width / 2 - 80) * Adapter.MinScale,
                        (CONFIG_SCREEN_HEIGHT - LayerManager.heightNoBottom) * Adapter.MinScale)
        nameSprite:setPosition(-20, 200)
    end

    local heroNode = Figure.newHero{
        heroModelID = heroModelID,
        parent      = baseNode,
        position    = heroPos,
        scale       = Adapter.MinScale * 0.7,
        shadow      = false,
    }
    if dialogModel.dialogTypeEnum == 2 then
        heroNode:setRotationSkewY(180) -- 翻转
        bgFrame:setRotationSkewY(180) -- 翻转
    end

    if not noMusic then
        -- 播放音效
        dump(soundName, "soundName")
    end

    return baseNode
end

-- 解析跳转类型指引
function GuideLayer:analysisGoto(eventModel)
    if self.mParams.clickNode then -- 在升级界面时点确定按钮
        return self:analysisPoint({ID = eventModel.ID})
    end

    -- 黑色蒙版
    self.mBaseNode:addChild(display.newLayer(cc.c4b(0, 0, 0, 200)))

    local bgSprite = ui.newScale9Sprite("sy_25.png", cc.size(506, 387))
    bgSprite:setScale(Adapter.MinScale)
    bgSprite:setPosition(display.center)
    local bgSize = bgSprite:getContentSize()
    self.mBaseNode:addChild(bgSprite)

    -- 显示标题
    local titleSp = ui.newSprite("sy_26.png")
    titleSp:setPosition(bgSize.width / 2, bgSize.height - 63)
    bgSprite:addChild(titleSp)

    -- 显示提示
    local titleLabel = ui.newLabel({
        text  = TR("恭喜您开启新的功能，快去看看吧！"),
        x     = bgSize.width / 2 + 10,
        y     = 255,
        color = Enums.Color.eBlack,
        font  = _FONT_TITLE,
        size  = 26,
    })
    bgSprite:addChild(titleLabel)

    -- 图标
    if self.mParams.icon then
        local sprite = ui.newSprite(self.mParams.icon)
        sprite:setScale(1.5)
        sprite:setPosition(bgSize.width / 2, 160)
        bgSprite:addChild(sprite)
    end

    local btnClose = ui.newButton{
        text        = TR("立即前往"),
        normalImage = "c_28.png",
        position    = cc.p(bgSize.width / 2, 60),
        clickAction = function()
            bgSprite:removeFromParent()
            -- 保存为本地变量后移除自身
            local params = self.mParams
            Guide.manager:removeGuideLayer()

            -- 保存此次引导(有可能它已经结束了)
            Guide.manager:nextStep(params.eventID, true)
            if params.nextStep then
                params.nextStep(params.eventID)
            end
        end,
    }
    bgSprite:addChild(btnClose)

    -- 点击区域和点击位置
    local clickRect = ui.getControlWorldSpaceRect(btnClose)
    self.mClickRect = clickRect

    local clickPos = cc.p(cc.rectGetMidX(clickRect), cc.rectGetMidY(clickRect))
    -- 创建手指
    self:createArrow(clickPos)

    if eventModel.sound and eventModel.sound ~= "" then
        self:playSound(eventModel.sound)
    end
end

-- 解析发放物品
function GuideLayer:analysisGift(eventModel, extData, callback)
    Guide.manager:getGift({
        eventID  = eventModel.ID,
        callback = function(...)
            local heroList = HeroObj:getHeroList({notInFormation=true})
            if self.mParams.eventID == 1020001 and #heroList ~= 0 then
                -- 特殊步骤需要自动上阵主将(固定上阵到2号位)
                local callbackArgs = arg
                HttpClient:request({
                    svrType = HttpSvrType.eGame,
                    moduleName = "Slot",
                    methodName = "HeroCombat",
                    svrMethodData = {2, heroList[1].Id},
                    callback = function(response)
                        if not response or response.Status ~= 0 then
                            return
                        end
                        self:callNext(callbackArgs)
                    end,
                })
            else
                self:callNext(...)
            end
        end,
    })
end

-- 调用下一步
function GuideLayer:callNext(...)
    dump("callNext:" .. #self.mNextCallQueue)
    local proc = self.mNextCallQueue[1]
    if proc then
        table.remove(self.mNextCallQueue, 1)
        proc(self.mParams.eventID, ...)
        return true
    end
end


-- 显示李富贵加入队伍
function GuideLayer:showGuideHero(eventModel)
    self.mBaseNode:addChild(display.newLayer(cc.c4b(0, 0, 0, 150)))

    local height = display.cy + 50 * Adapter.MinScale
    local heroModelID2 = FormationObj:getSlotInfoBySlotId(2).ModelId
    local heroModel2 = HeroModel.items[heroModelID2]

    -- 获得第二个主将
    local heroNode2 = Figure.newHero{
        heroModelID = heroModelID2,
        parent      = self.mBaseNode,
        needRace    = false,
        position    = cc.p(display.cx, height - 300 * Adapter.MinScale),
        scale       = Adapter.MinScale * 0.5,
        shadow      = false,
    }
    heroNode2:setLocalZOrder(1)
    heroNode2:setOpacity(0)

    -- 背光
    local flashEffect2 = ui.newEffect({
        parent      = self.mBaseNode,
        effectName  = "effect_ui_shengjiangchuchang_zi",
        scale       = Adapter.MinScale,
        position    = cc.p(display.cx, height),
        animation   = "guangyun",
        loop        = true,
        endRelease  = false,
    })
    flashEffect2:setOpacity(0)

    -- 播放下落音效
    MqAudio.playEffect("renwuhecheng_01.mp3")
    -- 下落特效
    ui.newEffect({
        parent        = self.mBaseNode,
        effectName    = "effect_ui_shengjiangchuchang_zi",
        position      = cc.p(display.cx, height - 150),
        loop          = false,
        scale         = Adapter.MinScale,
        animation     = "luo",
        endRelease    = true,
        endListener = function()
            -- 洪凌波出现
            heroNode2:runAction(cc.FadeIn:create(0.5))
            flashEffect2:runAction(cc.FadeIn:create(0.5))

            -- 播放下落完音效
            MqAudio.playEffect("renwuhecheng_02.mp3")

            -- 音效
            if heroModel2 and heroModel2.staySound ~= "0" then
                local _, staySound = Utility.getHeroSound(heroModel2)
                MqAudio.playEffect(Utility.randomStayAudio(staySound))
            end

            local tipsLabel1 = ui.newLabel{
                text  = TR("%s加入队伍", heroModel2.name),
                font  = _FONT_PANGWA,
                outlineColor = cc.c3b(0x51, 0x18, 0x63),
                color = cc.c3b(0xff, 00, 0xea),
                size  = 28 * Adapter.MinScale,
                x     = display.cx,
                y     = height - 355 * Adapter.MinScale,
            }
            self.mBaseNode:addChild(tipsLabel1)

            -- tips2
            local tipsLabel2 = ui.newLabel{
                text = TR("点击任意位置继续"),
                size = 24 * Adapter.MinScale,
                x    = display.cx,
                y    = height - 410 * Adapter.MinScale,
            }
            self.mBaseNode:addChild(tipsLabel2)

            -- 确定按钮
            local btnOK
            btnOK = ui.newButton{
                normalImage = "c_83.png",
                position    = cc.p(display.cx, display.cy),
                size        = display.size,
                clickAction = function()
                    self.mClickRect = nil
                    btnOK:removeFromParent(true)
                    -- tipsSprite:removeFromParent(true)
                    tipsLabel1:removeFromParent(true)
                    flashEffect2:removeFromParent(true)
                    tipsLabel2:removeFromParent(true)

                    local action1 = cc.Spawn:create(
                        cc.ScaleTo:create(0.6, 0),
                        cc.MoveTo:create(0.6, cc.p(display.cx - 130 * Adapter.MinScale, 50 * Adapter.MinScale))
                    )
                    heroNode2:runAction(cc.Sequence:create(
                        action1,
                        cc.CallFunc:create(function()
                            self:callNext()
                        end)
                    ))
                end,
            }
            self.mBaseNode:addChild(btnOK)

            self.mClickRect = ui.getControlWorldSpaceRect(btnOK)
        end,
    })
end

return GuideLayer
