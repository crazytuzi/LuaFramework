allianceWar2Tab1Dialog={

}

function allianceWar2Tab1Dialog:new(parent)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.leftBtn=nil
    self.expandIdx={}
    self.parent=parent
    self.bgLayer=nil;
    self.regroupLabel1=nil
    self.regroupTimeLabel1=nil
    self.menuAccelerate1=nil
    
    self.regroupLabel2=nil
    self.menuAccelerate2=nil
    
    self.regroupLabel3=nil
    self.tipLvTb={}
    self.isStratTick=false
    self.timeLb=nil
    self.cdLabel=nil
    self.numSp=nil
   
    return nc
end

function allianceWar2Tab1Dialog:init(layerNum)
    self.layerNum=layerNum;
    self.bgLayer=CCLayer:create();

    self:initTabLayer()
    --[[
    local function callback(fn,data)
        if base:checkServerData(data)==true then
            self:initTabLayer()


        end
    end
    socketHelper:alliancewarnewGet(allianceWar2VoApi:getTargetCity(),callback)
    ]]
    
    return self.bgLayer
end

function allianceWar2Tab1Dialog:initStartLayer()

    
    
end

function allianceWar2Tab1Dialog:initTabLayer()
    -- local warBgSp=GraySprite:create("scene/world_map_mi.jpg")
    -- local warBgSp=CCSprite:create("scene/world_map_mi.jpg")
    local warBgSp=CCSprite:create("public/serverWarLocal/serverWarLocalMapBg.jpg")
    local mapScale=1
    local wHeight=warBgSp:getContentSize().height*mapScale--*2
    local wWidth=warBgSp:getContentSize().width*mapScale
    local spacex=300
    local lbPosx=40+spacex+40
    local spacey=70
    local lbSpaceh=75
    local function touchLuaSpr()

    end
    self.touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    self.touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-5)
    local rect=CCSizeMake(G_VisibleSizeWidth,wHeight-15+90)
    self.touchDialogBg:setContentSize(rect)
    self.touchDialogBg:setAnchorPoint(ccp(0,1))
    self.touchDialogBg:setPosition(ccp(0,self.bgLayer:getContentSize().height-240+spacey+lbSpaceh))
    self.bgLayer:addChild(self.touchDialogBg,10);

    local cPoint=getCenterPoint(self.touchDialogBg)
    self.cdLabel = GetTTFLabel(getlocal("acCD"),40)
    self.cdLabel:setPosition(ccp(cPoint.x,cPoint.y+250))
    self.touchDialogBg:addChild(self.cdLabel,20)
    
    local zeroTime=G_getWeeTs(base.serverTime)
    local cityCfg=allianceWar2VoApi.startWarTime[allianceWar2VoApi:getTargetCity()]
    self.tmpTime=zeroTime+cityCfg[1]*3600+cityCfg[2]*60
    self.timeLb=GetTTFLabel("",40)
    self.timeLb:setPosition(ccp(cPoint.x,cPoint.y+150))
    self.touchDialogBg:addChild(self.timeLb,20)
    self.tmpTime=self.tmpTime-base.serverTime

    local timestr=G_getTimeStr(self.tmpTime)
    self.timeLb:setString(timestr)
    self.cdLabel:setColor(G_ColorOrange)
    self.timeLb:setColor(G_ColorOrange)


    local isCD,time=allianceWar2VoApi:getBattlefieldUserCDTime()
    local cdTimeStr=G_getTimeStr(time,1)
    self.regroupLabel1=GetTTFLabel(getlocal("allianceWarCD"),23)
    self.regroupLabel1:setAnchorPoint(ccp(0.5,0))
    self.regroupLabel1:setPosition(lbPosx,80+spacey+lbSpaceh)
    self.bgLayer:addChild(self.regroupLabel1,2)

    self.regroupTimeLabel1=GetTTFLabel(cdTimeStr,23)
    self.regroupTimeLabel1:setAnchorPoint(ccp(0.5,0.5))
    self.regroupTimeLabel1:setPosition(lbPosx,65+spacey+lbSpaceh)
    self.bgLayer:addChild(self.regroupTimeLabel1,2)

    
    local function touch()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if (battleScene and battleScene.isBattleing==true) then
            do return end
        end
        PlayEffect(audioCfg.mouseClick)

        local isCD,time=allianceWar2VoApi:getBattlefieldUserCDTime()
        local cdgem=allianceWar2VoApi:getCDGems(time)

        if playerVoApi:getGems()<cdgem then
            local function jumpGemDlg()
                vipVoApi:showRechargeDialog(self.layerNum+2)
            end
            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),jumpGemDlg,getlocal("dialog_title_prompt"),getlocal("alliance_createAllianceNoGem"),nil,self.layerNum+1)

            do
                return
            end
        end


        local function accelerate()
            local function callback(fn,data)
                local cresult,retTb=base:checkServerData(data)
                if cresult==true then
                    --减金币
                    local gemnum=playerVoApi:getGems()-cdgem
                    playerVoApi:setGems(gemnum)
                    -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allianceWar_killCD"),30)
                end

            end
            socketHelper:alliancewarnewBuycdtime(callback)
        
        end

        smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),accelerate,getlocal("dialog_title_prompt"),getlocal("accelerateGroupDesc",{cdgem}),nil,self.layerNum+1)

    end

    local accelerateBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",touch,1,getlocal("accelerateGroup"),25)
    self.menuAccelerate1=CCMenu:createWithItem(accelerateBtn)
    self.menuAccelerate1:setAnchorPoint(ccp(0,0))
    self.menuAccelerate1:setPosition(ccp(250+spacex,80+spacey+lbSpaceh))
    self.menuAccelerate1:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(self.menuAccelerate1,1)
    
    self.regroupLabel2=GetTTFLabelWrap(getlocal("regroup2"),25,CCSizeMake(130,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.regroupLabel2:setAnchorPoint(ccp(0.5,0.5))
    self.regroupLabel2:setPosition(lbPosx,80+spacey+lbSpaceh)
    self.bgLayer:addChild(self.regroupLabel2,2)
    
    local function touch2()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if (battleScene and battleScene.isBattleing==true) then
            do return end
        end
        PlayEffect(audioCfg.mouseClick)

        local function accelerate()
            local function callback(fn,data)
                local cresult,retTb=base:checkServerData(data)
                if cresult==true then
                    self:refreshFlag()
                    -- tankVoApi:clearTanksTbByType(6)
                    -- tankVoApi:clearTanksTbByType(4)
                    --smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allianceWar2_regroup_success"),30)
                end

            end
            if allianceWar2VoApi:getSelfOid()~=0 then
                -- print("allianceWar2VoApi:getTargetCity()",allianceWar2VoApi:getTargetCity())
                -- print("allianceWar2VoApi:getSelfOid()",allianceWar2VoApi:getSelfOid())
                socketHelper:alliancewarnewRegroup(allianceWar2VoApi:getSelfOid(),allianceWar2VoApi:getTargetCity(),callback)
            end
        end
        smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),accelerate,getlocal("dialog_title_prompt"),getlocal("accelerateGroupDesc2",{200}),nil,self.layerNum+1)
    end

    local accelerateBtn2=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",touch2,1,getlocal("regroup1"),25)
    self.menuAccelerate2=CCMenu:createWithItem(accelerateBtn2)
    self.menuAccelerate2:setAnchorPoint(ccp(0,0))
    self.menuAccelerate2:setPosition(ccp(250+spacex,80+spacey+lbSpaceh))
    self.menuAccelerate2:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(self.menuAccelerate2,1)
    self.regroupLabel2:setVisible(false)
    self.menuAccelerate2:setVisible(false)
    
    self.regroupLabel3=GetTTFLabelWrap(getlocal("allianceWarState1"),25,CCSizeMake(125,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.regroupLabel3:setAnchorPoint(ccp(0.5,0.5))
    self.regroupLabel3:setPosition(lbPosx,80+spacey+lbSpaceh)
    self.bgLayer:addChild(self.regroupLabel3,2)
    self.regroupLabel3:setVisible(false)

    
    local function touchInfo()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if (battleScene and battleScene.isBattleing==true) then
            do return end
        end
        PlayEffect(audioCfg.mouseClick)

        -- local td=smallDialog:new()
        -- local str1 = getlocal("allianceWar2_desc1")
        -- local str2 = getlocal("allianceWar2_desc2",{math.floor(allianceWar2Cfg.maxBattleTime/60)})
        -- local str3 = getlocal("allianceWar2_desc3")
        -- local str4 = getlocal("allianceWar2_desc4",{allianceWar2Cfg.tankeTransRate})
        -- local tabStr = {" ",str4,str3,str2,str1," "}
        -- local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28)
        -- sceneGame:addChild(dialog,self.layerNum+1)
        local tabStr={};
        local tabColor ={nil,G_ColorYellowPro,nil,G_ColorYellowPro,nil,G_ColorYellowPro,nil};
        local td=smallDialog:new()
        tabStr = {"\n",getlocal("allianceWar2_tip_desc4",{allianceWar2Cfg.winPointMax}),"\n",getlocal("allianceWar2_tip_desc3"),"\n",getlocal("allianceWar2_tip_desc2",{allianceWar2Cfg.tankeTransRate}),"\n"}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
        sceneGame:addChild(dialog,self.layerNum+1)
    end

    local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touchInfo,11,nil,nil)
    local infoMenu = CCMenu:createWithItem(infoItem);
    infoItem:setScale(0.8)
    infoMenu:setPosition(ccp(570+25,310-15));
    -- infoMenu:setPosition(ccp(570,310));
    infoMenu:setTouchPriority(-(self.layerNum-1)*20-6);
    self.bgLayer:addChild(infoMenu,21);
    -- if G_isIphone5()==false then
    --     infoMenu:setPosition(ccp(570,self.bgLayer:getContentSize().height-720+spacey));
    -- end

    -- local function callBuff(object,name,tag)
    --     allianceWarBidDialog:createWithBuffId(tag,self.layerNum+1)
    -- end
    
    -- local scale=0.7
    -- for i=1,SizeOfTable(allianceWar2Cfg.buffSkill),1 do
    --     local bid="b"..i
    --     local iconSp=LuaCCSprite:createWithSpriteFrameName(allianceWar2Cfg.buffSkill[bid].icon,callBuff)
    --     iconSp:setPosition(ccp(370+(i-1)*iconSp:getContentSize().width*scale,80));
    --     iconSp:setTouchPriority(-(self.layerNum-1)*20-2);
    --     self.bgLayer:addChild(iconSp)
    --     iconSp:setScale(scale)
    --     iconSp:setTag(i)
        
    --     local lvTip=CCSprite:createWithSpriteFrameName("IconLevel.png")
    --     local lvLb=GetTTFLabel(allianceWar2VoApi:getBattlefieldUser()[bid],30)
    --     self.tipLvTb[bid]=lvLb
    --     lvLb:setPosition(ccp(lvTip:getContentSize().width/2,lvTip:getContentSize().height/2))
    --     lvTip:setScale(0.6)
    --     lvTip:addChild(lvLb)
    --     lvTip:setPosition(ccp(15,iconSp:getContentSize().height-10))
    --     iconSp:addChild(lvTip)
    -- end
    
    -- local maskSpHeight=self.bgLayer:getContentSize().height-133
    -- for k=1,3 do
    --     local leftMaskSp=CCSprite:createWithSpriteFrameName("maskBgLeftUse.png")
    --     leftMaskSp:setAnchorPoint(ccp(0,0))
    --     -- leftMaskSp:setPosition(0,pos.y+25)
    --     leftMaskSp:setPosition(0,38)
    --     leftMaskSp:setScaleY(maskSpHeight/leftMaskSp:getContentSize().height)
    --     self.bgLayer:addChild(leftMaskSp,6)

    --     local rightMaskSp=CCSprite:createWithSpriteFrameName("maskBgLeftUse.png")
    --     -- rightMaskSp:setRotation(180)
    --     rightMaskSp:setFlipX(true)
    --     rightMaskSp:setAnchorPoint(ccp(0,0))
    --     -- rightMaskSp:setPosition(self.bgLayer:getContentSize().width-rightMaskSp:getContentSize().width,pos.y+25)
    --     rightMaskSp:setPosition(self.bgLayer:getContentSize().width-rightMaskSp:getContentSize().width,38)
    --     rightMaskSp:setScaleY(maskSpHeight/rightMaskSp:getContentSize().height)
    --     self.bgLayer:addChild(rightMaskSp,6)
    -- end

    local downH=170
    -- local downH=225-65
    -- local warBgSp=GraySprite:create("scene/world_map_mi.jpg")
    -- local warBgSp=CCSprite:create("scene/world_map_mi.jpg")
    local warBgSp=CCSprite:create("public/serverWarLocal/serverWarLocalMapBg.jpg")
    warBgSp:setAnchorPoint(ccp(0.5,1))
    -- warBgSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-warBgSp:getContentSize().height/2-downH))
    warBgSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-downH))
    self.bgLayer:addChild(warBgSp)
    -- warBgSp:setScale(0.9)
    warBgSp:setScale(mapScale)

    -- -- local warBgSp=GraySprite:create("scene/world_map_mi.jpg")
    -- -- local warBgSp=CCSprite:create("scene/world_map_mi.jpg")
    -- local warBgSp=CCSprite:create("public/serverWarLocal/serverWarLocalMapBg.jpg")
    -- warBgSp:setAnchorPoint(ccp(0.5,1))
    -- -- warBgSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-warBgSp:getContentSize().height/2-downH-warBgSp:getContentSize().height*0.85))
    -- warBgSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-downH-warBgSp:getContentSize().height*mapScale))
    -- self.bgLayer:addChild(warBgSp)
    -- -- warBgSp:setScale(0.9)
    -- warBgSp:setScale(mapScale)

    local function callHold(object,name,tag)
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if (battleScene and battleScene.isBattleing==true) then
            do return end
        end
        PlayEffect(audioCfg.mouseClick)

        if allianceWar2VoApi:getSelfOid()>0 then
            local hid="h"..allianceWar2VoApi:getSelfOid()
            -- local str1= getlocal(allianceWar2Cfg.stronghold[hid].name)
            -- local str2=allianceWar2Cfg.stronghold[hid].winPoint

            -- local str3=allianceWar2VoApi:getBattlefieldUser().b3*allianceWar2Cfg.buffSkill.b3.per*100

            -- smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,500),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("isCollectionResouce",{str1,str2,str3}),nil,self.layerNum+1)
            local function regroupHandler()
                self:refreshFlag()
            end
            allianceSmallDialog:showCityDialog("PanelHeaderPopup.png",CCSizeMake(550,450),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allianceWar2_troops_collecting"),true,self.layerNum+1,hid,regroupHandler)
            do
                return
            end
        end
        if allianceWar2VoApi:checkInWar()==false then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("backstage4010"),nil,self.layerNum+1)
            do
                return
            end
        end

        local function sure()

            -- local isCanBattle=allianceWar2VoApi:isCanBattle()
            -- if isCanBattle==false then
            --     smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("alliance_war_no_joinOrStandby"),nil,self.layerNum+1)
            --     do return end
            -- end
            
            if self:isHaveTroops()==false then
   
                do
                    return
                end
            end

            local isCD,time=allianceWar2VoApi:getBattlefieldUserCDTime()
            -- print("isCD,time",isCD,time)
            if isCD then
                -- smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("backstage4006"),nil,self.layerNum+1)
                local cdgem=allianceWar2VoApi:getCDGems(time)
                local function buycd()
                    local function callback(fn,data)
                        local cresult,retTb=base:checkServerData(data)
                        if cresult==true then
                            -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allianceWar_killCD"),30)
                            --减金币
                            local gemnum=playerVoApi:getGems()-cdgem
                            playerVoApi:setGems(gemnum)
                            
                            if self:isHaveTroops()==false then
                                do
                                    return
                                end
                            end
                            self:atk(tag)
                        end
                    end
                    socketHelper:alliancewarnewBuycdtime(callback)
                end
                local cdgem=allianceWar2VoApi:getCDGems(time)
                smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buycd,getlocal("dialog_title_prompt"),getlocal("allianceWar_cdFight",{cdgem}),nil,self.layerNum+1)
                do
                    return
                end
            end

            self:atk(tag)
        end
        local hid="h"..(tag-200)
        local str1= getlocal(allianceWar2Cfg.stronghold[hid].name)
        smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),sure,getlocal("dialog_title_prompt"),getlocal("isAtkCity",{str1}),nil,self.layerNum+1)

    end

    local spScale=1
    -- for i=1,SizeOfTable(allianceWar2Cfg.stronghold),1 do
    for i=SizeOfTable(allianceWar2Cfg.stronghold),1,-1 do
        local hid="h"..i
        local height=0
        if G_isIphone5() then
            height=90--170
        end
        height=height+spacey+40
        local iconSp=LuaCCSprite:createWithSpriteFrameName(allianceWar2Cfg.stronghold[hid].icon,callHold)
        iconSp:setPosition(ccp(allianceWar2Cfg.stronghold[hid].x,allianceWar2Cfg.stronghold[hid].y+height));
        iconSp:setTouchPriority(-(self.layerNum-1)*20-2);
        self.bgLayer:addChild(iconSp,3)
        iconSp:setTag(200+i)
        iconSp:setScale(spScale)
        
        -- local allianceWarPoint = allianceWar2Cfg.stronghold[hid].winPoint/10
        -- local iconNameStr="IconLevel_Circle.png"
        -- if allianceWarPoint==7 then
        --     iconNameStr="IconLevel.png"
        -- elseif allianceWarPoint==10 then
        --     iconNameStr="IconLevel_Angle.png"
        -- end
        -- local lvTip=CCSprite:createWithSpriteFrameName(iconNameStr)
        -- local lvLb=GetTTFLabel(i,30)
        -- lvLb:setPosition(ccp(lvTip:getContentSize().width/2,lvTip:getContentSize().height/2))
        -- lvTip:setScale(0.8)
        -- lvTip:addChild(lvLb)
        -- lvTip:setPosition(ccp(iconSp:getContentSize().width/2,iconSp:getContentSize().height-10))
        -- iconSp:addChild(lvTip)
        
        -- local iconWarTip=CCSprite:createWithSpriteFrameName("ProductTankDialog.png")
        -- iconWarTip:setPosition(ccp(iconSp:getContentSize().width/2+50,iconSp:getContentSize().height-10))
        -- iconSp:addChild(iconWarTip)

        local bgPx,bgPy=iconSp:getContentSize().width/2,-10
        for k=1,3 do
            local lbBg
            if k==1 then
                lbBg=LuaCCScale9Sprite:createWithSpriteFrameName("alien_mines_allybg.png", CCRect(15,8,153,28),function()end)
            elseif k==2 then
                lbBg=LuaCCScale9Sprite:createWithSpriteFrameName("serverWarLocal_bg1.png",CCRect(10,10,10,10),function()end)
                lbBg:setVisible(false)
            else
                lbBg=LuaCCScale9Sprite:createWithSpriteFrameName("serverWarLocal_bg3.png",CCRect(10,10,10,10),function()end)
                lbBg:setVisible(false)
            end
            -- if (i%3)+1==k then
            --     lbBg:setVisible(true)
            -- end
            lbBg:setContentSize(CCSizeMake(80,35))
            lbBg:setPosition(ccp(bgPx,bgPy))
            iconSp:addChild(lbBg)
            lbBg:setScale(1/spScale)
            lbBg:setTag(i*1000+k)
        end

        local redFlagSp=CCSprite:createWithSpriteFrameName("awRedFlag.png")
        redFlagSp:setPosition(ccp(bgPx-60,bgPy))
        iconSp:addChild(redFlagSp)
        redFlagSp:setTag(i*10000+1)
        redFlagSp:setVisible(false)
        local blueFlagSp=CCSprite:createWithSpriteFrameName("awBlueFlag.png")
        blueFlagSp:setPosition(ccp(bgPx-60,bgPy))
        iconSp:addChild(blueFlagSp)
        blueFlagSp:setTag(i*10000+2)
        blueFlagSp:setVisible(false)
        
        local lvLb=GetTTFLabel("Lv."..i,25)
        lvLb:setPosition(ccp(bgPx,bgPy))
        iconSp:addChild(lvLb,1)
        lvLb:setScale(1/spScale)
    end


    -- self.warTime=allianceWar2VoApi:getLeftWarTime()
    -- self.warTimeLb=GetTTFLabel("",30)
    -- self.warTimeLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-260+spacey))
    -- self.bgLayer:addChild(self.warTimeLb,10)
    -- local warTimestr=G_getTimeStr(self.warTime,1)
    -- self.warTimeLb:setString(getlocal("costTime1",{warTimestr}))
    -- --self.warTimeLb:setColor(G_ColorOrange)

    self.statusLbBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),function ()end)
    self.statusLbBg:setContentSize(CCSizeMake(180,90))
    self.statusLbBg:ignoreAnchorPointForPosition(false)
    self.statusLbBg:setAnchorPoint(ccp(0.5,0.5))
    self.statusLbBg:setTouchPriority(-(self.layerNum-1)*20-1)
    self.statusLbBg:setPosition(ccp(lbPosx,80+spacey+lbSpaceh))
    self.bgLayer:addChild(self.statusLbBg)
    self.statusLbBg:setOpacity(180)

    self:refreshFlag()
    self:refreshAtk()
    

    self.isStratTick=true

    self:initChat()
