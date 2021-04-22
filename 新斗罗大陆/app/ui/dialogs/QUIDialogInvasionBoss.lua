
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogInvasionBoss = class("QUIDialogInvasionBoss", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QInvasionArrangement = import("...arrangement.QInvasionArrangement")
local QUIDialogBuyCount = import("..dialogs.QUIDialogBuyCount")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QVIPUtil = import("...utils.QVIPUtil")

local INTERVAL = 1
local MAX_INVASION_TOKEN = 10
local TOKEN_REFRESH = 60

function QUIDialogInvasionBoss:ctor(options)
    local ccbFile = "ccb/Dialog_Panjun_client.ccbi"
	local callBacks = {
                    {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
                    {ccbCallbackName = "onTriggerBuy", callback = handler(self, self._onTriggerBuy)},
                    {ccbCallbackName = "onTriggerNormalAttack", callback = handler(self, self._onTriggerNormalAttack)},
                    {ccbCallbackName = "onTriggerCriticalAttack", callback = handler(self, self._onTriggerCriticalAttack)},
                    {ccbCallbackName = "onTriggerSelectRobot", callback = handler(self, self._onTriggerSelectRobot)},
	}
    QUIDialogInvasionBoss.super.ctor(self, ccbFile, callBacks, options)

    self.isAnimation = true --是否动画显示
    TOKEN_REFRESH = (QStaticDatabase:sharedDatabase():getConfiguration()["INTRUSION_TOKEN_REPLY_TIME"].value or TOKEN_REFRESH) * 60

    self._bossId = options.bossId
    self._userId = options.userId
    self._afterBattle = options.afterBattle
    options.afterBattle = false
    self._closeNow = false
    self._isRobot = false --app:getUserOperateRecord():getRobotRebelSetting()

    self:setInfo()
end

function QUIDialogInvasionBoss:viewDidAppear()
    QUIDialogInvasionBoss.super.viewDidAppear(self)

    self._userProxy = cc.EventProxy.new(remote.user)
    self._userProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self, self.setInfo))

    QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_QUICKBATTLE, self.exitFromBattleHandler, self)
end

function QUIDialogInvasionBoss:viewWillDisappear()
    QUIDialogInvasionBoss.super.viewWillDisappear(self)

    if self._closeCD then
        scheduler.unscheduleGlobal(self._closeCD)
    end
    if self._cdInterval then
        scheduler.unscheduleGlobal(self._cdInterval)
    end
    if self._tokenCD then
        scheduler.unscheduleGlobal(self._tokenCD)
    end
    self._userProxy:removeAllEventListeners()

    QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_QUICKBATTLE, self.exitFromBattleHandler, self)

    -- app:getUserOperateRecord():setRobotRebelSetting( self._isRobot )
end

