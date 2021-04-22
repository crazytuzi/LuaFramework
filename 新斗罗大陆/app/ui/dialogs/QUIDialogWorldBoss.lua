-- @Author: xurui
-- @Date:   2016-10-21 09:56:49
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-05-29 15:41:29
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogWorldBoss = class("QUIDialogWorldBoss", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QWorldBossArrangement = import("...arrangement.QWorldBossArrangement")
local QUIDialogBuyCount = import("..dialogs.QUIDialogBuyCount")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QRichText = import("...utils.QRichText") 
local QVIPUtil = import("...utils.QVIPUtil")
local QUIWidgetWorldBossGloryWall = import("..widgets.QUIWidgetWorldBossGloryWall")
local QNotificationCenter = import("...controllers.QNotificationCenter")

QUIDialogWorldBoss.NO_FIGHT_HEROES = "还未设置战队，无法参加战斗！现在就设置战队？"

function QUIDialogWorldBoss:ctor(options)
	local ccbFile = "ccb/Dialog_Panjun_Boss.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerRecord", callback = handler(self, self._onTriggerRecord)},
		{ccbCallbackName = "onTriggerAwards", callback = handler(self, self._onTriggerAwards)},
        {ccbCallbackName = "onTriggerRank", callback = handler(self, self._onTriggerRank)},
		{ccbCallbackName = "onTriggerBuff", callback = handler(self, self._onTriggerBuff)},
		{ccbCallbackName = "onTriggerPlus", callback = handler(self, self._onTriggerPlus)},
        {ccbCallbackName = "onTriggerRule", callback = handler(self, self._onTriggerRule)},
        {ccbCallbackName = "onTriggerClickBoss", callback = handler(self, self._onTriggerClickBoss)},
        {ccbCallbackName = "onTriggerFastFighter", callback = handler(self, self._onTriggerFastFighter)},
	}
	QUIDialogWorldBoss.super.ctor(self, ccbFile, callBack, options)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if page and page.setManyUIVisible then page:setManyUIVisible() end
    if page and page.setScalingVisible then page:setScalingVisible(false) end
    if page and page.topBar and page.topBar.showWithInvasion then
        page.topBar:showWithInvasion()
    end
    CalculateUIBgSize(self._ccbOwner.node_sp, 1280)
    self._bossInfo = {}
    self._buffList = {}
    self._database = QStaticDatabase:sharedDatabase()
    self._canFight = true
    self._bossIsLive = options.bossIsLive
    self._schedulers = {}
    self._index = 1
    self._curBuffId = 9  -- 暂时写死，以后可能支持多buff

    self._ccbOwner.tf_my_meritorious = setShadow5(self._ccbOwner.tf_my_meritorious)
    self._ccbOwner.tf_union_meritorious = setShadow5(self._ccbOwner.tf_union_meritorious)
    self._ccbOwner.tf_max_damage = setShadow5(self._ccbOwner.tf_max_damage) 
    self._ccbOwner.tf_hp = setShadow5(self._ccbOwner.tf_hp)
    self._ccbOwner.tf_boss_name = setShadow5(self._ccbOwner.tf_boss_name)
    self._ccbOwner.tf_time_title = setShadow5(self._ccbOwner.tf_time_title)
    self._ccbOwner.tf_next_time = setShadow5(self._ccbOwner.tf_next_time)

    self:resetAll()
end

function QUIDialogWorldBoss:viewDidAppear()
	QUIDialogWorldBoss.super.viewDidAppear(self)

    QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)

    self._bossProxy = cc.EventProxy.new(remote.worldBoss)
    self._bossProxy:addEventListener(remote.worldBoss.UPDATE_WORLDBOSS_INFO, handler(self, self.setBossInfo))
    self._bossProxy:addEventListener(remote.worldBoss.SEND_WORLDBOSS_KILL_INFO, handler(self, self._setBossHurtInfo))
    self._bossProxy:addEventListener(remote.worldBoss.UPDATE_WORLDBOSS_AWARDS_INFO, handler(self, self.checkRedTips))
    self._bossProxy:addEventListener(remote.worldBoss.UPDATE_WORLDBOSS_BUY_COUNT, handler(self, self.setBottomBarInfo))

    remote.worldBoss:requestWorldBossInfo(false, function()
        if self:safeCheck() then
            self:setBuffInfo()
            self:setBossInfo()
            self:checkRedTips()
        end
    end)
	self:addBackEvent(false)

    if not app.unlock:checkLock("UNLOCK_WHALE_AUTO", false) then
        self._ccbOwner.fast_fight_node:setVisible(false)
    else
        self._ccbOwner.fast_fight_node:setVisible(true)
    end

