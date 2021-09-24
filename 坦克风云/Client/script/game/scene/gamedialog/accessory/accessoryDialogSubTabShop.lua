--晶体碎片兑换配件的页签
accessoryDialogSubTabShop={}

function accessoryDialogSubTabShop:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.bgLayer=nil
	self.curTab=1
	self.tabs={}
	return nc
end

function accessoryDialogSubTabShop:init(layerNum)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	if(accessoryCfg.unLockPart<5)then
		self.tabNum=1
	elseif(accessoryCfg.unLockPart<7)then
		self.tabNum=2
	else
		self.tabNum=3
	end
	self:initBackground()
	self:initTabs()
	self:initTableView()
	self:switchTab(1)
	return self.bgLayer
end

function accessoryDialogSubTabShop:initBackground()
	local propNum=accessoryVoApi:getShopPropNum()
	for i=1,self.tabNum do
		local numStr
		local iconName
		local lbTag
		if(i==1)then
			numStr=FormatNumber(propNum["p8"])
			iconName="accessoryP8_1.png"
			lbTag=108
		elseif(i==2)then
			numStr=FormatNumber(propNum["p9"])
			iconName="accessoryP9_1.png"
			lbTag=109
		else
			numStr=FormatNumber(propNum["p10"])
			iconName="accessoryP10_1.png"
			lbTag=110
		end
		local icon=CCSprite:createWithSpriteFrameName(iconName)
		icon:setScale(45/icon:getContentSize().width)
		icon:setPosition(ccp(100 + 130*(i-1),G_VisibleSizeHeight - 260))
		self.bgLayer:addChild(icon)
		local propLb=GetTTFLabel(numStr,28)
		propLb:setAnchorPoint(ccp(0,0.5))
		propLb:setPosition(ccp(120 + 130*(i-1),G_VisibleSizeHeight - 260))
		propLb:setTag(lbTag)
		self.bgLayer:addChild(propLb)
	end
	local function showInfo()
		PlayEffect(audioCfg.mouseClick)
		local tabStr={"\n",getlocal("accessory_buy_info"),"\n"}
		local tabColor={nil,G_ColorYellowPro,nil}
		local td=smallDialog:new()
		local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
		sceneGame:addChild(dialog,self.layerNum+1) 
	end
	local infoItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",showInfo,11,nil,nil)
	infoItem:setScale(0.9)
	local infoBtn = CCMenu:createWithItem(infoItem)
	infoBtn:setPosition(ccp(G_VisibleSizeWidth - 80,G_VisibleSizeHeight - 260))
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-3);
	self.bgLayer:addChild(infoBtn)
	local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",CCRect(20,20,10,10),function ( ... ) end)
	tvBg:setAnchorPoint(ccp(0,0))
	tvBg:setPosition(ccp(78,50))
	tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 120,G_VisibleSizeHeight - 350))
	self.bgLayer:addChild(tvBg)
end

function accessoryDialogSubTabShop:initTabs()
	for i=1,self.tabNum do
		local tabBtn=CCMenu:create()
	    local tabItem=CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
		tabItem:setAnchorPoint(ccp(0,0))
		tabItem:setRotation(-90)
    	local function tabSubClick(idx)
			return self:switchTab(idx)
		end
		tabItem:registerScriptTapHandler(tabSubClick)
		local iconName
		if(i==1)then
			iconName="accessoryP8_1.png"
		elseif(i==2)then
			iconName="accessoryP9_1.png"
		else
			iconName="accessoryP10_1.png"
		end
		self.tabs[i]=tabItem
		tabBtn:addChild(tabItem)
		tabItem:setTag(i)
		tabBtn:setPosition(ccp(80,G_VisibleSizeHeight - 300 - tabItem:getContentSize().width*i))
		tabBtn:setTouchPriority(-(self.layerNum-1)*20-4)
		self.bgLayer:addChild(tabBtn)

		local icon=CCSprite:createWithSpriteFrameName(iconName)
		icon:setScale(45/icon:getContentSize().width)
		icon:setPosition(ccp(55,G_VisibleSizeHeight - 235 - tabItem:getContentSize().width*i))
		self.bgLayer:addChild(icon)
	end
end

