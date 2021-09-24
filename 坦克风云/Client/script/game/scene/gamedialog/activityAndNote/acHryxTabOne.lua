acHryxTabOne={}
function acHryxTabOne:new(parent)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.parent    = parent
	nc.bgLayer   = nil
	nc.isIphone5 = G_isIphone5()

	nc.showLayerTop  = nil                                                                        
	nc.showLayerBg   = nil                                                                           
	nc.timeLb        = nil                                                                                          
	nc.rechargeLb    = nil                                                                              
	nc.buyItemButton = nil                                                                     
	nc.buyLb         = nil                                                                                             
	nc.buyCostIcon   = nil                                                                           
	nc.stateLb       = nil                                                                                       
	nc.lockSp        = nil                                                                                          
	nc.showTopY      = G_VisibleSizeHeight - 160
	nc.showTopHeight = 400

	return nc
end
function acHryxTabOne:dispose( )
	if self.circelAc then
		self.circelAc:stop()
	end
	if self.buildingAc then
		self.buildingAc:stopAllActions()
		self.buildingAc = nil
	end
	if self.circelAc and self.circelAc.stop then
		self.circelAc:stop()
		self.circelAc=nil
	end  
	self.bgLayer   = nil
	self.parent    = nil
	self.isIphone5 = nil

	self.showLayerTop  = nil
	self.showLayerBg   = nil
	self.timeLb        = nil
	self.rechargeLb    = nil
	self.buyItemButton = nil
	self.buyLb         = nil
	self.buyCostIcon   = nil
	self.stateLb       = nil
	self.lockSp        = nil
	self.shopList      = nil
	self.shopKeyList   = nil
end
function acHryxTabOne:init(layerNum)
	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()
	
	self.tvCellSize = CCSizeMake(616, 80)

	self:initTopShow()
	self:initTableView()
	return self.bgLayer
end

function acHryxTabOne:initTopShow( )
    self.rtflag = acHryxVoApi:isRewardTime() --是否是领奖时间
	local showTopY = self.showTopY
    local showTopWidth = G_VisibleSizeWidth
    local showTopHeight = self.showTopHeight
    -- 上边显示Layer
    self.showLayerTop = CCLayer:create()
    self.showLayerTop:ignoreAnchorPointForPosition(false)
    self.showLayerTop:setAnchorPoint(ccp(0.5, 1))
    self.showLayerTop:setContentSize(CCSize(showTopWidth, showTopHeight))
    self.showLayerTop:setPosition(ccp(showTopWidth / 2, showTopY))
    self.bgLayer:addChild(self.showLayerTop)

    -- 背景
    self.showLayerBg = CCLayer:create()
    self.showLayerBg:setPosition(ccp(showTopWidth / 2, showTopHeight / 2))
    self.showLayerTop:addChild(self.showLayerBg)
    -- 网络下载的图
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
    local function onLoadIcon(fn,icon)
        if self and self.showLayerBg and tolua.cast(self.showLayerBg, "CCLayer") then
            icon:setAnchorPoint(ccp(0.5,0.5))
            icon:setPosition(ccp(0, 0))
            self.showLayerBg:addChild(icon)
        end
    end
    local webImage = LuaCCWebImage:createWithURL(G_downloadUrl("active/acHryxImage_tab1.jpg"), onLoadIcon)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    -- 梯形底
    local bgShade = LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png", CCRect(103, 0, 2, 80), function () end)
    bgShade:setContentSize(CCSizeMake(showTopWidth, 80))
    bgShade:setAnchorPoint(ccp(0.5, 1))
    bgShade:setPosition(showTopWidth / 2, showTopHeight)
    self.showLayerTop:addChild(bgShade,1)

    local function touch(tag, object)
        PlayEffect(audioCfg.mouseClick)
        -- 说明按钮详细
        local tabStr = {}
        local tabColor = {}
        local tabAlignment = {}
        tabStr = {"\n", getlocal("activity_hryx_tab1_tip6"),"\n", getlocal("activity_hryx_tab1_tip5",{}),"\n", getlocal("activity_hryx_tab1_tip4",{5}),"\n", getlocal("activity_hryx_tab1_tip3"), "\n", getlocal("activity_hryx_tab1_tip2",{acHryxVoApi:getNeedPlayerLv( ), acHryxVoApi:getRechargeNeedLimit()}), "\n", getlocal("activity_hryx_tab1_tip1"), "\n"}
        tabColor = {nil, nil, nil, nil, nil, nil}
        tabAlignment = {nil, nil, nil, nil, nil, nil}
        local td=smallDialog:new()
        local dialog=td:init("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10),
            nil, true, true, self.layerNum + 1, tabStr, 25, tabColor, nil, nil, nil, tabAlignment)
        sceneGame:addChild(dialog, self.layerNum + 1)
    end

    local menuItemDesc = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", touch)
    menuItemDesc:setAnchorPoint(ccp(0.5, 0.5))
    local menuDesc = CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
    menuDesc:setPosition(ccp(showTopWidth - 40, showTopHeight - 40))
    self.showLayerTop:addChild(menuDesc,1)

    -- local timeLb = GetTTFLabel("", 25)
    -- timeLb:setAnchorPoint(ccp(0.5, 0))
    -- timeLb:setPosition(ccp(showTopWidth / 2, showTopHeight - 40))
    -- self.showLayerTop:addChild(timeLb,1)
    -- self.timeLb = timeLb


    -- local timeBgHeight = 35
    -- local timeBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    -- timeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, timeBgHeight))
    -- timeBg:setAnchorPoint(ccp(0.5, 1))
    -- timeBg:setOpacity(0)
    -- timeBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 85)
    -- self.mainLayer:addChild(timeBg)
    
    local timeStr1 = acHryxVoApi:getTimeStr()
    local timeStr2 = acHryxVoApi:getRewardTimeStr()
    local lbRollView, timeLb, rewardLb = G_LabelRollView(CCSizeMake(showTopWidth - 20, 30), timeStr1, 22, kCCTextAlignmentCenter, G_ColorGreen, nil, timeStr2, G_ColorYellowPro3, 2, 2, 2, nil)
    lbRollView:setPosition(10, showTopHeight - 40)--timeBg:getContentSize().height * 0.3)
     self.showLayerTop:addChild(lbRollView,1)
    self.timeLb = timeLb
    self.rTimeLb = rewardLb


    local buildingPic = acHryxVoApi:getCurPicName(1)
    self:showBuildingFunction(buildingPic,self.showLayerTop,ccp(20,15),ccp(0,0),0.7)

    self:updateShowTop(true)
    self:tick()
