
local QUIDialog = import("..Dialogs.QUIDialog")
local QUIDialogRobotForSocietySingle = class("QUIDialogRobotForSocietySingle", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QUIWidgetRobotSocietyDungeonBoss = import("..widgets.QUIWidgetRobotSocietyDungeonBoss")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QVIPUtil = import("...utils.QVIPUtil")
local QSocietyDungeonArrangement = import("...arrangement.QSocietyDungeonArrangement")

QUIDialogRobotForSocietySingle.EVENT_EXIT = "EVENT_EXIT"

function QUIDialogRobotForSocietySingle:ctor(options)
    local ccbFile = "ccb/Dialog_society_fuben_saodang.ccbi";
    local callBacks = 
    {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerPlus", callback = handler(self, self._onTriggerPlus)},
        {ccbCallbackName = "onTriggerPlusTen", callback = handler(self, self._onTriggerPlusTen)},
        {ccbCallbackName = "onTriggerSub", callback = handler(self, self._onTriggerSub)},
        {ccbCallbackName = "onTriggerSubTen", callback = handler(self, self._onTriggerSubTen)},
        {ccbCallbackName = "onTriggerBuy", callback = handler(self, self._onTriggerBuy)},
        {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
    }
    QUIDialogRobotForSocietySingle.super.ctor(self,ccbFile,callBacks,options)
    self.isAnimation = true
    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._curHp = options.bossHp
    self._curHurt = options.allHurt or 0
    self._chapter = options.chapter
    self._wave = options.wave
    self._activityBuffList = options.activityBuffList

    self._fightCounts = 0
    self._robotCounts = 1
    self._scoietyWaveConfig = QStaticDatabase.sharedDatabase():getScoietyWave(self._wave, self._chapter)
    self._bossId = self._scoietyWaveConfig.boss
    self._bossLevel = self._scoietyWaveConfig.levels
    self._little_monster = self._scoietyWaveConfig.little_monster

    self:_init()
end

function QUIDialogRobotForSocietySingle:_init()
    -- 初始化标题
    local character = QStaticDatabase.sharedDatabase():getCharacterByID(self._bossId)
    self._ccbOwner.frame_tf_title = setShadow5(self._ccbOwner.frame_tf_title)
    self._ccbOwner.frame_tf_title:setString(character.name)

    local scale = self._scoietyWaveConfig.boss_small_scale or 1
    -- 初始化BOSS形象
    if not self._avatarHero then
        self._ccbOwner.node_avatar:setScaleX( -scale )
        self._ccbOwner.node_avatar:setScaleY( scale )
        self._avatarHero = QUIWidgetActorDisplay.new(self._bossId)
        self._ccbOwner.node_avatar:addChild(self._avatarHero)
    end
    local isFinalBoss = remote.union:checkIsFinalWave(self._chapter, self._wave)
    if isFinalBoss then
        self._avatarHero:setOpacity(UNION_DUNGEON_MAX_BOSS_OPACITY)
    end

    -- 刷新BOSS血条
    self:updateHp()

    -- 初始化可挑战BOSS次数
    local userConsortia = remote.user:getPropForKey("userConsortia")
    self._fightCounts = userConsortia.consortia_boss_fight_count
    self:updateFightCount(self._fightCounts)
    self:updateRobotCount()

    -- 初始化BOSS说明
    local tbl = QStaticDatabase.sharedDatabase():getScoietyWave(self._wave, self._chapter)
    if tbl and tbl.wenan_type then
        self._ccbOwner.tf_boss_explain:setString(tbl.wenan_type)
    else
        self._ccbOwner.tf_boss_explain:setString("")
    end
end

function QUIDialogRobotForSocietySingle:viewDidAppear()
    QUIDialogRobotForSocietySingle.super.viewDidAppear(self)

    self.unionProxy = cc.EventProxy.new(remote.union)
    self.unionProxy:addEventListener(remote.union.SOCIETY_BUY_FIGHT_COUNT_SUCCESS, handler(self, self.updateUnionHandler))

    local userConsortia = remote.user:getPropForKey("userConsortia")
    self._fightCounts = userConsortia.consortia_boss_fight_count
    self:updateFightCount(self._fightCounts)
    self:updateRobotCount()
end

function QUIDialogRobotForSocietySingle:viewWillDisappear()
    QUIDialogRobotForSocietySingle.super.viewWillDisappear(self)

    self.unionProxy:removeAllEventListeners()
end

function QUIDialogRobotForSocietySingle:_onTriggerPlus(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_plusOne) == false then return end
    app.sound:playSound("common_small")
    self._robotCounts = self._robotCounts + 1
    self:updateRobotCount()
end
function QUIDialogRobotForSocietySingle:_onTriggerPlusTen(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_plusTen) == false then return end
    app.sound:playSound("common_small")
    self._robotCounts = self._robotCounts + 10
    self:updateRobotCount()
end
function QUIDialogRobotForSocietySingle:_onTriggerSub(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_subOne) == false then return end
    app.sound:playSound("common_small")
    self._robotCounts = self._robotCounts - 1
    self:updateRobotCount()
end
function QUIDialogRobotForSocietySingle:_onTriggerSubTen(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_subTen) == false then return end
    app.sound:playSound("common_small")
    self._robotCounts = self._robotCounts - 10
    self:updateRobotCount()
end

function QUIDialogRobotForSocietySingle:_onTriggerBuy(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_plus) == false then return end
    if remote.union:checkUnionDungeonIsOpen(true) == false then
        return
    end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBuyCountBase", options = {cls = "QBuyCountUnionInstance"}}, {isPopCurrentDialog = false})
end

function QUIDialogRobotForSocietySingle:_onTriggerClose(e)
    if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
    self._isStartRobot = false
    self:close()
end

function QUIDialogRobotForSocietySingle:_onTriggerOK(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_ok) == false then return end
    app.sound:playSound("common_small")

    if self._robotCounts > self._fightCounts then
        app.tip:floatTip("魂师大人，您攻击次数不足～")
        return
    end

    local isFinalBoss = remote.union:checkIsFinalWave(self._chapter, self._wave)
    if isFinalBoss or self._curHp > 0 then 
        local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.SOCIETYDUNGEON_ATTACK_TEAM)

        local societyDungeonArrangement = QSocietyDungeonArrangement.new({})
        local isTeamIsEmpty = societyDungeonArrangement:checkTeamIsEmpty(self:safeHandler(function()
            self._isStartRobot = true
            self:close()
        end))
        if not isTeamIsEmpty then
            self._isStartRobot = true
            self:close()
        end
    else
        app.tip:floatTip("魂师大人，BOSS已被击败了")
        return
    end
end

function QUIDialogRobotForSocietySingle:close()
    app.sound:playSound("common_close")
    self:playEffectOut()
end

function QUIDialogRobotForSocietySingle:viewAnimationOutHandler()
    self:popSelf()

    if self._isStartRobot then
        self:startRobot()
    end
end

function QUIDialogRobotForSocietySingle:startRobot()
    -- print("QUIDialogRobotForSocietySingle:startRobot()  ", self._robotCounts)
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRobotForSocietyInformation",
        options = {wave = self._wave, chapter = self._chapter, count = self._robotCounts, activityBuffList = self._activityBuffList }})
