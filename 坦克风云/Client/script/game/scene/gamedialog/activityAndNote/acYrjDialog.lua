acYrjDialog=commonDialog:new()

function acYrjDialog:new(layerNum)
	local nc={
        detailCfg = {-17,14,-58,55,21}
	}
	setmetatable(nc,self)
	self.__index=self
	self.layerNum=layerNum

	self.layerTab1=nil
	self.layerTab2=nil
	self.tab1=nil
	self.tab2=nil

	self.awardBoxBgTb = nil
	self.actionBgTb2 = {}
	self.rewardList = {}
	self.sAwardTb = {}
	self.gCover1Tb = {}
	self.gCover2Tb = {}
	self.sIconTb = {}
	self.awardLastPos = {}
	self.aNameTb = {}
	self.notEnd = true
	self.xScale = {0.2,0.5,0.8,0.3,0.7}
	self.yScale = {0.6,0.6,0.6,0.35,0.35}
	return nc
end

function acYrjDialog:resetTab()
	--acYrjImage
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)

    spriteController:addPlist("public/activePicUseInNewGuid.plist")
    spriteController:addPlist("public/yrjV2.plist")
    spriteController:addTexture("public/activePicUseInNewGuid.png")
    spriteController:addTexture("public/yrjV2.png")
    spriteController:addPlist("public/taskYouhua.plist")
    spriteController:addTexture("public/taskYouhua.png")
    spriteController:addPlist("public/mergedShopIconImage.plist")
    spriteController:addTexture("public/mergedShopIconImage.png")
    -- spriteController:addPlist("public/acYrjImage.plist")
    -- spriteController:addTexture("public/acYrjImage.png")--"public/plane/planeNewSkill.plist",
    --"public/plane/planeNewSkill.plist",
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

	local index=0
	for k,v in pairs(self.allTabs) do
		 local  tabBtnItem=v

		 if index==0 then
			tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
		 else
			tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
		 end
		 if index==self.selectedTabIndex then
			 tabBtnItem:setEnabled(false)
		 end
		 index=index+1
	end

	self.panelLineBg:setVisible(false)
	local topBorder=CCSprite:createWithSpriteFrameName("newTopBorder.png")
	topBorder:setScaleX(G_VisibleSizeWidth/topBorder:getContentSize().width)
	topBorder:setAnchorPoint(ccp(0,1))
	topBorder:setPosition(0,G_VisibleSizeHeight - 158)
	self.bgLayer:addChild(topBorder)

	self:tabClick(0)
end

function acYrjDialog:initTableView()

end

function acYrjDialog:tabClick(idx)
	for k,v in pairs(self.allTabs) do
		if v:getTag()==idx then
			v:setEnabled(false)
			self.selectedTabIndex=idx
		else
			v:setEnabled(true)
		end
	end
	self:switchTab(idx+1)
end

