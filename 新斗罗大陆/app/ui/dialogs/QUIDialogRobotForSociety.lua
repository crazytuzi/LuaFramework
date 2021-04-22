
local QUIDialog = import("..Dialogs.QUIDialog")
local QUIDialogRobotForSociety = class("QUIDialogRobotForSociety", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QUIWidgetRobotSocietyDungeonBoss = import("..widgets.QUIWidgetRobotSocietyDungeonBoss")

QUIDialogRobotForSociety.STATE_MOVE = 1 --移动状态中
QUIDialogRobotForSociety.STATE_NONE = 2 --可以移动
QUIDialogRobotForSociety.STATE_ANIMATION = 3 --动画状态中

function QUIDialogRobotForSociety:ctor(options)
    local ccbFile = "ccb/Dialog_society_fuben_zidong.ccbi";
    local callBacks = 
    {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
    }
    QUIDialogRobotForSociety.super.ctor(self,ccbFile,callBacks,options)
    self.isAnimation = true
    self._chapter = options.chapter
    self._isStartRobot = false
    self._waveList = {} 
    self._bossList = {} -- 储存boss信息
    self._posiotionList = {} -- 储存原始的存放boss卡片的node的坐标和顺序

    local size = CCSize(818, 320)
    self.touchLayer = QUIGestureRecognizer.new()
    self.touchLayer:attachToNode(self._ccbOwner.node_contain, size.width, size.height, -414, -141, handler(self, self.onEvent))
    self.touchLayer:enable()
    self._moveState = QUIDialogRobotForSociety.STATE_NONE

    self:_init(true)
end

function QUIDialogRobotForSociety:_init(isSort)
    local bossList = remote.union:getConsortiaBossList(self._chapter)
    -- QPrintTable(bossList)
    if not bossList or #bossList == 0 then return end
    for _, value in pairs(bossList) do
        local boss = QUIWidgetRobotSocietyDungeonBoss.new(value)
        table.insert( self._waveList, value.wave )
        self._bossList[value.wave] = {}
        self._bossList[value.wave].size = boss:getSize()
        self._bossList[value.wave].bossHp = value.bossHp
        self._bossList[value.wave].totalHp = boss:getTotalHp()
        print(value.bossHp,"totalHp", self._bossList[value.wave].totalHp)
        local node = self._ccbOwner["node_"..value.wave]
        if node then
            self._posiotionList[value.wave] = ccp(node:getPositionX(), node:getPositionY())
        end
    end

    self:_showBoss(isSort)
end

function QUIDialogRobotForSociety:_mySort(isSort)
    local removedWaveList = {}
    while true do
        local isFind = false
        for index, wave in pairs(self._waveList) do
            if self._bossList[wave].bossHp == 0 then
                isFind = true
                table.insert(removedWaveList, wave)
                table.remove(self._waveList, index)
                break
            end
        end

        if not isFind then
            break
        end
    end
    if isSort then
        table.sort(self._waveList, function(a, b) 
                local bossA = self._bossList[a]
                local bossB = self._bossList[b]
                local hpPercentA = bossA.bossHp/bossA.totalHp
                local hpPercentB = bossB.bossHp/bossB.totalHp
                if hpPercentA ~= hpPercentB then
                    return hpPercentA < hpPercentB
                else
                    return a < b 
                end
            end)
    end
    for _, wave in pairs(removedWaveList) do
        table.insert(self._waveList, wave)
    end
end

function QUIDialogRobotForSociety:_showBoss(isSort)
    self:_updateData()

    local bossList = remote.union:getConsortiaBossList(self._chapter)
    if not bossList or #bossList == 0 then return end
    
    self:_mySort(isSort)

    self._ccbOwner.node_move:removeAllChildren()

    for index, wave in pairs(self._waveList) do
        local node = self._ccbOwner["node_"..index]
        if node then
            node:removeAllChildren()
            node:setPositionX(self._posiotionList[index].x)
            node:setPositionY(self._posiotionList[index].y)
            node:setVisible(true)
        end
    end

    for index, wave in pairs(self._waveList) do
        local node = self._ccbOwner["node_"..index]
        if node then
            for _, value in pairs(bossList) do
                if value.wave == wave then
                    local boss = QUIWidgetRobotSocietyDungeonBoss.new(value)
                    self._bossList[value.wave] = {}
                    self._bossList[value.wave].size = boss:getSize()
                    self._bossList[value.wave].bossHp = value.bossHp
                    self._bossList[value.wave].totalHp = boss:getTotalHp()
                    node:addChild(boss)
                end
            end
        end
    end
end

function QUIDialogRobotForSociety:_updateData()
    local userConsortia = remote.user:getPropForKey("userConsortia")
    -- 初始化可挑战BOSS次数
    self._fightCounts = userConsortia.consortia_boss_fight_count
    self._ccbOwner.tf_counts:setString(self._fightCounts)
end

function QUIDialogRobotForSociety:_actionHandler(node, pos)
    local arr = CCArray:create()
    arr:addObject(CCMoveTo:create(0.3, pos))
    arr:addObject(CCCallFunc:create(function()
        node:setScale(0.72*1.2)
        end))
    arr:addObject(CCScaleTo:create(2/30, 0.72*0.9, 0.72*0.9))
    arr:addObject(CCScaleTo:create(1/30, 0.72, 0.72))
    node:runAction(CCSequence:create(arr))
end

function QUIDialogRobotForSociety:onEvent(event)
    local pos = self._ccbOwner.node_contain:convertToNodeSpaceAR(ccp(event.x, event.y))
    if event.name == "began" then
        if self._moveState == QUIDialogRobotForSociety.STATE_NONE then
            local isGetBoss, wave, index = self:_getBossByPos(pos)
            if isGetBoss then
                app.sound:playSound("common_small")
                self._moveState = QUIDialogRobotForSociety.STATE_MOVE
                self._selectWave = wave
                self._removeIndex = index
                local bossList = remote.union:getConsortiaBossList(self._chapter)
                for _, value in pairs(bossList) do
                    if value.wave == wave then
                        local boss = QUIWidgetRobotSocietyDungeonBoss.new(value)
                        self._ccbOwner.node_move:addChild(boss)
                    end
                end
                self._moveNode = self._ccbOwner.node_move
                -- self._moveNode = self._ccbOwner["node_"..index]
                self._ccbOwner["node_"..index]:setVisible(false)
                self._moveNode:setPosition(pos.x, pos.y)
                self._startX = pos.x
                -- local parentNode = self._moveNode:getParent()
                -- self._moveNode:removeFromParent()
                -- parentNode:addChild(self._moveNode)
                -- self._moveNode:setParent(parentNode)
                -- self._ccbOwner.node_contain:addChild(self._moveNode)
            end
        else
            return
        end
    elseif event.name == "moved" then
        if self._moveState == QUIDialogRobotForSociety.STATE_MOVE then
            if self._moveNode ~= nil then
                self._moveNode:setPosition(pos.x, pos.y)
            end
        end
    elseif event.name == "ended" then
        if self._moveState == QUIDialogRobotForSociety.STATE_MOVE then
            app.sound:playSound("common_cancel")
            self._moveState = QUIDialogRobotForSociety.STATE_NONE
            table.remove(self._waveList, self._removeIndex)
            local insertPos = 0
            local minX = 999999999
            local maxX = -999999999
            for index, wave in pairs(self._waveList) do
                local bossInfo = self._bossList[wave]
                if pos.x > (self._posiotionList[index].x-bossInfo.size.width/2) and pos.x < (self._posiotionList[index].x+bossInfo.size.width/2) then
                    insertPos = index
                    break
                end
                -- if self._startX < pos.x then
                --     -- 右移
                --     if pos.x > self._posiotionList[index].x and self._posiotionList[index].x > maxX then
                --         maxX = self._posiotionList[index].x
                --         insertPos = index
                --     end
                -- else
                --     -- 左移
                --     if pos.x < self._posiotionList[index].x and self._posiotionList[index].x < minX then
                --         minX = self._posiotionList[index].x
                --         insertPos = index
                --     end
                -- end
                
            end

            if insertPos == 0 then
                table.insert(self._waveList, self._selectWave)
            else
                table.insert(self._waveList, insertPos, self._selectWave)
            end

            self:_showBoss(false)
        end
    end
end

function QUIDialogRobotForSociety:_getBossByPos( pos )
    for index, wave in pairs(self._waveList) do
        local node = self._ccbOwner["node_"..index]
        if node then
            local bossInfo = self._bossList[wave]
            QPrintTable(bossInfo)
            if bossInfo.bossHp ~= 0 then
                local size = bossInfo.size
                local position = self._posiotionList[index]
                if pos.x >= position.x - size.width/2 and pos.x <= position.x + size.width/2 and pos.y >= position.y - size.height/2 and pos.y <= position.y + size.height/2 then
                    return true, wave, index
                end 
            end
        end
    end
end

function QUIDialogRobotForSociety:viewDidAppear()
    QUIDialogRobotForSociety.super.viewDidAppear(self)
end

function QUIDialogRobotForSociety:viewWillDisappear()
    QUIDialogRobotForSociety.super.viewWillDisappear(self)
end

function QUIDialogRobotForSociety:_onTriggerClose()
    self._isStartRobot = false
    self:close()
end

function QUIDialogRobotForSociety:_onTriggerCancel()
    self._isStartRobot = false
    self:close()
end

function QUIDialogRobotForSociety:_onTriggerOK(e)
    if self._fightCounts == 0 then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBuyCountBase", options = {cls = "QBuyCountUnionInstance", buyCallback = handler(self, self._updateData)}}, {isPopCurrentDialog = false})
        -- app.tip:floatTip("魂师大人，您攻打次数进行扫荡～")
        return
    end
    local isFind = false
    for _, boss in pairs(self._bossList) do
        if boss.bossHp > 0 then
            isFind = true
        end
    end
    if isFind then 
        self._isStartRobot = true
        self:close()
    else
        app.tip:floatTip("魂师大人，当前章节已经通关了，请继续挑战下一章节～")
        return
    end
end

function QUIDialogRobotForSociety:close()
    app.sound:playSound("common_close")
    self:playEffectOut()
end

function QUIDialogRobotForSociety:viewAnimationOutHandler()
    local callType = self._type
    self:popSelf()

    if self._isStartRobot then
        self:startRobot()
    end
end

function QUIDialogRobotForSociety:startRobot()
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRobotForSocietyInformation",
        options = {list = self._waveList, chapter = self._chapter}})
end

function QUIDialogRobotForSociety:_backClickHandler()
    self:_onTriggerClose()
end

return QUIDialogRobotForSociety