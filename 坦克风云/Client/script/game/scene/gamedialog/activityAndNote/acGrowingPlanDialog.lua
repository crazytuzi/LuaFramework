acGrowingPlanDialog=commonDialog:new()

function acGrowingPlanDialog:new()
	local nc=commonDialog:new()
    setmetatable(nc,self)
    self.__index=self
    self.buyItem=nil
    self.viplvLabel=nil
    self.oldVipLv=nil
    self.flicker=nil 
    return nc
end

function acGrowingPlanDialog:initTableView( ... )

	--self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSize.width-20,G_VisibleSize.height-100))
	self.panelLineBg:setVisible(false)

	local capInSet = CCRect(65, 25, 1, 1)
	local function cellClick(...)
  		
    end
	local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",capInSet,cellClick)
   	backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20, 270))
  	backSprie:ignoreAnchorPointForPosition(false);
   	backSprie:setAnchorPoint(ccp(0.5,1));
   	backSprie:setIsSallow(false)
   	backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
   	backSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-90));
   	self.bgLayer:addChild(backSprie,1)

   	local iconSp=CCSprite:createWithSpriteFrameName("Icon_grown.png")
    iconSp:setAnchorPoint(ccp(0,1))
    iconSp:setPosition(ccp(20,backSprie:getContentSize().height-10))
    backSprie:addChild(iconSp)

    local growingPlanCfg = playerCfg.growingPlan

    local desc1 = GetTTFLabelWrap(getlocal("growingPlanDesc1"),23,CCSizeMake(backSprie:getContentSize().width/2+30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    desc1:setPosition(iconSp:getPositionX()+iconSp:getContentSize().width+10,backSprie:getContentSize().height-60)
    desc1:setAnchorPoint(ccp(0,0));
    --desc1:setColor(G_ColorGreen)
    backSprie:addChild(desc1,2)

    local desc2 = GetTTFLabelWrap(getlocal("growingPlanGlodsDesc1",{growingPlanCfg.costGolds}),23,CCSizeMake(backSprie:getContentSize().width/2+30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    desc2:setPosition(iconSp:getPositionX()+iconSp:getContentSize().width+10,backSprie:getContentSize().height-60)
    desc2:setAnchorPoint(ccp(0,1));
    desc2:setColor(G_ColorYellow)
    backSprie:addChild(desc2,2)

    local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSprite:setAnchorPoint(ccp(0.5,0.5))
    lineSprite:setScaleX(0.8)
    lineSprite:setPosition(backSprie:getContentSize().width/2,backSprie:getContentSize().height/2)
    backSprie:addChild(lineSprite)
    
    local noteLabel= GetTTFLabelWrap(getlocal("growingPlanNote"),25,CCSizeMake((backSprie:getContentSize().width-160)/2,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    noteLabel:setPosition(10+(backSprie:getContentSize().width-150)/4,backSprie:getContentSize().height/3)
    noteLabel:setAnchorPoint(ccp(0.5,0.5));
    --noteLabel:setColor(G_ColorRed)
    backSprie:addChild(noteLabel,2)

    local numLb = GetTTFLabel(tostring(growingPlanCfg.discount).."%",60)
    numLb:setPosition((backSprie:getContentSize().width-160)/2+10,backSprie:getContentSize().height/3)
    numLb:setAnchorPoint(ccp(0,0.5));
    numLb:setColor(G_ColorYellow)
    backSprie:addChild(numLb,2)

    local allGoldsLb = GetTTFLabel(getlocal("daily_award_tip_3",{growingPlanCfg.allGolds}),25)
    allGoldsLb:setPosition((backSprie:getContentSize().width-160)/2+10+numLb:getContentSize().width/2,backSprie:getContentSize().height/3-numLb:getContentSize().height/2-10)
    allGoldsLb:setAnchorPoint(ccp(0.5,1));
    --noteLabel:setColor(G_ColorRed)
    backSprie:addChild(allGoldsLb,2)

    local buyStr = ""
    local viplV = playerVoApi:getVipLevel() 
    self.oldVipLv=viplV
    if viplV<growingPlanCfg.needVipLv then
      self.viplvLabel = GetTTFLabelWrap(getlocal("growingPlanVip",{growingPlanCfg.needVipLv}),20,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
      self.viplvLabel:setColor(G_ColorRed)

      buyStr=getlocal("recharge")
    else
      self.viplvLabel = GetTTFLabelWrap(getlocal("curVipLevel",{viplV}),20,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
      
      buyStr=getlocal("buy")
    end
    if playerVoApi:getIsBuyGrowingplan()>0 then
      buyStr=getlocal("hasBuy")
    end
    local function touch1( ... )

      if self.tv:getIsScrolled()==true then
          return
      end
      if viplV<growingPlanCfg.needVipLv then
        if G_checkClickEnable()==false then
            do
                return
            end
        end
        PlayEffect(audioCfg.mouseClick)
        vipVoApi:showRechargeDialog(self.layerNum+1)
      else
        local function buyGems( ... )
          -- body
          if G_checkClickEnable()==false then
            do
                return
            end
          end
          PlayEffect(audioCfg.mouseClick)
          vipVoApi:showRechargeDialog(self.layerNum+1)
        end 

        local function touchBuy( ... )
          -- body
          local function callbackBuy(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
              if playerVoApi:getIsBuyGrowingplan()>0 then

                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("growingPlanBuySuc"),30)
                tolua.cast(self.buyItem:getChildByTag(101),"CCLabelTTF"):setString(getlocal("hasBuy"))
                self.buyItem:setEnabled(false)
                self.flicker:setVisible(false)
                self.tv:reloadData()
                acGrowingPlanVoApi:updateShow()
              end
            end
          end
          socketHelper:buyGrowingPlan(callbackBuy)
        end
        if playerVo.gems<tonumber(growingPlanCfg.costGolds) then
          local num=tonumber(growingPlanCfg.costGolds)-playerVo.gems
          local smallD=smallDialog:new()
          smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyGems,getlocal("dialog_title_prompt"),getlocal("gemNotEnough",{tonumber(growingPlanCfg.costGolds),playerVo.gems,num}),nil,self.layerNum+1)
        else
          local smallD=smallDialog:new()
          smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),touchBuy,getlocal("dialog_title_prompt"),getlocal("growingPlanGlodsDesc1",{growingPlanCfg.costGolds}),nil,self.layerNum+1)
        end
      end
    end
    self.buyItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",touch1,0,buyStr,25,101)
    local confirmBtn=CCMenu:createWithItem(self.buyItem);
    confirmBtn:setPosition(ccp(backSprie:getContentSize().width-self.buyItem:getContentSize().width/2-10,backSprie:getContentSize().height/4))
    confirmBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    backSprie:addChild(confirmBtn,1)
    self.flicker=G_addRectFlicker(self.buyItem, 2.3, 1)
    if playerVoApi:getIsBuyGrowingplan()>0 then
      self.buyItem:setEnabled(false)
      self.flicker:setVisible(false)
    else
      self.buyItem:setEnabled(true)
      self.flicker:setVisible(true)
    end

    

	  self.viplvLabel:setPosition(confirmBtn:getPositionX(),backSprie:getContentSize().height/2)
	  self.viplvLabel:setAnchorPoint(ccp(0.5,0));
    backSprie:addChild(self.viplvLabel,2)



  	local function touchHander()
  
  	end
  	local capInSet = CCRect(40, 40, 10, 10);
 	  local exBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,touchHander)
  	exBg:setAnchorPoint(ccp(0.5,0))
  	exBg:setContentSize(CCSize(self.bgLayer:getContentSize().width-40,self.bgLayer:getContentSize().height-270-10-120))
  	exBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,25))
  	self.bgLayer:addChild(exBg)

  	local function cellClick(hd,fn,idx)
    end
  	local headBackSprie =LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",capInSet,cellClick)
    headBackSprie:setContentSize(CCSizeMake(exBg:getContentSize().width-10, 40))
    headBackSprie:ignoreAnchorPointForPosition(false);
    headBackSprie:setAnchorPoint(ccp(0.5,1));
    headBackSprie:setIsSallow(false)
    headBackSprie:setPosition(ccp(exBg:getContentSize().width/2,exBg:getContentSize().height-10));
    exBg:addChild(headBackSprie)

    
    local yy=exBg:getContentSize().height-30
    local playerLevelLabel = GetTTFLabel(getlocal("playerLevel"),20)
    playerLevelLabel:setAnchorPoint(ccp(0.5,0.5))
    playerLevelLabel:setPosition(100,yy)
    exBg:addChild(playerLevelLabel)

    local valueLabel = GetTTFLabel(getlocal("gem"),20)
    valueLabel:setAnchorPoint(ccp(0.5,0.5))
    valueLabel:setPosition(300,yy)
    exBg:addChild(valueLabel)


    local operationLabel = GetTTFLabel(getlocal("alliance_list_scene_operator"),20)
    operationLabel:setAnchorPoint(ccp(0.5,0.5))
    operationLabel:setPosition(500,yy)
    exBg:addChild(operationLabel)


	-- body
	local function callBack(...)
	   return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(exBg:getContentSize().width,exBg:getContentSize().height-55),nil)
	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	--self.tv:setPosition(ccp(30,20))
	self.tv:setAnchorPoint(ccp(0,0))
	self.tv:setPosition(ccp(10,5))

	exBg:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(80)
end


function acGrowingPlanDialog:eventHandler( handler,fn,idx,cel)
	-- body
	if fn=="numberOfCellsInTableView" then
		local lvAndGolds = playerCfg.growingPlan
        local n = SizeOfTable(lvAndGolds.playerLevelAndRewards)
        return n
    elseif fn=="tableCellSizeForIndex" then
   		local tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-80,130)
       	return tmpSize
    elseif fn=="tableCellAtIndex" then
     	local cell=CCTableViewCell:new()
       cell:autorelease()
       --cell:setAnchorPoint(ccp(0,0))
        local function cellClick( ... )
        	
        end
       local bgSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
       bgSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, 120))
       bgSprie:ignoreAnchorPointForPosition(false)
       bgSprie:setAnchorPoint(ccp(0,0))
       bgSprie:setIsSallow(false)
       bgSprie:setTouchPriority(-(self.layerNum-1)*20-2)
       cell:addChild(bgSprie,1)

      local poxY = 60

	    local lvAndGolds = playerCfg.growingPlan

	    local playerLvLabel = GetTTFLabel(tostring(lvAndGolds.playerLevelAndRewards[idx+1]["lv"]),28)
      local levelIcon =CCSprite:createWithSpriteFrameName("IconLevel.png")
      --levelIcon:setContentSize(CCSizeMake(50,50))
	    levelIcon:ignoreAnchorPointForPosition(false)
	    levelIcon:setAnchorPoint(CCPointMake(0.5,0.5))
	    levelIcon:setPosition(ccp(90,poxY))
	    playerLvLabel:setPosition(levelIcon:getContentSize().width/2,levelIcon:getContentSize().height/2)
	    playerLvLabel:setAnchorPoint(ccp(0.5,0.5))
      levelIcon:addChild(playerLvLabel,1)
	    bgSprie:addChild(levelIcon)

       
       local goldsLabel = GetTTFLabel(getlocal("daily_award_tip_3",{lvAndGolds.playerLevelAndRewards[idx+1]["gold"]}),28)
       goldsLabel:setPosition(290,poxY)
       goldsLabel:setAnchorPoint(ccp(0.5,0.5))
       bgSprie:addChild(goldsLabel)

      local  function rewardHandler( ... )
          if G_checkClickEnable()==false then
              do
                  return
              end
          end

          if lvAndGolds.playerLevelAndRewards[idx]~=nil and lvAndGolds.playerLevelAndRewards[idx]["lv"]>playerVoApi:getGrowingPlanRewarded() then
              local function cancleBack( ... )
                
              end
              local cancleSmallD=smallDialog:new()

              cancleSmallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),cancleBack,getlocal("dialog_title_prompt"),getlocal("growingPlanWarning"),nil,self.layerNum+1)
              return
          end
          local function callbackReward(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
              smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("daily_lotto_tip_10")..getlocal("daily_award_tip_3",{lvAndGolds.playerLevelAndRewards[idx+1]["gold"]}) ,30)
              local recordPoint = self.tv:getRecordPoint()
              self.tv:reloadData()
              self.tv:recoverToRecordPoint(recordPoint)
              acGrowingPlanVoApi:updateShow()
            end
          end
          if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
              socketHelper:growingPlanReward(lvAndGolds.playerLevelAndRewards[idx+1]["lv"],callbackReward)
          end
      end 
      local rewardBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",rewardHandler,0,getlocal("daily_scene_get"),28)
      rewardBtn:setAnchorPoint(ccp(0.5, 0.5))
      rewardBtn:setScaleX(0.8)
      rewardBtn:setScaleY(0.8)
      local menuAward=CCMenu:createWithItem(rewardBtn)
      menuAward:setPosition(ccp(490,poxY))
      menuAward:setTouchPriority(-(self.layerNum-1)*20-2)
      cell:addChild(menuAward,1)

      if playerVoApi:getIsBuyGrowingplan()<=0 then
          rewardBtn:setEnabled(false)
      else
          if playerVoApi:getPlayerLevel()<lvAndGolds.playerLevelAndRewards[idx+1]["lv"] then
              rewardBtn:setEnabled(false)
              local LvNotNnoughLabel=GetTTFLabelWrap(getlocal("lv_not_enough"),20,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
              LvNotNnoughLabel:setAnchorPoint(ccp(0.5,0.5))
              LvNotNnoughLabel:setPosition(490,poxY/2)
              cell:addChild(LvNotNnoughLabel,1)
              LvNotNnoughLabel:setColor(G_ColorRed)
              menuAward:setPositionY(LvNotNnoughLabel:getPositionY()+LvNotNnoughLabel:getContentSize().height/2+rewardBtn:getContentSize().height/2-5)
          else
            if playerVoApi:getGrowingPlanRewarded()>=lvAndGolds.playerLevelAndRewards[idx+1]["lv"] then
              menuAward:setVisible(false)
              local hasRewarded = GetTTFLabelWrap(getlocal("activity_hadReward"),30,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
              hasRewarded:setAnchorPoint(ccp(0.5,0.5))
              hasRewarded:setPosition(490,poxY)
              cell:addChild(hasRewarded,1)
              hasRewarded:setColor(G_ColorYellow)
            else
              rewardBtn:setEnabled(true)
            end
        end


      end
       return cell

    elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end

end
function acGrowingPlanDialog:tick()
  local curViplV = playerVoApi:getVipLevel() 
  if self.oldVipLv<2 and curViplV>=2 then
    self.oldVipLv=curViplV
    self.viplvLabel=GetTTFLabelWrap(getlocal("curVipLevel",{viplV}),20,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    tolua.cast(self.buyItem:getChildByTag(101),"CCLabelTTF"):setString(getlocal("buy"))
  end
end
function acGrowingPlanDialog:dispose()
  self.oldVipLv=nil
  self.layerNum = nil
  self.buyItem=nil
  self.viplvLabel=nil
  self.flicker=nil 
  self=nil
end