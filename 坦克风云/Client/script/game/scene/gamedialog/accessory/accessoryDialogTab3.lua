--配件的仓库页签
accessoryDialogTab3={}

function accessoryDialogTab3:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.parent=nil
	nc.subTabs={}
	nc.curTab=1
	nc.aData=nil
	nc.fData=nil
	nc.pData=nil
	nc.tv1=nil
	nc.tv2=nil
	nc.tv3=nil
	nc.tabShop=nil
	nc.gridWidth=0
	return nc
end

function accessoryDialogTab3:init(layerNum,parent)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self.parent=parent
	self:initBackground()
	self.gridWidth=(self.bgLayer:getContentSize().width-70)/4-10
	self:switchSubTab(1,false)
	local function onRefresh(event,data)
		self:refresh(data)
	end
	self.refreshListener=onRefresh
	eventDispatcher:addEventListener("accessory.data.refresh",self.refreshListener)
	return self.bgLayer
end

function accessoryDialogTab3:refresh(data)
	for k,v in pairs(data.type) do
		if(v==1)then
			self.aData=accessoryVoApi:getAccessoryBag()
			if(self.aData==nil)then
				self.aData={}
			end
			if(self.tv1~=nil)then
				local recordPoint = self.tv1:getRecordPoint()
				self.tv1:reloadData()
				self.tv1:recoverToRecordPoint(recordPoint)
			end
		elseif(v==2)then
			self.fData=accessoryVoApi:getFragmentBag()
			if(self.fData==nil)then
				self.fData={}
			end
			if(self.tv2~=nil)then
				local recordPoint = self.tv2:getRecordPoint()
				self.tv2:reloadData()
				self.tv2:recoverToRecordPoint(recordPoint)
			end
		elseif(v==3)then
			self.pData={}
			for pid,num in pairs(accessoryVoApi:getPropNums()) do
				if(num>0)then
					table.insert(self.pData,{id=pid,num=num})
				end
			end	
			local function sortFunc(a,b)
				return accessoryCfg.propCfg[a.id].index<accessoryCfg.propCfg[b.id].index
			end
			table.sort(self.pData,sortFunc)
			if(self.tv3~=nil)then
				local recordPoint = self.tv3:getRecordPoint()
				self.tv3:reloadData()
				self.tv3:recoverToRecordPoint(recordPoint)
			end
			if(self.tabShop~=nil)then
				self.tabShop:refresh()
			end
		end
	end
end

