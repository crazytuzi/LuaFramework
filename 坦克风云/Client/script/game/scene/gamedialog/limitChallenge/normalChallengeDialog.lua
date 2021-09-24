-- @Author hj
-- @Date 2018-10-15
-- @Description 普通挑战

normalChallengeDialog = commonDialog:new()

function normalChallengeDialog:new( ... )
	local nc = {
		curIndex = 1,
		tabItemList = {},
		maxTankPage = 6,
		outScreenPos = ccp(9999,20),
		displayTankPage = 5,
		curTankPage = 1,
		timeInterval = 0.3,
		switchFlag = false,
		tankSpTb = {},
		tankTb = {},
		disPlayPageTb = {},
		centerPos = ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-82-282-75-30-30-75),
		taskTb = {},
		pointTb = {},
		showTb = {},
		sizeTb = {},
		updateFlag = 0,
		requestFlag = 0,
		oldTime = 0,
		-- tank动画信息
		displayPosCfg = {
			{G_VisibleSizeWidth/2-260,0.8,0.5},
	    	{G_VisibleSizeWidth/2-140,0.8,0.5},
	    	{G_VisibleSizeWidth/2-10,1.2,1},
	   	 	{G_VisibleSizeWidth/2+120,0.8,0.5},
	    	{G_VisibleSizeWidth/2+240,0.8,0.5},
		},
		leftCfg = {G_VisibleSizeWidth/2-360,0.8,0.5},
		rightCfg = {G_VisibleSizeWidth/2+360,0.8,0.5},
	}
	setmetatable(nc,self)
	self.__index = self
    return nc
end

function normalChallengeDialog:doUserHandler( ... )


	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	spriteController:addPlist("public/limitChallenge.plist")
	spriteController:addTexture("public/limitChallenge.png")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

	spriteController:addPlist("public/acRadar_images.plist")
	spriteController:addTexture("public/acRadar_images.png")

	spriteController:addPlist("public/packsImage.plist")
	spriteController:addTexture("public/packsImage.png")
	spriteController:addPlist("public/acThfb.plist")
    spriteController:addTexture("public/acThfb.png")
	spriteController:addPlist("public/smbdPic.plist")
    spriteController:addTexture("public/smbdPic.png")

	if self.panelLineBg then
		self.panelLineBg:setVisible(false)
	end
	if self.panelTopLine then
		self.panelTopLine:setVisible(false)
	end
	
	local tabLine=LuaCCScale9Sprite:createWithSpriteFrameName("yh_ltzdzHelp_tabLine.png",CCRect(4,3,1,1),function()end)
    tabLine:setContentSize(CCSizeMake(G_VisibleSizeWidth,tabLine:getContentSize().height))
    tabLine:setAnchorPoint(ccp(0.5,1))
    tabLine:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-82)
    self.bgLayer:addChild(tabLine,5)

    local panelBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelBgShade.png",CCRect(30,0,2,3),function ()end)
    panelBg:setAnchorPoint(ccp(0.5,0))
    panelBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-82))
    panelBg:setPosition(G_VisibleSizeWidth/2,5)
    self.bgLayer:addChild(panelBg)


    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)

    local function onLoadIcon(fn,icon)
		if self and self.bgLayer and tolua.cast(self.bgLayer,"CCLayer") then
			icon:setAnchorPoint(ccp(0.5,1))
			icon:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-82))
			self.bgLayer:addChild(icon)
		end
	end
	local webImage=LuaCCWebImage:createWithURL(G_downloadUrl("limittask/normalChallenge.jpg"),onLoadIcon)

	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
   
   --标题框
	local titleBacksprie = LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png",CCRect(103,0,2,80),function()end)
	self.bgLayer:addChild(titleBacksprie,10)
	titleBacksprie:setAnchorPoint(ccp(0.5,1))
	titleBacksprie:setContentSize(CCSizeMake(G_VisibleSizeWidth,90))
	titleBacksprie:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-82))

	--活动时间
 	local acTimeLb=GetTTFLabel(limitChallengeVoApi:getTimeStr(),25,true)
	acTimeLb:setPosition(ccp(titleBacksprie:getContentSize().width/2,titleBacksprie:getContentSize().height-33))
	acTimeLb:setColor(G_ColorYellowPro)
	titleBacksprie:addChild(acTimeLb)
	self.acTimeLb=acTimeLb

	self.taskTb,self.pointTb,self.showTb = limitChallengeVoApi:getNormalTask()
	self:initSizeTb()

	-- i说明
	local function touchTip()
		local tabStr={getlocal("limitChanllengeI1"),getlocal("limitChanllengeI2",{limitChallengeVoApi:getRankNum()}),getlocal("limitChanllengeI3"),getlocal("limitChanllengeI4"),getlocal("limitChanllengeI5")}
		require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
		tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),tabStr)
	end
	G_addMenuInfo(titleBacksprie,self.layerNum,ccp(titleBacksprie:getContentSize().width-40,45),{},nil,nil,28,touchTip,true)
	self:initGift()
	self:initDown()
end

