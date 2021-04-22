--
-- Author: Kumo.Wang
-- 图鉴列表(新版)
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogHandBookClientNew = class("QUIDialogHandBookClientNew", QUIDialog)

local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QQuickWay = import("...utils.QQuickWay")
local QActorProp = import("...models.QActorProp")
local QRichText = import("...utils.QRichText")
local QUIWidgetHandBookCellNew = import("..widgets.QUIWidgetHandBookCellNew")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QTextFiledScrollUtils = import("...utils.QTextFiledScrollUtils")

QUIDialogHandBookClientNew.RADIUS = 40
QUIDialogHandBookClientNew.FCA_START_Y = -70
QUIDialogHandBookClientNew.FCA_END_Y = 10

QUIDialogHandBookClientNew.FCA_ANIMATION_TIME = 0.7         -- 进度条变化时间
QUIDialogHandBookClientNew.TYPE_ADD_TIPS_LEVEL = "level"    -- 弹绿字的类型 图鉴等级
QUIDialogHandBookClientNew.TYPE_ADD_TIPS_POINT = "point"    -- 弹绿字的类型 总图鉴点


function QUIDialogHandBookClientNew:ctor(options)
	local ccbFile = "ccb/Dialog_Handbook_Client_New.ccbi"
	local callBack = {
        {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
        {ccbCallbackName = "onTriggerEnter", callback = handler(self, self._onTriggerEnter)},
        {ccbCallbackName = "onTriggerHelp", callback = handler(self, self._onTriggerHelp)},
        {ccbCallbackName = "onTriggerProp", callback = handler(self, self._onTriggerProp)},
        {ccbCallbackName = "onTriggerPropOverview", callback = handler(self, self._onTriggerPropOverview)},
    }
	QUIDialogHandBookClientNew.super.ctor(self, ccbFile, callBack, options)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setAllUIVisible(false)
    page:setScalingVisible(true)

    CalculateUIBgSize(self._ccbOwner.sp_bg)
    CalculateUIBgSize(self._ccbOwner.ly_mask)

    q.setButtonEnableShadow(self._ccbOwner.btn_enter)
    q.setButtonEnableShadow(self._ccbOwner.btn_help)
    q.setButtonEnableShadow(self._ccbOwner.btn_prop)
    q.setButtonEnableShadow(self._ccbOwner.btn_prop_overview)

    if page.topBar then
        page.topBar:showWithArchaeology()
    end

    self._isHandBookItemRuning = true -- 入场动效的开关（false播放，true关闭）

    self._sheetLeyoutWidth = self._ccbOwner.sheet_layout:getContentSize().width

    remote.handBook:handBookInfoRequest()

    if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.HANDBOOK) then
        app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.HANDBOOK)
    end

    --QKumo(remote.handBook.heroHandbookList)
    self:_init()
end

function QUIDialogHandBookClientNew:_checkTutorial()
    local haveTutorial = false

    if app.tutorial and app.tutorial:isTutorialFinished() == false then
        local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
        if page.buildLayer then
            page:buildLayer()
        end
        if app.tutorial:getStage().handbook == app.tutorial.Guide_Start then
            haveTutorial = app.tutorial:startTutorial(app.tutorial.Statge_Handbook)
        end
        if haveTutorial == false and page.cleanBuildLayer then
            page:cleanBuildLayer()
        end
    end

    return haveTutorial
end

function QUIDialogHandBookClientNew:_initView()
    self._propWidth = self._ccbOwner.node_mask:getContentSize().width
    self._propHeight = self._ccbOwner.node_mask:getContentSize().height
    self._propContent = self._ccbOwner.node_rtf_nextProp
    self._propPrginalPosition = ccp(self._propContent:getPosition())
    local propLayerColor = CCLayerColor:create(ccc4(0,0,0,150), self._propWidth, self._propHeight)
    local propClippingNode = CCClippingNode:create()
    propLayerColor:setPositionX(self._ccbOwner.node_mask:getPositionX())
    propLayerColor:setPositionY(self._ccbOwner.node_mask:getPositionY())
    propClippingNode:setStencil(propLayerColor)
    self._propContent:removeFromParent()
    propClippingNode:addChild(self._propContent)
    self._ccbOwner.node_prop:addChild(propClippingNode)

    self._touchLayer = QUIGestureRecognizer.new({color = false})
    self._touchLayer:attachToNode(self:getView(), self._propWidth, self._propHeight, -self._propWidth, -(self._propHeight * 5 + 25), handler(self, self._onTouchEvent))
    self._touchLayer:enable()
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self._onTouchEvent))
end

