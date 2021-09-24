acWsjdzzIITabTwo={

}

function acWsjdzzIITabTwo:new(parent)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.parent = parent
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil

    return nc;
end

function acWsjdzzIITabTwo:init(layerNum,parent)
    self.activeName=acWsjdzzIIVoApi:getActiveName()
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    self:initTableView()
    return self.bgLayer
end

function acWsjdzzIITabTwo:initTableView()
    local function callBack(...)
        return self:eventHandler(...)
    end

    local function nilFunc( ... )
        -- body
    end
    if acWsjdzzIIVoApi:getVersion() == 3 then
        local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),nilFunc)
        self.bgLayer:addChild(tvBg)
        tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20,G_VisibleSizeHeight-215))
        tvBg:setAnchorPoint(ccp(0,0))
        tvBg:setPosition(ccp(10,40))
    end

    local hd= LuaEventHandler:createHandler(callBack)
    if acWsjdzzIIVoApi:getVersion() == 3 then
        self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-20,G_VisibleSizeHeight-235),nil)
        self.tv:setPosition(ccp(10,50))
    else
        self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-50,G_VisibleSizeHeight-200),nil)
        self.tv:setPosition(ccp(25,40))
    end
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
end

function acWsjdzzIITabTwo:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local acVo = acWsjdzzIIVoApi:getAcVo()
        return SizeOfTable(acVo.taskList)
    elseif fn=="tableCellSizeForIndex" then
        -- local tmpSize = CCSizeMake(G_VisibleSizeWidth-50,200)
        local tmpSize = CCSizeMake(G_VisibleSizeWidth-50,160)
        if acWsjdzzIIVoApi:getVersion() == 3 then
            tmpSize = CCSizeMake(G_VisibleSizeWidth-20,160)
        end
        return tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local taskList=acWsjdzzIIVoApi:getTaskList()
        local taskData=taskList[idx+1]
        local id=taskData.id
        local reward=taskData.reward
        local taskType=taskData.taskType
        local num=taskData.num
        local maxNum=taskData.maxNum
        local isReward=taskData.isReward
        local status=taskData.status

        local cellWidth=G_VisibleSizeWidth-50
        if acWsjdzzIIVoApi:getVersion() == 3 then
            cellWidth=G_VisibleSizeWidth - 20
        end
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

        if acWsjdzzIIVoApi:getVersion() == 3 then
            backSprie:setOpacity(0)
            bgSp:setOpacity(0)
            local titleSpire = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,0,1,32),cellClick)
            titleSpire:setContentSize(CCSizeMake(backSprie:getContentSize().width-100,32))
            titleSpire:setAnchorPoint(ccp(0,0.5))
            backSprie:addChild(titleSpire)
            titleSpire:setPosition(ccp(20,backSprie:getContentSize().height-35))
        end


        local titleStr=""
        
        if taskType=="hit" and maxNum==10 then
            if acWsjdzzIIVoApi:getVersion() == 2 or acWsjdzzIIVoApi:getVersion() == 4 then
                titleStr=getlocal("activity_wanshengjiedazuozhan_task_hit2_n",{maxNum})
            elseif acWsjdzzIIVoApi:getVersion() == 1 then
                titleStr=getlocal("activity_wanshengjiedazuozhan_task_hit2",{maxNum})
            elseif acWsjdzzIIVoApi:getVersion() == 3 then
                titleStr=getlocal("activity_wanshengjiedazuozhan_task_hit2_p",{maxNum})
            end

        else
            if acWsjdzzIIVoApi:getVersion() == 2 or acWsjdzzIIVoApi:getVersion() == 4 then
                titleStr=getlocal("activity_wanshengjiedazuozhan_task_"..taskType.."_n",{maxNum})
            elseif acWsjdzzIIVoApi:getVersion() == 1 then
                titleStr=getlocal("activity_wanshengjiedazuozhan_task_"..taskType,{maxNum})
            elseif acWsjdzzIIVoApi:getVersion() == 3 then
                titleStr=getlocal("activity_wanshengjiedazuozhan_task_"..taskType.."_p",{maxNum})
            end

        end

        local strSize = 25
        if G_isAsia() == false then
            strSize = 20
        end

        local titleLb=GetTTFLabelWrap(titleStr,strSize,CCSize(580,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        titleLb:setAnchorPoint(ccp(0,0.5))
        if  acWsjdzzIIVoApi:getVersion() ~= 3 then
            titleLb:setColor(G_ColorYellowPro)   
        end
        titleLb:setPosition(ccp(25,backSprie:getContentSize().height-35))
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
                local scaleSize = 80
                local px,py=180+100*(k-1),posY
                local function showNewPropInfo()
                    G_showNewPropInfo(self.layerNum+1,true,true,nil,v)
                    return false
                end
                local icon,scale=G_getItemIcon(v,scaleSize,true,self.layerNum+1,showNewPropInfo,nil,nil,nil,nil,nil,true)
                icon:setTouchPriority(-(self.layerNum-1)*20-2)
                icon:setPosition(ccp(px,py))
                backSprie:addChild(icon,1)
                local numLb=GetTTFLabel("x"..FormatNumber(v.num),20)
                numLb:setAnchorPoint(ccp(1,0))
                numLb:setPosition(ccp(icon:getContentSize().width-5,5))
                icon:addChild(numLb,1)
                numLb:setScale(1/scale)
                if v.key =="p4707" then
                    icon:setScale(0.8)
                end
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
                                    acWsjdzzIIVoApi:updateData(sData.data[self.activeName])
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


                                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("receivereward_received_success"),28)

                                end
                                local recordPoint=self.tv:getRecordPoint()
                                self.tv:reloadData()
                                self.tv:recoverToRecordPoint(recordPoint)
                            end
                        end
                    end
                    local cmdStr="active.wsjdzz2017.task"
                    local tid=id
                    socketHelper:activityWsjdzz2017(cmdStr,nil,tid,nil,activeCallback)
                end
            end

            local rewardItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",rewardHandler,2,getlocal("daily_scene_get"),35)
            rewardItem:setScale(0.7)
            if acWsjdzzIIVoApi:getVersion() == 3 then
                rewardItem=GetButtonItem("yh_taskReward.png","yh_taskReward_down.png","yh_taskReward.png",rewardHandler,2)
            end
            local rewardMenu=CCMenu:createWithItem(rewardItem)
            rewardMenu:setPosition(ccp(backSprie:getContentSize().width-80,posY))
            rewardMenu:setTouchPriority(-(self.layerNum-1)*20-2)
            backSprie:addChild(rewardMenu,1)

            lbPosY=backSprie:getContentSize().height-60

        elseif status==2 then
            if num>maxNum then
                num=maxNum
            end
            statusStr=getlocal("scheduleChapter",{num,maxNum})
            if taskType=="hit" then
                statusStr=getlocal("scheduleChapter",{0,1})
            end
            if acWsjdzzIIVoApi:getVersion() == 3 then
                local function jumpHandler( ... )
                    if self.parent then
                        self.parent:tabClick(0)
                    end
                end
                local jumpItem =GetButtonItem("yh_nbSkillGoto.png","yh_nbSkillGoto_Down.png","yh_nbSkillGoto.png",jumpHandler)
                local jumpMenu=CCMenu:createWithItem(jumpItem)
                jumpMenu:setPosition(ccp(backSprie:getContentSize().width-80,posY))
                jumpMenu:setTouchPriority(-(self.layerNum-1)*20-2)
                backSprie:addChild(jumpMenu,1)
            end
        elseif status==3 then
            statusStr=""
            if acWsjdzzIIVoApi:getVersion() == 3 then
                if num>maxNum then
                    statusStr=getlocal("scheduleChapter",{maxNum,maxNum})
                else
                    statusStr=getlocal("scheduleChapter",{num,maxNum})
                end
            end
            color=G_ColorGreen
        end
        local strSubPosWidth = 80
        if G_isAsia() then
                strSubPosWidth =80
        end
        if acWsjdzzIIVoApi:getVersion() ~= 3 then
            local statusLb=GetTTFLabel(statusStr,25)
            statusLb:setPosition(ccp(backSprie:getContentSize().width-strSubPosWidth,lbPosY))
            backSprie:addChild(statusLb,1)
            statusLb:setColor(color)
        else
            local statusLb = GetTTFLabel("("..statusStr..")",25)
            statusLb:setAnchorPoint(ccp(0,0.5))
            statusLb:setPosition(ccp(titleLb:getPositionX()+titleLb:getContentSize().width+5,titleLb:getPositionY()))
            statusLb:setColor(color)
            backSprie:addChild(statusLb)
        end

        if status==3 then
            -- local p1Sp=CCSprite:createWithSpriteFrameName("IconCheck.png")
            -- backSprie:addChild(p1Sp,2)
            -- p1Sp:setPosition(ccp(backSprie:getContentSize().width-strSubPosWidth,lbPosY))
            if acWsjdzzIIVoApi:getVersion() == 3 then
                local getSpirte = CCSprite:createWithSpriteFrameName("IconCheck.png")
                getSpirte:setAnchorPoint(ccp(0.5,0.5))
                getSpirte:setPosition(ccp(backSprie:getContentSize().width-strSubPosWidth,posY))
                backSprie:addChild(getSpirte)
            else
                local desLb=GetTTFLabelWrap(getlocal("activity_hadReward"),strSize,CCSizeMake(140,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                desLb:setPosition(ccp(backSprie:getContentSize().width-strSubPosWidth,posY))
                backSprie:addChild(desLb)
                desLb:setColor(G_ColorGray)
            end
        end
        if acWsjdzzIIVoApi:getVersion() == 3 then
            local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function ()end)
            lineSp:setAnchorPoint(ccp(0.5,0))
            lineSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,3))
            lineSp:setPosition(ccp((G_VisibleSizeWidth-20)/2,2))
            cell:addChild(lineSp)
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

function acWsjdzzIITabTwo:refresh()
    if self and self.tv then
        local recordPoint=self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
end

function acWsjdzzIITabTwo:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.tv=nil
    self.layerNum=nil
end
