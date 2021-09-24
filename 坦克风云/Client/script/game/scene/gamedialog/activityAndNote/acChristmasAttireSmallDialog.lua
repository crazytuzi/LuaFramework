acChristmasAttireSmallDialog=smallDialog:new()

function acChristmasAttireSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acChristmasAttireSmallDialog:showExchangeDialog(bgSrc,size,inRect,title,floorNum,isuseami,layerNum,callBackHandler)
  	local sd=acChristmasAttireSmallDialog:new()
	sd:initExchangeDialog(bgSrc,size,inRect,title,floorNum,isuseami,layerNum,callBackHandler)
end

function acChristmasAttireSmallDialog:initExchangeDialog(bgSrc,size,inRect,title,floorNum,isuseami,layerNum,callBackHandler)
	local strSize2=16
	if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
		strSize2=22
	end
	local exFlag=true --是否可以兑换
	local iconSize=100
	local mSize=80
    local namePosY=-10
    local nameWidth=130
    local nameHeight=0
    local content={}
    local rewardlist=acChristmasAttireVoApi:getRewardList()
    if rewardlist and rewardlist[floorNum] then
        content=FormatItem(rewardlist[floorNum].reward,nil,true)
    end
    for k,v in pairs(content) do
	    if v.type=="h" then
	    	namePosY=-15
	    end
		local nameLb=GetTTFLabelWrap(v.name,22,CCSize(nameWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
		local realH=nameLb:getContentSize().height
		if realH>nameHeight then
			nameHeight=realH
		end
    end
   	local dialogH=280
   	local propHeight=100+math.abs(namePosY)+nameHeight+10
    dialogH=dialogH+propHeight+40

    local promptLb=GetTTFLabelWrap(getlocal("exchange_cost").."：",24,CCSize(size.width-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	dialogH=dialogH+promptLb:getContentSize().height+60
    local materialNum=0
    local materialNumCfg=acChristmasAttireVoApi:getMaterialNumCfg()
    local materials=acChristmasAttireVoApi:getMaterials()
    if materialNumCfg and materialNumCfg[floorNum] then
    	materialNum=materialNumCfg[floorNum]
    end
    local rcount=0
    if materialNum%4>0 then
    	rcount=math.floor(materialNum/4)+1
    else
    	rcount=math.floor(materialNum/4)
    end
    dialogH=dialogH+rcount*mSize

	local function nilFunc() end
	if bgSrc==nil or bgSrc=="" then
		bgSrc="TankInforPanel.png"
	end
	self.isUseAmi=isuseami
	local dialogBg=LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,nilFunc)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
	size=CCSizeMake(size.width,dialogH)
	self.bgSize=size
	self.bgLayer:setContentSize(size)
	self:show()
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)
	local lineWidth=size.width-60
	local posY=self.bgSize.height-70
	if title then
	  	local titleLb=GetTTFLabelWrap(title,35,CCSize(self.bgSize.width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	    titleLb:setAnchorPoint(ccp(0.5,0.5))
	    titleLb:setPosition(ccp(self.bgSize.width/2,posY))
	    self.bgLayer:addChild(titleLb)
	    posY=posY-titleLb:getContentSize().height
	end
    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setAnchorPoint(ccp(0.5,1))
    lineSp:setScaleX(lineWidth/lineSp:getContentSize().width)
    lineSp:setPosition(ccp(self.bgSize.width/2,posY))
    self.bgLayer:addChild(lineSp)
    posY=posY-30

	local bgSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20,20,10,10),nilFunc)
	bgSp:setContentSize(CCSizeMake(size.width-60,propHeight+40))
	bgSp:setAnchorPoint(ccp(0.5,1))
	bgSp:setTouchPriority(-(layerNum-1)*20-2)
	bgSp:setPosition(ccp(size.width/2,posY))
	self.bgLayer:addChild(bgSp)

	local rewardCount=SizeOfTable(content)
	local cellWidth=size.width-80
	local cellHeight=propHeight
	local tvWidth=cellWidth
	local spaceX=0
	if rewardCount<=3 then
		spaceX=10
		cellWidth=rewardCount*nameWidth+(rewardCount-1)*spaceX
		tvWidth=cellWidth
	else
		cellWidth=rewardCount*nameWidth+(rewardCount-1)*spaceX
		tvWidth=size.width-80
	end
	local flick=acChristmasAttireVoApi:getFlick()
	local flickScale=1.3
	local function initRewards(parent)
		if parent==nil then
			do return end
		end

		local tmpPosY=cellHeight-iconSize
		for k,v in pairs(content) do
	        local icon,scale=G_getItemIcon(v,iconSize,true,layerNum)
           	icon:setAnchorPoint(ccp(0,0))
            icon:setPosition(ccp((nameWidth-iconSize)/2+(k-1)*(spaceX+nameWidth),tmpPosY))
            icon:setTouchPriority(-(layerNum-1)*20-3)
            parent:addChild(icon,1)
            icon:setScale(scale)
          	if flick[floorNum] and flick[floorNum]==1 then
                G_addRectFlicker(icon,flickScale,flickScale,ccp(icon:getContentSize().width/2,icon:getContentSize().height/2))
            end
           	local nameLb=GetTTFLabelWrap(v.name,strSize2,CCSize(nameWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	        nameLb:setAnchorPoint(ccp(0.5,1))
	        nameLb:setPosition(ccp(icon:getContentSize().width/2,-10))
	        nameLb:setScale(1/scale)
	        icon:addChild(nameLb)
	        if tonumber(v.num)>0 and v.type~="h" then
		        local numLb=GetTTFLabel(v.num,25)
		        numLb:setAnchorPoint(ccp(1,0))
		        numLb:setScale(1/scale)
		        numLb:setPosition(ccp(icon:getContentSize().width*scale-5,0))
		        icon:addChild(numLb,4)
              	local numBg=CCSprite:createWithSpriteFrameName("allianceHeaderBg.png")
	            numBg:setAnchorPoint(ccp(0.5,0))
	            local scaleX=icon:getContentSize().width/numBg:getContentSize().width
	            local scaleY=1/icon:getScale()*(numLb:getContentSize().height)/numBg:getContentSize().height
	            numBg:setScaleX(scaleX)
	            numBg:setScaleY(scaleY)
	            numBg:setPosition(ccp(icon:getContentSize().width/2,2))
	            numBg:setOpacity(150)
	            icon:addChild(numBg,3)
	        end
		end
	end
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return 1
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(cellWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            initRewards(cell)

            return cell
        elseif fn=="ccTouchBegan" then
            self.isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            self.isMoved=true
        elseif fn=="ccTouchEnded"  then

        end
    end
	local hd=LuaEventHandler:createHandler(tvCallBack)
    self.tv=LuaCCTableView:createHorizontalWithEventHandler(hd,CCSizeMake(tvWidth,cellHeight),nil)
    self.tv:setTableViewTouchPriority(-(layerNum-1)*20-4)
    self.tv:setPosition(ccp((bgSp:getContentSize().width-tvWidth)/2,(bgSp:getContentSize().height-cellHeight)/2))
    bgSp:addChild(self.tv,2)
    if rewardCount>3 then
	    self.tv:setMaxDisToBottomOrTop(120)
	else
	    self.tv:setMaxDisToBottomOrTop(0)
    end
    posY=posY-bgSp:getContentSize().height-20

    promptLb:setAnchorPoint(ccp(0,1))
    promptLb:setPosition(ccp(30,posY))
    self.bgLayer:addChild(promptLb)
	posY=posY-mSize-10-promptLb:getContentSize().height
	spaceX=50
	firstPosX=(size.width-materialNum*mSize-(materialNum-1)*spaceX)/2
   	for k=1,materialNum do
        local pngName=acChristmasAttireVoApi:getMaterialPic(floorNum,k)
        local spBg=CCSprite:createWithSpriteFrameName("material_bg.png")
        spBg:setPosition(ccp(firstPosX+(k-1)%4*(spaceX+mSize),posY))
        spBg:setAnchorPoint(ccp(0,0))
        spBg:setScale(mSize/spBg:getContentSize().width)
        self.bgLayer:addChild(spBg)
        local materialSp=CCSprite:createWithSpriteFrameName(pngName)
        if materialSp then
            materialSp:setPosition(getCenterPoint(spBg))
            spBg:addChild(materialSp)
            local count=0
            if materials and materials[floorNum] and materials[floorNum][k] then
                count=materials[floorNum][k]
            end
        	local needNum=acChristmasAttireVoApi:getExchangeNeed(floorNum)
        	local color=G_ColorWhite
        	if needNum>count then
        		color=G_ColorRed
        		exFlag=false
        	end
            local numLb=GetTTFLabel(FormatNumber(count).."/"..FormatNumber(needNum),22)
            numLb:setScale(1/spBg:getScale())
            numLb:setPosition(ccp(spBg:getContentSize().width/2,numLb:getContentSize().height*numLb:getScale()/2+2))
            numLb:setColor(color)
            spBg:addChild(numLb,5)
            local numBg=CCSprite:createWithSpriteFrameName("allianceHeaderBg.png")
            numBg:setAnchorPoint(ccp(0.5,0))
            local scaleX=spBg:getContentSize().width/numBg:getContentSize().width
            local scaleY=1/spBg:getScale()*(numLb:getContentSize().height-5)/numBg:getContentSize().height
            numBg:setScaleX(scaleX)
            numBg:setScaleY(scaleY)
            numBg:setPosition(ccp(spBg:getContentSize().width/2,5))
            numBg:setOpacity(150)
            spBg:addChild(numBg,3)
        end
        if k%5==0 then
        	posY=posY-(mSize+10)
        end
    end
    posY=posY-20
	local lineSp3=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp3:setAnchorPoint(ccp(0.5,1))
    lineSp3:setScaleX(lineWidth/lineSp3:getContentSize().width)
    lineSp3:setPosition(ccp(self.bgSize.width/2,posY))
    self.bgLayer:addChild(lineSp3)
	--确定
    local function sureHandler()
    	-- print("sureHandler--------")
        if G_checkClickEnable()==false then
			do
				return
			end
		else
			base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
		end
		PlayEffect(audioCfg.mouseClick)
		if exFlag==false then
        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("lack_material"),30)
        	do return end
		end
		if callBackHandler~=nil then
			-- print("callbackSure------~~~~~")
			callBackHandler()
		end
        self:close()
    end
    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sureHandler,2,getlocal("code_gift"),25)
    local sureMenu=CCMenu:createWithItem(sureItem)
    sureMenu:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,70))
    sureMenu:setTouchPriority(-(layerNum-1)*20-2)
    self.bgLayer:addChild(sureMenu)

	local function close()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end
	local closeItem=GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil)
	closeItem:setAnchorPoint(CCPointMake(0,0))
	local closeBtn=CCMenu:createWithItem(closeItem)
	closeBtn:setTouchPriority(-(layerNum-1)*20-4)
	closeBtn:setPosition(ccp(size.width-closeItem:getContentSize().width,size.height-closeItem:getContentSize().height))
	self.bgLayer:addChild(closeBtn)

    local function nilFunc() end
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(0,0))
	self.dialogLayer:addChild(touchDialogBg)

	sceneGame:addChild(self.dialogLayer,layerNum)
	self.dialogLayer:setPosition(getCenterPoint(sceneGame))
	return self.dialogLayer
end