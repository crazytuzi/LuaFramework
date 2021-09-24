acJidongbuduiTab2={}
function acJidongbuduiTab2:new()
	local nc=commonDialog:new()
	setmetatable(nc,self)
	self.__index=self
	self.getTimes=0
	return nc
end

function acJidongbuduiTab2:init(layerNum,parent)
	self.layerNum=layerNum
	self.parent=parent
	self.bgLayer=CCLayer:create()

	-- self:getServerTankData()
	self:initTableView()
	self:update()
	return self.bgLayer
end

function acJidongbuduiTab2:initTableView()


  local characterSp
    if platCfg.platCfgChangeGuideUI[G_curPlatName()] then
        characterSp = CCSprite:create("public/guide.png")
    else
        characterSp = CCSprite:createWithSpriteFrameName("GuideCharacter.png") --姑娘
    end
    characterSp:setAnchorPoint(ccp(0,0))
    characterSp:setPosition(ccp(20,self.bgLayer:getContentSize().height - 520))
    self.bgLayer:addChild(characterSp,5)

    local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSprite:setScaleX((G_VisibleSizeWidth)/lineSprite:getContentSize().width)
    lineSprite:setScaleY(1.2)
    lineSprite:setPosition(ccp((G_VisibleSizeWidth)/2,self.bgLayer:getContentSize().height - 520))
    self.bgLayer:addChild(lineSprite,6)
    
    local girlDescBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),function () do return end end)
    girlDescBg:setContentSize(CCSizeMake(400,240))
    girlDescBg:setAnchorPoint(ccp(0,0))
    girlDescBg:setPosition(ccp(190,self.bgLayer:getContentSize().height - 510))
    self.bgLayer:addChild(girlDescBg,4)

    self.tankAid,self.tankId,self.tankNum = acJidongbuduiVoApi:getTankIdAndNum()
    local cfg = tankCfg[self.tankId]
    local descStr = ""
    local tankName = getlocal(cfg.name)
    local tankCapacity = cfg.carryResource
    local tankSpeed = 1
    descStr=getlocal("activity_jidongbudui_tankDesc1").."\n"..getlocal("activity_jidongbudui_tankName",{tankName}).."\n"..getlocal("activity_jidongbudui_tankCapacity",{tankCapacity}).."\n"..getlocal("activity_jidongbudui_tankDesc2")

    local descTv=G_LabelTableView(CCSize(300,220),descStr,25,kCCTextAlignmentLeft)
    descTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    descTv:setAnchorPoint(ccp(0,0))
    descTv:setPosition(ccp(80,10))
    girlDescBg:addChild(descTv,2)
    descTv:setMaxDisToBottomOrTop(50)
    
    local actTime=GetTTFLabel(getlocal("activity_timeLabel"),30)
    actTime:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-205))
    self.bgLayer:addChild(actTime,5);
    actTime:setColor(G_ColorGreen)
    
    local acVo = acJidongbuduiVoApi:getAcVo()
    if acVo ~= nil then
        local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
        local timeLabel=GetTTFLabel(timeStr,26)
        timeLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2, self.bgLayer:getContentSize().height-240))
        self.bgLayer:addChild(timeLabel)
    end

    local function showInfo()
        PlayEffect(audioCfg.mouseClick)
        local tabStr={};
        local tabColor ={};
        local td=smallDialog:new()
        tabStr = {"\n",getlocal("activity_jidongbudui_Tip4"),"\n",getlocal("activity_jidongbudui_Tip3"),"\n",getlocal("activity_jidongbudui_Tip2"),"\n",getlocal("activity_jidongbudui_Tip1"),"\n"}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25)
        sceneGame:addChild(dialog,self.layerNum+1)
    end

    local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
    --infoItem:setScale(0.8)
    infoItem:setAnchorPoint(ccp(1,1))
    infoItem:setScale(0.8)
    local infoBtn = CCMenu:createWithItem(infoItem);
    infoBtn:setAnchorPoint(ccp(1,1))
    infoBtn:setPosition(ccp(G_VisibleSizeWidth-35,self.bgLayer:getContentSize().height-175))
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer:addChild(infoBtn,3)
end

