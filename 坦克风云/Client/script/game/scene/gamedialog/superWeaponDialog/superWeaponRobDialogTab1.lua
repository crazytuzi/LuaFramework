superWeaponRobDialogTab1 = {}

function superWeaponRobDialogTab1:new(defaultWeaponID)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    nc.bgLayer = nil
    nc.layerNum = nil
    nc.recordBtn = nil
    nc.upgradeBtn = nil
    nc.protectedBtn = nil
    nc.weaponBg = nil
    nc.fragmentBg = nil
    nc.selectWeaponIndex = 1
    nc.defaultWeaponID = defaultWeaponID
    nc.cellHeight = 120
    return nc
end

function superWeaponRobDialogTab1:init(layerNum, parent)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/superWeapon/swChallenge.plist")
    self.bgLayer = CCLayer:create()
    self.layerNum = layerNum
    self.parent = parent
    self:initLayer()
    return self.bgLayer
end

function superWeaponRobDialogTab1:initLayer()
    local function callback()
        if(self and self.bgLayer)then
            self:initHeader()
            self:initFood()
            self:refreshWeapon()
            self:initAutoSupplyCheckBox()
            self:initBtn()
        end
    end
    superWeaponVoApi:fixMaxFragment(callback)
end

function superWeaponRobDialogTab1:initHeader()
    local function cellClick(hd, fn, idx)
    end
    local headSp = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png", CCRect(20, 20, 10, 10), cellClick)
    headSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width - 60, self.cellHeight - 10))
    headSp:ignoreAnchorPointForPosition(false)
    headSp:setAnchorPoint(ccp(0.5, 1))
    headSp:setIsSallow(false)
    headSp:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
    headSp:setPosition(ccp(self.bgLayer:getContentSize().width / 2, self.bgLayer:getContentSize().height - 175))
    self.bgLayer:addChild(headSp, 1)
    
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createHorizontalWithEventHandler(hd, CCSizeMake(headSp:getContentSize().width - 60, self.cellHeight), nil)
    self.tv:setAnchorPoint(ccp(0, 0))
    self.tv:setPosition(ccp(30, -5))
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    headSp:addChild(self.tv, 1)
    
    local scale = 1
    local leftSp = CCSprite:createWithSpriteFrameName("leftBtnGreen.png")
    leftSp:setScale(scale)
    leftSp:setPosition(ccp(0, headSp:getContentSize().height / 2))
    headSp:addChild(leftSp, 2)
    local rightSp = CCSprite:createWithSpriteFrameName("leftBtnGreen.png")
    rightSp:setScale(scale)
    rightSp:setRotation(180)
    rightSp:setPosition(ccp(headSp:getContentSize().width, headSp:getContentSize().height / 2))
    headSp:addChild(rightSp, 2)
    if(self.defaultWeaponID)then
        self.selectWeaponIndex = tonumber(string.sub(self.defaultWeaponID, 2))
        self:refreshWeapon()
        self.tv:reloadData()
        local minX = math.max(-(self.selectWeaponIndex - 1) * 120, headSp:getContentSize().width - 60 - SizeOfTable(superWeaponCfg.weaponCfg) * 120)
        self.tv:recoverToRecordPoint(ccp(minX, 0))
    end
end

