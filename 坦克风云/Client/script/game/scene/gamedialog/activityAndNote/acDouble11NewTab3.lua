acDouble11NewTab3 ={} 
function acDouble11NewTab3:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.bgLayer=nil
    self.layerNum=nil
    self.upPosTb={}
    self.downPosTb={}
    self.numChoose=nil
    self.valueChoose=nil
    self.needMoney =nil
    self.downCellNum=0
    self.cellWidth =nil
    self.cellHeight=nil
    return nc;

end
function acDouble11NewTab3:init(layerNum)
    self.bgLayer=CCLayer:create()
    self.layerNum =layerNum
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local bigBg =CCSprite:create("public/superWeapon/weaponBg.jpg")
    self.upBgJpg =CCSprite:create("public/superWeapon/weaponBg.jpg")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    bigBg:setScaleX((G_VisibleSizeWidth-42)/bigBg:getContentSize().width)
    bigBg:setScaleY((G_VisibleSizeHeight-186)/bigBg:getContentSize().height)
    bigBg:ignoreAnchorPointForPosition(false)
    bigBg:setOpacity(150)
    bigBg:setAnchorPoint(ccp(0.5,0.5))
    bigBg:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*0.5-68))
    self.bgLayer:addChild(bigBg)

    self:initUpBg()
    self:initDownBg()

    return self.bgLayer
end

