allianceWarTab3Dialog={

}

function allianceWarTab3Dialog:new(parent)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.leftBtn=nil
    self.expandIdx={}
    self.parent=parent
    self.bgLayer=nil;
    self.timeLb=nil;
    self.isCD=false
    self.regroupLabel1=nil
    self.menuAccelerate1=nil
    
    self.regroupLabel2=nil
    self.menuAccelerate2=nil
    
    self.regroupLabel3=nil
    self.menuAccelerate3=nil
    self.backLb1=nil
    self.backLb2=nil
    self.applyTypeSp=nil

    return nc
end



function allianceWarTab3Dialog:init(layerNum)
    self.bgLayer=CCLayer:create();
    self.layerNum=layerNum;
    self:initTabLayer();
    
    return self.bgLayer
end

function allianceWarTab3Dialog:initTabLayer()
    
    local rect = CCRect(0, 0, 50, 50);
    local capInSet = CCRect(40, 40, 10, 10);
    local capInSetNew=CCRect(20, 20, 10, 10)
    local function cellClick1(hd,fn,idx)

    end

    local width=600
    if base.heroSwitch==1 then
        width=480
    end
    local backSprieHeight,fontSize,backSpriePosY = 60,26,self.bgLayer:getContentSize().height-275
    if G_getIphoneType() == G_iphone4 then
        backSprieHeight,fontSize,backSpriePosY = 40,18,self.bgLayer:getContentSize().height-265
    end
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfItemBg.png",capInSetNew,cellClick1)
    backSprie:setContentSize(CCSizeMake(width, backSprieHeight))
    backSprie:setAnchorPoint(ccp(0,0.5))
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-42)
    backSprie:setPosition(ccp(20,backSpriePosY))
    self.bgLayer:addChild(backSprie,1)
    
    local backSprie1 =LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfItemBg.png",capInSetNew,cellClick1)
    backSprie1:setContentSize(CCSizeMake(width, backSprieHeight))
    backSprie1:setAnchorPoint(ccp(0,0.5))
    backSprie1:setIsSallow(false)
    backSprie1:setTouchPriority(-42)
    backSprie1:setPosition(ccp(20,backSpriePosY-backSprieHeight))
    self.bgLayer:addChild(backSprie1,1)
    
    local stateStr=""
    local isCD,time=allianceWarVoApi:getBattlefieldUserCDTime()
    if isCD==true then
        stateStr=getlocal("allianceWarState2")
    elseif allianceWarVoApi:getSelfOid()~=0 then
        stateStr=getlocal("allianceWarState3")
    else
        stateStr=getlocal("allianceWarState1")
    end
    
    self.backLb1 = GetTTFLabel(getlocal("allianceWarCurrentStatus",{stateStr}),fontSize);
    self.backLb1:setPosition(ccp(backSprie:getContentSize().width/2,backSprie:getContentSize().height/2));
    backSprie:addChild(self.backLb1,2);
    
    local areaName=getlocal("alliance_info_content")
    if allianceWarVoApi:getSelfOid()>0 then
        local str="h"..allianceWarVoApi:getSelfOid()
        areaName=getlocal(allianceWarCfg.stronghold[str].name)
    end

    self.backLb2 = GetTTFLabel(getlocal("allianceWarOccupiedAreas",{areaName}),fontSize);
    self.backLb2:setPosition(ccp(backSprie1:getContentSize().width/2,backSprie1:getContentSize().height/2));
    backSprie1:addChild(self.backLb2,2);

    local tHeight,troopLayerPosY = G_VisibleSize.height-380,G_VisibleSize.height - 370
    if G_getIphoneType() == G_iphone4 then
        tHeight,troopLayerPosY = G_VisibleSize.height-340,G_VisibleSize.height - 340
    end

    G_addSelectTankLayer(4,self.bgLayer,self.layerNum,nil,nil,nil,nil,nil,troopLayerPosY)
    
    local textSize = 26
    if G_curPlatName()=="androidzhongshouyouru" or G_curPlatName()=="12" or G_curPlatName()=="0" or G_curPlatName()=="testServer" then
        textSize = 20
    end
    local soldiersLb = GetTTFLabel(getlocal("player_leader_troop_num",{playerVoApi:getTroopsLvNum()}),textSize);
    soldiersLb:setAnchorPoint(ccp(0,0.5));
    soldiersLb:setPosition(ccp(40,tHeight-10));
    self.bgLayer:addChild(soldiersLb,2);
    
    local soldiersLbNum = GetTTFLabel("+"..playerVoApi:getExtraTroopsNum(),textSize);
    soldiersLbNum:setColor(G_ColorGreen)
    soldiersLbNum:setAnchorPoint(ccp(0,0.5));
    soldiersLbNum:setPosition(ccp(soldiersLb:getPositionX()+soldiersLb:getContentSize().width,tHeight-10));
    self.bgLayer:addChild(soldiersLbNum,2);

    local bestFightLb = GetTTFLabel(getlocal("allianceWar_bestFight"),textSize);
    bestFightLb:setAnchorPoint(ccp(1,0.5));
    bestFightLb:setPosition(ccp(self.bgLayer:getContentSize().width-30,tHeight-10));
    self.bgLayer:addChild(bestFightLb,2);

    local function touch1()
        if self.applyTypeSp:isVisible() then
            self.applyTypeSp:setVisible(false)
            allianceWarVoApi:setIsAutoSupplement(false)
        else
            self.applyTypeSp:setVisible(true)
            allianceWarVoApi:setIsAutoSupplement(true)
        end
    end
    local sscale = 0.9
    if G_getIphoneType() == G_iphone4 then
        sscale = 0.6
    end
    local typeSp1=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",touch1)
    typeSp1:setAnchorPoint(ccp(1,0.5));
    typeSp1:setTouchPriority(-(self.layerNum-1)*20-4);
    typeSp1:setScale(sscale)
    typeSp1:setPosition(self.bgLayer:getContentSize().width-35-bestFightLb:getContentSize().width,tHeight-10)
    self.bgLayer:addChild(typeSp1,2)

    self.applyTypeSp=CCSprite:createWithSpriteFrameName("LegionCheckBtn.png");
    self.applyTypeSp:setPosition(getCenterPoint(typeSp1))
    self.applyTypeSp:setScale(sscale)
    typeSp1:addChild(self.applyTypeSp)
    if allianceWarVoApi:getIsAutoSupplement()==false then
        self.applyTypeSp:setVisible(false)
    end
    
    local btnPosY = 80
    if G_getIphoneType() == G_iphone4 then
        btnPosY = 60
    end

    local isCD,time=allianceWarVoApi:getBattlefieldUserCDTime()
    local cdTimeStr=G_getTimeStr(time,1)
    self.regroupLabel1=GetTTFLabel(getlocal("allianceWarCD"),23)
    self.regroupLabel1:setAnchorPoint(ccp(0,0))
    self.regroupLabel1:setPosition(40,btnPosY)
    self.bgLayer:addChild(self.regroupLabel1)
    
    self.regroupTimeLabel1=GetTTFLabel(cdTimeStr,23)
    self.regroupTimeLabel1:setAnchorPoint(ccp(0,0.5))
    self.regroupTimeLabel1:setPosition(40,btnPosY - self.regroupTimeLabel1:getContentSize().height)
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
                    self:refreshAtk()
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allianceWar_killCD"),30)
                    --减金币
                end

            end
            socketHelper:alliancewarBuycdtime(callback)
        
        end

        smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),accelerate,getlocal("dialog_title_prompt"),getlocal("accelerateGroupDesc",{cdgem}),nil,self.layerNum+1)

    end

    local accelerateBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",touch,1,getlocal("accelerateGroup"),25)
    self.menuAccelerate1=CCMenu:createWithItem(accelerateBtn)
    self.menuAccelerate1:setAnchorPoint(ccp(0,0))
    self.menuAccelerate1:setPosition(ccp(250,btnPosY))
    self.menuAccelerate1:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(self.menuAccelerate1,1)
    
    self.regroupLabel2=GetTTFLabelWrap(getlocal("regroup2"),25,CCSizeMake(130,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.regroupLabel2:setAnchorPoint(ccp(0,0.5))
    self.regroupLabel2:setPosition(35,btnPosY)
    self.bgLayer:addChild(self.regroupLabel2)
    
    local function touch2()
        local function accelerate()
            local function callback(fn,data)
                local cresult,retTb=base:checkServerData(data)
                if cresult==true then
                    tankVoApi:clearTanksTbByType(6)
                    self:clearTouchSp()
                    self:refreshAtk()
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
    self.menuAccelerate2:setPosition(ccp(250,btnPosY))
    self.menuAccelerate2:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(self.menuAccelerate2,1)
    self.regroupLabel2:setVisible(false)
    self.menuAccelerate2:setVisible(false)
    
    self.regroupLabel3=GetTTFLabelWrap(getlocal("allianceWarState1"),25,CCSizeMake(125,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.regroupLabel3:setAnchorPoint(ccp(0,0.5))
    self.regroupLabel3:setPosition(40,btnPosY)
    self.bgLayer:addChild(self.regroupLabel3)
    
    local function touch3()
        self.parent:tabClick(0)
    end
    
    local accelerateBtn3=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",touch3,1,getlocal("returnWarField"),25)
    self.menuAccelerate3=CCMenu:createWithItem(accelerateBtn3)
    self.menuAccelerate3:setAnchorPoint(ccp(0,0))
    self.menuAccelerate3:setPosition(ccp(250,btnPosY))
    self.menuAccelerate3:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(self.menuAccelerate3,1)
    self.regroupLabel3:setVisible(false)
    self.menuAccelerate3:setVisible(false)
    


end

function allianceWarTab3Dialog:clearTouchSp()
    local isEableAttack=true
    local num=0;
    for k,v in pairs(tankVoApi:getTanksTbByType(4)) do
        if SizeOfTable(v)==0 then
            num=num+1;
        end
    end
    if num==6 then
        for i=1,6,1 do
            local spA=self.bgLayer:getChildByTag(i):getChildByTag(2)
            if spA~=nil then
                spA:removeFromParentAndCleanup(true)
            end
        end
    end
    if allianceWarVoApi:getSelfOid()>0 then
        local defenseTanks=tankVoApi:getTanksTbByType(6)
         for k,v in pairs(defenseTanks) do
            local sp=self.bgLayer:getChildByTag(k)
            if v[1]~=nil and v[2]~=nil then
                tankVoApi:setTanksByType(4,k,v[1],v[2])
                G_addTouchSp(4,sp,v[1],v[2],self.layerNum,self.bgLayer,1)
            end
         end
    end


end



function allianceWarTab3Dialog:addTouchSp(parent,id,num)

    local function touchSpAdd()
        PlayEffect(audioCfg.mouseClick)
        if allianceWarVoApi:getSelfOid()>0 then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage4008"),30)

            do
                return
            end
        end
        tankVoApi:deleteTanksTbByType(4,parent:getTag())
        local spA=parent:getChildByTag(2)
        spA:removeFromParentAndCleanup(true)
        
    end
    local addLayer=CCLayer:create();
    parent:addChild(addLayer)
    addLayer:setTag(2)
    
    local capInSet = CCRect(20, 20, 10, 10);
    local touchSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,touchSpAdd)
    touchSp:setContentSize(CCSizeMake(parent:getContentSize().width, parent:getContentSize().height))
    --local scX=parent:getContentSize().width/touchSp:getContentSize().width
    --local scY=parent:getContentSize().height/touchSp:getContentSize().height
    --touchSp:setScaleX(scX)
    --touchSp:setScaleY(scY)
    touchSp:setPosition(getCenterPoint(parent))
    touchSp:setTouchPriority(-(self.layerNum-1)*20-3)
    touchSp:setIsSallow(true)
    --touchSp:setOpacity(0)
    addLayer:addChild(touchSp)
    
    local spAdd=LuaCCSprite:createWithSpriteFrameName(tankCfg[id].icon,touchSpAdd);
    spAdd:setScale(0.6)
    spAdd:setAnchorPoint(ccp(0,0.5));
    spAdd:setIsSallow(true)
    spAdd:setPosition(ccp(5,parent:getContentSize().height/2))
    spAdd:setTouchPriority(-(self.layerNum-1)*20-3)
    addLayer:addChild(spAdd)
    
    local spDelect=LuaCCSprite:createWithSpriteFrameName("IconFault.png",touchSpAdd);
    spDelect:setAnchorPoint(ccp(0.5,0.5));
    spDelect:setPosition(ccp(parent:getContentSize().width-40,40))
    addLayer:addChild(spDelect)
    
    local soldiersLbName = GetTTFLabelWrap(getlocal(tankCfg[id].name),22,CCSizeMake(210,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop);
    soldiersLbName:setAnchorPoint(ccp(0,1));
    soldiersLbName:setPosition(ccp(spAdd:getContentSize().width*0.6+5,parent:getContentSize().height/2+50));
    addLayer:addChild(soldiersLbName,2);
    
    local soldiersLbNum = GetTTFLabel(num,22);
    soldiersLbNum:setAnchorPoint(ccp(0,0.5));
    soldiersLbNum:setPosition(ccp(spAdd:getContentSize().width*0.6+10,parent:getContentSize().height/2-30));
    addLayer:addChild(soldiersLbNum,2);

end

function allianceWarTab3Dialog:isState(state)
    if state==1 then
        self.regroupLabel1:setVisible(true)
        self.regroupTimeLabel1:setVisible(true)
        self.menuAccelerate1:setVisible(true)
        self.regroupLabel2:setVisible(false)
        self.menuAccelerate2:setVisible(false)
        self.regroupLabel3:setVisible(false)
        self.menuAccelerate3:setVisible(false)
    elseif state==2 then
        self.regroupLabel1:setVisible(false)
        self.regroupTimeLabel1:setVisible(false)
        self.menuAccelerate1:setVisible(false)
        self.regroupLabel2:setVisible(true)
        self.menuAccelerate2:setVisible(true)
        self.regroupLabel3:setVisible(false)
        self.menuAccelerate3:setVisible(false)
    elseif state==3 then
        self.regroupLabel1:setVisible(false)
        self.regroupTimeLabel1:setVisible(false)
        self.menuAccelerate1:setVisible(false)
        self.regroupLabel2:setVisible(false)
        self.menuAccelerate2:setVisible(false)
        self.regroupLabel3:setVisible(true)
        self.menuAccelerate3:setVisible(true)
    elseif state==4 then
        self.regroupLabel1:setVisible(false)
        self.regroupTimeLabel1:setVisible(false)
        self.menuAccelerate1:setVisible(false)
        self.regroupLabel2:setVisible(false)
        self.menuAccelerate2:setVisible(false)
        self.regroupLabel3:setVisible(false)
        self.menuAccelerate3:setVisible(false)
    end

end
function allianceWarTab3Dialog:refreshAtk()
    local isCD,time=allianceWarVoApi:getBattlefieldUserCDTime()
    local stateStr=""
    
    local isCD,time=allianceWarVoApi:getBattlefieldUserCDTime()
    if allianceWarVoApi:getStatus(allianceWarVoApi.targetCity)==21 then
        self:isState(4)
    elseif isCD==true then
        self:isState(1)
        local cdTimeStr=G_getTimeStr(time,1)
        self.regroupLabel1=tolua.cast(self.regroupLabel1,"CCLabelTTF")
        self.regroupLabel1:setString(getlocal("allianceWarCD"))
        self.regroupTimeLabel1=tolua.cast(self.regroupTimeLabel1,"CCLabelTTF")
        self.regroupTimeLabel1:setString(cdTimeStr)
        stateStr=getlocal("allianceWarState2")
    elseif allianceWarVoApi:getSelfOid()~=0 then
        self:isState(2)
        stateStr=getlocal("allianceWarState3")
    else
        self:isState(3)
        stateStr=getlocal("allianceWarState1")
    end
    self.backLb1=tolua.cast(self.backLb1,"CCLabelTTF")
    self.backLb1:setString(getlocal("allianceWarCurrentStatus",{stateStr}))

    local areaName=getlocal("alliance_info_content")
    if allianceWarVoApi:getSelfOid()>0 then
        local str="h"..allianceWarVoApi:getSelfOid()
        areaName=getlocal(allianceWarCfg.stronghold[str].name)
    end
    self.backLb2=tolua.cast(self.backLb2,"CCLabelTTF")
    self.backLb2:setString(getlocal("allianceWarOccupiedAreas",{areaName}))
    
    
end


function allianceWarTab3Dialog:tick()
    
    self:refreshAtk()

end

--用户处理特殊需求,没有可以不写此方法
function allianceWarTab3Dialog:doUserHandler()

end

function allianceWarTab3Dialog:dispose()
    
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil;
    self.layerNum=nil;
    tankVoApi:clearTanksTbByType(4)
    
end