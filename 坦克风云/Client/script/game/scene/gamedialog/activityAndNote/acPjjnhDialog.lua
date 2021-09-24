acPjjnhDialog = commonDialog:new()

function acPjjnhDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.isToday=true
    self.tvHeight=140
    self.darkSp={}
    self.brightSp={}
    self.hLineSp={} -- 外圈
	self.oLineSp={} -- 内环
	self.defaultSp={}
	self.sqrtParticle={}
	self.lastL=0
    spriteController:addPlist("public/acPjjnh.plist")
    return nc
end

function acPjjnhDialog:resetTab()
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
	self.panelLineBg:setContentSize(CCSizeMake(620,G_VisibleSize.height-100))
end

function acPjjnhDialog:initTableView( )
end

function acPjjnhDialog:doUserHandler()
	self.activeName=acPjjnhVoApi:getActiveName()
	local flickReward=acPjjnhVoApi:getFlickReward()
	self.flickItem = FormatItem(flickReward)

	local flag=acPjjnhVoApi:logFlagByName()
	local acVo=acPjjnhVoApi:getAcVo()
	if (flag==nil or flag==0) and acVo and acVo.l and acVo.l~=0 then
		local function getlog(fn,data)
	    	local ret,sData = base:checkServerData(data)
	    	if ret==true then
	    		acPjjnhVoApi:setLogFlag()
				if sData and sData.data and sData.data[self.activeName] then
					acPjjnhVoApi:updateSpecialData(sData.data[self.activeName])
				end
				self:initLayer()
			end
	    end
	    local action="getlog"
	    socketHelper:acPjjnh(action,nil,nil,self.activeName,nil,getlog)
	else
		self:initLayer()
	end
end

function acPjjnhDialog:initLayer()
	local strSize2 = 21
	local addPos = 5
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
		strSize2 = 25
		addPos = 0
	end
	local function onRechargeChange(event,data)
		self:checkCost()
	end
	self.PjjnhListener=onRechargeChange
	eventDispatcher:addEventListener("activity.recharge",onRechargeChange)

	local w = G_VisibleSizeWidth - 40 -- 背景框的宽度
	local h = G_VisibleSizeHeight - 95
	local function  bgClick()
		-- body
	end
	local baspH=150
	if G_getIphoneType() == G_iphoneX then
		baspH = 235
	end
	self.baspH=baspH
	local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),bgClick)
	backSprie:setPosition(self.bgLayer:getContentSize().width/2,h)
	backSprie:setContentSize(CCSizeMake(w, baspH))
	backSprie:setAnchorPoint(ccp(0.5,1))
	self.bgLayer:addChild(backSprie,2)

	local bsW=backSprie:getContentSize().width
	local bsH=backSprie:getContentSize().height
	local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),25)
	acLabel:setAnchorPoint(ccp(0.5,1))
	acLabel:setColor(G_ColorGreen)
	acLabel:setPosition(bsW/2,bsH-10)
	backSprie:addChild(acLabel,1)

	local acLbH = acLabel:getContentSize().height

	local acVo = acPjjnhVoApi:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
	local timeLabel=GetTTFLabel(timeStr,25)
	timeLabel:setAnchorPoint(ccp(0.5,1))
	timeLabel:setPosition(ccp(bsW/2, bsH-10-acLbH-5))
	backSprie:addChild(timeLabel,3)
	self.timeLb=timeLabel
	self:updateAcTime()

	local function touchInfo()
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end
        PlayEffect(audioCfg.mouseClick)
		local td=smallDialog:new()
		local tabStr = {"\n",getlocal("activity_pjjnh_tip3"),"\n",getlocal("activity_pjjnh_tip2"),"\n",getlocal("activity_pjjnh_tip1"),"\n"}
		local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,nil)
		sceneGame:addChild(dialog,self.layerNum+1)
	end
	local menuItem=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon2.png",touchInfo,1,nil,0)
	menuItem:setAnchorPoint(ccp(1,1))
	menuItem:setScale(0.8)
	local menuBtn=CCMenu:createWithItem(menuItem)
	menuBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	menuBtn:setPosition(ccp(bsW-10, bsH-20))
	backSprie:addChild(menuBtn,2)

	local desLb=GetTTFLabelWrap(getlocal("activity_pjjnh_des"),strSize2,CCSizeMake(550,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	desLb:setAnchorPoint(ccp(0,0.5))
	desLb:setPosition(20,(bsH-10-acLbH-5-timeLabel:getContentSize().height-5-10)/2+5+addPos)
	backSprie:addChild(desLb)

	local tabTb={getlocal("activity_pjjnh_smallTab1"),getlocal("activity_pjjnh_smallTab2")}
	local tabBtn=CCMenu:create()
	local tabIndex=0
	local tabBtnItem
	if tabTb~=nil then
       for k,v in pairs(tabTb) do
           local lbSize=30
           tabBtnItem = CCMenuItemImage:create("tabBtnBig.png", "tabBtnBig_Selected.png","tabBtnBig_Selected.png")
           tabBtnItem:setAnchorPoint(CCPointMake(0.5,0.5))
           local tabBtnItemPosH = h-baspH-tabBtnItem:getContentSize().height/2
			if k==1 then
				tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,tabBtnItemPosH)
			elseif k==2 then
				tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,tabBtnItemPosH)
			end
			self.tabBtnItemH=tabBtnItem:getContentSize().height

           local function tabClick(idx)
               self.oldSelectedTabIndex=self.selectedTabIndex
               self:tabClickColor(idx)
               return self:tabClick(idx)
           end
           tabBtnItem:registerScriptTapHandler(tabClick)
           
           local lb=GetTTFLabelWrap(v,lbSize,CCSizeMake((self.bgLayer:getContentSize().width-20)/SizeOfTable(tabTb),0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
           lb:setPosition(CCPointMake(tabBtnItem:getContentSize().width/2,tabBtnItem:getContentSize().height/2))
           tabBtnItem:addChild(lb,1)
		   lb:setTag(31)
           if k~=1 then
              lb:setColor(G_TabLBColorGreen)
           end
	 
		   if k==2 then
				local tipSp = CCSprite:createWithSpriteFrameName("IconTip.png");
				tipSp:setAnchorPoint(CCPointMake(1,0.5))
				tipSp:setPosition(ccp(tabBtnItem:getContentSize().width,tabBtnItem:getContentSize().height-15));
				tipSp:setTag(101);
				tipSp:setVisible(false)
				tabBtnItem:addChild(tipSp)
				self.tipSp=tipSp
		   end
           
			
           self.allTabs[k]=tabBtnItem
           tabBtn:addChild(tabBtnItem)
           tabBtn:setTouchPriority(-(self.layerNum-1)*20-4)
           tabBtnItem:setTag(tabIndex)
           tabIndex=tabIndex+1
       end
   end
	tabBtn:setPosition(0,0)
	self.bgLayer:addChild(tabBtn,1)
	self:tabClick(0,false)

	self:refreshTaskList()

	local lineSp =CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, 3))
	lineSp:ignoreAnchorPointForPosition(false);
	lineSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,G_VisibleSizeHeight - 95-self.baspH-self.tabBtnItemH-5))
	self.bgLayer:addChild(lineSp)

