stewardTabThree={}

function stewardTabThree:init(layerNum,parent)
	self.layerNum = layerNum
	self.parent = parent
	self.bgSize = parent.bgSize

	self.bgLayer=CCLayer:create()

	self.tvData = stewardVoApi:getStewardData(self.layerNum,3)
	self:initUI()

	return self.bgLayer
end

function stewardTabThree:initUI()
	local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function()end)
    tvBg:setContentSize(CCSizeMake(self.bgSize.width-40,self.bgSize.height-120))
    tvBg:setAnchorPoint(ccp(0.5,1))
    tvBg:setPosition(self.bgSize.width/2,self.bgSize.height-85)
    self.bgLayer:addChild(tvBg)

    self.cellNum = SizeOfTable(self.tvData)
	local function tvCallBack(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(tvCallBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgSize.width-40,tvBg:getContentSize().height-6),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,tvBg:getPositionY()-tvBg:getContentSize().height+3))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
end

function stewardTabThree:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return self.cellNum
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(self.bgSize.width-40,90)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local cellW, cellH = self.bgSize.width-40,90
		local data = self.tvData[idx+1]
		local _freeFlag = false

		local iconBg
		if data.iconBg then
			iconBg = CCSprite:createWithSpriteFrameName(data.iconBg)
			iconBg:setAnchorPoint(ccp(0,0.5))
			iconBg:setPosition(15,cellH/2)
			iconBg:setScale((cellH-18)/iconBg:getContentSize().height)
			cell:addChild(iconBg)
		end
		local icon = CCSprite:createWithSpriteFrameName(data.icon or "icon_bg_gray.png")
		icon:setAnchorPoint(ccp(0,0.5))
		icon:setPosition(15,cellH/2)
		icon:setScale((cellH-18)/icon:getContentSize().height)
		cell:addChild(icon)

		local strSize = 22
		if G_isAsia() == false then
			strSize = 18
		end
		local nameLb = GetTTFLabelWrap(data.name,strSize,CCSizeMake(cellW/2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
		nameLb:setAnchorPoint(ccp(0,1))
		nameLb:setPosition(icon:getPositionX()+icon:getContentSize().width*icon:getScale()+10,cellH-10)
		cell:addChild(nameLb)

		if data.descTb and data.freeTb and SizeOfTable(data.descTb)==SizeOfTable(data.freeTb) then
			local _posX = nameLb:getPositionX()
			for k, v in pairs(data.descTb) do
				local freeTb = data.freeTb[k]
				local _curFreeNum, _maxFreeNum = freeTb[1], freeTb[2]
				local _lbStr
				if _maxFreeNum==nil then
					_lbStr = v.."：".._curFreeNum
				else
					_lbStr = v.."："..getlocal("scheduleChapter",{_curFreeNum,_maxFreeNum})
				end
				local strSize1 = 20
				if G_isAsia() == false then
					strSize1 = 16
				end
				local lb = GetTTFLabel(_lbStr, strSize1)
				lb:setAnchorPoint(ccp(0,0))
				lb:setPosition(_posX, 10)
				if _curFreeNum==0 then
					lb:setColor(G_ColorGray)
				else
					_freeFlag=true
				end
				cell:addChild(lb)
				_posX = lb:getPositionX()+lb:getContentSize().width+10
			end
		end

		local function onBtnHandler(tag,obj)
			if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            if type(data.jumpTo)=="function" then
            	if self.parent and self.parent.closeDialog then
            		self.parent:closeDialog()
            	end
            	data.jumpTo()
            end
		end
		local button=GetButtonItem("yh_nbSkillGoto.png","yh_nbSkillGoto_Down.png","yh_nbSkillGoto.png",onBtnHandler,idx+1)
        button:setScale(50/button:getContentSize().height)
        button:setAnchorPoint(ccp(0.5,0.5))
        local menu=CCMenu:createWithItem(button)
        menu:setTouchPriority(-(self.layerNum-1)*20-4)
        menu:setPosition(ccp(cellW-button:getContentSize().width*button:getScale()/2-15,cellH/2))
        cell:addChild(menu,11)

        if _freeFlag==false then
        	if iconBg then
        		iconBg:setColor(G_ColorGray)
        	end
        	icon:setColor(G_ColorGray)
        	nameLb:setColor(G_ColorGray)
	        local cellAlpha = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
	        cellAlpha:setContentSize(CCSizeMake(cellW-4,cellH-3))
	        cellAlpha:setPosition(cellW/2,cellH/2)
	        cellAlpha:setOpacity(100)
	        cell:addChild(cellAlpha,10)
    	end

        local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function()end)
        lineSp:setContentSize(CCSizeMake(cellW-18, 3))
        lineSp:ignoreAnchorPointForPosition(false)
        lineSp:setAnchorPoint(ccp(0.5,0.5))
        lineSp:setPosition(cellW/2,0)
        cell:addChild(lineSp)

		return cell
	elseif fn=="ccTouchBegan" then
		return true
	elseif fn=="ccTouchMoved" then
	elseif fn=="ccTouchEnded" then
	end
end

function stewardTabThree:tick()
end

function stewardTabThree:dispose()
	self.cellNum = nil
	self.tvData = nil
	self = nil
end

return stewardTabThree