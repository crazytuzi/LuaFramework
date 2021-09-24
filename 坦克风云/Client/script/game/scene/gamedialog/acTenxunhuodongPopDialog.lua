acTenxunhuodongPopDialog={}
function acTenxunhuodongPopDialog:new()
    local nc={
            container,
     touchDialogBg,
            isUseAmi,
            require4={}, --4个需求
            updateOnline=nil,
            isShow = false, -- 在线礼包奖励面板是否打开
            id,

          }
    setmetatable(nc,self)
    self.__index=self
    base.allShowedSmallDialog=base.allShowedSmallDialog+1
    return nc
end


function acTenxunhuodongPopDialog:createPowerSurge(container,layerNum,title,desc,award)
    local td=self:new()
    td:initPowerSurge(container,layerNum,title,desc,award)
    self.isUseAmi=true
end


function acTenxunhuodongPopDialog:checkIfBoxOpen()
	return self.isShow
end
function acTenxunhuodongPopDialog:setIsShow(value)
	self.isShow = value
end

function acTenxunhuodongPopDialog:initPowerSurge(parent,layerNum,title,desc,award)
    local function touchDialog()
          
    end

    local rect = CCRect(0, 0, 400, 350)
    local capInSet = CCRect(130, 50, 1, 1)
    local capInSet1 = CCRect(10, 10, 1, 1)


    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",capInSet,touchDialog);
    dialogBg:setContentSize(CCSizeMake(600,500))
    self.container=dialogBg
    
    self.touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",capInSet1,touchDialog);
    self.touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect1=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    self.touchDialogBg:setContentSize(rect1)
    self.touchDialogBg:setOpacity(180)
    self.touchDialogBg:setPosition(getCenterPoint(sceneGame))
    sceneGame:addChild(self.touchDialogBg,layerNum);
    
    local function rightHandler()
        PlayEffect(audioCfg.mouseClick)
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),"领取成功",30)
        self:close()                
    end
    local buttonStr="领取"


    local rightItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",rightHandler,2,buttonStr,25)
    local rightMenu=CCMenu:createWithItem(rightItem);
    rightMenu:setPosition(ccp(dialogBg:getContentSize().width/2,10))
    rightMenu:setTouchPriority(-(layerNum-1)*20-3);
    dialogBg:addChild(rightMenu)
  
	local spriteIcon = CCSprite:create("public/woman.png");
	spriteIcon:setAnchorPoint(ccp(0,0));
	spriteIcon:setPosition(20,170)
    spriteIcon:setScale(0.56)
    spriteIcon:setFlipX(true)
	self.container:addChild(spriteIcon,8)

	local spriteTitle = CCSprite:createWithSpriteFrameName("ShapeTank.png");
	spriteTitle:setAnchorPoint(ccp(0.5,0.5));
	spriteTitle:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height)
	self.container:addChild(spriteTitle,2)

	local spriteTitle1 = CCSprite:createWithSpriteFrameName("ShapeGift.png");
	spriteTitle1:setAnchorPoint(ccp(0.5,0.5));
	spriteTitle1:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height)
	self.container:addChild(spriteTitle1,2)

	local spriteShapeAperture = CCSprite:createWithSpriteFrameName("ShapeAperture.png");
	spriteShapeAperture:setAnchorPoint(ccp(0.5,0.5));
	spriteShapeAperture:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height)
	self.container:addChild(spriteShapeAperture,1)

	local spriteShapeEagle = CCSprite:createWithSpriteFrameName("ShapeEagle.png");
	spriteShapeEagle:setAnchorPoint(ccp(0.5,0.5));
	spriteShapeEagle:setPosition(dialogBg:getContentSize().width/2+60,dialogBg:getContentSize().height-spriteShapeEagle:getContentSize().height/2-60)
	self.container:addChild(spriteShapeEagle,2)
    
    local function shapeDiaTouch()
    
    end
    local rect = CCRect(0, 0, 400, 350)
    local capInSet = CCRect(130, 70, 1, 1)
    local capInSet1 = CCRect(10, 10, 1, 1)
    local spriteShapeDialog =LuaCCScale9Sprite:createWithSpriteFrameName("ShapeDialog.png",capInSet,shapeDiaTouch);
	--local spriteShapeDialog = CCSprite:createWithSpriteFrameName("ShapeDialog.png");
	spriteShapeDialog:setAnchorPoint(ccp(0.5,0.5));
    spriteShapeDialog:setContentSize(CCSizeMake(430,180));
	spriteShapeDialog:setPosition(dialogBg:getContentSize().width/2+60,dialogBg:getContentSize().height-200)
	self.container:addChild(spriteShapeDialog,2)

	local spriteShapeInfor = CCSprite:createWithSpriteFrameName("ShapeInfor.png");
	spriteShapeInfor:setAnchorPoint(ccp(0.5,0));
	spriteShapeInfor:setPosition(dialogBg:getContentSize().width/2+60,30)
	self.container:addChild(spriteShapeInfor,2)

	local titleLb=GetTTFLabel("奖励",30)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(spriteShapeInfor:getContentSize().width/2,spriteShapeInfor:getContentSize().height+17))
	spriteShapeInfor:addChild(titleLb,2)
	titleLb:setColor(G_ColorYellowPro)
  
	local titleDesLb=GetTTFLabelWrap(getlocal("powerSurgeDesc"),22,CCSizeMake(310, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	if desc then
		titleDesLb=GetTTFLabelWrap(desc,22,CCSizeMake(310, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	else

	end
	titleDesLb:setAnchorPoint(ccp(0.5,0.5))
	titleDesLb:setPosition(ccp(spriteShapeDialog:getContentSize().width/2+titleDesLb:getContentSize().width/2-240/2,spriteShapeDialog:getContentSize().height/2))
	spriteShapeDialog:addChild(titleDesLb,2)
  
	--if award then
	if title then
		local tLable=GetTTFLabel(title,30)
		tLable:setAnchorPoint(ccp(0.5,0.5))
		tLable:setPosition(ccp(dialogBg:getContentSize().width/2-60,dialogBg:getContentSize().height-108))
		spriteShapeInfor:addChild(tLable,2)
		tLable:setColor(G_ColorYellowPro)
	end
	if titleLb then
		titleLb:setPosition(ccp(dialogBg:getContentSize().width/2-60,spriteShapeInfor:getContentSize().height+17))	
	end
	if spriteShapeAperture then
		spriteShapeAperture:setPosition(dialogBg:getContentSize().width/2-40,dialogBg:getContentSize().height)
	end
	if spriteShapeEagle then
		spriteShapeEagle:setPosition(dialogBg:getContentSize().width/2+20,dialogBg:getContentSize().height-spriteShapeEagle:getContentSize().height/2-60)
	end

	if spriteShapeInfor then
		spriteShapeInfor:setPosition(dialogBg:getContentSize().width/2+0,30)
	end
    for i=1,4,1 do
        local nameStr=nil
        local numLbStr=nil
        if i==1 then
            _,nameStr=getItem("p20","p")
            numLbStr="×6"
        elseif i==2 then
            _,nameStr=getItem("p292","p")
            numLbStr="×5"
        elseif i==3 then
            _,nameStr=getItem("p17","p")
            numLbStr="×2"
        elseif i==4 then
            _,nameStr=getItem("p12","p")
            numLbStr="×1"
        end

        local spriteIcon = CCSprite:createWithSpriteFrameName("Icon_buff1.png");
        spriteIcon:setAnchorPoint(ccp(0.5,0.5));
        spriteIcon:setPosition(70+(spriteIcon:getContentSize().width+15)*(i-1),spriteShapeInfor:getContentSize().height/2+6);
        spriteShapeInfor:addChild(spriteIcon,2);
        local numLb=GetTTFLabel(numLbStr,20)
        numLb:setAnchorPoint(ccp(1,0));
        numLb:setPosition(ccp(spriteIcon:getContentSize().width-8,4));
        spriteIcon:addChild(numLb,2);

        local sp=CCSprite:createWithSpriteFrameName(nameStr);
        local scale=100/sp:getContentSize().width
        sp:setScale(scale)
        sp:setPosition(ccp(spriteIcon:getContentSize().width/2,spriteIcon:getContentSize().height/2))
        spriteIcon:addChild(sp)
    end


    self.container:setPosition(getCenterPoint(sceneGame))
    sceneGame:addChild(self.container,layerNum+1)
    self:show()

end

--显示面板,加效果
function acTenxunhuodongPopDialog:show()
   local moveTo=CCMoveTo:create(0.3,CCPointMake(G_VisibleSize.width/2,G_VisibleSize.height/2))
   local function callBack()
       base:cancleWait()
   end
   local callFunc=CCCallFunc:create(callBack)
   
   local scaleTo1=CCScaleTo:create(0.1, 1.1);
   local scaleTo2=CCScaleTo:create(0.07, 1);

   local acArr=CCArray:create()
   acArr:addObject(scaleTo1)
   acArr:addObject(scaleTo2)
   acArr:addObject(callFunc)
    
   local seq=CCSequence:create(acArr)
   self.container:runAction(seq)   
end

function acTenxunhuodongPopDialog:close()
	self.updateOnline = nil
	self:setIsShow(false)
    if self.isUseAmi~=nil then
    local function realClose()
    self.touchDialogBg:removeFromParentAndCleanup(true)
        return self:realClose()
    end
   local fc= CCCallFunc:create(realClose)
    local scaleTo1=CCScaleTo:create(0.1, 1.1);
   local scaleTo2=CCScaleTo:create(0.07, 0.8);

   local acArr=CCArray:create()
   acArr:addObject(scaleTo1)
   acArr:addObject(scaleTo2)
   acArr:addObject(fc)
    
   local seq=CCSequence:create(acArr)
   self.container:runAction(seq)
   else
        self:realClose()

   end
   
   
end
function acTenxunhuodongPopDialog:realClose()
    base.allShowedSmallDialog=base.allShowedSmallDialog-1
    self.container:removeFromParentAndCleanup(true)
    self.container=nil

end
function acTenxunhuodongPopDialog:tick()    
end

function acTenxunhuodongPopDialog:dispose() --释放方法

 self.touchDialogBg=nil
    self.container=nil
    for k,v in pairs(self.pp4) do
         k=nil
         v=nil
    end

    self.have4=nil
end
