acXstqDialog=commonDialog:new()

function acXstqDialog:new(layerNum)
	local nc={}

	setmetatable(nc,self)
	self.__index=self

	nc.layerNum =layerNum
	nc.url      =G_downloadUrl("active/".."acTqbj2018.jpg") or nil
	nc.upPosY   =G_VisibleSizeHeight - 80
	nc.upHeight =220
	nc.cellNum        = acXstqVoApi:getCellNum( )
	nc.curPlayerLevel = playerVoApi:getPlayerLevel()  --获取玩家等级
	nc.isTodayFlag    = acXstqVoApi:isToday()
	return nc
end

function acXstqDialog:dispose()
	self.url      = nil
	self.upPosY   = nil
	self.upHeight = nil
	self.cellNum        = nil
	self.curPlayerLevel = nil
	self.isTodayFlag    = nil
	spriteController:removePlist("public/packsImage.plist")
	spriteController:removeTexture("public/packsImage.png")
	spriteController:removePlist("public/datebaseShow.plist")
	spriteController:removeTexture("public/datebaseShow.png")
end

function acXstqDialog:doUserHandler()
	
	self.panelLineBg:setVisible(false)

	local upBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
	upBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,self.upHeight))
	upBgSp:setAnchorPoint(ccp(0.5,1))
	upBgSp:setPosition(ccp(G_VisibleSizeWidth * 0.5,self.upPosY))
	upBgSp:setOpacity(0)
	self.bgLayer:addChild(upBgSp,1)

	self.downPosy = self.upPosY - self.upHeight
	self.downHeight = self.upPosY - self.upHeight - 20

	local function onLoadIcon(fn,icon)
		if self.bgLayer and self.upPosY and self.upHeight then
	        icon:setAnchorPoint(ccp(0.5,1))
	        icon:setPosition(G_VisibleSizeWidth * 0.5,self.upPosY)
	        self.bgLayer:addChild(icon)
	        icon:setScaleX(G_VisibleSizeWidth/icon:getContentSize().width)
	        icon:setScaleY(self.upHeight/icon:getContentSize().height)
	    end
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local webImage=LuaCCWebImage:createWithURL(self.url,onLoadIcon)

    spriteController:addPlist("public/datebaseShow.plist")--acMjzx2Image
    spriteController:addTexture("public/datebaseShow.png")
    spriteController:addPlist("public/packsImage.plist")
	spriteController:addTexture("public/packsImage.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)


    local timeStrSize = G_isAsia() and 24 or 21
	local acLabel     = GetTTFLabel(acXstqVoApi:getTimer(),22,"Helvetica-bold")
    acLabel:setPosition(ccp(G_VisibleSizeWidth *0.5, self.upHeight - 25))
    upBgSp:addChild(acLabel,1)
    acLabel:setColor(G_ColorYellowPro2)
    self.timeLb=acLabel

	local upDesc = GetTTFLabelWrap(getlocal("activity_tqbj_topTip"),G_isAsia() and 24 or 21,CCSizeMake(350,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    upDesc:setAnchorPoint(ccp(0.5,0.5))
    upDesc:setPosition(ccp(G_VisibleSizeWidth * 0.5,self.upHeight * 0.5))
    upBgSp:addChild(upDesc,1)

    local function touchTip() acXstqVoApi:showInfoTipTb(self.layerNum + 1) end 


    local function touchTip()
		local tabStr={getlocal("activity_tqbj_tip1"),getlocal("activity_tqbj_tip2"),getlocal("activity_xstq_info3"),getlocal("activity_tqbj_tip4")}
		require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
		tipShowSmallDialog:showStrInfo(self.layerNum+5,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),tabStr)
	end
    G_addMenuInfo(upBgSp,self.layerNum,ccp(G_VisibleSizeWidth - 40,self.upHeight - 45),{},nil,nil,nil,touchTip,true)
    local function goRecharge()
		vipVoApi:showRechargeDialog(self.layerNum+1)
		activityAndNoteDialog:closeAllDialog()
	end
	local btnScale,priority=0.9,-(self.layerNum-1)*20-4
	local rechargeBtn,rechargeMenu = G_createBotton(upBgSp,ccp(G_VisibleSizeWidth * 0.84,40),{getlocal("new_recharge_recharge_now")},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",goRecharge,btnScale,priority)

end

function acXstqDialog:initTableView()
	self.cellHeight = 180
	self.cellWidth  = G_VisibleSizeWidth - 40
	local downBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
    downBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40,self.downHeight))
    downBg:setAnchorPoint(ccp(0,0))
    downBg:setPosition(20,20)
    self.bgLayer:addChild(downBg,10)

    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 40, self.downHeight - 2),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(0,0)
	downBg:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(120)

