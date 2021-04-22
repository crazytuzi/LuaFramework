local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogBlackRockTeam = class("QUIDialogBlackRockTeam", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetBlackRockTeamPlayer = import("..widgets.blackrock.QUIWidgetBlackRockTeamPlayer")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QUIWidgetBlackRockTeamDungeon = import("..widgets.blackrock.QUIWidgetBlackRockTeamDungeon")
local QUIWidgetChat = import("..widgets.QUIWidgetChat")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QChatData = import("...models.chatdata.QChatData")
local QUIDialogBuyCount = import("..dialogs.QUIDialogBuyCount")
local QVIPUtil = import("...utils.QVIPUtil")
local QUIWidgetBlackRockTeamPanel = import("..widgets.blackrock.QUIWidgetBlackRockTeamPanel")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QUIWidgetTeamChat = import("..widgets.QUIWidgetTeamChat")

QUIDialogBlackRockTeam.STATE_NONE = "STATE_NONE"
QUIDialogBlackRockTeam.STATE_MOVE = "STATE_MOVE"

function QUIDialogBlackRockTeam:ctor(options)
    local ccbFile = "ccb/Dialog_Black_mountain_chuanjian.ccbi"
    local callBacks = {
  --       {ccbCallbackName = "onTriggerOpenRoom", callback = handler(self, self._onTriggerOpenRoom)},
        -- {ccbCallbackName = "onTriggerClosePop", callback = handler(self, self._onTriggerClosePop)},
        {ccbCallbackName = "onTriggerRefresh", callback = handler(self, self._onTriggerRefresh)},
        {ccbCallbackName = "onTriggerStartBattle", callback = handler(self, self._onTriggerStartBattle)},
        {ccbCallbackName = "onPlus", callback = handler(self, self._onPlus)},
        {ccbCallbackName = "onTriggerReady", callback = handler(self, self._onTriggerReady)},
        {ccbCallbackName = "onTriggerCancle", callback = handler(self,self._onTriggerCancle)},
        {ccbCallbackName = "onTriggerInvite", callback = handler(self, self._onTriggerInvite)},      
        {ccbCallbackName = "onTriggerIntroduce", callback = handler(self, self._onTriggerIntroduce)},  
        {ccbCallbackName = "onTriggerIntroduce2", callback = handler(self, self._onTriggerIntroduce2)},--放大镜接口
        {ccbCallbackName = "onTriggerSetPassWord", callback = handler(self, self._onTriggerSetPassWord)}, 
        {ccbCallbackName = "onTriggerShare", callback = handler(self, self._onTriggerShare)},       
        {ccbCallbackName = "onTriggerClickHelpForState", callback = handler(self, self._onTriggerClickHelpForState)},       
        {ccbCallbackName = "onTriggerSelect", callback = handler(self, self._onTriggerSelect)},       
    }
    QUIDialogBlackRockTeam.super.ctor(self,ccbFile,callBacks,options)

    self._page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    self._page:setManyUIVisible()
    self._page:setScalingVisible(false)
    self._page.topBar:showWithBlackRockTeam()

    CalculateUIBgSize(self._ccbOwner.sp_background)

    self._players = {}

    self:updateView(true)

    remote.blackrock:setLastFastFightSeclectId(nil)
    
    local size = CCSize(800, 500)
    self.touchLayer = QUIGestureRecognizer.new()
    self.touchLayer:attachToNode(self._ccbOwner.node_contain, size.width, size.height, -size.width/2, -size.height/2, handler(self, self.onEvent))
    self.touchLayer:enable()
    self._moveState = QUIDialogBlackRockTeam.STATE_NONE

    if self._team then
        app:getUserOperateRecord():setBlackRockChapterSetting(self._team.chapterId)
    end
    
    remote.blackrock:setJoinTeamTime(q.serverTime())
end

function QUIDialogBlackRockTeam:viewDidAppear()
    QUIDialogBlackRockTeam.super.viewDidAppear(self)
    self:addBackEvent(false)
    self._blackrockProxy = cc.EventProxy.new(remote.blackrock)
    self._blackrockProxy:addEventListener(remote.blackrock.EVENT_UPDATE_TEAM_INFO, handler(self, self.blackrockPushHandler))
    self._blackrockProxy:addEventListener(remote.blackrock.EVENT_UPDATE_MYINFO, handler(self, self.updateMyInfoHandler))
    self._blackrockProxy:addEventListener(remote.blackrock.EVENT_UPDATE_STATE, handler(self, self._updateActiveState))

    self._chatDataProxy = cc.EventProxy.new(app:getServerChatData())
    self._chatDataProxy:addEventListener(QChatData.NEW_MESSAGE_RECEIVED, handler(self, self._onMessageReceived))

    -- 显示聊天信息
    self:setChatInfo()
    remote.blackrock:setInviteEnable(false)

    -- local options = self:getOptions()
    -- if options.isCreat == true then
    --     app:alert({content = "魂师大人，是否分享队伍信息至组队频道，便于他人快速加入？", title = "系统提示", callback = function (type)
    --         if type == ALERT_TYPE.CONFIRM then
    --             remote.blackrock:blackRockShareInviteMessageRequest()
    --         end
    --     end}, false)
    --     options.isCreat = false
    -- end

    self._ccbOwner.btn_plus:setVisible(false)
    self._ccbOwner.sp_select:setVisible(false)
    self:_updateBtnRefresh()
    self:_updateActiveState()
end

function QUIDialogBlackRockTeam:_updateActiveState()
    local teamInfo = remote.blackrock:getTeamInfo()
    local isNoAward = true
    local countAddtionalFun = function (fighter)
        if fighter.isNpc == false then
            if isNoAward then
                local count = remote.blackrock:getTotalAwardsCount() - (fighter.awardCount or 0) + (fighter.buyAwardCount or 0)
                if count > 0 then
                    isNoAward = false
                end
            end
        end
    end
    if teamInfo.leader ~= nil then
        countAddtionalFun(teamInfo.leader)
    end
    if teamInfo.member1 ~= nil then
        countAddtionalFun(teamInfo.member1)
    end
    if teamInfo.member2 ~= nil then
        countAddtionalFun(teamInfo.member2)
    end

    self._ccbOwner.node_noActive:setVisible(false)
    if isNoAward then
        self._ccbOwner.node_noActive:setVisible(true)
        self._ccbOwner.tf_state:setString("无奖励")
        self._state = remote.blackrock.NO_AWARD
    else
        local leaderLastActiveAt = self._team.leaderLastActiveAt
        if leaderLastActiveAt and q.serverTime()*1000 >= leaderLastActiveAt + remote.blackrock.noActiveTimeForMsec then
            print("不活躍 ： ", q.serverTime()*1000, leaderLastActiveAt, remote.blackrock.noActiveTimeForMsec, leaderLastActiveAt + remote.blackrock.noActiveTimeForMsec)
            self._ccbOwner.node_noActive:setVisible(true)
            self._ccbOwner.tf_state:setString("不活跃")
            self._state = remote.blackrock.NO_ACTIVE
        else
            self._state = remote.blackrock.NORMAL
        end
    end

    if self._state == remote.blackrock.NORMAL then
        local leaderLastActiveAt = self._team.leaderLastActiveAt
        if leaderLastActiveAt then 
            if self._leaderLastActiveAt ~= leaderLastActiveAt then
                if self._stateScheduler then
                    scheduler.unscheduleGlobal(self._stateScheduler)
                    self._stateScheduler = nil
                end

                local time = (leaderLastActiveAt + remote.blackrock.noActiveTimeForMsec)/1000 - q.serverTime()
                if time and time > 0 then
                    self._stateScheduler = scheduler.performWithDelayGlobal(function ()
                            if self._stateScheduler then
                                scheduler.unscheduleGlobal(self._stateScheduler)
                                self._stateScheduler = nil
                            end
                            if self:safeCheck() then
                                self:_updateActiveState()
                            end
                        end, time)
                end
            end
        else
            if self._stateScheduler then
                scheduler.unscheduleGlobal(self._stateScheduler)
                self._stateScheduler = nil
            end
        end
        self._leaderLastActiveAt = leaderLastActiveAt
    else
        if self._stateScheduler then
            scheduler.unscheduleGlobal(self._stateScheduler)
            self._stateScheduler = nil
        end
        self._leaderLastActiveAt = nil
    end
end

function QUIDialogBlackRockTeam:viewWillDisappear()
    QUIDialogBlackRockTeam.super.viewWillDisappear(self)
    self:removeBackEvent()
    if self._blackrockProxy ~= nil then
        self._blackrockProxy:removeAllEventListeners()
        self._blackrockProxy = nil
    end
    if self._refreshHandler ~= nil then
        scheduler.unscheduleGlobal(self._refreshHandler)
        self._refreshHandler = nil
    end
    if self._chatDataProxy ~= nil then
        self._chatDataProxy:removeAllEventListeners()
        self._chatDataProxy = nil
    end
    if self._stateScheduler then
        scheduler.unscheduleGlobal(self._stateScheduler)
        self._stateScheduler = nil
    end
    remote.blackrock:setInviteEnable(true)

    if self.touchLayer then
        self.touchLayer:detach()
        self.touchLayer = nil
    end

    self._ccbOwner.node_contain:removeAllChildren()

    if self._timeHideChatScheduler ~= nil then
        scheduler.unscheduleGlobal(self._timeHideChatScheduler)
        self._timeHideChatScheduler = nil
    end

    remote.blackrock:setJoinTeamTime(0)
end

--刷新界面显示
function QUIDialogBlackRockTeam:updateView(isAnimation)
    self._team = remote.blackrock:getTeamInfo()
    if self._team == nil then
        self:popSelf()
        app.tip:floatTip("很抱歉，您被队长踢出队伍，请重新寻找队伍~")
        return
    end
    --战斗开始了
    if self._team.teamProgress.isFight == true and self._team.teamProgress.isEnd == false then
        self:teamStart()
        return
    end
    self:showMyInfo()
    self:showTeamInfo(isAnimation)

    local isLeader = false
    if self._team.leader ~= nil then
        isLeader = self._team.leader.userId == remote.user.userId    
    end
    -- self._ccbOwner.node_count:setVisible(true)
end

--显示自己的信息
function QUIDialogBlackRockTeam:showMyInfo()
    self._myInfo = remote.blackrock:getMyInfo()
    local count = remote.blackrock:getTotalAwardsCount() - self._myInfo.awardCount + self._myInfo.buyAwardCount
    self._ccbOwner.tf_count:setString(count)

    local totalVIPNum = QVIPUtil:getCountByWordField("blackrock_award", QVIPUtil:getMaxLevel())
    local totalNum = QVIPUtil:getCountByWordField("blackrock_award")
    local buyCount = remote.blackrock:getMyInfo().buyAwardCount or 0
    -- self._ccbOwner.btn_plus:setVisible(totalVIPNum > totalNum or totalNum > buyCount)

    local totalRefreshVIPNum = QVIPUtil:getCountByWordField("black_rock_refresh", QVIPUtil:getMaxLevel())
    local totalRsNum = QVIPUtil:getCountByWordField("black_rock_refresh")

    local lastRsfreshCount = tonumber(totalRsNum) - remote.blackrock:getMyInfo().refreshRivalsCount 
    
    self._ccbOwner.tf_lastRefreshTime:setString(lastRsfreshCount)
end

-- 显示队伍信息
function QUIDialogBlackRockTeam:showTeamInfo(isAnimation)   
    self:_updateActiveState()

    local activityCount = 0
    local consortiaCount = 0
    local teams = {}
    local countAddtionalFun = function (fighter)
        if fighter.isNpc == false then
            if fighter.userId ~= remote.user.userId then
                activityCount = activityCount + 1
                if fighter.consortiaId == remote.user.userConsortia.consortiaId then
                    consortiaCount = consortiaCount + 1
                end
            end
        end
    end
    if self._team.leader ~= nil then
        teams[self._team.leader.userId] = self._team.leader
        countAddtionalFun(self._team.leader)
    end
    if self._team.member1 ~= nil then
        teams[self._team.member1.userId] = self._team.member1
        countAddtionalFun(self._team.member1)
    end
    if self._team.member2 ~= nil then
        teams[self._team.member2.userId] = self._team.member2
        countAddtionalFun(self._team.member2)
    end

    local config = QStaticDatabase:sharedDatabase():getConfiguration()
    local str = string.format("活跃＋%d%%", activityCount * tonumber(config.blackrock_active_addition.value) * 100)
    local strZm = string.format("宗门＋%d%%", consortiaCount * tonumber(config.blackrock_union_addition.value) * 100)
    local jiachengStr = string.format("%s %s", str, strZm)
    self._ccbOwner.tf_dangqianjiacheng:setString(jiachengStr)

    if self._comeBackIcon ~= nil then
        self._comeBackIcon:removeFromParent()
        self._comeBackIcon = nil
    end
    if self._team.isPlayComeBack then
        self._comeBackIcon = CCSprite:create("ui/dl_wow_pic/sp_comeback.png")
        local node = self._ccbOwner.tf_dangqianjiacheng:getParent()
        self._comeBackIcon:setAnchorPoint(ccp(0, 0.5))
        self._comeBackIcon:setPositionX(self._ccbOwner.tf_dangqianjiacheng:getPositionX() + self._ccbOwner.tf_dangqianjiacheng:getContentSize().width)
        self._comeBackIcon:setPositionY(self._ccbOwner.tf_dangqianjiacheng:getPositionY())
        node:addChild(self._comeBackIcon)
    end

    self._ccbOwner.tf_room_num:setString(self._team.symbol or 0)
    self._ccbOwner.node_setMima:setVisible(self._team.leader.userId == remote.user.userId)
    self._ccbOwner.node_select:setVisible(self._team.leader.userId == remote.user.userId)

    if self._team.leader.userId == remote.user.userId then
        self._ccbOwner.node_start:setVisible(true)
        self._ccbOwner.btn_invite:setVisible(true)
        self._ccbOwner.node_ready:setVisible(false)
        self._ccbOwner.tf_move_tips:setVisible(true)
        self._ccbOwner.node_cancel:setVisible(false)
    else
        self._ccbOwner.node_start:setVisible(false)
        self._ccbOwner.btn_invite:setVisible(false)
        self._ccbOwner.node_ready:setVisible(true)
        self._ccbOwner.tf_move_tips:setVisible(false)
        local progress = remote.blackrock:getProgress(remote.user.userId)
        if progress and progress.memberSts == 3 then
            self._ccbOwner.node_cancel:setVisible(true)
            self._ccbOwner.node_ready:setVisible(false)
        else
            self._ccbOwner.node_cancel:setVisible(false)
            self._ccbOwner.node_ready:setVisible(true)
        end
    end

    local allProgress = self._team.teamProgress.allProgress 

    for i = 1,3 do
        local battlePlayer = self._players[i]
        if battlePlayer == nil then
            battlePlayer = QUIWidgetBlackRockTeamPlayer.new()
            battlePlayer:addEventListener(QUIWidgetBlackRockTeamPlayer.EVENT_KICK, handler(self, self.kickHandler))
            battlePlayer:addEventListener(QUIWidgetBlackRockTeamPlayer.EVENT_INVITE, handler(self, self.inviteHandler))
            battlePlayer:addEventListener(QUIWidgetBlackRockTeamPlayer.EVENT_CHANGEPOS,handler(self,self.changePosHandler))
            if battlePlayer:getAvatar() then
                battlePlayer:getAvatar():setTouchEnabled(false)
            end
            table.insert(self._players, battlePlayer)
            -- self._ccbOwner["player"..i]:addChild(battlePlayer)
            battlePlayer:setAnchorPoint(ccp(0.5,0.5))
            battlePlayer:setPosition(ccp(0,120-144*(i-1)))
            self._ccbOwner.node_playerTeam:addChild(battlePlayer)
        end
        battlePlayer:setVisible(true)
        local progress = nil
        for _,v in ipairs(allProgress) do
            if v.memberPos == i then
                progress = v
                break
            end
        end
        battlePlayer:setIndex(i)
        if progress ~= nil then
            battlePlayer:setPlayerInfo(teams[progress.memberId], progress, self._team.leader)
        else
            battlePlayer:setPlayerInfo()
        end
    end
    self:_updateBtnRefresh()
end

function QUIDialogBlackRockTeam:setChatInfo()
    if self._chat == nil then
        self._chat = QUIWidgetChat.new({state = QUIWidgetChat.STATE_TEAM})
        self._ccbOwner.node_chat:addChild(self._chat)
        self._chat:setChatAreaVisible(true)
        self._chat:setChatInBlackRock(true)
        
        if self._timeHideChatScheduler ~= nil then
            scheduler.unscheduleGlobal(self._timeHideChatScheduler)
            self._timeHideChatScheduler = nil
        end
        self._timeHideChatScheduler = scheduler.performWithDelayGlobal(function()
            self._chat:setChatAreaVisible(false)
        end, 5)

    end
end

--检查是不是全部准备
function QUIDialogBlackRockTeam:checkReady()
    if self._team.member1 == nil or self._team.member2 == nil then
        app.tip:floatTip("队伍没满员~")
        return false
    end
    if self._team.teamProgress ~= nil then
        for _,progress in ipairs(self._team.teamProgress.allProgress) do
            if progress.memberId ~= self._team.leader.userId then
                if progress.memberSts == 2 then
                    app.tip:floatTip(string.format("魂师大人，%d号位还未准备，无法开始~", progress.memberPos))
                    return false
                elseif progress.memberSts == 1 then
                    app.tip:floatTip(progress.memberPos.."位置掉线了~")
                    return false
                end
            end
        end
    end
    return true
end

function QUIDialogBlackRockTeam:changePos(pos1, pos2)
    remote.blackrock:blackRockChangeMemberPositionRequest(pos1, pos2, function ()
        if self:safeCheck() then
            self:updateView()
        end
    end)
end

function QUIDialogBlackRockTeam:setLockState()
    local team = remote.blackrock:getTeamInfo()
    self._ccbOwner.sp_lock_state:setVisible(false)

    -- if team.password ~= nil and team.password ~= "" then
    --     self._ccbOwner.sp_lock_state:setVisible(true)
    -- end
    self._ccbOwner.btn_set_password:setVisible(team.leader.userId == remote.user.userId)
end

--战斗开始
function QUIDialogBlackRockTeam:teamStart()
    if self._fightStart then return end
    self._fightStart = true
    self:enableTouchSwallowTop()
    self:popOtherDialog()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBlackRockBattle", options = {isFrist = true}})
end

--收到推送消息
function QUIDialogBlackRockTeam:blackrockPushHandler(e)
    local value = e.value
    if value.messageType == "BLACK_ROCK_MEMBER_CHANGE_POSITION" then
        local team = remote.blackrock:getTeamInfo()
        self:updateView()
    elseif value.messageType == "BLACK_ROCK_REFRESH_RIVALS" then
        if self._refreshHandler ~= nil then
            scheduler.unscheduleGlobal(self._refreshHandler)
            self._refreshHandler = nil
        end
        self:updateView(false)
    elseif value.messageType == "BLACK_ROCK_TEAM_DELETE" then
        self:popOtherDialog()
        self:popSelf()
        app.tip:floatTip("魂师大人，由于长时间未开始，队伍已解散~")
    else
        self:updateView()
    end
end

function QUIDialogBlackRockTeam:updateMyInfoHandler()
    self:showMyInfo()
end

--xurui: 收到新的组队聊天信息
function QUIDialogBlackRockTeam:_onMessageReceived(data)
    if self._popClose == true then return end
    if data.channelId and data.channelId == app:getServerChatData():teamChannelId() and data.misc.type ~= "admin" then
        for index,widget in ipairs(self._players) do
            if widget:getUserId() == data.misc.uid  then --and data.misc.uid ~= remote.user.userId then
                widget:showChatMessage(data.message)
            end
        end
    end

    if self._chat then
        self._chat:setChatAreaVisible(true)

        if self._timeHideChatScheduler ~= nil then
            scheduler.unscheduleGlobal(self._timeHideChatScheduler)
            self._timeHideChatScheduler = nil
        end
        self._timeHideChatScheduler = scheduler.performWithDelayGlobal(function()
            self._chat:setChatAreaVisible(false)
        end, 5)
    end
end

--通过位置获取avatar
function QUIDialogBlackRockTeam:getAvatarByPos(pos, isCheck)
    for index,widget in ipairs(self._players) do
        if isCheck == false or (isCheck == true and widget:getPlayerInfo() ~= nil) then
            local newPos = widget:convertToNodeSpaceAR(pos)
            if newPos.x > -360 and newPos.x < -290 and newPos.y > -30 and newPos.y < 50 then
                return widget, widget:getIndex()
            end
        end
    end
end
--移动
function QUIDialogBlackRockTeam:onEvent(event)
    if event.name == "began" then
        if self._moveState == QUIDialogBlackRockTeam.STATE_NONE and remote.blackrock:getIsLeader() then
            local widget,index = self:getAvatarByPos(ccp(event.x, event.y), true)
            if widget ~= nil then
                app.sound:playSound("common_small")
                self._moveState = QUIDialogBlackRockTeam.STATE_MOVE
                self._selectWidget = widget
                self._selectIndex = index
                self._selectWidget:setAvatarVisible(false)

                local playerInfo = self._selectWidget:getPlayerInfo()
                if self._moveWidget ~= nil then
                    self._moveWidget:removeFromParent()
                    self._moveWidget = nil
                end

                self._moveWidget = QUIWidgetTeamChat.new()
                -- self._ccbOwner.node_avatar:addChild(self._avatar)
                self._moveWidget:setInfo(playerInfo,playerInfo.userId == self._team.leader.userId)

                -- self._moveWidget = QUIWidgetActorDisplay.new(playerInfo.defaultActorId, {heroInfo = {skinId = playerInfo.defaultSkinId}})
                -- self._moveWidget:setScaleX(-1.2)
                -- self._moveWidget:setScaleY(1.2)
                self:getView():addChild(self._moveWidget)

                self._offsetPos = self._selectWidget:getAvatarPos()
                self._offsetPos = ccp(self._offsetPos.x - event.x, self._offsetPos.y - event.y)
                local pos = self:getView():convertToNodeSpaceAR(ccp(event.x,event.y))
                self._moveWidget:setPosition(pos.x + self._offsetPos.x, pos.y + self._offsetPos.y)
            end
        else
            return
        end
    elseif event.name == "moved" then
        if self._moveState == QUIDialogBlackRockTeam.STATE_MOVE then
            if self._moveWidget ~= nil then
                local pos = self:getView():convertToNodeSpaceAR(ccp(event.x,event.y))
                self._moveWidget:setPosition(pos.x + self._offsetPos.x, pos.y + self._offsetPos.y)
            end
        end
    elseif event.name == "ended" then
        if self._moveState == QUIDialogBlackRockTeam.STATE_MOVE then
            app.sound:playSound("common_cancel")
            self._moveState = QUIDialogBlackRockTeam.STATE_NONE

            local targetWidget,index = self:getAvatarByPos(ccp(event.x, event.y), false)

            if index ~= nil and index ~= self._selectIndex then
                self:changePos(index, self._selectIndex)
            else
                self._selectWidget:refresh()
            end
            if self._moveWidget ~= nil then
                self._moveWidget:removeFromParent()
                self._moveWidget = nil
            end
        end
    end
end

function QUIDialogBlackRockTeam:changePosHandler(data)
    if self:safeCheck() then
        for index,widget in ipairs(self._players) do
            if widget:getUserId() == remote.user.userId then
                widget:showChatMessage(data.message)
            end
        end
    end
end
--踢掉一个成员
function QUIDialogBlackRockTeam:kickHandler( ... )
    self:updateView()
end

function QUIDialogBlackRockTeam:inviteHandler( ... )
    app.sound:playSound("common_small")
    if remote.user.userConsortia ~= nil then
        remote.blackrock:blackRockGetOnlineConsortiaMemberListRequest(self._team.chapterId, function (data)
            if self:safeCheck() then
                if data.blackRockGetOnlineConsortiaMemberListResponse ~= nil then
                    local members = data.blackRockGetOnlineConsortiaMemberListResponse.onlineMemebers or {}
                    self._invateDialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBlackRockInvite",
                        options = {members = members, teamId = self._team.teamId, chapterId = self._team.chapterId, callBack = function ()
                            self._invateDialog = nil
                        end}})
                end
            end
        end)
    else
        self._invateDialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBlackRockInvite",
            options = {members = {}, teamId = self._team.teamId, chapterId = self._team.chapterId, callBack = function ()
                self._invateDialog = nil
            end}})
    end
