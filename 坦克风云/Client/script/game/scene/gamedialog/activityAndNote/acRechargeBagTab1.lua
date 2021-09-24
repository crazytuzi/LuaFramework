acRechargeBagTab1={}

function acRechargeBagTab1:new()
    local nc={}
    nc.height=90
    nc.rechargeLvCfg={}
    nc.numberCell=0
    nc.tvHeight=380
    nc.desHeight=120
    nc.extraW=400
    nc.extraLb=nil
    nc.totalLb=nil
    nc.donateBtn=nil
    nc.receiveBtn=nil
    nc.desTv=nil
    nc.extraGemsLb=nil
    nc.needGemsLb=nil
    nc.gemsNode=nil
    nc.gemsSp=nil
    nc.adaH = 0
    nc.slidH = 80
    if G_getIphoneType() == G_iphoneX then
        nc.adaH = 1250 - 1136
        nc.slidH = 0
    end
    setmetatable(nc,self)
    self.__index=self

    return nc
end

function acRechargeBagTab1:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent

    self:initTableView()
    self:initRechargeBagView()
    self:doUserHandler()

    self:refresh()

    return self.bgLayer
end

function acRechargeBagTab1:initTableView()
    if(G_isIphone5()) then
        self.height=120
        self.desHeight=150
    end
    self.rechargeLvCfg=acRechargeBagVoApi:getRechargeLvCfg()
    self.numberCell=SizeOfTable(self.rechargeLvCfg)
    self.tvHeight=self.height*self.numberCell+50
    local function callBack( ... )
        return self:eventHandler(...)
    end 
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-20,self.tvHeight),nil)
    self.bgLayer:addChild(self.tv,2)
    self.tv:setPosition(ccp(10,G_VisibleSizeHeight-180-self.desHeight-self.tvHeight-28))
    self.tv:setAnchorPoint(ccp(0,0))
    self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    if self.numberCell>4 then
        self.tv:setMaxDisToBottomOrTop(120)
    else
        self.tv:setMaxDisToBottomOrTop(0)
    end
end

