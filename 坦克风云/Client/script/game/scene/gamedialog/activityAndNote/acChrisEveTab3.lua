acChrisEveTab3 ={}
function acChrisEveTab3:new(layerNum)
        local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.rankList            = {}
    nc.bgLayer             = nil
    nc.layerNum            = layerNum
    nc.tv                  = nil
    nc.loveGems            = nil
    nc.bgWidth             = G_VisibleSizeWidth-40
    nc.bgHeight            = G_VisibleSizeHeight-182
    nc.rewardBtn           = nil
    nc.needIphone5Height_1 =  0
    nc.name                = playerVoApi:getPlayerName()
    nc.rank                = nil
    nc.adaH                = 0
    nc.adaH2               = 0
    nc.version             = acChrisEveVoApi:getVersion()
    nc.isIphoneX           = false
    if G_getIphoneType() == G_iphoneX then
        nc.adaH = 60
        nc.isIphoneX= true
    end
    nc.isCurr=true
    if G_isIphone5() then
        nc.needIphone5Height_1 = 20
        if nc.version == 5 and nc.isIphoneX == false then
            nc.adaH2 = 20
        end
    end
    return nc;

end
function acChrisEveTab3:dispose( )
    self.adaH2               = nil
    self.isIphoneX           = nil
    self.version             = nil
    self.bgLayer             = nil
    self.layerNum            = nil
    self.rankList            = nil
    self.tv                  = nil
    self.loveGems            = nil
    self.rank                = nil
    self.bgWidth             = nil
    self.bgHeight            = nil
    self.needIphone5Height_1 = nil
    self.rewardBtn           = nil
    self.name                = nil
    self.isCurr              = nil
    self.adaH                = nil
end

function acChrisEveTab3:init(layerNum)
    local strSize2 = 20
    local subPosH = 10
    if G_isAsia() == true then
        strSize2 =25
        subPosH =0
        if G_getCurChoseLanguage() == "ko" and G_getIphoneType() == G_iphone4 then
            strSize2 = 18
            subPosH = -20
        end
    end
    self.bgLayer=CCLayer:create()
    self.layerNum = layerNum or self.layerNum

    self.rankList =acChrisEveVoApi:getRankList()

    local function touch( )
    end 
    local wholeBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touch)--拉霸动画背景
    wholeBgSp:setContentSize(CCSizeMake(self.bgWidth,self.bgHeight))
    self.bgLayer:addChild(wholeBgSp,1)
    wholeBgSp:setAnchorPoint(ccp(0,0))
    wholeBgSp:setPosition(ccp(20,23))

    if(acChrisEveVoApi:isNormalVersion()==false) and self.version ~= 5 then
        local cloud1 = CCSprite:createWithSpriteFrameName("snowBg_1.png")
        cloud1:setAnchorPoint(ccp(0,0.5))
        cloud1:setPosition(ccp(0,self.bgHeight))
        wholeBgSp:addChild(cloud1,99999)
    
        local cloud2 = CCSprite:createWithSpriteFrameName("snowBg_2.png")
        cloud2:setAnchorPoint(ccp(1,1))
        cloud2:setPosition(ccp(self.bgWidth,self.bgHeight+5))
        wholeBgSp:addChild(cloud2,99999)
    end
