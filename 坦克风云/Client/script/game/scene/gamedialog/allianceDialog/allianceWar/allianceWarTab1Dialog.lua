allianceWarTab1Dialog={

}

function allianceWarTab1Dialog:new(parent)
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
    
   
    return nc
end

function allianceWarTab1Dialog:init(layerNum)
    self.layerNum=layerNum;
    self.bgLayer=CCLayer:create();
    self:initTabLayer()
    --[[
    local function callback(fn,data)
        if base:checkServerData(data)==true then
            self:initTabLayer()


        end
    end
    socketHelper:alliancewarGet(allianceWarVoApi:getTargetCity(),callback)
    ]]
    
    return self.bgLayer
end

function allianceWarTab1Dialog:initStartLayer()

    
    
end

function allianceWarTab1Dialog:initTabLayer()


    local warBgSp=GraySprite:create("scene/world_map_mi.jpg")
    local wHeight=warBgSp:getContentSize().height*0.9*2
    local wWidth=warBgSp:getContentSize().width*0.9
    local function touchLuaSpr()

    end
    self.touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    self.touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-5)
    local rect=CCSizeMake(600,wHeight-15)
    self.touchDialogBg:setContentSize(rect)
    self.touchDialogBg:setAnchorPoint(ccp(0,1))
    self.touchDialogBg:setPosition(ccp(20,self.bgLayer:getContentSize().height-240))
    self.bgLayer:addChild(self.touchDialogBg,10);

    local cPoint=getCenterPoint(self.touchDialogBg)
    self.cdLabel = GetTTFLabel(getlocal("acCD"),40)
    self.cdLabel:setPosition(ccp(cPoint.x,cPoint.y+50))
    self.touchDialogBg:addChild(self.cdLabel,20)
    
    local zeroTime=G_getWeeTs(base.serverTime)
    local cityCfg=allianceWarVoApi.startWarTime[allianceWarVoApi:getTargetCity()]
    self.tmpTime=zeroTime+cityCfg[1]*3600+cityCfg[2]*60
    self.timeLb=GetTTFLabel("",40)
    self.timeLb:setPosition(ccp(cPoint.x,cPoint.y-50))
    self.touchDialogBg:addChild(self.timeLb,20)
    self.tmpTime=self.tmpTime-base.serverTime

    local timestr=G_getTimeStr(self.tmpTime,1)
    self.timeLb:setString(timestr)
    self.cdLabel:setColor(G_ColorOrange)
    self.timeLb:setColor(G_ColorOrange)


    local isCD,time=allianceWarVoApi:getBattlefieldUserCDTime()
    local cdTimeStr=G_getTimeStr(time,1)
    self.regroupLabel1=GetTTFLabel(getlocal("allianceWarCD"),23)
    self.regroupLabel1:setAnchorPoint(ccp(0,0))
    self.regroupLabel1:setPosition(40,80)
    self.bgLayer:addChild(self.regroupLabel1)

    self.regroupTimeLabel1=GetTTFLabel(cdTimeStr,23)
    self.regroupTimeLabel1:setAnchorPoint(ccp(0,0.5))
    self.regroupTimeLabel1:setPosition(40,55)
    self.bgLayer:addChild(self.regroupTimeLabel1)

    
    local function touch()
        local isCD,time=allianceWarVoApi:getBattlefieldUserCDTime()
        local cdgem=allianceWarVoApi:getCDGems(time)

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
                    local gemnum=playerVoApi:getGems()-cdgem
                    playerVoApi:setGems(gemnum)
                    --减金币
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allianceWar_killCD"),30)
                end

            end
            socketHelper:alliancewarBuycdtime(callback)
        
        end

        smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),accelerate,getlocal("dialog_title_prompt"),getlocal("accelerateGroupDesc",{cdgem}),nil,self.layerNum+1)

    end

    local accelerateBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",touch,1,getlocal("accelerateGroup"),25)
    self.menuAccelerate1=CCMenu:createWithItem(accelerateBtn)
    self.menuAccelerate1:setAnchorPoint(ccp(0,0))
    self.menuAccelerate1:setPosition(ccp(250,80))
    self.menuAccelerate1:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(self.menuAccelerate1,1)
    
    self.regroupLabel2=GetTTFLabelWrap(getlocal("regroup2"),25,CCSizeMake(130,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.regroupLabel2:setAnchorPoint(ccp(0,0.5))
    self.regroupLabel2:setPosition(35,80)
    self.bgLayer:addChild(self.regroupLabel2)
    
    local function touch2()
        local function accelerate()
            local function callback(fn,data)
                local cresult,retTb=base:checkServerData(data)
                if cresult==true then
                    self:refreshFlag()
                    tankVoApi:clearTanksTbByType(6)
                    tankVoApi:clearTanksTbByType(4)
                end

            end
            if allianceWarVoApi:getSelfOid()~=0 then
            
                print("allianceWarVoApi:getTargetCity()",allianceWarVoApi:getTargetCity())
            socketHelper:alliancewarRegroup(allianceWarVoApi:getSelfOid(),allianceWarVoApi:getTargetCity(),callback)
            end
        end
        smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),accelerate,getlocal("dialog_title_prompt"),getlocal("accelerateGroupDesc2",{200}),nil,self.layerNum+1)
    end

    local accelerateBtn2=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",touch2,1,getlocal("regroup1"),25)
    self.menuAccelerate2=CCMenu:createWithItem(accelerateBtn2)
    self.menuAccelerate2:setAnchorPoint(ccp(0,0))
    self.menuAccelerate2:setPosition(ccp(250,80))
    self.menuAccelerate2:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(self.menuAccelerate2,1)
    self.regroupLabel2:setVisible(false)
    self.menuAccelerate2:setVisible(false)
    
    self.regroupLabel3=GetTTFLabelWrap(getlocal("allianceWarState1"),25,CCSizeMake(125,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.regroupLabel3:setAnchorPoint(ccp(0,0.5))
    self.regroupLabel3:setPosition(40,80)
    self.bgLayer:addChild(self.regroupLabel3)
    self.regroupLabel3:setVisible(false)

    
    local function touchInfo()
        local td=smallDialog:new()
        local str1 = getlocal("allianceWarDesc1")
        local str2 = getlocal("allianceWarDesc2")
        local str3 = getlocal("allianceWarDesc3")
        local str4 = getlocal("allianceWarDesc4")
        local tabStr = {" ",str4,str3,str2,str1," "}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28)
        sceneGame:addChild(dialog,self.layerNum+1)
    end

    local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touchInfo,11,nil,nil)
    local infoMenu = CCMenu:createWithItem(infoItem);
    infoMenu:setPosition(ccp(570,self.bgLayer:getContentSize().height-800));
    infoMenu:setTouchPriority(-(self.layerNum-1)*20-6);
    self.bgLayer:addChild(infoMenu,21);
    if G_isIphone5()==false then
        infoMenu:setPosition(ccp(570,self.bgLayer:getContentSize().height-720));
    end

    local function callBuff(object,name,tag)
        allianceWarBidDialog:createWithBuffId(tag,self.layerNum+1)
    end
    
    local scale=0.7
    for i=1,SizeOfTable(allianceWarCfg.buffSkill),1 do
        local bid="b"..i
        local iconSp=LuaCCSprite:createWithSpriteFrameName(allianceWarCfg.buffSkill[bid].icon,callBuff)
        iconSp:setPosition(ccp(370+(i-1)*iconSp:getContentSize().width*scale,80));
        iconSp:setTouchPriority(-(self.layerNum-1)*20-2);
        self.bgLayer:addChild(iconSp)
        iconSp:setScale(scale)
        iconSp:setTag(i)
        
        local lvTip=CCSprite:createWithSpriteFrameName("IconLevel.png")
        local lvLb=GetTTFLabel(allianceWarVoApi:getBattlefieldUser()[bid],30)
        self.tipLvTb[bid]=lvLb
        lvLb:setPosition(ccp(lvTip:getContentSize().width/2,lvTip:getContentSize().height/2))
        lvTip:setScale(0.6)
        lvTip:addChild(lvLb)
        lvTip:setPosition(ccp(15,iconSp:getContentSize().height-10))
        iconSp:addChild(lvTip)
    end
    
    local maskSpHeight=self.bgLayer:getContentSize().height-133
    for k=1,3 do
        local leftMaskSp=CCSprite:createWithSpriteFrameName("maskBgLeftUse.png")
        leftMaskSp:setAnchorPoint(ccp(0,0))
        -- leftMaskSp:setPosition(0,pos.y+25)
        leftMaskSp:setPosition(0,38)
        leftMaskSp:setScaleY(maskSpHeight/leftMaskSp:getContentSize().height)
        self.bgLayer:addChild(leftMaskSp,6)

        local rightMaskSp=CCSprite:createWithSpriteFrameName("maskBgLeftUse.png")
        -- rightMaskSp:setRotation(180)
        rightMaskSp:setFlipX(true)
        rightMaskSp:setAnchorPoint(ccp(0,0))
        -- rightMaskSp:setPosition(self.bgLayer:getContentSize().width-rightMaskSp:getContentSize().width,pos.y+25)
        rightMaskSp:setPosition(self.bgLayer:getContentSize().width-rightMaskSp:getContentSize().width,38)
        rightMaskSp:setScaleY(maskSpHeight/rightMaskSp:getContentSize().height)
        self.bgLayer:addChild(rightMaskSp,6)
    end
    
    local downH=225
    local warBgSp=GraySprite:create("scene/world_map_mi.jpg")
    warBgSp:setAnchorPoint(ccp(0.5,0.5))
    warBgSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-warBgSp:getContentSize().height/2-downH))
    self.bgLayer:addChild(warBgSp,1)
    warBgSp:setScale(0.9)
    
    local warBgSp=GraySprite:create("scene/world_map_mi.jpg")
    warBgSp:setAnchorPoint(ccp(0.5,0.5))
    warBgSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-warBgSp:getContentSize().height/2-downH-warBgSp:getContentSize().height*0.85))
    self.bgLayer:addChild(warBgSp,1)
    warBgSp:setScale(0.9)

    local function callHold(object,name,tag)
        if allianceWarVoApi:getSelfOid()>0 then
            local hid="h"..allianceWarVoApi:getSelfOid()
            local str1= getlocal(allianceWarCfg.stronghold[hid].name)
            local str2=allianceWarCfg.stronghold[hid].winPoint

            local str3=allianceWarVoApi:getBattlefieldUser().b3*allianceWarCfg.buffSkill.b3.per*100

            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,500),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("isCollectionResouce",{str1,str2,str3}),nil,self.layerNum+1)
            do
                return
            end
        end
        if allianceWarVoApi:checkInWar()==false then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("backstage4010"),nil,self.layerNum+1)
            do
                return
            end
        end

        local function sure()

                local isCanBattle=allianceWarVoApi:isCanBattle()
                if isCanBattle==false then
                    smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("alliance_war_no_joinOrStandby"),nil,self.layerNum+1)
                    do return end
                end
                

                if self:isHaveTroops()==false then
       
                    do
                        return
                    end
                end

                local isCD,time=allianceWarVoApi:getBattlefieldUserCDTime()
                if isCD then
                    -- smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("backstage4006"),nil,self.layerNum+1)
                    local cdgem=allianceWarVoApi:getCDGems(time)
                    local function buycd()
                        local function callback(fn,data)
                            local cresult,retTb=base:checkServerData(data)
                            if cresult==true then
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allianceWar_killCD"),30)
                                local gemnum=playerVoApi:getGems()-cdgem
                                playerVoApi:setGems(gemnum)
                                --减金币
                                if self:isHaveTroops()==false then
                                    do
                                        return
                                    end
                                end
                                self:atk(tag)


                            end
                        end
                        socketHelper:alliancewarBuycdtime(callback)
                    end
                local cdgem=allianceWarVoApi:getCDGems(time)
                 smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buycd,getlocal("dialog_title_prompt"),getlocal("allianceWar_cdFight",{cdgem}),nil,self.layerNum+1)



                    do
                        return
                    end
                end

                self:atk(tag)
        end
        local hid="h"..(tag-200)
        local str1= getlocal(allianceWarCfg.stronghold[hid].name)
        smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),sure,getlocal("dialog_title_prompt"),getlocal("isAtkCity",{str1}),nil,self.layerNum+1)

    end

    for i=1,SizeOfTable(allianceWarCfg.stronghold),1 do
        local hid="h"..i
        local height=0
        if G_isIphone5() then
            height=170
        end
        local iconSp=LuaCCSprite:createWithSpriteFrameName(allianceWarCfg.stronghold[hid].icon,callHold)
        iconSp:setPosition(ccp(allianceWarCfg.stronghold[hid].x,allianceWarCfg.stronghold[hid].y+height));
        iconSp:setTouchPriority(-(self.layerNum-1)*20-2);
        self.bgLayer:addChild(iconSp,3)
        iconSp:setTag(200+i)
        iconSp:setScale(0.5)
        
        
        local allianceWarPoint = allianceWarCfg.stronghold[hid].winPoint/10
        local iconNameStr="IconLevel_Circle.png"
        if allianceWarPoint==7 then
            iconNameStr="IconLevel.png"
        elseif allianceWarPoint==10 then
            iconNameStr="IconLevel_Angle.png"
        end
        local lvTip=CCSprite:createWithSpriteFrameName(iconNameStr)

        local lvLb=GetTTFLabel(i,30)
        lvLb:setPosition(ccp(lvTip:getContentSize().width/2,lvTip:getContentSize().height/2))
        lvTip:setScale(0.8)
        lvTip:addChild(lvLb)
        lvTip:setPosition(ccp(iconSp:getContentSize().width/2,iconSp:getContentSize().height-10))
        iconSp:addChild(lvTip)
        
        local iconWarTip=CCSprite:createWithSpriteFrameName("IconWarNone.png")
        iconWarTip:setPosition(ccp(iconSp:getContentSize().width/2+50,iconSp:getContentSize().height-10))
        iconSp:addChild(iconWarTip)

    end


    self.warTime=allianceWarVoApi:getLeftWarTime()
    self.warTimeLb=GetTTFLabel("",30)
    self.warTimeLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-260))
    self.bgLayer:addChild(self.warTimeLb,10)
    local warTimestr=G_getTimeStr(self.warTime,1)
    self.warTimeLb:setString(getlocal("costTime1",{warTimestr}))
    --self.warTimeLb:setColor(G_ColorOrange)

    self:refreshFlag()
    self:refreshAtk()
    

    self.isStratTick=true

    self:initChat()
