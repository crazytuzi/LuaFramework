warRecordTab1Dialog={

}

function warRecordTab1Dialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    
    self.tv=nil;
    self.tv2=nil;

    self.bgLayer=nil;
    self.layerNum=nil;
    self.allTabs={};
    
    -- self.bgLayer1=nil;
    -- self.bgLayer2=nil;

    self.selectedTabIndex=0;
    self.parentDialog=nil;

    self.cellHeightTab={}
    -- self.cellHeightTab2={}

    self.canSand=true
    self.noRecordLb=nil

    return nc;

end

function warRecordTab1Dialog:init(layerNum,parentDialog)
    self.layerNum=layerNum
    self.parentDialog=parentDialog
    self.bgLayer=CCLayer:create()

    self:initTabLayer();

    return self.bgLayer
end

function warRecordTab1Dialog:initTabLayer()
    -- self:resetTab()

    local rect = CCRect(0, 0, 50, 50);
    local capInSet = CCRect(20, 20, 10, 10);
    local function click(hd,fn,idx)
    end
    self.tvBg =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,click)
    self.tvBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50,G_VisibleSize.height-345+15+30))
    self.tvBg:ignoreAnchorPointForPosition(false)
    self.tvBg:setAnchorPoint(ccp(0.5,0))
    --self.tvBg:setIsSallow(false)
    --self.tvBg:setTouchPriority(-(self.layerNum-1)*20-2)
    self.tvBg:setPosition(ccp(G_VisibleSizeWidth/2,100-70))
    self.bgLayer:addChild(self.tvBg)

    self.noRecordLb=GetTTFLabelWrap(getlocal("alliance_war_no_record"),30,CCSizeMake(self.tvBg:getContentSize().width-50,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.noRecordLb:setAnchorPoint(ccp(0.5,0.5))
    self.noRecordLb:setPosition(ccp(self.tvBg:getContentSize().width/2,self.tvBg:getContentSize().height/2+30))
    self.tvBg:addChild(self.noRecordLb)
    self.noRecordLb:setColor(G_ColorGray)
    self.noRecordLb:setVisible(false)

    local function getbattlelogCallback(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            if sData.data then
                if sData.data.unum then
                    allianceWarRecordVoApi:setPersonMaxNum(tonumber(sData.data.unum))
                end
                if sData.data.ulog then
                    allianceWarRecordVoApi:formatRecordData(sData.data.ulog)
                end
                if self then
                    -- print("self.parentDialog",self.parentDialog)
                    if self.parentDialog then
                        self.parentDialog:updateDestroyNum()
                    end
                    self:initTableView()
                    allianceWarRecordVoApi:setRFlag(1)
                end
            end
        end
    end

    local maxNum=allianceWarRecordVoApi:getPersonMaxNum()
    local personRecordTab=allianceWarRecordVoApi:getPersonRecordTab()
    local rFlag=allianceWarRecordVoApi:getRFlag()
    -- print("rFlag",rFlag)
    if rFlag==-1 or (maxNum and personRecordTab and maxNum>SizeOfTable(personRecordTab)) then
        local type=1
        local selfAlliance = allianceVoApi:getSelfAlliance()
        local aid=selfAlliance.aid
        local uid=playerVoApi:getUid()
        local minTs,maxTs=allianceWarRecordVoApi:getMinAndMaxTime(type)
        local warid=allianceWarVoApi.warid
        -- print("warid",warid)
        if warid and warid>0 then
            socketHelper:allianceGetbattlelog(warid,1,aid,uid,minTs,maxTs,getbattlelogCallback)
        end
    else
        if self then
            self:initTableView()
        end
    end

end

function warRecordTab1Dialog:initTableView()
    if self.tv then
        self.cellHeightTab={}
        self.tv:reloadData()
    else
        local function callBack(...)
           return self:eventHandler(...)
        end
        local hd= LuaEventHandler:createHandler(callBack)
        local height=0;
        self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-50,G_VisibleSize.height-345+5+30),nil)
        -- self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
        self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
        self.tv:setPosition(ccp(30,100-65))
        self.bgLayer:addChild(self.tv)
        self.tv:setMaxDisToBottomOrTop(120)
    end
    self:doUserHandler()
    allianceWarRecordVoApi:setHasNew(false)
end

function warRecordTab1Dialog:getCellHeight(index)
    local personRecordTab=allianceWarRecordVoApi:getPersonRecordTab()
    if personRecordTab==nil or SizeOfTable(personRecordTab)==0 then
        do return 0 end
    end
    if self.cellHeightTab[index]==nil then
        local record={}
        record=personRecordTab[index]
        local isAttacker=record.isAttacker
        local isWin=record.isWin

        -- local timeStr=G_getTimeStr(record.time-G_getWeeTs(record.time))
        --local time=G_getTimeStr(record.time-G_getWeeTs(record.time))
        --local weeTs=G_getWeeTs(record.time) or 0
        --local timeTab=os.date("*t",weeTs)
        --local timeStr=getlocal("activity_equipSearch_data",{timeTab.month,timeTab.day})..time
        local timeStr=G_getDataTimeStr(record.time)
        
        local attId=record.attId
        local defId=record.defId
        local attName=record.attName
        local defName=record.defName
        local placeIndex=record.placeIndex
        local areaName=allianceWarRecordVoApi:getAreaNameByIndex(placeIndex)
        local attAName=record.attAName
        local defAName=record.defAName
        local destroyNum=record.destroyNum
        local lostNum=record.lostNum
        local rewardNum=0
        local report=record.report
        local isBattle=record.isBattle

        local lbSize=22
        local lbWidth=self.bgLayer:getContentSize().width-70
        local lbHeight=20
        local lbSpace=5

        local descStr=""
        local color=G_ColorWhite
        local params={}
        if isBattle==true then
            if isAttacker then
                if isWin then
                    params={timeStr,attAName,attName,areaName,defAName,defName,areaName}
                    descStr=getlocal("record_alliance_attack_success",params)
                    color=G_ColorGreen
                else
                    params={timeStr,attAName,attName,areaName,defAName,defName,areaName}
                    descStr=getlocal("record_alliance_attack_fail",params)
                    color=G_ColorRed
                end
                rewardNum=record.attRaising
            else
                if isWin then
                    params={timeStr,defAName,defName,attAName,attName,areaName}
                    descStr=getlocal("record_alliance_defence_success",params)
                    color=G_ColorGreen
                else
                    params={timeStr,defAName,defName,attAName,attName,areaName}
                    descStr=getlocal("record_alliance_defence_fail",params)
                    color=G_ColorRed
                end
                rewardNum=record.defRaising
            end
        else
            if attId==1 then
                params={timeStr,defAName,defName,areaName}
                descStr=getlocal("record_alliance_retreat",params)
                color=G_ColorRed
                rewardNum=record.defRaising
            else
                params={timeStr,attAName,attName,areaName}
                descStr=getlocal("record_alliance_occupy",params)
                -- if isAttacker then
                    color=G_ColorGreen
                -- else
                --     color=G_ColorRed
                -- end
                rewardNum=record.attRaising
            end
        end
        local recordDescLb=GetTTFLabelWrap(descStr,lbSize,CCSizeMake(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)

        local destroyLb=GetTTFLabelWrap(getlocal("record_destroy_num",{destroyNum}),lbSize,CCSizeMake(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        local lostLb=GetTTFLabelWrap(getlocal("record_lost_num",{lostNum}),lbSize,CCSizeMake(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        local rewardLb=GetTTFLabelWrap(getlocal("record_reward_contribution_num",{rewardNum}),lbSize,CCSizeMake(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        local function operateHandler()
        end
        local scale=0.75
        local replayBtn=GetButtonItem("letterBtnPlay.png","letterBtnPlay_Down.png","letterBtnPlay_Down.png",operateHandler,nil,nil,nil)

        local cellHeight=lbHeight+recordDescLb:getContentSize().height+destroyLb:getContentSize().height+lostLb:getContentSize().height+rewardLb:getContentSize().height+lbSpace*3+lbHeight+replayBtn:getContentSize().height*scale+5

        self.cellHeightTab[index]=cellHeight
    end
    return self.cellHeightTab[index]
end

function warRecordTab1Dialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then   
        local personRecordTab=allianceWarRecordVoApi:getPersonRecordTab()

        local num=0
        if personRecordTab then
            local hasMore=allianceWarRecordVoApi:hasMore()
            if hasMore then
                num=SizeOfTable(personRecordTab)+1
            else
                num=SizeOfTable(personRecordTab)
            end
        end
        return num
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-50,100)
        local personRecordTab=allianceWarRecordVoApi:getPersonRecordTab()
        if personRecordTab then
        local hasMore=allianceWarRecordVoApi:hasMore()
            if hasMore and idx+1==SizeOfTable(personRecordTab)+1 then
                tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-50,100)
            else
                tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-50,self:getCellHeight(idx+1))
            end
        end
        return tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local index=idx+1

        local personRecordTab=allianceWarRecordVoApi:getPersonRecordTab()
        local record=personRecordTab[index]
 
        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick(hd,fn,idx)
            local function getbattlelogCallback(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    if sData.data then
                        if sData.data.unum then
                            allianceWarRecordVoApi:setPersonMaxNum(tonumber(sData.data.unum))
                        end
                        if sData.data.ulog then
                            allianceWarRecordVoApi:formatRecordData(sData.data.ulog)
                        end
                        if self then
                            if self.parentDialog then
                                self.parentDialog:updateDestroyNum()
                            end
                            self:refreshTableView()
                        end
                    end
                end
            end
            local type=1
            local selfAlliance = allianceVoApi:getSelfAlliance()
            local aid=selfAlliance.aid
            local uid=playerVoApi:getUid()
            local minTs,maxTs=allianceWarRecordVoApi:getMinAndMaxTime(type)
            local warid=allianceWarVoApi.warid
            if warid and warid>0 then
                socketHelper:allianceGetbattlelog(warid,1,aid,uid,minTs,maxTs,getbattlelogCallback)
            end
        end
        local hasMore=allianceWarRecordVoApi:hasMore()

        local backSprie
        if hasMore and index==SizeOfTable(personRecordTab)+1 then
            backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("ItemBtnMore.png",capInSet,cellClick)
            backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, 100-5))
            backSprie:ignoreAnchorPointForPosition(false)
            backSprie:setAnchorPoint(ccp(0,0))
            backSprie:setPosition(0,5)
            backSprie:setIsSallow(false)
            backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
            backSprie:setTag(index)
            cell:addChild(backSprie,1)
            
            local moreLabel=GetTTFLabel(getlocal("showMoreTen"),30)
            moreLabel:setPosition(getCenterPoint(backSprie))
            backSprie:addChild(moreLabel,2)
            do return cell end
        end


        local isAttacker=record.isAttacker
        local isWin=record.isWin

        -- local timeStr=G_getTimeStr(record.time-G_getWeeTs(record.time))
        local time=G_getTimeStr(record.time-G_getWeeTs(record.time))
        local weeTs=G_getWeeTs(record.time) or 0
        local timeTab=os.date("*t",weeTs)
        local timeStr=getlocal("activity_equipSearch_data",{timeTab.month,timeTab.day})..time
        
        local attId=record.attId
        local defId=record.defId
        local attName=record.attName
        local defName=record.defName
        local areaIndex=record.placeIndex
        local areaName=allianceWarRecordVoApi:getAreaNameByIndex(areaIndex)
        local attAName=record.attAName
        local defAName=record.defAName
        local destroyNum=record.destroyNum
        local lostNum=record.lostNum
        local rewardNum=0
        local report=record.report
        local isBattle=record.isBattle

        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick(hd,fn,idx)
            --return self:cellClick(idx)
        end

        local cellHeight=self:getCellHeight(index)

        local backSprie
        backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
        backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, cellHeight-5))
        backSprie:ignoreAnchorPointForPosition(false)
        backSprie:setAnchorPoint(ccp(0,0))
        backSprie:setPosition(0,5)
        backSprie:setIsSallow(false)
        backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
        backSprie:setTag(index)
        cell:addChild(backSprie,1)

        local lbSize=22
        local lbWidth=self.bgLayer:getContentSize().width-70
        local lbX=5
        local lbHeight=20
        local lbSpace=5

        local descStr=""
        local color=G_ColorWhite
        local params={}
        if isBattle==true then
            if isAttacker then
                if isWin then
                    params={timeStr,attAName,attName,areaName,defAName,defName,areaName}
                    descStr=getlocal("record_alliance_attack_success",params)
                    color=G_ColorGreen
                else
                    params={timeStr,attAName,attName,areaName,defAName,defName,areaName}
                    descStr=getlocal("record_alliance_attack_fail",params)
                    color=G_ColorRed
                end
                rewardNum=record.attRaising
            else
                if isWin then
                    params={timeStr,defAName,defName,attAName,attName,areaName}
                    descStr=getlocal("record_alliance_defence_success",params)
                    color=G_ColorGreen
                else
                    params={timeStr,defAName,defName,attAName,attName,areaName}
                    descStr=getlocal("record_alliance_defence_fail",params)
                    color=G_ColorRed
                end
                rewardNum=record.defRaising
            end
        else
            if attId==1 then
                params={timeStr,defAName,defName,areaName}
                descStr=getlocal("record_alliance_retreat",params)
                color=G_ColorRed
                rewardNum=record.defRaising
            else
                params={timeStr,attAName,attName,areaName}
                descStr=getlocal("record_alliance_occupy",params)
                -- if isAttacker then
                    color=G_ColorGreen
                -- else
                --     color=G_ColorRed
                -- end
                rewardNum=record.attRaising
            end
        end
        -- end
        local recordDescLb=GetTTFLabelWrap(descStr,lbSize,CCSizeMake(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        recordDescLb:setAnchorPoint(ccp(0,1))
        recordDescLb:setPosition(ccp(lbX,cellHeight-lbHeight))
        backSprie:addChild(recordDescLb,1)
        recordDescLb:setColor(color)

        local destroyLb=GetTTFLabelWrap(getlocal("record_destroy_num",{destroyNum}),lbSize,CCSizeMake(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        destroyLb:setAnchorPoint(ccp(0,1))
        destroyLb:setPosition(ccp(lbX,cellHeight-recordDescLb:getContentSize().height-lbHeight-lbSpace*1))
        backSprie:addChild(destroyLb,1)

        local lostLb=GetTTFLabelWrap(getlocal("record_lost_num",{lostNum}),lbSize,CCSizeMake(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        lostLb:setAnchorPoint(ccp(0,1))
        lostLb:setPosition(ccp(lbX,cellHeight-recordDescLb:getContentSize().height-destroyLb:getContentSize().height-lbHeight-lbSpace*2))
        backSprie:addChild(lostLb,1)

        local rewardLb=GetTTFLabelWrap(getlocal("record_reward_contribution_num",{rewardNum}),lbSize,CCSizeMake(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        rewardLb:setAnchorPoint(ccp(0,1))
        rewardLb:setPosition(ccp(lbX,cellHeight-recordDescLb:getContentSize().height-destroyLb:getContentSize().height-lostLb:getContentSize().height-lbHeight-lbSpace*3))
        backSprie:addChild(rewardLb,1)

        local function operateHandler(tag,object)
            if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                if tag==11 then
                    if report==nil or (report and SizeOfTable(report)==0) then
                        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("fight_content_result_no_play"),true,self.layerNum+1)
                    else
                        local data={data={report=report},isAttacker=isAttacker,isReport=true}
                        data.isInAllianceWar=true
                        battleScene:initData(data)
                    end
                elseif tag==12 then
                    if report==nil or (report and SizeOfTable(report)==0) then
                        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("fight_content_result_no_play"),true,self.layerNum+1)
                    else
                        --检测是否被禁言
                        if chatVoApi:canChat(self.layerNum)==false then
                            do return end
                        end
                        
                        local playerLv=playerVoApi:getPlayerLevel()
                        local timeInterval=playerCfg.chatLimitCfg[playerLv] or 0
                        local diffTime=0
                        if base.lastSendTime then
                            diffTime=base.serverTime-base.lastSendTime
                        end
                        if diffTime>=timeInterval then
                            self.canSand=true
                        end
                        if self.canSand==nil or self.canSand==false then
                            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("time_limit_prompt",{timeInterval-diffTime}),true,self.layerNum+1)
                            do return end
                        end

                        local function sendReportHandle(tag,object)
                            self.canSand=false

                            base.lastSendTime=base.serverTime
                            local channelType=tag or 1
                            
                            local sender=playerVoApi:getUid()
                            local senderName=playerVoApi:getPlayerName()
                            local level=playerVoApi:getPlayerLevel()
                            local rank=playerVoApi:getRank()
                            local allianceName
                            local allianceRole
                            if allianceVoApi:isHasAlliance() then
                                local allianceVo=allianceVoApi:getSelfAlliance()
                                allianceName=allianceVo.name
                                allianceRole=allianceVo.role
                            end
                            local message=getlocal("record_chat_content",{descStr})
                            local params={subType=channelType,contentType=2,message=message,level=level,rank=rank,power=playerVoApi:getPlayerPower(),uid=playerVoApi:getUid(),name=playerVoApi:getPlayerName(),pic=playerVoApi:getPic(),report=report,ts=base.serverTime,allianceName=allianceName,allianceRole=allianceRole,vip=playerVoApi:getVipLevel(),isAllianceWar=true,isAttacker==isAttacker,wr=playerVoApi:getServerWarRank(),st=playerVoApi:getServerWarRankStartTime(),title=playerVoApi:getTitle()}
                            local aid=playerVoApi:getPlayerAid()
                            if channelType==1 then
                                chatVoApi:sendChatMessage(1,sender,senderName,0,"",params)
                                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("read_email_report_share_sucess"),28)
                            elseif aid then
                                chatVoApi:sendChatMessage(aid+1,sender,senderName,0,"",params)
                                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("read_email_report_share_sucess"),28)
                            end
                        end
                        allianceSmallDialog:selectChannelDialog("PanelHeaderPopup.png",CCSizeMake(450,350),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,self.layerNum+1,sendReportHandle)
                    end
                end
            end
        end
        local scale=0.75
        local replayBtn=GetButtonItem("letterBtnPlay.png","letterBtnPlay_Down.png","letterBtnPlay_Down.png",operateHandler,11,nil,nil)
        replayBtn:setScale(scale)
        local replaySpriteMenu=CCMenu:createWithItem(replayBtn)
        replaySpriteMenu:setAnchorPoint(ccp(0.5,0.5))
        replaySpriteMenu:setTouchPriority(-(self.layerNum-1)*20-2)

        local sendBtn=GetButtonItem("letterBtnSend.png","letterBtnSend_Down.png","letterBtnSend_Down.png",operateHandler,12,nil,nil)
        sendBtn:setScale(scale)
        local sendSpriteMenu=CCMenu:createWithItem(sendBtn)
        sendSpriteMenu:setAnchorPoint(ccp(0.5,0.5))
        sendSpriteMenu:setTouchPriority(-(self.layerNum-1)*20-2)

        cell:addChild(replaySpriteMenu,2)
        cell:addChild(sendSpriteMenu,2)
        replaySpriteMenu:setPosition(ccp(backSprie:getContentSize().width/4,replayBtn:getContentSize().height/2*scale+15))
        sendSpriteMenu:setPosition(ccp(backSprie:getContentSize().width/4*3,sendBtn:getContentSize().height/2*scale+15))

        if isBattle==false or report==nil or (report and SizeOfTable(report)==0) then
            replayBtn:setEnabled(false)
            sendBtn:setEnabled(false)
        end
        -- print("replayBtn:getContentSize().height*scale",replayBtn:getContentSize().height*scale)
       
        return cell;

    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
     
    elseif fn=="ccScrollEnable" then
        if newGuidMgr:isNewGuiding()==true then
            return 0
        else
            return 1
        end
    end

end

function warRecordTab1Dialog:refreshTableView()
    if self and self.tv then
        local recordPoint = self.tv:getRecordPoint()
        local oldHeight=0
        if self.cellHeightTab and SizeOfTable(self.cellHeightTab)>0 then
            for k,v in pairs(self.cellHeightTab) do
                oldHeight=oldHeight+v
            end
        end
        self.cellHeightTab={}
        self.tv:reloadData()
        local newHeight=0
        if self.cellHeightTab and SizeOfTable(self.cellHeightTab)>0 then
            for k,v in pairs(self.cellHeightTab) do
                newHeight=newHeight+v
            end
        end
        local diffHeight=newHeight-oldHeight
        local hasMore=allianceWarRecordVoApi:hasMore()
        if hasMore then
            self.tv:recoverToRecordPoint(ccp(recordPoint.x,recordPoint.y-diffHeight))
        else
            self.tv:recoverToRecordPoint(ccp(recordPoint.x,recordPoint.y-diffHeight+100))
        end
    end
end

function warRecordTab1Dialog:tick()
    if self then
        local rFlag=allianceWarRecordVoApi:getRFlag()
        if rFlag==0 then
            self:refreshTableView()
            self:doUserHandler()
            allianceWarRecordVoApi:setRFlag(1)
        end
    end
end


--用户处理特殊需求,没有可以不写此方法
function warRecordTab1Dialog:doUserHandler()
    if self and self.noRecordLb then
        local personRecordTab=allianceWarRecordVoApi:getPersonRecordTab()
        if personRecordTab and SizeOfTable(personRecordTab)>0 then
            self.noRecordLb:setVisible(false)
        else
            self.noRecordLb:setVisible(true)
        end
    end
end

--点击了cell或cell上某个按钮
function warRecordTab1Dialog:cellClick(idx)

end

function warRecordTab1Dialog:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    
    self.tv=nil
    -- self.tv2=nil
    self.layerNum=nil
    self.allTabs=nil
    self.cellHeightTab=nil
    self.canSand=nil
    self.noRecordLb=nil

    -- self.bgLayer1=nil
    -- self.bgLayer2=nil
    self.selectedTabIndex=nil
    self.bgLayer=nil

end
