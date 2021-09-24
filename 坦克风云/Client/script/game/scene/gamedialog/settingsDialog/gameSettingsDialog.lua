--require "luascript/script/componet/commonDialog"
gameSettingsDialog=commonDialog:new()

function gameSettingsDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
	self.btnTab={}
	self.switchTab={}
	self.pushTb={}
	self.pushNameTb={}
	self.settingTb={}
    return nc
end


--设置对话框里的tableView
function gameSettingsDialog:initTableView()
	self.pushTb,self.pushNameTb=pushController:getAllPushModules()
	-- self.settingTb=G_GameSettings
	self.settingTb=G_clone(G_GameSettings)
	if G_getCurChoseLanguage()=="ja" then
		table.insert(self.settingTb,"gameSettings_vipLevelShow")
	end

	if G_getGameUIVer()~=2 then
		if base.isWinter then
			table.insert(self.settingTb,"gameSettings_seasonEffect2017")
			local curSkin=skinMgr:getCurrentSkin()
			if(curSkin~="winter2017")then
				CCUserDefault:sharedUserDefault():setIntegerForKey("gameSettings_seasonEffect2017",1)
			end
		end
	end

	if base.dnews == 1 then
		-- 每日捷报开关
		table.insert(self.settingTb, "gameSetting_dailyNewspaper")
	end

	if CCUserDefault:sharedUserDefault():getIntegerForKey("gameSetting_legionCityEnemyAlert")==0 then
		CCUserDefault:sharedUserDefault():setIntegerForKey("gameSetting_legionCityEnemyAlert",2)
	end
	if G_checkUseAuditUI()==true or base.allianceCitySwitch == 0 then

	else
		table.insert(self.settingTb,"gameSetting_legionCityEnemyAlert")
	end

	if CCUserDefault:sharedUserDefault():getIntegerForKey("gameSetting_newMainUI")==0 then
		G_setGameUIVer(2)
	end
	if base.newUIOff == 0 then
		table.insert(self.settingTb,"gameSetting_newMainUI")
	end

	self.panelLineBg:setVisible(false)
	
    local function callBack(...)
		return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-20,self.bgLayer:getContentSize().height-110),nil)
    self.bgLayer:setTouchPriority(-61)
    self.tv:setTableViewTouchPriority(-63)
    self.tv:setPosition(ccp(10,20))
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(0)
end


function gameSettingsDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		local num=#self.pushTb+#self.settingTb
		return num	
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		if idx==0 or idx==#self.pushTb then
			tmpSize=CCSizeMake(400,130)
		else
			tmpSize=CCSizeMake(400,80)
		end
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		
	    local function cellClick(hd,fn,idx)
	    end
		if idx==0 or idx==#self.pushTb then
			local subTitleStr=""
			if idx==0 then
				subTitleStr="subTitile1"
			else
				subTitleStr="subTitile2"
			end
			local subTitleSprie=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(10,10,28,28),cellClick)
			subTitleSprie:ignoreAnchorPointForPosition(false)
			subTitleSprie:setIsSallow(false)
			subTitleSprie:setTouchPriority(-62)
		    subTitleSprie:setAnchorPoint(ccp(0.5,0))
		    subTitleSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-30, 50))
		    subTitleSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2-10,80))
		    cell:addChild(subTitleSprie,1)
			
		    local subTitleLabel=GetTTFLabel(getlocal(subTitleStr),24,true)
			subTitleLabel:setAnchorPoint(ccp(0,0.5))
		    subTitleLabel:setPosition(ccp(10,subTitleSprie:getContentSize().height/2))
		    subTitleSprie:addChild(subTitleLabel,2)
		end
		
		local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
		backSprie:ignoreAnchorPointForPosition(false)
		backSprie:setIsSallow(false)
		backSprie:setTouchPriority(-62)
	    backSprie:setAnchorPoint(ccp(0.5,0))
	    backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40, 80))
	    backSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2-10,0))
	    cell:addChild(backSprie,1)
		
		local settingStrTab
		local isPush
		local index
		if(idx<#self.pushTb)then
			isPush=true
			index=idx+1
			if(pushController:checkPushServiceVersion()==1)then
				settingStrTab=Split(self.pushTb[index],"_")[2]
			else
				settingStrTab="pushSettings_"..self.pushNameTb[index]
			end
		else
			isPush=false
			index=idx+1-#self.pushTb
			settingStrTab=Split(self.settingTb[index],"_")[2]
		end
	    local itemLabel=GetTTFLabelWrap(getlocal(settingStrTab),24,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		itemLabel:setAnchorPoint(ccp(0,0.5))
	    itemLabel:setPosition(ccp(10,backSprie:getContentSize().height/2))
	    backSprie:addChild(itemLabel,2)

	    local tabBtn=CCMenu:create()
		local switchSp1 = CCSprite:createWithSpriteFrameName("switch-off.png")
        local switchSp2 = CCSprite:createWithSpriteFrameName("switch-off.png")
        local menuItemSp1 = CCMenuItemSprite:create(switchSp1,switchSp2)
		local switchSp3 = CCSprite:createWithSpriteFrameName("switch-on.png")
		local switchSp4 = CCSprite:createWithSpriteFrameName("switch-on.png")
		local menuItemSp2 = CCMenuItemSprite:create(switchSp3,switchSp4)
        local tabBtnItem = CCMenuItemToggle:create(menuItemSp1)
		tabBtnItem:addSubItem(menuItemSp2)
		tabBtnItem:setAnchorPoint(CCPointMake(0,0))
		tabBtnItem:setPosition(0,0)
		
		local function operateHandler(tag,object)
			PlayEffect(audioCfg.mouseClick)
			local switch=self.btnTab[tag]:getSelectedIndex()
			local isPush
			local index
			if(tag>#self.pushTb)then
				isPush=false
				index=tag-#self.pushTb
			else
				isPush=true
				index=tag
			end
			local settingsKey
			if(isPush and pushController:checkPushServiceVersion()==1)then
				settingsKey=self.pushTb[index]
			elseif(isPush==false)then
				settingsKey=self.settingTb[index]
			end
			if switch==1 then
				self.switchTab[tag]:setString(getlocal("open_setting"))
				if isPush==false and self.settingTb[index]=="gameSettings_autoDefence" then --打开自动补充防御舰队
					local function gameSettingsCallback(fn,data)
						if base:checkServerData(data)==true then
					        CCUserDefault:sharedUserDefault():setIntegerForKey(settingsKey,2)
					        CCUserDefault:sharedUserDefault():flush()
						end
					end
					local sid="s"..4
					local autoSwitch=1
					socketHelper:gameSettings(sid,autoSwitch,gameSettingsCallback)
				else
					if(settingsKey)then
				        if settingsKey == "gameSetting_newMainUI" then
				        	tabBtnItem:setSelectedIndex(0)
				        	self.switchTab[tag]:setString(getlocal("close_setting"))
				        	local popKey="gameSetting.newMainUI"
				        	local function confirmHandler( ... )
				        		G_setGameUIVer(2)
					        	G_backToLoginScene(true) --返回登录页面
					        end
				        	local function secondTipFunc(sbFlag)	
				        		local sValue=base.serverTime .. "_" .. sbFlag
        						G_changePopFlag(popKey,sValue)						    
			        		end
			        		G_dailyConfirm("newui.set", getlocal("newMainUI_secondConfirm"), confirmHandler, self.layerNum + 1, base.serverTime)
			        	else
			        		CCUserDefault:sharedUserDefault():setIntegerForKey(settingsKey,2)
				        	CCUserDefault:sharedUserDefault():flush()
				        end
			    	end
			        if(isPush)then
			        	if(pushController:checkPushServiceVersion()~=1)then
				        	pushController:openModule(index)
				        end
			        else
			        	--打开背景音乐
			        	if(self.settingTb[index]=="gameSettings_musicSetting")then
			        		PlayBackGroundEffect(audioCfg.backGround)
			        	--重置主线任务引导时间
			        	elseif(self.settingTb[index]=="gameSettings_mainTaskGuide")then
			        		mainUI.m_mtRefresh=true
			        	--打开卫星地图
			        	elseif(self.settingTb[index]=="gameSettings_miniMapSetting")then
			        		mainUI:switchMiniMap(true)
			        	elseif(self.settingTb[index]=="gameSettings_seasonEffect2017") then
			        		skinMgr:setSkin("winter2017")
			        	end
			        end
				end
			else
				self.switchTab[tag]:setString(getlocal("close_setting"))
				if isPush==false and self.settingTb[index]=="gameSettings_autoDefence" then --关闭自动补充防御舰队
					local function gameSettingsCallback(fn,data)
						if base:checkServerData(data)==true then
					        CCUserDefault:sharedUserDefault():setIntegerForKey(settingsKey,1)
					        CCUserDefault:sharedUserDefault():flush()
						end
					end
					local sid="s"..4
					local autoSwitch=0
					socketHelper:gameSettings(sid,autoSwitch,gameSettingsCallback)
				else
					if(settingsKey)then
				        if settingsKey == "gameSetting_newMainUI" then
				        	self.switchTab[tag]:setString(getlocal("open_setting"))
							tabBtnItem:setSelectedIndex(1)
				        	local function confirmHandler( ... )
				        		G_setGameUIVer(1)
					        	G_backToLoginScene(true) --返回登录页面
					        	statisticsHelper:uploadOption("ui")
					        end
				        	local function secondTipFunc( sbFlag )
				        		local sValue=base.serverTime .. "_" .. sbFlag
        						G_changePopFlag(popKey,sValue)
				        	end
			        		G_dailyConfirm("newui.set", getlocal("newMainUI_secondConfirm"), confirmHandler, self.layerNum + 1, base.serverTime)
				        	return
				        else
				        	CCUserDefault:sharedUserDefault():setIntegerForKey(settingsKey,1)
				        	CCUserDefault:sharedUserDefault():flush()
				        end
				    end
			        if(isPush)then
			        	if(pushController:checkPushServiceVersion()==1)then
			        		if(self.pushTb[index]=="gameSettings_jobDown")then
								deviceHelper:removeAllPushByTag(G_BuildUpgradeTag)
								deviceHelper:removeAllPushByTag(G_TechUpgradeTag)
								deviceHelper:removeAllPushByTag(G_TankProduceTag)
								deviceHelper:removeAllPushByTag(G_TankUpgradeTag)
								deviceHelper:removeAllPushByTag(G_ItemProduceTag)
							elseif(self.pushTb[index]=="gameSettings_energyFull")then
								deviceHelper:removeAllPushByTag(G_EnergyFullTag)
							elseif(self.pushTb[index]=="gameSettings_pushWhole")then
								deviceHelper:removeAllPushByTag(G_timeTag)
								deviceHelper:removeAllPushByTag(G_timeTag2)
							end
			        	else
			        		pushController:closeModule(index)
			        	end
			        else
			        	if(self.settingTb[index]=="gameSettings_musicSetting")then --关闭背景音乐
			        		SimpleAudioEngine:sharedEngine():stopBackgroundMusic(true)
			        	elseif(self.settingTb[index]=="gameSettings_mainTaskGuide")then --重置主线任务引导时间
			        		mainUI.m_mtRefresh=true
			        	elseif(self.settingTb[index]=="gameSettings_miniMapSetting")then		--关闭卫星地图
			        		mainUI:switchMiniMap(false)
			        	elseif(self.settingTb[index]=="gameSettings_seasonEffect2017") then
			        		skinMgr:setSkin(0)
			        	end
			        end
				end
			end
		end
        tabBtnItem:registerScriptTapHandler(operateHandler)
		--游戏设置数据
		tabBtnItem:setSelectedIndex(0)
		
	    local switchLabel
		local settingsKey
		if(isPush and pushController:checkPushServiceVersion()==1)then
			settingsKey=self.pushTb[index]
		elseif(isPush==false)then
			settingsKey=self.settingTb[index]
		end
	    if settingsKey and CCUserDefault:sharedUserDefault():getIntegerForKey(settingsKey)==0 then
	        CCUserDefault:sharedUserDefault():setIntegerForKey(settingsKey,2)
	        CCUserDefault:sharedUserDefault():flush()
	    end
	    local openFlag
	    if(isPush)then
	    	if(pushController:checkPushServiceVersion()==1)then
	    		openFlag=pushController:checkModule(self.pushTb[index])
	    	else
		    	openFlag=pushController:checkModule(index)
		    end
	    else
	    	if settingsKey and CCUserDefault:sharedUserDefault():getIntegerForKey(settingsKey)==2 then
	    		openFlag=true
	    	else
	    		openFlag=false
	    	end
	    end
		if openFlag then
			switchLabel=GetTTFLabel(getlocal("open_setting"),24)
			tabBtnItem:setSelectedIndex(1)

		else
			tabBtnItem:setSelectedIndex(0)
			switchLabel=GetTTFLabel(getlocal("close_setting"),24)
		end
	    switchLabel:setPosition(getCenterPoint(tabBtnItem))
	    tabBtnItem:addChild(switchLabel,2)
		table.insert(self.switchTab,idx+1,switchLabel)
		
        tabBtn:addChild(tabBtnItem)
        tabBtnItem:setTag(idx+1)
		table.insert(self.btnTab,idx+1,tabBtnItem)
		tabBtn:setPosition(ccp(backSprie:getContentSize().width-switchSp1:getContentSize().width-10,backSprie:getContentSize().height/2-switchSp1:getContentSize().height/2))
		tabBtn:setTouchPriority(-62)
		backSprie:addChild(tabBtn,2)

		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end

function gameSettingsDialog:dispose()
	self.btnTab=nil
	self.switchTab=nil
    self=nil
end
