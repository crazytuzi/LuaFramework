acXinchunhongbaoSmallDialog=smallDialog:new()

function acXinchunhongbaoSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.dialogHeight=400
	self.dialogWidth=550
    self.isToday = false
	return nc
end

function acXinchunhongbaoSmallDialog:create(layerNum,nameStr,uid,callback)
    local sd=acXinchunhongbaoSmallDialog:new()
    sd:init(layerNum,nameStr,uid,callback)
    return sd

end
function acXinchunhongbaoSmallDialog:init(layerNum,nameStr,uid,callback)
    self.isTouch=false
    self.isUseAmi=false
    self.isToday = acXinchunhongbaoVoApi:isToday()
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
      if G_checkClickEnable()==false then
          do
              return
          end
      else
          base.setWaitTime=G_getCurDeviceMillTime()
      end 
      PlayEffect(audioCfg.mouseClick)
      if callback then
        callback()
      end
      return self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
    closeBtnItem:setPosition(ccp(0,0))
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))
     
    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-6)
    self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn,2)


    local titleLb=GetTTFLabel(getlocal("activity_xinchunhongbao_giveFirendsGiftBtn"),40)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-titleLb:getContentSize().height/2-25))
    dialogBg:addChild(titleLb)

    local hasGems = playerVoApi:getGems()
    local smallNeedCost = acXinchunhongbaoVoApi:getSmallCost()
    local bigNeedCost = acXinchunhongbaoVoApi:getBigCost()

    local function nilFun( ... )
    	-- body
    end
    local panelSp =LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),nilFun)
    panelSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,self.bgLayer:getContentSize().height-110))
    panelSp:setAnchorPoint(ccp(0,0))
    panelSp:setPosition(ccp(10,10))
    self.bgLayer:addChild(panelSp,1)

    local function giveGiftHandler(tag,object)
        local free = 1
        if acXinchunhongbaoVoApi:isToday() == false then
            free = 0
        end
      local function giveGiftCallback(fn,data)
        local ret,sData = base:checkServerData(data)
        if ret==true then
        	acXinchunhongbaoVoApi:addHasGiftNumTb(tag)
            local giftName = ""
            local medalNum
            free = 1
            if acXinchunhongbaoVoApi:isToday() == false then
                free = 0
            end
        	if tag==1 then
                if free == 1 then
        		  playerVoApi:setGems(playerVoApi:getGems() - smallNeedCost)
                else
                  acXinchunhongbaoVoApi:updateLastTime()
                  self.isToday = acXinchunhongbaoVoApi:isToday()
                  acXinchunhongbaoVoApi:updateShow()
                end
        		acXinchunhongbaoVoApi:addHasMedals(acXinchunhongbaoVoApi:getSmallGiftGems())
                giftName=getlocal("activity_xinchunhongbao_smallGiftName")
                medalNum=acXinchunhongbaoVoApi:getSmallGiftGems()
        	else
        		playerVoApi:setGems(playerVoApi:getGems() - bigNeedCost)
        		acXinchunhongbaoVoApi:addHasMedals(acXinchunhongbaoVoApi:getBigGiftGems())
                giftName=getlocal("activity_xinchunhongbao_bigGiftName")
                medalNum=acXinchunhongbaoVoApi:getBigGiftGems()
        	end

            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_xinchunhongbao_giveFirendsSuc",{giftName,nameStr,giftName," x"..medalNum}),28)
	        acXinchunhongbaoVoApi:addGiveFriendsList(uid)
	        if callback then
	        	callback()
	        end
	        return self:close()
        end

      end
      if tag == 1 then
        if free == 1 then
          	if  playerVoApi:getGems()<smallNeedCost then
              GemsNotEnoughDialog(nil,nil,smallNeedCost-playerVoApi:getGems(),layerNum+1,smallNeedCost)
              do return end
            end
            local function onConfirm( ... )
              socketHelper:activityXinchunhongbaoGiveGift(tag,uid,giveGiftCallback)
            end
            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("activity_xinchunhongbao_giveFirendsTip",{nameStr,smallNeedCost,getlocal("activity_xinchunhongbao_smallGiftName")}),nil,layerNum+1)
      	 else
            socketHelper:activityXinchunhongbaoGiveGift(tag,uid,giveGiftCallback)
        end

      elseif tag == 2 then	
      	if  playerVoApi:getGems()<bigNeedCost then
          GemsNotEnoughDialog(nil,nil,bigNeedCost-playerVoApi:getGems(),layerNum+1,bigNeedCost)
          do return end
        end

        local function onConfirm( ... )
          socketHelper:activityXinchunhongbaoGiveGift(tag,uid,giveGiftCallback)
        end
        smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("activity_xinchunhongbao_giveFirendsTip",{nameStr,bigNeedCost,getlocal("activity_xinchunhongbao_bigGiftName")}),nil,layerNum+1)
      	
      end
    end

    local smallBtnX = panelSp:getContentSize().width/4
    local bigBtnX = panelSp:getContentSize().width/4*3
    local btnY = 70
    self.smallGiftBtn = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",giveGiftHandler,1,getlocal("activity_xinchunhongbao_giveFirendsGiftBtn"),25,101)
    local smallGiftMenu=CCMenu:createWithItem(self.smallGiftBtn)
    smallGiftMenu:setPosition(ccp(smallBtnX,btnY))
    smallGiftMenu:setTouchPriority(-(layerNum-1)*20-4)
    panelSp:addChild(smallGiftMenu,2)

    self.medalIcon1 = CCSprite:createWithSpriteFrameName("IconGold.png")
    self.medalIcon1:setScale(0.8)
    self.medalIcon1:setAnchorPoint(ccp(1,0.5))
    self.medalIcon1:setPosition(smallBtnX,btnY+60)
    panelSp:addChild(self.medalIcon1)

    self.medalNum1 = GetTTFLabel(tostring(smallNeedCost),25)
    self.medalNum1:setPosition(smallBtnX,btnY+60)
    self.medalNum1:setAnchorPoint(ccp(0,0.5))
    panelSp:addChild(self.medalNum1)

    local smallGiftSp=CCSprite:createWithSpriteFrameName("yuanzhuSp.png")
    smallGiftSp:setAnchorPoint(ccp(0.5,1))
    smallGiftSp:setPosition(smallBtnX,panelSp:getContentSize().height-10)
    panelSp:addChild(smallGiftSp,4)

    local smallGiftIcon = CCSprite:createWithSpriteFrameName("acSmallGift.png")
    --smallGiftIcon:setScale(1.2)
    smallGiftIcon:setAnchorPoint(ccp(0.5,0))
    smallGiftIcon:setPosition(smallGiftSp:getContentSize().width/2,smallGiftSp:getContentSize().height/2-30)
    smallGiftSp:addChild(smallGiftIcon)


    local smallGiftName = GetTTFLabelWrap(getlocal("activity_xinchunhongbao_smallGiftName"),25,CCSizeMake(smallGiftSp:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    smallGiftName:setAnchorPoint(ccp(0.5,1))
    smallGiftName:setPosition(smallGiftSp:getContentSize().width/2,smallGiftSp:getContentSize().height/2-50)
    smallGiftSp:addChild(smallGiftName)

    local smallButtomSp = CCSprite:createWithSpriteFrameName("expedition_bg2.png")
    smallButtomSp:setScaleY(0.5)
    smallButtomSp:setScaleX(1.2)
    smallButtomSp:setPosition(smallBtnX,panelSp:getContentSize().height-smallGiftSp:getContentSize().height)
    panelSp:addChild(smallButtomSp,3)
    --smallButtomSp:setColor(ccc(238,207,0))


    local bigGiftBtn = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",giveGiftHandler,2,getlocal("activity_xinchunhongbao_giveFirendsGiftBtn"),25,102)
    local bigGiftMenu=CCMenu:createWithItem(bigGiftBtn)
    bigGiftMenu:setPosition(ccp(bigBtnX,btnY))
    bigGiftMenu:setTouchPriority(-(layerNum-1)*20-4)
    panelSp:addChild(bigGiftMenu,2)

    local medalIcon2 = CCSprite:createWithSpriteFrameName("IconGold.png")
    medalIcon2:setScale(0.8)
    medalIcon2:setAnchorPoint(ccp(1,0.5))
    medalIcon2:setPosition(bigBtnX,btnY+60)
    panelSp:addChild(medalIcon2)

    local medalNum2 = GetTTFLabel(tostring(bigNeedCost),25)
    medalNum2:setPosition(bigBtnX,btnY+60)
    medalNum2:setAnchorPoint(ccp(0,0.5))
    panelSp:addChild(medalNum2)

    local bigGiftSp=CCSprite:createWithSpriteFrameName("yuanzhuSp.png")
    bigGiftSp:setAnchorPoint(ccp(0.5,1))
    bigGiftSp:setPosition(bigBtnX,panelSp:getContentSize().height-10)
    panelSp:addChild(bigGiftSp,4)
    bigGiftSp:setColor(ccc3(238,207,0))

    local bigGiftIcon = CCSprite:createWithSpriteFrameName("acBigGift.png")
    --bigGiftIcon:setScale(1.2)
    bigGiftIcon:setAnchorPoint(ccp(0.5,0))
    bigGiftIcon:setPosition(bigGiftSp:getContentSize().width/2,bigGiftSp:getContentSize().height/2-30)
    bigGiftSp:addChild(bigGiftIcon)

    local bigGiftName = GetTTFLabelWrap(getlocal("activity_xinchunhongbao_bigGiftName"),25,CCSizeMake(bigGiftSp:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    bigGiftName:setAnchorPoint(ccp(0.5,1))
    bigGiftName:setPosition(bigGiftSp:getContentSize().width/2,bigGiftSp:getContentSize().height/2-50)
    bigGiftSp:addChild(bigGiftName)

    local bigButtomSp = CCSprite:createWithSpriteFrameName("expedition_bg1.png")
    bigButtomSp:setScaleY(0.5)
    bigButtomSp:setScaleX(1.2)
    bigButtomSp:setPosition(bigBtnX,panelSp:getContentSize().height-bigGiftSp:getContentSize().height)
    panelSp:addChild(bigButtomSp,3)
    

    if hasGems>=smallNeedCost then
    	self.medalNum1:setColor(G_ColorWhite)
    else
    	self.medalNum1:setColor(G_ColorRed)
    end

    if hasGems>=bigNeedCost then
    	medalNum2:setColor(G_ColorWhite)
    else
    	medalNum2:setColor(G_ColorRed)
    end
    self:updateShowBtn()

end

function acXinchunhongbaoSmallDialog:updateShowBtn()
   if acXinchunhongbaoVoApi:isToday()==false then
    if self.smallGiftBtn then
        local smallBtnLabel=tolua.cast(self.smallGiftBtn:getChildByTag(101),"CCLabelTTF")
        smallBtnLabel:setString(getlocal("activity_xinchunhongbao_giveFirendsGiftBtnFree"))
    end
    if self.medalIcon1 and self.medalNum1 then
        self.medalIcon1:setVisible(false)
        self.medalNum1:setVisible(false)
    end
   else
    if self.smallGiftBtn then
        local smallBtnLabel=tolua.cast(self.smallGiftBtn:getChildByTag(101),"CCLabelTTF")
        smallBtnLabel:setString(getlocal("activity_xinchunhongbao_giveFirendsGiftBtn"))
    end
    if self.medalIcon1 and self.medalNum1 then
        self.medalIcon1:setVisible(true)
        self.medalNum1:setVisible(true)
    end
   end
end


function acXinchunhongbaoSmallDialog:tick()
    local istoday =acXinchunhongbaoVoApi:isToday()
    if istoday ~= self.isToday then
        self:updateShowBtn()
        self.isToday = istoday
        acXinchunhongbaoVoApi:updateShow()
    end
end



