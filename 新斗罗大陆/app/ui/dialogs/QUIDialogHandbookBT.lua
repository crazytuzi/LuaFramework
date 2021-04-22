--
-- Kumo.Wang
-- 新版魂师图鉴激活、升星界面
--

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogHandbookBT = class("QUIDialogHandbookBT", QUIDialog)

local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QUIViewController = import("..QUIViewController")
local QActorProp = import("...models.QActorProp")
local QQuickWay = import("...utils.QQuickWay")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QUIViewController = import("..QUIViewController")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

function QUIDialogHandbookBT:ctor(options)
    local ccbFile = "ccb/Dialog_Handbook_BT.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
        {ccbCallbackName = "onTriggerInfo", callback = handler(self, self._onTriggerInfo)},
    }
    QUIDialogHandbookBT.super.ctor(self,ccbFile,callBacks,options)
    self.isAnimation = true

    if options then
        self._actorId = options.actorId
        self._callback = options.callback
    end

    self._ccbOwner.frame_tf_title:setString("图鉴突破")

    q.setButtonEnableShadow(self._ccbOwner.btn_ok)
    q.setButtonEnableShadow(self._ccbOwner.btn_info)

    self:_init()
    self:_refreshInfo()
end

function QUIDialogHandbookBT:_initView()
    self._totalHeight = 235

    self._oldWidth = self._ccbOwner.node_old_mask:getContentSize().width
    self._oldHeight = self._ccbOwner.node_old_mask:getContentSize().height
    self._oldContent = self._ccbOwner.node_old_prop
    self._oldPrginalPosition = ccp(self._oldContent:getPosition())
    local oldLayerColor = CCLayerColor:create(ccc4(0,0,0,150), self._oldWidth, self._oldHeight)
    local oldClippingNode = CCClippingNode:create()
    oldLayerColor:setPositionX(self._ccbOwner.node_old_mask:getPositionX())
    oldLayerColor:setPositionY(self._ccbOwner.node_old_mask:getPositionY())
    oldClippingNode:setStencil(oldLayerColor)
    self._oldContent:removeFromParent()
    oldClippingNode:addChild(self._oldContent)
    self._ccbOwner.node_old:addChild(oldClippingNode)

    self._newWidth = self._ccbOwner.node_new_mask:getContentSize().width
    self._newHeight = self._ccbOwner.node_new_mask:getContentSize().height
    self._newContent = self._ccbOwner.node_new_prop
    self._newPrginalPosition = ccp(self._newContent:getPosition())
    local newLayerColor = CCLayerColor:create(ccc4(0,0,0,150), self._newWidth, self._newHeight)
    local newClippingNode = CCClippingNode:create()
    newLayerColor:setPositionX(self._ccbOwner.node_new_mask:getPositionX())
    newLayerColor:setPositionY(self._ccbOwner.node_new_mask:getPositionY())
    newClippingNode:setStencil(newLayerColor)
    self._newContent:removeFromParent()
    newClippingNode:addChild(self._newContent)
    self._ccbOwner.node_new:addChild(newClippingNode)

    self._allWidth = self._ccbOwner.node_all_mask:getContentSize().width
    self._allHeight = self._ccbOwner.node_all_mask:getContentSize().height

    self._touchLayer = QUIGestureRecognizer.new({color = false})
    self._touchLayer:attachToNode(self:getView(), self._allWidth, self._allHeight, -(self._allWidth)/2, -(self._allHeight/2 + 35), handler(self, self._onTouchEvent))
    self._touchLayer:enable()
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self._onTouchEvent))
end

function QUIDialogHandbookBT:viewDidAppear()
    QUIDialogHandbookBT.super.viewDidAppear(self)

    self:_initView()
end 

