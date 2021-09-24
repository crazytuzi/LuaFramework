acMjcsTab2={
}

function acMjcsTab2:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.layerNum=layerNum
    self.state = 0 

    return nc;
end

function acMjcsTab2:init( parent )
	self.bgLayer=CCLayer:create()
    self.parent=parent

	--活动时间
 	local acTimeLb=GetTTFLabel(acMjcsVoApi:getTimeStr(),22,true)
	acTimeLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-185))
	acTimeLb:setColor(G_ColorYellowPro)
	self.bgLayer:addChild(acTimeLb)
	self.acTimeLb=acTimeLb

	--I里的信息
    local function touchTip()
		local tabStr={getlocal("activity_mjcs_tab1_info1"),getlocal("activity_mjcs_tab2_info2")}
		require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
		tipShowSmallDialog:showStrInfo(self.layerNum+5,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),tabStr)
	end
	G_addMenuInfo(self.bgLayer,self.layerNum+1,ccp(G_VisibleSizeWidth - 40,G_VisibleSizeHeight-185),{},nil,0.7,28,touchTip,true)

	--任务列表
    self:refreshTaskList()
    self.cellNum = acMjcsVoApi:taskListNum()
    self.cellHeight = 150
    self.tvWidth = G_VisibleSizeWidth-40
    self.tvHeight = G_VisibleSizeHeight - 250

    

    local pos = ccp(20,20)
    local function nilFunc( ... )
    end
    local tbBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),nilFunc)
    tbBg:setContentSize(CCSizeMake(self.tvWidth,self.tvHeight))
    tbBg:setAnchorPoint(ccp(0,0))
    tbBg:setPosition(pos)
    self.bgLayer:addChild(tbBg)

    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(pos)
    self.bgLayer:addChild(self.tv)

    --以下代码处理上下遮挡层
    local function forbidClick()
   
    end
    local capInSet = CCRect(20, 20, 10, 10);
    self.topforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
    self.topforbidSp:setTouchPriority(-(self.layerNum-1)*20-3)
    self.topforbidSp:setAnchorPoint(ccp(0,0))
    local topY
    local topHeight
    if(self.tv~=nil)then
        local tvX,tvY=self.tv:getPosition()
        topY=tvY+self.tv:getViewSize().height
        topHeight=G_VisibleSizeHeight-topY
    else
        topHeight=0
        topY=0
    end
    self.topforbidSp:setContentSize(CCSize(G_VisibleSizeWidth,topHeight))
    self.topforbidSp:setPosition(0,topY)
    self.bgLayer:addChild(self.topforbidSp)

    self:resetForbidLayer()
    self.topforbidSp:setVisible(false)

	return self.bgLayer
end

function acMjcsTab2:resetForbidLayer()
   if(self.tv~=nil)then
     local tvX,tvY=self.tv:getPosition()
   else
     -- 如果没有self.tv 将遮罩移出屏幕外防止干扰
     if self.topforbidSp then
        self.topforbidSp:setPosition(ccp(9999,0))
     end
   end
end

function acMjcsTab2:refreshTaskList()
    self.tasks=acMjcsVoApi:getSortTaskList()
end
    
