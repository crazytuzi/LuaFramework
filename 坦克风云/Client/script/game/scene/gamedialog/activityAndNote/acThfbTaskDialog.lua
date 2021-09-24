-- @Author hj
-- @Description 特惠风暴任务板子
-- @Date 2018-05-16

acThfbTaskDialog = {}

function acThfbTaskDialog:new(layer,parent)
	local nc = {
		layerNum = layer,
        flag = 0,
        parent = parent,
        cellHeight = 160,
        tvHeight = G_VisibleSizeHeight-225,
		taskList = acThfbVoApi:reOrderTaskList()
	}
	setmetatable(nc,self)
	self.__index = self
	return nc
end

function acThfbTaskDialog:init()
	self.bgLayer=CCLayer:create()
	self:initTableView()
	return self.bgLayer
end

function acThfbTaskDialog:initTableView( ... )
	local function callBack(...)
        return self:eventHandler(...)
    end

    local function nilFunc( ... )
    end
    local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),nilFunc)
    self.bgLayer:addChild(tvBg)
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20,G_VisibleSizeHeight-215+20))
    tvBg:setAnchorPoint(ccp(0,0))
    tvBg:setPosition(ccp(10,20))

    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-20,G_VisibleSizeHeight-225+20),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
    self.tv:setPosition(ccp(10,25))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)

    --设置tableview的遮罩
    local stencilBgUp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
    stencilBgUp:setContentSize(CCSizeMake(G_VisibleSizeWidth-20,180))
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

function acThfbTaskDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
        return #self.taskList
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize = CCSizeMake(G_VisibleSizeWidth-20,160)
        return tmpSize
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

