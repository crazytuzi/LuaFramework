allianceWarCityRankDialog=smallDialog:new()

function allianceWarCityRankDialog:new(cityData,type)
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.dialogHeight=700
	self.dialogWidth=550
	self.pageCellNum=10
	self.cellHeight=70

	self.cityData=cityData
	self.type=type				--type=1: 不显示投标数额只显示名次; type=2: 显示投标数额和名次
	return nc
end

function allianceWarCityRankDialog:init(layerNum)
	self.layerNum=layerNum

	local function nilFunc()
	end

	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168,86,10,10),nilFunc)
	self.dialogLayer=CCLayer:create()
	
	local size=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer=dialogBg
	self.bgLayer:setContentSize(size)
	self:show()
	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(self.bgLayer,2);
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-2)
	self.dialogLayer:setBSwallowsTouches(true);

	local function close()
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end
	local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
	closeBtnItem:setPosition(0,0)
	closeBtnItem:setAnchorPoint(CCPointMake(0,0))
		 
	self.closeBtn = CCMenu:createWithItem(closeBtnItem)
	self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
	self.closeBtn:setPosition(ccp(size.width-closeBtnItem:getContentSize().width,size.height-closeBtnItem:getContentSize().height))
	dialogBg:addChild(self.closeBtn)
	
	local titleLb=GetTTFLabel(getlocal("allianceWar_bidRankTitle"),40)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height/2-25))
	dialogBg:addChild(titleLb)

	--遮罩层
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc);
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(touchDialogBg,1);

	self:initTableBg()
	self:initTableView()

	sceneGame:addChild(self.dialogLayer,layerNum)
	self.dialogLayer:setPosition(ccp(0,0))
end

function allianceWarCityRankDialog:initTableBg()
	local function nilFunc()
	end
	self.panelLineBg = LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),nilFunc)
	self.panelLineBg:setContentSize(CCSizeMake(self.dialogWidth-20,self.dialogHeight-100))
	self.panelLineBg:setPosition(ccp(self.dialogWidth/2,self.dialogHeight/2-35))
	self.bgLayer:addChild(self.panelLineBg)
    local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("HelpHeaderBg.png",CCRect(20,20,10,10),nilFunc)
    titleBg:setContentSize(CCSizeMake(titleBg:getContentSize().width,self.cellHeight-10))
    titleBg:setScaleX(self.panelLineBg:getContentSize().width/titleBg:getContentSize().width)
    titleBg:setAnchorPoint(ccp(0,1))
    titleBg:setPosition(ccp(0,self.panelLineBg:getContentSize().height))
    self.panelLineBg:addChild(titleBg)
    local titleY=self.panelLineBg:getContentSize().height-(self.cellHeight-10)/2
	local titleRankLb=GetTTFLabel(getlocal("rank"),25)
	titleRankLb:setPosition(ccp(45,titleY))
	self.panelLineBg:addChild(titleRankLb)
	local namePosX
	if(self.type==2)then
		local titlePointLb=GetTTFLabel(getlocal("allianceWar_pointRankTitle"),25)
		titlePointLb:setPosition(ccp(200,titleY))
		self.panelLineBg:addChild(titlePointLb)
		namePosX=420
	else
		namePosX=310
	end
	local titleNameLb=GetTTFLabel(getlocal("alliance_list_scene_alliance_name"),25)
	titleNameLb:setPosition(ccp(namePosX,titleY))
	self.panelLineBg:addChild(titleNameLb)
end

function allianceWarCityRankDialog:initTableView()
	self.tvHeight=self.dialogHeight-170
    local function callBack(...)
    	return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.dialogWidth-30,self.tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(5,10))
    self.panelLineBg:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(self.cellHeight)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function allianceWarCityRankDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		local num=(#self.cityData.bidList)
        if(num > self.pageCellNum)then
        	return self.pageCellNum
        else
    		return num
        end
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(self.dialogWidth,self.cellHeight)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
    	local cell=CCTableViewCell:new()
    	cell:autorelease()
    	local cellData = self.cityData.bidList[idx+1]
        local rankSign
        if(idx>2)then
            rankSign=GetTTFLabel(idx+1,23)
        else
            rankSign=CCSprite:createWithSpriteFrameName("top"..tostring(idx+1)..".png")
            rankSign:setScale(0.7)
        end
        rankSign:setPosition(ccp(45,self.cellHeight/2))
        cell:addChild(rankSign,2)

        local namePosX
        if(cellData.point and self.type==2)then
        	local pointLb=GetTTFLabel(cellData.point,23)
        	pointLb:setPosition(ccp(200,self.cellHeight/2))
        	cell:addChild(pointLb,2)
        	namePosX=420
        else
        	namePosX=310
        end
        local nameLb=GetTTFLabel(cellData.name,23)
        nameLb:setPosition(ccp(namePosX,self.cellHeight/2))
        cell:addChild(nameLb,2)

        local lineSP =CCSprite:createWithSpriteFrameName("LineCross.png");
        lineSP:setAnchorPoint(ccp(0.5,0))
        lineSP:setScaleX(1.2)
        lineSP:setPosition(ccp((self.dialogWidth-20)/2,0))
        cell:addChild(lineSP,1)
    	return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end
