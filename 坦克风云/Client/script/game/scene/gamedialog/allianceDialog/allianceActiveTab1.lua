allianceActiveTab1={}

function allianceActiveTab1:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.bgLayer=nil
    self.layerNum=nil
    self.parent=nil

    self.layerList={}
    self.pageList={}

    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/slotMachine.plist")

    return nc
end

function allianceActiveTab1:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    self:initLayer()
    
    return self.bgLayer
end

function allianceActiveTab1:initLayer( ... )


  local function callBack(...)
       return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-40,self.bgLayer:getContentSize().height-295),nil)
  self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
  self.tv:setPosition(ccp(20,120))
  self.bgLayer:addChild(self.tv)
  self.tv:setMaxDisToBottomOrTop(120)


  	local function onConfirm()
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
        local activeTip = ""
        for k,v in pairs(allianceActiveCfg.allianceAdelPoint) do
        	if k and v then
        		activeTip=activeTip..getlocal("alliance_activie_deductActive",{k,v}).."\n"
        	end
        end
        tabStr = {"\n",getlocal("alliance_activie_tip4"),"\n",getlocal("alliance_activie_tip3"),"\n",getlocal("alliance_activie_tip2"),"\n",activeTip,"\n",getlocal("alliance_activie_tip1"),"\n"}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,{nil,G_ColorRed,nil,nil    ,nil,nil,nil,G_ColorGreen,nil,nil,nil})
        sceneGame:addChild(dialog,self.layerNum+1)

	end
	local okItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onConfirm,nil,getlocal("activity_baseLeveling_ruleTitle"),25)
	local okBtn=CCMenu:createWithItem(okItem)
	okBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	okBtn:setAnchorPoint(ccp(0.5,0.5))
	okBtn:setPosition(ccp(self.bgLayer:getContentSize().width/2,70))
	self.bgLayer:addChild(okBtn)


