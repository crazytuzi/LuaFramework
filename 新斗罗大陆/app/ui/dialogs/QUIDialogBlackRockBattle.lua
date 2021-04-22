local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogBlackRockBattle = class("QUIDialogBlackRockBattle", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetBlackRockBattlePlayer = import("..widgets.blackrock.QUIWidgetBlackRockBattlePlayer")
local QUIViewController = import("..QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetBlackRockBattleLine = import("..widgets.blackrock.QUIWidgetBlackRockBattleLine")
local QUIWidgetChat = import("..widgets.QUIWidgetChat")
local QChatData = import("...models.chatdata.QChatData")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

QUIDialogBlackRockBattle.STATE_NONE = "STATE_NONE"
QUIDialogBlackRockBattle.STATE_MOVE = "STATE_MOVE"


function QUIDialogBlackRockBattle:ctor(options)
    local ccbFile = "ccb/Dialog_Black_mountain_chuanjian2.ccbi"
    local callBacks = {
         {ccbCallbackName = "onTriggerHelp", callback = handler(self, self._onTriggerHelp)},
    }
    QUIDialogBlackRockBattle.super.ctor(self,ccbFile,callBacks,options)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if page and page.class.__cname == "QUIPageMainMenu" then
        page:setAllUIVisible(false)
        page:setScalingVisible(false)
    end

    CalculateUIBgSize(self._ccbOwner.sp_background)
    CalculateBattleUIPosition(self._ccbOwner.node_star1)
    CalculateBattleUIPosition(self._ccbOwner.node_star2)
    CalculateBattleUIPosition(self._ccbOwner.node_star3)

    self._lines = {}
    self._color = "yellow"
    self._ccbOwner.tf_time:setColor(UNITY_COLOR_LIGHT.yellow)   
    self._totalTime = remote.blackrock:getTotalFightTime()

end

function QUIDialogBlackRockBattle:viewDidAppear()
    QUIDialogBlackRockBattle.super.viewDidAppear(self)
    self:addBackEvent(false)
    QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)
    self._blackrockProxy = cc.EventProxy.new(remote.blackrock)
    self._blackrockProxy:addEventListener(remote.blackrock.EVENT_UPDATE_TEAM_INFO, handler(self, self.blackrockPushHandler))
    self._blackrockProxy:addEventListener(remote.blackrock.EVENT_FIGHT_END_AWARDS, handler(self, self.fightEndAwardsPushHandler))
    self._blackrockProxy:addEventListener(remote.blackrock.EVENT_FIGHT_QUICK, handler(self, self.exitFromBattleHandler))

    self._chatDataProxy = cc.EventProxy.new(app:getServerChatData())
    self._chatDataProxy:addEventListener(QChatData.NEW_MESSAGE_RECEIVED, handler(self, self._onMessageReceived))

    self:initView()
    self:fightEndAwards()
    -- 显示聊天信息
    self:setChatInfo()
end

function QUIDialogBlackRockBattle:viewWillDisappear()
    QUIDialogBlackRockBattle.super.viewWillDisappear(self)
    self:removeBackEvent()
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)
    if self._blackrockProxy ~= nil then
        self._blackrockProxy:removeAllEventListeners()
        self._blackrockProxy = nil
    end
    if self._effectHandlers ~= nil then
        for _,handler in ipairs(self._effectHandlers) do
            scheduler.unscheduleGlobal(handler)
        end
    end
    if self._countTimeHandler ~= nil then
        scheduler.unscheduleGlobal(self._countTimeHandler)
        self._countTimeHandler = nil
    end
    if self._waitStarHandler ~= nil then
        scheduler.unscheduleGlobal(self._waitStarHandler)
        self._waitStarHandler = nil
    end
    if self._chatDataProxy ~= nil then
        self._chatDataProxy:removeAllEventListeners()
        self._chatDataProxy = nil
    end
end
 