end

function allianceWarTab1Dialog:atk(tag)
     local function callback(fn,data)
        local cresult,retTb=base:checkServerData(data)
        if cresult==true then   
            local reporttb=retTb.data.alliancewar.report
            if retTb.data~=nil and retTb.data.alliancewar~=nil and reporttb~=nil and reporttb[16]~=nil and type(reporttb[16])=="table" and SizeOfTable(reporttb[16])>0 then
                local dateTb={}
                local dateTb1={}
                dateTb.data=dateTb1
                dateTb.data.report=retTb.data.alliancewar.report[16]
                dateTb.isFuben=true
                dateTb.isInAllianceWar=true
                battleScene:initData(dateTb)
            end

            self:refreshFlag()
            tankVoApi:clearTanksTbByType(4)
        end

    end
    local atkTb=tankVoApi:getTanksTbByType(4)
    if allianceWarVoApi:getIsAutoSupplement()==true then
        atkTb=tankVoApi:getBestTankTb()

        local isEableAttack=true
	    local num=0;
	    for k,v in pairs(atkTb) do
	        if SizeOfTable(v)==0 then
	            num=num+1;
	        end
	    end
	    if num==6 or SizeOfTable(atkTb)==0 then
	        isEableAttack=false
	    end
	    if isEableAttack==false then
	    	smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("allianceWar_noTroops"),nil,self.layerNum+1,nil)

            do
                return
            end
	    end 

    end
    local hTb=nil
    if heroVoApi:isHaveTroops() then
        hTb = heroVoApi:getMachiningHeroList(atkTb)
    end
    print("ppp=",heroVoApi:isHaveTroops())
    socketHelper:alliancewarBattle(tag-200,allianceWarVoApi:getTargetCity(),0,atkTb,callback,hTb)