end

function allianceWar2Tab1Dialog:atk(tag)
     local function callback(fn,data)
        local cresult,retTb=base:checkServerData(data)
        if cresult==true then   
            local reporttb=retTb.data.alliancewar.report
            -- if retTb.data~=nil and retTb.data.alliancewar~=nil and reporttb~=nil and reporttb[16]~=nil and type(reporttb[16])=="table" and SizeOfTable(reporttb[16])>0 then
            local hid=tag-200
            
            
            if retTb.data~=nil and retTb.data.alliancewar~=nil and reporttb~=nil and type(reporttb)=="table" and SizeOfTable(reporttb)>0 then
                local dateTb={}
                local dateTb1={}
                dateTb.data=dateTb1
                dateTb.data.report=retTb.data.alliancewar.report
                dateTb.isFuben=true
                -- dateTb.isInAllianceWar=true
                if allianceWar2Cfg.stronghold and allianceWar2Cfg.stronghold["h"..hid] and allianceWar2Cfg.stronghold["h"..hid].lanform then
                    dateTb.landform=allianceWar2Cfg.stronghold["h"..hid].lanform
                end
                battleScene:initData(dateTb)
            end

            self:refreshFlag()
            -- tankVoApi:clearTanksTbByType(31)
        end

    end
    local atkTb=tankVoApi:getTanksTbByType(31)
    -- if allianceWar2VoApi:getIsAutoSupplement()==true then
    --     atkTb=tankVoApi:getBestTankTb()

    --     local isEableAttack=true
	   --  local num=0;
	   --  for k,v in pairs(atkTb) do
	   --      if SizeOfTable(v)==0 then
	   --          num=num+1;
	   --      end
	   --  end
	   --  if num==6 or SizeOfTable(atkTb)==0 then
	   --      isEableAttack=false
	   --  end
	   --  if isEableAttack==false then
	   --  	smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("allianceWar_noTroops"),nil,self.layerNum+1,nil)

    --         do
    --             return
    --         end
	   --  end 

    -- end
    -- local hTb=nil
    -- if heroVoApi:isHaveTroops() then
    --     hTb = heroVoApi:getMachiningHeroList(atkTb)
    -- end
    -- print("ppp=",heroVoApi:isHaveTroops())

    local hTb=heroVoApi:getAllianceWar2HeroList()
    local isHasHeros=false
    for k,v in pairs(hTb) do
        if SizeOfTable(atkTb[k])==0 then
            hTb[k]=0
        end
    end
    for k,v in pairs(hTb) do
        if v and type(v)=="string" and v~=0 then
            isHasHeros=true
        end
    end
    -- print("isHasHeros",isHasHeros)
    if isHasHeros==false then
        hTb=nil
    end

    local aitroops=AITroopsFleetVoApi:getAllianceWar2AITroopsList()
    local isHasAITroops=false
    for k,v in pairs(aitroops) do
        if SizeOfTable(atkTb[k])==0 then
            aitroops[k]=0
        end
    end
    for k,v in pairs(aitroops) do
        if v and v~=0 and v~="" then
            isHasAITroops=true
        end
    end
    -- print("isHasAITroops",isHasAITroops)
    if isHasAITroops==false then
        aitroops=nil
    end
    socketHelper:alliancewarnewBattle(tag-200,allianceWar2VoApi:getTargetCity(),0,atkTb,callback,hTb,aitroops)
