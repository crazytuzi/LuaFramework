acThreeYearThird={}
function acThreeYearThird:new()
	local nc={}
	setmetatable(nc,self)
	nc.cellWidth=G_VisibleSizeWidth-50
	nc.cellHeight=140
	nc.cellNum=0
	nc.buffCfg=nil
	self.__index=self
	return nc
end

function acThreeYearThird:init(layerNum,parent)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self.parent=parent

	self:initTableView()

	return self.bgLayer
end

function acThreeYearThird:initTableView()
	self.buffCfg=acThreeYearVoApi:getBuffAddedCfg()
	self.cellNum=SizeOfTable(self.buffCfg)

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local viewBg=CCSprite:create("public/acWanshengjiedazuozhanBg2.jpg")
    viewBg:setAnchorPoint(ccp(0.5,1))
    viewBg:setScaleX((G_VisibleSizeWidth-50)/viewBg:getContentSize().width)
    viewBg:setScaleY((G_VisibleSizeHeight-200)/viewBg:getContentSize().height)
    viewBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160))
    self.bgLayer:addChild(viewBg)
   	local fadeBg=CCSprite:createWithSpriteFrameName("redFadeLine.png")
    fadeBg:setAnchorPoint(ccp(0.5,1))
    fadeBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160))
    fadeBg:setScaleX((G_VisibleSizeWidth-50)/fadeBg:getContentSize().width)
    fadeBg:setScaleY((G_VisibleSizeHeight-200)/fadeBg:getContentSize().height)
    self.bgLayer:addChild(fadeBg)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    local lineSp1=CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
    -- lineSp1:setScaleX((G_VisibleSizeWidth-30)/lineSp1:getContentSize().width)
    lineSp1:setAnchorPoint(ccp(0.5,1))
    lineSp1:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160))
    self.bgLayer:addChild(lineSp1,10)
  	local lineSp2=CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
    -- lineSp2:setScaleX((G_VisibleSizeWidth-30)/lineSp2:getContentSize().width)
    lineSp2:setAnchorPoint(ccp(0.5,1))
    lineSp2:setRotation(180)
    lineSp2:setPosition(ccp(G_VisibleSizeWidth/2,25))
    self.bgLayer:addChild(lineSp2,10)

	local function eventHandler( ... )
		return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(eventHandler)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.cellWidth,G_VisibleSizeHeight-240),nil)
    self.tv:setPosition(ccp(23,50))
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)
end

function acThreeYearThird:eventHandler(handler,fn,idx,cel)
	local strSize2 = 18
	local addPosY = 10
	local addPosY2 = 0
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
		strSize2 =22
		addPosY =0
	elseif G_getCurChoseLanguage() =="ru" then
		addPosY =20
		addPosY2 =15
	end
    if fn=="numberOfCellsInTableView" then     
        return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(self.cellWidth,self.cellHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local buffInfo=self.buffCfg[idx+1]
        local titleStr,desc,btnName,iconName,scale=acThreeYearVoApi:getBuffInfo(idx+1)
        if titleStr and desc and btnName and iconName then
	        local iconSize=100
		 	local function nilFunc()
		    end
		    local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("acChunjiepansheng_orangeBg3.png",CCRect(20,20,20,20),nilFunc)
		    backSprie:setContentSize(CCSizeMake(self.cellWidth,self.cellHeight))
		    backSprie:setAnchorPoint(ccp(0,0))
		    backSprie:setPosition(ccp(0,0))
		    cell:addChild(backSprie)
		    local bgSize=backSprie:getContentSize()
	     	local icon=CCSprite:createWithSpriteFrameName(iconName)
	        icon:setAnchorPoint(ccp(0,0.5))
	        icon:setPosition(10,bgSize.height/2)
	        icon:setScale(scale)
	        backSprie:addChild(icon)
		    
	        local titleLb=GetTTFLabelWrap(titleStr,24,CCSizeMake(self.cellWidth-270,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		    titleLb:setAnchorPoint(ccp(0,1))
			titleLb:setColor(G_ColorYellowPro)
			titleLb:setPosition(ccp(120,bgSize.height-30+addPosY2))
			backSprie:addChild(titleLb,2)

			local descLb=GetTTFLabelWrap(desc,strSize2,CCSizeMake(self.cellWidth-270,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		    descLb:setAnchorPoint(ccp(0,1))
			-- descLb:setColor(G_ColorYellowPro)
			descLb:setPosition(ccp(titleLb:getPositionX(),titleLb:getPositionY()-titleLb:getContentSize().height-20+addPosY))
			backSprie:addChild(descLb,2)

			local function goHandler()
				if self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
					if G_checkClickEnable()==false then
					    do
					        return
					    end
					else
					    base.setWaitTime=G_getCurDeviceMillTime()
					end
					acThreeYearVoApi:goBuffAddedDialog(idx+1,self.layerNum+1)
				end
			end
			local goItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",goHandler,11,btnName,25)
			goItem:setAnchorPoint(ccp(0.5,0.5))
			goItem:setScale(0.8)
			local goBtn=CCMenu:createWithItem(goItem)
			goBtn:setTouchPriority(-(self.layerNum-1)*20-3)
			goBtn:setPosition(ccp(backSprie:getContentSize().width-80,self.cellHeight/2))
			backSprie:addChild(goBtn)
        end
        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
       	-- self.isMoved=false
    end
end

function acThreeYearThird:tick()

end

function acThreeYearThird:dispose()
	if self.bgLayer then
		self.bgLayer:removeFromParentAndCleanup(true)
		self.bgLayer=nil
	end
	self.parent=nil
	self.layerNum=nil
	self.cellWidth=G_VisibleSizeWidth-50
	self.cellHeight=150
	self.cellNum=0
	self.buffCfg=nil
	self=nil
end