end

function QUIDialogWorldBoss:viewWillDisappear()
	QUIDialogWorldBoss.super.viewWillDisappear(self)

    QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)

    self._bossProxy:removeAllEventListeners()
    self._bossProxy = nil

    if self._buffScheduler then
        scheduler.unscheduleGlobal(self._buffScheduler)
        self._buffScheduler = nil
    end

    if self["BOSS_COMING_DOWN"] ~= nil then
        scheduler.unscheduleGlobal(self["BOSS_COMING_DOWN"])
        self["BOSS_COMING_DOWN"] = nil
    end
    if self["BOSS_LOCK"] ~= nil then
        scheduler.unscheduleGlobal(self["BOSS_LOCK"])
        self["BOSS_LOCK"] = nil
    end
    if self._fightCountScheduler ~= nil then
        scheduler.unscheduleGlobal(self._fightCountScheduler)
        self._fightCountScheduler = nil
    end
    if self._schedulers ~= nil then
        for _,handler in ipairs(self._schedulers) do
            scheduler.unscheduleGlobal(handler)
        end
    end
    
    self._schedulers = {}
    self._index = 1

    if app:getClient() then
        app:getClient():quitScene(SceneEnum.SCENE_WORLD_BOSS)
    end

	self:removeBackEvent()
end

function QUIDialogWorldBoss:exitFromBattleHandler() 
    if self:safeCheck() then
        self:setBuffInfo()
        self:setBossInfo()
        self:checkRedTips()
    end
end

function QUIDialogWorldBoss:resetAll()
    self._ccbOwner.node_boss:setVisible(false)
    self._ccbOwner.node_no_boss:setVisible(false)
    self._ccbOwner.node_bg_open:setVisible(false)
    -- self._ccbOwner.node_bottom_bar:setVisible(false)
    self._ccbOwner.tf_my_meritorious:setString("")
    self._ccbOwner.tf_union_meritorious:setString("")
    self._ccbOwner.tf_max_damage:setString("")
    self._ccbOwner.sp_award_tips:setVisible(false)
    self._ccbOwner.sp_record_tips:setVisible(false)
    self._ccbOwner.node_have:setVisible(false)
    self._ccbOwner.node_no:setVisible(false)
    self._ccbOwner.node_time:setVisible(false)
    self._ccbOwner.node_plus:setVisible(false)
    self._ccbOwner.node_buff:setVisible(false)
end

function QUIDialogWorldBoss:setBuffInfo()
    self._bossInfo = remote.worldBoss:getWorldBossInfo() 
    local isUnlock = remote.worldBoss:checkWorldBossIsUnlock()
    local buff = self._database:getScoietyDungeonBuff(self._curBuffId)
    if isUnlock then
        self._ccbOwner.node_buff:setVisible(true)
        local startHour, endHour = remote.worldBoss:getBuffTimeHoursById( self._bossInfo.additionTimeId )
        if startHour and endHour then
            self._ccbOwner.tf_buff_time:setString(startHour..":00~"..endHour..":00")
            self._ccbOwner.tf_buff_value:setString(buff.buff_des)
        else
            if remote.user.userConsortia and remote.user.userConsortia.consortiaId and remote.user.userConsortia.consortiaId ~= "" then
                self._ccbOwner.tf_buff_time:setString("未设置")
                self._ccbOwner.tf_buff_value:setString(buff.buff_des)
            else
                self._ccbOwner.tf_buff_time:setString("")
                self._ccbOwner.tf_buff_value:setString("无宗门，无法享受加成")
            end
        end

        -- 和时间有关的数据
        self:_updateTime()
        if self._buffScheduler then
            scheduler.unscheduleGlobal(self._buffScheduler)
            self._buffScheduler = nil
        end
        self._buffScheduler = scheduler.scheduleGlobal(function ()
            self:_updateTime()
        end, 1)
    else
        if self._buffScheduler then
            scheduler.unscheduleGlobal(self._buffScheduler)
            self._buffScheduler = nil
        end
        self._ccbOwner.node_buff:setVisible(false)
    end
end

function QUIDialogWorldBoss:_updateTime()
    local isInTime, color = remote.worldBoss:updateBuffColor()
    if self._isInTime == isInTime then return end
    self._isInTime = isInTime
    self._ccbOwner.tf_buff_time:setColor(color)
    self._ccbOwner.tf_buff_value:setColor(color)
