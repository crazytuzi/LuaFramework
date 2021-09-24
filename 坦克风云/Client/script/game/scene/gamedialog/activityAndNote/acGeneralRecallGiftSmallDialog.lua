acGeneralRecallGiftSmallDialog=smallDialog:new()

function acGeneralRecallGiftSmallDialog:new()
    local nc={
            bgLayer,
        }
    setmetatable(nc,self)
    self.__index=self
    self.getAllRewardBtn=nil
    self.layerNum=0
    self.rewardNumLb=nil
    self.scoreLb=nil
    self.giftCount=0
    self.giftList=nil
    self.callBack=nil
    -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/superWeapon/superWeaponTmp.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage2.plist")
    return nc
end

function acGeneralRecallGiftSmallDialog:init(layerNum,callBack)
    self.giftList=acGeneralRecallVoApi:getGiftList()
    self.giftCount=SizeOfTable(self.giftList)
    self.callBack=callBack

    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/bubbleImage.plist")
    self.layerNum=layerNum
    local function touch( ... )
        
    end
    local capInSet=CCRect(130, 50, 1, 1)
    local dialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",capInSet,touch)
    dialogBg:setContentSize(CCSizeMake(560,800))
    self.bgLayer=dialogBg
    self.bgLayer:setPosition(getCenterPoint(sceneGame))
    dialogBg:setTouchPriority(-(self.layerNum-1)*20-3)
    local capInSet1=CCRect(10, 10, 1, 1)
    self.touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",capInSet1,touch);
    self.touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-3)
    local rect1=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    self.touchDialogBg:setContentSize(rect1)
    self.touchDialogBg:setOpacity(250)
    self.touchDialogBg:setPosition(getCenterPoint(sceneGame))
    sceneGame:addChild(self.touchDialogBg,3);

    local spriteTitle=CCSprite:createWithSpriteFrameName("ShapeTank.png");
    spriteTitle:setAnchorPoint(ccp(0.5,0.5));
    spriteTitle:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height)
    dialogBg:addChild(spriteTitle,2)

    local spriteTitle1=CCSprite:createWithSpriteFrameName("ShapeGift.png");
    spriteTitle1:setAnchorPoint(ccp(0.5,0.5));
    spriteTitle1:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height)
    dialogBg:addChild(spriteTitle1,2)

    local spriteShapeInfor=CCSprite:createWithSpriteFrameName("ShapeInfor.png");
    spriteShapeInfor:setAnchorPoint(ccp(0.5,0.5));
    spriteShapeInfor:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height-80)
    dialogBg:addChild(spriteShapeInfor,1)

    -- 标题文本
    local score=acGeneralRecallVoApi:getCurScore()
    local titleStr=getlocal("curScoreNums",{score})
    local scoreLb=GetTTFLabel(titleStr,30)
    scoreLb:setPosition(ccp(dialogBg:getContentSize().width/2,spriteTitle:getPositionY()-spriteTitle:getContentSize().height/2-5))
    scoreLb:setAnchorPoint(ccp(0.5,1));
    dialogBg:addChild(scoreLb,2)
    scoreLb:setColor(G_ColorYellowPro)
    self.scoreLb=scoreLb

    local lineSp2=CCSprite:createWithSpriteFrameName("LineCross.png");
    lineSp2:setAnchorPoint(ccp(0.5,1));
    lineSp2:setPosition(ccp(dialogBg:getContentSize().width/2,scoreLb:getPositionY()-scoreLb:getContentSize().height))
    dialogBg:addChild(lineSp2,2)
    lineSp2:setScaleX((dialogBg:getContentSize().width-160)/lineSp2:getContentSize().width)

    local subLbSize=16
    if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ko" or G_getCurChoseLanguage()=="ja" then
        subLbSize=26
    end

    local subTitleSp=CCSprite:createWithSpriteFrameName("hotSaleStrip.png")
    subTitleSp:setFlipX(true)
    subTitleSp:setAnchorPoint(ccp(0,1))
    subTitleSp:setPosition(ccp(0,scoreLb:getPositionY()-scoreLb:getContentSize().height-15))
    dialogBg:addChild(subTitleSp,2)

    local bindPlayer=acGeneralRecallVoApi:getOldPlayerBD()
    if bindPlayer then
        local playerName=bindPlayer[4]
        local subTitleLb=GetTTFLabel(getlocal("activity_chrisEve_fromPlayerGift",{playerName}),subLbSize)
        subTitleLb:setAnchorPoint(ccp(0,0.5))
        subTitleLb:setPosition(10,subTitleSp:getContentSize().height/2)
        subTitleSp:addChild(subTitleLb,2)
    end
    -- 全部领取
    local function allRewardHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local function rewardCallBack()
            local rewardStr=getlocal("rewardCenterGetAllSuccess")
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),rewardStr,30)
            self:close()
        end
        if self.giftCount>0 then
            local rewardlist,cost=acGeneralRecallVoApi:getAllGiftRewardAndCost()
            local score=acGeneralRecallVoApi:getCurScore()
            if score<cost then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("score_lack_prompt"),30)
                do return end
            end
            acGeneralRecallVoApi:socketGeneralRecall("active.djrecall.gift2",nil,rewardCallBack,rewardlist)
        end
    end
    self.getAllRewardBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",allRewardHandler,11,getlocal("alien_tech_acceptAll"),25)
    self.getAllRewardBtn:setAnchorPoint(ccp(0.5,0.5))
    local getAllRewardMenu=CCMenu:createWithItem(self.getAllRewardBtn)
    getAllRewardMenu:setPosition(ccp(dialogBg:getContentSize().width/4*3,self.getAllRewardBtn:getContentSize().height/2+21))
    getAllRewardMenu:setTouchPriority(-(99-1)*20-1)
    dialogBg:addChild(getAllRewardMenu,2)
    if self.giftCount<=0 then
        self.getAllRewardBtn:setEnabled(false)
    else
        self.getAllRewardBtn:setEnabled(true)
    end
    local function closeHandler( ... )
        self:close()
    end
    local closeBtn=GetButtonItem("BtnGraySmall.png","BtnGraySmall_Down.png","BtnGraySmall_Down.png",closeHandler,2,getlocal("fight_close"),25)
    closeBtn:setAnchorPoint(ccp(0.5,0.5))
    local closeBtnMenu=CCMenu:createWithItem(closeBtn)
    closeBtnMenu:setPosition(ccp(dialogBg:getContentSize().width/4,closeBtn:getContentSize().height/2+21))
    closeBtnMenu:setTouchPriority(-(99-1)*20-1)
    dialogBg:addChild(closeBtnMenu,2)
    -- 奖励列表
    local tvHight=subTitleSp:getPositionY()-subTitleSp:getContentSize().height-100
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(dialogBg:getContentSize().width-20,tvHight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    self.tv:setAnchorPoint(ccp(0,1))
    self.tv:setPosition(ccp(10,100))
    dialogBg:addChild(self.tv,3)

    local function touch3( ... )
    end
    local topSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",capInSet1,touch3);
    topSp:setAnchorPoint(ccp(0,1))
    topSp:setContentSize(CCSizeMake(dialogBg:getContentSize().width,dialogBg:getContentSize().height-subTitleSp:getPositionY()+subTitleSp:getContentSize().height))
    dialogBg:addChild(topSp)
    topSp:setPosition(ccp(0,dialogBg:getContentSize().height))
    topSp:setTouchPriority(-(self.layerNum-1)*20-9)
    topSp:setVisible(false)

    local bottomSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",capInSet1,touch3);
    bottomSp:setAnchorPoint(ccp(0,0))
    bottomSp:setContentSize(CCSizeMake(dialogBg:getContentSize().width,self.getAllRewardBtn:getContentSize().height+20))
    dialogBg:addChild(bottomSp)
    bottomSp:setPosition(ccp(0,0))
    bottomSp:setTouchPriority(-(self.layerNum-1)*20-9)
    bottomSp:setVisible(false)

    sceneGame:addChild(self.bgLayer,layerNum)
    
    return self.bgLayer
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acGeneralRecallGiftSmallDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return self.giftCount
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-20,200)
        return tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local gid=idx+1
        local gift=self.giftList[gid]
        local sid=gift[1]
        local num=gift[2]
        local ts=gift[3]
        local subLbSize2=16
        if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ko" or G_getCurChoseLanguage()=="ja" then
            subLbSize2=23
        end
        local function cellClick( ... )
        end
        local rewardlist,cost=acGeneralRecallVoApi:getGiftRewardAndCost(gid,sid)
        local descStr=getlocal("receiveGiftCostStr",{cost})
        local descLb=GetTTFLabelWrap(descStr,22,CCSizeMake(self.bgLayer:getContentSize().width-36, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        local sprieBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),cellClick)
        sprieBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,200))
        sprieBg:setAnchorPoint(ccp(0,0))
        sprieBg:setPosition(ccp(0,10))
        sprieBg:setTouchPriority(-(self.layerNum-1)*20-2)
        cell:addChild(sprieBg)
        local bgSize=sprieBg:getContentSize()

        local sendTimeLb=GetTTFLabel(G_getDataTimeStr(ts),26)
        sendTimeLb:setPosition(bgSize.width-10,bgSize.height-10)
        sendTimeLb:setAnchorPoint(ccp(1,1))
        cell:addChild(sendTimeLb,3)

        descLb:setPosition(10,bgSize.height-10)
        descLb:setAnchorPoint(ccp(0,1))
        cell:addChild(descLb,3)
        local rewardVd=self:initRewarListDialog(rewardlist,idx);
        rewardVd:setAnchorPoint(ccp(0,0))
        rewardVd:setPosition(ccp(0,20))
        cell:addChild(rewardVd,4)
        
        --领取奖励处理
        local function rewardHandler(tag,object)
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            local function getRewadCallback()
                self:refresh()
                if self.giftCount==0 then
                    self:close()
                end
            end
            local score=acGeneralRecallVoApi:getCurScore()
            if score<cost then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("score_lack_prompt"),30)
                do return end
            end
            local params={gid=gid,sid=sid,num=num}
            acGeneralRecallVoApi:socketGeneralRecall("active.djrecall.gift1",params,getRewadCallback,rewardlist)
        end
        local getBtn=GetButtonItem("TaskBtnGet.png","TaskBtnGet_Down.png","TaskBtnGet_Down.png",rewardHandler,11,nil,0)
        getBtn:setAnchorPoint(ccp(1,0))
        local getMenu=CCMenu:createWithItem(getBtn)
        getMenu:setPosition(ccp(sprieBg:getContentSize().width-5,45))
        getMenu:setTouchPriority(-(self.layerNum-1)*20-7)
        cell:addChild(getMenu,5)
        getMenu:setTag(idx+1)
        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
       
    end