function accessoryDialogSubTabShop:initTableView()
	self.shopData={}
	for i=1,self.tabNum do
		self.shopData[i]={}
	end
	local shopCfg=accessoryCfg.shopItems
	for k,v in pairs(shopCfg) do
		if(v.type==4)then
			if(self.shopData[1])then
				table.insert(self.shopData[1],v)
			end
		elseif(v.type==6)then
			if(self.shopData[2])then
				table.insert(self.shopData[2],v)
			end
		else
			if(self.shopData[3])then
				table.insert(self.shopData[3],v)
			end
		end
	end

	for i=1,self.tabNum do
		local function sortFunc(a,b)
			return a.index<b.index
		end
		table.sort(self.shopData[i],sortFunc)
	end
	local function callback(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 120,G_VisibleSizeHeight - 360),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(78,55)
	self.bgLayer:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(80)
end

function accessoryDialogSubTabShop:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return #(self.shopData[self.curTab])
	elseif fn=="tableCellSizeForIndex" then
	   self.cellHight = 280
       if G_getCurChoseLanguage() == "cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage()=="ja" then
           self.cellHight = 170
       end
		return  CCSizeMake(520,self.cellHight)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local background=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function () end)
		background:setContentSize(CCSizeMake(510,self.cellHight-10))
		background:setAnchorPoint(ccp(0,0))
		background:setPosition(ccp(5,5))
		cell:addChild(background)
		local item=self.shopData[self.curTab][idx+1]
		local rewardTb=FormatItem(item.reward)
		if(rewardTb and rewardTb[1])then
			local reward=rewardTb[1]
			local icon=G_getItemIcon(reward,100)
			icon:setPosition(70,self.cellHight-80)
			cell:addChild(icon)
			if(reward.num>1)then
				local numLb=GetTTFLabel("x"..FormatNumber(reward.num),22)
				numLb:setAnchorPoint(ccp(1,0))
				numLb:setPosition(ccp(95,5))
				icon:addChild(numLb)
			end
			local nameLb=GetTTFLabelWrap(reward.name,24,CCSizeMake(300,80),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
			nameLb:setAnchorPoint(ccp(0,1))
			nameLb:setPosition(130,self.cellHight-30)
			cell:addChild(nameLb)
			local descLb=GetTTFLabelWrap(getlocal(reward.desc),20,CCSizeMake(250,240),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			descLb:setAnchorPoint(ccp(0,0.5))
			local deslbHeight = 170
			if G_getCurChoseLanguage() == "cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage()=="ja" then
					deslbHeight =115
			end
			descLb:setPosition(130,self.cellHight-deslbHeight)
			cell:addChild(descLb)
		end
		local iconName
		local price
		local costProp
		for k,v in pairs(item.price) do
			if(k=="p8")then
				iconName="accessoryP8_1.png"
			elseif(k=="p9")then
				iconName="accessoryP9_1.png"
			else
				iconName="accessoryP10_1.png"
			end
			costProp=k
			price=v
		end
		local priceIcon=CCSprite:createWithSpriteFrameName(iconName)
		priceIcon:setScale(40/priceIcon:getContentSize().width)
		priceIcon:setPosition(ccp(400,130))
		cell:addChild(priceIcon)
		local priceLb=GetTTFLabel(FormatNumber(price),25)
		local selfProp=accessoryVoApi:getShopPropNum()
		if(selfProp[costProp]<price)then
			priceLb:setColor(G_ColorRed)
		end
		priceLb:setPosition(ccp(450,130))
		cell:addChild(priceLb)
		if(item.gems>0)then
			local gemIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
			gemIcon:setPosition(ccp(400,90))
			cell:addChild(gemIcon)
			local gemLb=GetTTFLabel(item.gems,25)
			if(playerVoApi:getGems()<item.gems)then
				gemLb:setColor(G_ColorRed)
			end
			gemLb:setPosition(ccp(450,90))
			cell:addChild(gemLb)
		else
			priceIcon:setPositionY(110)
			priceLb:setPositionY(110)
		end
		local function onClickBuy(tag,object)
			local tab=math.floor(tag/100)
			local index=tag%100
			self:buyItem(tab,index)
		end
		local buyItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onClickBuy,self.curTab*100 + idx + 1,getlocal("code_gift"),24/0.6,101)
		buyItem:setScale(0.6)
		local btnLb = buyItem:getChildByTag(101)
		if btnLb then
			btnLb = tolua.cast(btnLb,"CCLabelTTF")
			btnLb:setFontName("Helvetica-bold")
		end
		local buyBtn=CCMenu:createWithItem(buyItem)
		buyBtn:setTouchPriority(-(self.layerNum-1)*20-2)
		buyBtn:setPosition(ccp(450,50))
		cell:addChild(buyBtn)
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
	end
end

function accessoryDialogSubTabShop:refresh()
	local recordPoint=self.tv:getRecordPoint()
	self.tv:reloadData()
	self.tv:recoverToRecordPoint(recordPoint)
	local propNum=accessoryVoApi:getShopPropNum()
	for i=8,10 do
		local lb=tolua.cast(self.bgLayer:getChildByTag(100+i),"CCLabelTTF")
		if(lb)then
			lb:setString(FormatNumber(propNum["p"..i]))
		end
	end
end

function accessoryDialogSubTabShop:setVisible(isVisible)
	if(isVisible)then
		self.bgLayer:setPositionX(0)
		self.bgLayer:setVisible(true)
	else
		self.bgLayer:setPositionX(999333)
		self.bgLayer:setVisible(false)
	end
end

function accessoryDialogSubTabShop:switchTab(type)
	for k,v in pairs(self.tabs) do
		if k==type then
			v:setEnabled(false)
			self.curTab=type
		else
			v:setEnabled(true)
		end
	end
	self.tv:reloadData()
end

function accessoryDialogSubTabShop:buyItem(tab,index)
	local item=self.shopData[tab][index]
	if(item)then
		local price
		local costProp
		for k,v in pairs(item.price) do
			price=v
			costProp=k
		end
		local costGem=item.gems
		if(costGem>playerVoApi:getGems())then
			GemsNotEnoughDialog(nil,nil,costGem - playerVoApi:getGems(),self.layerNum+1,costGem)
			do return end
		end
		local selfProp=accessoryVoApi:getShopPropNum()

		local function showBuyDialog( num )
			local buyNum = num
			local function onConfirm()
				local function callback()
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allianceShop_buySuccess",{getlocal("accessory_smelt_"..costProp)}),30)
					self:refresh()
				end
				accessoryVoApi:buy(item.id,callback,buyNum)
			end
			
			local costStr=getlocal("accessory_smelt_"..costProp).." x"..FormatNumber(price*num)
			if(costGem>0)then
				costStr=costStr..","..getlocal("gem").." x"..FormatNumber(costGem*num)
			end
			local rewardTb=FormatItem(item.reward)
			local str=getlocal("accessory_buy_confirm",{costStr,rewardTb[1].name.." x"..FormatNumber(rewardTb[1].num*num)})
			smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),str,nil,self.layerNum+1)
		end

		local limitNum
		local limitNum1
		local limitNum2 = 0
		if costGem>0 then
			limitNum1 = math.floor(playerVoApi:getGems()/costGem)
		end
		if selfProp[costProp]>=price then
			limitNum2 = math.floor(selfProp[costProp]/price)
		end

		if limitNum1~=nil then
			if limitNum1<=limitNum2 then
				limitNum = limitNum1
			else
				limitNum = limitNum2
			end
		else
			limitNum = limitNum2
		end

		local rewardTb=FormatItem(item.reward)
		local costTb = {}
		costTb["e"]={item.price}
		if costGem>0 then
			costTb["u"]={{gems=costGem}}
		end

		local costTable = FormatItem(costTb)
		for k,v in pairs(costTable) do
			print(k,v.key)
		end
		if(selfProp[costProp]<price)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_not_enough_prop_buy",{getlocal("accessory_smelt_"..costProp)}),30)
			do return end
		else
			shopVoApi:showBatchBuyPropSmallDialog(rewardTb[1].key,self.layerNum+1,showBuyDialog,getlocal("code_gift"),limitNum,nil,costTable,true,rewardTb[1])
		end
	end
end

function accessoryDialogSubTabShop:dispose()
	self.tabs=nil
end