end

function QUIDialogWorldBoss:setBossInfo()
    print("-----QUIDialogWorldBoss:setBossInfo------")
    self._bossInfo = remote.worldBoss:getWorldBossInfo() 

    local isUnlock, unlockTime, lockTime = remote.worldBoss:checkWorldBossIsUnlock()
    self._ccbOwner.node_boss:setVisible(isUnlock)
    self._ccbOwner.node_no_boss:setVisible(not isUnlock)
    self._ccbOwner.node_bg_open:setVisible(isUnlock)
    self._ccbOwner.node_bottom_bar:setVisible(true)
    self._ccbOwner.node_have:setVisible(isUnlock)
    self._ccbOwner.node_time:setVisible(isUnlock)
    self._ccbOwner.node_plus:setVisible(isUnlock)
    self._ccbOwner.node_no:setVisible(not isUnlock)
    self._ccbOwner.node_glory_client:setVisible(isUnlock)

    if isUnlock == false then
        self:setDefaultBoss()
        self:setCountDownForBossComming("BOSS_COMING_DOWN", unlockTime, self._ccbOwner.tf_next_time)
    else
        self:setBoss()
        self:setBottomBarInfo()
        self:setCountDownForBossComming("BOSS_LOCK", lockTime)

        self:setGloryWallInfo()
    end

    -- 个人荣誉
    local allHurt1 = math.floor((self._bossInfo.allHurt or 0)/1000)
    local num1, word1 = q.convertLargerNumber(allHurt1)
    local rank1 = self._bossInfo.hurtRank or 0
    local meritoriousRank = rank1 > 0 and string.format("（第%d名）", rank1) or "（尚未进榜）"
    local str1 = num1 == 0 and num1..(word1 or "")..meritoriousRank or num1..(word1 or "")..meritoriousRank
    self._ccbOwner.tf_my_meritorious:setString(str1)
    
    -- 宗门荣誉
    local allHurt2 = math.floor((self._bossInfo.consortiaTotalHurt or 0)/1000)
    local num2, word2 = q.convertLargerNumber(allHurt2)
    local rank2 = self._bossInfo.consortiaHurtRank or 0
    local meritoriousRank = rank2 > 0 and string.format("（第%d名）", rank2) or "（尚未进榜）"
    local str2 = num2 == 0 and num2..(word2 or "")..meritoriousRank or num2..(word2 or "")..meritoriousRank
    self._ccbOwner.tf_union_meritorious:setString(str2)
    
    -- 历史最高伤害
    local maxHurt = self._bossInfo.maxHurt or 0
    local num3, word3 = q.convertLargerNumber(maxHurt)
    self._ccbOwner.tf_max_damage:setString(num3..(word3 or ""))
end

function QUIDialogWorldBoss:setDefaultBoss()
    -- Display boss character
    self._bossAvatar = self:createBoss(60030, self._ccbOwner.noBossNode, -1.5, 1.5, nil, -250, -100)

    local talkWord = self._database:getShopNpcInfo("10002")
    if talkWord == nil then return end

    self._ccbOwner.yell:setString(talkWord[1].talk1 or "")
end