function superWeaponRobDialogTab1:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        local cNum = SizeOfTable(superWeaponCfg.weaponCfg)
        return cNum
    elseif fn == "tableCellSizeForIndex" then
        local tmpSize = CCSizeMake(self.cellHeight, self.cellHeight)
        return tmpSize
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        local cfg = superWeaponCfg.weaponCfg["w" .. (idx + 1)]
        local function clickCell()
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
                
                self.selectWeaponIndex = idx + 1
                self:refreshWeapon()
                local recordPoint = self.tv:getRecordPoint()
                self.tv:reloadData()
                self.tv:recoverToRecordPoint(recordPoint)
                self:refresh()
            end
        end
        local weaponSp = LuaCCSprite:createWithSpriteFrameName(cfg.icon, clickCell)
        weaponSp:setPosition(ccp(self.cellHeight / 2, self.cellHeight / 2))
        weaponSp:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
        weaponSp:setScale(100 / weaponSp:getContentSize().width)
        cell:addChild(weaponSp, 2)
        
        local function nilFunc()
        end
        local blackSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), nilFunc)
        blackSp:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
        local rect = CCSizeMake(100, 100)
        blackSp:setContentSize(rect)
        blackSp:setOpacity(180)
        -- blackSp:setAnchorPoint(ccp(0,0))
        blackSp:setPosition(ccp(weaponSp:getContentSize().width / 2, weaponSp:getContentSize().height / 2))
        weaponSp:addChild(blackSp, 2)
        blackSp:setTag(99)
        
        if self.selectWeaponIndex == idx + 1 then
            blackSp:setVisible(false)
            weaponSp:setScale(self.cellHeight / weaponSp:getContentSize().width)
            -- G_addRectFlicker(weaponSp,1.4,1.4)
        end
        
        return cell
    elseif fn == "ccTouchBegan" then
        self.isMoved = false
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

