--
-- Author: wkwang
-- Date: 2015-01-14 20:06:17
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogExchangeHeroSoul = class("QUIDialogExchangeHeroSoul", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollContain = import("..QScrollContain")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QRichText = import("...utils.QRichText")
local QQuickWay = import("...utils.QQuickWay")

function QUIDialogExchangeHeroSoul:ctor(options)
 	local ccbFile = "ccb/Dialog_wannneg.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onPlusOne", callback = handler(self, self._onPlusOne)},
        {ccbCallbackName = "onSubOne", callback = handler(self, self._onSubOne)},
        {ccbCallbackName = "onPlusTen", callback = handler(self, self._onPlusTen)},
        {ccbCallbackName = "onSubTen", callback = handler(self, self._onSubTen)},
        {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
    }
    QUIDialogExchangeHeroSoul.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true
    self._actorId = options.actorId
    self._needNum = options.needNum
    self._totalScale = self._ccbOwner.sp_curBar:getScaleX()
    local gradeConfig = QStaticDatabase:sharedDatabase():getGradeByHeroId(self._actorId)
    self._soulId = gradeConfig[1].soul_gem
    self._exchangeNum = QStaticDatabase:sharedDatabase():getSuperSoulByActorId(self._actorId)
    local qc = QStaticDatabase:sharedDatabase():getActorSABC(self._actorId).qc
    self._itemId = tonumber(ITEM_TYPE.POWERFUL_PIECE)
    local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(self._itemId)
    self._count = 0 -- 選擇轉換的碎片次數（1次=1片）
    self._maxExchangeCount = math.floor(remote.items:getItemsNumByID(self._itemId)/self._exchangeNum)
    self._needExchangeCount = math.max(self._needNum - remote.items:getItemsNumByID(self._soulId), 0)
    -- local totalExchangeCount = math.min(self._maxExchangeCount, self._needExchangeCount)
    -- self._totalExchangeCount = totalExchangeCount < 0 and 0 or totalExchangeCount
    self._totalExchangeCount = self._maxExchangeCount
    self._isSkipAndTips = true

    self._ccbOwner.frame_tf_title:setString("万能碎片转换")
    --5个万能碎片可以转换成1个A级魂师碎片
    local richText = QRichText.new()
    self._ccbOwner.wannengName:addChild(richText)
    self._wannengNameRichText = richText
    self._ccbOwner.wannengDec:setString(itemInfo.description)

    self._ccbOwner.tf_tips:setString(self._exchangeNum.."个万能碎片可以转换成1个"..qc.."级魂师碎片")
    self._heroSoul = QUIWidgetItemsBox.new()
    self._ccbOwner.node_hero_soul:addChild(self._heroSoul)
    self._superSoul = QUIWidgetItemsBox.new()
    self._ccbOwner.node_super_soul:addChild(self._superSoul)
    local itemBox = QUIWidgetItemsBox.new()
    itemBox:setGoodsInfo(self._itemId, ITEM_TYPE.ITEM, 0)
    self._ccbOwner.node_item:addChild(itemBox)
    local characterConfig = QStaticDatabase:sharedDatabase():getCharacterByID(self._actorId)
    self._ccbOwner.tf_hero_name:setString(characterConfig.name)
    self:updateInfo()

    local itemBox2 = QUIWidgetItemsBox.new()
    itemBox2:setGoodsInfo(self._soulId, ITEM_TYPE.ITEM, 0)
    itemBox2:hideSabc()
    itemBox2:hideTalentIcon()
    itemBox2:setScale(0.5)
    self._ccbOwner.node_heroItem:addChild(itemBox2)
end

function QUIDialogExchangeHeroSoul:viewDidAppear()
    QUIDialogExchangeHeroSoul.super.viewDidAppear(self)
end

function QUIDialogExchangeHeroSoul:viewWillDisappear()
    QUIDialogExchangeHeroSoul.super.viewWillDisappear(self)
    if self._itemProxy ~= nil then
        self._itemProxy:removeAllEventListeners()
        self._itemProxy = nil
    end

    if self._calculatorScheduler then
        scheduler.unscheduleGlobal(self._calculatorScheduler)
        self._calculatorScheduler = nil
    end
