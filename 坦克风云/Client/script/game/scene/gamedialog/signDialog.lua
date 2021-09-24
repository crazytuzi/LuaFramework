signDialog=commonDialog:new()

function signDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

	self.signDayLabel=nil
	self.signBtn=nil
	self.signRewardBtn=nil
	self.selectSp=nil
	self.rewardBg=nil

	self.isRefresh=false
	-- self.adaH = 0 
	-- if G_getIphoneType() == G_iphoneX then
 --       self.adaH = 1250 - 1136
 --    end
    return nc
end

--设置对话框里的tableView
function signDialog:initTableView()
	local signData=signVoApi:getSignData()

	self.panelLineBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,285))
	-- self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-805))
	self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.panelLineBg:getContentSize().height/2+10))

	local rect = CCRect(0, 0, 50, 50)
    local capInSet = CCRect(20, 20, 10, 10)
    local function cellClick(hd,fn,idx)
    end
	local backSprie1=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",capInSet,cellClick)
    backSprie1:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20, 50))
    if G_getIphoneType() == G_iphoneX then
    	backSprie1:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20, 70))
    end
    backSprie1:ignoreAnchorPointForPosition(false)
    backSprie1:setAnchorPoint(ccp(0,1))
    backSprie1:setIsSallow(false)
    backSprie1:setTouchPriority(-(self.layerNum-1)*20-1)
	backSprie1:setPosition(ccp(10,self.bgLayer:getContentSize().height-85))
	self.bgLayer:addChild(backSprie1)

	local subTitle1Label=GetTTFLabelWrap(getlocal("signSubTitle1"),28,CCSizeMake(self.bgLayer:getContentSize().width-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	subTitle1Label:setAnchorPoint(ccp(0,0.5))
    subTitle1Label:setPosition(ccp(10,backSprie1:getContentSize().height/2))
    backSprie1:addChild(subTitle1Label)
	subTitle1Label:setColor(G_ColorYellowPro)

	local function tipTouch()
        local sd=smallDialog:new()
        local dialogLayer=sd:init("TankInforPanel.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,{" ",getlocal("signTip5")," ",getlocal("signTip4")," ",getlocal("signTip3")," ",getlocal("signTip2")," ",getlocal("signTip1")," "},25,{nil,G_ColorYellow,nil,G_ColorYellow,nil,G_ColorYellow,nil,G_ColorYellow,nil,G_ColorYellow,nil})
        sceneGame:addChild(dialogLayer,self.layerNum+1)
        dialogLayer:setPosition(ccp(0,0))
    end
    local tipItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon2.png",tipTouch,11,nil,nil)
    tipItem:setScale(0.6)
    local tipMenu = CCMenu:createWithItem(tipItem)
    tipMenu:setPosition(ccp(backSprie1:getContentSize().width-80,backSprie1:getContentSize().height/2))
    tipMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    backSprie1:addChild(tipMenu,1)

	local backSprie2=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",capInSet,cellClick)
    backSprie2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20, 50))
    if G_getIphoneType() == G_iphoneX then
    	backSprie2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,70))
    end
    backSprie2:ignoreAnchorPointForPosition(false)
    backSprie2:setAnchorPoint(ccp(0,0))
    backSprie2:setIsSallow(false)
    backSprie2:setTouchPriority(-(self.layerNum-1)*20-1)
	backSprie2:setPosition(ccp(10,self.panelLineBg:getContentSize().height+12))
	self.bgLayer:addChild(backSprie2)

	local subTitle2Label=GetTTFLabelWrap(getlocal("signSubTitle2"),28,CCSizeMake(28*11,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	subTitle2Label:setAnchorPoint(ccp(0,0.5))
    subTitle2Label:setPosition(ccp(10,backSprie2:getContentSize().height/2))
    backSprie2:addChild(subTitle2Label)
	subTitle2Label:setColor(G_ColorYellowPro)

	self.signDayLabel=GetTTFLabelWrap(getlocal("signDay",{signData.totalNum}),28,CCSizeMake(28*9,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	self.signDayLabel:setAnchorPoint(ccp(1,0.5))
    self.signDayLabel:setPosition(ccp(backSprie2:getContentSize().width-20,backSprie2:getContentSize().height/2))
    backSprie2:addChild(self.signDayLabel)

    local totalSign=signVoApi:getTotalSign()
    local rewardNumTab=signVoApi:getRewardNumTab()
	for k,v in pairs(rewardNumTab) do
		if v then
			local pic
			if k==1 then
		    	pic="CommonBox.png"
		    elseif k==2 then
		    	pic="CommonBox.png"
		    elseif k==3 then
		    	pic="SeniorBox.png"
		    end
			local function touchInfo(hd,fn,idx)
				local totalSign1=signVoApi:getTotalSign()
				local award=totalSign1[k].award
				if award and SizeOfTable(award)>0 then
					local awardStr=""
					for m,n in pairs(award) do
						awardStr=awardStr..n.name.." x"..n.num..", "
					end
					awardStr=string.sub(awardStr,0,-2)
					local item={name=getlocal("signBox"..k),pic=pic,num=1,desc=awardStr}
					if item and item.name and item.pic and item.num and item.desc then
						propInfoDialog:create(sceneGame,item,self.layerNum+1,true)
					end
				end
			end
			local itemBg=LuaCCScale9Sprite:createWithSpriteFrameName("RegistrationUnselected.png",CCRect(15, 15, 1, 1),touchInfo)
			itemBg:setContentSize(CCSizeMake(185,70))
			itemBg:ignoreAnchorPointForPosition(false)
			itemBg:setAnchorPoint(ccp(0,0))
			itemBg:setIsSallow(false)
			itemBg:setTouchPriority(-(self.layerNum-1)*20-4)
		    self.panelLineBg:addChild(itemBg)
		    itemBg:setPosition(ccp(20+(k-1)*200,210))

		    local boxSp=CCSprite:createWithSpriteFrameName(pic)
		    boxSp:setAnchorPoint(ccp(0,0.5))
		    local scale=0.5
		    boxSp:setPosition(ccp(5,boxSp:getContentSize().height/2*scale))
		    itemBg:addChild(boxSp,1)
		    boxSp:setScale(scale)

		    local numLabel=GetTTFLabel(getlocal("signRewardDay",{v}),25)
			numLabel:setAnchorPoint(ccp(0.5,0))
			numLabel:setPosition((itemBg:getContentSize().width-boxSp:getContentSize().width*scale)/2+boxSp:getContentSize().width*scale,20)
			itemBg:addChild(numLabel,1)
			numLabel:setColor(G_ColorYellow)
		end
	end

	self:doUserHandler()

	local tvHeight=self.bgLayer:getContentSize().height-self.panelLineBg:getContentSize().height-backSprie1:getContentSize().height-backSprie2:getContentSize().height-85
	self.tvHeight = tvHeight
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-20,tvHeight),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    -- self.tv:setPosition(ccp(10,self.bgLayer:getContentSize().height-612))
    self.tv:setPosition(ccp(10,self.panelLineBg:getContentSize().height+backSprie1:getContentSize().height+17))
    if G_getIphoneType() == G_iphoneX then
    	self.tv:setPosition(ccp(10,self.panelLineBg:getContentSize().height+backSprie1:getContentSize().height+7))
    end
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(0)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function signDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        -- return newGiftsVoApi:getNewGiftsNum()
        return signVoApi:getMaxNum()
    elseif fn=="tableCellSizeForIndex" then
    	local cellHeight=95
    	if G_getIphoneType() == G_iphoneX then
    		cellHeight = self.tvHeight / signVoApi:getMaxNum()
    	elseif G_isIphone5() then
	        cellHeight=130
	    end
        local tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-20,cellHeight)
        return tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local cellHeight=95
        if G_getIphoneType() == G_iphoneX then
    		cellHeight = self.tvHeight / signVoApi:getMaxNum()
    	elseif G_isIphone5() then
	        cellHeight = 130
	    end
		
		local signData=signVoApi:getSignData()
		local showIdx=signVoApi:getCanSignDay()

		local rect = CCRect(0, 0, 50, 50)
		local capInSet = CCRect(20, 20, 10, 10)
		local function cellClick(hd,fn,idx)
		end
		local sprieBg
		if showIdx>0 and idx+1==showIdx then
			sprieBg=LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",CCRect(20, 20, 10, 10),cellClick)
			-- sprieBg=LuaCCScale9Sprite:createWithSpriteFrameName("RegistrationAlready.png",CCRect(15, 15, 1, 1),cellClick)
		else
			sprieBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
		end
		sprieBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,cellHeight-5))
		sprieBg:ignoreAnchorPointForPosition(false)
		sprieBg:setAnchorPoint(ccp(0,0))
		-- sprieBg:setTag(1000+idx)
		sprieBg:setIsSallow(false)
		sprieBg:setTouchPriority(-(self.layerNum-1)*20-2)
        sprieBg:setPosition(ccp(0,0))
        cell:addChild(sprieBg)
		--vip特权，奖励翻倍
		if(base.vipPrivilegeSwitch and base.vipPrivilegeSwitch.vsr==1)then
			local vipLb=GetTTFLabel(getlocal("VIPStr34_1"),22)
			local vipBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(40,0,30,36),cellClick)
			vipBg:setContentSize(CCSizeMake(vipLb:getContentSize().width + 60,30))
			vipBg:setAnchorPoint(ccp(0.5,1))
			vipBg:setPosition(ccp(G_VisibleSizeWidth - 120,cellHeight - 10))
			sprieBg:addChild(vipBg)
			vipLb:setColor(G_ColorYellowPro)
			vipLb:setPosition(ccp(G_VisibleSizeWidth - 120,cellHeight - 25))
			sprieBg:addChild(vipLb)
		end


        
        --[[
		local loginLabel=GetTTFLabel(getlocal("newGiftsDesc"),25)
		loginLabel:setAnchorPoint(ccp(0,0.5))
        loginLabel:setPosition(ccp(10,sprieBg:getContentSize().height/2))
        sprieBg:addChild(loginLabel,1)
		loginLabel:setColor(G_ColorGreen)
		
		local numLabel=GetTTFLabel(idx+1,35)
		numLabel:setAnchorPoint(ccp(0,0.5))
        numLabel:setPosition(ccp(10+loginLabel:getContentSize().width+5,sprieBg:getContentSize().height/2))
        sprieBg:addChild(numLabel,1)
		numLabel:setColor(G_ColorYellow)
		
		local dayLabel=GetTTFLabel(getlocal("newGiftsDayDesc"),25)
		dayLabel:setAnchorPoint(ccp(0,0.5))
        dayLabel:setPosition(ccp(10+loginLabel:getContentSize().width+dayLabel:getContentSize().width+5,sprieBg:getContentSize().height/2))
        sprieBg:addChild(dayLabel,1)
		dayLabel:setColor(G_ColorGreen)
		]]

		local numLabel=GetTTFLabel(getlocal("signDayNum",{idx+1}),25)
		numLabel:setAnchorPoint(ccp(0.5,0.5))
        numLabel:setPosition(ccp(50,sprieBg:getContentSize().height/2))
        sprieBg:addChild(numLabel,1)
		numLabel:setColor(G_ColorGreen)
		
		local signVo = signVoApi:getDailySignVo(idx+1)
		local award=signVo.award
		
		local function showInfoHandler(hd,fn,index)
			if self and self.tv and self.tv:getIsScrolled()==false then
				local item=G_clone(award[index])
				if item and item.name and item.pic and item.num and item.desc then
					if tostring(item.key)=="honors" then
						item.num=playerVoApi:getRankDailyHonor(playerVoApi:getRank())
					end
					if(base.vipPrivilegeSwitch and base.vipPrivilegeSwitch.vsr==1  and playerVoApi:getVipLevel()>=playerCfg.vipRelatedCfg.dailySign[1])then
						item.num=item.num*2
					end
					propInfoDialog:create(sceneGame,item,self.layerNum+1)
				end
			end
		end
		for k,v in pairs(award) do
			local icon
			local pic=v.pic
			local iconScaleX=1
			local iconScaleY=1
			--[[
			local startIndex,endIndex=string.find(pic,"^rank(%d+).png$")
			if startIndex~=nil and endIndex~=nil then
				icon=GetBgIcon(pic)
			else
			]]
			icon = LuaCCSprite:createWithSpriteFrameName(pic,showInfoHandler)
			icon:ignoreAnchorPointForPosition(false)
	        icon:setAnchorPoint(ccp(0,0.5))
			if icon:getContentSize().width>100 then
				iconScaleX=0.78*100/150
				iconScaleY=0.78*100/150
			else
				iconScaleX=0.78
				iconScaleY=0.78
			end
			icon:setScaleX(iconScaleX)
			icon:setScaleY(iconScaleY)
				--end
	      	icon:setPosition(ccp((k-1)*85+100,sprieBg:getContentSize().height/2))
			icon:setIsSallow(false)
			icon:setTouchPriority(-(self.layerNum-1)*20-2)
			sprieBg:addChild(icon,1)
			icon:setTag(k)
		
			if tostring(v.key)~="honors" then
				local numLabel
				if(base.vipPrivilegeSwitch and base.vipPrivilegeSwitch.vsr==1  and playerVoApi:getVipLevel()>=playerCfg.vipRelatedCfg.dailySign[1])then
					numLabel=GetTTFLabel("x"..(v.num*playerCfg.vipRelatedCfg.dailySign[2]),25)
				else
					numLabel=GetTTFLabel("x"..v.num,25)
				end
		        --numLabel:setColor(G_ColorGreen)
				numLabel:setAnchorPoint(ccp(1,0))
				numLabel:setPosition(icon:getContentSize().width-10,0)
				icon:addChild(numLabel,1)
				numLabel:setScaleX(1/iconScaleX)
				numLabel:setScaleY(1/iconScaleY)
				--numLabel:setPosition((k-1)*85+icon:getContentSize().width*iconScaleX/2+12,10)
				--cell:addChild(numLabel,1)
			end
		end
		
		local lessDay=signVoApi:getSignLessDay()
		local maxDay=signVoApi:getMaxNum()
		if showIdx>0 and idx+1==showIdx then
			local function rewardHandler(tag,object)
	            PlayEffect(audioCfg.mouseClick)
	            if G_checkClickEnable()==false then
	                do
	                    return
	                end
	            else
	                base.setWaitTime=G_getCurDeviceMillTime()
	            end
	            --正常签到和重新开始回调
	            local function signCallback(fn,data)
					local ret,sData=base:checkServerData(data)
            		if ret==true then
                        if self==nil or self.tv==nil then
                            do return end
                        end
                        local lessDay1=signVoApi:getSignLessDay()
                        if(lessDay1>=1)then
	                        signVoApi:rewardById(1)
	                    else
	                    	signVoApi:rewardById(idx+1)
	                    end
                        local signData1=signVoApi:getSignData()
                        local signDay=signData1.signDay+1
                        local totalNum=signData1.totalNum+1
                        local rewardNumTab=signVoApi:getRewardNumTab()
                        local maxNum=rewardNumTab[SizeOfTable(rewardNumTab)]
                        if totalNum>maxNum then
                        	totalNum=maxNum
                        end
      --                   if signDay>=signVoApi:getMaxNum() then
						-- 	signDay=signVoApi:getMaxNum()
						-- end
                        if lessDay1>=1 then
                        	signDay=1
                        end
                        local lastTime=sData.ts
                        local newData={signDay=signDay,lastTime=lastTime,totalNum=totalNum}
                        signVoApi:updateData(newData)

                        if self.signDayLabel then
                        	self.signDayLabel:setString(getlocal("signDay",{totalNum}))
                        end
						self.tv:reloadData()

						if self.signRewardBtn and signVoApi:isCanReward() then
							self.signRewardBtn:setEnabled(true)
						else
							self.signRewardBtn:setEnabled(false)
						end

					end
                end
                --补签回调
                local function addSignCallback(fn,data)
					local ret,sData=base:checkServerData(data)
            		if ret==true then
                        if self==nil or self.tv==nil then
                            do return end
                        end

                        local costGemsTab=signVoApi:getAddSign()
		            	local costGems=costGemsTab[lessDay]
		            	playerVoApi:setValue("gems",playerVoApi:getGems()-costGems)

		            	signVoApi:signReward()

                        local lessDay2=signVoApi:getSignLessDay()
                        local signData2=signVoApi:getSignData()
                        local signDay=signData2.signDay+lessDay2+1
                        local totalNum=signData2.totalNum+lessDay2+1
                        local rewardNumTab=signVoApi:getRewardNumTab()
                        local maxNum=rewardNumTab[SizeOfTable(rewardNumTab)]
                        if totalNum>maxNum then
                        	totalNum=maxNum
                        end
      --                   if signDay>=signVoApi:getMaxNum() then
						-- 	signDay=signVoApi:getMaxNum()
						-- end
						-- local lastTime=base.serverTime
						local lastTime=sData.ts
                        local newData={signDay=signDay,lastTime=lastTime,totalNum=totalNum}
                        signVoApi:updateData(newData)

                        if self.signDayLabel then
                        	self.signDayLabel:setString(getlocal("signDay",{totalNum}))
                        end
						self.tv:reloadData()

						if self.signRewardBtn and signVoApi:isCanReward() then
							self.signRewardBtn:setEnabled(true)
						else
							self.signRewardBtn:setEnabled(false)
						end

					end
                end
	            local lessDay=signVoApi:getSignLessDay()
	            if tag==1 and lessDay>=1 and lessDay<signVoApi:getMaxNum() then
	            	local costGemsTab=signVoApi:getAddSign()
		            local costGems=costGemsTab[lessDay]
            		local function addSignHandler()
            			local addSign=1
            			if costGems>0 and playerVoApi:getGems()-costGems>=0 then
	            			socketHelper:userSign(addSign,addSignCallback)
	            		else
	            			GemsNotEnoughDialog(nil,nil,costGems-playerVoApi:getGems(),layerNumber,costGems)
	            		end
		            end
	            	local function signAgainHandler()
	            		socketHelper:userSign(nil,signCallback)
		            end
		            local leftBtnStr=getlocal("addSignBtn")
		            local rightBtnStr=getlocal("signAgainBtn")
		            local addSignDesc=getlocal("addSignDesc",{lessDay,costGems})
		            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),addSignHandler,getlocal("dialog_title_prompt"),addSignDesc,true,self.layerNum+1,nil,nil,signAgainHandler,leftBtnStr,rightBtnStr,true)
            	elseif tag==2 then
					socketHelper:userSign(nil,signCallback)
            	end
	        end
	        local menuItemAward
			if lessDay>=1 and lessDay<signVoApi:getMaxNum() then
				menuItemAward=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",rewardHandler,1,getlocal("signBtn"),25)
		    else
				menuItemAward=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",rewardHandler,2,getlocal("signBtn"),25)
		    end
			menuItemAward:setScale(0.8)
			local menuAward=CCMenu:createWithItem(menuItemAward)
	        menuAward:setAnchorPoint(ccp(0.5,0.5))
	        if(base.vipPrivilegeSwitch and base.vipPrivilegeSwitch.vsr==1)then
	        	menuItemAward:setScale(0.7)
	        	menuAward:setPosition(ccp(self.bgLayer:getContentSize().width-120,sprieBg:getContentSize().height/2 - 15))
	        else
	        	menuAward:setPosition(ccp(self.bgLayer:getContentSize().width-120,sprieBg:getContentSize().height/2))
	        end
		    menuAward:setTouchPriority(-(self.layerNum-1)*20-2)
		    sprieBg:addChild(menuAward,2)
		end

		if (signVoApi:isTodaySign()==false and idx==showIdx) or (signVoApi:isTodaySign()==true and idx==signData.signDay) then
			local nextLabel=GetTTFLabelWrap(getlocal("newGiftsNextReward"),25,CCSizeMake(125,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			if(base.vipPrivilegeSwitch and base.vipPrivilegeSwitch.vsr==1)then
				nextLabel:setPosition(ccp(self.bgLayer:getContentSize().width-121,sprieBg:getContentSize().height/2 - 15))
			else
		        nextLabel:setPosition(ccp(self.bgLayer:getContentSize().width-121,sprieBg:getContentSize().height/2))
		    end
	        sprieBg:addChild(nextLabel,1)
		end

		if signData.signDay~=0 and idx+1<=signData.signDay then
			if idx+1<signVoApi:getMaxNum() or (idx+1==signVoApi:getMaxNum() and signVoApi:isTodaySign()==true) then
				local rightIcon=CCSprite:createWithSpriteFrameName("7daysCheckmark.png")
				rightIcon:setAnchorPoint(ccp(0.5,0.5))
				if(base.vipPrivilegeSwitch and base.vipPrivilegeSwitch.vsr==1)then
					rightIcon:setPosition(ccp(self.bgLayer:getContentSize().width-120,sprieBg:getContentSize().height/2 - 15))
				else
					rightIcon:setPosition(ccp(self.bgLayer:getContentSize().width-120,sprieBg:getContentSize().height/2))
				end
				sprieBg:addChild(rightIcon,1)
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

--用户处理特殊需求,没有可以不写此方法
function signDialog:doUserHandler()
	local signData=signVoApi:getSignData()

	if self.signDayLabel then
    	self.signDayLabel:setString(getlocal("signDay",{signData.totalNum}))
    end

	local showIdx=signVoApi:showRewardIdx()
	-- local rewardNumTab=signVoApi:getRewardNumTab()
	-- signVoApi:getTotalSignTab(rewardNumTab[showIdx])
	local totalSign=signVoApi:getTotalSign()
	local signVo=totalSign[showIdx]

	local rect = CCRect(0, 0, 50, 50)
	local capInSet = CCRect(15, 15, 1, 1)
	local function cellClick(hd,fn,idx)
	end
	if self.selectSp==nil then
		self.selectSp=LuaCCScale9Sprite:createWithSpriteFrameName("RegistrationSelect.png",capInSet,cellClick)
		self.selectSp:setContentSize(CCSizeMake(185,70))
		self.selectSp:ignoreAnchorPointForPosition(false)
		self.selectSp:setAnchorPoint(ccp(0,0))
		self.selectSp:setIsSallow(false)
		self.selectSp:setTouchPriority(-(self.layerNum-1)*20-2)
	    self.panelLineBg:addChild(self.selectSp,2)

	    local triangleSp=CCSprite:createWithSpriteFrameName("RegistrationArrow.png")
	    triangleSp:ignoreAnchorPointForPosition(false)
	    triangleSp:setAnchorPoint(ccp(0.5,1))
      	triangleSp:setPosition(ccp(self.selectSp:getContentSize().width/2,5))
		self.selectSp:addChild(triangleSp,1)
	end
	self.selectSp:setPosition(ccp(20+(showIdx-1)*200,210))

	if self.rewardBg then
		self.rewardBg:removeFromParentAndCleanup(true)
		self.rewardBg=nil
	end
	if self.rewardBg==nil then
		self.rewardBg=LuaCCScale9Sprite:createWithSpriteFrameName("RegistrationAwardsBox.png",CCRect(40, 40, 1, 1),cellClick)
		self.rewardBg:setContentSize(CCSizeMake(self.panelLineBg:getContentSize().width-30,120))
		self.rewardBg:ignoreAnchorPointForPosition(false)
		self.rewardBg:setAnchorPoint(ccp(0.5,1))
		self.rewardBg:setIsSallow(false)
		self.rewardBg:setTouchPriority(-(self.layerNum-1)*20-2)
	    self.panelLineBg:addChild(self.rewardBg)
	    self.rewardBg:setPosition(ccp(self.panelLineBg:getContentSize().width/2,200))

		local award=signVo.award
		local function showInfoHandler(hd,fn,index)
			local item=award[index]
			if item and item.name and item.pic and item.num and item.desc then
				propInfoDialog:create(sceneGame,item,self.layerNum+1)
			end
		end
		for k,v in pairs(award) do
			local icon
			local pic=v.pic
			local iconScale=1

			icon = LuaCCSprite:createWithSpriteFrameName(pic,showInfoHandler)
			icon:ignoreAnchorPointForPosition(false)
	        icon:setAnchorPoint(ccp(0,0.5))
			if icon:getContentSize().width>100 then
				iconScale=iconScale*100/150
			end
			icon:setScale(iconScale)

	      	icon:setPosition(ccp((k-1)*120+65,self.rewardBg:getContentSize().height/2))
			icon:setIsSallow(false)
			icon:setTouchPriority(-(self.layerNum-1)*20-4)
			self.rewardBg:addChild(icon,1)
			icon:setTag(k)
		
			if tostring(v.key)~="honors" then
				local numLabel=GetTTFLabel("x"..v.num,25)
		        --numLabel:setColor(G_ColorGreen)
				numLabel:setAnchorPoint(ccp(1,0))
				numLabel:setPosition(icon:getContentSize().width-10,0)
				icon:addChild(numLabel,1)
				numLabel:setScale(1/iconScale)
			end
		end
	end

	if self.signRewardBtn==nil then
		local function signRewardCallback(tag,object)
			if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
			local function signRewardHandler(fn,data)
				local ret,sData=base:checkServerData(data)
                if ret==true then
                	local showIdx1=signVoApi:showRewardIdx()
					local totalSign1=signVoApi:getTotalSign()
					local signVo1=totalSign1[showIdx1]
					local award=signVo1.award

				    local playerHonors =playerVoApi:getHonors() --用户当前的总声望值
				    local maxLevel =playerVoApi:getMaxLvByKey("roleMaxLevel") --当前服 最大等级
				    local honTb =Split(playerCfg.honors,",")
				    local maxHonors =honTb[maxLevel] --当前服 最大声望值
				    				
					for k,v in pairs(award) do
						if v.key=="honors" then
							if base.isConvertGems==1 and tonumber(playerHonors) >=tonumber(maxHonors) then
								local gems = playerVoApi:convertGems(2,tonumber(playerVoApi:getRankDailyHonor(playerVoApi:getRank())))
								playerVoApi:setValue("gold",playerVoApi:getGold()+gems)
							else
								playerVoApi:setValue("honors",playerVoApi:getHonors()+tonumber(playerVoApi:getRankDailyHonor(playerVoApi:getRank())))
							end
						end
						if v.key=="gems" then
							playerVoApi:setValue("gems",playerVoApi:getGems()+tonumber(v.num))
						end
						if v.id and v.id>0 then
							bagVoApi:addBag(v.id,tonumber(v.num))
						end
					end
					G_showRewardTip(award,true)
					-- local awardStr=signVoApi:getAwardStr(award,nil,true)
					-- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),awardStr,28)
                	

                	local signData1=signVoApi:getSignData()
					local rewardNum=signData1.rewardNum+1
					local rewardNumTab=signVoApi:getRewardNumTab()
					if rewardNum>=SizeOfTable(rewardNumTab) then
						rewardNum=0
    				end
    				local newData={rewardNum=rewardNum}
    				local totalNum=signData1.totalNum
    				if totalNum>=rewardNumTab[SizeOfTable(rewardNumTab)] and signData1.rewardNum>=SizeOfTable(rewardNumTab)-1 then
    					newData.totalNum=0
    				end
                	signVoApi:updateData(newData)
                	self:doUserHandler()
                end
			end
			socketHelper:userSignaward(signRewardHandler)
		end
		self.signRewardBtn=GetButtonItem("BigBtnBlue.png","BigBtnBlue_Down.png","BigBtnBlue_Down.png",signRewardCallback,1,getlocal("daily_scene_get"),25)
	    self.signRewardBtn:setAnchorPoint(ccp(0.5,0))
	    local signRewardMenu=CCMenu:createWithItem(self.signRewardBtn)
	    signRewardMenu:setPosition(ccp(self.panelLineBg:getContentSize().width/2+10,2))
	    signRewardMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	    self.panelLineBg:addChild(signRewardMenu,2)
	end

	if signVoApi:isCanReward() then
		self.signRewardBtn:setEnabled(true)
	else
		self.signRewardBtn:setEnabled(false)
	end
	
end

function signDialog:tick()
	if signVoApi:getFlag()==0 or self.isRefresh~=signVoApi:isTodaySign() then
		if self then
			if self.tv then
				self.tv:reloadData()
			end
			self:doUserHandler()
		end
		signVoApi:setFlag(1)
		self.isRefresh=signVoApi:isTodaySign()
	end
end

function signDialog:dispose()
	self.signDayLabel=nil
	self.signBtn=nil
	self.signRewardBtn=nil
	self.selectSp=nil
	self.rewardBg=nil
	self.isRefresh=nil
    self=nil
end




