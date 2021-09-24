playerDialogTab3 = {
    
}

function playerDialogTab3:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    
    self.tv = nil;
    self.bgLayer = nil;
    self.tableCell3 = {}
    self.tableCellItem3 = {}
    self.layerNum = nil;
    self.dataSource = {}
    self.cellNum = 0
    
    self.autoSwitchLabel = nil --自动升级的状态文字label
    self.switchMenuToggle = nil -- 自动升级的状态按钮
    self.autoUpgradeSpBg = nil -- 自动升级icon信息的背景精灵
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/heroRecruitImage.plist")
    self.isOpening = false--是否正在发送开启自动建造的请求
    self.canSpeedTime = 0
    self.speedUpSmallDialog = nil--选择加速升级道具进行加速升级的小面板
    return nc;
    
end

function playerDialogTab3:init(layerNum)
    
    if base.fs == 1 then
        self.canSpeedTime = playerVoApi:getFreeTime()
    end
    self.dataSource = {}
    self.dataSource = buildingVoApi:getBuildingsEnableUpgrade()
    self.bgLayer = CCLayer:create();
    self.layerNum = layerNum;
    self:initTableView();
    if base.autoUpgrade == 1 then
        -- 初始化自动升级建筑
        self:initBuildingAutoUpgrade()
    end
    local function dialogListener(event, data)
        if(data.type == 1)then
            self.tableCell3 = {}
            self.tableCellItem3 = {}
            self.dataSource = {}
            self.dataSource = buildingVoApi:getBuildingsEnableUpgrade()
            if self.tv then
                self.tv:reloadData()
            end
        end
    end
    self.dialogListener = dialogListener
    eventDispatcher:addEventListener("speedUpProp.useProp", self.dialogListener)
    return self.bgLayer
end

-- 更新自动升级的icon及信息  operation: true:添加 nil:移除
function playerDialogTab3:upDateAutoUpgradeIcon(operation)
    -- 移除已存在的
    if self.autoUpgradeSpBg ~= nil then
        self.autoUpgradeSpBg:removeFromParentAndCleanup(true)
        self.autoUpgradeSpBg = nil
        self.autoExpireLabel = nil
    end
    local capInSet = CCRect(20, 20, 10, 10)
    local function cellClick(hd, fn, idx)
    end
    self.autoUpgradeSpBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png", capInSet, cellClick)
    self.autoUpgradeSpBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 100))
    -- self.autoUpgradeSpBg:ignoreAnchorPointForPosition(false)
    self.autoUpgradeSpBg:setAnchorPoint(ccp(0.5, 1))
    -- self.autoUpgradeSpBg:setIsSallow(false)
    self.autoUpgradeSpBg:setTouchPriority(-(self.layerNum - 1) * 20 - 9)
    self.autoUpgradeSpBg:setPosition(ccp(self.bgLayer:getContentSize().width / 2, 200))
    self.autoUpgradeSpBg:setOpacity(0)
    self.bgLayer:addChild(self.autoUpgradeSpBg, 5)
    
    if self.autoBuildBg == nil then
        self.autoBuildBg = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png", CCRect(50, 50, 1, 1), cellClick)
        self.autoBuildBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width - 50, 186))
        self.autoBuildBg:setAnchorPoint(ccp(0.5, 1))
        self.autoBuildBg:setPosition(ccp(self.bgLayer:getContentSize().width / 2, 215))
        self.bgLayer:addChild(self.autoBuildBg, 2)
        self.autoBuildBg:setOpacity(0)
    end
    
    -- 图标
    local autoIcon = propCfg["p2129"].icon
    -- 描述
    local autoDes = propCfg["p2129"].description
    -- 物品消费钻石数
    local autoCost = propCfg["p2129"].gemCost
    -- 自动升级的剩余时间
    local autoExpire = buildingVoApi:getAutoUpgradeExpire()
    if buildingVoApi:getAutoUpgradeBuilding() == 1 then
        autoExpire = autoExpire - base.serverTime
    end
    local reward = FormatItem({p = {p2129 = 1}})
    local item = reward[1]
    local posX = 30
    local posY = self.autoUpgradeSpBg:getContentSize().height - 15
    local function touch()
        local num = bagVoApi:getItemNumId(2129)
        item.num = num
        propInfoDialog:create(sceneGame, item, self.layerNum + 1)
    end
    -- 图标精灵
    local autoUpgradeSp = G_getItemIcon(item, 100, false, self.layerNum + 1, touch)
    autoUpgradeSp:setAnchorPoint(ccp(0, 1))
    autoUpgradeSp:setPosition(ccp(posX, posY))
    autoUpgradeSp:setTouchPriority(-(self.layerNum - 1) * 20 - 10)
    self.autoUpgradeSpBg:addChild(autoUpgradeSp, 1)
    
    posX = posX + autoUpgradeSp:getContentSize().width + 10
    posY = posY
    
    -- 名称label
    local autoNameLabel = GetTTFLabel(getlocal("building_auto_upgrade_title"), 24, true)
    autoNameLabel:setAnchorPoint(ccp(0, 1))
    autoNameLabel:setPosition(ccp(posX, posY))
    self.autoUpgradeSpBg:addChild(autoNameLabel, 1)
    
    if autoExpire > 0 then
        -- 剩余时间数字label
        local autoExpireLabel = GetTTFLabel("("..GetTimeForItemStrState(autoExpire) .. ")", 24)
        autoExpireLabel:setAnchorPoint(ccp(0, 1))
        autoExpireLabel:setPosition(ccp(posX + autoNameLabel:getContentSize().width, posY))
        autoExpireLabel:setColor(G_ColorGreen)
        self.autoUpgradeSpBg:addChild(autoExpireLabel, 1)
        self.autoExpireLabel = autoExpireLabel
    else
        -- 剩余时间数字label
        -- local autoExpireLabel = GetTTFLabel("(0)",25)
        -- autoExpireLabel:setAnchorPoint(ccp(0,1))
        -- autoExpireLabel:setPosition(ccp(posX+autoNameLabel:getContentSize().width,posY))
        -- autoExpireLabel:setColor(G_ColorAutoUpgradeTime)
        -- self.autoUpgradeSpBg:addChild(autoExpireLabel,1)
    end
    posY = posY - 25
    
    self:controlDescLb(posX, posY, self.autoUpgradeSpBg)
    
    -- 钻石精灵
    local goldSp = CCSprite:createWithSpriteFrameName("IconGold.png")
    goldSp:setAnchorPoint(ccp(0, 0.5))
    goldSp:setPosition(ccp(320, -28))
    goldSp:setScale(1.1)
    self.autoUpgradeSpBg:addChild(goldSp, 1)
    
    posX = posX + goldSp:getContentSize().width
    
    -- 当前钻石数的label
    local goldLabel = GetTTFLabel(autoCost, 20)
    goldLabel:setAnchorPoint(ccp(0, 1))
    goldLabel:setPosition(ccp(350, -15))
    goldLabel:setColor(G_ColorAllianceYellow)
    self.autoUpgradeSpBg:addChild(goldLabel, 1)
    
    -- 当前拥有的道具数量label
    local propNumLabel = GetTTFLabel(getlocal("propOwned")..bagVoApi:getItemNumId(2129), 20)
    propNumLabel:setAnchorPoint(ccp(0, 1))
    propNumLabel:setPosition(ccp(autoUpgradeSp:getPositionX(), -15))
    self.autoUpgradeSpBg:addChild(propNumLabel, 1)
    
    if self.menuItem3 then
        -- self.menuItem3:getChildByTag(99)
        local btnName = ""
        if bagVoApi:getItemNumId(2129) <= 0 then
            btnName = getlocal("buyAndUse")
            if G_getCurChoseLanguage() == "fr" then
                btnName = getlocal("buyAndUse")
            end
            goldSp:setVisible(true)
            goldLabel:setVisible(true)
        else
            if autoExpire > 0 then
                btnName = getlocal("useAndDelayed")
            else
                btnName = getlocal("use")
            end
            goldSp:setVisible(false)
            goldLabel:setVisible(false)
        end
        tolua.cast(self.menuItem3:getChildByTag(99), "CCLabelTTF"):setString(btnName)
    else
        if bagVoApi:getItemNumId(2129) <= 0 then
            goldSp:setVisible(true)
            goldLabel:setVisible(true)
        else
            goldSp:setVisible(false)
            goldLabel:setVisible(false)
        end
        
    end
    
    -- 重置tableView的位置
    if (playerVoApi:getTmpSlotTs() >= base.serverTime) and self.tmpSlotLb then
        self:resetTabelView(210, G_VisibleSize.height - 85 - 290 - self.tmpSlotLb:getContentSize().height - 10)
    else
        self:resetTabelView(210, G_VisibleSize.height - 85 - 290)
    end
