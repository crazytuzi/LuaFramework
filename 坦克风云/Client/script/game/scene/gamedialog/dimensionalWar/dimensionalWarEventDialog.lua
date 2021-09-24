dimensionalWarEventDialog=commonDialog:new()

function dimensionalWarEventDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.layerNum=layerNum
    self.cellHeght=230
    self.roundTab={}
    self.noRecordLb=nil
    self.canClick=false
    self.lastHeadNum=0
    self.headNum=0

    return nc
end

--设置对话框里的tableView
function dimensionalWarEventDialog:initTableView()
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-30))
    self.panelLineBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-30,G_VisibleSize.height-105))

    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-30,self.bgLayer:getContentSize().height-180),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(15,90))
    self.bgLayer:addChild(self.tv)
    -- self.tv:setVisible(false)
    self.tv:setMaxDisToBottomOrTop(120)

    self:doUserHandler()
end

function dimensionalWarEventDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local eventList=dimensionalWarVoApi:getEventList()
        local num=SizeOfTable(eventList)
        local hasMore=dimensionalWarVoApi:getHasMore()
        if hasMore==true then
            num=num+1
        end
        return num
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        local eventList=dimensionalWarVoApi:getEventList()
        local num=SizeOfTable(eventList)
        local hasMore=dimensionalWarVoApi:getHasMore()
        if hasMore==true and num==idx then
            tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-30,80)
        elseif eventList and eventList[idx+1] and eventList[idx+1].showRound==1 then
            tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-30,self.cellHeght+60)
        else
            tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-30,self.cellHeght)
        end
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local width=self.bgLayer:getContentSize().width-60
        local height=self.cellHeght
        local eventList=dimensionalWarVoApi:getEventList()
        local num=SizeOfTable(eventList)
        local hasMore=dimensionalWarVoApi:getHasMore()
        if hasMore==true and num==idx then
            local capInSet = CCRect(20, 20, 10, 10);
            local function cellClick(hd,fn,idx)
                return self:cellClick(idx)
            end
            local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("ItemBtnMore.png",capInSet,cellClick)
            backSprie:setContentSize(CCSizeMake(width, 80-2))
            backSprie:ignoreAnchorPointForPosition(false);
            backSprie:setAnchorPoint(ccp(0,0));
            backSprie:setTag(idx)
            backSprie:setIsSallow(false)
            backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
            backSprie:setPosition(ccp(15,0));
            cell:addChild(backSprie,1)
            
            local moreLabel=GetTTFLabel(getlocal("showMoreTen"),30)
            moreLabel:setPosition(getCenterPoint(backSprie))
            backSprie:addChild(moreLabel,2)
            do return cell end
        end
        
        if eventList==nil or eventList[idx+1]==nil then
            do return cell end
        end
        
        local eventData=eventList[idx+1]
        local aType=eventData.aType         --1行动，2事件
        local oldStatus=eventData.oldStatus --0幸存，1亡者，2死亡
        local status=eventData.status       --0幸存，1亡者，2死亡
        local type=eventData.type           --这次事件具体类型
        local subType=eventData.subType     --这次事件类型的小类型
        local param=eventData.param
        local isBattle=eventData.isBattle   --是否发生战斗，0没有，1有
        local action=eventData.action
        local point=eventData.point
        local round=eventData.round
        local isHigh=eventData.isHigh
        local gold=eventData.gold or 0
        -- print("type",type)
        if (type==11 or type==12) and param and param[1] then
            subType=(tonumber(param[1]) or tonumber(RemoveFirstChar(param[1])))
        end
        local descStr,titleStr=dimensionalWarVoApi:getEventDesc(eventData)
        
        if eventData and eventData.showRound==1 then
            self.headNum=self.headNum+1
            local titleBg=CCSprite:createWithSpriteFrameName("ladder_title_bg.png")
            -- titleBg:setAnchorPoint(ccp(0.5,0.5))
            titleBg:setPosition(ccp(width/2,self.cellHeght+60/2))
            cell:addChild(titleBg)
            local roundStr=getlocal("dimensionalWar_round",{round})
            local roundLb=GetTTFLabel(roundStr,25)
            roundLb:setPosition(ccp(width/2,self.cellHeght+60/2))
            roundLb:setPosition(getCenterPoint(titleBg))
            roundLb:setColor(G_ColorYellowPro)
            titleBg:addChild(roundLb,1)
        end

        -- local capInSet = CCRect(20, 20, 10, 10)
        -- local background=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,function ()end)
        -- local background=LuaCCScale9Sprite:createWithSpriteFrameName("serverWarLocal_bg4.png",CCRect(10,10,10,10),function()end)
        local background=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray2.png",CCRect(20, 20, 1, 1),function()end)
        background:setTouchPriority(-(self.layerNum-1)*20-2)
        background:setAnchorPoint(ccp(0,0))
        background:setContentSize(CCSizeMake(width,height-5))
        background:setPosition(ccp(15,5))
        cell:addChild(background)

        local bgHeight=60
        local bgSp
        if status==0 then
            bgSp=LuaCCScale9Sprite:createWithSpriteFrameName("textGreenBg.png",CCRect(10,10,10,10),function()end)
            -- bgSp=CCSprite:createWithSpriteFrameName("groupSelf.png")
            -- bgSp:setScaleX((width+200)/bgSp:getContentSize().width)
            -- bgSp:setScaleY(bgHeight/bgSp:getContentSize().height)
        elseif status==1 then
            bgSp=LuaCCScale9Sprite:createWithSpriteFrameName("textYellowBg.png",CCRect(10,10,10,10),function()end)
            -- bgSp=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),function () do return end end)
        else
            bgSp=LuaCCScale9Sprite:createWithSpriteFrameName("serverWarLocal_bg1.png",CCRect(10,10,10,10),function()end)
            -- bgSp=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),function () do return end end)
        end
        if bgSp then
            bgSp:setAnchorPoint(ccp(0.5,1))
            bgSp:setContentSize(CCSizeMake(width-10,bgHeight))
            bgSp:setPosition(ccp(width/2,height-10))
            background:addChild(bgSp,1)
        end

        -- local titleStr=getlocal("dimensionalWar_event_action"..aType)
        -- if isHigh==1 then
        --     titleStr=titleStr..getlocal("dimensionalWar_event_title"..type.."_1")
        -- else
        --     titleStr=titleStr..getlocal("dimensionalWar_event_title"..type)
        -- end
        local titleLb=GetTTFLabelWrap(titleStr,25,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        titleLb:setAnchorPoint(ccp(0,0.5))
        titleLb:setPosition(30,height-bgHeight/2-5)
        cell:addChild(titleLb,2)
        -- if aType==1 then
        --     titleLb:setColor(G_ColorGreen)
        -- else
        --     titleLb:setColor(G_ColorYellowPro)
        -- end
        
        local iconScale=1
        local statusSp=CCSprite:createWithSpriteFrameName("survive"..(status+1)..".png")
        if statusSp then
            statusSp:setAnchorPoint(ccp(0.5,0.5))
            statusSp:setPosition(width-35,height-bgHeight/2-5)
            cell:addChild(statusSp,2)
            statusSp:setScale(iconScale)
        end
        local statusStr=getlocal("dimensionalWar_status"..status)
        local statusLb=GetTTFLabel(statusStr,25)
        statusLb:setAnchorPoint(ccp(1,0.5))
        statusLb:setPosition(width-65,height-bgHeight/2-5)
        cell:addChild(statusLb,2)

        
        -- local descBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),function()end)
        -- local descBg=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray2.png",CCRect(20, 20, 1, 1),function()end)
        -- descBg:setTouchPriority(-(self.layerNum-1)*20-4)
        -- descBg:setAnchorPoint(ccp(0,0.5))
        -- descBg:setContentSize(CCSizeMake(400,130))
        -- descBg:setPosition(ccp(20,height/2))
        -- cell:addChild(descBg)

        -- local descStr=getlocal("dimensionalWar_event_desc"..type.."_"..subType,param)
        local descLb=GetTTFLabelWrap(descStr,22,CCSizeMake(width-40-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        descLb:setAnchorPoint(ccp(0,0.5))
        descLb:setPosition(ccp(30,height/2-5))
        cell:addChild(descLb,2)
        -- local desTv,desLabel=G_LabelTableView(CCSizeMake(descBg:getContentSize().width-20,descBg:getContentSize().height-10),descStr,20,kCCTextAlignmentLeft)
        -- desTv:setPosition(ccp(10,5))
        -- desTv:setAnchorPoint(ccp(0,0))
        -- desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
        -- desTv:setMaxDisToBottomOrTop(120)
        -- cell:addChild(desTv,5)


        local function operateHandler(tag,object) 
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            if tag==11 then
                local function sendReport(reportData,contentStr)
                    contentStr=getlocal("dimensionalWar_chat_head",{round,statusStr,titleStr})..contentStr
                    G_sendReportChat(self.layerNum,contentStr,reportData,12)
                end
                local reportData={}
                if isBattle==1 and eventData.id then
                    local function getReportCallback1(report)
                        if report then
                            reportData=report
                            local contentStr=descStr..getlocal("dimensionalWar_click_look")
                            sendReport(reportData,contentStr)
                        end
                    end
                    dimensionalWarVoApi:getEventReport(eventData.id,getReportCallback1)
                else
                    sendReport(reportData,descStr)
                end
            elseif tag==12 then
                if isBattle==1 and eventData.id then
                    local function getReportCallback(report)
                        -- print("SizeOfTable(report)",SizeOfTable(report))
                        if report and SizeOfTable(report)>0 then
                            -- local isAttacker=emailVoApi:isAttacker(report,self.chatSender)
                            -- local landform={0,0}
                            -- if report.aLandform then
                            --     landform[1]=report.aLandform
                            -- end
                            -- if report.dLandform then
                            --     landform[2]=report.dLandform
                            -- end
                            -- local data={data=report,isAttacker=isAttacker,isReport=true,landform=landform}
                            local data={data={report=report},isAttacker=true,isReport=true}
                            battleScene:initData(data,nil,self.layerNum+1)
                        else
                            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("fight_content_result_no_play"),true,self.layerNum+1)
                        end
                    end
                    dimensionalWarVoApi:getEventReport(eventData.id,getReportCallback)
                else
                    smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("fight_content_result_no_play"),true,self.layerNum+1)
                end
            end
        end
        local scale=0.6
        local sendBtn=GetButtonItem("letterBtnSend.png","letterBtnSend_Down.png","letterBtnSend_Down.png",operateHandler,11,nil,nil)
        sendBtn:setScaleX(scale)
        sendBtn:setScaleY(scale)
        local sendSpriteMenu=CCMenu:createWithItem(sendBtn)
        sendSpriteMenu:setAnchorPoint(ccp(0.5,0.5))
        sendSpriteMenu:setTouchPriority(-(self.layerNum-1)*20-2)
        sendSpriteMenu:setPosition(ccp(width-45,bgHeight/2+10))
        cell:addChild(sendSpriteMenu,1)

        if isBattle==1 then
            local replayBtn=GetButtonItem("letterBtnPlay.png","letterBtnPlay_Down.png","letterBtnPlay_Down.png",operateHandler,12,nil,nil)
            replayBtn:setScaleX(scale)
            replayBtn:setScaleY(scale)
            local replaySpriteMenu=CCMenu:createWithItem(replayBtn)
            replaySpriteMenu:setAnchorPoint(ccp(0.5,0.5))
            replaySpriteMenu:setTouchPriority(-(self.layerNum-1)*20-2)
            -- replaySpriteMenu:setPosition(ccp(width-150,bgHeight/2+10))
            replaySpriteMenu:setPosition(ccp(width-45,bgHeight+10+30))
            cell:addChild(replaySpriteMenu,1)
        end

        local actionLb
        -- if gold and tonumber(gold)>0 then
        -- -- if type==5 or isHigh==1 then
        -- --     local goldStr=""
        -- --     if gold and tonumber(gold)>0 then
        -- --         goldStr="-"..gold
        -- --     end
        --     local goldStr="-"..gold
        --     actionLb=GetTTFLabel(getlocal("dimensionalWar_cost_gold",{goldStr}),25)
        -- else
            local actionStr=""
            if action>0 then
                actionStr="-"..action
            else
                actionStr=action
            end
            actionLb=GetTTFLabel(getlocal("dimensionalWar_event_action_power",{actionStr}),25)
        -- end
        actionLb:setAnchorPoint(ccp(0,0.5))
        actionLb:setPosition(30,bgHeight/2+10)
        cell:addChild(actionLb,2)
        actionLb:setColor(G_ColorRed)
        local pointLb=GetTTFLabel(getlocal("serverwar_reward_desc2",{point}),25)
        pointLb:setAnchorPoint(ccp(0,0.5))
        pointLb:setPosition(width/2-90,bgHeight/2+10)
        cell:addChild(pointLb,2)
        pointLb:setColor(G_ColorGreen)
        if gold and tonumber(gold)>0 then
            local goldLb=GetTTFLabel(getlocal("dimensionalWar_cost_gold",{gold}),25)
            goldLb:setAnchorPoint(ccp(0,0.5))
            goldLb:setPosition(width/2+50,bgHeight/2+10)
            cell:addChild(goldLb,2)
            goldLb:setColor(G_ColorYellowPro)
            local goldSp=CCSprite:createWithSpriteFrameName("IconGold.png")
            goldSp:setPosition(ccp(width-120,bgHeight/2+10))
            cell:addChild(goldSp,2)
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

