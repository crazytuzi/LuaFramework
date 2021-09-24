acMingjiangzailinDialog = commonDialog:new()

function acMingjiangzailinDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.height = 130
    self.adaH = 0
    if G_getIphoneType() == G_iphoneX then
        self.adaH = 1250-1136
    end
    self.dangci = nil
    self.numSpFlag=1
    self.spTb={}
    self.starItemTb={}
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("allianceWar/warMap.plist")
    return nc
end

function acMingjiangzailinDialog:resetTab()
    self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 105))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, 10))
    self:initLogData()

end

function acMingjiangzailinDialog:initLogData()
    local function callBack(fn,data)
        local ret,sData = base:checkServerData(data)
        if ret==true then 
            if sData and sData.data and sData.data.log then
                acMingjiangzailinVoApi:initLogData(sData.data.log)
            end
            self:initLayer()
        end                
    end
    local logList = acMingjiangzailinVoApi:getLogList()
    if SizeOfTable(logList)==0 then
        socketHelper:activityMingjiangzailinLog(callBack)
    else
        self:initLayer()
    end
end

function acMingjiangzailinDialog:initTableView()
end

function acMingjiangzailinDialog:initLayer()
    local isNewMode = acMingjiangzailinVoApi:getMustMode()
    local strSize2 = 20
    local strSize3 = 15
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =25
        strSize3 =21
    end
    local widCenter=self.bgLayer:getContentSize().width/2
    local nowHeight=self.bgLayer:getContentSize().height-100
    local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),28)
    acLabel:setAnchorPoint(ccp(0.5,1))
    acLabel:setPosition(ccp(widCenter, nowHeight))
    self.bgLayer:addChild(acLabel)
    acLabel:setColor(G_ColorGreen)
    local addH=0
    if(G_isIphone5())then
        addH=20
    end
    nowHeight=nowHeight-acLabel:getContentSize().height-addH
    local acVo = acMingjiangzailinVoApi:getAcVo()
    local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
    local messageLabel=GetTTFLabel(timeStr,28)
    messageLabel:setAnchorPoint(ccp(0.5,1))
    messageLabel:setPosition(ccp(widCenter, nowHeight))
    self.bgLayer:addChild(messageLabel)
    self.timeLb=messageLabel
    self:updateAcTime()


    local function touch(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local tabStr = {}
        local tabColor = {}
        tabStr = {"\n",getlocal("activity_mingjiangzailin_tip3"),"\n",getlocal("activity_mingjiangzailin_tip2"),"\n",getlocal("activity_mingjiangzailin_tip1"),"\n"}
        if isNewMode ==true then
            tabStr ={"\n",getlocal("activity_mingjiangzailin_tip3_add"),"\n",getlocal("activity_mingjiangzailin_tip2_add"),"\n",getlocal("activity_mingjiangzailin_tip1_add"),"\n"}
        end
        tabColor = {nil, nil, nil, nil, nil,nil, nil}
        local td=smallDialog:new()
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
        sceneGame:addChild(dialog,self.layerNum+1)
    end

    local menuItemDesc = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon2.png",touch,nil,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,0.5))
    menuItemDesc:setScale(0.8)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-3)
    menuDesc:setPosition(ccp(self.bgLayer:getContentSize().width-20, nowHeight))
    self.bgLayer:addChild(menuDesc)

    nowHeight=nowHeight-messageLabel:getContentSize().height-addH
    local backSpH = 280
    if G_getIphoneType() == G_iphoneX then
        backSpH = 310 + 70 
    elseif(G_isIphone5())then
        backSpH=310
    end
    local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),function () do return end end)
    backSprie:setContentSize(CCSizeMake(600,backSpH))
    backSprie:setAnchorPoint(ccp(0.5,1))
    backSprie:setPosition(widCenter,nowHeight)
    self.bgLayer:addChild(backSprie)

    local function touchHeroIcon(...)
        PlayEffect(audioCfg.mouseClick)        
        require "luascript/script/game/scene/gamedialog/activityAndNote/acHuoxianmingjiangHeroInfoDialog"
        local mustgetHero = acMingjiangzailinVoApi:mustGetHero()
        local hid,heroProductOrder = self:getHidandheroProductOrder(mustgetHero)

        local td = acHuoxianmingjiangHeroInfoDialog:new(hid,heroProductOrder)
        local dialog = td:init("PanelHeaderPopup.png",self.layerNum+1,CCRect(168, 86, 10, 10),CCSizeMake(600,800),getlocal("report_hero_message"))
        sceneGame:addChild(dialog,self.layerNum+1)
        
     end   

     local mustgetHero = acMingjiangzailinVoApi:mustGetHero()
     local hid,heroProductOrder = self:getHidandheroProductOrder(mustgetHero)

     local heroIcon = heroVoApi:getHeroIcon(hid,heroProductOrder,true,touchHeroIcon,nil,nil,nil,{adjutants={}})
     heroIcon:setTouchPriority(-(self.layerNum-1)*20-2)
     heroIcon:setAnchorPoint(ccp(0,0))
     heroIcon:setPosition(25,backSprie:getContentSize().height/2+25)
     heroIcon:setScale(100/150)
     backSprie:addChild(heroIcon)

    local sizeMake,PosWhi,sizeStr22,PosWidth
    local namePosHeight = backSprie:getContentSize().height/2+25+50+10+10
    if isNewMode ==true then
        heroIcon:setPosition(35,backSprie:getContentSize().height/2-self.adaH/2)
        heroIcon:setScale(0.85)
        sizeMake = CCSizeMake(560, 95+self.adaH/2)
        PosWhi = ccp(25,20-self.adaH*2/3)
        sizeStr22 =30
        PosWidth =205
        namePosHeight = namePosHeight-10
        if G_isIphone5() then
            heroIcon:setScale(0.9)
            namePosHeight = namePosHeight+10
        end
         local heroNationLabel = GetTTFLabel(getlocal("nation_of_hero",{heroVoApi:getHeroNation(hid)}),25)
         heroNationLabel:setAnchorPoint(ccp(0,0))
         -- heroNationLabel:setColor(heroVoApi:getHeroColor(heroProductOrder))
         heroNationLabel:setPosition(ccp(PosWidth, backSprie:getContentSize().height/2+20))
         backSprie:addChild(heroNationLabel)
    else
        PosWidth =170
        sizeMake = CCSizeMake(410, 70+self.adaH)
        PosWhi = ccp(PosWidth,backSprie:getContentSize().height/2+20-self.adaH*2/3)
        sizeStr22 =25
    end

     local heroNameLabel = GetTTFLabel(heroVoApi:getHeroName(hid),sizeStr22)
     heroNameLabel:setAnchorPoint(ccp(0,0))
     heroNameLabel:setColor(heroVoApi:getHeroColor(heroProductOrder))
     heroNameLabel:setPosition(ccp(PosWidth,namePosHeight))
     backSprie:addChild(heroNameLabel)

    local desStr=getlocal("active_mingjiangzailin_hero_des1")
    local version = acMingjiangzailinVoApi:getVersion()
    if version then
        desStr=getlocal("active_mingjiangzailin_hero_des" .. version)
    end 
    if isNewMode ==true then
        desStr = desStr..getlocal("activity_mingjiangzailin_addLabel")
    end
    local heroDesTv, heroIntroduction = G_LabelTableView(sizeMake,desStr,25,kCCTextAlignmentLeft)
    backSprie:addChild(heroDesTv)
    heroDesTv:setPosition(PosWhi)
    heroDesTv:setAnchorPoint(ccp(0,0))
    heroDesTv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    heroDesTv:setMaxDisToBottomOrTop(80)

    
    local function itemTouch()
    end
    local w = G_VisibleSizeWidth/2-202-40
    for i=1,4 do
       local item = GetButtonItem("IconWar.png","IconWar.png","IconWar.png",itemTouch,i)
       item:setAnchorPoint(ccp(0, 1))
       item:setEnabled(false)
       item:setTag(i)
       local menu = CCMenu:createWithItem(item)
       menu:setPosition(w, backSprie:getContentSize().height/2+7-self.adaH/2)
       menu:setTag(i+1000)
       menu:setTouchPriority(-(self.layerNum-1)*20-1)
       backSprie:addChild(menu)
       table.insert(self.starItemTb,item)
       w = w + 121
       if isNewMode ==true then
            item:setVisible(false)
            menu:setVisible(false)
            menu:setPosition(w, 999999)
       end
    end 
    self:refreshStar()

    local descLb=GetTTFLabelWrap(getlocal("activity_huoxianmingjiang_xingxing",{heroVoApi:getHeroName(hid)}), strSize2, CCSizeMake(580,0), kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    descLb:setAnchorPoint(ccp(0.5,0.5))
    descLb:setPosition(ccp(G_VisibleSizeWidth*0.5,30))
    backSprie:addChild(descLb,1)

    local desBgSp = CCSprite:createWithSpriteFrameName("orangeMask.png")
    desBgSp:setScaleY(50/desBgSp:getContentSize().height)
    desBgSp:setScaleX(550/desBgSp:getContentSize().width)
    desBgSp:setPosition(ccp(G_VisibleSizeWidth*0.5,30))
    desBgSp:ignoreAnchorPointForPosition(false)
    desBgSp:setAnchorPoint(ccp(0.5,0.5))
    backSprie:addChild(desBgSp)

    if isNewMode ==true then
        descLb:setVisible(false)
        desBgSp:setVisible(false)
    end
    -- item_baoxiang_03.png
    local addH2=0
    local everyH=140
    if(G_isIphone5())then
        addH2=10
        everyH=155
    end
    nowHeight=nowHeight-backSprie:getContentSize().height-5-addH-addH2

    local reward = acMingjiangzailinVoApi:mustGetReward()
    for i=1,8 do
        local function touchKuReward(tag,object)
            if G_checkClickEnable()==false then
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            if self.numSpFlag==i then
                -- 板子
                local td=acMingjiangzailinRewardSmallDialog:new()
                local showList=reward[i].showList
                local rewardList=FormatItem(showList,nil,true)
                local title=getlocal("activity_mingjiangzailin_canReward")
                local desStr = getlocal("activity_yijizaitan_desTip")
                local dialog=td:init("PanelPopup.png",CCSizeMake(600,600),nil,false,false,self.layerNum+1,rewardList,title,desStr,nil)
                sceneGame:addChild(dialog,self.layerNum+1)
            else
                -- 位置
                self.numSpFlag=i
                self.animiSp:setPosition(self.spTb[i]:getPosition())
            end
            
        end

        local showProp=reward[i].showProp
        local award = FormatItem(showProp)

        local mIcon=G_getItemIcon(award[1],100,false,self.layerNum,touchKuReward,nil)
        mIcon:setAnchorPoint(ccp(0.5,1))
        mIcon:setTouchPriority(-(self.layerNum-1)*20-4)

        local nameLb=GetTTFLabelWrap(award[1].name, strSize3, CCSizeMake(140,0), kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        nameLb:setAnchorPoint(ccp(0.5,1))
        self.bgLayer:addChild(nameLb,10)

        if i<5 then
            mIcon:setPosition(95+(i-1)*150, nowHeight)
            nameLb:setPosition(ccp(95+(i-1)*150,nowHeight-100))
        else
            mIcon:setPosition(95+(i-5)*150, nowHeight-everyH)
            nameLb:setPosition(ccp(95+(i-5)*150,nowHeight-everyH-100))
        end
        self.bgLayer:addChild(mIcon)
        table.insert(self.spTb,mIcon)
    end

    local function nilFunc()

    end
    self.animiSp = LuaCCScale9Sprite:createWithSpriteFrameName("arrange1.png",CCRect(20, 20, 10, 10),nilFunc)
    self.animiSp:setContentSize(CCSizeMake(100,100))
    self.animiSp:setAnchorPoint(ccp(0.5,1))
    self.animiSp:setPosition(self.spTb[1]:getPosition())
    self.bgLayer:addChild(self.animiSp)

    nowHeight=nowHeight-300-addH
    if G_getIphoneType() == G_iphoneX then
        nowHeight = nowHeight - 20
    end
    local noteLb=GetTTFLabelWrap(getlocal("activity_mingjiangzailin_note"), strSize3, CCSizeMake(580,0), kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    noteLb:setAnchorPoint(ccp(0.5,0.5))
    noteLb:setColor(G_ColorRed)
    noteLb:setPosition(ccp(G_VisibleSizeWidth*0.5,nowHeight))
    self.bgLayer:addChild(noteLb,1)
    nowHeight=nowHeight-25 
    local logBgH=60
    if(G_isIphone5())then
        logBgH=70
    end

    local function nilFunc()
    end
    local logBg =LuaCCScale9Sprite:createWithSpriteFrameName("iconTitlebg.png",CCRect(27, 29, 2, 2),nilFunc)
    logBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, logBgH))
    logBg:ignoreAnchorPointForPosition(false);
    logBg:setAnchorPoint(ccp(0.5,1));
    self.bgLayer:addChild(logBg)
    logBg:setPosition(widCenter, nowHeight)

    local eventStr = getlocal("activity_huoxianmingjiang_log_tip0")
    local logList = acMingjiangzailinVoApi:getLogList()
    if SizeOfTable(logList)~=0 then
        local logItem = FormatItem(logList[1])
        eventStr=getlocal("activity_huoxianmingjiang_log_tip3",{logItem[1].name,logItem[1].num})
    end
    self.recentLog = GetTTFLabelWrap(eventStr, 25, CCSizeMake(450,0), kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    self.recentLog:setColor(G_ColorYellow)
    self.recentLog:setAnchorPoint(ccp(0,0.5))
    logBg:addChild(self.recentLog)
    self.recentLog:setPosition(ccp(130, logBg:getContentSize().height/2))

    local function logItemTouch()
        if G_checkClickEnable()==false then
                do
                    return
                end
          else
              base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local td=acMingjiangzailinLogSmallDialog:new()
        local rewardList=acMingjiangzailinVoApi:getLogList() or {}
        local title=getlocal("activity_customLottery_RewardRecode")
        local desStr = getlocal("activity_mingjiangzailin_desTip")
        local nojilu = getlocal("activity_huoxianmingjiang_log_tip0")
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,600),nil,false,false,self.layerNum+1,rewardList,title,desStr,nojilu)
        sceneGame:addChild(dialog,self.layerNum+1)
    end
    local logInfoItem = GetButtonItem("hero_infoBtn.png","hero_infoBtn.png","hero_infoBtn.png",logItemTouch,11,nil,nil)
    logInfoItem:setScale(0.9)
    local logMenu = CCMenu:createWithItem(logInfoItem)
    logMenu:setAnchorPoint(ccp(0,0.5))
    logMenu:setTouchPriority(-(self.layerNum-1)*20-3)
    self.bgLayer:addChild(logMenu,100)
    logMenu:setPosition(ccp(58,nowHeight-35))
    if G_getIphoneType() == G_iphoneX then
        logMenu:setPosition(ccp(58,nowHeight-self.adaH/2+23 ))
    end
    local function touchTenRecruitItem()
        if G_checkClickEnable()==false then
                  do
                      return
                  end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
          end
        PlayEffect(audioCfg.mouseClick)
        local cost =  acMingjiangzailinVoApi:getTenCost()
        if playerVoApi:getGems()<cost then
            GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost)
            return
        end

        local function callback(fn,data)
            local oldHeroList3=heroVoApi:getHeroList()
            local ret,sData = base:checkServerData(data)
            local isNewMode = acMingjiangzailinVoApi:getMustMode()
              if ret==true then 
                if sData.data==nil then 
                  return
                end


                if sData.data and sData.data.hero and sData.data.hero.report and self and self.bgLayer then
                    local content={}
                    local msgContent={}
                    local report=sData.data.hero.report or {}
                    local starTb=sData.data.star or {}
                    local initStar=acMingjiangzailinVoApi:getStar() or {0,0,0,0}

                                      
                    local numOfStar = 0
                    local addIndex=0
                    local starFlag = false
                    local startFlag = true

                    for k,v in pairs(initStar) do
                        if v==1 then
                            numOfStar=numOfStar+1
                        end
                    end

                    local startNumOfStar=numOfStar

                    for k,v in pairs(report) do

                        local addNumStar = 0
                        local indexNum = {} 
                        local star = starTb[k]

                        if startNumOfStar == 4 then 
                          initStar = {0,0,0,0}
                        end
                        for m,n in pairs(star) do
                          if k == 1 then

                               if n==1 and n-initStar[m]==1 then
                                  indexNum[m]=1
                                  addNumStar = addNumStar+1
                                  indexNum[addNumStar] = m
                                  numOfStar = numOfStar+1
                               end
                          else
                              if starFlag then 
                                starTb[k-1] = {0,0,0,0}
                              end
                               if n==1 and n-starTb[k-1][m]==1 then
                                  -- indexNum[m]=1
                                  addNumStar = addNumStar+1
                                  indexNum[addNumStar] = m
                                  numOfStar = numOfStar+1
                               end
                          end
                        end


                        local awardTb=FormatItem(v[1]) or {}
                        acMingjiangzailinVoApi:updateLogData(v[1])

                        local award=awardTb[1]
                        local showStr=""
                        local existStr=""
                        if award.type=="h" and award.eType=="h" then
                            local type,heroIsExist,addNum,newProductOrder=heroVoApi:getNewHeroData(award,oldHeroList3)
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

                       

                        if starFlag or startNumOfStar== 4 then 
                          table.insert(msgContent,{showStr,G_ColorYellowPro})
                        else
                          table.insert(msgContent,{showStr,G_ColorWhite})
                        end
                        table.insert(content,{award=award,point=0,index=(k+addIndex)})

                        if isNewMode ==false and startNumOfStar== 4 then 
                           local mustgetHero = acMingjiangzailinVoApi:mustGetHero()
                          local hid,heroProductOrder = self:getHidandheroProductOrder(mustgetHero)
                          local showStr1=getlocal("activity_huoxianmingjiang_star_desc3",{heroProductOrder,heroVoApi:getHeroName(hid)})
                          table.insert(msgContent,{showStr1,G_ColorYellowPro})
                          local award1={pic="IconWar.png",type="",name="",desc=""}
                          table.insert(content,{award=award1,point=0,index=(k+addIndex)})
                          if numOfStar== 4 then 
                            numOfStar = addNumStar
                          end
                        end
                        

                        if starFlag then 
                          local mustgetHero = acMingjiangzailinVoApi:mustGetHero()
                          local hid,heroProductOrder = self:getHidandheroProductOrder(mustgetHero)
                          local strLb = "activity_huoxianmingjiang_star_desc3"
                          local pic="IconWar.png"
                          if isNewMode ==true then
                                strLb = "activity_huoxianmingjiang_star_desc3_add"
                                pic=nil
                          end
                          local showStr1=getlocal(strLb,{heroProductOrder,heroVoApi:getHeroName(hid)})
                          table.insert(msgContent,{showStr1,G_ColorYellowPro})
                          local award1={pic=pic,type="",name="",desc=""}
                          table.insert(content,{award=award1,point=0,index=(k+addIndex)})
                          starFlag = false
                        end
                        

                        if isNewMode ==false then
                            for i=1,addNumStar do 

                              local showStr1=getlocal("activity_huoxianmingjiang_star_desc1",{indexNum[i]})
                              addIndex=addIndex+1
                              table.insert(msgContent,{showStr1,G_ColorYellowPro})
                              local award1={pic="IconWar.png",type="",name="",desc=""}
                              table.insert(content,{award=award1,point=0,index=(k+addIndex)})
                              
                            end                       
                        end

                        if isNewMode ==false and numOfStar == 4 and startNumOfStar~=4 then 
                          local mustgetHero = acMingjiangzailinVoApi:mustGetHero()
                          local hid,heroProductOrder = self:getHidandheroProductOrder(mustgetHero)
                          local showStr1=getlocal("activity_huoxianmingjiang_star_desc2",{heroProductOrder,heroVoApi:getHeroName(hid)})
                          table.insert(msgContent,{showStr1,G_ColorYellowPro})
                          local award1={pic="IconWar.png",type="",name="",desc=""}
                          table.insert(content,{award=award1,point=0,index=(k+addIndex)})
                          numOfStar = 0
                          starFlag = true
                        end  
                        startNumOfStar = nil            

                        G_addPlayerAward(award.type,award.key,award.id,award.num,nil,true)

                    end

                    if content and SizeOfTable(content)>0 then
                        local function confirmHandler(awardIdx)
                        end
                        local title2 = getlocal("heroRecruitTotal")
                        local isNewMode = acMingjiangzailinVoApi:getMustMode()
                        if isNewMode ==true then
                            title2 =getlocal("heroRecruitTotal_2")
                        end
                        smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),title2,content,nil,true,self.layerNum+1,confirmHandler,true,true,nil,nil,nil,msgContent)
                        playerVoApi:setValue("gems",playerVoApi:getGems()-cost)
                        acMingjiangzailinVoApi:updateData(sData.data.mingjiangzailin)
                        self:refreshStar()
                        self:refreshRecentLog()
                    end
                end

              end
        end

        socketHelper:activityMingjiangzailinChoujiang(1,self.numSpFlag,callback)
    end
    -- local strSize = 25
    -- if G_getCurChoseLanguage() =="ru" then
    --     strSize =22
    -- end
    local btnH = 20
    if G_getIphoneType() == G_iphoneX then
        btnH = btnH + self.adaH/5
    elseif(G_isIphone5())then
        btnH=30
    end
    local tenRecruitItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",touchTenRecruitItem,nil,getlocal("activity_mingjiangzailin_btn10"),strSize2)
    tenRecruitItem:setAnchorPoint(ccp(0.5,0))
    self.tenRecruitItem=tenRecruitItem
    local tenRecruitBtn=CCMenu:createWithItem(tenRecruitItem);
    tenRecruitBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    tenRecruitBtn:setPosition(ccp(G_VisibleSizeWidth/2+150,btnH))
    self.bgLayer:addChild(tenRecruitBtn)

    local cost = acMingjiangzailinVoApi:getTenCost()
    local tenLabel = GetTTFLabel(tostring(cost),25)
    tenLabel:setAnchorPoint(ccp(0,0))
    tenLabel:setPosition(G_VisibleSizeWidth/2+150-tenRecruitItem:getContentSize().width/4+20, btnH+tenRecruitItem:getContentSize().height)
    tenLabel:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(tenLabel)

    local tenGem = CCSprite:createWithSpriteFrameName("IconGold.png")
    tenGem:setAnchorPoint(ccp(0,0))
    tenGem:setPosition(G_VisibleSizeWidth/2+150-tenRecruitItem:getContentSize().width/4+tenLabel:getContentSize().width+20, btnH+tenRecruitItem:getContentSize().height)
    self.bgLayer:addChild(tenGem) 


    local function touchOneRecruitItem()
          if G_checkClickEnable()==false then
                  do
                      return
                  end
            else
            base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            -- 判断是不是免费
            local free = 0
            if acMingjiangzailinVoApi:isToday() then
              free = 1
            end


            -- 判断金币是否够
            local cost =  acMingjiangzailinVoApi:getOneCost()
            if playerVoApi:getGems()<cost and free==1 then
              GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost)
              return
            end

            local function callBack(fn,data)
              local oldHeroList=heroVoApi:getHeroList()
              local ret,sData = base:checkServerData(data)
              if ret==true then 
                if sData.data==nil then 
                  return
                end

                if sData.data and sData.data.hero and sData.data.hero.report then
                    self:showHero(sData.data.hero.report[1][1],oldHeroList)
                    acMingjiangzailinVoApi:updateLogData(sData.data.hero.report[1][1])
                end

                local initStar=acMingjiangzailinVoApi:getStar() or {0,0,0,0}
                local starTb=sData.data.star or {}

                local numOfStar = 0
                local addIndex=0
                local starFlag = false
                local addNumStar = 0
                local indexNum = {} 

                for k,v in pairs(initStar) do
                    if v==1 then
                        numOfStar=numOfStar+1
                    end
                end

                if numOfStar== 4 then
                 initStar = {0,0,0,0}
                 numOfStar = 0
                end

                for k,v in pairs(starTb[1]) do
                    if v==1 and v-initStar[k]==1 then
                        addNumStar = addNumStar+1
                        indexNum[addNumStar] = k
                        numOfStar = numOfStar+1
                    end
                end
                local showStr = nil
                if addNumStar==1 then
                  showStr = getlocal("activity_huoxianmingjiang_star_desc1",{indexNum[1]})
                elseif addNumStar==2 then
                   showStr = getlocal("activity_huoxianmingjiang_star_desc4",{indexNum[1],indexNum[2]})
                elseif addNumStar==3 then
                   showStr = getlocal("activity_huoxianmingjiang_star_desc5",{indexNum[1],indexNum[2],indexNum[3]})
                elseif addNumStar==4 then
                   showStr = getlocal("activity_huoxianmingjiang_star_desc6",{indexNum[1],indexNum[2],indexNum[3],indexNum[4]})
                end

                if showStr ~= nil and acMingjiangzailinVoApi:getMustMode() ==false then 
                  smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),showStr,30)
                end

              

                -- 免费的不扣用户端的金币
                if free==1 then 
                      playerVoApi:setValue("gems",playerVoApi:getGems()-cost)

                end
                self:checkOneRecruitVisible(false)
      
                acMingjiangzailinVoApi:updateData(sData.data.mingjiangzailin)
                self:refreshStar()
                self:refreshRecentLog()
              end
            end

            socketHelper:activityMingjiangzailinChoujiang(0,self.numSpFlag,callBack)
    end
    local oneRecruitItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",touchOneRecruitItem,nil,getlocal("activity_mingjiangzailin_btn1"),strSize2)
    oneRecruitItem:setAnchorPoint(ccp(0.5,0))
    local oneRecruitBtn=CCMenu:createWithItem(oneRecruitItem);
    oneRecruitBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    oneRecruitBtn:setPosition(ccp(G_VisibleSizeWidth/2-150,btnH))
    self.bgLayer:addChild(oneRecruitBtn)

    self.oneLabel = GetTTFLabel(getlocal("activity_equipSearch_free_btn"),20)
    self.oneLabel:setAnchorPoint(ccp(0,0))
    self.oneLabel:setPosition(G_VisibleSizeWidth/2-150-oneRecruitItem:getContentSize().width/4, btnH+oneRecruitItem:getContentSize().height)
    self.bgLayer:addChild(self.oneLabel)
    self.oneLabel :setColor(G_ColorGreen)

    local oneCost = acMingjiangzailinVoApi:getOneCost()
    self.oneCostLabel = GetTTFLabel(tostring(oneCost),25)
    self.oneCostLabel:setAnchorPoint(ccp(0,0))
    self.oneCostLabel:setPosition(G_VisibleSizeWidth/2-150-oneRecruitItem:getContentSize().width/4+20, btnH+oneRecruitItem:getContentSize().height)
    self.oneCostLabel:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(self.oneCostLabel)

    self.oneGem = CCSprite:createWithSpriteFrameName("IconGold.png")
    self.oneGem:setAnchorPoint(ccp(0,0))
    self.oneGem:setPosition(G_VisibleSizeWidth/2-150-oneRecruitItem:getContentSize().width/4+self.oneCostLabel:getContentSize().width+20, btnH+oneRecruitItem:getContentSize().height)
    self.bgLayer:addChild(self.oneGem) 
    if acMingjiangzailinVoApi:isToday() then 
        self:checkOneRecruitVisible(false)
    else
        self:checkOneRecruitVisible(true)
    end
    

