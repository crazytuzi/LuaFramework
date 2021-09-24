armorMatrixShopDialog=commonDialog:new()

function armorMatrixShopDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.btnScale1=140/205
    nc.normalHeight=150
    spriteController:addPlist("public/yellowFlicker.plist")
    spriteController:addTexture("public/yellowFlicker.png")
    return nc
end

function armorMatrixShopDialog:doUserHandler()
	local startH=G_VisibleSizeHeight-90
	local headerH=200
	local posH=startH

	self.panelLineBg:setContentSize(CCSizeMake(600,startH-headerH-30))
    self.panelLineBg:setAnchorPoint(ccp(0,0))
    self.panelLineBg:setPosition(ccp(20,20))
    self.panelLineBg:setVisible(true)
    self.bgLayer:reorderChild(self.panelLineBg,2)

    self:setShopInfo()

	local headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),function (...)end)
	headerSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,headerH))
	headerSprie:ignoreAnchorPointForPosition(false)
	headerSprie:setAnchorPoint(ccp(0.5,1))
	headerSprie:setIsSallow(false)
	headerSprie:setTouchPriority(-(self.layerNum-1)*20-1)
	headerSprie:setPosition(ccp(G_VisibleSizeWidth/2,posH))
	self.bgLayer:addChild(headerSprie,2)

	local headSize=headerSprie:getContentSize()

	local posy=headSize.height-40
	local lineSp1=CCSprite:createWithSpriteFrameName("lineAndPoint.png")
	lineSp1:setAnchorPoint(ccp(0,0.5))
	lineSp1:setPosition(ccp(200,posy))
	headerSprie:addChild(lineSp1,1)
	lineSp1:setRotation(180)
	local lineSp2=CCSprite:createWithSpriteFrameName("lineAndPoint.png")
	lineSp2:setAnchorPoint(ccp(0,0.5))
	lineSp2:setPosition(ccp(headSize.width-200,posy))
	headerSprie:addChild(lineSp2,1)

    local strSize2 = 18
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
        strSize2 =24
    end
	local titleLb=GetTTFLabelWrap(getlocal("armorMatrix_epoor"),24,CCSizeMake(300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
	-- titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(headSize.width/2,posy))
	headerSprie:addChild(titleLb,1)
	titleLb:setColor(G_ColorYellowPro)

	local iconSp=CCSprite:createWithSpriteFrameName("equipBg_blue.png")
	iconSp:setAnchorPoint(ccp(0,0.5))
	iconSp:setPosition(20,(posy-titleLb:getContentSize().height/2)/2)
	headerSprie:addChild(iconSp)

    local expIcon=CCSprite:createWithSpriteFrameName("armorMatrixExp.png")
    iconSp:addChild(expIcon)
    expIcon:setPosition(getCenterPoint(iconSp))

    local armorMatrixInfo=armorMatrixVoApi:getArmorMatrixInfo()
	local expPosX=130
	local haveExpLb=GetTTFLabelWrap(getlocal("ownedXp",{armorMatrixInfo.exp or 0}),24,CCSizeMake(headSize.width-expPosX-15,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom,"Helvetica-bold")
	iconSp:addChild(haveExpLb)
	haveExpLb:setAnchorPoint(ccp(0,0))
	haveExpLb:setPosition(expPosX,iconSp:getContentSize().height/2+15)
    self.haveExpLb=haveExpLb

	local expDesLb=GetTTFLabelWrap(getlocal("armorMatrix_exp_des"),20,CCSizeMake(headSize.width-expPosX-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	iconSp:addChild(expDesLb)
	expDesLb:setAnchorPoint(ccp(0,1))
	expDesLb:setPosition(expPosX,iconSp:getContentSize().height/2+5)
	self.expDesLb=expDesLb
	self:refreshExpDesLb()
end

function armorMatrixShopDialog:refreshExpDesLb()
	local expDesStr
	if self.shopType==1 then
		expDesStr=getlocal("armorMatrix_exp_des")
	else
		expDesStr=getlocal("armor_shop_des1")
	end
	self.expDesLb:setString(expDesStr)
end

function armorMatrixShopDialog:initTableView()
	

	local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-60,G_VisibleSizeHeight-90-210-30-10),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,30))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(80)
end

function armorMatrixShopDialog:eventHandler(handler,fn,idx,cel)
	local strSize2,addPosX2 = 16,10
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
		strSize2,addPosX2 = 22,0
	end
    if fn=="numberOfCellsInTableView" then
        return self.shopNum
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-60,self.normalHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local cellHeight=self.normalHeight-5
        local function cellClick(hd,fn,idx)
		end
        local capInSet=CCRect(20, 20, 10, 10)
        local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
		backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-60, cellHeight))
		backSprie:ignoreAnchorPointForPosition(false);
		backSprie:setAnchorPoint(ccp(0,0));
		backSprie:setIsSallow(false)
		backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
		cell:addChild(backSprie,1)

		local bsSize=backSprie:getContentSize()

		if self.shopType==1 then
			local armorshopCfg=armorMatrixVoApi:getArmorshopCfg()
			local preshoplist=armorshopCfg.preshoplist
			local id=self.shopInfo[idx+1].id
			local index=self.shopInfo[idx+1].index
			local infoTb=preshoplist[id]
			local rewardTb=FormatItem(infoTb.reward)
			if(rewardTb and rewardTb[1])then
				local reward=rewardTb[1]
				local iconHight=bsSize.height/2-15
				local icon,scale=G_getItemIcon(reward,90,true,self.layerNum)
				icon:setPosition(60,iconHight)
				icon:setTouchPriority(-(self.layerNum-1)*20-2)
				backSprie:addChild(icon)

				if infoTb.flicker then
					local indexTb={y=3,b=1,p=2,g=4}
					G_addRectFlicker2(icon,1.2,1.2,indexTb[infoTb.flicker],infoTb.flicker,nil,3)
				end

				local numLb=GetTTFLabel("x"..FormatNumber(reward.num),strSize2)
				numLb:setAnchorPoint(ccp(1,0))
				numLb:setPosition(icon:getContentSize().width-5,5)
				icon:addChild(numLb)

				local nameLb=GetTTFLabelWrap(reward.name,22,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
				nameLb:setAnchorPoint(ccp(0,0))
				backSprie:addChild(nameLb)
				nameLb:setPosition(15,bsSize.height/2+35)
				nameLb:setColor(G_ColorGreen)

				local conditionLb=GetTTFLabelWrap(getlocal("armor_buy_conditions"),24,CCSizeMake(bsSize.width-120-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom,"Helvetica-bold")
				conditionLb:setAnchorPoint(ccp(0,0))
				conditionLb:setPosition(143,iconHight+10)
				backSprie:addChild(conditionLb)

				local needQuality=infoTb.needquality
				local haveNum=armorMatrixVoApi:getUsedQualityNum(needQuality)
				local needNum=infoTb.needNum
				local needStr=getlocal("armor_buy_need1",{haveNum .. "/" .. needNum,getlocal("armorMatrix_color_" .. needQuality)})
				local colorTab
				if haveNum>=needNum then
					colorTab={G_ColorWhite,G_ColorGreen,G_ColorWhite,G_ColorPurple}
				else
					colorTab={G_ColorWhite,G_ColorRed,G_ColorWhite,G_ColorPurple}
				end

				local needLb,lbHeight=G_getRichTextLabel(needStr,colorTab,20,bsSize.width-120-150,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,0,true)
				needLb:setAnchorPoint(ccp(0,1))
				backSprie:addChild(needLb)
				needLb:setPosition(143,iconHight-10)

				local price=infoTb.price

				local function buyFunc()
			        if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
					    if G_checkClickEnable()==false then
					        do
					            return
					        end
					    else
					        base.setWaitTime=G_getCurDeviceMillTime()
					    end

					    if haveNum<needNum then
						    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("armor_buy_des1"),30)
							do return end
						else
							local gems=playerVoApi:getGems() or 0
							if gems<price then
								local function onSure()
					                -- activityAndNoteDialog:closeAllDialog()
					            end
					            GemsNotEnoughDialog(nil,nil,price-gems,self.layerNum+1,price,onSure)
								do return end
							else
								local function refreshFunc()
									smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("vip_tequanlibao_goumai_success"),30)
									playerVoApi:setGems(playerVoApi:getGems() - price)
									self:refreshTv()
								end
								armorMatrixVoApi:shopExchange(refreshFunc,1,id)
							end
						end

					end
			    end
			    local lbStr2=getlocal("buy")
			    local buyItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",buyFunc,nil,lbStr2,24/self.btnScale1,11)
			    buyItem:setScale(self.btnScale1)
			    local btnLb = buyItem:getChildByTag(11)
			    if btnLb then
			    	btnLb = tolua.cast(btnLb,"CCLabelTTF")
			    	btnLb:setFontName("Helvetica-bold")
			    end
			    local buyBtn=CCMenu:createWithItem(buyItem);
			    buyBtn:setTouchPriority(-(self.layerNum-1)*20-2);
			    buyBtn:setPosition(ccp(bsSize.width-80,iconHight))
			    backSprie:addChild(buyBtn)

			    local childH=buyItem:getContentSize().height+30
			    local expIcon1=CCSprite:createWithSpriteFrameName("IconGold.png")
			    buyItem:addChild(expIcon1)
			    expIcon1:setPositionY(childH)
			    expIcon1:setAnchorPoint(ccp(0.5,0.5))
			    expIcon1:setScale(1/self.btnScale1)

			    local iconLb1=GetTTFLabel(price,25)
			    buyItem:addChild(iconLb1)
			    iconLb1:setPositionY(childH)
			    iconLb1:setAnchorPoint(ccp(0.5,0.5))
			    iconLb1:setScale(1/self.btnScale1)

			    G_setchildPosX(buyItem,expIcon1,iconLb1)

			end

		else
			local armorshopCfg=armorMatrixVoApi:getArmorshopCfg()
			local shoplist=armorshopCfg.shoplist
			local id=self.shopInfo[idx+1].id
			local index=self.shopInfo[idx+1].index
			local infoTb=shoplist[id]
			local rewardTb=FormatItem(infoTb.reward)

			local armorMatrixInfo=armorMatrixVoApi:getArmorMatrixInfo()
			local exinfo=armorMatrixInfo.exinfo or {}
			local s=exinfo.s or {}
			local buyNum=(s[2] or {})[id] or 0


			if(rewardTb and rewardTb[1])then
				local reward=rewardTb[1]
				local iconHight=bsSize.height/2-15
				local icon,scale=G_getItemIcon(reward,90,true,self.layerNum)
				icon:setPosition(60,iconHight)
				icon:setTouchPriority(-(self.layerNum-1)*20-2)
				backSprie:addChild(icon)

				local numLb=GetTTFLabel("x"..FormatNumber(reward.num),22)
				numLb:setAnchorPoint(ccp(1,0))
				numLb:setPosition(icon:getContentSize().width-5,5)
				icon:addChild(numLb)

				-- buyNum
				local limittimes=infoTb.limittimes
				local colorTab={G_ColorYellowPro,G_ColorWhite}

				local StitchingStr="(" .. buyNum .. "/" .. limittimes .. ")"
				local nameStr=reward.name .. "<rayimg>" .. StitchingStr .. "<rayimg>"
				local nameLb=G_getRichTextLabel(nameStr,colorTab,strSize2,bsSize.width-100,kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom,0,true)
				-- GetTTFLabelWrap(reward.name,22,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
				nameLb:setAnchorPoint(ccp(0,0))
				backSprie:addChild(nameLb)
				nameLb:setPosition(15,bsSize.height/2+35)
				if G_isShowRichLabel() then
					nameLb:setPosition(15,bsSize.height/2+60)
				end
				-- nameLb:setColor(G_ColorGreen)

				local desLb=GetTTFLabelWrap(getlocal(reward.desc),strSize2,CCSizeMake(bsSize.width-120-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
				desLb:setAnchorPoint(ccp(0,0.5))
				desLb:setPosition(120,iconHight)
				backSprie:addChild(desLb)

				local price=infoTb.aExpcost
				local armorMatrixInfo=armorMatrixVoApi:getArmorMatrixInfo()
				local exp=armorMatrixInfo.exp or 0

				local function buyFunc()
			        if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
					    if G_checkClickEnable()==false then
					        do
					            return
					        end
					    else
					        base.setWaitTime=G_getCurDeviceMillTime()
					    end

						if exp<price then
							smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("armor_no_enough_exp"),30)
							do return end
						else
							local function refreshFunc()
								smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_tccx_change_sucess"),30)
								-- activity_tccx_change_sucess
								G_addPlayerAward(reward.type,reward.key,reward.id,reward.num,nil,true,nil)
								self:refreshTv()
							end
							armorMatrixVoApi:shopExchange(refreshFunc,2,id)
						end

					end
			    end
			    local lbStr2=getlocal("activity_loversDay_tab2")
			    local buyItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",buyFunc,nil,lbStr2,24/self.btnScale1,11)
			    buyItem:setScale(self.btnScale1)
			    local btnLb = buyItem:getChildByTag(11)
			    if btnLb then
			    	btnLb = tolua.cast(btnLb,"CCLabelTTF")
			    	btnLb:setFontName("Helvetica-bold")
			    end
			    if index>10000 then
			    	buyItem:setEnabled(false)
			    end

			    local buyBtn=CCMenu:createWithItem(buyItem);
			    buyBtn:setTouchPriority(-(self.layerNum-1)*20-2);
			    buyBtn:setPosition(ccp(bsSize.width-80,iconHight))
			    backSprie:addChild(buyBtn)

			    local childH=buyItem:getContentSize().height+30
			    local expIcon1=CCSprite:createWithSpriteFrameName("armorMatrixExp.png")
			    buyItem:addChild(expIcon1)
			    expIcon1:setPositionY(childH)
			    expIcon1:setAnchorPoint(ccp(0.5,0.5))
			    expIcon1:setScale(1/self.btnScale1*0.5)

			    local iconLb1=GetTTFLabel(price,25)
			    buyItem:addChild(iconLb1)
			    iconLb1:setPositionY(childH)
			    iconLb1:setAnchorPoint(ccp(0.5,0.5))
			    iconLb1:setScale(1/self.btnScale1)

			    G_setchildPosX(buyItem,expIcon1,iconLb1)


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

-- shopType 1:金币购买 2:经验购买
-- shopInfo 列表内容
-- shopNum 列表个数
function armorMatrixShopDialog:setShopInfo()
	self.shopType,self.shopInfo,self.shopNum=armorMatrixVoApi:getShopInfo()
end

function armorMatrixShopDialog:refreshTv()
	local lastType=self.shopType
	self:setShopInfo()
	local armorMatrixInfo=armorMatrixVoApi:getArmorMatrixInfo()
	self.haveExpLb:setString(getlocal("ownedXp",{armorMatrixInfo.exp or 0}))
	self:refreshExpDesLb()

	if self.shopType==1 then
		self.tv:reloadData()
	else
		if lastType==1 and self.shopType==2 then
			self.tv:reloadData()
		else
			local recordPoint=self.tv:getRecordPoint()
			self.tv:reloadData()
			self.tv:recoverToRecordPoint(recordPoint)
		end
	end
		

end



function armorMatrixShopDialog:tick()
	if self.shopType and self.shopType==2 then
		local armorMatrixInfo=armorMatrixVoApi:getArmorMatrixInfo()
		local exinfo=armorMatrixInfo.exinfo or {}
		local s=exinfo.s or {}
		local ts=s[1] or 0
		if G_isToday(ts)==false then
			self:refreshTv()
		end
	end
end

function armorMatrixShopDialog:dispose()
	spriteController:removePlist("public/yellowFlicker.plist")
    spriteController:removeTexture("public/yellowFlicker.png")
end