-- {actorId, hp, level, refresh}
function QUIDialogInvasionBoss:setInfo()
    self._invasion = nil
    local invasions = remote.invasion:getInvasions() or {}
    for i, invasion in pairs(invasions) do
        if invasion.bossId == self._bossId and self._userId == invasion.userId then
            self._invasion = invasion
            break
        end
    end
    if not self._invasion or self._invasion.bossId == 0 or self._invasion.bossHp == 0 then
        if not self._closeNow then
            self._closeNow = true
            self._closeCD = scheduler.performWithDelayGlobal(function ()
                self:popSelf()
            end,0)
        end
        return
    end

    self._ccbOwner.count:setString(string.format("%d/%d", self:_currentTokenNumber(TOKEN_REFRESH), MAX_INVASION_TOKEN))
    self._ccbOwner.normalCost:setString(self:_tokenNumberRequired(1))
    self._ccbOwner.criticalCost:setString(self:_tokenNumberRequired(2))
    self._ccbOwner.fight_tips:setColor(COLORS.k)
    -- self._ccbOwner.critical_tips:setColor(GAME_COLOR_LIGHT.stress)
    -- self._ccbOwner.criticalCost:setColor(GAME_COLOR_LIGHT.stress)

    local buyCount = remote.user.todayBuyIntrusionTokenCount or 0
    local totalVIPNum = QVIPUtil:getCountByWordField("intrusion_token", QVIPUtil:getMaxLevel())
    local totalNum = QVIPUtil:getCountByWordField("intrusion_token")

    local itemId = QStaticDatabase:sharedDatabase():getConfiguration()["INTRUSION_TOKEN_ITEM_ID"].value or 201
    if remote.items:getItemsNumByID(itemId) <= 0 then
        self._ccbOwner.btn_plus:setVisible(totalVIPNum > totalNum or totalNum > buyCount)
    end


    local level = self._invasion.fightCount + 1
    local maxLevel = db:getIntrusionMaximumLevel(self._invasion.bossId)
    level = math.min(level, maxLevel)

    -- Display boss character
    local avatar = QUIWidgetHeroInformation.new()
    self._ccbOwner.node_avatar:removeAllChildren()
    self._ccbOwner.node_avatar:addChild(avatar)
    avatar:setBackgroundVisible(false)
    avatar:setNameVisible(false)
    avatar:setStarVisible(false)
    avatar:setAvatar(self._invasion.bossId, 0.8)
    -- Set boss size and position
    local size, posX, posY = QStaticDatabase:sharedDatabase():getIntrusionPos(remote.user.level)
    avatar:setScale(size or 1)
    avatar:setPosition(ccp(posX or 0, posY or 0))

    self:_showBossHp(self._invasion.bossId, self._invasion.bossHp, level)
    self:_showTokenCD(TOKEN_REFRESH)

    if self._invasion.bossHp > 0 then
        if (self._afterBattle and self._invasion.userId == remote.user.userId and self._invasion.share == false) then
            app:alert({content="要邀请好友和宗门成员一起来击杀魂兽吗？（好友击杀魂兽，您也可以获得大量极品宝箱）", title="好友分享", callback = function(state)
                if state == ALERT_TYPE.CONFIRM then
                    remote.invasion:shareIntrusionBossRequest()
                end
            end}, false, true)
        end
        self._afterBattle = false
        self:_bossAlive(self._invasion.bossRefreshAt, self._invasion.bossHp, self._invasion.bossId, level, avatar)
    else
        self:_bossDead(avatar)
    end

    -- Highlight text in special moment
    if self:_specialMoment(1) then
        self._ccbOwner.specialMoment2:setColor(COLORS.n)
        self._ccbOwner.specialText2:setColor(COLORS.n)
        self._ccbOwner.specialText2:setString("获得的所有积分翻倍（未生效）")
        self._ccbOwner.specialText1:setString("2.5倍攻击次数消耗减半")

    elseif self:_specialMoment(2) then
        self._ccbOwner.specialMoment1:setColor(COLORS.n)
        self._ccbOwner.specialText1:setColor(COLORS.n)
        self._ccbOwner.specialText2:setString("获得的所有积分翻倍")
        self._ccbOwner.specialText1:setString("2.5倍攻击次数消耗减半（未生效）")
    else
        self._ccbOwner.specialMoment1:setColor(COLORS.n)
        self._ccbOwner.specialText1:setColor(COLORS.n)
        self._ccbOwner.specialMoment2:setColor(COLORS.n)
        self._ccbOwner.specialText2:setColor(COLORS.n)
        self._ccbOwner.specialText2:setString("获得的所有积分翻倍（未生效）")
        self._ccbOwner.specialText1:setString("2.5倍攻击次数消耗减半（未生效）")
    end

    self:_showRobotState()
end

