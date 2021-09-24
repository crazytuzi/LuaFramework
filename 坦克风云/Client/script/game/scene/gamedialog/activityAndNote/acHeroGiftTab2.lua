acHeroGiftTab2 = {}

function acHeroGiftTab2:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
	
	self.normalHeight=80
	
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil

    self.descLb=nil
    self.descLb1=nil
    self.rewardBtn=nil

    return nc
end

function acHeroGiftTab2:init(layerNum)
    self.layerNum=layerNum
    self.bgLayer=CCLayer:create()

    local tipKey,tipKeyInteger = acHeroGiftVoApi:getTipKey( )
    if acHeroGiftVoApi:acIsStop() and tipKeyInteger ~= 2 then
        if acHeroGiftVoApi:isReaward() == false then
            acHeroGiftVoApi:afterExchange()
        end
    end

    self:initLayer()
    self:initTableView()
    
    return self.bgLayer
end
function acHeroGiftTab2:refresh( )
    
    tolua.cast(self.bgLayer:getChildByTag(111),"CCLabelTTF"):setString(getlocal("dailyAnswer_tab1_recentLabelNum",{acHeroGiftVoApi:getScore()}))
    self.tv:reloadData()
end

function acHeroGiftTab2:initTableView(  )
    local height=self.bgLayer:getContentSize().height-280
    local widthSpace=80

    local rankLabel=GetTTFLabel(getlocal("RankScene_rank"),24)
    rankLabel:setPosition(widthSpace,height)
    self.bgLayer:addChild(rankLabel,2)
    rankLabel:setColor(G_ColorYellowPro)
    
    local nameLabel=GetTTFLabel(getlocal("RankScene_name"),24)
    nameLabel:setPosition(widthSpace+150,height)
    self.bgLayer:addChild(nameLabel,2)
    nameLabel:setColor(G_ColorYellowPro)
    
    local levelLabel=GetTTFLabel(getlocal("serverwar_point"),24)
    levelLabel:setPosition(widthSpace+120*2+50,height)
    self.bgLayer:addChild(levelLabel,2)
    levelLabel:setColor(G_ColorYellowPro)

    local powerLabel=GetTTFLabel(getlocal("award"),24)
    powerLabel:setPosition(widthSpace+120*4-10,height)
    self.bgLayer:addChild(powerLabel,2)
    powerLabel:setColor(G_ColorYellowPro)

    self.tvHeight=self.bgLayer:getContentSize().height-340-20
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-60,self.tvHeight-90),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,40+90))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(self.normalHeight)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acHeroGiftTab2:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local num=1
    local playerList=acHeroGiftVoApi:getPlayerList()
    if playerList and SizeOfTable(playerList)>0 then
        num=SizeOfTable(playerList)
    end
    return num
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-70,self.normalHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cellWidht = self.bgLayer:getContentSize().width-70
        local cell=CCTableViewCell:new()
          cell:autorelease()

      local rankList=acHeroGiftVoApi:getPlayerList()
      local rData
      
      local rank--名次
      local name
      local level--积分
      local power--奖励
        
        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick(hd,fn,idx)
        end

        rData=rankList[idx+1] or {}
        rank=idx+1
        name=rData[2] 
        level=rData[3] or 0
        power=rData[6] or 0

        if name ~=nil then
        
            local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
            lineSp:setAnchorPoint(ccp(0,1));
            lineSp:setPosition(ccp(0,self.normalHeight));
            cell:addChild(lineSp,1)

            local lbSize=25
            local lbHeight=35
            local lbWidth=50

            local awardList,typeList = acHeroGiftVoApi:formatAwardList( idx+1 ) or {}

            if SizeOfTable(awardList) and (idx+1)<4 then
                for k,v in pairs(awardList) do
                    local keY,nuM = v.key,v.num
                    local function showHeroInfo1(... ) 
                        self:showHeroInfo(keY,nuM)
                    end 
                    local showAwardIcon = heroVoApi:getHeroIcon(v.key,v.num,false,showHeroInfo1,false,false)
                    showAwardIcon:setScale(0.4)
                    showAwardIcon:setTouchPriority(-(self.layerNum-1)*20-5)
                    showAwardIcon:setAnchorPoint(ccp(1,0.5))
                    showAwardIcon:setPosition(ccp(cellWidht-5-((k-1)*65+15)+30,lbHeight))
                    cell:addChild(showAwardIcon,2)
                end
            end --CommonBox.png SeniorBox.png
            if SizeOfTable(awardList) and (idx+1)>3 then
                    local function showHeroInfo2(... ) 
                        self:showAwardInfo( awardList)
                    end 
                    local showAwardIcon2 = LuaCCScale9Sprite:createWithSpriteFrameName("SeniorBox.png",CCRect(20, 20, 10, 10),showHeroInfo2)
                    showAwardIcon2:setScale(0.6)
                    showAwardIcon2:setTouchPriority(-(self.layerNum-1)*20-5)
                    showAwardIcon2:setAnchorPoint(ccp(1,0.5))
                    showAwardIcon2:setPosition(ccp(cellWidht,lbHeight))
                    cell:addChild(showAwardIcon2,2)                
            end

            local rankLb=GetTTFLabel(rank,lbSize)
            rankLb:setPosition(ccp(lbWidth,lbHeight))
            cell:addChild(rankLb)
            rankLb:setColor(G_ColorYellow)

            local rankSp
            if tonumber(rank)==1 then
                rankSp=CCSprite:createWithSpriteFrameName("top1.png")
            elseif tonumber(rank)==2 then
                rankSp=CCSprite:createWithSpriteFrameName("top2.png")
            elseif tonumber(rank)==3 then
                rankSp=CCSprite:createWithSpriteFrameName("top3.png")
            elseif tonumber(rank)>3 then
                rankSp=GetTTFLabel(tonumber(rank),lbSize)
            end
            if rankSp then
                rankSp:setPosition(ccp(lbWidth,lbHeight))
                cell:addChild(rankSp,2)
                -- rankLb:setVisible(false)
            end

        local nameLb=GetTTFLabel(name,lbSize)
        nameLb:setPosition(ccp(lbWidth+150,lbHeight))
        cell:addChild(nameLb)

        local levelLb=GetTTFLabel(level,lbSize)
        levelLb:setPosition(ccp(lbWidth+120*2+50,lbHeight))
        cell:addChild(levelLb)
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