end

function playerDialogTab3:controlDescLb(posX, posY, parentSp)
    -- 状态文字
    local autoState
    local stateColor
    -- 自动升级的状态开关
    local autoSwitch = buildingVoApi:getAutoUpgradeBuilding()
    -- 自动升级的剩余时间
    local autoExpire = buildingVoApi:getAutoUpgradeExpire()
    if autoSwitch == 1 and autoExpire > 0 then
        local endTime = autoExpire - base.serverTime
        -- 剩余时间有效
        if endTime > 0 then
            autoState = getlocal("allianceWarCurrentStatus", {getlocal("building_auto_upgrade_on")})
            stateColor = G_ColorGreen
        else
            autoState = getlocal("building_auto_upgrade_desc")
            stateColor = G_ColorWhite
        end
    elseif autoSwitch == 0 and autoExpire > 0 then
        autoState = getlocal("allianceWarCurrentStatus", {getlocal("building_auto_upgrade_off")})
        stateColor = G_ColorYellowPro
    else
        autoState = getlocal("building_auto_upgrade_desc")
        stateColor = G_ColorWhite
    end
    if parentSp then
        local autoBuildDescLb = GetTTFLabelWrap(autoState, G_isAsia() and 20 or 16, CCSizeMake(450, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
        autoBuildDescLb:setPosition(ccp(posX, posY - 35))
        autoBuildDescLb:setAnchorPoint(ccp(0, 0.5))
        parentSp:addChild(autoBuildDescLb, 1)
        self.autoBuildDescLb = autoBuildDescLb
        if stateColor then
            autoBuildDescLb:setColor(stateColor)
        end
    else
        self.autoBuildDescLb:setString(autoState)
        if stateColor then
            self.autoBuildDescLb:setColor(stateColor)
        end
    end
    
end

-- 初始化自动升级功能
function playerDialogTab3:initBuildingAutoUpgrade()
    
    local posX = 0 -- 未使用
    local posY = 75
    -- 自动升级的状态开关
    local autoSwitch = buildingVoApi:getAutoUpgradeBuilding()
    -- 自动升级的剩余时间
    local autoExpire = buildingVoApi:getAutoUpgradeExpire()
    print("autoSwitch=", autoSwitch)
    print("autoExpire=", autoExpire)
    -- 建筑自动升级开启
    local function autoTurnOn()
        print("------dmj------autoTurnOn")
        local function serverAutoUpgradeOn(fn, data)
            if base:checkServerData(data) == true then
                self.isOpening = false
                self:upDateAutoUpgradeIcon()
                -- 更新状态文字
                if self.autoSwitchLabel then
                    local autoExpire = buildingVoApi:getAutoUpgradeExpire() - base.serverTime
                    -- 剩余时间有效
                    if autoExpire > 0 then
                        self.autoSwitchLabel:setString(GetTimeForItemStrState(autoExpire))
                        
                    end
                    self:controlDescLb()
                end
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("building_auto_tip1"), 30)
            else
                -- 失败，置为关闭
                if self.switchMenuToggle then
                    self.switchMenuToggle:setSelectedIndex(0)
                    print("------dmj---1---setSelectedIndex(0)")
                end
            end
        end
        self.isOpening = true
        socketHelper:autoUpgradeBuildingsTurnOn(serverAutoUpgradeOn)
    end
    
    -- 建筑自动升级暂停
    local function autoTurnOff()
        print("------dmj------autoTurnOff")
        local function sureFunc()
            local function serverAutoUpgradeOff(fn, data)
                if base:checkServerData(data) == true then
                    self:upDateAutoUpgradeIcon(true)
                    -- 更新状态文字
                    if self.autoSwitchLabel then
                        self.autoSwitchLabel:setString("("..getlocal("building_auto_upgrade_off") .. ")")
                    end
                    if self.switchMenuToggle then
                        self.switchMenuToggle:setSelectedIndex(0)
                        print("------dmj---2---setSelectedIndex(0)")
                    end
                    self:controlDescLb()
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("building_auto_tip2"), 30)
                else
                    -- 置为开启
                    if self.switchMenuToggle then
                        self.switchMenuToggle:setSelectedIndex(1)
                        print("------dmj---3---setSelectedIndex(1)")
                    end
                end
            end
            socketHelper:autoUpgradeBuildingsTurnOff(serverAutoUpgradeOff)
        end
        local smallD = smallDialog:new()
        -- 提示是否使用道具
        smallD:initSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), sureFunc, getlocal("dialog_title_prompt"), getlocal("building_auto_upgrade_sure"), nil, self.layerNum + 1)
    end
    
    -- 状态文字
    local autoState
    -- 按钮状态
    local toggleState
    if autoSwitch == 1 and autoExpire > 0 then
        local endTime = autoExpire - base.serverTime
        -- 剩余时间有效
        if endTime > 0 then
            autoState = GetTimeForItemStrState(endTime)
            toggleState = 1
            self:upDateAutoUpgradeIcon()
        else
            autoState = getlocal("building_auto_upgrade_off")
            toggleState = 0
            self:upDateAutoUpgradeIcon(true)
        end
    else
        autoState = getlocal("building_auto_upgrade_off")
        toggleState = 0
        self:upDateAutoUpgradeIcon(true)
    end
    
    local function menuToggleFunc()
        print("------dmj------menuToggleFunc")
        PlayEffect(audioCfg.mouseClick)
        if (buildingVoApi:getAutoUpgradeBuilding() == 1 and (buildingVoApi:getAutoUpgradeExpire() - base.serverTime) > 0) or (buildingVoApi:getAutoUpgradeBuilding() == 0 and buildingVoApi:getAutoUpgradeExpire() > 0) then
            local index = self.switchMenuToggle:getSelectedIndex()
            if index == 0 then
                self.switchMenuToggle:setSelectedIndex(1)
                print("------dmj----4--setSelectedIndex(1)")
                autoTurnOff()
            else
                autoTurnOn()
            end
        else
            local function serverAutoUpgrade(fn, data)
                if base:checkServerData(data) == true then
                    self:upDateAutoUpgradeIcon()
                    -- 更新按钮状态
                    if self.switchMenuToggle then
                        self.switchMenuToggle:setSelectedIndex(1)
                        print("------dmj---5---setSelectedIndex(1)")
                    end
                    -- 更新状态文字
                    if self.autoSwitchLabel then
                        local autoExpire = buildingVoApi:getAutoUpgradeExpire() - base.serverTime
                        -- 剩余时间有效
                        if autoExpire > 0 then
                            self.autoSwitchLabel:setString(GetTimeForItemStrState(autoExpire))
                        end
                        self:controlDescLb()
                    end
                    self:controlPropBtnState()
                end
            end
            -- 购买道具
            local function autoUpgradeBuy()
                socketHelper:autoUpgradeBuildings(serverAutoUpgrade, 1)
            end
            -- 使用道具
            local function autoUpgradeUse()
                socketHelper:autoUpgradeBuildings(serverAutoUpgrade, 0)
            end
            local smallD = smallDialog:new()
            local autoGemCost = propCfg["p2129"].gemCost
            local autoPropName = propCfg["p2129"].name
            if bagVoApi:getItemNumId(2129) <= 0 then
                local function buyGems()
                    if G_checkClickEnable() == false then
                        do
                            return
                        end
                    end
                    vipVoApi:showRechargeDialog(self.layerNum + 1)
                end
                -- 钻石不够提示充值
                if playerVo.gems < autoGemCost then
                    local num = autoGemCost - playerVo.gems
                    smallD:initSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), buyGems, getlocal("dialog_title_prompt"), getlocal("gemNotEnough", {autoGemCost, playerVo.gems, num}), nil, self.layerNum + 1)
                else
                    -- 提示是否购买道具
                    smallD:initSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), autoUpgradeBuy, getlocal("dialog_title_prompt"), getlocal("activity_republicHui_notEnough", {autoGemCost, 1, getlocal(autoPropName)}), nil, self.layerNum + 1, nil, nil, nil, getlocal("buy"))
                end
            else
                -- 提示是否使用道具
                smallD:initSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), autoUpgradeUse, getlocal("dialog_title_prompt"), getlocal("island_sureUse", {getlocal(autoPropName)}), nil, self.layerNum + 1)
            end
            -- 恢复按钮状态
            if self.switchMenuToggle then
                self.switchMenuToggle:setSelectedIndex(0)
                print("------dmj----6--setSelectedIndex(0)")
            end
        end
    end
    
    local turnOnItem = GetButtonItem("btn_switch_on.png", "btn_switch_middle.png", "btn_switch_middle.png", autoTurnOn, nil, openStr, 22, 66)
    local turnOffItem = GetButtonItem("btn_switch_off.png", "btn_switch_middle.png", "btn_switch_middle.png", autoTurnOff, nil, closeStr, 22, 67)
    self.switchMenuToggle = CCMenuItemToggle:create(turnOffItem)
    self.switchMenuToggle:addSubItem(turnOnItem)
    self.switchMenuToggle:setAnchorPoint(CCPointMake(0.5, 0.5))
    self.switchMenuToggle:setPosition(0, 0)
    self.switchMenuToggle:setSelectedIndex(toggleState)
    print("------dmj---7---setSelectedIndex(1)")
    self.switchMenuToggle:registerScriptTapHandler(menuToggleFunc)
    local switchMenu = CCMenu:create()
    switchMenu:addChild(self.switchMenuToggle)
    switchMenu:setPosition(ccp(220, posY - 5))
    switchMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    self.bgLayer:addChild(switchMenu, 6)
    
    local xPos = 245
    if G_getCurChoseLanguage() == "de" then
        xPos = 275
    end
    -- 建筑自动升级的状态文字label
    self.autoSwitchLabel = GetTTFLabelWrap(autoState, 20, CCSizeMake(150, 100), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    self.autoSwitchLabel:setAnchorPoint(ccp(0, 0.5))
    self.autoSwitchLabel:setPosition(ccp(xPos, posY))
    self.autoSwitchLabel:setColor(G_ColorAutoUpgradeTime)
    self.bgLayer:addChild(self.autoSwitchLabel, 3)
    self.autoSwitchLabel:setVisible(false)
    -- 购买建筑自动升级
    local function touch3()
        PlayEffect(audioCfg.mouseClick)
        if G_checkClickEnable == false then
            do return end
        end
        local function serverAutoUpgrade(fn, data)
            if base:checkServerData(data) == true then
                self:upDateAutoUpgradeIcon()
                -- 更新按钮状态
                if self.switchMenuToggle then
                    self.switchMenuToggle:setSelectedIndex(1)
                    print("------dmj---8---setSelectedIndex(1)")
                end
                -- 更新状态文字
                if self.autoSwitchLabel then
                    local autoExpire = buildingVoApi:getAutoUpgradeExpire() - base.serverTime
                    -- 剩余时间有效
                    if autoExpire > 0 then
                        self.autoSwitchLabel:setString(GetTimeForItemStrState(autoExpire))
                    end
                    self:controlDescLb()
                end
                self:controlPropBtnState()
                local propName = "【"..getlocal("sample_prop_name_2129") .. "】"
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("use_prop_success", {propName}), 30)
            end
        end
        -- 购买道具
        local function autoUpgradeBuy()
            socketHelper:autoUpgradeBuildings(serverAutoUpgrade, 1)
        end
        -- 使用道具
        local function autoUpgradeUse()
            socketHelper:autoUpgradeBuildings(serverAutoUpgrade, 0)
        end
        local smallD = smallDialog:new()
        local autoGemCost = propCfg["p2129"].gemCost
        local autoPropName = propCfg["p2129"].name
        if bagVoApi:getItemNumId(2129) <= 0 then
            local function buyGems()
                if G_checkClickEnable() == false then
                    do
                        return
                    end
                end
                vipVoApi:showRechargeDialog(self.layerNum + 1)
            end
            if playerVo.gems < autoGemCost then
                local num = autoGemCost - playerVo.gems
                smallD:initSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), buyGems, getlocal("dialog_title_prompt"), getlocal("gemNotEnough", {autoGemCost, playerVo.gems, num}), nil, self.layerNum + 1)
            else
                smallD:initSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), autoUpgradeBuy, getlocal("dialog_title_prompt"), getlocal("prop_buy_tip", {autoGemCost, getlocal(autoPropName)}), nil, self.layerNum + 1)
            end
        else
            -- 提示是否使用道具
            smallD:initSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), autoUpgradeUse, getlocal("dialog_title_prompt"), getlocal("island_sureUse", {getlocal(autoPropName)}), nil, self.layerNum + 1)
        end
        
    end
    local btnName, fontSize
    if bagVoApi:getItemNumId(2129) <= 0 then
        btnName = getlocal("buyAndUse")
        fontSize = 25
        if G_getCurChoseLanguage() == "fr" then
            fontSize = 24
            btnName = getlocal("buyAndUse")
        elseif G_getCurChoseLanguage() == "de" then
            fontSize = 20
        end
    else
        if autoExpire > 0 then
            btnName = getlocal("useAndDelayed")
        else
            btnName = getlocal("use")
        end
        fontSize = 27
        if not G_isAsia() then
            fontSize = 20
        end
    end
    local btnScale = 0.8
    self.menuItem3 = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", touch3, 11, btnName, fontSize / btnScale, 99)
    self.menuItem3:setScale(btnScale)
    local menu3 = CCMenu:createWithItem(self.menuItem3)
    menu3:setPosition(ccp(520, posY))
    menu3:setTouchPriority(-(self.layerNum - 1) * 20 - 4);
    self.bgLayer:addChild(menu3, 3)
    menu3:setTag(23)
    self.menu3 = menu3
    
    btnScale = 1
    self.menuItem4 = GetButtonItem("heroRecruitBtn2.png", "heroRecruitBtn2Down.png", "heroRecruitBtn2Down.png", touch3, 2, getlocal("buyAndUse"), fontSize, 11)
    local menu4 = CCMenu:createWithItem(self.menuItem4)
    menu4:setPosition(ccp(455, posY - 5))
    menu4:setTouchPriority(-(self.layerNum - 1) * 20 - 4);
    self.bgLayer:addChild(menu4, 3)
    menu4:setTag(24)
    self.menu4 = menu4
    local lb = tolua.cast(self.menuItem4:getChildByTag(11), "CCLabelTTF")
    lb:setPosition(ccp(self.menuItem4:getContentSize().width * btnScale * (1 - 1 / 8 * 5 / 2), self.menuItem4:getContentSize().height / 2 * btnScale))
    
    self:controlPropBtnState()
    
    self:checkItemEnable()