end

function QUIDialogExchangeHeroSoul:updateInfo(isAnimation)
    self._count = 0

    local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(self._itemId)
    self._wannengNameRichText:setString({
            {oType = "font", content = itemInfo.name,size = 24,color = EQUIPMENT_COLOR[itemInfo.colour], strokeColor = QIDEA_STROKE_COLOR},
            {oType = "font", content = "（拥有："..remote.items:getItemsNumByID(self._itemId).."）",size = 22,color = ccc3(134, 85, 55)},
        })

    self:_updatePreviewBar()
    self:_updateCurBar(isAnimation)
    self:_updateCount()
end

function QUIDialogExchangeHeroSoul:_updatePreviewBar()
    local heroSoulCount = remote.items:getItemsNumByID(self._soulId) + self._count
    local heroSoulCount2 = math.min(heroSoulCount, self._needNum)
    self._ccbOwner.sp_previewBar:setScaleX(self._totalScale*heroSoulCount2/self._needNum)
end

function QUIDialogExchangeHeroSoul:_updateCurBar(isAnimation)
    local heroSoulCount = remote.items:getItemsNumByID(self._soulId)
    self._ccbOwner.tf_bar:setString(heroSoulCount.."/"..self._needNum)
    local heroSoulCount2 = math.min(heroSoulCount, self._needNum)
    if isAnimation == true and self._oldSoulCount ~= nil and heroSoulCount > self._oldSoulCount then
        self._ccbOwner.sp_curBar:runAction(CCScaleTo:create(0.2, self._totalScale*heroSoulCount2/self._needNum, self._ccbOwner.sp_curBar:getScaleY()))
        local ccbfile = "effects/Tips_add.ccbi"
        local animationPlayer = QUIWidgetAnimationPlayer.new()
        animationPlayer:setPosition((self._ccbOwner.sprite_back:getScaleX() * self._ccbOwner.sprite_back:getContentSize().width)/2,0)
        self._ccbOwner.sprite_back:getParent():addChild(animationPlayer)
        animationPlayer:playAnimation(ccbfile,function (_ccbOwner)
            _ccbOwner.content:setString("+"..(heroSoulCount - self._oldSoulCount))
        end,function()
            if self:safeCheck() then
                animationPlayer:disappear()
                self._isExchanging = false
            end
        end)
        app.tip:floatTip("转换成功")
    else
        self._ccbOwner.sp_curBar:setScaleX(self._totalScale*heroSoulCount2/self._needNum)
        self._isExchanging = false
    end

    self._oldSoulCount = heroSoulCount
end

function QUIDialogExchangeHeroSoul:_updateItemsInfo()
    self._heroSoul:setGoodsInfo(self._soulId, ITEM_TYPE.ITEM, 1*self._count)
    self._superSoul:setGoodsInfo(self._itemId, ITEM_TYPE.ITEM, self._exchangeNum*self._count)
end

function QUIDialogExchangeHeroSoul:_updateCount()
    self._maxExchangeCount = math.floor(remote.items:getItemsNumByID(self._itemId)/self._exchangeNum)
    self._needExchangeCount = math.max(self._needNum - remote.items:getItemsNumByID(self._soulId), 0)
    -- local totalExchangeCount = math.min(self._maxExchangeCount, self._needExchangeCount)
    -- self._totalExchangeCount = totalExchangeCount < 0 and 0 or totalExchangeCount
    self._totalExchangeCount = self._maxExchangeCount
    self._ccbOwner.tf_count:setString(self._count.."/"..self._totalExchangeCount)
    self:_updateItemsInfo()
end

