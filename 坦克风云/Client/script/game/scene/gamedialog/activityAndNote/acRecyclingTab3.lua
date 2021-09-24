acRecyclingTab3={}

function acRecyclingTab3:new(layerNum)
	local nc = {}
	setmetatable(nc,self)
	self.__index=self
	self.layerNum=layerNum
	self.bgLayer=nil

	self.picOneBg=nil
	self.picTwoBg=nil
	self.touchPicOne=nil
	self.touchipicTwo=nil
	self.touchPicNum=1
	self.arrowPointG=nil
	self.arrowActionTF=true

	self.haveTankNum_1=0
	self.haveTankNum_2=0

	self.aid=nil
	self.tankid=nil
	self.aidChoose=nil
	self.chooseTankIdx =4 --默认为3  3，4两个配置坦克的选择
	self.tb ={} --坦克组装的需求
	self.m_numLb=nil
	self.countTb={}
	self.numTab={}
	self.lastHeight=160
	self.addy =50
	self.needVal =70
	return nc
end

function acRecyclingTab3:init()
	  if G_isIphone5() == true then
	  	self.lastHeight = 220
	  	self.addy =70
	  	self.needVal = 100
	  end
	self.bgLayer=CCLayer:create()
	self.isToday=acRecyclingVoApi:isToday()
	self.aid,self.tankid,self.aidChoose=acRecyclingVoApi:getTankID(self.chooseTankIdx)
	self:initTwoPic()
	self:initPointAc()
	self:initCosumeBar()
	self:initLast()
	return self.bgLayer	
end

function acRecyclingTab3:initPointAc( )

		self.arrowPointG=CCSprite:createWithSpriteFrameName("arrowPointG.png")
		self.arrowPointG:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSize.height-165-self.picOneBg:getContentSize().height*0.5))
		self.arrowPointG:setVisible(true)
		self.arrowPointG:setAnchorPoint(ccp(0.5,0.5))
		self.bgLayer:addChild(self.arrowPointG,3)
		self.arrowPointG:setScale(1.4)
		self.arrowPointG:setRotation(45)
end

function acRecyclingTab3:initpointAction(idx)
	if self.arrowActionTF ==true then
		self.arrowActionTF =false
		if self.arrowPointG then
			-- local arrowPos,arrowPos2,arrowPos3,arrow4,arrow5
			-- if idx ==2 then
			--   arrowPos = CCRotateBy:create(0.3, -210)
			--   arrowPos2 =CCRotateBy:create(0.1,50)
			--   arrowPos3 =CCRotateBy:create(0.1,-40)
			--   arrowpos4 =CCRotateBy:create(0.05,30)
			--   arrowpos5 =CCRotateBy:create(0.01,-10)
			-- elseif idx==1 then
			--   arrowPos = CCRotateBy:create(0.3,210)
			--   arrowPos2 =CCRotateBy:create(0.1,-50)
			--   arrowPos3 =CCRotateBy:create(0.1,40)
			--   arrowpos4 =CCRotateBy:create(0.05,-30)
			--   arrowpos5 =CCRotateBy:create(0.01,10)
			-- end
			--  local function ccCall(  )
			-- 	self.arrowActionTF=true
			-- 	if self.chooseTankIdx ==3 then
			-- 		self.chooseTankIdx =4
			-- 	elseif self.chooseTankIdx ==4 then
			-- 		self.chooseTankIdx =3
			-- 	end
			-- 	self.aid,self.tankid,self.aidChoose=acRecyclingVoApi:getTankID(self.chooseTankIdx)
			-- 	self:resetSlider()
			--  end 
			--  local callFunc = CCCallFunc:create(ccCall)
			--  local acArr1 = CCArray:create()
			--  acArr1:addObject(arrowPos)
			--  acArr1:addObject(arrowPos2)
			--  acArr1:addObject(arrowPos3)
			--  acArr1:addObject(arrowpos4)
			--  acArr1:addObject(arrowpos5)
			--  acArr1:addObject(callFunc)
			--  local seq1=CCSequence:create(acArr1)
			--  self.arrowPointG:runAction(seq1)

		 	if self.chooseTankIdx ==3 then
		 		self.arrowPointG:setRotation(45)
				self.chooseTankIdx =4
			elseif self.chooseTankIdx ==4 then
				self.arrowPointG:setRotation(-135)
				self.chooseTankIdx =3
			end
			self.aid,self.tankid,self.aidChoose=acRecyclingVoApi:getTankID(self.chooseTankIdx)
			self:resetSlider()
			self.arrowActionTF=true
		end
	end