function QUIDialogHandBookClientNew:_initBallEffect()
    self._ccbOwner.node_ball_effect:removeAllChildren()

    -- 球的遮罩初始化
    local ccclippingNode = CCClippingNode:create()
    local maskDrawNode = CCDrawNode:create()
    maskDrawNode:drawCircle(self.RADIUS)
    ccclippingNode:setStencil(maskDrawNode)
    maskDrawNode:setPosition(0, 0)

    if not self._fcaAnimation then
        self._fcaAnimation = QUIWidgetFcaAnimation.new("fca/tx_jingdutiao", "res")
    end
    ccclippingNode:addChild(self._fcaAnimation)
    self._fcaAnimation:setPositionY(self.FCA_START_Y)

    self._pointFiledScroll = QTextFiledScrollUtils.new()
    self._progressFiledScroll = QTextFiledScrollUtils.new()
    
    self._ccbOwner.node_ball_effect:addChild(ccclippingNode)
end

function QUIDialogHandBookClientNew:_onTouchEvent(event)
    if event == nil or event.name == nil or not self._totalHeight then
        return
    end
    if event.name == QUIGestureRecognizer.EVENT_SLIDE_GESTURE then
    elseif event.name == "began" then
        self._startY = event.y
        self._pageY = self._propContent:getPositionY()
    elseif event.name == "moved" then
        local offsetY = self._pageY + event.y - self._startY
        if offsetY < self._propPrginalPosition.y then
            offsetY = self._propPrginalPosition.y
        elseif offsetY > (self._totalHeight - self._propHeight + self._propPrginalPosition.y) then
            offsetY = (self._totalHeight - self._propHeight + self._propPrginalPosition.y)
        else
        end
        self._propContent:setPositionY(offsetY)
    elseif event.name == "ended" then
    end
end

function QUIDialogHandBookClientNew:viewDidAppear()
	QUIDialogHandBookClientNew.super.viewDidAppear(self)
    self:addBackEvent(true)

    self:_initView()
    self:_initBallEffect()
    self:_initListView()

    local haveTutorial = self:_checkTutorial()

    if not haveTutorial then
        local actorId = self:getOptions().selectedActorId
        if actorId then
            self:_enterHandbookMainByActorId(actorId)
            self:getOptions().selectedActorId = nil
        end
    end
end

function QUIDialogHandBookClientNew:viewWillDisappear()
	QUIDialogHandBookClientNew.super.viewWillDisappear(self)
    self:removeBackEvent()
    remote.handBook.showActorId = nil

    if self._handBookItemRunInScheduler ~= nil then
        scheduler.unscheduleGlobal(self._handBookItemRunInScheduler)
        self._handBookItemRunInScheduler = nil
    end

    if self._handBookItemRunOutScheduler ~= nil then
        scheduler.unscheduleGlobal(self._handBookItemRunOutScheduler)
        self._handBookItemRunOutScheduler = nil
    end

    if self._touchLayer then
        self._touchLayer:removeAllEventListeners()
        self._touchLayer:disable()
        self._touchLayer:detach()
    end

    if self._pointFiledScroll ~= nil then
        self._pointFiledScroll:stopUpdate()
        self._pointFiledScroll = nil
    end
    if self._progressFiledScroll ~= nil then
        self._progressFiledScroll:stopUpdate()
        self._progressFiledScroll = nil
    end
end

function QUIDialogHandBookClientNew:_init()
    -- self._allHerosID = remote.handBook:getAllHerosID()
    self._onlineHerosID = remote.handBook:getOnlineHerosID()
    -- 新版不显示还未上线的英雄
    self._allHerosID = self._onlineHerosID

    self._isFirst = true
    self._multiItems = 3
end

