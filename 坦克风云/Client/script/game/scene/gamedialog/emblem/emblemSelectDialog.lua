--选择装备的小板子
emblemSelectDialog=smallDialog:new()

function emblemSelectDialog:new(quality,dialogType,usedList,callback,dtype,cid)
	local nc={}
	setmetatable(nc,self)
	self.__index=self	
	nc.dialogHeight=750
	nc.dialogWidth=550
	nc.quality=quality
	nc.type=dialogType		--1是进阶，不可堆叠，等级大于1的不显示，排序从低到高，2是出战，可堆叠，全显示，排序从高到低 		
	nc.usedList=usedList
	nc.callback=callback
	nc.dtype=dtype
	nc.cid=cid
	return nc
end

function emblemSelectDialog:init(layerNum)
	self.layerNum=layerNum
	local function nilFunc()
	end
	local function close()
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end
	local dialogBg = G_getNewDialogBg(CCSizeMake(self.dialogWidth,self.dialogHeight),getlocal("emblem_select"),30,nilFunc,layerNum,true,close)
	--LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168,86,10,10),nilFunc)
	self.dialogLayer=CCLayer:create()	
	--遮罩层
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(255)
	touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(touchDialogBg)

	local grayBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),function ()end)
	grayBgSp:setTouchPriority(-(layerNum-1)*20-1)
    grayBgSp:setAnchorPoint(ccp(0,0.5))
    grayBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth*0.2,G_VisibleSizeHeight*0.7))
    grayBgSp:setPosition(ccp(0,G_VisibleSizeHeight*0.5))
    self.dialogLayer:addChild(grayBgSp)
    grayBgSp:setVisible(false)  

    local grayBgSp2 = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),function ()end)
	grayBgSp2:setTouchPriority(-(layerNum-1)*20-1)
    grayBgSp2:setAnchorPoint(ccp(1,0.5))
    grayBgSp2:setContentSize(CCSizeMake(G_VisibleSizeWidth*0.2,G_VisibleSizeHeight*0.7))
    grayBgSp2:setPosition(ccp(G_VisibleSizeWidth,G_VisibleSizeHeight*0.5))
    self.dialogLayer:addChild(grayBgSp2) 
    grayBgSp2:setVisible(false)  

	self.bgLayer=dialogBg
	-- self.bgLayer:setContentSize(CCSizeMake(self.dialogWidth,self.dialogHeight))
	self.bgLayer:setIsSallow(false)
	self:show()
	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(self.bgLayer,2);
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-2)
	self.dialogLayer:setBSwallowsTouches(true);

	
	-- local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
	-- closeBtnItem:setPosition(0,0)
	-- closeBtnItem:setAnchorPoint(CCPointMake(0,0))
	-- self.closeBtn = CCMenu:createWithItem(closeBtnItem)
	-- self.closeBtn:setTouchPriority(-(layerNum-1)*20-5)
	-- self.closeBtn:setPosition(ccp(self.dialogWidth-closeBtnItem:getContentSize().width,self.dialogHeight-closeBtnItem:getContentSize().height))
	-- dialogBg:addChild(self.closeBtn)

	-- local titleLb=GetTTFLabel(getlocal("emblem_select"),30)
	-- titleLb:setAnchorPoint(ccp(0.5,0.5))
	-- titleLb:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-titleLb:getContentSize().height/2-30))
	-- dialogBg:addChild(titleLb)

	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
	spriteController:addPlist("public/emblem/emblemImage.plist")
	spriteController:addTexture("public/emblem/emblemImage.png")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

	local forbidLayerUp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),nilFunc)
	forbidLayerUp:setTouchPriority(((-(self.layerNum-1)*20-4)))
	forbidLayerUp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight/2 - self.dialogHeight/2 + 70))
	forbidLayerUp:setAnchorPoint(ccp(0,1))
	forbidLayerUp:setPosition(0,G_VisibleSizeHeight)
	self.dialogLayer:addChild(forbidLayerUp,5)
	forbidLayerUp:setVisible(false)
	local forbidLayerDown=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),nilFunc)
	forbidLayerDown:setTouchPriority(((-(self.layerNum-1)*20-4)))
	forbidLayerDown:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight/2 - self.dialogHeight/2 + 110))
	forbidLayerDown:setAnchorPoint(ccp(0,0))
	forbidLayerDown:setPosition(0,0)
	self.dialogLayer:addChild(forbidLayerDown,5)
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

	self.emblemList={}
	self.selectedID=nil
	self.selectedSp=nil

	local equipList
	if self.dtype and (self.dtype==35 or self.dtype==36) then
		equipList=ltzdzFightApi:getCanBattleEmblem()
	else
		if self.type==2 then --出战用
			equipList=emblemVoApi:getEquipListForBattle(self.dtype)
		else
			equipList=emblemVoApi:getEquipList()
		end
	end

	for k,v in pairs(equipList) do
		if emblemTroopVoApi:checkIfIsEmblemTroopById(v.id)==true then --如果是军徽部队处理方式
			if self.dtype==35 or self.dtype==36 then --领土争夺战处理
				if ltzdzFightApi:checkEquipCanUse(self.dtype,v.id,self.cid,v.num)==true then
					table.insert(self.emblemList,v)
				end
			else
				if emblemVoApi:checkEquipCanUse(self.dtype,v.id)==true then
					table.insert(self.emblemList,v)
				end
			end
		else
			local usableNum
			if self.dtype and (self.dtype==35 or self.dtype==36) then
				local hasNum=ltzdzFightApi:getBattleNumById(v.id,self.cid)
				usableNum=v.num-hasNum
			else
				-- usableNum=v:getUsableNum()
				usableNum=v.num-emblemVoApi:getBattleNumById(v.id)
			end
			local usedNum=0
			if(self.usedList and self.usedList[v.id])then
				usedNum=self.usedList[v.id]
			end
			usableNum=usableNum - usedNum
			--etype==2的是放在家就可以生效的军徽，在选择出征的时候不出现
			if(self.type==2 and v.cfg.etype==2)then
				usableNum=0
			--进阶的时候不选择等级大于1的
			elseif(self.type==1 and v.cfg.lv and v.cfg.lv>0)then
				usableNum=0
			end
			if(usableNum>0)then
				if((self.quality and self.quality~=0 and v.cfg.color==self.quality) or self.quality==nil or self.quality==0)then
					if(self.type==1)then
						for i=1,usableNum do
							local eVo=emblemVo:new(v.cfg)
							eVo:initWithData(v.id,1)
							table.insert(self.emblemList,eVo)
						end
					else
						local cloneData=G_clone(v)
						cloneData.num=cloneData.num - usedNum
						table.insert(self.emblemList,v)
					end
				end
			end
		end
	end
	local function callback(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.dialogWidth - 50,self.dialogHeight - 185),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(ccp(25,115))
	self.bgLayer:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(80)

	local function onConfirm()
		if(self.selectedID==nil)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("emblem_set_troops_prompt"),30)
			do return end
		end
		if(self.callback)then
			self.callback(self.selectedID)
		end
		self:close()
	end
	local confirmItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onConfirm,nil,getlocal("confirm"),25)
	confirmItem:setScale(0.8)
	local confirmBtn=CCMenu:createWithItem(confirmItem)
	confirmBtn:setTouchPriority(((-(self.layerNum-1)*20-5)))
	confirmBtn:setPosition(self.dialogWidth - 150,60)
	self.bgLayer:addChild(confirmBtn)
	local cancelItem=GetButtonItem("newGrayBtn.png","newGrayBtn_Down.png","newGrayBtn.png",close,nil,getlocal("cancel"),25)
	cancelItem:setScale(0.8)
	local cancelBtn=CCMenu:createWithItem(cancelItem)
	cancelBtn:setTouchPriority(((-(self.layerNum-1)*20-5)))
	cancelBtn:setPosition(150,60)
	self.bgLayer:addChild(cancelBtn)

	sceneGame:addChild(self.dialogLayer,layerNum)
	self.dialogLayer:setPosition(ccp(0,0))
	return self.dialogLayer
