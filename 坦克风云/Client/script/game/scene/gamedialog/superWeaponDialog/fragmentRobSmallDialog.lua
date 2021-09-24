fragmentRobSmallDialog=smallDialog:new()

function fragmentRobSmallDialog:new(fragmentId,type)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.fragmentId=fragmentId
	nc.type=type
	nc.dialogWidth=550
	nc.dialogHeight=400
	nc.isNew = true
	return nc
end

function fragmentRobSmallDialog:init(layerNum)
	self.isTouch=nil
	self.layerNum=layerNum
	self:initBackground()
	self:initContent()
	sceneGame:addChild(self.dialogLayer,self.layerNum)
	return self.dialogLayer
end

function fragmentRobSmallDialog:initBackground()
	local function nilFunc()
	end
	local dialogBg = nil 
	if self.isNew then
		dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("newSmallPanelBg.png",CCRect(170,80,22,10),nilFunc)
	else
		dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),nilFunc)
	end

	if self.isNew then--CCSizeMake(560,170)
		local titleBg=CCSprite:createWithSpriteFrameName("newTitleBg.png")
	    titleBg:setAnchorPoint(ccp(0.5,1))
	    titleBg:setPosition(self.dialogWidth * 0.5,self.dialogHeight)
	    dialogBg:addChild(titleBg)
	end

	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer:setContentSize(self.bgSize)
	self:show()
	self.bgLayer:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)
	local function close()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end
	local closeBtn1,closeBtn2 = "closeBtn.png","closeBtn_Down.png"
	if self.isNew then
		closeBtn1,closeBtn2 = "newCloseBtn.png","newCloseBtn_Down.png"
	end
	local closeBtnItem = GetButtonItem(closeBtn1,closeBtn2,closeBtn1,close,nil,nil,nil);
	closeBtnItem:setPosition(0,0)
	closeBtnItem:setAnchorPoint(CCPointMake(0,0))
	self.closeBtn = CCMenu:createWithItem(closeBtnItem)
	self.closeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.closeBtn:setPosition(ccp(self.dialogWidth-closeBtnItem:getContentSize().width,self.dialogHeight-closeBtnItem:getContentSize().height))
	dialogBg:addChild(self.closeBtn)
	
	-- local titleStr=getlocal("playerInfo")
	-- local titleLb=GetTTFLabel(titleStr,30)
	-- titleLb:setAnchorPoint(ccp(0.5,0.5))
	-- titleLb:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-titleLb:getContentSize().height-5))
	-- dialogBg:addChild(titleLb,1)
    
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
	local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.dialogLayer:addChild(touchDialogBg)
end

function fragmentRobSmallDialog:initContent()
	if superWeaponCfg and superWeaponCfg.fragmentCfg and superWeaponCfg.fragmentCfg[self.fragmentId] then
		local needNameSize = 22
		local lbSize = 20
	    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
	        needNameSize = 28
	        lbSize = 25
	    end

		local cfg=superWeaponCfg.fragmentCfg[self.fragmentId]
		-- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
		local function clickHandler()
		end
		local subNewPosy = self.isNew and 30 or 0
		local fragmentIcon=superWeaponVoApi:getFragmentIcon(self.fragmentId,clickHandler)
		fragmentIcon:setPosition(ccp(90,self.dialogHeight-120 - subNewPosy))
		self.bgLayer:addChild(fragmentIcon,1)

		local swId=cfg.output
		local weaponVo=superWeaponVoApi:getWeaponByID(swId)
		local level=0
		if weaponVo and weaponVo.lv then
			level=weaponVo.lv or 0
		end
		local fName,fDesc=superWeaponVoApi:getFragmentNameAndDesc(self.fragmentId)
		local nameStr=getlocal("fightLevel",{level})..fName
		-- nameStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
		local nameLb=GetTTFLabelWrap(nameStr,needNameSize,CCSizeMake(self.dialogWidth-250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		nameLb:setAnchorPoint(ccp(0,0.5))
		nameLb:setPosition(ccp(160,self.dialogHeight-70 - subNewPosy))
		self.bgLayer:addChild(nameLb,1)
		nameLb:setColor(G_ColorYellowPro)

		local descStr=fDesc
		local descLb=GetTTFLabelWrap(descStr,lbSize,CCSizeMake(self.dialogWidth-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		descLb:setAnchorPoint(ccp(0,0.5))
		descLb:setPosition(ccp(160,self.dialogHeight-150 - subNewPosy))
		self.bgLayer:addChild(descLb,1)

		if self.isNew then
			local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function()end)
            lineSp:setContentSize(CCSizeMake((self.dialogWidth-40),5))
            lineSp:setPosition(ccp(self.dialogWidth * 0.5,170))
            self.bgLayer:addChild(lineSp)
		else
			local lineSp =CCSprite:createWithSpriteFrameName("LineCross.png")
			lineSp:setAnchorPoint(ccp(0.5,0.5))
			lineSp:setScaleX(self.dialogWidth/lineSp:getContentSize().width)
			lineSp:setScaleY(1.2)
			lineSp:setPosition(ccp(self.dialogWidth * 0.5,150))
			self.bgLayer:addChild(lineSp,1)
		end

		if self.type==1 then
			local infoDescLb=GetTTFLabelWrap(getlocal("super_weapon_rob_fragment_info_desc"),25,CCSizeMake(self.dialogWidth-50,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			-- local infoDescLb=GetTTFLabelWrap(str,25,CCSizeMake(self.dialogWidth-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			infoDescLb:setAnchorPoint(ccp(0.5,0.5))
			infoDescLb:setPosition(ccp(self.dialogWidth/2,110))
			self.bgLayer:addChild(infoDescLb,1)
			infoDescLb:setColor(G_ColorYellowPro)

			local hasNum=superWeaponVoApi:getFragmentNum(self.fragmentId)
			local hasNumLb=GetTTFLabelWrap(getlocal("super_weapon_rob_fragment_has_num",{hasNum}),25,CCSizeMake(self.dialogWidth-150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			-- local hasNumLb=GetTTFLabelWrap(str,25,CCSizeMake(self.dialogWidth-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			hasNumLb:setAnchorPoint(ccp(0.5,0.5))
			hasNumLb:setPosition(ccp(self.dialogWidth/2,55))
			self.bgLayer:addChild(hasNumLb,1)
			hasNumLb:setColor(G_ColorYellowPro)
		else
			local btnPosy = self.isNew and 115 or 105
			local function robHandler()
		    	if G_checkClickEnable()==false then
					do return end
				else
					base.setWaitTime=G_getCurDeviceMillTime()
				end
		        PlayEffect(audioCfg.mouseClick)

		        if G_isGlobalServer()==false then
			        if superWeaponVoApi:checkInPeaceTime()==true then
	                    local stStr=G_getTimeStr(weaponrobCfg.peaceTime[1][1]*3600+weaponrobCfg.peaceTime[1][2]*60,2)
	                    local etStr=G_getTimeStr(weaponrobCfg.peaceTime[2][1]*3600+weaponrobCfg.peaceTime[2][2]*60,2)
	                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("super_weapon_rob_peace_tip",{stStr,etStr}),30)
	                    do return end
	                end
	            end

		        local cfg=superWeaponCfg.fragmentCfg[self.fragmentId]
		        local swId=cfg.output
				local weaponVo=superWeaponVoApi:getWeaponByID(swId)
		        -- if weaponVo and weaponVo.lv and weaponVo.lv>=superWeaponCfg.maxLv then
		        -- 	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("super_weapon_rob_can_not_rob"),30)
		        -- 	do return end
		        -- end

		        local function getRobListCallback()
		        	superWeaponVoApi:showRobListDialog(self.fragmentId,self.layerNum+1)
			        self:close()
		        end
		        superWeaponVoApi:weaponGetRoblist(self.fragmentId,false,false,getRobListCallback)
		    end
		    local robItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",robHandler,2,getlocal("super_weapon_title_3"),24/0.8,101)
		    robItem:setScale(0.8)
		    local btnLb = robItem:getChildByTag(101)
		    if btnLb then
		    	btnLb = tolua.cast(btnLb,"CCLabelTTF")
		    	btnLb:setFontName("Helvetica-bold")
		    end
		    local robMenu=CCMenu:createWithItem(robItem)
		    robMenu:setPosition(ccp(self.dialogWidth * 0.28,btnPosy))--80
		    robMenu:setTouchPriority(-(self.layerNum-1)*20-4)
		    self.bgLayer:addChild(robMenu,1)
			
		    local function exploreHandler( )
		    	local cfg=superWeaponCfg.fragmentCfg[self.fragmentId]
		        local swId=cfg.output
				-- local weaponVo=superWeaponVoApi:getWeaponByID(swId)
		  --       if weaponVo and weaponVo.lv and weaponVo.lv>=superWeaponCfg.maxLv then
		  --       	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("super_weapon_rob_can_not_rob"),30)
		  --       	do return end
		  --       end
		    	if level and level < 5 then--super_weapon_exploreTip
		    		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("super_weapon_exploreTip"),30)
		    		do return end
		    	end
		    	local energyNum,nextTime=superWeaponVoApi:setCurEnergy()
                if energyNum < 2 then
                	superWeaponVoApi:showRobAddEnergySmallDialog(self.layerNum+1)
                    self:close()
                    do return end
                end
		    	local function sureExplore( )
			    	local energyNum,nextTime=superWeaponVoApi:setCurEnergy()
	                if energyNum < 2 then
	                	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("super_weapon_noEnergy"),30)
			        	do return end

	     --                if tonumber(CCUserDefault:sharedUserDefault():getIntegerForKey("isContinuousExpl"..playerVoApi:getUid())) == 2 then
						-- 	superWeaponVoApi:showRobAddEnergySmallDialog(self.layerNum+1)
		    --                 self:close()
		    --                 do return end
						-- end
	     --                local item=FormatItem(weaponrobCfg.addEnergyCostProp)[1]
						-- local pid=(tonumber(item.key) or tonumber(RemoveFirstChar(item.key)))
						-- local propNum=bagVoApi:getItemNumId(pid)
						-- local costGemsNum=superWeaponVoApi:getEnergyGemsBuyCost()
						-- if propNum == 0 then 
						-- 	local buyNum=superWeaponVoApi:getEnergyBuyNum()
					 --        local maxNum=superWeaponVoApi:getMaxBuyNum()
					 --        if buyNum >= maxNum then
					 --        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("super_weapon_rob_energy_buy_max"),30)
					 --        	do return end
					 --        end
						-- 	if playerVoApi:getGems() < costGemsNum then
						-- 		 GemsNotEnoughDialog(nil,nil,costGemsNum - playerVoApi:getGems(),self.layerNum+1,costGemsNum)
						-- 		 do return end
						-- 	end
						-- end
	                end

			    	local function getExploreListCallback()
			        	superWeaponVoApi:showContinuousExploreDialog(self.fragmentId,self.layerNum+1,level)
				        self:close()
			        end
			        local isContinuous = tonumber(CCUserDefault:sharedUserDefault():getIntegerForKey("isContinuousExpl"..playerVoApi:getUid())) < 2 and 1 or 0
			        superWeaponVoApi:weaponGetExploreList(self.fragmentId,isContinuous,getExploreListCallback)
			    end

			    local function sureClick()
		            sureExplore()
		        end
		        local function secondTipFunc(sbFlag)
		            local sValue=base.serverTime .. "_" .. sbFlag
		            G_changePopFlag("swExploreTip",sValue)
		        end
	            if G_isPopBoard("swExploreTip") then
	            	local spTb = {secondTip=true}
	                self.secondDialog=superWeaponVoApi:showSecondConfirm(self.layerNum+2,true,true,getlocal("dialog_title_prompt"),true,sureClick,secondTipFunc,nil,nil,nil,nil,true,spTb)
	            else
	                sureClick()
	            end
		    end
			local exploreItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",exploreHandler,2,getlocal("excavate"),24/0.8,101)
		    exploreItem:setScale(0.8)
		    local explBtnLb = exploreItem:getChildByTag(101)
		    if explBtnLb then
		    	explBtnLb = tolua.cast(explBtnLb,"CCLabelTTF")
		    	explBtnLb:setFontName("Helvetica-bold")
		    end
		    local exploreMenu=CCMenu:createWithItem(exploreItem)
		    exploreMenu:setPosition(ccp(self.dialogWidth * 0.72,btnPosy))
		    exploreMenu:setTouchPriority(-(self.layerNum-1)*20-4)
		    self.bgLayer:addChild(exploreMenu,1)		    
		    if level and level > 4 then -- 等级限制 5级
		    	local isContinuous=CCUserDefault:sharedUserDefault():getIntegerForKey("isContinuousExpl"..playerVoApi:getUid())
		    	local function checkClick( )
			    		local isContinuous=CCUserDefault:sharedUserDefault():getIntegerForKey("isContinuousExpl"..playerVoApi:getUid())
			    		-- print("isContinuous----->>>>>",isContinuous)
			    		if isContinuous == 2 then
			    			superWeaponVoApi:setContinuousExp(true)
			    			self.continuousSp:setVisible(true)
			    			CCUserDefault:sharedUserDefault():setIntegerForKey("isContinuousExpl"..playerVoApi:getUid(),1)
                            CCUserDefault:sharedUserDefault():flush()
			    		else
			    			superWeaponVoApi:setContinuousExp(false)
			    			self.continuousSp:setVisible(false)
			    			CCUserDefault:sharedUserDefault():setIntegerForKey("isContinuousExpl"..playerVoApi:getUid(),2)
                            CCUserDefault:sharedUserDefault():flush()
			    		end
		    	end 
		    	local touchSp=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",checkClick)
                touchSp:setAnchorPoint(ccp(0,0))
                touchSp:setScale(0.7)
                touchSp:setPosition(ccp(self.dialogWidth * 0.57,25))
                touchSp:setTouchPriority(-(self.layerNum-1)*20-4)
                self.bgLayer:addChild(touchSp)

                local continuousSp = CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
                continuousSp:setPosition(getCenterPoint(touchSp))
                touchSp:addChild(continuousSp)
                self.continuousSp = continuousSp
                if isContinuous ~= 2 then-- 2 :不连续探索
                	superWeaponVoApi:setContinuousExp(true)
                	continuousSp:setVisible(true)
                else
                	continuousSp:setVisible(false)
                end
                local strSize2 = G_isAsia() and 22 or 15
                local cLb = GetTTFLabelWrap(getlocal("super_weapon_exploreGetPowerTip"),strSize2/0.7,CCSizeMake(self.dialogWidth * 0.45,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
                cLb:setAnchorPoint(ccp(0,0.5))
                cLb:setPosition(ccp(touchSp:getContentSize().width + 5,touchSp:getContentSize().height * 0.5))
                touchSp:addChild(cLb)
		    else
		    	robMenu:setPositionY(80)
		    	exploreMenu:setPositionY(80)
		    end
		end
	end
end

function fragmentRobSmallDialog:dispose()

end