function QUIDialogHandBookClientNew:_initListView()
    if not self._listView then
        local cfg = {
            renderItemCallBack = function( list, index, info )
                local isCacheNode = true
                local itemData = self._allHerosID[index]
                local item = list:getItemFromCache()
                if not item then
                    item = QUIWidgetHandBookCellNew.new()
                    isCacheNode = false
                end
                item:setInfo({actorId = itemData, curSelectedActorId = self._curSelectedActorId})
                info.item = item
                info.size = item:getContentSize()

                list:registerBtnHandler(index, "btn_handBookCell", handler(self, self._clickHandBookCellHandler))
                
                return isCacheNode
            end,
            isVertical = true,
            multiItems = self._multiItems,
            spaceX = 0,
            spaceY = 0,
            curOriginOffset = 0,
            enableShadow = false,
            ignoreCanDrag = true,  
            totalNumber = #self._allHerosID,
        }
        self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._listView:reload({totalNumber = #self._allHerosID})
    end

    self:_startScrollByActorId()

    self:_selectHeroByActorId()
end

function QUIDialogHandBookClientNew:_startScrollByActorId()
    local showActorId = remote.handBook.showActorId
    local pos = 0
    for i, actorId in ipairs(self._allHerosID) do
        if tostring(actorId) == tostring(showActorId) then
            pos = i
            break
        end
    end
    -- print("QUIDialogHandBookClientNew:_startScrollByActorId() showActorId = ", showActorId, pos, remote.handBook.showActorId)
    if pos > 6 then
        self._listView:startScrollToIndex(pos, false, 100, nil, -40)
    else
        self:handBookItemRunOutAction()
    end
end

function QUIDialogHandBookClientNew:handBookItemRunOutAction()
    if self._isHandBookItemRuning == true then return end
    if not self._listView then return end

    self._listView:setCanNotTouchMove(true)
    self._isHandBookItemRuning = true
    local index = 1
    while true do
        local item = self._listView:getItemByIndex(index)
        if item then
            local posx, posy = item:getPosition()
            item:setPosition(ccp(posx + self._sheetLeyoutWidth * 2, posy))  
            index = index + 1
        else
            break
        end 
    end

    self._totalCell = index - 1

    self.func1 = function()
        self._handBookItemRunInScheduler = scheduler.performWithDelayGlobal(function()
            if self:safeCheck() then
                self:handBookItemRunInAction()
            end
        end, 0.02)
    end
    self.func1()
end 

function QUIDialogHandBookClientNew:handBookItemRunInAction()
    if self._isHandBookItemRuning == false then return end
    if not self._listView then return end

    local time = 0.14
    local i = 1
    self.func2 = function()
        if i <= self._multiItems then
            local item1 = self._listView:getItemByIndex(i)
            local item2 = self._listView:getItemByIndex(i + self._multiItems)
            local item3 = self._listView:getItemByIndex(i + self._multiItems * 2)

            if item1 ~= nil then
                local array1 = CCArray:create()
                array1:addObject(CCCallFunc:create(function()
                        makeNodeFadeToOpacity(item1, time)
                    end))

                array1:addObject(CCEaseSineOut:create(CCMoveBy:create(time, ccp(-self._sheetLeyoutWidth * 2, 0))))

                local array2 = CCArray:create()
                array2:addObject(CCSpawn:create(array1))
                item1:runAction(CCSequence:create(array2))
            end

            if item2 ~= nil then
                local array1 = CCArray:create()
                array1:addObject(CCCallFunc:create(function()
                        makeNodeFadeToOpacity(item2, time)
                    end))
                array1:addObject(CCEaseSineOut:create(CCMoveBy:create(time, ccp(-self._sheetLeyoutWidth * 2, 0))))

                local array2 = CCArray:create()
                array2:addObject(CCDelayTime:create(0.08))
                array2:addObject(CCSpawn:create(array1))
                item2:runAction(CCSequence:create(array2))
            end

            if item3 ~= nil then
                local array1 = CCArray:create()
                array1:addObject(CCCallFunc:create(function()
                        makeNodeFadeToOpacity(item3, time)
                    end))
                array1:addObject(CCEaseSineOut:create(CCMoveBy:create(time, ccp(-self._sheetLeyoutWidth * 2, 0))))

                local array2 = CCArray:create()
                array2:addObject(CCDelayTime:create(0.08 * 2))
                array2:addObject(CCSpawn:create(array1))
                item3:runAction(CCSequence:create(array2))
            end

            i = i + 1
            self._handBookItemRunOutScheduler = scheduler.performWithDelayGlobal(self.func2, 0.05)
        else
            self._isHandBookItemRuning = false

            local index = self._multiItems * 3 + 1
            while true do
                local item = self._listView:getItemByIndex(index)
                if item then
                    local posx, posy = item:getPosition()
                    item:setPosition(ccp(posx - self._sheetLeyoutWidth * 2, posy))  
                    index = index + 1
                else
                    break
                end 
            end

            self._listView:setCanNotTouchMove(false)
        end
    end

    self.func2()
end 

function QUIDialogHandBookClientNew:_clickHandBookCellHandler( x, y, touchNode, listView )
    if self._isPlaying then return end

    app.sound:playSound("common_others")
    local touchIndex = listView:getCurTouchIndex()
    local selectActorId = self._allHerosID[touchIndex]
    self:_selectHeroByActorId(selectActorId, touchIndex)
end

function QUIDialogHandBookClientNew:_selectHeroByActorId( actorId, touchIndex )
    local isUpdate = false
    if actorId ~= self._curSelectedActorId then
        self._curSelectedActorId = actorId
        self._curTouchIndex = touchIndex
        isUpdate = true
    end
    if not self._curSelectedActorId then
        self._curSelectedActorId = remote.handBook.showActorId or self._allHerosID[1]
        isUpdate = true
    end

    self._listView:refreshData()

    print("[QUIDialogHandBookClientNew:_selectHeroByActorId()] self._curSelectedActorId = ", self._curSelectedActorId)
    if isUpdate and self._curSelectedActorId then
        self:_update()
    end
end

function QUIDialogHandBookClientNew:_update()
    if not self._curSelectedActorId then return end

    self:_updateBgView()
    self:_updateActorImgView()
    self:_updateHandbookLevelView()
    self:_updateHandbookPointView()
    self:_updateButtonState()
end

function QUIDialogHandBookClientNew:_updateBgView()
    if not self._curSelectedActorId then return end
    local aptitudeInfo = remote.handBook:getHeroAptitudeInfoByActorID(self._curSelectedActorId)
    if aptitudeInfo.aptitude <= APTITUDE.S then
        QSetDisplayFrameByPath(self._ccbOwner.sp_bg, QResPath("handbook_bg")[1])
    else
        QSetDisplayFrameByPath(self._ccbOwner.sp_bg, QResPath("handbook_bg")[2])
    end
end

function QUIDialogHandBookClientNew:_updateActorImgView()
    local state = remote.handBook:getHandbookStateByActorID(self._curSelectedActorId)
    print("[QUIDialogHandBookClientNew:_updateActorImgView()] state = ", state)
    self._ccbOwner.ly_mask:setVisible(state == remote.handBook.STATE_NONE or state == remote.handBook.STATE_ACTIVATION)

    -- local heroInfo = remote.herosUtil:getHeroByID(tostring(self._curSelectedActorId))
    -- QKumo(heroInfo)
    local card = "icon/hero_card/art_snts.png"
    local x = 0
    local y = 0
    local scale = 1
    local rotation = 0
    local turn = 1
    local _cardPath = ""

    -- if heroInfo and heroInfo.skinId and heroInfo.skinId > 0 then
    --     local skinConfig = remote.heroSkin:getHeroSkinBySkinId(tostring(self._curSelectedActorId), heroInfo.skinId)
    --     if skinConfig and skinConfig.fightEnd_card then
    --         print("显示皮肤原画")
    --         _cardPath = skinConfig.fightEnd_card
    --         if skinConfig.fightEnd_display then
    --             local skinDisplaySetConfig = remote.heroSkin:getSkinDisplaySetConfigById(skinConfig.fightEnd_display)
    --             x = skinDisplaySetConfig.x or 0
    --             y = skinDisplaySetConfig.y or 0
    --             scale = skinDisplaySetConfig.scale or 1
    --             rotation = skinDisplaySetConfig.rotation or 0
    --             turn = skinDisplaySetConfig.isturn or 1
    --         end
    --     end
    -- end
    if _cardPath == "" then
        local dialogDisplayConfig = remote.handBook:getDialogDisplayByActorID(self._curSelectedActorId)
        -- QKumo(dialogDisplayConfig)
        if dialogDisplayConfig and dialogDisplayConfig.handbook_Bg_card then
            print("显示默认原画")
            card = dialogDisplayConfig.handbook_Bg_card
            x = dialogDisplayConfig.handbook_Bg_x
            y = dialogDisplayConfig.handbook_Bg_y
            scale = dialogDisplayConfig.handbook_Bg_scale
            rotation = dialogDisplayConfig.handbook_Bg_rotation
            turn = dialogDisplayConfig.handbook_Bg_isturn
        end
    else
        card = _cardPath
    end

    local sprite = CCSprite:create(card)
    if sprite then
        self._ccbOwner.node_actor_img:removeAllChildren()
        sprite:setPosition(x, y)
        sprite:setScaleX(scale*turn)
        sprite:setScaleY(scale)
        sprite:setRotation(rotation)
        self._ccbOwner.node_actor_img:addChild(sprite)
    else
        assert(false, "<<<"..card..">>>not exist!")
    end
end

function QUIDialogHandBookClientNew:_updateHandbookLevelView()
    local gradeLevel = remote.handBook:getHandbookLevelByActorID(self._curSelectedActorId)
    if gradeLevel >= 0 then
        self._ccbOwner.tf_curGradeLevel:setString(gradeLevel)
        self._ccbOwner.node_curGradeLevel:setVisible(true)
    else
        self._ccbOwner.node_curGradeLevel:setVisible(false)
    end

    local bTLevel = remote.handBook:getHandbookBreakthroughLevelByActorID(self._curSelectedActorId)
    if bTLevel > 0 then
        self._ccbOwner.tf_curBTLevel:setString(bTLevel)
        self._ccbOwner.node_curBTLevel:setVisible(true)
    else
        self._ccbOwner.node_curBTLevel:setVisible(false)
    end
end

-- 图鉴点变化时显示tips  showType：level,point
function QUIDialogHandBookClientNew:_showPointAddTips(showType, content, callback)
    if self["_effect_" .. showType] ~= nil then 
        self["_effect_" .. showType]:disappear()
        self["_effect_" .. showType] = nil
    end
    self["_effect_" .. showType] = QUIWidgetAnimationPlayer.new()
    self._ccbOwner["node_add_tip_" .. showType]:addChild(self["_effect_" .. showType])
    self["_effect_" .. showType]:playAnimation("effects/Tips_add.ccbi", function(ccbOwner)
        ccbOwner.content:setString(content)
    end, function()
        self["_effect_" .. showType]:disappear()
        if callback then
            callback()
        end
    end)
end

-- 显示更新进度的动画 开始进度 结束进度 结束进度时等级的最大进度 开始等级 结束等级 结束等级后要达到的进度比例值
function QUIDialogHandBookClientNew:_showUpdatePointAnimation(startPoint, endPoint, maxPoint, startLevel, endLevel, proportion)
    -- 最终曝光动画
    local lightCallback = function(curProportion)
        if self._fcaEffectccb ~= nil then
            self._fcaEffectccb:disappear()
            self._fcaEffectccb = nil
        end
        self._fcaEffectccb = QUIWidgetAnimationPlayer.new()
        self._ccbOwner.node_ball_up_effect:addChild(self._fcaEffectccb)
        local effectName = "effects/hg_upgrade_1.ccbi"
        self._fcaEffectccb:setPositionY(QUIDialogHandBookClientNew.RADIUS * curProportion * 2)
        self._fcaEffectccb:setScale(0.8)
        self._fcaEffectccb:playAnimation(effectName,nil,function()
            self._fcaEffectccb:disappear()
            local curEpicPropConfig = remote.handBook:getCurAndOldEpicPropConfig()
            if self._oldEpicConfig and curEpicPropConfig and self._oldEpicConfig.epic_level < curEpicPropConfig.epic_level then
                scheduler.performWithDelayGlobal(function()
                app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHandbookEpicLevelUpSuccess", 
                options = {oldEpicConfig = self._oldEpicConfig}})
                self._oldEpicConfig = remote.handBook:getCurAndOldEpicPropConfig()
                end, 0)
            end
        end)
    end

    -- fca进度动画
    local updateFcaPosition = function(loopCount, curProportion)
        loopCount = loopCount or 0
        local useTime = QUIDialogHandBookClientNew.FCA_ANIMATION_TIME / (loopCount + 1)
        local curPoint = startPoint
        local fcaArr = CCArray:create()
        local tfArr = CCArray:create()
        for i = 1, loopCount do
            fcaArr:addObject(CCMoveTo:create(useTime, ccp(0.0, self.FCA_END_Y)))
            fcaArr:addObject(CCCallFunc:create(function() self._fcaAnimation:setPositionY(self.FCA_START_Y) end))

            tfArr:addObject(CCCallFunc:create(function()
                local config = remote.handBook:getEpicPropConfigByLevel(startLevel + i)
                local nextPoint = 0
                if startLevel + i == 1 then
                    nextPoint = config.handbook_score_num
                else
                    local lastConfig = remote.handBook:getEpicPropConfigByLevel(startLevel + i - 1)
                    nextPoint = config.handbook_score_num - lastConfig.handbook_score_num
                end
                
                if config.handbook_score_num then
                    self._progressFiledScroll:addUpdate(curPoint, nextPoint, function(value)
                        self._ccbOwner.tf_handbook_progress:setString(string.format("%d/%d", math.ceil(value), nextPoint))
                    end, useTime)
                    curPoint = 0
                end
            end))
            tfArr:addObject(CCDelayTime:create(useTime))
        end
        local targetPosY = self.FCA_START_Y + (self.FCA_END_Y - self.FCA_START_Y) * curProportion
        fcaArr:addObject(CCMoveTo:create(useTime, ccp(0.0, targetPosY)))
        fcaArr:addObject(CCCallFunc:create(function()
            lightCallback(curProportion)
        end))
        tfArr:addObject(CCCallFunc:create(function()
            self._progressFiledScroll:addUpdate(curPoint, endPoint, function(value)
                self._ccbOwner.tf_handbook_progress:setString(string.format("%d/%d", math.ceil(value), maxPoint))
            end, useTime)
        end))
        self._fcaAnimation:stopAllActions()
        self._fcaAnimation:runAction(CCSequence:create(fcaArr))

        self._ccbOwner.tf_handbook_progress:stopAllActions()
        self._ccbOwner.tf_handbook_progress:runAction(CCSequence:create(tfArr))
    end

    if endLevel > startLevel then
        --不飘等级了
        --self:_showPointAddTips(QUIDialogHandBookClientNew.TYPE_ADD_TIPS_LEVEL, string.format("LV +%d", levelDiff))
    end

    self:_showPointAddTips(QUIDialogHandBookClientNew.TYPE_ADD_TIPS_POINT, string.format("总图鉴点 +%d", (self._curHandbookPoint - self._lastHandbookPoint)), function()
        updateFcaPosition(endLevel - startLevel, proportion)
    end)
    -- 总图鉴点文本变更
    self._pointFiledScroll:addUpdate(self._lastHandbookPoint, self._curHandbookPoint, function(value)
        self._ccbOwner.tf_handbook_point:setString(tostring(math.ceil(value)))
    end, 1.0)