function superWeaponRobDialogTab1:initFood()
    local posY = self.bgLayer:getContentSize().height - 320
    local foodLb = GetTTFLabelWrap(getlocal("super_weapon_rob_food"), 25, CCSizeMake(120, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    -- local foodLb=GetTTFLabelWrap("啊啊啊啊啊啊啊啊",25,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    foodLb:setAnchorPoint(ccp(0.5, 0.5))
    foodLb:setPosition(ccp(85, posY))
    self.bgLayer:addChild(foodLb, 1)
    
    local maxNum = weaponrobCfg.energyMax
    local energyNum, nextTime = superWeaponVoApi:setCurEnergy()
    local energyStr = ""
    if energyNum < maxNum then
        energyStr = energyNum.."/"..maxNum.."("..GetTimeStr(nextTime) .. ")"
    else
        energyStr = energyNum.."/"..maxNum
    end
    AddProgramTimer(self.bgLayer, ccp(260, posY), 24, 25, energyStr, "AllBarBg.png", "AllEnergyBar.png", 26)
    self.timerSpriteEnergy = self.bgLayer:getChildByTag(24)
    self.timerSpriteEnergy = tolua.cast(self.timerSpriteEnergy, "CCProgressTimer")
    self.timerSpriteEnergy:setPercentage((energyNum / maxNum) * 100)
    
    local function addFoodHandler()
        if G_checkClickEnable() == false then
            do
                return
            end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        
        superWeaponVoApi:showRobAddEnergySmallDialog(self.layerNum + 1)
    end
    local addSp = LuaCCSprite:createWithSpriteFrameName("sYellowAddBtn.png", addFoodHandler)
    addSp:setPosition(ccp(420, posY))
    addSp:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    self.bgLayer:addChild(addSp, 1)
    
    local function showInfo()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local tabStr = {getlocal("super_weapon_rob_info1"), getlocal("super_weapon_rob_info2"), getlocal("super_weapon_rob_info3")}
        local tabColor = {G_ColorYellowPro, G_ColorRed, G_ColorRed}
        local titleStr = getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        local textSize = 25
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, titleStr, tabStr, tabColor, textSize)
    end
    local infoItem = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", showInfo, 11, nil, nil)
    infoItem:setScale(0.7)
    local infoBtn = CCMenu:createWithItem(infoItem)
    infoBtn:setPosition(ccp(G_VisibleSizeWidth - 60, posY))
    infoBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    self.bgLayer:addChild(infoBtn, 1)
end

function superWeaponRobDialogTab1:refreshWeapon()
    local posX = self.bgLayer:getContentSize().width / 2
    local bgHeight = self.bgLayer:getContentSize().height - 500
    local posY = bgHeight / 2 + 140
    if self.weaponBg == nil then
        self.weaponBg = CCSprite:create("public/superWeapon/weaponBg.jpg")
        self.weaponBg:setScaleX((self.bgLayer:getContentSize().width - 50) / self.weaponBg:getContentSize().width)
        self.weaponBg:setScaleY((bgHeight + 20) / self.weaponBg:getContentSize().height)
        self.weaponBg:setPosition(ccp(posX, posY))
        self.bgLayer:addChild(self.weaponBg, 1)
    end
    
    if self.fragmentBg then
        self.fragmentBg:removeFromParentAndCleanup(true)
        self.fragmentBg = nil
    end
    local swId = "w"..self.selectWeaponIndex
    local weaponVo = superWeaponVoApi:getWeaponByID(swId)
    local cfg = superWeaponCfg.weaponCfg[swId]
    if cfg and cfg.fragment then
        local bgScale = 1
        local fragmentNum = SizeOfTable(cfg.fragment)
        if fragmentNum == 5 then
            -- self.fragmentBg=CCSprite:createWithSpriteFrameName("fragmentBg1.png")
            self.fragmentBg = CCSprite:create("public/superWeapon/fragmentBg1.png")
            -- bgScale=0.95
        elseif fragmentNum == 6 then
            -- self.fragmentBg=CCSprite:createWithSpriteFrameName("fragmentBg2.png")
            self.fragmentBg = CCSprite:create("public/superWeapon/fragmentBg2.png")
            bgScale = 0.8
        end
        if self.fragmentBg then
            self.fragmentBg:setPosition(ccp(posX, posY))
            self.fragmentBg:setScale(bgScale)
            self.bgLayer:addChild(self.fragmentBg, 2)
            
            -- local hasFragmentKindNum=0
            local bgWidth, bgHeight = self.fragmentBg:getContentSize().width, self.fragmentBg:getContentSize().height
            for k, v in pairs(cfg.fragment) do
                if v and superWeaponCfg.fragmentCfg[v] and superWeaponCfg.fragmentCfg[v].icon then
                    local num = superWeaponVoApi:getFragmentNum(v)
                    -- if num>0 then
                    -- hasFragmentKindNum=hasFragmentKindNum+1
                    -- end
                    local fCfg = superWeaponCfg.fragmentCfg[v]
                    local function showFragmentInfo()
                        if G_checkClickEnable() == false then
                            do
                                return
                            end
                        else
                            base.setWaitTime = G_getCurDeviceMillTime()
                        end
                        PlayEffect(audioCfg.mouseClick)
                        
                        local type
                        local hasNum = superWeaponVoApi:getFragmentNum(v)
                        if hasNum > 0 then
                            type = 1
                        else
                            type = 2
                        end
                        superWeaponVoApi:showFragmentRobSmallDialog(v, type, self.layerNum + 1)
                    end
                    
                    local fragmentSp
                    if num == 0 then
                        fragmentSp = superWeaponVoApi:getFragmentIcon(v, showFragmentInfo, true)
                    else
                        fragmentSp = superWeaponVoApi:getFragmentIcon(v, showFragmentInfo)
                    end
                    if fragmentSp then
                        local fx, fy = 0, 0
                        if fragmentNum == 5 then
                            local sideLength = bgWidth / 3 * 2
                            if k == 1 then
                                fx, fy = bgWidth / 2, bgHeight
                            elseif k == 2 then
                                fx, fy = bgWidth, sideLength / 2 * math.sqrt(3)
                            elseif k == 3 then
                                fx, fy = bgWidth / 2 + sideLength / 2, 0
                            elseif k == 4 then
                                fx, fy = bgWidth / 2 - sideLength / 2, 0
                            elseif k == 5 then
                                fx, fy = 0, sideLength / 2 * math.sqrt(3)
                            end
                        else
                            if k == 1 then
                                fx, fy = bgWidth / 2, bgHeight
                            elseif k == 2 then
                                fx, fy = bgWidth, bgHeight / 4 * 3
                            elseif k == 3 then
                                fx, fy = bgWidth, bgHeight / 4 * 1
                            elseif k == 4 then
                                fx, fy = bgWidth / 2, 0
                            elseif k == 5 then
                                fx, fy = 0, bgHeight / 4 * 1
                            elseif k == 6 then
                                fx, fy = 0, bgHeight / 4 * 3
                            end
                        end
                        fragmentSp:setPosition(ccp(fx, fy))
                        fragmentSp:setScale(1 / bgScale)
                        fragmentSp:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
                        self.fragmentBg:addChild(fragmentSp, 2)
                        
                        local numLb = GetTTFLabel("x"..num, 25)
                        numLb:setAnchorPoint(ccp(1, 0))
                        numLb:setPosition(ccp(fragmentSp:getContentSize().width - 5, 5))
                        fragmentSp:addChild(numLb, 2)
                    end
                end
            end
            
            local function showSWInfoHandler()
                if G_checkClickEnable() == false then
                    do
                        return
                    end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                
                local weaponVo = superWeaponVoApi:getWeaponByID(swId)
                if weaponVo and weaponVo.lv and weaponVo.lv > 0 then
                    superWeaponVoApi:showWeaponDetailDialog(swId, self.layerNum + 1)
                end
            end
            if cfg.bigIcon then
                local swSp = LuaCCSprite:createWithSpriteFrameName(cfg.bigIcon, showSWInfoHandler)
                swSp:setPosition(ccp(bgWidth / 2, bgHeight / 2))
                if self.selectWeaponIndex == 7 then
                    swSp:setPosition(ccp(bgWidth / 2, bgHeight / 2 + 50))
                end
                swSp:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
                self.fragmentBg:addChild(swSp, 1)
            end
            
            local barWidth = 200
            local nameBgPosY
            local barPosY
            if fragmentNum == 5 then
                nameBgPosY = 90
                barPosY = 70
            else
                nameBgPosY = 120
                barPosY = 90
            end
            local function nilFunc()
            end
            local level = 0
            if weaponVo and weaponVo.lv then
                level = weaponVo.lv
            end
            local nameStr = getlocal(cfg.name)..getlocal("fightLevel", {level})
            local nameLb = GetTTFLabelWrap(nameStr, 24, CCSizeMake(barWidth, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
            -- local nameLb=GetTTFLabelWrap("啊啊啊啊啊啊啊啊",25,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), nilFunc)
            nameBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
            nameBg:setAnchorPoint(ccp(0.5, 0))
            nameBg:setContentSize(CCSizeMake(barWidth, nameLb:getContentSize().height + 10))
            -- nameBg:setOpacity(180)
            nameBg:setPosition(ccp(bgWidth / 2, nameBgPosY))
            self.fragmentBg:addChild(nameBg, 2)
            nameLb:setAnchorPoint(ccp(0.5, 0.5))
            nameLb:setPosition(getCenterPoint(nameBg))
            nameBg:addChild(nameLb, 1)
            nameBg:setScale(1 / bgScale)
            
            local level = 0
            if weaponVo and weaponVo.lv then
                level = weaponVo.lv
            end
            local curMaxExp = 0
            local curExp = 0
            if weaponVo and weaponVo.exp then
                curExp = weaponVo.exp
            end
            if level == 0 then
                curMaxExp = 100
            elseif level == 1 then
                curExp = curExp
                curMaxExp = superWeaponCfg.expCfg[1]
            elseif level < (SizeOfTable(superWeaponCfg.expCfg) + 1) then
                curMaxExp = superWeaponCfg.expCfg[level] - superWeaponCfg.expCfg[level - 1]
                curExp = curExp - superWeaponCfg.expCfg[level - 1]
            else
                curMaxExp = superWeaponCfg.expCfg[SizeOfTable(superWeaponCfg.expCfg)] - superWeaponCfg.expCfg[SizeOfTable(superWeaponCfg.expCfg) - 1]
                curExp = curMaxExp
            end
            AddProgramTimer(self.fragmentBg, ccp(bgWidth / 2, barPosY), 21, 22, curExp.."/"..curMaxExp, "AllBarBg.png", "AllXpBar.png", 23, nil, nil, nil, nil, 20)
            local scheduleBar = self.fragmentBg:getChildByTag(21)
            scheduleBar = tolua.cast(scheduleBar, "CCProgressTimer")
            scheduleBar:setPercentage(curExp / curMaxExp * 100)
            scheduleBar:setScaleX(1 / bgScale * barWidth / scheduleBar:getContentSize().width)
            scheduleBar:setScaleY(1 / bgScale)
            local scheduleBarBg = self.fragmentBg:getChildByTag(23)
            scheduleBarBg = tolua.cast(scheduleBarBg, "CCSprite")
            scheduleBarBg:setScaleX(1 / bgScale * barWidth / scheduleBar:getContentSize().width)
            scheduleBarBg:setScaleY(1 / bgScale)
        end
    end
end

function superWeaponRobDialogTab1:initBtn()
    local btnPosY = 65
    local function recordHandler(...)
        if G_checkClickEnable() == false then
            do
                return
            end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        
        superWeaponVoApi:showRobReportDialog(self.layerNum + 1)
    end
    self.recordBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", recordHandler, 1, getlocal("super_weapon_rob_record_btn"), 24 / 0.8, 101)
    self.recordBtn:setScale(0.8)
    local btnLb = self.recordBtn:getChildByTag(101)
    if btnLb then
        btnLb = tolua.cast(btnLb, "CCLabelTTF")
        btnLb:setFontName("Helvetica-bold")
    end
    local menuRecord = CCMenu:createWithItem(self.recordBtn)
    menuRecord:setAnchorPoint(ccp(0, 0))
    menuRecord:setPosition(ccp(130, btnPosY))
    menuRecord:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    self.bgLayer:addChild(menuRecord, 1)
    
    local numHeight = 25
    local iconWidth = 36
    local iconHeight = 36
    local unreadNum = superWeaponVoApi:getUnreadNum()
    local newsNumLabel = GetTTFLabel(unreadNum or 0, numHeight)
    newsNumLabel:setPosition(ccp(newsNumLabel:getContentSize().width / 2 + 5, iconHeight / 2))
    newsNumLabel:setTag(11)
    --newsNumLabel:setColor(G_ColorRed)
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
    newsIcon:setPosition(ccp(self.recordBtn:getContentSize().width, self.recordBtn:getContentSize().height - 15))
    newsIcon:addChild(newsNumLabel, 1)
    newsIcon:setTag(10)
    newsNumLabel:setPosition(getCenterPoint(newsIcon))
    newsIcon:setVisible(false)
    self.recordBtn:addChild(newsIcon)
    if unreadNum and unreadNum > 0 then
        newsIcon:setVisible(true)
    end
    
    local function upgradeUpHandler(...)
        if G_checkClickEnable() == false then
            do
                return
            end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        
        local swId = "w"..self.selectWeaponIndex
        local weaponVo = G_clone(superWeaponVoApi:getWeaponByID(swId))
        local function callback(propNum)
            local swId = "w"..self.selectWeaponIndex
            local weaponVo1 = superWeaponVoApi:getWeaponByID(swId)
            if weaponVo == nil then
                superWeaponVoApi:showLvUpDialog(swId, self.layerNum + 1, propNum)
            elseif weaponVo and weaponVo.lv and weaponVo1 and weaponVo1.lv and weaponVo.lv ~= weaponVo1.lv then
                superWeaponVoApi:showLvUpDialog(swId, self.layerNum + 1, propNum)
                -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_composeSuccess"),30)
            else
                local oldLevel = 0
                if weaponVo and weaponVo.lv and tonumber(weaponVo.lv) then
                    oldLevel = tonumber(weaponVo.lv)
                end
                local expNum = 0
                if oldLevel == 0 then
                    expNum = 100
                elseif oldLevel <= SizeOfTable(superWeaponCfg.composeExp) then
                    expNum = superWeaponCfg.composeExp[oldLevel]
                else
                    expNum = superWeaponCfg.composeExp[SizeOfTable(superWeaponCfg.composeExp)]
                end
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("super_weapon_rob_weapon_upgrade_success", {expNum}), 30)
            end
            self:refresh()
            self:refreshWeapon()
        end
        local lackFragmentNum = 0 --合成或者进阶缺少的碎片数
        if superWeaponCfg and superWeaponCfg.weaponCfg and superWeaponCfg.weaponCfg[swId] and superWeaponCfg.weaponCfg[swId].fragment then
            local fCfg = superWeaponCfg.weaponCfg[swId].fragment
            if fCfg and SizeOfTable(fCfg) > 0 then
                for k, v in pairs(fCfg) do
                    if v then
                        local fNum = superWeaponVoApi:getFragmentNum(v)
                        if fNum <= 0 then
                            lackFragmentNum = lackFragmentNum + 1
                        end
                    end
                end
                if weaponVo then
                    local isAuto = self:isAutoSupplyPropForUpgrade()
                    if isAuto == true and superWeaponCfg.costProp[swId] then
                        local costProp = FormatItem(superWeaponCfg.costProp[swId].prop)[1]
                        costProp.num = lackFragmentNum * costProp.num
                        local function realUpgrade()
                            superWeaponVoApi:upgradeSuperWeapon(swId, costProp, callback)
                        end
                        if lackFragmentNum > 0 then
                            G_dailyConfirm("weapon.upgrade.confirm", getlocal("super_weapon_upgradeConfirm", {costProp.num, costProp.name}), function ()
                                local num = bagVoApi:getItemNumId(costProp.id)
                                if costProp.num > num then
                                    G_showTipsDialog(getlocal("noenough_prop1"))
                                else
                                    realUpgrade()
                                end
                            end, self.layerNum + 1)
                        else
                            realUpgrade()
                        end
                    else
                        if lackFragmentNum == 0 then
                            superWeaponVoApi:upgradeSuperWeapon(swId, nil, callback)
                        else
                            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("super_weapon_rob_fragment_not_enough_2"), 30)
                        end
                    end
                else
                    if lackFragmentNum == 0 then
                        superWeaponVoApi:makeSuperWeapon(swId, callback)
                    else
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("super_weapon_rob_fragment_not_enough_1"), 30)
                    end
                end
            end
        end
    end
    local swId = "w"..self.selectWeaponIndex
    local weaponVo = superWeaponVoApi:getWeaponByID(swId)
    local upgradeStr = ""
    if weaponVo then
        upgradeStr = getlocal("super_weapon_lvUp")
    else
        upgradeStr = getlocal("super_weapon_rob_upgrade_btn")
    end
    self.upgradeBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", upgradeUpHandler, 2, upgradeStr, 24 / 0.8, 101)
    self.upgradeBtn:setScale(0.8)
    local btnLb = self.upgradeBtn:getChildByTag(101)
    if btnLb then
        btnLb = tolua.cast(btnLb, "CCLabelTTF")
        btnLb:setFontName("Helvetica-bold")
    end
    local menuUpgrade = CCMenu:createWithItem(self.upgradeBtn)
    menuUpgrade:setAnchorPoint(ccp(0, 0))
    menuUpgrade:setPosition(ccp(self.bgLayer:getContentSize().width / 2, btnPosY))
    menuUpgrade:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    self.bgLayer:addChild(menuUpgrade, 1)
    local level = 0
    if weaponVo and weaponVo.lv then
        level = weaponVo.lv
    end
    if level >= (SizeOfTable(superWeaponCfg.expCfg) + 1) then
        self.upgradeBtn:setEnabled(false)
    end
    
    local function protectedHandler(...)
        if G_checkClickEnable() == false then
            do
                return
            end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        
        superWeaponVoApi:showRobProtectSmallDialog(self.layerNum + 1)
    end
    self.protectedBtn = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", protectedHandler, 2, getlocal("super_weapon_rob_protected_btn"), 24 / 0.8, 101)
    self.protectedBtn:setScale(0.8)
    local btnLb = self.protectedBtn:getChildByTag(101)
    if btnLb then
        btnLb = tolua.cast(btnLb, "CCLabelTTF")
        btnLb:setFontName("Helvetica-bold")
    end
    local menuProtected = CCMenu:createWithItem(self.protectedBtn)
    menuProtected:setAnchorPoint(ccp(0, 0))
    menuProtected:setPosition(ccp(self.bgLayer:getContentSize().width - 130, btnPosY))
    menuProtected:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    self.bgLayer:addChild(menuProtected, 1)
    
    self.pLeftTimeLb = GetTTFLabel("", 25)
    self.pLeftTimeLb:setAnchorPoint(ccp(0, 0.5))
    self.pLeftTimeLb:setPosition(ccp(50, btnPosY + 55))
    self.bgLayer:addChild(self.pLeftTimeLb, 2)
    self.pLeftTimeLb:setColor(G_ColorYellowPro)
    local protectTime = superWeaponVoApi:getProtectTime()
    if base.serverTime < protectTime then
        local leftTime = protectTime - base.serverTime
        local leftTimeStr = getlocal("super_weapon_rob_protect_time", {GetTimeStr(leftTime)})
        self.pLeftTimeLb:setString(leftTimeStr)
    else
        self.pLeftTimeLb:setVisible(false)
    end
    
    self:refresh()
