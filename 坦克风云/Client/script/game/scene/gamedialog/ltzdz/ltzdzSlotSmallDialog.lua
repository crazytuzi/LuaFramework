ltzdzSlotSmallDialog=smallDialog:new()

function ltzdzSlotSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function ltzdzSlotSmallDialog:showSlotInfo(layerNum,istouch,isuseami,callBack,titleStr,parent)
	local sd=ltzdzSlotSmallDialog:new()
    sd:initSlotInfo(layerNum,istouch,isuseami,callBack,titleStr,parent)
    return sd
end

function ltzdzSlotSmallDialog:initSlotInfo(layerNum,istouch,isuseami,pCallBack,titleStr,parent)
    ltzdzVoApi:addOrRemoveOpenDialog(1,"ltzdzSlotSmallDialog",self)

	self.isTouch=istouch
    self.isUseAmi=isuseami
    self.layerNum=layerNum
    self.parent=parent
    local nameFontSize=30

    local function refreshSlot(event,data)
       self:refreshSlot(data)
    end
    self.slotListener=refreshSlot
    eventDispatcher:addEventListener("ltzdz.refreshSlot",refreshSlot)


    -- base:removeFromNeedRefresh(self) --停止刷新
    base:addNeedRefresh(self)

    local function tmpFunc()
    end
    local rrect=CCRect(0, 50, 1, 1)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setTouchEnabled(true)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true)

    local function touchLuaSpr()
        -- PlayEffect(audioCfg.mouseClick)
        -- self:close()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(255)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)


    local dialogBg=G_getNewDialogBg2(CCSizeMake(580,500),self.layerNum,callback,titleStr,25,titleColor)
    self.dialogLayer:addChild(dialogBg,2)
    dialogBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
    self.bgLayer=dialogBg

    self:show()

    local function closeFunc()
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    G_addForbidForSmallDialog(self.dialogLayer,dialogBg,-(layerNum-1)*20-3,closeFunc)

    local dialogSize=dialogBg:getContentSize()

    local isMoved=false
    local tvWidth=dialogSize.width-40
    local tvHeight=dialogSize.height-25-40
    local cellHeight=120
    local cellWidth=tvWidth

    self.allSlot=ltzdzFightApi:getSelfAllSlot()
    self.tickFleetTimer={}

    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return #self.allSlot
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(cellWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            local slotInfo=self.allSlot[idx+1].value
            local sid=self.allSlot[idx+1].sid -- 队列号

            local backSprie=G_getThreePointBg(CCSizeMake(cellWidth,cellHeight-5),nil,ccp(0,0),ccp(0,5),cell)

            local bgSize=backSprie:getContentSize()

            local function touchLeft()
                if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)
                    self:childVisible(false)
                    local function childVisible()
                        self:childVisible(true)
                    end
                    if slotInfo[1]==1 then
                        local trueInfo=ltzdzFightApi:getSlotInfo(slotInfo)
                        ltzdzFightApi:showScoutInfo(self.layerNum+1,true,true,childVisible,getlocal("scout_content_scout_title"),nil,false,trueInfo)
                    else
                        ltzdzFightApi:showTransInfo(self.layerNum+1,true,true,childVisible,getlocal("scout_content_scout_title"),nil,slotInfo)
                    end
                    
                end
                
            end
            local leftSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLeft)
            leftSp:setContentSize(CCSizeMake(100,bgSize.height))
            backSprie:addChild(leftSp)
            leftSp:setAnchorPoint(ccp(0,0.5))
            leftSp:setPosition(0,bgSize.height/2)
            -- leftSp:setTouchPriority(-(self.layerNum-1)*20-2)



            local iconSp
            local iconPic1
            local iconPic2
            -- newAttackBtn_Down
            if slotInfo[1]==1 then
                iconPic1="newAttackBtn.png"
                iconPic2="newAttackBtn_Down.png"
            else
                iconPic1="newTransBtn.png"
                iconPic2="newTransBtn_Down.png"
            end
            local iconItem = GetButtonItem(iconPic1,iconPic2,iconPic2,touchLeft,nil,nil,nil);
            local iconMenu = CCMenu:createWithItem(iconItem)
            iconMenu:setTouchPriority(-(layerNum-1)*20-2)
            iconMenu:setPosition(ccp(leftSp:getContentSize().width/2,leftSp:getContentSize().height/2))
            leftSp:addChild(iconMenu)


            local function touchCenter()
                if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)
                    if self.parent then
                        local mapCfg=ltzdzVoApi:getMapCfg()
                        local cityCfg=mapCfg.citycfg
                        local targetCity=cityCfg[slotInfo[3]]
                        self.parent:focus(targetCity.pos[1],targetCity.pos[2])
                    end
                    self:close()
                end
            end
            local centerSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchCenter)
            centerSp:setContentSize(CCSizeMake(bgSize.width-250,bgSize.height))
            backSprie:addChild(centerSp)
            centerSp:setAnchorPoint(ccp(0,0.5))
            centerSp:setPosition(100,bgSize.height/2)
            centerSp:setTouchPriority(-(self.layerNum-1)*20-2)

            local centerSize=centerSp:getContentSize()

            local cityLbSize=22 
            local cityLbH=bgSize.height/2+20
            local startCityLb=GetTTFLabel(ltzdzCityVoApi:getCityName(slotInfo[2]),cityLbSize)
            -- GetTTFLabelWrap(ltzdzCityVoApi:getCityName(slotInfo[2]),cityLbSize,CCSizeMake(centerSize.width/2-30,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
            startCityLb:setAnchorPoint(ccp(1,0.5))
            centerSp:addChild(startCityLb)
            startCityLb:setPosition(centerSize.width/2-30,cityLbH)
            startCityLb:setColor(G_ColorYellowPro)

            local endCityLb=GetTTFLabel(ltzdzCityVoApi:getCityName(slotInfo[3]),cityLbSize)
            -- GetTTFLabelWrap(ltzdzCityVoApi:getCityName(slotInfo[3]),cityLbSize,CCSizeMake(centerSize.width/2-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            endCityLb:setAnchorPoint(ccp(0,0.5))
            centerSp:addChild(endCityLb)
            endCityLb:setPosition(centerSize.width/2+30,cityLbH)
            endCityLb:setColor(G_ColorYellowPro)
            

            local arrow=CCSprite:createWithSpriteFrameName("targetArrow.png")
            centerSp:addChild(arrow)
            arrow:setPosition(centerSize.width/2,cityLbH)


            AddProgramTimer(centerSp,ccp(centerSp:getContentSize().width/2,centerSp:getContentSize().height/2-20),9,12,getlocal(""),"TeamTravelBarBg.png","TeamTravelBar.png",11);
            local moneyTimerSprite = tolua.cast(centerSp:getChildByTag(9),"CCProgressTimer")
            self.tickFleetTimer[idx+1]=moneyTimerSprite

            self:setTimerSpPer(moneyTimerSprite,slotInfo)

            -- 加速按钮
            local btnScale=0.6
            local btnlbSize=22
            local function touchAcc()
                if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)
                    -- tid 计策id
                    local tValue=ltzdzFightApi:getTvalueByTid("t2")
                    ltzdzFightApi:showMarchAcc(self.layerNum+1,true,true,nil,getlocal("ltzdz_use_ploy"),nil,getlocal("ltzdz_use_acc_des",{tValue.effc*100 .. "%%"}),"t2",slotInfo[2],sid)
                end
            end
            local accItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",touchAcc,nil,getlocal("accelerateBuild"),btnlbSize/btnScale)
            local accBtn=CCMenu:createWithItem(accItem)
            accBtn:setTouchPriority(-(self.layerNum-1)*20-2)
            accItem:setScale(btnScale)
            accBtn:setPosition(bgSize.width-75,bgSize.height/2-15)
            backSprie:addChild(accBtn)
            local flag,useNum,limitNum=ltzdzFightApi:isCanAcc(slotInfo)
            local btnLb=GetTTFLabel("(" .. useNum .. "/" .. limitNum .. ")",btnlbSize)
            accItem:addChild(btnLb)
            btnLb:setScale(1/btnScale)
            btnLb:setPosition(accItem:getContentSize().width/2,accItem:getContentSize().height+10)
            btnLb:setAnchorPoint(ccp(0.5,0))
            accItem:setEnabled(flag)

            return cell
        elseif fn=="ccTouchBegan" then
            isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            isMoved=true
        elseif fn=="ccTouchEnded"  then

        end
    end
    
    local hd=LuaEventHandler:createHandler(tvCallBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth,tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,25))
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(80)

    self.childTb=G_clickSreenContinue(self.bgLayer)


    sceneGame:addChild(self.dialogLayer,layerNum)
    return self.dialogLayer

end

function ltzdzSlotSmallDialog:setTimerSpPer(moneyTimerSprite,slotInfo)
    local totalTime=slotInfo[5]-slotInfo[4]
    local marchTime=base.serverTime-slotInfo[4]
    -- print("totalTime,marchTime",totalTime,marchTime)
    moneyTimerSprite:setPercentage(marchTime/totalTime*100)


    local lbPer = tolua.cast(moneyTimerSprite:getChildByTag(12),"CCLabelTTF")
    lbPer:setAnchorPoint(ccp(0.5,0))
    lbPer:setPosition(ccp(moneyTimerSprite:getContentSize().width/2,0))
    local subTime=slotInfo[5]-base.serverTime
    if subTime<0 then
        subTime=0
    end
    lbPer:setString(GetTimeStrForFleetSlot(subTime))
end

function ltzdzSlotSmallDialog:refreshSlot(data)

    if self.tv then
        local lastNum=#self.allSlot
        self.allSlot=ltzdzFightApi:getSelfAllSlot()
        local nowNum=#self.allSlot
        if #self.allSlot==0 then
            self.tickFleetTimer={}
            self:close()
            do return end
        end
        self.tickFleetTimer={}
        
        if nowNum<lastNum then
            self.tv:reloadData()
        else
            local recordPoint=self.tv:getRecordPoint()
            self.tv:reloadData()
            self.tv:recoverToRecordPoint(recordPoint)
        end
    end

end


function ltzdzSlotSmallDialog:childVisible(flag)
    if self.childTb then
        for k,v in pairs(self.childTb) do
            if v then
                v:setVisible(flag)
            end
        end
    end
end


function ltzdzSlotSmallDialog:tick()
    if self.tickFleetTimer and self.allSlot then
        for k,v in pairs(self.tickFleetTimer) do
            if k and self.allSlot[k] and self.allSlot[k].value then
                local slotInfo=self.allSlot[k].value
                if v and slotInfo then
                    self:setTimerSpPer(v,slotInfo)
                end
            end
        end
    end
end


function ltzdzSlotSmallDialog:dispose()
    if self.slotListener then
        eventDispatcher:removeEventListener("ltzdz.refreshSlot",self.slotListener)
        self.slotListener=nil
    end
    self.childTb=nil

    self.allSlot=nil
    self.tickFleetTimer=nil
    ltzdzVoApi:addOrRemoveOpenDialog(2,"ltzdzSlotSmallDialog")
    -- base:removeFromNeedRefresh(self)
end