end


function acRecyclingTab3:initTankShow(idx)
	local picBgNode,num
	if idx ==3 and self.picOneBg then
		picBgNode =self.picOneBg
		num=3
	elseif idx ==4 and self.picTwoBg then --------4
		picBgNode =self.picTwoBg
		num=4
	end
	local function showTankInfo( )
		
	end

	local aid,tankID = acRecyclingVoApi:getTankID(idx)
	local tankNameStr = "tank_name_"..tankID
	local tankPicName = "t"..tankID.."_1.png"

	local tankNameLb = GetTTFLabelWrap(getlocal(tankNameStr),22,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	tankNameLb:setAnchorPoint(ccp(0.5,0.5))
	tankNameLb:setPosition(ccp(picBgNode:getContentSize().width*0.5-10,picBgNode:getContentSize().height*0.9))
	picBgNode:addChild(tankNameLb)
	local tankIcon = LuaCCSprite:createWithSpriteFrameName(tankPicName,showTankInfo)
	--tankIcon:setTouchPriority(-(self.layerNum-1)*20-5)
	tankIcon:setAnchorPoint(ccp(0.5,0.5))
	local iconHeight = picBgNode:getContentSize().height*0.65
	if acRecyclingVoApi:getVersion() ==1 and G_getCurChoseLanguage() =="ru" then
		iconHeight =iconHeight -20
	end
	tankIcon:setPosition(picBgNode:getContentSize().width*0.5-10,iconHeight)
	picBgNode:addChild(tankIcon)

   local tankBarrel="t"..tankID.."_1_1.png"  --炮管 第6层
   local tankBarrelSP=CCSprite:createWithSpriteFrameName(tankBarrel)
   tankBarrelSP:setPosition(ccp(tankIcon:getContentSize().width*0.5,tankIcon:getContentSize().height*0.5))
   tankBarrelSP:setAnchorPoint(ccp(0.5,0.5))
   tankIcon:addChild(tankBarrelSP)

	if num ==3 then
		local haveTankNum_1 = tankVoApi:getTankCountByItemId(tankID)
		self.haveTankNum_1 = GetTTFLabel(getlocal("propInfoNum",{haveTankNum_1}),23)
		self.haveTankNum_1:setAnchorPoint(ccp(0.5,0.5))
		self.haveTankNum_1:setPosition(ccp(picBgNode:getContentSize().width*0.5-10,picBgNode:getContentSize().height*0.4))
		picBgNode:addChild(self.haveTankNum_1)
	elseif num ==4 then
		local haveTankNum_2 = tankVoApi:getTankCountByItemId(tankID)
		self.haveTankNum_2 = GetTTFLabel(getlocal("propInfoNum",{haveTankNum_2}),23)
		self.haveTankNum_2:setAnchorPoint(ccp(0.5,0.5))
		self.haveTankNum_2:setPosition(ccp(picBgNode:getContentSize().width*0.5-10,picBgNode:getContentSize().height*0.4))
		picBgNode:addChild(self.haveTankNum_2)
	end		

	local secTankDec = getlocal("activity_recycling_a"..tankID.."_dl")
	local desTv, desLabel = G_LabelTableView(CCSizeMake(220, 110),secTankDec,22,kCCTextAlignmentLeft)
	picBgNode:addChild(desTv)
	desTv:setPosition(ccp(10,15))
	desTv:setAnchorPoint(ccp(0.5,1))
	desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
	desTv:setMaxDisToBottomOrTop(100)

	self:initBlackDialog(num)
end

function acRecyclingTab3:initBlackDialog( idx)
	local picBlack,picBgNode,posX,posY

	  local function bgClick3() --遮罩层
		  if self.touchPicNum ==1 and self.arrowActionTF==true then
		  	self.touchPicOne:setVisible(false)
		  	self.touchipicTwo:setVisible(true)
		  	self.touchPicNum=2
		  	self:initpointAction(self.touchPicNum)
		  end
	  end
	  local function bgClick4() --遮罩层
		  if self.touchPicNum ==2 and self.arrowActionTF==true then
		  	self.touchPicOne:setVisible(true)
		  	self.touchipicTwo:setVisible(false)
		  	self.touchPicNum=1
		  	self:initpointAction(self.touchPicNum)
		  end
	  end
  if idx ==3 and self.picOneBg then
  	picBgNode =self.picOneBg
	  self.touchPicOne= LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(20, 20, 10, 10),bgClick3)
	  self.touchPicOne:setContentSize(CCSizeMake(picBgNode:getContentSize().width-8,picBgNode:getContentSize().height-12))
	  self.touchPicOne:setAnchorPoint(ccp(0,1))
	  self.touchPicOne:setPosition(ccp(29, G_VisibleSize.height-170))
	  --self.touchPic:setScale(0.8)
	  self.touchPicOne:setTouchPriority(-(self.layerNum-1)*20-4)
	  self.bgLayer:addChild(self.touchPicOne,2)
	  self.touchPicOne:setVisible(false)
  elseif idx ==4 and self.picTwoBg then
  	picBgNode =self.picTwoBg
	  self.touchipicTwo= LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(20, 20, 10, 10),bgClick4)
	  self.touchipicTwo:setContentSize(CCSizeMake(picBgNode:getContentSize().width-8,picBgNode:getContentSize().height-12))
	  self.touchipicTwo:setAnchorPoint(ccp(1,1))
	  self.touchipicTwo:setPosition(ccp(610,G_VisibleSize.height-170))
	  --self.touchPic:setScale(0.8)
	  self.touchipicTwo:setTouchPriority(-(self.layerNum-1)*20-4)
	  self.bgLayer:addChild(self.touchipicTwo,2) 
	  self.touchipicTwo:setVisible(false)
  end
  if self.touchPicNum ==1 then
  	if self.touchPicOne then
  		self.touchPicOne:setVisible(true)
  	end
  	if self.touchipicTwo then
  		self.touchipicTwo:setVisible(false)
  	end
  end

