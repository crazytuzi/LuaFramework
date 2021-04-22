local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogBlackRock = class("QUIDialogBlackRock", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QListView = import("...views.QListView")
local QUIWidgetBlackRock = import("..widgets.blackrock.QUIWidgetBlackRock")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIDialogBuyCount = import("..dialogs.QUIDialogBuyCount")
local QUIWidgetChat = import("..widgets.QUIWidgetChat")
local QVIPUtil = import("...utils.QVIPUtil")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIWidgetSoulSpriteHead = import("..widgets.QUIWidgetSoulSpriteHead")
local QUIWidgetBlackRockTouchMoveController = import("..widgets.QUIWidgetBlackRockTouchMoveController")

function QUIDialogBlackRock:ctor(options)
    local ccbFile = "ccb/Dialog_black_mountain.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerShop", callback = handler(self, self._onTriggerShop)},
        {ccbCallbackName = "onTriggerRank", callback = handler(self, self._onTriggerRank)},
        {ccbCallbackName = "onTriggerIntroduce", callback = handler(self, self._onTriggerIntroduce)},
        {ccbCallbackName = "onTriggerRecord", callback = handler(self, self._onTriggerRecord)},
        -- {ccbCallbackName = "onTriggerRank", callback = handler(self, self._onTriggerRank)},
        {ccbCallbackName = "onTriggerShowTujian", callback = handler(self,self._onTriggerShowTujian)},
        {ccbCallbackName = "onPlus", callback = handler(self, self._onPlus)},
    }
    QUIDialogBlackRock.super.ctor(self,ccbFile,callBacks,options)
    self._page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if self._page.setManyUIVisible then self._page:setManyUIVisible() end
    if self._page.setScalingVisible then self._page:setScalingVisible(false) end
    if self._page.topBar.showWithBlackRock then self._page.topBar:showWithBlackRock() end

    self._data = remote.blackrock:getAllBalckRockConfig()

    remote.blackrock:setLastFastFightSeclectId(nil)
    local config = QStaticDatabase:sharedDatabase():getConfiguration()
    local timeStr = config.blackrock_double_reward.value  or "11,14;18,22"
    local times = string.split(timeStr, ";")
    local times1 = string.split(times[1], ",")
    local times2 = string.split(times[2], ",")
    self._ccbOwner.tf_tips:setString(string.format("%s:00—%s:00，%s:00—%s:00   传灵塔奖励的货币和积分翻倍", times1[1], times1[2], times2[1], times2[2]))

    local contentSize = self._ccbOwner.sheet_layout:getContentSize()
    local position = self._ccbOwner.sheet_layout:getContentSize()
    self._ccbOwner.sheet_layout:setContentSize(CCSize(display.width, contentSize.height))
    self._ccbOwner.sheet_layout:setPositionX( - 568.0 + (- (display.width - contentSize.width)/2))

    self._lastChapterId = app:getUserOperateRecord():getBlackRockChapterSetting()   --最后一次进入的章节

    self._ccbOwner.sheet_layout:setVisible(false)

    self._maxSize =  CCSize(2000, 0)
    self._pageSilder = QUIWidgetBlackRockTouchMoveController.new({ccbOwner = self._ccbOwner, maxSize = self._maxSize,maxNum = #self._data})
    self:getView():addChild(self._pageSilder)
    local pos = ccp(self._pageSilder:getPosition())

    self._pageSilder:setPosition(ccp(-display.width/2,-display.height/2))

    -- self._pageSilder:moveToPos(ccp(self._maxSize.width, 0), false)
end

function QUIDialogBlackRock:viewDidAppear()
    QUIDialogBlackRock.super.viewDidAppear(self)
    self:addBackEvent(false)
    self:initView()
    local options = self:getOptions()
    if options.checkAwards == nil then
        self:requestAwardsList()
        options.checkAwards = true
    end
    
    self:moveToLastChapter()
    -- 显示聊天信息
    self:setChatInfo()
    self._ccbOwner.btn_plus:setVisible(false)
    self._blackrockProxy = cc.EventProxy.new(remote.blackrock)
    self._blackrockProxy:addEventListener(remote.blackrock.EVENT_UPDATE_MYINFO, handler(self, self.updateMyInfoHandler))
end

function QUIDialogBlackRock:viewWillDisappear()
    QUIDialogBlackRock.super.viewWillDisappear(self)
    self:removeBackEvent()
    if self._blackrockProxy ~= nil then 
        self._blackrockProxy:removeAllEventListeners()
        self._blackrockProxy = nil
    end

end

function QUIDialogBlackRock:initView()
    self:showMyInfo()

    self:initWidgetBlackRocks()

    self:checkRedTips()
    self:showSoulSprit()
end

function QUIDialogBlackRock:moveToLastChapter( )
    local headIndex = nil
    for index, value in ipairs(self._data) do
        if self._lastChapterId and value[1].id == self._lastChapterId then
            headIndex = index
            self._lastChapterId = nil
            break
        end
    end
    local maxNum = #self._data
    local offsetIndex = 4
    local showDefautNum = 4
    local maxOffsetX = 0
    if display.width >= UI_VIEW_MIN_WIDTH then
        offsetIndex = 4
        showDefautNum = 4
        maxOffsetX = -self._maxSize.width - math.abs(350*maxNum - display.width) - 300
    else
        offsetIndex = 6
        showDefautNum = 3
        maxOffsetX = -self._maxSize.width - math.abs(350*maxNum - self._maxSize.width) - 300
    end

    if headIndex and headIndex > showDefautNum and headIndex <= (maxNum - showDefautNum) then
        self._pageSilder:moveToPos(ccp(-self._maxSize.width - (maxNum - offsetIndex )*350 + 350*(maxNum-headIndex) + 300,0), false)
    elseif headIndex and headIndex > (maxNum - showDefautNum) then
        self._pageSilder:moveToPos(ccp(maxOffsetX,0), false)
    else
        self._pageSilder:moveToPos(ccp(self._maxSize.width, 0), false)
    end
end
function QUIDialogBlackRock:showMyInfo()
    self._myInfo = remote.blackrock:getMyInfo()
    self._ccbOwner.tf_today_score:setString(self._myInfo.todayScore or 0)
    self._ccbOwner.tf_total_score:setString(self._myInfo.totalScore or 0)
    local count = remote.blackrock:getTotalAwardsCount() - self._myInfo.awardCount + self._myInfo.buyAwardCount
    self._ccbOwner.tf_count:setString(count)

    local totalVIPNum = QVIPUtil:getCountByWordField("blackrock_award", QVIPUtil:getMaxLevel())
    local totalNum = QVIPUtil:getCountByWordField("blackrock_award")
    local buyCount = remote.blackrock:getMyInfo().buyAwardCount or 0
    -- self._ccbOwner.btn_plus:setVisible(totalVIPNum > totalNum or totalNum > buyCount)
end

function QUIDialogBlackRock:showSoulSprit()
    local randomDay = remote.blackrock:getDayOfYear()
    local soulspritInfo = remote.blackrock:getBlackRockSoulSpiritById(randomDay)
    if soulspritInfo == nil then return end
    local showSoulSpritList = string.split(soulspritInfo.random_soul_spirit,";")
    local index = 1
    for _,value in pairs(showSoulSpritList) do
        local sorlWiget = QUIWidgetSoulSpriteHead.new()
        sorlWiget:setScale(0.6)
        sorlWiget:setSoulInfo(value)
        self._ccbOwner["node_hunling_"..index]:addChild(sorlWiget)
        index = index + 1
        -- local texture = CCTextureCache:sharedTextureCache():addImage(characterConfig.icon)
        -- if texture then
        --     local soulSpritAvatar = CCSprite:createWithTexture(texture)
        --     soulSpritAvatar:setScale(0.6)
        --     self._ccbOwner["node_hunling_"..index]:addChild(soulSpritAvatar)
        -- end

        -- local aptitudeInfo = QStaticDatabase.sharedDatabase():getSABCByQuality(characterConfig.aptitude)
        -- local frame = nil
        -- if aptitudeInfo.lower == "s" then
        --     frame =  CCTextureCache:sharedTextureCache():addImage("ui/common/hl_h_glod.png")
        -- else
        --     frame =  CCTextureCache:sharedTextureCache():addImage("ui/common/hl_h_purper.png")
        -- end
        -- if frame then
        --     local soulSpritFrame = CCSprite:createWithTexture(frame)
        --     soulSpritFrame:setScale(0.6)
        --     self._ccbOwner["node_hunling_"..index]:addChild(soulSpritFrame)
        --     index = index + 1
        -- end

    end
end

function QUIDialogBlackRock:requestAwardsList()
    remote.blackrock:blackRockGetTeamAwardListRequest(function (data)
        if self:safeCheck() then
            if data.blackRockGetTeamAwardListResponse ~= nil then
                self._awards = data.blackRockGetTeamAwardListResponse.awardList
                local checkAwardsFun = nil

                checkAwardsFun = function ()
                    self:showMyInfo()
                    if self._awards ~= nil and #self._awards > 0 then
                        local award = table.remove(self._awards, 1)
                        if award.getAward == false then 
                            if award.starNum > 0 then
                                if award.giveAward then
                                    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBlackRockPassAwards",
                                        options = {award = award, callback = checkAwardsFun}})
                                    self._ccbOwner.sp_record_tips:setVisible(true)
                                else
                                    checkAwardsFun()
                                end
                            else
                                app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBlackRockPassLost",
                                    options = {award = award, callback = checkAwardsFun}})
                                self._ccbOwner.sp_record_tips:setVisible(true)
                            end
                        else
                            checkAwardsFun()
                        end
                    end
                end
                checkAwardsFun()
            end
        end
    end)
