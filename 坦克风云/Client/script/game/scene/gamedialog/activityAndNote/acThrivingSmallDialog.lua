acThrivingSmallDialog=smallDialog:new()

function acThrivingSmallDialog:new(layerNum,getTb)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.layerNum=layerNum
    nc.awardTb = getTb
    nc.wholeBgSp=nil
    nc.dialogWidth=nil
    nc.dialogHeight=nil
    nc.isTouch=nil
    nc.bgLayer=nil
    nc.bgSize=nil
    nc.dialogLayer=nil
    nc.newPicTb=nil
    return nc
end

function acThrivingSmallDialog:init()
    base:addNeedRefresh(self)
    self.dialogWidth=550
    self.dialogHeight=450

    self.isTouch=nil
    local addW = 110
    local addH = 130
    local function nilFunc()
        if self.awardTb then
            if self.awardTb[1] == "airShipPartsTotal" then
                self:close()
            end
        end
    end
    local function closeCall( )
        if self.awardTb[1] == "xlpdShop" then
            if self.awardTb[3] and self.awardTb[3].refresh then
                self.awardTb[3]:refresh("gBox")
            end
        end
        return self:close()
    end

    local titleStr   = self.awardTb and self.awardTb[2] or getlocal("fullGoalAward")
    local titleColor = nil
    local dialogBg   = nil
    local useClose   = true
    if self.awardTb then
        if self.awardTb[1] == "airShipPartsTotal" then
            useClose = false
            self.dialogWidth = 400
            self.dialogHeight = 250
            self.newPicTb = {"airShipPartsTotal","rewardPanelBg1.png",nil,CCRect(30, 30, 1, 1),ccp(0.5,0.5)}
        elseif self.awardTb[1] == "airShipLastDayRank" then
            self.dialogWidth = 600
            self.dialogHeight = 880
        elseif self.awardTb[1] == "championshipWarQuickBattle" then
            useClose = false
            self.dialogWidth = 550
            self.dialogHeight = 550
        elseif self.awardTb[1] == "veri" then--验证
            self.dialogHeight = 400
            self.dialogWidth = 500
            useClose = false
        elseif self.awardTb[1] == "exerwarAution" then--跨服联合演习 竞拍
            self.dialogHeight = 240
            local bgWidth = self.dialogWidth - 40
            local tipTb = self.awardTb[4]
            for k,v in pairs(tipTb) do
                local upTipLb = GetTTFLabelWrap(tipTb[k],G_isAsia() and 24 or 19,CCSizeMake(bgWidth - 30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                self.dialogHeight = self.dialogHeight+upTipLb:getContentSize().height + 5
            end
            self.dialogHeight = self.dialogHeight + 40
        elseif self.awardTb[1] == "tqbj" then
            self.dialogHeight = self.awardTb[5] > 2 and 550 or 450
            titleColor = self.awardTb[6]
        elseif self.awardTb[1] == "kljz" then
            if self.awardTb[5] then
                useClose = false
            else
                self.dialogHeight=350
            end
        elseif self.awardTb[1] =="qmcj" then
            self.dialogHeight=350
        elseif self.awardTb[1] =="qmsd" then
            self.dialogHeight = self.awardTb[5] > 4 and 450 or 350
        elseif self.awardTb[1] =="mjzx" or self.awardTb[1] =="yrj" or self.awardTb[1]== "smbd" or self.awardTb[1] == "xstz" then
            self.dialogHeight = self.awardTb[5] > 4 and 450 or 350
            if self.awardTb[5] > 8 then
                self.dialogHeight = 550
            end
        elseif self.awardTb[1] =="xlys"  then
            self.dialogHeight = self.awardTb[5] > 4 and 450 or 350
        elseif  self.awardTb[1] =="xcjh" then
            if self.awardTb[5] > 8 then
                self.dialogHeight = 630
            elseif self.awardTb[5] > 4 then
                self.dialogHeight = 530
            else
                self.dialogHeight = 430
            end
        elseif self.awardTb[1] == "dlbz" then
            self.dialogHeight = 450
            self.dialogWidth = 570
            useClose = false
            self.newPicTb = {"dlbz","rewardPanelBg1.png","newTitleBg2.png",CCRect(30, 30, 1, 1),ccp(0.5,0.5)}
        elseif self.awardTb[1] == "dlbzSee" then
            self.dialogHeight = 600
        elseif self.awardTb[1] =="smcjTask" or self.awardTb[1] =="smcjDailyTask" or self.awardTb[1] =="smcjRechr" or self.awardTb[1] =="xlpdBoxAward" then
            self.dialogHeight = 520
        elseif self.awardTb[1] == "nsAddUpAward" then
            self.dialogHeight = 520
        elseif self.awardTb[1] == "nsCheckIn" then
            self.dialogHeight = 520
        elseif self.awardTb[1] == "hryx" then
            --acHryxImage_tabSub1.png--458,447
            useClose = false
            self.dialogHeight =560
            self.dialogWidth  =560
            self.newPicTb = {"hryx","rewardPanelBg1.png","newTitleBg2.png",CCRect(30, 30, 1, 1),ccp(0.5,0.5)}
        elseif self.awardTb[1] == "hljbEx" then
            useClose = false
            self.dialogHeight=400
            self.newPicTb = {"hljbEx","rewardPanelBg1.png","newTitleBg2.png",CCRect(30, 30, 1, 1),ccp(0.5,0.5)}
        elseif self.awardTb[1] == "hljbKeep" then
            useClose = false
            self.dialogHeight = 350
            self.newPicTb = {"hljbKeep","rewardPanelBg1.png","newTitleBg2.png",CCRect(30, 30, 1, 1),ccp(0.5,0.5)}
        elseif self.awardTb[1] == "hljbTake" then
            self.dialogHeight = 550
        elseif self.awardTb[1] == "allianceInfoNow" then
            self.dialogWidth = 550
            self.dialogHeight = 600
        elseif self.awardTb[1] == "zncf" then
            self.dialogWidth = 500
            self.dialogHeight = 350
        elseif self.awardTb[1] == "xlpdShop" then
            self.dialogWidth = 570
            self.dialogHeight = 750
        elseif self.awardTb[1] == "xlpdLog" or self.awardTb[1] == "xlpdMyTeam" or self.awardTb[1] == "xlpdInvite" then
            self.dialogWidth = 570
            self.dialogHeight = 750
        end
    end
    dialogBg = G_getNewDialogBg(CCSizeMake(self.dialogWidth,self.dialogHeight),titleStr,30,nil,self.layerNum+1,useClose,closeCall,titleColor,self.newPicTb)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self:show()
    self.dialogLayer:addChild(self.bgLayer,1)
    self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true)
    
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
    touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(250)
    touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg)

    if useClose then
        local notToucDialog = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
        notToucDialog:setTouchPriority(-(self.layerNum-1)*20-999)
        notToucDialog:setAnchorPoint(ccp(0,1))
        notToucDialog:setContentSize(CCSizeMake(self.dialogWidth,self.dialogHeight))
        notToucDialog:setOpacity(0)
        notToucDialog:setPosition(ccp(0,0))
        self.bgLayer:addChild(notToucDialog)
    end

    if self.awardTb then
        if self.awardTb[1] == "airShipPartsTotal" then
            self:aboutAirShipPartsTotalCall()
        elseif self.awardTb[1] == "airShipLastDayRank" then
            self:aboutAirShipLastDayRank()
        elseif self.awardTb[1] == "championshipWarQuickBattle" then
            self:aboutChampionshipWarQuickBattle()
        elseif self.awardTb[1] == "veri" then--验证
            self:aboutVeriCall()
        elseif self.awardTb[1] == "exerwarAution" then
            self:aboutExerwarAutionCall()
        elseif self.awardTb[1] == "tqbj" then
            self:aboutTqbjCall()
        elseif self.awardTb[1] == "kljz" then
            self:aboutKljzCall()
        elseif self.awardTb[1] =="qmcj" then
            self:aboutQmcjCall()
        elseif self.awardTb[1] =="qmsd" then
            self:aboutQmsdCall()
        elseif self.awardTb[1] =="mjzx" or self.awardTb[1] =="yrj" or self.awardTb[1]== "smbd" or self.awardTb[1] == "xstz" or self.awardTb[1] == "xcjh" then
            self:aboutMjzxCall()
        elseif self.awardTb[1] =="xlys" then
            self:aboutXlysCall()
        elseif self.awardTb[1] =="dlbz" then
            self:aboutDlbzCall()
        elseif self.awardTb[1] =="dlbzSee" then
            self:aboutDlbzSeeCall()
        elseif self.awardTb[1] =="smcjTask" then
            self:aboutSmcjTask()
        elseif self.awardTb[1] =="smcjDailyTask" then
            self:aboutSmcjDailyTask()
        elseif self.awardTb[1] =="smcjRechr" then
            self:aboutSmcjRecharge()
        elseif self.awardTb[1] == "nsAddUpAward" then
            self:aboutNewSignAddUpAwardCall()
        elseif self.awardTb[1] == "nsCheckIn" then
            self:aboutNewSignCheckInCall()
        elseif self.awardTb[1] == "hljbEx" then
            self:aboutHljbExchangeCall()
        elseif self.awardTb[1] == "hljbKeep" then
            self:aboutHljbKeepCall()
        elseif self.awardTb[1] == "hljbTake" then
            self:aboutHljbTakeCall()
        elseif self.awardTb[1] == "allianceInfoNow" then
            self:aboutAllianceInfoNow()
        elseif self.awardTb[1] == "hryx" then
            self:aboutHryxBuildingShow()
        elseif self.awardTb[1] == "zncf" then
            self:aboutReadyShareSelfData()
        elseif self.awardTb[1] == "xlpdShop" then
            self:aboutXlpdShopShow()
        elseif self.awardTb[1] == "xlpdBoxAward" then
            self:aboutXlpdBoxAwardShow()
        elseif self.awardTb[1] == "xlpdLog" then
            self:aboutXlpdLogShow()
        elseif self.awardTb[1] == "xlpdMyTeam" then
            self:aboutXlpdMyTeamShow()
        elseif self.awardTb[1] == "xlpdInvite" then
            self:aboutXlpdInviteShow()
        end
    else
        self:addBoxAndAni()
    end

    sceneGame:addChild(self.dialogLayer,self.layerNum)
    self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    return self.dialogLayer
end

function acThrivingSmallDialog:aboutXlpdBoxAwardShow( )
    local tvWidth,tvHeight = self.dialogWidth - 40 , self.dialogHeight - 210
    local awardType = self.awardTb[4]

    local btnLb = getlocal("confirm")
    local isCan = false
    if awardType == 1 then
        btnLb = getlocal("daily_scene_get")
        isCan = true
    end
    if awardType == 2 then
        btnLb = getlocal("activity_hadReward")
        local hadRewardLb = GetTTFLabel(btnLb,25,true)
        hadRewardLb:setAnchorPoint(ccp(0.5,0))
        hadRewardLb:setPosition(ccp(self.dialogWidth * 0.5, 40))
        -- hadRewardLb:setColor(G_ColorRed)
        self.bgLayer:addChild(hadRewardLb)
    else
        local function closeCall()
            if isCan then
                --用于领取宝箱奖励时候使用，加在自身背包中
                local function socketCallBack( )
                    for k,v in pairs(self.awardTb[5]) do
                        -- print("v.name , v.num ====>>>",v.name,v.num)
                        G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                    end    
                    G_showRewardTip(self.awardTb[5],true)
                    if  self.awardTb[8] then
                        self.awardTb[8]()
                    end
                    self:close()
                end 
                acXlpdVoApi:socketgBoxAward(socketCallBack,self.awardTb[7],"task")
            else
                self:close()
            end
        end
        local sureItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",closeCall,nil,btnLb,34)
        sureItem:setAnchorPoint(ccp(0.5,1))
        sureItem:setScale(0.8)
        local sureBtn=CCMenu:createWithItem(sureItem)
        sureBtn:setTouchPriority(-(self.layerNum-1)*20-3)
        sureBtn:setPosition(self.dialogWidth * 0.5,80)
        self.bgLayer:addChild(sureBtn)

        local getTipLb = GetTTFLabelWrap(self.awardTb[3],22,CCSizeMake(350,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
        getTipLb:setColor(acXlpdVoApi:getTeamNum() >= self.awardTb[6] and G_ColorGreen or G_ColorRed)
        getTipLb:setPosition(self.dialogWidth * 0.5, 105)
        self.bgLayer:addChild(getTipLb,1111)
    end

    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
    tvBg:setAnchorPoint(ccp(0.5,0))
    tvBg:setContentSize(CCSizeMake(tvWidth,tvHeight))
    tvBg:setPosition(ccp(self.dialogWidth*0.5,130))
    self.bgLayer:addChild(tvBg) 
    local cellHeight = 100
    local strSize2 = G_isAsia() and 20 or 18

    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return SizeOfTable(self.awardTb[5])
        elseif fn=="tableCellSizeForIndex" then
            return  CCSizeMake(tvWidth, cellHeight)
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            
            local awardTb = self.awardTb[5][idx + 1]
            local icon,scale = G_getItemIcon(awardTb,80,false,self.layerNum)
            cell:addChild(icon)
            icon:setAnchorPoint(ccp(0,1))
            icon:setPosition(10,cellHeight - 10)

            local numLb = GetTTFLabel("x" .. FormatNumber(awardTb.num),20)
            numLb:setAnchorPoint(ccp(1,0))
            icon:addChild(numLb,4)
            numLb:setPosition(icon:getContentSize().width-5, 5)
            numLb:setScale(1/scale)

            local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
            numBg:setAnchorPoint(ccp(1,0))
            numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-5))
            numBg:setPosition(ccp(icon:getContentSize().width-5,5))
            numBg:setOpacity(150)
            icon:addChild(numBg,3)

            local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,0,1,32),function () end)
            nameBg:setContentSize(CCSizeMake(350,28))
            nameBg:setAnchorPoint(ccp(0,1))
            nameBg:setPosition(100,cellHeight - 10)
            cell:addChild(nameBg)

            local titleLb = GetTTFLabel(awardTb.name,strSize2,true)
            titleLb:setAnchorPoint(ccp(0,0.5))
            titleLb:setColor(G_ColorYellowPro2)
            titleLb:setPosition(15,nameBg:getContentSize().height * 0.5)
            nameBg:addChild(titleLb)

            local descStr2 = G_formatStr(awardTb)
            local descLb = GetTTFLabelWrap(descStr2,strSize2 - 3,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            descLb:setAnchorPoint(ccp(0,1))
            descLb:setPosition(100,cellHeight - 45)
            cell:addChild(descLb)

            local bottomLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)--modifiersLine2
            bottomLine:setContentSize(CCSizeMake(tvWidth - 10,bottomLine:getContentSize().height))
            bottomLine:setRotation(180)
            bottomLine:setPosition(ccp(tvWidth * 0.5, 0))
            cell:addChild(bottomLine,1)

            return cell
        end
    end
    local hd=LuaEventHandler:createHandler(tvCallBack)
    local tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth, tvHeight - 4),nil)
    tableView:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    tableView:setPosition(ccp(20,132))
    self.bgLayer:addChild(tableView,2)
    tableView:setMaxDisToBottomOrTop(100)
    self.tv = tableView
end