--用户处理特殊需求,没有可以不写此方法
function dimensionalWarEventDialog:doUserHandler()
    -- local capInSet = CCRect(20, 20, 10, 10)
    -- local lbBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,function ()end)
    local lbBg=LuaCCScale9Sprite:createWithSpriteFrameName("serverWarLocal_bg4.png",CCRect(10,10,10,10),function()end)
    lbBg:setTouchPriority(-(self.layerNum-1)*20-2)
    lbBg:setAnchorPoint(ccp(0,0))
    lbBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-30,65))
    lbBg:setPosition(ccp(15,20))
    self.bgLayer:addChild(lbBg,1)

    local maxStr=getlocal("dimensionalWar_report_desc")
    local maxLb=GetTTFLabelWrap(maxStr,22,CCSizeMake(lbBg:getContentSize().width-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    maxLb:setAnchorPoint(ccp(0,0.5))
    maxLb:setPosition(ccp(15,lbBg:getContentSize().height/2))
    lbBg:addChild(maxLb,2)
    maxLb:setColor(G_ColorYellowPro)

    self.noRecordLb=GetTTFLabelWrap(getlocal("plat_war_no_report"),30,CCSizeMake(self.bgLayer:getContentSize().width-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.noRecordLb:setAnchorPoint(ccp(0.5,0.5))
    self.noRecordLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2))
    self.bgLayer:addChild(self.noRecordLb,2)
    self.noRecordLb:setColor(G_ColorYellowPro)
    
    self:tick()
end

function dimensionalWarEventDialog:cellClick(idx)
    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        PlayEffect(audioCfg.mouseClick)
        local eventList=dimensionalWarVoApi:getEventList()
        local num=SizeOfTable(eventList)
        local hasMore=dimensionalWarVoApi:getHasMore()
        local nextHasMore=false
        if hasMore and tostring(idx)==tostring(num) then
            local function eventListCallback()
                self.canClick=true
                local eventList1=dimensionalWarVoApi:getEventList()
                local newNum=SizeOfTable(eventList1)
                local diffNum=newNum-num
                local nextHasMore=dimensionalWarVoApi:getHasMore()
                local recordPoint=self.tv:getRecordPoint()
                -- print("recordPoint.y~~~~~1",recordPoint.y)
                self.lastHeadNum=self.headNum
                self.headNum=0
                self.tv:reloadData()
                local headDiffNum=self.headNum-self.lastHeadNum
                -- print("headDiffNum",headDiffNum)
                recordPoint.y=-(diffNum)*self.cellHeght-headDiffNum*60+recordPoint.y
                if nextHasMore then
                else
                    recordPoint.y=recordPoint.y+80
                end
                -- print("recordPoint.y~~~~~2",recordPoint.y)
                self.tv:recoverToRecordPoint(recordPoint)
                self.canClick=false
            end
            if self.canClick==false then
                dimensionalWarVoApi:formatEventList(eventListCallback,false)
            end
        end
    end
end

function dimensionalWarEventDialog:tick()
    if self and self.noRecordLb then
        local eventList=dimensionalWarVoApi:getEventList()
        if eventList and SizeOfTable(eventList)>0 then
            self.noRecordLb:setVisible(false)
        else
            self.noRecordLb:setVisible(true)
        end
    end
end

function dimensionalWarEventDialog:dispose()
    self.lastHeadNum=0
    self.headNum=0
    self.canClick=false
    self.roundTab={}
    self.noRecordLb=nil
end