function accessoryDialogTab3:initBackground()
	local function nilFun()
	end
	local capInSet = CCRect(20, 20, 10, 10);
	self.panelLineBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",capInSet,nilFun)
	self.panelLineBg:setAnchorPoint(ccp(0,0))
	self.panelLineBg:setPosition(ccp(30,175))
	self.panelLineBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,self.bgLayer:getContentSize().height-380))
	self.bgLayer:addChild(self.panelLineBg)
	local tabStr={getlocal("accessory"),getlocal("fragment"),getlocal("accessory_material")}
	if(base.ecshop==1)then
		table.insert(tabStr,getlocal("code_gift"))
	end
	for k,v in pairs(tabStr) do
		local subTabBtn=CCMenu:create()
		local subTabItem=CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
		subTabItem:setAnchorPoint(ccp(0,0))
		local function tabSubClick(idx)
			return self:switchSubTab(idx)
		end
		subTabItem:registerScriptTapHandler(tabSubClick)
		local lb=GetTTFLabelWrap(v,24,CCSizeMake(subTabItem:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
		lb:setPosition(CCPointMake(subTabItem:getContentSize().width/2,subTabItem:getContentSize().height/2))
		subTabItem:addChild(lb)
		self.subTabs[k]=subTabItem
		subTabBtn:addChild(subTabItem)
		subTabItem:setTag(k)
		subTabBtn:setPosition(ccp((k-1)*subTabItem:getContentSize().width+30,self.bgLayer:getContentSize().height-210))
		subTabBtn:setTouchPriority(-(self.layerNum-1)*20-4)
		self.bgLayer:addChild(subTabBtn)
	end
	local function onBulkSale(tag,object)
		PlayEffect(audioCfg.mouseClick)
		if FuncSwitchApi:isEnabled("accessory_warehouse_expand") and self.curTab == 2 then
			local batchData = {
				{getlocal("accessory_bulkcompose"), function() self:bulkCompose() end},
				{getlocal("bulksale"), function() self:bulkSale() end}
			}
			accessoryVoApi:showBatchSmallDialog(self.layerNum + 1, getlocal("dialog_title_prompt"), batchData)
		else
			self:bulkSale()
		end
	end
	
	local textSize = 24
	local bulkLbSize = 24
	if platCfg.platCfgBMImage[G_curPlatName()]~=nil then
		textSize=20
		bulkLbSize =20
	end
    if G_getCurChoseLanguage() =="ru" then
        bulkLbSize =20
    end
	local bulkSaleItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onBulkSale,nil,getlocal("bulksale"),bulkLbSize,101)
	bulkSaleItem:setAnchorPoint(ccp(0.5,0.5))
	local btnLb = bulkSaleItem:getChildByTag(101)
	if btnLb then
		btnLb = tolua.cast(btnLb,"CCLabelTTF")
		btnLb:setFontName("Helvetica-bold")
		self.bulkSaleBtnLb = btnLb
	end
	self.bulkSaleBtn=CCMenu:createWithItem(bulkSaleItem)
	self.bulkSaleBtn:setAnchorPoint(ccp(0.5,0.5))
	self.bulkSaleBtn:setPosition(self.bgLayer:getContentSize().width/2,130)
	self.bulkSaleBtn:setTouchPriority(-(self.layerNum-1)*20-3)
	self.bgLayer:addChild(self.bulkSaleBtn)

	self.bulkSaleDesc=GetTTFLabelWrap(getlocal("accessory_bulksale_desc"),25,CCSizeMake(self.bgLayer:getContentSize().width-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	self.bulkSaleDesc:setPosition(self.bgLayer:getContentSize().width/2,60)
	self.bgLayer:addChild(self.bulkSaleDesc)

	local function onBulkCompose(tag,object)
		PlayEffect(audioCfg.mouseClick)
		if FuncSwitchApi:isEnabled("accessory_warehouse_expand") and (self.curTab == 1 or self.curTab == 2) then
			local costGold = accessoryVoApi:getBagDilatationCostNum(self.curTab)
			local tipsStr = getlocal("accessoryDilatationTips", {costGold, accessoryCfg.increments, tabStr[self.curTab]})
			G_showSureAndCancle(tipsStr, function()
				local gems = playerVoApi:getGems()
                if gems < costGold then
                    GemsNotEnoughDialog(nil, nil, costGold - gems, self.layerNum + 1, costGold)
                    do return end
                end
				socketHelper:accessoryBagDilatation(self.curTab, function(fn, data)
					local ret, sData = base:checkServerData(data)
			        if ret == true then
			        	if sData and sData.data then
							accessoryVoApi:updateDilatationNum(sData.data)
							playerVoApi:setGems(playerVoApi:getGems() - costGold)
							-- self:refresh({type={self.curTab}})
							local bagTv
							if self.curTab == 1 then
								self.aData=accessoryVoApi:getAccessoryBag()
								if(self.aData==nil)then
									self.aData={}
								end
								bagTv = self.tv1
							elseif self.curTab == 2 then
								self.fData=accessoryVoApi:getFragmentBag()
								if(self.fData==nil)then
									self.fData={}
								end
								bagTv = self.tv2
							end
							if bagTv ~= nil then
								local recordPoint = bagTv:getRecordPoint()
								self.gridTvAction = true
								bagTv:reloadData()
								recordPoint.y = 0
								bagTv:recoverToRecordPoint(recordPoint)
							end
							self:switchSubTab(self.curTab)
						end
					end
				end)
			end)
		else
			self:bulkCompose()
		end
	end
	local bulkComposeItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onBulkCompose,nil,getlocal("accessory_bulkcompose"),textSize,101)
	bulkComposeItem:setAnchorPoint(ccp(0.5,0.5))
	self.bulkComposeItem = bulkComposeItem
	local btnLb = bulkComposeItem:getChildByTag(101)
	if btnLb then
		btnLb = tolua.cast(btnLb,"CCLabelTTF")
		btnLb:setFontName("Helvetica-bold")
		self.bulkComposeBtnLb = btnLb
	end
	self.bulkComposeBtn=CCMenu:createWithItem(bulkComposeItem)
	self.bulkComposeBtn:setAnchorPoint(ccp(0.5,0.5))
	self.bulkComposeBtn:setPosition(G_VisibleSizeWidth/4,130)
	self.bulkComposeBtn:setTouchPriority(-(self.layerNum-1)*20-3)
	self.bgLayer:addChild(self.bulkComposeBtn)
end

function accessoryDialogTab3:switchSubTab(type,isEffect)
	if isEffect==false then
	else
		PlayEffect(audioCfg.mouseClick)
	end
	for k,v in pairs(self.subTabs) do
		if k==type then
			v:setEnabled(false)
			self.curTab=type
		else
			v:setEnabled(true)
		end
	end
	if(type==1)then
		if(self.tv1==nil)then
			self:initABag()
		end
		self.tv1:setPosition(ccp(30,180))
		self.tv1:setVisible(true)
		if(self.tv2~=nil)then
			self.tv2:setPosition(ccp(999333,0))
			self.tv2:setVisible(false)
		end
		if(self.tv3~=nil)then
			self.tv3:setPositionX(999333)
			self.tv3:setVisible(false)
		end
		if(self.tabShop)then
			self.tabShop:setVisible(false)
		end
		if FuncSwitchApi:isEnabled("accessory_warehouse_expand") then
			self.bulkComposeBtn:setPositionX(G_VisibleSizeWidth*3/4)
			self.bulkComposeBtn:setVisible(true)
			if self.bulkComposeBtnLb then
				self.bulkComposeBtnLb:setString(getlocal("dilatationText"))
			end
			if self.bulkSaleBtnLb then
				self.bulkSaleBtnLb:setString(getlocal("bulksale"))
			end
			self.bulkSaleBtn:setPositionX(G_VisibleSizeWidth/4)
			local costNum = accessoryVoApi:getBagDilatationCostNum(type)
			if tonumber(costNum) then
				self.bulkComposeItem:setEnabled(true)
			else
				if self.bulkComposeBtnLb then
					self.bulkComposeBtnLb:setString(getlocal("itsEnough"))
				end
				self.bulkComposeItem:setEnabled(false)
			end
		else
			self.bulkComposeBtn:setPositionX(999333)
			self.bulkComposeBtn:setVisible(false)
			self.bulkSaleBtn:setPositionX(G_VisibleSizeWidth/2)
		end
		self.bulkSaleBtn:setVisible(true)
	elseif(type==2)then
		if(self.tv2==nil)then
			self:initFBag()
		end
		self.tv2:setPosition(ccp(30,180))
		self.tv2:setVisible(true)
		self.tv1:setPosition(ccp(999333,0))
		self.tv1:setVisible(false)
		if(self.tv3~=nil)then
			self.tv3:setPositionX(999333)
			self.tv3:setVisible(false)
		end
		if(self.tabShop)then
			self.tabShop:setVisible(false)
		end
		if FuncSwitchApi:isEnabled("accessory_warehouse_expand") then
			self.bulkComposeBtn:setPositionX(G_VisibleSizeWidth*3/4)
			if self.bulkComposeBtnLb then
				self.bulkComposeBtnLb:setString(getlocal("dilatationText"))
			end
			if self.bulkSaleBtnLb then
				self.bulkSaleBtnLb:setString(getlocal("batchText"))
			end
			self.bulkSaleBtn:setPositionX(G_VisibleSizeWidth/4)
			local costNum = accessoryVoApi:getBagDilatationCostNum(type)
			if tonumber(costNum) then
				self.bulkComposeItem:setEnabled(true)
			else
				if self.bulkComposeBtnLb then
					self.bulkComposeBtnLb:setString(getlocal("itsEnough"))
				end
				self.bulkComposeItem:setEnabled(false)
			end
		else
			self.bulkComposeBtn:setPositionX(G_VisibleSizeWidth/4)
			self.bulkSaleBtn:setPositionX(G_VisibleSizeWidth*3/4)
		end
		self.bulkComposeBtn:setVisible(true)
		self.bulkSaleBtn:setVisible(true)
	elseif(type==3)then
		if(self.tv3==nil)then
			self:initPBag()
		end
		self.tv3:setPosition(ccp(30,50))
		self.tv3:setVisible(true)
		self.tv1:setPosition(ccp(999333,0))
		self.tv1:setVisible(false)
		if(self.tv2~=nil)then
			self.tv2:setPosition(ccp(999333,0))
			self.tv2:setVisible(false)
		end
		if(self.tabShop)then
			self.tabShop:setVisible(false)
		end
	elseif(type==4)then
		if(self.tabShop==nil)then
			require "luascript/script/game/scene/gamedialog/accessory/accessoryDialogSubTabShop"
			self.tabShop=accessoryDialogSubTabShop:new()
			self.tabShop:init(self.layerNum + 1)
			self.bgLayer:addChild(self.tabShop.bgLayer,1)
		end
		self.tabShop:setVisible(true)
		self.tv1:setPosition(ccp(999333,0))
		self.tv1:setVisible(false)
		if(self.tv2~=nil)then
			self.tv2:setPosition(ccp(999333,0))
			self.tv2:setVisible(false)
		end
		if(self.tv3~=nil)then
			self.tv3:setPositionX(999333)
			self.tv3:setVisible(false)
		end
	end
	if(type==3 or type==4)then
		self.bulkComposeBtn:setPositionX(999333)
		self.bulkComposeBtn:setVisible(false)
		self.bulkSaleBtn:setPositionX(999333)
		self.bulkSaleBtn:setVisible(false)
		self.bulkSaleDesc:setPositionX(999333)
		self.bulkSaleDesc:setVisible(false)
		self.panelLineBg:setPosition(ccp(30,40))
		self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,G_VisibleSizeHeight-245))
	else
		self.bulkSaleDesc:setPositionX(G_VisibleSizeWidth/2)
		self.bulkSaleDesc:setVisible(true)
	end
