--[[
军团旗帜

@author JNK
]]

allianceFlagDialog = commonDialog:new()

function allianceFlagDialog:new(callBack)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.bgLayer = nil
    self.layerNum = nil
    self.showAllTab = {}
    self.showAllSelectId = {1, 1, 1}
    self.useAllId = {}
    self.selectAllState = {}
    self.curSelectedTab = 1
    self.lastSelectedTab = 0
    self.sortAllKey = {"icon", "frame", "color"}
    self.showTableViewSize = nil
    self.showCellSize = nil
    self.topTitleHeight = 86
    self.topContentHeight = 355
    self.bottomHeight = 0
    self.attrLbArr = {}
    self.timeLb = nil
    self.saveBtn = nil
    self.callBack = callBack

    --在这里加载图片
    local function addPlist()
        spriteController:addPlist("public/youhuaUI3.plist")
        spriteController:addTexture("public/youhuaUI3.png")
        spriteController:addPlist("public/allianceFlagEffect.plist")
        spriteController:addTexture("public/allianceFlagEffect.png")
    end
    G_addResource8888(addPlist)

    return nc
end

function allianceFlagDialog:resetTab()
    -- 排序数据
    self.showAllTab = {}
    for i,v in ipairs(self.sortAllKey) do
        local showList = {}
        -- 去除不显示的
        for k,vv in pairs(allianceFlagCfg[v]) do
            if vv.isShow == 1 then
                showList[k] = vv
            end
        end
        -- 排序key值
        self.showAllTab[i] = {}
        for k,vvv in pairs(showList) do
            table.insert(self.showAllTab[i], k)
        end
        local function sortFunc(a, b)
            local aData = showList[a]
            local bData = showList[b]
            return tonumber(aData.sortId) < tonumber(bData.sortId)
        end
        table.sort(self.showAllTab[i], sortFunc)
    end

    local alliance = allianceVoApi:getSelfAlliance()
    local isManager = false

    -- 对应军团旗帜图标组合
    local defaultSelect = allianceVoApi:getFlagIconTab(alliance.banner)
    for i,v in ipairs(self.showAllTab) do
        for ii,vv in ipairs(v) do
            if defaultSelect[i] == vv then
                self.showAllSelectId[i] = ii
                self.useAllId[i] = vv
            end
        end
    end

    if tostring(alliance.role) == "1" or tostring(alliance.role) == "2" then
        isManager = true
    else
        isManager = false
    end

    if isManager then
        self.bottomHeight = 140
    else
        self.bottomHeight = 20
    end

    -- 框下
    local showBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function () end)
    showBgSp:setContentSize(CCSizeMake(600, G_VisibleSizeHeight - self.bottomHeight - self.topTitleHeight - self.topContentHeight))
    showBgSp:setAnchorPoint(ccp(0.5, 0))
    showBgSp:setPosition(ccp(G_VisibleSizeWidth / 2, self.bottomHeight))
    self.bgLayer:addChild(showBgSp)
    self.BgBottom = showBgSp

    if isManager then
        -- 保存
        local oneKeyItem = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", function (tag, object)
            if G_checkClickEnable() == false then
                do
                    return
                end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end

            PlayEffect(audioCfg.mouseClick)

            local function saveCallBack(fn, data)
                local ret, sData = base:checkServerData(data)

                if ret == true then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("save_success"),30)

                    if self.bgLayer then
                        local flagEffect = self:createAnim()
                        flagEffect:setScale(1.6)
                        flagEffect:setPosition(self.flagShow:getPositionX(), self.flagShow:getPositionY() + 20)
                        self.bgLayer:addChild(flagEffect)
                    end

                    --更新自己军团的旗帜数据
                    allianceVoApi:formatSelfAllianceData(sData.data)
                    --更新世界地图数据
                    local alliance = allianceVoApi:getSelfAlliance()
                    local params = {}
                    params.data = sData.data
                    params.aid = alliance.aid
                    params.name = alliance.name
                    params.uid = playerVoApi:getUid()
                    local refreshMineTb = worldBaseVoApi:updateAllianceFlagData(params)
                    worldScene:refreshTileCell(refreshMineTb)
                    if self.tv then
                        local defaultSelect = allianceVoApi:getFlagIconTab(sData.data.banner)
                        for i,v in ipairs(defaultSelect) do
                            self.useAllId[i] = v
                        end
                        self.tv:reloadData()
                    end
                    --发送聊天消息通知全服更新世界地图军团旗帜
                    chatVoApi:sendUpdateMessage(58, params)
                end
            end

            for k,v in pairs(self.selectAllState) do
                if v == true then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allianceFlagTips1", {getlocal("allianceFlagTabName" .. k)}),30)
                    return
                end
            end

            local icon = self.showAllTab[1][self.showAllSelectId[1]]
            local frame = self.showAllTab[2][self.showAllSelectId[2]]
            local color = self.showAllTab[3][self.showAllSelectId[3]]
            socketHelper:allianceSetflag(saveCallBack, icon, frame, color)
        end, 101, getlocal("collect_border_save"), 30)
        local saveMenu = CCMenu:createWithItem(oneKeyItem)
        saveMenu:setPosition(ccp(G_VisibleSizeWidth / 2, self.bottomHeight / 2 - 5))
        saveMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
        self.bgLayer:addChild(saveMenu)
        self.saveBtn = oneKeyItem

        -- 倒计时
        self.timeLb = GetTTFLabel("", 22, true)
        self.timeLb:setAnchorPoint(ccp(0.5, 0.5))
        self.timeLb:setPosition(ccp(G_VisibleSizeWidth / 2, self.bottomHeight - 20))
        self.timeLb:setColor(G_ColorWhite)
        self.bgLayer:addChild(self.timeLb)
    end
    local adaW = 0
    local strsize = 20
    if G_isAsia() == false then
        adaW = 35
        strsize = 17
    end
    if G_getCurChoseLanguage() =="ko" then
        strsize = 17
    end
    for i=1,6 do
        -- 属性显示
        local titleLb = GetTTFLabel(getlocal("allianceFlagAttrTitle" .. i), strsize, true)
        titleLb:setAnchorPoint(ccp(0, 0.5))
        titleLb:setColor(G_ColorWhite)
        titleLb:setPosition(280-adaW, G_VisibleSizeHeight - self.topTitleHeight - 45 - 43 * (i - 1))
        self.bgLayer:addChild(titleLb)

        self.attrLbArr[i] = GetTTFLabel("", strsize, true)
        self.attrLbArr[i]:setAnchorPoint(ccp(0, 0.5))
        self.attrLbArr[i]:setColor(G_ColorWhite)
        self.attrLbArr[i]:setPosition(titleLb:getPositionX() + titleLb:getContentSize().width, G_VisibleSizeHeight - self.topTitleHeight - 45 - 43 * (i - 1))
        self.bgLayer:addChild(self.attrLbArr[i])
    end