end

function playerDialogTab3:controlPropBtnState()
    if bagVoApi:getItemNumId(2129) <= 0 then
        if self.menu3 then
            self.menu3:setVisible(false)
        end
        if self.menu4 then
            self.menu4:setVisible(true)
        end
    else
        if self.menu3 then
            self.menu3:setVisible(true)
        end
        if self.menu4 then
            self.menu4:setVisible(false)
        end
    end
end

-- 根据荣誉勋章数判断item是否可点击
function playerDialogTab3:checkItemEnable()
    if buildingVoApi:isAllBuildingsMax() == true and self.menuItem3 then
        self.menuItem3:setEnabled(false)
    else
        self.menuItem3:setEnabled(true)
    end
end

function playerDialogTab3:resetTabelView(posY, tvHeight)
    
    if self.tv then
        self.tv:setViewSize(CCSizeMake(self.bgLayer:getContentSize().width - 10, tvHeight))
        self.tv:setPosition(ccp((G_VisibleSizeWidth - self.cellWidth) / 2, posY))
        base.refreshupgrade = true
    end
    
    -- if self.tv then
    --     self.tv:removeFromParentAndCleanup(true)
    --     self.tv = nil
    -- end
    -- local function callBack(...)
    --     return self:eventHandler(...)
    -- end
    -- local hd= LuaEventHandler:createHandler(callBack)
    -- local height=0;
    -- self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,tvHeight),nil)
    -- --self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    -- self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    -- self.tv:setPosition(ccp(30,posY))
    -- self.bgLayer:addChild(self.tv)
    -- self.tv:setMaxDisToBottomOrTop(120)
