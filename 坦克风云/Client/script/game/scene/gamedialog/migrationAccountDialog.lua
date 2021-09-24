--迁移账号列表
local migrationAccountDialog = smallDialog:new()

function migrationAccountDialog:new(codeList)
    local nc = {
        migrationList = codeList
    }
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function migrationAccountDialog:showAccountDialog(codeList, layerNum)
    local sd = migrationAccountDialog:new(codeList)
    sd:initAccountDialog(layerNum)
    return sd
end

function migrationAccountDialog:initAccountDialog(layerNum)
    self.layerNum = layerNum
    self.isUseAmi = true
    self.isTouch = false
end

function migrationAccountDialog:initAccountDialog(layerNum)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/youhuaUI6.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/youhuaUI2.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/youhuaUI5.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/youhua170523.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/creatRoleImage.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    self.layerNum = layerNum
    self.isUseAmi = true
    
    self.dialogLayer = CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.dialogLayer:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    sceneGame:addChild(self.dialogLayer, self.layerNum)
    self.dialogLayer:setPosition(ccp(0, 0))
    
    self.dialogWidth, self.dialogHeight = 550, 200
    self.accountList = {}
    local accountStr = CCUserDefault:sharedUserDefault():getStringForKey("localUidData")
    if accountStr and accountStr ~= "" then
        self.accountList = G_Json.decode(accountStr)
        for k, v in pairs(self.accountList) do
            local regdate = tonumber(v[4] or 0)
            if regdate and regdate > 0 and regdate > 1553529600 then --删除注册的新号,2019/3/26号之后的号
                table.remove(self.accountList, k)
            end
        end
    end
    self.cellHeightTb = {}
    local maxTvHeight = 500
    self.tvWidth, self.tvHeight = self.dialogWidth - 30, 0
    self.uc = SizeOfTable(self.accountList) --账号的个数
    local tvContentHeight = 0
    for k = 1, self.uc do
        tvContentHeight = tvContentHeight + self:getCellHeight(k)
    end
    if tvContentHeight > maxTvHeight then
        self.tvHeight = maxTvHeight
    else
        self.tvHeight = tvContentHeight
    end
    self.dialogHeight = self.dialogHeight + self.tvHeight + 20
    
    local function closeCallBack(...)
        self:close()
    end
    
    self.bgSize = CCSizeMake(self.dialogWidth, self.dialogHeight)
    
    local titleStr = getlocal("migrationListStr")
    local titleSize = 28
    local dialogBg
    if G_isTestServer() == true then
        dialogBg = G_getNewDialogBg(CCSizeMake(self.dialogWidth, self.dialogHeight), titleStr, titleSize, closeCallBack, self.layerNum, true)
    else
        dialogBg = G_getNewDialogBg(CCSizeMake(self.dialogWidth, self.dialogHeight), titleStr, titleSize, nil, self.layerNum, false)
    end
    self.bgLayer = dialogBg
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer, 2)
    
    local accountListBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function () end)
    accountListBg:setContentSize(CCSizeMake(self.tvWidth, self.tvHeight + 20))
    accountListBg:setAnchorPoint(ccp(0.5, 0))
    accountListBg:setPosition(self.dialogWidth / 2, self.dialogHeight - accountListBg:getContentSize().height - 80)
    self.bgLayer:addChild(accountListBg)
    
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.tvWidth, self.tvHeight), nil)
    self.tv:setPosition((self.bgSize.width - self.tvWidth) / 2, accountListBg:getPositionY() + 10)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 5)
    self.bgLayer:addChild(self.tv, 1)
    if tvContentHeight > self.tvHeight then
        self.tv:setMaxDisToBottomOrTop(100)
    else
        self.tv:setMaxDisToBottomOrTop(0)
    end
    
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function () end)
    touchDialogBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    local rect = CCSizeMake(640, G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(220)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg, 1)
    
    local btnScale, priority, btnPosY = 0.7, -(self.layerNum - 1) * 20 - 4, 60
    
    local flag, mtype = G_isForceMigration()
    if flag == true then
        if mtype == 2 then
            local updateBtnPosX = self.bgSize.width / 2
            --显示客服联系入口
            if G_isShowContactSys() == true then
                local function showContactSys()
                    G_showZhichiContactSys()
                end
                local contactItem = G_createBotton(self.bgLayer, ccp(self.bgSize.width / 2 - 100, btnPosY), {getlocal("contactCustomerPersonnel"), 22}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", showContactSys, btnScale, priority)
                updateBtnPosX = self.bgSize.width / 2 + 100
            end
            --强制更新新包
            local function forceUpdateHandler()
                G_goForceUpdateUrl()
            end
            local forceUpdateItem = G_createBotton(self.bgLayer, ccp(updateBtnPosX, btnPosY), {getlocal("forceDownloadPkg"), 22}, "creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", forceUpdateHandler, btnScale, priority)
        elseif mtype == 1 then
            local function enterGame()
                self:close()
                loginScene:showAccountSettings(1)
            end
            local enterItem = G_createBotton(self.bgLayer, ccp(self.bgSize.width / 2 - 100, btnPosY), {getlocal("platIDLoginGame"), 22}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", enterGame, btnScale, priority)
            local function registerGame()
                self:close()
                loginScene:showAccountSettings(2)
            end
            local registerItem = G_createBotton(self.bgLayer, ccp(self.bgSize.width / 2 + 100, btnPosY), {getlocal("registerGameStr"), 22}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", registerGame, btnScale, priority)
        end
    end
    --显示公告
    local function showNotice()
        self:close()
        loginScene:showMigrationNotice()
    end
    G_addMenuInfo(self.bgLayer, self.layerNum, ccp(self.bgSize.width - 60, btnPosY), nil, nil, 0.6, nil, showNotice, true)
end

function migrationAccountDialog:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return self.uc
    elseif fn == "tableCellSizeForIndex" then
        local tmpSize
        tmpSize = CCSizeMake(self.tvWidth, self:getCellHeight(idx + 1))
        return tmpSize
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        local cellWidth, cellHeight = self.tvWidth, self:getCellHeight(idx + 1)
        local leftPosX, posY = 10, cellHeight - 10
        local acountInfo = self.accountList[idx + 1]
        if acountInfo and acountInfo[1] then
            local zoneid = acountInfo[2]
            local migrationInfo = self.migrationList[tonumber(acountInfo[1])]
            if migrationInfo then
                local code, useFlag = migrationInfo[1], tonumber(migrationInfo[2])
                local contentTb = self:getAccountContent(idx + 1)
                for k, lb in pairs(contentTb) do
                    if lb and tolua.cast(lb, "CCLabelTTF") then
                        lb:setPosition(leftPosX, posY - lb:getContentSize().height / 2)
                        cell:addChild(lb)
                        if k == 3 then --迁移码
                            local flag, mtype = G_isForceMigration()
                            if mtype == 2 then
                                local btnStr = ""
                                if useFlag == 1 then
                                    btnStr = getlocal("decorateUse")
                                else
                                    btnStr = getlocal("migrationNone")
                                end
                                local migrationNoneLb = GetTTFLabelWrap(btnStr, 20, CCSizeMake(120, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
                                migrationNoneLb:setAnchorPoint(ccp(0.5, 0.5))
                                migrationNoneLb:setPosition(cellWidth - 60, posY)
                                cell:addChild(migrationNoneLb)
                            else
                                local btnStr = ""
                                if useFlag == 1 then
                                    btnStr = getlocal("decorateUse")
                                else
                                    btnStr = getlocal("activity_ryhg_acBtn2")
                                end
                                local function btnHandler()
                                    if useFlag == 0 then
                                        migrationVoApi:setMigrationCode(zoneid, code)
                                        local serverNameStr = GetServerNameByID(zoneid)
                                        loginScene:setSelectServer("cn,"..serverNameStr)
                                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("migrationCopyTip"), 28)
                                    end
                                end
                                local btnScale, priority = 0.5, -(self.layerNum - 1) * 20 - 2
                                local btnItem = G_createBotton(cell, ccp(cellWidth - 60, posY), {btnStr, 22}, "creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", btnHandler, btnScale, priority)
                                if useFlag == 1 then
                                    btnItem:setEnabled(false)
                                end
                            end
                        end
                        posY = posY - lb:getContentSize().height - 10
                    end
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

function migrationAccountDialog:getCellHeight(idx)
    if self.cellHeightTb[idx] == nil then
        local height = 20
        local contentTb = self:getAccountContent(idx)
        for k, lb in pairs(contentTb) do
            if lb and tolua.cast(lb, "CCLabelTTF") then
                height = height + lb:getContentSize().height
            end
        end
        height = height + (SizeOfTable(contentTb) - 1) * 10
        self.cellHeightTb[idx] = height
    end
    return self.cellHeightTb[idx]
end

function migrationAccountDialog:getAccountContent(idx)
    local nameFontSize, nameFontWidth, smallFontSize = 24, self.dialogWidth - 120, 20
    local contentTb = {}
    local userAccount = self.accountList[idx]
    if userAccount and SizeOfTable(userAccount) > 0 then
        local uid = tonumber(userAccount[1])
        local serverNameStr = GetServerNameByID(userAccount[2])
        local playerNameStr = userAccount[3] or ""
        local migrationInfo = self.migrationList[uid]
        if migrationInfo then
            local migrationCode = migrationInfo[1]
            local serverNameLb = GetTTFLabelWrap(getlocal("server", {serverNameStr}), nameFontSize, CCSizeMake(nameFontWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
            serverNameLb:setAnchorPoint(ccp(0, 0.5))
            local playerNameLb = GetTTFLabelWrap(getlocal("playerNameTip", {playerNameStr}), smallFontSize, CCSizeMake(nameFontWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
            playerNameLb:setAnchorPoint(ccp(0, 0.5))
            local migrationCodeLb = GetTTFLabelWrap(getlocal("migrationCode") .. ":"..migrationCode, smallFontSize, CCSizeMake(nameFontWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
            migrationCodeLb:setAnchorPoint(ccp(0, 0.5))
            contentTb = {serverNameLb, playerNameLb, migrationCodeLb}
        end
    end
    return contentTb
end

function migrationAccountDialog:dispose()
    
end

return migrationAccountDialog
