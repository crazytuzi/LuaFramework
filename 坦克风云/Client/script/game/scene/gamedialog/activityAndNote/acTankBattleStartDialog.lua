acTankBattleStartDialog = commonDialog:new()

function acTankBattleStartDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.height = 130
    self.touchArr={}
    self.flag1=false 
    self.flag2=false
    self.flag3=false

    self.touchEnable=true
    self.rankList={}
    self.acIsStop=false
    self.nowSid=nil
    self.lastSid=nil
    self.heroIcon={}

    return nc
end

function acTankBattleStartDialog:resetTab()
    self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 105))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, 10))
    self.panelLineBg:setVisible(false)

    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.closeBtn:setTouchPriority(-(self.layerNum-1)*20-0)

    self.acIsStop=acTankBattleVoApi:acIsStop()

    if acTankBattleVoApi:acIsStop()==true then

        local function callback(fn,data)
            local ret,sData = base:checkServerData(data)
            if ret then
                if sData and sData.data and sData.data.ranklist then
                    self.rankList=sData.data.ranklist
                end

                self:initLayer(true)
            end
            
        end
        if acTankBattleVoApi:getR()==0 then
            socketHelper:acTankBattleRanklist(callback)
        else
           self:initLayer(true)
        end
        
    else
        self:initLayer()
    end
    
    

end

function acTankBattleStartDialog:initTableView()
end

