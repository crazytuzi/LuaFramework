acChristmasFightTab1={}

function acChristmasFightTab1:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.bgLayer=nil
    self.layerNum=nil
    self.selectedTabIndex=nil
    self.cPointLb=nil
    self.lotteryBtn=nil
    self.tenLotteryBtn=nil
    self.status=0
    self.iconTab={}
    self.maskSp=nil
    self.showIndex1=1
    self.showIndex2=1001
    self.showTab={}
    self.snowStatus=0
    self.barNum=0
    self.expireTime=0
    self.queIconTab={}
    self.scaleY=1

    return nc
end

function acChristmasFightTab1:init(layerNum,selectedTabIndex,parentDialog)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.selectedTabIndex=selectedTabIndex
    self.parentDialog=parentDialog
    -- self.tvWidth=G_VisibleSizeWidth - 40
    -- local acVo=acChristmasFightVoApi:getAcVo()
    -- if acVo and acVo.cost then
        self:initLayer()
        self:initHeader()
        self:initContent()

        self:tick()
        self:refresh()
    -- end
    return self.bgLayer
end

function acChristmasFightTab1:initLayer()
    local status,point,time=acChristmasFightVoApi:getSnowmanData()
    self.snowStatus=status
    self.barNum=point
    self.expireTime=base.serverTime+60
    local bgStr
    if acChristmasFightVoApi:getAcShowType()==acChristmasFightVoApi.acShowType.TYPE_2 then
        self.acBg=CCNode:create()
        self.acBg:setContentSize(CCSizeMake(612,786))
        local function onLoadIcon(fn,bgSprite)
            if self and self.acBg and tolua.cast(self.acBg,"CCNode") then
                bgSprite:setAnchorPoint(ccp(0.5,0.5))
                bgSprite:setPosition(self.acBg:getContentSize().width/2,self.acBg:getContentSize().height/2)
                self.acBg:addChild(bgSprite)
            end
        end
        if status==1 then
            LuaCCWebImage:createWithURL(G_downloadUrl("active/demonBg_v2.jpg"),onLoadIcon)
        else
            LuaCCWebImage:createWithURL(G_downloadUrl("active/angelBg_v2.jpg"),onLoadIcon)
        end
    else
        if G_curPlatName()=="21" or G_curPlatName()=="androidarab" or G_curPlatName()=="0" then
            bgStr="arImage/"
        else
            bgStr="public/"
        end
        if status==1 then
            bgStr=bgStr.."demonBg.jpg"
        else
            bgStr=bgStr.."angelBg.jpg"
        end
        self.acBg=CCSprite:create(bgStr)
    end
    self.acBg:setAnchorPoint(ccp(0.5,1))
    self.acBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-160))
    self.bgLayer:addChild(self.acBg)
    self.acBg:setScaleX(590/self.acBg:getContentSize().width)
    self.scaleY=(self.bgLayer:getContentSize().height-200)/self.acBg:getContentSize().height
    self.acBg:setScaleY(self.scaleY)
    self.status=status
    if self.scaleY<1 then
        self.scaleY=1
    end

    local acVo=acChristmasFightVoApi:getAcVo()
    local function touch(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local param={FormatNumber(acVo.addRes),1,FormatNumber(acVo.addBp),1}
        local strTab={" ",getlocal("activity_christmasfight_tip1",param)," "}
        smallDialog:showTableViewSure("TankInforPanel.png",CCSizeMake(550,800),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("shuoming"),getlocal("activity_christmasfight_tip1",param),true,self.layerNum+1,nil)
    end
    local w = nil
    local h = G_VisibleSizeHeight - 170
    local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),25)
    acLabel:setAnchorPoint(ccp(0.5,1))
    acLabel:setPosition(ccp(G_VisibleSizeWidth/2, h))
    acLabel:setColor(G_ColorGreen)
    self.bgLayer:addChild(acLabel,1)

    w = G_VisibleSizeWidth - 60
    h = h - 30*self.scaleY
    local menuItemDesc
    if acChristmasFightVoApi:getAcShowType()==acChristmasFightVoApi.acShowType.TYPE_2 then
        menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touch,1,nil,0)
    else
        menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,1,nil,0)
    end
    menuItemDesc:setAnchorPoint(ccp(0.5,0.5))
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
    menuDesc:setPosition(ccp(w, h))
    self.bgLayer:addChild(menuDesc,2)

    h = h - 20*self.scaleY
    local timeStr=acChristmasFightVoApi:getTimeStr()
    local timeLabel=GetTTFLabel(timeStr,28)
    timeLabel:setAnchorPoint(ccp(0.5,0.5))
    timeLabel:setPosition(ccp(G_VisibleSizeWidth/2+20, h))
    self.bgLayer:addChild(timeLabel,3)
    self.timeLb=timeLabel
    self:updateAcTime()


    h = h - 40*self.scaleY
    -- local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),function ()end)
    -- backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-70, 50))
    -- backSprie:ignoreAnchorPointForPosition(false)
    -- backSprie:setAnchorPoint(ccp(0.5,0.5))
    -- backSprie:setIsSallow(false)
    -- backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
    -- backSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2,h))
    -- self.bgLayer:addChild(backSprie)
    local backSprie=CCSprite:createWithSpriteFrameName("orangeMask.png")
    backSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2,h))
    self.bgLayer:addChild(backSprie)

    self.cPointLb=GetTTFLabel(getlocal("allianceShop_myDonate")..acVo.cPoint,25)
    self.cPointLb:setAnchorPoint(ccp(0.5,0.5))
    self.cPointLb:setPosition(getCenterPoint(backSprie))
    backSprie:addChild(self.cPointLb,1)
    self.cPointLb:setColor(G_ColorYellowPro)
    -- local pIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
    -- pIcon:setPosition(ccp(60+self.cPointLb:getContentSize().width+30,lby))
    -- backSprie:addChild(pIcon,1)
    
    if acChristmasFightVoApi:getAcShowType()==acChristmasFightVoApi.acShowType.TYPE_2 then
    else
        local dscSp=CCSprite:createWithSpriteFrameName("bellPic.png")
        dscSp:setPosition(ccp(w,h))
        self.bgLayer:addChild(dscSp,5)
    end
