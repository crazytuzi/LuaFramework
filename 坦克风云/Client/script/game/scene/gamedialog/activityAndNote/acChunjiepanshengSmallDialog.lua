acChunjiepanshengSmallDialog=smallDialog:new()

function acChunjiepanshengSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.cellHight=120
	return nc
end

-- isXiushi:是否有顶部的修饰
function acChunjiepanshengSmallDialog:init(isTouch,isuseami,layerNum,titleStr,bgSrc,dialogSize,bgRect,reward,isXiushi,btnStr,confirmCallback,isUseNewUi,activeKey,titleStr2)
	local strHeight2 = 25
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strHeight2 =40
    end
	self.layerNum=layerNum
	self.reward=reward or {}

	self.dialogWidth=500
	self.dialogHeight=650
	self.isTouch=isTouch
    self.isUseAmi=isuseami
    self.isUseNewUi=isUseNewUi or false
    self.activeKey=activeKey or "chunjiepansheng"
    if bgSrc==nil then
    	bgSrc="TankInforPanel.png"
    end
    if dialogSize==nil then
    	dialogSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
    end
    if bgRect then
    	bgRect=CCRect(130, 50, 1, 1)
    end
	local function nilFunc()
	end

	local dialogBg
	if self.isUseNewUi==true then
		dialogBg=G_getNewDialogBg2(dialogSize,self.layerNum)
	else
		dialogBg=LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,bgRect,nilFunc)
	end
	dialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
    self.bgSize=dialogSize
	self.bgLayer:setContentSize(self.bgSize)
	-- self:show()
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)

	if isXiushi then
		local spriteTitle = CCSprite:createWithSpriteFrameName("ShapeTank.png");
		spriteTitle:setAnchorPoint(ccp(0.5,0.5));
		spriteTitle:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height+20)
		self.bgLayer:addChild(spriteTitle,1)

		local spriteTitle1 = CCSprite:createWithSpriteFrameName("ShapeGift.png");
		spriteTitle1:setAnchorPoint(ccp(0.5,0.5));
		spriteTitle1:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height+20)
		self.bgLayer:addChild(spriteTitle1,1)

		local spriteShapeAperture = CCSprite:createWithSpriteFrameName("ShapeAperture.png");
		spriteShapeAperture:setAnchorPoint(ccp(0.5,0.5));
		spriteShapeAperture:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height+20)
		self.bgLayer:addChild(spriteShapeAperture)
	end
	

	-- title

	local titleFontSize = 24
	if G_isAsia() then
		titleFontSize = 30
	end
	local titleLb=GetTTFLabelWrap(titleStr,titleFontSize,CCSizeMake(G_VisibleSizeWidth-200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLb:setAnchorPoint(ccp(0.5,1))
	titleLb:setColor(G_ColorYellowPro)
	titleLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-strHeight2))
	self.bgLayer:addChild(titleLb,1)

	if titleStr2 then
		local titleLb2=GetTTFLabelWrap(titleStr2,22,CCSizeMake(G_VisibleSizeWidth-200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	    titleLb2:setAnchorPoint(ccp(0.5,0))
		titleLb2:setColor(G_ColorYellowPro)
		titleLb2:setPosition(ccp(self.bgLayer:getContentSize().width/2,8))
		self.bgLayer:addChild(titleLb2,1)
	end

	local function nilFunc()
	end
	local descBg
	if self.isUseNewUi==true then
		descBg = G_createItemKuang(CCSizeMake(self.bgLayer:getContentSize().width-30,self.bgLayer:getContentSize().height-100))
		-- descBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-30,self.bgLayer:getContentSize().height-100))
	    local lightSp=CCSprite:createWithSpriteFrameName("newGreenFadeLight.png")
	    lightSp:setAnchorPoint(ccp(0.5,0))
	    lightSp:setScaleX(2)
	    lightSp:setPosition(descBg:getContentSize().width/2,descBg:getContentSize().height-2)
	    descBg:addChild(lightSp)

	    titleLb:setAnchorPoint(ccp(0.5,0.5))
	    local tmpTitleLb=GetTTFLabel(titleStr,30)
	    local realTitleW=tmpTitleLb:getContentSize().width
	    if realTitleW>titleLb:getContentSize().width then
	        realTitleW=titleLb:getContentSize().width
	    end
        for i=1,2 do
	        local pointSp=CCSprite:createWithSpriteFrameName("newPointRect.png")
	        local anchorX=1
	        local posX=self.bgSize.width/2-(realTitleW/2+20)
	        local pointX=-7
	        if i==2 then
	            anchorX=0
	            posX=self.bgSize.width/2+(realTitleW/2+20)
	            pointX=15
	        end
	        pointSp:setAnchorPoint(ccp(anchorX,0.5))
	        pointSp:setPosition(posX,titleLb:getPositionY())
	        self.bgLayer:addChild(pointSp)

	        local pointLineSp=CCSprite:createWithSpriteFrameName("newPointLine.png")
	        pointLineSp:setAnchorPoint(ccp(0,0.5))
	        pointLineSp:setPosition(pointX,pointSp:getContentSize().height/2)
	        pointSp:addChild(pointLineSp)
	        if i==1 then
	            pointLineSp:setRotation(180)
	        end
	    end
	else
		descBg = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50, 50, 1, 1),nilFunc)
		descBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-30,self.bgLayer:getContentSize().height-200))
	end
	if self.isUseNewUi==true then
		descBg:setPosition(ccp(15,40))
	else
		descBg:setPosition(ccp(15,115))
	end
	descBg:setAnchorPoint(ccp(0,0))
	self.bgLayer:addChild(descBg)

	self.cellNum=SizeOfTable(self.reward)
	--物品列表
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    if self.isUseNewUi==true then
	    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-20,descBg:getContentSize().height-20),nil) 
    	self.tv:setPosition(ccp(10,50))
    else
	    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-20,descBg:getContentSize().height-20),nil) 
	    self.tv:setPosition(ccp(10,125))
    end
    self.tv:setMaxDisToBottomOrTop(100)
    self.tv:setTableViewTouchPriority(-(layerNum-1)*20-5)
    self.bgLayer:addChild(self.tv,1)
    if self.refreshData then
		self.refreshData.tableView=self.tv
    end
	if self.isUseNewUi==false then
	 	--确定
	  	local function sureHandler()
	        if G_checkClickEnable()==false then
				do
					return
				end
			else
				base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
			end
			PlayEffect(audioCfg.mouseClick)
			if(confirmCallback)then
				confirmCallback()
			end
	        self:close()
	    end
	    local str
	    if(btnStr)then
	    	str=btnStr
	    else
	    	str=getlocal("confirm")
	    end
	    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sureHandler,2,str,25)
	    self.sureItem = sureItem
	    local sureMenu=CCMenu:createWithItem(sureItem);
	    sureMenu:setPosition(ccp(dialogBg:getContentSize().width*0.5,65))
	    sureMenu:setTouchPriority(-(self.layerNum-1)*20-5);
	    dialogBg:addChild(sureMenu)
	end
  

    local function touchLuaSpr()
      	if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
            if self.isTouch and self.isTouch==true then
                self:close()
            end
        end
	end
	
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr)
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(0,0))
	self.dialogLayer:addChild(touchDialogBg)

	self:show()


	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(getCenterPoint(sceneGame))
	if self.isUseNewUi==true then
		self:addForbidSp(self.bgLayer,dialogSize,self.layerNum,nil,true,true)
	else
		self:addForbidSp(self.bgLayer,dialogSize,self.layerNum,nil,nil,true)
	end

	if self.sureItem == nil then
		G_addArrowPrompt(self.bgLayer)
	end

	return self.dialogLayer