end

function allianceFlagDialog:doUserHandler()
    self.panelLineBg:setVisible(false)
end

function allianceFlagDialog:initTableView()
    local titleTab = {getlocal("allianceFlagTabName1"), getlocal("allianceFlagTabName2"), getlocal("allianceFlagTabName3")}
    self.allTabBtn = {}
    self.allTabRed = {}
    local tabPosY = self.BgBottom:getPositionY() + self.BgBottom:getContentSize().height
    local tabBtn = CCMenu:create()
    for i,v in pairs(titleTab) do
        local tabBtnItem = CCMenuItemImage:create("yh_ltzdzHelp_tab.png", "yh_ltzdzHelp_tab_down.png", "yh_ltzdzHelp_tab_down.png")
        tabBtnItem:setAnchorPoint(ccp(0, 1))
        tabBtnItem:setPosition(20 + (i - 1) * (tabBtnItem:getContentSize().width + 4), tabPosY + tabBtnItem:getContentSize().height)
        tabBtn:addChild(tabBtnItem)
        tabBtnItem:setTag(i)
        local strsize = 24
        if G_getCurChoseLanguage() == "de" and i == 2 then
            strsize = 20
        end
        local lb = GetTTFLabelWrap(v, strsize, CCSizeMake(tabBtnItem:getContentSize().width, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
        lb:setPosition(CCPointMake(tabBtnItem:getContentSize().width / 2, tabBtnItem:getContentSize().height / 2))
        tabBtnItem:addChild(lb, 1)

        local function tabClick(idx)
            PlayEffect(audioCfg.mouseClick)
            return self:tabBtnClick(idx)
        end
        tabBtnItem:registerScriptTapHandler(tabClick)
        self.allTabBtn[i] = tabBtnItem

        -- 红点
        self.allTabRed[i] = CCSprite:createWithSpriteFrameName("NumBg.png")
        self.allTabRed[i]:setPosition(tabBtnItem:getPositionX() + tabBtnItem:getContentSize().width - 15, tabBtnItem:getPositionY())
        self.allTabRed[i]:setVisible(false)
        self.allTabRed[i]:setScale(0.7)
        self.bgLayer:addChild(self.allTabRed[i], 5)
    end
    tabBtn:setPosition(0, 0)
    tabBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    self.bgLayer:addChild(tabBtn)

    local function tableViewCallBack(...)
        return self:eventHandlerNew(...)
    end
    local tvSize = self.BgBottom:getContentSize()
    local hd = LuaEventHandler:createHandler(tableViewCallBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(tvSize.width - 5, tvSize.height - 5), nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition(ccp((G_VisibleSizeWidth - self.BgBottom:getContentSize().width) / 2 + 2.5, self.BgBottom:getPositionY() + 2.5))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(80)

    self:tabBtnClick(self.curSelectedTab)

    self.flagShow = allianceVoApi:createShowFlag(self.showAllTab[1][self.showAllSelectId[1]], self.showAllTab[2][self.showAllSelectId[2]], self.showAllTab[3][self.showAllSelectId[3]], 0.8,
        -(self.layerNum - 1) * 20 - 5, 
        function ()
            -- 跳转属性查看
            self:lookAttrAll()
        end
    )
    self.flagShow:setPosition(140, G_VisibleSizeHeight - self.topTitleHeight - self.topContentHeight / 2 + 35)
    self.bgLayer:addChild(self.flagShow)

    local function jumpToAttrLook()
        -- 跳转属性查看
        self:lookAttrAll()
    end
    local attrLookLb = GetTTFLabel(getlocal("battlebuff_overview"), 22, true)
    attrLookLb:setAnchorPoint(ccp(0.5, 0))
    local line = CCLayerColor:create(ccc4(255, 255, 255, 255))
    line:setContentSize(CCSizeMake(attrLookLb:getContentSize().width + 4, 2))
    line:setPosition(-2, -2)
    attrLookLb:addChild(line)
    local menuItem = CCMenuItemLabel:create(attrLookLb)
    menuItem:registerScriptTapHandler(jumpToAttrLook)
    local menu = CCMenu:createWithItem(menuItem)
    menu:setAnchorPoint(ccp(0.5, 0.5))
    menu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    menu:setPosition(self.flagShow:getPositionX(), self.flagShow:getPositionY() - self.topContentHeight / 2 + 65)
    self.bgLayer:addChild(menu)

    -- 属性显示
    self:setFlagInfo(1, self.showAllTab[1][self.showAllSelectId[1]])
    self:setFlagInfo(2, self.showAllTab[2][self.showAllSelectId[2]])
    self:setFlagInfo(3, self.showAllTab[3][self.showAllSelectId[3]])
end

function allianceFlagDialog:tabBtnClick(idx)
    local update = true
    if self.curSelectedTab == idx then
        update = false
    end

    for k,v in pairs(self.allTabBtn) do
        if v:getTag() == idx then
            v:setEnabled(false)
            self.curSelectedTab = idx
        else
            v:setEnabled(true)
        end
    end

    if self.lastSelectedTab ~= self.curSelectedTab and self.lastSelectedTab > 0 then
        allianceVoApi:setFlagNewTips(self.lastSelectedTab, nil, -1)
    end
    self.lastSelectedTab = self.curSelectedTab

    if update and self.tv then
        local selectId = self.showAllSelectId[self.curSelectedTab]
        self.tv:reloadData()
    end
end

function allianceFlagDialog:eventHandlerNew(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return 1
    elseif fn == "tableCellSizeForIndex" then
        local cellHeight = 100
        if self.curSelectedTab == 3 then
            self.showCellSize = CCSizeMake(145, 180)
            cellHeight = math.ceil(SizeOfTable(self.showAllTab[self.curSelectedTab]) / 4) * self.showCellSize.height
        elseif self.curSelectedTab == 2 then
            self.showCellSize = CCSizeMake(145, 180) -- CCSizeMake(194, 320)
            cellHeight = math.ceil(SizeOfTable(self.showAllTab[self.curSelectedTab]) / 4) * self.showCellSize.height
        else
            self.showCellSize = CCSizeMake(145, 180)
            cellHeight = math.ceil(SizeOfTable(self.showAllTab[self.curSelectedTab]) / 4) * self.showCellSize.height
        end

        self.showTableViewSize = CCSizeMake(self.BgBottom:getContentSize().width - 5, cellHeight)
        return self.showTableViewSize
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()

        -- 选中框
        local selectSp = LuaCCScale9Sprite:createWithSpriteFrameName("newSelectKuang.png", CCRect(30, 30, 1, 1),function()end)
        selectSp:setAnchorPoint(ccp(0.5, 0.5))
        selectSp:setVisible(false)
        cell:addChild(selectSp, 10)

        -- 使用中
        local useSp = LuaCCScale9Sprite:createWithSpriteFrameName("newBlackBg.png", CCRect(3, 3, 3, 3), function() end)
        useSp:setAnchorPoint(ccp(0.5, 0))
        useSp:setVisible(false)
        useSp:setOpacity(127)
        cell:addChild(useSp, 5)
        -- 使用中文字
        local useLb = GetTTFLabel(getlocal("in_use"), 18, true)
        useLb:setAnchorPoint(ccp(0.5, 0.5))
        useLb:setColor(G_ColorWhite)
        useLb:setVisible(false)
        cell:addChild(useLb, 6)

        self["addTabCell" .. self.curSelectedTab](self, cell, selectSp, useSp, useLb)

        return cell
    elseif fn == "ccTouchBegan" then
        return true
    elseif fn == "ccTouchMoved" then
    elseif fn == "ccTouchEnded" then
    end
end

function allianceFlagDialog:addTabCell1(cell, selectSp, useSp, useLb)
    selectSp:setContentSize(CCSizeMake(130, 130))
    useSp:setContentSize(CCSizeMake(126, 25))

    for i=1, SizeOfTable(self.showAllTab[self.curSelectedTab]) do
        local currentTabKey = self.sortAllKey[self.curSelectedTab]
        local currentKey = self.showAllTab[self.curSelectedTab][i]
        local currentDataCfg = allianceFlagCfg[currentTabKey][currentKey]
        local pointSp
        local function touchIconCallBack()
            if tostring(i) == tostring(self.curSelectedHeadId) then
                return
            end

            if self.tv:getScrollEnable() == true and self.tv:getIsScrolled() == false then
                if G_checkClickEnable() == false then
                    do
                        return
                    end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)

                selectSp:setPosition(pointSp:getPosition())
                selectSp:setVisible(true)
                self.showAllSelectId[self.curSelectedTab] = i

                self:setFlagInfo(1, self.showAllTab[1][self.showAllSelectId[1]])
                self:setFlagIcon()
            end
        end

        local posX = ((i - 1) % 4 + 0.5) * self.showCellSize.width + (self.showTableViewSize.width - self.showCellSize.width * 4) / 2
        local posY = self.showTableViewSize.height - (math.floor((i - 1) / 4)) * self.showCellSize.height

        -- 底板
        local bgSp = LuaCCScale9Sprite:createWithSpriteFrameName("fi_bubble_bg.png", CCRect(3, 3, 3, 3), function() end)
        bgSp:setContentSize(CCSizeMake(130, 130))
        bgSp:setAnchorPoint(ccp(0.5, 0.5))
        bgSp:setPosition(posX, posY - 80)
        cell:addChild(bgSp)

        -- 图标
        pointSp = LuaCCSprite:createWithSpriteFrameName(currentDataCfg.pic .. ".png", touchIconCallBack)
        pointSp:setAnchorPoint(ccp(0.5, 0.5))
        pointSp:setPosition(bgSp:getPositionX(), bgSp:getPositionY())
        cell:addChild(pointSp)
        pointSp:setTouchPriority(-(self.layerNum - 1) * 20 - 2)

        -- 状态
        local stateLb
        local attr, limit, lock = allianceVoApi:getShowFlagAttr(1, currentKey)
        if lock == true then
            -- 遮罩
            local sp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10,10,1,1), function() end)
            sp:setContentSize(CCSizeMake(bgSp:getContentSize().width*bgSp:getScale(),bgSp:getContentSize().height*bgSp:getScale()))
            sp:setPosition(bgSp:getPosition())
            sp:setOpacity(140)
            cell:addChild(sp)

            local lock = CCSprite:createWithSpriteFrameName("aitroops_lock.png")
            lock:setScale(0.7)
            lock:setPosition(posX + 40, posY - self.showCellSize.height + 65)
            cell:addChild(lock)

            stateLb = GetTTFLabel(getlocal("decorateTabitem1"), 20, true)
            stateLb:setColor(G_ColorRed)
        else
            stateLb = GetTTFLabel(getlocal("decorateTabitem2"), 20, true)
            stateLb:setColor(G_ColorGreen)
        end
        stateLb:setAnchorPoint(ccp(0.5, 0.5))
        stateLb:setPosition(posX, posY - self.showCellSize.height + 15)
        cell:addChild(stateLb)

        if allianceVoApi:getFlagNewTips()[self.curSelectedTab] and allianceVoApi:getFlagNewTips()[self.curSelectedTab][currentKey] == 1 then
            self:addNewTips(cell, ccp(bgSp:getPositionX()-bgSp:getContentSize().width/2, bgSp:getPositionY()+bgSp:getContentSize().height/2))
        end

        -- 使用中
        if currentKey == self.useAllId[1] then
            useSp:setPosition(pointSp:getPositionX(), pointSp:getPositionY() - bgSp:getContentSize().height / 2 + 2)
            useSp:setVisible(true)
            useLb:setPosition(useSp:getPositionX(), useSp:getPositionY() + useSp:getContentSize().height / 2)
            useLb:setVisible(true)
        end

        if tostring(i) == tostring(self.showAllSelectId[self.curSelectedTab]) then
            selectSp:setPosition(pointSp:getPosition())
            selectSp:setVisible(true)
        end
    end
end

function allianceFlagDialog:addTabCell2(cell, selectSp, useSp, useLb)
    local selectSize = CCSizeMake(130, 130) -- CCSizeMake(194, 270)
    selectSp:setContentSize(selectSize)
    useSp:setContentSize(CCSizeMake(selectSize.width, 25))

    for i=1, SizeOfTable(self.showAllTab[self.curSelectedTab]) do
        local currentTabKey = self.sortAllKey[self.curSelectedTab]
        local currentKey = self.showAllTab[self.curSelectedTab][i]
        local currentDataCfg = allianceFlagCfg[currentTabKey][currentKey]
        local pointSp
        local function touchIconCallBack()
            if tostring(i) == tostring(self.curSelectedHeadId) then
                return
            end

            if self.tv:getScrollEnable() == true and self.tv:getIsScrolled() == false then
                if G_checkClickEnable() == false then
                    do
                        return
                    end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)

                selectSp:setPosition(pointSp:getPosition())
                selectSp:setVisible(true)
                self.showAllSelectId[self.curSelectedTab] = i

                self:setFlagInfo(2, self.showAllTab[2][self.showAllSelectId[2]])
                self:setFlagIcon()
            end
        end

        local posX = ((i - 1) % 4 + 0.5) * self.showCellSize.width + (self.showTableViewSize.width - self.showCellSize.width * 4) / 2
        local posY = self.showTableViewSize.height - (math.floor((i - 1) / 4)) * self.showCellSize.height

        -- 底板
        local bgSp = LuaCCScale9Sprite:createWithSpriteFrameName("fi_bubble_bg.png", CCRect(3, 3, 3, 3), function() end)
        bgSp:setContentSize(selectSize)
        bgSp:setAnchorPoint(ccp(0.5, 0.5))
        bgSp:setPosition(posX, posY - selectSize.height / 2 - 15)
        cell:addChild(bgSp)

        -- 图标
        pointSp = LuaCCSprite:createWithSpriteFrameName(currentDataCfg.pic .. ".png", touchIconCallBack)
        pointSp:setAnchorPoint(ccp(0.5, 0.5))
        pointSp:setPosition(bgSp:getPositionX(), bgSp:getPositionY())
        pointSp:setScale(0.45)
        cell:addChild(pointSp)
        pointSp:setTouchPriority(-(self.layerNum - 1) * 20 - 2)

        -- 状态
        local attr, limit, lock = allianceVoApi:getShowFlagAttr(2, currentKey)
        if lock == true then
            -- 遮罩
            local sp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10,10,1,1), function() end)
            sp:setContentSize(CCSizeMake(bgSp:getContentSize().width*bgSp:getScale(),bgSp:getContentSize().height*bgSp:getScale()))
            sp:setPosition(bgSp:getPosition())
            sp:setOpacity(140)
            cell:addChild(sp)

            local lock = CCSprite:createWithSpriteFrameName("LockIconCheckPoint.png")
            lock:setPosition(posX + 40, posY - self.showCellSize.height + 65)
            cell:addChild(lock)

            stateLb = GetTTFLabel(getlocal("decorateTabitem1"), 20, true)
            stateLb:setColor(G_ColorRed)
        else
            stateLb = GetTTFLabel(getlocal("decorateTabitem2"), 20, true)
            stateLb:setColor(G_ColorGreen)
        end
        stateLb:setPosition(posX, posY - self.showCellSize.height + 15)
        cell:addChild(stateLb)

        -- 使用中
        if currentKey == self.useAllId[2] then
            useSp:setPosition(pointSp:getPositionX(), pointSp:getPositionY() - bgSp:getContentSize().height / 2 + 2)
            useSp:setVisible(true)
            useLb:setPosition(useSp:getPositionX(), useSp:getPositionY() + useSp:getContentSize().height / 2)
            useLb:setVisible(true)
        end

        if tostring(i) == tostring(self.showAllSelectId[self.curSelectedTab]) then
            selectSp:setPosition(pointSp:getPosition())
            selectSp:setVisible(true)
        end
    end