end

function allianceWarTab1Dialog:isHaveTroops()
    local isEableAttack=true
    local num=0;
    for k,v in pairs(tankVoApi:getTanksTbByType(4)) do
        if SizeOfTable(v)==0 then
            num=num+1;
        end
    end
    if num==6 then
        isEableAttack=false
    end
    if isEableAttack==false and allianceWarVoApi:getIsAutoSupplement()==false then
        local function onGotoTab3()
            self.parent:tabClick(2)
        end
        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("allianceWarNoArmy"),nil,self.layerNum+1,nil,onGotoTab3)
    end

    if allianceWarVoApi:getIsAutoSupplement()==true then
        isEableAttack=true
    end

    return isEableAttack
end


function allianceWarTab1Dialog:initChat()
    local function chatHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
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
    
    local scaleX=(G_VisibleSizeWidth-40)/(self.m_chatBtn:getContentSize().width/2+self.m_chatBg:getContentSize().width+5)

    self.m_chatBtn:setAnchorPoint(ccp(1,0))
    local chatSpriteMenu=CCMenu:createWithItem(self.m_chatBtn)
    chatSpriteMenu:setPosition(ccp(G_VisibleSizeWidth-20,122))
    chatSpriteMenu:setTouchPriority(-(self.layerNum-1)*20-6)
    self.bgLayer:addChild(chatSpriteMenu,11)
    self.m_chatBtn:setScaleX(scaleX)
    
    self.m_chatBg:setAnchorPoint(ccp(0,0))
    self.m_chatBg:setIsSallow(false)
    self.m_chatBg:setTouchPriority(-(self.layerNum-1)*20-6)
    self.m_chatBg:setPosition(ccp(20,125))
    self.bgLayer:addChild(self.m_chatBg,11)
    self.m_chatBg:setScaleX(scaleX)

    self:setLastChat(true)