function acThrivingSmallDialog:aboutXlpdInviteShow( )--协力攀登 好友邀请面板
    self.xlpdJoinChooseIdx = 1
    self.xlpdTvCellNum    = SizeOfTable(self.awardTb[4])--好友数目
    self.teamInfo = self.awardTb[5]
    local bgWidth,bgHeight = self.dialogWidth , self.dialogHeight - 65
    local tabPosy    = bgHeight - 80
    local cellHeight =  self.xlpdTvCellNum == 0 and bgHeight - 110 or 100
    local cellWidth  = bgWidth - 50
    
    local function tabHandle(tIdx)
        if tIdx == self.xlpdJoinChooseIdx then
            do return end
        end
        self.xlpdJoinChooseIdx = tIdx

        ---- 拿到数据
        self.xlpdTvCellNum = 0 -- 切换数据 需要刷新
        if tIdx == 1 then
            self.xlpdTvCellNum = SizeOfTable(self.awardTb[4])
        else
             self.xlpdTvCellNum = 1 -- 发布邀请
        end
        if self.xlpdTvCellNum == 0 or tIdx == 2 then
            cellHeight = bgHeight - 110
        elseif tIdx == 1 then
            cellHeight = 100
        end
        if self.tv then
            self.tv:setMaxDisToBottomOrTop(tIdx == 1 and 120 or 0)
            self.tv:reloadData()
        end
    end 
     
    local tabTb = {
        {tabText = getlocal("friend_title")},
        {tabText = getlocal("postInvitation")},
    }
    local function tabClick(idx)
        tabHandle(idx)
    end
    local multiTab = G_createMultiTabbed(tabTb, tabClick, "page_dark.png", "page_light.png", nil, nil, 10)
    multiTab:setTabTouchPriority(-(self.layerNum - 1) * 20 - 4)
    multiTab:setTabPosition(32, tabPosy)
    multiTab:setParent(self.bgLayer, 2)
    self.multiTab = multiTab
    
    self.multiTab:tabClick(1)

    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png", CCRect(20, 20, 1, 1),function() end)
    tvBg:setContentSize(CCSizeMake(bgWidth - 50, bgHeight - 100))
    tvBg:setAnchorPoint(ccp(0.5,0))
    tvBg:setPosition(bgWidth *0.5, 20)
    self.bgLayer:addChild(tvBg)

    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return self.xlpdTvCellNum == 0  and 1 or self.xlpdTvCellNum
        elseif fn=="tableCellSizeForIndex" then
            return CCSizeMake(cellWidth, cellHeight)
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            if self.xlpdJoinChooseIdx == 1 then
                if self.xlpdTvCellNum > 0 then
                    local frData = self.awardTb[4][idx + 1]
                    local isInMyTeam = false
                    for k,v in pairs(self.teamInfo) do
                        if tostring(v[1]) == tostring(frData[1]) and v[2] == frData[2] then
                            isInMyTeam = true
                        end
                    end
                    local pic = playerVoApi:getPersonPhotoName(frData[3] or headCfg.default)
                    playerIconSp = playerVoApi:GetPlayerBgIcon(pic, function () end, nil, 70,80)
                    playerIconSp:setPosition(70,cellHeight * 0.5)
                    cell:addChild(playerIconSp)

                    local nameLb = GetTTFLabel(frData[2],21,true)
                    nameLb:setAnchorPoint(ccp(0,0.5))
                    nameLb:setColor(G_ColorGreen)
                    nameLb:setPosition(120,cellHeight * 0.5 + 20)
                    cell:addChild(nameLb)

                    local pdLevelLb = GetTTFLabel(getlocal("activity_xlpd_level")..": Lv."..frData[4],21,true)
                    pdLevelLb:setAnchorPoint(ccp(0,0.5))
                    pdLevelLb:setPosition(120,cellHeight * 0.5 - 20)
                    cell:addChild(pdLevelLb)

                    local isBeInvited = frData[5] == 1 and true or false
                    local btnPos = ccp(cellWidth - 80 ,cellHeight * 0.5)
                    if isInMyTeam then --isBeInvited or isInMyTeam then
                        local str = isInMyTeam and getlocal("inTeamNow") or getlocal("inviteEndStr")
                        local inviteEndLb = GetTTFLabel(str,G_isAsia() and 22 or 19,true)
                        inviteEndLb:setPosition(btnPos)
                        cell:addChild(inviteEndLb)
                    else
                        local function invitedHandle( )
                            local canInviteType = acXlpdVoApi:isCanBeInviteType(frData[5])
                            if canInviteType ~= true then
                                G_showTipsDialog(canInviteType)
                                do return end
                            end
                            if not acXlpdVoApi:isCanJoinTeam() then
                                G_showTipsDialog(getlocal("notBeInvitedStr2"))
                                do return end
                            end

                            local function invitedOverHandle()
                                G_showTipsDialog(getlocal("postInvitationOver1"))
                                if self.tv then
                                    self.awardTb[4] = acXlpdVoApi:formatFriendList()
                                    self.tv:reloadData()
                                end
                            end
                            acXlpdVoApi:socketInviteFriend(invitedOverHandle,frData[1],frData)
                        end
                        local btnScale,priority = 0.7,-(self.layerNum-1)*20-4
                        local invitedBtn,invitedMenu = G_createBotton(cell,btnPos,{getlocal("inviteStr")},"newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png",invitedHandle,btnScale,priority,nil,idx + 1)
                    end

                    local bottomLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)--modifiersLine2
                    bottomLine:setContentSize(CCSizeMake(cellWidth - 10,bottomLine:getContentSize().height + 1))
                    bottomLine:setRotation(180)
                    bottomLine:setPosition(ccp(cellWidth * 0.5, 2))
                    cell:addChild(bottomLine,1)
                 else---无数据
                    local notDataLabel = GetTTFLabel(getlocal("noFriends"), 25)
                    notDataLabel:setColor(G_ColorGray)
                    notDataLabel:setPosition(cellWidth * 0.5, cellHeight * 0.5)
                    cell:addChild(notDataLabel)
                end
            else---发布邀请
                local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("newListItemBg.png", CCRect(4, 4, 1, 1), function () end)
                backSprie:setContentSize(CCSizeMake(400,cellHeight))
                backSprie:setPosition(ccp(cellWidth * 0.5,cellHeight * 0.5))
                backSprie:setOpacity(0)
                cell:addChild(backSprie)

                local posy1,posy2,poy3 = cellHeight - 100, cellHeight - 155,0
                -----第一行
                local pdLevelLimitLb1 = GetTTFLabel(getlocal("activity_xlpd_pdLevelLimitStr1"),G_isAsia() and 24 or 20,true)
                pdLevelLimitLb1:setAnchorPoint(ccp(0,0.5))
                pdLevelLimitLb1:setPosition(0,posy1)
                backSprie:addChild(pdLevelLimitLb1)
                local pdLb1Width = pdLevelLimitLb1:getContentSize().width
                middleWidth = 160
                if pdLb1Width > 150 then
                    pdLevelLimitLb1:setScale(150 / pdLb1Width)
                    pdLb1Width = 150
                end

                local numPos = ccp(pdLb1Width + 80,posy1)

                local pdNeedLevelNumLb=GetTTFLabel(" ",30)
                pdNeedLevelNumLb:setPosition(numPos)
                pdNeedLevelNumLb:setColor(G_ColorYellowPro2)
                backSprie:addChild(pdNeedLevelNumLb,10)
                pdNeedLevelNumLb:setString(tostring(acXlpdVoApi:getEditPdLevelNum()))

                local xBox=LuaCCScale9Sprite:createWithSpriteFrameName("inputBg1912.png",CCRect(10,10,5,5),function () end)
                local function inPutCallBack(newNum)
                    acXlpdVoApi:setEditPdLevelNum(newNum)
                end
                local editXBox =  G_editBoxWithNumberShow(backSprie, 5, numPos, xBox, CCSizeMake(100,42), 1, 50, acXlpdVoApi:getEditPdLevelNum(), pdNeedLevelNumLb, inPutCallBack)
                local function tthandler2()
                    PlayEffect(audioCfg.mouseClick)
                    if editXBox then
                        editXBox:setVisible(true)
                    end
                end
                local xBoxBg=LuaCCScale9Sprite:createWithSpriteFrameName("inputBg1912.png",CCRect(10,10,5,5),tthandler2)
                xBoxBg:setPosition(numPos)
                xBoxBg:setContentSize(CCSizeMake(100,42))
                xBoxBg:setTouchPriority(-(self.layerNum-1)*20-4)
                -- xBoxBg:setOpacity(0)
                backSprie:addChild(xBoxBg)

                 local pdLevelLimitLb2 = GetTTFLabel(getlocal("activity_xlpd_pdLevelLimitStr2"),G_isAsia() and 24 or 20,true)
                pdLevelLimitLb2:setAnchorPoint(ccp(0,0.5))
                pdLevelLimitLb2:setPosition(pdLb1Width + middleWidth,posy1)
                backSprie:addChild(pdLevelLimitLb2)
                pdLb1Width = pdLevelLimitLb2:getContentSize().width
                if pdLb1Width > 90 then
                    pdLevelLimitLb2:setScale(90 / pdLb1Width)
                end
                -----第二行
                local chatChooseLb = GetTTFLabel(getlocal("activity_xlpd_chatChooseStr"),G_isAsia() and 24 or 20,true)
                chatChooseLb:setAnchorPoint(ccp(0,0.5))
                chatChooseLb:setPosition(0,posy2)
                backSprie:addChild(chatChooseLb)
                local chatChooseLbWidth = chatChooseLb:getContentSize().width
                if chatChooseLbWidth > 150 then
                    chatChooseLb:setScale(150 / chatChooseLbWidth)
                    chatChooseLbWidth = 150
                end

                local choseIdx = 1
                local leftArrowSp,rightArrowSp
                local chatLb = ""
                local function chooseHandle1()
                    PlayEffect(audioCfg.mouseClick)
                    choseIdx = 1
                    if chatLb then
                        chatLb:setString(getlocal("report_to_world"))
                        if chatLb:getContentSize().width > 100 then
                            chatLb:setScale(100 / chatLb:getContentSize().width)
                        end
                    end
                end
                local function chooseHandle2()
                    PlayEffect(audioCfg.mouseClick)
                    choseIdx = 2
                    if chatLb then
                        chatLb:setString(getlocal("alliance_list_scene_name"))
                        if chatLb:getContentSize().width > 100 then
                            chatLb:setScale(100 / chatLb:getContentSize().width)
                        end
                    end
                end
                local chooseBg=LuaCCScale9Sprite:createWithSpriteFrameName("inputBg1912.png",CCRect(10,10,5,5),function()end)
                chooseBg:setPosition(ccp(chatChooseLbWidth + 80,posy2))
                chooseBg:setContentSize(CCSizeMake(100,42))
                backSprie:addChild(chooseBg)

                chatLb = GetTTFLabel(getlocal("report_to_world"),G_isAsia() and 23 or 20)
                chatLb:setPosition(getCenterPoint(chooseBg))
                chatLb:setColor(G_ColorYellowPro2)
                if chatLb:getContentSize().width > 100 then
                    chatLb:setScale(100 / chatLb:getContentSize().width)
                end
                chooseBg:addChild(chatLb)

                local offset = 65
                leftArrowSp = LuaCCSprite:createWithSpriteFrameName("rewardCenterArrow.png",chooseHandle1)
                leftArrowSp:setPosition(chooseBg:getContentSize().width * 0.5 - offset, chooseBg:getContentSize().height * 0.5)
                leftArrowSp:setTouchPriority(-(self.layerNum-1)*20-4)
                leftArrowSp:setScale(0.65)
                chooseBg:addChild(leftArrowSp)
                rightArrowSp = LuaCCSprite:createWithSpriteFrameName("rewardCenterArrow.png",chooseHandle2)
                rightArrowSp:setFlipX(true)
                rightArrowSp:setScale(0.65)
                rightArrowSp:setPosition(chooseBg:getContentSize().width * 0.5 + offset, chooseBg:getContentSize().height * 0.5)
                rightArrowSp:setTouchPriority(-(self.layerNum-1)*20-4)
                chooseBg:addChild(rightArrowSp)

                ------第三行

                local function callBackTargetHandler(fn,eB,str) end
                local inviteBoxBg=LuaCCScale9Sprite:createWithSpriteFrameName("inputBg1912.png",CCRect(10,10,5,5),function()end)
                inviteBoxBg:setContentSize(CCSizeMake(400,200))
                inviteBoxBg:setIsSallow(false)
                inviteBoxBg:setTouchPriority(-(self.layerNum-1)*20-4)
                inviteBoxBg:setPosition(200, cellHeight * 0.5)
                local targetBoxLabel=GetTTFLabelWrap(getlocal("xlpd_invite_note"),24,CCSizeMake(390,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)

                targetBoxLabel:setPosition(getCenterPoint(inviteBoxBg))
                local customEditBox=customEditBox:new()
                local length=G_isAsia() and 20 or 40
                local function endCallBack()
                    acXlpdVoApi:setInputText(targetBoxLabel:getString())
                end
                local editBox=customEditBox:init(inviteBoxBg,targetBoxLabel,"mail_input_bg.png",nil,-(self.layerNum-1)*20-4,length,callBackTargetHandler,nil,nil,nil,nil,nil,nil,endCallBack)
                backSprie:addChild(inviteBoxBg,2)

                local inputTipLb = GetTTFLabel(getlocal("xlpd_inviteInput"),G_isAsia() and 20 or 18)
                inputTipLb:setColor(G_ColorGray)
                inputTipLb:setAnchorPoint(ccp(0,1))
                inputTipLb:setPosition(0, -5)
                inviteBoxBg:addChild(inputTipLb)

                local function postHandle()
                    local isNotCanPost,oldPostTime = acXlpdVoApi:getPostTime()
                    -- if isNotCanPost then
                    --     G_showTipsDialog(oldPostTime)
                    --     do return end
                    -- end
                    local function postSucessHandle()
                        local team = acXlpdVoApi:getChatNeedInfo( )
                        -- team.tid    = --邀请队伍id
                        -- team.pd     = --队伍攀登值
                        -- team.pn     = --当前队伍人数
                        -- team.max    = --最大人数
                        -- team.pdLv   = --攀登等级要求
                        -- team.leader = --队伍队长的昵称
                        -- team.msg    = --邀请宣言
                        local flag = acXlpdVoApi:dispatchInvite(team, nil, choseIdx)
                        if flag == true then
                            acXlpdVoApi:flushPostTime(base.serverTime)
                            if self.awardTb[3] then
                                self.awardTb[3]:close()
                            end
                            self:close()
                            G_showTipsDialog(getlocal("postInvitation")..getlocal("success_str"))
                        end
                    end
                    postSucessHandle()
                end
                local btnScale,priority = 0.9,-(self.layerNum-1)*20-4
                local postBtn,postMenu = G_createBotton(backSprie,ccp(200, 50),{getlocal("postInvitation")},"newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png",postHandle,btnScale,priority)
                local isNotCanPost,oldPostTime = acXlpdVoApi:getPostTime()
                if isNotCanPost == true then
                    postBtn:setEnabled(false)
                    self.inviteTimeLb = GetTTFLabelWrap(oldPostTime,18,CCSizeMake(bgWidth - 60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
                    self.inviteTimeLb:setPosition(backSprie:getContentSize().width/2,postMenu:getPositionY() + 50)
                    backSprie:addChild(self.inviteTimeLb)
                else
                    self.inviteTimeLb = nil
                end
            end
            return cell
        end
    end
    local hd=LuaEventHandler:createHandler(tvCallBack)
    local tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(bgWidth - 50,bgHeight - 104),nil)
    tableView:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    tableView:setPosition(ccp(25,22))
    self.bgLayer:addChild(tableView,2)
    tableView:setMaxDisToBottomOrTop(120)
    self.tv = tableView
end

function acThrivingSmallDialog:aboutXlpdMyTeamShow( )
    local bgWidth,bgHeight = self.dialogWidth , self.dialogHeight - 65
    local isTeamLeader = false--判断自己是否为队长
    -- local isCanFreeTeam = false

    local teamPdValue,selfTeam = self.awardTb[3],self.awardTb[4]

    local heightTb = {40,110,110,110}
    local bgPosy = bgHeight
    for i=1,4 do
        local bgCenterPosy = heightTb[i] * 0.5
        local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("newListItemBg.png", CCRect(4, 4, 1, 1), function () end)
        backSprie:setAnchorPoint(ccp(0.5,1))
        backSprie:setContentSize(CCSizeMake(bgWidth - 8,heightTb[i]))
        backSprie:setOpacity(i % 2 == 0 and 255 or 0)
        self.bgLayer:addChild(backSprie)
        
        backSprie:setPosition(ccp(bgWidth * 0.5,bgPosy))
        bgPosy = bgPosy - heightTb[i]

        if i == 1 then
            local teamPdValueLb = GetTTFLabel(getlocal("activity_xlpd_teamPdValue")..":"..teamPdValue,22,true)
            teamPdValueLb:setPosition(getCenterPoint(backSprie))
            teamPdValueLb:setColor(G_ColorYellowPro)
            backSprie:addChild(teamPdValueLb)
        else
            local tIdx = i - 1
            local pData = selfTeam[tIdx]
            if tIdx == 1 and pData and pData[1] == playerVoApi:getUid() then
                isTeamLeader =true
            end

            if pData and next(pData) then
                local pic = playerVoApi:getPersonPhotoName(pData[3] or headCfg.default)
                playerIconSp = playerVoApi:GetPlayerBgIcon(pic, function () end, nil, 70,80)
                playerIconSp:setPosition(100,bgCenterPosy)
                backSprie:addChild(playerIconSp)

                local nameLb = GetTTFLabel(pData[2],21,true)
                nameLb:setAnchorPoint(ccp(0,0.5))
                nameLb:setColor(G_ColorYellowPro)
                nameLb:setPosition(150,bgCenterPosy + 20)
                backSprie:addChild(nameLb)

                local pdLevelLb = GetTTFLabel(getlocal("activity_xlpd_level")..": Lv."..pData[4],21,true)
                pdLevelLb:setAnchorPoint(ccp(0,0.5))
                pdLevelLb:setPosition(150,bgCenterPosy - 20)
                backSprie:addChild(pdLevelLb)

                local teamTypeLb = GetTTFLabel(tIdx == 1 and getlocal("CaptainStr") or getlocal("memberStr"), G_isAsia() and 23 or 20)
                teamTypeLb:setPosition(bgWidth - 80, bgCenterPosy)
                backSprie:addChild(teamTypeLb)
            else
                --"Icon_BG.png"
                local function addHandle( )
                    print "进入邀请好友面板"
                    if G_checkClickEnable()==false then
                        do return end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)
                    local function getFriendsInfoHandle()
                        acXlpdVoApi:showInvitePanel(self.layerNum + 1, self)
                    end
                    acXlpdVoApi:socketGetFriendList(getFriendsInfoHandle)
                end
                local addMemberSp = LuaCCSprite:createWithSpriteFrameName("Icon_BG.png",addHandle)
                addMemberSp:setScale(0.8)
                addMemberSp:setTouchPriority(-(self.layerNum-1)*20-3)
                addMemberSp:setPosition( bgWidth * 0.5, bgCenterPosy + 15)
                backSprie:addChild(addMemberSp)

                local addBtnSp = CCSprite:createWithSpriteFrameName("st_addIcon.png")
                addBtnSp:setPosition(getCenterPoint(addMemberSp))
                addMemberSp:addChild(addBtnSp)
                local seq = CCSequence:createWithTwoActions(CCFadeTo:create(1, 55), CCFadeTo:create(1, 255))
                addBtnSp:runAction(CCRepeatForever:create(seq))

                local InviteTeammatesLb = GetTTFLabel(getlocal("InviteTeammates"),G_isAsia() and 20 or 18)
                InviteTeammatesLb:setColor(G_ColorGreen)
                InviteTeammatesLb:setPosition(bgWidth * 0.5, bgCenterPosy - 35)
                backSprie:addChild(InviteTeammatesLb)
            end
        end
    end
    local canFreeTeamLb = GetTTFLabel(getlocal("activity_xlpd_freeTeamStr"),G_isAsia() and 22 or 18,true)
    canFreeTeamLb:setAnchorPoint(ccp(0,0.5))
    canFreeTeamLb:setPosition(25,bgPosy - 35)
    self.bgLayer:addChild(canFreeTeamLb)
    local teamLbPosAndWidth = canFreeTeamLb:getPositionX() + canFreeTeamLb:getContentSize().width--check
    local teamLbPosy = canFreeTeamLb:getPositionY()

    local checkShowSp = nil
    local function checkCallBack( )
        -- print("here???????",isTeamLeader)
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        if not isTeamLeader then
            do return true end
        end
        local function refreshCheck( )
            if acXlpdVoApi:getCurIspool() == 1 then
                checkShowSp:setVisible(true)
            else
                checkShowSp:setVisible(false)
            end
        end
        acXlpdVoApi:socketRefreshIspool(refreshCheck)
    end 
    local checkTipBg=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",checkCallBack)
    checkTipBg:setAnchorPoint(ccp(0,0.5))
    checkTipBg:setTouchPriority(-(self.layerNum-1)*20-3);
    checkTipBg:setPosition(teamLbPosAndWidth + 8,teamLbPosy)
    self.bgLayer:addChild(checkTipBg)
    checkTipBg:setScale(canFreeTeamLb:getContentSize().height / checkTipBg:getContentSize().height)

    checkShowSp=CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
    checkTipBg:addChild(checkShowSp)
    checkShowSp:setPosition(getCenterPoint(checkTipBg))
    if acXlpdVoApi:getCurIspool() == 0 then
        checkShowSp:setVisible(false)
    end

    local checkTipLb = GetTTFLabelWrap(getlocal("activity_xlpd_freeTeamTipStr"),G_isAsia() and 20 or 17 ,CCSizeMake(bgWidth - 60,0), kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    checkTipLb:setAnchorPoint(ccp(0,1))
    checkTipLb:setColor(G_ColorRed)
    checkTipLb:setPosition(25, bgPosy - 55)
    self.bgLayer:addChild(checkTipLb)

    ---- 一键组队
    if selfTeam and SizeOfTable(selfTeam) == 1 then
        local function joinTeamHandle( )
            local function sureCallBack( )
                local function joinSucess( )
                    -- print("self.awardTb[5]====>>>>",self.awardTb[5])
                     if self.awardTb[5] then
                        self.awardTb[5]()
                     end
                     self:close()
                end
                acXlpdVoApi:socketTeamJoin(joinSucess)
            end
            local function cancleCallBack( ) end
            G_showSureAndCancle(getlocal("activity_xlpd_teamJoinBTipStr"),sureCallBack,cancleCallBack)
        end
        local btnScale,priority = 0.95,-(self.layerNum-1)*20-3
        local joinBtn,joinMenu = G_createBotton(self.bgLayer,ccp(bgWidth * 0.5 ,80),{getlocal("activity_xlpd_teamJoinBtnStr")},"newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png",joinTeamHandle,btnScale,priority,nil,111)
    end
end

function acThrivingSmallDialog:aboutXlpdLogShow()
    self.xlpdLogChooseIdx = 1
    self.xlpdTvCellNum    = SizeOfTable(self.awardTb[3])--组队记录条数

    local bgWidth,bgHeight = self.dialogWidth , self.dialogHeight - 65
    local tabPosy    = bgHeight - 80
    local cellHeight =  self.xlpdTvCellNum == 0 and bgHeight - 110 or 80
    local cellWidth  = bgWidth - 50
    
    local function tabHandle(tIdx)
        if tIdx == self.xlpdLogChooseIdx then
            do return end
        end
        self.xlpdLogChooseIdx = tIdx

        ---- 拿到数据
        self.xlpdTvCellNum = 0 -- 切换数据 需要刷新
        if tIdx == 1 then
            self.xlpdTvCellNum = SizeOfTable(self.awardTb[3])
        else
             self.xlpdTvCellNum = SizeOfTable(self.awardTb[4])
        end
        if self.xlpdTvCellNum == 0 then
            cellHeight = bgHeight - 110
        elseif tIdx == 1 then
            cellHeight = 80
        else
            cellHeight = 180
        end
        if self.tv then
            self.tv:reloadData()
        end
    end 
    for i=1,2 do
        local btnScale,priority = 1,-(self.layerNum-1)*20-100
        local posX = i == 1 and bgWidth * 0.5 - 2 or bgWidth * 0.5 + 2
        local anPosx = i == 1  and 1 or 0
        local btnStr = getlocal("activity_xlpd_logBtn"..i)
        local logBtn,logMenu = G_createBotton(self.bgLayer,ccp(posX ,tabPosy),{btnStr},"page_dark.png", "page_light.png", "page_dark.png",tabHandle,btnScale,priority,nil,i,ccp(anPosx , 0))
    end

    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png", CCRect(20, 20, 1, 1),function() end)
    tvBg:setContentSize(CCSizeMake(bgWidth - 50, bgHeight - 100))
    tvBg:setAnchorPoint(ccp(0.5,0))
    tvBg:setPosition(bgWidth *0.5, 20)
    self.bgLayer:addChild(tvBg)

    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return self.xlpdTvCellNum == 0  and 1 or self.xlpdTvCellNum
        elseif fn=="tableCellSizeForIndex" then
            return CCSizeMake(cellWidth, cellHeight)
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            if self.xlpdLogChooseIdx == 1 then
                local teamTb = self.awardTb[3][idx + 1] 
                if self.xlpdTvCellNum > 0 then
                        local timeTitle = G_getDataTimeStr(teamTb[3])
                        local playerInfo = teamTb[1]
                        local teamType = teamTb[2]
                        local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("newListItemBg.png", CCRect(4, 4, 1, 1), function () end)
                        backSprie:setContentSize(CCSizeMake(cellWidth,cellHeight))
                        backSprie:setPosition(ccp(cellWidth * 0.5,cellHeight * 0.5))
                        cell:addChild(backSprie)
                        backSprie:setOpacity(idx % 2 * 255)
                        local height=backSprie:getContentSize().height

                        local timeLb = GetTTFLabel(timeTitle,24,true)
                        timeLb:setPosition(cellWidth * 0.5, height * 0.78)
                        timeLb:setColor(G_ColorYellowPro2)
                        backSprie:addChild(timeLb)

                        local pName = GetTTFLabel(playerInfo,23)
                        pName:setAnchorPoint(ccp(0,0.5))
                        pName:setPosition(25,height * 0.24)
                        backSprie:addChild(pName)

                        local teamTypeLb = GetTTFLabel(teamType == 1 and getlocal("joinTeam") or getlocal("leaveTeam"),23)
                        teamTypeLb:setColor(teamType == 1 and G_ColorGreen or G_ColorRed)
                        teamTypeLb:setAnchorPoint(ccp(1,0.5))
                        teamTypeLb:setPosition(cellWidth - 40,height * 0.24)
                        backSprie:addChild(teamTypeLb)
                else---无数据
                    local notDataLabel = GetTTFLabel(getlocal("activity_xlpd_logBtn1")..getlocal("serverWarLocal_noData"), 25)
                    notDataLabel:setColor(G_ColorGray)
                    notDataLabel:setPosition(cellWidth * 0.5, cellHeight * 0.5)
                    cell:addChild(notDataLabel)
                end
            else
                local pkTb = self.awardTb[4][idx + 1] 

                if self.xlpdTvCellNum > 0 then
                        local isInMyTeamType = pkTb[5] or nil
                        local timeTitle = G_getDataTimeStr(pkTb[4])
                        local battleType = pkTb[3]
                        local timeLbHeight = 35

                        local timeLb = GetTTFLabel(timeTitle,24,true)
                        timeLb:setAnchorPoint(ccp(0.5,0))
                        timeLb:setColor(G_ColorYellowPro2)
                        timeLb:setPosition(cellWidth * 0.5, cellHeight - timeLbHeight)
                        cell:addChild(timeLb)

                        local namePosy = cellHeight - timeLbHeight
                        local bgStrTb = {"winnerMedal.png","loserMedal.png"}
                        local bgStr2Tb = {"ltzdzCampBg1.png","ltzdzCampBg2.png"}
                        local lbPosx = {cellWidth * 0.25,cellWidth * 0.75}
                        local tipStr = {getlocal("fight_content_result_win"),getlocal("fight_content_result_defeat")}


                        for i=1,2 do
                            local nameType = G_ColorWhite
                            if ( i == 1 and isInMyTeamType == 1 ) or ( i == 2 and isInMyTeamType == 0 ) then
                                nameType = G_ColorYellowPro
                            end


                            local lbRich  = {nil,nameType,nil}
                            local nameStr = getlocal("xxxTeam",{pkTb[i][1]})
                            -- print("nameStr===>>",nameStr)
                            local nameLb, lbHeight = G_getRichTextLabel(nameStr, lbRich, G_isAsia() and 22 or 19, 320, kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
                            nameLb:setPosition(lbPosx[i],namePosy)
                            cell:addChild(nameLb)
                            if battleType ~= 3 then
                                local bgSp = CCSprite:createWithSpriteFrameName(bgStrTb[i])
                                bgSp:setPosition(lbPosx[i],( cellHeight - timeLbHeight ) * 0.5 - 5)
                                bgSp:setScale(0.8)
                                cell:addChild(bgSp)
                            end

                            local bgSp2 = CCSprite:createWithSpriteFrameName(battleType == 3 and "ltzdzCampBg1.png" or bgStr2Tb[i])
                            bgSp2:setPosition(lbPosx[i],( cellHeight - timeLbHeight ) * 0.5 - 15)
                            bgSp2:setOpacity(200)
                            bgSp2:setScaleX(220 / bgSp2:getContentSize().width)
                            bgSp2:setScaleY( (namePosy - 30) / bgSp2:getContentSize().height)
                            cell:addChild(bgSp2)
                            if i == 1 then
                                bgSp2:setFlipX(true)
                                bgSp2:setFlipY(true)
                            end

                            local tipLb = GetTTFLabel(battleType == 3 and getlocal("drawStr") or tipStr[i],21,true)
                            tipLb:setPosition(lbPosx[i], ( cellHeight - timeLbHeight ) * 0.5 + 24)
                            if battleType ~= 3 then
                                tipLb:setColor(i == 1 and G_ColorGreen or G_ColorRed)
                            end
                            cell:addChild(tipLb)

                            ---海拔
                            local elevationLb = GetTTFLabel(getlocal("elevationStr")..":"..acXlpdVoApi:getElevation(pkTb[i][2]),G_isAsia() and 19 or 15)
                            elevationLb:setPosition(lbPosx[i], ( cellHeight - timeLbHeight ) * 0.5 - 25)
                            cell:addChild(elevationLb)                    
                            --攀登币
                            local pdCoinLb = GetTTFLabel(getlocal("activity_xlpd_coinName")..":"..pkTb[i][3],G_isAsia() and 19 or 15)
                            pdCoinLb:setPosition(lbPosx[i], ( cellHeight - timeLbHeight ) * 0.5 - 50)
                            cell:addChild(pdCoinLb)                    
                        end

                        local vsSp = CCSprite:createWithSpriteFrameName("VS.png")
                        vsSp:setPosition(cellWidth * 0.5, ( namePosy - 30 ) * 0.5)
                        vsSp:setScale(0.8)
                        cell:addChild(vsSp)
                else---无数据
                    local notDataLabel = GetTTFLabel(getlocal("activity_xlpd_logBtn2")..getlocal("serverWarLocal_noData"), 25)
                    notDataLabel:setColor(G_ColorGray)
                    notDataLabel:setPosition(cellWidth * 0.5, cellHeight * 0.5)
                    cell:addChild(notDataLabel)
                end
            end

            return cell
        end
    end
     local hd=LuaEventHandler:createHandler(tvCallBack)
    local tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(bgWidth - 50,bgHeight - 104),nil)
    tableView:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    tableView:setPosition(ccp(25,22))
    self.bgLayer:addChild(tableView,2)
    tableView:setMaxDisToBottomOrTop(120)
    self.tv = tableView
end

function acThrivingSmallDialog:aboutXlpdShopShow( )
    local bgWidth,bgHeight = self.dialogWidth , self.dialogHeight - 65

    local timeBg=LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png",CCRect(103,0,2,80),function()end)
    timeBg:setContentSize(CCSizeMake(bgWidth - 4,80))
    timeBg:setAnchorPoint(ccp(0.5,1))
    timeBg:setPosition(bgWidth * 0.5,bgHeight)
    self.bgLayer:addChild(timeBg,1)

    local timeStr=acXlpdVoApi:getShopTime()
    self.shopTimeLb=GetTTFLabel(timeStr,25,"Helvetica-bold")
    self.shopTimeLb:setColor(G_ColorYellowPro)--acXlpdVoApi:isShopOpen() and G_ColorYellowPro or G_ColorRed)
    self.shopTimeLb:setAnchorPoint(ccp(0.5,1))
    self.shopTimeLb:setPosition(ccp(timeBg:getContentSize().width * 0.5,timeBg:getContentSize().height - 12))
    timeBg:addChild(self.shopTimeLb,2)

    local cellHeight = 125
    local cellWidth  = bgWidth - 50
    local strSize2   = G_isAsia() and 20 or 18

    local function touchTip()
        acXlpdVoApi:getShopTip(self.layerNum + 1)
    end
    G_addMenuInfo(self.bgLayer, self.layerNum, ccp(bgWidth-35,bgHeight - 40), {}, nil, 0.9, 28, touchTip, true)

    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
    tvBg:setAnchorPoint(ccp(0.5,0))
    tvBg:setOpacity(0)
    tvBg:setContentSize(CCSizeMake(bgWidth - 50,bgHeight - 120))
    tvBg:setPosition(ccp(self.dialogWidth*0.5,20))
    self.bgLayer:addChild(tvBg) 

    local pdIcoin = GetTTFLabel(acXlpdVoApi:getCurCoin(),24,true)
    pdIcoin:setColor(G_ColorYellowPro2)
    pdIcoin:setAnchorPoint(ccp(0,0.5))
    pdIcoin:setPosition(ccp(bgWidth * 0.5 + 2,bgHeight - 75))
    self.pdIcoin = pdIcoin
    self.bgLayer:addChild(pdIcoin,2)
    local pdIcoinSp = CCSprite:createWithSpriteFrameName("pdCoin.png")
    pdIcoinSp:setAnchorPoint(ccp(1,0.5))
    pdIcoinSp:setPosition(bgWidth * 0.5 - 2,pdIcoin:getPositionY())
    pdIcoinSp:setScale((pdIcoin:getContentSize().height + 2) / pdIcoinSp:getContentSize().height)
    self.bgLayer:addChild(pdIcoinSp)

    self.tv = nil
     local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return acXlpdVoApi:getShopCellNum()
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(cellWidth, cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            local shopItem = acXlpdVoApi:getcurShopData( )[idx + 1]
            -- print("shopItem--->>",idx + 1,shopItem,SizeOfTable(shopItem))
            local shopInfo = FormatItem(shopItem.item,nil,true)[1]
            -- print("shopInfo---->>>>",SizeOfTable(shopInfo),shopItem.id)
            local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,0,1,32),function () end)
            nameBg:setContentSize(CCSizeMake(bgWidth - 80,28))
            nameBg:setAnchorPoint(ccp(0,1))
            nameBg:setPosition(0,cellHeight)
            cell:addChild(nameBg)

            local titleLb = GetTTFLabel(shopInfo.name,strSize2,true)
            titleLb:setAnchorPoint(ccp(0,0.5))
            titleLb:setColor(G_ColorYellowPro2)
            titleLb:setPosition(15,nameBg:getContentSize().height * 0.5)
            nameBg:addChild(titleLb)

            local titleLbStr2 = "("..getlocal("curProgressStr",{shopItem.curExNum or 0,shopItem.max})..")"
            local titleLb2 = GetTTFLabel(titleLbStr2,strSize2,true)
            titleLb2:setAnchorPoint(ccp(0,0.5))
            titleLb2:setPosition(18 + titleLb:getContentSize().width,nameBg:getContentSize().height * 0.5)
            nameBg:addChild(titleLb2)

            local function callback( )
                G_showNewPropInfo(self.layerNum+1,true,nil,nil,shopInfo,nil,nil,nil)
            end

            local icon,scale = G_getItemIcon(shopInfo,85,false,self.layerNum,callback,nil)
            icon:setTouchPriority(-(self.layerNum-1)*20-3)
            cell:addChild(icon)
            icon:setAnchorPoint(ccp(0,0))
            icon:setPosition(0,5)

            local numLb = GetTTFLabel("x" .. FormatNumber(shopInfo.num),20)
            numLb:setAnchorPoint(ccp(1,0))
            icon:addChild(numLb,4)
            numLb:setPosition(icon:getContentSize().width-5, 5)
            numLb:setScale(1/scale)

            local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
            numBg:setAnchorPoint(ccp(1,0))
            numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-5))
            numBg:setPosition(ccp(icon:getContentSize().width-5,5))
            numBg:setOpacity(150)
            icon:addChild(numBg,3)

            local descStr2 = G_formatStr(shopInfo)--awardTb.type == "p" and getlocal(awardTb.desc) or awardTb.desc
            local descLb = GetTTFLabelWrap(descStr2,strSize2 - 1,CCSizeMake(280,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            descLb:setAnchorPoint(ccp(0,1))
            descLb:setPosition(90,cellHeight - 45)
            cell:addChild(descLb)


            local limitMax,limitNum = shopItem.max,shopItem.curExNum or 0
            local price = shopItem.cost
            local canExChangeMax = shopItem.type == 2 and math.floor( acXlpdVoApi:getCurCoin() / price ) or math.floor( playerVoApi:getGems() / price )
            limitMax = canExChangeMax + shopItem.curExNum > limitMax and limitMax or canExChangeMax + shopItem.curExNum
            local sid = shopItem.id
            local isIntegral = shopItem.type == 2 and {"pdCoin.png",0.75} or nil
            local function exchangeHandle( )


                local function sureCallBack(num)
                    local shopNum = num
                    if acXlpdVoApi:isEnd() == true then
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10),
                            getlocal("acOver"), 28)
                        return
                    end
                    local function secondTipFunc(sbFlag)
                        local keyName = "active.xlpdShop"
                        local sValue=base.serverTime .. "_" .. sbFlag
                        G_changePopFlag(keyName,sValue)
                        
                    end
                    local function confirmHandler()
                            local function callBack(fn, data)
                                local ret, sData = base:checkServerData(data)
                                if ret == true then
                                    local rewardlist = {}
                                    if shopInfo and next(shopInfo) then
                                        local addItem = shopInfo
                                        addItem.num = addItem.num * shopNum
                                        G_addPlayerAward(addItem.type, addItem.key, addItem.id, addItem.num, nil, true)
                                        table.insert(rewardlist, addItem)
                                    end
                                    acXlpdVoApi:updateData(sData.data.xlpd)
                                    if shopItem.type == 1 then
                                        playerVoApi:setGems(playerVoApi:getGems() - price * shopNum)
                                    end


                                    require "luascript/script/game/scene/gamedialog/rewardShowSmallDialog"
                                    local function showEndHandler()
                                        if shopInfo then
                                            local awardItem = {
                                                type=shopInfo.type,
                                                key=shopInfo.key,
                                                pic=shopInfo.pic,
                                                name=shopInfo.name,
                                                num=shopInfo.num,
                                                desc=shopInfo.desc,
                                                id=shopInfo.id,
                                                bgname=shopInfo.bgname
                                            }
                                            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10),
                                                "", 28, nil, nil, {awardItem})

                                            if self.pdIcoin then
                                                self.pdIcoin:setString(acXlpdVoApi:getCurCoin())
                                            end
                                            -- acThrivingSmallDialog:refresh()
                                            if self.tv then
                                                local tv=tolua.cast(self.tv,"LuaCCTableView")
                                                local recordPoint=tv:getRecordPoint()
                                                tv:reloadData()
                                                tv:recoverToRecordPoint(recordPoint)
                                            end

                                        end
                                    end
                                    rewardShowSmallDialog:showNewReward(self.layerNum + 777, true, true, rewardlist,
                                        showEndHandler, getlocal("exchange_get"), nil, nil, nil, "")
                                end
                            end
                            socketHelper:acXlpdShopBuy(callBack, sid,shopNum)
                    end
                    local keyName = "active.xlpdShop"
                    if G_isPopBoard(keyName) then
                        local secondTipStr = shopItem.type == 2 and "second_pdTip_des" or  "second_tip_des"
                        G_showSecondConfirm(self.layerNum+666,true,true,getlocal("dialog_title_prompt"),getlocal(secondTipStr,{num*price}),true,confirmHandler,secondTipFunc)
                        do return end
                    else
                        confirmHandler()
                    end
                end
                shopVoApi:showBatchBuyPropSmallDialog(shopInfo.key,self.layerNum+555,sureCallBack,getlocal("activity_loversDay_tab2"),limitMax - limitNum,price,nil,true,shopInfo,nil,isIntegral)
            end
            local exBtnItem, exMenu = G_createBotton(cell, ccp(cellWidth - 80, 15), {getlocal("activity_loversDay_tab2"), 25}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", exchangeHandle, 0.6, -(self.layerNum - 1) * 20 - 3, 3,nil,ccp(0.5,0))

            local pdIcoin = GetTTFLabel(shopItem.cost,22,true)
            pdIcoin:setAnchorPoint(ccp(0,0.5))
            pdIcoin:setPosition(exMenu:getPositionX(), exBtnItem:getContentSize().height * 0.5 + exBtnItem:getPositionY() + 40)
            cell:addChild(pdIcoin)
            local pdIcoinSp = CCSprite:createWithSpriteFrameName(shopItem.type == 1 and "IconGold.png" or "pdCoin.png")
            pdIcoinSp:setAnchorPoint(ccp(1,0.5))
            pdIcoinSp:setPosition(exMenu:getPositionX(), exBtnItem:getContentSize().height * 0.5 + exBtnItem:getPositionY() + 40)
            pdIcoinSp:setScale((pdIcoin:getContentSize().height + 2) / pdIcoinSp:getContentSize().height)
            cell:addChild(pdIcoinSp)


            local bottomLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)--modifiersLine2
            bottomLine:setContentSize(CCSizeMake(cellWidth - 10,bottomLine:getContentSize().height))
            bottomLine:setRotation(180)
            bottomLine:setPosition(ccp(cellWidth * 0.5, 3))
            cell:addChild(bottomLine,1)
            
            if shopItem.exType == 3 then
                exBtnItem:setVisible(false)
                exBtnItem:setEnabled(false)
                local endExLb = GetTTFLabelWrap(getlocal("itsEnough"),G_isAsia() and 24 or 20,CCSizeMake(160,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                endExLb:setColor(G_ColorGray)
                endExLb:setPosition(exMenu:getPositionX(),35)
                cell:addChild(endExLb)
            elseif shopItem.exType == 2 or not shopItem.exType then
                exBtnItem:setEnabled(false)
            end

            return cell
        end
    end
    local hd=LuaEventHandler:createHandler(tvCallBack)
    local tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(bgWidth - 50,bgHeight - 124),nil)
    tableView:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    tableView:setPosition(ccp(25,22))
    self.bgLayer:addChild(tableView,2)
    tableView:setMaxDisToBottomOrTop(120)
    self.tv = tableView
end

function acThrivingSmallDialog:aboutVeriCall( )
    self.veriImageNum = 0
    local width ,height = self.dialogWidth, self.dialogHeight
    if self.awardTb[3] then

        local function removeVeriImgData(newImgPath)
            if self.veriImage then
                CCTextureCache:sharedTextureCache():removeTextureForKey(newImgPath)
                self.veriImage:removeFromParentAndCleanup(true)
                self.veriImage = nil
            end
        end 

        local function getNewVeriImg(newImgPath)
            removeVeriImgData(newImgPath)
            local veriImage = CCSprite:create(newImgPath)
            -- print("veriImage====>>>>",veriImage)
            veriImage:setPosition(width * 0.5, height - 120 )
            veriImage:setScale(2)
            self.bgLayer:addChild(veriImage)
            self.veriImage = veriImage
        end

        if self.awardTb[4] then
            self.awardTb[4] = false
            getNewVeriImg(self.awardTb[3])
        end

        local backSprie = self.bgLayer
        local numPos = ccp(width * 0.5,height * 0.5 - 15)

        local veriNum=GetTTFLabel(" ",30)
        veriNum:setPosition(numPos)
        backSprie:addChild(veriNum,10)
        veriNum:setString(tostring(self:getVeriImgNum()))

        local xBox = LuaCCScale9Sprite:createWithSpriteFrameName("worldInputBg.png",CCRect(10,10,5,5),function () end)

        local function inPutCallBack(newNum)
            self:setVeriImgNum(newNum)
            -- print("222222",newNum)
        end
        local editXBox =  G_editBoxWithNumberShow(backSprie, 5, numPos, xBox, CCSizeMake(100,42), 0, 9999, self:getVeriImgNum(), veriNum, inPutCallBack, true)
        
        local function tthandler2()
            PlayEffect(audioCfg.mouseClick)
            if editXBox then
                editXBox:setVisible(true)
            end
        end
        
        local xBoxBg=LuaCCScale9Sprite:createWithSpriteFrameName("worldInputBg.png",CCRect(10,10,5,5),tthandler2)
        xBoxBg:setPosition(numPos)
        xBoxBg:setContentSize(CCSizeMake(100,42))
        xBoxBg:setTouchPriority(-(self.layerNum-1)*20-4)
        backSprie:addChild(xBoxBg)

        local function veriSocketHandle()
            if base.verifyCoolingEndTs and tonumber(base.verifyCoolingEndTs) >= tonumber(base.serverTime) then
                G_showCoolingTimeTip(-201)
                do return end
            end
            
            local veriTipTb = {getlocal("veriSuccessStr"),getlocal("verifailureStr") , getlocal("backstage25113")}
            local willVeriNum = tostring(self:getVeriImgNum())
            if tonumber(willVeriNum) and #willVeriNum < 4 then
                willVeriNum = "0000"
            end
            local httpURL = "http://" .. base.serverIp .. "/tank-server/public/index.php/api/verifica/checkcode"
            local requestParams ="uid="..playerVoApi:getUid().."&zoneid="..base.curZoneID.."&code="..willVeriNum
            local function verIsAllright(responseStr)
                base:cancleNetWait()
                local veriType = nil
                if responseStr and responseStr ~="" then
                    local sData = G_Json.decode(responseStr)
                    local path = CCFileUtils:sharedFileUtils():getWritablePath().."webImg/"--veriFile
                    local imgPath = path.."veriImg.png"
                    if sData and sData.ret == 0 then
                        veriType = 1
                        removeVeriImgData(imgPath)
                        G_showTipsDialog(veriTipTb[veriType],nil,self.layerNum + 1)
                        base.veriIsTrue = nil
                        self:close()
                    elseif sData.data and sData.data.img then
                        veriType = 2
                        local imgData = string.gsub(sData.data.img,'\r\n','')
                        local deCodeData = ZZBase64:decode(imgData)--deviceHelper:base64Decode(imgData)
                        local file = io.open(imgPath,"w")
                        file:write(deCodeData)
                        file:close()
                        getNewVeriImg(imgPath)
                        G_showTipsDialog(veriTipTb[veriType],nil,self.layerNum + 1)
                    elseif sData and sData.ret == -201 then
                        base.verifyCoolingEndTs = sData and sData.data and sData.data.forbidTs or base.serverTime + 3600
                        G_showCoolingTimeTip(-201, self.layerNum + 1)
                        do return end
                    end
                end
            end
            G_sendHttpAsynRequest(httpURL, requestParams, verIsAllright, 2)
            base:setNetWait()
        end
        local btnScale,priority = 0.7, -(self.layerNum-1)*20-4
        local veriBtn = G_createBotton(backSprie,ccp(width * 0.5 ,80),{getlocal("veriStr"),25},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",veriSocketHandle,btnScale,priority)

    end
end

function acThrivingSmallDialog:getVeriImgNum( )
    return self.veriImageNum or 0
end
function acThrivingSmallDialog:setVeriImgNum(newNum)
    if newNum then
        self.veriImageNum = newNum
    end
end

function acThrivingSmallDialog:aboutTqbjCall( )--{"tqbj",titleStr,levelTb,rewardTb,SizeOfTable(rewardTb)}
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return self.awardTb[5]
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(self.dialogWidth - 20, 180)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            
            local cellBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
            cellBg:setAnchorPoint(ccp(0,1))
            cellBg:setContentSize(CCSizeMake(self.dialogWidth - 20, 170))
            cellBg:setPosition(0,180)
            cell:addChild(cellBg,1)

            local cellWidth = cellBg:getContentSize().width
            local cellHeight = cellBg:getContentSize().height

            local cellTitleBg=CCSprite:createWithSpriteFrameName("believerTitleBg.png")
            cellTitleBg:setPosition(ccp(cellBg:getContentSize().width * 0.5,cellBg:getContentSize().height - 2))
            cellTitleBg:setAnchorPoint(ccp(0.5,1))
            cellBg:addChild(cellTitleBg)

            local titleStr = getlocal("levelTo",{self.awardTb[3][idx+1][1],self.awardTb[3][idx+1][2]})
            local titleLb=GetTTFLabel(titleStr,22,"Helvetica-bold")
            titleLb:setColor(G_ColorYellowPro2)
            titleLb:setPosition(getCenterPoint(cellTitleBg))
            cellTitleBg:addChild(titleLb)

            local showAwardTb = self.awardTb[4][idx + 1]
            local showNum = SizeOfTable(showAwardTb)
            local useScale = 0.3
            if showNum == 2 then
                useScale = 0.4
            elseif showNum == 1 then
                useScale = 0.5
            end
            for i=1,showNum do
                local reward=showAwardTb[i]
                local function showNewReward()
                    if reward.type == "at" and reward.eType == "a" then --AI部队
                        local troopsVo = AITroopsVoApi:getMaxLvAITroopsVo(reward.key, true)
                        AITroopsVoApi:showTroopsInfoDialog(troopsVo, true, self.layerNum + 1)
                    else
                        G_showNewPropInfo(self.layerNum+1,true,true,nil,reward,nil,nil,nil,nil,true)
                    end
                    return false
                end
                local icon,scale=G_getItemIcon(reward,80,true,self.layerNum,showNewReward)
                icon:setTouchPriority(-(self.layerNum-1)*20-3)
                -- icon:setIsSallow(false)
                icon:setAnchorPoint(ccp(0.5,0))   

                icon:setPosition(cellWidth * useScale + cellWidth * 0.2 *(i - 1),15)
                G_noVisibleInIcon(reward,icon,101)
                cellBg:addChild(icon)
                local numLb=GetTTFLabel("×"..FormatNumber(reward.num),22)
                numLb:setAnchorPoint(ccp(1,0))
                numLb:setPosition(icon:getContentSize().width - 5,5)
                icon:addChild(numLb,2)
                numLb:setScale(0.9/scale)

                local numBg=CCSprite:createWithSpriteFrameName("allianceHeaderBg_black.png")--LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
                numBg:setAnchorPoint(ccp(0.5,0))
                numBg:setScaleX((icon:getContentSize().width -2 ) / numBg:getContentSize().width)
                numBg:setScaleY((numLb:getContentSize().height + 2) / numBg:getContentSize().height)
                -- numBg:setContentSize(CCSizeMake(90,numLb:getContentSize().height*numLb:getScale() - 2))
                numBg:setPosition(ccp(icon:getContentSize().width * 0.5 ,5))
                numBg:setOpacity(150)
                icon:addChild(numBg,1) 
            end

            return cell
        elseif fn=="ccTouchBegan" then
            isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            isMoved=true
        elseif fn=="ccTouchEnded"  then

        end
    end
    local hd=LuaEventHandler:createHandler(tvCallBack)

    local tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.dialogWidth - 20, self.dialogHeight - 100),nil)
    tableView:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    tableView:setPosition(ccp(10,30))
    self.bgLayer:addChild(tableView,2)
    tableView:setMaxDisToBottomOrTop(120)
    self.tv = tableView