end

function QUIDialogRobotForSocietySingle:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogRobotForSocietySingle:updateUnionHandler( event )
    if event.name == remote.union.SOCIETY_BUY_FIGHT_COUNT_SUCCESS then
        local userConsortia = remote.user:getPropForKey("userConsortia")
        self._fightCounts = userConsortia.consortia_boss_fight_count
        self:updateFightCount(self._fightCounts)
        self:updateRobotCount()
    end
end

function QUIDialogRobotForSocietySingle:updateHp( curHp )
    local isFinalBoss = remote.union:checkIsFinalWave(self._chapter, self._wave)
    if not self._percentBarClippingNode then
        self._percentBarClippingNode = q.newPercentBarClippingNode(self._ccbOwner.sp_hp)
        self._totalStencilWidth = self._ccbOwner.sp_hp:getContentSize().width * self._ccbOwner.sp_hp:getScaleX()
    end

    if curHp then self._curHp = curHp end
    local curHp = 0
    local totalHp = self:getTotalHp( self._bossId, self._bossLevel )
    local curUnit = ""
    local totalUnit = ""
    local sx = self._curHp / totalHp
    if isFinalBoss then
        curHp, curUnit = q.convertLargerNumber(self._curHurt)
        totalHp, totalUnit = q.convertLargerNumber(totalHp)
        sx = 1
        self._ccbOwner.tf_hp:setString(curHp..(curUnit or "").." / ???")
    else
        curHp, curUnit = q.convertLargerNumber(self._curHp)
        totalHp, totalUnit = q.convertLargerNumber(totalHp)
        self._ccbOwner.tf_hp:setString(curHp..(curUnit or "").." / "..totalHp..(totalUnit or ""))
    end
    local stencil = self._percentBarClippingNode:getStencil()
    stencil:setPositionX(-self._totalStencilWidth + sx*self._totalStencilWidth)
end

function QUIDialogRobotForSocietySingle:getTotalHp( bossId, bossLevel )
    if not self._bossId or not self._bossLevel then return 0 end

    if not bossId then bossId = self._bossId end
    if not bossLevel then bossLevel = self._bossLevel end

    local characterData = QStaticDatabase.sharedDatabase():getCharacterDataByID( bossId, bossLevel )
    local totalHp = characterData.hp_value + characterData.hp_grow * characterData.npc_level

    return totalHp
end

function QUIDialogRobotForSocietySingle:updateFightCount( fightCount )
    self._fightCounts = fightCount
    self._ccbOwner.tf_fight_count:setString( "攻击次数："..fightCount )

    local buyCount = remote.user.userConsortia.consortia_boss_buy_count or 0
    if remote.user.userConsortia.consortia_boss_buy_at ~= nil and q.refreshTime(remote.user.c_systemRefreshTime) > remote.user.userConsortia.consortia_boss_buy_at then
        buyCount = 0
    end
    local totalVIPNum = QVIPUtil:getCountByWordField("sociaty_chapter_times", QVIPUtil:getMaxLevel())
    local totalNum = QVIPUtil:getCountByWordField("sociaty_chapter_times")
    self._ccbOwner.btn_plus:setVisible(totalVIPNum > totalNum or totalNum > buyCount)
end

function QUIDialogRobotForSocietySingle:updateRobotCount()
    if self._robotCounts > self._fightCounts then self._robotCounts = self._fightCounts end
    if self._robotCounts < 1 then self._robotCounts = 1 end
    self._ccbOwner.tf_num1:setString(self._robotCounts)
    self._ccbOwner.tf_num2:setString("/"..self._fightCounts)
end

return QUIDialogRobotForSocietySingle