function QUIDialogBlackRockBattle:initView()
    local isFrist = self:getOptions().isFrist
    self:getOptions().isFrist = false
    -- local posY = {6, -165, -340}
    local selfIndex = 0
    for i=1,3 do
        if self._lines[i] == nil then
            self._lines[i] = QUIWidgetBlackRockBattleLine.new({index = i, parent = self})
            self._lines[i]:addEventListener(QUIWidgetBlackRockBattleLine.EVENT_GET_STAR, handler(self, self.playStarAnimationHandler))
            self._lines[i]:addEventListener(QUIWidgetBlackRockBattleLine.EVENT_GET_BUFF, handler(self, self.playBuffAnimationHandler))
            self._lines[i]:addEventListener(QUIWidgetBlackRockBattleLine.EVENT_FAST_FIGHT, handler(self, self.blackRockQuickFight))
            self._ccbOwner["node_line"..i]:addChild(self._lines[i])
        end

        if isFrist then
            self._effectHandlers = {}
            local handler = scheduler.performWithDelayGlobal(function ()
                self._lines[i]:refreshInfo(isFrist)
            end, (i-1)*0.3)
            table.insert(self._effectHandlers, handler)
        else
            self._lines[i]:refreshInfo(isFrist)
        end

        local progress = remote.blackrock:getProgressByPos(i)
        if isFrist ~= true and progress.isEnd == true then
            if progress.isGiveUp == true then
                self._lines[i]:showLineLost(false)
                self:showStarByIndex(i, false)
            else
                self._ccbOwner["node_star"..i]:setVisible(false)
                self:showStarByIndex(i, true)
                self._lines[i]:showLineWin(false)
            end
        else
            self._ccbOwner["node_star"..i]:setVisible(true)
            self:showStarByIndex(i, false)
        end

        local playerInfo = remote.blackrock:getMemberById(progress.memberId)
        if playerInfo.userId == remote.user.userId then
            selfIndex = i
        end
    end

    if isFrist == true then
        self:enableTouchSwallowTop()
        local handler = scheduler.performWithDelayGlobal(function ()
            local animationPlayer = QUIWidgetAnimationPlayer.new()
            self:getView():addChild(animationPlayer)
            app.sound:playSound("battle_fight")
            local ccbOnwner = animationPlayer:playAnimation("ccb/Dialog_Black_mountain_fight.ccbi",nil,function ()
                self:disableTouchSwallowTop()
                animationPlayer:disappear()
                animationPlayer:removeFromParent()
            end)
            CalculateUIBgSize(ccbOnwner.ly_bg)
        end, 3*0.3)
        table.insert(self._effectHandlers, handler)
    end

    --倒计时
    self._teamInfo = remote.blackrock:getTeamInfo()
    if self._teamInfo ~= nil then
        self._startTime = self._teamInfo.teamProgress.fightStartAt/1000
        self:countTime()
    end

    --刷新最大通关boss
    self:refreshMaxCombatTeamID()
end

function QUIDialogBlackRockBattle:blackRockQuickFight(event)
    if self._fightEnd == false then return end
    self._fightEnd = false
    remote.blackrock:responsBlackRockFightQuick(event.stepInfo,event.progressId,function(data)
        if self:safeCheck() then
            local awards = {}
            local score = 0
            if data.gfQuickResponse.blackRockMemberStepFightEndResponse.stepWinAward ~= nil then
                awards = remote.items:analysisServerItem(data.gfQuickResponse.blackRockMemberStepFightEndResponse.stepWinAward, awards)
            end
            if data.gfQuickResponse.blackRockMemberStepFightEndResponse.awardScore ~= nil then
                score = data.gfQuickResponse.blackRockMemberStepFightEndResponse.awardScore
            end
            if score > 0 then
                table.insert(awards,{typeName=ITEM_TYPE.BLACKROCK_INTEGRAL, count=score})
            end

            remote.user:addPropNumForKey("todayBlackFightCount")
            
            self._winDialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogWin", 
                options = {awards = awards, closeCallback = function()
                    self._winDialog = nil
                end}}, {isPopCurrentDialog = true})
            remote.blackrock:quickFightEnd()  
        end   
    end,function()
        self._fightEnd = false
    end)
end

function QUIDialogBlackRockBattle:refreshMaxCombatTeamID()
    if app.unlock:checkLock("UNLOCK_CHUANLINGTA_SAODANG", false) then 
        local unlockConfigWeek = app.unlock:getConfigByKey("UNLOCK_CHUANLINGTA_SAODANG2")
        local level = remote.user.level
        local titleStr = ""
        if level >= unlockConfigWeek.team_level then
            titleStr = "本周完胜最强敌人："
        else 
            titleStr = "今日完胜最强敌人："
        end
        self._ccbOwner.tf_maxbossTips:setString(titleStr)

        self._ccbOwner.node_showMaxBoss:setVisible(true)
        local maxCombatTeamId = tonumber(remote.blackrock:getMaxCombatTeamId())
        if maxCombatTeamId == 1 then
            self._ccbOwner.tf_maxbossName:setString("前哨")
            self._ccbOwner.tf_maxbossName:setColor(UNITY_COLOR_LIGHT.blue)
        elseif maxCombatTeamId == 2 then
            self._ccbOwner.tf_maxbossName:setString("中坚")
            self._ccbOwner.tf_maxbossName:setColor(UNITY_COLOR_LIGHT.purple)
        elseif maxCombatTeamId == 3 then
            self._ccbOwner.tf_maxbossName:setString("头目")
            self._ccbOwner.tf_maxbossName:setColor(UNITY_COLOR_LIGHT.orange)
        elseif maxCombatTeamId == 4 then
            self._ccbOwner.tf_maxbossName:setString("首领")
            self._ccbOwner.tf_maxbossName:setColor(UNITY_COLOR_LIGHT.red)
        else
            self._ccbOwner.tf_maxbossName:setString("暂无")
            self._ccbOwner.tf_maxbossName:setColor(UNITY_COLOR_LIGHT.white)
        end
    else
        self._ccbOwner.node_showMaxBoss:setVisible(false)
    end