end

function acPjjnhDialog:initBottomSp1()

	local blueBg=CCSprite:create("public/superWeapon/weaponBg.jpg")
	blueBg:setAnchorPoint(ccp(0.5,0.5))
	blueBg:setScaleX((G_VisibleSizeWidth-40)/blueBg:getContentSize().width)
	blueBg:setScaleY((self.bottomSp1:getContentSize().height-30)/blueBg:getContentSize().height)
	blueBg:setPosition(self.bottomSp1:getContentSize().width/2,self.bottomSp1:getContentSize().height/2+10)
	self.bottomSp1:addChild(blueBg)

	local bsH=135
	local function nilFunc()
	end
	local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),nilFunc)
	backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40, bsH))
	backSprie:setAnchorPoint(ccp(0.5,0))
	backSprie:setPosition(ccp(G_VisibleSizeWidth/2, 10))
	self.bottomSp1:addChild(backSprie,2)
	backSprie:setOpacity(0)

	local bottomSp=CCSprite:createWithSpriteFrameName("acPjjnh_bottom.png")
	self.bottomSp1:addChild(bottomSp,4)
	bottomSp:setPosition(G_VisibleSizeWidth/2,(self.bottomSp1:getContentSize().height-bsH)/2+bsH)
	self.panSp=bottomSp

	local function touchLibao()
		if G_checkClickEnable()==false then
		    do
		        return
		    end
		else
		    base.setWaitTime=G_getCurDeviceMillTime()
		end
		acPjjnhVoApi:showSmallDialog(self.layerNum+1,2)
	end
	local libaoSp=LuaCCSprite:createWithSpriteFrameName("friendBtn.png",touchLibao)
	libaoSp:setTouchPriority(-(self.layerNum-1)*20-2)
	-- CCSprite:createWithSpriteFrameName("friendBtn.png")
	bottomSp:addChild(libaoSp,3)
	libaoSp:setPosition(bottomSp:getContentSize().width/2,bottomSp:getContentSize().height/2)
	libaoSp:setScale(1.1)
	self.libaoSp=libaoSp

	-- local dNumSp=CCSprite:createWithSpriteFrameName("double_num.png")
	-- dNumSp:setScale(0.8)
	-- dNumSp:setPosition(bottomSp:getContentSize().width/2+45,bottomSp:getContentSize().height/2-30)
	-- bottomSp:addChild(dNumSp,4)
	if acPjjnhVoApi:getVersion( ) == 2 then-------!!!!!!!
		local lb=GetBMLabel("*",G_GoldFontSrc2,30)
	    lb:setAnchorPoint(ccp(0,0.5))
	    lb:setPosition(ccp(bottomSp:getContentSize().width/2+15,bottomSp:getContentSize().height/2-60))
	    bottomSp:addChild(lb,4)
	    lb:setScale(0.8)

	    local lb2=GetBMLabel("3",G_GoldFontSrc2,30)
	    lb2:setAnchorPoint(ccp(0,0.5))
	    lb2:setPosition(ccp(lb:getPositionX()+lb:getContentSize().width*0.6,bottomSp:getContentSize().height/2-60))
	    bottomSp:addChild(lb2,4)
	    lb2:setScale(0.8)
	else
		local dNumSp=CCSprite:createWithSpriteFrameName("double_num.png")
		dNumSp:setScale(0.8)
		dNumSp:setPosition(bottomSp:getContentSize().width/2+45,bottomSp:getContentSize().height/2-30)
		bottomSp:addChild(dNumSp,4)
	end

	local acVo=acPjjnhVoApi:getAcVo()
	local rlog=acPjjnhVoApi:getRlog()
	self:isAddNeiParticle()
	

	local linePosTb={{132, 407,0,60},{357, 407,60,120},{470, 212,120,180},{357, 15,180,-120},{132, 15,-120,-60},{18, 211,-60,0}}
	local bulbPosTb={{208.5, 275.5},{282.5, 274.5},{316.5, 211.5},{282.5, 145.5},{207.5, 145.5},{172.5, 211.5}}
	self.linePosTb=linePosTb
	self.bulbPosTb=bulbPosTb
	for k,v in pairs(bulbPosTb) do
		local anSp=CCSprite:createWithSpriteFrameName("acPjjnh_darkBulb.png")
		bottomSp:addChild(anSp,2)
		anSp:setPosition(v[1],v[2])

		local liangSp=CCSprite:createWithSpriteFrameName("acPjjnh_brightBulb.png")
		bottomSp:addChild(liangSp,2)
		liangSp:setPosition(v[1],v[2])
		liangSp:setVisible(false)

		self.darkSp[k]=anSp
	    self.brightSp[k]=liangSp

	end

	for k,v in pairs(linePosTb) do
		local lineSp=CCSprite:createWithSpriteFrameName("acPjjnh_line.png")
		bottomSp:addChild(lineSp)
		lineSp:setAnchorPoint(ccp(0,0.5))
		lineSp:setPosition(v[1],v[2])
		lineSp:setRotation(v[3])
		self.hLineSp[k]=lineSp
		-- lineSp:setScaleX(2.8)
		lineSp:setScaleX(0.1)

		local lineSp2=CCSprite:createWithSpriteFrameName("acPjjnh_line.png")
		bottomSp:addChild(lineSp2)
		lineSp2:setAnchorPoint(ccp(0,0.5))
		lineSp2:setPosition(v[1],v[2])
		lineSp2:setRotation(v[4])
		self.oLineSp[k]=lineSp2
		lineSp2:setScaleX(0.1)

		local function touchDefault()
			if G_checkClickEnable()==false then
			    do
			        return
			    end
			else
			    base.setWaitTime=G_getCurDeviceMillTime()
			end
			acPjjnhVoApi:showSmallDialog(self.layerNum+1,1)
		end
		local defaultSp=LuaCCSprite:createWithSpriteFrameName("BlueBoxRandom.png",touchDefault)
		defaultSp:setTouchPriority(-(self.layerNum-1)*20-2)
		defaultSp:setScale(88/defaultSp:getContentSize().width)
	    bottomSp:addChild(defaultSp,2)
		defaultSp:setPosition(v[1],v[2])
		self.defaultSp[k]=defaultSp

		local spBg=CCSprite:createWithSpriteFrameName("accessoryMetalBg.png")
		spBg:setPosition(v[1],v[2])
		bottomSp:addChild(spBg,1)
	end
	
	if acVo and acVo.l and acVo.l>0 then
		for k,v in pairs(rlog) do
			local rewardItem=FormatItem(v[2])
			local icon,scale=G_getItemIcon(rewardItem[1],88,true,self.layerNum)
			icon:setTouchPriority(-(self.layerNum-1)*20-3)
			icon:setPosition(linePosTb[v[1]][1],linePosTb[v[1]][2])
			icon:setTag(v[1])
			bottomSp:addChild(icon,3)

			local numLb = GetTTFLabel("x" .. rewardItem[1].num,25)
			icon:addChild(numLb)
			numLb:setAnchorPoint(ccp(1,0))
			numLb:setPosition(icon:getContentSize().width-5,5)
			numLb:setScale(1/scale)
			numLb:setTag(1)



			self.hLineSp[v[1]]:setScaleX(2.8)
			self.oLineSp[v[1]]:setScaleX(1.8)
			self.brightSp[v[1]]:setVisible(true)

			local lineP = self:createParticle("public/acPjjnh_lineP.plist",1/2.8*1.1,1,ccp(0,self.hLineSp[v[1]]:getContentSize().height/2),self.hLineSp[v[1]],10)
			lineP:setAnchorPoint(ccp(0,0.5))

			local lineP2 = self:createParticle("public/acPjjnh_lineP.plist",1/1.8*0.9,1,ccp(0,self.oLineSp[v[1]]:getContentSize().height/2),self.oLineSp[v[1]],10)
			lineP2:setAnchorPoint(ccp(0,0.5))
		end
	end



	local function btnClick(tag,object)
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end
        PlayEffect(audioCfg.mouseClick)
        if tag~=3 then
        	local cost = acPjjnhVoApi:getCostByType(tag)
			if cost>playerVoApi:getGems() then
				GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost,nil)
				return
			end
        end
        
        local function getRawardCallback(fn,data)
			local oldHeroList=heroVoApi:getHeroList()
			local ret,sData = base:checkServerData(data)
			if ret==true then
				if sData and sData.data and sData.data[self.activeName] then
					acPjjnhVoApi:updateSpecialData(sData.data[self.activeName])
				end
				if sData and sData.data and sData.data.accessory then
        			accessoryVoApi:onRefreshData(sData.data.accessory)
        		end
        		if tag==3 then
			        self.isToday=true
			    else
			    	local playerGem=playerVoApi:getGems()
					local cost = acPjjnhVoApi:getCostByType(tag)
					playerVoApi:setGems(playerGem-cost)
				end
				if sData and sData.data and sData.data.report then
					local report = sData.data.report
					local reward = {}
                    for k,v in pairs(report) do
                        local item = FormatItem(v[2])
                        table.insert(reward,item[1])
                        G_addPlayerAward(item[1].type,item[1].key,item[1].id,item[1].num,true)
                    end
                    if tag==1 or tag==3 then
                    	local pjjnhVo=acPjjnhVoApi:getAcVo()
                    	local isFirst=false
                    	if self.lastL and pjjnhVo and pjjnhVo.l then
                    		if math.abs(self.lastL-pjjnhVo.l)==6 then
                    			isFirst=true
                    		end
                    	end
                    	self.lastL=pjjnhVo.l
						self:showOneSearch(3,reward[1],self.layerNum+1,isFirst)
					else
						self:showTenSearch(reward)
					end
				end
				
				self:checkCost()
				self:refreshTaskList()
				
			end
		end
		local action="rand"
		local free=false
		local num=1
		if tag==3 then
			free=true
		end
		if tag==2 then
			num=2
		end
		socketHelper:acPjjnh(action,free,num,self.activeName,nil,getRawardCallback)
	end
	local btnItem1=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",btnClick,1,getlocal("activation"),25)
	btnItem1:setAnchorPoint(ccp(0.5,0))
	self.btnItem1=btnItem1
	local btn1=CCMenu:createWithItem(btnItem1);
	btn1:setTouchPriority(-(self.layerNum-1)*20-4);
	btn1:setPosition(ccp(G_VisibleSizeWidth/2-150,15))
	if G_getIphoneType() == G_iphoneX then
		btn1:setPosition(ccp(G_VisibleSizeWidth/2-150,45))
	end
	backSprie:addChild(btn1)

	local goldIconAddH=18
	local cost1=acPjjnhVoApi:getCostByType(1)
	local goldIcon1 = CCSprite:createWithSpriteFrameName("IconGold.png")
	goldIcon1:setAnchorPoint(ccp(0,0.5))
	goldIcon1:setPosition(btnItem1:getContentSize().width/2+10,btnItem1:getContentSize().height+goldIconAddH)
	btnItem1:addChild(goldIcon1)

	local costLb1 = GetTTFLabel(cost1, 25)
	costLb1:setAnchorPoint(ccp(1,0.5))
	costLb1:setPosition(ccp(btnItem1:getContentSize().width/2,btnItem1:getContentSize().height+goldIconAddH))
	btnItem1:addChild(costLb1)
	self.costLb1=costLb1

	local btnItem2=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",btnClick,2,getlocal("activity_pjjnh_btn2"),25)
	btnItem2:setAnchorPoint(ccp(0.5,0))
	local btn2=CCMenu:createWithItem(btnItem2);
	btn2:setTouchPriority(-(self.layerNum-1)*20-4);
	btn2:setPosition(ccp(G_VisibleSizeWidth/2+150,15))
	if G_getIphoneType() == G_iphoneX then
		btn2:setPosition(ccp(G_VisibleSizeWidth/2+150,45))
	end
	backSprie:addChild(btn2)

	local cost2=acPjjnhVoApi:getCostByType(2)
	local goldIcon2 = CCSprite:createWithSpriteFrameName("IconGold.png")
	goldIcon2:setAnchorPoint(ccp(0,0.5))
	goldIcon2:setPosition(btnItem2:getContentSize().width/2+15,btnItem2:getContentSize().height+goldIconAddH)
	btnItem2:addChild(goldIcon2)

	local costLb2 = GetTTFLabel(cost2, 25)
	costLb2:setAnchorPoint(ccp(1,0.5))
	costLb2:setPosition(ccp(btnItem2:getContentSize().width/2+5,btnItem2:getContentSize().height+goldIconAddH))
	btnItem2:addChild(costLb2)
	self.costLb2=costLb2

	local freeItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",btnClick,3,getlocal("activity_equipSearch_free_btn"),25)
	freeItem:setAnchorPoint(ccp(0.5,0))
	self.freeItem=freeItem
	local freeBtn=CCMenu:createWithItem(freeItem);
	freeBtn:setTouchPriority(-(self.layerNum-1)*20-4);
	freeBtn:setPosition(ccp(G_VisibleSizeWidth/2-150,15))
	if G_getIphoneType() == G_iphoneX then
		freeBtn:setPosition(ccp(G_VisibleSizeWidth/2-150,45))
	end
	backSprie:addChild(freeBtn)

	self:checkCost()
