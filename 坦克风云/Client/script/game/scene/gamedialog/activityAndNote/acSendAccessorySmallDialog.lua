acSendAccessorySmallDialog=smallDialog:new()

--param type: 面板类型, 1是自己, 2是玩家, 3是矿点
--param data: 数据, 坐标 ID等
function acSendAccessorySmallDialog:new(layerNum,selectFriendTb)
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.layerNum=layerNum
	self.cellHeight=72
	self.selectFriendTb=selectFriendTb
	self.selectVo = nil
	self.duiSpTb={}
	return nc
end

function acSendAccessorySmallDialog:init()
	self.dialogWidth=G_VisibleSizeWidth-60
	self.dialogHeight=G_VisibleSizeHeight-200
	self.isTouch=nil
	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),nilFunc)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer:setContentSize(self.bgSize)
	self:show()
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)
	local function close()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end
	local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
	closeBtnItem:setPosition(0,0)
	closeBtnItem:setAnchorPoint(CCPointMake(0,0))
	self.closeBtn = CCMenu:createWithItem(closeBtnItem)
	self.closeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.closeBtn:setPosition(ccp(self.dialogWidth-closeBtnItem:getContentSize().width,self.dialogHeight-closeBtnItem:getContentSize().height))
	dialogBg:addChild(self.closeBtn)

	local titleStr=getlocal("activity_peijianhuzeng_selectAccessory")
	local titleLb=GetTTFLabel(titleStr,30)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-titleLb:getContentSize().height-5))
	dialogBg:addChild(titleLb,1)

	self.aData= accessoryVoApi:getAccesoryWithoutJiagong()
	if(self.aData==nil)then
		self.aData={}
	end
	self.gridWidth=(self.bgLayer:getContentSize().width-70)/4-20
	
	self:initBg()

	local function callBack(...)
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.dialogWidth-40,self.dialogBg:getContentSize().height-210),nil)
	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(ccp(30,80))
	self.dialogBg:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(80)

	local lbSize=25
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
        lbSize =32
    end
    self.noLb=GetTTFLabelWrap(getlocal("activity_peijianhuzeng_accessory_tip4"),lbSize,CCSizeMake(self.bgLayer:getContentSize().width*0.8,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	-- self.noLb=GetTTFLabel(getlocal("activity_peijianhuzeng_accessory_tip4"),32)
	self.noLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2))
	self.noLb:setColor(G_ColorGray)
	self.bgLayer:addChild(self.noLb,5)
	local num = SizeOfTable(self.aData)
	if num==0 then
		self.noLb:setVisible(true)
	else
		self.noLb:setVisible(false)
	end

	local function nilFunc()
	end
	
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(0,0))
	self.dialogLayer:addChild(touchDialogBg)

	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(getCenterPoint(sceneGame))
	return self.dialogLayer
end

function acSendAccessorySmallDialog:eventHandler(handler,fn,idx,cel)
	 if fn=="numberOfCellsInTableView" then
		return math.ceil(SizeOfTable(self.aData)/4)
   elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-30,self.gridWidth+10)
		return  tmpSize
   elseif fn=="tableCellAtIndex" then
	
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local rect = CCRect(0, 0, 50, 50);
		local capInSet = CCRect(40, 40, 10, 10);
		local capInSetNew=CCRect(20, 20, 10, 10)

		local icon
		for i=1,4 do
			local icon
			local tmpData=self.aData[idx*4+i]
			if(tmpData~=nil)then
				local function onClickAccessory(object,fn,tag)
					if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
					    if G_checkClickEnable()==false then
					        do
					            return
					        end
					    else
					        base.setWaitTime=G_getCurDeviceMillTime()
					    end
					    PlayEffect(audioCfg.mouseClick)
					    self.selectVo=tmpData
					
				    	local x,y = icon:getPosition()
				    	if self.duiSpTb[idx+1] then
				    		self.duiSpTb[idx+1]:setPosition(x+icon:getContentSize().width-10,y+25)
				    	end
				    	self:CheckVisible(idx+1)
				    	
					   

					end
				end
				icon=accessoryVoApi:getAccessoryIcon(tmpData.type,70,self.gridWidth,onClickAccessory)
				icon:setTag(1000+idx*4+i)
				local rankTip=CCSprite:createWithSpriteFrameName("IconLevel.png")
				local rankLb=GetTTFLabel(tmpData.rank,30)
				rankLb:setPosition(ccp(rankTip:getContentSize().width/2,rankTip:getContentSize().height/2))
				rankTip:addChild(rankLb)
				rankTip:setScale(0.5)
				rankTip:setAnchorPoint(ccp(0,1))
				rankTip:setPosition(ccp(0,icon:getContentSize().height))
				icon:addChild(rankTip)

				local lvLb=GetTTFLabel("Lv. "..tmpData.lv,15)
				lvLb:setAnchorPoint(ccp(1,0))
				lvLb:setPosition(ccp(icon:getContentSize().width-10,5))
				icon:addChild(lvLb)
				icon:setTouchPriority(-(self.layerNum-1)*20-2)

				icon:setAnchorPoint(ccp(0,0))
				icon:setPosition(ccp((i-1)*(self.gridWidth+10)+25,5))
				cell:addChild(icon)
			-- else
			-- 	icon=CCSprite:createWithSpriteFrameName("Icon_BG.png")
			-- 	icon:setScale(self.gridWidth/icon:getContentSize().width)
			end
			-- icon:setAnchorPoint(ccp(0,0))
			-- icon:setPosition(ccp((i-1)*(self.gridWidth+10)+10,5))
			-- cell:addChild(icon)
		end

		local duiSp=CCSprite:createWithSpriteFrameName("IconCheck.png")
    	cell:addChild(duiSp,2)
    	self.duiSpTb[idx+1]=duiSp
    	duiSp:setVisible(false)
		

		return cell
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end

