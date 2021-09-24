acXuyuanluHistory=smallDialog:new()

function acXuyuanluHistory:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.dialogHeight=650
	self.dialogWidth=550


	return nc
end

function acXuyuanluHistory:create(layerNum)
    local sd=acXuyuanluHistory:new()
    sd:init(layerNum)
    return sd

end
function acXuyuanluHistory:init(layerNum)
    self.isTouch=fals
    self.isUseAmi=false
    local function touchHandler()
    
    end
    
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),touchHandler)
    self.dialogLayer=CCLayer:create()
    
    self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(550,650)
    self.bgLayer:setContentSize(self.bgSize)
    self:show()
    
    local function touchLuaSpr()

    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1);
    sceneGame:addChild(self.dialogLayer,layerNum)
    
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    

	local function close()
        PlayEffect(audioCfg.mouseClick)
	    return self:close()
	end
	local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
	closeBtnItem:setPosition(ccp(0,0))
	closeBtnItem:setAnchorPoint(CCPointMake(0,0))
     
	self.closeBtn = CCMenu:createWithItem(closeBtnItem)
	self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
	self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
	self.bgLayer:addChild(self.closeBtn,2)
	
    local titleLb=GetTTFLabel(getlocal("activity_xuyuanlu_goldHistoryBtn"),40)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-titleLb:getContentSize().height/2-25))
    dialogBg:addChild(titleLb)

    
    local function confirm()
 		PlayEffect(audioCfg.mouseClick)
	    return self:close()
    end
    local confirmItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnCancleSmall.png",confirm,nil,getlocal("confirm"),25)
    local confirmMenu=CCMenu:createWithItem(confirmItem);
    confirmMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,60))
    confirmMenu:setTouchPriority((-(layerNum-1)*20-4));
    self.bgLayer:addChild(confirmMenu)


    local function nilFun()
	end
    local capInSet = CCRect(20, 20, 10, 10);
	self.backSprite = LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",capInSet,nilFun)
	self.backSprite:setAnchorPoint(ccp(0.5,1))
	self.backSprite:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-100))
	self.backSprite:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-100,self.bgLayer:getContentSize().height-220))
	self.bgLayer:addChild(self.backSprite)

	self.historyList = acXuyuanluVoApi:getGoldHistory()
    if self.historyList and SizeOfTable(self.historyList)>0 then
    	local function callBack(...)
	     	return self:eventHandler(...)
		end
	  	local hd= LuaEventHandler:createHandler(callBack)
	  	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.backSprite:getContentSize().width-20,self.backSprite:getContentSize().height-20),nil)
	  	self.tv:setTableViewTouchPriority(-(layerNum-1)*20-3)
	  	self.tv:setPosition(ccp(10,10))
	  	self.backSprite:addChild(self.tv)
	  	self.tv:setMaxDisToBottomOrTop(120)
    else
    	local noHistoryLb = GetTTFLabelWrap(getlocal("activity_xuyuanlu_noHistory"),25,CCSizeMake(self.backSprite:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    	noHistoryLb:setPosition(self.backSprite:getContentSize().width/2,self.backSprite:getContentSize().height/2)
    	self.backSprite:addChild(noHistoryLb)
    end


    

end


function acXuyuanluHistory:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return SizeOfTable(self.historyList)
  elseif fn=="tableCellSizeForIndex" then
    local tmpSize
    self.cellHeight =100
    tmpSize = CCSizeMake(self.backSprite:getContentSize().width - 20,self.cellHeight)
    return  tmpSize
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    
    local tiSize =23
    local lbSize =20
    if G_getCurChoseLanguage() == "cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage()=="ja" then
        lbSize=27
        lbSize=25
    end

    local title = GetTTFLabelWrap(getlocal("activity_xuyuanlu_HistoryNum",{idx+1}),tiSize,CCSizeMake(self.backSprite:getContentSize().width - 40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    title:setAnchorPoint(ccp(0,1))
    title:setPosition(10,self.cellHeight-5)
    cell:addChild(title)

    local posX = 40
    local posY = self.cellHeight-title:getContentSize().height-40

    local costLb = GetTTFLabel(getlocal("activity_xuyuanlu_costGolds",{acXuyuanluVoApi:getGoldCostByID(idx+1)}),lbSize)
    costLb:setAnchorPoint(ccp(0,0.5))
    costLb:setPosition(posX,posY)
    cell:addChild(costLb)

    posX = posX+costLb:getContentSize().width+20
    local goldSp1 = CCSprite:createWithSpriteFrameName("IconGold.png")
    goldSp1:setPosition(ccp(0,0.5))
    goldSp1:setPosition(posX,posY)
    cell:addChild(goldSp1)

    posX = posX+goldSp1:getContentSize().width

    local gotGoldLb = GetTTFLabel(getlocal("activity_xuyuanlu_getGolds",{self.historyList[idx+1]}),lbSize)
    gotGoldLb:setAnchorPoint(ccp(0,0.5))
    gotGoldLb:setPosition(posX,posY)
    cell:addChild(gotGoldLb)

    posX = posX+gotGoldLb:getContentSize().width+20
    local goldSp2= CCSprite:createWithSpriteFrameName("IconGold.png")
    goldSp2:setPosition(ccp(0,0.5))
    goldSp2:setPosition(posX,posY)
    cell:addChild(goldSp2)


    return cell
  elseif fn=="ccTouchBegan" then
    self.isMoved=false
    return true
  elseif fn=="ccTouchMoved" then
    self.isMoved=true
  elseif fn=="ccTouchEnded"  then
   
  end
end