function acMjcsTab2:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
        return CCSizeMake(self.tvWidth,self.cellHeight)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function()end)
        lineSp:setContentSize(CCSizeMake(self.tvWidth-20, 4))
        lineSp:ignoreAnchorPointForPosition(false)
        lineSp:setAnchorPoint(ccp(0.5, 0))
        lineSp:setPosition(self.tvWidth / 2,self.cellHeight-6)
        cell:addChild(lineSp)

        local fontSize =22
        if not G_isAsia() then
            fontSize=18
        end
        local tbTitleImage = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png", CCRect(105, 16, 1, 1), function()end)
        tbTitleImage:setContentSize(CCSizeMake(self.tvWidth-20, tbTitleImage:getContentSize().height))
        tbTitleImage:setAnchorPoint(ccp(0,1))
        tbTitleImage:setPosition(ccp(3,self.cellHeight-8))
        cell:addChild(tbTitleImage)

        local task = self.tasks[idx+1]
        local tid=task.id

        local titleDes = GetTTFLabelWrap(acMjcsVoApi:taskListDes(tid),fontSize,CCSizeMake(self.tvWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        titleDes:setAnchorPoint(ccp(0,1))
        titleDes:setPosition(ccp(30,lineSp:getPositionY()-5))
        titleDes:setColor(G_ColorYellowPro)
        cell:addChild(titleDes)

        local taskRwardList,taskLimit,tasktype,starClass = acMjcsVoApi:taskList(tid)

        for k,v in pairs(taskRwardList) do
            if v then 
                local function showTip()
                    G_showNewPropInfo(self.layerNum+1,true,true,nil,v) 
                end
                 
                local iconSp = G_getItemIcon(v,nil,false,100,showTip,nil,nil,nil,nil,nil,true)
                local scale = 80/iconSp:getContentSize().width
                iconSp:setAnchorPoint(ccp(0,1))
                iconSp:setScale(scale)
                local iconSize=iconSp:getContentSize().width*scale
                iconSp:setPosition(ccp(30+(iconSize+15)*(k-1),titleDes:getPositionY()-titleDes:getContentSize().height-20))
                iconSp:setTouchPriority(-(self.layerNum-1)*20-2)
                cell:addChild(iconSp,6)

                local numLb=GetTTFLabel("x"..FormatNumber(v.num),20/scale)
                numLb:setAnchorPoint(ccp(1,0))
                numLb:setPosition(ccp(iconSp:getContentSize().width-5,5))
                iconSp:addChild(numLb,4)
                local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
                numBg:setAnchorPoint(ccp(1,0))
                numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-2))
                numBg:setPosition(ccp(iconSp:getContentSize().width-5,5))
                numBg:setOpacity(150)
                iconSp:addChild(numBg,3) 
            end
        end

        local function lotteryHandler( ... )
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                local function refreshFunc(reward)
                    if not self.parent:isClosed() then
                        self:refreshTaskList()
                        local recordPoint = self.tv:getRecordPoint()
                        self.tv:reloadData()
                        self.tv:recoverToRecordPoint(recordPoint)
                        self.parent:setIconTipVisibleByIdx(acMjcsVoApi:tab2Reward(),2)

                        -- 此处加弹板
                        if reward then
                            G_showRewardTip(reward, true)
                        end
                    end
                end

                -- 兑换逻辑
                if acMjcsVoApi:taskIsFinish( tid )==0 then
                    local action="task"
                    acMjcsVoApi:socketMjcsTask(action,refreshFunc,tid)
                elseif acMjcsVoApi:taskIsFinish( tid )==1 then
                    G_showTipsDialog(getlocal("activity_mjcs_alert"))
                end
            end
        end

        
        local hasReward = GetTTFLabel(getlocal("activity_vipAction_had"),24,true)
        hasReward:setAnchorPoint(ccp(1,0.5))
        hasReward:setColor(ccc3(168,168,168))
        hasReward:setPosition(ccp(self.tvWidth-60,60))
        cell:addChild(hasReward)

        local notReward = GetTTFLabel(getlocal("noReached"),24,true)
        notReward:setAnchorPoint(ccp(1,0.5))
        notReward:setColor(ccc3(168,168,168))
        notReward:setPosition(ccp(self.tvWidth-60,60))
        cell:addChild(notReward)

        local lotteryBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",lotteryHandler,nil,getlocal("daily_scene_get"),30,11)
        lotteryBtn:setScale(0.7)
        local lotteryMenu=CCMenu:createWithItem(lotteryBtn)
        lotteryMenu:setTouchPriority(-(self.layerNum-1)*20-2)
        lotteryMenu:setAnchorPoint(ccp(0,1))
        lotteryMenu:setPosition(ccp(self.tvWidth-100,60))
        lotteryMenu:setVisible(not judge)
        cell:addChild(lotteryMenu)

        local judge = acMjcsVoApi:taskIsFinish( tid )
        if judge==1 then
            hasReward:setVisible(false)
            lotteryMenu:setVisible(false)
        elseif judge==0 then
            hasReward:setVisible(false)
            notReward:setVisible(false)
            G_addNumTip(lotteryBtn,ccp(lotteryBtn:getContentSize().width-2,lotteryBtn:getContentSize().height-2),true,1,0.9)
        else 
            lotteryMenu:setVisible(false)
            notReward:setVisible(false)
        end

        return cell
    end
end

function acMjcsTab2:tick( ... )
	if tolua.cast(self.acTimeLb,"CCLabelTTF") then
    	self.acTimeLb:setString(acMjcsVoApi:getTimeStr())
    end
end

function acMjcsTab2:updateUI( ... )
    self:refreshTaskList()
    local recordPoint = self.tv:getRecordPoint()
    self.tv:reloadData()
    self.tv:recoverToRecordPoint(recordPoint)
    self.parent:setIconTipVisibleByIdx(acMjcsVoApi:tab2Reward(),2)
end

function acMjcsTab2:dispose( )
    self.layerNum = nil
    self.bgLayer = nil
    self.tv = nil
end