end

function accessoryDialogTab3:initABag()
	self.aData=accessoryVoApi:getAccessoryBag()
	if(self.aData==nil)then
		self.aData={}
	end
	local tmp=SizeOfTable(self.aData)
	for i=tmp+1,accessoryVoApi:getABagGrid() do
		self.aData[i]=nil
	end
	local function callBack(...)
		return self:eventHandler1(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv1=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-50,self.bgLayer:getContentSize().height-390),nil)
	self.tv1:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.bgLayer:addChild(self.tv1,1)
	self.tv1:setMaxDisToBottomOrTop(100)
end

function accessoryDialogTab3:eventHandler1(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return accessoryVoApi:getABagGrid()/4
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-30,self.gridWidth+10)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local isAction
		if self.gridTvAction and idx + 1 == accessoryVoApi:getABagGrid()/4 then
			isAction = true
			self.gridTvAction = nil
		end
		for i=1,4 do
			local icon
			local tmpData=self.aData[idx*4+i]
			if(tmpData~=nil)then
				local function onClickAccessory(object,fn,tag)
					if self.tv1:getIsScrolled()==true then
						do return end
					end
					if G_checkClickEnable()==false then
						do
							return
						end
					else
						base.setWaitTime=G_getCurDeviceMillTime()
					end
					self:showEquipAndSell(tag)
				end
				icon=accessoryVoApi:getAccessoryIcon(tmpData.type,70,self.gridWidth,onClickAccessory)
				icon:setTag(1000+idx*4+i)
				local rankTip=CCSprite:createWithSpriteFrameName("IconLevel.png")
				local rankLb=GetTTFLabel(tmpData.rank,30)
				rankLb:setPosition(ccp(rankTip:getContentSize().width/2,rankTip:getContentSize().height/2))
				rankTip:addChild(rankLb)
				rankTip:setScale(0.5)
				rankTip:setAnchorPoint(ccp(0,1))
				rankTip:setPosition(ccp(0,icon:getContentSize().height))
				icon:addChild(rankTip)

				local lvLb=GetTTFLabel("Lv. "..tmpData.lv,15)
				lvLb:setAnchorPoint(ccp(1,0))
				lvLb:setPosition(ccp(icon:getContentSize().width-10,5))
				icon:addChild(lvLb)
				icon:setTouchPriority(-(self.layerNum-1)*20-2)
			else
				icon=CCSprite:createWithSpriteFrameName("Icon_BG.png")
				icon:setScale(self.gridWidth/icon:getContentSize().width)
			end
			icon:setAnchorPoint(ccp(0,0))
			icon:setPosition(ccp((i-1)*(self.gridWidth+10)+10,5))
			cell:addChild(icon)
			if isAction then
				icon:setVisible(false)
				icon:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.3 + 0.2 * i), CCCallFunc:create(function() icon:setVisible(true) end)))
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

