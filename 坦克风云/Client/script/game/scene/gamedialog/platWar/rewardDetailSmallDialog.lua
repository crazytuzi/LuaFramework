rewardDetailSmallDialog=smallDialog:new()

function rewardDetailSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.dialogWidth=600
	self.dialogHeight=800
	
	self.cellWidth=self.dialogWidth-40
	self.cellHeight=270

	return nc
end

function rewardDetailSmallDialog:init(layerNum,type)
	self.layerNum=layerNum
	self.type=type

	local function nilFunc()
	end

	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168,86,10,10),nilFunc)
	self.dialogLayer=CCLayer:create()

	local size=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer=dialogBg
	self.bgLayer:setContentSize(size)
	self:show()
	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(self.bgLayer,2);
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-2)
	self.dialogLayer:setBSwallowsTouches(true);

	local function close()
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end
	local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
	closeBtnItem:setPosition(0,0)
	closeBtnItem:setAnchorPoint(CCPointMake(0,0))
		 
	self.closeBtn = CCMenu:createWithItem(closeBtnItem)
	self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
	self.closeBtn:setPosition(ccp(size.width-closeBtnItem:getContentSize().width,size.height-closeBtnItem:getContentSize().height))
	dialogBg:addChild(self.closeBtn)

	local titleLb=GetTTFLabel(getlocal("plat_war_reward_detail"),36)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height/2-25))
	dialogBg:addChild(titleLb)


	local function callback(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.cellWidth,self.dialogHeight-130),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(20,40)
	dialogBg:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(80)

	--遮罩层
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc);
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(touchDialogBg,1);
		
	sceneGame:addChild(self.dialogLayer,layerNum)
	self.dialogLayer:setPosition(ccp(0,0))
end


function rewardDetailSmallDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		if self.type==1 then
			return SizeOfTable(platWarCfg.battleRank.reward)
		else
			return SizeOfTable(platWarCfg.pointRank.reward)
		end
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(self.cellWidth,self.cellHeight)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local rewardCfg={}
		if self.type==1 then
			rewardCfg=platWarCfg.battleRank.reward
		else
			rewardCfg=platWarCfg.pointRank.reward
		end
		local cfg=rewardCfg[idx+1]
		local rankRange=cfg.range
		local rewardTb=cfg.reward
		local itemTb=FormatItem(rewardTb)
		local rankStr=""
		if rankRange[1] then
			rankStr=rankRange[1]
			if rankRange[2] then
				if rankRange[1]==rankRange[2] then
					rankStr=rankRange[1]
				else
					rankStr=rankRange[1].."~"..rankRange[2]
				end
			end
		end

		local function nilFunc()
		end
		local headSp=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20,20,10,10),nilFunc)
		headSp:setContentSize(CCSizeMake(self.cellWidth,60))
		headSp:setAnchorPoint(ccp(0,1))
		headSp:setPosition(ccp(0,self.cellHeight-5))
		cell:addChild(headSp)
		local titleStr=getlocal("serverwar_rank_reward",{rankStr})
		-- titleStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
		local titleLb=GetTTFLabelWrap(titleStr,25,CCSizeMake(self.cellWidth-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		titleLb:setAnchorPoint(ccp(0,0.5))
		titleLb:setPosition(ccp(10,headSp:getContentSize().height/2))
		titleLb:setColor(G_ColorYellowPro)
		headSp:addChild(titleLb)

		local bgHeight=self.cellHeight-headSp:getContentSize().height-10
		local background=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20,20,10,10),function () end)
		background:setContentSize(CCSizeMake(self.cellWidth-20,bgHeight))
		background:setAnchorPoint(ccp(0,0))
		background:setPosition(ccp(10,0))
		cell:addChild(background)

		-- local tankItemTb={p={p1=10,p19=10,p20=10,p2=10}}
		-- local itemTb=FormatItem(tankItemTb)
		-- local itemNum=SizeOfTable(itemTb)
		local wSpace=25
		local iconSize=100
		for k,v in pairs(itemTb) do
			local px,py=0,bgHeight-iconSize/2-30
			px=100/2+42+(iconSize+wSpace)*(k-1)
			local item=v
			local icon=G_getItemIcon(item,iconSize)
			icon:setPosition(ccp(px,py))
			cell:addChild(icon)
			local nameLb=GetTTFLabelWrap(item.name.."x"..item.num,22,CCSizeMake(110,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			nameLb:setAnchorPoint(ccp(0.5,0.5))
			nameLb:setPosition(px,py-iconSize/2-25)
			cell:addChild(nameLb)
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

