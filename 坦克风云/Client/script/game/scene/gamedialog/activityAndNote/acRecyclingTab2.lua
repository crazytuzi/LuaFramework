acRecyclingTab2={}

function acRecyclingTab2:new(layerNum)
	local nc = {}
	setmetatable(nc,self)
	self.__index=self
	self.layerNum=layerNum
	self.bgLayer=nil

	self.picOneBg=nil
	self.picTwoBg=nil
	self.changeIdx=0
	self.stopAction=0
	self.countTb =nil
	self.tb=nil
	self.m_numLb=nil
	self.slider=nil
	self.chooseTankIdx=1
	self.aidChoose=1
	return nc
end

function acRecyclingTab2:init()
	self.bgLayer=CCLayer:create()
	self.isToday=acRecyclingVoApi:isToday()
	self:initUpLayer()
	self.aid,self.tankid,self.aidChoose=acRecyclingVoApi:getTankID(self.chooseTankIdx)
	self:initDownLayer()
	self:initLast()
	return self.bgLayer	
end
function acRecyclingTab2:updateTv()
  if self and self.tv2 then
    self.tv2:reloadData()

    if self.slider and self.menuItem1 then
      local count = math.floor(self.slider:getValue())
      self.m_numLb:setString(count)
      local tb =self.tb
      if count>0 and self.countTb and tb then
       for k,v in pairs(self.countTb) do
         v:setString(FormatNumber(tb[k].num2*count))
       end
      end

    	  local reR1,reR2,reR3,reR4,reUpgradedMoney = acRecyclingVoApi:getUpgradedTankResources(self.chooseTankIdx)
		  	local reGold
			if acRecyclingVoApi:getVersion() ==2 then
				reGold = acRecyclingVoApi:getRefitNeedGoldNum(self.chooseTankIdx)
			end
		  local UpgradePropConsume = acRecyclingVoApi:getUpgradePropConsume(self.chooseTankIdx)
		  local haveTankNum = self.haveTankNum
		  if UpgradePropConsume~=nil and  (UpgradePropConsume[1]~=nil and UpgradePropConsume[1][1]~=nil) and (UpgradePropConsume[2]~=nil and UpgradePropConsume[2][1]~=nil) then
		      local pid1 = UpgradePropConsume[1][1]
		      local pid2 = UpgradePropConsume[2][1]
		      local numP1 = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid1)))
		      local numP2 = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid2))) 
		      if playerVoApi:getR1()>=tonumber(reR1) and playerVoApi:getR2()>=tonumber(reR2) and playerVoApi:getR3()>=tonumber(reR3) and playerVoApi:getR4()>=tonumber(reR4) and haveTankNum>=1 and numP1>=1 and numP2>=1 then

		        local tnum1=playerVoApi:getR1()/tonumber(reR1)
		        local num1 = math.floor(tnum1)
		        
		        local tnum2=playerVoApi:getR2()/tonumber(reR2)
		        local num2 = math.floor(tnum2)
		        
		        local tnum3=playerVoApi:getR3()/tonumber(reR3)
		        local num3 = math.floor(tnum3)
		        
		        local tnum4=playerVoApi:getR4()/tonumber(reR4)
		        local num4 = math.floor(tnum4)
		        
		        local num5 = haveTankNum
		        if self.numTab then
		        	self.numTab =nil
		        end
		        self.numTab = {num1,num2,num3,num4,num5}
		        --self.numTab=numTab
		        if UpgradePropConsume~=nil then
		           table.insert(self.numTab,numP1)
		           table.insert(self.numTab,numP2)
		        end
		        local num6
		        if acRecyclingVoApi:getVersion() ==2 and self.chooseTankIdx ==2 then
		        	num6 = math.floor(playerVoApi:getGems()/tonumber(reGold))
		        	table.insert(self.numTab,num6)
		        end
		        table.sort(self.numTab,function(a,b) return a<b end)
		        if self.numTab[1]>100 then

		           self.slider:setMaximumValue(100);
		           
		        else

		           self.slider:setMaximumValue(self.numTab[1]);
		           
		        end
		        
		        if self.numTab[1]==1 then
		            self.slider:setMinimumValue(1.0);
		            self.slider:setMaximumValue(1.0);
		        else
		            self.slider:setMinimumValue(1.0);
		        end
		        if acRecyclingVoApi:getVersion() ==2 and self.chooseTankIdx ==2 and playerVoApi:getGems() <reGold then
			        self.slider:setMaximumValue(0);
			        self.menuItem1:setEnabled(false)
			        self.menu1:setTag(199)
		        else
			        self.slider:setValue(self.numTab[1]);
			        self.menuItem1:setEnabled(true)
			    end
		    else
		        self.slider:setMaximumValue(0);
		        self.menuItem1:setEnabled(false)
		        self.menu1:setTag(199)
		    
		    end

		  else
		      if playerVoApi:getR1()>=tonumber(reR1) and playerVoApi:getR2()>=tonumber(reR2) and playerVoApi:getR3()>=tonumber(reR3) and playerVoApi:getR4()>=tonumber(reR4) then
		        --and(haveTankNum and haveTankNum>=1)  
		        
		        local tnum1=playerVoApi:getR1()/tonumber(reR1)
		        local num1 = math.floor(tnum1)
		        
		        local tnum2=playerVoApi:getR2()/tonumber(reR2)
		        local num2 = math.floor(tnum2)
		        
		        local tnum3=playerVoApi:getR3()/tonumber(reR3)
		        local num3 = math.floor(tnum3)
		        
		        local tnum4=playerVoApi:getR4()/tonumber(reR4)
		        local num4 = math.floor(tnum4)
		        
		        local num5 = haveTankNum
		        if self.numTab then
		        	self.numTab =nil
		        end
		        self.numTab = {num1,num2,num3,num4,num5}

		        local num6
		        if acRecyclingVoApi:getVersion() ==2 and self.chooseTankIdx ==2 then
		        	num6 = math.floor(playerVoApi:getGems()/tonumber(reGold))
		        	table.insert(self.numTab,num6)
		        end
		        table.sort(self.numTab,function(a,b) return a<b end)
		        if self.numTab[1]>100 then

		           self.slider:setMaximumValue(100);
		           
		        else

		           self.slider:setMaximumValue(self.numTab[1]);
		           
		        end
		        
		        if self.numTab[1]==1 then
		            self.slider:setMinimumValue(1.0);
		            self.slider:setMaximumValue(1.0);
		        else
		            self.slider:setMinimumValue(1.0);
		        end
		        
		        if acRecyclingVoApi:getVersion() ==2 and self.chooseTankIdx ==2 and playerVoApi:getGems() <reGold then
			        self.slider:setMaximumValue(0);
			        self.menuItem1:setEnabled(false)
			        self.menu1:setTag(199)
		        else
			        self.slider:setValue(self.numTab[1]);
			        self.menuItem1:setEnabled(true)
			    end
		      else
		        self.slider:setMaximumValue(0);
		        self.menuItem1:setEnabled(false)
		        self.menu1:setTag(199)
		    
		      end
		   end

  	end
  	
  end
