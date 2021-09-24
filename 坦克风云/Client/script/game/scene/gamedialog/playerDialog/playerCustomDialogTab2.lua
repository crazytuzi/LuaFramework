playerCustomDialogTab2={}

function playerCustomDialogTab2:new( )
	local nc = {}
	setmetatable(nc,self)
	self.__index=self

	self.bgLayer=nil
	self.layerNum=nil
	self.curChooseId = 0
	self.newTitleCfg = {}
	self.typeTb = {}
	self.nameTb = {}
	self.smallerestSc = nil
	return nc
end

function playerCustomDialogTab2:dispose()
	eventDispatcher:removeEventListener("playerCustomDialogTab2.playerIconChange",self.playerIconChangeListener)
	self.nameTb = nil
	self.smallerestSc = nil
	self.tvNum=nil
	self.bgLayer=nil
	self.layerNum=nil
	self.tvTb=nil
	self.noTitleLb=nil
	self.curChooseId=nil
	self.newTitleCfg = nil
	self.typeTb = nil
end

function playerCustomDialogTab2:init(layerNum)
	self.bgLayer=CCLayer:create()
	self.layerNum =layerNum
	self.newTitleCfg,self.typeTb = playerVoApi:formatTitleCfgInfo()
	self:initTableView()
	if self.smallerestSc then
		for k,v in pairs(self.nameTb) do
			v:setScale(self.smallerestSc)
		end
	end

	-- 添加监听事件
	local function playerIconChange(event,data)
        self:refresh(data)
    end
    self.playerIconChangeListener=playerIconChange
    eventDispatcher:addEventListener("playerCustomDialogTab2.playerIconChange",playerIconChange)

	return self.bgLayer
end

function playerCustomDialogTab2:initTableView()
	local topBgSprite=LuaCCScale9Sprite:createWithSpriteFrameName("newItemKuang.png",CCRect(15,15,2,2),function()end)
    topBgSprite:setContentSize(CCSizeMake(616,187))
    topBgSprite:setAnchorPoint(ccp(0.5,1))
    topBgSprite:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-165)
    self.bgLayer:addChild(topBgSprite)
    self.topBgSprite=topBgSprite

	self:setTvNum()
	self.curSelectedChatFrameId = playerVoApi:getCfid()
	local curGetTitle = playerVoApi:getTitle()
	self.curSelectedTitleId = (curGetTitle == nil or curGetTitle =="") and 0 or tonumber(curGetTitle)
	self.curChooseId = self.curSelectedTitleId
	self:setTopInfo(playerVoApi:getTitle())

	self:setCellHeight()
	local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function()end)
    tvBg:setContentSize(CCSizeMake(616,G_VisibleSizeHeight-topBgSprite:getContentSize().height-275))
    tvBg:setAnchorPoint(ccp(0.5,1))
    tvBg:setPosition(G_VisibleSizeWidth/2,topBgSprite:getPositionY()-topBgSprite:getContentSize().height-15)
    self.bgLayer:addChild(tvBg)

    local function callBack(...)
    	return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvBg:getContentSize().width-5,tvBg:getContentSize().height-5),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(2.5,2.5))
    tvBg:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(80)

    G_addForbidForSmallDialog2(self.bgLayer,tvBg,-(self.layerNum-1)*20-2,nil,1)

    local function saveHandler()
    	if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:saveEvent()
    end
    local saveBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",saveHandler,11)
    saveBtn:setScale(0.8)
    saveBtn:setAnchorPoint(ccp(0.5,0.5))
    local menu=CCMenu:createWithItem(saveBtn)
    menu:setTouchPriority(-(self.layerNum-1)*20-4)
    menu:setPosition(ccp(G_VisibleSizeWidth/2,tvBg:getPositionY()-tvBg:getContentSize().height-15-saveBtn:getContentSize().height*saveBtn:getScale()/2))
    self.bgLayer:addChild(menu)
    local btnLb=GetTTFLabel(getlocal("collect_border_save"),24,true)
    btnLb:setPosition(menu:getPosition())
    self.bgLayer:addChild(btnLb)
    self.saveBtn=saveBtn
end