function QUIDialogExchangeHeroSoul:exchangeSoul(count)
    local needSuperSoulCount = self._exchangeNum * count
    if remote.items:getItemsNumByID(self._itemId) < needSuperSoulCount then
        QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, self._itemId, needSuperSoulCount, nil, false)
        app.tip:floatTip("碎片不足，无法转换")
    else
        if self._isExchanging == true then return end
        self._isExchanging = true
        app:getClient():heroPieceChangeRequest(self._actorId, count, function ()
            if self:safeCheck() then
                local animationPlayer = QUIWidgetAnimationPlayer.new()
                self._ccbOwner.node_effect:addChild(animationPlayer)
                animationPlayer:playAnimation("ccb/effects/wanneng1.ccbi", nil, function ()
                    if self:safeCheck() then
                        animationPlayer:disappear()
                        local screenPos = ccp(self._ccbOwner.node_bar:getPosition())
                        local currentPos = ccp(self._ccbOwner.node_hero_soul:getPosition())
                        local itemBox = QUIWidgetItemsBox.new()
                        itemBox:setGoodsInfo(self._soulId, ITEM_TYPE.ITEM, 0)
                        itemBox:hideSabc()
                        itemBox:hideTalentIcon()
                        itemBox:setPosition(currentPos)
                        self._ccbOwner.node_hero_soul:getParent():addChild(itemBox)

                        local bezierConfig = ccBezierConfig:new()
                        bezierConfig.endPosition = ccp(screenPos.x, screenPos.y)
                        bezierConfig.controlPoint_1 = ccp(currentPos.x + (screenPos.x - currentPos.x) * 0.4, screenPos.y - 80)
                        bezierConfig.controlPoint_2 = ccp(currentPos.x + (screenPos.x - currentPos.x) * 0.667, screenPos.y)
                        local bezierTo = CCBezierTo:create(0.3, bezierConfig)

                        local arr = CCArray:create()
                        local arr2 = CCArray:create()
                        arr2:addObject(CCScaleTo:create(0.3, 0.5, 0.5))
                        arr2:addObject(CCEaseOut:create(bezierTo, 0.3))
                        arr:addObject(CCSpawn:create(arr2))
                        arr:addObject(CCCallFunc:create(function()
                                itemBox:removeFromParent()
                                self:_showEffect()
                                self:updateInfo(true)
                            end))
                        itemBox:runAction(CCSequence:create(arr))
                    end
                end)
            end
        end, function() self._isExchanging = false end)
    end
end

function QUIDialogExchangeHeroSoul:_showEffect()
    local effectShow = QUIWidgetAnimationPlayer.new()
    effectShow:setPosition((self._ccbOwner.sprite_back:getScaleX() * self._ccbOwner.sprite_back:getContentSize().width)/2, 7)
    self._ccbOwner.sprite_back:getParent():addChild(effectShow)
    effectShow:playAnimation("ccb/effects/qianghua_effect_g.ccbi",nil,function ()
        if self:safeCheck() then
            effectShow:disappear()
        end
    end)
    app.sound:playSound("equipment_enhance")
end

function QUIDialogExchangeHeroSoul:_backClickHandler()
    self:playEffectOut()
end

function QUIDialogExchangeHeroSoul:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
    app.sound:playSound("common_close")
    self:playEffectOut()
end

function QUIDialogExchangeHeroSoul:_onPlusOne(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_plusOne) == false then return end
    app.sound:playSound("common_increase")
    local isNeedTips = self._isSkipAndTips and (self._count < self._needExchangeCount or (self._count == 0 and self._needExchangeCount == 0))

    self._count = self._count + 1
    if self._count > self._maxExchangeCount then
        self._count = self._maxExchangeCount
    end
    if isNeedTips and self._count >= self._needExchangeCount then
        app.tip:floatTip("已满足当前魂师升星的需求")
        self._isSkipAndTips = false
        self._count = self._needExchangeCount
    end
    
    self:_updatePreviewBar()
    self:_updateCount()
end

function QUIDialogExchangeHeroSoul:_onPlusTen(event)
    app.sound:playSound("common_increase")

    if tonumber(event) == CCControlEventTouchDown then
        self._ccbOwner.btn_plusTen:setColor(ccc3(210, 210, 210))
        self:_onPlusDownHandler()
    elseif self._isLoop then
        self._ccbOwner.btn_plusTen:setColor(ccc3(255, 255, 255))
        self:_onPlusUpHandler()
    end
