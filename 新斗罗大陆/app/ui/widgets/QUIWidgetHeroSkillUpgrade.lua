
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroSkillUpgrade = class("QUIWidgetHeroSkillUpgrade", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAssistHeorSkillCell = import("..widgets.QUIWidgetAssistHeorSkillCell")
local QUIWidgetGodHeroSkillCell = import("..widgets.QUIWidgetGodHeroSkillCell")
local QUIWidgetHeroSkillCell = import("..widgets.QUIWidgetHeroSkillCell")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QRemote = import("...models.QRemote")
local QVIPUtil = import("...utils.QVIPUtil")
local QQuickWay = import("....utils.QQuickWay")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

function QUIWidgetHeroSkillUpgrade:ctor(options)
	local ccbFile = "ccb/Widget_HeroSkillUpgrade.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerBuy", callback = handler(self, QUIWidgetHeroSkillUpgrade._onTriggerBuy)},
        {ccbCallbackName = "onTriggerAbout", callback = handler(self, QUIWidgetHeroSkillUpgrade._onTriggerAbout)},
        {ccbCallbackName = "onTriggerMonthCard", callback = handler(self, QUIWidgetHeroSkillUpgrade._onTriggerMonthCard)},
        {ccbCallbackName = "onTriggerLevelUp", callback = handler(self, QUIWidgetHeroSkillUpgrade._onTriggerLevelUp)},
    }
	QUIWidgetHeroSkillUpgrade.super.ctor(self, ccbFile, callBacks, options)

    q.setButtonEnableShadow(self._ccbOwner.btn_buy)
    q.setButtonEnableShadow(self._ccbOwner.btn_level)

    self._totleHeight = 0
    self._offsetY = 0
    self._haveAssistSkill = false
    self._haveGodSkill = false
    self.addAllSkillMoney = 0
    
    self._ccbOwner.node_normal:setVisible(false)
    self._ccbOwner.node_buy:setVisible(false)
    self._ccbOwner.node_levelAll:setVisible(false)
    
    self:_initBackGroundBG()

    local node = self._ccbOwner.node_mask
    self._ccbOwner.top_btn:setPositionY(-336)
    self._ccbOwner.bottom_btn:setPositionY(-308)
    self._pageWidth = node:getContentSize().width
    self._pageHeight = node:getContentSize().height
    self._pageContent = self._ccbOwner.node_contain
    self._orginalPosition = ccp(self._pageContent:getPosition())

    local layerColor = CCLayerColor:create(ccc4(255,0,0,150), self._pageWidth, self._pageHeight)
    local ccclippingNode = CCClippingNode:create()
    layerColor:setPositionX(node:getPositionX())
    layerColor:setPositionY(node:getPositionY())
    ccclippingNode:setStencil(layerColor)
    self._pageContent:retain()
    self._pageContent:removeFromParent()
    ccclippingNode:addChild(self._pageContent)
    self._pageContent:release()

    self._ccbOwner.node_skill:addChild(ccclippingNode)

    self._ccbOwner.btn_month_card:setVisible(false)
    if remote.activity:checkMonthCardActive(2) then
        self._ccbOwner.btn_month_card:setVisible(true)
    end

    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    self._reportEffectLayer = CCNode:create()
    page:getView():addChild(self._reportEffectLayer)
end

function QUIWidgetHeroSkillUpgrade:onEnter()

    self._touchLayer = QUIGestureRecognizer.new()
    self._touchLayer:attachToNode(self._ccbOwner.node_mask:getParent(),self._pageWidth, self._pageHeight, -self._pageWidth/2, 
        -self._pageHeight/2, handler(self, self.onTouchEvent))
    self._touchLayer:enable()
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self.onTouchEvent))
   
    self._remoteProxy = cc.EventProxy.new(remote)
    self._remoteProxy:addEventListener(QRemote.HERO_UPDATE_EVENT, handler(self, self.onEvent)) 

    self:showPointAndTime()
end

function QUIWidgetHeroSkillUpgrade:_initBackGroundBG()
    local bgHeight = 440
    local posY = -149
    if app.unlock:getUnlockUnlimitedSkillPoint() then
        local unlockKey = "UNLOCK_SKILL_ONEKEY"
        local unlock = app.unlock:checkLock(unlockKey, false)
        if unlock then
            bgHeight = 417
            posY = -126
        end
    end
    local brownBGSize = self._ccbOwner.so_brown_bg:getContentSize()
    local maskBGSize = self._ccbOwner.node_mask:getContentSize()
    brownBGSize.height = bgHeight
    maskBGSize.height = bgHeight - 4
    self._ccbOwner.so_brown_bg:setContentSize(brownBGSize)
    self._ccbOwner.node_mask:setContentSize(maskBGSize)
    self._ccbOwner.node_mask:setPositionY(posY)
