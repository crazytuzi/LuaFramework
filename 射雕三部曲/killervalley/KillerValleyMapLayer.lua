--[[
    文件名: KillerValleyMapLayer.lua
    描述: 绝情谷大地图
    创建人: heguanghui
    创建时间: 2018.01.22
-- ]]
local KillerValleyMapLayer = class("KillerValleyMapLayer", function(params)
    return display.newLayer()
end)

--[[
    参数:
--]]
function KillerValleyMapLayer:ctor(params)
    --父节点标准层
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    --返回按钮
    local cancelBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(600, 1080),
        clickAction = function ()
            -- 直接返回到挑战，清空栈
            KillerValleyUiHelper:exitGame()
        end
    })
    self.mParentLayer:addChild(cancelBtn, 1)
    -- 加载障碍地图
    self.mAstarWorld = require("common.AStar").new({"killervalley.KillerValleyMap"})

    -- 显示大地图
    self:createBigMap()
    -- 显示小地图
    self:createMiniMap()
    -- 创建所有人物
    self:createAllHeros()
    -- 添加拖动事件
    self:setTouchEvent()

    -- 添加按钮图标(飞刀和道具，布阵)
    self:addHanderBtns()
    -- 添加滚动信息记录窗口
    self:addRecordsAndRolling()
    -- 添加毒圈蔓延倒计时
    self:addPoisonCircleTimeLabel()

    -- 注册推送通知事件
    self:registerPushNotification()
    -- 添加地图更新事件
    Utility.schedule(self.mParentLayer, handler(self, self.updateWorldSchedule), 0)
end

function KillerValleyMapLayer:onEnterTransitionFinish()
    -- 判断比赛是否已经结束
    if (KillerValleyHelper.battleResultData ~= nil) then
        LayerManager.addLayer({name = "killervalley.KillerValleyGameEndLayer", cleanUp = false,})
    else
        local selfData = KillerValleyHelper:getPlayerData()
        -- 如7号位上有将，则需要弹出布阵界面
        if selfData and #selfData.Formations >= 7 and selfData.Formations[7] > 0 then
            LayerManager.addLayer({name = "killervalley.DlgSetCampLayer", cleanUp = false,})
        end
    end
end

--创建地图
function KillerValleyMapLayer:createBigMap()
    -- 创建可拖动背景
    local worldView = ccui.ScrollView:create()
    worldView:setContentSize(cc.size(640, 1136))
    worldView:setPosition(cc.p(0,0))
    worldView:setDirection(ccui.ScrollViewDir.both)
    worldView:setSwallowTouches(false)
    -- worldView:setTouchEnabled(false)
    self.mParentLayer:addChild(worldView)
    self.mWorldView = worldView

    -- 创建背景
    local bgSprite = ui.newSprite("jqg_6.jpg")
    bgSprite:setAnchorPoint(0, 0)
    bgSprite:setPosition(0, 0)
    self.mWorldView:setInnerContainerSize(bgSprite:getContentSize())
    self.mWorldView:addChild(bgSprite, -2)
    self.mMapBg = bgSprite
    self.mMapSize = bgSprite:getContentSize()
end

-- 创建小地图
function KillerValleyMapLayer:createMiniMap()
    -- 创建缩小版地图精灵
    local miniSprite = ui.newSprite("jqg_46.png")
    miniSprite:setAnchorPoint(0, 1)
    miniSprite:setPosition(0, 1136)
    self.mParentLayer:addChild(miniSprite)

    self.miniWorldWidth = 120
    local miniOffsetWidth = (miniSprite:getContentSize().width - self.miniWorldWidth) / 2
    local miniNode = display.newNode()
    miniNode:setPosition(miniOffsetWidth, miniOffsetWidth)
    miniNode:setContentSize(cc.size(self.miniWorldWidth, self.miniWorldWidth))
    miniSprite:addChild(miniNode)
    -- 创建所有的人物小地图位置
    self.mPlayerMiniNode = ui.newSprite("jqg_23.png")
    miniNode:addChild(self.mPlayerMiniNode)
    self.miniNode = miniNode
    self.miniScalePercent = self.miniWorldWidth / self.mMapSize.width
end

