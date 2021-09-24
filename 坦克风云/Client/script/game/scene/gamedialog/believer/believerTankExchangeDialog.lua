local believerTankExchangeDialog=commonDialog:new()

function believerTankExchangeDialog:new(parent)
	local nc={
		parent=parent,
	}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function believerTankExchangeDialog:doUserHandler()
	self.panelLineBg:setVisible(false)
    spriteController:addPlist("public/squaredImgs.plist")
  	spriteController:addTexture("public/squaredImgs.png")

	self.believerCfg=believerVoApi:getBelieverCfg()
	self.myTroopsPool=believerVoApi:getTroopsPool()
	self.cellNum=SizeOfTable(self.myTroopsPool)
	if self.cellNum%3>0 then
		self.cellNum=math.floor(self.cellNum/3)+1
	else
		self.cellNum=self.cellNum/3
	end
	self.lockTankTb={}

	local titleBg=CCSprite:createWithSpriteFrameName("believerTitleBg.png")
	titleBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-125)
	self.bgLayer:addChild(titleBg,1)

	local segment=believerVoApi:getMySegment()
	local segNameStr=believerVoApi:getSegmentName(segment)
	local segmentStr=getlocal("believer_seg",{segNameStr})
	local segmentLb=GetTTFLabelWrap(segmentStr,25,CCSizeMake(G_VisibleSizeWidth-200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,nil,true)
	segmentLb:setPosition(getCenterPoint(titleBg))
	titleBg:addChild(segmentLb)

	local function touchTip()
        believerVoApi:showActiveTankDialog(self.layerNum+1)
	end
	G_addMenuInfo(self.bgLayer,self.layerNum,ccp(G_VisibleSizeWidth-60,titleBg:getPositionY()),{},nil,nil,28,touchTip,true)

    --兑换记录
    local function exchangeReportHandler()
    	local function callBack()
    		believerVoApi:showTroopExchangeRecordDialog(self.layerNum+1)
    	end
        believerVoApi:troopsExchangeRecordHttpRequest(callBack)
    end
    local reportItem,reportMenu=G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth-100,60),{getlocal("believer_exchange_report"),25},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",exchangeReportHandler,0.8,-(self.layerNum-1)*20-4)

	local tipLb=GetTTFLabelWrap(getlocal("believer_exchange_tip"),25,CCSizeMake(G_VisibleSizeWidth-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	tipLb:setAnchorPoint(ccp(0,0.5))
	tipLb:setPosition(12,60)
	tipLb:setColor(G_ColorRed)
	self.bgLayer:addChild(tipLb)
end

function believerTankExchangeDialog:initTableView()
	self.tvWidth,self.tvHeight,self.cellHeight=616,G_VisibleSizeHeight-300,250
	local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
	tvBg:setAnchorPoint(ccp(0.5,1))
    tvBg:setContentSize(CCSizeMake(self.tvWidth,self.tvHeight+10))
    tvBg:setPosition(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight-180)
    self.bgLayer:addChild(tvBg)

	local function callBack(...)
       return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.tv:setPosition((G_VisibleSizeWidth-self.tvWidth)/2,tvBg:getPositionY()-self.tvHeight-5)
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(10)
end

function believerTankExchangeDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
        return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(self.tvWidth,self.cellHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        if self.myTroopsPool==nil then
        	do return cell end
        end

        local iconWidth,spaceW=150,40
        local firstPosX=(self.tvWidth-3*iconWidth-2*spaceW)/2
        for i=1,3 do
        	local index=idx*3+i
        	local tank=self.myTroopsPool[index]
        	if tank==nil then
        		do break end
        	end
        	local tankId,tankNum=tank[1],tank[2]
			local tankSp=tankVoApi:getTankIconSp(tankId)--CCSprite:createWithSpriteFrameName(tankCfg[tankId].icon)
			tankSp:setAnchorPoint(ccp(0.5,0.5))
			tankSp:setScale(iconWidth/tankSp:getContentSize().width)
			tankSp:setPosition(firstPosX+iconWidth*0.5+(i-1)*(iconWidth+spaceW),self.cellHeight-iconWidth/2-10)
			tankSp:setTag(tankId)
			cell:addChild(tankSp,2)
			if tankId~=G_pickedList(tankId) then
				local pickedIcon=CCSprite:createWithSpriteFrameName("picked_icon1.png")
				tankSp:addChild(pickedIcon)
				pickedIcon:setPosition(tankSp:getContentSize().width*0.7,tankSp:getContentSize().height*0.5-20)
			end
			local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("TeamTankNumBg.png",CCRect(15,15,1,1),function () end)
			numBg:setContentSize(CCSizeMake(130,36))
			numBg:setPosition(tankSp:getPositionX(),tankSp:getPositionY()-iconWidth/2-numBg:getContentSize().height/2)
			numBg:setTag(1000+index)
			cell:addChild(numBg,2)

			local numLb=GetTTFLabel(tankNum,26)
			numLb:setPosition(getCenterPoint(numBg))
			numLb:setTag(2)
			numBg:addChild(numLb)
            local believerCfg=believerVoApi:getBelieverCfg()		
			if tankNum<believerCfg.troopsNum then
				numLb:setColor(G_ColorRed)
			end

			local tankNameLb=GetTTFLabelWrap(getlocal(tankCfg[tankId].name),24,CCSizeMake(24*8,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
			tankNameLb:setAnchorPoint(ccp(0.5,1))
			tankNameLb:setPosition(tankSp:getPositionX(),numBg:getPositionY()-numBg:getContentSize().height/2-5)
			cell:addChild(tankNameLb,2)

			local function showInfoHandler(hd,fn,idx)
				if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
					if self.tv:getIsScrolled()==true then
						do
						    return
						end
					end
					if G_checkClickEnable()==false then
						do
						    return
						end
					else
						base.setWaitTime=G_getCurDeviceMillTime()
					end
					PlayEffect(audioCfg.mouseClick)
					local id=G_pickedList(tankId)
                    tankInfoDialog:create(self.bgLayer,tonumber(id),self.layerNum+1,true,nil,nil,true)
				end
			end
			local tipItem=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",showInfoHandler,nil,nil,nil)
			local spScale=0.7
			tipItem:setScale(spScale)
			local tipMenu=CCMenu:createWithItem(tipItem)
			tipMenu:setPosition(tipItem:getContentSize().width/2*spScale+10,iconWidth-tipItem:getContentSize().width/2*spScale-10)
			tipMenu:setTouchPriority(-(self.layerNum-1)*20-3)
			tankSp:addChild(tipMenu,5)

			local function exchange(object,name,tag)
				if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
			        if self.lockTankTb[tag]==true then
		                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("killRace_troop_grade_lock"),28)
		                do return end
		            end
		            local believerCfg=believerVoApi:getBelieverCfg()
					local function exchangeTroops()
                        local costNum=believerVoApi:getTroopExchangeCostNum(1)
                        local tankNum=tankVoApi:getTankCountByItemId(tankId)
                        if tankNum<costNum then --部队数量不足
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("believer_exchange_lack",{getlocal(tankCfg[tag].name)}),28)
                            do return end
                        end
                       	local function exchangeHandler()
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("believer_exchange_ok",{believerCfg.troopsNum,getlocal(tankCfg[tag].name)}),28)
                            self:refresh()
                        end
                        local list={{"a"..tankId,costNum}}
                        believerVoApi:believerExchange(list,exchangeHandler)
                    end
					local exchangeList={{"a"..tag,believerCfg.troopsNum}}
             		local cost,num,exchangeNum=believerVoApi:getTroopExchangeCostNum(1),believerCfg.troopsNum
					local exchangeNum=believerVoApi:getDayExchangeNum()+1
                    local exchangeRateTb={{cost,num,exchangeNum}}
                    local isAutoCheck=believerVoApi:checkAutoExchange()
                    local function oneKeyConfirmHandler(callback)
                        local function onConfirm()
                            believerVoApi:requestAutoExchange(1,callback)
                        end
                        G_showSecondConfirm(self.layerNum+2,true,true,getlocal("dialog_title_prompt"),getlocal("believer_troop_exchange_oneKey_desc"),true,onConfirm)
                    end
                    local function oneKeyCancelHandler(callback)
                        believerVoApi:requestAutoExchange(0,callback)
                    end
					believerVoApi:showTroopExchangeSmallDialog(exchangeList,exchangeRateTb,true,self.layerNum+1,exchangeTroops,isAutoCheck,oneKeyConfirmHandler,oneKeyCancelHandler)
				end
			end
			if tank[3]~=true then --坦克未限制
				local addBtnSp=LuaCCSprite:createWithSpriteFrameName("believerAddBtn.png",exchange)
	            addBtnSp:setTouchPriority(-(self.layerNum-1)*20-3)
	            addBtnSp:setTag(tankId)
	            addBtnSp:setPosition(iconWidth-addBtnSp:getContentSize().width/2-10,addBtnSp:getContentSize().height/2+10)
	            tankSp:addChild(addBtnSp,1)
	            local curNum=tankVoApi:getTankCountByItemId(tankId)
	            local costNum=believerVoApi:getTroopExchangeCostNum(1)
            	if curNum<costNum then
					addBtnSp:setColor(G_ColorRed)
				else
					addBtnSp:setColor(G_ColorGreen)
				end
	            --忽隐忽现
	            local fade1=CCFadeTo:create(1,55)
	            local fade2=CCFadeTo:create(1,255)
	            local seq=CCSequence:createWithTwoActions(fade1,fade2)
	            local repeatEver=CCRepeatForever:create(seq)
	            addBtnSp:runAction(repeatEver)
	        else
	        	self.lockTankTb[tankId]=true
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

function believerTankExchangeDialog:refresh()
	if self.tv then
		self.myTroopsPool=believerVoApi:getTroopsPool()
		local recordPoint=self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
	end
end

function believerTankExchangeDialog:tick()
	
end

function believerTankExchangeDialog:dispose()
	self.myTroopsPool=nil
	self.cellNum=nil
    if self.parent and self.parent.backToMainDialogHandler then
        self.parent:backToMainDialogHandler()
        self.parent=nil
    end
    spriteController:removePlist("public/squaredImgs.plist")
  	spriteController:removeTexture("public/squaredImgs.png")
end

return believerTankExchangeDialog