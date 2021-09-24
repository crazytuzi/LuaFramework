BossBattleMyselfAttack=smallDialog:new()

function BossBattleMyselfAttack:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.dialogHeight=400
	self.dialogWidth=550
	self.attackSelf=false

	return nc
end

function BossBattleMyselfAttack:create(layerNum)
    local sd=BossBattleMyselfAttack:new()
    sd:init(layerNum,nameStr,uid,callback)
    return sd

end
function BossBattleMyselfAttack:init(layerNum)
    self.isTouch=false
    self.isUseAmi=false
    self.layerNum = layerNum
    local function touchHandler()
    
    end
    
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),touchHandler)
    self.dialogLayer=CCLayer:create()
    
    self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(550,550)
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
      return self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
    closeBtnItem:setPosition(ccp(0,0))
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))
     
    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-6)
    self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn,2)

    local titleLb=GetTTFLabel(getlocal("award"),40)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-titleLb:getContentSize().height/2-25))
    dialogBg:addChild(titleLb)

    local desc = GetTTFLabelWrap(getlocal("BossBattle_MyselfAttack_desc"),30,CCSizeMake(self.bgLayer:getContentSize().width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    desc:setAnchorPoint(ccp(0.5,0.5))
    desc:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2+50)
    self.bgLayer:addChild(desc)

    local function touch( ... )
    	if self.attackSelf==false then

    		self.attackSelf=true
    		self.attackMyselfSp:setVisible(true)
    	else
    		self.attackSelf=false
    		self.attackMyselfSp:setVisible(false)
    	end

    end

    local AttackSelfbgSp = GetButtonItem("LegionCheckBtnUn.png","LegionCheckBtnUn.png","LegionCheckBtnUn.png",touch,5,nil)
	  AttackSelfbgSp:setAnchorPoint(ccp(0,0.5))
	  self.attackSelfBtn=CCMenu:createWithItem(AttackSelfbgSp)
	  self.attackSelfBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	  self.attackSelfBtn:setPosition(50,140)
	  self.bgLayer:addChild(self.attackSelfBtn)

	  self.attackMyselfSp=CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
	  self.attackMyselfSp:setAnchorPoint(ccp(0,0.5))
	  self.attackMyselfSp:setPosition(50,140)
	  self.bgLayer:addChild(self.attackMyselfSp)

	  local attackMySelf = GetTTFLabelWrap(getlocal("BossBattle_MyselfAttack_sure"),30,CCSizeMake(self.bgLayer:getContentSize().width-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
      attackMySelf:setAnchorPoint(ccp(0,0.5))
      attackMySelf:setPosition(110,140)
      self.bgLayer:addChild(attackMySelf)

      self.attackMyselfSp:setVisible(false)

    local function onConfirm( ... )
    	if G_checkClickEnable()==false then
          do
              return
          end
      else
          base.setWaitTime=G_getCurDeviceMillTime()
      end 
      PlayEffect(audioCfg.mouseClick)
      if self.attackSelf==true then
      	  local zoneId=tostring(base.curZoneID)
	      local gameUid=tostring(playerVoApi:getUid())
	      local key = G_local_BossAttackSelf..zoneId..gameUid
	      print("key.........",key,self.attackSelf)
	      CCUserDefault:sharedUserDefault():setStringForKey(key,"true")
	      CCUserDefault:sharedUserDefault():flush()
      end
      return self:close()
    end
  	
  	local okItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onConfirm,nil,getlocal("confirm"),25)
	local okBtn=CCMenu:createWithItem(okItem)
	okBtn:setTouchPriority(-(layerNum-1)*20-2)
	okBtn:setAnchorPoint(ccp(0.5,0.5))
	okBtn:setPosition(self.bgLayer:getContentSize().width/2,70)
	self.bgLayer:addChild(okBtn,10)



end