function acTankBattleStartDialog:initLayer(flag)

    local function close()
        PlayEffect(audioCfg.mouseClick)    
        return self:close()
    end
    local closeBtnItem = GetButtonItem("acTankBattle_close.png","acTankBattle_close.png","acTankBattle_close.png",close,nil,nil,nil);
    closeBtnItem:setPosition(0, 0)
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))

    local closeBtn = CCMenu:createWithItem(closeBtnItem)
    closeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    closeBtn:setPosition(ccp(self.bgLayer:getContentSize().width-closeBtnItem:getContentSize().width,self.bgLayer:getContentSize().height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(closeBtn,6)


    self.clayer=CCLayerColor:create(ccc4(0,0,0,255))
    self.bgLayer:addChild(self.clayer,5) 
    self.clayer:setBSwallowsTouches(false)
    -- self.clayer:setTouchEnabled(true)
    local function tmpHandler(...)

        if self.flag1 and self.touchEnable then
            self.touchEnable=false
            self:showList1()
            return
        end

        if self.flag2 and self.touchEnable then
            self.touchEnable=false
            self:showList2()
            return
        end
    end
    self.clayer:registerScriptTouchHandler(tmpHandler,false,-(self.layerNum-1)*20-1,true)
    -- self.clayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.clayer:setBSwallowsTouches(true)


    local acVo = acTankBattleVoApi:getAcVo()
    local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt-86400)
    local acTime = getlocal("activity_timeLabel") .. ":" .. timeStr
    local acTimeLb = GetTTFLabelWrap(acTime,25,CCSizeMake(580,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    acTimeLb:setPosition(ccp(G_VisibleSizeWidth/2, 90))
    self.clayer:addChild(acTimeLb)

    local rewardTime = getlocal("recRewardTime") .. ":" .. acTankBattleVoApi:getRewardTimeStr()
    local acrewardLb = GetTTFLabelWrap(rewardTime,25,CCSizeMake(580,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    acrewardLb:setPosition(ccp(G_VisibleSizeWidth/2, 45))
    self.clayer:addChild(acrewardLb)


    if flag then
        self:addJiangliBtn()
    end

    self:initMap()
    
end

function acTankBattleStartDialog:addJiangliBtn()
    local rank = self:getRankReward()
    if rank==0 and acTankBattleVoApi:getR()==0 then
        return
    end

    local function getRankReward()
        local function callback(fn,data)
            local ret,sData = base:checkServerData(data)
            if ret then
                if sData and sData.data and sData.data.tankbattle then
                    acTankBattleVoApi:updateSpecialData(sData.data.tankbattle)
                end 
                self.rewardItem:setEnabled(false)
                self.rewardItem:setVisible(false)
                local reward = acTankBattleVoApi:getRankReward(rank)
                -- G_dayin(reward)
                if reward then
                    -- print("+++++++rank",rank)
                    local item = FormatItem(reward)
                    -- print("++++++++item",item[1].type,item[1].key,item[1].num)
                    G_addPlayerAward(item[1].type,item[1].key,item[1].id,item[1].num,nil,nil)
                    -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("active_lottery_reward_tank",{item[1].name,item[1].num}),30)
                    -- G_showRewardTip(item,true)
                    local str=self:getRewardStr(reward)
                    str = getlocal("daily_lotto_tip_10") .. str
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,28)
                end
            end
        end
        socketHelper:acTankBattleRankreward(rank,callback)
    end
    local rewardItem = GetButtonItem("acTankBattle_gift.png","acTankBattle_gift.png","acTankBattle_gift.png",getRankReward,nil,nil,25)
    self.rewardItem=rewardItem
    local rewardBtn=CCMenu:createWithItem(rewardItem);
    rewardBtn:setTouchPriority(-(self.layerNum-1)*20-6);
    rewardBtn:setPosition(ccp(self.clayer:getContentSize().width/2-150,self.clayer:getContentSize().height/2))
    self.clayer:addChild(rewardBtn,7)

    if acTankBattleVoApi:getR()==1 then
        self.rewardItem:setEnabled(false)
        self.rewardItem:setVisible(false)
    end
end

function acTankBattleStartDialog:initMap()
    
    local spriteBatch = CCSpriteBatchNode:create("public/acTankBattle.png")
    self.clayer:addChild(spriteBatch)
    self.spriteBatch=spriteBatch

    local caoTb={ccp(47, 828),ccp(79, 828),ccp(111, 828),ccp(143, 828),ccp(95, 796),ccp(95, 764),ccp(95, 732),ccp(95, 700),ccp(95, 668),ccp(95, 636),ccp(245, 828),ccp(221, 796),ccp(269, 796),ccp(205, 764),ccp(285, 764),ccp(197, 732),ccp(229, 700),ccp(261, 700),ccp(197, 700),ccp(197, 668),ccp(293, 732),ccp(293, 700),ccp(293, 668),ccp(197, 636),ccp(293, 636),ccp(347, 828),ccp(379, 796),ccp(387, 764),ccp(395, 732),ccp(403, 700),ccp(411, 668),ccp(347, 796),ccp(347, 764),ccp(347, 732),ccp(347, 700),ccp(347, 668),ccp(443, 828),ccp(443, 796),ccp(443, 764),ccp(443, 732),ccp(443, 700),ccp(443, 668),ccp(347, 636),ccp(443, 636),ccp(497, 828),ccp(529, 748),ccp(529, 716),ccp(561, 700),ccp(593, 828),ccp(561, 764),ccp(577, 796),ccp(593, 636),ccp(577, 668),ccp(497, 796),ccp(497, 764),ccp(497, 732),ccp(497, 700),ccp(497, 668),ccp(497, 636),ccp(47, 324),ccp(47, 292),ccp(47, 260),ccp(47, 228),ccp(47, 196),ccp(47, 164),ccp(47, 132),ccp(260, 324),ccp(228, 324),ccp(196, 324),ccp(166, 324),ccp(166, 292),ccp(166, 260),ccp(166, 228),ccp(196, 228),ccp(228, 228),ccp(260, 292),ccp(260, 260),ccp(260, 228),ccp(260, 196),ccp(260, 164),ccp(260, 132),ccp(228, 132),ccp(196, 132),ccp(166, 132),ccp(593, 324),ccp(561, 324),ccp(529, 324),ccp(499, 324),ccp(499, 292),ccp(499, 260),ccp(499, 228),ccp(529, 228),ccp(561, 228),ccp(593, 292),ccp(593, 260),ccp(593, 228),ccp(593, 196),ccp(593, 164),ccp(593, 132),ccp(561, 132),ccp(529, 132),ccp(499, 132),ccp(332, 324),ccp(364, 324),ccp(396, 324),ccp(428, 324),ccp(364, 132),ccp(396, 132),ccp(428, 132),ccp(332, 292),ccp(332, 260),ccp(332, 228),ccp(332, 196),ccp(364, 228),ccp(396, 228),ccp(332, 164),ccp(428, 228),ccp(428, 164),ccp(428, 196),ccp(332, 132)}

    for k,v in pairs(caoTb) do
        local caoIcon=CCSprite:createWithSpriteFrameName("acTankBattle_zhuan.png")
        caoIcon:setPosition(v)
        spriteBatch:addChild(caoIcon)
        if(G_isIphone5())then
            local y=caoIcon:getPositionY()
            caoIcon:setPositionY(y+88)
        end
    end

    self:initMenu()
end

function acTankBattleStartDialog:initMenu()
    local posWidth2 = 20
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        posWidth2 =0
    end
    -- heroVoApi:getHeroList()
    local function startCalllback()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if self.flag1 and self.touchEnable then
            self.touchEnable=false
            self:showList1()
            return
        end

        if self.flag3 and self.touchEnable then
            self.touchEnable=false
            self:showList3()
            return
        end

        if self.flag2 and self.touchEnable then
            self.touchEnable=false
            self:showList2()
            return
        end

        self:setGuangbiao(1)
        local function callback()
            self:checkIsFree()
        end
        acTankBattleVoApi:showTankBattleDialog(self.layerNum+1,callback)

    end

    local function listCalllback()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end

        if self.flag2 and self.touchEnable then
            self.touchEnable=false
            self:showList2()
            return
        end

        if self.flag3 and self.touchEnable then
            self.touchEnable=false
            self:showList3()
            return
        end

        self:setGuangbiao(2)
        if self.touchEnable and self.flag1==false then
            local function callback(fn,data)
                local ret,sData = base:checkServerData(data)
                if ret then
                    self:showList1()
                    if sData and sData.data and sData.data.ranklist then
                        self.rankList=sData.data.ranklist
                    end
                    self:updateTv2()
                    
                end
                
            end
            socketHelper:acTankBattleRanklist(callback)
        elseif self.touchEnable then
            self:showList1()
        end
        
    end

    local function optionCalllback()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end

        if self.flag1 and self.touchEnable then
            self.touchEnable=false
            self:showList1()
            return
        end

        if self.flag3 and self.touchEnable then
            self.touchEnable=false
            self:showList3()
            return
        end

        if self.touchEnable then
            self:setGuangbiao(3)
            self:showList2()
        end
    end

    local function helpCalllback()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end

        if self.flag1 and self.touchEnable then
            self.touchEnable=false
            self:showList1()
            return
        end

        if self.flag2 and self.touchEnable then
            self.touchEnable=false
            self:showList2()
            return
        end

        if self.touchEnable then
            self:setGuangbiao(4)
            self:showList3()
        end

    end



    local startLb = GetTTFLabel(getlocal("activity_tankbattle_start"),25)
    local listLb = GetTTFLabel(getlocal("activity_tankbattle_list"),25)
    local optionLb = GetTTFLabel(getlocal("activity_tankbattle_option"),25)
    local helpLb = GetTTFLabel(getlocal("activity_tankbattle_help"),25)


    local menuItem1 = CCMenuItemLabel:create(startLb)
    local menuItem2 = CCMenuItemLabel:create(listLb)
    local menuItem3 = CCMenuItemLabel:create(optionLb)
    local menuItem4 = CCMenuItemLabel:create(helpLb)
    menuItem1:setAnchorPoint(ccp(0,0.5))
    menuItem2:setAnchorPoint(ccp(0,0.5))
    menuItem3:setAnchorPoint(ccp(0,0.5))
    menuItem4:setAnchorPoint(ccp(0,0.5))


    self.menuItem1=menuItem1
    self.menuItem2=menuItem2
    self.menuItem3=menuItem3
    self.menuItem4=menuItem4

    menuItem1:registerScriptTapHandler(startCalllback)
    menuItem2:registerScriptTapHandler(listCalllback)
    menuItem3:registerScriptTapHandler(optionCalllback)
    menuItem4:registerScriptTapHandler(helpCalllback)




    local btnMenu = CCMenu:create()
    btnMenu:addChild(menuItem1)
    btnMenu:addChild(menuItem2)
    btnMenu:addChild(menuItem3)
    btnMenu:addChild(menuItem4)

    btnMenu:alignItemsVerticallyWithPadding(20)

    self.clayer:addChild(btnMenu)
    btnMenu:setTouchPriority(-(self.layerNum-1)*20-5)
    btnMenu:setBSwallowsTouches(true)
    btnMenu:setPositionX(280)

    local freeLb = GetTTFLabel(getlocal("activity_tankbattle_free"),25)
    -- freeLb:setPosition(280+50+startLb:getContentSize().width,self.clayer:getContentSize().height/2+60)
    freeLb:setPosition(280+50+startLb:getContentSize().width+posWidth2,menuItem1:getPositionY()+self.clayer:getContentSize().height/2)

    freeLb:setColor(G_ColorRed)
    self.clayer:addChild(freeLb)
    self.freeLb=freeLb

    self.guangbiaoIcon = CCSprite:createWithSpriteFrameName("SlotArowRed.png")
    self.guangbiaoIcon:setRotation(-90)
    self.guangbiaoIcon:setPosition(ccp(240,menuItem1:getPositionY()+self.clayer:getContentSize().height/2))
    self.clayer:addChild(self.guangbiaoIcon,3)

    

    local costLb = GetTTFLabel("100",25)
    costLb:setPosition(280+50+startLb:getContentSize().width,menuItem1:getPositionY()+self.clayer:getContentSize().height/2)
    self.clayer:addChild(costLb)
    self.costLb=costLb

    local goldIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
    costLb:addChild(goldIcon)
    goldIcon:setPosition(costLb:getContentSize().width+20,costLb:getContentSize().height/2)

    local function nilFunc()
    end
    local lineSp1=LuaCCScale9Sprite:createWithSpriteFrameName("acTankBattle_white.png",CCRect(1, 1, 1, 1),nilFunc)
    lineSp1:setTouchPriority(-(self.layerNum-1)*20-1)
    lineSp1:setContentSize(CCSizeMake(280,3))
    lineSp1:setAnchorPoint(ccp(0.5,0.5))
    lineSp1:setPosition(200+50+startLb:getContentSize().width,menuItem1:getPositionY()+self.clayer:getContentSize().height/2)
    self.clayer:addChild(lineSp1)
    self.lineSp1=lineSp1

    local function nilFunc()
    end
    local lineSp2=LuaCCScale9Sprite:createWithSpriteFrameName("acTankBattle_white.png",CCRect(1, 1, 1, 1),nilFunc)
    lineSp2:setTouchPriority(-(self.layerNum-1)*20-1)
    lineSp2:setContentSize(CCSizeMake(140,3))
    lineSp2:setAnchorPoint(ccp(0.5,0.5))
    lineSp2:setPosition(170+startLb:getContentSize().width,menuItem3:getPositionY()+self.clayer:getContentSize().height/2)
    self.clayer:addChild(lineSp2)
    self.lineSp2=lineSp2

    self:checkIsFree()

    self:checkItemEnable()

    
    self:addListAndOption()
     
end

function acTankBattleStartDialog:setGuangbiao(flag)
    if flag==1 then
        self.guangbiaoIcon:setPositionY(self.menuItem1:getPositionY()+self.clayer:getContentSize().height/2)
    elseif flag==2 then
        self.guangbiaoIcon:setPositionY(self.menuItem2:getPositionY()+self.clayer:getContentSize().height/2)
    elseif flag==3 then
        self.guangbiaoIcon:setPositionY(self.menuItem3:getPositionY()+self.clayer:getContentSize().height/2)
    elseif flag==4 then
        self.guangbiaoIcon:setPositionY(self.menuItem4:getPositionY()+self.clayer:getContentSize().height/2)
    end

end

function acTankBattleStartDialog:checkIsFree()
    local isFree = acTankBattleVoApi:isCanBattle( )
    if isFree==true then
        if self.freeLb then
            self.freeLb:setVisible(true)
        end
        if self.costLb then 
            self.costLb:setVisible(false)
        end
        
    else
        if self.costLb then 
            local cost = acTankBattleVoApi:getCost()
            self.costLb:setString(cost)
            self.costLb:setVisible(true)
        end
        if self.freeLb then
            self.freeLb:setVisible(false)
        end
        
    end
end

function acTankBattleStartDialog:checkItemEnable()
    if acTankBattleVoApi:acIsStop() then
        self.menuItem1:setEnabled(false)
        self.menuItem3:setEnabled(false)
        self.lineSp1:setVisible(true)
        self.lineSp2:setVisible(true)
    else
        self.lineSp1:setVisible(false)
        self.lineSp2:setVisible(false)
    end
end

function acTankBattleStartDialog:updateTv2()
    -- local recordPoint=self.tv2:getRecordPoint()
    self.tv2:reloadData()
    -- self.tv2:recoverToRecordPoint(recordPoint)
end

-- 0:无奖励 其它有奖励
function acTankBattleStartDialog:getRankReward()
    local playerUid = playerVoApi:getUid()
    local rank=0
    for k,v in pairs(self.rankList) do
        if tonumber(v[1])==tonumber(playerUid) then
            rank = k
            break
        end
    end
    return rank
end

function acTankBattleStartDialog:addListAndOption()
    for i=1,3 do
        local function nilFunc()
            return
        end
        local grayBg = LuaCCScale9Sprite:createWithSpriteFrameName("acTankBattle_gray.png",CCRect(1,1,1,1),nilFunc)
        grayBg:setTouchPriority(-(self.layerNum-1)*20-1)
        grayBg:setContentSize(CCSizeMake(580,400))
        grayBg:setAnchorPoint(ccp(0,0))
        -- grayBg:setPosition(ccp(30,0))
        grayBg:setPosition(ccp(30,-400))    
        self.clayer:addChild(grayBg)

        local neiBg = LuaCCScale9Sprite:createWithSpriteFrameName("acTankBattle_wb.png",CCRect(4,4,1,1),nilFunc)
        neiBg:setContentSize(CCSizeMake(578,340))
        neiBg:setAnchorPoint(ccp(0,0))
        neiBg:setPosition(ccp(1,0))
        grayBg:addChild(neiBg)

        if i==1 then
            self.grayBg1=grayBg
        elseif i==2 then
            self.grayBg2=grayBg
        else
            self.grayBg3=grayBg
        end
    end

    local function forbidClick()
        if self.flag1 and self.touchEnable then
            self.touchEnable=false
            self:showList1()
            return
        end

        if self.flag2 and self.touchEnable then
            self.touchEnable=false
            self:showList2()
            return
        end

        if self.flag3 and self.touchEnable then
            self.touchEnable=false
            self:showList3()
            return
        end
    end
    self.topfbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20,20,10,10),forbidClick)
    self.topfbidSp:setTouchPriority(-(self.layerNum-1)*20-3)
    self.topfbidSp:setAnchorPoint(ccp(0,0))
    self.topfbidSp:setContentSize(CCSizeMake(640,G_VisibleSizeHeight-self.grayBg1:getContentSize().height+40))
    self.topfbidSp:setPosition(0,340)
    self.clayer:addChild(self.topfbidSp)
    self.topfbidSp:setVisible(false)



    local lbSize = 20

    -- list 排行榜信息
    local hei = self.grayBg1:getContentSize().height-30
    local titleTb1={
                    {name=getlocal("activity_tankbattle_num"),pos=ccp(70,hei)},
                    {name=getlocal("activity_tankbattle_name"),pos=ccp(290,hei)},
                    {name=getlocal("activity_tankbattle_score"),pos=ccp(500,hei)},
                   }
    for k,v in pairs(titleTb1) do
        local lb = GetTTFLabelWrap(v.name,lbSize,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        lb:setPosition(v.pos)
        self.grayBg1:addChild(lb)
    end 

    -- 奖励信息
    local titleLb=GetTTFLabelWrap(getlocal("activity_tankbattle_selectHero"),lbSize,CCSizeMake(540,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(self.grayBg2:getContentSize().width/2,hei))
    self.grayBg2:addChild(titleLb)

    -- 帮助信息
    local helpLb=GetTTFLabelWrap(getlocal("alien_tech_propTitle4"),lbSize,CCSizeMake(540,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    helpLb:setAnchorPoint(ccp(0.5,0.5))
    helpLb:setPosition(ccp(self.grayBg3:getContentSize().width/2,hei))
    self.grayBg3:addChild(helpLb)

    self.heroList = heroVoApi:getHeroList()
    -- G_dayin(self.heroList)
    if SizeOfTable(self.heroList)==0 then
        local noHeroDes = GetTTFLabelWrap(getlocal("activity_tankbattle_noHero"),lbSize,CCSizeMake(540,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        noHeroDes:setAnchorPoint(ccp(0,0.5))
        noHeroDes:setPosition(ccp(20,hei-100))
        self.grayBg2:addChild(noHeroDes)
        noHeroDes:setColor(G_ColorYellowPro)

        local sid = acTankBattleVoApi:getReward()
        local heroIcon = heroVoApi:getHeroIcon(sid)
        heroIcon:setAnchorPoint(ccp(0.5,1))
        heroIcon:setScale(100/heroIcon:getContentSize().width)
        heroIcon:setPosition(self.grayBg2:getContentSize().width/2,hei-130)
        self.grayBg2:addChild(heroIcon)


        local id=tonumber(sid) or tonumber(RemoveFirstChar(sid))
        local hid = "h" .. id
        local name = getlocal("heroSoul",{heroVoApi:getHeroName(hid)})

        local namelb = GetTTFLabelWrap(name,25,CCSizeMake(300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        namelb:setAnchorPoint(ccp(0.5,1))
        namelb:setPosition(self.grayBg2:getContentSize().width/2,hei-240)
        self.grayBg2:addChild(namelb)

        self.cellNum=0
    else
        self.cellNum=1
    end

    self.tv1H = math.ceil(SizeOfTable(self.heroList)/3)*150

    self.lastSid=acTankBattleVoApi:getSid()
    self.nowSid=acTankBattleVoApi:getSid()
    local function callBack(...)
        return self:eventHandler1(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv1=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.grayBg2:getContentSize().width-20,320),nil)
    self.tv1:setPosition(ccp(0,10))
    self.tv1:setMaxDisToBottomOrTop(80)
    self.tv1:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.grayBg2:addChild(self.tv1,1)

    local function callBack2(...)
        return self:eventHandler2(...)
    end
    local hd2= LuaEventHandler:createHandler(callBack2)
    self.tv2=LuaCCTableView:createWithEventHandler(hd2,CCSizeMake(self.grayBg1:getContentSize().width-20,320),nil)
    self.tv2:setPosition(ccp(0,10))
    self.tv2:setMaxDisToBottomOrTop(80)
    self.tv2:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.grayBg1:addChild(self.tv2,1)

    local function callBack3(...)
        return self:eventHandler3(...)
    end
    local hd3= LuaEventHandler:createHandler(callBack3)
    self.tv3=LuaCCTableView:createWithEventHandler(hd3,CCSizeMake(self.grayBg1:getContentSize().width-20,320),nil)
    self.tv3:setPosition(ccp(0,10))
    self.tv3:setMaxDisToBottomOrTop(80)
    self.tv3:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.grayBg3:addChild(self.tv3,1)



    
end

function acTankBattleStartDialog:eventHandler1(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize = CCSizeMake(self.bgLayer:getContentSize().width - 20,self.tv1H)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local heroNum = SizeOfTable(self.heroList)
        local cellNum = math.ceil(heroNum/3)
        local width = 560/3
        for i=1, heroNum do
            local numHang = cellNum-math.ceil(i/3)
            local numLie = i%3
            if numLie==0 then
                numLie=3
            end
            local hid = self.heroList[i].hid
            local id=tonumber(hid) or tonumber(RemoveFirstChar(hid))
            local sid = "s" .. id

            local function callback()
                if self.tv1:getScrollEnable()==true and self.tv1:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                end
               
                -- self.rightIcon:setPosition(ccp((numLie-1)*width+(width-100)/2+50+50,numHang*150+20+20))
                self.lastSid=self.nowSid
                self.nowSid=sid

                if self.nowSid~=self.lastSid then
                    local acScale1 = CCScaleTo:create(0.1,110/150)
                    local acScale2 = CCScaleTo:create(0.1,100/150)
                    local function acCallback()
                        self.rightIcon:setPosition(ccp((numLie-1)*width+(width-100)/2+50+50,numHang*150+20+20))
                    end
                    local callFunc=CCCallFunc:create(acCallback)

                    local acArr=CCArray:create()
                    acArr:addObject(acScale1)
                    acArr:addObject(acScale2)
                    acArr:addObject(callFunc)

                    local seq=CCSequence:create(acArr)
                    self.heroIcon[hid]:runAction(seq)
                end
                

                
        
                
            end
            local heroIcon = heroVoApi:getHeroIcon(hid,nil,nil,callback)
            heroIcon:setAnchorPoint(ccp(0.5,1))
            heroIcon:setScale(100/heroIcon:getContentSize().width)
            heroIcon:setAnchorPoint(ccp(0.5,0.5))
            heroIcon:setTouchPriority(-(self.layerNum-1)*20-2)
            heroIcon:setPosition((numLie-1)*width+(width-100)/2+50,numHang*150+40+50)
            cell:addChild(heroIcon)
            self.heroIcon[hid]=heroIcon

            local name = heroVoApi:getHeroName(hid)
            local nameLb = GetTTFLabelWrap(name,20,CCSizeMake(140,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            nameLb:setAnchorPoint(ccp(0.5,0.5))
            nameLb:setPosition((numLie-1)*width+(width-100)/2+50,numHang*150+20)
            cell:addChild(nameLb)


            if sid==acTankBattleVoApi:getSid() then
                local rightIcon=CCSprite:createWithSpriteFrameName("7daysCheckmark.png")
                rightIcon:setAnchorPoint(ccp(1,0))
                rightIcon:setPosition(ccp((numLie-1)*width+(width-100)/2+50+50,numHang*150+20+20))
                cell:addChild(rightIcon,4)
                self.rightIcon=rightIcon
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

function acTankBattleStartDialog:eventHandler2(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return SizeOfTable(self.rankList)+1
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize = CCSizeMake(self.grayBg2:getContentSize().width - 20,60)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local rank=0
        local name=0
        local point=0
        if idx==0 then
            rank,name,point=self:getSelfRank(self.rankList)
        else
            rank=idx
            name=self.rankList[idx][2]
            point=self.rankList[idx][3]
        end
        local lbSize = 20
        local rankLb = GetTTFLabel(rank,lbSize)
        rankLb:setPosition(ccp(70,0))
        rankLb:setAnchorPoint(ccp(0.5,0))
        cell:addChild(rankLb)

        local nameLb = GetTTFLabelWrap(name,lbSize,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        nameLb:setPosition(ccp(290,0))
        nameLb:setAnchorPoint(ccp(0.5,0))
        cell:addChild(nameLb)

        local pointLb = GetTTFLabelWrap(point,lbSize,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        pointLb:setPosition(ccp(500,0))
        pointLb:setAnchorPoint(ccp(0.5,0))
        cell:addChild(pointLb)
        if idx==0 then
            rankLb:setColor(G_ColorYellowPro)
            nameLb:setColor(G_ColorYellowPro)
            pointLb:setColor(G_ColorYellowPro)
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

function acTankBattleStartDialog:eventHandler3(handler,fn,idx,cel)
    local needHeight = 830
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        needHeight =580
    end
    if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize = CCSizeMake(self.grayBg2:getContentSize().width - 20,needHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local high=needHeight
        local lbSize=25

        local helpTb={getlocal("activity_tankbattle_help_tip1",{acTankBattleVoApi:getFree()}),getlocal("activity_tankbattle_help_tip3"),getlocal("activity_tankbattle_help_tip4"),getlocal("BossBattle_rankTitle")}
        local rankReward=acTankBattleVoApi:getAllRankReward()
        for k,v in pairs(rankReward) do
            local rewardRankStr=""
            if v.range[1]==v.range[2] then
                local rewardStr = self:getRewardStr(v.reward)
                rewardRankStr=getlocal("activity_tankbattle_help_tip5",{v.range[1],rewardStr})
            else
                local rewardStr = self:getRewardStr(v.reward)
                rewardRankStr=getlocal("activity_tankbattle_help_tip6",{v.range[1],v.range[2],rewardStr})
            end
            table.insert(helpTb,rewardRankStr)
        end

        local corLb = {nil,nil,nil,G_ColorYellowPro,nil}

        for k,v in pairs(helpTb) do
            high=high-10
            local helpLb = GetTTFLabelWrap(v,lbSize,CCSizeMake(540,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            helpLb:setPosition(ccp(10,high))
            helpLb:setAnchorPoint(ccp(0,1))
            if corLb[k]~=nil then
                helpLb:setColor(corLb[k])
            end
            cell:addChild(helpLb)
            high=high-helpLb:getContentSize().height
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

function acTankBattleStartDialog:getSelfRank(rankList)
    local playerUid = tonumber(playerVoApi:getUid())
    local rank,name,point
    for k,v in pairs(rankList) do
        if tonumber(v[1])==playerUid then
            rank=k
            name=v[2]
            point=v[3]
            return rank,name,point
        end
    end
    rank="20+"
    name=playerVoApi:getPlayerName()
    point=acTankBattleVoApi:getRankPoint()
    return rank,name,point

end


function acTankBattleStartDialog:showList1()
    local movPos=ccp(30,0)
    if self.flag1==true then
        movPos=ccp(30,-400)
    end

    local function onFlipHandlerToShowppp( )
        self.flag1 = not self.flag1
        self.touchEnable=true
    end
    local moveby=CCMoveTo:create(0.3,movPos)
    local callFunc=CCCallFunc:create(onFlipHandlerToShowppp)
    local acArr=CCArray:create()
    acArr:addObject(moveby)
    acArr:addObject(callFunc)
    local seq=CCSequence:create(acArr)
    self.grayBg1:runAction(seq)

end

function acTankBattleStartDialog:showList2()
    -- print("+++++++++++++++jsfdjksjl")

    local movPos=ccp(30,0)
    if self.flag2==true then
        movPos=ccp(30,-400)
    end

    local function callback()
        local function onFlipHandlerToShowppp( )
            self.flag2 = not self.flag2
            self.touchEnable=true
        end
        local moveby=CCMoveTo:create(0.3,movPos)
        local callFunc=CCCallFunc:create(onFlipHandlerToShowppp)
        local acArr=CCArray:create()
        acArr:addObject(moveby)
        acArr:addObject(callFunc)
        local seq=CCSequence:create(acArr)
        self.grayBg2:runAction(seq)
    end

    if self.flag2==true and self.nowSid then
        acTankBattleVoApi:setGetReward(self.nowSid,callback)
    else
        callback()
    end
    

end

function acTankBattleStartDialog:showList3()
    local movPos=ccp(30,0)
    if self.flag3==true then
        movPos=ccp(30,-400)
    end

    local function onFlipHandlerToShowppp( )
        self.flag3 = not self.flag3
        self.touchEnable=true
    end
    local moveby=CCMoveTo:create(0.3,movPos)
    local callFunc=CCCallFunc:create(onFlipHandlerToShowppp)
    local acArr=CCArray:create()
    acArr:addObject(moveby)
    acArr:addObject(callFunc)
    local seq=CCSequence:create(acArr)
    self.grayBg3:runAction(seq)

end



function acTankBattleStartDialog:tick()
    local vo=acTankBattleVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end
    -- 跨天
    if acTankBattleVoApi:isToday()==false then
        acTankBattleVoApi:clearVandC()
        self:checkIsFree()
    end
    if self.acIsStop~=acTankBattleVoApi:acIsStop() then
        self.acIsStop=acTankBattleVoApi:acIsStop()
        self:checkItemEnable()
        local function callback(fn,data)
            local ret,sData = base:checkServerData(data)
            if ret then
                if sData and sData.data and sData.data.ranklist then
                    self.rankList=sData.data.ranklist
                end
                self:addJiangliBtn()

            end
            
        end
        socketHelper:acTankBattleRanklist(callback)
    end

end

function acTankBattleStartDialog:getRewardStr(reward)
    local item = FormatItem(reward)
    local str=""
    for kk,vv in pairs(item) do
        if kk==SizeOfTable(item) then
            if vv.type=="h" then
                str=getlocal("activity_tankBattle_help_hero",{vv.num,vv.name})
            else
                str=str .. vv.name .. "*" .. vv.num
            end
            
        else
            if vv.type=="h" then
                str=getlocal("activity_tankBattle_help_hero",{vv.num,vv.name}) .. ","
            else
                str=str .. vv.name .. "*" .. vv.num .. ","
            end
            
        end
    end
    return str
end

function acTankBattleStartDialog:fastTick()
end

function acTankBattleStartDialog:dispose()
    self.touchArr={}
    self.touchEnable=nil
    self.rankList={}
    self.menuItem1=nil
    self.menuItem2=nil
    self.menuItem3=nil
    self.nowSid=nil
    self.lastSid=nil
    self.heroIcon={}
    
end
