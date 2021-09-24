ltzdzTransInfoSmallDialog=smallDialog:new()

function ltzdzTransInfoSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function ltzdzTransInfoSmallDialog:showTransInfo(layerNum,istouch,isuseami,callBack,titleStr,parent,transInfo)
	local sd=ltzdzTransInfoSmallDialog:new()
    sd:initTransInfo(layerNum,istouch,isuseami,callBack,titleStr,parent,transInfo)
    return sd
end

function ltzdzTransInfoSmallDialog:initTransInfo(layerNum,istouch,isuseami,pCallBack,titleStr,parent,transInfo)
	self.isTouch=istouch
    self.isUseAmi=isuseami
    self.layerNum=layerNum
    self.parent=parent
    self.scoutInfo=scoutInfo
    local nameFontSize=30

    ltzdzVoApi:addOrRemoveOpenDialog(1,"ltzdzTransInfoSmallDialog",self)


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
        PlayEffect(audioCfg.mouseClick)
        if pCallBack then
            pCallBack()
        end
        self:close()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(255)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    local dgSize=CCSizeMake(600,260)
   
    local dialogBg=G_getNewDialogBg2(dgSize,self.layerNum,callback,titleStr,25,titleColor)
    self.dialogLayer:addChild(dialogBg,2)
    dialogBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
    self.bgLayer=dialogBg

    self:show()

   
    local iconPic,slotState=ltzdzFightApi:getIconState(transInfo)
    local logoSp=CCSprite:createWithSpriteFrameName(iconPic)
    logoSp:setScale(0.6)

    local titleTb={slotState,28,G_ColorYellowPro}
    local titleBg,titleLb=G_createNewTitle(titleTb,CCSizeMake(dgSize.width-60,0),false)
    dialogBg:addChild(titleBg)
    titleBg:setPosition(dgSize.width/2,dgSize.height-70)

    local sbLb=GetTTFLabel(titleTb[1],titleTb[2])
    local sbSizeWidth=sbLb:getContentSize().width
    local titlelbWidth=titleLb:getContentSize().width
    -- titleLb:setDimensions(CCSizeMake(titlelbWidth-logoSp:getContentSize().width, 0))
    if sbSizeWidth<titlelbWidth then
        logoSp:setPosition(titlelbWidth/2-logoSp:getContentSize().width/2-sbSizeWidth/2,titleLb:getContentSize().height/2)
    else
        logoSp:setPosition(-logoSp:getContentSize().width/2,titleLb:getContentSize().height/2)
    end
    -- titleLb:setPositionX(titleLb:getPositionX()-logoSp:getContentSize().width/2)
    titleLb:addChild(logoSp)

    local cityLbSize=22 
    local cityLbH=dgSize.height-95
    local startCityLb=GetTTFLabel(ltzdzCityVoApi:getCityName(transInfo[2]),cityLbSize)
    startCityLb:setAnchorPoint(ccp(1,0.5))
    dialogBg:addChild(startCityLb)
    startCityLb:setPosition(dgSize.width/2-60,cityLbH)
    startCityLb:setColor(G_ColorYellowPro)

    local endCityLb=GetTTFLabel(ltzdzCityVoApi:getCityName(transInfo[3]),cityLbSize)
    endCityLb:setAnchorPoint(ccp(0,0.5))
    dialogBg:addChild(endCityLb)
    endCityLb:setPosition(dgSize.width/2+60,cityLbH)
    endCityLb:setColor(G_ColorYellowPro)

    -- 加箭头 dgSize.width/2
    local arrow=CCSprite:createWithSpriteFrameName("targetArrow.png")
    dialogBg:addChild(arrow)
    arrow:setPosition(dgSize.width/2,cityLbH)

    local transH=cityLbH-70
    -- ltzdz_trans_num_des
    local transNumDesLb=GetTTFLabelWrap(getlocal("ltzdz_trans_num_des"),25,CCSizeMake(dgSize.width - 100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
    dialogBg:addChild(transNumDesLb)
    transNumDesLb:setAnchorPoint(ccp(0.5,0))
    transNumDesLb:setPosition(dgSize.width/2,transH)
    -- transNumDesLb:setColor(G_ColorGreen)

    local transIcon=CCSprite:createWithSpriteFrameName("picked_icon2.png")
    dialogBg:addChild(transIcon)
    transIcon:setPositionY(transH-30)

    local transNumLb=GetTTFLabel("    " .. transInfo[7] or 0,25)
    dialogBg:addChild(transNumLb)
    transNumLb:setPositionY(transH-30)
    transNumLb:setColor(G_ColorGreen)
    G_setchildPosX(dialogBg,transIcon,transNumLb)


    G_clickSreenContinue(self.bgLayer)


    sceneGame:addChild(self.dialogLayer,layerNum)
    return self.dialogLayer

end



function ltzdzTransInfoSmallDialog:tick()
end


function ltzdzTransInfoSmallDialog:dispose()
    self.scoutInfo=nil
    self.parent=nil
    ltzdzVoApi:addOrRemoveOpenDialog(2,"ltzdzTransInfoSmallDialog")
end

