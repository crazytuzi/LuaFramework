
acHarvestDayDialog=commonDialog:new()

function acHarvestDayDialog:new()
    local nc=commonDialog:new()
    setmetatable(nc,self)
    self.__index=self

    self.timeLb=nil
    self.descBg=nil
    self.gotoBtn=nil
    self.cellHeight=150
    self.cellHeight1=nil
    -- self.isEnd=false

    return nc
end

--设置对话框里的tableView
function acHarvestDayDialog:initTableView()
    -- local needUpdate=acHarvestDayVoApi:getNeedUpdate()
    -- if needUpdate==true then
        local function harvestdayCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                if sData and sData.data and sData.data.harvestDay then
                    acHarvestDayVoApi:updateData(sData.data.harvestDay)
                    self:initLayer()
                end
            end
        end
        socketHelper:activeHarvestday(harvestdayCallback)
    -- else
    --     self:initLayer()
    -- end
end

function acHarvestDayDialog:initLayer()
    self.panelLineBg:setAnchorPoint(ccp(0.5,0))
    self.panelLineBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,self.bgLayer:getContentSize().height-100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2,15))

    local function touch()
    end
    local capInSet = CCRect(20, 20, 10, 10)
    local timeBg =LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",capInSet,touch)
    timeBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-30,70))
    timeBg:setAnchorPoint(ccp(0.5,1))
    timeBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-90))
    self.bgLayer:addChild(timeBg,1)

    -- local timeLb=GetTTFLabel(getlocal("activity_timeLabel"),25)
    -- timeLb:setAnchorPoint(ccp(0,0.5))
    -- timeLb:setPosition(ccp(10,timeBg:getContentSize().height/2))
    -- timeBg:addChild(timeLb,1)

    local vo=acHarvestDayVoApi:getAcVo()
    local timeStr
    -- if acHarvestDayVoApi:acIsStop()==true then
    --     timeStr=getlocal("activity_equipSearch_time_end")
    -- else
        timeStr=getlocal("activity_timeLabel")..":"..acHarvestDayVoApi:getTimeStr()
        -- timeStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    -- end
    self.timeLb=GetTTFLabelWrap(timeStr,25,CCSizeMake(timeBg:getContentSize().width-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    self.timeLb:setAnchorPoint(ccp(0,0.5))
    self.timeLb:setPosition(ccp(10,timeBg:getContentSize().height/2))
    timeBg:addChild(self.timeLb,1)
    G_updateActiveTime(vo,self.timeLb,nil,true)


    self.descBg =LuaCCScale9Sprite:createWithSpriteFrameName("RankItemBg.png",CCRect(40, 40, 10, 10),touch)
    self.descBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-30,270+40))
    self.descBg:setAnchorPoint(ccp(0.5,1))
    self.descBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-timeBg:getContentSize().height-96))
    self.bgLayer:addChild(self.descBg,1)

    -- local contentLb=GetTTFLabel(getlocal("activity_contentLabel")..":",25)
    -- contentLb:setAnchorPoint(ccp(0,1))
    -- contentLb:setPosition(ccp(10,self.descBg:getContentSize().height-10))
    -- self.descBg:addChild(contentLb,1)

    -- local descLb=GetTTFLabelWrap(getlocal("activity_harvestDay_desc"),25,CCSizeMake(self.descBg:getContentSize().width-70,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    -- descLb:setAnchorPoint(ccp(0,1))
    -- descLb:setPosition(ccp(50,self.descBg:getContentSize().height-contentLb:getContentSize().height-20))
    -- self.descBg:addChild(descLb,1)

    

    
    local function gotoAllianceWar()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        local selfAlliance=allianceVoApi:getSelfAlliance()
        if (selfAlliance==nil or selfAlliance.aid<=0) then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allianceWar_errorNeedAlliance"),30)
        else
            activityAndNoteDialog:closeAllDialog()
            if(base.allianceWar2Switch==1)then
                local function openDialog()
                    require "luascript/script/game/scene/gamedialog/arenaDialog/arenaTotalDialog"
                    local td=arenaTotalDialog:new()
                    local tbArr={}
                    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("arena_total"),true,self.layerNum)
                    sceneGame:addChild(dialog,self.layerNum)
                end
                local delay=CCDelayTime:create(0.4)
                local callFunc=CCCallFunc:create(openDialog)
                local acArr=CCArray:create()
                acArr:addObject(delay)
                acArr:addObject(callFunc)
                local seq=CCSequence:create(acArr)
                sceneGame:runAction(seq)
            else
                local td=allianceWarOverviewDialog:new(self.layerNum)
                local tbArr={}
                local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("alliance_war"),false,self.layerNum)
                sceneGame:addChild(dialog,self.layerNum)
            end
        end
    end
    self.gotoBtn=GetButtonItem("BigBtnGreen.png","BigBtnGreen_Down.png","BigBtnGreen_Down.png",gotoAllianceWar,11,getlocal("activity_harvestDay_goto_allianceWar"),25)
    self.gotoBtn:setAnchorPoint(ccp(0.5,0.5))
    local gotoMenu=CCMenu:createWithItem(self.gotoBtn)
    gotoMenu:setPosition(ccp(self.descBg:getContentSize().width-self.gotoBtn:getContentSize().width/2-10,self.gotoBtn:getContentSize().height/2+15))
    gotoMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.descBg:addChild(gotoMenu,1)
    --self.gotoBtn:setVisible(false)

    local function callBack1(...)
       return self:eventHandler1(...)
    end
    local hd1= LuaEventHandler:createHandler(callBack1)
    self.tv1=LuaCCTableView:createWithEventHandler(hd1,CCSizeMake(self.bgLayer:getContentSize().width-30,200),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv1:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.tv1:setPosition(ccp(0,self.gotoBtn:getContentSize().height+25))
    self.descBg:addChild(self.tv1,1)
    self.tv1:setMaxDisToBottomOrTop(50)


    -- self.tvBg =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,touch)
    -- self.tvBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-30,self.bgLayer:getContentSize().height-timeBg:getContentSize().height-self.descBg:getContentSize().height-120))
    -- self.tvBg:setAnchorPoint(ccp(0.5,0))
    -- self.tvBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,25))
    -- self.bgLayer:addChild(self.tvBg,1)

    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-30,self.bgLayer:getContentSize().height-timeBg:getContentSize().height-self.descBg:getContentSize().height-125),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(15,25))
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)

    -- local function tipTouch()
    --     local sd=smallDialog:new()
    --     local labelTab={" ",getlocal("activity_monsterComeback_tip8"),getlocal("activity_monsterComeback_tip7"),getlocal("activity_monsterComeback_tip6")," ",getlocal("activity_monsterComeback_tip5"),getlocal("activity_monsterComeback_tip4"),getlocal("activity_monsterComeback_tip3")," ",getlocal("activity_monsterComeback_tip2"),getlocal("activity_monsterComeback_tip1")," "}
    --     local colorTab={nil,G_ColorYellow,G_ColorWhite,G_ColorYellowPro,nil,G_ColorYellow,G_ColorWhite,G_ColorYellowPro,nil,G_ColorRed,G_ColorWhite,nil,}
    --     local dialogLayer=sd:init("TankInforPanel.png",CCSizeMake(600,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,labelTab,25,colorTab,nil,true)
    --     sceneGame:addChild(dialogLayer,self.layerNum+1)
    --     dialogLayer:setPosition(ccp(0,0))
    -- end
    -- local tipItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",tipTouch,11,nil,nil)
    -- tipItem:setScale(1)
    -- local tipMenu = CCMenu:createWithItem(tipItem)
    -- --tipMenu:setPosition(ccp(self.bgLayer:getContentSize().width-30,self.bgLayer:getContentSize().height-110))
    -- tipMenu:setPosition(ccp(50,self.bgLayer:getContentSize().height-130))
    -- tipMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    -- self.bgLayer:addChild(tipMenu,1)

    -- self:doUserHandler()
end

function acHarvestDayDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 3
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-30,self.cellHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local acVo=acHarvestDayVoApi:getAcVo()
        local rewardRank=acVo.bidRank or 0
        local rewardNumTab=acVo.maxRewardTab
        local maxNum=rewardNumTab[idx+1]

        local acVo=acHarvestDayVoApi:getAcVo()
        -- local rank=tonumber(acVo.rank) or 0
        local hadRewardNum=acHarvestDayVoApi:getHadRewardNum(idx+1)
        local canReward=acHarvestDayVoApi:getCanReward(idx+1)
        local leftNum=acHarvestDayVoApi:getLeftNum(idx+1)

        local bgHeight=self.cellHeight-10

        local function touch()
        end
        local capInSet = CCRect(20, 20, 10, 10)
        local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,touch)
        backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-30,bgHeight))
        backSprie:setAnchorPoint(ccp(0,0))
        backSprie:setPosition(ccp(0,5))
        cell:addChild(backSprie)

        -- local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
        -- lineSp:setAnchorPoint(ccp(0.5,0.5))
        -- lineSp:setScale(0.7)
        -- lineSp:setPosition(ccp(180,bgHeight/2-5))
        -- backSprie:addChild(lineSp,1)

        local descStr=""
        local color=G_ColorWhite
        if idx==0 then
            descStr=getlocal("activity_harvestDay_desc_1",{rewardRank})
        else
            descStr=getlocal("activity_harvestDay_desc_"..(idx+1))
            if idx==2 then
                color=G_ColorYellowPro
            end
        end
        -- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
        -- descStr=str
        local descLabel=GetTTFLabelWrap(descStr,25,CCSizeMake(backSprie:getContentSize().width/4+20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        descLabel:setAnchorPoint(ccp(0,0.5))
        descLabel:setPosition(ccp(20,bgHeight/2))
        backSprie:addChild(descLabel,1)
        descLabel:setColor(color)

        if idx==0 then
            -- if rank and rank>0 and rank<=10 then
            --     -- str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
            --     -- local rankLabel=GetTTFLabelWrap(str,25,CCSizeMake(140,0),kCCVerticalTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            --     local rankLabel=GetTTFLabelWrap(getlocal("rankOne",{acVo.rank}),25,CCSizeMake(150,0),kCCVerticalTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            --     rankLabel:setAnchorPoint(ccp(0.5,0.5))
            --     rankLabel:setPosition(ccp(260,bgHeight/2))
            --     backSprie:addChild(rankLabel,1)
            --     rankLabel:setColor(G_ColorGreen)
            -- end
        elseif idx==1 then
            local tankSp=CCSprite:createWithSpriteFrameName("t20_1.png")
            tankSp:setAnchorPoint(ccp(0.5,0.5))
            local tScale=0.65
            tankSp:setScale(tScale)
            tankSp:setPosition(ccp(260,bgHeight/2))
            backSprie:addChild(tankSp,1)
        elseif idx==2 then
            local victorySp = CCSprite:createWithSpriteFrameName("SuccessHeader.png")
            victorySp:setAnchorPoint(ccp(0.5,0.5))
            local vicScale=0.3
            victorySp:setScale(vicScale)
            victorySp:setPosition(260,bgHeight/2)
            backSprie:addChild(victorySp,1)
        end

        -- str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
        -- local rewardNumLabel=GetTTFLabelWrap(str,22,CCSizeMake(backSprie:getContentSize().width/3+20,0),kCCVerticalTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        local rewardNumLabel=GetTTFLabelWrap(getlocal("activity_harvestDay_reward_num",{leftNum}),22,CCSizeMake(backSprie:getContentSize().width/3,0),kCCVerticalTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        rewardNumLabel:setAnchorPoint(ccp(0.5,0.5))
        rewardNumLabel:setPosition(ccp(backSprie:getContentSize().width-120,bgHeight/2+35))
        backSprie:addChild(rewardNumLabel,1)
        rewardNumLabel:setColor(G_ColorGreen)

        local posY=bgHeight/2-25
        if leftNum<=0 then
            rewardNumLabel:setVisible(false)
            posY=bgHeight/2
        end
        local function tipTouch()
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                local param={}
                if idx==0 then
                    param={rewardRank}
                end
                local strTab={" ",getlocal("activity_harvestDay_tip_"..idx+1,param)," "}
                local colorTab={}
                local sd=smallDialog:new()
                local dialogLayer=sd:init("TankInforPanel.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,strTab,25,colorTab)
                sceneGame:addChild(dialogLayer,self.layerNum+1)
                dialogLayer:setPosition(ccp(0,0))
            end
        end
        local tipItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",tipTouch,idx+1,nil,nil)
        local spScale=0.75
        tipItem:setScale(spScale)
        local tipMenu = CCMenu:createWithItem(tipItem)
        -- tipMenu:setPosition(ccp(backSprie:getContentSize().width-210,tipItem:getContentSize().height/2*spScale+20))
        tipMenu:setPosition(ccp(backSprie:getContentSize().width-180,posY))
        tipMenu:setTouchPriority(-(self.layerNum-1)*20-2)
        backSprie:addChild(tipMenu,1)

        local function rewardHandler(tag,object)
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)

                local canReward1=acHarvestDayVoApi:getCanReward(tag)
                if canReward1==true then
                    local function rewardCallback(fn,data)
                        local ret,sData=base:checkServerData(data)
                        if ret==true then
                            -- if tag==1 then
                                if sData and sData.data and sData.data.allince and sData.data.allince.point then
                                    if sData.data.allince.addpoint then
                                        local addpoint=tonumber(sData.data.allince.addpoint)
                                        if addpoint then
                                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_harvestDay_reward_point",{addpoint}),30)
                                        end
                                    end
                                    local point=tonumber(sData.data.allince.point)
                                    if point then
                                        -- local selfAlliance=allianceVoApi:getSelfAlliance()
                                        -- if selfAlliance and selfAlliance.point then
                                        --     smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_harvestDay_reward_point",{point-selfAlliance.point}),30)
                                        -- end

                                        
                                        

                                        local aid=playerVoApi:getPlayerAid()
                                        local params={}
                                        local uid=playerVoApi:getUid()
                                        params[1]=uid
                                        params[8]=point
                                        chatVoApi:sendUpdateMessage(9,params,aid+1)
                                    end
                                end
                            -- elseif tag==2 then
                                if sData and sData.data and sData.data.reward then
                                    local award=FormatItem(sData.data.reward) or {}
                                    for k,v in pairs(award) do
                                        G_addPlayerAward(v.type,v.key,v.id,v.num)
                                    end
                                    G_showRewardTip(award)
                                end
                            -- elseif tag==3 then
                                if sData and sData.data and sData.data.accessory then
                                    -- local accessory=sData.data.accessory
                                    -- accessoryVoApi:addNewData(accessory)
                                    accessoryVoApi.dataNeedRefresh=true
                                end
                            -- end

                            acHarvestDayVoApi:setRewardNum(tag)
                            if self.tv then
                                self.tv:reloadData()
                            end
                        end
                    end
                    local rank,join,win=nil,nil,nil
                    if tag==1 then
                        rank=1
                    elseif tag==2 then
                        join=1
                    elseif tag==3 then
                        win=1
                    end
                    socketHelper:activeHarvestdayReward(rank,join,win,rewardCallback)
                end
                
            end
        end
        local rewardBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",rewardHandler,idx+1,getlocal("daily_scene_get"),25)
        rewardBtn:setAnchorPoint(ccp(0.5,0.5))
        local btnScale=0.8
        rewardBtn:setScale(btnScale)
        local rewardMenu=CCMenu:createWithItem(rewardBtn)
        -- rewardMenu:setPosition(ccp(backSprie:getContentSize().width-90,rewardBtn:getContentSize().height/2*btnScale+20))
        rewardMenu:setPosition(ccp(backSprie:getContentSize().width-75,posY))
        rewardMenu:setTouchPriority(-(self.layerNum-1)*20-2)
        backSprie:addChild(rewardMenu,1)
        if canReward==true then
            rewardBtn:setEnabled(true)
        else
            rewardBtn:setEnabled(false)
        end

        local numLabel=GetTTFLabel(getlocal("scheduleChapter",{hadRewardNum,maxNum}),25)
        numLabel:setAnchorPoint(ccp(0.5,0.5))
        -- numLabel:setPosition(ccp(backSprie:getContentSize().width-90,bgHeight-15))
        numLabel:setPosition(ccp(backSprie:getContentSize().width/2+65,posY))
        backSprie:addChild(numLabel,1)

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

function acHarvestDayDialog:eventHandler1(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        if self.cellHeight1==nil then
            local contentLb=GetTTFLabel(getlocal("activity_contentLabel")..":",25)
            local descLb=GetTTFLabelWrap(getlocal("activity_harvestDay_desc"),25,CCSizeMake(self.descBg:getContentSize().width-70,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            local desc1Lb=GetTTFLabelWrap(getlocal("activity_harvestDay_desc1"),25,CCSizeMake(self.descBg:getContentSize().width-70,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            self.cellHeight1=contentLb:getContentSize().height+descLb:getContentSize().height+desc1Lb:getContentSize().height+80
        end
        tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-30,self.cellHeight1)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local contentLb=GetTTFLabel(getlocal("activity_contentLabel")..":",25)
        local descLb=GetTTFLabelWrap(getlocal("activity_harvestDay_desc"),25,CCSizeMake(self.descBg:getContentSize().width-70,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        local desc1Lb=GetTTFLabelWrap(getlocal("activity_harvestDay_desc1"),25,CCSizeMake(self.descBg:getContentSize().width-70,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)

        if self.cellHeight1==nil then
            self.cellHeight1=contentLb:getContentSize().height+descLb:getContentSize().height+desc1Lb:getContentSize().height+80
        end 

        contentLb:setAnchorPoint(ccp(0,1))
        contentLb:setPosition(ccp(10,self.cellHeight1-5))
        cell:addChild(contentLb,1)

        descLb:setAnchorPoint(ccp(0,1))
        descLb:setPosition(ccp(50,self.cellHeight1-contentLb:getContentSize().height-15))
        cell:addChild(descLb,1)

        desc1Lb:setAnchorPoint(ccp(0,1))
        desc1Lb:setPosition(ccp(50,self.cellHeight1-contentLb:getContentSize().height-15-descLb:getContentSize().height))
        cell:addChild(desc1Lb,1)
        desc1Lb:setColor(G_ColorRed)

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

--用户处理特殊需求,没有可以不写此方法
function acHarvestDayDialog:doUserHandler()
    
end

function acHarvestDayDialog:tick()
    local vo=acHarvestDayVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then
        if self then
            self:close()
            do return end
        end
    end
    -- if self.isEnd==false and acHarvestDayVoApi:acIsStop()==true then
    --     if self.tv then
    --         self.tv:reloadData()
    --     end
    --     self.isEnd=true
    -- end
    if self.timeLb then
        G_updateActiveTime(vo,self.timeLb,nil,true)
    end
end

function acHarvestDayDialog:dispose()
    self.timeLb=nil
    self.descBg=nil
    self.gotoBtn=nil
    self.cellHeight=nil
    self.cellHeight1=nil
    -- self.isEnd=nil
end




