platWarReportDialogTab3={}
function platWarReportDialogTab3:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.cellWidth=G_VisibleSizeWidth-60
    self.cellHeight=150
    self.reportType=1
    self.canClick=false
    self.mailClick=0
    self.noRecordLb=nil
    return nc
end

function platWarReportDialogTab3:init(layerNum,parent)
    self.layerNum=layerNum
    self.parent=parent
    self.bgLayer=CCLayer:create()
    self:initLayer()
    return self.bgLayer
end

function platWarReportDialogTab3:initLayer()
    local function callback(...)
        return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callback)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.cellWidth,G_VisibleSizeHeight-220),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(30,40)
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(80)

    self.noRecordLb=GetTTFLabelWrap(getlocal("plat_war_no_report"),30,CCSizeMake(self.bgLayer:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.noRecordLb:setAnchorPoint(ccp(0.5,0.5))
    self.noRecordLb:setPosition(getCenterPoint(self.bgLayer))
    self.bgLayer:addChild(self.noRecordLb,1)
    self.noRecordLb:setColor(G_ColorYellowPro)
    self.noRecordLb:setVisible(false)
    self:doUserHandler()

    return self.bgLayer
end

function platWarReportDialogTab3:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local hasMore=platWarVoApi:getReportHasMore(self.reportType)
        local num=platWarVoApi:getReportNum(self.reportType)
        if hasMore==true then
            num=num+1
        end
        return num
    elseif fn=="tableCellSizeForIndex" then
        return CCSizeMake(self.cellWidth,self.cellHeight)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local hasMore=platWarVoApi:getReportHasMore(self.reportType)
        local num=platWarVoApi:getReportNum(self.reportType)
        -- local reportList=platWarVoApi:getReportList(self.reportType)
        
        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick()
            if battleScene and battleScene.isBattleing==false then
                self:cellClick(idx)
            end
        end
        local background
        if hasMore and idx==num then
            background=LuaCCScale9Sprite:createWithSpriteFrameName("ItemBtnMore.png",capInSet,cellClick)
            background:setContentSize(CCSizeMake(self.cellWidth,self.cellHeight-5))
            background:ignoreAnchorPointForPosition(false)
            background:setAnchorPoint(ccp(0,0))
            background:setTag(idx)
            background:setIsSallow(false)
            background:setTouchPriority(-(self.layerNum-1)*20-2)
            background:setPosition(ccp(0,0))
            cell:addChild(background,1)
            
            local moreLabel=GetTTFLabel(getlocal("showMore"),30)
            moreLabel:setPosition(getCenterPoint(background))
            background:addChild(moreLabel,2)
            
            return cell
        end

        -- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
        background=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20,20,10,10),cellClick)
        background:setContentSize(CCSizeMake(self.cellWidth,self.cellHeight-5))
        background:setAnchorPoint(ccp(0,0))
        background:setPosition(ccp(0,0))
        background:setTag(idx)
        background:setIsSallow(false)
        cell:addChild(background)

        local function sendReport()
            if battleScene and battleScene.isBattleing==false then
                if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end

                    local rType=self.reportType
                    local reportList=platWarVoApi:getReportList(rType)
                    local reportVo=reportList[idx+1]
                    if reportVo and reportVo.id then
                        local id=reportVo.id
                        local function addCallback()
                            local reportList1=platWarVoApi:getReportList(rType)
                            local reportVo1=reportList[idx+1]
                            if reportVo1 and reportVo1.report then
                                local reportData=reportVo1.report
                                local sender=playerVoApi:getUid()
                                local chatContent=self:getDescStr(reportVo1)
                                if chatContent==nil then
                                    chatContent=""
                                end
                                local landform=platWarVoApi:getLandform(reportVo1.roadIndex)
                                local hasAlliance=allianceVoApi:isHasAlliance()
                                if hasAlliance==false then
                                    base.lastSendTime=base.serverTime

                                    local senderName=playerVoApi:getPlayerName()
                                    local level=playerVoApi:getPlayerLevel()
                                    local rank=playerVoApi:getRank()
                                    local language=G_getCurChoseLanguage()
                                    local params={subType=1,contentType=2,message=chatContent,level=level,rank=rank,power=playerVoApi:getPlayerPower(),uid=playerVoApi:getUid(),name=playerVoApi:getPlayerName(),pic=playerVoApi:getPic(),report=reportData,ts=base.serverTime,vip=playerVoApi:getVipLevel(),language=language,wr=playerVoApi:getServerWarRank(),st=playerVoApi:getServerWarRankStartTime(),title=playerVoApi:getTitle(),brType=10}
                                    if landform then
                                        params.landform=landform
                                    end
                                    --chatVoApi:addChat(1,sender,senderName,0,"",params)
                                    chatVoApi:sendChatMessage(1,sender,senderName,0,"",params)
                                    --mainUI:setLastChat()
                                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("read_email_report_share_sucess"),28)
                                else
                                    local function sendReportHandle(tag,object)
                                        base.lastSendTime=base.serverTime
                                        local channelType=tag or 1
                                        
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
                                        local language=G_getCurChoseLanguage()
                                        local params={subType=channelType,contentType=2,message=chatContent,level=level,rank=rank,power=playerVoApi:getPlayerPower(),uid=playerVoApi:getUid(),name=playerVoApi:getPlayerName(),pic=playerVoApi:getPic(),report=reportData,ts=base.serverTime,allianceName=allianceName,allianceRole=allianceRole,vip=playerVoApi:getVipLevel(),language=language,wr=playerVoApi:getServerWarRank(),st=playerVoApi:getServerWarRankStartTime(),title=playerVoApi:getTitle(),brType=10}
                                        if landform then
                                            params.landform=landform
                                        end
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
                        platWarVoApi:addReportBattle(rType,reportVo.id,addCallback,false)
                    end
                end
            end
        end
        local touchSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20,20,10,10),sendReport)
        touchSp:setContentSize(CCSizeMake(200,self.cellHeight-5))
        touchSp:setAnchorPoint(ccp(1,0))
        touchSp:setPosition(ccp(self.cellWidth,0))
        touchSp:setTag(idx)
        touchSp:setIsSallow(true)
        touchSp:setTouchPriority(-(self.layerNum-1)*20-2)
        cell:addChild(touchSp)
        touchSp:setOpacity(0)
        background:setTouchPriority(-(self.layerNum-1)*20-2)

        local reportList=platWarVoApi:getReportList(self.reportType)
        local vo=reportList[idx+1]
        local time=vo.time
        local roadIndex=vo.roadIndex
        local attServer=vo.attServer
        local defServer=vo.defServer
        local attName=vo.attName
        local defName=vo.defName
        -- local descStr,isVictory,targetStr=self:getDescStr(vo)
        local descStr,isVictory=self:getDescStr(vo)
        -- descStr=str
        local descLb=GetTTFLabelWrap(descStr,25,CCSizeMake(380,80),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        descLb:setAnchorPoint(ccp(0,0.5))
        descLb:setPosition(20,45)
        cell:addChild(descLb)
        
        -- local titleStr=getlocal("plat_war_against",{targetStr})
        local timeStr=G_getDataTimeStr(time)
        local landform=""
        if roadIndex and roadIndex>0 then
            landform=getlocal("plat_war_road_"..roadIndex)
        end
        local titleStr=timeStr.." "..landform
        -- titleStr=str
        local titleLb=GetTTFLabelWrap(titleStr,25,CCSizeMake(380,80),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        titleLb:setAnchorPoint(ccp(0,0.5))
        titleLb:setPosition(20,self.cellHeight-45)
        cell:addChild(titleLb)
        titleLb:setColor(G_ColorYellowPro)
        
        local resultSp
        local scale=0.3
        if isVictory==1 then
            resultSp=CCSprite:createWithSpriteFrameName("SuccessHeader.png")
        else
            resultSp=CCSprite:createWithSpriteFrameName("LoseHeader.png")
        end
        resultSp:setScale(scale)
        resultSp:setPosition(ccp(self.cellWidth-resultSp:getContentSize().width/2*scale-10,self.cellHeight/2+5))
        cell:addChild(resultSp,2)

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
    end
end

function platWarReportDialogTab3:getDescStr(vo)
    local descStr=""
    local isVictory=0
    local targetStr=""
    if vo then
        local attServer=vo.attServer
        local defServer=vo.defServer
        local attName=vo.attName
        local defName=vo.defName
        if vo.isAttacker==true then
            if vo.isVictory==1 then
                isVictory=1
                descStr=getlocal("plat_war_report_desc_1",{attName,defName})
            else
                isVictory=0
                descStr=getlocal("plat_war_report_desc_2",{attName,defName})
            end
            -- targetStr=GetServerNameByID(defServer).."-"..defName
        else
            if vo.isVictory==1 then
                isVictory=0
                descStr=getlocal("plat_war_report_desc_2",{defName,attName})
            else
                isVictory=1
                descStr=getlocal("plat_war_report_desc_1",{defName,attName})
            end
            -- targetStr=GetServerNameByID(attServer).."-"..attName
        end
    end
    return descStr,isVictory--,targetStr
end

--点击了cell或cell上某个按钮
function platWarReportDialogTab3:cellClick(idx)
    if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local type=self.reportType
        local num=platWarVoApi:getReportNum(type)
        local hasMore=platWarVoApi:getReportHasMore(type)
        local nextHasMore=false
        if hasMore and tostring(idx)==tostring(num) then
            local function reportListCallback(fn,data)
                -- if base:checkServerData(data)==true then
                    self.canClick=true
                    local newNum=platWarVoApi:getReportNum(type)
                    local diffNum=newNum-num
                    local nextHasMore=platWarVoApi:getReportHasMore(type)
                    if nextHasMore then
                        diffNum=diffNum+1
                    end
                    local recordPoint = self.tv:getRecordPoint()
                    self.tv:reloadData()
                    recordPoint.y=-(diffNum-1)*self.cellHeight+recordPoint.y
                    self.tv:recoverToRecordPoint(recordPoint)
                    self.canClick=false
                -- end
            end
            if self.canClick==false then
                platWarVoApi:formatReportList(type,reportListCallback,true)
            end
        else
            if self.mailClick==0 then
                self.mailClick=1
                local reportList=platWarVoApi:getReportList(type)
                local reportVo=reportList[idx+1]
                if reportVo and reportVo.id then
                    local id=reportVo.id
                    local function addCallback()
                    end
                    platWarVoApi:addReportBattle(type,reportVo.id,addCallback,true)
                end
            end
        end
    end
end

function platWarReportDialogTab3:doUserHandler()
    if self.noRecordLb then
        local num=platWarVoApi:getReportNum(self.reportType)
        if num==0 then
            self.noRecordLb:setVisible(true)
        else
            self.noRecordLb:setVisible(false)
        end
    end
end

function platWarReportDialogTab3:tick()
    if self and self.mailClick and self.mailClick>0 then
        self.mailClick=0
    end
end

function platWarReportDialogTab3:dispose()
    self.noRecordLb=nil
    self.mailClick=nil
    self.canClick=nil
    self.bgLayer:removeFromParentAndCleanup(true)
    self.layerNum=nil
    self.bgLayer=nil
end