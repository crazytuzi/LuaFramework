
heroRecruitDialog=commonDialog:new()

function heroRecruitDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.expandIdx={}
    self.layerNum=layerNum

    self.recruitItem1=nil
    self.recruitItem2=nil
    self.recruitItem3=nil
    self.leftTimeLb1=nil
    self.leftTimeLb2=nil
    self.numLb1=nil
    self.numLb2=nil
    self.tipDescSp1=nil
    self.tipDescSp2=nil
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/heroRecruitImage.plist")

    self.tenCountsLb1=nil
    self.tenCountsLb2=nil
    return nc
end

--设置或修改每个Tab页签
function heroRecruitDialog:resetTab()

    local index=0
    local tabHeight=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
         tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
         elseif index==1 then
         tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+23+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
         elseif index==2 then
         tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)

         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
end

--设置对话框里的tableView
function heroRecruitDialog:initTableView()

    -- local dataKey="hero_1TimeNow@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)-- upperTen_small
    -- local timeNow1 = tonumber(CCUserDefault:sharedUserDefault():getStringForKey(dataKey))
    -- if timeNow1 ==nil then
    --     timeNow1=G_getWeeTs(base.serverTime)
    -- end
    -- local dataKey="hero_2TimeNow@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)-- upperTen_small
    -- local timeNow2 = tonumber(CCUserDefault:sharedUserDefault():getStringForKey(dataKey))
    -- if timeNow2 ==nil then
    --     timeNow2=G_getWeeTs(base.serverTime)
    -- end

    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height/2-36))
    self:initBgLayer()



    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-30,self.bgLayer:getContentSize().height-370+35),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(15,30))
    self.bgLayer:addChild(self.tv,1)

    self.tv:setMaxDisToBottomOrTop(200)
end


function heroRecruitDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 3
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        local adaptCellSize = 270
        if G_getIphoneType() == G_iphoneX then
            adaptCellSize = 320
        end
        tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-30,adaptCellSize)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local index=idx+1


        
        local cellWidth=self.bgLayer:getContentSize().width-30
        local cellHeight=270

        local lbSize=24
        local addHeight=0
        local reY = 60

        if G_getIphoneType() == G_iphoneX then
            cellHeight = 320
        end

        local function touch( ... )
        
        end
        local descBg =LuaCCScale9Sprite:createWithSpriteFrameName("RankItemBg.png",CCRect(40, 40, 10, 10),touch)
        descBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-30,200+addHeight))
        descBg:setAnchorPoint(ccp(0.5,1))
        descBg:setPosition(ccp(cellWidth/2,cellHeight-reY))
        cell:addChild(descBg,1)
        local eLbSize=16
        if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
            eLbSize = 24
        elseif not G_isIOS() then
            eLbSize = 14
        end
        local tabStr=""
        if idx==0 then
            tabStr=getlocal("commonRecruit")
            -- if G_getBHVersion()==2 then
                -- tabStr=getlocal("newcommonRecruit")
            if(base.hexieMode==1)then
                tabStr=getlocal("newfreeTimes")
            end
        elseif idx==1 then
            tabStr=getlocal("eliteRecruit")
            -- if G_getBHVersion()==2 then
            if(base.hexieMode==1)then
                tabStr=getlocal("neweliteRecruit")
            end
        else
            tabStr=getlocal("continuousRecruit")
            -- if G_getBHVersion()==2 then
            if(base.hexieMode==1)then
                tabStr=getlocal("newcontinuousRecruit")
            end

        end
        local titleItem=GetButtonItem("RankBtnTab_Down.png", "RankBtnTab_Down.png","RankBtnTab_Down.png",touch,1,tabStr,eLbSize,101)
        local btnLb = titleItem:getChildByTag(101)
        if btnLb then
            btnLb = tolua.cast(btnLb,"CCLabelTTF")
            btnLb:setFontName("Helvetica-bold")
        end
        local recruitMenu=CCMenu:createWithItem(titleItem)
        recruitMenu:setPosition(ccp(titleItem:getContentSize().width/2,descBg:getContentSize().height+titleItem:getContentSize().height/2))
        recruitMenu:setTouchPriority(-(self.layerNum-1)*20-1)
        descBg:addChild(recruitMenu,3)

        if G_getBHVersion() ==2 then
            if idx ==1 then
                local dataKey="playeridx1@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)-- upperTen_small
                local coutNums = tonumber(CCUserDefault:sharedUserDefault():getStringForKey(dataKey))

                if coutNums ==nil or tonumber(coutNums)<1 then
                    coutNums =0
                end
                 self.tenCountsLb1 = GetTTFLabelWrap(getlocal("dailyTenCounts",{coutNums}),17,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                self.tenCountsLb1:setAnchorPoint(ccp(0,0.5))
                self.tenCountsLb1:setPosition(ccp(titleItem:getContentSize().width*0.9+50,descBg:getContentSize().height+titleItem:getContentSize().height/2))
                descBg:addChild(self.tenCountsLb1,2)
                if playerVoApi:getPlayerLevel()>15 and base.isCheckVersion ==0 then
                    self.tenCountsLb1:setVisible(false)
                end 

            elseif idx ==2  then
                local dataKey="playeridx2@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)-- upperTen_small
                local coutNums = tonumber(CCUserDefault:sharedUserDefault():getStringForKey(dataKey))

                if coutNums ==nil or tonumber(coutNums)<1 then
                    coutNums =0
                end
                 self.tenCountsLb2 = GetTTFLabelWrap(getlocal("dailyTenCounts",{coutNums}),17,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                self.tenCountsLb2:setAnchorPoint(ccp(0,0.5))
                self.tenCountsLb2:setPosition(ccp(titleItem:getContentSize().width*0.9+50,descBg:getContentSize().height+titleItem:getContentSize().height/2))
                descBg:addChild(self.tenCountsLb2,2)
                if playerVoApi:getPlayerLevel()>15 and base.isCheckVersion ==0 then
                    self.tenCountsLb2:setVisible(false)
                end 

            end
        end
        if idx==0 or idx==1 then
            local tipSpace=30
            local tipDescSp =LuaCCScale9Sprite:createWithSpriteFrameName("recruitDialog.png",CCRect(70, 50, 5, 5),touch)
            tipDescSp:setContentSize(CCSizeMake((descBg:getContentSize().width-titleItem:getContentSize().width)-tipSpace*2,80))
            tipDescSp:setAnchorPoint(ccp(0,0))
            tipDescSp:setPosition(ccp(titleItem:getContentSize().width+tipSpace,descBg:getContentSize().height-20))
            descBg:addChild(tipDescSp,3)

            local hid
            local productOrder
            if idx==0 then
                hid=heroCfg.left[1]
                productOrder=heroCfg.left[2]
            elseif idx==1 then
                hid=heroCfg.right[1]
                productOrder=heroCfg.right[2]
            end
            local nameStr=getlocal(heroListCfg[hid].heroName)
            -- local firstDescLb=GetTTFLabelWrap(str1,lbSize,CCSizeMake(tipDescSp:getContentSize().width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            local firstDescLb=GetTTFLabelWrap(getlocal("firstRecruitDesc",{nameStr}),lbSize,CCSizeMake(tipDescSp:getContentSize().width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
            firstDescLb:setPosition(ccp(tipDescSp:getContentSize().width/2,tipDescSp:getContentSize().height-25))
            tipDescSp:addChild(firstDescLb)
            firstDescLb:setColor(G_ColorYellowPro)
            if heroVoApi:getHeroGuide(idx+1)==0 then
                tipDescSp:setVisible(true)
            else
                tipDescSp:setVisible(false)
            end
        end

        local capInSet = CCRect(20, 20, 10, 10)
        -- local timeBg1 =LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",capInSet,touch)
        -- timeBg1:setContentSize(CCSizeMake(descBg:getContentSize().width,50))
        -- timeBg1:ignoreAnchorPointForPosition(false)
        -- timeBg1:setAnchorPoint(ccp(0,0))
        -- timeBg1:setIsSallow(false)
        -- timeBg1:setTouchPriority(-(self.layerNum-1)*20-1)
        -- timeBg1:setPosition(ccp(0,0))
        -- descBg:addChild(timeBg1)

        local spriteIcon=CCSprite:createWithSpriteFrameName("heroRecruitBox"..index..".png")
        local heroSp
        if idx==0 then
            local iconImageStr = "commonRecruitIcon.png"
            if G_getBHVersion()==2 then
                iconImageStr ="SpecialBox.png"
            end
            heroSp=CCSprite:createWithSpriteFrameName(iconImageStr)
        elseif idx==1 then
            local iconImageStr = "eliteRecruitIcon.png"
            if G_getBHVersion()==2 then
                iconImageStr ="expBook2.png"
            end
            heroSp=CCSprite:createWithSpriteFrameName(iconImageStr)
        else
            local iconImageStr = "continuousDraw.png"
            if G_getBHVersion()==2 then
                iconImageStr ="expBook3.png"
            end
            heroSp=CCSprite:createWithSpriteFrameName(iconImageStr)
        end
        heroSp:addChild(spriteIcon)
        spriteIcon:setPosition(getCenterPoint(heroSp))
        heroSp:setAnchorPoint(ccp(0,0.5))
        heroSp:setPosition(10,(descBg:getContentSize().height)/2)
        descBg:addChild(heroSp,2)


        local lbXPos=spriteIcon:getContentSize().width+15+(descBg:getContentSize().width-spriteIcon:getContentSize().width-30)/2
        local numStr=""
        local color=G_ColorYellowPro

        local goldSize=36
        local goldIcon
        if idx==0 then
            local num=heroCfg.freeTicketLimit-(heroVoApi:getHeroInfo().commonLotteryNum or 0)
            -- numStr=getlocal("freeTimes")..":"..num.."/"..heroCfg.freeTicketLimit
            numStr=getlocal("scheduleChapter",{num,heroCfg.freeTicketLimit})
            if num==0 and heroVoApi:getHeroGuide(1)~=0 then
                color=G_ColorRed
            end
        else
            if idx==1 then
                numStr=heroCfg.payTicketCost
                if playerVoApi:getGems()<heroCfg.payTicketCost then
                    color=G_ColorRed
                end

            else
                numStr=heroCfg.payTicketTenCost
                if playerVoApi:getGems()<heroCfg.payTicketTenCost then
                    color=G_ColorRed
                end
            end
            goldIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
            goldIcon:setScale(goldSize/goldIcon:getContentSize().width)
            -- descBg2:addChild(goldIcon)
        end



        local btnScale=1
        local function recruitHandler()
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)

                if idx==0 then
                    local function lotteryCallback(fn,data)
                        local oldHeroList=heroVoApi:getHeroList()
                        local ret,sData=base:checkServerData(data)
                        if ret==true then
                            self:refresh()
                            if sData.data.reward then
                                self:showHero(sData.data.reward,oldHeroList)
                            end
                        end
                    end

                    local function addheroCallback(fn,data)
                        local oldHeroList=heroVoApi:getHeroList()
                        local ret,sData=base:checkServerData(data)
                        if ret==true then
                            --bagVoApi:addBag(446,1)
                            heroVoApi:setHeroGuide(1,1)
                            self:refresh()
                            local reward={h={}}
                            reward.h[heroCfg.left[1]]=heroCfg.left[2]
                            self:showHero(reward,oldHeroList)
                            G_removeFlicker(self.recruitItem1)
                            -- freeLb:setVisible(true)
                            -- self.numLb1:setVisible(true)
                        end
                    end

                    if heroVoApi:getHeroGuide(1)==0 then
                        socketHelper:heroAddhero(1,addheroCallback)
                    else
                        socketHelper:heroLottery(1,nil,lotteryCallback)
                    end
                elseif idx==1 then
                    local dataKey="playeridx1@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
                    local coutNums1 =tonumber(CCUserDefault:sharedUserDefault():getStringForKey(dataKey))
                    if G_getBHVersion()==2 and base.isCheckVersion == 1 and coutNums1~=nil and coutNums1 >=10 then
                        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("upperTen"),nil,self.layerNum+1)
                        do return end 
                    end                   
                    local function callback(fn,data)
                        local oldHeroList=heroVoApi:getHeroList()
                        local oldIsFree=heroVoApi:isFreeAdvancedLottery()
                        local ret,sData=base:checkServerData(data)
                        if ret==true then
                            -- if G_getBHVersion()==2 then
                            if(base.hexieMode==1)then
                                -- bagVoApi:addBag(447,1)
                                -- print("11111")
                                local award=FormatItem(heroCfg.mustReward1.reward)
                                for k,v in pairs(award) do
                                    G_addPlayerAward(v.type,v.key,v.id,v.num)
                                end
                                G_showRewardTip(award, true)
                            end
                            --bagVoApi:addBag(447,1)
                            if oldIsFree~=0 then
                                playerVoApi:setGems(playerVoApi:getGems()-heroCfg.payTicketCost)
                            end
                            self:refresh()
                            if sData.data.reward then
                                self:showHero(sData.data.reward,oldHeroList)
                            end

                            if G_getBHVersion()==2 then

                                local dataKeys="hero_1TimeNow@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
                                local timeNow1 =base.serverTime
                                CCUserDefault:sharedUserDefault():setStringForKey(dataKeys,tostring(timeNow1))
                                CCUserDefault:sharedUserDefault():flush()

                                local dataKey="playeridx1@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
                                local coutNums1 =tonumber(CCUserDefault:sharedUserDefault():getStringForKey(dataKey))
                                if coutNums1~=nil and coutNums1 <10 then
                                    coutNums1 =coutNums1+1
                                end
                                if coutNums1==nil then
                                    coutNums1=0
                                end
                                if self.tenCountsLb1 then
                                    self.tenCountsLb1:setString(getlocal("dailyTenCounts",{coutNums1}))
                                end
                                CCUserDefault:sharedUserDefault():setStringForKey(dataKey,tostring(coutNums1))
                                CCUserDefault:sharedUserDefault():flush()                                   
                            end
                        end
                    end
                    local function addheroCallback(fn,data)
                        local oldHeroList=heroVoApi:getHeroList()
                        local ret,sData=base:checkServerData(data)
                        if ret==true then
                            -- if G_getBHVersion()==2 then
                            --     bagVoApi:addBag(447,1)
                            if(base.hexieMode==1)then
                                local award=FormatItem(heroCfg.mustReward1.reward)
                                for k,v in pairs(award) do
                                    G_addPlayerAward(v.type,v.key,v.id,v.num)
                                end
                                G_showRewardTip(award, true)
                                -- print("22222")
                            end
                            heroVoApi:setHeroGuide(2,1)
                            self:refresh()
                            local reward={h={}}
                            reward.h[heroCfg.right[1]]=heroCfg.right[2]
                            self:showHero(reward,oldHeroList)  
                            G_removeFlicker(self.recruitItem2) 
                            self.numLb2:setVisible(true)
                            goldIcon:setVisible(true)             
                        end
                    end
                    if heroVoApi:getHeroGuide(2)==0 then
                        socketHelper:heroAddhero(2,addheroCallback)
                    else
                        if heroVoApi:isFreeAdvancedLottery()==0 then
                            socketHelper:heroLottery(2,1,callback)
                        else
                            if playerVoApi:getGems()<heroCfg.payTicketCost then 
                                GemsNotEnoughDialog(nil,nil,heroCfg.payTicketCost-playerVoApi:getGems(),self.layerNum+1,heroCfg.payTicketCost)
                                do
                                    return
                                end
                            end
                            
                            local function onConfirm()
                                socketHelper:heroLottery(2,nil,callback)
                            end
                            local str = getlocal("eliteRecruitCostGold",{heroCfg.payTicketCost})
                            if G_getBHVersion()==2 then
                               str = getlocal("neweliteRecruitCostGold",{heroCfg.payTicketCost})
                            end
                            
                            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),str,nil,self.layerNum+1)
                        end
                    end
                else
                    local dataKey="playeridx2@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
                    local coutNums2 =tonumber(CCUserDefault:sharedUserDefault():getStringForKey(dataKey))
                    if G_getBHVersion()==2 and base.isCheckVersion == 1 and coutNums2~=nil and coutNums2 >=10 then
                        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("upperTen"),nil,self.layerNum+1)
                        do return end 
                    end 
                    local function callback3(fn,data)                        
                        local oldHeroList3=heroVoApi:getHeroList()
                        local ret,sData=base:checkServerData(data)
                        if ret==true then
                            playerVoApi:setGems(playerVoApi:getGems()-heroCfg.payTicketTenCost)
                            -- if G_getBHVersion()==2 then
                            --     bagVoApi:addBag(448,2)
                            if(base.hexieMode==1)then
                                local award=FormatItem(heroCfg.mustReward1.reward)
                                for k,v in pairs(award) do
                                    v.num=v.num*10
                                    G_addPlayerAward(v.type,v.key,v.id,v.num)
                                end
                                G_showRewardTip(award, true)
                            end
                            self:refresh()

                            if sData.data.hero and sData.data.hero.report and self and self.bgLayer then
                                local content={}
                                local msgContent={}
                                local report=sData.data.hero.report or {}
                                for k,v in pairs(report) do
                                    local awardTb=FormatItem(v[1]) or {}
                                    local award=awardTb[1]

                                    local showStr=""
                                    local existStr=""
                                    if award.type=="h" and award.eType=="h" then
                                        local type,heroIsExist,addNum,newProductOrder=heroVoApi:getNewHeroData(award,oldHeroList3)
                                        if heroIsExist==true then
                                            if heroVoApi:heroHonorIsOpen()==true and heroVoApi:getIsHonored(award.key)==true then
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
                                            table.insert(oldHeroList3,vo)

                                            heroVoApi:getNewHeroChat(award.key)
                                        end
                                        showStr=getlocal("congratulationsGet",{award.name})..existStr

                                        -- heroVoApi:getNewHeroChat(award.key)
                                    else
                                        showStr=getlocal("congratulationsGet",{award.name .. "*" .. award.num})
                                        if award.type=="h" and award.eType=="s" then
                                            local heroid=heroCfg.soul2hero[award.key]
                                            if heroVoApi:heroHonorIsOpen()==true and  heroVoApi:getIsHonored(heroid)==true then
                                                existStr=","..getlocal("hero_honor_recruit_honored_hero",{award.num})
                                                showStr=showStr..existStr
                                                local addNum=award.num
                                                if addNum and addNum>0 then
                                                    local pid=heroCfg.getSkillItem
                                                    local id=(tonumber(pid) or tonumber(RemoveFirstChar(pid)))
                                                    bagVoApi:addBag(id,addNum)
                                                end
                                            end
                                        end
                                    end
                                    table.insert(msgContent,showStr)
                                    table.insert(content,{award=award,point=0,index=k})

                                    G_addPlayerAward(award.type,award.key,award.id,award.num,nil,true)
                                end

                                if content and SizeOfTable(content)>0 then
                                    local function confirmHandler(awardIdx)
                                    end
                                    smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("heroRecruitTotal"),content,nil,true,self.layerNum+1,confirmHandler,true,true,nil,nil,nil,msgContent)
                                end
                            end
                            if G_getBHVersion()==2 then
                                local dataKeys="hero_2TimeNow@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
                                local timeNow2 =base.serverTime
                                CCUserDefault:sharedUserDefault():setStringForKey(dataKeys,tostring(timeNow2))
                                CCUserDefault:sharedUserDefault():flush()

                                local dataKey="playeridx2@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
                                local coutNums2 =tonumber(CCUserDefault:sharedUserDefault():getStringForKey(dataKey))
                                if coutNums2~=nil and coutNums2 <10 then
                                    coutNums2 =coutNums2+1
                                end
                                if coutNums2==nil then
                                    coutNums2=0
                                end
                                if self.tenCountsLb2 then
                                    self.tenCountsLb2:setString(getlocal("dailyTenCounts",{coutNums2}))
                                end
                                CCUserDefault:sharedUserDefault():setStringForKey(dataKey,tostring(coutNums2))
                                CCUserDefault:sharedUserDefault():flush()  
                            end                                 

                        end
                    end

                    if playerVoApi:getGems()<heroCfg.payTicketTenCost then 
                        GemsNotEnoughDialog(nil,nil,heroCfg.payTicketTenCost-playerVoApi:getGems(),self.layerNum+1,heroCfg.payTicketTenCost)
                        do
                            return
                        end
                    end
                    local function onConfirm()
                        socketHelper:heroTenlottery(callback3)
                    end
                    local str = getlocal("eliteRecruitCostGold",{heroCfg.payTicketTenCost})
                    if G_getBHVersion()==2 then
                       str = getlocal("neweliteRecruitCostGold",{heroCfg.payTicketTenCost})
                    end
                    smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),str,nil,self.layerNum+1)
                end
            end
        end
        self["recruitItem"..index]=nil
        local strSize2 = 20
        local strSize3 = 20
        local strSize4 = 20
        if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
            strSize4 = 24
        elseif G_getCurChoseLanguage() =="ru" then
                strSize2 =17
                strSize3 =15
        end
        if index==1 then
            local str = getlocal("freeTimes")
            -- if G_getBHVersion()==2 then
            if(base.hexieMode==1)then
                str = getlocal("newfreeTimes")
            end
            self["recruitItem"..index]=GetButtonItem("heroRecruitBtn1.png","heroRecruitBtn1Down.png","heroRecruitBtn1Down.png",recruitHandler,2,str,strSize4/btnScale,11)
        elseif index==2 then
            local str = getlocal("recruit")
            -- if G_getBHVersion()==2 then
            if(base.hexieMode==1)then
                str=getlocal("buy")
            end
            self["recruitItem"..index]=GetButtonItem("heroRecruitBtn2.png","heroRecruitBtn2Down.png","heroRecruitBtn2Down.png",recruitHandler,2,str,strSize4/btnScale,11)
        else
            local tabStr=getlocal("continuousRecruit")
            -- if G_getBHVersion()==2 then
            if(base.hexieMode==1)then
                tabStr=getlocal("newcontinuousRecruit")
            end
            if G_getCurChoseLanguage() == "de" then
                strSize4 = 15
            end
            self["recruitItem"..index]=GetButtonItem("heroRecruitBtn2.png","heroRecruitBtn2Down.png","heroRecruitBtn2Down.png",recruitHandler,2,tabStr,strSize4/btnScale,11)
        end
        self["recruitItem"..index]:setScale(btnScale)
        local btnLb = self["recruitItem"..index]:getChildByTag(11)
        if btnLb then
            btnLb = tolua.cast(btnLb,"CCLabelTTF")
            btnLb:setFontName("Helvetica-bold")
        end
        local recruitMenu=CCMenu:createWithItem(self["recruitItem"..index])
        recruitMenu:setPosition(ccp(cellWidth-self["recruitItem"..index]:getContentSize().width/2*btnScale-20,self["recruitItem"..index]:getContentSize().height/2*btnScale+10))
        recruitMenu:setTouchPriority(-(self.layerNum-1)*20-2)
        descBg:addChild(recruitMenu)

        self["freeTipSp"..index]=nil
        if index==1 or index==2 then
            local recruitItem=self["recruitItem"..index]
            if recruitItem then
                local freeTipSp=G_createTipSp(recruitItem)
                self["freeTipSp"..index]=freeTipSp
            end
        end

        local lb=tolua.cast(self["recruitItem"..index]:getChildByTag(11),"CCLabelTTF")
        lb:setPosition(ccp(self["recruitItem"..index]:getContentSize().width*btnScale*(1-1/8*5/2),self["recruitItem"..index]:getContentSize().height/2*btnScale))
        if index==1 then
            if heroVoApi:getHeroGuide(1)==0 then
                G_addRectFlicker(self.recruitItem1, 4.4, 0.8)
                -- self.numLb1:setVisible(false)
            end
        elseif index==2 then
            if heroVoApi:getHeroGuide(2)==0 then
                local str = getlocal("freeTimes")
                -- if G_getBHVersion()==2 then
                if(base.hexieMode==1)then
                    str = getlocal("newfreeTimes")
                end

                lb:setString(str)
                G_addRectFlicker(self.recruitItem2, 4.4, 0.8)
                -- self.numLb2:setVisible(false)
                -- goldIcon:setVisible(false)
                local freeTipSp=self["freeSp"..index]
                if freeTipSp then
                    freeTipSp:setVisible(true)
                end
            end
        end

        self["numLb"..index]=nil
        self["numLb"..index]=GetTTFLabel(numStr,lbSize)
        self["recruitItem"..index]:addChild(self["numLb"..index])
        self["numLb"..index]:setColor(color)

        local mPos=self["recruitItem"..index]:getContentSize().width*btnScale*(3/8/2)-5
        local mHeight=self["recruitItem"..index]:getContentSize().height/2*btnScale
        if goldIcon then
            goldIcon:setPosition(ccp(mPos-22,mHeight))
            self["recruitItem"..index]:addChild(goldIcon)
            self["numLb"..index]:setPosition(ccp(mPos+12,mHeight))
        else
            self["numLb"..index]:setPosition(ccp(mPos,mHeight))
        end
        


        if index<=2 then
            self["leftTimeLb"..index]=nil
            -- self["leftTimeLb"..index]=GetTTFLabelWrap(str2,lbSize,CCSizeMake(descBg:getContentSize().width-spriteIcon:getContentSize().width-40,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
            self["leftTimeLb"..index]=GetTTFLabelWrap(getlocal("leftTime",{1}),lbSize-4,CCSizeMake(descBg:getContentSize().width-spriteIcon:getContentSize().width-40,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
            self["leftTimeLb"..index]:setAnchorPoint(ccp(1,0.5))
            self["leftTimeLb"..index]:setPosition(ccp(descBg:getContentSize().width-20,descBg:getContentSize().height-22))
            descBg:addChild(self["leftTimeLb"..index])
            self["leftTimeLb"..index]:setColor(G_ColorYellowPro)

            local lineSp =CCSprite:createWithSpriteFrameName("heroRecruitLine.png");
            lineSp:setAnchorPoint(ccp(1,0.5))
            -- lineSp:setScaleX(1000/lineSp:getContentSize().width)
            lineSp:setScaleX((descBg:getContentSize().width-spriteIcon:getContentSize().width-10)/lineSp:getContentSize().width)
            lineSp:setPosition(ccp(descBg:getContentSize().width-10,descBg:getContentSize().height-44))
            descBg:addChild(lineSp,2)
        end

        -- local desLabel=GetTTFLabelWrap(str1,20,CCSizeMake(descBg:getContentSize().width-spriteIcon:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)en
        local descStr=""
        if idx==0 then
            descStr=getlocal("commonRecruitDesc")
            -- if G_getBHVersion()==2 then
            if(base.hexieMode==1)then
                descStr=getlocal("newcommonRecruitDesc")
            end

        elseif idx==1 then
            descStr=getlocal("eliteRecruitDesc")
            -- if G_getBHVersion()==2 then
            if(base.hexieMode==1)then
                descStr=getlocal("neweliteRecruitDesc")
            end

        else
            descStr=getlocal("continueRecruitDesc")
            -- if G_getBHVersion()==2 then
            if(base.hexieMode==1)then
                descStr=getlocal("newcontinueRecruitDesc")
            end

        end
        local desLabel=GetTTFLabelWrap(descStr,20,CCSizeMake(descBg:getContentSize().width-spriteIcon:getContentSize().width-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        desLabel:setAnchorPoint(ccp(0.5,0.5))
        desLabel:setPosition(ccp(lbXPos,(descBg:getContentSize().height-44-self["recruitItem"..index]:getContentSize().height*btnScale-10)/2+self["recruitItem"..index]:getContentSize().height*btnScale+10))
        descBg:addChild(desLabel)
        -- desLabel:setColor(G_ColorYellowPro)

        if idx==2 then
            self:tick()
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


function heroRecruitDialog:initBgLayer()
    -- local str1="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    -- str1=str1.."啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    -- local str2="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    local function touch( ... )
      
    end
    local wSacle=0.70
    local descBg =LuaCCScale9Sprite:createWithSpriteFrameName("RankItemBg.png",CCRect(40, 40, 10, 10),touch)
    descBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-30,150))
    descBg:setAnchorPoint(ccp(0.5,1))
    descBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-130-15))
    self.bgLayer:addChild(descBg,1)
    local womanSp=CCSprite:createWithSpriteFrameName("GuideCharacter.png")
    womanSp:setAnchorPoint(ccp(0,0))
    womanSp:setPosition(ccp(5,10))
    womanSp:setScale(wSacle)
    descBg:addChild(womanSp)

    -- local desTv, desLabel = G_LabelTableView(CCSizeMake(descBg:getContentSize().width-womanSp:getContentSize().width*wSacle-20,descBg:getContentSize().height-10),str1,25,kCCTextAlignmentLeft)
    local desTv, desLabel = G_LabelTableView(CCSizeMake(descBg:getContentSize().width-womanSp:getContentSize().width*wSacle-20,descBg:getContentSize().height-20),getlocal("activityWillOpen"),24,kCCTextAlignmentLeft)
    descBg:addChild(desTv)
    desTv:setPosition(ccp(womanSp:getContentSize().width*wSacle+10,10))
    desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    desTv:setMaxDisToBottomOrTop(200)
    desLabel:setColor(G_ColorYellowPro)
end

--展示英雄动画
function heroRecruitDialog:showHero(reward,oldHeroList)
    if reward then
        local rewardTb=FormatItem(reward)
        local award=rewardTb[1]
        if award then
            if award.type=="h" then
                local type,heroIsExist,addNum,newProductOrder=heroVoApi:getNewHeroData(award,oldHeroList)
                G_recruitShowHero(type,award,self.layerNum+1,heroIsExist,addNum,nil,newProductOrder)

                if award.eType=="h" and heroIsExist==false then
                    heroVoApi:getNewHeroChat(award.key)
                end

                if heroVoApi:heroHonorIsOpen()==true then
                    local hid
                    if award.eType=="h" then 
                        hid=award.key
                    elseif award.eType=="s" then
                        hid=heroCfg.soul2hero[award.key]
                    end 
                    if hid and heroVoApi:getIsHonored(hid)==true then
                        local pid=heroCfg.getSkillItem
                        local id=(tonumber(pid) or tonumber(RemoveFirstChar(pid)))
                        bagVoApi:addBag(id,addNum)
                    end
                end
            else
                G_addPlayerAward(award.type,award.key,award.id,award.num,false,true)
                G_recruitShowHero(3,award,self.layerNum+1,nil,nil,nil)
            end
        end
    end
end


--点击tab页签 idx:索引
function heroRecruitDialog:tabClick(idx)
        if newGuidMgr:isNewGuiding() then --新手引导
              if newGuidMgr.curStep==39 and idx~=1 then
                    do
                        return
                    end
              end
        end
        PlayEffect(audioCfg.mouseClick)
        
        for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            self:tabClickColor(idx)
            self:doUserHandler()
            self:getDataByType(idx)
            
         else
            v:setEnabled(true)
         end
    end

    self:resetForbidLayer()
end

--用户处理特殊需求,没有可以不写此方法
function heroRecruitDialog:doUserHandler()

end


function heroRecruitDialog:refresh()
    if self then
        if self.tv then
            local recordPoint = self.tv:getRecordPoint()
            self.tv:reloadData()
            self.tv:recoverToRecordPoint(recordPoint)
        end
    end
end

function heroRecruitDialog:awardConditions()
    local isCanLottery,timeStr=heroVoApi:isCanCommonLottery()
    if isCanLottery==0 or heroVoApi:getHeroGuide(1)==0 then
        if self.recruitItem1 then
            self.recruitItem1:setEnabled(true)
            if self.freeTipSp1 then
                self.freeTipSp1:setVisible(true)
            end
        end
        if self.leftTimeLb1 then
            local str = getlocal("freeRecruit")
            if G_getBHVersion()==2 then
                str=getlocal("newfreeRecruit")
            end
            self.leftTimeLb1:setString(str)
        end
    else
        if self.recruitItem1 then
            self.recruitItem1:setEnabled(false)
            if self.freeTipSp1 then
                self.freeTipSp1:setVisible(false)
            end
        end
        if self.leftTimeLb1 then
            if isCanLottery==1 then
                self.leftTimeLb1:setString(getlocal("todayNumCost"))
            elseif timeStr then
                self.leftTimeLb1:setString(getlocal("leftTime",{timeStr}))
            end
        end
    end
    if self.numLb1 then
        local num=heroCfg.freeTicketLimit-(heroVoApi:getHeroInfo().commonLotteryNum or 0)
        -- local numStr = getlocal("freeTimes")..":"..num.."/"..heroCfg.freeTicketLimit
        local numStr=getlocal("scheduleChapter",{num,heroCfg.freeTicketLimit})
        self.numLb1:setString(numStr)
        if num==0 then
            if self.numLb1:getColor()~=G_ColorRed then
                self.numLb1:setColor(G_ColorRed)
            end
        else
            if self.numLb1:getColor()~=G_ColorYellowPro then
                self.numLb1:setColor(G_ColorYellowPro)
            end
        end
    end

    if self.leftTimeLb2 then
        local isFree,timeStr2=heroVoApi:isFreeAdvancedLottery()
        if isFree==0 or heroVoApi:getHeroGuide(2)==0 then
            local str = getlocal("freeRecruit")
            if G_getBHVersion()==2 then
                str=getlocal("newfreeRecruit")
            end
            self.leftTimeLb2:setString(str)
            if self.recruitItem2 then
                local str = getlocal("freeTimes")
                if G_getBHVersion()==2 then
                    str = getlocal("newfreeTimes")
                end
                local lb=tolua.cast(self.recruitItem2:getChildByTag(11),"CCLabelTTF")
                lb:setString(str)
            end
            if self.freeTipSp2 then
                self.freeTipSp2:setVisible(true)
            end
        elseif timeStr2 then
            self.leftTimeLb2:setString(getlocal("leftTime",{timeStr2}))
            if self.recruitItem2 then
                local lb=tolua.cast(self.recruitItem2:getChildByTag(11),"CCLabelTTF")
                lb:setString(getlocal("recruit"))
                -- if G_getBHVersion()==2 then
                if(base.hexieMode==1)then
                    local str=getlocal("buy")
                    lb:setString(str)
                end
            end
            if self.freeTipSp2 then
                self.freeTipSp2:setVisible(false)
            end
        end
    end

    -- self.leftTimeLb1:setString("啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊")

    -- if self.numLb2 then
    --     if playerVoApi:getGems()<heroCfg.payTicketCost then
    --         if self.numLb2:getColor()~=G_ColorRed then
    --             self.numLb2:setColor(G_ColorRed)
    --         end
    --     else
    --         if self.numLb2:getColor()~=G_ColorYellowPro then
    --             self.numLb2:setColor(G_ColorYellowPro)
    --         end
    --     end
    -- end

    -- if self.numLb3 then
    --     if playerVoApi:getGems()<heroCfg.payTicketTenCost then
    --         if self.numLb3:getColor()~=G_ColorRed then
    --             self.numLb3:setColor(G_ColorRed)
    --         end
    --     else
    --         if self.numLb3:getColor()~=G_ColorYellowPro then
    --             self.numLb3:setColor(G_ColorYellowPro)
    --         end
    --     end
    -- end

end

function heroRecruitDialog:tipUpdate()
    -- if self.tipDescSp1 then
    --     if heroVoApi:getHeroGuide(1)==0 then
    --         if self.tipDescSp1:isVisible()==false then
    --             self.tipDescSp1:setVisible(true)
    --         end
    --     else
    --         if self.tipDescSp1:isVisible()==true then
    --             self.tipDescSp1:setVisible(false)
    --         end
    --     end
    -- end
    -- if self.tipDescSp2 then
    --     if heroVoApi:getHeroGuide(2)==0 then
    --         if self.tipDescSp2:isVisible()==false then
    --             self.tipDescSp2:setVisible(true)
    --         end
    --     else
    --         if self.tipDescSp2:isVisible()==true then
    --             self.tipDescSp2:setVisible(false)
    --         end
    --     end
    -- end
end

function heroRecruitDialog:tick()
    if G_getBHVersion()==2 then
        local dataKey="hero_1TimeNow@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)-- upperTen_small
        local timeNow1 = tonumber(CCUserDefault:sharedUserDefault():getStringForKey(dataKey))
        if timeNow1 ==nil then
            timeNow1=0
        end
        --if self.tenCountsLb1 then
            if G_isToday(timeNow1)==false then

                local coutNums1 =0
                if self.tenCountsLb1 then
                    self.tenCountsLb1:setString(getlocal("dailyTenCounts",{coutNums1}))
                end
                local dataKey="playeridx1@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
                CCUserDefault:sharedUserDefault():setStringForKey(dataKey,tostring(coutNums1))
                CCUserDefault:sharedUserDefault():flush()
            else
                local dataKey="playeridx1@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
                local coutNums1=CCUserDefault:sharedUserDefault():getStringForKey(dataKey)
                if coutNums1=="" then
                    coutNums1=0
                end
                if self.tenCountsLb1 then
                    self.tenCountsLb1:setString(getlocal("dailyTenCounts",{coutNums1}))
                end
            end
        --end
        -- if self.timeNow1~=nil and self.timeNow1 ~=G_getWeeTs(base.serverTime)  then
        --     print("self.timeNow111:::",self.timeNow1,G_getWeeTs(base.serverTime))
        --     self.coutNums1 =0
        --     if self.tenCountsLb1~=nil then
        --         self.tenCountsLb1:setString(getlocal("dailyTenCounts",{self.coutNums1}))
        --     end
        -- end
        local dataKey="hero_2TimeNow@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)-- upperTen_small
        local timeNow2 = tonumber(CCUserDefault:sharedUserDefault():getStringForKey(dataKey))
        if timeNow2 ==nil then
            timeNow2=0
        end
        --if self.tenCountsLb2 then
            if G_isToday(timeNow2)==false then

                local coutNums2 =0
                if self.tenCountsLb2 then
                    self.tenCountsLb2:setString(getlocal("dailyTenCounts",{coutNums2}))
                end
                local dataKey="playeridx2@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
                CCUserDefault:sharedUserDefault():setStringForKey(dataKey,tostring(coutNums2))
                CCUserDefault:sharedUserDefault():flush()
            else
                local dataKey="playeridx2@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
                local coutNums2=CCUserDefault:sharedUserDefault():getStringForKey(dataKey)
                if coutNums2=="" then
                    coutNums2=0
                end
                if self.tenCountsLb2 then
                    self.tenCountsLb2:setString(getlocal("dailyTenCounts",{coutNums2}))
                end
            end
        --end        
    end
    self:awardConditions()
    -- self:tipUpdate()
end

function heroRecruitDialog:dispose()
    self.expandIdx=nil
    self.recruitItem1=nil
    self.recruitItem2=nil
    self.recruitItem3=nil
    self.leftTimeLb1=nil
    self.leftTimeLb2=nil
    self.numLb1=nil
    self.numLb2=nil
    self.tipDescSp1=nil
    self.tipDescSp2=nil
    self.tenCountsLb1=nil
    self.tenCountsLb2=nil
    self.freeTipSp1=nil
    self.freeTipSp2=nil
 
    self=nil

end