function acRechargeBagTab1:initRechargeBagView()
    local function cellClick(hd,fn,index)
    end

    local w=G_VisibleSizeWidth-20 -- 背景框的宽度
    local h=G_VisibleSizeHeight-180
    local function touch(tag,object)
        self:openInfo()
    end

    local blueBg=CCSprite:create("public/superWeapon/weaponBg.jpg")
    blueBg:setAnchorPoint(ccp(0.5,0))
    blueBg:setScaleX((G_VisibleSizeWidth-45)/blueBg:getContentSize().width)
    blueBg:setScaleY((G_VisibleSizeHeight-190)/blueBg:getContentSize().height)
    blueBg:setPosition(G_VisibleSizeWidth/2,30)
    self.bgLayer:addChild(blueBg)

    local yellowbgSp=LuaCCScale9Sprite:createWithSpriteFrameName("dwEndBg2.png",CCRect(0,0,126,126),function ()end)
    yellowbgSp:setContentSize(CCSizeMake(self.tvHeight+120,G_VisibleSizeWidth-20))
    yellowbgSp:setPosition(ccp(G_VisibleSizeWidth-yellowbgSp:getContentSize().height/2,G_VisibleSizeHeight-180-self.desHeight-yellowbgSp:getContentSize().width/2-20))
    yellowbgSp:setOpacity(100)
    yellowbgSp:setRotation(90)
    self.bgLayer:addChild(yellowbgSp)

    local lineBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",CCRect(168, 86, 10, 10),cellClick)
    lineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-66))
    lineBg:setContentSize(CCSizeMake(600,G_VisibleSize.height-180))
    self.bgLayer:addChild(lineBg)

    w=w-10 -- 按钮的x坐标
    local descStr1=acRechargeBagVoApi:getTimeStr()
    local descStr2=acRechargeBagVoApi:getRewardTimeStr()
    local fontSize=23
    local spaceX=-7
    if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="ko" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="tw" then
        fontSize=25
        spaceX=0
    end
    local moveBgStarStr = G_LabelRollView(CCSizeMake(w-100,70),descStr1,fontSize,kCCTextAlignmentCenter,G_ColorGreen,nil,descStr2,G_ColorYellowPro,2,2,2,nil)
    moveBgStarStr:setPosition(ccp(80,h-moveBgStarStr:getContentSize().height+5))
    self.bgLayer:addChild(moveBgStarStr,2)

    local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon2.png",touch,nil,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,0.5))
    menuItemDesc:setScale(0.8)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
    menuDesc:setPosition(ccp(w,h-menuItemDesc:getContentSize().height*menuItemDesc:getScale()/2+10))
    self.bgLayer:addChild(menuDesc)

    local pic,bagCount=acRechargeBagVoApi:getDonateBag()
    local bagSp = nil
    if pic and bagCount then
        bagSp = CCSprite:createWithSpriteFrameName(pic)
        bagSp:setAnchorPoint(ccp(0,0.5))
        bagSp:setPosition(ccp(30,G_VisibleSizeHeight-170-self.desHeight/2))
        self.bgLayer:addChild(bagSp)
        local numLabel=GetTTFLabel("x"..bagCount,21)
        numLabel:setAnchorPoint(ccp(1,0))
        numLabel:setPosition(bagSp:getContentSize().width-5, 5)
        bagSp:addChild(numLabel,1)
        self.totalLb=numLabel
    end

    local desStr = getlocal("activity_rechargebag_des")
    local desTv, desLabel= G_LabelTableView(CCSizeMake(self.bgLayer:getContentSize().width*0.7, 60),desStr,25,kCCTextAlignmentLeft)
    desTv:setPosition(ccp(140,bagSp:getPositionY()-bagSp:getContentSize().height*0.5-10))
    self.bgLayer:addChild(desTv)
    -- desTv:setAnchorPoint(ccp(0,1))
    desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    desTv:setMaxDisToBottomOrTop(80)

    local lineupSp = CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
    lineupSp:setAnchorPoint(ccp(0.5,1))
    lineupSp:setPosition(ccp(G_VisibleSizeWidth/2,h-self.desHeight))
    self.bgLayer:addChild(lineupSp,1)
    local fadeSp1 = LuaCCScale9Sprite:createWithSpriteFrameName("brown_fade2.png", CCRect(0,0,306,99),cellClick)
    fadeSp1:setContentSize(CCSizeMake(w+60,200))
    fadeSp1:setAnchorPoint(ccp(0.5,1))
    fadeSp1:setOpacity(150)
    fadeSp1:setPosition(ccp(G_VisibleSizeWidth/2,lineupSp:getPositionY()))
    self.bgLayer:addChild(fadeSp1)

    local linedownSp = CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
    linedownSp:setAnchorPoint(ccp(0.5,1))
    linedownSp:setPosition(ccp(G_VisibleSizeWidth/2,120+self.adaH))
    linedownSp:setRotation(180)
    self.bgLayer:addChild(linedownSp,1)
    local fadeSp2 = LuaCCScale9Sprite:createWithSpriteFrameName("brown_fade1.png", CCRect(0,0,162,66),cellClick)
    fadeSp2:setContentSize(CCSizeMake(w-10,150))
    fadeSp2:setAnchorPoint(ccp(0.5,0))
    fadeSp2:setOpacity(150)
    fadeSp2:setPosition(ccp(G_VisibleSizeWidth/2,linedownSp:getPositionY()))
    self.bgLayer:addChild(fadeSp2)

    local spaceY=-10
    if G_getIphoneType() == G_iphoneX then
        spaceY = 1250 - 1136
    elseif G_isIphone5()==true then
        spaceY=0
    end
    local pid,icon,scale,extraCount=acRechargeBagVoApi:getExtraBag()
    if icon then
        icon:setAnchorPoint(ccp(0,0))
        icon:setPosition(30,158+spaceY)
        self.bgLayer:addChild(icon)

        local numLabel=GetTTFLabel("x"..extraCount,21)
        numLabel:setAnchorPoint(ccp(1,0))
        numLabel:setPosition(icon:getContentSize().width-5, 5)
        numLabel:setScale(1/scale)
        icon:addChild(numLabel,1)
        self.extraLb=numLabel
    end

    local function receiveHandler(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end
        PlayEffect(audioCfg.mouseClick)
        local function callBack()
            self:refresh()
        end
        acRechargeBagVoApi:rechargeBagRequest("extra",nil,callBack)
    end
    local getBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",receiveHandler,nil,getlocal("daily_scene_get"),30)
    getBtn:setScale(0.7)
    local btnMenu=CCMenu:createWithItem(getBtn)
    btnMenu:setPosition(ccp(520-self.adaH/6,148+getBtn:getContentSize().height/2+spaceY))
    btnMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(btnMenu,1)
    self.receiveBtn=getBtn
    local limit=acRechargeBagVoApi:getRechargeLimit()
    local chargeCount=acRechargeBagVoApi:getRechargeCount()
    if tonumber(chargeCount)<tonumber(limit) then
        getBtn:setVisible(false)
        self.extraW=self.bgLayer:getContentSize().width*0.7
        self.extraLb:setVisible(false)
    else
        self.extraW=360
        self.extraLb:setVisible(true)
    end
    local desStr2 = getlocal("activity_rechargebag_des2",{acRechargeBagVoApi:getRechargeLimit(),acRechargeBagVoApi:getNeedRecharge()})
    local desTv2, desLabel2= G_LabelTableView(CCSizeMake(self.extraW,self.tv:getPositionY()-148),desStr2,25,kCCTextAlignmentLeft)
    desTv2:setPosition(ccp(120,148+self.adaH/2))
    self.bgLayer:addChild(desTv2)
    desTv2:setAnchorPoint(ccp(0,0))
    desTv2:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    desTv2:setMaxDisToBottomOrTop(self.slidH)
    self.desTv=desTv2

    local extraGems=acRechargeBagVoApi:getExtraCharge()
    local needGems=acRechargeBagVoApi:getNeedRecharge()
    local moneyNode = CCNode:create()
    local goldIconSp=CCSprite:createWithSpriteFrameName("IconGold.png")
    goldIconSp:setAnchorPoint(ccp(0,0.5))
    moneyNode:addChild(goldIconSp)

    local goldLb1 = GetTTFLabel(tostring(extraGems),22)
    goldLb1:setAnchorPoint(ccp(0,0.5))
    moneyNode:addChild(goldLb1)
    if tonumber(extraGems)<tonumber(needGems) then
        goldLb1:setColor(G_ColorRed)
    end
    local goldLb2 = GetTTFLabel("/"..needGems,22)
    goldLb2:setAnchorPoint(ccp(0,0.5))
    moneyNode:addChild(goldLb2)

    local moneyLabelWidth = goldIconSp:getContentSize().width+goldLb1:getContentSize().width+goldLb2:getContentSize().width
    moneyNode:setContentSize(CCSizeMake(moneyLabelWidth,goldLb1:getContentSize().height))
    goldIconSp:setPosition(ccp(0+self.adaH/10,moneyNode:getContentSize().height/2+self.adaH))
    goldLb1:setPosition(ccp(goldIconSp:getContentSize().width+self.adaH/10,moneyNode:getContentSize().height/2+self.adaH))
    goldLb2:setPosition(ccp(goldLb1:getPositionX()+goldLb1:getContentSize().width,moneyNode:getContentSize().height/2+self.adaH))

    moneyNode:setAnchorPoint(ccp(0,0))
    moneyNode:setScale(1/getBtn:getScale())
    moneyNode:setPosition(ccp(-20,getBtn:getContentSize().height+20))
    getBtn:addChild(moneyNode)
    self.gemsSp=goldIconSp
    self.extraGemsLb=goldLb1
    self.needGemsLb=goldLb2
    self.gemsNode=moneyNode

    local function donateCallBack(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end
        PlayEffect(audioCfg.mouseClick)
        friendMailVoApi:showSelectFriendDialog(self.layerNum,tag)
    end
    local donateBtn = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",donateCallBack,pid,getlocal("rechargeGifts_giveLabel"),30)
    -- donateBtn:setScale(0.9)
    local donateMenu=CCMenu:createWithItem(donateBtn)
    donateMenu:setPosition(ccp(160,70+self.adaH/2))
    donateMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(donateMenu,1)
    self.donateBtn=donateBtn
    if bagCount<=0 then
        donateBtn:setEnabled(false)
    end
    local function rechargeCallBack()
        vipVoApi:showRechargeDialog(self.layerNum+1)
    end
    local rechargeBtn = GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",rechargeCallBack,nil,getlocal("recharge"),30)
    -- rechargeBtn:setScale(0.9)
    local rechargeMenu=CCMenu:createWithItem(rechargeBtn)
    rechargeMenu:setPosition(ccp(480,70+self.adaH/2))
    rechargeMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(rechargeMenu,1)
end

function acRechargeBagTab1:doUserHandler()
end

function acRechargeBagTab1:eventHandler( handler,fn,idx,cel )
    if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then
        return  CCSizeMake(G_VisibleSizeWidth-20,self.tvHeight)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local height = self.height
        local totalW = G_VisibleSizeWidth-20
        local totalH = self.tvHeight
        local spaceH = (self.tvHeight-self.numberCell*self.height)/2

        for i=1,self.numberCell do
            local spWidth=210
            local posY=self.height/2+(i-1)*height+spaceH
            local state=acRechargeBagVoApi:getStateByRechargeLv(i)
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
                            self.tv:reloadData()
                            self:refresh()
                        end
                        acRechargeBagVoApi:rechargeBagRequest("reward",tag,callBack)
                    end               
                end
                local getBtn = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",receiveHandler,i,getlocal("daily_scene_get"),30)
                getBtn:setScale(0.7)
                local btnMenu=CCMenu:createWithItem(getBtn)
                btnMenu:setPosition(ccp(520,posY))
                btnMenu:setTouchPriority(-(self.layerNum-1)*20-4)
                cell:addChild(btnMenu,1)
            else
                -- local lbBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),function ( ... )end)
                -- lbBg:setContentSize(CCSizeMake(300,50))
                -- lbBg:setPosition(300,posY)
                -- lbBg:setOpacity(200)
                -- cell:addChild(lbBg,3)
                -- local hasRewardLb = GetTTFLabelWrap(getlocal("activity_hadReward"),25,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                -- hasRewardLb:setPosition(ccp(lbBg:getContentSize().width/2,lbBg:getContentSize().height/2))
                -- hasRewardLb:setColor(G_ColorGray)
                -- lbBg:addChild(hasRewardLb)

                local rightIcon=CCSprite:createWithSpriteFrameName("IconCheck.png")
                rightIcon:setAnchorPoint(ccp(0.5,0.5))
                rightIcon:setPosition(ccp(520,posY))
                cell:addChild(rightIcon,1)
            end
            
            -- 刻度线
            local keduSp = CCSprite:createWithSpriteFrameName("acChunjiepansheng_fengexian.png")
            keduSp:setPosition(60,i*self.height+spaceH)
            cell:addChild(keduSp,3)

            --充值等级
            local numBgSp = CCSprite:createWithSpriteFrameName("recharge_numlabel.png")
            numBgSp:setAnchorPoint(ccp(0,1))
            numBgSp:setPosition(70,i*self.height+8+spaceH)
            cell:addChild(numBgSp,3)
            -- numBgSp:setPosition(53,self.numberCell*self.height*per+addH)

            local numLb=GetTTFLabel(self.rechargeLvCfg[i],22)
            numLb:setPosition(numBgSp:getContentSize().width/2+5,numBgSp:getContentSize().height/2)
            numBgSp:addChild(numLb)
                    
            local lineSprite = CCSprite:createWithSpriteFrameName("acChunjiepansheng_orangeLine.png")
            lineSprite:setScaleX((totalW + 30)/lineSprite:getContentSize().width)
            lineSprite:setPosition(ccp((totalW + 30)/2 + 30,0+(i-1)*height+spaceH))
            cell:addChild(lineSprite)

            local rewards=acRechargeBagVoApi:getBagByRechargeLv(i)
            if rewards then
                rewards=FormatItem(rewards)
                for k,v in pairs(rewards) do
                    local icon,scale=G_getItemIcon(v,80,true,self.layerNum)
                    if icon and scale then
                        icon:setTouchPriority(-(self.layerNum-1)*20-3)
                        cell:addChild(icon,2)
                        icon:setPosition(200+(k-1)*90, posY)

                        local numLabel=GetTTFLabel("x"..v.num,21)
                        numLabel:setAnchorPoint(ccp(1,0))
                        numLabel:setPosition(icon:getContentSize().width-5, 5)
                        numLabel:setScale(1/scale)
                        icon:addChild(numLabel,1)
                    end 
                end
            end
        end

        local barWidth=self.numberCell*self.height
        local barBgH=totalH
        local function click(hd,fn,idx)
        end

        local barSprie = LuaCCScale9Sprite:createWithSpriteFrameName("acChunjiepansheng_progressBg.png", CCRect(42,42,2,2),click)
        barSprie:setContentSize(CCSizeMake(86,barBgH-10))
        barSprie:setPosition(ccp(60,barBgH/2))
        cell:addChild(barSprie,1)

        AddProgramTimer(cell,ccp(60,barWidth/2+spaceH),11,12,nil,"acChunjiepansheng_progress2.png","acChunjiepansheng_progress1.png",13,1,1,nil,ccp(0,1))
        local per=acRechargeBagVoApi:getRechargePercent()
        local timerSpriteLv=cell:getChildByTag(11)
        timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
        timerSpriteLv:setPercentage(per)
        timerSpriteLv:setScaleY((barWidth)/timerSpriteLv:getContentSize().height)
        timerSpriteLv:setRotation(180)
        local bg = cell:getChildByTag(13)
        bg:setScaleY((barWidth)/bg:getContentSize().height)

        local moneyNode=CCNode:create()
        moneyNode:setAnchorPoint(ccp(0.5,0))
        cell:addChild(moneyNode)
        local goldIconSp=CCSprite:createWithSpriteFrameName("IconGold.png")
        goldIconSp:setAnchorPoint(ccp(0,0.5))
        moneyNode:addChild(goldIconSp)
        local rechargeLabel = GetTTFLabel(getlocal("activity_baifudali_totalMoney"),25)
        rechargeLabel:setAnchorPoint(ccp(0,0.5))
        moneyNode:addChild(rechargeLabel)
        local totalMoney=acRechargeBagVoApi:getRechargeCount()
        local moneyLabel=GetTTFLabel(tostring(totalMoney),25)
        moneyLabel:setAnchorPoint(ccp(0,0.5))
        moneyLabel:setColor(G_ColorYellowPro)
        moneyNode:addChild(moneyLabel)
        local mwidth=rechargeLabel:getContentSize().width+moneyLabel:getContentSize().width+goldIconSp:getContentSize().width
        local mheight=rechargeLabel:getContentSize().height
        moneyNode:setContentSize(CCSizeMake(mwidth,mheight))
        moneyNode:setPosition(ccp(totalW/2,totalH-mheight))
        rechargeLabel:setPosition(ccp(0,mheight/2))
        goldIconSp:setPosition(ccp(rechargeLabel:getContentSize().width,mheight/2))
        moneyLabel:setPosition(ccp(goldIconSp:getPositionX()+goldIconSp:getContentSize().width,mheight/2))

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
    end
end

function acRechargeBagTab1:openInfo()
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
    local ruleStr1=getlocal("activity_rechargebag_rule1")
    local ruleStr2=getlocal("activity_rechargebag_rule2",{acRechargeBagVoApi:getNeedRecharge()})
    local ruleStr3=getlocal("activity_rechargebag_rule3")
    local ruleStr4=getlocal("activity_rechargebag_rule4",{acRechargeBagVoApi:getPoint()})
    local ruleStr5=getlocal("activity_rechargebag_rule5",{getlocal("activity_rechargebag_rule6",{acRechargeBagVoApi:getNeedPoint()})})

    strTab={" ",ruleStr5,ruleStr4,ruleStr3,ruleStr2,ruleStr1," ",ruleStr," "}
    colorTab={nil,nil,nil,nil,nil,nil,nil,G_ColorYellowPro,nil}
    tabAlignment={nil,nil,nil,nil,nil,nil,nil,kCCTextAlignmentCenter,nil}

    local dialogLayer=sd:init("TankInforPanel.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,strTab,25,colorTab,nil,nil,nil,tabAlignment)
    sceneGame:addChild(dialogLayer,self.layerNum+1)
    dialogLayer:setPosition(ccp(0,0))   
end

function acRechargeBagTab1:refresh()
    if self and self.totalLb and self.extraLb and self.donateBtn and self.receiveBtn then
        local limit=acRechargeBagVoApi:getRechargeLimit()
        local chargeCount=acRechargeBagVoApi:getRechargeCount()
        local pic,bagCount=acRechargeBagVoApi:getDonateBag()
        local pid,icon,scale,extraCount=acRechargeBagVoApi:getExtraBag()
        self.totalLb:setString("x"..bagCount)
        self.extraLb:setString("x"..extraCount)
        if bagCount>0 then
            self.donateBtn:setEnabled(true)
        else
            self.donateBtn:setEnabled(false)
        end
        if tonumber(chargeCount)>=tonumber(limit) then
            self.receiveBtn:setVisible(true)
            if extraCount>0 then
                self.receiveBtn:setEnabled(true)
            else
                self.receiveBtn:setEnabled(false)
            end

            if self.extraW~=360 then
                self.extraW=360
                if self.desTv then
                    self.desTv:removeFromParentAndCleanup(true)
                    self.desTv=nil
                end
                local desStr = getlocal("activity_rechargebag_des2",{acRechargeBagVoApi:getRechargeLimit(),acRechargeBagVoApi:getNeedRecharge()})
                local desTv, desLabel= G_LabelTableView(CCSizeMake(self.extraW,self.tv:getPositionY()-148),desStr,25,kCCTextAlignmentLeft)
                desTv:setPosition(ccp(120,148+self.adaH))
                self.bgLayer:addChild(desTv,1)
                desTv:setAnchorPoint(ccp(0,0))
                desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
                desTv:setMaxDisToBottomOrTop(self.slidH)
                self.desTv=desTv
            end
            if self.extraGemsLb then
                local extraGems=acRechargeBagVoApi:getExtraCharge()
                local needGems=acRechargeBagVoApi:getNeedRecharge()
                self.extraGemsLb:setString(tostring(extraGems))
                if tonumber(extraGems)<tonumber(needGems) then
                    self.extraGemsLb:setColor(G_ColorRed)
                else
                    self.extraGemsLb:setColor(G_ColorWhite)
                end
            end
            self.extraLb:setVisible(true)
        else
            if self.receiveBtn:isVisible()==true then
                if self.extraW~=self.bgLayer:getContentSize().width*0.7 then
                    self.extraW=self.bgLayer:getContentSize().width*0.7
                    if self.desTv then
                        self.desTv:removeFromParentAndCleanup(true)
                        self.desTv=nil
                    end
                    local desStr = getlocal("activity_rechargebag_des2",{acRechargeBagVoApi:getRechargeLimit(),acRechargeBagVoApi:getNeedRecharge()})
                    local desTv, desLabel= G_LabelTableView(CCSizeMake(self.extraW,self.tv:getPositionY()-148),desStr,25,kCCTextAlignmentLeft)
                    desTv:setPosition(ccp(120,148+self.adaH))
                    self.bgLayer:addChild(desTv,1)
                    desTv:setAnchorPoint(ccp(0,0))
                    desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
                    desTv:setMaxDisToBottomOrTop(self.slidH)
                    self.desTv=desTv
                end
                self.receiveBtn:setVisible(false)
                self.extraLb:setVisible(false)
            end      
        end
        --重新调整充值金币的坐标
        if self.needGemsLb and self.extraGemsLb and self.gemsNode and self.gemsSp then
            local width=self.needGemsLb:getContentSize().width+self.extraGemsLb:getContentSize().width+self.gemsSp:getContentSize().width
            self.gemsNode:setContentSize(CCSizeMake(width,self.needGemsLb:getContentSize().height))
            self.gemsSp:setPosition(ccp(0+self.adaH/10,self.gemsNode:getContentSize().height/2))
            self.extraGemsLb:setPosition(ccp(self.gemsSp:getContentSize().width+self.adaH/10,self.gemsNode:getContentSize().height/2))
            self.needGemsLb:setPosition(ccp(self.extraGemsLb:getPositionX()+self.extraGemsLb:getContentSize().width,self.gemsNode:getContentSize().height/2))
        end
    end
end

function acRechargeBagTab1:tick()
    local isEnd=acRechargeBagVoApi:isEnd()
    if isEnd==false then
        if acRechargeBagVoApi:getFlag(1)==0 then
            self:updateUI()
            acRechargeBagVoApi:setFlag(1,1)
        end
    end
end

function acRechargeBagTab1:updateUI()
    if self then
        self:refresh()
        if self.tv then
            self.tv:reloadData()
        end
    end
end

function acRechargeBagTab1:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.layerNum=nil
    self.parent=nil
    self.height=90
    self.rechargeLvCfg={}
    self.numberCell=0
    self.tvHeight=380
    self.desHeight=120
    self.extraW=400
    self.extraLb=nil
    self.totalLb=nil
    self.donateBtn=nil
    self.receiveBtn=nil
    self.desTv=nil
    self.extraGemsLb=nil
    self.needGemsLb=nil
    self.gemsNode=nil
    self.gemsSp=nil
end