end

function allianceFlagDialog:addTabCell3(cell, selectSp, useSp, useLb)
    selectSp:setContentSize(CCSizeMake(130, 130))
    useSp:setContentSize(CCSizeMake(126, 25))

    for i=1, SizeOfTable(self.showAllTab[self.curSelectedTab]) do
        local currentTabKey = self.sortAllKey[self.curSelectedTab]
        local currentKey = self.showAllTab[self.curSelectedTab][i]
        local currentDataCfg = allianceFlagCfg[currentTabKey][currentKey]
        local pointSp
        local function touchIconCallBack()
            if tostring(i) == tostring(self.curSelectedHeadId) then
                return
            end

            if self.tv:getScrollEnable() == true and self.tv:getIsScrolled() == false then
                if G_checkClickEnable() == false then
                    do
                        return
                    end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)

                selectSp:setPosition(pointSp:getPosition())
                selectSp:setVisible(true)
                self.showAllSelectId[self.curSelectedTab] = i
                
                self:setFlagInfo(3, self.showAllTab[3][self.showAllSelectId[3]])
                self:setFlagIcon()
            end
        end

        local posX = ((i - 1) % 4 + 0.5) * self.showCellSize.width + (self.showTableViewSize.width - self.showCellSize.width * 4) / 2
        local posY = self.showTableViewSize.height - (math.floor((i - 1) / 4)) * self.showCellSize.height

        -- 底板
        local bgSp = LuaCCScale9Sprite:createWithSpriteFrameName("fi_bubble_bg.png", CCRect(3, 3, 3, 3), function() end)
        bgSp:setContentSize(CCSizeMake(130, 130))
        bgSp:setAnchorPoint(ccp(0.5, 0.5))
        bgSp:setPosition(posX, posY - 80)
        cell:addChild(bgSp)

        -- 图标
        pointSp = LuaCCSprite:createWithSpriteFrameName("allianceFlagBox.png", touchIconCallBack)
        pointSp:setAnchorPoint(ccp(0.5, 0.5))
        pointSp:setPosition(bgSp:getPositionX(), bgSp:getPositionY())
        cell:addChild(pointSp)
        pointSp:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
        pointSp:setScale(1.5)
        pointSp:setColor(ccc3(currentDataCfg.color[1],currentDataCfg.color[2],currentDataCfg.color[3]))

        -- 状态
        local stateLb
        local attr, limit, lock = allianceVoApi:getShowFlagAttr(3, currentKey)
        if lock == true then
            -- 遮罩
            local sp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10,10,1,1), function() end)
            sp:setContentSize(CCSizeMake(bgSp:getContentSize().width*bgSp:getScale(),bgSp:getContentSize().height*bgSp:getScale()))
            sp:setPosition(bgSp:getPosition())
            sp:setOpacity(140)
            cell:addChild(sp)

            local lock = CCSprite:createWithSpriteFrameName("LockIconCheckPoint.png")
            lock:setPosition(posX + 40, posY - self.showCellSize.height + 65)
            cell:addChild(lock)

            stateLb = GetTTFLabel(getlocal("decorateTabitem1"), 20, true)
            stateLb:setColor(G_ColorRed)
        else
            stateLb = GetTTFLabel(getlocal("decorateTabitem2"), 20, true)
            stateLb:setColor(G_ColorGreen)
        end
        stateLb:setAnchorPoint(ccp(0.5, 0.5))
        stateLb:setPosition(posX, posY - self.showCellSize.height + 15)
        cell:addChild(stateLb)

        if allianceVoApi:getFlagNewTips()[self.curSelectedTab] and allianceVoApi:getFlagNewTips()[self.curSelectedTab][currentKey] == 1 then
            self:addNewTips(cell, ccp(bgSp:getPositionX()-bgSp:getContentSize().width/2, bgSp:getPositionY()+bgSp:getContentSize().height/2))
        end

        -- 使用中
        if currentKey == self.useAllId[3] then
            useSp:setPosition(pointSp:getPositionX(), pointSp:getPositionY() - bgSp:getContentSize().height / 2 + 2)
            useSp:setVisible(true)
            useLb:setPosition(useSp:getPositionX(), useSp:getPositionY() + useSp:getContentSize().height / 2)
            useLb:setVisible(true)
        end

        if tostring(i) == tostring(self.showAllSelectId[self.curSelectedTab]) then
            selectSp:setPosition(pointSp:getPosition())
            selectSp:setVisible(true)
        end
    end