end
function QUIDialogBlackRockBattle:countTime()
    if self._countTime == nil then
        local passTime = q.serverTime() - self._startTime
        if passTime <= self._totalTime then
            if self._totalTime - passTime <= 60 and self._color == "yellow" then
                self._color = "red"
                self._ccbOwner.tf_time:setColor(UNITY_COLOR_LIGHT.red)
            elseif self._totalTime - passTime > 60 and self._color == "red" then
                self._color = "yellow"
                self._ccbOwner.tf_time:setColor(UNITY_COLOR_LIGHT.yellow)    
            end
            self._ccbOwner.tf_time:setString(q.timeToHourMinuteSecond(self._totalTime - passTime))
            if self._countTimeHandler ~= nil then
                scheduler.unscheduleGlobal(self._countTimeHandler)
                self._countTimeHandler = nil
            end
            self._countTimeHandler = scheduler.performWithDelayGlobal(function ()
                self._countTimeHandler = nil
                self:countTime()
            end, 1)
        end 
    end
end

function QUIDialogBlackRockBattle:showStarByIndex(index, isGet)
    local sp = CCSprite:create()
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ui/Fighting.plist")
    if isGet == false then
        sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("Big_star_hui.png"))
    else
        sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("Big_star2.png"))
    end
    sp:setScale(0.5)
    self._ccbOwner["complete_star"..index]:removeAllChildren()
    self._ccbOwner["complete_star"..index]:addChild(sp)
end

function QUIDialogBlackRockBattle:_playStarAnimationByIndex(index, callback)
    self._ccbOwner["node_star"..index]:setVisible(false)
    local pos = self._ccbOwner["node_star"..index]:convertToWorldSpaceAR(ccp(0,0))
    local sp = CCSprite:create()
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ui/Fighting.plist")
    sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("Big_star2.png"))
    pos = self:getView():convertToNodeSpaceAR(pos)
    self:getView():addChild(sp)
    sp:setPosition(pos)

    local targetPos = self._ccbOwner["complete_star"..index]:convertToWorldSpaceAR(ccp(0,0))
    targetPos = self:getView():convertToNodeSpaceAR(targetPos)

    local actionArrayIn = CCArray:create()
    actionArrayIn:addObject(CCMoveTo:create(0.3, ccp(targetPos.x, targetPos.y)))
    -- actionArrayIn:addObject(CCScaleTo:create(0.2, 0.45, 0.45))
    -- actionArrayIn:addObject(CCScaleTo:create(0.1, 0.5, 0.5))
    actionArrayIn:addObject(CCCallFunc:create(function ()
        sp:setVisible(false)
        sp:removeFromParent()
        local animationPlayer = QUIWidgetAnimationPlayer.new()
        animationPlayer:playAnimation("ccb/effects/zd_tgxingxing.ccbi")
        self._ccbOwner["complete_star"..index]:addChild(animationPlayer)
        self:showStarByIndex(index, true)
        if callback ~= nil then
            callback()
        end
    end))
    local ccsequence = CCSequence:create(actionArrayIn)
    sp:runAction(ccsequence)
end

function QUIDialogBlackRockBattle:blackrockPushHandler(e)
    if e.value.messageType == "BLACK_ROCK_TEAM_FIGHT_START" then
        self._startNewBattle = true
    end
    local teamInfo = remote.blackrock:getTeamInfo()

    if teamInfo ~= nil then
        for i=1,3 do
            self._lines[i]:checkLineState()
        end      
    end
end

