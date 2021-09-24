allianceShopDialogTabP={}
function allianceShopDialogTabP:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.data=nil
	self.cellHeght=180
	self.tagOffset=518
	self.countdown=nil
	return nc
end

function allianceShopDialogTabP:init(layerNum,parent)
	local function callback(data)
		self:initWithData(data)
		self:initTick()
		self:initDesc()
		self:initTableView()
	end
	self.layerNum=layerNum
	self.parent=parent
	self.bgLayer=CCLayer:create()
	allianceShopVoApi:getPShopData(callback)
	return self.bgLayer
end

function allianceShopDialogTabP:initWithData(data)
	self.data={}
	for k,v in pairs(allianceShopCfg.pShopItems) do
		local cellData={}
		cellData.id=v.id
		cellData.rewardTb=FormatItem(v.reward)
		cellData.lv=v.lv
		cellData.price=v.price
		cellData.maxTime=v.pBuyNum
		if(data[v.id])then
			cellData.curTime=data[v.id]
		else
			cellData.curTime=0
		end
		local length=#self.data
		local flag=false
		for i=1,length do
			if(cellData.lv<self.data[i].lv)then
				flag=true
				table.insert(self.data,i,cellData)
				break
			elseif(cellData.lv==self.data[i].lv)then
				local id1=tonumber(string.sub(cellData.id,2))
				local id2=tonumber(string.sub(self.data[i].id,2))
				if(id1<id2)then
					flag=true
					table.insert(self.data,i,cellData)
					break
				end
			end
		end
		if(flag==false)then
			table.insert(self.data,cellData)
		end
	end
end

function allianceShopDialogTabP:initTick()
	self.countdown=allianceShopVoApi:getNextRefreshTime(1)-base.serverTime
end

function allianceShopDialogTabP:initDesc()
	local tip=GetTTFLabelWrap(getlocal("allianceShop_tip1"),25,CCSizeMake(G_VisibleSizeWidth-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	tip:setAnchorPoint(ccp(0,0.5))
	tip:setPosition(ccp(30,G_VisibleSizeHeight-225))
	tip:setColor(G_ColorYellowPro)
	self.bgLayer:addChild(tip)
	local function showInfo()
		local tabStr={"\n",getlocal("allianceShop_info_p2"),"\n",getlocal("allianceShop_info_p1",{allianceShopCfg.cdTime/3600}),"\n",getlocal("activity_baseLeveling_ruleTitle"),"\n"};
		local tabColor={nil,G_ColorWhite,nil,G_ColorWhite,nil,G_ColorGreen,nil}
		PlayEffect(audioCfg.mouseClick)
		local td=smallDialog:new()
		local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
		sceneGame:addChild(dialog,self.layerNum+1)
	end
	local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
	local infoBtn = CCMenu:createWithItem(infoItem);
	infoBtn:setPosition(ccp(G_VisibleSizeWidth-80,G_VisibleSizeHeight-210))
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-5)
	self.bgLayer:addChild(infoBtn)
end

function allianceShopDialogTabP:initTableView()
	local function callBack(...)
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-60,self.bgLayer:getContentSize().height-290),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
	self.tv:setAnchorPoint(ccp(0,0))
	self.tv:setPosition(ccp(30,30))
	self.tv:setMaxDisToBottomOrTop(120)
	self.bgLayer:addChild(self.tv)
end

function allianceShopDialogTabP:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return SizeOfTable(allianceShopCfg.pShopItems)
	elseif fn=="tableCellSizeForIndex" then
		if G_getCurChoseLanguage() == "in" or G_getCurChoseLanguage() =="en" or G_getCurChoseLanguage() =="thai" or G_getCurChoseLanguage() =="de"  or G_getCurChoseLanguage() =="vi" then
           self.cellHeght = 210
        elseif G_getCurChoseLanguage() == "ru" then
          self.cellHeght = 230
        end 
		local tmpSize = CCSizeMake(G_VisibleSizeWidth-60,self.cellHeght)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function () end)
		backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-65,self.cellHeght))
		backSprie:setPosition(ccp((G_VisibleSizeWidth-60)/2,self.cellHeght/2))
		backSprie:setTouchPriority(-(self.layerNum-1)*20-1)

		local cellData=self.data[idx+1]
		local nameStrTb={}
		for k,v in pairs(cellData.rewardTb) do
			table.insert(nameStrTb,v.name.." x"..FormatNumber(v.num))
		end
		local nameLb=GetTTFLabel(table.concat(nameStrTb, ", "),25)
		nameLb:setAnchorPoint(ccp(0,0.5))
		nameLb:setColor(G_ColorGreen)
		nameLb:setPosition(ccp(10,(self.cellHeght/2+50+self.cellHeght)/2))
		backSprie:addChild(nameLb)

		local limitLb=GetTTFLabel("("..cellData.curTime.."/"..cellData.maxTime..")",25)
		limitLb:setAnchorPoint(ccp(0,0.5))
		limitLb:setPosition(ccp(10+nameLb:getContentSize().width+5,(self.cellHeght/2+50+self.cellHeght)/2))
		backSprie:addChild(limitLb)

		local award=cellData.rewardTb[1]
		local icon
		local iconSize=100
		if(award.type and award.type=="e")then
			if(award.eType)then
				if(award.eType=="a")then
					icon=accessoryVoApi:getAccessoryIcon(award.key,80,iconSize)
				elseif(award.eType=="f")then
					icon=accessoryVoApi:getFragmentIcon(award.key,80,iconSize)
				elseif(award.pic and award.pic~="")then
					icon=GetBgIcon(award.pic,nil,nil,80,iconSize)
				end
			end
		elseif(award.equipId)then
			local eType=string.sub(award.equipId,1,1)
			if(eType=="a")then
				icon=accessoryVoApi:getAccessoryIcon(award.equipId,80,iconSize)
			elseif(eType=="f")then
				icon=accessoryVoApi:getFragmentIcon(award.equipId,80,iconSize)
			elseif(eType=="p")then
				icon=GetBgIcon(accessoryCfg.propCfg[award.equipId].icon,nil,nil,80,iconSize)
			end
		elseif(award.pic and award.pic~="")then
			icon=GetBgIcon(award.pic,nil,nil,80,iconSize)
		end
		if(icon)then
			icon:setAnchorPoint(ccp(0,0.5))
			icon:setPosition(ccp(10,self.cellHeght/2-10))
			backSprie:addChild(icon)
		end

		local descLb=GetTTFLabelWrap(getlocal(cellData.rewardTb[1].desc),22,CCSizeMake(G_VisibleSizeWidth-335,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		descLb:setAnchorPoint(ccp(0,1))
		descLb:setPosition(ccp(130,self.cellHeght/2+40))
		backSprie:addChild(descLb)

		local priceDescLb=GetTTFLabel(getlocal("alliance_contribution"),25)
		priceDescLb:setPosition(ccp(G_VisibleSizeWidth-135,self.cellHeght*3/4))
		backSprie:addChild(priceDescLb)

		local priceLb=GetTTFLabel(cellData.price,25)
		priceLb:setPosition(ccp(G_VisibleSizeWidth-135,self.cellHeght/2+10))
		if(allianceMemberVoApi:getCanUseDonate(playerVoApi:getUid())<cellData.price)then
			priceLb:setColor(G_ColorRed)
		else
			priceLb:setColor(G_ColorYellowPro)
		end
		backSprie:addChild(priceLb)

		local function onClick(tag,object)
			if(allianceVoApi:getJoinTime()>=base.serverTime-allianceShopCfg.cdTime)then
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allianceShop_errorNewmemberCD",{allianceShopCfg.cdTime/3600}),30)
				do return end
			end
			if(allianceMemberVoApi:getCanUseDonate(playerVoApi:getUid())<cellData.price)then
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allianceShop_donateNotEnough"),30)
				do return end
			end
			if(tag)then
				self:buyItem(tag-self.tagOffset)
			end
		end
		local buyItem = GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",onClick,nil,getlocal("code_gift"),25)
		buyItem:setTag(self.tagOffset+idx+1)
		buyItem:setScale(0.8)
		if(cellData.curTime>=cellData.maxTime)then
			buyItem:setEnabled(false)
		end
		local buyBtn = CCMenu:createWithItem(buyItem)
		buyBtn:setPosition(ccp(G_VisibleSizeWidth-135,self.cellHeght/4))
		buyBtn:setTouchPriority(-(self.layerNum-1)*20-2)
		backSprie:addChild(buyBtn)

		local selfLv=allianceVoApi:getSelfAlliance().level
		if(selfLv<cellData.lv)then
			local mask = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
			mask:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,self.cellHeght))
			mask:setOpacity(200)
			mask:setPosition(ccp((G_VisibleSizeWidth-60)/2,self.cellHeght/2))
			mask:setTouchPriority(-(self.layerNum-1)*20-3)
			cell:addChild(mask,2)
			local unlockDesc=GetTTFLabelWrap(getlocal("alliance_skillUnlockLv",{cellData.lv}),28,CCSizeMake(G_VisibleSizeWidth-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			unlockDesc:setColor(G_ColorRed)
			unlockDesc:setPosition(ccp((G_VisibleSizeWidth-60)/2,self.cellHeght/2))
			cell:addChild(unlockDesc,3)
			local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 20, 10, 10),function ()end)
			titleBg:setContentSize(CCSizeMake(titleBg:getContentSize().width,unlockDesc:getContentSize().height+10))
			titleBg:setScaleX((G_VisibleSizeWidth-60)/titleBg:getContentSize().width)
			titleBg:setPosition(ccp((G_VisibleSizeWidth-60)/2,self.cellHeght/2))
			cell:addChild(titleBg,2)
		end

		cell:addChild(backSprie,1)
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
	end
end

function allianceShopDialogTabP:tick()
	if(self.countdown)then
		self.countdown=self.countdown-1
		if(self.countdown<=0)then
			local function callback(data)
				self:initWithData(data)
				self:initTick()
				local recordPoint = self.tv:getRecordPoint()
				self.tv:reloadData()
				self.tv:recoverToRecordPoint(recordPoint)
			end
			allianceShopVoApi:getPShopData(callback)
		end
	end
end

function allianceShopDialogTabP:buyItem(index)
	local cellData=self.data[index]
	if(cellData.curTime<cellData.maxTime)then
		local function callback()
			local function onGetData(data)
				self:initWithData(data)
				local recordPoint = self.tv:getRecordPoint()
				self.tv:reloadData()
				self.tv:recoverToRecordPoint(recordPoint)
				self.parent.myDonateLb:setString(allianceMemberVoApi:getCanUseDonate(playerVoApi:getUid()))
			end
			allianceShopVoApi:getPShopData(onGetData)
		end
		allianceShopVoApi:buyItem(1,cellData.id,nil,callback)
	end
end

function allianceShopDialogTabP:dispose()
	self.data=nil
end