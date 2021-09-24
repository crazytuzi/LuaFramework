acSweetTroubleTab1 ={}
function acSweetTroubleTab1:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.bgLayer=nil
    self.layerNum=nil
    self.touchDialogBg=nil
    self.tv=nil
    self.upBg=nil
    self.middleBg=nil
    self.downBg=nil
    self.isToday =nil
    self.bgimage =nil
    self.dialog =nil
    self.firstRecharLabel=nil
    self.cellHight = nil
    if G_getIphoneType() == G_iphoneX then
        self.cellHight = G_VisibleSizeHeight -200
    elseif G_getIphoneType() == G_iphone4 then
        self.cellHight = G_VisibleSizeHeight + 300
    else
        self.cellHight = G_VisibleSizeHeight
    end
    self.newscale = 0.8
    return nc;

end

function acSweetTroubleTab1:init(layerNum)
    self.isToday =acSweetTroubleVoApi:isToday()
    if acSweetTroubleVoApi:isToday() ==true then
        -- print("----setIsCrossToday---")
        acSweetTroubleVoApi:setIsCrossToday(false)
    end
    self.bgLayer=CCLayer:create()
    self.layerNum = layerNum

    self:initTableView()

    return self.bgLayer
end

function acSweetTroubleTab1:initTableView()
    local function click(hd,fn,idx)
    end
    local bigBg-- =CCSprite:createWithSpriteFrameName("halloweenBg.jpg")--LuaCCScale9Sprite:createWithSpriteFrameName("halloweenBg.jpg",CCRect(20, 20, 10, 10),clickk)
    -- bigBg:setContentSize(CCSizeMake(G_VisibleSizeWidth ,G_VisibleSizeHeight))
    if platCfg.platCfgNewTypeAddTank==true then
        bigBg=CCSprite:create("ship/newTank/halloweenBg.jpg")
    else
        bigBg =CCSprite:createWithSpriteFrameName("halloweenBg.jpg")--LuaCCScale9Sprite:createWithSpriteFrameName("halloweenBg.jpg",CCRect(20, 20, 10, 10),clickk)
    -- bigBg:setContentSize(CCSizeMake(G_VisibleSizeWidth ,G_VisibleSizeHeight))
    end
    bigBg:setScaleX((G_VisibleSizeWidth-42)/bigBg:getContentSize().width)
    bigBg:setScaleY((G_VisibleSizeHeight-186)/bigBg:getContentSize().height)
    bigBg:setOpacity(150)
    bigBg:setAnchorPoint(ccp(0.5,0.5))
    bigBg:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*0.5-68))
    self.bgLayer:addChild(bigBg)

    local function callBack(...)
         return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth,G_VisibleSize.height-200),nil)-- -200
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(0,40))--40
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)--120

end

function acSweetTroubleTab1:eventHandler( handler,fn,idx,cel )
  if fn=="numberOfCellsInTableView" then
    return 1
  elseif fn=="tableCellSizeForIndex" then
    return  CCSizeMake(G_VisibleSizeWidth-42,self.cellHight)-- -100
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    self:initUpBg(cell)
    self:initDownBg(cell)
    return cell
  elseif fn=="ccTouchBegan" then
    self.isMoved=false
    return true
  elseif fn=="ccTouchMoved" then
    self.isMoved=true
  elseif fn=="ccTouchEnded"  then
  end
end