function QUIDialogWorldBoss:setBoss()
    QPrintTable(self._bossInfo)
    if self._bossInfo.bossId == nil then return end

    local bossLevel = self._bossInfo.bossLevel
    local bossHp = self._bossInfo.bossHp

    local showBossId = self._bossInfo.bossId
    if self._bossInfo.isShow == false then
        bossHp = 0
    end

    -- local hpPercent = bossHp/self._database:getCharacterDataByID(self._bossInfo.bossId, bossLevel).hp_value
    -- local realBossId = string.split(self._database:getCharacterByID(self._bossInfo.bossId).real_id , ";")
    -- for i = #realBossId, 1, -1 do
    --     realBossId[i] = string.split(realBossId[i], ",")
    --     if hpPercent < tonumber(string.sub(realBossId[i][1], 1, string.len( [i][1]) - 1)) / 100  then
    --         showBossId = tonumber(realBossId[i][2])
    --         break
    --     end
    -- end

    if self._oldBossId ~= showBossId then
        self._bossAvatar = self:createBoss(showBossId, self._ccbOwner.boss_node, -1.1, 1.1, true, 0, -150)
        self._oldBossId = showBossId
    end

    self._ccbOwner.node_kill_info:setVisible(false)
    self._ccbOwner.node_be_killed:setVisible(false)

    if not app.unlock:checkLock("UNLOCK_WHALE_AUTO", false) then
        self._ccbOwner.fast_fight_node:setVisible(false)
    else
        self._ccbOwner.fast_fight_node:setVisible(true)
    end
        
    if self._bossInfo.isShow then
        self._canFight = true

        -- 播放BOSS生成动画
        if self._bossIsLive == false then
            self._bossAvatar:displayWithBehavior(ANIMATION_EFFECT.VICTORY)
            self._bossAvatar:setAutoStand(true)
            makeNodeFromGrayToNormal(self._bossAvatar)
            self._bossAvatar:getActor():getSkeletonView():resumeAnimation()
            self._bossAvatar:setDisplayBehaviorCallback(nil)
        end
        self._bossIsLive = true
    else
        self._canFight = false
        bossLevel = bossLevel - 1
        bossHp = 0
        self._ccbOwner.node_kill_info:setVisible(true)
        self._ccbOwner.fast_fight_node:setVisible(false)
        -- 播放BOSS死亡动画
        if self._bossIsLive == true then
            self._bossAvatar:displayWithBehavior(ANIMATION_EFFECT.DEAD)
            self._bossAvatar:setAutoStand(false)
            self._bossAvatar:setDisplayBehaviorCallback(function()
                    makeNodeFromNormalToGray(self._bossAvatar)
                    self._ccbOwner.node_be_killed:setVisible(true)
                end)
        else
            self._bossAvatar:displayWithBehavior(ANIMATION_EFFECT.INSTANT_DEAD)
            self._bossAvatar:setAutoStand(false)
            self._bossAvatar:setDisplayBehaviorCallback(function()
                    makeNodeFromNormalToGray(self._bossAvatar)
                    self._ccbOwner.node_be_killed:setVisible(true)
                end)
        end
        self._bossIsLive = false

        -- 设置BOSS刷新倒计时
        local refereshTime = self._database:getConfiguration()["YAOSAI_SHUAXIN_TIME"].value or 15
        local nowTime = q.serverTime()
        self:setCountDownForBossComming("BOSS_COMING_DOWN", self._bossInfo.startAt/1000+refereshTime, self._ccbOwner.tf_comming_time)

        -- 设置击杀者
        local str = string.split(self._bossInfo.lastKillers or "", ";")
        local killName = ""
        for i = 1, #str do
            if killName == "" then
                killName = str[i]
            else
                killName = killName.."、"..str[i]
            end
        end

        local stringFormat = "##wBOSS已经被##0xffb63b%s ##w击杀"
        if self._richText == nil then
            self._richText = QRichText.new(nil,750,{stringType = 1, defaultColor = ccc3(255,255,255), defaultSize = 24, autoCenter = true})
            self._richText:setAnchorPoint(0.5,0)
            self._ccbOwner.node_killer_name:addChild(self._richText)
        end
        stringFormat = string.format(stringFormat, killName)
        self._richText:setString(stringFormat)
    end
    self:getOptions().bossIsLive = self._bossIsLive

    -- set name and hp
    local monsteInfo = self._database:getCharacterDataByID(self._bossInfo.bossId, bossLevel)
    local character = self._database:getCharacterByID(self._bossInfo.bossId)
    self._ccbOwner.tf_boss_name:setString("LV."..bossLevel.." "..character.name or "")

    local num1, word1 = q.convertLargerNumber(bossHp)
    local num2, word2 = q.convertLargerNumber(monsteInfo.hp_value)
    self._ccbOwner.tf_hp:setString("生命值："..num1..(word1 or "").."/"..num2..(word2 or ""))
    local scale = bossHp/monsteInfo.hp_value
    scale = scale > 1 and 1 or scale

    -- 初始化进度条
    if not self._percentBarClippingNode then
        self._totalStencilPosition = self._ccbOwner.sp_hp:getPositionX() -- 这个坐标必须sp_hp节点的锚点为(0, 0.5)
        self._percentBarClippingNode = q.newPercentBarClippingNode(self._ccbOwner.sp_hp)
        self._totalStencilWidth = self._ccbOwner.sp_hp:getContentSize().width * self._ccbOwner.sp_hp:getScaleX()
    end
    local stencil = self._percentBarClippingNode:getStencil()
    stencil:setPositionX(-self._totalStencilWidth + scale*self._totalStencilWidth)
end