end

function allianceWar2Tab1Dialog:isHaveTroops()
    local isEableAttack=true
    local num=0;
    -- print("hasTroops")
    -- G_dayin(tankVoApi:getTanksTbByType(31))
    for k,v in pairs(tankVoApi:getTanksTbByType(31)) do
        if SizeOfTable(v)==0 then
            num=num+1;
        end
    end
    -- print("num",num)
    if num==6 then
        isEableAttack=false
    end
    -- print("isEableAttack",isEableAttack)
    -- if isEableAttack==false and allianceWar2VoApi:getIsAutoSupplement()==false then
    if isEableAttack==false then
        local function onGotoTab3()
            -- print("~~~~~~~~~~~~~~~~~")
            -- self.parent:tabClick(2)
        end
        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("allianceWarNoArmy"),nil,self.layerNum+1,nil,onGotoTab3)
    end

    -- if allianceWar2VoApi:getIsAutoSupplement()==true then
    --     isEableAttack=true
    -- end

    return isEableAttack
end


function allianceWar2Tab1Dialog:initChat()
    local function chatHandler()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if (battleScene and battleScene.isBattleing==true) then
            do return end
        end

        if newGuidMgr:isNewGuiding()==true then
            do return end
        end
        --判断是否有工会
        local isHasAlliance=allianceVoApi:isHasAlliance()
        if isHasAlliance then
            chatVoApi:showChatDialog(self.layerNum+1,1)
        else
            chatVoApi:showChatDialog(self.layerNum+1)
        end
    end
    
    self.m_chatBtn=GetButtonItem("mainBtnChat.png","mainBtnChat_Down.png","mainBtnChat_Down.png",chatHandler,nil,nil,nil)
    -- self.m_chatBg=LuaCCScale9Sprite:createWithSpriteFrameName("mainChatBgSmall.png",CCRect(10,10,5,5),chatHandler)
    self.m_chatBg=LuaCCScale9Sprite:createWithSpriteFrameName("mainChatBg.png",CCRect(10,10,5,5),chatHandler)
    
    local sspaceh=10
    -- local scaleX=(G_VisibleSizeWidth-40)/(self.m_chatBtn:getContentSize().width/2+self.m_chatBg:getContentSize().width+5)
    local scaleX=1
    self.m_chatBtn:setAnchorPoint(ccp(1,0))
    local chatSpriteMenu=CCMenu:createWithItem(self.m_chatBtn)
    chatSpriteMenu:setPosition(ccp(G_VisibleSizeWidth,122-sspaceh))
    chatSpriteMenu:setTouchPriority(-(self.layerNum-1)*20-6)
    self.bgLayer:addChild(chatSpriteMenu,11)
    self.m_chatBtn:setScaleX(scaleX)
    
    self.m_chatBg:setAnchorPoint(ccp(0,0))
    self.m_chatBg:setIsSallow(false)
    self.m_chatBg:setTouchPriority(-(self.layerNum-1)*20-6)
    self.m_chatBg:setPosition(ccp(0,125-sspaceh))
    self.bgLayer:addChild(self.m_chatBg,11)
    self.m_chatBg:setScaleX(scaleX)

    self:setLastChat(true)