end

function QUIDialogHandBookClientNew:_updateHandbookPointView()
    local curEpicPropConfig = remote.handBook:getCurAndOldEpicPropConfig()
    local subScore = 0
    local curLevel = 0
    self._curHandbookPoint = remote.handBook.handbookEpicPoint

    if not q.isEmpty(curEpicPropConfig) then
        curLevel = curEpicPropConfig.epic_level
        self._ccbOwner.tf_handbook_level:setString("LV. "..curLevel)
        self._ccbOwner.tf_nextProp_title:setString("图鉴等级属性加成")
        self._ccbOwner.node_level_0:setVisible(false)

        self:_showProp(curEpicPropConfig)
        subScore = curEpicPropConfig.handbook_score_num or 0
    end

    local doUpdate = function()
        -- 进度条
        local nextEpicPropConfig = remote.handBook:getNextEpicPropConfig()
        local curProportion = 1
        local curProgress = 0
        local nextProgress = 0
        if q.isEmpty(nextEpicPropConfig) then
            -- 满级
            curProportion = 1
            curProgress = self._curHandbookPoint
            nextProgress = subScore

        else
            curProgress = self._curHandbookPoint - subScore
            nextProgress = nextEpicPropConfig.handbook_score_num - subScore
            curProportion = curProgress/nextProgress
            if curProportion > 1 then curProportion = 1 end
        end

        if self._fcaAnimation then
            if not self._lastLevel then
                self._lastLevel = curLevel
            end

            if not self._lastHandbookPoint then
                self._lastHandbookPoint = self._curHandbookPoint
            end

            if not self._lastProgress then
                self._lastProgress = curProgress
            end

            -- if self._lastHandbookPoint < self._curHandbookPoint then
            --     self:_showUpdatePointAnimation(self._lastProgress, curProgress, nextProgress, self._lastLevel, curLevel, curProportion)
            --     self._lastHandbookPoint = self._curHandbookPoint
            --     self._lastProgress = curProgress
            --     self._lastLevel = curLevel
            -- elseif self._isFirst then
            --     self._isFirst = false
            self._ccbOwner.tf_handbook_progress:setString(curProgress.."/"..nextProgress)
            self._fcaAnimation:setPositionY(self.FCA_START_Y + (self.FCA_END_Y - self.FCA_START_Y) * curProportion)
            self._ccbOwner.tf_handbook_point:setString(self._curHandbookPoint)
            -- end

            if self._oldEpicConfig and curEpicPropConfig and self._oldEpicConfig.epic_level < curEpicPropConfig.epic_level then
                scheduler.performWithDelayGlobal(function()
                app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHandbookEpicLevelUpSuccess", 
                options = {oldEpicConfig = self._oldEpicConfig, callback = doUpdate}})
                self._oldEpicConfig = remote.handBook:getCurAndOldEpicPropConfig()
                end, 0)
            end
        end
    end


    -- if self._oldEpicConfig and curEpicPropConfig and self._oldEpicConfig.epic_level < curEpicPropConfig.epic_level then
    --     scheduler.performWithDelayGlobal(function()
    --         app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHandbookEpicLevelUpSuccess", 
    --         options = {oldEpicConfig = self._oldEpicConfig, callback = doUpdate}})
    --     self._oldEpicConfig = remote.handBook:getCurAndOldEpicPropConfig()
    --     end, 0)
    -- else
    --     doUpdate()
    -- end

    doUpdate()
