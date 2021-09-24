acThreeYearSecond={}
function acThreeYearSecond:new()
	local nc={}
	setmetatable(nc,self)
	nc.vipLimit=0
	nc.myVip=0
	nc.goodsCount=0
	nc.shopList=nil
	nc.cellWidth=G_VisibleSizeWidth-50
	nc.cellHeight=0
	nc.itemHeight=160
	nc.refreshItem=nil
	nc.refreshNumLb=nil
	nc.isTodayFlag=true
	nc.numTb=nil
	nc.buyBtnTb=nil
	nc.smallD=nil
	nc.gemsSmallD=nil
	nc.space=20

	self.__index=self
	return nc
end

function acThreeYearSecond:init(layerNum,parent)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self.parent=parent

	self:initTableView()

	return self.bgLayer
end

function acThreeYearSecond:initTableView()
	self.myVip=playerVoApi:getVipLevel()
	self.shopList=acThreeYearVoApi:getShopList()
	if self.shopList then
		self.goodsCount=SizeOfTable(self.shopList)
	end
	self.cellWidth=G_VisibleSizeWidth-50
	local lineCount=math.ceil(self.goodsCount/2)
	self.cellHeight=lineCount*self.itemHeight+lineCount*self.space

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local viewBg=CCSprite:create("public/acWanshengjiedazuozhanBg2.jpg")
    viewBg:setAnchorPoint(ccp(0.5,1))
    viewBg:setScaleX((G_VisibleSizeWidth-50)/viewBg:getContentSize().width)
    viewBg:setScaleY((G_VisibleSizeHeight-190)/viewBg:getContentSize().height)
    viewBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160))
    self.bgLayer:addChild(viewBg)
    local fadeBg=CCSprite:createWithSpriteFrameName("redFadeLine.png")
    fadeBg:setAnchorPoint(ccp(0.5,1))
    fadeBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160))
    fadeBg:setScaleX((G_VisibleSizeWidth+150)/fadeBg:getContentSize().width)
    fadeBg:setScaleY((G_VisibleSizeHeight-190)/fadeBg:getContentSize().height)
    self.bgLayer:addChild(fadeBg,2)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

	self:initVipIconView()
	self:initShopView()
end

