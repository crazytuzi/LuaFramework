acBenfuqianxianTab1={}

function acBenfuqianxianTab1:new()
    local nc={}
    nc.height=90
    nc.integralLvCfg={}
    nc.numberCell=0
    nc.tvHeight=380
    nc.cellHeight=0
    nc.desHeight=120
    nc.fixedCell=5
    nc.integralBg=nil
    nc.integralIcon=nil
    nc.integralLb=nil

    setmetatable(nc,self)
    self.__index=self

    return nc
end

function acBenfuqianxianTab1:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent

    self:initTableView()
    self:initIntegralRewardsView()
    self:doUserHandler()

    self:refresh()

    return self.bgLayer
end

function acBenfuqianxianTab1:initTableView()
    if(G_isIphone5()) then
        self.height=120
        self.desHeight=150
    end
    self.integralLvCfg=acBenfuqianxianVoApi:getIntegralLvCfg()
    self.numberCell=SizeOfTable(self.integralLvCfg)
    self.tvHeight=self.height*self.fixedCell+60
    self.cellHeight=self.height*self.numberCell+60
    local function callBack( ... )
        return self:eventHandler(...)
    end 
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-20,self.tvHeight),nil)
    self.bgLayer:addChild(self.tv,2)
    self.tv:setPosition(ccp(10,G_VisibleSizeHeight-180-self.desHeight-self.tvHeight-90))
    self.tv:setAnchorPoint(ccp(0,0))
    self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    if self.numberCell>self.fixedCell then
        self.tv:setMaxDisToBottomOrTop(120)
    else
        self.tv:setMaxDisToBottomOrTop(0)
    end
end

function acBenfuqianxianTab1:initIntegralRewardsView()
    local function cellClick(hd,fn,index)
    end

    local w=G_VisibleSizeWidth-20 -- 背景框的宽度
    local h=G_VisibleSizeHeight-180
    local function touch(tag,object)
        self:openInfo()
    end
    local lineBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",CCRect(168, 86, 10, 10),cellClick)
    lineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-66))
    lineBg:setContentSize(CCSizeMake(600,G_VisibleSize.height-180))
    self.bgLayer:addChild(lineBg)

    local acIconSp = CCSprite:createWithSpriteFrameName("satellite.png")
    acIconSp:setAnchorPoint(ccp(0,0.5))
    acIconSp:setScale(1.2)
    acIconSp:setPosition(ccp(30,G_VisibleSizeHeight-170-self.desHeight/2))
    self.bgLayer:addChild(acIconSp)
    w=w-10 -- 按钮的x坐标
    local timeStr=acBenfuqianxianVoApi:getTimeStr()
    local timeLb = GetTTFLabelWrap(timeStr,25,CCSizeMake(G_VisibleSizeWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    timeLb:setAnchorPoint(ccp(0.5,1))
    timeLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-170))
    self.bgLayer:addChild(timeLb)

    local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,nil,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,0.5))
    menuItemDesc:setScale(0.8)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
    menuDesc:setPosition(ccp(w,h-menuItemDesc:getContentSize().height*menuItemDesc:getScale()/2+10))
    self.bgLayer:addChild(menuDesc)

    local desStr = getlocal("activity_benfuqianxian_desc")
    local desTv, desLabel= G_LabelTableView(CCSizeMake(self.bgLayer:getContentSize().width*0.7, 90),desStr,25,kCCTextAlignmentLeft)
    desTv:setPosition(ccp(160,h-timeLb:getContentSize().height-90))
    self.bgLayer:addChild(desTv)
    desTv:setAnchorPoint(ccp(0,1))
    desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    desTv:setMaxDisToBottomOrTop(80)
    acIconSp:setPosition(ccp(30,G_VisibleSizeHeight-170-(timeLb:getContentSize().height+90)/2))

    local function nilFunc()
    end
    local integralBg=LuaCCScale9Sprite:createWithSpriteFrameName("acRadar_integralBg.png",CCRect(75,35,50,30),nilFunc)
    integralBg:setAnchorPoint(ccp(0.5,1))
    integralBg:setContentSize(CCSizeMake(G_VisibleSize.width-300,80))
    integralBg:setPosition(ccp(G_VisibleSizeWidth/2,desTv:getPositionY()-20))
    self.bgLayer:addChild(integralBg,1)
    local integralIcon=CCSprite:createWithSpriteFrameName("acRadar_integralIcon.png")
    integralIcon:setAnchorPoint(ccp(0,0.5))
    integralBg:addChild(integralIcon)
    local integralLb=GetTTFLabel(acBenfuqianxianVoApi:getIntegralCount(),25)
    integralLb:setAnchorPoint(ccp(0,0.5))
    integralBg:addChild(integralLb)
    local cwidth=integralIcon:getContentSize().width+integralLb:getContentSize().width
    integralIcon:setPosition(ccp((integralBg:getContentSize().width-cwidth)/2,integralBg:getContentSize().height/2+12))
    integralLb:setPosition(ccp(integralIcon:getPositionX()+integralIcon:getContentSize().width,integralBg:getContentSize().height/2+12))
    self.integralBg=integralBg
    self.integralIcon=integralIcon
    self.integralLb=integralLb
    local fadeLineSp=CCSprite:createWithSpriteFrameName("acNewYearFadeLight.png")
    fadeLineSp:setScaleY(0.5)
    fadeLineSp:setPosition(ccp(G_VisibleSize.width/2,integralBg:getPositionY()-integralBg:getContentSize().height/2))
    self.bgLayer:addChild(fadeLineSp)