--检查是否有奖励没弹出来
function QUIDialogBlackRockBattle:fightEndAwards()
    if self._awardsDialog ~= nil then
        return false
    end

    -- body blackRockDoTeamFightEndRequest
    local awardTbl = remote.blackrock:getEndAwards()
    if awardTbl ~= nil then
        local awards = awardTbl.endAwards
        local awardId = awardTbl.endAwardId
        local endScore = awardTbl.endScore
        local giveAward = awardTbl.giveAward
        local isPlayerComeBack = awardTbl.isPlayerComeBack

        remote.blackrock:blackRockGetProgressInfoRequest(awardId,function(data)
            if self:safeCheck() then
                local callFun = function ()
                    self._waitStarHandler = nil
                    self:disableTouchSwallowTop()
                    local isLost = true
                    local teamInfo = remote.blackrock:getTeamInfo()
                    local allProgress = data.blackRockGetProgressInfoResponse.allProgress
                    if teamInfo ~= nil then
                        for _, progress in ipairs(allProgress) do
                            if progress.isWin == true then
                                isLost = false
                                break
                            end
                        end
                    end
                    
                    if self._winDialog then
                        self._winDialog:popSelf()
                        self._winDialog = nil
                    end
                    if isLost == false then    
                        app.taskEvent:updateTaskEventProgress(app.taskEvent.BLACKROCK_PASS_EVENT, 1)
                        if not giveAward then
                            app.taskEvent:updateTaskEventProgress(app.taskEvent.BLACKROCK_PASS_WITHOUT_REWARD_EVENT, 1)
                        end
                        remote.blackrock:setLastFastFightSeclectId(nil)
                        self._awardsDialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogblackRockBattleAwards",
                            options = {awards = awards, sendId = awardId,endScore = endScore, giveAward = giveAward, info = teamInfo,allProgress = allProgress,isPlayerRecall = isPlayerComeBack, callBack = function ()
                                self._awardsDialog = nil
                   
                                remote.blackrock:blackRockGetMyInfoRequest(function ()
                                    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
                                    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBlackRock"})
                                end)
                            end}})
                    else
                        remote.blackrock:setLastFastFightSeclectId(nil)
                        self._awardsDialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogblackRockBattleLost",
                            options = {info = teamInfo, callBack = function ()
                                self._awardsDialog = nil
                     
                                remote.blackrock:blackRockGetMyInfoRequest(function ()
                                    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
                                    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBlackRock"})
                                end)                                                           
                            end}})
                    end
                end

                self:enableTouchSwallowTop()
                self._index = {}
                for i=1,3 do
                    local result = self._lines[i]:checkLineState(function ()
                        self._index[i] = 1
                        local count = table.nums(self._index)
                        if count == 3 then
                            callFun()
                        end
                    end)
                    if result == false then
                        self._index[i] = 1
                        self._lines[i]:refreshInfo()
                        local progress = remote.blackrock:getProgressByPos(i)
                        if progress.isWin == true then
                            self._ccbOwner["node_star"..i]:setVisible(false)
                            self:showStarByIndex(i, true)
                            self._lines[i]:showLineWin(false)
                        end
                        local count = table.nums(self._index)
                        if count == 3 then
                            callFun()
                        end
                    end
                end
                return true   
            end
        end)     
    end
    return false
end

function QUIDialogBlackRockBattle:getTeamInfoAtEndAwards()
    remote.blackrock:blackRockGetMyInfoRequest(function ()
        if self:safeCheck() then
            self:checkMyTeamInfo()
        end
    end)
end

--检查自己的teaminfo状态是否变化
function QUIDialogBlackRockBattle:checkMyTeamInfo()
    local teamInfo = remote.blackrock:getTeamInfo()
    if teamInfo ~= nil then
        if teamInfo.teamProgress.isFight == true and teamInfo.teamProgress.isEnd == false then
            self:getOptions().isFrist = true
            self:initView()
        else 
            app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
            app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBlackRockTeam"})
        end
    else
        app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBlackRock"})
    end
end

--显示战斗结束奖励
function QUIDialogBlackRockBattle:fightEndAwardsPushHandler(e)
    if app.battle == nil then
        self:fightEndAwards()
    end
end

function QUIDialogBlackRockBattle:playStarAnimationHandler(e)
    local line = e.target
    local callback = e.callback
    self:_playStarAnimationByIndex(line:getIndex(), callback)

    local progress = remote.blackrock:getProgress(remote.user.userId)
    if progress and progress.memberPos == line:getIndex() then
        self._ccbOwner.tf_leave_tips:setVisible(true)
        self._ccbOwner.tf_leave_tips:setOpacity(0)
        self._ccbOwner.tf_leave_tips:setScale(2)
        local array1 = CCArray:create()
        array1:addObject(CCCallFunc:create(function()
                makeNodeOpacity(self._ccbOwner.tf_leave_tips, 255)
            end))
        array1:addObject(CCScaleTo:create(0.08, 1))

        local array2 = CCArray:create()
        array2:addObject(CCSpawn:create(array1))
        self._ccbOwner.tf_leave_tips:runAction(CCSequence:create(array2))
    end