function normalChallengeDialog:initDown( ... )

    for i=1,3 do
    	local strSize = 25
    	if G_isAsia() == false then
    		strSize = 20
    	end
		local function touchInfo( ... )
			self:touchInfo(i)
		end
		local tabItem = G_createBotton(self.bgLayer,ccp(20+72.5+150*(i-1),G_VisibleSizeHeight-87-282-37),{getlocal("limitChanllengeBtText"..i),strSize},"yh_ltzdzHelp_tab.png","yh_ltzdzHelp_tab_down.png","yh_ltzdzHelp_tab_down.png",touchInfo,1,-(self.layerNum-1)*20-4,nil,nil,nil,true)
		if self.curIndex == i then
			tabItem:setEnabled(false)
		end
		self.tabItemList[i] = tabItem
	end

	local downSpire = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
	downSpire:setContentSize(CCSizeMake(G_VisibleSizeWidth-30,G_VisibleSizeHeight-82-282-75-30-30))
	downSpire:setAnchorPoint(ccp(0.5,0))
	downSpire:setPosition(ccp(G_VisibleSizeWidth/2,70))
	self.bgLayer:addChild(downSpire)
	
	local tvHeight = G_VisibleSizeHeight-82-282-75-30-40
    local tvWidth = G_VisibleSizeWidth-40

    local function callBack( ... )
    	return self:eventHandler(...)
    end

    local hd= LuaEventHandler:createHandler(callBack)
 	local tasktv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth,tvHeight),nil)
	tasktv:setPosition(ccp(5,5))
	tasktv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
	tasktv:setMaxDisToBottomOrTop(120)
	self.tasktv = tasktv
    downSpire:addChild(tasktv)

    local strSize = 20
    if G_isAsia() == false or G_getCurChoseLanguage() == "ko" then
    	strSize = 18
    end

    local tipLabel = GetTTFLabelWrap(getlocal("limitChanllengeTip1"),strSize,CCSizeMake(550,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    tipLabel:setAnchorPoint(ccp(0.5,1))
    tipLabel:setPosition(ccp(G_VisibleSizeWidth/2,60))
    tipLabel:setColor(G_ColorYellowPro)
    self.tipLabel = tipLabel
    self.bgLayer:addChild(tipLabel)

end

function normalChallengeDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
        return self:getCellNum()
    elseif fn=="tableCellSizeForIndex" then
        return self:getCellSize(idx)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        self:initCell(cell,idx)
        return cell
    elseif fn=="ccTouchBegan" then
    	return true
    elseif fn=="ccTouchMoved" then
    elseif fn=="ccScrollEnable" then
    end
end

function normalChallengeDialog:initTableView( ... )
	-- body
end

function normalChallengeDialog:initGift( ... )

	giftNode = CCNode:create()
	giftNode:setContentSize(CCSizeMake(640,282))
	giftNode:setAnchorPoint(ccp(0.5,1))
	giftNode:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-82))
	self.giftNode = giftNode
	self.bgLayer:addChild(giftNode,2)

	local point = limitChallengeVoApi:getNpoint()
	local minusPoint = 0

	local giftDetail = limitChallengeVoApi:getRewardNormalDetail()
	if giftDetail and giftDetail.scoreList and giftDetail.reward then
		local scoreList = giftDetail.scoreList
		minusPoint = self:getMinusPoint(scoreList,point)
		for k,v in pairs(scoreList) do
			local posX 
			local posY
			local function giftHandler( ... )
				if G_checkClickEnable()==false then
	            	do return end
		        else
		            base.setWaitTime=G_getCurDeviceMillTime()
		        end
		        PlayEffect(audioCfg.mouseClick)
				require "luascript/script/game/scene/gamedialog/activityAndNote/acThrivingSmallDialog"
		        local rewardTb = FormatItem(giftDetail.reward[k],nil,true)
		        local titleStr = getlocal("limitChanllengeBox",{v})
		        local descStr = getlocal("limitChanllengeBoxDesc",{v})
		        local needTb = {"xstz",titleStr,descStr,rewardTb,SizeOfTable(rewardTb)}
		        local rewardDialog = acThrivingSmallDialog:new(self.layerNum+1,needTb)
		        rewardDialog:init()
			end
			local imgStr = self:getGiftimg(k)
			local giftSp = LuaCCSprite:createWithSpriteFrameName(imgStr,giftHandler)
			giftSp:setScale(0.9)
			giftSp:setAnchorPoint(ccp(0.5,0.5))
			if k == 1 then
				posX = 108
				posY = 87
			elseif k == 2 then
				posX = G_VisibleSizeWidth/2
				posY = 87
			else
				posX = G_VisibleSizeWidth-108
				posY = 87
			end
			giftSp:setPosition(ccp(posX,posY))
			giftNode:addChild(giftSp,2)

			local pd = point.."/"..v
			local detailLabel = GetTTFLabel(pd,22,true)
			detailLabel:setAnchorPoint(ccp(0.5,1))
			detailLabel:setPosition(ccp(giftSp:getContentSize().width/2,3))
			giftSp:addChild(detailLabel)
			giftSp:setTouchPriority(-(self.layerNum-1)*20-4)
			if point < v then
				detailLabel:setColor(G_ColorRed)
			else
				local levelBg = LuaCCScale9Sprite:createWithSpriteFrameName("newBlackFadeBar.png",CCRect(0,0,1,9),function ()end)
				levelBg:setContentSize(CCSizeMake(giftSp:getContentSize().width,30))
				levelBg:setAnchorPoint(ccp(0.5,0.5))
				levelBg:setPosition(ccp(giftSp:getContentSize().width/2,giftSp:getContentSize().height/2-10))
				local getLabel = GetTTFLabel(getlocal("already_sent"),20,true)
				getLabel:setAnchorPoint(ccp(0.5,0.5))
				getLabel:setPosition(ccp(levelBg:getContentSize().width/2,levelBg:getContentSize().height/2))
				levelBg:addChild(getLabel)
				giftSp:addChild(levelBg)
				detailLabel:setColor(G_ColorGreen)
			end

		end
	end
	local pointLabel = GetTTFLabel(getlocal("limitChanllengePoint",{point}),22,true)
	pointLabel:setAnchorPoint(ccp(0,1))
	pointLabel:setPosition(ccp(60,282-90))
	giftNode:addChild(pointLabel,2)
	local integralIcon1 = CCSprite:createWithSpriteFrameName("acRadar_integralIcon.png")
    integralIcon1:setAnchorPoint(ccp(0,0.5))
    integralIcon1:setPosition(ccp(pointLabel:getContentSize().width+20,pointLabel:getContentSize().height/2))
    pointLabel:addChild(integralIcon1)
    local nextPointLabel
    if minusPoint <= 0 then
    	nextPointLabel = GetTTFLabel(getlocal("limitChanllengeMaxPoint"),22,true)
    else
		nextPointLabel = GetTTFLabel(getlocal("limitChanllengeNextPoint",{minusPoint}),22,true)
    end
	nextPointLabel:setAnchorPoint(ccp(0,1))
	nextPointLabel:setPosition(ccp(60,282-100-pointLabel:getContentSize().height))
	giftNode:addChild(nextPointLabel,2)
	local integralIcon2 = CCSprite:createWithSpriteFrameName("acRadar_integralIcon.png")
    integralIcon2:setAnchorPoint(ccp(0,0.5))
    integralIcon2:setPosition(ccp(nextPointLabel:getContentSize().width+20,pointLabel:getContentSize().height/2))
    nextPointLabel:addChild(integralIcon2)
    if minusPoint <= 0 then
    	integralIcon2:setVisible(false)
    end