end

function QUIDialogBlackRock:initWidgetBlackRocks( )
    self._ccbOwner.node_guanka:removeAllChildren()

    for i=1,#self._data do
        local widgetBlack = QUIWidgetBlackRock.new()
        widgetBlack:setInfo(self._data[i],self)
        local size = widgetBlack:getContentSize()
        -- widgetBlack:setAnchorPoint(ccp(0.0, 0.5))
        widgetBlack:setPosition(ccp(-self._maxSize.width + size.width*2+50 + i * (size.width + 100),display.height/2-150))
        self._ccbOwner.node_guanka:addChild(widgetBlack)
    end

end

function QUIDialogBlackRock:isMoving( )
    return self._pageSilder:getIsMoveing()
end

function QUIDialogBlackRock:setChatInfo()
    if self._chat == nil then
        self._chat = QUIWidgetChat.new({state = QUIWidgetChat.STATE_ALL})
        self._ccbOwner.node_chat:addChild(self._chat)
        self._chat:setChatAreaVisible(false)
        self._chat:setChatInBlackRock(true)
    end
end

function QUIDialogBlackRock:checkRedTips()
    self._ccbOwner.sp_shop_tips:setVisible(remote.stores:checkFuncShopRedTips(SHOP_ID.blackRockShop))
end