function QUIDialogHandbookBT:_onTouchEvent(event)
    if event == nil or event.name == nil then
        return
    end
    if event.name == QUIGestureRecognizer.EVENT_SLIDE_GESTURE then
    elseif event.name == "began" then
        self._startY = event.y
        self._pageY = self._oldContent:getPositionY()
    elseif event.name == "moved" then
        local offsetY = self._pageY + event.y - self._startY
        if offsetY < self._oldPrginalPosition.y then
            offsetY = self._oldPrginalPosition.y
        elseif offsetY > (self._totalHeight - self._oldHeight + self._oldPrginalPosition.y) then
            offsetY = (self._totalHeight - self._oldHeight + self._oldPrginalPosition.y)
        else
        end
        self._oldContent:setPositionY(offsetY)
        self._newContent:setPositionY(offsetY)
    elseif event.name == "ended" then
    end
end

function QUIDialogHandbookBT:viewWillDisappear()
    QUIDialogHandbookBT.super.viewWillDisappear(self)

    if self._touchLayer then
        self._touchLayer:removeAllEventListeners()
        self._touchLayer:disable()
        self._touchLayer:detach()
    end
end

function QUIDialogHandbookBT:_init()
    if not self._actorId then return end
    local characterConfig = remote.handBook:getHeroInfoByActorID(self._actorId)
    if q.isEmpty(characterConfig) then return end

    -- 头像
    local heroHead = QUIWidgetHeroHead.new()
    local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
    if heroInfo then
        heroHead:setHeroSkinId(heroInfo.skinId)
    end
    heroHead:setHero(self._actorId)
    heroHead:setStarVisible(false)
    heroHead:hideSabc()
    -- heroHead:setBreakthrough(heroInfo.breakthrough)
    -- heroHead:setGodSkillShowLevel(heroInfo.godSkillGrade)
    self._ccbOwner.node_head:addChild(heroHead)

    -- 名字
    self._ccbOwner.tf_name:setString(characterConfig.name)

    -- 按钮文字
    self._ccbOwner.tf_btn_ok:setString("突 破")
end

function QUIDialogHandbookBT:_refreshInfo()
    self._showType = remote.handBook:getHandbookStateByActorID(self._actorId)

    -- 说明
    local curHandbookBreakthroughLevel = remote.handBook:getHandbookBreakthroughLevelByActorID(self._actorId)
    self._ccbOwner.tf_tips:setString("消耗碎片，将魂师的突破等级提升到"..(curHandbookBreakthroughLevel + 1).."级。")

    -- 魂师碎片
    self._ccbOwner.node_item:removeAllChildren()
    local gradeConfig = db:getStaticByName("grade")
    local curGradeConfig = gradeConfig[tostring(self._actorId)]
    if not q.isEmpty(curGradeConfig) then
        self._itemId = curGradeConfig[1].soul_gem
        local itemBox = QUIWidgetItemsBox.new()
        itemBox:setGoodsInfo(self._itemId, ITEM_TYPE.ITEM, 0)
        itemBox:hideSabc()
        itemBox:hideTalentIcon()
        self._ccbOwner.node_item:addChild(itemBox)
    end

    -- 前后对比
    if curHandbookBreakthroughLevel < 1 then
        self._ccbOwner.node_old_prop:setVisible(false)
        self._ccbOwner.tf_no_prop:setVisible(true)
        self._ccbOwner.tf_old_title:setString("图鉴未突破")
        self._ccbOwner.tf_new_title:setString("突破1级")
    else
        self._ccbOwner.node_old_prop:setVisible(true)
        self._ccbOwner.tf_no_prop:setVisible(false)
        self._ccbOwner.tf_old_title:setString("突破"..curHandbookBreakthroughLevel.."级")
        self._ccbOwner.tf_new_title:setString("突破"..(curHandbookBreakthroughLevel + 1).."级")
        self:_showCurProp()
    end

    self:_showNextProp()

    local isReady = remote.handBook:isReadyBreakthroughByActorId(self._actorId)
    if isReady then
        makeNodeFromGrayToNormal(self._ccbOwner.node_ok)
        self._ccbOwner.tf_btn_ok:enableOutline()
    else
        makeNodeFromNormalToGray(self._ccbOwner.node_ok)
        self._ccbOwner.tf_btn_ok:disableOutline() 
    end
    self._ccbOwner.ccb_btn_ok_effect:setVisible(isReady)
end