function playerCustomDialogTab2:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
	    return 1
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(616,self.cellHeight)
	elseif fn=="tableCellAtIndex" then
    	local cell=CCTableViewCell:new()
		 cell:autorelease()

		 local cellWidth=611
		local selectSp=LuaCCScale9Sprite:createWithSpriteFrameName("newSelectKuang.png",CCRect(30, 30, 1, 1),function()end)
		selectSp:setContentSize(CCSizeMake(134,134))
		selectSp:setPosition(99999,99999)
		selectSp:setVisible(false)
		cell:addChild(selectSp,10)

		local _posY = self.cellHeight
		for k,v in pairs(self.showTvTb) do
			for i,j in pairs(v) do
				cellType=j.value.type
				break
			end

			local titleStr = self.typeTb[cellType] or ""
			-- print("titleStr=====>>>>",titleStr)

			if k>1 then
				local topLine=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png",CCRect(34,1,1,1),function ()end)
				topLine:setContentSize(CCSizeMake(cellWidth,topLine:getContentSize().height))
				topLine:setPosition(cellWidth/2,_posY)
				cell:addChild(topLine)
				_posY=_posY-15
			end

			-- 标题
		    local lightSp1=CCSprite:createWithSpriteFrameName("newGreenFadeLight.png")
		    lightSp1:setAnchorPoint(ccp(0.5,0.5))
		    lightSp1:setScaleX(4)
		    lightSp1:setPosition(cellWidth/2,_posY-25)
		    cell:addChild(lightSp1)
		    local nameLb1=GetTTFLabel(titleStr,24,true)
		    nameLb1:setAnchorPoint(ccp(0.5,0.5))
		    nameLb1:setPosition(cellWidth/2,lightSp1:getPositionY()+5)
		    cell:addChild(nameLb1)
		    local realNameW1=nameLb1:getContentSize().width
		    for i=1,2 do
		        local pointSp=CCSprite:createWithSpriteFrameName("newPointRect.png")
		        local anchorX=1
		        local posX=cellWidth/2-(realNameW1/2+20)
		        local pointX=-7
		        if i==2 then
		            anchorX=0
		            posX=cellWidth/2+(realNameW1/2+20)
		            pointX=15
		        end
		        pointSp:setAnchorPoint(ccp(anchorX,0.5))
		        pointSp:setPosition(posX,nameLb1:getPositionY())
		        cell:addChild(pointSp)

		        local pointLineSp=CCSprite:createWithSpriteFrameName("newPointLine.png")
		        pointLineSp:setAnchorPoint(ccp(0,0.5))
		        pointLineSp:setPosition(pointX,pointSp:getContentSize().height/2)
		        pointSp:addChild(pointLineSp)
		        if i==1 then
		            pointLineSp:setRotation(180)
		        end
		    end

		    _posY=_posY-25

		    local function sortFunc(a,b)
				return a.value.sortId<b.value.sortId
			end
			table.sort(v,sortFunc)

			local startX = 85
			local startY = _posY-95
			local addW	 = 145
			local addH   = 145

			for i,j in pairs(v) do
				local bgSp
				local function changeIcon()
					if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
		                if G_checkClickEnable()==false then
		                    do return end
		                else
		                    base.setWaitTime=G_getCurDeviceMillTime()
		                end
						PlayEffect(audioCfg.mouseClick)

						selectSp:setPosition(bgSp:getPosition())
						selectSp:setVisible(true)
						-- print("j.key====>>>>",j.key)
						self.curChooseId=tonumber(j.key)
						self:setTopInfo(self.curChooseId)
					end
				end
				bgSp=LuaCCScale9Sprite:createWithSpriteFrameName("fi_bubble_bg.png",CCRect(4,4,1,1),changeIcon)
				bgSp:setContentSize(CCSizeMake(128,128))
				cell:addChild(bgSp)
				bgSp:setTouchPriority(-(self.layerNum-1)*20-2)

				local nameLb = GetTTFLabel(getlocal(j.value.name),25)
				nameLb:setPosition(getCenterPoint(bgSp))
				bgSp:addChild(nameLb,1)
				if j.value.name ~= "alliance_info_content" then
					local frameSp=CCSprite:createWithSpriteFrameName("serverWarTopBg1.png")
					local fSpScaleY = (bgSp:getContentSize().width - 8) / frameSp:getContentSize().width
					frameSp:setScale(fSpScaleY)
					frameSp:setPosition(ccp(bgSp:getContentSize().width * 0.5,bgSp:getContentSize().height * 0.54))
					bgSp:addChild(frameSp)
					local newSc = (bgSp:getContentSize().width - 40)/nameLb:getContentSize().width
					if not self.smallerestSc then
						self.smallerestSc = newSc
					elseif self.smallerestSc > newSc then
						self.smallerestSc = newSc
					end
					self.nameTb[i] = nameLb
					-- nameLb:setScale()
				
					local isUnlock = false
					for k,v in pairs(self.tvTb) do
						if v.key == j.key then
							isUnlock =true
							do break end
						end
					end
					if not isUnlock then
						nameLb:setColor(G_ColorGray2)
						frameSp:setColor(G_ColorGray)

						local lockSp = CCSprite:createWithSpriteFrameName("LockIcon.png")
						lockSp:setPosition(bgSp:getContentSize().width-5, 3)
						lockSp:setAnchorPoint(ccp(1,0))
						lockSp:setScale(0.5)
						bgSp:addChild(lockSp)
					end
				end
				local num2 = math.floor(i/4)
				local num1 = i%4
				if num1==0 then
					num1=4
					num2=num2-1
				end
				local useChoose = nil
				if self.curChooseId == 0 and self.curSelectedTitleId == 0 then
					useChoose = 1
				end
				bgSp:setPosition(startX+(num1-1)*addW, startY-num2*addH)
				if (useChoose and useChoose == tonumber(j.key)) or tonumber(j.key)==tonumber(self.curChooseId) then
					selectSp:setPosition(bgSp:getPosition())
					selectSp:setVisible(true)
				end
				-- print("self.curSelectedTitleId=====>>>>",self.curSelectedTitleId,self.curChooseId)
				if (useChoose and useChoose == tonumber(j.key)) or tonumber(j.key)==self.curSelectedTitleId then
					local useSp=LuaCCScale9Sprite:createWithSpriteFrameName("fi_used.png",CCRect(1,1,7,7),function()end)
					useSp:setContentSize(CCSizeMake(bgSp:getContentSize().width,25))
					useSp:setAnchorPoint(ccp(0.5,0))
					useSp:setPosition(bgSp:getContentSize().width/2,0)
					bgSp:addChild(useSp)
					useSp:setOpacity(255*0.8)
					local useLb=GetTTFLabel(getlocal("in_use"),18,true)
					useLb:setPosition(useSp:getContentSize().width/2,useSp:getContentSize().height/2)
					useSp:addChild(useLb)
				end
				--[[--目前用不上，用上的时候需要改逻辑
				--判断是否有‘新’的标志
								local newUnlockTb=playerVoApi:getNewUnlockTb(4)
								if newUnlockTb then
									for m,q in pairs(newUnlockTb) do
										if tostring(q)==tostring(j.key) then
											--此处添加‘新’的图片和文字
											local newSp=CCSprite:createWithSpriteFrameName("fi_newFlag.png")
											newSp:setAnchorPoint(ccp(0,1))
											newSp:setPosition(0,bgSp:getContentSize().height)
											bgSp:addChild(newSp,5)
											newSp:setScale(0.8)
											local newLb=GetTTFLabel(getlocal("new_text"),14/newSp:getScale(),true)
											newLb:setPosition(newSp:getContentSize().width/2-12,newSp:getContentSize().height/2+15)
											newLb:setRotation(-47)
											newLb:setColor(G_ColorYellow)
											newSp:addChild(newLb)
											break
										end
									end
								end
								local _isLock --是否上锁
								if cellType==1 and j.value.gemCost>0 then
									local count=self:checkJiesuo(j.key)
									if count==0 then
										_isLock=true
									end
								elseif cellType==4 and playerVoApi:getPlayerLevel()<j.value.level then
									_isLock=true
								elseif cellType==5 and playerVoApi:getVipLevel()<j.value.vip then
									_isLock=true
								end
								if _isLock then
									local contentSize = bgSp:getContentSize()
									local sp = CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")
									sp:setPosition(contentSize.width/2, contentSize.height/2)
									sp:setScale(contentSize.width/sp:getContentSize().width)
									sp:setOpacity(255)
									bgSp:addChild(sp)

									local lockSp = CCSprite:createWithSpriteFrameName("LockIcon.png")
									lockSp:setPosition(contentSize.width, 0)
									lockSp:setAnchorPoint(ccp(1,0))
									lockSp:setScale(0.5)
									bgSp:addChild(lockSp)
								end
				]]
				_posY=bgSp:getPositionY()-90
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

