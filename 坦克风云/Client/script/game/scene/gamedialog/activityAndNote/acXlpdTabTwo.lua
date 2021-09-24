acXlpdTabTwo = {}
function acXlpdTabTwo:new(parent)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
	nc.parent      = parent
	nc.bgLayer     = nil
	nc.isIphone5   = G_isIphone5()
	nc.subHeight   = 168
	nc.url         = G_downloadUrl("active/acXlpdVisionBg.jpg")
	nc.urlRuler    = G_downloadUrl("active/acXlpdBigRuler.png")
	nc.overGetType = false
	nc.notTouchDialpg = nil
    nc.teamTipLb = nil
    return nc
end
function acXlpdTabTwo:dispose()
    self.teamTipLb = nil
	self.notTouchDialpg = nil
	self.urlRuler  = nil
	self.url       = nil
	self.bgLayer   = nil
	self.parent    = nil
	self.isIphone5 = nil
	self.useHeight = nil
end
function acXlpdTabTwo:init(layerNum)
	self.lHillSp    = nil
	self.rHillSp    = nil
	self.layerNum   = layerNum
	self.bgLayer    = CCLayer:create()
	self.useHeight  = G_VisibleSizeHeight - self.subHeight
	self.topPosy    = G_VisibleSizeHeight - 84
	self.pkLayerTb  = {}
	self.refreshTs  = base.serverTime
	self.status     = acXlpdVoApi:getStatus()
	self.lastStatus = self.status
	self:initAll()
    self:clipperBgImage()
    self:initTimeInfo()
    self:initPkInfo()
    self:goUpAction()
    self:initScapeAction()
    
    return self.bgLayer
end
function acXlpdTabTwo:initAll()
	if not self.notTouchDialpg and ( acXlpdVoApi:getStatus() == 5 or acXlpdVoApi:isShopOpen() ) then
		local function touchHandle()--acOver
			-- print("fdjklfkjl????????????")
		end
		local notTouchDialpg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchHandle)
		self.notTouchDialpg = notTouchDialpg
		notTouchDialpg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight - self.subHeight - 65))
		notTouchDialpg:setOpacity(200)
		notTouchDialpg:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
		notTouchDialpg:setAnchorPoint(ccp(0.5,0))
		notTouchDialpg:setPosition(G_VisibleSizeWidth * 0.5, 84)
		self.bgLayer:addChild(notTouchDialpg,100)

        local endStr = acXlpdVoApi:isShopOpen() and "acOver" or  "activity_xlpd_endStr"
		local EndTipLb = GetTTFLabel(getlocal(endStr),G_isAsia() and 33 or 25,true)
		EndTipLb:setPosition(notTouchDialpg:getContentSize().width * 0.5,notTouchDialpg:getContentSize().height * 0.58)
		EndTipLb:setColor(G_ColorRed)
		notTouchDialpg:addChild(EndTipLb)
	elseif self.notTouchDialpg then
		if acXlpdVoApi:getStatus() ~= 5  and not acXlpdVoApi:isShopOpen() then
			self.notTouchDialpg:setPosition(-9999999,0)
			self.notTouchDialpg:setVisible(false)
		else
			self.notTouchDialpg:setPosition(G_VisibleSizeWidth * 0.5, 84)
			self.notTouchDialpg:setVisible(true)
		end
	end