-------
    local headBg=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),function () do return end end)
    headBg:setContentSize(CCSizeMake(wholeBgSp:getContentSize().width-4,wholeBgSp:getContentSize().height*0.15+self.needIphone5Height_1+15))
    headBg:setAnchorPoint(ccp(0.5,1))
    if self.version == 5 then
        wholeBgSp:setOpacity(0)
        headBg:setOpacity(0)
    end
    headBg:setPosition(ccp(wholeBgSp:getContentSize().width*0.5,wholeBgSp:getContentSize().height-4))
    wholeBgSp:addChild(headBg)

    local koAda = 0
    if G_getCurChoseLanguage() == "ko" then
        koAda = 20
    end
    local rechargeTimeLabel=GetTTFLabel(acChrisEveVoApi:getRewardTimeStr(),strSize2,"Helvetica-bold")
    rechargeTimeLabel:setAnchorPoint(ccp(0.5,1))
    rechargeTimeLabel:setPosition((headBg:getContentSize().width-80)/2+15,headBg:getContentSize().height-30+koAda)
    if self.version == 5 then
        local timeBg=LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png",CCRect(103,0,2,80),function()end)
        timeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,80))
        timeBg:setAnchorPoint(ccp(0.5,1))
        timeBg:setOpacity(255*0.6)
        timeBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-157)
        self.bgLayer:addChild(timeBg)

        rechargeTimeLabel:setColor(G_ColorYellowPro2)
        self.headPosMiddlePosx = headBg:getContentSize().width * 0.5
        rechargeTimeLabel:setPosition(self.headPosMiddlePosx,headBg:getContentSize().height-5)
    else
        rechargeTimeLabel:setColor(G_ColorYellowPro)
    end
    headBg:addChild(rechargeTimeLabel)
    self.timeLb=rechargeTimeLabel
    self:updateAcTime()

    local kccType = self.version == 5 and kCCTextAlignmentCenter or kCCTextAlignmentLeft
    local iphone5H = 20
    if G_isIphone5() then
        iphone5H =30
    end
    local rankPoint = acChrisEveVoApi:getRankPoint( )
    local rankPointStr = GetTTFLabelWrap(getlocal("activity_chrisEve_LoveGemsMayToShow",{rankPoint}),strSize2,CCSizeMake(450,0),kccType,kCCVerticalTextAlignmentCenter)
    rankPointStr:setAnchorPoint(ccp(0,0))
    rankPointStr:setPosition(ccp(25,iphone5H*2.3-subPosH-koAda*2/3))
    rankPointStr:setColor(G_ColorGreen)
    headBg:addChild(rankPointStr)

    local allLoveGems =acChrisEveVoApi:getLoveGems()--activity_chrisEve_myAllLoveGems
    self.loveGems =GetTTFLabelWrap(getlocal("activity_chrisEve_myAllLoveGems",{allLoveGems}),strSize2,CCSizeMake(350,0),kccType,kCCVerticalTextAlignmentCenter)
    self.loveGems:setAnchorPoint(ccp(0,0))
    self.loveGems:setPosition(ccp(25,iphone5H-subPosH-koAda))
    self.loveGems:setColor(G_ColorYellowPro)
    headBg:addChild(self.loveGems)

    if self.version == 5 and self.headPosMiddlePosx then
        rankPointStr:setAnchorPoint(ccp(0.5,0))
        rankPointStr:setPositionX(self.headPosMiddlePosx)

        self.loveGems:setAnchorPoint(ccp(0.5,0))
        self.loveGems:setPositionX(self.headPosMiddlePosx)

        local infoBg=LuaCCScale9Sprite:createWithSpriteFrameName("ltzdzNameBg.png",CCRect(4, 4, 1, 1),function() end)
        infoBg:setContentSize(CCSizeMake(self.bgWidth-12,(self.bgHeight*0.65-self.needIphone5Height_1) * 0.09 - 6))
        infoBg:setPosition(wholeBgSp:getContentSize().width*0.5 + 2,headBg:getPositionY()-headBg:getContentSize().height-20)
        wholeBgSp:addChild(infoBg,1)
        self.infoBg = infoBg
    end

    local showTop = {"RankScene_rank","alliance_scene_button_info_name","activity_chrisEve_loveGemsStr"}
    local rankPosH = {80,wholeBgSp:getContentSize().width*0.5,wholeBgSp:getContentSize().width*0.85}
    for i=1,3 do
        
        local rankLabel=GetTTFLabel(getlocal(showTop[i]),strSize2)
        rankLabel:setPosition(rankPosH[i],headBg:getPositionY()-headBg:getContentSize().height-20)
        wholeBgSp:addChild(rankLabel,2)
        if self.version == 5 then
            rankLabel:setColor(G_ColorYellowPro2)
        else
            rankLabel:setColor(G_ColorGreen)
        end
    end

    local function touch33(tag,object)
        self:openInfo()
    end
    local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touch33,1,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,1))
    -- menuItemDesc:setScale(0.9)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
    menuDesc:setPosition(ccp(headBg:getContentSize().width-5,headBg:getContentSize().height-5))
    headBg:addChild(menuDesc,1)

    if self.version == 5 then
        menuDesc:setPositionX(menuDesc:getPositionX() + 15)
    end
    if(acChrisEveVoApi:isNormalVersion()==false) and self.version ~= 5 then
        --bellPic
        local bellPic = CCSprite:createWithSpriteFrameName("bellPic.png")
        bellPic:setAnchorPoint(ccp(1,0.5))
        bellPic:setPosition(ccp(self.bgLayer:getContentSize().width+10,self.bgLayer:getContentSize().height-headBg:getContentSize().height*2-25))
        self.bgLayer:addChild(bellPic,99999)
    end

    local function rewardHandler( )
        local rank =nil
        local rankList = acChrisEveVoApi:getRankList()
        local listNum = SizeOfTable(rankList)
        local myUid = playerVoApi:getUid()
        for i=1,listNum do
            if rankList[i][1]==myUid then
                rank =i
            end
        end

        local function getRankCallBack( fn,data )
            local ret,sData=base:checkServerData(data)
            if ret ==true then
                if sData.data and sData.data.reward then
                    local reward = FormatItem(sData.data.reward,false)
                    for k,v in pairs(reward) do
                        G_addPlayerAward(v.type,v.key,v.id,tonumber(v.num),nil,true)
                    end
                    G_showRewardTip(reward)
                end
                if sData.data and sData.data.shengdanqianxi.r then
                    acChrisEveVoApi:setRewardHas(sData.data.shengdanqianxi.r)
                    self.rewardBtn:setEnabled(false)
                end
            elseif sData.ret == -1975 then
                self:socketRefresh( )
            end
        end

        socketHelper:chrisEveSend(getRankCallBack,"rankreward",nil,nil,nil,rank)--rank 排名
    end 

    self.rewardBtn = GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",rewardHandler,nil,getlocal("newGiftsReward"),25,11)
    self.rewardBtn:setAnchorPoint(ccp(0.5,0))
    local rewardMenu=CCMenu:createWithItem(self.rewardBtn)
    rewardMenu:setPosition(ccp(self.bgWidth*0.5,15))
    rewardMenu:setTouchPriority(-(self.layerNum-1)*20-5)
    wholeBgSp:addChild(rewardMenu,2)
    self.rewardBtn:setEnabled(false)

    local acVo = acChrisEveVoApi:getAcVo()
    if base.serverTime > acVo.acEt -86400 then
        local rankList = acChrisEveVoApi:getRankList()
        local listNum = SizeOfTable(rankList)
        local myUid = playerVoApi:getUid()
        for i=1,listNum do
            if rankList[i][1]==myUid then
                -- print("here?33333",i)
                self.rewardBtn:setEnabled(true)
            end
        end
    end
    if acChrisEveVoApi:getRewardHas() ==1 then
        self.rewardBtn:setEnabled(false)
    end

    if self.version == 5 then
        local newBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
        newBg:setContentSize(CCSizeMake(self.bgWidth-8,self.bgHeight*0.65-self.needIphone5Height_1 + self.adaH + self.adaH2 + (self.bgHeight*0.65-self.needIphone5Height_1) * 0.09 + 12))
        newBg:setAnchorPoint(ccp(0.5,0))
        newBg:setPosition(ccp(self.bgWidth*0.5+2,self.rewardBtn:getContentSize().height+22))
        wholeBgSp:addChild(newBg)
    end

    local function touch( )
    end     
    local downBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touch)--拉霸动画背景
    downBgSp:setContentSize(CCSizeMake(self.bgWidth-6,self.bgHeight*0.65-self.needIphone5Height_1+self.adaH + self.adaH2))
    downBgSp:setAnchorPoint(ccp(0.5,0))--
    downBgSp:setOpacity(0)
    downBgSp:setPosition(ccp(self.bgWidth*0.5+2,self.rewardBtn:getContentSize().height+25))
    wholeBgSp:addChild(downBgSp)

    self:initTableView()

    return self.bgLayer