end

function playerDialogTab3:initTableView()
    
    self.cellWidth = 616
    local tvHeight = 0
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    if(playerVoApi:getTmpSlotTs() >= base.serverTime)then
        self.tmpSlotLb = GetTTFLabelWrap(getlocal("promptTmpBuldingCD", {GetTimeForItemStrState(playerVoApi:getTmpSlotTs() - base.serverTime)}), 20, CCSizeMake(G_VisibleSizeWidth - 60, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        self.tmpSlotLb:setColor(G_ColorYellowPro)
        self.tmpSlotLb:setAnchorPoint(ccp(0, 1))
        self.tmpSlotLb:setPosition(ccp(30, G_VisibleSizeHeight - 85 - 85))
        tvHeight = G_VisibleSize.height - 85 - 290 - self.tmpSlotLb:getContentSize().height
        self.bgLayer:addChild(self.tmpSlotLb)
    else
        tvHeight = G_VisibleSize.height - 85 - 290
    end
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.cellWidth, tvHeight), nil)
    --self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition(ccp((G_VisibleSizeWidth - self.cellWidth) / 2, 210))
    self.bgLayer:addChild(self.tv, 2)
    self.tv:setMaxDisToBottomOrTop(120)
    
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("newKuang2.png", CCRect(7, 7, 1, 1), function () end)
    tvBg:setAnchorPoint(ccp(0.5, 0))
    tvBg:setContentSize(CCSizeMake(self.cellWidth, tvHeight + 4))
    tvBg:setPosition(G_VisibleSizeWidth / 2, self.tv:getPositionY() - 2)
    self.bgLayer:addChild(tvBg)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function playerDialogTab3:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        self.cellNum = SizeOfTable(self.dataSource)
        return self.cellNum
        
    elseif fn == "tableCellSizeForIndex" then
        local tmpSize
        
        tmpSize = CCSizeMake(self.cellWidth, 120)
        
        return tmpSize
        
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        local function cellClick(hd, fn, idx)
            --return self:cellClick(idx)
        end
        
        local hei = 120 - 5
        
        -- local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("newKuang2.png",CCRect(7,7,1,1),cellClick)
        -- backSprie:setContentSize(CCSizeMake(self.cellWidth, hei))
        -- backSprie:ignoreAnchorPointForPosition(false);
        -- backSprie:setAnchorPoint(ccp(0,0));
        -- backSprie:setPositionY(2.5)
        -- backSprie:setTag(1000+idx)
        -- backSprie:setIsSallow(false)
        -- backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
        -- cell:addChild(backSprie,1)
        
        local strname = buildingCfg[self.dataSource[idx + 1].type].icon;
        local buildingSp = CCSprite:createWithSpriteFrameName(strname);
        buildingSp:setAnchorPoint(ccp(0, 0.5));
        buildingSp:setPosition(ccp(20, 60));
        --buildingSp:setScale(0.4)
        cell:addChild(buildingSp, 2);
        
        local strLbName = getlocal(buildingCfg[self.dataSource[idx + 1].type].buildName)..getlocal("fightLevel", {self.dataSource[idx + 1].level})
        local nameLb = GetTTFLabel(strLbName, 24, true);
        nameLb:setAnchorPoint(ccp(0, 0.5));
        nameLb:setPosition(ccp(130, 90));
        cell:addChild(nameLb, 2);
        
        if self.dataSource[idx + 1].status == 1 then
            local function touch2()
                if self.tv:getIsScrolled() == true then
                    return
                end
                PlayEffect(audioCfg.mouseClick)
                local td = smallDialog:new()
                local dialog, container = td:initShowBuilding("TankInforPanel.png", CCSizeMake(530, 400), CCRect(0, 0, 400, 350), CCRect(130, 50, 1, 1), nil, true, true, self.layerNum + 1)
                dialog:setPosition(ccp(0, 0))
                local upgradeBg = upgradeRequire:new();
                upgradeBg:create(container, "build", self.dataSource[idx + 1].id, self.dataSource[idx + 1].type)
                sceneGame:addChild(dialog, self.layerNum + 1)
                
            end
            
            local function touch1()
                if self.tv:getIsScrolled() == true then
                    return
                end
                PlayEffect(audioCfg.mouseClick)
                
                local function serverUpgrade(fn, data)
                    --local retTb=OBJDEF:decode(data)
                    if base:checkServerData(data) == true then
                        if buildingVoApi:upgrade(self.dataSource[idx + 1].id, self.dataSource[idx + 1].type) then
                            self.tableCell3 = {}
                            self.tableCellItem3 = {}
                            self.dataSource = {}
                            self.dataSource = buildingVoApi:getBuildingsEnableUpgrade()
                            self.tv:reloadData()
                        end
                    end
                end
                local checkResult = buildingVoApi:checkUpgradeBeforeSendServer(self.dataSource[idx + 1].id, self.dataSource[idx + 1].type)
                if(checkResult == 0)then
                    socketHelper:upgradeBuild(self.dataSource[idx + 1].id, self.dataSource[idx + 1].type, serverUpgrade)
                elseif(checkResult == 1)then
                    local targetBid = self.dataSource[idx + 1].id
                    local targetType = self.dataSource[idx + 1].type
                    local function onSpeed()
                        socketHelper:upgradeBuild(targetBid, targetType, serverUpgrade)
                    end
                    vipVoApi:showQueueFullDialog(1, self.layerNum + 1, onSpeed)
                end
            end
            
            local menuItem1 = GetButtonItem("yh_BtnBuild.png", "yh_BtnBuild_Down.png", "yh_BtnBuild_Down.png", touch1, 10, nil, nil)
            local menu1 = CCMenu:createWithItem(menuItem1);
            menu1:setPosition(ccp(self.cellWidth - 50, hei / 2 - 10));
            menu1:setTouchPriority(-(self.layerNum - 1) * 20 - 2);
            cell:addChild(menu1, 3);
            self.tableCellItem3[idx + 1] = menuItem1;
            
            local timeSp = CCSprite:createWithSpriteFrameName("IconTime.png");
            timeSp:setAnchorPoint(ccp(0, 0.5));
            timeSp:setPosition(125, 35)
            cell:addChild(timeSp, 2)
            
            local timeLable = GetTTFLabelWrap(" ", 20, CCSizeMake(180, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
            timeLable:setAnchorPoint(ccp(0, 0.5));
            timeLable:setPosition(ccp(timeSp:getPositionX() + timeSp:getContentSize().width, 35));
            cell:addChild(timeLable, 1);
            
            local isRequire = buildingVoApi:checkUpgradeRequire(self.dataSource[idx + 1].id, self.dataSource[idx + 1].type)
            if isRequire == false then
                menuItem1:setEnabled(false);
                timeLable:setString(getlocal("cannot_build_up"))
            else
                menuItem1:setEnabled(true);
                local leftTime = tonumber(buildingVoApi:getBuildingTime(self.dataSource[idx + 1].type, self.dataSource[idx + 1].level))
                
                local desVate = 1
                if self.dataSource[idx + 1].type == 7 then -- 指挥中心
                    local levelVo = activityVoApi:getActivityVo("leveling")
                    if levelVo ~= nil and activityVoApi:isStart(levelVo) == true then
                        desVate = acLevelingVoApi:getDesVate()
                    end
                    local level2Vo = activityVoApi:getActivityVo("leveling2")
                    if level2Vo ~= nil and activityVoApi:isStart(level2Vo) == true then
                        if acLeveling2VoApi:checkIfDesVate() == true then
                            desVate = acLeveling2VoApi:getDesVate()
                        end
                    end
                end
                
                local str = GetTimeStr(math.ceil(leftTime * desVate))
                timeLable:setString(str)
            end
            
            local menuItem2 = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", touch2, 11, nil, nil)
            local menu2 = CCMenu:createWithItem(menuItem2);
            menu2:setPosition(ccp(self.cellWidth - 130, hei / 2 - 10));
            menu2:setTouchPriority(-(self.layerNum - 1) * 20 - 2);
            cell:addChild(menu2, 3);
            
        elseif self.dataSource[idx + 1].status == 2 then
            self.tableCell3[idx + 1] = cell
            local function touch2()
                if self.tv:getIsScrolled() == true then
                    do
                        return
                    end
                end
                PlayEffect(audioCfg.mouseClick)
                local function cancleUpgrade()
                    
                    local function serverCancleUpgrade(fn, data)
                        
                        --local retTb=OBJDEF:decode(data)
                        if base:checkServerData(data) == true then
                            if buildingVoApi:cancleUpgradeBuild(self.dataSource[idx + 1].id) == false then --取消失败
                                
                            else--取消成功
                                self.dataSource = {}
                                self.dataSource = buildingVoApi:getBuildingsEnableUpgrade()
                                self.tableCell3 = {}
                                self.tableCellItem3 = {}
                                self.tv:reloadData()
                            end
                        end
                    end
                    if buildingVoApi:checkCancleUpgradeBuildBeforeServer(self.dataSource[idx + 1].id) == true then
                        socketHelper:cancleUpgradeBuild(self.dataSource[idx + 1].id, self.dataSource[idx + 1].type, serverCancleUpgrade)
                    end
                    
                end
                local smallD = smallDialog:new()
                local contenStr
                if base.autoUpgrade == 1 and buildingVoApi:getAutoUpgradeBuilding() == 1 and buildingVoApi:getAutoUpgradeExpire() - base.serverTime > 0 then
                    contenStr = getlocal("BuildBoard_cancel_prompt")..getlocal("building_auto_upgrade_cancle")
                else
                    contenStr = getlocal("BuildBoard_cancel_prompt")
                end
                
                smallD:initSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), cancleUpgrade, getlocal("dialog_title_prompt"), contenStr, nil, self.layerNum + 1)
                
            end
            
            local function touch1()
                if self.tv:getIsScrolled() == true then
                    return
                end
                PlayEffect(audioCfg.mouseClick)
                
                local function superUpgradeHandler()
                    local function superUpgrade()
                        local function serverSuperUpgrade(fn, data)
                            --local retTb=OBJDEF:decode(data)
                            if base:checkServerData(data) == true then
                                if self.speedUpSmallDialog ~= nil then
                                    self.speedUpSmallDialog:close()
                                    self.speedUpSmallDialog = nil
                                end
                                if buildingVoApi:superUpgradeBuild(self.dataSource[idx + 1].id) then --加速成功
                                    self:tick()
                                else
                                    if self.tv then
                                        self.dataSource = buildingVoApi:getBuildingsEnableUpgrade()
                                        self.tv:reloadData()
                                    end
                                end
                            end
                        end
                        
                        if buildingVoApi:checkSuperUpgradeBuildBeforeServer(self.dataSource[idx + 1].id) == true then
                            socketHelper:superUpgradeBuild(self.dataSource[idx + 1].id, self.dataSource[idx + 1].type, serverSuperUpgrade)
                        end
                        
                    end
                    local bsv = buildingSlotVoApi:getSlotByBid(self.dataSource[idx + 1].id)
                    local leftTime = buildingVoApi:getUpgradeLeftTime(self.dataSource[idx + 1].id)
                    if leftTime > 0 then
                        local needGemsNum = TimeToGems(leftTime)
                        local needGems = getlocal("speedUp", {needGemsNum})
                        if needGemsNum > playerVoApi:getGems() then --金币不足
                            GemsNotEnoughDialog(nil, nil, needGemsNum - playerVoApi:getGems(), self.layerNum + 2, needGemsNum)
                        else
                            local smallD = smallDialog:new()
                            local contenStr
                            if base.autoUpgrade == 1 and buildingVoApi:getAutoUpgradeBuilding() == 1 and buildingVoApi:getAutoUpgradeExpire() - base.serverTime > 0 then
                                contenStr = needGems..getlocal("building_auto_upgrade_quick")
                            else
                                contenStr = needGems
                            end
                            local zhhzxVo = buildingVoApi:getBuildiingVoByBId(1)
                            local level = 5
                            for k, v in pairs(homeCfg.pIndexArrayByLevel) do
                                for kk, vv in pairs(v) do
                                    if vv == 7 then
                                        level = k
                                        break
                                    end
                                end
                            end
                            local addStr = nil
                            if zhhzxVo and zhhzxVo.level and zhhzxVo.level >= level then
                                addStr = getlocal("recommendJoinAlliance_lbDes")
                            end
                            smallD:initSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), superUpgrade, getlocal("dialog_title_prompt"), contenStr, nil, self.layerNum + 2, nil, nil, nil, nil, nil, nil, nil, nil, addStr)
                        end
                    end
                end
                --使用加速道具
                if base.speedUpPropSwitch == 1 then
                    if self.speedUpSmallDialog ~= nil then
                        self.speedUpSmallDialog:close()
                        self.speedUpSmallDialog = nil
                    end
                    require "luascript/script/componet/speedUpPropSmallDialog"
                    self.speedUpSmallDialog = speedUpPropSmallDialog:new(1, self.dataSource[idx + 1].id, superUpgradeHandler)
                    self.speedUpSmallDialog:init(self.layerNum + 1)
                else
                    superUpgradeHandler()
                end
            end
            
            local menuItem1 = GetButtonItem("yh_BtnRight.png", "yh_BtnRight_Down.png", "yh_BtnRight_Down.png", touch1, 10, nil, nil)
            local menu1 = CCMenu:createWithItem(menuItem1);
            menu1:setPosition(ccp(self.cellWidth - 50, hei / 2 - 10));
            menu1:setTag(101)
            menu1:setTouchPriority(-(self.layerNum - 1) * 20 - 2);
            cell:addChild(menu1, 3);
            
            local menuItem2 = GetButtonItem("yh_BtnNo.png", "yh_BtnNo_Down.png", "yh_BtnNo_Down.png", touch2, 11, nil, nil)
            local menu2 = CCMenu:createWithItem(menuItem2);
            menu2:setPosition(ccp(self.cellWidth - 130, hei / 2 - 10));
            menu2:setTouchPriority(-(self.layerNum - 1) * 20 - 2);
            cell:addChild(menu2, 3);
            
            local leftTime = buildingVoApi:getUpgradeLeftTime(self.dataSource[idx + 1].id)
            
            local isFree = false
            if base.fs == 1 then
                local function touch3()
                    if self.tv:getIsScrolled() == true then
                        return
                    end
                    PlayEffect(audioCfg.mouseClick)
                    local function superUpgrade()
                        local function serverSuperUpgrade(fn, data)
                            --local retTb=OBJDEF:decode(data)
                            if base:checkServerData(data) == true then
                                if buildingVoApi:superUpgradeBuild(self.dataSource[idx + 1].id) then --加速成功
                                    self:tick()
                                end
                            end
                        end
                        
                        if buildingVoApi:checkSuperUpgradeBuildBeforeServer(self.dataSource[idx + 1].id) == true then
                            socketHelper:freeUpgradeBuild(self.dataSource[idx + 1].id, self.dataSource[idx + 1].type, serverSuperUpgrade)
                        end
                        
                    end
                    local leftTime = buildingVoApi:getUpgradeLeftTime(self.dataSource[idx + 1].id)
                    if leftTime > 0 and leftTime <= self.canSpeedTime then
                        superUpgrade()
                    end
                    
                end
                
                local menuItem3 = GetButtonItem("yh_freeSpeedupBtn.png", "yh_freeSpeedupBtn_Down.png", "yh_freeSpeedupBtn_Down.png", touch3, 10, nil, nil)
                local menu3 = CCMenu:createWithItem(menuItem3);
                menu3:setPosition(ccp(self.cellWidth - 50, hei / 2 - 10));
                menu3:setTag(103)
                menu3:setTouchPriority(-(self.layerNum - 1) * 20 - 2);
                cell:addChild(menu3, 3)
                
                local freeLb = GetTTFLabelWrap(getlocal("daily_lotto_tip_2"), 20, CCSizeMake(120, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
                menuItem3:addChild(freeLb)
                freeLb:setPosition(menuItem3:getContentSize().width / 2, menuItem3:getContentSize().height + 18)
                
                if leftTime > self.canSpeedTime then
                    menu3:setVisible(false)
                    menu1:setEnabled(true)
                else
                    menu3:setVisible(true)
                    menu1:setEnabled(false)
                    isFree = true
                end
            end
            
            if base.allianceHelpSwitch == 1 then
                local function seekHelpHandler()
                    if self.tv:getScrollEnable() == true and self.tv:getIsScrolled() == false then
                        if G_checkClickEnable() == false then
                            do
                                return
                            end
                        else
                            base.setWaitTime = G_getCurDeviceMillTime()
                        end
                        PlayEffect(audioCfg.mouseClick)
                        
                        local function helpCallback(fn, data)
                            local ret, sData = base:checkServerData(data)
                            if ret == true then
                                if sData and sData.data and sData.data.newhelp then
                                    local selfAlliance = allianceVoApi:getSelfAlliance()
                                    if selfAlliance then
                                        local aid = selfAlliance.aid
                                        local prams = {newhelp = sData.data.newhelp, uid = playerVoApi:getUid()}
                                        chatVoApi:sendUpdateMessage(29, prams, aid + 1)
                                    end
                                    self:tick()
                                end
                            end
                            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("alliance_help_success"), 30)
                        end
                        
                        local leftTime = buildingVoApi:getUpgradeLeftTime(self.dataSource[idx + 1].id)
                        local buildingSlotVo = buildingSlotVoApi:getSlotByBid(self.dataSource[idx + 1].id)
                        local selfAlliance = allianceVoApi:getSelfAlliance()
                        if selfAlliance and leftTime and leftTime > 0 and buildingSlotVo and buildingSlotVo.hid == nil then
                            if base.fs == 1 then
                                local canSpeedTime = playerVoApi:getFreeTime()
                                if leftTime > canSpeedTime then
                                    local bid = self.dataSource[idx + 1].id
                                    local btype = self.dataSource[idx + 1].type
                                    socketHelper:buildingAlliancehelp(bid, btype, helpCallback)
                                end
                            else
                                local bid = self.dataSource[idx + 1].id
                                local btype = self.dataSource[idx + 1].type
                                socketHelper:buildingAlliancehelp(bid, btype, helpCallback)
                            end
                        end
                    end
                end
                local menuItem4 = GetButtonItem("yh_allianceHelpBtn.png", "yh_allianceHelpBtn_Down.png", "yh_allianceHelpBtn_Down.png", seekHelpHandler, 11, nil, nil)
                local seekHelpBtn = CCMenu:createWithItem(menuItem4);
                seekHelpBtn:setPosition(ccp(self.cellWidth - 50, hei / 2 - 10));
                seekHelpBtn:setTag(104)
                seekHelpBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 2);
                cell:addChild(seekHelpBtn, 3)
                
                local buildingSlotVo = buildingSlotVoApi:getSlotByBid(self.dataSource[idx + 1].id)
                local selfAlliance = allianceVoApi:getSelfAlliance()
                if selfAlliance and leftTime and leftTime > 0 and buildingSlotVo and buildingSlotVo.hid == nil and isFree == false then
                    seekHelpBtn:setVisible(true)
                    seekHelpBtn:setEnabled(true)
                    menu1:setVisible(false)
                    menu1:setEnabled(false)
                else
                    seekHelpBtn:setVisible(false)
                    seekHelpBtn:setEnabled(false)
                    menu1:setVisible(true)
                    menu1:setEnabled(true)
                end
            end
            
            local totalTime = buildingSlotVoApi:getSlotByBid(self.dataSource[idx + 1].id).et - buildingSlotVoApi:getSlotByBid(self.dataSource[idx + 1].id).st
            local leftTime = buildingSlotVoApi:getSlotByBid(self.dataSource[idx + 1].id).et - base.serverTime
            if leftTime < 0 then
                leftTime = 0
            end
            print("self.dataSource[idx+1].id,leftTime", self.dataSource[idx + 1].id, leftTime)
            AddProgramTimer(cell, ccp(266, 35), 21, 22, GetTimeStr(leftTime), "TeamTravelBarBg.png", "TeamTravelBar.png", 23, nil, nil, nil, nil, 20)
            local timerSpriteLv = cell:getChildByTag(21);
            timerSpriteLv = tolua.cast(timerSpriteLv, "CCProgressTimer")
            
            timerSpriteLv:setPercentage((1 - leftTime / totalTime) * 100)
        end
        local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function()end)
        lineSp:setContentSize(CCSizeMake(self.cellWidth - 18, lineSp:getContentSize().height))
        lineSp:setRotation(180)
        lineSp:setPosition(self.cellWidth / 2, lineSp:getContentSize().height / 2)
        cell:addChild(lineSp)
        
        return cell;
    elseif fn == "ccTouchBegan" then
        self.isMoved = false
        return true
    elseif fn == "ccTouchMoved" then
        self.isMoved = true
    elseif fn == "ccTouchEnded" then
        
    end
