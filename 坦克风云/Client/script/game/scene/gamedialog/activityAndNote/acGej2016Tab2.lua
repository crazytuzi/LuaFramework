acGej2016Tab2={
}

function acGej2016Tab2:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.tv=nil
    self.bgLayer=nil
    self.layerNum=layerNum

    return nc
end

function acGej2016Tab2:init()
    self.bgLayer=CCLayer:create()

    self:initUI()
    self:initTableView()
    return self.bgLayer
end


function acGej2016Tab2:initUI()

    local lbH=self.bgLayer:getContentSize().height-175
    local function nilfunc()
    end
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),nilfunc)
    backSprie:setAnchorPoint(ccp(0.5,1))
    backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-50, 180))
    backSprie:setPosition(ccp(G_VisibleSizeWidth/2, lbH));
    self.bgLayer:addChild(backSprie)

    local bsSize=backSprie:getContentSize()

    local nbReward={p={{p3337=1}}}
    local nbItem=FormatItem(nbReward)
    self.nbItem=nbItem
    local icon,scale=G_getItemIcon(nbItem[1],100,true,self.layerNum,nil,nil,nil,nil,true)
    scale=1.2
    icon:setScale(scale)
    icon:setTouchPriority(-(self.layerNum-1)*20-4)
    icon:setAnchorPoint(ccp(0,0.5))
    icon:setPosition(20,bsSize.height/2)
    backSprie:addChild(icon,2)

    local desStr=getlocal("activity_gej2016_heart_des")
    local desLb=GetTTFLabelWrap(desStr,25,CCSize(bsSize.width-160-10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    desLb:setAnchorPoint(ccp(0,0.5))
    desLb:setPosition(160,bsSize.height/2)
    backSprie:addChild(desLb)

    -- 彩带
    for i=1,2 do
        local caidaiSp=CCSprite:createWithSpriteFrameName("acGej2016_caidai" .. i .. ".png")
        self.bgLayer:addChild(caidaiSp,3)
        caidaiSp:setAnchorPoint(ccp(0.5,1))
        if i==1 then
            caidaiSp:setPosition(45,lbH-180)
        else
            caidaiSp:setPosition(G_VisibleSizeWidth-65,lbH-170)
        end

    end

    self.tvH=lbH-bsSize.height-10-30
end

function acGej2016Tab2:initTableView()

    self.cellHeight=155
    self.shopTb=acGej2016VoApi:getShop()
    self.shopIndexTb=acGej2016VoApi:getShopIndexTb()
    self.cellNum=SizeOfTable(self.shopTb)

    local function callBack(...)
         return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-50,self.tvH),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(25,30))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
end

function acGej2016Tab2:eventHandler(handler,fn,idx,cel)
    local strSize2 = 18
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
        strSize2 =25
    end
    if fn=="numberOfCellsInTableView" then
        return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(G_VisibleSizeWidth-50,self.cellHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local rect = CCRect(0, 0, 50, 50)
        local capInSet = CCRect(20, 20, 10, 10)
        local function cellClick(hd,fn,idx)
        end
        local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("NoticeLine.png",capInSet,cellClick)
        backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,self.cellHeight))
        backSprie:ignoreAnchorPointForPosition(false)
        backSprie:setAnchorPoint(ccp(0,0))
        backSprie:setIsSallow(false)
        backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
        backSprie:setPosition(ccp(0,0))
        cell:addChild(backSprie,1)

        local bsSize=backSprie:getContentSize()
        local bgSp=CCSprite:createWithSpriteFrameName("threeyear_bg.png")
        bgSp:setPosition(backSprie:getContentSize().width/2+5,backSprie:getContentSize().height/2)
        cell:addChild(bgSp)
        bgSp:setScaleX((backSprie:getContentSize().width-5)/bgSp:getContentSize().width)
        bgSp:setScaleY((backSprie:getContentSize().height-10)/bgSp:getContentSize().height)
        bgSp:setOpacity(120)

        local iconWidth=100
        local startW=20
        local iconSp1,scale=G_getItemIcon(self.nbItem[1],iconWidth,true,self.layerNum+1,nil,self.tv,nil,nil,true)
        iconSp1:setTouchPriority(-(self.layerNum-1)*20-2)
        iconSp1:setAnchorPoint(ccp(0,0.5))
        iconSp1:setPosition(startW,bsSize.height/2+10)
        backSprie:addChild(iconSp1,2)

        local taskId=self.shopIndexTb[idx+1].taskId
        local haveNum=acGej2016VoApi:getV()
        local needLove=self.shopTb[taskId].needLove
        local haveLb=GetTTFLabel(haveNum,25)
        haveLb:setAnchorPoint(ccp(0,0.5))
        local needLb=GetTTFLabel("/".. needLove,25)
        needLb:setAnchorPoint(ccp(0,0.5))
        needLb:setPosition(haveLb:getContentSize().width,haveLb:getContentSize().height/2)
        haveLb:addChild(needLb)
        local totalWidth=haveLb:getContentSize().width+needLb:getContentSize().width
        backSprie:addChild(haveLb)
        haveLb:setPosition(startW+iconWidth/2-totalWidth/2,bsSize.height/2-iconWidth/2-7)
        if haveNum<needLove then
            haveLb:setColor(G_ColorRed)
        end

        -- local numLb=GetTTFLabel(getlocal("bindText"),25)
        -- backSprie:addChild(numLb)
        -- numLb:setPosition(startW+iconWidth/2,bsSize.height/2-iconWidth/2-10)

        local arrowSp=CCSprite:createWithSpriteFrameName("acGej2016_arrow.png")
        backSprie:addChild(arrowSp)
        arrowSp:setPosition(startW+iconWidth+30,bsSize.height/2+10)

        local reward=self.shopTb[taskId].reward
        local rewardItem=FormatItem(reward)
        local iconSp2,scale=G_getItemIcon(rewardItem[1],iconWidth,true,self.layerNum+1,nil,self.tv,nil,nil,nil)
        iconSp2:setTouchPriority(-(self.layerNum-1)*20-2)
        iconSp2:setAnchorPoint(ccp(0,0.5))
        iconSp2:setPosition(startW+iconWidth+60,bsSize.height/2+10)
        backSprie:addChild(iconSp2,2)

        if self.shopTb[taskId].isFlick and self.shopTb[taskId].isFlick==1 then
            G_addRectFlicker(iconSp2,1.3,1.3)
        end
        

        local numBg =CCSprite:createWithSpriteFrameName("allianceHeaderBg.png")
        numBg:setAnchorPoint(ccp(0.5,0.5))
        numBg:setPosition(ccp(iconSp2:getContentSize().width/2,14))
        iconSp2:addChild(numBg)
        numBg:setScaleY(1/scale*0.5)
        numBg:setScaleX(1/scale*0.5)

        local numLb2=GetTTFLabel(rewardItem[1].num,22)
        iconSp2:addChild(numLb2)
        numLb2:setPosition(iconSp2:getContentSize().width/2,14)
        numLb2:setScale(1/scale)
        -- numBg:setOpacity(180)

        local bLogTb=acGej2016VoApi:getB()

        local function rewardTiantang()
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                -- 兑换逻辑
                if haveNum<needLove then

                    do return end
                end

                local function refreshFunc(rewardlist)
                    self.shopIndexTb=acGej2016VoApi:getShopIndexTb()
                    local recordPoint=self.tv:getRecordPoint()
                    self.tv:reloadData()
                    self.tv:recoverToRecordPoint(recordPoint)

                    -- 此处加弹板
                    if rewardlist then
                        acGej2016VoApi:showRewardDialog(rewardlist,self.layerNum)
                    end
                end
                local action="buy"
                local tid=taskId
                acGej2016VoApi:socketGej2016(action,refreshFunc,tid)

            end
        end
        -- "BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png"
        local changeItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",rewardTiantang,nil,getlocal("code_gift"),strSize2)
        -- rewardItem:setScale(0.8)
        local changeBtn=CCMenu:createWithItem(changeItem);
        changeBtn:setTouchPriority(-(self.layerNum-1)*20-2);
        changeBtn:setPosition(ccp(bsSize.width-120,50))
        backSprie:addChild(changeBtn)

        local desStr
        local limitNum=self.shopTb[taskId].limit
        if limitNum then
            local nowNum=bLogTb[taskId] or 0
            if nowNum>=limitNum then
                changeItem:setEnabled(false)
            end

            desStr=getlocal("activity_gej2016_limit_des",{nowNum .. "/" .. limitNum})

        else
            desStr=getlocal("activity_gej2016_no_limit")

        end
        if haveNum<needLove then
            changeItem:setEnabled(false)
        end
        local desLb=GetTTFLabelWrap(desStr,strSize2,CCSize(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
        desLb:setAnchorPoint(ccp(0.5,0))
        desLb:setPosition(bsSize.width-120,90)
        backSprie:addChild(desLb)

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

function acGej2016Tab2:refresh()
    if self.tv then
        self.shopIndexTb=acGej2016VoApi:getShopIndexTb()
        local recordPoint=self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
end


function acGej2016Tab2:tick()
end

function acGej2016Tab2:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.tv=nil
    self.layerNum=nil
end