end

function acThrivingSmallDialog:aboutDlbzSeeCall( )
    local descStr = GetTTFLabelWrap(self.awardTb[3],22,CCSize(self.dialogWidth-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    descStr:setAnchorPoint(ccp(0.5,0.5))
    descStr:setColor(G_ColorYellowPro2)
    descStr:setPosition(ccp(self.dialogWidth * 0.5, self.dialogHeight - 90))
    self.bgLayer:addChild(descStr) 

    local tvWidth,tvHeight = self.dialogWidth - 40 , self.dialogHeight - 130
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
    tvBg:setAnchorPoint(ccp(0.5,0))
    tvBg:setContentSize(CCSizeMake(tvWidth,tvHeight))
    tvBg:setPosition(ccp(self.dialogWidth*0.5,20))
    self.bgLayer:addChild(tvBg) 
    local cellHeight = 100
    local strSize2 = G_isAsia() and 20 or 18

    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return self.awardTb[4]
        elseif fn=="tableCellSizeForIndex" then
            return  CCSizeMake(tvWidth, cellHeight)
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            
            local awardTb,needNum = acDlbzVoApi:getExtraRewardToShow(self.awardTb[4] - idx)

            local function callback( )
                G_showNewPropInfo(self.layerNum+1,true,nil,nil,awardTb,nil,nil,nil)
            end

            local icon,scale = G_getItemIcon(awardTb,80,false,self.layerNum,callback,nil)
            icon:setTouchPriority(-(self.layerNum-1)*20-4)
            cell:addChild(icon)
            icon:setAnchorPoint(ccp(0,1))
            icon:setPosition(10,cellHeight - 10)

            local numLb = GetTTFLabel("x" .. FormatNumber(awardTb.num),20)
            numLb:setAnchorPoint(ccp(1,0))
            icon:addChild(numLb,4)
            numLb:setPosition(icon:getContentSize().width-5, 5)
            numLb:setScale(1/scale)

            local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
            numBg:setAnchorPoint(ccp(1,0))
            numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-5))
            numBg:setPosition(ccp(icon:getContentSize().width-5,5))
            numBg:setOpacity(150)
            icon:addChild(numBg,3)

            local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,0,1,32),function () end)
            nameBg:setContentSize(CCSizeMake(350,28))
            nameBg:setAnchorPoint(ccp(0,1))
            nameBg:setPosition(100,cellHeight - 10)
            cell:addChild(nameBg)

            local titleLb = GetTTFLabel(awardTb.name,strSize2,true)
            titleLb:setAnchorPoint(ccp(0,0.5))
            titleLb:setColor(G_ColorYellowPro2)
            titleLb:setPosition(15,nameBg:getContentSize().height * 0.5)
            nameBg:addChild(titleLb)

            local descStr2 = G_formatStr(awardTb)--awardTb.type == "p" and getlocal(awardTb.desc) or awardTb.desc
            local descLb = GetTTFLabelWrap(descStr2,strSize2 - 3,CCSizeMake(250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            descLb:setAnchorPoint(ccp(0,1))
            descLb:setPosition(100,cellHeight - 45)
            cell:addChild(descLb)

            --activity_vipAction_had
            local canGetStr = needNum < 1 and getlocal("activity_vipAction_had") or getlocal("activity_dlbz_snatchCanget",{needNum})

            local canGetLb = GetTTFLabelWrap(canGetStr,strSize2-3,CCSizeMake(140,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            canGetLb:setPosition(tvWidth - 75,cellHeight * 0.35)
            canGetLb:setAnchorPoint(ccp(0.5,0.5))
            cell:addChild(canGetLb)

            local bottomLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)--modifiersLine2
            bottomLine:setContentSize(CCSizeMake(tvWidth - 10,bottomLine:getContentSize().height))
            bottomLine:setRotation(180)
            bottomLine:setPosition(ccp(tvWidth * 0.5, 0))
            cell:addChild(bottomLine,1)

            return cell
        end
    end
    local hd=LuaEventHandler:createHandler(tvCallBack)
    local tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth, tvHeight - 4),nil)
    tableView:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    tableView:setPosition(ccp(20,22))
    self.bgLayer:addChild(tableView,2)
    tableView:setMaxDisToBottomOrTop(120)
    self.tv = tableView

end

function acThrivingSmallDialog:aboutQmcjCall( )
    local strSize3 = 20
    if G_isAsia() then
        strSize3 = 24
    end
    -- print("qmcjjjjjjjjj~~~~~~~~~~~")
    local stageStrTb = {"singleRecharge2","singleScores2","legionMembersScores2"}
    local numsScaleTb = {100,100,1}

    local dialogBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ()end)
    dialogBg2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,self.dialogHeight*0.5))
    dialogBg2:setAnchorPoint(ccp(0.5,0))
    dialogBg2:setPosition(self.bgLayer:getContentSize().width*0.5,30)
    self.bgLayer:addChild(dialogBg2)
    local  smalDiaWidth = dialogBg2:getContentSize().height
    --curProgressStr
    local curProbability,curRechargeNums,lowerLimit,nextProbability,nextRchargeNums = acEatChickenVoApi:getSixKillProbability( )
    local curStageStr = GetTTFLabelWrap(getlocal("curStage")..getlocal("singleRecharge2",{curRechargeNums,lowerLimit}),strSize3,CCSizeMake(self.dialogWidth*0.8,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    curStageStr:setAnchorPoint(ccp(0,0.5))
    curStageStr:setPosition(ccp(30,smalDiaWidth*0.85))
    dialogBg2:addChild(curStageStr)
    self.curStageStr = curStageStr
    curStageStr:setColor(G_ColorGreen)

    local curProblty = GetTTFLabelWrap(getlocal("activity_qmcj_bufTab1",{curProbability*100}),strSize3,CCSizeMake(self.dialogWidth*0.8,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    curProblty:setAnchorPoint(ccp(0,0.5))
    curProblty:setPosition(ccp(30,smalDiaWidth*0.65))
    dialogBg2:addChild(curProblty)
    self.curProblty = curProblty
    curProblty:setColor(G_ColorYellowPro)

    local bufTopStr =  GetTTFLabelWrap(getlocal("bufTopStr"),strSize3,CCSizeMake(self.dialogWidth*0.8,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    bufTopStr:setAnchorPoint(ccp(0,0.5))
    bufTopStr:setPosition(ccp(30,smalDiaWidth*0.2))
    dialogBg2:addChild(bufTopStr)
    self.bufTopStr = bufTopStr
    bufTopStr:setColor(G_ColorRed)
    bufTopStr:setVisible(false)

    if nextProbability then
        local nextStageStr = GetTTFLabelWrap(getlocal("nextStage")..getlocal("singleRecharge2",{curRechargeNums,nextRchargeNums}),strSize3,CCSizeMake(self.dialogWidth*0.8,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        nextStageStr:setAnchorPoint(ccp(0,0.5))
        nextStageStr:setPosition(ccp(30,smalDiaWidth*0.4))
        dialogBg2:addChild(nextStageStr)
        self.nextStageStr = nextStageStr
        nextStageStr:setColor(G_ColorRed)
        local nextProblty = GetTTFLabelWrap(getlocal("activity_qmcj_bufTab1",{nextProbability*100}),strSize3,CCSizeMake(self.dialogWidth*0.8,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        nextProblty:setAnchorPoint(ccp(0,0.5))
        nextProblty:setPosition(ccp(30,smalDiaWidth*0.2))
        dialogBg2:addChild(nextProblty)
        self.nextProblty = nextProblty
        nextProblty:setColor(G_ColorYellowPro)
    else
        curStageStr:setPositionY(smalDiaWidth*0.8)
        curProblty:setPositionY(smalDiaWidth*0.5)
        bufTopStr:setVisible(true)
    end

    self.checkSpTb = {}
    self.noCheckSpTb = {}
    local heightScale = 0.7
    local function checkCall(object,name,tag)
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        
        for i=1,3 do
            if i == tag then
                self.noCheckSpTb[i]:setVisible(false)
                self.checkSpTb[i]:setVisible(true)

                local curProbability,curRechargeNumsOrScores,lowerLimit,nextProbability,nextRechargeNumsOrScores =nil,nil,nil,nil,nil
                if tag == 1 then
                    curProbability,curRechargeNumsOrScores,lowerLimit,nextProbability,nextRechargeNumsOrScores =acEatChickenVoApi:getSixKillProbability()
                elseif tag == 2 then
                    curProbability,curRechargeNumsOrScores,lowerLimit,nextProbability,nextRechargeNumsOrScores =acEatChickenVoApi:getBigAwardProbability()
                else
                    curProbability,curRechargeNumsOrScores,lowerLimit,nextProbability,nextRechargeNumsOrScores =acEatChickenVoApi:getawardLowerLimitRobability()
                end
                self.curStageStr:setString(getlocal("curStage")..getlocal(stageStrTb[i],{curRechargeNumsOrScores,lowerLimit}))
                self.curProblty:setString(getlocal("activity_qmcj_bufTab"..tag,{curProbability*numsScaleTb[i]}))

                -- print("curRechargeNumsOrScores======>>>>>",curRechargeNumsOrScores,nextRechargeNumsOrScores)
                if nextProbability then
                    if self.nextStageStr then
                        -- print("in here???111111111")
                        self.nextStageStr:setString(getlocal("nextStage")..getlocal(stageStrTb[i],{curRechargeNumsOrScores,nextRechargeNumsOrScores}))
                        self.nextProblty:setString(getlocal("activity_qmcj_bufTab"..tag,{nextProbability*numsScaleTb[i]}))
                        self.nextStageStr:setVisible(true)
                        self.nextProblty:setVisible(true)

                        self.curStageStr:setPositionY(smalDiaWidth*0.85)
                        self.curProblty:setPositionY(smalDiaWidth*0.65)
                    else
                        local nextStageStr = GetTTFLabelWrap(getlocal("nextStage")..getlocal(stageStrTb[i],{curRechargeNumsOrScores,nextRechargeNumsOrScores}),strSize3,CCSizeMake(self.dialogWidth*0.8,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                        nextStageStr:setAnchorPoint(ccp(0,0.5))
                        nextStageStr:setPosition(ccp(30,smalDiaWidth*0.4))
                        dialogBg2:addChild(nextStageStr)
                        self.nextStageStr = nextStageStr
                        nextStageStr:setColor(G_ColorRed)
                        local nextProblty = GetTTFLabelWrap(getlocal("activity_qmcj_bufTab"..tag,{nextProbability*numsScaleTb[i]}),strSize3,CCSizeMake(self.dialogWidth*0.8,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                        nextProblty:setAnchorPoint(ccp(0,0.5))
                        nextProblty:setPosition(ccp(30,smalDiaWidth*0.2))
                        dialogBg2:addChild(nextProblty)
                        self.nextProblty = nextProblty
                        nextProblty:setColor(G_ColorYellowPro)

                        self.curStageStr:setPositionY(smalDiaWidth*0.85)
                        self.curProblty:setPositionY(smalDiaWidth*0.65)
                    end
                    self.bufTopStr:setVisible(false)
                else
                    self.bufTopStr:setVisible(true)
                    self.curStageStr:setPositionY(smalDiaWidth*0.8)
                    self.curProblty:setPositionY(smalDiaWidth*0.5)
                    if self.nextStageStr then
                        self.nextStageStr:setVisible(false)
                        self.nextProblty:setVisible(false)
                    end
                end
                
            else
                self.noCheckSpTb[i]:setVisible(true)
                -- self.noCheckSpTb[i]:setColor(ccc3(136,136,136))
                self.checkSpTb[i]:setVisible(false)
            end

        end
    end
    for i=1,3 do
        local noCheckSp = LuaCCSprite:createWithSpriteFrameName("chickBtn_1.png",checkCall)
        local heightScale = 0.7
        noCheckSp:setPosition(ccp(0.25*i*self.bgLayer:getContentSize().width,self.dialogHeight*heightScale))
        noCheckSp:setTag(i)
        noCheckSp:setTouchPriority(-(self.layerNum-1)*20-4)
        noCheckSp:setColor(ccc3(136,136,136))
        self.bgLayer:addChild(noCheckSp)
        self.noCheckSpTb[i] = noCheckSp
        local checkSp = CCSprite:createWithSpriteFrameName("chickBtn_2.png")
        checkSp:setPosition(ccp(0.25*i*self.bgLayer:getContentSize().width,self.dialogHeight*heightScale))
        self.bgLayer:addChild(checkSp)
        self.checkSpTb[i] = checkSp

        if i == 1 then
            noCheckSp:setVisible(false)
        else
            checkSp:setVisible(false)
        end
    end


end

function acThrivingSmallDialog:aboutXlysCall( ... )

    local adaStrSize,adaHeight
    if G_isAsia() == true then
        adaStrSize = 22
        adaHeight=0
         if G_getCurChoseLanguage() == "ko" and self.awardTb[1] =="smbd" or self.awardTb[1] == "xstz" then
            adaHeight = 10
        end
    else
        adaStrSize = 18
        adaHeight= 10
    end

    for i=1,2 do

        local descStr = nil 
        descStr = GetTTFLabelWrap(self.awardTb[3][i],adaStrSize,CCSize(self.dialogWidth-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)--GetTTFLabel(self.awardTb[3],22)
        descStr:setPosition(ccp(30, self.dialogHeight - 66 - 15+adaHeight))--66 背景图上边框高度
        descStr:setAnchorPoint(ccp(0,1))
        self.bgLayer:addChild(descStr) 

        local awardBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
        awardBg:setAnchorPoint(ccp(0.5,0))
        local heightScale = self.awardTb[5] > 4 and 0.7 or 0.6
        awardBg:setContentSize(CCSizeMake(self.dialogWidth-40,self.dialogHeight - 66 - 25 - 60))
        awardBg:setPosition(ccp(self.dialogWidth*0.5,30))
        self.bgLayer:addChild(awardBg)

        local posXxScale = self.awardTb[5] == 3 and {0.25,0.5,0.75} or {0.2,0.4,0.6,0.8}
        local posYyScale = self.awardTb[5] > 4 and {0.75,0.25} or {0.5}
        if self.awardTb[5] > 8 then
            posYyScale = {0.8,0.5,0.2}
        end
        for k,v in pairs(self.awardTb[4]) do
            local function callback( )
                G_showNewPropInfo(self.layerNum+2,true,nil,nil,v,nil,nil,nil)
            end
            local icon,scale 
            if self.awardTb[1] == "smbd" and v.type == "se" then
                icon,scale=G_getItemIcon(v,100,true,self.layerNum,nil,nil,nil,nil,nil,nil,true)
            else
                icon,scale=G_getItemIcon(v,100,false,self.layerNum,callback,nil)
            end
            awardBg:addChild(icon)
            local useScale = 100/icon:getContentSize().width
            -- icon:setAnchorPoint(ccp(0.5,0.5))
            icon:setTouchPriority(-(self.layerNum-1)*20-4)
            local posssX = k > 4 and k - 4 or k
            local possssy = k > 4 and 2 or 1
            if k > 8 then
                posssX = k - 8
                possssy = 3
            end
            if self.awardTb[5] == 3 then
                icon:setPosition(ccp(awardBg:getContentSize().width*posXxScale[posssX],awardBg:getContentSize().height*posYyScale[possssy]))
            else
                icon:setPosition(ccp( (30 + icon:getContentSize().width*useScale)*0.5 +(posssX - 1) * (25 + icon:getContentSize().width*useScale) ,awardBg:getContentSize().height*posYyScale[possssy]))
            end

            local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function() end)
            numBg:setAnchorPoint(ccp(1,0))
            icon:addChild(numBg,1)
            numBg:setPosition(icon:getContentSize().width-5, 4)

            local numLabel=GetTTFLabel("x"..v.num,21)
            numLabel:setAnchorPoint(ccp(1,0))
            numLabel:setPosition(icon:getContentSize().width-5, 5)
            numLabel:setScale(1/scale)
            icon:addChild(numLabel,1)
            numBg:setContentSize(CCSizeMake(numLabel:getContentSize().width+5,numLabel:getContentSize().height+4))
        end
    end
end

function acThrivingSmallDialog:addBoxAndAni( )
    local rewardCenterBtnBg = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
    rewardCenterBtnBg:setOpacity(0)
    self.bgLayer:addChild(rewardCenterBtnBg,2)
    rewardCenterBtnBg:setPosition(ccp(self.dialogWidth*0.18,self.dialogHeight*0.64-30))
    for i=1,2 do
      local realLight = CCSprite:createWithSpriteFrameName("equipShine.png")
      realLight:setScale(1.4)
      realLight:setPosition(getCenterPoint(rewardCenterBtnBg))
      rewardCenterBtnBg:addChild(realLight)  
      local roteSize = i ==1 and 360 or -360
      local rotate1=CCRotateBy:create(8, roteSize)
      local repeatForever = CCRepeatForever:create(rotate1)
      realLight:runAction(repeatForever)
    end

    local rewardCenterBtn=CCSprite:createWithSpriteFrameName("unGiftBoxPic.png")
    rewardCenterBtn:setPosition(getCenterPoint(rewardCenterBtnBg))
    -- rewardCenterBtn:setScale(1.4)
    rewardCenterBtnBg:addChild(rewardCenterBtn,1)

    local littStars = CCParticleSystemQuad:create("public/littStars.plist")
    littStars.positionType=kCCPositionTypeFree
    littStars:setPosition(getCenterPoint(rewardCenterBtn))
    rewardCenterBtn:addChild(littStars,99)
    local subPosY = -10 
    local boxAwardLb = GetTTFLabel(getlocal("giftPackageReward")..":",25)
    boxAwardLb:setAnchorPoint(ccp(0,1))
    boxAwardLb:setPosition(ccp(rewardCenterBtnBg:getContentSize().width,rewardCenterBtnBg:getContentSize().height+5))
    rewardCenterBtnBg:addChild(boxAwardLb)

    local bigAwardMaxAmount = acThrivingVoApi:getBigAwardMaxAmount()
    
    for k,v in pairs(bigAwardMaxAmount) do
        local function callback( )
            G_showNewPropInfo(self.layerNum+1,true,nil,nil,v,nil,nil,nil)
        end 
        local icon,scale=G_getItemIcon(v,75,false,self.layerNum,callback,nil)
        rewardCenterBtnBg:addChild(icon)
        icon:setTouchPriority(-(self.layerNum-1)*20-4)
        icon:setPosition(ccp(rewardCenterBtnBg:getContentSize().width+90*(k-1)+80,rewardCenterBtnBg:getContentSize().height-65+subPosY))

        local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function() end)
        numBg:setAnchorPoint(ccp(1,0))
        icon:addChild(numBg,1)
        -- numBg:setOpacity(220)
        numBg:setPosition(icon:getContentSize().width-5, 4)

        local numLabel=GetTTFLabel("x"..v.num,21)
        numLabel:setAnchorPoint(ccp(1,0))
        numLabel:setPosition(icon:getContentSize().width-5, 5)
        numLabel:setScale(1/scale)
        icon:addChild(numLabel,1)
        numBg:setContentSize(CCSizeMake(numLabel:getContentSize().width+23,numLabel:getContentSize().height+8))
    end
    local CurCompletedTaskNums,curAwardNums = acThrivingVoApi:getCurCompletedTaskNums( )
    local taskComplDegreeLb = GetTTFLabel(getlocal("taskComplDegree",{CurCompletedTaskNums,100}),24)
    taskComplDegreeLb:setAnchorPoint(ccp(0,0.5))
    taskComplDegreeLb:setPosition(ccp(rewardCenterBtnBg:getContentSize().width,rewardCenterBtnBg:getContentSize().height-145+subPosY*0.5))
    rewardCenterBtnBg:addChild(taskComplDegreeLb)

    local canGetAwardAmount = GetTTFLabel(getlocal("getAwardPer",{curAwardNums}),24)
    canGetAwardAmount:setAnchorPoint(ccp(0,0.5))
    local subPosX = 0
    if G_getCurChoseLanguage() == "de" then
        subPosX = 150
    end
    canGetAwardAmount:setPosition(ccp(rewardCenterBtnBg:getContentSize().width-subPosX,rewardCenterBtnBg:getContentSize().height-180+subPosY))
    rewardCenterBtnBg:addChild(canGetAwardAmount)

    local lineSp =LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png",CCRect(34,1,1,1),function ()end)
    lineSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-10,lineSp:getContentSize().height))
    -- lineSp:setScaleX(self.bgLayer:getContentSize().width/lineSp:getContentSize().width)
    -- lineSp:setScaleY(0.8)
    lineSp:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height*0.36+subPosY))
    self.bgLayer:addChild(lineSp,1)

    local timeStr,timeStr2=acThrivingVoApi:getTimer()
    local messageLabel=GetTTFLabel(timeStr2,25)
    messageLabel:setAnchorPoint(ccp(0.5,1))
    messageLabel:setColor(G_ColorYellowPro)
    messageLabel:setPosition(ccp(self.dialogWidth*0.5,lineSp:getPositionY()-30))
    self.bgLayer:addChild(messageLabel)
    self.timeLb=messageLabel

    local isInLastDay = acThrivingVoApi:isInLastDay()
    local hadBigAward = acThrivingVoApi:gethadBigAward( )

    local function getAwardCall(  )
        -- print("getAwardCall~~~~~~~!!!!@@@###")
        if hadBigAward == 1 then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_hadReward"),28)
            do return end
        end
        -- print("isInLastDay=======>>>>",isInLastDay,curAwardNums)
        if (CurCompletedTaskNums < 100 and isInLastDay == false ) or (isInLastDay and curAwardNums == 0 )then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_zzrs_canAward"),28)
            do return end
        end
        local function getCellAwardCall(fn,data)
            local ret,sData = base:checkServerData(data)
            if ret==true then
                if sData and sData.data and sData.data.zzrs then
                    acThrivingVoApi:updateData(sData.data.zzrs)
                    if sData.data.zzrs.c then
                        acThrivingVoApi:sethadBigAward(sData.data.zzrs.c)
                        lotteryBtn:setEnabled(false)
                    end
                end
                local curGetBigAwardTb = acThrivingVoApi:getBigAwardMaxAmount(curAwardNums/10)
                for k,v in pairs(curGetBigAwardTb) do
                    G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                end
                G_showRewardTip(curGetBigAwardTb,true)
            end
        end
        typeName = typeName =="gba" and "gb" or typeName
        socketHelper:acThrivingRequest("active.zzrs.talreward",{},getCellAwardCall)
    end 
    lotteryBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",getAwardCall,nil,getlocal("daily_scene_get"),32,11)
    lotteryBtn:setScale(0.8)
    local lotteryMenu=CCMenu:createWithItem(lotteryBtn)
    lotteryMenu:setTouchPriority(-(self.layerNum-1)*20-3)
    lotteryMenu:setPosition(ccp(self.dialogWidth*0.5,55))
    self.bgLayer:addChild(lotteryMenu,5)

    if isInLastDay and (hadBigAward == 1 or curAwardNums == 0 )then
        lotteryBtn:setEnabled(false)
    end
end

function acThrivingSmallDialog:aboutMjzxCall()
    local adaStrSize,adaHeight
    if G_isAsia() == true then
        adaStrSize = 22
        adaHeight=0
         if G_getCurChoseLanguage() == "ko" and self.awardTb[1] =="smbd" then
            adaHeight = 10
        end
    else
        adaStrSize = 18
        adaHeight= 10
    end
    local adaH = 0
    local adaH1 = 0
    local descStr = nil 

    if self.awardTb[1] =="xcjh"  then
        adaH = 30
    end
    if self.awardTb[1] =="xcjh" and self.awardTb[6] then
        adaH1 = 30
    end

    if  self.awardTb[1] =="yrj" then
        local strSize3 = G_isAsia() and 20 or 17
        local colorTab={nowColor,G_ColorYellowPro,nowColor}
        descStr = G_getRichTextLabel(self.awardTb[3],colorTab,strSize3,self.dialogWidth-40,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,0,true)
        descStr:setPosition(ccp(20, self.dialogHeight - 70))--66 背景图上边框高度
    else
        descStr = GetTTFLabelWrap(self.awardTb[3],adaStrSize,CCSize(self.dialogWidth-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)--GetTTFLabel(self.awardTb[3],22)
        descStr:setPosition(ccp(30, self.dialogHeight - 66 - 15+adaHeight))--66 背景图上边框高度
    end
    descStr:setAnchorPoint(ccp(0,1))
    self.bgLayer:addChild(descStr) 




    local awardBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
    awardBg:setAnchorPoint(ccp(0.5,0))
    local heightScale = self.awardTb[5] > 4 and 0.7 or 0.6
    awardBg:setContentSize(CCSizeMake(self.dialogWidth-40,self.dialogHeight - 66 - 25 - 60-adaH))
    awardBg:setPosition(ccp(self.dialogWidth*0.5,30))
    self.bgLayer:addChild(awardBg)

    if self.awardTb[6] then
     
        local titleBg=CCSprite:createWithSpriteFrameName("believerTitleBg.png")
        titleBg:setAnchorPoint(ccp(0.5,1))
        titleBg:setPosition(awardBg:getContentSize().width/2,awardBg:getContentSize().height-2)
        awardBg:addChild(titleBg)

        local allGemLabel = GetTTFLabel(getlocal("all_worth_gem",{self.awardTb[6]}),22,true)
        allGemLabel:setAnchorPoint(ccp(0.5,0.5))
        allGemLabel:setPosition(ccp(titleBg:getContentSize().width/2-5,titleBg:getContentSize().height/2))
        allGemLabel:setColor(G_ColorYellowPro)
        titleBg:addChild(allGemLabel)
        
        local costSp=CCSprite:createWithSpriteFrameName("IconGold.png")
        costSp:setAnchorPoint(ccp(1,0.5))
        costSp:setPosition(ccp(allGemLabel:getContentSize().width+30,allGemLabel:getContentSize().height/2))
        allGemLabel:addChild(costSp)

    end

    local posXxScale = self.awardTb[5] == 3 and {0.25,0.5,0.75} or {0.2,0.4,0.6,0.8}
    local posYyScale = self.awardTb[5] > 4 and {0.75,0.25} or {0.5}
    if self.awardTb[5] > 8 then
        posYyScale = {0.8,0.5,0.2}
    end
    for k,v in pairs(self.awardTb[4]) do
        local function callback( )
            if v.type == "at" and v.eType == "a" then --AI部队
                local troopsVo = AITroopsVoApi:getMaxLvAITroopsVo(v.key, true)
                AITroopsVoApi:showTroopsInfoDialog(troopsVo, true, self.layerNum + 2)
            else
                G_showNewPropInfo(self.layerNum+2,true,nil,nil,v,nil,nil,nil)
            end
        end
        local icon,scale 
        if self.awardTb[1] == "smbd" and v.type == "se" then
            icon,scale=G_getItemIcon(v,100,true,self.layerNum,nil,nil,nil,nil,nil,nil,true)
        else
            icon,scale=G_getItemIcon(v,100,false,self.layerNum,callback,nil)
        end
        awardBg:addChild(icon)
        local useScale = 100/icon:getContentSize().width
        -- icon:setAnchorPoint(ccp(0.5,0.5))
        icon:setTouchPriority(-(self.layerNum-1)*20-4)
        local posssX = k > 4 and k - 4 or k
        local possssy = k > 4 and 2 or 1
        if k > 8 then
            posssX = k - 8
            possssy = 3
        end
        if self.awardTb[5] == 3 then
            icon:setPosition(ccp(awardBg:getContentSize().width*posXxScale[posssX],awardBg:getContentSize().height*posYyScale[possssy]-adaH1))
        else
            icon:setPosition(ccp( (30 + icon:getContentSize().width*useScale)*0.5 +(posssX - 1) * (25 + icon:getContentSize().width*useScale) ,awardBg:getContentSize().height*posYyScale[possssy]-adaH1))
        end

        local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function() end)
        numBg:setAnchorPoint(ccp(1,0))
        icon:addChild(numBg,1)
        numBg:setPosition(icon:getContentSize().width-5, 4)
        if self.awardTb[1] == "xstz" then
            numBg:setOpacity(0)
        end
        local numLabel=GetTTFLabel("x"..v.num,21)
        numLabel:setAnchorPoint(ccp(1,0))
        numLabel:setPosition(icon:getContentSize().width-5, 5)
        numLabel:setScale(1/scale)
        icon:addChild(numLabel,1)
        numBg:setContentSize(CCSizeMake(numLabel:getContentSize().width+5,numLabel:getContentSize().height+4))

    end
end

function acThrivingSmallDialog:aboutQmsdCall()
    
    local descStr = GetTTFLabelWrap(self.awardTb[3],22,CCSize(self.dialogWidth-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)--GetTTFLabel(self.awardTb[3],22)
    descStr:setAnchorPoint(ccp(0,0.5))
    descStr:setPosition(ccp(30, self.awardTb[5] > 4 and self.dialogHeight*0.78 or self.dialogHeight*0.72))
    self.bgLayer:addChild(descStr) 

    local awardBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
    awardBg:setAnchorPoint(ccp(0.5,0))
    local heightScale = self.awardTb[5] > 4 and 0.7 or 0.6
    awardBg:setContentSize(CCSizeMake(self.dialogWidth-40,self.dialogHeight*heightScale - descStr:getContentSize().height - 10))
    awardBg:setPosition(ccp(self.dialogWidth*0.5,self.awardTb[5] > 4 and 40 or 45))
    self.bgLayer:addChild(awardBg)   

    local cType = 0
    local posXxScale = self.awardTb[5] == 3 and {0.25,0.5,0.75} or {0.2,0.4,0.6,0.8}
    local posYyScale = self.awardTb[5] > 4 and {0.75,0.25} or {0.5}
    for k,v in pairs(self.awardTb[4]) do
        local function callback( )
            G_showNewPropInfo(self.layerNum+1,true,nil,nil,v,nil,nil,nil,nil,true)
        end 
        local icon,scale=G_getItemIcon(v,100,false,self.layerNum,callback,nil)
        awardBg:addChild(icon)
        -- icon:setAnchorPoint(ccp(0.5,0.5))
        icon:setTouchPriority(-(self.layerNum-1)*20-4)
        local posssX = k > 4 and k - 4 or k
        local possssy = k > 4 and 2 or 1
        
        if self.awardTb[5] == 3 then
            icon:setPosition(ccp(awardBg:getContentSize().width*posXxScale[posssX],awardBg:getContentSize().height*posYyScale[possssy]))
        else
            local iconWidth = 100
            icon:setPosition(ccp( (30 + iconWidth)*0.5 +(posssX - 1) * (25 + iconWidth) ,awardBg:getContentSize().height*posYyScale[possssy]))
        end

        local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function() end)
        numBg:setAnchorPoint(ccp(1,0))
        icon:addChild(numBg,1)
        numBg:setPosition(icon:getContentSize().width-5, 4)

        local numLabel=GetTTFLabel("x"..v.num,21)
        numLabel:setAnchorPoint(ccp(1,0))
        numLabel:setPosition(icon:getContentSize().width-5, 5)
        numLabel:setScale(1/scale)
        icon:addChild(numLabel,1)
        numBg:setContentSize(CCSizeMake(numLabel:getContentSize().width+5,numLabel:getContentSize().height+4))

    end
end

function acThrivingSmallDialog:aboutDlbzCall( )

    local strSize2,strSize3,strSize4 = 22,23,24
    if not G_isAsia() then
        strSize2,strSize3,strSize4 = 20,20,21
    end
    local awardBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function() end)
    awardBg:setAnchorPoint(ccp(0.5,1))
    awardBg:setContentSize(CCSizeMake(self.dialogWidth-40,self.dialogHeight - 130))
    awardBg:setPosition(ccp(self.dialogWidth*0.5,self.dialogHeight - 30))
    self.bgLayer:addChild(awardBg)  

    local womanSp = CCSprite:createWithSpriteFrameName("charater_beautyGirl.png") --姑娘
    womanSp:setAnchorPoint(ccp(0, 1))
    womanSp:setPosition(-5, awardBg:getContentSize().height + 10)
    awardBg:addChild(womanSp,1)

    local awardBgWidth = awardBg:getContentSize().width
    local usePosx = awardBg:getContentSize().width * 0.35
    local useHeight = awardBg:getContentSize().height
    local rightWidth = awardBgWidth - usePosx
    
    local upTip = GetTTFLabelWrap(self.awardTb[3],strSize3,CCSize(rightWidth - 5,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    upTip:setAnchorPoint(ccp(0,1))
    upTip:setColor(G_ColorYellowPro2)
    upTip:setPosition(ccp(usePosx,useHeight - 20))
    awardBg:addChild(upTip) 

    local useIconSize = 80
    local awardIcon , scale = G_getItemIcon(self.awardTb[4],useIconSize,false,self.layerNum)
    awardBg:addChild(awardIcon)
    awardIcon:setAnchorPoint(ccp(0,1))
    awardIcon:setPosition(usePosx - 20,useHeight - 120)

    local iconSc = useIconSize / awardIcon:getContentSize().width
    local rightPosx2 = usePosx + 5 + iconSc * awardIcon:getContentSize().width
    local rightWidth2 = awardBgWidth - rightPosx2

    -- print("self.awardTb[4].name ----->>>>",self.awardTb[4].name)
    local titleLb=GetTTFLabelWrap(self.awardTb[4].name,strSize4,CCSizeMake(rightWidth2 - 10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
    titleLb:setColor(G_ColorYellowPro2)
    titleLb:setAnchorPoint(ccp(0,1))
    titleLb:setPosition(ccp(rightPosx2 -5,useHeight - 123))
    awardBg:addChild(titleLb,1)

    local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,0,1,32),function () end)
    nameBg:setContentSize(CCSizeMake(rightWidth2,titleLb:getContentSize().height + 6))
    nameBg:setAnchorPoint(ccp(0,1))
    nameBg:setPosition(rightPosx2 - 20,useHeight - 120)
    awardBg:addChild(nameBg)

    local awardNum = GetTTFLabel(getlocal("propInfoNum",{self.awardTb[4].num}),strSize2)
    awardNum:setAnchorPoint(ccp(0,1))
    awardNum:setPosition(rightPosx2 - 20,useHeight - 120 - nameBg:getContentSize().height - 15)
    awardBg:addChild(awardNum)

    local descStr2 = G_formatStr(self.awardTb[4])--self.awardTb[4].type == "p" and getlocal(self.awardTb[4].desc) or self.awardTb[4].desc

    local awardDesc = GetTTFLabelWrap(descStr2,strSize2,CCSizeMake(rightWidth2 - 10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
    awardDesc:setAnchorPoint(ccp(0,0))
    awardDesc:setPosition(usePosx,50)
    awardBg:addChild(awardDesc)

    if awardDesc:getContentSize().height > 70 then
        awardDesc:setPositionY(awardDesc:getPositionY() - 25)
    end

    local function closeCall()
        self:close()
        self.awardTb[5]()
    end
    local sureItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",closeCall,nil,getlocal("confirm"),34)
    sureItem:setAnchorPoint(ccp(0.5,1))
    sureItem:setScale(0.8)
    local sureBtn=CCMenu:createWithItem(sureItem)
    sureBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    sureBtn:setPosition(self.dialogWidth * 0.5,85)
    self.bgLayer:addChild(sureBtn)

end

function acThrivingSmallDialog:aboutKljzCall( )

    local descStr = GetTTFLabelWrap(self.awardTb[3],22,CCSize(self.dialogWidth-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)--GetTTFLabel(self.awardTb[3],22)
    descStr:setAnchorPoint(ccp(0,0.5))
    descStr:setPosition(ccp(30, self.awardTb[5] and self.dialogHeight*0.78 or self.dialogHeight*0.72))
    self.bgLayer:addChild(descStr)

    local posyScale =self.awardTb[5] and 0.55 or 0.45

    local awardBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
    awardBg:setContentSize(CCSizeMake(self.dialogWidth-40,self.dialogHeight*0.3))
    awardBg:setPosition(ccp(self.dialogWidth*0.5,self.dialogHeight*posyScale))
    self.bgLayer:addChild(awardBg)

    local cType = 0
    if self.awardTb[8] then
        cType = self.awardTb[8]
    end
    
    for k,v in pairs(self.awardTb[4]) do
        local function callback( )
            G_showNewPropInfo(self.layerNum+1,true,nil,nil,v,nil,nil,nil)
        end 
        local icon,scale=G_getItemIcon(v,85,false,self.layerNum,callback,nil)
        self.bgLayer:addChild(icon)
        icon:setTouchPriority(-(self.layerNum-1)*20-4)
        icon:setPosition(ccp(self.dialogWidth*0.2*k,self.dialogHeight*posyScale))

        local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function() end)
        numBg:setAnchorPoint(ccp(1,0))
        icon:addChild(numBg,1)
        numBg:setPosition(icon:getContentSize().width-5, 4)

        local numLabel=GetTTFLabel("x"..v.num,21)
        numLabel:setAnchorPoint(ccp(1,0))
        numLabel:setPosition(icon:getContentSize().width-5, 5)
        numLabel:setScale(1/scale)
        icon:addChild(numLabel,1)
        numBg:setContentSize(CCSizeMake(numLabel:getContentSize().width+23,numLabel:getContentSize().height+8))

        if cType > 0 then
            local colorName = acKljzVoApi:getFlickList()[cType][k]
            -- print("colorName=====>>>>",colorName)
            if colorName and colorName~="" then
                --flickerIdx: 黄色 y 3  蓝色 b 1  紫色 p 2 绿色 g 4
                local flickerIdxTb = {y=3,b=1,p=2,g=4}
                -- print("flickerIdxTb[colorName]=====>>>>",flickerIdxTb[colorName],colorName)
                local flickerPic = G_addRectFlicker2(icon,1.15,1.15,flickerIdxTb[colorName],colorName)
                flickerPic:setPosition(ccp(flickerPic:getPositionX(),flickerPic:getPositionY()-2))
            end
        end
    end

    local function rewardHandler( )
        if self.awardBtn then
            self.awardBtn:setEnabled(false)
        end
        if self.awardTb[6] then
            local showRewards = self.awardTb[6]
            local showReward = {}
            for m,n in pairs(showRewards) do
                -- print("mm-----nn------>>>>",m)
                local reward=FormatItem(n,nil,true) 
                table.insert(showReward,reward[1])
                -- print("reward.name---->>>>",reward[1].name)
                -- G_showRewardTip(reward,true)
            end
            G_showRewardTip(showReward,true)
            if self.awardTb[7] then
                self.awardTb[7]()
            end
            acKljzVoApi:sendRewardNotice(self.awardTb[8])
            self:close()
        end
    end 
    local buttonItem = GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",rewardHandler,nil,getlocal("daily_scene_get"),25,11)
    self.awardBtn = buttonItem
    local rewardMenu=CCMenu:createWithItem(buttonItem)
    rewardMenu:setPosition(ccp(self.dialogWidth*0.5,70))
    rewardMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(rewardMenu,2)
    local descStr = nil
    if self.awardTb[5] then
        self.awardBtn:setEnabled(true)
        local awardNum = SizeOfTable(self.awardTb[6])
        descStr = GetTTFLabelWrap(getlocal("activity_kljz_largeAwardStr2",{awardNum,self.awardTb[2],awardNum}),23,CCSize(self.dialogWidth-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)--GetTTFLabel(self.awardTb[3],22)

        descStr:setColor(G_ColorYellowPro)
        descStr:setAnchorPoint(ccp(0.5,0.5))
        descStr:setPosition(ccp(self.dialogWidth*0.5,140))
        self.bgLayer:addChild(descStr)
    else
        self.awardBtn:setEnabled(false)
        self.awardBtn:setVisible(false)
        -- descStr = GetTTFLabelWrap(getlocal("activity_kljz_largeAwardStr"),23,CCSize(self.dialogWidth-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)--GetTTFLabel(self.awardTb[3],22)
    end
end

function acThrivingSmallDialog:aboutSmcjTask( )
    local tvWidth,tvHeight = self.dialogWidth - 40 , self.dialogHeight - 180
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
    tvBg:setAnchorPoint(ccp(0.5,0))
    tvBg:setContentSize(CCSizeMake(tvWidth,tvHeight))
    tvBg:setPosition(ccp(self.dialogWidth*0.5,100))
    self.bgLayer:addChild(tvBg) 
    local cellHeight = 100
    local strSize2 = G_isAsia() and 20 or 18

    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return self.awardTb[4]
        elseif fn=="tableCellSizeForIndex" then
            return  CCSizeMake(tvWidth, cellHeight)
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            
            local awardTb = self.awardTb[3][idx + 1]
            local icon,scale = G_getItemIcon(awardTb,80,false,self.layerNum)
            cell:addChild(icon)
            icon:setAnchorPoint(ccp(0,1))
            icon:setPosition(10,cellHeight - 10)

            local numLb = GetTTFLabel("x" .. FormatNumber(awardTb.num),20)
            numLb:setAnchorPoint(ccp(1,0))
            icon:addChild(numLb,4)
            numLb:setPosition(icon:getContentSize().width-5, 5)
            numLb:setScale(1/scale)

            local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
            numBg:setAnchorPoint(ccp(1,0))
            numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-5))
            numBg:setPosition(ccp(icon:getContentSize().width-5,5))
            numBg:setOpacity(150)
            icon:addChild(numBg,3)

            local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,0,1,32),function () end)
            nameBg:setContentSize(CCSizeMake(350,28))
            nameBg:setAnchorPoint(ccp(0,1))
            nameBg:setPosition(100,cellHeight - 10)
            cell:addChild(nameBg)

            local titleLb = GetTTFLabel(awardTb.name,strSize2,true)
            titleLb:setAnchorPoint(ccp(0,0.5))
            titleLb:setColor(G_ColorYellowPro2)
            titleLb:setPosition(15,nameBg:getContentSize().height * 0.5)
            nameBg:addChild(titleLb)

            local descStr2 = G_formatStr(awardTb)
            local descLb = GetTTFLabelWrap(descStr2,strSize2 - 3,CCSizeMake(250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            descLb:setAnchorPoint(ccp(0,1))
            descLb:setPosition(100,cellHeight - 45)
            cell:addChild(descLb)

            local bottomLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)--modifiersLine2
            bottomLine:setContentSize(CCSizeMake(tvWidth - 10,bottomLine:getContentSize().height))
            bottomLine:setRotation(180)
            bottomLine:setPosition(ccp(tvWidth * 0.5, 0))
            cell:addChild(bottomLine,1)

            return cell
        end
    end
    local hd=LuaEventHandler:createHandler(tvCallBack)
    local tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth, tvHeight - 4),nil)
    tableView:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    tableView:setPosition(ccp(20,102))
    self.bgLayer:addChild(tableView,2)
    tableView:setMaxDisToBottomOrTop(100)
    self.tv = tableView

    local btnLb = getlocal("confirm")
    local isCan = false
    if self.awardTb[5] >= self.awardTb[6] then
        btnLb = getlocal("activity_hadReward")
        isCan = true
    end

    if isCan then
        local hadRewardLb = GetTTFLabel(btnLb,25,true)
        hadRewardLb:setAnchorPoint(ccp(0.5,0))
        hadRewardLb:setPosition(ccp(self.dialogWidth * 0.5, 40))
        -- hadRewardLb:setColor(G_ColorRed)
        self.bgLayer:addChild(hadRewardLb)
    else
        local function closeCall()
            self:close()
            
            if isCan then
                -- -- 用于领取积分奖励时候使用，加在自身背包中
                -- local function rewardSucCall( )
                --     for k,v in pairs(self.awardTb[3]) do
                --         print("v.name , v.num ====>>>",v.name,v.num)
                --         G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                --     end    
                --     G_showRewardTip(self.awardTb[3],true)
                --     self.awardTb[8]()
                -- end 
                -- acSmcjVoApi:socketWithScoreReward(self.awardTb[9],rewardSucCall)
            end
        end
        local sureItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",closeCall,nil,btnLb,34)
        sureItem:setAnchorPoint(ccp(0.5,1))
        sureItem:setScale(0.8)
        local sureBtn=CCMenu:createWithItem(sureItem)
        sureBtn:setTouchPriority(-(self.layerNum-1)*20-4)
        sureBtn:setPosition(self.dialogWidth * 0.5,80)
        self.bgLayer:addChild(sureBtn)
    end
end

function acThrivingSmallDialog:aboutSmcjDailyTask()
    local tvWidth,tvHeight = self.dialogWidth - 40 , self.dialogHeight - 210
    local canGetNum = GetTTFLabelWrap(getlocal("getPoint")..self.awardTb[12],22,CCSizeMake(350,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    canGetNum:setColor(G_ColorYellowPro2)
    canGetNum:setPosition(self.dialogWidth * 0.5, tvHeight + 20 + 100)
    self.bgLayer:addChild(canGetNum,1111)
    
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
    tvBg:setAnchorPoint(ccp(0.5,0))
    tvBg:setContentSize(CCSizeMake(tvWidth,tvHeight))
    tvBg:setPosition(ccp(self.dialogWidth*0.5,100))
    self.bgLayer:addChild(tvBg) 
    local cellHeight = 100
    local strSize2 = G_isAsia() and 20 or 18

    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return self.awardTb[4]
        elseif fn=="tableCellSizeForIndex" then
            return  CCSizeMake(tvWidth, cellHeight)
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            
            local awardTb = self.awardTb[3][idx + 1]
            local icon,scale = G_getItemIcon(awardTb,80,false,self.layerNum)
            cell:addChild(icon)
            icon:setAnchorPoint(ccp(0,1))
            icon:setPosition(10,cellHeight - 10)

            local numLb = GetTTFLabel("x" .. FormatNumber(awardTb.num),20)
            numLb:setAnchorPoint(ccp(1,0))
            icon:addChild(numLb,4)
            numLb:setPosition(icon:getContentSize().width-5, 5)
            numLb:setScale(1/scale)

            local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
            numBg:setAnchorPoint(ccp(1,0))
            numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-5))
            numBg:setPosition(ccp(icon:getContentSize().width-5,5))
            numBg:setOpacity(150)
            icon:addChild(numBg,3)

            local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,0,1,32),function () end)
            nameBg:setContentSize(CCSizeMake(350,28))
            nameBg:setAnchorPoint(ccp(0,1))
            nameBg:setPosition(100,cellHeight - 10)
            cell:addChild(nameBg)

            local titleLb = GetTTFLabel(awardTb.name,strSize2,true)
            titleLb:setAnchorPoint(ccp(0,0.5))
            titleLb:setColor(G_ColorYellowPro2)
            titleLb:setPosition(15,nameBg:getContentSize().height * 0.5)
            nameBg:addChild(titleLb)

            local descStr2 = G_formatStr(awardTb)
            local descLb = GetTTFLabelWrap(descStr2,strSize2 - 3,CCSizeMake(250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            descLb:setAnchorPoint(ccp(0,1))
            descLb:setPosition(100,cellHeight - 45)
            cell:addChild(descLb)

            local bottomLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)--modifiersLine2
            bottomLine:setContentSize(CCSizeMake(tvWidth - 10,bottomLine:getContentSize().height))
            bottomLine:setRotation(180)
            bottomLine:setPosition(ccp(tvWidth * 0.5, 0))
            cell:addChild(bottomLine,1)

            return cell
        end
    end
    local hd=LuaEventHandler:createHandler(tvCallBack)
    local tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth, tvHeight - 4),nil)
    tableView:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    tableView:setPosition(ccp(20,102))
    self.bgLayer:addChild(tableView,2)
    tableView:setMaxDisToBottomOrTop(100)
    self.tv = tableView

    local btnLb = getlocal("confirm")
    local isCan = false
    if self.awardTb[5] >= self.awardTb[6] then
        btnLb = getlocal("activity_hadReward")
        isCan = true
    end
    if isCan then
        local hadRewardLb = GetTTFLabel(btnLb,25,true)
        hadRewardLb:setAnchorPoint(ccp(0.5,0))
        hadRewardLb:setPosition(ccp(self.dialogWidth * 0.5, 40))
        -- hadRewardLb:setColor(G_ColorRed)
        self.bgLayer:addChild(hadRewardLb)
    else
        local function closeCall()
            self:close()
            
            if isCan then
                -- 用于领取积分奖励时候使用，加在自身背包中
                -- local function rewardSucCall( )
                --     for k,v in pairs(self.awardTb[3]) do
                --         print("v.name , v.num ====>>>",v.name,v.num)
                --         G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                --     end    
                --     G_showRewardTip(self.awardTb[3],true)
                --     self.awardTb[8]()
                -- end 
                -- acSmcjVoApi:socketWithDailyTaskReward(self.awardTb[10],self.awardTb[9],rewardSucCall)
            end
        end
        local sureItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",closeCall,nil,btnLb,34)
        sureItem:setAnchorPoint(ccp(0.5,1))
        sureItem:setScale(0.8)
        local sureBtn=CCMenu:createWithItem(sureItem)
        sureBtn:setTouchPriority(-(self.layerNum-1)*20-4)
        sureBtn:setPosition(self.dialogWidth * 0.5,80)
        self.bgLayer:addChild(sureBtn)
    end

end

function acThrivingSmallDialog:aboutSmcjRecharge( )
    local tvWidth,tvHeight = self.dialogWidth - 40 , self.dialogHeight - 180
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
    tvBg:setAnchorPoint(ccp(0.5,0))
    tvBg:setContentSize(CCSizeMake(tvWidth,tvHeight))
    tvBg:setPosition(ccp(self.dialogWidth*0.5,100))
    self.bgLayer:addChild(tvBg) 
    local cellHeight = 100
    local strSize2 = G_isAsia() and 20 or 18

    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return self.awardTb[4]
        elseif fn=="tableCellSizeForIndex" then
            return  CCSizeMake(tvWidth, cellHeight)
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            
            local awardTb = self.awardTb[3][idx + 1]
            local icon,scale = G_getItemIcon(awardTb,80,false,self.layerNum)
            cell:addChild(icon)
            icon:setAnchorPoint(ccp(0,1))
            icon:setPosition(10,cellHeight - 10)

            local numLb = GetTTFLabel("x" .. FormatNumber(awardTb.num),20)
            numLb:setAnchorPoint(ccp(1,0))
            icon:addChild(numLb,4)
            numLb:setPosition(icon:getContentSize().width-5, 5)
            numLb:setScale(1/scale)

            local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
            numBg:setAnchorPoint(ccp(1,0))
            numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-5))
            numBg:setPosition(ccp(icon:getContentSize().width-5,5))
            numBg:setOpacity(150)
            icon:addChild(numBg,3)

            local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,0,1,32),function () end)
            nameBg:setContentSize(CCSizeMake(350,28))
            nameBg:setAnchorPoint(ccp(0,1))
            nameBg:setPosition(100,cellHeight - 10)
            cell:addChild(nameBg)

            local titleLb = GetTTFLabel(awardTb.name,strSize2,true)
            titleLb:setAnchorPoint(ccp(0,0.5))
            titleLb:setColor(G_ColorYellowPro2)
            titleLb:setPosition(15,nameBg:getContentSize().height * 0.5)
            nameBg:addChild(titleLb)

            local descStr2 = G_formatStr(awardTb)
            local descLb = GetTTFLabelWrap(descStr2,strSize2 - 3,CCSizeMake(250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            descLb:setAnchorPoint(ccp(0,1))
            descLb:setPosition(100,cellHeight - 45)
            cell:addChild(descLb)

            local bottomLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)--modifiersLine2
            bottomLine:setContentSize(CCSizeMake(tvWidth - 10,bottomLine:getContentSize().height))
            bottomLine:setRotation(180)
            bottomLine:setPosition(ccp(tvWidth * 0.5, 0))
            cell:addChild(bottomLine,1)

            return cell
        end
    end
    local hd=LuaEventHandler:createHandler(tvCallBack)
    local tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth, tvHeight - 4),nil)
    tableView:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    tableView:setPosition(ccp(20,102))
    self.bgLayer:addChild(tableView,2)
    tableView:setMaxDisToBottomOrTop(100)
    self.tv = tableView

    local btnLb = getlocal("confirm")
    local isCan = false
    if self.awardTb[10] > 0 and self.awardTb[7] < self.awardTb[10] then
        btnLb = getlocal("daily_scene_get")
        isCan = true
    end

    local function closeCall()
        self:close()
        
        if isCan then
            -- 用于领取积分奖励时候使用，加在自身背包中
            -- local function rewardSucCall( )
            --     for k,v in pairs(self.awardTb[3]) do
            --         print("v.name , v.num ====>>>",v.name,v.num)
            --         G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
            --     end    
            --     G_showRewardTip(self.awardTb[3],true)
            --     self.awardTb[8]()
            -- end 
            -- acSmcjVoApi:socketWithDailyRechargeReward(rewardSucCall)
        end
    end
    local sureItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",closeCall,nil,btnLb,34)
    sureItem:setAnchorPoint(ccp(0.5,1))
    sureItem:setScale(0.8)
    local sureBtn=CCMenu:createWithItem(sureItem)
    sureBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    sureBtn:setPosition(self.dialogWidth * 0.5,80)
    self.bgLayer:addChild(sureBtn)
end

function acThrivingSmallDialog:aboutNewSignAddUpAwardCall()
    local useCurTime = base.serverTime
    local tvWidth,tvHeight = self.dialogWidth - 40 , self.dialogHeight - 180
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
    tvBg:setAnchorPoint(ccp(0.5,0))
    tvBg:setContentSize(CCSizeMake(tvWidth,tvHeight))
    tvBg:setPosition(ccp(self.dialogWidth*0.5,100))
    self.bgLayer:addChild(tvBg) 
    local cellHeight = 100
    local strSize2 = G_isAsia() and 20 or 18

    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return self.awardTb[4]
        elseif fn=="tableCellSizeForIndex" then
            return  CCSizeMake(tvWidth, cellHeight)
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            
            local awardTb = self.awardTb[3][idx + 1]
            local icon,scale = G_getItemIcon(awardTb,80,false,self.layerNum)
            cell:addChild(icon)
            icon:setAnchorPoint(ccp(0,1))
            icon:setPosition(10,cellHeight - 10)
            local numLb = GetTTFLabel("x" .. FormatNumber(awardTb.num),20)
            numLb:setAnchorPoint(ccp(1,0))
            icon:addChild(numLb,4)
            numLb:setPosition(icon:getContentSize().width-5, 5)
            numLb:setScale(1/scale)

            local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
            numBg:setAnchorPoint(ccp(1,0))
            numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-5))
            numBg:setPosition(ccp(icon:getContentSize().width-5,5))
            numBg:setOpacity(150)
            icon:addChild(numBg,3)

            local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,0,1,32),function () end)
            nameBg:setContentSize(CCSizeMake(350,28))
            nameBg:setAnchorPoint(ccp(0,1))
            nameBg:setPosition(100,cellHeight - 10)
            cell:addChild(nameBg)

            local titleLb = GetTTFLabel(awardTb.name,strSize2,true)
            titleLb:setAnchorPoint(ccp(0,0.5))
            titleLb:setColor(G_ColorYellowPro2)
            titleLb:setPosition(15,nameBg:getContentSize().height * 0.5)
            nameBg:addChild(titleLb)

            local descStr2 = G_formatStr(awardTb)
            local descLb = GetTTFLabelWrap(descStr2,strSize2 - 3,CCSizeMake(380,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            descLb:setAnchorPoint(ccp(0,1))
            descLb:setPosition(100,cellHeight - 45)
            cell:addChild(descLb)

            local bottomLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)--modifiersLine2
            bottomLine:setContentSize(CCSizeMake(tvWidth - 10,bottomLine:getContentSize().height))
            bottomLine:setRotation(180)
            bottomLine:setPosition(ccp(tvWidth * 0.5, 0))
            cell:addChild(bottomLine,1)

            return cell
        end
    end
    local hd=LuaEventHandler:createHandler(tvCallBack)
    local tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth, tvHeight - 4),nil)
    tableView:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    tableView:setPosition(ccp(20,102))
    self.bgLayer:addChild(tableView,2)
    tableView:setMaxDisToBottomOrTop(100)
    self.tv = tableView

    local btnLb = getlocal("confirm")
    local isCan = false
    if self.awardTb[7] == 2 then
        btnLb = getlocal("daily_scene_get")
        isCan = true
    elseif self.awardTb[7] == 3 then
        btnLb = getlocal("activity_hadReward")
    end

    if self.awardTb[7] == 3 then
        local hadRewardLb = GetTTFLabel(btnLb,25,true)
        hadRewardLb:setAnchorPoint(ccp(0.5,0))
        hadRewardLb:setPosition(ccp(self.dialogWidth * 0.5, 40))
        -- hadRewardLb:setColor(G_ColorRed)
        self.bgLayer:addChild(hadRewardLb)
    else
        local function closeCall()
            self:close()
            
            if isCan then
                -- -- 用于领取积分奖励时候使用，加在自身背包中
                -- local function rewardSucCall( )
                --     for k,v in pairs(self.awardTb[3]) do
                --         print("v.name , v.num ====>>>",v.name,v.num)
                --         G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                --     end    
                --     G_showRewardTip(self.awardTb[3],true)
                --     self.awardTb[8]()
                -- end 
                -- acSmcjVoApi:socketWithScoreReward(self.awardTb[9],rewardSucCall)

                local function callBack( )
                    local playerHonors =playerVoApi:getHonors() --用户当前的总声望值
                    local maxLevel =playerVoApi:getMaxLvByKey("roleMaxLevel") --当前服 最大等级
                    local honTb =Split(playerCfg.honors,",")
                    local maxHonors =honTb[maxLevel] --当前服 最大声望值

                    --vip特权，奖励翻倍
                    -- local vipPrivilegeSwitch=base.vipPrivilegeSwitch
                    local rewardPercent=1
                    -- if(vipPrivilegeSwitch and vipPrivilegeSwitch.vsr==1)then
                    --     if(playerCfg.vipRelatedCfg and playerCfg.vipRelatedCfg.dailySign and playerCfg.vipRelatedCfg.dailySign[2] and playerVoApi:getVipLevel()>=playerCfg.vipRelatedCfg.dailySign[1])then
                    --         rewardPercent=playerCfg.vipRelatedCfg.dailySign[2]
                    --     end
                    -- end

                    for k,v in pairs(self.awardTb[3]) do
                        -- print("v.name , v.num ====>>>",v.name,v.num)
                        if v.key=="honors" then
                            if base.isConvertGems==1 and tonumber(playerHonors) >=tonumber(maxHonors) then
                                local gems = playerVoApi:convertGems(2,tonumber(playerVoApi:getRankDailyHonor(playerVoApi:getRank()))*rewardPercent)
                                playerVoApi:setValue("gold",playerVoApi:getGold()+gems)
                            else            
                                playerVoApi:setValue("honors",playerVoApi:getHonors()+tonumber(playerVoApi:getRankDailyHonor(playerVoApi:getRank()))*rewardPercent)
                            end
                        end
                        if v.key=="gems" then
                            playerVoApi:setValue("gems",playerVoApi:getGems()+tonumber(v.num)*rewardPercent)
                        end
                        if v.id and v.id>0 then
                            G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                        end
                    end    
                    if self.awardTb[6] then
                        self.awardTb[6]()
                    end
                end
                newSignInVoApi:SocketCall(callBack,"getreward",self.awardTb[5],useCurTime)

                
            end
        end
        local sureItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",closeCall,nil,btnLb,34)
        sureItem:setAnchorPoint(ccp(0.5,1))
        sureItem:setScale(0.8)
        local sureBtn=CCMenu:createWithItem(sureItem)
        sureBtn:setTouchPriority(-(self.layerNum-1)*20-4)
        sureBtn:setPosition(self.dialogWidth * 0.5,80)
        self.bgLayer:addChild(sureBtn)
    end
