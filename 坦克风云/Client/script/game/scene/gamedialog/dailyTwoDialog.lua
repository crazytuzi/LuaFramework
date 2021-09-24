--require "luascript/script/componet/commonDialog"
require "luascript/script/game/gamemodel/daily/dailyVoApi"

dailyTwoDialog=commonDialog:new()

function dailyTwoDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
	
	self.characterSp=nil
	self.descBg=nil
	self.descLabel=nil
	self.backSprie=nil
	self.commonBoxTab={}
	self.seniorBoxTab={}
	self.canClick=true
	self.maskSp=nil
	self.freeBtn=nil
	self.playBtn=nil
	self.buyAndPlayBtn=nil
	self.costDescLabel=nil
	self.selectedBox=nil
	self.unlockSp=nil
	self.goldSp=nil
	self.gemsLabel=nil
	self.unlockLabel=nil

	self.tenCountsLb=nil
	self.tenCountsLb2=nil
    return nc
end

--设置对话框里的tableView
function dailyTwoDialog:initTableView()
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSize.width-20,G_VisibleSize.height-105))
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.panelLineBg:getContentSize().height/2+20))
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-20,self.bgLayer:getContentSize().height-125),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)

	local function touch()
	end
	local capInSet = CCRect(20, 20, 10, 10)
	if self.characterSp==nil then
        if platCfg.platCfgChangeGuideUI[G_curPlatName()] then
            self.characterSp=CCSprite:create("public/guide.png")
        else
            self.characterSp=CCSprite:createWithSpriteFrameName("GuideCharacter.png")
        end
		self.characterSp:setAnchorPoint(ccp(0,0))
		self.characterSp:setPosition(ccp(20,self.bgLayer:getContentSize().height-360))
		self.bgLayer:addChild(self.characterSp,2)
	end
	if self.descBg==nil then
	    self.descBg =LuaCCScale9Sprite:createWithSpriteFrameName("LanguageSelectBtn.png",capInSet,touch)
	    self.descBg:setContentSize(CCSizeMake(355, 200))
	    self.descBg:setAnchorPoint(ccp(0.5,0.5))
	    self.descBg:setPosition(ccp(self.bgLayer:getContentSize().width*0.68,self.bgLayer:getContentSize().height-self.characterSp:getContentSize().height*0.5-120))
	    self.descBg:setRotation(180)
	    self.bgLayer:addChild(self.descBg,1)
	end
	if self.descLabel==nil then
		self.descLabel=GetTTFLabelWrap(getlocal("lotteryCommonDesc2"),25,CCSizeMake(self.descBg:getContentSize().width-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	    self.descLabel:setAnchorPoint(ccp(0.5,0.5))
	    self.descLabel:setPosition(ccp(self.descBg:getContentSize().width*0.5,self.descBg:getContentSize().height*0.3))
	    self.descBg:addChild(self.descLabel,1)
	    self.descLabel:setRotation(180)
		--self.descLabel:setColor(G_ColorGreen)
	else
		if self.selectedTabIndex==0 then
			self.descLabel:setString(getlocal("lotteryCommonDesc2"))
		elseif self.selectedTabIndex==1 then
			self.descLabel:setString(getlocal("lotteryCommonDesc2"))
		end
	end

	local luckGemss = dailyVoApi:getLuckyCoins()
	self.luckGems =GetTTFLabelWrap(getlocal("exchangeAllLuckGem",{luckGemss}),23,CCSizeMake(self.descBg:getContentSize().width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	self.luckGems:setAnchorPoint(ccp(0.5,0.5))
	self.luckGems:setPosition(ccp(self.descBg:getContentSize().width*0.7,self.descBg:getContentSize().height*0.9-5))
	self.luckGems:setRotation(180)
	self.descBg:addChild(self.luckGems,1)
	self.luckGems:setColor(G_ColorYellow)

	if self.backSprie==nil then
		self.backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(10, 10, 1, 1),touch)
	    self.backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,self.bgLayer:getContentSize().height-380))
	    self.backSprie:setAnchorPoint(ccp(0,0))
	    self.backSprie:setPosition(ccp(10,20))
	    self.bgLayer:addChild(self.backSprie,1)
	end
	self:setDownShow()

end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function dailyTwoDialog:eventHandler(handler,fn,idx,cel)
	do return end	
end

function dailyTwoDialog:setDownShow()

	local function bgClick()
	end
	local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(63, 28, 1, 1),bgClick)
	backSprie:setContentSize(CCSizeMake(self.backSprie:getContentSize().width-2, self.backSprie:getContentSize().height*0.25))
	backSprie:setAnchorPoint(ccp(0.5,0))
	backSprie:setPosition(ccp(self.backSprie:getContentSize().width*0.5,self.backSprie:getContentSize().height*0.65))
	self.backSprie:addChild(backSprie)
	
	local ShapeGift1 = CCSprite:createWithSpriteFrameName("ShapeGift.png")
	ShapeGift1:setAnchorPoint(ccp(0.5,0.5))
	ShapeGift1:setPosition(ccp(backSprie:getContentSize().width*0.5,backSprie:getContentSize().height+10))
	backSprie:addChild(ShapeGift1,1)

	self.smallGoldIcon =CCSprite:createWithSpriteFrameName("item_baoxiang_34.png")
	self.smallGoldIcon:setAnchorPoint(ccp(0,0.5))
	self.smallGoldIcon:setPosition(ccp(backSprie:getContentSize().width*0.05,backSprie:getContentSize().height*0.5-20))
	backSprie:addChild(self.smallGoldIcon,1)
	self.smallGoldIcon:setScale(1.2)

	self.primaryExchange = GetTTFLabelWrap(getlocal("exchangePrimary"),28,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	self.primaryExchange:setAnchorPoint(ccp(0,0))
	self.primaryExchange:setPosition(ccp(self.smallGoldIcon:getPositionX(),self.smallGoldIcon:getPositionY()+self.smallGoldIcon:getContentSize().height*0.5+10))
	backSprie:addChild(self.primaryExchange,1)
	self.primaryExchange:setColor(G_ColorGreen)

	local reward=FormatItem(playerCfg.mustReward1.reward)
	local rewardStr=""
	for k,v in pairs(reward) do
		rewardStr=rewardStr..v.name.."×"..FormatNumber(v.num).." "
	end
	self.primaryExchangeDes = GetTTFLabelWrap(getlocal("exchangePrimaryDes",{rewardStr}),23,CCSizeMake(430,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	self.primaryExchangeDes:setAnchorPoint(ccp(0,0.5))
	self.primaryExchangeDes:setPosition(ccp(backSprie:getContentSize().width*0.05+130,backSprie:getContentSize().height*0.5))
	backSprie:addChild(self.primaryExchangeDes,1)

	local function onClick1(tag1,object )
		local isFree=dailyVoApi:isFreeByType(1)
		local diffCoins=dailyVoApi:getLuckyCoins()
		local gemsSingle = playerVoApi:getGems()
		local dataKey="dailiTwoDialog@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
		local coutNums =tonumber(CCUserDefault:sharedUserDefault():getStringForKey(dataKey))
		if G_getBHVersion()==2 and base.isCheckVersion == 1 and coutNums ~=nil and coutNums >=10 then
			smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("upperTen"),nil,self.layerNum+1)
			do return end
		end
			if isFree or diffCoins>0 or gemsSingle>= 15 then		
				local function lotteryCommonCallback(fn,data)
	                local success,retTb=base:checkServerData(data)
					if success==true and retTb~=nil then
			                    --统计使用物品
						if diffCoins> 0 then
			            	diffCoins=dailyVoApi:getLuckyCoins()
			            	
			            	if diffCoins<= 0 then
			            		self.clickItem1:setVisible(false)
			            		self.clickItem1:setEnabled(false)
			            		self.cost1:setVisible(true)
			            		self.cost1:setEnabled(true)
			            		self.singleGem:setVisible(true)
			            		self.gemIcon1:setVisible(true)
			            	else
			            		tolua.cast(self.clickItem1:getChildByTag(501),"CCLabelTTF"):setString(getlocal("code_gift"))
								self.clickItem1:setVisible(true)
								self.clickItem1:setEnabled(true)
								self.cost1:setVisible(false)
								self.cost1:setEnabled(false)
								self.singleGem:setVisible(false)
								self.gemIcon1:setVisible(false)
			            	end
			            else
			            	--playerVoApi:setGems(gemsSingle-15)
		            		self.clickItem1:setVisible(false)
		            		self.clickItem1:setEnabled(false)
		            		self.cost1:setVisible(true)
		            		self.cost1:setEnabled(true)
		            		self.singleGem:setVisible(true)
		            		self.gemIcon1:setVisible(true)
			            end
				        if retTb.data.ConsumeType~=3 then
				            statisticsHelper:useItem("p47",1)
				        end
						local award=retTb.data.awards
						if award==nil or SizeOfTable(award)==0 then
							do return end
						end

						local awardTab=FormatItem(award)
						local item = awardTab[1]
						local awardType=item.type

						local rewardStrTab={}
						local rewardStr=""
		                if item and item.name and item.num then	
							rewardStr = item.name.." x"..item.num.."\n"..getlocal(item.desc)
							--[[if awardType=="p" and (tonumber(item.id)==5 or tonumber(item.id)==20 or tonumber(item.id)==2) then
								-- chatVoApi:sendSystemMessage(getlocal("chatSystemMessage5",{playerVoApi:getPlayerName(),item.name}))
								local pid="p"..item.id
	    						local prop=propCfg[pid]
	    						local nameData={key=prop.name,param={}}
								local message={key="chatSystemMessageDH",param={playerVoApi:getPlayerName(),nameData}}
	            				chatVoApi:sendSystemMessage(message)
							elseif awardType=="o" and ((tonumber(item.id)==10024 and item.num>=2) or (tonumber(item.id)==10034 and item.num>=2)) then
								-- chatVoApi:sendSystemMessage(getlocal("chatSystemMessage5",{playerVoApi:getPlayerName(),item.name.." x"..item.num}))
								local tank=tankCfg[item.id]
	        					local nameData={key=tank.name,param={}}
	        					local paramData={nameData,item.num}
	        					local msgData={key="item_number",param=paramData}
								local message={key="chatSystemMessageDH",param={playerVoApi:getPlayerName(),msgData}}
	                			chatVoApi:sendSystemMessage(message)
							end]]
						end

						local shuijingRes={u={gold=1000}}
						local shuijingTab=FormatItem(shuijingRes)
						table.insert(awardTab,shuijingTab[1])

						local rewardTab={awardTab[1],shuijingTab[1]}
						tipStr=G_showRewardTip(rewardTab,false)
						smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tipStr,28)

						local dataKey="dailiTwoDialog@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
						local coutNums =tonumber(CCUserDefault:sharedUserDefault():getStringForKey(dataKey))
						if  coutNums~=nil and tonumber(coutNums) <10 then
							coutNums=coutNums+1
							if  self.tenCountsLb ~=nil then
								self.tenCountsLb:setString(getlocal("dailyTenCounts",{coutNums}))
							end
						end		
						if coutNums ==nil then
							coutNums =0
						end
						local dataKey="dailiTwoDialog@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
						CCUserDefault:sharedUserDefault():setStringForKey(dataKey,tostring(coutNums))
						CCUserDefault:sharedUserDefault():flush()
					end	
				end
				local gems=nil
				if isFree==false and diffCoins<=0 then
					gems=15
				end
				socketHelper:luckygoods(1,isFree,gems,1,lotteryCommonCallback)
			else
				vipVoApi:showRechargeDialog(self.layerNum+1)
			end	
	end 
	self.clickItem1=GetButtonItem("BigBtnGreen.png","BigBtnGreen_Down.png","BigBtnGreen_Down.png",onClick1,11,getlocal("code_gift"),25,501)
	local clickItemBtn=CCMenu:createWithItem(self.clickItem1)
	clickItemBtn:setAnchorPoint(ccp(0.5,0))
	clickItemBtn:setPosition(ccp(backSprie:getContentSize().width*0.5,backSprie:getPositionY()-50))
	clickItemBtn:setTouchPriority(-(self.layerNum-1)*20-3)
	self.backSprie:addChild(clickItemBtn,1)

	self.cost1=GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",onClick1,11,getlocal("buyAndUsIt"),25,503)
	local cost1Btn=CCMenu:createWithItem(self.cost1)
	cost1Btn:setAnchorPoint(ccp(0.5,0))
	cost1Btn:setPosition(ccp(backSprie:getContentSize().width*0.5,backSprie:getPositionY()-50))
	cost1Btn:setTouchPriority(-(self.layerNum-1)*20-3)
	self.backSprie:addChild(cost1Btn,1)
	tolua.cast(self.cost1:getChildByTag(503),"CCLabelTTF"):setContentSize(CCSizeMake(135,72))
	tolua.cast(self.cost1:getChildByTag(503),"CCLabelTTF"):setPosition(ccp(120,58))

	self.singleGem =GetTTFLabel("15",25)
	self.singleGem:setAnchorPoint(ccp(0.5,0.5))
	self.singleGem:setPosition(ccp(backSprie:getContentSize().width*0.5-90,backSprie:getPositionY()-50))
	self.backSprie:addChild(self.singleGem,1)

	self.gemIcon1= CCSprite:createWithSpriteFrameName("IconGold.png")
	self.gemIcon1:setAnchorPoint(ccp(0.5,0.5))
	self.gemIcon1:setPosition(ccp(backSprie:getContentSize().width*0.5-55,backSprie:getPositionY()-50))
	self.backSprie:addChild(self.gemIcon1,1)

	local dataKey="dailiTwoDialog@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)-- upperTen_small
	local coutNums = tonumber(CCUserDefault:sharedUserDefault():getStringForKey(dataKey))

	if coutNums ==nil or tonumber(coutNums)<1 then
		coutNums =0
	end
	 self.tenCountsLb = GetTTFLabelWrap(getlocal("dailyTenCounts",{coutNums}),15,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	self.tenCountsLb:setAnchorPoint(ccp(0.5,0.5))
	self.tenCountsLb:setPosition(ccp(backSprie:getContentSize().width*0.9,backSprie:getPositionY()-30))
	self.backSprie:addChild(self.tenCountsLb,1)
	if playerVoApi:getPlayerLevel()>15 and base.isCheckVersion ==0 then
		self.tenCountsLb:setVisible(false)
	end

	local isFree=dailyVoApi:isFreeByType(1)

	local diffCoins=dailyVoApi:getLuckyCoins()
	local gemsSingle = playerVoApi:getGems() 
	if isFree then
		tolua.cast(self.clickItem1:getChildByTag(501),"CCLabelTTF"):setString(getlocal("daily_lotto_tip_2"))
		self.clickItem1:setVisible(true)
		self.clickItem1:setEnabled(true)
		self.cost1:setVisible(false)
		self.cost1:setEnabled(false)
		self.singleGem:setVisible(false)
		self.gemIcon1:setVisible(false)
	elseif diffCoins >0 then
		tolua.cast(self.clickItem1:getChildByTag(501),"CCLabelTTF"):setString(getlocal("code_gift"))
		self.clickItem1:setVisible(true)
		self.clickItem1:setEnabled(true)
		self.cost1:setVisible(false)
		self.cost1:setEnabled(false)
		self.singleGem:setVisible(false)
		self.gemIcon1:setVisible(false)
	else
		tolua.cast(self.clickItem1:getChildByTag(501),"CCLabelTTF"):setString(getlocal("buyAndUsIt"))
		local gemsSingle = playerVoApi:getGems()
		if gemsSingle <15 then
			self.singleGem:setColor(G_ColorRed)
		end
		self.clickItem1:setVisible(false)
		self.clickItem1:setEnabled(false)
		self.cost1:setVisible(true)
		self.cost1:setEnabled(true)
		self.singleGem:setVisible(true)
		self.gemIcon1:setVisible(true)
	end		
	--------------

	local function bgClick2()
	end
	local backSprie2 = LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(63, 28, 1, 1),bgClick2)
	backSprie2:setContentSize(CCSizeMake(self.backSprie:getContentSize().width-2, self.backSprie:getContentSize().height*0.25))
	backSprie2:setAnchorPoint(ccp(0.5,1))
	backSprie2:setPosition(ccp(self.backSprie:getContentSize().width*0.5,self.backSprie:getContentSize().height*0.4))
	self.backSprie:addChild(backSprie2)

	local ShapeGift2 = CCSprite:createWithSpriteFrameName("ShapeGift.png")
	ShapeGift2:setAnchorPoint(ccp(0.5,0.5))
	ShapeGift2:setPosition(ccp(backSprie2:getContentSize().width*0.5,backSprie2:getContentSize().height+20))
	backSprie2:addChild(ShapeGift2,1)

	local ShapeTank2 = CCSprite:createWithSpriteFrameName("ShapeTank.png")
	ShapeTank2:setAnchorPoint(ccp(0.5,0.5))
	ShapeTank2:setPosition(ccp(backSprie2:getContentSize().width*0.5,backSprie2:getContentSize().height+20))
	backSprie2:addChild(ShapeTank2,1)

	self.bigGoldIcon =CCSprite:createWithSpriteFrameName("item_baoxiang_37.png")
	self.bigGoldIcon:setAnchorPoint(ccp(0,0.5))
	self.bigGoldIcon:setPosition(ccp(backSprie2:getContentSize().width*0.05,backSprie2:getContentSize().height*0.5-20))
	backSprie2:addChild(self.bigGoldIcon,1)
	self.bigGoldIcon:setScale(1.2)

	self.seniorExchange = GetTTFLabelWrap(getlocal("exchangeSenior"),28,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	self.seniorExchange:setAnchorPoint(ccp(0,0))
	self.seniorExchange:setPosition(self.bigGoldIcon:getPositionX(),self.bigGoldIcon:getPositionY()+self.bigGoldIcon:getContentSize().height*0.5+10)
	backSprie2:addChild(self.seniorExchange,1)
	self.seniorExchange:setColor(G_ColorGreen)

	local reward=FormatItem(playerCfg.mustReward2.reward)
	local rewardStr=""
	for k,v in pairs(reward) do
		rewardStr=rewardStr..v.name.."×"..FormatNumber(v.num).." "
	end
	self.seniorExchangeDes = GetTTFLabelWrap(getlocal("exchangeSeniorDes",{rewardStr}),23,CCSizeMake(430,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	self.seniorExchangeDes:setAnchorPoint(ccp(0,0.5))
	self.seniorExchangeDes:setPosition(ccp(backSprie2:getContentSize().width*0.05+130,backSprie2:getContentSize().height*0.5))
	backSprie2:addChild(self.seniorExchangeDes,1)

	local function onClick2( )
		local isFree=dailyVoApi:isFreeByType(2)
		local diffCoins2=dailyVoApi:getLuckyCoins()
		local gemsSingle = playerVoApi:getGems()

		local dataKey="dailiTwoDialog2@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
		local coutNums2 =tonumber(CCUserDefault:sharedUserDefault():getStringForKey(dataKey))
		if G_getBHVersion()==2 and base.isCheckVersion == 1 and coutNums2~=nil and coutNums2 >=10 then
				smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("upperTen"),nil,self.layerNum+1)
				do return end
		end
			if isFree or diffCoins2>2 or gemsSingle>=45 or (diffCoins2==2 and gemsSingle>=15) or (diffCoins2==1 and gemsSingle>=30) then		
				local function lotteryCommonCallback(fn,data)
	                local success,retTb=base:checkServerData(data)
					if success==true and retTb~=nil then
			                    --统计使用物品
			            if diffCoins2>= 3 then
			            	tolua.cast(self.clickItem2:getChildByTag(502),"CCLabelTTF"):setString(getlocal("code_gift"))
							self.clickItem2:setVisible(true)
							self.clickItem2:setEnabled(true)
							self.cost2:setVisible(false)
							self.cost2:setEnabled(false)
							self.lotGem:setVisible(false)
							self.gemIcon2:setVisible(false)
			            end

						if diffCoins2 <=2 then
							tolua.cast(self.clickItem2:getChildByTag(502),"CCLabelTTF"):setString(getlocal("buyAndUsIt"))
							local gemsSingle = playerVoApi:getGems()
							if gemsSingle <15 then
								self.lotGem:setColor(G_ColorRed)
							end
							self.lotGem:setString("15")
							self.clickItem2:setVisible(false)
							self.clickItem2:setEnabled(false)
							self.cost2:setVisible(true)
							self.cost2:setEnabled(true)
							self.lotGem:setVisible(true)
							self.gemIcon2:setVisible(true)
							if diffCoins2 ==1 then
								if gemsSingle <30 then
									self.lotGem:setColor(G_ColorRed)
								end
								self.lotGem:setString("30")
							elseif diffCoins2<1 then
								if gemsSingle <45 then
									self.lotGem:setColor(G_ColorRed)
								end
								self.lotGem:setString("45")
							end
			            end
			            -- ConsumeType： 1是纯道具，2是道具加金币，3是免费
				        if retTb.data.ConsumeType~=3 then
				            statisticsHelper:useItem("p47",1)
				        end
						local award=retTb.data.awards
						if award==nil or SizeOfTable(award)==0 then
							do return end
						end
						
						local awardTab=FormatItem(award)
						local item = awardTab[1]
						local awardType=item.type

						local rewardStrTab={}
						local rewardStr=""
		                if item and item.name and item.num then	
							rewardStr = item.name.." x"..item.num.."\n"..getlocal(item.desc)
							--[[if awardType=="p" and (tonumber(item.id)==5 or tonumber(item.id)==20 or tonumber(item.id)==2) then
								-- chatVoApi:sendSystemMessage(getlocal("chatSystemMessage5",{playerVoApi:getPlayerName(),item.name}))
								local pid="p"..item.id
	    						local prop=propCfg[pid]
	    						local nameData={key=prop.name,param={}}
								local message={key="chatSystemMessageDH",param={playerVoApi:getPlayerName(),nameData}}
	            				chatVoApi:sendSystemMessage(message)
							elseif awardType=="o" and ((tonumber(item.id)==10024 and item.num>=2) or (tonumber(item.id)==10034 and item.num>=2)) then
								-- chatVoApi:sendSystemMessage(getlocal("chatSystemMessage5",{playerVoApi:getPlayerName(),item.name.." x"..item.num}))
								local tank=tankCfg[item.id]
	        					local nameData={key=tank.name,param={}}
	        					local paramData={nameData,item.num}
	        					local msgData={key="item_number",param=paramData}
								local message={key="chatSystemMessageDH",param={playerVoApi:getPlayerName(),msgData}}
	                			chatVoApi:sendSystemMessage(message)
							end]]
						end
						local shuijingRes={u={gold=10000}}
						local shuijingTab=FormatItem(shuijingRes)
						table.insert(awardTab,shuijingTab[1])
						local rewardTab={awardTab[1],shuijingTab[1]}
						tipStr=G_showRewardTip(rewardTab,false)
						smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tipStr,28)

						local dataKey="dailiTwoDialog2@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
						local coutNums2 = tonumber(CCUserDefault:sharedUserDefault():getStringForKey(dataKey))
						if  coutNums2 ~=nil and tonumber(coutNums2) <10 then
							coutNums2=coutNums2+1
							if  self.tenCountsLb2 ~=nil then
								self.tenCountsLb2:setString(getlocal("dailyTenCounts",{coutNums2}))
							end
						end	
						if coutNums2 ==nil then
							coutNums2 =0
						end
						local dataKey="dailiTwoDialog2@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
						CCUserDefault:sharedUserDefault():setStringForKey(dataKey,tostring(coutNums2))
						CCUserDefault:sharedUserDefault():flush()
	
					end	
				end
				local gems=nil
				if isFree==false and diffCoins2<=2 then
					if diffCoins2==1 then
						gems=30
					elseif diffCoins2==2 then
						gems=15
					else
						gems=45
					end
				end
				socketHelper:luckygoods(2,isFree,gems,1,lotteryCommonCallback)
			else
				vipVoApi:showRechargeDialog(self.layerNum+1)
			end	

	end 
	self.clickItem2=GetButtonItem("BigBtnGreen.png","BigBtnGreen_Down.png","BigBtnGreen_Down.png",onClick2,33,getlocal("code_gift"),25,502)
	local clickItemBtn2=CCMenu:createWithItem(self.clickItem2)
	clickItemBtn2:setAnchorPoint(ccp(0.5,1))
	clickItemBtn2:setPosition(ccp(backSprie2:getContentSize().width*0.5,backSprie2:getPositionY()-backSprie2:getContentSize().height-50))
	clickItemBtn2:setTouchPriority(-(self.layerNum-1)*20-3)
	self.backSprie:addChild(clickItemBtn2,1)

	self.cost2=GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",onClick2,11,getlocal("buyAndUsIt"),25,504)
	local cost2Btn=CCMenu:createWithItem(self.cost2)
	cost2Btn:setAnchorPoint(ccp(0.5,0))
	cost2Btn:setPosition(ccp(backSprie2:getContentSize().width*0.5,backSprie2:getPositionY()-backSprie2:getContentSize().height-50))
	cost2Btn:setTouchPriority(-(self.layerNum-1)*20-3)
	self.backSprie:addChild(cost2Btn,1)
	tolua.cast(self.cost2:getChildByTag(504),"CCLabelTTF"):setContentSize(CCSizeMake(135,72))
	tolua.cast(self.cost2:getChildByTag(504),"CCLabelTTF"):setPosition(ccp(120,58))

	self.lotGem =GetTTFLabel(getlocal("45"),25)
	self.lotGem:setAnchorPoint(ccp(0.5,0.5))
	self.lotGem:setPosition(ccp(backSprie2:getContentSize().width*0.5-90,backSprie2:getPositionY()-backSprie2:getContentSize().height-50))
	self.backSprie:addChild(self.lotGem,1)
	self.lotGem:setVisible(false)

	self.gemIcon2= CCSprite:createWithSpriteFrameName("IconGold.png")
	self.gemIcon2:setAnchorPoint(ccp(0.5,0.5))
	self.gemIcon2:setPosition(ccp(backSprie2:getContentSize().width*0.5-55,backSprie2:getPositionY()-backSprie2:getContentSize().height-50))
	self.backSprie:addChild(self.gemIcon2,1)
	self.gemIcon2:setVisible(false)

	local dataKey="dailiTwoDialog2@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)-- upperTen_small
	local coutNums2 = tonumber(CCUserDefault:sharedUserDefault():getStringForKey(dataKey))

	if coutNums2 ==nil or tonumber(coutNums2)<1 then
		coutNums2 =0
	end
	 self.tenCountsLb2 = GetTTFLabelWrap(getlocal("dailyTenCounts",{coutNums2}),15,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	self.tenCountsLb2:setAnchorPoint(ccp(0.5,0.5))
	self.tenCountsLb2:setPosition(ccp(backSprie:getContentSize().width*0.9,backSprie2:getPositionY()-backSprie2:getContentSize().height-30))
	self.backSprie:addChild(self.tenCountsLb2,1)
	if playerVoApi:getPlayerLevel()>15 and base.isCheckVersion ==0 then
		self.tenCountsLb2:setVisible(false)
	end

	local unlockLevel=dailyVoApi:getUnlockLevel()
	local isfree,isVipFree=dailyVoApi:isFreeByType(2)
	local diffCoins2=dailyVoApi:getLuckyCoins()
	local gemsSingle2= playerVoApi:getGems()
	if playerVoApi:getPlayerLevel()<unlockLevel then
		self.clickItem2:setEnabled(false)
		self.cost2:setVisible(false)
		self.cost2:setEnabled(false)
		self.lotGem:setVisible(false)
		self.gemIcon2:setVisible(false)
		tolua.cast(self.clickItem2:getChildByTag(502),"CCLabelTTF"):setString(getlocal("exchangeGrade"))
	else
		if isVipFree then
			tolua.cast(self.clickItem2:getChildByTag(502),"CCLabelTTF"):setString(getlocal("daily_lotto_tip_2"))
			self.clickItem2:setVisible(true)
			self.clickItem2:setEnabled(true)
			self.cost2:setVisible(false)
			self.cost2:setEnabled(false)
			self.lotGem:setVisible(false)
			self.gemIcon2:setVisible(false)
		elseif diffCoins2 >2 then
			tolua.cast(self.clickItem2:getChildByTag(502),"CCLabelTTF"):setString(getlocal("code_gift"))
			self.clickItem2:setVisible(true)
			self.clickItem2:setEnabled(true)
			self.cost2:setVisible(false)
			self.cost2:setEnabled(false)
			self.lotGem:setVisible(false)
			self.gemIcon2:setVisible(false)
		elseif diffCoins2 <=2 then
			tolua.cast(self.clickItem2:getChildByTag(502),"CCLabelTTF"):setString(getlocal("buyAndUsIt"))
			local gemsSingle = playerVoApi:getGems()
			if gemsSingle <15 then
				self.lotGem:setColor(G_ColorRed)
			end
			self.lotGem:setString("15")
			self.clickItem2:setVisible(false)
			self.clickItem2:setEnabled(false)
			self.cost2:setVisible(true)
			self.cost2:setEnabled(true)
			self.lotGem:setVisible(true)
			self.gemIcon2:setVisible(true)
			if diffCoins2 ==1 then
				if gemsSingle <30 then
					self.lotGem:setColor(G_ColorRed)
				end
				self.lotGem:setString("30")
			elseif diffCoins2<1 then
				if gemsSingle <45 then
					self.lotGem:setColor(G_ColorRed)
				end
				self.lotGem:setString("45")
			end
		end			
	end
----
	-- self.gradeExchange = GetTTFLabelWrap(getlocal("exchangeGrade"),23,CCSizeMake(400,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	-- self.gradeExchange:setAnchorPoint(ccp(0.5,0))
	-- self.gradeExchange:setPosition(ccp(backSprie2:getContentSize().width*0.5,16))
	-- backSprie2:addChild(self.gradeExchange,1)
	-- if playerVoApi:getPlayerLevel()<unlockLevel then
	-- 	self.gradeExchange:setColor(G_ColorRed)	
	-- else
	-- 	self.gradeExchange:setColor(G_ColorWhite)
	-- end


end

function dailyTwoDialog:tick( ... )
	if dailyVoApi:is_Today() ==false then
		local coutNums2 =0
		if  self.tenCountsLb2 ~=nil then
			self.tenCountsLb2:setString(getlocal("dailyTenCounts",{coutNums2}))
		end
		local dataKey="dailiTwoDialog2@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
		CCUserDefault:sharedUserDefault():setStringForKey(dataKey,tostring(coutNums2))
		CCUserDefault:sharedUserDefault():flush()
	else
		local dataKey="dailiTwoDialog2@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
		local coutNums2 =tonumber(CCUserDefault:sharedUserDefault():getStringForKey(dataKey))
		if coutNums2 ==nil then
			coutNums2 =0
		end
		if self.tenCountsLb2 ~=nil then
			self.tenCountsLb2:setString(getlocal("dailyTenCounts",{coutNums2}))
		end
	end		


	local isFree=dailyVoApi:isFreeByType(1)
	if isFree ==true then
		self.clickItem1:setVisible(true)
		self.clickItem1:setEnabled(true)
		self.cost1:setVisible(false)
		self.cost1:setEnabled(false)
		self.singleGem:setVisible(false)
		self.gemIcon1:setVisible(false)
		tolua.cast(self.clickItem1:getChildByTag(501),"CCLabelTTF"):setString(getlocal("daily_lotto_tip_2"))

		local coutNums =0
		if  self.tenCountsLb ~=nil then
			self.tenCountsLb:setString(getlocal("dailyTenCounts",{coutNums}))
		end
		local dataKey="dailiTwoDialog@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
		CCUserDefault:sharedUserDefault():setStringForKey(dataKey,tostring(coutNums))
		CCUserDefault:sharedUserDefault():flush()

	else
		local dataKey="dailiTwoDialog@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
		local coutNums =tonumber(CCUserDefault:sharedUserDefault():getStringForKey(dataKey))
		if coutNums ==nil then
			coutNums =0
		end
		if self.tenCountsLb then
			self.tenCountsLb:setString(getlocal("dailyTenCounts",{coutNums}))
		end

		tolua.cast(self.clickItem1:getChildByTag(501),"CCLabelTTF"):setString(getlocal("code_gift"))
		local diffCoins=dailyVoApi:getLuckyCoins()
		--判断幸运币是否够
		if diffCoins<=0 then
			tolua.cast(self.clickItem1:getChildByTag(501),"CCLabelTTF"):setString(getlocal("buyAndUsIt"))
			local gemsSingle = playerVoApi:getGems()
			if gemsSingle <15 then
				self.singleGem:setColor(G_ColorRed)
			else
				self.singleGem:setColor(G_ColorWhite)
			end
			self.clickItem1:setVisible(false)
			self.clickItem1:setEnabled(false)
			self.cost1:setVisible(true)
			self.cost1:setEnabled(true)
			self.singleGem:setVisible(true)
			self.gemIcon1:setVisible(true)
		else
			tolua.cast(self.clickItem1:getChildByTag(501),"CCLabelTTF"):setString(getlocal("code_gift"))
			self.clickItem1:setVisible(true)
			self.clickItem1:setEnabled(true)
			self.cost1:setVisible(false)
			self.cost1:setEnabled(false)
			self.singleGem:setVisible(false)
			self.gemIcon1:setVisible(false)
		end
	end
	local diffCoins2=dailyVoApi:getLuckyCoins()
	local isFree2,isVipFree=dailyVoApi:isFreeByType(2)
	local unlockLevel=dailyVoApi:getUnlockLevel()
	if playerVoApi:getPlayerLevel()>=unlockLevel then
		if isFree2 then

			self.clickItem2:setEnabled(true)
			self.clickItem2:setVisible(true)
			tolua.cast(self.clickItem2:getChildByTag(502),"CCLabelTTF"):setString(getlocal("daily_lotto_tip_2"))
			self.lotGem:setVisible(false)
			self.gemIcon2:setVisible(false)
			self.cost2:setVisible(false)
			self.lotGem:setVisible(false)
		else
			local diffCoins=dailyVoApi:getLuckyCoins()
			if diffCoins2 >2 then
				tolua.cast(self.clickItem2:getChildByTag(502),"CCLabelTTF"):setString(getlocal("code_gift"))
				self.clickItem2:setVisible(true)
				self.clickItem2:setEnabled(true)
				self.cost2:setVisible(false)
				self.cost2:setEnabled(false)
				self.lotGem:setVisible(false)
				self.gemIcon2:setVisible(false)
			elseif diffCoins2 <=2 then
				tolua.cast(self.clickItem2:getChildByTag(502),"CCLabelTTF"):setString(getlocal("buyAndUsIt"))
				local gemsSingle = playerVoApi:getGems()
				if gemsSingle <15 then
					self.lotGem:setColor(G_ColorRed)
				end
				self.lotGem:setString("15")
				self.clickItem2:setVisible(false)
				self.clickItem2:setEnabled(false)
				self.cost2:setVisible(true)
				self.cost2:setEnabled(true)
				self.lotGem:setVisible(true)
				self.gemIcon2:setVisible(true)
				if diffCoins2 ==1 then
					if gemsSingle <30 then
						self.lotGem:setColor(G_ColorRed)
					end
					self.lotGem:setString("30")
				elseif diffCoins2<1 then
					if gemsSingle <45 then
						self.lotGem:setColor(G_ColorRed)
					end
					self.lotGem:setString("45")
				end
			end
		end
	end
	local diffCoins2=dailyVoApi:getLuckyCoins()
	if diffCoins2<0 then
		diffCoins2 =0
	end
	tolua.cast(self.luckGems,"CCLabelTTF"):setString(getlocal("exchangeAllLuckGem",{diffCoins2}))
end


function dailyTwoDialog:dispose()
	self.characterSp=nil
	self.descBg=nil
	self.descLabel=nil
	self.backSprie=nil
	self.commonBoxTab=nil
	self.seniorBoxTab=nil
	self.canClick=nil
	self.maskSp=nil
	self.freeBtn=nil
	self.playBtn=nil
	self.buyAndPlayBtn=nil
	self.costDescLabel=nil
	self.selectedBox=nil
	self.unlockSp=nil
	self.goldSp=nil
	self.gemsLabel=nil
	self.unlockLabel=nil

	self.tenCountsLb=nil
	self.tenCountsLb2=nil
    self=nil

end




