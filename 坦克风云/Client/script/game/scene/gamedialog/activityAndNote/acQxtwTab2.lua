acQxtwTab2={
}

function acQxtwTab2:new(layerNum,parent)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.tv=nil
    self.bgLayer=nil
    self.layerNum=layerNum
    self.parent=parent

    return nc;
end

function acQxtwTab2:init()
    self.bgLayer=CCLayer:create()

    self:initUI()
    self:initTableView()
    return self.bgLayer
end


function acQxtwTab2:initUI()
    local function goToCallback()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if acQxtwVoApi:getGoFlag() then
            self.parent:tabClick(0)
            return
        end
        PlayEffect(audioCfg.mouseClick)
        
        if base.emblemSwitch~=1 then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("backstage17000"),nil,self.layerNum+1)
            do return end
        end
        local permitLevel = emblemVoApi:getPermitLevel()
        if permitLevel and playerVoApi:getPlayerLevel()<permitLevel then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("emblem_building_not_permit",{permitLevel}),nil,self.layerNum+1)
            do return end
        end
        activityAndNoteDialog:closeAllDialog()
        emblemVoApi:showMainDialog(4)
    end
    local lbStr
    lbStr=getlocal("activity_heartOfIron_goto")
    local adaH = 0
    if G_getIphoneType() == G_iphoneX then
        adaH = 50
    end
    local goItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",goToCallback,nil,lbStr,25,11)
    local goBtn=CCMenu:createWithItem(goItem);
    goBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    goBtn:setPosition(ccp(G_VisibleSizeWidth/2,70+adaH))
    self.bgLayer:addChild(goBtn)

    local lbH=self.bgLayer:getContentSize().height-180
    self.tvH=lbH-120-adaH
end

function acQxtwTab2:initTableView()
    local adaH = 0
    if G_getIphoneType() == G_iphoneX then
        adaH = 50
    end
    self.cellHeight=165
    self.taskTb=acQxtwVoApi:getCurrentTaskState()
    self.cellNum=SizeOfTable(self.taskTb)

    local function callBack(...)
         return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-50,self.tvH),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(25,120 + adaH))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(120)
end

