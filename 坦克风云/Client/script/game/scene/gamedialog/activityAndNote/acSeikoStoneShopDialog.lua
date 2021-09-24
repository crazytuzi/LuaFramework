acSeikoStoneShopDialog = commonDialog:new()

function acSeikoStoneShopDialog:new(closeCallback)
    local nc={}
    nc.normalHeight=180
   	acSeikoStoneShopVoApi:initShopList()
    nc.pShopItems=acSeikoStoneShopVoApi:getShopList()
    nc.costPropName=""
    nc.costId=0
    nc.costPropPic=""
    nc.numLb=nil
    nc.num=0

    setmetatable(nc,self)
    self.__index=self
    return nc
end

function acSeikoStoneShopDialog:resetTab()
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight-100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height/2-36))
end

function acSeikoStoneShopDialog:initTableView()
    spriteController:addTexture("public/acSeikoShopTitleBg.jpg")

    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        self.normalHeight=160
    end
	local function callBack(...)
    	return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-80-90-190),nil)
 	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(10,80))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(120)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acSeikoStoneShopDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return SizeOfTable(self.pShopItems) or 0
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-20,self.normalHeight)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

        local propItem=self.pShopItems[idx+1]
		local cellWidth=self.bgLayer:getContentSize().width-20
        local cellHeight=120

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

        local reward=propItem.reward
        local propSp=G_getItemIcon(reward,100,nil,self.layerNum+1)
        propSp:setAnchorPoint(ccp(0,0.5))
        backSprie:addChild(propSp,1)
        local propSpWidth=propSp:getContentSize().width*propSp:getScaleX()
        local propSpHeight=propSp:getContentSize().height*propSp:getScaleY()

        local numLabel = GetTTFLabel("x"..reward.num,25)
        numLabel:setAnchorPoint(ccp(1,0))
        numLabel:setPosition(ccp(propSpWidth-5,5))
        numLabel:setScale(1/propSp:getScale())
        propSp:addChild(numLabel,1)

		local countLb = GetTTFLabel(propItem.curCount.."/"..propItem.maxCount,25)
        countLb:setAnchorPoint(ccp(0.5,1))
		countLb:setPosition(ccp(propSpWidth/2,0))
		propSp:addChild(countLb)
		if propItem.maxCount-propItem.curCount<=0 then
			countLb:setColor(G_ColorRed)
		else
			countLb:setColor(G_ColorYellow)
		end
        propSp:setPosition(ccp(15,backSprie:getContentSize().height/2+countLb:getContentSize().height/2))
        local needWidh = 0
        local lbSortHeight = 50
        local neddHeight = 0
        if G_getCurChoseLanguage() =="de" or G_getCurChoseLanguage() == "en" or G_getCurChoseLanguage() =="in" or G_getCurChoseLanguage() =="thai" then
          needWidh =60
          lbSortHeight =80
          neddHeight =80
        end
        local lbName=GetTTFLabelWrap(reward.name,26,CCSizeMake(26*12+needWidh,neddHeight),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        lbName:setPosition(15+propSpWidth+10,backSprie:getContentSize().height-15)
        lbName:setAnchorPoint(ccp(0,1))
        backSprie:addChild(lbName,2)
        lbName:setColor(G_ColorYellowPro)
                
        local labelSize = CCSize(330, 0)
        local lbDescription=GetTTFLabelWrap(getlocal(reward.desc),22,labelSize, kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        lbDescription:setPosition(15+propSpWidth+10,backSprie:getContentSize().height-lbSortHeight)
        lbDescription:setAnchorPoint(ccp(0,1))
        backSprie:addChild(lbDescription,2)

        local function exchange()
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
			    if G_checkClickEnable()==false then
			        do
			            return
			        end
			    else
			        base.setWaitTime=G_getCurDeviceMillTime()
			    end

			    if self.num<propItem.price then
			    	smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("backstage1996"),nil,self.layerNum+1)
			    	return
			    end
				local function buycallback()
	                local function callback(fn,data)
	                    local ret,sData=base:checkServerData(data)
	                    if ret==true then
	                    	if sData.data then
	                    		if sData.data.seikoStoneShop then
			                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("expeditionBuySuccess",{reward.name}),30)
	                        		acSeikoStoneShopVoApi:updateData(sData.data.seikoStoneShop)
	                        		self:refresh()
                    				self.tv:reloadData()
			                        -- G_addPlayerAward(reward.type,reward.key,reward.id,reward.num,false,true)
	                        		-- bagVoApi:useItemNumId(self.costId,propItem.price)
                    			end
	                    	end	                        
	                    end
	                end
	                socketHelper:seikoStoneShopBuy(propItem.itemId,callback)
		        end

				smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buycallback,getlocal("dialog_title_prompt"),getlocal("equip_shopBuy",{propItem.price..self.costPropName,reward.name}),nil,self.layerNum+1)
			end
        end
        local exchangeItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",exchange,nil,getlocal("code_gift"),25)
        local exchangeBtn=CCMenu:createWithItem(exchangeItem)
        exchangeBtn:setTouchPriority(-(self.layerNum-1)*20-2)
        exchangeItem:setAnchorPoint(ccp(1,0))
        exchangeItem:setScale(0.8)
        exchangeBtn:setPosition(ccp(backSprie:getContentSize().width-15,propSp:getPositionY()-propSpHeight/2-countLb:getContentSize().height/2))
        backSprie:addChild(exchangeBtn,1)

        if (propItem.maxCount-propItem.curCount<=0) or (self.num<propItem.price) then
        	exchangeItem:setEnabled(false)
        else
        	exchangeItem:setEnabled(true)
        end

		if self.costPropPic~="" then
			local pointSp = CCSprite:createWithSpriteFrameName(self.costPropPic)
			pointSp:setScale(0.7*1/exchangeItem:getScale())
			pointSp:setAnchorPoint(ccp(0,0.5))
			pointSp:setPosition(ccp(5,exchangeItem:getContentSize().height+pointSp:getContentSize().height*pointSp:getScaleY()/2+5))
			exchangeItem:addChild(pointSp,6)

			local numLb = GetTTFLabel(propItem.price,25)
			numLb:setAnchorPoint(ccp(0,0.5))
			numLb:setScale(1/exchangeItem:getScale())
			numLb:setPosition(ccp(pointSp:getPositionX()+pointSp:getContentSize().width*pointSp:getScaleX()-5,pointSp:getPositionY()))
			exchangeItem:addChild(numLb)
			if self.num<propItem.price then
				numLb:setColor(G_ColorRed)
			else
				numLb:setColor(G_ColorYellowPro)
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

