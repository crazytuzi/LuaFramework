shareSmallDialog=smallDialog:new()
function shareSmallDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

--player:玩家的信息 share:分享的具体数据
function shareSmallDialog:create(bgSrc,inRect,size,player,share,layerNum,closeCallBack,isUseAmi,isTouch)
	self.layerNum=layerNum
   	self.isUseAmi=isUseAmi
    self.isTouch=isTouch
    self.share=share
    if size==nil then
    	size=CCSizeMake(550,500)
    end
    self.bgSize=size
    if bgSrc==nil then
    	bgSrc="PanelHeaderPopup.png"
    end
    if inRect==nil then
    	inRect=CCRect(168,86,10,10)
    end
    local function nilFunc()
    end
    local dialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("newSmallPanelBg.png",CCRect(170,80,22,10),nilFunc)
    self.bgLayer=dialogBg
    dialogBg:setContentSize(size)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)
    self:show()

    local playerNameBg=CCSprite:createWithSpriteFrameName("newTitleBg.png")
    playerNameBg:setAnchorPoint(ccp(0.5,1))
    playerNameBg:setPosition(size.width/2,size.height)
    self.bgLayer:addChild(playerNameBg,3)

    local nameStr=""
    if player and player.name then
    	nameStr=player.name
    end
    local playerNameLb=GetTTFLabelWrap(nameStr,30,CCSizeMake(size.width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    self.playerNameLb=playerNameLb
    playerNameLb:setPosition(getCenterPoint(playerNameBg))
    playerNameBg:addChild(playerNameLb,1)
    self.playerNameBg=playerNameBg

	local detailBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2),nilFunc)
    detailBg:setAnchorPoint(ccp(0.5,1))
    detailBg:setContentSize(CCSizeMake(size.width-20,size.height-100))
    detailBg:setPosition(size.width/2,size.height-90)
    self.bgLayer:addChild(detailBg)
    self.detailBg=detailBg

  	local function close()
        PlayEffect(audioCfg.mouseClick)
	    if closeCallBack then
	      closeCallBack()
	    end
	      return self:close()
  	end
	local closeBtnItem=GetButtonItem("newCloseBtn.png","newCloseBtn_Down.png","newCloseBtn.png",close,nil,nil,nil);
	closeBtnItem:setPosition(0,0)
	closeBtnItem:setAnchorPoint(CCPointMake(1,1))
   	self.closeBtn=CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    self.closeBtn:setPosition(ccp(size.width,size.height))
    self.bgLayer:addChild(self.closeBtn,2)

    self:init()
    self:resetHandler()

    local function touchHandler()
        if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
            if self.isTouch and self.isTouch==true then
                self:close()
            end
        end
    end    
    local touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),touchHandler)
    touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
    local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(255*0.8)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg)

    self.dialogLayer:setPosition(0,0)
    sceneGame:addChild(self.dialogLayer,self.layerNum)
end

function shareSmallDialog:init()
	
end

--具体板子初始化后，板子高度会发生变化，此接口就是重新设置某一些node坐标的
function shareSmallDialog:resetHandler()
	if self.playerNameBg and self.closeBtn then
        self.bgSize=self.bgLayer:getContentSize()
		self.playerNameBg:setPosition(ccp(self.bgSize.width/2,self.bgSize.height))
		self.closeBtn:setPosition(ccp(self.bgSize.width,self.bgSize.height))
	end
	self:resetOther()
end

function shareSmallDialog:resetOther()
	
end

function shareSmallDialog:dispose()
    if self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil
    end
    self.touchDialogBg=nil
    self.playerNameBg,self.playerNameLb=nil,nil
    self.closeBtn=nil
end