end


-- 获取下阶段的积分差值
function normalChallengeDialog:getMinusPoint(scoreList,point)
	for k,v in pairs(scoreList) do
		if point < v then
			return (v-point)
		end
	end
	return 0
end

function normalChallengeDialog:getGiftimg(i)
	local str 
	if i == 1 then
		str = "packs3.png"
	elseif i == 2 then
		str = "white_pack.png"
	else
		str = "packs6.png"
	end
	return str

end

function normalChallengeDialog:touchInfo(idx)

	if self.curIndex ~= idx then

		self.curIndex = idx
		for k,v in pairs(self.tabItemList) do
			if k ~= self.curIndex then
				v:setEnabled(true)
			else
				v:setEnabled(false)
			end
		end

		if self.curIndex == 1 then
			self:taskHandler()
		elseif self.curIndex == 2 then
			self:rankHandler()
		else
			self:tankHandler()
		end
	end
end

function normalChallengeDialog:initCell(cell,idx)

	if self.curIndex == 1 then

		local function onclick( ... )
			self:setExpandTb(idx)
			self.tasktv:reloadData()	
		end
		cell:setContentSize(self.sizeTb[idx+1])

		local cellBg = LuaCCScale9Sprite:createWithSpriteFrameName("normalChallengeItem.png",CCRect(5,5,1,1),onclick)
		cellBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-70,30))
	    cellBg:setAnchorPoint(ccp(0.5,1))
	    cellBg:setTouchPriority(-(self.layerNum-1)*20-2)
	    cellBg:setPosition(ccp((G_VisibleSizeWidth-40)/2,cell:getContentSize().height-5))
	    cell:addChild(cellBg)

	    -- 标题
	    -- local key = self:getKVFromTb(idx+1)
	    local str = self:getCellTitle(self.showTb[idx+1])
	    local titleLabel = GetTTFLabel(str,22,true)
	    titleLabel:setAnchorPoint(ccp(0,0.5))
	    titleLabel:setPosition(ccp(30,cellBg:getContentSize().height/2))
	    cellBg:addChild(titleLabel)

	   	local arrowSp = CCSprite:createWithSpriteFrameName("normalChallengeArrow.png")
	   	arrowSp:setAnchorPoint(ccp(0.5,0.5))
	   	arrowSp:setPosition(ccp(cellBg:getContentSize().width-30,cellBg:getContentSize().height/2))
	   	if self.sizeTb[idx+1].height <= 50 then
	   		arrowSp:setRotation(-90)
	   	end
	   	cellBg:addChild(arrowSp)

	   	if self.sizeTb[idx+1].height > 50 then
	   		local count = 0
	   		for k,v in pairs(self.showTb) do
	   			v = self.taskTb[v]	
	   			count = count + 1
	   			if count == (idx+1) then
	   				local temp = 0
	   				local sizeV = G_getSizeForKV(v)
	   				local indexCount = 0
	   				for kk,vv in pairs(v) do
	   					temp = temp + 1
	   					local num = self:getChildNum(vv)
	   					for i=1,num do
							indexCount = indexCount+1
							local expandBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(15,15,2,2),function() end)
		   					expandBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-70,40))
		   					expandBg:setAnchorPoint(ccp(0.5,1))
		   					expandBg:setPosition(ccp((G_VisibleSizeWidth-40)/2,cell:getContentSize().height-40*indexCount))
		   					cell:addChild(expandBg)
		   					expandBg:setOpacity(0)
		   					
		   					local taskCfg = limitChallengeVoApi:getTaskCfg(vv)
		   					local key 
		   					local value
		   					local point

		   					if vv == "ky" or vv == "jz" or vv == "jg" or vv == "jk" or vv == "cr" or vv == "lr" or vv == "gb" or vv == "jb" then
								value = taskCfg[1][1]
		   						if vv == "ky" or vv == "jz" then
		   							value = math.floor(value/60)
		   						end
		   						point = taskCfg[1][2]
						   		key = "limitChanllenge_task_"..vv.."_desc"
		   					elseif vv == "sc" or vv == "gz"  or vv == "yx" then
		   						value = taskCfg[i][1]
		   						point = taskCfg[i][2]
		   						key = "limitChanllenge_task_"..vv.."_desc"
		   					elseif vv == "pj" then
		   						local index 
		   						if i <= (#taskCfg) then
		   							index = i
		   							point = taskCfg[index][2][1]
		   							key = "limitChanllenge_task_pj1_desc"
		   						else
		   							index = i-(#taskCfg)
		   							point = taskCfg[index][2][2]
		   							key = "limitChanllenge_task_pj2_desc"
		   						end
		   						local lvD = taskCfg[index][1][1]
		   						local lvU = taskCfg[index][1][2]
		   						value = lvD.."~"..lvU
		   					else

		   					end

	   						local descLabel = GetTTFLabel(getlocal(key,{value}),20)
	   						descLabel:setAnchorPoint(ccp(0,0.5))
	   						descLabel:setPosition(ccp(30,expandBg:getContentSize().height/2-4))
	   						expandBg:addChild(descLabel)

	   						local pointLabel = GetTTFLabel(point,20)
	   						pointLabel:setAnchorPoint(ccp(1,0.5))
	   						pointLabel:setPosition(ccp(expandBg:getContentSize().width - 20,expandBg:getContentSize().height/2-4))
		   					expandBg:addChild(pointLabel)
		   					
		   					if temp == sizeV and i == num then
		   					else
			   					local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function ()end)
							    lineSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-90,2))
							    lineSp:setAnchorPoint(ccp(0.5,0))
							    lineSp:setPosition(ccp((G_VisibleSizeWidth-70)/2,-5))
							    expandBg:addChild(lineSp)
							end
	   					end
	   				end
	   			end
	   		end
	   	end

	    for i=1,2 do
			local bottomLine = LuaCCScale9Sprite:createWithSpriteFrameName("normalChallengeLine2.png",CCRect(18,5,1,1),function () end)
			bottomLine:setContentSize(CCSizeMake((G_VisibleSizeWidth-65)/2,13))
			bottomLine:setAnchorPoint(ccp(1,0.5))
			bottomLine:setPosition(ccp((G_VisibleSizeWidth-40)/2,3))
	    	if i == 2 then
	    		bottomLine:setScaleX(-1)
	    	end
			cell:addChild(bottomLine)
	    end

	 elseif self.curIndex == 2 then

	 	cell:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,110))

	 	local rank = self:getRank(idx+1)
	 	local grayBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("newListItemBg.png",CCRect(4,4,1,1),function ()end)
	 	grayBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,110))
	 	grayBgSp:setAnchorPoint(ccp(0.5,1))
	 	grayBgSp:setPosition(ccp(cell:getContentSize().width/2,cell:getContentSize().height))
	 	cell:addChild(grayBgSp)

	 	if (idx+1)%2 == 1 then
	 		grayBgSp:setOpacity(0)
	 	end 
	 	
	 	local rankLabel = GetTTFLabel(idx+1,20,true)
	 	rankLabel:setAnchorPoint(ccp(0.5,0.5))
	 	rankLabel:setPosition(ccp(grayBgSp:getContentSize().width/8,grayBgSp:getContentSize().height/2))
	 	cell:addChild(rankLabel)

	 	local reward = FormatItem(rank.reward,nil,true)
	 	for k,v in pairs(reward) do

	        local function showNewPropInfo()
                G_showNewPropInfo(self.layerNum+1,true,true,nil,v)
			end
		    local icon,scale=G_getItemIcon(v,80,false,self.layerNum+1,showNewPropInfo,nil,nil,nil,nil,nil,true)
		   	icon:setTouchPriority(-(self.layerNum-1)*20-2)
		    grayBgSp:addChild(icon)
		    icon:setPosition(ccp(grayBgSp:getContentSize().width*(1/4+3/(#reward+1)/4*k),grayBgSp:getContentSize().height/2))
	 	
		   	local numLb=GetTTFLabel("x"..FormatNumber(v.num),18)
            numLb:setAnchorPoint(ccp(1,0))
            numLb:setPosition(ccp(icon:getContentSize().width-5,5))
            icon:addChild(numLb,1)
            numLb:setScale(1/scale)
	 	end

	 else
	 	local firstPosX = 40
		local iconSize = 100
        local spaceX=(G_VisibleSizeWidth-40-2*firstPosX-4*iconSize)/3
        for i=1,4 do
            local tank=self.tankTb[idx*4+i]
            if tank then
                local tankId=tank.key
                if tankId and tankCfg[tankId] and tankCfg[tankId].icon then
                    local tankSp=CCSprite:createWithSpriteFrameName(tankCfg[tankId].icon)
                    tankSp:setAnchorPoint(ccp(0,1))
                    tankSp:setScale(iconSize/tankSp:getContentSize().width)
                    tankSp:setPosition(firstPosX+(i-1)*(iconSize+spaceX),150-10)
                    cell:addChild(tankSp,2)
                    local nameLb=GetTTFLabelWrap(getlocal(tankCfg[tankId].name),20,CCSizeMake(iconSize,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
                    nameLb:setAnchorPoint(ccp(0.5,1))
                    nameLb:setPosition(tankSp:getPositionX()+iconSize/2,tankSp:getPositionY()-iconSize-5)
                    cell:addChild(nameLb)
                end
            end
        end
	 end
end

function normalChallengeDialog:getRank(index)

	if self.rankTb and #self.rankTb > 0 then 
		for k,v in pairs(self.rankTb) do
			if v.rank and index>= v.rank[1] and index <= v.rank[2] then
				return v
			end
		end
	end

end

function normalChallengeDialog:getCellNum( ... )
	if self.curIndex == 1 then
		return self:getTaskNum()
	elseif self.curIndex == 2 then 
		return limitChallengeVoApi:getRankNum()
	else
		self.tankTb = limitChallengeVoApi:getTankByLevel(self.curTankPage+2)
    	local tc,pertc=SizeOfTable(self.tankTb),4
    	local cellNum= tc%pertc==0 and math.floor(tc/pertc) or (math.floor(tc/pertc)+1)
    	return cellNum
	end
end

function normalChallengeDialog:getTaskNum( ... )
	local count = 0
	for k,v in pairs(self.taskTb) do
		count = count + 1
	end
	return count
end

function normalChallengeDialog:getCellSize(idx)
	if self.curIndex == 1 then
		return self.sizeTb[idx+1]
	elseif self.curIndex == 2 then
		return CCSizeMake(G_VisibleSizeWidth-40,110)
	else
		return CCSizeMake(G_VisibleSizeWidth-40,150)
	end
end

function normalChallengeDialog:initSizeTb( ... )
	self.sizeTb = {}
	for k,v in pairs(self.taskTb) do
		table.insert(self.sizeTb,CCSizeMake(G_VisibleSizeWidth-40,50))
	end
end

function normalChallengeDialog:setExpandTb(idx)
	if self.sizeTb[idx+1].height > 50 then
		self.sizeTb[idx+1].height = 50
		return
	else
		self:initSizeTb()
		local count = 1
		for k,v in pairs(self.showTb) do
			if (idx+1) == count then
				local cellNum = 0
				for kk,vv in pairs(self.taskTb[v]) do
					local num = self:getChildNum(vv)
					cellNum = cellNum + num
				end
				self.sizeTb[idx+1].height = 50 + 40*cellNum
				return
			else
				count = count + 1 
			end
		end

	end
end

function normalChallengeDialog:getChildNum(key)
	local taskCfg = limitChallengeVoApi:getTaskCfg(key)
	if key == "pj" then
		return 2*(#taskCfg)
	else
		return #taskCfg
	end
end


function normalChallengeDialog:getKVFromTb(index)
	local count = 0
	for k,v in pairs(self.taskTb) do
		count = count + 1
		if index == count then
			return k,v
		end
	end
end

function normalChallengeDialog:getCellTitle(key)
	if tonumber(string.sub(key,2,2)) then
		local point = self.pointTb[key]
		return getlocal("limitChanllenge_task_"..tonumber(string.sub(key,2,2)),{point})
	end
end

function normalChallengeDialog:taskHandler( ... )

	if tolua.cast(self.removeNode,"CCClippingNode") then
		self.removeNode:setPosition(ccp(9999,20))
	end

	if tolua.cast(self.rankNode,"CCNode") then
		self.rankNode:setPosition(ccp(9999,20))
	end

	if self.taskTb and self:getTaskNum() > 0 then
	else
		self.taskTb,self.pointTb,self.showTb = limitChallengeVoApi:getNormalTask()
	end
	self:initSizeTb()
	self:refreshTips()
	self.tasktv:setViewSize(CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSizeHeight-82-282-75-30-40))
	self.tasktv:setPosition(ccp(5,5))
	self.tasktv:reloadData()

end


function normalChallengeDialog:rankHandler( ... )

	if tolua.cast(self.removeNode,"CCClippingNode") then
		self.removeNode:setPosition(ccp(9999,20))
	end

	if tolua.cast(self.rankNode,"CCNode") then
		self.rankNode:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-82-282-75-30-30+70))
		self:refreshTips()
		self.tasktv:setViewSize(CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSizeHeight-82-282-75-30-40-70))
		self.tasktv:setPosition(ccp(5,5))
		self.tasktv:reloadData()
		do return end
	end

	if self.rankTb and (#self.rankTb) > 0 then
	else
		self.rankTb = limitChallengeVoApi:getNormalRankData()
	end

	local rankNode=CCNode:create()
	rankNode:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,70))
	rankNode:setAnchorPoint(ccp(0.5,1))
	rankNode:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-82-282-75-30-30+70))
	self.rankNode = rankNode

	local wholeBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("ltzdzNameBg.png",CCRect(4, 4, 1, 1),function () end)
	wholeBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,60))
	wholeBgSp:setAnchorPoint(ccp(0,0))
	wholeBgSp:setPosition(ccp(5,0))
	rankNode:addChild(wholeBgSp)

	local rankLabel = GetTTFLabel(getlocal("alliance_scene_rank"),25,true)
	local rewardLabel = GetTTFLabel(getlocal("award"),25,true)
	rankLabel:setAnchorPoint(ccp(0.5,0.5))
	rewardLabel:setAnchorPoint(ccp(0.5,0.5))
	rankLabel:setColor(G_ColorYellowPro) 
	rewardLabel:setColor(G_ColorYellowPro)
	rankLabel:setPosition(ccp(wholeBgSp:getContentSize().width/8,35))
	rewardLabel:setPosition(ccp(wholeBgSp:getContentSize().width*5/8,35))
	wholeBgSp:addChild(rankLabel)
	wholeBgSp:addChild(rewardLabel)
	
	self.bgLayer:addChild(rankNode)

	self:refreshTips()
	self.tasktv:setViewSize(CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSizeHeight-82-282-75-30-40-70))
	self.tasktv:setPosition(ccp(5,5))
	self.tasktv:reloadData()

