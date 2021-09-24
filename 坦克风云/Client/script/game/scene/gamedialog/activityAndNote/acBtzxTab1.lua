acBtzxTab1={
}

function acBtzxTab1:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.tv=nil
    self.bgLayer=nil
    self.layerNum=layerNum

    return nc;
end

function acBtzxTab1:init()
    self.bgLayer=CCLayer:create()
    self:initUI()
    self:initTableView()
    return self.bgLayer
end


function acBtzxTab1:initUI()

    -- 活动 时间 描述
    local lbH=self.bgLayer:getContentSize().height-185

    local actTime=GetTTFLabel(getlocal("activity_timeLabel"),30)
    actTime:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-185))
    self.bgLayer:addChild(actTime,5)
    actTime:setColor(G_ColorYellowPro)

    local acVo = acBtzxVoApi:getAcVo()
    lbH=lbH-35
    local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
    local timeLabel=GetTTFLabel(timeStr,25)
    timeLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2, self.bgLayer:getContentSize().height-220))
    self.bgLayer:addChild(timeLabel,1)
    self.timeLabel = timeLabel
    self:updateAcTime()

    lbH=lbH-35-20


    local startW=40
    local activeDesLb=GetTTFLabelWrap(getlocal("activity_btzx_info1"),25,CCSize(G_VisibleSizeWidth-startW*2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    activeDesLb:setAnchorPoint(ccp(0,1))
    activeDesLb:setPosition(startW,lbH)
    self.bgLayer:addChild(activeDesLb,2)

    local desBg=CCSprite:createWithSpriteFrameName("allianceHeaderBg_black.png")
    desBg:setAnchorPoint(ccp(0.5,1))
    desBg:setPosition(ccp(G_VisibleSizeWidth/2,lbH+15))
    self.bgLayer:addChild(desBg)
    desBg:setScaleX(580/desBg:getContentSize().width)
    desBg:setScaleY((activeDesLb:getContentSize().height+30)/desBg:getContentSize().height)
    desBg:setOpacity(180)

    lbH=lbH-activeDesLb:getContentSize().height-10-20
    self.tvPosH=40
    self.tvVisibleH=lbH-self.tvPosH
end

function acBtzxTab1:updateAcTime()
    local acVo=acBtzxVoApi:getAcVo()
    if acVo and self.timeLabel and tolua.cast(self.timeLabel,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.timeLabel,nil,nil,nil,true)
    end
end
function acBtzxTab1:tick()
    self:updateAcTime()
end
function acBtzxTab1:initTableView()

    self.cellHeight=180
    if(G_isIphone5())then
        self.cellHeight=230
    end
    self.cellNum=3

    local function callBack(...)
         return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-50,self.tvVisibleH),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(25,self.tvPosH))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(0)
end

function acBtzxTab1:eventHandler(handler,fn,idx,cel)
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

        local cellHeight=self.cellHeight
        if(G_isIphone5())then
            cellHeight=self.cellHeight-60
        else
            cellHeight=self.cellHeight-10
        end
        local bgPic="panelItemBg.png"
        -- local bgPic="panelItemBg.png"
        -- panelItemBg
        local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName(bgPic,capInSet,cellClick)
        backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,cellHeight))
        backSprie:ignoreAnchorPointForPosition(false)
        backSprie:setAnchorPoint(ccp(0,0))
        backSprie:setIsSallow(false)
        backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
        backSprie:setPosition(ccp(0,self.cellHeight-cellHeight))
        cell:addChild(backSprie,1)

        local bsSize=backSprie:getContentSize()

        local goldLineSprite = CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
        goldLineSprite:setAnchorPoint(ccp(0.5,1))
        goldLineSprite:setPosition(ccp(bsSize.width/2,bsSize.height))
        backSprie:addChild(goldLineSprite)


        local iconPic
        local bgPic
        if idx==0 then
            iconPic="icon_moveFastNew.png"
        elseif idx==1 then
            iconPic="rpCoin.png"
            bgPic="icon_bg_gray.png"
        else
            iconPic="tech_metal_up.png"
        end
        local starPosX=20
        local centerH=(bsSize.height-goldLineSprite:getContentSize().height)/2
        
        local iconSp
        if bgPic then
            iconSp=GetBgIcon(iconPic,nil,bgPic,90,100)
        else
            iconSp=CCSprite:createWithSpriteFrameName(iconPic)
        end
        
        -- CCSprite:createWithSpriteFrameName(iconPic)
        backSprie:addChild(iconSp)
        iconSp:setPosition(starPosX+50,centerH)

        local desLb=GetTTFLabelWrap(getlocal("activity_btzx_task_info" .. idx+1),25,CCSize(bsSize.width-140-10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        desLb:setAnchorPoint(ccp(0,1))
        backSprie:addChild(desLb)
        desLb:setPosition(starPosX+120,centerH+50)

        local numBg = CCSprite:createWithSpriteFrameName("acNewYearFadeLight.png")
        numBg:setAnchorPoint(ccp(0.5,1))
        numBg:setScaleX(200/numBg:getContentSize().width)
        numBg:setPosition(ccp(bsSize.width-100,centerH))
        backSprie:addChild(numBg)

        local cfg=acBtzxVoApi:getCfg()
        local numStr=cfg.buff[idx+1]*100 .. "%"
        local numLb=GetTTFLabel(numStr,30)
        numBg:addChild(numLb)
        numLb:setScaleX(numBg:getContentSize().width/200)
        numLb:setPosition(getCenterPoint(numBg))
        numLb:setColor(G_ColorYellowPro)


        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end


function acBtzxTab1:refresh()    
end


function acBtzxTab1:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.tv=nil
    self.layerNum=nil
end
