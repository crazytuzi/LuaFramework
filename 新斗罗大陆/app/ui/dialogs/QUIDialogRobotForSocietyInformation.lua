
local QUIDialog = import("..Dialogs.QUIDialog")
local QUIDialogRobotForSocietyInformation = class("QUIDialogRobotForSocietyInformation", QUIDialog)

local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetRobotAwardForSociety = import("..widgets.QUIWidgetRobotAwardForSociety")
local QNavigationController = import("...controllers.QNavigationController")
local QSocietyDungeonArrangement = import("...arrangement.QSocietyDungeonArrangement")

function QUIDialogRobotForSocietyInformation:ctor(options)
    local ccbFile = "ccb/Dialog_society_fuben_zidong2.ccbi";
    local callBacks = 
    {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerStop", callback = handler(self, self._onTriggerStop)},
    }
    QUIDialogRobotForSocietyInformation.super.ctor(self,ccbFile,callBacks,options)
    self.isAnimation = true
    self._ccbOwner.frame_tf_title:setString("自动扫荡")

    self._size = self._ccbOwner.layer_content:getContentSize()
    self._content = CCNode:create()
    local layerColor = CCLayerColor:create(ccc4(0,0,0,150),self._size.width,self._size.height)
    local ccclippingNode = CCClippingNode:create()
    layerColor:setPositionY(-self._size.height)
    ccclippingNode:setStencil(layerColor)
    ccclippingNode:addChild(self._content)
    self._ccbOwner.node_contain:addChild(ccclippingNode)

    self._touchLayer = QUIGestureRecognizer.new()
    self._touchLayer:attachToNode(self._ccbOwner.node_contain, self._size.width, self._size.height, 0, layerColor:getPositionY(), handler(self, self._onEvent))
    
    self._ccbOwner.touch_button:setVisible(false)

    self._titleStringFormat = options.titleStringFormat or "第%s次"

    self._wave = options.wave 
    self._chapter = options.chapter 
    self._robotCount = options.count
    self._activityBuffList = options.activityBuffList

    self._fightCounts = 0
    self._isStopAnimation = false

    self:_init()
end

function QUIDialogRobotForSocietyInformation:_init()
    self._index = 1 -- 攻击第几个boss
    self._count = 0 -- 攻击了几次
    self._moveIndex = 1
    self._numY = 0
    self._offsetMoveH = 60
    self._moveTime = 0.15
    self._totalHeight = 0
    self._panelWidth = 640
    self._panelHeight = 0

    self._isShowEnd = false
    self._isStop = false
    self._isSuspend = false

    self._startConsortiaMoney = remote.user.consortiaMoney or 0

    self._awardPanels = {}
    self._awardItems = {} -- 保存所有物品奖励，在结束之后，增加itembox的tips功能

    -- self._ccbOwner.tf_btnStop:setString("停止扫荡")
    -- self._ccbOwner.tf_tips:setString("")
    self._awardSpec = {}
    self._ccbOwner.node_btn_stop:setVisible(false)
end

function QUIDialogRobotForSocietyInformation:update()
    local userConsortia = remote.user:getPropForKey("userConsortia")
    -- 剩余可挑战BOSS次数
    self._fightCounts = userConsortia.consortia_boss_fight_count
    -- self._ccbOwner.tf_tips:setString(string.format("消耗攻击次数：%s／%s", self._count, (self._count + self._fightCounts)))
    self._ccbOwner.tf_tips:setString(string.format("消耗攻击次数：%s／%s", self._count, self._robotCount))

    -- if self._index > #self._waveList then
    if self._index > 1 or self._count >= self._robotCount then
        return false
    end


    -- self._wave = self._waveList[self._index]

    local isFinalBoss = remote.union:checkIsFinalWave(self._chapter, self._wave)
    if isFinalBoss then
        self._bossCurHp = 0
    else
        local bossList = remote.union:getConsortiaBossList(self._chapter)
        for _, bossInfo in pairs(bossList) do
            if bossInfo.chapter == self._chapter and bossInfo.wave == self._wave then
                self._bossCurHp = bossInfo.bossHp or 0
            end 
        end
    end

    local scoietyWaveConfig = QStaticDatabase.sharedDatabase():getScoietyWave(self._wave, self._chapter)
    self._bossId = scoietyWaveConfig.boss
    self._bossLevel = scoietyWaveConfig.levels
    self._little_monster = scoietyWaveConfig.little_monster

    return true