end
function acRecyclingTab2:initUpLayer( )
	
  local function bgClick()
  end
  local w = G_VisibleSizeWidth - 50 -- 背景框的宽度
  self.picOneBg= LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),bgClick)
  self.picOneBg:setContentSize(CCSizeMake(w*0.5, G_VisibleSizeHeight*0.4))
  self.picOneBg:setAnchorPoint(ccp(0.5,0.5))
  self.picOneBg:setPosition(ccp(G_VisibleSizeWidth*0.35, G_VisibleSizeHeight*0.6-20))
  self.bgLayer:addChild(self.picOneBg,3)
  self:showOnePic()

	local function picOneBgClick() --self.picOneBg遮罩层
	end
	self.picOneBgBl= LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(20, 20, 10, 10),picOneBgClick)
	self.picOneBgBl:setContentSize(CCSizeMake(w*0.5-10, G_VisibleSizeHeight*0.4-10))
	self.picOneBgBl:setAnchorPoint(ccp(0.5,0.5))
	self.picOneBgBl:setPosition(ccp(self.picOneBg:getContentSize().width*0.5,self.picOneBg:getContentSize().height*0.5))
	self.picOneBg:addChild(self.picOneBgBl,99)
	self.picOneBgBl:setVisible(false)

  local function bgClick2()
  end
  self.picTwoBg= LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),bgClick2)
  self.picTwoBg:setContentSize(CCSizeMake(w*0.5, G_VisibleSizeHeight*0.4))
  self.picTwoBg:setAnchorPoint(ccp(0.5,0.5))
  self.picTwoBg:setPosition(ccp(G_VisibleSizeWidth*0.7, G_VisibleSizeHeight*0.6-20))
  self.picTwoBg:setScale(0.8)
  self.bgLayer:addChild(self.picTwoBg,1)
  self:showTwoPic()

	local function picTwoBgClick() --self.picOneBg遮罩层
	end
	self.picTwoBgBl= LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(20, 20, 10, 10),picTwoBgClick)
	self.picTwoBgBl:setContentSize(CCSizeMake(w*0.5-10, G_VisibleSizeHeight*0.4-10))
	self.picTwoBgBl:setAnchorPoint(ccp(0.5,0.5))
	self.picTwoBgBl:setPosition(ccp(self.picTwoBg:getContentSize().width*0.5,self.picTwoBg:getContentSize().height*0.5))
	self.picTwoBg:addChild(self.picTwoBgBl,99)
	self.picTwoBgBl:setVisible(true)

  local function bgClick3() --遮罩点击层
  	print("啊啊啊啊啊")
  	if self.chooseTankIdx ==1 then
  		self.picOneBgBl:setVisible(true)
  		self.picTwoBgBl:setVisible(false)
  	elseif self.chooseTankIdx ==2 then
   		self.picOneBgBl:setVisible(false)
  		self.picTwoBgBl:setVisible(true)
  	end 		
  	self:changeTwoPic()
  end
	self.touchPic= LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(20, 20, 10, 10),bgClick3)
	self.touchPic:setContentSize(CCSizeMake(w*0.5-62, G_VisibleSizeHeight*0.4-16))
	self.touchPic:setAnchorPoint(ccp(0.5,0.5))
	self.touchPic:setPosition(ccp(G_VisibleSizeWidth*0.7+18, G_VisibleSizeHeight*0.6-20))
	self.touchPic:setScale(0.8)
	self.touchPic:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(self.touchPic,2)
	self.touchPic:setVisible(false)

	self.smallArrowUp = CCSprite:createWithSpriteFrameName("smallPoint.png");--上箭头
	self.smallArrowUp:setPosition(ccp(self.touchPic:getPositionX()-self.touchPic:getContentSize().width*0.2,self.touchPic:getPositionY()+self.touchPic:getContentSize().height*0.5-10));
	self.smallArrowUp:setAnchorPoint(ccp(0.5,0.5));
	self.bgLayer:addChild(self.smallArrowUp,1); 

	self.smallArrowDown = CCSprite:createWithSpriteFrameName("smallPoint.png");--下箭头
	self.smallArrowDown:setPosition(ccp(self.touchPic:getPositionX()-self.touchPic:getContentSize().width*0.2,self.touchPic:getPositionY()-self.touchPic:getContentSize().height*0.5+10));
	self.smallArrowDown:setAnchorPoint(ccp(0.5,0.5));
	self.bgLayer:addChild(self.smallArrowDown,1); 
	self.smallArrowDown:setRotation(180)