end
function acXlpdTabTwo:clipperBgImage()-- ruler layer 5
    local clipper = CCClippingNode:create()
    clipper:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight - self.subHeight))
    clipper:setAnchorPoint(ccp(0.5, 1))
    clipper:setPosition(G_VisibleSizeWidth * 0.5, G_VisibleSizeHeight - 84)
    clipper:setStencil(CCDrawNode:getAPolygon(clipper:getContentSize(), 1, 1))
    self.bgLayer:addChild(clipper)
    
    local function onLoadBackground(fn, webImage)
        if self and clipper and tolua.cast(clipper, "CCNode") then
            webImage:setAnchorPoint(ccp(0.5, 0))
            webImage:setPosition(G_VisibleSizeWidth * 0.5, 0)
            clipper:addChild(webImage)
        end
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local webImage = LuaCCWebImage:createWithURL(self.url, onLoadBackground)
    
    local clipper2 = CCClippingNode:create()
    clipper2:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight - self.subHeight - 65))
    clipper2:setAnchorPoint(ccp(0.5, 1))
    clipper2:setPosition(G_VisibleSizeWidth * 0.5, G_VisibleSizeHeight - 84 - 65)
    clipper2:setStencil(CCDrawNode:getAPolygon(clipper2:getContentSize(), 1, 1))
    self.bgLayer:addChild(clipper2, 5)
    
    local function onLoadBackground2(fn, webImage2)
        if self and clipper2 and tolua.cast(clipper2, "CCNode") then
            webImage2:setAnchorPoint(ccp(0.5, 0))
            webImage2:setPosition(G_VisibleSizeWidth * 0.5, 0)
            clipper2:addChild(webImage2)
        end
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local webImage2 = LuaCCWebImage:createWithURL(self.urlRuler, onLoadBackground2)
end

function acXlpdTabTwo:initTimeInfo()
    local timeBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    timeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, 65))
    timeBg:setAnchorPoint(ccp(0.5, 1))
    -- timeBg:setOpacity(0)
    timeBg:setPosition(G_VisibleSizeWidth * 0.5, self.topPosy)
    self.bgLayer:addChild(timeBg, 10)
    local timeBgHeight = timeBg:getContentSize().height
    
    local timeType, timeStr = acXlpdVoApi:getActiveTypeAndTime()
    self.timeLb = GetTTFLabel(timeStr, G_isAsia() and 22 or 20, "Helvetica-bold")
    self.timeLb:setAnchorPoint(ccp(0.5, 0.5))
    self.timeLb:setColor(G_ColorRed)
    self.timeLb:setPosition(ccp(timeBg:getContentSize().width * 0.5, timeBgHeight * 0.5))
    timeBg:addChild(self.timeLb, 2)
    
    local function touchTip()
        acXlpdVoApi:getTip(self.layerNum + 2, "tabTwo")
    end
    G_addMenuInfo(timeBg, self.layerNum + 1, ccp(G_VisibleSizeWidth - 30, timeBgHeight * 0.5), {}, nil, 0.7, 28, touchTip, true)
    
    local function logHandler()
        if acXlpdVoApi:isEnd() then
            do return end
        end
        local function showLog(teamLog, pkLog)
               local needTb = {"xlpdLog", getlocal("serverwar_point_record"), teamLog, pkLog}
               G_showCustomizeSmallDialog(self.layerNum + 1, needTb)
           end
           acXlpdVoApi:socketLog(showLog)
        -- acXlpdVoApi:showMyTeamPanel(self.layerNum + 1)
    end
    local btnScale, priority = 0.6, -(self.layerNum - 1) * 20 - 3
    local logBtn, logMenu = G_createBotton(timeBg, ccp(30, timeBgHeight * 0.5), nil, "bless_record.png", "bless_record.png", "bless_record.png", logHandler, btnScale, priority, nil, nil)
end

--初始化pk信息
function acXlpdTabTwo:initPkInfo()
    --初始化pk信息
    local teams = G_clone(acXlpdVoApi:getTeams())
    for k = 1, 2 do
        local team = teams[k] or {}
        team.isMy = acXlpdVoApi:isMyTeam(team)
        team.pd = acXlpdVoApi:getTeamPdv(team,k)
    end
    
    --保持高攀登值的队伍为胜者，胜者在左侧显示
    if teams[1] and teams[2] then
        self.pdDif = teams[1].pd - teams[2].pd
        -- print("teams[1].pd - teams[2].pd--->>",teams[1].pd , teams[2].pd, self.pdDif)
        local isTie = self.pdDif == 0 and true or false
        if self.pdDif >= 0 or (self.status <= 2) then
            self:refreshTeamInfo(1, teams[1], true,isTie)
            self:refreshTeamInfo(2, teams[2], false,isTie)
        else
            self:refreshTeamInfo(1, teams[1], false,isTie)
            self:refreshTeamInfo(2, teams[2], true,isTie)
        end
    end