end

function acMingjiangzailinDialog:refreshRecentLog()
    local eventStr = getlocal("activity_huoxianmingjiang_log_tip0")
    local logList = acMingjiangzailinVoApi:getLogList()
    if SizeOfTable(logList)~=0 then
        local logItem = FormatItem(logList[1])
        eventStr=getlocal("activity_huoxianmingjiang_log_tip3",{logItem[1].name,logItem[1].num})
    end
    self.recentLog:setString(eventStr)
end

function acMingjiangzailinDialog:showHero(reward,oldHeroList)
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

function acMingjiangzailinDialog:checkOneRecruitVisible(isFree)
    if isFree and self.oneLabel then
        self.oneLabel:setVisible(true)
        self.oneCostLabel:setVisible(false)
        self.oneGem:setVisible(false)
        self.tenRecruitItem:setEnabled(false)
    elseif self.oneLabel then
        self.oneLabel:setVisible(false)
        self.oneCostLabel:setVisible(true)
        self.oneGem:setVisible(true)
        self.tenRecruitItem:setEnabled(true)
    end
end

function acMingjiangzailinDialog:refreshStar()
    local star = acMingjiangzailinVoApi:getStar()
    if star == nil then
        return
    end
    for k,v in pairs(star) do
        if v==1 then
           self.starItemTb[k]:setEnabled(true)
        else
            self.starItemTb[k]:setEnabled(false)
        end
    end
end

function acMingjiangzailinDialog:refreshBtn()
end

function acMingjiangzailinDialog:getHidandheroProductOrder(mustgetHero)
    -- local hid 
    --  local heroProductOrder
    --  for k,v in pairs(mustgetHero) do
    --    hid = Split(k,"_")[2]
    --    heroProductOrder = v
    --  end
    --  return hid,heroProductOrder
    return acMingjiangzailinVoApi:getHidandheroProductOrder()
end


function acMingjiangzailinDialog:openInfo()
end

function acMingjiangzailinDialog:tick()
    local vo=acMingjiangzailinVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end
    if not acMingjiangzailinVoApi:isToday() then
      self:checkOneRecruitVisible(true)
    end
    self:updateAcTime()
end

function acMingjiangzailinDialog:updateAcTime()
    local acVo = acMingjiangzailinVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acMingjiangzailinDialog:dispose()
    self.recentLog=nil
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("allianceWar/warMap.plist")
end