end

--刷新怪物
function QUIDialogBlackRockTeam:_onTriggerRefresh(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_refresh) == false then return end    
    app.sound:playSound("common_small")
    local isAllBoss = self._ccbOwner.sp_select:isVisible()
    remote.blackrock:blackRockRefreshTeamRivalsRequest(isAllBoss, function ()
        if self:safeCheck() then
            for index,widget in ipairs(self._players) do
                 widget:setIndex(index)
                 widget:updateBossInfo()
            end
            self:_updateBtnRefresh()
            self:_updateActiveState()
        end
    end)
end

--开始战斗
function QUIDialogBlackRockTeam:_onTriggerStartBattle(event)
    if q.buttonEventShadow(event,self._ccbOwner.btn_battle) == false then return end
    app.sound:playSound("common_confirm")
    if self:checkReady() then
        if self._state == remote.blackrock.NO_AWARD then
            app:alert({content = "魂师大人，队伍内成员均无领奖次数，继续战斗无法解锁乐于助人成就，是否继续？",title="系统提示", callback = function (state)
                    if state == ALERT_TYPE.CONFIRM then
                        remote.blackrock:blackRockTeamFightStartRequest(function ()
                                if self:safeCheck() then
                                    self:teamStart()
                                end
                            end)
                    end
                end})
        else
            remote.blackrock:blackRockTeamFightStartRequest(function ()
                    if self:safeCheck() then
                        self:teamStart()
                    end
                end)
        end
    end
