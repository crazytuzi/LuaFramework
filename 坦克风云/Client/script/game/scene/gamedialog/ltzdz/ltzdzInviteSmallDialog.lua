ltzdzInviteSmallDialog=smallDialog:new()

function ltzdzInviteSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function ltzdzInviteSmallDialog:showInviteInfo(layerNum,istouch,isuseami,callBack,titleStr,inviteInfo)
	local sd=ltzdzInviteSmallDialog:new()
    sd:initInviteInfo(layerNum,istouch,isuseami,callBack,titleStr,inviteInfo)
    return sd
end

function ltzdzInviteSmallDialog:initInviteInfo(layerNum,istouch,isuseami,pCallBack,titleStr,inviteInfo)
	self.isTouch=istouch
    self.isUseAmi=isuseami
    self.layerNum=layerNum
    local nameFontSize=30
    self.time=base.serverTime

    -- print("uid",inviteInfo.uid)

    self.flag,self.curDuan,self.curEndTime=ltzdzVoApi:canSignTime()
    -- print("flag,curDuan",self.flag,self.curDuan,self.curEndTime)


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
        -- self:close()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    local jianGeH=30
    local bgSize=CCSizeMake(560,30+jianGeH*2+300)



    -- rewardItem
    local function touchHandler()
    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg1.png",CCRect(30, 30, 1, 1),touchHandler)
    self.bgLayer=dialogBg
    -- self.bgLayer:setTouchPriority(-(layerNum-1)*20-2)
    self.bgLayer:setContentSize(bgSize)
    self:show()
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)

    local lineSp1=CCSprite:createWithSpriteFrameName("rewardPanelLine.png")
    lineSp1:setAnchorPoint(ccp(0.5,1))
    lineSp1:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height))
    self.bgLayer:addChild(lineSp1)
    local lineSp2=CCSprite:createWithSpriteFrameName("rewardPanelLine.png")
    lineSp2:setAnchorPoint(ccp(0.5,0))
    lineSp2:setPosition(ccp(self.bgLayer:getContentSize().width/2,lineSp2:getContentSize().height))
    self.bgLayer:addChild(lineSp2)
    lineSp2:setRotation(180)

    local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
    pointSp1:setPosition(ccp(5,self.bgLayer:getContentSize().height/2))
    self.bgLayer:addChild(pointSp1)
    local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
    pointSp2:setPosition(ccp(self.bgLayer:getContentSize().width-5,self.bgLayer:getContentSize().height/2))
    self.bgLayer:addChild(pointSp2)


    -- 标题
    local lightSp=CCSprite:createWithSpriteFrameName("newGreenFadeLight.png")
    lightSp:setAnchorPoint(ccp(0.5,0.5))
    lightSp:setScaleX(3)
    lightSp:setPosition(self.bgLayer:getContentSize().width/2,bgSize.height-50)
    self.bgLayer:addChild(lightSp)

    local nameLb=GetTTFLabelWrap(titleStr,nameFontSize,CCSizeMake(320,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
    nameLb:setAnchorPoint(ccp(0.5,0.5))
    nameLb:setColor(G_ColorYellowPro)
    nameLb:setPosition(bgSize.width/2,bgSize.height-40)
    self.bgLayer:addChild(nameLb)
    local nameLb2=GetTTFLabel(titleStr,nameFontSize)
    local realNameW=nameLb2:getContentSize().width
    if realNameW>nameLb:getContentSize().width then
        realNameW=nameLb:getContentSize().width
    end
    for i=1,2 do
        local pointSp=CCSprite:createWithSpriteFrameName("newPointRect.png")
        local anchorX=1
        local posX=bgSize.width/2-(realNameW/2+20)
        local pointX=-7
        if i==2 then
            anchorX=0
            posX=bgSize.width/2+(realNameW/2+20)
            pointX=15
        end
        pointSp:setAnchorPoint(ccp(anchorX,0.5))
        pointSp:setPosition(posX,nameLb:getPositionY())
        self.bgLayer:addChild(pointSp)

        local pointLineSp=CCSprite:createWithSpriteFrameName("newPointLine.png")
        pointLineSp:setAnchorPoint(ccp(0,0.5))
        pointLineSp:setPosition(pointX,pointSp:getContentSize().height/2)
        pointSp:addChild(pointLineSp)
        if i==1 then
            pointLineSp:setRotation(180)
        end
    end
    local dialogHeight=180
    -- 内容
    local dialogBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ()end)
    dialogBg2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,dialogHeight))
    dialogBg2:setAnchorPoint(ccp(0.5,0))
    dialogBg2:setPosition(self.bgLayer:getContentSize().width/2,30)
    self.bgLayer:addChild(dialogBg2)

    local dialogSize=dialogBg2:getContentSize()

    if inviteInfo then
        local childTb={}
        table.insert(childTb,{pic=inviteInfo.icon,order=2,tag=2,size=100})
        if inviteInfo.iconBg then
            table.insert(childTb,{pic=inviteInfo.iconBg,order=1,tag=1,size=120})
            -- print("333333333")
        end
        local function nilFunc()
        end
        local composeIcon=G_getComposeIcon(nilFunc,CCSizeMake(120,120),childTb)
        composeIcon:setPosition(70,dialogSize.height/2)
        dialogBg2:addChild(composeIcon)

        local nameLb=GetTTFLabel(inviteInfo.name,28)
        dialogBg2:addChild(nameLb)
        nameLb:setAnchorPoint(ccp(0,0.5))
        nameLb:setPosition(140,dialogSize.height/2+40)
        nameLb:setColor(G_ColorYellowPro)

        local fightLb=GetTTFLabel(getlocal("world_war_power",{FormatNumber(inviteInfo.fight)}),25)
        dialogBg2:addChild(fightLb)
        fightLb:setAnchorPoint(ccp(0,0.5))
        fightLb:setPosition(140,dialogSize.height/2-40)

        local btnScale=0.7
        local btnlbSize=25
        local function touchOkFunc()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            -- 再次邀请
            local function refreshFunc()
                if self.parentRefresh then

                end
            end
            ltzdzVoApi:socketOperateFriend(refreshFunc,inviteInfo.uid,1)
            -- inviteInfo.uid
        end
        local okItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touchOkFunc,nil,getlocal("ltzdz_invite_again"),btnlbSize/btnScale)
        okItem:setEnabled(false)
        self.okItem=okItem
        local okBtn=CCMenu:createWithItem(okItem)
        okBtn:setTouchPriority(-(self.layerNum-1)*20-4)
        okItem:setScale(btnScale)
        okBtn:setPosition(dialogSize.width-85,dialogSize.height/2+40)
        dialogBg2:addChild(okBtn)

        local function touchCancelFunc()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            local function refreshFunc()
                if pCallBack then
                    pCallBack()
                end
                if self.parentRefresh then 
                    eventDispatcher:dispatchEvent("ltzdz.signUpExpired",{})
                end
                -- 
                self:close()
            end
            -- 取消邀请
            ltzdzVoApi:socketOperateFriend(refreshFunc,nil,4)
            
            
        end
        local cancelItem=GetButtonItem("newGrayBtn.png","newGrayBtn_Down.png","newGrayBtn_Down.png",touchCancelFunc,nil,getlocal("cancel"),btnlbSize/btnScale)
        local cancelBtn=CCMenu:createWithItem(cancelItem)
        cancelBtn:setTouchPriority(-(self.layerNum-1)*20-4)
        cancelItem:setScale(btnScale)
        cancelBtn:setPosition(dialogSize.width-85,dialogSize.height/2-40)
        dialogBg2:addChild(cancelBtn)

    end

    local centerH=bgSize.height-60-60-10

    local pzFrameName="loading1.png" --loading动画
    local metalSp=CCSprite:createWithSpriteFrameName(pzFrameName)
    local pzArr=CCArray:create()
    for kk=1,10 do
        local nameStr="loading"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        pzArr:addObject(frame)
    end
    local animation=CCAnimation:createWithSpriteFrames(pzArr)
    animation:setDelayPerUnit(0.1)
    local animate=CCAnimate:create(animation)
    metalSp:setAnchorPoint(ccp(0.5,0.5))
    -- metalSp:setScale(1/50)
    metalSp:setPosition(ccp(self.bgLayer:getContentSize().width/2-80,centerH))
    self.bgLayer:addChild(metalSp)
    local repeatForever=CCRepeatForever:create(animate)
    metalSp:runAction(repeatForever)

    local composeLb=GetTTFLabelWrap(getlocal("ltzdz_composing"),25,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    composeLb:setAnchorPoint(ccp(0,0.5))
    -- composeLb:setColor(G_ColorYellowPro)
    composeLb:setPosition(self.bgLayer:getContentSize().width/2-10,centerH+15)
    self.bgLayer:addChild(composeLb)

    -- 
    local timeLb=GetTTFLabel("",25)
    -- GetTTFLabelWrap(getlocal("ltzdz_composing"),25,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    timeLb:setAnchorPoint(ccp(0,0.5))
    -- timeLb:setColor(G_ColorYellowPro)
    timeLb:setPosition(self.bgLayer:getContentSize().width/2-10,centerH-15)
    self.bgLayer:addChild(timeLb)
    self.timeLb=timeLb
    self:setTimeLb()

    base:addNeedRefresh(self)


    sceneGame:addChild(self.dialogLayer,layerNum)
    return self.dialogLayer

end

function ltzdzInviteSmallDialog:setTimeLb()
    if self.curEndTime and self.timeLb then

        local subTime=self.curEndTime-base.serverTime

        if subTime<0 then
            local flag,curDuan,curEndTime=ltzdzVoApi:canSignTime()
            if flag==0 then
                self:close()
            else
                subTime=0
                self.parentRefresh=true
                self.okItem:setEnabled(true)
            end
        end
        self.timeLb:setString(GetTimeForItemStrState(subTime))
    end
end

function ltzdzInviteSmallDialog:tick()
    self:setTimeLb()
end


function ltzdzInviteSmallDialog:dispose()
    base:removeFromNeedRefresh(self)
    self.okItem=nil
end