end

function acRecyclingTab2:showOnePic( )
	local aid,tankID = acRecyclingVoApi:getTankID(1)

	  local function touch(tag,object)
	    PlayEffect(audioCfg.mouseClick)
		tankInfoDialog:create(nil,tankID,self.layerNum+1, nil)
	  end

	  local menuItemDesc=GetButtonItem("hero_infoBtn.png","hero_infoBtn.png","hero_infoBtn.png",touch,nil,nil,0)
	  menuItemDesc:setAnchorPoint(ccp(1,1))
	  menuItemDesc:setScale(0.8)
	  local menuDesc=CCMenu:createWithItem(menuItemDesc)
	  menuDesc:setTouchPriority(-(self.layerNum-1)*20-4)
	  menuDesc:setPosition(ccp(self.picOneBg:getContentSize().width-10,self.picOneBg:getContentSize().height-20))
	  self.picOneBg:addChild(menuDesc) --按钮

	local function showTankInfo( )
	end
	local tankPicName = "t"..tankID.."_1.png"
	local tankIcon = LuaCCSprite:createWithSpriteFrameName(tankPicName,showTankInfo)
	--tankIcon:setTouchPriority(-(self.layerNum-1)*20-5)
	tankIcon:setAnchorPoint(ccp(0.5,0.5))
	tankIcon:setPosition(self.picOneBg:getContentSize().width*0.5-10,self.picOneBg:getContentSize().height*0.75)
	self.picOneBg:addChild(tankIcon)

   local tankBarrel="t"..tankID.."_1_1.png"  --炮管 第6层
   local tankBarrelSP=CCSprite:createWithSpriteFrameName(tankBarrel)
   tankBarrelSP:setPosition(ccp(tankIcon:getContentSize().width*0.5,tankIcon:getContentSize().height*0.5))
   tankBarrelSP:setAnchorPoint(ccp(0.5,0.5))
   tankIcon:addChild(tankBarrelSP)


	local firTankDec = getlocal("activity_recycling_a"..tankID.."_dl")
	local desTv, desLabel = G_LabelTableView(CCSizeMake(270, 110),firTankDec,22,kCCTextAlignmentLeft)
	self.picOneBg:addChild(desTv)
	desTv:setPosition(ccp(10,self.picOneBg:getContentSize().height*0.3))
	desTv:setAnchorPoint(ccp(0.5,1))
	desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	desTv:setMaxDisToBottomOrTop(100)

	--播放动画按钮 first
	local function touchAction(tag,object )
		self:showBattle(1)
	end 
	local actionTouchFir = GetButtonItem("cameraBtn.png","cameraBtn_down.png","cameraBtn.png",touchAction,nil,nil,0)
	actionTouchFir:setAnchorPoint(ccp(0.5,0))
	local actionTouchFirMenu = CCMenu:createWithItem(actionTouchFir)
	actionTouchFirMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	actionTouchFirMenu:setPosition(ccp(self.picOneBg:getContentSize().width*0.5,10))
	self.picOneBg:addChild(actionTouchFirMenu)
end

