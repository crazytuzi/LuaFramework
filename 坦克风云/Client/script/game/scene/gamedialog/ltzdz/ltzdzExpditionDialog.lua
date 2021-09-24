ltzdzExpditionDialog = commonDialog:new()

function ltzdzExpditionDialog:new(layerNum,targetCid,startCid,targetCityTb,parent)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.layerNum=layerNum
    nc.targetCid=targetCid or 1 -- 目标城市
    nc.startCid=startCid -- 出发城市（算出征兵量）
    nc.targetCityTb=targetCityTb
    self.parent=parent
    return nc
end

function ltzdzExpditionDialog:resetTab()
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
	self.panelLineBg:setContentSize(CCSizeMake(620,G_VisibleSize.height-100))
    self.panelLineBg:setVisible(false)
    G_addCommonGradient(self.bgLayer,G_VisibleSizeHeight-80)
end

function ltzdzExpditionDialog:initTableView()
    local function troopChangeFunc(event,data)
        self:refreshLb(data)
    end
    self.troopChange=troopChangeFunc
    eventDispatcher:addEventListener("troops.change",troopChangeFunc)
end

function ltzdzExpditionDialog:doUserHandler()
    self.type=36
    local havaCityTb=ltzdzFightApi:getAllCityCanWalk(self.targetCityTb)

    self.line=ltzdzVoApi:shortPath_Dijkstra(self.startCid,self.targetCid,havaCityTb)

    -- self.marchTime=ltzdzFightApi:getMarchTime(self.line,self.targetCityTb[self.targetCid])

    G_addSelectTankLayer(self.type,self.bgLayer,self.layerNum,callback,nil,nil,nil,nil,nil,self.startCid)
    self.editLayer=G_editLayer[self.type]

    -- 目标
    local targetH=G_VisibleSizeHeight-105
    local function nilFunc()
    end
    local targetBg =LuaCCScale9Sprite:createWithSpriteFrameName("iconTitlebg.png",CCRect(27, 29, 2, 2),nilFunc)
    targetBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-60, 60))
    targetBg:setAnchorPoint(ccp(0.5,1))
    targetBg:setTouchPriority(-(self.layerNum-1)*20-1)
    targetBg:setPosition(G_VisibleSizeWidth/2,targetH)
    self.bgLayer:addChild(targetBg,1)


    local targetLb=GetTTFLabel(getlocal("ltzdz_target_idom")..ltzdzCityVoApi:getCityName(self.targetCid),25);
    targetLb:setAnchorPoint(ccp(0,0.5));
    targetLb:setPosition(ccp(10,targetBg:getContentSize().height/2))
    targetBg:addChild(targetLb)

    local powerLb=GetTTFLabel(getlocal("ltzdz_power_des") .. "" .. getlocal("alliance_scene_info_null"),25);
    powerLb:setAnchorPoint(ccp(0,0.5));
    powerLb:setPosition(ccp(targetBg:getContentSize().width/2+60,targetBg:getContentSize().height/2))
    targetBg:addChild(powerLb)

    local fontSize = 22
    local startX=45
    -- 消耗石油
    local oilLb=GetTTFLabelWrap(getlocal("ltzdz_consume_oil_num",{0}),fontSize,CCSizeMake(G_VisibleSizeWidth/2-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    self.bgLayer:addChild(oilLb)
    oilLb:setAnchorPoint(ccp(0,1))
    oilLb:setPosition(G_VisibleSizeWidth/2+20,G_VisibleSizeHeight-180)
    self.oilLb=oilLb

    -- 可出征
    local expeditionLb=GetTTFLabelWrap(getlocal("ltzdz_expedition_des",{0}),fontSize,CCSizeMake(G_VisibleSizeWidth/2-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    self.bgLayer:addChild(expeditionLb)
    expeditionLb:setAnchorPoint(ccp(0,1))
    expeditionLb:setPosition(startX,G_VisibleSizeHeight-220)
    self.expeditionLb=expeditionLb

    -- 消耗时间
    local timeLb=GetTTFLabelWrap(getlocal("ltzdz_consume_time_num",{}),fontSize,CCSizeMake(G_VisibleSizeWidth/2-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    self.bgLayer:addChild(timeLb)
    timeLb:setAnchorPoint(ccp(0,1))
    timeLb:setPosition(G_VisibleSizeWidth/2+20,G_VisibleSizeHeight-220)
    self.timeLb=timeLb

    self:refreshLb()


    -- 出征
    local btnH=60
    local function expenditionFunc()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if otherGuideMgr.isGuiding and otherGuideMgr.curStep==52 then
            otherGuideMgr:toNextStep()
        end
        local isEableAttack=true
        local num=0;
        for k,v in pairs(tankVoApi:getTanksTbByType(36)) do
            if SizeOfTable(v)==0 then
                num=num+1;
            end
        end
        if num==6 then
            isEableAttack=false
        end
        
        if isEableAttack==false then
            local function addFlicker()
                if self.addBtn then
                    G_addFlickerByTimes(self.addBtn,4.2,4.2,getCenterPoint(self.addBtn),3)
                end
            end
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("needFleet"),nil,9,nil,addFlicker)
            do
                return
            end
        end

        -- 只要不是友军的城就能走
        local flag=ltzdzFightApi:cityBelong(self.targetCid)
        if flag==2 then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("ltzdz_no_set_ally_city"),30)
            do return end
        end

        self:expenditionOperate()
    end
    local expenditionItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",expenditionFunc,nil,getlocal("ltzdz_expedition"),25/0.8)
    expenditionItem:setScale(0.8)
    local expenditionBtn=CCMenu:createWithItem(expenditionItem)
    expenditionBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    expenditionBtn:setPosition(ccp(G_VisibleSize.width/2+200,btnH))
    self.bgLayer:addChild(expenditionBtn,1)

    local function readCallback(tank,hero)
    end
    ltzdzFightApi:setCurStartCid(self.startCid)
    local formationMenu=G_getFormationBtn(self.bgLayer,self.layerNum,1,36,readCallback,ccp(G_VisibleSize.width * 0.5 - 200,btnH),nil,0.8)--阵型

    local mLine=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png",CCRect(34,1,1,1),function ()end)
    mLine:setPosition(ccp(G_VisibleSizeWidth/2,btnH+60))
    mLine:setContentSize(CCSizeMake(G_VisibleSizeWidth,mLine:getContentSize().height))
    self.bgLayer:addChild(mLine)

    otherGuideMgr:setGuideStepField(52,expenditionItem,true)
    if otherGuideMgr:checkGuide(51)==false and ltzdzVoApi:isQualifying()==true then
        otherGuideMgr:showGuide(51)
    end
end

function ltzdzExpditionDialog:expenditionOperate()

    local attackTb=tankVoApi:getTanksTbByType(self.type)

    local tankNum=ltzdzFightApi:getTankNumByTb(attackTb)
    local cityBelong=ltzdzFightApi:cityBelong(self.targetCid)
    local flag
    if cityBelong==1 then
        flag=2 -- 相当于运输
    else
        flag=1
    end
    self.marchTime=ltzdzFightApi:getMarchTime(self.line,cityBelong)
    local consumeOil=ltzdzFightApi:getMarchOil(tankNum,self.marchTime,flag)

    local _,oil=ltzdzFightApi:getMyRes()

    if oil<consumeOil then
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("ltzdz_oil_not_enough"),30)
        do return end
    end

    local htb = heroVoApi:getMachiningHeroList(attackTb)
    local aitroops = AITroopsFleetVoApi:getMatchAITroopsList(attackTb)
    local emblemID
    local planePos

    emblemID = emblemVoApi:getTmpEquip(self.type)
    planePos = planeVoApi:getTmpEquip(self.type)

    local flag=ltzdzFightApi:isUseDefense(self.startCid,attackTb,htb,emblemID,planePos,aitroops)

    local function expenditionFunc()
        local function refreshFunc()
            if self.parent then
                self.parent:removeSetOrTransport()
                -- self.parent:refreshMatchLine()
            end
            self:close()
            if otherGuideMgr:checkGuide(53)==false and ltzdzVoApi:isQualifying()==true then
                otherGuideMgr:showGuide(53)
            end
        end
        ltzdzFightApi:setTroopsSocket(refreshFunc,3,nil,self.startCid,attackTb,htb,emblemID,planePos,self.line,nil,aitroops)
    end
    if flag then
        G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("attackTankChangeDefence"),false,expenditionFunc,nil,nil)
    else
        expenditionFunc()
    end
end

function ltzdzExpditionDialog:refreshLb()
    local flag
    local cityBelong=ltzdzFightApi:cityBelong(self.targetCid)
    if cityBelong==1 then
        flag=2 -- 相当于运输
    else
        flag=1
    end

    local defenseTab=tankVoApi:getTanksTbByType(self.type)
    local tankNum=0
    for k,v in pairs(defenseTab) do
        if v and v[2] then
            tankNum=tankNum+v[2]
        end
    end
    self.marchTime=ltzdzFightApi:getMarchTime(self.line,cityBelong)
    local consumeOil=ltzdzFightApi:getMarchOil(tankNum,self.marchTime,flag)
    self.oilLb:setString(getlocal("ltzdz_consume_oil_num",{consumeOil}))

    local _,oilNum=ltzdzFightApi:getMyRes()
    if oilNum>consumeOil then
        self.oilLb:setColor(G_ColorWhite)
    else
        self.oilLb:setColor(G_ColorRed)
    end

    self.expeditionLb:setString(getlocal("ltzdz_expedition_des",{ltzdzFightApi:getCanUseTroopsNum(self.type,self.startCid)}))
    self.timeLb:setString(getlocal("ltzdz_consume_time_num",{self.marchTime}))
end

function ltzdzExpditionDialog:initUp(upTb)
  
end

function ltzdzExpditionDialog:initTroopLayer()
    
end


function ltzdzExpditionDialog:tick()
end

function ltzdzExpditionDialog:fastTick()  
end

function ltzdzExpditionDialog:dispose()
    if self.editLayer then
        self.editLayer:dispose()
        self.editLayer=nil
    end
    if self.troopChange then
        eventDispatcher:removeEventListener("troops.change",self.troopChange)
        self.troopChange=nil
    end
    self.targetCid=nil
    self.startCid=nil
    self.targetCityTb=nil
    self.layerNum=nil
    if self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
    end
    self.bgLayer=nil
    tankVoApi:clearTanksTbByType(self.type)
    ltzdzFightApi:clearHeroTbByType(self.type)
    ltzdzFightApi:clearAITroopsTbByType(self.type)
    self.type=nil

    self.oilLb=nil
    self.expeditionLb=nil
    self.timeLb=nil
end