function acSweetTroubleTab1:initUpBg(cell)
    local needO = 150
    local upBgNeedHeight = self.cellHight*0.3
    if base.ifSuperWeaponOpen ==1 then
        upBgNeedHeight = self.cellHight*0.4
    end
    if base.gxh ==0 then
        upBgNeedHeight = self.cellHight*0.12
        needO = 0
    end
    local needAddHeight =0
    local needBgAddHeight =0
    if G_getIphoneType() == G_iphone4 then
        upBgNeedHeight = upBgNeedHeight - 50
    end
    local function click(hd,fn,idx)
    end
    self.upBg =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),click)
    self.upBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 44,upBgNeedHeight))
    self.upBg:setOpacity(needO)
    self.upBg:setAnchorPoint(ccp(0.5,1))
    self.upBg:setPosition(ccp(G_VisibleSizeWidth*0.5,self.cellHight))
    cell:addChild(self.upBg)

    local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),28)
    acLabel:setAnchorPoint(ccp(0.5,1))
    acLabel:setPosition(ccp(self.upBg:getContentSize().width*0.5,self.upBg:getContentSize().height-5))
    self.upBg:addChild(acLabel)

    local acVo = acSweetTroubleVoApi:getAcVo()
    local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
    local messageLabel=GetTTFLabel(timeStr,28)
    messageLabel:setAnchorPoint(ccp(0.5,1))
    messageLabel:setPosition(ccp(acLabel:getPositionX(), acLabel:getPositionY()-30))
    self.upBg:addChild(messageLabel)
    self.timeLb=messageLabel
    self:updateAcTime()

    local function touch(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end

        PlayEffect(audioCfg.mouseClick)
        if tag == 1 then
            self:openInfo()
        elseif tag ==2 then
            if acSweetTroubleVoApi:getRecvedSnatReward( ) ==0 then
                local challengeVo=superWeaponVoApi:getSWChallenge()
                local openLv=base.superWeaponOpenLv or 25
                if playerVoApi:getPlayerLevel() >=openLv then
                    if challengeVo.maxClearPos ==nil or challengeVo.maxClearPos<1 then
                        
                        self.dialog:close()
                        activityAndNoteDialog:closeAllDialog()
                        superWeaponVoApi:showMainDialog(self.layerNum)
                    else 

                        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/superWeapon/swChallenge.plist")
                        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/localWar/localWar.plist")
                        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/superWeapon/superWeapon.plist")
                        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/hero/heroHonor.plist")
                        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("allianceWar/warMap.plist")
                        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/refiningImage.plist")
                        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/superWeapon/energyCrystal.plist")
                        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("serverWar/serverWar.plist")
                        
                        self.dialog:close()
                        activityAndNoteDialog:closeAllDialog()
                        superWeaponVoApi:showRobDialog(self.layerNum)
                    end
                else
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("port_scene_building_tip_102",{openLv}),30)
                end
            end
        elseif tag ==3 then
            --第一个领奖动画
            if acSweetTroubleVoApi:getRecvedSnatReward() ==0 then
                local function callback(fn,data)
                    local ret,sData = base:checkServerData(data)
                    if ret==true then
                        if sData.data and sData.data.halloween and  sData.data.halloween.swr==1 then
                            acSweetTroubleVoApi:setRecvedSnatReward()
                            --播放动画
                            self.tv:reloadData() --"BlackAlphaBg.png"
                            local paramTab={}
                            paramTab.functionStr="halloween"
                            paramTab.addStr="i_also_want"
                            local shwoMessage = getlocal("activity_sweettrouble_chatShow",{playerVoApi:getPlayerName(),getlocal("activity_halloween_title"),getlocal("activity_sweettrouble_seed_4")})
                            chatVoApi:sendSystemMessage(shwoMessage,paramTab)
                            local params = {key="activity_sweettrouble_chatShow",param={{playerVoApi:getPlayerName(),1},{"activity_halloween_title",2},{"activity_sweettrouble_seed_4",5}}}
                            chatVoApi:sendUpdateMessage(41,params)
                            self:displayGetReward(1)
                            G_addPlayerAward("p","p893","893",1)
                        end
                    end
                end
                if superWeaponVoApi:isCanPlunder() then
                    socketHelper:halloweenReward("swreward",callback,nil,nil,"wp")
                else
                    socketHelper:halloweenReward("swreward",callback)
                end
            end
        elseif tag ==4 then 
            --称号
            if acSweetTroubleVoApi:getCropedReward( ) ==0 then
                local function callback(fn,data)
                    local ret,sData = base:checkServerData(data)
                    if ret==true then
                        if sData.data and sData.data.halloween and  sData.data.halloween.pcr==1 then
                            acSweetTroubleVoApi:setCropedReward()
                            --播放动画
                            self.tv:reloadData()
                            self:displayGetReward(2)
                            G_addPlayerAward("p","p895","895",1)
                        end
                    end
                end
                socketHelper:halloweenReward("plantreward",callback)
            end
        end
    end
    local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon2.png",touch,1,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,1))
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
    menuDesc:setPosition(ccp(self.upBg:getContentSize().width-5,self.upBg:getContentSize().height-5))
    self.upBg:addChild(menuDesc)

    local needWidth = 15
    local needSubHeight = 50

    local strSize2 = 20
    local strSize3 = 30
    local needHeightPos = 25
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =25
        strSize3 =40
        needHeightPos =0
    end

    local  firstUpWidth = needWidth
    local  firstUpHeight = messageLabel:getPositionY()-60
