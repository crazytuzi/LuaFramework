require "luascript/script/game/gamemodel/ltzdz/ltzdzReportVoApi"
ltzdzReportDialog=commonDialog:new()

function ltzdzReportDialog:new()
	local nc={
        reportList={{},{}},
        cellNumTb={0,0}
    }
	setmetatable(nc,self)
    self.__index=self

    return nc
end

function ltzdzReportDialog:resetTab()
    local capInSet=CCRect(20,20,10,10)
    local function forbidClick()
    end
    local topfbSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
    topfbSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,210))
    topfbSp:setAnchorPoint(ccp(0.5,1))
    topfbSp:setTouchPriority(-(self.layerNum-1)*20-3)
    topfbSp:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight)
    self.bgLayer:addChild(topfbSp,2)

    local bottomfbSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
    bottomfbSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,130))
    bottomfbSp:setAnchorPoint(ccp(0.5,0))
    bottomfbSp:setTouchPriority(-(self.layerNum-1)*20-3)
    bottomfbSp:setPosition(G_VisibleSizeWidth/2,0)
    self.bgLayer:addChild(bottomfbSp,2)
    self.bottomfbSp=bottomfbSp
    topfbSp:setVisible(false)
    bottomfbSp:setVisible(false)

    self.tvTb={}
    local index=0
    for k,v in pairs(self.allTabs) do
        local  tabBtnItem=v
        if index==0 then
            tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
        elseif index==1 then
            tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
        end
        if index==self.selectedTabIndex then
            tabBtnItem:setEnabled(false)
        end
        index=index+1
    end
    self:tabClick(0)
end

function ltzdzReportDialog:tabClick(idx)
    for k,v in pairs(self.allTabs) do
        if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
        else
            v:setEnabled(true)
        end
    end
    self:getDataByType(idx+1)
end

function ltzdzReportDialog:getDataByType(rtype)
    if(rtype==nil)then
        rtype=1
    end
    local function realSwitch(rtype)
        local tablayer=self["layerTab"..rtype]
        if tablayer==nil then
            if rtype==1 then
                tablayer=self:initAttackReportLayer()
            elseif rtype==2 then
                tablayer=self:initTransportReportLayer()
            end
            self.bgLayer:addChild(tablayer,2)
            self["layerTab"..rtype]=tablayer
        end
        self:switchTab(rtype)
    end
    local tablayer=self["layerTab"..rtype]
    local newFlag=ltzdzReportVoApi:hasNewReport(rtype)
    if newFlag>0 or tablayer==nil then
        ltzdzReportVoApi:setReportExpireTime(rtype,0)
        local function handler()
            realSwitch(rtype)
        end
        ltzdzReportVoApi:formatReportList(rtype,handler)
    else
        realSwitch(rtype)
    end
end

function ltzdzReportDialog:switchTab(idx)
    for i=1,2 do
        if i~=idx then
            local tablayer=self["layerTab"..i]
            if tablayer then
                tablayer:setPosition(9999,0)
                tablayer:setVisible(false)
            end
        else
            local tablayer=self["layerTab"..i]
            if tablayer then
                tablayer:setPosition(0,0)
                tablayer:setVisible(true)
            end
        end
        if self.bottomfbSp then
            if idx==1 then
                self.bottomfbSp:setPosition(G_VisibleSizeWidth/2,0)
            else
                self.bottomfbSp:setPosition(G_VisibleSizeWidth/2,-1000)
            end
        end
    end
    self:refreshNoReportLb(idx)
end

