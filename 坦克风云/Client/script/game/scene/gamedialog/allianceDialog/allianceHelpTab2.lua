allianceHelpTab2={}

function allianceHelpTab2:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	-- self.cellHeight1=320
	-- self.cellHeight2=200
	self.cellHeight=120
	self.curIndex=2
	self.noRecordLb=nil
	self.callbackNum=0

	return nc
end

function allianceHelpTab2:init(layerNum,parent)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self.parent=parent
	self:initTableView()
	return self.bgLayer
end

function allianceHelpTab2:initTableView()


	local function touch( ... )
		-- body
	end

	local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),touch)
    backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,G_VisibleSizeHeight-160-20-20))
    backSprie:setAnchorPoint(ccp(0.5,1))
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
    backSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-160-20))
    self.bgLayer:addChild(backSprie)

	local function callBack(...)
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSizeHeight-160-20-20-10),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setAnchorPoint(ccp(0,0))
	self.tv:setPosition(ccp(20,25))
	self.tv:setMaxDisToBottomOrTop(120)
	self.bgLayer:addChild(self.tv)

	self.noRecordLb = GetTTFLabelWrap(getlocal("alliance_help_no_myHelp"),30,CCSizeMake(G_VisibleSizeWidth-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.noRecordLb:setAnchorPoint(ccp(0.5,0.5))
    self.noRecordLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
    self.bgLayer:addChild(self.noRecordLb,1)
    self.noRecordLb:setColor(G_ColorGray)

    local num=SizeOfTable(allianceHelpVoApi:getList(self.curIndex))
	if num and num>0 then
		self.noRecordLb:setVisible(false)
	else
		self.noRecordLb:setVisible(true)
	end

end

function allianceHelpTab2:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		local num=SizeOfTable(allianceHelpVoApi:getList(self.curIndex))
		return num
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize = CCSizeMake(G_VisibleSizeWidth-40,self.cellHeight)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local cellWidth=G_VisibleSizeWidth-40
		local cellHeight=self.cellHeight
		local bgWidth=cellWidth-10
		local bgHeight=cellHeight-5
		local capInSet = CCRect(20, 20, 10, 10)
		local function touch()
		end
		local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,touch)
        backSprie:setContentSize(CCSizeMake(bgWidth,bgHeight))
        backSprie:ignoreAnchorPointForPosition(false)
        backSprie:setAnchorPoint(ccp(0.5,1))
        backSprie:setIsSallow(false)
        backSprie:setOpacity(0)
        backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
		backSprie:setPosition(ccp(cellWidth/2,cellHeight-5))
		cell:addChild(backSprie)

		local list=allianceHelpVoApi:getList(self.curIndex)
		local hvo=list[idx+1]
		local name=hvo.name--"name"..(idx+1)

		local scale=0.9
		local level=hvo.level
		local hPoint=hvo.num
		local maxPoint=hvo.maxNum
		local targetName=""
		local hType=hvo.hType
		local iconStr
		if hType=="techs" then
			local tid=hvo.tid
			if tid then
				tid=(tonumber(tid) or tonumber(RemoveFirstChar(tid)))
				if techCfg[tid] then
					if techCfg[tid].name then
						targetName=getlocal(techCfg[tid].name)
					end
					iconStr=techCfg[tid].icon
				end
			end
		else
			local bType=hvo.bType
			if bType then
				bType=(tonumber(bType) or tonumber(RemoveFirstChar(bType)))
				if buildingCfg[bType] then
					if buildingCfg[bType].buildName then
						targetName=getlocal(buildingCfg[bType].buildName)
					end
					iconStr=buildingCfg[bType].icon
				end
			end
		end
		if iconStr then
			local icon=CCSprite:createWithSpriteFrameName(iconStr)
			if icon then
				icon:setPosition(ccp(50,bgHeight/2))
				backSprie:addChild(icon,1)
				icon:setScale(0.8)
			end
		end	

		local per = hPoint/maxPoint*100
		-- local percentStr = hPoint.."/"..maxPoint
		local percentStr = getlocal("alliance_help_schedule",{hPoint,maxPoint})
		AddProgramTimer(backSprie,ccp(100+352*scale/2,28),101,201,percentStr,"skillBg.png","skillBar.png",301)
	    local timerSpriteLv = backSprie:getChildByTag(101)
	    -- print("timerSpriteLv:getContentSize().width",timerSpriteLv:getContentSize().width)
		timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
		timerSpriteLv:setPercentage(per)
		timerSpriteLv:setScaleX(scale)
		local bg = backSprie:getChildByTag(301)
		bg:setScaleX(scale)
		local lb = timerSpriteLv:getChildByTag(201)
		lb:setScaleX(1/scale)

		local function nilFunc( ... )
			-- body
		end
		local titleSpire = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,0,1,32),nilFunc)
	    titleSpire:setContentSize(CCSizeMake(bgWidth-150,32))
	    titleSpire:setAnchorPoint(ccp(0,0.5))
	    backSprie:addChild(titleSpire)
	    titleSpire:setPosition(ccp(100,backSprie:getContentSize().height-20))

		local nameLb=GetTTFLabel(name,22,true)
		nameLb:setAnchorPoint(ccp(0,0.5))
		nameLb:setPosition(ccp(15,titleSpire:getContentSize().height/2))
		titleSpire:addChild(nameLb,1)
		nameLb:setColor(G_ColorYellowPro)

		-- local desc=getlocal("alliance_help_desc",{targetName,level})
		local desc=getlocal("buildNameAndLevel",{targetName,level})
		-- desc="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
		local descLb=GetTTFLabelWrap(desc,22,CCSizeMake(cellWidth-250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
		descLb:setAnchorPoint(ccp(0,0.5))
		descLb:setPosition(ccp(100,bgHeight/2+5))
		-- descLb:setPosition(ccp(100,bgHeight/2+40))
		backSprie:addChild(descLb,1)

		-- local function helpHandler(tag,object)
		-- 	if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
		-- 		if G_checkClickEnable()==false then
		--             do
		--                 return
		--             end
		--         else
		--             base.setWaitTime=G_getCurDeviceMillTime()
		--         end
		--         PlayEffect(audioCfg.mouseClick)

		--     end
		-- end
		-- local scale=0.8
		-- local helpItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",helpHandler,nil,getlocal("help"),25,11)
		-- helpItem:setScale(scale)
		-- local helpMenu=CCMenu:createWithItem(helpItem)
		-- helpMenu:setPosition(ccp(cellWidth-80,bgHeight/2))
		-- helpMenu:setTouchPriority(-(self.layerNum-1)*20-2)
		-- cell:addChild(helpMenu,2)

		local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine5.png", CCRect(4, 0, 2, 2), function ()end)
        lineSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-40-10, 2))
        lineSp:setPosition((G_VisibleSizeWidth-40)/2,0)
        cell:addChild(lineSp,2)

		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
	end
