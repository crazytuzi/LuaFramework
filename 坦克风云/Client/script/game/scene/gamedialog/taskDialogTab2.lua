require "luascript/script/game/gamemodel/task/taskVoApi"

taskDialogTab2 = {}

function taskDialogTab2:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.cancelBtn = nil
    self.refreshBtn = nil
    self.resetBtn = nil
    self.resetCountLabel = nil
    --self.newsIconTab={}
    self.expandIdx = {}
    
    self.timeTab = {}
    self.urgentTab = nil
    self.showTasks = {}
    self.playerLv = 0
    
    return nc
end

--设置或修改每个Tab页签
function taskDialogTab2:resetTab()
    self.allTabs = {getlocal("dailyTask_sub_title_1"), getlocal("dailyTask_sub_title_2"), getlocal("dailyTask_sub_title_3"), getlocal("dailyTask_sub_title_4")}
    self:initTab(self.allTabs)
    local index = 0
    self.selectedTabIndex = 0
    for k, v in pairs(self.allTabs) do
        local tabBtnItem = v
        
        if index == 0 then
            tabBtnItem:setPosition(100, G_VisibleSizeHeight - tabBtnItem:getContentSize().height / 2 - 160)
        elseif index == 1 then
            tabBtnItem:setPosition(248, G_VisibleSizeHeight - tabBtnItem:getContentSize().height / 2 - 160)
        elseif index == 2 then
            tabBtnItem:setPosition(394, G_VisibleSizeHeight - tabBtnItem:getContentSize().height / 2 - 160)
        elseif index == 3 then
            tabBtnItem:setPosition(540, G_VisibleSizeHeight - tabBtnItem:getContentSize().height / 2 - 160)
        end
        if index == self.selectedTabIndex then
            tabBtnItem:setEnabled(false)
        end
        index = index + 1
    end
    
end

function taskDialogTab2:initTab(tabTb)
    local tabBtn = CCMenu:create()
    local tabIndex = 0
    local tabBtnItem;
    if tabTb ~= nil then
        for k, v in pairs(tabTb) do
            
            tabBtnItem = CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png", "RankBtnTab_Down.png")
            
            tabBtnItem:setAnchorPoint(CCPointMake(0.5, 0.5))
            
            local function tabClick(idx)
                return self:tabClick(idx)
            end
            tabBtnItem:registerScriptTapHandler(tabClick)
            
            local lb = GetTTFLabel(v, 24, true)
            lb:setPosition(CCPointMake(tabBtnItem:getContentSize().width / 2, tabBtnItem:getContentSize().height / 2))
            tabBtnItem:addChild(lb)
            lb:setTag(31)
            
            local numHeight = 20
            local iconWidth = 36
            local iconHeight = 36
            local newsNumLabel = GetTTFLabel("0", numHeight)
            newsNumLabel:setPosition(ccp(newsNumLabel:getContentSize().width / 2 + 5, iconHeight / 2))
            newsNumLabel:setTag(11)
            local capInSet1 = CCRect(17, 17, 1, 1)
            local function touchClick()
            end
            local newsIcon = LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png", capInSet1, touchClick)
            if newsNumLabel:getContentSize().width + 10 > iconWidth then
                iconWidth = newsNumLabel:getContentSize().width + 10
            end
            newsIcon:setContentSize(CCSizeMake(iconWidth, iconHeight))
            newsIcon:ignoreAnchorPointForPosition(false)
            newsIcon:setAnchorPoint(CCPointMake(1, 0.5))
            newsIcon:setPosition(ccp(tabBtnItem:getContentSize().width - 2 + 15, tabBtnItem:getContentSize().height))
            newsIcon:addChild(newsNumLabel, 1)
            newsIcon:setTag(10)
            newsIcon:setVisible(false)
            tabBtnItem:addChild(newsIcon, 2)
            
            --local lockSp=CCSprite:createWithSpriteFrameName("LockIconCheckPoint.png")
            local lockSp = CCSprite:createWithSpriteFrameName("LockIcon.png")
            lockSp:setAnchorPoint(CCPointMake(0, 0.5))
            lockSp:setPosition(ccp(10, tabBtnItem:getContentSize().height / 2))
            lockSp:setScaleX(0.7)
            lockSp:setScaleY(0.7)
            tabBtnItem:addChild(lockSp, 3)
            lockSp:setTag(30)
            lockSp:setVisible(false)

            self.allTabs[k] = tabBtnItem
            tabBtn:addChild(tabBtnItem)
            tabBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
            tabBtnItem:setTag(tabIndex)
            
            tabIndex = tabIndex + 1
        end
    end
    tabBtn:setPosition(0, 0)
    self.bgLayer:addChild(tabBtn, 2)
    
end

function taskDialogTab2:setTipsVisibleByIdx(isVisible, idx, num)
    if self == nil then
        do
            return
        end
    end
    local tabBtnItem = self.allTabs[idx]
    local temTabBtnItem = tolua.cast(tabBtnItem, "CCNode")
    local tipSp = temTabBtnItem:getChildByTag(10)
    if tipSp ~= nil then
        if tipSp:isVisible() ~= isVisible then
            tipSp:setVisible(isVisible)
        end
        if tipSp:isVisible() == true then
            local tipNumLabel = tolua.cast(tipSp:getChildByTag(11), "CCLabelTTF")
            if tipNumLabel ~= nil then
                if num and tipNumLabel:getString() ~= tostring(num) then
                    tipNumLabel:setString(num)
                    local iconWidth = 36
                    if tipNumLabel:getContentSize().width + 10 > iconWidth then
                        iconWidth = tipNumLabel:getContentSize().width + 10
                    end
                    tipSp:setContentSize(CCSizeMake(iconWidth, 36))
                    tipNumLabel:setPosition(getCenterPoint(tipSp))
                end
            end
        end
    end
end

function taskDialogTab2:init(layerNum, parentDialog)
    self.layerNum = layerNum
    self.parentDialog = parentDialog
    self.bgLayer = CCLayer:create()
    self.playerLv = playerVoApi:getPlayerLevel()
    -- self:initTableView()
    local isShowNew = taskVoApi:isShowNew()
    if isShowNew == true then
    else
        self:resetTab()
    end
    self:doUserHandler()
    
    return self.bgLayer
end