function accessoryDialogTab3:initFBag()
	self.fData=accessoryVoApi:getFragmentBag()
	if(self.fData==nil)then
		self.fData={}
	end
	local tmp=SizeOfTable(self.fData)
	for i=tmp+1,accessoryVoApi:getFBagGrid() do
		self.fData[i]=nil
	end
	local function callBack(...)
		return self:eventHandler2(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv2=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-50,self.bgLayer:getContentSize().height-390),nil)
	self.tv2:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.bgLayer:addChild(self.tv2,1)
	self.tv2:setMaxDisToBottomOrTop(100)
end

function accessoryDialogTab3:eventHandler2(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return accessoryVoApi:getFBagGrid()/4
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-30,self.gridWidth+10)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local isAction
		if self.gridTvAction and idx + 1 == accessoryVoApi:getFBagGrid()/4 then
			isAction = true
			self.gridTvAction = nil
		end
		for i=1,4 do
			local icon
			local tmpData=self.fData[idx*4+i]
			if(tmpData~=nil)then
				local function onClickF0(object,fn,tag)
					if self.tv2:getIsScrolled()==true then
						do return end
					end
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_f0_desc"),30)
				end
				local function onClickFragment(object,fn,tag)
					if self.tv2:getIsScrolled()==true then
						do return end
					end
					if G_checkClickEnable()==false then
						do
							return
						end
					else
						base.setWaitTime=G_getCurDeviceMillTime()
					end
					self:showComposeAndSell(tag)
				end
				if(tmpData:getConfigData("output")=="")then
					icon=accessoryVoApi:getFragmentIcon(tmpData.id,70,self.gridWidth,onClickF0)
				else
					icon=accessoryVoApi:getFragmentIcon(tmpData.id,70,self.gridWidth,onClickFragment)
				end
				
				icon:setTag(2000+idx*4+i)
				icon:setTouchPriority(-(self.layerNum-1)*20-2)
				local numLb=GetTTFLabel("x"..tmpData.num,17)
				numLb:setAnchorPoint(ccp(1,0))
				if(tmpData.num>=tonumber(tmpData:getConfigData("composeNum")))then
					numLb:setColor(G_ColorGreen)
				else
					numLb:setColor(G_ColorRed)
				end
				numLb:setPosition(ccp(icon:getContentSize().width-10,5))
				icon:addChild(numLb)
			else
				icon=CCSprite:createWithSpriteFrameName("Icon_BG.png")
				icon:setScale(self.gridWidth/icon:getContentSize().width)
			end
			icon:setAnchorPoint(ccp(0,0))
			icon:setPosition(ccp((i-1)*(self.gridWidth+10)+10,5))
			cell:addChild(icon)
			if isAction then
				icon:setVisible(false)
				icon:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.3 + 0.2 * i), CCCallFunc:create(function() icon:setVisible(true) end)))
			end
		end
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded" then
	end
