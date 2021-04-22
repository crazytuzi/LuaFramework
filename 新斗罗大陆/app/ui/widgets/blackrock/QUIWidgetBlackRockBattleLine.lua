local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetBlackRockBattleLine = class("QUIWidgetBlackRockBattleLine", QUIWidget)
local QUIWidgetBlackRockBattlePlayer = import("...widgets.blackrock.QUIWidgetBlackRockBattlePlayer")
local QBlackRockArragement = import("....arrangement.QBlackRockArragement")
local QUIWidgetBlackRockBattleMonster = import("...widgets.blackrock.QUIWidgetBlackRockBattleMonster")
local QUIViewController = import("...QUIViewController")
local QStaticDatabase = import("....controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("...widgets.QUIWidgetAnimationPlayer")
local QChatDialog = import("....utils.QChatDialog")

QUIWidgetBlackRockBattleLine.DEFAULT_POS = {0,300,535,770}

QUIWidgetBlackRockBattleLine.EVENT_GET_STAR = "EVENT_GET_STAR"
QUIWidgetBlackRockBattleLine.EVENT_GET_BUFF = "EVENT_GET_BUFF"
QUIWidgetBlackRockBattleLine.EVENT_FAST_FIGHT = "EVENT_FAST_FIGHT"

function QUIWidgetBlackRockBattleLine:ctor(options)
	QUIWidgetBlackRockBattleLine.super.ctor(self, nil, nil, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._index = options.index
	self._monsters = {}
	self._parent = options.parent
    self._isInMove = false
    self._endX = 850
end

function QUIWidgetBlackRockBattleLine:onExit()
    QUIWidgetBlackRockBattleLine.super.onExit(self)
    if self._handler ~= nil then
        scheduler.unscheduleGlobal(self._handler)
        self._handler = nil
    end
    if self._delayHandler then
        scheduler.unscheduleGlobal(self._delayHandler)
        self._delayHandler = nil
    end
end

function QUIWidgetBlackRockBattleLine:refreshInfo(isFrist)
	self._progress = remote.blackrock:getProgressByPos(self._index)
    self._buff = remote.blackrock:getBuff()
	if self._progress ~= nil then
		if self._player == nil then
			self._player = QUIWidgetBlackRockBattlePlayer.new()
            self._player:setPositionX(QUIWidgetBlackRockBattleLine.DEFAULT_POS[1])
	        self:addChild(self._player, 998)
		end
        self._player:setHp(true)
        if isFrist == true then
            self:playThunderEffect(self._player)
            self._player:setPositionX(QUIWidgetBlackRockBattleLine.DEFAULT_POS[1])
            app.sound:playSound("black_rock_flashing_lightning")
        end

		self._playerInfo = remote.blackrock:getMemberById(self._progress.memberId)
        self._player:setPlayerInfo(self._playerInfo, self._progress)
        self._player:setBuff(false)

        self:showSelfEffect()

        self._fightMonster = nil --当前战斗的怪物
        self._deadMonster = nil --最后一个死掉的怪物包括buff
        local nextTarget = nil
        for index,value in ipairs(self._progress.stepInfo) do
            local monsterAvatar = self._monsters[index]
            if monsterAvatar == nil then
                monsterAvatar = QUIWidgetBlackRockBattleMonster.new()
                monsterAvatar:addEventListener(QUIWidgetBlackRockBattleMonster.EVENT_CLICK, handler(self, self._clickHandler))
                monsterAvatar:addEventListener(QUIWidgetBlackRockBattleMonster.FAST_FIGHTER, handler(self, self._fastFightHandler))
                table.insert(self._monsters, monsterAvatar)
                self:addChild(monsterAvatar)
            end
            if isFrist == true then
                self:playThunderEffect(monsterAvatar)
            end
        	monsterAvatar:setPositionX(QUIWidgetBlackRockBattleLine.DEFAULT_POS[index+1])
        	monsterAvatar:setDungeonId(value,self:getIsSelf())
        	monsterAvatar:setGridPos(ccp(self._index, index))
            if value.isComplete == true then
            	-- monsterAvatar:setVisible(false)
                monsterAvatar:showDead(true)
            	self._deadMonster = monsterAvatar
            else
            	-- monsterAvatar:setVisible(true)
                monsterAvatar:showDead(false)
            	if value.isNpc == true then
            		if self._fightMonster == nil and self._progress.isEnd == false then
            			self._fightMonster = monsterAvatar
            		end
            	end
                if nextTarget == nil then
                    nextTarget = monsterAvatar
                end
            end
        end

        local actionList = {}
        if isFrist == true then
            table.insert(actionList, {fun = handler(self, self.actionWait), param = {(4-self._index) * 0.3 + 1}})
        end
        if self._deadMonster ~= nil then --人物移动到死亡的怪物这个位置
            table.insert(actionList, {fun = handler(self, self.actionMoveToTarget), param = {self._deadMonster, false}})
        end
        if nextTarget ~= nil and nextTarget ~= nil then
            if isFrist then
                if self:getIsSelf() == false then
                    table.insert(actionList, {fun = handler(self, self.actionPlayAnimation), param = {ANIMATION_EFFECT.WALK, false}})
                    table.insert(actionList, {fun = handler(self, self.actionMoveToFight), param = {nextTarget, true}})
                    table.insert(actionList, {fun = handler(self, self.actionStopAnimation)})
                end
            else
                table.insert(actionList, {fun = handler(self, self.actionMoveToFight), param = {nextTarget, false}})
            end
            if self._progress.isFightStart == true or (self._playerInfo.isNpc == true and nextTarget:getIsNpc()) then
                table.insert(actionList, {fun = handler(self, self.actionPlayAnimation), param = {ANIMATION_EFFECT.COMMON_FIGHT, false}})
                table.insert(actionList, {fun = handler(self, self.actionMonsterPlayAnimation), param = {nextTarget, ANIMATION_EFFECT.COMMON_MONSTER_FIGHT, false}})
            end
        end
        if #actionList > 0 then
            self:runAnimationAction(actionList)
        end
        if self._fightMonster ~= nil then
            if self:getIsSelf() == true then --当前战斗的怪物
            	self._fightMonster:setFight(true)
            end
            self._fightMonster:setHpVisible(true)
        end
	end
end

function QUIWidgetBlackRockBattleLine:showSelfEffect()
    if self:getIsSelf() == false then return end

    if self._selfEffect ~= nil then
        self._selfEffect:removeFromParent()
        self._selfEffect = nil
    end
    if (self._progress.stepInfo and self._progress.stepInfo[1].isComplete == true) or self._progress.isGiveUp == true then
        return
    end

    self._selfEffect = QUIWidgetAnimationPlayer.new()
    self:addChild(self._selfEffect, -1)
    self._selfEffect:playAnimation("ccb/effects/zlt_fx_2.ccbi", function()end, function()end, false)
end

--------------------------------------------------------------------------------- Action -------------------------------------------------------------------
--移动到指定位置
function QUIWidgetBlackRockBattleLine:actionMoveTo(posX, isAnimation, callback)
    if isAnimation == true then
        self._isInMove = true
        local speed = 250
        local startX = self._player:getPositionX()
        local time = (posX - startX) / speed
        if time > 4 then
            time = 4
        end
        local actionArrayIn = CCArray:create()
        actionArrayIn:addObject(CCMoveTo:create(time, ccp(posX, self._player:getPositionY())))
        actionArrayIn:addObject(CCCallFunc:create(function ()
            self._isInMove = false
            if callback ~= nil then
                callback()
            end
        end))
        local ccsequence = CCSequence:create(actionArrayIn)
        self._player:runAction(ccsequence)
    else
        self._player:setPosition(ccp(posX, self._player:getPositionY()))
        if callback ~= nil then
            callback()
        end
    end
end

--action 等待
function QUIWidgetBlackRockBattleLine:actionWait(delay, callback)
    self._delayHandler = scheduler.performWithDelayGlobal(function ()
        self._delayHandler = nil
        callback()
    end, delay)
end

--action 移动到对象的位置
function QUIWidgetBlackRockBattleLine:actionMoveToTarget(target, isAnimation, callback)
    print(self:getIndex(), "actionMoveToTarget")
    local gridPos = target:getGridPos()
    self._player:setGridPos(gridPos)
    local endX = target:getPositionX()
    --最后一个直接移动到星星那里
    if gridPos.y >= #self._progress.stepInfo then
        endX = self._endX
    end
    self:actionMoveTo(endX, isAnimation, callback)
end

--人物去目标面前战斗
function QUIWidgetBlackRockBattleLine:actionFightTarget(target, isAnimation, callback)
    print(self:getIndex(), "actionFightTarget")
    local gridPos = target:getGridPos()
    local endX = target:getPositionX()
    self:actionMoveTo(endX, isAnimation, function ()
        self._player:avatarPlayAnimation(ANIMATION_EFFECT.COMMON_FIGHT)
        target:avatarPlayAnimation(ANIMATION_EFFECT.COMMON_FIGHT)
        callback()
    end)
end

--人物播放动作
function QUIWidgetBlackRockBattleLine:actionPlayAnimation(action, isAnimation, callback)
    print(self:getIndex(), "actionPlayAnimation")
    if isAnimation then
        self._player:avatarPlayAnimation(action, callback)
    else
        self._player:avatarPlayAnimation(action)
        callback()
    end
end

--人物停止动作
function QUIWidgetBlackRockBattleLine:actionStopAnimation(callback)
    print(self:getIndex(), "actionStopAnimation")
    self._player:getAvatar():stopDisplay()
    callback()
end

--怪物播放死亡动作
function QUIWidgetBlackRockBattleLine:actionMonsterDead(target, isAnimation, callback)
    print(self:getIndex(), "actionMonsterDead")
    print(self:getIndex(), isAnimation,callback)
    if isAnimation then
        target:avatarPlayAnimation(ANIMATION_EFFECT.DEAD, function ()
            target:showDead(true)
            callback()
            self:refreshLineMonsterInfo()
        end)
        target:setHp(0)
    else
        target:showDead(true)
        callback()
    end
end

function QUIWidgetBlackRockBattleLine:actionMonsterPlayAnimation(target, action, isAnimation, callback)
    print(self:getIndex(), "actionMonsterPlayAnimation")
    if isAnimation then
        target:avatarPlayAnimation(action, callback)
    else
        target:avatarPlayAnimation(action)
        callback()
    end
end

--检查当前关卡怪物
function QUIWidgetBlackRockBattleLine:actionCheckMonster(callback)
    print(self:getIndex(), "actionCheckMonster")
    for index,value in ipairs(self._progress.stepInfo) do
        if value.isComplete == false and value.isNpc == true then
            self._fightMonster = self._monsters[index]
            if self:getIsSelf() == true then
                self._fightMonster:setFight(true)
            end
            self._fightMonster:setHpVisible(true)
            break
        end
    end
    callback()
end

--播放星星动画
function QUIWidgetBlackRockBattleLine:actionPlayStarAnimation(callback)
    print(self:getIndex(), "actionPlayStarAnimation", callback ~= nil)
    self:dispatchEvent({name = QUIWidgetBlackRockBattleLine.EVENT_GET_STAR, callback = callback})
    self:showLineWin(true)
end

--吃BUFF
function QUIWidgetBlackRockBattleLine:actionEatBuff(target, stepInfo, callback)
    target:setVisible(false)
    local fightStep = stepInfo
    fightStep.isComplete = true
    fightStep.battleVerify = fightStep.battleVerify --q.battleVerifyHandler(fightStep.battleVerify)
    local herosHpMp = self._progress.herosHpMp
    remote.blackrock:blackRockMemberStepFightEndRequest(fightStep, herosHpMp, nil, nil, remote.blackrock:getProgressId(),fightStep.battleVerify,
        function(data)
            remote.blackrock:blackRockEatBuffRequest(fightStep.stepId, herosHpMp, remote.blackrock:getProgressId(), function ()
                callback()
                self:dispatchEvent({name = QUIWidgetBlackRockBattleLine.EVENT_GET_BUFF})
            end,function ()
                assert(false,"eat buff error: ".. fightStep.stepId.." "..remote.blackrock:getProgressId())
            end)
        end,function(data)
            assert(false,"buff fight end error: ".. fightStep.stepId.." "..remote.blackrock:getProgressId())
        end)
end

--移动到下一个怪物面前
function QUIWidgetBlackRockBattleLine:actionMoveToFight(target, isAnimation, callback)
    print(self:getIndex(), "actionMoveToFight")
    local gridPos = target:getGridPos()
    local endX = target:getPositionX() - 150
    self._player:setNextPos(gridPos)
    self:actionMoveTo(endX, isAnimation, callback)
end
--刷新怪物
function QUIWidgetBlackRockBattleLine:refreshLineMonsterInfo()
    if not self:getIsSelf() then return end
    self._progress = remote.blackrock:getProgressByPos(self._index)
    for index,value in ipairs(self._progress.stepInfo) do
        local monsterAvatar = self._monsters[index]
        if monsterAvatar then
            if value.isComplete == true then
                 monsterAvatar:showDead(true)
            else
                monsterAvatar:showDead(false)
            end
        end
    end
end
--检查每条线路的移动状态
function QUIWidgetBlackRockBattleLine:checkLineState(callback)
    if self._isAction == true then
        self._player:stopAllActions()
        self._isAction = false
    end

	self._progress = remote.blackrock:getProgressByPos(self._index)

    if self._player == nil then return false end

    --装上buff
    local buffId = remote.blackrock:getBuff()
    if self._progress.isEnd ~= true and buffId ~= nil and self:getIsSelf() == true and remote.blackrock:checkBuffIsEat(buffId) == false then
        local herosHpMp = self._progress.herosHpMp
        remote.blackrock:blackRockEatBuffRequest(buffId, herosHpMp, remote.blackrock:getProgressId())
    end
    self._player:setBuff(self._buff ~= buffId)
    self._buff = buffId
    
    --计算当前打到哪里
    local passStepIndex = nil
    local nextStepIndex = 1
    for index,stepInfo in ipairs(self._progress.stepInfo) do
        if stepInfo.isComplete == true then
            passStepIndex = index
        end
        if stepInfo.isComplete == false then
            nextStepIndex = index
            break
        end
    end

    --显示已经死去的怪物
    if passStepIndex ~= nil then
        for index,monsterWidget in ipairs(self._monsters) do
            if index < passStepIndex then
                monsterWidget:showDead(true)
            end
        end
    end

    --如果放弃直接显示放弃动画
    if self._progress.isGiveUp == true then
        self:showLineLost(true)
        if callback then
            callback()
        end
        return true
    end

    local actionList = {}
    local gridPos = self._player:getGridPos()
    local nextPos = self._player:getNextPos()

    if passStepIndex ~= nil and (gridPos == nil or gridPos.y < passStepIndex) then
        self._monsters[passStepIndex]:setFight(false)
        --显示死亡的怪物
        if self._progress.stepInfo[passStepIndex].isNpc == true then
            table.insert(actionList, {fun = handler(self, self.actionMonsterDead), param = {self._monsters[passStepIndex], true}})
        else
            table.insert(actionList, {fun = handler(self, self.actionMonsterDead), param = {self._monsters[passStepIndex], false}})
        end
        --走到死亡的怪物节点
        table.insert(actionList, {fun = handler(self, self.actionPlayAnimation), param = {ANIMATION_EFFECT.WALK, false}})
        table.insert(actionList, {fun = handler(self, self.actionMoveToTarget), param = {self._monsters[passStepIndex], true}})
        --如果已经在打下一个怪物了
        if --[[(self._progress.isFightStart == true or self:getIsSelf() == false) and]] passStepIndex < #self._progress.stepInfo and self._monsters[nextStepIndex] ~= nil then
            table.insert(actionList, {fun = handler(self, self.actionMoveToFight), param = {self._monsters[nextStepIndex], true}})
            if self._progress.isFightStart == true or (self._playerInfo.isNpc == true and self._monsters[nextStepIndex]:getIsNpc() == true) then
                table.insert(actionList, {fun = handler(self, self.actionPlayAnimation), param = {ANIMATION_EFFECT.COMMON_FIGHT, false}})
                table.insert(actionList, {fun = handler(self, self.actionMonsterPlayAnimation), param = {self._monsters[nextStepIndex], ANIMATION_EFFECT.COMMON_MONSTER_FIGHT, false}})
            else
                table.insert(actionList, {fun = handler(self, self.actionStopAnimation)})
            end
        else
            table.insert(actionList, {fun = handler(self, self.actionStopAnimation)})
        end
        table.insert(actionList, {fun = handler(self, self.actionCheckMonster)})
        if passStepIndex >= #self._progress.stepInfo then
            table.insert(actionList, {fun = handler(self, self.actionPlayStarAnimation)})
        end
    elseif passStepIndex == nil or passStepIndex < #self._progress.stepInfo then
            --直接走到下一个怪物面前
            if nextPos ~= nil and nextPos.y < nextStepIndex --[[and self:getIsSelf() == false]] and self._monsters[nextStepIndex] ~= nil then
                table.insert(actionList, {fun = handler(self, self.actionPlayAnimation), param = {ANIMATION_EFFECT.WALK, false}})
                table.insert(actionList, {fun = handler(self, self.actionMoveToFight), param = {self._monsters[nextStepIndex], true}})
                table.insert(actionList, {fun = handler(self, self.actionStopAnimation)})
            end
            if self._progress.isFightStart == true or (self._playerInfo.isNpc == true and self._monsters[nextStepIndex]:getIsNpc() == true) then
                table.insert(actionList, {fun = handler(self, self.actionPlayAnimation), param = {ANIMATION_EFFECT.COMMON_FIGHT, false}})
                table.insert(actionList, {fun = handler(self, self.actionMonsterPlayAnimation), param = {self._monsters[nextStepIndex], ANIMATION_EFFECT.COMMON_MONSTER_FIGHT, false}})
            end
    end
    if #actionList > 0 then
        table.insert(actionList, {fun = function (_callBack)
                if callback then
                    callback()
                end
                _callBack()
            end})
        self:runAnimationAction(actionList)
        return true
    end
    return false
end

--执行动作序列
function QUIWidgetBlackRockBattleLine:runAnimationAction(actions)
    -- if self._runAction == true then return end
    self._actions = actions
    if self._isAction ~= true then
        self:animationActionLoop()
    end
end

function QUIWidgetBlackRockBattleLine:animationActionLoop()
    local action = table.remove(self._actions, 1)
    -- if action == nil then return end
    self._isAction = true
    local callback = function ()
        print(self:getIndex(), "animationActionLoop")
        if #self._actions > 0 then
            self:animationActionLoop(self._actions)
        else
            self._isAction = false
        end
    end
    -- if #self._actions > 0 then
    --     callback = function ()
    --         self:animationActionLoop(self._actions)
    --     end
    -- end
    local paramCount = 0
    if action.param ~= nil then
        paramCount = #action.param
    end 
    if paramCount == 0 then
        action.fun(callback)
    elseif paramCount == 1 then
        action.fun(action.param[1], callback)
    elseif paramCount == 2 then
        action.fun(action.param[1], action.param[2], callback)
    elseif paramCount == 3 then
        action.fun(action.param[1], action.param[2], action.param[3], callback)
    end
end

--播放一道闪电劈下的效果
function QUIWidgetBlackRockBattleLine:playThunderEffect(node)
    local thunderPlayer = QUIWidgetAnimationPlayer.new()
    thunderPlayer:playAnimation("ccb/effects/Widget_Black_mounatin_shandian.ccbi")
    thunderPlayer:setPositionY(140)
    node:addChild(thunderPlayer)
end

--显示战斗失败
function QUIWidgetBlackRockBattleLine:showLineLost(isAnimation)
    if self._isGiveUpAnimation ~= true then
        self._isGiveUpAnimation = true 
    else
        isAnimation = false
    end
    
    for _,monsterAvatar in ipairs(self._monsters) do
        monsterAvatar:stopDisplay()
    end

    self._player:setHp(false)
    if self._passSign == nil then
        self._passSign = QUIWidgetAnimationPlayer.new()
        self:getView():addChild(self._passSign, 999)
        self._passSign:setPosition(ccp(self._player:getPositionX(), 120))
    end
    self._player:pauseAnimation()
    self._player:setGray()
    local index = self:getIndex()
    if isAnimation == true then
        self._passSign:playAnimation("ccb/effects/zd_shibai.ccbi", function (ccbOwner)
            for i=1,3 do
                ccbOwner["node_"..i]:setVisible(false)
                ccbOwner["animation_"..i]:setVisible(false)
            end
            ccbOwner["animation_"..index]:setVisible(true)
        end)
    else
        self._passSign:playAnimation("ccb/effects/zd_shibai.ccbi", function (ccbOwner)
            for i=1,3 do
                ccbOwner["node_"..i]:setVisible(false)
                ccbOwner["animation_"..i]:setVisible(false)
            end
            ccbOwner["node_"..index]:setVisible(true)
        end)
    end
end

--显示战斗胜利
function QUIWidgetBlackRockBattleLine:showLineWin(isAnimation)
    self._player:setHp(false)
    if self._handler ~= nil then
        scheduler.unscheduleGlobal(self._handler)
        self._handler = nil
    end
    self._handler = scheduler.performWithDelayGlobal(function ()
        self._player:avatarPlayAnimation(ANIMATION_EFFECT.VICTORY)
        self._handler = nil
        self:showLineWin(false)
    end, 15) 
    if self._passSign == nil then
        self._passSign = QUIWidgetAnimationPlayer.new()
        self:getView():addChild(self._passSign, 999)
        self._passSign:setPosition(ccp(self._endX, 120))
    end
    local index = self:getIndex()
    if isAnimation == true then
        self._player:avatarPlayAnimation(ANIMATION_EFFECT.VICTORY, function ()
            self._passSign:playAnimation("ccb/effects/zd_tongguang.ccbi", function (ccbOwner)
                for i=1,3 do
                    ccbOwner["node_"..i]:setVisible(false)
                    ccbOwner["animation_"..i]:setVisible(false)
                end
                ccbOwner["animation_"..index]:setVisible(true)
            end)
        end)
    else
        self._passSign:playAnimation("ccb/effects/zd_tongguang.ccbi", function (ccbOwner)
            for i=1,3 do
                ccbOwner["node_"..i]:setVisible(false)
                ccbOwner["animation_"..i]:setVisible(false)
            end
            ccbOwner["node_"..index]:setVisible(true)
        end)
    end
end

--获取index
function QUIWidgetBlackRockBattleLine:getIndex()
	return self._index 
end

--这条线是不是自己的
function QUIWidgetBlackRockBattleLine:getIsSelf()
	if self._playerInfo ~= nil then
		return self._playerInfo.userId == remote.user.userId
	end
	return false
end

--这条线是不是结束了
function QUIWidgetBlackRockBattleLine:getIsEnd()
    return self._progress.isEnd
end

function QUIWidgetBlackRockBattleLine:getUserId()
    if self._playerInfo ~= nil then
        return self._playerInfo.userId
    else
        return nil
    end
end

--xurui: 展示聊天信息
function QUIWidgetBlackRockBattleLine:showChatMessage(message)
    if message == nil or self._player == nil then return end

    if self._chat == nil then
        self._chat = QChatDialog.new()
        self._player:addChild(self._chat)
    end
    self._chat:setPosition(ccp(80, 60))
    self._chat:setString(message or "")

    local wordWidth = 214
    local offset = self._player:convertToWorldSpace(ccp(0, 0))
    if (offset.x + wordWidth) > display.width then
        self._chat:setScaleX(-1)
        self._chat:setPosition(ccp(-80, 60))
    end
end

function QUIWidgetBlackRockBattleLine:_fastFightHandler(e)
    local target = e.target
    local gridPos = target:getGridPos()
    if self:getIsSelf() == false then
        print("这是别人的关卡怪物")
        return 
    end --这是别人的关卡怪物
    if self._progress.isEnd == true then 
        print("这条路的结束了")
        return 
    end --这条路的结束了
    if self._isAction == true then 
        print("正在action执行中")
        return 
    end --正在action执行中
    local dungeonId = e.dungeonId

    local stepInfo = self._progress.stepInfo[gridPos.y]
    if stepInfo.isComplete == true then 
        print("这条路的这一关结束了")
        return 
    end --这条路的这一关结束了
    local perDead = true --前面一关的怪有没有死
    if gridPos.y > 1 then
        perDead = self._progress.stepInfo[gridPos.y-1].isComplete == true
    end
    if perDead == false then 
        print("前面一关的怪还没死")
        return 
    end --前面一关的怪还没死

    local lastSeclectDungeId = remote.blackrock:getLastFastFightSeclectId()
    if lastSeclectDungeId ~= nil and lastSeclectDungeId == dungeonId then
        print("点击的同一个boss")
        remote.blackrock:quickFightEnd() 
        return
    end
    remote.blackrock:setLastFastFightSeclectId(dungeonId)
    
    stepInfo.isComplete = true  --能扫荡就直接通关

    self:showSelfEffect()   

    self:dispatchEvent({name = QUIWidgetBlackRockBattleLine.EVENT_FAST_FIGHT,stepInfo=stepInfo,progressId=remote.blackrock:getProgressId()})
end

function QUIWidgetBlackRockBattleLine:_clickHandler(e)
    local target = e.target
    local gridPos = target:getGridPos()
    if self:getIsSelf() == false then return end --这是别人的关卡怪物
    if self._progress.isEnd == true then return end --这条路的结束了
    if self._isAction == true then return end --正在action执行中

    local stepInfo = self._progress.stepInfo[gridPos.y]
    if stepInfo.isComplete == true then return end --这条路的这一关结束了
    local perDead = true --前面一关的怪有没有死
    if gridPos.y > 1 then
        perDead = self._progress.stepInfo[gridPos.y-1].isComplete == true
    end
    if perDead == false then return end --前面一关的怪还没死

    app.sound:playSound("common_item")
    if stepInfo.isNpc == true then
        if self._player:getNextPos() == nil or self._player:getNextPos().y < gridPos.y then
            local actionList = {}
            table.insert(actionList, {fun = handler(self, self.actionPlayAnimation), param = {ANIMATION_EFFECT.WALK, false}})
            table.insert(actionList, {fun = handler(self, self.actionMoveToFight), param = {target, true}})
            table.insert(actionList, {fun = handler(self, self.actionStopAnimation)})
            table.insert(actionList, {fun = handler(self, self.actionWait), param = {0.1}})
            table.insert(actionList, {fun = function (_callback)
                self:fightStartHandler(e.dungeonId, stepInfo,e.soulSpiritId,e.battleVerify)
                _callback()
            end})
            self:runAnimationAction(actionList)
        else
            self:fightStartHandler(e.dungeonId, stepInfo,e.soulSpiritId,e.battleVerify)
        end
    else
        local actionList = {}
        table.insert(actionList, {fun = handler(self, self.actionPlayAnimation), param = {ANIMATION_EFFECT.WALK, false}})
        table.insert(actionList, {fun = handler(self, self.actionMoveToTarget), param = {target, true}})
        table.insert(actionList, {fun = handler(self, self.actionStopAnimation)})
        table.insert(actionList, {fun = handler(self, self.actionCheckMonster)})
        table.insert(actionList, {fun = handler(self, self.actionEatBuff), param = {target, stepInfo}})
        self:runAnimationAction(actionList)
    end
end

--战斗开始
function QUIWidgetBlackRockBattleLine:fightStartHandler(dungeonId, stepInfo,soulSpiritId,battleVerify)
    local herosInfos, count, force = remote.herosUtil:getMaxForceHeros()
    local strDungeonId = QStaticDatabase:sharedDatabase():convertDungeonID(dungeonId)
    local config = QStaticDatabase:sharedDatabase():getDungeonConfigByID(strDungeonId)
    local isRecommend = (not not config.thunder_force) and force >= tonumber(config.thunder_force or 0)

    local teamKey = remote.teamManager.BLACK_ROCK_FRIST_TEAM
    if self._progress.herosHpMp ~= nil then
        teamKey = remote.teamManager.BLACK_ROCK_SECOND_TEAM
    end
    local heros = clone(remote.teamManager:getActorIdsByKey(teamKey))
    local teamVO = remote.teamManager:getTeamByKey(teamKey)
    if self._progress.herosHpMp ~= nil then
        for _,heroInfo in ipairs(self._progress.herosHpMp) do
            if heroInfo ~= nil and heroInfo.currHp and heroInfo.currHp <= 0 then
                teamVO:delHeroByIndex(1, heroInfo.actorId)
            end
        end
        remote.teamManager:saveTeamToLocal(teamVO, teamKey)
    end
    local dungeonArrangement = QBlackRockArragement.new({dungeonId = dungeonId, battleVerify = battleVerify,soulSpiritId = soulSpiritId,isRecommend = isRecommend, force = force, progress = self._progress, stepInfo = stepInfo, teamKey = teamKey})
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement",
        options = {arrangement = dungeonArrangement, isQuickWay = true}})
end

return QUIWidgetBlackRockBattleLine