end

function playerDialogTab3:tick()
    
    self.dataSource = buildingVoApi:getBuildingsEnableUpgrade()
    
    if(self.tmpSlotLb)then
        if(playerVoApi:getTmpSlotTs() >= base.serverTime)then
            self.tmpSlotLb:setString(getlocal("promptTmpBuldingCD", {GetTimeForItemStrState(playerVoApi:getTmpSlotTs() - base.serverTime)}))
        else
            self.tmpSlotLb:setVisible(false)
        end
    else
        if(playerVoApi:getTmpSlotTs() >= base.serverTime)then
            self.bgLayer:removeChild(self.tv, true)
            self.tableCell3 = {}
            self.tableCellItem3 = {}
            self:initTableView()
            do return end
        end
    end
    
    if SizeOfTable(self.dataSource) ~= self.cellNum then
        self.tableCell3 = {}
        self.tableCellItem3 = {}
        if(self.tv)then
            self.tv:reloadData()
        end
        do
            return
        end
    end
    
    for k, v in pairs(self.tableCell3) do
        local cell = self.tableCell3[k]
        if self.dataSource[k].status == 2 then
            local progress = tolua.cast(cell:getChildByTag(21), "CCProgressTimer")
            local totalTime = buildingVoApi:getUpgradingTotalUpgradeTime(self.dataSource[k].id)
            if totalTime == nil then
                break
            end
            local leftTime = buildingVoApi:getUpgradeLeftTime(self.dataSource[k].id)
            progress:setPercentage((1 - leftTime / totalTime) * 100)
            tolua.cast(progress:getChildByTag(22), "CCLabelTTF"):setString(GetTimeStr(leftTime))
            
            local isFree = false
            if base.fs == 1 then
                local menu1 = tolua.cast(cell:getChildByTag(101), "CCMenu")
                local menu3 = tolua.cast(cell:getChildByTag(103), "CCMenu")
                if leftTime > self.canSpeedTime then
                    if menu1 then
                        menu1:setVisible(true)
                        menu1:setEnabled(true)
                    end
                    if menu3 then
                        menu3:setVisible(false)
                        menu3:setEnabled(false)
                    end
                else
                    if menu1 then
                        menu1:setVisible(false)
                        menu1:setEnabled(false)
                    end
                    if menu3 then
                        menu3:setVisible(true)
                        menu3:setEnabled(true)
                        isFree = true
                    end
                end
            end
            
            if base.allianceHelpSwitch == 1 then
                local menu1 = tolua.cast(cell:getChildByTag(101), "CCMenu")
                local seekHelpBtn = tolua.cast(cell:getChildByTag(104), "CCMenu")
                if menu1 and seekHelpBtn then
                    local buildingSlotVo = buildingSlotVoApi:getSlotByBid(self.dataSource[k].id)
                    local selfAlliance = allianceVoApi:getSelfAlliance()
                    if selfAlliance and leftTime and leftTime > 0 and buildingSlotVo and buildingSlotVo.hid == nil and isFree == false then
                        seekHelpBtn:setVisible(true)
                        seekHelpBtn:setEnabled(true)
                        menu1:setVisible(false)
                        menu1:setEnabled(false)
                    else
                        seekHelpBtn:setVisible(false)
                        seekHelpBtn:setEnabled(false)
                        menu1:setVisible(true)
                        menu1:setEnabled(true)
                    end
                end
            end
            
        elseif self.dataSource[k].status == 1 then
            tolua.cast(cell:getChildByTag(21), "CCProgressTimer"):removeFromParentAndCleanup(true)
            tolua.cast(cell:getChildByTag(23), "CCSprite"):removeFromParentAndCleanup(true)
            self.dataSource = nil
            self.tableCell3 = {}
            self.tableCellItem3 = {}
            self.dataSource = {}
            self.dataSource = buildingVoApi:getBuildingsEnableUpgrade()
            self.tv:reloadData()
            break;
            
        end
        
    end
    
    -- 建筑自动升级功能开启
    if base.autoUpgrade == 1 then
        -- 当前为开启状态
        if self.switchMenuToggle and self.switchMenuToggle:getSelectedIndex() == 1 then
            -- 判断建筑自动升级是否暂停或者已使用完
            if self.isOpening == false and (buildingVoApi:getAutoUpgradeBuilding() == 0 or buildingVoApi:getAutoUpgradeExpire() - base.serverTime <= 0) then
                self.switchMenuToggle:setSelectedIndex(0)
                print("------dmj----9--setSelectedIndex(0)：--"..buildingVoApi:getAutoUpgradeBuilding())
                self:upDateAutoUpgradeIcon(true)
                -- self.openLb:setVisible(true)
                -- self.closeLb:setVisible(false)
            end
            if self.autoSwitchLabel then
                local autoExpire = buildingVoApi:getAutoUpgradeExpire() - base.serverTime
                self:controlDescLb()
                -- 剩余时间有效
                if autoExpire > 0 then
                    self.autoSwitchLabel:setString(GetTimeForItemStrState(autoExpire))
                    if self and self.autoExpireLabel then
                        self.autoExpireLabel:setString("("..GetTimeForItemStrState(autoExpire) .. ")")
                    end
                else
                    self.autoSwitchLabel:setString(getlocal("building_auto_upgrade_off"))
                    
                end
            end
        end
        -- 刷新tableview
        if base.refreshupgrade == true then
            self.tableCell3 = {}
            self.tableCellItem3 = {}
            -- local recordPoint = self.tv:getRecordPoint()
            self.tv:reloadData()
            -- self.tv:recoverToRecordPoint(recordPoint)
            print("刷新tableview~~~~~~~~~~~~~~")
            -- print("答应大噶发放222222222")
            base.refreshupgrade = nil
            -- 判断是否可自动升级建筑
            self:checkItemEnable()
        end
    end