end
function allianceActiveTab1:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return 3
  elseif fn=="tableCellSizeForIndex" then
      local tmpSize
      local cellHeight
      if idx==0 then
      	cellHeight=250
      elseif idx==1 then
      	cellHeight=260
      elseif idx ==2 then
      	cellHeight=120*(#allianceActiveCfg.allianceActivePoint)+60
      end
      tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-40,cellHeight)
      return  tmpSize
  elseif fn=="tableCellAtIndex" then
      local cell=CCTableViewCell:new()
      cell:autorelease()
      local cellWidth = self.bgLayer:getContentSize().width-40
      local spWidth = cellWidth-40
      local cellHeight

      local alliance=allianceVoApi:getSelfAlliance()

      if idx == 0 then
      	cellHeight=250

      	-- public/tankLoadingBar.png
      	-- public/tankLoadingBg.png

      	
      	local function tmpFunc( ... )
      		-- body
      	end
      	local backsprite=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),tmpFunc)
	    backsprite:setIsSallow(true)
	    backsprite:setTouchPriority(-(self.layerNum-1)*20-1)
	    local rect=CCSizeMake(spWidth,cellHeight-40)
	    backsprite:setContentSize(rect)
	    backsprite:ignoreAnchorPointForPosition(false)
	    backsprite:setAnchorPoint(CCPointMake(0.5,0))
	    backsprite:setPosition(CCPointMake(cellWidth/2,0))
	    cell:addChild(backsprite)

	    local function touch1(hd,fn,idx)

  		end
		local vipIcon=LuaCCScale9Sprite:createWithSpriteFrameName("VipIconYellow.png",CCRect(110, 60, 1, 1),touch1)
	    vipIcon:setContentSize(CCSizeMake(300,74))
	    vipIcon:setAnchorPoint(ccp(0.5,0.5))
	    vipIcon:setPosition(ccp(backsprite:getContentSize().width/2,backsprite:getContentSize().height))
	    backsprite:addChild(vipIcon,1)

	    local allianceActiveLv = GetTTFLabel(getlocal("fightLevel",{alliance.alevel}),30)
	    allianceActiveLv:setPosition(vipIcon:getContentSize().width/2,vipIcon:getContentSize().height/2)
	    vipIcon:addChild(allianceActiveLv)

	    AddProgramTimer(backsprite,ccp(backsprite:getContentSize().width/2,backsprite:getContentSize().height/2-10),10,101,"","allianceActiveBg.png","allianceActiveBar.png",11)
      	self.timerSprite = tolua.cast(backsprite:getChildByTag(10),"CCProgressTimer")
      	-- self.timerSprite:setScaleX(0.8)
     	local nowActive = alliance.apoint
	    local maxActive = allianceActiveCfg.ActiveMaxPoint
      	if self.timerSprite then
	      local percentage = nowActive/maxActive
	      self.timerSprite:setPercentage(percentage*100)
	    end

	    self.perLb = tolua.cast(self.timerSprite:getChildByTag(101),"CCLabelTTF")
	    self.perLb:setString(getlocal("scheduleChapter",{nowActive,maxActive}))

	    local timerSpriteWidth=self.timerSprite:getContentSize().width-10 

	    local posTopY = self.timerSprite:getPositionY()+self.timerSprite:getContentSize().height/2+10
	    local posButtomY = self.timerSprite:getPositionY()-self.timerSprite:getContentSize().height/2-10
	    for i=1,5 do
	    	local posX = (backsprite:getContentSize().width/2-timerSpriteWidth/2)+allianceActiveCfg.allianceALevelPoint[i]/allianceActiveCfg.ActiveMaxPoint*timerSpriteWidth--(i-1)*self.timerSprite:getContentSize().width/4*(allianceActiveCfg.allianceALevelPoint[SizeOfTable(allianceActiveCfg.allianceALevelPoint)]/allianceActiveCfg.ActiveMaxPoint)*(allianceActiveCfg.allianceALevelPoint[i]/allianceActiveCfg.allianceALevelPoint[SizeOfTable(allianceActiveCfg.allianceALevelPoint)])
	    	local posY
	    	local topArrow = CCSprite:createWithSpriteFrameName("allianceActiveArow.png")

	    	local lvSpH
	    	local function nilFun( ... )
	    		-- body
	    	end
	    	local lvSp
	    	
			if i==1 or i==2 or i==3 then
				lvSp =LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",CCRect(20,20,10,10),nilFun)
			elseif i==5 then
				lvSp =LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBgSelect.png",CCRect(20,20,10,10),nilFun)
			elseif i==4 then
				lvSp =LuaCCScale9Sprite:createWithSpriteFrameName("allianceActiveLevelSp.png",CCRect(10,10,1,1),nilFun)

			end
		    
	    	if i ==1 or i==3 or i== 5 then
	    		posY=posTopY
	    		topArrow:setRotation(90)
	    		lvSpH=posY+topArrow:getContentSize().height
	    	elseif i==2 or i==4 then
	    		posY=posButtomY
	    		topArrow:setRotation(270)

	    		lvSpH=posY-topArrow:getContentSize().height
	    	end
	    	topArrow:setPosition(posX,posY)
	    	backsprite:addChild(topArrow,2)


	    	lvSp:setContentSize(CCSizeMake(80, 50))
	    	lvSp:ignoreAnchorPointForPosition(false)
	    	--backSprie:setAnchorPoint(ccp(0,0))
	   		lvSp:setIsSallow(false)
		    lvSp:setTouchPriority(-(self.layerNum-1)*20-4)
	    	lvSp:setPosition(ccp(posX, lvSpH))
	    	backsprite:addChild(lvSp,5)

	    	local lvLb = GetTTFLabel(getlocal("fightLevel",{i}),25)
	    	lvLb:setPosition(lvSp:getContentSize().width/2,lvSp:getContentSize().height/2)
	    	lvSp:addChild(lvLb)

	    end

      elseif idx==1 then
      	cellHeight=260

      	self.activeWelfare = GetTTFLabelWrap(getlocal("alliance_activie_Welfare",{alliance.alevel}),30,CCSizeMake(cellWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
      	self.activeWelfare:setAnchorPoint(ccp(0.5,0))
      	self.activeWelfare:setPosition(cellWidth/2,210)
      	cell:addChild(self.activeWelfare)
      	self.activeWelfare:setColor(G_ColorGreen)

      	local len = SizeOfTable(allianceActiveCfg.allianceActiveReward)

		for i=1,len do
			local function touch(hd,fn,idx)
		    end
		    local vipBgSprie=LuaCCScale9Sprite:createWithSpriteFrameName("VipLineYellow.png",CCRect(20, 20, 10, 10),touch)
		    vipBgSprie:setContentSize(CCSizeMake(spWidth,200))
		    vipBgSprie:ignoreAnchorPointForPosition(false)
		    vipBgSprie:setAnchorPoint(ccp(0.5,0))
		    vipBgSprie:setIsSallow(false)
		    vipBgSprie:setTouchPriority(-(self.layerNum-1)*20-1)
		    vipBgSprie:setPosition(ccp(cellWidth/2,0))
		    cell:addChild(vipBgSprie,1)

		    local arowStr =""
	    	if alliance.alevel>=i then
	    		arowStr="SlotArowRed.png"
	    	else
	    		arowStr="SlotArow.png"
	    	end

	    	local  strSize = 25
    		if G_getCurChoseLanguage() =="de" or G_getCurChoseLanguage() =="en" or G_getCurChoseLanguage() =="in" or G_getCurChoseLanguage() =="tu" or G_getCurChoseLanguage() =="ru" then
	    		strSize =22
	    	end
		    if allianceActiveCfg.ActiveDonateCount[i]==1 then
		    	local leftArrow2 = CCSprite:createWithSpriteFrameName(arowStr)
	    		leftArrow2:setPosition(ccp(40,vipBgSprie:getContentSize().height/2))
	    		vipBgSprie:addChild(leftArrow2)
	    		leftArrow2:setRotation(-90)
	    		local desc2
	    		if  allianceActiveCfg.allianceActiveReward[i]==0 then
	    			desc2 =GetTTFLabelWrap(getlocal("alliance_activie_noReward"),strSize,CCSizeMake(vipBgSprie:getContentSize().width-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	    			desc2:setColor(G_ColorYellow)
	    		else
	    			desc2 =GetTTFLabelWrap(getlocal("alliance_activie_collectResource",{allianceActiveCfg.allianceActiveReward[i]*100}),strSize,CCSizeMake(vipBgSprie:getContentSize().width-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	    		end
	    		desc2:setAnchorPoint(ccp(0,1))
	    		desc2:setPosition(60,vipBgSprie:getContentSize().height/2+10)
	    		vipBgSprie:addChild(desc2)
	    		
		    else



		    	local leftArrow1 = CCSprite:createWithSpriteFrameName(arowStr)
	    		leftArrow1:setPosition(ccp(40,vipBgSprie:getContentSize().height-20))
	    		vipBgSprie:addChild(leftArrow1)
	    		leftArrow1:setRotation(-90)
	    		local desc1 = GetTTFLabelWrap(getlocal("alliance_activie_collectResource",{allianceActiveCfg.allianceActiveReward[i]*100}),strSize,CCSizeMake(vipBgSprie:getContentSize().width-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	    		desc1:setAnchorPoint(ccp(0,1))
	    		desc1:setPosition(60,vipBgSprie:getContentSize().height-10)
	    		vipBgSprie:addChild(desc1)

	    		local leftArrow2 = CCSprite:createWithSpriteFrameName(arowStr)
	    		leftArrow2:setPosition(ccp(40,vipBgSprie:getContentSize().height/2-20))
	    		vipBgSprie:addChild(leftArrow2)
	    		leftArrow2:setRotation(-90)
	    		local desc2 = GetTTFLabelWrap(getlocal("alliance_activie_donate",{allianceActiveCfg.ActiveDonateCount[i]}),strSize,CCSizeMake(vipBgSprie:getContentSize().width-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	    		desc2:setAnchorPoint(ccp(0,1))
	    		desc2:setPosition(60,vipBgSprie:getContentSize().height/2-10)
	    		vipBgSprie:addChild(desc2)


		    end

		    

			self.layerList[i]=vipBgSprie
			self.pageList[i]=i
		end

		self.curPage=self.pageList[alliance.alevel]
		self.pageLayer=pageDialog:new()
		local page=self.curPage
		local isShowBg=false
		local isShowPageBtn=true
		local function onPage(topage)
			if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
				self.curPage=self.pageList[topage]
				self.activeWelfare:setString(getlocal("alliance_activie_Welfare",{topage}))
			end
		end
		local posY=100
		local leftBtnPos=ccp(20,posY)
		local rightBtnPos=ccp(cellWidth-20,posY)

		local function movedCallback( ... )
			if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
				return true
			else
				return false
			end
		end
		self.pageLayer:create("panelItemBg.png",CCSizeMake(cellWidth,cellHeight),CCRect(20, 20, 10, 10),cell,ccp(0,0),self.layerNum,page,self.layerList,isShowBg,isShowPageBtn,onPage,leftBtnPos,rightBtnPos,movedCallback)
		local maskSpHeight=self.bgLayer:getContentSize().height-133
		for k=1,2 do
			local leftMaskSp=CCSprite:createWithSpriteFrameName("maskBgLeftUse.png")
			leftMaskSp:setAnchorPoint(ccp(0,0))
			leftMaskSp:setPosition(0,38)
			leftMaskSp:setScaleY(maskSpHeight/leftMaskSp:getContentSize().height)
			self.bgLayer:addChild(leftMaskSp,6)

			local rightMaskSp=CCSprite:createWithSpriteFrameName("maskBgLeftUse.png")
			rightMaskSp:setFlipX(true)
			rightMaskSp:setAnchorPoint(ccp(0,0))
			rightMaskSp:setPosition(G_VisibleSizeWidth-rightMaskSp:getContentSize().width,38)
			rightMaskSp:setScaleY(maskSpHeight/rightMaskSp:getContentSize().height)
			self.bgLayer:addChild(rightMaskSp,6)
		end

      	
      elseif idx ==2 then
      	local cfgNum=SizeOfTable(allianceActiveCfg.allianceActivePoint)
      	cellHeight=120*cfgNum+60
      	local rewardTitle = GetTTFLabelWrap(getlocal("alliance_activie_toGetReward"),30,CCSizeMake(cellWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
      	rewardTitle:setPosition(cellWidth/2,cellHeight-30)
      	cell:addChild(rewardTitle)
      	rewardTitle:setColor(G_ColorGreen)
      	for i=1,cfgNum do
      		local posX = 20
      		local posY = (i-1)*120
      		local function touchHander( ... )
      			-- body
      		end
      		local rewardSp = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touchHander)
      		rewardSp:setTouchPriority(-(self.layerNum-1)*20-1)
			local rect=CCSizeMake(400,110)
			rewardSp:setContentSize(rect)
			-- rewardSp:setOpacity(0)
			rewardSp:setAnchorPoint(ccp(0,0))
			rewardSp:setPosition(posX,posY)
			cell:addChild(rewardSp,1)
			local iconStr = ""
			local conditionStr = ""
			local num = 1--allianceActiveCfg.allianceActiveDonate[SizeOfTable(allianceActiveCfg.allianceActiveDonate)-i+1]
			if i == cfgNum then
				iconStr = "Icon_mainui_02.png"
				conditionStr = getlocal("daily_task_name_305",{num})
			elseif i == (cfgNum-1) then
				iconStr = "icon_alliance_war.png"
				conditionStr =  getlocal("daily_task_name_306",{num})
			elseif i== (cfgNum-2) then
				iconStr = "icon_alliance_gem.png"
				conditionStr =  getlocal("daily_task_name_304",{num})
			elseif i == (cfgNum-3) then
				iconStr = "icon_help_defense.png"
				conditionStr =  getlocal("daily_task_name_303",{num})
			elseif i == (cfgNum-4) then
				iconStr = "icon_help_defense.png"
				conditionStr =  getlocal("alliance_help_active",{num})
			end

			local icon = CCSprite:createWithSpriteFrameName(iconStr)
			icon:setAnchorPoint(ccp(0,0.5))
			icon:setPosition(10,rewardSp:getContentSize().height/2)
			rewardSp:addChild(icon)
			
			local conditionLb = GetTTFLabelWrap(conditionStr,25,CCSizeMake(rewardSp:getContentSize().width-120,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			conditionLb:setAnchorPoint(ccp(0,1))
			conditionLb:setPosition(120,rewardSp:getContentSize().height-10)
			rewardSp:addChild(conditionLb)

			local activeNumLb = GetTTFLabelWrap(getlocal("alliance_activie_activieNum",{"+"..allianceActiveCfg.allianceActivePoint[SizeOfTable(allianceActiveCfg.allianceActivePoint)-i+1]}),25,CCSizeMake(rewardSp:getContentSize().width-120,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			activeNumLb:setAnchorPoint(ccp(0,0))
			activeNumLb:setPosition(120,10)
			rewardSp:addChild(activeNumLb)

			local limitSp = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touchHander)
      		limitSp:setTouchPriority(-(self.layerNum-1)*20-1)
			local rect=CCSizeMake(150,110)
			limitSp:setContentSize(rect)
			-- rewardSp:setOpacity(0)
			limitSp:setAnchorPoint(ccp(0,0))
			limitSp:setPosition(posX+rewardSp:getContentSize().width+10,posY)
			cell:addChild(limitSp,1)

            local lbHeight =0
            if G_getCurChoseLanguage() =="en" or G_getCurChoseLanguage() =="de" then
                lbHeight =5
            end
			local todayLimitLb = GetTTFLabelWrap(getlocal("alliance_activie_todayLimit"),25,CCSizeMake(limitSp:getContentSize().width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
			todayLimitLb:setAnchorPoint(ccp(0.5,0))
			todayLimitLb:setPosition(limitSp:getContentSize().width/2,limitSp:getContentSize().height/2-lbHeight)
			limitSp:addChild(todayLimitLb)

			local donateNum = 0
			if alliance.ainfo and alliance.ainfo.a and  alliance.ainfo.a[SizeOfTable(allianceActiveCfg.allianceActive)-i+1] then
				donateNum=alliance.ainfo.a[SizeOfTable(allianceActiveCfg.allianceActive)-i+1]
			end
			local maxNum =allianceActiveCfg.allianceActive[SizeOfTable(allianceActiveCfg.allianceActive)-i+1]
			
			if donateNum>=maxNum then
				donateNum=maxNum
			end
			local stateLb = GetTTFLabelWrap(getlocal("scheduleChapter",{donateNum,maxNum}),25,CCSizeMake(limitSp:getContentSize().width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
			stateLb:setAnchorPoint(ccp(0.5,1))
			stateLb:setPosition(limitSp:getContentSize().width/2,limitSp:getContentSize().height/2)
			limitSp:addChild(stateLb)
			if donateNum>=maxNum then
				stateLb:setColor(G_ColorYellow)
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
       
  elseif fn=="ccScrollEnable" then
      if newGuidMgr:isNewGuiding()==true then
          return 0
      else
          return 1
      end
  end

end


function allianceActiveTab1:refresh()
    if self.tv then
    	self.tv:reloadData()
    end
end


function allianceActiveTab1:dispose()
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/slotMachine.plist")
	if G_isCompressResVersion()==true then
		CCTextureCache:sharedTextureCache():removeTextureForKey("public/slotMachine.png")
	else
		CCTextureCache:sharedTextureCache():removeTextureForKey("public/slotMachine.pvr.ccz")
	end
	
	self.bgLayer=nil
    self.layerNum=nil
    self.parent=nil

	self=nil
end



