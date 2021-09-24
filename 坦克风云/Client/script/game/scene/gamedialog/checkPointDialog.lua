--require "luascript/script/componet/commonDialog"
require "luascript/script/game/gamemodel/checkPoint/checkPointVoApi"

checkPointDialog=commonDialog:new()

function checkPointDialog:new(sid)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
	self.sid=sid
    self.starLabel=nil
    self.chapterTab={}
    self.energyLabel=nil
    self.cellMinHeight=700
    self.spaceX=140
    self.spaceY=160
    -- if G_isIphone5() then
    --     self.spaceY=(G_VisibleSizeHeight-260)/4
    -- end
	self.flicker=nil
	self.enTime=nil
    self.enTimeCount=nil
	self.energycd=nil
	self.isShow=false
	self.iconTab={}
	self.rewardBg=nil
	self.scheduleLb=nil
    self.switchSp=nil
    self.openLb=nil
    self.closeLb=nil
    self.guildItem=nil
    return nc
end

--设置对话框里的tableView
function checkPointDialog:initTableView()	
	local checkPointCfg = checkPointVoApi:getCfgBySid(self.sid)
	local checkPointVo = checkPointVoApi:getCheckPointVoBySid(self.sid)
	-- local isShow=true
	-- if checkPointVo.chapterTab==nil or SizeOfTable(checkPointVo.chapterTab)==0 or (checkPointVo.sid==1 and checkPointVo.chapterTab[1].starNum==0) then
	-- 	isShow=false
	-- end
	
    local rect = CCRect(0, 0, 50, 50)
    local capInSet = CCRect(20, 20, 10, 10)
    local function cellClick(hd,fn,idx)
    end
	
    local headSprie =LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),cellClick)
    headSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20, 80))
    headSprie:ignoreAnchorPointForPosition(false)
    headSprie:setAnchorPoint(ccp(0,0))
    headSprie:setIsSallow(false)
    headSprie:setTouchPriority(-(self.layerNum-1)*20-2)
	headSprie:setPosition(ccp(10, self.bgLayer:getContentSize().height-165))
    self.bgLayer:addChild(headSprie,1)

	local rankSp=CCSprite:createWithSpriteFrameName(checkPointCfg.style)
	rankSp:setAnchorPoint(ccp(0,0.5))
    rankSp:setPosition(ccp(10,headSprie:getContentSize().height/2))
	headSprie:addChild(rankSp,1)
	if rankSp:getContentSize().width>=60 then
		rankSp:setScaleX(0.8)
		rankSp:setScaleY(0.8)
	end
	
	local descLabel = GetTTFLabelWrap(getlocal(checkPointCfg.description),30,CCSizeMake(30*13,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	descLabel:setAnchorPoint(ccp(0,0.5))
    descLabel:setPosition(ccp(70,headSprie:getContentSize().height/2))
	headSprie:addChild(descLabel,1)
	
	local star=CCSprite:createWithSpriteFrameName("StarIcon.png")
	star:setAnchorPoint(ccp(1,0.5))
    star:setPosition(ccp(headSprie:getContentSize().width-20,headSprie:getContentSize().height/2))
	headSprie:addChild(star,1)

	local starNum
	if checkPointVo and checkPointVo.starNum then
		starNum=checkPointVo.starNum
	else
		starNum=0
	end
    self.starLabel=GetTTFLabel(getlocal("scheduleChapter",{starNum,checkPointVoApi:getCheckPointStarNum()}),30)
	self.starLabel:setAnchorPoint(ccp(1,0.5))
    self.starLabel:setPosition(ccp(headSprie:getContentSize().width-star:getContentSize().width-20,headSprie:getContentSize().height/2))
	headSprie:addChild(self.starLabel,1)
	


	self.tvWidth=self.bgLayer:getContentSize().width-60
	self.tvHeight=self.bgLayer:getContentSize().height-270
    self.backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
    self.backSprie:setContentSize(CCSizeMake(self.tvWidth+10,self.tvHeight+10))
    self.backSprie:ignoreAnchorPointForPosition(false)
    self.backSprie:setAnchorPoint(ccp(0,0))
    self.backSprie:setIsSallow(false)
    self.backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
	self.backSprie:setPosition(ccp(30, 100))
    self.bgLayer:addChild(self.backSprie,1)


	self:updateHeader()
    self:reloadTableView()

	
	self.energycd=playerVoApi:getPlayerEnergycd()
	self.enTime=playerVoApi:getPlayerEnergycd()%1800
    self.enTimeCount=playerVoApi:getPlayerEnergycd()/1800
    if self.enTime==0 and self.enTimeCount>0 then
        self.enTime=1800
        self.enTimeCount=self.enTimeCount-1
    end
    if playerVoApi:getEnergy()>=20 then
		energyStr = getlocal("current_energy")..getlocal("scheduleChapter",{playerVoApi:getEnergy(),checkPointVoApi:getMaxEnergy()})
    else
        energyStr = getlocal("current_energy")..getlocal("scheduleChapter",{playerVoApi:getEnergy(),checkPointVoApi:getMaxEnergy()}).."("..GetTimeStr(self.enTime)..")"
	end
    self.energyLabel=GetTTFLabel(energyStr,30)
	self.energyLabel:setAnchorPoint(ccp(0,0))
    self.energyLabel:setPosition(ccp(30,40))
	self.bgLayer:addChild(self.energyLabel,1)

    local unlockNum=checkPointVoApi:getUnlockNum()
    if base.raids==1 and unlockNum and unlockNum>=challengeRaidCfg.needChapter and playerVoApi:getPlayerLevel()>=challengeRaidCfg.needLv then
        self:initRaid()
    end

    if newGuidMgr:isNewGuiding()==true and self.guildItem then
    	if newGuidMgr.curStep==11 then
        	local nextStepId=newGuidCfg[newGuidMgr.curStep].toStepId
			newGuidMgr:setGuideStepField(nextStepId,self.guildItem,true)
    	end
    end
	
	G_WeakTb.checkPoint=self
end

function checkPointDialog:initRaid()
	local posX=self.bgLayer:getContentSize().width-115+10
    local posY=60
    local spacex=0

    local openStr=getlocal("elite_challenge_raid_btn")
    local closeStr=getlocal("city_info_attack")
    local dataKey="challengeRaids@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)

 --    local function switchState()
 --        if G_checkClickEnable()==false then
	-- 		do return end
	-- 	else
	-- 		base.setWaitTime=G_getCurDeviceMillTime()
	-- 	end
 --        PlayEffect(audioCfg.mouseClick)

 --        if self.isRaidsOn==0 then
 --            self.isRaidsOn=1
 --        else
 --            self.isRaidsOn=0
 --        end
 --        CCUserDefault:sharedUserDefault():setIntegerForKey(dataKey,self.isRaidsOn)
 --        CCUserDefault:sharedUserDefault():flush()
 --        print("self.isRaidsOn:",self.isRaidsOn)
 --        if self.isRaidsOn and self.isRaidsOn==1 then
 --            if self.switchSp then
 --                self.switchSp:setPosition(ccp(posX+self.switchSp:getContentSize().width/2-spacex,posY))
 --            end
 --            if self.openLb then
 --                self.openLb:setVisible(true)
 --            end
 --            if self.closeLb then
 --                self.closeLb:setVisible(false)
 --            end
 --        else
 --            if self.switchSp then
 --                self.switchSp:setPosition(ccp(posX-self.switchSp:getContentSize().width/2+spacex,posY))
 --            end
 --            if self.openLb then
 --                self.openLb:setVisible(false)
 --            end
 --            if self.closeLb then
 --                self.closeLb:setVisible(true)
 --            end
 --        end
 --    end
 --    local switchScale=1.2
 --    local bgScale=1.1
 --    local capInSet = CCRect(25, 25, 1, 1)
 --    local function cellClick(hd,fn,idx)
 --    end
 --    self.switchSp=LuaCCSprite:createWithSpriteFrameName("raids_switch_btn.png",switchState)
 --    self.switchSp:setTouchPriority(-(self.layerNum-1)*20-4)
 --    self.bgLayer:addChild(self.switchSp,3)
 --    self.switchSp:setScaleX(switchScale)
 --    local switchOnBg=LuaCCScale9Sprite:createWithSpriteFrameName("raids_switch_on.png",capInSet,cellClick)
 --    switchOnBg:setContentSize(CCSizeMake(self.switchSp:getContentSize().width*bgScale,switchOnBg:getContentSize().height))
 --    switchOnBg:setAnchorPoint(ccp(1,0.5))
 --    switchOnBg:setPosition(ccp(posX,posY))
 --    self.bgLayer:addChild(switchOnBg,2)
 --    self.openLb=GetTTFLabelWrap(getlocal("elite_challenge_raid_btn"),22,CCSizeMake(self.switchSp:getContentSize().width*bgScale,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
 --    self.openLb:setPosition(getCenterPoint(switchOnBg))
 --    switchOnBg:addChild(self.openLb,1)
 --    local switchOffBg=LuaCCScale9Sprite:createWithSpriteFrameName("raids_switch_off.png",capInSet,cellClick)
 --    switchOffBg:setContentSize(CCSizeMake(self.switchSp:getContentSize().width*bgScale,switchOffBg:getContentSize().height))
 --    switchOffBg:setAnchorPoint(ccp(0,0.5))
 --    switchOffBg:setPosition(ccp(posX,posY))
 --    self.bgLayer:addChild(switchOffBg,2)
 --    self.closeLb=GetTTFLabelWrap(getlocal("city_info_attack"),22,CCSizeMake(self.switchSp:getContentSize().width*bgScale,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
 --    self.closeLb:setPosition(getCenterPoint(switchOffBg))
 --    switchOffBg:addChild(self.closeLb,1)
 --    if self.isRaidsOn and self.isRaidsOn==1 then
 --        self.switchSp:setPosition(ccp(posX+self.switchSp:getContentSize().width/2-spacex,posY))
 --        self.closeLb:setVisible(false)
 --    else
 --        self.switchSp:setPosition(ccp(posX-self.switchSp:getContentSize().width/2+spacex,posY))
 --        self.openLb:setVisible(false)
 --    end


    local function menuToggleFunc()
        PlayEffect(audioCfg.mouseClick)

        local isRaidsOn=self.switchMenuToggle:getSelectedIndex()
        CCUserDefault:sharedUserDefault():setIntegerForKey(dataKey,isRaidsOn)
        CCUserDefault:sharedUserDefault():flush()
        print("isRaidsOn:",isRaidsOn)
    end
    local function nilFunc()
    end
    local toggleState=CCUserDefault:sharedUserDefault():getIntegerForKey(dataKey)
    if toggleState==nil then
    	toggleState=0
    end
    print("toggleState",toggleState)
    local turnOnItem = GetButtonItem("raids_switch_on.png","btn_switch_middle.png","btn_switch_middle.png",nilFunc,nil,"",22,66,nil,nil,openStr,ccp(50,33))
    local turnOffItem = GetButtonItem("raids_switch_off.png","btn_switch_middle.png","btn_switch_middle.png",nilFunc,nil,"",22,67,nil,nil,closeStr,ccp(95,33))
    self.switchMenuToggle = CCMenuItemToggle:create(turnOffItem)
    self.switchMenuToggle:addSubItem(turnOnItem)
    self.switchMenuToggle:setAnchorPoint(CCPointMake(0.5,0.5))
    self.switchMenuToggle:setPosition(0,0)
    self.switchMenuToggle:setSelectedIndex(toggleState)
    self.switchMenuToggle:registerScriptTapHandler(menuToggleFunc)
    local switchMenu = CCMenu:create()
    switchMenu:addChild(self.switchMenuToggle)
    switchMenu:setPosition(ccp(posX,posY))
    switchMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(switchMenu,6)

end

function checkPointDialog:updateHeader()
	local isShowTech=checkPointVoApi:isShowTech(self.sid)
	local cRewardCfg=checkPointVoApi:getCRewardCfgBySid(self.sid)
	if cRewardCfg and SizeOfTable(cRewardCfg)>0 and ((isShowTech==true and checkPointVoApi:getTechFlag()~=-1) or newGuidMgr:isNewGuiding()==true) then
		local techData=checkPointVoApi:getTechData()
		local tech={0,0,0}
		local ssid="s"..self.sid
		if techData and techData[ssid] then
			tech=techData[ssid]
		end
		local checkPointVo=checkPointVoApi:getCheckPointVoBySid(self.sid)
		local starNum
		if checkPointVo and checkPointVo.starNum then
			starNum=checkPointVo.starNum
		else
			starNum=0
		end
		if self.rewardBg==nil then
		    local capInSet = CCRect(20, 20, 10, 10)
		    local function cellClick(hd,fn,idx)
		    end
			self.rewardBg=LuaCCScale9Sprite:createWithSpriteFrameName("HelpHeaderBg.png",capInSet,cellClick)
		    self.rewardBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-70,150))
		    -- local scaleX=(self.bgLayer:getContentSize().width-70)/self.rewardBg:getContentSize().width
		    -- self.rewardBg:setScaleX(scaleX)
		    self.rewardBg:setAnchorPoint(ccp(0,1))
		    -- self.rewardBg:setPosition(ccp(25,self.bgLayer:getContentSize().height-170+10))
		    self.bgLayer:addChild(self.rewardBg,1)

		    local lbWidth=180
		    local rewardLb = GetTTFLabelWrap(getlocal("checkPointReward"),25,CCSizeMake(lbWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			rewardLb:setAnchorPoint(ccp(0.5,0.5))
		    rewardLb:setPosition(ccp(lbWidth/2,self.rewardBg:getContentSize().height-35))
			self.rewardBg:addChild(rewardLb,1)
			rewardLb:setColor(G_ColorYellowPro)

			local hasRewardLb = GetTTFLabelWrap(getlocal("activity_vipAction_had"),20,CCSizeMake(lbWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			hasRewardLb:setAnchorPoint(ccp(0.5,0.5))
		    hasRewardLb:setPosition(ccp(lbWidth/2,self.rewardBg:getContentSize().height/2))
			self.rewardBg:addChild(hasRewardLb,1)

			local star1=CCSprite:createWithSpriteFrameName("StarIcon.png")
			star1:setAnchorPoint(ccp(0.5,0.5))
		    star1:setPosition(ccp(lbWidth/2+25,self.rewardBg:getContentSize().height/2-40))
			self.rewardBg:addChild(star1,1)
			star1:setScale(0.8)

		    self.scheduleLb=GetTTFLabel(getlocal("scheduleChapter",{starNum,checkPointVoApi:getCheckPointStarNum()}),20)
			self.scheduleLb:setAnchorPoint(ccp(0.5,0.5))
		    self.scheduleLb:setPosition(ccp(lbWidth/2-15,self.rewardBg:getContentSize().height/2-40))
			self.rewardBg:addChild(self.scheduleLb,1)

			-- local testReward={p={{p19=1,index=1},{p20=1,index=2}},o={{a10001=10,index=3}}}
			-- local cRewardCfg=checkPointVoApi:getCRewardCfgBySid(self.sid)
			local content=cRewardCfg.content
			for k,v in pairs(content) do
				local needStar=v.star
				local reward=v.reward
				local rewardTab=FormatItem(reward)
				local item=rewardTab[1]
				local isReward=tech[k]

				local posX=200+100/2+(k-1)*125
				local size=100
				local function rewardHandler()
					if otherGuideMgr.isGuiding and otherGuideMgr.curStep==40 then
				        otherGuideMgr:toNextStep()
				    end
					local techData1=checkPointVoApi:getTechData()
					local tech1={0,0,0}
					local ssid1="s"..self.sid
					if techData1 and techData1[ssid1] then
						tech1=techData1[ssid1]
					end
					local isReward1=tech1[k]

					local checkPointVo1=checkPointVoApi:getCheckPointVoBySid(self.sid)
					local starNum1
					if checkPointVo1 and checkPointVo1.starNum then
						starNum1=checkPointVo1.starNum
					else
						starNum1=0
					end
					if isReward1==0 and starNum1>=needStar then
						local sid=cRewardCfg.sid
					    local category=k
						local function challengeGetrewardCallback(fn,data)
					        local ret,sData=base:checkServerData(data)
					        if ret==true then
					            if sData and sData.data then
					            	checkPointVoApi:setReward(self.sid,k)

								    G_addPlayerAward(item.type,item.key,item.id,tonumber(item.num),nil,true)
								    if item.type=="c" then
								    	local techStr=getlocal(item.name,{item.num})
								    	local rewardStr=getlocal("challenge_tech_reward_tip",{sid,needStar,techStr})
								    	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),rewardStr,30)
								    else
								    	-- G_showRewardTip({item})
								    	local awardStr=item.name.."*"..item.num
								    	local rewardStr=getlocal("challenge_tech_common_reward_tip",{sid,needStar,awardStr})
								    	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),rewardStr,30)
								    end

		                            self:refresh()

		                            storyScene:updateHeadTech()
					            end
					        end
					    end
					    socketHelper:challengeGetreward(sid,category,challengeGetrewardCallback)
						return false
					else
						return true
					end
				end
				local icon,iconScale=G_getItemIcon(item,size,true,self.layerNum+1,rewardHandler)
				icon:setPosition(ccp(posX,self.rewardBg:getContentSize().height/2+10))
				icon:setTouchPriority(-(self.layerNum-1)*20-4)
				self.rewardBg:addChild(icon,1)

				if item.type~="c" then
					local numLb=GetTTFLabel("x"..item.num,25)
					numLb:setAnchorPoint(ccp(1,0))
					numLb:setPosition(ccp(icon:getContentSize().width-5,5))
					icon:addChild(numLb,1)
					numLb:setScale(1/iconScale)
				end

				local num=needStar
				local starLb=GetTTFLabel(num,20)
				starLb:setAnchorPoint(ccp(0.5,0.5))
			    starLb:setPosition(ccp(posX-15,20))
				self.rewardBg:addChild(starLb,1)
				if starNum<num then
					starLb:setColor(G_ColorRed)
				end

				local star=CCSprite:createWithSpriteFrameName("StarIcon.png")
				star:setAnchorPoint(ccp(0.5,0.5))
			    star:setPosition(ccp(posX+17,20))
				self.rewardBg:addChild(star,1)
				star:setScale(0.8)

				local function tmpFunc()
			    end
			    local maskSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),tmpFunc)
			    maskSp:setOpacity(255)
			    local spSize=CCSizeMake(icon:getContentSize().width,icon:getContentSize().height)
			    maskSp:setContentSize(spSize)
			    maskSp:setPosition(getCenterPoint(icon))
			    maskSp:setTag(11)
			    icon:addChild(maskSp,2)
			    if isReward==1 then
			    	maskSp:setVisible(true)
			    else
			    	maskSp:setVisible(false)
			    end

			    local flicker
			    if starNum>=needStar and isReward==0 then
			    	flicker=G_addRectFlicker(icon,1.4*1/iconScale,1.4*1/iconScale)
			    end
			    table.insert(self.iconTab,{icon=icon,iconScale=iconScale,flicker=flicker,starLb=starLb})
			end
		end

		-- local cRewardCfg=checkPointVoApi:getCRewardCfgBySid(self.sid)
		local content=cRewardCfg.content
		if self.iconTab and SizeOfTable(self.iconTab)>0 then
			for k,v in pairs(self.iconTab) do
				if v.icon and v.iconScale then
					local isReward=tech[k]

					local icon=tolua.cast(v.icon,"LuaCCSprite")
					local maskSp=tolua.cast(icon:getChildByTag(11),"LuaCCScale9Sprite")
				    if isReward==1 then
				    	maskSp:setVisible(true)
				    else
				    	maskSp:setVisible(false)
				    end
					local iconScale=v.iconScale

					if content and content[k] then
						local rCfg=content[k]
						if rCfg and starNum>=rCfg.star and isReward==0 then
							if v.flicker==nil then
								self.iconTab[k].flicker=G_addRectFlicker(icon,1.4*1/iconScale,1.4*1/iconScale)
							end
						else
							if v.flicker then
								G_removeFlicker(icon)
								self.iconTab[k].flicker=nil
							end
						end
						if v.starLb then
							local lb=tolua.cast(v.starLb,"CCLabelTTF")
							if lb then
								if rCfg and starNum<rCfg.star then
									lb:setColor(G_ColorRed)
								else
									lb:setColor(G_ColorWhite)
								end
							end
						end
					end

				end
			end
		end

		self.rewardBg:setPosition(ccp(25,self.bgLayer:getContentSize().height-170+8))
	else
		if self.rewardBg then
			self.rewardBg:setPosition(ccp(0,999999))
		end
	end
end

function checkPointDialog:reloadTableView()
	local isShowTech=checkPointVoApi:isShowTech(self.sid)
	if newGuidMgr:isNewGuiding()==true then
		isShowTech=true
	end
	if isShowTech==true then
		self.tvHeight=self.bgLayer:getContentSize().height-270-150
	else
		self.tvHeight=self.bgLayer:getContentSize().height-270
	end
	if G_isIphone5() then
        self.spaceY=self.tvHeight/4-10
    end
	if self and self.tv then
		self.tv:removeFromParentAndCleanup(true)
		self.tv=nil
	end
	local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30, 100+5))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(150)

    self.backSprie:setContentSize(CCSizeMake(self.tvWidth,self.tvHeight+10))

    
    local unlockSid=checkPointVoApi:getUnlockChapterSid()
    local chapterNum=checkPointVoApi:getChapterNum()
    local leftNum=(unlockSid%chapterNum)
    if isShowTech==true and G_isIphone5()==false and leftNum>=13 and leftNum<=chapterNum then
    	local recordPoint = self.tv:getRecordPoint()
    	recordPoint.y=0
    	self.tv:recoverToRecordPoint(recordPoint)
    end


    self:resetForbidLayer()
