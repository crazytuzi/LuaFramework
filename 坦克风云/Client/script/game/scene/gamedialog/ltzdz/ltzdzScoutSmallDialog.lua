ltzdzScoutSmallDialog=smallDialog:new()

function ltzdzScoutSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function ltzdzScoutSmallDialog:showScoutInfo(layerNum,istouch,isuseami,callBack,titleStr,parent,isScout,scoutInfo)
	local sd=ltzdzScoutSmallDialog:new()
    sd:initScoutInfo(layerNum,istouch,isuseami,callBack,titleStr,parent,isScout,scoutInfo)
    return sd
end

function ltzdzScoutSmallDialog:initScoutInfo(layerNum,istouch,isuseami,pCallBack,titleStr,parent,isScout,scoutInfo)
	self.isTouch=istouch
    self.isUseAmi=isuseami
    self.layerNum=layerNum
    self.parent=parent
    self.scoutInfo=scoutInfo
    local nameFontSize=30

    ltzdzVoApi:addOrRemoveOpenDialog(1,"ltzdzScoutSmallDialog",self)


    -- base:removeFromNeedRefresh(self) --停止刷新
    base:addNeedRefresh(self)

    local function tmpFunc()
    end
    local rrect=CCRect(0, 50, 1, 1)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setTouchEnabled(true)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true)

    local function touchLuaSpr()
        PlayEffect(audioCfg.mouseClick)
        if pCallBack then
            pCallBack()
        end
        self:close()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(255)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    local dgSize
    if isScout then
        dgSize=CCSizeMake(600,620)
    else
        dgSize=CCSizeMake(600,630)
    end
    local dialogBg=G_getNewDialogBg2(dgSize,self.layerNum,callback,titleStr,25,titleColor)
    self.dialogLayer:addChild(dialogBg,2)
    dialogBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
    self.bgLayer=dialogBg

    self:show()

    if isScout then
        local titleTb={getlocal("ltzdz_scout_time",{GetTimeForItemStr(self.scoutInfo.st)}),25,G_ColorYellowPro}
        local titleBg=G_createNewTitle(titleTb,CCSizeMake(dgSize.width-60,0))
        dialogBg:addChild(titleBg)
        titleBg:setPosition(dgSize.width/2,dgSize.height-60)

        local cityLvLb=GetTTFLabelWrap(getlocal("ltzdz_city_level",{self.scoutInfo.cLevel}),25,CCSizeMake(dgSize.width/2 - 20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        dialogBg:addChild(cityLvLb)
        cityLvLb:setAnchorPoint(ccp(0,0.5))
        cityLvLb:setPosition(10,dgSize.height-85)

        local cityReserveLb=GetTTFLabelWrap(getlocal("ltzdz_city_defense_reserve",{self.scoutInfo.defence}),25,CCSizeMake(dgSize.width/2 - 20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        dialogBg:addChild(cityReserveLb)
        cityReserveLb:setAnchorPoint(ccp(0,0.5))
        cityReserveLb:setPosition(dgSize.width/2+10,dgSize.height-85)
    else
        local slotInfo=scoutInfo.slotInfo
        local iconPic,slotState=ltzdzFightApi:getIconState(slotInfo)
        local logoSp=CCSprite:createWithSpriteFrameName(iconPic)
        logoSp:setScale(0.6)

        local titleTb={slotState,25,G_ColorYellowPro}
        local titleBg,titleLb=G_createNewTitle(titleTb,CCSizeMake(dgSize.width-60,0),false)
        dialogBg:addChild(titleBg)
        titleBg:setPosition(dgSize.width/2,dgSize.height-70)

        local sbLb=GetTTFLabel(titleTb[1],titleTb[2])
        local sbSizeWidth=sbLb:getContentSize().width
        local titlelbWidth=titleLb:getContentSize().width
        -- titleLb:setDimensions(CCSizeMake(titlelbWidth-logoSp:getContentSize().width, 0))
        if sbSizeWidth<titlelbWidth then
            logoSp:setPosition(titlelbWidth/2-logoSp:getContentSize().width/2-sbSizeWidth/2,titleLb:getContentSize().height/2)
        else
            logoSp:setPosition(-logoSp:getContentSize().width/2,titleLb:getContentSize().height/2)
        end
        -- titleLb:setPositionX(titleLb:getPositionX()-logoSp:getContentSize().width/2)
        titleLb:addChild(logoSp)

        local cityLbSize=22 
        local cityLbH=dgSize.height-95
        local startCityLb=GetTTFLabel(ltzdzCityVoApi:getCityName(slotInfo[2]),cityLbSize)
        startCityLb:setAnchorPoint(ccp(1,0.5))
        dialogBg:addChild(startCityLb)
        startCityLb:setPosition(dgSize.width/2-60,cityLbH)

        local endCityLb=GetTTFLabel(ltzdzCityVoApi:getCityName(slotInfo[3]),cityLbSize)
        endCityLb:setAnchorPoint(ccp(0,0.5))
        dialogBg:addChild(endCityLb)
        endCityLb:setPosition(dgSize.width/2+60,cityLbH)

        -- 加箭头 dgSize.width/2
        local arrow=CCSprite:createWithSpriteFrameName("targetArrow.png")
        dialogBg:addChild(arrow)
        arrow:setPosition(dgSize.width/2,cityLbH)
    end
    

    -- 部队信息
    local troopsBg = LuaCCScale9Sprite:createWithSpriteFrameName("st_background.png",CCRect(5, 5, 1, 1),function ()end)
    troopsBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-55,490))
    troopsBg:setAnchorPoint(ccp(0.5,0))
    dialogBg:addChild(troopsBg,2)
    troopsBg:setTouchPriority(-(layerNum-1)*20-2)
    troopsBg:setPosition(ccp(dgSize.width/2,20))

    local lineSp1=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp1:setScaleX((troopsBg:getContentSize().width)/lineSp1:getContentSize().width)
    lineSp1:setPosition(ccp(G_VisibleSizeWidth/2,troopsBg:getContentSize().height))
    troopsBg:addChild(lineSp1)

    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setScaleX((troopsBg:getContentSize().width)/lineSp:getContentSize().width)
    lineSp:setPosition(ccp(G_VisibleSizeWidth/2,0))
    troopsBg:addChild(lineSp)


    local leftFrameBg2=CCSprite:createWithSpriteFrameName("st_frameBg2.jpg")
    leftFrameBg2:setAnchorPoint(ccp(0,0.5))
    leftFrameBg2:setPosition(ccp(0,troopsBg:getContentSize().height/2))
    troopsBg:addChild(leftFrameBg2)
    local rightFrameBg2=CCSprite:createWithSpriteFrameName("st_frameBg2.jpg")
    rightFrameBg2:setFlipX(true)
    rightFrameBg2:setFlipY(true)
    rightFrameBg2:setAnchorPoint(ccp(1,0.5))
    rightFrameBg2:setPosition(ccp(troopsBg:getContentSize().width,troopsBg:getContentSize().height/2))
    troopsBg:addChild(rightFrameBg2)
    local leftFrameBg1=CCSprite:createWithSpriteFrameName("st_frameBg1.png")
    leftFrameBg1:setAnchorPoint(ccp(0,0.5))
    leftFrameBg1:setPosition(ccp(0,troopsBg:getContentSize().height/2))
    troopsBg:addChild(leftFrameBg1)
    local rightFrameBg1=CCSprite:createWithSpriteFrameName("st_frameBg1.png")
    rightFrameBg1:setFlipX(true)
    rightFrameBg1:setAnchorPoint(ccp(1,0.5))
    rightFrameBg1:setPosition(ccp(troopsBg:getContentSize().width,troopsBg:getContentSize().height/2))
    troopsBg:addChild(rightFrameBg1)

    local tankInfo=self.scoutInfo.tank
    local heroInfo=self.scoutInfo.hero
    local aitroopsInfo=self.scoutInfo.aitroops or {0,0,0,0,0,0}
    local tskinList = self.scoutInfo.tskin or {}

    local troopsBgSize=troopsBg:getContentSize()
    local startW=8
    local startH=11
    local jiangeH=5

    -- 为了计算位置
    local sbbgSp=CCSprite:createWithSpriteFrameName("st_select2.png")
    local sbBgSize=sbbgSp:getContentSize()

    local width1=startW+sbBgSize.width+5
    local width2=startW
    local heightC=sbBgSize.height+jiangeH

    local posTb={ccp(width1,startH+2*heightC),ccp(width1,startH+1*heightC),ccp(width1,startH),ccp(width2,startH+2*heightC),ccp(width2,startH+1*heightC),ccp(width2,startH)}

    local heroBgSpTb={}
    local tankBgSpTb={}
    local aiTroopsBgSpTb={}
    for i=0,1,1 do
        for j=0,2,1 do
            local tag=((j+1)+(i*3))

            local tankNow=tankInfo[tag]
            local heroNow=heroInfo[tag]
            local aitroopsNow=aitroopsInfo[tag]

            -- 坦克
            local bgSp1
            if tankNow and tankNow[1] then
                bgSp1=CCSprite:createWithSpriteFrameName("st_select2.png")

                local tankId=tankNow[1]
                tankId=tonumber(tankId) or tonumber(RemoveFirstChar(tankId))
                local tankNum=tankNow[2]
                local skinId = tskinList[tankSkinVoApi:convertTankId(tankId)]
                local tankSp= tankVoApi:getTankIconSp(tankId,skinId,nil,false)
                local spScale=0.6
                tankSp:setPosition(ccp(10+tankSp:getContentSize().width*spScale/2,bgSp1:getContentSize().height/2-15))
                tankSp:setScale(spScale)
                bgSp1:addChild(tankSp,3)

                if tankId~=G_pickedList(tankId) then
                    local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
                    tankSp:addChild(pickedIcon)
                    pickedIcon:setPosition(tankSp:getContentSize().width-30,30)
                    pickedIcon:setScale(1.5)
                end

                local soldiersLbName = GetTTFLabelWrap(getlocal(tankCfg[tankId].name),20,CCSizeMake(130,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                soldiersLbName:setAnchorPoint(ccp(0,0.5))
                soldiersLbName:setPosition(ccp(tankSp:getPositionX()+tankSp:getContentSize().width*spScale/2+3,tankSp:getPositionY()+tankSp:getContentSize().height*spScale/2-13))
                bgSp1:addChild(soldiersLbName,2)

                local soldiersLbNum = GetTTFLabel(tankNum,20)
                soldiersLbNum:setAnchorPoint(ccp(0,0.5))
                soldiersLbNum:setPosition(ccp(tankSp:getPositionX()+tankSp:getContentSize().width*spScale/2+3,tankSp:getPositionY()-tankSp:getContentSize().height*spScale/2+10))
                bgSp1:addChild(soldiersLbNum,2)
            else
                bgSp1=CCSprite:createWithSpriteFrameName("st_select1.png")

                -- 舰队为空时显示
                local nullTankSp = CCSprite:createWithSpriteFrameName("selectTankBg1.png")
                nullTankSp:setAnchorPoint(ccp(0.5,0.5))
                nullTankSp:setPosition(ccp(bgSp1:getContentSize().width/2,bgSp1:getContentSize().height/2-10))
                bgSp1:addChild(nullTankSp,1)
                nullTankSp:setScale(0.8)
                local selectTankBg2=CCSprite:createWithSpriteFrameName("selectTankBg2.png")
                selectTankBg2:setAnchorPoint(ccp(0.5,0.5))
                selectTankBg2:setPosition(ccp(nullTankSp:getContentSize().width/2,nullTankSp:getContentSize().height/2-35))
                nullTankSp:addChild(selectTankBg2)
                local posSp=CCSprite:createWithSpriteFrameName("tankPos"..tag..".png")
                posSp:setPosition(ccp(nullTankSp:getContentSize().width/2,nullTankSp:getContentSize().height/2-10))
                nullTankSp:addChild(posSp,1)
            end

            -- 头顶显示文字
            local headNameLb1=GetTTFLabel("",20)
            headNameLb1:setAnchorPoint(ccp(0.5,0))
            headNameLb1:setPosition(ccp(bgSp1:getContentSize().width/2,bgSp1:getContentSize().height-32))
            headNameLb1:setTag(12)
            bgSp1:addChild(headNameLb1,1)

            bgSp1:setAnchorPoint(ccp(0,0))

            bgSp1:setPosition(posTb[tag])
            troopsBg:addChild(bgSp1)

            table.insert(tankBgSpTb,bgSp1)

            -- 英雄
            local bgSp2
            if heroNow and heroNow~=0 then
                bgSp2=CCSprite:createWithSpriteFrameName("st_select2.png")
                -- 坦克相关bgSp1
                local arr=Split(heroNow,"-")
                local hid=arr[1]
                local level=arr[2] or 1
                local productOrder=arr[3] or 1
                local heroName=getlocal(heroListCfg[hid].heroName)
                local heroStr="Lv."..level.." "..heroName
                headNameLb1:setString(heroStr)
                local star=tonumber(productOrder)
                local starSize=13
                for i=1,star do
                    local starSpace=starSize
                    local starSp=CCSprite:createWithSpriteFrameName("StarIcon.png")
                    starSp:setScale(starSize/starSp:getContentSize().width)
                    bgSp1:addChild(starSp)
                    if starSp then
                        local px=bgSp1:getContentSize().width/2-starSpace/2*(star-1)+starSpace*(i-1)
                        local py=bgSp1:getContentSize().height-5
                        starSp:setPosition(ccp(px,py))
                    end
                end

                -- bgSp2
                local spScale=0.5
                local adjutants = heroAdjutantVoApi:decodeAdjutant(heroNow) --将领副官
                local heroSp=heroVoApi:getHeroIcon(hid,productOrder,nil,nil,nil,nil,nil,{adjutants=adjutants})
                heroSp:setScale(spScale)
                heroSp:setPosition(ccp(20+heroSp:getContentSize().width*spScale/2,bgSp2:getContentSize().height/2-10))
                bgSp2:addChild(heroSp)

                local heroNameLb = GetTTFLabelWrap(heroVoApi:getHeroName(hid),20,CCSizeMake(130,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                heroNameLb:setAnchorPoint(ccp(0,0.5))
                heroNameLb:setPosition(ccp(heroSp:getPositionX()+heroSp:getContentSize().width*spScale/2+8,heroSp:getPositionY()+heroSp:getContentSize().height*spScale/2-13))
                bgSp2:addChild(heroNameLb,2)

                local heroLvLb = GetTTFLabel("LV."..level,20)
                heroLvLb:setAnchorPoint(ccp(0,0.5))
                heroLvLb:setPosition(ccp(heroSp:getPositionX()+heroSp:getContentSize().width*spScale/2+10,heroSp:getPositionY()-heroSp:getContentSize().height*spScale/2+10))
                bgSp2:addChild(heroLvLb,2)
            else
                bgSp2=CCSprite:createWithSpriteFrameName("st_select1.png")
                -- 英雄为空时显示
                local nullHeroSp = CCSprite:createWithSpriteFrameName("selectTankBg3.png")
                nullHeroSp:setAnchorPoint(ccp(0.5,0.5))
                nullHeroSp:setPosition(ccp(bgSp2:getContentSize().width/2,bgSp2:getContentSize().height/2-10))
                bgSp2:addChild(nullHeroSp,1)
                nullHeroSp:setScale(0.8)
                local selectTankBg21=CCSprite:createWithSpriteFrameName("selectTankBg2.png")
                selectTankBg21:setAnchorPoint(ccp(0.5,0.5))
                selectTankBg21:setPosition(ccp(nullHeroSp:getContentSize().width/2,nullHeroSp:getContentSize().height/2-35))
                nullHeroSp:addChild(selectTankBg21)
                local posSp1=CCSprite:createWithSpriteFrameName("tankPos"..tag..".png")
                posSp1:setPosition(ccp(nullHeroSp:getContentSize().width/2,nullHeroSp:getContentSize().height/2-10))
                nullHeroSp:addChild(posSp1,1)

                -- 坦克相关bgSp1
                headNameLb1:setString(getlocal("fight_content_null"))

            end
            -- 头顶显示文字
            local headNameLb2=GetTTFLabel("",20)
            headNameLb2:setAnchorPoint(ccp(0.5,0))
            headNameLb2:setPosition(ccp(bgSp2:getContentSize().width/2,bgSp2:getContentSize().height-32))
            headNameLb2:setTag(12)
            bgSp2:addChild(headNameLb2,1)

            if tankNow and tankNow[1] then
                local tankId=tankNow[1]
                tankId=tonumber(tankId) or tonumber(RemoveFirstChar(tankId))
                local tankNum=tankNow[2]
                local tankStr=getlocal("item_type_number",{getlocal(tankCfg[tankId].name),tankNum})
                headNameLb2:setString(tankStr)
            else
                headNameLb2:setString(getlocal("fight_content_null"))
            end


            bgSp2:setAnchorPoint(ccp(0,0))

            bgSp2:setPosition(posTb[tag])
            troopsBg:addChild(bgSp2)

            table.insert(heroBgSpTb,bgSp2)

            --AI部队
            local bgSp3
            local atid,lv,grade,strength    
            if aitroopsNow then
                if isScout==true then
                    if aitroopsNow~=0 and aitroopsNow~="" then
                        local arr = Split(aitroopsNow,"-")
                        atid,lv,grade,strength = arr[1],arr[2],arr[3],arr[4]
                    end
                else
                    if type(aitroopsNow)=="table" then
                        atid,lv,grade,strength = aitroopsNow.id,aitroopsNow.lv,aitroopsNow.grade,aitroopsNow:getTroopsStrength()
                    end
                end
            end
            if atid and lv and grade and strength then
                bgSp3=CCSprite:createWithSpriteFrameName("st_select2.png")
                local spWidth=90
                local aitroopsIconSp=AITroopsVoApi:getAITroopsSimpleIcon(atid,lv,grade)
                aitroopsIconSp:setScale(spWidth/aitroopsIconSp:getContentSize().width)
                aitroopsIconSp:setPosition(ccp(10+spWidth/2,bgSp3:getContentSize().height/2-15))
                bgSp3:addChild(aitroopsIconSp)

                local nameStr,color=AITroopsVoApi:getAITroopsNameStr(atid)
                local troopsNameLb = GetTTFLabelWrap(nameStr,20,CCSizeMake(130,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                troopsNameLb:setAnchorPoint(ccp(0,0.5))
                troopsNameLb:setPosition(ccp(aitroopsIconSp:getPositionX()+spWidth/2+8,aitroopsIconSp:getPositionY()+spWidth/2-13))
                bgSp3:addChild(troopsNameLb,2)

                local strengthLb = GetTTFLabel(strength,20)
                strengthLb:setAnchorPoint(ccp(0,0.5))
                strengthLb:setPosition(ccp(aitroopsIconSp:getPositionX()+spWidth/2+10,aitroopsIconSp:getPositionY()-spWidth/2+10))
                bgSp3:addChild(strengthLb,2)
            else
                bgSp3=CCSprite:createWithSpriteFrameName("st_select1.png")
                --AI部队为空时显示
                local nullAITroopsSp = CCSprite:createWithSpriteFrameName("selectTankBg1.png")
                nullAITroopsSp:setAnchorPoint(ccp(0.5,0.5))
                nullAITroopsSp:setPosition(ccp(bgSp3:getContentSize().width/2,bgSp3:getContentSize().height/2-10))
                bgSp3:addChild(nullAITroopsSp,1)
                nullAITroopsSp:setScale(0.8)
                local selectTankBg22=CCSprite:createWithSpriteFrameName("selectTankBg2.png")
                selectTankBg22:setAnchorPoint(ccp(0.5,0.5))
                selectTankBg22:setPosition(ccp(nullAITroopsSp:getContentSize().width/2,nullAITroopsSp:getContentSize().height/2-35))
                nullAITroopsSp:addChild(selectTankBg22)
                local posSp=CCSprite:createWithSpriteFrameName("tankPos"..tag..".png")
                posSp:setPosition(ccp(nullAITroopsSp:getContentSize().width/2,nullAITroopsSp:getContentSize().height/2-10))
                nullAITroopsSp:addChild(posSp,1) 
            end
            -- 头顶显示文字
            local headNameLb3=GetTTFLabel("",20)
            headNameLb3:setAnchorPoint(ccp(0.5,0))
            headNameLb3:setPosition(ccp(bgSp3:getContentSize().width/2,bgSp3:getContentSize().height-32))
            headNameLb3:setTag(12)
            bgSp3:addChild(headNameLb3,1)

            if tankNow and tankNow[1] then
                local tankId=tankNow[1]
                tankId=tonumber(tankId) or tonumber(RemoveFirstChar(tankId))
                local tankNum=tankNow[2]
                local tankStr=getlocal("item_type_number",{getlocal(tankCfg[tankId].name),tankNum})
                headNameLb3:setString(tankStr)
            else
                headNameLb3:setString(getlocal("fight_content_null"))
            end


            bgSp3:setAnchorPoint(ccp(0,0))

            bgSp3:setPosition(posTb[tag])
            troopsBg:addChild(bgSp3)
            table.insert(aiTroopsBgSpTb,bgSp3)
        end
    end
    self:changeHeroOrTank(heroBgSpTb,tankBgSpTb,aiTroopsBgSpTb,1)

    local peW=troopsBg:getContentSize().width-8
    -- 飞机
    local planeSp1 = CCSprite:createWithSpriteFrameName("st_features.png")
    troopsBg:addChild(planeSp1)
    planeSp1:setAnchorPoint(ccp(1,0))
    planeSp1:setPosition(peW,startH-2)

    local plane=self.scoutInfo.plane
    if plane and plane~=0 then
        local showPlaneSp1 = planeVoApi:getPlaneIconNoBg(planeSp1,plane,15)
        -- showPlaneSp1:setScale(0.3)
        showPlaneSp1:setPosition(ccp(planeSp1:getContentSize().width/2,planeSp1:getContentSize().height/2+15))
        planeSp1:addChild(showPlaneSp1)
    else
        local showPlaneSp1 = CCSprite:createWithSpriteFrameName("plane_icon.png")
        showPlaneSp1:setPosition(getCenterPoint(planeSp1))
        showPlaneSp1:setScale(0.9)
        planeSp1:addChild(showPlaneSp1)
    end

    -- 军徽
    local equipSp1 = CCSprite:createWithSpriteFrameName("st_features.png")
    troopsBg:addChild(equipSp1)
    equipSp1:setAnchorPoint(ccp(1,0))
    equipSp1:setPosition(peW,startH+planeSp1:getContentSize().height+2)

    local emblem=self.scoutInfo.emblem
    if emblem and emblem~=0 then
        local showEquipSp1 = emblemVoApi:getEquipIconNoBg(emblem,18,145,nil,0)
        showEquipSp1:setScale(equipSp1:getContentSize().width/showEquipSp1:getContentSize().width)
        showEquipSp1:setPosition(getCenterPoint(equipSp1))
        equipSp1:addChild(showEquipSp1)
    else
        local showEquipSp1 = CCSprite:createWithSpriteFrameName("st_emptyShadow.png")
        showEquipSp1:setPosition(getCenterPoint(equipSp1))
        showEquipSp1:setScale(0.9)
        equipSp1:addChild(showEquipSp1)
    end
    
    local switchTankPic,switchHeroPic,switchAIPic = "st_showFleet.png","st_showHero.png","et_switchAI.png"
    if base.AITroopsSwitch==1 then
        switchTankPic,switchHeroPic="et_switchTank.png","et_switchHero.png"
    end
    -- 显示舰队时的按钮
    local switchSp1 = CCSprite:createWithSpriteFrameName("st_features.png")
    local showFleetSp1=CCSprite:createWithSpriteFrameName(switchTankPic)
    showFleetSp1:setPosition(getCenterPoint(switchSp1))
    switchSp1:addChild(showFleetSp1)
    local switchSp2 = CCSprite:createWithSpriteFrameName("st_features.png")
    local showFleetSp2=CCSprite:createWithSpriteFrameName(switchTankPic)
    showFleetSp2:setPosition(getCenterPoint(switchSp2))
    switchSp2:addChild(showFleetSp2)
    switchSp2:setScale(0.97)
    local menuItemSp1 = CCMenuItemSprite:create(switchSp1,switchSp2)

    -- 显示将领时的按钮
    local switchSp3 = CCSprite:createWithSpriteFrameName("st_features.png")
    local showHeroSp1=CCSprite:createWithSpriteFrameName(switchHeroPic)
    showHeroSp1:setPosition(getCenterPoint(switchSp3))
    switchSp3:addChild(showHeroSp1)
    local switchSp4 = CCSprite:createWithSpriteFrameName("st_features.png")
    local showHeroSp2=CCSprite:createWithSpriteFrameName(switchHeroPic)
    showHeroSp2:setPosition(getCenterPoint(switchSp4))
    switchSp4:addChild(showHeroSp2)
    switchSp4:setScale(0.97)
    local menuItemSp2 = CCMenuItemSprite:create(switchSp3,switchSp4)

    -- 显示AI部队的按钮
    local switchSp5 = CCSprite:createWithSpriteFrameName("st_features.png")
    local showAITroopsSp1=CCSprite:createWithSpriteFrameName(switchAIPic)
    showAITroopsSp1:setPosition(getCenterPoint(switchSp5))
    switchSp5:addChild(showAITroopsSp1)
    local switchSp6 = CCSprite:createWithSpriteFrameName("st_features.png")
    local showAITroopsSp2=CCSprite:createWithSpriteFrameName(switchAIPic)
    showAITroopsSp2:setPosition(getCenterPoint(switchSp6))
    switchSp6:addChild(showAITroopsSp2)
    switchSp6:setScale(0.97)
    local menuItemSp3 = CCMenuItemSprite:create(switchSp5,switchSp6)

    local changeItem = CCMenuItemToggle:create(menuItemSp1)
    if base.AITroopsSwitch==1 then
        changeItem:addSubItem(menuItemSp3)
    end
    changeItem:addSubItem(menuItemSp2)
    changeItem:setAnchorPoint(CCPointMake(1,0))
    changeItem:setPosition(ccp(peW,startH+planeSp1:getContentSize().height+jiangeH+equipSp1:getContentSize().height))
    local function changeHandler()
        -- print("点击更换按钮了",changeItem:getSelectedIndex())
        if changeItem:getSelectedIndex()==0 then
            self:changeHeroOrTank(heroBgSpTb,tankBgSpTb,aiTroopsBgSpTb,1)
        else
            if base.AITroopsSwitch==1 then
                if changeItem:getSelectedIndex()==1 then
                    self:changeHeroOrTank(heroBgSpTb,tankBgSpTb,aiTroopsBgSpTb,3)
                else
                    self:changeHeroOrTank(heroBgSpTb,tankBgSpTb,aiTroopsBgSpTb,2)
                end
            else
                self:changeHeroOrTank(heroBgSpTb,tankBgSpTb,aiTroopsBgSpTb,2)
            end
        end
    end
    changeItem:registerScriptTapHandler(changeHandler)
    local changeMenu=CCMenu:create()
    changeMenu:addChild(changeItem)
    changeMenu:setAnchorPoint(ccp(0,0))
    changeMenu:setPosition(ccp(0,0))
    changeMenu:setTouchPriority(-(layerNum-1)*20-4)
    changeItem:setSelectedIndex(0)
    troopsBg:addChild(changeMenu,1)

    G_clickSreenContinue(self.bgLayer)


    sceneGame:addChild(self.dialogLayer,layerNum)
    return self.dialogLayer

end

-- flag:1 tank显示  2：英雄显示  3：AI部队显示
function ltzdzScoutSmallDialog:changeHeroOrTank(heroBgSpTb,tankBgSpTb,aiTroopsBgSpTb,flag)
    for k,v in pairs(tankBgSpTb) do
        if v then
            v:setVisible(flag==1 and true or false)
        end
    end
    for k,v in pairs(heroBgSpTb) do
        if v then
            v:setVisible(flag==2 and true or false)
        end
    end
    for k,v in pairs(aiTroopsBgSpTb) do
        if v then
            v:setVisible(flag==3 and true or false)
        end
    end
end



function ltzdzScoutSmallDialog:tick()
end


function ltzdzScoutSmallDialog:dispose()
    self.scoutInfo=nil
    self.parent=nil
    ltzdzVoApi:addOrRemoveOpenDialog(2,"ltzdzScoutSmallDialog")
end

