--超级武器装备的tab
superWeaponInfoDialogTabEquip={}
function superWeaponInfoDialogTabEquip:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.newEquipList={}
	nc.changeFlag=false
	return nc
end

function superWeaponInfoDialogTabEquip:init(layerNum,parent)
	self.layerNum=layerNum
	self.parent=parent
	self.bgLayer=CCLayer:create()
	self.newEquipList=superWeaponVoApi:getEquipList()
	if(self.newEquipList==nil)then
		self.newEquipList={}
	end
	for i=1,6 do
		if(self.newEquipList[i]==nil)then
			self.newEquipList[i]=0
		end
	end
	self:initEquip()
	return self.bgLayer
end

function superWeaponInfoDialogTabEquip:initEquip()
	local naLbSize = 20
	local lvHeightPos = 35
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
        naLbSize = 24
        lvHeightPos =20
    end
	local function showInfo()
		PlayEffect(audioCfg.mouseClick)
		local tabStr={"\n",getlocal("super_weapon_equipInfo"),"\n"}
		local tabColor ={G_ColorYellowPro,G_ColorYellowPro,G_ColorYellowPro}
		local td=smallDialog:new()
		local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
		sceneGame:addChild(dialog,self.layerNum+1)
	end
	local infoItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",showInfo,11,nil,nil)
	infoItem:setAnchorPoint(ccp(1,1))
	local infoBtn = CCMenu:createWithItem(infoItem)
	infoBtn:setPosition(ccp(G_VisibleSizeWidth - 50,G_VisibleSizeHeight - 165))
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	self.bgLayer:addChild(infoBtn)
	local function onClickPos(object,fn,tag)
		local troopIndex=tag - 100
		if(self.newEquipList[troopIndex] and self.newEquipList[troopIndex]~=0 and self.newEquipList[troopIndex]~="0")then
			local bg=self.bgLayer:getChildByTag(200 + troopIndex)
			if(bg)then
				bg:removeFromParentAndCleanup(true)
			end
			self.newEquipList[troopIndex]=0
			self.changeFlag=true
		else
			self:showSelectWeaponDialog(troopIndex)
		end
	end
	for i=1,6 do
		local equipPosBg=LuaCCSprite:createWithSpriteFrameName("superWeapon_equipBg.png",onClickPos)
		equipPosBg:setTag(100 + i)
		local posX
		local yOffset
		if(i<4)then
			posX=G_VisibleSizeWidth*3/4 - 10
			yOffset=i - 1
		else
			posX=G_VisibleSizeWidth/4 + 10
			yOffset= i - 4
		end
		equipPosBg:setAnchorPoint(ccp(0.5,1))
		equipPosBg:setTouchPriority(-(self.layerNum-1)*20-2)
		equipPosBg:setPosition(ccp(posX,G_VisibleSizeHeight - 295 - (equipPosBg:getContentSize().height + 40)*yOffset))
		self.bgLayer:addChild(equipPosBg)
		if(self.newEquipList[i] and self.newEquipList[i]~=0 and self.newEquipList[i]~="0")then
			local data=superWeaponVoApi:getWeaponByID(self.newEquipList[i])
			if(data)then
				local equipBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png", CCRect(10, 10, 80, 80),onClickPos)
				equipBg:setTag(200 + i)
				equipBg:setContentSize(equipPosBg:getContentSize())
				equipBg:setAnchorPoint(ccp(0.5,1))
				equipBg:setPosition(equipPosBg:getPosition())
				self.bgLayer:addChild(equipBg)
				local equipIcon=CCSprite:createWithSpriteFrameName(data:getConfigData("icon"))
				equipIcon:setScale(80/equipIcon:getContentSize().width)
				equipIcon:setPosition(ccp(50,equipPosBg:getContentSize().height/2))
				equipBg:addChild(equipIcon)
				local nameLb=GetTTFLabelWrap(getlocal(data:getConfigData("name")),naLbSize,CCSizeMake(120,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
				nameLb:setAnchorPoint(ccp(0,0.5))
				nameLb:setPosition(ccp(100,equipPosBg:getContentSize().height/2 + 20))
				equipBg:addChild(nameLb)
				local lvLb=GetTTFLabel(getlocal("fightLevel",{data.lv}),24)
				lvLb:setAnchorPoint(ccp(0,0.5))
				lvLb:setPosition(ccp(100,equipPosBg:getContentSize().height/2 - lvHeightPos))
				equipBg:addChild(lvLb)
				local deleteIcon=CCSprite:createWithSpriteFrameName("IconFault.png")
				deleteIcon:setPosition(ccp(equipPosBg:getContentSize().width - 30,30))
				equipBg:addChild(deleteIcon)
			end
		end

		local troopIndexLb=GetTTFLabel(getlocal("super_weapon_troopIndex",{i}),24,true)
		troopIndexLb:setPosition(ccp(posX,G_VisibleSizeHeight - 275 - (equipPosBg:getContentSize().height + 40)*yOffset))
		self.bgLayer:addChild(troopIndexLb)
	end
	local strSize = 24
	local heightCha = 140
	if (G_getIphoneType() == G_iphoneX) then
		strSize = 30
		heightCha = 260
	end
	local descLb=GetTTFLabelWrap(getlocal("super_weapon_equipDesc"),strSize,CCSizeMake(G_VisibleSizeWidth - 80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	descLb:setPosition(ccp(G_VisibleSizeWidth/2,heightCha))
	self.bgLayer:addChild(descLb)

	local function onAutoEquip()
		local weaponList={}
		for id,vo in pairs(superWeaponVoApi:getWeaponList()) do
			table.insert(weaponList,vo)
		end
		local function sortFunc(a,b)
			local lvTotal=0
			for k,v in pairs(a.slots) do
				if(v~=0)then
					local crystal=superWeaponVoApi:getCrystalVoByCid(v)
					lvTotal=lvTotal + crystal:getLevel()
				end
			end
			local paramA=tonumber(a:getConfigData("quality"))*a.lv + lvTotal
			local slotB=b.slots
			lvTotal=0
			for k,v in pairs(b.slots) do
				if(v~=0)then
					local crystal=superWeaponVoApi:getCrystalVoByCid(v)
					lvTotal=lvTotal + crystal:getLevel()
				end
			end
			local paramB=tonumber(b:getConfigData("quality"))*b.lv + lvTotal
			return paramA>paramB
		end
		table.sort(weaponList,sortFunc)
		self.newEquipList={}

		for i=1,6 do
			local bg=self.bgLayer:getChildByTag(200 + i)
			if(bg)then
				bg:removeFromParentAndCleanup(true)
			end
			if(weaponList[i])then
				local data=weaponList[i]
				self.newEquipList[i]=data.id
				local equipPosBg=self.bgLayer:getChildByTag(100 + i)
				local equipBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png", CCRect(10, 10, 80, 80),function ( ... )end)
				equipBg:setTag(200 + i)
				equipBg:setContentSize(equipPosBg:getContentSize())
				equipBg:setAnchorPoint(ccp(0.5,1))
				equipBg:setPosition(equipPosBg:getPosition())
				self.bgLayer:addChild(equipBg)
				local equipIcon=CCSprite:createWithSpriteFrameName(data:getConfigData("icon"))
				equipIcon:setScale(80/equipIcon:getContentSize().width)
				equipIcon:setPosition(ccp(50,equipPosBg:getContentSize().height/2))
				equipBg:addChild(equipIcon)
				local nameLb=GetTTFLabelWrap(getlocal(data:getConfigData("name")),naLbSize,CCSizeMake(120,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
				nameLb:setAnchorPoint(ccp(0,0.5))
				nameLb:setPosition(ccp(100,equipPosBg:getContentSize().height/2 + 20))
				equipBg:addChild(nameLb)
				local lvLb=GetTTFLabel(getlocal("fightLevel",{data.lv}),24)
				lvLb:setAnchorPoint(ccp(0,0.5))
				lvLb:setPosition(ccp(100,equipPosBg:getContentSize().height/2 - lvHeightPos))
				equipBg:addChild(lvLb)
				local deleteIcon=CCSprite:createWithSpriteFrameName("IconFault.png")
				deleteIcon:setPosition(ccp(equipPosBg:getContentSize().width - 30,30))
				equipBg:addChild(deleteIcon)
			else
				self.newEquipList[i]=0
			end
		end
		if(self.parent and self.parent.equipTip)then
			self.parent.equipTip:setVisible(false)
		end
		self.changeFlag=true
	end
	local autoEquipItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onAutoEquip,nil,getlocal("autoMaxPower"),24/0.8,101)
	autoEquipItem:setScale(0.8)
	local btnLb = autoEquipItem:getChildByTag(101)
	if btnLb then
		btnLb = tolua.cast(btnLb,"CCLabelTTF")
		btnLb:setFontName("Helvetica-bold")
	end
	autoEquipBtn=CCMenu:createWithItem(autoEquipItem)
	autoEquipBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	autoEquipBtn:setPosition(ccp(G_VisibleSizeWidth*3/4,70))
	self.bgLayer:addChild(autoEquipBtn)
end

function superWeaponInfoDialogTabEquip:showSelectWeaponDialog(troopIndex)
	local naLbSize = 20
	local lvHeightPos = 35
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
        naLbSize = 24
        lvHeightPos =20
    end
	if(self.selectLayer)then
		self.selectLayer:removeFromParentAndCleanup(true)
		self.selectLayer=nil
	end
	self.unEquipWeaponList={}
	local tmp=superWeaponVoApi:getWeaponList()
	for k,v in pairs(tmp) do
		local inFlag=false
		for kk,vv in pairs(self.newEquipList) do
			if(v.id==vv)then
				inFlag=true
				break
			end
		end
		if(inFlag==false)then
			table.insert(self.unEquipWeaponList,v)
		end
	end
	self.selectedNewWeapon=nil
	self.selectedHalo=nil
	local layerNum=self.layerNum + 1
	self.selectLayer=CCLayer:create()
	self.bgLayer:addChild(self.selectLayer,3)
	local function nilFunc( ... )
	end
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	touchDialogBg:setOpacity(180)
	touchDialogBg:setAnchorPoint(ccp(0,0))
	touchDialogBg:setPosition(ccp(0,0))
	self.selectLayer:addChild(touchDialogBg)
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelBg.png",CCRect(168, 86, 10, 10),nilFunc)
	dialogBg:setContentSize(CCSizeMake(560,800))
	dialogBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.selectLayer:addChild(dialogBg,1)
	local titleLb = GetTTFLabel(getlocal("super_weapon_chooseWeapon"),32,true)
	titleLb:setPosition(ccp(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height - titleLb:getContentSize().height/2-23))
	dialogBg:addChild(titleLb,2)
	
	local function onClose()
		if(self and self.selectLayer)then
			PlayEffect(audioCfg.mouseClick)
			self.selectLayer:removeFromParentAndCleanup(true)
			self.selectLayer=nil
		end
	end
	local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",onClose,nil,nil,nil);
	local closeBtn = CCMenu:createWithItem(closeBtnItem)
	closeBtn:setTouchPriority(-(layerNum-1)*20-4)
	closeBtn:setPosition(ccp(dialogBg:getContentSize().width-closeBtnItem:getContentSize().width/2-5,dialogBg:getContentSize().height-closeBtnItem:getContentSize().height/2-5))
	dialogBg:addChild(closeBtn)
	local function callBack(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callBack)
	local tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(550,800 - 205),nil)
	tv:setTableViewTouchPriority((-(layerNum-1)*20-3))
	tv:setPosition(ccp(5,120))
	tv:setMaxDisToBottomOrTop(30)
	dialogBg:addChild(tv)
	local function onConfirm()
		if(self.selectedNewWeapon)then
			self.newEquipList[troopIndex]=self.selectedNewWeapon
			local data=superWeaponVoApi:getWeaponByID(self.selectedNewWeapon)
			if(data)then
				local equipPosBg=self.bgLayer:getChildByTag(100 + troopIndex)
				local equipBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png", CCRect(10, 10, 80, 80),function ( ... )end)
				equipBg:setTag(200 + troopIndex)
				equipBg:setContentSize(equipPosBg:getContentSize())
				equipBg:setAnchorPoint(ccp(0.5,1))
				equipBg:setPosition(equipPosBg:getPosition())
				self.bgLayer:addChild(equipBg)
				local equipIcon=CCSprite:createWithSpriteFrameName(data:getConfigData("icon"))
				equipIcon:setScale(80/equipIcon:getContentSize().width)
				equipIcon:setPosition(ccp(50,equipPosBg:getContentSize().height/2))
				equipBg:addChild(equipIcon)
				local nameLb=GetTTFLabelWrap(getlocal(data:getConfigData("name")),naLbSize,CCSizeMake(120,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
				nameLb:setAnchorPoint(ccp(0,0.5))
				nameLb:setPosition(ccp(100,equipPosBg:getContentSize().height/2 + 20))
				equipBg:addChild(nameLb)
				local lvLb=GetTTFLabel(getlocal("fightLevel",{data.lv}),24)
				lvLb:setAnchorPoint(ccp(0,0.5))
				lvLb:setPosition(ccp(100,equipPosBg:getContentSize().height/2 - lvHeightPos))
				equipBg:addChild(lvLb)
				local deleteIcon=CCSprite:createWithSpriteFrameName("IconFault.png")
				deleteIcon:setPosition(ccp(equipPosBg:getContentSize().width - 30,30))
				equipBg:addChild(deleteIcon)
			end
			if(self.parent and self.parent.equipTip)then
				local equipNum=0
				for k,v in pairs(self.newEquipList) do
					if(v and v~=0 and v~="0")then
						equipNum=equipNum + 1
					end
				end
				if(equipNum<6 and SizeOfTable(superWeaponVoApi:getWeaponList())>equipNum)then
					self.parent.equipTip:setVisible(true)
				else
					self.parent.equipTip:setVisible(false)
				end
			end
			self.changeFlag=true
		end
		onClose()
	end
	local okItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onConfirm,2,getlocal("ok"),24/0.8,101)
	okItem:setScale(0.8)
	local btnLb = okItem:getChildByTag(101)
	if btnLb then
		btnLb = tolua.cast(btnLb,"CCLabelTTF")
		btnLb:setFontName("Helvetica-bold")
	end
	local okBtn=CCMenu:createWithItem(okItem)
	okBtn:setPosition(ccp(dialogBg:getContentSize().width/2,60))
	okBtn:setTouchPriority(-(layerNum-1)*20-4)
	dialogBg:addChild(okBtn)
end

function superWeaponInfoDialogTabEquip:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return math.ceil((#self.unEquipWeaponList)/4)
	elseif fn=="tableCellSizeForIndex" then
		tmpSize=CCSizeMake(550,200)
		return tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local function onSelect(object,fn,tag)
			local index=tag - 100
			self.selectedNewWeapon=self.unEquipWeaponList[index].id
			if(self.selectedHalo)then
				self.selectedHalo:removeFromParentAndCleanup(true)
			end
			self.selectedHalo=CCSprite:createWithSpriteFrameName("TeamTankSelected.png")
			local icon=tolua.cast(cell:getChildByTag(tag),"LuaCCSprite")
			if(icon)then
				self.selectedHalo:setScale(icon:getContentSize().width/self.selectedHalo:getContentSize().width)
				self.selectedHalo:setPosition(getCenterPoint(icon))
				icon:addChild(self.selectedHalo)
			end
		end
		for i=1,4 do
			local data=self.unEquipWeaponList[idx*4 + i]
			if(data)then
				local icon=LuaCCSprite:createWithSpriteFrameName(data:getConfigData("icon"),onSelect)
				icon:setTag(100 + idx*4 + i)
				icon:setScale(120/icon:getContentSize().width)
				local layerNum=self.layerNum + 1
				icon:setTouchPriority((-(layerNum-1)*20-2))
				icon:setAnchorPoint(ccp(0,0))
				icon:setPosition(ccp(20 + (i - 1)*130,80))
				cell:addChild(icon)
				local lvLb=GetTTFLabel(getlocal("fightLevel",{data.lv}),24)
				lvLb:setAnchorPoint(ccp(1,0))
				lvLb:setPosition(ccp(10 + i*130 - 5,85))
				cell:addChild(lvLb)
				local nameLb=GetTTFLabelWrap(getlocal(data:getConfigData("name")),24,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
				nameLb:setPosition(ccp(80 + (i - 1)*130,40))
				if(nameLb:getContentSize().height>70)then
					nameLb:setFontSize(20)
				end
				cell:addChild(nameLb)
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

function superWeaponInfoDialogTabEquip:dispose()
	if(self.changeFlag)then
		superWeaponVoApi:wareEquip(self.newEquipList,callback)
	end
	self.newEquipList={}
	self.changeFlag=false
end