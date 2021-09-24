ladderShopDialog = commonDialog:new()

function ladderShopDialog:new(closeCallback)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.normalHeight=180
    self.closeCallback=closeCallback
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage2.plist")
    -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
    return nc
end

function ladderShopDialog:resetTab()
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height/2-36))

end

function ladderShopDialog:initTableView()
	self.pShopItems=skyladderCfg.pShopItems
	local function callBack(...)
    	return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-100-200-35),nil)
 	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(10,40))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(120)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function ladderShopDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return SizeOfTable(self.pShopItems) or 0
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-20,self.normalHeight)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local cellWidth=self.bgLayer:getContentSize().width-20
        local cellHeight=120

	    local rect = CCRect(0, 0, 50, 50)
        local capInSet = CCRect(20, 20, 10, 10)
        local function cellClick(hd,fn,idx)
        end
        local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)

	    backSprie:setContentSize(CCSizeMake(cellWidth-10, self.normalHeight))
        backSprie:ignoreAnchorPointForPosition(false)
        backSprie:setAnchorPoint(ccp(0.5,0))
        backSprie:setIsSallow(false)
        backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		    backSprie:setPosition(ccp((self.bgLayer:getContentSize().width-20)/2,0))
        cell:addChild(backSprie,1)

        local tId = "i" .. idx+1
        local reward = self.pShopItems[tId].reward
        local price = self.pShopItems[tId].price

        local item = FormatItem(reward)


        local propIcon=""
        local namestr=""
        local descStr=""
        local propSp=""
        local hid=""

        namestr=item[1].name
        descStr=getlocal(item[1].desc)
        
        propSp=G_getItemIcon(item[1],100,nil,self.layerNum+1)
        propSp:setAnchorPoint(ccp(0,0.5))
        propSp:setPosition(ccp(10,backSprie:getContentSize().height/2))
        backSprie:addChild(propSp,1)

        local needWidh = 0
        local lbSortHeight = 50
        local neddHeight = 0
        if G_getCurChoseLanguage() =="de" or G_getCurChoseLanguage() == "en" or G_getCurChoseLanguage() =="in" or G_getCurChoseLanguage() =="thai" then
          needWidh =180
          lbSortHeight =80
          neddHeight =80
        end
        local lbName=GetTTFLabelWrap(namestr,26,CCSizeMake(26*12+needWidh,neddHeight),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        lbName:setPosition(150,backSprie:getContentSize().height-20)
        lbName:setAnchorPoint(ccp(0,1));
        backSprie:addChild(lbName,2)
        lbName:setColor(G_ColorYellowPro)

        local propNumLb=GetTTFLabel("x"..item[1].num,20)
        propNumLb:setAnchorPoint(ccp(1,0))
        propNumLb:setPosition(ccp(propSp:getContentSize().width-15,10))
        propSp:addChild(propNumLb)
        
           
        local labelSize = CCSize(270, 0);
        local lbDescription=GetTTFLabelWrap(descStr,22,labelSize, kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        lbDescription:setPosition(150,backSprie:getContentSize().height-lbSortHeight)
        lbDescription:setAnchorPoint(ccp(0,1));
        backSprie:addChild(lbDescription,2)

        -- local scale = 40/80
		local bgSp =LuaCCScale9Sprite:createWithSpriteFrameName("smallGreen2QuadrateBg.png",CCRect(20, 20, 1, 1),function () do return end end)
		bgSp:setContentSize(CCSizeMake(80, 40))
		bgSp:setAnchorPoint(ccp(1,0.5));
		bgSp:setIsSallow(false)
		bgSp:setTouchPriority(-(self.layerNum-1)*20-1)
		bgSp:setPosition(backSprie:getContentSize().width-35, backSprie:getContentSize().height/4*3-30)
		-- bgSp:setScaleY(scale)
		backSprie:addChild(bgSp)

		local pointSp = CCSprite:createWithSpriteFrameName("ladder_point_icon.png")
		pointSp:setScale(0.5)
		pointSp:setAnchorPoint(ccp(0,0.5))
		pointSp:setPosition(ccp(-50,bgSp:getContentSize().height/2))
		bgSp:addChild(pointSp,6)

		local num = price
		local numLb = GetTTFLabel(num,25)
		numLb:setAnchorPoint(ccp(0.5,0.5))
		numLb:setPosition(ccp(bgSp:getContentSize().width/2,bgSp:getContentSize().height/2))
		-- numLb:setScaleY(1/scale)
		bgSp:addChild(numLb)


        local function exchange()
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
			    if G_checkClickEnable()==false then
			        do
			            return
			        end
			    else
			        base.setWaitTime=G_getCurDeviceMillTime()
			    end

			    if self.num<price then
			    	smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("backstage1996"),nil,self.layerNum+1)
			    	return
			    end
				local function buycallback()
	                local function callback(fn,data)
	                    local ret,sData=base:checkServerData(data)
	                    if ret==true then
	                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("expeditionBuySuccess",{namestr}),30)
	                        if(item[1].type=="e")then
	                        	if(item[1].eType=="p")then
	                        		local props={}
	                        		props[item[1].key]=item[1].num
		                        	accessoryVoApi:addNewData({props=props})
		                        elseif(item[1].eType=="f")then
	                        		local fData={}
	                        		fData[item[1].key]=item[1].num
		                        	accessoryVoApi:addNewData({fragment=fData})
		                        end
	                        end
	                        self:refresh()
	                    end
	                end
	                socketHelper:useLadderTicket(tId,callback)
		        end

				-- smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buycallback,getlocal("dialog_title_prompt"),getlocal("ladder_shopBuy",{num  .. self.name,namestr}),nil,self.layerNum+1)
                local saveLocalKey = "keyLadderShop"
                local function secondTipFunc(sbFlag)
                    local sValue=base.serverTime .. "_" .. sbFlag
                    G_changePopFlag(saveLocalKey,sValue)
                end
                if G_isPopBoard(saveLocalKey) then
                    G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("ladder_shopBuy",{num  .. self.name,namestr}),true,buycallback,secondTipFunc)
                else
                    buycallback()
                end
			end
        end
        local exchangeItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",exchange,nil,getlocal("code_gift"),25)
        local exchangeBtn=CCMenu:createWithItem(exchangeItem)
        exchangeBtn:setTouchPriority(-(self.layerNum-1)*20-2)
        exchangeItem:setAnchorPoint(ccp(1,0))
        exchangeItem:setScale(0.8)
        exchangeBtn:setPosition(ccp(backSprie:getContentSize().width-20,10))
        backSprie:addChild(exchangeBtn,1)

		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end