end

function QUIWidgetHeroSkillUpgrade:onExit()
    self._touchLayer:removeAllEventListeners()
    self._touchLayer:disable()
    self._touchLayer:detach()
    self._remoteProxy:removeAllEventListeners()
    
    if self._timeHandler ~= nil then
        scheduler.unscheduleGlobal(self._timeHandler)
    end
    if self._handler ~= nil then
        scheduler.unscheduleGlobal(self._handler)
    end
    self:removeSkillCell()

    if self._effect ~= nil then
        self._effect:disappear()
        self._effect:removeFromParent()
        self._effect = nil
    end
    if self._schedulerHandler ~= nil then
        scheduler.unscheduleGlobal(self._schedulerHandler)
        self._schedulerHandler = nil
    end
    
    if self._reportEffectLayer ~= nil then
        self._reportEffectLayer:removeFromParentAndCleanup(true)
    end
end

function QUIWidgetHeroSkillUpgrade:setMoveState(state)
    self._isMoving = state
    for _, box in pairs(self.skillCell) do
        box:setParentMoveState(state)
    end
end

-- 处理各种touch event
function QUIWidgetHeroSkillUpgrade:onTouchEvent(event)
    if event == nil or event.name == nil then
        return
    end
    if self._totleHeight <= self._pageHeight then
        return 
    end
    if event.name == QUIGestureRecognizer.EVENT_SLIDE_GESTURE then
        -- self._page:endMove(event.distance.y)
    elseif event.name == "began" then
        self._startY = event.y
        self._pageY = self._pageContent:getPositionY()
    elseif event.name == "moved" then
        if math.abs(event.y - self._startY) < 10 then return end
        local offsetY = self._pageY + event.y - self._startY
        if offsetY < self._orginalPosition.y then
            offsetY = self._orginalPosition.y
        elseif offsetY > (self._totleHeight - self._pageHeight + self._orginalPosition.y) then
            offsetY = (self._totleHeight - self._pageHeight + self._orginalPosition.y)
        end
        self._pageContent:setPositionY(offsetY)

        self:setMoveState(true)
    elseif event.name == "ended" then   
        self._schedulerHandler = scheduler.performWithDelayGlobal(function()
            self:setMoveState(false)
        end, 0)
    end
end

function QUIWidgetHeroSkillUpgrade:onEvent(event)
    self:showPointAndTime()
    self:updateHero()
    self:_initAllLevelUp()
end

function QUIWidgetHeroSkillUpgrade:updateHero()
    local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
    if self._heroInfo == nil then return end

    if #heroInfo.slots ~= #self._heroInfo.slots or (heroInfo.level ~= self._heroInfo.level) then
        self:setHero(self._actorId)
    end
end

function QUIWidgetHeroSkillUpgrade:setHero(actorId)
    self._actorId = actorId
    self._heroUIModel = remote.herosUtil:getUIHeroByID(self._actorId)
    if self._effect ~= nil then
        self._effect:setVisible(false)
    end
    self._heroInfo = clone(remote.herosUtil:getHeroByID(actorId))
    self:removeSkillCell()
    self._pageContent:removeAllChildren()
    self._pageContent:setPosition(self._orginalPosition.x, self._orginalPosition.y)
    self._totleHeight = 0
    local config = QStaticDatabase:sharedDatabase():getConfiguration()
    self.canSkillUpgrade = true
    if app.unlock:getUnlockSkill() == false then
        self.canSkillUpgrade = false
    end

    local breakthroughConfig = QStaticDatabase:sharedDatabase():getBreakthroughHeroByActorId(self._actorId)
    local skillIdLists = {}
    if breakthroughConfig ~= nil then
        local index = 1
        local disableSkill = {}
        for _,value in pairs(breakthroughConfig) do
            if #disableSkill > 1 then break end
            local skillInfo = self._heroUIModel:getSkillBySlot(value.skill_id_3)
            if skillInfo ~= nil then
                local count = 1
                if index < 4 or #disableSkill <= 1 then
                    count = self:addSkill(value.skill_id_3)
                    table.insert(skillIdLists,value.skill_id_3)
                end
                if index >= 3 and skillInfo.info == nil then
                    table.insert(disableSkill, skillInfo)
                end
                index = index + count
            end
        end
    end
    self:_initAllLevelUp()
end

function QUIWidgetHeroSkillUpgrade:removeSkillCell()
    if self.skillCell ~= nil then
        for _,cell in pairs(self.skillCell) do
            cell:removeAllEventListeners()
        end
    end
    self.skillCell = {}