end

--用户处理特殊需求,没有可以不写此方法
function playerDialogTab3:doUserHandler()
    
end

--点击了cell或cell上某个按钮
function playerDialogTab3:cellClick(idx)
    if self.tv:getScrollEnable() == true and self.tv:getIsScrolled() == false then
        if self.expandIdx["k" .. (idx - 1000)] == nil then
            self.expandIdx["k" .. (idx - 1000)] = idx - 1000
            self.tv:openByCellIndex(idx - 1000, 120)
        else
            self.expandIdx["k" .. (idx - 1000)] = nil
            self.tv:closeByCellIndex(idx - 1000, 800)
        end
    end
end

function playerDialogTab3:dispose()
    eventDispatcher:removeEventListener("speedUpProp.useProp", self.dialogListener)
    if self.speedUpSmallDialog then
        self.speedUpSmallDialog:close()
        self.speedUpSmallDialog = nil
    end
    self.isOpening = false
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer = nil;
    self.tv = nil;
    self.tableCell3 = {};
    self.tableCell3 = nil;
    self.tableCellItem3 = {};
    self.tableCellItem3 = nil;
    self.layerNum = nil;
    
    self.autoSwitchLabel = nil --自动升级的状态文字label
    self.switchMenuToggle = nil -- 自动升级的状态按钮
    self.autoUpgradeSpBg = nil -- 自动升级icon信息的背景精灵
    self.cellWidth = nil
    
end