end

function acXstqDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
	    return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(self.cellWidth,self.cellHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local useIdx = idx + 1--self.cellNum - idx
        local curTopAwardNum,curRecharge,curAwardTb,curAwardNum = acXstqVoApi:getCurCellAwardAndRechargeNum(useIdx,self.curPlayerLevel)
        local isCanRec,recNum = acXstqVoApi:getCurCellInfo(useIdx )
        self:initCurCell(idx,useIdx,cell,curTopAwardNum,curRecharge,curAwardTb,curAwardNum,isCanRec,recNum)
     	return cell
    end
end

function acXstqDialog:initCurCell(oldIdx,curIdx,parent,canRecTopNum,needRecharge,awardTb,awardTbNum,isCanRec,recNum)
	local idxInPic = oldIdx < 6 and 6 - oldIdx or 1
	local titleHeight = 50
	local cellTitleBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,0,1,32),function () end)
	cellTitleBg:setContentSize(CCSizeMake(self.cellWidth - 6,titleHeight))
	cellTitleBg:setAnchorPoint(ccp(0,1))
	cellTitleBg:setPosition(2,self.cellHeight - 2)
	parent:addChild(cellTitleBg)

	local title = GetTTFLabel(getlocal("activity_tqbj_levelStr",{needRecharge}),23,"Helvetica-bold")
	title:setColor(G_ColorYellowPro2)
	title:setAnchorPoint(ccp(0,0.5))
	title:setPosition(25,cellTitleBg:getContentSize().height * 0.5)
	cellTitleBg:addChild(title)
	
	local cellHeight2 = self.cellHeight - titleHeight

	local leftPos = ccp(self.cellWidth * 0.13,cellHeight2 * 0.5)
	self:initSunShine(parent,titleHeight,leftPos)
	local function curCellAwardHandeler( )

	end 
	local awardBox = LuaCCSprite:createWithSpriteFrameName("packs"..idxInPic..".png",curCellAwardHandeler)
	awardBox:setTouchPriority(-(self.layerNum-1)*20-3)
	awardBox:setPosition(leftPos.x + 5 , leftPos.y)
	parent:addChild(awardBox,2)

	----========---------========---------========---------========-----
	local useScale = 0.32
	for i=1,awardTbNum do
		local reward=awardTb[i]
		local function showNewReward()
			-- if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
				G_showNewPropInfo(self.layerNum+1,true,true,nil,reward,nil,nil,nil,nil,true)
			-- end
			return false
		end
		local icon,scale=G_getItemIcon(reward,80,true,self.layerNum,showNewReward)
		icon:setTouchPriority(-(self.layerNum-1)*20-3)
		-- icon:setIsSallow(false)
		icon:setAnchorPoint(ccp(0.5,0.5))	

		icon:setPosition(self.cellWidth * useScale + 100*(i - 1),cellHeight2 * 0.5)

		G_noVisibleInIcon(reward,icon,101)

		parent:addChild(icon)
		local numLb=GetTTFLabel("×"..FormatNumber(reward.num),22)
		numLb:setAnchorPoint(ccp(1,0))
		numLb:setPosition(icon:getContentSize().width - 5,5)
		icon:addChild(numLb,2)
		numLb:setScale(0.9/scale)

		local numBg=CCSprite:createWithSpriteFrameName("allianceHeaderBg_black.png")--LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
        numBg:setAnchorPoint(ccp(0.5,0))
        numBg:setScaleX((icon:getContentSize().width -2 ) / numBg:getContentSize().width)
        numBg:setScaleY((numLb:getContentSize().height + 2) / numBg:getContentSize().height)
        -- numBg:setContentSize(CCSizeMake(90,numLb:getContentSize().height*numLb:getScale() - 2))
        numBg:setPosition(ccp(icon:getContentSize().width * 0.5 ,5))
        numBg:setOpacity(150)
        icon:addChild(numBg,1) 
	end
	----========---------========---------========---------========-----
	-- local posArx = G_getCurChoseLanguage() == "ar" and -15 or 0
	local strSize2,posArx = 22,0
	if G_getCurChoseLanguage() == "ar" then
		strSize2,posArx = 17,0
	end
	local recLb = GetTTFLabel(getlocal("hadRecStr",{recNum,canRecTopNum}),strSize2,"Helvetica-bold")
	recLb:setPosition(self.cellWidth * 0.86 + posArx,cellHeight2 * 0.7)
	parent:addChild(recLb)
	recLb:setColor(G_ColorGreen2)

	if isCanRec then
		local function recHandle()
			-- print("recHandle : curIdx===>>",curIdx)
			local function socketEndCall( )
				G_ShowFloatingBoard()
				local recordPoint = self.tv:getRecordPoint()
				self.tv:reloadData()
				self.tv:recoverToRecordPoint(recordPoint)
			end 
			acXstqVoApi:recSocket(curIdx,socketEndCall)
		end
		local btnScale,priority=0.7,-(self.layerNum-1)*20-3
		local rechargeBtn,rechargeMenu = G_createBotton(parent,ccp(self.cellWidth * 0.86, cellHeight2 * 0.32),{getlocal("daily_scene_get")},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",recHandle,btnScale,priority)

	else
		local notRecLb = GetTTFLabelWrap(getlocal("local_war_incomplete"),23,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
		notRecLb:setPosition(self.cellWidth * 0.86, cellHeight2 * 0.36)
		parent:addChild(notRecLb)

		if recNum >= canRecTopNum then
			recLb:setColor(G_ColorRed3)
			notRecLb:setString(getlocal("todayTaskEnd"))
			notRecLb:setColor(G_ColorGray)
			if not G_isAsia() then
				notRecLb:setFontSize(17)
			end
		end

	end

	local cellLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 1, 1, 1),function() end)
    cellLine:setContentSize(CCSizeMake(self.cellWidth - 6, cellLine:getContentSize().height))
    cellLine:setPosition(ccp(self.cellWidth * 0.5,2))
    parent:addChild(cellLine)
