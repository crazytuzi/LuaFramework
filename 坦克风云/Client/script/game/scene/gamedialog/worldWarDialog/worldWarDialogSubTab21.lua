worldWarDialogSubTab21={}
function worldWarDialogSubTab21:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.layerNum=nil
	self.parent=nil
	self.bgLayer=nil
	self.clayer=nil

	self.maskSp=nil
	self.cannotSaveLb=nil
	self.touchArr={}
    self.multTouch=false
    self.touchEnable=nil
    self.isMoved=false
    self.temSp=nil

    self.iconTab={}
    self.tankSpTab={}
    self.tankBgTab={}
    self.numTab={}
    self.descTab={}

    self.fleetIndexTab={}
    self.propertyIndexTab={}

    self.headBgHeight=150
    self.backBgHeight=G_VisibleSizeHeight-self.headBgHeight-235-60

	return nc
end

function worldWarDialogSubTab21:init(layerNum,parent)
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/world_ground.plist")
	self.layerNum=layerNum
	self.parent=parent
	self.bgLayer=CCLayer:create()
	self:updateData()
	self:initHeadBg()
	self:initBackBg()
	self:initSaveBtn()
	-- self:initTableView()
	-- base:addNeedRefresh(self)

	local function tmpFunc()
    end
    self.maskSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),tmpFunc)
    self.maskSp:setOpacity(255)
    local size=CCSizeMake(G_VisibleSize.width-50,G_VisibleSizeHeight-235)
    self.maskSp:setContentSize(size)
    self.maskSp:setAnchorPoint(ccp(0.5,0))
    self.maskSp:setPosition(ccp(G_VisibleSize.width/2,30))
    self.maskSp:setIsSallow(true)
    self.maskSp:setTouchPriority(-(self.layerNum-1)*20-5)
    self.bgLayer:addChild(self.maskSp,8)

    self.cannotSaveLb=GetTTFLabelWrap(getlocal("world_war_cannot_set_fleet2"),30,CCSizeMake(self.maskSp:getContentSize().width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.cannotSaveLb:setAnchorPoint(ccp(0.5,0.5))
    self.cannotSaveLb:setPosition(getCenterPoint(self.maskSp))
    self.maskSp:addChild(self.cannotSaveLb,2)
    self.cannotSaveLb:setColor(G_ColorYellowPro)

    self:tick()

	return self.bgLayer
end

function worldWarDialogSubTab21:initHeadBg()
	local headBgWidth=self.bgLayer:getContentSize().width-40

	local function touch()
	end
	local capInSet = CCRect(65, 25, 1, 1);
	local headBg=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",capInSet,touch)
	headBg:setContentSize(CCSizeMake(headBgWidth,self.headBgHeight))
	headBg:ignoreAnchorPointForPosition(false)
	headBg:setAnchorPoint(ccp(0.5,1))
	headBg:setIsSallow(true)
	headBg:setTouchPriority(-(self.layerNum-1)*20-1)
	headBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-210))
	self.bgLayer:addChild(headBg,1)

	local fpX=50
	local wSpace=25
	local ySpace=40
	for i=1,3 do
		local icon
		local arowRotation=210
		local arrowSp=CCSprite:create("story/CheckPointArow.png")

		-- local icon=CCSprite:createWithSpriteFrameName("ww_tactics_"..i..".png")
	 --    local iconBg=CCSprite:createWithSpriteFrameName("ww_tactics_bg.png")
	 --    icon:setPosition(getCenterPoint(iconBg))
	 --    iconBg:addChild(icon,2)
	    local iconBg=CCSprite:createWithSpriteFrameName("ww_tactics_"..i..".png")
		if i==1 then
			iconBg:setPosition(ccp(fpX+wSpace*2,self.headBgHeight/2+ySpace))
	        
			arrowSp:setRotation(arowRotation)
			arrowSp:setPosition(ccp(fpX+wSpace-15,self.headBgHeight/2))
		elseif i==2 then
			iconBg:setPosition(ccp(fpX+5,self.headBgHeight/2-ySpace))

			arrowSp:setRotation(arowRotation+120)
			arrowSp:setPosition(ccp(fpX+wSpace*3+10,self.headBgHeight/2+8))
		elseif i==3 then
			iconBg:setPosition(ccp(fpX+wSpace*4,self.headBgHeight/2-ySpace))

			arrowSp:setRotation(arowRotation+240)
			arrowSp:setPosition(ccp(fpX+wSpace*2+5,self.headBgHeight/2-ySpace-10))
		end
		-- arrowSp:setFlipX(true)
		arrowSp:setScale(0.4)
		headBg:addChild(arrowSp,1)
		iconBg:setScale(1)
		headBg:addChild(iconBg,2)
	end

	local function showInfo()
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
		PlayEffect(audioCfg.mouseClick)

		local contentTb={getlocal("world_war_help_content3"),getlocal("world_war_help_title3"),"\n",getlocal("world_war_help_content2"),getlocal("world_war_help_title2"),"\n",getlocal("world_war_help_content1",{worldWarCfg.tankeTransRate}),getlocal("world_war_help_title1")}
		local colorTb={nil,G_ColorGreen,nil,nil,G_ColorGreen,nil,nil,G_ColorGreen}
		smallDialog:showTableViewSureWithColorTb("PanelHeaderPopup.png",CCSizeMake(600,750),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("help"),contentTb,colorTb,true,self.layerNum+1)
	end
	local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
	-- infoItem:setScale(0.9)
	local infoBtn = CCMenu:createWithItem(infoItem)
	infoBtn:setPosition(ccp(headBgWidth-80,self.headBgHeight/2))
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	headBg:addChild(infoBtn,1)

	local tabelLb=G_LabelTableView(CCSizeMake(headBgWidth-60-infoItem:getContentSize().width/2-fpX-wSpace*4-40,self.headBgHeight-20),getlocal("world_war_tactical_desc_1"),25,kCCTextAlignmentLeft,G_ColorYellowPro)
	tabelLb:setPosition(ccp(fpX+wSpace*4+40,10))
	tabelLb:setAnchorPoint(ccp(0,0))
	tabelLb:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	tabelLb:setMaxDisToBottomOrTop(70)
	headBg:addChild(tabelLb,2)
