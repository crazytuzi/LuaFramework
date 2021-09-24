acDoorGhostTab1={
   rewardBtnState = nil,
}

function acDoorGhostTab1:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.tv=nil
    self.bgLayer=nil
   
    self.layerNum=nil

    self.isToday =true
    self.spTb={}

    return nc;

end

function acDoorGhostTab1:init(layerNum)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    
    self:initTableView()


    return self.bgLayer
end

function acDoorGhostTab1:initTableView()

  local acVo = acDoorGhostVoApi:getAcVo()
  if acVo ~= nil then
    local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
    local timeLabel=GetTTFLabel(timeStr,26)
    timeLabel:setAnchorPoint(ccp(0.5,0.5))
    timeLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-190))
    self.bgLayer:addChild(timeLabel)
    self.timeLb=timeLabel
    self:updateAcTime()
  end

	self.ghostNumLb =  GetTTFLabelWrap("",30,CCSizeMake(self.bgLayer:getContentSize().width-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	self.ghostNumLb:setAnchorPoint(ccp(0,0.5))
	self.ghostNumLb:setPosition(ccp(30,self.bgLayer:getContentSize().height-230))
  if G_getIphoneType() == G_iphoneX then
    self.ghostNumLb:setPosition(ccp(30,self.bgLayer:getContentSize().height-290))
  end
	self.bgLayer:addChild(self.ghostNumLb)
	self:updateGhostNum()

	local function showInfo()
        PlayEffect(audioCfg.mouseClick)
        local tabStr={};
        local tabColor ={};
        local td=smallDialog:new()
        tabStr = {"\n",getlocal("activity_doorGhost_tip3"),"\n",getlocal("activity_doorGhost_tip2"),"\n",getlocal("activity_doorGhost_tip1"),"\n"}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25)
        sceneGame:addChild(dialog,self.layerNum+1)
    end

    local infoItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon2.png",showInfo,11,nil,nil)
    infoItem:setScale(0.8)
    infoItem:setAnchorPoint(ccp(1,1))
    local infoBtn = CCMenu:createWithItem(infoItem);
    infoBtn:setAnchorPoint(ccp(1,1))
    infoBtn:setPosition(ccp(G_VisibleSizeWidth-35,self.bgLayer:getContentSize().height-190))
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer:addChild(infoBtn,3);


    local function touch()
    end
    local capInSet = CCRect(20, 20, 10, 10)
    local descBg =LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBgSelect.png",capInSet,touch)
    descBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50,150))
    descBg:setAnchorPoint(ccp(0,1))
    descBg:setPosition(ccp(25,self.bgLayer:getContentSize().height-260))
    if G_getIphoneType() == G_iphoneX then
      descBg:setPosition(ccp(25,self.bgLayer:getContentSize().height-320))
    end
    self.bgLayer:addChild(descBg,1)

    local descTv=G_LabelTableView(CCSize(self.bgLayer:getContentSize().width-90,120),getlocal("activity_doorGhost_desc"),25,kCCTextAlignmentCenter)
 	  descTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    descTv:setPosition(ccp(20,15))
    descBg:addChild(descTv,2)
    descTv:setMaxDisToBottomOrTop(50)


  local function callBack(...)
     return self:eventHandler(...)
  end
  local adaH = 0
  if G_getIphoneType() == G_iphoneX then
    adaH = 80
  end
  local hd= LuaEventHandler:createHandler(callBack)
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-40,self.bgLayer:getContentSize().height-570-adaH),nil)
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
  self.tv:setPosition(ccp(10,150))
  self.bgLayer:addChild(self.tv)
  self.tv:setMaxDisToBottomOrTop(120)

  local function ResetHandler( ... )
  	if G_checkClickEnable()==false then
      do
          return
      end
    end

    if newGuidMgr:isNewGuiding()==true then --新手引导
        do
          return
        end
    end
    PlayEffect(audioCfg.mouseClick)

    local free =acDoorGhostVoApi:getFreeRefresh()
    local needGold = acDoorGhostVoApi:getOpenDoorCost()

    local hadOpenDoorNum= acDoorGhostVoApi:getHadOpenDoorNum()
    local maxOpenDoorNum = acDoorGhostVoApi:getMaxOpenDoorNum()

    local function refreshSure( ... )

      local function refreshHandler(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret == true then
          if free == false then
            playerVoApi:setValue("gems",playerVoApi:getGems()-needGold)
          end

          if sData.data.doorGhost then

            acDoorGhostVoApi:updateData(sData.data.doorGhost)
          --acDoorGhostVoApi:refreshData(sData)
            if self.tv then
              self.tv:reloadData()
            end
            self:updateGhostNum()
            self:updateCostOrFree()
          end
        end
      end

      if free== true then
        socketHelper:activityDoorGhostRefresh(1,refreshHandler)
      else
        if playerVoApi:getGems()<needGold then
          local function buyGems()
              vipVoApi:showRechargeDialog(self.layerNum+1)
          end
          local num=tonumber(needGold-playerVoApi:getGems())
          local smallD=smallDialog:new()
          smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyGems,getlocal("dialog_title_prompt"),getlocal("gemNotEnough",{needGold,playerVoApi:getGems(),num}),nil,self.layerNum+1)
          do return end
        else
          local function costRefresh( ... )
            socketHelper:activityDoorGhostRefresh(2,refreshHandler)
          end 

          smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),costRefresh,getlocal("dialog_title_prompt"),getlocal("activity_doorGhost_isCostRefresh",{needGold}),nil,self.layerNum+1)
        end

      end
    end
    if hadOpenDoorNum < maxOpenDoorNum then
      smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),refreshSure,getlocal("dialog_title_prompt"),getlocal("activity_doorGhost_isRefresh"),nil,self.layerNum+1)
    else
      refreshSure()
    end

  end

  local resetBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",ResetHandler,nil,getlocal("dailyTaskReset"),28)
  local resetMenu=CCMenu:createWithItem(resetBtn)
	resetMenu:setAnchorPoint(ccp(0.5,0.5))
	resetMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,70))
	resetMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(resetMenu)

	self.freeLb=GetTTFLabel(getlocal("daily_lotto_tip_2"),25)
	self.freeLb:setPosition(ccp(0.5,0.5))
	self.freeLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,130))
	self.bgLayer:addChild(self.freeLb)

	self.costLb=GetTTFLabel(tostring(acDoorGhostVoApi:getOpenDoorCost()),25)
	self.costLb:setAnchorPoint(ccp(1,0.5))
	self.costLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,130))
	self.bgLayer:addChild(self.costLb)

	self.costIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
	self.costIcon:setAnchorPoint(ccp(0,0.5))
	self.costIcon:setPosition(ccp(self.bgLayer:getContentSize().width/2,130))
	self.bgLayer:addChild(self.costIcon)

	self:updateCostOrFree()