end

function acXlpdTabTwo:refreshTeamInfo(tidx, team, isWin, isTie)
    if not self.bgLayer then
        do return end
    end
    if self.pkLayerTb[tidx] and tolua.cast(self.pkLayerTb[tidx], "CCNode") then
        if self.teamTipLb then
            self.teamTipLb:removeFromParentAndCleanup(true)
            self.teamTipLb = nil
        end
        self.pkLayerTb[tidx]:removeFromParentAndCleanup(true)
        self.pkLayerTb[tidx] = nil
    end
    local pkLayer = CCNode:create()
    pkLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - self.subHeight - 65))
    pkLayer:setAnchorPoint(ccp(0, 0))
    self.bgLayer:addChild(pkLayer, 12)
    self.pkLayerTb[tidx] = pkLayer
    if isWin == true then
        pkLayer:setPosition(0, 86)

        if not team[1] or not team[2] or not team[3] then
            self:teamTipLbIsShow(pkLayer, isWin, self.status)
        end
    else
        pkLayer:setPosition(G_VisibleSizeWidth / 2, 86)
    end
    
    local iconWidth = 78
    for k = 1, 3 do
        local playerIconSp
        local player = team[k]
        if player == nil or next(player) == nil then
            if team.isMy == true then --组队期间可以选择邀请好友
                if self.status == 1 then
                    local function showMyTeamInfo()
                        --显示我方队伍详情
                        local function refresh()
                            print("self:refresh~~~")
                            self:refresh()
                        end
                        acXlpdVoApi:showMyTeamPanel(self.layerNum + 1, refresh)
                    end
                    playerIconSp = LuaCCSprite:createWithSpriteFrameName("Icon_BG.png", showMyTeamInfo)
                    local addBtnSp = CCSprite:createWithSpriteFrameName("st_addIcon.png")
                    addBtnSp:setPosition(getCenterPoint(playerIconSp))
                    playerIconSp:addChild(addBtnSp)
                    local seq = CCSequence:createWithTwoActions(CCFadeTo:create(1, 55), CCFadeTo:create(1, 255))
                    addBtnSp:runAction(CCRepeatForever:create(seq))
                end
            else
                if self.status <= 2 then
                    playerIconSp = LuaCCSprite:createWithSpriteFrameName("Icon_BG.png", function () end)
                    local unKownSp = CCSprite:createWithSpriteFrameName("blackHero.png")
                    unKownSp:setScale((iconWidth - 10) / unKownSp:getContentSize().height)
                    unKownSp:setPosition(getCenterPoint(playerIconSp))
                    playerIconSp:addChild(unKownSp)
                end
            end
        else
            local pic = playerVoApi:getPersonPhotoName(player[3] or headCfg.default)
            playerIconSp = playerVoApi:GetPlayerBgIcon(pic, function () end, nil, nil, 100)
        end
        if playerIconSp then
            playerIconSp:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
            playerIconSp:setScale(iconWidth / playerIconSp:getContentSize().width)
            playerIconSp:setPosition(pkLayer:getContentSize().width / 2 + (k - 2) * (iconWidth + 20), iconWidth / 2 + 60)
            pkLayer:addChild(playerIconSp, 2)
            
            local pdBg
            if isWin == true then
                pdBg = CCSprite:createWithSpriteFrameName("subTip1912_green.png")
            else
                pdBg = CCSprite:createWithSpriteFrameName("subTip1912_brown.png")
            end
            pdBg:setAnchorPoint(ccp(0.5, 1))
            pdBg:setPosition(playerIconSp:getPositionX(), playerIconSp:getPositionY() - iconWidth / 2 + 22)
            pkLayer:addChild(pdBg)
            
            local pdLv = 0
            if player and player[4] then
                pdLv = player[4]
            end
            local pdLb = GetTTFLabel(pdLv, 18)
            pdLb:setPosition(pdBg:getContentSize().width / 2, 18)
            pdBg:addChild(pdLb)
            if player and player[2] then
                local playerNameLb = GetTTFLabelWrap(player[2], 18, CCSizeMake(iconWidth + 20, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
                playerNameLb:setAnchorPoint(ccp(0.5, 1))
                playerNameLb:setPosition(playerIconSp:getPositionX(), pdBg:getPositionY() - pdBg:getContentSize().height)
                pkLayer:addChild(playerNameLb)
                if tostring(player[1]) == tostring(playerVoApi:getUid()) then
                    playerNameLb:setColor(G_ColorYellowPro2)
                end
            end
        end
    end
    local nameFontSize, smallFontSize = 20, 18
    local nameStr, align, anchor
    
    if team and team[1] and next(team[1]) then --有队伍
        nameStr = getlocal("activity_xlpd_troops", {team[1][2] or ""})
    else
        nameStr = getlocal("activity_xlpd_noMatchTroops")
    end
    local nameLb, nameLbHeight = G_getRichTextLabel(nameStr, {nil, G_ColorYellowPro, nil}, nameFontSize, pkLayer:getContentSize().width - 10, (isWin == true and kCCTextAlignmentLeft or kCCTextAlignmentRight), kCCVerticalTextAlignmentTop)
    
    local teamNameBg
    if isWin == true then
        teamNameBg = CCSprite:createWithSpriteFrameName("subTitle1912_green.png")
    else
        teamNameBg = CCSprite:createWithSpriteFrameName("subTitle1912_brown.png")
    end
    teamNameBg:setAnchorPoint(ccp(0.5, 1))
    if isWin ~= true then
        teamNameBg:setFlipX(true)
        teamNameBg:setPosition(pkLayer:getContentSize().width - teamNameBg:getContentSize().width / 2, pkLayer:getContentSize().height)
        nameLb:setAnchorPoint(ccp(1, 1))
        nameLb:setPosition(pkLayer:getContentSize().width - 10, pkLayer:getContentSize().height - 5)
    else
        teamNameBg:setPosition(teamNameBg:getContentSize().width / 2, pkLayer:getContentSize().height)
        nameLb:setAnchorPoint(ccp(0, 1))
        nameLb:setPosition(10, pkLayer:getContentSize().height - 5)
    end
    pkLayer:addChild(teamNameBg)
    pkLayer:addChild(nameLb)
    
    local pdLb = GetTTFLabelWrap(getlocal("activity_xlpd_coinValue") .. ": " .. (team.pd or 0), smallFontSize, CCSizeMake(240, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
    pdLb:setAnchorPoint(ccp(0.5, 1))
    pdLb:setPosition(teamNameBg:getPositionX(), nameLb:getPositionY() - nameLbHeight - 5)
    pkLayer:addChild(pdLb)
    
    local infoWidth = 270
    local pdInfoBg
    if isWin == true then
        pdInfoBg = LuaCCScale9Sprite:createWithSpriteFrameName("smallTip_green1.png", CCRect(26, 0, 2, 138), function ()end)
        pdInfoBg:setContentSize(CCSizeMake(infoWidth, pdInfoBg:getContentSize().height))
        pdInfoBg:setPosition(pkLayer:getContentSize().width - infoWidth / 2, G_VisibleSizeHeight - 480)
    else
        pdInfoBg = LuaCCScale9Sprite:createWithSpriteFrameName("smallTip_green2.png", CCRect(108, 0, 2, 138), function ()end)
        pdInfoBg:setContentSize(CCSizeMake(infoWidth, pdInfoBg:getContentSize().height))
        pdInfoBg:setPosition(infoWidth / 2, 400)
    end
    if acXlpdVoApi:isShopOpen() then
        pdInfoBg:setVisible(false)
    end

    pkLayer:addChild(pdInfoBg)
    
    local nullStr, leftPosX = "?", 20
    local pdDifStr, pdHeightStr, pdCoinStr
    if isWin == true then
        pdDifStr = getlocal("activity_xlpd_pddif1", {math.abs(self.pdDif)})
        pdHeightStr = getlocal("activity_xlpd_hight", {acXlpdVoApi:getTeamPdHeight(team.pd)})
        pdCoinStr = getlocal("activity_xlpd_pdcoin", {acXlpdVoApi:getTeamPdCoin(team.pd,isWin)})
    else
        if self.status == 1 or self.status == 2 then
            pdDifStr = getlocal("activity_xlpd_pddif2", {nullStr})
            pdHeightStr = getlocal("activity_xlpd_hight", {nullStr})
            pdCoinStr = getlocal("activity_xlpd_pdcoin", {nullStr})
        else
            pdDifStr = getlocal("activity_xlpd_pddif2", {math.abs(self.pdDif)})
            pdHeightStr = getlocal("activity_xlpd_hight", {acXlpdVoApi:getTeamPdHeight(team.pd)})
            pdCoinStr = getlocal("activity_xlpd_pdcoin", {acXlpdVoApi:getTeamPdCoin(team.pd,isTie)})
        end
        leftPosX = 50
    end
    local fontSize, spaceY, color = 20, 5, ccc3(117, 250, 255)
    if G_isIOS() == false or G_isAsia() == false then
        fontSize, spaceY = 18, 0
    end
    local pdDifLb = GetTTFLabel(pdDifStr, fontSize) --领先值
    pdDifLb:setAnchorPoint(ccp(0, 0.5))
    pdDifLb:setColor(color)
    pdInfoBg:addChild(pdDifLb)
    local pdHeightLb = GetTTFLabel(pdHeightStr, fontSize) --攀登高度
    pdHeightLb:setAnchorPoint(ccp(0, 0.5))
    pdHeightLb:setColor(color)
    pdInfoBg:addChild(pdHeightLb)
    local pdCoinLb = GetTTFLabel(pdCoinStr, fontSize) --攀登币预览
    pdCoinLb:setAnchorPoint(ccp(0, 0.5))
    pdCoinLb:setColor(color)
    pdInfoBg:addChild(pdCoinLb)
    pdHeightLb:setPosition(leftPosX, 90)
    pdDifLb:setPosition(leftPosX, pdHeightLb:getPositionY() + pdHeightLb:getContentSize().height / 2 + pdDifLb:getContentSize().height / 2 + spaceY)
    pdCoinLb:setPosition(leftPosX, pdHeightLb:getPositionY() - pdHeightLb:getContentSize().height / 2 - pdCoinLb:getContentSize().height / 2 - spaceY)
end

function acXlpdTabTwo:tick()
    local status = acXlpdVoApi:getStatus()
    if ((base.serverTime - self.refreshTs) >= 5 * 60) or (self.lastStatus ~= status) or acXlpdVoApi:getNeedRefreshTeamData( ) then --每隔5分钟同步一次数据
        if not acXlpdVoApi:isShopOpen() then
            local function refresh()
                if self and self.bgLayer then
                    self:refresh()
                end
            end
            if acXlpdVoApi:getNeedRefreshTeamData() then
                acXlpdVoApi:setNeedRefreshTeamData()
            end
            acXlpdVoApi:xlpdRequest("get", {}, refresh, false)
            self.refreshTs = base.serverTime
            self.lastStatus = status   
        end
    end
    --同步时间显示
    if not acXlpdVoApi:isEnd() then
        if self.timeLb and tolua.cast(self.timeLb, "CCLabelTTF") then
            local timeType, timeStr = acXlpdVoApi:getActiveTypeAndTime()
            self.timeLb:setString(timeStr)
        end

        local pdvUpTb = acXlpdVoApi:getPdvUpType( )
        local choseIdx = 0
        for k,v in pairs(pdvUpTb) do
        	if not v then
        		acXlpdVoApi:setPdvUpType(k)
        		choseIdx = choseIdx + k
        	end
        end
        if choseIdx > 0 then
        	self:goUpAction(choseIdx)
        end

        self:initAll()
    end
    --同步攀登状态
    self.status = status

    if self.overGetType == false and acXlpdVoApi:isCanSocketGetOverData() then
    	self.overGetType = true 
    	self:showOverPanel()
    end
end

function acXlpdTabTwo:showOverPanel( )
	print "~~~  acXlpdTabTwo:showOverPanel ~~~"
	local function showOverPanel( )
		local overData, overType = acXlpdVoApi:getOverNow()
		acXlpdVoApi:showOverPanel(self.layerNum + 10, nil, overData, overType)
        self:refresh()
	end
	acXlpdVoApi:socketOverData(showOverPanel)
end

function acXlpdTabTwo:refresh()
    self:initPkInfo()
end

------------------------------- 动 画
function acXlpdTabTwo:initScapeAction()
	local farCloudSpeedTb = {130,132,134,136,138,140,142,144,146,148}--远端云 运行总时间
	local farHeightTb1 = {self.useHeight * 0.75,self.useHeight * 0.25}
	local farHeightTb2 = {self.useHeight*0.25,self.useHeight * 0.65}

	local function actionHandl1( )
		local speedRdm1 = math.random(1,5)
		local speedRdm2 = math.random(5,10)
		local useHeightRdm = math.random(1,2)

		local farCloud1 = CCSprite:createWithSpriteFrameName("farCloud1.png")
		self.bgLayer:addChild(farCloud1,1)
		farCloud1:setPosition(900,farHeightTb1[useHeightRdm])
		local inMvTo=CCMoveTo:create(farCloudSpeedTb[speedRdm1],ccp(-300,farHeightTb1[useHeightRdm]))
		local function movEndCallBack()
			farCloud1:removeFromParentAndCleanup(true)
		end
		local movEndFun = CCCallFunc:create(movEndCallBack)
		local cloudArr = CCArray:create()
		cloudArr:addObject(inMvTo)
		cloudArr:addObject(movEndFun)
		local cSeq = CCSequence:create(cloudArr)
		farCloud1:runAction(cSeq)

		local farCloud2 = CCSprite:createWithSpriteFrameName("farCloud2.png")
		self.bgLayer:addChild(farCloud2)

		farCloud2:setPosition(900,farHeightTb2[useHeightRdm])
		local inMvTo2=CCMoveTo:create(farCloudSpeedTb[speedRdm2],ccp(-300,farHeightTb2[useHeightRdm]))
		local function movEndCallBac2()
			farCloud2:removeFromParentAndCleanup(true)
		end
		local movEndFu2 = CCCallFunc:create(movEndCallBac2)
		local cloudArr2 = CCArray:create()
		cloudArr2:addObject(inMvTo2)
		cloudArr2:addObject(movEndFu2)
		local cSeq2 = CCSequence:create(cloudArr2)
		farCloud2:runAction(cSeq2)
	end 
	local ccfun1 = CCCallFunc:create(actionHandl1)
	local delay1=CCDelayTime:create(150)
	local arr1 = CCArray:create()
	arr1:addObject(ccfun1)
	arr1:addObject(delay1)
	local seq1 = CCSequence:create(arr1)
    local repeatForever1=CCRepeatForever:create(seq1)	
    self.bgLayer:runAction(repeatForever1)

    local farShipSpeedTb = {122,122,124,126,128,100,102,104,106,108}--远端云 运行总时间
	local shipHposy1 = {self.useHeight * 0.6,self.useHeight * 0.3}
	local shipHposy2 = {self.useHeight*0.8,self.useHeight * 0.5}
	local function actionHandl2( )
		local speedRdm1 = math.random(1,5)
		local speedRdm2 = math.random(5,10)
		local useHeightRdm = math.random(1,2)

		-- local airship1 = CCSprite:createWithSpriteFrameName("airship1.png")
		-- self.bgLayer:addChild(airship1,1)
		-- airship1:setPosition(900,shipHposy1[useHeightRdm])
		-- local inMvTo=CCMoveTo:create(farShipSpeedTb[speedRdm1],ccp(-300,shipHposy1[useHeightRdm]))
		-- local function movEndCallBack()
		-- 	airship1:removeFromParentAndCleanup(true)
		-- end
		-- local movEndFun = CCCallFunc:create(movEndCallBack)
		-- local shipArr = CCArray:create()
		-- shipArr:addObject(inMvTo)
		-- shipArr:addObject(movEndFun)
		-- local cSeq = CCSequence:create(shipArr)
		-- airship1:runAction(cSeq)

		local airship2 = CCSprite:createWithSpriteFrameName("airship2.png")
		self.bgLayer:addChild(airship2)

		airship2:setPosition(900,shipHposy2[useHeightRdm])
		local inMvTo2=CCMoveTo:create(farShipSpeedTb[speedRdm2],ccp(-300,shipHposy2[useHeightRdm]))
		local function movEndCallBac2()
			airship2:removeFromParentAndCleanup(true)
		end
		local movEndFu2 = CCCallFunc:create(movEndCallBac2)
		local shipArr2 = CCArray:create()
		shipArr2:addObject(inMvTo2)
		shipArr2:addObject(movEndFu2)
		local cSeq2 = CCSequence:create(shipArr2)
		airship2:runAction(cSeq2)
	end 

	local ccfun2 = CCCallFunc:create(actionHandl2)
	local delay2=CCDelayTime:create(110)
	local arr2 = CCArray:create()
	arr2:addObject(ccfun2)
	arr2:addObject(delay2)
	local seq2 = CCSequence:create(arr2)
    local repeatForever2=CCRepeatForever:create(seq2)	
    self.bgLayer:runAction(repeatForever2)

    local nearSpeedTb = {400,450}
    local nearShopPosyTb = {self.useHeight * 0.7,self.useHeight * 0.3}
    local function actionHandl3( )
    	local speedRdm1 = math.random(1,2)
		local useHeightRdm = math.random(1,2)

		local nearCloud1 = CCSprite:createWithSpriteFrameName("nearCloud1.png")
		self.bgLayer:addChild(nearCloud1,5)
		nearCloud1:setPosition(900,shipHposy1[useHeightRdm])
		local inMvTo=CCMoveTo:create(nearSpeedTb[speedRdm1],ccp(-300,nearShopPosyTb[useHeightRdm]))
		local function movEndCallBack()
			nearCloud1:removeFromParentAndCleanup(true)
		end
		local movEndFun = CCCallFunc:create(movEndCallBack)
		local cArr = CCArray:create()
		cArr:addObject(inMvTo)
		cArr:addObject(movEndFun)
		local cSeq = CCSequence:create(cArr)
		nearCloud1:runAction(cSeq)
    end
    local ccfun3 = CCCallFunc:create(actionHandl3)
	local delay3=CCDelayTime:create(460)
	local arr3 = CCArray:create()
	arr3:addObject(ccfun3)
	arr3:addObject(delay3)
	local seq3 = CCSequence:create(arr3)
    local repeatForever3=CCRepeatForever:create(seq3)	
    self.bgLayer:runAction(repeatForever3)
end
function acXlpdTabTwo:goUpAction(idx)
	local function runLhillAction( )
		local movDown = CCMoveTo:create(30,ccp(0,-self.hillHight))
		local function movEndHandl()
			self.lHillSp:setPosition(0,0)
		end
		local ccfun = CCCallFunc:create(movEndHandl)
		local arr = CCArray:create()
		arr:addObject(movDown)
		arr:addObject(ccfun)
		local seq = CCSequence:create(arr)
		self.lHillSp:runAction(seq)
	end 
	local function runRhillAction( )
		local movDown = CCMoveTo:create(30,ccp(G_VisibleSizeWidth,-self.hillHight))
		local function movEndHandl()
			self.rHillSp:setPosition(G_VisibleSizeWidth,0)
		end
		local ccfun = CCCallFunc:create(movEndHandl)
		local arr = CCArray:create()
		arr:addObject(movDown)
		arr:addObject(ccfun)
		local seq = CCSequence:create(arr)
		self.rHillSp:runAction(seq)
	end 
	if idx == 1 then
		if self.lHillSp then
			runLhillAction()
		end
	elseif idx == 2 then
		if self.rHillSp then
			runRhillAction()
		end
	elseif idx == 3 then
		runLhillAction()
		runRhillAction()
	elseif not self.lHillSp and not self.rHillSp then
		local function tvCallBack(handler,fn,idx,cel)
	        if fn=="numberOfCellsInTableView" then
	            return 1
	        elseif fn=="tableCellSizeForIndex" then
	            return  CCSizeMake(G_VisibleSizeWidth, self.useHeight + 20)
	        elseif fn=="tableCellAtIndex" then
	        	local cell=CCTableViewCell:new()
	            cell:autorelease()

	            local hill1 = "hill1.png"
				local hill2 = "hill2.png"
				local hill1Sp1 = CCSprite:createWithSpriteFrameName(hill1)
				hill1Sp1:setPosition(0,0)
				hill1Sp1:setAnchorPoint(ccp(0,0))
				cell:addChild(hill1Sp1)
				self.lHillSp = hill1Sp1
				self.hillHight = self.lHillSp:getContentSize().height
				local hill1Sp2 = CCSprite:createWithSpriteFrameName(hill1)
				hill1Sp2:setPosition(0,hill1Sp1:getContentSize().height - 2)
				hill1Sp2:setAnchorPoint(ccp(0,0))
				hill1Sp1:addChild(hill1Sp2)

				local hill2Sp1 = CCSprite:createWithSpriteFrameName(hill2)
				hill2Sp1:setPosition(G_VisibleSizeWidth,0)
				hill2Sp1:setAnchorPoint(ccp(1,0))
				cell:addChild(hill2Sp1)
				self.rHillSp = hill2Sp1

				local hill2Sp2 = CCSprite:createWithSpriteFrameName(hill2)
				hill2Sp2:setPosition(hill2Sp1:getContentSize().width,hill2Sp1:getContentSize().height - 2)
				hill2Sp2:setAnchorPoint(ccp(1,0))
				hill2Sp1:addChild(hill2Sp2)

	            return cell
	        end
	    end
		local hd=LuaEventHandler:createHandler(tvCallBack)
	    local tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth, self.useHeight + 20),nil)
	    tableView:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	    tableView:setPosition(ccp(0,64))
	    self.bgLayer:addChild(tableView,5)
	    tableView:setMaxDisToBottomOrTop(0)
	    self.tv = tableView
	end

end

function acXlpdTabTwo:teamTipLbIsShow(parent, isWin,status)
    if acXlpdVoApi:isShopOpen() then
        do return end
    end
    if self.teamTipLb and tolua.cast(self.teamTipLb,"CCLabelTTF") then
        if status == 1 then
            self.teamTipLb:setVisible(true)
        else
            self.teamTipLb:setVisible(false)
        end
    elseif status == 1 then
        local teamTipLb = GetTTFLabelWrap(getlocal("xlpd_teamTipStr"),G_isAsia() and 20 or 17, CCSizeMake(parent:getContentSize().width - 40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
        teamTipLb:setAnchorPoint(ccp(0,0))
        teamTipLb:setColor(G_ColorGreen)
        teamTipLb:setPosition(20,140)
        parent:addChild(teamTipLb,20)
        self.teamTipLb = teamTipLb
    end
end