require "luascript/script/game/scene/gamedialog/rpshop/rpShopDialogTabNB"
require "luascript/script/game/scene/gamedialog/rpshop/rpShopDialogTabSB"
rpShopDialog=commonDialog:new()

function rpShopDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.shopTab1=nil
	self.layerTab1=nil
	self.shopTab2=nil
	self.layerTab2=nil
	return nc
end

function rpShopDialog:resetTab()
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
	self:tabClick(0)
end

function rpShopDialog:initTableView()
	local function refreshListener(event,data)
		for i=1,2 do
			if(self["shopTab"..i])then
				self["shopTab"..i]:refresh(data)
			end
		end
	end
	self.refreshListener=refreshListener
	eventDispatcher:addEventListener("rpShop.refresh",refreshListener)
	local background=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),function ( ... )end)
	background:setAnchorPoint(ccp(0,1))
	background:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,110))
	background:setPosition(ccp(30,G_VisibleSizeHeight - 170))
	self.bgLayer:addChild(background)

	local openLb1=GetTTFLabel(getlocal("serverwar_opentime",{""}),25)
	openLb1:setColor(G_ColorGreen)
	openLb1:setAnchorPoint(ccp(0,0.5))
	openLb1:setPosition(ccp(10,80))
	background:addChild(openLb1)

	local openLb2=GetTTFLabel(getlocal("rpshop_openTime"),25)
	openLb2:setAnchorPoint(ccp(0,0.5))
	openLb2:setPosition(ccp(10 + openLb1:getContentSize().width + 10,80))
	background:addChild(openLb2)

	local descLb=GetTTFLabelWrap(getlocal("rpshop_sellDesc"),25,CCSizeMake(G_VisibleSizeWidth - 160,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	descLb:setColor(G_ColorYellowPro)
	descLb:setAnchorPoint(ccp(0,0.5))
	descLb:setPosition(ccp(10,35))
	background:addChild(descLb)

	local function showInfo()
		PlayEffect(audioCfg.mouseClick)
		local tabStr={"\n",getlocal("rpshop_info5"),"\n",getlocal("rpshop_info4"),"\n",getlocal("rpshop_info3"),"\n",getlocal("rpshop_info2"),"\n",getlocal("rpshop_info1"),"\n"}
		local tabColor={nil,G_ColorYellowPro,nil,G_ColorYellowPro,nil,G_ColorYellowPro,nil,G_ColorYellowPro,nil,G_ColorYellowPro,nil}
		local td=smallDialog:new()
		local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
		sceneGame:addChild(dialog,self.layerNum+1) 
	end
	local infoItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",showInfo,11,nil,nil)
	infoItem:setScale(0.9)
	local infoBtn = CCMenu:createWithItem(infoItem)
	infoBtn:setPosition(ccp(G_VisibleSizeWidth - 110,55-15))
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-3)
	background:addChild(infoBtn)

	self.rpOwnLb=GetTTFLabel(getlocal("propOwned").." "..FormatNumber(playerVoApi:getRpCoin()),22)
	self.rpOwnLb:setAnchorPoint(ccp(0,0.5))
	self.rpOwnLb:setPosition(ccp(30,G_VisibleSizeHeight - 380))
	self.bgLayer:addChild(self.rpOwnLb)

	local icon=CCSprite:createWithSpriteFrameName("rpCoin.png")
	icon:setScale(70/icon:getContentSize().height)
	icon:setPosition(30 + self.rpOwnLb:getContentSize().width/2,G_VisibleSizeHeight - 330)
	self.bgLayer:addChild(icon)

	local leftWidth=30 + self.rpOwnLb:getContentSize().width
	local rpCoinNameLb=GetTTFLabel(getlocal("rpshop_rpCoin"),28)
	rpCoinNameLb:setColor(G_ColorYellowPro)
	rpCoinNameLb:setAnchorPoint(ccp(0,0.5))
	rpCoinNameLb:setPosition(ccp(leftWidth + 10,G_VisibleSizeHeight - 320))
	self.bgLayer:addChild(rpCoinNameLb)

	local rpDescLb=GetTTFLabelWrap(getlocal("rpshop_rpCoinDesc"),22,CCSizeMake(G_VisibleSizeWidth - leftWidth - 5 - 150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	rpDescLb:setAnchorPoint(ccp(0,0.5))
	rpDescLb:setPosition(ccp(leftWidth + 10,G_VisibleSizeHeight - 370))
	self.bgLayer:addChild(rpDescLb)

	local function gotoMap()
		activityAndNoteDialog:closeAllDialog()
		mainUI:changeToWorld()
	end
	local gotoMapItem = GetButtonItem("IconReturnBtn.png","IconReturnBtn_Down.png","IconReturnBtn.png",gotoMap,11,nil,nil)
	gotoMapItem:setScale(0.9)
	local gotoMapBtn = CCMenu:createWithItem(gotoMapItem)
	gotoMapBtn:setPosition(ccp(G_VisibleSizeWidth - 110,G_VisibleSizeHeight - 330))
	gotoMapBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(gotoMapBtn)

	local timeStrTb={}
	for k,v in pairs(rpShopCfg.reftime) do
		local str
		if(v<10)then
			str="0"..v
		else
			str=v
		end
		str=str..":00"
		table.insert(timeStrTb,str)
	end
	local timeStr=table.concat(timeStrTb, ", ")
	local tip=GetTTFLabelWrap(getlocal("allianceShop_tip2",{timeStr}),25,CCSizeMake(G_VisibleSizeWidth - 60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	tip:setColor(G_ColorYellowPro)
	tip:setAnchorPoint(ccp(0,0.5))
	tip:setPosition(ccp(30,65))
	self.bgLayer:addChild(tip)
end

function rpShopDialog:tabClick(idx,isEffect)
	for k,v in pairs(self.allTabs) do
		if v:getTag()==idx then
			v:setEnabled(false)
			self.selectedTabIndex=idx
		else
			v:setEnabled(true)
		end
	end
	self:resetForbidLayer()
	self:switchTab(idx+1)
end

function rpShopDialog:switchTab(type)
	if type==nil then
		type=1
	end
	if self["shopTab"..type]==nil then
		local tab
		if(type==1)then
			tab=rpShopDialogTabSB:new()
		elseif(type==2)then
			tab=rpShopDialogTabNB:new()
		end
		self["shopTab"..type]=tab
		self["layerTab"..type]=tab:init(self.layerNum,self)
		self.bgLayer:addChild(self["layerTab"..type])
	end
	for i=1,2 do
		if(i==type)then
			if(self["layerTab"..i]~=nil)then
				self["layerTab"..i]:setPosition(ccp(0,0))
				self["layerTab"..i]:setVisible(true)
			end
		else
			if(self["layerTab"..i]~=nil)then
				self["layerTab"..i]:setPosition(ccp(999333,0))
				self["layerTab"..i]:setVisible(false)
			end
		end
	end
end

function rpShopDialog:tick()
	if(base.serverTime>=rpShopVoApi.dataExpireTime)then
		local function callback()
			for i=1,2 do
				if(self["shopTab"..i])then
					self["shopTab"..i]:refresh()
				end
			end
		end
		rpShopVoApi:refresh(callback)
	end
end

function rpShopDialog:dispose()
	eventDispatcher:removeEventListener("rpShop.refresh",self.refreshListener)
	if(self.shopTab1)then
		self.shopTab1:dispose()
		self.shopTab1=nil
		self.layerTab1=nil
	end
	if(self.shopTab2)then
		self.shopTab2:dispose()
		self.shopTab2=nil
		self.layerTab2=nil
	end
end