chatDialogTab2 = {}

function chatDialogTab2:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    
    self.tv = nil
    self.bgLayer = nil
    self.tableCell1 = {}
    self.layerNum = nil
    self.selectedTabIndex = 0
    self.chatDialog = nil
    self.cellBgTab = {}
    self.isFirst = true
    self.curShowIndex = 0
    return nc
end

function chatDialogTab2:init(layerNum, selectedTabIndex, chatDialog)
    self.bgLayer = CCLayer:create()
    self.layerNum = layerNum
    self.selectedTabIndex = selectedTabIndex
    self.chatDialog = chatDialog
    self:initTableView()
    
    return self.bgLayer
end

--设置对话框里的tableView
function chatDialogTab2:initTableView()
    chatVoApi:initLocalPrivateChatData()
    
    local _isChat2_0 = chatVoApi:isChat2_0()
    
    local function callBack(...)
        if _isChat2_0 == true then
            -- return self:eventHandlerNew(...)
            return self:tableViewHandler(...)
        else
            return self:eventHandler(...)
        end
    end
    local hSpace = 65
    local tvSizeH = self.bgLayer:getContentSize().height - 270 - hSpace - 10
    if _isChat2_0 == true then
        hSpace = 0
        tvSizeH = self.bgLayer:getContentSize().height - 270 - 35 - 10
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.bgLayer:getContentSize().width - 15, tvSizeH), nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition(ccp(20, 100 + hSpace))
    self.bgLayer:addChild(self.tv, 1)
    self.tv:setMaxDisToBottomOrTop(120)
end

function chatDialogTab2:createNoLabel(_str)
    self.noLabel = GetTTFLabel(_str, 24)
    self.noLabel:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2)
    self.noLabel:setColor(G_ColorGray)
    self.bgLayer:addChild(self.noLabel, 100)
end

function chatDialogTab2:initUI(_showIndex, _reciverTab)
    if type(_showIndex) == "number" then
        self.curShowIndex = _showIndex
    end
    self:clearFindEditBox()
    local titleStr
    if self.curShowIndex == 0 then
        titleStr = getlocal("chat_private_talkList")
        if self.newTalkBtn == nil then
            local function newTalkBtnHandler()
                if G_checkClickEnable() == false then
                    do return end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                
                local flag = friendMailVoApi:getFlag()
                if flag == -1 then
                    local function callbackList(fn, data)
                        local ret, sData = base:checkServerData(data)
                        if ret == true then
                            self:initUI(1)
                        end
                    end
                    socketHelper:friendsList(callbackList)
                else
                    self:initUI(1)
                end
            end
            self.newTalkBtn = GetButtonItem("newChat_msg_btn.png", "newChat_msg_btn.png", "newChat_msg_btn.png", newTalkBtnHandler, nil, getlocal("chat_private_newTalk"), 24, 101)
            self.newTalkBtn:setAnchorPoint(ccp(0.5, 0))
            local talkMenu = CCMenu:createWithItem(self.newTalkBtn)
            talkMenu:setPosition(ccp((G_VisibleSizeWidth - 70) / 2 + 70, 20))
            talkMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
            self.bgLayer:addChild(talkMenu)
        else
            self.newTalkBtn:setVisible(true)
            self.newTalkBtn:setEnabled(true)
        end
        if self.chatDialog and self.chatDialog.changeBtn then
            self.chatDialog.changeBtn:setEnabled(true)
            self.chatDialog.changeBtn:setVisible(true)
        end
        if self.backBtn then
            self.backBtn:setEnabled(false)
            self.backBtn:setVisible(false)
        end
        local _size = chatVoApi:getPrivateChatDataNum()
        if _size == 0 and self.noLabel == nil then
            self:createNoLabel(getlocal("chat_private_noTalkList"))
        end
        if self.noLabel then
            if _size == 0 then
                self.noLabel:setString(getlocal("chat_private_noTalkList"))
                self.noLabel:setVisible(true)
            else
                self.noLabel:setVisible(false)
            end
        end
    else
        if self.backBtn == nil then
            local function backBtnHandler()
                if G_checkClickEnable() == false then
                    do return end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                
                if self.chatDialog then
                    self.chatDialog:setMsgBoxVisible(false)
                    if self.curShowIndex == 2 then
                        chatVoApi:setChatUnSendMsg(2, self.chatDialog.message, self.curChatDataUid)
                    end
                end
                self:initUI(0)
            end
            self.backBtn = GetButtonItem("newChat_back_btn.png", "newChat_back_btn.png", "newChat_back_btn.png", backBtnHandler)
            self.backBtn:setAnchorPoint(ccp(0, 0))
            local backMenu = CCMenu:createWithItem(self.backBtn)
            backMenu:setPosition(10, 23)
            backMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
            self.bgLayer:addChild(backMenu)
        else
            self.backBtn:setVisible(true)
            self.backBtn:setEnabled(true)
        end
        if self.chatDialog and self.chatDialog.changeBtn then
            self.chatDialog.changeBtn:setEnabled(false)
            self.chatDialog.changeBtn:setVisible(false)
        end
        if self.newTalkBtn then
            self.newTalkBtn:setVisible(false)
            self.newTalkBtn:setEnabled(false)
        end
        if self.curShowIndex == 1 then
            titleStr = getlocal("activity_peijianhuzeng_selectFriend")
            self.friendListTb = G_getMailList()
            self:initFindEditBox()
            local _size = SizeOfTable(self.friendListTb)
            if _size == 0 and self.noLabel == nil then
                self:createNoLabel(getlocal("chat_private_noFriendList"))
            end
            if self.noLabel then
                if _size == 0 then
                    self.noLabel:setString(getlocal("chat_private_noFriendList"))
                    self.noLabel:setVisible(true)
                else
                    self.noLabel:setVisible(false)
                end
            end
        elseif self.curShowIndex == 2 then
            if _showIndex then
                if type(_reciverTab) ~= "table" then
                    print("ERROR: 参数错误！！！  eg: {uid=xxx,name=\"xxx\"}")
                    do return end
                end
                self.reciverTab = _reciverTab
            end
            titleStr = self.reciverTab.name or ""
            self.curChatDataUid = self.reciverTab.uid
            local chatData = chatVoApi:getPrivateChatDataByKey(self.curChatDataUid)
            chatVoApi:addPrivateChatData(chatData)
            if self.chatDialog then
                self.chatDialog.reciver = titleStr
                self.chatDialog.reciverUid = self.curChatDataUid
                self.chatDialog:setMsgBoxVisible(true)
            end
            -- if self.isFirst==false and chatVoApi:getPrivateChatDataNumByKey(self.curChatDataUid)==0 then
            -- self.isFirst=true
            -- end
            if self.noLabel then
                self.noLabel:setVisible(false)
            end
        end
    end
    
    if self.chatDialog and self.chatDialog.priavteTitleLb then
        self.chatDialog.priavteTitleLb:setString(titleStr)
    end
    if type(_showIndex) == "number" then
        self.tv:reloadData()
    end
    if self.curShowIndex == 2 then
        self:resetTvPos()
    end
end

function chatDialogTab2:getCurShowIndex()
    return self.curShowIndex
end

function chatDialogTab2:initFindEditBox()
    self:clearFindEditBox()
    local findTextStr
    local editBoxTipLb = GetTTFLabel(getlocal("chat_private_searchFriend"), 24)
    local function findHandler()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        
        if findTextStr == nil or findTextStr == "" then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("friend_enterNo"), 30)
            do return end
        end
        local function searchCallFunc(fn, data)
            local ret, sData = base:checkServerData(data)
            if ret == true then
                if sData and sData.data then
                    if SizeOfTable(sData.data) == 0 then
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("friend_searchNo"), 28)
                        do return end
                    else
                        self.friendListTb = {}
                        for k, v in pairs(sData.data.info) do
                            local vo = friendMailVo:new()
                            vo:initWithData(v)
                            vo.name = vo.nickname or ""
                            table.insert(self.friendListTb, vo)
                        end
                        self.findLabel:setString("")
                        findTextStr = nil
                        editBoxTipLb:setVisible(true)
                        self.tv:reloadData()
                        if SizeOfTable(self.friendListTb) > 0 and self.noLabel then
                            self.noLabel:setVisible(false)
                        end
                    end
                end
            end
        end
        socketHelper:friendsSearch(findTextStr, searchCallFunc)
    end
    self.findBtn = GetButtonItem("newChat_find_btn.png", "newChat_find_btn_down.png", "newChat_find_btn.png", findHandler, nil, nil, nil)
    self.findBtn:setAnchorPoint(ccp(1, 0))
    self.findBtnMenu = CCMenu:createWithItem(self.findBtn)
    self.findBtnMenu:setPosition(ccp(G_VisibleSizeWidth - 10, 20))
    self.findBtnMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
    self.bgLayer:addChild(self.findBtnMenu, 2)
    
    local function callBackMsgHandler(fn, eB, str, type)
        if str == nil then
            str = ""
        end
        findTextStr = str
        if str ~= "" then
            editBoxTipLb:setVisible(false)
        else
            editBoxTipLb:setVisible(true)
        end
    end
    self.findBox = LuaCCScale9Sprite:createWithSpriteFrameName("cin_mainChatBgSmall.png", CCRect(4, 25, 2, 4), function()end)
    self.findBox:setContentSize(CCSizeMake(G_VisibleSizeWidth - self.chatDialog.changeBtn:getContentSize().width - self.findBtn:getContentSize().width - 13, self.findBox:getContentSize().height))
    self.findBox:setIsSallow(false)
    self.findBox:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    self.findBox:setAnchorPoint(ccp(0, 0))
    self.findBox:setPosition(ccp(self.chatDialog.changeBtn:getPositionX() + self.chatDialog.changeBtn:getContentSize().width, 23))
    
    self.findLabel = GetTTFLabel("", 30)
    self.findLabel:setAnchorPoint(ccp(0, 0.5))
    self.findLabel:setPosition(ccp(5, self.findBox:getContentSize().height / 2))
    
    local editBox = customEditBox:new()
    local length = 12
    local inputMode = CCEditBox.kEditBoxInputModeSingleLine
    local inputFlag = CCEditBox.kEditBoxInputFlagInitialCapsSentence
    local showLength = self.findBox:getContentSize().width - 60
    self.editFindBox, editBoxText = editBox:init(self.findBox, self.findLabel, "cin_mainChatBgSmall.png", CCSizeMake(self.findBox:getContentSize().width, self.findBox:getContentSize().height), -(self.layerNum - 1) * 20 - 4, length, callBackMsgHandler, inputFlag, inputMode, true, nil, G_isIOS() and showLength or nil)
    self.bgLayer:addChild(self.findBox, 2)
    
    editBoxTipLb:setAnchorPoint(ccp(0, 0.5))
    editBoxTipLb:setPosition(10, self.findBox:getContentSize().height / 2)
    editBoxTipLb:setColor(G_ColorGray)
    self.findBox:addChild(editBoxTipLb)
end
function chatDialogTab2:setVisibleOfFindEditBox(_visible)
    if self.findBtn then
        self.findBtn:setEnabled(_visible)
        self.findBtn:setVisible(_visible)
    end
    if self.findBtnMenu then
        self.findBtnMenu:setVisible(_visible)
    end
    if self.findBox then
        self.findBox:setPositionX(_visible == true and (self.chatDialog.changeBtn:getPositionX() + self.chatDialog.changeBtn:getContentSize().width) or 99999)
        self.findBox:setVisible(_visible)
    end
    if self.editFindBox then
        self.editFindBox:setPositionX(_visible == true and tonumber(0) or 99999)
    end