function acQxtwTab2:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(G_VisibleSizeWidth-50,self.cellHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local index=self.taskTb[idx+1].index

        local rect = CCRect(0, 0, 50, 50)
        local capInSet = CCRect(20, 20, 10, 10)
        local function cellClick(hd,fn,idx)
        end

        local bgPic="panelItemBg.png"
        if index<1000 then
            bgPic="letterBgWrite.png"
        end
        -- letterBgWrite
        -- NoticeLine
        local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName(bgPic,capInSet,cellClick)
        backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,self.cellHeight-5))
        backSprie:ignoreAnchorPointForPosition(false)
        backSprie:setAnchorPoint(ccp(0,0))
        backSprie:setIsSallow(false)
        backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
        backSprie:setPosition(ccp(0,0))
        cell:addChild(backSprie,1)


        -- 数据
        local valueTb=self.taskTb[idx+1].value
        local trueIndex=valueTb.type
        local haveNum=self.taskTb[idx+1].haveNum
        local needNum=valueTb.needNum
        local loveNum=valueTb.love

        -- 任务描述
        local lbStarWidth=20
        local titleStr
        --任务6,7是拥有XX军徽，处理方式不同
        if(trueIndex==6 or trueIndex==7)then
            local sid=valueTb.sid
            if(sid)then
                local equipName=emblemVoApi:getEquipName(sid)
                titleStr=getlocal("emblem_infoOwn",{equipName})
            else
                titleStr=getlocal("world_war_landType_unknow")
            end            
        else
            titleStr=getlocal("activity_qxtw_task" .. trueIndex,{FormatNumber(haveNum) .. "/" .. FormatNumber(needNum)})
        end
        if acQxtwVoApi:isMustR() and trueIndex==2 then
            titleStr=getlocal("activity_qxtw_taskNew" .. trueIndex,{FormatNumber(haveNum) .. "/" .. FormatNumber(needNum)})
        end
        local titleLb=GetTTFLabelWrap(titleStr,25,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        titleLb:setAnchorPoint(ccp(0,1))
        titleLb:setColor(G_ColorYellowPro)
        titleLb:setPosition(ccp(lbStarWidth,backSprie:getContentSize().height-10))
        backSprie:addChild(titleLb,1)

        -- 奖励描述
        local desH=(self.cellHeight - titleLb:getContentSize().height-20)/2
        local desLb=GetTTFLabelWrap(getlocal("activity_rechargeDouble_get"),22,CCSizeMake(100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        desLb:setAnchorPoint(ccp(0,0.5))
        -- desLb:setColor(G_ColorYellowPro)
        desLb:setPosition(ccp(lbStarWidth,desH))
        backSprie:addChild(desLb)

        -- 奖励展示
        local rewardItem=FormatItem(valueTb.reward,nil,true)
        local taskW=0
        for k,v in pairs(rewardItem) do
            local icon = G_getItemIcon(v,100,true,self.layerNum+1,nil,self.tv,nil,nil,nil,nil,true)
            icon:setTouchPriority(-(self.layerNum-1)*20-2)
            backSprie:addChild(icon)
            icon:setAnchorPoint(ccp(0,0.5))
            icon:setPosition(k*100+20, desH)
            local scale=80/icon:getContentSize().width
            icon:setScale(scale)
            taskW=k*100


            local numLabel=GetTTFLabel("x"..FormatNumber(v.num),22)
            numLabel:setAnchorPoint(ccp(1,0))
            numLabel:setPosition(icon:getContentSize().width-5, 5)
            numLabel:setScale(1/scale)
            icon:addChild(numLabel,1)
        end

        
        if index>10000 then -- 已完成(已领取)
            local desLb=GetTTFLabelWrap(getlocal("activity_hadReward"),25,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            -- desLb:setColor(G_ColorYellowPro)
            desLb:setPosition(ccp(backSprie:getContentSize().width-90,backSprie:getContentSize().height/2))
            backSprie:addChild(desLb)
            desLb:setColor(G_ColorGreen)
            titleLb:setColor(G_ColorWhite)
        elseif index>1000 then -- 未完成
            local desLb=GetTTFLabelWrap(getlocal("local_war_incomplete"),25,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            -- desLb:setColor(G_ColorYellowPro)
            desLb:setPosition(ccp(backSprie:getContentSize().width-90,backSprie:getContentSize().height/2))
            backSprie:addChild(desLb)

        else -- 可领取
            local function rewardTiantang()
                if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end

                    local function refreshFunc(rewardlist)
                        self.taskTb=acQxtwVoApi:getCurrentTaskState()
                        local recordPoint=self.tv:getRecordPoint()
                        self.tv:reloadData()
                        self.tv:recoverToRecordPoint(recordPoint)

                        -- 此处加弹板
                        if rewardlist then
                            acQxtwVoApi:showRewardDialog(rewardlist,self.layerNum)
                        end
                    end
                    local cmd="active.quanxiantuwei.taskreward"
                    local tid=self.taskTb[idx+1].key
                    acQxtwVoApi:socketQxtw(cmd,nil,nil,refreshFunc,tid)
                
                end
            end
            -- "BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png"
            local rewardItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",rewardTiantang,nil,getlocal("daily_scene_get"),25)
            -- rewardItem:setScale(0.8)
            local rewardBtn=CCMenu:createWithItem(rewardItem);
            rewardBtn:setTouchPriority(-(self.layerNum-1)*20-2);
            local adaH = 0
            if G_getIphoneType() == G_iphoneX then
                adaH = 20
            end
            rewardBtn:setPosition(ccp(backSprie:getContentSize().width-90-adaH,backSprie:getContentSize().height/2))
            backSprie:addChild(rewardBtn)
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


function acQxtwTab2:refresh()
    if self.tv then
        self.taskTb=acQxtwVoApi:getCurrentTaskState()
        local recordPoint=self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
         
end


function acQxtwTab2:dispose()
    -- eventDispatcher:removeEventListener("activity.recharge",self.wsjdzzListener)
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.tv=nil
    self.url=nil
    self.layerNum=nil
end
