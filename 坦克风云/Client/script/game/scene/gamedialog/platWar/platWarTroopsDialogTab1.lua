platWarTroopsDialogTab1={}
function platWarTroopsDialogTab1:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.layerNum=nil
	self.parent=nil
	self.bgLayer=nil
	-- self.clayer=nil

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
    self.teSpTab={}
    self.teNameLbTab={}
    self.statusTab={}
    self.leftRoundTab={}

    self.fleetIndexTab={}
    self.propertyIndexTab={}
    self.tipTab={}

    -- self.headBgHeight=150
    -- self.backBgHeight=G_VisibleSizeHeight-self.headBgHeight-235-60
    self.backBgHeight=G_VisibleSizeHeight-355

	return nc
end

function platWarTroopsDialogTab1:init(layerNum,parent)
	self.layerNum=layerNum
	self.parent=parent
	self.bgLayer=CCLayer:create()
	self:updateData()
	-- self:initHeadBg()
	self:initBackBg()
	self:initSaveBtn()

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

    self.maskSp:setPosition(ccp(10000,0))

	return self.bgLayer
end

function platWarTroopsDialogTab1:initBackBg()
	local backBgWidth=self.bgLayer:getContentSize().width-60
	local topSpace=20
	local bottomSpace=20--70
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
	backBg:setPosition(ccp(30,215))
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
    self.statusTab={}
    self.leftRoundTab={}
    -- self:updateProperty()
    for i=1,3 do
    	local posX=backBgWidth/6*(i*2-1)+5

		local perY=7.3
	    local skillTitle=getlocal("world_war_sub_title2"..(i+1))
	    local skillTitleLb=GetTTFLabel(skillTitle,25)
		skillTitleLb:setAnchorPoint(ccp(0.5,0.5))
		skillTitleLb:setPosition(ccp(posX,bottomSpace+lineHeight/8*perY))
		backBg:addChild(skillTitleLb,2)
		skillTitleLb:setColor(G_ColorYellowPro)

	    perY=6.6
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
     	perY=5.5
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
	    local tankId=tankVoApi:getPlatWarTankIdByIndex(i)
	    -- tankId="a1000"..i
	    if tankId then
	    	local tid=(tonumber(tankId) or tonumber(RemoveFirstChar(tankId)))
	    	if tid and tankCfg[tid] then
	    		local tankSp=CCSprite:createWithSpriteFrameName(tankCfg[tid].icon)
	   --  		tankSp:setTouchPriority(-(self.layerNum-1)*20-3)
				-- tankSp:setIsSallow(false)
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

		perY=4
		local fleetIndex=tankVoApi:getPlatWarFleetIndex(i)
		local landType=0
		if fleetIndex then
	    	landType=platWarVoApi:getFleetLandType(fleetIndex)
	    end
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
	    teSp:setPosition(ccp(posX,bottomSpace+lineHeight/8*perY))
	    backBg:addChild(teSp,2)
	    table.insert(self.teSpTab,teSp)

	    perY=3.2
	    local teNameLb=GetTTFLabel(teName,20)
		teNameLb:setAnchorPoint(ccp(0.5,0.5))
		teNameLb:setPosition(ccp(posX,bottomSpace+lineHeight/8*perY))
		backBg:addChild(teNameLb,2)
		-- teNameLb:setColor(G_ColorYellowPro)
		table.insert(self.teNameLbTab,teNameLb)

		perY=2.55
		local status,round=platWarVoApi:getTroopsStatus(i)
	    local statusStr=getlocal("plat_war_troops_status_"..status)
	    -- statusStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
	    local statusLb=GetTTFLabelWrap(statusStr,20,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		statusLb:setAnchorPoint(ccp(0.5,0.5))
		statusLb:setPosition(ccp(posX,bottomSpace+lineHeight/8*perY))
		backBg:addChild(statusLb,2)
		statusLb:setColor(G_ColorYellowPro)
		if status==1 then
			statusLb:setColor(G_ColorRed)
		elseif status==2 then
			statusLb:setColor(G_ColorGreen)
		elseif status==3 then
			statusLb:setColor(G_ColorOrange)
		end
		table.insert(self.statusTab,statusLb)
		perY=1.85
		local roundLeftLb=GetTTFLabelWrap("",20,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		roundLeftLb:setAnchorPoint(ccp(0.5,0.5))
		roundLeftLb:setPosition(ccp(posX,bottomSpace+lineHeight/8*perY))
		backBg:addChild(roundLeftLb,2)
		roundLeftLb:setColor(G_ColorYellowPro)
		if status==3 then
			local roundLeftStr=getlocal("plat_war_round_left",{round})
			-- roundLeftStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
			roundLeftLb:setString(roundLeftStr)
		else
			roundLeftLb:setVisible(false)
		end
		table.insert(self.leftRoundTab,roundLeftLb)

		perY=0.8
		local function changeHandler()
			if G_checkClickEnable()==false then
	            do
	                return
	            end
	        else
	            base.setWaitTime=G_getCurDeviceMillTime()
	        end
			PlayEffect(audioCfg.mouseClick)
			
		    local function selectHandler( ... )
		    	for k=1,3 do
		    		local posXX=backBgWidth/6*(k*2-1)+5
		    		local perYY=4
					local fleetIndex=tankVoApi:getPlatWarFleetIndex(k)
					local landType=0
					if fleetIndex then
				    	landType=platWarVoApi:getFleetLandType(fleetIndex)
				    end
				    local teSp
				    local teName
				    local teNameLb
				    if self.teSpTab==nil then
						self.teSpTab={}
					end
					if self.teNameLbTab==nil then
						self.teNameLbTab={}
					end
				    if self.teSpTab[k] then
				    	teSp=tolua.cast(self.teSpTab[k],"CCSprite")
				    end
				    if self.teNameLbTab[k] then
				    	teNameLb=tolua.cast(self.teNameLbTab[k],"CCLabelTTF")
				    end
				    if teSp then
				    	teSp:removeFromParentAndCleanup(true)
				    	teSp=nil
				    end
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
				    teSp:setPosition(ccp(posXX,bottomSpace+lineHeight/8*perYY))
				    backBg:addChild(teSp,2)
				    if teNameLb then
					    teNameLb:setString(teName)
					end
					if self.teSpTab==nil then
						self.teSpTab={}
					end
					self.teSpTab[k]=teSp
					self.teNameLbTab[k]=teNameLb
		    	end
		    end
			platWarVoApi:showSelectRoadSmallDialog(self.layerNum+1,i,selectHandler)
	    end
	    local changeItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnCancleSmall.png",changeHandler,nil,getlocal("plat_war_changeRoad"),25)
	    -- self.changeItem:setScale(0.8)
	    local changeMenu=CCMenu:createWithItem(changeItem)
	    changeMenu:setPosition(ccp(posX,bottomSpace+lineHeight/8*perY))
	    changeMenu:setTouchPriority((-(self.layerNum-1)*20-4))
	    backBg:addChild(changeMenu,2)

	    local tipSp=CCSprite:createWithSpriteFrameName("IconTip.png")
        tipSp:setAnchorPoint(CCPointMake(1,1))
        tipSp:setPosition(ccp(changeItem:getContentSize().width,changeItem:getContentSize().height))
        changeItem:addChild(tipSp,5)
        table.insert(self.tipTab,tipSp)
        tipSp:setVisible(false)
    end

end


function platWarTroopsDialogTab1:updateData()
    self.fleetIndexTab=G_clone(tankVoApi:getPlatWarFleetIndexTb())
end

function platWarTroopsDialogTab1:refresh()
	if self.tankBgTab and SizeOfTable(self.tankBgTab)>0 then
		for k,v in pairs(self.tankBgTab) do
			local bg=tolua.cast(v,"CCSprite")
			if self.tankSpTab and self.tankSpTab[k] then
				local sp=tolua.cast(self.tankSpTab[k],"CCSprite")
				if sp then
					sp:removeFromParentAndCleanup(true)
				end
				self.tankSpTab[k]=nil
			end
		    local tankId=tankVoApi:getPlatWarTankIdByIndex(k)
		    -- local tankId="a1001"..k
		    if tankId then
		    	local tid=(tonumber(tankId) or tonumber(RemoveFirstChar(tankId)))
		    	if tid and tankCfg[tid] then
		    		local tankSp=CCSprite:createWithSpriteFrameName(tankCfg[tid].icon)
		    		tankSp:setScale(bg:getContentSize().width/tankSp:getContentSize().width)
		    		tankSp:setPosition(getCenterPoint(bg))
		    		bg:addChild(tankSp,2)
		    		self.tankSpTab[k]=tankSp
		    	end
		    end
		    -- if self.numTab and self.numTab[k] then
		    -- 	local index=self.fleetIndexTab[k]
		    -- 	local lb=tolua.cast(self.numTab[k],"CCLabelTTF")
		    -- 	lb:setString(index)
		    -- end
		end
	end
end

function platWarTroopsDialogTab1:initSaveBtn()
	local function save()
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
		PlayEffect(audioCfg.mouseClick)

		if platWarVoApi:isCanSetTroops()==false then
	        do return end
	    end
		if tankVoApi:platWarIsAllSetFleet()==false then
			-- local function onConfirm()
			-- 	if self.parent and self.parent.switchSubTab then
			-- 		self.parent:switchSubTab(2,false)
			-- 	end
			-- end
			-- smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("world_war_cannot_set_tactical"),nil,self.layerNum+1)
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("plat_war_set_troops_tip"),30)
			do return end
		end

		local fleetIndexTb=tankVoApi:getPlatWarFleetIndexTb()
		if(fleetIndexTb==nil or #fleetIndexTb<3)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("plat_war_set_line_tip"),30)
			do return end
		end
		for k,v in pairs(fleetIndexTb) do
			if(v==nil or v<=0)then
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("plat_war_set_line_tip"),30)
				do return end
			end
		end

    	local function setLineCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
            	if sData.data then
					platWarVoApi:updateInfo(sData.data)
					self:updateData()
				end
	            self:tick()
            	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("save_success"),30)
            end
        end
    	local line=G_clone(tankVoApi:getPlatWarFleetIndexTb())
    	-- local strategy=self.propertyIndexTab
        -- socketHelper:worldwarSetstrategy(line,strategy,setstrategyCallback)
    	socketHelper:platwarSetline(line,setLineCallback)
    end
    self.saveBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnCancleSmall.png",save,nil,getlocal("arena_save"),25)
    -- self.saveBtn:setScale(0.8)
    local saveMenu=CCMenu:createWithItem(self.saveBtn)
    saveMenu:setPosition(ccp(520,80))
    saveMenu:setTouchPriority((-(self.layerNum-1)*20-4))
    self.bgLayer:addChild(saveMenu,3)

    local saveTimeStr=getlocal(getlocal("world_war_can_save"))
    -- saveTimeStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    self.saveTimeLb=GetTTFLabelWrap(saveTimeStr,25,CCSizeMake(self.bgLayer:getContentSize().width-250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    self.saveTimeLb:setAnchorPoint(ccp(0,0.5))
    self.saveTimeLb:setPosition(ccp(40,80))
    self.bgLayer:addChild(self.saveTimeLb,3)
    self.saveTimeLb:setColor(G_ColorYellowPro)

    local desc2=getlocal("plat_war_set_line_desc")
    -- desc2=saveTimeStr
    local desc2Lb=GetTTFLabelWrap(desc2,25,CCSizeMake(550,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	desc2Lb:setAnchorPoint(ccp(0.5,0.5))
	desc2Lb:setPosition(ccp(self.bgLayer:getContentSize().width/2,170))
	self.bgLayer:addChild(desc2Lb,2)
	desc2Lb:setColor(G_ColorYellowPro)

	self:tick()
end

function platWarTroopsDialogTab1:tick()
	if self then
    	local lastTime=platWarVoApi:getLastSetLineTime() or 0
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

        for i=1,3 do
        	local status,round=platWarVoApi:getTroopsStatus(i)
        	if self.statusTab and self.statusTab[i] then
        		local statusStr=getlocal("plat_war_troops_status_"..status)
        		local statusLb=tolua.cast(self.statusTab[i],"CCLabelTTF")
        		statusLb:setString(statusStr)
        	end
        	if self.leftRoundTab and self.leftRoundTab[i] then
        		local roundLeftLb=tolua.cast(self.leftRoundTab[i],"CCLabelTTF")
        		if status==3 then
        			roundLeftLb:setVisible(true)
					local roundLeftStr=getlocal("plat_war_round_left",{round})
					-- roundLeftStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
					roundLeftLb:setString(roundLeftStr)
				else
					roundLeftLb:setVisible(false)
				end
        	end
        end
        if platWarVoApi:checkStatus()<30 then
        	for k,v in pairs(self.tipTab) do
		    	if v then
		            local tipSp=tolua.cast(v,"CCSprite")
		            if tipSp then
		            	local tankId=tankVoApi:getPlatWarTankIdByIndex(k)
		                if tankId then
		                	local fIndex=tankVoApi:getPlatWarFleetIndex(k)
			                if fIndex and fIndex>0 then
			            		tipSp:setVisible(false)
			            	else
			            		tipSp:setVisible(true)
			            	end
		                else
		                    tipSp:setVisible(false)
		                end
		            end
		        end
		    end
        end
    end
end

function platWarTroopsDialogTab1:dispose()
	tankVoApi:setPlatWarFleetIndexTb(G_clone(self.fleetIndexTab))
	self.fleetIndexTab={}
    self.propertyIndexTab={}
    self.tipTab={}

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
    self.teSpTab={}
    self.teNameLbTab={}
    self.statusTab={}
    self.leftRoundTab={}

	-- if self.clayer then
	-- 	self.clayer:removeFromParentAndCleanup(true)
	-- end
	-- self.clayer=nil
	if self.bgLayer then
		self.bgLayer:removeFromParentAndCleanup(true)
	end
	self.tv=nil
	self.layerNum=nil
	self.bgLayer=nil
end