end

function allianceWar2Tab1Dialog:setLastChat(isShow)
    if isShow==true or chatVoApi:getHasNewData(10)==true then
        local chatVo=chatVoApi:getLast(3)
        if chatVo and chatVo.subType then
            local typeStr,color,icon=chatVoApi:getTypeStr(chatVo.subType)

            local sizeSp=36
            if icon and self.m_chatBg then
                if self.m_labelLastType then
                    self.m_labelLastType:removeFromParentAndCleanup(true)
                    self.m_labelLastType=nil
                end
                self.m_labelLastType = CCSprite:createWithSpriteFrameName(icon)
                local typeScale=sizeSp/self.m_labelLastType:getContentSize().width
                self.m_labelLastType:setAnchorPoint(ccp(0.5,0.5))
                self.m_labelLastType:setPosition(ccp(5+sizeSp/2,self.m_chatBg:getContentSize().height/2))
                self.m_chatBg:addChild(self.m_labelLastType,2)
                self.m_labelLastType:setScale(typeScale)
            end
            
            local nameStr=chatVoApi:getNameStr(chatVo.type,chatVo.subType,chatVo.senderName,chatVo.reciverName,chatVo.sender)
            --nameStr=nameStr..":"
            if nameStr~=nil and nameStr~="" and chatVo.type<=3 and chatVo.contentType~=3 then
                nameStr=nameStr..":"
                if self.m_labelLastName then
                    self.m_labelLastName:setString(nameStr)
                    if color then
                       self.m_labelLastName:setColor(color)
                    end
                else
                    self.m_labelLastName=GetTTFLabel(nameStr,30)
                    self.m_labelLastName:setAnchorPoint(ccp(0,0.5))
                    self.m_labelLastName:setPosition(ccp(5+sizeSp,self.m_chatBg:getContentSize().height/2))
                    self.m_chatBg:addChild(self.m_labelLastName,2)
                    if color then
                       self.m_labelLastName:setColor(color)
                    end
                end
            end
            
            local message=chatVo.content
            if message==nil then
                message=""
            end
            local msgFont=nil
            --处理ios表情在安卓不显示问题
            if G_isIOS()==false then
                if platCfg.platCfgSameServerWithIos[G_curPlatName()] then
                    local tmpTb={}
                    tmpTb["action"]="EmojiConv"
                    tmpTb["parms"]={}
                    tmpTb["parms"]["str"]=tostring(message)
                    local cjson=G_Json.encode(tmpTb)
                    message=G_accessCPlusFunction(cjson)
                    msgFont=G_EmojiFontSrc
                end
            end

            local xPos=sizeSp+5
            if self.m_labelLastName and chatVo.type<=3 then
                if chatVo.contentType==3 then
                    --self.m_labelLastName:setString(nameStr)
                    self.m_labelLastName:setString("")
                else
                    xPos=xPos+self.m_labelLastName:getContentSize().width
                end
            end
            --local tmpLb=GetTTFLabel(message,30)
            if self.m_labelLastMsg then
                self.m_labelLastMsg:setString(message)
                if msgFont then
                    self.m_labelLastMsg:setFontName(msgFont)
                end
            else
                --self.m_labelLastMsg=GetTTFLabel(message,30)
                self.m_labelLastMsg=GetTTFLabelWrap(message,30,CCSizeMake(self.m_chatBg:getContentSize().width-100,35),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,msgFont)
                self.m_labelLastMsg:setAnchorPoint(ccp(0,0.5))
                self.m_labelLastMsg:setPosition(ccp(xPos,self.m_chatBg:getContentSize().height/2))
                self.m_chatBg:addChild(self.m_labelLastMsg,2)
            end

            self.m_labelLastMsg:setDimensions(CCSize(self.m_chatBg:getContentSize().width-xPos-50,40))
            if chatVo.contentType and chatVo.contentType==2 then --战报
                self.m_labelLastMsg:setColor(G_ColorYellow)
            else
                self.m_labelLastMsg:setColor(color)
            end
            self.m_labelLastMsg:setPosition(ccp(xPos,self.m_chatBg:getContentSize().height/2))
  
        end
        chatVoApi:setNoNewData(10)
    end
