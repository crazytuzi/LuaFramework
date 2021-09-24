-- @Author hj
-- @Description 名将增援商店板子
-- @Date 2018-06-11

acMjzyShopDialog = {} 

function acMjzyShopDialog:new(layer)
	local nc = {
		layerNum = layer,
		shopList = acMjzyVoApi:reorderShopList()
	}
	setmetatable(nc,self)
	self.__index = self
	return nc
end

function acMjzyShopDialog:init()
	self.bgLayer=CCLayer:create()
	self:doUserHandler()
	self:initTableView()
	return self.bgLayer
end

function acMjzyShopDialog:doUserHandler()

	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	
	local function onLoadIcon(fn,icon)
		if self and self.bgLayer and tolua.cast(self.bgLayer,"CCLayer") then
			icon:setAnchorPoint(ccp(0.5,1))
			icon:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160))
			self.bgLayer:addChild(icon)

			local goldLb = GetTTFLabel(getlocal("serverwarteam_own_gems",{playerVoApi:getGems()}),24,true)
			goldLb:setAnchorPoint(ccp(0.5,1))
			goldLb:setPosition(ccp(425,130))
			self.goldLb = goldLb
			icon:addChild(goldLb)

			local function rechargeCallback( ... )
				vipVoApi:showRechargeDialog(self.layerNum+1)
			end
			local rechargeBtn = G_createBotton(icon,ccp(425,50),{getlocal("recharge")},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",rechargeCallback,0.8,-(self.layerNum-1)*20-4)

		end
	end
	local webImage=LuaCCWebImage:createWithURL(G_downloadUrl("active/acMjzyShop_headBg.jpg"),onLoadIcon)
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
end

function acMjzyShopDialog:initTableView( ... )
	local function callBack(...)
        return self:eventHandler(...)
    end

    local function nilFunc( ... )
    end
    local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),nilFunc)
    self.bgLayer:addChild(tvBg)
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20,G_VisibleSizeHeight-158-180-20-10))
    tvBg:setAnchorPoint(ccp(0,0))
    tvBg:setPosition(ccp(10,20))

    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-20,G_VisibleSizeHeight-158-180-20-10-10),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
    self.tv:setPosition(ccp(10,25))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(80)

    --设置tableview的遮罩
    local stencilBgUp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
    stencilBgUp:setContentSize(CCSizeMake(G_VisibleSizeWidth-20,360))
    stencilBgUp:setAnchorPoint(ccp(0.5,1))
    stencilBgUp:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight))
    stencilBgUp:setTouchPriority(-(self.layerNum-1)*20-3)
    stencilBgUp:setVisible(false)
    stencilBgUp:setIsSallow(true)
    self.bgLayer:addChild(stencilBgUp)
    local stencilBgDown=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
    stencilBgDown:setContentSize(CCSizeMake(G_VisibleSizeWidth-20,25))
    stencilBgDown:setAnchorPoint(ccp(0.5,0))
    stencilBgDown:setPosition(ccp(G_VisibleSizeWidth/2,0))
    stencilBgDown:setTouchPriority(-(self.layerNum-1)*20-3)
    stencilBgDown:setVisible(false)
    stencilBgDown:setIsSallow(true)
    self.bgLayer:addChild(stencilBgDown)
end

function acMjzyShopDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		if self.shopList then
        	return #self.shopList
        else
        	return 0
        end
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize = CCSizeMake(G_VisibleSizeWidth-20,120)
        return tmpSize
    elseif fn=="tableCellAtIndex" then
    	local cell=CCTableViewCell:new()
        cell:autorelease()
        self:initCell(idx+1,cell)
        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end