end

function QUIDialogRobotForSocietyInformation:work()
    -- 是否手动停止
    if self._isStop then
        if not self._isStoping then
            self._isStoping = true
            -- app.tip:floatTip("扫荡结束，手动终止")
            local userConsortia = remote.user:getPropForKey("userConsortia")
            self._fightCounts = userConsortia.consortia_boss_fight_count
            self:_autoMoveWithFinishedAnimation(70)
            -- self._ccbOwner.tf_tips:setString(string.format("消耗攻击次数：%s／%s", self._count, (self._count + self._fightCounts)))
            self._ccbOwner.tf_tips:setString(string.format("消耗攻击次数：%s／%s", self._count, self._robotCount))
        end
        return
    end

    -- 检查扫荡剩余关卡情况
    if not self:update() then
        -- 处理结束流程，扫荡结束
        -- app.tip:floatTip("扫荡结束，约定扫荡次数用完")
        self:_autoMoveWithFinishedAnimation(70)
        return
    end

    -- 检查攻击次数情况
    if self._fightCounts == 0 then
        -- app.tip:floatTip("扫荡结束，没有攻击次数了")
        self:_autoMoveWithFinishedAnimation(70)
        return
    end

    local isFinalBoss = remote.union:checkIsFinalWave(self._chapter, self._wave)
    -- 准备快速攻击宗门boss
    if self._bossCurHp > 0 or isFinalBoss then
        remote.union:setFightWave(self._wave)
        local societyDungeonArrangement = QSocietyDungeonArrangement.new({ robotCount = self._robotCount, chapter = self._chapter, wave = self._wave, bossId = self._bossId, bossHp = self._bossCurHp, bossLevel = self._bossLevel, little_monster = self._little_monster, activityBuffList = self._activityBuffList } )
        local oldConsortiaMoney = remote.user.consortiaMoney or 0
        societyDungeonArrangement:startQuickBattle(function(data)
                if data.gfEndResponse and data.gfEndResponse.consortiaBossQuickFightResponse and data.gfEndResponse.consortiaBossQuickFightResponse.fightInfoList then
                    local fightInfoList = data.gfEndResponse.consortiaBossQuickFightResponse.fightInfoList
                    --更新每日宗门副本活跃任务
                    remote.union.unionActive:updateActiveTaskProgress(20002, #fightInfoList)
                    if data.items then remote.items:setItems(data.items) end

                    if data.extraExpItem then 
                        self._awardSpec = data.extraExpItem or {} 
                    end
                        
                    
                    for _, fightInfo in ipairs(fightInfoList) do
                        local totalDamage = fightInfo.hurt or 0
                        local award = {}
                        -- local totalAward = remote.user.consortiaMoney - oldConsortiaMoney
                        local config = QStaticDatabase.sharedDatabase():getScoietyWave(self._wave, self._chapter)
                        local activityYield = remote.activity:getActivityMultipleYield(702)
                        local baseMultiple = 1
                        if activityYield and activityYield > 1 then
                            baseMultiple = activityYield
                        end
                        local baseAward = config.battle_reward * baseMultiple
                        local killedAward = fightInfo.consortiaBossKillAward and fightInfo.consortiaBossKillAward[1] and fightInfo.consortiaBossKillAward[1].count or 0
                        local hurtAward = fightInfo.consortiaBossHurtAward and fightInfo.consortiaBossHurtAward[1] and (fightInfo.consortiaBossHurtAward[1].count - baseAward) or 0
                        local totalAward = baseAward + hurtAward + killedAward
                        -- local isWin = self:_isWin()
                        -- if isWin then
                        --     local tbl = QStaticDatabase.sharedDatabase():getluckyDrawById(config.reward_personal)
                        --     killedAward = tbl[1].count
                        -- end

                        if totalAward > 0 then
                            table.insert(award, 1, {type = ITEM_TYPE.CONSORTIA_MONEY, count = totalAward})
                            -- table.insert(award, 2, {type = ITEM_TYPE.CONSORTIA_MONEY, count = totalAward - baseAward - killedAward, activityYield = activityYield})
                            table.insert(award, 2, {type = ITEM_TYPE.CONSORTIA_MONEY, count = hurtAward, activityYield = activityYield})
                            table.insert(award, 3, {type = ITEM_TYPE.CONSORTIA_MONEY, count = baseAward, activityYield = activityYield} )
                            if killedAward > 0 then
                                table.insert(award, 4, {type = ITEM_TYPE.CONSORTIA_MONEY, count = killedAward})
                            end
                        end

                        self:setAwards(award, totalDamage)
                    end
                end
            end, function(data)
                -- if data.api == "CONSORTIA_FIGHT_START" then
                if data.api == "GLOBAL_FIGHT_START" then
                    if data.error == "CONSORTIA_BOSS_ALREADY_DEAD" then
                        self:_autoMoveWithFinishedAnimation(70)
                    end
                else
                    local totalDamage = 0
                    local award = {}
                    self:setAwards(award, totalDamage)
                end
            end)
    else
        self._index = self._index + 1
        self:work()
    end
end

-- function QUIDialogRobotForSocietyInformation:_isWin()
--     local bossList = remote.union:getConsortiaBossList(self._chapter)
--     for _, bossInfo in pairs(bossList) do
--         if bossInfo.chapter == self._chapter and bossInfo.wave == self._wave and bossInfo.bossHp == 0 then
--             self._index = self._index + 1
--             return true
--         end
--     end
--     return false
-- end

function QUIDialogRobotForSocietyInformation:setAwards(award, totalDamage)
    local panel = QUIWidgetRobotAwardForSociety.new()

    local info = {}
    info.award = award
    info.bossId = self._bossId
    info.totalDamage = totalDamage

    self._awardPanels[#self._awardPanels + 1] = panel
    panel:setPositionY(self._numY)
    self._count = self._count + 1
    panel:setTitle(string.format(self._titleStringFormat, self._count))
    panel:setInfo(info)
    panel:setVisible(false)
    self._content:addChild(panel)

    --将所有奖励物品保存起来
    for _, value in pairs(panel._itemsBox) do
        table.insert(self._awardItems, value)
    end

    self._numY = self._numY - panel:getHeight()
    self._panelWidth = panel:getWidth()
    self._panelHeight = panel:getHeight()

    self._totalHeight = math.abs(self._numY)

    self:autoMove()
end

function QUIDialogRobotForSocietyInformation:autoMove()
    if #self._awardPanels == 1 then
        self._content:setPositionY(0)
        self._touchLayer:disable()
        self._ccbOwner.touch_button:setVisible(true)
        self._awardPanels[self._moveIndex]:setVisible(true)
        self._awardPanels[self._moveIndex]:startAnimation(function()
            self._moveIndex = self._moveIndex + 1
            self:autoMoveOver()
        end)
    else
        if self._isStopAnimation then
            local num = self._moveIndex
            for i = self._moveIndex, #self._awardPanels, 1 do
                self._awardPanels[i]:setVisible(true)
                if #self._awardPanels[i]._itemsBox == 0 then
                else
                    for j = 1, #self._awardPanels[i]._itemsBox, 1 do
                        self._awardPanels[i]._itemsBox[j]:setVisible(true)
                    end
                end
                self._moveIndex = self._moveIndex + 1
            end
            self._content:runAction(CCMoveBy:create(0, ccp(0, (#self._awardPanels - num) * self._panelHeight + 170)))
            self:_autoMoveWithFinishedAnimation(70)
            self._count = #self._awardPanels
            self._ccbOwner.tf_tips:setString(string.format("消耗攻击次数：%s／%s", self._count, self._robotCount))
        elseif self._moveIndex <= #self._awardPanels then
            self._touchLayer:disable()
            self._awardPanels[self._moveIndex]:setVisible(true)
            self._awardPanels[self._moveIndex]:startAnimation(function()
                local rate = 1
                if self._moveIndex < 2 then
                    rate = 0
                end
                local actionArrayIn = CCArray:create()
                actionArrayIn:addObject(CCMoveBy:create(self._moveTime, ccp(0, rate * self._panelHeight)))
                actionArrayIn:addObject(CCCallFunc:create(function () 
                    self:_removeAction()
                    self:autoMove()
                end))
                local ccsequence = CCSequence:create(actionArrayIn)
                self.actionHandler = self._content:runAction(ccsequence)
                self._moveIndex = self._moveIndex + 1
            end)
        else
            self:autoMoveOver()
        end
    end
end

function QUIDialogRobotForSocietyInformation:autoMoveOver()
    -- self._count = self._count + 1
    self:work()
end

function QUIDialogRobotForSocietyInformation:_autoMoveWithFinishedAnimation(offset)
    local ccbProxy = CCBProxy:create()
    local ccbOwner = {}
    local node, owner = CCBuilderReaderLoad("ccb/effects/saodangwancheng.ccbi", ccbProxy, ccbOwner)

    if ccbOwner.tf_warning and remote.user.userConsortia then
        ccbOwner.tf_warning:setVisible(not remote.user.userConsortia.isValid)
    end

    self._content:addChild(node)
    node:setPosition(self._panelWidth * 0.5, -self._totalHeight - self._panelHeight/2)
    self._touchLayer:disable()
    local actionArrayIn = CCArray:create()
    -- actionArrayIn:addObject(CCMoveBy:create(self._moveTime, ccp(0, self._offsetMoveH + offset)))
    actionArrayIn:addObject(CCMoveBy:create(self._moveTime, ccp(0, self._offsetMoveH + 180)))
    actionArrayIn:addObject(CCCallFunc:create(function () 
        self:_removeAction()
        self:_autoMoveWithALLReward()
    end))
    local ccsequence = CCSequence:create(actionArrayIn)
    self.actionHandler = self._content:runAction(ccsequence)
    self._totalHeight = self._totalHeight + self._panelHeight/2
end

function QUIDialogRobotForSocietyInformation:_autoMoveWithALLReward()
    local totalAward = (remote.user.consortiaMoney or 0) - self._startConsortiaMoney
    local info = {}
    local award = {}
    table.insert(award, 1, {type = ITEM_TYPE.CONSORTIA_MONEY, count = totalAward})
    info.award = award
    local panel = QUIWidgetRobotAwardForSociety.new()
    panel:setPositionY(-self._totalHeight - self._panelHeight/2)
    panel:setTitleExtra()
    panel:setInfo(info)
    self._content:addChild(panel)
    panel:startAnimation(function()
        --当动画结束时给物品添加悬浮提示
        for _, value in pairs(panel._itemsBox) do
            table.insert(self._awardItems, value)
        end
        self:_autoMoveEnd()
    end)

    self._panelWidth = panel:getWidth()
    self._panelHeight = panel:getHeight()

    self._totalHeight = self._totalHeight + self._panelHeight + self._panelHeight/2
end

function QUIDialogRobotForSocietyInformation:_autoMoveEnd()
    self._touchLayer:enable()
    if self._awardSpec and not q.isEmpty(self._awardSpec) then
        local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG , uiClass = "QUIDialogAwardsAlert" ,
            options = {awards = self._awardSpec, callBack = self:safeHandler(function () 
                end)
            }}, {isPopCurrentDialog = false} )    
    end
    
    scheduler.performWithDelayGlobal(function ()
        scheduler.performWithDelayGlobal(function ()
            self._ccbOwner.touch_button:setVisible(true)
            self._isShowEnd = true
            self._ccbOwner.tf_btnStop:setString("关  闭")
            self._ccbOwner.node_btn_stop:setVisible(true)
        end, 0.2)
    end, 0)


    for _, value in pairs(self._awardItems) do
        value:setPromptIsOpen(true)
    end
end

-- 移除动作
function QUIDialogRobotForSocietyInformation:_removeAction()
    if self._actionHandler ~= nil then
        self._content:stopAction(self._actionHandler)
        self._actionHandler = nil
    end
end

function QUIDialogRobotForSocietyInformation:moveTo(time,x,y,callback)
    local actionArrayIn = CCArray:create()
    actionArrayIn:addObject(CCMoveBy:create(time, ccp(x,y)))
    actionArrayIn:addObject(CCCallFunc:create(function () 
        self:_removeAction()
        if callback ~= nil then
            callback()
        end
    end))
    local ccsequence = CCSequence:create(actionArrayIn)
    self.actionHandler = self._content:runAction(ccsequence)
end

function QUIDialogRobotForSocietyInformation:_backClickHandler()
    if self._isShowEnd == false then
        self._isStopAnimation = true
    else
        self:_onTriggerClose()
    end
end

function QUIDialogRobotForSocietyInformation:viewDidAppear()
    QUIDialogRobotForSocietyInformation.super.viewDidAppear(self)

    self._touchLayer:setAttachSlide(true)
    self._touchLayer:setSlideRate(0.3)
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self._onEvent))
    self._touchLayer:disable()
end

function QUIDialogRobotForSocietyInformation:viewWillDisappear()
    QUIDialogRobotForSocietyInformation.super.viewWillDisappear(self)

    self._touchLayer:removeAllEventListeners()
    self._touchLayer:disable()
    self._touchLayer:detach()
end

function QUIDialogRobotForSocietyInformation:_onTriggerStop(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_stop) == false then return end
    app.sound:playSound("common_close")
    if self._isShowEnd == true then
        self:_onTriggerClose()
    else
        self._isStop = true
        -- self._ccbOwner.tf_btnStop:setString("关  闭")
    end
end

function QUIDialogRobotForSocietyInformation:_onTriggerClose(e)
    if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
    if e then
        app.sound:playSound("common_close")
    end
    if self._isShowEnd == true then 
        self:playEffectOut()
    else
        app.tip:floatTip("正在扫荡无法直接关闭，请先停止扫荡～")
    end
end

function QUIDialogRobotForSocietyInformation:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
    remote.union:unionGetBossListRequest(function()
        remote.union:dispathExitRobotForSociety()
    end)
end

function QUIDialogRobotForSocietyInformation:viewAnimationInHandler()
    self:work()
end

function QUIDialogRobotForSocietyInformation:_onEvent(event)
    if event.name == "began" then
        self:_removeAction()
        self._lastSlidePositionY = event.y
        return true
    elseif event.name == "moved" then
        local deltaY = event.y - self._lastSlidePositionY
        local positionY = self._content:getPositionY()
        self._content:setPositionY(positionY + deltaY * .5)
        self._lastSlidePositionY = event.y
    elseif event.name == "ended" or event.name == "cancelled" then
    elseif event.name == QUIGestureRecognizer.EVENT_SLIDE_GESTURE then
        local offset = event.distance.y
        if self._content:getPositionY() + offset > self._totalHeight - self._size.height  then
            if self._totalHeight - self._size.height > 0 then
                offset = self._totalHeight - self._size.height - self._content:getPositionY()
            else
                offset = 0 - self._content:getPositionY()
            end
        elseif self._content:getPositionY() + offset < 0 then
            offset = 0 - self._content:getPositionY()
        end
        self:moveTo(0.3,0,offset)
    end
end

return QUIDialogRobotForSocietyInformation