end

function acRecyclingTab3:eventHandler1(handler,fn,idx,cel)

	if fn=="numberOfCellsInTableView" then
		return 1 --SizeOfTable(self.tankResultTypeTab)
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
	      tmpSize=CCSizeMake(G_VisibleSizeWidth-50,self.lastHeight+100)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		self:pushCell(cell)
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end
function acRecyclingTab3:pushCell(thisCell)
	self.background1=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function () end)
	--self.background1:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,self.lastHeight))
	self.background1:setAnchorPoint(ccp(0,1))
	--self.background1:setPosition(ccp(G_VisibleSizeWidth*0.5-25,0))
    local exBgHeight
    if G_isIphone5()==true then
      self.background1:setContentSize(CCSize(self.bgLayer:getContentSize().width-60,self.lastHeight+100))
      self.background1:setPosition(ccp(0,self.lastHeight+100-4))
    else
      self.background1:setContentSize(CCSize(self.bgLayer:getContentSize().width-60,self.lastHeight+100))
      self.background1:setPosition(ccp(0,self.lastHeight+100-4))
    end
	--thisCell:addChild(self.background1)
	if self.tb then
		self.tb ={}
	end
	local  tb = {}
	local countTb = {}
 		  local typeLb1=GetTTFLabel(getlocal("resourceType"),20)
		  typeLb1:setAnchorPoint(ccp(0.5,0.5))
		  typeLb1:setPosition(ccp(150,self.background1:getContentSize().height-25))
		  thisCell:addChild(typeLb1)
		  
		  local resourceLb1=GetTTFLabel(getlocal("resourceRequire"),20)
		  resourceLb1:setAnchorPoint(ccp(0.5,0.5))
		  resourceLb1:setPosition(ccp(300,self.background1:getContentSize().height-25))
		  thisCell:addChild(resourceLb1)

		  local haveLb1=GetTTFLabel(getlocal("resourceOwned"),20)
		  haveLb1:setAnchorPoint(ccp(0.5,0.5))
		  haveLb1:setPosition(ccp(450,self.background1:getContentSize().height-25))
		  thisCell:addChild(haveLb1)

		  local UpgradePropConsume = acRecyclingVoApi:getUpgradePropConsume(self.chooseTankIdx)
		  if UpgradePropConsume~=nil and  (UpgradePropConsume[1]~=nil and UpgradePropConsume[1][1]~=nil) then
		     local pid1 = UpgradePropConsume[1][1]
		     local nameStr1=propCfg[pid1].name
		     local numStr1=UpgradePropConsume[1][2]

		     local tb1={titleStr=nameStr1,spName=propCfg[pid1].icon,needStr=FormatNumber(numStr1),haveStr=bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid1))),num1=bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid1))),num2=tonumber(numStr1)}
		     table.insert(tb,tb1)
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
		  local tb4 = {}
		  if acRecyclingVoApi:getVersion() ==2 and self.chooseTankIdx ==4 then
		  	needGoldNum =acRecyclingVoApi:getRefitNeedGoldNum(self.chooseTankIdx)
		  	if needGoldNum then
		  		 tb4={titleStr="gem",spName=needGoldIcon,needStr=needGoldNum,haveStr=playerVoApi:getGems(),num1=playerVoApi:getGems(),num2=needGoldNum}
		  		 table.insert(tb,tb4)
		  	end
		  end

		  self.haveTankNum =haveTankNum
		  self.needTankNum =needTankNum
		    local addH=11
		  if #tb ~=0 then
			  for k,v in pairs(tb) do
			      local r1Lb=GetTTFLabelWrap(getlocal(v.titleStr),20,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			      r1Lb:setAnchorPoint(ccp(0.5,0.5))
			      r1Lb:setPosition(ccp(150,self.background1:getContentSize().height-self.needVal+addH-(k-1)*self.addy))
			      thisCell:addChild(r1Lb)
			      local r1Sp=CCSprite:createWithSpriteFrameName(v.spName)
			      r1Sp:setAnchorPoint(ccp(0.5,0.5))
			      r1Sp:setPosition(ccp(40,self.background1:getContentSize().height-self.needVal+addH-(k-1)*self.addy))
			      thisCell:addChild(r1Sp)
			      if v.titleStr==tankCfg[needTankID].name then
			        r1Sp:setScale(0.35)
			      else
			        r1Sp:setScale(0.5)
			      end

			      local needR1Lb=GetTTFLabel(v.needStr,20)
			      needR1Lb:setAnchorPoint(ccp(0.5,0.5))
			      needR1Lb:setPosition(ccp(300,self.background1:getContentSize().height-self.needVal+addH-(k-1)*self.addy))
			      thisCell:addChild(needR1Lb)

			      local haveR1Lb=GetTTFLabel(v.haveStr,20)
			      haveR1Lb:setAnchorPoint(ccp(0,0.5))
			      haveR1Lb:setPosition(ccp(450,self.background1:getContentSize().height-self.needVal+addH-(k-1)*self.addy))
			      thisCell:addChild(haveR1Lb)

			      local p1Sp;
			      if v.num1>=v.num2 then
			         p1Sp=CCSprite:createWithSpriteFrameName("IconCheck.png")
			      else
			         p1Sp=CCSprite:createWithSpriteFrameName("IconFault.png")
			      end
			      p1Sp:setAnchorPoint(ccp(0.5,0.5))
			      
			      p1Sp:setPosition(ccp(400,self.background1:getContentSize().height-self.needVal+addH-(k-1)*self.addy))

			      thisCell:addChild(p1Sp)
			      countTb[k]= needR1Lb
			  end
			end
			self.tb =tb
			self.countTb=countTb
end
function acRecyclingTab3:initCosumeBar(idx )

  local rect = CCRect(0, 0, 50, 50);
  local capInSet = CCRect(20, 20, 10, 10);
  local function touchHander()
  end
  local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,touchHander)
  tvBg:setAnchorPoint(ccp(0.5,1))
  tvBg:setContentSize(CCSize(G_VisibleSizeWidth-50,self.lastHeight))
  tvBg:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*0.5 - 100))
  self.bgLayer:addChild(tvBg)

	local function callBack(...)
		return self:eventHandler1(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv1=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-50,self.lastHeight-10),nil)
	self.tv1:setPosition(ccp(0,5))
	self.tv1:setMaxDisToBottomOrTop(120)
  	self.tv1:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
	tvBg:addChild(self.tv1,1)

