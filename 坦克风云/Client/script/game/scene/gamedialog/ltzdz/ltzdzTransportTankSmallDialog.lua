ltzdzTransportTankSmallDialog=smallDialog:new()

function ltzdzTransportTankSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function ltzdzTransportTankSmallDialog:showTransport(layerNum,istouch,isuseami,callBack,titleStr,startCid,endCid,targetCityTb,parent)
	local sd=ltzdzTransportTankSmallDialog:new()
    sd:initTransport(layerNum,istouch,isuseami,callBack,titleStr,
        startCid,endCid,targetCityTb,parent)
    return sd
end

function ltzdzTransportTankSmallDialog:initTransport(layerNum,istouch,isuseami,pCallBack,titleStr,startCid,endCid,targetCityTb,parent)
	self.isTouch=istouch
    self.isUseAmi=isuseami
    self.layerNum=layerNum
    self.startCid=startCid
    self.endCid=endCid
    self.targetCityTb=targetCityTb
    self.parent=parent

    ltzdzVoApi:addOrRemoveOpenDialog(1,"ltzdzTransportTankSmallDialog",self)


    local havaCityTb=ltzdzFightApi:getAllCityCanWalk(targetCityTb)
    self.line=ltzdzVoApi:shortPath_Dijkstra(self.startCid,self.endCid,havaCityTb)


    base:removeFromNeedRefresh(self) --停止刷新

    local function tmpFunc()
    end
    local rrect=CCRect(0, 50, 1, 1)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setTouchEnabled(true)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true)

     local function touchLuaSpr()
        -- PlayEffect(audioCfg.mouseClick)
        -- return self:close()
        
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    -- touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    local bgSize=CCSizeMake(600,540)

    local function closeFunc()
        self:close()
    end
    local dialogBg=G_getNewDialogBg(bgSize,titleStr,25,nil,self.layerNum,true,closeFunc,G_ColorBlue)
    self.dialogLayer:addChild(dialogBg,2)
    dialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.bgLayer=dialogBg

    local startH=bgSize.height-80

    -- print("self.startCid",self.startCid)
    local startCity=ltzdzFightApi:getTargetCityByCid(self.startCid)
    self.reserveNum=startCity.n or 0 -- 预备役数量
    
    -- 城市预备役
    local cityH=startH
    local cityReLb=GetTTFLabelWrap(getlocal("ltzdz_city_reserve",{self.reserveNum}),25,CCSizeMake(bgSize.width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    cityReLb:setAnchorPoint(ccp(0.5,1))
    cityReLb:setPosition(bgSize.width/2,startH)
    self.bgLayer:addChild(cityReLb)
    cityReLb:setColor(G_ColorYellowPro)

    -- 目标城市
    local targetH=cityH-cityReLb:getContentSize().height-10
    local targetCityLb=GetTTFLabelWrap(getlocal("ltzdz_target_city",{ltzdzCityVoApi:getCityName(self.endCid)}),25,CCSizeMake(bgSize.width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    targetCityLb:setAnchorPoint(ccp(0.5,1))
    targetCityLb:setPosition(bgSize.width/2,targetH)
    self.bgLayer:addChild(targetCityLb)
    targetCityLb:setColor(G_ColorYellowPro)

    -- 运输兵力
    local transH=targetH-targetCityLb:getContentSize().height-20
    local transTroopLb=GetTTFLabelWrap(getlocal("ltzdz_trans_troop_num",{}),25,CCSizeMake(bgSize.width-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    transTroopLb:setAnchorPoint(ccp(0,1))
    transTroopLb:setPosition(40,transH)
    self.bgLayer:addChild(transTroopLb)
    self.transTroopLb=transTroopLb

    



    -- 滑动条
    local sliderH=transH-transTroopLb:getContentSize().height-60

    local addBg=G_getThreePointBg(CCSizeMake(bgSize.width-30,160),nilFunc,ccp(0.5,1),ccp(bgSize.width/2,sliderH+40),self.bgLayer)



    local m_numLb=GetTTFLabel(" ",25)
    m_numLb:setPosition(70,sliderH)
    self.bgLayer:addChild(m_numLb,2)
    
    self.marchTime=ltzdzFightApi:getMarchTime(self.line,1)
    local everyOil=ltzdzFightApi:getMarchOil(1,self.marchTime,2)

    local _,oilNum=ltzdzFightApi:getMyRes()
    self.oilNum=oilNum
    local function sliderTouch(handler,object)
        local count = math.ceil(object:getValue())
        if count>self.reserveNum then
            count=self.reserveNum
            object:setValue(count)

        end
        self:refreshOilLb()
        if self.reserveLb then
            self.reserveLb:setString(getlocal("ltzdz_reserve",{self.reserveNum-count}))
        end
        if count>0 then
            m_numLb:setString(count)
        end
    end
    local spBg =CCSprite:createWithSpriteFrameName("proBar_n2.png");
    local spPr =CCSprite:createWithSpriteFrameName("proBar_n1.png");
    local spPr1 =CCSprite:createWithSpriteFrameName("grayBarBtn.png");
    self.slider = LuaCCControlSlider:create(spBg,spPr,spPr1,sliderTouch);
    self.slider:setTouchPriority(-(layerNum-1)*20-5);
    self.slider:setIsSallow(true);
    self.slider:setScaleX(0.9)
    
    if self.reserveNum==0 then
        self.slider:setMinimumValue(0);
        self.slider:setMaximumValue(0);
    else
        self.slider:setMinimumValue(1);
        self.slider:setMaximumValue(self.reserveNum)
    end
    
    if self.oilNum>=self.reserveNum*everyOil then
        self.slider:setValue(self.reserveNum)
    else
        self.slider:setValue(math.floor(self.oilNum/everyOil))
    end
    
    -- self.slider:setValue(self.reserveNum);
    self.slider:setPosition(ccp(355,sliderH))
    self.slider:setTag(99)
    self.bgLayer:addChild(self.slider,2)
    m_numLb:setString(math.ceil(self.slider:getValue()))
    self.m_numLb=m_numLb

    local bgSp = CCSprite:createWithSpriteFrameName("proBar_n2.png");
    bgSp:setAnchorPoint(ccp(0.5,0.5));
    bgSp:setPosition(70,sliderH);
    self.bgLayer:addChild(bgSp,1);
    bgSp:setScaleX(85/bgSp:getContentSize().width)
    
    
    local function touchAdd()
        local nowValue=self.slider:getValue()
        if nowValue+1<=self.reserveNum then
            self.slider:setValue(nowValue+1)
            self:refreshOilLb()
            if self.reserveLb then
                self.reserveLb:setString(getlocal("ltzdz_reserve",{self.reserveNum-nowValue-1}))
            end
        end
    end
    
    local function touchMinus()
        local nowValue=self.slider:getValue()
        if nowValue-1>0 then
            self.slider:setValue(nowValue-1);
            self:refreshOilLb()
            if self.reserveLb then
                self.reserveLb:setString(getlocal("ltzdz_reserve",{self.reserveNum-nowValue+1}))
            end
        end
    
    end
    
    local addSp=LuaCCSprite:createWithSpriteFrameName("greenPlus.png",touchAdd)
    addSp:setPosition(ccp(555,sliderH))
    self.bgLayer:addChild(addSp,1)
    addSp:setTouchPriority(-(layerNum-1)*20-4);
    
    
    local minusSp=LuaCCSprite:createWithSpriteFrameName("greenMinus.png",touchMinus)
    minusSp:setPosition(ccp(148,sliderH))
    self.bgLayer:addChild(minusSp,1)
    minusSp:setTouchPriority(-(layerNum-1)*20-4)

    -- 消耗石油
    local cousumH=sliderH-50
    local nowValue=self.slider:getValue()
    local consumeOilLb=GetTTFLabelWrap("",25,CCSizeMake(bgSize.width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    self.bgLayer:addChild(consumeOilLb)
    consumeOilLb:setAnchorPoint(ccp(0.5,0.5))
    consumeOilLb:setPosition(bgSize.width/2,cousumH)
    self.consumeOilLb=consumeOilLb
    self:refreshOilLb()

    -- 消耗时间
    local cousumTH=cousumH-consumeOilLb:getContentSize().height
    local nowValue=self.slider:getValue()
    local consumeTimeLb=GetTTFLabelWrap(getlocal("ltzdz_consume_time_num",{GetTimeStrForFleetSlot(self.marchTime)}),25,CCSizeMake(bgSize.width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    self.bgLayer:addChild(consumeTimeLb)
    consumeTimeLb:setAnchorPoint(ccp(0.5,1))
    consumeTimeLb:setPosition(bgSize.width/2,cousumTH)
    self.consumeTimeLb=consumeTimeLb

    local tvBgH=startH-cousumTH+consumeTimeLb:getContentSize().height+30
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ()end)
    tvBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,tvBgH))
    tvBg:setAnchorPoint(ccp(0.5,1))
    tvBg:setPosition(self.bgLayer:getContentSize().width/2,bgSize.height-70)
    self.bgLayer:addChild(tvBg)
    tvBg:setVisible(false)

    local btnScale=1
    local btnlbSize=25
    local btnY=30+40
    local function touchOkFunc()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local function refreshFunc()
            if self.parent then
                self.parent:removeSetOrTransport()
            end
            self:close()
        end
        local num=math.ceil(self.slider:getValue())
        if num==0 then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("ltzdz_can_not_trans_reserve"),30)
            return
        end
        ltzdzFightApi:setTroopsSocket(refreshFunc,4,nil,self.startCid,nil,nil,nil,nil,self.line,num)
    end
    local okItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touchOkFunc,nil,getlocal("confirm"),btnlbSize/btnScale)
    local okBtn=CCMenu:createWithItem(okItem)
    okBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    okItem:setScale(btnScale)
    okBtn:setPosition(self.bgLayer:getContentSize().width/2-125,btnY)
    self.bgLayer:addChild(okBtn)

    local function touchCancelFunc()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:close()
        
    end
    local cancelItem=GetButtonItem("newGrayBtn.png","newGrayBtn_Down.png","newGrayBtn_Down.png",touchCancelFunc,nil,getlocal("cancel"),btnlbSize/btnScale)
    local cancelBtn=CCMenu:createWithItem(cancelItem)
    cancelBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    cancelItem:setScale(btnScale)
    cancelBtn:setPosition(self.bgLayer:getContentSize().width/2+125,btnY)
    self.bgLayer:addChild(cancelBtn)


    sceneGame:addChild(self.dialogLayer,layerNum)
    return self.dialogLayer

end

function ltzdzTransportTankSmallDialog:refreshOilLb()
    if not self.consumeOilLb then
        return
    end
    local num=math.ceil(self.slider:getValue())
    local consumeOil=ltzdzFightApi:getMarchOil(num,self.marchTime,2)
    self.consumeOilLb:setString(getlocal("ltzdz_consume_oil_num",{consumeOil}))
    if self.oilNum>=consumeOil then
        self.consumeOilLb:setColor(G_ColorWhite)
    else
        self.consumeOilLb:setColor(G_ColorRed)
    end
    if not self.transTroopLb then
        return
    end
    self.transTroopLb:setString(getlocal("ltzdz_trans_troop_num",{num .. "/" .. self.reserveNum}))
end


function ltzdzTransportTankSmallDialog:dispose()
    self.hei=nil
    self.selectSp=nil
    self.tankTable=nil
    self.consumeOilLb=nil
    self.transTroopLb=nil
    self.slider=nil
    self.marchTime=nil
    self.startCid=nil
    self.endCid=nil
    self.targetCityTb=nil
    self.parent=nil
    ltzdzVoApi:addOrRemoveOpenDialog(2,"ltzdzTransportTankSmallDialog")

end