local believerDailyRewardTab={}

function believerDailyRewardTab:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	
	return nc
end

function believerDailyRewardTab:init(layerNum,parent)
	self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent

    self:initLayer()

    local function dayRefresh(event,data)
        if self.bgLayer then
            self:refresh()
        end
    end
    self.dayRefreshListener=dayRefresh
    eventDispatcher:addEventListener("believer.day.refresh",dayRefresh)

    return self.bgLayer
end

function believerDailyRewardTab:initData()
    local believerCfg=believerVoApi:getBelieverCfg()
    local grade=believerVoApi:getMySegment()
    local user=believerVoApi:getMyUser()
    local dayGrade=grade
    if user and user.day and user.day.day_grade then
        dayGrade=user.day.day_grade
    end
    local dailyTask=believerCfg.dailyTask[dayGrade]
    self.cellNum=SizeOfTable(dailyTask)

    self.taskList={}
    local flags=believerVoApi:getDailyTaskRewardFlags()
    for k,v in pairs(dailyTask) do
        local sortId=k
        local num,needNum,kcoin=believerVoApi:getDailyTaskByIdx(k),v[1],v[2]
        if flags[k] and tonumber(flags[k])==1 then --已领取
            sortId=k*10000+sortId
        elseif num>needNum then --可领取
            sortId=k*100+sortId
        else --未完成
            sortId=k*1000+sortId
        end
        table.insert(self.taskList,{num,needNum,kcoin,(flags[k] or 0),sortId,k})
    end
    --排序任务列表
    local function sortFunc(a,b)
        if a and b and a[5] and b[5] then
            if a[5]<b[5] then
                return true
            end
        end
        return false
    end
    table.sort(self.taskList,sortFunc)
end

function believerDailyRewardTab:initLayer()
    self:initData()

    local adaSize = 0
    if G_getCurChoseLanguage() == "ar" then
        adaSize = 40
    end
    local fontSize=25
    local promptLb=GetTTFLabelWrap(getlocal("believer_reward_daily_prompt"),fontSize,CCSizeMake(G_VisibleSizeWidth-150-adaSize,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    promptLb:setAnchorPoint(ccp(0.5,0.5))
    promptLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-190))
    self.bgLayer:addChild(promptLb)


    local function infoHandler()
    	local tabStr={}
    	for i=1,4 do
    		table.insert(tabStr,getlocal("believer_reward_daily_info_"..i))
    	end
		require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
		tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),tabStr)
    end
    G_addMenuInfo(self.bgLayer,self.layerNum,ccp(G_VisibleSizeWidth-60,promptLb:getPositionY()),{},nil,nil,28,infoHandler,true)

	self.tvWidth,self.tvHeight,self.cellHeight=616,G_VisibleSizeHeight-260,150
    local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
    tvBg:setAnchorPoint(ccp(0.5,1))
    tvBg:setContentSize(CCSizeMake(self.tvWidth,self.tvHeight+10))
    tvBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-220)
    self.bgLayer:addChild(tvBg)

    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    self.tv:setPosition((G_VisibleSizeWidth-self.tvWidth)/2,tvBg:getPositionY()-self.tvHeight-5)
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)
end

function believerDailyRewardTab:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(self.tvWidth,self.cellHeight)
        return tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local task=self.taskList[idx+1]
        if task then
            local num,needNum,kcoin,rewardFlag,rewardIdx=task[1],task[2],task[3],task[4],task[6]
        	local itemHeight=self.cellHeight-6
            local fontSize=22

            local colorTb={}
            local descStr=""
            if rewardIdx==1 or rewardIdx==4 or rewardIdx==5 then
                descStr=getlocal("believer_reward_daily_desc_1",{num,needNum})
            else
                descStr=getlocal("believer_reward_daily_desc_"..rewardIdx,{num,needNum})
            end
            if num>=needNum then
                colorTb={nil,G_ColorGreen,nil}
            else
                colorTb={nil,G_ColorRed,nil}
            end
            local descLb,lbheight=G_getRichTextLabel(descStr,colorTb,fontSize,self.tvWidth-100,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            descLb:setAnchorPoint(ccp(0,1))
            descLb:setPosition(ccp(20,itemHeight-15))
            cell:addChild(descLb)

            local rewardLb=GetTTFLabelWrap(getlocal("award")..":",fontSize-2,CCSizeMake(120,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            rewardLb:setAnchorPoint(ccp(0,0.5))
            rewardLb:setPosition(ccp(descLb:getPositionX(),(itemHeight-lbheight-20)/2))
            cell:addChild(rewardLb)

            local kCoinSp=CCSprite:createWithSpriteFrameName("believerKcoin.png")
            kCoinSp:setAnchorPoint(ccp(0,0.5))
            kCoinSp:setPosition(ccp(rewardLb:getPositionX()+rewardLb:getContentSize().width,rewardLb:getPositionY()))
            kCoinSp:setScale(0.7)
            cell:addChild(kCoinSp)
            local iconWidth=kCoinSp:getScale()*kCoinSp:getContentSize().width

            local kcoinNumLb=GetTTFLabelWrap("x"..kcoin,fontSize-2,CCSizeMake(100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            kcoinNumLb:setAnchorPoint(ccp(0,0.5))
            kcoinNumLb:setPosition(ccp(kCoinSp:getPositionX()+iconWidth,kCoinSp:getPositionY()))
            cell:addChild(kcoinNumLb)

            local function getHandler()
                if self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    local function getCallBack()
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("receivereward_received_success"),28)
                        self:refresh()
                    end
                    believerVoApi:getRewardRequest(1,rewardIdx,getCallBack)
                end
            end
            local state=0
            local btnStr=""
            if num>=needNum then --任务已完成
                if rewardFlag==1 then
                    btnStr=getlocal("activity_hadReward")
                    state=2
                else
                    btnStr=getlocal("daily_scene_get")
                end
            else
                btnStr=getlocal("noReached") --未完成
                state=1
            end
            if state==2 then
                local finishedSp=CCSprite:createWithSpriteFrameName("IconCheck.png")
                finishedSp:setPosition(ccp(self.tvWidth-90,rewardLb:getPositionY()))
                cell:addChild(finishedSp,1)
            else
                local btnScale,priority=0.6,-(self.layerNum-1)*20-4
                local getItem=G_createBotton(cell,ccp(self.tvWidth-90,rewardLb:getPositionY()),{btnStr,22},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",getHandler,btnScale,priority)
                if state==0 then
                    getItem:setEnabled(true)
                else
                    getItem:setEnabled(false)
                end
            end

            local mLine=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function () end)
            mLine:setContentSize(CCSizeMake(self.tvWidth-20,mLine:getContentSize().height))
            mLine:setPosition(self.tvWidth/2,mLine:getContentSize().height/2)
            cell:addChild(mLine)
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

function believerDailyRewardTab:refresh()
    if self.tv then
        self:initData()
        self.tv:reloadData()
    end
    if self.parent and self.parent.refreshRedTip then
        self.parent:refreshRedTip(1)
    end
end

function believerDailyRewardTab:dispose()
    self.taskList=nil
    self.cellNum=nil
    if self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil
    end
    self.layerNum=nil
    self.parent=nil
    self.tvWidth=nil
    self.tvHeight=nil
    self.cellHeight=nil
    if self.dayRefreshListener then
        eventDispatcher:removeEventListener("believer.day.refresh",self.dayRefreshListener)
        self.dayRefreshListener=nil
    end
end

return believerDailyRewardTab