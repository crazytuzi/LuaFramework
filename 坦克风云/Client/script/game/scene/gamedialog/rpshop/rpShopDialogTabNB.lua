rpShopDialogTabNB={}
function rpShopDialogTabNB:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.data=nil
	self.limitTb={}
	self.buyItemTb={}
	self.cellHeght=210
	self.tagOffset=518
	self.countdown=nil
	return nc
end

function rpShopDialogTabNB:init(layerNum,parent)
	local function callback()
		self:initWithData(rpShopVoApi:getNbItemList())
		self:initTableView()
	end
	self.layerNum=layerNum
	self.parent=parent
	self.bgLayer=CCLayer:create()
	rpShopVoApi:refresh(callback)
	return self.bgLayer
end

function rpShopDialogTabNB:initWithData(data)
	self.data={}
	self.limitTb={}
	self.buyItemTb={}
	self.buyLbTb={}
	if(data==nil)then
		return
	end
	local length=#data
	for i=1,length do
		local vo=data[i]
		local cellData={}
		cellData.id=vo.id
		cellData.rewardTb=FormatItem(vo.cfg.reward)
		cellData.rank=vo.cfg.rank
		cellData.price=vo.cfg.price
		cellData.maxTime=vo.cfg.buynum
		cellData.curTime=vo.buyNum
		cellData.gemprice=vo.cfg.gemprice
		table.insert(self.data,cellData)
	end
end

function rpShopDialogTabNB:initTableView()
	local function callBack(...)
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 60,G_VisibleSizeHeight - 510),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
	self.tv:setAnchorPoint(ccp(0,0))
	self.tv:setPosition(ccp(30,100))
	self.tv:setMaxDisToBottomOrTop(120)
	self.bgLayer:addChild(self.tv)
end