function acSeikoStoneShopDialog:doUserHandler()
	local propKey=acSeikoStoneShopVoApi:getBuyItem()
	if propKey==nil then
		self.num=0
		return
	end
    local strSize2 = 22
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" then
      strSize2 =28
    elseif G_getCurChoseLanguage() =="de" and G_isIOS() ==false then
        strSize2 =19
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)

    -- local titleKuang = LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),function (...)end)
    -- titleKuang:setContentSize(CCSizeMake(610,186))
    -- titleKuang:setAnchorPoint(ccp(0.5,1))
    -- titleKuang:setTouchPriority(-(self.layerNum-1)*20-2)
    -- titleKuang:setPosition(ccp(G_VisibleSize.width/2,G_VisibleSize.height - 85))
    -- self.bgLayer:addChild(titleKuang,2)

    local titleBg = CCSprite:create("public/acSeikoShopTitleBg.jpg")
    titleBg:setAnchorPoint(ccp(0.5,1))
    titleBg:setPosition(ccp(G_VisibleSize.width/2,G_VisibleSize.height-90))
    self.bgLayer:addChild(titleBg,1)

    -- local blackBg = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 20, 10, 10),function () end)
    -- blackBg:setContentSize(CCSizeMake(titleBg:getContentSize().width,titleBg:getContentSize().height+4))
    -- blackBg:setAnchorPoint(ccp(0.5,0.5))
    -- blackBg:setOpacity(0)
    -- blackBg:setPosition(ccp(titleBg:getContentSize().width/2,titleBg:getContentSize().height/2))
    -- titleBg:addChild(blackBg)
    
    local timeTitle = GetTTFLabel(getlocal("activity_timeLabel"),25)
    timeTitle:setAnchorPoint(ccp(0.5,1))
    timeTitle:setColor(G_ColorGreen)
    timeTitle:setPosition(ccp(titleBg:getContentSize().width/2,titleBg:getContentSize().height-10))
    titleBg:addChild(timeTitle)

    local timeStr = acSeikoStoneShopVoApi:getTimeStr()
    local timeStrLabel = GetTTFLabel(timeStr,25)
    timeStrLabel:setAnchorPoint(ccp(0.5,1))
    timeStrLabel:setPosition(ccp(titleBg:getContentSize().width/2,titleBg:getContentSize().height-50))
    titleBg:addChild(timeStrLabel)
    self.timeLb=timeStrLabel
    self:updateAcTime()


    local contentLabel = GetTTFLabelWrap(getlocal("activity_seikostone_shop_tip"),strSize2,CCSizeMake(G_VisibleSizeWidth-200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    contentLabel:setAnchorPoint(ccp(0.5,0))
    contentLabel:setPosition(ccp(titleBg:getContentSize().width/2,15))
    contentLabel:setColor(ccc3(255,222,0))
    titleBg:addChild(contentLabel)

    local function onTouchInfo()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:showAcInfo()
    end

    local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",onTouchInfo,11,nil,nil)
    infoItem:setScale(0.8) 
    local infoBtn = CCMenu:createWithItem(infoItem)
    infoBtn:setPosition(ccp(titleBg:getContentSize().width - infoItem:getContentSize().width/2 - 10,titleBg:getContentSize().height/2))
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    titleBg:addChild(infoBtn)

	local id=tonumber(propKey) or tonumber(RemoveFirstChar(propKey))
	local name,pic,desc=getItem(propKey,"p")
    self.costPropName=name
	self.costPropPic=pic
	self.num=bagVoApi:getItemNumId(id)
	self.costId=id

	local width=G_VisibleSizeWidth-50
	local height=50

	--点击添加按钮则跳转至装备研究所页面抽奖获得
	local function addCallBack()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

		G_goToDialog("hy",self.layerNum,true)
	end
  	local addItem=GetButtonItem("moreBtn.png","moreBtn.png","moreBtn.png",addCallBack)
    local addBtn=CCMenu:createWithItem(addItem)
    addBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    -- addItem:setScale(0.8)
    addBtn:setPosition(ccp(width,height))
    self.bgLayer:addChild(addBtn,1)
    width=width-40

	local numBg =LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray2.png",CCRect(20, 20, 1, 1),function () do return end end)
	numBg:setContentSize(CCSizeMake(100, 40))
	numBg:setAnchorPoint(ccp(1,0.5))
	numBg:setIsSallow(false)
	numBg:setTouchPriority(-(self.layerNum-1)*20-1)
	numBg:setPosition(ccp(width,height))
	self.bgLayer:addChild(numBg,1)
    width=width-numBg:getContentSize().width

	local numLb = GetTTFLabel(FormatNumber(self.num),25)
    numLb:setAnchorPoint(ccp(1,0.5))
    numLb:setPosition(ccp(numBg:getContentSize().width-10,numBg:getContentSize().height/2))
    numBg:addChild(numLb)
    self.numLb=numLb

	local iconSp = CCSprite:createWithSpriteFrameName(pic)
	iconSp:setScale(130/iconSp:getContentSize().width)
	iconSp:setAnchorPoint(ccp(1,0.5))
	iconSp:setPosition(ccp(width,height))
	iconSp:setScale(0.8)
	self.bgLayer:addChild(iconSp)
	width=width-iconSp:getContentSize().width*iconSp:getScaleX()

	local promptLb = GetTTFLabel(getlocal("resourceOwned"),25)
    promptLb:setAnchorPoint(ccp(1,0.5))
    promptLb:setPosition(ccp(width,height))
    promptLb:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(promptLb)

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
end

function acSeikoStoneShopDialog:showAcInfo()
    local tabStr = {getlocal("activity_seikostone_shop_rule3"),"\n",getlocal("activity_seikostone_shop_rule2"),"\n",getlocal("activity_seikostone_shop_rule1"),"\n"}
    local tabColor ={G_ColorRed,nil,nil,nil}
    local td=smallDialog:new()
    local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
    sceneGame:addChild(dialog,self.layerNum+1)
end

function acSeikoStoneShopDialog:refresh()
	self.num=bagVoApi:getItemNumId(self.costId)
    -- print("self.num ======== ",self.num)
	if self.numLb then
		self.numLb:setString(FormatNumber(self.num))
	end
end

function acSeikoStoneShopDialog:updateAcTime()
    local acVo=acSeikoStoneShopVoApi:getAcVo()
    if acVo and self.timeLb then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acSeikoStoneShopDialog:tick()
    if acSeikoStoneShopVoApi:isEnd()==true then
        self:close()
        do return end
    end
    self:updateAcTime()
end

function acSeikoStoneShopDialog:dispose()
    self.normalHeight=180
    self.pShopItems=nil
    self.costPropName=""
    self.costId=0
    self.costPropPic=""
    self.numLb=nil
    self.num=0
    self.timeLb=nil
    spriteController:removeTexture("public/acSeikoShopTitleBg.jpg")
end