---------------------
    if base.gxh ==1 then
        if base.ifSuperWeaponOpen ==1 then

                local headPic = CCSprite:createWithSpriteFrameName("equipBg_orange.png")
                headPic:setScale(100 / headPic:getContentSize().width)
                headPic:setPosition(ccp(needWidth,messageLabel:getPositionY()-60))
                headPic:setAnchorPoint(ccp(0,1))
                self.upBg:addChild(headPic)

                local sweet_4 =CCSprite:createWithSpriteFrameName("sweet_4.png")
                sweet_4:setScale(100 / headPic:getContentSize().width)
                sweet_4:setPosition(getCenterPoint(headPic))
                sweet_4:setAnchorPoint(ccp(0.5,0.5))
                headPic:addChild(sweet_4)


                local needSnatchCouts = acSweetTroubleVoApi:getAsCounts()
                local upShowStrWrap = GetTTFLabelWrap(getlocal("activity_sweettrouble_upShowStr",{needSnatchCouts}),strSize2,CCSizeMake(self.upBg:getContentSize().width*0.6-50,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                upShowStrWrap:setAnchorPoint(ccp(0,1))
                upShowStrWrap:setPosition(ccp(headPic:getContentSize().width+needWidth,headPic:getPositionY()+needHeightPos))
                self.upBg:addChild(upShowStrWrap)
             
                local gotoBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",touch,2,getlocal("activity_heartOfIron_goto"),25)
                gotoBtn:setAnchorPoint(ccp(1,0.5))
                gotoBtn:setScale(self.newscale)
                local gotoMenu=CCMenu:createWithItem(gotoBtn)
                gotoMenu:setPosition(ccp(self.upBg:getContentSize().width-10,headPic:getPositionY()-headPic:getContentSize().height*0.5))
                gotoMenu:setTouchPriority(-(self.layerNum-1)*20-2)
                gotoMenu:setTag(111)
                self.upBg:addChild(gotoMenu)
    
                local gotoRecevBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",touch,3,getlocal("newGiftsReward"),25)
                gotoRecevBtn:setScale(self.newscale)
                gotoRecevBtn:setAnchorPoint(ccp(1,0.5))
                local gotoRecevMenu=CCMenu:createWithItem(gotoRecevBtn)
                gotoRecevMenu:setPosition(ccp(self.upBg:getContentSize().width-10,headPic:getPositionY()-headPic:getContentSize().height*0.5))
                gotoRecevMenu:setTouchPriority(-(self.layerNum-1)*20-2)
                gotoRecevMenu:setTag(115)
                self.upBg:addChild(gotoRecevMenu)

                local snatchedCounts = acSweetTroubleVoApi:getSnatchedCounts()
                if snatchedCounts >needSnatchCouts then
                    snatchedCounts = needSnatchCouts
                end
                local snatchCounts = GetTTFLabelWrap(getlocal("activity_sweettrouble_snatchCounts",{snatchedCounts,needSnatchCouts}),strSize2,CCSizeMake(gotoMenu:getContentSize().width+50,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
                snatchCounts:setAnchorPoint(ccp(1,1))
                snatchCounts:setPosition(ccp(gotoMenu:getPositionX(),gotoMenu:getPositionY()-needSubHeight))
                snatchCounts:setColor(G_ColorRed)
                snatchCounts:setTag(112)
                self.upBg:addChild(snatchCounts)

                if (needSnatchCouts <= snatchedCounts or superWeaponVoApi:isCanPlunder()) and acSweetTroubleVoApi:getRecvedSnatReward() ==0 then
                    gotoBtn:setVisible(false)
                    gotoRecevBtn:setVisible(true)
                    snatchCounts:setVisible(false)
                else
                    gotoRecevBtn:setVisible(false)
                    gotoBtn:setVisible(true)
                end
                if acSweetTroubleVoApi:getRecvedSnatReward() ==1 then
                    gotoRecevBtn:setVisible(true)
                    gotoRecevBtn:setEnabled(false)
                    snatchCounts:setVisible(false)
                end

                firstUpHeight =snatchCounts:getPositionY()-needSubHeight
        end
    -------------------------捣蛋专家模块
        local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
        lineSp:setAnchorPoint(ccp(0.5,0))
        lineSp:setScale(0.95)
        lineSp:setPosition(ccp(self.upBg:getContentSize().width*0.5,firstUpHeight+needAddHeight))
        self.upBg:addChild(lineSp)

        local getTitle = GetTTFLabelWrap(getlocal("player_title_name_11"),strSize3,CCSizeMake(self.upBg:getContentSize().width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        getTitle:setAnchorPoint(ccp(0.5,1))
        getTitle:setPosition(ccp(self.upBg:getContentSize().width*0.5,lineSp:getPositionY()-10))
        getTitle:setColor(G_ColorYellowPro)
        self.upBg:addChild(getTitle)    


        local head2Pic = CCSprite:createWithSpriteFrameName("sweetsBox.png")
        -- head2Pic:setScale(100 / head2Pic:getContentSize().width)
        head2Pic:setPosition(ccp(needWidth,lineSp:getPositionY()-30))
        head2Pic:setAnchorPoint(ccp(0,1))
        self.upBg:addChild(head2Pic)
        local needCropCounts = acSweetTroubleVoApi:getCropCounts()
        local upTwoStr = GetTTFLabelWrap(getlocal("activity_sweettrouble_upShowTwoStr",{needCropCounts}),strSize2,CCSizeMake(self.upBg:getContentSize().width*0.5,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        upTwoStr:setAnchorPoint(ccp(0,1))
        upTwoStr:setPosition(ccp(needWidth+10+head2Pic:getContentSize().width,getTitle:getPositionY()-needSubHeight*1.3+needHeightPos))
        self.upBg:addChild(upTwoStr) 
        local  adaH = 0
        if G_getIphoneType() == G_iphoneX then
            adaH = 25
        end
        local recevBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",touch,4,getlocal("newGiftsReward"),25)
        recevBtn:setAnchorPoint(ccp(1,1))
        recevBtn:setScale(self.newscale)
        local recevMenu=CCMenu:createWithItem(recevBtn)
        recevMenu:setPosition(ccp(self.upBg:getContentSize().width-10,upTwoStr:getPositionY()+adaH))
        recevMenu:setTouchPriority(-(self.layerNum-1)*20-2)
        recevMenu:setTag(113)
        recevBtn:setEnabled(false)
        self.upBg:addChild(recevMenu)

        local cropedCounts = acSweetTroubleVoApi:getCropedCounts()
        if needCropCounts < cropedCounts then
            cropedCounts = needCropCounts
        end
        local cropCounts = GetTTFLabelWrap(getlocal("activity_sweettrouble_cropCounts",{cropedCounts,needCropCounts}),strSize2,CCSizeMake(recevMenu:getContentSize().width+50,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
        cropCounts:setAnchorPoint(ccp(1,1))
        cropCounts:setPosition(ccp(recevMenu:getPositionX(),recevMenu:getPositionY()-needSubHeight*1.6-needHeightPos))
        cropCounts:setColor(G_ColorRed)
        cropCounts:setTag(114)
        self.upBg:addChild(cropCounts)
        if tonumber(needCropCounts) <=tonumber(cropedCounts) and acSweetTroubleVoApi:getCropedReward( ) == 0 then
            recevBtn:setEnabled(true)
            cropCounts:setVisible(false)
        elseif acSweetTroubleVoApi:getCropedReward( ) ==1 then
            recevBtn:setEnabled(false)
            cropCounts:setVisible(false)
        end

    end
end

function acSweetTroubleTab1:initDownBg(cell)

    local strSizeD2 = 22
    local frSize = 25
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSizeD2 =28
    end
    if G_getCurChoseLanguage() =="fr" then
        frSize =18
    end

    local needBgSubHeight = 0
    local bgSer = 0.3
    local bgDownSer = 0.3
    local needBgAddHeight =250
    if base.ifSuperWeaponOpen ==0 then
        needBgSubHeight =self.cellHight*0.1
    end
    if base.gxh ==0 then
        needBgSubHeight =self.cellHight*0.32
    end
    if G_isIphone5() then
        bgSer =0.25
        bgDownSer =0.4
        needBgAddHeight= 30
        if base.gxh ==0 then
            bgSer = 0.3
            bgDownSer = 0.3
            needBgAddHeight =250
            needBgSubHeight =self.cellHight*0.1
        end
    end
    local function touch(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end

        PlayEffect(audioCfg.mouseClick)
        if tag == 1 then
            if acSweetTroubleVoApi:getCountsByDay() >0 then
                local function callback(fn,data)
                    local ret,sData = base:checkServerData(data)
                    if ret==true then
                        if sData.data and sData.data.halloween.dc and sData.data.halloween.drc and sData.data.halloween.tg then
                            acSweetTroubleVoApi:setFirstAllCounts(sData.data.halloween.dc )
                            acSweetTroubleVoApi:setFirstRecvedCounts( sData.data.halloween.drc)
                            acSweetTroubleVoApi:setTgSeedTab( sData.data.halloween.tg )
                            print("飘板提示首充领奖信息---------")
                            self.tv:reloadData()
                             local rewardTab = acSweetTroubleVoApi:getTotalRewardShowTab(1)
                            for k,v in pairs(rewardTab) do

                                    -- print("v.type, v.key, v.id,tonumber(v.num)",v.type, v.key, v.id,tonumber(v.num))
                                    G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num))
                                    
                            end
                            G_showRewardTip(rewardTab)

                            acSweetTroubleVoApi:afterExchange()
                        end
                    end
                end
                socketHelper:halloweenReward("dayreward",callback)
            end
        elseif tag ==2 then
            -- print("second get reward !!!!!!")
            local idxs =  acSweetTroubleVoApi:getCountsByTotal( )
            if acSweetTroubleVoApi:getCountsByTotal() >0 then
                local function callback(fn,data)
                    local ret,sData = base:checkServerData(data)
                    if ret==true then
                        if sData.data and sData.data.halloween.c and sData.data.halloween.num and sData.data.halloween.c then
                            print("飘板提示累计充值领奖信息---------")
                            acSweetTroubleVoApi:setAllgolds(sData.data.halloween.num )
                            acSweetTroubleVoApi:setRecvedGoldsCounts(sData.data.halloween.c )
                            if sData.data.halloween.tg then
                                acSweetTroubleVoApi:setTgSeedTab( sData.data.halloween.tg )
                            end
                            self.tv:reloadData()
                            local rewardTab = acSweetTroubleVoApi:getTotalRewardShowTab(2)
                            for k,v in pairs(rewardTab) do
                                v.num = tonumber(v.num)*idxs
                                    G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num))
                            end
                            G_showRewardTip(rewardTab)
                            
                            acSweetTroubleVoApi:afterExchange()
                        end
                    end
                end
                socketHelper:halloweenReward("totalreward",callback)
            end
        elseif tag ==3 then
            -- print(" go to recharge!!!!!")
            vipVoApi:showRechargeDialog(self.layerNum+1)
        end
    end
    local adaSizeH = 0
    if G_getIphoneType() == G_iphone4 then
        adaSizeH = 60
    end
    local function click(hd,fn,idx)
    end
    self.middleBg =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),click)
    self.middleBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 44,self.cellHight*bgSer+20-adaSizeH))
    self.middleBg:ignoreAnchorPointForPosition(false)
    self.middleBg:setAnchorPoint(ccp(0.5,1))
    self.middleBg:setOpacity(150)
    if G_isIphone5() == true or G_getIphoneType() == G_iphoneX then
        self.middleBg:setPosition(ccp(G_VisibleSizeWidth*0.5,self.cellHight*0.6-100+needBgSubHeight+needBgAddHeight+70))
    else
        self.middleBg:setPosition(ccp(G_VisibleSizeWidth*0.5,self.cellHight*0.6-100+needBgSubHeight+needBgAddHeight-110))
    end
    cell:addChild(self.middleBg)

    local middleTitle = GetTTFLabelWrap(getlocal("activity_sweettrouble_firstRecharge"),28,CCSizeMake(self.middleBg:getContentSize().width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    middleTitle:setAnchorPoint(ccp(0.5,1))
    middleTitle:setPosition(ccp(self.middleBg:getContentSize().width*0.5,self.middleBg:getContentSize().height-55))
    middleTitle:setColor(G_ColorYellowPro)
    self.middleBg:addChild(middleTitle) 

    local lineSp2=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp2:setAnchorPoint(ccp(0.5,0))
    lineSp2:setScale(0.95)
    lineSp2:setPosition(ccp(self.middleBg:getContentSize().width*0.5,middleTitle:getPositionY()-40))
    self.middleBg:addChild(lineSp2)

    local middleShow = acSweetTroubleVoApi:getTotalRewardShowTab(1)
    for i=1,4 do
        local iconPic = middleShow[i].pic
        local iconNum = middleShow[i].num
        local middlepic = nil
        if  middleShow[i].equipId =="t4" then
            middlepic ="equipBg_orange.png"
        elseif  middleShow[i].equipId =="t3" then
            middlepic ="equipBg_purple.png"
        elseif  middleShow[i].equipId =="t2" then
            middlepic ="equipBg_blue.png"
        elseif  middleShow[i].equipId =="t1" then
            middlepic ="equipBg_green.png"
        else
            middlepic = "Icon_BG.png"
        end

        local function showInfoHandler(hd,fn,idx)
            local item=middleShow[i]
            if item and item.name and item.pic and item.num and item.desc then
                propInfoDialog:create(sceneGame,item,self.layerNum+10,nil,true)
            end
        end

        local middlePic = LuaCCSprite:createWithSpriteFrameName(middlepic,showInfoHandler)
        middlePic:setTouchPriority(-(self.layerNum-1)*20-2)
        local needWidth = self.middleBg:getContentSize().width*0.14*i+self.middleBg:getContentSize().width*0.1*(i-1)
        local needHeight = self.middleBg:getContentSize().height*0.6-10
        middlePic:setScale(100 / middlePic:getContentSize().width)
        middlePic:setAnchorPoint(ccp(0.5,0.5))
        if G_getIphoneType() == G_iphoneX then
            middlePic:setPosition(ccp(self.middleBg:getContentSize().width*0.14*i+self.middleBg:getContentSize().width*0.1*(i-1),self.middleBg:getContentSize().height*0.6-35))
        elseif G_getIphoneType() == G_iphone5 then
            middlePic:setPosition(ccp(self.middleBg:getContentSize().width*0.14*i+self.middleBg:getContentSize().width*0.1*(i-1),self.middleBg:getContentSize().height*0.6-50))
        else
            middlePic:setPosition(ccp(self.middleBg:getContentSize().width*0.14*i+self.middleBg:getContentSize().width*0.1*(i-1),self.middleBg:getContentSize().height*0.6-10)) 
        end
        self.middleBg:addChild(middlePic)

        local iconPicShow = CCSprite:createWithSpriteFrameName(iconPic)
        iconPicShow:setScale(0.8)
        iconPicShow:setPosition(getCenterPoint(middlePic))
        iconPicShow:setAnchorPoint(ccp(0.5,0.5))
        middlePic:addChild(iconPicShow)
        local adaH2 = 0
        if G_getIphoneType() == G_iphoneX or G_getIphoneType() == G_iphone5 then
            adaH2 = 25
        end
        local iconLabel = GetTTFLabel("x"..iconNum,25)
        iconLabel:setAnchorPoint(ccp(1,0))
        iconLabel:setPosition(ccp(needWidth+46,needHeight-48-adaH2))
        self.middleBg:addChild(iconLabel,2)
    end

    local countsByDay = acSweetTroubleVoApi:getCountsByDay()
    local canRecCountsStr = GetTTFLabelWrap(getlocal("activity_sweettrouble_canRecCountsStr",{countsByDay}),frSize,CCSizeMake(self.middleBg:getContentSize().width*0.65-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    canRecCountsStr:setAnchorPoint(ccp(0,0.5))
    canRecCountsStr:setPosition(ccp(25,30))
    canRecCountsStr:setTag(221)
    self.middleBg:addChild(canRecCountsStr)

    self.firstRecharLabel=GetTTFLabelWrap(getlocal("activity_sweettrouble_noFirst"),frSize,CCSizeMake(self.middleBg:getContentSize().width*0.65-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    self.firstRecharLabel:setAnchorPoint(ccp(0,0.5))
    self.firstRecharLabel:setPosition(ccp(25,60))
    if G_getIphoneType() == G_iphoneX then
        self.firstRecharLabel:setPosition(ccp(25,75))
    end
    -- self.firstRecharLabel:setTag(2221)
    self.middleBg:addChild(self.firstRecharLabel)

    local isCross = acSweetTroubleVoApi:getIsCrossToday()
      -- if self.isToday ==0 then
      --   self.firstRecharLabel:setVisible(true)
      -- print("isCross---->",isCross)
      if isCross then
        self.firstRecharLabel:setVisible(true)
      else
        self.firstRecharLabel:setVisible(false)
      end
    local recevBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",touch,1,getlocal("newGiftsReward"),25)
    recevBtn:setAnchorPoint(ccp(1,0))
    recevBtn:setScale(self.newscale)
    local recevMenu=CCMenu:createWithItem(recevBtn)
    recevMenu:setPosition(ccp(self.middleBg:getContentSize().width-10,5))
    if G_getIphoneType() == G_iphoneX then
        recevMenu:setPosition(ccp(self.middleBg:getContentSize().width-10,20))
    end
    recevMenu:setTouchPriority(-(self.layerNum-1)*20-2)
    recevMenu:setTag(222)
    self.middleBg:addChild(recevMenu)
    if countsByDay > 0 then
        recevBtn:setEnabled(true)
    else
        recevBtn:setEnabled(false)
    end

-------
    self.downBg =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),click)
    self.downBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 44,self.cellHight*bgSer+20-adaSizeH))
    self.downBg:ignoreAnchorPointForPosition(false)
    self.downBg:setAnchorPoint(ccp(0.5,1))
    self.downBg:setOpacity(150)
    if  G_getIphoneType() == G_iphoneX then
        self.downBg:setPosition(ccp(G_VisibleSizeWidth*0.5,self.cellHight*bgDownSer-120+needBgSubHeight+needBgAddHeight+20))
    elseif G_getIphoneType() == G_iphone5 then
        self.downBg:setPosition(ccp(G_VisibleSizeWidth*0.5,self.cellHight*bgDownSer-120+needBgSubHeight+needBgAddHeight+20))
    else
        self.downBg:setPosition(ccp(G_VisibleSizeWidth*0.5,self.cellHight*bgDownSer-120+needBgSubHeight+needBgAddHeight-55))
    end
    cell:addChild(self.downBg)

    local needCost = acSweetTroubleVoApi:getNeedCost()
    local downTitle = GetTTFLabelWrap(getlocal("activity_sweettrouble_secondRecharge",{needCost}),strSizeD2,CCSizeMake(self.downBg:getContentSize().width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    downTitle:setAnchorPoint(ccp(0.5,1))
    downTitle:setPosition(ccp(self.downBg:getContentSize().width*0.5,self.downBg:getContentSize().height-15))
    downTitle:setColor(G_ColorYellowPro)
    self.downBg:addChild(downTitle) 

    local lineSp3=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp3:setAnchorPoint(ccp(0.5,0))
    lineSp3:setScale(0.95)
    lineSp3:setPosition(ccp(self.downBg:getContentSize().width*0.5,downTitle:getPositionY()-40))
    self.downBg:addChild(lineSp3)

    local totalShow = acSweetTroubleVoApi:getTotalRewardShowTab(2)
    for i=1,4 do
        local iconPic = totalShow[i].pic
        local iconNum = totalShow[i].num
        local needWidth = self.downBg:getContentSize().width*0.14*i+self.downBg:getContentSize().width*0.1*(i-1)
        local needHeight = self.downBg:getContentSize().height*0.6-10
        if  totalShow[i].equipId =="t4" then
            downpic ="equipBg_orange.png"
        elseif  totalShow[i].equipId =="t3" then
            downpic ="equipBg_purple.png"
        elseif  totalShow[i].equipId =="t2" then
            downpic ="equipBg_blue.png"
        elseif  totalShow[i].equipId =="t1" then
            downpic ="equipBg_green.png"
        else
            downpic = "Icon_BG.png"
        end

        local function showInfoHandler(hd,fn,idx)
            local item=totalShow[i]
            if item and item.name and item.pic and item.num and item.desc then
                propInfoDialog:create(sceneGame,item,self.layerNum+10,nil,true)
            end
        end

        downPic = LuaCCSprite:createWithSpriteFrameName(downpic,showInfoHandler)
        downPic:setTouchPriority(-(self.layerNum-1)*20-2)
        downPic:setScale(100 / downPic:getContentSize().width)
        downPic:setPosition(ccp(self.downBg:getContentSize().width*0.14*i+self.downBg:getContentSize().width*0.1*(i-1),self.downBg:getContentSize().height*0.6-10))
        downPic:setAnchorPoint(ccp(0.5,0.5))
        self.downBg:addChild(downPic)

        local iconPicShow = CCSprite:createWithSpriteFrameName(iconPic)
        iconPicShow:setScale(0.8)
        iconPicShow:setPosition(getCenterPoint(downPic))
        iconPicShow:setAnchorPoint(ccp(0.5,0.5))
        downPic:addChild(iconPicShow)

        local iconLabel = GetTTFLabel("x"..iconNum,25)
        iconLabel:setAnchorPoint(ccp(1,0))
        iconLabel:setPosition(ccp(needWidth+46,needHeight-48))
        self.downBg:addChild(iconLabel,2)
    end

    local countsByTotal = acSweetTroubleVoApi:getCountsByTotal()
    local lastRecCountsStr = GetTTFLabelWrap(getlocal("activity_sweettrouble_canRecCountsStr",{countsByTotal}),frSize,CCSizeMake(self.downBg:getContentSize().width*0.65,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    lastRecCountsStr:setAnchorPoint(ccp(0,0.5))
    lastRecCountsStr:setPosition(ccp(25,30))
    lastRecCountsStr:setTag(223)
    self.downBg:addChild(lastRecCountsStr)
    local recevBtn2=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",touch,2,getlocal("newGiftsReward"),25)
    recevBtn2:setAnchorPoint(ccp(1,0))
    recevBtn2:setScale(self.newscale)
    local recevMenu2=CCMenu:createWithItem(recevBtn2)
    recevMenu2:setPosition(ccp(self.downBg:getContentSize().width-10,5))
    if G_getIphoneType() == G_iphoneX then
        recevMenu2:setPosition(ccp(self.downBg:getContentSize().width-10,20))
    end
    recevMenu2:setTouchPriority(-(self.layerNum-1)*20-2)
    recevMenu2:setTag(224)
    self.downBg:addChild(recevMenu2)
    if countsByTotal > 0 then
        recevBtn2:setEnabled(true)
    else
        recevBtn2:setEnabled(false)
    end

    local rechargeNum = acSweetTroubleVoApi:getAllgolds( )-------
    local pieceNeed = needCost-------
    -- print("rechargeNum---------,pieceNeed,acSweetTroubleVoApi:getRecvedGoldsCounts()----->",rechargeNum,pieceNeed,acSweetTroubleVoApi:getRecvedGoldsCounts() +pieceNeed,pieceNeed* acSweetTroubleVoApi:getRecvedGoldsCounts() +pieceNeed)
    if rechargeNum>= needCost then
        if rechargeNum >= pieceNeed* acSweetTroubleVoApi:getRecvedGoldsCounts() +pieceNeed then
            rechargeNum= rechargeNum%pieceNeed
            -- print("ceilNum---->",ceilNum)
        else
            rechargeNum =rechargeNum-pieceNeed* acSweetTroubleVoApi:getRecvedGoldsCounts()
        end
    end
    local percentStr = rechargeNum.."/"..pieceNeed
    local percent = rechargeNum/pieceNeed*100
    if percent>needCost then
        percent =needCost
    end
    local proScaleX=0.9
    local proScaleY = 1.1
    local progress=nil
    if progress ==nil then
        postion = ccp(25,60)
        if G_getIphoneType() == G_iphoneX then
            postion = ccp(25,75)
        end
        AddProgramTimer(self.downBg,postion,225,226,percentStr,"platWarProgressBg.png","platWarProgress1.png",227,proScaleX,proScaleY)--225 前面图片 226 数字 227 背景图片
        progress =self.downBg:getChildByTag(225)
        local progressBg = self.downBg:getChildByTag(227)
        progress:setAnchorPoint(ccp(0,0.5))
        progressBg:setAnchorPoint(ccp(0,0.5))
        progress =tolua.cast(progress,"CCProgressTimer")
    end
    progress:setPercentage(percent)
    tolua.cast(progress:getChildByTag(226),"CCLabelTTF"):setString(percentStr)

    rewardBtn =GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",touch,3,getlocal("recharge"),25);
    rewardBtn:setScale(0.9)
    local rewardMenu=CCMenu:createWithItem(rewardBtn)
    rewardMenu:setAnchorPoint(ccp(0.5, 1))
    if G_getIphoneType() == G_iphoneX  then
        rewardMenu:setPosition(ccp(self.downBg:getContentSize().width*0.5,-30))
    elseif  G_getIphoneType() == G_iphone5 then
        rewardMenu:setPosition(ccp(self.downBg:getContentSize().width*0.5,-40))
    else
        rewardMenu:setPosition(ccp(self.downBg:getContentSize().width*0.5,-50))
    end
    rewardMenu:setTouchPriority(-(self.layerNum-1)*20-2)
    self.downBg:addChild(rewardMenu)  

end

function acSweetTroubleTab1:openInfo()
   local td=smallDialog:new()
      local tabStr = nil 
      tabStr ={"\n",getlocal("activity_sweettrouble_tip4"),"\n",getlocal("activity_sweettrouble_tip3"),"\n",getlocal("activity_sweettrouble_tip2"),"\n",getlocal("activity_sweettrouble_tip1"),"\n"}
      -- print("gxh----ifsu---->",base.gxh,base.ifSuperWeaponOpen)
    -- if base.gxh ==1 then
    --     tabStr ={"\n",getlocal("activity_sweettrouble_tip4"),"\n",getlocal("activity_sweettrouble_tip3"),"\n",getlocal("activity_sweettrouble_tip2"),"\n",getlocal("activity_sweettrouble_tip1"),"\n"}
    -- elseif base.ifSuperWeaponOpen ==1 then
    --     tabStr= {"\n",getlocal("activity_sweettrouble_tip5"),"\n",getlocal("activity_sweettrouble_tip3"),"\n",getlocal("activity_sweettrouble_tip2"),"\n",getlocal("activity_sweettrouble_tip1"),"\n"}
    -- else
    --     tabStr= {"\n",getlocal("activity_sweettrouble_tip3"),"\n",getlocal("activity_sweettrouble_tip2"),"\n",getlocal("activity_sweettrouble_tip1"),"\n"}
    -- end
  local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,nil)
  sceneGame:addChild(dialog,self.layerNum+1)
end

function acSweetTroubleTab1:tick( )
    if acSweetTroubleVoApi:isChanData(1) ==true then
        acSweetTroubleVoApi:setChanData(1,false)
        acSweetTroubleVoApi:updateLastTime()
        self.isToday = acSweetTroubleVoApi:isToday()
        acSweetTroubleVoApi:setIsCrossToday(false)
        self.firstRecharLabel:setVisible(false)
        self.tv:reloadData()
    end

      local istoday = acSweetTroubleVoApi:isToday()
      if istoday ~= self.isToday then
        acSweetTroubleVoApi:setIsCrossToday(true)
        self.firstRecharLabel:setVisible(true)
        self.isToday = istoday
        self.tv:reloadData()
      end
    self:updateAcTime()
end

function acSweetTroubleTab1:updateAcTime()
    local acVo=acSweetTroubleVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acSweetTroubleTab1:updata( )
    -- self.tv:reloadData() 
    if base.gxh ==1 then 
        local needCropCounts = acSweetTroubleVoApi:getCropCounts()
        local cropedCounts = acSweetTroubleVoApi:getCropedCounts()
        if needCropCounts < cropedCounts then
            cropedCounts = needCropCounts
        end
        -- print("cropedCounts , needCropCounts",cropedCounts ,needCropCounts,acSweetTroubleVoApi:getCropedReward( ))

        local recevBtn = tolua.cast(self.upBg:getChildByTag(113),"CCMenu")
        local cropCounts = tolua.cast(self.upBg:getChildByTag(114),"CCLabelTTF")
        local cropCountsBtn = tolua.cast(recevBtn:getChildByTag(4),"CCMenuItemSprite")
            cropCounts:setString(getlocal("activity_sweettrouble_cropCounts",{cropedCounts,needCropCounts}))
        if recevBtn and cropCountsBtn then
            if tonumber(needCropCounts) <=tonumber(cropedCounts) and acSweetTroubleVoApi:getCropedReward( ) == 0 then
                cropCountsBtn:setEnabled(true)
                cropCounts:setVisible(false)
            elseif acSweetTroubleVoApi:getCropedReward( ) ==1 then
                cropCountsBtn:setEnabled(false)
                cropCounts:setVisible(false)
            end
        end
    end
end
function acSweetTroubleTab1:displayGetReward(whiReward)--whiReward:1.头像 2.称号
    local function touchcallback( ... )
        
    end
    local reward = nil
    local rewardStr = nil
    if whiReward ==1 then
        rewardShow = "sweet_4.png"
        rewardStr ="activity_sweettrouble_seed_4"
    elseif whiReward ==2 then
        rewardShow ="player_title_name_11"
    end

    self.bgimage = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchcallback)
    self.bgimage:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
    self.bgLayer:addChild(self.bgimage,10)
    self.bgimage:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*0.5))
    self.bgimage:setTouchPriority(-(self.layerNum-1)*20-5)
    local node = CCNode:create()
    self.bgimage:addChild(node)
    node:setPosition(ccp(self.bgimage:getContentSize().width*0.5,self.bgimage:getContentSize().height*0.5))

    local lighticon = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
    if whiReward ==1 then
        node:addChild(lighticon)
    end
    lighticon:setPosition(ccp(0,0))
    lighticon:runAction(CCRepeatForever:create(CCRotateBy:create(0.5,40)))
    local icon = nil 
    local iconBg = nil
    local nbTitle = nil
    if whiReward ==1 then

        local iconBg = CCSprite:createWithSpriteFrameName("equipBg_orange.png")
        iconBg:setScale(100 / iconBg:getContentSize().width)
        iconBg:setPosition(ccp(0,0))
        node:addChild(iconBg)

        icon=CCSprite:createWithSpriteFrameName(rewardShow)
        iconBg:addChild(icon)
        icon:setPosition(getCenterPoint(iconBg))
        iconBg:setAnchorPoint(ccp(0.5,0.5))
        icon:setScale(100/icon:getContentSize().width)
    elseif whiReward ==2 then
        local nbTitle = GetTTFLabelWrap(getlocal(rewardShow),40,CCSizeMake(self.upBg:getContentSize().width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        nbTitle:setPosition(ccp(0,0))
        nbTitle:setColor(G_ColorYellowPro)
        node:addChild(nbTitle)    
    end
    local function callback( ... )
        local label = nil 
        if whiReward == 1 then 
            label = GetTTFLabel(getlocal("activity_sweettrouble_snatchRec",{getlocal(rewardStr)}),25)
        elseif whiReward ==2 then
            label = GetTTFLabel(getlocal("activity_sweettrouble_nbTitleRec",{getlocal(rewardShow)}),25)
        end
        node:addChild(label)
        label:setPosition(ccp(0,-70))
        local function touch( ... )
                self.bgimage:removeFromParentAndCleanup(true)
                self.bgimage=nil
        end
        local btn = GetButtonItem("BigBtnBlue.png","BigBtnBlue_Down.png","BigBtnBlue_Down.png",touch,2,getlocal("confirm"),25)
        local menu = CCMenu:create()
        menu:addChild(btn)
        menu:setPosition(ccp(0,-150))
        node:addChild(menu)
    end
    local arr = CCArray:create()
    arr:addObject(CCScaleTo:create(0.3, 1.3))
    arr:addObject(CCScaleTo:create(0.3, 1.1))
    arr:addObject(CCCallFunc:create(callback))
    local action2 = CCSequence:create(arr)
    node:runAction(action2)
end


function acSweetTroubleTab1:dispose( )
    self.upBg=nil
    self.middleBg=nil
    self.downBg=nil
    self.touchDialogBg=nil
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
    self.isToday =nil
    self.bgimage=nil
    self.dialog =nil
    self.firstRecharLabel=nil
end