end


function allianceWar2Tab1Dialog:refreshAtk()
    local isCD,time=allianceWar2VoApi:getBattlefieldUserCDTime()
    -- print("isCD,time~~~",isCD,time)
    -- print("allianceWar2VoApi:getSelfOid()",allianceWar2VoApi:getSelfOid())
    if allianceWar2VoApi:getStatus(allianceWar2VoApi.targetCity)==20 then
        self:isState(4)
    elseif isCD==true then
        self:isState(1)
        local cdTimeStr=G_getTimeStr(time,1)
        self.regroupLabel1=tolua.cast(self.regroupLabel1,"CCLabelTTF")
        self.regroupLabel1:setString(getlocal("allianceWarCD"))
        self.regroupTimeLabel1:setString(cdTimeStr)
    elseif allianceWar2VoApi:getSelfOid()~=0 then
        self:isState(2)
    else
        self:isState(3)
    end
end

function allianceWar2Tab1Dialog:refreshFlag()

    for k,v in pairs(allianceWar2VoApi:getBattlefield()) do
        self:setHoldState(v,self.bgLayer,200+tonumber(RemoveFirstChar(k)))
    end
end

function allianceWar2Tab1Dialog:setHoldState(sign,object,tag)
    local bgsp=object:getChildByTag(tag)
    -- local flageName="IconWarBlueFlage.png"
    -- if sign==1 then
    --     flageName="IconWarRedFlage.png"
    -- elseif sign==2 then
    --     flageName="IconWarBlueFlage.png"
    -- end
    -- G_removeFlicker(bgsp)

    if bgsp:getChildByTag(10)~=nil then
        bgsp:getChildByTag(10):removeFromParentAndCleanup(true)
    end
    if sign~=0 then
        local hid=tag-200
        local positionInfo=allianceWar2VoApi:getPositionInfo("h"..hid)
        if positionInfo and positionInfo.pic then
            -- local photoSp = playerVoApi:getPersonPhotoSp(positionInfo.pic)
            local personPhotoName=playerVoApi:getPersonPhotoName(positionInfo.pic)
            local photoSp = playerVoApi:GetPlayerBgIcon(personPhotoName)
            if photoSp then
                local iconWarTip=CCSprite:createWithSpriteFrameName("ProductTankDialog.png")
                iconWarTip:setPosition(ccp(bgsp:getContentSize().width/2,bgsp:getContentSize().height-10))
                iconWarTip:setTag(10)
                bgsp:addChild(iconWarTip,10)
                iconWarTip:setScale(0.8)
                photoSp:setPosition(ccp(iconWarTip:getContentSize().width/2,iconWarTip:getContentSize().height/2+5))
                iconWarTip:addChild(photoSp,3)
                -- photoSp:setScale(0.85)
            end
        end
        -- if allianceWar2VoApi:getSelfOid()==tag-200 then
        --     G_addFlicker(bgsp,4,4)
        --     iconWarTip:setScale(1.5)
        -- end
    end

    local index=(tag-200)
    for i=1,3 do
        local lbBg=bgsp:getChildByTag(1000*index+i)
        if lbBg then
            if i==sign+1 then
                lbBg:setVisible(true)
            else
                lbBg:setVisible(false)
            end
        end
    end
    local redFlagSp=bgsp:getChildByTag(index*10000+1)
    local blueFlagSp=bgsp:getChildByTag(index*10000+2)
    if redFlagSp and blueFlagSp then
        if sign==1 then
            redFlagSp:setVisible(true)
            blueFlagSp:setVisible(false)
        elseif sign==2 then
            redFlagSp:setVisible(false)
            blueFlagSp:setVisible(true)
        else
            redFlagSp:setVisible(false)
            blueFlagSp:setVisible(false)
        end
    end