end

function acBenfuqianxianTab1:doUserHandler()
end

function acBenfuqianxianTab1:eventHandler( handler,fn,idx,cel )
    if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then
        return  CCSizeMake(G_VisibleSizeWidth-20,self.cellHeight)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local height = self.height
        local totalW = G_VisibleSizeWidth-20
        local totalH = self.cellHeight
        local spaceH = (self.cellHeight-self.numberCell*self.height)/2+10
        local function click(hd,fn,idx)
        end
        local itemBg = CCSprite:createWithSpriteFrameName("acLabelbg.png")
        itemBg:setAnchorPoint(ccp(0,0))
        itemBg:setScaleX((G_VisibleSize.width-160)/itemBg:getContentSize().width)
        itemBg:setScaleY(self.numberCell*self.height/itemBg:getContentSize().height)
        -- itemBg:setContentSize(CCSizeMake(G_VisibleSize.width-160,self.numberCell*self.height))
        itemBg:setPosition(ccp(160,spaceH))
        cell:addChild(itemBg)

        for i=1,self.numberCell do
            local spWidth=210
            local posY=self.height/2+(i-1)*height+spaceH
            local state=acBenfuqianxianVoApi:getStateByIntegralLv(i)
            -- 判断 条件不足  可领取  已领取
            if state==1 then
                local hasRewardLb = GetTTFLabelWrap(getlocal("noReached"),25,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                hasRewardLb:setPosition(ccp(520,posY))
                cell:addChild(hasRewardLb)
            elseif state==2 then
                local function receiveHandler(tag,object)
                    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                        if G_checkClickEnable()==false then
                            do
                                return
                            end
                        else
                            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
                        end
                        PlayEffect(audioCfg.mouseClick)
                        local function callBack()
                            if self and self.tv then
                                self.tv:reloadData()
                            end
                        end
                        acBenfuqianxianVoApi:receiveRewardsRequest(tag,callBack)
                    end               
                end
                local getBtn = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnGraySmall_Down.png",receiveHandler,i,getlocal("daily_scene_get"),30)
                getBtn:setScale(0.7)
                local btnMenu=CCMenu:createWithItem(getBtn)
                btnMenu:setPosition(ccp(520,posY))
                btnMenu:setTouchPriority(-(self.layerNum-1)*20-2)
                cell:addChild(btnMenu,1)
            else
                local rightIcon=CCSprite:createWithSpriteFrameName("IconCheck.png")
                rightIcon:setAnchorPoint(ccp(0.5,0.5))
                rightIcon:setPosition(ccp(520,posY))
                cell:addChild(rightIcon,1)
            end
            
            -- 刻度线
            local keduSp = CCSprite:createWithSpriteFrameName("acRadar_splitline.png")
            keduSp:setPosition(60,i*self.height+spaceH)
            cell:addChild(keduSp,3)

            --充值等级
            local numBgSp = CCSprite:createWithSpriteFrameName("acRadar_numlabel.png")
            numBgSp:setAnchorPoint(ccp(0,1))
            numBgSp:setPosition(70,i*self.height+8+spaceH)
            cell:addChild(numBgSp,3)

            local numLb=GetTTFLabel(self.integralLvCfg[i],22)
            numLb:setPosition(numBgSp:getContentSize().width/2+5,numBgSp:getContentSize().height/2)
            numBgSp:addChild(numLb)
            
            if i>1 then
                local lineSprite = CCSprite:createWithSpriteFrameName("acChunjiepansheng_orangeLine.png")
                lineSprite:setScaleX((totalW + 30)/lineSprite:getContentSize().width)
                lineSprite:setPosition(ccp((totalW + 30)/2 + 30,0+(i-1)*height+spaceH))
                cell:addChild(lineSprite)
            end

            local rewards=acBenfuqianxianVoApi:getRewardsByIntegralLv(i)
            if rewards then
                rewards=FormatItem(rewards)
                for k,v in pairs(rewards) do
                    local icon,scale=G_getItemIcon(v,80,true,self.layerNum,nil,self.tv)
                    if icon and scale then
                        icon:setTouchPriority(-(self.layerNum-1)*20-2)
                        cell:addChild(icon,2)
                        icon:setPosition(210+(k-1)*90, posY)

                        local numLabel=GetTTFLabel("x"..v.num,21)
                        numLabel:setAnchorPoint(ccp(1,0))
                        numLabel:setPosition(icon:getContentSize().width-5, 5)
                        numLabel:setScale(1/scale)
                        icon:addChild(numLabel,1)
                        if acBenfuqianxianVoApi:isFlick(v.key)==true then
                            G_addRectFlicker(icon,1.1/icon:getScaleX(),1.1/icon:getScaleY(),ccp(icon:getContentSize().width/2,icon:getContentSize().height/2))
                        end
                    end        
                end
            end
        end

        local barWidth=self.numberCell*self.height
        local barBgH=totalH
        local barSprie = LuaCCScale9Sprite:createWithSpriteFrameName("acRadar_progressBg.png", CCRect(15,50,50,80),click)
        barSprie:setContentSize(CCSizeMake(86,totalH))
        barSprie:setPosition(ccp(60,totalH/2))
        cell:addChild(barSprie,1)

        AddProgramTimer(cell,ccp(60,barWidth/2+spaceH),11,12,nil,"acChunjiepansheng_progress2.png","acChunjiepansheng_progress1.png",13,1,1,nil,ccp(0,1))
        local per=acBenfuqianxianVoApi:getIntegralPercent()
        local timerSpriteLv=cell:getChildByTag(11)
        timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
        timerSpriteLv:setPercentage(per)
        timerSpriteLv:setScaleY((barWidth)/timerSpriteLv:getContentSize().height)
        timerSpriteLv:setRotation(180)
        local bg = cell:getChildByTag(13)
        bg:setScaleY((barWidth)/bg:getContentSize().height)

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
    end
end

function acBenfuqianxianTab1:showShine()

end
function acBenfuqianxianTab1:openInfo()
    if G_checkClickEnable()==false then
        do
            return
        end
    else
        base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
    end
    PlayEffect(audioCfg.mouseClick)
    
    local sd=smallDialog:new()
    local strTab={}
    local colorTab={}
    local tabAlignment={}
    local ruleStr=getlocal("activityDescription")
    local ruleStr1=getlocal("activity_benfuqianxian_rule1")
    local ruleStr2=getlocal("activity_benfuqianxian_rule2")
    local ruleStr3=getlocal("activity_benfuqianxian_tip")

    strTab={" ",ruleStr3," ",ruleStr2,ruleStr1," ",ruleStr," "}
    colorTab={nil,G_ColorRed,nil,nil,nil,nil,G_ColorYellowPro,nil}
    tabAlignment={nil,kCCTextAlignmentCenter,nil,nil,nil,nil,kCCTextAlignmentCenter,nil}

    local dialogLayer=sd:init("TankInforPanel.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,strTab,25,colorTab,nil,nil,nil,tabAlignment)
    sceneGame:addChild(dialogLayer,self.layerNum+1)
    dialogLayer:setPosition(ccp(0,0))   
end

function acBenfuqianxianTab1:refresh()
    if self and self.integralBg and self.integralIcon and self.integralLb then
        self.integralLb:setString(acBenfuqianxianVoApi:getIntegralCount())
        local cwidth=self.integralIcon:getContentSize().width+self.integralLb:getContentSize().width
        self.integralIcon:setPosition(ccp((self.integralBg:getContentSize().width-cwidth)/2,self.integralBg:getContentSize().height/2+12))
        self.integralLb:setPosition(ccp(self.integralIcon:getPositionX()+self.integralIcon:getContentSize().width,self.integralBg:getContentSize().height/2+12))
    end
end

function acBenfuqianxianTab1:tick()
    local isEnd=acBenfuqianxianVoApi:isEnd()
    if isEnd==false then
        if acBenfuqianxianVoApi:getFlag(1)==0 then
            self:updateUI()
            acBenfuqianxianVoApi:setFlag(1,1)
        end
    end
end

function acBenfuqianxianTab1:updateUI()
    if self then
        self:refresh()
        if self.tv then
            self.tv:reloadData()
        end
    end
end

function acBenfuqianxianTab1:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.layerNum=nil
    self.height=90
    self.integralLvCfg={}
    self.numberCell=0
    self.tvHeight=380
    self.cellHeight=0
    self.desHeight=120
    self.fixedCell=5
    self.integralBg=nil
    self.integralIcon=nil
    self.integralLb=nil
end