end

-- 设置旗帜属性信息
function allianceFlagDialog:setFlagInfo(flagType, flagKey)
    local attr, limit, lock = allianceVoApi:getShowFlagAttr(flagType, flagKey)
    local i = (flagType - 1) * 2
    self.attrLbArr[i + 1]:setString("" .. attr)
    self.attrLbArr[i + 2]:setString("" .. limit)

    if lock then
        self.attrLbArr[i + 2]:setColor(G_ColorRed)
    else
        self.attrLbArr[i + 2]:setColor(G_ColorWhite)
    end

    self.selectAllState[flagType] = lock
end

-- 设置旗帜显示
function allianceFlagDialog:setFlagIcon()
    allianceVoApi:setShowFlag(self.flagShow, self.showAllTab[1][self.showAllSelectId[1]], self.showAllTab[2][self.showAllSelectId[2]], self.showAllTab[3][self.showAllSelectId[3]])
end

function allianceFlagDialog:lookAttrAll()
    require "luascript/script/game/scene/gamedialog/allianceDialog/allianceFlagAttrAllDialog"
    allianceFlagAttrAllDialog:showFlagAttrAllDialog(self.layerNum + 1)
end

function allianceFlagDialog:tick()
    if self.timeLb then
        local alliance = allianceVoApi:getSelfAlliance()
        local time = tonumber(alliance.banner_at or 0) + allianceFlagCfg.saveCd - base.serverTime

        self.timeLb:setVisible(time >= 0)
        self.saveBtn:setEnabled(time < 0)

        if time >= 0 then
            self.timeLb:setString(G_formatActiveDate(time))
        end
    end

    local allianceFlagUnlock = allianceVoApi:getFlagNewTips()
    for i=1,3 do
        if allianceFlagUnlock then
            local unlockNum = SizeOfTable(allianceFlagUnlock[i])
            if unlockNum > 0 then
                self.allTabRed[i]:setVisible(true)
            else
                self.allTabRed[i]:setVisible(false)
            end
        end
    end
