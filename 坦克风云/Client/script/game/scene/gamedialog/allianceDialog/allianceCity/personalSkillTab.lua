personalSkillTab={}

function personalSkillTab:new()
    local nc={}
    setmetatable(nc, self)
    self.__index=self

    return nc
end

function personalSkillTab:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    self.grabTodayFlag=true
    self.collectTodayFlag=true

    local cityVo=allianceCityVoApi:getAllianceCity()
    local acityuser=allianceCityVoApi:getAllianceCityUser()
    local glorySp=CCSprite:createWithSpriteFrameName("honor.png")
    local glorySpScale=40/glorySp:getContentSize().width
    glorySp:setAnchorPoint(ccp(0,0.5))
    glorySp:setPosition(20,G_VisibleSizeHeight - 200)
    glorySp:setScale(glorySpScale)
    self.bgLayer:addChild(glorySp)
    local ownGloryStr=getlocal("own_glory")
    local ownGloryLb=GetTTFLabelWrap(ownGloryStr.." "..FormatNumber(acityuser.glory),24,CCSizeMake(G_VisibleSizeWidth/2 - 70,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    ownGloryLb:setAnchorPoint(ccp(0,0.5))
    ownGloryLb:setPosition(65,G_VisibleSizeHeight - 200)
    self.bgLayer:addChild(ownGloryLb)
    self.gloryLb=ownGloryLb

    local glorySp2=CCSprite:createWithSpriteFrameName("honor.png")
    glorySp2:setAnchorPoint(ccp(0,0.5))
    glorySp2:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 200)
    glorySp2:setScale(glorySpScale)
    self.bgLayer:addChild(glorySp2)
    local dailyGetStr=getlocal("daily_get")
    local dailyGetLb=GetTTFLabelWrap(dailyGetStr,24,CCSizeMake(G_VisibleSizeWidth/2 - 70,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    dailyGetLb:setAnchorPoint(ccp(0,0.5))
    dailyGetLb:setPosition(G_VisibleSizeWidth/2 + 45,G_VisibleSizeHeight - 200)
    self.bgLayer:addChild(dailyGetLb)
    self.dailyGloryLb=dailyGetLb
    self:refreshGloryLbs()

    local kuangWidth,kuangHeight=616,375
    local skillPanel=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
    skillPanel:setContentSize(CCSizeMake(kuangWidth,kuangHeight))
    skillPanel:setAnchorPoint(ccp(0.5,1))
    skillPanel:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-240)
    self.bgLayer:addChild(skillPanel)
    self.skillPanel=skillPanel
    local lanStr,strSize2 = G_getCurChoseLanguage(),22
    if lanStr =="cn" or lanStr =="tw" or lanStr =="ja" or lanStr =="ko" then
        strSize2 = 25
    end
    local titleTb={getlocal("citySkillTitle"),strSize2,G_ColorWhite}
    tempLb=GetTTFLabel(getlocal("citySkillTitle"),25)
    realW=tempLb:getContentSize().width+80
    if realW>kuangWidth then
        realW=kuangWidth
    end
    local titleBg,titleLb=G_createNewTitle(titleTb,CCSizeMake(realW,0))
    titleBg:setPosition(kuangWidth/2,kuangHeight-40)
    skillPanel:addChild(titleBg)

    local skillTb=allianceCityCfg.personSkill
    local allianceSkill=allianceCityCfg.allianceSkill
    local leftSpaceX,iconWidth=60,100
    local iconSpaceX,iconSpaceY=(kuangWidth-2*leftSpaceX-3*iconWidth)/2,60

    self.selectSp=LuaCCScale9Sprite:createWithSpriteFrameName("newSelectKuang.png",CCRect(30, 30, 1, 1),function () end)
    self.selectSp:setContentSize(CCSizeMake(iconWidth,iconWidth))
    skillPanel:addChild(self.selectSp,2)

    local cityVo=allianceCityVoApi:getAllianceCity()
    local cityLv=allianceCityVoApi:getAllianceCityLv()
    self.skillObjectTb={}
    self.sortSkills={}
    for k,v in pairs(allianceSkill) do
        table.insert(self.sortSkills,{sid=k,index=v.buildLevel})
    end
    local function sortFunc(s1,s2)
        if s1.index<s2.index then
            return true
        end
        return false
    end
    table.sort(self.sortSkills,sortFunc)

    self:refreshSkillList()

    local spaceY=0
    if G_isIphone5()==true then
        spaceY=-10
    end
    local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("newRankTitleBg.png",CCRect(4,4,1,1),function () end)
    titleBg:setContentSize(CCSizeMake(kuangWidth,28))
    titleBg:setAnchorPoint(ccp(0.5,1))
    titleBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-620+spaceY)
    self.bgLayer:addChild(titleBg)

    local infoPanel=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function () end)
    infoPanel:setContentSize(CCSizeMake(kuangWidth,200))
    infoPanel:setAnchorPoint(ccp(0.5,1))
    infoPanel:setOpacity(50)
    infoPanel:setPosition(G_VisibleSizeWidth/2,titleBg:getPositionY()-titleBg:getContentSize().height)
    self.bgLayer:addChild(infoPanel)

    local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function () end)
    lineSp:setContentSize(CCSizeMake(titleBg:getContentSize().height+infoPanel:getContentSize().height,2))
    lineSp:setRotation(90)
    lineSp:setPosition(infoPanel:getContentSize().width/2,infoPanel:getContentSize().height/2+14)
    infoPanel:addChild(lineSp)

    local titleLb1=GetTTFLabel(getlocal("skillTab"),20)
    titleLb1:setPosition(kuangWidth/4,titleBg:getContentSize().height/2)
    titleBg:addChild(titleLb1)
    local titleLb2=GetTTFLabel(getlocal("upgradeEffectStr"),20)
    titleLb2:setPosition(3*kuangWidth/4,titleBg:getContentSize().height/2)
    titleBg:addChild(titleLb2)

    local sid=self.selectSid
    local skillCfg=skillTb[sid]
    local skillLv,limitLv=(acityuser.skill[sid] or 0),(cityVo.skill[sid] or 0)  
    local iconScale=0.8
    local selectSkillSp=CCSprite:createWithSpriteFrameName(skillCfg.skillIcon)
    selectSkillSp:setAnchorPoint(ccp(0,0.5))
    selectSkillSp:setScale(iconScale)
    infoPanel:addChild(selectSkillSp)
    self.selectSkillSp=selectSkillSp

    local nameLb=GetTTFLabelWrap(getlocal(skillCfg.skillName),20,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    selectSkillSp:setPosition(10,infoPanel:getContentSize().height/2+nameLb:getContentSize().height/2)
    nameLb:setAnchorPoint(ccp(0.5,1))
    nameLb:setPosition(selectSkillSp:getPositionX()+selectSkillSp:getContentSize().width*iconScale/2,selectSkillSp:getPositionY()-selectSkillSp:getContentSize().height*iconScale/2-5)
    infoPanel:addChild(nameLb)
    self.nameLb=nameLb

    local skillLvLb=GetTTFLabelWrap(getlocal("personalSkillLvStr").." "..getlocal("fightLevel",{skillLv}),20,CCSizeMake(210,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
    skillLvLb:setAnchorPoint(ccp(0,0))
    skillLvLb:setPosition(100,selectSkillSp:getPositionY()+10)
    infoPanel:addChild(skillLvLb)
    self.skillLvLb=skillLvLb

    local lvLimitLb=GetTTFLabelWrap(getlocal("help5_t2_t1").." "..getlocal("fightLevel",{limitLv}),20,CCSizeMake(210,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    lvLimitLb:setAnchorPoint(ccp(0,1))
    lvLimitLb:setPosition(100,selectSkillSp:getPositionY()-10)
    infoPanel:addChild(lvLimitLb)
    self.lvLimitLb=lvLimitLb
    if skillLv<=limitLv then
        self.skillLvLb:setColor(G_ColorGreen)
        self.lvLimitLb:setColor(G_ColorWhite)
    else
        self.skillLvLb:setColor(G_ColorRed)
        self.lvLimitLb:setColor(G_ColorGreen)
    end
    if allianceSkill[sid] and limitLv>=allianceSkill[sid].levelLimit then
        self.lvLimitLb:setColor(G_ColorRed)
    end

    self.cellHeight,self.tvHeight=self:getSkillContent(sid,true),infoPanel:getContentSize().height
    local isMoved,cellWidth=false,kuangWidth/2-16
    local function eventHandler(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return 1
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(cellWidth,self.cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            local descLb,lbheight,curValueLb,arrowSp,upValueLb,upgradeCostLb,honorSp,costLb=self:getSkillContent(self.selectSid)
            local posY=self.cellHeight
            descLb:setPosition(0,posY)
            cell:addChild(descLb)

            posY=posY-lbheight-curValueLb:getContentSize().height/2-20
            curValueLb:setPosition(0,posY)
            cell:addChild(curValueLb)

            if arrowSp and upValueLb then
                arrowSp:setPosition(curValueLb:getPositionX()+curValueLb:getContentSize().width+10,curValueLb:getPositionY())
                cell:addChild(arrowSp)
                upValueLb:setPosition(arrowSp:getPositionX()+arrowSp:getContentSize().width+10,arrowSp:getPositionY())
                cell:addChild(upValueLb)
            end

            if upgradeCostLb and honorSp and costLb then
                posY=posY-curValueLb:getContentSize().height/2-upgradeCostLb:getContentSize().height/2-20
                upgradeCostLb:setPosition(0,posY)
                cell:addChild(upgradeCostLb)

                honorSp:setPosition(upgradeCostLb:getPositionX()+upgradeCostLb:getContentSize().width,upgradeCostLb:getPositionY())
                cell:addChild(honorSp)

                costLb:setPosition(honorSp:getPositionX()+honorSp:getContentSize().width*honorSp:getScale(),honorSp:getPositionY())
                cell:addChild(costLb)
            end

            if self.selectSid=="s6" then --军团编制技能显示具体的坦克加成详情面板
                local function touchTip()
                    local tabStr={}
                    local textFormatTb={}
                    local str=getlocal("curSkillEffectStr")
                    table.insert(tabStr,str)
                    textFormatTb[1]={alignment=kCCTextAlignmentCenter}
                    local descTb=allianceCityVoApi:getSkill6Desc()
                    for k,v in pairs(descTb) do
                        table.insert(tabStr,v)
                        table.insert(textFormatTb,{alignment=kCCTextAlignmentLeft,richFlag=true,richColor={G_ColorWhite,G_ColorGreen,G_ColorWhite}})
                    end
                    local titleStr=getlocal("skill_detail_title")
                    require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
                    tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,nil,25,textFormatTb)
                end
                G_addMenuInfo(cell,self.layerNum,ccp(cellWidth-20,posY),nil,nil,0.7,nil,touchTip,true)
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
    local hd=LuaEventHandler:createHandler(eventHandler)
    self.skillTv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,self.tvHeight),nil)
    self.skillTv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
    self.skillTv:setPosition(kuangWidth/2+8,0)
    infoPanel:addChild(self.skillTv)
    if self.tvHeight>self.cellHeight then
        self.skillTv:setMaxDisToBottomOrTop(0)
        self.skillTv:setPositionY((self.cellHeight-self.tvHeight)/2)
    else
        self.skillTv:setPositionY(0)
        self.skillTv:setMaxDisToBottomOrTop(120)
    end

    local function touchTip()
        local tabStr={}
        for i=1,5 do
            local str=getlocal("alliancecity_sutdySkill_rule"..i)
            table.insert(tabStr,str)
        end
        local titleStr=getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,nil,25)
    end
    G_addMenuInfo(self.bgLayer,self.layerNum,ccp(40,70),nil,nil,0.7,nil,touchTip,true)

    local priority=-(self.layerNum-1)*20-5
    local function upgradeLimitHandler()
        local downFlag=allianceCityVoApi:isCityDown()
        if downFlag==false then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage26003"),28)
            do return end
        end
        local flag=allianceCityVoApi:isPrivilegeEnough()
        if flag==false then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage8008"),28)
            do return end
        end
        local sid=self.selectSid
        local cityVo=allianceCityVoApi:getAllianceCity()
        if allianceSkill[sid] then
            local skillCfg=skillTb[sid]
            local curlimit=cityVo.skill[sid] or 0
            local maxlimit=allianceSkill[sid].levelLimit
            if curlimit>=maxlimit then --已达可以提升的上限
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage26011"),28)
                do return end
            end
            local versionLimitCfg=playerVoApi:getMaxLvByKey("unlockCitySkill")
            if sid==versionLimitCfg[1] then
                local limitLv=versionLimitCfg[2] or 0
                if curlimit>=limitLv then --技能version限制
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage26011"),28)
                    do return end
                end
            end
            local costR=allianceSkill[sid].costR[curlimit+1] or 0 --消耗的稀土数
            local function realUpgradeHandler()
                local ownR=cityVo.cr or 0 --当前的稀土数
                if costR>ownR then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage26008"),28)
                    do return end
                end
                local function upgradeCallBack()
                    self:refreshSkillInfoPanel(sid)
                    self:playUpgradeAction(self.selectSp)
                end
                allianceCityVoApi:upgradePersonalSkill(1,sid,upgradeCallBack,curlimit)
            end
            G_showSecondConfirm(self.layerNum+1,true,true,getlocal("upgradeLimitStr"),getlocal("upgradeSkillLimitStr",{costR,getlocal(skillCfg.skillName)}),false,realUpgradeHandler)
        end
    end
    self.upgradeLimitBtn=G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth/2-120,70),{getlocal("upgradeLimitStr"),25},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",upgradeLimitHandler,1,priority)

    local function upgradeSkillHandler()
        local downFlag=allianceCityVoApi:isCityDown()
        if downFlag==false then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage26003"),28)
            do return end
        end
        local sid=self.selectSid
        local cityVo,acityuser=allianceCityVoApi:getAllianceCity(),allianceCityVoApi:getAllianceCityUser()
        local skillLv,limitLv=(acityuser.skill[sid] or 0),(cityVo.skill[sid] or 0)
        local versionLimitCfg=playerVoApi:getMaxLvByKey("unlockCitySkill")
        if sid==versionLimitCfg[1] then
            local limitLv=versionLimitCfg[2] or 0
            if skillLv>=limitLv then --技能version限制
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("allianceSkillLevelMax"),28)
                do return end
            end
        end
        if skillLv>=limitLv then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage26012"),28)
            do return end
        end
        local skillCfg=skillTb[sid]
        local glory,cost=(acityuser.glory or 0),skillCfg.costH[skillLv+1]
        local function confirm()
            if glory<cost then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage26013"),28)
                do return end
            end
            local function upgradeCallBack()
                self:refreshSkillInfoPanel(sid)
                self:playUpgradeAction(self.selectSkillSp)
            end
            -- print("self.selectSid",self.selectSid)
            allianceCityVoApi:upgradePersonalSkill(2,sid,upgradeCallBack)
        end
        G_showSecondConfirm(self.layerNum+1,true,true,getlocal("upgradeBuild"),getlocal("upgradeSkillConfirmStr",{cost,getlocal(skillCfg.skillName)}),false,confirm)    
    end
    self.upgradeBtn=G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth/2+150,70),{getlocal("upgradeBuild"),25},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",upgradeSkillHandler,1,priority)

    self:initTableView()

    return self.bgLayer