--初始化vip可领取三周年头像的view
function acThreeYearSecond:initVipIconView()
	local strWidth2 = 300
	if G_getCurChoseLanguage() =="ar" then
		strWidth2 =120
	end
    local function bgClick()
    end
    local h=G_VisibleSizeHeight-140
    local w=G_VisibleSizeWidth-50 --背景框的宽度
    local backSprie=CCNode:create()
    backSprie:setAnchorPoint(ccp(0.5,1))
    backSprie:setContentSize(CCSizeMake(w,180))
    backSprie:setAnchorPoint(ccp(0.5,1))
    backSprie:setPosition(ccp(G_VisibleSizeWidth/2,h))
    self.bgLayer:addChild(backSprie,3)

    local iconCfg=acThreeYearVoApi:getPlayerIconCfg()
    if iconCfg then
    	self.vipLimit=iconCfg.viplimit
    	local iconItem=FormatItem(iconCfg.reward[1])[1]
    	local iconSp,scale=G_getItemIcon(iconItem,100,true)
    	iconSp:setAnchorPoint(ccp(0,0.5))
    	iconSp:setPosition(ccp(20,backSprie:getContentSize().height/2+10))
    	backSprie:addChild(iconSp)

		local myVipLb=GetTTFLabelWrap(getlocal("activity_threeyear_myvip"),25,CCSizeMake(strWidth2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	    myVipLb:setAnchorPoint(ccp(0,1))
		-- myVipLb:setColor(G_ColorGreen)
		myVipLb:setPosition(ccp(20,iconSp:getPositionY()-iconSp:getContentSize().height*scale/2-5))
		backSprie:addChild(myVipLb,2)
		local myVipLb2=GetTTFLabel(getlocal("activity_threeyear_myvip"),25)
		local realW=myVipLb2:getContentSize().width
		local lbw=myVipLb:getContentSize().width
		if realW>lbw then
			realW=lbw
		end
		local vipLb=GetTTFLabel(getlocal("VIPStr1",{self.myVip}),25)
		vipLb:setAnchorPoint(ccp(0,1))
		vipLb:setPosition(ccp(myVipLb:getPositionX()+realW,myVipLb:getPositionY()))
		vipLb:setColor(G_ColorYellowPro)
		backSprie:addChild(vipLb)
    end

    local desTv,desLabel=G_LabelTableView(CCSizeMake(G_VisibleSizeWidth-220,70),getlocal("activity_threeyear_vipiconDesc",{self.vipLimit}),25,kCCTextAlignmentLeft)
    backSprie:addChild(desTv)
    desTv:setPosition(ccp(150,80))
    desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    desTv:setMaxDisToBottomOrTop(100)
	local flag=acThreeYearVoApi:getVipIconState()
	if flag==1 or flag==2 then
		local function rewardHandler()
			if G_checkClickEnable()==false then
			    do
			        return
			    end
			else
			    base.setWaitTime=G_getCurDeviceMillTime()
			end
			if flag==1 then
	 			local function callback()
	    			if self.getItem then
					    self.getItem:setEnabled(false)
					    local btnLb=tolua.cast(self.getItem:getChildByTag(12),"CCLabelTTF")
					    if btnLb then
					    	btnLb:setString(getlocal("activity_hadReward"))
					    end
	    			end
				end
				acThreeYearVoApi:threeYearRequest("reward","vip",nil,callback)
			end
		end
		local getItem
		if flag==2 then
			getItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",rewardHandler,11,getlocal("activity_hadReward"),25,12)
			getItem:setEnabled(false)
		else
			getItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",rewardHandler,11,getlocal("daily_scene_get"),25,12)
		end
		if getItem then
			getItem:setAnchorPoint(ccp(0.5,0.5))
			getItem:setScale(0.8)
			local getBtn=CCMenu:createWithItem(getItem)
			getBtn:setTouchPriority(-(self.layerNum-1)*20-3)
			getBtn:setPosition(ccp(backSprie:getContentSize().width-90,50))
			backSprie:addChild(getBtn)
		end
		self.getItem=getItem
	elseif flag==3 then
		local function goRecharge()
			if G_checkClickEnable()==false then
			    do
			        return
			    end
			else
			    base.setWaitTime=G_getCurDeviceMillTime()
			end
			G_goToDialog("gb",self.layerNum+1,true)
		end
		local rechargeItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",goRecharge,nil,getlocal("recharge"),25)
		rechargeItem:setAnchorPoint(ccp(0.5,0.5))
		rechargeItem:setScale(0.8)
		local rechargeBtn=CCMenu:createWithItem(rechargeItem)
		rechargeBtn:setTouchPriority(-(self.layerNum-1)*20-3)
		rechargeBtn:setPosition(ccp(backSprie:getContentSize().width-90,50))
		backSprie:addChild(rechargeBtn)
	end
end

function acThreeYearSecond:initShopView()
	local function nilFunc()
	end
	local shopBg=LuaCCScale9Sprite:createWithSpriteFrameName("iconTitlebg.png",CCRect(27,29,2,2),nilFunc)
    shopBg:setContentSize(CCSizeMake(self.cellWidth,G_VisibleSizeHeight-340))
    shopBg:ignoreAnchorPointForPosition(false)
    shopBg:setAnchorPoint(ccp(0.5,0))
    shopBg:setPosition(ccp(G_VisibleSizeWidth/2,35))
    self.bgLayer:addChild(shopBg)
    local shopNode=CCNode:create()
    shopNode:setContentSize(CCSizeMake(self.cellWidth,G_VisibleSizeHeight-340))
    shopNode:setAnchorPoint(ccp(0.5,0))
    shopNode:setPosition(ccp(G_VisibleSizeWidth/2,35))
    self.bgLayer:addChild(shopNode,3)
    local bgSize=shopNode:getContentSize()
    local lineSp=CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
    lineSp:setScaleX((G_VisibleSizeWidth-30)/lineSp:getContentSize().width)
    lineSp:setAnchorPoint(ccp(0.5,1))
    lineSp:setPosition(ccp(bgSize.width/2,bgSize.height-2))
    shopNode:addChild(lineSp,1)


    local strSize2 = 21
	local kccChoose = kCCTextAlignmentLeft
	local needHeight = 15
	local chooseWidth = 400
	local choosePosX = 20
	local chooseAn = ccp(0,0.5)
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
		strSize2 =25
		kccChoose =kCCTextAlignmentRight
		needHeight =0
		chooseWidth =280
		chooseAn = ccp(1,0.5)
		choosePosX =bgSize.width-90
	end

	local function nilFunc()
    end
    local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("threeyear_numbg.png",CCRect(10,10,10,10),nilFunc)
    backSprie:setContentSize(CCSizeMake(self.cellWidth-20,70))
    backSprie:setAnchorPoint(ccp(0.5,1))
    backSprie:setPosition(ccp(self.cellWidth/2,bgSize.height-30))
    shopNode:addChild(backSprie)

	local timeStr=""
	local function callback()
		self:refresh()
	end
	local time=acThreeYearVoApi:checkRefreshShop(callback)
	if time then
		timeStr=GetTimeStrForFleetSlot(time)
	end
	local timeLb=GetTTFLabelWrap(getlocal("auto_refresh").."："..timeStr,strSize2,CCSizeMake(chooseWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    timeLb:setAnchorPoint(ccp(0,0.5))
	timeLb:setColor(G_ColorYellowPro)
	timeLb:setPosition(ccp(20,bgSize.height-65+needHeight))
	shopNode:addChild(timeLb,2)
	self.timeLb=timeLb

	local function refreshHandler()
		if G_checkClickEnable()==false then
		    do
		        return
		    end
		else
		    base.setWaitTime=G_getCurDeviceMillTime()
		end
		local cost=acThreeYearVoApi:getRefreshCost()
		local function realRefresh()
			local function callback()
				self:refresh()
	    		playerVoApi:setValue("gems",playerVoApi:getGems()-tonumber(cost))
			end
			acThreeYearVoApi:threeYearRequest("refshop",cost,nil,callback)
		end
        local title=getlocal("dialog_title_prompt")
	    local promptStr=getlocal("refresh_shop_promptstr",{cost})
	    local function callBack()
	        if playerVoApi:getGems()<cost then
	        	local function callback()
	        		self.gemsSmallD=nil
	        	end
	            self.gemsSmallD=GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost,callback,callback)
	            do return end
	        else
	            realRefresh()
	        end
	        self.smallD=nil
	    end
	    local function cancelCallBack( ... )
	    	self.smallD=nil
	    end
	    self.smallD=nil
	    local pDialog=smallDialog:new()
	    pDialog:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0,0,400,350),CCRect(168,86,10,10),callBack,title,promptStr,nil,self.layerNum+1,nil,nil,cancelCallBack)
	    self.smallD=pDialog

	end
	local refreshItem=GetButtonItem("acmidautumn_refreshbtn.png","acmidautumn_refreshbtn.png","acmidautumn_refreshbtn.png",refreshHandler,nil,"",25)
	refreshItem:setAnchorPoint(ccp(0.5,0.5))
	refreshItem:setScale(0.75)
	local refreshBtn=CCMenu:createWithItem(refreshItem)
	refreshBtn:setTouchPriority(-(self.layerNum-1)*20-3)
	refreshBtn:setPosition(ccp(bgSize.width-50,bgSize.height-65))
	shopNode:addChild(refreshBtn)
	local cur,max=acThreeYearVoApi:getRefreshNum()
	local refreshNumLb=GetTTFLabelWrap(getlocal("manual_refresh").."："..cur.."/"..max,strSize2,CCSizeMake(chooseWidth,0),kccChoose,kCCVerticalTextAlignmentCenter)
    refreshNumLb:setAnchorPoint(chooseAn)
	refreshNumLb:setColor(G_ColorYellowPro)
	refreshNumLb:setPosition(ccp(choosePosX,bgSize.height-65-needHeight))
	shopNode:addChild(refreshNumLb,2)
	self.refreshItem=refreshItem
	self.refreshNumLb=refreshNumLb
	if tonumber(cur)>=tonumber(max) then
		self.refreshItem:setEnabled(false)
	end

	local function eventHandler( ... )
		return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(eventHandler)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.cellWidth,bgSize.height-105),nil)
    self.tv:setPosition(ccp(2,5))
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    shopNode:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)
end

