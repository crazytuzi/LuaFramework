serverWarPersonalDialogTab2 = {}

function serverWarPersonalDialogTab2:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    
    nc.tv = nil
    nc.bgLayer = nil
    nc.layerNum = nil
    nc.selectedTabIndex = 0
    nc.serverWarDialog = nil
    
    nc.bgLayer0 = nil
    nc.bgLayer1 = nil
    nc.bgLayer2 = nil
    nc.bgLayer3 = nil
    
    nc.serverWarTanks1 = {{}, {}, {}, {}, {}, {}}
    nc.serverWarTanks2 = {{}, {}, {}, {}, {}, {}}
    nc.serverWarTanks3 = {{}, {}, {}, {}, {}, {}}
    
    nc.maskSp = nil
    nc.saveTimeLb = nil
    nc.leftTimeLb = nil
    nc.cannotSaveLb = nil
    
    nc.maxPowerBtn1 = nil
    nc.maxPowerBtn2 = nil
    nc.maxPowerBtn3 = nil
    
    nc.serverWarHero1 = {0, 0, 0, 0, 0, 0}
    nc.serverWarHero2 = {0, 0, 0, 0, 0, 0}
    nc.serverWarHero3 = {0, 0, 0, 0, 0, 0}
    nc.serverWarEmblem1 = nil
    nc.serverWarEmblem2 = nil
    nc.serverWarEmblem3 = nil
    nc.serverWarPlane1 = nil
    nc.serverWarPlane2 = nil
    nc.serverWarPlane3 = nil
    
    nc.currentShow = {1, 1, 1}
    nc.tipItem = nil
    
    nc.fleetIndexTab = {}
    nc.propertyIndexTab = {}
    nc.cellHeight = 170
    if G_isIphone5() == true then
        nc.cellHeight = 190
    end
    nc.touchArr = {}
    nc.multTouch = false
    nc.touchEnable = nil
    nc.isMoved = false
    nc.temSp = nil
    
    nc.tankSpTab = {}
    nc.tankBgTab = {}
    nc.lastStrategyTimeLb = nil
    
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/world_ground.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("worldWar/worldWar.plist")
    
    return nc
end

function serverWarPersonalDialogTab2:initTab(tabTb)
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
            
            local lb = GetTTFLabelWrap(v, 20, CCSizeMake(tabBtnItem:getContentSize().width, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
            lb:setPosition(CCPointMake(tabBtnItem:getContentSize().width / 2, tabBtnItem:getContentSize().height / 2))
            tabBtnItem:addChild(lb)
            lb:setTag(31)
            
            local numHeight = 25
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
            newsIcon:setPosition(ccp(tabBtnItem:getContentSize().width - 2, tabBtnItem:getContentSize().height - 30))
            newsIcon:addChild(newsNumLabel, 1)
            newsIcon:setTag(10)
            newsIcon:setVisible(false)
            tabBtnItem:addChild(newsIcon)
            
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
    self.bgLayer:addChild(tabBtn)
    
end

function serverWarPersonalDialogTab2:resetTab()
    -- self.allTabs={getlocal("world_war_sub_title21")}
    -- for i=1,3 do
    -- table.insert(self.allTabs,getlocal("serverwar_battle_num",{i}))
    -- end
    self.allTabs = {getlocal("world_war_sub_title21"), getlocal("world_war_sub_title22"), getlocal("world_war_sub_title23"), getlocal("world_war_sub_title24")}
    self:initTab(self.allTabs)
    local index = 0
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

function serverWarPersonalDialogTab2:init(layerNum, serverWarDialog)
    self.bgLayer = CCLayer:create()
    self.layerNum = layerNum
    self.serverWarDialog = serverWarDialog
    
    self:initTableView()
    self:resetTab()
    self:initTabLayer()
    self:doUserHandler()
    
    return self.bgLayer
end

--[[
function serverWarPersonalDialogTab2:getDataByType(type)
if type==nil then
type=1
end
local flag=emailVoApi:getFlag(type)
local function showEmailList(fn,data)
if base:checkServerData(data)==true then
      self:refresh()
end
end
if self.noEmailLabel then
self.noEmailLabel:setVisible(false)
end
if flag==nil or flag==-1 then
socketHelper:emailList(type,0,0,showEmailList,1)
else
self:refresh()
end
end
]]

--设置对话框里的tableView
function serverWarPersonalDialogTab2:initTableView()
    local function callBack(...)
        -- return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.bgLayer:getContentSize().width - 50, G_VisibleSizeHeight), nil)
    --self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    -- self.tv:setPosition(ccp(50,115))
    -- self.bgLayer:addChild(self.tv,1)
    -- self.tv:setMaxDisToBottomOrTop(self.normalHeight)
end

function serverWarPersonalDialogTab2:initTabLayer()
    --最后初始化第一场，给heroVoApi.troopsTb最后赋值为第一场的数据
    self:initTabLayer3()
    self:initTabLayer2()
    self:initTabLayer1()
    self:initTabLayer0()
    
    self:initSaveBtn()
    self:switchTab()
end