end

function emblemSelectDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return math.max(math.ceil((#self.emblemList)/3),1)
	elseif fn=="tableCellSizeForIndex" then
		return  CCSizeMake(self.dialogWidth - 50,190)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local startIndex=idx*3
		local bgWidth=(self.dialogWidth - 100)/3
		for i=1,3 do
			local eVo=self.emblemList[startIndex + i]
			if(eVo)then
				local emblemIcon
				local function onSelected()
					if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
						if(self.selectedSp)then
							self.selectedSp:removeFromParentAndCleanup(true)
							self.selectedSp=nil
						end
						if self.selectedID~=eVo.id then
							self.selectedID=eVo.id
							self.selectedSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(3,3,4,4),function ( ... )end)
							self.selectedSp:setTag(999)
							self.selectedSp:setContentSize(CCSizeMake(190,238))
							self.selectedSp:setOpacity(120)
							self.selectedSp:setPosition(95,119)
							local icon=CCSprite:createWithSpriteFrameName("7daysCheckmark.png")
							icon:setPosition(getCenterPoint(self.selectedSp))
							self.selectedSp:addChild(icon)
							emblemIcon:addChild(self.selectedSp)
						else
							self.selectedID=nil
						end
					end
				end
				if emblemTroopVoApi:checkIfIsEmblemTroopById(eVo.id)==true then --军徽部队显示
					emblemIcon=emblemVoApi:getEquipIcon(eVo.id,onSelected,startIndex + i,nil,nil,nil,nil,eVo)
				else
					local showItemCfg=eVo.cfg
					local num
					if(self.type==2)then
						num=eVo.num
					end
					emblemIcon=emblemVoApi:getEquipIcon(eVo.id,onSelected,startIndex + i,num,showItemCfg.qiangdu)
				end

				emblemIcon:setTouchPriority(-(self.layerNum-1)*20-2)
				emblemIcon:setScale(bgWidth/emblemIcon:getContentSize().width)
				emblemIcon:setAnchorPoint(ccp(0.5,0))
				emblemIcon:setPosition(ccp(15 + bgWidth/2 + (i - 1)*(bgWidth + 10),0))
				local function showInfo()
					local selectedSp=emblemIcon:getChildByTag(999)
					if(selectedSp)then
						do return end
					end
					local data=G_clone(eVo)
					data.num=0
					emblemVoApi:showInfoDialog(data,self.layerNum + 1)
				end
				local infoBtn = LuaCCSprite:createWithSpriteFrameName("i_sq_Icon1.png",showInfo)--BtnInfor
				infoBtn:setTouchPriority(-(self.layerNum-1)*20-3)
				infoBtn:setScale(1)
				infoBtn:setPosition(ccp(emblemIcon:getContentSize().width - 30,emblemIcon:getContentSize().height - 30))
				emblemIcon:addChild(infoBtn)
				cell:addChild(emblemIcon)
			end
		end
		if(#self.emblemList==0)then
			local noEmblemLb=GetTTFLabelWrap(getlocal("emblem_no_equip_prompt"),25,CCSizeMake(self.dialogWidth - 60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			noEmblemLb:setPosition((self.dialogWidth - 50)/2,0)
			cell:addChild(noEmblemLb)
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

function emblemSelectDialog:dispose()
	spriteController:removePlist("public/emblem/emblemImage.plist")
	spriteController:removeTexture("public/emblem/emblemImage.png")
end