-- 创建所有人物
function KillerValleyMapLayer:createAllHeros()
    -- 创建人物脚下光圈
    self.mSelfCirleSprite = ui.newSprite("jqg_7.png")
    self.mMapBg:addChild(self.mSelfCirleSprite)
    self.mSelfCirleSprite:setVisible(false)
    self.mSelfCirleSprite:setAnchorPoint(cc.p(0.2, 0.5))

    -- 创建所有人物
    self.playerNodes = {}
    self.selfPlayerNode = nil
    local selfPId = PlayerAttrObj:getPlayerAttrByName("PlayerId")
    for _,pInfo in ipairs(KillerValleyHelper.playerList) do
        local heroNode = require("killervalley.KillerValleyPlayer").new({playerInfo = pInfo, astarWorld = self.mAstarWorld})
        self.mMapBg:addChild(heroNode)
        self.playerNodes[pInfo.PlayerId] = heroNode
        self:setHeroPosition(pInfo.PlayerId, pInfo.CurPos)
        -- 保存自身结点
        if selfPId == pInfo.PlayerId then
            self.selfPlayerNode = heroNode
        end
    end

    -- 创建当前存活人数
    local liveLabel = ui.newLabel({
        text = TR("当前存活人数:#FFBB50%d", #KillerValleyHelper.playerList),
        outlineColor = cc.c3b(0x29, 0x16, 0x14),
        size = 20,
    })
    liveLabel:setAnchorPoint(0, 0.5)
    liveLabel:setPosition(140, 1118)
    self.mParentLayer:addChild(liveLabel)
    self.livePlayerLabel = liveLabel
end

-- 定时更新地图事件
function KillerValleyMapLayer:updateWorldSchedule(pId, pos)
    -- 更新人物位置及状态
    for _,pInfo in ipairs(KillerValleyHelper.playerList) do
        local updatePlayerNode = self.playerNodes[pInfo.PlayerId]
        self:setHeroPosition(pInfo.PlayerId, pInfo.CurPos)
        updatePlayerNode:setRunAngle(pInfo.Angle)
        -- 设置当前是否可战斗
        updatePlayerNode:setFightEff(pInfo.reachable == true)
        -- 设置当前是否中毒
        updatePlayerNode:setLongEffStatus(KillerValleyHelper.HeroStatus.ePoison, pInfo.poisonEff == true)
        -- 设置当前是否隐身衣
        updatePlayerNode:setLongEffStatus(KillerValleyHelper.HeroStatus.eHiding, pInfo.hidingEff == true)
        -- 设置当前是否攻防翻倍
        updatePlayerNode:setLongEffStatus(KillerValleyHelper.HeroStatus.eAttrDouble, pInfo.doubleEff == true)
        -- 自身移动的同时，更新地上光圈的位置
        if pInfo.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then
            self.mSelfCirleSprite:setPosition(pInfo.CurPos)
        end
    end

    -- 更新飞刀位置及状态
    self.flyPropNodeList = self.flyPropNodeList or {}
    local updatePropList = clone(self.flyPropNodeList)
    for _, prop in ipairs(KillerValleyHelper.flyPropList) do
        if not self.flyPropNodeList[prop.UniqueId] then
            local flyPropSprite = ui.newSprite(prop.GoodsId == 1 and "jqg_40.png" or "jqg_29.png")
            flyPropSprite:setRotation(-prop.Angle)
            self.mMapBg:addChild(flyPropSprite)
            self.flyPropNodeList[prop.UniqueId] = flyPropSprite
        end
        -- 更新飞刀的位置
        self.flyPropNodeList[prop.UniqueId]:setPosition(prop.CurPos)
        updatePropList[prop.UniqueId] = nil
    end
    -- 删除不需要更新的飞刀结点
    for key,_ in pairs(updatePropList) do
        self.flyPropNodeList[key]:removeFromParent()
        self.flyPropNodeList[key] = nil
    end

    -- 更新陷阱位置及状态
    local selfPId = PlayerAttrObj:getPlayerAttrByName("PlayerId")
    self.trapNodeList = self.trapNodeList or {}
    local updateTrapList = clone(self.trapNodeList)
    for _, trap in ipairs(KillerValleyHelper.trapInfo) do
        if not self.trapNodeList[trap.UniqueId] and trap.PlayerId == selfPId then
            local trapSprite = ui.newSprite("jqg_36.png")
            trapSprite:setPosition(trap.StartPos)
            self.mMapBg:addChild(trapSprite)
            self.trapNodeList[trap.UniqueId] = trapSprite
        end
        updateTrapList[trap.UniqueId] = nil
    end
    -- 删除不需要更新的陷阱结点
    for key,_ in pairs(updateTrapList) do
        self.trapNodeList[key]:removeFromParent()
        self.trapNodeList[key] = nil
    end

    -- 包裹拾取事件
    local function packagePickUpAction(pSender)
        local package = nil
        -- 取出当前包裹的信息
        for _, item in ipairs(KillerValleyHelper.packageInfo) do
            if item.UniqueId == pSender.tag then
                package = clone(item)
                break
            end
        end
        -- 判断是否在捡取距离之内
        local selfInfo = KillerValleyHelper:getPlayerData()
        if selfInfo and package then
            local packageDis = cc.pGetDistance(selfInfo.CurPos, package.CurPos)
            if packageDis <= KillerValleyHelper.enemyReachDistance then
                local emptyCount = KillerValleyHelper:getBagEmptyCount()
                if (package.Enum == 1) then
                    -- 侠客包
                    KillerValleyHelper:pickupProp(package.UniqueId, nil, nil)
                elseif (package.Enum == 2) or (package.Enum == 3) then
                    if emptyCount > 0 then
                        -- 道具包或掉落包
                        self.handleDlgLayer = LayerManager.addLayer({name = "killervalley.DlgPickUpLayer", data = {packageInfo = package}, cleanUp = false})
                    else
                        ui.showFlashView(TR("背包已满，请先清理背包"))
                    end
                end
            else
                ui.showFlashView(TR("距离目标太远，请先接近目标"))
            end
        end
    end

    -- 更新包裹位置
    self.packageNodeList = self.packageNodeList or {}
    local updatePackageList = clone(self.packageNodeList)
    for _, package in ipairs(KillerValleyHelper.packageInfo) do
        if not self.packageNodeList[package.UniqueId] then
            local packageImageList = {"jqg_27.png", "jqg_25.png", "jqg_26.png"}
            local packageBtn = ui.newButton({normalImage = packageImageList[package.Enum],
                position = package.CurPos,
                clickAction = packagePickUpAction})
            self.mMapBg:addChild(packageBtn)
            -- 标记包裹的ID
            packageBtn.tag = package.UniqueId
            self.packageNodeList[package.UniqueId] = packageBtn
        end
        updatePackageList[package.UniqueId] = nil
    end
    -- 删除不存在的包裹结点
    for key,_ in pairs(updatePackageList) do
        self.packageNodeList[key]:removeFromParent()
        self.packageNodeList[key] = nil
    end
end

-- 设置人物的位置
function KillerValleyMapLayer:setHeroPosition(pId, pos)
    if self.playerNodes[pId] then
        self.playerNodes[pId]:setPlayerPosition(pos)
        -- 如果是主角自己的位置变化，则移动地图
        local selfPId = PlayerAttrObj:getPlayerAttrByName("PlayerId")
        if pId == selfPId then
            local viewPercent = cc.p((pos.x - 320)/34.40, (self.mMapSize.height - pos.y - 568)/30.44)
            self.mWorldView:scrollToPercentBothDirection(viewPercent, 0, true)
            -- 设置小地图上的位置
            self.mPlayerMiniNode:setPosition(cc.p(pos.x * self.miniScalePercent, pos.y * self.miniScalePercent))
        end
    end
end

-- 创建触摸事件
function KillerValleyMapLayer:setTouchEvent()
    -- 创建操作圆盘
    self.handleNode = display.newNode()
    self.handleNode:setVisible(false)
    self.mParentLayer:addChild(self.handleNode)
    local handleBgSprite = ui.newSprite("jqg_15.png")
    self.handleNode:addChild(handleBgSprite)
    self.handleSprite = ui.newSprite("jqg_9.png")
    self.handleNode:addChild(self.handleSprite)

    local function touchBegin(touch, event)
        -- 检查网络连接状态
        if not KillerValleyHelper.socketMgr then
            MsgBoxLayer.addOKLayer(
                TR("网络连接已断开，请重新进入"),
                TR("提示"),
                {{
                    text = TR("确定"),
                    textColor = Enums.Color.eWhite,
                    clickAction = function(layerObj, btnObj)
                        KillerValleyUiHelper:exitGame(true)
                    end
                }}
            )
            return
        end
        
        local touchPos = self.mParentLayer:convertToNodeSpace(touch:getLocation())
        if touchPos.x > 500 or touchPos.y > 800 then
            return false
        end
        self.handleNode:setPosition(touchPos)
        self.handleSprite:setPosition(cc.p(0, 0))
        self.handleNode:setVisible(true)
        self.lastTouchPos = touchPos
        return true
    end
    local function touchMoved(touch, event)
        -- 处理跑动中死亡报错
        if not self.selfPlayerNode then
            return
        end
        local touchPos = self.mParentLayer:convertToNodeSpace(touch:getLocation())
        local handlePos = cc.pSub(touchPos, self.lastTouchPos)
        local touchLength = cc.pGetLength(handlePos)
        if touchLength > 76 then
            handlePos = cc.p(handlePos.x * 76 / touchLength, handlePos.y * 76 / touchLength)
        end
        if touchLength > 40 then
            -- 人物开始移动(tan22.5=0.414, tan67.5=2.414)
            local tanAngle = handlePos.y / handlePos.x
            local movingAngle = 0
            if handlePos.y > 0 and tanAngle >= 0.414 and tanAngle <= 2.414 then
                movingAngle = 45
            elseif handlePos.y > 0 and (tanAngle > 2.414 or tanAngle < -2.414) then
                movingAngle = 90
            elseif handlePos.y > 0 and tanAngle >= -2.414 and tanAngle <= -0.414 then
                movingAngle = 135
            elseif handlePos.x < 0 and tanAngle > -0.414 and tanAngle < 0.414 then
                movingAngle = 180
            elseif handlePos.y < 0 and tanAngle >= 0.414 and tanAngle <= 2.414 then
                movingAngle = 225
            elseif handlePos.y < 0 and (tanAngle > 2.414 or tanAngle < -2.414) then
                movingAngle = 270
            elseif handlePos.y < 0 and tanAngle >= -2.414 and tanAngle <= -0.414 then
                movingAngle = 315
            end
            KillerValleyHelper:playerMove(movingAngle, function () end)
            self.selfPlayerNode:setRunAngle(movingAngle)
        else
            -- 人物停止移动(angle=-1)
            KillerValleyHelper:playerMove(-1, function () end)
            self.selfPlayerNode:setRunAngle(-1)
        end
        self.handleSprite:setPosition(handlePos)
    end
    local function touchEnd(touch, event)
        -- 处理跑动中死亡报错
        if not self.selfPlayerNode then
            return
        end
        self.handleNode:setVisible(false)
        -- 通知人物停止移动(angle=-1)
        KillerValleyHelper:playerMove(-1, function () end)
        self.selfPlayerNode:setRunAngle(-1)
    end
    -- 添加触摸事件
    ui.registerSwallowTouch({
        node = self.mParentLayer,
        beganEvent = touchBegin,
        movedEvent = touchMoved,
        endedEvent = touchEnd,
        cancellEvent = touchEnd,
    })
end

-- 添加按钮图标(飞刀和道具，布阵)
function KillerValleyMapLayer:addHanderBtns()
    -- 在按钮底部创建光圈
    self.btnLightSprite = ui.newSprite("jqg_22.png")
    self.btnLightSprite:setVisible(false)
    self.mParentLayer:addChild(self.btnLightSprite)
    -- 创建“取消”按钮
    self.cancelShotBtn = ui.newButton({normalImage = "jqg_55.png", position = cc.p(392, 171)})
    self.mParentLayer:addChild(self.cancelShotBtn)
    self.cancelShotBtn:setVisible(false)
    self.cancelShotSize = self.cancelShotBtn:getContentSize()

    -- 技能背景，技能方向显示控制
    local function touchSkillAction(downOrUp, targetNode)
        -- 处理跑动中死亡报错
        if not self.selfPlayerNode then
            return
        end
        self.btnLightSprite:setVisible(downOrUp)
        self.btnHandleSprite:setVisible(downOrUp)
        self.cancelShotBtn:setVisible(downOrUp)
        self.mSelfCirleSprite:setVisible(downOrUp)
        if downOrUp then
            self.mSelfCirleSprite:setRotation(0)
            self.mSelfCirleSprite:setPosition(self.selfPlayerNode:getPosition())
            self.btnLightSprite:setPosition(targetNode:getPosition())
            self.btnLightSprite:setScale(0.5)
            self.btnLightSprite:runAction(cc.ScaleTo:create(0.15, 1.8))
        end
    end

    local btnsInfo = {{normalImage = "jqg_58.png", position = cc.p(572, 968), clickAction = function (pSender)
        -- 布阵
        self.handleDlgLayer = LayerManager.addLayer({name = "killervalley.DlgSetCampLayer", cleanUp = false})
    end}, 
    {normalImage = "tb_129.png", position = cc.p(572, 851), clickAction = function (pSender)
        -- 背包
        self.handleDlgLayer = LayerManager.addLayer({name = "killervalley.DlgPropBagLayer", cleanUp = false})
    end}, 
    -- 飞刀和银针的道具id
    {normalImage = "jqg_53.png", position = cc.p(568, 235), pId = 1}, 
    {normalImage = "jqg_54.png", position = cc.p(568, 107), pId = 2}}
    -- 创建功能图标
    self.goodsHandlerBtns = {}
    for i,btn in ipairs(btnsInfo) do
        local handlerBtn = ui.newButton(btn)
        handlerBtn:setTouchEnabled(btn.pId == nil)
        self.mParentLayer:addChild(handlerBtn)
        handlerBtn.pId = btn.pId
        -- 技能图标的大小
        local btnSize = handlerBtn:getContentSize()
        -- 飞刀和冰魄银针添加触摸事件
        if btn.pId then
            local function touchBegin(touch, event)
                local targetNode = event:getCurrentTarget()
                local touchPos = touch:getLocation()
                local targetPos = targetNode:convertToNodeSpace(touchPos)
                local isTouchInBtn = cc.rectContainsPoint(cc.rect(0, 0, btnSize.width, btnSize.height), targetPos)
                if isTouchInBtn and targetNode:isEnabled() then
                    -- 显示按钮及光圈
                    touchSkillAction(true, targetNode)
                    -- 设置初始按钮圆点的位置
                    self.btnHandleSprite:setPosition(self.mParentLayer:convertToNodeSpace(touchPos))
                    return true
                end
                return false
            end
            local function touchMoved(touch, event)
                -- 设置按钮上小圆点的位置(限制不拖出圈外)
                local targetNode = event:getCurrentTarget()
                local btnTouchPos = targetNode:convertToNodeSpace(touch:getLocation())
                local touchOffset = cc.pSub(btnTouchPos, cc.p(btnSize.width / 2, btnSize.height / 2))
                local touchLength = cc.pGetLength(touchOffset)
                if touchLength > 45 then
                    touchOffset = cc.p(touchOffset.x * 45 / touchLength, touchOffset.y * 45 / touchLength)
                end
                local btnTouchPos = cc.p(targetNode:getPosition())
                self.btnHandleSprite:setPosition(cc.p(btnTouchPos.x + touchOffset.x, btnTouchPos.y + touchOffset.y))
                -- 计算当前位置与点击位置的角度
                if touchLength > 20 then
                    local radius = cc.pToAngleSelf(touchOffset)
                    self.mSelfCirleSprite:setRotation(-radius * 180 / math.pi)
                end
            end
            local function touchEnd(touch, event)
                local touchPos = touch:getLocation()
                -- 取消按钮点击效果
                touchSkillAction(false)
                -- 释放按钮位置不能在取消按钮上
                local cancelPos = self.cancelShotBtn:convertToNodeSpace(touchPos)
                if not cc.rectContainsPoint(cc.rect(0, 0, self.cancelShotSize.width, self.cancelShotSize.height), cancelPos) then
                    local targetNode = event:getCurrentTarget()
                    -- 计算当前位置与点击位置的角度
                    local angle = -self.mSelfCirleSprite:getRotation()
                    angle = angle < 0 and (angle + 360) or angle
                    -- 向指定方向发射暗器(转换成角度)
                    KillerValleyHelper:shotProp(targetNode.pId, math.floor(angle))
                end
            end
            local function touchCancel(touch, event)
                touchSkillAction(false)
            end
            ui.registerSwallowTouch({
                node = handlerBtn,
                beganEvent = touchBegin,
                movedEvent = touchMoved,
                endedEvent = touchEnd,
                cancellEvent = touchCancel,
            })

            -- 保存按钮
            self.goodsHandlerBtns[btn.pId] = handlerBtn

            -- 道具数量是否为0都显示出来
            local countLabel = ui.newLabel({
                text = "",
                size = 20,
                -- color = ,
                outlineColor = Enums.Color.eBlack,
                outlineSize = 2,
                x = btnSize.width/2,
                y = 0,
            })
            countLabel:setAnchorPoint(0.5, 0)
            handlerBtn:addChild(countLabel)
            handlerBtn.countLabel = countLabel
            -- 设置数量
            for key, count in pairs(KillerValleyHelper.bagGoodsList) do
                if tonumber(key) == btn.pId then
                    countLabel:setString(count)
                    break
                end
            end
        end
    end

    -- 创建按钮小光圈
    self.btnHandleSprite = ui.newSprite("jqg_9.png")
    self.btnHandleSprite:setScale(0.8)
    self.btnHandleSprite:setVisible(false)
    self.mParentLayer:addChild(self.btnHandleSprite)
    
    -- 添加按钮是否可用状态更新
    Utility.schedule(self.btnHandleSprite, function ()
        for _,btn in pairs(self.goodsHandlerBtns) do
            btn:setEnabled(false)
            for key, count in pairs(KillerValleyHelper.bagGoodsList) do
                if tonumber(key) == btn.pId then
                    btn.countLabel:setVisible(count > 0)
                    if count > 0 then
                        btn:setEnabled(true)
                        btn.countLabel:setString(count)
                        break
                    end
                end
            end
        end
    end, 0)
end

-- 添加滚动信息记录窗口
function KillerValleyMapLayer:addRecordsAndRolling()
    -- 所有的信息List
    self.mRecordsList = {}
    -- 当前显示的信息List
    self.mShowList = {}
    -- 最多显示五条
    local showNum = 5
    -- 滚动时间
    local scrollTime = 0.1
    -- 每一条Label的间隔
    local gapNum = 5
    -- 灰色背景
    local boxSize = cc.size(520, 150)
    local boxBg = ui.newScale9Sprite("c_38.png", boxSize)
    boxBg:setAnchorPoint(0, 1)
    boxBg:setPosition(10, 1000)
    self.mParentLayer:addChild(boxBg)
    -- 遮罩节点
    local messageBoxSize = cc.size(boxSize.width, boxSize.height - 20)
    local messageBox = cc.ClippingNode:create()
    messageBox:setAlphaThreshold(1.0)
    messageBox:setContentSize(messageBoxSize)
    messageBox:setAnchorPoint(cc.p(0.5, 0.5))
    messageBox:setPosition(boxSize.width * 0.5, boxSize.height * 0.5)
    boxBg:addChild(messageBox)
    local stencilNode = cc.LayerColor:create(cc.c4b(255, 255, 255, 255))
    stencilNode:setAnchorPoint(cc.p(0.5, 0.5))
    stencilNode:setIgnoreAnchorPointForPosition(false)
    stencilNode:setPosition(messageBoxSize.width * 0.5, messageBoxSize.height * 0.5)
    stencilNode:setContentSize(messageBoxSize)
    messageBox:setStencil(stencilNode)
    -- 创建一条Label
    local function showRecords(text)
        local titleLabel = ui.newLabel({
            text = text,
            size = 20,
            -- color = ,
            outlineColor = Enums.Color.eBlack,
            outlineSize = 2,
            x = 10,
            y = 0,
            dimensions = cc.size(messageBoxSize.width-20, 0),
        })
        titleLabel:setAnchorPoint(cc.p(0, 0))
        messageBox:addChild(titleLabel)

        return titleLabel
    end
    -- 滚动函数
    local function scrollFunction(scrollHeight)
        local allHeight = -scrollHeight
        for i = #self.mShowList, 1, -1 do
            local node = self.mShowList[i]
            -- 停止动作
            node:stopAllActions()
            -- 重新设置位置
            node:setPosition(10, allHeight)
            -- 高度增加
            allHeight = allHeight + node:getContentSize().height + gapNum

            -- 执行上滑动作
            node:runAction(cc.Sequence:create({
                cc.MoveBy:create(scrollTime, cc.p(0, scrollHeight)), 
                cc.DelayTime:create(scrollTime),
                cc.CallFunc:create(function ()
                    -- 如果node的位置超出了背景的最高高度就设置为不可见
                    if (node:getPositionY() + node:getContentSize().height) > messageBoxSize.height then 
                        node:setVisible(false)
                    end 
                end)
            }))
        end
    end
    -- 刷新显示
    local function refreshShow( )
        -- 创建Label不添加，为了求出滚动的高度
        local titleLabel = ui.newLabel({
            text = self.mRecordsList[#self.mRecordsList],
            size = 20,
            dimensions = cc.size(messageBoxSize.width-20, 0),
        })
        local scrollHeight = titleLabel:getContentSize().height
        -- 先向上滚动
        scrollFunction(scrollHeight)
    end 

    -- 接收buff消息变化
    Notification:registerAutoObserver(boxBg, function (node, data)
        -- 最多五条
        if #self.mRecordsList >= showNum then 
            table.remove(self.mRecordsList, 1)
        end
        table.insert(self.mRecordsList, data)
        -- dump(self.mRecordsList,"self.mRecordsList")

        -- 消除最上面一个
        if #self.mShowList >= showNum then 
            if not tolua.isnull(self.mShowList[1]) then
                self.mShowList[1]:removeFromParent()
                table.remove(self.mShowList, 1)
            end
        end     
        -- 添加一个滚动信息
        local scroLabel = showRecords(self.mRecordsList[#self.mRecordsList])
        table.insert(self.mShowList, scroLabel)
        -- 刷新显示
        refreshShow()
    end, {KillerValleyHelper.Events.eNoticeMsg})
end

-- 添加毒圈蔓延倒计时
function KillerValleyMapLayer:addPoisonCircleTimeLabel()
    --剩余时间Label
    local  timeBgSize = cc.size(400, 50)
    local timeBg = ui.newScale9Sprite("c_25.png", timeBgSize)
    timeBg:setPosition(320, 1070)
    self.mParentLayer:addChild(timeBg)
    local timeLabel = ui.newLabel({
        text = "",
        -- color = cc.c3b(0xeb, 0xff, 0xc9),
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        size = 20,
    })
    -- timeLabel:setAnchorPoint(0, 0.5)
    timeLabel:setPosition(timeBgSize.width/2, timeBgSize.height/2)
    timeBg:addChild(timeLabel)

    -- 初始化倒计时
    local function updatePoisonCircleTime()
        local circleInfo = KillerValleyHelper.poisonCircle
        local poisonCircleEndTime = circleInfo.RemainTime or 0
        if poisonCircleEndTime > 0 then
            timeLabel:setString(TR("距情花障下次蔓延还有: %s%s", "#f8ea3a", MqTime.formatAsDay(poisonCircleEndTime)))
        else
            timeLabel:setString(TR("距情花障下次蔓延还有: %s00:00:00", "#f8ea3a"))
        end
        local isTimeVisible = not (circleInfo.CurRadius and circleInfo.CurRadius == 0)
        timeLabel:setVisible(isTimeVisible)
        timeBg:setVisible(isTimeVisible)
    end  
    -- dump(circleInfo,"circleInfo")
    self.mSchelTime = Utility.schedule(timeBg, function()
        updatePoisonCircleTime()
    end, 1.0)       
end

-- 注册所有服务器推送信息
function KillerValleyMapLayer:registerPushNotification()
    -- 创建毒圈
    local poisonActionTime = 1  -- 毒圈缩小动画时间
    local function createPoisonSprite(parent, relPos, relRadius, scale, annulus)
        -- 创建毒圈的显示
        local poisonSprite = KillerValleyUiHelper:createCavityCircleSprite("jqg_42.png", relPos, relRadius, poisonActionTime, annulus or 0)
        poisonSprite:setScale(self.mMapSize.width / 640 * scale)
        poisonSprite:setPosition(self.mMapSize.width / 2 * scale, self.mMapSize.height / 2 * scale)
        -- 设置毒圈最高层级(人物层级依Y坐标设定)
        parent:addChild(poisonSprite, self.mMapSize.width + 1)
        -- 毒圈闪烁
        if not annulus then
            local fadesAction = cc.Sequence:create({cc.FadeTo:create(1, 157), cc.FadeTo:create(1, 255)})
            poisonSprite:runAction(cc.RepeatForever:create(fadesAction))
        end
        return poisonSprite
    end
    -- 毒圈变化通知
    self.miniPoisonSprite = nil     -- 小地图毒圈
    self.worldPoisonSprite = nil
    Notification:registerAutoObserver(self.mPlayerMiniNode, function ()
        local circleInfo = KillerValleyHelper.poisonCircle
        if circleInfo.CurPos then
            local centerPos = cc.p(circleInfo.CurPos.x / self.mMapSize.width, circleInfo.CurPos.y / self.mMapSize.height)
            local circleRadius = circleInfo.CurRadius / self.mMapSize.width
            -- 创建小地图毒圈
            if not self.miniPoisonSprite then
                self.miniPoisonSprite = createPoisonSprite(self.miniNode, centerPos, circleRadius, self.miniScalePercent, 2 / self.miniWorldWidth)
                self.miniPoisonSprite:setColor(Enums.Color.eRed)
            else
                self.miniPoisonSprite:actionCavity(centerPos, circleRadius, poisonActionTime)
            end
            -- 创建或重设大地图毒圈
            if not self.worldPoisonSprite then 
                self.worldPoisonSprite = createPoisonSprite(self.mMapBg, centerPos, circleRadius, 1.0)
            else
                self.worldPoisonSprite:actionCavity(centerPos, circleRadius, poisonActionTime)
            end
        end
        -- 在小地图中显示毒圈
    end, {KillerValleyHelper.Events.ePoisonCircle})
    Notification:postNotification(KillerValleyHelper.Events.ePoisonCircle)
    -- 小地图下一个毒圈
    self.miniNextSprite = nil
    Notification:registerAutoObserver(self.mSelfCirleSprite, function ()
        local circleInfo = KillerValleyHelper.poisonWarning
        -- 创建下一次毒圈
        if next(circleInfo) and circleInfo.WarningTime > 0 then
            local nextBluePos = cc.p(circleInfo.NextPos.x / self.mMapSize.width, circleInfo.NextPos.y / self.mMapSize.height)
            local nextBlueRadius = circleInfo.NextRadius / self.mMapSize.width
            if not self.miniNextSprite then
                self.miniNextSprite = createPoisonSprite(self.miniNode, nextBluePos, nextBlueRadius, self.miniScalePercent, 2 / self.miniWorldWidth)
                self.miniNextSprite:setColor(Enums.Color.eBlue)
            else
                self.miniNextSprite:actionCavity(nextBluePos, nextBlueRadius, poisonActionTime)
            end
        end
        -- 在小地图中显示毒圈
    end, {KillerValleyHelper.Events.ePoisonWarning})
    Notification:postNotification(KillerValleyHelper.Events.ePoisonWarning)

    -- 某玩家死亡事件，删除战斗失败的玩家
    local deathNode = display.newNode()
    self.mParentLayer:addChild(deathNode)
    Notification:registerAutoObserver(deathNode, function (node, deathPlayerInfo)
        local losePNode = self.playerNodes[deathPlayerInfo.playerId]
        if losePNode then
            losePNode:removeFromParent()
            self.playerNodes[deathPlayerInfo.playerId] = nil
            -- 如自己死亡，则清空缓存
            if deathPlayerInfo.playerId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then
                self.selfPlayerNode = nil
            end
        end
        -- 刷新当前剩余人数
        self.livePlayerLabel:setString(TR("当前存活人数:#FFBB50%d", #KillerValleyHelper.playerList))
        -- 通知玩家显示人数少时信息提示事件
        local msgContent = TR("%s%s#ffffff潜入绝情谷失败，在原地留下一个包裹", KillerValleyHelper:getPlayerNameColor(deathPlayerInfo.playerId), deathPlayerInfo.playerName)
        Notification:postNotification(KillerValleyHelper.Events.eNoticeMsg, msgContent)
    end, {KillerValleyHelper.Events.ePlayerDeath})

    -- 结算事件
    Notification:registerAutoObserver(self.mMapBg, function ()
        -- 隐藏操作盘
        self.handleNode:setVisible(false)
        -- 删除包裹界面
        if not tolua.isnull(self.handleDlgLayer) then
            LayerManager.removeLayer(self.handleDlgLayer)
            self.handleDlgLayer = nil
        end
        -- 非吃鸡玩家，延迟显示结算，展示死亡画面
        local delayUI = #KillerValleyHelper.playerList > 1
        LayerManager.addLayer({
                name = "killervalley.KillerValleyGameEndLayer",
                cleanUp = false,
                data = {isDelay = delayUI},
            })
    end, {KillerValleyHelper.Events.eBattleResult})
end

return KillerValleyMapLayer