end

function acPjjnhDialog:initBottomSp2()
	self:refreshTaskList()
	local function callBack(...)
    	return self:eventHandler(...)
    end

    local hd= LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-40,self.bottomSp2:getContentSize().height-30-10),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,30))
    self.bottomSp2:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(80)
end

function acPjjnhDialog:refreshTaskList()
	self.taskList = acPjjnhVoApi:getTask()
	for k,v in pairs(self.taskList) do
		if v.isReceive==2 then
			self.tipSp:setVisible(true)
			return 
		end
	end
	self.tipSp:setVisible(false)
end

function acPjjnhDialog:refreshTableView()
	self:refreshTaskList()
	local recordPoint=self.tv:getRecordPoint()
	self.tv:reloadData()
	self.tv:recoverToRecordPoint(recordPoint)
end


function acPjjnhDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
	    return SizeOfTable(self.taskList)
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-40,self.tvHeight)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local taskInfo = self.taskList[idx+1]

		local backResource="panelItemBg.png"
		if taskInfo.isReceive==2 then
			backResource="7daysLight.png"
		end
		local function nilFunc()
		end
		local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName(backResource,CCRect(20, 20, 10, 10),nilFunc)
		backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-40, self.tvHeight-5))
		backSprie:setAnchorPoint(ccp(0,0));
		cell:addChild(backSprie,1)

		-- BlackAlphaBg

		local desLb=GetTTFLabelWrap(taskInfo.des,22,CCSizeMake(G_VisibleSizeWidth-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		desLb:setAnchorPoint(ccp(0,1))
		desLb:setPosition(ccp(10,backSprie:getContentSize().height-10))
		backSprie:addChild(desLb)
		desLb:setColor(G_ColorYellowPro)

		local iconW=80
		for k,v in pairs(taskInfo.reward) do
			local icon,scale=G_getItemIcon(v,iconW,true,self.layerNum)
			icon:setTouchPriority(-(self.layerNum-1)*20-2)
			icon:setPosition(10+iconW/2+(k-1)*iconW,(backSprie:getContentSize().height-10-desLb:getContentSize().height)/2)
			backSprie:addChild(icon)

			local numLb = GetTTFLabel("x" .. v.num,25)
			icon:addChild(numLb)
			numLb:setAnchorPoint(ccp(1,0))
			numLb:setPosition(icon:getContentSize().width-5,5)
			numLb:setScale(1/scale)
			numLb:setTag(1)
		end


		if taskInfo.isReceive==1 then -- 已领取
			local mengSprie =LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
			mengSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-40, self.tvHeight-5))
			mengSprie:setPosition(backSprie:getContentSize().width/2,backSprie:getContentSize().height/2)
			mengSprie:setOpacity(180)
			backSprie:addChild(mengSprie,2)

			local alreadyLb=GetTTFLabelWrap(getlocal("activity_hadReward"),22,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			alreadyLb:setPosition(ccp(backSprie:getContentSize().width-80,backSprie:getContentSize().height/2))
			backSprie:addChild(alreadyLb,3)
			alreadyLb:setColor(G_ColorGreen)
		elseif taskInfo.isReceive==2 then -- 可领取
			local function btnClick(tag,object)
				if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
				    if G_checkClickEnable()==false then
				        do
				            return
				        end
				    else
				        base.setWaitTime=G_getCurDeviceMillTime()
				    end
				    -- 添加代码
				    local function changeTask(fn,data)
				    	local ret,sData = base:checkServerData(data)
				    	if ret==true then
				    		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("receivereward_received_success"),30)
							if sData and sData.data and sData.data[self.activeName] then
								acPjjnhVoApi:updateSpecialData(sData.data[self.activeName])
							end
							if sData and sData.data and sData.data.accessory then
			        			accessoryVoApi:onRefreshData(sData.data.accessory)
			        		end
			        		for k,v in pairs(taskInfo.reward) do
		                        G_addPlayerAward(v.type,v.key,v.id,v.num,true)
		                    end
							self:refreshTableView()
						end
				    end
				    local action="task"
				    socketHelper:acPjjnh(action,nil,nil,self.activeName,taskInfo.tid,changeTask)
				end
			end
			local getItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",btnClick,1,getlocal("daily_scene_get"),25)
			getItem:setAnchorPoint(ccp(0.5,0.5))
			getItem:setScale(0.8)
			local getBtn=CCMenu:createWithItem(getItem);
			getBtn:setTouchPriority(-(self.layerNum-1)*20-2);
			getBtn:setPosition(ccp(backSprie:getContentSize().width-80,backSprie:getContentSize().height/2))
			backSprie:addChild(getBtn)
		elseif taskInfo.isReceive==3 then -- 不能领取
			local noReachLb=GetTTFLabelWrap(getlocal("noReached"),22,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			noReachLb:setPosition(ccp(backSprie:getContentSize().width-80,backSprie:getContentSize().height/2))
			backSprie:addChild(noReachLb)
			noReachLb:setColor(G_ColorRed)
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

function acPjjnhDialog:showOneSearch(type,item,layerNum,firstFlag)
	local circleP
	local time=0
	if firstFlag then
		time=1
		circleP=self:createParticle("public/acPjjnh_circleP.plist",1.7,1.7,ccp(self.panSp:getContentSize().width/2,self.panSp:getContentSize().height/2),self.panSp,3)

	end
	self:isAddHuangguang(item.key,item.num)
	
	local function nilFunc()
	end
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-9)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(255)
	touchDialogBg:setAnchorPoint(ccp(0,0))
	touchDialogBg:setPosition(ccp(0,0))
	self.panSp:addChild(touchDialogBg,10)
	touchDialogBg:setVisible(false)
	self.touchDialogBg=touchDialogBg
	local pos = self.panSp:convertToNodeSpace(ccp(0,0))
	touchDialogBg:setPosition(pos)

	

	local function runTenTunc()
		if circleP then
			circleP:removeFromParentAndCleanup(true)
			circleP=nil
		end
		if self.neiParticle then
			self.neiParticle:removeFromParentAndCleanup(true)
			self.neiParticle=nil
		end
		touchDialogBg:setVisible(true)
		self:runOneSerch(type,item,layerNum)
	end
	local callFunc=CCCallFunc:create(runTenTunc)
    local delay=CCDelayTime:create(time)
    local acArr=CCArray:create()
    acArr:addObject(delay)
    acArr:addObject(callFunc)
    local seq=CCSequence:create(acArr)
    touchDialogBg:runAction(seq)
	
