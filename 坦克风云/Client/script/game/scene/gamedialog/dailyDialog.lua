--require "luascript/script/componet/commonDialog"
require "luascript/script/game/gamemodel/daily/dailyVoApi"

dailyDialog=commonDialog:new()

function dailyDialog:new()
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
	self.rewardLevelLabel=nil
	self.rewardValueLabel=nil
	self.isFree1=false
	self.isFree2=false

    return nc
end

--设置或修改每个Tab页签
function dailyDialog:resetTab()
    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v
         if index==0 then
         	tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         elseif index==1 then
         	tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end 
         index=index+1
    end
end

--设置对话框里的tableView
function dailyDialog:initTableView()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-20,self.bgLayer:getContentSize().height-125),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    --self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    --self.tv:setPosition(ccp(10,40))
    --self.bgLayer:addChild(self.tv,1)
    --self.tv:setMaxDisToBottomOrTop(140)
	--self.panelLineBg:setVisible(false)

	self:doUserHandler()
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function dailyDialog:eventHandler(handler,fn,idx,cel)
	do return end	
end

--用户处理特殊需求,没有可以不写此方法
function dailyDialog:doUserHandler()
	local btnHeight=150
	local dailyVo=dailyVoApi:getDailyVo(self.selectedTabIndex+1)
	local function touch()
	end
	local capInSet = CCRect(20, 20, 10, 10)

	local rewardLevel,levelMax = dailyVoApi:getRewardLevel()

	if self.characterSp==nil then
        if platCfg.platCfgChangeGuideUI[G_curPlatName()] then
            self.characterSp=CCSprite:create("public/guide.png")
        else
            self.characterSp=CCSprite:createWithSpriteFrameName("GuideCharacter.png")
        end
		self.characterSp:setAnchorPoint(ccp(0,0))
		self.characterSp:setPosition(ccp(40,self.bgLayer:getContentSize().height-430))
		self.bgLayer:addChild(self.characterSp,2)
	end
	if self.descBg==nil then
	    self.descBg =LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",capInSet,touch)
	    self.descBg:setContentSize(CCSizeMake(370, 200))
	    self.descBg:setAnchorPoint(ccp(0,0))
	    self.descBg:setPosition(ccp(235,self.bgLayer:getContentSize().height-410))
	    self.bgLayer:addChild(self.descBg,1)
	end
	local offsety = 0
	if G_getCurChoseLanguage()~="cn" and G_getCurChoseLanguage()~="tw" then
		offsety = 15
	end
	if  self.rewardLevelLabel == nil then
		local str 
		if rewardLevel < levelMax then
			str = getlocal("rewardUpdateNeedLevel",{playerCfg.levelGroup[rewardLevel+1]})
		else
			str = getlocal("rewardUpdateMaxLevel",{playerCfg.levelGroup[levelMax]})
		end
		local textWidth,strSize,posY = self.descBg:getContentSize().width-100,20,G_VisibleSizeHeight-400
		if G_getCurChoseLanguage()~="cn" and G_getCurChoseLanguage()~="tw" then
			textWidth,strSize,posY=self.descBg:getContentSize().width-60,18,G_VisibleSizeHeight-425
		end
		local rewardLevelLabel=GetTTFLabelWrap(str,strSize,CCSizeMake(textWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		-- local rewardLevelLabel = GetTTFLabel(str,20)
		rewardLevelLabel:setAnchorPoint(ccp(0,0))
		rewardLevelLabel:setPosition(ccp(290,posY+offsety))
		rewardLevelLabel:setColor(G_ColorYellowPro)
		self.rewardLevelLabel = rewardLevelLabel
		self.bgLayer:addChild(rewardLevelLabel,2)
	end

	if self.rewardValueLabel == nil then
		local posY,strSize = G_VisibleSizeHeight-350,20
		if G_getCurChoseLanguage()~="cn" and G_getCurChoseLanguage()~="tw" then
			posY = G_VisibleSizeHeight-375
			if G_isIOS()==false then
				strSize=17
			end
		end
		local value = dailyVoApi:getGemValue(self.selectedTabIndex+1)
		local rewardValueLabel = GetTTFLabelWrap(getlocal("luckyBoxValue",{value}),strSize,CCSizeMake(self.descBg:getContentSize().width-55,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		-- local rewardValueLabel = GetTTFLabel(getlocal("luckyBoxValue",{value}),20)
		rewardValueLabel:setAnchorPoint(ccp(0,0))
		rewardValueLabel:setPosition(ccp(290,posY+offsety))
		rewardValueLabel:setColor(G_ColorGreen)
		self.rewardValueLabel=rewardValueLabel
		self.bgLayer:addChild(rewardValueLabel,2)
	else
		if self.selectedTabIndex==0 then
			tolua.cast(self.rewardValueLabel,"CCLabelTTF"):setString(getlocal("luckyBoxValue",{dailyVoApi:getGemValue(self.selectedTabIndex+1)}))
		elseif self.selectedTabIndex==1 then
			tolua.cast(self.rewardValueLabel,"CCLabelTTF"):setString(getlocal("luckyBoxValue",{dailyVoApi:getGemValue(self.selectedTabIndex+1)}))
		end
	end

	if self.descLabel==nil then
		local textWidth,posX,posY = self.descBg:getContentSize().width-100,90,self.descBg:getContentSize().height-60*1.5+30
		local strSize = 21
		if G_getCurChoseLanguage()~="cn" and G_getCurChoseLanguage()~="tw" then
			textWidth,posX,posY = self.descBg:getContentSize().width-60,55,self.descBg:getContentSize().height-60*1.5+20
			strSize=18
		end
		if(base.hexieMode==1)then
			local reward=FormatItem(playerCfg.mustReward1.reward)
			local rewardStr
			for k,v in pairs(reward) do
				rewardStr=v.name.."×"..FormatNumber(v.num)
			end
			self.descLabel=GetTTFLabelWrap(getlocal("lotteryCommonDesc2",{1,rewardStr}),strSize,CCSizeMake(textWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		else
			self.descLabel=GetTTFLabelWrap(getlocal("lotteryCommonDesc"),strSize,CCSizeMake(textWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		end
	    self.descLabel:setAnchorPoint(ccp(0,0.5))
	    self.descLabel:setPosition(ccp(posX,posY+offsety))
	    self.descBg:addChild(self.descLabel,1)
		self.descLabel:setColor(G_ColorGreen)
	else
		if self.selectedTabIndex==0 then
			tolua.cast(self.descLabel,"CCLabelTTF"):setString(getlocal("lotteryCommonDesc"))
		elseif self.selectedTabIndex==1 then
			if(base.hexieMode==1)then
				local reward=FormatItem(playerCfg.mustReward2.reward)
				local rewardStr
				for k,v in pairs(reward) do
					rewardStr=v.name.."×"..FormatNumber(v.num)
				end
				tolua.cast(self.descLabel,"CCLabelTTF"):setString(getlocal("lotteryCommonDesc2",{3,rewardStr}))
			else
				tolua.cast(self.descLabel,"CCLabelTTF"):setString(getlocal("lotterySeniorDesc"))
			end
		end
	end
	if self.backSprie==nil then
	    --self.backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,touch)
		self.backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),touch)
	    self.backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,self.bgLayer:getContentSize().height-470))
	    self.backSprie:setAnchorPoint(ccp(0,0))
	    self.backSprie:setPosition(ccp(30,40))
	    self.bgLayer:addChild(self.backSprie,1)
	end
	
	if self.maskSp==nil then
		local function tmpFunc()
	    end
	    self.maskSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),tmpFunc)
	    self.maskSp:setOpacity(255)
	    local size=CCSizeMake(self.backSprie:getContentSize().width,self.backSprie:getContentSize().height-25)
	    self.maskSp:setContentSize(size)
	    self.maskSp:setAnchorPoint(ccp(0.5,0.5))
	    self.maskSp:setPosition(ccp(self.backSprie:getContentSize().width/2,self.backSprie:getContentSize().height/2+5))
		self.maskSp:setIsSallow(true)
		self.maskSp:setTouchPriority(-(self.layerNum-1)*20-4)
	    self.backSprie:addChild(self.maskSp,2)
	else
		self.maskSp:setVisible(true)
		self.maskSp:setPosition(ccp(self.backSprie:getContentSize().width/2,self.backSprie:getContentSize().height/2+5))
	end
	if self.costDescLabel==nil then
		local costStr
		if(base.hexieMode==1)then
			local reward=FormatItem(playerCfg.mustReward1.reward)
			local rewardStr
			for k,v in pairs(reward) do
				rewardStr=v.name.."×"..FormatNumber(v.num)
			end
			costStr=getlocal("exchangePrimaryDes",{rewardStr})
		else
			costStr=getlocal("lotteryCostDesc",{dailyVo.cost}).."\n"
		end
		--[[
		local luckyCoins=dailyVoApi:getLuckyCoins()
		if luckyCoins==0 then
			costStr=costStr..getlocal("lotteryGemsDesc",{dailyVoApi:getGemsCost(self.selectedTabIndex+1)}).."\n"
		end
		]]
		local strSize2 = 25
		if G_getCurChoseLanguage() =="it" then
			strSize2 = 21
		end
		costStr=costStr..getlocal("lotteryHasDesc",{dailyVoApi:getLuckyCoins()})
		self.costDescLabel=GetTTFLabelWrap(costStr,strSize2,CCSizeMake(self.maskSp:getContentSize().width-120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	    self.costDescLabel:setAnchorPoint(ccp(0.5,0.5))
	    self.costDescLabel:setPosition(ccp(self.maskSp:getContentSize().width/2,320))
	    self.maskSp:addChild(self.costDescLabel,1)
	else
		local costStr
		if(base.hexieMode==1)then
			local rewardCfg
			local key
			if(dailyVo.cost==1)then
				rewardCfg=playerCfg.mustReward1.reward
				key="exchangePrimaryDes"
			else
				rewardCfg=playerCfg.mustReward2.reward
				key="exchangeSeniorDes"
			end
			local reward=FormatItem(rewardCfg)
			local rewardStr
			for k,v in pairs(reward) do
				rewardStr=v.name.."×"..FormatNumber(v.num)
			end
			costStr=getlocal(key,{rewardStr}).."\n"
		else
			costStr=getlocal("lotteryCostDesc",{dailyVo.cost}).."\n"
		end
		--[[
		local luckyCoins=dailyVoApi:getLuckyCoins()
		if luckyCoins==0 then
			costStr=costStr..getlocal("lotteryGemsDesc",{dailyVoApi:getGemsCost(self.selectedTabIndex+1)}).."\n"
		end
		]]
		costStr=costStr..getlocal("lotteryHasDesc",{dailyVoApi:getLuckyCoins()})
		self.costDescLabel:setString(costStr)
		self.costDescLabel:setPosition(ccp(self.maskSp:getContentSize().width/2,320))
		self.costDescLabel:setVisible(true)
	end
	if self.selectedBox~=nil then
		self.selectedBox:removeFromParentAndCleanup(true)
		self.selectedBox=nil
	end
	
	local unlockLevel=dailyVoApi:getUnlockLevel()
	self:setLockVisibleByIdx(false,2)
	if playerVoApi:getPlayerLevel()<unlockLevel then
		self:setLockVisibleByIdx(true,2)
		if self.selectedTabIndex==1 then
			self.characterSp:setVisible(false)
		    self.descBg:setVisible(false)
			self.backSprie:setVisible(false)
			self.maskSp:setVisible(false)
			self.rewardLevelLabel:setVisible(false)
			self.rewardValueLabel:setVisible(false)
			
			if self.unlockLabel==nil then
				local unlockStr=getlocal("lotteryUnlock",{unlockLevel})
				self.unlockLabel=GetTTFLabelWrap(unlockStr,25,CCSizeMake(self.maskSp:getContentSize().width-50,120),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
			    self.unlockLabel:setAnchorPoint(ccp(0.5,0.5))
			    self.unlockLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-50))
			    self.bgLayer:addChild(self.unlockLabel,1)
			else
				self.unlockLabel:setVisible(true)
			end
			--[[
			if self.unlockSp==nil then
				local function tmpFunc()
			    end
			    self.unlockSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),tmpFunc)
			    self.unlockSp:setOpacity(255)
			    local size=CCSizeMake(self.backSprie:getContentSize().width,200)
			    self.unlockSp:setContentSize(size)
			    self.unlockSp:setAnchorPoint(ccp(0,0))
			    self.unlockSp:setPosition(ccp(30,self.bgLayer:getContentSize().height-410))
			    self.bgLayer:addChild(self.unlockSp,2)
				self.unlockSp:setVisible(true)
		
				local unlockStr=getlocal("lotteryUnlock",{unlockLevel})
				self.unlockLabel=GetTTFLabelWrap(unlockStr,25,CCSizeMake(self.maskSp:getContentSize().width-50,120),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
			    self.unlockLabel:setAnchorPoint(ccp(0.5,0.5))
			    self.unlockLabel:setPosition(ccp(self.unlockSp:getContentSize().width/2,self.unlockSp:getContentSize().height/2))
			    self.unlockSp:addChild(self.unlockLabel,1)
			else
				self.unlockSp:setVisible(true)
			end
			]]
			do return end
		end
	else
		if self.selectedTabIndex==1 then
			self:setTabBtnEffect(false,2)
		else
			self:setTabBtnEffect(true,2)
		end
	end

	self.characterSp:setVisible(true)
    self.descBg:setVisible(true)
	self.backSprie:setVisible(true)
	self.rewardLevelLabel:setVisible(true)
	self.rewardValueLabel:setVisible(true)
	if self.unlockLabel then
		self.unlockLabel:setVisible(false)
	end
	
	local function btnCallback(tag,object)
        PlayEffect(audioCfg.mouseClick)
		if tag>=4 then			--抽奖结束 确定按钮
			self:doUserHandler()
		else
			if tag==1 then		--免费
				self.maskSp:setVisible(false)
				self.maskSp:setPosition(ccp(10000,0))
				self.descLabel:setString(getlocal("lotteryBeginDesc"))
			elseif tag==2 then	--花费幸运币
				if dailyVoApi:coinLessNum(self.selectedTabIndex+1)>0 then
					do return end
				end
				self.maskSp:setVisible(false)
				self.maskSp:setPosition(ccp(10000,0))
				--self.descLabel:setString(getlocal("lotteryBeginDesc"))
				local dailyVo=dailyVoApi:getDailyVo(self.selectedTabIndex+1)
				if(base.hexieMode==1)then
					self.descLabel:setString(getlocal("lotteryBeginCostDescHexie",{dailyVo.cost,dailyVoApi:getLuckyCoins()}))
				else
					self.descLabel:setString(getlocal("lotteryBeginCostDesc",{dailyVo.cost,dailyVoApi:getLuckyCoins()}))
				end
			elseif tag==3 then	--花费金币
				local diffGems=dailyVoApi:gemLessNum(self.selectedTabIndex+1)
				if diffGems>0 then
					local gemsCost=dailyVoApi:getGemsCost(self.selectedTabIndex+1)
					GemsNotEnoughDialog(nil,nil,diffGems,self.layerNum+1,gemsCost)
					do return end
				else
					local coinLessNum=dailyVoApi:coinLessNum(self.selectedTabIndex+1)
					if coinLessNum>0 then
						local function callbackBuyprop(fn,data)
		                    if base:checkServerData(data)==true then
                                --统计购买物品
                                statisticsHelper:buyItem("p47",propCfg["p47"].gemCost,coinLessNum,tonumber(propCfg["p47"].gemCost)*coinLessNum)
								if self.maskSp==nil then
									do return end
								end
								self.maskSp:setVisible(false)
								self.maskSp:setPosition(ccp(10000,0))
								--self.descLabel:setString(getlocal("lotteryBeginDesc"))
								local dailyVo=dailyVoApi:getDailyVo(self.selectedTabIndex+1)
								if(base.hexieMode==1)then
									self.descLabel:setString(getlocal("lotteryBeginCostDescHexie",{dailyVo.cost,dailyVoApi:getLuckyCoins()}))
								else
									self.descLabel:setString(getlocal("lotteryBeginCostDesc",{dailyVo.cost,dailyVoApi:getLuckyCoins()}))
								end
		                    end
		                end
		                socketHelper:buyProc(47,callbackBuyprop,coinLessNum)
					end
				end
			end
			
		end
	end
	
	if self.freeBtn==nil then
		if(base.hexieMode==1)then
			self.freeBtn=GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",btnCallback,1,getlocal("daily_lotto_tip_2"),25,501)
		else
			self.freeBtn=GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",btnCallback,1,getlocal("lotteryBtnFree"),25,501)
		end
	    self.freeBtn:setAnchorPoint(ccp(0.5,0.5))
	    local boxSpMenu=CCMenu:createWithItem(self.freeBtn)
	    boxSpMenu:setPosition(ccp(self.maskSp:getContentSize().width/2,btnHeight))
	    boxSpMenu:setTouchPriority(-(self.layerNum-1)*20-5)
	    self.maskSp:addChild(boxSpMenu,2)
		--self.freeBtn:setVisible(false)
	end
	if self.playBtn==nil then
		if(base.hexieMode==1)then
			self.playBtn=GetButtonItem("BigBtnBlue.png","BigBtnBlue_Down.png","BigBtnBlue_Down.png",btnCallback,2,getlocal("code_gift"),25)
		else
			self.playBtn=GetButtonItem("BigBtnBlue.png","BigBtnBlue_Down.png","BigBtnBlue_Down.png",btnCallback,2,getlocal("lotteryBtnPlay"),25)
		end
	    self.playBtn:setAnchorPoint(ccp(0.5,0.5))
	    local boxSpMenu1=CCMenu:createWithItem(self.playBtn)
	    boxSpMenu1:setPosition(ccp(self.maskSp:getContentSize().width/2,btnHeight))
	    boxSpMenu1:setTouchPriority(-(self.layerNum-1)*20-5)
	    self.maskSp:addChild(boxSpMenu1,2)
		--self.playBtn:setVisible(false)
	end
	if self.buyAndPlayBtn==nil then
		if(base.hexieMode==1)then
			self.buyAndPlayBtn=GetButtonItem("BigBtnGreen.png","BigBtnGreen_Down.png","BigBtnGreen_Down.png",btnCallback,3,getlocal("lotteryBtnBuyAndPlayHexie"),25)
		else
			self.buyAndPlayBtn=GetButtonItem("BigBtnGreen.png","BigBtnGreen_Down.png","BigBtnGreen_Down.png",btnCallback,3,getlocal("lotteryBtnBuyAndPlay"),25)
		end
	    self.buyAndPlayBtn:setAnchorPoint(ccp(0.5,0.5))
	    local boxSpMenu2=CCMenu:createWithItem(self.buyAndPlayBtn)
	    boxSpMenu2:setPosition(ccp(self.maskSp:getContentSize().width/2,btnHeight))
	    boxSpMenu2:setTouchPriority(-(self.layerNum-1)*20-5)
	    self.maskSp:addChild(boxSpMenu2,2)
		--self.buyAndPlayBtn:setVisible(false)
	end
	if self.confirmBtn==nil then
		self.confirmBtn=GetButtonItem("BigBtnBlue.png","BigBtnBlue_Down.png","BigBtnBlue_Down.png",btnCallback,4,getlocal("confirm"),25)
	    self.confirmBtn:setAnchorPoint(ccp(0.5,0.5))
	    local boxSpMenu3=CCMenu:createWithItem(self.confirmBtn)
	    boxSpMenu3:setPosition(ccp(self.maskSp:getContentSize().width/2,self.backSprie:getContentSize().height/2-180))
	    boxSpMenu3:setTouchPriority(-(self.layerNum-1)*20-5)
	    self.maskSp:addChild(boxSpMenu3,2)
		--self.confirmBtn:setVisible(false)
	end
	
	local diffGem=dailyVoApi:buyCoinNeedGems(self.selectedTabIndex+1)	
	if self.goldSp==nil then
	    self.goldSp=CCSprite:createWithSpriteFrameName("IconGold.png")
	    self.goldSp:setAnchorPoint(ccp(1,0.5))
	    self.goldSp:setPosition(ccp(self.maskSp:getContentSize().width/2-10,btnHeight+75))
	    self.maskSp:addChild(self.goldSp)
	end
	if self.gemsLabel==nil then
		self.gemsLabel=GetTTFLabel(diffGem,25)
	    self.gemsLabel:setAnchorPoint(ccp(0,0.5))
	    self.gemsLabel:setPosition(ccp(self.maskSp:getContentSize().width/2+10,btnHeight+75))
	    self.maskSp:addChild(self.gemsLabel,1)
	end
	  
	local wSpace=177
	-- local hSpace=150
	-- if G_isIphone5() then
	-- 	hSpace=self.maskSp:getContentSize().height/4
	-- end
	local boxHeight=60
	--local hSpace=(self.maskSp:getContentSize().height-3*boxHeight)/4
	local hSpace=(self.maskSp:getContentSize().height)/3
	
	local scaleX=0.8
	local scaleY=0.8
	--local scale=0.8
	local scale=1
	local function lotteryCommonHandler(tag,object)
		if self.canClick==true then
			self.canClick=false
			local function lotteryCommonCallback(fn,data)
                local success,retTb=base:checkServerData(data)
				if success==true and retTb~=nil then
                    --统计使用物品
			        if retTb.data.ConsumeType~=3 then
			            statisticsHelper:useItem("p47",1)
			        end
					local award=retTb.data.awards
					if award==nil or SizeOfTable(award)==0 then
						do return end
					end
					if(base.hexieMode==1)then
						local award=FormatItem(playerCfg.mustReward1.reward)
                        G_showRewardTip(award, true)
					end
					local awardTab=FormatItem(award)
					local item = awardTab[1]
					local awardType=item.type

					-- 投放非背包数据奖励需要自己加
					if item.type ~= "p" and item.type ~= "u" and item.type ~= "o" and item.type ~= "h" then
        				G_addPlayerAward(item.type,item.key,item.id,item.num,nil,true)
					end
					
					if item.type == "h" then
						heroVoApi:addSoul(item.key,item.num,true)
					end

					local rewardStrTab={}
					local rewardStr=""
	                if item and item.name and item.num then	
						rewardStr = item.name.." x"..item.num.."\n"..getlocal(item.desc)
						-- if awardType=="p" and (tonumber(item.id)==5 or tonumber(item.id)==20 or tonumber(item.id)==2) then
						-- 	-- chatVoApi:sendSystemMessage(getlocal("chatSystemMessage5",{playerVoApi:getPlayerName(),item.name}))
						-- 	local pid="p"..item.id
    		-- 				local prop=propCfg[pid]
    		-- 				local nameData={key=prop.name,param={}}
    		-- 				local paramTab={}
    		-- 				paramTab.functionStr="dailyLottery"
		    --                 paramTab.addStr="i_also_want"
						-- 	local message={key="chatSystemMessage5",param={playerVoApi:getPlayerName(),nameData}}
      --       				chatVoApi:sendSystemMessage(message,paramTab)
						--[[if awardType=="o"then
							-- chatVoApi:sendSystemMessage(getlocal("chatSystemMessage5",{playerVoApi:getPlayerName(),item.name.." x"..item.num}))
							local tank=tankCfg[tonumber(item.id)]
							if not tank then
								tank=tankCfg[tonumber(RemoveFirstChar(item.id))]
							end
							if tank and tank.tankLevel and tank.tankLevel >= 4 then
	        					local nameData={key=tank.name,param={}}
	        					local paramData={nameData,item.num}
	        					local paramTab={}
	    						paramTab.functionStr="dailyLottery"
			                    paramTab.addStr="i_also_want"
	        					local msgData={key="item_number",param=paramData}
								local message={key="chatSystemMessage5",param={playerVoApi:getPlayerName(),msgData}}
	                			chatVoApi:sendSystemMessage(message,paramTab)
                			end
                		elseif awardType=="h" then
							local heroName = item.name.."x"..item.num
        					local paramTab={}
    						paramTab.functionStr="dailyLottery"
		                    paramTab.addStr="i_also_want"
        					local msgData={key="item_number",param=paramData}
							local message={key="chatSystemMessage5",param={playerVoApi:getPlayerName(),heroName}}
	                		chatVoApi:sendSystemMessage(message,paramTab)
						end]]
					end

					local index=tag-100
					local dailyVo=dailyVoApi:getDailyVo(self.selectedTabIndex+1)
					--local awardPool=dailyVo.awardPool
					local awardPool=dailyVo.award
					local awardTab={}
					while SizeOfTable(awardTab)<9 do
						local randomNum=math.random(SizeOfTable(awardPool))
						if tostring(item.name)~=tostring(awardPool[randomNum].name) then
							table.insert(awardTab,awardPool[randomNum])
						end
						table.remove(awardPool,randomNum)
					end

					for k,v in pairs(self.commonBoxTab) do
						if self.commonBoxTab[k].itemSp~=nil then
							self.commonBoxTab[k].itemSp:removeFromParentAndCleanup(true)
							self.commonBoxTab[k].itemSp=nil
						end
						local pic=awardTab[k].pic

						local itemSp
						if awardTab[k].type == "h" then
							local heroPic
						 	if platCfg.platCfgHeroCartoonPhoto[G_curPlatName()]~=nil then
					            heroPic = "ship/Hero_Icon_Cartoon/"..pic
					        else
					        	heroPic = "ship/Hero_Icon/"..pic
					        end
							itemSp = CCSprite:create(heroPic)
						else
							itemSp = CCSprite:createWithSpriteFrameName(pic)
						end

						-- local itemSp = CCSprite:createWithSpriteFrameName(pic)
					    itemSp:setAnchorPoint(ccp(0.5,0.5))
					    itemSp:setPosition(getCenterPoint(self.commonBoxTab[k].lightSp))
						if itemSp:getContentSize().width>100 then
							itemSp:setScaleX(100/itemSp:getContentSize().width*scale)
							itemSp:setScaleY(100/itemSp:getContentSize().height*scale)
						else
							itemSp:setScaleX(scale)
							itemSp:setScaleY(scale)
						end
					    self.commonBoxTab[k].lightSp:addChild(itemSp,1)
						--itemSp:setVisible(false)
						self.commonBoxTab[k].itemSp=itemSp
						
						self.commonBoxTab[k].boxSp:setEnabled(false)
						self.commonBoxTab[k].lightSp:setVisible(true)
						
						if index==k then
							self.commonBoxTab[k].boxSp:setEnabled(false)
							self.commonBoxTab[k].boxSpMenu:setVisible(false)

							if self.selectedBox~=nil then
								self.selectedBox:removeFromParentAndCleanup(true)
								self.selectedBox=nil
							end
							local buttonName1 = "CommonBox.png"
							local buttonName2 = "CommonBoxOpen.png"
							if platCfg.platCfgBMImage[G_curPlatName()]~=nil  then
								buttonName1="kunlunCommonBox.png"
								buttonName2="kunlunCommonBoxOpen.png"
							end
							local boxSp=CCMenuItemImage:create(buttonName1, buttonName1,buttonName2)
							--local posX=wSpace*((k-1)%3)+28+100*scale
							--local posY=self.backSprie:getContentSize().height/2-(hSpace-10)*(math.ceil(k/3)-2)+80-100*scale
							--local posY=self.backSprie:getContentSize().height-hSpace*(math.ceil(k/3)-1)-100*scale-15
							--local posY=hSpace*k+boxHeight/2+(math.ceil(k/3)-1)*boxHeight+boxHeight
							local posX,posY=self:getPosition(wSpace,hSpace,k,scale)
							
						    boxSp:setAnchorPoint(ccp(0.5,0.5))
							boxSp:setEnabled(false)
						    self.selectedBox=CCMenu:createWithItem(boxSp)
						    self.selectedBox:setPosition(ccp(posX,posY))
						    --self.selectedBox:setTouchPriority(-(self.layerNum-1)*20-3)
						    self.backSprie:addChild(self.selectedBox,3)
	
							local lightSp = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
						    lightSp:setAnchorPoint(ccp(0.5,0.5))
						    lightSp:setPosition(getCenterPoint(boxSp))
						    boxSp:addChild(lightSp,1)
							--lightSp:setVisible(true)
							
							local itemSp
							if item.type == "h" then
								local heroPic
								if platCfg.platCfgHeroCartoonPhoto[G_curPlatName()]~=nil then
						            heroPic = "ship/Hero_Icon_Cartoon/"..item.pic
						        else
						        	heroPic = "ship/Hero_Icon/"..item.pic
						        end
								itemSp = CCSprite:create(heroPic)
							else
								itemSp = CCSprite:createWithSpriteFrameName(item.pic)
							end

						    itemSp:setAnchorPoint(ccp(0.5,0.5))
						    itemSp:setPosition(getCenterPoint(self.commonBoxTab[k].lightSp))
							if itemSp:getContentSize().width>100 then
								itemSp:setScaleX(100/itemSp:getContentSize().width*scale)
								itemSp:setScaleY(100/itemSp:getContentSize().height*scale)
							else
								itemSp:setScaleX(scale)
								itemSp:setScaleY(scale)
							end
							lightSp:addChild(itemSp,1)
							
							local function playEndCallback()
								self.costDescLabel:setVisible(true)
								self.confirmBtn:setVisible(true)
								self.costDescLabel:setVisible(true)
							end
							local delay=CCDelayTime:create(0.5)
							local posX,posY=self:getPosition(wSpace,hSpace,2,scale)
							local mvTo0=CCMoveTo:create(0.3,ccp(posX,self.backSprie:getContentSize().height/2+100))
							
							local ms=2
					        local scaleTo=CCScaleTo:create(0.1,ms)
					        --local mvTo=CCMoveTo:create(0.3,ccp(wSpace+28+100*scale,self.backSprie:getContentSize().height/2-(hSpace-10)*(-1)+80-100*scale))
							posX,posY=self:getPosition(wSpace,hSpace,2,scale)
							posX=(posX+8*ms)*ms
							--posY=(posY)*ms-30
							posY=(self.backSprie:getContentSize().height/2+160)*ms
							local mvTo=CCMoveTo:create(0.1,ccp(posX,posY))
							local carray=CCArray:create()
					        carray:addObject(mvTo)
					        carray:addObject(scaleTo)
					        local spawn=CCSpawn:create(carray)
							
							ms=1.3
							local scaleTo1=CCScaleTo:create(0.2,ms)
							posX,posY=self:getPosition(wSpace,hSpace,2,scale)
							posX=(posX+7*ms)*ms
							--posY=(posY)*ms-30
							posY=(self.backSprie:getContentSize().height/2+130)*ms
							local mvTo1=CCMoveTo:create(0.2,ccp(posX,posY))
							local carray1=CCArray:create()
					        carray1:addObject(mvTo1)
					        carray1:addObject(scaleTo1)
					        local spawn1=CCSpawn:create(carray1)
							local callFunc=CCCallFuncN:create(playEndCallback)
							
						    local acArr=CCArray:create()
						    acArr:addObject(delay)
							acArr:addObject(mvTo0)
						    acArr:addObject(spawn)
							acArr:addObject(spawn1)
						    acArr:addObject(callFunc)
						    local seq=CCSequence:create(acArr)
						    self.selectedBox:runAction(seq)
						end
					end
					self.maskSp:setVisible(true)
					self.maskSp:setPosition(ccp(self.backSprie:getContentSize().width/2,self.backSprie:getContentSize().height/2+5))
					self.goldSp:setVisible(false)
					self.gemsLabel:setVisible(false)
					if awardType and awardType=="o" then
						self.descLabel:setString(getlocal("lotteryFinishTankDesc"))
					else
						self.descLabel:setString(getlocal("lotteryFinishDesc"))
					end
		
					self.freeBtn:setVisible(false)
					self.playBtn:setVisible(false)
					self.buyAndPlayBtn:setVisible(false)
					self.costDescLabel:setVisible(false)
					self.confirmBtn:setVisible(false)
		
					self.costDescLabel:setPosition(ccp(self.maskSp:getContentSize().width/2,self.backSprie:getContentSize().height/2-55))
					self.costDescLabel:setString(rewardStr)
					self.costDescLabel:setVisible(false)
				
					self.canClick=true
				else
					self.canClick=true
				end
			end
			local isFree=dailyVoApi:isFreeByType(self.selectedTabIndex+1)
			socketHelper:luckygoods(1,isFree,nil,1,lotteryCommonCallback)
		end
	end
	local function lotterySeniorHandler(tag,object)
		if self.canClick==true then
			self.canClick=false
			local function lotterySeniorCallback(fn,data)
                local success,retTb=base:checkServerData(data)
				if success==true and retTb~=nil then
                    --统计使用物品

			        if retTb.data.ConsumeType~=3 then
			            statisticsHelper:useItem("p47",3)
			        end
					if(base.hexieMode==1)then
						local award=FormatItem(playerCfg.mustReward2.reward)
                        G_showRewardTip(award, true)
					end
					local award=retTb.data.awards
					local awardTab=FormatItem(award)
					local item = awardTab[1]
					local awardType=item.type

					-- 投放非背包数据奖励需要自己加
					-- G_dayin(item)
					if item.type ~= "p" and item.type ~= "u" and item.type ~= "o" and item.type ~= "h" then
						-- print("hjtest1>>")
						-- G_dayin(item)
        				G_addPlayerAward(item.type,item.key,item.id,item.num,nil,true)
					end

					if item.type == "h" then
						heroVoApi:addSoul(item.key,item.num,true)
					end

					local rewardStrTab={}
					local rewardStr=""
					-- G_dayin(item)
	                if item and item.name and item.num then	
						rewardStr = item.name.." x"..item.num.."\n"..getlocal(item.desc)
						--[[if awardType=="o"then
							-- chatVoApi:sendSystemMessage(getlocal("chatSystemMessage5",{playerVoApi:getPlayerName(),item.name.." x"..item.num}))
							local tank=tankCfg[tonumber(item.id)]
							if not tank then
								tank=tankCfg[tonumber(RemoveFirstChar(item.id))]
							end
							if tank and tank.tankLevel and tank.tankLevel >= 4 then
	        					local nameData={key=tank.name,param={}}
	        					local paramData={nameData,item.num}
	        					local paramTab={}
	    						paramTab.functionStr="dailyLottery"
			                    paramTab.addStr="i_also_want"
	        					local msgData={key="item_number",param=paramData}
								local message={key="chatSystemMessage5",param={playerVoApi:getPlayerName(),msgData}}
	                			chatVoApi:sendSystemMessage(message,paramTab)
                			end
                		elseif awardType=="h" then
                			local heroName = item.name.."x"..item.num
        					local paramTab={}
    						paramTab.functionStr="dailyLottery"
		                    paramTab.addStr="i_also_want"
        					local msgData={key="item_number",param=paramData}
							local message={key="chatSystemMessage5",param={playerVoApi:getPlayerName(),heroName}}
	                		chatVoApi:sendSystemMessage(message,paramTab)
						end]]
					end

					local index=tag-200
					local dailyVo=dailyVoApi:getDailyVo(self.selectedTabIndex+1)
					--local awardPool=dailyVo.awardPool
					local awardPool=dailyVo.award
					local awardTab={}
					while SizeOfTable(awardTab)<9 do
						local randomNum=math.random(SizeOfTable(awardPool))
						if tostring(item.name)~=tostring(awardPool[randomNum].name) then
							table.insert(awardTab,awardPool[randomNum])
						end
						table.remove(awardPool,randomNum)
					end

					for k,v in pairs(self.seniorBoxTab) do
						if self.seniorBoxTab[k].itemSp~=nil then
							self.seniorBoxTab[k].itemSp:removeFromParentAndCleanup(true)
							self.seniorBoxTab[k].itemSp=nil
						end
						local pic=awardTab[k].pic
						local itemSp 
						if awardTab[k].type == "h" then
							local heroPic
						 	if platCfg.platCfgHeroCartoonPhoto[G_curPlatName()]~=nil then
					            heroPic = "ship/Hero_Icon_Cartoon/"..pic
					        else
					        	heroPic = "ship/Hero_Icon/"..pic
					        end
							itemSp = CCSprite:create(heroPic)
						else
							itemSp = CCSprite:createWithSpriteFrameName(pic)
						end

					    itemSp:setAnchorPoint(ccp(0.5,0.5))
					    itemSp:setPosition(getCenterPoint(self.seniorBoxTab[k].lightSp))
						if itemSp:getContentSize().width>100 then
							itemSp:setScaleX(100/itemSp:getContentSize().width*scale)
							itemSp:setScaleY(100/itemSp:getContentSize().height*scale)
						else
							itemSp:setScaleX(scale)
							itemSp:setScaleY(scale)
						end
					    self.seniorBoxTab[k].lightSp:addChild(itemSp,1)
						--itemSp:setVisible(false)
						self.seniorBoxTab[k].itemSp=itemSp
						
						self.seniorBoxTab[k].boxSp:setEnabled(false)
						self.seniorBoxTab[k].lightSp:setVisible(true)
						
						if index==k then
							self.seniorBoxTab[k].boxSp:setEnabled(false)
							self.seniorBoxTab[k].boxSpMenu:setVisible(false)

							if self.selectedBox~=nil then
								self.selectedBox:removeFromParentAndCleanup(true)
								self.selectedBox=nil
							end
							local buttonName1 = "SeniorBox.png"
							local buttonName2 = "SeniorBoxOpen.png"
							if platCfg.platCfgBMImage[G_curPlatName()]~=nil then
								buttonName1="kunlunSeniorBox.png"
								buttonName2="kunlunSeniorBoxOpen.png"
							end
							local boxSp=CCMenuItemImage:create(buttonName1, buttonName1,buttonName2)
							--local posX=wSpace*((k-1)%3)+40
							--local posY=self.backSprie:getContentSize().height-hSpace*(math.ceil(k/3)-1)-28
							--local posX=wSpace*((k-1)%3)+28+100*scale
							--local posY=self.backSprie:getContentSize().height/2-(hSpace-10)*(math.ceil(k/3)-2)+80-100*scale
							local posX,posY=self:getPosition(wSpace,hSpace,k,scale)
							
							boxSp:setAnchorPoint(ccp(0.5,0.5))
							boxSp:setEnabled(false)
						    self.selectedBox=CCMenu:createWithItem(boxSp)
						    self.selectedBox:setPosition(ccp(posX,posY))
						    --self.selectedBox:setTouchPriority(-(self.layerNum-1)*20-3)
						    self.backSprie:addChild(self.selectedBox,3)
	
							local lightSp = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
						    lightSp:setAnchorPoint(ccp(0.5,0.5))
						    lightSp:setPosition(getCenterPoint(boxSp))
						    boxSp:addChild(lightSp,1)
							--lightSp:setVisible(true)
							local itemSp
							if item.type == "h" then
								local heroPic
							 	if platCfg.platCfgHeroCartoonPhoto[G_curPlatName()]~=nil then
						            heroPic = "ship/Hero_Icon_Cartoon/"..item.pic
						        else
						        	heroPic = "ship/Hero_Icon/"..item.pic
						        end
								itemSp = CCSprite:create(heroPic)
							else
								itemSp = CCSprite:createWithSpriteFrameName(item.pic)
							end
						    itemSp:setAnchorPoint(ccp(0.5,0.5))
						    itemSp:setPosition(getCenterPoint(self.seniorBoxTab[k].lightSp))
							if itemSp:getContentSize().width>100 then
								itemSp:setScaleX(100/itemSp:getContentSize().width*scale)
								itemSp:setScaleY(100/itemSp:getContentSize().height*scale)
							else
								itemSp:setScaleX(scale)
								itemSp:setScaleY(scale)
							end
							lightSp:addChild(itemSp,1)
							
							local function playEndCallback()
								self.costDescLabel:setVisible(true)
								self.confirmBtn:setVisible(true)
								self.costDescLabel:setVisible(true)
							end
							local delay=CCDelayTime:create(0.5)
							local posX,posY=self:getPosition(wSpace,hSpace,2,scale)
							local mvTo0=CCMoveTo:create(0.3,ccp(posX,self.backSprie:getContentSize().height/2+100))
							
							local ms=2
					        local scaleTo=CCScaleTo:create(0.1,ms)
					        --local mvTo=CCMoveTo:create(0.3,ccp(wSpace+28+100*scale,self.backSprie:getContentSize().height/2-(hSpace-10)*(-1)+80-100*scale))
							posX,posY=self:getPosition(wSpace,hSpace,2,scale)
							posX=(posX+8*ms)*ms
							--posY=(posY)*ms-30
							posY=(self.backSprie:getContentSize().height/2+160)*ms
							local mvTo=CCMoveTo:create(0.1,ccp(posX,posY))
							local carray=CCArray:create()
					        carray:addObject(mvTo)
					        carray:addObject(scaleTo)
					        local spawn=CCSpawn:create(carray)
							
							ms=1.3
							local scaleTo1=CCScaleTo:create(0.2,ms)
							posX,posY=self:getPosition(wSpace,hSpace,2,scale)
							posX=(posX+7*ms)*ms
							--posY=(posY)*ms-30
							posY=(self.backSprie:getContentSize().height/2+130)*ms
							local mvTo1=CCMoveTo:create(0.2,ccp(posX,posY))
							local carray1=CCArray:create()
					        carray1:addObject(mvTo1)
					        carray1:addObject(scaleTo1)
					        local spawn1=CCSpawn:create(carray1)
							local callFunc=CCCallFuncN:create(playEndCallback)
							
						    local acArr=CCArray:create()
						    acArr:addObject(delay)
							acArr:addObject(mvTo0)
						    acArr:addObject(spawn)
							acArr:addObject(spawn1)
						    acArr:addObject(callFunc)
						    local seq=CCSequence:create(acArr)
						    self.selectedBox:runAction(seq)
						end
					end
					self.maskSp:setVisible(true)
					self.maskSp:setPosition(ccp(self.backSprie:getContentSize().width/2,self.backSprie:getContentSize().height/2+5))
					self.goldSp:setVisible(false)
					self.gemsLabel:setVisible(false)
					if awardType and awardType=="o" then
						self.descLabel:setString(getlocal("lotteryFinishTankDesc"))
					else
						self.descLabel:setString(getlocal("lotteryFinishDesc"))
					end
		
					self.freeBtn:setVisible(false)
					self.playBtn:setVisible(false)
					self.buyAndPlayBtn:setVisible(false)
					self.costDescLabel:setVisible(false)
					self.confirmBtn:setVisible(false)
		
					self.costDescLabel:setPosition(ccp(self.maskSp:getContentSize().width/2,self.backSprie:getContentSize().height/2-55))
					self.costDescLabel:setString(rewardStr)
					self.costDescLabel:setVisible(false)
				
					self.canClick=true
				else
					self.canClick=true
				end
			end
			local isVipFree=dailyVoApi:isFreeByType(self.selectedTabIndex+1)
			socketHelper:luckygoods(2,isVipFree,nil,1,lotterySeniorCallback)
		end
	end
	
	local isFree,isVipFree=dailyVoApi:isFreeByType(self.selectedTabIndex+1)
	if isFree then
		self.freeBtn:setVisible(true)
		if self.selectedTabIndex==0 then
			if(base.hexieMode==1)then
				tolua.cast(self.freeBtn:getChildByTag(501),"CCLabelTTF"):setString(getlocal("daily_lotto_tip_2"))
			else
				tolua.cast(self.freeBtn:getChildByTag(501),"CCLabelTTF"):setString(getlocal("lotteryBtnFree"))
			end
		elseif self.selectedTabIndex==1 then
			if isVipFree==true then
				tolua.cast(self.freeBtn:getChildByTag(501),"CCLabelTTF"):setString(getlocal("vip_special_use"))
			else
				if(base.hexieMode==1)then
					tolua.cast(self.freeBtn:getChildByTag(501),"CCLabelTTF"):setString(getlocal("daily_lotto_tip_2"))
				else
					tolua.cast(self.freeBtn:getChildByTag(501),"CCLabelTTF"):setString(getlocal("lotteryBtnSeniorFree"))
				end
			end
		end
		self.playBtn:setVisible(false)
		self.buyAndPlayBtn:setVisible(false)
		if self.selectedTabIndex==0 then
			if(base.hexieMode==1)then
				self.descLabel:setString(getlocal("lotteryCommonFreeDescHexie"))
			else
				self.descLabel:setString(getlocal("lotteryCommonFreeDesc"))
			end
		elseif self.selectedTabIndex==1 then
			if(base.hexieMode==1)then
				self.descLabel:setString(getlocal("lotterySeniorFreeDescHexie"))
			else
				self.descLabel:setString(getlocal("lotterySeniorFreeDesc"))
			end
		end
		self.goldSp:setVisible(false)
		self.gemsLabel:setVisible(false)
	else
		local diffCoins=dailyVoApi:coinLessNum(self.selectedTabIndex+1)
		--判断幸运币是否够
		if diffCoins>0 then
			self.freeBtn:setVisible(false)
			self.playBtn:setVisible(false)
			self.buyAndPlayBtn:setVisible(true)
			
			self.maskSp:setVisible(true)
			self.maskSp:setPosition(ccp(self.backSprie:getContentSize().width/2,self.backSprie:getContentSize().height/2+5))
			if self.selectedTabIndex==0 then
				if(base.hexieMode==1)then
					local reward=FormatItem(playerCfg.mustReward1.reward)
					local rewardStr
					for k,v in pairs(reward) do
						rewardStr=v.name.."×"..FormatNumber(v.num)
					end
					self.descLabel:setString(getlocal("lotteryCommonDesc2",{1,rewardStr}))
				else
					self.descLabel:setString(getlocal("lotteryCommonDesc"))
				end
			elseif self.selectedTabIndex==1 then
				if(base.hexieMode==1)then
					local reward=FormatItem(playerCfg.mustReward2.reward)
					local rewardStr
					for k,v in pairs(reward) do
						rewardStr=v.name.."×"..FormatNumber(v.num)
					end
					self.descLabel:setString(getlocal("lotteryCommonDesc2",{3,rewardStr}))
				else
					self.descLabel:setString(getlocal("lotterySeniorDesc"))
				end
			end
			local diffGem1=dailyVoApi:buyCoinNeedGems(self.selectedTabIndex+1)
			if diffGem1>0 then
				self.goldSp:setVisible(true)
				self.gemsLabel:setVisible(true)
				self.gemsLabel:setString(diffGem1)
			end
		else
			self.freeBtn:setVisible(false)
			self.playBtn:setVisible(true)
			self.buyAndPlayBtn:setVisible(false)
			
			self.maskSp:setVisible(false)
			self.maskSp:setPosition(ccp(10000,0))
			if(base.hexieMode==1)then
				self.descLabel:setString(getlocal("lotteryBeginCostDescHexie",{dailyVo.cost,dailyVoApi:getLuckyCoins()}))
			else
				self.descLabel:setString(getlocal("lotteryBeginCostDesc",{dailyVo.cost,dailyVoApi:getLuckyCoins()}))
			end
			self.goldSp:setVisible(false)
			self.gemsLabel:setVisible(false)
		end
	end
	self.confirmBtn:setVisible(false)
	
	for i=1,9 do
		if self.selectedTabIndex==0 then
			if self.commonBoxTab==nil then
				self.commonBoxTab={}
			end
			if self.commonBoxTab[i]==nil then
				--local boxSp=GetButtonItem("kunlunCommonBox.png","kunlunCommonBox.png","kunlunCommonBoxOpen.png",lotteryCommonHandler,100+i,nil,nil)
				local buttonName1 = "CommonBox.png"
				local buttonName2 = "CommonBoxOpen.png"
				if platCfg.platCfgBMImage[G_curPlatName()]~=nil then
					buttonName1="kunlunCommonBox.png"
					buttonName2="kunlunCommonBoxOpen.png"
				end
				local boxSp=CCMenuItemImage:create(buttonName1, buttonName1,buttonName2)
				boxSp:registerScriptTapHandler(lotteryCommonHandler)
				boxSp:setTag(100+i)
				
				--local posX=wSpace*((i-1)%3)+28+100*scale
				--local posY=self.backSprie:getContentSize().height-hSpace*(math.ceil(i/3)-1)-28
				--local posY=self.backSprie:getContentSize().height/2-(hSpace-10)*(math.ceil(i/3)-2)+80-100*scale
				local posX,posY=self:getPosition(wSpace,hSpace,i,scale)
			    boxSp:setAnchorPoint(ccp(0.5,0.5))
			    local boxSpMenu=CCMenu:createWithItem(boxSp)
			    boxSpMenu:setPosition(ccp(posX,posY))
			    boxSpMenu:setTouchPriority(-(self.layerNum-1)*20-3)
			    self.backSprie:addChild(boxSpMenu,1)
	
				local lightSp = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
			    lightSp:setAnchorPoint(ccp(0.5,0.5))
			    lightSp:setPosition(getCenterPoint(boxSp))
			    boxSp:addChild(lightSp,1)
				lightSp:setVisible(false)
				table.insert(self.commonBoxTab,i,{boxSp=boxSp,boxSpMenu=boxSpMenu,lightSp=lightSp})
			else
				self.commonBoxTab[i].boxSpMenu:setVisible(true)
				self.commonBoxTab[i].boxSp:setEnabled(true)
				self.commonBoxTab[i].lightSp:setVisible(false)
			end
			if self.seniorBoxTab and SizeOfTable(self.seniorBoxTab)>0 then
				self.seniorBoxTab[i].boxSpMenu:setVisible(false)
			end
			if self.commonBoxTab[i].itemSp~=nil then
				self.commonBoxTab[i].itemSp:removeFromParentAndCleanup(true)
				self.commonBoxTab[i].itemSp=nil
			end
		elseif self.selectedTabIndex==1 then
			if self.seniorBoxTab==nil then
				self.seniorBoxTab={}
			end
			if self.seniorBoxTab[i]==nil then   
				--local boxSp=GetButtonItem("kunlunSeniorBox.png","kunlunSeniorBox.png","kunlunSeniorBoxOpen.png",lotterySeniorHandler,200+i,nil,nil)
				local buttonName1 = "SeniorBox.png"
				local buttonName2 = "SeniorBoxOpen.png"
				if platCfg.platCfgBMImage[G_curPlatName()]~=nil then
					buttonName1="kunlunSeniorBox.png"
					buttonName2="kunlunSeniorBoxOpen.png"
				end
				local boxSp=CCMenuItemImage:create(buttonName1, buttonName1,buttonName2)
				boxSp:registerScriptTapHandler(lotterySeniorHandler)
				boxSp:setTag(200+i)
				--local posX=wSpace*((i-1)%3)+40
				--local posY=self.backSprie:getContentSize().height-hSpace*(math.ceil(i/3)-1)-28
			    local posX,posY=self:getPosition(wSpace,hSpace,i,scale)
				boxSp:setAnchorPoint(ccp(0.5,0.5))
			    local boxSpMenu=CCMenu:createWithItem(boxSp)
			    boxSpMenu:setPosition(ccp(posX,posY))
			    boxSpMenu:setTouchPriority(-(self.layerNum-1)*20-3)
			    self.backSprie:addChild(boxSpMenu,1)
	
				local lightSp = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
			    lightSp:setAnchorPoint(ccp(0.5,0.5))
			    lightSp:setPosition(getCenterPoint(boxSp))
			    boxSp:addChild(lightSp,1)
				lightSp:setVisible(false)
				table.insert(self.seniorBoxTab,i,{boxSp=boxSp,boxSpMenu=boxSpMenu,lightSp=lightSp})
			else
				self.seniorBoxTab[i].boxSpMenu:setVisible(true)
				self.seniorBoxTab[i].boxSp:setEnabled(true)
				self.seniorBoxTab[i].lightSp:setVisible(false)
			end
			if self.commonBoxTab and SizeOfTable(self.commonBoxTab)>0 then
				self.commonBoxTab[i].boxSpMenu:setVisible(false)
			end
			if self.seniorBoxTab[i].itemSp~=nil then
				self.seniorBoxTab[i].itemSp:removeFromParentAndCleanup(true)
				self.seniorBoxTab[i].itemSp=nil
			end
		end
	end
end
function dailyDialog:getPosition(wSpace,hSpace,index,scale)
	local posX=wSpace*((index-1)%3)+100*scale+10
	local posY=self.backSprie:getContentSize().height/2-(hSpace-10)*(math.ceil(index/3)-2)-100*scale+100
	return posX,posY
end

--点击tab页签 idx:索引
function dailyDialog:tabClick(idx)
    PlayEffect(audioCfg.mouseClick)
	for k,v in pairs(self.allTabs) do
		if v:getTag()==idx then
			--self.canClick=true
			v:setEnabled(false)
			self.selectedTabIndex=idx
			--self.tv:reloadData()
			self:doUserHandler()
		else
			v:setEnabled(true)
		end
	end
end

function dailyDialog:tick()
	-- if self.isFree1~=dailyVoApi:isFreeByType(1) then
	-- 	self.isFree1=dailyVoApi:isFreeByType(1)
	-- 	self:doUserHandler()
	-- end
	-- if self.isFree2~=dailyVoApi:isFreeByType(2) then
	-- 	self.isFree2=dailyVoApi:isFreeByType(2)
	-- 	self:doUserHandler()
	-- end
end

function dailyDialog:dispose()
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
	self.rewardValueLabel=nil
	self.rewardLevelLabel=nil
	self.isFree1=nil
	self.isFree2=nil
    self=nil
end