end
function acRecyclingTab3:initLast( )

	local bgSp = CCSprite:createWithSpriteFrameName("TeamProduceTank_Bg.png");
	bgSp:setAnchorPoint(ccp(0,0.5));
	bgSp:setPosition(30,160);
	self.bgLayer:addChild(bgSp,1);

	self.m_numLb=GetTTFLabel(" ",30)
	self.m_numLb:setPosition(100,160);------------------------------1111
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
	  self.slider:setPosition(ccp(385,160))-------------------------------
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
	  addSp:setPosition(ccp(579,160))-------------------------------
	  self.bgLayer:addChild(addSp,1)
	  addSp:setTouchPriority(-(self.layerNum-1)*20-4);
	  
	  local minusSp=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconLess.png",touchMinus)
	  minusSp:setPosition(ccp(187,160))-------------------------------
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
        if self and nums>0 then
            local function serverUpgrade(fn,data)
              local ret,sData=base:checkServerData(data)
              if ret==true then
                local tankName=getlocal(tankCfg[self.tankid].name)
                local makeTankTip=getlocal("active_lottery_reward_tank",{tankName," x"..nums})
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),makeTankTip,28)
                self:resetSlider()
              end
          end
          socketHelper:activityhuiluzaizaoRefitTank(nums,self.aidChoose,serverUpgrade)
        end
    end
    self.menuItem1 = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",touch1,11,getlocal("compose"),28)
    self.menu1 = CCMenu:createWithItem(self.menuItem1);
    self.menu1:setAnchorPoint(ccp(0,0))
    self.menu1:setPosition(ccp(520,80));-------------------------------1111
    self.menu1:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer:addChild(self.menu1,3);
  	local reGold
	if acRecyclingVoApi:getVersion() ==2 then
		reGold = acRecyclingVoApi:getRefitNeedGoldNum(self.chooseTankIdx)
	end

	  local UpgradePropConsume = acRecyclingVoApi:getUpgradePropConsume(self.chooseTankIdx)
	  local haveTankNum = self.haveTankNum
	  if UpgradePropConsume~=nil and  (UpgradePropConsume[1]~=nil and UpgradePropConsume[1][1]~=nil)then
	      local pid1 = UpgradePropConsume[1][1]
	      local numP1 = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid1)))
	      if haveTankNum>=1 and numP1>=1  then
	        local num5 = haveTankNum
	        
	        self.numTab = {num5}
	        
	        if UpgradePropConsume~=nil then
	           table.insert(self.numTab,numP1)
	        end
	        local num6
	        if acRecyclingVoApi:getVersion() ==2 and self.chooseTankIdx ==4 then
	        	print("reGold~~~~~~~~~~",reGold,playerVoApi:getGems())
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
	        
	        if acRecyclingVoApi:getVersion() ==2 and self.chooseTankIdx ==4 and playerVoApi:getGems() <reGold then
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

