acMemoryServerTabOne = {}

function acMemoryServerTabOne:new(layerNum)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.layerNum = layerNum
    G_addResource8888(function()
        spriteController:addPlist("public/juntuanCityBtns.plist")
        spriteController:addTexture("public/juntuanCityBtns.png")
        spriteController:addPlist("public/youhuaUI4.plist")
        spriteController:addTexture("public/youhuaUI4.png")
        spriteController:addPlist("public/youhuaUI3.plist")
        spriteController:addTexture("public/youhuaUI3.png")
    end)
    return nc
end

function acMemoryServerTabOne:init()
    self.bgLayer = CCLayer:create()
    self:initUI()
    return self.bgLayer
end

function acMemoryServerTabOne:initUI()
    local topInfoBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("acMS_cellBg.png", CCRect(4, 4, 2, 2), function()end)
    topInfoBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth - 30, 180))
    topInfoBgSp:setAnchorPoint(ccp(0.5, 1))
    topInfoBgSp:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 165))
    self.bgLayer:addChild(topInfoBgSp)
    local function showInfo()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local tabStr = {
            getlocal("acMemoryServer_i_tab1Desc1", {acMemoryServerVoApi:getBindLimitLevel()}),
            getlocal("acMemoryServer_i_tab1Desc2"),
            getlocal("acMemoryServer_i_tab1Desc3"),
            getlocal("acMemoryServer_i_tab1Desc4"),
            getlocal("acMemoryServer_i_tab1Desc5"),
        }
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, getlocal("activity_baseLeveling_ruleTitle"), tabStr, nil, 25)
    end
    local infoBtn = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", showInfo)
    infoBtn:setAnchorPoint(ccp(1, 1))
    infoBtn:setScale(0.7)
    local infoMenu = CCMenu:createWithItem(infoBtn)
    infoMenu:setPosition(ccp(topInfoBgSp:getContentSize().width - 10, topInfoBgSp:getContentSize().height - 10))
    infoMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    topInfoBgSp:addChild(infoMenu)
    local topContentBg = CCNode:create()
    topContentBg:setContentSize(topInfoBgSp:getContentSize())
    topContentBg:setAnchorPoint(topInfoBgSp:getAnchorPoint())
    topContentBg:setPosition(ccp(topInfoBgSp:getPosition()))
    self.bgLayer:addChild(topContentBg)
    self.topContentBg = topContentBg
    
    if acMemoryServerVoApi:isBind() then
        self:showBindInfoUI()
    else
        local selectServerBg, selectServerLb, nameAndLevelLb, bindBtn, shadeBg, selectedServerData
        local function onClickSelectServer()
            local serverListStartPos = selectServerBg:getParent():convertToWorldSpace(ccp(selectServerBg:getPosition()))
            self:showServerList(selectServerBg:getContentSize().width, serverListStartPos, function(serCfgData)
                selectedServerData = G_clone(serCfgData)
                if selectServerLb then
                    selectServerLb:setString(selectedServerData.name)
                end
                if nameAndLevelLb then
                    nameAndLevelLb:setString(getlocal("acMemoryServer_notPlayerTips"))
                end
                if bindBtn then
                    bindBtn:setEnabled(false)
                end
                local u_zoneid
                local userName = (base.platformUserId==nil and G_getTankUserName() or base.platformUserId)
                if selectedServerData.oldzoneid and selectedServerData.oldzoneid ~= "" and tonumber(selectedServerData.oldzoneid) > 0 then
                    u_zoneid = tonumber(selectedServerData.oldzoneid)
                else
                    u_zoneid = tonumber(selectedServerData.zoneid)
                end
                local b_uid = acMemoryServerVoApi:httpRequestUID(userName, u_zoneid, selectedServerData)
                if b_uid and b_uid > 0 then
                    selectedServerData["uid"] = b_uid
                    local b_zoneId = tonumber(selectedServerData.zoneid)
                    local b_host = tostring(selectedServerData.ip)
                    local b_port = tonumber(selectedServerData.port)
                    acMemoryServerVoApi:requestBindUserInfo(function(uData)
                        if uData and type(uData.level) == "number" then
                            selectedServerData["uData"] = uData
                            if nameAndLevelLb then
                                nameAndLevelLb:setString(getlocal("fightLevel", {uData.level}) .. "-" .. getlocal("VIPStr1", {uData.vip}) .. "-" .. uData.nickname)
                            end
                            if bindBtn then
                                bindBtn:setEnabled(true)
                            end
                        end
                    end, b_uid, b_zoneId, b_host, b_port)
                end
            end)
        end
        selectServerBg = LuaCCScale9Sprite:createWithSpriteFrameName("acMS_serverBg.png", CCRect(20, 20, 4, 4), onClickSelectServer)
        selectServerBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
        selectServerBg:setContentSize(CCSizeMake(335, selectServerBg:getContentSize().height))
        selectServerBg:setAnchorPoint(ccp(0, 0))
        selectServerBg:setPosition(ccp(30, topContentBg:getContentSize().height / 2))
        topContentBg:addChild(selectServerBg)
        local nameAndLevelBg = LuaCCScale9Sprite:createWithSpriteFrameName("acMS_serverBg.png", CCRect(20, 20, 4, 4), function()end)
        nameAndLevelBg:setContentSize(CCSizeMake(335, nameAndLevelBg:getContentSize().height))
        nameAndLevelBg:setAnchorPoint(ccp(0, 1))
        nameAndLevelBg:setPosition(ccp(30, topContentBg:getContentSize().height / 2 - 4))
        topContentBg:addChild(nameAndLevelBg)
        local arraowSp = CCSprite:createWithSpriteFrameName("expandBtn.png")
        arraowSp:setRotation(90)
        arraowSp:setPosition(ccp(selectServerBg:getContentSize().width - arraowSp:getContentSize().width, selectServerBg:getContentSize().height / 2))
        selectServerBg:addChild(arraowSp)
        selectServerLb = GetTTFLabel(getlocal("acMemoryServer_onClickSelectServer"), 20)
        selectServerLb:setPosition(ccp(selectServerBg:getContentSize().width / 2 - 20, selectServerBg:getContentSize().height / 2))
        selectServerBg:addChild(selectServerLb)
        nameAndLevelLb = GetTTFLabelWrap(getlocal("acMemoryServer_oldSoldiersNameAndLevel"), 20, CCSizeMake(nameAndLevelBg:getContentSize().width, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        nameAndLevelLb:setPosition(ccp(nameAndLevelBg:getContentSize().width / 2 - 20, nameAndLevelBg:getContentSize().height / 2))
        nameAndLevelBg:addChild(nameAndLevelLb)
        local function onClickBind(tag, obj)
            if G_checkClickEnable() == false then
                do return end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            if selectedServerData and selectedServerData.uid then
                local limitLevel = acMemoryServerVoApi:getBindLimitLevel()
                if selectedServerData.uData.level >= limitLevel then
                    local tipsParams = {selectedServerData.name, selectedServerData.uData.nickname, selectedServerData.uData.level}
                    G_showSureAndCancle(getlocal("acMemoryServer_bindingSureTips", tipsParams), function()
                        local b_uid = selectedServerData.uid
                        local b_zoneId = tonumber(selectedServerData.zoneid)
                        local b_host = tostring(selectedServerData.ip)
                        local b_port = tonumber(selectedServerData.port)
                        local b_oldZoneId = (selectedServerData.oldzoneid ~= nil and tonumber(selectedServerData.oldzoneid) > 0) and tonumber(selectedServerData.oldzoneid) or b_zoneId
                        acMemoryServerVoApi:requestBind(function()
                            self:showBindInfoUI()
                            if shadeBg then
                                shadeBg:removeFromParentAndCleanup(true)
                                shadeBg = nil
                            end
                        end, b_uid, b_zoneId, b_host, b_port, b_oldZoneId)
                    end)
                else
                    G_showTipsDialog(getlocal("acMemoryServer_bindingOldSoldiersLvTips", {limitLevel}))
                end
            end
        end
        local bindBtnScale = 0.6
        bindBtn = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", onClickBind, 11, getlocal("bindText"), 24 / bindBtnScale)
        local btnMenu = CCMenu:createWithItem(bindBtn)
        btnMenu:setPosition(ccp(0, 0))
        btnMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
        topContentBg:addChild(btnMenu)
        bindBtn:setScale(bindBtnScale)
        bindBtn:setAnchorPoint(ccp(1, 0))
        bindBtn:setPosition(ccp(topContentBg:getContentSize().width - 10, 10))
        bindBtn:setEnabled(false)
        
        shadeBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
        shadeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, topContentBg:getPositionY() - topContentBg:getContentSize().height))
        shadeBg:setAnchorPoint(ccp(0.5, 1))
        shadeBg:setPosition(ccp(G_VisibleSizeWidth / 2, topContentBg:getPositionY() - topContentBg:getContentSize().height))
        shadeBg:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
        shadeBg:setOpacity(255 * 0.85)
        self.bgLayer:addChild(shadeBg, 1)
        local shadeTipsLb = GetTTFLabelWrap(getlocal("acMemoryServer_pleaseBindTips"), 25, CCSizeMake(shadeBg:getContentSize().width - 30, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        shadeTipsLb:setPosition(ccp(shadeBg:getContentSize().width / 2, shadeBg:getContentSize().height * 0.73))
        shadeTipsLb:setColor(G_ColorYellowPro2)
        shadeBg:addChild(shadeTipsLb)
    end
    
    self.taskList = acMemoryServerVoApi:getTaskList(1)
    local taskTvSize = CCSizeMake(topContentBg:getContentSize().width, topContentBg:getPositionY() - topContentBg:getContentSize().height - 40)
    local taskTv = G_createTableView(taskTvSize, SizeOfTable(self.taskList), CCSizeMake(taskTvSize.width, 150), function(...) self:showTaskTvCell(...) end)
    taskTv:setPosition(ccp((G_VisibleSizeWidth - taskTvSize.width) / 2, 20))
    taskTv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    -- taskTv:setMaxDisToBottomOrTop(0)
    self.bgLayer:addChild(taskTv)
    self.taskTv = taskTv
end

function acMemoryServerTabOne:responseInitData()
    if self then
        self:showBindInfoUI()
        if self.taskTv then
            self.taskTv:reloadData()
        end
    end
end

function acMemoryServerTabOne:showBindInfoUI()
    if self and tolua.cast(self.topContentBg, "CCNode") then
        local topContentBg = tolua.cast(self.topContentBg, "CCNode")
        topContentBg:removeAllChildrenWithCleanup(true)
        local bindLb = GetTTFLabel(getlocal("accessory_bindOver"), 22)
        bindLb:setAnchorPoint(ccp(1, 0))
        bindLb:setPosition(ccp(topContentBg:getContentSize().width - 15, 15))
        bindLb:setColor(G_ColorGreen)
        topContentBg:addChild(bindLb)
        local playerData = acMemoryServerVoApi:getBindPlayerData()
        if playerData then
            local playerIcon = playerVoApi:GetPlayerBgIcon(playerVoApi:getPersonPhotoName(playerData.pic), nil, nil, nil, topContentBg:getContentSize().height - 60, playerData.hfid or headFrameCfg.default)
            playerIcon:setAnchorPoint(ccp(0, 0.5))
            playerIcon:setPosition(ccp(20, topContentBg:getContentSize().height / 2))
            topContentBg:addChild(playerIcon)
            local bindPlayerSerName = acMemoryServerVoApi:getBindPlayerServerName()
            local playerNameLbWidth = topContentBg:getContentSize().width - (playerIcon:getPositionX() + playerIcon:getContentSize().width * playerIcon:getScale() + 20) - 80
            local playerNameLb = GetTTFLabelWrap(bindPlayerSerName .. "-" .. playerData.nickname, 24, CCSizeMake(playerNameLbWidth, 0), kCCTextAlignmentLeft, kCCTextAlignmentCenter)
            local playerLevelLb = GetTTFLabel(getlocal("fightLevel", {playerData.level}), 24)
            local vipLevelSp = CCSprite:createWithSpriteFrameName("Vip" .. playerData.vip .. ".png")
            local bottomStartPosY = (topContentBg:getContentSize().height - (playerNameLb:getContentSize().height + 5 + playerLevelLb:getContentSize().height + 3 + vipLevelSp:getContentSize().height)) / 2
            vipLevelSp:setAnchorPoint(ccp(0, 0))
            vipLevelSp:setPosition(ccp(playerIcon:getPositionX() + playerIcon:getContentSize().width * playerIcon:getScale() + 15, bottomStartPosY))
            topContentBg:addChild(vipLevelSp)
            playerLevelLb:setAnchorPoint(ccp(0, 0))
            playerLevelLb:setPosition(ccp(vipLevelSp:getPositionX() + 5, vipLevelSp:getPositionY() + vipLevelSp:getContentSize().height + 3))
            topContentBg:addChild(playerLevelLb)
            playerNameLb:setAnchorPoint(ccp(0, 0))
            playerNameLb:setPosition(ccp(playerLevelLb:getPositionX(), playerLevelLb:getPositionY() + playerLevelLb:getContentSize().height + 5))
            topContentBg:addChild(playerNameLb)
        end
    end
end

function acMemoryServerTabOne:showServerList(width, pos, callback)
    width = 450
    local serverListLayer = CCLayer:create()
    serverListLayer:setTouchEnabled(true)
    serverListLayer:setBSwallowsTouches(true)
    serverListLayer:registerScriptTouchHandler(function(...)
        if serverListLayer then
            serverListLayer:removeFromParentAndCleanup(true)
        end
        serverListLayer = nil
    end, false, -(self.layerNum - 1) * 20 - 6, true)
    self.bgLayer:addChild(serverListLayer, 1)
    
    local serverTvBgHeight = pos.y - 15
    serverTvBgHeight = G_VisibleSizeHeight - 400
    self.selectPage = 1
    local svrTb = {}
    local pageTvSize = CCSizeMake(120, serverTvBgHeight)
    local pageTvCellHeight = 55
    local pageNum = serverMgr:getPageNum()
    local hasMs = serverMgr:hasMemoryServer()
    if hasMs == true then
        pageNum = pageNum - 1 --不显示怀旧服
    end

    local pageTb = {}
    local pageTvBg = LuaCCScale9Sprite:createWithSpriteFrameName("newBlackBg.png", CCRect(4, 4, 1, 1), function()end)
    pageTvBg:setContentSize(pageTvSize)
    pageTvBg:setAnchorPoint(ccp(0, 1))
    pageTvBg:setPosition(ccp(45, pos.y - 70))
    -- pageTvBg:setOpacity(0)
    serverListLayer:addChild(pageTvBg)

    local lineSp = CCSprite:createWithSpriteFrameName("acMS_spaceLine.png")
    lineSp:setScaleY(pageTvSize.height / lineSp:getContentSize().width)
    lineSp:setAnchorPoint(ccp(0.5,1))
    lineSp:setPosition(pageTvBg:getPositionX()+pageTvSize.width,pageTvBg:getPositionY())
    serverListLayer:addChild(lineSp)
    
    local function selectPageCallback()
        for k, v in pairs(pageTb) do
            if v[1] and tolua.cast(v[1], "LuaCCScale9Sprite") and v[2] and tolua.cast(v[2], "LuaCCScale9Sprite") then
                if self.selectPage == k then
                    v[2]:setVisible(true)
                else
                    v[2]:setVisible(false)
                end
            end
        end
    end
    
    local pageTv = G_createTableView(pageTvSize, pageNum, CCSizeMake(pageTvSize.width, pageTvCellHeight), function(cell, cellSize, idx, cellNum)
        local pageBg = nil
        local function showServer(object, event, tag)
            if self.selectPage ~= tonumber(tag) then
                self.selectPage = tonumber(tag)
                if self.serverTv then
                    self.serverTv:reloadData()
                end
                selectPageCallback()
            end
        end
        local pageBg = LuaCCScale9Sprite:createWithSpriteFrameName("newBlackBg.png", CCRect(4, 4, 1, 1), showServer)
        pageBg:setContentSize(CCSizeMake(pageTvSize.width, pageTvCellHeight))
        pageBg:setPosition(pageTvSize.width / 2, pageTvCellHeight / 2)
        pageBg:setTag(idx + 1)
        pageBg:setTouchPriority(-(self.layerNum - 1) * 20 - 6)
        cell:addChild(pageBg)
        
        local downPageBg = LuaCCScale9Sprite:createWithSpriteFrameName("ltzdz_selectRange.png", CCRect(4, 4, 1, 1), function ()end)
        downPageBg:setContentSize(pageBg:getContentSize())
        downPageBg:setPosition(pageBg:getPosition())
        downPageBg:setVisible(false)
        cell:addChild(downPageBg)
        if self.selectPage == (idx + 1) then
            downPageBg:setVisible(true)
        end
        local pageStr = serverMgr:getPageStr(idx + 2)
        local serverNumLb = GetTTFLabel(pageStr, 25)
        serverNumLb:setAnchorPoint(ccp(0.5, 0.5))
        serverNumLb:setPosition(pageBg:getPosition())
        cell:addChild(serverNumLb, 3)
        pageTb[idx + 1] = {pageBg, downPageBg}
    end)
    pageTv:setAnchorPoint(ccp(0, 0))
    pageTv:setPosition(ccp(0, pageTvBg:getContentSize().height - pageTvSize.height))
    pageTv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 7)
    pageTvBg:addChild(pageTv)
    self.pageTv = pageTv
    
    local serverTvCellNum = SizeOfTable(serverList)
    local serverTvCellHeight = 65
    
    local serverTvBg = LuaCCScale9Sprite:createWithSpriteFrameName("newBlackBg.png", CCRect(4, 4, 1, 1), function()end)
    serverTvBg:setContentSize(CCSizeMake(width, serverTvBgHeight))
    serverTvBg:setAnchorPoint(ccp(0, 1))
    serverTvBg:setPosition(ccp(pageTvBg:getPositionX() + pageTvBg:getContentSize().width, pageTvBg:getPositionY()))
    serverTvBg:setTouchPriority(-(self.layerNum - 1) * 20 - 6)
    serverListLayer:addChild(serverTvBg)
    
    local serverTvSize = serverTvBg:getContentSize()
    
    self.pageRowTb = {}
    local function getServerTvCellNum()
        if self.pageRowTb[self.selectPage] == nil then
            local serverList = {}
            if hasMs == true then
                serverList = serverMgr:getServerListByPage(self.selectPage + 1)
            else
                serverList = serverMgr:getServerListByPage(self.selectPage)
            end
            self.pageRowTb[self.selectPage] = math.ceil(SizeOfTable(serverList) / 2)
        end
        return self.pageRowTb[self.selectPage]
    end
    local serverTv = G_createTableView(serverTvSize, getServerTvCellNum, CCSizeMake(serverTvSize.width, serverTvCellHeight), function(cell, cellSize, idx, cellNum)
        local serverList = {}
        if hasMs == true then
            serverList = serverMgr:getServerListByPage(self.selectPage + 1)
        else
            serverList = serverMgr:getServerListByPage(self.selectPage)
        end
        for k = 1, 2 do
            local svrIdx = idx * 2 + k
            local svrData = serverList[svrIdx]
            if svrData == nil or next(svrData) == nil then
                do break end
            end
            local serverNameLb = GetTTFLabel(svrData.name, 24, true)
            local menuItem = CCMenuItemLabel:create(serverNameLb)
            local menu = CCMenu:createWithItem(menuItem)
            menu:setPosition(ccp(0, 0))
            menu:setTouchPriority(-(self.layerNum - 1) * 20 - 6)
            cell:addChild(menu)
            menuItem:setPosition(ccp(cellSize.width / 2 + (2 ^ k - 3) * 120, cellSize.height / 2))
            menuItem:registerScriptTapHandler(function(tag, obj)
                if G_checkClickEnable() == false then
                    do return end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                if type(callback) == "function" then
                    callback(svrData)
                end
                if serverListLayer then
                    serverListLayer:removeFromParentAndCleanup(true)
                end
                serverListLayer = nil
            end)
            svrTb[svrData.name] = {serverNameLb, menuItem, self.selectPage, idx, k}
        end
        if idx + 1 < cellNum then
            local spaceLineSp = CCSprite:createWithSpriteFrameName("acMS_spaceLine.png")
            spaceLineSp:setScaleX(cellSize.width / spaceLineSp:getContentSize().width)
            spaceLineSp:setPosition(ccp(cellSize.width / 2, 0))
            cell:addChild(spaceLineSp)
        end
    end)
    serverTv:setPosition(ccp(0, 0))
    serverTv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 7)
    -- serverTv:setMaxDisToBottomOrTop(0)
    serverTvBg:addChild(serverTv)
    self.serverTv = serverTv
    
    local searchBg = LuaCCScale9Sprite:createWithSpriteFrameName("acMS_cellBg.png", CCRect(4, 4, 2, 2), function()end)
    searchBg:setContentSize(CCSizeMake(serverTvBg:getContentSize().width, serverTvCellHeight))
    searchBg:setAnchorPoint(ccp(0, 0))
    searchBg:setPosition(ccp(serverTvBg:getPosition()))
    searchBg:setOpacity(255 * 0.85)
    searchBg:setTouchPriority(-(self.layerNum - 1) * 20 - 7)
    serverListLayer:addChild(searchBg)
    
    local tempSearchCellIndex
    local editBoxLb = GetTTFLabel("", 25)
    local function gotoServerAt()
        local editLb = tolua.cast(editBoxLb, "CCLabelTTF")
        if editLb then
            local svrNameStr = editLb:getString()
            local svrNameLb, menuItem, at_page, at_cell
            local svr = svrTb[svrNameStr]
            local tvPoint = self.pageTv:getRecordPoint()
            if tvPoint.y <= 0 and self.inputServerAt then
                if self.selectPage ~= self.inputServerAt then
                    self.selectPage = self.inputServerAt
                    selectPageCallback()
                end
                tvPoint.y = pageTvSize.height - pageTvCellHeight * (pageNum - (self.inputServerAt - 1))
                if tvPoint.y > 0 then
                    tvPoint.y = 0
                end
                self.pageTv:recoverToRecordPoint(tvPoint)
            end
            if svr == nil and self.inputServerAt then
                self.serverTv:reloadData()
                svr = svrTb[svrNameStr]
            end
            if svr then
                svrNameLb, menuItem, at_page, at_cell = svr[1], svr[2], svr[3], svr[4]
                tvPoint = self.serverTv:getRecordPoint()
                if tvPoint.y <= 0 then
                    tvPoint.y = serverTvSize.height - serverTvCellHeight * (self.pageRowTb[at_page] - (at_cell - 1))
                    if tvPoint.y > 0 then
                        tvPoint.y = 0
                    end
                    self.serverTv:recoverToRecordPoint(tvPoint)
                end
                local svrNameLb = tolua.cast(svrNameLb, "CCLabelTTF")
                local menuItem = tolua.cast(menuItem, "CCMenuItemLabel")
                if svrNameLb then
                    svrNameLb:setColor(G_ColorYellowPro2)
                end
                if menuItem then
                    menuItem:runAction(CCSequence:createWithTwoActions(CCScaleTo:create(0.1, 1.35), CCScaleTo:create(0.1, 1)))
                end
            end
        end
    end
    local function onClickSearch(tag, obj)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        gotoServerAt()
    end
    local searchBtn = GetButtonItem("yh_taskGoto.png", "yh_taskGoto_down.png", "yh_taskGoto.png", onClickSearch)
    local btnMenu = CCMenu:createWithItem(searchBtn)
    btnMenu:setPosition(ccp(0, 0))
    btnMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 7)
    searchBg:addChild(btnMenu)
    searchBtn:setEnabled(false)
    searchBtn:setScale((searchBg:getContentSize().height - 10) / searchBtn:getContentSize().height)
    searchBtn:setAnchorPoint(ccp(1, 0.5))
    searchBtn:setPosition(ccp(searchBg:getContentSize().width - 5, searchBg:getContentSize().height / 2))
    local searchEditBoxSize = CCSizeMake(searchBtn:getPositionX() - searchBtn:getContentSize().width * searchBtn:getScale() - 10, searchBg:getContentSize().height)
    editBoxLb:setAnchorPoint(ccp(0, 0.5))
    editBoxLb:setPosition(ccp(10, searchBg:getContentSize().height / 2))
    local editBoxPlaceHolderLb = GetTTFLabelWrap(getlocal("acMemoryServer_serverListEditBoxTips"), 24, CCSizeMake(searchEditBoxSize.width - 10, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
    editBoxPlaceHolderLb:setColor(G_ColorGray)
    editBoxPlaceHolderLb:setAnchorPoint(ccp(0, 0.5))
    editBoxPlaceHolderLb:setPosition(ccp(10, searchBg:getContentSize().height / 2))
    searchBg:addChild(editBoxPlaceHolderLb)
    
    self.inputServerAt = nil
    local function editBoxTextEventHandle(fn, pSender, str, etype)
        local edit = tolua.cast(pSender, "CCEditBox")
        if edit then
            local isVisible = (str == nil or str == "")
            editBoxPlaceHolderLb:setVisible(isVisible)
        end
        searchBtn:setEnabled(false)
        self.inputServerAt = nil
    end
    local function inputEnd()
        local editLb = tolua.cast(editBoxLb, "CCLabelTTF")
        if editLb == nil then
            do return end
        end
        local svrExist = false --输入的服务器是否存在
        local str = editLb:getString()
        for p = 1, pageNum do
            local serverList = {}
            if hasMs == true then
                serverList = serverMgr:getServerListByPage(p + 1)
            else
                serverList = serverMgr:getServerListByPage(p)
            end
            for k, v in pairs(serverList) do
                local arr = Split(v.name, "-")
                if (arr[1] and str == arr[1]) or (arr[2] and arr[2] == str) or (str == v.name) then
                    editLb:setString(v.name)
                    svrExist = true
                    self.inputServerAt = p
                    do break end
                end
            end
            if svrExist == true then
                do break end
            end
        end
        searchBtn:setEnabled(svrExist)
        if svrExist == false then
            G_showTipsDialog(getlocal("acMemoryServer_notSearchServerTips"))
        else
            gotoServerAt()
        end
    end
    local kEditBoxInputMaxLength = 15
    customEditBox:new():init(searchBg, editBoxLb, "acMS_cellBg.png", searchEditBoxSize, -(self.layerNum - 1) * 20 - 7, kEditBoxInputMaxLength, editBoxTextEventHandle, nil, nil, nil, nil, nil, nil, inputEnd)
end

function acMemoryServerTabOne:showTaskTvCell(cell, cellSize, idx, cellNum)
    local cellTitleBg = LuaCCScale9Sprite:createWithSpriteFrameName("acMS_cellTitleBg1.png", CCRect(12, 1, 78, 30), function()end)
    cellTitleBg:setContentSize(CCSizeMake(cellSize.width - 120, cellTitleBg:getContentSize().height))
    cellTitleBg:setAnchorPoint(ccp(0, 1))
    cellTitleBg:setPosition(ccp(0, cellSize.height - 5))
    cell:addChild(cellTitleBg)
    local cellContentBg = LuaCCScale9Sprite:createWithSpriteFrameName("acMS_cellBg.png", CCRect(4, 4, 2, 2), function()end)
    cellContentBg:setContentSize(CCSizeMake(cellSize.width, cellTitleBg:getPositionY() - cellTitleBg:getContentSize().height - 10))
    cellContentBg:setAnchorPoint(ccp(0.5, 1))
    cellContentBg:setPosition(ccp(cellSize.width / 2, cellTitleBg:getPositionY() - cellTitleBg:getContentSize().height))
    cell:addChild(cellContentBg)
    
    local data = self.taskList[idx + 1]
    if data then
        local taskId = data.tsk
        local taskKey = data.key
        local completeNum = acMemoryServerVoApi:getTaskCompleteNum(taskKey, 1)
        local totalNum = SizeOfTable(data.num)
        local taskIndex = (completeNum == totalNum) and completeNum or (completeNum + 1)
        local needNum = (data.num[taskIndex] or data.num[totalNum])
        local curNum = acMemoryServerVoApi:getTaskCurNum(taskKey, true)
        local descStr = acMemoryServerVoApi:getTaskDesc(taskKey, curNum, needNum, data.quality)
        local titleLb = GetTTFLabelWrap(descStr, 16, CCSizeMake(cellTitleBg:getContentSize().width - 100, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
        titleLb:setAnchorPoint(ccp(0, 0.5))
        titleLb:setPosition(ccp(15, cellTitleBg:getContentSize().height / 2))
        cellTitleBg:addChild(titleLb)
        local taskNumLb = GetTTFLabelWrap(getlocal("acMemoryServer_taskNum", {completeNum, totalNum}), 18, CCSizeMake(180, 0), kCCTextAlignmentRight, kCCVerticalTextAlignmentCenter)
        taskNumLb:setAnchorPoint(ccp(1, 0.5))
        taskNumLb:setPosition(ccp(cellSize.width - 5, cellTitleBg:getPositionY() - cellTitleBg:getContentSize().height / 2))
        cell:addChild(taskNumLb)
        
        local spaceLineSp = CCSprite:createWithSpriteFrameName("acMS_spaceLine.png")
        spaceLineSp:setScaleY(cellContentBg:getContentSize().height / spaceLineSp:getContentSize().height)
        spaceLineSp:setPosition(ccp(cellContentBg:getContentSize().height, cellContentBg:getContentSize().height / 2))
        cellContentBg:addChild(spaceLineSp)
        local oldSoldiersLb = GetTTFLabelWrap(getlocal("acMemoryServer_oldSoldiersReward"), 16, CCSizeMake(spaceLineSp:getPositionX(), 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
        oldSoldiersLb:setAnchorPoint(ccp(0.5, 1))
        oldSoldiersLb:setPosition(ccp(spaceLineSp:getPositionX() / 2, cellContentBg:getContentSize().height - 7))
        cellContentBg:addChild(oldSoldiersLb)
        local newSoldiersLb = GetTTFLabelWrap(getlocal("acMemoryServer_newSoldiersReward"), 16, CCSizeMake(cellContentBg:getContentSize().width - spaceLineSp:getPositionX() - 20, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        newSoldiersLb:setAnchorPoint(ccp(0, 1))
        newSoldiersLb:setPosition(ccp(spaceLineSp:getPositionX() + 20, cellContentBg:getContentSize().height - 7))
        cellContentBg:addChild(newSoldiersLb)
        
        local iconSize = 60
        local oldSoldiersRewardGoldNum = (data.gb[taskIndex] or data.gb[totalNum])
        local oldSoldiersReward = FormatItem({u = {{gems = oldSoldiersRewardGoldNum}}})
        if oldSoldiersReward and oldSoldiersReward[1] then
            local v = oldSoldiersReward[1]
            local icon, scale = G_getItemIcon(v, 100, false, self.layerNum, function()
                if v.type == "at" and v.eType == "a" then --AI部队
                    local troopsVo = AITroopsVoApi:getMaxLvAITroopsVo(v.key, true)
                    AITroopsVoApi:showTroopsInfoDialog(troopsVo, true, self.layerNum + 1)
                else
                    G_showNewPropInfo(self.layerNum + 1, true, true, nil, v, nil, nil, nil, nil, true)
                end
            end)
            icon:setScale(iconSize / icon:getContentSize().height)
            scale = icon:getScale()
            icon:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
            icon:setPosition(ccp(oldSoldiersLb:getPositionX(), 10 + iconSize / 2))
            cellContentBg:addChild(icon, 1)
            local numLb = GetTTFLabel("x" .. FormatNumber(v.num), 18)
            local numBg = CCSprite:createWithSpriteFrameName("newBlackFadeBar.png")
            numBg:setAnchorPoint(ccp(0, 1))
            numBg:setRotation(180)
            numBg:setScaleX((numLb:getContentSize().width + 15) / numBg:getContentSize().width)
            numBg:setScaleY(numLb:getContentSize().height / numBg:getContentSize().height)
            numBg:setPosition(icon:getPositionX() + iconSize / 2 - 5, icon:getPositionY() - iconSize / 2 + 5)
            cellContentBg:addChild(numBg, 1)
            numLb:setAnchorPoint(ccp(1, 0))
            numLb:setPosition(numBg:getPosition())
            cellContentBg:addChild(numLb, 1)
        end
        
        local taskReward = acMemoryServerVoApi:getTaskReward(1, taskKey, taskIndex)
        if taskReward then
            local iconSpaceX = 20
            local firstIconPosX = 20 + spaceLineSp:getPositionX()
            for k, v in pairs(taskReward) do
                local icon, scale = G_getItemIcon(v, 100, false, self.layerNum, function()
                    if v.type == "at" and v.eType == "a" then --AI部队
                        local troopsVo = AITroopsVoApi:getMaxLvAITroopsVo(v.key, true)
                        AITroopsVoApi:showTroopsInfoDialog(troopsVo, true, self.layerNum + 1)
                    else
                        G_showNewPropInfo(self.layerNum + 1, true, true, nil, v, nil, nil, nil, nil, true)
                    end
                end)
                icon:setScale(iconSize / icon:getContentSize().height)
                scale = icon:getScale()
                icon:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                icon:setPosition(ccp(firstIconPosX + (k - 1) * (iconSize + iconSpaceX) + iconSize / 2, 10 + iconSize / 2))
                cellContentBg:addChild(icon, 1)
                local numLb = GetTTFLabel("x" .. FormatNumber(v.num), 18)
                local numBg = CCSprite:createWithSpriteFrameName("newBlackFadeBar.png")
                numBg:setAnchorPoint(ccp(0, 1))
                numBg:setRotation(180)
                numBg:setScaleX((numLb:getContentSize().width + 15) / numBg:getContentSize().width)
                numBg:setScaleY(numLb:getContentSize().height / numBg:getContentSize().height)
                numBg:setPosition(icon:getPositionX() + iconSize / 2 - 5, icon:getPositionY() - iconSize / 2 + 5)
                cellContentBg:addChild(numBg, 1)
                numLb:setAnchorPoint(ccp(1, 0))
                numLb:setPosition(numBg:getPosition())
                cellContentBg:addChild(numLb, 1)
            end
        end
        if completeNum == totalNum then --已完成
            local accomplishLb = GetTTFLabelWrap(getlocal("activity_hadReward"), 22, CCSizeMake(120, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
            accomplishLb:setAnchorPoint(ccp(1, 0.5))
            accomplishLb:setPosition(ccp(cellContentBg:getContentSize().width - 20, 10 + iconSize / 2))
            cellContentBg:addChild(accomplishLb)
        else
            local function onClickCellBtn(tag, obj)
                if G_checkClickEnable() == false then
                    do return end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                if curNum >= needNum then --领奖
                    acMemoryServerVoApi:requestTaskReward(function()
                        if taskReward then
                            for k, v in pairs(taskReward) do
                                G_addPlayerAward(v.type, v.key, v.id, v.num, nil, true)
                                if v.type == "h" then --添加将领魂魄
                                    if v.key and string.sub(v.key, 1, 1) == "s" then
                                        heroVoApi:addSoul(v.key, tonumber(v.num))
                                    end
                                end
                            end
                            G_showRewardTip(taskReward)
                        end
                        G_showTipsDialog(getlocal("acMemoryServer_rewardOldSoldiersTips"))
                        if self.taskTv then
                            local recordPoint = self.taskTv:getRecordPoint()
                            self.taskTv:reloadData()
                            self.taskTv:recoverToRecordPoint(recordPoint)
                        end
                    end, 1, taskId, taskIndex)
                else
                    acMemoryServerVoApi:taskJumpTo(taskKey)
                end
            end
            local cellBtnPicNormal, cellBtnPicDown = "yh_taskGoto.png", "yh_taskGoto_down.png"
            if curNum >= needNum then
                cellBtnPicNormal, cellBtnPicDown = "yh_taskReward.png", "yh_taskReward_down.png"
            end
            local cellBtn = GetButtonItem(cellBtnPicNormal, cellBtnPicDown, cellBtnPicNormal, onClickCellBtn)
            local btnMenu = CCMenu:createWithItem(cellBtn)
            btnMenu:setPosition(ccp(0, 0))
            btnMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
            cellContentBg:addChild(btnMenu)
            cellBtn:setAnchorPoint(ccp(1, 0.5))
            cellBtn:setPosition(ccp(cellContentBg:getContentSize().width - 20, 10 + iconSize / 2))
        end
    end
end

function acMemoryServerTabOne:dispose()
    self = nil
    spriteController:removePlist("public/juntuanCityBtns.plist")
    spriteController:removeTexture("public/juntuanCityBtns.png")
    spriteController:removePlist("public/youhuaUI4.plist")
    spriteController:removeTexture("public/youhuaUI4.png")
    spriteController:removePlist("public/youhuaUI3.plist")
    spriteController:removeTexture("public/youhuaUI3.png")
end