function acJidongbuduiTab2:updateturkeyNum()
 if self.turkeyNum then
    self.turkeyNum:setString(tostring(acJidongbuduiVoApi:getTurkeyNum()))
  end
end
function acJidongbuduiTab2:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return 1
  elseif fn=="tableCellSizeForIndex" then
    local tmpSize
    tmpSize = CCSizeMake(self.bgLayer:getContentSize().width-60,self.bgLayer:getContentSize().height-560)
    return  tmpSize
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()


    self.serverLeftNum = acJidongbuduiVoApi:getServerLeftTankNum()
	self.exChangeTankNum = acJidongbuduiVoApi:getExChangeTankNum()
	local showMax = acJidongbuduiVoApi:getServerTankShowMax()
	local mySelfLimit = acJidongbuduiVoApi:getSelfTankMax()
 	local strSize2 = 25
 	if G_getCurChoseLanguage() =="in" then
 		strSize2 =22
 	end

	if (self.serverLeftNum>0) and (self.exChangeTankNum<mySelfLimit) then
		local function nilFun()
		end
	    local capInSet = CCRect(20, 20, 10, 10);
		local exChangeBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",capInSet,nilFun)
		exChangeBg:setAnchorPoint(ccp(0,0))
		exChangeBg:setPosition(ccp(0,0))
		exChangeBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,self.bgLayer:getContentSize().height-560))
		cell:addChild(exChangeBg)

		local descLb = GetTTFLabelWrap(getlocal("activity_jidongbudui_wajuejiDesc"),strSize2,CCSizeMake(exChangeBg:getContentSize().width/2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		descLb:setAnchorPoint(ccp(0,1))
		descLb:setPosition(15,exChangeBg:getContentSize().height-20)
		exChangeBg:addChild(descLb)

		local turkeyIcon = CCSprite:createWithSpriteFrameName("Turkey.png")
		--turkeyIcon:setScale(0.5)
		turkeyIcon:setAnchorPoint(ccp(0,0))
		turkeyIcon:setPosition(exChangeBg:getContentSize().width/2+10,exChangeBg:getContentSize().height-turkeyIcon:getContentSize().height-10)
		exChangeBg:addChild(turkeyIcon)

		self.turkeyNum = GetTTFLabel("",30)
		self.turkeyNum:setAnchorPoint(ccp(0,0))
		self.turkeyNum:setPosition(exChangeBg:getContentSize().width/2+30+turkeyIcon:getContentSize().width,exChangeBg:getContentSize().height-turkeyIcon:getContentSize().height)
		exChangeBg:addChild(self.turkeyNum)
    	self:updateturkeyNum()

    	local needPartsNum = acJidongbuduiVoApi:getExchangeTankNeedParts()
    	
    	local function tankInfo( ... )
    		 tankInfoDialog:create(nil,self.tankId,self.layerNum+1, nil)
    	end
    	local tankIcon = LuaCCSprite:createWithSpriteFrameName("Excavator.png",tankInfo)
    	tankIcon:setTouchPriority(-(self.layerNum-1)*20-5)
    	tankIcon:setAnchorPoint(ccp(0,0.5))
    	tankIcon:setPosition(20,exChangeBg:getContentSize().height/2-40)
    	exChangeBg:addChild(tankIcon)

    	local addWidth,subPosX = 0,0
    	if G_getCurChoseLanguage() =="ru" then
    		addWidth,subPosX = 120,80
    	end

    	local exChangeLb = GetTTFLabelWrap(getlocal("activity_jidongbudui_exchangeScale",{needPartsNum/self.tankNum,1}),25,CCSizeMake(exChangeBg:getContentSize().width/2-50+addWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    	exChangeLb:setAnchorPoint(ccp(0,0))
    	exChangeLb:setPosition(exChangeBg:getContentSize().width/2-subPosX,exChangeBg:getContentSize().height-120)
    	exChangeBg:addChild(exChangeLb)

        local secPosSize = exChangeBg:getContentSize().height-130
        if G_getCurChoseLanguage() =="ru" or G_getCurChoseLanguage() =="pt" then
            secPosSize =exChangeBg:getContentSize().height-120
        end
    	self.hasExchangeTankNumLb = GetTTFLabelWrap(getlocal("activity_jidongbudui_hadExchangeTankNum",{self.exChangeTankNum,mySelfLimit}),25,CCSizeMake(exChangeBg:getContentSize().width/2+addWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    	self.hasExchangeTankNumLb:setAnchorPoint(ccp(0,1))
    	self.hasExchangeTankNumLb:setPosition(exChangeBg:getContentSize().width/2-subPosX,secPosSize)
    	exChangeBg:addChild(self.hasExchangeTankNumLb)


    	local showStr=""
    	if self.serverLeftNum >showMax then
    		showStr = getlocal("activity_jidongbudui_leftTankMore")
    	else
    		showStr = getlocal("activity_jidongbudui_leftTankNum",{self.serverLeftNum})
    	end


    	self.leftNum = GetTTFLabelWrap(showStr,25,CCSizeMake(exChangeBg:getContentSize().width/2-50+addWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    	self.leftNum:setAnchorPoint(ccp(0,1))
    	self.leftNum:setPosition(exChangeBg:getContentSize().width/2-subPosX,exChangeBg:getContentSize().height-170)
    	exChangeBg:addChild(self.leftNum)

    	local posY = exChangeBg:getContentSize().height-220-self.leftNum:getContentSize().height

    	local numSp = CCSprite:createWithSpriteFrameName("ProduceTankSlideBg.png")
    	numSp:setScaleX(0.5)
    	numSp:setScaleY(2)
		numSp:setAnchorPoint(ccp(0.5,0.5))
		numSp:setPosition(ccp(exChangeBg:getContentSize().width/2+90,posY))
		numSp:setContentSize(CCSizeMake(100,50))
		exChangeBg:addChild(numSp,1)

		self.chooseNum = 10 

    	local m_numLb=GetTTFLabel(" ",30)
		m_numLb:setPosition(exChangeBg:getContentSize().width/2+140,posY);
		exChangeBg:addChild(m_numLb,5);
		m_numLb:setString(tostring(self.chooseNum))

		local function tthandler()
    
   		 end

   		local canExChangeTank = mySelfLimit-self.exChangeTankNum

		local function callBackXHandler(fn,eB,str,type)
         
	         if type==1 then  --检测文本内容变化
	         	if str == nil then
	         		eB:setText(tostring(self.chooseNum))
	         	else
		      		local num = tonumber(str)
                    print(num,canExChangeTank)
		      		if num then
		      			if (num>=self.serverLeftNum) then
			      			num = math.floor(self.serverLeftNum/10)*10
			      			eB:setText(tostring(num))
                        elseif (num>=canExChangeTank) or (num>=math.floor(acJidongbuduiVoApi:getTurkeyNum()/(needPartsNum/self.tankNum))) then
                            if canExChangeTank>=math.floor(acJidongbuduiVoApi:getTurkeyNum()/(needPartsNum/self.tankNum)) then
                                num =math.floor(acJidongbuduiVoApi:getTurkeyNum()/(needPartsNum/self.tankNum)/10)*10
                            else
                                num = math.floor(canExChangeTank/10)*10
                            end
			      			eB:setText(tostring(num))
			      		else
			      			eB:setText(str)
			      		end
		         		if num<10 then
		         			self.chooseNum = 10 
		         		else
		         			self.chooseNum = num
		         		end
			         	m_numLb:setString(tostring(self.chooseNum))
		      		end
		      		
	  			end
	         		
	         elseif type==2 then --检测文本输入结束
	            eB:setVisible(false)
	         end
	    end
	    
	    local xBox=LuaCCScale9Sprite:createWithSpriteFrameName("worldInputBg.png",CCRect(10,10,5,5),tthandler)
	    local editXBox
	    --if G_isIOS()==true then
	    --   editXBox=CCEditBox:createForLua(CCSize(90,50),xBox,nil,nil,callBackXHandler)
	   -- else
	        editXBox=CCEditBox:createForLua(CCSize(150,60),xBox,nil,nil,callBackXHandler)
	    
	    editXBox:setPosition(ccp(exChangeBg:getContentSize().width/2+140,posY))
	    if G_isIOS()==true then
	        editXBox:setInputMode(CCEditBox.kEditBoxInputModePhoneNumber)
	    else
	        editXBox:setInputMode(CCEditBox.kEditBoxInputModeAny)
	    end
	    editXBox:setVisible(false)
	    exChangeBg:addChild(editXBox,6)

	    local function tthandler2()
	        PlayEffect(audioCfg.mouseClick)
	        editXBox:setVisible(true)
	    end
	    local xBoxBg=LuaCCScale9Sprite:createWithSpriteFrameName("worldInputBg.png",CCRect(10,10,5,5),tthandler2)
	    xBoxBg:setPosition(ccp(exChangeBg:getContentSize().width/2+140,posY))
	    xBoxBg:setContentSize(CCSize(150,60))
	    xBoxBg:setTouchPriority(-(self.layerNum-1)*20-5)
	    xBoxBg:setOpacity(0)
	    exChangeBg:addChild(xBoxBg,6)


		  -- local function sliderTouch(handler,object)
		  --     local count = math.floor(object:getValue())
		  --     m_numLb:setString(count)
		  --     if count>0 then
		  --      lbTime:setString(GetTimeStr(timeConsume*count))
		  --      for k,v in pairs(countTb) do
		  --        v:setString(FormatNumber(tb[k].num2*count))
		  --      end
		           
		  --     end

		  -- end
		  -- local spBg =CCSprite:createWithSpriteFrameName("ProduceTankSlideBg.png");
		  -- local spPr =CCSprite:createWithSpriteFrameName("ProduceTankSlideBar.png");
		  -- local spPr1 =CCSprite:createWithSpriteFrameName("ProduceTankIconSlide.png");
		  -- local slider = LuaCCControlSlider:create(spBg,spPr,spPr1,sliderTouch);
		  -- slider:setTouchPriority(-42);
		  -- slider:setIsSallow(true);
		  
		  -- slider:setMinimumValue(0.0);
		  
		  -- slider:setMaximumValue(100.0);
		  
		  -- slider:setValue(0);
		  -- slider:setPosition(ccp(355,posY))
		  -- slider:setTag(99)
		  -- exChangeBg:addChild(slider,2)
		  -- m_numLb:setString(math.floor(slider:getValue()))
		  
		  local function touchAdd()
		  	if (self.chooseNum +1*10 <=self.serverLeftNum) and  ((self.chooseNum +1*10)*(needPartsNum/self.tankNum)<=acJidongbuduiVoApi:getTurkeyNum()) and ((self.chooseNum +1*10)<=canExChangeTank) then
		  		self.chooseNum = self.chooseNum+1*10
		      	m_numLb:setString(tostring(self.chooseNum))
		  	end
		  end
		  
		  local function touchMinus()
		      if self.chooseNum-10>0 then
		          self.chooseNum = self.chooseNum-1*10
		      		m_numLb:setString(tostring(self.chooseNum))
		      end
		  
		  end
		  
		  local addSp=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconMore.png",touchAdd)
		  addSp:setPosition(ccp(exChangeBg:getContentSize().width-50,posY))
		  exChangeBg:addChild(addSp,1)
		  addSp:setTouchPriority(-(self.layerNum-1)*20-5)
		  
		  local minusSp=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconLess.png",touchMinus)
		  minusSp:setPosition(ccp(exChangeBg:getContentSize().width/2+40,posY))
		  exChangeBg:addChild(minusSp,1)
		  minusSp:setTouchPriority(-(self.layerNum-1)*20-5)



    	local function btnCallback( ... )
    		if G_checkClickEnable()==false then
		        do
		            return
		        end
		    else
		        base.setWaitTime=G_getCurDeviceMillTime()
		    end 
		    PlayEffect(audioCfg.mouseClick)
		    local function exchangeCallback(fn,data)
		    	local ret,sData=base:checkServerData(data)
		   		if ret == true then
		   			print(self.chooseNum)
		   			tankVoApi:addTank(self.tankId,self.chooseNum)
		   			acJidongbuduiVoApi:updateExChangeTankNum(self.chooseNum)
		   			acJidongbuduiVoApi:updateSelfTurkey(-(self.chooseNum*(needPartsNum/self.tankNum)))
		   			acJidongbuduiVoApi:setServerLeftTankNum(sData.data.jidongbudui.validCount)
		            acJidongbuduiVoApi:setLastSt()
		            self.getTimes = 0
		            
		            local str = getlocal("daily_lotto_tip_10")
		            str = str .. getlocal(tankCfg[self.tankId].name) .. " x" .. self.chooseNum
		            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,28)

		            --聊天公告
	                --local nameData={key=tankCfg[self.tankid].name,param={}}
	                local paramTab={}
                    paramTab.functionStr="jidongbudui"
                    paramTab.addStr="i_also_want"
	                local message={key="activity_jidongbudui_chatSystemMessage",param={playerVoApi:getPlayerName(),self.chooseNum,getlocal(tankCfg[self.tankId].name)}}
	                chatVoApi:sendSystemMessage(message,paramTab)
                    local params = {key="activity_jidongbudui_chatSystemMessage",param={{playerVoApi:getPlayerName(),1},{self.chooseNum,3},{tankCfg[self.tankId].name,5}}}
                    chatVoApi:sendUpdateMessage(41,params)
	                self:update()
		   		end
		    end
		    if self.chooseNum>0 then
		    	socketHelper:activityJidongbuduiExchangeTank(self.chooseNum/10,exchangeCallback)
		    end
		   
    	end 
    	local exChangeBtn=GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",btnCallback,1,getlocal("code_gift"),25)
    	local exChangeMenu = CCMenu:createWithItem(exChangeBtn)
	  	exChangeMenu:setPosition(ccp(exChangeBg:getContentSize().width/4*3,posY-100))
	  	exChangeMenu:setTouchPriority(-(self.layerNum-1)*20-5)
	  	exChangeBg:addChild(exChangeMenu) 
	  	if ((self.chooseNum)*(needPartsNum/self.tankNum)<=acJidongbuduiVoApi:getTurkeyNum()) and ((self.chooseNum)<=canExChangeTank) then
	  		exChangeBtn:setEnabled(true)
	  	else
	  		exChangeBtn:setEnabled(false)
	  	end

	else

		local function nilFun()
		end
	    local capInSet = CCRect(20, 20, 10, 10);
		local exChangeBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",capInSet,nilFun)
		exChangeBg:setAnchorPoint(ccp(0,0))
		exChangeBg:setPosition(ccp(0,0))
		exChangeBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,self.bgLayer:getContentSize().height-560))
		cell:addChild(exChangeBg)

		local DescStr = ""

		if self.serverLeftNum<=0 then
			DescStr=getlocal("activity_jidongbudui_soldout")
		elseif self.exChangeTankNum>=mySelfLimit then
			DescStr=getlocal("activity_jidongbudui_maxTank")
		end

		local turkeyIcon = CCSprite:createWithSpriteFrameName("Turkey.png")
		--turkeyIcon:setScale(0.5)
		turkeyIcon:setAnchorPoint(ccp(0,0))
		turkeyIcon:setPosition(exChangeBg:getContentSize().width/2+10,exChangeBg:getContentSize().height-turkeyIcon:getContentSize().height)
		exChangeBg:addChild(turkeyIcon)

		self.turkeyNum = GetTTFLabel("",30)
		self.turkeyNum:setAnchorPoint(ccp(0,0))
		self.turkeyNum:setPosition(exChangeBg:getContentSize().width/2+30+turkeyIcon:getContentSize().width,exChangeBg:getContentSize().height-turkeyIcon:getContentSize().height+20)
		exChangeBg:addChild(self.turkeyNum)
    	self:updateturkeyNum()

		local descLb = GetTTFLabelWrap(DescStr,25,CCSizeMake(exChangeBg:getContentSize().width-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		descLb:setAnchorPoint(ccp(0.5,0.5))
		descLb:setPosition(exChangeBg:getContentSize().width/2,exChangeBg:getContentSize().height-100)
		exChangeBg:addChild(descLb)

		for i=1,3 do
			local award = acJidongbuduiVoApi:getExchangeRewardByID(i)
			local icon = G_getItemIcon(award,100,true,self.layerNum)
			icon:setTouchPriority(-(self.layerNum-1)*20-4)
			icon:setAnchorPoint(ccp(0.5,1))
			local posx = 110+180*(i-1)
			local posy = exChangeBg:getContentSize().height-160
			icon:setPosition(posx,posy)
			exChangeBg:addChild(icon)

			local numLb = GetTTFLabel("x"..award.num,25)
			numLb:setAnchorPoint(ccp(1,0))
			numLb:setPosition(icon:getContentSize().width-10,10)
			icon:addChild(numLb)

			local needTurkey =  acJidongbuduiVoApi:getNeedTurkeyByID(i)
			local needTurkeyLb = GetTTFLabelWrap(getlocal("activity_jidongbudui_turkeyNum",{needTurkey}),25,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
			needTurkeyLb:setAnchorPoint(ccp(0.5,1))
			needTurkeyLb:setPosition(posx,posy-120)
			exChangeBg:addChild(needTurkeyLb)


			local function rewardCallback( ... )
				if G_checkClickEnable()==false then
			        do
			            return
			        end
			    else
			        base.setWaitTime=G_getCurDeviceMillTime()
			    end
		   	 	PlayEffect(audioCfg.mouseClick)
		   	 	

		   	 	local function callback(fn,data)
		   	 		local ret,sData=base:checkServerData(data)
		   			if ret == true then
		   				acJidongbuduiVoApi:updateSelfTurkey(-needTurkey)
				   	 	G_addPlayerAward(award.type,award.key,award.id,award.num,false,true)
				   	 	G_showRewardTip({award})
				   	 	self:update()
		   			end
		   	 	end

		   	 	socketHelper:activityJidongbuduiExchangeOthers(i,callback)
			end
			 local rewardBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",rewardCallback,1,getlocal("code_gift"),25)
			 if acJidongbuduiVoApi:getTurkeyNum()< needTurkey then
			 	rewardBtn:setEnabled(false)
			 else
			 	rewardBtn:setEnabled(true)
			 end
			 local rewardMenu = CCMenu:createWithItem(rewardBtn)
			 rewardMenu:setPosition(posx,posy-200)
			 rewardMenu:setTouchPriority(-(self.layerNum-1)*20-4)
			 exChangeBg:addChild(rewardMenu)
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

function acJidongbuduiTab2:tick()

	-- if acJidongbuduiVoApi.lastSt + 300 < base.serverTime and self.getTimes <= 2 then
	--     self:getServerTankData()
	--     self.getTimes = self.getTimes + 1
	--     if self.getTimes > 2 then
	--       self.getTimes = 0
	--       acJidongbuduiVoApi:setLastSt()
	--     end
	--  end
end

-- function acJidongbuduiTab2:getServerTankData()
 
--     local function getList(fn,data)
--       local ret,sData=base:checkServerData(data)
--       if ret==true then
--          PlayEffect(audioCfg.mouseClick)

--          if sData ~= nil and sData.data.jidongbudui.validCount then
--             acJidongbuduiVoApi:setServerLeftTankNum(sData.data.jidongbudui.validCount, true)
--             acJidongbuduiVoApi:setLastSt()
--             self.getTimes = 0
--             self:update()
--          end
--       end
--     end
--     print("***********acCuikulaxiuDialog:refreshData******2****")
--     socketHelper:activityJidongbuduiServerLeftTank(getList)
-- end
function acJidongbuduiTab2:update()
	-- self:updateExchangeSp()
	if self.tv then
		local recordPoint = self.tv:getRecordPoint()
		self.tv:reloadData()
		self.tv:recoverToRecordPoint(recordPoint)
	else
		local function callBack(...)
	     return self:eventHandler(...)
	  end
	  local hd= LuaEventHandler:createHandler(callBack)
	  local height=0;
	  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-60,self.bgLayer:getContentSize().height-560),nil)
	  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	  self.tv:setPosition(ccp(30,30))
	  self.bgLayer:addChild(self.tv)
	  self.tv:setMaxDisToBottomOrTop(0)
	end
end

function acJidongbuduiTab2:dispose()
	
end