end

function acPjjnhDialog:runOneSerch(type,item,layerNum)
	local touchPos=self.touchDialogBg:convertToNodeSpace(ccp(self.panSp:getPosition()))
	local function callback1()
		local particleS=self:createParticle("public/1.plist",1,1,touchPos,self.touchDialogBg,10)
    end

    local function callback2()
        local mIcon,scale
        mIcon,scale=G_getItemIcon(item,100,true,layerNum)

        if mIcon then
        	mIcon:setTouchPriority(-(self.layerNum-1)*20-3)
        	local numLb = GetTTFLabel("x" .. item.num,25)
			mIcon:addChild(numLb)
			numLb:setAnchorPoint(ccp(1,0))
			numLb:setPosition(mIcon:getContentSize().width-5,5)
			numLb:setVisible(false)
			numLb:setTag(1)

            local function callback3()
                local lightSp = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
                -- local lightSp = CCSprite:createWithSpriteFrameName("BgSelect.png")
                lightSp:setAnchorPoint(ccp(0.5,0.5))
                lightSp:setPosition(touchPos)
                self.touchDialogBg:addChild(lightSp,10)
                lightSp:setScale(2)

                local descStr=""
                local nameStr=item.name or ""
                if item.type=="h" and item.eType=="h" then
                else
                    nameStr=nameStr.."x"..item.num
                end
                if type==1 then
                    descStr=getlocal("getNewHeroDesc")
                elseif type==2 then
                    descStr=getlocal("getNewSoulDesc")
                else
                    descStr=getlocal("activity_chunjiepansheng_getReward") .. ":"
                end
                local lb=GetTTFLabelWrap(descStr,30,CCSizeMake(500,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                lb:setPosition(ccp(touchPos.x,touchPos.y+300))
                lb:setColor(G_ColorYellowPro)
                self.touchDialogBg:addChild(lb,11)

                local nameLb=GetTTFLabel(nameStr,30)
                nameLb:setPosition(ccp(touchPos.x,touchPos.y-150))
                nameLb:setColor(G_ColorYellowPro)
                self.touchDialogBg:addChild(nameLb,11)

                if addSoulNum and addSoulNum>0 then
                    local hid
                    if item.type=="h" then
                        if item.eType=="h" then
                            hid=item.key
                        elseif item.eType=="s" then
                            hid=heroCfg.soul2hero[item.key]
                        end
                    end
                    local existStr=""
                    if hid and heroVoApi:getIsHonored(hid)==true and heroVoApi:heroHonorIsOpen()==true then
                        existStr=getlocal("hero_honor_recruit_honored_hero",{addSoulNum})
                    elseif type==1 and heroIsExist==true then
                        if newProductOrder then
                            existStr=getlocal("hero_breakthrough_desc",{newProductOrder})
                        else
                            existStr=getlocal("alreadyHasDesc",{addSoulNum})
                        end
                    end
                    if existStr and existStr~="" then
                        local existLb=GetTTFLabelWrap(existStr,25,CCSizeMake(500,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                        existLb:setPosition(ccp(touchPos.x,150))
                        existLb:setColor(G_ColorYellowPro)
                        self.self.touchDialogBg:addChild(existLb,11)
                    end
                end
                if score and score~="" then
                    local scoreLb=GetTTFLabelWrap(getlocal("serverwar_get_point")..score,28,CCSizeMake(500,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                    scoreLb:setPosition(ccp(320,350))
                    scoreLb:setColor(G_ColorYellowPro)
                    self.touchDialogBg:addChild(scoreLb,777)
                end
                local function ok( ... )
                	self.touchDialogBg:setVisible(false)
                    self:runAcitonLine(mIcon)
                end

                local okItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",ok,nil,getlocal("confirm"),25,100)
                local okBtn=CCMenu:createWithItem(okItem)
                okBtn:setTouchPriority(-(layerNum)*20-2)
                okBtn:setAnchorPoint(ccp(0.5,0.5))
                okBtn:setPosition(ccp(self.touchDialogBg:getContentSize().width/2,100))
                self.touchDialogBg:addChild(okBtn,11)
                local okLabel = tolua.cast(okItem:getChildByTag(100),"CCLabelTTF")
                okLabel:setPosition(ccp(okItem:getContentSize().width/2,okItem:getContentSize().height/2 + 5))

            end
            mIcon:setScale(0)
            mIcon:setPosition(ccp(self.panSp:getContentSize().width/2,self.panSp:getContentSize().height/2))
            self.panSp:addChild(mIcon,11)
            local ccScaleTo = CCScaleTo:create(0.6,150/mIcon:getContentSize().width)
            local ccScaleTo1 = CCScaleTo:create(0.1,(150+100)/mIcon:getContentSize().width)
            local ccScaleTo2 = CCScaleTo:create(0.1,150/mIcon:getContentSize().width)
            local callFunc3=CCCallFunc:create(callback3)
            local acArr=CCArray:create()
            acArr:addObject(ccScaleTo)
            acArr:addObject(ccScaleTo1)
            acArr:addObject(ccScaleTo2)
            acArr:addObject(callFunc3)
            local seq=CCSequence:create(acArr)
            mIcon:runAction(seq)
        end
    end
	local callFunc1=CCCallFunc:create(callback1)
    local callFunc2=CCCallFunc:create(callback2)

    local delay=CCDelayTime:create(0.2)
    local acArr=CCArray:create()
    acArr:addObject(delay)
    acArr:addObject(callFunc1)
    acArr:addObject(callFunc2)
    local seq=CCSequence:create(acArr)
    self.bottomSp1:runAction(seq)
end

function acPjjnhDialog:runAcitonLine(runSp)
	local acVo=acPjjnhVoApi:getAcVo()
	local pos = acVo.l
	-- self.linePosTb=linePosTb
	-- self.bulbPosTb=bulbPosTb
	if pos~=0 then
		runSp:setTag(pos)
		self.panSp:reorderChild(runSp,3)
		-- runSp:setZOrder(3)
		-- 图标动画
		local time1=0.4
		local time2=0.2
		local moveTo=CCMoveTo:create(time1,ccp(self.linePosTb[pos][1],self.linePosTb[pos][2]))
		local scale=88/runSp:getContentSize().width
		local ccScaleTo = CCScaleTo:create(time2,scale)
		local function numFunc()
			if runSp then
				local numLb=tolua.cast(runSp:getChildByTag(1),"CCLabelTTF")
				if numLb then
					numLb:setVisible(true)
					numLb:setScale(1/scale)
				end
			end
		end
		local numCallFunc=CCCallFunc:create(numFunc)
		local Arr=CCArray:create()
		Arr:addObject(moveTo)
		Arr:addObject(ccScaleTo)
		Arr:addObject(numCallFunc)
		local seq=CCSequence:create(Arr)
		runSp:runAction(seq)

		-- 外圈线动画
		local lineScaleTo = CCScaleTo:create(time1+time2,2.8,1)
		self.hLineSp[pos]:runAction(lineScaleTo)

		-- 内圈动画
		local olineScaleTo = CCScaleTo:create(time1+time2,1.8,1)
		local function oCallback()
			-- 灯闪
			self.brightSp[pos]:setVisible(true)
			local actBlink=CCBlink:create(1, 3)
			self.brightSp[pos]:runAction(actBlink)

			-- 方框粒子
			local scale=100/runSp:getContentSize().width
			local p = self:createParticle("public/acPjjnh_sqrtP.plist",1/scale*1.4,1/scale*1.4,ccp(runSp:getContentSize().width/2,runSp:getContentSize().height/2),runSp,10)
			self.sqrtParticle[pos]=p

			local delay=CCDelayTime:create(0.7)
			local function delayFunc()
				self:removeSqrtParticles(pos)
				self:removeTouchBg()
			end
			local ocallFunc=CCCallFunc:create(delayFunc)
			local dArr=CCArray:create()
			dArr:addObject(delay)
			dArr:addObject(ocallFunc)
			local dSeq=CCSequence:create(dArr)
			runSp:runAction(dSeq)

			-- 线粒子
			local lineP=self:createParticle("public/acPjjnh_lineP.plist",1/2.8*1.1,1,ccp(0,self.hLineSp[pos]:getContentSize().height/2),self.hLineSp[pos],10)
			lineP:setAnchorPoint(ccp(0,0.5))

			local lineP2=self:createParticle("public/acPjjnh_lineP.plist",1/1.8*0.9,1,ccp(0,self.oLineSp[pos]:getContentSize().height/2),self.oLineSp[pos],10)
			lineP2:setAnchorPoint(ccp(0,0.5))
			
		end
		local ocallFunc=CCCallFunc:create(oCallback)
		local oArr=CCArray:create()
		oArr:addObject(olineScaleTo)
		oArr:addObject(ocallFunc)
		local oSeq=CCSequence:create(oArr)
		self.oLineSp[pos]:runAction(oSeq)
	else
		self:removeTouchBg()
		self:resertInitial()
		runSp:removeFromParentAndCleanup(true)
	end
	self:isAddNeiParticle()
end

function acPjjnhDialog:resertInitial()
	for k,v in pairs(self.oLineSp) do
		v:setScaleX(0.1)
	end
	for k,v in pairs(self.hLineSp) do
		v:setScaleX(0.1)
	end
	for k,v in pairs(self.brightSp) do
		v:setVisible(false)
	end
	for i=1,6 do
		local sp=tolua.cast(self.panSp:getChildByTag(i),"CCSprite")
		if sp then
			sp:removeFromParentAndCleanup(true)
			sp=nil
		end
	end
end

function acPjjnhDialog:refreshNowSp()
	local PjjnhVo = acPjjnhVoApi:getAcVo()
	local l=PjjnhVo.l or 0
	for i=1,l do
		local sp=tolua.cast(self.panSp:getChildByTag(i),"CCSprite")
		if sp then
			sp:removeFromParentAndCleanup(true)
			sp=nil
		end
	end
	local rlog=acPjjnhVoApi:getRlog()
	if rlog and l>0 then
		for k,v in pairs(rlog) do
			local rewardItem=FormatItem(v[2])
			local icon,scale=G_getItemIcon(rewardItem[1],88,true,self.layerNum)
			icon:setTouchPriority(-(self.layerNum-1)*20-3)
			icon:setPosition(self.linePosTb[v[1]][1],self.linePosTb[v[1]][2])
			icon:setTag(v[1])
			self.panSp:addChild(icon,3)

			local numLb = GetTTFLabel("x" .. rewardItem[1].num,25)
			icon:addChild(numLb)
			numLb:setAnchorPoint(ccp(1,0))
			numLb:setPosition(icon:getContentSize().width-5,5)
			numLb:setScale(1/scale)
			numLb:setTag(1)
		end
	end
end

function acPjjnhDialog:removeTouchBg()
	if self.touchDialogBg then
		self.touchDialogBg:removeFromParentAndCleanup(true)
		self.touchDialogBg=nil
	end
end

function acPjjnhDialog:removeSqrtParticles(pos)
	if pos and self.sqrtParticle[pos] then
		self.sqrtParticle[pos]:removeFromParentAndCleanup(true)
		self.sqrtParticle[pos]=nil
	end
end

function acPjjnhDialog:showTenSearch(reward)
	local circleP=self:createParticle("public/acPjjnh_circleP.plist",1.7,1.7,ccp(self.panSp:getContentSize().width/2,self.panSp:getContentSize().height/2),self.panSp,3)

	local function nilFunc()
		if self.isAction==false then
            for k,v in pairs(self.spTb) do
                v:stopAllActions()
                v:setScale(100/v:getContentSize().width)
                self.isAction=true

                if self.guangSpTb[k] then
                    self.guangSpTb[k]:stopAllActions()
                    self.guangSpTb[k]:setScale(1.6)
                    local rotateBy = CCRotateBy:create(4,360)
                    local reverseBy = rotateBy:reverse()
                    self.guangSpTb[k]:runAction(CCRepeatForever:create(reverseBy))
                    -- guangSpTb[k]:runAction(CCRepeatForever:create(rotateBy))
                end

                if self.guangSpTb2[k] then
                    self.guangSpTb2[k]:stopAllActions()
                    self.guangSpTb2[k]:setScale(1.6)
                    local rotateBy = CCRotateBy:create(4,360)
                    -- local reverseBy = rotateBy:reverse()
                    -- self.guangSpTb2[k]:runAction(CCRepeatForever:create(reverseBy))
                    self.guangSpTb2[k]:runAction(CCRepeatForever:create(rotateBy))
                end
                
            end
            self.okBtn:setVisible(true)
        end
	end
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-9)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(240)
	touchDialogBg:setAnchorPoint(ccp(0,0))
	touchDialogBg:setPosition(ccp(0,0))
	self.panSp:addChild(touchDialogBg,10)
	self.touchDialogBg=touchDialogBg
	local pos = self.panSp:convertToNodeSpace(ccp(0,0))
	touchDialogBg:setPosition(pos)
	touchDialogBg:setVisible(false)

	local function runTenTunc()
		self:refreshNowSp()
		circleP:removeFromParentAndCleanup(true)
		self:runTenAction(reward)
	end
	local callFunc=CCCallFunc:create(runTenTunc)
    local delay=CCDelayTime:create(1)
    local acArr=CCArray:create()
    acArr:addObject(delay)
    acArr:addObject(callFunc)
    local seq=CCSequence:create(acArr)
    touchDialogBg:runAction(seq)
end

function acPjjnhDialog:runTenAction(reward)
	self.touchDialogBg:setVisible(true)
	local titlesubH=250
	local subH = 380
	if(G_isIphone5()==false)then
		titlesubH=150
		subH = 260
	end
	local titleLb = GetTTFLabelWrap(getlocal("activity_chunjiepansheng_getReward") .. ":",30,CCSizeMake(500,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLb:setPosition(ccp(320,self.touchDialogBg:getContentSize().height-titlesubH))
    titleLb:setColor(G_ColorYellowPro)
    self.touchDialogBg:addChild(titleLb)

    self.isAction = false

    local spTb={}
    local guangSpTb={}
    local guangSpTb2={}
    
    local everyH=180
    local startH=self.touchDialogBg:getContentSize().height-subH
    for k,v in pairs(reward) do
        
        local i=math.ceil(k/3)
        local j=k%3
        if j==0 then
            j=3
        end

        local sp,scale = G_getItemIcon(v,100,false)
        self.touchDialogBg:addChild(sp,4)
       
        -- sp:setAnchorPoint(ccp(0,0.5))
        sp:setPosition(68+(j-1)*200+50, startH-(i-1)*everyH)
        if k==SizeOfTable(reward) then
            sp:setPosition(68+(2-1)*200+50, startH-(i-1)*everyH)
        end

        local nameLb = GetTTFLabelWrap(v.name .. "x" .. v.num,22,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        nameLb:setPosition(ccp(sp:getContentSize().width/2,-40))
        sp:addChild(nameLb)
        
        sp:setScale(0.0001)
        nameLb:setScale(1/scale)
        table.insert(spTb,sp)

        local flag = self:isAddHuangguang(v.key,v.num)
        if flag == true then
            local guangSp = CCSprite:createWithSpriteFrameName("equipShine.png")
            self.touchDialogBg:addChild(guangSp,1)
            guangSp:setPosition(68+(j-1)*200+50, startH-(i-1)*everyH)
            if k==SizeOfTable(reward) then
                guangSp:setPosition(68+(2-1)*200+50, startH-(i-1)*everyH)
            end
            guangSp:setScale(0.0001)
            guangSpTb[k]=guangSp

            local guangSp = CCSprite:createWithSpriteFrameName("equipShine.png")
            self.touchDialogBg:addChild(guangSp,1)
            guangSp:setPosition(68+(j-1)*200+50, startH-(i-1)*everyH)
            if k==SizeOfTable(reward) then
                guangSp:setPosition(68+(2-1)*200+50, startH-(i-1)*everyH)
            end
            guangSp:setScale(0.0001)
            guangSpTb2[k]=guangSp
        end
    end

    for k,v in pairs(spTb) do
        local time = (k-1)*0.7

         if guangSpTb[k] then
            local delay=CCDelayTime:create(time)
            local scaleTo1 = CCScaleTo:create(0.6,2)
            local scaleTo2 = CCScaleTo:create(0.1,1.6)
            local acArr=CCArray:create()
            acArr:addObject(delay)
            acArr:addObject(scaleTo1)
            acArr:addObject(scaleTo2)

            local function callback()
                local rotateBy = CCRotateBy:create(4,360)
                local reverseBy = rotateBy:reverse()
                guangSpTb[k]:runAction(CCRepeatForever:create(reverseBy))
                -- guangSpTb[k]:runAction(CCRepeatForever:create(rotateBy))
            end
            local callFunc=CCCallFunc:create(callback)
            acArr:addObject(callFunc)

            local seq=CCSequence:create(acArr)
            guangSpTb[k]:runAction(seq)
        end


         if guangSpTb2[k] then
            local delay=CCDelayTime:create(time)
            local scaleTo1 = CCScaleTo:create(0.6,2)
            local scaleTo2 = CCScaleTo:create(0.1,1.6)
            local acArr=CCArray:create()
            acArr:addObject(delay)
            acArr:addObject(scaleTo1)
            acArr:addObject(scaleTo2)

            local function callback()
                local rotateBy = CCRotateBy:create(4,360)
                -- local reverseBy = rotateBy:reverse()
                -- guangSpTb2[k]:runAction(CCRepeatForever:create(reverseBy))
                guangSpTb2[k]:runAction(CCRepeatForever:create(rotateBy))
            end
            local callFunc=CCCallFunc:create(callback)
            acArr:addObject(callFunc)

            local seq=CCSequence:create(acArr)
            guangSpTb2[k]:runAction(seq)
        end



        local delay=CCDelayTime:create(time)
        local scale1=120/v:getContentSize().width
     	local scale2=100/v:getContentSize().width
        local scaleTo1 = CCScaleTo:create(0.3,scale1)
        local scaleTo2 = CCScaleTo:create(0.05,scale2)
        local acArr=CCArray:create()
        acArr:addObject(delay)
        acArr:addObject(scaleTo1)
        acArr:addObject(scaleTo2)
        if k==SizeOfTable(reward) then
            local function callback()
                self.isAction=true
                self.okBtn:setVisible(true)
            end
            local callFunc=CCCallFunc:create(callback)
            acArr:addObject(callFunc)
        end
        local seq=CCSequence:create(acArr)
        v:runAction(seq)
    end

    self.guangSpTb=guangSpTb
    self.guangSpTb2=guangSpTb2
    self.spTb=spTb

    local function ok()
    	if G_checkClickEnable()==false then
		    do
		        return
		    end
		else
		    base.setWaitTime=G_getCurDeviceMillTime()
		end
        self.touchDialogBg:removeFromParentAndCleanup(true)
        self.touchDialogBg=nil
    end

    local okItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",ok,nil,getlocal("confirm"),25,100)
    local okBtn=CCMenu:createWithItem(okItem)
    okBtn:setTouchPriority(-(self.layerNum+1)*20-1)
    okBtn:setAnchorPoint(ccp(0.5,0.5))
    self.touchDialogBg:addChild(okBtn)
    okBtn:setVisible(false)
    self.okBtn=okBtn
    local okLabel = tolua.cast(okItem:getChildByTag(100),"CCLabelTTF")
    okLabel:setPosition(ccp(okItem:getContentSize().width/2,okItem:getContentSize().height/2 + 5))
    okBtn:setPosition(ccp(self.touchDialogBg:getContentSize().width/2,150))
end

function acPjjnhDialog:isAddHuangguang(key,num)
    for k,v in pairs(self.flickItem) do
		-- for kk,vv in pairs(self.flickReward) do
		if v.key==key and v.num==num then
			local message={key="activity_pjjnh_chatSystemMessage",param={playerVoApi:getPlayerName(),getlocal("activity_pjjnh_title"),v.name .. "*" .. v.num}}
	          chatVoApi:sendSystemMessage(message)
          return true
		end
		-- end
    end
    return false
end

function acPjjnhDialog:tabClick(idx,isEffect)
	if(isEffect)then
		PlayEffect(audioCfg.mouseClick)
	end
	for k,v in pairs(self.allTabs) do
		if v:getTag()==idx then
			v:setEnabled(false)
			self.selectedTabIndex=idx
		else
			v:setEnabled(true)
		end
	end
	if(idx==0)then
		if(self.bottomSp1==nil)then
			local function nilFunc()
			end
			self.bottomSp1=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),nilFunc)
			self.bottomSp1:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight - 95-self.baspH-self.tabBtnItemH))
			self.bottomSp1:setAnchorPoint(ccp(0,0))
			self.bgLayer:addChild(self.bottomSp1,3)
			self.bottomSp1:setOpacity(0)
			self:initBottomSp1()
		end
		if self.bottomSp1 then
			self.bottomSp1:setPosition(ccp(0,0))
			self.bottomSp1:setVisible(true)
		end
		if self.bottomSp2 then
			self.bottomSp2:setPosition(ccp(999333,0))
			self.bottomSp2:setVisible(false)
		end
	elseif(idx==1)then
		if(self.bottomSp2==nil)then
			local function nilFunc()
			end
			self.bottomSp2=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),nilFunc)
			self.bottomSp2:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight - 95-self.baspH-self.tabBtnItemH))
			self.bottomSp2:setAnchorPoint(ccp(0,0))
			self.bgLayer:addChild(self.bottomSp2)
			self.bottomSp2:setOpacity(0)
			self:initBottomSp2()
			self:resetForbidLayer()
		end
		if self.bottomSp1 then
			self.bottomSp1:setPosition(ccp(999333,0))
			self.bottomSp1:setVisible(false)
		end
		if self.bottomSp2 then
			self.bottomSp2:setPosition(ccp(0,0))
			self.bottomSp2:setVisible(true)
			self:refreshTableView()
		end
	end