end
function allianceFlagDialog:addNewTips(node, pos)
    --此处添加‘新’的图片和文字
    local newSp = CCSprite:createWithSpriteFrameName("fi_newFlag.png")
    newSp:setAnchorPoint(ccp(0,1))
    newSp:setPosition(pos.x, pos.y)
    node:addChild(newSp, 10)
    newSp:setScale(0.7)
    local newLb = GetTTFLabel(getlocal("new_text"), 14/newSp:getScale(), true)
    newLb:setPosition(newSp:getContentSize().width/2-12, newSp:getContentSize().height/2+15)
    newLb:setRotation(-47)
    newLb:setColor(G_ColorYellow)
    newSp:addChild(newLb)
end

function allianceFlagDialog:createAnim()
    local firstSp = CCSprite:createWithSpriteFrameName("animationFlagEffect_1.png")
    G_setBlendFunc(firstSp, GL_ONE, GL_ONE)
    local frameArray = CCArray:create()
    for i = 1, 25 do
        local frameName = "animationFlagEffect_" .. i .. ".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(frameName)
        if frame then
            frameArray:addObject(frame)
        end
    end
    local animation = CCAnimation:createWithSpriteFrames(frameArray, 0.05)
    local animate = CCAnimate:create(animation)
    local animArray = CCArray:create()
    animArray:addObject(animate)
    animArray:addObject(CCCallFunc:create(function()
            firstSp:removeFromParentAndCleanup(true)
        end))
    firstSp:runAction(CCSequence:create(animArray))

    return firstSp
end

function allianceFlagDialog:dispose()
    if self.callBack then
        self.callBack()
    end

    self.bgLayer = nil
    self.layerNum = nil
    self.showAllTab = nil
    self.showAllSelectId = nil
    self.useAllId = nil
    self.selectAllState = nil
    self.curSelectedTab = nil
    self.lastSelectedTab = nil
    self.sortAllKey = nil
    self.showTableViewSize = nil
    self.showCellSize = nil
    self.topTitleHeight = nil
    self.topContentHeight = nil
    self.bottomHeight = nil
    self.attrLbArr = nil
    self.timeLb = nil
    self.callBack = nil

    -- 关闭面板清楚第一个页签显示数据
    allianceVoApi:setFlagNewTips(1, nil, -1)

    spriteController:removePlist("public/youhuaUI3.plist")
    spriteController:removeTexture("public/youhuaUI3.png")
    spriteController:addPlist("public/allianceFlagEffect.plist")
    spriteController:addTexture("public/allianceFlagEffect.png")
end