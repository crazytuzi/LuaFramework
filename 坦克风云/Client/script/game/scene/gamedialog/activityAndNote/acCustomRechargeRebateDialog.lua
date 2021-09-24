acCustomRechargeRebateDialog=commonDialog:new()

function acCustomRechargeRebateDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.layerNum=layerNum

    self.cellWidth=570

    return nc
end

function acCustomRechargeRebateDialog:initTableView()
    self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSize.height-105))
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.panelLineBg:getContentSize().height/2+20))

    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-205),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,105))
   -- self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)



    local timeTime = GetTTFLabel(getlocal("activity_timeLabel"),28)
	timeTime:setAnchorPoint(ccp(0.5,1))
	timeTime:setColor(G_ColorGreen)
	timeTime:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-95))
	self.bgLayer:addChild(timeTime)

    local acVo = acCustomRechargeRebateVoApi:getAcVo()
      if acVo ~= nil then
        local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
        local desLabel=GetTTFLabel(timeStr,25)
        desLabel:setAnchorPoint(ccp(0.5,1))
        desLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2,G_VisibleSizeHeight-128))
        self.bgLayer:addChild(desLabel)
        self.timeLb=desLabel
        self:updateAcTime()
      end

	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setAnchorPoint(ccp(0.5,1))
    lineSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,G_VisibleSizeHeight-158))
    self.bgLayer:addChild(lineSp,1)

 --    local girlImg=CCSprite:createWithSpriteFrameName("ShapeCharacter.png")
	-- girlImg:setScale((G_VisibleSizeHeight-480)/girlImg:getContentSize().height)
	-- girlImg:setAnchorPoint(ccp(0,0))
	-- girlImg:setPosition(ccp(20,310))
	-- self.bgLayer:addChild(girlImg)

	local w = self.bgLayer:getContentSize().width-60
	local posY = self.bgLayer:getContentSize().height -200
    -- if G_isIphone5()==false then
    --     w = self.bgLayer:getContentSize().width/2+60
    --     posY = self.bgLayer:getContentSize().height-200
    -- end
    local posX = self.bgLayer:getContentSize().width/2

	local rechargeToGetLb = GetTTFLabelWrap(getlocal("activity_customRechargeRebate_rechargeToGet"),30,CCSizeMake(w-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	rechargeToGetLb:setAnchorPoint(ccp(0,0.5))
	rechargeToGetLb:setPosition(ccp(40,posY-30))
	self.bgLayer:addChild(rechargeToGetLb)

	local rechargeRebateNum = GetTTFLabel(tostring(acCustomRechargeRebateVoApi:getDiscount()*100).."%",60)
	rechargeRebateNum:setAnchorPoint(ccp(0.5,1))
	rechargeRebateNum:setPosition(ccp(posX,posY-rechargeToGetLb:getContentSize().height/2-50))
	self.bgLayer:addChild(rechargeRebateNum)
	rechargeRebateNum:setColor(G_ColorYellowPro)

	local rechargeRebateLb= GetTTFLabelWrap(getlocal("activity_customRechargeRebate_rebate"),60,CCSizeMake(w-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	rechargeRebateLb:setAnchorPoint(ccp(0.5,1))
	rechargeRebateLb:setPosition(ccp(posX,posY-rechargeToGetLb:getContentSize().height/2-rechargeRebateNum:getContentSize().height-60))
	self.bgLayer:addChild(rechargeRebateLb)
	rechargeRebateLb:setColor(G_ColorYellowPro)

	local gemIcon= CCSprite:createWithSpriteFrameName("iconGold6.png")
	gemIcon:setAnchorPoint(ccp(0.5,1))
    gemIcon:setPosition(ccp(posX,posY-rechargeToGetLb:getContentSize().height/2-rechargeRebateNum:getContentSize().height-rechargeRebateLb:getContentSize().height-70))
    self.bgLayer:addChild(gemIcon)

    local  tmpStoreCfg=G_getPlatStoreCfg()
    local goldCfg = tmpStoreCfg["gold"]
    local mPrice=goldCfg[1]
    local totalGold = mPrice+math.ceil(mPrice*acCustomRechargeRebateVoApi:getDiscount())

	local noteLb= GetTTFLabelWrap(getlocal("activity_customRechargeRebate_note",{mPrice,totalGold}),25,CCSizeMake(w-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	noteLb:setAnchorPoint(ccp(0,1))
	noteLb:setPosition(ccp(40,gemIcon:getPositionY()-gemIcon:getContentSize().height-30))
	self.bgLayer:addChild(noteLb)
	noteLb:setColor(G_ColorRed)

    local function nilfun( ... )
        
    end

	local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),nilfun)
	backSprie:setAnchorPoint(ccp(0.5,0))
	backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, 200))
	backSprie:setPosition(ccp(G_VisibleSizeWidth/2, 120));
	self.bgLayer:addChild(backSprie)

	local descStr=""
	descStr=getlocal("activity_customRechargeRebate_Tip1",{acCustomRechargeRebateVoApi:getDiscount()*100}).."\n"..getlocal("activity_customRechargeRebate_Tip2").."\n"..getlocal("activity_customRechargeRebate_Tip3")

	local desTv, desLabel = G_LabelTableView(CCSizeMake(backSprie:getContentSize().width-20, 180),descStr,25,kCCTextAlignmentLeft)
	desTv:setAnchorPoint(ccp(0,0))
	desTv:setPosition(ccp(10, 10))
	backSprie:addChild(desTv,5)
	desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	desTv:setMaxDisToBottomOrTop(50)

    local function rechargeCallback(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        activityAndNoteDialog:closeAllDialog()
    	vipVoApi:showRechargeDialog(self.layerNum+1)
    end
    local rewardBtn=GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",rechargeCallback,nil,getlocal("recharge"),25,11)
    rewardBtn:setAnchorPoint(ccp(0.5,0))
    local rewardMenu=CCMenu:createWithItem(rewardBtn)
    rewardMenu:setPosition(ccp(self.panelLineBg:getContentSize().width/2+10,10))
    rewardMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.panelLineBg:addChild(rewardMenu,2)

end

function acCustomRechargeRebateDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-20,self.bgLayer:getContentSize().height-200)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

function acCustomRechargeRebateDialog:updateAcTime()
    local acVo=acCustomRechargeRebateVoApi:getAcVo()
    if acVo and self.timeLb then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acCustomRechargeRebateDialog:tick()
    local vo=acCustomRechargeRebateVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end
    self:updateAcTime()
end

function acCustomRechargeRebateDialog:dispose()
    self.bgLayer=nil
    self.layerNum=nil
    self.timeLb=nil
    self=nil
end