function QUIDialogHandbookBT:_showCurProp()
    local curHandbookBreakthroughLevel = remote.handBook:getHandbookBreakthroughLevelByActorID(self._actorId)
    local config = remote.handBook:getCurHandbookBTConfigByActorId(self._actorId, curHandbookBreakthroughLevel)
    if q.isEmpty(config) then 
        self._ccbOwner.node_old_prop:setVisible(false)
        return 
    end
    local propFields = QActorProp:getPropFields()
    local index = 1
    for key, value in pairs(config) do
        if propFields[key] then
            local tfTitle = self._ccbOwner["tf_old_title_"..index]
            local tfProp = self._ccbOwner["tf_old_prop_"..index]
            if tfTitle and tfProp then
                local nameStr = propFields[key].uiName or propFields[key].name
                local valueStr = q.getFilteredNumberToString(value, propFields[key].isPercent, 1)
                tfTitle:setString(nameStr.."：")
                tfTitle:setVisible(true)

                tfProp:setString("+"..valueStr)
                tfProp:setVisible(true)
                index = index + 1
            else
                break
            end
        end
    end

    while true do
        local tfTitle = self._ccbOwner["tf_old_title_"..index]
        local tfProp = self._ccbOwner["tf_old_prop_"..index]
        if tfTitle and tfProp then
            tfTitle:setVisible(false)
            tfProp:setVisible(false)
            index = index + 1
        else
            break
        end
    end
end

function QUIDialogHandbookBT:_showNextProp()
    local curHandbookBreakthroughLevel = remote.handBook:getHandbookBreakthroughLevelByActorID(self._actorId)
    local config = remote.handBook:getCurHandbookBTConfigByActorId(self._actorId, curHandbookBreakthroughLevel + 1)
    if q.isEmpty(config) then 
        self._ccbOwner.node_new_prop:setVisible(false)
        self._ccbOwner.tf_new_title:setString("MAX")
        return 
    end
    local propFields = QActorProp:getPropFields()
    local index = 1
    for key, value in pairs(config) do
        if propFields[key] then
            local tfTitle = self._ccbOwner["tf_new_title_"..index]
            local tfProp = self._ccbOwner["tf_new_prop_"..index]
            if tfTitle and tfProp then
                local nameStr = propFields[key].uiName or propFields[key].name
                local valueStr = q.getFilteredNumberToString(value, propFields[key].isPercent, 1)
                tfTitle:setString(nameStr.."：")
                tfTitle:setVisible(true)

                tfProp:setString("+"..valueStr)
                tfProp:setVisible(true)
                index = index + 1
            else
                break
            end
        end
    end

    while true do
        local tfTitle = self._ccbOwner["tf_new_title_"..index]
        local tfProp = self._ccbOwner["tf_new_prop_"..index]
        if tfTitle and tfProp then
            tfTitle:setVisible(false)
            tfProp:setVisible(false)
            index = index + 1
        else
            break
        end
    end

    --  消耗
    self._ccbOwner.tf_price:setString(config.consume_money_num)

    -- 进度条
    local itemCount = remote.items:getItemsNumByID(self._itemId)
    local needCount = config.consume_item_num
    local curProportion = itemCount/needCount
    if curProportion > 1 then curProportion = 1 end

    if not self._percentBarClippingNode then
        self._totalStencilPosition = self._ccbOwner.sp_progress:getPositionX() -- 这个坐标必须sp_progress节点的锚点为(0, 0.5)
        self._percentBarClippingNode = q.newPercentBarClippingNode(self._ccbOwner.sp_progress)
        self._totalStencilWidth = self._ccbOwner.sp_progress:getContentSize().width * self._ccbOwner.sp_progress:getScaleX()
    end
    local stencil = self._percentBarClippingNode:getStencil()
    stencil:setPositionX(-self._totalStencilWidth + curProportion * self._totalStencilWidth)
    self._ccbOwner.tf_progress:setString(itemCount.."/"..needCount)
end