function QUIDialogBlackRock:clickHandler(x, y, touchNode, listView )
    -- body
    app.sound:playSound("common_switch")
    local touchIndex = listView:getCurTouchIndex()
    local selectInfo = self._data[touchIndex] or {}

    local force = 0
    for _,v in ipairs(selectInfo) do
        if force == 0 or force > v.monster_battleforce then
            force = v.monster_battleforce
        end
    end
    if force > (remote.user:getHistoryTopForce() or 0) then
        app.tip:floatTip("魂师大人，您的战力还未达到进入要求哦~")
        return
    end

    --之前放弃的还没结束
    local progress = remote.blackrock:getProgress(remote.user.userId)
    local teamInfo = remote.blackrock:getTeamInfo()
    if remote.blackrock:getTeamIsEnd() == false and progress ~= nil and progress.isEnd == true then
        local chapterId = teamInfo.chapterId
        local configs = QStaticDatabase:sharedDatabase():getBalckRockConfig()
        local name = configs[tostring(chapterId)][1].name
        local startTime = teamInfo.teamProgress.fightStartAt/1000
        local passTime = q.serverTime() - startTime
        local totalTime = remote.blackrock:getTotalFightTime()
        app.tip:floatTip(string.format("魂师大人，您在%s节的战斗还未结束，队伍结束倒计时：%s", name, q.timeToHourMinuteSecond(math.max(totalTime - passTime, 0))))
        return
    end

    if q.isEmpty(selectInfo) == false then
        remote.blackrock:blackRockGetChapterTeamListRequest(selectInfo[1].id,"",function (data)
            if self:safeCheck() then
            
                local teams = data.blackRockGetChapterTeamListResponse.teams or {}
                remote.blackrock:setCurrentAllTeams(teams)
                app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBlackRockChoose", 
                    options = {info = selectInfo, teams = teams}})
            end
        end)
    end
end

function QUIDialogBlackRock:_onTriggerShowTujian()
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBlackRockOverView"})
end

--显示奖励信息
function QUIDialogBlackRock:showAwardsHandler(x, y, touchNode, listView )
    print("--QUIDialogBlackRock:showAwardsHandler---")
    local touchIndex = listView:getCurTouchIndex()
    local item = listView:getItemByIndex(touchIndex)
    local info = item:getChapterInfo()
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBlackRockAwardsTips", 
        options = {info = info}}, {isPopCurrentDialog = false})
end

function QUIDialogBlackRock:_onTriggerShop(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_shop) == false then return end
    app.sound:playSound("common_small")
    remote.stores:openShopDialog(SHOP_ID.blackRockShop)
end

function QUIDialogBlackRock:_onTriggerRank(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_rank) == false then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRank", 
        options = {initRank = "blackRock"}}, {isPopCurrentDialog = false})
end

function QUIDialogBlackRock:_onPlus()
    app.sound:playSound("common_small")
    local count = remote.blackrock:getMyInfo().buyAwardCount or 0
    if count >= QVIPUtil:getBlackRockBuyAwardsCount() then
        app:vipAlert({title = "奖励次数", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.BLACKROCK_BUY_AWARDS_COUNT}, false)
    else
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBuyCountBase",
            options = {cls = "QBuyCountBlackRock"}})
    end    
end

function QUIDialogBlackRock:_onTriggerIntroduce(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_rule) == false then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBlackRockRule"})
end

function QUIDialogBlackRock:_onTriggerRecord(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_record) == false then return end
    app.sound:playSound("common_switch")
    self._ccbOwner.sp_record_tips:setVisible(false)
    remote.blackrock:blackRockGetTeamFightReportList(function(data)
            if self:safeCheck() then
                local list = data.blackRockGetTeamFightReportListResponse.blackRockTeamFightReports or {}
                app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBlackRockRecord",
                    options = {list = list}})
            end
        end
    )
end

function QUIDialogBlackRock:updateMyInfoHandler()
    self:showMyInfo()
end

function QUIDialogBlackRock:onTriggerBackHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogBlackRock:onTriggerHomeHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogBlackRock