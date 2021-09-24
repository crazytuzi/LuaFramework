begingPurifyingDialog2 = commonDialog:new()

function begingPurifyingDialog2:new(parent,report,vo,count,typeFlag,typeTb,position,tankId,oldLevel,doType)
	local nc = {
		doType=doType,
	}
	setmetatable(nc, self)
	self.__index = self
	self.parent = parent
	self.report1=report
	self.itemVo=vo
	self.count = count
	self.typeFlag = typeFlag
	self.typeTb=typeTb
	self.position=position
	self.tankId=tankId
	self.oldLevel=oldLevel
	self.activeSpTb={}
	self.unActiveSpTb={}
	self.isEnd=false
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/platWar/platWarImage.plist")
    spriteController:addPlist("public/taskYouhua.plist")
    spriteController:addTexture("public/taskYouhua.png")
    spriteController:addPlist("public/nbSkill.plist")
    spriteController:addTexture("public/nbSkill.png")
	return nc
end	

function begingPurifyingDialog2:resetTab()
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height/2-36))  
end	

function begingPurifyingDialog2:initLayer()
	if self.doType==nil then
		self.doType=1
	end
	self.purifyingNum=SizeOfTable(self.report1)
	self.cellHeightTb={}
	self.titleH,self.spaceY,self.iconWidth=32,10,60
	if self.doType==1 then
		self.attributeIconCfg={"pro_ship_attack.png","pro_ship_life.png","attributeARP.png","attributeArmor.png"}
		self.nameCfg={getlocal("tankAtk"),getlocal("tankBlood"),getlocal("emblem_attUp_arp"),getlocal("emblem_attUp_armor")}
	elseif self.doType==2 then
    	self.conditionTb={getlocal("emblem_troop_washAuto_up"),getlocal("purifying_life_up"),getlocal("purifying_attact_up"),getlocal("sample_prop_name_427"),getlocal("sample_prop_name_428"),getlocal("sample_prop_name_429"),getlocal("sample_prop_name_430")}

		self.attributeIconCfg={"pro_ship_life.png","pro_ship_attack.png","skill_01.png","skill_02.png","skill_03.png","skill_04.png"}
		self.nameCfg={getlocal("property_maxhp"),getlocal("property_dmg"),getlocal("property_accuracy"),getlocal("property_evade"),getlocal("property_crit"),getlocal("property_anticrit")}
	end
	local function bsClick()
	end
	local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),bsClick)
	backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40, 160))
	backSprie:ignoreAnchorPointForPosition(false);
	backSprie:setAnchorPoint(ccp(0.5,1));
	backSprie:setIsSallow(false)
	backSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-100))
	backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
	self.bgLayer:addChild(backSprie,1)
	backSprie:setOpacity(0)

	local titleBg=CCSprite:createWithSpriteFrameName("believerTitleBg.png")
	titleBg:setPosition(ccp(backSprie:getContentSize().width/2,backSprie:getContentSize().height-20))
    backSprie:addChild(titleBg,1)
    local titleStr=""
    if self.doType==1 then
    	titleStr=getlocal("purifying_processStr")
	elseif self.doType==2 then
    	titleStr=getlocal("emblem_troop_washprogress")
    end
	local titleLb=GetTTFLabel(titleStr,25,true)
	titleLb:setPosition(getCenterPoint(titleBg))
	titleBg:addChild(titleLb)

	AddProgramTimer(backSprie,ccp(backSprie:getContentSize().width/2,backSprie:getContentSize().height-110),110,nil,nil,"platWarProgressBg.png","taskBlueBar.png",111,barWScale,nil)
	self.loadingBar = tolua.cast(backSprie:getChildByTag(110),"CCProgressTimer")
	self.loadingBarBg = tolua.cast(backSprie:getChildByTag(111),"CCSprite")
	self.loadingBarBg:setRotation(180)
	self.loadingBar:setRotation(180)
	self.loadingBar:setScaleX(1.15)
	self.loadingBarBg:setScaleX(1.15)
	self.loadingBar:setScaleY(1.3)
	self.loadingBarBg:setScaleY(1.3)
	self.loadingBar:setMidpoint(ccp(1,0))
	self.loadingBar:setPercentage(0)

	self.percentTb={0,self.count/5,self.count/5*2,self.count/5*3,self.count/5*4,self.count}
	local w = 60
	local addw = self.loadingBar:getContentSize().width*1.15/5-2
	for k,v in pairs(self.percentTb) do
		local lb=GetBMLabel(tostring(v),G_GoldFontSrc,10)
		backSprie:addChild(lb,3)
		lb:setPosition(ccp(w+(k-1)*addw,self.loadingBarBg:getPositionY()))
		lb:setScale(0.3)

		local unActiveSp=CCSprite:createWithSpriteFrameName("taskActiveSp1.png")
		unActiveSp:setPosition(ccp(w+(k-1)*addw,self.loadingBarBg:getPositionY()))
		unActiveSp:setScale(1.4)
		backSprie:addChild(unActiveSp,2)

		local activeSp=CCSprite:createWithSpriteFrameName("taskActiveSp2.png")
		activeSp:setPosition(ccp(w+(k-1)*addw,self.loadingBarBg:getPositionY()))
		activeSp:setScale(1.4)
		backSprie:addChild(activeSp,2)

		self.activeSpTb[k]=activeSp
		self.unActiveSpTb[k]=unActiveSp

	end


	local function btnPurifyingCallback()
        if self.doType==2 then
            local usedTimes=emblemTroopVoApi:getTroopWashTimes(self.typeFlag)
            local maxTimes=emblemTroopVoApi:getTroopWashMaxTimes(self.typeFlag)
            if usedTimes+self.count>maxTimes then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("emblem_troop_wash_limitMax"),30)
                return
            end
        end
        local key,num,award = self:getConsumeKeyAndNum()
        if key=="r4" then
            local r4 = playerVoApi:getR4()
            if num*self.count>r4 then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("resourcelimit"),30)
                return
            end
        elseif key=="p8" then
            local shopProps = accessoryVoApi:getShopPropNum()
            if num*self.count>shopProps.p8 then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("purifying_crystal_notenough"),30)
                return
            end 
             local propNum = {shopProps.p8-num*self.count,shopProps.p9,shopProps.p10}
            accessoryVoApi:setShopPropNum(propNum)
        elseif key=="p9" then
            
            local shopProps = accessoryVoApi:getShopPropNum()
            if num*self.count>shopProps.p9 then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("purifying_crystal_notenough"),30)
                return
            end 
            local propNum = {shopProps.p8,shopProps.p9-num*self.count,shopProps.p10}
            accessoryVoApi:setShopPropNum(propNum) 
            
        elseif key=="p10" then
            
            local shopProps = accessoryVoApi:getShopPropNum()
            if num*self.count>shopProps.p10 then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("purifying_crystal_notenough"),30)
                return
            end 
            local propNum = {shopProps.p8,shopProps.p9,shopProps.p10-num*self.count}
            accessoryVoApi:setShopPropNum(propNum)
           
        elseif key=="gems" then
            if playerVoApi:getGems()<num*self.count then
                GemsNotEnoughDialog(nil,nil,num*self.count-playerVoApi:getGems(),self.layerNum+1,num*self.count)
                return
            end 
        else
        	local hadNum = bagVoApi:getItemNumId(award.id)
            if num*self.count>hadNum then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_newTech_pNotEnought"),30)
                return
	        end
        end
		if self.doType==1 then
			self.oldLevel = accessoryVoApi:getSuccinct_level()
			local function callback(fn,data)
	            local ret,sData = base:checkServerData(data)
	            if ret==true then 
	            	self.purifyingMenu:setVisible(false)
					self.endMenu:setVisible(true)
	                if sData.data==nil then 
	                  return
	                end
	                if sData.data.accessory then
	                    accessoryVoApi:updateSuccinctData(sData.data.accessory)
	                    self:refresh()
	                end
	                if sData.data.report then
	                	-- self.report1=sData.data.report
	                	-- self.purifyingNum=SizeOfTable(self.report1)
	                	-- self:initData()
	                	-- self.tvNum=0
	                	-- self.tv:reloadData()
	                	-- self.loadingBar:setPercentage(0)
	                	-- self.tv:runAction(self:getTvAction())
						self:resetShow(sData.data.report)
	                end
	            end
	        end
			socketHelper:accessoryPurifying(self.count,self.typeFlag,self.position,self.tankId,self.typeTb,callback)
		elseif self.doType==2 then
        	local function washRefresh(report)
	            if report then
	            	self:refresh()
                    self.purifyingMenu:setVisible(false)
                    if self.timesLimit then
		            	self.timesLimit:setVisible(false)
		            end
					self.endMenu:setVisible(true)
					self:resetShow(report)
                	-- self.tv:runAction(self:getTvAction())
	            end
        	end
           	local numFlag 
            local timesTb=emblemTroopVoApi:getTroopAutoWashTimes()
            for k,v in pairs(timesTb) do
        		if self.count==v then
            		numFlag=k
            	end
            end
            if numFlag then
        		emblemTroopVoApi:troopWashAuto(self.itemVo.id,self.typeFlag,numFlag,self.typeTb,washRefresh)
            end
		end
	end
	local btnScale,btnStr=0.8,""
	if self.doType==1 then
		btnStr=getlocal("purifying_also",{self.count})
	elseif self.doType==2 then
		btnStr=getlocal("emblem_troop_washAlso",{self.count})
	end
	local purifyingItem = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",btnPurifyingCallback,nil,btnStr,25/btnScale)
	purifyingItem:setScale(btnScale)
	local purifyingMenu=CCMenu:createWithItem(purifyingItem)
	purifyingMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,70))
	purifyingMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(purifyingMenu)
	purifyingMenu:setVisible(false)
	self.purifyingMenu=purifyingMenu

	if self.doType==2 then
        local usedTimes=emblemTroopVoApi:getTroopWashTimes(self.typeFlag)
        local maxTimes=emblemTroopVoApi:getTroopWashMaxTimes(self.typeFlag)
        if usedTimes and maxTimes then
	        local lastTimes=0
	        if maxTimes>usedTimes then
	            lastTimes=maxTimes-usedTimes
	        end
	        self.timesLimit=GetTTFLabel("",20)
	        self.timesLimit:setAnchorPoint(ccp(0.5,0.5))
	        self.bgLayer:addChild(self.timesLimit)
	        self.timesLimit:setPosition(ccp(self.bgLayer:getContentSize().width/2,115))
	        self.timesLimit:setVisible(false)
	        purifyingMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,60))
	    end
    end

	local function endFunc()
		if G_checkClickEnable()==false then
		    do
		        return
		    end
		else
		    base.setWaitTime=G_getCurDeviceMillTime()
		end
		self:endPurifying()
	end
	local endItem = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",endFunc,nil,getlocal("gemCompleted"),25/btnScale)
	endItem:setScale(btnScale)
	local endMenu=CCMenu:createWithItem(endItem)
	endMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,70))
	endMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(endMenu)
	self.endMenu=endMenu


