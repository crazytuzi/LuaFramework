--将领领悟授勋技能的面板
heroRealiseDialog=commonDialog:new()

function heroRealiseDialog:new(heroVo,layerNum,parent)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.layerNum=layerNum
    nc.heroVo=heroVo
    nc.parent=parent
    nc.useMedalBtn=nil
    nc.ownedSkillList=nil
    nc.newSkillList=nil
    nc.cardList=nil
    nc.curChooseCard=nil
    nc.cell1=nil
    nc.cell2=nil
    return nc
end

function heroRealiseDialog:updateSkillList()
    self.heroVo=G_clone(heroVoApi:getHeroByHid(self.heroVo.hid))
    local rList=heroVoApi:getRealiseSkillList(self.heroVo.hid)
    self.ownedSkillList=G_clone(self.heroVo.honorSkill)
    self.newSkillList={}
    for k,v in pairs(rList) do
        for m,n in pairs(v) do
            table.insert(self.newSkillList,{m,n})
        end
    end
end

function heroRealiseDialog:initLayer()
    local strSize2 = 22
    local subPosX  = 12
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 = 25
        subPosX =0
    elseif G_getCurChoseLanguage() =="de" then
        strSize2 =17
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local background=CCSprite:create("public/hero/heroHonorBackground.jpg")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    background:setScaleX((G_VisibleSizeWidth - 22)/background:getContentSize().width)
    background:setScaleY((G_VisibleSizeHeight - 102)/background:getContentSize().height)
    background:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 - 36)
    self.bgLayer:addChild(background)
    local upBg=LuaCCScale9Sprite:createWithSpriteFrameName("HelpHeaderBg.png",CCRect(213,20,2,7),function ( ... )end)
    upBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 30,170))
    upBg:setOpacity(180)
    upBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 180)
    self.bgLayer:addChild(upBg)
    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setScaleX((G_VisibleSizeWidth - 30)/lineSp:getContentSize().width)
    lineSp:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 180 + 84)
    self.bgLayer:addChild(lineSp)
    lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setScaleX((G_VisibleSizeWidth - 30)/lineSp:getContentSize().width)
    lineSp:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 180 - 84)
    self.bgLayer:addChild(lineSp)
    local heroIcon = heroVoApi:getHeroIcon(self.heroVo.hid,self.heroVo.productOrder)
    heroIcon:setScale(0.8)
    heroIcon:setPosition(ccp(130,G_VisibleSizeHeight-170))
    heroIcon:setTag(201)
    self.bgLayer:addChild(heroIcon)

    local function itemTouch( ... )
        -- 这一句打开之后，当滑动下面的tableView时就不能在点击了
        -- if self.tv:getIsScrolled()==true then
        --   return
        -- end

        if G_checkClickEnable()==false then
            return
        end
        PlayEffect(audioCfg.mouseClick)

        local propName=""
        local pCfg=propCfg[heroCfg.getSkillItem]
        if pCfg and pCfg.name then
            propName=getlocal(pCfg.name)
        end
        local tabStr={
            "\n",
            getlocal("hero_honor_info_tip_1"),
            "\n",
            getlocal("hero_honor_info_tip_2"),
            "\n",
            getlocal("hero_honor_info_tip_3",{propName,propName}),
            "\n"
        }
        local tabColor={
            G_ColorWhite,
            G_ColorYellowPro,
            G_ColorWhite,
            G_ColorYellowPro,
            G_ColorWhite,
            G_ColorYellowPro,
            G_ColorWhite
        }
        if(heroVoApi:heroHonor2IsOpen())then
            for i=1,3 do
                table.insert(tabStr, getlocal("hero_honor_info_tip_"..tostring(3 + i)))
                table.insert(tabStr, "\n")
                table.insert(tabColor, G_ColorYellowPro)
                table.insert(tabColor, G_ColorWhite)
            end
        end

        local titleStr=getlocal("help")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        local textSize = 25
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,nil,textSize)
    end
    -- 添加英雄信息按钮
    local heroInfoItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",itemTouch,11,nil,nil)
    heroInfoItem:setScale(0.9)
    local menu = CCMenu:createWithItem(heroInfoItem)
    menu:setPosition(ccp(555,G_VisibleSizeHeight-135))
    menu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(menu)

    local lbx=240
    local qualityLevel,qualityStr,qualityLevelColor=heroVoApi:getQualityLevel(self.heroVo.realiseNum)
    local skillMaxLevel,isLevelMax=heroVoApi:getSkillMaxLevel(self.heroVo.hid)
    local color=heroVoApi:getHeroColor(self.heroVo.productOrder)
    local skillLevelStr=getlocal("hero_honor_skill_level",{skillMaxLevel})
    local skillLevelColor=G_ColorWhite
    if(qualityLevel>=#heroFeatCfg.aptitude - 1)then
        qualityStr=qualityStr..getlocal("hero_honor_level_max")
    end
    if isLevelMax==true then
        skillLevelStr=skillLevelStr..getlocal("hero_honor_level_max")
        skillLevelColor=G_ColorYellowPro
    end
    -- Alter@JNK
    local strSizeHeadName = 24
    local strSizeHeadOther = 20
    local lbTB={
        {str=getlocal(heroListCfg[self.heroVo.hid].heroName),size=strSizeHeadName,pos={lbx,G_VisibleSizeHeight-135},aPos={0,0.5},color=color,tag=101},
        {str=getlocal("hero_honor_quality_level",{qualityStr}),size=strSizeHeadOther,pos={lbx,G_VisibleSizeHeight-165},aPos={0,0.5},color=qualityLevelColor,tag=102,lbWidth=300},
        {str=skillLevelStr,size=strSizeHeadOther,pos={lbx,G_VisibleSizeHeight-225},aPos={0,0.5},tag=103,lbWidth=380},
    }
    for k,v in pairs(lbTB) do
        local strLb
        if(k==2)then
            strLb=G_getRichTextLabel(v.str,{G_ColorWhite,v.color,G_ColorWhite},v.size,v.lbWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        elseif v.lbWidth then
            strLb=GetTTFLabelWrap(v.str,v.size,CCSizeMake(v.lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        else
            strLb=GetTTFLabel(v.str,v.size, true)
        end
        if v.aPos then
            strLb:setAnchorPoint(ccp(v.aPos[1],v.aPos[2]))
        end
        if k~=2 and v.color then
            strLb:setColor(v.color)
        end
        strLb:setPosition(ccp(v.pos[1],v.pos[2]))
        self.bgLayer:addChild(strLb)
        if v.tag~=nil then
            strLb:setTag(v.tag)
        end
    end


    local gemCost=heroVoApi:getGemCost(self.heroVo.hid)
    local propItem=heroVoApi:getPropItem(self.heroVo.hid)
    local propNum=0
    local hasPropNum=0
    local propName=""
    local pid
    if propItem and propItem.num and propItem.key then
        propNum=propItem.num
        pid=(tonumber(propItem.key) or tonumber(RemoveFirstChar(propItem.key)))
        propName=propItem.name
    end
    if pid then
        hasPropNum=bagVoApi:getItemNumId(pid)
    end
    local function callBack()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if(self.curChooseCard>self.heroVo.productOrder - heroFeatCfg.fusionLimit)then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("hero_honor_unlock2"),30)
            do return end
        end
        local gemCost1=heroVoApi:getGemCost(self.heroVo.hid)
        local index=self.useMedalBtn:getSelectedIndex()
        if index==0 then
            if(gemCost1>playerVoApi:getGems())then
                GemsNotEnoughDialog(nil,nil,gemCost1 - playerVoApi:getGems(),self.layerNum+1,gemCost1)
                do return end
            end
        else
            local hNum=bagVoApi:getItemNumId(pid)
            if hNum==0 or hNum<propNum then
                smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("activity_newTech_pNotEnought"),nil,self.layerNum+1)
                do return end
            end
        end


        local hid=self.heroVo.hid
        local function heroApperceptionCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                if index==0 then
                    playerVoApi:setGems(playerVoApi:getGems()-gemCost1)
                else
                    -- bagVoApi:useItemNumId(pid,propNum)
                    if self.propNumLb then
                        local hasNum=bagVoApi:getItemNumId(pid)
                        local pStr=getlocal("hero_honor_has_prop",{hasNum})
                        self.propNumLb:setString(pStr)
                    end
                end

                if sData.data and sData.data.newskill then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("hero_honor_realise_success"),30)
                    local skillList=sData.data.newskill
                    heroVoApi:realiseSkillUpdate(hid,self.curChooseCard,skillList)
                    self:refresh()
                    eventDispatcher:dispatchEvent("hero.honor",{type="update"})
                end
            end
        end
        local type=1
        if index==1 then
            type=2
        end
        local isSame
        if((self.curChooseCard==1 and self.heroVo.realiseID==nil) or self.curChooseCard==self.heroVo.realiseID)then
            isSame=true
        else
            isSame=false
        end
        local function onConfirm()
            if(self.curChooseCard==1)then
                socketHelper:heroApperception(hid,type,nil,heroApperceptionCallback)
            else
                socketHelper:heroApperception(hid,type,self.curChooseCard,heroApperceptionCallback)
            end
        end
        if(isSame==false and #self.newSkillList>0)then
            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("hero_honor_realiseConfirm"),nil,self.layerNum+1)
        else
            local propNum = 0
            local propItem=heroVoApi:getPropItem(self.heroVo.hid)
            if propItem and propItem.num and propItem.key then
                propNum=propItem.num
            end
            local keyName 
            if index == 0 then
                keyName = "hero_skill_release_gold"
            else
                keyName = "hero_skill_release_pop"
            end
            local function secondTipFunc(sbFlag)
                local sValue=base.serverTime .. "_" .. sbFlag
                G_changePopFlag(keyName,sValue)
            end
            if G_isPopBoard(keyName) then
                local costName 
                local costNum 
                if index == 0 then
                    costName = getlocal("gem")
                    costNum = gemCost1
                else
                    costName = propName
                    costNum = propNum
                end
                G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des5",{costNum,costName}),true,onConfirm,secondTipFunc)
            else
                onConfirm()
            end
        end
    end
    local heroStr = getlocal("hero_honor_realise")
    local realiseItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",callBack,nil,heroStr,strSize2,101)
    realiseItem:setScaleX(1.1)
    local realiseBtn=CCMenu:createWithItem(realiseItem)
    local lbMenu=tolua.cast(realiseItem:getChildByTag(101),"CCLabelTTF")
    lbMenu:setScaleX(1/1.1)
    lbMenu:setAnchorPoint(ccp(1,0.5))
    lbMenu:setPositionX(260-subPosX)
    realiseBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    realiseBtn:setPosition(ccp(G_VisibleSizeWidth - 150,60))
    realiseBtn:setTag(202)
    self.bgLayer:addChild(realiseBtn)

    local btnX=G_VisibleSizeWidth - 150 - 110*1.1
    local gemSp1=CCSprite:createWithSpriteFrameName("IconGold.png")
    gemSp1:setAnchorPoint(ccp(0,0.5))
    gemSp1:setPosition(ccp(btnX + 20,60))
    self.bgLayer:addChild(gemSp1,2)
    local gemNum=gemCost
    self.gemLb=GetTTFLabel(gemNum,25)
    self.gemLb:setAnchorPoint(ccp(0,0.5))
    self.gemLb:setPosition(ccp(btnX + 20 + gemSp1:getContentSize().width + 10,60))
    self.bgLayer:addChild(self.gemLb,2)
    if(gemCost>playerVoApi:getGems())then
        self.gemLb:setColor(G_ColorRed)
    end

    local propSp1=CCSprite:createWithSpriteFrameName("icon_866.png")
    propSp1:setAnchorPoint(ccp(0,0.5))
    propSp1:setPosition(ccp(btnX + 20,60))
    self.bgLayer:addChild(propSp1,2)
    propSp1:setVisible(false)
    propSp1:setScale(0.6)
    self.propLb=GetTTFLabel(FormatNumber(propNum),25)
    self.propLb:setAnchorPoint(ccp(0,0.5))
    self.propLb:setPosition(ccp(btnX + 20 + gemSp1:getContentSize().width + 10,60))
    self.bgLayer:addChild(self.propLb,2)
    self.propLb:setVisible(false)

    local gemSp2=CCSprite:createWithSpriteFrameName("IconGold.png")
    gemSp2:setScale(1.2)
    gemSp2:setAnchorPoint(ccp(0,0.5))
    gemSp2:setPosition(30,100)
    self.bgLayer:addChild(gemSp2,2)
    self.gemNumLb=GetTTFLabel(getlocal("ownedGem",{FormatNumber(playerVoApi:getGems())}),25)
    self.gemNumLb:setAnchorPoint(ccp(0,0.5))
    self.gemNumLb:setPosition(30 + gemSp2:getContentSize().width + 10,100)
    self.bgLayer:addChild(self.gemNumLb)

    local propSp2=CCSprite:createWithSpriteFrameName("icon_866.png")
    propSp2:setAnchorPoint(ccp(0,0.5))
    propSp2:setScale(0.8)
    propSp2:setPosition(ccp(30,100))
    propSp2:setVisible(false)
    self.bgLayer:addChild(propSp2,2)
    self.propNumLb=GetTTFLabel(getlocal("ownedGem",{FormatNumber(hasPropNum)}),25)
    self.propNumLb:setAnchorPoint(ccp(0,0.5))
    self.propNumLb:setPosition(30 + gemSp1:getContentSize().width + 10,100)
    self.bgLayer:addChild(self.propNumLb,2)
    self.propNumLb:setVisible(false)

    local function changeHandler()
        local index=self.useMedalBtn:getSelectedIndex()
        if index==0 then
            if self.gemLb then
                self.gemLb:setVisible(true)
            end
            if gemSp1 then
                gemSp1:setVisible(true)
            end
            if self.gemNumLb then
                self.gemNumLb:setVisible(true)
            end
            if gemSp2 then
                gemSp2:setVisible(true)
            end
            if self.propLb then
                self.propLb:setVisible(false)
            end
            if propSp1 then
                propSp1:setVisible(false)
            end
            if self.propNumLb then
                self.propNumLb:setVisible(false)
            end
            if propSp2 then
                propSp2:setVisible(false)
            end
        else
            if self.gemLb then
                self.gemLb:setVisible(false)
            end
            if gemSp1 then
                gemSp1:setVisible(false)
            end
            if self.gemNumLb then
                self.gemNumLb:setVisible(false)
            end
            if gemSp2 then
                gemSp2:setVisible(false)
            end
            if self.propLb then
                self.propLb:setVisible(true)
            end
            if propSp1 then
                propSp1:setVisible(true)
            end
            if self.propNumLb then
                self.propNumLb:setVisible(true)
            end
            if propSp2 then
                propSp2:setVisible(true)
            end
        end
    end
    local tabBtn=CCMenu:create()
    local selectSp1 = CCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png")
    local selectSp2 = CCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png")
    local menuItemSp1 = CCMenuItemSprite:create(selectSp1,selectSp2)
    local selectSp3 = CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
    local selectSp4 = CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
    local menuItemSp2 = CCMenuItemSprite:create(selectSp3,selectSp4)
    self.useMedalBtn = CCMenuItemToggle:create(menuItemSp1)
    self.useMedalBtn:addSubItem(menuItemSp2)
    self.useMedalBtn:setAnchorPoint(CCPointMake(0,0.5))
    self.useMedalBtn:setPosition(0,0)
    self.useMedalBtn:registerScriptTapHandler(changeHandler)
    -- self.useMedalBtn:setSelectedIndex(0)
    tabBtn:addChild(self.useMedalBtn)
    tabBtn:setPosition(ccp(30,50))
    tabBtn:setTouchPriority(-(self.layerNum-1)*20-5)
    self.bgLayer:addChild(tabBtn,2)


    local useLb=GetTTFLabelWrap(getlocal("hero_honor_use_medal"),25,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    useLb:setAnchorPoint(ccp(0,0.5))
    useLb:setPosition(ccp(90,50))
    self.bgLayer:addChild(useLb,2)
end

--设置对话框里的tableView
function heroRealiseDialog:initTableView()
    spriteController:addPlist("public/datebaseShow.plist")
    spriteController:addTexture("public/datebaseShow.png")
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height/2-36))

    self:updateSkillList()
    self.cardList={}
    self.curChooseCard=1
    if(self.heroVo.realiseID)then
        self.curChooseCard=self.heroVo.realiseID
    end
    self:initLayer()

    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 50,G_VisibleSizeHeight - 375),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(25,120))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(0)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function heroRealiseDialog:eventHandler(handler,fn,idx,cel)
    local strSize2 = 20
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =25
    end
    if fn=="numberOfCellsInTableView" then
        return 2
    elseif fn=="tableCellSizeForIndex" then
        local cellHeight
        if(idx==0)then
            if(G_isIphone5())then
                cellHeight=420
            else
                cellHeight=285
            end
        else
            cellHeight=300
        end
        return CCSizeMake(G_VisibleSizeWidth - 50,cellHeight)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        if(idx==0)then
            self.cell1=cell
            local cellHeight
            if(G_isIphone5())then
                cellHeight=420
            else
                cellHeight=285
            end
            local skillNum
            if(heroVoApi:heroHonor2IsOpen())then
                skillNum=2
            else
                skillNum=1
            end
            local hid=self.heroVo.hid
            for i=1,skillNum do
                local function switchCard(object,fn,tag)
                    if G_checkClickEnable()==false then
                        do return end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    if(self.switching==true)then
                        do return end
                    end
                    if(skillNum==1 or tag==self.curChooseCard)then
                        do return end
                    end
                    if(tag>1 and self.heroVo.productOrder<=heroFeatCfg.fusionLimit2[1])then
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("hero_honor_unlock2"),30)
                        do return end
                    end
                    if(tag)then
                        self:switchCard(tag)
                    end
                end
                local depth=math.abs(self.curChooseCard - i)
                local background=LuaCCSprite:createWithSpriteFrameName("heroHonorBg1.png",switchCard)
                background:setTag(i)
                background:setTouchPriority(-(self.layerNum-1)*20-3-(skillNum-depth))
                background:setIsSallow(true)
                background:setAnchorPoint(ccp(0,0.5))
                background:setPosition((G_VisibleSizeWidth - 50 - background:getContentSize().width*skillNum + 40*(skillNum - 1))/2 + (background:getContentSize().width - 40)*(i - 1),cellHeight/2 + 30*(i - 1.5))
                cell:addChild(background,skillNum - depth)
                self.cardList[i]=background
                background:setScale(math.pow(0.9,depth))
                local mask=CCSprite:createWithSpriteFrameName("heroHonorBg2.png")
                mask:setTag(101)
                mask:setColor(G_ColorBlack)
                mask:setOpacity(255 - math.floor(255*math.pow(0.5,depth)))
                mask:setAnchorPoint(ccp(0,0))
                mask:setPosition(0,0)
                background:addChild(mask,9)
                local background2=CCSprite:createWithSpriteFrameName("heroHonorBg2.png")
                background2:setTag(102)
                if(i==self.curChooseCard)then
                    background2:setVisible(false)
                else
                    background:setOpacity(0)
                end
                background2:setAnchorPoint(ccp(0,0))
                background2:setPosition(0,0)
                background:addChild(background2)

                -- local realIndex=self.curChooseCard + i - 1
                -- if(realIndex>skillNum)then
                --     realIndex=realIndex - skillNum
                -- end
                local realIndex=i
                local iconBg=CCSprite:createWithSpriteFrameName("heroHonorSkillBorder.png")
                iconBg:setPosition(background:getContentSize().width/2,background:getContentSize().height - 90)
                background:addChild(iconBg)
                if(self.ownedSkillList[realIndex] and self.ownedSkillList[realIndex][1])then
                    local sid=self.ownedSkillList[realIndex][1]
                    local skillLevel=self.ownedSkillList[realIndex][2]
                    local nameStr=getlocal(heroSkillCfg[sid].name)
                    local function showSkillDesc()
                        if self.tv:getIsScrolled()==true then
                            do return end
                        end
                        if G_checkClickEnable()==false then
                            do return end
                        else
                            base.setWaitTime=G_getCurDeviceMillTime()
                        end
                        if(self.curChooseCard~=realIndex)then
                            base.setWaitTime=0
                            switchCard(nil,nil,realIndex)
                        else
                            heroVoApi:showHeroSkillDescDialog(hid,sid,self.heroVo.productOrder,skillLevel,true,self.layerNum + 1)
                        end
                    end
                    local icon = LuaCCSprite:createWithFileName(heroVoApi:getSkillIconBySid(sid),showSkillDesc)
                    icon:setTag(realIndex)
                    icon:setTouchPriority(-(self.layerNum-1)*20-11)
                    icon:setScale(100/icon:getContentSize().width)
                    icon:setPosition(ccp(background:getContentSize().width/2,background:getContentSize().height - 90))
                    background:addChild(icon)
                    local icon2=CCSprite:createWithSpriteFrameName("datebaseShow2.png")
                    icon2:setAnchorPoint(ccp(1,0))
                    icon2:setPosition(icon:getContentSize().width - 5,5)
                    icon:addChild(icon2)
                    local nameBg=LuaCCScale9Sprite:createWithSpriteFrameName("heroHonorBg3.png",CCRect(40,20,90,20),showSkillDesc)
                    nameBg:setContentSize(CCSizeMake(background:getContentSize().width - 20,85))
                    nameBg:setPosition(background:getContentSize().width/2,(background:getContentSize().height - 150)/2 + 5)
                    background:addChild(nameBg)
                    local color
                    if skillLevel then
                        color=heroVoApi:getSkillColorByLv(skillLevel)
                    else
                        color=G_ColorWhite
                    end
                    local nameLb=GetTTFLabelWrap(nameStr,strSize2,CCSizeMake(background:getContentSize().width - 30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                    nameLb:setColor(color)
                    nameLb:setPosition(background:getContentSize().width/2,(background:getContentSize().height - 150)/2 + 20)
                    background:addChild(nameLb)
                    local lvLb=GetTTFLabel(getlocal("fightLevel",{skillLevel}),25)
                    lvLb:setPosition(background:getContentSize().width/2,23)
                    background:addChild(lvLb)
                else
                    local icon=CCSprite:createWithSpriteFrameName("heroHeadBG.png")
                    icon:setScale(100/icon:getContentSize().width)
                    icon:setPosition(ccp(background:getContentSize().width/2,background:getContentSize().height - 90))
                    background:addChild(icon)
                    if(self.heroVo.productOrder<heroFeatCfg.fusionLimit + realIndex)then
                        local lockIcon=CCSprite:createWithSpriteFrameName("LockIcon.png")
                        lockIcon:setPosition(background:getContentSize().width/2,background:getContentSize().height - 90)
                        background:addChild(lockIcon)
                        local lockLb=GetTTFLabelWrap(getlocal("hero_honor_unlock2"),strSize2,CCSizeMake(background:getContentSize().width - 30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                        lockLb:setPosition(background:getContentSize().width/2,(background:getContentSize().height - 150)/2)
                        background:addChild(lockLb)
                    end
                end
            end
        else
            self.cell2=cell
            self:refreshCell2()
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

function heroRealiseDialog:refresh()
    self:updateSkillList()

    local qualityLevel,qualityStr,color=heroVoApi:getQualityLevel(self.heroVo.realiseNum)
    if(qualityLevel>=#heroFeatCfg.aptitude - 1)then
        qualityStr=qualityStr..getlocal("hero_honor_level_max")
    end
    local skillMaxLevel,isLevelMax=heroVoApi:getSkillMaxLevel(self.heroVo.hid)

    local qualityLvLb=self.bgLayer:getChildByTag(102)
    if qualityLvLb then
        qualityLvLb=tolua.cast(qualityLvLb,"CCNode")
        local qualityLvLbNew=G_getRichTextLabel(getlocal("hero_honor_quality_level",{qualityStr}),{G_ColorWhite,color,G_ColorWhite},26,300,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        qualityLvLbNew:setTag(102)
        qualityLvLbNew:setAnchorPoint(ccp(0,0.5))
        qualityLvLbNew:setPosition(240,G_VisibleSizeHeight-170)
        self.bgLayer:addChild(qualityLvLbNew)
        qualityLvLb:removeFromParentAndCleanup(true)
    end
    local maxSkillLvLb=self.bgLayer:getChildByTag(103)
    if maxSkillLvLb then
        maxSkillLvLb=tolua.cast(maxSkillLvLb,"CCLabelTTF")
        local skillLevelStr=getlocal("hero_honor_skill_level",{skillMaxLevel})
        if isLevelMax==true then
            skillLevelStr=skillLevelStr..getlocal("hero_honor_level_max")
        end
        maxSkillLvLb:setString(skillLevelStr)
    end

    local propItem=heroVoApi:getPropItem(self.heroVo.hid)
    local propNum=0
    local hasPropNum=0
    local propName=""
    local pid
    if propItem and propItem.num and propItem.key then
        propNum=propItem.num
        pid=(tonumber(propItem.key) or tonumber(RemoveFirstChar(propItem.key)))
        propName=propItem.name
    end
    if pid then
        hasPropNum=bagVoApi:getItemNumId(pid)
    end
    if self.propLb then
        self.propLb:setString(FormatNumber(propNum))
    end
    if self.propNumLb then
        local pStr=getlocal("ownedGem",{FormatNumber(hasPropNum)})
        self.propNumLb:setString(pStr)
    end

    if self.gemLb then
        local gemCost=heroVoApi:getGemCost(self.heroVo.hid)
        self.gemLb:setString(gemCost)
    end
    if(self.gemNumLb)then
        self.gemNumLb:setString(getlocal("ownedGem",{FormatNumber(playerVoApi:getGems())}))
    end

    if self.tv then
        self.cardList={}
        local recordPoint=self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
end

function heroRealiseDialog:switchCard(index)
    if(self.cell1==nil)then
        do return end
    end
    self.switching=true
    local cellHeight
    if(G_isIphone5())then
        cellHeight=420
    else
        cellHeight=285
    end
    local skillNum
    if(heroVoApi:heroHonor2IsOpen())then
        skillNum=2
    else
        skillNum=1
    end
    for i=1,skillNum do
        local depth=math.abs(index - i)
        local card=self.cardList[i]
        card:setTouchPriority(-(self.layerNum-1)*20-3-(skillNum-depth))
        local distance
        if(i==1)then
            distance=40
        else
            distance=-40
        end
        local move1=CCMoveTo:create(0.3,ccp(card:getPositionX() - distance,cellHeight/2))
        local function onMove1()
            self.cell1:reorderChild(card,skillNum - depth)
            if(i~=index)then
                card:setOpacity(0)
                local background2=tolua.cast(card:getChildByTag(102),"CCSprite")
                background2:setVisible(true)
            else
                card:setOpacity(255)
                local background2=tolua.cast(card:getChildByTag(102),"CCSprite")
                background2:setVisible(false)
            end
        end
        local callFunc1=CCCallFunc:create(onMove1)
        local move2=CCMoveTo:create(0.3,ccp(card:getPositionX(),cellHeight/2 + 15*math.pow(-1,index - i + 1)))
        local function onMove2()
            self.switching=false
            self:refreshCell2()
        end
        local callFunc2=CCCallFunc:create(onMove2)
        local acArr=CCArray:create()
        acArr:addObject(move1)
        acArr:addObject(callFunc1)
        acArr:addObject(move2)
        acArr:addObject(callFunc2)
        local seq=CCSequence:create(acArr)
        local scaleTo=CCScaleTo:create(0.6,math.pow(0.9,depth))
        local arr=CCArray:create()
        arr:addObject(seq)
        arr:addObject(scaleTo)
        local spawn=CCSpawn:create(arr)
        card:runAction(spawn)
        local mask=tolua.cast(card:getChildByTag(101),"CCSprite")
        local fadeTo=CCFadeTo:create(0.6,255 - math.floor(255*math.pow(0.5,depth)))
        mask:runAction(fadeTo)
    end
    self.curChooseCard=index
end

function heroRealiseDialog:refreshCell2()
    local strSize2 = 20
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =25
    end
    if(self.cell2 and self.cell2.getChildByTag)then
        local cellBg=self.cell2:getChildByTag(101)
        if(cellBg)then
            cellBg=tolua.cast(cellBg,"CCScale9Sprite")
            cellBg:removeFromParentAndCleanup(true)
        end
        local function nilFunc( ... )
        end
        local cellBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20,20,10,10),nilFunc)
        cellBg:setTag(101)
        cellBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 50,300))
        cellBg:setAnchorPoint(ccp(0,0))
        cellBg:setPosition(0,0)
        self.cell2:addChild(cellBg)
        local bgWidth=(G_VisibleSizeWidth - 80)/3
        local flag
        if((self.heroVo.realiseID==nil and self.curChooseCard==1) or (self.heroVo.realiseID==self.curChooseCard))then
            flag=true
        else
            flag=false
        end
        for i=1,3 do
            local skillBg=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(30,30,40,40),nilFunc)
            skillBg:setContentSize(CCSizeMake(bgWidth,280))
            skillBg:setPosition(15 + bgWidth*(i - 0.5),150)
            cellBg:addChild(skillBg)
            local iconBg=CCSprite:createWithSpriteFrameName("heroHonorSkillBorder.png")
            iconBg:setPosition(bgWidth/2,140)
            skillBg:addChild(iconBg)
            if(flag==true and self.newSkillList and self.newSkillList[i] and self.newSkillList[i][1])then
                local hid=self.heroVo.hid
                local sid=self.newSkillList[i][1]
                local skillLevel=self.newSkillList[i][2]
                local function showSkillDesc( ... )
                    if self.tv:getIsScrolled()==true then
                        do return end
                    end
                    if G_checkClickEnable()==false then
                        do return end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    heroVoApi:showHeroSkillDescDialog(hid,sid,self.heroVo.productOrder,skillLevel,true,self.layerNum + 1)
                end
                local nameStr,icon
                if(sid==heroFeatCfg.tianming.id)then
                    nameStr=getlocal(heroFeatCfg.tianming.name)
                    icon=LuaCCSprite:createWithSpriteFrameName(heroFeatCfg.tianming.icon,showSkillDesc)
                else
                    nameStr=getlocal(heroSkillCfg[sid].name).. " "..getlocal("fightLevel",{skillLevel})
                    icon=LuaCCSprite:createWithFileName(heroVoApi:getSkillIconBySid(sid),showSkillDesc)
                end
                icon:setTouchPriority(-(self.layerNum-1)*20-2)
                icon:setPosition(ccp(bgWidth/2,140))
                skillBg:addChild(icon)
                local icon2=CCSprite:createWithSpriteFrameName("datebaseShow2.png")
                icon2:setAnchorPoint(ccp(1,0))
                icon2:setPosition(icon:getContentSize().width - 5,5)
                icon:addChild(icon2)
                local color=G_ColorWhite
                if skillLevel then
                    color=heroVoApi:getSkillColorByLv(skillLevel)
                end
                local nameLb=GetTTFLabelWrap(nameStr,strSize2,CCSizeMake(bgWidth - 20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                nameLb:setColor(color)
                nameLb:setPosition(bgWidth/2,230)
                skillBg:addChild(nameLb)
                local function onReplace()
                    if self.tv:getIsScrolled()==true then
                        do return end
                    end
                    if G_checkClickEnable()==false then
                        do return end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)
                    local function onConfirm()
                        local function heroUseskillCallback(fn,data)
                            local ret,sData=base:checkServerData(data)
                            if ret==true then
                                if(sid==heroFeatCfg.tianming.id)then
                                    local skillTb=self.heroVo.skill
                                    local heroVo=heroVoApi:getHeroByHid(self.heroVo.hid)
                                    local skillTbNew=heroVo.skill
                                    local upSid,oldLv,newLv
                                    for sid,sLv in pairs(skillTbNew) do
                                        if(skillTb[sid] and sLv>skillTb[sid])then
                                            upSid=sid
                                            oldLv=skillTb[sid]
                                            newLv=sLv
                                        end
                                    end
                                    self:showTianmingDialog(upSid,oldLv,newLv)
                                else
                                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("hero_honor_change_success"),30)
                                end
                                self:refresh()
                                if self.parent and self.parent.refreshTv then
                                    self.parent:refreshTv()
                                end
                            end
                        end
                        local sidIndex=heroVoApi:getHonorSidIndex(hid,sid)
                        if sidIndex and sidIndex>0 then
                            if(self.curChooseCard==1)then
                                socketHelper:heroUseskill(hid,sidIndex,nil,heroUseskillCallback)
                            else
                                socketHelper:heroUseskill(hid,sidIndex,self.curChooseCard,heroUseskillCallback)
                            end
                        end
                    end
                    local replaceID=self.heroVo.realiseID or 1
                    if(self.ownedSkillList[replaceID] and self.ownedSkillList[replaceID][1])then
                        local oldSid=self.ownedSkillList[replaceID][1]
                        local oldSkillLevel=self.ownedSkillList[replaceID][2]
                        local oldNameStr=getlocal(heroSkillCfg[oldSid].name)
                        if(sid==heroFeatCfg.tianming.id)then
                            onConfirm()
                        else
                            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("hero_honor_change_skill_desc",{getlocal(heroSkillCfg[sid].name),skillLevel,oldNameStr,oldSkillLevel}),nil,self.layerNum+1)
                        end
                    else
                        onConfirm()
                    end
                end
                local menuItem
                if(sid==heroFeatCfg.tianming.id)then
                    menuItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onReplace,10,getlocal("use"),25/0.8)
                else
                    menuItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onReplace,10,getlocal("hero_honor_change"),25/0.8)
                end
                menuItem:setScale(0.8)
                local menu = CCMenu:createWithItem(menuItem);
                menu:setPosition(ccp(bgWidth/2,45))
                menu:setTouchPriority(-(self.layerNum-1)*20-2);
                skillBg:addChild(menu)
            else
                if(i==3 and self.heroVo.productOrder<=heroFeatCfg.fusionLimit2[1])then
                    local lockIcon=CCSprite:createWithSpriteFrameName("LockIcon.png")
                    lockIcon:setPosition(ccp(bgWidth/2,140))
                    skillBg:addChild(lockIcon)
                    local lockStr
                    if(heroVoApi:heroHonor2IsOpen())then
                        lockStr=getlocal("hero_honor_unlock2")
                    else
                        lockStr=getlocal("alliance_notOpen")
                    end
                    local lockLb=GetTTFLabelWrap(lockStr,25,CCSizeMake(bgWidth - 20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                    lockLb:setPosition(bgWidth/2,45)
                    skillBg:addChild(lockLb)
                end
            end
        end
        local newSkillList={}
        if(self.curChooseCard==self.heroVo.realiseID or self.curChooseCard==1 and self.heroVo.realiseID==nil)then
            newSkillList=self.newSkillList
        end
        if(SizeOfTable(newSkillList)==0 or self.curChooseCard>self.heroVo.productOrder - heroFeatCfg.fusionLimit)then
            local mask=CCSprite:createWithSpriteFrameName("BlackBg.png")
            mask:setScaleX((G_VisibleSizeWidth - 50)/10)
            mask:setScaleY(300/10)
            mask:setOpacity(180)
            mask:setPosition((G_VisibleSizeWidth - 50)/2,150)
            cellBg:addChild(mask)
            local unlockStr
            if(self.curChooseCard>self.heroVo.productOrder - heroFeatCfg.fusionLimit)then
                unlockStr=getlocal("hero_honor_unlock2")
            else
                unlockStr=getlocal("hero_honor_realiseGet")
            end
            local unlockLb=GetTTFLabelWrap(unlockStr,20,CCSizeMake(G_VisibleSizeWidth - 60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            unlockLb:setColor(G_ColorYellowPro)
            unlockLb:setPosition((G_VisibleSizeWidth - 50)/2,150)
            cellBg:addChild(unlockLb)
        end
    end
end

function heroRealiseDialog:showTianmingDialog(sid,oldLv,newLv)
    local strSize2 =21
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =25
    end
    if(self.tmLayer)then
        do return end
    end
    local layerNum=self.layerNum + 1
    self.tmLayer=CCLayer:create()
    self.bgLayer:addChild(self.tmLayer,9)
    local function onHide()
        if(self.tmLayer and self.tmLayer.removeFromParentAndCleanup)then
            self.tmLayer:removeFromParentAndCleanup(true)
            self.tmLayer=nil
        end
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),onHide)
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
    touchDialogBg:setOpacity(180)
    touchDialogBg:setAnchorPoint(ccp(0,0))
    touchDialogBg:setPosition(ccp(0,0))
    self.tmLayer:addChild(touchDialogBg)
    local bgHeight=400
    local lvStr,value,isMax=heroVoApi:getHeroSkillLvAndValue(self.heroVo.hid,sid,self.heroVo.productOrder)
    local descLb=GetTTFLabelWrap(getlocal(heroSkillCfg[sid].des,{value}),strSize2,CCSizeMake(430,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    if(descLb:getContentSize().height>110)then
        bgHeight=bgHeight + descLb:getContentSize().height - 110
    end
    local panelBg=LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),onHide)
    panelBg:setContentSize(CCSizeMake(500,bgHeight))
    panelBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
    self.tmLayer:addChild(panelBg)
    local posY=bgHeight - 40
    local titleLb=GetTTFLabelWrap(getlocal("hero_honor_tianmingTitle"),strSize2,CCSizeMake(460,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLb:setColor(G_ColorYellowPro)
    titleLb:setPosition(250,posY)
    panelBg:addChild(titleLb)
    posY=posY - titleLb:getContentSize().height/2
    local icon=CCSprite:create(heroVoApi:getSkillIconBySid(sid))
    icon:setPosition(250,posY - 10 - icon:getContentSize().height/2)
    panelBg:addChild(icon)
    posY=posY - 10 - icon:getContentSize().height
    local nameLb=GetTTFLabel(getlocal(heroSkillCfg[sid].name),strSize2)
    nameLb:setPosition(250,posY - 20)
    panelBg:addChild(nameLb)
    posY=posY - 40
    local lvLb1=GetTTFLabel(getlocal("fightLevel",{oldLv}),25)
    lvLb1:setAnchorPoint(ccp(1,0.5))
    lvLb1:setPosition(230,posY - 15)
    panelBg:addChild(lvLb1)
    local lvChangeLb=GetTTFLabel("→",strSize2)
    lvChangeLb:setColor(G_ColorGreen)
    lvChangeLb:setPosition(250,posY - 15)
    panelBg:addChild(lvChangeLb)
    local lvLb2=GetTTFLabel(getlocal("fightLevel",{newLv}),25)
    lvLb2:setAnchorPoint(ccp(0,0.5))
    lvLb2:setPosition(270,posY - 15)
    panelBg:addChild(lvLb2)
    posY=posY - 30
    local descBg=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(30,30,40,40),onHide)
    descBg:setContentSize(CCSizeMake(460,posY - 30))
    descBg:setAnchorPoint(ccp(0.5,0))
    descBg:setPosition(250,30)
    panelBg:addChild(descBg)
    descLb:setPosition(250,30 + (posY - 30)/2)
    panelBg:addChild(descLb)
end

function heroRealiseDialog:dispose()
    self.layerNum=nil
    self.heroVo=nil
    self.useMedalBtn=nil
    self.skillList=nil
    self.newSKillNum=0
    self.cardList=nil
    self.cell1=nil
    self.cell2=nil
    self.tmLayer=nil
    spriteController:removePlist("public/datebaseShow.plist")
    spriteController:removeTexture("public/datebaseShow.png")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/hero/heroHonorBackground.jpg")
end