function acDouble11NewTab3:initUpBg( )
    local strSize2 = 24
    local strSize3 = 20
    local addWidth = 5
    local strSize4 = 20
    if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
        strSize2 =30
        strSize3 =25
        addWidth =35
        strSize4 =25
    elseif G_getCurChoseLanguage() =="de" then
        strSize4 =12
    elseif G_getCurChoseLanguage() =="ru" then
        strSize3 =14
    end
    local function noData( ) end
    local bgNeedWidth = G_VisibleSizeWidth-40
    local bgNeedHeight = G_VisibleSizeHeight*0.38
    local upBgSp =LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50,50,1,1),noData) 
    upBgSp:setContentSize(CCSizeMake(bgNeedWidth,bgNeedHeight))
    upBgSp:setAnchorPoint(ccp(0.5,1))
    upBgSp:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight-160))
    self.bgLayer:addChild(upBgSp,1)

    self.upBgJpg:setScaleX((bgNeedWidth-10)/self.upBgJpg:getContentSize().width)
    self.upBgJpg:setScaleY((bgNeedHeight-10)/self.upBgJpg:getContentSize().height)
    self.upBgJpg:ignoreAnchorPointForPosition(false)
    self.upBgJpg:setAnchorPoint(ccp(0.5,0))
    self.upBgJpg:setPosition(ccp(upBgSp:getContentSize().width*0.5,5))
    upBgSp:addChild(self.upBgJpg)

    local upSideBar=CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
    upSideBar:setAnchorPoint(ccp(0.5,1))
    upSideBar:setPosition(ccp(bgNeedWidth*0.5,upBgSp:getContentSize().height-5))
    upBgSp:addChild(upSideBar,1)

    local titleBg = CCSprite:createWithSpriteFrameName("groupSelf.png")
    titleBg:setScaleX(bgNeedWidth/titleBg:getContentSize().width)
    titleBg:setScaleY(bgNeedHeight*0.15/titleBg:getContentSize().height)
    titleBg:setAnchorPoint(ccp(0.5,1))
    titleBg:setPosition(ccp(upBgSp:getContentSize().width*0.5+10,upSideBar:getPositionY()-upSideBar:getContentSize().height+5))
    upBgSp:addChild(titleBg)
    --activity_double11New_corpsRedBagTitle
    local titleStr = GetTTFLabel(getlocal("activity_double11New_corpsRedBagTitle"),strSize2)
    titleStr:setAnchorPoint(ccp(0.5,0.5))
    titleStr:setPosition(ccp(titleBg:getPositionX()-10,titleBg:getPositionY()-bgNeedHeight*0.075))
    upBgSp:addChild(titleStr)

    local upSideBar2=CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
    upSideBar2:setAnchorPoint(ccp(0.5,0))
    upSideBar2:setPosition(ccp(bgNeedWidth*0.5,upSideBar2:getContentSize().height+5))
    upSideBar2:setRotation(180)
    upBgSp:addChild(upSideBar2,1)

    local function touch33(...)
        self:openInfo()
    end
    local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch33,1,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,1))
    menuItemDesc:setScale(0.7)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-15)
    menuDesc:setPosition(ccp(bgNeedWidth-10,bgNeedHeight-25))
    upBgSp:addChild(menuDesc,55)


    local corpRedBagNusStr = GetTTFLabel(getlocal("activity_double11New_corpRedBagNums"),strSize3)--第一行
    corpRedBagNusStr:setAnchorPoint(ccp(0,0.5))
    corpRedBagNusStr:setPosition(ccp(addWidth,bgNeedHeight*0.7))
    upBgSp:addChild(corpRedBagNusStr)

    local corpValueStr = GetTTFLabel(getlocal("activity_double11New_corpValue"),strSize3)--第2行
    corpValueStr:setAnchorPoint(ccp(0,0.5))
    corpValueStr:setPosition(ccp(addWidth,bgNeedHeight*0.5))
    upBgSp:addChild(corpValueStr)

    local corpsPayStr = GetTTFLabel(getlocal("activity_double11New_corpsPay"),strSize3)--第3行
    corpsPayStr:setAnchorPoint(ccp(0,0.5))
    corpsPayStr:setPosition(ccp(addWidth,bgNeedHeight*0.25))
    upBgSp:addChild(corpsPayStr)

    local initWidth = corpRedBagNusStr:getPositionX()+corpRedBagNusStr:getContentSize().width+50

    local function clickCallBack(object,fn,tag)
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end
        if tag<20 then--选择个数
            local idx = tag-10
            self.numChoose:setPosition(ccp(self.upPosTb[idx].x+5,self.upPosTb[idx].y))
            acDouble11NewVoApi:setUsePickNum(idx)
        else--选择代币数量
            local idx = tag-20
            self.valueChoose:setPosition(ccp(self.downPosTb[idx].x+5,self.downPosTb[idx].y))
            acDouble11NewVoApi:setUsePickMoney(idx)
        end
         local needMoneyNum = acDouble11NewVoApi:getCurNeedMoney()
         self.needMoney:setString(tonumber(needMoneyNum))
    end
    local bgScaleWidth,bgScaleWidth2
    local bgScaleHeight,bgScaleHeight2
    local pickNumTb = acDouble11NewVoApi:getPickNumTb( )
    local pickMoneyTb = acDouble11NewVoApi:getPickMoneyTb( )
    for i=1,3 do
        local chooseNumsBg = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50,50,1,1),clickCallBack)
        chooseNumsBg:setAnchorPoint(ccp(0,0.5))
        bgScaleWidth =110/chooseNumsBg:getContentSize().width
        bgScaleHeight=55/chooseNumsBg:getContentSize().height
        chooseNumsBg:setScaleX(bgScaleWidth)
        chooseNumsBg:setScaleY(bgScaleHeight)
        chooseNumsBg:setTouchPriority(-(self.layerNum-1)*20-11)
        self.upPosTb[i] =ccp(initWidth+(chooseNumsBg:getContentSize().width+35)*(i-1),corpRedBagNusStr:getPositionY())
        chooseNumsBg:setPosition(self.upPosTb[i])
        upBgSp:addChild(chooseNumsBg)
        chooseNumsBg:setTag(10+i)

        local pickNum = GetTTFLabel(getlocal("theCount",{pickNumTb[i]}),strSize3)
        pickNum:setAnchorPoint(ccp(0.5,0.5))
        pickNum:setPosition(ccp(self.upPosTb[i].x+chooseNumsBg:getContentSize().width*bgScaleWidth*0.5,self.upPosTb[i].y))
        upBgSp:addChild(pickNum,1)
    end
    for i=1,3 do
        local chooseValueBg = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50,50,1,1),clickCallBack)
        chooseValueBg:setAnchorPoint(ccp(0,0.5))
        bgScaleWidth2 =110/chooseValueBg:getContentSize().width
        bgScaleHeight2=55/chooseValueBg:getContentSize().height
        chooseValueBg:setScaleX(bgScaleWidth2)
        chooseValueBg:setScaleY(bgScaleHeight2)
        chooseValueBg:setTouchPriority(-(self.layerNum-1)*20-11)
        self.downPosTb[i]=ccp(initWidth+(chooseValueBg:getContentSize().width+35)*(i-1),corpValueStr:getPositionY())
        chooseValueBg:setPosition(self.downPosTb[i])
        upBgSp:addChild(chooseValueBg)
        chooseValueBg:setTag(20+i)

        local pickMoney = GetTTFLabel(getlocal("activity_double11New_redBagGotNums",{pickMoneyTb[i]}),strSize4)
        pickMoney:setAnchorPoint(ccp(0.5,0.5))
        pickMoney:setPosition(ccp(self.downPosTb[i].x+chooseValueBg:getContentSize().width*bgScaleWidth2*0.5,self.downPosTb[i].y))
        upBgSp:addChild(pickMoney,1)
    end

    self.numChoose = LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",CCRect(20, 20, 1, 11),noData)
    self.numChoose:setAnchorPoint(ccp(0,0.5))
    self.numChoose:setContentSize(CCSizeMake(100,52))
    self.numChoose:setOpacity(250)
    self.numChoose:setPosition(ccp(self.upPosTb[1].x+5,self.upPosTb[1].y))
    upBgSp:addChild(self.numChoose)

    self.valueChoose = LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",CCRect(20, 20, 1, 1),noData)
    self.valueChoose:setAnchorPoint(ccp(0,0.5))
    self.valueChoose:setContentSize(CCSizeMake(100,52))
    self.valueChoose:setOpacity(250)
    self.valueChoose:setPosition(ccp(self.downPosTb[1].x+5,self.downPosTb[1].y))
    upBgSp:addChild(self.valueChoose)

    --默认选择第一种类型
    acDouble11NewVoApi:setUsePickNum(1)
    acDouble11NewVoApi:setUsePickMoney(1)

    local IconGoldSp = CCSprite:createWithSpriteFrameName("IconGold.png")
    IconGoldSp:setAnchorPoint(ccp(0,0.5))
    IconGoldSp:setPosition(ccp(corpsPayStr:getPositionX()+corpsPayStr:getContentSize().width+10,corpsPayStr:getPositionY()))
    upBgSp:addChild(IconGoldSp)

    local needMoneyNum = acDouble11NewVoApi:getCurNeedMoney()
    self.needMoney = GetTTFLabel(tonumber(needMoneyNum),25)
    self.needMoney:setAnchorPoint(ccp(0,0.5))
    self.needMoney:setPosition(ccp(corpsPayStr:getPositionX()+corpsPayStr:getContentSize().width+IconGoldSp:getContentSize().width+10,corpsPayStr:getPositionY()))
    upBgSp:addChild(self.needMoney)


    local function sureHandler()
        local haveCost = playerVoApi:getGems()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end
        local needGems,redBagValue = acDouble11NewVoApi:getCurNeedMoney( )
        -- print("haveCost < needGems=====>",tonumber(haveCost) , tonumber(needGems))
        if playerVoApi:getPlayerLevel() < acDouble11NewVoApi:getLvLimit( ) then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("notEnoughLevel",{acDouble11NewVoApi:getLvLimit()}),30)
        elseif needGems ==nil then
            -- print("error~~~~~~needGems is nil!!!!!!")
            return
        elseif tonumber(haveCost) < tonumber(needGems) then
            self:needMoneyDia(needGems,haveCost)
        else
            self:isSureToSendRedBag(needGems,redBagValue)
        end
    end

    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",sureHandler,2,getlocal("activity_double11New_sendRedBag"),strSize3)
    sureItem:setScale(0.8)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(corpsPayStr:getPositionX()+corpsPayStr:getContentSize().width+200,corpsPayStr:getPositionY()))
    sureMenu:setTouchPriority(-(10-1)*20-11);
    upBgSp:addChild(sureMenu)

    