function serverWarPersonalDialogTab2:initTabLayer0()
    self.bgLayer0 = CCLayer:create()
    self.bgLayer:addChild(self.bgLayer0, 2)
    
    self.tankSpTab = {}
    self.tankBgTab = {}
    
    self:updateData()
    self:initHead()
    self:initTableView0()
    
    local strategyTime = serverWarPersonalVoApi:getLastSetStrategyTime()
    local leftTime = strategyTime + 60 - base.serverTime
    local saveTimeStr = ""
    if leftTime > 0 then
        saveTimeStr = getlocal("world_war_save_left_time", {GetTimeForItemStr(leftTime)})
    else
        saveTimeStr = getlocal("world_war_save_left_time", {GetTimeForItemStr(0)})
    end
    -- saveTimeStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    self.lastStrategyTimeLb = GetTTFLabelWrap(saveTimeStr, 25, CCSizeMake(380, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
    self.lastStrategyTimeLb:setAnchorPoint(ccp(0, 0.5))
    self.lastStrategyTimeLb:setPosition(ccp(30, 70))
    self.bgLayer:addChild(self.lastStrategyTimeLb, 2)
    self.lastStrategyTimeLb:setColor(G_ColorYellowPro)
    if leftTime > 0 then
    else
        self.lastStrategyTimeLb:setVisible(false)
    end
    
    self.clayer = CCLayer:create()
    self.clayer:setPosition(ccp(0, 0))
    self.bgLayer:addChild(self.clayer, 8)
    self.clayer:setTouchEnabled(true)
    local function tmpHandler(...)
        return self:touchEvent(...)
    end
    self.clayer:registerScriptTouchHandler(tmpHandler, false, -(self.layerNum - 1) * 20 - 4, false)
    self.touchEnable = true
end
function serverWarPersonalDialogTab2:touchEvent(fn, x, y, touch)
    if fn == "began" then
        -- if self.touchEnable==false or SizeOfTable(self.touchArr)>=2 or newGuidMgr:isNewGuiding()==true then
        if self.touchEnable == false or newGuidMgr:isNewGuiding() == true then
            return 0
        end
        self.isMoved = false
        self.touchArr[touch] = touch
        
        if SizeOfTable(self.touchArr) > 1 then
            -- self.multTouch=true
            
            if self.temSp then
                self.temSp:removeFromParentAndCleanup(true)
                self.temSp = nil
            end
        else
            -- self.multTouch=false
            
            local curPos = CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
            -- print("x,y-----",curPos.x,curPos.y)
            self.index = 0
            self.selectType = 0
            local bx, by = self.tv0:getPosition()
            -- for k,v in pairs(self.iconTab) do
            --     local ix,iy=v:getPosition()
            --     local cx,cy=ix+bx,iy+by
            --     local w,h=v:getContentSize().width/2,v:getContentSize().height/2
            --     if curPos.x>=cx-w and curPos.x<=cx+w and curPos.y>=cy-h and curPos.y<=cy+h then
            --         self.index=k
            --         self.selectType=1
            --     end
            -- end
            local tSize = 100
            if self.tankBgTab then
                for k, v in pairs(self.tankBgTab) do
                    if self.tankSpTab and self.tankSpTab[k] then
                        local ix, iy = v:getPosition()
                        -- local cx,cy=ix+bx,iy+by+(3-k)*self.cellHeight
                        local cx, cy = ix + bx, iy + by + G_VisibleSizeHeight - 450 - k * self.cellHeight
                        -- print("cx,cy~~~~",cx,cy)
                        local w, h = tSize / 2, tSize / 2
                        if curPos.x >= cx - w and curPos.x <= cx + w and curPos.y >= cy - h and curPos.y <= cy + h then
                            self.index = k
                            self.selectType = 2
                        end
                    end
                end
            end
            -- print("self.index,self.selectType",self.index,self.selectType)
            if self.index > 0 and self.selectType > 0 and self.temSp == nil then
                -- if self.selectType==1 then
                --     local idx=self.propertyIndexTab[self.index]
                --     local icon=CCSprite:createWithSpriteFrameName("ww_tactics_"..idx..".png")
                --     self.temSp=CCSprite:createWithSpriteFrameName("ww_tactics_bg.png")
                --     icon:setPosition(getCenterPoint(self.temSp))
                --     self.temSp:addChild(icon,2)
                --     self.temSp:setScale(0.9)
                -- else
                -- print("self.tankSpTab[self.index]",self.tankSpTab[self.index])
                if self.tankSpTab and self.tankSpTab[self.index] then
                    local tankId = tankVoApi:getFirstTankIdByIndex(self.index, self.fleetIndexTab)
                    if tankId then
                        local tid = (tonumber(tankId) or tonumber(RemoveFirstChar(tankId)))
                        if tid and tankCfg[tid] then
                            local tskinTb = tankSkinVoApi:getTankSkinListByBattleType(self.index + 6) or {}
                            local skinId = tskinTb[tankSkinVoApi:convertTankId(tid)]
                            self.temSp = tankVoApi:getTankIconSp(tid, skinId, nil, false) --CCSprite:createWithSpriteFrameName(tankCfg[tid].icon)
                            self.temSp:setScale(tSize / self.temSp:getContentSize().width)
                        end
                    end
                end
                -- end
                if self.temSp then
                    self.temSp:setAnchorPoint(ccp(0.5, 0.5))
                    self.temSp:setPosition(curPos)
                    self.temSp:setOpacity(150)
                    self.clayer:addChild(self.temSp, 2)
                    -- self.bgLayer:addChild(self.temSp,2)
                    self.touch = touch
                    
                    -- self.iconTab[self.index]:setVisible(false)
                end
            end
        end
        
        return 1
    elseif fn == "moved" then
        if self.touchEnable == false or newGuidMgr:isNewGuiding() == true then
            do
                return
            end
        end
        self.isMoved = true
        -- if self.multTouch==true then --双点触摸
        
        -- else --单点触摸
        if self.touch and self.touch == touch then
            local curPos = CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
            -- print("curPos--x,y:",curPos.x,curPos.y)
            if self.temSp then
                self.temSp:setPosition(curPos)
            end
        end
    elseif fn == "ended" then
        if self.touchEnable == false or newGuidMgr:isNewGuiding() == true then
            do
                return
            end
        end
        if self.touch and self.touch == touch then
            if self.temSp then
                self.temSp:removeFromParentAndCleanup(true)
                self.temSp = nil
            end
            
            local curPos = CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
            local targetIndex = 0
            local bx, by = self.tv0:getPosition()
            -- if self.selectType and self.selectType==1 then
            --     for k,v in pairs(self.iconTab) do
            --         -- v:setVisible(true)
            --         local ix,iy=v:getPosition()
            --         local cx,cy=ix+bx,iy+by
            --         local w,h=v:getContentSize().width/2,v:getContentSize().height/2
            --         if curPos.x>=cx-w and curPos.x<=cx+w and curPos.y>=cy-h and curPos.y<=cy+h then
            --             targetIndex=k
            --         end
            --     end
            -- elseif self.selectType and self.selectType==2 then
            if self.selectType and self.selectType == 2 then
                local tSize = 100
                if self.tankBgTab then
                    for k, v in pairs(self.tankBgTab) do
                        local ix, iy = v:getPosition()
                        -- local cx,cy=ix+bx,iy+by+(3-k)*self.cellHeight
                        local cx, cy = ix + bx, iy + by + G_VisibleSizeHeight - 450 - k * self.cellHeight
                        local w, h = tSize / 2, tSize / 2
                        if curPos.x >= cx - w and curPos.x <= cx + w and curPos.y >= cy - h and curPos.y <= cy + h then
                            targetIndex = k
                        end
                    end
                end
            end
            if targetIndex > 0 and self.index and self.index > 0 and targetIndex ~= self.index then
                -- if self.selectType and self.selectType==1 then
                --     worldWarVoApi:setPropertyIndex(self.index,targetIndex,self.propertyIndexTab)
                --     self:updateProperty()
                -- elseif self.selectType and self.selectType==2 then
                tankVoApi:setServerWarFleetIndex(self.index, targetIndex, self.fleetIndexTab)
                self:refresh()
                -- end
            end
        end
        if self.touchArr[touch] ~= nil then
            self.touchArr[touch] = nil
        end
    else
        self.touchArr = nil
        self.touchArr = {}
    end
end
function serverWarPersonalDialogTab2:refresh()
    self.tankSpTab = {}
    self.tankBgTab = {}
    if self.tv0 then
        self.tv0:reloadData()
    end
end
function serverWarPersonalDialogTab2:updateData()
    self.fleetIndexTab = G_clone(tankVoApi:getServerWarFleetIndexTb())
    -- self.propertyIndexTab=G_clone(serverWarPersonalVoApi:getPropertyIndexTab())
end
function serverWarPersonalDialogTab2:initHead()
    local desc1 = getlocal("serverwar_troops_landform1")
    -- desc1="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    local descLb1 = GetTTFLabelWrap(desc1, 25, CCSizeMake(350, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
    descLb1:setAnchorPoint(ccp(0, 0.5))
    descLb1:setPosition(ccp(30, G_VisibleSizeHeight - 260 + 25))
    self.bgLayer0:addChild(descLb1, 1)
    
    local desc2 = getlocal("serverwar_troops_landform2")
    -- desc2="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    local descLb2 = GetTTFLabelWrap(desc2, 25, CCSizeMake(350, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
    descLb2:setAnchorPoint(ccp(0, 0.5))
    descLb2:setPosition(ccp(30, G_VisibleSizeHeight - 260 - 25))
    self.bgLayer0:addChild(descLb2, 1)
    
    local lineSp = CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setScale((G_VisibleSizeWidth - 60) / lineSp:getContentSize().width)
    lineSp:setPosition(ccp(G_VisibleSizeWidth / 2 - 20, G_VisibleSizeHeight - 315))
    self.bgLayer0:addChild(lineSp, 1)
end
function serverWarPersonalDialogTab2:initTableView0()
    self.tankBgTab = {}
    local function callBack(...)
        return self:eventHandler0(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv0 = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.bgLayer:getContentSize().width - 60, G_VisibleSizeHeight - 450), nil)
    self.bgLayer0:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    self.tv0:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 1)
    self.tv0:setPosition(ccp(30, 120))
    self.bgLayer0:addChild(self.tv0, 2)
    self.tv0:setMaxDisToBottomOrTop(0)
end
function serverWarPersonalDialogTab2:eventHandler0(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return 3
    elseif fn == "tableCellSizeForIndex" then
        local tmpSize = CCSizeMake(self.bgLayer:getContentSize().width - 60, self.cellHeight)
        return tmpSize
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        local cellWidth = self.bgLayer:getContentSize().width - 60
        local cellHeight = self.cellHeight
        
        local titleHeight = cellHeight - 130--cellHeight/170*40
        local titleLb = GetTTFLabel(getlocal("serverwar_battle_num", {idx + 1}), 28)
        titleLb:setPosition(ccp(cellWidth / 2, cellHeight - titleHeight / 2))
        cell:addChild(titleLb, 1)
        titleLb:setColor(G_ColorYellowPro)
        
        local rect = CCRect(0, 0, 50, 50)
        local capInSet = CCRect(20, 20, 10, 10)
        local function cellClick(hd, fn, idx)
        end
        local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png", capInSet, cellClick)
        backSprie:setContentSize(CCSizeMake(cellWidth, cellHeight - titleHeight))
        backSprie:ignoreAnchorPointForPosition(false)
        backSprie:setAnchorPoint(ccp(0.5, 0))
        backSprie:setIsSallow(false)
        backSprie:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
        backSprie:setPosition(ccp(cellWidth / 2, 0))
        cell:addChild(backSprie, 1)
        
        local posx = 80
        local isHasBattle, battleVo = serverWarPersonalVoApi:checkPlayerHasBattle()
        local landType
        if isHasBattle == true and battleVo and battleVo.landformTb and battleVo.landformTb[idx + 1] then
            landType = tonumber(battleVo.landformTb[idx + 1])
        end
        local teSp
        local teName
        if landType and landType ~= 0 then
            teSp = CCSprite:createWithSpriteFrameName("world_ground_"..landType..".png")
            teName = getlocal("world_ground_name_"..landType)
        else
            teSp = CCSprite:createWithSpriteFrameName("ww_landType_0.png")
            teName = getlocal("world_war_landType_unknow")
            
            local questionMarkSp = CCSprite:createWithSpriteFrameName("questionMark.png")
            questionMarkSp:setPosition(getCenterPoint(teSp))
            teSp:addChild(questionMarkSp, 1)
        end
        teSp:setScale(1.3)
        teSp:setPosition(ccp(posx, backSprie:getContentSize().height / 2 + 10))
        backSprie:addChild(teSp, 2)
        
        local teNameLb = GetTTFLabel(teName, 20)
        teNameLb:setAnchorPoint(ccp(0.5, 0.5))
        teNameLb:setPosition(ccp(posx, 25))
        backSprie:addChild(teNameLb, 2)
        teNameLb:setColor(G_ColorYellowPro)
        
        local function clickHandler()
        end
        local tSize = 100
        local tankBg = LuaCCSprite:createWithSpriteFrameName("Icon_BG.png", clickHandler)
        tankBg:setScale(tSize / tankBg:getContentSize().width)
        -- tankBg:setPosition(ccp(posx,bottomSpace+lineHeight/2-tSize/2-10))
        tankBg:setPosition(ccp(cellWidth - posx, backSprie:getContentSize().height / 2))
        tankBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
        tankBg:setIsSallow(false)
        cell:addChild(tankBg, 2)
        table.insert(self.tankBgTab, tankBg)
        local addSp = CCSprite:createWithSpriteFrameName("ProduceTankIconMore.png")
        addSp:setPosition(getCenterPoint(tankBg))
        tankBg:addChild(addSp)
        addSp:setScale(1.5)
        
        local function nilFunc()
        end
        local tankId = tankVoApi:getFirstTankIdByIndex(idx + 1, self.fleetIndexTab)
        -- print("tankId",tankId)
        if tankId then
            local tid = (tonumber(tankId) or tonumber(RemoveFirstChar(tankId)))
            if tid and tankCfg[tid] then
                local fleetIndex = self.fleetIndexTab[idx + 1]
                local tskinTb = tankSkinVoApi:getTankSkinListByBattleType(fleetIndex + 6)
                local skinId = tskinTb[tankSkinVoApi:convertTankId(tid)]
                local tankSp = tankVoApi:getTankIconSp(tid, skinId, nilFunc, false)--LuaCCSprite:createWithSpriteFrameName(tankCfg[tid].icon,nilFunc)
                tankSp:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
                tankSp:setIsSallow(false)
                tankSp:setScale(tankBg:getContentSize().width / tankSp:getContentSize().width)
                tankSp:setPosition(getCenterPoint(tankBg))
                tankBg:addChild(tankSp, 2)
                self.tankSpTab[idx + 1] = tankSp
            end
            if self.fleetIndexTab and self.fleetIndexTab[idx + 1] then
                local fleetIndex = self.fleetIndexTab[idx + 1]
                local function nilFunc()
                end
                local numSp = LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png", CCRect(17, 17, 1, 1), nilFunc)
                numSp:setScale(0.8)
                numSp:setPosition(ccp(tankBg:getContentSize().width / 2, 5))
                tankBg:addChild(numSp, 4)
                local numLb = GetTTFLabel(fleetIndex, 25)
                numLb:setAnchorPoint(ccp(0.5, 0.5))
                numLb:setPosition(getCenterPoint(numSp))
                numSp:addChild(numLb, 1)
            end
        end
        
        local effectStr = getlocal("serverwar_effect_unkown")
        local color = G_ColorWhite
        if landType and landType ~= 0 and worldGroundCfg[landType] then
            local attackCfg = worldGroundCfg[landType]
            for k, v in pairs(attackCfg.attType) do
                -- local valueStr=G_getPropertyStr(v)
                local valueStr = getlocal("world_ground_effect_"..v)
                local color
                if(attackCfg.attValue[k] > 0)then
                    valueStr = valueStr.."+"..attackCfg.attValue[k] .. "%"
                    color = G_ColorGreen
                else
                    valueStr = valueStr..attackCfg.attValue[k] .. "%"
                    color = G_ColorRed
                end
                local effectLb = GetTTFLabel(valueStr, 25)
                effectLb:setColor(color)
                effectLb:setPosition(ccp(cellWidth / 2, backSprie:getContentSize().height / 2 - (k - 2) * 35))
                cell:addChild(effectLb, 2)
            end
        else
            local effectLb = GetTTFLabel(effectStr, 25)
            effectLb:setColor(color)
            effectLb:setPosition(ccp(cellWidth / 2, backSprie:getContentSize().height / 2))
            cell:addChild(effectLb, 2)
        end
        
        local capInSet1 = CCRect(9, 6, 1, 1)
        local function touchClick(hd, fn, idx)
        end
        local arrowSp1 = LuaCCScale9Sprite:createWithSpriteFrameName("heroArrowRight.png", capInSet1, touchClick)
        arrowSp1:setContentSize(CCSizeMake(250, 16))
        arrowSp1:setAnchorPoint(ccp(0.5, 0.5))
        arrowSp1:setPosition(ccp(cellWidth / 2, backSprie:getContentSize().height / 4))
        arrowSp1:setIsSallow(false)
        arrowSp1:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
        cell:addChild(arrowSp1, 2)
        
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

function serverWarPersonalDialogTab2:initTabLayer1()
    self.bgLayer1 = CCLayer:create()
    self.bgLayer:addChild(self.bgLayer1, 2)
    
    local function callback(flag)
        if self.selectedTabIndex > 0 then
            self.currentShow[self.selectedTabIndex] = flag + 1
        end
    end
    local btype = 7
    self.serverWarTanks1 = G_clone(tankVoApi:getTanksTbByType(btype))
    self.maxPowerBtn1 = G_addSelectTankLayer(btype, self.bgLayer1, self.layerNum, callback)
    -- self:initTanks(self.bgLayer1)
    self.serverWarHero1 = G_clone(heroVoApi:getServerWarHeroList(1))
    self.serverWarAITroops1 = G_clone(AITroopsFleetVoApi:getServerWarAITroopsList(1))
    self.serverWarEmblem1 = emblemVoApi:getBattleEquip(btype)
    self.serverWarPlane1 = planeVoApi:getBattleEquip(btype)
    self.serverWarAirship1 = airShipVoApi:getBattleEquip(btype)
end

function serverWarPersonalDialogTab2:initTabLayer2()
    self.bgLayer2 = CCLayer:create()
    self.bgLayer:addChild(self.bgLayer2, 2)
    
    local function callback(flag)
        if self.selectedTabIndex > 0 then
            self.currentShow[self.selectedTabIndex] = flag + 1
        end
    end
    local btype = 8
    self.serverWarTanks2 = G_clone(tankVoApi:getTanksTbByType(btype))
    self.maxPowerBtn2 = G_addSelectTankLayer(btype, self.bgLayer2, self.layerNum, callback)
    -- self:initTanks(self.bgLayer2)
    self.serverWarHero2 = G_clone(heroVoApi:getServerWarHeroList(2))
    self.serverWarAITroops2 = G_clone(AITroopsFleetVoApi:getServerWarAITroopsList(2))
    self.serverWarEmblem2 = emblemVoApi:getBattleEquip(btype)
    self.serverWarPlane2 = planeVoApi:getBattleEquip(btype)
    self.serverWarAirship2 = airShipVoApi:getBattleEquip(btype)
end

function serverWarPersonalDialogTab2:initTabLayer3()
    self.bgLayer3 = CCLayer:create()
    self.bgLayer:addChild(self.bgLayer3, 2)
    
    local function callback(flag)
        if self.selectedTabIndex > 0 then
            self.currentShow[self.selectedTabIndex] = flag + 1
        end
    end
    local btype = 9
    self.serverWarTanks3 = G_clone(tankVoApi:getTanksTbByType(btype))
    self.maxPowerBtn3 = G_addSelectTankLayer(btype, self.bgLayer3, self.layerNum, callback)
    -- self:initTanks(self.bgLayer3)
    self.serverWarHero3 = G_clone(heroVoApi:getServerWarHeroList(3))
    self.serverWarAITroops3 = G_clone(AITroopsFleetVoApi:getServerWarAITroopsList(3))
    self.serverWarEmblem3 = emblemVoApi:getBattleEquip(btype)
    self.serverWarPlane3 = planeVoApi:getBattleEquip(btype)
    self.serverWarAirship3 = airShipVoApi:getBattleEquip(btype)
end

function serverWarPersonalDialogTab2:initSaveBtn()
    local function save()
        if G_checkClickEnable() == false then
            do
                return
            end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        
        local function saveStrategyCallback(fn, data)
            local ret, sData = base:checkServerData(data)
            if ret == true then
                tankVoApi:setServerWarFleetIndexTb(G_clone(self.fleetIndexTab))
                serverWarPersonalVoApi:setLastSetStrategyTime(base.serverTime)
                self:tick()
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("save_success"), 30)
            end
        end
        if self.selectedTabIndex == 0 then
            local strategyTime = serverWarPersonalVoApi:getLastSetStrategyTime()
            if base.serverTime > strategyTime + 60 then
                local isSet = tankVoApi:serverWarIsSetFleet()
                if isSet == true then
                    socketHelper:serverWarSetline(self.fleetIndexTab, saveStrategyCallback)
                else
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("local_war_cantMove0"), 30)
                end
            end
            do return end
        end
        local lastTime = serverWarPersonalVoApi:getLastSetFleetTime(self.selectedTabIndex)
        if lastTime then
            local leftTime = serverWarPersonalCfg.settingTroopsLimit - (base.serverTime - lastTime)
            if leftTime > 0 then
                do return end
            end
        end
        
        local isEable = true
        local num = 0;
        local type = 7
        if self.selectedTabIndex == 1 then
            type = 7
        elseif self.selectedTabIndex == 2 then
            type = 8
        elseif self.selectedTabIndex == 3 then
            type = 9
        end
        for k, v in pairs(tankVoApi:getTanksTbByType(type)) do
            if SizeOfTable(v) == 0 then
                num = num + 1;
            end
        end
        if num == 6 then
            isEable = false
        end
        if isEable == false then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("allianceWarNoArmy"), nil, self.layerNum + 1, nil)
            do return end
        end
        
        -- --检测军徽是否被分解
        -- local list=emblemVoApi:getEquipList()
        -- local cannotSetIndex=0
        -- local hasSetTb={}
        -- for i=1,3 do
        --     local emblemID1=emblemVoApi:getBattleEquip(i+6)
        --     -- print("i,self.selectedTabIndex",i,self.selectedTabIndex)
        --     if self.selectedTabIndex==i then
        --         emblemID1=emblemVoApi:getTmpEquip(i+6)
        --     end
        --     -- print("emblemID1",emblemID1)
        --     if emblemID1 then
        --         local isCanSet=false
        --         for k,v in pairs(list) do
        --             if v and v.id==emblemID1 then
        --                 if hasSetTb and hasSetTb[v.id] then
        --                     hasSetTb[v.id]=hasSetTb[v.id]+1
        --                     if v.num>0 and v.num>=hasSetTb[v.id] then
        --                         isCanSet=true
        --                     end
        --                 else
        --                     hasSetTb[v.id]=1
        --                     if v.num>0 then
        --                         isCanSet=true
        --                     end
        --                 end
        --             end
        --         end
        --         if isCanSet==false then
        --             cannotSetIndex=i
        --         end
        --     end
        -- end
        -- if cannotSetIndex~=0 then
        --     local function confirmCallBackHandler()
        --         if G_checkClickEnable()==false then
        --             do
        --                 return
        --             end
        --         else
        --             base.setWaitTime=G_getCurDeviceMillTime()
        --         end
        --         PlayEffect(audioCfg.mouseClick)
        
        --         self:clearAllTroops()
        --     end
        --     smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),confirmCallBackHandler,getlocal("dialog_title_prompt"),getlocal("emblem_serverwar_not_exist",{getlocal("world_war_sub_title2"..(cannotSetIndex+1))}),nil,self.layerNum+1)
        --     do return end
        -- end
        
        -- if self:judgeFight() then
        --     do
        --         return
        --     end
        -- end
        
        local fleetInfo = tankVoApi:getTanksTbByType(self.selectedTabIndex + 6)
        local hero = nil
        print("heroVoApi:isHaveTroops()", heroVoApi:isHaveTroops())
        if heroVoApi:isHaveTroops() == true then
            -- local heroList=heroVoApi:getServerWarHeroList(self.selectedTabIndex)
            local heroList = heroVoApi:getTroopsHeroList()
            hero = heroVoApi:getBindFleetHeroList(heroList, fleetInfo, self.selectedTabIndex + 6)
        end
        local tmpTroopsTb = AITroopsFleetVoApi:getAITroopsTb()
        local AITroopsTb = AITroopsFleetVoApi:getBindFleetAITroopsList(tmpTroopsTb, fleetInfo, self.selectedTabIndex + 6)
        local function callback(fn, data)
            local ret, sData = base:checkServerData(data)
            if ret == true then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("save_success"), 30)
                local heroList = {0, 0, 0, 0, 0, 0}
                if hero then
                    heroList = hero
                end
                local btype
                if self.selectedTabIndex == 1 then
                    btype = 7
                    self.serverWarTanks1 = G_clone(tankVoApi:getTanksTbByType(btype))
                    
                    local tskin = G_clone(tankSkinVoApi:getTempTankSkinList(btype))
                    tankSkinVoApi:setTankSkinListByBattleType(btype, tskin)
                    
                    heroVoApi:setServerWarHeroList(1, heroList)
                    AITroopsFleetVoApi:setServerWarAITroopsList(1, AITroopsTb)
                    self.serverWarHero1 = G_clone(heroVoApi:getServerWarHeroList(1))
                    self.serverWarAITroops1 = G_clone(AITroopsFleetVoApi:getServerWarAITroopsList(1))
                    local emblemID = emblemVoApi:getTmpEquip(btype)
                    emblemVoApi:setBattleEquip(btype, emblemID)
                    self.serverWarEmblem1 = emblemID
                    local planePos = planeVoApi:getTmpEquip(btype)
                    planeVoApi:setBattleEquip(btype, planePos)
                    self.serverWarPlane1 = planePos
                    local airshipId = airShipVoApi:getTempLineupId(btype)
                    airShipVoApi:setBattleEquip(btype, airshipId)
                    self.serverWarAirship1 = airshipId
                elseif self.selectedTabIndex == 2 then
                    btype = 8
                    self.serverWarTanks2 = G_clone(tankVoApi:getTanksTbByType(btype))
                    
                    local tskin = G_clone(tankSkinVoApi:getTempTankSkinList(btype))
                    tankSkinVoApi:setTankSkinListByBattleType(btype, tskin)
                    
                    heroVoApi:setServerWarHeroList(2, heroList)
                    AITroopsFleetVoApi:setServerWarAITroopsList(2, AITroopsTb)
                    self.serverWarHero2 = G_clone(heroVoApi:getServerWarHeroList(2))
                    self.serverWarAITroops2 = G_clone(AITroopsFleetVoApi:getServerWarAITroopsList(2))
                    local emblemID = emblemVoApi:getTmpEquip(btype)
                    emblemVoApi:setBattleEquip(btype, emblemID)
                    self.serverWarEmblem2 = emblemID
                    local planePos = planeVoApi:getTmpEquip(btype)
                    planeVoApi:setBattleEquip(btype, planePos)
                    self.serverWarPlane2 = planePos
                    local airshipId = airShipVoApi:getTempLineupId(btype)
                    airShipVoApi:setBattleEquip(btype, airshipId)
                    self.serverWarAirship2 = airshipId
                elseif self.selectedTabIndex == 3 then
                    btype = 9
                    self.serverWarTanks3 = G_clone(tankVoApi:getTanksTbByType(btype))
                    
                    local tskin = G_clone(tankSkinVoApi:getTempTankSkinList(btype))
                    tankSkinVoApi:setTankSkinListByBattleType(btype, tskin)
                    
                    heroVoApi:setServerWarHeroList(3, heroList)
                    AITroopsFleetVoApi:setServerWarAITroopsList(3, AITroopsTb)
                    self.serverWarHero3 = G_clone(heroVoApi:getServerWarHeroList(3))
                    self.serverWarAITroops3 = G_clone(AITroopsFleetVoApi:getServerWarAITroopsList(3))
                    local emblemID = emblemVoApi:getTmpEquip(btype)
                    emblemVoApi:setBattleEquip(btype, emblemID)
                    self.serverWarEmblem3 = emblemID
                    local planePos = planeVoApi:getTmpEquip(btype)
                    planeVoApi:setBattleEquip(btype, planePos)
                    self.serverWarPlane3 = planePos
                    local airshipId = airShipVoApi:getTempLineupId(btype)
                    airShipVoApi:setBattleEquip(btype, airshipId)
                    self.serverWarAirship3 = airshipId
                end
                serverWarPersonalVoApi:setLastSetFleetTime(self.selectedTabIndex, base.serverTime)
                self:tick()
            elseif sData.ret == -5015 then
                local function sureCallBackHandler()
                    if G_checkClickEnable() == false then
                        do
                            return
                        end
                    else
                        base.setWaitTime = G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)
                    
                    self:clearAllTroops()
                end
                smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), sureCallBackHandler, getlocal("dialog_title_prompt"), getlocal("backstage5015"), nil, self.layerNum + 1)
            end
        end
        local aName
        if allianceVoApi:isHasAlliance() then
            local selfAlliance = allianceVoApi:getSelfAlliance()
            if selfAlliance and selfAlliance.name then
                aName = selfAlliance.name
            end
        end
        local emblemID = emblemVoApi:getTmpEquip(self.selectedTabIndex + 6)
        emblemID = emblemVoApi:getEquipIdForBattle(emblemID)
        local planePos = planeVoApi:getTmpEquip(self.selectedTabIndex + 6)
        local airshipId = airShipVoApi:getTempLineupId(self.selectedTabIndex + 6)
        if emblemID ~= -1 then
            socketHelper:crossSetInfo(self.selectedTabIndex, fleetInfo, aName, hero, nil, callback, emblemID, planePos, AITroopsTb, airshipId)
        end
    end
    self.saveBtn = GetButtonItem("BtnOkSmall.png", "BtnOkSmall_Down.png", "BtnCancleSmall.png", save, nil, getlocal("arena_save"), 25)
    local saveMenu = CCMenu:createWithItem(self.saveBtn)
    saveMenu:setPosition(ccp(520, 70))
    saveMenu:setTouchPriority((-(self.layerNum - 1) * 20 - 4))
    self.bgLayer:addChild(saveMenu, 3)
    
    -- local saveTimeStr=getlocal("serverwar_left_save_time")
    -- -- saveTimeStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    -- self.saveTimeLb=GetTTFLabelWrap(saveTimeStr,25,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
    -- self.saveTimeLb:setAnchorPoint(ccp(0.5,0))
    -- self.saveTimeLb:setPosition(ccp(520,150))
    -- self.bgLayer:addChild(self.saveTimeLb,3)
    -- self.saveTimeLb:setVisible(false)
    
    self.leftTimeLb = GetTTFLabel("0", 25)
    self.leftTimeLb:setAnchorPoint(ccp(0.5, 0))
    self.leftTimeLb:setPosition(ccp(520, 120))
    self.bgLayer:addChild(self.leftTimeLb, 3)
    self.leftTimeLb:setColor(G_ColorYellowPro)
    self.leftTimeLb:setVisible(false)
    
    -- if self.selectedTabIndex and self.selectedTabIndex>0 then
    local lastTime = serverWarPersonalVoApi:getLastSetFleetTime(self.selectedTabIndex)
    if lastTime then
        local leftTime = serverWarPersonalCfg.settingTroopsLimit - (base.serverTime - lastTime)
        if leftTime > 0 then
            self.saveBtn:setEnabled(false)
            
            -- self.saveTimeLb:setVisible(true)
            self.leftTimeLb:setVisible(true)
            self.leftTimeLb:setString(GetTimeForItemStr(leftTime))
        end
    end
    -- end
end
function serverWarPersonalDialogTab2:clearAllTroops()
    local function clearSetFleetHandler(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            for k = 1, 3 do
                self["serverWarTanks"..k] = {{}, {}, {}, {}, {}, {}}
            end
            for k = 1, 3 do
                self["serverWarHero"..k] = {0, 0, 0, 0, 0, 0}
            end
            for i = 1, 3 do
                self["serverWarAITroops"..k] = {0, 0, 0, 0, 0, 0}
            end
            for k = 1, 3 do
                self["serverWarEmblem"..k] = nil
            end
            for k = 1, 3 do
                self["serverWarPlane"..k] = nil
            end
            for k = 1, 3 do
                self["serverWarAirship"..k] = nil
            end
            self:setTanksRestore()
            for i = 1, 3 do
                if self["bgLayer"..i] then
                    G_updateSelectTankLayer(i + 6, self["bgLayer"..i], self.layerNum, self.currentShow[i])
                end
            end
        end
    end
    socketHelper:crossSetInfo(nil, nil, nil, nil, 1, clearSetFleetHandler)
end

-- function serverWarPersonalDialogTab2:judgeFight()
--     local bestTab2={}
--     local allfight1=0
--     local allfight2=0
--     for k,v in pairs(self.arenaTanks) do
--         if SizeOfTable(v)>0 then
--             local fight=tankVoApi:getBestTanksFighting(v[1],v[2])
--             allfight1=allfight1+fight
--         end
--     end
--     for k,v in pairs(tankVoApi:getDeArenaTanks()) do
--         if SizeOfTable(v)>0 then
--             local fight=tankVoApi:getBestTanksFighting(v[1],v[2])
--             allfight2=allfight2+fight
--         end
--     end
--     local isLow = false

--     if allfight1>allfight2 then

--         local function gosave()
--             local function callback(fn,data)
--             if base:checkServerData(data)==true then
--                 smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("arena_saveOk"),30)

--             end
--         end

--         socketHelper:militarySettroops(tankVoApi:getDeArenaTanks(),callback)
--         end
--         smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),gosave,getlocal("dialog_title_prompt"),getlocal("arena_powerLow"),nil,self.layerNum+1)
--         isLow = true

--     end

--     return isLow

-- end

function serverWarPersonalDialogTab2:tabClick(idx)
    
    PlayEffect(audioCfg.mouseClick)
    
    for k, v in pairs(self.allTabs) do
        if v:getTag() == idx then
            v:setEnabled(false)
            self.selectedTabIndex = idx
        else
            v:setEnabled(true)
        end
    end
    
    self:switchTab(self.selectedTabIndex)
    
    heroVoApi:clearTroops()
    AITroopsFleetVoApi:clearAITroops()
    self:setTanksRestore()
    if self.selectedTabIndex > 0 then
        G_updateSelectTankLayer(self.selectedTabIndex + 6, self["bgLayer" .. (self.selectedTabIndex)], self.layerNum, self.currentShow[self.selectedTabIndex])
    end
    self:tick()
end

function serverWarPersonalDialogTab2:switchTab(type)
    if type == nil then
        type = 0
    end
    for i = 0, 3 do
        if(i == type)then
            if(self["bgLayer"..i] ~= nil)then
                self["bgLayer"..i]:setPosition(ccp(0, 0))
                self["bgLayer"..i]:setVisible(true)
            end
            if type == 0 then
                -- if self.saveBtn then
                --     self.saveBtn:setEnabled(false)
                --     self.saveBtn:setVisible(false)
                -- end
                -- if self.saveTimeLb then
                --     self.saveTimeLb:setVisible(false)
                -- end
                if self.leftTimeLb then
                    self.leftTimeLb:setVisible(false)
                end
                if self.tipItem then
                    self.tipItem:setEnabled(true)
                    self.tipItem:setVisible(true)
                end
                self:setTanksRestore()
                self:updateData()
                self:refresh()
            else
                if self.saveBtn then
                    self.saveBtn:setVisible(true)
                end
                local lastTime = serverWarPersonalVoApi:getLastSetFleetTime(type)
                if lastTime then
                    local leftTime = serverWarPersonalCfg.settingTroopsLimit - (base.serverTime - lastTime)
                    if leftTime > 0 then
                        if self.saveBtn then
                            self.saveBtn:setEnabled(false)
                        end
                        -- if self.saveTimeLb then
                        --     self.saveTimeLb:setVisible(true)
                        -- end
                        if self.leftTimeLb then
                            self.leftTimeLb:setVisible(true)
                            self.leftTimeLb:setString(GetTimeForItemStr(leftTime))
                        end
                    end
                end
                if self.tipItem then
                    self.tipItem:setEnabled(false)
                    self.tipItem:setVisible(false)
                end
            end
        else
            if(self["bgLayer"..i] ~= nil)then
                self["bgLayer"..i]:setPosition(ccp(999333, 0))
                self["bgLayer"..i]:setVisible(false)
            end
        end
    end
    if type == 0 then
        self.touchEnable = true
    else
        self.touchEnable = false
    end