end


function normalChallengeDialog:tankHandler( ... )

	if tolua.cast(self.rankNode,"CCNode") then
		self.rankNode:setPosition(ccp(9999,20))
	end

	if self.removeNode and tolua.cast(self.removeNode,"CCClippingNode") then
		self.removeNode:setPosition(ccp(G_VisibleSizeWidth/2,70))
		self:refreshTips()
		self.tasktv:setViewSize(CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSizeHeight-82-282-75-30-40-150))
		self.tasktv:setPosition(ccp(5,5))
		self.tasktv:reloadData()
		do return end
	end

	-- 坦克的等级介绍面板
    local removeNode=CCClippingNode:create()
	removeNode:setContentSize(CCSizeMake(G_VisibleSizeWidth-30,G_VisibleSizeHeight-82-282-75-30-30))
	removeNode:setAnchorPoint(ccp(0.5,0))
    removeNode:setPosition(ccp(G_VisibleSizeWidth/2,70))
    self.removeNode = removeNode

	local stencil=CCDrawNode:getAPolygon(CCSizeMake(G_VisibleSizeWidth-30-20,G_VisibleSizeHeight-82-282-75-30-30),1,1)
	stencil:setPosition(ccp(10,0))
	removeNode:setStencil(stencil)
    self.bgLayer:addChild(removeNode)

    local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function ()end)
    lineSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-30-20,2))
    lineSp:setAnchorPoint(ccp(0.5,0))
    lineSp:setPosition(ccp((G_VisibleSizeWidth-30)/2,G_VisibleSizeHeight-82-282-75-30-30-150+10))
    removeNode:addChild(lineSp)

	for i=1,self.maxTankPage do

        local function touchHandler(object,event,tag)
            if self.switchFlag==true then
                do return end
            end
            if G_checkClickEnable()==false then
        	do
            	return
        	end
    		else
        		base.setWaitTime=G_getCurDeviceMillTime()
    		end
            local offsetPage=tonumber(tag)-math.ceil(self.displayTankPage/2)
           	self:runTankMoveAction(offsetPage)
        end
        local tankSp = LuaCCSprite:createWithSpriteFrameName((i+2).."_t.png",touchHandler)
        tankSp:setPosition(self.outScreenPos)
        tankSp:setTouchPriority(-(self.layerNum-1)*20-4)
        tankSp:setTag(i)
        removeNode:addChild(tankSp,1)
        self.tankSpTb[i]=tankSp
        local levelSp = LuaCCSprite:createWithSpriteFrameName("smbd"..(i+2)..".png",touchHandler)
        levelSp:setAnchorPoint(ccp(1,0))
        levelSp:setPosition(ccp(tankSp:getContentSize().width-20,20))
        tankSp:addChild(levelSp)
    end
    local function rightPageHandler()
		if self.switchFlag==true then
    		do return end
		end
		if G_checkClickEnable()==false then
    	do
        	return
    	end
		else
    		base.setWaitTime=G_getCurDeviceMillTime()
		end
		self:rightPageHandler()
	end
	local function leftPageHandler()
        if self.switchFlag==true then
            do return end
        end
        if G_checkClickEnable()==false then
    	do
        	return
    	end
		else
    		base.setWaitTime=G_getCurDeviceMillTime()
		end
        self:leftPageHandler()
	end

	local arrowCfg={
		  {startPos=ccp(30,removeNode:getContentSize().height/2-40),targetPos=ccp(25,removeNode:getContentSize().height/2-40),callback=leftPageHandler,angle=0},
		  {startPos=ccp(removeNode:getContentSize().width-30,removeNode:getContentSize().height/2-40),targetPos=ccp(removeNode:getContentSize().width-25,removeNode:getContentSize().height/2-40),callback=rightPageHandler,angle=180}
	}
	for i=1,2 do
        local cfg=arrowCfg[i]
        local arrowBtn=GetButtonItem("leftBtnGreen.png","leftBtnGreen.png","leftBtnGreen.png",function () end,11,nil,nil)
        arrowBtn:setRotation(cfg.angle)
        local arrowMenu=CCMenu:createWithItem(arrowBtn)
        arrowMenu:setAnchorPoint(ccp(0.5,0.5))
        arrowMenu:setTouchPriority(-(self.layerNum-1)*20-4)
        arrowMenu:setPosition(cfg.startPos)
        removeNode:addChild(arrowMenu,3)

        local arrowTouchSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,5,5),cfg.callback)
        arrowTouchSp:setTouchPriority(-(self.layerNum-1)*20-4)
        arrowTouchSp:setAnchorPoint(ccp(0.5,0.5))
        arrowTouchSp:setContentSize(CCSizeMake(100,100))
        arrowTouchSp:setPosition(cfg.startPos)
        arrowTouchSp:setOpacity(0)
       	removeNode:addChild(arrowTouchSp,4)

        local moveTo=CCMoveTo:create(0.5,cfg.targetPos)
        local fadeIn=CCFadeIn:create(0.5)
        local carray=CCArray:create()
        carray:addObject(moveTo)
        carray:addObject(fadeIn)
        local spawn=CCSpawn:create(carray)

        local moveTo2=CCMoveTo:create(0.5,cfg.startPos)
        local fadeOut=CCFadeOut:create(0.5)
        local carray2=CCArray:create()
        carray2:addObject(moveTo2)
        carray2:addObject(fadeOut)
        local spawn2=CCSpawn:create(carray2)

        local seq=CCSequence:createWithTwoActions(spawn2,spawn)
        arrowMenu:runAction(CCRepeatForever:create(seq))
	end

	local page = self.curTankPage - 2
    if page<1 then
        page=page+self.maxTankPage
    end

    for i=1,self.displayTankPage do
        self.disPlayPageTb[i]=page
        local tankSp=tolua.cast(self.tankSpTb[page],"LuaCCSprite")
        if tankSp then
            tankSp:setPosition(self.displayPosCfg[i][1],self.centerPos.y)
            tankSp:setScale(self.displayPosCfg[i][2])
            tankSp:setOpacity(255*self.displayPosCfg[i][3])
            tankSp:setTag(i)
        end
        page=page+1
        if page>self.maxTankPage then
            page=1
        end
    end

    self:refreshTips()
	self.tasktv:setViewSize(CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSizeHeight-82-282-75-30-40-150))
	self.tasktv:setPosition(ccp(5,5))
	self.tasktv:reloadData()