end
function chatDialogTab2:clearFindEditBox()
    if self.findBtn then
        self.findBtn:removeFromParentAndCleanup(true)
        self.findBtn = nil
    end
    if self.findBtnMenu then
        self.findBtnMenu:removeFromParentAndCleanup(true)
        self.findBtnMenu = nil
    end
    if self.findBox then
        self.findBox:removeFromParentAndCleanup(true)
        self.findBox = nil
    end
    if self.findLabel then
        self.findLabel:removeFromParentAndCleanup(true)
        self.findLabel = nil
    end
    if self.editFindBox then
        self.editFindBox:removeFromParentAndCleanup(true)
        self.editFindBox = nil
    end
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function chatDialogTab2:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        local msgNum = chatVoApi:getChatNum(self.selectedTabIndex + 1)
        if msgNum <= 0 then
            do return end
        end
        return msgNum
    elseif fn == "tableCellSizeForIndex" then
        local chatVo = chatVoApi:getChatVo(idx + 1, self.selectedTabIndex + 1)
        if chatVo == nil then
            do return end
        end
        local msgData = chatVo.msgData
        local height = msgData.height
        tmpSize = CCSizeMake(600, height + 5)
        if(base.ifChatTransOpen == 1 and chatVo.params.language ~= G_getCurChoseLanguage())then
            tmpSize = CCSizeMake(600, height + 60)
        end
        return tmpSize
    elseif fn == "tableCellAtIndex" then
        local msgNum = chatVoApi:getChatNum(self.selectedTabIndex + 1)
        if msgNum <= 0 then
            do return end
        end
        local chatVo = chatVoApi:getChatVo(idx + 1, self.selectedTabIndex + 1)
        if chatVo == nil then
            do return end
        end
        local msgData = chatVo.msgData
        local type = chatVo.type
        local content = chatVo.content
        if(chatVo.showTranslate == true and chatVo.translateContent and chatVo.translateContent[G_getCurChoseLanguage()])then
            content = chatVo.translateContent[G_getCurChoseLanguage()]
        end
        --local showMsg=msgData.message
        local params = chatVo.params
        --local width=tonumber(msgData.width)
        --local height=tonumber(msgData.rows)*35
        if type == nil then
            do return end
        end
        
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        local vip = 0
        if params and params.vip then
            vip = params.vip or 0
        end
        local isGM = false
        if GM_UidCfg[chatVo.sender] and chatVo.senderName then
            isGM = true
        end
        local wSpace = 5
        local hSpace = 5
        if(base.ifChatTransOpen == 1 and chatVo.params.language ~= G_getCurChoseLanguage())then
            hSpace = 60
        end
        local width = msgData.width
        local height = msgData.height
        
        local typeStr, color, icon = chatVoApi:getTypeStr(chatVo.subType, self.selectedTabIndex, params.allianceRole, vip)
        -- local typeLabel=GetTTFLabel(typeStr,28)
        -- typeLabel:setAnchorPoint(ccp(0,1))
        -- cell:addChild(typeLabel,3)
        -- typeLabel:setColor(color)
        -- --height=height-typeLabel:getContentSize().height/2
        -- typeLabel:setPosition(ccp(wSpace,height+hSpace))
        -- typeLabel:setVisible(false)
        local typeWidth = 55
        
        --类型图标
        local spSize = 36
        local spaceX = 10
        local typeSp = CCSprite:createWithSpriteFrameName(icon)
        local typeScale = 36 / typeSp:getContentSize().width
        typeSp:setAnchorPoint(ccp(0.5, 0.5))
        typeSp:setPosition(ccp(wSpace + typeSp:getContentSize().width / 2 * typeScale + spaceX, height + hSpace - typeSp:getContentSize().height / 2 * typeScale))
        cell:addChild(typeSp, 3)
        typeSp:setScale(typeScale)
        
        local timeStr = G_chatTime(chatVo.time, true)
        timeLabel = GetTTFLabel(timeStr, 26)
        timeLabel:setAnchorPoint(ccp(1, 1))
        timeLabel:setPosition(ccp(590, height + hSpace - 3))
        cell:addChild(timeLabel, 3)
        timeLabel:setColor(color)
        
        local messageLabel
        local msgX = 0
        local msgY = -1
        
        local rect = CCRect(0, 0, 50, 50)
        local capInSet = CCRect(20, 20, 10, 10)
        local senderLabel
        if type <= 3 and chatVo.contentType ~= 3 then
            local function cellClick1(hd, fn, idx)
                if G_checkClickEnable() == false then
                    do
                        return
                    end
                end
                if self.tv:getIsScrolled() == true then
                    do return end
                end
                if (battleScene and battleScene.isBattleing == true) then
                    do return end
                end
                base:setWait()
                if self.cellBgTab and self.cellBgTab[idx] then
                    local function touchCallback()
                        if params.brType then
                            self:cellClick(idx, params.brType)
                        elseif params.serverWarTeam == 1 then
                            self:cellClick(idx, 6)
                        elseif params.isExpedition == true then
                            self:cellClick(idx, 5)
                        elseif params.isAllianceWar == true then
                            self:cellClick(idx, 3)
                        elseif params.report ~= nil or params.reportId ~= nil then
                            self:cellClick(idx, 2)
                        elseif params.ltzdz then
                            self:cellClick(idx, 19)
                        else
                            self:cellClick(idx, 1)
                        end
                        base:cancleWait()
                    end
                    local fadeIn = CCFadeIn:create(0.2)
                    --local delay=CCDelayTime:create(2)
                    local fadeOut = CCFadeOut:create(0.2)
                    local callFunc = CCCallFuncN:create(touchCallback)
                    local acArr = CCArray:create()
                    acArr:addObject(fadeIn)
                    --acArr:addObject(delay)
                    acArr:addObject(fadeOut)
                    acArr:addObject(callFunc)
                    local seq = CCSequence:create(acArr)
                    self.cellBgTab[idx]:runAction(seq)
                end
            end
            local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfItemBg.png", capInSet, cellClick1)
            backSprie:ignoreAnchorPointForPosition(false);
            backSprie:setAnchorPoint(ccp(0, 0))
            backSprie:setTag(chatVo.index)
            backSprie:setIsSallow(false)
            backSprie:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
            backSprie:setPosition(ccp(2, 0))
            cell:addChild(backSprie, 1)
            backSprie:setContentSize(CCSizeMake(596, height + hSpace))
            backSprie:setOpacity(0)
            table.insert(self.cellBgTab, chatVo.index, backSprie)
            
            local function showPlayerInfoHandler(hd, fn, idx)
                if G_checkClickEnable() == false then
                    do
                        return
                    end
                end
                if self.tv:getIsScrolled() == true then
                    do return end
                end
                if (battleScene and battleScene.isBattleing == true) then
                    do return end
                end
                base:setWait()
                if self.cellBgTab and self.cellBgTab[idx] then
                    local function touchCallback()
                        self:cellClick(idx, 1)
                        base:cancleWait()
                    end
                    local fadeIn = CCFadeIn:create(0.2)
                    --local delay=CCDelayTime:create(2)
                    local fadeOut = CCFadeOut:create(0.2)
                    local callFunc = CCCallFuncN:create(touchCallback)
                    local acArr = CCArray:create()
                    acArr:addObject(fadeIn)
                    --acArr:addObject(delay)
                    acArr:addObject(fadeOut)
                    acArr:addObject(callFunc)
                    local seq = CCSequence:create(acArr)
                    self.cellBgTab[idx]:runAction(seq)
                end
            end
            
            if chatVo.sender and chatVo.senderName then--普通聊天和战报
                --军团名称
                if G_chatAllianceName == true then
                    local allianceName = params.allianceName
                    if allianceName and allianceName ~= "" and allianceName ~= "nil" and self.selectedTabIndex ~= 2 then
                        allianceNameLabel = GetTTFLabel(allianceName, 26)
                        allianceNameLabel:setAnchorPoint(ccp(1, 1))
                        allianceNameLabel:setPosition(ccp(590 - timeLabel:getContentSize().width - 10, height + hSpace - 4))
                        cell:addChild(allianceNameLabel, 3)
                        allianceNameLabel:setColor(G_ColorGreen)
                        
                        local function touch()
                            
                        end
                        local allianceNameSp = LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfItemBg.png", capInSet, touch)
                        allianceNameSp:ignoreAnchorPointForPosition(false)
                        allianceNameSp:setAnchorPoint(ccp(1, 1))
                        --allianceNameSp:setTag(chatVo.index)
                        allianceNameSp:setIsSallow(false)
                        allianceNameSp:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                        allianceNameSp:setPosition(ccp(590 - timeLabel:getContentSize().width - 10 + 5, height + hSpace - 4 + 2))
                        cell:addChild(allianceNameSp, 2)
                        allianceNameSp:setContentSize(CCSizeMake(allianceNameLabel:getContentSize().width + 10, allianceNameLabel:getContentSize().height + 4))
                    end
                end
                
                local nameStr = chatVoApi:getNameStr(type, chatVo.subType, chatVo.senderName, chatVo.reciverName, chatVo.sender)
                senderLabel = GetTTFLabel(nameStr, 28)
                senderLabel:setAnchorPoint(ccp(0, 1))
                senderLabel:setPosition(ccp(typeWidth + wSpace, height + hSpace - 2))
                cell:addChild(senderLabel, 3)
                senderLabel:setColor(color)
                if isGM then
                    senderLabel:setColor(GM_Color)
                end
                local nameLabel = GetTTFLabel(nameStr, 28)
                local nameBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png", capInSet, showPlayerInfoHandler)
                nameBgSp:ignoreAnchorPointForPosition(false)
                nameBgSp:setAnchorPoint(ccp(0, 1))
                nameBgSp:setTag(chatVo.index)
                nameBgSp:setIsSallow(true)
                nameBgSp:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                nameBgSp:setPosition(ccp(wSpace, height + hSpace - 2))
                cell:addChild(nameBgSp, 2)
                nameBgSp:setContentSize(CCSizeMake(nameLabel:getContentSize().width + wSpace + spSize + spaceX, nameLabel:getContentSize().height))
                nameBgSp:setOpacity(0)
                
                --军衔
                local rankSp = nil
                local spScale = 0.6
                local showRank = chatVoApi:isShowRank(params.rank)
                if showRank == true then
                    local pic = playerVoApi:getRankIconName(params.rank)
                    if pic then
                        rankSp = CCSprite:createWithSpriteFrameName(pic)
                        if rankSp then
                            rankSp:setScale(spScale)
                            rankSp:setPosition(wSpace + nameLabel:getContentSize().width + spSize + spaceX + 20 + rankSp:getContentSize().width / 2 * spScale, height + hSpace - 2 - nameLabel:getContentSize().height / 2)
                            cell:addChild(rankSp, 2)
                        end
                    end
                end
                
                --vip
                local vipIcon = nil
                if G_chatVip == true then
                    if vip and vip ~= 0 then
                        if platCfg.platCfgBMImage[G_curPlatName()] ~= nil then
                            vipIcon = GetTTFLabel(getlocal("VIPStr1", {vip}), 28)
                            vipIcon:setAnchorPoint(ccp(0, 0.5))
                            vipIcon:setColor(G_ColorYellowPro)
                            vipIcon:setPosition(senderLabel:getContentSize().width + 20, senderLabel:getContentSize().height / 2 - 4)
                            if rankSp then
                                vipIcon:setPosition(senderLabel:getContentSize().width + 20 + rankSp:getContentSize().width * spScale, senderLabel:getContentSize().height / 2 - 4)
                            end
                            senderLabel:addChild(vipIcon, 2)
                        else
                            local vipPic = chatVoApi:getVipPic(params.isVipV, vip)
                            vipIcon = CCSprite:createWithSpriteFrameName(vipPic)
                            vipIcon:setAnchorPoint(ccp(0.5, 0.5))
                            local scale = 1
                            vipIcon:setScale(scale)
                            vipIcon:setPosition(wSpace + nameLabel:getContentSize().width + spSize + spaceX + 20 + 30, height + hSpace - 2 - nameLabel:getContentSize().height / 2)
                            if rankSp then
                                vipIcon:setPosition(wSpace + nameLabel:getContentSize().width + spSize + spaceX + 20 + 30 + rankSp:getContentSize().width * spScale, height + hSpace - 2 - nameLabel:getContentSize().height / 2)
                            end
                            cell:addChild(vipIcon, 2)
                        end
                    end
                end
                
                --跨服战排名前3名称号图标
                local wrIcon = nil
                local iconScale = 0.5
                local serverWarRank = params.wr or 0
                local startTime = params.st or 0
                if serverWarRank and serverWarRank > 0 and startTime and startTime > 0 and serverWarPersonalVoApi then
                    local icon, sType = serverWarPersonalVoApi:getRankIcon(serverWarRank, startTime)
                    if icon and (sType == 1 or sType == 2) then
                        if sType == 1 then
                            wrIcon = CCSprite:createWithSpriteFrameName(icon)
                        elseif sType == 2 then
                            wrIcon = GraySprite:createWithSpriteFrameName(icon)
                        end
                        if wrIcon then
                            local iconWidth = wSpace + nameLabel:getContentSize().width + spSize + spaceX + 20 + wrIcon:getContentSize().width / 2 * spScale + 10
                            if rankSp then
                                iconWidth = iconWidth + rankSp:getContentSize().width * spScale
                            end
                            if vipIcon then
                                iconWidth = iconWidth + vipIcon:getContentSize().width
                            end
                            wrIcon:setScale(iconScale)
                            wrIcon:setPosition(iconWidth, height + hSpace - 2 - nameLabel:getContentSize().height / 2)
                            cell:addChild(wrIcon, 2)
                        end
                    end
                end
            end
            if chatVo.contentType == 1 and base.ifChatTransOpen == 1 and chatVo.params.language ~= G_getCurChoseLanguage() then
                local switchLb
                if(chatVo.showTranslate == true)then
                    switchLb = GetTTFLabel("【"..getlocal("translate_origin") .. "】", 25)
                else
                    switchLb = GetTTFLabel("【"..getlocal("translate") .. "】", 25)
                end
                switchLb:setTag(823)
                switchLb:setColor(G_ColorGreen)
                local transBtn
                local function onTranslate(hd, fn, tag)
                    if(chatVo.showTranslate == true)then
                        chatVo.showTranslate = false
                    else
                        chatVo.showTranslate = true
                    end
                    if(chatVo.showTranslate == false or(chatVo.translateContent and chatVo.translateContent[G_getCurChoseLanguage()]))then
                        if(self.tv and tolua.cast(self.tv, "LuaCCTableView"))then
                            local recordPoint = self.tv:getRecordPoint()
                            self.tv:reloadData()
                            self.tv:recoverToRecordPoint(recordPoint)
                            local msgNum = chatVoApi:getChatNum(self.selectedTabIndex + 1)
                            if(idx == msgNum - 1)then
                                mainUI:setLastChat(true)
                                -- chatVoApi:setHasNewData(self.chatType)
                            end
                        end
                    else
                        local function translateCallback(result)
                            if(self.tv and tolua.cast(self.tv, "LuaCCTableView"))then
                                if(chatVo and chatVo.updateTransData)then
                                    chatVo:updateTransData(result, G_getCurChoseLanguage())
                                end
                                local recordPoint = self.tv:getRecordPoint()
                                self.tv:reloadData()
                                self.tv:recoverToRecordPoint(recordPoint)
                                local msgNum = chatVoApi:getChatNum(self.selectedTabIndex + 1)
                                if(idx == msgNum - 1)then
                                    mainUI:setLastChat(true)
                                    -- chatVoApi:setHasNewData(self.chatType)
                                end
                            end
                        end
                        switchLb:setString(getlocal("translating"))
                        chatVoApi:translate(content, translateCallback, chatVo.params.language)
                    end
                end
                transBtn = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(0, 0, 10, 10), onTranslate)
                transBtn:setTag(chatVo.index)
                transBtn:setContentSize(CCSizeMake(switchLb:getContentSize().width + 20, 60))
                transBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
                transBtn:setOpacity(0)
                transBtn:setAnchorPoint(ccp(0, 0))
                transBtn:setPosition(wSpace, 0)
                cell:addChild(transBtn)
                switchLb:setPosition(transBtn:getContentSize().width / 2, 30)
                transBtn:addChild(switchLb)
                if G_getCurChoseLanguage() ~= "cn" and G_getCurChoseLanguage() ~= "tw" and G_getCurChoseLanguage() ~= "ja" and G_getCurChoseLanguage() ~= "ko" then
                    switchLb:setAnchorPoint(ccp(0, 0.5))
                    switchLb:setPosition(0, 40)
                    
                end
                
                local fromLb = GetTTFLabel(getlocal("translate_from", {getlocal("language_name_"..chatVo.params.language)}), 25)
                fromLb:setColor(G_ColorOrange)
                fromLb:setAnchorPoint(ccp(1, 0.5))
                fromLb:setPosition(590, 30)
                cell:addChild(fromLb)
            end
        else--系统公告
            local noticeLabel = GetTTFLabel(getlocal("chat_system_notice"), 28)
            noticeLabel:setAnchorPoint(ccp(0, 1))
            noticeLabel:setPosition(ccp(typeWidth + wSpace, height + hSpace - 2))
            cell:addChild(noticeLabel, 3)
            noticeLabel:setColor(color)
        end
        local msgFont = nil
        --处理ios表情在安卓不显示问题
        if G_isIOS() == false then
            if platCfg.platCfgSameServerWithIos[G_curPlatName()] then
                local tmpTb = {}
                tmpTb["action"] = "EmojiConv"
                tmpTb["parms"] = {}
                tmpTb["parms"]["str"] = tostring(content)
                local cjson = G_Json.encode(tmpTb)
                content = G_accessCPlusFunction(cjson)
                msgFont = G_EmojiFontSrc
            end
        end
        local showMsg = string.gsub(content, "<rayimg>", "")
        messageLabel = GetTTFLabelWrap(showMsg, 26, CCSizeMake(width, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop, msgFont)
        msgX = msgX + typeWidth + wSpace
        if chatVo.contentType == 1 and base.ifChatTransOpen == 1 and chatVo.params.language ~= G_getCurChoseLanguage() then
            msgY = height + hSpace - 40
        else
            msgY = msgY + messageLabel:getContentSize().height + hSpace
        end
        
        messageLabel:setPosition(ccp(msgX, msgY))
        messageLabel:setAnchorPoint(ccp(0, 1))
        cell:addChild(messageLabel, 2)
        --local msgColor=msgData.color
        --messageLabel:setColor(msgColor)
        if chatVo.contentType and chatVo.contentType == 2 then --战报
            messageLabel:setColor(G_ColorYellow)
        else
            messageLabel:setColor(color)
        end
        if isGM then
            messageLabel:setColor(GM_Color2)
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

function chatDialogTab2:tableViewHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        local _count = 0
        if self.curShowIndex == 0 then
            _count = chatVoApi:getPrivateChatDataNum()
        elseif self.curShowIndex == 1 then
            if self.friendListTb then
                _count = SizeOfTable(self.friendListTb)
            end
        elseif self.curShowIndex == 2 then
            _count = chatVoApi:getPrivateChatDataNumByKey(self.curChatDataUid)
        end
        return _count
    elseif fn == "tableCellSizeForIndex" then
        local _cellH = 150
        if self.curShowIndex == 0 then
            _cellH = 120
        elseif self.curShowIndex == 1 then
            _cellH = 120
        elseif self.curShowIndex == 2 then
            local chatVo = chatVoApi:getChatVo(idx + 1, self.selectedTabIndex + 1)
            if chatVo == nil then
                do return CCSizeMake(0, 0) end
            end
            local msgData = chatVo.msgData
            local height = msgData.height
            if chatVo.params and chatVo.params.emojiId then --动态表情
                height = 140 + 37
            end
            height = 136 / 2 - 40 + height + 13
            if height < 146 then
                height = 156
            end
            _cellH = height + 5
            if(base.ifChatTransOpen == 1 and chatVo.params.language ~= G_getCurChoseLanguage())then
                _cellH = height + 70
            end
            if chatVo.timeVisible then
                _cellH = _cellH + 40
            end
        end
        return CCSizeMake(600, _cellH)
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        local cellWidth, cellHeight = 600, 150
        
        if self.curShowIndex == 0 then
            cellHeight = 120
            local chatData = chatVoApi:getPrivateChatData(idx + 1)
            if chatData == nil then
                do return cell end
            end
            local _cellData
            local pic, hfid, name, ts, message, rank, bnum, rpoint, vip, privatePlayerUid
            local size = SizeOfTable(chatData)
            for i = size, 1, -1 do
                if chatData[i].sender ~= playerVoApi:getUid() then
                    _cellData = chatData[i]
                    pic = _cellData.content.pic
                    hfid = _cellData.content.hfid
                    name = _cellData.content.name
                    -- ts=_cellData.content.ts
                    -- message=_cellData.content.message
                    rank = _cellData.content.rank
                    bnum = _cellData.content.bnum
                    rpoint = _cellData.content.rpoint
                    vip = _cellData.content.vip
                    privatePlayerUid = _cellData.sender
                    break
                end
            end
            if _cellData == nil then
                _cellData = chatData[size]
                name = _cellData.recivername
                -- ts=_cellData.content.ts
                -- message=_cellData.content.message
                privatePlayerUid = _cellData.reciver
            end
            ts = chatData[size].content.ts
            message = chatData[size].content.emojiId and getlocal("chatEmoji_msgReceiveTips") or chatData[size].content.message
            
            local function onClickCellBg()
                if G_checkClickEnable() == false then
                    do return end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                
                self:initUI(2, {uid = privatePlayerUid, name = name})
            end
            local cellBg = LuaCCScale9Sprite:createWithSpriteFrameName("newUnReadBg.png", CCRect(5, 23, 1, 1), onClickCellBg)
            cellBg:setContentSize(CCSizeMake(cellWidth, cellHeight - 5))
            cellBg:setPosition(cellWidth / 2, cellHeight / 2)
            cellBg:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
            cell:addChild(cellBg)
            
            local iconBg = LuaCCScale9Sprite:createWithSpriteFrameName("newChat_head_shade.png", CCRect(16, 16, 2, 2), function()end)
            iconBg:setContentSize(CCSizeMake(105, 105))
            iconBg:setAnchorPoint(ccp(0, 0.5))
            iconBg:setPosition(15, cellBg:getContentSize().height / 2)
            cellBg:addChild(iconBg)
            
            local _unReadNum = 0
            for k, v in pairs(chatData) do
                if v._isRead ~= 1 then
                    _unReadNum = _unReadNum + 1
                end
            end
            --红点
            if _unReadNum > 0 then
                local numBgW, numBgH = 36, 36
                local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png", CCRect(17, 17, 1, 1), function()end)
                local numLb = GetTTFLabel(tostring(_unReadNum), 25)
                if numLb:getContentSize().width + 10 > numBgW then
                    numBgW = numLb:getContentSize().width + 10
                end
                numBg:setContentSize(CCSizeMake(numBgW, numBgH))
                numLb:setPosition(numBg:getContentSize().width / 2, numBg:getContentSize().height / 2)
                numBg:addChild(numLb)
                numBg:setAnchorPoint(ccp(1, 1))
                numBg:setPosition(iconBg:getContentSize().width, iconBg:getContentSize().height)
                iconBg:addChild(numBg, 2)
            end
            
            local _posX = iconBg:getPositionX() + iconBg:getContentSize().width + 5
            local _posY = cellBg:getContentSize().height / 2 + 25
            
            --头像
            local icon
            if pic then
                local personPhotoName = playerVoApi:getPersonPhotoName(pic)
                icon = playerVoApi:GetPlayerBgIcon(personPhotoName, nil, nil, nil, nil, hfid, tonumber(privatePlayerUid))
                --icon = playerVoApi:getPersonPhotoSp(pic,nil,privatePlayerUid)
                icon:setScale((iconBg:getContentSize().height - 10) / icon:getContentSize().height)
            else
                icon = CCSprite:createWithSpriteFrameName("newChat_unknown_pic.png")
                icon:setScale((iconBg:getContentSize().height - 50) / icon:getContentSize().height)
            end
            icon:setPosition(iconBg:getContentSize().width / 2, iconBg:getContentSize().height / 2)
            iconBg:addChild(icon)
            
            --名称
            if name then
                local nameLb = GetTTFLabel(name, 24)
                nameLb:setAnchorPoint(ccp(0, 0.5))
                nameLb:setPosition(_posX, _posY)
                cellBg:addChild(nameLb)
                _posX = nameLb:getPositionX() + nameLb:getContentSize().width
            end
            
            --时间
            if ts then
                local timeLb = GetTTFLabel(G_chatTime(ts, true), 24)
                timeLb:setAnchorPoint(ccp(1, 0.5))
                timeLb:setPosition(cellBg:getContentSize().width - 20, cellBg:getContentSize().height / 2 + 28)
                cellBg:addChild(timeLb)
            end
            
            --军功
            if rank then
                local rankPic = playerVoApi:getRankIconName(rank)
                if rankPic then
                    local rankSp = CCSprite:createWithSpriteFrameName(rankPic)
                    if rankSp then
                        rankSp:setAnchorPoint(ccp(0, 0.5))
                        rankSp:setPosition(_posX, _posY)
                        rankSp:setScale(0.8)
                        cellBg:addChild(rankSp)
                        _posX = rankSp:getPositionX() + rankSp:getContentSize().width * rankSp:getScale()
                    end
                end
            end
            
            --领土争夺战段位
            if bnum and bnum > 0 and rpoint then
                local seg, smallLevel, totalSeg = ltzdzVoApi:getSegment(rpoint)
                if seg and smallLevel then
                    local segIcon = ltzdzVoApi:getSegIcon(seg, smallLevel, nil, 1)
                    segIcon:setAnchorPoint(ccp(0, 0.5))
                    segIcon:setPosition(_posX - 5, _posY)
                    cellBg:addChild(segIcon)
                    _posX = segIcon:getPositionX() + segIcon:getContentSize().width
                end
            end
            
            --VIP
            if vip and vip ~= 0 then
                local vipPic = chatVoApi:getVipPic(chatVoApi:isJapanV() and 1 or nil, vip)
                local vipIcon = CCSprite:createWithSpriteFrameName(vipPic)
                vipIcon:setAnchorPoint(ccp(0, 0.5))
                vipIcon:setPosition(_posX, _posY)
                cellBg:addChild(vipIcon)
                _posX = vipIcon:getPositionX() + vipIcon:getContentSize().width
            end
            
            if message then
                local _lbX = iconBg:getPositionX() + iconBg:getContentSize().width + 5
                local msgSize = CCSize(cellBg:getContentSize().width - _lbX - 80, 35)
                local showMsg = string.gsub(message, "<rayimg>", "")
                local msgLb = GetTTFLabelWrap(showMsg, 24, msgSize, kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
                msgLb:setDimensions(msgSize)
                msgLb:setAnchorPoint(ccp(0, 0.5))
                msgLb:setPosition(_lbX, cellBg:getContentSize().height / 2 - 25)
                msgLb:setColor(ccc3(174, 171, 171))
                cellBg:addChild(msgLb)
                local unSendMsg = chatVoApi:getChatUnSendMsg(2, privatePlayerUid)
                if unSendMsg ~= "" then
                    local unSendIcon = CCSprite:createWithSpriteFrameName("newChat_unSendMsgIcon.png")
                    unSendIcon:setAnchorPoint(ccp(0, 0.5))
                    unSendIcon:setPosition(_lbX, msgLb:getPositionY() - 2)
                    cellBg:addChild(unSendIcon)
                    msgLb:setPositionX(unSendIcon:getPositionX() + unSendIcon:getContentSize().width + 2)
                    msgSize.width = msgSize.width - unSendIcon:getContentSize().width
                    msgLb:setDimensions(msgSize)
                    msgLb:setString(unSendMsg)
                end
            end
            
            --删除按钮
            local function deleteBtnHandler()
                if G_checkClickEnable() == false then
                    do return end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                
                chatVoApi:deletePrivateChatData(chatData, privatePlayerUid)
                if chatVoApi:getPrivateChatDataNum() == 0 then
                    if self.noLabel == nil then
                        self:createNoLabel(getlocal("chat_private_noTalkList"))
                    else
                        self.noLabel:setString(getlocal("chat_private_noTalkList"))
                        self.noLabel:setVisible(true)
                    end
                end
                self.tv:reloadData()
            end
            local deleteBtn = GetButtonItem("newChat_deleteBtn.png", "newChat_deleteBtn.png", "newChat_deleteBtn.png", deleteBtnHandler)
            deleteBtn:setScale(0.9)
            deleteBtn:setAnchorPoint(ccp(1, 0))
            local deleteMenu = CCMenu:createWithItem(deleteBtn)
            deleteMenu:setPosition(ccp(cellBg:getContentSize().width - 25, 12))
            deleteMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
            cellBg:addChild(deleteMenu)
        elseif self.curShowIndex == 1 then
            cellHeight = 120
            local friendData = self.friendListTb[idx + 1]
            if friendData == nil then
                do return end
            end
            local function onClickCellBg()
                if G_checkClickEnable() == false then
                    do return end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                
                if friendData.uid == playerVoApi:getUid() then
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("chat_private_selfTip"), 28)
                    do return end
                end
                
                self:initUI(2, {uid = friendData.uid, name = friendData.name})
            end
            
            local cellBg = LuaCCScale9Sprite:createWithSpriteFrameName("newUnReadBg.png", CCRect(5, 23, 1, 1), onClickCellBg)
            cellBg:setContentSize(CCSizeMake(cellWidth, cellHeight - 5))
            cellBg:setPosition(cellWidth / 2, cellHeight / 2)
            cellBg:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
            cell:addChild(cellBg)
            
            local iconBg = LuaCCScale9Sprite:createWithSpriteFrameName("newChat_head_shade.png", CCRect(16, 16, 2, 2), function()end)
            iconBg:setContentSize(CCSizeMake(105, 105))
            iconBg:setAnchorPoint(ccp(0, 0.5))
            iconBg:setPosition(15, cellBg:getContentSize().height / 2)
            cellBg:addChild(iconBg)
            
            if friendData.pic then
                local personPhotoName = playerVoApi:getPersonPhotoName(friendData.pic)
                local icon = playerVoApi:GetPlayerBgIcon(personPhotoName, nil, nil, nil, nil, friendData.bpic, tonumber(friendData.uid))
                --local icon = playerVoApi:getPersonPhotoSp(friendData.pic,nil,tonumber(friendData.uid))
                icon:setPosition(iconBg:getContentSize().width / 2, iconBg:getContentSize().height / 2)
                icon:setScale((iconBg:getContentSize().height - 10) / icon:getContentSize().height)
                iconBg:addChild(icon)
            end
            
            local _posX = iconBg:getPositionX() + iconBg:getContentSize().width + 15
            local _posY = cellBg:getContentSize().height / 2 + 10
            
            if friendData.name then
                local nameLb = GetTTFLabel(friendData.name, 24)
                nameLb:setAnchorPoint(ccp(0, 0))
                nameLb:setPosition(_posX, _posY)
                cellBg:addChild(nameLb)
                _posX = nameLb:getPositionX() + nameLb:getContentSize().width
            end
            
            _posX = iconBg:getPositionX() + iconBg:getContentSize().width + 15
            _posY = cellBg:getContentSize().height / 2 - 10
            
            if friendData.level then
                local levelLb = GetTTFLabel(getlocal("fightLevel", {friendData.level}), 24)
                levelLb:setAnchorPoint(ccp(0, 1))
                levelLb:setPosition(_posX, _posY)
                levelLb:setColor(G_ColorYellowPro)
                cellBg:addChild(levelLb)
                _posX = levelLb:getPositionX() + levelLb:getContentSize().width + 25
            end
            
            if friendData.fc then
                local powerLb = GetTTFLabel(FormatNumber(tonumber(friendData.fc)), 24)
                powerLb:setAnchorPoint(ccp(0, 1))
                powerLb:setPosition(_posX, _posY)
                cellBg:addChild(powerLb)
                _posX = powerLb:getPositionX() + powerLb:getContentSize().width
            end
        elseif self.curShowIndex == 2 then
            
            local msgNum = chatVoApi:getChatNum(self.selectedTabIndex + 1)
            if msgNum <= 0 then
                do return cell end
            end
            local chatVo = chatVoApi:getChatVo(idx + 1, self.selectedTabIndex + 1)
            if chatVo == nil then
                do return cell end
            end
            
            local msgData = chatVo.msgData
            local type = chatVo.type
            local content = chatVo.content
            if(chatVo.showTranslate == true and chatVo.translateContent and chatVo.translateContent[G_getCurChoseLanguage()])then
                content = chatVo.translateContent[G_getCurChoseLanguage()]
            end
            --local showMsg=msgData.message
            local params = chatVo.params
            --local width=tonumber(msgData.width)
            --local height=tonumber(msgData.rows)*35
            if type == nil then
                do return cell end
            end
            
            local vip = 0
            if params and params.vip then
                vip = params.vip or 0
            end
            
            local isUserSelf = false -- 是否是当前玩家发送的消息
            if chatVo.sender == playerVoApi:getUid() and type <= 3 and chatVo.contentType ~= 3 then
                isUserSelf = true
            end
            
            local wSpace = 5
            local hSpace = 5
            if(base.ifChatTransOpen == 1 and chatVo.params.language ~= G_getCurChoseLanguage())then
                hSpace = 60
            end
            local width = msgData.width
            local height = msgData.height
            if params and params.emojiId then --动态表情
                height = 140 + 37
            end
            height = 136 / 2 - 40 + height + 13
            if height < 146 then
                height = 156
            end
            local jiange = 0
            local totalHeight = height + hSpace + jiange
            local timeLbH = 0
            if chatVo.timeVisible then
                timeLbH = 40
                local timeStr = G_chatTime(chatVo.time, true)
                local timeLabel = GetTTFLabel(timeStr, 26)
                timeLabel:setAnchorPoint(ccp(0.5, 0.5))
                timeLabel:setPosition(ccp(300, totalHeight + timeLbH - 30))
                cell:addChild(timeLabel, 3)
                timeLabel:setColor(G_ColorYellowPro)
            end
            
            local typeStr, color, icon = chatVoApi:getTypeStr(chatVo.subType, self.selectedTabIndex, params.allianceRole, vip)
            -- if chatVo.contentType and chatVo.contentType==2 then
            -- else
            -- color=G_ColorWhite
            -- end
            -- local typeLabel=GetTTFLabel(typeStr,28)
            -- typeLabel:setAnchorPoint(ccp(0,1))
            -- cell:addChild(typeLabel,3)
            -- typeLabel:setColor(color)
            -- --height=height-typeLabel:getContentSize().height/2
            -- typeLabel:setPosition(ccp(wSpace,height+hSpace))
            -- typeLabel:setVisible(false)
            local typeWidth = 55
            
            local bgImage
            -- if params.allianceRole and tonumber(params.allianceRole)==1 then
            -- bgImage="chat_head_fu.png"
            -- elseif params.allianceRole and tonumber(params.allianceRole)==2 then
            -- bgImage="chat_head_zheng.png"
            -- else
            -- bgImage="chat_head_common.png"
            -- end
            bgImage = "icon_bg_gray.png"
            
            if type <= 3 and chatVo.contentType ~= 3 then
            else
                bgImage = "chat_head_system.png"
                icon = "chat_system.png"
            end
            
            -- 新版显示头像所以不在需要icon
            local pic = 1
            if params and params.pic then
                pic = params.pic
            end
            
            --类型图标
            local spSize = 98
            local spaceX = 10
            local typeSp
            -- if type<=3 and chatVo.contentType~=3 then
            -- typeSp = playerVoApi:getPersonPhotoSp(pic)
            -- else
            typeSp = CCSprite:createWithSpriteFrameName(bgImage)
            -- end
            local typeScale = spSize / typeSp:getContentSize().width
            typeSp:setAnchorPoint(ccp(0.5, 0.5))
            cell:addChild(typeSp, 3)
            typeSp:setScale(typeScale)
            
            if isUserSelf then
                typeSp:setPosition(ccp(600 - wSpace - spSize / 2, totalHeight - spSize / 2 - 27))
            else
                typeSp:setPosition(ccp(wSpace + spSize / 2, totalHeight - spSize / 2 - 27))
            end
            
            -- 头像
            local headSp
            if type <= 3 and chatVo.contentType ~= 3 then
                headSp = playerVoApi:getPersonPhotoSp(pic, nil, chatVo.sender)
            else
                headSp = CCSprite:createWithSpriteFrameName(icon)
            end
            headSp:setScale((typeSp:getContentSize().height - 5) / headSp:getContentSize().height)
            -- headSp:setScale(78/70*headSp:getScale())
            
            typeSp:addChild(headSp)
            
            headSp:setPosition(typeSp:getContentSize().width / 2, typeSp:getContentSize().height / 2)
            -- headSp:setPosition(typeSp:getContentSize().width/2,80)
            
            -- if isGM then
            -- headSp:setPosition(typeSp:getContentSize().width/2,typeSp:getContentSize().height/2)
            -- end
            
            --头像框
            if params and params.hfid then
                local frameSp = playerVoApi:getPlayerHeadFrameSp(params.hfid)
                if frameSp then
                    frameSp:setPosition(headSp:getContentSize().width / 2, headSp:getContentSize().height / 2)
                    frameSp:setScale((headSp:getContentSize().width + 7) / frameSp:getContentSize().width)
                    headSp:addChild(frameSp)
                end
            end
            
            local timeStr = G_chatTime(chatVo.time, true)
            timeLabel = GetTTFLabel(timeStr, 26)
            timeLabel:setAnchorPoint(ccp(1, 1))
            timeLabel:setPosition(ccp(590, height + hSpace - 3))
            cell:addChild(timeLabel, 3)
            timeLabel:setColor(color)
            timeLabel:setVisible(false)
            
            -- 聊天信息背景
            local bgImage, robeImage--robeImage 装饰图
            if isUserSelf then
                bgImage = "chat_bg_right.png"
                --       elseif chatVo.subType==2 then
                --       bgImage = "chat_bg_purple.png"
                --   elseif chatVo.subType==3 then
                --   bgImage = "chat_bg_blue.png"
                -- elseif chatVo.contentType and chatVo.contentType==3 then
                -- bgImage = "chat_bg_yellow.png"
            else
                bgImage = "chat_bg_left.png"
            end
            local cdis = 0
            local rect = CCRect(30, 25, 1, 1)
            if params and params.cfid then
                local cfCfg = chatFrameCfg.list[tostring(params.cfid)]
                if isUserSelf then
                    bgImage = cfCfg.pic[2]
                    if bgImage ~= "chat_bg_right.png" then
                        rect = CCRect(37, 25, 1, 1)
                    end
                    robeImage = cfCfg.pic2 and cfCfg.pic2[2] or nil
                else
                    bgImage = cfCfg.pic[1]
                    if bgImage ~= "chat_bg_left.png" then
                        rect = CCRect(48, 25, 1, 1)
                    end
                    robeImage = cfCfg.pic2 and cfCfg.pic2[1] or nil
                end
            elseif params and params.xlpd_invite then
                bgImage, rect, cdis = "xlpd_invitebg.png", CCRect(45, 42, 2, 2), 17
            end
            
            local function msgBgClick(...)
                
            end
            msgBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgImage, rect, msgBgClick)
            msgBg:setContentSize(CCSizeMake(100, 50))
            if isUserSelf then
                msgBg:setAnchorPoint(ccp(1, 1))
                msgBg:setPosition(ccp(600 - wSpace - spSize - cdis, totalHeight - spSize / 2 - 15))
            else
                msgBg:setAnchorPoint(ccp(0, 1))
                msgBg:setPosition(ccp(wSpace + spSize + cdis, totalHeight - spSize / 2 - 15))
            end
            if params and params.emojiId then --动态表情
                msgBg:setVisible(false)
            else
                cell:addChild(msgBg)
            end
            
            local messageLabel
            local msgX = 0
            local msgY = -1
            
            local rect = CCRect(0, 0, 50, 50)
            local capInSet = CCRect(20, 20, 10, 10)
            local senderLabel
            if type <= 3 and chatVo.contentType ~= 3 then
                local function cellClick1(hd, fn, idx)
                    if G_checkClickEnable() == false then
                        do
                            return
                        end
                    end
                    if self.tv:getIsScrolled() == true then
                        do return end
                    end
                    if (battleScene and battleScene.isBattleing == true) then
                        do return end
                    end
                    base:setWait()
                    if self.cellBgTab and self.cellBgTab[idx] then
                        local function touchCallback()
                            if params.brType then
                                self:cellClick(idx, params.brType)
                            elseif params.serverWarTeam == 1 then
                                self:cellClick(idx, 6)
                            elseif params.isExpedition == true then
                                self:cellClick(idx, 5)
                            elseif params.isAllianceWar == true then
                                self:cellClick(idx, 3)
                            elseif params.report ~= nil or params.reportId ~= nil then
                                self:cellClick(idx, 2)
                            elseif params.ltzdz then
                                self:cellClick(idx, 19)
                            else
                                self:cellClick(idx, 1)
                            end
                            base:cancleWait()
                        end
                        local fadeIn = CCFadeIn:create(0.2)
                        --local delay=CCDelayTime:create(2)
                        local fadeOut = CCFadeOut:create(0.2)
                        local callFunc = CCCallFuncN:create(touchCallback)
                        local acArr = CCArray:create()
                        acArr:addObject(fadeIn)
                        --acArr:addObject(delay)
                        acArr:addObject(fadeOut)
                        acArr:addObject(callFunc)
                        local seq = CCSequence:create(acArr)
                        self.cellBgTab[idx]:runAction(seq)
                    end
                end
                local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfItemBg.png", capInSet, cellClick1)
                backSprie:ignoreAnchorPointForPosition(false);
                backSprie:setAnchorPoint(ccp(0, 0))
                backSprie:setTag(chatVo.index)
                backSprie:setIsSallow(false)
                backSprie:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                backSprie:setPosition(ccp(2, 0))
                cell:addChild(backSprie, 1)
                backSprie:setContentSize(CCSizeMake(596, totalHeight - 5))
                backSprie:setOpacity(0)
                if robeImage then
                    backSprie:setContentSize(CCSizeMake(596, totalHeight + 5))
                    backSprie:setPositionY(backSprie:getPositionY() - 5)
                end
                table.insert(self.cellBgTab, chatVo.index, backSprie)
                
                local function showPlayerInfoHandler(hd, fn, idx)
                    if G_checkClickEnable() == false then
                        do
                            return
                        end
                    end
                    if self.tv:getIsScrolled() == true then
                        do return end
                    end
                    if (battleScene and battleScene.isBattleing == true) then
                        do return end
                    end
                    base:setWait()
                    if self.cellBgTab and self.cellBgTab[idx] then
                        local function touchCallback()
                            self:cellClick(idx, 1)
                            base:cancleWait()
                        end
                        local fadeIn = CCFadeIn:create(0.2)
                        --local delay=CCDelayTime:create(2)
                        local fadeOut = CCFadeOut:create(0.2)
                        local callFunc = CCCallFuncN:create(touchCallback)
                        local acArr = CCArray:create()
                        acArr:addObject(fadeIn)
                        --acArr:addObject(delay)
                        acArr:addObject(fadeOut)
                        acArr:addObject(callFunc)
                        local seq = CCSequence:create(acArr)
                        self.cellBgTab[idx]:runAction(seq)
                    end
                end
                
                if chatVo.sender and chatVo.senderName then--普通聊天和战报
                    --军团名称
                    if G_chatAllianceName == true then
                        local allianceName = params.allianceName
                        if allianceName and allianceName ~= "" and allianceName ~= "nil" and self.selectedTabIndex ~= 2 then
                            allianceNameLabel = GetTTFLabel(allianceName, 26)
                            allianceNameLabel:setAnchorPoint(ccp(1, 1))
                            allianceNameLabel:setPosition(ccp(590 - timeLabel:getContentSize().width - 10, height + hSpace - 4))
                            cell:addChild(allianceNameLabel, 3)
                            allianceNameLabel:setColor(G_ColorGreen)
                            
                            local function touch()
                                
                            end
                            local allianceNameSp = LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfItemBg.png", capInSet, touch)
                            allianceNameSp:ignoreAnchorPointForPosition(false)
                            allianceNameSp:setAnchorPoint(ccp(1, 1))
                            --allianceNameSp:setTag(chatVo.index)
                            allianceNameSp:setIsSallow(false)
                            allianceNameSp:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                            allianceNameSp:setPosition(ccp(590 - timeLabel:getContentSize().width - 10 + 5, height + hSpace - 4 + 2))
                            cell:addChild(allianceNameSp, 2)
                            allianceNameSp:setContentSize(CCSizeMake(allianceNameLabel:getContentSize().width + 10, allianceNameLabel:getContentSize().height + 4))
                        end
                    end
                    local lbSize = 24
                    local lbSpace = 0
                    if platCfg.platCfgBMImage[G_curPlatName()] ~= nil then
                        lbSpace = 8
                        lbSize = 22
                    end
                    
                    --玩家名称和称号
                    -- local nameStr= chatVoApi:getNameStr(type,chatVo.subType,chatVo.senderName,chatVo.reciverName,chatVo.sender)
                    local nameStr = chatVo.senderName
                    local titleStr = params.title or ""
                    if params.title and params.title ~= "" and tonumber(params.title) ~= 0 then
                        titleStr = getlocal("player_title_name_" .. params.title)
                        titleStr = "【" .. titleStr .. "】"
                    else
                        titleStr = ""
                    end
                    
                    local _posX, _posY = 0, 0
                    local titleLb = GetTTFLabel(titleStr, lbSize)
                    senderLabel = GetTTFLabel(nameStr, lbSize)
                    -- if isUserSelf then
                    -- senderLabel:setAnchorPoint(ccp(1,0))
                    -- senderLabel:setPosition(ccp(600-wSpace-spSize-5,totalHeight-spSize/2-15+20+lbSpace))
                    -- titleLb:setAnchorPoint(ccp(1,0))
                    -- titleLb:setPosition(ccp(600-wSpace-spSize-senderLabel:getContentSize().width,totalHeight-spSize/2-15+20+lbSpace))
                    -- _posX=titleLb:getPositionX()-titleLb:getContentSize().width
                    -- else
                    senderLabel:setAnchorPoint(ccp(0, 0))
                    senderLabel:setPosition(ccp(wSpace + spSize + 5, totalHeight - spSize / 2 + lbSpace))
                    titleLb:setAnchorPoint(ccp(0, 0))
                    local titleLbSpace = 0
                    if titleLb:getContentSize().width > 0 then
                        titleLbSpace = 10
                    end
                    titleLb:setPosition(ccp(senderLabel:getPositionX() + senderLabel:getContentSize().width - titleLbSpace, totalHeight - spSize / 2 + lbSpace))
                    _posX = titleLb:getPositionX() + titleLb:getContentSize().width - titleLbSpace
                    -- end
                    _posY = senderLabel:getPositionY() + senderLabel:getContentSize().height / 2
                    titleLb:setColor(G_ColorGreen)
                    cell:addChild(titleLb, 3)
                    cell:addChild(senderLabel, 3)
                    senderLabel:setColor(color)
                    
                    -- if isGM then
                    -- senderLabel:setColor(GM_Color)
                    -- end
                    
                    local nameLabel = GetTTFLabel(nameStr, lbSize)
                    local nameBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png", capInSet, showPlayerInfoHandler)
                    nameBgSp:ignoreAnchorPointForPosition(false)
                    nameBgSp:setAnchorPoint(ccp(0, 1))
                    nameBgSp:setTag(chatVo.index)
                    nameBgSp:setIsSallow(true)
                    nameBgSp:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                    nameBgSp:setPosition(ccp(wSpace, height + hSpace - 2))
                    cell:addChild(nameBgSp, 2)
                    nameBgSp:setContentSize(CCSizeMake(nameLabel:getContentSize().width + wSpace + spSize + spaceX, nameLabel:getContentSize().height))
                    nameBgSp:setOpacity(0)
                    
                    --军衔
                    local rankSp = nil
                    local spScale = 0.8
                    -- local showRank=chatVoApi:isShowRank(params.rank)
                    
                    -- if showRank==true then
                    local pic = playerVoApi:getRankIconName(params.rank)
                    if pic then
                        rankSp = CCSprite:createWithSpriteFrameName(pic)
                        if rankSp then
                            -- typeSp:addChild(rankSp)
                            -- rankSp:setScale(1/typeScale*spScale)
                            -- rankSp:setAnchorPoint(ccp(0.5,0.5))
                            -- rankSp:setPosition(typeSp:getContentSize().width/2,28)
                            rankSp:setScale(spScale)
                            cell:addChild(rankSp, 3)
                            -- rankSp:setScale(senderLabel:getContentSize().height/rankSp:getContentSize().height)
                            rankSp:setPosition(_posX, _posY)
                            -- if isUserSelf then
                            -- rankSp:setAnchorPoint(ccp(1,0.5))
                            -- _posX=rankSp:getPositionX()-rankSp:getContentSize().width
                            -- else
                            rankSp:setAnchorPoint(ccp(0, 0.5))
                            _posX = rankSp:getPositionX() + rankSp:getContentSize().width * spScale
                            -- end
                        end
                    end
                    -- end
                    
                    --领土争夺战段位图标
                    local segIcon = nil
                    if params.bnum and params.bnum > 0 and params.rpoint then
                        local seg, smallLevel, totalSeg = ltzdzVoApi:getSegment(params.rpoint)
                        if seg and smallLevel then
                            segIcon = ltzdzVoApi:getSegIcon(seg, smallLevel, nil, 1)
                            segIcon:setPosition(_posX - 5, _posY)
                            -- if isUserSelf then
                            -- segIcon:setAnchorPoint(ccp(1,0.5))
                            -- _posX=segIcon:getPositionX()-segIcon:getContentSize().width
                            -- else
                            segIcon:setAnchorPoint(ccp(0, 0.5))
                            _posX = segIcon:getPositionX() + segIcon:getContentSize().width
                            -- end
                            cell:addChild(segIcon, 3)
                        end
                    end
                    
                    --跨服战排名前3名称号图标
                    local wrIcon = nil
                    local iconScale = 0.5
                    local serverWarRank = params.wr or 0
                    local startTime = params.st or 0
                    if serverWarRank and serverWarRank > 0 and startTime and startTime > 0 and serverWarPersonalVoApi then
                        local icon, sType = serverWarPersonalVoApi:getRankIcon(serverWarRank, startTime)
                        -- icon="serverWarTopMedal1.png"
                        -- sType=1
                        if icon and (sType == 1 or sType == 2) then
                            if sType == 1 then
                                wrIcon = CCSprite:createWithSpriteFrameName(icon)
                            elseif sType == 2 then
                                wrIcon = GraySprite:createWithSpriteFrameName(icon)
                            end
                            if wrIcon then
                                -- local senderW=senderLabel:getContentSize().width+wrIcon:getContentSize().width/2-10
                                -- local titleW=titleLb:getContentSize().width
                                -- if chatVo.subType and (chatVo.subType==1 or chatVo.subType==3) and  params.title and params.title~="" and tonumber(params.title)~=0 then
                                -- titleW=titleW-17
                                -- end
                                
                                -- local senderH=senderLabel:getContentSize().height
                                -- if isUserSelf then
                                -- wrIcon:setPosition(ccp(600-wSpace-spSize-senderW-titleW,totalHeight-spSize/2-15+20+senderH*iconScale))
                                -- else
                                -- wrIcon:setPosition(ccp(wSpace+spSize+senderW+titleW,totalHeight-spSize/2-15+20+senderH*iconScale))
                                -- end
                                wrIcon:setScale(iconScale)
                                wrIcon:setPosition(_posX, _posY)
                                -- if isUserSelf then
                                -- wrIcon:setAnchorPoint(ccp(1,0.5))
                                -- _posX=wrIcon:getPositionX()-wrIcon:getContentSize().width*wrIcon:getScale()
                                -- else
                                wrIcon:setAnchorPoint(ccp(0, 0.5))
                                _posX = wrIcon:getPositionX() + wrIcon:getContentSize().width * wrIcon:getScale()
                                -- end
                                cell:addChild(wrIcon, 3)
                            end
                        end
                    end
                    
                    --vip图标
                    local vipIcon = nil
                    if G_chatVip == true then
                        if vip and vip ~= 0 then
                            if platCfg.platCfgBMImage[G_curPlatName()] ~= nil then
                                vipIcon = GetTTFLabel(getlocal("VIPStr1", {vip}), 22)
                                vipIcon:setColor(G_ColorYellowPro)
                                -- if isUserSelf then
                                -- vipIcon:setAnchorPoint(ccp(1,0.5))
                                -- vipIcon:setPosition(ccp(600-wSpace-spSize-5,totalHeight-spSize/2))
                                -- else
                                vipIcon:setAnchorPoint(ccp(0, 0.5))
                                vipIcon:setPosition(_posX, _posY)
                                _posX = vipIcon:getPositionX() + vipIcon:getContentSize().width
                                -- end
                                cell:addChild(vipIcon)
                            else
                                local vipPic = chatVoApi:getVipPic(params.isVipV, vip)
                                vipIcon = CCSprite:createWithSpriteFrameName(vipPic)
                                -- vipIcon:setScale(1/typeScale)
                                -- vipIcon:setPosition(typeSp:getContentSize().width/2,130)
                                -- vipIcon:setAnchorPoint(ccp(0.5,0.5))
                                -- typeSp:addChild(vipIcon)
                                -- vipIcon:setScale(senderLabel:getContentSize().height/vipIcon:getContentSize().height)
                                vipIcon:setPosition(_posX, _posY)
                                -- if isUserSelf then
                                -- vipIcon:setAnchorPoint(ccp(1,0.5))
                                -- _posX=vipIcon:getPositionX()-vipIcon:getContentSize().width
                                -- else
                                vipIcon:setAnchorPoint(ccp(0, 0.5))
                                _posX = vipIcon:getPositionX() + vipIcon:getContentSize().width
                                -- end
                                cell:addChild(vipIcon, 3)
                            end
                            
                        end
                    end
                    
                    if isUserSelf then
                        -- _posX=(typeSp:getPositionX()-typeSp:getContentSize().width*typeSp:getScale()-5)-_posX
                        _posX = (600 - wSpace - spSize - 5) - _posX
                        if allianceRoleLb then
                            allianceRoleLb:setPositionX(allianceRoleLb:getPositionX() + _posX)
                            senderLabel:setPositionX(allianceRoleLb:getPositionX() + allianceRoleLb:getContentSize().width + 3)
                        else
                            senderLabel:setPositionX(senderLabel:getPositionX() + _posX)
                        end
                        _posX = senderLabel:getPositionX() + senderLabel:getContentSize().width
                        local titleLbSpace = 0
                        if titleLb:getContentSize().width > 0 then
                            titleLbSpace = 10
                        end
                        titleLb:setPositionX(_posX - titleLbSpace)
                        _posX = titleLb:getPositionX() + titleLb:getContentSize().width - titleLbSpace
                        if rankSp then
                            rankSp:setPositionX(_posX)
                            _posX = rankSp:getPositionX() + rankSp:getContentSize().width * rankSp:getScale()
                        end
                        if segIcon then
                            segIcon:setPositionX(_posX - 5)
                            _posX = segIcon:getPositionX() + segIcon:getContentSize().width
                        end
                        if wrIcon then
                            wrIcon:setPositionX(_posX)
                            _posX = wrIcon:getPositionX() + wrIcon:getContentSize().width * wrIcon:getScale()
                        end
                        if vipIcon then
                            vipIcon:setPositionX(_posX)
                            _posX = vipIcon:getPositionX() + vipIcon:getContentSize().width
                        end
                    end
                    
                end
                if (not (params and params.emojiId)) and chatVo.contentType == 1 and base.ifChatTransOpen == 1 and chatVo.params.language ~= G_getCurChoseLanguage() then
                    local switchLb
                    if(chatVo.showTranslate == true)then
                        switchLb = GetTTFLabel("【"..getlocal("translate_origin") .. "】", 25)
                    else
                        switchLb = GetTTFLabel("【"..getlocal("translate") .. "】", 25)
                    end
                    switchLb:setTag(823)
                    switchLb:setColor(G_ColorGreen)
                    local transBtn
                    local function onTranslate(hd, fn, tag)
                        if(chatVo.showTranslate == true)then
                            chatVo.showTranslate = false
                        else
                            chatVo.showTranslate = true
                        end
                        if(chatVo.showTranslate == false or (chatVo.translateContent and chatVo.translateContent[G_getCurChoseLanguage()]))then
                            if(self.tv and tolua.cast(self.tv, "LuaCCTableView"))then
                                local recordPoint = self.tv:getRecordPoint()
                                self.tv:reloadData()
                                self.tv:recoverToRecordPoint(recordPoint)
                                local msgNum = chatVoApi:getChatNum(self.selectedTabIndex + 1)
                                if(idx == msgNum - 1)then
                                    mainUI:setLastChat(true)
                                    -- chatVoApi:setHasNewData(self.chatType)
                                end
                            end
                        else
                            local function translateCallback(result)
                                if(self.tv and tolua.cast(self.tv, "LuaCCTableView"))then
                                    if(chatVo and chatVo.updateTransData)then
                                        chatVo:updateTransData(result, G_getCurChoseLanguage())
                                    end
                                    local recordPoint = self.tv:getRecordPoint()
                                    self.tv:reloadData()
                                    self.tv:recoverToRecordPoint(recordPoint)
                                    local msgNum = chatVoApi:getChatNum(self.selectedTabIndex + 1)
                                    if(idx == msgNum - 1)then
                                        mainUI:setLastChat(true)
                                        -- chatVoApi:setHasNewData(self.chatType)
                                    end
                                end
                            end
                            switchLb:setString(getlocal("translating"))
                            chatVoApi:translate(content, translateCallback, chatVo.params.language)
                        end
                    end
                    transBtn = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(0, 0, 10, 10), onTranslate)
                    transBtn:setTag(chatVo.index)
                    transBtn:setContentSize(CCSizeMake(switchLb:getContentSize().width + 20, 60))
                    transBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
                    transBtn:setOpacity(0)
                    transBtn:setAnchorPoint(ccp(0, 0))
                    transBtn:setPosition(wSpace, 0)
                    cell:addChild(transBtn)
                    switchLb:setPosition(transBtn:getContentSize().width / 2, 40)
                    transBtn:addChild(switchLb)
                    if G_getCurChoseLanguage() ~= "cn" and G_getCurChoseLanguage() ~= "tw" and G_getCurChoseLanguage() ~= "ja" and G_getCurChoseLanguage() ~= "ko" then
                        switchLb:setAnchorPoint(ccp(0, 0.5))
                        switchLb:setPosition(0, 40)
                        
                    end
                    local fromLb = GetTTFLabel(getlocal("translate_from", {getlocal("language_name_"..chatVo.params.language)}), 25)
                    fromLb:setColor(G_ColorOrange)
                    fromLb:setAnchorPoint(ccp(1, 0.5))
                    fromLb:setPosition(590, 40)
                    cell:addChild(fromLb)
                end
            else--系统公告
                local noticeLabel = GetTTFLabel(getlocal("chat_system_notice"), 28)
                cell:addChild(noticeLabel, 3)
                noticeLabel:setColor(color)
                
                noticeLabel:setAnchorPoint(ccp(0, 0))
                noticeLabel:setPosition(ccp(wSpace + spSize, totalHeight - spSize / 2 - 40 + 20))
            end
            if params and params.xlpd_invite then --协力攀登发送邀请处理
                chatVoApi:createXlpdInviteView(msgBg, isUserSelf, params.xlpd_invite, self.layerNum)
                return cell
            end
            local msgFont = nil
            --处理ios表情在安卓不显示问题
            if G_isIOS() == false then
                if platCfg.platCfgSameServerWithIos[G_curPlatName()] then
                    local tmpTb = {}
                    tmpTb["action"] = "EmojiConv"
                    tmpTb["parms"] = {}
                    tmpTb["parms"]["str"] = tostring(content)
                    local cjson = G_Json.encode(tmpTb)
                    content = G_accessCPlusFunction(cjson)
                    msgFont = G_EmojiFontSrc
                end
            end
            local showMsg = string.gsub(content, "<rayimg>", "")
            messageLabel = GetTTFLabelWrap(showMsg, 26, CCSizeMake(width, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, msgFont)
            msgX = msgX + typeWidth + wSpace
            if chatVo.contentType == 1 and base.ifChatTransOpen == 1 and chatVo.params.language ~= G_getCurChoseLanguage() then
                msgY = height + hSpace - 40
            else
                msgY = msgY + messageLabel:getContentSize().height + hSpace
            end
            
            messageLabel:setPosition(ccp(msgX, msgY))
            messageLabel:setAnchorPoint(ccp(0, 0.5))
            -- cell:addChild(messageLabel,2)
            --local msgColor=msgData.color
            --messageLabel:setColor(msgColor)
            
            local widLb = GetTTFLabel(content, 26)
            if widLb:getContentSize().width <= width then
                local msgBgW = widLb:getContentSize().width + 25
                if widLb:getContentSize().width < 50 then
                    msgBgW = 90
                end
                msgBg:setContentSize(CCSizeMake(msgBgW, widLb:getContentSize().height + 20))
            else
                msgBg:setContentSize(CCSizeMake(messageLabel:getContentSize().width + 25, messageLabel:getContentSize().height + 20))
            end
            if isUserSelf then
                messageLabel:setPosition(ccp(5, msgBg:getContentSize().height / 2))
            else
                messageLabel:setPosition(ccp(20, msgBg:getContentSize().height / 2))
            end
            
            msgBg:addChild(messageLabel, 2)
            
            if G_getCurChoseLanguage() == "ar" then
                messageLabel:setAnchorPoint(ccp(1, 0.5))
                if isUserSelf then
                    messageLabel:setPosition(ccp(msgBg:getContentSize().width - 17, msgBg:getContentSize().height / 2))
                else
                    messageLabel:setPosition(ccp(msgBg:getContentSize().width - 10, msgBg:getContentSize().height / 2))
                end
            end
            if robeImage then
                local robeSp = CCSprite:createWithSpriteFrameName(robeImage)
                robeSp:setAnchorPoint(ccp(isUserSelf and 1 or 0, 0))
                robeSp:setPosition(isUserSelf and msgBg:getContentSize().width - 10 or 10, msgBg:getContentSize().height - 8)
                msgBg:addChild(robeSp)
                msgBg:setPositionY(msgBg:getPositionY() - 5)
            end
            
            if chatVo.contentType and chatVo.contentType == 2 then --战报
                messageLabel:setColor(G_ColorYellow)
            else
                messageLabel:setColor(color)
            end
            
            if isGM then
                messageLabel:setColor(GM_Color2)
            end
            
            if params and params.emojiId then --动态表情
                messageLabel:setVisible(false)
                messageLabel:removeFromParentAndCleanup(true)
                local emoji = chatVoApi:getChatEmoji(params.emojiId)
                if emoji then
                    emoji:setAnchorPoint(ccp(msgBg:getAnchorPoint().x, 0))
                    emoji:setPosition(msgBg:getPositionX(), msgBg:getPositionY() - 140)
                    cell:addChild(emoji)
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

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function chatDialogTab2:eventHandlerNew(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        local msgNum = chatVoApi:getChatNum(self.selectedTabIndex + 1)
        if msgNum <= 0 then
            do return end
        end
        return msgNum
    elseif fn == "tableCellSizeForIndex" then
        local chatVo = chatVoApi:getChatVo(idx + 1, self.selectedTabIndex + 1)
        if chatVo == nil then
            do return end
        end
        local msgData = chatVo.msgData
        local height = msgData.height
        height = 136 / 2 - 40 + msgData.height + 13
        if height < 146 then
            height = 146
        end
        tmpSize = CCSizeMake(600, height + 5)
        if(base.ifChatTransOpen == 1 and chatVo.params.language ~= G_getCurChoseLanguage())then
            tmpSize = CCSizeMake(600, height + 60)
        end
        if chatVo.timeVisible then
            tmpSize.height = tmpSize.height + 60
        end
        return tmpSize
    elseif fn == "tableCellAtIndex" then
        local msgNum = chatVoApi:getChatNum(self.selectedTabIndex + 1)
        if msgNum <= 0 then
            do return end
        end
        local chatVo = chatVoApi:getChatVo(idx + 1, self.selectedTabIndex + 1)
        if chatVo == nil then
            do return end
        end
        local msgData = chatVo.msgData
        local type = chatVo.type
        local content = chatVo.content
        if(chatVo.showTranslate == true and chatVo.translateContent and chatVo.translateContent[G_getCurChoseLanguage()])then
            content = chatVo.translateContent[G_getCurChoseLanguage()]
        end
        --local showMsg=msgData.message
        local params = chatVo.params
        --local width=tonumber(msgData.width)
        --local height=tonumber(msgData.rows)*35
        if type == nil then
            do return end
        end
        
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        local vip = 0
        if params and params.vip then
            vip = params.vip or 0
        end
        
        local isUserSelf = false -- 是否是当前玩家发送的消息
        if GM_UidCfg[chatVo.sender] and chatVo.senderName then
            isGM = true
        end
        if chatVo.sender == playerVoApi:getUid() and type <= 3 and chatVo.contentType ~= 3 then
            isUserSelf = true
        end
        
        local wSpace = 5
        local hSpace = 5
        if(base.ifChatTransOpen == 1 and chatVo.params.language ~= G_getCurChoseLanguage())then
            hSpace = 60
        end
        local width = msgData.width
        local height = msgData.height
        height = 136 / 2 - 40 + msgData.height + 13
        if height < 146 then
            height = 146
        end
        local jiange = 0
        local totalHeight = height + hSpace + jiange
        local timeLbH = 0
        if chatVo.timeVisible then
            timeLbH = 60
            local timeStr = G_chatTime(chatVo.time, true)
            local timeLabel = GetTTFLabel(timeStr, 26)
            timeLabel:setAnchorPoint(ccp(0.5, 0.5))
            timeLabel:setPosition(ccp(300, totalHeight + timeLbH - 30))
            cell:addChild(timeLabel, 3)
            timeLabel:setColor(G_ColorYellowPro)
        end
        
        local typeStr, color, icon = chatVoApi:getTypeStr(chatVo.subType, self.selectedTabIndex, params.allianceRole, vip)
        -- if chatVo.contentType and chatVo.contentType==2 then
        -- else
        -- color=G_ColorWhite
        -- end
        -- local typeLabel=GetTTFLabel(typeStr,28)
        -- typeLabel:setAnchorPoint(ccp(0,1))
        -- cell:addChild(typeLabel,3)
        -- typeLabel:setColor(color)
        -- --height=height-typeLabel:getContentSize().height/2
        -- typeLabel:setPosition(ccp(wSpace,height+hSpace))
        -- typeLabel:setVisible(false)
        local typeWidth = 55
        
        local bgImage
        if params.allianceRole and tonumber(params.allianceRole) == 1 then
            bgImage = "chat_head_fu.png"
        elseif params.allianceRole and tonumber(params.allianceRole) == 2 then
            bgImage = "chat_head_zheng.png"
        else
            bgImage = "chat_head_common.png"
        end
        
        -- 新版显示头像所以不在需要icon
        local pic = 1
        if params and params.pic then
            pic = params.pic
        end
        
        if isGM then
            bgImage = "chat_head_system.png"
            icon = GM_Icon
        end
        --类型图标
        local spSize = 98
        local spaceX = 10
        local typeSp
        -- if type<=3 and chatVo.contentType~=3 then
        -- typeSp = playerVoApi:getPersonPhotoSp(pic)
        -- else
        typeSp = CCSprite:createWithSpriteFrameName(bgImage)
        -- end
        local typeScale = spSize / typeSp:getContentSize().width
        typeSp:setAnchorPoint(ccp(0.5, 0.5))
        cell:addChild(typeSp, 3)
        typeSp:setScale(typeScale)
        
        if isUserSelf then
            typeSp:setPosition(ccp(600 - wSpace - spSize / 2, totalHeight - spSize / 2 - 30))
        else
            typeSp:setPosition(ccp(wSpace + spSize / 2, totalHeight - spSize / 2 - 30))
        end
        
        -- 头像
        local headSp
        if isGM then
            headSp = CCSprite:createWithSpriteFrameName(icon)
            headSp:setScale(0.8)
        elseif type <= 3 and chatVo.contentType ~= 3 then
            headSp = playerVoApi:getPersonPhotoSp(pic, nil, chatVo.sender)
        else
            headSp = CCSprite:createWithSpriteFrameName(icon)
        end
        headSp:setScale(78 / 70 * headSp:getScale())
        
        typeSp:addChild(headSp)
        headSp:setPosition(typeSp:getContentSize().width / 2, 80)
        
        if isGM then
            headSp:setPosition(typeSp:getContentSize().width / 2, typeSp:getContentSize().height / 2)
        end
        
        local timeStr = G_chatTime(chatVo.time, true)
        timeLabel = GetTTFLabel(timeStr, 26)
        timeLabel:setAnchorPoint(ccp(1, 1))
        timeLabel:setPosition(ccp(590, height + hSpace - 3))
        cell:addChild(timeLabel, 3)
        timeLabel:setColor(color)
        timeLabel:setVisible(false)
        
        -- 聊天信息背景
        local bgImage
        if isUserSelf then
            bgImage = "chat_bg_right.png"
            --       elseif chatVo.subType==2 then
            --       bgImage = "chat_bg_purple.png"
            --   elseif chatVo.subType==3 then
            --   bgImage = "chat_bg_blue.png"
            -- elseif chatVo.contentType and chatVo.contentType==3 then
            -- bgImage = "chat_bg_yellow.png"
        else
            bgImage = "chat_bg_left.png"
        end

        local function msgBgClick(...)
            
        end
        msgBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgImage, CCRect(30, 25, 1, 1), msgBgClick)
        msgBg:setContentSize(CCSizeMake(100, 50))
        if isUserSelf then
            msgBg:setAnchorPoint(ccp(1, 1))
            msgBg:setPosition(ccp(600 - wSpace - spSize - cdis, totalHeight - spSize / 2 - 17))
        else
            msgBg:setAnchorPoint(ccp(0, 1))
            msgBg:setPosition(ccp(wSpace + spSize + cdis, totalHeight - spSize / 2 - 17))
        end
        cell:addChild(msgBg)
        
        local messageLabel
        local msgX = 0
        local msgY = -1
        
        local rect = CCRect(0, 0, 50, 50)
        local capInSet = CCRect(20, 20, 10, 10)
        local senderLabel
        if type <= 3 and chatVo.contentType ~= 3 then
            local function cellClick1(hd, fn, idx)
                if G_checkClickEnable() == false then
                    do
                        return
                    end
                end
                if self.tv:getIsScrolled() == true then
                    do return end
                end
                if (battleScene and battleScene.isBattleing == true) then
                    do return end
                end
                base:setWait()
                if self.cellBgTab and self.cellBgTab[idx] then
                    local function touchCallback()
                        if params.brType then
                            self:cellClick(idx, params.brType)
                        elseif params.serverWarTeam == 1 then
                            self:cellClick(idx, 6)
                        elseif params.isExpedition == true then
                            self:cellClick(idx, 5)
                        elseif params.isAllianceWar == true then
                            self:cellClick(idx, 3)
                        elseif params.report ~= nil or params.reportId ~= nil then
                            self:cellClick(idx, 2)
                        elseif params.ltzdz then
                            self:cellClick(idx, 19)
                        else
                            self:cellClick(idx, 1)
                        end
                        base:cancleWait()
                    end
                    local fadeIn = CCFadeIn:create(0.2)
                    --local delay=CCDelayTime:create(2)
                    local fadeOut = CCFadeOut:create(0.2)
                    local callFunc = CCCallFuncN:create(touchCallback)
                    local acArr = CCArray:create()
                    acArr:addObject(fadeIn)
                    --acArr:addObject(delay)
                    acArr:addObject(fadeOut)
                    acArr:addObject(callFunc)
                    local seq = CCSequence:create(acArr)
                    self.cellBgTab[idx]:runAction(seq)
                end
            end
            local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfItemBg.png", capInSet, cellClick1)
            backSprie:ignoreAnchorPointForPosition(false);
            backSprie:setAnchorPoint(ccp(0, 0))
            backSprie:setTag(chatVo.index)
            backSprie:setIsSallow(false)
            backSprie:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
            backSprie:setPosition(ccp(2, 0))
            cell:addChild(backSprie, 1)
            backSprie:setContentSize(CCSizeMake(596, totalHeight - 5))
            backSprie:setOpacity(0)
            table.insert(self.cellBgTab, chatVo.index, backSprie)
            
            local function showPlayerInfoHandler(hd, fn, idx)
                if G_checkClickEnable() == false then
                    do
                        return
                    end
                end
                if self.tv:getIsScrolled() == true then
                    do return end
                end
                if (battleScene and battleScene.isBattleing == true) then
                    do return end
                end
                base:setWait()
                if self.cellBgTab and self.cellBgTab[idx] then
                    local function touchCallback()
                        self:cellClick(idx, 1)
                        base:cancleWait()
                    end
                    local fadeIn = CCFadeIn:create(0.2)
                    --local delay=CCDelayTime:create(2)
                    local fadeOut = CCFadeOut:create(0.2)
                    local callFunc = CCCallFuncN:create(touchCallback)
                    local acArr = CCArray:create()
                    acArr:addObject(fadeIn)
                    --acArr:addObject(delay)
                    acArr:addObject(fadeOut)
                    acArr:addObject(callFunc)
                    local seq = CCSequence:create(acArr)
                    self.cellBgTab[idx]:runAction(seq)
                end
            end
            
            if chatVo.sender and chatVo.senderName then--普通聊天和战报
                --军团名称
                if G_chatAllianceName == true then
                    local allianceName = params.allianceName
                    if allianceName and allianceName ~= "" and allianceName ~= "nil" and self.selectedTabIndex ~= 2 then
                        allianceNameLabel = GetTTFLabel(allianceName, 26)
                        allianceNameLabel:setAnchorPoint(ccp(1, 1))
                        allianceNameLabel:setPosition(ccp(590 - timeLabel:getContentSize().width - 10, height + hSpace - 4))
                        cell:addChild(allianceNameLabel, 3)
                        allianceNameLabel:setColor(G_ColorGreen)
                        
                        local function touch()
                            
                        end
                        local allianceNameSp = LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfItemBg.png", capInSet, touch)
                        allianceNameSp:ignoreAnchorPointForPosition(false)
                        allianceNameSp:setAnchorPoint(ccp(1, 1))
                        --allianceNameSp:setTag(chatVo.index)
                        allianceNameSp:setIsSallow(false)
                        allianceNameSp:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                        allianceNameSp:setPosition(ccp(590 - timeLabel:getContentSize().width - 10 + 5, height + hSpace - 4 + 2))
                        cell:addChild(allianceNameSp, 2)
                        allianceNameSp:setContentSize(CCSizeMake(allianceNameLabel:getContentSize().width + 10, allianceNameLabel:getContentSize().height + 4))
                    end
                end
                local lbSize = 28
                local lbSpace = 0
                if platCfg.platCfgBMImage[G_curPlatName()] ~= nil then
                    lbSpace = 8
                    lbSize = 22
                end
                local nameStr = chatVoApi:getNameStr(type, chatVo.subType, chatVo.senderName, chatVo.reciverName, chatVo.sender)
                senderLabel = GetTTFLabel(nameStr, lbSize)
                if isUserSelf then
                    senderLabel:setAnchorPoint(ccp(1, 0))
                    senderLabel:setPosition(ccp(600 - wSpace - spSize - 5, totalHeight - spSize / 2 - 15 + 20 + lbSpace))
                else
                    senderLabel:setAnchorPoint(ccp(0, 0))
                    senderLabel:setPosition(ccp(wSpace + spSize + 5, totalHeight - spSize / 2 - 15 + 20 + lbSpace))
                end
                cell:addChild(senderLabel, 3)
                senderLabel:setColor(color)
                
                if isGM then
                    senderLabel:setColor(GM_Color)
                end
                
                local nameLabel = GetTTFLabel(nameStr, lbSize)
                local nameBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png", capInSet, showPlayerInfoHandler)
                nameBgSp:ignoreAnchorPointForPosition(false)
                nameBgSp:setAnchorPoint(ccp(0, 1))
                nameBgSp:setTag(chatVo.index)
                nameBgSp:setIsSallow(true)
                nameBgSp:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                nameBgSp:setPosition(ccp(wSpace, height + hSpace - 2))
                cell:addChild(nameBgSp, 2)
                nameBgSp:setContentSize(CCSizeMake(nameLabel:getContentSize().width + wSpace + spSize + spaceX, nameLabel:getContentSize().height))
                nameBgSp:setOpacity(0)
                
                --军衔
                local rankSp = nil
                local spScale = 0.6
                -- local showRank=chatVoApi:isShowRank(params.rank)
                -- if showRank==true then
                local pic = playerVoApi:getRankIconName(params.rank)
                if pic and isGM == false then
                    rankSp = CCSprite:createWithSpriteFrameName(pic)
                    if rankSp then
                        typeSp:addChild(rankSp)
                        rankSp:setScale(1 / typeScale * spScale)
                        rankSp:setAnchorPoint(ccp(0.5, 0.5))
                        rankSp:setPosition(typeSp:getContentSize().width / 2, 28)
                    end
                end
                -- end
                
                --vip
                local vipIcon = nil
                if G_chatVip == true and isGM == false then
                    if vip and vip ~= 0 then
                        if platCfg.platCfgBMImage[G_curPlatName()] ~= nil then
                            vipIcon = GetTTFLabel(getlocal("VIPStr1", {vip}), 22)
                            vipIcon:setColor(G_ColorYellowPro)
                            if isUserSelf then
                                vipIcon:setAnchorPoint(ccp(1, 0.5))
                                vipIcon:setPosition(ccp(600 - wSpace - spSize - 5, totalHeight - spSize / 2))
                            else
                                vipIcon:setAnchorPoint(ccp(0, 0.5))
                                vipIcon:setPosition(ccp(wSpace + spSize + 5, totalHeight - spSize / 2))
                            end
                            cell:addChild(vipIcon)
                        else
                            local vipPic = chatVoApi:getVipPic(params.isVipV, vip)
                            vipIcon = CCSprite:createWithSpriteFrameName(vipPic)
                            vipIcon:setScale(1 / typeScale)
                            vipIcon:setPosition(typeSp:getContentSize().width / 2, 130)
                            vipIcon:setAnchorPoint(ccp(0.5, 0.5))
                            typeSp:addChild(vipIcon)
                        end
                        
                    end
                end
                
                --跨服战排名前3名称号图标
                local wrIcon = nil
                local iconScale = 0.5
                local serverWarRank = params.wr or 0
                local startTime = params.st or 0
                if serverWarRank and serverWarRank > 0 and startTime and startTime > 0 and serverWarPersonalVoApi then
                    local icon, sType = serverWarPersonalVoApi:getRankIcon(serverWarRank, startTime)
                    if icon and (sType == 1 or sType == 2) then
                        if sType == 1 then
                            wrIcon = CCSprite:createWithSpriteFrameName(icon)
                        elseif sType == 2 then
                            wrIcon = GraySprite:createWithSpriteFrameName(icon)
                        end
                        if wrIcon then
                            local senderW = senderLabel:getContentSize().width + wrIcon:getContentSize().width / 2 - 20
                            local senderH = senderLabel:getContentSize().height / 2
                            if isUserSelf then
                                wrIcon:setPosition(ccp(600 - wSpace - spSize - senderW, totalHeight - spSize / 2 - 40 + 20 + senderH))
                            else
                                wrIcon:setPosition(ccp(wSpace + spSize + senderW, totalHeight - spSize / 2 - 40 + 20 + senderH))
                            end
                            wrIcon:setScale(iconScale)
                            cell:addChild(wrIcon, 2)
                        end
                    end
                end
            end
            if chatVo.contentType == 1 and base.ifChatTransOpen == 1 and chatVo.params.language ~= G_getCurChoseLanguage() then
                local switchLb
                if(chatVo.showTranslate == true)then
                    switchLb = GetTTFLabel("【"..getlocal("translate_origin") .. "】", 25)
                else
                    switchLb = GetTTFLabel("【"..getlocal("translate") .. "】", 25)
                end
                switchLb:setTag(823)
                switchLb:setColor(G_ColorGreen)
                local transBtn
                local function onTranslate(hd, fn, tag)
                    if(chatVo.showTranslate == true)then
                        chatVo.showTranslate = false
                    else
                        chatVo.showTranslate = true
                    end
                    if(chatVo.showTranslate == false or (chatVo.translateContent and chatVo.translateContent[G_getCurChoseLanguage()]))then
                        if(self.tv and tolua.cast(self.tv, "LuaCCTableView"))then
                            local recordPoint = self.tv:getRecordPoint()
                            self.tv:reloadData()
                            self.tv:recoverToRecordPoint(recordPoint)
                            local msgNum = chatVoApi:getChatNum(self.selectedTabIndex + 1)
                            if(idx == msgNum - 1)then
                                mainUI:setLastChat(true)
                                -- chatVoApi:setHasNewData(self.chatType)
                            end
                        end
                    else
                        local function translateCallback(result)
                            if(self.tv and tolua.cast(self.tv, "LuaCCTableView"))then
                                if(chatVo and chatVo.updateTransData)then
                                    chatVo:updateTransData(result, G_getCurChoseLanguage())
                                end
                                local recordPoint = self.tv:getRecordPoint()
                                self.tv:reloadData()
                                self.tv:recoverToRecordPoint(recordPoint)
                                local msgNum = chatVoApi:getChatNum(self.selectedTabIndex + 1)
                                if(idx == msgNum - 1)then
                                    mainUI:setLastChat(true)
                                    -- chatVoApi:setHasNewData(self.chatType)
                                end
                            end
                        end
                        switchLb:setString(getlocal("translating"))
                        chatVoApi:translate(content, translateCallback, chatVo.params.language)
                    end
                end
                transBtn = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(0, 0, 10, 10), onTranslate)
                transBtn:setTag(chatVo.index)
                transBtn:setContentSize(CCSizeMake(switchLb:getContentSize().width + 20, 60))
                transBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
                transBtn:setOpacity(0)
                transBtn:setAnchorPoint(ccp(0, 0))
                transBtn:setPosition(wSpace, 0)
                cell:addChild(transBtn)
                switchLb:setPosition(transBtn:getContentSize().width / 2, 40)
                transBtn:addChild(switchLb)
                if G_getCurChoseLanguage() ~= "cn" and G_getCurChoseLanguage() ~= "tw" and G_getCurChoseLanguage() ~= "ja" and G_getCurChoseLanguage() ~= "ko" then
                    switchLb:setAnchorPoint(ccp(0, 0.5))
                    switchLb:setPosition(0, 40)
                    
                end
                local fromLb = GetTTFLabel(getlocal("translate_from", {getlocal("language_name_"..chatVo.params.language)}), 25)
                fromLb:setColor(G_ColorOrange)
                fromLb:setAnchorPoint(ccp(1, 0.5))
                fromLb:setPosition(590, 40)
                cell:addChild(fromLb)
            end
        else--系统公告
            local noticeLabel = GetTTFLabel(getlocal("chat_system_notice"), 28)
            cell:addChild(noticeLabel, 3)
            noticeLabel:setColor(color)
            
            noticeLabel:setAnchorPoint(ccp(0, 0))
            noticeLabel:setPosition(ccp(wSpace + spSize, totalHeight - spSize / 2 - 40 + 20))
        end
        local msgFont = nil
        --处理ios表情在安卓不显示问题
        if G_isIOS() == false then
            if platCfg.platCfgSameServerWithIos[G_curPlatName()] then
                local tmpTb = {}
                tmpTb["action"] = "EmojiConv"
                tmpTb["parms"] = {}
                tmpTb["parms"]["str"] = tostring(content)
                local cjson = G_Json.encode(tmpTb)
                content = G_accessCPlusFunction(cjson)
                msgFont = G_EmojiFontSrc
            end
        end
        local showMsg = string.gsub(content, "<rayimg>", "")
        messageLabel = GetTTFLabelWrap(showMsg, 26, CCSizeMake(width, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, msgFont)
        msgX = msgX + typeWidth + wSpace
        if chatVo.contentType == 1 and base.ifChatTransOpen == 1 and chatVo.params.language ~= G_getCurChoseLanguage() then
            msgY = height + hSpace - 40
        else
            msgY = msgY + messageLabel:getContentSize().height + hSpace
        end
        
        messageLabel:setPosition(ccp(msgX, msgY))
        messageLabel:setAnchorPoint(ccp(0, 0.5))
        -- cell:addChild(messageLabel,2)
        --local msgColor=msgData.color
        --messageLabel:setColor(msgColor)
        
        local widLb = GetTTFLabel(content, 26)
        if widLb:getContentSize().width <= width then
            local msgBgW = widLb:getContentSize().width + 25
            if widLb:getContentSize().width < 50 then
                msgBgW = 70
            end
            msgBg:setContentSize(CCSizeMake(msgBgW, widLb:getContentSize().height + 20))
        else
            msgBg:setContentSize(CCSizeMake(messageLabel:getContentSize().width + 25, messageLabel:getContentSize().height + 20))
        end
        if isUserSelf then
            messageLabel:setPosition(ccp(5, msgBg:getContentSize().height / 2))
        else
            messageLabel:setPosition(ccp(20, msgBg:getContentSize().height / 2))
        end
        
        msgBg:addChild(messageLabel, 2)
        
        if G_getCurChoseLanguage() == "ar" then
            messageLabel:setAnchorPoint(ccp(1, 0.5))
            if isUserSelf then
                messageLabel:setPosition(ccp(msgBg:getContentSize().width - 17, msgBg:getContentSize().height / 2))
            else
                messageLabel:setPosition(ccp(msgBg:getContentSize().width - 10, msgBg:getContentSize().height / 2))
            end
        end
        
        if chatVo.contentType and chatVo.contentType == 2 then --战报
            messageLabel:setColor(G_ColorYellow)
        else
            messageLabel:setColor(color)
        end
        
        if isGM then
            messageLabel:setColor(GM_Color2)
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

--点击了cell或cell上某个按钮 type 1:用户信息,2:战报
function chatDialogTab2:cellClick(idx, type)
    PlayEffect(audioCfg.mouseClick)
    local chatVo = chatVoApi:getChatVoByIndex(idx, self.selectedTabIndex + 1)
    if chatVo and chatVo.type <= 3 then
        if base.chatReportSwitch == 1 and chatVo and chatVo.contentType == 2 and (type == 2 or type == 3 or type == 5 or type == 6 or type == 8 or type == 9 or type == 10 or type == 11 or type == 12 or type == 17) then
            if chatVo.params then
                if chatVo.params.report and SizeOfTable(chatVo.params.report) > 0 then
                elseif chatVo.params.reportId then
                    local reportId = chatVo.params.reportId
                    
                    local httpUrl = "http://"..base.serverIp.."/tank-server/public/index.php/api/chatrecord/get"
                    local reqStr = "zoneid="..base.curZoneID.."&id="..reportId
                    -- deviceHelper:luaPrint(httpUrl)
                    -- deviceHelper:luaPrint(reqStr)
                    local retStr = G_sendHttpRequestPost(httpUrl, reqStr)
                    -- deviceHelper:luaPrint(retStr)
                    if(retStr ~= "")then
                        local retData = G_Json.decode(retStr)
                        if(retData["ret"] == 0 or retData["ret"] == "0")then
                            if retData.data and retData.data.report and retData.data.report.content then
                                local report = G_Json.decode(retData.data.report.content)
                                chatVoApi:setChatReport(idx, self.selectedTabIndex + 1, nil, report)
                                chatVo.params.report = report
                            end
                        end
                    end
                end
            end
            if chatVo.params == nil or chatVo.params.report == nil or SizeOfTable(chatVo.params.report) == 0 then
                do return end
            end
        end
        if type == 1 then
            local function emailCallBack()
                if tonumber(chatVo.sender) == tonumber(playerVoApi:getUid()) then
                    --smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("player_message_info_tip1"),30)
                    smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("player_message_info_tip1"), true, self.layerNum + 2)
                    return false
                else
                    local lyNum = self.layerNum + 2
                    emailVoApi:showWriteEmailDialog(lyNum, getlocal("email_write"), chatVo.senderName, nil, nil, nil, nil, chatVo.sender)
                    return true
                end
                --self.editMsgBox:setVisible(false)
            end
            local function whisperCallBack()
                if tonumber(chatVo.sender) == tonumber(playerVoApi:getUid()) then
                    --smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("player_message_info_tip2"),30)
                    smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("message_scene_whiper_prompt"), true, self.layerNum + 2)
                    return false
                else
                    local senderName = chatVo.senderName
                    if self.chatDialog then
                        self.chatDialog:changeReciver(senderName, true, chatVo.sender)
                    end
                    return true
                end
                --self.editMsgBox:setVisible(false)
            end
            local function resetBoxCallBack()
            end
            local function addBlackList()
                -- local uid=chatVo.sender
                -- local name=chatVo.senderName
                -- local blackList=G_getBlackList()
                -- if blackList and SizeOfTable(blackList)>0 then
                -- for k,v in pairs(blackList) do
                -- if tonumber(uid)==tonumber(v.uid) and tostring(name)==tostring(v.name) then
                -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("shieldSuccess",{name}),28)
                -- do return end
                -- end
                -- end
                -- end
                -- if SizeOfTable(G_getBlackList())>=G_blackListNum then
                --         smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("blackListMax"),28)
                --        do return end
                --    end
                -- local function confirmHandler()
                -- local function saveBlackCallback()
                --                     smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("shieldSuccess",{name}),28)
                --                 end
                -- local toBlackTb={uid=uid,name=name}
                -- local isSuccess=G_saveNameAndUidInBlackList(toBlackTb,saveBlackCallback)
                -- -- if isSuccess==true then
                -- -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("shieldSuccess",{name}),28)
                -- -- end
                -- end
                -- local mailStr=getlocal("shieldDesc",{name})
                --             if base.mailBlackList==1 then
                --                 mailStr=getlocal("shieldDesc1",{name})
                --             end
                -- smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),confirmHandler,getlocal("dialog_title_prompt"),mailStr,nil,self.layerNum+1)
            end
            local function addMailList()
                --             local uid=chatVo.sender
                -- local name=chatVo.senderName
                -- local blackList=G_getMailList()
                -- if blackList and SizeOfTable(blackList)>0 then
                -- for k,v in pairs(blackList) do
                -- if tonumber(uid)==tonumber(v.uid) and tostring(name)==tostring(v.name) then
                -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("addMailListSuccess",{name}),28)
                -- do return end
                -- end
                -- end
                -- end
                -- if SizeOfTable(G_getBlackList())>=30 then
                --         smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("mailListMax"),28)
                --        do return end
                --    end
                -- local function confirmHandler()
                -- local function callback(fn,data)
                --               local ret,sData=base:checkServerData(data)
                --               if ret==true then
                --    --            local toBlackTb={uid=uid,name=name}
                -- -- local isSuccess=G_saveNameAndUidInMailList(toBlackTb)
                -- -- if isSuccess==true then
                --                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("addMailListSuccess",{name}),28)
                --               -- end
                --               local function callbackList(fn,data)
                -- local ret,sData=base:checkServerData(data)
                -- if ret==true then
                
                -- end
                -- end
                -- socketHelper:friendsList(callbackList)
                --               elseif sData.ret==-12001 then
                --    --            local toBlackTb={uid=uid,name=name}
                -- -- local isSuccess=G_saveNameAndUidInMailList(toBlackTb)
                --               local function callbackList(fn,data)
                -- local ret,sData=base:checkServerData(data)
                -- if ret==true then
                
                -- end
                -- end
                -- socketHelper:friendsList(callbackList)
                --               end
                --           end
                -- socketHelper:friendsAdd(name,callback)
                -- end
                -- smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),confirmHandler,getlocal("dialog_title_prompt"),getlocal("mailListDesc",{name}),nil,self.layerNum+1)
            end
            local params = chatVo.params
            local content1 = chatVo.senderName--getlocal("player_message_info_name",{chatVo.senderName,params.level,playerVoApi:getRankName(params.rank)})
            local content2 = getlocal("alliance_info_level") .. " Lv."..params.level--.." "..playerVoApi:getRankName(params.rank)
            local content3 = getlocal("player_message_info_power") .. ": "..G_countDigit(params.power)
            --是否有联盟
            if params.allianceName then
                content4 = getlocal("player_message_info_alliance") .. ": "..params.allianceName
            else
                content4 = getlocal("player_message_info_alliance") .. ": "..getlocal("alliance_info_content")
            end
            local content = {{content1, 28, G_ColorYellowPro}, {content2, 22}, {content3, 22}, {content4, 27}}
            local pic = params.pic
            local rank = params.rank
            local hfid = params.hfid
            local serverWarRank = params.wr or 0
            local startTime = params.st or 0
            local vipPicStr = nil
            if params then
                if params.isVipV then
                    vipPicStr = "vipNoLevel.png"
                elseif params.vip then
                    vipPicStr = "Vip"..params.vip..".png"
                end
            end
            local isGM = false
            if GM_UidCfg[chatVo.sender] then
                isGM = true
            end
            local rpoint = nil
            if params.bnum and params.bnum > 0 and params.rpoint then
                rpoint = params.rpoint
            end
            if chatVo.sender == playerVoApi:getUid() then
                smallDialog:showPlayerInfoSmallDialog("newSmallPanelBg.png", CCSizeMake(550, 450), CCRect(0, 0, 400, 400), CCRect(170, 80, 22, 10), getlocal("player_message_info_email"), emailCallBack, getlocal("player_message_info_whisper"), whisperCallBack, getlocal("player_message_info_title"), content, nil, self.layerNum + 1, 1, nil, resetBoxCallBack, nil, pic, nil, nil, nil, nil, rank, serverWarRank, startTime, params.title, chatVo.senderName, vipPicStr, isGM, rpoint, hfid, chatVo.sender)
                
            else
                smallDialog:showPlayerInfoSmallDialog("newSmallPanelBg.png", CCSizeMake(550, 530), CCRect(0, 0, 400, 400), CCRect(170, 80, 22, 10), getlocal("player_message_info_email"), emailCallBack, getlocal("player_message_info_whisper"), whisperCallBack, getlocal("player_message_info_title"), content, nil, self.layerNum + 1, 1, nil, resetBoxCallBack, nil, pic, getlocal("shield"), addBlackList, getlocal("addFriends_title"), addMailList, rank, serverWarRank, startTime, params.title, chatVo.senderName, vipPicStr, isGM, rpoint, hfid, chatVo.sender)
            end
        elseif type == 2 then
            local params = chatVo.params
            local report
            if params then
                report = params.report
            end
            if report ~= nil then
                local titleStr = ""
                if report.type == 1 then
                    titleStr = getlocal("fight_content_fight_title")
                elseif report.type == 2 then
                    titleStr = getlocal("scout_content_scout_title")
                elseif report.type == 3 then
                    titleStr = getlocal("fight_content_return_title")
                end
                require "luascript/script/game/scene/gamedialog/emailDetailDialog"
                local layerNum = self.layerNum + 1
                local td = emailDetailDialog:new(layerNum, 2, nil, nil, nil, chatVo.sender, report)
                local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), {}, nil, nil, titleStr, false, layerNum)
                sceneGame:addChild(dialog, layerNum)
            end
        elseif type == 3 or type == 5 then
            local params = chatVo.params
            local report
            if params then
                report = params.report
            end
            if report ~= nil then
                local data = {data = {report = report}, isAttacker = params.isAttacker, isReport = true}
                if type == 3 then
                    data.isInAllianceWar = true
                end
                battleScene:initData(data)
            end
        elseif type == 6 then
            local params = chatVo.params
            local report
            if params then
                report = params.report
            end
            if report ~= nil and SizeOfTable(report) > 0 then
                require "luascript/script/game/scene/gamedialog/serverWarTeam/sertverWarReportDetailDialog"
                local layerNum = self.layerNum + 1
                local td = sertverWarReportDetailDialog:new(layerNum, report, true)
                local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), {}, nil, nil, getlocal("arena_report_title"), false, layerNum)
                sceneGame:addChild(dialog, layerNum)
            end
        elseif type == 8 or type == 9 or type == 10 or type == 11 or type == 12 then
            local params = chatVo.params
            local report
            local landform
            if params then
                report = params.report
                if params.landform then
                    landform = {params.landform, params.landform}
                end
            end
            if report ~= nil and SizeOfTable(report) > 0 then
                local battleType = nil
                if type == 8 then
                    battleType = 1
                elseif type == 9 then
                    battleType = 3
                elseif type == 10 then
                    battleType = 4
                elseif type == 11 then
                    battleType = 6
                end
                local data = {data = {report = report}, landform = landform, isReport = true, battleType = battleType}
                battleScene:initData(data)
            end
        elseif type == 13 then
            local params = chatVo.params
            local rebelInfo = params.rebelInfo
            if rebelInfo and rebelInfo.x and rebelInfo.y then
                if self.chatDialog and self.chatDialog.close then
                    self.chatDialog:close()
                end
                if mainUI:changeToWorld() == true then
                    worldScene:focus(rebelInfo.x, rebelInfo.y)
                end
            end
        elseif type == 14 then
            local params = chatVo.params
            local emblemID = params.eId
            if(emblemID)then
                local cfg = emblemVoApi:getEquipCfgById(emblemID)
                local eVo = emblemVo:new(cfg)
                eVo:initWithData(emblemID, 0)
                emblemVoApi:showInfoDialog(eVo, self.layerNum + 1)
            end
        elseif type == 17 then
            local params = chatVo.params
            if params.report and dailyNewsVoApi and dailyNewsVoApi.showDailyNewsDialog then
                dailyNewsVoApi:showDailyNewsDialog(self.layerNum + 1, params.report)
            end
        elseif type == 18 then
            local params = chatVo.params
            if params and params.paramTab and params.paramTab.functionStr then
                if self.chatDialog and self.chatDialog.close then
                    self.chatDialog:close()
                end
                jump_judgment(params.paramTab.functionStr)
            end
        elseif type == 19 then
            local params = chatVo.params
            if base.serverTime > params.ltzdz then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("ltzdz_invite_expired"), 30)
            else
                G_goToDialog2("ltzdz", 3, true)
            end
        end
    end
