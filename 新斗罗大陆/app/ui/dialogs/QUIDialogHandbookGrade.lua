--
-- Kumo.Wang
-- 新版魂师图鉴激活、升星界面
--

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogHandbookGrade = class("QUIDialogHandbookGrade", QUIDialog)

local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QActorProp = import("...models.QActorProp")

local QUIViewController = import("..QUIViewController")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

function QUIDialogHandbookGrade:ctor(options)
    local ccbFile = "ccb/Dialog_Handbook_Grade.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
    }
    QUIDialogHandbookGrade.super.ctor(self,ccbFile,callBacks,options)
    self.isAnimation = true

    if options then
        self._actorId = options.actorId
        self._callback = options.callback
    end

    q.setButtonEnableShadow(self._ccbOwner.btn_ok)

    self:_init()
    self:_initView()
    self:_refreshInfo()
end

function QUIDialogHandbookGrade:_initView()
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
end

function QUIDialogHandbookGrade:viewDidAppear()
    QUIDialogHandbookGrade.super.viewDidAppear(self)

    self._touchLayer = QUIGestureRecognizer.new({color = false})
    self._touchLayer:attachToNode(self:getView(), self._allWidth, self._allHeight, -(self._allWidth)/2, -(self._allHeight - 80), handler(self, self._onTouchEvent))
    self._touchLayer:enable()
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self._onTouchEvent))
end 

function QUIDialogHandbookGrade:_onTouchEvent(event)
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

function QUIDialogHandbookGrade:viewWillDisappear()
    QUIDialogHandbookGrade.super.viewWillDisappear(self)

    if self._touchLayer then
        self._touchLayer:removeAllEventListeners()
        self._touchLayer:disable()
        self._touchLayer:detach()
    end
end

function QUIDialogHandbookGrade:_init()
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
    self._characterName = characterConfig.name
    self._ccbOwner.tf_name:setString(self._characterName)

    self._isPlaying = false
end

function QUIDialogHandbookGrade:_refreshInfo()
    self._showType = remote.handBook:getHandbookStateByActorID(self._actorId)
    if self._showType == remote.handBook.STATE_NONE or self._showType == remote.handBook.STATE_ACTIVATION then
        -- 激活
        self._ccbOwner.frame_tf_title:setString("图鉴激活")

        -- 按钮文字
        self._ccbOwner.tf_btn_ok:setString("激 活")

        -- 可获得图鉴点
        self._ccbOwner.tf_point_title:setString("激活可获得图鉴点：")

        -- 条件
        self._ccbOwner.tf_tips_title:setString("激活条件：")
        self._ccbOwner.tf_tips:setString("获得魂师"..self._characterName)
        if self._showType == remote.handBook.STATE_NONE then
            self._ccbOwner.tf_tips:setColor(COLORS.m)
            makeNodeFromNormalToGray(self._ccbOwner.node_ok)
            self._ccbOwner.tf_btn_ok:disableOutline() 
            self._ccbOwner.ccb_btn_ok_effect:setVisible(false)
        elseif self._showType == remote.handBook.STATE_ACTIVATION then
            self._ccbOwner.tf_tips:setColor(COLORS.l)
            makeNodeFromGrayToNormal(self._ccbOwner.node_ok)
            self._ccbOwner.tf_btn_ok:enableOutline()
            self._ccbOwner.ccb_btn_ok_effect:setVisible(true)
        end

        -- 前后对比
        self._ccbOwner.node_old_prop:setVisible(false)
        self._ccbOwner.tf_no_prop:setVisible(true)
        self._ccbOwner.tf_old_title:setString("图鉴未激活")
        self._ccbOwner.tf_new_title:setString("图鉴激活后")
    elseif self._showType == remote.handBook.STATE_GRADE_UP then
        -- 升星
        self._ccbOwner.frame_tf_title:setString("图鉴升星")

        -- 按钮文字
        self._ccbOwner.tf_btn_ok:setString("升 星")

        -- 可获得图鉴点
        self._ccbOwner.tf_point_title:setString("升星可获得图鉴点：")

        -- 条件
        local curHandbookGradeLevel = remote.handBook:getHandbookLevelByActorID(self._actorId)
        local needGodSkillLevel = curHandbookGradeLevel + 1
        self._ccbOwner.tf_tips_title:setString("升星条件：")
        self._ccbOwner.tf_tips:setString("该魂师神技达到"..needGodSkillLevel.."级")
        if remote.handBook:isReadyGradeUpByActorId(self._actorId) then
            self._ccbOwner.tf_tips:setColor(COLORS.l)
            makeNodeFromGrayToNormal(self._ccbOwner.node_ok)
            self._ccbOwner.tf_btn_ok:enableOutline()
            self._ccbOwner.ccb_btn_ok_effect:setVisible(true)
        else
            self._ccbOwner.tf_tips:setColor(COLORS.m)
            makeNodeFromNormalToGray(self._ccbOwner.node_ok)
            self._ccbOwner.tf_btn_ok:disableOutline() 
            self._ccbOwner.ccb_btn_ok_effect:setVisible(false)
        end

        -- 前后对比
        self._ccbOwner.node_old_prop:setVisible(true)
        self._ccbOwner.tf_no_prop:setVisible(false)
        self._ccbOwner.tf_old_title:setString(curHandbookGradeLevel.."星图鉴")
        self._ccbOwner.tf_new_title:setString((curHandbookGradeLevel + 1).."星图鉴")

        self:_showCurProp()
    end

    self:_showNextProp()