end


function normalChallengeDialog:runTankMoveAction(offset)

	if offset == 0 then
	 	do return end	
	else
		if self.switchFlag == false then
			self.switchFlag = true
			local unDisplayPage = self.curTankPage + math.ceil(self.displayTankPage/2)
			if unDisplayPage > self.maxTankPage then
				unDisplayPage = unDisplayPage - self.maxTankPage 
			end
			local targetPos,targetScale,targetFadeRate
			-- 向右移动
			if offset < 0 then
				offset = offset + 1
				self.tankSpTb[unDisplayPage]:setPosition(ccp(self.leftCfg[1],self.centerPos.y))
				self.tankSpTb[unDisplayPage]:setScale(self.leftCfg[2])
	    		table.insert(self.disPlayPageTb,1,unDisplayPage)
	    		for i=1,self.displayTankPage+1 do
		    		local tankSp = self.tankSpTb[self.disPlayPageTb[i]]
		    		tankSp:setTag(i)
		    		if i == (self.displayTankPage+1) then
		            	targetPos,targetScale,targetFadeRate=ccp(self.rightCfg[1],self.centerPos.y),self.rightCfg[2],self.rightCfg[3]
		        	else
		            	targetPos,targetScale,targetFadeRate=ccp(self.displayPosCfg[i][1],self.centerPos.y),self.displayPosCfg[i][2],self.displayPosCfg[i][3]
		        	end
		        	local acArr=CCArray:create()
			        local moveTo=CCMoveTo:create(self.timeInterval,targetPos)
			        local fadeTo = CCFadeTo:create(self.timeInterval,255*targetFadeRate)
			        local scaleTo=CCScaleTo:create(self.timeInterval,targetScale)
			        acArr:addObject(fadeTo)
			        acArr:addObject(moveTo)
			        acArr:addObject(scaleTo)
			        local swpanAc=CCSpawn:create(acArr)
			        local function moveCallBack()
			            if i==(self.displayTankPage+1) then
			                self.curTankPage=self.curTankPage-1
			                if self.curTankPage<1 then
			                    self.curTankPage=self.maxTankPage
			                end
			                self:resetDisplayPage()
			                tankSp:setPosition(self.outScreenPos)
			                -- segmentSp:setScale(self.scaleCfg[page])
			                if offset and offset~=0 then
			                    self.switchFlag = false
			                    self:runTankMoveAction(offset)
			                else
			                    self.switchFlag=false
			                    self.tasktv:reloadData()
			                end
		           		end
			        end
			        local callback=CCCallFunc:create(moveCallBack)
			        local seq=CCSequence:createWithTwoActions(swpanAc,callback)
			        tankSp:runAction(seq)
	    		end
			-- 向左移动
			elseif offset > 0 then
				offset = offset -1
				self.tankSpTb[unDisplayPage]:setPosition(ccp(self.rightCfg[1],self.centerPos.y))
				self.tankSpTb[unDisplayPage]:setScale(self.rightCfg[2])
	    		table.insert(self.disPlayPageTb,unDisplayPage)
	    		for i=1,self.displayTankPage+1 do
		    		local tankSp = self.tankSpTb[self.disPlayPageTb[i]]
		    		if i==1 then
		            	targetPos,targetScale,targetFadeRate=ccp(self.leftCfg[1],self.centerPos.y),self.leftCfg[2],self.leftCfg[3]
		            	tankSp:setTag(self.displayTankPage+1)
		        	else
		            	targetPos,targetScale,targetFadeRate=ccp(self.displayPosCfg[i-1][1],self.centerPos.y),self.displayPosCfg[i-1][2],self.displayPosCfg[i-1][3]
		            	tankSp:setTag(i-1)
		        	end
			        local acArr=CCArray:create()
			        local moveTo=CCMoveTo:create(self.timeInterval,targetPos)
			        local scaleTo=CCScaleTo:create(self.timeInterval,targetScale)
			        local fadeTo = CCFadeTo:create(self.timeInterval,255*targetFadeRate)
			        acArr:addObject(fadeTo)
			        acArr:addObject(moveTo)
			        acArr:addObject(scaleTo)
			        local swpanAc=CCSpawn:create(acArr)
			        local function moveCallBack()
			            if i==1 then
			                self.curTankPage=self.curTankPage+1
			                if self.curTankPage > self.maxTankPage then
			                    self.curTankPage=1
			                end
			                self:resetDisplayPage()
			                tankSp:setPosition(self.outScreenPos)
			                if offset and offset~= 0 then
			                    self.switchFlag=false
			                    self:runTankMoveAction(offset)
			                else
			                    self.switchFlag=false
			                    self.tasktv:reloadData()
			                end
			            end
			        end
			        local callback=CCCallFunc:create(moveCallBack)
			        local seq=CCSequence:createWithTwoActions(swpanAc,callback)
			        tankSp:runAction(seq)
	    		end
			end
		end
	end
end


function normalChallengeDialog:resetDisplayPage( ... )

    self.disPlayPageTb = {}
    local page=self.curTankPage-2
    if page<1 then
        page=page+self.maxTankPage
    end
    for i=1,5 do
        self.disPlayPageTb[i]=page
        local tankSp=self.tankSpTb[page]
        if tankSp then
            if page==self.curTankPage then
                self.removeNode:reorderChild(tankSp,3)
            else
                self.removeNode:reorderChild(tankSp,1)
            end
        end
        page=page+1
        if page>self.maxTankPage then
            page=1
        end
    end
end


function normalChallengeDialog:refreshTips( ... )
	if tolua.cast(self.tipLabel,"CCLabelTTF") then
		if self.curIndex == 2 then
			tolua.cast(self.tipLabel,"CCLabelTTF"):setString(getlocal("limitChanllengeTip"..self.curIndex,{limitChallengeVoApi:getRankNum()}))
		else
			tolua.cast(self.tipLabel,"CCLabelTTF"):setString(getlocal("limitChanllengeTip"..self.curIndex))
		end
	end
end

function normalChallengeDialog:leftPageHandler( ... )
	self:runTankMoveAction(-1)
end

function normalChallengeDialog:rightPageHandler( ... )
	self:runTankMoveAction(1)