end

function chatDialogTab2:tick()
    if chatVoApi:getHasNewData(self.selectedTabIndex + 1) == true then
        if(self.tv == nil or tolua.cast(self.tv, "LuaCCTableView") == nil)then
            do return end
        end
        if chatVoApi:isChat2_0() then
            chatVoApi:initLocalPrivateChatData()
            local recordPoint = self.tv:getRecordPoint()
            local tabIndex = self.selectedTabIndex + 1
            if self.curShowIndex == 0 then
                if self.noLabel and self.noLabel:isVisible() and chatVoApi:getPrivateChatDataNum() > 0 then
                    self.noLabel:setVisible(false)
                end
                self.tv:reloadData()
            elseif self.curShowIndex == 2 then
                local isMaxMore = chatVoApi:getMaxMore(tabIndex)
                if isMaxMore == true then
                    self.tv:removeCellAtIndex(0)
                    chatVoApi:setMaxMore(tabIndex, false)
                end
                local msgNum = chatVoApi:getChatNum(tabIndex)
                self.tv:insertCellAtIndex(msgNum - 1)
            end
            chatVoApi:setNoNewData(tabIndex)
            if self.curShowIndex == 2 then
                -- if self.isFirst then
                --           self.isFirst=false
                --       else
                --           self.tv:recoverToRecordPoint(recordPoint)
                --       end
                if self.bgLayer:isVisible() then
                    local chatData = chatVoApi:getPrivateChatDataByKey(self.curChatDataUid)
                    chatVoApi:setReadData(chatData)
                end
            end
        else
            local recordPoint = self.tv:getRecordPoint()
            --self:resetData()
            local tabIndex = self.selectedTabIndex + 1
            local isMaxMore = chatVoApi:getMaxMore(tabIndex)
            if isMaxMore == true then
                self.tv:removeCellAtIndex(0)
                chatVoApi:setMaxMore(tabIndex, false)
            end
            local msgNum = chatVoApi:getChatNum(tabIndex)
            self.tv:insertCellAtIndex(msgNum - 1)
            --mainUI:setLastChat()
            chatVoApi:setNoNewData(tabIndex)
            if self.isFirst then
                self.isFirst = false
            else
                self.tv:recoverToRecordPoint(recordPoint)
            end
        end
    end
end

function chatDialogTab2:resetTvPos()
    local recordPoint = self.tv:getRecordPoint()
    if recordPoint.y < 0 then
        recordPoint.y = 0
        self.tv:recoverToRecordPoint(recordPoint)
    end
end

--用户处理特殊需求,没有可以不写此方法
function chatDialogTab2:doUserHandler()
    
end

function chatDialogTab2:reloadChatDialog2WhenChatLogin()
    if self and self.tv then
        self.tv:reloadData()
    end
end

function chatDialogTab2:dispose()
    self.tv = nil
    self.bgLayer = nil
    self.tableCell1 = nil
    self.layerNum = nil
    self.selectedTabIndex = nil
    --self.chatDialog=nil
    self.cellBgTab = nil
    self = nil
end