end

function acXstqDialog:initSunShine( parent ,titleHeight , leftPos)
	local rewardCenterBtnBg = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
    rewardCenterBtnBg:setOpacity(0)
    parent:addChild(rewardCenterBtnBg,1)
    rewardCenterBtnBg:setPosition(leftPos)
    rewardCenterBtnBg:setScaleY(1/1.25)
    rewardCenterBtnBg:setScale(0.72)
    for i=1,2 do
      local realLight = CCSprite:createWithSpriteFrameName("equipShine.png")
      realLight:setScale(1.4)
      realLight:setPosition(getCenterPoint(rewardCenterBtnBg))
      rewardCenterBtnBg:addChild(realLight)  
      local roteSize = i ==1 and 360 or -360
      local rotate1=CCRotateBy:create(4, roteSize)
      local repeatForever = CCRepeatForever:create(rotate1)
      realLight:runAction(repeatForever)
    end
end

function acXstqDialog:tick( )
	if acXstqVoApi:isEnd()==true then
		self:close()
		do return end
	end
	if self.timeLb then
    	self.timeLb:setString(acXstqVoApi:getTimer())
    end

    local isEnd=acXstqVoApi:isEnd()
    if isEnd==false then
        local todayFlag=acXstqVoApi:isToday()
        if self.isTodayFlag==true and todayFlag==false and self.tv then
            self.isTodayFlag=false
            acXstqVoApi:removeCurData()
            self.tv:reloadData()
        end
    end
end