function acRecyclingTab3:resetSlider( )

	 local aid_3,tankID_3 = acRecyclingVoApi:getTankID(3)
	 local aid_4,tankID_4 = acRecyclingVoApi:getTankID(4)
  	local reGold
	if acRecyclingVoApi:getVersion() ==2 then
		reGold = acRecyclingVoApi:getRefitNeedGoldNum(self.chooseTankIdx)
	end
	 self.haveTankNum_1:setString(getlocal("propInfoNum",{tankVoApi:getTankCountByItemId(tankID_3)}))
	 self.haveTankNum_2:setString(getlocal("propInfoNum",{tankVoApi:getTankCountByItemId(tankID_4)}))
	 if self and self.tv1 then
	 	self.tv1:reloadData()
		 if self.slider and self.menuItem1 then
		      local count = math.floor(self.slider:getValue())
		      self.m_numLb:setString(count)
		      local tb =self.tb
		      G_dayin(tb)
		      if count>0 and self.countTb and tb then
		       for k,v in pairs(self.countTb) do
		         v:setString(FormatNumber(tb[k].num2*count))
		       end
		      end
			  local UpgradePropConsume = acRecyclingVoApi:getUpgradePropConsume(self.chooseTankIdx)
			  local haveTankNum = self.haveTankNum
			  if UpgradePropConsume~=nil and  (UpgradePropConsume[1]~=nil and UpgradePropConsume[1][1]~=nil)then
			      local pid1 = UpgradePropConsume[1][1]
			      local numP1 = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid1)))
			      if haveTankNum>=1 and numP1>=1  then
			        local num5 = haveTankNum

			        if self.numTab then
			        	self.numTab =nil
			        end
			        self.numTab = {num5}
			        
			        if UpgradePropConsume~=nil then
			           table.insert(self.numTab,numP1)
			        end
			        local num6
			        if acRecyclingVoApi:getVersion() ==2 and self.chooseTankIdx ==4 then
			        	print("reGold~~~~~~~~~~",reGold,playerVoApi:getGems())
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
			        
			        if acRecyclingVoApi:getVersion() ==2 and self.chooseTankIdx ==4 and playerVoApi:getGems() <reGold then
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