end

function begingPurifyingDialog2:refreshTimesLimitShow()
	if self.doType==2 then
		if self.timesLimit then --军徽部队训练次数刷新
			self.timesLimit:setVisible(true)
	        local usedTimes=emblemTroopVoApi:getTroopWashTimes(self.typeFlag)
        	local maxTimes=emblemTroopVoApi:getTroopWashMaxTimes(self.typeFlag)
	     	local lastTimes=0
		    if maxTimes>usedTimes then
		    	lastTimes=maxTimes-usedTimes
		    end
        	if usedTimes and maxTimes then
	          	local str=getlocal("emblem_troop_washType"..self.typeFlag)
            	self.timesLimit:setString(getlocal("emblem_troop_wash_limitCurrent",{str,lastTimes}))
        	end
	        if lastTimes==0 then
	            self.timesLimit:setColor(G_LowfiColorRed2)
	        else
	            self.timesLimit:setColor(G_ColorWhite)
	        end
		end
	end
end

function begingPurifyingDialog2:initData()
	self.report={}
	for k,v in pairs(self.percentTb) do
		local activeSp=self.activeSpTb[k]
		local unActiveSp=self.unActiveSpTb[k]
		if activeSp then
			activeSp:setVisible(false)
		end
		if unActiveSp then
			unActiveSp:setVisible(true)
		end
	end