end

function acThrivingSmallDialog:aboutNewSignCheckInCall( )
    local useCurTime = base.serverTime
    local tvWidth,tvHeight = self.dialogWidth - 40 , self.dialogHeight - 180
    if self.awardTb[8] then
        tvHeight = tvHeight - 40
        local topTip = GetTTFLabelWrap(getlocal("doubleTip"),G_isAsia() and 23 or 19,CCSizeMake(tvWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        topTip:setPosition(self.dialogWidth * 0.5,self.dialogHeight -90)
        self.bgLayer:addChild(topTip)

    end

    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
    tvBg:setAnchorPoint(ccp(0.5,0))
    tvBg:setContentSize(CCSizeMake(tvWidth,tvHeight))
    tvBg:setIsSallow(false)
    tvBg:setPosition(ccp(self.dialogWidth*0.5,100))
    self.bgLayer:addChild(tvBg) 
    local cellHeight = 100
    local strSize2 = G_isAsia() and 20 or 18

    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return self.awardTb[4]
        elseif fn=="tableCellSizeForIndex" then
            return  CCSizeMake(tvWidth, cellHeight)
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            
            local awardTb = self.awardTb[3][idx + 1]
            local icon,scale = G_getItemIcon(awardTb,80,false,self.layerNum)
            cell:addChild(icon)
            icon:setAnchorPoint(ccp(0,1))
            icon:setPosition(10,cellHeight - 10)
            local realNum = self.awardTb[8] and awardTb.num * 2 or awardTb.num
            local numLb = GetTTFLabel("x" .. FormatNumber(realNum),20)
            numLb:setAnchorPoint(ccp(1,0))
            icon:addChild(numLb,4)
            numLb:setPosition(icon:getContentSize().width-5, 5)
            numLb:setScale(1/scale)

            local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
            numBg:setAnchorPoint(ccp(1,0))
            numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-5))
            numBg:setPosition(ccp(icon:getContentSize().width-5,5))
            numBg:setOpacity(150)
            icon:addChild(numBg,3)

            local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,0,1,32),function () end)
            nameBg:setContentSize(CCSizeMake(350,28))
            nameBg:setAnchorPoint(ccp(0,1))
            nameBg:setPosition(100,cellHeight - 10)
            cell:addChild(nameBg)

            local titleLb = GetTTFLabel(awardTb.name,strSize2,true)
            titleLb:setAnchorPoint(ccp(0,0.5))
            titleLb:setColor(G_ColorYellowPro2)
            titleLb:setPosition(15,nameBg:getContentSize().height * 0.5)
            nameBg:addChild(titleLb)

            local descStr2 = G_formatStr(awardTb)
            local descLb = GetTTFLabelWrap(descStr2,strSize2 - 3,CCSizeMake(380,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            descLb:setAnchorPoint(ccp(0,1))
            descLb:setPosition(100,cellHeight - 45)
            cell:addChild(descLb)

            local bottomLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)--modifiersLine2
            bottomLine:setContentSize(CCSizeMake(tvWidth - 10,bottomLine:getContentSize().height))
            bottomLine:setRotation(180)
            bottomLine:setPosition(ccp(tvWidth * 0.5, 0))
            cell:addChild(bottomLine,1)

            return cell
        end
    end
    local hd=LuaEventHandler:createHandler(tvCallBack)
    local tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth, tvHeight - 4),nil)
    tableView:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    tableView:setPosition(ccp(20,102))
    -- tableView:setIsSallow(false)
    self.bgLayer:addChild(tableView,2)
    tableView:setMaxDisToBottomOrTop(100)
    self.tv = tableView

    local btnLb = getlocal("confirm")
    local isCan = false
    if self.awardTb[7] == 2 then
        btnLb = getlocal("daily_scene_get")
        isCan = true
    elseif self.awardTb[7] == 3 then
        btnLb = getlocal("activity_hadReward")
    end
    local beishu = self.awardTb[8] and 2 or 1

    if self.awardTb[7] == 3 then
        local hadRewardLb = GetTTFLabel(btnLb,25,true)
        hadRewardLb:setAnchorPoint(ccp(0.5,0))
        hadRewardLb:setPosition(ccp(self.dialogWidth * 0.5, 40))
        -- hadRewardLb:setColor(G_ColorRed)
        self.bgLayer:addChild(hadRewardLb)
    else
        local function closeCall()
            self:close()
            
            if isCan then
                -- -- 用于领取积分奖励时候使用，加在自身背包中
                -- local function rewardSucCall( )
                --     for k,v in pairs(self.awardTb[3]) do
                --         print("v.name , v.num ====>>>",v.name,v.num)
                --         G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                --     end    
                --     G_showRewardTip(self.awardTb[3],true)
                --     self.awardTb[8]()
                -- end 
                -- acSmcjVoApi:socketWithScoreReward(self.awardTb[9],rewardSucCall)

                local function callBack( )
                    local playerHonors =playerVoApi:getHonors() --用户当前的总声望值
                    local maxLevel =playerVoApi:getMaxLvByKey("roleMaxLevel") --当前服 最大等级
                    local honTb =Split(playerCfg.honors,",")
                    local maxHonors =honTb[maxLevel] --当前服 最大声望值

                    --vip特权，奖励翻倍
                    -- local vipPrivilegeSwitch=base.vipPrivilegeSwitch
                    local rewardPercent=1
                    -- if(vipPrivilegeSwitch and vipPrivilegeSwitch.vsr==1)then
                    --     if(playerCfg.vipRelatedCfg and playerCfg.vipRelatedCfg.dailySign and playerCfg.vipRelatedCfg.dailySign[2] and playerVoApi:getVipLevel()>=playerCfg.vipRelatedCfg.dailySign[1])then
                    --         rewardPercent=playerCfg.vipRelatedCfg.dailySign[2]
                    --     end
                    -- end

                    for k,v in pairs(self.awardTb[3]) do
                        -- print("v.name , v.num ====>>>",v.name,v.num)
                        if v.key=="honors" then
                            if base.isConvertGems==1 and tonumber(playerHonors) >=tonumber(maxHonors) then
                                local gems = playerVoApi:convertGems(2,tonumber(playerVoApi:getRankDailyHonor(playerVoApi:getRank()))*rewardPercent)
                                playerVoApi:setValue("gold",playerVoApi:getGold()+gems * beishu)
                            else            
                                playerVoApi:setValue("honors",playerVoApi:getHonors()+tonumber(playerVoApi:getRankDailyHonor(playerVoApi:getRank()))*rewardPercent * beishu)
                            end
                        end
                        if v.key=="gems" then
                            -- print("gems---->>>",playerVoApi:getGems(),tonumber(v.num),rewardPercent , beishu)
                            playerVoApi:setValue("gems",playerVoApi:getGems()+tonumber(v.num)*rewardPercent * beishu)
                        end
                        if v.id and v.id>0 then
                            -- print("v.key-->>",v.num,beishu)
                            G_addPlayerAward(v.type,v.key,v.id,v.num * beishu,nil,true)
                        end
                    end    
                    if self.awardTb[6] then
                        self.awardTb[6]()
                    end
                end
                newSignInVoApi:SocketCall(callBack,"sign",nil,useCurTime)

                
            end
        end
        local sureItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",closeCall,nil,btnLb,34)
        sureItem:setAnchorPoint(ccp(0.5,1))
        sureItem:setScale(0.8)
        local sureBtn=CCMenu:createWithItem(sureItem)
        sureBtn:setTouchPriority(-(self.layerNum-1)*20-4)
        sureBtn:setPosition(self.dialogWidth * 0.5,80)
        self.bgLayer:addChild(sureBtn)
    end