function acSendAccessorySmallDialog:CheckVisible(idx)
	for k,v in pairs(self.duiSpTb) do
		if idx==k then
			v:setVisible(true)
		else
			v:setVisible(false)
		end
	end
end

function acSendAccessorySmallDialog:initBg()
	local size = CCSizeMake(self.dialogWidth-10,self.dialogHeight-40)
	local function tmpFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),tmpFunc)
	dialogBg:setContentSize(size)
	dialogBg:setPosition(self.dialogWidth/2, (self.dialogHeight-100)/2+20)
	self.bgLayer:addChild(dialogBg)
	self.dialogBg=dialogBg
	dialogBg:setOpacity(0)

	local function touchSelectItem()
	    if G_checkClickEnable()==false then
	        do
	            return
	        end
	    else
	        base.setWaitTime=G_getCurDeviceMillTime()
	    end
		PlayEffect(audioCfg.mouseClick)
		if self.selectVo then

			local accessoryName = getlocal(self.selectVo:getConfigData("name"))
			local friendName = self.selectFriendTb.nickname

			local function callback()
				local function sendAccessory(fn,data)
					-- local ret,sData = base:checkServerData(data)
					-- if ret==true then
						-- accessoryVoApi:sendAccessory(sData)
						smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_peijianhuzeng_accessory_tip2",{accessoryName,1}),30)
						self:close()
						activityAndNoteDialog:closeAllDialog()
					-- end
					
				end
				 accessoryVoApi:sendAccessory(self.selectFriendTb.uid,self.selectVo.id,sendAccessory)
			end
			allianceSmallDialog:showOKDialog(callback,getlocal("activity_peijianhuzeng_send_ok",{accessoryName,friendName}),self.layerNum+1)
		else
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_peijianhuzeng_accessory_tip3"),30)
		end
			
		
	end
	local sendItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",touchSelectItem,nil,getlocal("rechargeGifts_giveLabel"),25)
   sendItem:setAnchorPoint(ccp(0.5,0.5))
   -- sendItem:setScale(0.8)
   local sendBtn=CCMenu:createWithItem(sendItem);
   sendBtn:setTouchPriority(-(self.layerNum-1)*20-4);
   sendBtn:setPosition(ccp(self.dialogBg:getContentSize().width/2,60))
   self.dialogBg:addChild(sendBtn,2)

	local tipLb=GetTTFLabelWrap(getlocal("activity_peijianhuzeng_accessory_tip"),22,CCSizeMake(dialogBg:getContentSize().width-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	tipLb:setAnchorPoint(ccp(0,1))
	tipLb:setColor(G_ColorRed)
	tipLb:setPosition(ccp(30,dialogBg:getContentSize().height-40))
	dialogBg:addChild(tipLb)

   local num = SizeOfTable(self.aData)
	if num==0 then
		sendItem:setVisible(false)
	else
		sendItem:setVisible(true)
	end


end

function acSendAccessorySmallDialog:dispose()
	self.noLb=nil
	self.dialogBg=nil
	self.aData=nil
	self.gridWidth=nil
	self.selectId=nil

end


