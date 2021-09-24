raidsStorySmallDialog=smallDialog:new()

function raidsStorySmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.dialogHeight=790
	self.dialogWidth=570
	self.sid=nil
	self.index=nil
	self.tankDataTb={{},{},{}}
	self.eUpExp=nil
	self.m_numLb=nil
	self.hasEnergy=nil
	self.hasNumLb=nil
	spriteController:addPlist("public/acNewYearsEva.plist")
	return nc
end

function raidsStorySmallDialog:init(layerNum,sid,index)
	self.eliteUpgradeEnabled = FuncSwitchApi:isEnabled("elite") --是否可以设置精英坦克扫荡
	local offset_h = 0
	if self.eliteUpgradeEnabled == false then
		offset_h = -220
	end
	self.dialogHeight = self.dialogHeight + offset_h
	self.layerNum=layerNum
	self.sid=sid
	self.index=index
	local chepterNum
	local checkPointCfg=checkPointVoApi:getCfgBySid(self.sid)
	if checkPointCfg and checkPointCfg.checkPointList then
		local checkPointList=Split(checkPointCfg.checkPointList,",")
		if checkPointList and checkPointList[self.index] then
			chepterNum=tonumber(checkPointList[self.index])
		end
	end
	if chepterNum==nil then
		do return end
	end
	local chepterCfg=checkPointVoApi:getCfgBySid(chepterNum)
    if chepterCfg==nil then
    	do return end
    end
    local eUpExp=tonumber(chepterCfg.eUpExp)
    self.eUpExp=eUpExp*(1+challengeRaidCfg.addExp)
    print("eUpExp",eUpExp)

    local buyItem
    if challengeRaidCfg and challengeRaidCfg.buyGet and challengeRaidCfg.buyGet[2] then
        local rewardTb=FormatItem(challengeRaidCfg.buyGet[2])
        if rewardTb and rewardTb[1] then
	        buyItem=rewardTb[1]
	    end
	end
	local useItem
	if challengeRaidCfg and challengeRaidCfg.useprop and challengeRaidCfg.useprop[2] then
        local rewardTb=FormatItem(challengeRaidCfg.useprop[2])
        if rewardTb and rewardTb[1] then
	        useItem=rewardTb[1]
	    end
	end

	local function nilFunc()
	end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),nilFunc)
    self.dialogLayer=CCLayer:create()
	self.dialogLayer:setTouchEnabled(true)

	local size=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgSize=size
	self.bgLayer=dialogBg
	self.bgLayer:setContentSize(size)
	self:show()
	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(self.bgLayer,2);
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-2)
	self.dialogLayer:setBSwallowsTouches(true);

	local function close()
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end
	local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
	closeBtnItem:setPosition(0,0)
	closeBtnItem:setAnchorPoint(CCPointMake(0,0))
	self.closeBtn = CCMenu:createWithItem(closeBtnItem)
	self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
	self.closeBtn:setPosition(ccp(size.width-closeBtnItem:getContentSize().width,size.height-closeBtnItem:getContentSize().height))
	dialogBg:addChild(self.closeBtn)


	local midWidth=size.width/2
	local lbPosy=size.height-45
	local lbSize2 = 35
	local titleLb=GetTTFLabelWrap(getlocal("elite_challenge_raid_btn"),lbSize2,CCSizeMake(self.dialogWidth-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	titleLb:setPosition(ccp(midWidth,lbPosy))
	dialogBg:addChild(titleLb,1)
	local titleBg=CCSprite:createWithSpriteFrameName("groupSelf.png")
	titleBg:setPosition(ccp(midWidth+20,lbPosy))
	titleBg:setScaleY(60/titleBg:getContentSize().height)
	titleBg:setScaleX(self.dialogWidth/titleBg:getContentSize().width)
	dialogBg:addChild(titleBg)

	lbPosy=lbPosy-50
	local sp=CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
    -- sp:setScaleY(1)
    sp:setPosition(ccp(midWidth,lbPosy))
    self.bgLayer:addChild(sp)

    lbPosy=lbPosy-40
    local function showInfoHandler()
    	if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
        PlayEffect(audioCfg.mouseClick)
        local tabStr,tabColor={},{}
        if self.eliteUpgradeEnabled == false then
			tabStr={"\n",getlocal("raids_ms_desc_tip2"),"\n",getlocal("raids_ms_desc_tip1"),"\n"}
			tabColor={nil,G_ColorYellowPro,nil,G_ColorYellowPro,nil}
        else
			tabStr={"\n",getlocal("raids_desc_tip5"),"\n",getlocal("raids_desc_tip4"),"\n",getlocal("raids_desc_tip3"),"\n",getlocal("raids_desc_tip2"),"\n",getlocal("raids_desc_tip1"),"\n"}
			tabColor={nil,G_ColorYellowPro,nil,G_ColorYellowPro,nil,G_ColorYellowPro,nil,G_ColorYellowPro,nil,G_ColorYellowPro,nil}
        end
		local td=smallDialog:new()
		local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
		sceneGame:addChild(dialog,self.layerNum+1)
    end
    local scale=0.8
    local infoItem=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfoHandler)
    infoItem:setScale(scale)
    local infoMenu=CCMenu:createWithItem(infoItem)
    infoMenu:setPosition(ccp(self.bgLayer:getContentSize().width-70,lbPosy))
    infoMenu:setTouchPriority(-(layerNum-1)*20-4)
    self.bgLayer:addChild(infoMenu)

    local addExpCfg=challengeRaidCfg.addExp
    local eliteTankExp=(1+addExpCfg)*100
    local lbSize=22
    local leftPosX=25
    local lbWidth=self.bgSize.width-150
    local lbTb={
        {getlocal("raids_getEliteTankExp",{eliteTankExp}),25,ccp(0,0.5),ccp(leftPosX,lbPosy),self.bgLayer,1,G_ColorWhite,CCSize(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
        {getlocal("raids_baseExp"),lbSize,ccp(0,0.5),ccp(leftPosX,lbPosy-40),self.bgLayer,1,G_ColorWhite,CCSize(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
        {getlocal("raids_raidsAdd"),lbSize,ccp(0,0.5),ccp(leftPosX,lbPosy-40-35),self.bgLayer,1,G_ColorWhite,CCSize(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
        -- {getlocal("raids_weekCartAdd"),lbSize,ccp(0,0.5),ccp(leftPosX,lbPosy-40-35*2),self.bgLayer,1,G_ColorWhite,CCSize(self.bgSize.width-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
    }
    for k,v in pairs(lbTb) do
    	local str,strSize,pos=v[1],v[2],v[4]
    	if self.eliteUpgradeEnabled == false then
        	pos.y = pos.y + 40
        end
        local lb=GetAllTTFLabel(str,strSize,v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10],v[11])
        if self.eliteUpgradeEnabled == false and k == 1 then
    		lb:setVisible(false)
    	end
        if k==2 or k==3 then
        	local lbx
	        local tmpLb=GetTTFLabel(str,strSize)
	        if tmpLb:getContentSize().width>lbWidth then
	        	lbx=pos.x+lbWidth+10
	        else
	        	lbx=pos.x+tmpLb:getContentSize().width+10
	        end
	        local addLb
	        if k==2 then
		        addLb=GetTTFLabel("100%",strSize)
		    elseif k==3 then
		    	addLb=GetTTFLabel("+"..(addExpCfg*100).."%",strSize)
		    end
		    addLb:setAnchorPoint(ccp(0,0.5))
	        addLb:setPosition(ccp(lbx,pos.y))
	        addLb:setColor(G_ColorGreen)
	        self.bgLayer:addChild(addLb,1)
        end
    end

    
    local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50, 50, 1, 1),nilFunc)
	backSprie:setContentSize(CCSizeMake(self.bgSize.width-20,420 + offset_h))
    backSprie:ignoreAnchorPointForPosition(false)
    backSprie:setAnchorPoint(ccp(0.5,0))
    -- backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
	backSprie:setPosition(ccp(self.bgSize.width/2,110))
    self.bgLayer:addChild(backSprie)
    if self.eliteUpgradeEnabled == false then
    	backSprie:setPositionY(140)
    end

    local bgWidth=backSprie:getContentSize().width
    local bgHeight=backSprie:getContentSize().height
    local bgPosy=bgHeight-87
    local iSize=120
    for i=1,3 do
    	if self.eliteUpgradeEnabled == false then
    		do break end
    	end
        local needVip=0
        local curVipLv=playerVoApi:getVipLevel()
        local isUnlock=false
        if i>1 then
        	needVip=challengeRaidCfg.vipQueue[i] or 0
        end
        if curVipLv<needVip then
        else
        	isUnlock=true
        end

    	local px,py=bgWidth/2-(2-i)*180,bgPosy
    	local function touchBg(...)
    		if G_checkClickEnable()==false then
				do return end
			else
				base.setWaitTime=G_getCurDeviceMillTime()
			end
	        PlayEffect(audioCfg.mouseClick)
    		
    		if isUnlock==true then
	    		local function callBack(tid,num)
		            -- print("tid,num",tid,num)
		            local idx=i
		            for k=3,1,-1 do
		            	if self.tankDataTb[k] then
			            	if self.tankDataTb[k].tank==nil then
			            		if k<idx then
				            		idx=k
				            	end
			            	end
			            end
		            end
		            if self.tankDataTb[idx] then
			            local tankBg1=tolua.cast(self.tankDataTb[idx].tankBg,"LuaCCScale9Sprite")
			            local lb1=tolua.cast(self.tankDataTb[idx].lb,"CCLabelTTF")
			            local nameLb1=tolua.cast(self.tankDataTb[idx].nameLb,"CCLabelTTF")
			            if tankBg1 then
			            	local tankSp=tankBg1:getChildByTag(idx)
			            	if tankSp then
			            		tankSp:removeFromParentAndCleanup(true)
			            		tankSp=nil
			            	end
				            if tid and num then
					            local tmpItem={o={}}
					            tmpItem.o["a"..tid]=num
					            local awardTb=FormatItem(tmpItem)
					            if awardTb and awardTb[1] then
					            	local item=awardTb[1]
					            	if item.type=="o" then
							            tankSp=tankVoApi:getTankIconSp(item.key)
							            tankSp:setScale(120/tankSp:getContentSize().width)
					            	else
							            tankSp=G_getItemIcon(item,120,false,self.layerNum+1)
					            	end
						            tankSp:setPosition(getCenterPoint(tankBg1))
						            tankSp:setTag(idx)
						            tankBg1:addChild(tankSp,2)
						            self.tankDataTb[idx].tankSp=tankSp
					            	if lb1 then
							        	lb1:setString(num)
							        end
							        if nameLb1 then
							        	local nStr=item.name
							        	-- nStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
							        	nameLb1:setString(nStr)
							        end
							        self.tankDataTb[idx].tank=item

							        self:resetShowTank()
						        end
						    end
						end
					end
		        end
	    		require "luascript/script/game/scene/gamedialog/warDialog/selectTankDialog"
	    		local keyTable,tankTable=tankVoApi:getAllTanksInByType(2)
	    		for k,v in pairs(self.tankDataTb) do
	    			if v and v.tank and SizeOfTable(v.tank)>0 then
	    				local item=v.tank
	    				local tankId=(tonumber(item.key) or tonumber(RemoveFirstChar(item.key)))
	    				for m,n in pairs(keyTable) do
	    					if n and tonumber(n.key)==tankId then
	    						table.remove(keyTable,m)
	    					end
	    				end
	    				for m,n in pairs(tankTable) do
	    					if m==tankId then
	    						table.remove(tankTable,m)
	    					end
	    				end
	    			end
	    		end
	    		local tankData={keyTable,tankTable}
	            selectTankDialog:showSelectTankDialog(3,layerNum+1,callBack,tankData,nil,nil,nil,true)
	        else
	        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("raids_vipUnlock",{needVip}),30)
	        end
    	end
    	local tmpScale=1
    	-- local tankBg=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50, 50, 1, 1),touchBg)
    	-- local tankBg=LuaCCScale9Sprite:createWithSpriteFrameName("frameDeepBg.png",CCRect(20, 20, 5, 5),touchBg)
    	local tankBg=LuaCCSprite:createWithSpriteFrameName("frameDeepBg.png",touchBg)
	    tankBg:setScale(tmpScale)
		-- tankBg:setContentSize(CCSizeMake(iSize,iSize))
	    -- tankBg:ignoreAnchorPointForPosition(false)
	    tankBg:setAnchorPoint(ccp(0.5,0.5))
	    tankBg:setIsSallow(false)
	    tankBg:setTouchPriority(-(self.layerNum-1)*20-4)
		tankBg:setPosition(ccp(px,py))
	    backSprie:addChild(tankBg)
	    self.tankDataTb[i].tankBg=tankBg
	    -- local selectTankBg2=CCSprite:createWithSpriteFrameName("selectTankBg2.png")
	    local selectTankBg2=CCSprite:createWithSpriteFrameName("emptyTankBg.png")
        selectTankBg2:setAnchorPoint(ccp(0.5,0))
        selectTankBg2:setPosition(ccp(tankBg:getContentSize().width/2,tankBg:getContentSize().height/2-25))
        -- selectTankBg2:setScale(1/tmpScale)
        tankBg:addChild(selectTankBg2)
	    local selectTankBg1=CCSprite:createWithSpriteFrameName("selectTankBg1.png")
        selectTankBg1:setPosition(ccp(tankBg:getContentSize().width/2,tankBg:getContentSize().height/2+10))
        selectTankBg1:setScale(0.6/tmpScale)
        tankBg:addChild(selectTankBg1)
        local posSp=CCSprite:createWithSpriteFrameName("tankPos"..i..".png")
        posSp:setPosition(ccp(tankBg:getContentSize().width/2,tankBg:getContentSize().height/2))
        posSp:setScale(0.7/tmpScale)
        tankBg:addChild(posSp)
	    local lockSp=CCSprite:createWithSpriteFrameName("LockIcon.png")
	    lockSp:setScale(0.7/tmpScale)
	    lockSp:setPosition(getCenterPoint(tankBg))
		tankBg:addChild(lockSp)

	    local addBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),touchBg)
        addBg:setContentSize(CCSizeMake(iSize, 30))
        addBg:ignoreAnchorPointForPosition(false)
        addBg:setAnchorPoint(ccp(0.5,1))
        addBg:setIsSallow(false)
        addBg:setTouchPriority(-(self.layerNum-1)*20-4)
        addBg:setPosition(ccp(px,py-iSize/2))
        backSprie:addChild(addBg)
        
        local lbStr="+"
        if isUnlock==true then
        	lockSp:setVisible(false)
        else
        	lbStr=getlocal("raids_vipUnlock",{needVip})
        end
        local lb=GetTTFLabel(lbStr,18)
        lb:setPosition(getCenterPoint(addBg))
		addBg:addChild(lb)
		self.tankDataTb[i].lb=lb
		local nameLb=GetTTFLabelWrap("",22,CCSizeMake(170,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
		nameLb:setAnchorPoint(ccp(0.5,1))
        nameLb:setPosition(ccp(px,py-iSize/2-addBg:getContentSize().height-2))
		backSprie:addChild(nameLb)
		self.tankDataTb[i].nameLb=nameLb
    end

    bgPosy=bgPosy-150-offset_h
    if self.eliteUpgradeEnabled == true then
	    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
		lineSp:setScale(bgWidth/lineSp:getContentSize().width)
		lineSp:setPosition(ccp(bgWidth/2,bgPosy))
		backSprie:addChild(lineSp)	
    end

	bgPosy=bgPosy-35
	local hasEnergy=playerVoApi:getEnergy() or 0
	local needEnergy=challengeRaidCfg.energy or 0
	local hasNum=0
	local needNum=0
	local id
	if useItem and useItem.key then
		needNum=useItem.num or 0
		local pid=useItem.key
		id=(tonumber(pid) or tonumber(RemoveFirstChar(pid)))
		hasNum=bagVoApi:getItemNumId(id)
	end
	local hasEnergyLb,needEnergyLb,hasNumLb,needNumLb
	for i=1,2 do
		local str=""
		local energy=0
		local energyColor=G_ColorWhite
		local pNum=0
		local pNumColor=G_ColorWhite
		if i==1 then
			str=getlocal("propOwned")
			energy=hasEnergy
			pNum=hasNum
			if hasEnergy<needEnergy then
				energyColor=G_ColorRed
			end
			if hasNum<needNum then
				pNumColor=G_ColorRed
			end
		else
			str=getlocal("raids_cost")
			energy=needEnergy
			pNum=needNum
		end
		-- str="啊啊啊啊啊啊啊啊啊"
		local px=10
		local lb=GetTTFLabelWrap(str,25,CCSizeMake(125,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		lb:setAnchorPoint(ccp(0,0.5))
		lb:setPosition(ccp(px,bgPosy))
		backSprie:addChild(lb,1)
		px=px+150
		local energyIconSp=CCSprite:createWithSpriteFrameName("energyIcon.png")
	    energyIconSp:setPosition(ccp(px,bgPosy))
	    backSprie:addChild(energyIconSp,1)
	    px=px+50
	    local energyLb=GetTTFLabel(energy,25)
	    energyLb:setPosition(ccp(px,bgPosy))
	    backSprie:addChild(energyLb,1)
	    energyLb:setColor(energyColor)
	    if i==1 then
		    px=px+60
		    local function addEnergy( ... )
		    	if G_checkClickEnable()==false then
					do return end
				else
					base.setWaitTime=G_getCurDeviceMillTime()
				end
		        PlayEffect(audioCfg.mouseClick)

		    	self:buyEnergy()
		    end
		    local addSp=LuaCCSprite:createWithSpriteFrameName("moreBtn.png",addEnergy)
			addSp:setPosition(ccp(px,bgPosy))
			addSp:setTouchPriority(-(self.layerNum-1)*20-4)
			backSprie:addChild(addSp,1)
			addSp:setScale(0.8)
			hasEnergyLb=energyLb
			self.hasEnergy=hasEnergyLb
		else
			needEnergyLb=energyLb
		end
	    px=backSprie:getContentSize().width-150
	    local raidsCardSp=CCSprite:createWithSpriteFrameName("raidsCardSmall.png")
	    raidsCardSp:setPosition(ccp(px,bgPosy))
	    backSprie:addChild(raidsCardSp,1)
	    raidsCardSp:setScale(1.2)
	    px=px+50
	    local pNumLb=GetTTFLabel(pNum,25)
	    pNumLb:setPosition(ccp(px,bgPosy))
	    backSprie:addChild(pNumLb,1)
	    pNumLb:setColor(pNumColor)
	    if i==1 then
		    px=px+60
		    local function addPropNum( ... )
		    	if G_checkClickEnable()==false then
					do return end
				else
					base.setWaitTime=G_getCurDeviceMillTime()
				end
		        PlayEffect(audioCfg.mouseClick)

		        self:buyProps()
		    end
		    local addSp=LuaCCSprite:createWithSpriteFrameName("moreBtn.png",addPropNum)
			addSp:setPosition(ccp(px,bgPosy))
			addSp:setTouchPriority(-(self.layerNum-1)*20-4)
			backSprie:addChild(addSp,1)
			addSp:setScale(0.8)
			hasNumLb=pNumLb
			self.hasNumLb=hasNumLb
		else
			needNumLb=pNumLb
		end

		bgPosy=bgPosy-50
	end

	local sPosx=10
	local numStr=getlocal("raids_raidsNum")
	-- numStr="啊啊啊啊啊啊啊啊啊"
	local propLb=GetTTFLabelWrap(numStr,25,CCSizeMake(125,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	propLb:setAnchorPoint(ccp(0,0.5))
	propLb:setPosition(ccp(sPosx,bgPosy))
	backSprie:addChild(propLb,1)

	--拖动条
	local raidsNum=math.min(hasEnergy,hasNum)
	if raidsNum>challengeRaidCfg.limitNum then
		raidsNum=challengeRaidCfg.limitNum
	end
	sPosx=sPosx+120
	local sScale=0.7
	local bgSp = CCSprite:createWithSpriteFrameName("TeamProduceTank_Bg.png")
    bgSp:setAnchorPoint(ccp(0,0.5))
    bgSp:setScaleX(sScale)
    bgSp:setPosition(ccp(sPosx,bgPosy))
    backSprie:addChild(bgSp,1)

    sPosx=sPosx+65*sScale
	local m_numLb=GetTTFLabel(" ",30)
	m_numLb:setPosition(ccp(sPosx,bgPosy))
	backSprie:addChild(m_numLb,1)
	self.m_numLb=m_numLb

	local function sliderTouch(handler,object)
		local count = math.floor(object:getValue())
		m_numLb:setString(count)
		needEnergyLb:setString(count)
		needNumLb:setString(count)
		
		local hasEnergy=playerVoApi:getEnergy() or 0
		local hasNum=0
		if id then
			hasNum=bagVoApi:getItemNumId(id)
		end
		local raidsNum=math.min(hasEnergy,hasNum)
		if raidsNum>challengeRaidCfg.limitNum then
			raidsNum=challengeRaidCfg.limitNum
		end
		if count>raidsNum then
			m_numLb:setColor(G_ColorRed)
		else
			m_numLb:setColor(G_ColorWhite)
		end
		if count>hasEnergy then
			hasEnergyLb:setColor(G_ColorRed)
		else
			hasEnergyLb:setColor(G_ColorWhite)
		end
		if count>hasNum then
			hasNumLb:setColor(G_ColorRed)
		else
			hasNumLb:setColor(G_ColorWhite)
		end
		self:resetShowTank()
	end
	local spBg =CCSprite:createWithSpriteFrameName("ProduceTankSlideBg.png");
	local spPr =CCSprite:createWithSpriteFrameName("ProduceTankSlideBar.png");
	local spPr1 =CCSprite:createWithSpriteFrameName("ProduceTankIconSlide.png");
	local slider = LuaCCControlSlider:create(spBg,spPr,spPr1,sliderTouch);
	slider:setTouchPriority(-(self.layerNum-1)*20-4)
	slider:setIsSallow(true);
	slider:setMinimumValue(1.0);
	local maxNum=challengeRaidCfg.limitNum
	maxNum=G_keepNumber(maxNum,1)
	slider:setMaximumValue(maxNum);
	if raidsNum<=0 then
		m_numLb:setColor(G_ColorRed)
		raidsNum=1
	end
	slider:setValue(raidsNum);
	slider:setTag(99)
	slider:setScaleX(0.6)
	backSprie:addChild(slider,1)
	m_numLb:setString(math.floor(slider:getValue()))

	local function touchAdd()
		local num=math.floor(slider:getValue())+1
		if num<=challengeRaidCfg.limitNum then
			slider:setValue(num)
			needEnergyLb:setString(num)
			needNumLb:setString(num)
		end
	end
	local function touchMinus()
		local num=math.floor(slider:getValue())-1
		if num>0 then
			slider:setValue(num)
			needEnergyLb:setString(num)
			needNumLb:setString(num)
		end
	end
	sPosx=sPosx+105*sScale
	local minusSp=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconLess.png",touchMinus)
	minusSp:setPosition(ccp(sPosx,bgPosy))
	backSprie:addChild(minusSp,1)
	minusSp:setTouchPriority(-(self.layerNum-1)*20-4);
	sPosx=sPosx+180*sScale
	slider:setPosition(ccp(sPosx,bgPosy))
	sPosx=sPosx+180*sScale
	local addSp=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconMore.png",touchAdd)
	addSp:setPosition(ccp(sPosx,bgPosy))
	backSprie:addChild(addSp,1)
	addSp:setTouchPriority(-(self.layerNum-1)*20-4);
	self.slider=slider
	

	--推荐
    local function recommendHandler(tag,object)
    	if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
        PlayEffect(audioCfg.mouseClick)

        --keyTable={{"key":60155},{"key":50001},{"key":20155},{"key":10003},{"key":10012},{"key":10002},{"key":10001}}
        --tankTable={10012={8},10002={111111},}
        local index=1
        local recommendTb={{},{},{}}
        local tmpIndex=1
        local tmpRecommendTb={{},{},{}}
        local keyTable,tankTable=tankVoApi:getAllTanksInByType(2)
        for k,v in pairs(keyTable) do
        	if v and v.key then
        		local tankId=v.key
        		if tankCfg[tankId].isElite==1 then
        		else
			        local needExp=tonumber(tankCfg[tankId].eUpExp)
			        local upNum=math.floor(eUpExp/needExp)
        			local num=tankTable[tankId][1]
        			if num>upNum then
	        			recommendTb[index]={tankId,num,upNum}
	        			index=index+1
	        		else
	        			tmpRecommendTb[tmpIndex]={tankId,num,num}
	        			tmpIndex=tmpIndex+1
	        		end
        		end
        	end
        end
        local tmpIdx=1
        for k,v in pairs(recommendTb) do
        	if v and SizeOfTable(v)==0 then
        		recommendTb[k]=tmpRecommendTb[tmpIdx]
        		tmpIdx=tmpIdx+1
        	end
        end

        for k,v in pairs(recommendTb) do
        	if v and SizeOfTable(v)>0 then
        		local idx=k
        		local needVip=0
		        local curVipLv=playerVoApi:getVipLevel()
		        local isUnlock=false
		        if idx>1 then
		        	needVip=challengeRaidCfg.vipQueue[idx] or 0
		        end
		        if curVipLv>=needVip then
		        	local id=v[1]
		        	local num=v[2]
		        	local upNum=v[3]
		        	if self.tankDataTb[idx] then
			            local tankBg1=tolua.cast(self.tankDataTb[idx].tankBg,"LuaCCScale9Sprite")
			            local lb1=tolua.cast(self.tankDataTb[idx].lb,"CCLabelTTF")
			            local nameLb1=tolua.cast(self.tankDataTb[idx].nameLb,"CCLabelTTF")
			            if tankBg1 then
			            	local tankSp=tankBg1:getChildByTag(idx)
			            	if tankSp then
			            		tankSp:removeFromParentAndCleanup(true)
			            		tankSp=nil
			            	end
				            if id and num then
					            local tmpItem={o={}}
					            tmpItem.o["a"..id]=num
					            local awardTb=FormatItem(tmpItem)
					            if awardTb and awardTb[1] then
					            	local item=awardTb[1]
					            	if item.type=="o" then
	            			            tankSp=tankVoApi:getTankIconSp(item.key)
							            tankSp:setScale(120/tankSp:getContentSize().width)
					            	else
							            tankSp=G_getItemIcon(item,120,false,self.layerNum+1)
					            	end
						            tankSp:setPosition(getCenterPoint(tankBg1))
						            tankSp:setTag(idx)
						            tankBg1:addChild(tankSp,2)
						            self.tankDataTb[idx].tankSp=tankSp
					            	if lb1 then
							        	lb1:setString(num)
							        end
							        if nameLb1 then
							        	nameLb1:setString(item.name)
							        end
							        self.tankDataTb[idx].tank=item
							        
							        self:resetShowTank()
						        end
						    end
						end
					end
				end
	        end
        end
    end
    local recommendItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",recommendHandler,2,getlocal("best"),25)
    local recommendMenu=CCMenu:createWithItem(recommendItem)
    recommendMenu:setPosition(ccp(self.dialogWidth/2-140,60))
    recommendMenu:setTouchPriority(-(layerNum-1)*20-4)
    self.bgLayer:addChild(recommendMenu)

    --扫荡
    local function raidsHandler()
    	if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
        PlayEffect(audioCfg.mouseClick)

        local num=math.floor(self.slider:getValue())
        local hasEnergy=playerVoApi:getEnergy() or 0
		local hasNum=0
		if id then
			hasNum=bagVoApi:getItemNumId(id)
		end
        if hasEnergy<num or hasNum<num then
        	if hasEnergy<num then
        		self:buyEnergy(true)
				do return end
			end
			if hasNum<num then
				self:buyProps(true)
				do return end
			end
		end

	    local function raidCallback(fn,data)
			local ret,sData=base:checkServerData(data)
			if(ret==true)then
				if sData.data and sData.data.report then
			        local report=sData.data.report
			        local acreward=sData.data.acreward
			        local content={}
			        if report and SizeOfTable(report)>0 and acreward and SizeOfTable(acreward)>0 then
			        	for k,v in pairs(acreward) do
			        		report[SizeOfTable(report)][k]=v
			        	end
			        end
			        for k,v in pairs(report) do
			        	local rewardTb=FormatItem(v)
			        	table.insert(content,{award=rewardTb})
			        end
			        local upgradeTanks
			        if sData.data.reward and sData.data.reward.o then
				        upgradeTanks=sData.data.reward.o
				    end
			        checkPointVoApi:showRewardSmallDialog("TankInforPanel.png",CCSizeMake(550,700),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("raids_raids_result"),content,nil,nil,self.layerNum+1,nil,true,upgradeTanks)
				end
      			
				if id then
					local hasNum=bagVoApi:getItemNumId(id)
					hasNumLb:setString(hasNum)
					if hasNum<needNum then
						hasNumLb:setColor(G_ColorRed)
					end
					-- playerVoApi:setEnergy(playerVoApi:getEnergy()-needEnergy)
					local hasEnergy=playerVoApi:getEnergy()
					hasEnergyLb:setString(hasEnergy)
					if hasEnergy<needEnergy then
						hasEnergyLb:setColor(G_ColorRed)
					end
				end
				self:close()
			end
		end
		if chepterNum and self.tankDataTb then
		    local defender=chepterNum-10000
		    local isHasSelect=false
		    local tanks={}
		    local totalNeedExp=0
		    for k,v in pairs(self.tankDataTb) do
		    	if v and v.tank and v.tank.key and v.tank.num then
		    		isHasSelect=true
		    		local item=v.tank
		    		if item then
		    			local tid=(tonumber(item.key) or tonumber(RemoveFirstChar(item.key)))
						local needExp=tonumber(tankCfg[tid].eUpExp) or 0
		    			totalNeedExp=totalNeedExp+item.num*needExp
		    			if v.upNum and v.upNum>0 then
				    		local itemData={item.key,v.upNum}
				    		tanks[k]=itemData
				    	end
			    	end
		    	end
		    end
		    local function onConfirm( ... )
				if num>0 then
				    socketHelper:challengeRaid(defender,tanks,num,raidCallback)
				end
			end
			if self.eliteUpgradeEnabled == true then
				if isHasSelect==false then
					smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("raids_not_set_troops"),nil,self.layerNum+1)
				else
					-- print("self.eUpExp,totalNeedExp",self.eUpExp,totalNeedExp)
					if self.eUpExp<totalNeedExp then
						onConfirm()
					else
						smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("raids_upgrade_overflow"),nil,self.layerNum+1)
					end
				end
			else
				onConfirm()
			end
		end
    end
    local raidsItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",raidsHandler,2,getlocal("elite_challenge_raid_btn"),25)
    local raidsMenu=CCMenu:createWithItem(raidsItem)
    raidsMenu:setPosition(ccp(self.dialogWidth/2+140,60))
    raidsMenu:setTouchPriority(-(layerNum-1)*20-4)
    self.bgLayer:addChild(raidsMenu)

  	if self.eliteUpgradeEnabled == false then
    	recommendItem:setEnabled(false)
    	recommendMenu:setVisible(false)
    	recommendMenu:setPosition(9999,9999)
    	raidsMenu:setPositionX(self.dialogWidth/2)
    end

	--遮罩层
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc);
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(touchDialogBg,1);

	sceneGame:addChild(self.dialogLayer,layerNum)
	self.dialogLayer:setPosition(ccp(0,0))
end

function raidsStorySmallDialog:buyEnergy(isNotEnough)
	local function buySuccess()
		if self.slider then
			local energy=playerVoApi:getEnergy()
			local count=math.floor(self.slider:getValue())
			if self.hasEnergy then
				self.hasEnergy:setString(energy)
				if energy>=count then
					self.hasEnergy:setColor(G_ColorWhite)
				end
			end
			local useItem
			if challengeRaidCfg and challengeRaidCfg.useprop and challengeRaidCfg.useprop[2] then
		        local rewardTb=FormatItem(challengeRaidCfg.useprop[2])
		        if rewardTb and rewardTb[1] then
			        useItem=rewardTb[1]
			    end
			end
			local id
			if useItem and useItem.key then
				local pid=useItem.key
				id=(tonumber(pid) or tonumber(RemoveFirstChar(pid)))
			end
			if self.m_numLb and id then
				local hasNum1=bagVoApi:getItemNumId(id)
				local raidsNum1=math.min(energy,hasNum1)
				if raidsNum1>challengeRaidCfg.limitNum then
					raidsNum1=challengeRaidCfg.limitNum
				end
				if count>raidsNum1 then
					self.m_numLb:setColor(G_ColorRed)
				else
					self.m_numLb:setColor(G_ColorWhite)
				end
			end
		end
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("energySupplySuccess"),30)
    end
    -- G_buyEnergy(self.layerNum+1,isNotEnough,buySuccess)
    smallDialog:showEnergySupplementDialog(self.layerNum+1, buySuccess)
end
function raidsStorySmallDialog:buyProps(isNotEnough)
	local buyItem
    if challengeRaidCfg and challengeRaidCfg.buyGet and challengeRaidCfg.buyGet[2] then
        local rewardTb=FormatItem(challengeRaidCfg.buyGet[2])
        if rewardTb and rewardTb[1] then
	        buyItem=rewardTb[1]
	    end
	end
	if buyItem and buyItem.key and buyItem.num then
		local pid=buyItem.key
		local id=(tonumber(pid) or tonumber(RemoveFirstChar(pid)))
		local curVipLv=playerVoApi:getVipLevel()
		local buyNum=checkPointVoApi:getBuyRaidsPropNum(pid)
		local canBuyNum=challengeRaidCfg.vipBuyNums[curVipLv+1]
		if buyNum>=canBuyNum then
			local tabStr={"\n",getlocal("raids_can_not_buy2"),"\n",getlocal("raids_can_not_buy"),"\n"}
	        local tabColor={nil,G_ColorYellow,nil,nil,nil}
	        local sizeTab={25,25,25,25,25}
	        smallDialog:showTableViewSureWithColorTb("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),tabStr,tabColor,true,self.layerNum+1,nil,sizeTab,nil,kCCTextAlignmentCenter)
			do return end
		end
		local cost=checkPointVoApi:buyCost(pid)
		if cost and cost>=0 then
			if playerVoApi:getGems()>=cost then
	    		local function onConfirm( ... )
	    			local function buyCallback(fn,data)
		    			local ret,sData=base:checkServerData(data)
						if(ret==true)then
							if id and self.slider then
								local hasNum=bagVoApi:getItemNumId(id)
								local count=math.floor(self.slider:getValue())
								if self.hasNumLb then
									self.hasNumLb:setString(hasNum)
									if hasNum>=count then
										self.hasNumLb:setColor(G_ColorWhite)
									end
								end
								if self.m_numLb then
									local energy1=playerVoApi:getEnergy()
					    			local raidsNum1=math.min(energy1,hasNum)
									if raidsNum1>challengeRaidCfg.limitNum then
										raidsNum1=challengeRaidCfg.limitNum
									end
									if count>raidsNum1 then
										self.m_numLb:setColor(G_ColorRed)
									else
										self.m_numLb:setColor(G_ColorWhite)
									end
					    		end
							end
							playerVoApi:setGems(playerVoApi:getGems()-cost)
							smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("vip_tequanlibao_goumai_success"),30)
						end
		    		end
			    	socketHelper:challengeBuy(cost,buyCallback)
	    		end
		    	local buyDesc
		    	if isNotEnough==true then
		    		buyDesc=getlocal("raids_can_not_raids",{getlocal("sample_prop_name_3326"),getlocal("raids_buy_desc",{cost,buyItem.name.."*"..buyItem.num})})
		    	else
		    		buyDesc=getlocal("raids_buy_desc",{cost,buyItem.name.."*"..buyItem.num})
		    	end
			    smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),buyDesc,nil,self.layerNum+1)
			else
				GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost)
			end
	    end
	end