end

function QUIDialogHandbookGrade:_showCurProp()
    local curHandbookGradeLevel = remote.handBook:getHandbookLevelByActorID(self._actorId)
    local config = remote.handBook:getCurHandbookGradeConfigByActorId(self._actorId, curHandbookGradeLevel)
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

function QUIDialogHandbookGrade:_showNextProp()
    local curHandbookGradeLevel = remote.handBook:getHandbookLevelByActorID(self._actorId)

    if curHandbookGradeLevel == -1 then 
        local aptitudeInfo = remote.handBook:getHeroAptitudeInfoByActorID(self._actorId)
        if aptitudeInfo.lower ~= "ss+" then
            curHandbookGradeLevel = 0
        end
    end
    
    local config = remote.handBook:getCurHandbookGradeConfigByActorId(self._actorId, curHandbookGradeLevel + 1)
    if q.isEmpty(config) then 
        self._ccbOwner.node_new_prop:setVisible(false)
        self._ccbOwner.tf_point:setString("+0")
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

    self._ccbOwner.tf_point:setString("+"..config.handbook_score)
end

function QUIDialogHandbookGrade:_onTriggerOK(event)
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

    if self._showType == remote.handBook.STATE_NONE then
        app.tip:floatTip("尚未拥有该英雄，无法激活～")
    elseif self._showType == remote.handBook.STATE_ACTIVATION then
        -- 激活
        remote.handBook:heroHandbookUpgradeRequest({self._actorId}, false, successCallback)
    elseif self._showType == remote.handBook.STATE_GRADE_UP then
        if remote.handBook:isReadyGradeUpByActorId(self._actorId) then
            -- 升星
            remote.handBook:heroHandbookUpgradeRequest({self._actorId}, false, successCallback)
        else
            app.tip:floatTip("神技等级不足，无法升星～")
        end
   end
end


function QUIDialogHandbookGrade:_succeedEffect()
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

function QUIDialogHandbookGrade:checkExit()
    local curHandbookGradeLevel = remote.handBook:getHandbookLevelByActorID(self._actorId)
    local config = remote.handBook:getCurHandbookGradeConfigByActorId(self._actorId, curHandbookGradeLevel + 1)
    if self._lastShowType == remote.handBook.STATE_ACTIVATION or q.isEmpty(config) then
        self:viewAnimationOutHandler()
    end
end

function QUIDialogHandbookGrade:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
    if event then
        app.sound:playSound("common_cancel")
    end
    self:playEffectOut()
end

function QUIDialogHandbookGrade:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogHandbookGrade:viewAnimationOutHandler()
    if self._callback then
        self._callback(self._actorId, self._lastShowType)
    end
    self:popSelf()
end

return QUIDialogHandbookGrade