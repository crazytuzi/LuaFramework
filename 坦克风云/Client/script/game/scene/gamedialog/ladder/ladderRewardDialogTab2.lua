-- 天梯奖励面板
ladderRewardDialogTab2={}
function ladderRewardDialogTab2:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.subTab1Layer=nil
    self.subTab2Layer=nil
    self.subTab3Layer=nil
    return nc
end


function ladderRewardDialogTab2:init(layerNum,subTabType)
    self.layerNum=layerNum
    self.bgLayer=CCLayer:create()
    self:switchSubTab(subTabType)
    return self.bgLayer
end

function ladderRewardDialogTab2:switchSubTab(subTabType)
    self.subTabType=subTabType
    if subTabType==10 then
        if self.subTab2Layer then
            self.subTab2Layer:setPosition(ccp(99999,0))
            self.subTab2Layer:setVisible(false)
        end
        if self.subTab1Layer==nil then
            self.subTab1Layer=self:initTableView(subTabType)
        else
            self.subTab1Layer:setPosition(getCenterPoint(self.bgLayer))
            self.subTab1Layer:setVisible(true)
        end
    elseif  subTabType==11 then
        if self.subTab1Layer then
            self.subTab1Layer:setPosition(ccp(99999,0))
            self.subTab1Layer:setVisible(false)
        end
        if self.subTab2Layer==nil then
            local function openTab2()
                self.subTab2Layer=self:initTableView(subTabType)
            end
            local function callbackHandler(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    if sData and sData.data and sData.data.ladder then
                        ladderVoApi:formatData(sData.data.ladder)
                        ladderVoApi.lastRequestTime2=base.serverTime
                    end
                    openTab2()
                end
            end
            print("---dmj----1")
            if (ladderVoApi:getAllianceLadderList()==nil and ladderVoApi:checkIfNeedRequestByNoData()) or ladderVoApi:checkIfNeedRequestData(2)==true then
                print("---dmj----2")
                local isCountScore=ladderVoApi:ifCountingScore()
                if isCountScore==false then
                    print("---dmj----3")
                    local expiration_time,isShowRank = ladderVoApi:getLadderEndTime()
                    if isShowRank==true then
                        print("---dmj----4")
                        socketHelper:getLadderRank(2,callbackHandler)
                    else
                        openTab2()        
                    end
                else
                    openTab2()    
                end
            else
                openTab2()
            end
            
        else
            self.subTab2Layer:setPosition(getCenterPoint(self.bgLayer))
            self.subTab2Layer:setVisible(true)
        end
    end
end
--设置对话框里的tableView
function ladderRewardDialogTab2:initTableView(subTabType)
    local topBgH = 180
    local topBgW = self.bgLayer:getContentSize().width-28
    local topY = self.bgLayer:getContentSize().height-295
    local tvH = topY-topBgH/2-245
    local tvY = 85
    local containerSp=CCSprite:create()
    containerSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width,self.bgLayer:getContentSize().height))
    containerSp:setAnchorPoint(ccp(0.5,0.5))
    containerSp:setPosition(getCenterPoint(self.bgLayer))
    self.bgLayer:addChild(containerSp)

    local function togBgHandler( ... )
    end
    local topBg = LuaCCScale9Sprite:createWithSpriteFrameName("TrialSquadBox.png",CCRect(28, 30, 1, 1),togBgHandler)
    topBg:setContentSize(CCSizeMake(topBgW-20,topBgH))
    containerSp:addChild(topBg)
    topBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,topY))

    local timeTitleLb=GetTTFLabelWrap(getlocal("send_reward_time"),28,CCSizeMake(topBgW,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    timeTitleLb:setPosition(ccp((topBgW-20)/2,topBgH-25))
    topBg:addChild(timeTitleLb)
    timeTitleLb:setColor(G_ColorYellowPro)

    local expiration_time,isShowRank = ladderVoApi:getLadderEndTime()
    if ladderVoApi:getLadderEndTime()==0 then
        expiration_time=getlocal("ladder_season_endtime")
    end
    local timeLb=GetTTFLabelWrap(expiration_time,25,CCSizeMake(topBgW,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    timeLb:setPosition(ccp((topBgW-20)/2,topBgH-55))
    topBg:addChild(timeLb)

    local rewardDescStr1 = getlocal("ladder_reward_desc3")
    local rewardDescStr5 = ""
    if subTabType==11 then
        rewardDescStr1 = getlocal("ladder_reward_desc4")
        rewardDescStr5 = getlocal("ladder_reward_desc5")
    end
    local rewardDescLb1=GetTTFLabelWrap(rewardDescStr1,22,CCSizeMake(topBgW-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    rewardDescLb1:setPosition(ccp(20,(topBgH-55)/2))
    -- rewardDescLb1:setPosition(ccp(20,timeLb:getPositionY()-timeLb:getContentSize().height/2-rewardDescLb1:getContentSize().height/2-5))
    rewardDescLb1:setAnchorPoint(ccp(0,0.5))
    topBg:addChild(rewardDescLb1)

    if rewardDescStr5~="" then
        local rewardDescLb2=GetTTFLabelWrap(rewardDescStr5,22,CCSizeMake(topBgW-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        rewardDescLb2:setAnchorPoint(ccp(0,0.5))
        topBg:addChild(rewardDescLb2)
        rewardDescLb2:setColor(G_ColorRed)
        rewardDescLb1:setPosition(ccp(20,(topBgH-55+rewardDescLb2:getContentSize().height)/2))
        rewardDescLb2:setPosition(ccp(20,rewardDescLb1:getPositionY()-rewardDescLb1:getContentSize().height/2-rewardDescLb2:getContentSize().height/2-5))
    end


    local totalScore,score1,score2,score3,score4,myRank = ladderVoApi:getMyselfInfo()
    if subTabType==11 then
        totalScore,score1,score2,score3,score4,myRank = ladderVoApi:getMyAllianceInfo()
    end
    self.myRank=myRank
    local rankParamStr,reward = ladderVoApi:getRankDistrict(myRank,subTabType)
    if isShowRank==false then
        rankParamStr=getlocal("ladderRank_noRank")
    end
    local rewardStr = getlocal("ladder_reward_desc1",{rankParamStr})
    local rankRewardLb
        
    rankRewardLb=GetTTFLabelWrap(rewardStr,25,CCSizeMake(topBgW-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    rankRewardLb:setPosition(ccp(30,topY-topBgH/2-30))
    rankRewardLb:setAnchorPoint(ccp(0,0.5))    
    containerSp:addChild(rankRewardLb)
    if myRank==0 or isShowRank==false then
        local noDataDescLb=getlocal("ladder_hof_desc2")
        noDataDescLb=GetTTFLabelWrap(noDataDescLb,23,CCSizeMake(topBgW-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        noDataDescLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,topY-topBgH/2-90))
        noDataDescLb:setColor(G_ColorGray)
        containerSp:addChild(noDataDescLb)
    end
    

    local iconY = topY-topBgH/2-90
    local iconX = 0
    local iconW = 80
    
    local award = FormatItem(reward)
    local rewardNum = SizeOfTable(award)
    if award and rewardNum>0 and isShowRank==true then
        local index = 1
        for k,v in pairs(award) do
            iconX=topBgW/2+(index-(rewardNum+1)/2)*(iconW+10)
            local icon = G_getItemIcon(v, iconW, true, self.layerNum)
            icon:setTouchPriority(-(self.layerNum-1)*20-3)
            icon:setPosition(ccp(iconX,iconY))
            containerSp:addChild(icon,1)
            index=index+1

            local numLb=GetTTFLabel("x"..v.num,20)
            numLb:setAnchorPoint(ccp(1,0))
            numLb:setPosition(ccp(icon:getContentSize().width-15,10))
            icon:addChild(numLb)
        end
    end

    -- local lineSP =CCSprite:createWithSpriteFrameName("LineCross.png")
    -- lineSP:setAnchorPoint(ccp(0.5,0.5))
    -- lineSP:setScaleX((G_VisibleSizeWidth-40)/lineSP:getContentSize().width)
    -- lineSP:setPosition(ccp(containerSp:getContentSize().width/2,iconY-iconW/2-10))
    -- containerSp:addChild(lineSP)

    self["rewardCfg"..self.subTabType]=ladderVoApi:getRankRewardCfg(subTabType)
    local function callBack(...)
       return self:eventHandler(...)
    end

    local descBg = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50, 50, 1, 1),function ()    end)
    descBg:setContentSize(CCSizeMake(topBgW-20,tvH+20))
    descBg:setPosition(ccp(containerSp:getContentSize().width/2,tvY-5))
    descBg:setAnchorPoint(ccp(0.5,0))
    containerSp:addChild(descBg)

    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(topBgW,tvH),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.tv:setPosition(ccp(10,tvY))
    containerSp:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(10)


    local descLb=GetTTFLabelWrap(getlocal("ladder_reward_desc2"),20,CCSizeMake(topBgW-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    descLb:setPosition(ccp(30,55))
    descLb:setAnchorPoint(ccp(0,0.5))
    containerSp:addChild(descLb)
    descLb:setColor(G_ColorRed)
    return containerSp
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function ladderRewardDialogTab2:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local rewardNum = SizeOfTable(self["rewardCfg"..self.subTabType])
        return rewardNum
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-40,90)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local iconY = 45
        local reward = self["rewardCfg"..self.subTabType][idx+1].reward
        local award = FormatItem(reward)
        local rewardNum = SizeOfTable(award)
        if (idx+1)<3 then
            local rankSp
            if tonumber(idx+1)==1 then
                rankSp=CCSprite:createWithSpriteFrameName("top1.png")
            elseif tonumber(idx+1)==2 then
                rankSp=CCSprite:createWithSpriteFrameName("top2.png")
            elseif tonumber(idx+1)==3 then
                rankSp=CCSprite:createWithSpriteFrameName("top3.png")
            end
            if rankSp then
                rankSp:setPosition(ccp(160,iconY))
                cell:addChild(rankSp,1)
            end
        else
            local rankStr = getlocal("rankOne",{ladderVoApi:getRankDistrickByIndix((idx+1),self.subTabType)})
            local rankLb=GetTTFLabelWrap(rankStr,28,CCSizeMake(300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            rankLb:setPosition(ccp(160,iconY))
            cell:addChild(rankLb)
            rankLb:setColor(G_ColorYellowPro)


        end
        
        local iconX = 0
        local iconW = 80
        for i=1,rewardNum do
            local item = award[i]
            if item then
                iconX=330+(i-1)*(iconW+10)
                local icon = G_getItemIcon(item, iconW, true, self.layerNum)
                icon:setTouchPriority(-(self.layerNum-1)*20-3)
                icon:setPosition(ccp(iconX,iconY))
                cell:addChild(icon,1)

                local numLb=GetTTFLabel("x"..item.num,20)
                numLb:setAnchorPoint(ccp(1,0))
                numLb:setPosition(ccp(icon:getContentSize().width-15,10))
                icon:addChild(numLb)
            end
        end

        return cell

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


function ladderRewardDialogTab2:tick()

end

function ladderRewardDialogTab2:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.subTab1Layer=nil
    self.subTab2Layer=nil
    self.subTab3Layer=nil
end