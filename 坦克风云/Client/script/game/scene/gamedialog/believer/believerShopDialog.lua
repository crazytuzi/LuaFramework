local believerShopDialog=commonDialog:new()

function believerShopDialog:new(parent)
	local nc={
		parent=parent,
	}
	setmetatable(nc,self)
	self.__index=self
	nc.parent   = parent
	nc.layerNum = layerNum
	nc.shopInfoTb = {}
	return nc
end

function believerShopDialog:dispose()
	self.shopInfoTb = nil
    self.layerNum   = nil
    if self.parent and self.parent.backToMainDialogHandler then
        self.parent:backToMainDialogHandler()
        self.parent=nil
    end
end

function believerShopDialog:doUserHandler()
	self.panelLineBg:setVisible(false)
	self.panelTopLine:setVisible(true)
	self.panelTopLine:setPositionY(self.panelTopLine:getPositionY() + 70)
	self.tvWidth = G_VisibleSizeWidth - 20
	local bottomBg = LuaCCScale9Sprite:createWithSpriteFrameName("newUnReadBg.png",CCRect(5,23,1,1),function () end)
    bottomBg:setContentSize(CCSizeMake(self.tvWidth ,70))
    bottomBg:setTouchPriority(-(self.layerNum-1)*20-4)
    bottomBg:setAnchorPoint(ccp(0,0))
    self.bgLayer:addChild(bottomBg)
    bottomBg:setPosition(ccp(10,15))
    local bgHeight = bottomBg:getContentSize().height

    local kcointipStr = GetTTFLabelWrap(getlocal("believer_shop_kTip"),24,CCSizeMake(self.tvWidth * 0.6,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    kcointipStr:setAnchorPoint(ccp(0,0.5))
    kcointipStr:setPosition(ccp(self.tvWidth * 0.1,bgHeight*0.5))
    kcointipStr:setColor(G_ColorOrange)
    bottomBg:addChild(kcointipStr)

    local kCoinSp = CCSprite:createWithSpriteFrameName("believerKcoin.png")
    kCoinSp:setPosition(ccp(self.tvWidth * 0.75,bgHeight*0.5))
    local scaleNum = bgHeight*0.5/kCoinSp:getContentSize().width
    kCoinSp:setScale(scaleNum)
    bottomBg:addChild(kCoinSp)
    local kCoinSpWidth = kCoinSp:getContentSize().width * scaleNum

    local kcoinStr = GetTTFLabel(believerVoApi:getCurKcoin(),22)
    kcoinStr:setAnchorPoint(ccp(0,0.5))
    kcoinStr:setPosition(ccp(kCoinSp:getPositionX() + kCoinSpWidth,bgHeight * 0.5))
    self.kcoinStr = kcoinStr
    bottomBg:addChild(kcoinStr)

    if self.tvWidth * 0.25 < kCoinSpWidth + kcoinStr:getContentSize().width then
    	local addWidth = kCoinSpWidth + kcoinStr:getContentSize().width - self.tvWidth * 25
    	kCoinSp:setPositionX(kCoinSp:getPositionX() + addWidth)
    	kcoinStr:setPositionX(kcoinStr:getPositionX() + addWidth)
    end
end
function believerShopDialog:initTableView()
	self.shopInfoTb = believerVoApi:returnFormatShopInfo()

	local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
    tvBg:setPosition(ccp(10,90))
    tvBg:setContentSize(CCSizeMake(self.tvWidth,G_VisibleSizeHeight - 180))
    tvBg:setAnchorPoint(ccp(0,0))
    self.tvBg = tvBg
    self.bgLayer:addChild(tvBg)

    self.cellHeight = 170
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,G_VisibleSizeHeight - 182),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
    self.tv:setPosition(ccp(0,0))
    self.tvBg:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
end

function believerShopDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
			-- print("SizeOfTable(self.shopInfoTb)========>>>>>",SizeOfTable(self.shopInfoTb))
            return SizeOfTable(self.shopInfoTb)
    elseif fn=="tableCellSizeForIndex" then
        return CCSizeMake(self.tvWidth,self.cellHeight)
    elseif fn=="tableCellAtIndex" then

        local cell=CCTableViewCell:new()
        cell:autorelease()

        local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function ()end)
        lineSp:setContentSize(CCSizeMake(self.tvWidth-20,lineSp:getContentSize().height))
        lineSp:setPosition(ccp(self.tvWidth*0.5,0))
        cell:addChild(lineSp)

        local curShopTb = self.shopInfoTb[idx+1]
        local rewardTb=FormatItem(curShopTb[4])
        local reward=rewardTb[1]
        local function showNewPropInfo()
            G_showNewPropInfo(self.layerNum+1,true,true,nil,reward,nil,nil,nil,nil,true)
            return false
        end
        local icon,scale=G_getItemIcon(reward,100,true,self.layerNum,showNewPropInfo)
        icon:setAnchorPoint(ccp(0,0))
        icon:setPosition(ccp(20,45))
        icon:setTouchPriority(-(self.layerNum-1)*20-2)
        cell:addChild(icon)
        local middlePosx = icon:getPositionX() + icon:getContentSize().width*scale + 10

        -- print("curShopTb[7]-----curShopTb[3]------>>>>",curShopTb[7],curShopTb[3])
        if curShopTb[3] > 0 then
	        local shopNumStr = GetTTFLabel("("..curShopTb[7].."/"..curShopTb[3]..")",24)
	        shopNumStr:setPosition(ccp(icon:getPositionX() + icon:getContentSize().width*0.5*scale,25))
	        cell:addChild(shopNumStr)
	        if curShopTb[7] >= curShopTb[3] then
	        	shopNumStr:setColor(G_ColorRed)
	        end
	    end

        local shopNameStr = GetTTFLabel(reward.name.."x"..FormatNumber(reward.num),24)
        shopNameStr:setAnchorPoint(ccp(0,1))
        shopNameStr:setPosition(ccp(middlePosx,icon:getPositionY() +  icon:getContentSize().height*scale))
        shopNameStr:setColor(G_ColorGreen)
        cell:addChild(shopNameStr)

        local shopDesc = GetTTFLabelWrap(getlocal(reward.desc),23,CCSizeMake(self.tvWidth*0.54,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        shopDesc:setAnchorPoint(ccp(0,1))
        shopDesc:setPosition(ccp(middlePosx,shopNameStr:getPositionY() - 35))
        cell:addChild(shopDesc)

        local function buyFunc()
        	if G_checkClickEnable()==false then
	            do return end
	        else
	            base.setWaitTime=G_getCurDeviceMillTime()
	        end
	        PlayEffect(audioCfg.mouseClick)
            local function realBuy()
                self:buyPropCall(idx+1,curShopTb[6],curShopTb[9])  
            end
	        -- print("buyFunc~~~~~~~~ idx + 1 ======>>>>>>",idx + 1)
            local key="believer_shop_buy"
            local function secondTipFunc(flag)
                local sValue=base.serverTime .. "_" .. flag
                G_changePopFlag(key,sValue) 
            end
            if G_isPopBoard(key) then
                G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("ladder_shopBuy",{curShopTb[2]..getlocal("believer_kcoin"),reward.name}),true,realBuy,secondTipFunc)
            else
                realBuy()
            end
        end
        local buyItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",buyFunc)
        local buyItemScale = 0.7
        buyItem:setScale(buyItemScale)
        local buyBtn=CCMenu:createWithItem(buyItem);
        buyBtn:setTouchPriority(-(self.layerNum-1)*20-2);
        buyBtn:setPosition(ccp(self.tvWidth * 0.85,40))
        cell:addChild(buyBtn)

        local kCoinSp = CCSprite:createWithSpriteFrameName("believerKcoin.png")
        kCoinSp:setScale(0.6)
        kCoinSp:setPosition(ccp(buyItem:getContentSize().width*0.3,buyItem:getContentSize().height*0.5))
        buyItem:addChild(kCoinSp)
        local kCoinLb = GetTTFLabel(curShopTb[2],28)
        kCoinLb:setAnchorPoint(ccp(0,0.5))
        kCoinLb:setPosition(getCenterPoint(buyItem))
        buyItem:addChild(kCoinLb)

        if curShopTb[8] > 0 then
        	buyItem:setEnabled(false)
        	kCoinLb:setColor(G_ColorRed)
        end
        if curShopTb[8] == 3 then
        	local needWidth = 120
        	local segSp,segSpScale = believerVoApi:getSegmentIcon(curShopTb[6],curShopTb[1],needWidth)
        	segSp:setAnchorPoint(ccp(1,0))
		    segSp:setPosition(ccp(buyItem:getContentSize().width,buyItem:getContentSize().height + 15))
		    buyItem:addChild(segSp)

		    local unClocklb = GetTTFLabel(getlocal("activity_fbReward_unlock").."：",28)
		    unClocklb:setAnchorPoint(ccp(1,0.5))
		    unClocklb:setColor(G_ColorRed)
		    unClocklb:setPosition(ccp(needWidth-20,buyItem:getContentSize().height + 60))
		    buyItem:addChild(unClocklb)
        end
        return cell
    end
end

function believerShopDialog:buyPropCall(itemIdx,itemGrade,itemSeg)
	local function buyItemEndCall()
        local curShopTb=self.shopInfoTb[itemIdx]
        local rewardTb=FormatItem(curShopTb[4])
        for k,v in pairs(rewardTb) do
            G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
        end
        G_showRewardTip(rewardTb)
        self:refreshSelfData()
	end 
	believerVoApi:buyPropInShop(buyItemEndCall,itemIdx,itemGrade,itemSeg)
end
function believerShopDialog:refreshSelfData()
	self.shopInfoTb = believerVoApi:returnFormatShopInfo()
	if self.kcoinStr then
		self.kcoinStr:setString(believerVoApi:getCurKcoin())
	end
	if self.tv then
		local recordPoint=self.tv:getRecordPoint()
		self.tv:reloadData()
		self.tv:recoverToRecordPoint(recordPoint)
	end
end

return believerShopDialog