function acThfbTaskDialog:initCell(seq,cell)

	cell:setContentSize(CCSizeMake(G_VisibleSizeWidth-20,160))
	local taskTb = self.taskList[seq]
	-- 任务描述框
	local function nilFunc( ... )
	end
    local titleSpire = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,0,1,32),nilFunc)
    titleSpire:setContentSize(CCSizeMake(cell:getContentSize().width-150,32))
    titleSpire:setAnchorPoint(ccp(0,0.5))
    cell:addChild(titleSpire)
    titleSpire:setPosition(ccp(5,cell:getContentSize().height-20))

    -- 任务描述
    local descStr = acThfbVoApi:getTaskDescWithColor(taskTb.id)

    local colorTb 
    if acThfbVoApi:getTaskNum(taskTb.id) >= taskTb.num then
        colorTb = {nil,G_ColorGreen,nil}
    else
        colorTb = {nil,G_ColorRed,nil}
    end

    local strSize = 24
    if G_isAsia() == false then
        strSize = 18
    end
    local posx = G_getCurChoseLanguage() == "ar" and -180 or 20
    local descLb = G_getRichTextLabel(descStr,colorTb,strSize,cell:getContentSize().width-100,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	descLb:setAnchorPoint(ccp(0,1))
	descLb:setPosition(ccp(posx,cell:getContentSize().height-5))
	cell:addChild(descLb)

    local height = (cell:getContentSize().height-32-5)/2+2

	--奖励物品
	if taskTb.reward then

        local rewardTab = FormatItem(taskTb.reward,true,true)
        for k,v in pairs(rewardTab) do
            if v then
                local scaleSize = 80
                local px,py= 60 + 100*(k-1),height
                local function showNewPropInfo()
                    G_showNewPropInfo(self.layerNum+1,true,true,nil,v)
                    return false
                end

                local icon,scale=G_getItemIcon(v,scaleSize,true,self.layerNum+1,showNewPropInfo,nil,nil,nil,nil,nil,true)
                icon:setTouchPriority(-(self.layerNum-1)*20-2)
                icon:setPosition(ccp(px,py))
                cell:addChild(icon,1)

                local numLb=GetTTFLabel("x"..FormatNumber(v.num),18)
                numLb:setAnchorPoint(ccp(1,0))
                numLb:setPosition(ccp(icon:getContentSize().width-5,5))
                icon:addChild(numLb,1)
                numLb:setScale(1/scale)

            end
        end
        local actualId 
        if taskTb.id == 100 then
            actualId = 7
        elseif taskTb.id == 7 then
            actualId  = 8
        else
            actualId = taskTb.id
        end

        local function showDisHandler( ... )

            local item = {}
            item.universal = true
            item.hasIcon = true
            item.finalDesc = true
            item.icon = CCSprite:createWithSpriteFrameName(acThfbVoApi:getBagIcon(actualId))
            item.icon:setScale(80/item.icon:getContentSize().height)
            local saleSpire = CCSprite:createWithSpriteFrameName("sale_ticket.png")
            saleSpire:setAnchorPoint(ccp(0.5,0.5))
            saleSpire:setPosition(ccp(item.icon:getContentSize().width/2,item.icon:getContentSize().height/2+5))
            saleSpire:setRotation(25)
            item.icon:addChild(saleSpire)

            local saleRate = string.format("%.2f",taskTb.dis/10)
            -- 折扣券文字
            local saleLabel = GetTTFLabel(tostring((1-saleRate)*100).."%",20)
            saleLabel:setAnchorPoint(ccp(0,0.5))
            saleLabel:setPosition(ccp(10,saleSpire:getContentSize().height/2))
            saleSpire:addChild(saleLabel)
       
            local offLabel = GetTTFLabel("OFF",10)
            offLabel:setAnchorPoint(ccp(0,0.5))
            offLabel:setPosition(ccp(5+saleLabel:getContentSize().width+6,saleSpire:getContentSize().height/2))
            saleSpire:addChild(offLabel)
            local dis = taskTb.dis
            if G_isAsia() == false then
                dis = 100 - dis*10
            end
            item.name,item.desc = acThfbVoApi:getBagNameAndDesc(taskTb.id,dis)
            G_showNewPropInfo(self.layerNum+1,true,true,nil,item,true)
        end

        -- 礼包
        local giftSpire = LuaCCSprite:createWithSpriteFrameName(acThfbVoApi:getBagIcon(actualId),showDisHandler)
        giftSpire:setAnchorPoint(ccp(0.5,0.5))
        giftSpire:setPosition(ccp(60 + 100*(#rewardTab),height))
        giftSpire:setTouchPriority(-(self.layerNum-1)*20-2)
        cell:addChild(giftSpire)
        giftSpire:setScale(100/giftSpire:getContentSize().height)

        -- 折扣券
        local saleSpire = CCSprite:createWithSpriteFrameName("sale_ticket.png")
        saleSpire:setAnchorPoint(ccp(0.5,0.5))
        saleSpire:setPosition(ccp(giftSpire:getContentSize().width/2,giftSpire:getContentSize().height/2+5))
        saleSpire:setRotation(25)
        giftSpire:addChild(saleSpire)

        local saleRate = string.format("%.2f",taskTb.dis/10)
        -- 折扣券文字
        local saleLabel = GetTTFLabel(tostring((1-saleRate)*100).."%",20)
        saleLabel:setAnchorPoint(ccp(0,0.5))
        saleLabel:setPosition(ccp(10,saleSpire:getContentSize().height/2))
        saleSpire:addChild(saleLabel)
   
        local offLabel = GetTTFLabel("OFF",10)
        offLabel:setAnchorPoint(ccp(0,0.5))
        offLabel:setPosition(ccp(5+saleLabel:getContentSize().width+6,saleSpire:getContentSize().height/2))
        saleSpire:addChild(offLabel)

	end
    if  acThfbVoApi:getTaskStatus(taskTb.id) == 2 then
    -- 已领取
        local getSpirte = CCSprite:createWithSpriteFrameName("IconCheck.png")
        getSpirte:setAnchorPoint(ccp(0.5,0.5))
        getSpirte:setPosition(ccp(cell:getContentSize().width-65,height))
        cell:addChild(getSpirte)
    elseif acThfbVoApi:getTaskNum(taskTb.id) >= taskTb.num then
    -- 完成未领取
        local function getCallback( ... )
            local function callback(fn,data)
                local ret,sData = base:checkServerData(data)
                if ret==true then 
                    if sData.data and sData.data.reward then
                        local rewardTb = FormatItem(sData.data.reward,nil,true)
                        for k,v in pairs(rewardTb) do
                            G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                        end
                        G_showRewardTip(rewardTb,true)
                    end
                    if sData.data and sData.data.thfb then
                        acThfbVoApi:updateSpecialData(sData.data.thfb)
                        self.taskList = acThfbVoApi:reOrderTaskList()
                        self.tv:reloadData()
                        if self.parent and self.parent.tab1 and self.parent.tab1.refreshTv then
                            self.parent.tab1:refreshTv()
                        end
                    end
                end
            end
            local seq
            if taskTb.id == 100 then
                seq = 8
            else
                seq = taskTb.id
            end
            socketHelper:acThfbGetTaskReward(seq,callback)
        end
        local getButton = G_createBotton(cell,ccp(cell:getContentSize().width-75,height),nil,"yh_taskReward.png","yh_taskReward_down.png","yh_taskReward.png",getCallback,1,-(self.layerNum-1)*20-2)
    else
    -- 未完成
        local strSize = 24
        if G_isAsia() == false then
            strSize = 15
        end
        local unDoneLabel = GetTTFLabel(getlocal("local_war_incomplete"),strSize,true)
        unDoneLabel:setAnchorPoint(ccp(0.5,0.5))
        unDoneLabel:setPosition(ccp(cell:getContentSize().width-65,height))
        cell:addChild(unDoneLabel)
    end

    local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function ()end)
    lineSp:setAnchorPoint(ccp(0.5,0))
    lineSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,3))
    lineSp:setPosition(ccp((G_VisibleSizeWidth-20)/2,3))
    cell:addChild(lineSp)
    if self.flag and self.flag ~= 0 then

        if self.flag == 7 and  taskTb.id == 100 then
            self:runPromotAction(cell)
            self.flag = 0
        elseif self.flag == 8 and taskTb.id == 7 then
            self:runPromotAction(cell)
            self.flag = 0
        elseif self.flag == taskTb.id and  self.flag < 7 then
            self:runPromotAction(cell)
            self.flag = 0
        end
    end

end

function acThfbTaskDialog:runPromotAction(cell)

    local selectedSp=LuaCCScale9Sprite:createWithSpriteFrameName("equipSelectedRect.png",CCRect(20,20,80,80),function()end)
    selectedSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-20,160))
    selectedSp:setAnchorPoint(ccp(0,0))
    selectedSp:setPosition(ccp(0,0))
    cell:addChild(selectedSp,3)
    local fade1 = CCFadeTo:create(0.5,150)
    local fade2 = CCFadeTo:create(0.5,255)
    local delay = CCDelayTime:create(1)
    local acArr = CCArray:create()
    acArr:addObject(fade1)
    acArr:addObject(fade2)
    acArr:addObject(delay)
    local seq = CCSequence:create(acArr)
    local acRepeat = CCRepeat:create(seq,1)
    local function callBack( ... )
        selectedSp:removeFromParentAndCleanup(true)
        selectedSp = nil
    end 
    local callFunc = CCCallFunc:create(callBack)
    local final = CCSequence:createWithTwoActions(acRepeat,callFunc)
    selectedSp:runAction(final)