end

--移除掉其他的dialog
function QUIDialogBlackRockTeam:popOtherDialog()
    if self._invateDialog ~= nil then
        self._invateDialog:popSelf()
        self._invateDialog = nil
    end
    if self._buyCountDialog ~= nil then
        self._buyCountDialog:popSelf()
        self._buyCountDialog = nil
    end
end

--准备战斗
function QUIDialogBlackRockTeam:_onTriggerReady(event)
    if q.buttonEventShadow(event,self._ccbOwner.btn_ready) == false then return end
    
    local progress = remote.blackrock:getProgress(remote.user.userId)
    if progress then
        remote.blackrock:blackRockFightReadyRequest((progress.memberSts == 3), function()
            if self:safeCheck() then
                self:updateView(false)
            end
        end)
    end
end

function QUIDialogBlackRockTeam:_onTriggerCancle( event )
    if q.buttonEventShadow(event,self._ccbOwner.btn_cancle) == false then return end

    local progress = remote.blackrock:getProgress(remote.user.userId)
    if progress then
        remote.blackrock:blackRockFightReadyRequest((progress.memberSts == 3), function()
            if self:safeCheck() then
                self:updateView(false)
            end
        end)
    end
end
--一键邀请
function QUIDialogBlackRockTeam:_onTriggerInvite(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_invite_bt) == false then return end    
    app.sound:playSound("common_small")
    remote.blackrock:blackRockOneKeyInviteRequest(function ()
        if self:safeCheck() then
            self:updateView(false)
        end
    end)