end

function worldWarDialogSubTab21:initBackBg()
	local backBgWidth=self.bgLayer:getContentSize().width-60
	local topSpace=20
	local bottomSpace=70
	local lineHeight=self.backBgHeight-topSpace-bottomSpace

	local desc2LbSiz = 18
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
		desc2LbSiz =20
    end
	local function touch()
	end
	local capInSet = CCRect(130, 50, 1, 1);
	local backBg=LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",capInSet,touch)
	backBg:setContentSize(CCSizeMake(backBgWidth,self.backBgHeight))
	backBg:ignoreAnchorPointForPosition(false)
	backBg:setAnchorPoint(ccp(0,0))
	backBg:setIsSallow(true)
	backBg:setTouchPriority(-(self.layerNum-1)*20-1)
	backBg:setPosition(ccp(30,25+60))
	self.bgLayer:addChild(backBg,1)
	self.backBg=backBg

	backBgWidth=backBgWidth-10

	local lineSp1=CCSprite:createWithSpriteFrameName("LineEntity.png");
    lineSp1:setAnchorPoint(ccp(0.5,0.5));
    lineSp1:setPosition(backBgWidth/3+5,lineHeight/2+bottomSpace)
    backBg:addChild(lineSp1,2)
    lineSp1:setRotation(90)
    lineSp1:setScaleX(lineHeight/lineSp1:getContentSize().width)
    lineSp1:setScaleY(5)

    local lineSp2=CCSprite:createWithSpriteFrameName("LineEntity.png");
    lineSp2:setAnchorPoint(ccp(0.5,0.5));
    lineSp2:setPosition(backBgWidth/3*2+5,lineHeight/2+bottomSpace)
    backBg:addChild(lineSp2,2)
    lineSp2:setRotation(90)
    lineSp2:setScaleX(lineHeight/lineSp2:getContentSize().width)
    lineSp2:setScaleY(5)

    self.iconTab={}
    self.tankSpTab={}
    self.tankBgTab={}
    self:updateProperty()
    for i=1,3 do
    	local posX=backBgWidth/6*(i*2-1)+5

		local perY=7.5
	    local skillTitle=getlocal("world_war_battle_num_"..i)
	    local skillTitleLb=GetTTFLabel(skillTitle,25)
		skillTitleLb:setAnchorPoint(ccp(0.5,0.5))
		skillTitleLb:setPosition(ccp(posX,bottomSpace+lineHeight/8*perY))
		backBg:addChild(skillTitleLb,2)
		skillTitleLb:setColor(G_ColorYellowPro)

	    perY=7
	    local lineSprie =CCSprite:createWithSpriteFrameName("LineCross.png")
		lineSprie:setAnchorPoint(ccp(0.5,0.5))
		lineSprie:setScaleX(backBgWidth/3/lineSprie:getContentSize().width)
		lineSprie:setScaleY(2)
		lineSprie:setPosition(ccp(posX,bottomSpace+lineHeight/8*perY))
		backBg:addChild(lineSprie,2)




	    -- local landTypeBg =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20,20,10,10),function ()end)
     --    landTypeBg:setContentSize(CCSizeMake(backBgWidth/3,lineHeight/2))
     --    landTypeBg:ignoreAnchorPointForPosition(false)
     --    landTypeBg:setAnchorPoint(ccp(0.5,0))
     --    landTypeBg:setIsSallow(false)
     --    landTypeBg:setTouchPriority(-(self.layerNum-1)*20-1)
     --    landTypeBg:setPosition(ccp(posX,bottomSpace))
     --    backBg:addChild(landTypeBg,1)
     --    landTypeBg:setVisible(false)

     	local function clickHandler()
     		if self.tankSpTab and self.tankSpTab[i] then
     			do return end
     		end
     		if self.parent and self.parent.switchSubTab then
				self.parent:switchSubTab(i+1,false)
			end
     	end
     	perY=2.8
        local tSize=100
	    local tankBg=LuaCCSprite:createWithSpriteFrameName("Icon_BG.png",clickHandler)
	    tankBg:setScale(tSize/tankBg:getContentSize().width)
	    -- tankBg:setPosition(ccp(posX,bottomSpace+lineHeight/2-tSize/2-10))
	    tankBg:setPosition(ccp(posX,bottomSpace+lineHeight/8*perY))
	    tankBg:setTouchPriority(-(self.layerNum-1)*20-2)
		tankBg:setIsSallow(false)
	    backBg:addChild(tankBg,2)
	    table.insert(self.tankBgTab,tankBg)
	    local addSp=CCSprite:createWithSpriteFrameName("ProduceTankIconMore.png")
		addSp:setPosition(getCenterPoint(tankBg))
		tankBg:addChild(addSp)
		addSp:setScale(1.5)

		local function nilFunc()
		end
	    local tankId=tankVoApi:getTankIdByIndex(i,self.fleetIndexTab)
	    -- print("tankId",tankId)
	    if tankId then
	    	local tid=(tonumber(tankId) or tonumber(RemoveFirstChar(tankId)))
	    	if tid and tankCfg[tid] then
	    		local fleetIndex = self.fleetIndexTab[i]
	    		local tskinTb=tankSkinVoApi:getTankSkinListByBattleType(fleetIndex+12)
	    		local skinId = tskinTb[tankSkinVoApi:convertTankId(tid)]
	    		local tankSp = tankVoApi:getTankIconSp(tid,skinId,nilFunc,false)
	    		tankSp:setTouchPriority(-(self.layerNum-1)*20-3)
				tankSp:setIsSallow(false)
	    		tankSp:setScale(tankBg:getContentSize().width/tankSp:getContentSize().width)
	    		tankSp:setPosition(getCenterPoint(tankBg))
	    		tankBg:addChild(tankSp,2)
	    		self.tankSpTab[i]=tankSp
	    	end
	    end


        local function nilFunc()
        end
        local numSp =LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",CCRect(17, 17, 1, 1),nilFunc)
        numSp:setScale(0.8)
        numSp:setPosition(ccp(tankBg:getContentSize().width/2,5))
        tankBg:addChild(numSp,4)
        local numLb=GetTTFLabel(i,25)
		numLb:setAnchorPoint(ccp(0.5,0.5))
		numLb:setPosition(getCenterPoint(numSp))
		numSp:addChild(numLb,1)
		table.insert(self.numTab,numLb)

		perY=0.95
	    local landType=worldWarVoApi:getFleetLandType(i)
	    local teSp
	    local teName
	    if landType and landType~=0 then
	    	teSp=CCSprite:createWithSpriteFrameName("world_ground_"..landType..".png")
	    	teName=getlocal("world_ground_name_"..landType)
	    else
	    	teSp=CCSprite:createWithSpriteFrameName("ww_landType_0.png")
	    	teName=getlocal("world_war_landType_unknow")

	    	local questionMarkSp=CCSprite:createWithSpriteFrameName("questionMark.png")
	    	questionMarkSp:setPosition(getCenterPoint(teSp))
	    	teSp:addChild(questionMarkSp,1)
	    end
	    -- teSp:setPosition(ccp(posX,bottomSpace+lineHeight/2-tSize-10-teSp:getContentSize().height/2-15))
	    teSp:setPosition(ccp(posX,bottomSpace+lineHeight/8*perY))
	    -- if G_isIphone5()==true then
	    -- 	teSp:setPosition(ccp(posX,bottomSpace+lineHeight/4))
	    -- end
	    backBg:addChild(teSp,2)

	    perY=0.20
	    local teNameLb=GetTTFLabel(teName,20)
		teNameLb:setAnchorPoint(ccp(0.5,0.5))
		teNameLb:setPosition(ccp(posX,bottomSpace+lineHeight/8*perY))
		backBg:addChild(teNameLb,2)
		teNameLb:setColor(G_ColorYellowPro)
    end
    
    local desc2=getlocal("world_war_tactical_desc_2")
    local desc2Lb=GetTTFLabelWrap(desc2,desc2LbSiz,CCSizeMake(550,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	desc2Lb:setAnchorPoint(ccp(0.5,0.5))
	desc2Lb:setPosition(ccp(backBgWidth/2,bottomSpace/2+10))
	backBg:addChild(desc2Lb,2)
	desc2Lb:setColor(G_ColorYellowPro)





	self.clayer=CCLayer:create()
	-- self.clayer:setContentSize(CCSizeMake(backBgWidth,self.backBgHeight))
    self.clayer:setPosition(ccp(0,0))
	self.bgLayer:addChild(self.clayer,8)
    self.clayer:setTouchEnabled(true)
    local function tmpHandler(...)
    	return self:touchEvent(...)
    end
	self.clayer:registerScriptTouchHandler(tmpHandler,false,-(self.layerNum-1)*20-4,false)
	self.touchEnable=true
end

function worldWarDialogSubTab21:touchEvent(fn,x,y,touch)
    if fn=="began" then
        -- if self.touchEnable==false or SizeOfTable(self.touchArr)>=2 or newGuidMgr:isNewGuiding()==true then
        if self.touchEnable==false or newGuidMgr:isNewGuiding()==true then
            return 0
        end
        self.isMoved=false
        self.touchArr[touch]=touch

        if SizeOfTable(self.touchArr)>1 then
            -- self.multTouch=true

            if self.temSp then
	        	self.temSp:removeFromParentAndCleanup(true)
	        	self.temSp=nil
	        end
        else
            -- self.multTouch=false

            local curPos=CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
            self.index=0
            self.selectType=0
            local bx,by=self.backBg:getPosition()
            for k,v in pairs(self.iconTab) do
            	local ix,iy=v:getPosition()
            	local cx,cy=ix+bx,iy+by
            	local w,h=v:getContentSize().width/2,v:getContentSize().height/2
            	if curPos.x>=cx-w and curPos.x<=cx+w and curPos.y>=cy-h and curPos.y<=cy+h then
	            	self.index=k
	            	self.selectType=1
	            end
            end
            local tSize=100
            if self.tankBgTab then
	            for k,v in pairs(self.tankBgTab) do
	            	if self.tankSpTab and self.tankSpTab[k] then
		            	local ix,iy=v:getPosition()
		            	local cx,cy=ix+bx,iy+by
		            	local w,h=tSize/2,tSize/2
		            	if curPos.x>=cx-w and curPos.x<=cx+w and curPos.y>=cy-h and curPos.y<=cy+h then
			            	self.index=k
			            	self.selectType=2
			            end
			        end
	            end
	        end
            if self.index>0 and self.selectType>0 and self.temSp==nil then
            	if self.selectType==1 then
            		local idx=self.propertyIndexTab[self.index]
				    local icon=CCSprite:createWithSpriteFrameName("ww_tactics_"..idx..".png")
				    self.temSp=CCSprite:createWithSpriteFrameName("ww_tactics_bg.png")
				    icon:setPosition(getCenterPoint(self.temSp))
				    self.temSp:addChild(icon,2)
				    self.temSp:setScale(0.9)
				else
					if self.tankSpTab and self.tankSpTab[self.index] then
						local tankId=tankVoApi:getTankIdByIndex(self.index,self.fleetIndexTab)
					    if tankId then
					    	local tid=(tonumber(tankId) or tonumber(RemoveFirstChar(tankId)))
							if tid and tankCfg[tid] then
								local fleetIndex = self.fleetIndexTab[self.index]
								local tskinTb = tankSkinVoApi:getTankSkinListByBattleType(fleetIndex+12)
								local skinId = tskinTb[tankSkinVoApi:convertTankId(tid)]
								self.temSp= tankVoApi:getTankIconSp(tid,skinId,nil,false)
								self.temSp:setScale(tSize/self.temSp:getContentSize().width)
							end
						end
					end
				end
			    if self.temSp then
				    self.temSp:setAnchorPoint(ccp(0.5,0.5))
				    self.temSp:setPosition(curPos)
				    self.temSp:setOpacity(150)
				    self.clayer:addChild(self.temSp,2)
				    -- self.bgLayer:addChild(self.temSp,2)
				    self.touch=touch

				    -- self.iconTab[self.index]:setVisible(false)
				end
	        end
        end

        return 1
    elseif fn=="moved" then
        if self.touchEnable==false or newGuidMgr:isNewGuiding()==true then
            do
            	return
            end
        end
        self.isMoved=true
        -- if self.multTouch==true then --双点触摸

        -- else --单点触摸
        if self.touch and self.touch==touch then
            local curPos=CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
            -- print("curPos--x,y:",curPos.x,curPos.y)
            if self.temSp then
			    self.temSp:setPosition(curPos)
            end
        end
    elseif fn=="ended" then
        if self.touchEnable==false or newGuidMgr:isNewGuiding()==true then
            do
                return
            end
        end
        if self.touch and self.touch==touch then
	        if self.temSp then
	        	self.temSp:removeFromParentAndCleanup(true)
	        	self.temSp=nil
	        end

	        local curPos=CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
            local targetIndex=0
            local bx,by=self.backBg:getPosition()
            if self.selectType and self.selectType==1 then
	            for k,v in pairs(self.iconTab) do
	            	-- v:setVisible(true)
	            	local ix,iy=v:getPosition()
	            	local cx,cy=ix+bx,iy+by
	            	local w,h=v:getContentSize().width/2,v:getContentSize().height/2
	            	if curPos.x>=cx-w and curPos.x<=cx+w and curPos.y>=cy-h and curPos.y<=cy+h then
		            	targetIndex=k
		            end
	            end
	        elseif self.selectType and self.selectType==2 then
	        	local tSize=100
	        	if self.tankBgTab then
		            for k,v in pairs(self.tankBgTab) do
		            	local ix,iy=v:getPosition()
		            	local cx,cy=ix+bx,iy+by
		            	local w,h=tSize/2,tSize/2
		            	if curPos.x>=cx-w and curPos.x<=cx+w and curPos.y>=cy-h and curPos.y<=cy+h then
			            	targetIndex=k
			            end
		            end
		        end
	        end
            if targetIndex>0 and self.index and self.index>0 and targetIndex~=self.index then
            	if self.selectType and self.selectType==1 then
            		worldWarVoApi:setPropertyIndex(self.index,targetIndex,self.propertyIndexTab)
	            	self:updateProperty()
	            elseif self.selectType and self.selectType==2 then
	            	tankVoApi:setFleetIndex(self.index,targetIndex,self.fleetIndexTab)
	            	self:refresh()
	            end
            end
	    end
    	if self.touchArr[touch]~=nil then
           self.touchArr[touch]=nil
       	end
    else
        self.touchArr=nil
        self.touchArr={}
    end
end

-- function worldWarDialogSubTab21:initTableView()
-- 	local function callBack(...)
-- 		-- return self:eventHandler3(...)
-- 	end
-- 	local hd= LuaEventHandler:createHandler(callBack)
-- 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-50,G_VisibleSizeHeight-260),nil)
-- 	-- self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
-- 	-- self.tv:setPosition(25,50)
-- 	-- self.bgLayer:addChild(self.tv,1)
-- 	-- self.tv:setMaxDisToBottomOrTop(100)