function QUIDialogInvasionBoss:_bossAlive(refresh, hp, actorId, level, avatar)
    self._ccbOwner.isDead:setVisible(false)
    self._ccbOwner.runawayNode:setVisible(true)
    self._ccbOwner.isRunaway:setVisible(false)

    -- Set escape remaining time cd
    local cd = QStaticDatabase:sharedDatabase():getIntrusionEscapeTime(remote.user.level) * 60
    local timeDiff = math.floor((q.serverTime()*1000 - refresh)/1000)
    if timeDiff < cd then 
        local activityCD = cd - timeDiff
        self._ccbOwner.cd:setString(q.timeToHourMinuteSecond(activityCD, true))

        if self._cdInterval then scheduler.unscheduleGlobal(self._cdInterval) end
        self._cdInterval = scheduler.scheduleGlobal(handler(self, function ()
            activityCD = activityCD - INTERVAL

            if activityCD < 0 then
                scheduler.unscheduleGlobal(self._cdInterval)
                self._cdInterval = nil
                self:refresh()

                return
            end

            self._ccbOwner.cd:setString(q.timeToHourMinuteSecond(activityCD, true))
        end), INTERVAL)

        local function attackImpl(type)
            local tokenNeeded = self:_tokenNumberRequired(type)
            if tokenNeeded > self:_currentTokenNumber(TOKEN_REFRESH) then 
                self:_onTriggerBuy() 
                return
            end 
            if self._invasion == nil then
                app.tip:floatTip("数据出错~")
                return
            end
            self._invasionArrangement = QInvasionArrangement.new({hp = hp, actorId = actorId, level = level, type = type, invasion = self._invasion, token = tokenNeeded})
            if self._isRobot then
                local isTeamIsEmpty = self._invasionArrangement:checkTeamIsEmpty(self:safeHandler(handler(self, self._startRobot)))
                if not isTeamIsEmpty then
                    self:_startRobot()
                end
            else
                self:popSelf()
                app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement", 
                    options = {arrangement = self._invasionArrangement}})
            end
        end
        self._onTriggerNormalAttackImpl = function () attackImpl(1) end
        self._onTriggerCriticalAttackImpl = function () attackImpl(2) end
    else
        self:_bossEscaped(avatar)
    end
end

function QUIDialogInvasionBoss:_startRobot()
    local op = {}
    local invasion = remote.invasion:getSelfInvasion()
    -- QPrintTable(invasion)
    op.meritOldRank = invasion.allHurtRank or "无" --积分名次左
    op.damageOldRank = invasion.maxHurtRank or "无" --伤害名次左
    local oldInvasionMoney = remote.user.intrusion_money
    self._invasionArrangement:startQuickBattle(self:safeHandler(function(data)
            remote.user:update( data.wallet )
            --设置掉落的物品
            remote.invasion:setBattleItems(clone(data.intrusionFightEndAward))
            op.damage = data.userIntrusionResponse.deltaBossHp or 0 --造成伤害
            op.meritorious = (remote.invasion:getSelfInvasion().allHurt or 0) - (remote.invasion:getSelfOldInvasion().allHurt or 0) --获得积分
            op.meritNewRank = remote.invasion:getSelfInvasion().allHurtRank  --积分名次右
            op.damageNewRank = remote.invasion:getSelfInvasion().maxHurtRank --伤害名次右
            op.baseRebelToken = math.floor(self._invasionArrangement.token * 50 * data.userIntrusionResponse.criticalHit) --基础获得
            op.addRebelToken = remote.user.intrusion_money - oldInvasionMoney --总共获得
            op.callback = self:safeHandler(handler(self, self.exitFromBattleHandler))
            remote.activity:updateLocalDataByType(700, op.meritorious)
            -- remote.trailer:updateTaskProgressByTaskId("4000019", 1)
            app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogInvasionQuickRobotEnd", options = op}, {isPopCurrentDialog = false})
        end), function()
            remote.invasion:setInvasionUpdate(true)
            self:exitFromBattleHandler()
        end)
end

function QUIDialogInvasionBoss:_bossDead(avatar)
    self._ccbOwner.isDead:setVisible(true)
    self._ccbOwner.isRunaway:setVisible(false)
    self._ccbOwner.runawayNode:setVisible(false)
    self._bossState = 2

    makeNodeFromNormalToGray(avatar)
    avatar:pauseAnimation()

    self._onTriggerNormalAttackImpl = function () app.tip:floatTip("BOSS已被击败") end
    self._onTriggerCriticalAttackImpl = function () app.tip:floatTip("BOSS已被击败") end
end

function QUIDialogInvasionBoss:_bossEscaped(avatar)
    self._ccbOwner.runawayNode:setVisible(false)
    self._ccbOwner.isRunaway:setVisible(true)
    avatar:pauseAnimation()
    self._bossState = 3

    self._onTriggerNormalAttackImpl = function () app.tip:floatTip("BOSS已逃跑") end
    self._onTriggerCriticalAttackImpl = function () app.tip:floatTip("BOSS已逃跑") end
end