end

function QUIDialogBlackRockTeam:_onTriggerIntroduce()
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBlackRockRule"})
end

function QUIDialogBlackRockTeam:_onTriggerIntroduce2()
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBlackRockRule", options = {index = 2}})
end

--购买次数
function QUIDialogBlackRockTeam:_onPlus()
    app.sound:playSound("common_small")
    local count = remote.blackrock:getMyInfo().buyAwardCount or 0
    if count >= QVIPUtil:getBlackRockBuyAwardsCount() then
        app:vipAlert({title = "奖励次数", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.BLACKROCK_BUY_AWARDS_COUNT}, false)
    else
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBuyCountBase",
            options = {cls = "QBuyCountBlackRock"}})
    end   
end

function QUIDialogBlackRockTeam:_onTriggerSetPassWord(event)
if q.buttonEventShadow(event, self._ccbOwner.btn_setMima) == false then return end        
    app.sound:playSound("common_small")

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBlackRockSearchRoom", 
        options = {alertType = "CHANGE_PASSWORD_ALERT", callback = function()
            if self:safeCheck() then
                self:setLockState()
            end
        end}})
end

function QUIDialogBlackRockTeam:_onTriggerClickHelpForState(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_helpForState) == false then return end        
    app.sound:playSound("common_small")
    if self._state == remote.blackrock.NO_AWARD then
        app.tip:floatTip("队伍内成员均无领奖次数，继续战斗无法解锁乐于助人成就")
    elseif self._state == remote.blackrock.NO_ACTIVE then
        app.tip:floatTip("队长最近一段时间无操作，可能需要长时间的等待")
    end