-- end


function worldWarDialogSubTab21:updateData()
    self.fleetIndexTab=G_clone(tankVoApi:getFleetIndexTb())
    self.propertyIndexTab=G_clone(worldWarVoApi:getPropertyIndexTab())
end

function worldWarDialogSubTab21:updateProperty()
	local backBgWidth=self.bgLayer:getContentSize().width-60
	local topSpace=20
	local bottomSpace=70
	local lineHeight=self.backBgHeight-topSpace-bottomSpace
	
	if self.iconTab==nil then
		self.iconTab={}
	else
		for k,v in pairs(self.iconTab) do
			local sp=tolua.cast(v,"CCSprite")
			sp:removeFromParentAndCleanup(true)
			sp=nil
			self.iconTab[k]=nil
		end
		self.iconTab={}
	end
	if self.descTab==nil then
		self.descTab={}
	end
	for i=1,3 do
		local posX=backBgWidth/6*(i*2-1)+5*(2-i)

		local perY=6.1
		-- local idx=worldWarVoApi:getPropertyIndex(i)
		local idx=self.propertyIndexTab[i]
		local icon=CCSprite:createWithSpriteFrameName("ww_tactics_"..idx..".png")
	    local iconBg=CCSprite:createWithSpriteFrameName("ww_tactics_bg.png")
	    iconBg:setScale(0.9)
	    iconBg:setPosition(ccp(posX,lineHeight/8*perY+bottomSpace))
	    icon:setPosition(getCenterPoint(iconBg))
	    iconBg:addChild(icon,2)
	    self.backBg:addChild(iconBg,2)
	    table.insert(self.iconTab,iconBg)

	    perY=4.6
		if self.descTab[i]==nil then
			self.descTab[i]={}
		else
			for k,v in pairs(self.descTab[i]) do
				local lb=tolua.cast(v,"CCLabelTTF")
				lb:removeFromParentAndCleanup(true)
				lb=nil
				self.descTab[i]=nil
				self.descTab[i]={}
			end
		end
		local skillName=getlocal("world_war_tactical_property_"..idx)
	    local skillNameLb=GetTTFLabel(skillName,20)
		skillNameLb:setAnchorPoint(ccp(0.5,0.5))
		skillNameLb:setPosition(ccp(posX,lineHeight/8*perY+bottomSpace+25))
		self.backBg:addChild(skillNameLb,2)
		skillNameLb:setColor(G_ColorYellowPro)
		table.insert(self.descTab[i],skillNameLb)

		local attCfg=worldWarCfg.strategyAtt[idx]
		local indx=0
		local strSize2 = 20
		if G_getCurChoseLanguage() =="ru" then
			strSize2 =16
		end
		for k,v in pairs(attCfg[1]) do
			local propStr=G_getPropertyStr(k)
			local addStr="+"..v.."%"
			local propStrLb=GetTTFLabel(propStr,strSize2)
			local addStrLb=GetTTFLabel(addStr,strSize2)
			addStrLb:setColor(G_ColorGreen)
			local totalWidth=propStrLb:getContentSize().width+addStrLb:getContentSize().width
			propStrLb:setPosition(ccp(posX-totalWidth/2+propStrLb:getContentSize().width/2,lineHeight/8*perY+bottomSpace-25*indx))
			addStrLb:setPosition(ccp(posX+totalWidth/2-addStrLb:getContentSize().width/2,lineHeight/8*perY+bottomSpace-25*indx))
			self.backBg:addChild(propStrLb,2)
			self.backBg:addChild(addStrLb,2)
			table.insert(self.descTab[i],propStrLb)
			table.insert(self.descTab[i],addStrLb)
			indx=indx+1
		end
	end