end
function acHryxTabOne:tick()
    if acHryxVoApi:isEnd() == true then
        self:close()
        do return end
    end

    -- local acVo = acHryxVoApi:getAcVo()
    -- if acVo and self.timeLb and tolua.cast(self.timeLb, "CCLabelTTF") then
    --     self.timeLb:setString(acHryxVoApi:getTimeStr())
    -- end
    if self.timeLb and tolua.cast(self.timeLb, "CCLabelTTF") then
        self.timeLb:setString(acHryxVoApi:getTimeStr())
    end
    if self.rTimeLb and tolua.cast(self.rTimeLb, "CCLabelTTF") then
        self.rTimeLb:setString(acHryxVoApi:getRewardTimeStr())
    end
    self:updateUI()
end

function acHryxTabOne:updateShowTop(isInit)
    local unlockId = acHryxVoApi:getAcVo().rankReward

    if self.rechargeLb then
        self.rechargeLb:removeFromParentAndCleanup(true)
    end
    if self.topTip then
    	self.topTip:removeFromParentAndCleanup(true)
    end

    local recharge1 = acHryxVoApi:getV()
    local recharge2 = acHryxVoApi:getAcVo().recharge

    if recharge1 >= recharge2 then
        recharge1 = recharge2
    end

    local rechargeStr = getlocal("activity_wxgx_info1",{recharge1, recharge2})
    local colorTab = {G_ColorWhite, G_ColorYellowPro2, G_ColorWhite}
    local rechargeLb, lbHeight = G_getRichTextLabel(rechargeStr, colorTab, 22, G_VisibleSizeWidth - 100, kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
    rechargeLb:setAnchorPoint(ccp(0.5, 1))
    rechargeLb:setPosition(ccp(G_VisibleSizeWidth / 2, self.showTopHeight - 65))
    rechargeLb:setVisible(false)
    self.showLayerTop:addChild(rechargeLb, 1)
    self.rechargeLb = rechargeLb

    local topTip = GetTTFLabelWrap(getlocal("activity_hryx_tab1_topTip"),20,CCSizeMake(G_VisibleSizeWidth - 100, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop,"Helvetica-bold")
    topTip:setAnchorPoint(ccp(0.5,1))
    topTip:setPosition(G_VisibleSizeWidth / 2, self.showTopHeight - 100)
    self.showLayerTop:addChild(topTip,1)
    topTip:setColor(G_ColorYellowPro)
    self.topTip = topTip

    if isInit == true then
        -- 装备配置
        -- print("unlockId--->>>",unlockId)
        local decorateCfg = exteriorCfg.exteriorLit[unlockId]
        local decorateLv = #decorateCfg.value[1]

        local attrLb = GetTTFLabel(getlocal("activity_wxgx_info2"), 24, true)
        attrLb:setAnchorPoint(ccp(0, 1))
        attrLb:setPosition(ccp(rechargeLb:getPositionX() - 10, rechargeLb:getPositionY() - 130))
        self.showLayerTop:addChild(attrLb)

        local strSize = 22
        local supX = 0
        if G_isAsia() == false or G_getCurChoseLanguage() == "ko" then
            strSize = 15
            supX = 40
        end
        for i,v in ipairs(decorateCfg.attType) do
            local value = decorateCfg.value[i][decorateLv]
            local attstr = value < 1 and tostring(value * 100) .. "%" or value
            attstr = getlocal("decorateAttr" .. v) .. " + " .. attstr
            local nameLb = GetTTFLabel(attstr, strSize)
            nameLb:setAnchorPoint(ccp(0, 1))
            nameLb:setPosition(ccp(attrLb:getPositionX() + 40 - supX, attrLb:getPositionY() - 40 - (i - 1) * 40))
            nameLb:setColor(G_ColorGreen)
            self.showLayerTop:addChild(nameLb)
        end

        local strSize = 24
        local stateLb = GetTTFLabelWrap("", strSize, CCSizeMake(300, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        stateLb:setAnchorPoint(ccp(0.5, 0.5))
        stateLb:setPosition(ccp(G_VisibleSizeWidth / 2 + 130, 40))
        self.showLayerTop:addChild(stateLb)
        self.stateLb = stateLb

    end

    if buildDecorateVoApi:judgeHas(unlockId) and buildDecorateVoApi:isExperience(unlockId) == false then
        self.stateLb:setVisible(true)

        self.stateLb:setColor(G_ColorYellow)
        self.stateLb:setString(getlocal("activity_wxgx_tips3"))
    end

end

function acHryxTabOne:initTableView()
	local middlePosy = self.showTopY - self.showTopHeight - 45
	self.rankList,self.cellNum = acHryxVoApi:getRankList()
	local playerLv = playerVoApi:getPlayerLevel()
    local strSize1,strSize2,strSize3 = 22,20,19
    if not G_isAsia() or ( G_getCurChoseLanguage() == "ja" or G_getCurChoseLanguage() == "ko" ) then
        strSize1,strSize2,strSize3 = 19,17,16
    end

    if playerLv < acHryxVoApi:getAcVo().unlockNeedPlayerlv then
    	local needTip = getlocal("activity_hryx_tab1_bottomTip3",{acHryxVoApi:getAcVo().unlockNeedPlayerlv})
    	local tip3Lb = GetTTFLabelWrap(needTip,strSize1,CCSizeMake(G_VisibleSizeWidth  - 50,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    	tip3Lb:setPosition(G_VisibleSizeWidth *0.5, middlePosy + 16)
    	tip3Lb:setColor(G_ColorRed)
    	self.bgLayer:addChild(tip3Lb)
    else
		local tip1Lb = GetTTFLabelWrap(getlocal("activity_hryx_tab1_bottomTip1"),strSize2,CCSizeMake(G_VisibleSizeWidth - 50,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		tip1Lb:setColor(G_ColorYellowPro)
		tip1Lb:setPosition(G_VisibleSizeWidth * 0.5, middlePosy + 30)
		self.bgLayer:addChild(tip1Lb, 1)

		local tip2Str = getlocal("activity_hryx_tab1_bottomTip2",{acHryxVoApi:getRechargeNeedLimit()})
	    local colorTab = {G_ColorWhite, G_ColorYellowPro2, G_ColorWhite,G_ColorGreen2,G_ColorWhite}
	    local tip2Lb, lbHeight = G_getRichTextLabel(tip2Str, colorTab, strSize3, G_VisibleSizeWidth - 50, kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
	    tip2Lb:setAnchorPoint(ccp(0.5, 1))
	    tip2Lb:setPosition(ccp(G_VisibleSizeWidth * 0.5, middlePosy + 10))
	    self.bgLayer:addChild(tip2Lb, 1)
	end

	local posxTb = {65,215,380,520}
    self.posxTb = posxTb

	local tvH = self.showTopY - self.showTopHeight - 90 -45
    local function eventHandler( ... )
        return self:eventHandler( ... )
    end
    local hdSize = CCSizeMake(self.tvCellSize.width, tvH)
    local hd = LuaEventHandler:createHandler(eventHandler)
    self.tv = LuaCCTableView:createWithEventHandler(hd, hdSize, nil)
    self.tv:setPosition(ccp(18, 20))
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 4)
    self.bgLayer:addChild(self.tv, 2)
    self.tv:setMaxDisToBottomOrTop(120)

    local tableViewBox = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function () end)
    tableViewBox:setContentSize(CCSizeMake(616, hdSize.height + 4 + 45))
    tableViewBox:setAnchorPoint(ccp(0.5, 0))
    tableViewBox:setPosition(ccp(G_VisibleSizeWidth / 2, self.tv:getPositionY() - 2))
    self.bgLayer:addChild(tableViewBox)

    local tvTitleBg = LuaCCScale9Sprite:createWithSpriteFrameName("ltzdzNameBg.png",CCRect(4, 4, 1, 1),function() end)
    tvTitleBg:setContentSize(CCSizeMake(self.tvCellSize.width - 8,45))
    tvTitleBg:setAnchorPoint(ccp(0.5,1))
    tvTitleBg:setPosition(self.tvCellSize.width * 0.5,tableViewBox:getContentSize().height)
    tableViewBox:addChild(tvTitleBg)

    local lbSize= G_isAsia() and 22 or 18
    local lbTb = {"RankScene_rank","playerName","showAttackRank","rechagedGemsNum"}
    for i=1,4 do
    	local label = GetTTFLabel(getlocal(lbTb[i]),lbSize)
    	label:setPosition(posxTb[i],tvTitleBg:getContentSize().height * 0.5)
    	label:setColor(G_ColorYellowPro2)
    	tvTitleBg:addChild(label)
    end


    self.noRankLb=GetTTFLabelWrap(getlocal("activity_fightRanknew_no_rank"),35,CCSizeMake(self.bgLayer:getContentSize().width-80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.noRankLb:setAnchorPoint(ccp(0.5,0.5))
    self.noRankLb:setPosition(tableViewBox:getContentSize().width * 0.5,tableViewBox:getContentSize().height * 0.5)
    tableViewBox:addChild(self.noRankLb,1)
    self.noRankLb:setColor(G_ColorGray)

end

function acHryxTabOne:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
         return self.cellNum
    elseif fn == "tableCellSizeForIndex" then
        return  self.tvCellSize
    elseif fn == "tableCellAtIndex" then
    	local cell=CCTableViewCell:new()
        cell:autorelease()

        local cellWidth=self.tvCellSize.width
        local cellHeight=self.tvCellSize.height
        local rank,name,power,rechargeNum
        if idx == 0 then
        	rank,name,power,rechargeNum = acHryxVoApi:getPlayerRank()
        else
        	rank,name,power,rechargeNum = idx,self.rankList[idx][1],tonumber(self.rankList[idx][2]),tonumber(self.rankList[idx][3])
        end

        if rank and name and power and rechargeNum then

        	local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("newListItemBg.png", CCRect(4, 4, 1, 1), function () end)
            backSprie:setContentSize(CCSizeMake(cellWidth,80))
            backSprie:setPosition(ccp(cellWidth * 0.5,cellHeight * 0.5))
            cell:addChild(backSprie)
            backSprie:setOpacity(idx % 2 * 255)
            local height=backSprie:getContentSize().height * 0.5

            if tonumber(rank) and tonumber(rank) < 4 then
                local signSp = CCSprite:createWithSpriteFrameName("top_" .. rank .. ".png")
                signSp:setPosition(ccp(cellWidth * 0.5 - 4, cellHeight * 0.5))
                signSp:setScaleY((cellHeight-10)/signSp:getContentSize().height)
                signSp:setScaleX((cellWidth-10)/signSp:getContentSize().width)
                cell:addChild(signSp, 1)

                local rankSp=CCSprite:createWithSpriteFrameName("top" .. rank .. ".png")
                rankSp:setScale(0.7)
                rankSp:setPosition(ccp(self.posxTb[1] - 4,height))
                cell:addChild(rankSp,3)
            else
                local rankLabel=GetTTFLabelWrap(rank,18,CCSizeMake(160,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                rankLabel:setPosition(self.posxTb[1] - 4,height)
                cell:addChild(rankLabel,2)
            end

            local playerNameLabel=GetTTFLabelWrap(name,25,CCSizeMake(175,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            playerNameLabel:setPosition(self.posxTb[2] - 4,height)
            cell:addChild(playerNameLabel,2)

            local powerLb=GetTTFLabel(FormatNumber(power),25)
            powerLb:setPosition(self.posxTb[3] - 4,height)
            cell:addChild(powerLb,2)

            local rechargeStr, fontSize = "", 25
            if self.rtflag == true or (idx == 0) then
                rechargeStr = tostring(rechargeNum)
            else
                rechargeStr = getlocal("no_announce")
                fontSize = 20
            end
            local rechargeLb=GetTTFLabelWrap(rechargeStr,fontSize,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            rechargeLb:setPosition(self.posxTb[4] - 4,height)
            cell:addChild(rechargeLb,2)
        end
        return cell
    end
end

function acHryxTabOne:updataRank( )
    self.rtflag = acHryxVoApi:isRewardTime() --是否是领奖时间
	self.rankList,self.cellNum = acHryxVoApi:getRankList()
	if self.tv then
		self.tv:reloadData()
	end
	if self.noRankLb then
		if self.cellNum > 1 then
			self.noRankLb:setVisible(false)
		else
			self.noRankLb:setVisible(true)
		end
	end
end

function acHryxTabOne:showBuildingFunction(buildingPic,parent,pos,aPos,scaleSize)
	buildingSp = G_buildingAction1(buildingPic,parent,pos,aPos,scaleSize)
	self.buildingAc = buildingSp
	--放大镜
	local magnifierNode=CCNode:create()
	magnifierNode:setPosition(buildingSp:getContentSize().width - 120,50)
	magnifierNode:setTag(1016)
	parent:addChild(magnifierNode)

	local circelCenter=getCenterPoint(magnifierNode)
	local radius,rt,rtimes=10,2,2
	local magnifierSp=LuaCCSprite:createWithSpriteFrameName("ydcz_magnifier.png",function() end)
	magnifierSp:setScale(0.6)
	magnifierSp:setTouchPriority(-(self.layerNum-1)*20-4)
	magnifierSp:setPosition(circelCenter)
	magnifierNode:addChild(magnifierSp)

	local acArr=CCArray:create()
	local moveTo=CCMoveTo:create(0.5,ccp(magnifierNode:getContentSize().width/2,radius))
	local function rotateBy()
		G_requireLua("componet/CircleBy")
		self.circelAc=CircleBy:create(magnifierSp,rt,circelCenter,radius,rtimes)
	end
	local function removeRotateBy()
		if self.circelAc and self.circelAc.stop then
			self.circelAc:stop()
		end
	end
	local moveTo2=CCMoveTo:create(0.5,ccp(magnifierNode:getContentSize().width/2,magnifierNode:getContentSize().height/2))
	local delay=CCDelayTime:create(1)
	acArr:addObject(moveTo)
	acArr:addObject(CCCallFunc:create(rotateBy))
	acArr:addObject(CCDelayTime:create(rt))
	acArr:addObject(CCCallFunc:create(removeRotateBy))
	acArr:addObject(moveTo2)
	acArr:addObject(delay)
	local seq=CCSequence:create(acArr)
	magnifierSp:runAction(CCRepeatForever:create(seq))


	local function touchHandle( )
		if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

    	require "luascript/script/game/scene/gamedialog/activityAndNote/acThrivingSmallDialog"
        local titleStr = getlocal("buildingReadyToShow")
        local needTb = {"hryx",titleStr,1}
        local sd = acThrivingSmallDialog:new(self.layerNum+1,needTb)
        sd:init()
	end 
	local touchSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchHandle)
	touchSp:setContentSize(CCSizeMake(buildingSp:getContentSize().width,buildingSp:getContentSize().height))
	touchSp:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
	touchSp:setAnchorPoint(ccp(0,0))
	touchSp:setOpacity(0)
	parent:addChild(touchSp)
end

function acHryxTabOne:updateUI()
    local rtf = acHryxVoApi:isRewardTime() --是否是领奖时间
    if rtf == true and self.rtflag == false then
        self.rtflag = rtf
        self:updataRank()
    end  
end