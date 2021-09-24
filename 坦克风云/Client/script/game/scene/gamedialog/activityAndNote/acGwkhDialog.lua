acGwkhDialog=commonDialog:new()

function acGwkhDialog:new( )
	local nc = {}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acGwkhDialog:resetTab()
	self.panelLineBg:setVisible(false)
    self.panelTopLine:setVisible(false)
    self.panelShadeBg:setVisible(true)

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	spriteController:addPlist("public/acGwkhIconImage.plist")
	spriteController:addTexture("public/acGwkhIconImage.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
end

function acGwkhDialog:initTableView()

	self.today = acGwkhVoApi:getToday()
	self.tDialogHeight = 80
	self.bgLayer1 = self.bgLayer

    --活动时间
 	local acTimeLb=GetTTFLabel(acGwkhVoApi:getTimeStr(),25,true)
	acTimeLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-self.tDialogHeight-30))
	acTimeLb:setColor(G_ColorYellowPro)
	self.bgLayer:addChild(acTimeLb,6)
	self.acTimeLb=acTimeLb

	local timeBg = LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png", CCRect(103, 0, 2, 80), function()end)
    timeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, timeBg:getContentSize().height+5))
    timeBg:setAnchorPoint(ccp(0.5, 1))
    timeBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight-self.tDialogHeight)
    timeBg:setOpacity(0.8*255)
    self.bgLayer:addChild(timeBg,2)

    --I里的信息
    local function touchTip()
		local tabStr={getlocal("activity_gwkh_info1"),getlocal("activity_gwkh_info2"),getlocal("activity_gwkh_info3")}
		require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
		tipShowSmallDialog:showStrInfo(self.layerNum+5,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),tabStr)
	end
	G_addMenuInfo(self.bgLayer,self.layerNum+1,ccp(G_VisibleSizeWidth - 40,G_VisibleSizeHeight-self.tDialogHeight-40),{},nil,nil,28,touchTip,true)


	--今日消费
	local showBg
	--今天消费了多少

	self.todayCost = GetTTFLabel(acGwkhVoApi:getTodayCostStr(  ),28,true)
	local goldIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
	self.todayCost:setAnchorPoint(ccp(0,1))
	self.todayCost:setPosition(ccp((G_VisibleSizeWidth-self.todayCost:getContentSize().width-goldIcon:getContentSize().width+2)/2,timeBg:getPositionY()-timeBg:getContentSize().height/5*4))
	self.bgLayer:addChild(self.todayCost,6)
	goldIcon:setAnchorPoint(ccp(0,1))
	goldIcon:setPosition(ccp(self.todayCost:getPositionX()+self.todayCost:getContentSize().width+2,self.todayCost:getPositionY()))
	self.bgLayer:addChild(goldIcon,6)

	--今日消费达

	self:eventHandler2( )


	--亮亮的底图
	local lowBg = CCSprite:createWithSpriteFrameName("acGwkhBg.png")
	lowBg:setAnchorPoint(ccp(0,1))
	lowBg:setPosition(ccp(0,G_VisibleSizeHeight-self.tDialogHeight-10))
	self.bgLayer:addChild(lowBg,1)

	--累计奖励的滑动列表
		--配置里奖励的种数
	self.cellNum = acGwkhVoApi:getTotalRewardNum()
	self.cellHeight = 210
	self.tvWidth = G_VisibleSizeWidth - 40
	self.tvHeight = self.costLineBg:getPositionY() - self.costLineBg:getContentSize().height -30
	local function callBack(...)
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	local pos = ccp(20,20)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    self.tv:setPosition(pos)
    self.bgLayer:addChild(self.tv)
    

end

function acGwkhDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
	    return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
        return CCSizeMake(self.tvWidth,self.cellHeight)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        --累计奖励的单个列表
		local totalRewardTb = acGwkhVoApi:getTotalRewardList(idx+1)
		local function nilFunc( ... )
    	end
		local tbBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),nilFunc)
		tbBg:setContentSize(CCSizeMake(self.tvWidth-1,self.cellHeight-5))
		tbBg:setAnchorPoint(ccp(0,0))
		tbBg:setPosition(ccp(0,0))
		cell:addChild(tbBg)

	    local tbTitleImage = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png", CCRect(105, 16, 1, 1), function()end)
	    local tbTitleDes = acGwkhVoApi:getRewardTitleStr(idx+1)
        tbTitleImage:setContentSize(CCSizeMake(self.tvWidth-20, tbTitleImage:getContentSize().height))
        tbTitleImage:setAnchorPoint(ccp(0,1))
        tbTitleImage:setPosition(ccp(3,tbBg:getContentSize().height-2))
        tbTitleDes:setAnchorPoint(ccp(0,1))
        tbTitleDes:setPosition(ccp(17,tbTitleImage:getContentSize().height))
        tbTitleImage:addChild(tbTitleDes)
        tbBg:addChild(tbTitleImage)

        local giftImage = CCSprite:createWithSpriteFrameName("manyGift.png")
        giftImage:setAnchorPoint(ccp(0,0.5))
        giftImage:setPosition(ccp(20,(tbBg:getContentSize().height-tbTitleImage:getContentSize().height)/2))
        cell:addChild(giftImage)

        --累计奖品列表
        local totalRewardTbList=FormatItem(acGwkhVoApi:getTotalRewardList(idx+1))
		local num = 0
		for k,v in pairs(totalRewardTbList) do
			num = num+1
		end
		for k,v in pairs(totalRewardTbList) do
			if v then 
	            local function showTip()
	                if G_checkClickEnable()==false then
	                    do
	                        return
	                    end
	                else
	                    base.setWaitTime=G_getCurDeviceMillTime()
	                end
            		G_showNewPropInfo(self.layerNum+1,true,true,nil,v) 
	            end
	            
				local iconSp = G_getItemIcon(v,nil,true,100,showTip,nil,nil,nil,nil,nil,true)
	            iconSp:setAnchorPoint(ccp(0,0.5))
	            iconSp:setScale(0.7)
	            local iconSize=iconSp:getContentSize().width*0.7
	            iconSp:setPosition(ccp(40+giftImage:getContentSize().width+(iconSize+15)*(k-1),giftImage:getPositionY()))
	            iconSp:setTouchPriority(-(self.layerNum-1)*20-4)
	            cell:addChild(iconSp,6)

	            local numLb=GetTTFLabel("x"..FormatNumber(v.num),20)
                numLb:setAnchorPoint(ccp(1,0))
                numLb:setPosition(ccp(iconSp:getContentSize().width-5,5))
                iconSp:addChild(numLb,4)
                local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
                numBg:setAnchorPoint(ccp(1,0))
                numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-2))
                numBg:setPosition(ccp(iconSp:getContentSize().width-5,5))
                numBg:setOpacity(150)
                iconSp:addChild(numBg,3) 
			end
		end

		--每个cell的按钮
			local judge = acGwkhVoApi:ifHasRewardTotal(idx+1)
			local hasReward = GetTTFLabel(getlocal("activity_vipAction_had"),24,true)
			hasReward:setAnchorPoint(ccp(1,0.5))
			hasReward:setColor(G_ColorGray)
			hasReward:setPosition(ccp(self.tvWidth-40,giftImage:getPositionY()))
			hasReward:setVisible(judge)
			cell:addChild(hasReward)

			function goShoppingHandler( ... )
				G_goToDialog2("jb",self.layerNum,true)
			end
			self.goShoppingBtn1=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",goShoppingHandler,11,getlocal("activity_heartOfIron_goto"),30,100)
		    self.goShoppingBtn1:setAnchorPoint(ccp(1,0.5))
		    self.goShoppingBtn1:setScale(0.7)
		    local lb = self.goShoppingBtn1:getChildByTag(100)
		    if lb then
		        lb = tolua.cast(lb,"CCLabelTTF")
		        lb:setFontName("Helvetica-bold")
		    end
		    self.goShoppingMenu1=CCMenu:createWithItem(self.goShoppingBtn1)
		    self.goShoppingMenu1:setPosition(ccp(self.tvWidth-15,giftImage:getPositionY()))
		    self.goShoppingMenu1:setTouchPriority(-(self.layerNum-1)*20-4)
		    self.goShoppingMenu1:setVisible(not judge)
		    self.goShoppingMenu1:setEnabled(not judge)
		    cell:addChild(self.goShoppingMenu1)
		


     	return cell
    end
end