function playerCustomDialogTab2:setTvNum()
	self.tvNum=0 
	self.tvTb=playerVoApi:getTitleTb()
	local function sortFunc(a,b)
		return a.value.sortId<b.value.sortId
	end
	table.sort(self.tvTb,sortFunc)
	self.tvNum=SizeOfTable(self.tvTb)
end

function playerCustomDialogTab2:setCellHeight()
	self.showTvTb={}
	self.cellHeight=0
	local commonTb = {}
	local limitTb  = {}
	local levelTb  = {}
	local vipTb    = {}
	local acTb	   = {}
	local warTb    = {}
	local unLockData=playerVoApi:getUnLockData(4)--4 新加，但是在playerVoApi里并没有添加相关逻辑和字段，所以何时需要，何时处理
	for k, v in pairs(self.newTitleCfg) do
		if v.type == 1 then
			table.insert(commonTb,{key=k,value=v})
		elseif v.type == 3 then
			if unLockData then
				for m,q in pairs(unLockData) do
					if tostring(q[1]) == tostring(k) and q[2] > base.serverTime then
	            		table.insert(limitTb,{key=k,value=v})
	            		break
	            	end
				end
			end
		elseif v.type == 4 then
			table.insert(levelTb,{key=k,value=v})
		elseif v.type == 5 then
			table.insert(vipTb,{key=k,value=v})
		elseif v.type == 6 then
			table.insert(acTb,{key=k,value=v})
		elseif v.type == 7 then
			table.insert(warTb,{key=k,value=v})
		end
	end

	--基础聊天框
	if SizeOfTable(commonTb)~=0 then
		table.insert(self.showTvTb,commonTb)
		self.cellHeight=self.cellHeight+50
	else--如果增加基础称号 这里需要修改
		table.insert(commonTb,{key=1,value={sortId=1,type=1,name="alliance_info_content",isShow=1}})
		table.insert(self.showTvTb,commonTb)
		self.cellHeight=self.cellHeight+50
	end

	--限时聊天框
	if SizeOfTable(limitTb)~=0 then
		table.insert(self.showTvTb,limitTb)
		self.cellHeight=self.cellHeight+50
	end

	--等级聊天框
	if SizeOfTable(levelTb)~=0 then
		table.insert(self.showTvTb,levelTb)
		self.cellHeight=self.cellHeight+50
	end

	--VIP聊天框
	if SizeOfTable(vipTb)~=0 then
		table.insert(self.showTvTb,vipTb)
		self.cellHeight=self.cellHeight+50
	end

	if SizeOfTable(acTb)~=0 then
		table.insert(self.showTvTb,acTb)
		self.cellHeight=self.cellHeight+50
	end

	if SizeOfTable(warTb)~=0 then
		table.insert(self.showTvTb,warTb)
		self.cellHeight=self.cellHeight+50
	end

	for k,v in pairs(self.showTvTb) do
		local num = SizeOfTable(v)
		self.cellHeight=self.cellHeight+160*math.ceil(num/4)
	end