end

function begingPurifyingDialog2:getTvAction()
	local acArr=CCArray:create()
	for i=1,self.purifyingNum+1 do
		local function showNextMsg()
			if self and self.tv then 
				if self.report1[i] then               
					table.insert(self.report,self.report1[i]) 
					self.loadingBar:setPercentage(100/self.count*i)
					local percentIdx
					if i>=self.percentTb[6] then
						percentIdx=6
					elseif i>=self.percentTb[5] then
						percentIdx=5
					elseif i>=self.percentTb[4] then
						percentIdx=4
					elseif i>=self.percentTb[3] then
						percentIdx=3
					elseif i>=self.percentTb[2] then
						percentIdx=2
					elseif i>=self.percentTb[1] then
						percentIdx=1
					end
					if percentIdx then
						local activeSp=self.activeSpTb[percentIdx]
						local unActiveSp=self.unActiveSpTb[percentIdx]
						if activeSp and unActiveSp then
							activeSp:setVisible(true)
							unActiveSp:setVisible(false)
						end
					end
				end
			     self.tvNum = i              
			     self.tv:insertCellAtIndex(i-1)
			     if i==self.purifyingNum+1 then
			     	self.purifyingMenu:setVisible(true)
					self.endMenu:setVisible(false)
			     	self:showUpdateDialog()
			     	self:refreshTimesLimitShow()
			     end
			end
		end
		local callFunc1=CCCallFuncN:create(showNextMsg)
		local delay=CCDelayTime:create(0.5)

		acArr:addObject(delay)
		acArr:addObject(callFunc1)
	end
    local seq=CCSequence:create(acArr)
    return seq
end