end

function raidsStorySmallDialog:resetShowTank()
	if self.eliteUpgradeEnabled == false then
		do return end
	end
	if self.eUpExp and self.tankDataTb and self.slider
	 then
	 	local isUpZero=false
		local count=math.floor(self.slider:getValue())
		local eUpExp=self.eUpExp*count
		for k,v in pairs(self.tankDataTb) do
			if v and v.tank then
				local item=v.tank
				local tid=(tonumber(item.key) or tonumber(RemoveFirstChar(item.key)))
				local needExp=tonumber(tankCfg[tid].eUpExp)
		        local canUpNum=math.floor(eUpExp/needExp)
		        local upNum=canUpNum
				if item.num<upNum then
					upNum=item.num
				end
				if isUpZero==true then
					upNum=0
				end
				self.tankDataTb[k].upNum=upNum
				local tankSp=tolua.cast(self.tankDataTb[k].tankSp,"LuaCCSprite")
				if tankSp then
					local upNumLb=tolua.cast(tankSp:getChildByTag(k),"CCLabelTTF")
					if upNumLb then
						upNumLb:setString(upNum)
					else
						local capInSet = CCRect(15, 15, 1, 1);
					    local function touchClick(hd,fn,idx)
					    end
					    local numSprie =LuaCCScale9Sprite:createWithSpriteFrameName("TeamTankNumBgSelected.png",capInSet,touchClick)
					    numSprie:setContentSize(CCSizeMake(100,36))
						numSprie:ignoreAnchorPointForPosition(false);
						numSprie:setAnchorPoint(ccp(0.5,0))
						numSprie:setPosition(ccp(tankSp:getContentSize().width/2,5));
						tankSp:addChild(numSprie,1)
		        		local upNumLb=GetTTFLabel(upNum,25)
		        		upNumLb:setPosition(ccp(tankSp:getContentSize().width/2,5+numSprie:getContentSize().height/2))
		        		upNumLb:setTag(k)
			            tankSp:addChild(upNumLb,2)
			        end
			    end
				eUpExp=eUpExp-(needExp*upNum)
				if item.num>canUpNum then
					isUpZero=true
				end
			end
		end
	end
end

function raidsStorySmallDialog:dispose()
	self.sid=nil
	self.index=nil
	self.tankDataTb={{},{},{}}
	self.eUpExp=nil
	self.m_numLb=nil
	self.hasEnergy=nil
	self.hasNumLb=nil
	self.eliteUpgradeEnabled = nil
	spriteController:removePlist("public/acNewYearsEva.plist")
end