end

function playerCustomDialogTab2:refresh(data)
	if self and self.setTopInfo then
		self:setTopInfo(self.curSelectedTitleId)
	end
end

function playerCustomDialogTab2:setTopInfo(titleId)
	self.timeValue=nil
	self.timeLb=nil
	local bgNode = self.topBgSprite:getChildByTag(100)
	if bgNode and tolua.cast(bgNode,"CCNode") then
		bgNode:removeFromParentAndCleanup(true)
		bgNode=nil
	end
	bgNode=CCNode:create()
	bgNode:setContentSize(self.topBgSprite:getContentSize())
	bgNode:setTag(100)
	self.topBgSprite:addChild(bgNode)

	if titleId == nil or titleId == "" then
		titleId = self.curSelectedTitleId--chatFrameId = self.curSelectedChatFrameId
	end
	local titleCfg = titleCfg.list[tostring(titleId)]
	local chatFrameId = self.curSelectedChatFrameId
	local headId = playerVoApi:getPic()
    local headFrameId = playerVoApi:getHfid()

    --头像
	local personPhotoName=playerVoApi:getPersonPhotoName(headId)
	local photoSp = playerVoApi:GetPlayerBgIcon(personPhotoName,nil,nil,nil,nil,headFrameId)
	photoSp:setPosition(85,self.topBgSprite:getContentSize().height/2)
	photoSp:setScale(140/photoSp:getContentSize().height)
	bgNode:addChild(photoSp)

	--气泡
	local fontSize = 20
	local cfCfg = chatFrameCfg.list[tostring(chatFrameId)]
	local rect=CCRect(30,25,1,1)
	if cfCfg.pic[1]~="chat_bg_left.png" then
		rect=CCRect(48,25,1,1)
	end
	local subPosy = cfCfg.pic2 and 15 or 0
	local cfSp = LuaCCScale9Sprite:createWithSpriteFrameName(cfCfg.pic[1],rect,function()end)
	if G_isAsia() == false then
		cfSp:setContentSize(CCSizeMake(self.topBgSprite:getContentSize().width-photoSp:getContentSize().width*photoSp:getScale()-30,self.topBgSprite:getContentSize().height * 0.8 +10))
	else
		cfSp:setContentSize(CCSizeMake(self.topBgSprite:getContentSize().width-photoSp:getContentSize().width*photoSp:getScale()-30,self.topBgSprite:getContentSize().height * 0.7 ))
	end
	cfSp:setAnchorPoint(ccp(0,0.5))
	cfSp:setPosition(photoSp:getPositionX()+photoSp:getContentSize().width*photoSp:getScale()/2+5,self.topBgSprite:getContentSize().height * 0.5 - subPosy)
	bgNode:addChild(cfSp)

	if cfCfg.pic2 then
		local cfSp2 = CCSprite:createWithSpriteFrameName(cfCfg.pic2[1])
		cfSp2:setAnchorPoint(ccp(0,0))
		cfSp2:setPosition(10,cfSp:getContentSize().height - 8)
		cfSp:addChild(cfSp2)
	end

	local frameLb=GetTTFLabel(getlocal("use_deadline"),fontSize)
	frameLb:setAnchorPoint(ccp(0,1))
	frameLb:setPosition(25,cfSp:getContentSize().height-20)
	cfSp:addChild(frameLb)

	local _txtColor=G_ColorGreen
	local _timeStr=getlocal("foreverTime")
	-- local unLockData=playerVoApi:getUnLockData(3)
	-- if unLockData then
	-- 	for k, v in pairs(unLockData) do
	-- 		if tostring(v[1])==tostring(chatFrameId) then
	-- 			_txtColor=G_ColorRed
	-- 			if v[2]<=base.serverTime then
	-- 				_timeStr=getlocal("expireDesc")
	-- 			else
	-- 				_timeStr=G_formatActiveDate(v[2] - base.serverTime)
	-- 				self.timeValue=v[2]
	-- 			end
	-- 			break
	-- 		end
	-- 	end
	-- end
	local timeLb=GetTTFLabel(_timeStr,fontSize)
	timeLb:setAnchorPoint(ccp(0,1))
	timeLb:setPosition(frameLb:getPositionX()+frameLb:getContentSize().width,frameLb:getPositionY())
	timeLb:setColor(_txtColor)
	cfSp:addChild(timeLb)
	self.timeLb=timeLb

	local deblockingLb=GetTTFLabel(getlocal("deblocking_condition"),fontSize)
	deblockingLb:setAnchorPoint(ccp(0,1))
	deblockingLb:setPosition(frameLb:getPositionX(),frameLb:getPositionY()-frameLb:getContentSize().height-10)
	cfSp:addChild(deblockingLb)

	local conditionStr=getlocal("alliance_info_content")
	if titleCfg then
		if titleCfg.type==1 then
			conditionStr=getlocal("alliance_info_content")
		elseif titleCfg.type==4 then
			conditionStr=getlocal("fightLevel",{titleCfg.level})
		elseif titleCfg.type==5 then
			conditionStr=getlocal("VIPStr1",{titleCfg.vip})
		elseif titleCfg.type==6 then
			conditionStr=getlocal("getInAc")
		elseif titleCfg.type==7 then
			conditionStr=getlocal("getInWar")
		end
	end
	local conditionLb=GetTTFLabel(conditionStr,fontSize)
	if (deblockingLb:getContentSize().width + conditionLb:getContentSize().width) > (cfSp:getContentSize().width - frameLb:getPositionX() - 15) then
		conditionLb = GetTTFLabelWrap(conditionStr,fontSize,CCSize(cfSp:getContentSize().width - frameLb:getPositionX() - deblockingLb:getContentSize().width - 15, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	end
	local unlock = false
	for k,v in pairs(self.tvTb) do
		if tonumber(v.key) == tonumber(titleId) then
			unlock = true
			do break end
		end
	end
	-- print("titleId=====>>>>",titleId,unlock,playerVoApi:getTitle())
	if not unlock and titleId and tonumber(titleId) > 1 then
		conditionLb:setColor(G_ColorRed)
	end
	conditionLb:setAnchorPoint(ccp(0,1))
	conditionLb:setPosition(deblockingLb:getPositionX()+deblockingLb:getContentSize().width,deblockingLb:getPositionY())
	cfSp:addChild(conditionLb)

	local talkingShow=GetTTFLabel(getlocal("talkingShow"),fontSize)
	talkingShow:setAnchorPoint(ccp(0,1))
	talkingShow:setPosition(deblockingLb:getPositionX(),deblockingLb:getPositionY()-deblockingLb:getContentSize().height-10)
	cfSp:addChild(talkingShow)

	local showName1 = GetTTFLabel(playerVoApi:getPlayerName(),fontSize)
	showName1:setAnchorPoint(ccp(0,1))
	showName1:setPosition(talkingShow:getPositionX() + talkingShow:getContentSize().width,talkingShow:getPositionY())
	cfSp:addChild(showName1)	
	if titleId and titleId > 1 then
		local x1,x2 = "【","】"
		if G_getCurChoseLanguage() ~="cn" then
			x1,x2 = "[","]"
		end

		local showName2 = GetTTFLabel(x1..getlocal(titleCfg.name)..x2,fontSize)
		showName2:setAnchorPoint(ccp(0,1))
		showName2:setColor(G_ColorGreen)
		showName2:setPosition(showName1:getPositionX() + showName1:getContentSize().width,showName1:getPositionY())
		cfSp:addChild(showName2)	
	end
end

function playerCustomDialogTab2:saveEvent()
	local _isCanSave=false --是否可以保存

	--[[--暂时没有用上
							local cfCfg = titleCfg.list[tostring(self.curSelectedChatFrameId)]
							
							if cfCfg.type==1 and cfCfg.gemCost>0 then
								local count=self:checkJiesuo(self.curSelectedChatFrameId)
								if count==0 then
									_isCanSave=false
								end
							elseif cfCfg.type==4 and playerVoApi:getPlayerLevel()<cfCfg.level then
								_isCanSave=false
							elseif cfCfg.type==5 and playerVoApi:getVipLevel()<cfCfg.vip then
								_isCanSave=false
							end
	]]

	if self.curChooseId > 1 then
		for k,v in pairs(self.tvTb) do
			if tonumber(v.key) == self.curChooseId then
				_isCanSave = true
				do break end
			end
		end
	else
		_isCanSave = true
	end
	if not _isCanSave then --聊天框未解锁
		local tipStr=getlocal("title_buble_undeblocking")
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tipStr,30,nil,true)
		do return end
	end

	local function callback(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			playerVoApi:setTitle(tonumber(self.curChooseId > 1 and self.curChooseId or 0))
			self.curSelectedTitleId = self.curChooseId
            local recordPoint=self.tv:getRecordPoint()
			self.tv:reloadData()
			self.tv:recoverToRecordPoint(recordPoint)
			if self.smallerestSc then
				for k,v in pairs(self.nameTb) do
					v:setScale(self.smallerestSc)
				end
			end
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("save_success"),30,nil,true)
		end
	end
	socketHelper:setTitle(self.curChooseId > 1 and self.curChooseId or 0,callback)
end