end

function accessoryDialogTab3:showEquipAndSell(tag)
	local index=tag-1000
	local aVo=self.aData[index]
	--验证一下,防止点击过快， 还没刷新就继续点击造成的数据不一致
	local checkVo=accessoryVoApi:getAccessoryBag()[index]
	if(checkVo==nil or aVo.id~=checkVo.id)then
		do return end
	end

	accessoryVoApi:showSmallDialog(self.layerNum+1,1,aVo,self,nil,nil,1)
end

function accessoryDialogTab3:showComposeAndSell(tag)
	local index=tag-2000
	local fVo=self.fData[index]
	--验证一下,防止点击过快， 还没刷新就继续点击造成的数据不一致
	local checkVo=accessoryVoApi:getFragmentBag()[index]
	if(checkVo==nil or fVo.id~=checkVo.id)then
		do return end
	end
	accessoryVoApi:showSmallDialog(self.layerNum+1,2,fVo,self,nil,nil,1)
end

function accessoryDialogTab3:bulkSale()
	accessoryVoApi:showBulkSaleDialog(self.curTab,self.layerNum+1)
end

function accessoryDialogTab3:bulkCompose()
	local function onConfirm()
		local function callBack()
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_composeSuccess"),30)
		end
		local result=accessoryVoApi:bulkCompose();
		if(result>0)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_bulkcomposeError"..result),30)
		end
	end
	smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("accessory_bulkcomposeDesc"),nil,self.layerNum+1)
