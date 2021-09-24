acGqkhSmallDialog=smallDialog:new()

function acGqkhSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acGqkhSmallDialog:showScrollDialog(bgSrc,inRect,size,layerNum,istouch,isuseami,item,cousumeTb,callBack,parent)
	local sd=acGqkhSmallDialog:new()
    sd:initGqkhSmallDialog(bgSrc,inRect,size,layerNum,istouch,isuseami,item,cousumeTb,callBack,parent)
end

function acGqkhSmallDialog:initGqkhSmallDialog(bgSrc,inRect,size,layerNum,istouch,isuseami,item,cousumeTb,callBack,parent)
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
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
    closeBtnItem:setAnchorPoint(CCPointMake(1,1))
     
    closeBtn = CCMenu:createWithItem(closeBtnItem)
    closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    closeBtn:setPosition(size.width,size.height)
    dialogBg:addChild(closeBtn)

    local icon,scale=G_getItemIcon(item,100)
    icon:setAnchorPoint(ccp(0,0.5))
	dialogBg:addChild(icon)
	icon:setPosition(20,size.height-100)

    local adaptWidth = 160
    if G_getCurChoseLanguage() == "ar" then
        adaptWidth = 260
    end
	local lbName=GetTTFLabelWrap(item.name,28,CCSizeMake(size.width-adaptWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
	lbName:setAnchorPoint(ccp(0,0))
    lbName:setPosition(ccp(140,size.height-100+10))
    dialogBg:addChild(lbName,2)
    lbName:setColor(G_ColorYellowPro)

    local numLb=GetTTFLabel(getlocal("propInfoNum",{item.num}),28)
	dialogBg:addChild(numLb)
	numLb:setAnchorPoint(ccp(0,1))
	numLb:setPosition(140,size.height-100-10)



    local lbDes=GetTTFLabelWrap(getlocal(item.desc),25,CCSizeMake(size.width-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	lbDes:setAnchorPoint(ccp(0,1))
    lbDes:setPosition(ccp(40,size.height-160))
    dialogBg:addChild(lbDes,2)

    if cousumeTb then
    	local function sureHandler()
    		if G_checkClickEnable()==false then
	            do
	                return
	            end
	        else
	            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
	        end
    		PlayEffect(audioCfg.mouseClick)
    		if callBack then
    			callBack()
    		end
    		self:close()
    	end
        local sureItemImage1,sureItemImage2,sureItemImage3="BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png"
        if acGqkhVoApi:getAcShowType()==acGqkhVoApi.acShowType.TYPE_2 then
            sureItemImage1,sureItemImage2,sureItemImage3="newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png"
        end
    	local sureItem=GetButtonItem(sureItemImage1,sureItemImage2,sureItemImage3,sureHandler,2,getlocal("code_gift"),25)
	    local sureMenu=CCMenu:createWithItem(sureItem);
	    sureMenu:setPosition(ccp(size.width*0.5,70))
	    sureMenu:setTouchPriority(-(layerNum-1)*20-3);
	    dialogBg:addChild(sureMenu)

	    local cousumeLb=GetTTFLabel(cousumeTb[1],25)
	    cousumeLb:setAnchorPoint(ccp(0,0.5))
	    dialogBg:addChild(cousumeLb)

	    local cousumeLb=GetTTFLabel(cousumeTb[1],25)
	    cousumeLb:setAnchorPoint(ccp(0,0.5))
	    dialogBg:addChild(cousumeLb)
	    
		local goldIcon = CCSprite:createWithSpriteFrameName(cousumeTb[2])
		local scale=40/goldIcon:getContentSize().width
		goldIcon:setScale(scale)
		goldIcon:setAnchorPoint(ccp(0,0.5))
		goldIcon:setPosition(cousumeLb:getContentSize().width,cousumeLb:getContentSize().height/2)
		cousumeLb:addChild(goldIcon,1)

		cousumeLb:setPosition(size.width/2-(cousumeLb:getContentSize().width+goldIcon:getContentSize().width*scale)/2,125)

    end

    if parent then
        parent:addChild(self.dialogLayer,10)
    else
        sceneGame:addChild(self.dialogLayer,layerNum)
    end
    
    base:removeFromNeedRefresh(self) --停止刷新


end