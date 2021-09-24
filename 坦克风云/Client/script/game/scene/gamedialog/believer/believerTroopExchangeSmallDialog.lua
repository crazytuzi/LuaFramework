local believerTroopExchangeSmallDialog=smallDialog:new()

function believerTroopExchangeSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function believerTroopExchangeSmallDialog:init(exchangeList,exchangeRateTb,isShowRate,layerNum,confirmHandler,oneKeyState,oneKeyConfirmHandler,oneKeyCancelHandler)
	self.isTouch=nil
	self.isUseAmi=true
	self.layerNum=layerNum
	
	local dialogWidth,dialogHeight,itemHeight=550,200,240
	if isShowRate==true then
		itemHeight=itemHeight+80
	end
	if oneKeyState~=nil then
		dialogHeight=dialogHeight+60
	end
	local tvWidth,tvHeight=dialogWidth-40,0
	local cellNum=SizeOfTable(exchangeList)
	if cellNum>1 then
		tvHeight=itemHeight*3/2
	else
		tvHeight=itemHeight
	end
	dialogHeight=dialogHeight+tvHeight

    self.bgSize=CCSizeMake(dialogWidth,dialogHeight)
    local function close()
    	return self:close()
    end
    local dialogBg=G_getNewDialogBg(self.bgSize,getlocal("code_gift"),30,nil,self.layerNum,true,close)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
	self.bgLayer:setTouchPriority(-(layerNum-1)*20-2)
	self.bgLayer:setContentSize(self.bgSize)
	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)

	local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
	tvBg:setAnchorPoint(ccp(0.5,1))
    tvBg:setContentSize(CCSizeMake(tvWidth,tvHeight+10))
    tvBg:setPosition(self.bgSize.width*0.5,self.bgSize.height-70)
    self.bgLayer:addChild(tvBg)

    local function infoHandler()
        local strTb={}
        for i=1,4 do
            local str=getlocal("believer_troop_exchange_info_"..i)
            table.insert(strTb,str)
        end
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),strTb)
    end
    local infoItem=G_addMenuInfo(tvBg,self.layerNum,ccp(tvWidth-35,tvBg:getContentSize().height-35),{},nil,nil,28,infoHandler,true)

    local isMoved,canBuy=false,true
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return cellNum
        elseif fn=="tableCellSizeForIndex" then
            return CCSizeMake(tvWidth,itemHeight)
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            local exchangeTank=exchangeList[idx+1]
            if exchangeTank==nil or exchangeTank[1]==nil or exchangeTank[2]==nil then
            	do return cell end
            end
            local tankId,tankNum=exchangeTank[1],exchangeTank[2]
            tankId=tonumber(RemoveFirstChar(tankId))
            local tmpTankCfg=tankCfg[tankId]

            local fontSize,fontWidth,iconWidth=25,tvWidth/2-60,120
            local textPosY,iconPosY=itemHeight-30,itemHeight-45-iconWidth/2
			local desc1=getlocal("world_war_fleet_cost_desc1")
		    local descLb1=GetTTFLabelWrap(desc1,fontSize,CCSize(fontWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter) 
		    descLb1:setPosition(tvWidth/2-120,textPosY)
		    descLb1:setColor(G_ColorRed)
		    cell:addChild(descLb1,2)
		    descLb1:setColor(G_ColorGreen)

		    local desc2=getlocal("world_war_fleet_cost_desc2")
		    local descLb2=GetTTFLabelWrap(desc2,fontSize,CCSize(fontWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		    descLb2:setPosition(tvWidth/2+120,textPosY)
		    cell:addChild(descLb2,2)
		    descLb2:setColor(G_ColorGreen)
            local cost,obtain,exchangeNum=0,0,nil --cost/obtain是兑换比例，exchangeNum兑换次数
            if exchangeRateTb and exchangeRateTb[idx+1] then
            	cost,obtain,exchangeNum=(exchangeRateTb[idx+1][1] or 0),(exchangeRateTb[idx+1][2] or 0),exchangeRateTb[idx+1][3]
            end
            if isShowRate==true then
            	local rateBg=CCSprite:createWithSpriteFrameName("believerTitleBg.png")
			    rateBg:setPosition(tvWidth/2,30)
			    cell:addChild(rateBg)
			    if exchangeNum and exchangeNum>0 then
					--第几次兑换
					local timesLb=GetTTFLabelWrap(getlocal("raids_reward_num",{exchangeNum}),fontSize,CCSizeMake(100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
					timesLb:setAnchorPoint(ccp(0,0.5))
					timesLb:setPosition(ccp(70,rateBg:getContentSize().height/2))
					rateBg:addChild(timesLb,1)
					--兑换比例
					local rateLb=GetTTFLabelWrap(getlocal("believer_troop_exchange_rate",{cost,obtain}),fontSize,CCSizeMake(rateBg:getContentSize().width-170,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
					rateLb:setAnchorPoint(ccp(0,0.5))
					rateLb:setPosition(ccp(timesLb:getPositionX()+timesLb:getContentSize().width+10,rateBg:getContentSize().height/2))
					rateBg:addChild(rateLb,1)
				else
					local rateLb=GetTTFLabelWrap(getlocal("believer_troop_exchange_rate",{cost,obtain}),fontSize,CCSizeMake(rateBg:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
					rateLb:setPosition(getCenterPoint(rateBg))
					rateBg:addChild(rateLb,1)
			    end
            end
           
            --中间方向箭头
            local directSp=CCSprite:createWithSpriteFrameName("leftBtnGreen.png")
            directSp:setAnchorPoint(ccp(0.5,0.5))
            directSp:setPosition(tvWidth/2,iconPosY)
            directSp:setFlipX(true)
            cell:addChild(directSp)

            for k=1,2,1 do
                local tankSp=tankVoApi:getTankIconSp(tankId)--CCSprite:createWithSpriteFrameName(tmpTankCfg.icon)
                local iconScale=iconWidth/tankSp:getContentSize().width
                tankSp:setPosition(tvWidth/2-120+(k-1)*240,iconPosY)
                tankSp:setScale(iconScale)
                cell:addChild(tankSp)

                local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("TeamTankNumBg.png",CCRect(15,15,1,1),function () end)
				numBg:setContentSize(CCSizeMake(iconWidth-20,36))
				numBg:setPosition(tankSp:getPositionX(),tankSp:getPositionY()-iconWidth/2-numBg:getContentSize().height/2)
				cell:addChild(numBg,2)

				local num=tankNum
				if k==1 then
					num=tankNum*cost/obtain
				end
				local numLb=GetTTFLabel(num,26)
				numLb:setPosition(getCenterPoint(numBg))
				numLb:setTag(2)
				numBg:addChild(numLb,3)
				if k==1 and tankVoApi:getTankCountByItemId(tankId)<num then
					numLb:setColor(G_ColorRed)
					canBuy=false
				end
				local tankNameLb=GetTTFLabelWrap(getlocal(tankCfg[tankId].name),22,CCSizeMake(22*8,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
				tankNameLb:setAnchorPoint(ccp(0.5,1))
				tankNameLb:setPosition(tankSp:getPositionX(),numBg:getPositionY()-numBg:getContentSize().height/2-5)
				cell:addChild(tankNameLb,2)
            end

            return cell
        elseif fn=="ccTouchBegan" then
            isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            isMoved=true
        elseif fn=="ccTouchEnded"  then

        end
    end
    local hd=LuaEventHandler:createHandler(tvCallBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth,tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition((self.bgSize.width-tvWidth)/2,tvBg:getPositionY()-tvHeight-5)
    self.bgLayer:addChild(self.tv,3)
    self.tv:setMaxDisToBottomOrTop(120)

    if oneKeyState~=nil then
    	local checkBox
		local uncheckBox
		local isCheck=oneKeyState
		local function selectAutoExchangeHandler()
			if isCheck==false then
				local function onConfirm()
	        		isCheck=true
	        		if checkBox then
						checkBox:setVisible(isCheck)
					end
		        end
		        if oneKeyConfirmHandler then
		        	oneKeyConfirmHandler(onConfirm)
		        end
			else
				local function onCancel()
	        		isCheck=false
					if checkBox then
						checkBox:setVisible(isCheck)
					end
	        	end
	        	if oneKeyCancelHandler then
	        		oneKeyCancelHandler(onCancel)
	        	end
			end
		end
		checkBox=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtn.png",selectAutoExchangeHandler)
		checkBox:setAnchorPoint(ccp(0.5,0.5))
		checkBox:setPosition(ccp(self.bgSize.width/2-90,120))
		checkBox:setVisible(isCheck)
		checkBox:setTouchPriority(-(self.layerNum-1)*20-3)
		self.bgLayer:addChild(checkBox,4)

		uncheckBox=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",selectAutoExchangeHandler)
		uncheckBox:setAnchorPoint(ccp(0.5,0.5))
		uncheckBox:setPosition(ccp(self.bgSize.width/2-90,checkBox:getPositionY()))
		uncheckBox:setTouchPriority(-(self.layerNum-1)*20-3)
		self.bgLayer:addChild(uncheckBox,3)

		local onKeyLb=GetTTFLabelWrap(getlocal("believer_troop_exchange_oneKey"),25,CCSizeMake(self.bgSize.width/2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		onKeyLb:setAnchorPoint(ccp(0,0.5))
		onKeyLb:setPosition(ccp(uncheckBox:getPositionX()+uncheckBox:getContentSize().width/2+10,checkBox:getPositionY()))
		self.bgLayer:addChild(onKeyLb)
    end
    
    local function okHandler()
        if canBuy==false then
        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("believer_exchange_lack1"),30)
        	do return end
        end
        if confirmHandler then
    		confirmHandler()
    	end
    	self:close()
    end
	G_createBotton(self.bgLayer,ccp(self.bgSize.width/2,50),{getlocal("confirm"),25},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",okHandler,0.8,-(self.layerNum-1)*20-3)

	local function touchLuaSpr()
    end
    local touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchLuaSpr)
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(250)
    touchDialogBg:setAnchorPoint(ccp(0.5,0.5))
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg)

	self:show()

	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(0,0)
	return self.dialogLayer
end

function believerTroopExchangeSmallDialog:dispose()
	
end

return believerTroopExchangeSmallDialog