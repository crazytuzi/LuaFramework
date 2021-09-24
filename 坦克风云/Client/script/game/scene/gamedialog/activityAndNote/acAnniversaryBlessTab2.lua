acAnniversaryBlessTab2={

}

function acAnniversaryBlessTab2:new()
    local nc={}
    nc.layerNum=nil
    nc.dialogLayer=nil
    nc.bgLayer=nil
    nc.closeBtn=nil
    nc.tv=nil
    nc.normalHeight=200
    nc.buyBtn=nil
    nc.receiveBtn=nil

    setmetatable(nc,self)
    self.__index=self
    return nc
end

function acAnniversaryBlessTab2:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    self.acIsStoped=acAnniversaryBlessVoApi:acIsStop()
    self.isToday=acAnniversaryBlessVoApi:isToday()

    if G_isIphone5() then
        self.normalHeight=250
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)

    self:initTableView()

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	return self.bgLayer
end

--设置对话框里的tableView
function acAnniversaryBlessTab2:initTableView()
    local bgWidth = self.bgLayer:getContentSize().width
    local bgHeight = self.bgLayer:getContentSize().height
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(bgWidth-60,bgHeight-550),nil)

    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,30))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)

    local bgSp = CCSprite:create("public/acImminentImage/imminentBg.jpg")
    bgSp:setAnchorPoint(ccp(0.5,1))
    bgSp:setScale(0.97)
    bgSp:setPosition(ccp(bgWidth/2,bgHeight-160))
    self.bgLayer:addChild(bgSp)

    local function nilFunc()
    end
    local timeSP = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),nilFunc)
    timeSP:setAnchorPoint(ccp(0.5,1))
    timeSP:setPosition(ccp(bgWidth/2,bgHeight-160))
    self.bgLayer:addChild(timeSP)

    local actTime=GetTTFLabel(getlocal("activity_timeLabel"),30)
    actTime:setPosition(ccp(bgWidth/2,bgHeight-180))
    self.bgLayer:addChild(actTime,5);
    actTime:setColor(G_ColorGreen)
    local timeLabel=GetTTFLabel(acAnniversaryBlessVoApi:getTimeStr(),26)
    timeLabel:setPosition(ccp(bgWidth/2, bgHeight-220))
    self.bgLayer:addChild(timeLabel)
    timeSP:setContentSize(CCSizeMake(bgWidth-180,actTime:getContentSize().height+timeLabel:getContentSize().height+20))

    local function touchHander( ... )
    end
    local desBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touchHander)
    desBg:setContentSize(CCSize(460,200))
    desBg:setAnchorPoint(ccp(0,0))
    desBg:setPosition(ccp(bgWidth-490,bgHeight-520))
    self.bgLayer:addChild(desBg)

    local characterSp
    if platCfg.platCfgChangeGuideUI[G_curPlatName()] then
        characterSp = CCSprite:create("public/guide.png")
    else
        characterSp = CCSprite:createWithSpriteFrameName("GuideCharacter.png") --姑娘
    end
    characterSp:setAnchorPoint(ccp(0.5,0))
    characterSp:setPosition(ccp(0,0))
    desBg:addChild(characterSp,5)
    
    local descLabel=GetTTFLabelWrap(getlocal("activity_anniversaryBless_prompt8"),26,CCSizeMake(320,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    descLabel:setPosition(ccp(desBg:getContentSize().width/2+60,desBg:getContentSize().height/2))
    desBg:addChild(descLabel,5)
    
    local function touch()
        local td=smallDialog:new()
        local str1=getlocal("activity_anniversaryBless_rule5")
        tabStr={" ",str1," "}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28)
        --dialog:setPosition(getCenterPoint(sceneGame))
        sceneGame:addChild(dialog,self.layerNum+1)
    end

    local menuItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,11,nil,nil)
    local menu = CCMenu:createWithItem(menuItem)
    menuItem:setScale(0.8)
    menu:setPosition(ccp(580,bgHeight-200))
    menu:setTouchPriority(-(self.layerNum-1)*20-2)
    self.bgLayer:addChild(menu,5)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acAnniversaryBlessTab2:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return 2
   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
       tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-60,self.normalHeight)
       return  tmpSize
   elseif fn=="tableCellAtIndex" then
       
        local cell=CCTableViewCell:new()
        cell:autorelease()
        cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.normalHeight))
        
        local rect = CCRect(0, 0, 50, 50)
        local capInSet = CCRect(20, 20, 10, 10)
        local function cellClick(hd,fn,idx)     
        end
        local txtSize=25
        if G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage()=="in" or G_getCurChoseLanguage()=="en" or G_getCurChoseLanguage()=="ru" or G_getCurChoseLanguage()=="pt" then
            txtSize=20
        end

        local headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),function (...)end)
        headerSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,self.normalHeight-4))
        headerSprie:ignoreAnchorPointForPosition(false);
        headerSprie:setAnchorPoint(ccp(0,0));
        headerSprie:setTag(1000+idx)
        headerSprie:setIsSallow(false)
        headerSprie:setTouchPriority(-(self.layerNum-1)*20-2)
        headerSprie:setPosition(ccp(0,cell:getContentSize().height-headerSprie:getContentSize().height));
        cell:addChild(headerSprie)
        
        if idx==0 then
            local tid,cur,max,rewardCfg,hasReceived=acAnniversaryBlessVoApi:getTaskData()
            local item={}
            local num = 0
            local award=FormatItem(rewardCfg)
            for k,v in pairs(award) do
                num=v.num
                item=v
            end
            local function showInfo()
                propInfoDialog:create(sceneGame,item,self.layerNum+1,nil,true)
            end
            local mIcon=LuaCCSprite:createWithSpriteFrameName("bless_energy_supply.png",showInfo)
            mIcon:setAnchorPoint(ccp(0,0.5))
            mIcon:setTouchPriority(-(self.layerNum-1)*20-3)
            mIcon:setPosition(ccp(20,headerSprie:getContentSize().height/2-20))
            headerSprie:addChild(mIcon)


            local countLb=GetTTFLabel(tostring(num),25)
            countLb:setAnchorPoint(ccp(1,0))
            countLb:setPosition(ccp(mIcon:getContentSize().width-5,5))
            mIcon:addChild(countLb,5)
            -- countLb:setColor(G_ColorGreen)
           
            local titleLb=GetTTFLabel(getlocal("anniversaryBless_task_title1"),25)
            titleLb:setAnchorPoint(ccp(0,0.5))
            titleLb:setPosition(ccp(20,mIcon:getPositionY()+mIcon:getContentSize().height/2+30))
            headerSprie:addChild(titleLb,5)
            titleLb:setColor(G_ColorGreen)

            local descLabel=GetTTFLabelWrap(getlocal("anniversaryBless_task_des1",{max}),txtSize,CCSizeMake(270,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            descLabel:setAnchorPoint(ccp(0,0.5))
            descLabel:setPosition(ccp(mIcon:getPositionX()+mIcon:getContentSize().width+20,headerSprie:getContentSize().height/2))
            headerSprie:addChild(descLabel,5)

            local function receiveRewards()
                local function onReceive(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                        acAnniversaryBlessVoApi:updateData(sData.data)
                        local award=FormatItem(rewardCfg)
                        for k,v in pairs(award) do
                            G_addPlayerAward(v.type,v.key,v.id,v.num)        
                        end
                        G_showRewardTip(award,true)
                        local btnstr=getlocal("activity_hadReward")
                        local btnNameLb=self.receiveBtn:getChildByTag(1001)
                        btnNameLb=tolua.cast(btnNameLb,"CCLabelTTF")
                        btnNameLb:setString(btnstr)
                        self.receiveBtn:setEnabled(false)
                        --刷新页签红点提示
                        if self.parent then
                            if self.parent.refreshIconTipVisible then
                                self.parent:refreshIconTipVisible()
                            end
                        end
                    end
                end
                --领取能量补给的礼包
                socketHelper:receiveSupplyGift(tid,onReceive)
            end
            
            local buttonstr=getlocal("daily_scene_get")
            if hasReceived and hasReceived==true then
                buttonstr=getlocal("activity_hadReward")
            end
            local confirmItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",receiveRewards,2,buttonstr,25,1001)
            local confirmBtn=CCMenu:createWithItem(confirmItem)
            confirmBtn:setPosition(ccp(headerSprie:getContentSize().width-confirmItem:getContentSize().width/2-10,headerSprie:getContentSize().height/2-20))
            confirmBtn:setTouchPriority(-(self.layerNum-1)*20-2)
            headerSprie:addChild(confirmBtn)
            self.receiveBtn=confirmItem
            
            if self.acIsStoped==true or (hasReceived and hasReceived==true) or cur<max then
                confirmItem:setEnabled(false)
            end

            local timesLb=GetTTFLabel(cur.."/"..max,25)
            timesLb:setAnchorPoint(ccp(0.5,0))
            timesLb:setPosition(ccp(confirmItem:getContentSize().width/2,confirmItem:getContentSize().height+5))
            confirmItem:addChild(timesLb,5)

        elseif idx==1 then
            local pid,cur,max,oldPrice,newPrice=acAnniversaryBlessVoApi:getShopData()
            local num = 1
            local function showInfo()
                local item={}
                local name,pic,desc,id,index,eType,equipId,bgname=getItem(pid,"p")
                item={name=name,pic=pic,desc=desc,id=id,index=index,eType=eType,equipId=equipId,bgname=bgname,num=1}
                propInfoDialog:create(sceneGame,item,self.layerNum+1,nil,true)
            end
            local mIcon=LuaCCSprite:createWithSpriteFrameName("bless_equip_gift.png",showInfo)
            mIcon:setAnchorPoint(ccp(0,0.5))
            mIcon:setTouchPriority(-(self.layerNum-1)*20-3)
            mIcon:setPosition(ccp(20,headerSprie:getContentSize().height/2-20))
            headerSprie:addChild(mIcon)

            local countLb=GetTTFLabel(tostring(num),25)
            countLb:setAnchorPoint(ccp(1,0))
            countLb:setPosition(ccp(mIcon:getContentSize().width-5,5))
            mIcon:addChild(countLb,5)
      
            local titleLb=GetTTFLabel(getlocal("anniversaryBless_task_title2"),25)
            titleLb:setAnchorPoint(ccp(0,0.5))
            titleLb:setPosition(ccp(20,mIcon:getPositionY()+mIcon:getContentSize().height/2+30))
            headerSprie:addChild(titleLb,5)
            titleLb:setColor(G_ColorGreen)
            
            local timesStr="("..cur.."/"..max..")"
            local timesLb=GetTTFLabel(timesStr,25)
            timesLb:setAnchorPoint(ccp(0,0.5))
            timesLb:setPosition(ccp(titleLb:getPositionX()+titleLb:getContentSize().width+10,titleLb:getPositionY()))
            headerSprie:addChild(timesLb,5)

            
            local descLabel=GetTTFLabelWrap(getlocal("anniversaryBless_task_des2"),txtSize,CCSizeMake(270,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            descLabel:setAnchorPoint(ccp(0,0.5))
            descLabel:setPosition(ccp(mIcon:getPositionX()+mIcon:getContentSize().width+20,headerSprie:getContentSize().height/2))
            headerSprie:addChild(descLabel,5)
            
            local oldGoldLb=GetTTFLabel(tostring(oldPrice),30)
            oldGoldLb:setPosition(ccp(headerSprie:getContentSize().width-90,headerSprie:getContentSize().height/2+50))
            headerSprie:addChild(oldGoldLb,5)
            oldGoldLb:setColor(G_ColorRed)
            
            local line = CCSprite:createWithSpriteFrameName("redline.jpg")
            line:setScaleX((oldGoldLb:getContentSize().width  + 30) / line:getContentSize().width)
            --line:setAnchorPoint(ccp(0, 0))
            line:setPosition(getCenterPoint(oldGoldLb))
            oldGoldLb:addChild(line,2)

            local newGoldLb=GetTTFLabel(tostring(newPrice),30)
            newGoldLb:setPosition(ccp(headerSprie:getContentSize().width-90,headerSprie:getContentSize().height/2+15))
            headerSprie:addChild(newGoldLb,5)
            newGoldLb:setColor(G_ColorYellowPro)
            
            local goldIcon1=CCSprite:createWithSpriteFrameName("IconGold.png");
            goldIcon1:setPosition(ccp(oldGoldLb:getPositionX()+50,oldGoldLb:getPositionY()));
            headerSprie:addChild(goldIcon1)
            
            local goldIcon2=CCSprite:createWithSpriteFrameName("IconGold.png");
            goldIcon2:setPosition(ccp(newGoldLb:getPositionX()+50,newGoldLb:getPositionY()));
            headerSprie:addChild(goldIcon2)

            local function buyGift()
                if self.tv:getIsScrolled()==true then
                    return
                end
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                if playerVoApi:getGems()<newPrice then
                    GemsNotEnoughDialog(nil,nil,newPrice-playerVoApi:getGems(),self.layerNum+1,newPrice)
                    do return end
                end

                local function buyCallBack(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                        acAnniversaryBlessVoApi:updateData(sData.data.anniversaryBless)
                        acAnniversaryBlessVoApi:updateShopBuyCount()

                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("vip_tequanlibao_goumai_success"),30)
                        local pid,curNum,maxNum=acAnniversaryBlessVoApi:getShopData()
                        local timesStr="("..curNum.."/"..maxNum..")"
                        timesLb:setString(timesStr)
                        if curNum>=maxNum then
                            local btnstr=getlocal("soldOut")
                            local btnNameLb=self.buyBtn:getChildByTag(1001)
                            btnNameLb=tolua.cast(btnNameLb,"CCLabelTTF")
                            btnNameLb:setString(btnstr)
                            self.buyBtn:setEnabled(false)
                        end
                    end
                end
                local pid,cur,max,oldPrice,newPrice=acAnniversaryBlessVoApi:getShopData()
                if type(pid)~="number" then
                    pid=RemoveFirstChar(pid)
                end
                socketHelper:buyProc(pid,buyCallBack,1,"anniversaryBless")
            end
            
            local buttonstr=getlocal("buy")
            if cur>=max then
                buttonstr=getlocal("soldOut")
            end
            local confirmItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",buyGift,2,buttonstr,25,1001)
            local confirmBtn=CCMenu:createWithItem(confirmItem)
            confirmBtn:setPosition(ccp(headerSprie:getContentSize().width-confirmItem:getContentSize().width/2-10,headerSprie:getContentSize().height/2-40))
            confirmBtn:setTouchPriority(-(self.layerNum-1)*20-3)
            headerSprie:addChild(confirmBtn)
            self.buyBtn=confirmItem

            if self.acIsStoped==true or cur>=max then
                confirmItem:setEnabled(false)
            end
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

function acAnniversaryBlessTab2:tick()
    local istoday=acAnniversaryBlessVoApi:isToday()

    if istoday ~= self.isToday and istoday==false then
        if self.tv then
            self.tv:reloadData()
        end
        self.isToday=istoday
    end
end

function acAnniversaryBlessTab2:dispose()
    self.layerNum=nil
    self.dialogLayer=nil
    self.bgLayer=nil
    self.closeBtn=nil
    self.tv=nil
    self.normalHeight=nil
    self=nil
end