end

function acThrivingSmallDialog:aboutAllianceInfoNow( )
    local tvWidth,tvHeight = self.dialogWidth - 40 , self.dialogHeight - 180
    local cellHeight = 70
    local tipHeight = 0
    if self.awardTb[3] then
        tvHeight = tvHeight - 40
        local topTip = GetTTFLabelWrap(self.awardTb[3],G_isAsia() and 22 or 17,CCSizeMake(tvWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        topTip:setPosition(self.dialogWidth * 0.5,self.dialogHeight -90)
        self.bgLayer:addChild(topTip)
        topTip:setColor(G_ColorYellowPro2)
        tipHeight = topTip:getContentSize().height
    end

    local wholeBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("ltzdzNameBg.png",CCRect(4, 4, 1, 1),function () end)
    wholeBgSp:setContentSize(CCSizeMake(tvWidth,40))
    wholeBgSp:setAnchorPoint(ccp(0.5,1))
    wholeBgSp:setPosition(ccp(self.dialogWidth * 0.5,self.dialogHeight -90 - tipHeight - 5))
    self.bgLayer:addChild(wholeBgSp)

    local height=tvHeight
    local lbSize=22
    local widthSpaceTb={60,60 + 120, 70 + 240, 90 + 350}
    local titleStrTb = {getlocal("alliance_scene_rank_title"),
                        getlocal("alliance_scene_alliance_name_title"),
                        getlocal("alliance_scene_alliance_power_title"),
                        getlocal("alliance_scene_member_num")}
    for k,v in pairs(titleStrTb) do
        local titleLb = GetTTFLabel(v,lbSize,true)
        titleLb:setPosition(widthSpaceTb[k],20)
        wholeBgSp:addChild(titleLb)
    end
    local teamTb = self.awardTb[4] or nil


     local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            local num = 0
            if teamTb then
                num = SizeOfTable(teamTb)
            else
                num = SizeOfTable(allianceVoApi:getRankOrGoodList())
                if num > 10 then
                    num = 10
                end
            end
            return num
        elseif fn=="tableCellSizeForIndex" then
            return  CCSizeMake(tvWidth, cellHeight)
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            
            local grayBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("newListItemBg.png",CCRect(4,4,1,1),function ()end)
            grayBgSp:setContentSize(CCSizeMake(tvWidth,cellHeight))
            grayBgSp:setAnchorPoint(ccp(0.5,1))
            grayBgSp:setPosition(ccp(tvWidth * 0.5,cellHeight))
            cell:addChild(grayBgSp) 
            if (idx+1)%2 == 1 then
              grayBgSp:setOpacity(0)
            end

            if idx < serverWarLocalVoApi:getThisServersTeamNum() then
                local cellBg = LuaCCScale9Sprite:createWithSpriteFrameName("exer_lightYellowFrame.png", CCRect(3, 10, 1, 1), function()end)
                cellBg:setContentSize(CCSizeMake(tvWidth - 4, cellHeight - 4))
                cellBg:setPosition(tvWidth * 0.5,cellHeight * 0.5)
                cell:addChild(cellBg)

            end

            local rankStr=0
            local nameStr=""
            local numStr=0
            local valueStr=0

            local allianceVo = allianceVoApi:getRankOrGoodList()[idx + 1]
            
            if teamTb then
                rankStr  = idx + 1
                nameStr  = teamTb[rankStr][2] or ""
                numStr   = tonumber(teamTb[rankStr][4]) or 0
                valueStr = tonumber(teamTb[rankStr][3]) or 0 
            elseif allianceVo then
                rankStr  = allianceVo.rank or 0
                nameStr  = allianceVo.name or ""
                numStr   = allianceVo.num or 0
                valueStr = allianceVo.fight or 0
            end

            local rankLabel=GetTTFLabel(rankStr,25)
            rankLabel:setAnchorPoint(ccp(0.5,0.5))
            rankLabel:setPosition(widthSpaceTb[1],cellHeight * 0.5)
            cell:addChild(rankLabel,2)
            
            local rankSp
            if tonumber(rankStr) < 3 then
              rankSp=CCSprite:createWithSpriteFrameName("top"..tonumber(rankStr)..".png")
            end
            if rankSp then
              rankSp:setAnchorPoint(ccp(0.5,0.5))
                  rankSp:setPosition(ccp(widthSpaceTb[1],cellHeight * 0.5))
              cell:addChild(rankSp,3)
              rankLabel:setVisible(false)
            end

            local nameLabel=GetTTFLabel(nameStr,25)
            nameLabel:setAnchorPoint(ccp(0.5,0.5))
            nameLabel:setPosition(widthSpaceTb[2],cellHeight * 0.5)
            cell:addChild(nameLabel,2)

            local valueLabel=GetTTFLabel(FormatNumber(valueStr),25)
            valueLabel:setAnchorPoint(ccp(0.5,0.5))
            valueLabel:setPosition(widthSpaceTb[3],cellHeight * 0.5)
            cell:addChild(valueLabel,2)

            local numberLb = GetTTFLabel(numStr,22)
            numberLb:setPosition(widthSpaceTb[4],cellHeight * 0.5)
            cell:addChild(numberLb,2)

            return cell
        end
    end
    local hd=LuaEventHandler:createHandler(tvCallBack)
    local tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth, tvHeight - 44 + 80),nil)
    tableView:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    tableView:setPosition(ccp(20,22))
    -- tableView:setIsSallow(false)
    self.bgLayer:addChild(tableView,2)
    tableView:setMaxDisToBottomOrTop(100)
    self.tv = tableView