function acRecyclingTab2:showTwoPic( )
	  local aid,tankID = acRecyclingVoApi:getTankID(2)

	  local function touch(tag,object)
	  		PlayEffect(audioCfg.mouseClick) 
		  	tankInfoDialog:create(nil,tankID,self.layerNum+1, nil)	    
	  end
	  local menuItemDesc=GetButtonItem("hero_infoBtn.png","hero_infoBtn.png","hero_infoBtn.png",touch,nil,nil,0)
	  menuItemDesc:setAnchorPoint(ccp(1,1))
	  menuItemDesc:setScale(0.8)
	  local menuDesc=CCMenu:createWithItem(menuItemDesc)
	  menuDesc:setTouchPriority(-(self.layerNum-1)*20-4)
	  menuDesc:setPosition(ccp(self.picTwoBg:getContentSize().width-10,self.picTwoBg:getContentSize().height-20))
	  self.picTwoBg:addChild(menuDesc)  --按钮

	local function showTankInfo( )
	end
	local tankPicName = "t"..tankID.."_1.png"
	local tankIcon = LuaCCSprite:createWithSpriteFrameName(tankPicName,showTankInfo)
	tankIcon:setAnchorPoint(ccp(0.5,0.5))
	tankIcon:setPosition(self.picTwoBg:getContentSize().width*0.5-10,self.picTwoBg:getContentSize().height*0.7)
	self.picTwoBg:addChild(tankIcon)

   local tankBarrel="t"..tankID.."_1_1.png"  --炮管 第6层
   local tankBarrelSP=CCSprite:createWithSpriteFrameName(tankBarrel)
   tankBarrelSP:setPosition(ccp(tankIcon:getContentSize().width*0.5,tankIcon:getContentSize().height*0.5))
   tankBarrelSP:setAnchorPoint(ccp(0.5,0.5))
   tankIcon:addChild(tankBarrelSP)

	local secTankDec = getlocal("activity_recycling_a"..tankID.."_dl")
	local desTv, desLabel = G_LabelTableView(CCSizeMake(270, 110),secTankDec,22,kCCTextAlignmentLeft)
	self.picTwoBg:addChild(desTv)
	desTv:setPosition(ccp(10,self.picTwoBg:getContentSize().height*0.3))
	desTv:setAnchorPoint(ccp(0.5,1))
	desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	desTv:setMaxDisToBottomOrTop(100)

	--播放动画按钮 second
	local function touchAction(tag,object )
		self:showBattle(2)
	end 
	local actionTouchSec = GetButtonItem("cameraBtn.png","cameraBtn_down.png","cameraBtn.png",touchAction,nil,nil,0)
	actionTouchSec:setAnchorPoint(ccp(0.5,0))
	local actionTouchSecMenu = CCMenu:createWithItem(actionTouchSec)
	actionTouchSecMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	actionTouchSecMenu:setPosition(ccp(self.picTwoBg:getContentSize().width*0.5,10))
	self.picTwoBg:addChild(actionTouchSecMenu)
end

function acRecyclingTab2:showBattle(idx)
	local battleStr=acRecyclingVoApi:returnTankData(idx)
	local report=G_Json.decode(battleStr)
	local isAttacker=true
	local data={data={report=report},isAttacker=isAttacker,isReport=true}
	battleScene:initData(data)
end

function acRecyclingTab2:changeTwoPic( )

	if self.stopAction ==0 then
		self.stopAction =1
		local posAx,posAy = self.picOneBg:getPosition()
		local posBx,posBy = self.picTwoBg:getPosition()

		local posX=30
		local scaleFir1 = 1.2
		local scaleFir2 = 1
		local scaleSec1 = 0.6
		local scaleSec2 = 0.8
		local scaleChage
		if self.changeIdx ==1 then
			posX =-30
			scaleChage =scaleFir1
			scaleFir1 =scaleSec1
			scaleSec1 =scaleChage
			scaleChage =scaleFir2
			scaleFir2 =scaleSec2
			scaleSec2 =scaleChage

			self.changeIdx =0
		elseif self.changeIdx ==0 then
			self.changeIdx =1
		end
		local function setP1( )
			if self.changeIdx ==1 then
				self.bgLayer:reorderChild(self.picOneBg,1)
			else
				self.bgLayer:reorderChild(self.picOneBg,2)
			end
		end 
		local function setBlack( )
			self.smallArrowUp:setVisible(false)
			self.smallArrowDown:setVisible(false)
		end 
		local moveBg1a = CCMoveTo:create(0.2,ccp(posAx-posX,posBy))
		local moveBg1 = CCMoveTo:create(0.3,ccp(posBx,posBy))
		local scaleToSmals = CCScaleTo:create(0.2,scaleSec1)
		local scaleToBig = CCScaleTo:create(0.2,scaleSec2)
		local callFunc1 = CCCallFunc:create(setP1)
		local callFuncB = CCCallFunc:create(setBlack)
	    local acArr1=CCArray:create()
	    local acArr3 =CCArray:create()
	    local acArr5 = CCArray:create()
	    acArr3:addObject(callFuncB)
	    acArr3:addObject(moveBg1a)
	    acArr3:addObject(callFunc1)
	    acArr3:addObject(moveBg1)
	    acArr1:addObject(scaleToSmals)
	    acArr1:addObject(scaleToBig)
	    
	    local seq1 = CCSequence:create(acArr1)
	    local seq3 = CCSequence:create(acArr3)
	    acArr5:addObject(seq3)
	    acArr5:addObject(seq1)
	    local spawn1 = CCSpawn:create(acArr5)
	    self.picOneBg:runAction(spawn1)

		local function setP2( )
			if self.changeIdx ==1 then
				self.bgLayer:reorderChild(self.picTwoBg,2)
			else
				self.bgLayer:reorderChild(self.picTwoBg,1)
			end
		end 
		local function stopAc( )
			self.stopAction =0
			self.smallArrowUp:setVisible(true)
			self.smallArrowDown:setVisible(true)
			if self.chooseTankIdx ==1 then
				self.chooseTankIdx =2 
			elseif self.chooseTankIdx ==2 then
				self.chooseTankIdx=1
			end
			self:updateTv()
		end
		local moveBg2a = CCMoveTo:create(0.2,ccp(posBx+posX,posAy))
		local moveBg2 = CCMoveTo:create(0.3,ccp(posAx,posAy))
		local scaleToBigb = CCScaleTo:create(0.2,scaleFir1)
		local scaleToSmal = CCScaleTo:create(0.2,scaleFir2)
		local callFunc2 = CCCallFunc:create(setP2)
		local callFuncStop = CCCallFunc:create(stopAc)
	    local acArr2=CCArray:create()
	    local acArr4 = CCArray:create()
	    local acArr6 = CCArray:create()
	    acArr4:addObject(moveBg2a)
	    acArr4:addObject(callFunc2)
	    acArr4:addObject(moveBg2)
	    acArr2:addObject(scaleToBigb)
	    acArr2:addObject(scaleToSmal)
	    acArr4:addObject(callFuncStop)
	    
	    local seq2=CCSequence:create(acArr2)
	    local seq4=CCSequence:create(acArr4)
	    acArr6:addObject(seq4)
	    acArr6:addObject(seq2)
	    local spawn2=CCSpawn:create(acArr6)
	    self.picTwoBg:runAction(spawn2)
	end