function acRecyclingTab3:initTwoPic( )
	
  local function bgClick()
  end
  local w = G_VisibleSizeWidth - 50 -- 背景框的宽度
  self.picOneBg= LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),bgClick)
  self.picOneBg:setContentSize(CCSizeMake(w*0.5-32, G_VisibleSizeHeight*0.4))
  self.picOneBg:setAnchorPoint(ccp(0,1))
  self.picOneBg:setPosition(ccp(25, G_VisibleSize.height-165))
  self.bgLayer:addChild(self.picOneBg,1)
  self:initTankShow(3)
  local function bgClick2()
  end
  self.picTwoBg= LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),bgClick2)
  self.picTwoBg:setContentSize(CCSizeMake(w*0.5-32, G_VisibleSizeHeight*0.4))
  self.picTwoBg:setAnchorPoint(ccp(1,1))
  self.picTwoBg:setPosition(ccp(615,G_VisibleSize.height-165))
  self.bgLayer:addChild(self.picTwoBg,1)
  self:initTankShow(4)

end

function acRecyclingTab3:dispose( )
	self.bgLayer=nil

	self.picOneBg=nil
	self.picTwoBg=nil
	self.touchPicOne=nil
	self.touchipicTwo=nil
	self.touchPicNum=1
	self.arrowPointG=nil
	self.arrowActionTF=true

	self.haveTankNum_1=0
	self.haveTankNum_2=0

	self.aid=nil
	self.tankid=nil
	self.aidChoose=nil
	self.chooseTankIdx =nil --默认为3  3，4两个配置坦克的选择
	self.tb =nil --坦克组装的需求
	self.m_numLb=nil
	self.countTb=nil
	self.numTab=nil
end