end

function acThrivingSmallDialog:aboutHljbExchangeCall()

    local strSize2,strSize3,strSize4 = 22,23,24
    if not G_isAsia() then
        strSize2,strSize3,strSize4 = 20,20,21
    end

    local awardData = self.awardTb[3]
    local awardTb = awardData.reward
    local order = awardData.order
    local limit = awardData.limit
    local price = awardData.price
    local hadExNum = awardData.hadExNum or 0

    local curPoint = acHljbVoApi:getCurPoint( )
    -- print("limit * price / curPoint----->>>>",limit * price, curPoint, limit * price / curPoint)
    local curLarNum = limit--math.floor(limit * price / curPoint) --最大兑换次数

    if curPoint > limit * price then
        curLarNum = limit - hadExNum
    elseif curPoint >= price then
        curLarNum = math.floor(curPoint / price)
    end

    local awardBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function() end)
    awardBg:setAnchorPoint(ccp(0.5,1))
    awardBg:setContentSize(CCSizeMake(self.dialogWidth-40,self.dialogHeight - 130))
    awardBg:setPosition(ccp(self.dialogWidth*0.5,self.dialogHeight - 30))
    self.bgLayer:addChild(awardBg) 

    local awardBgWidth = awardBg:getContentSize().width
    local usePosx = awardBg:getContentSize().width * 0.03
    local useHeight = awardBg:getContentSize().height

    if true then
        local icon,scale = G_getItemIcon(awardTb,90,false,self.layerNum)
        awardBg:addChild(icon)
        icon:setAnchorPoint(ccp(0,0.5))
        icon:setPosition(usePosx,useHeight - 60)

        local rightPosy = icon:getPositionY() + icon:getContentSize().height * 0.5 * scale

        local numLb = GetTTFLabel("x" .. FormatNumber(awardTb.num),20)
        numLb:setAnchorPoint(ccp(1,0))
        icon:addChild(numLb,4)
        numLb:setPosition(icon:getContentSize().width-5, 5)
        numLb:setScale(1/scale)

        local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
        numBg:setAnchorPoint(ccp(1,0))
        numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-5))
        numBg:setPosition(ccp(icon:getContentSize().width-5,5))
        numBg:setOpacity(150)
        icon:addChild(numBg,3)

        local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,0,1,32),function () end)
        nameBg:setContentSize(CCSizeMake(350,28))
        nameBg:setAnchorPoint(ccp(0,1))
        nameBg:setPosition(usePosx + 105 ,rightPosy)
        awardBg:addChild(nameBg)

        local titleLb = GetTTFLabel(awardTb.name,strSize2,true)
        titleLb:setAnchorPoint(ccp(0,0.5))
        titleLb:setColor(G_ColorYellowPro2)
        titleLb:setPosition(15,nameBg:getContentSize().height * 0.5)
        nameBg:addChild(titleLb)

        local descStr2 = G_formatStr(awardTb)
        local descLb = GetTTFLabelWrap(descStr2,strSize2 - 3,CCSizeMake(380,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        descLb:setAnchorPoint(ccp(0,1))
        descLb:setPosition(usePosx + 105 ,rightPosy - 40)
        awardBg:addChild(descLb)
    end

    local m_numLb=GetTTFLabel(" ",30)
    awardBg:addChild(m_numLb,2);

    local function sliderTouch(handler,object)
          -- local valueNum = tonumber(string.format("%.2f", object:getValue()))
          local count = math.ceil(object:getValue())
          self.count = count
          -- print("count====>>>>>",count)
          if count >= 0 then
              m_numLb:setString(count)
          end  

          if self.curNumLb then
                self.curNumLb:setString(self.count)
          end

          if self.curPointLb then
                self.curPointLb:setString(self.count * price)
          end
    end
    local sliderScale = 0.8
    local spBg =CCSprite:createWithSpriteFrameName("proBar_n2.png");
    local spPr =CCSprite:createWithSpriteFrameName("proBar_n1.png");
    local spPr1 =CCSprite:createWithSpriteFrameName("grayBarBtn.png");--ProduceTankIconSlide
    self.slider = LuaCCControlSlider:create(spBg,spPr,spPr1,sliderTouch);
    self.slider:setTouchPriority(-(self.layerNum-1)*20-5);
    self.slider:setIsSallow(true);
    self.slider:setScaleX(sliderScale)
    
    self.slider:setMinimumValue(1.0);

    self.slider:setTag(99)
    awardBg:addChild(self.slider,2)
    m_numLb:setString(math.ceil(self.slider:getValue()))
    self.m_numLb=m_numLb

    local bgSp = CCSprite:createWithSpriteFrameName("proBar_n2.png");
    bgSp:setScaleX(85/bgSp:getContentSize().width)
    bgSp:setAnchorPoint(ccp(0.5,0.5));
    awardBg:addChild(bgSp,1);


    local function touchAdd()
       self.slider:setValue(self.slider:getValue()+1);
    end

    local function touchMinus()
      if self.slider:getValue()-1>0 then
          self.slider:setValue(self.slider:getValue()-1);
      end
    end

    local addSp=LuaCCSprite:createWithSpriteFrameName("greenPlus.png",touchAdd)
    awardBg:addChild(addSp,1)
    addSp:setTouchPriority(-(self.layerNum-1)*20-5);

    local minusSp=LuaCCSprite:createWithSpriteFrameName("greenMinus.png",touchMinus)
    awardBg:addChild(minusSp,1)
    minusSp:setTouchPriority(-(self.layerNum-1)*20-5);

    local sliderAddPosx2 = 35

    self.slider:setPosition(ccp(340 * sliderScale + sliderAddPosx2,55))
    bgSp:setPosition(60,55);
    m_numLb:setPosition(60,55);
    addSp:setPosition(ccp(560 * sliderScale + sliderAddPosx2,55))
    minusSp:setPosition(ccp(125 * sliderScale + sliderAddPosx2,55))
    
    print("curLarNum--->>>",curLarNum)
    self.slider:setMaximumValue(curLarNum);
    self.slider:setValue(1);
    self.count = 1


    local curNumStrLb = GetTTFLabel(getlocal("activity_qxtw_need"),22)
    curNumStrLb:setAnchorPoint(ccp(1,0.5))
    curNumStrLb:setPosition(awardBgWidth * 0.33,110)
    awardBg:addChild(curNumStrLb)

    local curNumLb = GetTTFLabel(self.count,22)
    curNumLb:setAnchorPoint(ccp(0,0.5))
    curNumLb:setPosition(awardBgWidth * 0.33,110)
    awardBg:addChild(curNumLb)
    self.curNumLb = curNumLb

    local curPointStrLb = GetTTFLabel(getlocal("serverwar_point").."：",22)
    curPointStrLb:setAnchorPoint(ccp(1,0.5))
    curPointStrLb:setPosition(awardBgWidth * 0.67 + 40,110)
    awardBg:addChild(curPointStrLb)

    local curPointLb = GetTTFLabel(self.count * price,22)
    curPointLb:setAnchorPoint(ccp(0,0.5))
    curPointLb:setPosition(awardBgWidth * 0.67 + 40,110)
    awardBg:addChild(curPointLb)
    self.curPointLb = curPointLb

    local function SureCall()
        if curPoint < price * self.count then
            acHljbVoApi:showbtnTip(getlocal"activity_smbd_prompt")
            do return end
        end

        local function socketSuccCall()
            local getAwardTb = G_clone(awardTb)
            getAwardTb.num   = self.count * getAwardTb.num
            self:close()
            self.awardTb[4](getAwardTb)
        end
        acHljbVoApi:exchangeSocket(order,self.count,socketSuccCall)
    end
    local sureItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",SureCall,nil,getlocal("confirm"),34)
    sureItem:setAnchorPoint(ccp(0.5,1))
    sureItem:setScale(0.8)
    local sureBtn=CCMenu:createWithItem(sureItem)
    sureBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    sureBtn:setPosition(self.dialogWidth*0.74,80)
    self.bgLayer:addChild(sureBtn)


    local function closeCall()
            self:close()
            -- self.awardTb[4]()
    end
    local cancelItem=GetButtonItem("newGrayBtn.png","newGrayBtn_Down.png","newGrayBtn_Down.png",closeCall,nil,getlocal("cancel"),34)
    cancelItem:setAnchorPoint(ccp(0.5,1))
    cancelItem:setScale(0.8)
    local cancelBtn=CCMenu:createWithItem(cancelItem)
    cancelBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    cancelBtn:setPosition(self.dialogWidth*0.26,80)
    self.bgLayer:addChild(cancelBtn)
end

function acThrivingSmallDialog:aboutHljbTakeCall()
    local strSize2,strSize3,strSize4 = 22,22,24
    if not G_isAsia() then
        strSize2,strSize3,strSize4 = 20,18,21
    end

    local upTip = GetTTFLabelWrap(self.awardTb[4],strSize3,CCSize(self.dialogWidth - 20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    upTip:setAnchorPoint(ccp(0.5,1))
    upTip:setColor(G_ColorYellowPro2)
    upTip:setPosition(ccp(self.dialogWidth * 0.5,self.dialogHeight - 75))
    self.bgLayer:addChild(upTip) 
    local upTipHeight = upTip:getContentSize().height + 15

    local awardBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
    awardBg:setAnchorPoint(ccp(0.5,1))
    awardBg:setContentSize(CCSizeMake(self.dialogWidth-40,self.dialogHeight - 160 - upTipHeight))
    awardBg:setPosition(ccp(self.dialogWidth*0.5,self.dialogHeight - upTipHeight - 70))
    self.bgLayer:addChild(awardBg) 

    local largeItemBg = LuaCCScale9Sprite:createWithSpriteFrameName("believerRankItemBg.png", CCRect(18, 21, 1, 1), function()end)
    largeItemBg:setContentSize(CCSizeMake(self.dialogWidth-60, awardBg:getContentSize().height * 0.5))
    largeItemBg:setAnchorPoint(ccp(0.5,0))
    largeItemBg:setPosition(awardBg:getContentSize().width * 0.5, 10)
    largeItemBg:setOpacity(255*0.8)
    awardBg:addChild(largeItemBg)



    local awardBgCenterPosx,awardBgHeight = awardBg:getContentSize().width * 0.5,awardBg:getContentSize().height
    local largeBgCenterPosx,largeBgHeight = largeItemBg:getContentSize().width * 0.5,largeItemBg:getContentSize().height

    local useIcon, curRate, curCanTakeNums, curCanGetPoints, useIcon2, largeRate, larCanTakeNums, larCanGetPoints = acHljbVoApi:getCanTakeItems( )

    local curTakeTipLb = GetTTFLabelWrap(getlocal("activity_hljb_curTakeTip",{curRate,curCanGetPoints}),strSize3,CCSize(self.dialogWidth - 80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    curTakeTipLb:setColor(G_ColorYellowPro2)
    curTakeTipLb:setPosition(awardBgCenterPosx, awardBgHeight - curTakeTipLb:getContentSize().height * 0.5 -25)
    awardBg:addChild(curTakeTipLb)

    local scale = 0.9
    local curTakeItemIconSp = useIcon
    curTakeItemIconSp:setScale(scale)
    curTakeItemIconSp:setAnchorPoint(ccp(0.5,1))
    curTakeItemIconSp:setPosition(awardBgCenterPosx,curTakeTipLb:getPositionY() - curTakeTipLb:getContentSize().height * 0.5 - 20)
    awardBg:addChild(curTakeItemIconSp)

    local numLb = GetTTFLabel("x" .. FormatNumber(curCanTakeNums),19)
    numLb:setAnchorPoint(ccp(1,0))
    curTakeItemIconSp:addChild(numLb,4)
    numLb:setPosition(curTakeItemIconSp:getContentSize().width + 5, -5)
    numLb:setScale(1/scale)

    local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
    numBg:setAnchorPoint(ccp(1,0))
    numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-5))
    numBg:setPosition(ccp(curTakeItemIconSp:getContentSize().width + 5, -5))
    numBg:setOpacity(180)
    curTakeItemIconSp:addChild(numBg,3)

    -------large
    local largeTakeTipLb = GetTTFLabelWrap(getlocal("activity_hljb_larTakeTip",{largeRate,larCanGetPoints}),strSize3,CCSize(self.dialogWidth - 80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    largeTakeTipLb:setColor(G_ColorYellowPro2)
    largeTakeTipLb:setPosition(largeBgCenterPosx, largeBgHeight - largeTakeTipLb:getContentSize().height * 0.5 -25)
    largeItemBg:addChild(largeTakeTipLb)

    local scale = 0.9
    local largeTakeItemIconSp = useIcon2
    largeTakeItemIconSp:setScale(scale)
    largeTakeItemIconSp:setAnchorPoint(ccp(0.5,1))
    largeTakeItemIconSp:setPosition(largeBgCenterPosx,largeTakeTipLb:getPositionY() - largeTakeTipLb:getContentSize().height * 0.5 - 20)
    largeItemBg:addChild(largeTakeItemIconSp)

    local numLb = GetTTFLabel("x" .. FormatNumber(larCanTakeNums),19)
    numLb:setAnchorPoint(ccp(1,0))
    largeTakeItemIconSp:addChild(numLb,4)
    numLb:setPosition(largeTakeItemIconSp:getContentSize().width + 5, -5)
    numLb:setScale(1/scale)

    local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
    numBg:setAnchorPoint(ccp(1,0))
    numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-5))
    numBg:setPosition(ccp(largeTakeItemIconSp:getContentSize().width + 5, -5))
    numBg:setOpacity(180)
    largeTakeItemIconSp:addChild(numBg,3)


    ----------------- b t n -----------------

    local function SureCall()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        


        local function sureClick()
            local function socketSuccCall()
                self:close()
                self.awardTb[3]()
                --takeSuccsess
                acHljbVoApi:showbtnTip(getlocal("takeSuccsess"))
            end
            acHljbVoApi:takeSocket(socketSuccCall,curCanTakeNums)
        end
        local function secondTipFunc(sbFlag)
            local keyName=acHljbVoApi:getActiveName()
            local sValue=base.serverTime .. "_" .. sbFlag
            G_changePopFlag(keyName,sValue)
        end

        local keyName=acHljbVoApi:getActiveName()
        if G_isPopBoard(keyName) then
            local contentTb = {}
            contentTb[1] = getlocal("activity_hljb_takeSureTip",{curRate})
            contentTb[2] = {G_ColorWhite,G_ColorRed,G_ColorWhite,G_ColorRed,G_ColorWhite}

            self.secondDialog=G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),contentTb,true,sureClick,secondTipFunc)
        else
            sureClick()
        end


    end
    local sureItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",SureCall,nil,getlocal("confirm"),34)
    sureItem:setAnchorPoint(ccp(0.5,1))
    sureItem:setScale(0.8)
    local sureBtn=CCMenu:createWithItem(sureItem)
    sureBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    sureBtn:setPosition(self.dialogWidth*0.74,80)
    self.bgLayer:addChild(sureBtn)


    local function closeCall()
            self:close()
            self.awardTb[3]()
    end
    local cancelItem=GetButtonItem("newGrayBtn.png","newGrayBtn_Down.png","newGrayBtn_Down.png",closeCall,nil,getlocal("cancel"),34)
    cancelItem:setAnchorPoint(ccp(0.5,1))
    cancelItem:setScale(0.8)
    local cancelBtn=CCMenu:createWithItem(cancelItem)
    cancelBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    cancelBtn:setPosition(self.dialogWidth*0.26,80)
    self.bgLayer:addChild(cancelBtn)
end

function acThrivingSmallDialog:aboutHljbKeepCall()
    local strSize2,strSize3,strSize4 = 22,23,24
    if not G_isAsia() then
        strSize2,strSize3,strSize4 = 20,20,21
    end

    local hasNum,iconSp,itemName = acHljbVoApi:getCurHasItem( )
    local keepInitNum,keepLimitNum = acHljbVoApi:getCurCanKeepItemNum( )
    print("keepLimitNum:"..keepLimitNum)
    local awardBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function() end)
    awardBg:setAnchorPoint(ccp(0.5,1))
    awardBg:setContentSize(CCSizeMake(self.dialogWidth-40,self.dialogHeight - 130))
    awardBg:setPosition(ccp(self.dialogWidth*0.5,self.dialogHeight - 30))
    self.bgLayer:addChild(awardBg) 

    local awardBgWidth = awardBg:getContentSize().width
    local usePosx = awardBg:getContentSize().width * 0.03
    local useHeight = awardBg:getContentSize().height

    if hasNum then
        local scale = 90 / iconSp:getContentSize().width
        local icon = iconSp
        awardBg:addChild(icon)
        icon:setAnchorPoint(ccp(0,0.5))
        icon:setPosition(usePosx,useHeight - 60)

        local rightPosy = icon:getPositionY() + icon:getContentSize().height * 0.5 * scale

        local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,0,1,32),function () end)
        nameBg:setContentSize(CCSizeMake(350,28))
        nameBg:setAnchorPoint(ccp(0,1))
        nameBg:setPosition(usePosx + 105 ,rightPosy)
        awardBg:addChild(nameBg)

        local titleLb = GetTTFLabel(itemName,strSize2,true)
        titleLb:setAnchorPoint(ccp(0,0.5))
        titleLb:setColor(G_ColorYellowPro2)
        titleLb:setPosition(15,nameBg:getContentSize().height * 0.5)
        nameBg:addChild(titleLb)

        local hasNumLb = GetTTFLabel(getlocal("hold").."："..hasNum,20)
        hasNumLb:setAnchorPoint(ccp(0,1))
        hasNumLb:setPosition(usePosx + 115 ,rightPosy - 40)
        awardBg:addChild(hasNumLb)
        self.hasNumLb = hasNumLb

        local keepNumLb = GetTTFLabel(getlocal("keep").."："..keepLimitNum,20)
        keepNumLb:setAnchorPoint(ccp(0,1))
        keepNumLb:setPosition(usePosx + 115 ,rightPosy - 65)
        awardBg:addChild(keepNumLb)
        self.keepNumLb = keepNumLb    

        if keepInitNum > hasNum then
            keepNumLb:setColor(G_ColorRed)
            acHljbVoApi:willKeepItemNum(0)
        else
            acHljbVoApi:willKeepItemNum(keepInitNum)
        end    
    end

    local m_numLb=GetTTFLabel(" ",30)
    awardBg:addChild(m_numLb,2);

    local function sliderTouch(handler,object)
          -- local valueNum = tonumber(string.format("%.2f", object:getValue()))
          local count = math.ceil(object:getValue())
          self.count = count
          -- print("count====>>>>>",count)
          if count >= 0 then
              m_numLb:setString(count)
          end  

          if self.keepNumLb then
                self.keepNumLb:setString(getlocal("keep").."："..count)
                self.keepNumLb:setColor(count > hasNum and G_ColorRed or G_ColorWhite)
          end
          acHljbVoApi:willKeepItemNum(count)
    end
    local sliderScale = 1--0.8
    local spBg =CCSprite:createWithSpriteFrameName("proBar_n2.png");
    local spPr =CCSprite:createWithSpriteFrameName("proBar_n1.png");
    local spPr1 =CCSprite:createWithSpriteFrameName("grayBarBtn.png");--ProduceTankIconSlide
    self.slider = LuaCCControlSlider:create(spBg,spPr,spPr1,sliderTouch);
    self.slider:setTouchPriority(-(self.layerNum-1)*20-5);
    self.slider:setIsSallow(true);
    self.slider:setScaleX(sliderScale)
    self.slider:setMinimumValue(keepLimitNum);

    self.slider:setTag(99)
    awardBg:addChild(self.slider,2)
    m_numLb:setString(math.ceil(self.slider:getValue()))
    self.m_numLb=m_numLb

    local bgSp = CCSprite:createWithSpriteFrameName("proBar_n2.png");
    bgSp:setScaleX(85/bgSp:getContentSize().width)
    bgSp:setAnchorPoint(ccp(0.5,0.5));
    awardBg:addChild(bgSp,1);

    local function touchAdd()
       self.slider:setValue(self.slider:getValue()+1);
    end

    local function touchMinus()
      if self.slider:getValue()-1>0 and self.slider:getValue() ~= keepInitNum then
          self.slider:setValue(self.slider:getValue()-1);
      end
    end

    local addSp=LuaCCSprite:createWithSpriteFrameName("greenPlus.png",touchAdd)
    awardBg:addChild(addSp,1)
    addSp:setTouchPriority(-(self.layerNum-1)*20-5);

    local minusSp=LuaCCSprite:createWithSpriteFrameName("greenMinus.png",touchMinus)
    awardBg:addChild(minusSp,1)
    minusSp:setTouchPriority(-(self.layerNum-1)*20-5);

    local sliderAddPosx2 = -86

    self.slider:setPosition(ccp(340 * sliderScale + sliderAddPosx2,55))
    addSp:setPosition(ccp(560 * sliderScale + sliderAddPosx2,55))
    minusSp:setPosition(ccp(125 * sliderScale + sliderAddPosx2,55))
    
    bgSp:setPosition(60,55);
    m_numLb:setPosition(60,55);
    bgSp:setVisible(false)
    m_numLb:setVisible(false)

    self.slider:setMaximumValue(keepLimitNum);
    self.slider:setValue(keepLimitNum);
    self.count = keepLimitNum



    local function SureCall()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local keepNum = acHljbVoApi:getKeepItemNum( )
        if hasNum < keepNum then
            acHljbVoApi:showbtnTip(getlocal("notKeepTip"))
            do return end
        end
        local function socketSuccCall()
            self:close()
            self.awardTb[3]()
        end
        acHljbVoApi:keepSocket(socketSuccCall,keepNum)
    end
    local sureItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",SureCall,nil,getlocal("confirm"),34)
    sureItem:setAnchorPoint(ccp(0.5,1))
    sureItem:setScale(0.8)
    local sureBtn=CCMenu:createWithItem(sureItem)
    sureBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    sureBtn:setPosition(self.dialogWidth*0.74,80)
    self.bgLayer:addChild(sureBtn)


    local function closeCall()
            self:close()
            -- self.awardTb[3]()
    end
    local cancelItem=GetButtonItem("newGrayBtn.png","newGrayBtn_Down.png","newGrayBtn_Down.png",closeCall,nil,getlocal("cancel"),34)
    cancelItem:setAnchorPoint(ccp(0.5,1))
    cancelItem:setScale(0.8)
    local cancelBtn=CCMenu:createWithItem(cancelItem)
    cancelBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    cancelBtn:setPosition(self.dialogWidth*0.26,80)
    self.bgLayer:addChild(cancelBtn)
