chatDialogTab3 = {}

function chatDialogTab3:new()
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
    self.redBagTagAndIconTb = {}
    return nc
end

function chatDialogTab3:init(layerNum, selectedTabIndex, chatDialog)
    self.bgLayer = CCLayer:create()
    self.layerNum = layerNum
    self.selectedTabIndex = selectedTabIndex
    self.chatDialog = chatDialog
    self:initTableView()
    
    return self.bgLayer
end

--设置对话框里的tableView
function chatDialogTab3:initTableView()
    local function callBack(...)
        if chatVoApi:isChat2_0() then
            return self:eventHandlerNew(...)
        else
            return self:eventHandler(...)
        end
        
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.bgLayer:getContentSize().width - 15, self.bgLayer:getContentSize().height - 270 - 10), nil)
    --self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition(ccp(20, 100))
    self.bgLayer:addChild(self.tv, 1)
    self.tv:setMaxDisToBottomOrTop(120)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function chatDialogTab3:eventHandler(handler, fn, idx, cel)
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
            if params.paramTab and ((params.paramTab.redid and params.paramTab.redid>0) or params.paramTab.functionStr) then

                local redbagTg = params.paramTab.redBagTb and params.paramTab.redBagTb.tag or nil
                local isTodayRedBag = false
                if params.paramTab.functionStr =="acXssd2019WithRedBag" and params.paramTab.redBagTb and params.paramTab.redBagTb.redbuyedTs then
                    isTodayRedBag = G_isToday(params.paramTab.redBagTb.redbuyedTs)
                end
                if params.paramTab.functionStr then
                    if params.paramTab.functionStr =="double11NewWithRedBag" and acDouble11NewVoApi then
                        -- print("idx--->",idx,redbagTg)
                        if redbagTg then
                            local ccPos = ccp(noticeLabel:getPositionX()+noticeLabel:getContentSize().width+30,height+hSpace-20)
                            if acDouble11NewVoApi:isHasTag(redbagTg) then
                                guangSp,fuzi =acDouble11NewVoApi:showActionTip( cell,redbagTg,ccPos)
                                table.insert(self.redBagTagAndIconTb,{redbagTg,guangSp,fuzi})

                            end
                        end
                    elseif params.paramTab.functionStr =="acXssd2019WithRedBag" and acXssd2019VoApi then
                        -- print("idx--->",idx,redbagTg)
                        if redbagTg then
                            local ccPos = ccp(noticeLabel:getPositionX()+noticeLabel:getContentSize().width+30,height+hSpace-20)
                            if acXssd2019VoApi:isHasTag(redbagTg) then
                                guangSp,fuzi =acXssd2019VoApi:showActionTip( cell,redbagTg,ccPos)
                                table.insert(self.redBagTagAndIconTb,{redbagTg,guangSp,fuzi})

                            end
                        end
                    end
                end
                
               local function cellClick2(hd,fn,idx)
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    end
                    if self.tv:getIsScrolled()==true then
                        do return end
                    end

                    base:setWait()
                    if self.cellBgTab and self.cellBgTab[idx] then
                        local function touchCallback()
                            if params.paramTab.redid and params.paramTab.redid>0 then
                                self:cellClick(idx,4)
                                base:cancleWait()
                            elseif params.paramTab.functionStr then
                                if params.paramTab.functionStr =="acXssd2019WithRedBag" and not isTodayRedBag then
                                    if acXssd2019VoApi and acXssd2019VoApi.outTimeShowTip then
                                        acXssd2019VoApi:outTimeShowTip()
                                    end
                                    base:cancleWait()
                                    do return end
                                end

                                local redBagTag = chatVo.params.paramTab.redBagTb and chatVo.params.paramTab.redBagTb.tag or nil
                                if params.paramTab.functionStr ~="double11NewWithRedBag" and params.paramTab.functionStr ~="acXssd2019WithRedBag" then
                                    self.chatDialog:close()
                                else
                                    if params.paramTab.functionStr =="acXssd2019WithRedBag" then
                                        acXssd2019VoApi:setNewGetRecordInCorp(params.paramTab.redBagTb)
                                    else
                                        acDouble11NewVoApi:setNewGetRecordInCorp(params.paramTab.redBagTb)
                                    end

                                    if redbagTg then
                                        -- print("in tab3 at up click redbagTg----->",redbagTg)
                                        if cell:getChildByTag(redbagTg) then
                                            tolua.cast(cell:getChildByTag(redbagTg),"CCSprite"):removeFromParentAndCleanup(true)
                                            tolua.cast(cell:getChildByTag(redbagTg+1000),"CCSprite"):removeFromParentAndCleanup(true)
                                            chatVo.params.paramTab.redBagTb.tag =nil
                                            for k,v in pairs(self.redBagTagAndIconTb) do
                                                if v[1] ==redbagTg then
                                                    v[1] =nil
                                                    v[2] =nil
                                                    v[3] =nil
                                                end
                                            end
                                        end
                                        chatVoApi:setChatVoKillRedBagTag(nil,1,redbagTg,3)
                                        if params.paramTab.functionStr =="acXssd2019WithRedBag" then
                                            acXssd2019VoApi:setRecBagTbTagNil(redbagTg,nil)
                                        else
                                            acDouble11NewVoApi:setRecBagTbTagNil(redbagTg,nil)
                                        end
                                        
                                        self.chatDialog:refreshEveryTabRedBagIcon(redbagTg,1)
                                        redbagTg =nil
                                    end
                                end
                                if params.paramTab.functionStr =="acXssd2019WithRedBag" then
                                    jump_judgment(params.paramTab.functionStr, redBagTag)
                                else
                                    jump_judgment(params.paramTab.functionStr)
                                end
                                base:cancleWait()
                            end
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
                local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfItemBg.png", capInSet, cellClick2)
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
            end
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
        -- messageLabel=GetTTFLabelWrap(content,26,CCSizeMake(width, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,msgFont)
        
        local lbHeight
        local lbColor
        local richAdd = 0
        if chatVo.contentType and chatVo.contentType == 2 then --战报
            lbColor = G_ColorYellow
        end
        if lbColor == nil then
            lbColor = color
        end
        local showMsg = ""
        if params.paramTab and params.paramTab.addStr then
            if params.paramTab.noRich and tostring(params.paramTab.noRich) == "1" then
                showMsg = content .. " " .. getlocal(params.paramTab.addStr)
                showMsg = string.gsub(showMsg, "<rayimg>", "")
                messageLabel = GetTTFLabelWrap(showMsg, 26, CCSizeMake(width, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, msgFont)
                messageLabel:setColor(lbColor)
                lbHeight = messageLabel:getContentSize().height
            else
                showMsg = content .. " " .. "<rayimg>" .. getlocal(params.paramTab.addStr) .. "<rayimg>"
                local colorTb = {}
                if params.paramTab.colorStr then
                    local colorArr = Split(params.paramTab.colorStr, ",")
                    for k, v in pairs(colorArr) do
                        if v == "w" then
                            table.insert(colorTb, lbColor)
                        elseif v == "y" then
                            table.insert(colorTb, G_ColorYellowPro)
                        elseif v == "b" then
                            table.insert(colorTb, G_ColorBlue)
                        end
                    end
                    table.insert(colorTb, G_ColorBlue)
                else
                    colorTb = {lbColor, G_ColorYellowPro}
                end
                messageLabel, lbHeight = G_getRichTextLabel(showMsg, colorTb, 26, width, kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
                if G_isShowRichLabel() then
                    richAdd = lbHeight / 2
                else
                    messageLabel:setColor(lbColor)
                end
            end
        else
            showMsg = string.gsub(content, "<rayimg>", "")
            messageLabel = GetTTFLabelWrap(showMsg, 26, CCSizeMake(width, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, msgFont)
            messageLabel:setColor(lbColor)
            lbHeight = messageLabel:getContentSize().height
        end
        
        msgX = msgX + typeWidth + wSpace
        if chatVo.contentType == 1 and base.ifChatTransOpen == 1 and chatVo.params.language ~= G_getCurChoseLanguage() then
            msgY = height + hSpace - 40
        else
            msgY = msgY + lbHeight + hSpace
        end
        
        messageLabel:setPosition(ccp(msgX, msgY))
        messageLabel:setAnchorPoint(ccp(0, 1))
        cell:addChild(messageLabel, 2)
        --local msgColor=msgData.color
        --messageLabel:setColor(msgColor)
        -- if chatVo.contentType and chatVo.contentType==2 then --战报
        -- messageLabel:setColor(G_ColorYellow)
        -- else
        -- messageLabel:setColor(color)
        -- end
        
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
function chatDialogTab3:eventHandlerNew(handler, fn, idx, cel)
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
        if chatVo.params and chatVo.params.emojiId then --动态表情
            height = 140 + 37
        end
        height = 136 / 2 - 40 + height + 13
        if height < 146 then
            height = 156
        end
        tmpSize = CCSizeMake(600, height + 5)
        if(base.ifChatTransOpen == 1 and chatVo.params.language ~= G_getCurChoseLanguage())then
            tmpSize = CCSizeMake(600, height + 70)
        end
        if chatVo.timeVisible then
            tmpSize.height = tmpSize.height + 40
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
        -- if type<=3 and chatVo.contentType~=3 then
        -- else
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
                
                --军团职位名称
                local allianceRoleStr, allianceRoleLb
                if chatVo.subType == 3 then --只有从军团里出来的聊天内容才显示军团职位
                    if params.allianceRole and tonumber(params.allianceRole) == 1 then
                        allianceRoleStr = getlocal("alliance_role1")
                    elseif params.allianceRole and tonumber(params.allianceRole) == 2 then
                        allianceRoleStr = getlocal("alliance_role2")
                    end
                    if allianceRoleStr then
                        allianceRoleLb = GetTTFLabel(allianceRoleStr, lbSize)
                        allianceRoleLb:setAnchorPoint(ccp(0, 0))
                        allianceRoleLb:setPosition(wSpace + spSize + 5, totalHeight - spSize / 2 + lbSpace)
                        allianceRoleLb:setColor(G_ColorGreen2)
                        cell:addChild(allianceRoleLb, 3)
                    end
                end
                
                local nameStr = chatVoApi:getNameStr(type, chatVo.subType, chatVo.senderName, chatVo.reciverName, chatVo.sender)
                local titleStr = params.title or ""
                if chatVo.subType and (chatVo.subType == 1 or chatVo.subType == 3) and params.title and params.title ~= "" and tonumber(params.title) ~= 0 then
                    titleStr = getlocal("player_title_name_" .. params.title)
                    titleStr = "【" .. titleStr .. "】"
                else
                    titleStr = ""
                end
                
                local _posX, _posY = 0, 0
                -- local titleLb=GetTTFLabel(titleStr,lbSize)
                senderLabel = GetTTFLabel(nameStr, lbSize)
                -- if isUserSelf then
                -- senderLabel:setAnchorPoint(ccp(1,0))
                -- senderLabel:setPosition(ccp(600-wSpace-spSize-5,totalHeight-spSize/2-15+20+lbSpace))
                -- titleLb:setAnchorPoint(ccp(1,0))
                -- titleLb:setPosition(ccp(600-wSpace-spSize-senderLabel:getContentSize().width,totalHeight-spSize/2-15+20+lbSpace))
                -- else
                senderLabel:setAnchorPoint(ccp(0, 0))
                if allianceRoleLb then
                    senderLabel:setPosition(ccp(allianceRoleLb:getPositionX() + allianceRoleLb:getContentSize().width + 3, totalHeight - spSize / 2 + lbSpace))
                else
                    senderLabel:setPosition(ccp(wSpace + spSize + 5, totalHeight - spSize / 2 + lbSpace))
                end
                -- titleLb:setAnchorPoint(ccp(0,0))
                -- local titleLbSpace = 0
                -- if titleLb:getContentSize().width>0 then
                -- titleLbSpace=10
                -- end
                -- titleLb:setPosition(ccp(senderLabel:getPositionX()+senderLabel:getContentSize().width-titleLbSpace,totalHeight-spSize/2-15+20+lbSpace))
                -- _posX=titleLb:getPositionX()+titleLb:getContentSize().width-titleLbSpace
                _posX = senderLabel:getPositionX() + senderLabel:getContentSize().width
                -- end
                _posY = senderLabel:getPositionY() + senderLabel:getContentSize().height / 2
                -- titleLb:setColor(G_ColorGreen)
                -- cell:addChild(titleLb,3)
                cell:addChild(senderLabel, 3)
                senderLabel:setColor(color)
                
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
                        --             typeSp:addChild(rankSp)
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
                            -- local senderH=senderLabel:getContentSize().height/2
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
                
                --vip
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
                    -- local titleLbSpace = 0
                    -- if titleLb:getContentSize().width>0 then
                    -- titleLbSpace=10
                    -- end
                    -- titleLb:setPositionX(_posX-titleLbSpace)
                    -- _posX=titleLb:getPositionX()+titleLb:getContentSize().width-titleLbSpace
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
            noticeLabel:setPosition(ccp(wSpace + spSize, totalHeight - spSize / 2))
            if params.paramTab and ((params.paramTab.redid and params.paramTab.redid>0) or params.paramTab.functionStr) then

                local redbagTg = (params.paramTab.redBagTb and params.paramTab.redBagTb.tag) and params.paramTab.redBagTb.tag or nil

                local isTodayRedBag = false
                if params.paramTab.functionStr =="acXssd2019WithRedBag" and params.paramTab.redBagTb and params.paramTab.redBagTb.redbuyedTs then
                    isTodayRedBag = G_isToday(params.paramTab.redBagTb.redbuyedTs)
                end

                if params.paramTab.functionStr then
                    if params.paramTab.functionStr =="double11NewWithRedBag" and acDouble11NewVoApi then
                        -- print("idx--->",idx,redbagTg)
                        if redbagTg then
                            local ccPos = ccp(noticeLabel:getPositionX()+noticeLabel:getContentSize().width+30,height+hSpace-25)
                            if acDouble11NewVoApi:isHasTag(redbagTg) then
                                guangSp,fuzi =acDouble11NewVoApi:showActionTip( cell,redbagTg,ccPos)
                                table.insert(self.redBagTagAndIconTb,{redbagTg,guangSp,fuzi})
                            end
                        end
                    end
                    if params.paramTab.functionStr =="acXssd2019WithRedBag" and acXssd2019VoApi then
                        -- print("idx--->",idx,redbagTg)
                        if redbagTg then
                            local ccPos = ccp(noticeLabel:getPositionX()+noticeLabel:getContentSize().width+30,height+hSpace-25)
                            if acXssd2019VoApi:isHasTag(redbagTg) then
                                print("redbagTb==2=====>>>>",redbagTg)
                                guangSp,fuzi =acXssd2019VoApi:showActionTip( cell,redbagTg,ccPos)
                                table.insert(self.redBagTagAndIconTb,{redbagTg,guangSp,fuzi})
                            end
                        end
                    end
                end

                local function cellClick2(hd,fn,idx)
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    end
                    if self.tv:getIsScrolled()==true then
                        do return end
                    end

                    base:setWait()
                    if self.cellBgTab and self.cellBgTab[idx] then
                        local function touchCallback()
                            if params.paramTab.redid and params.paramTab.redid>0 then
                                self:cellClick(idx,4)
                                base:cancleWait()
                            elseif params.paramTab.functionStr then
                                if params.paramTab.functionStr =="acXssd2019WithRedBag" and not isTodayRedBag then
                                    if acXssd2019VoApi and acXssd2019VoApi.outTimeShowTip then
                                        acXssd2019VoApi:outTimeShowTip()
                                    end
                                    base:cancleWait()
                                    do return end
                                end
                                
                                local redBagTag = chatVo.params.paramTab.redBagTb and chatVo.params.paramTab.redBagTb.tag or nil
                                if params.paramTab.functionStr ~="double11NewWithRedBag" and params.paramTab.functionStr ~="acXssd2019WithRedBag" then
                                    self.chatDialog:close()
                                else
                                    if params.paramTab.functionStr =="acXssd2019WithRedBag" then
                                        acXssd2019VoApi:setNewGetRecordInCorp(params.paramTab.redBagTb)
                                    else
                                        acDouble11NewVoApi:setNewGetRecordInCorp(params.paramTab.redBagTb)
                                    end

                                    if redbagTg then
                                        -- print("in tab3 at down click redbagTg----->",redbagTg)
                                        if cell:getChildByTag(redbagTg) then
                                            tolua.cast(cell:getChildByTag(redbagTg),"CCSprite"):removeFromParentAndCleanup(true)
                                            tolua.cast(cell:getChildByTag(redbagTg+1000),"CCSprite"):removeFromParentAndCleanup(true)
                                            chatVo.params.paramTab.redBagTb.tag =nil
                                            for k,v in pairs(self.redBagTagAndIconTb) do
                                                if v[1] ==redbagTg then
                                                    v[1] =nil
                                                    v[2] =nil
                                                    v[3] =nil
                                                end
                                            end
                                        end
                                        chatVoApi:setChatVoKillRedBagTag(nil,1,redbagTg,3)
                                        if params.paramTab.functionStr ~="acXssd2019WithRedBag" then
                                            acDouble11NewVoApi:setRecBagTbTagNil(redbagTg,nil)
                                        else
                                            acXssd2019VoApi:setRecBagTbTagNil(redbagTg,nil)
                                        end
                                        
                                        self.chatDialog:refreshEveryTabRedBagIcon(redbagTg,1)
                                        redbagTg =nil
                                    end
                                end
                                if params.paramTab.functionStr =="acXssd2019WithRedBag" then
                                    jump_judgment(params.paramTab.functionStr, redBagTag)
                                else
                                    jump_judgment(params.paramTab.functionStr)
                                end
                                base:cancleWait()
                            end
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
                local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfItemBg.png", capInSet, cellClick2)
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
            end
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
        -- messageLabel=GetTTFLabelWrap(content,26,CCSizeMake(width, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,msgFont)
        local lbHeight
        local lbColor
        local richAdd = 0
        if chatVo.contentType and chatVo.contentType == 2 then --战报
            lbColor = G_ColorYellow
        end
        if lbColor == nil then
            lbColor = color
        end
        local showMsg = ""
        if params.paramTab and params.paramTab.addStr then
            if params.paramTab.noRich and tostring(params.paramTab.noRich) == "1" then
                showMsg = content .. " " .. getlocal(params.paramTab.addStr)
                showMsg = string.gsub(showMsg, "<rayimg>", "")
                messageLabel = GetTTFLabelWrap(showMsg, 26, CCSizeMake(width, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, msgFont)
                messageLabel:setColor(lbColor)
                lbHeight = messageLabel:getContentSize().height
            else
                showMsg = content .. " " .. "<rayimg>" .. getlocal(params.paramTab.addStr) .. "<rayimg>"
                local colorTb = {}
                if params.paramTab.colorStr then
                    local colorArr = Split(params.paramTab.colorStr, ",")
                    for k, v in pairs(colorArr) do
                        if v == "w" then
                            table.insert(colorTb, lbColor)
                        elseif v == "y" then
                            table.insert(colorTb, G_ColorYellowPro)
                        elseif v == "b" then
                            table.insert(colorTb, G_ColorBlue)
                        elseif v == "g" then
                            table.insert(colorTb, G_ColorGreen2)
                        end
                    end
                    table.insert(colorTb, G_ColorBlue)
                else
                    colorTb = {lbColor, G_ColorYellowPro}
                end
                messageLabel, lbHeight = G_getRichTextLabel(showMsg, colorTb, 26, width, kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
                if G_isShowRichLabel() then
                    richAdd = lbHeight / 2
                else
                    messageLabel:setColor(lbColor)
                end
            end
        else
            showMsg = string.gsub(content, "<rayimg>", "")
            messageLabel = GetTTFLabelWrap(showMsg, 26, CCSizeMake(width, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, msgFont)
            messageLabel:setColor(lbColor)
            lbHeight = messageLabel:getContentSize().height
        end
        
        msgX = msgX + typeWidth + wSpace
        if chatVo.contentType == 1 and base.ifChatTransOpen == 1 and chatVo.params.language ~= G_getCurChoseLanguage() then
            msgY = height + hSpace - 40
        else
            msgY = msgY + lbHeight + hSpace
        end
        
        messageLabel:setPosition(ccp(msgX, msgY))
        messageLabel:setAnchorPoint(ccp(0, 0.5))
        -- cell:addChild(messageLabel,2)
        showMsg = string.gsub(showMsg, "<rayimg>", "")
        local widLb = GetTTFLabel(content, 26)
        if widLb:getContentSize().width <= width then
            local msgBgW = widLb:getContentSize().width + 25
            if widLb:getContentSize().width < 50 then
                msgBgW = 90
            end
            msgBg:setContentSize(CCSizeMake(msgBgW, widLb:getContentSize().height + 20))
        else
            msgBg:setContentSize(CCSizeMake(width + 35, lbHeight + 20))
            -- msgBg:setContentSize(CCSizeMake(messageLabel:getContentSize().width+25,messageLabel:getContentSize().height+20))
        end
        if isUserSelf then
            messageLabel:setPosition(ccp(5, msgBg:getContentSize().height / 2 + richAdd))
        else
            messageLabel:setPosition(ccp(20, msgBg:getContentSize().height / 2 + richAdd))
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
        
        -- if chatVo.contentType and chatVo.contentType==2 then --战报
        -- messageLabel:setColor(G_ColorYellow)
        -- else
        -- messageLabel:setColor(color)
        -- end
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
function chatDialogTab3:cellClick(idx, type)
    PlayEffect(audioCfg.mouseClick)
    local chatVo = chatVoApi:getChatVoByIndex(idx, self.selectedTabIndex + 1)
    if chatVo and chatVo.type <= 3 then
        if base.chatReportSwitch == 1 and chatVo and chatVo.contentType == 2 and (type == 2 or type == 3 or type == 5 or type == 6 or type == 8 or type == 9 or type == 10 or type == 11 or type == 12 or type == 16 or type == 17) then
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
                                local data = G_Json.decode(retData.data.report.content) --http请求拉回来的数据
                                if type ~= 16 then --战报的处理 type==16是分享的处理
                                    chatVoApi:setChatReport(idx, self.selectedTabIndex + 1, nil, data)
                                end
                                chatVo.params.report = data
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
            local rpoint = nil
            if params.bnum and params.bnum > 0 and params.rpoint then
                rpoint = params.rpoint
            end
            local isGM = GM_UidCfg[chatVo.sender] and true or false
            if chatVo.sender == playerVoApi:getUid() then
                smallDialog:showPlayerInfoSmallDialog("newSmallPanelBg.png", CCSizeMake(550, 450), CCRect(0, 0, 400, 400), CCRect(170, 80, 22, 10), getlocal("player_message_info_email"), emailCallBack, getlocal("player_message_info_whisper"), whisperCallBack, getlocal("player_message_info_title"), content, nil, self.layerNum + 1, 1, nil, resetBoxCallBack, nil, pic, nil, nil, nil, nil, rank, serverWarRank, startTime, params.title, nil, vipPicStr, isGM, rpoint, hfid, chatVo.sender)
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
        elseif type == 16 then --分享数据处理
            local params = chatVo.params
            if params.report then
                local player = {name = params.name}
                G_goToShareDialog(player, params.report, self.layerNum + 1)
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
        end
    end
end

function chatDialogTab3:tick()
    if chatVoApi:getHasNewData(self.selectedTabIndex + 1) == true then
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

function chatDialogTab3:resetTvPos()
    local recordPoint = self.tv:getRecordPoint()
    if recordPoint.y < 0 then
        recordPoint.y = 0
        self.tv:recoverToRecordPoint(recordPoint)
    end
end

--用户处理特殊需求,没有可以不写此方法
function chatDialogTab3:doUserHandler()
    
end

function chatDialogTab3:reloadChatDialog3WhenChatLogin()
    if self and self.tv then
        self.tv:reloadData()
    end
end

function chatDialogTab3:dispose()
    self.redBagTagAndIconTb = nil
    self.tv = nil
    self.bgLayer = nil
    self.tableCell1 = nil
    self.layerNum = nil
    self.selectedTabIndex = nil
    --self.chatDialog=nil
    self.cellBgTab = nil
    self = nil
end