end	

function checkPointDialog:resetForbidLayer()
	if self and self.topforbidSp and self.bottomforbidSp then
    	-- if isShowReward==true then
     --        self.topforbidSp:setPosition(ccp(0,self.tvHeight+100))
     --        self.topforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, self.bgLayer:getContentSize().height-self.tvHeight-100))
     --    elseif (self.selectedTabIndex==1) then
            self.topforbidSp:setPosition(ccp(0,self.tvHeight+100))
            self.topforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, self.bgLayer:getContentSize().height-self.tvHeight-100))
            self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 100))
        -- end
    end
end

function checkPointDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return 1
	elseif fn=="tableCellSizeForIndex" then
	    local tmpSize
		-- tmpSize=CCSizeMake(self.tvWidth,self.bgLayer:getContentSize().height-260)
	    if self.tvHeight>self.cellMinHeight then
	    	tmpSize=CCSizeMake(self.tvWidth,self.tvHeight)
	    else
	    	tmpSize=CCSizeMake(self.tvWidth,self.cellMinHeight)
	    end
	    return  tmpSize
	elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local checkPointCfg = checkPointVoApi:getCfgBySid(self.sid)
		local checkPointVo = checkPointVoApi:getCheckPointVoBySid(self.sid)
		-- local isShow=true
		-- if checkPointVo.chapterTab==nil or SizeOfTable(checkPointVo.chapterTab)==0 or (checkPointVo.sid==1 and checkPointVo.chapterTab[1].starNum==0) then
		-- 	isShow=false
		-- end

		local isShow=self.isShow

		if self.flicker then
			self.flicker:removeFromParentAndCleanup(true)
			self.flicker=nil
		end

	    local checkPointList=Split(checkPointCfg.checkPointList,",")
		for k,v in pairs(checkPointList) do
			local chapterCfg = checkPointVoApi:getCfgBySid(v)
			local posX = 110+(tonumber(chapterCfg.index)%4)*self.spaceX-30
	        -- local hei =(self.bgLayer:getContentSize().height-100)/4
			-- local posY = self.bgLayer:getContentSize().height-250-math.floor(tonumber(chapterCfg.index)/4)*self.spaceY-100
			
			-- local posY = self.bgLayer:getContentSize().height-260-math.floor(tonumber(chapterCfg.index)/4)*self.spaceY-100
			local cHeight=self.cellMinHeight
			if self.tvHeight>self.cellMinHeight then
		    	cHeight=self.tvHeight
		    end
		    local posY = cHeight-math.floor(tonumber(chapterCfg.index)/4)*self.spaceY-100
			

			local chapterData = checkPointVoApi:getUnlockChapter(self.sid,tonumber(chapterCfg.index)+1)
	        self.chapterTab[chapterCfg.index]={}
			if chapterCfg and chapterCfg.style then 
				local function attackHandler(object,name,tag)
					if checkPointVoApi:getUnlockChapter(self.sid,tonumber(chapterCfg.index)+1).isUnlock then
	                    if self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
		                    if G_checkClickEnable()==false then
								do return end
							else
								base.setWaitTime=G_getCurDeviceMillTime()
							end
		                    PlayEffect(audioCfg.mouseClick)

		                    if newGuidMgr:isNewGuiding() then --新手引导
		                    	checkPointVoApi:showTankStoryDialog(tag)
                                newGuidMgr:toNextStep()
                                do return end
		                    end
		                    local dataKey="challengeRaids@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
                            local isRaidsOn=CCUserDefault:sharedUserDefault():getIntegerForKey(dataKey)
		                    if base.raids==1 and isRaidsOn and isRaidsOn==1 then
                                local chapter=checkPointVoApi:getUnlockChapter(self.sid,tonumber(chapterCfg.index)+1)
                                if chapter and chapter.starNum>=challengeRaidCfg.needStar then
    		                    	checkPointVoApi:showRaidsSmallDialog(self.layerNum+1,self.sid,tonumber(chapterCfg.index)+1)
                                else
                                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("raids_can_not_raids2"),30)
                                end
		                    else
		                    	checkPointVoApi:showTankStoryDialog(tag)
		                    end
		                end
					end
				end
				local shipIcon=LuaCCSprite:createWithSpriteFrameName(chapterCfg.style,attackHandler)
			    shipIcon:setPosition(ccp(posX,posY))
			    shipIcon:setTouchPriority(-(self.layerNum-1)*20-2)
				shipIcon:setIsSallow(false)
				shipIcon:setTag(v)	
				shipIcon:setVisible(isShow)
				shipIcon:setScale(0.9)
				cell:addChild(shipIcon,2)
	            self.chapterTab[chapterCfg.index].shipIcon=shipIcon
	            if newGuidMgr:isNewGuiding()==true and newGuidMgr.curStep==11 and chapterCfg.index=="0" then
	            	self.guildItem=shipIcon
	            end
	            -- if chapterCfg and chapterCfg.iselite then
	            -- 	local eliteSp = CCSprite:createWithSpriteFrameName("IconTip.png")
	            -- 	shipIcon:addChild(eliteSp,4)
	            -- 	eliteSp:setAnchorPoint(ccp(0.5,0.5))
	            -- 	eliteSp:setPosition(shipIcon:getContentSize().width/2+40,shipIcon:getContentSize().height/2+45)
	            -- 	eliteSp:setScale(1/shipIcon:getScale())
	            -- end

				if newGuidMgr:isNewGuiding() then --新手引导
		                	
				else
					local unlockSid=checkPointVoApi:getUnlockChapterSid()
					if tostring(unlockSid)==tostring(v) then
						local xPos1,yPos1=shipIcon:getPosition()
						self.flicker=self:addFlicker(cell,ccp(xPos1,yPos1))
						self.flicker:setVisible(isShow)
					end
		        end


	            local style1=Split(chapterCfg.style,".png")
	            local style1Str=style1[1].."_1.".."png"
	            local tankSp1=CCSprite:createWithSpriteFrameName(style1Str);
				self.chapterTab[chapterCfg.index].tankSp=tankSp1
	            if tankSp1~=nil then
	                tankSp1:setPosition(getCenterPoint(shipIcon))
	                shipIcon:addChild(tankSp1)
					--[[
					local unlockSid=checkPointVoApi:getUnlockChapterSid()
					if tostring(unlockSid)==tostring(v) then
				        local fadeOut=CCTintTo:create(0.5,80,80,80)
				        local fadeIn=CCTintTo:create(0.5,255,255,255)
				        local seq=CCSequence:createWithTwoActions(fadeOut,fadeIn)
						local repeatForever=CCRepeatForever:create(seq)
						shipIcon:runAction(repeatForever)
					end
					if tostring(unlockSid)==tostring(v) then
				        local fadeOut1=CCTintTo:create(0.5,80,80,80)
				        local fadeIn1=CCTintTo:create(0.5,255,255,255)
				        local seq1=CCSequence:createWithTwoActions(fadeOut1,fadeIn1)
						local repeatForever1=CCRepeatForever:create(seq1)
						tankSp1:runAction(repeatForever1)
					end
					]]
	            end

				
				if not chapterData.isUnlock then
					--local lockSp=CCSprite:createWithSpriteFrameName("LockIconCheckPoint.png")
					local lockSp=CCSprite:createWithSpriteFrameName("LockIcon.png")
				    lockSp:setPosition(ccp(posX,posY+10))
					lockSp:setScaleX(0.7)
					lockSp:setScaleY(0.7)
					cell:addChild(lockSp,3)
	                self.chapterTab[chapterCfg.index].lockSp=lockSp
					lockSp:setVisible(isShow)
				end
			end
	        
	        self.chapterTab[chapterCfg.index].starTab={}
			for i=1,checkPointVoApi:getChapterStarNum() do
				local cStar
				local starNumber=chapterData.starNum or 0
				if i<=starNumber then
					cStar=CCSprite:createWithSpriteFrameName("StarIcon.png")
				else
					cStar=CCSprite:createWithSpriteFrameName("starIconEmpty.png")
				end

			    cStar:setPosition(ccp(posX+cStar:getContentSize().width*(i-2),posY-40))
				cell:addChild(cStar,2)
	            table.insert(self.chapterTab[chapterCfg.index].starTab,i,cStar)
				cStar:setVisible(isShow)
			end

		end

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
		
    elseif fn=="ccScrollEnable" then
		if newGuidMgr:isNewGuiding()==true then
		     return 0
		else
		     return 1
		end
    end