end

function allianceWar2Tab1Dialog:isState(state)
    if state==1 then
        self.regroupLabel1:setVisible(true)
        self.regroupTimeLabel1:setVisible(true)
        self.menuAccelerate1:setVisible(true)
        self.regroupLabel2:setVisible(false)
        self.menuAccelerate2:setVisible(false)
        self.regroupLabel3:setVisible(false)
        -- self.warTimeLb:setVisible(true)
        -- self.cdLabel:setVisible(false)
        -- self.timeLb:setVisible(false)
        self.touchDialogBg:setVisible(false)
        self.touchDialogBg:setPosition(ccp(10000,0))
        self.statusLbBg:setVisible(true)
    elseif state==2 then
        self.regroupLabel1:setVisible(false)
        self.regroupTimeLabel1:setVisible(false)
        self.menuAccelerate1:setVisible(false)
        self.regroupLabel2:setVisible(false)
        self.menuAccelerate2:setVisible(true)
        self.regroupLabel3:setVisible(false)
        -- self.warTimeLb:setVisible(true)
        -- self.cdLabel:setVisible(false)
        -- self.timeLb:setVisible(false)
        self.touchDialogBg:setVisible(false)
        self.touchDialogBg:setPosition(ccp(10000,0))
        self.statusLbBg:setVisible(false)
    elseif state==3 then
        self.regroupLabel1:setVisible(false)
        self.regroupTimeLabel1:setVisible(false)
        self.menuAccelerate1:setVisible(false)
        self.regroupLabel2:setVisible(false)
        self.menuAccelerate2:setVisible(false)
        self.regroupLabel3:setVisible(false)
        -- self.warTimeLb:setVisible(true)
        -- self.cdLabel:setVisible(false)
        -- self.timeLb:setVisible(false)
        self.touchDialogBg:setVisible(false)
        self.touchDialogBg:setPosition(ccp(10000,0))
        self.statusLbBg:setVisible(false)
    elseif state==4 then
        self.regroupLabel1:setVisible(false)
        self.regroupTimeLabel1:setVisible(false)
        self.menuAccelerate1:setVisible(false)
        self.regroupLabel2:setVisible(false)
        self.menuAccelerate2:setVisible(false)
        self.regroupLabel3:setVisible(false)
        -- self.warTimeLb:setVisible(false)
        -- self.cdLabel:setVisible(true)
        -- self.timeLb:setVisible(true)
        self.touchDialogBg:setVisible(true)
        self.statusLbBg:setVisible(false)
    end