-- Display boss hp percent
function QUIDialogInvasionBoss:_showBossHp(actorId, hp, level)
    local function addMaskLayer(ccb, mask, scaleX, scaleY)
        local width = ccb:getContentSize().width * scaleX
        local height = ccb:getContentSize().height * scaleY
        local maskLayer = CCLayerColor:create(ccc4(0,0,0,150), width, height)
        maskLayer:setAnchorPoint(ccp(0, 0.5))
        maskLayer:setPosition(ccp(-width/2, -height/2))

        local ccclippingNode = CCClippingNode:create()
        ccclippingNode:setStencil(maskLayer)
        ccb:retain()
        ccb:removeFromParent()
        ccb:setPosition(ccp(-width/2, 0))
        ccclippingNode:addChild(ccb)
        ccb:release()

        mask:addChild(ccclippingNode)
        return maskLayer
    end
   
    -- local prefix = "优秀"
    -- if self._invasion.boss_type == 1 then
    --     prefix = "优秀"
    -- elseif self._invasion.boss_type == 2 then
    --     prefix = "精良"
    -- else
    --     prefix = "史诗"
    -- end
 
    local data = QStaticDatabase:sharedDatabase():getCharacterDataByID(actorId, level)
    local maxHP = (data.hp_value or 0) + (data.hp_grow or 0) * level
    local name = QStaticDatabase:sharedDatabase():getCharacterByID(actorId).name
    local title = string.format("%s(LV.%d)", name, level)
    self._ccbOwner.frame_tf_title:setString(title)
    local strWidth = self._ccbOwner.frame_tf_title:getContentSize().width + 80
    printInfo("~~~~~~~~~ strWidth == %s ·~~~~~~~~~~", strWidth)
    local titleWidth = math.max(286, strWidth)
    self._ccbOwner.frame_sp_title:setPreferredSize(CCSize(titleWidth, 50))
    -- self._ccbOwner.left:setPositionX(self._ccbOwner.frame_tf_title:getPositionX() - self._ccbOwner.frame_tf_title:getContentSize().width/2 - 10)
    -- self._ccbOwner.right:setPositionX(self._ccbOwner.frame_tf_title:getPositionX() + self._ccbOwner.frame_tf_title:getContentSize().width/2 + 10)

    local hpRatio = hp/maxHP
    hpRatio = hpRatio > 1 and 1 or (hpRatio < 0 and 0 or hpRatio)
    -- hpMask:setScaleX(hpRatio)
    if not self._hpBarClippingNode or not self._totalStencilWidth then
        self._hpBarClippingNode = q.newPercentBarClippingNode(self._ccbOwner.hp_bar)
        self._totalStencilWidth = self._ccbOwner.hp_bar:getContentSize().width * self._ccbOwner.hp_bar:getScaleX()
    end
    local stencil = self._hpBarClippingNode:getStencil()
    stencil:setPositionX(-self._totalStencilWidth + hpRatio*self._totalStencilWidth)



    local num,unit = q.convertLargerNumber(hp)
    local hpStr = num..(unit or "").."/"
    num,unit = q.convertLargerNumber(maxHP)
    hpStr = hpStr..num..(unit or "")
    self._ccbOwner.tf_hp:setString(hpStr)

    local fontColor = remote.invasion:getBossColorByType(self._invasion.boss_type)

    self._ccbOwner.frame_tf_title:setColor(fontColor)
    self._ccbOwner.frame_tf_title = setShadowByFontColor(self._ccbOwner.frame_tf_title, fontColor)
end

function QUIDialogInvasionBoss:_showTokenCD(interval) -- TODO, token CD has wrong elapsed time
    if self:_currentTokenNumber(interval) >= MAX_INVASION_TOKEN then 
        self._ccbOwner.token_cd:setVisible(false)
        return 
    end

    if self._tokenCD then 
        scheduler.unscheduleGlobal(self._tokenCD) 
    end

    local activityCD = math.floor((q.serverTime() * 1000 - remote.user.intrusion_token_refresh_at)/1000)
    local remainingCD = interval - math.fmod(activityCD, interval)
    self._ccbOwner.token_cd:setString("（"..q.timeToHourMinuteSecond(remainingCD, true).."）")
    self._ccbOwner.token_cd:setVisible(true)

    self._tokenCD = scheduler.scheduleGlobal(handler(self, function ()
        remainingCD = remainingCD - INTERVAL

        if remainingCD < 0 then
            scheduler.unscheduleGlobal(self._tokenCD)
            self._tokenCD = nil
            self:refresh()
            return
        end

        self._ccbOwner.token_cd:setString("（"..q.timeToHourMinuteSecond(remainingCD, true).."）")
    end), INTERVAL)