function acMjzyShopDialog:initCell(seq,cell)

	cell:setContentSize(CCSizeMake(G_VisibleSizeWidth-20,160))
	local colorTb
	local shopInfo = self.shopList[seq]
	local shopId = shopInfo.id
	-- 解锁需要的抽奖次数
	local rewardNum = shopInfo.costNum
	-- 商品的购买限制
	local buyLimit = shopInfo.bn
	-- 原价
	local originalCost = shopInfo.p
	-- 商品的购买花费
	local cost = math.floor(shopInfo.p * shopInfo.dis)
	-- 商品的详细信息
	local shopItem = FormatItem(shopInfo.reward,nil,true)[1]

	local function showNewPropInfo()
	    G_showNewPropInfo(self.layerNum+1,true,true,nil,shopItem)
	end
    local icon,scale=G_getItemIcon(shopItem,80,false,self.layerNum+1,showNewPropInfo,nil,nil,nil,nil,nil,true)
    icon:setAnchorPoint(ccp(0,0.5))
    icon:setPosition(ccp(20,cell:getContentSize().height/2-10))
    icon:setTouchPriority(-(self.layerNum-1)*20-2)
    cell:addChild(icon)

    local numLb=GetTTFLabel("x"..FormatNumber(shopItem.num),18)
    numLb:setAnchorPoint(ccp(1,0))
    numLb:setPosition(ccp(icon:getContentSize().width-5,5))
    icon:addChild(numLb,1)
    numLb:setScale(1/scale)


	local strSize = 22
	if G_isAsia() == false then
		strSize = 17
	end

	if acMjzyVoApi:getBuyCount(shopId) >= buyLimit then
        colorTb = {nil,G_ColorGreen,G_ColorRed,nil}
    else
        colorTb = {nil,G_ColorGreen,G_ColorYellowPro,nil}
    end
    local adaWidth = 400
    if G_getCurChoseLanguage() == "ar" then
    	adaWidth = 250
    end
    local param = acMjzyVoApi:getBuyCount(shopId) >= buyLimit and buyLimit or acMjzyVoApi:getBuyCount(shopId)
	local descStr = getlocal("activity_mjzy_shopDesc",{shopItem.name,param,buyLimit})
	local descLb,lbHeight = G_getRichTextLabel(descStr,colorTb,strSize,adaWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	descLb:setAnchorPoint(ccp(0,1))
	descLb:setPosition(ccp(20+100,cell:getContentSize().height-50))
	cell:addChild(descLb)

	if acMjzyVoApi:getRewardNum() >= rewardNum then
		colorTb = {nil,G_ColorYellowPro,nil}
	else
		colorTb = {nil,G_ColorRed,nil}
	end
	local sizeWidth = 400
	if G_isAsia() == false then
		if G_getCurChoseLanguage()  == "ar" then
			sizeWidth = 300
		else
			sizeWidth = 350
		end
	end
	local param = acMjzyVoApi:getRewardNum() >= rewardNum and rewardNum or acMjzyVoApi:getRewardNum()
	local limitLb = G_getRichTextLabel(getlocal("activity_mjzy_shopLimit",{param,rewardNum}),colorTb,strSize,sizeWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	limitLb:setAnchorPoint(ccp(0,1))
	limitLb:setPosition(ccp(20+100,cell:getContentSize().height-40-30-lbHeight))
	cell:addChild(limitLb)

	-- 购买按钮
	local function buyCallback()
		if acMjzyVoApi:getRewardNum() >= rewardNum then
			if acMjzyVoApi:getBuyCount(shopId) >= buyLimit then
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_thfb_buy_limit"),30)
			else
				if playerVoApi:getGems() < cost then
					GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost)
				else

					local function realBuy(num)
						if not num then
							num = 1
						end
		        		local function callback(fn,data)
			    			local ret,sData = base:checkServerData(data)
			    			if ret==true then
				    			if sData.data and sData.data.mjzy then
				    				playerVoApi:setGems(playerVoApi:getGems()-cost*num)
				    				acMjzyVoApi:updateSpecialData(sData.data.mjzy)
				    				self:refreshGoldLb()
				    				self:refreshShopList()
				    				local recordPoint=self.tv:getRecordPoint()
				    				self.tv:reloadData()
							        self.tv:recoverToRecordPoint(recordPoint)

				    				if shopItem.type == "h" then
	                                	heroVoApi:addSoul(shopItem.key,shopItem.num*num)
	                            	else
	                            		-- 将领道具需要公告
	                            		local paramTab = {}
										paramTab.functionStr="mjzy"
										paramTab.addStr="goTo_see_see"
										paramTab.colorStr="w,y,w"
								        local playerName = playerVoApi:getPlayerName() 
								        local propName = shopItem.name
										local message = {key="activity_mjzy_sysMessage",param={playerName,propName}}
										chatVoApi:sendSystemMessage(message,paramTab) 
				    					G_addPlayerAward(shopItem.type,shopItem.key,shopItem.id,shopItem.num*num,nil,true)
	                            	end
	                            	local reward = {}
	                            	for i=1,num do
	                            		table.insert(reward,FormatItem(shopInfo.reward,nil,true)[1])
	                            	end
	                            	G_showRewardTip(reward,true)
				    			end
			    			end
	        			end
	        			socketHelper:acMjzyShopBuy(shopId,num,callback)
        			end 
        			-- 将领道具不用批量购买 因为只投放一次
		            if shopItem.num <= 1  then
			            local function secondTipFunc(sbFlag)
			                local keyName = "mjzy"
			                local sValue=base.serverTime .. "_" .. sbFlag
			                G_changePopFlag(keyName,sValue)
			            end
			            local keyName = "mjzy"
			            if G_isPopBoard(keyName) then
			               G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{cost}),true,realBuy,secondTipFunc)
			            else
			                realBuy(1)
			            end
			        else
			        	local canBuyNum = buyLimit - acMjzyVoApi:getBuyCount(shopId)
		            	shopVoApi:showBatchBuyPropSmallDialog("p1",self.layerNum+1,realBuy,nil,canBuyNum,cost,nil,true,shopItem)
		        	end
				end
			end
		else
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_mjzy_reinforceLimit"),30)
		end
	end
	local buyBtn
	if acMjzyVoApi:getBuyCount(shopId) >= buyLimit then
		buyBtn = G_createBotton(cell,ccp(cell:getContentSize().width-80,cell:getContentSize().height/2-15),{getlocal("hasBuy"),24},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",buyCallback,0.6,-(self.layerNum-1)*20-2)
		buyBtn:setEnabled(false)		
	else
		buyBtn = G_createBotton(cell,ccp(cell:getContentSize().width-80,cell:getContentSize().height/2-15),{getlocal("buy"),24},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",buyCallback,0.6,-(self.layerNum-1)*20-2)
	end

    local originalCostLb = GetTTFLabel(originalCost,24)
    originalCostLb:setAnchorPoint(ccp(1,0.5))
    originalCostLb:setColor(G_ColorRed)
    originalCostLb:setScale(1/0.7)
    buyBtn:addChild(originalCostLb)

    local costLb=GetTTFLabel(cost,24)
    costLb:setAnchorPoint(ccp(0,0.5))
    if playerVoApi:getGems() >= cost then
    	costLb:setColor(G_ColorYellowPro)
	else
		costLb:setColor(G_ColorRed)
	end

    costLb:setScale(1/0.7)
    buyBtn:addChild(costLb)

    local redLine=CCSprite:createWithSpriteFrameName("white_line.png")
    redLine:setColor(G_ColorRed)
    redLine:setAnchorPoint(ccp(0.5,0.5))
    redLine:setScaleX(originalCostLb:getContentSize().width/redLine:getContentSize().width)
    originalCostLb:addChild(redLine)


    local costSp=CCSprite:createWithSpriteFrameName("IconGold.png")
    costSp:setAnchorPoint(ccp(0,0.5))
    costSp:setScale(1/0.7)
    buyBtn:addChild(costSp)

    costLb:setPosition(buyBtn:getContentSize().width/2+10,buyBtn:getContentSize().height+costLb:getContentSize().height/2+10)
    originalCostLb:setPosition(buyBtn:getContentSize().width/2-10,buyBtn:getContentSize().height+costLb:getContentSize().height/2+10)
    costSp:setPosition(originalCostLb:getPositionX()-originalCostLb:getContentSize().width-70,costLb:getPositionY())
    redLine:setPosition(originalCostLb:getContentSize().width/2,originalCostLb:getContentSize().height/2)
    
    local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function()end)
	lineSp:setAnchorPoint(ccp(0.5,0))
	lineSp:setPosition(ccp(cell:getContentSize().width/2,7))
	lineSp:setContentSize(CCSizeMake(cell:getContentSize().width-30,2))
	cell:addChild(lineSp)

end

function acMjzyShopDialog:refreshShopList( ... )
	self.shopList = acMjzyVoApi:reorderShopList()
end

function acMjzyShopDialog:refreshGoldLb( ... )
	if self.goldLb and tolua.cast(self.goldLb,"CCLabelTTF") then
		tolua.cast(self.goldLb,"CCLabelTTF"):setString(getlocal("serverwarteam_own_gems",{playerVoApi:getGems()}))
	end
end

function acMjzyShopDialog:tick( ... )
	if self.goldLb and tolua.cast(self.goldLb,"CCLabelTTF") then
		tolua.cast(self.goldLb,"CCLabelTTF"):setString(getlocal("serverwarteam_own_gems",{playerVoApi:getGems()}))
	end
end

function acMjzyShopDialog:dispose( ... )

end