end

function QUIDialogBlackRockTeam:_onTriggerSelect(event)
    app.sound:playSound("common_small")
    self._ccbOwner.sp_select:setVisible(not self._ccbOwner.sp_select:isVisible())
    self:_updateBtnRefresh()
end

function QUIDialogBlackRockTeam:_updateBtnRefresh()
    if self._ccbOwner.sp_select:isVisible() then
        self._ccbOwner.sp_token:setVisible(true)
        self._ccbOwner.tf_refresh:setPositionX(-30)
        local cost = db:getConfigurationValue("blackrock_all_cruel_enemy") or 999
        self._ccbOwner.tf_refresh:setString(cost.."刷新")
    else
        self._myInfo = remote.blackrock:getMyInfo()
        local config = QStaticDatabase:sharedDatabase():getConfiguration()
        local freeCount = tonumber(config.blackrock_refresh_free.value)
        local refreshToken = tonumber(config.blackrock_token.value)
        local todayRefreshCount = self._myInfo.refreshRivalsCount or 0

        if todayRefreshCount < freeCount then
            self._ccbOwner.sp_token:setVisible(false)
            self._ccbOwner.tf_refresh:setPositionX(-45)
            self._ccbOwner.tf_refresh:setString("免费刷新")
        elseif todayRefreshCount >= freeCount then
            self._ccbOwner.sp_token:setVisible(true)
            self._ccbOwner.tf_refresh:setPositionX(-30)
            self._ccbOwner.tf_refresh:setString(string.format("%d刷新",refreshToken))
        end
    end