end

function superWeaponRobDialogTab1:refresh()
    if self and self.upgradeBtn then
        local autoViewFlag = false
        local swId = "w"..self.selectWeaponIndex
        local weaponVo = superWeaponVoApi:getWeaponByID(swId)
        local upgradeStr = ""
        if weaponVo then
            upgradeStr = getlocal("super_weapon_lvUp")
            autoViewFlag = true
        else
            upgradeStr = getlocal("super_weapon_rob_upgrade_btn")
            autoViewFlag = false
        end
        local lb = tolua.cast(self.upgradeBtn:getChildByTag(101), "CCLabelTTF")
        if lb then
            lb:setString(upgradeStr)
        end
        local level = 0
        if weaponVo and weaponVo.lv then
            level = weaponVo.lv
        end
        if level >= (SizeOfTable(superWeaponCfg.expCfg) + 1) then
            self.upgradeBtn:setEnabled(false)
            self.upgradeBtn:setVisible(false)
            autoViewFlag = false
        else
            self.upgradeBtn:setEnabled(true)
            self.upgradeBtn:setVisible(true)
        end
        if autoViewFlag == true then
            if self.weaponAutoSupplyView then
                self.weaponAutoSupplyView:setVisible(true)
                if G_getIphoneType() == G_iphone4 then
                    self.weaponAutoSupplyView:setPositionX(45)
                else    
                    self.weaponAutoSupplyView:setPositionX(G_VisibleSizeWidth / 2)
                end
            end
        else
            if self.weaponAutoSupplyView then
                self.weaponAutoSupplyView:setVisible(false)
                self.weaponAutoSupplyView:setPositionX(9999)
            end
        end
    end
