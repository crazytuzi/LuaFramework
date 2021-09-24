ltzdzTroopDialog = commonDialog:new()

function ltzdzTroopDialog:new(layerNum,cid,pCallback)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.layerNum=layerNum
    nc.cid=cid
    nc.pCallback=pCallback -- 父类刷新回调
    nc.flag=false -- 是否部署过新的部队
    return nc
end

function ltzdzTroopDialog:resetTab()
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
	self.panelLineBg:setContentSize(CCSizeMake(620,G_VisibleSize.height-100))
    self.panelLineBg:setVisible(false)
    G_addCommonGradient(self.bgLayer,G_VisibleSizeHeight-80)
end

function ltzdzTroopDialog:initTableView( )
    self.closeBtn:setVisible(false)
    local function close()
        PlayEffect(audioCfg.mouseClick)  
        self:closeCheck(1)
         
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
    closeBtnItem:setPosition(0, 0)
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))

    local closeBtn = CCMenu:createWithItem(closeBtnItem)
    closeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    closeBtn:setPosition(ccp(G_VisibleSize.width-closeBtnItem:getContentSize().width,G_VisibleSize.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(closeBtn)


    local function troopChangeFunc(event,data)
        self:refreshReserve(data)
    end
    self.troopChange=troopChangeFunc
    eventDispatcher:addEventListener("troops.change",troopChangeFunc)
end

function ltzdzTroopDialog:doUserHandler()
    ltzdzVoApi:addOrRemoveOpenDialog(1,"ltzdzTroopDialog",self)

    self.type=35
    self.tankD,self.heroD,self.emblemID,self.planePos,self.defAITroops=ltzdzFightApi:getDefenceByCid(self.cid)
    -- print("self.emblemID",self.emblemID)
    for k,v in pairs(self.tankD) do
        local tid=v[1]
        local num=v[2]
        tankVoApi:setTanksByType(self.type,k,tid,num)
    end
    for k,v in pairs(self.heroD) do
        heroVoApi:setTroopsByPos(k,v,self.type)
    end
    for k,v in pairs(self.defAITroops) do
        AITroopsFleetVoApi:setAITroopsByPos(k, v, self.type)
    end

    -- 部队
    G_addSelectTankLayer(self.type,self.bgLayer,self.layerNum,callback,nil,nil,nil,nil,nil,self.cid)
    self.editLayer=G_editLayer[self.type]

    self:refreshReserve()



    -- 快速补充
    local tid="t1"
    local tValue=ltzdzFightApi:getTvalueByTid(tid)
    local supplyItem
    local btnLb
    local function supplyFunc()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local function refreshFunc()
            local useNum=ltzdzFightApi:getUseNumByTid(tid)
            btnLb:setString("(" .. useNum .. "/" .. tValue.limit .. ")")
            supplyItem:setEnabled(not ltzdzFightApi:isRitchLimit(useNum,tValue.limit))
            self:refreshReserve()
        end
        local strnameStr=ltzdzVoApi:getStratagemInfoById(tid)
        ltzdzFightApi:showMarchAcc(self.layerNum+1,true,true,refreshFunc,getlocal("ltzdz_use_ploy"),nil,getlocal("ltzdz_use_acc_des4",{strnameStr,tValue.effc}),tid,self.cid)
    end

    supplyItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",supplyFunc,nil,getlocal("ltzdz_fast_supply"),25/0.8)
    local supplyScale=0.8
    supplyItem:setScale(supplyScale)
    local supplyBtn=CCMenu:createWithItem(supplyItem)
    supplyBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    supplyBtn:setPosition(ccp(G_VisibleSize.width-120,G_VisibleSize.height-160))
    self.bgLayer:addChild(supplyBtn,1)

    -- local propNum=ltzdzFightApi:getPropNumByTid("t1")
    
    local useNum=ltzdzFightApi:getUseNumByTid("t1")
    btnLb=GetTTFLabel("(" .. useNum .. "/" .. tValue.limit .. ")",22)
    supplyItem:addChild(btnLb)
    btnLb:setScale(1/supplyScale)
    btnLb:setPosition(supplyItem:getContentSize().width/2,supplyItem:getContentSize().height+10)
    btnLb:setAnchorPoint(ccp(0.5,0))
    supplyItem:setEnabled(not ltzdzFightApi:isRitchLimit(useNum,tValue.limit))

    -- 部署
    local btnH2=150

    local arrangeLb=GetTTFLabelWrap(getlocal("ltzdz_arrange_des"),25,CCSizeMake(560,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.bgLayer:addChild(arrangeLb)
    arrangeLb:setPosition(G_VisibleSizeWidth/2,btnH2+60)

    local btnScale1=0.6
    local function arrangeFunc()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        if self:isTroopsChanged(true) then
            self:arrangeTroops()
        else
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("arrange_nochange_troops_tip"),30)
        end
    end
    local arrangeItem=GetButtonItem("newGrayBtn2.png","newGrayBtn2_Down.png","newGreenBtn2.png",arrangeFunc,nil,getlocal("arrange_name"),22/btnScale1)
    arrangeItem:setScale(btnScale1)
    local arrangeBtn=CCMenu:createWithItem(arrangeItem)
    arrangeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    arrangeBtn:setPosition(ccp(G_VisibleSize.width * 0.865,btnH2))
    self.bgLayer:addChild(arrangeBtn,1)
    otherGuideMgr:setGuideStepField(47,nil,true,{arrangeItem,2})

    -- 解散
    local function disbanFunc()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        -- 解散
        eventDispatcher:dispatchEvent("ltzdz.disban",{})
        
    end
    local disbanItem=GetButtonItem("newGrayBtn2.png","newGrayBtn2_Down.png","newGreenBtn2.png",disbanFunc,nil,getlocal("ltzdz_disban"),22/btnScale1)
    disbanItem:setScale(btnScale1)
    local disbanBtn=CCMenu:createWithItem(disbanItem)
    disbanBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    disbanBtn:setPosition(ccp(G_VisibleSize.width * 0.135,btnH2))
    self.bgLayer:addChild(disbanBtn,1)

    local mLine=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png",CCRect(34,1,1,1),function ()end)
    mLine:setPosition(ccp(G_VisibleSizeWidth/2,110))
    mLine:setContentSize(CCSizeMake(G_VisibleSizeWidth,mLine:getContentSize().height))
    self.bgLayer:addChild(mLine)

    local function readCallback(tank,hero)
    end
    ltzdzFightApi:setCurStartCid(self.cid)
    local formationMenu=G_getFormationBtn(self.bgLayer,self.layerNum,1,35,readCallback,ccp(G_VisibleSize.width * 0.38,btnH2),nil,btnScale1)--阵型

    -- 运输
    local btnH=60
    local function transportFunc()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        -- 判断队列是否够
        local targetCityTb=ltzdzFightApi:getTargetCityTb(2,self.cid)

        local flagNum=0
        for k,v in pairs(targetCityTb) do
            if v==1 then
                flagNum=1
                break
            end
        end

        if flagNum==0 then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("ltzdz_no_transport_city"),30)
            do return end
        end

        local data={}
        data.bType=2
        data.targetCityTb=targetCityTb
        data.startCid=self.cid
        eventDispatcher:dispatchEvent("ltzdz.setOrTransport",data)

        self:closeCheck()  
    end
    local transportItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",transportFunc,nil,getlocal("ltzdz_transport"),25/0.8)
    transportItem:setScale(0.8)
    local transportBtn=CCMenu:createWithItem(transportItem)
    transportBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    transportBtn:setPosition(ccp(G_VisibleSize.width/2-150,btnH))
    self.bgLayer:addChild(transportBtn,1)

    -- 出征
    local function expenditionFunc()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        -- 判断队列是否够
        local targetCityTb=ltzdzFightApi:getTargetCityTb(1,self.cid)

        local data={}
        data.bType=1
        data.targetCityTb=targetCityTb
        data.startCid=self.cid
        eventDispatcher:dispatchEvent("ltzdz.setOrTransport",data)

        self:closeCheck() 
    end
    local expenditionItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",expenditionFunc,nil,getlocal("ltzdz_expedition"),25/0.8)
    expenditionItem:setScale(0.8)
    local expenditionBtn=CCMenu:createWithItem(expenditionItem)
    expenditionBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    expenditionBtn:setPosition(ccp(G_VisibleSize.width/2+150,btnH))
    self.bgLayer:addChild(expenditionBtn,1)

    otherGuideMgr:setGuideStepField(48,expenditionItem,true)
    --如果是定级赛则开始出征城市的引导
    if ltzdzVoApi:isQualifying()==true then
        if otherGuideMgr:checkGuide(47)==false then
            otherGuideMgr:showGuide(47)
        end
    end
end

function ltzdzTroopDialog:refreshReserve()
    if self.reserveLb then
        self.reserveLb:removeFromParentAndCleanup(true)
    end

    if self.defenceLb then
        self.defenceLb:removeFromParentAndCleanup(true)
    end
    
    local reserveNum=ltzdzFightApi:getCanUseTroopsNum(self.type,self.cid)

    local colorTab={nil,G_ColorYellowPro,nil}
    local posX=45
    local fontSize=22

    local reserveStr=""
    -- cid
    local mapCfg=ltzdzVoApi:getMapCfg()
    local cType=mapCfg.citycfg[self.cid].type
    local mapVo=ltzdzFightApi.mapVo or {}
    local cityVo=mapVo.city or {}
    local clv=ltzdzFightApi:getCityLevel(self.cid,cityVo)

    local reserveLimit=ltzdzFightApi:getReserveLimit(cType,clv)
    local lbHeight
    reserveStr=getlocal("ltzdz_reserve",{reserveNum .. "/" .. "<rayimg>" .. reserveLimit .. "<rayimg>"})
    self.reserveLb,lbHeight=G_getRichTextLabel(reserveStr,colorTab,fontSize,G_VisibleSizeWidth-200,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    self.reserveLb:setAnchorPoint(ccp(0,1))
    self.reserveLb:setPosition(ccp(posX,G_VisibleSizeHeight-139))
    self.bgLayer:addChild(self.reserveLb,2)

    local warCfg=ltzdzVoApi:getWarCfg()
    local nbLimit=warCfg.realArmyLimit*reserveLimit
    print("nbLimit",nbLimit)
    if reserveNum>nbLimit then
        reserveNum=nbLimit
    end
    local defenseStr=getlocal("ltzdz_city_defense_reserve",{reserveNum .. "/" .. "<rayimg>" .. nbLimit .. "<rayimg>"})
    self.defenceLb=G_getRichTextLabel(defenseStr,colorTab,fontSize,G_VisibleSizeWidth-200,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    self.defenceLb:setAnchorPoint(ccp(0,1))
    self.defenceLb:setPosition(ccp(posX,G_VisibleSizeHeight-170))
    self.bgLayer:addChild(self.defenceLb,2)

end

function ltzdzTroopDialog:arrangeTroops(clickClose)

    local defenseTab=tankVoApi:getTanksTbByType(self.type)
    local htb = heroVoApi:getMachiningHeroList(defenseTab)
    local hasTroops=heroVoApi:isHaveTroops()
    local emblemID
    local planePos

    if hasTroops==false then
        htb=nil
    end
    local _,slotNum=ltzdzFightApi:getTankNumByTb(defenseTab)
    if slotNum~=0 then
        emblemID = emblemVoApi:getTmpEquip(self.type)
        planePos = planeVoApi:getTmpEquip(self.type)
    end
    --AI部队
    local aitroops = AITroopsFleetVoApi:getMatchAITroopsList(defenseTab)

    local haveAITroops = AITroopsFleetVoApi:isHaveAITroops()
    if haveAITroops==false then
        aitroops=nil
    end

    local function refreshFunc()
        self.tankD,self.heroD,self.emblemID,self.planePos,self.defAITroops=ltzdzFightApi:getDefenceByCid(self.cid)
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("arrange_troops_success"),30)

        local num=0
        for i=1,6 do
            if self.tankD[i][1]==nil then
                num=num+1
            end
        end
        if num==6 then
            eventDispatcher:dispatchEvent("ltzdz.disban",{})
        end
        self.flag=true

        self:refreshParentOprate(clickClose)
        
        
    end
    ltzdzFightApi:setTroopsSocket(refreshFunc,1,nil,self.cid,defenseTab,htb,emblemID,planePos,nil,nil,aitroops)
end

-- 问文清  其实当没有坦克部署时，其它发生改变实际上是不变的
-- flag true 部署的时候检查数量，其它不检测
function ltzdzTroopDialog:isTroopsChanged(flag)

    local isChange=false
    local defenseTab=tankVoApi:getTanksTbByType(self.type)

    -- 判断坦克是否发生变化
    local nilNum=0
    for i=1,6 do
        if self.tankD[i][1]==defenseTab[i][1] then
            if flag then
                if self.tankD[i][2]==defenseTab[i][2] then
                else
                    return true
                end
            end
            if self.tankD[i][1]==nil then
                nilNum=nilNum+1
            end
        else
            return true
        end
    end
    -- if nilNum==6 then
    --     return false
    -- end

    -- 判断英雄是否发生变化
    local htb = heroVoApi:getTroopsHeroList()
    -- heroVoApi:getMachiningHeroList(defenseTab)
    for i=1,6 do
        local hid1=htb[i] or 0
        local hid2=self.heroD[i] or 0
        -- print("++++++i,hid1,hid2",i,hid1,hid2)
        if hid1==hid2 then
        else
            return true
        end
    end

    local aitroopsTb = AITroopsFleetVoApi:getAITroopsTb()
    for k=1,6 do
        local atid1 = aitroopsTb[k] or 0
        local atid2 = self.defAITroops[k] or 0
        if atid1~=atid2 then
            return true
        end
    end

    local emblemID1 = emblemVoApi:getTmpEquip(self.type) or 0
    local emblemID2 = self.emblemID or 0
    if emblemID1==emblemID2 then
    else
        return true
    end
    local planePos1 = planeVoApi:getTmpEquip(self.type) or 0
    local planePos2 = self.planePos or 0
    if planePos1==planePos2 then
    else
        return true
    end

    return isChange
end

function ltzdzTroopDialog:closeCheck(clickClose)
    local isChange=self:isTroopsChanged()
    local function sureHandler()
        self:arrangeTroops(clickClose)
        self:close()
    end
    local function cancelHandler()
        self:refreshParentOprate(clickClose)
        self:close()
    end
    if isChange==true then
        smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),sureHandler,getlocal("dialog_title_prompt"),getlocal("arrange_troops_change_tip"),nil,self.layerNum+1,nil,nil,cancelHandler)
    else
        self:refreshParentOprate(clickClose)
        self:close()
    end
end

function ltzdzTroopDialog:refreshParentOprate(clickClose)
    -- print("clickClose",clickClose)
    if clickClose==1 then -- 点击关闭按钮时并且更新了，刷新
        if self.flag then
            if self.pCallback then
                self.pCallback(1)
            end
        end
    end
end

function ltzdzTroopDialog:initUp(upTb)
  
end

function ltzdzTroopDialog:initTroopLayer()
    
end


function ltzdzTroopDialog:tick()
end

function ltzdzTroopDialog:fastTick()  
end

function ltzdzTroopDialog:dispose()
    if self.editLayer then
        self.editLayer:dispose()
        self.editLayer=nil
        G_editLayer[self.type]=nil
    end
    if self.troopChange then
        eventDispatcher:removeEventListener("troops.change",self.troopChange)
        self.troopChange=nil
    end
    
    self.layerNum=nil
    if self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
    end
    self.bgLayer=nil
    tankVoApi:clearTanksTbByType(self.type)
    ltzdzFightApi:clearHeroTbByType(self.type)
    ltzdzFightApi:clearAITroopsTbByType(self.type)
    self.type=nil
    self.flag=nil

    ltzdzVoApi:addOrRemoveOpenDialog(2,"ltzdzTroopDialog")
end