function acYrjDialog:switchTab(type)
	if type==nil then
		type=1
	end
	self.useTipSp =  tolua.cast(self.allTabs[2]:getChildByTag(101),"CCSprite")
	if not self.touchDia then
        local function touchCall()
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            self.touchDia:setPositionX(G_VisibleSizeWidth * 10)
            if self.notEnd then
            	self.notEnd = false
	            self:stopAwardAction()
	        end
            -- self:showBlackAction(self.newRewardList,true,true)
        end
        self.tDialogHeight = 80
        self.touchDia = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchCall);
        self.touchDia:setTouchPriority(-(self.layerNum-1)*20-11)
        self.touchDia:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
        self.touchDia:setOpacity(0)
        self.touchDia:setIsSallow(true) -- 点击事件透下去
        self.touchDia:setPosition(ccp(G_VisibleSizeWidth*2.5,G_VisibleSizeHeight * 0.5))
        self.bgLayer:addChild(self.touchDia,99)
    end
    for i=1,3 do
        if not self.actionBgTb2[i] then
            local actionBlackBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(5, 5, 1, 1),function () end)
            actionBlackBg:setOpacity(i == 3 and 0 or 255)
            actionBlackBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
            actionBlackBg:setPosition(ccp(G_VisibleSizeWidth * 10,G_VisibleSizeHeight * 0.5))
            actionBlackBg:setTouchPriority(-(self.layerNum-1)*20-5)
            actionBlackBg:setIsSallow(true)
            self.bgLayer:addChild(actionBlackBg,90)    
            self.actionBgTb2[i] = actionBlackBg
        end
    end
    if not self.titleStr then
    	local titleStrVersion = "activity_yrj_title"
    	if acYrjVoApi:getVersion() == 2 then
    		titleStrVersion = "activity_yrjV2_title"
    	end
    	local titleStr = GetTTFLabelWrap(getlocal(titleStrVersion),30,CCSizeMake(G_VisibleSizeWidth - 20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop,"Helvetica-bold")
    	titleStr:setAnchorPoint(ccp(0.5,1))
    	titleStr:setPosition(ccp(G_VisibleSizeWidth * 0.5, G_VisibleSizeHeight - 40))
    	self.actionBgTb2[3]:addChild(titleStr)
    	self.titleStr = titleStr
    end
    if not self.awardBoxBgTb then
	    self:initAwardBox(self.actionBgTb2[3])
	end

	if not self.actionCloseMenu then
        local function closeHandle( )
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            self:endActionLayer()
        end 
        local btnScale=0.8
        local closeBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",closeHandle,11,getlocal("fight_close"),24/btnScale)
        closeBtn:setScale(btnScale)
        closeBtn:setAnchorPoint(ccp(0.5,0))
        local menu=CCMenu:createWithItem(closeBtn)
        menu:setTouchPriority(-(self.layerNum-1)*20-10)
        menu:setPosition(ccp(G_VisibleSizeWidth * 0.3, 100))
        self.actionCloseMenu = menu
        self.bgLayer:addChild(menu,99) 
        self.actionCloseMenu:setVisible(false)
    end
    if not self.mulBtn then
    	local cost1,cost2=acYrjVoApi:getLotteryCost()
    	local function multiLotteryHandler()
    		if self.tab1.lotteryHandler then
	            self:endActionLayer(true)
		        self.tab1:lotteryHandler(true,true)
		    end
	    end
	    local num=acYrjVoApi:getMultiNum()
	    self.mulBtn=self:getLotteryBtn(num,ccp(G_VisibleSizeWidth * 0.7 ,100),multiLotteryHandler,cost2,true)
	    self.mulBtn:setVisible(false)
	end
	local function showTab( )
		if self["tab"..type]==nil then
	   		local tab
	   		if(type==1)then
	   			tab=acYrjTabOne:new(self)
	   		else
	   			tab=acYrjTabTwo:new(self)
	   		end
		   	self["tab"..type]=tab
		   	self["layerTab"..type]=tab:init(self.layerNum)
		   	self.bgLayer:addChild(self["layerTab"..type])
	   	end
		for i=1,2 do
			if(i==type)then
				if(self["layerTab"..i]~=nil)then
					self["layerTab"..i]:setPosition(ccp(0,0))
					self["layerTab"..i]:setVisible(true)
				end
			else
				if(self["layerTab"..i]~=nil)then
					self["layerTab"..i]:setPosition(ccp(999333,0))
					self["layerTab"..i]:setVisible(false)
				end
			end
		end
	end 

	if type== 2 then
		self:refresh(2)
	end
	-- else
		showTab()
	-- end
end

function acYrjDialog:getLotteryBtn(num,pos,callback,cost,isMul)
    local btnZorder,btnFontSize=2,25
    local function lotteryHandler()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if callback then
            callback()
        end
    end
    local lotteryBtn
    local btnScale=0.8
    
    if cost and tonumber(cost)>0 then
        local btnStr=getlocal("activity_qxtw_buy",{num})
        lotteryBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",lotteryHandler,nil,btnStr,btnFontSize/btnScale,11)
        local costLb=GetTTFLabel(tostring(cost),25)
        costLb:setAnchorPoint(ccp(0,0.5))
        lotteryBtn:setAnchorPoint(ccp(0.5,0))
        costLb:setColor(G_ColorYellowPro)
        costLb:setScale(1/btnScale)
        lotteryBtn:addChild(costLb)
        local costSp=CCSprite:createWithSpriteFrameName("IconGold.png")
        costSp:setAnchorPoint(ccp(0,0.5))
        costSp:setScale(1/btnScale)
        lotteryBtn:addChild(costSp)
        local lbWidth=costLb:getContentSize().width+costSp:getContentSize().width+10
        costLb:setPosition(lotteryBtn:getContentSize().width/2-lbWidth/2,lotteryBtn:getContentSize().height+costLb:getContentSize().height/2+10)
        costSp:setPosition(costLb:getPositionX()+costLb:getContentSize().width+10,costLb:getPositionY())
    end

    lotteryBtn:setScale(btnScale)
    local lotteryMenu=CCMenu:createWithItem(lotteryBtn)
    lotteryMenu:setTouchPriority(-(self.layerNum-1)*20-10)
    lotteryMenu:setPosition(pos)
    self.bgLayer:addChild(lotteryMenu,99)

    return lotteryBtn
end

function acYrjDialog:refresh( tab )
	if tab ==2 then
        if self.tab2 and self.tab2.refresh then
            self.tab2:refresh()
        end
    end
end
function acYrjDialog:doUserHandler()

end

function acYrjDialog:tick()
	local acVo = acYrjVoApi:getAcVo()
    if activityVoApi:isStart(acVo)==true then
		if self and self.tab1 and self.tab1.tick then
			self.tab1:tick()
		end
		
        
		if acYrjVoApi:CanExrechargeBigAward( ) then
			self.useTipSp:setVisible(true)	
		else
			self.useTipSp:setVisible(false)	
	    end
	else
		self:close()
	end

	
end

function acYrjDialog:dispose()
	if self.tab1 and self.tab1.dispose then
		self.tab1:dispose()
	end
	if self.tab2 and self.tab2.dispose then

	end
    self.layerTab1=nil
	self.layerTab2=nil
	self.tab1=nil
	self.tab2=nil

	self.rewardList = nil
	self.sIconTb = nil
	self.awardLastPos = nil
	spriteController:removePlist("public/mergedShopIconImage.plist")
	spriteController:removePlist("public/yrjV2.plist")
    spriteController:removeTexture("public/mergedShopIconImage.png")
    spriteController:removeTexture("public/yrjV2.png")
    spriteController:removePlist("public/activePicUseInNewGuid.plist")
	spriteController:removeTexture("public/activePicUseInNewGuid.png")
	spriteController:removePlist("public/taskYouhua.plist")
    spriteController:removeTexture("public/taskYouhua.png")
    -- spriteController:removePlist("public/acYrjImage.plist")
    -- spriteController:removeTexture("public/acYrjImage.png")
end

function acYrjDialog:initAwardBox(prSp )
	self.awardBoxBgTb = {}
	self.sNameLb = {}
	for i=1,5 do
		
		local gBox1 = CCSprite:createWithSpriteFrameName("greenBoxBorder2.png")
	    gBox1:setPosition(ccp(G_VisibleSizeWidth * self.xScale[i], G_VisibleSizeHeight * self.yScale[i] ))
	    gBox1:setScale(0.55)
	    prSp:addChild(gBox1)
	    self.awardBoxBgTb[i] = gBox1

	    local gBox2 = CCSprite:createWithSpriteFrameName("greenBoxBorder1.png")
	    gBox2:setPosition(getCenterPoint(gBox1))
	    gBox1:addChild(gBox2,2)

	    local sAward = CCSprite:createWithSpriteFrameName("clown.png")
	    if not self.sOldPos then
		    self.sOldPos = ccp(gBox1:getContentSize().width * 0.5,gBox1:getContentSize().height * 0.7)
		end
		if not self.sOldScale then
		    self.sOldScale = (gBox1:getContentSize().width -40)/sAward:getContentSize().height
		end
	    sAward:setPosition(self.sOldPos)
	    sAward:setScale(self.sOldScale)
	    self.sAwardTb[i] = sAward
	    gBox1:addChild(sAward,1)

	    local nameLb=GetTTFLabel(acYrjVoApi:getSpecialProp(),35,"Helvetica-bold")
        nameLb:setAnchorPoint(ccp(0.5,1))
        nameLb:setColor(G_ColorYellowPro)
        nameLb:setPosition(ccp(gBox1:getContentSize().width * 0.5, -5))
        gBox1:addChild(nameLb)
        self.sNameLb[i] = nameLb
        self.sNameLb[i]:setVisible(false)

	    local gCover1 = CCSprite:createWithSpriteFrameName("greenCover1.png")
	    gCover1:setPosition(ccp(gBox1:getContentSize().width * 0.5 + 10,gBox1:getContentSize().height - 10))
	    gBox1:addChild(gCover1,2)
	    self.gCover1Tb[i] = gCover1

	    local gCover2 = CCSprite:createWithSpriteFrameName("greenCover2.png")
	    gCover2:setAnchorPoint(ccp(0,.5))
	    gCover2:setPosition(ccp(gBox1:getContentSize().width - 25,gBox1:getContentSize().height - 40))
	    gBox1:addChild(gCover2,5)
	    self.gCover2Tb[i] = gCover2

	    self.sAwardTb[i]:setVisible(false)
	    self.gCover2Tb[i]:setVisible(false)

	    self.awardBoxBgTb[i]:setVisible(false)
	end
end


function acYrjDialog:stopAwardAction()
	self.actionCloseMenu:setVisible(true)
	self.mulBtn:setVisible(true)
	self.bgLayer:stopAllActions()
	for i=1,3 do
		self.actionBgTb2[i]:setPosition(getCenterPoint(self.bgLayer))
		self.actionBgTb2[i]:setVisible(true)
    end
    if not self.hexieLb then
        local hexieLb = GetTTFLabel(getlocal("equip_getReward",{self.rewardList[1].name.."x"..self.rewardList[1].num}),25,"Helvetica-bold")
        hexieLb:setAnchorPoint(ccp(0.5,1))
        hexieLb:setColor(G_ColorYellowPro)
        hexieLb:setPosition(ccp(G_VisibleSizeWidth * 0.5,G_VisibleSizeHeight - 180))
        self.bgLayer:addChild(hexieLb,99)
        self.hexieLb= hexieLb
    end
	table.remove(self.rewardList,1)
    for k,v in pairs(self.awardBoxBgTb) do
    	v:stopAllActions()
    	v:setVisible(true)
    	self.gCover1Tb[k]:stopAllActions()
    	self.gCover1Tb[k]:setVisible(false)
    	self.gCover2Tb[k]:setVisible(true)
    	self.gCover2Tb[k]:setRotation(30)
    	if self.rewardList[k].type == "ac" then
    		self.sNameLb[k]:setVisible(true)
    		if acYrjVoApi:getVersion() == 1 then
	    		self.sAwardTb[k]:stopAllActions()
	    		self.sAwardTb[k]:setVisible(true)
	    		self.sAwardTb[k]:setPosition(self.awardLastPos[k] or ccp(self.sAwardTb[ii-1]:getPositionX(),self.sAwardTb[ii-1]:getPositionY() + 75))
	    		self.sAwardTb[k]:setScale(1)
	    	elseif acYrjVoApi:getVersion() == 2 then
	    		self.sAwardTb[k]:stopAllActions()
	    		self.sAwardTb[k]:setVisible(false)	
	    		self:stopStarAction(k)
	    	end
    		if self.sIconTb[k] then
    			self.sIconTb[k]:stopAllActions()
    			self.sIconTb[k]:setVisible(false)
    		end
    	else
    		self.sAwardTb[k]:stopAllActions()
    		self.sAwardTb[k]:setVisible(false)
    		if self.sIconTb[k] then
    			self.sIconTb[k]:stopAllActions()
    			self.sIconTb[k]:setScale(1.3)
    			self.sIconTb[k]:setVisible(true)
    			self.aNameTb[k]:setVisible(true)
    		else
    			local function callback( )
                    G_showNewPropInfo(self.layerNum+1,true,true,nil,self.rewardList[k],nil,nil,nil)
                    return false
                end 
    			local icon,scale=G_getItemIcon(self.rewardList[k],100,true,self.layerNum+1,callback)
				icon:setTouchPriority(-(self.layerNum-1)*20-6)
				self.awardBoxBgTb[k]:addChild(icon,1)
				icon:setVisible(false)
				icon:setScale(80/icon:getContentSize().width)

				local itemW=icon:getContentSize().width*scale
				local numLb=GetTTFLabel("x"..self.rewardList[k].num,25)
				numLb:setAnchorPoint(ccp(1,0))
				numLb:setPosition(ccp(itemW-5,5))
				numLb:setScale(1/icon:getScale())
				icon:addChild(numLb,1)

				local nameLb=GetTTFLabel(self.rewardList[k].name,35,"Helvetica-bold")
		        nameLb:setAnchorPoint(ccp(0.5,1))
		        nameLb:setColor(G_ColorYellowPro)
		        nameLb:setPosition(ccp(self.awardBoxBgTb[k]:getContentSize().width * 0.5, -5))
		        self.awardBoxBgTb[k]:addChild(nameLb)
		        self.aNameTb[ii-1] = nameLb

				self.sIconTb[k] = icon
    		end
    		self.sIconTb[k]:setPosition(self.awardLastPos[k] or ccp(self.sIconTb[k]:getPositionX(),self.sIconTb[k]:getPositionY() + 75))
    	end
    end
end

function acYrjDialog:runAwardAction(rewardList,point)
	if SizeOfTable(self.rewardList) == 0 then
		self.rewardList = rewardList
	end
	for i=1,3 do
		self.actionBgTb2[i]:setVisible(true)
		self.actionBgTb2[i]:setPosition(getCenterPoint(self.bgLayer))
	end

    if not self.hexieLb then
        local hexieLb = GetTTFLabel(getlocal("equip_getReward",{rewardList[1].name.."x"..rewardList[1].num}),25,"Helvetica-bold")
        hexieLb:setAnchorPoint(ccp(0.5,1))
        hexieLb:setColor(G_ColorYellowPro)
        hexieLb:setPosition(ccp(G_VisibleSizeWidth * 0.5,G_VisibleSizeHeight - 180))
        self.bgLayer:addChild(hexieLb,99)
        self.hexieLb = hexieLb
    end

    local rewardListNum = SizeOfTable(self.rewardList)
    for i=2,rewardListNum do
    	self:awardOneByOne(self.rewardList[i],i)
    end

    local deT = CCDelayTime:create(0.25 * rewardListNum)
    local function movCall()
    	print(" in movCall~~~~~~~~~")
    	if self.notEnd then
    		self.notEnd = false
	    	self:stopAwardAction()
	    	self.touchDia:setPositionX(G_VisibleSizeWidth*10)
	    end
    end
    local CCFun = CCCallFuncN:create(movCall)
    local arr = CCArray:create()
    arr:addObject(deT)
    arr:addObject(CCFun)
    local seq = CCSequence:create(arr)
    self.bgLayer:runAction(seq)

end

function acYrjDialog:awardOneByOne(awardTb,ii)
	local boxDeT = CCDelayTime:create(0.2 * (ii-1))
	local function boxShowCall()
		self.awardBoxBgTb[ii-1]:setVisible(true)
	end
	local boxCCF = CCCallFuncN:create(boxShowCall)
	local boxArr = CCArray:create()
	boxArr:addObject(boxDeT)
	boxArr:addObject(boxCCF)
	local boxSeq = CCSequence:create(boxArr)
	self.awardBoxBgTb[ii-1]:runAction(boxSeq)
	local useT = 0.25 * (ii-1)
    local deT = CCDelayTime:create(useT)
    local function cCall( )
    	self.actionCloseMenu:setVisible(true)
    	self.mulBtn:setVisible(true)
        self.gCover1Tb[ii-1]:setVisible(false)
        self.gCover2Tb[ii-1]:setVisible(true)
        local roTo = CCRotateTo:create(0.2, 30)
        self.gCover2Tb[ii-1]:runAction(roTo)
    end 
    local coverCall = CCCallFuncN:create(cCall)
    local coverArr=CCArray:create()
    coverArr:addObject(deT)
    coverArr:addObject(coverCall)
    local Seq=CCSequence:create(coverArr)
    self.gCover1Tb[ii-1]:runAction(Seq)

    if awardTb.type == "ac" then
	    self.awardLastPos[ii-1] =ccp(self.sAwardTb[ii-1]:getPositionX(),self.sAwardTb[ii-1]:getPositionY() + 60)
		local deT2 = CCDelayTime:create(useT)
	    local awardArr=CCArray:create()
    	if acYrjVoApi:getVersion() == 1 then
	        local function sAwardCall( )
	            self.sAwardTb[ii-1]:setVisible(true)
	            self.sNameLb[ii-1]:setVisible(true)
	        end 
	        local sAwardCall = CCCallFuncN:create(sAwardCall)
	        local movUp = CCMoveTo:create(0.1,self.awardLastPos[ii-1])
	        local scalb = CCScaleTo:create(0.1,1)
	        local spaArr = CCArray:create()
	        awardArr:addObject(deT2)
	        awardArr:addObject(sAwardCall)

	        spaArr:addObject(movUp)
	        spaArr:addObject(scalb)
	        local spawn1=CCSpawn:create(spaArr)
	        awardArr:addObject(spawn1)
	        local Seq=CCSequence:create(awardArr)
	        self.sAwardTb[ii-1]:runAction(Seq)
	    elseif acYrjVoApi:getVersion() == 2 then
	    	 local function sAwardCall( )
	            self.sAwardTb[ii-1]:setVisible(false)
	            self.sNameLb[ii-1]:setVisible(true)
	        end 
	        local function starFunc( ... )
	    		self:awardMove(1,ii)
	        end 
	        local starCall = CCCallFuncN:create(starFunc)
	        local sAwardCall = CCCallFuncN:create(sAwardCall)
	        awardArr:addObject(deT2)
	        awardArr:addObject(sAwardCall)
	        awardArr:addObject(starCall)
	        local Seq=CCSequence:create(awardArr)
	        self.sAwardTb[ii-1]:runAction(Seq)
    	end
    else
    	local function callback()
            G_showNewPropInfo(self.layerNum+1,true,true,nil,awardTb,nil,nil,nil)
            return false
        end 
        local icon,scale=G_getItemIcon(awardTb,100,true,self.layerNum+1,callback)
        
        -- icon:setAnchorPoint(ccp(0,0.5))
        icon:setTouchPriority(-(self.layerNum-1)*20-6)
        icon:setPosition(self.sOldPos)
        self.awardBoxBgTb[ii-1]:addChild(icon,1)
        icon:setVisible(false)
        icon:setScale(80/icon:getContentSize().width)

        local itemW=icon:getContentSize().width*scale
        local numLb=GetTTFLabel("x"..awardTb.num,25)
        numLb:setAnchorPoint(ccp(1,0))
        numLb:setPosition(ccp(itemW-5,5))
        numLb:setScale(1/icon:getScale())
        icon:addChild(numLb,1)

        local nameLb=GetTTFLabel(awardTb.name,35,"Helvetica-bold")
        nameLb:setAnchorPoint(ccp(0.5,1))
        nameLb:setColor(G_ColorYellowPro)
        nameLb:setPosition(ccp(self.awardBoxBgTb[ii-1]:getContentSize().width * 0.5, -5))
        self.awardBoxBgTb[ii-1]:addChild(nameLb)
        self.aNameTb[ii-1] = nameLb
        self.aNameTb[ii-1]:setVisible(false)

        self.sIconTb[ii - 1] = icon
        self.awardLastPos[ii-1] =ccp(self.sIconTb[ii-1]:getPositionX(),self.sIconTb[ii-1]:getPositionY() + 75)

        local deT2 = CCDelayTime:create(useT)
        local function sAwardCall( )
            self.sIconTb[ii - 1]:setVisible(true)
            self.aNameTb[ii-1]:setVisible(true)
        end 
        local sAwardCall = CCCallFuncN:create(sAwardCall)
        local movUp = CCMoveTo:create(0.1,self.awardLastPos[ii-1])
        local scalb = CCScaleTo:create(0.2,1.5)
        local scalb2 = CCScaleTo:create(0.1,1.3)
        local awardArr=CCArray:create()
        local spaArr = CCArray:create()
        awardArr:addObject(deT2)
        awardArr:addObject(sAwardCall)

        spaArr:addObject(movUp)
        spaArr:addObject(scalb)
        local spawn1=CCSpawn:create(spaArr)
        awardArr:addObject(spawn1)
        awardArr:addObject(scalb2)
        local Seq=CCSequence:create(awardArr)
        self.sIconTb[ii - 1]:runAction(Seq)
    end
end

--version2 星星动画 
function acYrjDialog:awardMove(i,ii)

    -- 星星出现的时候要有层次感，既不要一次性全出，也不要相继而出
    local tempSpirte = tolua.cast(self.awardBoxBgTb[ii-1]:getChildByTag(i),"CCSprite")
    -- 动作停止
    if tempSpirte then
    	do return end
    end
    local star = CCSprite:createWithSpriteFrameName(i.."_star.png")
    star:setAnchorPoint(ccp(0.5,0))
    star:setPosition(ccp(self.sAwardTb[ii-1]:getPositionX(),self.sAwardTb[ii-1]:getPositionY()-60))
    star:setOpacity(0)
    -- star:setScale(self.sOldScale)
    star:setTag(i)
    self.awardBoxBgTb[ii-1]:addChild(star)
    local acArr = CCArray:create()
    local fadeIn = CCFadeIn:create(0.01)  
    acArr:addObject(fadeIn)
    local acArr1 = CCArray:create()
    local acArr2 = CCArray:create()
    local rotate1 = CCRotateTo:create(0.01,self.detailCfg[i]/4)
    local moveTo1 = CCMoveBy:create(0.01,ccp(0,60/4))
    local rotate2 = CCRotateTo:create(0.03,self.detailCfg[i])
    local moveTo2 = CCMoveBy:create(0.03,ccp(0,60/4*3))
    acArr1:addObject(rotate1)
    acArr1:addObject(moveTo1)
    acArr2:addObject(rotate2)
    acArr2:addObject(moveTo2)
    local spawn1 = CCSpawn:create(acArr1)
    local spawn2 = CCSpawn:create(acArr2)
    acArr:addObject(spawn1)

    if i < 5 then
        local function midMoveCallBack()
            -- 迭代调用
            self:awardMove(i+1,ii)
        end
        local midMoveCall = CCCallFuncN:create(midMoveCallBack)
        acArr:addObject(midMoveCall)
    end
    acArr:addObject(spawn2)

    if i == 5 then
        local function endMoveCallBack()
            local starBg = CCSprite:createWithSpriteFrameName("color_bar.png")
            starBg:setAnchorPoint(ccp(0.5,0.5))
            starBg:setPosition(ccp(self.sAwardTb[ii-1]:getPositionX()+10,self.sAwardTb[ii-1]:getPositionY()+100))
            self.awardBoxBgTb[ii-1]:addChild(starBg)
            starBg:setOpacity(0)
            starBg:setTag(6)
            local fadeIn = CCFadeIn:create(0.01)
            starBg:runAction(fadeIn)
        end
        local endMoveCall = CCCallFuncN:create(endMoveCallBack)
        acArr:addObject(endMoveCall)
    end
    local seq = CCSequence:create(acArr)
    star:runAction(seq)
end

function acYrjDialog:stopStarAction(ii)
	for i=1,6,1 do
    	local tempSpirte = tolua.cast(self.awardBoxBgTb[ii]:getChildByTag(i),"CCSprite")
        if tempSpirte then
            tempSpirte:removeFromParentAndCleanup(true)
            tempSpirte = nil	
        end
	end

	for i=1,5,1 do
    	-- local tempSpirte = tolua.cast(self.awardBoxBgTb[ii]:getChildByTag(i),"CCSprite")
     --    if tempSpirte then
     --        tempSpirte:stopAllActions()
	    -- 	tempSpirte:setPosition(ccp(self.sAwardTb[ii]:getPositionX(),self.sAwardTb[ii]:getPositionY()))
	    -- 	tempSpirte:setRotation(self.detailCfg[i])
     --    else
			local tempSpirte = CCSprite:createWithSpriteFrameName(i.."_star.png")
			tempSpirte:setAnchorPoint(ccp(0.5,0))
	   		tempSpirte:setPosition(ccp(self.sAwardTb[ii]:getPositionX(),self.sAwardTb[ii]:getPositionY()))
	    	tempSpirte:setTag(i)
	    	tempSpirte:setRotation(self.detailCfg[i])
	    	self.awardBoxBgTb[ii]:addChild(tempSpirte)
	end
	local starBg 
	-- = tolua.cast(self.awardBoxBgTb[ii]:getChildByTag(6),"CCSprite")
	-- if starBg then
	-- 	starBg:stopAllActions()
 --     	starBg:setPosition(ccp(self.sAwardTb[ii]:getPositionX(),self.sAwardTb[ii]:getPositionY()+80))
	-- else
	starBg = CCSprite:createWithSpriteFrameName("color_bar.png")
    starBg:setAnchorPoint(ccp(0.5,0.5))
    starBg:setPosition(ccp(self.sAwardTb[ii]:getPositionX()+10,self.sAwardTb[ii]:getPositionY()+100))
    self.awardBoxBgTb[ii]:addChild(starBg)
    starBg:setTag(6)
	-- end
end

function acYrjDialog:endActionLayer(again)
	G_showRewardTip(self.rewardList,true)
	if again then
	else
		for k,v in pairs(self.actionBgTb2) do
			v:setPosition(ccp(G_VisibleSizeWidth * 10,G_VisibleSizeHeight * 0.5))
			v:setVisible(false)
		end
		self.actionCloseMenu:setVisible(false)
		self.mulBtn:setVisible(false)
	end
	for k,v in pairs(self.awardBoxBgTb) do
		for i=1,6,1 do
        	local tempSpirte = tolua.cast(v:getChildByTag(i),"CCSprite")
	        if tempSpirte then
	            tempSpirte:removeFromParentAndCleanup(true)
	            tempSpirte = nil	
	        end
    	end
		self.sNameLb[k]:setVisible(false)
		v:setVisible(false)
		self.gCover1Tb[k]:setVisible(true)
		self.gCover2Tb[k]:setVisible(false)
		self.gCover2Tb[k]:setRotation(0)
		self.sAwardTb[k]:setVisible(false)
		self.sAwardTb[k]:setPosition(self.sOldPos)
		self.sAwardTb[k]:setScale(self.sOldScale)
	end
	for k,v in pairs(self.sIconTb) do
		v:removeFromParentAndCleanup(true)
		self.sIconTb[k] = nil
	end
	for k,v in pairs(self.aNameTb) do
		v:removeFromParentAndCleanup(true)
		self.aNameTb[k] = nil
	end
	self.aNameTb = {}
	self.sIconTb = {}
	self.rewardList = {}
	self.awardLastPos = {}
	if self.hexieLb then
		self.hexieLb:removeFromParentAndCleanup(true)
	end
	self.hexieLb = nil
	
	self.touchDia:setPosition(ccp(G_VisibleSizeWidth*10,G_VisibleSizeHeight * 0.5))
	self.notEnd = true
end