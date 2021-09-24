acYuandanxianliDialogTab2={}

function acYuandanxianliDialogTab2:new( )
	local nc = {}
	setmetatable(nc,self)
	self.__index=self


	self.bgLayer=nil
	self.layerNum=nil
	self.isToday = false
	return nc
end

function acYuandanxianliDialogTab2:init( layerNum )
	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()

	self:initGift()
	self.isToday =acYuandanxianliVoApi:isStrengToday()


	return self.bgLayer
end

function acYuandanxianliDialogTab2:initGift( )
	
	local yuandanSpr = nil
	yuandanSpr = CCSprite:createWithSpriteFrameName("yuandanPic.png") --元旦图片
	yuandanSpr:setScaleX(0.99)
	yuandanSpr:setScaleY(1.2)
    yuandanSpr:setAnchorPoint(ccp(0.5,1))
    yuandanSpr:setPosition(ccp(self.bgLayer:getContentSize().width*0.5+2,self.bgLayer:getContentSize().height-155))
    self.bgLayer:addChild(yuandanSpr,5)

    local function showInfo()
      if G_checkClickEnable()==false then
          do
              return
          end
      else
          base.setWaitTime=G_getCurDeviceMillTime()
      end 
        PlayEffect(audioCfg.mouseClick)
        local tabStr={};
        local tabColor ={};
        local td=smallDialog:new()
        tabStr = {getlocal("activity_yuandanxianli_tablabel2",24),"\n",getlocal("activity_yuandanxianli_tablabel1",24),"\n",}  --按钮内的说明信息
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25)
        sceneGame:addChild(dialog,self.layerNum+1)
    end

    local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
    infoItem:setScale(0.8)
    infoItem:setAnchorPoint(ccp(1,1))
    infoItem:setScale(0.8)
    local infoBtn = CCMenu:createWithItem(infoItem);
    infoBtn:setAnchorPoint(ccp(1,1))
    infoBtn:setPosition(ccp(G_VisibleSizeWidth-30,G_VisibleSize.height-170))
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer:addChild(infoBtn,5)	--按钮

    local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSprite:setScaleX((G_VisibleSizeWidth)/lineSprite:getContentSize().width)
    lineSprite:setScaleY(1.2)
    lineSprite:setPosition(ccp((G_VisibleSizeWidth)*0.5,self.bgLayer:getContentSize().height - 400))
    self.bgLayer:addChild(lineSprite,6)

  	local characterSp
    characterSp = CCSprite:createWithSpriteFrameName("ShapeCharacter.png") --姑娘
    characterSp:setScale(1.6)
    characterSp:setAnchorPoint(ccp(0,0))
    characterSp:setPosition(ccp(0,25))
    self.bgLayer:addChild(characterSp,6)

    local girlDescBg1=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),function () do return end end)
    girlDescBg1:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,170))
    girlDescBg1:setAnchorPoint(ccp(0,0))
    girlDescBg1:setPosition(ccp(30,self.bgLayer:getContentSize().height*0.36-30))
    self.bgLayer:addChild(girlDescBg1,4)

    local descTv1=G_LabelTableView(CCSize(330,130),getlocal("activity_yuandanxianli_rebate"),25,kCCTextAlignmentLeft)
    descTv1:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    descTv1:setAnchorPoint(ccp(0,0))
    descTv1:setPosition(ccp(girlDescBg1:getContentSize().width*0.5-40,30))
    girlDescBg1:addChild(descTv1,2)
    descTv1:setMaxDisToBottomOrTop(70)

    local girlDescBg2=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),function () do return end end)
    girlDescBg2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,170))
    girlDescBg2:setAnchorPoint(ccp(0,0))
    girlDescBg2:setPosition(ccp(30,self.bgLayer:getContentSize().height*0.12-30))
    self.bgLayer:addChild(girlDescBg2,4)


    local freeTime = {}
    freeTime=acYuandanxianliVoApi:getAccessFreeTime()
    local descTv1=G_LabelTableView(CCSize(300,130),getlocal("activity_yuandanxianli_streng",{freeTime}),25,kCCTextAlignmentLeft)
    descTv1:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    descTv1:setAnchorPoint(ccp(0,0))
    descTv1:setPosition(ccp(girlDescBg2:getContentSize().width*0.5-30,30))
    girlDescBg2:addChild(descTv1,2)
    descTv1:setMaxDisToBottomOrTop(70)


	local function buyGems( )  --跳转到充值页面
		if G_checkClickEnable()==false then
			do
			return
			end
		end
		activityAndNoteDialog:closeAllDialog()
		vipVoApi:showRechargeDialog(self.layerNum+1)--弹出充值页面
	end
    local clickItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",buyGems,idx,getlocal("activity_heartOfIron_goto"),25)
    clickItem:setScaleY(0.9)
	local clickItemBtn=CCMenu:createWithItem(clickItem)
	clickItemBtn:setAnchorPoint(ccp(0.5,0))
	clickItemBtn:setScaleY(0.9)
	clickItemBtn:setPosition(ccp(self.bgLayer:getContentSize().width-120,girlDescBg1:getPositionY()-30))
	clickItemBtn:setTouchPriority(-(self.layerNum-1)*20-3)
	self.bgLayer:addChild(clickItemBtn,5)


	local function onGotoAccessory()
		if(playerVoApi:getPlayerLevel()<accessoryCfg.accessoryUnlockLv)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("elite_challenge_unlock_level",{accessoryCfg.accessoryUnlockLv}),30)
		else
			activityAndNoteDialog:closeAllDialog()
			local function onShowAccessory()
				accessoryVoApi:showAccessoryDialog(sceneGame,3)
			end
			local callFunc=CCCallFunc:create(onShowAccessory)
			local delay=CCDelayTime:create(0.4)
			local acArr=CCArray:create()
			acArr:addObject(delay)
			acArr:addObject(callFunc)
			local seq=CCSequence:create(acArr)
			sceneGame:runAction(seq)
		end
	end
	local upgradeItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",onGotoAccessory,2,getlocal("activity_heartOfIron_goto"),25)
	upgradeItem:setScaleY(0.9)
	local upgradeBtn=CCMenu:createWithItem(upgradeItem)
	upgradeBtn:setAnchorPoint(ccp(0.5,0))
	upgradeBtn:setScaleY(0.9)
	upgradeBtn:setPosition(ccp(self.bgLayer:getContentSize().width-120,girlDescBg2:getPositionY()-30))
    upgradeBtn:setTouchPriority(-(self.layerNum-1)*20-2);
	self.bgLayer:addChild(upgradeBtn,5)


	local strengTime ,xianZhi
	strengTime=acYuandanxianliVoApi:getCurStreng()
	xianZhi = acYuandanxianliVoApi:getAccessFreeTime()
	self.nowStrengTime = GetTTFLabelWrap(getlocal("daily_lotto_tip_3",{strengTime,xianZhi}),25,CCSizeMake(164,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
    self.nowStrengTime:setAnchorPoint(ccp(1,0.5))
	self.nowStrengTime:setPosition(ccp(self.bgLayer:getContentSize().width-220,girlDescBg2:getPositionY()-30))
	self.bgLayer:addChild(self.nowStrengTime,5)	

end

function acYuandanxianliDialogTab2:tick()
	local today = acYuandanxianliVoApi:isStrengToday()
  if today==false then
    self.isToday = today
    acYuandanxianliVoApi:updateStrengTime()
    acYuandanxianliVoApi:refreshCurStreng()
    self:refresh()
  end
end

function acYuandanxianliDialogTab2:refresh()
	local strengTime ,xianZhi
	strengTime=acYuandanxianliVoApi:getCurStreng()
	xianZhi = acYuandanxianliVoApi:getAccessFreeTime()
	self.nowStrengTime=tolua.cast(self.nowStrengTime,"CCLabelTTF")
	self.nowStrengTime:setString(getlocal("daily_lotto_tip_3",{strengTime,xianZhi}))
end

function acYuandanxianliDialogTab2:dispose()
	self.bgLayer:removeFromParentAndCleanup(true)
	self.bgLayer=nil
	self.layerNum=nil
end