function ladderShopDialog:doUserHandler()
	local backSprie1=LuaCCScale9Sprite:createWithSpriteFrameName("TrialSquadBox.png",CCRect(28, 30, 1, 1),function () do return end end)
	backSprie1:setContentSize(CCSizeMake(614,200))
	backSprie1:setAnchorPoint(ccp(0.5,1))
	backSprie1:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-95)
	self.bgLayer:addChild(backSprie1)

	local propKey = skyladderCfg.buyitem
	local name,pic,desc=getItem(propKey,"p")
	local id = tonumber(propKey) or tonumber(RemoveFirstChar(propKey))
	local num = bagVoApi:getItemNumId(id)
	self.name=name
	self.num = num
	self.id = id
	local iconbg = propCfg[propKey].iconbg
	local iconSp = GetBgIcon(pic,nil,iconbg,90,100)
	-- local iconSp = CCSprite:createWithSpriteFrameName(pic)
	iconSp:setScale(130/iconSp:getContentSize().width)
	iconSp:setAnchorPoint(ccp(0,0.5))
	iconSp:setPosition(ccp(35,backSprie1:getContentSize().height/2+20))
	backSprie1:addChild(iconSp,2)

	-- local scale = 40/80
	local bgSp =LuaCCScale9Sprite:createWithSpriteFrameName("smallGreen2QuadrateBg.png",CCRect(20, 20, 1, 1),function () do return end end)
	bgSp:setContentSize(CCSizeMake(100, 40))
	bgSp:setAnchorPoint(ccp(0.5,0));
	bgSp:setIsSallow(false)
	bgSp:setTouchPriority(-(self.layerNum-1)*20-2)
	bgSp:setPosition(100, 10)
	-- bgSp:setScaleY(scale)
	backSprie1:addChild(bgSp)

	local num = num
	local numLb = GetTTFLabel(num,25)
    numLb:setAnchorPoint(ccp(0.5,0.5))
    numLb:setPosition(ccp(bgSp:getContentSize().width/2,bgSp:getContentSize().height/2))
    -- numLb:setScaleY(1/scale)
    bgSp:addChild(numLb)
    self.numLb=numLb

    local nameLb = GetTTFLabelWrap(name,30,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	backSprie1:addChild(nameLb)
	nameLb:setAnchorPoint(ccp(0,0.5))
	nameLb:setPosition(200, backSprie1:getContentSize().height/4*3)
	nameLb:setColor(G_ColorYellowPro)

	
	local upLb = getlocal("ladder_shop_desc_962")
	local desTv, desLabel = G_LabelTableView(CCSizeMake(350, 100),upLb,25,kCCTextAlignmentLeft)
    desTv:setPosition(ccp(200,10))
    desTv:setAnchorPoint(ccp(0,1))
	desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	desTv:setMaxDisToBottomOrTop(130)
    backSprie1:addChild(desTv)

 
    
end

function ladderShopDialog:refresh()
	self.numLb:setString(bagVoApi:getItemNumId(self.id))
end

function ladderShopDialog:tick()
end

function ladderShopDialog:dispose()
	if self and self.closeCallback then
		self.closeCallback()
	end
	self.numLb=nil
	self.refreshTimeLb=nil
	self.name=nil
	self.num=nil
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
end