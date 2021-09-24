stewardLotterySmallDialog=smallDialog:new()

function stewardLotterySmallDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self

    self.moveDistance = 6 --每帧移动的距离

    return nc
end

function stewardLotterySmallDialog:showLotteryRewardDialog(layerNum, titleStr, rewardData, parent)
    local sd = stewardLotterySmallDialog:new()
    sd:initLotteryRewardDialog(layerNum, titleStr, rewardData, parent)
    return sd
end

function stewardLotterySmallDialog:getCellHeight(idx)
	if self.cellHeightTb==nil then
		self.cellHeightTb={}
	end
	if self.cellHeightTb[idx]==nil then
		local height = 0
		if idx==self.cellNum then
			height = height + 15
			local lb=GetTTFLabelWrap(getlocal("steward_reward_dialog_tip"),22,CCSizeMake(self.bgSize.width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			height = height + lb:getContentSize().height
			height = height + 15
		else
			-- local titleHeight = 32
			local titleBg = CCSprite:createWithSpriteFrameName("believerTitleBg.png")
			local titleHeight = titleBg:getContentSize().height
			height = height + titleHeight
			height = height + 15
			local rData = self.rewardData[idx]
			if rData.reward then
				local rowNum=4
				local iconSize=85
				local spaceX,spaceY=35,25
				local rewardSize = SizeOfTable(rData.reward)
				local colNum = math.floor(rewardSize/rowNum)
				if rewardSize%rowNum~=0 then
					colNum = colNum +1
				end
				height = height + iconSize * colNum + (colNum - 1) * spaceY
				height = height + 15
			end
			if rData.stringTb then
				for k, v in pairs(rData.stringTb) do
					local descLb=GetTTFLabelWrap(v[1],18,CCSizeMake(self.bgSize.width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
					height = height + descLb:getContentSize().height + 10
				end
				if rData.key=="s1" then
					local btn=GetButtonItem("steward_green_midBtn.png","steward_green_midBtn_down.png","steward_green_midBtn.png",function(...)end,1,getlocal("hold_name3"),24)
	        		height = height + btn:getContentSize().height + 10
				end
				height = height + 5
			end
			height = height + 10
		end
		self.cellHeightTb[idx] = height
	end
	return self.cellHeightTb[idx]
end

function stewardLotterySmallDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return self.cellNum
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(self.bgSize.width-40,self:getCellHeight(idx+1))
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local cellW, cellH = self.bgSize.width-40,self:getCellHeight(idx+1)

		local cellBg = CCNode:create()
		cellBg:setContentSize(CCSizeMake(cellW,cellH))
		cellBg:setAnchorPoint(ccp(0,0))
		-- cellBg:setPosition(-cellW,0)
		cellBg:setPosition(0,0)
		cellBg:setVisible(false)
		cell:addChild(cellBg)
		if idx+1==self.cellNum then
			local tipLb=GetTTFLabelWrap(getlocal("steward_reward_dialog_tip"),22,CCSizeMake(self.bgSize.width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			tipLb:setAnchorPoint(ccp(0.5,0.5))
			tipLb:setPosition(cellW/2,cellH/2)
			tipLb:setColor(G_ColorGreen)
			cellBg:addChild(tipLb)
		else
			local cellBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function()end)
			cellBgSp:setContentSize(CCSizeMake(cellW,cellH-10))
			cellBgSp:setPosition(cellW/2,cellH/2)
			cellBg:addChild(cellBgSp)

			local rData = self.rewardData[idx+1]

			local titleBg = CCSprite:createWithSpriteFrameName("believerTitleBg.png")
			titleBg:setAnchorPoint(ccp(0.5,1))
			titleBg:setPosition(cellW/2,cellH-5)
			cellBg:addChild(titleBg,1)
			local titleLb = GetTTFLabel(rData.name,22,true)
			titleLb:setAnchorPoint(ccp(0.5,0.5))
			titleLb:setPosition(titleBg:getContentSize().width/2,titleBg:getContentSize().height/2)
			titleBg:addChild(titleLb,1)

			local rowNum=4
			local iconSize=85
			local spaceX,spaceY=35,25
			local firstPosX=(cellW-(iconSize*rowNum+spaceX*(rowNum-1)))/2
			local firstPosY=titleBg:getPositionY()-titleBg:getContentSize().height-15
			local _posY = firstPosY
			if rData.reward then
				for k, v in pairs(rData.reward) do
					local icon
					if (v.type=="am" and v.key~="exp") or v.type=="se" or v.type=="pl" then
						icon=G_getItemIcon(v,100,true,self.layerNum,nil,self.tv,nil,nil,nil,nil,true,true)
					else
						icon=G_getItemIcon(v,100,false,self.layerNum,function() G_showNewPropInfo(self.layerNum+1,true,true,nil,v) end)
					end
					icon:setAnchorPoint(ccp(0,1))
					local scale=iconSize/icon:getContentSize().width
					icon:setScale(scale)
					icon:setPosition(firstPosX+((k-1)%rowNum)*(iconSize+spaceX),firstPosY-math.floor(((k-1)/rowNum))*(iconSize+spaceY))
		        	icon:setTouchPriority(-(self.layerNum-1)*20-4)
		        	cellBg:addChild(icon,1)

		        	if not (v.type=="h" and v.eType=="h") then
			        	if v.type=="am" then
			        		if v.key=="exp" then
						        local lvBg=CCSprite:createWithSpriteFrameName("amHeaderBg.png")
						        lvBg:setAnchorPoint(ccp(1,0))
						        lvBg:setPosition(ccp(icon:getContentSize().width-6,7))
						        icon:addChild(lvBg)
						        lvBg:setFlipX(true)
						        local numLb=GetTTFLabel(FormatNumber(v.num),25)
						        numLb:setAnchorPoint(ccp(1,0))
						        numLb:setPosition(ccp(icon:getContentSize().width-10,7))
						        icon:addChild(numLb,1)
						        lvBg:setScaleX((numLb:getContentSize().width+25)/lvBg:getContentSize().width)
						        lvBg:setScaleY(numLb:getContentSize().height/lvBg:getContentSize().height)
						    end
						elseif v.type=="h" and v.eType=="s" then --将领魂魄
							local numLb=GetTTFLabel("x"..FormatNumber(v.num),33,true)
					        numLb:setAnchorPoint(ccp(1,0))
					        numLb:setPosition(ccp(icon:getContentSize().width-10,10))
					        icon:addChild(numLb,1)
					    else
				            local numLb=GetTTFLabel("x"..FormatNumber(v.num),25)
					        numLb:setAnchorPoint(ccp(1,0))
					        numLb:setPosition(ccp(icon:getContentSize().width-8,7))
					        icon:addChild(numLb,1)
			        	end
		        	end

		        	self:checkRewardEffect(rData.key,v,icon)

		        	_posY = icon:getPositionY()-iconSize
				end
				_posY = _posY - 15
			end

			if rData.stringTb then
				for k, v in pairs(rData.stringTb) do
					local descLb=GetTTFLabelWrap(v[1],18,CCSizeMake(self.bgSize.width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
					-- height = height + descLb:getContentSize().height + 10
					descLb:setPosition(cellW/2,_posY-descLb:getContentSize().height/2)
					descLb:setColor(v[2])
					cellBg:addChild(descLb,1)
					_posY=descLb:getPositionY()-descLb:getContentSize().height/2-10
				end
				if rData.key=="s1" then
					local function btnHandler(tag,obj)
		        		if G_checkClickEnable()==false then
			                do return end
			            else
			                base.setWaitTime=G_getCurDeviceMillTime()
			            end
			            PlayEffect(audioCfg.mouseClick)
			            local function showCallback()
			            	self:close()
			            	if self.parent and self.parent.closeDialog then
			            		self.parent:closeDialog()
			            	end
		                    armorMatrixVoApi:showArmorMatrixDialog(self.layerNum+1)
		                    armorMatrixVoApi:showBagDialog(self.layerNum+2)
		                end
		                armorMatrixVoApi:armorGetData(showCallback)
		        	end
					local btn=GetButtonItem("steward_green_midBtn.png","steward_green_midBtn_down.png","steward_green_midBtn.png",btnHandler,1,getlocal("hold_name3"),24)
	        		-- height = height + btn:getContentSize().height + 10
	        		btn:setAnchorPoint(ccp(0.5,1))
		        	local btnMenu=CCMenu:createWithItem(btn)
			        btnMenu:setTouchPriority(-(self.layerNum-1)*20-4)
			        btnMenu:setPosition(ccp(cellW/2,_posY))
			        cellBg:addChild(btnMenu,1)
				end
				-- height = height + 5
			end
		end
		self.cellNodeTb[idx+1]=cellBg

		return cell
	elseif fn=="ccTouchBegan" then
		return true
	elseif fn=="ccTouchMoved" then
	elseif fn=="ccTouchEnded" then
	end
end

function stewardLotterySmallDialog:checkRewardEffect(_key,v,icon)
	local function runEffectAction()
		local _pos=ccp(icon:getPositionX()+icon:getContentSize().width*icon:getScale()/2,icon:getPositionY()-icon:getContentSize().height*icon:getScale()/2)
		for i=1,2 do
			local guangSp = CCSprite:createWithSpriteFrameName("equipShine.png")
			guangSp:setPosition(_pos)
			guangSp:setScale(1)
	        icon:getParent():addChild(guangSp)
	        local rotateBy = CCRotateBy:create(4,360)
			guangSp:runAction(CCRepeatForever:create((i==1) and rotateBy:reverse() or rotateBy))
    	end
	end
	if _key=="s1" then
		if v.type=="am" and v.key~="exp" then
			local cfg=armorMatrixVoApi:getCfgByMid(v.key)
        	local color=armorMatrixVoApi:getColorByQuality(cfg.quality)
        	if cfg.quality>=4 then
				runEffectAction()
		    end
	    end
	elseif _key=="s3" then
		local heroEquipReward = FormatItem(heroEquipAwakeShopCfg.canReward)
		for m, n in pairs(heroEquipReward) do
			if n.key==v.key then
				runEffectAction()
				break
			end
		end
	end
end

function stewardLotterySmallDialog:initLotteryRewardDialog(layerNum, titleStr, rewardData, parent)
	self.layerNum = layerNum
    self.isUseAmi = true
    self.rewardData = rewardData
    self.parent = parent
    
    self.dialogLayer = CCLayer:create()

    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    touchDialogBg:setTouchPriority( - (layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    -- touchDialogBg:setOpacity(50)
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(touchDialogBg)

    self.bgSize = CCSizeMake(560, 680)
    local function closeDialog()
    	if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local dialogBg,titleBg,titleLb,closeBtnItem,closeBtn=G_getNewDialogBg(self.bgSize,titleStr,32,nil,layerNum,true,closeDialog,nil)
    self.bgLayer=dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5,0.5))
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setTouchPriority(-(layerNum-1)*20-2)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
    self.dialogLayer:addChild(self.bgLayer,2)

    self.cellNodeTb = {}
    self.cellNum = SizeOfTable(self.rewardData) + 1
	local function tvCallBack(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(tvCallBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgSize.width-40,self.bgSize.height-98),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,30))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)

    local function callback()

    	--[[
    	if self and tolua.cast(self.bgLayer,"CCNode") and self.cellNodeTb then
    		local cellAction
    		local _cellPosY
    		cellAction = function(index)
    			if self and tolua.cast(self.bgLayer,"CCNode") and self.cellNodeTb and self.cellNodeTb[index] and tolua.cast(self.cellNodeTb[index],"CCNode") then

    				local tvPoint = self.tv:getRecordPoint()
					if tvPoint.y < 0 then
						if _cellPosY==nil then
							_cellPosY=tvPoint.y
						end
						local cellHeight = 0
						for i=1,index do
							cellHeight = cellHeight+self:getCellHeight(i)
						end
					    local tvSize = self.tv:getViewSize()
					    if cellHeight>tvSize.height then
					    	tvPoint.y = _cellPosY + math.abs(tvSize.height-cellHeight)
					    	self.tv:recoverToRecordPoint(tvPoint)
					    end
					end

	    			local arry=CCArray:create()
	    			-- arry:addObject(CCMoveTo:create(0.5,ccp(0,0)))
	    			arry:addObject(CCDelayTime:create(0.3))
	    			arry:addObject(CCCallFunc:create(function() cellAction(index+1) end))
	    			self.cellNodeTb[index]:runAction(CCSequence:create(arry))

	    			self.cellNodeTb[index]:setVisible(true)
    			end
    		end
    		cellAction(1)
    	end
    	--]]

    	if self and tolua.cast(self.bgLayer,"CCNode") and self.cellNodeTb then

    		local _cellPosY
    		self.cellDataTb={}
    		for k=1, self.cellNum do
    			local tvPoint = self.tv:getRecordPoint()
				if tvPoint.y < 0 then
					if _cellPosY==nil then
						_cellPosY=tvPoint.y
					end
					local cellHeight = 0
					for i=1,k do
						cellHeight = cellHeight+self:getCellHeight(i)
					end
				    local tvSize = self.tv:getViewSize()
				    if cellHeight>tvSize.height then
				    	self.cellDataTb[k] = {
				    		_cellPosY + math.abs(tvSize.height-cellHeight),
				    		self.cellNodeTb[k],
				    	}
				    end
				end
    		end

    		local cellAction
    		cellAction = function(index)
    			if self and tolua.cast(self.bgLayer,"CCNode") and self.cellNodeTb and self.cellNodeTb[index] and tolua.cast(self.cellNodeTb[index],"CCNode") then

    				local tvPoint = self.tv:getRecordPoint()
					if tvPoint.y < 0 then
						local cellHeight = 0
						for i=1,index do
							cellHeight = cellHeight+self:getCellHeight(i)
						end
					    local tvSize = self.tv:getViewSize()
					    if cellHeight>tvSize.height then
					    	self.showCellIndex=index
					    	self.schedulerID=CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function(...) self:update(...) end, 0, false)
					    	do return end
					    end
					end

	    			local arry=CCArray:create()
	    			-- arry:addObject(CCMoveTo:create(0.5,ccp(0,0)))
	    			arry:addObject(CCDelayTime:create(0.4))
	    			arry:addObject(CCCallFunc:create(function() cellAction(index+1) end))
	    			self.cellNodeTb[index]:runAction(CCSequence:create(arry))

	    			self.cellNodeTb[index]:setVisible(true)
    			end
    		end
    		local arry=CCArray:create()
    		arry:addObject(CCDelayTime:create(0.3))
    		arry:addObject(CCCallFunc:create(function() cellAction(1) end))
    		self.bgLayer:runAction(CCSequence:create(arry))
    		-- cellAction(1)
    	end

    end
    self:show(callback)
    sceneGame:addChild(self.dialogLayer, self.layerNum)
end

function stewardLotterySmallDialog:update(dt)
	if self and self.bgLayer and tolua.cast(self.bgLayer, "CCNode") and self.tv and self.cellDataTb and self.showCellIndex then
		if self.cellDataTb[self.showCellIndex]==nil then
			if self.schedulerID~=nil then
		        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedulerID)
		        self.schedulerID=nil
		    end
			do return end
		end
		local tvPoint = self.tv:getRecordPoint()
		tvPoint.y = tvPoint.y + self.moveDistance
		self.tv:recoverToRecordPoint(tvPoint)
		local _posY = self.cellDataTb[self.showCellIndex][1]
		if tvPoint.y>=_posY-self:getCellHeight(self.showCellIndex)/2 then
			local _cellNode = self.cellDataTb[self.showCellIndex][2]
			if tolua.cast(_cellNode,"CCNode") then
				_cellNode:setVisible(true)
			end
		end
		if tvPoint.y>=_posY then
			self.showCellIndex=self.showCellIndex+1
		end
	end
end

function stewardLotterySmallDialog:dispose()
	if self.schedulerID~=nil then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedulerID)
        self.schedulerID=nil
    end
	self.cellNodeTb = nil
	self.cellDataTb = nil
	self.showCellIndex = nil
	self.cellNum = nil
	self = nil
end