end


function acRecyclingTab2:initDownLayer( )
	
  local rect = CCRect(0, 0, 50, 50);
  local capInSet = CCRect(20, 20, 10, 10);
  local function touchHander()
  end
  local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,touchHander)
  tvBg:setAnchorPoint(ccp(0.5,0))
  tvBg:setContentSize(CCSize(self.bgLayer:getContentSize().width-60,G_VisibleSizeHeight*0.2+35))
  tvBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,G_VisibleSizeHeight*0.14))
  self.bgLayer:addChild(tvBg)

	local function callBack(...)
		return self:eventHandler2(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
 	self.tv2=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-60,G_VisibleSizeHeight*0.2+28),nil)
  	self.tv2:setPosition(ccp(0,5))

	self.tv2:setMaxDisToBottomOrTop(120)
  	self.tv2:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
	tvBg:addChild(self.tv2,1)
end

function acRecyclingTab2:eventHandler2(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return 1 --SizeOfTable(self.tankResultTypeTab)
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
	    tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-60,G_VisibleSizeHeight*0.6-50)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		self:exbgCellForId(cell,G_VisibleSizeHeight*0.6-50)
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end

function acRecyclingTab2:exbgCellForId(container,cellHeight)
    local capInSet = CCRect(20, 20, 10, 10);
    local function touchHander()
    end
    local exBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,touchHander)
    exBg:setAnchorPoint(ccp(0,1))
    local exBgHeight
    if G_isIphone5()==true then
      exBgHeight=G_VisibleSize.height-365
      exBg:setContentSize(CCSize(self.bgLayer:getContentSize().width-60,exBgHeight))
      exBg:setPosition(ccp(0,cellHeight-4))
    else
      exBgHeight=G_VisibleSize.height-165
      exBg:setContentSize(CCSize(self.bgLayer:getContentSize().width-60,exBgHeight))
      exBg:setPosition(ccp(0,cellHeight-4))
    end
    exBg:setVisible(false)
    container:addChild(exBg)

	local addH=11;
	local reR1,reR2,reR3,reR4,reUpgradedMoney = acRecyclingVoApi:getUpgradedTankResources(self.chooseTankIdx)
	local typeLb=GetTTFLabel(getlocal("resourceType"),20)
	typeLb:setAnchorPoint(ccp(0.5,0.5))
	typeLb:setPosition(ccp(150,exBg:getPositionY()-40+addH))
	container:addChild(typeLb)

	local resourceLb=GetTTFLabel(getlocal("resourceRequire"),20)
	resourceLb:setAnchorPoint(ccp(0.5,0.5))
	resourceLb:setPosition(ccp(300,exBg:getPositionY()-40+addH))
	container:addChild(resourceLb)

	local haveLb=GetTTFLabel(getlocal("resourceOwned"),20)
	haveLb:setAnchorPoint(ccp(0.5,0.5))
	haveLb:setPosition(ccp(450,exBg:getPositionY()-40+addH))
	container:addChild(haveLb)
  
  local tb={
  {titleStr="metal",spName="resourse_normal_metal.png",needStr=FormatNumber(reR1),haveStr=FormatNumber(playerVoApi:getR1()),num1=playerVoApi:getR1(),num2=tonumber(reR1)},
  {titleStr="oil",spName="resourse_normal_oil.png",needStr=FormatNumber(reR2),haveStr=FormatNumber(playerVoApi:getR2()),num1=playerVoApi:getR2(),num2=tonumber(reR2)},
  {titleStr="silicon",spName="resourse_normal_silicon.png",needStr=FormatNumber(reR3),haveStr=FormatNumber(playerVoApi:getR3()),num1=playerVoApi:getR3(),num2=tonumber(reR3)},
  {titleStr="uranium",spName="resourse_normal_uranium.png",needStr=FormatNumber(reR4),haveStr=FormatNumber(playerVoApi:getR4()),num1=playerVoApi:getR4(),num2=tonumber(reR4)},

    
  }
  local UpgradePropConsume = acRecyclingVoApi:getUpgradePropConsume(self.chooseTankIdx)
  if UpgradePropConsume~=nil and  (UpgradePropConsume[1]~=nil and UpgradePropConsume[1][1]~=nil) and (UpgradePropConsume[2]~=nil and UpgradePropConsume[2][1]~=nil) then
     local pid1 = UpgradePropConsume[1][1]
     local pid2 = UpgradePropConsume[2][1]
     local nameStr1=propCfg[pid1].name
     local numStr1=UpgradePropConsume[1][2]
     local nameStr2=propCfg[pid2].name
     local numStr2=UpgradePropConsume[2][2]


     local tb1={titleStr=nameStr1,spName=propCfg[pid1].icon,needStr=FormatNumber(numStr1),haveStr=bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid1))),num1=bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid1))),num2=tonumber(numStr1)}
     local tb2={titleStr=nameStr2,spName=propCfg[pid2].icon,needStr=FormatNumber(numStr2),haveStr=bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid2))),num1=bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid2))),num2=tonumber(numStr2)}
     table.insert(tb,tb1)
     table.insert(tb,tb2)

  end

  local needTankID,needTankNum = acRecyclingVoApi:getRefitNeedTankIDAndNum(self.chooseTankIdx)
  local haveTankNum
  if needTankID and needTankID>0 then
    haveTankNum=tankVoApi:getTankCountByItemId(needTankID)
    local tb3={titleStr=tankCfg[needTankID].name,spName=tankCfg[needTankID].icon,needStr=1,haveStr=FormatNumber(haveTankNum),num1=haveTankNum,num2=needTankNum}
    table.insert(tb,tb3)
  end

  local needGoldNum = nil
  local needGoldIcon = "resourse_normal_gem.png"
  	needGoldNum =acRecyclingVoApi:getRefitNeedGoldNum(self.chooseTankIdx)
  local  tb4={titleStr="gem",spName=needGoldIcon,needStr=needGoldNum,haveStr=playerVoApi:getGems(),num1=playerVoApi:getGems(),num2=tonumber(needGoldNum)}
  if acRecyclingVoApi:getVersion() ==2 and needGoldNum then
  		 table.insert(tb,tb4)
  end

  self.haveTankNum =haveTankNum
  self.needTankNum =needTankNum

  local addy=60
  local countTb = {}

  for k,v in pairs(tb) do
      local r1Lb=GetTTFLabelWrap(getlocal(v.titleStr),20,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
      r1Lb:setAnchorPoint(ccp(0.5,0.5))
      r1Lb:setPosition(ccp(150,exBg:getPositionY()-100+addH-(k-1)*addy))
      container:addChild(r1Lb)

      local r1Sp=CCSprite:createWithSpriteFrameName(v.spName)
      r1Sp:setAnchorPoint(ccp(0.5,0.5))
      r1Sp:setPosition(ccp(40,exBg:getPositionY()-100+addH-(k-1)*60))
      container:addChild(r1Sp)
      if v.titleStr==tankCfg[needTankID].name then
        r1Sp:setScale(0.35)
      else
        r1Sp:setScale(0.5)
      end

      local needR1Lb=GetTTFLabel(v.needStr,20)
      needR1Lb:setAnchorPoint(ccp(0.5,0.5))
      needR1Lb:setPosition(ccp(300,exBg:getPositionY()-100+addH-(k-1)*addy))
      container:addChild(needR1Lb)

      local haveR1Lb=GetTTFLabel(v.haveStr,20)
      haveR1Lb:setAnchorPoint(ccp(0,0.5))
      haveR1Lb:setPosition(ccp(450,exBg:getPositionY()-100+addH-(k-1)*addy))
      container:addChild(haveR1Lb)

      local p1Sp;
      if v.num1>=v.num2 then
         p1Sp=CCSprite:createWithSpriteFrameName("IconCheck.png")
      else
         p1Sp=CCSprite:createWithSpriteFrameName("IconFault.png")
      end
      p1Sp:setAnchorPoint(ccp(0.5,0.5))
      
      p1Sp:setPosition(ccp(400,exBg:getPositionY()-100+addH-(k-1)*addy))

      container:addChild(p1Sp)
      countTb[k]=needR1Lb
  end
  self.tb=tb
  self.countTb =countTb
    -- end
end
function acRecyclingTab2:initLast( )
	local reR1,reR2,reR3,reR4,reUpgradedMoney = acRecyclingVoApi:getUpgradedTankResources(self.chooseTankIdx)
	local reGold
	if acRecyclingVoApi:getVersion() ==2 then
		reGold = acRecyclingVoApi:getRefitNeedGoldNum(self.chooseTankIdx)
	end
    local bgSp = CCSprite:createWithSpriteFrameName("TeamProduceTank_Bg.png");
    bgSp:setAnchorPoint(ccp(0,0.5));
    bgSp:setPosition(30,110);
    self.bgLayer:addChild(bgSp,1);

  self.m_numLb=GetTTFLabel(" ",30)
  self.m_numLb:setPosition(100,110);------------------------------1111
  self.bgLayer:addChild(self.m_numLb,2);

  local tb = self.tb
  local function sliderTouch(handler,object)
      local count = math.floor(object:getValue())
      self.m_numLb:setString(count)
      local tb = self.tb
      if count>0 and self.countTb and tb then
       for k,v in pairs(self.countTb) do
         v:setString(FormatNumber(tb[k].num2*count))
       end
           
      end

  end
  local spBg =CCSprite:createWithSpriteFrameName("ProduceTankSlideBg.png");
  local spPr =CCSprite:createWithSpriteFrameName("ProduceTankSlideBar.png");
  local spPr1 =CCSprite:createWithSpriteFrameName("ProduceTankIconSlide.png");
  self.slider = LuaCCControlSlider:create(spBg,spPr,spPr1,sliderTouch);
  self.slider:setTouchPriority(-(self.layerNum-1)*20-4);
  self.slider:setIsSallow(true);
  
  self.slider:setMinimumValue(0.0);
  
  self.slider:setMaximumValue(100.0);
  
  self.slider:setValue(0);
  self.slider:setPosition(ccp(385,110))-------------------------------
  self.slider:setTag(99)
  self.bgLayer:addChild(self.slider,2)
  self.m_numLb:setString(math.floor(self.slider:getValue()))
  
  
  local function touchAdd()
      self.slider:setValue(self.slider:getValue()+1);
  end
  
  local function touchMinus()
      if self.slider:getValue()-1>0 then
          self.slider:setValue(self.slider:getValue()-1);
      end
  
  end
  
  local addSp=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconMore.png",touchAdd)
  addSp:setPosition(ccp(579,110))-------------------------------
  self.bgLayer:addChild(addSp,1)
  addSp:setTouchPriority(-(self.layerNum-1)*20-4);
  
  local minusSp=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconLess.png",touchMinus)
  minusSp:setPosition(ccp(187,110))-------------------------------
  self.bgLayer:addChild(minusSp,1)
  minusSp:setTouchPriority(-(self.layerNum-1)*20-4);


  local function touch1()
  		self.aid,self.tankid,self.aidChoose=acRecyclingVoApi:getTankID(self.chooseTankIdx)
        local tid=tonumber(self.aid)
        local nums=math.floor(tonumber(self.slider:getValue()))
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end 

        PlayEffect(audioCfg.mouseClick)
        if self and self.tv2 and self.tv2:getScrollEnable()==true and self.tv2:getIsScrolled()==false then
            local function serverUpgrade(fn,data)
              local ret,sData=base:checkServerData(data)
              if ret==true then
              	self.aid,self.tankid,self.aidChoose=acRecyclingVoApi:getTankID(self.chooseTankIdx)
                local tankName=getlocal(tankCfg[self.tankid].name)
                local makeTankTip=getlocal("active_lottery_reward_tank",{tankName," x"..nums})
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),makeTankTip,28)
                --self.tv2:reloadData()
                self:updateTv()

                --聊天公告
                local nameData={key=tankCfg[self.tankid].name,param={}}
                local message={key="activity_recycling_chatSystemMessage",param={playerVoApi:getPlayerName(),nameData}}
                if nums >=10 then
                	chatVoApi:sendSystemMessage(message)
                end
              end
          end
          socketHelper:activityhuiluzaizaoRefitTank(nums,self.aidChoose,serverUpgrade)
        end
        
   
    end
    self.menuItem1 = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",touch1,11,getlocal("compose"),28)
    self.menu1 = CCMenu:createWithItem(self.menuItem1);
    self.menu1:setAnchorPoint(ccp(0,0))
    self.menu1:setPosition(ccp(540,55));-------------------------------1111
    self.menu1:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer:addChild(self.menu1,3);
    self.menu1:setScale(0.8)

    -- for i=1,4 do
    -- 	 local ig = i+4
	   --   local attackIconType = "pro_ship_attacktype_"..ig..".png"
	   --   local attackType = CCSprite:createWithSpriteFrameName(attackIconType) 
	   --   attackType:setAnchorPoint(ccp(0,0))
	   --   attackType:setPosition(ccp(i*60,55))
	   --   self.bgLayer:addChild(attackType,4)
    -- end

  local UpgradePropConsume = acRecyclingVoApi:getUpgradePropConsume(self.chooseTankIdx)
  local haveTankNum = self.haveTankNum
  if UpgradePropConsume~=nil and  (UpgradePropConsume[1]~=nil and UpgradePropConsume[1][1]~=nil) and (UpgradePropConsume[2]~=nil and UpgradePropConsume[2][1]~=nil) then
      local pid1 = UpgradePropConsume[1][1]
      local pid2 = UpgradePropConsume[2][1]
      local numP1 = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid1)))
      local numP2 = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid2))) 
      if playerVoApi:getR1()>=tonumber(reR1) and playerVoApi:getR2()>=tonumber(reR2) and playerVoApi:getR3()>=tonumber(reR3) and playerVoApi:getR4()>=tonumber(reR4) and haveTankNum>=1 and numP1>=1 and numP2>=1 then

        local tnum1=playerVoApi:getR1()/tonumber(reR1)
        local num1 = math.floor(tnum1)
        
        local tnum2=playerVoApi:getR2()/tonumber(reR2)
        local num2 = math.floor(tnum2)
        
        local tnum3=playerVoApi:getR3()/tonumber(reR3)
        local num3 = math.floor(tnum3)
        
        local tnum4=playerVoApi:getR4()/tonumber(reR4)
        local num4 = math.floor(tnum4)
        
        local num5 = haveTankNum
        
        self.numTab = {num1,num2,num3,num4,num5}
        
        if UpgradePropConsume~=nil then
           table.insert(self.numTab,numP1)
           table.insert(self.numTab,numP2)
        end
        local num6
        if acRecyclingVoApi:getVersion() ==2 and self.chooseTankIdx ==2 then
        	num6 = math.floor(playerVoApi:getGems()/tonumber(reGold))
        	table.insert(self.numTab,num6)
        end
        table.sort(self.numTab,function(a,b) return a<b end)
        if self.numTab[1]>100 then

           self.slider:setMaximumValue(100);
           
        else
           self.slider:setMaximumValue(self.numTab[1]);
           
        end
        
        if self.numTab[1]==1 then
            self.slider:setMinimumValue(1.0);
            self.slider:setMaximumValue(1.0);
        else
            self.slider:setMinimumValue(1.0);
        end
        
        if acRecyclingVoApi:getVersion() ==2 and self.chooseTankIdx ==2 and playerVoApi:getGems() <reGold then
	        self.slider:setMaximumValue(0);
	        self.menuItem1:setEnabled(false)
	        self.menu1:setTag(199)
        else
	        self.slider:setValue(self.numTab[1]);
	        self.menuItem1:setEnabled(true)
	    end
    else
        self.slider:setMaximumValue(0);
        self.menuItem1:setEnabled(false)
        self.menu1:setTag(199)
    
    end

  else
      if playerVoApi:getR1()>=tonumber(reR1) and playerVoApi:getR2()>=tonumber(reR2) and playerVoApi:getR3()>=tonumber(reR3) and playerVoApi:getR4()>=tonumber(reR4) then
        --and(haveTankNum and haveTankNum>=1)  
        
        local tnum1=playerVoApi:getR1()/tonumber(reR1)
        local num1 = math.floor(tnum1)
        
        local tnum2=playerVoApi:getR2()/tonumber(reR2)
        local num2 = math.floor(tnum2)
        
        local tnum3=playerVoApi:getR3()/tonumber(reR3)
        local num3 = math.floor(tnum3)
        
        local tnum4=playerVoApi:getR4()/tonumber(reR4)
        local num4 = math.floor(tnum4)
        
        local num5 = haveTankNum
        
        self.numTab = {num1,num2,num3,num4,num5}
        local num6
        if acRecyclingVoApi:getVersion() ==2 and self.chooseTankIdx ==2 then
        	num6 = math.floor(playerVoApi:getGems()/tonumber(reGold))
        	table.insert(self.numTab,num6)
        end
        table.sort(self.numTab,function(a,b) return a<b end)
        if self.numTab[1]>100 then

           self.slider:setMaximumValue(100);
           
        else

           self.slider:setMaximumValue(self.numTab[1]);
           
        end
        
        if self.numTab[1]==1 then
            self.slider:setMinimumValue(1.0);
            self.slider:setMaximumValue(1.0);
        else
            self.slider:setMinimumValue(1.0);
        end
        if acRecyclingVoApi:getVersion() ==2 and self.chooseTankIdx ==2 and playerVoApi:getGems() <reGold then
	        self.slider:setMaximumValue(0);
	        self.menuItem1:setEnabled(false)
	        self.menu1:setTag(199)
        else
	        self.slider:setValue(self.numTab[1]);
	        self.menuItem1:setEnabled(true)
	    end
      else
        self.slider:setMaximumValue(0);
        self.menuItem1:setEnabled(false)
        self.menu1:setTag(199)
    
      end
   end
end


function acRecyclingTab2:dispose( )
	self.bgLayer=nil
	self.picOneBg=nil
	self.picTwoBg=nil
	self.changeIdx=nil
	self.stopAction=nil
	self.countTb =nil
	self.tb=nil
	self.m_numLb=nil
	self.slider=nil
	self.chooseTankIdx=nil
end