end


function QUIDialogHandBookClientNew:_showProp( propConfig )
    self._propContent:removeAllChildren()
    local richTextTbl1 = {}
    local richTextTbl2 = {}
    local propFields = QActorProp:getPropFields()
    local maxWidth = 0
    local fontSize = 18
    local index = 0
    for key, value in pairs(propConfig) do
        if propFields[key] and value > 0 then
            index = index + 1
            local nameStr = propFields[key].handbookName or propFields[key].uiName or propFields[key].name
            if remote.handBook.battlePropKey[key] then
                nameStr = remote.handBook.battlePropKey[key].preName..nameStr
            end
            local valueStr = q.getFilteredNumberToString(value, propFields[key].isPercent, 1)
            if index % 2 == 0 then
                if not q.isEmpty(richTextTbl2) then
                    table.insert(richTextTbl2, {oType = "wrap"})
                end
                table.insert(richTextTbl2, {oType = "font", content = nameStr, size = fontSize, color = COLORS.a})
                table.insert(richTextTbl2, {oType = "font", content = "+"..valueStr, size = fontSize, color = COLORS.b})
            else
                if not q.isEmpty(richTextTbl1) then
                    table.insert(richTextTbl1, {oType = "wrap"})
                end
                table.insert(richTextTbl1, {oType = "font", content = nameStr, size = fontSize, color = COLORS.a})
                table.insert(richTextTbl1, {oType = "font", content = "+"..valueStr, size = fontSize, color = COLORS.b})
            end
            local str = CCLabelTTF:create(nameStr.."+"..valueStr.."  ", global.font_default, fontSize)
            local width = str:getContentSize().width
            if width > maxWidth then
                maxWidth = width
            end
        end
    end
    if q.isEmpty(richTextTbl1) and q.isEmpty(richTextTbl2) then
        self._ccbOwner.node_level_0:setVisible(true)
    else
        local maxHeight = 0
        local richTextNode1 = QRichText.new(nil, maxWidth, {autoCenter = false, lineSpacing = -2})
        richTextNode1:setString(richTextTbl1)
        richTextNode1:setAnchorPoint(ccp(0, 1))
        self._propContent:addChild(richTextNode1)
        if maxHeight < richTextNode1:getContentSize().height then
            maxHeight = richTextNode1:getContentSize().height
        end

        local richTextNode2 = QRichText.new(nil, nil, {autoCenter = false, lineSpacing = -2})
        richTextNode2:setString(richTextTbl2)
        richTextNode2:setAnchorPoint(ccp(0, 1))
        self._propContent:addChild(richTextNode2)
        if maxHeight < richTextNode2:getContentSize().height then
            maxHeight = richTextNode2:getContentSize().height
        end

        if richTextNode2:getContentSize().width < maxWidth then
            local offsetX = maxWidth - richTextNode2:getContentSize().width
            richTextNode1:setPositionX(-maxWidth + offsetX/2)
            richTextNode2:setPositionX(offsetX/2)
        end

        local totalHeight = math.abs(self._propContent:getPositionY()) + maxHeight
        self._totalHeight = totalHeight
    end