function QUIDialogWorldBoss:createBoss(bossId, node, scaleX, scaleY, isLisener, positionX, positionY)
    if self._bossAvatar ~= nil then 
        self._bossAvatar:removeFromParent()
        self._bossAvatar = nil
    end

    local avatar = QUIWidgetActorDisplay.new(bossId)
    if isLisener then
        -- avatar:addEventListener(QUIWidgetHeroInformation.EVENT_CLICK, handler(self, self._clickBoss))
    end
    node:removeAllChildren()
    node:addChild(avatar)
    node:setScaleX(scaleX)
    node:setScaleY(scaleY)
    node:setPosition(ccp(positionX, positionY))

    return avatar
end

function QUIDialogWorldBoss:setCountDownForBossComming(schedulerName, unlockTime, node)
    if self[schedulerName] ~= nil then
        scheduler.unscheduleGlobal(self[schedulerName])
        self[schedulerName] = nil
    end

    local schedulerFunc
    schedulerFunc = function()
        if self[schedulerName] ~= nil then
            scheduler.unscheduleGlobal(self[schedulerName])
            self[schedulerName] = nil
        end
        local nowTime = q.serverTime()
        if unlockTime >= nowTime then
            if node then
                node:setString(q.timeToHourMinuteSecond(unlockTime-nowTime))
            end
            self[schedulerName] = scheduler.scheduleGlobal(schedulerFunc, 1)
        elseif self:safeCheck() then
            remote.worldBoss:requestWorldBossInfo(nil, function()
                    if self:safeCheck() then
                        self:setBossInfo()
                    end
                end)
        end
    end
    schedulerFunc()
end

function QUIDialogWorldBoss:setBottomBarInfo()
    local count, unlockTime = remote.worldBoss:getWorldBossFightCount()
    self._count = count
    self._ccbOwner.tf_count:setString(count)

    self:setFightCountTimeScheduler(unlockTime, self._ccbOwner.tf_time)

    local buyCount = remote.worldBoss:getWorldBossInfo().buyFightCount or 0
    local totalVIPNum = QVIPUtil:getCountByWordField("yaosai_boss_times", QVIPUtil:getMaxLevel())
    local totalNum = QVIPUtil:getCountByWordField("yaosai_boss_times")
    self._ccbOwner.btn_plus:setVisible(totalVIPNum > totalNum or totalNum > buyCount)
    self._ccbOwner.btn_plus2:setVisible(totalVIPNum > totalNum or totalNum > buyCount)
end

function QUIDialogWorldBoss:setFightCountTimeScheduler(unlockTime, node)
    if self._fightCountScheduler ~= nil then
        scheduler.unscheduleGlobal(self._fightCountScheduler)
        self._fightCountScheduler = nil
    end

    local replyTime = self._database:getConfiguration()["HUIFU_JIANGE"].value * 60
    local schedulerFunc
    schedulerFunc = function()
        if self._fightCountScheduler ~= nil then
            scheduler.unscheduleGlobal(self._fightCountScheduler)
            self._fightCountScheduler = nil
        end
        local nextTime = replyTime - (q.serverTime() - unlockTime)%replyTime
        if nextTime > 0 then
            node:setString(q.timeToHourMinuteSecond(nextTime))
            self._fightCountScheduler = scheduler.scheduleGlobal(schedulerFunc, 1)
        elseif self:safeCheck() then
            self:setBottomBarInfo()
        end
    end
    schedulerFunc()
end

function QUIDialogWorldBoss:checkRedTips()
    self._ccbOwner.sp_award_tips:setVisible(remote.worldBoss:checkAwardsRedTips())
    self._ccbOwner.sp_record_tips:setVisible(remote.worldBoss:checkScoreRedTips())