end


function checkPointDialog:getDataByType()
    if newGuidMgr:isNewGuiding() then
    	self.isShow=true
    	self:refresh()
		do return end
    end
	local checkPointVo=checkPointVoApi:getCheckPointVoBySid(self.sid)
	if checkPointVo.chapterTab==nil or SizeOfTable(checkPointVo.chapterTab)==0 or (checkPointVo.sid==1 and checkPointVo.chapterTab[1].starNum==0) then
		local function showStoryScene(fn,data)
			if base:checkServerData(data)==true then
				self.isShow=true
			    self:refresh()										
			end
		end
		local maxsid=self.sid*16
		local minsid=maxsid-15
        if self.sid==nil or self.sid==0 then
            maxsid=16
            minsid=1
        end
		socketHelper:challengelist(minsid,maxsid,showStoryScene)
	else
		self.isShow=true
		self:refresh()
	end
end

function checkPointDialog:refresh()
	if self~=nil and self.bgLayer~=nil then
	    local checkPointCfg = checkPointVoApi:getCfgBySid(self.sid)
		local checkPointVo = checkPointVoApi:getCheckPointVoBySid(self.sid)
	    local starNum
		if checkPointVo and checkPointVo.starNum then
			starNum=checkPointVo.starNum
		else
			starNum=0
		end
	    self.starLabel:setString(getlocal("scheduleChapter",{starNum,checkPointVoApi:getCheckPointStarNum()}))
		if self.scheduleLb then
			self.scheduleLb:setString(getlocal("scheduleChapter",{starNum,checkPointVoApi:getCheckPointStarNum()}))
		end

		if self.flicker then
			self.flicker:removeFromParentAndCleanup(true)
			self.flicker=nil
		end

		self:updateHeader()
		self:reloadTableView()

		-- local cRewardCfg=checkPointVoApi:getCRewardCfgBySid(checkPointVo.sid)
		-- local content=cRewardCfg.content
		-- if self.iconTab and SizeOfTable(self.iconTab)>0 then
		-- 	for k,v in pairs(self.iconTab) do
		-- 		if v.icon and v.iconScale then
		-- 			local isReward=0

		-- 			local icon=tolua.cast(v.icon,"LuaCCSprite")
		-- 			local maskSp=tolua.cast(icon:getChildByTag(11),"LuaCCScale9Sprite")
		-- 		    if isReward==1 then
		-- 		    	maskSp:setVisible(true)
		-- 		    else
		-- 		    	maskSp:setVisible(false)
		-- 		    end
		-- 			local iconScale=v.iconScale
		-- 			-- G_removeFlicker(v.icon)

		-- 			if content and content[k] then
		-- 				local rCfg=content[k]
		-- 				if v.flicker==nil then
		-- 					if rCfg and starNum>=rCfg.star and isReward==0 then
		-- 						self.iconTab[k].flicker=G_addRectFlicker(icon,1.4*1/iconScale,1.4*1/iconScale)
		-- 					end
		-- 				end
		-- 				if v.starLb then
		-- 					local lb=tolua.cast(v.starLb,"CCLabelTTF")
		-- 					if lb then
		-- 						if rCfg and starNum<rCfg.star then
		-- 							lb:setColor(G_ColorRed)
		-- 						else
		-- 							lb:setColor(G_ColorWhite)
		-- 						end
		-- 					end
		-- 				end
		-- 			end

		-- 		end
		-- 	end
		-- end


	end