end

-- There will be discount at special time
-- Pass in token needed and return discounted token number
function QUIDialogInvasionBoss:_tokenNumberRequired(tokenNumber)
    if self:_specialMoment(1) then
        return math.ceil(tokenNumber/2)
    end

    return tokenNumber
end

function QUIDialogInvasionBoss:_specialMoment(type)
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

-- Invasion token grows every hour
-- Return the current token
function QUIDialogInvasionBoss:_currentTokenNumber(interval)
    local token = remote.user.intrusion_token
    if token < MAX_INVASION_TOKEN then
        local timeDiff = (q.serverTime() * 1000 - remote.user.intrusion_token_refresh_at)/1000
        local tokenGrown = math.floor(timeDiff/interval)
        return (token + tokenGrown > MAX_INVASION_TOKEN) and MAX_INVASION_TOKEN or (token + tokenGrown)
    end

    return token
end

function QUIDialogInvasionBoss:refresh( ... )
    self:setInfo()
end

function QUIDialogInvasionBoss:_onTriggerNormalAttack( event )
    if q.buttonEventShadow(event, self._ccbOwner.btn_putong) == false then return end
    self._onTriggerNormalAttackImpl()
end

function QUIDialogInvasionBoss:_onTriggerCriticalAttack(event )
    if q.buttonEventShadow(event, self._ccbOwner.btn_quanli) == false then return end
    self._onTriggerCriticalAttackImpl()
end

function QUIDialogInvasionBoss:_onTriggerSelectRobot()
    if app.unlock:checkLock("UNLOCK_RUQINGZIDONGZHANDOU", true) == false then
        return
    end
    self._isRobot = not self._isRobot
    self:_showRobotState()
end

function QUIDialogInvasionBoss:_showRobotState()
    self._ccbOwner.sp_gou:setVisible(self._isRobot)
end

function QUIDialogInvasionBoss:getItemInfo( )
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

function QUIDialogInvasionBoss:getBuyMoneyByBuyCount(buyCount)
    local tokeNum = 0
    local moneyInfo = db:getTokenConsumeByType(tostring(self._itemInfo.good_group_id)) or {}
    for _, value in pairs(moneyInfo) do
        if value.consume_times == buyCount + 1 then
            return value.money_num
        end
    end
    return moneyInfo[#moneyInfo].money_num
end

function QUIDialogInvasionBoss:calculaterDiscount(realMoney)
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

function QUIDialogInvasionBoss:_onTriggerBuy( event )
    if q.buttonEventShadow(event, self._ccbOwner.btn_plus) == false then return end
    local itemId = QStaticDatabase:sharedDatabase():getConfiguration()["INTRUSION_TOKEN_ITEM_ID"].value or 201
    if remote.items:getItemsNumByID(itemId) > 0 then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPacksackMultipleOpen", 
            options = {itemId = itemId, tips = "魂师大人，您的攻击次数不足，请使用征讨令恢复", callback = function (count)
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
                    self:setInfo()
                end
                app.tip:floatTip("使用成功，攻击次数增加"..count.."次")
            end)   
        end
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMallDetail", 
            options = {shopId = SHOP_ID.itemShop, itemInfo = self._itemInfo, btnName = "购买并使用", maxNum = self._maxCount, sale = self._sale, pos = self._itemInfo.position, callback = buyItem }}, {isPopCurrentDialog = false})
    end
end



function QUIDialogInvasionBoss:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogInvasionBoss:_onTriggerClose() -- TODO, update boss state on close
    app.sound:playSound("common_close")
    self:playEffectOut()

    if self:getOptions().closeCallback then
        local state = 1
        if self._ccbOwner.isRunaway:isVisible() then
            state = 3
        elseif self._ccbOwner.isDead:isVisible() then
            state = 2
        end
        self:getOptions().closeCallback(state)
    end
end

function QUIDialogInvasionBoss:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogInvasionBoss:exitFromBattleHandler()
    self._afterBattle = true
    self:setInfo()
end

return QUIDialogInvasionBoss