end

function acGeneralRecallGiftSmallDialog:initRewarListDialog(rewardlist,index)
    local function touch()     
    end
    local rewardBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),touch)
    rewardBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-150,130))
    rewardBg:setPosition(ccp(0,0))
    rewardBg:setAnchorPoint(ccp(0,0))
    local count=SizeOfTable(rewardlist)
    local function callBack2(handler,fn,idx,cell)
        return self:eventHandler2(handler,fn,idx,cell,rewardlist,count,index)
    end
    local hd2=LuaEventHandler:createHandler(callBack2)
    local tv=LuaCCTableView:createHorizontalWithEventHandler(hd2,CCSizeMake(self.bgLayer:getContentSize().width-165,125),nil)
    tv:setTableViewTouchPriority(-(self.layerNum-1)*20-6)
    tv:setAnchorPoint(ccp(0,1))
    tv:setPosition(ccp(8,-5))
    rewardBg:addChild(tv,self.layerNum)

    return rewardBg
end

function acGeneralRecallGiftSmallDialog:eventHandler2(handler,fn,idx,cel,rewardlist,count,index)
    if fn=="numberOfCellsInTableView" then
        return count
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(110,120)
        return tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local rewardItem=rewardlist[idx+1]
        if rewardItem then 
            local function showTip()
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==true then
                    return
                end
                if rewardItem then
                    propInfoDialog:create(sceneGame,rewardItem,self.layerNum+1)
                end
            end
            local iconSize=90
            local iconSp=G_getItemIcon(rewardItem,nil,true,self.layerNum,showTip)
            iconSp:setAnchorPoint(ccp(0,0))
            iconSp:setPosition(ccp(10,30))
            iconSp:setTouchPriority(-(self.layerNum-1)*20-4)
            cell:addChild(iconSp)
            iconSp:setScale(iconSize/iconSp:getContentSize().width)
            local numLb=GetTTFLabel("x"..FormatNumber(rewardItem.num),20)
            numLb:setPosition(iconSize/2+7,8)
            numLb:setAnchorPoint(ccp(0.5,0));
            cell:addChild(numLb,3)
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

--刷新板子
function acGeneralRecallGiftSmallDialog:refresh()
    self.giftList=acGeneralRecallVoApi:getGiftList()
    self.giftCount=SizeOfTable(self.giftList)
    local score=acGeneralRecallVoApi:getCurScore()
    if self.rewardNumLb and acGeneralRecallVoApi then
        self.rewardNumLb:setString(tostring(self.giftCount))
    end
    if self.scoreLb and acGeneralRecallVoApi then
        self.scoreLb:setString(getlocal("curScoreNums",{score}))
    end
    if self.tv then
        self.tv:reloadData()
    end
    if self.getAllRewardBtn then
        if self.giftCount<=0 then
            self.getAllRewardBtn:setEnabled(false)
        else
            self.getAllRewardBtn:setEnabled(true)
        end
    end
end

function acGeneralRecallGiftSmallDialog:dispose()
    if self.callBack then
        self.callBack()
    end
    self.getAllRewardBtn=nil
    self.layerNum=0
    self.rewardNumLb=nil
    self.scoreLb=nil
    self.giftCount=0
    self.giftList=nil
    self.callBack=nil
    if self and self.touchDialogBg then
        self.touchDialogBg:removeFromParentAndCleanup(true)
        self.touchDialogBg=nil
    end
    if self and self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil
    end
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/bubbleImage.plist")
end