end
-- WORLD_BOSS_GET_INFO
function QUIDialogWorldBoss:_setBossHurtInfo(event)
    if event.info == nil then return end

    local index = self._index
    local info = event.info 
    local scale = 1
    local posY = -50
    if index > 1 then
        scale = 0.85
        posY = -130
    end

    local ccbFile = "ccb/effects/xdaoguangdonghua_1.ccbi"
    local animationPlayer = QUIWidgetAnimationPlayer.new()
    animationPlayer:setPositionY(posY+50)
    animationPlayer:setScale(scale)
    animationPlayer:playAnimation(ccbFile,nil,function ()
        animationPlayer:removeFromParent()
    end)
    self:getView():addChild(animationPlayer)
    local hurtHp = info.hurtNum
    local handler = scheduler.performWithDelayGlobal(function ()
            -- self._ccbOwner["node_battle"..index]:setVisible(false)
            local richText = QRichText.new()
            richText:setPositionY(posY+50)
            local strokeColor = ccc3(0,0,0)
            local num,unit = q.convertLargerNumber(hurtHp)
            richText:setAnchorPoint(0.5,0.5)
            richText:setString({
                    {oType = "font", content = (info.userName or "").."("..(info.gameArea or "")..")", strokeColor = strokeColor, size = 22,color = UNITY_COLOR.white, fontName = global.font_name},
                    {oType = "font", content = "打出伤害"..num..(unit or ""), strokeColor = strokeColor, size = 22,color = QIDEA_QUALITY_COLOR.YELLOW},
                },790)
            self:getView():addChild(richText)

            local arr = CCArray:create()
            arr:addObject(CCFadeIn:create(4/30))
            arr:addObject(CCDelayTime:create(17/30))
            local arr2 = CCArray:create()
            arr2:addObject(CCMoveTo:create(25/30,ccp(0, 78)))
            arr2:addObject(CCFadeOut:create(25/30))
            arr:addObject(CCSpawn:create(arr2))
            arr:addObject(CCCallFunc:create(function()  
                    richText:removeFromParent()
                end))
            richText:runAction(CCSequence:create(arr))
        end,0.2)
    table.insert(self._schedulers, handler)
    self._index = self._index + 1
end

function QUIDialogWorldBoss:setGloryWallInfo()
    if self._gloryWall == nil then
        self._gloryWall = QUIWidgetWorldBossGloryWall.new()
        self._ccbOwner.node_glory_client:addChild(self._gloryWall)
    end
    self._gloryWall:setInfo()
end

function QUIDialogWorldBoss:checkSubteam()
    local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.WORLDBOSS_TEAM)
    local teams = teamVO:getAllTeam()
    local mainTeam = teams[remote.teamManager.TEAM_INDEX_MAIN] ~= nil and teams[remote.teamManager.TEAM_INDEX_MAIN].actorIds ~= nil and #teams[remote.teamManager.TEAM_INDEX_MAIN].actorIds or 0
    local soulTeam = teams[remote.teamManager.TEAM_INDEX_MAIN] ~= nil and teams[remote.teamManager.TEAM_INDEX_MAIN].spiritIds ~= nil and #teams[remote.teamManager.TEAM_INDEX_MAIN].spiritIds or 0
    local helpTeam = teams[remote.teamManager.TEAM_INDEX_HELP] ~= nil and teams[remote.teamManager.TEAM_INDEX_HELP].actorIds ~= nil and #teams[remote.teamManager.TEAM_INDEX_HELP].actorIds or 0
    local helpTeam2 = teams[remote.teamManager.TEAM_INDEX_HELP2] ~= nil and teams[remote.teamManager.TEAM_INDEX_HELP2].actorIds ~= nil and #teams[remote.teamManager.TEAM_INDEX_HELP2].actorIds or 0
    local helpTeam3 = teams[remote.teamManager.TEAM_INDEX_HELP3] ~= nil and teams[remote.teamManager.TEAM_INDEX_HELP3].actorIds ~= nil and #teams[remote.teamManager.TEAM_INDEX_HELP3].actorIds or 0
    local heros = remote.herosUtil:getHaveHero()
    local isUnlockSoul = app.unlock:getUnlockSoulSpirit()
    local isUnlockHelper = app.unlock:getUnlockHelperDisplay()
    local isUnlockHelper2 = app.unlock:getUnlockTeamHelp5()
    local isUnlockHelper3 = app.unlock:getUnlockTeamHelp9()

    local callBack = function()     
        local wordBossArrangement = QWorldBossArrangement.new({hp = self._bossInfo.bossHp, actorId = self._bossInfo.bossId, level = self._bossInfo.bossLevel, worldBoss = self._bossInfo, buffList = self._buffList})
        wordBossArrangement:setIsLocal(true)
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement",
            options = {arrangement = wordBossArrangement}})
    end

    if mainTeam == 0 then
        app:alert({content = QUIDialogWorldBoss.NO_FIGHT_HEROES, title = "系统提示", 
            callback = function(state)
                if state == ALERT_TYPE.CONFIRM then
                    callBack()
                end
            end})
        return false
    end

    --检查是否包含非治疗职业
    local isAllHeath = true
    for k, actorId in pairs(teams[remote.teamManager.TEAM_INDEX_MAIN].actorIds) do
        local heroConfig = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)
        if heroConfig.func ~= 'health' then
            isAllHeath = false
            break
        end
    end

    if isAllHeath then
        app:alert({content = "出战英雄不能全部为治疗英雄", title = "系统提示", 
            callback = function(state)
                if state == ALERT_TYPE.CONFIRM then
                    callBack()
                end
            end})
        return false
    end

    local str = "确定开始战斗吗？"
    local upTeam = helpTeam + mainTeam + helpTeam2 + helpTeam3
    local teamHeroNum = teamVO:getHerosMaxCountByIndex(remote.teamManager.TEAM_INDEX_MAIN)
    if mainTeam < teamHeroNum and #heros - upTeam > 0 then
        app:alert({content="有主力魂师未上阵，"..str,title="系统提示", callback = function (state)
            if state == ALERT_TYPE.CONFIRM then
                self:autoFightStart(teams)
            end
        end})
        return false
    end

    teamHeroNum = teamVO:getSpiritsMaxCountByIndex(remote.teamManager.TEAM_INDEX_MAIN)
    if isUnlockSoul and soulTeam < teamHeroNum then
        app:alert({content="有主力魂灵未上阵，"..str,title="系统提示", callback = function (state)
            if state == ALERT_TYPE.CONFIRM then
                self:autoFightStart(teams)
            end
        end})
        return false
    end

    teamHeroNum = teamVO:getHerosMaxCountByIndex(remote.teamManager.TEAM_INDEX_HELP)
    if isUnlockHelper and helpTeam < teamHeroNum and #heros - upTeam > 0 then
        app:alert({content="有援助1魂师未上阵，"..str,title="系统提示", callback = function (state)
            if state == ALERT_TYPE.CONFIRM then
                self:autoFightStart(teams)
            end
        end})
        return false
    end

    teamHeroNum = teamVO:getHerosMaxCountByIndex(remote.teamManager.TEAM_INDEX_HELP2)
    if isUnlockHelper2 and helpTeam2 < teamHeroNum and #heros - upTeam > 0 then
        app:alert({content="有援助2魂师未上阵，"..str,title="系统提示", callback = function (state)
            if state == ALERT_TYPE.CONFIRM then
                self:autoFightStart(teams)
            end
        end})
        return false
    end

    teamHeroNum = teamVO:getHerosMaxCountByIndex(remote.teamManager.TEAM_INDEX_HELP3)
    if isUnlockHelper3 and helpTeam3 < teamHeroNum and #heros - upTeam > 0 then
        app:alert({content="有援助3魂师未上阵，"..str,title="系统提示", callback = function (state)
            if state == ALERT_TYPE.CONFIRM then
                self:autoFightStart(teams)
            end
        end})
        return false
    end

    return true