end

function acThfbTaskDialog:dispose( ... )
    self.flag = nil
end

function acThfbTaskDialog:tick( ... )

end

function acThfbTaskDialog:jumpTask(id)

    self.flag = id
    self.taskList = acThfbVoApi:reOrderTaskList()

    local jumpIdx 

    for k,v in pairs(self.taskList) do
        if id == 7 and v.id == 100 then
            jumpIdx = k
        elseif id == 8 and v.id == 7 then
            jumpIdx = k
        elseif id < 7 and id == v.id then
            jumpIdx = k
        end
    end

    local minJumpH,maxJumpH=-(self.cellHeight*(#acThfbVoApi:getTaskList())-self.tvHeight),0
    local jumpHeight=jumpIdx*self.cellHeight-self.tvHeight+self.cellHeight/2
    local recordPoint=self.tv:getRecordPoint()
    recordPoint.y=0-(self.cellHeight-self.tvHeight-jumpHeight)
    if recordPoint.y>maxJumpH then
        recordPoint.y=maxJumpH
    elseif recordPoint.y<minJumpH then
        recordPoint.y=minJumpH
    end
    if jumpIdx == 1 or jumpIdx == 2 or jumpIdx == 3 then
        self.tv:reloadData()
    else
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
    
end

function acThfbTaskDialog:fastTick( ... )
    
end