end

function acDoorGhostTab1:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return 1
  elseif fn=="tableCellSizeForIndex" then
    local tmpSize
    self.cellHight = 560
    tmpSize = CCSizeMake(self.bgLayer:getContentSize().width - 40,self.cellHight)
    return  tmpSize
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()


    local hadOpendNum = acDoorGhostVoApi:getHadOpenDoorNum()
    local maxOpenNum = acDoorGhostVoApi:getMaxOpenDoorNum()
    for i=1,6 do
      local id = i
      local iconSprite 
      local rewardCfg = acDoorGhostVoApi:getDoorRewardByID(id)


      if hadOpendNum>= maxOpenNum then
          local icon

            local function nilFun( ... )
              -- body
            end
            
            iconSprite = LuaCCSprite:createWithSpriteFrameName("ghostCardsSp.png",nilFun) 
            if rewardCfg and type(rewardCfg)=="table" then

              for k,v in pairs(rewardCfg) do
                if v then
                  if k == "gt_g1" then
                    icon = CCSprite:createWithSpriteFrameName("ghost.png")
                    icon:setAnchorPoint(ccp(0.5,0.5))
                    icon:setPosition(ccp(iconSprite:getContentSize().width/2,iconSprite:getContentSize().height/2+20))
                    iconSprite:addChild(icon)

                    local numLb = GetTTFLabel(v,30)
                    numLb:setAnchorPoint(ccp(0.5,0.5))
                    numLb:setPosition(iconSprite:getContentSize().width/2,iconSprite:getContentSize().height/2-50)
                    iconSprite:addChild(numLb)
                    numLb:setColor(G_ColorYellow)
                  else
                    if type(v)=="table" and SizeOfTable(v)>0 then
                      local tb = {}
                      tb[k]=v
                      local award = FormatItem(tb) or {}
                      if award ~= nil then
                         for k,v in pairs(award) do
                          local icon, iconScale = G_getItemIcon(v, 100, true, self.layerNum)
                          icon:ignoreAnchorPointForPosition(false)
                          icon:setAnchorPoint(ccp(0.5,0.5))
                          icon:setIsSallow(false)
                          icon:setTouchPriority(-(self.layerNum-1)*20-3)
                          icon:setPosition(ccp(iconSprite:getContentSize().width/2 ,iconSprite:getContentSize().height/2+20))
                          iconSprite:addChild(icon,1)

                          local numLb = GetTTFLabel(v.num,30)
                          numLb:setAnchorPoint(ccp(0.5,0.5))
                          numLb:setPosition(iconSprite:getContentSize().width/2,iconSprite:getContentSize().height/2-50)
                          iconSprite:addChild(numLb)
                          numLb:setColor(G_ColorYellow)

                        end
                      end
                    end
                  end
                end
              end
            end

      else

        if acDoorGhostVoApi:getIsOpenByID(id) == true then
          local icon

            local function nilFun( ... )
              -- body
            end
            
            iconSprite = LuaCCSprite:createWithSpriteFrameName("ghostCardsSp.png",nilFun) 
            if rewardCfg and type(rewardCfg)=="table" then

              for k,v in pairs(rewardCfg) do
                if v then
                  if k == "gt_g1" then
                    icon = CCSprite:createWithSpriteFrameName("ghost.png")
                    icon:setAnchorPoint(ccp(0.5,0.5))
                    icon:setPosition(ccp(iconSprite:getContentSize().width/2,iconSprite:getContentSize().height/2+20))
                    iconSprite:addChild(icon)

                    local numLb = GetTTFLabel(v,30)
                    numLb:setAnchorPoint(ccp(0.5,0.5))
                    numLb:setPosition(iconSprite:getContentSize().width/2,iconSprite:getContentSize().height/2-50)
                    iconSprite:addChild(numLb)
                    numLb:setColor(G_ColorYellow)
                  else
                    if type(v)=="table" and SizeOfTable(v)>0 then
                      local tb = {}
                      tb[k]=v
                      local award = FormatItem(tb) or {}
                      if award ~= nil then
                         for k,v in pairs(award) do
                          local icon, iconScale = G_getItemIcon(v, 100, true, self.layerNum)
                          icon:ignoreAnchorPointForPosition(false)
                          icon:setAnchorPoint(ccp(0.5,0.5))
                          icon:setIsSallow(false)
                          icon:setTouchPriority(-(self.layerNum-1)*20-3)
                          icon:setPosition(ccp(iconSprite:getContentSize().width/2 ,iconSprite:getContentSize().height/2+20))
                          iconSprite:addChild(icon,1)

                          local numLb = GetTTFLabel(v.num,30)
                          numLb:setAnchorPoint(ccp(0.5,0.5))
                          numLb:setPosition(iconSprite:getContentSize().width/2,iconSprite:getContentSize().height/2-60)
                          iconSprite:addChild(numLb)
                          numLb:setColor(G_ColorYellow)

                        end
                      end
                    end
                  end
                end
              end
            end

        else
            local function openDoorHandler( ... )
              if G_checkClickEnable()==false then
                do
                    return
                end
              end

               if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then

                local hadOpenDoorNum= acDoorGhostVoApi:getHadOpenDoorNum()
                local maxOpenDoorNum = acDoorGhostVoApi:getMaxOpenDoorNum()
                if hadOpenDoorNum >= maxOpenDoorNum then
                  smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("activity_doorGhost_needRefresh"),nil,self.layerNum+1)
                  do return end
                end

                local function openDoorSocket(fn,data)
                  local ret,sData=base:checkServerData(data)
                  if ret == true then
                    if sData.data.doorGhost then
                      acDoorGhostVoApi:updateData(sData.data.doorGhost)

                      for k,v in pairs(rewardCfg) do
                        if v then
                          if k == "gt_g1" then
                            local str = getlocal("activity_doorGhost_getGhost",{v})
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,30)
                          else
                            if type(v)=="table" and SizeOfTable(v)>0 then
                              local tb = {}
                              tb[k]=v
                              local award = FormatItem(tb) or {}
                              if award ~= nil then
                                for m,n in pairs(award) do
                                  G_addPlayerAward(n.type,n.key,n.id,n.num,nil,true)
                                end
                                G_showRewardTip(award)
                              end
                            end
                          end
                        end
                      end
                      self:updateGhostNum()
                      self.tv:reloadData()
                    end
                    --acDoorGhostVoApi:updateHadOpenDoorNum(i)
                    
                  end
                end
                socketHelper:activityDoorGhostOpenDoor(i,openDoorSocket)
               end
            end
            iconSprite = LuaCCSprite:createWithSpriteFrameName("door.png",openDoorHandler) 
        end

      end
      -- G_removeFlicker(iconSprite)
      if acDoorGhostVoApi:getIsOpenByID(id) == true then
        G_addRectFlicker(iconSprite,1.8,2.4)
      end
      
      iconSprite:setAnchorPoint(ccp(0,1))
      local pIconX = 110+((i-1)%3)*200
      local pIconY = self.cellHight -(math.floor((i-1)/3))*270-20
      iconSprite:setAnchorPoint(ccp(0.5,1))
      iconSprite:setPosition(ccp(pIconX,pIconY))
      iconSprite:setTouchPriority(-(self.layerNum-1)*20-2)
      cell:addChild(iconSprite)

      self.spTb[i]=iconSprite

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