end

function allianceWar2Tab1Dialog:tick()
    -- print("self.isStratTick",self.isStratTick)
    if self.isStratTick==false then
        do
            return
        end
    end

    if self.touchDialogBg and self.timeLb then
        if self.tmpTime>=10 then
            self.timeLb:setVisible(true)
            local timestr=G_getTimeStr(self.tmpTime)
            self.timeLb=tolua.cast(self.timeLb,"CCLabelTTF")
            self.timeLb:setString(timestr)
            self.tmpTime=self.tmpTime-1

            if self.numSp then
                self.numSp:setVisible(false)
            end
        else
            self.timeLb:setVisible(false)
             
            if self.numSp then
                self.numSp:setVisible(false)
            end
            -- print("self.tmpTime",self.tmpTime)
            if self.tmpTime>0 then
                if self.numSp then
                    self.numSp:removeFromParentAndCleanup(true)
                end
                local px,py=self.timeLb:getPosition()
                local num=self.tmpTime%10
                -- print("num",num)
                self.numSp=CCSprite:createWithSpriteFrameName("numb_"..num..".png")
                self.numSp:setPosition(ccp(px,py))
                self.touchDialogBg:addChild(self.numSp,20)
            end
            self.tmpTime=self.tmpTime-1
        end
    end

    -- if allianceWar2VoApi:getLeftWarTime()>0 then
    --     self.warTime=allianceWar2VoApi:getLeftWarTime()
    --     local timestr=G_getTimeStr(self.warTime,1)
    --     self.warTimeLb=tolua.cast(self.warTimeLb,"CCLabelTTF")
    --     self.warTimeLb:setString(getlocal("costTime1",{timestr}))
    --     self.warTime=self.warTime-1
    -- end

    
    if G_isRefreshAllianceWar then
        self:refreshFlag()
        G_isRefreshAllianceWar=false
    end

    for k,v in pairs(self.tipLvTb) do
        v=tolua.cast(v,"CCLabelTTF")
        v:setString(allianceWar2VoApi:getBattlefieldUser()[k])
    end
    
    self:refreshAtk()

    self:setLastChat()
end

--用户处理特殊需求,没有可以不写此方法
function allianceWar2Tab1Dialog:doUserHandler()

end

function allianceWar2Tab1Dialog:dispose()
    self.numSp=nil
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil;
    self.layerNum=nil;
    self.touchLayer=nil
end