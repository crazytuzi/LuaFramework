platWarRewardDialogTab1={}
function platWarRewardDialogTab1:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.cellWidth=G_VisibleSizeWidth-60
	self.cellHeight=270
	return nc
end

function platWarRewardDialogTab1:init(layerNum,parent)
	self.layerNum=layerNum
	self.parent=parent
	self.bgLayer=CCLayer:create()
	self:initLayer()
	return self.bgLayer
end

function platWarRewardDialogTab1:initLayer()
	local function callback(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.cellWidth,G_VisibleSizeHeight-220),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(30,40)
	self.bgLayer:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(80)
	return self.bgLayer
end

function platWarRewardDialogTab1:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return 6
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(self.cellWidth,self.cellHeight)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local rewardCfg
		if idx>=0 and idx<=2 then
			rewardCfg=platWarCfg.victoryReward
		else
			rewardCfg=platWarCfg.failReward
		end
		local levelLimit=rewardCfg.levelLimit

		local cfg={}
		if idx==0 or idx==3 then
			cfg=rewardCfg.limitReward.q
		elseif idx==1 or idx==4 then
			cfg=rewardCfg.allReward.q
		elseif idx==2 or idx==5 then
			cfg=rewardCfg.dailyReward.q
		end
		local rewardTb=FormatItem(cfg)

		local function nilFunc()
		end
		local headSp=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20,20,10,10),nilFunc)
		headSp:setContentSize(CCSizeMake(self.cellWidth,60))
		headSp:setAnchorPoint(ccp(0,1))
		headSp:setPosition(ccp(0,self.cellHeight-5))
		cell:addChild(headSp)
		local titleStr=getlocal("plat_war_reward_type_"..(idx+1))
		if idx==0 then
			titleStr=getlocal("plat_war_reward_type_"..(idx+1),{levelLimit})
		end
		-- titleStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
		local titleLb=GetTTFLabelWrap(titleStr,25,CCSizeMake(self.cellWidth-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		titleLb:setAnchorPoint(ccp(0,0.5))
		titleLb:setPosition(ccp(10,headSp:getContentSize().height/2))
		titleLb:setColor(G_ColorYellowPro)
		headSp:addChild(titleLb)

		local bgHeight=self.cellHeight-headSp:getContentSize().height-10
		local background=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20,20,10,10),function () end)
		background:setContentSize(CCSizeMake(self.cellWidth,bgHeight))
		background:setAnchorPoint(ccp(0,0))
		background:setPosition(ccp(0,0))
		cell:addChild(background)

		-- local tankItemTb={p={p1=10,p19=10,p20=10,p2=10,p3=10}}
		-- local itemTb=FormatItem(tankItemTb)
		-- local itemNum=SizeOfTable(itemTb)
		local wSpace=15
		local iconSize=100
		for k,v in pairs(rewardTb) do
			local px,py=0,bgHeight-iconSize/2-30
			-- if itemNum%2==0 then
			-- 	px=self.cellWidth/2-(iconSize+wSpace)*((itemNum-1)/2)+(iconSize+wSpace)*(k-1)
			-- else
			-- 	px=self.cellWidth/2-(iconSize+wSpace)*math.floor(itemNum/2)+(iconSize+wSpace)*(k-1)
			-- end
			px=100/2+10+(iconSize+wSpace)*(k-1)
			local item=v
			local icon=G_getItemIcon(item,iconSize)
			icon:setPosition(ccp(px,py))
			cell:addChild(icon)
			local num=item.num
			if item.type=="u" then
				num=FormatNumber(num)
			end
			local nameLb=GetTTFLabelWrap(item.name.."x"..num,22,CCSizeMake(110,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			nameLb:setAnchorPoint(ccp(0.5,0.5))
			nameLb:setPosition(px,py-iconSize/2-25)
			cell:addChild(nameLb)
			-- if(item.num>1)then
			-- 	local numLb=GetTTFLabel("x"..FormatNumber(item.num),22)
			-- 	numLb:setAnchorPoint(ccp(1,0))
			-- 	numLb:setPosition(ccp(95,5))
			-- 	icon:addChild(numLb)
			-- end
			-- local nameLb=GetTTFLabelWrap(item.name,25,CCSizeMake(300,80),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			-- nameLb:setAnchorPoint(ccp(0,1))
			-- nameLb:setPosition(130,self.cellHeight-30)
			-- cell:addChild(nameLb)
			-- local descLb=GetTTFLabelWrap(getlocal(item.desc),22,CCSizeMake(250,240),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			-- descLb:setAnchorPoint(ccp(0,0.5))
			-- local deslbHeight = 170
			-- if G_getCurChoseLanguage() == "cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage()=="ja" then
			-- 		deslbHeight =115
			-- end
			-- descLb:setPosition(130,self.cellHeight-deslbHeight)
			-- cell:addChild(descLb)
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

function platWarRewardDialogTab1:tick()

end

function platWarRewardDialogTab1:dispose()
	self.bgLayer:removeFromParentAndCleanup(true)
	self.layerNum=nil
	self.bgLayer=nil
end