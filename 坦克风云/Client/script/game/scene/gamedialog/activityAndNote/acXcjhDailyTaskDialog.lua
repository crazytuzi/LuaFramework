-- @Author hj
-- @Description 新春聚惠每日任务
-- @Date 2018-12-24

acXcjhDailyTaskDialog = {}

function acXcjhDailyTaskDialog:new(layer,partent)
	local nc = {
		layerNum = layer,
		partent = partent,
	}
	setmetatable(nc,self)
	self.__index = self
	return nc
end

function acXcjhDailyTaskDialog:init()
	self.bgLayer=CCLayer:create()
	self:doUserHandler()
	self:initTableView()
	return self.bgLayer
end

function acXcjhDailyTaskDialog:doUserHandler( ... )
    
    -- if acXcjhVoApi:isToday() == false then
    --     acXcjhVoApi:initTask()
    -- end

    self.taskList = acXcjhVoApi:getTaskList()

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    
    local adaSize 
    if G_getIphoneType() == G_iphoneX then 
        adaSize = CCSizeMake(G_VisibleSizeWidth,1090)
    elseif G_getIphoneType() == G_iphone5 then
        adaSize = CCSizeMake(G_VisibleSizeWidth,976)
    else        
        adaSize = CCSizeMake(G_VisibleSizeWidth,800)
    end

    local function onLoadIcon(fn,icon)
        if self and self.bgLayer and  tolua.cast(self.bgLayer,"CCLayer") then

            icon:setAnchorPoint(ccp(0.5,0.5))
            icon:setPosition(ccp(G_VisibleSizeWidth/2,(G_VisibleSizeHeight-162)/2))

            -- 裁切适配区域
            local clipper=CCClippingNode:create()
            clipper:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
            clipper:setAnchorPoint(ccp(0.5,0))
            clipper:setPosition(G_VisibleSizeWidth/2,0)

            local stencil=CCDrawNode:getAPolygon(adaSize,1,1)
            clipper:setStencil(stencil) 
            clipper:addChild(icon)
            self.bgLayer:addChild(clipper)
        end
    end

    local webImage
    if acXcjhVoApi:getVersion(  )==2 then
        webImage=LuaCCWebImage:createWithURL(G_downloadUrl("active/xcjh1_v2.jpg"),onLoadIcon)
    else
        webImage=LuaCCWebImage:createWithURL(G_downloadUrl("xcjh/xcjh_3.jpg"),onLoadIcon)
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

end

function acXcjhDailyTaskDialog:initTableView( ... )

	
	local function callBack(...)
        return self:eventHandler(...)
    end

    local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("yellowKuang.png",CCRect(15,15,1,1),function() end)
    tvBg:setOpacity(255*0.8)
    self.bgLayer:addChild(tvBg,2)
    if acXcjhVoApi:getVersion()==1 then
        tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20,G_VisibleSizeHeight-160-90-20-20))
    else
        tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20,G_VisibleSizeHeight-160-90))
    end
    tvBg:setAnchorPoint(ccp(0,0))
    tvBg:setPosition(ccp(10,20))

    local hd= LuaEventHandler:createHandler(callBack)
    if acXcjhVoApi:getVersion()==1 then
        self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-30,G_VisibleSizeHeight-160-90-20-20-10),nil)
    else
        self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-30,G_VisibleSizeHeight-160-90-10),nil)
    end
    
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
    self.tv:setPosition(ccp(15,25))
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)

    --设置tableview的遮罩
    local stencilBgUp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
    stencilBgUp:setContentSize(CCSizeMake(G_VisibleSizeWidth-20,300))
    stencilBgUp:setAnchorPoint(ccp(0.5,1))
    stencilBgUp:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight))
    stencilBgUp:setTouchPriority(-(self.layerNum-1)*20-3)
    stencilBgUp:setVisible(false)
    stencilBgUp:setIsSallow(true)
    self.bgLayer:addChild(stencilBgUp,10)
    local stencilBgDown=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
    stencilBgDown:setContentSize(CCSizeMake(G_VisibleSizeWidth-20,25))
    stencilBgDown:setAnchorPoint(ccp(0.5,0))
    stencilBgDown:setPosition(ccp(G_VisibleSizeWidth/2,0))
    stencilBgDown:setTouchPriority(-(self.layerNum-1)*20-3)
    stencilBgDown:setVisible(false)
    stencilBgDown:setIsSallow(true)
    self.bgLayer:addChild(stencilBgDown,10)

end

function acXcjhDailyTaskDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return #self.taskList
    elseif fn=="tableCellSizeForIndex" then
        return  CCSizeMake(G_VisibleSizeWidth-30,150)
    elseif fn=="tableCellAtIndex" then
    	local cell=CCTableViewCell:new()
        cell:autorelease()
        self:initCell(idx+1,cell)
        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

function acXcjhDailyTaskDialog:initCell(index,cell)

	cell:setContentSize(CCSizeMake(G_VisibleSizeWidth-30,150))

    local titleBg = LuaCCScale9Sprite:createWithSpriteFrameName("acFyss_yellowTitleBg.png",CCRect(30,0,50,32),function()end)
    titleBg:setContentSize(CCSizeMake(cell:getContentSize().width-55, titleBg:getContentSize().height))
    titleBg:setAnchorPoint(ccp(0,1))
    titleBg:setPosition(3,cell:getContentSize().height-10)
    cell:addChild(titleBg)
    local strSize = 22
    if G_isAsia() == false then
        strSize = 18
    end

    local data = self.taskList[index]
    local curNum = data.curNum <= data.needNum and data.curNum or data.needNum

    local key = data.key
    key = (key == "gb") and "gba" or key

    if key == "ai" then
        if data.quality == 0 then
            curNum = getlocal("fleetInfoTitle2") .. curNum
        else
            curNum = getlocal("aitroops_troop" .. data.quality) .. curNum
        end
    end

    local str
    if key == "dl" then
        str = getlocal("activity_chunjiepansheng_dl_title")
    else
        if key =="cj" and acXcjhVoApi:getVersion()==2 then
            str = getlocal("activity_chunjiepansheng_" .. key .. "_title_v2", {curNum, data.needNum})
        else
            str = getlocal("activity_chunjiepansheng_" .. key .. "_title", {curNum, data.needNum})
        end
    end

    local titleLb = GetTTFLabelWrap(str,strSize,CCSizeMake(550,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    titleLb:setAnchorPoint(ccp(0,0.5))
    titleLb:setPosition(15,titleBg:getContentSize().height/2)
    titleLb:setColor(G_ColorYellowPro)  
    titleBg:addChild(titleLb)

    local rewardTb = FormatItem(data.reward, nil, true)
    if rewardTb then
        local iconSize = 85
        local itemPosY = (cell:getContentSize().height - (titleBg:getContentSize().height + 10)) / 2
        for k, v in pairs(rewardTb) do
            local function showNewPropDialog()
                if v.type == "at" and v.eType == "a" then --AI部队
                    local troopsVo = AITroopsVoApi:getMaxLvAITroopsVo(v.key, true)
                    AITroopsVoApi:showTroopsInfoDialog(troopsVo, true, self.layerNum + 1)
                else
                    G_showNewPropInfo(self.layerNum + 1, true, true, nil, v, nil, nil, nil, nil, true)
                end
            end
            icon,scale = G_getItemIcon(v, 100, false, self.layerNum, showNewPropDialog)
            icon:setScale(iconSize / icon:getContentSize().height)
            scale = icon:getScale()
            icon:setTouchPriority( - (self.layerNum - 1) * 20 - 1)
            icon:setPosition(50 + icon:getContentSize().width * scale / 2 + (k - 1) * (30 + icon:getContentSize().width * scale), itemPosY)
            cell:addChild(icon)
            local numLb = GetTTFLabel("x" .. FormatNumber(v.num), 20)
            local numBg = CCSprite:createWithSpriteFrameName("newBlackFadeBar.png")
            numBg:setAnchorPoint(ccp(0, 1))
            numBg:setRotation(180)
            numBg:setScaleX((numLb:getContentSize().width + 15) / numBg:getContentSize().width)
            numBg:setScaleY(numLb:getContentSize().height / numBg:getContentSize().height)
            numBg:setPosition(icon:getPositionX() + iconSize / 2 - 5, icon:getPositionY() - iconSize / 2 + 5)
            cell:addChild(numBg)
            numLb:setAnchorPoint(ccp(1, 0))
            numLb:setPosition(numBg:getPosition())
            cell:addChild(numLb)
        end
    end
    if acXcjhVoApi:isGetRewardTime() == false then
        -- 当前已经不是抽奖时间了
        local stateLb = GetTTFLabel(getlocal("activity_xcjh_alreadyOver"), strSize)
        stateLb:setColor(G_ColorGray)
        stateLb:setAnchorPoint(ccp(1, 0.5))
        stateLb:setPosition(cell:getContentSize().width - 65, (cell:getContentSize().height - (titleBg:getContentSize().height + 10)) / 2)
        cell:addChild(stateLb)
    elseif data.status == 1 then
        local function awardHandler(tag, obj)
 
            if G_checkClickEnable() == false then
                do return end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            local function callback(fn,data)

                local ret,sData = base:checkServerData(data)
                if ret==true then 
                    if sData.data and sData.data.reward then
                        local rewardTipTb = {}
                        local tipStr = ""
                        local rewardTb = FormatItem(sData.data.reward)
                        for k, v in pairs(rewardTb) do
                            local num = tonumber(v.num)
                            if v.type == "at" and v.eType == "a" then --AI部队
                                if AITroopsVoApi:isExist(v.key) == true then
                                    local aiFragmentNum = AITroopsVoApi:getModelCfg().fragmentExchangeNum * num
                                    local aiName = AITroopsVoApi:getAITroopsNameStr(v.key)
                                    tipStr = tipStr .. getlocal("alreadyHasAITroopsTipDesc", { aiName, aiName, aiFragmentNum})
                                else
                                    local temp = v
                                    if num > 1 then
                                        local aiFragmentNum = AITroopsVoApi:getModelCfg().fragmentExchangeNum * (num - 1)
                                        local aiName = AITroopsVoApi:getAITroopsNameStr(v.key)
                                        tipStr = tipStr .. getlocal("alreadyHasAITroopsTipDesc", { aiName, aiName, aiFragmentNum})
                                        num = 1
                                        temp = G_clone(v)
                                        temp.num = num
                                    end
                                    table.insert(rewardTipTb, temp)
                                end
                            else
                                table.insert(rewardTipTb, v)
                            end
                            G_addPlayerAward(v.type, v.key, v.id, num, nil, true)
                        end

                        if tipStr == "" then
                            tipStr = getlocal("receivereward_received_success")
                        end
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tipStr, 30)
                        G_showRewardTip(rewardTipTb, true)
                        if sData.data and sData.data.xcjh then
                            acXcjhVoApi:updateSpecialData(sData.data.xcjh)
                            self:refreshTv()
                        end
                    end
                end
            end
            socketHelper:acXcjhTask(data.id,callback)
        end
        local btnScale = 0.6
        local awardBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", awardHandler, 11, getlocal("daily_scene_get"), 24 / btnScale)
        awardBtn:setScale(btnScale)
        awardBtn:setAnchorPoint(ccp(1, 0.5))
        local menu = CCMenu:createWithItem(awardBtn)
        menu:setTouchPriority( - (self.layerNum - 1) * 20 - 1)
        menu:setPosition(ccp(cell:getContentSize().width - 40, (cell:getContentSize().height - (titleBg:getContentSize().height + 10)) / 2))
        cell:addChild(menu)
    elseif data.status == 2 then
        local stateLb = GetTTFLabel(getlocal("noReached"), strSize)
        stateLb:setAnchorPoint(ccp(1, 0.5))
        stateLb:setPosition(cell:getContentSize().width - 65, (cell:getContentSize().height - (titleBg:getContentSize().height + 10)) / 2)
        cell:addChild(stateLb)
    elseif data.status == 3 then
        local stateLb = GetTTFLabel(getlocal("activity_hadReward"), strSize)
        stateLb:setColor(G_ColorGray)
        stateLb:setAnchorPoint(ccp(1, 0.5))
        stateLb:setPosition(cell:getContentSize().width - 65, (cell:getContentSize().height - (titleBg:getContentSize().height + 10)) / 2)
        cell:addChild(stateLb)
    end

    -- 差奖励的领取状态
    if index < #self.taskList then
        local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifier_yellow.png",CCRect(2,1,1,1), function()end)
        lineSp:setContentSize(CCSizeMake((cell:getContentSize().width - 10), 4))
        lineSp:ignoreAnchorPointForPosition(false)
        lineSp:setAnchorPoint(ccp(0.5, 0))
        lineSp:setPosition(cell:getContentSize().width / 2, 0)
        cell:addChild(lineSp)
    end


end

function acXcjhDailyTaskDialog:refreshTv( ... )
    self.taskList = acXcjhVoApi:getTaskList()
    if self.tv then
        self.tv:reloadData()
    end
end

function acXcjhDailyTaskDialog:dispose( ... )
	-- body
end