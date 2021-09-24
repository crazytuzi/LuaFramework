selectSearchSmallDialog=smallDialog:new()

function selectSearchSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.reward={}
	self.dialogHeight=450
	self.dialogWidth=550
	-- self.pageCellNum=10
	self.cellHeight=120
	return nc
end

function selectSearchSmallDialog:init(targetName,layerNum)
	self.targetName=targetName
	self.layerNum=layerNum

	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),nilFunc)
	self.dialogLayer=CCLayer:create()
	
	local size=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgSize=size
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


	local lbSize2 = 30
	if G_getCurChoseLanguage() =="ko" then
		lbSize2 =25
	end
	local titleLb=GetTTFLabelWrap(getlocal("select_search_title"),lbSize2,CCSizeMake(self.dialogWidth-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height/2-25))
	dialogBg:addChild(titleLb)


	local descLb = GetTTFLabelWrap(getlocal("select_search_desc",{self.targetName}),25,CCSizeMake(self.bgSize.width-80,0),kCCTextAlignmentCenter,kCCTextAlignmentCenter)
	descLb:setAnchorPoint(ccp(0.5,0.5))
    descLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height/2))
    self.bgLayer:addChild(descLb,1)
    

    local num1=bagVoApi:getItemNumId(3304)
    local num2=bagVoApi:getItemNumId(3305)
	--搜索基地
    local function searchHandler(tag,object)
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

		local function mapRadarscanCallback()
        	self:close()
        end
	    bagVoApi:mapRadarscan("p"..tag,self.targetName,layerNum,mapRadarscanCallback)
    end
    local baseItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",searchHandler,3304,getlocal("search_base_btn"),25)
    local baseMenu=CCMenu:createWithItem(baseItem)
    baseMenu:setPosition(ccp(self.dialogWidth/2-150,60))
    baseMenu:setTouchPriority(-(layerNum-1)*20-4)
    dialogBg:addChild(baseMenu)
    local num1Lb=GetTTFLabel(getlocal("sample_prop_name_3304")..": "..num1,25)
    num1Lb:setPosition(ccp(self.dialogWidth/2-150,110))
    dialogBg:addChild(num1Lb)
    if num1 and num1>0 then
    else
    	num1Lb:setColor(G_ColorRed)
    	baseItem:setEnabled(false)
    end
    

    local fleetItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",searchHandler,3305,getlocal("search_fleet_btn"),25)
    local fleetMenu=CCMenu:createWithItem(fleetItem)
    fleetMenu:setPosition(ccp(self.dialogWidth/2+150,60))
    fleetMenu:setTouchPriority(-(layerNum-1)*20-4)
    dialogBg:addChild(fleetMenu)
    local num2Lb=GetTTFLabel(getlocal("sample_prop_name_3305")..": "..num2,25)
    num2Lb:setPosition(ccp(self.dialogWidth/2+150,110))
    dialogBg:addChild(num2Lb)
    if num2 and num2>0 then
    else
    	num2Lb:setColor(G_ColorRed)
    	fleetItem:setEnabled(false)
    end

	--遮罩层
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc);
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(touchDialogBg,1);

	sceneGame:addChild(self.dialogLayer,layerNum)
	self.dialogLayer:setPosition(ccp(0,0))
end