function acHeroGiftTab2:showAwardInfo( awardList )
    local content = {}
    for k,v in pairs(awardList) do
        local award = v
        local point = v.num
        table.insert(content,{award=award,point=point})
    end
    smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("buyGoldDiscounts6"),content,true,true,self.layerNum+1,nil,nil,nil,false,false,false,nil,false,nil,false,false,true)
end
function acHeroGiftTab2:showHeroInfo( key,num )
    
        local td = acHuoxianmingjiangHeroInfoDialog:new(key,num)
        local dialog = td:init("PanelHeaderPopup.png",self.layerNum+1,CCRect(168, 86, 10, 10),CCSizeMake(600,800),getlocal("report_hero_message"))
        sceneGame:addChild(dialog,self.layerNum+1)

end

function acHeroGiftTab2:initLayer( )
    local innerWidth = G_VisibleSizeWidth - 30
    local innerHeight = G_VisibleSizeHeight-180
    if(G_isIphone5())then
        h = G_VisibleSizeHeight - 100
    end


    local score = acHeroGiftVoApi:getScore()
    local currentIntegral=GetTTFLabel(getlocal("dailyAnswer_tab1_recentLabelNum",{score}),28) --当前积分 需要刷新 需要添加积分的函数VoApi
    currentIntegral:setPosition(ccp(50,innerHeight-10))
    currentIntegral:setAnchorPoint(ccp(0,0.5))
    currentIntegral:setTag(111)
    currentIntegral:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(currentIntegral)

    
    local str2Size = 20
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
        str2Size =28
    end
    local floor = acHeroGiftVoApi:getScoreFloor( )
    local scoreFloor = GetTTFLabelWrap(getlocal("activity_heroGift_scoreLb",{floor}),str2Size,CCSizeMake(innerWidth-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    -- local scoreFloor = GetTTFLabel(getlocal("activity_heroGift_scoreLb",{floor}),str2Size)
    scoreFloor:setPosition(ccp(50,innerHeight -50))
    scoreFloor:setAnchorPoint(ccp(0,0.5))
    scoreFloor:setTag(112)
    scoreFloor:setColor(G_ColorGreen)
    self.bgLayer:addChild(scoreFloor)

    local function touch(tag,object)
        PlayEffect(audioCfg.mouseClick)
        local tabStr = {}
        local tabColor = {}
        -- print("~~~~~~~~~~~~",acHeroGiftVoApi:getAwardListNums())
        local awardList = acHeroGiftVoApi:getAwardList()
        local rewardStrTab={}
        for k,v in pairs(awardList) do
            local award=FormatItem(v[2])
            local str=""
            for m,n in pairs(award) do
                -- print("@@@@@")
                -- G_dayin(v)
                -- print("@@@@@")
                if n.type =="h" then
                    if G_getCurChoseLanguage() ~="ar" then
                        if m==SizeOfTable(award) then
                            str = str ..getlocal("whichStar",{n.num}).. n.name .. " x 1 " 
                        else
                            str = str ..getlocal("whichStar",{n.num}).. n.name .. " x 1 " ..  ","
                        end
                    else
                        if m==SizeOfTable(award) then
                            str = str ..getlocal("whichStar",{n.num}).. n.name .. " x 1 " 
                        else
                            str = str ..getlocal("whichStar",{n.num}).. n.name .. " x 1 " ..  ",\n"
                        end
                    end
                else
                    if m==SizeOfTable(award) then
                        str = str .. n.name .. " x" .. n.num
                    else
                        str = str .. n.name .. " x" .. n.num .. ","
                    end
                end
            end
            rewardStrTab[k]=str
        end

        local tabStr={" ",getlocal("dailyAnswer_rank_tip_4",{rewardStrTab[1],rewardStrTab[2],rewardStrTab[3],rewardStrTab[4],rewardStrTab[5],rewardStrTab[6]}),getlocal("activity_heroGift_tip4"),getlocal("activity_heroGift_tip3")," "}
        local tabColor={}
        -- local dialogLayer=sd:init("TankInforPanel.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,strTab,25,colorTab)




        -- tabStr = {"\n",getlocal("activity_heroGift_tip4"),"\n",getlocal("activity_heroGift_tip3"),"\n"}
        -- tabColor = {nil, nil, nil, nil, nil}
        local td=smallDialog:new()
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
        sceneGame:addChild(dialog,self.layerNum+1)

    end

    local menuItemDesc = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,nil,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,1))
    menuItemDesc:setScale(0.9)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
    menuDesc:setPosition(ccp(innerWidth-20, self.bgLayer:getContentSize().height-180))
    self.bgLayer:addChild(menuDesc)

    ----------------
    local function onClickDesc()
        local isReaward = acHeroGiftVoApi:isReaward( )
        if acHeroGiftVoApi:getedBigAward() ~=nil then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_hadReward"),28)
            do return end 
        end
        if isReaward ==true and acHeroGiftVoApi:acIsStop() ==true then
            self:getBigReward()
        end
    end
    self.bigAwardClick = GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",onClickDesc,nil,getlocal("newGiftsReward"),25,11)
    self.bigAwardClick:setAnchorPoint(ccp(0.5,0.5))
    self.bigAwardClick:setTag(888)
    self.bigAwardClick:setEnabled(false)
    local descBtn=CCMenu:createWithItem(self.bigAwardClick)
    descBtn:setAnchorPoint(ccp(0,0.5))
    descBtn:setPosition(ccp(innerWidth*0.5,80))
    descBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(descBtn,2)
end
function acHeroGiftTab2:getBigReward( )
    local function getRanklist(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            if sData and sData.ranklist  then
                acHeroGiftVoApi:setPlayerList(sData.ranklist)
            end
            self.tab2=acHeroGiftTab2:new()
            self.layer2=self.tab2:init(self.layerNum)
            self.bgLayer:addChild(self.layer2)
            self:refresh(1)
        end

  


    local function getRanklist(fn,data)
        local oldHeroList=heroVoApi:getHeroList()
        local ret,sData = base:checkServerData(data)
        if ret==true then
            if sData.data==nil then 
              return
            end
            -- local scoreSHow = nil
            -- local reward = {}

                -- local content={}
                -- local msgContent = {}
                -- local showStr = nil
                -- local scoreSHow = {}
            if sData.data and sData.data.reward then
                local rewarddd = FormatItem(sData.data.reward)
                for k,v in pairs(rewarddd) do
                    -- for r,t in pairs(v) do
                        -- local jj = {}
                        -- table.insert(jj,v)
                        if v and SizeOfTable(v)~=nil then
                                 -- local award=FormatItem(t) or {}
                            -- local awardTb=FormatItem(v[1]) or {}
                            -- local award=awardTb[1]
                            local award=v
                            local existStr=""
                            if award.type=="h" and award.eType=="h" then
                                local type,heroIsExist,addNum,newProductOrder=heroVoApi:getNewHeroData(award,oldHeroList)
                                if heroIsExist==true then
                                    if heroVoApi:heroHonorIsOpen()==true and  heroVoApi:getIsHonored(award.key)==true then
                                        existStr=","..getlocal("hero_honor_recruit_honored_hero",{addNum})
                                        if addNum and addNum>0 then
                                            local pid=heroCfg.getSkillItem
                                            local id=(tonumber(pid) or tonumber(RemoveFirstChar(pid)))
                                            bagVoApi:addBag(id,addNum)
                                        end
                                    else
                                        if newProductOrder then
                                            existStr=","..getlocal("hero_breakthrough_desc",{newProductOrder})
                                        else
                                            existStr=","..getlocal("alreadyHasDesc",{addNum})
                                        end
                                    end
                                elseif heroIsExist==false then
                                    local vo = heroVo:new()
                                    vo.hid=award.key
                                    vo.level=1
                                    vo.points=0
                                    vo.productOrder=award.num
                                    vo.skill={}
                                    table.insert(oldHeroList,vo)

                                    heroVoApi:getNewHeroChat(award.key)
                                end
                                -- showStr=getlocal("congratulationsGet",{award.name})..existStr
                            else
                                -- showStr=getlocal("congratulationsGet",{award.name .. "*" .. award.num})
                                if award.type=="h" and award.eType=="s" then
                                    local heroid=heroCfg.soul2hero[award.key]
                                    if heroVoApi:heroHonorIsOpen()==true and  heroVoApi:getIsHonored(heroid)==true then
                                        -- existStr=","..getlocal("hero_honor_recruit_honored_hero",{award.num})
                                        -- showStr=showStr..existStr
                                        local addNum=award.num
                                        if addNum and addNum>0 then
                                            local pid=heroCfg.getSkillItem
                                            local id=(tonumber(pid) or tonumber(RemoveFirstChar(pid)))
                                            bagVoApi:addBag(id,addNum)
                                        end
                                    end
                                end
                            end
                            G_addPlayerAward(award.type,award.key,award.id,award.num,nil,true)
                        end
                        acHeroGiftVoApi:afterExchange()

                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("receivereward_received_success"),28)
                    -- end
                end
            end
            -- if SizeOfTable(reward) and scoreSHow then
            --     acHeroGiftVoApi:showHero(reward,oldHeroList,scoreSHow,false,self.layerNum)

            acHeroGiftVoApi:setGetedBigAward( )
        end
    end
    local rankPos = acHeroGiftVoApi:getRank()
    socketHelper:acHeroGiftSending("rankreward",nil,getRanklist,rankPos)    

      end
    socketHelper:acHeroGiftSending("ranklist",nil,getRanklist)
end

function acHeroGiftTab2:tick( )
    -- if acHeroGiftVoApi:isReaward() ==false then
    -- -- elseif 
    -- end
    -- print("ac>>>>???",acHeroGiftVoApi:acIsStop(),acHeroGiftVoApi:isReaward())
    if acHeroGiftVoApi:getedBigAward() then
        self.bigAwardClick:setEnabled(false)
    elseif acHeroGiftVoApi:acIsStop() ==true and acHeroGiftVoApi:isReaward() ==true then
        self.bigAwardClick:setEnabled(true)
        -- acHeroGiftVoApi:updateShow()
    end
end

function acHeroGiftTab2:dispose( )
    self.normalHeight=nil
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
    self.descLb=nil
    self.descLb1=nil
    self.rewardBtn=nil
end