end

function acThrivingSmallDialog:aboutExerwarAutionCall( )
    local bgWidth,bgHeight = self.dialogWidth - 40 , self.dialogHeight - 180
    local bgSp = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
    bgSp:setAnchorPoint(ccp(0.5,0))
    bgSp:setContentSize(CCSizeMake(bgWidth,bgHeight))
    bgSp:setIsSallow(false)
    bgSp:setPosition(ccp(self.dialogWidth*0.5,100))
    self.bgLayer:addChild(bgSp) 

    local posY = bgHeight - 20
    local tipTb = self.awardTb[4]
    for i=1,3 do
        local upTipLb = GetTTFLabelWrap(tipTb[i],G_isAsia() and 24 or 19,CCSizeMake(bgWidth - 30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        upTipLb:setAnchorPoint(ccp(0,1))
        upTipLb:setPosition(20, posY)
        upTipLb:setColor(G_ColorYellowPro)
        bgSp:addChild(upTipLb)
        posY = posY - upTipLb:getContentSize().height - 5
    end

    posY = posY - 20
    
    local function callBackXHandler(fn, eB, str, type)
        local hasMaxGold = playerVoApi:getGems()    
        if type == 1 then --检测文本内容变化
            if str == "" then
                self.autionNum = exerWarVoApi:getAuctionGem()
                self.autionNumLb:setString(self.autionNum)
                do return end
            end
            if tonumber(str) == nil then
                eB:setText(self.autionNum)
            else
                if tonumber(str) >= 0 and tonumber(str) <= hasMaxGold then
                    self.autionNum = tonumber(str)
                else
                    if tonumber(str) < 0 then
                        eB:setText(0)
                        self.autionNum = 0
                    end
                    if tonumber(str) > hasMaxGold then
                        eB:setText(hasMaxGold)
                        self.autionNum = hasMaxGold
                    end
                    
                end
            end
            self.autionNumLb:setString(self.autionNum)
        elseif type == 2 then --检测文本输入结束
            eB:setVisible(false)
        end
    end
    local minJpNum,limitJpNum,addJpNum=exerWarVoApi:getAuctionNeedAndLimit()
    local jpNum = exerWarVoApi:getAuctionGem()
    if jpNum > 0 then --如果已经竞拍过，默认显示最少竞拍价
        minJpNum = 100
    end
    self.autionNum = minJpNum
    self.autionNumLb = GetTTFLabel(tostring(self.autionNum), 26)
    self.autionNumLb:setPosition(ccp(bgWidth * 0.5, posY - 15))
    bgSp:addChild(self.autionNumLb, 2)

    posY = self.autionNumLb:getPositionY()
    
    local xBox = LuaCCScale9Sprite:createWithSpriteFrameName("proBar_n3.png", CCRect(3, 3, 1, 1), function() end)
    local editXBox = CCEditBox:createForLua(CCSize(150, 33), xBox, nil, nil, callBackXHandler)
    
    editXBox:setPosition(ccp(bgWidth * 0.5, posY))
    if G_isIOS() == true then
        editXBox:setInputMode(CCEditBox.kEditBoxInputModePhoneNumber)
    else
        editXBox:setInputMode(CCEditBox.kEditBoxInputModeAny)
    end
    editXBox:setVisible(false)
    bgSp:addChild(editXBox, 3)
    
    local function tthandler2()
        PlayEffect(audioCfg.mouseClick)
        editXBox:setVisible(true)
    end
    local xBoxBg = LuaCCScale9Sprite:createWithSpriteFrameName("proBar_n3.png", CCRect(3, 3, 1, 1), tthandler2)
    xBoxBg:setPosition(ccp(bgWidth * 0.5, posY))
    xBoxBg:setContentSize(CCSizeMake(150,33))
    xBoxBg:setTouchPriority(-(self.layerNum-1)*20-3)
    bgSp:addChild(xBoxBg)

    local btnScale,priority=1,-(self.layerNum-1)*20-4
    local function addJp() --加价
        if self.autionNum < (limitJpNum - jpNum) then
            self.autionNum = self.autionNum + addJpNum
        end
        self.autionNumLb:setString(self.autionNum)
    end
    local addBtn = G_createBotton(bgSp,ccp(bgWidth * 0.5 + 110,posY),{},"greenPlus.png","greenPlus.png","greenPlus.png",addJp,btnScale,priority)

    local function subJp() --减价
        if jpNum==0 then --没有竞拍过，最少得竞拍minJpNum
            if self.autionNum > minJpNum then
                self.autionNum = self.autionNum - addJpNum
            end
        else
            if self.autionNum > addJpNum then
                self.autionNum = self.autionNum - addJpNum
            end
        end
        self.autionNumLb:setString(self.autionNum)
    end
    local subBtn = G_createBotton(bgSp,ccp(bgWidth * 0.5 - 110,posY),{},"greenMinus.png","greenMinus.png","greenMinus.png",subJp,btnScale,priority)

    local function autionHandler( )
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if playerVoApi:getGems() < self.autionNum then
            G_showTipsDialog(getlocal("pleaseBuyGem"))
            do return end
        elseif self.autionNum < minJpNum then
            G_showTipsDialog(getlocal("exerwar_aution_showTip3",{minJpNum}))
            do return end
        elseif self.autionNum > limitJpNum then
            G_showTipsDialog(getlocal("exerwar_aution_showTip4",{limitJpNum}))
            do return end
        elseif self.autionNum % 100 ~= 0 then
            G_showTipsDialog(getlocal("exerwar_aution_showTip"))
            do return end
        end

        -- self.autionNumLb:setVisible(false)
        -- xBoxBg:setVisible(false)
        -- editXBox:setVisible(false)
        local function cancelCallBack( )
            print("cancelCallBack~~~~~")
            -- self.autionNumLb:setVisible(true)
            -- xBoxBg:setVisible(true)
            -- editXBox:setVisible(true)
        end 
        local function onConfirm( )
            -- self.autionNumLb:setVisible(true)
            -- xBoxBg:setVisible(true)

            local function autionSuccessCall()
                playerVoApi:setGems(playerVoApi:getGems() - self.autionNum)
                -- editXBox:setVisible(false)
                G_ShowFloatingBoard(getlocal("exerwar_aution_success"))
                if type(self.awardTb[3]) == "function" then
                    self.awardTb[3](self.autionNum)
                end
                self:close()
             end
             --需要向后台请求
             exerWarVoApi:auctionSocket(self.autionNum,autionSuccessCall)
        end
        smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("exerwar_aution_showTip2",{self.autionNum}),nil,self.layerNum+1,nil,nil,cancelCallBack)
    end 
    local autionItem = GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",autionHandler,nil,getlocal("exerwar_rankTab1_dTitleTip_2"),33,11)
    autionItem:setScale(0.8)
    local autionMenu=CCMenu:createWithItem(autionItem)
    autionMenu:setPosition(ccp(self.dialogWidth*0.5,55))
    autionMenu:setTouchPriority(-(self.layerNum-1)*20-3)
    self.bgLayer:addChild(autionMenu,2)
end

function acThrivingSmallDialog:aboutHryxBuildingShow( )
    local subWidth,subHeight = 80,130
    local awardBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function() end)
    awardBg:setAnchorPoint(ccp(0.5,1))
    awardBg:setContentSize(CCSizeMake(self.dialogWidth-subWidth - 10,self.dialogHeight - subHeight))
    awardBg:setPosition(ccp(self.dialogWidth*0.5,self.dialogHeight - 30))
    self.bgLayer:addChild(awardBg) 

    local function SureCall()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local sureItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",SureCall,nil,getlocal("confirm"),34)
    sureItem:setAnchorPoint(ccp(0.5,1))
    sureItem:setScale(0.7)
    local sureBtn=CCMenu:createWithItem(sureItem)
    sureBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    sureBtn:setPosition(self.dialogWidth*0.5,80)
    self.bgLayer:addChild(sureBtn)

     local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return 1
        elseif fn=="tableCellSizeForIndex" then
            return  CCSizeMake(self.dialogWidth-subWidth, self.dialogHeight - subHeight)
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            self:initHryxLayer(cell,awardBg)
            return cell
        end
    end
    local hd=LuaEventHandler:createHandler(tvCallBack)
    local tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.dialogWidth-subWidth, self.dialogHeight - subHeight),nil)
    tableView:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    tableView:setPosition(ccp(0,0))
    awardBg:addChild(tableView)
    tableView:setMaxDisToBottomOrTop(0)
    self.tv = tableView
    --"rewardCenterArrow.png","rewardCenterArrow.png","rewardCenterArrow.png"
end
function acThrivingSmallDialog:initHryxLayer(parent,parent2)----self.awardTb 第三个参数强制设置为最新建筑的idx 强制！！！！;第四个参数用于判断是否为单一建筑显示；第五个参数用于其他活动使用
    local width,height = parent2:getContentSize().width,parent2:getContentSize().height
    local listNum,forNum = 2,2
    local showPageIndex = 1
    local pageList = {}
    local buildingPic = nil 
    local isJustOneBuilding = self.awardTb[4] or false
    if not isJustOneBuilding then
        buildingPic = acHryxVoApi:getCurPicName(self.awardTb[3])
    else
        if self.awardTb[5] == "wxgx"then
            buildingPic = acWxgxVoApi:getCurPicName()
        end
    end
    if not buildingPic then
        print(" ~~~~~~~~ e r r o r  : buildingPic is nil ~~~~~~~~")
        do return end
    end

    for i=1,forNum do
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
        local function onLoadIcon(fn,icon)
            if parent then
                icon:setAnchorPoint(ccp(0.5,0.5))
                if showPageIndex == i then
                    icon:setPosition(width * 0.5,height * 0.5)
                else
                    icon:setPosition(width * 1.8,height * 0.5)
                end
                parent:addChild(icon)

                pageList[i] = icon
                if self.awardTb[3] == 1 then
                    local buildingSp = G_buildingAction1(buildingPic,icon,i ==1 and ccp(width * 0.45 - 5,height * 0.44) or ccp(width * 0.5,height * 0.5),nil,i ==1 and 0.8 or 0.38)
                elseif self.awardTb[3] == 2 then
                    local buildingSp = G_buildingAction2(buildingPic,icon,i ==1 and ccp(width * 0.45 - 5,height * 0.44) or ccp(width * 0.5,height * 0.5),nil,i ==1 and 0.8 or 0.38)
                else
                    local buildingSp = G_buildingAction3(buildingPic,icon, ccp(width * 0.43,height * 0.5),nil,0.6)
                end
            end
        end
        local webImage = LuaCCWebImage:createWithURL(G_downloadUrl("active/acHryxImage_tabSub"..i..".jpg"), onLoadIcon)
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        

    end

            local pageTurning = false
            local function onPage(flag)
                if pageTurning == true then
                    do return end
                end
                pageTurning = true
                local pageBg = pageList[showPageIndex]
                showPageIndex = showPageIndex + flag
                if showPageIndex <= 0 then
                    showPageIndex = listNum
                end
                if showPageIndex > listNum then
                    showPageIndex = 1
                end
                local newPageBg = pageList[showPageIndex]
                
                local cPos = ccp(pageBg:getPosition())
                newPageBg:setPosition(cPos.x + flag * G_VisibleSizeWidth, cPos.y)
                pageBg:runAction(CCMoveTo:create(0.3, ccp(cPos.x - flag * G_VisibleSizeWidth, cPos.y)))
                local arry = CCArray:create()
                arry:addObject(CCMoveTo:create(0.3, cPos))
                arry:addObject(CCMoveTo:create(0.06, ccp(cPos.x - flag * 50, cPos.y)))
                arry:addObject(CCMoveTo:create(0.06, cPos))
                arry:addObject(CCCallFunc:create(function()
                        pageTurning = false
                end))
                newPageBg:runAction(CCSequence:create(arry))
            end

            local leftArrowSp = CCSprite:createWithSpriteFrameName("rewardCenterArrow.png")
            local rightArrowSp = CCSprite:createWithSpriteFrameName("rewardCenterArrow.png")
            rightArrowSp:setFlipX(true)
            leftArrowSp:setPosition(-35, height * 0.5)
            rightArrowSp:setPosition(width + 35, height * 0.5)
            parent2:addChild(leftArrowSp,1)
            parent2:addChild(rightArrowSp,1)
            local leftTouchArrow = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function() onPage( - 1) end)
            local rightTouchArrow = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function() onPage(1) end)
            leftTouchArrow:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
            rightTouchArrow:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
            leftTouchArrow:setContentSize(CCSizeMake(leftArrowSp:getContentSize().width + 40, leftArrowSp:getContentSize().height + 60))
            rightTouchArrow:setContentSize(CCSizeMake(rightArrowSp:getContentSize().width + 40, rightArrowSp:getContentSize().height + 60))
            leftTouchArrow:setPosition(leftArrowSp:getPositionX() - 20, leftArrowSp:getPositionY())
            rightTouchArrow:setPosition(rightArrowSp:getPositionX() + 20, rightArrowSp:getPositionY())
            leftTouchArrow:setOpacity(0)
            rightTouchArrow:setOpacity(0)
            parent2:addChild(leftTouchArrow,1)
            parent2:addChild(rightTouchArrow,1)
            
            local function runArrowAction(arrowSp, flag)
                local posX, posY = arrowSp:getPosition()
                local posX2 = posX + flag * 20
                local arry1 = CCArray:create()
                arry1:addObject(CCMoveTo:create(0.5, ccp(posX, posY)))
                arry1:addObject(CCFadeIn:create(0.5))
                local spawn1 = CCSpawn:create(arry1)
                
                local arry2 = CCArray:create()
                arry2:addObject(CCMoveTo:create(0.5, ccp(posX2, posY)))
                arry2:addObject(CCFadeOut:create(0.5))
                local spawn2 = CCSpawn:create(arry2)
                
                arrowSp:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(spawn2, spawn1)))
            end
            runArrowAction(leftArrowSp, - 1)
            runArrowAction(rightArrowSp, 1)

            local pageLayer = CCLayer:create()
            pageLayer:setContentSize(CCSizeMake(width, height))
            pageLayer:setPosition(0,height)
            local touchArray = {}
            local beganPos
            local function touchHandler(fn, x, y, touch)
                if fn == "began" then
                    if x >= 0 and x <= width and y <= height and y > 0 then
                        return false
                    end
                    beganPos = CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
                    return true
                elseif fn == "moved" then
                elseif fn == "ended" then
                    if beganPos then
                        local curPos = CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
                        local moveDisTmp = ccpSub(curPos, beganPos)
                        if moveDisTmp.x > 50 then
                            onPage( - 1)
                        elseif moveDisTmp.x < - 50 then
                            onPage(1)
                        end
                    end
                    beganPos = nil
                end
            end
            pageLayer:setTouchEnabled(true)
            pageLayer:setBSwallowsTouches(true)
            pageLayer:registerScriptTouchHandler(touchHandler, false, - (self.layerNum - 1) * 20 - 1, true)
            parent:addChild(pageLayer,1)
