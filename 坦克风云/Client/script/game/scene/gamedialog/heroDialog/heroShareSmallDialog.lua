heroShareSmallDialog=shareSmallDialog:new()
function heroShareSmallDialog:new(isSelect)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.isSelect = isSelect
    return nc
end
--isSelect 用于布置将领时的特殊使用
function heroShareSmallDialog:showHeroInfoSmallDialog(player,hero,layerNum,bgSrc,inRect,isSelect)
    local sd=heroShareSmallDialog:new(isSelect)
    sd:create(bgSrc,inRect,CCSizeMake(550,500),player,hero,layerNum,nil,true)
end

function heroShareSmallDialog:init()
    if newGuidMgr:isNewGuiding()==true then
        do return end
    end
    spriteController:addPlist("public/nbSkill.plist")
    spriteController:addTexture("public/nbSkill.png")
    spriteController:addPlist("public/datebaseShow.plist")
    spriteController:addTexture("public/datebaseShow.png")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage2.plist")


    local hero=self.share
    local bgWidth=550
    local cellWidth=bgWidth-20
    local titleBgH=self.isSelect and 0 or 80
    local needHeight = self.isSelect and 30 or 100
    self.titleBgH = titleBgH
    local function nilFunc()
    end
    local lbSize=CCSize(440,0)
    local labelSize=20
    local iconSize=60
    local bgHeight=0
    local hid=hero.hid --将领id
    local level=hero.lv --将领等级
    local productOrder=hero.gd --将领品阶
    local adjutantStr = hero.ajt --将领副官数据
    local heroStr = hid.."-"..productOrder.."-"..level
    if adjutantStr and adjutantStr~="" then
        heroStr = heroStr.."-"..adjutantStr
    end
    local adjutants = heroAdjutantVoApi:decodeAdjutant(heroStr)

    local function getCellHeight()
        local cellHeight=0
        if false and false and heroAdjutantVoApi:isOpen() == true and heroAdjutantVoApi:isCanEquipAdjutant(hero.heroVo) then
            cellHeight = cellHeight + 150
        end
        local property=hero.p --属性加成
        local sbSkill=hero.sb --常规技能
        local nbSkill=hero.nb --授勋技能
        local data={property,sbSkill,nbSkill}
        for k,v in pairs(data) do
            local count=SizeOfTable(v)
            if count>0 then
                if count%2>0 then
                    count=math.floor(count/2)+1
                else
                    count=math.floor(count/2)
                end
                cellHeight=cellHeight+count*iconSize+(count-1)*10+20
                if k==2 or k==3 then
                    cellHeight=cellHeight+80
                end
            end
        end
        return cellHeight
    end
    local scrollFlag=false
    local cellHeight=getCellHeight()
    local tvHeight=cellHeight
    local maxHeight=G_VisibleSizeHeight-450
    if tvHeight>maxHeight then
        tvHeight=maxHeight
        scrollFlag=true
    end

    bgHeight=bgHeight+titleBgH+10
    local scale=0.7
    local heroIcon=heroVoApi:getHeroIcon(hid,productOrder,nil,nil,nil,nil,nil,{adjutants=adjutants})
    heroIcon:setAnchorPoint(ccp(0,0.5))
    heroIcon:setScale(scale)
    self.bgLayer:addChild(heroIcon,2)
    local heroIconSize=heroIcon:getContentSize()

    bgHeight=bgHeight+heroIconSize.height*scale+30

    local color=heroVoApi:getHeroColor(productOrder)
    local lbName=GetTTFLabelWrap(getlocal(heroListCfg[hid].heroName),28,CCSizeMake(bgWidth-300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    lbName:setAnchorPoint(ccp(0,0))
    lbName:setColor(color)
    self.bgLayer:addChild(lbName,2)
    local hlvLb=GetTTFLabel(G_LV()..level,24)
    hlvLb:setAnchorPoint(ccp(0,1))
    self.bgLayer:addChild(hlvLb)

    self.detailBg:setContentSize(CCSizeMake(cellWidth,tvHeight+20))
    bgHeight=bgHeight+self.detailBg:getContentSize().height+20

    self.bgSize=CCSizeMake(bgWidth,bgHeight)
    self.bgLayer:setContentSize(CCSizeMake(bgWidth,bgHeight))

    -- self.playerNameLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-40))
    heroIcon:setPosition(ccp(40,self.bgSize.height-heroIconSize.height*scale*0.5-needHeight))
    lbName:setPosition(heroIcon:getPositionX()+heroIconSize.width*scale+20,heroIcon:getPositionY()+5)
    hlvLb:setPosition(ccp(lbName:getPositionX(),heroIcon:getPositionY()-5))
    self.detailBg:setPosition(bgWidth/2,heroIcon:getPositionY()-heroIconSize.height*scale*0.5-20)

    local function itemTouch()
        if G_checkClickEnable()==false then
            return
        end
        -- 显示英雄信息
        local td=smallDialog:new()
        --获取hero描述lable的高度，动态的传给smallDialog
        local lable=GetTTFLabelWrap(heroVoApi:getHeroDes(hid),25,CCSize(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        local heroVo={hid=hid,productOrder=productOrder}
        local dialog=td:initHeroInfo("PanelPopup.png",CCSizeMake(500,200+lable:getContentSize().height+25+60),CCRect(0,0,400,350),CCRect(168,86,10,10),nil,true,true,self.layerNum+1,heroVo,28)
        sceneGame:addChild(dialog,self.layerNum+1)
        PlayEffect(audioCfg.mouseClick)
    end 
    -- 添加英雄信息按钮
    local heroInfoItem=GetButtonItem("hero_infoBtn.png","hero_infoBtn.png","hero_infoBtn.png",itemTouch,11)
    heroInfoItem:setScale(0.8)
    local menu=CCMenu:createWithItem(heroInfoItem)
    menu:setPosition(ccp(bgWidth-90,heroIcon:getPositionY()))
    menu:setTouchPriority(-(self.layerNum-1)*20-4)

    self.bgLayer:addChild(menu)
    local propertyCfg={
        {icon="skill_02.png",lb=getlocal("sample_skill_name_102")},
        {icon="skill_01.png",lb=getlocal("sample_skill_name_101")},
        {icon="attributeARP.png",lb=getlocal("dmg")},
        {icon="attributeArmor.png",lb=getlocal("hlp")},
        {icon="skill_03.png",lb=getlocal("sample_skill_name_103")},
        {icon="skill_04.png",lb=getlocal("sample_skill_name_104")},
        {icon="positiveHead.png",lb=getlocal("firstValue")},
    }
    local propertyNewCfg={
        atk={icon="attributeARP.png",lb={getlocal("dmg"),}},
        hlp={icon="attributeArmor.png",lb={getlocal("hlp"),}},
        hit={icon="skill_01.png",lb={getlocal("sample_skill_name_101"),}},
        eva={icon="skill_02.png",lb={getlocal("sample_skill_name_102"),}},
        cri={icon="skill_03.png",lb={getlocal("sample_skill_name_103"),}},
        res={icon="skill_04.png",lb={getlocal("sample_skill_name_104"),}},
        first={icon="positiveHead.png",lb={getlocal("firstValue"),}},
    }
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return 1
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(cellWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            local posY=cellHeight
            local labelWidth=180
            local labelSize=20
            local firstPosX=20
            local posY=cellHeight-10
            local property=hero.p --属性加成
            local sbSkill=hero.sb --常规技能
            local nbSkill=hero.nb --授勋技能
            local data={sbSkill,nbSkill}
            local count=SizeOfTable(property)

            if false and heroAdjutantVoApi:isOpen() == true and heroAdjutantVoApi:isCanEquipAdjutant(hero.heroVo) then
                local adjData = heroAdjutantVoApi:getAdjutant(hid)
                local adjIconStartPosX
                local adjIconScapeW = 18
                for i = 1, 4 do
                    local adjId, adjActivateState, adjCurLv, adjIconCallFunc
                    if adjData and adjData[i] then
                      if adjData[i][1] == 1 then
                            adjActivateState = true
                        end
                        if adjData[i][3] then
                            adjId = adjData[i][3]
                            adjCurLv = adjData[i][4]
                            adjIconCallFunc = function()
                              heroAdjutantVoApi:showInfoSmallDialog(self.layerNum + 1, {adjId, adjCurLv})
                            end
                        end
                    end
                    local adjIcon = heroAdjutantVoApi:getAdjutantIcon(adjId, adjActivateState, true, adjIconCallFunc, true)
                    adjIcon:setScale(0.4)
                    if adjIconStartPosX == nil then
                        adjIconStartPosX = (cellWidth - (adjIcon:getContentSize().width * adjIcon:getScale() * 4 + (4 - 1) * adjIconScapeW)) / 2
                    end
                    adjIcon:setAnchorPoint(ccp(0, 1))
                    adjIcon:setPosition(adjIconStartPosX + (i - 1) * (adjIcon:getContentSize().width * adjIcon:getScale() + adjIconScapeW), posY)
                    adjIcon:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
                    cell:addChild(adjIcon)
                    if adjId and adjCurLv then
                      heroAdjutantVoApi:setAdjLevel(adjIcon, adjId, adjCurLv)
                    else
                      local tipsStr, tipsLabelColor
                      if adjActivateState == true then --可装配
                        tipsStr = getlocal("skill_equip_empty2")
                        tipsLabelColor = G_ColorGreen
                      else
                        local needStarLv = heroAdjutantVoApi:getAdjutantCfg().needHeroStar[i]
                        if productOrder >= needStarLv then --可激活
                          tipsStr = getlocal("not_activated")
                        else --将领星级达到x星可解锁
                          tipsStr = getlocal("ineffectiveStr")
                        end
                        tipsLabelColor = G_ColorRed
                      end
                      local tipsLabel = GetTTFLabelWrap(tipsStr, 30, CCSizeMake(adjIcon:getContentSize().width - 6, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
                      tipsLabel:setPosition(adjIcon:getContentSize().width / 2, 55)
                      tipsLabel:setColor(tipsLabelColor)
                      adjIcon:addChild(tipsLabel)
                    end
                end
                posY = posY - 150
            end

            for i=1,#property do
                local item=property[i]
                local ptype=item[3]
                local iconSp
                local nameStr
                if ptype then
                    if ptype=="first" then
                        iconSp=GetBgIcon(propertyNewCfg[ptype].icon,nil,nil,55)
                    else
                        iconSp=CCSprite:createWithSpriteFrameName(propertyNewCfg[ptype].icon)
                    end
                    nameStr=propertyNewCfg[ptype].lb[1]
                else
                    iconSp=CCSprite:createWithSpriteFrameName(propertyCfg[i].icon)
                    if i==count then
                        iconSp=GetBgIcon(propertyCfg[i].icon,nil,nil,55)
                    end
                    nameStr=propertyCfg[i].lb
                end
                if iconSp then
                    local iconScale=iconSize/iconSp:getContentSize().width
                    iconSp:setAnchorPoint(ccp(0,1))
                    local posX=firstPosX
                    if i%2==0 then
                        posX=cellWidth/2+20
                    end
                    iconSp:setPosition(ccp(posX,posY-math.floor((i-1)/2)*(iconSize+10)))
                    cell:addChild(iconSp,2)
                    iconSp:setScale(iconScale)
                    nameStr=nameStr or ""
                    local nameLb=GetTTFLabelWrap(nameStr,labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
                    nameLb:setAnchorPoint(ccp(0,0))
                    nameLb:setPosition(ccp(iconSp:getPositionX()+iconSize+10,iconSp:getPositionY()-iconSize/2))
                    cell:addChild(nameLb)

                    local valueLb
                    if item[1] and item[1]~="-" then
                        valueLb=GetTTFLabel("+"..item[1],labelSize)
                        valueLb:setAnchorPoint(ccp(0,1))
                        valueLb:setPosition(ccp(iconSp:getPositionX()+iconSize+10,iconSp:getPositionY()-iconSize/2))
                        cell:addChild(valueLb)
                    end
                    if item[2] and item[2]~="-" then
                        local addLb=GetTTFLabel("+"..item[2],labelSize)
                        addLb:setAnchorPoint(ccp(0,1))
                        if valueLb then
                            addLb:setPosition(ccp(valueLb:getPositionX()+valueLb:getContentSize().width,iconSp:getPositionY()-iconSize/2))
                        else
                            addLb:setPosition(ccp(iconSp:getPositionX()+iconSize+10,iconSp:getPositionY()-iconSize/2))
                        end
                        addLb:setColor(G_ColorGreen)
                        cell:addChild(addLb)
                    end
                end
            end
            if count%2>0 then
                count=math.floor(count/2)+1
            else
                count=math.floor(count/2)
            end
            posY=posY-count*iconSize-(count-1)*10-10

            for k,ptab in pairs(data) do
                count=SizeOfTable(ptab)
                if count==0 then
                    do break end
                end
                local isHonor=false
                local titlePic,titleStr,color
                if k==1 then
                    titlePic="nbSkillTitle1.png"
                    titleStr=getlocal("hero_honor_commonSkill")
                else
                    titlePic="nbSkillTitle2.png"
                    titleStr=getlocal("hero_honor_used_honor_skill")
                    color=G_ColorYellowPro
                    isHonor=true
                end
                if titlePic and titleStr then
                    local titleBg=CCSprite:createWithSpriteFrameName("groupSelf.png")
                    titleBg:setAnchorPoint(ccp(0.5,1))
                    titleBg:setScaleX((cellWidth+140)/titleBg:getContentSize().width)
                    titleBg:setScaleY(60/titleBg:getContentSize().height)
                    titleBg:setPosition(cellWidth/2+20,posY)
                    cell:addChild(titleBg)
                    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
                    lineSp:setAnchorPoint(ccp(0.5,0.5))
                    lineSp:setScaleX((cellWidth-30)/lineSp:getContentSize().width)
                    lineSp:setPosition(ccp(cellWidth/2,titleBg:getPositionY()-2))
                    cell:addChild(lineSp)
                    local titleSp=CCSprite:createWithSpriteFrameName(titlePic)
                    titleSp:setAnchorPoint(ccp(0.5,1))
                    titleSp:setPosition((cellWidth)/2,posY)
                    cell:addChild(titleSp,1)
                    local titleLb=GetTTFLabel(titleStr,25)
                    titleLb:setAnchorPoint(ccp(0.5,1))
                    titleLb:setPosition(cellWidth/2,posY-titleSp:getContentSize().height)
                    cell:addChild(titleLb,1)
                    if color then
                        titleLb:setColor(color)
                    end
                    posY=posY-80
                end
                for idx,item in pairs(ptab) do
                    local sid=item[1]
                    local skillLv=item[2]
                    local awakenSid=item[3]
                    local skillId=awakenSid or sid
                    local posX=firstPosX
                    if idx%2==0 then
                        posX=cellWidth/2+20
                    end
                    local function showSkillDesc()
                        print("showSkillDesc~~~~~~")
                        if self.isSelect ==nil or self.isSelect == false then
                                if self.tv:getIsScrolled()==true then
                                  do return end
                                end
                                if G_checkClickEnable()==false then
                                    do return end
                                else
                                    base.setWaitTime=G_getCurDeviceMillTime()
                                end
                                heroVoApi:showHeroSkillDescDialog(hid,skillId,productOrder,skillLv,isHonor,self.layerNum+1)
                        end
                    end
                    local iconSp=LuaCCSprite:createWithFileName(heroVoApi:getSkillIconBySid(sid),showSkillDesc)
                    local scale=iconSize/iconSp:getContentSize().width
                    iconSp:setTouchPriority(-(self.layerNum-1)*20-2)
                    iconSp:setScale(scale)
                    iconSp:setAnchorPoint(ccp(0,1))
                    iconSp:setPosition(posX,posY-math.floor((idx-1)/2)*(iconSize+10))
                    cell:addChild(iconSp)
                    local icon2=CCSprite:createWithSpriteFrameName("datebaseShow2.png")
                    icon2:setAnchorPoint(ccp(1,0))
                    icon2:setPosition(iconSp:getContentSize().width-5,5)
                    iconSp:addChild(icon2,1)
                    if self.isSelect then
                        icon2:setVisible(false)
                    end

                    local color=G_ColorWhite
                    if skillLv then
                      color=heroVoApi:getSkillColorByLv(skillLv)
                    end
                    local skillId=awakenSid or sid
                    local nameLb=GetTTFLabelWrap(getlocal(heroSkillCfg[skillId].name),labelSize,CCSizeMake(labelWidth,65),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
                    nameLb:setColor(color)
                    nameLb:setAnchorPoint(ccp(0,0))
                    nameLb:setPosition(posX+iconSize+10,iconSp:getPositionY()-iconSize/2)
                    cell:addChild(nameLb)
                    local lvLb=GetTTFLabel(G_LV()..skillLv,labelSize)
                    lvLb:setAnchorPoint(ccp(0,1))
                    lvLb:setPosition(posX+iconSize+10,iconSp:getPositionY()-iconSize/2)
                    cell:addChild(lvLb)
                end
                if count%2>0 then
                    count=math.floor(count/2)+1
                else
                    count=math.floor(count/2)
                end
                posY=posY-count*iconSize-(count-1)*10-10
            end
            return cell
        elseif fn=="ccTouchBegan" then
            isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            isMoved=true
        elseif fn=="ccTouchEnded"  then

        end
    end
    local hd=LuaEventHandler:createHandler(tvCallBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(0,10))
    self.detailBg:addChild(self.tv,2)
    if scrollFlag==true then
        self.tv:setMaxDisToBottomOrTop(120)
    else
        self.tv:setMaxDisToBottomOrTop(0)
    end

    if self.closeBtn and self.isSelect then
        self.closeBtn:setVisible(false)
    end
    if self.isSelect then
            local function touchDialog()
                if self.tv:getIsScrolled()==true then
                    do return end
                end
                PlayEffect(audioCfg.mouseClick)
                self:close()
            end
            local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
            touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-3)
            local rect=CCSizeMake(640,G_VisibleSizeHeight)
            touchDialogBg:setContentSize(rect)
            touchDialogBg:setIsSallow(false) -- 点击事件透下去
            touchDialogBg:setOpacity(0)
            touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))

            self.dialogLayer:addChild(touchDialogBg,1);
    end

end


function heroShareSmallDialog:tick()
end

function heroShareSmallDialog:dispose() --释放方法
    if self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil
    end
    self.touchDialogBg=nil
    spriteController:removePlist("public/nbSkill.plist")
    spriteController:removeTexture("public/nbSkill.png")
    spriteController:removePlist("public/datebaseShow.plist")
    spriteController:removeTexture("public/datebaseShow.png")
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/accessoryImage2.plist")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/accessoryImage2.png")
end
