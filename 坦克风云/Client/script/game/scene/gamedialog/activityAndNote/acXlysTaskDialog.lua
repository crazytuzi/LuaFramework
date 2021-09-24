-- @Author hj
-- @Description  训练有素任务板子 
-- @Date 2018-07-02

acXlysTaskDialog = {}

function acXlysTaskDialog:new(layer)
	local nc = {
		layerNum = layer,
        taskList = acXlysVoApi:getTaskList()
	}
	setmetatable(nc,self)
	self.__index = self
	return nc
end

function acXlysTaskDialog:init()
	self.bgLayer=CCLayer:create()
	self:initTableView()
	return self.bgLayer
end

function acXlysTaskDialog:initTableView( ... )
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

function acXlysTaskDialog:eventHandler(handler,fn,idx,cel)
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

function acXlysTaskDialog:initCell(seq,cell)

	cell:setContentSize(CCSizeMake(G_VisibleSizeWidth-20,160))

    local taskInfo = self.taskList[seq]
    local taskId = taskInfo.id
    local taskType = taskInfo.type
    local taskDoneLimit = taskInfo.num
    local rewardTb = FormatItem(taskInfo.reward,true,true)
    local taskStatus = acXlysVoApi:getTaskStatus(taskId) 
    local taskNum
    local height = (cell:getContentSize().height-32-5)/2+2

	-- 任务描述框
	local function nilFunc( ... )
	end
    local titleSpire = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,0,1,32),nilFunc)
    titleSpire:setContentSize(CCSizeMake(cell:getContentSize().width-150,32))
    titleSpire:setAnchorPoint(ccp(0,0.5))
    cell:addChild(titleSpire)
    titleSpire:setPosition(ccp(5,cell:getContentSize().height-20))

    local colorTb 
    if acXlysVoApi:getTaskNum(taskType) >= taskDoneLimit then
        colorTb = {nil,G_ColorGreen,nil}
        taskNum = taskDoneLimit
    else
        colorTb = {nil,G_ColorRed,nil}
        taskNum = acXlysVoApi:getTaskNum(taskType)
    end

    local strSize = 24
    if G_isAsia() == false then
        strSize = 18
    end

    local descLb = G_getRichTextLabel(getlocal("activity_xlys_taskDesc"..taskType,{taskNum,taskDoneLimit}),colorTb,strSize,cell:getContentSize().width-100,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    descLb:setAnchorPoint(ccp(0,1))
    descLb:setPosition(ccp(20,cell:getContentSize().height-5))
    cell:addChild(descLb)

    local strSize = 22
    if G_getCurChoseLanguage() == "de" then
        strSize = 15
    end
    local rewardLb = GetTTFLabel(getlocal("seasonRewardStr"),strSize,true)
    rewardLb:setAnchorPoint(ccp(0.5,0.5))
    rewardLb:setPosition(ccp(60,height))
    cell:addChild(rewardLb)

    for k,v in pairs(rewardTb) do
        if v then
            local scaleSize = 80
            local px,py= 160 + 100*(k-1),height
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


    if taskStatus == 1 then
        local strSize = 24
        if G_isAsia() == false then
            strSize = 15
        end
        local unDoneLabel = GetTTFLabel(getlocal("local_war_incomplete"),strSize,true)
        unDoneLabel:setAnchorPoint(ccp(0.5,0.5))
        unDoneLabel:setPosition(ccp(cell:getContentSize().width-65,height))
        cell:addChild(unDoneLabel)
    elseif taskStatus == 2 then
        local strSize = 24
        if G_isAsia() == false then
            strSize = 15
        end
        local doneLabel = GetTTFLabel(getlocal("activity_wanshengjiedazuozhan_complete"),strSize,true)
        doneLabel:setAnchorPoint(ccp(0.5,0.5))
        doneLabel:setPosition(ccp(cell:getContentSize().width-65,height))
        doneLabel:setColor(G_ColorGray)
        cell:addChild(doneLabel)
    else
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
                    if sData.data and sData.data.xlys then
                        acXlysVoApi:updateSpecialData(sData.data.xlys)
                        self.taskList = acXlysVoApi:getTaskList()
                        self.tv:reloadData()
                    end
                end
            end
            socketHelper:acXlysTask(taskId,callback)
        end
        local getButton = G_createBotton(cell,ccp(cell:getContentSize().width-75,height),nil,"yh_taskReward.png","yh_taskReward_down.png","yh_taskReward.png",getCallback,1,-(self.layerNum-1)*20-2)
    end

    local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function ()end)
    lineSp:setAnchorPoint(ccp(0.5,0))
    lineSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,3))
    lineSp:setPosition(ccp((G_VisibleSizeWidth-20)/2,3))
    cell:addChild(lineSp)

end

function acXlysTaskDialog:refreshTv( ... )
    self.taskList = acXlysVoApi:getTaskList()
    self.tv:reloadData()
end

function acXlysTaskDialog:dispose( ... )
    self.taskList = nil
end

function acXlysTaskDialog:tick( ... )

end


function acXlysTaskDialog:fastTick(dt)
    
end


