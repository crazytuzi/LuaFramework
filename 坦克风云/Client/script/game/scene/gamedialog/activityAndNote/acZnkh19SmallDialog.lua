local acZnkh19SmallDialog = smallDialog:new()

function acZnkh19SmallDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

--ktype 数字品阶，numeralKa 兑换页面已选择的数量
function acZnkh19SmallDialog:showSelectNumeralDialog(ktype, numeralKa, confirmCallback, layerNum)
    local nc = acZnkh19SmallDialog:new()
    nc:initSelectNumeralDialog(ktype, numeralKa, confirmCallback, layerNum)
end

function acZnkh19SmallDialog:initSelectNumeralDialog(ktype, numeralKa, confirmCallback, layerNum)
    self.isUseAmi = isuseami
    self.layerNum = layerNum
    
    spriteController:addPlist("public/youhuaUI4.plist")
    spriteController:addTexture("public/youhuaUI4.png")
    
    local function close()
        spriteController:removePlist("public/youhuaUI4.plist")
        spriteController:removeTexture("public/youhuaUI4.png")
        self:close()
    end
    
    local size = CCSizeMake(550, 600)
    local dialogBg = G_getNewDialogBg(size, getlocal("znkh19_select_numeral"), 26, function () end, self.layerNum, true, close, G_ColorYellowPro2)
    self.dialogLayer = CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.bgLayer = dialogBg
    self.bgSize = size
    self.bgLayer:setContentSize(size)
    self:show()
    
    local function touchDialog()
    end
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer, 2)
    self.dialogLayer:setTouchPriority(-(layerNum - 1) * 20 - 1)
    
    local tipLb = GetTTFLabelWrap(getlocal("znkh19_selectnum_tip"), 24, CCSizeMake(size.width - 60, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    tipLb:setPosition(ccp(size.width / 2, size.height - 86 - tipLb:getContentSize().height / 2))
    self.bgLayer:addChild(tipLb)
    
    local tvWidth = size.width - 40
    local tvHeight = size.height - tipLb:getContentSize().height - 190
    
    local numerals = acZnkh19VoApi:getCanSelectNumerals(numeralKa, ktype)
    
    local count = SizeOfTable(numerals)
    if count == 0 then
        local noNumeralLb = GetTTFLabelWrap(getlocal("znkh19_no_numeral"), 22, CCSizeMake(size.width - 40, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        noNumeralLb:setPosition(ccp(size.width / 2, size.height / 2))
        noNumeralLb:setColor(G_ColorGray)
        self.bgLayer:addChild(noNumeralLb)
    end
    
    local kaHeight = 86
    local row = math.ceil(count / 4)
    local cellHeight = row * (kaHeight + 12)
    local kaWidth = kaHeight / 86 * 70
    local space = (tvWidth - 40 - kaWidth * 4) / 3
    local cellNum = (count == 0) and 0 or 1
    
    local function tvCallBack(handler, fn, idx, cel)
        if fn == "numberOfCellsInTableView" then
            return cellNum
        elseif fn == "tableCellSizeForIndex" then
            local tmpSize = CCSizeMake(tvWidth, cellHeight)
            return tmpSize
        elseif fn == "tableCellAtIndex" then
            local cell = CCTableViewCell:new()
            cell:autorelease()
            
            local selectSp = LuaCCScale9Sprite:createWithSpriteFrameName("ltzdz_selectRange.png", CCRect(4, 4, 1, 1), function ()end)
            selectSp:setContentSize(CCSizeMake(kaWidth + 2, kaHeight + 2))
            cell:addChild(selectSp, 2)
            local n = 0
            for k, v in pairs(numerals) do
                n = n + 1
                local posX = 20 + kaWidth / 2 + ((n - 1) % 4) * (kaWidth + space)
                local posY = cellHeight - (math.ceil(n / 4) - 1) * (kaHeight + 10) - kaHeight / 2 - 4
                local function selectNum()
                    self.numKey = v[1]
                    selectSp:setPosition(posX, posY + 2)
                end
                local icon = acZnkh19VoApi:getNumeralPropIcon(v[1], selectNum, {v[2], 18})
                icon:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                icon:setScale(kaHeight / icon:getContentSize().height)
                icon:setPosition(posX, posY)
                cell:addChild(icon)
                
                acZnkh19VoApi:refreshNumeralPropIcon(icon, v[2])
                
                if self.numKey == nil then
                    self.numKey = v[1]
                    selectSp:setPosition(posX, posY + 2)
                end
            end
            
            return cell
        elseif fn == "ccTouchBegan" then
            isMoved = false
            return true
        elseif fn == "ccTouchMoved" then
            isMoved = true
        elseif fn == "ccTouchEnded" then
            
        end
    end
    local hd = LuaEventHandler:createHandler(tvCallBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(tvWidth, tvHeight), nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition(ccp(20, 90))
    self.bgLayer:addChild(self.tv, 2)
    self.tv:setMaxDisToBottomOrTop(80)
    self.refreshData.tableView = self.tv
    
    local mLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine5.png", CCRect(4, 0, 2, 2), function ()end)
    mLine:setPosition(size.width / 2, 80)
    mLine:setContentSize(CCSizeMake(size.width - 40, mLine:getContentSize().height))
    self.bgLayer:addChild(mLine)
    
    --确定
    local function select()
        if confirmCallback then
            confirmCallback(self.numKey)
        end
        self:close()
    end
    local btnScale, priority = 0.6, -(self.layerNum - 1) * 20 - 4
    local sureItem = G_createBotton(self.bgLayer, ccp(size.width / 2, 40), {getlocal("dailyAnswer_tab1_btn"), 22}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", select, btnScale, priority)
    if count == 0 then
        sureItem:setEnabled(false)
    end
    local function touchLuaSpr()
        
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), touchLuaSpr)
    touchDialogBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    local rect = CCSizeMake(640, G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(250)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg, 1)
    
    self:addForbidSp(self.bgLayer, size, self.layerNum, nil, nil, true)
    
    sceneGame:addChild(self.dialogLayer, self.layerNum)
    self.dialogLayer:setPosition(ccp(0, 0))
end

--ktype 数字品阶，numeralKa 兑换页面已选择的数量
function acZnkh19SmallDialog:showGiveNumeralDialog(layerNum)
    local nc = acZnkh19SmallDialog:new()
    nc:initGiveNumeralDialog(layerNum)
end

function acZnkh19SmallDialog:initGiveNumeralDialog(layerNum)
    self.isUseAmi = isuseami
    self.layerNum = layerNum
    
    spriteController:addPlist("public/youhuaUI4.plist")
    spriteController:addTexture("public/youhuaUI4.png")
    
    local function close()
        spriteController:removePlist("public/youhuaUI4.plist")
        spriteController:removeTexture("public/youhuaUI4.png")
        self.logneedRf = nil
        self.numKey = nil
        self.multiTab = nil
        self.rcEventList = nil
        self:close()
    end
    
    local size = CCSizeMake(550, 750)
    local dialogBg = G_getNewDialogBg(size, getlocal("znkh19_select_numeral"), 26, function () end, self.layerNum, true, close, G_ColorYellowPro2)
    self.dialogLayer = CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.bgLayer = dialogBg
    self.bgSize = size
    self.bgLayer:setContentSize(size)
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer, 2)
    self.dialogLayer:setTouchPriority(-(layerNum - 1) * 20 - 1)
    self:show()
    
    self.logneedRf = true
    
    local tabTb = {
        {tabText = getlocal("alien_tech_send")},
        {tabText = getlocal("serverwar_point_record")},
    }
    
    local layerTb = {}
    local function switchTab(idx)
        local function realSwitch()
            if layerTb[idx] == nil then
                local layer
                if idx == 1 then
                    layer = self:initGiveLayer()
                else
                    layer = self:initRecordLayer()
                end
                self.bgLayer:addChild(layer)
                layerTb[idx] = layer
            end
            for k, layer in pairs(layerTb) do
                if layer and tolua.cast(layer, "CCLayer") then
                    if idx == k then
                        layer:setVisible(true)
                        layer:setPosition(0, 0)
                    else
                        layer:setVisible(false)
                        layer:setPosition(0, 93333)
                    end
                end
            end
        end
        if idx == 2 then --第二个页签需要拉取log日志
            if self.logneedRf == true then
                local function logHandler(log)
                    self.rcEventList = log or {}
                    realSwitch()
                end
                acZnkh19VoApi:getLog(3, logHandler)
            else
                realSwitch()
            end
        else
            realSwitch()
        end
    end
    
    local function tabClick(idx)
        switchTab(idx)
    end
    local multiTab = G_createMultiTabbed(tabTb, tabClick, "yh_ltzdzHelp_tab.png", "yh_ltzdzHelp_tab_down.png", nil, nil, 10)
    multiTab:setTabTouchPriority(-(self.layerNum - 1) * 20 - 4)
    multiTab:setTabPosition(40, self.bgSize.height - 120)
    multiTab:setParent(self.bgLayer, 2)
    self.multiTab = multiTab
    
    self.multiTab:tabClick(1)
    
    local function touchLuaSpr()
        
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), touchLuaSpr)
    touchDialogBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    local rect = CCSizeMake(640, G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(250)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg, 1)
    
    sceneGame:addChild(self.dialogLayer, self.layerNum)
    self.dialogLayer:setPosition(ccp(0, 0))
end

function acZnkh19SmallDialog:initGiveLayer()
    local giveLayer = CCLayer:create()
    
    local znkhVo = acZnkh19VoApi:getAcVo()
    local playerLv = znkhVo.cfg.sendGrade or 60
    local fontSize = 22
    if G_isIOS() == false then
        fontSize = 18
    end
    local tipLb, lbHeight = G_getRichTextLabel(getlocal("znkh19_sendnumeral_tip", {playerLv, getlocal("armorMatrix_color_5")}), {nil, G_ColorGreen, nil, G_ColorYellowPro2, nil}, fontSize, self.bgSize.width - 60, kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
    tipLb:setAnchorPoint(ccp(0.5, 1))
    tipLb:setPosition(self.bgSize.width / 2, self.bgSize.height - 130)
    giveLayer:addChild(tipLb, 2)
    
    local kaHeight = 75
    local kaWidth = kaHeight / 86 * 70
    local tvWidth, tvHeight = self.bgSize.width - 30, kaHeight + 20
    
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function () end)
    tvBg:setAnchorPoint(ccp(0.5, 1))
    tvBg:setContentSize(CCSizeMake(self.bgSize.width - 20, tvHeight))
    tvBg:setPosition(self.bgSize.width / 2, self.bgSize.height - lbHeight - 140)
    giveLayer:addChild(tvBg)
    
    local givePool = acZnkh19VoApi:getGiveNumeralPool()
    
    local num = SizeOfTable(givePool)
    local cellWidth = num * (kaWidth + 10)
    
    local function numeralTvEventHandler(handler, fn, idx, cel)
        if fn == "numberOfCellsInTableView" then
            return 1
        elseif fn == "tableCellSizeForIndex" then
            return CCSizeMake(cellWidth, tvHeight)
        elseif fn == "tableCellAtIndex" then
            local cell = CCTableViewCell:new()
            cell:autorelease()
            
            local selectSp = LuaCCScale9Sprite:createWithSpriteFrameName("ltzdz_selectRange.png", CCRect(4, 4, 1, 1), function ()end)
            selectSp:setContentSize(CCSizeMake(kaWidth + 4, kaHeight + 4))
            selectSp:setVisible(false)
            cell:addChild(selectSp, 2)
            
            for k, v in pairs(givePool) do
                local num = acZnkh19VoApi:getNumeralNum(v)
                
                local posX, posY = 5 + (2 * k - 1) * kaWidth / 2 + (k - 1) * 10, tvHeight / 2 - 8
                local sltPosY = posY + 3
                local function selectHandler()
                    if num == 0 then
                        G_showTipsDialog(getlocal("znkh19_numeral_nothis"))
                        do return end
                    elseif v == self.numKey then
                        do return end
                    else
                        self.numKey = v
                        selectSp:setVisible(true)
                        selectSp:setPosition(posX, sltPosY)
                        if self.friendsTv then
                            self.friendsTv:reloadData()
                        end
                    end
                end
                local icon = acZnkh19VoApi:getNumeralPropIcon(v, selectHandler, {num, 16})
                icon:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                icon:setScale(kaHeight / icon:getContentSize().height)
                icon:setPosition(posX, posY)
                cell:addChild(icon)
                
                if num == 0 then
                    local shadeBg = CCSprite:createWithSpriteFrameName("acZnkh19_zc.png")
                    shadeBg:setPosition(getCenterPoint(icon))
                    shadeBg:setOpacity(180)
                    icon:addChild(shadeBg, 3)
                else
                    acZnkh19VoApi:refreshNumeralPropIcon(icon, num)
                    if self.numKey == nil then
                        self.numKey = v
                        selectSp:setVisible(true)
                        selectSp:setPosition(posX, sltPosY)
                    elseif self.numKey == v then
                        selectSp:setVisible(true)
                        selectSp:setPosition(posX, sltPosY)
                    end
                end
            end
            
            return cell
        elseif fn == "ccTouchBegan" then
            self.isMoved = false
            return true
        elseif fn == "ccTouchMoved" then
            self.isMoved = true
        elseif fn == "ccTouchEnded" then
            
        end
    end
    
    local hd = LuaEventHandler:createHandler(numeralTvEventHandler)
    self.numeralTv = LuaCCTableView:createHorizontalWithEventHandler(hd, CCSizeMake(tvWidth, tvHeight), nil)
    self.numeralTv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.numeralTv:setPosition(5, 5)
    self.numeralTv:setMaxDisToBottomOrTop(80)
    tvBg:addChild(self.numeralTv)
    
    local titleFontSize, smallFontSize = 22, 20
    
    local friendsTvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function () end)
    friendsTvBg:setAnchorPoint(ccp(0.5, 0))
    friendsTvBg:setContentSize(CCSizeMake(self.bgSize.width - 20, tvBg:getPositionY() - tvBg:getContentSize().height - 90))
    friendsTvBg:setPosition(self.bgSize.width / 2, 20)
    giveLayer:addChild(friendsTvBg)
    
    local titleTb = {getlocal("activity_peijianhuzeng_selectFriend"), 22, G_ColorWhite}
    local titleBg, titleLb, titleHeight = G_createNewTitle(titleTb, CCSizeMake(250, 0), nil, true, "Helvetica-bold")
    titleBg:setPosition(friendsTvBg:getPositionX(), friendsTvBg:getPositionY() + friendsTvBg:getContentSize().height + 10)
    giveLayer:addChild(titleBg)
    
    --赠送次数
    local sendNum, sendMax = acZnkh19VoApi:getGiveNumInfo()
    local sendTimesLb = GetTTFLabelWrap(getlocal("activity_fyss_giveUpNum", {sendNum, sendMax}), smallFontSize, CCSizeMake(200, 0), kCCTextAlignmentRight, kCCVerticalTextAlignmentCenter)
    sendTimesLb:setAnchorPoint(ccp(1, 0.5))
    sendTimesLb:setPosition(self.bgSize.width - 20, titleBg:getPositionY() + 40)
    giveLayer:addChild(sendTimesLb)
    self.sendTimesLb = sendTimesLb
    
    --昵称
    local nameTitleLb = GetTTFLabelWrap(getlocal("exerwar_rankTab1_str2"), titleFontSize, CCSizeMake(100, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    nameTitleLb:setPosition(60, friendsTvBg:getContentSize().height - nameTitleLb:getContentSize().height / 2 - 5)
    nameTitleLb:setColor(G_ColorYellowPro2)
    friendsTvBg:addChild(nameTitleLb)
    
    --等级
    local lvTitleLb = GetTTFLabelWrap(getlocal("RankScene_level"), titleFontSize, CCSizeMake(100, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    lvTitleLb:setPosition(240, friendsTvBg:getContentSize().height - lvTitleLb:getContentSize().height / 2 - 5)
    lvTitleLb:setColor(G_ColorYellowPro2)
    friendsTvBg:addChild(lvTitleLb)
    
    --状态
    local statusTitleLb = GetTTFLabelWrap(getlocal("state"), titleFontSize, CCSizeMake(100, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    statusTitleLb:setPosition(friendsTvBg:getContentSize().width - 80, friendsTvBg:getContentSize().height - statusTitleLb:getContentSize().height / 2 - 5)
    statusTitleLb:setColor(G_ColorYellowPro2)
    friendsTvBg:addChild(statusTitleLb)
    
    --好友列表
    local friendList = friendInfoVoApi:getFriendTb()
    local friendNum = SizeOfTable(friendList)
    
    --没有任何好友
    if friendNum == 0 then
        local noFriendLb = GetTTFLabelWrap(getlocal("noMailList"), smallFontSize, CCSizeMake(self.bgSize.width - 40, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        noFriendLb:setPosition(friendsTvBg:getContentSize().width / 2, friendsTvBg:getContentSize().height / 2 - 20)
        noFriendLb:setColor(G_ColorGray)
        friendsTvBg:addChild(noFriendLb)
    end
    
    local fritvCellHeight = 60
    
    local function friendsEventHandler(handler, fn, idx, cel)
        if fn == "numberOfCellsInTableView" then
            return friendNum
        elseif fn == "tableCellSizeForIndex" then
            return CCSizeMake(tvWidth, fritvCellHeight)
        elseif fn == "tableCellAtIndex" then
            local cell = CCTableViewCell:new()
            cell:autorelease()
            
            local friendVo = friendList[idx + 1]
            if friendVo == nil then
                do return cell end
            end
            --好友昵称
            local nameLb = GetTTFLabelWrap(friendVo.nickname, smallFontSize, CCSizeMake(100, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
            nameLb:setPosition(nameTitleLb:getPositionX(), fritvCellHeight / 2)
            cell:addChild(nameLb)
            
            --好友等级
            local lvLb = GetTTFLabel(friendVo.level, smallFontSize)
            lvLb:setPosition(lvTitleLb:getPositionX(), fritvCellHeight / 2)
            cell:addChild(lvLb)
            
            local function giveHandler()
                if playerLv > playerVoApi:getPlayerLevel() then
                    G_showTipsDialog(getlocal("znkh19_give_lvlimit", {playerLv}))
                    do return end
                end
                if self.numKey == nil or self.numKey == "o0" then
                    G_showTipsDialog(getlocal("znkh19_numeral_notfull"))
                    do return end
                end
                local function giveCallback()
                    if self.numeralTv then
                        local recordPoint = self.numeralTv:getRecordPoint()
                        self.numeralTv:reloadData()
                        self.numeralTv:recoverToRecordPoint(recordPoint)
                    end
                    if self.friendsTv then
                        local recordPoint = self.friendsTv:getRecordPoint()
                        self.friendsTv:reloadData()
                        self.friendsTv:recoverToRecordPoint(recordPoint)
                    end
                    if self.sendTimesLb then
                        local sendNum, sendMax = acZnkh19VoApi:getGiveNumInfo()
                        self.sendTimesLb:setString(getlocal("activity_fyss_giveUpNum", {sendNum, sendMax}))
                    end
                end
                -- print("self.numKey=======> ",self.numKey)
                local ackey = acZnkh19VoApi:getNumeralKeyForServer(self.numKey)
                acZnkh19VoApi:numeralSend(ackey, friendVo.uid, giveCallback)
            end
            
            local recordList = acZnkh19VoApi:getGiveRecordList()
            local giveList = recordList["u"..friendVo.uid] or {} --送给玩家的数字卡片列表
            local ackey
            if self.numKey then
                ackey = acZnkh19VoApi:getNumeralKeyForServer(self.numKey)
            end
            
            local btnStr = ""
            if ackey == nil or giveList[ackey] == nil then --没有赠送过该数字
                btnStr = getlocal("alien_tech_send")
            else --已赠送
                btnStr = getlocal("alien_tech_alreadySend")
            end
            local giveBtn = G_createBotton(cell, ccp(statusTitleLb:getPositionX(), fritvCellHeight / 2), {btnStr, 22}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", giveHandler, 0.6, -(self.layerNum - 1) * 20 - 2)
            
            if ackey and giveList[ackey] then
                giveBtn:setEnabled(false)
            end
            
            return cell
        elseif fn == "ccTouchBegan" then
            self.isMoved = false
            return true
        elseif fn == "ccTouchMoved" then
            self.isMoved = true
        elseif fn == "ccTouchEnded" then
            
        end
    end
    
    local friendsTvHeight = friendsTvBg:getContentSize().height - nameTitleLb:getContentSize().height - 20
    local hd = LuaEventHandler:createHandler(friendsEventHandler)
    self.friendsTv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(tvWidth, friendsTvHeight), nil)
    self.friendsTv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.friendsTv:setPosition(ccp(5, 10))
    friendsTvBg:addChild(self.friendsTv)
    self.friendsTv:setMaxDisToBottomOrTop(80)
    
    return giveLayer
end

function acZnkh19SmallDialog:initRecordLayer()
    local recordLayer = CCLayer:create()
    
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function () end)
    tvBg:setAnchorPoint(ccp(0.5, 0))
    tvBg:setContentSize(CCSizeMake(self.bgSize.width - 20, self.bgSize.height - 140))
    tvBg:setPosition(self.bgSize.width / 2, 20)
    recordLayer:addChild(tvBg)
    
    local titleFontSize, smallFontSize = 22, 20
    
    --时间
    local timeTitleLb = GetTTFLabelWrap(getlocal("alliance_event_time"), titleFontSize, CCSizeMake(100, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    timeTitleLb:setPosition(80, tvBg:getContentSize().height - timeTitleLb:getContentSize().height / 2 - 5)
    timeTitleLb:setColor(G_ColorYellowPro2)
    tvBg:addChild(timeTitleLb)
    
    --事件
    local eventTitleLb = GetTTFLabelWrap(getlocal("alliance_event_event"), titleFontSize, CCSizeMake(100, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    eventTitleLb:setPosition(tvBg:getContentSize().width - 150, tvBg:getContentSize().height - eventTitleLb:getContentSize().height / 2 - 5)
    eventTitleLb:setColor(G_ColorYellowPro2)
    tvBg:addChild(eventTitleLb)
    
    local tvWidth, tvHeight = tvBg:getContentSize().width - 10, tvBg:getContentSize().height - eventTitleLb:getContentSize().height - 30
    
    local eventNum = SizeOfTable(self.rcEventList)
    
    --没有任何被赠送记录
    if eventNum == 0 then
        local noEventLb = GetTTFLabelWrap(getlocal("znkh19_numeral_noReceive"), smallFontSize, CCSizeMake(self.bgSize.width - 40, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        noEventLb:setPosition(tvBg:getContentSize().width / 2, tvBg:getContentSize().height / 2 - 20)
        noEventLb:setColor(G_ColorGray)
        tvBg:addChild(noEventLb)
    end
    
    local function getEvents(idx)
        if self.rcEventList[idx] == nil then
            return nil, nil
        end
        local ev = self.rcEventList[idx]
        
        local timeLb = GetTTFLabel(G_getDataTimeStr(ev[4]), smallFontSize)
        
        local numKey = acZnkh19VoApi:getNumeralKeyFromServer(ev[3])
        local pic, bgname, name, desc = acZnkh19VoApi:getNumeralPropShowInfo(numKey)
        local str = ""
        if ev[1] == "r" then --接收事件
            str = getlocal("znkh19_receive_event", {ev[2], name})
        elseif ev[1] == "s" then --赠送事件
            str = getlocal("znkh19_give_event", {ev[2], name})
        end
        local eventLb = GetTTFLabelWrap(str, smallFontSize, CCSizeMake(tvWidth - 200, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
        
        return eventLb, timeLb
    end
    local cellHeightTb = {}
    for k, v in pairs(self.rcEventList) do
        local eventLb = getEvents(k)
        if eventLb then
            eventLb = tolua.cast(eventLb, "CCLabelTTF")
            cellHeightTb[k] = eventLb:getContentSize().height + 20
        else
            cellHeightTb[k] = 0
        end
    end
    
    local function eventHandler(handler, fn, idx, cel)
        if fn == "numberOfCellsInTableView" then
            return eventNum
        elseif fn == "tableCellSizeForIndex" then
            return CCSizeMake(tvWidth, cellHeightTb[idx + 1])
        elseif fn == "tableCellAtIndex" then
            local cell = CCTableViewCell:new()
            cell:autorelease()
            
            local eventLb, timeLb = getEvents(idx + 1)
            if eventLb == nil or timeLb == nil then
                return cell
            end
            
            local ch = cellHeightTb[idx + 1]
            
            --事件
            eventLb:setColor(G_ColorGreen)
            eventLb:setAnchorPoint(ccp(0, 0.5))
            eventLb:setPosition(180, ch / 2)
            cell:addChild(eventLb)
            
            --时间
            timeLb:setPosition(timeTitleLb:getPositionX(), ch / 2)
            cell:addChild(timeLb)
            
            local mLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine5.png", CCRect(4, 0, 2, 2), function ()end)
            mLine:setPosition(tvWidth / 2, 2)
            mLine:setContentSize(CCSizeMake(tvWidth - 20, mLine:getContentSize().height))
            cell:addChild(mLine)
            
            return cell
        elseif fn == "ccTouchBegan" then
            self.isMoved = false
            return true
        elseif fn == "ccTouchMoved" then
            self.isMoved = true
        elseif fn == "ccTouchEnded" then
            
        end
    end
    
    local hd = LuaEventHandler:createHandler(eventHandler)
    self.eventTv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(tvWidth, tvHeight), nil)
    self.eventTv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.eventTv:setPosition(ccp(5, 10))
    tvBg:addChild(self.eventTv)
    self.eventTv:setMaxDisToBottomOrTop(80)
    
    return recordLayer
end

function acZnkh19SmallDialog:showRewardExchangeRecordDialog(reward, layerNum)
    local nc = acZnkh19SmallDialog:new()
    nc:initRewardExchangeRecordDialog(reward, layerNum)
end

function acZnkh19SmallDialog:initRewardExchangeRecordDialog(reward, layerNum)
    self.isUseAmi = isuseami
    self.layerNum = layerNum
    
    local function close()
        self:close()
    end
    
    local size = CCSizeMake(550, 660)
    local dialogBg = G_getNewDialogBg(size, getlocal("znkh19_exchangeMakeup"), 26, function () end, self.layerNum, true, close, G_ColorYellowPro2)
    self.dialogLayer = CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.bgLayer = dialogBg
    self.bgSize = size
    self.bgLayer:setContentSize(size)
    self:show()
    
    local function touchDialog()
    end
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer, 2)
    self.dialogLayer:setTouchPriority(-(layerNum - 1) * 20 - 1)
    
    local rposType = string.sub(reward.znkh19_rpos, 1, 1)
    
    local rwidth = 90
    local function showInfo()
        G_showNewPropInfo(self.layerNum + 1, true, true, nil, reward, true)
    end
    local rewardIconSp = G_getItemIcon(reward, 100, false, self.layerNum, showInfo)
    rewardIconSp:setScale(rwidth / rewardIconSp:getContentSize().width)
    rewardIconSp:setAnchorPoint(ccp(0, 0.5))
    rewardIconSp:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    rewardIconSp:setPosition(30, self.bgSize.height - rwidth / 2 - 86)
    self.bgLayer:addChild(rewardIconSp)
    
    --道具名称
    local nameLb = GetTTFLabelWrap(reward.name, 22, CCSizeMake(self.bgSize.width - 200, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop, "Helvetica-bold")
    nameLb:setAnchorPoint(ccp(0, 1))
    nameLb:setPosition(rewardIconSp:getPositionX() + rwidth + 10, rewardIconSp:getPositionY() + rwidth / 2)
    nameLb:setColor(G_ColorGreen)
    self.bgLayer:addChild(nameLb)
    
    --道具描述
    local tvh = rwidth - nameLb:getContentSize().height - 10
    local descTv, ch = G_LabelTableViewNew(CCSizeMake(self.bgSize.width - 180, tvh), getlocal(reward.desc), 18, kCCTextAlignmentLeft)
    descTv:setAnchorPoint(ccp(0, 0))
    descTv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    descTv:setPosition(nameLb:getPositionX(), rewardIconSp:getPositionY() - rwidth / 2 - 5)
    self.bgLayer:addChild(descTv, 2)
    if ch > tvh then
        descTv:setMaxDisToBottomOrTop(80) --文字太高需要滑动显示
    else
        descTv:setMaxDisToBottomOrTop(0) --不用滑动功能
    end
    
    local titleBg = CCSprite:createWithSpriteFrameName("HelpHeaderBg.png")
    titleBg:setPosition(self.bgSize.width / 2, rewardIconSp:getPositionY() - rwidth / 2 - titleBg:getContentSize().height / 2 - 20)
    self.bgLayer:addChild(titleBg)
    local titleLb = GetTTFLabelWrap(getlocal("znkh19_exchangeMakeup"), 22, CCSizeMake(self.bgSize.width - 100, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop, "Helvetica-bold")
    titleLb:setPosition(getCenterPoint(titleBg))
    titleBg:addChild(titleLb)
    
    local tvWidth, tvHeight = self.bgSize.width - 20, self.bgSize.height - rwidth - titleBg:getContentSize().height - 136
    local kaHeight = 70
    local kaWidth = kaHeight / 86 * 70
    local ch = kaHeight + 10
    
    local records = acZnkh19VoApi:getRewardExchangeRecords(reward)
    local rnum = SizeOfTable(records)
    local sx, lposx, kposy = 80, 80, ch / 2
    
    if rnum == 0 then
        local noMakeupLb = GetTTFLabelWrap(getlocal("znkh19_exchangeMakeup_null"), 20, CCSizeMake(tvWidth - 40, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
        noMakeupLb:setColor(G_ColorGray)
        noMakeupLb:setPosition(self.bgSize.width / 2, 20 + tvHeight / 2)
        self.bgLayer:addChild(noMakeupLb)
    end
    
    local function eventHandler(handler, fn, idx, cel)
        if fn == "numberOfCellsInTableView" then
            return rnum
        elseif fn == "tableCellSizeForIndex" then
            return CCSizeMake(tvWidth, ch)
        elseif fn == "tableCellAtIndex" then
            local cell = CCTableViewCell:new()
            cell:autorelease()
            
            local rcd = records[idx + 1][1]
            for k, v in pairs(rcd) do
                local numKey = acZnkh19VoApi:getNumeralKeyFromServer(v)
                icon = acZnkh19VoApi:getNumeralPropIcon(numKey)
                icon:setScale(kaHeight / icon:getContentSize().height)
                if rposType == "p" then --普通兑换
                    icon:setPosition(lposx + (2 * k - 1) * kaWidth / 2 + (k - 1) * sx, kposy)
                elseif rposType == "s" then
                    icon:setPosition(tvWidth / 2 + (2 ^ k - 3) * (40 + kaWidth / 2), kposy)
                end
                cell:addChild(icon)
            end
            
            local addSp = CCSprite:createWithSpriteFrameName("acZnkh19_add.png")
            if rposType == "s" then
                addSp:setPosition(tvWidth / 2, kposy + 3)
            else
                addSp:setPosition(lposx + kaWidth + sx / 2, kposy + 3)
            end
            cell:addChild(addSp)
            
            local numKey1, numKey2 = acZnkh19VoApi:getNumeralKeyFromServer(rcd[1]), acZnkh19VoApi:getNumeralKeyFromServer(rcd[2])
            local reward = acZnkh19VoApi:getExchangeReward(numKey1, numKey2)
            if rposType == "p" then
                local equalSp = CCSprite:createWithSpriteFrameName("acZnkh19_equal.png")
                equalSp:setPosition(lposx + kaWidth * 2 + 3 * sx / 2, addSp:getPositionY())
                cell:addChild(equalSp)
                
                local rewardIconSp = G_getItemIcon(reward, 100, false, self.layerNum)
                rewardIconSp:setScale(kaHeight / rewardIconSp:getContentSize().width)
                rewardIconSp:setPosition(equalSp:getPositionX() + sx / 2 + rewardIconSp:getScale() * rewardIconSp:getContentSize().width / 2, equalSp:getPositionY())
                cell:addChild(rewardIconSp)
                
                local numLb = GetTTFLabel(FormatNumber(reward.num), 18)
                numLb:setAnchorPoint(ccp(1, 0.5))
                numLb:setTag(22)
                local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), function ()end)
                numBg:setAnchorPoint(ccp(1, 0))
                numBg:setContentSize(CCSizeMake(numLb:getContentSize().width + 5, numLb:getContentSize().height - 5))
                numBg:setPosition(ccp(rewardIconSp:getContentSize().width - 2, 2))
                numBg:setOpacity(150)
                rewardIconSp:addChild(numBg, 3)
                numLb:setPosition(ccp(numBg:getContentSize().width - 2, numBg:getContentSize().height / 2))
                numBg:addChild(numLb)
                numBg:setScale(1 / rewardIconSp:getScale())
            end
            
            local mLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine5.png", CCRect(4, 0, 2, 2), function ()end)
            mLine:setPosition(tvWidth / 2, 2)
            mLine:setContentSize(CCSizeMake(tvWidth - 20, mLine:getContentSize().height))
            cell:addChild(mLine)
            
            return cell
        elseif fn == "ccTouchBegan" then
            self.isMoved = false
            return true
        elseif fn == "ccTouchMoved" then
            self.isMoved = true
        elseif fn == "ccTouchEnded" then
            
        end
    end
    
    local hd = LuaEventHandler:createHandler(eventHandler)
    self.makeupTv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(tvWidth, tvHeight), nil)
    self.makeupTv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.makeupTv:setPosition(ccp(10, 20))
    self.makeupTv:setMaxDisToBottomOrTop(80)
    self.bgLayer:addChild(self.makeupTv)
    
    local function touchLuaSpr()
        
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), touchLuaSpr)
    touchDialogBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    local rect = CCSizeMake(640, G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(250)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg, 1)
    
    self:addForbidSp(self.bgLayer, size, self.layerNum, nil, nil, true)
    
    sceneGame:addChild(self.dialogLayer, self.layerNum)
    self.dialogLayer:setPosition(ccp(0, 0))
end

function acZnkh19SmallDialog:showExchangeRecordsDialog(layerNum)
    local sd = acZnkh19SmallDialog:new()
    sd:initExchangeRecordsDialog(layerNum)
end

function acZnkh19SmallDialog:initExchangeRecordsDialog(layerNum)
    self.isUseAmi = isuseami
    self.layerNum = layerNum
    
    local function close()
        self:close()
    end
    
    local size = CCSizeMake(550, 660)
    local dialogBg = G_getNewDialogBg(size, getlocal("znkh19_exchangeMakeup"), 26, function () end, self.layerNum, true, close, G_ColorYellowPro2)
    self.dialogLayer = CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.bgLayer = dialogBg
    self.bgSize = size
    self.bgLayer:setContentSize(size)
    self:show()
    
    local function touchDialog()
    end
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer, 2)
    self.dialogLayer:setTouchPriority(-(layerNum - 1) * 20 - 1)
    
    local tipLb = GetTTFLabelWrap(getlocal("znkh19_exchangeRecord_tip"), 22, CCSizeMake(self.bgSize.width - 200, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop, "Helvetica-bold")
    tipLb:setAnchorPoint(ccp(0.5, 1))
    tipLb:setPosition(self.bgSize.width / 2, self.bgSize.height - 76)
    self.bgLayer:addChild(tipLb)
    
    local recordTipLb = GetTTFLabelWrap(getlocal("allianceWar2_limitNumLog", {10}), 20, CCSizeMake(self.bgSize.width - 40, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    recordTipLb:setColor(G_ColorRed)
    recordTipLb:setPosition(self.bgSize.width / 2, 20 + recordTipLb:getContentSize().height / 2)
    self.bgLayer:addChild(recordTipLb)
    
    local tvWidth, tvHeight = self.bgSize.width - 20, self.bgSize.height - recordTipLb:getContentSize().height - tipLb:getContentSize().height - 126
    local kaHeight = 70
    local kaWidth = kaHeight / 86 * 70
    local ch = kaHeight + 50
    
    local records = acZnkh19VoApi:getExchangeRecords()
    local rnum = SizeOfTable(records)
    local sx, lposx = 80, 80
    
    if rnum == 0 then
        local noRecordLb = GetTTFLabelWrap(getlocal("znkh19_exchangeRecord_null"), 20, CCSizeMake(self.bgSize.width - 60, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
        noRecordLb:setColor(G_ColorGray)
        noRecordLb:setPosition(self.bgSize.width / 2, 20 + tvHeight / 2)
        self.bgLayer:addChild(noRecordLb)
    end
    
    local function eventHandler(handler, fn, idx, cel)
        if fn == "numberOfCellsInTableView" then
            return rnum
        elseif fn == "tableCellSizeForIndex" then
            return CCSizeMake(tvWidth, ch)
        elseif fn == "tableCellAtIndex" then
            local cell = CCTableViewCell:new()
            cell:autorelease()
            
            local record = records[idx + 1]
            
            local exNum = record[1] --兑换数量
            local numMakeup = record[3] or {} --兑换数字组合
            local reward = FormatItem(record[2], nil, true)[1]
            local time = record[4]
            
            local cellBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png", CCRect(19, 19, 2, 2), function ()end)
            cellBg:setAnchorPoint(ccp(0, 1))
            cellBg:setContentSize(CCSizeMake(tvWidth, ch - 5))
            cellBg:setPosition(ccp(0, ch))
            cell:addChild(cellBg)
            
            --兑换时间
            local timeLb = GetTTFLabel(G_getDataTimeStr(time), 20)
            timeLb:setAnchorPoint(ccp(1, 0.5))
            timeLb:setPosition(cellBg:getContentSize().width - 10, cellBg:getContentSize().height - 35 / 2)
            cellBg:addChild(timeLb)
            local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("new_cutline.png", CCRect(27, 3, 1, 1), function ()end)
            lineSp:setContentSize(CCSizeMake(tvWidth - 20, lineSp:getContentSize().height))
            lineSp:setPosition(ccp(cellBg:getContentSize().width / 2, cellBg:getContentSize().height - 35))
            cellBg:addChild(lineSp)
            
            local kposy = (lineSp:getPositionY() - lineSp:getContentSize().height) / 2
            for k, v in pairs(numMakeup) do
                local numKey = acZnkh19VoApi:getNumeralKeyFromServer(v)
                icon = acZnkh19VoApi:getNumeralPropIcon(numKey)
                icon:setScale(kaHeight / icon:getContentSize().height)
                icon:setPosition(lposx + (2 * k - 1) * kaWidth / 2 + (k - 1) * sx, kposy)
                cellBg:addChild(icon)
            end
            
            local addSp = CCSprite:createWithSpriteFrameName("acZnkh19_add.png")
            addSp:setPosition(lposx + kaWidth + sx / 2, kposy + 3)
            cellBg:addChild(addSp)
            
            local equalSp = CCSprite:createWithSpriteFrameName("acZnkh19_equal.png")
            equalSp:setPosition(lposx + kaWidth * 2 + 3 * sx / 2, addSp:getPositionY())
            cellBg:addChild(equalSp)
            
            local rewardIconSp = G_getItemIcon(reward, 100, false, self.layerNum)
            rewardIconSp:setScale(kaHeight / rewardIconSp:getContentSize().width)
            rewardIconSp:setPosition(equalSp:getPositionX() + sx / 2 + rewardIconSp:getScale() * rewardIconSp:getContentSize().width / 2, equalSp:getPositionY())
            cellBg:addChild(rewardIconSp)
            
            local numLb = GetTTFLabel(FormatNumber(reward.num), 18)
            numLb:setAnchorPoint(ccp(1, 0.5))
            numLb:setTag(22)
            local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), function ()end)
            numBg:setAnchorPoint(ccp(1, 0))
            numBg:setContentSize(CCSizeMake(numLb:getContentSize().width + 5, numLb:getContentSize().height - 5))
            numBg:setPosition(ccp(rewardIconSp:getContentSize().width - 2, 2))
            numBg:setOpacity(150)
            rewardIconSp:addChild(numBg, 3)
            numLb:setPosition(ccp(numBg:getContentSize().width - 2, numBg:getContentSize().height / 2))
            numBg:addChild(numLb)
            numBg:setScale(1 / rewardIconSp:getScale())
            
            return cell
        elseif fn == "ccTouchBegan" then
            self.isMoved = false
            return true
        elseif fn == "ccTouchMoved" then
            self.isMoved = true
        elseif fn == "ccTouchEnded" then
            
        end
    end
    
    local hd = LuaEventHandler:createHandler(eventHandler)
    self.recordTv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(tvWidth, tvHeight), nil)
    self.recordTv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.recordTv:setPosition(ccp(10, recordTipLb:getPositionY() + recordTipLb:getContentSize().height / 2 + 10))
    self.recordTv:setMaxDisToBottomOrTop(80)
    self.bgLayer:addChild(self.recordTv)
    
    local function touchLuaSpr()
        
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), touchLuaSpr)
    touchDialogBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    local rect = CCSizeMake(640, G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(250)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg, 1)
    
    sceneGame:addChild(self.dialogLayer, self.layerNum)
    self.dialogLayer:setPosition(ccp(0, 0))
end

return acZnkh19SmallDialog
