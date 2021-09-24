
expeditionSmallDialog=smallDialog:new()

function expeditionSmallDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    return nc
end

function expeditionSmallDialog:showReward(eid,layerNum)
	self.isTouch=true
    self.isUseAmi=true

	local sd=expeditionSmallDialog:new()

	local function touchDialog()
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
 
    local rect = CCRect(0, 0, 400, 350)
    local capInSet = CCRect(130, 50, 1, 1)
    local capInSet1 = CCRect(10, 10, 1, 1)

    self.dialogLayer=CCLayer:create()

    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",capInSet,touchDialog);
    dialogBg:setContentSize(CCSizeMake(500,490))
    self.bgLayer=dialogBg
    
    local function touchDialog()
      
    end
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    self:userHandler()

    local function touchLuaSpr()
        if self.isTouch~=nil then
            PlayEffect(audioCfg.mouseClick)
            self:close()
        end
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    --touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg,1)

    local point=expeditionVoApi:getRewardPoint(eid)

    local spStr=""
    if eid%3==0 then
        spStr="SpecialBox.png"
        if expeditionVoApi:isReward(i) then
           spStr="SpecialBoxOpen.png"
        end
    else
       spStr="silverBox.png"
        if expeditionVoApi:isReward(i) then
           spStr="silverBoxOpen.png"
        end
    end

    

    local titleLb=GetTTFLabel(getlocal("expeditionReward",{eid}),34)
    titleLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-50))
    self.bgLayer:addChild(titleLb,7)
    titleLb:setColor(G_ColorYellowPro)

    local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSprite:setScaleX(((self.bgLayer:getContentSize().width-50)/lineSprite:getContentSize().width))
    lineSprite:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-90))
    self.bgLayer:addChild(lineSprite,6)

    local xxx=60
    local yyy = 40
    local boxsp=CCSprite:createWithSpriteFrameName(spStr)
    boxsp:setAnchorPoint(ccp(0,0.5))
    boxsp:setPosition(ccp(xxx,260+yyy))
    self.bgLayer:addChild(boxsp)

    local boxLb=GetTTFLabel(getlocal("sample_prop_name_56").."×1",27)
    boxLb:setAnchorPoint(ccp(0,0.5))
    boxLb:setPosition(ccp(190,boxsp:getPositionY()))
    self.bgLayer:addChild(boxLb,7)


    local sp=CCSprite:createWithSpriteFrameName("expeditionPoint.png")
    sp:setAnchorPoint(ccp(0,0.5))
    sp:setPosition(ccp(xxx,100+yyy))
    self.bgLayer:addChild(sp)

    local pointsLb=GetTTFLabel(getlocal("expeditionPoints",{point}),27)
    pointsLb:setAnchorPoint(ccp(0,0.5))
    pointsLb:setPosition(ccp(190,sp:getPositionY()))
    self.bgLayer:addChild(pointsLb,7)

    
    
    sceneGame:addChild(self.dialogLayer,layerNum)
    --self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    self.dialogLayer:setPosition(ccp(0,0))
    self:show()


	  
    return sd
end