end

function QUIWidgetHeroSkillUpgrade:addSkill(skillSlot)
    local count = 0
    --检查是否有合体技
    if skillSlot == 3 then
        local godSkillInfo = db:getGodSkillById(self._actorId)
        if godSkillInfo ~= nil then
            local skillCell = QUIWidgetGodHeroSkillCell.new({actorId = self._actorId})
            skillCell:setPositionY(-self._totleHeight - skillCell:getHeight()/2 + self._offsetY)
            self._pageContent:addChild(skillCell)
            self._totleHeight = self._totleHeight + skillCell:getHeight() + 5
            count = count + 1
            self._haveGodSkill = true
        end

        local assistSkillInfo = db:getAssistSkill(self._actorId)
        if assistSkillInfo ~= nil then
            local skillCell = QUIWidgetAssistHeorSkillCell.new({skillSlot = skillSlot, actorId = self._actorId, assistSkill = assistSkillInfo})
            skillCell:addEventListener(QUIWidgetAssistHeorSkillCell.EVENT_BUY, handler(self, self.buySkillPointHandler))
            skillCell:addEventListener(QUIWidgetAssistHeorSkillCell.EVENT_ADD, handler(self, self.addSkillHandler))
            skillCell:setPositionY(-self._totleHeight - skillCell:getHeight()/2 + self._offsetY)
            self._pageContent:addChild(skillCell)
            self._totleHeight = self._totleHeight + skillCell:getHeight() + 3
            count = count + 1
            self._haveAssistSkill = true
        end
    end

    if skillSlot ~= nil and skillSlot ~= "" then
        local skillCell = QUIWidgetHeroSkillCell.new({skillSlot = skillSlot, actorId = self._actorId, content = self})
        skillCell:addEventListener(QUIWidgetHeroSkillCell.EVENT_BUY, handler(self, self.buySkillPointHandler))
        skillCell:addEventListener(QUIWidgetHeroSkillCell.EVENT_ADD, handler(self, self.addSkillHandler))
        skillCell:setPositionY(-self._totleHeight + self._offsetY - skillCell:getHeight()/2)
        self._pageContent:addChild(skillCell)
        self._totleHeight = self._totleHeight + skillCell:getHeight() + 3
        skillCell:setOnPlusState(self.canSkillUpgrade)     
        table.insert(self.skillCell, skillCell)
        count = count + 1
    end
    return count
end

function QUIWidgetHeroSkillUpgrade:setText(name, text)
    if self._ccbOwner[name] then
        self._ccbOwner[name]:setString(text)
    end
end

function QUIWidgetHeroSkillUpgrade:_initAllLevelUp()

    if app.unlock:getUnlockUnlimitedSkillPoint() then
        local unlockKey = "UNLOCK_SKILL_ONEKEY"
        local unlock = app.unlock:checkLock(unlockKey, false)
        if not unlock then
            return
        end
    else
        return
    end
    local itemNum = "魂技等级已至上限"
    self.smallMoney = 0

    local breakthroughConfig = db:getBreakthroughHeroByActorId(self._actorId)
    local skillIdLists = {}
    local skillInfoLists = {}
    if breakthroughConfig ~= nil then
        local index = 1
        local disableSkill = {}
        for _,value in pairs(breakthroughConfig) do
            if #disableSkill > 1 then break end
            local skillInfo = self._heroUIModel:getSkillBySlot(value.skill_id_3)
            if skillInfo ~= nil then
                local count = 1
                if index < 4 or #disableSkill <= 1 then
                    table.insert(skillIdLists,value.skill_id_3)
                end
                if index >= 3 and skillInfo.info == nil then
                    table.insert(disableSkill, skillInfo)
                end
                index = index + count
            end
        end
    end
    if skillIdLists ~= nil and #skillIdLists >= 0 then
        local money = 0
        local smallMoney = 0
        local heroUIModel = self._heroUIModel
        local heroLevel = heroUIModel:getHeroLevel()
        for i,v in ipairs(skillIdLists) do
            local skillInfo = heroUIModel:getSkillBySlot(v)
            if skillInfo then
                if skillInfo.info then

                    local skills = {}
                    skills.slotLevel = skillInfo.info.slotLevel
                    skills.slotId    = skillInfo.info.slotId   
                    skills.skillId   = skillInfo.skillId
                    table.insert(skillInfoLists,skills)

                    local slotLevel = skillInfo.info.slotLevel + 1
                    for i = slotLevel,heroLevel do
                        local nextConfig = db:getSkillDataByIdAndLevel(skillInfo.skillId, i)
                        if nextConfig then
                            if smallMoney == 0 then
                                smallMoney = nextConfig.item_cost
                            else
                                if smallMoney > nextConfig.item_cost then
                                    smallMoney = nextConfig.item_cost
                                end
                            end
                            money = money + nextConfig.item_cost
                        end
                    end
                end
            end
        end
        self.smallMoney = smallMoney
        itemNum = money
    end
    self.skillInfoLists = skillInfoLists
    if itemNum <= 0 then
        itemNum = "魂技等级已至上限"
        self._ccbOwner.sp_price_icon:setVisible(false)
        self._ccbOwner.node_but_level:setVisible(false)

        self.addAllSkillMoney = nil
    else
        self._ccbOwner.node_but_level:setVisible(true)
        self._ccbOwner.sp_price_icon:setVisible(true)
        self.addAllSkillMoney = itemNum
    end
    self._ccbOwner.tf_money_num:setString(itemNum)
end

-- TODO: max skill point might be 20 after certain level
function QUIWidgetHeroSkillUpgrade:showPointAndTime()
    if self._timeHandler ~= nil then
        scheduler.unscheduleGlobal(self._timeHandler)
    end

    if app.unlock:getUnlockUnlimitedSkillPoint() then
        self._ccbOwner.node_normal:setVisible(false)
        self._ccbOwner.node_buy:setVisible(false)
        local unlockKey = "UNLOCK_SKILL_ONEKEY"
        local unlock = app.unlock:checkLock(unlockKey, false)
        if not unlock then
            local config = app.unlock:getConfigByKey("UNLOCK_SKILL_FREE")
            self._ccbOwner.tf_unlimited:setString(((config and config.team_level) and config.team_level or 80).."级或vip"..config.vip_level.."后不消耗技能点")
        end
        self._ccbOwner.node_unlimited:setVisible(not unlock)
        self._ccbOwner.node_levelAll:setVisible(unlock)
    else
        self._ccbOwner.node_unlimited:setVisible(false)
        self._ccbOwner.node_levelAll:setVisible(false)
        local realPoint, lastTime, point = remote.herosUtil:getSkillPointAndTime()
        local totalPoint = QVIPUtil:getSkillPointCount()
        self._ccbOwner.tf_point_num:setString(realPoint.."/"..totalPoint)
        if point > 0 then
            self._ccbOwner.node_normal:setVisible(true)
            self._ccbOwner.node_buy:setVisible(false)
        else
            self._ccbOwner.node_normal:setVisible(false)
            self._ccbOwner.node_buy:setVisible(true)
            self._ccbOwner.btn_buy:setEnabled(true)
        end
        if point >= QVIPUtil:getSkillPointCount() then
            self._ccbOwner.tf_time:setString("")
        else
            self._ccbOwner.tf_time:setString(string.format("(%.2d:%.2d)", math.floor(lastTime / 60.0), math.floor(lastTime % 60.0)))
            self._ccbOwner.tf_time_other:setString(string.format("%.2d:%.2d", math.floor(lastTime / 60.0), math.floor(lastTime % 60.0)))
            self._timeHandler = scheduler.performWithDelayGlobal(handler(self, self.showPointAndTime),1)
        end
        if realPoint == totalPoint - 1 or realPoint == 0 then
            remote.herosUtil:requestSkillUp()
        end
    end
end

function QUIWidgetHeroSkillUpgrade:_onTriggerBuy()
    self:buySkillPointHandler()
end

function QUIWidgetHeroSkillUpgrade:_onTriggerAbout()
    app:vipAlert({textType = VIPALERT_TYPE.NOT_ENOUGH_FOR_SKILL}, false)
end

function QUIWidgetHeroSkillUpgrade:_onTriggerMonthCard()
    app.sound:playSound("common_small")
    app.tip:floatTip("月卡特权，魂技点数双倍速回复中")
end

function QUIWidgetHeroSkillUpgrade:_onTriggerLevelUp()
    app.sound:playSound("common_small")
    if self.addAllSkillMoney == nil then
        app.tip:floatTip("魂技等级已至上限")
        return
    elseif self.addAllSkillMoney == 0 then
        app.tip:floatTip("魂技等级已至上限")
        return
    elseif self._heroUIModel then
        local curMoney = remote.user.money
        if self.smallMoney > curMoney then
            QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.MONEY)
            return
        end
        local oldList = clone(self.skillInfoLists)
        app:getClient():improveAllSkill(self._actorId,function ( data )
            if self.class then
                local attributeInfo = {}
                for index,v in ipairs(oldList) do
                    local skillInfo = self._heroUIModel:getSkillBySlot(v.slotId)
                    if skillInfo.info.slotLevel > v.slotLevel then
                        local skillConfig = QStaticDatabase:sharedDatabase():getSkillByID(v.skillId)
                        local skillName = skillConfig.name
                        local upLevel = skillInfo.info.slotLevel - v.slotLevel
                        local tips = string.format("%s技能等级 +%s",skillName,upLevel)
                        table.insert(attributeInfo,{name = tips})
                        print("name,upLevel",skillName,upLevel)
                        remote.user:addPropNumForKey("todaySkillImprovedCount", upLevel)
                    end
                end
                self:strengthenSucceedEffect(attributeInfo)
            end
        end,function ( data )
        end)
    end
end

function QUIWidgetHeroSkillUpgrade:strengthenSucceedEffect(data)
    self._reportEffectLayer:removeAllChildren()
    local unLockNum = 0
    if data then
        unLockNum = #data + 1
    end
    local distanceY = unLockNum * 56 / 2
    local strengthenEffectShow = QUIWidgetAnimationPlayer.new()
    self._reportEffectLayer:addChild(strengthenEffectShow)
    strengthenEffectShow:setPosition(ccp(display.cx, display.cy + distanceY))
    strengthenEffectShow:playAnimation("ccb/effects/SkillLevelUp.ccbi", function(ccbOwner)
        ccbOwner.level:setVisible(false)
        ccbOwner.node_critcrit:setVisible(false)

        ccbOwner.tf_name:setString("升级成功")
        if data then
            for i = 1,9 do
                if data[i] then
                    strengthenEffectShow._ccbOwner["tf_name"..i]:setString(data[i].name)
                else
                    strengthenEffectShow._ccbOwner["node_"..i]:setVisible(false)
                end
            end
        end
    end, function()
        if strengthenEffectShow ~= nil then
            strengthenEffectShow:disappear()
            strengthenEffectShow = nil
        end
    end)
end

function QUIWidgetHeroSkillUpgrade:buySkillPointHandler()
    local config = remote.user:getSkillTicketConfig()

    if not QVIPUtil:canBuySkillPoint() then
        local level = QVIPUtil:getBuySkillPointUnlockLevel()
        local text = "购买魂技点功能，VIP达到"..level.."级后可开启，是否前往充值提升VIP等级？"
        app:vipAlert({content=text}, false)
    else
        local skillPoint = QVIPUtil:getSkillPointCount()
        app:alert({content="购买"..skillPoint.."点魂技点需花费"..config.money_num.."钻石\n是否继续？(今日已购买"..remote.user.skillTicketsReset.."次)", title="系统提示", 
            callback = function(state)
                if state == ALERT_TYPE.CONFIRM then
                    self._ccbOwner.btn_buy:setEnabled(false)
                    app:getClient():buySkillTicket(function ()
                        remote.user:addPropNumForKey("skillTicketsReset")
                    end)
                end
            end}, false)
    end
end

function QUIWidgetHeroSkillUpgrade:addSkillHandler(event)
    if event.name == QUIWidgetHeroSkillCell.EVENT_ADD then
        local skillId = event.skillId
        local slotLevel = event.slotLevel
        local skillDatas = {}
        for i= slotLevel - event.addLevel, slotLevel do
            table.insert(skillDatas, QStaticDatabase:sharedDatabase():getSkillDataByIdAndLevel(skillId, i))
        end
        if self._effect == nil then
            self._effect =  QUIWidgetAnimationPlayer.new()
            local topDialog = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
            self._effect:setPosition(display.cx, display.cy)
            topDialog:getView():addChild(self._effect)
        else
            self._effect:setVisible(true)
        end
        if event.addLevel > 1 then
            self._effect:playAnimation("ccb/effects/SkillUpgarde2.ccbi", function (ccbOwner)
                ccbOwner.title_skill:setString("魂技等级＋1")
                local desc = skillDatas[event.addLevel].addition_float
                if desc ~= nil then
                    ccbOwner.tf_desc1:setString(string.split(desc, ";")[1])
                else
                    ccbOwner.node_1:setVisible(false)
                end
            end, function ()
                
            end,false)
        else
            self._effect:playAnimation("ccb/effects/SkillUpgarde2.ccbi", function (ccbOwner)
                ccbOwner.title_skill:setString("魂技等级＋1")
                local desc = skillDatas[1].addition_float
                if desc ~= nil then
                    ccbOwner.tf_desc1:setString(string.split(desc, ";")[1])
                else
                    ccbOwner.node_1:setVisible(false)
                end
            end, function ()
                
            end,false)
        end
    end
end

return QUIWidgetHeroSkillUpgrade