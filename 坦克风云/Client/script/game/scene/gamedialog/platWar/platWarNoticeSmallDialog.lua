platWarNoticeSmallDialog=smallDialog:new()

function platWarNoticeSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.descNum=20
	self.dialogWidth=540
	self.dialogHeight=700
	self.cellWidth=self.dialogWidth-40
	self.descTb={}
	self.descHeightTb={}
	self.totalHeight=0
	self.keyTb={}
	self.bgTab={}

	return nc
end

function platWarNoticeSmallDialog:init(layerNum,callback)
	self.layerNum=layerNum
	self.callback=callback

	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),nilFunc)
	self.dialogLayer=CCLayer:create()
	local size=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer=dialogBg
	self.bgLayer:setContentSize(size)
	self:show()
	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(self.bgLayer,2);
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-2)
	self.dialogLayer:setBSwallowsTouches(true);

	local selectLb=GetTTFLabelWrap(getlocal("plat_war_select_text"),25,CCSizeMake(self.cellWidth-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    selectLb:setAnchorPoint(ccp(0.5,0.5))
	selectLb:setPosition(ccp(self.dialogWidth/2,45))
	self.bgLayer:addChild(selectLb,2)
	selectLb:setColor(G_ColorYellowPro)

	self:initTableView()
	self:initArrow(self.bgLayer)
	self:tick()
	base:addNeedRefresh(self)

    local function touchDialog()
        -- PlayEffect(audioCfg.mouseClick)
        -- print("~~~~~~~2")
        -- self:close()
    end
	--遮罩层
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(touchDialogBg,1)
		
	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(ccp(0,0))

end

function platWarNoticeSmallDialog:initTableView()
    local function callBack(...)
    	return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.cellWidth,self.dialogHeight-140),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,100))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(120)
    if self.refreshData==nil then
    	self.refreshData={}
    end
    self.refreshData.tableView=self.tv
    self:addForbidSp(self.bgLayer,CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight),self.layerNum,true,true)
end

function platWarNoticeSmallDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		local descTb,descHeightTb=self:getContentAndHeight()
    	return SizeOfTable(descTb)
	elseif fn=="tableCellSizeForIndex" then
		local descTb,descHeightTb=self:getContentAndHeight()
		local tmpSize=CCSizeMake(self.cellWidth,descHeightTb[idx+1])
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
    	local cell=CCTableViewCell:new()
    	cell:autorelease()

    	local descTb,descHeightTb,totalHeight,keyTb=self:getContentAndHeight()
    	local descStr=descTb[idx+1]
    	local cellHeight=descHeightTb[idx+1]
    	local keyStr=keyTb[idx+1]

    	local function cellClick(hd,fn,index)
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)

                -- print("descStr",descStr)
                if self.callback then
                	self.callback(descStr,keyStr)
                	if self.bgTab then
                		local bg=tolua.cast(self.bgTab[idx+1],"CCSprite")
                		local function acEnd( ... )
                			if self and self.bgLayer then
	                			self:close()
	                		end
                		end
                		local subfunc=CCCallFuncN:create(acEnd)
				        local fadeIn=CCFadeIn:create(0.3)
				        local fadeOut=CCFadeOut:create(0.3)
				        local fadeArr=CCArray:create()
				        local acArr=CCArray:create()
				        -- acArr:addObject(fadeIn)
				        -- acArr:addObject(fadeOut)
				        acArr:addObject(fadeIn)
				        acArr:addObject(fadeOut)
				        acArr:addObject(subfunc)
				        local subseq=CCSequence:create(acArr)
				        bg:runAction(subseq)
                	end
                end
            end
		end
		local background=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),cellClick)
		background:setTouchPriority(-(self.layerNum-1)*20-2)
		background:setAnchorPoint(ccp(0,1))
		background:setContentSize(CCSizeMake(self.cellWidth,cellHeight))
		background:setPosition(ccp(0,cellHeight))
		cell:addChild(background)
		background:setOpacity(0)
		-- local background=LuaCCSprite:createWithSpriteFrameName("groupSelf.png",cellClick)
		-- background:setTouchPriority(-(self.layerNum-1)*20-2)
		-- background:setAnchorPoint(ccp(0.5,1))
		-- background:setPosition(ccp(self.cellWidth/2+40,cellHeight))
		-- background:setScaleY(cellHeight/background:getContentSize().height)
		-- background:setScaleX(self.cellWidth/background:getContentSize().width)
		-- cell:addChild(background)
		-- background:setOpacity(0)
		table.insert(self.bgTab,background)

		local descLb=GetTTFLabelWrap(descStr,24,CCSizeMake(self.cellWidth,cellHeight+100),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	    descLb:setAnchorPoint(ccp(0,1))
		descLb:setPosition(ccp(10,cellHeight-15))
		cell:addChild(descLb,2)

		local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
		lineSp:setAnchorPoint(ccp(0.5,0.5))
		lineSp:setScaleX(self.cellWidth/lineSp:getContentSize().width)
		lineSp:setScaleY(1.2)
		lineSp:setPosition(ccp(self.cellWidth/2,0))
		cell:addChild(lineSp,2)

    	return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end

function platWarNoticeSmallDialog:getContentAndHeight()
	if self.descTb and SizeOfTable(self.descTb)>0 then
		return self.descTb,self.descHeightTb,self.totalHeight,self.keyTb
	else
		self.totalHeight=0
		for i=1,self.descNum do
			local key="plat_war_notice_desc"..i
			local descStr=getlocal(key)
			local lb=GetTTFLabelWrap(descStr,24,CCSizeMake(self.cellWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			local lbHeight=lb:getContentSize().height+30
			table.insert(self.descTb,descStr)
			table.insert(self.descHeightTb,lbHeight)
			table.insert(self.keyTb,key)
			self.totalHeight=self.totalHeight+lbHeight
		end
		return self.descTb,self.descHeightTb,self.totalHeight,self.keyTb
	end
end

function platWarNoticeSmallDialog:initArrow(parent)
	local posX,posY,posY2=self.dialogWidth/2,parent:getContentSize().height-10,parent:getContentSize().height-30
	self.leftSp=CCSprite:createWithSpriteFrameName("leftBtnGreen.png")
    self.leftSp:setPosition(ccp(posX,posY))
    self.leftSp:setRotation(90)
    parent:addChild(self.leftSp,5)
	local mvTo=CCMoveTo:create(0.5,ccp(posX,posY))
    local fadeIn=CCFadeIn:create(0.5)
    local carray=CCArray:create()
    carray:addObject(mvTo)
    carray:addObject(fadeIn)
    local spawn=CCSpawn:create(carray)
    local mvTo2=CCMoveTo:create(0.5,ccp(posX,posY2))
    local fadeOut=CCFadeOut:create(0.5)
    local carray2=CCArray:create()
    carray2:addObject(mvTo2)
    carray2:addObject(fadeOut)
    local spawn2=CCSpawn:create(carray2)
    local seq=CCSequence:createWithTwoActions(spawn2,spawn)
    self.leftSp:runAction(CCRepeatForever:create(seq))

    posY,posY2=80-0,80+20
    self.rightSp=CCSprite:createWithSpriteFrameName("leftBtnGreen.png")
    self.rightSp:setPosition(ccp(posX,posY))
    self.rightSp:setRotation(-90)
    parent:addChild(self.rightSp,5)
	local mvTo=CCMoveTo:create(0.5,ccp(posX,posY))
    local fadeIn=CCFadeIn:create(0.5)
    local carray=CCArray:create()
    carray:addObject(mvTo)
    carray:addObject(fadeIn)
    local spawn=CCSpawn:create(carray)
    local mvTo2=CCMoveTo:create(0.5,ccp(posX,posY2))
    local fadeOut=CCFadeOut:create(0.5)
    local carray2=CCArray:create()
    carray2:addObject(mvTo2)
    carray2:addObject(fadeOut)
    local spawn2=CCSpawn:create(carray2)
    local seq=CCSequence:createWithTwoActions(spawn2,spawn)
    self.rightSp:runAction(CCRepeatForever:create(seq))
end

function platWarNoticeSmallDialog:tick()
	if self.tv and self.leftSp and self.rightSp then
		local recordPoint=self.tv:getRecordPoint()
		local descTb,descHeightTb,totalHeight=self:getContentAndHeight()
		local diff=totalHeight-(self.dialogHeight-130)
		if recordPoint.y>-diff then
			self.leftSp:setVisible(true)
		else
			self.leftSp:setVisible(false)
		end
		if recordPoint.y>=0 then
			self.rightSp:setVisible(false)
		else
			self.rightSp:setVisible(true)
		end
	end
end