end

function QUIDialogHandBookClientNew:_updateButtonState()
    if not self._curSelectedActorId then
        self._ccbOwner.ccb_btn_ok_effect:setVisible(false)
        self._ccbOwner.node_ok:setVisible(false)
        return
    end
    self._ccbOwner.node_ok:setVisible(true)

    local state = remote.handBook:getHandbookStateByActorID(self._curSelectedActorId)
    if state == remote.handBook.STATE_NONE or state == remote.handBook.STATE_ACTIVATION then
        self._ccbOwner.tf_btn_ok:setString("激 活")
        local spFrame = QSpriteFrameByPath("ui/update_common/button.plist/btn_normal_orange_jinbian.png")
        self._ccbOwner.btn_ok:setBackgroundSpriteFrameForState(spFrame, CCControlStateNormal)
        self._ccbOwner.btn_ok:setBackgroundSpriteFrameForState(spFrame, CCControlStateHighlighted)
        self._ccbOwner.btn_ok:setBackgroundSpriteFrameForState(spFrame, CCControlStateDisabled)
    elseif state == remote.handBook.STATE_GRADE_UP then
        self._ccbOwner.tf_btn_ok:setString("升 星")
        local spFrame = QSpriteFrameByPath("ui/update_common/button.plist/btn_normal_orange_jinbian.png")
        self._ccbOwner.btn_ok:setBackgroundSpriteFrameForState(spFrame, CCControlStateNormal)
        self._ccbOwner.btn_ok:setBackgroundSpriteFrameForState(spFrame, CCControlStateHighlighted)
        self._ccbOwner.btn_ok:setBackgroundSpriteFrameForState(spFrame, CCControlStateDisabled)
    elseif state == remote.handBook.STATE_BREAK_THROUGH then
        self._ccbOwner.tf_btn_ok:setString("界限突破")
        local spFrame = QSpriteFrameByPath("ui/update_common/button.plist/btn_stress_yellow.png")
        self._ccbOwner.btn_ok:setBackgroundSpriteFrameForState(spFrame, CCControlStateNormal)
        self._ccbOwner.btn_ok:setBackgroundSpriteFrameForState(spFrame, CCControlStateHighlighted)
        self._ccbOwner.btn_ok:setBackgroundSpriteFrameForState(spFrame, CCControlStateDisabled)
    else
        self._ccbOwner.node_ok:setVisible(false)
    end

    local isRedTips = remote.handBook:isRedTipsForHeroHandbook(self._curSelectedActorId)
    self._ccbOwner.ccb_btn_ok_effect:setVisible(isRedTips)