end

function allianceWarTab1Dialog:setLastChat(isShow)
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


function allianceWarTab1Dialog:refreshAtk()
    local isCD,time=allianceWarVoApi:getBattlefieldUserCDTime()
    if allianceWarVoApi:getStatus(allianceWarVoApi.targetCity)==21 then
        self:isState(4)
    elseif isCD==true then
        self:isState(1)
        local cdTimeStr=G_getTimeStr(time,1)
        self.regroupLabel1=tolua.cast(self.regroupLabel1,"CCLabelTTF")
        self.regroupLabel1:setString(getlocal("allianceWarCD"))
        self.regroupTimeLabel1:setString(cdTimeStr)
    elseif allianceWarVoApi:getSelfOid()~=0 then
        self:isState(2)
    else
        self:isState(3)
    end
end

function allianceWarTab1Dialog:refreshFlag()

    for k,v in pairs(allianceWarVoApi:getBattlefield()) do
        self:setHoldState(v,self.bgLayer,200+tonumber(RemoveFirstChar(k)))
    end
end

function allianceWarTab1Dialog:setHoldState(sign,object,tag)
    local bgsp=object:getChildByTag(tag)
    local flageName="IconWarBlueFlage.png"
    if sign==1 then
        flageName="IconWarRedFlage.png"
    elseif sign==2 then
        flageName="IconWarBlueFlage.png"
    end
    G_removeFlicker(bgsp)

    if bgsp:getChildByTag(10)~=nil then
        bgsp:getChildByTag(10):removeFromParentAndCleanup(true)
    end
    if sign~=0 then
       local iconWarTip=CCSprite:createWithSpriteFrameName(flageName)
        iconWarTip:setPosition(ccp(bgsp:getContentSize().width/2+50,bgsp:getContentSize().height-10))
        iconWarTip:setTag(10)
        bgsp:addChild(iconWarTip)
        if allianceWarVoApi:getSelfOid()==tag-200 then
            G_addFlicker(bgsp,4,4)
            iconWarTip:setScale(1.5)
        end
    end