end

function acPjjnhDialog:checkCost()
	local goldNum1=acPjjnhVoApi:getCostByType(1)
	local goldNum2=acPjjnhVoApi:getCostByType(2)
	local haveCost = playerVoApi:getGems()
	if acPjjnhVoApi:canReward()==true then
		if self.freeItem then
			self.freeItem:setVisible(true)
			self.freeItem:setEnabled(true)
		end
		if self.btnItem1 then
			self.btnItem1:setEnabled(false)
			self.btnItem1:setVisible(false)
		end
	else
		if self.freeItem then
			self.freeItem:setEnabled(false)
			self.freeItem:setVisible(false)
		end
		
		if self.btnItem1 then
			self.btnItem1:setEnabled(true)
			self.btnItem1:setVisible(true)
		end

		if self.costLb1 then
			if goldNum1>haveCost then
				self.costLb1:setColor(G_ColorRed)
			else
				self.costLb1:setColor(G_ColorWhite)
			end
		end
		
	end

	if self.costLb2 then
		if goldNum2<=haveCost then
			self.costLb2:setColor(G_ColorWhite)
		else
			self.costLb2:setColor(G_ColorRed)
		end
	end
	
end

function acPjjnhDialog:tick()
	local acVo = acPjjnhVoApi:getAcVo()
	if acVo ~= nil then
		if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
			if self ~= nil then
				self:close()
			end
		end
	end

	if acPjjnhVoApi:isToday()==false and self.isToday==true then
		self.isToday=false
		acPjjnhVoApi:setF(0)
		self:checkCost()
		acPjjnhVoApi:resertTask()
		if self.bottomSp2 and self.tv then
			self:refreshTableView()
		end		
	end
	self:updateAcTime()
end

function acPjjnhDialog:updateAcTime()
    local acVo=acPjjnhVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acPjjnhDialog:resetForbidLayer()
	local topY
	local topHeight
	local rect=CCSizeMake(640,G_VisibleSize.height)
	if(self.tv~=nil)then
		local tvX,tvY=self.tv:getPosition()
		topY=tvY+self.tv:getViewSize().height
		topHeight=rect.height-topY
	else
		topHeight=0
		topY=0
	end
	self.topforbidSp:setContentSize(CCSize(rect.width,topHeight))
	self.topforbidSp:setPosition(0,topY)
	if(self.tv~=nil)then
		local tvX,tvY=self.tv:getPosition()
		self.bottomforbidSp:setContentSize(CCSizeMake(self.bgSize.width,tvY))
	end
end
function acPjjnhDialog:createParticle(resource,scalex,scaley,pos,Parent,zOrder)
	local circleP = CCParticleSystemQuad:create(resource)
	-- circleP.tCCPositionType = kCCPositionTypeRelative
	circleP:setPositionType(kCCPositionTypeRelative) 
	circleP:setScaleX(scalex)
	circleP:setScaleY(scaley)
	circleP:setPosition(pos)
	Parent:addChild(circleP,zOrder)
	return circleP
end

function acPjjnhDialog:libaoRunAct(libaoSp)
	local time = 0.07
	local rotate1=CCRotateTo:create(time, 20)
	local rotate2=CCRotateTo:create(time, 0)
	local rotate3=CCRotateTo:create(time, -20)
	local rotate4=CCRotateTo:create(time, 0)
	local rotate5=CCRotateTo:create(time, 0)

	local delay=CCDelayTime:create(1)
	local acArr=CCArray:create()
	acArr:addObject(rotate1)
	acArr:addObject(rotate2)
	acArr:addObject(rotate3)
	acArr:addObject(rotate4)
	acArr:addObject(rotate5)
	acArr:addObject(delay)
	local seq=CCSequence:create(acArr)
	local repeatForever=CCRepeatForever:create(seq)
	libaoSp:runAction(repeatForever)