function begingPurifyingDialog2:initTableView()
	self.panelLineBg:setVisible(false)
	local panelBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelBgShade.png",CCRect(30,0,2,3),function ()end)
	panelBg:setAnchorPoint(ccp(0.5,0))
	panelBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-82))
	panelBg:setPosition(G_VisibleSizeWidth/2,5)
	self.bgLayer:addChild(panelBg)
	self.cellShowTb={}
	self.actionFlag,self.scrollFlag=true,false
	self.showIdx,self.showFrameIdx,self.showHeight=0,0,0

    self:initLayer()
    self:initData()
    self.tvNum=self.purifyingNum+1
	self.tvContentHeight=0
	for i=1,self.tvNum do
		table.insert(self.report,self.report1[i]) 		
		self.tvContentHeight=self.tvContentHeight+self:getCellHeight(i-1)
	end
    self.tvWidth,self.tvHeight=self.bgLayer:getContentSize().width-40,G_VisibleSizeHeight-410
    local viewBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
    viewBg:setAnchorPoint(ccp(0.5,0))
    viewBg:setContentSize(CCSizeMake(self.tvWidth,self.tvHeight+10))
  	self.bgLayer:addChild(viewBg)
	local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition((G_VisibleSizeWidth-self.tvWidth)/2,140)
    self.bgLayer:addChild(self.tv,3)
    self.tv:setMaxDisToBottomOrTop(120)
    -- self.tv:runAction(self:getTvAction())
    viewBg:setPosition(G_VisibleSizeWidth/2,self.tv:getPositionY()-5)
end

function begingPurifyingDialog2:getCellHeight(idx)
	if self.cellHeightTb[idx+1]==nil then
		local attc=SizeOfTable(self.attributeIconCfg)
		local row=math.ceil(attc/2)
		local height=self.titleH+row*self.iconWidth+(row-1)*self.spaceY+10
		if idx==self.purifyingNum then
			height=height+70
		elseif self.report[idx+1][3]==1 then
			height=height+40
		end
		self.cellHeightTb[idx+1]=height
	end
	return self.cellHeightTb[idx+1]
end