end

function QUIDialogWorldBoss:autoFightStart(heros)
    local sunwellArrangement = QWorldBossArrangement.new({hp = self._bossInfo.bossHp, actorId = self._bossInfo.bossId, level = self._bossInfo.bossLevel, worldBoss = self._bossInfo, buffList = self._buffList})
    sunwellArrangement:setIsLocal(true)
    sunwellArrangement:startQuickBattle(heros,function(data)
            app.taskEvent:updateTaskEventProgress(app.taskEvent.WORLD_BOSS_TASK_EVENT, 1)
            -- remote.trailer:updateTaskProgressByTaskId("4000026", 1)
            remote.user:addPropNumForKey("todayWorldBossFightCount")--记录魔鲸攻击次数
            if self:safeCheck() then
                self:showAuotFightResult(data)
                remote.worldBoss:requestWorldBossInfo(nil, function()
                    if self:safeCheck() then
                        self:setBuffInfo()
                        self:setBossInfo()
                        self:checkRedTips()
                    end
                end)
            end
        end, function() 

        end)
end

function QUIDialogWorldBoss:showAuotFightResult(data) 
    remote.worldBoss:updateWorldBossParam(data)
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogWorldBossQuickFightAwrds"})
end

-------------------- event handler ----------------------

function QUIDialogWorldBoss:_onTriggerClickBoss(event)
    if self._canFight == false then return end

    if self._count == 0 then
        self:_onTriggerPlus()
        return 
    end
    if remote.worldBoss:checkWorldBossIsUnlock() == false then
        self:setBossInfo()
        app.tip:floatTip("魂师大人，世界BOSS尚未开启")
        return 
    end
    
    local isInTime = remote.worldBoss:updateBuffColor()
    if isInTime then
        table.insert(self._buffList, self._curBuffId)
    else
        self._buffList = {}
    end

    remote.invasion:setAfterBattle(false)
    local worldBossArrangement = QWorldBossArrangement.new({hp = self._bossInfo.bossHp, actorId = self._bossInfo.bossId, level = self._bossInfo.bossLevel, worldBoss = self._bossInfo, buffList = self._buffList})
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement", 
            options = {arrangement = worldBossArrangement}})