end

function acThrivingSmallDialog:aboutReadyShareSelfData()
     local bgWidth,bgHeight = self.dialogWidth - 40 , self.dialogHeight - 180

     local function chatToWorld()
        local sender=playerVoApi:getUid()
        local senderName=playerVoApi:getPlayerName()
         chatVoApi:sendChatMessage(1,sender,senderName,0,"",{message=self.awardTb[3], subType=1,contentType=2, level=playerVoApi:getPlayerLevel(),rank=playerVoApi:getRank(),power=playerVoApi:getPlayerPower(),uid=playerVoApi:getUid(),name=playerVoApi:getPlayerName(),pic=playerVoApi:getPic(),ts=base.serverTime,vip=playerVoApi:getVipLevel(),language=G_getCurChoseLanguage(),st=base.serverTime,title=playerVoApi:getTitle()})
         G_showTipsDialog(getlocal("sendMessageOver",{getlocal("alliance_send_channel_1")}))
         self:close()
     end 
    G_createBotton(self.bgLayer,ccp(self.dialogWidth * 0.5 ,self.dialogHeight * 0.55),{getlocal("alliance_send_channel_1"),25},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",chatToWorld,0.8,-(self.layerNum-1)*20-3)

    local function chatToAlliance()
        local aid=playerVoApi:getPlayerAid()
        local sender=playerVoApi:getUid()
        local senderName=playerVoApi:getPlayerName()
        local allianceVo=allianceVoApi:getSelfAlliance()
        local allianceName=allianceVo.name
        local allianceRole=allianceVo.role
         chatVoApi:sendChatMessage(aid + 1,sender,senderName,0,"",{message=self.awardTb[3], subType=3,contentType=2, level=playerVoApi:getPlayerLevel(),rank=playerVoApi:getRank(),power=playerVoApi:getPlayerPower(),uid=playerVoApi:getUid(),name=playerVoApi:getPlayerName(),pic=playerVoApi:getPic(),ts=base.serverTime,vip=playerVoApi:getVipLevel(),language=G_getCurChoseLanguage(),st=base.serverTime,title=playerVoApi:getTitle(),allianceName=allianceName,allianceRole=allianceRole} )
        G_showTipsDialog(getlocal("sendMessageOver",{getlocal("alliance_send_channel_2")}))
         self:close()
     end 
    local allianBtn = G_createBotton(self.bgLayer,ccp(self.dialogWidth * 0.5 ,self.dialogHeight * 0.27),{getlocal("alliance_send_channel_2"),25},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",chatToAlliance,0.8,-(self.layerNum-1)*20-3)

    if not allianceVoApi:isHasAlliance() then
        allianBtn:setEnabled(false)
    end
    
end

function acThrivingSmallDialog:aboutChampionshipWarQuickBattle( )
    local awardTb = self.awardTb
    local bgWidth,bgHeight = self.dialogWidth - 80 , self.dialogHeight - 80
    local titleSize = G_isAsia() and 24 or 20
    local posx = self.dialogWidth * 0.5
    local title1 = getlocal("super_weapon_challenge_raid_complete")
    local testTitle1 = GetTTFLabel(title1,titleSize)
    local titleSizeWidth = testTitle1:getContentSize().width
    local titleBg1,titleLb1,titleHeight1 = G_createNewTitle({title1,titleSize},CCSizeMake(titleSizeWidth + 80,0),true,true)
    titleBg1:setPosition(posx, bgHeight - titleHeight1)
    self.bgLayer:addChild(titleBg1,1)

    local upBgHeight = 120
    local upBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function() end)
    upBg:setAnchorPoint(ccp(0.5,1))
    upBg:setContentSize(CCSizeMake(self.dialogWidth - 10,upBgHeight))
    upBg:setPosition(ccp(posx,titleBg1:getPositionY()))
    self.bgLayer:addChild(upBg)

    local lbCellHeight = upBgHeight * 0.3
    local lbUseStrTb = {getlocal("passTheLevels",{awardTb[4]}), getlocal("getTheNums",{awardTb[5]})}
    local lbPosyTb = { 75, 45}
    for i=1,2 do
        local posx,posy = (self.dialogWidth - 10) * 0.5, lbPosyTb[i]
        local lb = GetTTFLabel(lbUseStrTb[i],G_isAsia() and 22 or 19)
        lb:setPosition(posx,posy)
        upBg:addChild(lb)
        if i == 2 then
            local starSp1 = CCSprite:createWithSpriteFrameName("avt_star.png")
            starSp1:setAnchorPoint(ccp(0,0.5))
            starSp1:setPosition(lb:getContentSize().width * 0.5 + posx + 5, posy)
            upBg:addChild(starSp1)
        end
    end 
    if awardTb[7] then
        local showAwardTb = awardTb[7]--FormatItem(awardTb[7],nil,true) 
        local showAwardTbNums = SizeOfTable(showAwardTb)
        -- print("showAwardTb====>>>>",showAwardTb,showAwardTbNums)
        local title2 = getlocal("fight_award")
        local testTitle2 = GetTTFLabel(title2,titleSize)
        local titleSizeWidth = testTitle2:getContentSize().width
        local titleBg2,titleLb2,titleHeight2 = G_createNewTitle({title2,titleSize},CCSizeMake(titleSizeWidth + 80,0),true,true)
        titleHeight2 = titleHeight2 + 5
        titleBg2:setPosition(posx, upBg:getPositionY() - upBg:getContentSize().height - titleHeight2)
        self.bgLayer:addChild(titleBg2,1)

        local downBgHeight = 120
        if showAwardTbNums > 4 then
            downBgHeight = math.ceil(showAwardTbNums / 4) * 100 + 20
        end
        local downBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function() end)
        downBg:setAnchorPoint(ccp(0.5,1))
        downBg:setContentSize(CCSizeMake(self.dialogWidth - 10,downBgHeight))
        downBg:setPosition(ccp(posx,titleBg2:getPositionY()))
        self.bgLayer:addChild(downBg,1)

        if showAwardTbNums == 1 then
            local posx,posy = (self.dialogWidth - 10) * 0.5, downBgHeight * 0.5
            local function callback( )
                G_showNewPropInfo(self.layerNum+1,true,nil,nil,showAwardTb[1],nil,nil,nil)
            end 
            local icon,scale=G_getItemIcon(showAwardTb[1],80,false,self.layerNum,callback,nil)
            downBg:addChild(icon)
            icon:setTouchPriority(-(self.layerNum-1)*20-4)
            icon:setPosition(posx,posy)

            local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function() end)
            numBg:setAnchorPoint(ccp(1,0))
            icon:addChild(numBg,1)
            numBg:setPosition(icon:getContentSize().width-5, 4)

            local numLabel=GetTTFLabel("x"..showAwardTb[1].num,21)
            numLabel:setAnchorPoint(ccp(1,0))
            numLabel:setPosition(icon:getContentSize().width-5, 5)
            numLabel:setScale(1/scale)
            icon:addChild(numLabel,1)
            numBg:setContentSize(CCSizeMake(numLabel:getContentSize().width+23,numLabel:getContentSize().height+8))

        -- else
        --     cellNums = math.ceil(showAwardTbNums / 4)
        --     local startPosx = ( downBg:getContentSize().width - 400 ) * 0.5
        --     for i=1,cellNums do
        --             local posy = downBgHeight - 60 - (i - 1) * 100
        --         for j=1,4 do
        --             local posx = startPosx + 50 + (4 - j) * 100
        --             local curIdx = j + (i - 1) * 4
        --             local posx,posy = (self.dialogWidth - 10) * 0.5, downBgHeight * 0.5
        --             local function callback( )
        --                 G_showNewPropInfo(self.layerNum+1,true,nil,nil,showAwardTb[curIdx],nil,nil,nil)
        --             end 
        --             local icon,scale=G_getItemIcon(showAwardTb[curIdx],80,false,self.layerNum,callback,nil)
        --             downBg:addChild(icon)
        --             icon:setTouchPriority(-(self.layerNum-1)*20-4)
        --             icon:setPosition(posx,posy)

        --             local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function() end)
        --             numBg:setAnchorPoint(ccp(1,0))
        --             icon:addChild(numBg,1)
        --             numBg:setPosition(icon:getContentSize().width-5, 4)

        --             local numLabel=GetTTFLabel("x"..showAwardTb[curIdx].num,21)
        --             numLabel:setAnchorPoint(ccp(1,0))
        --             numLabel:setPosition(icon:getContentSize().width-5, 5)
        --             numLabel:setScale(1/scale)
        --             icon:addChild(numLabel,1)
        --             numBg:setContentSize(CCSizeMake(numLabel:getContentSize().width+23,numLabel:getContentSize().height+8))
        --         end
        --     end
        end
    end

    local function Endback( )
        --加奖励
        for k, v in pairs(self.awardTb[7]) do
            G_addPlayerAward(v.type, v.key, v.id, v.num)
        end
        --奖励展示
        G_showRewardTip(self.awardTb[7], true)

        self:close()
        self.awardTb[3]()
    end
    G_createBotton(self.bgLayer,ccp(self.dialogWidth * 0.5 ,60),{getlocal("confirm"),25},"newGreenBtn.png","newGreenBtn_Down.png","newGreenBtn.png",Endback,0.8,-(self.layerNum-1)*20-3)
end

function acThrivingSmallDialog:aboutAirShipPartsTotalCall()
    local useHeight = self.dialogHeight / 3.6
    local textStrTb = {self.awardTb[3],self.awardTb[4],self.awardTb[5]}
    for i=1,3 do
        local tipLb = GetTTFLabelWrap(textStrTb[i],G_isAsia() and 21 or 17,CCSizeMake(self.dialogWidth - 40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
        tipLb:setAnchorPoint(ccp(0,0.5))
        tipLb:setPosition(ccp(25,self.dialogHeight - useHeight * i + (i-1) * 18))
        self.bgLayer:addChild(tipLb)
        if i == 3 then
            tipLb:setColor(G_ColorYellowPro2)
        end
    end
end

function acThrivingSmallDialog:aboutAirShipLastDayRank( )
    local bgWidth,bgHeight = self.dialogWidth , self.dialogHeight - 80

    lastT = airShipVoApi:getLastDayRankAwardTime( )

    local airshipLastTLb = GetTTFLabel(lastT,G_isAsia() and 21 or 20)
    airshipLastTLb:setPosition(bgWidth * 0.5, bgHeight - 30)
    airshipLastTLb:setColor(G_ColorYellowPro2)
    self.airshipLastTLb = airshipLastTLb
    self.bgLayer:addChild(airshipLastTLb)


    local rewardBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),function() end)
    rewardBg:setContentSize(CCSizeMake(bgWidth - 30,115))
    rewardBg:setAnchorPoint(ccp(0.5,0))
    rewardBg:setPosition(bgWidth * 0.5,18)
    self.bgLayer:addChild(rewardBg)
    local canReward,rewardInfo,hadReawrd = airShipVoApi:isHasLastDayRankToGet()
    local rewardBtn

    local function getRewardHandl( )
        local function refreshBtn(reward)
            if rewardBtn then
                rewardBtn:setEnabled(false)
                G_showRewardTip(reward)
            end
        end
        airShipVoApi:socketGetLastDayReward(refreshBtn)
    end
    local btnStr = getlocal("daily_scene_get")
    if hadReawrd then
        btnStr = getlocal("activity_hadReward")
    end
    rewardBtn = G_createBotton(rewardBg,ccp(rewardBg:getContentSize().width - 100,56.7),{btnStr,25},"newGreenBtn.png","newGreenBtn_Down.png","newGreenBtn.png",getRewardHandl,0.75,-(self.layerNum-1)*20-3)

    local strSize2 = G_isAsia() and 19 or 15
    if canReward == false and hadReawrd == nil then
        local unEntryLb = GetTTFLabel(getlocal("unEntryRank"),G_isAsia() and 22 or 20)
        unEntryLb:setColor(G_ColorRed)
        unEntryLb:setAnchorPoint(ccp(0,0.5))
        unEntryLb:setPosition(50,56.7)
        rewardBg:addChild(unEntryLb)

        rewardBtn:setEnabled(false)
    elseif hadReawrd ~= nil then
        local rankIdx = rewardInfo[1] or getlocal("alliance_info_content")

        local myRank =  GetTTFLabel(getlocal("plat_war_my_rank",{rewardInfo[1] or 0}),strSize2)
        myRank:setAnchorPoint(ccp(0,0.5))
        myRank:setPosition(20,115 * 0.75)
        rewardBg:addChild(myRank)

        local myRewardLb = GetTTFLabel(getlocal("myReward").."：",strSize2)
        myRewardLb:setAnchorPoint(ccp(0,0.5))
        myRewardLb:setPosition(20,115 * 0.5)
        rewardBg:addChild(myRewardLb)

        local rewardIdx = rewardInfo[3] or nil

        local myRewardIdx = GetTTFLabel(rewardIdx and getlocal("rewardIndex",{rewardIdx}) or getlocal("alliance_info_content"),strSize2)
        myRewardIdx:setAnchorPoint(ccp(0,0.5))
        myRewardIdx:setPosition(myRewardLb:getContentSize().width + 20 + 2,myRewardLb:getPositionY())
        myRewardIdx:setColor(G_ColorGreen)
        rewardBg:addChild(myRewardIdx)

        local hurtNumLb = GetTTFLabel(getlocal("airShip_totalDamageText2"),strSize2)
        hurtNumLb:setAnchorPoint(ccp(0,0.5))
        hurtNumLb:setPosition(20,115 * 0.25)
        rewardBg:addChild(hurtNumLb)

        local hurtNum = rewardInfo[2] and FormatNumber(rewardInfo[2]) or 0

        local hurtValue = GetTTFLabel( hurtNum,strSize2)
        hurtValue:setAnchorPoint(ccp(0,0.5))
        hurtValue:setPosition(hurtNumLb:getContentSize().width + 20 + 2,hurtNumLb:getPositionY())
        hurtValue:setColor(G_ColorGreen)
        rewardBg:addChild(hurtValue)

        rewardBtn:setEnabled(not hadReawrd and true or false)
    end

    local tvWidth,tvHeight = bgWidth - 30,615
    local cellHeight = tvHeight * 0.25
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return 4
        elseif fn=="tableCellSizeForIndex" then
            return  CCSizeMake(tvWidth, cellHeight)
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            
            local bgWidth,bgHeight = tvWidth - 30,130
            local rankBg = LuaCCScale9Sprite:createWithSpriteFrameName("greenDiamondBg.png",CCRect(20,20,1,1),function() end)
            rankBg:setContentSize(CCSizeMake(bgWidth,bgHeight))
            rankBg:setPosition(tvWidth * 0.5,cellHeight * 0.5)
            cell:addChild(rankBg)

            local rankInfoTb = airShipVoApi:getLastDayAllRankInfoInCell(idx + 1)

            local rankTitleBg = CCSprite:createWithSpriteFrameName("rankBorder_".. idx+1 ..".png")
            rankTitleBg:setAnchorPoint(ccp(0,1))
            rankTitleBg:setPosition(1,bgHeight)
            rankBg:addChild(rankTitleBg)

            local hurtValue = rankInfoTb[1]
            local hurtLb,rewardTb
            if idx == 0 then
                --头像
                if rankInfoTb[3] and rankInfoTb[4] then
                    local personPhotoName=playerVoApi:getPersonPhotoName( tonumber(rankInfoTb[3]) )
                    local photoSp = playerVoApi:GetPlayerBgIcon(personPhotoName,nil,nil,nil,60,tonumber(rankInfoTb[4]))
                    photoSp:setPosition(30,bgHeight - 20)
                    rankBg:addChild(photoSp)
                else
                    local noHeadIcon = CCSprite:createWithSpriteFrameName("Icon_BG.png")
                    noHeadIcon:setPosition(30,bgHeight - 20)
                    noHeadIcon:setScale(60 / noHeadIcon:getContentSize().width)
                    rankBg:addChild(noHeadIcon)
                end

                rankTitleBg:setPositionX(61)

                local titleLb = GetTTFLabel(getlocal("rank_reward_str",{1,rankInfoTb[2]}),strSize2)
                titleLb:setAnchorPoint(ccp(0,0.5))
                titleLb:setPosition(10,rankTitleBg:getContentSize().height * 0.5)
                rankTitleBg:addChild(titleLb)

                hurtValue = rankInfoTb[5]
                rewardTb = rankInfoTb[8]
                hurtLb = GetTTFLabel(getlocal("totalDamageText1").."："..FormatNumber(tonumber(hurtValue) or 0),strSize2)
            else
                local titleLb = GetTTFLabel(getlocal("rewardIndex",{idx+1}),strSize2)
                titleLb:setAnchorPoint(ccp(0,0.5))
                titleLb:setPosition(5,rankTitleBg:getContentSize().height * 0.5)
                rankTitleBg:addChild(titleLb)

                --dailyanswer_rank_rewardlimit2
                local rankArea = rankInfoTb[2]
                local lb2Str = idx < 3 and getlocal("dailyanswer_rank_rewardlimit2",{rankArea[1],rankArea[2],""}) or getlocal("behindLevel",{rankArea[1]})
                local titleLb2 = GetTTFLabel(lb2Str,strSize2)
                titleLb2:setAnchorPoint(ccp(0,0.5))
                titleLb2:setPosition(10 + titleLb:getContentSize().width,rankTitleBg:getContentSize().height * 0.5)
                rankTitleBg:addChild(titleLb2)

                rewardTb = rankInfoTb[3]

                hurtLb = GetTTFLabel(getlocal("totalDamageText",{FormatNumber(tonumber(hurtValue) or 0)}),strSize2)
            end

            hurtLb:setAnchorPoint(ccp(1,0.5))
            hurtLb:setPosition(bgWidth - 5, bgHeight - 20)
            rankBg:addChild(hurtLb)
            for k,v in pairs(rewardTb) do
                local function callback( )
                    G_showNewPropInfo(self.layerNum+1,true,nil,nil,v,nil,nil,nil)
                end

                local icon,scale = G_getItemIcon(v,60,false,self.layerNum,callback,nil)
                icon:setTouchPriority(-(self.layerNum-1)*20-3)
                rankBg:addChild(icon)
                icon:setAnchorPoint(ccp(0,0))
                icon:setPosition(40 + ( k - 1) * 70,10)

                local numLb = GetTTFLabel("x" .. FormatNumber(v.num),20)
                numLb:setAnchorPoint(ccp(1,0))
                icon:addChild(numLb,4)
                numLb:setPosition(icon:getContentSize().width-5, 5)
                numLb:setScale(1/scale)

                local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
                numBg:setAnchorPoint(ccp(1,0))
                numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-5))
                numBg:setPosition(ccp(icon:getContentSize().width-5,5))
                numBg:setOpacity(150)
                icon:addChild(numBg,3)
            end

            return cell
        end
    end
    local hd=LuaEventHandler:createHandler(tvCallBack)
    local tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth, tvHeight),nil)
    tableView:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    tableView:setPosition(ccp(15,135))
    self.bgLayer:addChild(tableView,2)
    tableView:setMaxDisToBottomOrTop(100)
end

function acThrivingSmallDialog:dispose()
    self.tv = nil
    self.id = nil
    self.checkSp = nil
    self.wholeBgSp=nil
    self.dialogWidth=nil
    self.dialogHeight=nil
    self.awardBtn = nil
    self.isTouch=nil
    self.bgLayer=nil
    self.bgSize=nil
    self.dialogLayer=nil
    self.timeLb = nil
    if self.multiTab then
        self.multiTab:dispose()
        self.multiTab=nil
    end
end

function acThrivingSmallDialog:tick( )
    if self.timeLb then
        local timeStr,timeStr2=acThrivingVoApi:getTimer()
        self.timeLb:setString(timeStr2)
    end
    if self.awardTb[1] == "airShipLastDayRank" then
        if self.airshipLastTLb then
            self.airshipLastTLb:setString( airShipVoApi:getLastDayRankAwardTime() )
        end
    elseif ( self.awardTb[1] == "xlpdShop" or self.awardTb[1] == "xlpdLog" ) then
        if acXlpdVoApi:isEnd() then
            self:close()
        elseif self.awardTb[1] == "xlpdShop" then
            self.shopTimeLb:setString(acXlpdVoApi:getShopTime())
        end
    elseif self.awardTb[1] == "xlpdInvite" then
        if acXlpdVoApi:getStatus() ~= 1 then
            self:close()
        end
        if self.inviteTimeLb and tolua.cast(self.inviteTimeLb,"CCLabelTTF") then
            local isNotCanPost,oldPostTime = acXlpdVoApi:getPostTime()
            if isNotCanPost == true then
                self.inviteTimeLb:setString(oldPostTime)
            else
                print("====xlpdInvite refresh====")
                if self.tv and tolua.cast(self.tv,"LuaCCTableView") then
                    self.tv:reloadData()
                end
            end
        end
    elseif self.awardTb[1] == "xlpdMyTeam" then
        if acXlpdVoApi:getStatus() ~= 1 then
            self:close()
        end
    elseif self.awardTb[1] == "nsAddUpAward" or self.awardTb[1] == "nsCheckIn" then
        if self.awardTb[9] ~= newSignInVoApi:isToday( ) then
            -- print(" here in tick~~~~~")
            self:close()
        elseif not newSignInVoApi:lastSignInMonth( ) then
            self:close()
        end
    elseif self.awardTb[1] == "hljbEx" or self.awardTb[1] == "hljbKeep" or self.awardTb[1] == "hljbTake" then
        if acHljbVoApi then
            local acVo = acHljbVoApi:getAcVo()
            if not activityVoApi:isStart(acVo) then
                self:close()
            end
            if self.awardTb[5] ~= acHljbVoApi:getCurDay( ) then
                self:close()
            end
        else
            self:close()
        end
    end
end

function acThrivingSmallDialog:refresh( )
    if self.awardTb then
        if self.awardTb[1] == "xlpdShop" then
            if self.tv then
                local recordPoint=self.tv:getRecordPoint()
                self.tv:reloadData()
                self.tv:recoverToRecordPoint(recordPoint)
            end
        end
    end
end

function acThrivingSmallDialog:close()
    self.teamInfo = nil
    self.xlpdTvCellNum     = nil
    self.xlpdJoinChooseIdx = nil
    self.xlpdLogChooseIdx  = nil
    self.shopTimeLb   = nil
    self.veriImageNum = nil
    self.autionNum = nil
    self.autionNumLb = nil
    self.newPicTb  = nil
    self.tv        = nil
    self.awardBtn  = nil
    self.timeLb    = nil
    self.checkSp   = nil
    self.wholeBgSp =nil
    self.dialogWidth=nil
    self.dialogHeight=nil
    self.isTouch=nil
    self.bgLayer=nil
    self.bgSize=nil
    if self and self.dialogLayer then
        self.dialogLayer:removeFromParentAndCleanup(true)
        self.dialogLayer=nil
    end
    -- if self and self.bgLayer then
    --     self.bgLayer:removeFromParentAndCleanup(true)
    --     self.bgLayer=nil
    -- end
    base:removeFromNeedRefresh(self)
end