end

function QUIDialogHandBookClientNew:_enterHandbookMainByActorId(selectActorId)
    -- 选择英雄
    local selectActorId = tostring(selectActorId)
    local pos = 0
    for i, actorId in ipairs(self._onlineHerosID) do
        if actorId == selectActorId then
            pos = i
            break
        end
    end
    if pos > 0 then
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHandBookMain",
            options = {herosID = self._onlineHerosID, pos = pos}})
    else
        app.tip:floatTip("敬请期待")
    end
end

function QUIDialogHandBookClientNew:_onTriggerOK(event)
    if self._isPlaying then return end
    if q.buttonEventShadow(event, self._ccbOwner.btn_ok) == false then return end
    if event ~= nil then app.sound:playSound("common_small") end
    
    local callback = function(actorId, state)
        if self:safeCheck() then
            if state == remote.handBook.STATE_NONE or state == remote.handBook.STATE_ACTIVATION then
                self._ccbOwner.node_bg_effect:removeAllChildren()
                local fcaAnimation = QUIWidgetFcaAnimation.new("fca/hstj_jh_1", "res")
                fcaAnimation:playAnimation("animation", false)
                self._ccbOwner.node_bg_effect:addChild(fcaAnimation)
                fcaAnimation:setEndCallback(function( )
                    fcaAnimation:removeFromParent()
                    if self:safeCheck() then
                        self:_update()
                    end
                end)
            else
                self:_update()
            end

            if self._curTouchIndex then
                local item = self._listView:getItemByIndex(self._curTouchIndex)
                if item and item.getActorId then
                    if item:getActorId() == tonumber(self._curSelectedActorId) then
                        item:refreshInfo()
                    end
                end
            else
                remote.handBook.showActorId = actorId
                self:_initListView()
            end
        end
    end

    self._oldEpicConfig = remote.handBook:getCurAndOldEpicPropConfig()
    remote.handBook:openHandbookDialog(self._curSelectedActorId, callback)
end

function QUIDialogHandBookClientNew:_onTriggerEnter(event)
    if event ~= nil then app.sound:playSound("common_small") end
    self:_enterHandbookMainByActorId(self._curSelectedActorId)
end

function QUIDialogHandBookClientNew:_onTriggerHelp(event)
    if event ~= nil then app.sound:playSound("common_small") end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRatFestivalHelp", options = {helpType = "hero_handbook_help"}})
end

function QUIDialogHandBookClientNew:_onTriggerProp(event)
    if event ~= nil then app.sound:playSound("common_small") end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHandbookPropInfo", options = {title = "已激活属性", showType = remote.handBook.TYPE_ALL_PROP}})
end

function QUIDialogHandBookClientNew:_onTriggerPropOverview(event)
    if event ~= nil then app.sound:playSound("common_small") end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHandbookPropInfo", options = {title = "图鉴等级属性", showType = remote.handBook.TYPE_EPIC_PROP}})
end

function QUIDialogHandBookClientNew:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_SPECIFIC_CONTROLLER, nil, self)
end

return QUIDialogHandBookClientNew