end

function superWeaponRobDialogTab1:tick()
    if self.pLeftTimeLb then
        local protectTime = superWeaponVoApi:getProtectTime()
        if base.serverTime < protectTime then
            local leftTime = protectTime - base.serverTime
            local leftTimeStr = getlocal("super_weapon_rob_protect_time", {GetTimeStr(leftTime)})
            self.pLeftTimeLb:setString(leftTimeStr)
            self.pLeftTimeLb:setVisible(true)
        else
            self.pLeftTimeLb:setVisible(false)
        end
    end
    
    if self.timerSpriteEnergy then
        local maxNum = weaponrobCfg.energyMax
        local energyNum, nextTime = superWeaponVoApi:setCurEnergy()
        local energyStr = ""
        if energyNum < maxNum then
            energyStr = energyNum.."/"..maxNum.."("..GetTimeStr(nextTime) .. ")"
        else
            energyStr = energyNum.."/"..maxNum
        end
        self.timerSpriteEnergy:setPercentage((energyNum / maxNum) * 100)
        tolua.cast(self.timerSpriteEnergy:getChildByTag(25), "CCLabelTTF"):setString(energyStr)
    end
    if superWeaponVoApi:getFragmentFlag() == 0 then
        if battleScene.isBattleing == false then
            self:refreshWeapon()
            superWeaponVoApi:setFragmentFlag(1)
        end
    end
    
    if superWeaponVoApi:getExploreFlag() == 1 then
        superWeaponVoApi:setExploreFlag(0)
        self:refreshWeapon()
    end
    
    if self.recordBtn then
        local unreadNum = superWeaponVoApi:getUnreadNum()
        local temTabBtnItem = tolua.cast(self.recordBtn, "CCNode")
        local tipSp = temTabBtnItem:getChildByTag(10)
        if tipSp ~= nil then
            if unreadNum and unreadNum > 0 then
                tipSp:setVisible(true)
                local tipNumLabel = tolua.cast(tipSp:getChildByTag(11), "CCLabelTTF")
                tipNumLabel:setString(unreadNum)
                local iconWidth = 36
                if tipNumLabel:getContentSize().width + 10 > iconWidth then
                    iconWidth = tipNumLabel:getContentSize().width + 10
                end
                tipSp:setContentSize(CCSizeMake(iconWidth, 36))
                tipNumLabel:setPosition(getCenterPoint(tipSp))
            else
                tipSp:setVisible(false)
            end
        end
    end
end

--初始化自动补偿宝箱进阶的显示
function superWeaponRobDialogTab1:initAutoSupplyCheckBox()
    local isAuto = self:isAutoSupplyPropForUpgrade()
    local function onClickCheckBox(tag, obj)
        if obj and tolua.cast(obj, "CCMenuItemToggle") then
            local isAuto = (obj:getSelectedIndex() == 1)
            self:setAutoSupplyPropForUpgrade(isAuto)
        end
    end
    local weaponAutoSupplyView = CCNode:create()
    self.bgLayer:addChild(weaponAutoSupplyView, 5)
    self.weaponAutoSupplyView = weaponAutoSupplyView
    
    local checkBoxMenu, checkBoxItem = G_createCheckBox("LegionCheckBtnUn.png", "LegionCheckBtn.png", onClickCheckBox)
    checkBoxItem:setScale(0.8)
    checkBoxItem:setSelectedIndex(isAuto and 1 or 0)
    checkBoxMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    checkBoxMenu:setAnchorPoint(ccp(0, 0.5))
    self.weaponAutoSupplyView:addChild(checkBoxMenu)
    local tipStr, fontSize = getlocal("super_weapon_supplyprop"), G_getLS(22, 18)
    local checkTipLb = GetTTFLabelWrap(tipStr, fontSize, CCSizeMake(G_VisibleSizeWidth - 100, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
    checkTipLb:setColor(G_ColorYellowPro)
    checkTipLb:setAnchorPoint(ccp(0, 0.5))
    self.weaponAutoSupplyView:addChild(checkTipLb)
    local tmpLb = GetTTFLabel(tipStr, fontSize)
    local realW = ((tmpLb:getContentSize().width) > checkTipLb:getContentSize().width and checkTipLb:getContentSize().width or tmpLb:getContentSize().width) + checkBoxItem:getContentSize().width * checkBoxItem:getScale()
    weaponAutoSupplyView:setContentSize(CCSizeMake(realW, 1))
    checkBoxMenu:setPosition(0, weaponAutoSupplyView:getContentSize().height / 2)
    checkTipLb:setPosition(checkBoxMenu:getPositionX() + checkBoxItem:getContentSize().width * checkBoxItem:getScale(), checkBoxMenu:getPositionY())

    if G_getIphoneType() == G_iphone4 then
        weaponAutoSupplyView:setAnchorPoint(ccp(0, 0.5))
        weaponAutoSupplyView:setPosition(45, G_VisibleSizeHeight * 0.6)
    else
        weaponAutoSupplyView:setAnchorPoint(ccp(0.5, 0.5))
        weaponAutoSupplyView:setPosition(G_VisibleSizeWidth / 2, 180)
    end
end

--进阶时碎片不足是否自动补充道具来进阶
function superWeaponRobDialogTab1:isAutoSupplyPropForUpgrade()
    local autoKey = "weapon.auto.supplyprop@"..playerVoApi:getUid()
    return CCUserDefault:sharedUserDefault():getBoolForKey(autoKey)
end

function superWeaponRobDialogTab1:setAutoSupplyPropForUpgrade(isAuto)
    local autoKey = "weapon.auto.supplyprop@"..playerVoApi:getUid()
    CCUserDefault:sharedUserDefault():setBoolForKey(autoKey, isAuto or false)
    CCUserDefault:sharedUserDefault():flush()
end

function superWeaponRobDialogTab1:dispose()
    self.bgLayer = nil
    self.layerNum = nil
    self.recordBtn = nil
    self.upgradeBtn = nil
    self.protectedBtn = nil
    self.weaponBg = nil
    self.fragmentBg = nil
    self.selectWeaponIndex = 1
    self.weaponAutoSupplyView = nil
end