function ltzdzReportDialog:initTableView()
    self.panelLineBg:setVisible(false)
    G_addCommonGradient(self.bgLayer,G_VisibleSizeHeight-160)
    ltzdzVoApi:addOrRemoveOpenDialog(1,"ltzdzReportDialog",self)
    local noReportLb=GetTTFLabelWrap(getlocal("ltzdz_report_null"),25,CCSizeMake(G_VisibleSize.width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    noReportLb:setColor(G_ColorGray)
    noReportLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
    noReportLb:setVisible(false)
    self.bgLayer:addChild(noReportLb)
    self.noReportLb=noReportLb
end

--战斗报告
function ltzdzReportDialog:initAttackReportLayer()
    local rtype=1
    self.reportList[rtype]=ltzdzReportVoApi:getReportListByType(rtype)
    self.cellNumTb[rtype]=SizeOfTable(self.reportList[rtype])
    local cellWidth,cellHeight=616,100
    local viewHeight=G_VisibleSizeHeight-180

    local reportLayer=CCLayer:create()

    local noticeLb=GetTTFLabelWrap(getlocal("ltzdz_report_tip1"),22,CCSizeMake(cellWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    local noticeHeight=noticeLb:getContentSize().height
    noticeLb:setPosition(G_VisibleSizeWidth/2,viewHeight-noticeHeight/2)
    reportLayer:addChild(noticeLb)

    local tvHeight=viewHeight-noticeHeight-140
    local isMoved=false
    local guildItem=nil
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return self.cellNumTb[rtype]
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(cellWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            local itemHeight=90
            local reportList=self.reportList[rtype]
            local reportVo=reportList[idx+1]
            local attackerFlag=ltzdzReportVoApi:isAttacker(reportVo)

            local function cellClick(hd,fn,idx)
                local tv=tolua.cast(self.tvTb[rtype],"LuaCCTableView")
                if tv and tv:getScrollEnable()==true and tv:getIsScrolled()==false then
                    local reportVo=ltzdzReportVoApi:getReportById(reportVo.rtype,reportVo.rid)
                    local function showAttSimpleReportDialog()
                        self:refresh(rtype)
                        
                        require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzAttSimpleReportDialog"
                        local td=ltzdzAttSimpleReportDialog:new(reportVo)
                        local tbArr={}
                        local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0,0,400,350),CCRect(168,86,10,10),tbArr,nil,nil,getlocal("alliance_war_battle_stats"),true,self.layerNum+1)
                        sceneGame:addChild(dialog,self.layerNum+1)
                        print("self.layerNum+1---->",self.layerNum+1)
                    end
                    if reportVo.report then
                        showAttSimpleReportDialog()
                    else
                        ltzdzReportVoApi:readReport(reportVo.rid,reportVo.rtype,showAttSimpleReportDialog)    
                    end
                    if otherGuideMgr.isGuiding and otherGuideMgr.curStep==70 then
                        otherGuideMgr:toNextStep()
                    end
                end
            end

            local backSprite
            local readFlag=ltzdzReportVoApi:hasRead(reportVo)
            if readFlag==true then
                backSprite=LuaCCScale9Sprite:createWithSpriteFrameName("newReadBg.png",CCRect(5,5,1,1),cellClick)
            else
                backSprite=LuaCCScale9Sprite:createWithSpriteFrameName("newUnReadBg.png",CCRect(5,23,1,1),cellClick)
            end
            backSprite:setContentSize(CCSizeMake(cellWidth,itemHeight))
            backSprite:ignoreAnchorPointForPosition(false)
            backSprite:setTag(idx)
            backSprite:setIsSallow(false)
            backSprite:setTouchPriority(-(self.layerNum-1)*20-2)
            backSprite:setPosition(cellWidth/2,cellHeight*0.5)
            cell:addChild(backSprite)

            local timeLb=GetTTFLabel(G_getDataTimeStr(reportVo.time),20)
            timeLb:setAnchorPoint(ccp(0,0.5))
            timeLb:setPosition(10,itemHeight-timeLb:getContentSize().height/2-10)
            backSprite:addChild(timeLb)

            if reportVo.city and reportVo.city[2] then
                local cid=reportVo.city[2][1]
                cityNameStr=ltzdzCityVoApi:getCityName(cid)
                local nameLb=GetTTFLabel(cityNameStr,20)
                nameLb:setAnchorPoint(ccp(0,0.5))
                nameLb:setPosition(200,timeLb:getPositionY())
                nameLb:setColor(G_ColorYellowPro)
                backSprite:addChild(nameLb)
            end
            
            local winFlag,resultStr,resultColor=false,nil,G_ColorWhite --胜利失败的图片
            local roleStr,targetStr=""
            if attackerFlag==true then
                roleStr=getlocal("RankScene_attack")
                if reportVo.defender and reportVo.defender[2] then
                    targetStr=reportVo.defender[2] --敌方玩家名字
                else
                    local flag=ltzdzReportVoApi:isAttackCityOrNpc(reportVo)
                    if flag==1 then
                        if reportVo.city and reportVo.city[2] then
                            local cid=reportVo.city[2][1]
                            targetStr=ltzdzCityVoApi:getCityName(cid)
                            targetStr=getlocal("ltzdz_city_defense",{targetStr})
                        end
                    elseif flag==2 then
                        if reportVo.duid then
                            local npcUser=ltzdzFightApi:getUserInfo(reportVo.duid)
                            targetStr=npcUser.nickname
                        end
                    end
                end
                local isVictory=reportVo.isVictory
                if isVictory==1 then
                    winFlag=true
                    resultStr=getlocal("fight_content_result_win")
                    resultColor=G_ColorYellowPro
                else
                    winFlag=false
                    resultStr=getlocal("fight_content_result_defeat")
                end
            else
                if reportVo.attacker then
                    targetStr=reportVo.attacker[2] --敌方玩家名字
                end
                roleStr=getlocal("fight_content_defende_type")
                local isVictory=reportVo.isVictory
                if isVictory==1 then
                    winFlag=false
                    resultStr=getlocal("fight_content_result_defeat")
                else
                    winFlag=true
                    resultStr=getlocal("fight_content_result_win")
                    resultColor=G_ColorYellowPro
                end
            end
            local roleStrLb=GetTTFLabel(roleStr,18)
            roleStrLb:setAnchorPoint(ccp(0,0.5))
            roleStrLb:setPosition(10,10+roleStrLb:getContentSize().height/2)
            backSprite:addChild(roleStrLb)

            local targetStrLb=GetTTFLabelWrap(targetStr,18,CCSizeMake(cellWidth-300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            targetStrLb:setAnchorPoint(ccp(0,0.5))
            targetStrLb:setPosition(200,roleStrLb:getPositionY())
            backSprite:addChild(targetStrLb)


            if resultStr then
                local iconWidth=150
                local resultPic,iconPic
                local color=G_ColorGray
                if winFlag==true then
                    resultPic="successIcon.png"
                    color=G_ColorYellowPro
                else
                    resultPic="failIcon.png"
                end
                if resultPic then
                    local resultSp=CCSprite:createWithSpriteFrameName(resultPic)
                    resultSp:setPosition(cellWidth-iconWidth/2-10,itemHeight/2-10)
                    backSprite:addChild(resultSp)
                    local resultLb=GetTTFLabel(resultStr,18)
                    resultLb:setAnchorPoint(ccp(0.5,0))
                    resultLb:setPosition(resultSp:getPositionX(),itemHeight-30)
                    resultLb:setColor(resultColor)
                    backSprite:addChild(resultLb)
                end
            end

            if idx==0 then
                guildItem=cell
            end

            return cell
        elseif fn=="ccTouchBegan" then
            isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            isMoved=true
        elseif fn=="ccTouchEnded" then

        end
    end
    local hd=LuaEventHandler:createHandler(tvCallBack)
    local tv=LuaCCTableView:createWithEventHandler(hd,CCSize(cellWidth,tvHeight),nil)
    tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    tv:setPosition(ccp(12,130))
    reportLayer:addChild(tv)
    self.tvTb[rtype]=tv

     local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setAnchorPoint(ccp(0.5,0))
    -- lineSp:setScale(0.95)
    lineSp:setPosition(G_VisibleSizeWidth/2,120)
    reportLayer:addChild(lineSp)

    local unReadNum,readNum=ltzdzReportVoApi:getHasUnRead(rtype)
    local unReadLb=GetTTFLabelWrap(getlocal("ltzdz_unReadNum")..unReadNum,25,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    unReadLb:setAnchorPoint(ccp(0,0.5))
    unReadLb:setPosition(40,100)
    reportLayer:addChild(unReadLb)
    local readLb=GetTTFLabelWrap(getlocal("ltzdz_readNum")..readNum,25,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    readLb:setAnchorPoint(ccp(0,0.5))
    readLb:setPosition(40,60)
    reportLayer:addChild(readLb)
    self.unReadLb=unReadLb
    self.readLb=readLb

    local priority=-(self.layerNum-1)*20-3
    local function readAllCallBack() --全部读取
        local function refreshReportList()
            self:refresh(rtype)
        end
        ltzdzReportVoApi:readAllReport(rtype,refreshReportList)
    end
    G_createBotton(reportLayer,ccp(G_VisibleSizeWidth-150,80),{getlocal("email_readedAll"),25},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",readAllCallBack,0.8,priority)

    if guildItem and ltzdzVoApi:isQualifying()==true then
        local x,y,width,height=G_getSpriteWorldPosAndSize(guildItem,1)
        if otherGuideMgr:checkGuide(70)==false then
            local kuangHeight=120
            otherGuideCfg[70].clickRect=CCRectMake(320-kuangHeight*0.5,y-(kuangHeight-90)*0.5,kuangHeight,kuangHeight)
            otherGuideMgr:showGuide(70)
        end
    end


    return reportLayer
end

--运输报告
function ltzdzReportDialog:initTransportReportLayer()
    local rtype=2
    self.reportList[rtype]=ltzdzReportVoApi:getReportListByType(rtype)
    self.cellNumTb[rtype]=SizeOfTable(self.reportList[rtype])
    local cellWidth,cellHeight=616,100
    local viewHeight=G_VisibleSizeHeight-180

    local reportLayer=CCLayer:create()

    local noticeLb=GetTTFLabelWrap(getlocal("ltzdz_report_tip2"),22,CCSizeMake(cellWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    local noticeHeight=noticeLb:getContentSize().height
    noticeLb:setPosition(G_VisibleSizeWidth/2,viewHeight-noticeHeight/2)
    reportLayer:addChild(noticeLb)

    local tvHeight=viewHeight-noticeHeight-40
    local isMoved=false
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return self.cellNumTb[rtype]
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(cellWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            local itemHeight=94

            local function cellClick(hd,fn,idx)
            end

            local reportList=self.reportList[rtype]
            local reportVo=reportList[idx+1]
            local backSprite=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),cellClick)
            backSprite:setContentSize(CCSizeMake(cellWidth,itemHeight))
            backSprite:ignoreAnchorPointForPosition(false)
            backSprite:setTag(idx)
            backSprite:setIsSallow(false)
            backSprite:setTouchPriority(-(self.layerNum-1)*20-2)
            backSprite:setPosition(cellWidth/2,cellHeight*0.5)
            cell:addChild(backSprite)

            local timeLb=GetTTFLabel(G_getDataTimeStr(reportVo.time),20)
            timeLb:setAnchorPoint(ccp(0,0.5))
            timeLb:setPosition(10,itemHeight-timeLb:getContentSize().height/2-10)
            backSprite:addChild(timeLb)

            if reportVo.city and reportVo.city[1] and reportVo.city[2] then
                local scid=reportVo.city[1][1]
                local scNameStr=ltzdzCityVoApi:getCityName(scid) --起始城的名字
                local tcid=reportVo.city[2][1]
                local tcNameStr=ltzdzCityVoApi:getCityName(tcid) --目标城的名字
                local scNameLb=GetTTFLabel(scNameStr,20)
                scNameLb:setAnchorPoint(ccp(1,0.5))
                scNameLb:setPosition(cellWidth*0.5-50,timeLb:getPositionY())
                scNameLb:setColor(G_ColorYellowPro)
                backSprite:addChild(scNameLb)

                local tcNameLb=GetTTFLabel(tcNameStr,20)
                tcNameLb:setAnchorPoint(ccp(0,0.5))
                tcNameLb:setPosition(cellWidth*0.5+50,timeLb:getPositionY())
                tcNameLb:setColor(G_ColorYellowPro)
                backSprite:addChild(tcNameLb)

                local arrowSp=CCSprite:createWithSpriteFrameName("targetArrow.png")
                arrowSp:setPosition(cellWidth/2,timeLb:getPositionY())
                backSprite:addChild(arrowSp)
            end
            local resultStr=getlocal("ltzdz_transport_result"..reportVo.isVictory)
            local resultLb=GetTTFLabelWrap(resultStr,18,CCSizeMake(cellWidth/2,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
            resultLb:setAnchorPoint(ccp(1,0.5))
            resultLb:setPosition(cellWidth-20,resultLb:getContentSize().height/2+10)
            backSprite:addChild(resultLb)
            if reportVo.isVictory==1 then
                resultLb:setColor(G_ColorGreen)
            else
                resultLb:setColor(G_ColorRed)
            end

            local promptStr=getlocal("ltzdz_transport_reserve")
            local promptLb=GetTTFLabelWrap(promptStr,18,CCSizeMake(cellWidth/2-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            promptLb:setAnchorPoint(ccp(0,0.5))
            promptLb:setPosition(10,promptLb:getContentSize().height/2+10)
            backSprite:addChild(promptLb)
            local tempLb=GetTTFLabel(promptStr,18)
            local realW=tempLb:getContentSize().width
            if realW>promptLb:getContentSize().width then
                realW=promptLb:getContentSize().width
            end
            local capacity=FormatNumber(reportVo.reserve)
            local capacityLb=GetTTFLabel(capacity,18)
            capacityLb:setAnchorPoint(ccp(0,0.5))
            capacityLb:setPosition(promptLb:getPositionX()+realW,promptLb:getPositionY())
            backSprite:addChild(capacityLb)

            return cell
        elseif fn=="ccTouchBegan" then
            isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            isMoved=true
        elseif fn=="ccTouchEnded" then

        end
    end
    local hd=LuaEventHandler:createHandler(tvCallBack)
    local tv=LuaCCTableView:createWithEventHandler(hd,CCSize(cellWidth,tvHeight),nil)
    tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    tv:setPosition(ccp(12,30))
    reportLayer:addChild(tv)
    self.tvTb[rtype]=tv

    return reportLayer
end

function ltzdzReportDialog:refresh(rtype)
    local tv=self.tvTb[rtype]
    if tv then
        self.reportList[rtype]=ltzdzReportVoApi:getReportListByType(rtype)
        self.cellNumTb[rtype]=SizeOfTable(self.reportList[rtype])
        local recordPoint=tv:getRecordPoint()
        tv:reloadData()
        tv:recoverToRecordPoint(recordPoint)
    end
    if rtype==1 and self.unReadLb and self.readLb then
        local unReadNum,readNum=ltzdzReportVoApi:getHasUnRead(rtype)
        self.unReadLb:setString(getlocal("ltzdz_unReadNum")..unReadNum)
        self.readLb:setString(getlocal("ltzdz_readNum")..readNum)
    end
    self:refreshNoReportLb(rtype)
end

function ltzdzReportDialog:refreshNoReportLb(rtype)
    if self.noReportLb==nil then
        do return end
    end
    local reportList=ltzdzReportVoApi:getReportListByType(rtype)
    if SizeOfTable(reportList)>0 then
        self.noReportLb:setVisible(false)
    else
        self.noReportLb:setVisible(true)
    end
end

function ltzdzReportDialog:dispose()
	self.tvTb={}
    self.layerTab1=nil
    self.layerTab2=nil
    self.bottomfbSp=nil
    ltzdzVoApi:addOrRemoveOpenDialog(2,"ltzdzReportDialog",self)
end