end


function normalChallengeDialog:tick( ... )

	-- if limitChallengeVoApi:refresh() == true and self.updateFlag == 0 then
	-- 	print("hjtets1")
	-- 	self.updateFlag = 1
	-- 	self.oldTime = base.serverTime
	-- end

	-- if self.updateFlag == 1 and self.requestFlag == 0 then
	-- 	-- 后台要求 10s后再调接口刷新
	-- 	print("hjtets2")
	-- 	if base.serverTime - self.oldTime >= 10 then
	-- 		print("hjtets3")
	-- 		self.requestFlag = 1
	-- 		self:refreshTV()				
	-- 	end
	-- end
	if limitChallengeVo:getFlag() and limitChallengeVo:getFlag() == true then
		-- limitChallengeVoApi:updateData(sData.data.limittask)
		-- self.updateFlag = 0	
		-- self.requestFlag = 0
		self.taskTb,self.pointTb,self.showTb = limitChallengeVoApi:getNormalTask()
		self:initSizeTb()
		self.giftNode:removeFromParentAndCleanup(true)
		self:initGift()
		if self.curIndex == 1 then
			self.tasktv:reloadData()
		end
		limitChallengeVo:setFlag(false)
	end

	self:refreshTime()
end

function normalChallengeDialog:refreshTime( ... )
	if tolua.cast(self.acTimeLb,"CCLabelTTF") then
    	self.acTimeLb:setString(limitChallengeVoApi:getTimeStr())
    end