function acGwkhDialog:eventHandler2( ... )

	
	for i=1,2 do

		local size = (G_VisibleSizeWidth-20-30)/2
		if i==1 then
			self.costLineBg = LuaCCScale9Sprite:createWithSpriteFrameName("newItemKuang.png", CCRect(15, 15, 2, 2), function () end)
		else
			self.costLineBg = LuaCCScale9Sprite:createWithSpriteFrameName("newItemKuangBlue.png", CCRect(15, 15, 2, 2), function () end)
		end	
		self.costLineBg:setContentSize(CCSizeMake(size,240))
		local pos = (G_VisibleSizeWidth-self.costLineBg:getContentSize().width*2-20)/2
		self.costLineBg:setPosition(ccp(pos+(size+20)*(i-1),self.todayCost:getPositionY()-self.todayCost:getContentSize().height-12))
		self.costLineBg:setAnchorPoint(ccp(0,1))
		self.costLineBg:setOpacity(0.8*255)
		self.bgLayer1:addChild(self.costLineBg,5)

		--配置里今日消费多少
		local todayCostCfg = acGwkhVoApi:getDailyCostCfg(i)
		local fontsize
		if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" then
			fontsize=23
		else
			fontsize=16
		end
		local costLineTitle = GetTTFLabel(getlocal("activity_gwkh_todaygold")..todayCostCfg,fontsize,true)
		local goldIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
		costLineTitle:setAnchorPoint(ccp(0,1))
		goldIcon:setAnchorPoint(ccp(0,1))
		costLineTitle:setPosition(ccp((self.costLineBg:getContentSize().width-costLineTitle:getContentSize().width-goldIcon:getContentSize().width)/2,self.costLineBg:getContentSize().height-15))
		goldIcon:setPosition(ccp(costLineTitle:getPositionX()+costLineTitle:getContentSize().width+5,self.costLineBg:getContentSize().height-14))
		self.costLineBg:addChild(costLineTitle)
		self.costLineBg:addChild(goldIcon)


		--每日奖品列表
		local rewardTbList=FormatItem(acGwkhVoApi:getTodayRewardList(i))
		local num = 0
		for k,v in pairs(rewardTbList) do
			num = num+1
		end
		for k,v in pairs(rewardTbList) do
			if v then 
	            local function showTip()
	                if G_checkClickEnable()==false then
	                    do
	                        return
	                    end
	                else
	                    base.setWaitTime=G_getCurDeviceMillTime()
	                end
            		G_showNewPropInfo(self.layerNum+1,true,true,nil,v) 
	            end
	            
				local iconSp = G_getItemIcon(v,nil,true,100,showTip,nil,nil,nil,nil,nil,true)
	            iconSp:setAnchorPoint(ccp(0,0.5))
	            iconSp:setScale(0.7)
	            local iconSize=iconSp:getContentSize().width*0.7
	            iconSp:setPosition(ccp((self.costLineBg:getContentSize().width-iconSize*num-15*(num-1))/2+(iconSize+15)*(k-1),self.costLineBg:getContentSize().height/2+15))
	            iconSp:setTouchPriority(-(self.layerNum-1)*20-4)
	            self.costLineBg:addChild(iconSp,6)

	            local numLb=GetTTFLabel("x"..FormatNumber(v.num),20)
                numLb:setAnchorPoint(ccp(1,0))
                numLb:setPosition(ccp(iconSp:getContentSize().width-5,5))
                iconSp:addChild(numLb,4)
                local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
                numBg:setAnchorPoint(ccp(1,0))
                numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-2))
                numBg:setPosition(ccp(iconSp:getContentSize().width-5,5))
                numBg:setOpacity(150)
                iconSp:addChild(numBg,3) 
			end
		end

		--领取按钮
		local todayIs = acGwkhVoApi:getDay()
		local judge = acGwkhVoApi:ifHasRewardToday(todayIs,i)

		self.hasReward = GetTTFLabel(getlocal("activity_vipAction_had"),24,true)
		self.hasReward:setAnchorPoint(ccp(0.5,0.5))
		self.hasReward:setColor(G_ColorGray)
		self.hasReward:setPosition(ccp(self.costLineBg:getContentSize().width/2,self.costLineBg:getContentSize().height/5))
		self.hasReward:setVisible(judge)
		self.costLineBg:addChild(self.hasReward)

		function goShoppingHandler( ... )
			G_goToDialog2("jb",self.layerNum,true)
		end
		self.goShoppingBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",goShoppingHandler,11,getlocal("activity_heartOfIron_goto"),30,100)
	    self.goShoppingBtn:setAnchorPoint(ccp(0.5,0.5))
	    self.goShoppingBtn:setScale(0.7)
	    local lb = self.goShoppingBtn:getChildByTag(100)
	    if lb then
	        lb = tolua.cast(lb,"CCLabelTTF")
	        lb:setFontName("Helvetica-bold")
	    end
	    self.goShoppingMenu=CCMenu:createWithItem(self.goShoppingBtn)
	    self.goShoppingMenu:setPosition(ccp(self.costLineBg:getContentSize().width/2,self.costLineBg:getContentSize().height/5))
	    self.goShoppingMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	    self.goShoppingMenu:setVisible(not judge)
	    self.goShoppingMenu:setEnabled(not judge)
	    self.costLineBg:addChild(self.goShoppingMenu)
	end
end

function acGwkhDialog:tick( ... )
	if tolua.cast(self.acTimeLb,"CCLabelTTF") then
    	self.acTimeLb:setString(acGwkhVoApi:getTimeStr())
    end
    if acGwkhVoApi:checkIsToday( self.today ) then
    	self:refresh()
    	self.today=acGwkhVoApi:getToday()
    end

    local isEnd=acGwkhVoApi:isEnd()
    if isEnd==true then
        self:close()
    end
end

function acGwkhDialog:refresh()
	if tolua.cast(self.todayCost,"CCLabelTTF") then
    	self.todayCost:setString(acGwkhVoApi:getTodayCostStr( ))
    end
    self.goShoppingMenu:setVisible(true)
    self.goShoppingMenu:setEnabled(true)
    self.hasReward:setVisible(false)
    self.costLineBg=nil
    self:eventHandler2()
end

function acGwkhDialog:dispose()
	spriteController:removePlist("public/acGwkhIconImage.plist")
    spriteController:removeTexture("public/acGwkhIconImage.png")
end