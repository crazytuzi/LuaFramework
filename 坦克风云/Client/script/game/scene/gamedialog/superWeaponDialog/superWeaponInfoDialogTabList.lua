--超级武器仓库tab
superWeaponInfoDialogTabList={}
function superWeaponInfoDialogTabList:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function superWeaponInfoDialogTabList:init(layerNum,parent)
	self.layerNum=layerNum
	self.parent=parent
	self.bgLayer=CCLayer:create()
	self:initTableView()
	local function onDataChange(event,data)
		self:refresh()
	end
	eventDispatcher:addEventListener("superweapon.data.info",onDataChange)
	self.eventListener=onDataChange
	return self.bgLayer
end

function superWeaponInfoDialogTabList:initTableView()
	self.weaponList={}
	self.unlockSlots=superWeaponVoApi:getUnlockSlot()
	for k,v in pairs(superWeaponVoApi:getWeaponList()) do
		table.insert(self.weaponList,v)
	end
	local function sortFunc(a,b)
		local id1=tonumber(string.sub(a.id,2))
		local id2=tonumber(string.sub(b.id,2))
		return id1<id2
	end
	table.sort(self.weaponList,sortFunc)
	local function callBack(...)
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 60,G_VisibleSizeHeight - 190),nil)
	self.tv:setAnchorPoint(ccp(0,0))
	self.tv:setPosition(ccp(30,30))
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setMaxDisToBottomOrTop(80)
	self.bgLayer:addChild(self.tv)
end

function superWeaponInfoDialogTabList:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return #self.weaponList
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(G_VisibleSizeWidth - 60,160)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local naLbSize = 18
		if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
		    naLbSize = 24
		end

		local function nilFunc( ... )
		end
		local cellBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(5,5,80,80),nilFunc)
		cellBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,150))
		cellBg:setPosition(ccp((G_VisibleSizeWidth - 60)/2,160/2))
		cell:addChild(cellBg)
		local data=self.weaponList[idx + 1]
		local function onClick(object,fn,tag)
			if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
				if G_checkClickEnable()==false then
					do return end
				else
					base.setWaitTime=G_getCurDeviceMillTime()
				end
				local index=tag - 100 + 1
				self:showDetailDialog(index)
			end
		end
		local icon = LuaCCSprite:createWithSpriteFrameName(data:getConfigData("icon"),onClick)
		icon:setTag(100 + idx)
		icon:setTouchPriority(-(self.layerNum-1)*20-2)
		icon:setScale(120/icon:getContentSize().height)
		icon:setAnchorPoint(ccp(0,0.5))
		icon:setPosition(10,75)
		cellBg:addChild(icon)
		local nameLb=GetTTFLabelWrap(getlocal(data:getConfigData("name")),naLbSize,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
		nameLb:setColor(G_ColorYellowPro)
		nameLb:setAnchorPoint(ccp(0,0.5))
		nameLb:setPosition(ccp(140,125))
		cellBg:addChild(nameLb)
		local lvLb=GetTTFLabel(getlocal("fightLevel",{data.lv}),24,true)
		lvLb:setAnchorPoint(ccp(0,0.5))
		lvLb:setPosition(ccp(nameLb:getPositionX()+nameLb:getContentSize().width,125))
		cellBg:addChild(lvLb)
		local slot=data:getConfigData("slot")
		for k,v in pairs(slot) do
			local slotBg=LuaCCScale9Sprite:createWithSpriteFrameName("alienTechBg2.png", CCRect(10, 10, 80, 80),nilFunc)
			slotBg:setContentSize(CCSizeMake(80,80))
			slotBg:setAnchorPoint(ccp(0,0))
			slotBg:setPosition(ccp(140 + (k-1)*85,10))
			cellBg:addChild(slotBg)
			local sp
			if(k>self.unlockSlots)then
				local function onClickLock()
					if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
						if G_checkClickEnable()==false then
							do return end
						else
							base.setWaitTime=G_getCurDeviceMillTime()
						end
						smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("super_weapon_unlockTip",{superWeaponCfg.unlockCrystal[k]}),30)
					end					
				end
				sp=LuaCCSprite:createWithSpriteFrameName("LockIcon.png",onClickLock)
				sp:setTouchPriority(-(self.layerNum-1)*20-2)
				sp:setScale(60/sp:getContentSize().height)
			else
				if(data.slots["p"..k])then
					local crystalVo=superWeaponVoApi:getCrystalVoByCid(data.slots["p"..k])
					sp=crystalVo:getIconSp()
					sp:setScale(55/sp:getContentSize().height)
				end
			end
			if(sp)then
				sp:setPosition(getCenterPoint(slotBg))
				slotBg:addChild(sp)
			end
		end
		local function onLvUp()
			self.parent:close()
			superWeaponVoApi:showRobDialog(self.layerNum,1,data.id)
		end
		local strSize2,strSize3 = 21,21
		if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() =="tw" then
			strSize2,strSize3 = 24,24
		elseif G_getCurChoseLanguage() =="de" then
			strSize3 = 14
		end
		local lvUpItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onLvUp,nil,getlocal("super_weapon_lvUp"),strSize2/0.6,101)
		lvUpItem:setScale(0.6)
		local btnLb = lvUpItem:getChildByTag(101)
		if btnLb then
			btnLb = tolua.cast(btnLb,"CCLabelTTF")
			btnLb:setFontName("Helvetica-bold")
		end
		lvUpBtn=CCMenu:createWithItem(lvUpItem)
		lvUpBtn:setTouchPriority(-(self.layerNum-1)*20-2)
		lvUpBtn:setPosition(ccp(G_VisibleSizeWidth - 150,112.5))
		cellBg:addChild(lvUpBtn)
		local function onSet()
			self.parent:close()
			superWeaponVoApi:showEnergyCrystalDialog(self.layerNum,1,data.id)
		end
		local setGemItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onSet,nil,getlocal("super_weapon_setGem"),strSize3/0.6,101)
		local challengeVo=superWeaponVoApi:getSWChallenge()
		if(challengeVo.maxClearPos<20)then
			setGemItem:setEnabled(false)
		end
		setGemItem:setScale(0.6)
		local btnLb = setGemItem:getChildByTag(101)
		if btnLb then
			btnLb = tolua.cast(btnLb,"CCLabelTTF")
			btnLb:setFontName("Helvetica-bold")
		end
		setGemBtn=CCMenu:createWithItem(setGemItem)
		setGemBtn:setTouchPriority(-(self.layerNum-1)*20-2)
		setGemBtn:setPosition(ccp(G_VisibleSizeWidth - 150,37.5))
		cellBg:addChild(setGemBtn)
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
	end
end

function superWeaponInfoDialogTabList:showDetailDialog(index)
	if(self.weaponList and self.weaponList[index])then
		local data=self.weaponList[index]
		superWeaponVoApi:showWeaponDetailDialog(data.id,self.layerNum + 1)
	end
end

function superWeaponInfoDialogTabList:refresh()
	if(self and self.tv)then
		self.weaponList={}
		for k,v in pairs(superWeaponVoApi:getWeaponList()) do
			table.insert(self.weaponList,v)
		end
		local function sortFunc(a,b)
			local id1=tonumber(string.sub(a.id,2))
			local id2=tonumber(string.sub(b.id,2))
			return id1<id2
		end
		table.sort(self.weaponList,sortFunc)
		local recordPoint = self.tv:getRecordPoint()
		self.tv:reloadData()
		self.tv:recoverToRecordPoint(recordPoint)
	end
end

function superWeaponInfoDialogTabList:dispose()
	eventDispatcher:removeEventListener("superweapon.data.info",self.eventListener)
end