function acThreeYearSecond:eventHandler(handler,fn,idx,cel)
     if fn=="numberOfCellsInTableView" then
     	if self.goodsCount==0 then
     		return 0
     	end     
        return 1
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(self.cellWidth,self.cellHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local iconSize=100
        local itemW=(self.cellWidth-30)/2
        local posX=5
        local posY=self.cellHeight-self.space
        self.numTb={}
        self.buyBtnTb={}
        for k,goods in pairs(self.shopList) do
    		if k%2==0 then
    			posX=itemW+15
    		else
    			posX=8
    		end
		 	local function nilFunc()
		    end
		    local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("acChunjiepansheng_orangeBg3.png",CCRect(20,20,20,20),nilFunc)
		    backSprie:setContentSize(CCSizeMake(itemW,self.itemHeight))
		    backSprie:setAnchorPoint(ccp(0,1))
		    backSprie:setPosition(ccp(posX,posY))
		    cell:addChild(backSprie)
		    local bgSize=backSprie:getContentSize()
         	local icon,iconScale=G_getItemIcon(goods.reward,iconSize,true,self.layerNum,nil,self.tv)
            icon:setTouchPriority(-(self.layerNum-1)*20-3)
            icon:setAnchorPoint(ccp(0,1))
            icon:setPosition(10,bgSize.height-5)
            backSprie:addChild(icon)

            local pnum=GetTTFLabel("x"..FormatNumber(goods.reward.num),25)
            pnum:setAnchorPoint(ccp(1,0))
            pnum:setPosition(icon:getContentSize().width*iconScale-10,0)
            pnum:setScale(1/iconScale)
            icon:addChild(pnum)
            if k==1 or k==2 then
            	local scale=(icon:getContentSize().width+10)/80
				G_addRectFlicker(icon,scale,scale,getCenterPoint(icon))
            end

            local arPosX = 0
            if G_getCurChoseLanguage() =="ar" then
            	arPosX =30
            end

            local newPrice=goods.price
            local oldPrice=math.ceil(newPrice/goods.discount)
            local priceLbPosX=icon:getPositionX()+icon:getContentSize().width*iconScale+30
        	local oldPriceLb=GetTTFLabelWrap(oldPrice,22,CCSizeMake(70,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		    oldPriceLb:setAnchorPoint(ccp(0,0.5))
			oldPriceLb:setColor(G_ColorYellowPro)
			oldPriceLb:setPosition(ccp(priceLbPosX-arPosX,icon:getPositionY()-oldPriceLb:getContentSize().height/2-10))
			backSprie:addChild(oldPriceLb,2)
			local oldPriceLb2=GetTTFLabel(oldPrice,22)
			local realW=oldPriceLb2:getContentSize().width
			local lbw=oldPriceLb:getContentSize().width
			if realW>lbw then
				realW=lbw
			end
		    local gemSp1=CCSprite:createWithSpriteFrameName("IconGold.png")
		    gemSp1:setAnchorPoint(ccp(0,0.5))
		    gemSp1:setPosition(ccp(oldPriceLb:getPositionX()+realW,oldPriceLb:getPositionY()))
		    backSprie:addChild(gemSp1)
          	local rline=CCSprite:createWithSpriteFrameName("redline.jpg")
            rline:setAnchorPoint(ccp(0,0.5))
            rline:setScaleX((realW+40)/rline:getContentSize().width)
            rline:setPosition(ccp(priceLbPosX-10,oldPriceLb:getPositionY()))
            backSprie:addChild(rline,1)

			local newPriceLb=GetTTFLabelWrap(newPrice,22,CCSizeMake(70,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		    newPriceLb:setAnchorPoint(ccp(0,0.5))
			newPriceLb:setColor(G_ColorYellowPro)
			newPriceLb:setPosition(ccp(priceLbPosX-arPosX,oldPriceLb:getPositionY()-oldPriceLb:getContentSize().height/2-20))
			backSprie:addChild(newPriceLb,2)
			local newPriceLb2=GetTTFLabel(newPrice,22)
			realW=newPriceLb2:getContentSize().width
			lbw=newPriceLb:getContentSize().width
			if realW>lbw then
				realW=lbw
			end
		    local gemSp2=CCSprite:createWithSpriteFrameName("IconGold.png")
		    gemSp2:setAnchorPoint(ccp(0,0.5))
		    gemSp2:setPosition(ccp(newPriceLb:getPositionX()+realW,newPriceLb:getPositionY()))
		    backSprie:addChild(gemSp2)

		    local cur=acThreeYearVoApi:getShopData(goods.stype,goods.id)
            local num=GetTTFLabel(FormatNumber(tonumber(cur)).."/"..FormatNumber(goods.max),25)
            num:setAnchorPoint(ccp(0.5,1))
            num:setPosition(icon:getContentSize().width/2,-5)
            num:setColor(G_ColorYellow)
            num:setScale(1/iconScale)
            icon:addChild(num)

            if G_getCurChoseLanguage() =="ar" then
            	gemSp1:setPosition(ccp(backSprie:getContentSize().width*0.65,oldPriceLb:getPositionY()))
            	gemSp2:setPosition(ccp(backSprie:getContentSize().width*0.65,newPriceLb:getPositionY()))
            end

         	local saleNum=string.format("%.2f",1-goods.discount)*100
            local sellIcon=CCSprite:createWithSpriteFrameName("saleRedBg.png")
            sellIcon:setPosition(ccp(bgSize.width-15,bgSize.height-10))
            sellIcon:setAnchorPoint(ccp(0.5,0.5))
            sellIcon:setScale(0.8)
            backSprie:addChild(sellIcon,2)
            local saleNumStr=GetTTFLabel("-"..saleNum.."%",20)
            saleNumStr:setAnchorPoint(ccp(0.5,0.5))
            saleNumStr:setPosition(getCenterPoint(sellIcon))
            saleNumStr:setRotation(30)
            sellIcon:addChild(saleNumStr)

    		local function buyHandler()
				if self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
					if G_checkClickEnable()==false then
					    do
					        return
					    end
					else
					    base.setWaitTime=G_getCurDeviceMillTime()
					end
					local function realBuy()
						local function callback()
		    				local cur=acThreeYearVoApi:getShopData(goods.stype,goods.id)
							if self.numTb and self.numTb[k] then
								self.numTb[k]:setString(FormatNumber(tonumber(cur)).."/"..FormatNumber(goods.max))
							end
							if tonumber(cur)==tonumber(goods.max) then
								if self.buyBtnTb and self.buyBtnTb[k] then
									self.buyBtnTb[k]:setEnabled(false)
								end
							end
                    		playerVoApi:setValue("gems",playerVoApi:getGems()-tonumber(newPrice))
						end
						acThreeYearVoApi:threeYearRequest("buy",goods.stype,goods.id,callback)
					end
			        local title=getlocal("dialog_title_prompt")
				    local promptStr=getlocal("buyConfirm",{newPrice,goods.reward.num,goods.reward.name})
				    local function callBack()
				        if playerVoApi:getGems()<newPrice then
				        	local function callback()
				        		self.gemsSmallD=nil
				        	end
				            self.gemsSmallD=GemsNotEnoughDialog(nil,nil,newPrice-playerVoApi:getGems(),self.layerNum+1,newPrice,callback,callback)
				            do return end
				        else
				            realBuy()
				        end
				        self.smallD=nil
				    end
				    local function cancelCallBack()
				    	self.smallD=nil
				    end
				    self.smallD=nil
				    local pDialog=smallDialog:new()
				    pDialog:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0,0,400,350),CCRect(168,86,10,10),callBack,title,promptStr,nil,self.layerNum+1,nil,nil,cancelCallBack)
				    self.smallD=pDialog
				end
			end
			local buyItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall.png","BtnCancleSmall.png",buyHandler,11,getlocal("buy"),25)
			buyItem:setAnchorPoint(ccp(0.5,0.5))
			buyItem:setScale(0.8)
			local buyBtn=CCMenu:createWithItem(buyItem)
			buyBtn:setTouchPriority(-(self.layerNum-1)*20-3)
			buyBtn:setPosition(ccp(backSprie:getContentSize().width-80,40))
			backSprie:addChild(buyBtn)
			if tonumber(cur)==tonumber(goods.max) then
				buyItem:setEnabled(false)
			end

			if k%2==0 then
    			posY=posY-self.itemHeight-self.space
			end
			self.numTb[k]=num
			self.buyBtnTb[k]=buyItem
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

function acThreeYearSecond:refresh()
	if self.tv then
		if self.refreshNumLb and self.refreshItem then
			local cur,max=acThreeYearVoApi:getRefreshNum()
			self.refreshNumLb:setString(getlocal("manual_refresh").."："..cur.."/"..max)
			if tonumber(cur)>=tonumber(max) then
				self.refreshItem:setEnabled(false)
			else
				self.refreshItem:setEnabled(true)
			end
		end
		self.shopList=acThreeYearVoApi:getShopList()
		if self.shopList then
			self.goodsCount=SizeOfTable(self.shopList)
		end
		self.tv:reloadData()
	end
end

function acThreeYearSecond:tick()
	local timeStr=""
	local function callback()
		self:refresh()
	end
	local time=acThreeYearVoApi:checkRefreshShop(callback)
	if time and self.timeLb then
		timeStr=GetTimeStrForFleetSlot(time)
		self.timeLb:setString(getlocal("auto_refresh").."："..timeStr)
	end
	--跨天清空刷新次数
	local isEnd=acThreeYearVoApi:isEnd()
    local todayFlag=acThreeYearVoApi:isToday()
    if self.isTodayFlag==true and todayFlag==false and isEnd==false then
        self.isTodayFlag=false
        acThreeYearVoApi:clearRefreshNum()
        self:refresh()
    end
end

function acThreeYearSecond:dispose()
	if self.bgLayer then
		self.bgLayer:removeFromParentAndCleanup(true)
		self.bgLayer=nil
	end
	if self.smallD and self.smallD.close then
		self.smallD:close()
		self.smallD=nil
	end
	if self.gemsSmallD and self.gemsSmallD.close then
		self.gemsSmallD:close()
		self.gemsSmallD=nil
	end
	self.parent=nil
	self.layerNum=nil
	self.vipLimit=0
	self.myVip=0
	self.goodsCount=0
	self.shopList=nil
	self.cellWidth=G_VisibleSizeWidth-50
	self.cellHeight=0
	self.itemHeight=150
	self.refreshItem=nil
	self.refreshNumLb=nil
	self.numTb=nil
	self.buyBtnTb=nil
	self.space=20
	self=nil
end