end

function worldWarDialogSubTab21:refresh()
	if self.tankBgTab and SizeOfTable(self.tankBgTab)>0 then
		for k,v in pairs(self.tankBgTab) do
			local bg=tolua.cast(v,"CCSprite")
			if self.tankSpTab and self.tankSpTab[k] then
				local sp=tolua.cast(self.tankSpTab[k],"CCSprite")
				sp:removeFromParentAndCleanup(true)
				self.tankSpTab[k]=nil
			end
		    local tankId=tankVoApi:getTankIdByIndex(k,self.fleetIndexTab)
		    if tankId then
		    	local tid=(tonumber(tankId) or tonumber(RemoveFirstChar(tankId)))
		    	if tid and tankCfg[tid] then
                	local fleetIndex=self.fleetIndexTab[k]
		    		local tskinTb = tankSkinVoApi:getTankSkinListByBattleType(fleetIndex+12)
		    		local skinId = tskinTb[tankSkinVoApi:convertTankId(tid)]
		    		local tankSp = tankVoApi:getTankIconSp(tid,skinId,nil,false)
		    		tankSp:setScale(bg:getContentSize().width/tankSp:getContentSize().width)
		    		tankSp:setPosition(getCenterPoint(bg))
		    		bg:addChild(tankSp,2)
		    		self.tankSpTab[k]=tankSp
		    	end
		    end

		    if self.numTab and self.numTab[k] then
		    	-- local index=tankVoApi:getFleetIndex(k)
		    	local index=self.fleetIndexTab[k]
		    	local lb=tolua.cast(self.numTab[k],"CCLabelTTF")
		    	lb:setString(index)
		    end
		end
	end
