serverWarLocalAgainstRankTab1 = {}

function serverWarLocalAgainstRankTab1:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.bgLayer=nil
    self.selectedTabIndex=0  --当前选中的tab
    self.oldSelectedTabIndex=0 --上一次选中的tab
    self.allTabs={}
    self.normalHeight=400
    self.registrationlist={}
    self.cellheight1=100
    self.across={}
	return nc
end

function serverWarLocalAgainstRankTab1:init(layerNum)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
    self.across=serverWarLocalVoApi:getAcross()
	self:initLayer()
	return self.bgLayer
end

function serverWarLocalAgainstRankTab1:initLayer()
    self.cellWidth=580
    self.noRankLb=GetTTFLabelWrap(getlocal("serverWarLocal_noData"),30,CCSizeMake(self.bgLayer:getContentSize().width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.noRankLb:setAnchorPoint(ccp(0.5,0.5))
    self.noRankLb:setColor(G_ColorYellowPro)
    self.noRankLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2))
    self.bgLayer:addChild(self.noRankLb)
    self.noRankLb:setVisible(false)

    local tabHeight = self.bgLayer:getContentSize().height-190
      --  普通坦克和精英坦克的页签
    local function touchItem(idx)
        self.oldSelectedTabIndex=self.selectedTabIndex
        self:tabClickColor(idx)
        return self:tabClick(idx)
    end
    local oneItem = CCMenuItemImage:create("yh_ltzdzHelp_tab.png", "yh_ltzdzHelp_tab_down.png","yh_ltzdzHelp_tab_down.png")
    oneItem:setTag(1)
    oneItem:registerScriptTapHandler(touchItem)
    oneItem:setEnabled(false)
    self.allTabs[1]=oneItem
    local oneMenu=CCMenu:createWithItem(oneItem)
    oneMenu:setPosition(ccp(30+oneItem:getContentSize().width/2,tabHeight))
    oneMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(oneMenu,2)

    local onelb=GetTTFLabelWrap(getlocal("serverWarLocal_first_Bureau"),22,CCSizeMake(oneItem:getContentSize().width-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    onelb:setPosition(CCPointMake(oneItem:getContentSize().width/2,oneItem:getContentSize().height/2))
    oneItem:addChild(onelb,1)


    local twoItem=CCMenuItemImage:create("yh_ltzdzHelp_tab.png", "yh_ltzdzHelp_tab_down.png","yh_ltzdzHelp_tab_down.png")
    twoItem:setTag(2)
    twoItem:registerScriptTapHandler(touchItem)
    self.allTabs[2]=twoItem
    local twoMenu=CCMenu:createWithItem(twoItem)
    twoMenu:setPosition(ccp(30+twoItem:getContentSize().width/2*3+4,tabHeight))
    twoMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(twoMenu,2)

    local twolb=GetTTFLabelWrap(getlocal("serverWarLocal_second_Bureau"),22,CCSizeMake(twoItem:getContentSize().width-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    twolb:setPosition(CCPointMake(twoItem:getContentSize().width/2,twoItem:getContentSize().height/2))
    twoItem:addChild(twolb,1)

    local threeItem=CCMenuItemImage:create("yh_ltzdzHelp_tab.png", "yh_ltzdzHelp_tab_down.png","yh_ltzdzHelp_tab_down.png")
    threeItem:setTag(3)
    threeItem:registerScriptTapHandler(touchItem)
    self.allTabs[3]=threeItem
    local threeMenu=CCMenu:createWithItem(threeItem)
    threeMenu:setPosition(ccp(30+threeItem:getContentSize().width/2*5+8,tabHeight))
    threeMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(threeMenu,2)

    local threelb=GetTTFLabelWrap(getlocal("serverWarLocal_registrationlist"),22,CCSizeMake(threeItem:getContentSize().width-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    threelb:setPosition(CCPointMake(threeItem:getContentSize().width/2,threeItem:getContentSize().height/2))
    threeItem:addChild(threelb,1)

    local tabLine=LuaCCScale9Sprite:createWithSpriteFrameName("yh_ltzdzHelp_tabLine.png",CCRect(4,3,1,1),function()end)
    tabLine:setContentSize(CCSizeMake(G_VisibleSizeWidth,tabLine:getContentSize().height))
    tabLine:setAnchorPoint(ccp(0.5,1))
    tabLine:setPosition(G_VisibleSizeWidth/2,tabHeight-threeItem:getContentSize().height/2)
    self.bgLayer:addChild(tabLine)

    -- local timeHeight = self.bgLayer:getContentSize().height-240
    -- local everyStartBattleTimeTb=serverWarLocalVoApi:getEveryStartBattleTimeTb()
    -- local timeStr = G_getDataTimeStr(everyStartBattleTimeTb[1] or 0)
    -- local timelb=GetTTFLabelWrap(getlocal("serverWarLocal_beginTime",{timeStr}),25,CCSizeMake(550,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    -- timelb:setAnchorPoint(ccp(0,0.5))
    -- timelb:setPosition(CCPointMake(30,timeHeight))
    -- self.bgLayer:addChild(timelb,1)
    -- self.timelb=timelb


    local hi=self.bgLayer:getContentSize().height-240
    local tlbSize=26
    local tLb1 = GetTTFLabel(getlocal("alliance_scene_rank"),tlbSize);
    tLb1:setAnchorPoint(ccp(0,0.5));
    tLb1:setPosition(ccp(70,hi));
    self.bgLayer:addChild(tLb1,2);
    tLb1:setColor(G_ColorGreen)
    self.tLb1=tLb1

    local tLb2 = GetTTFLabel(getlocal("alliance_scene_button_info_name"),tlbSize);
    tLb2:setAnchorPoint(ccp(0,0.5));
    tLb2:setPosition(ccp(210,hi));
    self.bgLayer:addChild(tLb2,2);
    tLb2:setColor(G_ColorGreen)
    self.tLb2=tLb2

    local tLb3 = GetTTFLabel(getlocal("showAttackRank"),tlbSize);
    tLb3:setAnchorPoint(ccp(0,0.5));
    tLb3:setPosition(ccp(375,hi));
    self.bgLayer:addChild(tLb3,2);
    tLb3:setColor(G_ColorGreen)
    self.tLb3=tLb3

    local tLb4 = GetTTFLabel(getlocal("state"),tlbSize);
    tLb4:setAnchorPoint(ccp(0.5,0.5));
    tLb4:setPosition(ccp(540,hi));
    self.bgLayer:addChild(tLb4,2);
    tLb4:setColor(G_ColorGreen)
    self.tLb4=tLb4

    local desLb = GetTTFLabelWrap(getlocal("serverWarLocal_resgistion_des"),25,CCSizeMake(550,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    desLb:setAnchorPoint(ccp(0,0.5))
    desLb:setPosition(CCPointMake(40,70))
    desLb:setColor(G_ColorRed)
    self.bgLayer:addChild(desLb)
    self.desLb=desLb

    self:tLbIsvisible(false)



    self:tabClick(1)

end

function serverWarLocalAgainstRankTab1:tLbIsvisible(flag)
    if flag==true then
        for i=1, 4 do
            self["tLb" .. i]:setVisible(true)
        end
        -- self.timelb:setVisible(false)
        self.desLb:setVisible(true)
    else
        for i=1, 4 do
            self["tLb" .. i]:setVisible(false)
        end
        -- self.timelb:setVisible(true)
        self.desLb:setVisible(false)
    end
   
end

-- function serverWarLocalAgainstRankTab1:setTimeLb(num)
--     local everyStartBattleTimeTb=serverWarLocalVoApi:getEveryStartBattleTimeTb()
--     local timeStr = G_getDataTimeStr(everyStartBattleTimeTb[num] or 0)
--     self.timelb:setString(getlocal("serverWarLocal_beginTime",{timeStr}))
-- end



function serverWarLocalAgainstRankTab1:eventHandler1(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then	 	
        return 2
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
		tmpSize=CCSizeMake(self.cellWidth,self.normalHeight)
		return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease() 

        local function touch()
        end
        local capInSet = CCRect(15,15,2,2)
        local bgWidth,bgHeight=self.cellWidth,(self.normalHeight-60)
        local backsprite =LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",capInSet,touch)
        backsprite:setContentSize(CCSizeMake(bgWidth,bgHeight))
        backsprite:setAnchorPoint(ccp(0.5,0))
        backsprite:setPosition(ccp(bgWidth/2,0))
        cell:addChild(backsprite,1)

        local timeBg=LuaCCScale9Sprite:createWithSpriteFrameName("newRankTitleBg.png",CCRect(4,4,1,1),function()end)
        timeBg:setContentSize(CCSizeMake(bgWidth,60))
        timeBg:setAnchorPoint(ccp(0.5,1))
        timeBg:setPosition(bgWidth/2,bgHeight)
        backsprite:addChild(timeBg)

        local timeStr
        local noticeTime = serverWarLocalCfg.getSignUp
        if idx==0 then
            timeStr=serverWarLocalVoApi:getStartTime()+serverWarLocalCfg.signuptime*3600*24+serverWarLocalCfg.startWarTime["a"][1]*3600+serverWarLocalCfg.startWarTime["a"][2]*60 + noticeTime
        else
            timeStr=serverWarLocalVoApi:getStartTime()+serverWarLocalCfg.signuptime*3600*24+serverWarLocalCfg.startWarTime["b"][1]*3600+serverWarLocalCfg.startWarTime["b"][2]*60 + noticeTime
        end
        timeStr=G_getDataTimeStr(timeStr)
        local timelb=GetTTFLabelWrap(getlocal("serverWarLocal_beginTime",{timeStr}),25,CCSizeMake(backsprite:getContentSize().width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        timelb:setAnchorPoint(ccp(0.5,0.5))
        timelb:setPosition(getCenterPoint(timeBg))
        timeBg:addChild(timelb,1)

        local bgSize = backsprite:getContentSize()
        local titleStr=""
        if idx==0 then
            titleStr=getlocal("serverWarLocal_AGroup")
        else
            titleStr=getlocal("serverWarLocal_BGroup")
        end

        local state = self:getState1()
        local rankStrTb={}
        local armyTuanTb={}

        local schedule=self.across.schedule or {}
        local ainfo = self.across.ainfo
        local list=schedule[1] or {}
        local Alist = list.a or {}
        local Blist = list.b or {}

        if state==1 then
            for i=1,4 do
                table.insert(rankStrTb,"--")
                table.insert(armyTuanTb,getlocal("serverWarLocal_unSure"))
            end
        elseif state==2 and idx==0 then
           
            for i=1,4 do
                local xinxiTb = Alist[i]
                local nameStr="--"
                if xinxiTb then
                    local fid = tonumber(Split(xinxiTb[1],"-")[1])
                    nameStr = GetServerNameByID(fid) .. "-" .. ainfo[xinxiTb[1]][1]
                end
                table.insert(rankStrTb,"--")
                table.insert(armyTuanTb,nameStr)
            end
           
        elseif state==2 and idx==1 then

            for i=1,4 do
                local xinxiTb = Blist[i]
                local nameStr="--"
                if xinxiTb then
                    local fid = tonumber(Split(xinxiTb[1],"-")[1])
                    nameStr = GetServerNameByID(fid) .. "-" .. ainfo[xinxiTb[1]][1]
                end
                table.insert(rankStrTb,"--")
                table.insert(armyTuanTb,nameStr)
            end
        elseif state==3 and idx==0 then

            for i=1,4 do
                local xinxiTb = Alist[i]
                local rankStr = "--"
                local nameStr="--"
                if xinxiTb then
                    local fid = tonumber(Split(xinxiTb[1],"-")[1])
                    nameStr = GetServerNameByID(fid) .. "-" .. ainfo[xinxiTb[1]][1]
                    nameStr = nameStr .. "\n" .. "(" .. (xinxiTb[2] or 0) .. ")"
                    rankStr = i
                end
                print("++++++++state==3 and idx==0",rankStr,nameStr)
                table.insert(rankStrTb,rankStr)
                table.insert(armyTuanTb,nameStr)
            end
        elseif state==3 and idx==1 then
             for i=1,4 do
                local xinxiTb = Blist[i]
                local rankStr = "--"
                local nameStr="--"
                if xinxiTb then
                    local fid = tonumber(Split(xinxiTb[1],"-")[1])
                    nameStr = GetServerNameByID(fid) .. "-" .. ainfo[xinxiTb[1]][1]
                    nameStr = nameStr .. "\n" .. "(" .. (xinxiTb[2] or 0) .. ")"
                    rankStr = i
                end
                print("++++++++state==3 and idx==1",rankStr,nameStr)
                table.insert(rankStrTb,rankStr)
                table.insert(armyTuanTb,nameStr)
            end
        end
        local title={titleStr,25,G_ColorYellowPro}
        local titleBg=G_createNewTitle(title,CCSizeMake(bgWidth-150,0))
        titleBg:setPosition(bgWidth/2,bgHeight)
        cell:addChild(titleBg)

        local lineH = bgHeight-60
        local everyH = lineH/4
        for i=1,4 do
            if i~=4 then
                local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function ()end)
                lineSp:setContentSize(CCSizeMake(bgWidth-2,2))
                lineSp:setRotation(180)
                lineSp:setPosition(bgWidth/2,lineH-i*everyH)
                backsprite:addChild(lineSp,1)
            end
   
            if state==3 then
                local riscale=0.8
                if i==1 and rankStrTb[i]~="--" then
                    local rankSp =CCSprite:createWithSpriteFrameName("top1.png")
                    rankSp:setPosition(ccp(90,lineH-i*everyH+everyH/2));
                    rankSp:setScale(riscale)
                    backsprite:addChild(rankSp,1)
                elseif i==2 and rankStrTb[i]~="--" then
                    local rankSp =CCSprite:createWithSpriteFrameName("top2.png")
                    rankSp:setPosition(ccp(90,lineH-i*everyH+everyH/2));
                    rankSp:setScale(riscale)
                    backsprite:addChild(rankSp,1)
                elseif i==3 and rankStrTb[i]~="--" then
                    local rankSp =CCSprite:createWithSpriteFrameName("top3.png")
                    rankSp:setPosition(ccp(90,lineH-i*everyH+everyH/2));
                    rankSp:setScale(riscale)
                    backsprite:addChild(rankSp,1)
                else
                    local rankLb = GetTTFLabel(rankStrTb[i],25)
                    rankLb:setPosition(ccp(90,lineH-i*everyH+everyH/2));
                    backsprite:addChild(rankLb,1)
                end
            else
                local rankLb = GetTTFLabel(rankStrTb[i],25)
                rankLb:setPosition(ccp(70,lineH-i*everyH+everyH/2));
                backsprite:addChild(rankLb,1)
            end
           

            local ramyLb = GetTTFLabelWrap(armyTuanTb[i],25,CCSizeMake(300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            ramyLb:setAnchorPoint(ccp(0.5,0.5))
            ramyLb:setPosition(CCPointMake(bgWidth/2,lineH-i*everyH+everyH/2))
            backsprite:addChild(ramyLb)


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

function serverWarLocalAgainstRankTab1:eventHandler2(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then      
        return 2
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(self.cellWidth,self.normalHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease() 

        local function touch()
        end
        local capInSet = CCRect(15,15,2,2)
        local bgWidth,bgHeight=self.cellWidth,(self.normalHeight-60)
        local backsprite =LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",capInSet,touch)
        backsprite:setContentSize(CCSizeMake(bgWidth,bgHeight))
        backsprite:setAnchorPoint(ccp(0.5,0))
        backsprite:setPosition(ccp(bgWidth/2,0))
        cell:addChild(backsprite,1)

        local timeBg=LuaCCScale9Sprite:createWithSpriteFrameName("newRankTitleBg.png",CCRect(4,4,1,1),function()end)
        timeBg:setContentSize(CCSizeMake(bgWidth,60))
        timeBg:setAnchorPoint(ccp(0.5,1))
        timeBg:setPosition(bgWidth/2,bgHeight)
        backsprite:addChild(timeBg)

        local timeStr
        local noticeTime = serverWarLocalCfg.getSignUp
        if idx==0 then
            timeStr=serverWarLocalVoApi:getStartTime()+serverWarLocalCfg.signuptime*3600*24+serverWarLocalCfg.startWarTime["a"][1]*3600+serverWarLocalCfg.startWarTime["a"][2]*60+86400 + noticeTime
        else
            timeStr=serverWarLocalVoApi:getStartTime()+serverWarLocalCfg.signuptime*3600*24+serverWarLocalCfg.startWarTime["b"][1]*3600+serverWarLocalCfg.startWarTime["b"][2]*60+86400 + noticeTime
        end
        timeStr=G_getDataTimeStr(timeStr)
        local timelb=GetTTFLabelWrap(getlocal("serverWarLocal_beginTime",{timeStr}),25,CCSizeMake(backsprite:getContentSize().width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        timelb:setAnchorPoint(ccp(0.5,0.5))
        timelb:setPosition(getCenterPoint(timeBg))
        timeBg:addChild(timelb,1)

        local bgSize = backsprite:getContentSize()
        local titleStr=""
        if idx==0 then
            titleStr=getlocal("serverWarLocal_SuccessGroup")
        else
            titleStr=getlocal("serverWarLocal_FailureGroup")
        end


        local state = self:getState2()
        local rankStrTb={}
        local armyTuanTb={}

        local schedule=self.across.schedule or {}
        local ainfo = self.across.ainfo
        local list=schedule[2] or {}
        local Alist = list.a or {}
        local Blist = list.b or {}

        if state==1 then
            for i=1,4 do
                table.insert(rankStrTb,"--")
                if idx==0 then
                    table.insert(armyTuanTb,getlocal("serverWarLocal_sgroup" .. i))
                else
                    table.insert(armyTuanTb,getlocal("serverWarLocal_fgroup" .. i))
                end
            end
        elseif state==2 and idx==0 then
           
            for i=1,4 do
                local xinxiTb = Alist[i]
                local nameStr="--"
                if xinxiTb then
                    local fid = tonumber(Split(xinxiTb[1],"-")[1])
                    nameStr = GetServerNameByID(fid) .. "-" .. ainfo[xinxiTb[1]][1]
                end
                table.insert(rankStrTb,"--")
                table.insert(armyTuanTb,nameStr)
            end
           
        elseif state==2 and idx==1 then

            for i=1,4 do
                local xinxiTb = Blist[i]
                local nameStr="--"
                if xinxiTb then
                    local fid = tonumber(Split(xinxiTb[1],"-")[1])
                    nameStr = GetServerNameByID(fid) .. "-" .. ainfo[xinxiTb[1]][1]
                end
                table.insert(rankStrTb,"--")
                table.insert(armyTuanTb,nameStr)
            end
        elseif state==3 and idx==0 then

            for i=1,4 do
                local xinxiTb = Alist[i]
                local rankStr = "--"
                local nameStr="--"
                if xinxiTb then
                    local fid = tonumber(Split(xinxiTb[1],"-")[1])
                    nameStr = GetServerNameByID(fid) .. "-" .. ainfo[xinxiTb[1]][1]
                    nameStr = nameStr .. "\n" .. "(" .. (xinxiTb[2] or 0) .. ")"
                    rankStr = i
                end
                table.insert(rankStrTb,rankStr)
                table.insert(armyTuanTb,nameStr)
            end
        elseif state==3 and idx==1 then
             for i=1,4 do
                local xinxiTb = Blist[i]
                local rankStr = "--"
                local nameStr="--"
                if xinxiTb then
                    local fid = tonumber(Split(xinxiTb[1],"-")[1])
                    nameStr = GetServerNameByID(fid) .. "-" .. ainfo[xinxiTb[1]][1]
                    nameStr = nameStr .. "\n" .. "(" .. (xinxiTb[2] or 0) .. ")"
                    rankStr = i
                end
                table.insert(rankStrTb,rankStr)
                table.insert(armyTuanTb,nameStr)
            end
        end
        local title={titleStr,25,G_ColorYellowPro}
        local titleBg=G_createNewTitle(title,CCSizeMake(bgSize.width-150,0))
        titleBg:setPosition(bgWidth/2,bgHeight)
        cell:addChild(titleBg,2)

        local lineH = bgHeight-60
        local everyH = lineH/4
        for i=1,4 do
            if i~=4 then
                local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function ()end)
                lineSp:setContentSize(CCSizeMake(bgWidth-2,2))
                lineSp:setRotation(180)
                lineSp:setPosition(bgWidth/2,lineH-i*everyH)
                backsprite:addChild(lineSp,1)
            end

            if state==3 then
                local riscale=0.8
                if i==1 and rankStrTb[i]~="--" then
                    local rankSp =CCSprite:createWithSpriteFrameName("top1.png")
                    rankSp:setPosition(ccp(90,lineH-i*everyH+everyH/2));
                    rankSp:setScale(riscale)
                    backsprite:addChild(rankSp,1)
                elseif i==2 and rankStrTb[i]~="--" then
                    local rankSp =CCSprite:createWithSpriteFrameName("top2.png")
                    rankSp:setPosition(ccp(90,lineH-i*everyH+everyH/2));
                    rankSp:setScale(riscale)
                    backsprite:addChild(rankSp,1)
                elseif i==3 and rankStrTb[i]~="--" then
                    local rankSp =CCSprite:createWithSpriteFrameName("top3.png")
                    rankSp:setPosition(ccp(90,lineH-i*everyH+everyH/2));
                    rankSp:setScale(riscale)
                    backsprite:addChild(rankSp,1)
                else
                    local rankLb = GetTTFLabel(rankStrTb[i],25)
                    rankLb:setPosition(ccp(90,lineH-i*everyH+everyH/2));
                    backsprite:addChild(rankLb,1)
                end
            else
                local rankLb = GetTTFLabel(rankStrTb[i],25)
                rankLb:setPosition(ccp(70,lineH-i*everyH+everyH/2));
                backsprite:addChild(rankLb,1)
            end
           

            local ramyLb = GetTTFLabelWrap(armyTuanTb[i],25,CCSizeMake(350,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            ramyLb:setAnchorPoint(ccp(0.5,0.5))
            ramyLb:setPosition(CCPointMake(bgWidth/2,lineH-i*everyH+everyH/2))
            backsprite:addChild(ramyLb)


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

function serverWarLocalAgainstRankTab1:eventHandler3(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then      
        return SizeOfTable(self.registrationlist)
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(600,self.cellheight1)
       return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
       cell:autorelease()
       local rect = CCRect(0, 0, 50, 50);
       local capInSet = CCRect(20, 20, 10, 10);
       local function cellClick(hd,fn,idx)
           --return self:cellClick(idx)
       end
       
        local cellWidth=600
        local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function ()end)
        lineSp:setContentSize(CCSizeMake(cellWidth-2,2))
        lineSp:setRotation(180)
        lineSp:setPosition(cellWidth/2,lineSp:getContentSize().height/2)
        cell:addChild(lineSp,1)

       local tlbSize=25
       local tLb1 = GetTTFLabel(idx+1,tlbSize);
       tLb1:setPosition(ccp(65,self.cellheight1/2+5));
       cell:addChild(tLb1,2);

       local nameStr = GetServerNameByID(self.registrationlist[idx+1].zid) .. "-" .. self.registrationlist[idx+1].name
       local tLb2 = GetTTFLabelWrap(nameStr,tlbSize,CCSizeMake(175,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
       tLb2:setPosition(ccp(210,self.cellheight1/2+5));
       cell:addChild(tLb2,2);

       local fightNum=FormatNumber(self.registrationlist[idx+1].fight)
       local tLb3 = GetTTFLabel(fightNum,tlbSize);
       tLb3:setPosition(ccp(370,self.cellheight1/2+5));
       cell:addChild(tLb3,2);

       local state=getlocal("serverWarLocal_exam")
       if self.registrationlist[idx+1].state and self.registrationlist[idx+1].state==1 then
        state=getlocal("serverWarLocal_outbound")
       end
       local tLb4 = GetTTFLabel(state,tlbSize);
       tLb4:setPosition(ccp(510,self.cellheight1/2+5));
       cell:addChild(tLb4,2);

       if self.registrationlist[idx+1].state and self.registrationlist[idx+1].state==1 then
             tLb1:setColor(G_ColorYellowPro)
             tLb2:setColor(G_ColorYellowPro)
             tLb3:setColor(G_ColorYellowPro)
             tLb4:setColor(G_ColorYellowPro)
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

-- 1:报名未结束，无对阵列表信息
-- 2：第一局未结束，无排名信息
-- 3：第一局结束，排名已出
function serverWarLocalAgainstRankTab1:getState1()
    local Status = serverWarLocalVoApi:checkStatus()
    if Status==0 or Status==10 then
        return 1
    end

    if serverWarLocalVoApi:isEndOfoneBattle() then
        return 3
    end


    return 2
end

function serverWarLocalAgainstRankTab1:getState2()
    local Status = serverWarLocalVoApi:checkStatus()
    if Status==30 then
        return 3
    end

    if serverWarLocalVoApi:isEndOfoneBattle() then
        return 2
    end

    return 1

   
end

function serverWarLocalAgainstRankTab1:refresh()
end

function serverWarLocalAgainstRankTab1:initTableViw1()
    local function callBack(...)
        return self:eventHandler1(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv1=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.cellWidth,self.bgLayer:getContentSize().height-240),nil)
    self.tv1:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv1:setPosition(ccp(30,30))
    self.bgLayer:addChild(self.tv1,1)
    self.tv1:setMaxDisToBottomOrTop(80)
end

function serverWarLocalAgainstRankTab1:initTableViw2()
    local function callBack(...)
        return self:eventHandler2(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv2=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.cellWidth,self.bgLayer:getContentSize().height-240),nil)
    self.tv2:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv2:setPosition(ccp(30,30))
    self.bgLayer:addChild(self.tv2,1)
    self.tv2:setMaxDisToBottomOrTop(80)
end

function serverWarLocalAgainstRankTab1:initTableViw3()
    local function callBack(...)
        return self:eventHandler3(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv3=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-60,self.bgLayer:getContentSize().height-300-70),nil)
    self.tv3:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv3:setPosition(ccp(30,110))
    self.bgLayer:addChild(self.tv3,1)
    self.tv3:setMaxDisToBottomOrTop(80)
end

function serverWarLocalAgainstRankTab1:refreshNoRankLb()
    if SizeOfTable(self.registrationlist)==0 then
        self.noRankLb:setVisible(true)
    end
end



function serverWarLocalAgainstRankTab1:tabClickColor(idx)
    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
         else
            v:setEnabled(true)
         end
    end
end

function serverWarLocalAgainstRankTab1:tabClick(idx)
    PlayEffect(audioCfg.mouseClick)
    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx           
         else            
            v:setEnabled(true)
         end
    end

    if idx==1 then
        if self.tv1==nil then
            self:initTableViw1()
            self:tLbIsvisible(false)
            -- self:setTimeLb(1)
        end
        if  self.tv1 then
            self.tv1:setPosition(ccp(30,30))
            self.tv1:setVisible(true)
            self:tLbIsvisible(false)
            -- self:setTimeLb(1)
        end
        if  self.tv2 then
            self.tv2:setPosition(ccp(999333,0))
            self.tv2:setVisible(false)
        end
        if  self.tv3 then
            self.tv3:setPosition(ccp(999333,0))
            self.tv3:setVisible(false)
            self.noRankLb:setVisible(false)
        end
    elseif(idx==2)then
        if self.tv2==nil then
            self:initTableViw2()
            self:tLbIsvisible(false)
            -- self:setTimeLb(2)
        end
        if  self.tv2 then
            self.tv2:setPosition(ccp(30,30))
            self.tv2:setVisible(true)
            self:tLbIsvisible(false)
            -- self:setTimeLb(2)
        end
        if  self.tv1 then
            self.tv1:setPosition(ccp(999333,0))
            self.tv1:setVisible(false)
        end
        if  self.tv3 then
            self.tv3:setPosition(ccp(999333,0))
            self.tv3:setVisible(false)
            self.noRankLb:setVisible(false)
        end
    elseif(idx==3)then
        if self.tv3==nil then
            local function callback(registrationlist)
                self.registrationlist=self:getRegistrationlist(registrationlist)
                self:refreshNoRankLb()
                self:initTableViw3()
                self:tLbIsvisible(true)
            end
            serverWarLocalVoApi:getRegistrationlist(callback)
        end
        if  self.tv3 then
            self:refreshNoRankLb()
            self.tv3:setPosition(ccp(30,110))
            self.tv3:setVisible(true)
            self:tLbIsvisible(true)

        end
        if  self.tv1 then
            self.tv1:setPosition(ccp(999333,0))
            self.tv1:setVisible(false)
        end
         if  self.tv2 then
            self.tv2:setPosition(ccp(999333,0))
            self.tv2:setVisible(false)
        end

    end

end

function serverWarLocalAgainstRankTab1:getRegistrationlist(registrationlist)
    -- self.across
    local list = {}
    local ainfo=self.across.ainfo or {}
    for k,v in pairs(registrationlist) do
        local fid = v.zid
        local aid = v.aid
        local strId = fid .. "-" .. aid
        for kk,vv in pairs(ainfo) do
            if tostring(kk)==strId then
                local xinxiTb = G_clone(v)
                xinxiTb.state=1
                table.insert(list,xinxiTb)
            end
        end
    end

    for k,v in pairs(registrationlist) do
        local fid = v.zid
        local aid = v.aid
        local strId = fid .. "-" .. aid
        local flag=1
        for kk,vv in pairs(ainfo) do
            if tostring(kk)==strId then
                flag=nil
            end
        end
        if flag then
            table.insert(list,v)
        end
    end
    return list

end

function serverWarLocalAgainstRankTab1:tick()
end


function serverWarLocalAgainstRankTab1:dispose()
    self.bgLayer=nil
    self.layerNum=nil
    self.selectedTabIndex=nil --当前选中的tab
    self.oldSelectedTabIndex=nil --上一次选中的tab
    self.allTabs=nil
    self.timelb=nil
    self.registrationlist={}
    self.cellheight1=nil
end