end

function QUIDialogBlackRockTeam:_onTriggerShare(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_share) == false then return end
    app.sound:playSound("common_small")
    local teamInfo = remote.blackrock:getTeamInfo()
    if remote.user.userId ~= teamInfo.leader.userId then
        app.tip:floatTip("只有队长可以分享哦～")
        return
    end

    local maxDungeonConfig = nil
    if teamInfo and teamInfo.teamProgress and teamInfo.teamProgress.isFight == false and teamInfo.teamProgress.isEnd == false then
        local maxColor = 0
        for _, value in ipairs(teamInfo.teamProgress.allProgress or {}) do
            for _, info in ipairs(value.stepInfo or {}) do
                local dungeonConfig = remote.blackrock:getConfigByDungeonId(info.stepId)
                if dungeonConfig and maxColor < tonumber(dungeonConfig.colour) then
                    maxColor = tonumber(dungeonConfig.colour)
                    maxDungeonConfig = dungeonConfig
                end
            end
        end 
    end

    if not maxDungeonConfig then return end

    local getNpcColor = function(str)
        if str == "1" then
            return "##w"
        elseif str == "2" then
            return "##q"
        elseif str == "3" then
            return "##b"
        elseif str == "4" then
            return "##p"
        elseif str == "5" then
            return "##o"
        elseif str == "6" then
            return "##r"
        else
            return "##z"
        end
    end
    local nameColor = remote.blackrock:getColorById(maxDungeonConfig.id)
    local npcColor = getNpcColor(maxDungeonConfig.colour)
    local num, unit = q.convertLargerNumber(maxDungeonConfig.monster_battleforce or 0)
    local npcForce = num..(unit or "")
    local npcStr = maxDungeonConfig.monster_name.."("..npcForce..")"
    local msg = "##z我在"..nameColor..maxDungeonConfig.name.."##z刷到了"..npcColor..npcStr.."##z，邀请你来和我一起战斗，同宗门还有额外加成！"
    local btns = {}
    local btnDesc = {}
    if remote.union:checkHaveUnion() then
        btns = {ALERT_BTN.BTN_OK, ALERT_BTN.BTN_CANCEL, ALERT_BTN.BTN_CLOSE}
        btnDesc = {"宗门聊天", "世界聊天"}
    else
        btns = {ALERT_BTN.BTN_CANCEL, ALERT_BTN.BTN_CLOSE}
        btnDesc = {"世界聊天"}
    end
    app:alert({content = "魂师大人，是否要分享传灵塔信息至聊天频道，便于同服玩家一起来攻打并激活组队加成？", title = "系统提示",
        btns = btns,
        btnDesc = btnDesc,
        callback = function (type)
        if type == ALERT_TYPE.CONFIRM then
            app:getServerChatData():sendMessage(msg, CHANNEL_TYPE.UNION_CHANNEL, nil, nil, nil, {type = "blackrock", teamId = teamInfo.teamId, chapterId = teamInfo.chapterId, password = teamInfo.password}, 
                function(state)
                    if state == 0 then
                        app.tip:floatTip("传灵塔队伍信息已分享到宗门频道~")
                    elseif state == "CHAT_BLACK_ROCK_SHARE_CD" then
                        app.tip:floatTip("5分钟之内不能重复分享")
                    end
                end)
        elseif type == ALERT_TYPE.CANCEL then
            app:getServerChatData():sendMessage(msg, CHANNEL_TYPE.GLOBAL_CHANNEL, nil, nil, nil, {type = "blackrock", teamId = teamInfo.teamId, chapterId = teamInfo.chapterId, password = teamInfo.password},
                function(state)
                    if state == 0 then
                        app.tip:floatTip("传灵塔队伍信息已分享到世界频道~")
                    elseif state == "CHAT_BLACK_ROCK_SHARE_CD" then
                        app.tip:floatTip("5分钟之内不能重复分享")
                    end
                end)
        end
    end}, false)

end
function QUIDialogBlackRockTeam:onTriggerBackHandler(tag)
    app:alert({content = "确定离开队伍?", title = "系统提示", callback = function (state)
        if state == ALERT_TYPE.CONFIRM then
            remote.blackrock:blackRockQuitTeamRequest()
            app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
        end
    end})
end

function QUIDialogBlackRockTeam:onTriggerHomeHandler(tag)
    app:alert({content = "确定离开队伍?", title = "系统提示", callback = function (state)
        if state == ALERT_TYPE.CONFIRM then
            remote.blackrock:blackRockQuitTeamRequest()
            app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
        end
    end})
end

return QUIDialogBlackRockTeam