end

function worldWarDialogSubTab21:initSaveBtn()
	local function save()
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
		PlayEffect(audioCfg.mouseClick)

		if tankVoApi:worldWarIsSetFleet()==false then
			local function onConfirm()
				if self.parent and self.parent.switchSubTab then
					self.parent:switchSubTab(2,false)
				end
			end
			smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("world_war_cannot_set_tactical"),nil,self.layerNum+1)
			do return end
		end

    	local function setstrategyCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
            	tankVoApi:setFleetIndexTb(self.fleetIndexTab)
            	worldWarVoApi:setPropertyIndexTab(self.propertyIndexTab)
            	if sData.ts then
	            	worldWarVoApi:setLastSetStrategyTime(tonumber(sData.ts))
	            end
	            self:tick()

            	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("save_success"),30)
            end
        end
    	local line=self.fleetIndexTab
    	local strategy=self.propertyIndexTab
        socketHelper:worldwarSetstrategy(line,strategy,setstrategyCallback)
    end
    self.saveBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnCancleSmall.png",save,nil,getlocal("arena_save"),25)
    self.saveBtn:setScale(0.8)
    local saveMenu=CCMenu:createWithItem(self.saveBtn)
    saveMenu:setPosition(ccp(520,60))
    saveMenu:setTouchPriority((-(self.layerNum-1)*20-4))
    self.bgLayer:addChild(saveMenu,3)

    local saveTimeStr=getlocal(getlocal("world_war_can_save"))
    -- saveTimeStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    self.saveTimeLb=GetTTFLabelWrap(saveTimeStr,22,CCSizeMake(self.bgLayer:getContentSize().width-240,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    self.saveTimeLb:setAnchorPoint(ccp(0,0.5))
    self.saveTimeLb:setPosition(ccp(50,60))
    self.bgLayer:addChild(self.saveTimeLb,3)
    self.saveTimeLb:setColor(G_ColorYellowPro)

	self:tick()
end

function worldWarDialogSubTab21:tick()
	if self then
		local setFleetStatus=worldWarVoApi:getSetFleetStatus()
        if setFleetStatus and setFleetStatus>=0 then
            if setFleetStatus==0 then
                if self.maskSp then
                    self.maskSp:setPosition(ccp(10000,0))
                end
            else
                if self.maskSp then
                    self.maskSp:setPosition(ccp(G_VisibleSize.width/2,30))
                end

                if self.cannotSaveLb then
                	self.cannotSaveLb:setString(getlocal("world_war_cannot_set_fleet"..setFleetStatus))
                end
            end
        end

    	local lastTime=worldWarVoApi:getLastSetStrategyTime() or 0
        local leftTime=worldWarCfg.settingTroopsLimit-(base.serverTime-lastTime)
        if leftTime>0 then
            if self.saveBtn and self.saveBtn:isEnabled()==true then
                self.saveBtn:setEnabled(false)
            end
            if self.saveTimeLb then
                self.saveTimeLb:setVisible(true)
                self.saveTimeLb:setString(getlocal("world_war_save_left_time",{GetTimeForItemStr(leftTime)}))
            end
        else
        	if self.saveBtn and self.saveBtn:isEnabled()==false then
                self.saveBtn:setEnabled(true)
            end
            if self.saveTimeLb then
            	self.saveTimeLb:setString(getlocal("world_war_can_save"))
            end
        end
    end
end

function worldWarDialogSubTab21:dispose()
	self.fleetIndexTab={}
    self.propertyIndexTab={}

    self.maskSp=nil
	self.cannotSaveLb=nil
	self.touchArr={}
    self.multTouch=false
    self.touchEnable=nil
    self.isMoved=false
    self.temSp=nil

    self.iconTab={}
    self.tankSpTab={}
    self.tankBgTab={}
    self.numTab={}
    self.descTab={}

	-- base:removeFromNeedRefresh(self)
	if self.clayer then
		self.clayer:removeFromParentAndCleanup(true)
	end
	self.clayer=nil
	if self.bgLayer then
		self.bgLayer:removeFromParentAndCleanup(true)
	end
	self.tv=nil
	self.layerNum=nil
	self.bgLayer=nil
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/world_ground.plist")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/world_ground.pvr.ccz")
end