end

function QUIDialogBlackRockBattle:playBuffAnimationHandler(e)
    for i=1,3 do
        self._lines[i]:checkLineState()
    end
end

--海神岛退出
function QUIDialogBlackRockBattle:exitFromBattleHandler(e)
    self._fightEnd = true
    if self._startNewBattle == true then --开始新的一场战斗了
        self._startNewBattle = false
        for _,line in ipairs(self._lines) do
            line:removeFromParent()
        end
        self._lines = {}
        self:getTeamInfoAtEndAwards()
        return
    end
    local teamInfo = remote.blackrock:getTeamInfo()
    if teamInfo == nil then
        app.tip:floatTip("很抱歉，您被队长踢出队伍，请重新寻找队伍~")
        app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBlackRock"})
        return
    end
        
    if self:fightEndAwards() == false then
        for i=1,3 do
            local result = self._lines[i]:checkLineState()
            -- self._lines[i]:refreshLineMonsterInfo()
            self:refreshMaxCombatTeamID()
            if result == false then
                self._lines[i]:refreshInfo()
                local progress = remote.blackrock:getProgressByPos(i)
                if progress.isWin == true then
                    self:showStarByIndex(i, true)
                    self._lines[i]:showLineWin(false)
                end
            end
        end
    end
end

function QUIDialogBlackRockBattle:setChatInfo()
    if self._chat == nil then
        self._chat = QUIWidgetChat.new({state = QUIWidgetChat.STATE_TEAM})
        self._ccbOwner.node_chat:addChild(self._chat)
        self._chat:setChatAreaVisible(true)
        self._chat:setChatInBlackRock(true)
    end
end

--xurui: 收到新的组队聊天信息
function QUIDialogBlackRockBattle:_onMessageReceived(data)
    if self._popClose == true then return end
    if data.channelId and data.channelId == app:getServerChatData():teamChannelId() and data.misc.type ~= "admin" then
        for i = 1, #self._lines do
            if self._lines[i]:getUserId() == data.misc.uid and data.misc.uid ~= remote.user.userId then
                self._lines[i]:showChatMessage(data.message)
            end
        end
    end
end

function QUIDialogBlackRockBattle:_requestQuit(callback)
    local teamInfo = remote.blackrock:getTeamInfo()
    local isEnd = true
    local isGiveUp = false
    local pos = 0
    if teamInfo ~= nil then
        for index,progress in ipairs(teamInfo.teamProgress.allProgress) do
            if progress.memberId == remote.user.userId then
                isGiveUp = progress.isGiveUp
                pos = progress.memberPos
                for _,step in ipairs(progress.stepInfo) do
                    if step.isComplete == false then
                        isEnd = false
                    end
                end
                break
            end
        end
    end
    local tbl = {}
    local requestCallBack = callback
    if isGiveUp == true then
        requestCallBack()
        return
    end
    if isEnd == true then
        table.insert(tbl, {oType = "font", content = "魂师大人，您已",size = 22,color = COLORS.j})
        table.insert(tbl, {oType = "font", content = "通关",size = 22,color = COLORS.m})
        table.insert(tbl, {oType = "font", content = "现在离开奖励会在您",size = 22,color = COLORS.j})
        table.insert(tbl, {oType = "font", content = "下次进入组队战时发放~",size = 22,color = COLORS.m})
    else
        table.insert(tbl, {oType = "font", content = "魂师大人，现在离开将视为您放弃作战，队伍将",size = 20,color = COLORS.k})
    table.insert(tbl, {oType = "font", content = "无法获得"..pos.."号位所对应的星级奖励",size = 20,color = COLORS.m})
        requestCallBack = function ()
            callback()
            remote.blackrock:blackRockMemberFightGiveUpRequest()
        end
    end
    app:alert({content = tbl, title = "系统提示", colorful = true, callback = function (state)
        if state == ALERT_TYPE.CONFIRM then
            requestCallBack()
        end
    end})
end

function QUIDialogBlackRockBattle:onTriggerBackHandler(tag)
    if self._topTouchLayer ~= nil then return end
    self:_requestQuit(function ()
        app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
    end)
end

function QUIDialogBlackRockBattle:onTriggerHomeHandler(tag)
    if self._topTouchLayer ~= nil then return end
    self:_requestQuit(function ()
        app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
    end)
end

function QUIDialogBlackRockBattle:_onTriggerHelp(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_help) == false then return end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBlackRockRule", options = {dialogType = "customsIntroduction"}})
end
return QUIDialogBlackRockBattle