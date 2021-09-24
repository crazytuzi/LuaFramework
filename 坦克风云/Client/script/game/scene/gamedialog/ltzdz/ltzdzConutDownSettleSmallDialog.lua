ltzdzConutDownSettleSmallDialog=smallDialog:new()

function ltzdzConutDownSettleSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

-- tid 计策id cid:出发的城市 sid：队列号
function ltzdzConutDownSettleSmallDialog:showCountDown(layerNum,istouch,isuseami,callBack,titleStr)
	local sd=ltzdzConutDownSettleSmallDialog:new()
    sd:initCount(layerNum,istouch,isuseami,callBack,titleStr)
    return sd
end

function ltzdzConutDownSettleSmallDialog:initCount(layerNum,istouch,isuseami,pCallBack,titleStr)
	self.isTouch=istouch
    self.isUseAmi=isuseami
    self.layerNum=layerNum
    self.parent=parent
    self.scoutInfo=scoutInfo
    local nameFontSize=30


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
        
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(255)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    local dialogSize=CCSizeMake(580,170)

    local dialogBg2H=240
    dialogSize.height=dialogSize.height+dialogBg2H



    local function touchDialogBg()
        -- print("touchDialogBg")
    end
    local function closeFunc()
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local dialogBg=G_getNewDialogBg(dialogSize,titleStr,28,touchDialogBg,self.layerNum,false,closeFunc,G_ColorWhite)
    dialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
    self.dialogLayer:addChild(dialogBg,2)
    dialogBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)

    self.bgLayer=dialogBg

    self:show()

    local dialogBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ()end)
    dialogBg2:setContentSize(CCSizeMake(dialogSize.width-40,dialogBg2H))
    dialogBg2:setAnchorPoint(ccp(0.5,1))
    dialogBg2:setPosition(dialogSize.width/2,dialogSize.height-75)
    self.bgLayer:addChild(dialogBg2)


    local startH=dialogBg2H-20
    local desLb1=GetTTFLabelWrap(getlocal("ltzdz_count_down_des2"),25,CCSizeMake(dialogSize.width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    desLb1:setAnchorPoint(ccp(0.5,1))
    dialogBg2:addChild(desLb1)
    desLb1:setPosition(dialogBg2:getContentSize().width/2,startH)

    startH=startH-desLb1:getContentSize().height-25

    local desLb21=GetTTFLabelWrap(getlocal("ltzdz_count_down_des"),25,CCSizeMake(dialogSize.width-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    desLb21:setAnchorPoint(ccp(0,1))
    dialogBg2:addChild(desLb21)
    desLb21:setPosition(20,startH)

    startH=startH-desLb21:getContentSize().height-25
    local desLb22=GetTTFLabelWrap(getlocal("ltzdz_count_down_des3"),25,CCSizeMake(dialogSize.width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    desLb22:setAnchorPoint(ccp(0.5,1))
    dialogBg2:addChild(desLb22)
    desLb22:setPosition(dialogBg2:getContentSize().width/2,startH)

    startH=startH-desLb22:getContentSize().height
    local isDelay,time=ltzdzVoApi:isDelaySettlement()
    if time==nil or time<0 then
        time=0
    end
    local desLb2=GetTTFLabelWrap(GetTimeStr(time),25,CCSizeMake(dialogSize.width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    dialogBg2:addChild(desLb2)
    desLb2:setAnchorPoint(ccp(0.5,1))
    desLb2:setColor(G_ColorYellowPro)
    desLb2:setPosition(dialogBg2:getContentSize().width/2,startH)
    self.desLb2=desLb2



    local function touchStudy()
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
    local menuItem={}
    local scale=0.8
    local menuLbSize=25/scale
    menuItem[2]=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touchStudy,nil,getlocal("confirm"),menuLbSize)
    menuItem[2]:setScale(scale)

    local btnMenu = CCMenu:createWithItem(menuItem[2])
    self.bgLayer:addChild(btnMenu)
    btnMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    btnMenu:setBSwallowsTouches(true)
    btnMenu:setPosition(self.bgLayer:getContentSize().width/2,60)

    
    sceneGame:addChild(self.dialogLayer,layerNum)
    return self.dialogLayer

end





function ltzdzConutDownSettleSmallDialog:tick()
    local isDelay,time=ltzdzVoApi:isDelaySettlement() 
    if isDelay==true then
        if time==nil or time<=0 then
            time=0
        end
        if self.desLb2 then
            self.desLb2:setString(GetTimeStr(time))
        end
    else
        self:close()
    end
end


function ltzdzConutDownSettleSmallDialog:dispose()
    self.scoutInfo=nil
    self.parent=nil
end

