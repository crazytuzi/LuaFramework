acWsjdzzTab2={

}

function acWsjdzzTab2:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil

    return nc;
end

function acWsjdzzTab2:init(layerNum,parent)
    self.activeName=acWsjdzzVoApi:getActiveName()
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    self:initTableView()
    return self.bgLayer
end

function acWsjdzzTab2:initTableView()
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-50,G_VisibleSizeHeight-200),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(25,40))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
end

function acWsjdzzTab2:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local acVo = acWsjdzzVoApi:getAcVo()
        return SizeOfTable(acVo.taskList)
    elseif fn=="tableCellSizeForIndex" then
        -- local tmpSize = CCSizeMake(G_VisibleSizeWidth-50,200)
        local tmpSize = CCSizeMake(G_VisibleSizeWidth-50,160)
        return tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local taskList=acWsjdzzVoApi:getTaskList()
        local taskData=taskList[idx+1]
        local id=taskData.id
        local reward=taskData.reward
        local taskType=taskData.taskType
        local num=taskData.num
        local maxNum=taskData.maxNum
        local isReward=taskData.isReward
        local status=taskData.status

        -- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
        local cellWidth=G_VisibleSizeWidth-50
        -- local cellHeight=200
        local cellHeight=160
        local rect = CCRect(0, 0, 50, 50)
        local capInSet = CCRect(48, 48, 2, 2)
        local function cellClick(hd,fn,idx)
        end
        local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("wsjdzz_di3.png",capInSet,cellClick)
        backSprie:setContentSize(CCSizeMake(cellWidth-10,cellHeight))
        backSprie:ignoreAnchorPointForPosition(false)
        backSprie:setAnchorPoint(ccp(0,0))
        backSprie:setIsSallow(false)
        backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
        backSprie:setPosition(ccp(5,0))
        cell:addChild(backSprie,1)

        local bgSp=CCSprite:createWithSpriteFrameName("threeyear_bg.png")
        bgSp:setPosition(backSprie:getContentSize().width/2+5,backSprie:getContentSize().height/2)
        cell:addChild(bgSp)
        bgSp:setScaleX((backSprie:getContentSize().width-5)/bgSp:getContentSize().width)
        bgSp:setScaleY((backSprie:getContentSize().height-10)/bgSp:getContentSize().height)

        -- local backSprie=CCSprite:createWithSpriteFrameName("7daysBg.png")
        -- backSprie:setAnchorPoint(ccp(0,0))
        -- backSprie:setPosition(ccp(0,10))
        -- cell:addChild(backSprie,1)

        -- local version=acWsjdzzVoApi:getVersion()
        local titleStr=""
        
        if taskType=="hit" and maxNum==10 then
            if(acWsjdzzVoApi:isNormalVersion())then
                titleStr=getlocal("activity_wanshengjiedazuozhan_task_hit2_n",{maxNum})
            else
                titleStr=getlocal("activity_wanshengjiedazuozhan_task_hit2",{maxNum})
            end
            -- if version>1 then
            --     titleStr=getlocal("activity_wanshengjiedazuozhan_task_hit2_"..version,{maxNum})
            -- end
        else
            if(acWsjdzzVoApi:isNormalVersion())then
                titleStr=getlocal("activity_wanshengjiedazuozhan_task_"..taskType.."_n",{maxNum})
            else
                titleStr=getlocal("activity_wanshengjiedazuozhan_task_"..taskType,{maxNum})
            end
            -- if version>1 then
            --     titleStr=getlocal("activity_wanshengjiedazuozhan_task_"..taskType.."_"..version,{maxNum})
            -- end
        end
        
        -- titleStr=str
        local titleLb=GetTTFLabelWrap(titleStr,25,CCSizeMake(backSprie:getContentSize().width-180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        titleLb:setAnchorPoint(ccp(0,0.5))
        titleLb:setColor(G_ColorYellowPro)
        titleLb:setPosition(ccp(20,backSprie:getContentSize().height-35))
        backSprie:addChild(titleLb,1)

        local posY,strSize2=55,22
        local rewardStr=getlocal("award")
        if G_getCurChoseLanguage() =="fr" then
            strSize2 = 20
        end
        local rewardStr=getlocal("award")
        -- rewardStr="啊啊啊啊啊啊啊"
        local rewardLb=GetTTFLabelWrap(rewardStr,strSize2,CCSizeMake(120,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        rewardLb:setAnchorPoint(ccp(0,0.5))
        rewardLb:setPosition(ccp(20,posY))
        backSprie:addChild(rewardLb,1)

        local rewardTab=FormatItem(reward,true,true)
        for k,v in pairs(rewardTab) do
            if v then
                local px,py=180+100*(k-1),posY
                local icon,scale=G_getItemIcon(v,80,true,self.layerNum,nil,self.tv)
                icon:setTouchPriority(-(self.layerNum-1)*20-2)
                icon:setPosition(ccp(px,py))
                backSprie:addChild(icon,1)
                local numLb=GetTTFLabel("x"..FormatNumber(v.num),20)
                numLb:setAnchorPoint(ccp(1,0))
                numLb:setPosition(ccp(icon:getContentSize().width-5,5))
                icon:addChild(numLb,1)
                numLb:setScale(1/scale)
            end
        end

        local statusStr=""
        local color=G_ColorWhite
        local lbPosY=backSprie:getContentSize().height/2

        if status==1 then
            if num>maxNum then
                num=maxNum
            end
            statusStr=getlocal("scheduleChapter",{num,maxNum})
            if taskType=="hit" then
                statusStr=getlocal("scheduleChapter",{1,1})
            end

            local function rewardHandler()
                if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)

                    local function activeCallback(fn,data)
                        local ret,sData=base:checkServerData(data)
                        if ret==true then
                            if sData.data then
                                if sData.data[self.activeName] then
                                    acWsjdzzVoApi:updateData(sData.data[self.activeName])
                                end
                                if sData and sData.data and sData.data.accessory and accessoryVoApi then
                                    accessoryVoApi:onRefreshData(sData.data.accessory)
                                end
                                if sData and sData.data and sData.data.alien and alienTechVoApi then
                                    alienTechVoApi:setTechData(sData.data.alien)
                                end
                                if sData.data.reward then
                                    local award=FormatItem(sData.data.reward)
                                    G_showRewardTip(award,true)

                                    -- local delay=CCDelayTime:create(2)
                                    -- -- local function acCallfunc1()
                                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("receivereward_received_success"),28)
                                    -- end
                                    -- local endFunc=CCCallFunc:create(acCallfunc1)
                                    -- local acArr=CCArray:create()
                                    -- acArr:addObject(delay)
                                    -- acArr:addObject(endFunc)
                                    -- local seq=CCSequence:create(acArr)
                                    -- self.bgLayer:runAction(seq)
                                end
                                local recordPoint=self.tv:getRecordPoint()
                                self.tv:reloadData()
                                self.tv:recoverToRecordPoint(recordPoint)
                            end
                        end
                    end
                    local cmdStr="active.halloween2016.task"
                    local tid=id
                    socketHelper:activityWsjdzz(cmdStr,nil,tid,nil,activeCallback)
                end
            end
            local rewardItem=GetButtonItem("TaskBtnGet.png","TaskBtnGet_Down.png","TaskBtnGet_Down.png",rewardHandler,2,nil,25)
            -- rewardItem:setScale(0.8)
            local rewardMenu=CCMenu:createWithItem(rewardItem)
            rewardMenu:setPosition(ccp(backSprie:getContentSize().width-80,posY))
            rewardMenu:setTouchPriority(-(self.layerNum-1)*20-2)
            backSprie:addChild(rewardMenu,1)


            -- local lightSp = CCSprite:createWithSpriteFrameName("7daysLight.png")
            -- lightSp:setPosition(getCenterPoint(backSprie))
            -- backSprie:addChild(lightSp)
            -- lightSp:setScaleX(backSprie:getContentSize().width/lightSp:getContentSize().width)
            -- lightSp:setScaleY(backSprie:getContentSize().height/lightSp:getContentSize().height)

            lbPosY=backSprie:getContentSize().height-40

            
        elseif status==2 then
            if num>maxNum then
                num=maxNum
            end
            statusStr=getlocal("scheduleChapter",{num,maxNum})
            if taskType=="hit" then
                statusStr=getlocal("scheduleChapter",{0,1})
            end
        elseif status==3 then
            -- statusStr=getlocal("activity_wanshengjiedazuozhan_complete")
            -- color=G_ColorGreen
            statusStr=""
            color=G_ColorGreen
        end
        local strSubPosWidth = 120
        if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
                strSubPosWidth =80
        end
        local statusLb=GetTTFLabel(statusStr,25)
        statusLb:setPosition(ccp(backSprie:getContentSize().width-strSubPosWidth,lbPosY))
        backSprie:addChild(statusLb,1)
        statusLb:setColor(color)

        if status==3 then
            local p1Sp=CCSprite:createWithSpriteFrameName("IconCheck.png")
            backSprie:addChild(p1Sp,2)
            p1Sp:setPosition(ccp(backSprie:getContentSize().width-strSubPosWidth,lbPosY))
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

function acWsjdzzTab2:refresh()
    if self and self.tv then
        local recordPoint=self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
end

function acWsjdzzTab2:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.tv=nil
    self.layerNum=nil
end