end

function QUIDialogWorldBoss:_onTriggerFastFighter( event)
    if self._canFight == false then return end
    if self._count == 0 then
        self:_onTriggerPlus()
        return 
    end
    if remote.worldBoss:checkWorldBossIsUnlock() == false then
        self:setBossInfo()
        app.tip:floatTip("魂师大人，世界BOSS尚未开启")
        return 
    end

    local isInTime = remote.worldBoss:updateBuffColor()
    if isInTime then
        table.insert(self._buffList, self._curBuffId)
    else
        self._buffList = {}
    end

    remote.invasion:setAfterBattle(false)
    if self:checkSubteam() == false then return end
    local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.WORLDBOSS_TEAM)
    local teams = teamVO:getAllTeam()
    local soulMaxNum = teamVO:getSpiritsMaxCountByIndex(1)
    if soulMaxNum > 0 and teams[1].spiritIds ~= nil and #teams[1].spiritIds < soulMaxNum then
        app:alert({content="有主力魂灵未上阵，确定开始战斗吗？",title="系统提示", callback = function (state)
            if state == ALERT_TYPE.CONFIRM then
                self:autoFightStart(teams)
            end
        end})
    else
        self:autoFightStart(teams)
    end
    
end
function QUIDialogWorldBoss:_onTriggerRecord(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_record) == false then return end
    app.sound:playSound("common_small")
    return app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogWorldBossRecord"})
end

function QUIDialogWorldBoss:_onTriggerAwards(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_awards) == false then return end
    app.sound:playSound("common_small")
    return app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogWorldBossAwards"})
end

function QUIDialogWorldBoss:_onTriggerRank()
    app.sound:playSound("common_small")
    return app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogWorldBossRank"})
end

function QUIDialogWorldBoss:_onTriggerBuff(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_buff) == false then return end
    app.sound:playSound("common_small")
    local isUnlock, _, _, isReadyTime = remote.worldBoss:checkWorldBossIsUnlock()
    self._buffIndex = remote.worldBoss:getWorldBossInfo().additionTimeId or 0 -- 0未没有选择
    if isUnlock then
        if remote.user.userConsortia and remote.user.userConsortia.consortiaId and remote.user.userConsortia.consortiaId ~= "" then
            if remote.user.userConsortia.rank == SOCIETY_OFFICIAL_POSITION.BOSS or remote.user.userConsortia.rank == SOCIETY_OFFICIAL_POSITION.ADJUTANT then
                if not remote.worldBoss:getWorldBossInfo().additionTimeId or remote.worldBoss:getWorldBossInfo().additionTimeId == 0 then
                    return app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogWorldBossBuff", 
                        options = {successCallback = self:safeHandler(handler(self, self.setBuffInfo))}})
                else
                    app.tip:floatTip("活动已开启，不能重复修改～")
                end
            else
                app.tip:floatTip("只有宗主或副宗主可以设置～")
            end
        else
            app.tip:floatTip("尚未加入宗门，快去加入吧～")
        end
    elseif isReadyTime then
        if remote.user.userConsortia and remote.user.userConsortia.consortiaId and remote.user.userConsortia.consortiaId ~= "" then
            if remote.user.userConsortia.rank == SOCIETY_OFFICIAL_POSITION.BOSS or remote.user.userConsortia.rank == SOCIETY_OFFICIAL_POSITION.ADJUTANT then
                return app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogWorldBossBuff", 
                    options = {successCallback = self:safeHandler(handler(self, self.setBuffInfo))}})
            else
                app.tip:floatTip("只有宗主或副宗主可以设置～")
            end
        else
            app.tip:floatTip("尚未加入宗门，快去加入吧～")
        end
    else
        app.tip:floatTip("活动尚未开启～")
    end
end

function QUIDialogWorldBoss:_onTriggerPlus(event)
    if q.buttonEventShadow(event,self._ccbOwner.btn_plus) == false then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBuyCountBase", 
        options = {cls = "QBuyCountWorldBoss"}}, {isPopCurrentDialog = false})
end

function QUIDialogWorldBoss:_onTriggerRule()
    app.sound:playSound("common_small")
    return app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogWorldBossRule"})
end

function QUIDialogWorldBoss:onTriggerBackHandler()
    self:_onTriggerClose()
end

function QUIDialogWorldBoss:_onTriggerClose()
	self:popSelf()
end

return QUIDialogWorldBoss