end

function acDouble11NewTab3:initDownBg( )
    local strSize2 = 24
    if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
        strSize2 =30
    end
    local function noData( ) end
    local bgNeedWidth = G_VisibleSizeWidth-40
    local bgNeedHeight = G_VisibleSizeHeight*0.38
    local downBgSp =LuaCCScale9Sprite:createWithSpriteFrameName("iconTitlebg.png",CCRect(27, 29, 2, 2),noData)
    downBgSp:setContentSize(CCSizeMake(bgNeedWidth,bgNeedHeight))
    downBgSp:setAnchorPoint(ccp(0.5,0));
    downBgSp:setOpacity(120)
    downBgSp:setPosition(G_VisibleSizeWidth*0.5,20)
    self.bgLayer:addChild(downBgSp,1)

    self.cellWidth =bgNeedWidth-10
    self.cellHeight =bgNeedHeight-10
    local function callBack(...)
         return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(bgNeedWidth-10,bgNeedHeight-10),nil)-- -200
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.tv:setPosition(ccp(25,25))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(120)--120
    
    ------中间位置的背景色和文字显示
    local middleBg = CCSprite:createWithSpriteFrameName("groupSelf.png")
    middleBg:setScaleX(bgNeedWidth/middleBg:getContentSize().width)
    middleBg:setScaleY(G_VisibleSizeHeight*0.05/middleBg:getContentSize().height)
    middleBg:setAnchorPoint(ccp(0.5,0))
    middleBg:setPosition(ccp(G_VisibleSizeWidth*0.5+10,downBgSp:getPositionY()+bgNeedHeight))
    self.bgLayer:addChild(middleBg)
    --activity_double11New_corpsRedBagTitle
    local middleStr = GetTTFLabel(getlocal("activity_grabRed_grab"),strSize2)
    middleStr:setAnchorPoint(ccp(0.5,0.5))
    middleStr:setPosition(ccp(G_VisibleSizeWidth*0.5,downBgSp:getPositionY()+bgNeedHeight+G_VisibleSizeHeight*0.023))
    self.bgLayer:addChild(middleStr)

    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),noData);
    touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-5)
    local rect=CCSizeMake(bgNeedWidth-10,bgNeedHeight+30)
    touchDialogBg:setAnchorPoint(ccp(0,0))
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(0)
    touchDialogBg:setPosition(ccp(25,bgNeedHeight-10+self.tv:getPositionY()))
    self.bgLayer:addChild(touchDialogBg,1);
end

function acDouble11NewTab3:eventHandler( handler,fn,idx,cel)
  local recRedbagTb = acDouble11NewVoApi:getReceivedCorpRedbagTb( )
  self.downCellNum = SizeOfTable(recRedbagTb)
  local strSize2 = 21
  if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
        strSize2 =25
  end
  if fn=="numberOfCellsInTableView" then
    if self.downCellNum ==0 then
        return 1
    else
        return self.downCellNum
    end
  elseif fn=="tableCellSizeForIndex" then
    local cellHeight = self.cellHeight
    if self.downCellNum >0 then
        cellHeight = self.cellHeight*0.333
    end
    return  CCSizeMake(self.cellWidth,cellHeight)-- -100
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()

    if self.downCellNum ==0 then
        local tipStr = GetTTFLabelWrap(getlocal("activity_double11New_tab3_noBodySendRedBagCur"),35,CCSizeMake(self.cellWidth-40,self.cellHeight*0.5),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        tipStr:setAnchorPoint(ccp(0.5,0.5))
        tipStr:setPosition(ccp(self.cellWidth*0.5,self.cellHeight*0.5))
        tipStr:setColor(G_ColorYellowPro)
        cell:addChild(tipStr)
    else
        local subWidth = G_getCurChoseLanguage() == "ar" and 100 or 60
        local sender = recRedbagTb[self.downCellNum-idx].sender
        local cheduzi = getlocal("activity_double11New_CorpChat",{" "})
        local curT = G_chatTime(recRedbagTb[self.downCellNum-idx].redbuyedTs,true)

        local senderStr = GetTTFLabel(sender,27)
        senderStr:setAnchorPoint(ccp(0,1))
        senderStr:setColor(G_ColorYellowPro)
        senderStr:setPosition(ccp(5,self.cellHeight*0.333*0.95))
        cell:addChild(senderStr)

        local tag = nil
        if recRedbagTb[self.downCellNum-idx].tag then
            tag = recRedbagTb[self.downCellNum-idx].tag
            acDouble11NewVoApi:showActionTip(cell,tag,ccp(40+senderStr:getContentSize().width,self.cellHeight*0.333*0.95-15))
        end

        local curTStr = GetTTFLabel(curT,27)
        curTStr:setAnchorPoint(ccp(1,1))
        curTStr:setColor(G_ColorYellowPro)
        curTStr:setPosition(ccp(self.cellWidth-10,self.cellHeight*0.333*0.95))
        cell:addChild(curTStr)

        local cheduziStr = GetTTFLabelWrap(cheduzi,strSize2,CCSizeMake(self.cellWidth-subWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        cheduziStr:setAnchorPoint(ccp(0,1))
        cheduziStr:setPosition(ccp(senderStr:getContentSize().width-30,self.cellHeight*0.333*0.6))
        cell:addChild(cheduziStr)

        local cellIdx = idx
        local capInSet = CCRect(20, 20, 10, 10)
        local backSprie =nil
        local function cellClick1(hd,fn,idx)
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            -- if self.tv:getIsScrolled()==true then
            --     do return end
            -- end
            PlayEffect(audioCfg.mouseClick)
            base:setWait()
            -- print("tag=====>",tag,self.downCellNum-cellIdx)
            if tag then
                tolua.cast(cell:getChildByTag(tag),"CCSprite"):removeFromParentAndCleanup(true)
                tolua.cast(cell:getChildByTag(tag+1000),"CCSprite"):removeFromParentAndCleanup(true)
                recRedbagTb[self.downCellNum-cellIdx].tag =nil
                acDouble11NewVoApi:setRecBagTbTagNil(tag,self.downCellNum-cellIdx)
                chatVoApi:setChatVoKillRedBagTag( nil,1,tag,3 )
                tag =nil
            end
            local function touchCallback()
                -- print("cellIdx----->>>>",cellIdx,self.downCellNum,cellIdx)
                acDouble11NewVoApi:setNewGetRecordInCorp(recRedbagTb[self.downCellNum-cellIdx])
                acDouble11NewVoApi:getRedBag()
                base:cancleWait()
            end
            local fadeIn=CCFadeIn:create(0.2)
            --local delay=CCDelayTime:create(2)
            local fadeOut=CCFadeOut:create(0.2)
            local callFunc=CCCallFuncN:create(touchCallback)
            local acArr=CCArray:create()
            acArr:addObject(fadeIn)
            --acArr:addObject(delay)
            acArr:addObject(fadeOut)
            acArr:addObject(callFunc)
            local seq=CCSequence:create(acArr)
            if backSprie then
                backSprie:runAction(seq)
            end
        end
        backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfItemBg.png",capInSet,cellClick1)
        backSprie:ignoreAnchorPointForPosition(false);
        backSprie:setAnchorPoint(ccp(0,0))
        -- backSprie:setTag(chatVo.index)
        backSprie:setIsSallow(false)
        backSprie:setTouchPriority(-(self.layerNum-1)*20-4)
        backSprie:setPosition(ccp(2,0))
        cell:addChild(backSprie,1)
        backSprie:setContentSize(CCSizeMake(self.cellWidth,self.cellHeight*0.333))
        backSprie:setOpacity(0)
    end
    return cell
  elseif fn=="ccTouchBegan" then
    self.isMoved=false
    return true
  elseif fn=="ccTouchMoved" then
    self.isMoved=true
  elseif fn=="ccTouchEnded"  then
  end
end

function acDouble11NewTab3:tick( )
    
    if acDouble11NewVoApi:getIsNewCorpTbReceived( ) ==1 then
        acDouble11NewVoApi:setIsNewCorpTbReceived(0)
        if self.tv then
            local recordPoint = self.tv:getRecordPoint()
            local curCellNum = self.downCellNum
            -- print("curCellNum~~--->>>",curCellNum)
            -- print("self.tv:reloadData()~~~~~~~")
            self.tv:reloadData()
            if curCellNum > 0 then
                if self.downCellNum >1 and self.downCellNum < 15 then
                    recordPoint.y = recordPoint.y -self.cellHeight*0.333
                end
                self.tv:recoverToRecordPoint(recordPoint)
            end
        end
    end

end

function acDouble11NewTab3:needMoneyDia(cost,playerGems)
    -- print("in needMoneyDia~~~~~~~")
    local smallD
    local function closeAllDialog( )
        if smallD then
            smallD:close()
        end
    end 
    -- self.eventH = closeAllDialog
    if eventDispatcher:hasEventHandler("closeNewDouble11Dialog.becauseAllianceGetOut",closeAllDialog)==false then
        eventDispatcher:addEventListener("closeNewDouble11Dialog.becauseAllianceGetOut",closeAllDialog)
    end
    local function buyGems()
      if G_checkClickEnable()==false then
          do
              return
          end
      end
      eventDispatcher:removeEventListener("closeNewDouble11Dialog.becauseAllianceGetOut",closeAllDialog)
      activityAndNoteDialog:closeAllDialog()
      vipVoApi:showRechargeDialog(self.layerNum+1)
    end
    local function cancleCallBack( )

    end 
    local num=tonumber(cost)-tonumber(playerGems)
    smallD=smallDialog:new()
    smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyGems,getlocal("dialog_title_prompt"),getlocal("gemNotEnough",{tonumber(cost),playerGems,num}),nil,self.layerNum+1,nil,nil,cancleCallBack)
end

function acDouble11NewTab3:isSureToSendRedBag( cost,redBagValue)
    --activity_double11New_isSrueToSendRedBag
    local smallD
    local function closeAllDialog( )
        if smallD then
            smallD:close()
        end
    end 
    -- self.eventH = closeAllDialog
    if eventDispatcher:hasEventHandler("closeNewDouble11Dialog.becauseAllianceGetOut",closeAllDialog)==false then
        eventDispatcher:addEventListener("closeNewDouble11Dialog.becauseAllianceGetOut",closeAllDialog)
    end
    local function sureToSend()

        if G_checkClickEnable()==false then
            do
                  return
            end
        end
        eventDispatcher:removeEventListener("closeNewDouble11Dialog.becauseAllianceGetOut",closeAllDialog)
        local usePicNum = acDouble11NewVoApi:getUsePickNum( )
        local usepicMoney = acDouble11NewVoApi:getUsePickMoney( )

        local function getCallBack(fn,data )
            local ret,sData = base:checkServerData(data)
            if ret ==true and sData.data then
                local gems = playerVoApi:getGems()
                playerVoApi:setGems(gems-cost)

                if sData and sData.data  then
                    if sData.data.redid then--记录自己的可发送的红包ID的记录，弹出窗口提示玩家是否世界广播发送
                        acDouble11NewVoApi:chatCorpRedBag(sData.data.redid,sData.data.redtype,usePicNum,usepicMoney,sData.ts)
                    end
                end
            end
        end 
        socketHelper:double11NewPanicBuying( getCallBack,"sendbag",nil,nil,nil,nil,2,usePicNum,usepicMoney)
    end
    local function cancleCallBack( ) end 
    smallD=smallDialog:new()
    smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),sureToSend,getlocal("dialog_title_prompt"),getlocal("activity_double11New_isSrueToSendRedBag",{tonumber(cost),tonumber(redBagValue)}),nil,self.layerNum+1,nil,nil,cancleCallBack)

end

function acDouble11NewTab3:openInfo()
  local td=smallDialog:new()

  local tabStr ={"\n",getlocal("activity_double11New_tab3_tip5"),"\n",getlocal("activity_double11New_tab3_tip4"),"\n",getlocal("activity_double11New_tab3_tip3",{acDouble11NewVoApi:getLvLimit()}),"\n",getlocal("activity_double11New_tab3_tip2"),"\n",getlocal("activity_double11New_tab3_tip1"),"\n"}
  local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,nil)
  sceneGame:addChild(dialog,self.layerNum+1)
end
function acDouble11NewTab3:dispose( )
    self.downCellNum=nil
    self.bgLayer =nil
    self.layerNum =nil
    self.upPosTb=nil
    self.downPosTb=nil
    self.numChoose=nil
    self.valueChoose=nil
    self.needMoney =nil
    self.cellWidth =nil
    self.cellHeight=nil
end