end

function acChristmasFightTab1:initHeader()
    local rect = CCRect(0, 0, 50, 50)
    local capInSet = CCRect(20, 20, 10, 10)
    local function onClick(hd,fn,idx)
    end
    local heady=self.bgLayer:getContentSize().height-280*self.scaleY
    local headSp =LuaCCScale9Sprite:createWithSpriteFrameName("acHeadBg.png",capInSet,onClick)
    headSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, 200))
    headSp:ignoreAnchorPointForPosition(false)
    headSp:setAnchorPoint(ccp(0.5,1))
    headSp:setIsSallow(false)
    headSp:setTouchPriority(-(self.layerNum-1)*20-1)
    headSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,heady))
    self.bgLayer:addChild(headSp,1)

    -- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    local acVo=acChristmasFightVoApi:getAcVo()
    local bgWidth=headSp:getContentSize().width
    local bgHeight=headSp:getContentSize().height
    local descLb=GetTTFLabelWrap(getlocal("activity_christmasfight_desc"),25,CCSizeMake(bgWidth-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    -- local descLb=GetTTFLabelWrap(str,25,CCSizeMake(bgWidth-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    descLb:setPosition(ccp(bgWidth/2,bgHeight-35))
    headSp:addChild(descLb,1)
    -- descLb:setColor(G_ColorYellowPro)
    
    local spaceW=200
    local iconSize=100
    for i=1,3 do
        if acVo and acVo.pointRewardCfg and acVo.pointRewardCfg[i] then
            local cfg=acVo.pointRewardCfg[i]
            if cfg.p and cfg.reward and SizeOfTable(cfg.reward)>0 then
                local point=cfg.p or 0
                local rewardTb=FormatItem(cfg.reward,nil,true)
                local px,py=90+spaceW*(i-1),bgHeight/2-15
                if rewardTb and rewardTb[1] then
                    local item=rewardTb[1]
                    local function onClick()
                        local statusTab=acChristmasFightVoApi:getCRewardStatus()
                        local cStatus1=statusTab[i]
                        if cStatus1==1 then
                            local function callback(sData)
                                self:tick()
                                self:refresh()
                                if sData and sData.data and sData.data.reward then
                                    local award=FormatItem(sData.data.reward) or {}
                                    G_showRewardTip(award, true)
                                end
                            end
                            acChristmasFightVoApi:updateActiveData("devote",i,callback)
                            return false
                        else
                            return true
                        end
                    end
                    local icon=G_getItemIcon(item,iconSize,true,self.layerNum,onClick)
                    icon:setPosition(ccp(px,py))
                    icon:setTouchPriority(-(self.layerNum-1)*20-4)
                    headSp:addChild(icon,1)
                    local statusTab=acChristmasFightVoApi:getCRewardStatus()
                    local cStatus=statusTab[i]
                    -- print("cStatus",cStatus)
                    if cStatus==2 then
                        local function touchLuaSpr()
                        end
                        local maskSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr)
                        maskSp:setTouchPriority(-(self.layerNum-1)*20-1)
                        local rect=CCSizeMake(iconSize,iconSize)
                        maskSp:setContentSize(rect)
                        maskSp:setOpacity(180)
                        maskSp:setPosition(getCenterPoint(icon))
                        maskSp:setTag(101)
                        icon:addChild(maskSp)
                        hadRewardLb= GetTTFLabelWrap(getlocal("activity_hadReward"),25,CCSizeMake(iconSize,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                        hadRewardLb:setPosition(getCenterPoint(maskSp))
                        maskSp:addChild(hadRewardLb)
                        hadRewardLb:setColor(G_ColorYellow)
                    elseif cStatus==1 then
                        G_addRectFlicker(icon,1.4,1.4)
                    end
                    self.iconTab[i]=icon
                end
                local pointLb=GetTTFLabel(point,25)
                pointLb:setPosition(ccp(px-15,20))
                headSp:addChild(pointLb,1)
                local pIcon=CCSprite:createWithSpriteFrameName("contribution.png")
                pIcon:setPosition(ccp(px+25,20))
                headSp:addChild(pIcon,1)
                pIcon:setScale(0.5)
            end
        end
    end
end
function acChristmasFightTab1:initContent()
    local bgWidth=self.bgLayer:getContentSize().width
    local bgHeight=self.bgLayer:getContentSize().height

    local lbBg=CCSprite:createWithSpriteFrameName("acLabelbg.png")
    lbBg:setAnchorPoint(ccp(0,0.5))
    lbBg:setPosition(ccp(35,bgHeight-540*self.scaleY))
    self.bgLayer:addChild(lbBg,1)
    lbBg:setScaleX(580/lbBg:getContentSize().width)
    lbBg:setScaleY(120/lbBg:getContentSize().height)

    local acVo=acChristmasFightVoApi:getAcVo()
    local status,point,time=acChristmasFightVoApi:getSnowmanData()
    local cpy=bgHeight-515*self.scaleY
    local lbWidth=bgWidth-80
    -- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    local lbTb={
        {getlocal("activity_christmasfight_add_desc1",{(acVo.bpIncrease*100)}),25,ccp(0,0.5),ccp(60,cpy),self.bgLayer,1,G_ColorWhite,CCSize(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
        {getlocal("activity_christmasfight_add_desc2",{(acVo.resIncrease*100)}),25,ccp(0,0.5),ccp(60,cpy-50),self.bgLayer,1,G_ColorWhite,CCSize(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
        -- {str,25,ccp(0,0.5),ccp(60,cpy),self.bgLayer,1,G_ColorYellowPro,CCSize(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
        -- {str,25,ccp(0,0.5),ccp(60,cpy-50),self.bgLayer,1,G_ColorYellowPro,CCSize(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
    }
    for k,v in pairs(lbTb) do
        GetAllTTFLabel(v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10],v[11])
    end

    cpy=cpy-185*self.scaleY
    local snowScale=0.7
    -- local bigRewardCfg=acVo.bigRewardCfg
    local angelPoolCfg={}
    local demonPoolCfg={}
    if acVo.poolCfg and acVo.poolCfg.angel then
        angelPoolCfg=FormatItem(acVo.poolCfg.angel,nil,true) or {}
    end
    if acVo.poolCfg and acVo.poolCfg.demon then
        demonPoolCfg=FormatItem(acVo.poolCfg.demon,nil,true) or {}
    end
    local function onClick( ... )
    end
    self.iconBg=LuaCCSprite:createWithSpriteFrameName("blueBgIcon.png",onClick)
    local function initIcon(showType)
        local awardTb={}
        if showType==0 then
            awardTb=angelPoolCfg
        else
            awardTb=demonPoolCfg
        end
        for k,v in pairs(awardTb) do
            if v and SizeOfTable(v)>0 then
                local item=v
                local function onClick()
                    local rewardTb={}
                    local status,point,time=acChristmasFightVoApi:getSnowmanData()
                    if status==0 then
                        rewardTb=angelPoolCfg
                    else
                        rewardTb=demonPoolCfg
                    end
                    -- print("SizeOfTable(rewardTb)",SizeOfTable(rewardTb))
                    if rewardTb and SizeOfTable(rewardTb)>0 then
                        -- smallDialog:showRewardDialog("TankInforPanel.png",CCSizeMake(500,600),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),true,self.layerNum+1,{getlocal("activity_equipSearch_reward_include")},25,rewardTb) 
                        local titleStr=getlocal("activity_christmasfight_angel_title")
                        if status==1 then
                            titleStr=getlocal("activity_christmasfight_demon_title")
                        end
                        smallDialog:showTableViewRewardSure("TankInforPanel.png",CCSizeMake(500,600),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),titleStr,rewardTb,true,self.layerNum+1)
                    end
                    return false
                end
                local icon=G_getItemIcon(item,100,true,self.layerNum,onClick)
                icon:setTouchPriority(-(self.layerNum-1)*20-4)
                local status,point,time=acChristmasFightVoApi:getSnowmanData()
                local index=(k+showType*1000)
                if (status==0 and self.showIndex1==index) or (status==1 and self.showIndex2==index) then
                    icon:setPosition(getCenterPoint(self.iconBg))
                else
                    icon:setPosition(ccp(100000,0))
                end
                -- print("index",index)
                icon:setTag(index)
                self.iconBg:addChild(icon)
            end
        end
    end
    for i=1,2 do
        initIcon(i-1)
    end
    self.iconBg:setPosition(ccp(bgWidth/2-15,cpy))
    self.iconBg:setTouchPriority(-(self.layerNum-1)*20-1)
    self.bgLayer:addChild(self.iconBg,1)
    local snowSp=CCSprite:createWithSpriteFrameName("snowBg_2.png")
    snowSp:setPosition(ccp(self.iconBg:getContentSize().width/2,self.iconBg:getContentSize().height-15))
    self.iconBg:addChild(snowSp,1)
    snowSp:setScale(snowScale)
    snowSp:setFlipX(true)
    local function onChangeShow()
        local rNum=0
        local status,point,time=acChristmasFightVoApi:getSnowmanData()
        if status==0 then
            rNum=SizeOfTable(angelPoolCfg)
            self.showIndex1=self.showIndex1+1
            if self.showIndex1>rNum then
                self.showIndex1=1
            end
        else
            rNum=SizeOfTable(demonPoolCfg)
            self.showIndex2=self.showIndex2+1
            if self.showIndex2>rNum+1000 then
                self.showIndex2=1001
            end
        end
        -- print("self.showIndex1",self.showIndex1)
        -- print("self.showIndex2",self.showIndex2)
        for i=1,2 do
            local num=0
            if i==1 then
                num=SizeOfTable(angelPoolCfg)
            else
                num=SizeOfTable(demonPoolCfg)
            end
            for k=1,num do
                local index=k+1000*(i-1)
                local icon=tolua.cast(self.iconBg:getChildByTag(index),"LuaCCSprite")
                if icon then
                    if (status==0 and self.showIndex1==index) or (status==1 and self.showIndex2==index) then                    
                        icon:setPosition(getCenterPoint(self.iconBg))
                    else
                        icon:setPosition(ccp(100000,0))
                    end
                end
            end
        end
    end
    if acChristmasFightVoApi:acIsStop()==false then
        local delay=CCDelayTime:create(1)
        local callFunc=CCCallFunc:create(onChangeShow)
        local acArr=CCArray:create()
        acArr:addObject(delay)
        acArr:addObject(callFunc)
        local seq=CCSequence:create(acArr)
        self.iconBg:runAction(CCRepeatForever:create(seq))
    end

    cpy=cpy-80*self.scaleY
    local snowSp1=CCSprite:createWithSpriteFrameName("snowBg_2.png")
    snowSp1:setPosition(ccp(155,cpy+8))
    self.bgLayer:addChild(snowSp1,1)
    snowSp1:setFlipX(true)
    snowSp1:setScale(snowScale)
    local snowSp2=CCSprite:createWithSpriteFrameName("snowBg_1.png")
    snowSp2:setPosition(ccp(268,cpy+20))
    self.bgLayer:addChild(snowSp2,1)
    snowSp2:setScale(0.5)
    local snowSp3=CCSprite:createWithSpriteFrameName("snowBg_1.png")
    snowSp3:setPosition(ccp(bgWidth-268,cpy+20))
    self.bgLayer:addChild(snowSp3,1)
    snowSp3:setScale(0.5)
    local snowSp4=CCSprite:createWithSpriteFrameName("snowBg_2.png")
    snowSp4:setPosition(ccp(bgWidth-155,cpy+8))
    self.bgLayer:addChild(snowSp4,1)
    snowSp4:setScale(snowScale)
    local maxPoint=acVo.maxPoint
    local perStr=point.."/"..maxPoint
    if status==1 then
        AddProgramTimer(self.bgLayer,ccp(bgWidth/2,cpy),11,12,nil,"platWarProgressBg.png","platWarProgress1.png",13,1,1)
    else
        AddProgramTimer(self.bgLayer,ccp(bgWidth/2,cpy),11,12,nil,"platWarProgressBg.png","platWarProgress2.png",13,1,1)
    end
    local per = point/maxPoint*100
    local timerSpriteLv = self.bgLayer:getChildByTag(11)
    timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
    timerSpriteLv:setPercentage(per)
    -- timerSpriteLv:setRotation(-90)
    -- timerSpriteLv:setScaleX(barWidth/timerSpriteLv:getContentSize().width)
    local bg = self.bgLayer:getChildByTag(13)
    -- local lb=timerSpriteLv:getChildByTag(12)
    -- lb=tolua.cast(lb,"CCLabelTTF")
    local num=SizeOfTable(acVo.bigRewardCfg)
    for k,v in pairs(acVo.bigRewardCfg) do
        if v and v.p and v.r then
            local bPoint=v.p
            local rTb=FormatItem(v.r,nil,true) or {}
            if rTb and rTb[1] then
                local item=rTb[1]
                -- local px,py=bgWidth/2-bg:getContentSize().width/2+bg:getContentSize().width/(num+1)*k,cpy
                local px,py=bgWidth/2-bg:getContentSize().width/2+bPoint/maxPoint*bg:getContentSize().width,cpy
                local function showReward()
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)

                    local status2,point2,time2=acChristmasFightVoApi:getSnowmanData()
                    if status2==1 then
                        local touchDialogBg=self:setTouchLayer(true)
                        local icon=G_getItemIcon(item,100,true,self.layerNum)
                        icon:setPosition(ccp(px,py+80))
                        icon:setTouchPriority(-(self.layerNum-1)*20-10)
                        icon:setIsSallow(true)
                        touchDialogBg:addChild(icon)
                    end
                end
                -- local qIcon=LuaCCSprite:createWithSpriteFrameName("questionIcon.png",showReward)
                local qIcon=CCSprite:createWithSpriteFrameName("questionIcon.png")
                qIcon:setPosition(ccp(px,py))
                -- qIcon:setTouchPriority(-(self.layerNum-1)*20-4)
                self.bgLayer:addChild(qIcon,5)
                table.insert(self.queIconTab,qIcon)
                if status==1 then
                else
                    qIcon:setVisible(false)
                end
                local qIconBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),showReward)
                qIconBg:setTouchPriority(-(self.layerNum-1)*20-4)
                local rect=CCSizeMake(50,50)
                qIconBg:setContentSize(rect)
                qIconBg:setOpacity(255)
                qIconBg:setPosition(ccp(px,py))
                self.bgLayer:addChild(qIconBg)
                qIconBg:setOpacity(0)
            end
        end
    end
    cpy=cpy-27*self.scaleY
    local lbg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),function ()end)
    lbg:setContentSize(CCSizeMake(150, 30))
    lbg:ignoreAnchorPointForPosition(false)
    lbg:setAnchorPoint(ccp(0.5,0.5))
    lbg:setIsSallow(false)
    lbg:setTouchPriority(-(self.layerNum-1)*20-1)
    lbg:setPosition(ccp(bgWidth/2,cpy))
    self.bgLayer:addChild(lbg,1)
    self.barLb=GetTTFLabel(perStr,25)
    self.barLb:setPosition(getCenterPoint(lbg))
    lbg:addChild(self.barLb,1)


    local btnHeight=70*self.scaleY
    local clbHeight=125*self.scaleY
    local function onLottery()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local acVo=acChristmasFightVoApi:getAcVo()
        local isFree=acChristmasFightVoApi:isFree()
        local function callback(sData)
            self:tick()
            self:refresh()
            if sData and sData.data and sData.data.report then
                local report=sData.data.report
                self:showAnimation(report)
            end
        end
        if isFree==true then
            acChristmasFightVoApi:updateActiveData("rand",1,callback)
        else
            local costGem=acVo.cost
            if(costGem>playerVoApi:getGems())then
                GemsNotEnoughDialog(nil,nil,costGem - playerVoApi:getGems(),self.layerNum+1,costGem)
                do return end
            end
            acChristmasFightVoApi:updateActiveData("rand",2,callback)
        end
    end
    if acChristmasFightVoApi:getAcShowType()==acChristmasFightVoApi.acShowType.TYPE_2 then
        self.lotteryBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onLottery,nil,getlocal("activity_wheelFortune_subTitle_1"),24/0.8)
        self.lotteryBtn:setScale(0.8)
    else
        self.lotteryBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onLottery,nil,getlocal("activity_wheelFortune_subTitle_1"),25)
    end
    local lotteryMenu=CCMenu:createWithItem(self.lotteryBtn)
    lotteryMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    lotteryMenu:setAnchorPoint(ccp(0.5,0.5))
    lotteryMenu:setPosition(ccp(180,btnHeight))
    self.bgLayer:addChild(lotteryMenu,1)
    self.goldSp=CCSprite:createWithSpriteFrameName("IconGold.png")
    self.goldSp:setPosition(ccp(180-35,clbHeight))
    self.bgLayer:addChild(self.goldSp,2)
    self.goldSp:setScale(1.5)
    -- self.lbBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),function ()end)
    -- self.lbBg:setContentSize(CCSizeMake(100, 30))
    -- self.lbBg:setIsSallow(false)
    -- self.lbBg:setTouchPriority(-(self.layerNum-1)*20-1)
    self.lbBg=CCSprite:createWithSpriteFrameName("acLabelbg.png")
    self.lbBg:setAnchorPoint(ccp(0,0.5))
    self.lbBg:setPosition(ccp(180-35,clbHeight))
    self.bgLayer:addChild(self.lbBg,1)
    self.lbBg:setScaleX(1.5)
    self.lbBg:setScaleY(1.2)
    self.costLb=GetTTFLabel(acVo.cost,25)
    self.costLb:setAnchorPoint(ccp(0,0.5))
    self.costLb:setPosition(ccp(180+5,clbHeight))
    self.bgLayer:addChild(self.costLb,1)
    self.freeLb=GetTTFLabelWrap(getlocal("daily_lotto_tip_2"),25,CCSizeMake(300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.freeLb:setAnchorPoint(ccp(0.5,0.5))
    self.freeLb:setPosition(ccp(180,clbHeight))
    self.bgLayer:addChild(self.freeLb,1)
    self.freeLb:setVisible(false)

    local function onTenLottery()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local acVo=acChristmasFightVoApi:getAcVo()
        local isFree=acChristmasFightVoApi:isFree()
        local function callback(sData)
            self:tick()
            self:refresh()
            if sData and sData.data and sData.data.report then
                local report=sData.data.report
                if report and SizeOfTable(report)>0 then
                    local content={}
                    for k,v in pairs(report) do
                        if v and v[1] then
                            local reward=FormatItem(v[1]) or {}
                            for m,n in pairs(reward) do
                                -- table.insert(content,{award=n,})
                                table.insert(content,{icon=n.pic,msg = n.name.."x"..n.num, addFlicker = false,item=n})
                            end
                        end
                    end
                    smallDialog:showSearchDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_tankjianianhua_awardContent"),content,nil,true,self.layerNum+1,nil,true,true)
                end
            end
        end
        if isFree==true then
        else
            local costGem=acVo.tenCost
            if(costGem>playerVoApi:getGems())then
                GemsNotEnoughDialog(nil,nil,costGem - playerVoApi:getGems(),self.layerNum+1,costGem)
                do return end
            end
            acChristmasFightVoApi:updateActiveData("rand",3,callback)
        end
    end
    if acChristmasFightVoApi:getAcShowType()==acChristmasFightVoApi.acShowType.TYPE_2 then
        self.tenLotteryBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",onTenLottery,nil,getlocal("ten_roulette_btn"),24/0.8)
        self.tenLotteryBtn:setScale(0.8)
    else
        self.tenLotteryBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",onTenLottery,nil,getlocal("ten_roulette_btn"),25)
    end
    local tenLotteryMenu=CCMenu:createWithItem(self.tenLotteryBtn)
    tenLotteryMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    tenLotteryMenu:setAnchorPoint(ccp(0.5,0.5))
    tenLotteryMenu:setPosition(ccp(bgWidth-180,btnHeight))
    self.bgLayer:addChild(tenLotteryMenu,1)
    local goldSp2=CCSprite:createWithSpriteFrameName("IconGold.png")
    goldSp2:setPosition(ccp(bgWidth-180-35,clbHeight))
    self.bgLayer:addChild(goldSp2,2)
    goldSp2:setScale(1.5)
    -- local lbBg2=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),function ()end)
    -- lbBg2:setContentSize(CCSizeMake(100, 30))
    -- lbBg2:setIsSallow(false)
    -- lbBg2:setTouchPriority(-(self.layerNum-1)*20-1)
    local lbBg2=CCSprite:createWithSpriteFrameName("acLabelbg.png")
    lbBg2:setAnchorPoint(ccp(0,0.5))
    lbBg2:setPosition(ccp(bgWidth-180-35,clbHeight))
    self.bgLayer:addChild(lbBg2,1)
    lbBg2:setScaleX(1.5)
    lbBg2:setScaleY(1.2)
    local tenCostLb=GetTTFLabel(acVo.tenCost,25)
    tenCostLb:setAnchorPoint(ccp(0,0.5))
    tenCostLb:setPosition(ccp(bgWidth-180+5,clbHeight))
    self.bgLayer:addChild(tenCostLb,1)
end

function acChristmasFightTab1:showAnimation(report)
    if report and report[1] and report[1][1] then
        local award=report[1][1]
        local rewardTb=FormatItem(award)
        local item=rewardTb[1]
        if item then
            local icon=G_getItemIcon(item,100)
            if icon and self.iconBg then
                local touchDialogBg=self:setTouchLayer()
                local px,py=self.iconBg:getPosition()
                local lightSp = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
                lightSp:setAnchorPoint(ccp(0.5,0.5))
                lightSp:setPosition(ccp(px,py))
                touchDialogBg:addChild(lightSp)
                icon:setPosition(getCenterPoint(lightSp))
                lightSp:addChild(icon)

                local function playEndCallback()
                    local function btnCallback( ... )
                        self:cancleTouchLayer()
                    end
                    local confirmBtn=GetButtonItem("BigBtnBlue.png","BigBtnBlue_Down.png","BigBtnBlue_Down.png",btnCallback,4,getlocal("confirm"),25)
                    confirmBtn:setAnchorPoint(ccp(0.5,0.5))
                    local confirmMenu=CCMenu:createWithItem(confirmBtn)
                    confirmMenu:setPosition(ccp(touchDialogBg:getContentSize().width/2,100))
                    confirmMenu:setTouchPriority(-(self.layerNum-1)*20-9)
                    touchDialogBg:addChild(confirmMenu,2)

                    local nameLb=GetTTFLabelWrap(item.name.."x"..item.num,30,CCSizeMake(touchDialogBg:getContentSize().width-100,0),kCCVerticalTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                    nameLb:setPosition(ccp(touchDialogBg:getContentSize().width/2,touchDialogBg:getContentSize().height/2-120))
                    touchDialogBg:addChild(nameLb,2)
                    local desc=getlocal(item.desc)
                    if item.type=="w" and (item.eType=="c" or item.eType=="f") then
                        desc=item.desc
                    end
                    local descLb=GetTTFLabelWrap(desc,30,CCSizeMake(touchDialogBg:getContentSize().width-100,0),kCCVerticalTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                    descLb:setPosition(ccp(touchDialogBg:getContentSize().width/2,touchDialogBg:getContentSize().height/2-230))
                    touchDialogBg:addChild(descLb,2)
                end
                local delay=CCDelayTime:create(0.5)
                local mvTo0=CCMoveTo:create(0.3,getCenterPoint(touchDialogBg))
                local ms=2
                local scaleTo=CCScaleTo:create(0.1,ms)
                
                ms=1.5
                local scaleTo1=CCScaleTo:create(0.2,ms)
                local callFunc=CCCallFuncN:create(playEndCallback)

                local acArr=CCArray:create()
                acArr:addObject(delay)
                acArr:addObject(mvTo0)
                acArr:addObject(scaleTo)
                acArr:addObject(scaleTo1)
                acArr:addObject(callFunc)
                local seq=CCSequence:create(acArr)
                lightSp:runAction(seq)
            end
        end

    end
end

function acChristmasFightTab1:setTouchLayer(isTouch)
    self.touchLayer=CCLayer:create()
    self.touchLayer:setTouchEnabled(true)
    self.touchLayer:setBSwallowsTouches(true)
    self.touchLayer:setTouchPriority(-(self.layerNum-1)*20-8)
    self.touchLayer:setContentSize(G_VisibleSize)
    self.bgLayer:addChild(self.touchLayer,8)
    local function touchLuaSpr()
        if isTouch==true then
            self:cancleTouchLayer()
        end
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr)
    touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-9)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(255)
    touchDialogBg:setPosition(getCenterPoint(self.touchLayer))
    self.touchLayer:addChild(touchDialogBg)
    return touchDialogBg
end
function acChristmasFightTab1:cancleTouchLayer()
    if self.touchLayer~=nil then
        local temLayer=tolua.cast(self.touchLayer,"CCLayer")
        if temLayer~=nil then
            temLayer:removeFromParentAndCleanup(true)
            temLayer=nil
        end
        self.touchLayer=nil
    end
end

function acChristmasFightTab1:tick()
    if self then
        if acChristmasFightVoApi:acIsStop()==true then
            if self.maskSp==nil then
                local function nilFunc()
                end
                self.maskSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc);
                self.maskSp:setTouchPriority(-(self.layerNum-1)*20-10)
                local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-160)
                self.maskSp:setContentSize(rect)
                self.maskSp:setAnchorPoint(ccp(0,0))
                self.maskSp:setOpacity(180)
                self.maskSp:setPosition(ccp(0,0))
                self.bgLayer:addChild(self.maskSp,10)

                local endTimeLb=GetTTFLabelWrap(getlocal("activity_banzhangshilian_time_end"),30,CCSizeMake(G_VisibleSizeWidth-100,0),kCCVerticalTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                endTimeLb:setPosition(getCenterPoint(self.maskSp))
                self.maskSp:addChild(endTimeLb,1)
                endTimeLb:setColor(G_ColorYellowPro)
            end
        else
            local status,point,time=acChristmasFightVoApi:getSnowmanData()
            -- print("status,point,time",status,point,time)
            -- print("self.snowStatus",self.snowStatus)
            -- print("self.barNum",self.barNum)
            if self.snowStatus~=status or self.barNum~=point then
                local function callback()
                    self:tick()
                    self:refresh()
                end
                acChristmasFightVoApi:updateActiveData("get",nil,callback)
                self.snowStatus=status
                self.barNum=point
            elseif acChristmasFightVoApi:getFlag()==0 then
                acChristmasFightVoApi:setFlag(1)
                self:tick()
                self:refresh()
            end

            local clbHeight=125*self.scaleY
            local isFree=acChristmasFightVoApi:isFree()
            if isFree==true then
                if self.goldSp then
                    self.goldSp:setVisible(false)
                end
                if self.costLb then
                    self.costLb:setVisible(false)
                end
                if self.freeLb then
                    self.freeLb:setVisible(true)
                end
                if self.lbBg then
                    self.lbBg:setPosition(ccp(180-70,clbHeight))
                end
                if self.tenLotteryBtn then
                    self.tenLotteryBtn:setEnabled(false)
                end
            else
                if self.goldSp then
                    self.goldSp:setVisible(true)
                end
                if self.costLb then
                    self.costLb:setVisible(true)
                end
                if self.freeLb then
                    self.freeLb:setVisible(false)
                end
                if self.lbBg then
                    self.lbBg:setPosition(ccp(180-35,clbHeight))
                end
                if self.tenLotteryBtn then
                    self.tenLotteryBtn:setEnabled(true)
                end
            end
        end
        self:updateAcTime()
    end
end

function acChristmasFightTab1:updateAcTime()
    local acVo=acChristmasFightVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acChristmasFightTab1:refresh()
    if self then
        local acVo=acChristmasFightVoApi:getAcVo()
        local status,point,time=acChristmasFightVoApi:getSnowmanData()

        local bgWidth=self.bgLayer:getContentSize().width
        local bgHeight=self.bgLayer:getContentSize().height
        if self.status~=status then
            if self.acBg then
                self.acBg:removeFromParentAndCleanup(true)
                self.acBg=nil
            end
            if acChristmasFightVoApi:getAcShowType()==acChristmasFightVoApi.acShowType.TYPE_2 then
                self.acBg=CCNode:create()
                self.acBg:setContentSize(CCSizeMake(612,786))
                local function onLoadIcon(fn,bgSprite)
                    if self and self.acBg and tolua.cast(self.acBg,"CCNode") then
                        bgSprite:setAnchorPoint(ccp(0.5,0.5))
                        bgSprite:setPosition(self.acBg:getContentSize().width/2,self.acBg:getContentSize().height/2)
                        self.acBg:addChild(bgSprite)
                    end
                end
                if status==1 then
                    LuaCCWebImage:createWithURL(G_downloadUrl("active/demonBg_v2.jpg"),onLoadIcon)
                else
                    LuaCCWebImage:createWithURL(G_downloadUrl("active/angelBg_v2.jpg"),onLoadIcon)
                end
            else
                local bgStr
                if G_curPlatName()=="21" or G_curPlatName()=="androidarab" or G_curPlatName()=="0" then
                    bgStr="arImage/"
                else
                    bgStr="public/"
                end
                if status==1 then
                    bgStr=bgStr.."demonBg.jpg"
                else
                    bgStr=bgStr.."angelBg.jpg"
                end
                self.acBg=CCSprite:create(bgStr)
            end
            self.acBg:setAnchorPoint(ccp(0.5,1))
            self.acBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-160))
            self.bgLayer:addChild(self.acBg)
            self.acBg:setScaleX(590/self.acBg:getContentSize().width)
            self.acBg:setScaleY((self.bgLayer:getContentSize().height-200)/self.acBg:getContentSize().height)
            self.status=status

            local barBg = self.bgLayer:getChildByTag(13)
            if barBg then
                barBg:removeFromParentAndCleanup(true)
            end
            local bar = self.bgLayer:getChildByTag(11)
            if bar then
                bar:removeFromParentAndCleanup(true)
            end
            local maxPoint=acVo.maxPoint
            local perStr=point.."/"..maxPoint
            local cpy=bgHeight-(515+185+80)*self.scaleY
            if status==1 then
                AddProgramTimer(self.bgLayer,ccp(bgWidth/2,cpy),11,12,nil,"platWarProgressBg.png","platWarProgress1.png",13,1,1)
            else
                AddProgramTimer(self.bgLayer,ccp(bgWidth/2,cpy),11,12,nil,"platWarProgressBg.png","platWarProgress2.png",13,1,1)
            end
            local per = point/maxPoint*100
            local timerSpriteLv = self.bgLayer:getChildByTag(11)
            timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
            timerSpriteLv:setPercentage(per)

            if self.queIconTab then
                for k,v in pairs(self.queIconTab) do
                    local qIcon=tolua.cast(v,"LuaCCSprite")
                    if qIcon then
                        if status==1 then
                            qIcon:setVisible(true)
                        else
                            qIcon:setVisible(false)
                        end
                    end
                end
            end
        end

        if self.cPointLb then
            self.cPointLb:setString(getlocal("allianceShop_myDonate")..acVo.cPoint)
        end
        local maxPoint=acVo.maxPoint
        local timerSpriteLv = self.bgLayer:getChildByTag(11)
        if timerSpriteLv then
            timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
            if timerSpriteLv then
                local per = point/maxPoint*100
                timerSpriteLv:setPercentage(per)
            end
        end
        if self.barLb then
            local perStr=point.."/"..maxPoint
            self.barLb:setString(perStr)
        end

        if self.iconTab then
            for k,v in pairs(self.iconTab) do
                local icon=tolua.cast(v,"LuaCCSprite")
                if icon then
                    local iconSize=100
                    local statusTab=acChristmasFightVoApi:getCRewardStatus()
                    local cStatus=statusTab[k]
                    -- print("cStatus",cStatus)
                    if cStatus==2 then
                        G_removeFlicker(icon)
                        local maskSp=tolua.cast(icon:getChildByTag(101),"LuaCCScale9Sprite")
                        if maskSp==nil then
                            local function touchLuaSpr()
                            end
                            local maskSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr)
                            maskSp:setTouchPriority(-(self.layerNum-1)*20-1)
                            local rect=CCSizeMake(iconSize,iconSize)
                            maskSp:setContentSize(rect)
                            maskSp:setOpacity(180)
                            maskSp:setPosition(getCenterPoint(icon))
                            maskSp:setTag(101)
                            icon:addChild(maskSp)
                            hadRewardLb= GetTTFLabelWrap(getlocal("activity_hadReward"),25,CCSizeMake(iconSize,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                            hadRewardLb:setPosition(getCenterPoint(maskSp))
                            maskSp:addChild(hadRewardLb)
                            hadRewardLb:setColor(G_ColorYellow)
                        end
                    elseif cStatus==1 then
                        G_removeFlicker(icon)
                        G_addRectFlicker(icon,1.4,1.4)
                    end
                end
            end
        end
        local status,point,time=acChristmasFightVoApi:getSnowmanData()
        self.snowStatus=status
        self.barNum=point
    end
end

function acChristmasFightTab1:dispose()
    self.layerNum=nil
    self.selectedTabIndex=nil
    self.cPointLb=nil
    self.lotteryBtn=nil
    self.tenLotteryBtn=nil
    self.iconTab={}
    self.showIndex1=1
    self.showIndex2=1001
    self.showTab={}
    self.snowStatus=0
    self.barNum=0
    self.queIconTab={}

    self:cancleTouchLayer()
    self.touchLayer=nil
    if self.maskSp then
        self.maskSp:removeFromParentAndCleanup(true)
    end
    self.maskSp=nil
    if self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
    end
    self.bgLayer=nil
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/angelBg.jpg")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/demonBg.jpg")
    CCTextureCache:sharedTextureCache():removeTextureForKey("arImage/angelBg.jpg")
    CCTextureCache:sharedTextureCache():removeTextureForKey("arImage/angelBg.jpg")
end