end

function acPjjnhDialog:isAddNeiParticle()
	local acVo=acPjjnhVoApi:getAcVo()
	if acVo and acVo.l and acVo.l==6 then
		local function onShowParticle()
			self.neiParticle=self:createParticle("public/acPjjnh_circleP.plist",1.3,1.3,ccp(self.panSp:getContentSize().width/2,self.panSp:getContentSize().height/2),self.panSp,3)
	    end
	    local callFunc=CCCallFunc:create(onShowParticle)
	    local delay=CCDelayTime:create(0.6)
	    local acArr=CCArray:create()
	    acArr:addObject(delay)
	    acArr:addObject(callFunc)
	    local seq=CCSequence:create(acArr)
	    self.panSp:runAction(seq)

	    self:libaoRunAct(self.libaoSp)
	else
		self.libaoSp:setRotation(0)
		self.libaoSp:stopAllActions()
	end
end

function acPjjnhDialog:dispose()
	self.isShow=nil
	self.activeName=nil
	self.darkSp=nil
    self.brightSp=nil
    self.hLineSp=nil -- 外圈
	self.oLineSp=nil -- 内环
	self.defaultSp=nil
	eventDispatcher:removeEventListener("activity.recharge",self.PjjnhListener)
	spriteController:removePlist("public/acPjjnh.plist")
	spriteController:removeTexture("public/acPjjnh.png")
end