end

function allianceHelpTab2:doUserHandler()
    if self.noRecordLb then
		local num=SizeOfTable(allianceHelpVoApi:getList(self.curIndex))
		if num and num>0 then
			self.noRecordLb:setVisible(false)
		else
			self.noRecordLb:setVisible(true)
		end
	end
end

function allianceHelpTab2:tick()
	local flag=allianceHelpVoApi:getFlag(self.curIndex)
    -- local detailExpireTime=serverWarPersonalVoApi:getDetailExpireTime()
    -- if (self.callbackNum<3 and ((detailExpireTime and detailExpireTime>0 and base.serverTime>=detailExpireTime) or flag==-1)) then
    if self.callbackNum<3 and flag==-1 then
        local function callback()
            self:doUserHandler()
            if self and self.tv then
            	local recordPoint=self.tv:getRecordPoint()
				self.tv:reloadData()
				self.tv:recoverToRecordPoint(recordPoint)
            end
            self.callbackNum=0
        end
        allianceHelpVoApi:formatData(self.curIndex,callback)
        self.callbackNum=self.callbackNum+1
    elseif flag==0 then
        self:doUserHandler()
        if self and self.tv then
            local recordPoint=self.tv:getRecordPoint()
			self.tv:reloadData()
			self.tv:recoverToRecordPoint(recordPoint)
        end
        allianceHelpVoApi:setFlag(self.curIndex,1)
    end
end

function allianceHelpTab2:dispose()
	self.bgLayer:removeFromParentAndCleanup(true)
	self.bgLayer=nil
	self.layerNum=nil
	-- self.cellHeight1=nil
	-- self.cellHeight2=nil
	self.cellHeight=nil
	self.curIndex=nil
	self.noRecordLb=nil
	self.callbackNum=0
end