end

function accessoryDialogTab3:initPBag()
	self.pData={}
	for pid,num in pairs(accessoryVoApi:getPropNums()) do
		if(num>0)then
			table.insert(self.pData,{id=pid,num=num})
		end
	end	
	local function sortFunc(a,b)
		return accessoryCfg.propCfg[a.id].index<accessoryCfg.propCfg[b.id].index
	end
	table.sort(self.pData,sortFunc)
	local function callBack(...)
		return self:eventHandler3(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv3=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-50,G_VisibleSizeHeight-260),nil)
	self.tv3:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.bgLayer:addChild(self.tv3,1)
	self.tv3:setMaxDisToBottomOrTop(100)
end

function accessoryDialogTab3:eventHandler3(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		if(G_isIphone5())then
			return math.max(math.ceil(#self.pData/4),6)
		else
			return math.max(math.ceil(#self.pData/4),5)
		end
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(G_VisibleSizeWidth - 30,self.gridWidth+10)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		for i=1,4 do
			local icon
			local tmpData=self.pData[idx*4+i]
			if(tmpData~=nil)then
				local function onClickProp(object,fn,tag)
					if self.tv3:getIsScrolled()==true then
						do return end
					end
					if G_checkClickEnable()==false then
						do return end
					else
						base.setWaitTime=G_getCurDeviceMillTime()
					end
					self:showPropDialog(tag)
				end
				local iconStr=accessoryCfg.propCfg[tmpData.id]["icon"]
				icon=LuaCCSprite:createWithSpriteFrameName(iconStr,onClickProp)
				icon:setTag(3000+idx*4+i)
				icon:setScale(self.gridWidth/icon:getContentSize().width)
				icon:setTouchPriority(-(self.layerNum-1)*20-2)
				local numLb=GetTTFLabel("x"..FormatNumber(tmpData.num),17)
				numLb:setAnchorPoint(ccp(1,0))
				if(tmpData.id=="p11")then
					if(tmpData.num>=accessoryCfg.change.use[tmpData.id])then
						numLb:setColor(G_ColorGreen)
					else
						numLb:setColor(G_ColorRed)
					end
				end
				numLb:setPosition(ccp(icon:getContentSize().width-10,5))
				icon:addChild(numLb)
			else
				icon=CCSprite:createWithSpriteFrameName("Icon_BG.png")
				icon:setScale(self.gridWidth/icon:getContentSize().width)
			end
			icon:setAnchorPoint(ccp(0,0))
			icon:setPosition(ccp((i-1)*(self.gridWidth+10)+10,5))
			cell:addChild(icon)
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

function accessoryDialogTab3:showPropDialog(tag)
	local index=tag-3000
	local prop=self.pData[index]
	--验证一下,防止点击过快， 还没刷新就继续点击造成的数据不一致
	local propID=prop.id
	local propNum=accessoryVoApi:getPropNums()[propID]
	if(propNum==nil or propNum~=prop.num)then
		do return end
	end
	accessoryVoApi:showSmallDialog(self.layerNum+1,3,prop,self,nil,nil,1)
end

function accessoryDialogTab3:dispose()
	eventDispatcher:removeEventListener("accessory.data.refresh",self.refreshListener)
	self.subTabs=nil
	self.curTab=nil
	self.aData=nil
	self.fData=nil
	self.pData=nil
	self.tv1=nil
	self.tv2=nil
	self.tv3=nil
	self.gridTvAction=nil
	if(self.tabShop)then
		self.tabShop:dispose()
	end
	self.tabShop=nil
	self.gridWidth=nil
	self.panelLineBg=nil
	self.bgLayer=nil
	self.layerNum=nil
end