end

function allianceWarTab1Dialog:isState(state)
    if state==1 then
        self.regroupLabel1:setVisible(true)
        self.regroupTimeLabel1:setVisible(true)
        self.menuAccelerate1:setVisible(true)
        self.regroupLabel2:setVisible(false)
        self.menuAccelerate2:setVisible(false)
        self.regroupLabel3:setVisible(false)
        self.warTimeLb:setVisible(true)
        -- self.cdLabel:setVisible(false)
        -- self.timeLb:setVisible(false)
        self.touchDialogBg:setVisible(false)
        self.touchDialogBg:setPosition(ccp(10000,0))
    elseif state==2 then
        self.regroupLabel1:setVisible(false)
        self.regroupTimeLabel1:setVisible(false)
        self.menuAccelerate1:setVisible(false)
        self.regroupLabel2:setVisible(true)
        self.menuAccelerate2:setVisible(true)
        self.regroupLabel3:setVisible(false)
        self.warTimeLb:setVisible(true)
        -- self.cdLabel:setVisible(false)
        -- self.timeLb:setVisible(false)
        self.touchDialogBg:setVisible(false)
        self.touchDialogBg:setPosition(ccp(10000,0))
    elseif state==3 then
        self.regroupLabel1:setVisible(false)
        self.regroupTimeLabel1:setVisible(false)
        self.menuAccelerate1:setVisible(false)
        self.regroupLabel2:setVisible(false)
        self.menuAccelerate2:setVisible(false)
        self.regroupLabel3:setVisible(true)
        self.warTimeLb:setVisible(true)
        -- self.cdLabel:setVisible(false)
        -- self.timeLb:setVisible(false)
        self.touchDialogBg:setVisible(false)
        self.touchDialogBg:setPosition(ccp(10000,0))
    elseif state==4 then
        self.regroupLabel1:setVisible(false)
        self.regroupTimeLabel1:setVisible(false)
        self.menuAccelerate1:setVisible(false)
        self.regroupLabel2:setVisible(false)
        self.menuAccelerate2:setVisible(false)
        self.regroupLabel3:setVisible(flase)
        self.warTimeLb:setVisible(false)
        -- self.cdLabel:setVisible(true)
        -- self.timeLb:setVisible(true)
        self.touchDialogBg:setVisible(true)
    end