end

function serverWarPersonalDialogTab2:doUserHandler()
    local function tipTouch()
        if G_checkClickEnable() == false then
            do
                return
            end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local sd = smallDialog:new()
        local dialogLayer = sd:init("TankInforPanel.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, true, true, self.layerNum + 1, {" ", getlocal("serverwar_tanks_tip5"), " ", getlocal("serverwar_tanks_tip4"), " ", getlocal("serverwar_tanks_tip3"), " ", getlocal("serverwar_tanks_tip2", {math.floor(serverWarPersonalCfg.betTime / 60)}), " ", getlocal("serverwar_tanks_tip1"), " "}, 25, {nil, G_ColorYellow, nil, G_ColorYellow, nil, G_ColorYellow, nil, G_ColorYellow, nil, G_ColorYellow, nil})
        sceneGame:addChild(dialogLayer, self.layerNum + 1)
        dialogLayer:setPosition(ccp(0, 0))
    end
    self.tipItem = GetButtonItem("BtnInfor.png", "BtnInfor_Down.png", "BtnInfor_Down.png", tipTouch, 11, nil, nil)
    local spScale = 1
    self.tipItem:setScale(spScale)
    local tipMenu = CCMenu:createWithItem(self.tipItem)
    -- tipMenu:setPosition(ccp(self.bgLayer:getContentSize().width-self.tipItem:getContentSize().width/2*spScale-30-100,G_VisibleSize.height-250))
    tipMenu:setPosition(ccp(self.bgLayer:getContentSize().width - self.tipItem:getContentSize().width / 2 * spScale - 30, G_VisibleSize.height - 260))
    tipMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 6)
    self.bgLayer:addChild(tipMenu, 5)
    
    local function tmpFunc()
    end
    self.maskSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), tmpFunc)
    self.maskSp:setOpacity(255)
    local size = CCSizeMake(G_VisibleSize.width - 50, G_VisibleSizeHeight - 235)
    self.maskSp:setContentSize(size)
    self.maskSp:setAnchorPoint(ccp(0.5, 0))
    self.maskSp:setPosition(ccp(G_VisibleSize.width / 2, 30))
    self.maskSp:setIsSallow(true)
    self.maskSp:setTouchPriority(-(self.layerNum - 1) * 20 - 11)
    self.bgLayer:addChild(self.maskSp, 11)
    
    self.cannotSaveLb = GetTTFLabelWrap(getlocal("serverwar_cannot_set_fleet2"), 30, CCSizeMake(self.maskSp:getContentSize().width - 60, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    self.cannotSaveLb:setAnchorPoint(ccp(0.5, 0.5))
    self.cannotSaveLb:setPosition(getCenterPoint(self.maskSp))
    self.maskSp:addChild(self.cannotSaveLb, 2)
    self.cannotSaveLb:setColor(G_ColorYellowPro)
    
    self:tick()
end

function serverWarPersonalDialogTab2:tick()
    if self then
        local setFleetStatus = serverWarPersonalVoApi:getSetFleetStatus()
        if setFleetStatus and setFleetStatus >= 0 then
            if setFleetStatus == 0 then
                if self.selectedTabIndex and self.selectedTabIndex > 0 then
                    for i = 1, 3 do
                        if self["maxPowerBtn"..i] then
                            self["maxPowerBtn"..i]:setEnabled(true)
                        end
                    end
                    if self.saveBtn then
                        self.saveBtn:setEnabled(true)
                    end
                end
                if self.maskSp then
                    self.maskSp:setPosition(ccp(10000, 0))
                end
            else
                if self.selectedTabIndex and self.selectedTabIndex > 0 then
                    for i = 1, 3 do
                        if self["maxPowerBtn"..i] then
                            self["maxPowerBtn"..i]:setEnabled(false)
                        end
                    end
                    if self.saveBtn then
                        self.saveBtn:setEnabled(false)
                    end
                end
                if self.maskSp then
                    self.maskSp:setPosition(ccp(G_VisibleSize.width / 2, 30))
                end
                
                if self.cannotSaveLb then
                    if setFleetStatus == 1 then
                        self.cannotSaveLb:setString(getlocal("serverwar_cannot_set_fleet1"))
                    elseif setFleetStatus == 2 then
                        self.cannotSaveLb:setString(getlocal("serverwar_cannot_set_fleet2"))
                    elseif setFleetStatus == 3 then
                        self.cannotSaveLb:setString(getlocal("serverwar_cannot_set_fleet3"))
                    elseif setFleetStatus == 4 then
                        self.cannotSaveLb:setString(getlocal("serverwar_cannot_set_fleet4"))
                    elseif setFleetStatus == 5 then
                        self.cannotSaveLb:setString(getlocal("serverwar_cannot_set_fleet5"))
                    end
                end
            end
        end
        
        if self.selectedTabIndex then
            if self.selectedTabIndex and self.selectedTabIndex > 0 then
                local lastTime = serverWarPersonalVoApi:getLastSetFleetTime(self.selectedTabIndex) or 0
                local leftTime = serverWarPersonalCfg.settingTroopsLimit - (base.serverTime - lastTime)
                if leftTime > 0 then
                    if self.saveBtn and self.saveBtn:isEnabled() == true then
                        self.saveBtn:setEnabled(false)
                    end
                    -- if self.saveTimeLb then
                    --     self.saveTimeLb:setVisible(true)
                    -- end
                    if self.leftTimeLb then
                        self.leftTimeLb:setVisible(true)
                        self.leftTimeLb:setString(GetTimeForItemStr(leftTime))
                    end
                else
                    -- if self.saveTimeLb then
                    --     self.saveTimeLb:setVisible(false)
                    -- end
                    if self.leftTimeLb then
                        self.leftTimeLb:setVisible(false)
                    end
                end
                if self.lastStrategyTimeLb then
                    self.lastStrategyTimeLb:setVisible(false)
                end
            else
                -- if self.saveTimeLb then
                --     self.saveTimeLb:setVisible(false)
                -- end
                if self.leftTimeLb then
                    self.leftTimeLb:setVisible(false)
                end
                local strategyTime = serverWarPersonalVoApi:getLastSetStrategyTime()
                if base.serverTime > strategyTime + 60 then
                    if self.saveBtn then
                        self.saveBtn:setEnabled(true)
                        self.saveBtn:setVisible(true)
                    end
                    if self.lastStrategyTimeLb then
                        self.lastStrategyTimeLb:setVisible(false)
                    end
                else
                    if self.saveBtn then
                        self.saveBtn:setEnabled(false)
                        self.saveBtn:setVisible(true)
                    end
                    if self.lastStrategyTimeLb then
                        self.lastStrategyTimeLb:setVisible(true)
                        self.lastStrategyTimeLb:setString(getlocal("world_war_save_left_time", {GetTimeForItemStr(strategyTime + 60 - base.serverTime)}))
                    end
                end
            end
        end
    end
end

function serverWarPersonalDialogTab2:setTanksRestore()
    for k = 1, 3 do
        local tType = 6 + k
        for i = 1, 6 do
            local id = i
            if self["serverWarTanks"..k] and self["serverWarTanks"..k][id] and self["serverWarTanks"..k][id][1] then
                local tid = self["serverWarTanks"..k][id][1]
                local num = self["serverWarTanks"..k][id][2] or 0
                tankVoApi:setTanksByType(tType, id, tid, num)
            else
                tankVoApi:deleteTanksTbByType(tType, id)
            end
            
            if self["serverWarHero"..k] then
                local hid = self["serverWarHero"..k][id]
                if hid then
                    heroVoApi:setServerWarHeroByIndex(k, id, hid)
                else
                    heroVoApi:deleteTroopsByIndex(k, id)
                end
            end
            
            if self["serverWarAITroops"..k] then
                local atid = self["serverWarAITroops"..k][id]
                if atid then
                    AITroopsFleetVoApi:setServerWarAITroopsByIndex(k, id, atid)
                else
                    AITroopsFleetVoApi:setServerWarAITroopsByIndex(k, id, 0)
                end
            end
        end
        emblemVoApi:setBattleEquip(k + 6, self["serverWarEmblem"..k])
        planeVoApi:setBattleEquip(k + 6, self["serverWarPlane"..k])
        airShipVoApi:setBattleEquip(k + 6, self["serverWarAirship"..k])
    end
end

function serverWarPersonalDialogTab2:setEnabledTouch(enabled)
    if enabled == true then
        for k = 1, 3 do
            if self["bgLayer"..k] then
                if k == self.selectedTabIndex then
                    self["bgLayer"..k]:setVisible(true)
                else
                    self["bgLayer"..k]:setVisible(false)
                end
            end
        end
    else
        for k = 1, 3 do
            if self["bgLayer"..k] then
                self["bgLayer"..k]:setVisible(false)
            end
        end
    end
end

function serverWarPersonalDialogTab2:dispose()
    self:setTanksRestore()
    
    for k = 7, 9 do
        G_clearEditTroopsLayer(k)
    end
    
    for k = 1, 3 do
        self["serverWarTanks"..k] = {{}, {}, {}, {}, {}, {}}
    end
    
    for k = 1, 3 do
        self["serverWarHero"..k] = {0, 0, 0, 0, 0, 0}
    end
    for k = 1, 3 do
        self["serverWarAITroops"..k] = {0, 0, 0, 0, 0, 0}
    end
    for k = 1, 3 do
        self["serverWarEmblem"..k] = nil
    end
    
    for k = 1, 3 do
        self["serverWarPlane"..k] = nil
    end
    for k = 1, 3 do
        self["serverWarAirship"..k] = nil
    end
    
    self.tv = nil
    self.bgLayer = nil
    self.layerNum = nil
    self.selectedTabIndex = 0
    self.serverWarTanks = nil
    self.maskSp = nil
    self.saveTimeLb = nil
    self.leftTimeLb = nil
    self.cannotSaveLb = nil
    self.currentShow = {1, 1, 1}
    self.tipItem = nil
    self.lastStrategyTimeLb = nil
    heroVoApi:clearTroops()
    AITroopsFleetVoApi:clearAITroops()
end