end

function personalSkillTab:getSkillContent(sid,isgetHeight)
    local descLb,lbheight,curValueLb,arrowSp,upValueLb,upgradeCostLb,honorSp,costLb
    local skillCfg=allianceCityCfg.personSkill[sid]
    local allianceSkill=allianceCityCfg.allianceSkill
    local acityuser=allianceCityVoApi:getAllianceCityUser()
    local cityVo=allianceCityVoApi:getAllianceCity()

    local lv,limitLv=(acityuser.skill[sid] or 0),(cityVo.skill[sid] or 0)
    if lv>limitLv then
        lv=limitLv
    end
    local levelLimit=allianceSkill[sid].levelLimit
    local colorTb={}
    if sid=="s6" then
        colorTb={G_ColorWhite,G_ColorGreen,G_ColorWhite}
        local versionLimitCfg=playerVoApi:getMaxLvByKey("unlockCitySkill")
        local versionSid,vsersionLv=versionLimitCfg[1],versionLimitCfg[2]
        if versionSid and vsersionLv and versionSid==sid and vsersionLv>0 then
            if lv>vsersionLv then
                lv=vsersionLv
            end
        end
    end
    local descStr=allianceCityVoApi:getPersonalSkillDesc(sid,lv)

    -- descLb=GetTTFLabelWrap(descStr,20,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    -- descLb:setAnchorPoint(ccp(0,0.5))
    -- local height=descLb:getContentSize().height+20

    descLb,lbheight=G_getRichTextLabel(descStr,colorTb,20,280,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    descLb:setAnchorPoint(ccp(0,1))
    local height=lbheight+20

    local curValueStr=allianceCityVoApi:getPersonalSkillValue(sid,lv)
    local curValueLb=GetTTFLabel(curValueStr,20)
    curValueLb:setAnchorPoint(ccp(0,0.5))
    height=height+curValueLb:getContentSize().height

    if lv<levelLimit then
        local nextValueStr=allianceCityVoApi:getPersonalSkillValue(sid,lv+1)
        arrowSp=CCSprite:createWithSpriteFrameName("heroArrowRight.png")
        arrowSp:setAnchorPoint(ccp(0,0.5))

        upValueLb=GetTTFLabel(nextValueStr,20)
        upValueLb:setAnchorPoint(ccp(0,0.5))

        upgradeCostLb=GetTTFLabel(getlocal("skillUpgradeCostStr"),20)
        upgradeCostLb:setAnchorPoint(ccp(0,0.5))

        honorSp=CCSprite:createWithSpriteFrameName("honor.png")
        honorSp:setAnchorPoint(ccp(0,0.5))
        honorSp:setScale(32/honorSp:getContentSize().width)

        costLb=GetTTFLabel(skillCfg.costH[lv+1],20)
        costLb:setAnchorPoint(ccp(0,0.5))

        height=height+upgradeCostLb:getContentSize().height+20
    end
    if isgetHeight==true then
        return height
    end
    return descLb,lbheight,curValueLb,arrowSp,upValueLb,upgradeCostLb,honorSp,costLb,height
end

function personalSkillTab:playUpgradeAction(target)
    if target==nil then
        do return end
    end
    local equipLine1 = CCParticleSystemQuad:create("public/hero/equipLine.plist")
    equipLine1.positionType=kCCPositionTypeFree
    equipLine1:setPosition(self.selectSp:getContentSize().width/2,5)
    target:addChild(equipLine1,3)
    local function removeLine1( ... )
        if equipLine1 then
            equipLine1:stopAllActions()
            equipLine1:removeFromParentAndCleanup(true)
            equipLine1=nil
            self.isPlaying=false
        end
    end
    local mvTo1=CCMoveTo:create(0.35,ccp(target:getContentSize().width/2,target:getContentSize().height+5))
    local fc1= CCCallFunc:create(removeLine1)
    local carray1=CCArray:create()
    carray1:addObject(mvTo1)
    carray1:addObject(fc1)
    local seq1 = CCSequence:create(carray1)
    equipLine1:runAction(seq1)

    local equipStar1 = CCParticleSystemQuad:create("public/hero/equipStar.plist")
    equipStar1.positionType=kCCPositionTypeFree
    equipStar1:setPosition(target:getContentSize().width/2,5)
    target:addChild(equipStar1,3)
    local function removeLine2( ... )
        if equipStar1 then
            equipStar1:stopAllActions()
            equipStar1:removeFromParentAndCleanup(true)
            equipStar1=nil
            
        end
    end
    local mvTo2=CCMoveTo:create(0.5,ccp(target:getContentSize().width/2,self.selectSp:getContentSize().height+5))
    local fc2= CCCallFunc:create(removeLine2)
    local carray2=CCArray:create()
    carray2:addObject(mvTo2)
    carray2:addObject(fc2)
    local seq2 = CCSequence:create(carray2)
    equipStar1:runAction(seq2)
end

function personalSkillTab:refreshSkillList() 
    if self.skillPanel==nil or self.sortSkills==nil or self.selectSp==nil then
        do return end
    end
    local kuangWidth,kuangHeight=self.skillPanel:getContentSize().width,self.skillPanel:getContentSize().height

    local skillTb=allianceCityCfg.personSkill
    local allianceSkill=allianceCityCfg.allianceSkill
    local leftSpaceX,iconWidth=60,100
    local iconSpaceX,iconSpaceY=(kuangWidth-2*leftSpaceX-3*iconWidth)/2,60
    local cityVo=allianceCityVoApi:getAllianceCity()
    local cityLv=allianceCityVoApi:getAllianceCityLv()
    for k,v in pairs(self.sortSkills) do
        if k==1 and self.selectSid==nil then
            self.selectSid=v.sid
        end
        local skillCfg=skillTb[v.sid]
        local limitCfg=allianceSkill[v.sid]
        local sx=leftSpaceX+(k-1)%3*(iconSpaceX+iconWidth)
        local sy=kuangHeight-50-math.floor((k-1)/3)*(iconWidth+iconSpaceY)
        local skillSp,lvLb,nameLb,lockBg
        local skillObject=self.skillObjectTb[v.sid]
        if self.skillObjectTb and self.skillObjectTb[v.sid] then
            skillObject=self.skillObjectTb[v.sid]
            skillSp=tolua.cast(skillObject[1],"CCSprite")
        end
        if skillSp then
            skillSp:removeFromParentAndCleanup(true)
            skillSp=nil
        end
        local function touchSkill()
            if skillSp and self.selectSid~=v.sid then
                self.selectSid=v.sid
                self.selectSp:setPosition(sx+iconWidth/2,sy-iconWidth/2)
                self:refreshSkillInfoPanel(v.sid)
            end
        end
        if cityLv<limitCfg.buildLevel then
            skillSp=GraySprite:createWithSpriteFrameName(skillCfg.skillIcon)
        else
            skillSp=LuaCCSprite:createWithSpriteFrameName(skillCfg.skillIcon,touchSkill)
            skillSp:setTouchPriority(-(self.layerNum-1)*20-3)
        end
        skillSp:setAnchorPoint(ccp(0,1))
        skillSp:setPosition(sx,sy)
        self.skillPanel:addChild(skillSp)

        local skillLv=cityVo.skill[v.sid] or 0
        local lvLb=GetTTFLabel(getlocal("fightLevel",{skillLv}),20)
        local lvBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
        lvBg:setContentSize(CCSizeMake(lvLb:getContentSize().width+15,lvLb:getContentSize().height))
        lvBg:setAnchorPoint(ccp(0,0))
        lvBg:setPosition(skillSp:getContentSize().width-lvBg:getContentSize().width-5,5)
        skillSp:addChild(lvBg)

        lvLb:setAnchorPoint(ccp(0,0.5))
        lvLb:setPosition(5,lvBg:getContentSize().height/2)
        lvBg:addChild(lvLb)
        
        local nameLb=GetTTFLabelWrap(getlocal(skillCfg.skillName),20,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        nameLb:setAnchorPoint(ccp(0.5,1))
        nameLb:setPosition(skillSp:getContentSize().width/2,-5)
        -- nameLb:setColor(G_ColorYellowPro)
        skillSp:addChild(nameLb)

        if cityLv<limitCfg.buildLevel then
            local lockLb=GetTTFLabelWrap(getlocal("skillUnlockStr",{limitCfg.buildLevel}),18,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            local lockBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
            lockBg:setContentSize(CCSizeMake(100,lockLb:getContentSize().height))
            lockBg:setPosition(getCenterPoint(skillSp))
            skillSp:addChild(lockBg)

            lockLb:setPosition(getCenterPoint(lockBg))
            lockLb:setColor(G_ColorRed)
            lockBg:addChild(lockLb)
        end

        if v.sid==self.selectSid then
            self.selectSp:setPosition(sx+iconWidth/2,sy-iconWidth/2)
        end
        local tipSp=nil
        local flag=allianceCityVoApi:isGloryEnoughToUpgrade(v.sid)
        if flag==true then
            tipSp=CCSprite:createWithSpriteFrameName("IconTip.png")
            tipSp:setPosition(ccp(skillSp:getContentSize().width-2,skillSp:getContentSize().height-5))
            tipSp:setScale(0.6)
            skillSp:addChild(tipSp)
        end 
        self.skillObjectTb[v.sid]={skillSp,nameLb,lvLb,lockBg,tipSp}
    end
end

function personalSkillTab:refreshSkillInfoPanel(sid)
    local skillCfg=allianceCityCfg.personSkill[sid]
    local allianceSkill=allianceCityCfg.allianceSkill
    local acityuser=allianceCityVoApi:getAllianceCityUser()
    local cityVo=allianceCityVoApi:getAllianceCity()
    if skillCfg and allianceSkill and self.selectSkillSp and self.nameLb and self.lvLimitLb and self.skillLvLb and self.skillTv then
        local skillLv,limitLv=(acityuser.skill[sid] or 0),(cityVo.skill[sid] or 0)
        local frame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(skillCfg.skillIcon)
        self.selectSkillSp=tolua.cast(self.selectSkillSp,"LuaCCSprite")
        if self.selectSkillSp and frame then
            self.selectSkillSp:setDisplayFrame(frame)
        end
        self.nameLb:setString(getlocal(skillCfg.skillName))
        self.skillLvLb:setString(getlocal("personalSkillLvStr")..getlocal("fightLevel",{skillLv}))
        self.lvLimitLb:setString(getlocal("help5_t2_t1")..getlocal("fightLevel",{limitLv}))
        if skillLv<=limitLv then
            self.skillLvLb:setColor(G_ColorGreen)
            self.lvLimitLb:setColor(G_ColorWhite)
        else
            self.skillLvLb:setColor(G_ColorRed)
            self.lvLimitLb:setColor(G_ColorGreen)
        end
        if allianceSkill[sid] and limitLv>=allianceSkill[sid].levelLimit then
            self.lvLimitLb:setColor(G_ColorRed)
        end

        self.cellHeight=self:getSkillContent(sid,true)
        self.skillTv:reloadData()
        if self.tvHeight>self.cellHeight then
            self.skillTv:setMaxDisToBottomOrTop(0)
            self.skillTv:setPositionY((self.cellHeight-self.tvHeight)/2)
        else
            self.skillTv:setPositionY(0)
            self.skillTv:setMaxDisToBottomOrTop(120)
        end

        local skillObject=self.skillObjectTb[sid]
        if skillObject then
            local lvLb=tolua.cast(skillObject[3],"CCLabelTTF")
            if lvLb then
                lvLb:setString(getlocal("fightLevel",{limitLv}))
            end
        end
    end
    self:refreshGloryLbs()
end

function personalSkillTab:refreshSkillTips()
    for sid,v in pairs(self.skillObjectTb) do
        local skillSp=tolua.cast(v[1],"CCSprite")
        if skillSp then
            local tipSp=tolua.cast(v[5],"CCSprite")
            local flag=allianceCityVoApi:isGloryEnoughToUpgrade(sid)
            if flag==true then
                if tipSp==nil then
                    tipSp=CCSprite:createWithSpriteFrameName("IconTip.png")
                    tipSp:setPosition(ccp(skillSp:getContentSize().width-2,skillSp:getContentSize().height-5))
                    tipSp:setScale(0.6)
                    skillSp:addChild(tipSp)
                    self.skillObjectTb[sid][5]=tipSp
                else
                    tipSp:setVisible(true)
                end
            else
                if tipSp then
                    tipSp:removeFromParentAndCleanup(true)
                    self.skillObjectTb[sid][5]=nil
                end
            end  
        end
    end
end

function personalSkillTab:refreshGloryLbs()
    local acityuser=allianceCityVoApi:getAllianceCityUser()
    if self.gloryLb then
        self.gloryLb:setString(getlocal("own_glory").." "..FormatNumber(acityuser.glory))
    end
    if self.dailyGloryLb then
        local gloryCollect=0
        local cityCfg=allianceCityVoApi:getCityLimitCfg()
        if cityCfg then
            local collectH,grabH=0,0
            if acityuser.collect and acityuser.collect.h then
                collectH=acityuser.collect.h
            end
            if acityuser.grab and acityuser.grab.H then
                grabH=acityuser.grab.H
            end
            if acityuser.grab.T and G_isToday(acityuser.grab.T)~=G_isToday(base.serverTime) then
                self.grabTodayFlag=false
                grabH=0
            end
            if acityuser.collect.t and G_isToday(acityuser.collect.t)~=G_isToday(base.serverTime) then
                self.collectTodayFlag=false
                collectH=0
            end
            local colectHLimit=allianceCityVoApi:getCollectHLimit()
            gloryCollect=colectHLimit+cityCfg.grabLimitH-collectH-grabH
            if gloryCollect<0 then
                gloryCollect=0
            end
        end
        self.dailyGloryLb:setString(getlocal("daily_get").." "..FormatNumber(gloryCollect))
    end
end

function personalSkillTab:updateUI()
    self:refreshGloryLbs()
end

function personalSkillTab:initTableView()
    local function refreshSkillPanel(event,data)
        self:refreshSkillList()
        self:refreshSkillInfoPanel(self.selectSid)
    end
    self.refreshListener=refreshSkillPanel
    eventDispatcher:addEventListener("alliancecity.refreshSkils",refreshSkillPanel)

    local function refreshTip(event,data)
        self:refreshSkillTips()
    end
    self.refreshTipListener=refreshTip
    eventDispatcher:addEventListener("alliancecity.tipRefresh",refreshTip)
end

function personalSkillTab:tick()
    local acityuser=allianceCityVoApi:getAllianceCityUser()    
    if acityuser then
        local grabTimeFlag,collectTimeFlag=true,true
        if acityuser.grab and acityuser.grab.T and G_isToday(acityuser.grab.T)~=G_isToday(base.serverTime) then
            grabTimeFlag=false
        end
        if acityuser.collect and acityuser.collect.t and G_isToday(acityuser.collect.t)~=G_isToday(base.serverTime) then
            collectTimeFlag=false
        end
        if grabTimeFlag~=self.grabTodayFlag or collectTimeFlag~=self.collectTodayFlag then
            self.grabTodayFlag=grabTimeFlag
            self.collectTodayFlag=collectTimeFlag
            self:refreshGloryLbs()
        end
    end
end

function personalSkillTab:dispose()
    if self.refreshListener then
        eventDispatcher:removeEventListener("alliancecity.refreshSkils",self.refreshListener)
        self.refreshListener=nil
    end
    if self.refreshTipListener then
      eventDispatcher:removeEventListener("alliancecity.tipRefresh",self.refreshTipListener)
      self.refreshTipListener=nil
    end
    self.selectSp=nil
    self.selectSkillSp=nil
    self.skillTv=nil
    self.skillLvLb=nil
    self.nameLb=nil
    self.lvLimitLb=nil
    self.skillObjectTb={}
    self.dailyGloryLb=nil
    self.sortSkills={}
    self.selectSid=nil
    self.gloryLb=nil
end