function rpShopDialogTabNB:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return #self.data
	elseif fn=="tableCellSizeForIndex" then
		if G_getCurChoseLanguage() == "in" or G_getCurChoseLanguage() =="en" or G_getCurChoseLanguage() =="thai" or G_getCurChoseLanguage() =="de" then
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
		self.limitTb[cellData.id]=limitLb

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
			icon:setPosition(ccp(10,self.cellHeght/2-15))
			backSprie:addChild(icon)
		end

		local descLb=GetTTFLabelWrap(getlocal(cellData.rewardTb[1].desc),22,CCSizeMake(G_VisibleSizeWidth-335,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		descLb:setAnchorPoint(ccp(0,1))
		descLb:setPosition(ccp(130,self.cellHeght/2+40-10))
		backSprie:addChild(descLb)

		local canBuyLb=GetTTFLabel(getlocal("activity_vipRight_can_buy",{math.max(rpShopVoApi:getPersonalMaxBuy(cellData.id) - rpShopVoApi:getPersonalBuy(cellData.id),0)}),25)
		canBuyLb:setPosition(ccp(G_VisibleSizeWidth-160,self.cellHeght*3/4 + 20))
		backSprie:addChild(canBuyLb)
		self.buyLbTb[cellData.id]=canBuyLb

		-- 修改逻辑（增加可能消耗金币）
		local coinPrice=cellData.price or 0
		local gemPrice=cellData.gemprice or 0

		-- 军功币
		local coinIcon=CCSprite:createWithSpriteFrameName("rpCoin.png")
		backSprie:addChild(coinIcon)
		coinIcon:setScale(40/coinIcon:getContentSize().width)
		local coinLb=GetTTFLabel(FormatNumber(coinPrice),25)
		if(playerVoApi:getRpCoin()<coinPrice)then
			coinLb:setColor(G_ColorRed)
		else
			coinLb:setColor(G_ColorYellowPro)
		end
		coinLb:setAnchorPoint(ccp(0,0.5))
		backSprie:addChild(coinLb)

		local gemIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
		backSprie:addChild(gemIcon)
		local gemLb=GetTTFLabel(FormatNumber(gemPrice),25)
		if(playerVoApi:getGems()<gemPrice)then
			gemLb:setColor(G_ColorRed)
		else
			gemLb:setColor(G_ColorYellowPro)
		end
		gemLb:setAnchorPoint(ccp(0,0.5))
		backSprie:addChild(gemLb)

		local function onClick(tag,object)
			if(playerVoApi:getRpCoin()<cellData.price)then
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage14005"),30)
				do return end
			end
			if(playerVoApi:getGems()<cellData.gemprice)then
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("notEnoughGem"),30)
				do return end
			end
			if(tag)then
				local function realBuy()
					self:buyItem(tag-self.tagOffset)
				end
				if(gemPrice and tonumber(gemPrice)>0)then
					local key="rpShop_gem_buy"
					if G_isPopBoard(key) then
					    local function secondTipFunc(flag)
					        local sValue=base.serverTime .. "_" .. flag
					        G_changePopFlag(key,sValue)
					    end
					    G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("raids_buy_desc",{gemPrice,table.concat(nameStrTb, ", ")}),true,realBuy,secondTipFunc)
					else
					    realBuy()
					end
				else
					realBuy()
				end
			end
		end
		local btnStr
		if(cellData.curTime>=cellData.maxTime)then
			btnStr=getlocal("soldOut")
		else
			btnStr=getlocal("code_gift")
		end
		local btnScale=130/205
		local buyItem = GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",onClick,nil,btnStr,24/btnScale,518)
		buyItem:setTag(self.tagOffset+idx+1)
		buyItem:setScale(btnScale)
		if(cellData.curTime>=cellData.maxTime or rpShopVoApi:getPersonalBuy(cellData.id)>=rpShopVoApi:getPersonalMaxBuy(cellData.id))then
			buyItem:setEnabled(false)
		end
		self.buyItemTb[cellData.id]=buyItem
		local buyBtn = CCMenu:createWithItem(buyItem)
		buyBtn:setPosition(ccp(G_VisibleSizeWidth-135,self.cellHeght/4))
		buyBtn:setTouchPriority(-(self.layerNum-1)*20-2)
		backSprie:addChild(buyBtn)

		local btnX=G_VisibleSizeWidth-145
		local iconX=G_VisibleSizeWidth - 185
		local priceX=G_VisibleSizeWidth - 160

		if gemPrice==0 then
			coinIcon:setPosition(ccp(iconX,self.cellHeght/2 + 20))
			coinLb:setPosition(ccp(priceX,self.cellHeght/2 + 20))
			gemIcon:setVisible(false)
			gemLb:setVisible(false)
			buyBtn:setPosition(ccp(btnX,self.cellHeght/4+10))

		elseif coinPrice==0 then
			gemIcon:setPosition(ccp(iconX,self.cellHeght/2 + 20))
			gemLb:setPosition(ccp(priceX,self.cellHeght/2 + 20))
			coinIcon:setVisible(false)
			coinLb:setVisible(false)
			buyBtn:setPosition(ccp(btnX,self.cellHeght/4+10))
		else
			coinIcon:setPosition(ccp(iconX,self.cellHeght/2-5))
			coinLb:setPosition(ccp(priceX,self.cellHeght/2-5))
			gemIcon:setPosition(ccp(iconX,self.cellHeght/2 + 10+25))
			gemLb:setPosition(ccp(priceX,self.cellHeght/2 + 10+25))
			buyBtn:setPosition(ccp(btnX,self.cellHeght/4-5))
		end

		local selfRank=playerVoApi:getRank()
		if(selfRank<cellData.rank)then
			local mask = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
			mask:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,self.cellHeght))
			mask:setOpacity(200)
			mask:setPosition(ccp((G_VisibleSizeWidth-60)/2,self.cellHeght/2))
			mask:setTouchPriority(-(self.layerNum-1)*20-3)
			cell:addChild(mask,2)
			local unlockIcon=CCSprite:createWithSpriteFrameName(playerVoApi:getRankIconName(cellData.rank))
			unlockIcon:setPosition(ccp(120,self.cellHeght/2))
			cell:addChild(unlockIcon,3)
			local unlockDesc=GetTTFLabelWrap(getlocal("rpshop_rankLimit",{getlocal("military_rank_"..cellData.rank)}),28,CCSizeMake(G_VisibleSizeWidth-260,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			unlockDesc:setColor(G_ColorRed)
			unlockDesc:setPosition(ccp((G_VisibleSizeWidth-60)/2+40,self.cellHeght/2))
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

function rpShopDialogTabNB:refresh(itemVo)
	if(itemVo)then
		if(itemVo.type=="a")then
			for k,v in pairs(self.data) do
				if(v.id==itemVo.id)then
					v.curTime=itemVo.buyNum
					self.limitTb[v.id]:setString("("..v.curTime.."/"..v.maxTime..")")
					if(v.curTime>=v.maxTime)then
						local buyItem=self.buyItemTb[v.id]
						local lb=tolua.cast(buyItem:getChildByTag(518),"CCLabelTTF")
						lb:setString(getlocal("soldOut"))
						buyItem:setEnabled(false)
					end
					break
				end
			end
		end
	else
		self:initWithData(rpShopVoApi:getNbItemList())
		local recordPoint=self.tv:getRecordPoint()
		self.tv:reloadData()
		self.tv:recoverToRecordPoint(recordPoint)
	end
end

function rpShopDialogTabNB:buyItem(index)
	local cellData=self.data[index]
	if(cellData.curTime<cellData.maxTime and rpShopVoApi:getPersonalBuy(cellData.id)<rpShopVoApi:getPersonalMaxBuy(cellData.id))then
		local function callback()
			local canBuyLb=tolua.cast(self.buyLbTb[cellData.id],"CCLabelTTF")
			canBuyLb:setString(getlocal("activity_vipRight_can_buy",{rpShopVoApi:getPersonalMaxBuy(cellData.id) - rpShopVoApi:getPersonalBuy(cellData.id)}))
			self.parent.rpOwnLb:setString(getlocal("propOwned").." "..FormatNumber(playerVoApi:getRpCoin()))
			self:refresh()
		end
		rpShopVoApi:buyItem(cellData.id,callback)
	end
end

function rpShopDialogTabNB:dispose()
	self.data=nil
	self.limitTb=nil
	self.buyItemTb=nil
end