end

-- 刷新数据
function normalChallengeDialog:refreshTV( ... )

	local function callback(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then  
			if sData and sData.data and sData.data.limittask then
				limitChallengeVoApi:updateData(sData.data.limittask)
				self.updateFlag = 0	
				self.requestFlag = 0
				self.taskTb,self.pointTb,self.showTb = limitChallengeVoApi:getNormalTask()
				self:initSizeTb()
				self.giftNode:removeFromParentAndCleanup(true)
				self:initGift()
				if self.curIndex == 1 then
					self.tasktv:reloadData()
				end
			end
		end
	end
	socketHelper:xstzGetTask(callback)

end

function normalChallengeDialog:refreshNew( ... )

end


function normalChallengeDialog:dispose( ... )

	spriteController:removePlist("public/limitChallenge.plist")
	spriteController:removePlist("public/acRadar_images.plist")
	spriteController:removePlist("public/packsImage.plist")
	spriteController:removePlist("public/acThfb.plist")
	spriteController:removePlist("public/smbdPic.plist")
    spriteController:removeTexture("public/smbdPic.png")
    spriteController:removeTexture("public/acThfb.png")
	spriteController:removeTexture("public/packsImage.png")
	spriteController:removeTexture("public/acRadar_images.png")
	spriteController:removeTexture("public/limitChallenge.png")
end