end

function checkPointDialog:addFlicker(parentBg,pos)
	if parentBg then
		local targetSp = CCSprite:createWithSpriteFrameName("target_1.png")
	    targetSp:setAnchorPoint(ccp(0.5,0.5))
	    --targetSp:setPosition(getCenterPoint(parentBg))
		targetSp:setPosition(pos)
		parentBg:addChild(targetSp,5)
		local scaleTo1=CCScaleTo:create(0.5,1)
		local scaleTo2=CCScaleTo:create(0.5,0.8)
		local seq=CCSequence:createWithTwoActions(scaleTo1,scaleTo2)
		local repeatForever=CCRepeatForever:create(seq)
		targetSp:runAction(repeatForever)
		return targetSp
	end
	return nil
end

function checkPointDialog:tick()
	if self.energyLabel then
	    if playerVoApi:getEnergy()>=20 then
			energyStr = getlocal("current_energy")..getlocal("scheduleChapter",{playerVoApi:getEnergy(),checkPointVoApi:getMaxEnergy()})
	        self.energyLabel:setString(energyStr)
	    else
	    	-- local per=playerVoApi:getPerEnergyRecoverTime()
			--if self.energycd~=playerVoApi:getPlayerEnergycd() then
				self.enTime=playerVoApi:getEnergyRecoverLeftTime()
			    -- self.enTimeCount=playerVoApi:getPlayerEnergycd()/per
				--end
			
	        energyStr = getlocal("current_energy")..getlocal("scheduleChapter",{playerVoApi:getEnergy(),checkPointVoApi:getMaxEnergy()}).."("..GetTimeStr(self.enTime)..")"
	        self.energyLabel:setString(energyStr)
			
	        -- self.enTime=self.enTime-1
	        -- if self.enTime<=0 then
	        --     playerVo.energy=playerVo.energy+1
	        --     if self.enTimeCount>0 then
	        --         self.enTime=1800
	        --         self.enTimeCount=self.enTimeCount-1
	        --     end
	        -- end
	    end
	end
end

function checkPointDialog:setHide()
    if self.bgLayer then
        self.bgLayer:setVisible(false)
    end
end
function checkPointDialog:setShow()
    if self.bgLayer then
        self.bgLayer:setVisible(true)
    end
end
function checkPointDialog:dispose()
	self.sid=nil
    self.starLabel=nil
    self.chapterTab=nil
    self.energyLabel=nil
	if G_WeakTb.checkPoint then
		G_WeakTb.checkPoint=nil
	end
	self.flicker=nil
	self.enTime=nil
    self.enTimeCount=nil
	self.energycd=nil
	self.isShow=nil
	self.iconTab=nil
	self.rewardBg=nil
	self.scheduleLb=nil
    self.switchSp=nil
    self.openLb=nil
    self.closeLb=nil
    self.guildItem=nil
    self=nil
end