end

function acChrisEveTab3:eventHandler( handler,fn,idx,cel )
    local cellBgWidth = self.bgWidth-4 
    local cellBgHeight = self.bgHeight*0.65-self.needIphone5Height_1
    local strSize2 = 20
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =25
    end
   if fn=="numberOfCellsInTableView" then
        return 1
   elseif fn=="tableCellSizeForIndex" then
        return  CCSizeMake(cellBgWidth,cellBgHeight)-- -100
   elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()

        local function touch( )
        end     
        local cellBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touch)--拉霸动画背景
        cellBgSp:setContentSize(CCSizeMake(cellBgWidth-2,cellBgHeight))
        cellBgSp:setOpacity(0)
        cellBgSp:setAnchorPoint(ccp(0,0))
        cellBgSp:setPosition(ccp(0,0))
        cell:addChild(cellBgSp,3)

        local posW = {80,cellBgWidth*0.5+2,cellBgWidth*0.85+2}
        local allLoveGems =acChrisEveVoApi:getLoveGems()--activity_chrisEve_myAllLoveGems

        local rankList = acChrisEveVoApi:getRankList()
        local listNum = SizeOfTable(rankList)
        local myUid = playerVoApi:getUid()
        local hasMe = false
        for i=1,listNum do

            local name = rankList[i][2]
            local ranksp = nil
            local loveGems = rankList[i][3]
            local posH = cellBgHeight-cellBgHeight*0.05-cellBgHeight*0.1*i

            if self.version == 5 then
                local itemBg=LuaCCScale9Sprite:createWithSpriteFrameName("newListItemBg.png",CCRect(4,4,1,1),function () end)
                itemBg:setContentSize(CCSizeMake(cellBgWidth-4,cellBgHeight * 0.09))
                -- itemBg:setAnchorPoint(ccp(0,0))
                itemBg:setPosition(ccp(posW[2],posH))
                cellBgSp:addChild(itemBg)
                if i%2 == 0 then
                    itemBg:setOpacity(0)
                end
            end

            
            if i <4 then
                if self.version == 5 then
                    rankBgsp =CCSprite:createWithSpriteFrameName("top_"..i..".png")
                    rankBgsp:setScaleY((cellBgHeight * 0.09-4)/rankBgsp:getContentSize().height)
                    rankBgsp:setScaleX((cellBgWidth-10)/rankBgsp:getContentSize().width)
                    rankBgsp:setPosition(posW[2],posH)
                    cellBgSp:addChild(rankBgsp)
                end
                    ranksp =CCSprite:createWithSpriteFrameName("top"..i..".png")
                    ranksp:setScale(0.7)
            else
                ranksp =GetTTFLabel(i,25)
            end
            if rankList[i][1]==myUid then
                hasMe =i
            end
            ranksp:setAnchorPoint(ccp(0.5,0.5))
            ranksp:setPosition(ccp(posW[1],posH))
            cellBgSp:addChild(ranksp)

            local nameStr = GetTTFLabelWrap(name,strSize2,CCSizeMake(300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            nameStr:setAnchorPoint(ccp(0.5,0.5))
            nameStr:setPosition(ccp(posW[2],posH))
            cellBgSp:addChild(nameStr)

            if self.version ~= 5 then
                local lineSP =CCSprite:createWithSpriteFrameName("LineCross.png");
                lineSP:setAnchorPoint(ccp(0.5,0.5))
                lineSP:setScaleX(cellBgSp:getContentSize().width/lineSP:getContentSize().width)
                lineSP:setPosition(ccp(posW[2],posH-25))
                cellBgSp:addChild(lineSP,2)
            end

            local loveGemsStr =GetTTFLabelWrap(loveGems,strSize2,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            loveGemsStr:setAnchorPoint(ccp(0.5,0.5))
            loveGemsStr:setPosition(ccp(posW[3],posH))
            cellBgSp:addChild(loveGemsStr)

        end
        local myRank =nil
        if hasMe ==false then
            myRank = GetTTFLabel("10+",25)
        elseif hasMe >3 then
            myRank =GetTTFLabel(hasMe,25)
        else
            if self.version == 5 then
                    myRankBgsp =CCSprite:createWithSpriteFrameName("top_"..hasMe..".png")
                    myRankBgsp:setScaleY((cellBgHeight * 0.09-4)/myRankBgsp:getContentSize().height)
                    myRankBgsp:setScaleX((cellBgWidth-10)/myRankBgsp:getContentSize().width)
                    myRankBgsp:setPosition(posW[2],cellBgHeight-cellBgHeight*0.05)
                    cellBgSp:addChild(myRankBgsp)
            end
                myRank =CCSprite:createWithSpriteFrameName("top"..hasMe..".png")
                myRank:setScale(0.7)
        end
        myRank:setAnchorPoint(ccp(0.5,0.5))
        myRank:setPosition(ccp(posW[1],cellBgHeight-cellBgHeight*0.05))
        cellBgSp:addChild(myRank)

        local myName =GetTTFLabelWrap(self.name,strSize2,CCSizeMake(300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        myName:setAnchorPoint(ccp(0.5,0.5))
        myName:setPosition(ccp(posW[2],cellBgHeight-cellBgHeight*0.05))
        cellBgSp:addChild(myName)

        if self.version ~= 5 then
            local lineSP =CCSprite:createWithSpriteFrameName("LineCross.png");
            lineSP:setAnchorPoint(ccp(0.5,0.5))
            lineSP:setScaleX(cellBgSp:getContentSize().width/lineSP:getContentSize().width)
            lineSP:setPosition(ccp(posW[2],cellBgHeight-cellBgHeight*0.05-25))
            cellBgSp:addChild(lineSP,2)
        end

        local currLoveGems =GetTTFLabelWrap(allLoveGems,strSize2,CCSizeMake(350,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        currLoveGems:setAnchorPoint(ccp(0.5,0.5))
        currLoveGems:setPosition(ccp(posW[3],cellBgHeight-cellBgHeight*0.05))
        cellBgSp:addChild(currLoveGems)

        cell:autorelease()
        return cell
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end

function acChrisEveTab3:socketRefresh( )
    local function sendRequestCallBack(fn,data )
        local ret,sData = base:checkServerData(data)
        if ret==true then
            -- print("yes~~socketRefresh receive~~~")
            if sData.data and sData.ranklist then
                acChrisEveVoApi:setRankList(sData.ranklist)
                acChrisEveVoApi:setCurrTime(sData.ts)
                acChrisEveVoApi:setCurrType(false)
                local recordPoint = self.tv:getRecordPoint()
                self.tv:reloadData()
                self.tv:recoverToRecordPoint(recordPoint)
            end
        end
    end
    socketHelper:chrisEveSend(sendRequestCallBack,"ranklist")
end
function acChrisEveTab3:tick( )
    self:updateAcTime()
    if acChrisEveVoApi:isRefreshAllServerData( )  ==true then
        self:socketRefresh()
    end
    local acVo = acChrisEveVoApi:getAcVo()
    if base.serverTime > acVo.acEt -86400 then
        local rankList = acChrisEveVoApi:getRankList()
        local listNum = SizeOfTable(rankList)
        local myUid = playerVoApi:getUid()
        if acChrisEveVoApi:getRewardHas() ==0 then
            for i=1,listNum do
                if rankList[i][1]==myUid then
                    self.rewardBtn:setEnabled(true)
                end
            end
        end
    end

    local allLoveGems =acChrisEveVoApi:getLoveGems()
    self.loveGems:setString(getlocal("activity_chrisEve_myAllLoveGems",{allLoveGems}))
    if self.version == 5 and self.headPosMiddlePosx then
        self.loveGems:setPositionX(self.headPosMiddlePosx)
    end
end

function acChrisEveTab3:updateAcTime()
    -- local acVo=acChrisEveVoApi:getAcVo()
    -- if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
    --     G_updateActiveTime(acVo,nil,self.timeLb)
    -- end
    if self then
        if self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
            self.timeLb:setString(acChrisEveVoApi:getRewardTimeStr())
            if self.version == 5 and self.headPosMiddlePosx then
                self.timeLb:setPositionX(self.headPosMiddlePosx)
            end
        end
    end
end

function acChrisEveTab3:openInfo( )
    local rankReward,rankrewardNums,rankRewardAllIdx = acChrisEveVoApi:getRankReward()
     -- print("in openInfo~~~~~")
    local td=smallDialog:new()
    local tabStr = {}
    for i=1,rankrewardNums do
        table.insert(tabStr,"\n")
        table.insert(tabStr,rankRewardAllIdx[5-i])
    end
    for i=1,3 do
        table.insert(tabStr,"\n")
        if i ==2 then
            table.insert(tabStr,getlocal("activity_chrisEve_d3_tip"..4-i,{acChrisEveVoApi:getRankPoint( )}))
        else
            table.insert(tabStr,getlocal("activity_chrisEve_d3_tip"..4-i))
        end
    end
    table.insert(tabStr,"\n")
    -- tabStr ={"\n",getlocal("activity_chrisEve_d3_tip3"),"\n",getlocal("activity_chrisEve_d3_tip2"),"\n",getlocal("activity_chrisEve_d3_tip1"),"\n"}
    local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,{nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil})
    sceneGame:addChild(dialog,self.layerNum+1)
end

function acChrisEveTab3:initTableView()
    local function callBack(...)
           return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgWidth-4 ,self.bgHeight*0.65-self.needIphone5Height_1+self.adaH + self.adaH2),nil)
    self.bgLayer:addChild(self.tv,1)
    self.tv:setPosition(ccp(22,120))
    self.tv:setAnchorPoint(ccp(0,0))
    self.tv:setTableViewTouchPriority(-(self.layerNum-1) * 20 - 4)
    self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
    self.tv:setMaxDisToBottomOrTop(120)
end