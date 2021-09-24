acGqkhSPSmallDialog=smallDialog:new()

function acGqkhSPSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.point=1
	return nc
end

function acGqkhSPSmallDialog:showScrollDialog(bgSrc,inRect,size,layerNum,istouch,isuseami,callBack,parent)
	local sd=acGqkhSPSmallDialog:new()
    sd:initGqkhSpSmallDialog(bgSrc,inRect,size,layerNum,istouch,isuseami,callBack,parent)
end

function acGqkhSPSmallDialog:initGqkhSpSmallDialog(bgSrc,inRect,size,layerNum,istouch,isuseami,callBack,parent)
	self.isTouch=istouch
    self.isUseAmi=isuseami

	local function tmpFunc()
    end
    local rrect=CCRect(0, 50, 1, 1)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setTouchEnabled(true)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true)

    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,tmpFunc)
    self.bgLayer=dialogBg
	dialogBg:setContentSize(size)
	dialogBg:setIsSallow(false)
	self.dialogLayer:addChild(dialogBg,1)
	dialogBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
	self:show()

	local function close()
		if G_checkClickEnable()==false then
		    do
		        return
		    end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
	        PlayEffect(audioCfg.mouseClick)
	        return self:close()
	    end
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
    closeBtnItem:setAnchorPoint(CCPointMake(1,1))
     
    closeBtn = CCMenu:createWithItem(closeBtnItem)
    closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    closeBtn:setPosition(size.width,size.height)
    dialogBg:addChild(closeBtn)

    local titleLb=GetTTFLabelWrap(getlocal("activity_gqkh_sp"),25,CCSizeMake(240,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    titleLb:setAnchorPoint(ccp(0,1))
    titleLb:setPosition(20,size.height-40)
    dialogBg:addChild(titleLb)

    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setAnchorPoint(ccp(0.5,1))
    lineSp:setScaleX(size.width/lineSp:getContentSize().width)
    lineSp:setPosition(ccp(dialogBg:getContentSize().width/2,size.height-40-titleLb:getContentSize().height-10))
    dialogBg:addChild(lineSp)

    -- object,fn,tag
    local function touchPoint(object,fn,tag)
    	if G_checkClickEnable()==false then
		    do
		        return
		    end
		else
		    base.setWaitTime=G_getCurDeviceMillTime()
		    if self.point==tag then
		    	return 
		    end
		    PlayEffect(audioCfg.mouseClick)
		    self["unCheckSp" .. self.point]:setVisible(false)
		    self["unCheckSp" .. tag]:setVisible(true)
		    self.point=tag
		end
    end
    for i=1,6 do
    	local diceSp=CCSprite:createWithSpriteFrameName("Dice" .. i .. ".png")
    	dialogBg:addChild(diceSp)
    	diceSp:setPosition(size.width/7*i,dialogBg:getContentSize().height/2+50)
    	diceSp:setScale(0.8)

    	local checkSp=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",touchPoint)
	    dialogBg:addChild(checkSp)
	    checkSp:setTouchPriority(-(layerNum-1)*20-3);
	    checkSp:setPosition(size.width/7*i,dialogBg:getContentSize().height/2-40)
	    checkSp:setTag(i)

	    local unCheckSp=CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
	    dialogBg:addChild(unCheckSp)
	    unCheckSp:setPosition(size.width/7*i,dialogBg:getContentSize().height/2-40)
	    self["unCheckSp" .. i]=unCheckSp
	    if i~=1 then
	    	unCheckSp:setVisible(false)
	    end
    end

    local function sureHandler()
		if G_checkClickEnable()==false then
		    do
		        return
		    end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
			PlayEffect(audioCfg.mouseClick)
	        if callBack then
				callBack(self.point)
			end
			self:close()
	    end
	end
	local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sureHandler,2,getlocal("ok"),25)
	local sureMenu=CCMenu:createWithItem(sureItem);
	sureMenu:setPosition(ccp(size.width*0.5,70))
	sureMenu:setTouchPriority(-(layerNum-1)*20-3);
	dialogBg:addChild(sureMenu)

    if parent then
        parent:addChild(self.dialogLayer,10)
    else
        sceneGame:addChild(self.dialogLayer,layerNum)
    end
    base:removeFromNeedRefresh(self) --停止刷新
end

function acGqkhSPSmallDialog:dispose()
	self.point=1
end