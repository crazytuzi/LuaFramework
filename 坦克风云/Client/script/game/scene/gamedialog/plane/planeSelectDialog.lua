--选择装备的小板子
planeSelectDialog=smallDialog:new()

function planeSelectDialog:new(quality,dialogType,usedList,callback,canNotUseList,dtype,cid)
	local nc={}
	setmetatable(nc,self)
	self.__index=self	
	nc.dialogHeight=750
	nc.dialogWidth=550
	nc.quality=quality
	nc.type=dialogType		--1是进阶，不可堆叠，等级大于1的不显示，排序从低到高，2是出战，可堆叠，全显示，排序从高到低 		
	nc.usedList=usedList
	nc.callback=callback
	nc.canNotUseList=canNotUseList
	nc.dtype=dtype -- 领土争夺战（新加）
	self.cid=cid
	return nc
end

function planeSelectDialog:init(layerNum)
	local function onRefresh(event,data)		
		if self.tv then
			self:refreshPlaneList()
			self.tv:reloadData()
		end
	end
	self.refreshListener=onRefresh
	eventDispatcher:addEventListener("plane.data.refresh",self.refreshListener)
	self.layerNum=layerNum
	local size=CCSizeMake(self.dialogWidth,self.dialogHeight)
	local function nilFunc()
	end
	local function close()
		return self:close()
	end
	local dialogBg=G_getNewDialogBg(size,getlocal("plane_select"),30,nilFunc,layerNum,true,close)
	self.dialogLayer=CCLayer:create()
	--遮罩层
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(255)
	touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(touchDialogBg)

	local grayBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
	grayBgSp:setTouchPriority(-(layerNum-1)*20-1)
    grayBgSp:setAnchorPoint(ccp(0,0.5))
    grayBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth*0.2,G_VisibleSizeHeight*0.7))
    grayBgSp:setPosition(ccp(0,G_VisibleSizeHeight*0.5))
    self.dialogLayer:addChild(grayBgSp)  
    grayBgSp:setVisible(false)

    local grayBgSp2 = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
	grayBgSp2:setTouchPriority(-(layerNum-1)*20-1)
    grayBgSp2:setAnchorPoint(ccp(1,0.5))
    grayBgSp2:setContentSize(CCSizeMake(G_VisibleSizeWidth*0.2,G_VisibleSizeHeight*0.7))
    grayBgSp2:setPosition(ccp(G_VisibleSizeWidth,G_VisibleSizeHeight*0.5))
    self.dialogLayer:addChild(grayBgSp2)
    grayBgSp2:setVisible(false)


	self.bgLayer=dialogBg
	self.bgLayer:setContentSize(CCSizeMake(self.dialogWidth,self.dialogHeight))
	self.bgLayer:setIsSallow(false)
	self:show()
	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(self.bgLayer,2);
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-2)
	self.dialogLayer:setBSwallowsTouches(true);

	local forbidLayerUp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),nilFunc)
	forbidLayerUp:setTouchPriority(((-(self.layerNum-1)*20-4)))
	forbidLayerUp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight/2 - self.dialogHeight/2 + 100))
	forbidLayerUp:setAnchorPoint(ccp(0,1))
	forbidLayerUp:setPosition(0,G_VisibleSizeHeight)
	self.dialogLayer:addChild(forbidLayerUp)
	forbidLayerUp:setVisible(false)
	local forbidLayerDown=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),nilFunc)
	forbidLayerDown:setTouchPriority(((-(self.layerNum-1)*20-4)))
	forbidLayerDown:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight/2 - self.dialogHeight/2 + 110))
	forbidLayerDown:setAnchorPoint(ccp(0,0))
	forbidLayerDown:setPosition(0,0)
	self.dialogLayer:addChild(forbidLayerDown)
	forbidLayerDown:setVisible(false)

	-- local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),nilFunc)
	-- tvBg:setContentSize(CCSizeMake(self.dialogWidth - 40,self.dialogHeight - 200))
	-- tvBg:setAnchorPoint(ccp(0,0))
	-- tvBg:setPosition(20,110)
	-- dialogBg:addChild(tvBg)

	-- local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
	-- pointSp1:setPosition(ccp(2,tvBg:getContentSize().height/2))
	-- tvBg:addChild(pointSp1)
	-- local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
	-- pointSp2:setPosition(ccp(tvBg:getContentSize().width-2,tvBg:getContentSize().height/2))
	-- tvBg:addChild(pointSp2)
	
	local mLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png",CCRect(34,1,1,1),function ()end)
	mLine:setPosition(ccp(5,120))
	-- mLine:setScaleX((self.dialogWidth-40)/mLine:getContentSize().width)
	mLine:setContentSize(CCSizeMake(self.dialogWidth-10,mLine:getContentSize().height))
	mLine:setAnchorPoint(ccp(0,0.5))
	dialogBg:addChild(mLine)
	
	self:refreshPlaneList()

	self.selectedID=nil
	self.selectedSp=nil
	local function callback(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.dialogWidth - 50,self.dialogHeight - 210),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(ccp(25,115))
	self.bgLayer:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(80)

	local function onConfirm()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
		if(self.selectedID==nil)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("plane_set_troops_prompt"),30)
			do return end
		end
		if(self.callback)then
			self.callback(self.selectedID)
		end
		self:close()
	end
	local scale=0.8
	local confirmItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",onConfirm,nil,getlocal("confirm"),25/scale)
	confirmItem:setScale(scale)
	local confirmBtn=CCMenu:createWithItem(confirmItem)
	confirmBtn:setTouchPriority(((-(self.layerNum-1)*20-5)))
	confirmBtn:setPosition(self.dialogWidth - 150,60)
	self.bgLayer:addChild(confirmBtn)
	local function onCancel()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:close()
	end
	local cancelItem=GetButtonItem("newGrayBtn.png","newGrayBtn_Down.png","newGrayBtn_Down.png",onCancel,nil,getlocal("cancel"),25/scale)
	cancelItem:setScale(scale)
	local cancelBtn=CCMenu:createWithItem(cancelItem)
	cancelBtn:setTouchPriority(((-(self.layerNum-1)*20-5)))
	cancelBtn:setPosition(150,60)
	self.bgLayer:addChild(cancelBtn)

	sceneGame:addChild(self.dialogLayer,layerNum)
	self.dialogLayer:setPosition(ccp(0,0))
	local noPlaneLb=GetTTFLabelWrap(getlocal("plane_no_equip_prompt"),25,CCSizeMake(self.dialogWidth - 60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	noPlaneLb:setPosition(self.dialogWidth/2,self.dialogHeight/2+30)
	self.bgLayer:addChild(noPlaneLb)
	self.noPlaneLb=noPlaneLb
	if(#self.planeList==0)then
		self.noPlaneLb:setVisible(true)
	else
		self.noPlaneLb:setVisible(false)
	end

	return self.dialogLayer
end

function planeSelectDialog:refreshPlaneList()
	self.planeList={}
	
	local list
	if self.dtype and (self.dtype==35 or self.dtype==36) then
		list=G_clone(ltzdzFightApi:getCanBattlePlane())
	else
		list=G_clone(planeVoApi:getPlaneList())
	end
	
	-- G_dayin(list)
	-- G_dayin(self.canNotUseList)
	local tmpTb={}
	if self.canNotUseList then
		for k,v in pairs(self.canNotUseList) do
			if v then
				tmpTb[v]=1
			end
		end
	end
	for k,v in pairs(list) do
		local flag
		if self.dtype and (self.dtype==35 or self.dtype==36) then
			flag=ltzdzFightApi:planeIsCanBattle(self.dtype,k,self.cid)
		else
			flag=planeVoApi:getIsBattleEquip(k)
		end
		if flag==true then
		elseif v and v.idx then
			if tmpTb and tmpTb[v.idx]==1 then
			else
				table.insert(self.planeList,v)
			end
		end
	end
	
	if #self.planeList>1 then
		local function sortFunc(a,b)
			local strength1=a:getStrength()
			local strength2=b:getStrength()
			return strength1>strength2
		end
		table.sort(self.planeList,sortFunc)
	end
	

	self.cellNum=math.max(math.ceil((#self.planeList)/2),1)
	if self.noPlaneLb then
		if(#self.planeList==0)then
			self.noPlaneLb:setVisible(true)
		else
			self.noPlaneLb:setVisible(false)
		end
	end
end

function planeSelectDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return self.cellNum
	elseif fn=="tableCellSizeForIndex" then
		return  CCSizeMake(self.dialogWidth - 50,270)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local startIndex=idx*2
		local bgWidth=(self.dialogWidth - 50)/2
		for i=1,2 do
			local planeVo=self.planeList[startIndex + i]
			if(planeVo)then
				local planeSp
				local function showSelectSp(targetSp)
					if targetSp==nil then
						do return end
					end
					self.selectedSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(3,3,4,4),function ( ... )end)
					self.selectedSp:setTag(999)
					self.selectedSp:setContentSize(targetSp:getContentSize())
					self.selectedSp:setOpacity(120)
					self.selectedSp:setPosition(getCenterPoint(targetSp))
					local icon=CCSprite:createWithSpriteFrameName("7daysCheckmark.png")
					icon:setPosition(getCenterPoint(self.selectedSp))
					self.selectedSp:addChild(icon)
					targetSp:addChild(self.selectedSp)
				end
				local function onSelected()
					if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
						if planeSp==nil then
							do return end
						end
						if(self.selectedSp)then
							self.selectedSp:removeFromParentAndCleanup(true)
							self.selectedSp=nil
						end
						if self.selectedID~=planeVo.idx then
							showSelectSp(planeSp)
							self.selectedID=planeVo.idx
						else
							self.selectedID=nil
						end
					end
				end

				local showItemCfg=planeVo.cfg
				local strong=planeVo:getStrength()
				planeSp=planeVoApi:getPlaneIcon(planeVo.pid,strong,onSelected)
				planeSp:setTouchPriority(-(self.layerNum-1)*20-2)
				planeSp:setAnchorPoint(ccp(0.5,0))
				planeSp:setPosition(ccp(bgWidth/2 + (i - 1)*bgWidth,0))
				cell:addChild(planeSp)
				if self.selectedID and self.selectedID==planeVo.idx then
					self.selectedSp=nil
					showSelectSp(planeSp)
				end

				local function showInfo()
					local selectedSp=planeSp:getChildByTag(999)
					if(selectedSp)then
						do return end
					end
					planeVoApi:showPlaneInfoDialog(planeVo,self.layerNum+1,nil,self.dtype)
				end
				local infoBtn=LuaCCSprite:createWithSpriteFrameName("i_sq_Icon1.png",showInfo)
				infoBtn:setTouchPriority(-(self.layerNum-1)*20-3)
				infoBtn:setScale(0.8)
				infoBtn:setPosition(ccp(planeSp:getContentSize().width - 30,planeSp:getContentSize().height - 30))
				planeSp:addChild(infoBtn)
			end
		end
		return cell
	elseif fn=="ccTouchBegan" then
	   self.isMoved=false
	   return true
   elseif fn=="ccTouchMoved" then
		self.isMoved=true
   elseif fn=="ccTouchEnded" then	   
   end
end

function planeSelectDialog:dispose()
	eventDispatcher:removeEventListener("plane.data.refresh",self.refreshListener)
	self.refreshListener=nil
	self.noPlaneLb=nil
end