end

function QUIDialogExchangeHeroSoul:_onPlusUpHandler()
    self._isLoop = false
    self:_doPlusTen()
end

function QUIDialogExchangeHeroSoul:_onPlusDownHandler()
    if self._calculatorScheduler then
        scheduler.unscheduleGlobal(self._calculatorScheduler)
        self._calculatorScheduler = nil
    end
    self._isLoop = true
    self._calculatorScheduler = scheduler.performWithDelayGlobal(function()
            if self:safeCheck() then
                self:_doPlusTen()
            end
        end, 0.5)
end

function QUIDialogExchangeHeroSoul:_doPlusTen()
    if self._calculatorScheduler then
        scheduler.unscheduleGlobal(self._calculatorScheduler)
        self._calculatorScheduler = nil
    end

    local isNeedTips = self._isSkipAndTips and (self._count < self._needExchangeCount or (self._count == 0 and self._needExchangeCount == 0))

    self._count = self._count + 10
    if self._count > self._maxExchangeCount then
        self._count = self._maxExchangeCount
    end
    if isNeedTips and self._count >= self._needExchangeCount then
        app.tip:floatTip("已满足当前魂师升星的需求")
        self._isSkipAndTips = false
        self._count = self._needExchangeCount
        self._isLoop = false 
    end
    
    self:_updatePreviewBar()
    self:_updateCount()

    if self._isLoop then
        self._calculatorScheduler = scheduler.performWithDelayGlobal(function()
                if self:safeCheck() then
                    self:_doPlusTen()
                end
            end, 0.05)
    end
end

function QUIDialogExchangeHeroSoul:_onSubOne(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_subOne) == false then return end
    app.sound:playSound("common_increase")
    self._count = self._count - 1
    if self._count < self._needExchangeCount then
        self._isSkipAndTips = true
    end
    if self._count < 0 then
        self._count = 0
    end
    self:_updatePreviewBar()
    self:_updateCount()
end

function QUIDialogExchangeHeroSoul:_onSubTen(event)
    app.sound:playSound("common_increase")

    if tonumber(event) == CCControlEventTouchDown then
        self._ccbOwner.btn_subTen:setColor(ccc3(210, 210, 210))
        self:_onSubDownHandler()
    else
        self._ccbOwner.btn_subTen:setColor(ccc3(255, 255, 255))
        self:_onSubUpHandler()
    end
end

function QUIDialogExchangeHeroSoul:_onSubUpHandler()
    self._isLoop = false
    self:_doSubTen()
end

function QUIDialogExchangeHeroSoul:_onSubDownHandler()
    if self._calculatorScheduler then
        scheduler.unscheduleGlobal(self._calculatorScheduler)
        self._calculatorScheduler = nil
    end
    self._isLoop = true
    self._calculatorScheduler = scheduler.performWithDelayGlobal(function()
            if self:safeCheck() then
                self:_doSubTen()
            end
        end, 0.5)
end

function QUIDialogExchangeHeroSoul:_doSubTen()
    if self._calculatorScheduler then
        scheduler.unscheduleGlobal(self._calculatorScheduler)
        self._calculatorScheduler = nil
    end

    self._count = self._count - 10
    if self._count < self._needExchangeCount then
        self._isSkipAndTips = true
    end
    if self._count < 0 then
        self._count = 0
    end
    self:_updatePreviewBar()
    self:_updateCount()

    if self._isLoop then
        self._calculatorScheduler = scheduler.performWithDelayGlobal(function()
                if self:safeCheck() then
                    self:_doSubTen()
                end
            end, 0.05)
    end
end

function QUIDialogExchangeHeroSoul:_onTriggerOK(event)
    if q.buttonEventShadow(event, self._ccbOwner.button_ok) == false then return end
    app.sound:playSound("common_increase")
    if self._count < 1 then
        app.tip:floatTip("请选择转换的次数")
        return
    end
    self:exchangeSoul(self._count)
end

function QUIDialogExchangeHeroSoul:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogExchangeHeroSoul