-- @Author: xurui
-- @Date:   2019-01-10 11:03:27
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-03-18 14:43:58
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogInvasionFastFight = class("QUIDialogInvasionFastFight", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QVIPUtil = import("...utils.QVIPUtil")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QInvasionArrangement = import("...arrangement.QInvasionArrangement")

local MAX_INVASION_TOKEN = 10
local TOKEN_REFRESH = 60

function QUIDialogInvasionFastFight:ctor(options)
	local ccbFile = "ccb/Dialog_EliteBattleAgain_zidongsaodang.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerBuy", callback = handler(self, self._onTriggerBuy)},
        {ccbCallbackName = "onTriggerSelectFightType1", callback = handler(self, self._onTriggerSelectFightType1)},
        {ccbCallbackName = "onTriggerSelectFightType2", callback = handler(self, self._onTriggerSelectFightType2)},
        {ccbCallbackName = "onTriggerSelectFightCount", callback = handler(self, self._onTriggerSelectFightCount)},
        {ccbCallbackName = "onTriggerSelectShare", callback = handler(self, self._onTriggerSelectShare)},
        {ccbCallbackName = "onTriggerFastFight", callback = handler(self, self._onTriggerFastFight)},
    }
    QUIDialogInvasionFastFight.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

    TOKEN_REFRESH = (QStaticDatabase:sharedDatabase():getConfiguration()["INTRUSION_TOKEN_REPLY_TIME"].value or TOKEN_REFRESH) * 60

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
	    self._bossId = options.bossId
	    self._userId = options.userId
	    self._afterBattle = options.afterBattle
    end

    self._bossInfo = {}
    
    self._selectFightType = app:getUserOperateRecord():getInvasionFastFightSetting("fightType") or 1
    self._selectFightCount = app:getUserOperateRecord():getInvasionFastFightSetting("fightCount") or false
    self._selectShare = app:getUserOperateRecord():getInvasionFastFightSetting("share") or false
end

function QUIDialogInvasionFastFight:viewDidAppear()
	QUIDialogInvasionFastFight.super.viewDidAppear(self)

	self:setInfo()

    self:setSelectInfo()
end

function QUIDialogInvasionFastFight:viewWillDisappear()
  	QUIDialogInvasionFastFight.super.viewWillDisappear(self)

    if self._cdInterval then 
        scheduler.unscheduleGlobal(self._cdInterval) 
        self._cdInterval = nil
    end

    if self._closeCD then 
        scheduler.unscheduleGlobal(self._closeCD) 
        self._closeCD = nil
    end

    app:getUserOperateRecord():setInvasionFastFightSetting("fightType", self._selectFightType)
    app:getUserOperateRecord():setInvasionFastFightSetting("fightCount", self._selectFightCount )
    app:getUserOperateRecord():setInvasionFastFightSetting("share", self._selectShare )
end

function QUIDialogInvasionFastFight:setInfo()
    local invasions = remote.invasion:getInvasions() or {}
    for i, invasion in pairs(invasions) do
        if invasion.bossId == self._bossId and self._userId == invasion.userId then
            self._bossInfo = invasion
            break
        end
    end
    if not self._bossInfo or self._bossInfo.bossId == 0 or self._bossInfo.bossHp == 0 then
        if not self._closeNow then
            self._closeNow = true
            self._closeCD = scheduler.performWithDelayGlobal(function ()
                self:popSelf()
            end, 0)
        end
        return
    end
    local buyCount = remote.user.todayBuyIntrusionTokenCount or 0
    local totalVIPNum = QVIPUtil:getCountByWordField("intrusion_token", QVIPUtil:getMaxLevel())
    local totalNum = QVIPUtil:getCountByWordField("intrusion_token")

    local itemId = QStaticDatabase:sharedDatabase():getConfiguration()["INTRUSION_TOKEN_ITEM_ID"].value or 201
    if remote.items:getItemsNumByID(itemId) <= 0 then
        self._ccbOwner.btn_plus:setVisible(totalVIPNum > totalNum or totalNum > buyCount)
    end

    if self._bossInfo.userId ~= remote.user.userId then
        self._ccbOwner.node_share:setVisible(false)
        self._selectShare = false
    end

    self:setBoosInfo()

    self:setFightCount()

    self:setCDTime()
end

function QUIDialogInvasionFastFight:setBoosInfo()
    local level = self._bossInfo.fightCount + 1
    local maxLevel = db:getIntrusionMaximumLevel(self._bossInfo.bossId)
    level = math.min(level, maxLevel)
    local data = QStaticDatabase:sharedDatabase():getCharacterDataByID(self._bossInfo.bossId, level)
    local maxHP = (data.hp_value or 0) + (data.hp_grow or 0) * level
    local name = QStaticDatabase:sharedDatabase():getCharacterByID(self._bossInfo.bossId).name

    -- Display boss character
    local avatar = QUIWidgetHeroInformation.new()
    self._ccbOwner.node_boss_avatar:removeAllChildren()
    self._ccbOwner.node_boss_avatar:addChild(avatar)
    avatar:setBackgroundVisible(false)
    avatar:setNameVisible(false)
    avatar:setStarVisible(false)
    avatar:setAvatar(self._bossInfo.bossId, 0.8)
    local size, posX, posY = QStaticDatabase:sharedDatabase():getIntrusionPos(remote.user.level)
    avatar:setScale(size or 1)
    avatar:setPosition(ccp(posX or 0, posY or 0))

    local title = string.format("%s(LV.%d)", name, level)
    self._ccbOwner.frame_tf_title:setString(title)
    local strWidth = self._ccbOwner.frame_tf_title:getContentSize().width + 80
    local titleWidth = math.max(286, strWidth)
    self._ccbOwner.frame_sp_title:setPreferredSize(CCSize(titleWidth, 50))

    local hpRatio = self._bossInfo.bossHp/maxHP
    hpRatio = hpRatio > 1 and 1 or (hpRatio < 0 and 0 or hpRatio)
    if not self._hpBarClippingNode or not self._totalStencilWidth then
        self._hpBarClippingNode = q.newPercentBarClippingNode(self._ccbOwner.sp_progress)
        self._totalStencilWidth = self._ccbOwner.sp_progress:getContentSize().width * self._ccbOwner.sp_progress:getScaleX()
    end
    local stencil = self._hpBarClippingNode:getStencil()
    stencil:setPositionX(-self._totalStencilWidth + hpRatio*self._totalStencilWidth)

    local num,unit = q.convertLargerNumber(self._bossInfo.bossHp)
    local hpStr = num..(unit or "").."/"
    num,unit = q.convertLargerNumber(maxHP)
    hpStr = hpStr..num..(unit or "")
    self._ccbOwner.tf_progress:setString(hpStr)

    local fontColor = remote.invasion:getBossColorByType(self._bossInfo.boss_type)
    
    self._ccbOwner.frame_tf_title:setColor(fontColor)
    self._ccbOwner.frame_tf_title = setShadowByFontColor(self._ccbOwner.frame_tf_title, fontColor)
end

function QUIDialogInvasionFastFight:setFightCount()
    self._ccbOwner.tf_fight_count:setString(string.format("%d/%d", self:_currentTokenNumber(TOKEN_REFRESH), MAX_INVASION_TOKEN))
    self._ccbOwner.tf_special_count:setString(self:_tokenNumberRequired(2))
end

function QUIDialogInvasionFastFight:setCDTime()
    if self._cdInterval then 
        scheduler.unscheduleGlobal(self._cdInterval) 
        self._cdInterval = nil
    end

    local refreshTime = (self._bossInfo.bossRefreshAt or 0) / 1000
    local cd = QStaticDatabase:sharedDatabase():getIntrusionEscapeTime(remote.user.level) * 60
    local timeDiff = math.floor(q.serverTime() - refreshTime)
    if timeDiff < cd then 
        local activityCD = cd - timeDiff
        self._ccbOwner.tf_time:setString(q.timeToHourMinuteSecond(activityCD, true))

        self._cdInterval = scheduler.scheduleGlobal(handler(self, function ()
            activityCD = activityCD - 1

            if activityCD < 0 then
                scheduler.unscheduleGlobal(self._cdInterval)
                self._cdInterval = nil
                self:_bossEscaped()
                return
            end

            self._ccbOwner.tf_time:setString(q.timeToHourMinuteSecond(activityCD, true))
        end), 1)
    else
        self:_bossEscaped()
    end
end

function QUIDialogInvasionFastFight:_bossEscaped()
    self._onTriggerFastFight = function () app.tip:floatTip("BOSS已逃跑") end
end

function QUIDialogInvasionFastFight:setSelectInfo()
    self._ccbOwner.sp_fight_type_1:setVisible(self._selectFightType == 1)
    self._ccbOwner.sp_fight_type_2:setVisible(self._selectFightType == 2)

    self._ccbOwner.sp_fight_count:setVisible(self._selectFightCount)

    self._ccbOwner.sp_share:setVisible(self._selectShare)
end

function QUIDialogInvasionFastFight:_currentTokenNumber(interval)
    local token = remote.user.intrusion_token
    if token < MAX_INVASION_TOKEN then
        local timeDiff = (q.serverTime() * 1000 - remote.user.intrusion_token_refresh_at)/1000
        local tokenGrown = math.floor(timeDiff/interval)
        return (token + tokenGrown > MAX_INVASION_TOKEN) and MAX_INVASION_TOKEN or (token + tokenGrown)
    end

    return token
end

function QUIDialogInvasionFastFight:getItemInfo( )
    self._itemInfo = {}
    local shopItems = remote.stores:getStoresById(SHOP_ID.itemShop)
    for i, v in pairs(shopItems) do
        if v.id == 201 then
            self._itemInfo = v
            break
        end
    end
    local money = self:getBuyMoneyByBuyCount(self._itemInfo.buy_count)
    self._sale = self:calculaterDiscount(money)
end

function QUIDialogInvasionFastFight:getBuyMoneyByBuyCount(buyCount)
    local tokeNum = 0
    local moneyInfo = db:getTokenConsumeByType(tostring(self._itemInfo.good_group_id)) or {}
    for _, value in pairs(moneyInfo) do
        if value.consume_times == buyCount + 1 then
            return value.money_num
        end
    end
    return moneyInfo[#moneyInfo].money_num
end

function QUIDialogInvasionFastFight:calculaterDiscount(realMoney)
    local discount = {0, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5}
    local goodInfo = db:getGoodsGroupByGroupId(self._itemInfo.good_group_id)
    local money = goodInfo.money_num_1 or 0

    local maxCount = QVIPUtil:getMallItemMaxCountByVipLevel(self._itemInfo.good_group_id, QVIPUtil:VIPLevel())
    self._maxCount = maxCount

    local sale = realMoney/money * 10
    for i = 2, #discount do
        if sale < discount[i] then
            sale = discount[i-1]
            break
        end
    end
    
    return sale
end

function QUIDialogInvasionFastFight:_tokenNumberRequired(tokenNumber)
    if self:_specialMoment(1) then
        return math.ceil(tokenNumber/2)
    end

    return tokenNumber
end

function QUIDialogInvasionFastFight:_specialMoment(type)
    local hour = q.date("%H", q.serverTime())
    if type == 1 then
        if tonumber(hour) == 9 or tonumber(hour) == 10 or tonumber(hour) == 11 or tonumber(hour) == 12 or tonumber(hour) == 13 then
            return true
        end
    else
        local value = QStaticDatabase:sharedDatabase():getConfiguration()["INTRUSION_HURT_DOUBLE"].value
        local minHours = string.split(value,"#")
        return tonumber(hour) >= tonumber(minHours[1]) and tonumber(hour) < tonumber(minHours[2])
    end

    return false
end

function QUIDialogInvasionFastFight:_onTriggerBuy( event )
    if q.buttonEventShadow(event, self._ccbOwner.btn_plus) == false then return end    
    local itemId = QStaticDatabase:sharedDatabase():getConfiguration()["INTRUSION_TOKEN_ITEM_ID"].value or 201
    if remote.items:getItemsNumByID(itemId) > 0 then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPacksackMultipleOpen", 
            options = {itemId = itemId, tips = "魂师大人，您的攻击次数不足，请使用征讨令恢复", callback = function (count)
                if self:safeCheck() then
                    self:setFightCount()
                end
                app.tip:floatTip("使用成功，攻击次数增加"..count.."次")
            end}}, {isPopCurrentDialog = false})
    else
        self:getItemInfo()

        if self._maxCount - self._itemInfo.buy_count == 0 then
            if QVIPUtil:VIPLevel() < QVIPUtil:getMaxLevel() then
                app:vipAlert({content="购买次数已达上限，提升VIP等级可提高购买次数上限"}, false)
            else
                app.tip:floatTip("今日的购买次数已用完")
            end
            return
        end

        local buyItem = function(data)
            local count = data.num
            app:getClient():openItemPackage(self._itemInfo.id, count, function(data)
                if self:safeCheck() then
                    self:setFightCount()
                end
                app.tip:floatTip("使用成功，攻击次数增加"..count.."次")
            end)   
        end
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMallDetail", 
            options = {shopId = SHOP_ID.itemShop, itemInfo = self._itemInfo, btnName = "购买并使用", maxNum = self._maxCount, sale = self._sale, pos = self._itemInfo.position, callback = buyItem }}, {isPopCurrentDialog = false})
    end
end

function QUIDialogInvasionFastFight:_onTriggerSelectFightType1()
    if self._selectFightType == 1 then return end

    self._selectFightType = 1
    self:setSelectInfo()
end

function QUIDialogInvasionFastFight:_onTriggerSelectFightType2()
    if self._selectFightType == 2 then return end

    self._selectFightType = 2
    self:setSelectInfo()
end

function QUIDialogInvasionFastFight:_onTriggerSelectFightCount()
    self._selectFightCount = not self._selectFightCount
    self:setSelectInfo()
end

function QUIDialogInvasionFastFight:_onTriggerSelectShare()
    self._selectShare = not self._selectShare
    self:setSelectInfo()
end

function QUIDialogInvasionFastFight:_onTriggerFastFight(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_fastFight) == false then return end
    if self._bossInfo.bossId == 0 then
        app.tip:floatTip("魂师大人，BOSS已被击败了")
    elseif self._bossInfo.bossHp > 0 then 
        local tokenNeeded = self:_tokenNumberRequired(self._selectFightType)
        if tokenNeeded > self:_currentTokenNumber(TOKEN_REFRESH) then 
            self:_onTriggerBuy() 
            return
        end 

        local hp = self._bossInfo.bossHp
        local actorId = self._bossInfo.bossId
        local level = self._bossInfo.fightCount + 1
        local oldInvasionInfo = clone(remote.invasion:getSelfInvasion())

        local invasionArrangement = QInvasionArrangement.new({hp = hp, actorId = actorId, level = level, type = self._selectFightType, invasion = self._bossInfo, token = tokenNeeded})
        local fightStart = function()
            local isAllOut = false
            if self._selectFightType == 2 then
                isAllOut = true
            end
            invasionArrangement:startFastFight(self._selectFightCount, isAllOut, self._selectShare, function(data)
                    local fightCount = data.gfEndResponse.intrusionQuickFightResponse.fightCount or 0
                    remote.activity:updateLocalDataByType(531, fightCount)
                    remote.user:addPropNumForKey("c_fortressFightCount", fightCount)

                    app.taskEvent:updateTaskEventProgress(app.taskEvent.INVATION_EVENT, fightCount, false, true)

                    remote.invasion:setAfterBattle(true)

                    local fightResult = data.gfEndResponse.intrusionQuickFightResponse.fightResult
                    local newInvasionInfo = clone(remote.invasion:getSelfInvasion())
                    local userComeBackRatio = data.userComeBackRatio or 1

                    if self:safeCheck() and q.isEmpty(fightResult) == false then
                        self:showFastFightDialog(oldInvasionInfo, newInvasionInfo, fightResult, userComeBackRatio)
                    end
                end)
        end

        local isTeamIsEmpty = invasionArrangement:checkTeamIsEmpty(self:safeHandler(function()
            fightStart()
        end))
        if not isTeamIsEmpty then
            fightStart()
        end
    else
        app.tip:floatTip("魂师大人，BOSS已被击败了")
    end
end
 
function QUIDialogInvasionFastFight:showFastFightDialog(oldInvasionInfo, newInvasionInfo, fightResult, userComeBackRatio)
    self:popSelf()
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogUnityFastBattle",
        options = {fast_type = FAST_FIGHT_TYPE.BOSS_FAST,oldInvasionInfo = oldInvasionInfo, newInvasionInfo = newInvasionInfo, fightResult = fightResult, bossInfo = self._bossInfo, userComeBackRatio = userComeBackRatio}}) 
end

function QUIDialogInvasionFastFight:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogInvasionFastFight:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogInvasionFastFight:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogInvasionFastFight
