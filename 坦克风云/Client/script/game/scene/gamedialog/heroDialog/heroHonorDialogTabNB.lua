--已授勋将领列表
heroHonorDialogTabNB={}
function heroHonorDialogTabNB:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.heroList=nil
    return nc
end

function heroHonorDialogTabNB:updateHeroList()
    self.heroList=G_clone(heroVoApi:getHonoredHeroList())
end
function heroHonorDialogTabNB:getHeroList()
    if self.heroList==nil then
        self.heroList={}
    end
    return self.heroList
end

function heroHonorDialogTabNB:init(layerNum,parent)
    self.layerNum=layerNum
    self.parent=parent
    self.bgLayer=CCLayer:create()
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local bigBg=CCSprite:create("public/emblem/emblemBlackBg.jpg")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    bigBg:setScaleY((G_VisibleSizeHeight - 194)/bigBg:getContentSize().height)
    bigBg:setScaleX((G_VisibleSizeWidth - 42)/bigBg:getContentSize().width)
    bigBg:setAnchorPoint(ccp(0,0))
    bigBg:setPosition(ccp(21,32))
    self.bgLayer:addChild(bigBg)
    self:initTableView()
    local function honorListener(event,data)
        self:dealWithEvent(event,data)
    end
    self.honorListener=honorListener
    eventDispatcher:addEventListener("hero.honor",honorListener)
    return self.bgLayer
end

--设置对话框里的tableView
function heroHonorDialogTabNB:initTableView()
    self:updateHeroList()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 60,G_VisibleSizeHeight - 200),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,30))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)

    local heroList=self:getHeroList()
    if heroList and SizeOfTable(heroList)==0 then
        local noHeroLb=GetTTFLabelWrap(getlocal("hero_honor_no_had_honor"),35,CCSizeMake(G_VisibleSizeWidth - 80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        noHeroLb:setPosition(ccp(G_VisibleSizeWidth/2,(G_VisibleSizeHeight - 135)/2 + 15))
        self.bgLayer:addChild(noHeroLb)
        noHeroLb:setColor(G_ColorWhite)
    end
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function heroHonorDialogTabNB:eventHandler(handler,fn,idx,cel)
    local strSize2 = 22
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =24
    elseif G_getCurChoseLanguage() =="de" then
        strSize2 =17
    end
    if fn=="numberOfCellsInTableView" then
        return #(self:getHeroList())
    elseif fn=="tableCellSizeForIndex" then
        return CCSizeMake(G_VisibleSizeWidth - 60,170)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local hero=self.heroList[idx+1]
        local function cellClick(hd,fn,idx)
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do return end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                heroVoApi:showHeroRealiseDialog(hero,self.layerNum+1)
            end
        end
        local height = 150
        local mIcon=heroVoApi:getHeroIcon(hero.hid,hero.productOrder,nil,nil,nil,true)
        mIcon:setPosition(ccp(90,height/2 + 5))
        mIcon:setScale(0.8)
        cell:addChild(mIcon,2)
        local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("serverWarLocalTip.png",CCRect(40, 20, 40, 45),cellClick)
        backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60 - 75, height - 30))
        backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
        backSprie:setRotation(180)
        backSprie:setTag(1001 + idx)
        backSprie:setIsSallow(false)
        backSprie:setPosition((G_VisibleSizeWidth - 60)/2 + 30,height/2)
        cell:addChild(backSprie)


        local nameStr=getlocal(heroListCfg[hero.hid].heroName)
        if  heroVoApi:isInQueueByHid(hero.hid) then
            nameStr=nameStr..getlocal("designate")
        end
        local nameLb=GetTTFLabel(nameStr, 24, true)
        local color=heroVoApi:getHeroColor(hero.productOrder)
        nameLb:setColor(color)
        nameLb:setAnchorPoint(ccp(0,0.5))
        nameLb:setPosition(ccp(90 + mIcon:getContentSize().width/2,height/2 + 15))
        cell:addChild(nameLb)
        local qualityLevel,qualityStr,qualityLevelColor=heroVoApi:getQualityLevel(hero.realiseNum)
        local qualityLb=G_getRichTextLabel(getlocal("hero_honor_quality_level",{qualityStr}),{G_ColorWhite,qualityLevelColor,G_ColorWhite},22,200,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        qualityLb:setAnchorPoint(ccp(0,0.5))
        qualityLb:setPosition(ccp(90 + mIcon:getContentSize().width/2,height/2 - 20))
        cell:addChild(qualityLb)

        local function callBack()
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do return end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                heroVoApi:showHeroRealiseDialog(hero,self.layerNum+1)
            end
        end
        local selectAllItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",callBack,nil,getlocal("hero_honor_realise"),strSize2)
        selectAllItem:setAnchorPoint(ccp(1,0.5))
        local selectAllBtn=CCMenu:createWithItem(selectAllItem);
        selectAllBtn:setTouchPriority(-(self.layerNum-1)*20-2);
        selectAllBtn:setPosition(ccp(G_VisibleSizeWidth - 90,height/2))
        cell:addChild(selectAllBtn)
        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

function heroHonorDialogTabNB:tick()

end

function heroHonorDialogTabNB:dealWithEvent(event,data)
    if(data.type=="success")then
        self.heroList=G_clone(heroVoApi:getHonoredHeroList())
        self.tv:reloadData()
    elseif(data.type=="update")then
        self.heroList=G_clone(heroVoApi:getHonoredHeroList())
        self.tv:reloadData()
    end
end

function heroHonorDialogTabNB:dispose()
    eventDispatcher:removeEventListener("hero.honor",self.honorListener)
    self.bgLayer:removeFromParentAndCleanup(true)
    self.layerNum=nil
    self.bgLayer=nil
end