end

function acChunjiepanshengSmallDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize = CCSizeMake(self.bgLayer:getContentSize().width - 20,self.cellHight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local cellWidth=self.bgLayer:getContentSize().width - 20

        local item = self.reward[idx+1]
        local version
        if self.activeKey == "chunjiepansheng" then
			if acChunjiepanshengVoApi and acChunjiepanshengVoApi.getVersion then
	        	version=acChunjiepanshengVoApi:getVersion()
	        end
	    else
	    	
	    end
        local function showNewPropInfo()
	        G_showNewPropInfo(self.layerNum+1,true,true,nil,item,true)
	        return false
	    end
	    local icon
	    if self.isUseNewUi==true then
        	icon = G_getItemIcon(item,100,true,self.layerNum+1,showNewPropInfo,self.tv,nil,nil,nil,version)
        else
        	icon = G_getItemIcon(item,100,true,self.layerNum+1,nil,self.tv,nil,nil,nil,version)
	    end
		icon:setTouchPriority(-(self.layerNum-1)*20-2)
		cell:addChild(icon)
		icon:setAnchorPoint(ccp(0,0.5))
		icon:setPosition(30, self.cellHight/2)

		-- if self.isUseNewUi==true and (idx+1)~=self.cellNum then
		if self.isUseNewUi==true then
			local function nilFunc()
			end
	    	local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("new_cutline.png",CCRect(26,0,2,6),nilFunc)
		    lineSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,6))
		    lineSp:setPosition(cellWidth/2,0)
		    cell:addChild(lineSp)
		end

		local nameStr=item.name
		local nameLb = GetTTFLabelWrap(nameStr,25,CCSizeMake(250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		nameLb:setAnchorPoint(ccp(0,0.5))
		nameLb:setPosition(ccp(140,self.cellHight/4*3))
		cell:addChild(nameLb,1)

		local numStr=item.num
		local numLb = GetTTFLabelWrap(numStr,25,CCSizeMake(250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		numLb:setAnchorPoint(ccp(0,0.5))
		numLb:setPosition(ccp(140,self.cellHight/4))
		cell:addChild(numLb,1)


        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

function acChunjiepanshengSmallDialog:dispose()
	self.id = nil
	self.checkSp = nil
	self.item = nil
end