function QUIDialogHandbookBT:_onTriggerOK(event)
    if self._isPlaying then
        return
    end

    if event then
        app.sound:playSound("common_small")
    end

    local successCallback = function()
        if self:safeCheck() then
            self._lastShowType = self._showType
            self:_succeedEffect()
            self:_refreshInfo()
        end
    end

    local isReady, notEnough = remote.handBook:isReadyBreakthroughByActorId(self._actorId)
    if isReady then
        remote.handBook:heroHandbookBreakthroughRequest({self._actorId}, successCallback)
    else
        print("notEnough = ", notEnough)
        if notEnough == "money" then
            QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.MONEY)
        elseif notEnough == "godSkill" then
            app.tip:floatTip("该英雄神技尚未满级，无法突破界限～")
        elseif notEnough then
            QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, notEnough)
        else
            print("魂师图鉴，界限突破数据异常 ： ", self._actorId)
        end
    end
end

function QUIDialogHandbookBT:checkExit()
    local curHandbookBreakthroughLevel = remote.handBook:getHandbookBreakthroughLevelByActorID(self._actorId)
    local config = remote.handBook:getCurHandbookBTConfigByActorId(self._actorId, curHandbookBreakthroughLevel + 1)
    if q.isEmpty(config) then
        self:viewAnimationOutHandler()
    end
end

function QUIDialogHandbookBT:_succeedEffect()
    self._isPlaying = true
    self._ccbOwner.node_effect:removeAllChildren()
    local propConfig = remote.handBook:getCurStatePropIncreaseByActorId(self._actorId, self._showType)
    local propFields = QActorProp:getPropFields()
    local propCount = 0
    for key, value in pairs(propConfig) do
        if propFields[key] and value > 0 then
            propCount = propCount + 1
        end
    end
    local distanceY = (propCount - 1) * 30
    local aniPropListView = QUIWidgetAnimationPlayer.new()
    self._ccbOwner.node_effect:addChild(aniPropListView)
    aniPropListView:playAnimation("ccb/effects/propListView.ccbi", function(ccbOwner)

        ccbOwner.node_all:setPositionY(distanceY)

        if self._showType == remote.handBook.STATE_ACTIVATION then
            ccbOwner.tf_title:setString("激活属性增长")
        elseif self._showType == remote.handBook.STATE_GRADE_UP then
            ccbOwner.tf_title:setString("升星属性增长")
        elseif self._showType == remote.handBook.STATE_BREAK_THROUGH then
            ccbOwner.tf_title:setString("突破属性增长")
        elseif self._showType == "handbook_point" then
            ccbOwner.tf_title:setString("史诗属性增长")
        end

        local index = 1
        for key, value in pairs(propConfig) do
            if propFields[key] and value > 0 then
                local node = ccbOwner["node_"..index]
                if node then
                    local nameStr = propFields[key].handbookName or propFields[key].archaeologyName or propFields[key].uiName or propFields[key].name
                    local valueStr = q.getFilteredNumberToString(value, propFields[key].isPercent, 1)
                    ccbOwner["tf_name"..index]:setString(nameStr..": +"..valueStr)
                    node:setVisible(true)
                    index = index + 1
                else
                    break
                end
            end
        end
        
        while true do
            local node = ccbOwner["node_"..index]
            if node then
                node:setVisible(false)
                index = index + 1
            else
                break
            end
        end
    end, function()
        if aniPropListView ~= nil then
            aniPropListView:disappear()
            aniPropListView = nil
        end

        self._isPlaying = false
        self:checkExit()
    end)
end

function QUIDialogHandbookBT:_onTriggerInfo(event)
    if event then
        app.sound:playSound("common_small")
    end

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHandbookPropInfo", options = {title = "界限突破", showType = remote.handBook.TYPE_BT_PROP, actorId = self._actorId}})
end

function QUIDialogHandbookBT:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
    if event then
        app.sound:playSound("common_cancel")
    end
    self:playEffectOut()
end

function QUIDialogHandbookBT:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogHandbookBT:viewAnimationOutHandler()
    if self._callback then
        self._callback(self._actorId, self._lastShowType)
    end
    self:popSelf()
end

return QUIDialogHandbookBT