function begingPurifyingDialog2:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return self.tvNum
    elseif fn=="tableCellSizeForIndex" then
    	local tempSize=CCSizeMake(self.tvWidth,self:getCellHeight(idx))
        return  tempSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local cellWidth,cellHeight=self.tvWidth,self:getCellHeight(idx)
        local cellNode=CCNode:create()
        cellNode:setAnchorPoint(ccp(0.5,0.5))
        cellNode:setContentSize(CCSizeMake(cellWidth,cellHeight))
        cellNode:setPosition(cellWidth/2,cellHeight/2)
        cell:addChild(cellNode)
        local lbSize=22
        if idx ~= self.purifyingNum then
			local  bgSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,0,1,32),function () end)
		    bgSp:setAnchorPoint(ccp(0,1))
		    bgSp:setPosition(0,cellHeight)
		    bgSp:setContentSize(CCSizeMake(cellWidth,32))
		    cellNode:addChild(bgSp)

			local str=getlocal("raids_reward_num",{idx+1})
			local wayStr=""
			local color=G_LowfiColorRed2
			if 	self.report[idx+1][3]==1 then
				wayStr=getlocal("brackets",{getlocal("collect_border_save")})
				color=G_ColorYellowPro
			else
				wayStr=getlocal("brackets",{getlocal("dailyTaskCancel")})
			end
			local titleLb=GetTTFLabel(str,25)
			titleLb:setAnchorPoint(ccp(0,0.5))
			local wayLb=GetTTFLabel(wayStr,25)
			wayLb:setAnchorPoint(ccp(0,0.5))
			wayLb:setColor(color)
			titleLb:setPosition(10,bgSp:getContentSize().height/2)
			wayLb:setPosition(titleLb:getPositionX()+titleLb:getContentSize().width+5,titleLb:getPositionY())
			bgSp:addChild(titleLb)
			bgSp:addChild(wayLb)

			local attributeTb={}
			local changeTypeTb={}

			local iconSize=self.iconWidth
			local firstPosX=20
			local firstPosY=cellHeight-self.titleH-iconSize/2-5
			local num=#self.attributeIconCfg
			for k=1,num do
				local posX=firstPosX
                if k%2==0 then
                    posX=cellWidth/2+20
                end
				local iconSp=CCSprite:createWithSpriteFrameName(self.attributeIconCfg[k])
				iconSp:setScale(iconSize/iconSp:getContentSize().width)
				iconSp:setPosition(posX,firstPosY-math.floor((k-1)/2)*(iconSize+self.spaceY))
				iconSp:setAnchorPoint(ccp(0,0.5))
				cellNode:addChild(iconSp)


				local arrStr=0 
				if self.doType==1 then
					if k==1 or k==2 then
						arrStr=self.report[idx+1][1][k]*100 .. "%"
					else
						arrStr=self.report[idx+1][1][k]
					end
				elseif self.doType==2 then
					arrStr=self.report[idx+1][1][k]*100 .. "%"
				end
			
				local attribute=GetTTFLabel(self.nameCfg[k],lbSize)
				attribute:setAnchorPoint(ccp(0,0))
				attribute:setPosition(iconSp:getPositionX()+iconSize+10,iconSp:getPositionY()+2)
				cellNode:addChild(attribute)


				local baseLb=GetTTFLabel(arrStr,lbSize)
				baseLb:setAnchorPoint(ccp(0,1))
				baseLb:setPosition(iconSp:getPositionX()+iconSize+10,iconSp:getPositionY()-2)
				cellNode:addChild(baseLb)

				attributeTb[k]=baseLb
			end

			local oldTb = self.report[idx+1][1]
			local newTb = self.report[idx+1][2]
			for k,v in pairs(newTb) do
                changeTypeTb[k]=G_keepNumber(v-oldTb[k],3)
                local str
                if self.doType==1 then
        	       	if k==1 or k==2 then
	                    str=changeTypeTb[k]*100 .. "%"
	                else
	                    str=G_keepNumber(changeTypeTb[k],1)
	                end
            	elseif self.doType==2 then
                    str=changeTypeTb[k]*100 .. "%"
                end
         
                if changeTypeTb[k]>=0 then
                    str = "+" .. str
                else
                    str = str 
                end
                local changeLb = GetTTFLabel(str,20)
                if changeTypeTb[k]>=0 then
                     changeLb:setColor(G_ColorGreen)
                else
                     changeLb:setColor(G_LowfiColorRed2)
                end 
                changeLb:setAnchorPoint(ccp(0,0.5))                      
                attributeTb[k]:addChild(changeLb)
                changeLb:setPosition(attributeTb[k]:getContentSize().width+10,attributeTb[k]:getContentSize().height/2)
            end

            local gsAddLb
            if self.report[idx+1][3]==1 then
            	local changeNum,strengthStr=0,0,""
            	if self.doType==1 then
					local oldStrength=math.ceil((self.report[idx+1][1][1]+self.report[idx+1][1][2])*800+(self.report[idx+1][1][3]+self.report[idx+1][1][4])*20)
					changeNum=G_keepNumber((self.report[idx+1][2][1]+self.report[idx+1][2][2]-self.report[idx+1][1][1]-self.report[idx+1][1][2])*800+(self.report[idx+1][2][3]+self.report[idx+1][2][4]-self.report[idx+1][1][3]-self.report[idx+1][1][4])*20,1)
					strengthStr=getlocal("accessory_gsAdd",{oldStrength})
        		elseif self.doType==2 then
        			local troopVo=emblemTroopVoApi:getEmblemTroopData(self.itemVo.id)
        			local oldStrength=emblemTroopVoApi:getWashStrengthByAtt(self.report[idx+1][1])
            		local newStrength=emblemTroopVoApi:getWashStrengthByAtt(self.report[idx+1][2])
        			changeNum=G_keepNumber(newStrength-oldStrength,1)
					strengthStr=getlocal("emblem_troop_washStrong",{oldStrength})
            	end
				gsAddLb = GetTTFLabel(strengthStr,lbSize)
				gsAddLb:setAnchorPoint(ccp(0,0.5))
				cellNode:addChild(gsAddLb)

				local str = changeNum
				if changeNum>=0 then
					str = "+" .. changeNum
				end
				local changeLb = GetTTFLabel(str,lbSize)
				changeLb:setAnchorPoint(ccp(0,0.5))
				gsAddLb:addChild(changeLb)
				changeLb:setPosition(ccp(gsAddLb:getContentSize().width+10,gsAddLb:getContentSize().height/2))
				if changeNum<0 then
					changeLb:setColor(G_LowfiColorRed2)
				else
					changeLb:setColor(G_ColorGreen)
				end

			end
			if gsAddLb then
				gsAddLb:setPosition(200,gsAddLb:getContentSize().height/2)
			end
		else
			local titleBg=G_createNewTitle({getlocal("purifying_final_fruit"),25},CCSizeMake(300,0))
			titleBg:setPosition(cellWidth/2,cellHeight-60)
			cellNode:addChild(titleBg)

			local strSize2 = 80
			local subW=120
			local strSize3 = 22
		    if G_isAsia() then
		        strSize2 =30
		        subW =70
		        strSize3 =25
		    end
			
			local succinct
			local gsStr,gsStrNew,strengthStr=0,0,""
			if self.doType==1 then
				succinct=self.itemVo:getSuccinct()
				gsStr=math.ceil((self.report[1][1][1]+self.report[1][1][2])*800+(self.report[1][1][3]+self.report[1][1][4])*20)
				gsStrNew=math.ceil((succinct[1]+succinct[2])*800+(succinct[3]+succinct[4])*20)
				strengthStr=getlocal("accessory_gsAdd",{gsStr})
			elseif self.doType==2 then
				local troopVo=emblemTroopVoApi:getEmblemTroopData(self.itemVo.id)
				succinct=troopVo:getSuccinct()
    			gsStr=emblemTroopVoApi:getWashStrengthByAtt(self.report[1][1])
    			gsStrNew=troopVo:getWashStrength()
				strengthStr=getlocal("emblem_troop_washStrong",{gsStr})
			end
			local iconSize=self.iconWidth
			local firstPosX=20
			local firstPosY=cellHeight-60-iconSize/2-5
			local num=#self.attributeIconCfg
			if succinct then
				for k=1,num do
					local posX=firstPosX
	                if k%2==0 then
	                    posX=cellWidth/2+20
	                end
					local iconSp=CCSprite:createWithSpriteFrameName(self.attributeIconCfg[k])
					iconSp:setScale(iconSize/iconSp:getContentSize().width)
					iconSp:setPosition(posX,firstPosY-math.floor((k-1)/2)*(iconSize+self.spaceY))
					iconSp:setAnchorPoint(ccp(0,0.5))
					cellNode:addChild(iconSp)

					local arrStr=0
					local arrStr1New=0
					if self.doType==1 then
						if k==1 or k==2 then
							arrStr=self.report[1][1][k]*100 .. "%"
							arrStr1New=succinct[k]*100 .. "%"
						else
							arrStr=self.report[1][1][k]
							arrStr1New=succinct[k]
						end
					elseif self.doType==2 then
						arrStr=self.report[1][1][k]*100 .. "%"
						arrStr1New=succinct[k]*100 .. "%"
					end
			

					local attribute=GetTTFLabel(self.nameCfg[k],lbSize)
					attribute:setAnchorPoint(ccp(0,0))
					attribute:setPosition(iconSp:getPositionX()+iconSize+10,iconSp:getPositionY()+2)
					cellNode:addChild(attribute)


					local baseLb=GetTTFLabel(arrStr,lbSize)
					baseLb:setAnchorPoint(ccp(0,0.5))
					baseLb:setPosition(iconSp:getPositionX()+iconSize+10,iconSp:getPositionY()-baseLb:getContentSize().height/2-2)
					cellNode:addChild(baseLb)

					local arrowSp=CCSprite:createWithSpriteFrameName("heroArrowRight.png")
					arrowSp:setAnchorPoint(ccp(0,0.5))
					arrowSp:setScale(0.6)
					arrowSp:setPosition(baseLb:getPositionX()+baseLb:getContentSize().width+5,baseLb:getPositionY())
					cellNode:addChild(arrowSp)

					local attributeNew=GetTTFLabel(arrStr1New,lbSize)
					attributeNew:setAnchorPoint(ccp(0,0.5))
					attributeNew:setColor(G_ColorYellowPro)
					attributeNew:setPosition(arrowSp:getPositionX()+arrowSp:getContentSize().width*arrowSp:getScale()+5,baseLb:getPositionY())
					cellNode:addChild(attributeNew)
				end
				local sizeWidth = self.tvWidth-100
				if G_getCurChoseLanguage() == "ar" then
					sizeWidth = 300
				end
				local accessoryGsAdd = GetTTFLabelWrap(strengthStr,lbSize,CCSizeMake(sizeWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
				accessoryGsAdd:setAnchorPoint(ccp(0,0.5))
				cellNode:addChild(accessoryGsAdd)
				local tempLb=GetTTFLabel(strengthStr,lbSize)
				local realW=tempLb:getContentSize().width
				if realW>accessoryGsAdd:getContentSize().width then
					realW=accessoryGsAdd:getContentSize().width
				end

				local arrowSp = CCSprite:createWithSpriteFrameName("heroArrowRight.png")
				arrowSp:setAnchorPoint(ccp(0,0.5))
				arrowSp:setScale(0.6)
				cellNode:addChild(arrowSp)

				local attributeNew = GetTTFLabel(gsStrNew,lbSize)
				attributeNew:setAnchorPoint(ccp(0,0.5))
				attributeNew:setColor(G_ColorYellowPro)
				cellNode:addChild(attributeNew)

				local gsAddW=realW+arrowSp:getContentSize().width*arrowSp:getScale()+attributeNew:getContentSize().width+20
				if G_getCurChoseLanguage() =="ar" then
					accessoryGsAdd:setPosition(cellWidth*0.1,10+accessoryGsAdd:getContentSize().height/2)	
					arrowSp:setPosition(accessoryGsAdd:getPositionX()+accessoryGsAdd:getContentSize().width*1.1,accessoryGsAdd:getPositionY())
				else
					accessoryGsAdd:setPosition((cellWidth-gsAddW)/2,10+accessoryGsAdd:getContentSize().height/2)
					arrowSp:setPosition(accessoryGsAdd:getPositionX()+realW+10,accessoryGsAdd:getPositionY())
				end
				
				attributeNew:setPosition(arrowSp:getPositionX()+arrowSp:getContentSize().width*arrowSp:getScale()+10,arrowSp:getPositionY())
			end
		end
		cellNode:setVisible(false)
		self.cellShowTb[idx+1]=cellNode

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
    end

end

function begingPurifyingDialog2:getConsume()
	if self.doType==1 then
	    local position = tonumber(string.sub(self.position,2))
	    local priceTb = succinctCfg.price[position]
	    local price = priceTb[self.typeFlag]
	    local award = FormatItem(price)
	    return award[1]
	elseif self.doType==2 then
		return emblemTroopVoApi:getTroopWashCost(self.typeFlag)
	end

end

function begingPurifyingDialog2:getConsumeKeyAndNum()
    local award = self:getConsume()
    local level = accessoryVoApi:getSuccinct_level()
    local num=0
    if award.key=="r4" then
        if level < succinctCfg.privilege_5 then
            num=award.num
        elseif level < succinctCfg.privilege_10 then
            num=award.num*0.9
        else
            num=award.num*0.8
        end
    elseif award.key=="p8" then       
        if level < succinctCfg.privilege_7 then
            num=award.num
        elseif level < succinctCfg.privilege_11 then
            num=award.num*0.9
        else
            num=award.num*0.8
        end
    elseif award.key=="p9" then
        if level < succinctCfg.privilege_7 then
            num=award.num
        elseif level < succinctCfg.privilege_11 then
            num=award.num*0.9
        else
            num=award.num*0.8
        end
    elseif award.key=="p10" then       
       if level < succinctCfg.privilege_7 then
            num=award.num
        elseif level < succinctCfg.privilege_11 then
            num=award.num*0.9
        else
            num=award.num*0.8
        end
    elseif award.key=="gems" then
       if level < succinctCfg.privilege_8 then
            num=award.num
        else
            num=award.num*0.9
        end
    end
    return award.key,num,award
end

function begingPurifyingDialog2:resetShow(report)
	self.report1=report	      
	self.purifyingNum=SizeOfTable(self.report1)
	self.tvNum=self.purifyingNum+1
	self.cellShowTb={}
	self:initData()
	self.tvNum=self.purifyingNum+1
	self.tvContentHeight,self.showHeight=0,0
	self.actionFlag=true
	self.scrollFlag=false
	self.showIdx=0
	self.cellHeightTb={}
	for i=1,self.tvNum do
		table.insert(self.report,self.report1[i]) 		
		self.tvContentHeight=self.tvContentHeight+self:getCellHeight(i-1)
	end
	self.tv:reloadData()
	self.loadingBar:setPercentage(0)
end

function begingPurifyingDialog2:showCell(idx)
	local cell=tolua.cast(self.cellShowTb[idx],"CCNode")
	if cell then
		cell:setVisible(true)
	end
	self.loadingBar:setPercentage(100/self.count*idx)
	local percentIdx
	if idx>=self.percentTb[6] then
		percentIdx=6
	elseif idx>=self.percentTb[5] then
		percentIdx=5
	elseif idx>=self.percentTb[4] then
		percentIdx=4
	elseif idx>=self.percentTb[3] then
		percentIdx=3
	elseif idx>=self.percentTb[2] then
		percentIdx=2
	elseif idx>=self.percentTb[1] then
		percentIdx=1
	end
	if percentIdx then
		local activeSp=self.activeSpTb[percentIdx]
		local unActiveSp=self.unActiveSpTb[percentIdx]
		if activeSp and unActiveSp then
			activeSp:setVisible(true)
			unActiveSp:setVisible(false)
		end
	end
end

function begingPurifyingDialog2:fastTick(dt)
	if self.actionFlag==true then
		if self.scrollFlag==false then
			if self.showFrameIdx<3 then
				self.showFrameIdx=self.showFrameIdx+1
			else
				self.showFrameIdx=0
				if self.showIdx<(self.purifyingNum+1) then
					self.showIdx=self.showIdx+1
					self:showCell(self.showIdx)
					self.showHeight=self.showHeight+self:getCellHeight(self.showIdx-1)
				end
			end
			if self.showHeight>=self.tvHeight then
				self.scrollFlag=true
			end
		else
			local tvPoint=self.tv:getRecordPoint()
			tvPoint.y=tvPoint.y+6
			if tvPoint.y>0 then
				tvPoint.y=0
				self:endPurifying()
			end
			self.tv:recoverToRecordPoint(tvPoint)
			if self.showIdx<(self.purifyingNum+1) then
				if tvPoint.y>=self.showHeight-self.tvContentHeight+self:getCellHeight(self.showIdx)/2 then
					self.showIdx=self.showIdx+1
					self:showCell(self.showIdx)
					self.showHeight=self.showHeight+self:getCellHeight(self.showIdx-1)
					self.loadingBar:setPercentage(100/self.count*self.showIdx)
				end
			end
		end
	end
end

function begingPurifyingDialog2:endPurifying()
	self.scrollFlag=false
	self.actionFlag=false
	local recordPoint=self.tv:getRecordPoint()
	recordPoint.y=0
	self.tv:recoverToRecordPoint(recordPoint)
 	self.purifyingMenu:setVisible(true)
	self.endMenu:setVisible(false)
 	self:showUpdateDialog()
 	self:refreshTimesLimitShow()
 	for k=self.showIdx,self.tvNum do
		self:showCell(k)
	end
	self.loadingBar:setPercentage(100)
	self.showIdx=self.tvNum
end

function begingPurifyingDialog2:close(hasAnim)
	if  self.actionFlag==false and self.scrollFlag==false then --精炼完成后可以关闭
        self:purifyingClose()
	end
    -- if self.tvNum~=self.count+1 then
    -- 	return
    -- else
    --     self:purifyingClose()
    -- end
end

function begingPurifyingDialog2:purifyingClose()
    if self.isCloseing==true then
        do return end
    end
    if self.isCloseing==false then
        self.isCloseing=true
    end

    if hasAnim==nil then
        hasAnim=true
    end
    base.allShowedCommonDialog=base.allShowedCommonDialog-1
    for k,v in pairs(base.commonDialogOpened_WeakTb) do
         if v==self then
         	table.remove(base.commonDialogOpened_WeakTb,k)
         	break
         end
    end
    if base.allShowedCommonDialog<0 then
        base.allShowedCommonDialog=0
    end
    if newGuidMgr:isNewGuiding() and (newGuidMgr.curStep==9 or newGuidMgr.curStep==46 or newGuidMgr.curStep==17 or newGuidMgr.curStep==35 or newGuidMgr.curStep==41) then --新手引导
            newGuidMgr:toNextStep()
    end
    local function realClose()
        return self:realClose()
    end
    -- if base.allShowedCommonDialog==0 and storyScene.isShowed==false then
    if base.allShowedCommonDialog==0 and storyScene.isShowed==false and battleScene.isBattleing==false then
                if portScene.clayer~=nil then
                    if sceneController.curIndex==0 then
                        portScene:setShow()
                    elseif sceneController.curIndex==1 then
                        mainLandScene:setShow()
                    elseif sceneController.curIndex==2 then
                        worldScene:setShow()
                    end
                    mainUI:setShow()
                end
    end
     base:removeFromNeedRefresh(self) --停止刷新
    local time=0.3
    if newGuidMgr.curStep==16 then
      time=0;
    end
    local fc= CCCallFunc:create(realClose)
    local moveTo=CCMoveTo:create((hasAnim==true and time or 0),CCPointMake(G_VisibleSize.width/2,-self.bgLayer:getContentSize().height))
    local acArr=CCArray:create()
    acArr:addObject(moveTo)
    acArr:addObject(fc)
    local seq=CCSequence:create(acArr)
    self.bgLayer:runAction(seq)    
end

function begingPurifyingDialog2:showUpdateDialog()
	if self.doType==1 then
		local level = accessoryVoApi:getSuccinct_level()
	    if level~=self.oldLevel then
	         require "luascript/script/game/scene/gamedialog/purifying/purifyingSmallUpdateDialog2"
	        local smallDialog=purifyingSmallUpdateDialog2:new(self.oldLevel)
	        smallDialog:init(self.layerNum+1,self.parent,getlocal("upgradeBuild"))
	    end
	end
end

function begingPurifyingDialog2:refresh()
	self.parent:refresh()
end

function begingPurifyingDialog2:dispose()
	self.parent = nil
	self.report1=nil
	self.itemVo=nil
	self.count = nil
	self.typeFlag = nil
	self.typeTb=nil
	self.position=nil
	self.tankId=nil
	self.oldLevel=nil
	self.activeSpTb={}
	self.unActiveSpTb={}
	self.timesLimit=nil
	self.cellShowTb=nil
	self.actionFlag=nil
	self.scrollFlag=nil
	self.showIdx=nil
	self.showHeight=nil
	self.showFrameIdx=nil
	self.tvContentHeight=nil
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/platWar/platWarImage.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/platWar/platWarImage.png")
	spriteController:removePlist("public/taskYouhua.plist")
    spriteController:removeTexture("public/taskYouhua.png")
    spriteController:removePlist("public/nbSkill.plist")
    spriteController:removeTexture("public/nbSkill.png")
end