function acDoorGhostTab1:updateGhostNum()
	local hadOpendNum = acDoorGhostVoApi:getHadOpenDoorNum()
  local maxOpenNum = acDoorGhostVoApi:getMaxOpenDoorNum()
	self.ghostNumLb:setString(getlocal("activity_doorGhost_openDoorNum",{hadOpendNum,maxOpenNum}))
end

function acDoorGhostTab1:updateCostOrFree()
	local isfree = acDoorGhostVoApi:getFreeRefresh()
	if isfree == true then
		self.freeLb:setVisible(true)
		self.costIcon:setVisible(false)
		self.costLb:setVisible(false)
	else
    self.costLb:setString(tostring(acDoorGhostVoApi:getOpenDoorCost()))
		self.freeLb:setVisible(false)
		self.costIcon:setVisible(true)
		self.costLb:setVisible(true)
	end
end

function acDoorGhostTab1:updateAcTime()
    local acVo=acDoorGhostVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acDoorGhostTab1:tick()
  self:updateAcTime()
  if self.isToday ~= acDoorGhostVoApi:isToday() then
    local function refreshHandler(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret == true then
          if sData.data.doorGhost then
            acDoorGhostVoApi:updateData(sData.data.doorGhost)
            if self.tv then
              self.tv:reloadData()
            end
            self:updateGhostNum()
            self:updateCostOrFree()
          end
        end
      end
      socketHelper:activityDoorGhostGetReward(refreshHandler)
  end
end

function acDoorGhostTab1:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.tv=nil
    self.layerNum=nil
    self.spTb=nil
    self.isToday =nil
    self = nil
    
end