end

function allianceWarTab1Dialog:tick()
    if self.isStratTick==false then
        do
            return
        end
    end

    if self.tmpTime>0 then
        local timestr=G_getTimeStr(self.tmpTime,1)
        self.timeLb=tolua.cast(self.timeLb,"CCLabelTTF")
        self.timeLb:setString(timestr)
        self.tmpTime=self.tmpTime-1
    end

    if allianceWarVoApi:getLeftWarTime()>0 then
        self.warTime=allianceWarVoApi:getLeftWarTime()
        local timestr=G_getTimeStr(self.warTime,1)
        self.warTimeLb=tolua.cast(self.warTimeLb,"CCLabelTTF")
        self.warTimeLb:setString(getlocal("costTime1",{timestr}))
        self.warTime=self.warTime-1
    end

    
    if G_isRefreshAllianceWar then
        self:refreshFlag()
        G_isRefreshAllianceWar=false

    end

    for k,v in pairs(self.tipLvTb) do
        v=tolua.cast(v,"CCLabelTTF")
        v:setString(allianceWarVoApi:getBattlefieldUser()[k])
    end
    
    self:refreshAtk()

    self:setLastChat()
end

--用户处理特殊需求,没有可以不写此方法
function allianceWarTab1Dialog:doUserHandler()

end

function allianceWarTab1Dialog:dispose()
    
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil;
    self.layerNum=nil;
    
end