--设置对话框里的tableView
function taskDialogTab2:initTableView(height, posY)
    self.timeTab = {}
    
    local tvHeight = height or 230
    local hPos = posY or 65
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.bgLayer:getContentSize().width - 10, self.bgLayer:getContentSize().height - tvHeight), nil)
    self.bgLayer:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition(ccp(30, hPos))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
    
    if self.urgentTab == nil then
        self.urgentTab = self.timeTab
    end
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function taskDialogTab2:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        local num = 0
        if self.showTasks and SizeOfTable(self.showTasks) > 0 then
            num = SizeOfTable(self.showTasks)
        end
        return num
    elseif fn == "tableCellSizeForIndex" then
        local tmpSize
        tmpSize = CCSizeMake(400, 106)
        return tmpSize
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()

        local showTasks = self.showTasks
        if showTasks == nil or SizeOfTable(showTasks) == 0 then
            do return cell end
        end

        local task = showTasks[tonumber(idx) + 1]
        local taskVo = taskVoApi:getTaskFromCfg(task.sid, true)
        
        local isShowNew = taskVoApi:isShowNew()
        local playerLv = playerVoApi:getPlayerLevel()
        local needLv
        local isUnlock = true
        if isShowNew == true then
            if taskVo and taskVo.needLv then
                needLv = taskVo.needLv
                if playerLv < needLv then
                    isUnlock = false
                end
            end
        end
        
        local reduceHeight = 9
        local lbWidth = 25 * 11 + 20
        local btnAddX, btnAddY = 13, 9
        
        local rect = CCRect(0, 0, 50, 50)
        local capInSet = CCRect(20, 20, 10, 10)
        local function cellClick(hd, fn, idx)
        end
        local backSprie
        if taskVo.isUrgency == 1 then
            backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("VipLineYellow.png", capInSet, cellClick)
        else--"panelItemBg.png",capInSet
            backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("newKuang2.png", CCRect(7, 7, 1, 1), cellClick)--
        end
        
        backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width - 60, 104))
        backSprie:ignoreAnchorPointForPosition(false)
        backSprie:setAnchorPoint(ccp(0, 0))
        backSprie:setIsSallow(false)
        backSprie:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
        backSprie:setPosition(ccp(0, 0))
        cell:addChild(backSprie, 1)
        
        -- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
        local taskIcon
        local pic = taskVo.style
        -- print("task.sid,pic",task.sid,pic)
        local startIndex, endIndex = string.find(pic, "^rank(%d+).png$")
        local iconScaleX = 1
        local iconScaleY = 1
        if (startIndex ~= nil and endIndex ~= nil) or taskVo.isPintu == 1 then
            taskIcon = GetBgIcon(pic, nil, nil, 70, 80)
        else
            if taskVo and taskVo.style and taskVo.style ~= "" then
                taskIcon = CCSprite:createWithSpriteFrameName(taskVo.style)
            end
            if taskIcon then
                if taskIcon:getContentSize().width > 100 then
                    iconScaleX = 0.78 * 100 / 150
                    iconScaleY = 0.75 * 100 / 150
                else
                    iconScaleX = 0.78
                    iconScaleY = 0.75
                end
                taskIcon:setScaleX(iconScaleX)
                taskIcon:setScaleY(iconScaleY)
            end
        end
        if taskIcon then
            taskIcon:setAnchorPoint(ccp(0, 0))
            taskIcon:setPosition(ccp(15, 14))
            cell:addChild(taskIcon, 1)
        end
        
        local taskNameStr = taskVoApi:getTaskInfoById(taskVo.sid, true, true)--true:name,false:desc
        -- local taskNameStr=getlocal(taskVo.name)
        -- if tostring(taskVo.type)=="3" then
        -- taskNameStr=getlocal(taskVo.name)..getlocal("schedule_hours")
        -- end
        -- taskNameStr=str
        local strSize2, strSize4, lanChos = 20, 21, G_getCurChoseLanguage()
        if lanChos == "ru" then
            strSize2, strSize4 = 18, 18
        elseif lanStr == "cn" or lanStr == "tw" or lanStr == "ja" or lanStr == "ko" then
            strSize4 = 24
        end
        local taskName
        if isShowNew == true then
            if isUnlock == true then
                taskName = GetTTFLabelWrap(taskNameStr, strSize4, CCSizeMake(lbWidth + 20, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
            else
                taskName = GetTTFLabelWrap(taskNameStr, strSize4, CCSizeMake(backSprie:getContentSize().width - 250, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
            end
            taskName:setAnchorPoint(ccp(0, 0.5))
            taskName:setPosition(100, 105 - 15 - reduceHeight)
        else
            taskName = GetTTFLabelWrap(taskNameStr, strSize4, CCSizeMake(lbWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop, "Helvetica-bold")
            taskName:setAnchorPoint(ccp(0, 1))
            taskName:setPosition(100, 105 - reduceHeight)
        end
        cell:addChild(taskName, 1)
        if taskVo.isUrgency == 1 then
            taskName:setColor(G_ColorYellowPro)
        else
            taskName:setColor(G_ColorGreen)
        end
        
        if task.isReward == 1 then
        elseif taskVo.isUrgency == 1 then
            local endTime = task.ts
            local countDown = endTime - base.serverTime
            if countDown > 0 then
                local tStr = G_getTimeStr(countDown)
                local countDownLb = GetTTFLabel(tStr, strSize2)
                countDownLb:setColor(G_ColorRed)
                countDownLb:setAnchorPoint(ccp(1, 1))
                countDownLb:setPosition(lbWidth, 105 - reduceHeight)
                cell:addChild(countDownLb, 1)
                
                table.insert(self.timeTab, {sid = task.sid, et = endTime, timeLabel = countDownLb})
            end
        end
        
        local function showLockStr(lockStr)
            local lockStrLb = GetTTFLabelWrap(lockStr, strSize2, CCSizeMake(450, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
            lockStrLb:setAnchorPoint(ccp(0, 0.5))
            lockStrLb:setPosition(ccp(100, 48 - reduceHeight / 2))
            cell:addChild(lockStrLb, 1)
            lockStrLb:setColor(G_ColorRed)
            
            local function maskClickHandler()
                if self.tv:getScrollEnable() == true and self.tv:getIsScrolled() == false then
                    if G_checkClickEnable() == false then
                        do
                            return
                        end
                    else
                        base.setWaitTime = G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), lockStr, 30)
                end
            end
            local maskSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), maskClickHandler)
            maskSp:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
            maskSp:setIsSallow(true)
            local rect = CCSizeMake(backSprie:getContentSize().width, backSprie:getContentSize().height)
            maskSp:setContentSize(rect)
            maskSp:setOpacity(100)
            maskSp:setAnchorPoint(ccp(0, 0))
            maskSp:setPosition(ccp(5, 0))
            cell:addChild(maskSp, 11)
        end
        
        local schedule
        if isUnlock == true then
            if tonumber(taskVo.sid) == 1012 then --超级武器掠夺
                if superWeaponVoApi:isWeaponRobUnlock() == false then
                    local lockStr = getlocal("swrob_unlock_str")
                    showLockStr(lockStr)
                    do return cell end
                end
            end
            if isShowNew == true then
                local acPoint = 0
                local dCfg = taskVoApi:getTaskFromCfg(taskVo.sid, true)
                if dCfg and dCfg.point then
                    acPoint = dCfg.point
                end
                local activeLb = GetTTFLabelWrap(getlocal("daily_task_active_point", {"+"..acPoint}), strSize2, CCSizeMake(lbWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
                activeLb:setAnchorPoint(ccp(0, 0.5))
                local strPosy = G_getCurChoseLanguage() == "ru" and 60 or 63
                activeLb:setPosition(ccp(100, strPosy - reduceHeight))
                cell:addChild(activeLb, 1)
            end
            
            if task.isReward == 1 then
                schedule = GetTTFLabelWrap(getlocal("hadCompleted"), strSize2, CCSizeMake(lbWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                schedule:setAnchorPoint(ccp(0, 0.5))
                schedule:setPosition(100, 35 - reduceHeight)
                cell:addChild(schedule, 1)
                
                local finishedSp = CCSprite:createWithSpriteFrameName("monthlysignFreeGetIcon.png")
                -- local finishedSp=CCSprite:createWithSpriteFrameName("IconCheck.png")
                -- finishedSp:setAnchorPoint(ccp(0,0))
                finishedSp:setPosition(ccp(510 + btnAddX, 50 - 10 + btnAddY))
                cell:addChild(finishedSp, 1)
                finishedSp:setScale(0.7)
            elseif taskVoApi:isCompletedTask(task.sid, true) then
                schedule = GetTTFLabelWrap(getlocal("hadCompleted"), strSize2, CCSizeMake(lbWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                schedule:setAnchorPoint(ccp(0, 0.5))
                schedule:setPosition(100, 35 - reduceHeight)
                cell:addChild(schedule, 1)
                -- schedule:setColor(G_ColorYellowPro)

                local function rewardHandler(tag, object)
                    if self.tv:getScrollEnable() == true and self.tv:getIsScrolled() == false then
                        if G_checkClickEnable() == false then
                            do
                                return
                            end
                        else
                            base.setWaitTime = G_getCurDeviceMillTime()
                        end
                        PlayEffect(audioCfg.mouseClick)
                        local sid = task.sid
                        local point = taskVoApi:getAddAlliancePoint(sid)
                        local function finishDailytask()
                            local function dailytaskFinishHandler(fn, data)
                                local urgencyTab = taskVoApi:getUrgencyTasks()
                                local ret, sData = base:checkServerData(data)
                                if ret == true then
                                    local isShowAddPoint = false
                                    if point and point > 0 and allianceVoApi:isHasAlliance() == true then
                                        if sData.data.rais and sData.data.rais == 1 then
                                            taskVoApi:addAlliancePoint(sid)
                                            isShowAddPoint = true
                                        elseif sData.data.rais and sData.data.rais == -1 then
                                            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("reward_alliance_point_max"), nil, self.layerNum + 1)
                                        end
                                    end
                                    
                                    local awardStr, awardTab = taskVoApi:getAwardStr(sid, true, isShowAddPoint)
                                    local realReward = playerVoApi:getTrueReward(awardTab)
                                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), awardStr, 28, nil, nil, realReward)
                                    self:refresh()
                                    self:showUrgentTask(urgencyTab)
                                    if realReward and SizeOfTable(realReward) > 0 then
                                        for k, v in pairs(realReward) do
                                            if v.type ~= "u" then
                                                G_addPlayerAward(v.type, v.key, v.id, v.num, false, true)
                                            end
                                        end
                                    end
                                end
                            end
                            local taskid = "s"..tostring(sid)
                            if isShowNew == true then
                                socketHelper:dailytaskRewardTask(taskid, dailytaskFinishHandler)
                            else
                                socketHelper:dailytaskFinishNew(taskid, dailytaskFinishHandler)
                            end
                        end

                        if point and point > 0 and allianceVoApi:isHasAlliance() == false then
                            smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), finishDailytask, getlocal("dialog_title_prompt"), getlocal("reward_no_alliance_point"), nil, self.layerNum + 1)
                        else
                            finishDailytask()
                        end
                    end
                end
                -- local menuItemAward=GetButtonItem("TaskBtnGet.png","TaskBtnGet_Down.png","TaskBtnGet_Down.png",rewardHandler,task.sid,nil,0)
                local menuItemAward = GetButtonItem("yh_taskReward.png", "yh_taskReward_down.png", "yh_taskReward_down.png", rewardHandler, task.sid, nil, 0)
                -- self:iconFlicker(menuItemAward)
                G_addFlicker(menuItemAward, 2, 2)
                local menuAward = CCMenu:createWithItem(menuItemAward)
                menuAward:setAnchorPoint(ccp(0, 0))
                menuAward:setPosition(ccp(510 + btnAddX, 50 - 10 + btnAddY))
                menuAward:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                cell:addChild(menuAward, 1)
            else
                schedule = GetTTFLabelWrap(getlocal(taskVo.schedule, {task.num, task.cNum}), strSize2, CCSizeMake(lbWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                schedule:setAnchorPoint(ccp(0, 0.5))
                schedule:setPosition(100, 35 - reduceHeight)
                cell:addChild(schedule, 1)
                
                local function gotoHandler(tag, object)
                    if self.tv:getScrollEnable() == true and self.tv:getIsScrolled() == false then
                        if G_checkClickEnable() == false then
                            do
                                return
                            end
                        else
                            base.setWaitTime = G_getCurDeviceMillTime()
                        end
                        PlayEffect(audioCfg.mouseClick)
                        G_taskJumpTo(taskVo, self.parentDialog)
                    end
                end
                local gotoItem = GetButtonItem("yh_taskGoto.png", "yh_taskGoto_down.png", "yh_taskGoto_down.png", gotoHandler, task.sid, nil, 0)
                -- local gotoItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",gotoHandler,task.sid,getlocal("activity_heartOfIron_goto"),25)
                -- gotoItem:setScale(0.75)
                local gotoMenu = CCMenu:createWithItem(gotoItem)
                gotoMenu:setAnchorPoint(ccp(0, 0))
                gotoMenu:setPosition(ccp(510 + btnAddX, 50 - 10 + btnAddY))
                gotoMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                cell:addChild(gotoMenu, 1)
            end

            local function touch(tag, object)
                if self.tv:getScrollEnable() == true and self.tv:getIsScrolled() == false then
                    if newGuidMgr:isNewGuiding() == true then
                        do return end
                    end
                    if G_checkClickEnable() == false then
                        do
                            return
                        end
                    else
                        base.setWaitTime = G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)
                    local taskVo = taskVoApi:getTaskFromCfg(tag, true)
                    local task = taskVoApi:getTaskBySid(tag, true)
                    local awardTab = taskVoApi:getAwardBySid(tag, true)
                    local scheduleStr = ""
                    if task.isReward == 1 or taskVoApi:isCompletedTask(tag, true) then
                        scheduleStr = getlocal("hadCompleted")
                    else
                        scheduleStr = getlocal(taskVo.schedule, {task.num, task.cNum})
                    end
                    local capInSet1 = CCRect(30, 30, 1, 1)
                    
                    local taskDescStr = taskVoApi:getTaskInfoById(taskVo.sid, false, true)--true:name,false:desc
                    --             local taskDescStr=getlocal(taskVo.description)
                    -- if tostring(taskVo.type)=="3" then
                    -- taskDescStr=getlocal(taskVo.description)..getlocal("schedule_hours")
                    -- end
                    smallDialog:showTaskDialog("rewardPanelBg1.png", CCSizeMake(500, 600), CCRect(0, 0, 400, 350), capInSet1, true, 4, {getlocal("award"), " ", scheduleStr, " ", taskDescStr}, 20, awardTab, nil, nil, true)
                end
            end
            local menuItemDesc = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", touch, task.sid, nil, 0)
            local menuDesc = CCMenu:createWithItem(menuItemDesc)
            menuDesc:setAnchorPoint(ccp(0, 0))
            menuDesc:setPosition(ccp(420 + btnAddX * 2, 50 - 10 + btnAddY))
            menuDesc:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
            cell:addChild(menuDesc, 1)
        else
            local levelLimitStr = getlocal("daily_task_level_limit", {needLv})
            showLockStr(levelLimitStr)
        end
        
        return cell
    elseif fn == "ccTouchBegan" then
        self.isMoved = false
        return true
    elseif fn == "ccTouchMoved" then
        self.isMoved = true
    elseif fn == "ccTouchEnded" then

    elseif fn == "ccScrollEnable" then
        if newGuidMgr:isNewGuiding() == true then
            return 0
        else
            return 1
        end
    end
end

function taskDialogTab2:showUrgentTask(urgencyTab)
    local urgencyNewTab = taskVoApi:getUrgencyTasks()
    if urgencyTab and urgencyNewTab then
        local oldNum = SizeOfTable(urgencyTab)
        local newNum = SizeOfTable(urgencyNewTab)
        if oldNum < newNum then
            for k, v in pairs(urgencyNewTab) do
                if v and v.sid then
                    local newSid = v.sid
                    local isHasSid = false
                    for m, n in pairs(urgencyTab) do
                        if n and n.sid then
                            if newSid == n.sid then
                                isHasSid = true
                            end
                        end
                    end
                    if isHasSid == false then
                        local function jumpTo()
                            self:tabClick(1)
                        end
                        local cfg = taskVoApi:getTaskFromCfg(newSid, true)
                        local item = {pic = cfg.style, name = cfg.name, desc = cfg.detailDesc}
                        smallDialog:showUrgentTaskDialog("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), true, self.layerNum + 1, getlocal("urgent_task"), getlocal("alliance_list_check_info"), nil, jumpTo, nil, nil, item)
                    end
                end
            end
        end
    end
end

--设置对话框里的tableView
function taskDialogTab2:initTableView2()
    if self.extraRewardBg then
        local function callBack(...)
            return self:eventHandler2(...)
        end
        local hd = LuaEventHandler:createHandler(callBack)
        self.tv2 = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.extraRewardBg:getContentSize().width, self.extraRewardBg:getContentSize().height - 10), nil)
        self.extraRewardBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
        self.tv2:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
        self.tv2:setPosition(ccp(0, 5))
        self.extraRewardBg:addChild(self.tv2)
        self.tv2:setMaxDisToBottomOrTop(0)
    end
end

function taskDialogTab2:eventHandler2(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return 1
    elseif fn == "tableCellSizeForIndex" then
        if self.extraRewardBg == nil then
            do return end
        end
        local tmpSize
        tmpSize = CCSizeMake(self.extraRewardBg:getContentSize().width, self.extraRewardBg:getContentSize().height - 10)
        return tmpSize
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        if self.extraRewardBg == nil then
            do return cell end
        end
        
        local bgWidth = self.extraRewardBg:getContentSize().width
        local bgHeight = self.extraRewardBg:getContentSize().height - 10
        local pox1, poy1 = 60, bgHeight / 2 - 8
        local barWidth = 450
        
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        local backBg = CCSprite:create("public/emblem/emblemBlackBg.jpg")
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        -- backBg:setScaleY((sceneSpH-10)/backBg:getContentSize().height)
        -- backBg:setScaleX((G_VisibleSizeWidth - 60)/backBg:getContentSize().width)
        -- backBg:setAnchorPoint(ccp(0,0))
        backBg:setPosition(ccp(bgWidth / 2, bgHeight / 2 - 30))
        cell:addChild(backBg)
        
        local acPoint = taskVoApi:getAcPoint()
        local maxPoint = dailyTaskCfg2.maxPoint
        local percentStr = ""
        local per = tonumber(acPoint) / tonumber(maxPoint) * 100
        AddProgramTimer(cell, ccp(bgWidth / 2 + 20, poy1), 11, 12, percentStr, "platWarProgressBg.png", "taskBlueBar.png", 13, 1, 1)
        local timerSpriteLv = cell:getChildByTag(11)
        timerSpriteLv = tolua.cast(timerSpriteLv, "CCProgressTimer")
        timerSpriteLv:setPercentage(per)
        local timerSpriteBg = cell:getChildByTag(13)
        timerSpriteBg = tolua.cast(timerSpriteBg, "CCSprite")
        local scalex = barWidth / timerSpriteLv:getContentSize().width
        timerSpriteBg:setScaleX(scalex)
        timerSpriteLv:setScaleX(scalex)
        -- tolua.cast(timerSpriteLv:getChildByTag(12),"CCLabelTTF"):setString(percentStr)
        -- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
        -- local descLb=GetTTFLabelWrap(str,25,CCSizeMake(450,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        local strSize3, strWidth2 = 18, 500
        if G_getCurChoseLanguage() == "cn" or G_getCurChoseLanguage() == "tw" then
            strSize3, strWidth2 = 20, 500
        else
            strSize3 = 17
        end
        local descLb = GetTTFLabelWrap(getlocal("daily_task_point_desc"), strSize3, CCSizeMake(strWidth2, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        descLb:setAnchorPoint(ccp(0.5, 0.5))
        descLb:setPosition(ccp(bgWidth / 2 + 25, poy1 - 49))
        cell:addChild(descLb, 2)
        descLb:setColor(G_ColorWhite)
        
        local acSp = CCSprite:createWithSpriteFrameName("taskActiveSp.png")
        acSp:setPosition(ccp(pox1, poy1))
        cell:addChild(acSp, 2)
        local acPointLb = GetBMLabel(acPoint, G_GoldFontSrc, 10)
        acPointLb:setPosition(ccp(acSp:getContentSize().width / 2, acSp:getContentSize().height / 2 - 2))
        acSp:addChild(acPointLb, 2)
        acPointLb:setScale(0.5)
        -- local todayAcPointLb=GetTTFLabelWrap("啊啊啊啊啊啊啊啊",25,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        local todayAcPointLb = GetTTFLabelWrap(getlocal("daily_task_today_point"), 20, CCSizeMake(120, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        todayAcPointLb:setAnchorPoint(ccp(0.5, 0.5))
        todayAcPointLb:setPosition(ccp(pox1, poy1 + 70))
        cell:addChild(todayAcPointLb, 2)
        todayAcPointLb:setColor(G_ColorYellowPro)


        local nodeNum = 5
        for i = 1, nodeNum do
            local sid = i + 2000
            local pointNum = maxPoint / nodeNum * i
            local rCfg = taskVoApi:getTaskFromCfg(sid, false, true)
            if rCfg and rCfg.require and rCfg.require[1] then
                pointNum = rCfg.require[1]
            end
            local spacex = barWidth / nodeNum
            local px, py = pox1 + i * spacex + 27, poy1
            local acSp1 = CCSprite:createWithSpriteFrameName("taskActiveSp1.png")
            acSp1:setPosition(ccp(px, py))
            cell:addChild(acSp1, 2)
            acSp1:setScale(1.4)
            local acSp2 = CCSprite:createWithSpriteFrameName("taskActiveSp2.png")
            acSp2:setPosition(ccp(px, py))
            cell:addChild(acSp2, 2)
            acSp2:setScale(1.4)
            if acPoint >= pointNum then
                acSp1:setVisible(false)
            else
                acSp2:setVisible(false)
            end
            local numLb = GetBMLabel(pointNum, G_GoldFontSrc, 10)
            numLb:setPosition(ccp(px, py))
            cell:addChild(numLb, 3)
            numLb:setScale(0.3)
            
            local function clickBoxHandler(...)
                if G_checkClickEnable() == false then
                    do
                        return
                    end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                
                -- local acPoint1=taskVoApi:getAcPoint()
                -- local isReward=taskVoApi:acPointIsReward(i)
                -- local sid=i+2000
                -- local isDailyPoint=true
                -- local point=taskVoApi:getAddAlliancePoint(sid,isDailyPoint)
                -- if acPoint>=pointNum and isReward==false then
                -- local function rewardPointCallback(fn,data)
                -- local ret,sData=base:checkServerData(data)
                --       if ret==true then
                --       local isShowAddPoint=false
                --             if point and point>0 and allianceVoApi:isHasAlliance()==true then
                --       if sData.data.rais and sData.data.rais==1 then
                --       taskVoApi:addAlliancePoint(sid,isDailyPoint)
                --       isShowAddPoint=true
                --       elseif sData.data.rais and sData.data.rais==-1 then
                --       smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("reward_alliance_point_max"),nil,self.layerNum+1)
                --       end
                --       end
                
                --             local awardStr,awardTab = taskVoApi:getAwardStr(sid,true,isShowAddPoint,isDailyPoint)
                --             local realReward=playerVoApi:getTrueReward(awardTab)
                -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),awardStr,28,nil,nil,realReward)
                -- self:refresh()
                -- -- self:showUrgentTask(urgencyTab)
                -- if realReward and SizeOfTable(realReward)>0 then
                -- for k,v in pairs(realReward) do
                -- if v.type~="u" then
                -- G_addPlayerAward(v.type,v.key,v.id,v.num,false,true)
                -- end
                -- end
                -- end
                --       end
                --       end
                -- local tid="s"..tostring(sid)
                -- socketHelper:dailytaskRewardPoint(tid,rewardPointCallback)
                -- else
                local function rewardPointCallback(...)
                    self:refresh()
                end
                taskVoApi:taskRewardSmallDialog(i, self.layerNum + 1, rewardPointCallback)
                -- end
            end
            px, py = px, py + 55
            local boxScale = 0.7
            local boxSp = LuaCCSprite:createWithSpriteFrameName("taskBox"..i..".png", clickBoxHandler)
            boxSp:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
            -- boxSp:setAnchorPoint(ccp(0.5,0))
            -- boxSp:setPosition(ccp(px,py-boxSp:getContentSize().height/2*boxScale))
            boxSp:setPosition(ccp(px, py))
            cell:addChild(boxSp, 3)
            boxSp:setScale(boxScale)
            local isReward = taskVoApi:acPointIsReward(i)
            if acPoint >= pointNum and isReward == false then
                local lightSp = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
                lightSp:setAnchorPoint(ccp(0.5, 0.5))
                lightSp:setPosition(ccp(px + 5, py))
                cell:addChild(lightSp)
                lightSp:setScale(0.7)
                
                -- boxSp:setRotation(-15)
                --          local rotateBy1 = CCRotateBy:create(0.25,30)
                --          local rotateBy2 = CCRotateBy:create(0.25,-30)
                --          local delay = CCDelayTime:create(0.5)
                --          local acArr=CCArray:create()
                --    acArr:addObject(rotateBy1)
                --    acArr:addObject(rotateBy2)
                --    acArr:addObject(delay)
                --          local seq=CCSequence:create(acArr)
                --          local repeatForever=CCRepeatForever:create(seq)
                --    boxSp:runAction(repeatForever)
                
                local time = 0.1--0.07
                local rotate1 = CCRotateTo:create(time, 30)
                local rotate2 = CCRotateTo:create(time, -30)
                local rotate3 = CCRotateTo:create(time, 20)
                local rotate4 = CCRotateTo:create(time, -20)
                local rotate5 = CCRotateTo:create(time, 0)
                local delay = CCDelayTime:create(1)
                local acArr = CCArray:create()
                acArr:addObject(rotate1)
                acArr:addObject(rotate2)
                acArr:addObject(rotate3)
                acArr:addObject(rotate4)
                acArr:addObject(rotate5)
                acArr:addObject(delay)
                local seq = CCSequence:create(acArr)
                local repeatForever = CCRepeatForever:create(seq)
                boxSp:runAction(repeatForever)
            end
            if isReward == true then
                local lbBg = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png", CCRect(20, 20, 10, 10), function ()end)
                -- lbBg:setContentSize(CCSizeMake(150,40))
                lbBg:setScaleX(150 / lbBg:getContentSize().width)
                lbBg:setPosition(ccp(px, py))
                cell:addChild(lbBg, 4)
                lbBg:setScale(0.7)
                local hasRewardLb = GetTTFLabel(getlocal("activity_hadReward"), 20)
                hasRewardLb:setPosition(ccp(px, py))
                cell:addChild(hasRewardLb, 5)
            end
        end
        
        return cell
    elseif fn == "ccTouchBegan" then
        self.isMoved = false
        return true
    elseif fn == "ccTouchMoved" then
        self.isMoved = true
    elseif fn == "ccTouchEnded" then

    elseif fn == "ccScrollEnable" then
        if newGuidMgr:isNewGuiding() == true then
            return 0
        else
            return 1
        end
    end
end

--用户处理特殊需求,没有可以不写此方法
function taskDialogTab2:doUserHandler()
    self:updateShowTasks()
    local isShowNew = taskVoApi:isShowNew()
    if isShowNew == true then
        if self.extraRewardBg == nil then
            local function touch()
            end
            local capInSet = CCRect(65, 25, 1, 1);
            self.extraRewardBg = LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png", capInSet, touch)
            self.extraRewardBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width - 60, 140 + 50))
            self.extraRewardBg:ignoreAnchorPointForPosition(false)
            self.extraRewardBg:setAnchorPoint(ccp(0.5, 1))
            self.extraRewardBg:setIsSallow(true)
            self.extraRewardBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
            self.extraRewardBg:setPosition(ccp(self.bgLayer:getContentSize().width / 2, self.bgLayer:getContentSize().height - 213 + 50))
            self.bgLayer:addChild(self.extraRewardBg, 1)
            -- print("self.extraRewardBg",self.extraRewardBg:getContentSize().height)
        end
        
        if self and self.tv2 then
            self.tv2:reloadData()
        else
            self:initTableView2()
        end
        if self and self.tv then
            self.tv:reloadData()
        else
            -- self:initTableView(325,160)
            self:initTableView(325 + 100, 160 - 95)
        end
        local str
        local rewardLevel, levelMax = taskVoApi:getRewardLevel()
        if rewardLevel < levelMax then
            str = getlocal("rewardUpdateNeedLevel", {dailyTaskCfg2.levelGroup[rewardLevel + 1]})
        else
            str = getlocal("rewardUpdateMaxLevel", {dailyTaskCfg2.levelGroup[levelMax]})
        end
        local rewardLevelLabel = GetTTFLabel(str, 22, true)
        rewardLevelLabel:setAnchorPoint(ccp(0.5, 0))
        rewardLevelLabel:setPosition(ccp(G_VisibleSizeWidth / 2, 32))
        rewardLevelLabel:setColor(G_ColorYellowPro)
        self.bgLayer:addChild(rewardLevelLabel, 2)
    else
        local extraTask = taskVoApi:getExtraTab(self.selectedTabIndex + 1)
        -- local extraCfg=taskVoApi:getExtraCfg(self.selectedTabIndex+1)
        if extraTask == nil then
            do return end
        end
        local finishNum = extraTask.num or 0
        local totalNum = extraTask.cNum
        if totalNum == nil then
            do return end
        end
        local isFinish = false
        if finishNum >= totalNum then
            isFinish = true
        end
        local isReward = extraTask.isReward
        -- local totalNum=extraCfg.require[1]
        if self.extraRewardBg == nil then
            local function touch()
            end
            local capInSet = CCRect(65, 25, 1, 1);
            self.extraRewardBg = LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png", capInSet, touch)
            self.extraRewardBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width - 60, 140))
            self.extraRewardBg:ignoreAnchorPointForPosition(false)
            self.extraRewardBg:setAnchorPoint(ccp(0.5, 1))
            self.extraRewardBg:setIsSallow(true)
            self.extraRewardBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
            self.extraRewardBg:setPosition(ccp(self.bgLayer:getContentSize().width / 2, self.bgLayer:getContentSize().height - 213))
            self.bgLayer:addChild(self.extraRewardBg, 1)
            -- print("self.extraRewardBg",self.extraRewardBg:getContentSize().height)

            local extraDesc = getlocal("dailyTask_extra_desc")
            local descLb = GetTTFLabelWrap(extraDesc, 20, CCSizeMake(self.extraRewardBg:getContentSize().width - 30, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
            descLb:setAnchorPoint(ccp(0, 0.5))
            descLb:setPosition(15, self.extraRewardBg:getContentSize().height - 50)
            local lbHeight = descLb:getContentSize().height
            if lbHeight > 30 and lbHeight < 85 then
                descLb = GetTTFLabelWrap(extraDesc, 20, CCSizeMake(self.extraRewardBg:getContentSize().width - 30, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                descLb:setAnchorPoint(ccp(0, 1))
                descLb:setPosition(15, self.extraRewardBg:getContentSize().height - 7)
            end
            self.extraRewardBg:addChild(descLb, 1)
            descLb:setColor(G_ColorGreen)

            local percentStr = finishNum.."/"..totalNum
            local per = tonumber(finishNum) / tonumber(totalNum) * 100
            AddProgramTimer(self.extraRewardBg, ccp(190, 30), 11, 12, percentStr, "skillBg.png", "skillBar.png", 13, 1, 1)
            local timerSpriteLv = self.extraRewardBg:getChildByTag(11)
            timerSpriteLv = tolua.cast(timerSpriteLv, "CCProgressTimer")
            timerSpriteLv:setPercentage(per)
            tolua.cast(timerSpriteLv:getChildByTag(12), "CCLabelTTF"):setString(percentStr)
            
            local function extraRewardHandler(tag, object)
                if G_checkClickEnable() == false then
                    do
                        return
                    end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                
                local extraTask1 = taskVoApi:getExtraTab(self.selectedTabIndex + 1)
                local tSid = extraTask1.sid
                local point = taskVoApi:getAddAlliancePoint(tSid)
                local function finishDailytask()
                    local function dailytaskFinishHandler(fn, data)
                        local urgencyTab = taskVoApi:getUrgencyTasks()
                        local ret, sData = base:checkServerData(data)
                        if ret == true then
                            local isShowAddPoint = false
                            if point and point > 0 and allianceVoApi:isHasAlliance() == true then
                                if sData.data.rais and sData.data.rais == 1 then
                                    taskVoApi:addAlliancePoint(tSid)
                                    isShowAddPoint = true
                                elseif sData.data.rais and sData.data.rais == -1 then
                                    smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("reward_alliance_point_max"), nil, self.layerNum + 1)
                                end
                            end
                            
                            local awardStr, awardTab = taskVoApi:getAwardStr(tSid, true, isShowAddPoint)
                            local realReward = playerVoApi:getTrueReward(awardTab)
                            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), awardStr, 28, nil, nil, realReward)
                            self:refresh()
                            self:showUrgentTask(urgencyTab)
                            if realReward and SizeOfTable(realReward) > 0 then
                                for k, v in pairs(realReward) do
                                    if v.type ~= "u" then
                                        G_addPlayerAward(v.type, v.key, v.id, v.num, false, true)
                                    end
                                end
                            end
                        end
                    end
                    local taskid = "s"..tostring(tSid)
                    socketHelper:dailytaskFinishNew(taskid, dailytaskFinishHandler)
                end
                
                if point and point > 0 and allianceVoApi:isHasAlliance() == false then
                    smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), finishDailytask, getlocal("dialog_title_prompt"), getlocal("reward_no_alliance_point"), nil, self.layerNum + 1)
                else
                    finishDailytask()
                end
            end
            -- self.extraRewardBtn=GetButtonItem("TaskBtnGet.png","TaskBtnGet_Down.png","TaskBtnGet_Down.png",extraRewardHandler,nil,nil,0)
            self.extraRewardBtn = GetButtonItem("yh_taskReward.png", "yh_taskReward_down.png", "yh_taskReward_down.png", extraRewardHandler, nil, nil, 0)
            -- self:iconFlicker(self.extraRewardBtn)
            G_addFlicker(self.extraRewardBtn, 2, 2)
            local extraRewardMenu = CCMenu:createWithItem(self.extraRewardBtn)
            -- extraRewardMenu:setAnchorPoint(ccp(0,0.5))
            -- extraRewardMenu:setPosition(ccp(510,self.extraRewardBg:getContentSize().height/2-5))
            extraRewardMenu:setAnchorPoint(ccp(0, 0))
            extraRewardMenu:setPosition(ccp(510, 40))
            extraRewardMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
            -- extraRewardMenu:setScaleX(0.72)
            -- extraRewardMenu:setScaleY(0.85)
            self.extraRewardBg:addChild(extraRewardMenu, 1)
            
            self.finishSp = CCSprite:createWithSpriteFrameName("monthlysignFreeGetIcon.png")
            -- self.finishSp=CCSprite:createWithSpriteFrameName("IconCheck.png")
            -- self.finishSp:setAnchorPoint(ccp(0,0))
            self.finishSp:setPosition(ccp(510, 40))
            self.extraRewardBg:addChild(self.finishSp, 1)
            self.finishSp:setScale(0.7)
            
            local function touch(tag, object)
                if newGuidMgr:isNewGuiding() == true then
                    do return end
                end
                if G_checkClickEnable() == false then
                    do
                        return
                    end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                local exTask = taskVoApi:getExtraTab(self.selectedTabIndex + 1)
                local exSid = exTask.sid
                local taskCfg = taskVoApi:getTaskFromCfg(exSid, true)
                local awardTab = taskVoApi:getAwardBySid(exSid, true)
                local scheduleStr = ""
                if exTask.isReward == 1 or taskVoApi:isCompletedTask(exSid, true) then
                    scheduleStr = getlocal("hadCompleted")
                else
                    scheduleStr = getlocal(taskCfg.schedule, {exTask.num, exTask.cNum})
                end
                local capInSet1 = CCRect(30, 30, 1, 1)
                local taskDescStr = taskVoApi:getTaskInfoById(exSid, false, true)--true:name,false:desc
                smallDialog:showTaskDialog("rewardPanelBg1.png", CCSizeMake(500, 600), CCRect(0, 0, 400, 350), capInSet1, true, 4, {getlocal("award"), " ", scheduleStr, " ", taskDescStr}, 20, awardTab, nil, nil, true)
            end
            self.infoBtn = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", touch, extraTask.sid, nil, 0)
            local menuInfo = CCMenu:createWithItem(self.infoBtn)
            menuInfo:setAnchorPoint(ccp(0, 0))
            menuInfo:setPosition(ccp(410, 52 - 10))
            menuInfo:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
            self.extraRewardBg:addChild(menuInfo, 1)
        end
        
        if self and self.tv then
            self.tv:removeFromParentAndCleanup(true)
            self.tv = nil
        end
        -- self:initTableView(325,160)
        self:initTableView(325 + 100, 160 - 95)
        
        if self.extraRewardBg then
            local percentStr = finishNum.."/"..totalNum
            local per = tonumber(finishNum) / tonumber(totalNum) * 100
            local timerSpriteLv = self.extraRewardBg:getChildByTag(11)
            timerSpriteLv = tolua.cast(timerSpriteLv, "CCProgressTimer")
            timerSpriteLv:setPercentage(per)
            tolua.cast(timerSpriteLv:getChildByTag(12), "CCLabelTTF"):setString(percentStr)
        end
        
        if self.extraRewardBtn then
            if isReward == 0 and isFinish == true then
                self.extraRewardBtn:setEnabled(true)
                self.extraRewardBtn:setVisible(true)
            else
                self.extraRewardBtn:setEnabled(false)
                self.extraRewardBtn:setVisible(false)
            end
        end
        if self.finishSp then
            if isReward == 1 then
                self.finishSp:setVisible(true)
            else
                self.finishSp:setVisible(false)
            end
        end
        
        for i = 1, 4 do
            self:setTipsVisibleByIdx(false, i, 0)
        end
        local dailyTypeTab = taskVoApi:getDailyTypeTab()
        for k, v in pairs(dailyTypeTab) do
            if v and SizeOfTable(v) > 0 then
                local num = taskVoApi:getDailyFinishNum(k)
                if num and num > 0 then
                    self:setTipsVisibleByIdx(true, k, num)
                end
            end
        end
    end
end

function taskDialogTab2:tabClick(idx)
    PlayEffect(audioCfg.mouseClick)
    for k, v in pairs(self.allTabs) do
        if v:getTag() == idx then
            v:setEnabled(false)
            self.selectedTabIndex = idx
        else
            v:setEnabled(true)
        end
    end
    
    self:doUserHandler()
end

--刷新板子
function taskDialogTab2:refresh()
    if self == nil or self.tv == nil then
        do return end
    end
    -- self.tv:reloadData()
    self:doUserHandler()
end

function taskDialogTab2:tick()
    if self and self.timeTab and SizeOfTable(self.timeTab) > 0 then
        for k, v in pairs(self.timeTab) do
            local sid = v.sid
            local endTime = v.et
            local countDown = endTime - base.serverTime
            if countDown > 0 then
                local tStr = G_getTimeStr(countDown)
                local lb = tolua.cast(v.timeLabel, "CCLabelTTF")
                lb:setString(tStr)
            else
                taskVoApi:removeDailyTask(sid, self.selectedTabIndex + 1)
                self:doUserHandler()
            end
        end
    end
    if taskVoApi:isShowNew() == true then
        local playerLv = playerVoApi:getPlayerLevel()
        if self.playerLv ~= playerLv then
            self.playerLv = playerLv
            self:updateShowTasks()
        end
    end
end

function taskDialogTab2:iconFlicker(icon)
    if newGuidMgr:isNewGuiding() then
        do return end
    end
    local m_iconScaleX, m_iconScaleY = 1.65, 0.95
    local pzFrameName = "RotatingEffect1.png"
    local metalSp = CCSprite:createWithSpriteFrameName(pzFrameName)
    local pzArr = CCArray:create()
    for kk = 1, 20 do
        local nameStr = "RotatingEffect"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        pzArr:addObject(frame)
    end
    local animation = CCAnimation:createWithSpriteFrames(pzArr)
    animation:setDelayPerUnit(0.1)
    local animate = CCAnimate:create(animation)
    metalSp:setAnchorPoint(ccp(0.5, 0.5))
    if m_iconScaleX ~= nil then
        --metalSp:setScaleX(1/m_iconScaleX)
        metalSp:setScaleX(m_iconScaleX)
    end
    if m_iconScaleY ~= nil then
        --metalSp:setScaleY(1/m_iconScaleY)
        metalSp:setScaleY(m_iconScaleY)
    end
    --metalSp:setScale(1/50)
    metalSp:setPosition(ccp(icon:getContentSize().width / 2, icon:getContentSize().height / 2))
    icon:addChild(metalSp, 5)
    local repeatForever = CCRepeatForever:create(animate)
    metalSp:runAction(repeatForever)
end

function taskDialogTab2:updateShowTasks()
    self.showTasks = {}
    local isShowNew = taskVoApi:isShowNew()
    if isShowNew == true then
        local taskTb = {}
        local dailyTasks = taskVoApi:getDailyTasks()
        for k, v in pairs(dailyTasks) do
            local task, isNewDailyCfg = taskVoApi:getTaskFromCfg(v.sid, true)
            if isNewDailyCfg == true then
                local isSwitchOpen, isLvReached = true, true
                if task.switch and type(task.switch) == "string" then
                    isSwitchOpen = false
                    local arr = Split(task.switch, ",")
                    if arr and SizeOfTable(arr) > 0 then
                        for m, n in pairs(arr) do
                            if base[n] and base[n] == 1 then
                                isSwitchOpen = true
                            end
                        end
                    else
                        if base[task.switch] and base[task.switch] == 1 then
                            isSwitchOpen = true
                        end
                    end
                    if tostring(v.sid) == "1008" and FuncSwitchApi:isEnabled("hero_equip") == false then --将领装备探索的任务需要特殊处理（怀旧服不显示）
                    	isSwitchOpen = false
                    end
                end
                -- if task.needLv then
                -- isLvReached=false
                -- local playerLv=playerVoApi:getPlayerLevel()
                -- if playerLv>=task.needLv then
                -- isLvReached=true
                -- end
                -- end
                if isSwitchOpen == true and isLvReached == true then
                    table.insert(taskTb, v)
                end
            else
                table.insert(taskTb, v)
            end
        end
        self.showTasks = taskTb
        taskVoApi:dailyTaskSort(self.showTasks)
    else
        self.showTasks = taskVoApi:getDailyTypeTab(self.selectedTabIndex + 1)
    end
end

function taskDialogTab2:dispose()
    self.layerNum = nil
    
    self.cancelBtn = nil
    self.refreshBtn = nil
    self.resetBtn = nil
    self.resetCountLabel = nil
    
    self.timeTab = nil
    self.urgentTab = nil
    self.showTasks = nil
end
