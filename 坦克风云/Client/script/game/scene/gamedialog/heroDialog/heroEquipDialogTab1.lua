heroEquipDialogTab1={}
function heroEquipDialogTab1:new(selectedIndex,heroVoList,parentDialog)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.heroVo=nil                      --当前选择的将领
    self.selectedEquipSp=nil                --选中的武器sp
    self.equipInfoBgSp=nil
    self.selectedIndex=selectedIndex        --当前选择的将领索引
    self.heroVoList=heroVoList              --所有的将领vo数组
    self.containerSp=nil
    self.equipLevelLb=nil
    self.isPlaying=false                    --是否在播放动画
    self.parentDialog=parentDialog
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acMeteoriteLanding.plist")
    return nc
end


function heroEquipDialogTab1:init(layerNum)
    self.layerNum=layerNum
    self.bgLayer=CCLayer:create()
    self.heroVo=self.heroVoList[self.selectedIndex]
    self:switchHero()
    return self.bgLayer
end

function heroEquipDialogTab1:initPage()
    local function leftPageHandler()
        if self.isPlaying==true then
            return
        end
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end

        PlayEffect(audioCfg.mouseClick)

        if self.selectedIndex and self.selectedIndex<=1 then
            self.selectedIndex=SizeOfTable(self.heroVoList)
        else
            self.selectedIndex=self.selectedIndex-1
        end
        self.heroVo=self.heroVoList[self.selectedIndex]
        self:switchHero()
        if self and self.parentDialog then
            self.parentDialog:refreshTabStage()
        end
    end
    local scale=1
    self.leftBtn=GetButtonItem("leftBtnGreen.png","leftBtnGreen.png","leftBtnGreen.png",leftPageHandler,11,nil,nil)
    self.leftBtn:setScale(scale)
    local leftMenu=CCMenu:createWithItem(self.leftBtn)
    leftMenu:setAnchorPoint(ccp(0.5,0.5))
    leftMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.containerSp:addChild(leftMenu,1)
    local posY=G_VisibleSizeHeight-215
    if G_isIphone5()==true then
        posY=G_VisibleSizeHeight-225
    end

    local leftBtnPos=ccp(20,posY)
    local rightBtnPos=ccp(self.containerSp:getContentSize().width-20,posY)
    if(leftBtnPos~=nil)then
        leftMenu:setPosition(leftBtnPos)
    end

    local posX,posY=leftMenu:getPosition()
    local posX2=posX+20

    local mvTo=CCMoveTo:create(0.5,ccp(posX,posY))
    local fadeIn=CCFadeIn:create(0.5)
    local carray=CCArray:create()
    carray:addObject(mvTo)
    carray:addObject(fadeIn)
    local spawn=CCSpawn:create(carray)

    local mvTo2=CCMoveTo:create(0.5,ccp(posX2,posY))
    local fadeOut=CCFadeOut:create(0.5)
    local carray2=CCArray:create()
    carray2:addObject(mvTo2)
    carray2:addObject(fadeOut)
    local spawn2=CCSpawn:create(carray2)

    local seq=CCSequence:createWithTwoActions(spawn2,spawn)
    leftMenu:runAction(CCRepeatForever:create(seq))

    local function rightPageHandler()
        if self.isPlaying==true then
            return
        end
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        
        if self.selectedIndex and self.selectedIndex>=SizeOfTable(self.heroVoList) then
            self.selectedIndex=1
        else
            self.selectedIndex=self.selectedIndex+1
        end
        self.heroVo=self.heroVoList[self.selectedIndex]
        self:switchHero()
        if self and self.parentDialog then
            self.parentDialog:refreshTabStage()
        end
    end
    self.rightBtn=GetButtonItem("leftBtnGreen.png","leftBtnGreen.png","leftBtnGreen.png",rightPageHandler,11,nil,nil)
    self.rightBtn:setRotation(180)
    self.rightBtn:setScale(scale)
    local rightMenu=CCMenu:createWithItem(self.rightBtn)
    rightMenu:setAnchorPoint(ccp(0.5,0.5))
    rightMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.containerSp:addChild(rightMenu,1)
    if(rightBtnPos~=nil)then
        rightMenu:setPosition(rightBtnPos)
    end

    local posX,posY=rightMenu:getPosition()
    local posX2=posX-20

    local mvTo=CCMoveTo:create(0.5,ccp(posX,posY))
    local fadeIn=CCFadeIn:create(0.5)
    local carray=CCArray:create()
    carray:addObject(mvTo)
    carray:addObject(fadeIn)
    local spawn=CCSpawn:create(carray)

    local mvTo2=CCMoveTo:create(0.5,ccp(posX2,posY))
    local fadeOut=CCFadeOut:create(0.5)
    local carray2=CCArray:create()
    carray2:addObject(mvTo2)
    carray2:addObject(fadeOut)
    local spawn2=CCSpawn:create(carray2)

    local seq=CCSequence:createWithTwoActions(spawn2,spawn)
    rightMenu:runAction(CCRepeatForever:create(seq))
end


function heroEquipDialogTab1:switchHero(selectedIndex)
    if selectedIndex then
        self.selectedIndex=selectedIndex
        self.heroVo=self.heroVoList[self.selectedIndex]
    end
    if self.containerSp then
        self.containerSp:removeFromParentAndCleanup(true)
        self.containerSp=nil
    end
    self.containerSp=CCSprite:create()
    self.containerSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width,self.bgLayer:getContentSize().height))
    self.containerSp:setAnchorPoint(ccp(0.5,0.5))
    self.containerSp:setPosition(getCenterPoint(self.bgLayer))
    self.bgLayer:addChild(self.containerSp)
    self:initTableView()
end

--设置对话框里的tableView
function heroEquipDialogTab1:initTableView()

    local spriteShapeH
    if  G_getIphoneType() == G_iphoneX then
        self.descBgScaleY = 1.3
        spriteShapeH = 140
    elseif G_getIphoneType() == G_iphone5 then
        spriteShapeH = 120
        self.descBgScaleY = 1.2
    else
        spriteShapeH = 100
        self.descBgScaleY = 0.9
    end 
    local function cellClick( ... )
        
    end
    local spriteShapeInfor = LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),cellClick)
    spriteShapeInfor:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,spriteShapeH))
    spriteShapeInfor:setTouchPriority(-(self.layerNum-1)*20-2)
    spriteShapeInfor:setAnchorPoint(ccp(0.5,1));
    spriteShapeInfor:setPosition(ccp(self.containerSp:getContentSize().width/2,self.containerSp:getContentSize().height-160))
    self.containerSp:addChild(spriteShapeInfor)
    
    local heroIcon = heroVoApi:getHeroIcon(self.heroVo.hid,self.heroVo.productOrder)
    heroIcon:setScale(0.5)
    heroIcon:setPosition(ccp(130,spriteShapeInfor:getContentSize().height/2+5))
    spriteShapeInfor:addChild(heroIcon)

    local heroNameLb = GetTTFLabelWrap(heroVoApi:getHeroName(self.heroVo.hid),24,CCSize(350, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
    heroNameLb:setAnchorPoint(ccp(0,0.5))
    heroNameLb:setPosition(ccp(heroIcon:getPositionX()+heroIcon:getContentSize().width/2+20,spriteShapeInfor:getContentSize().height/2+20))
    spriteShapeInfor:addChild(heroNameLb)
    heroNameLb:setColor(heroVoApi:getHeroColor(self.heroVo.productOrder))

    local fightValue=heroEquipVoApi:getEquipFight(self.heroVo.hid,self.heroVo.productOrder)
    local equipFightLb = GetTTFLabelWrap(getlocal("equipFight")..fightValue,20,CCSize(350, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    equipFightLb:setAnchorPoint(ccp(0,0.5))
    equipFightLb:setPosition(ccp(heroIcon:getPositionX()+heroIcon:getContentSize().width/2+20,heroNameLb:getPositionY()-heroNameLb:getContentSize().height-5))
    spriteShapeInfor:addChild(equipFightLb)
    self.equipFightLb=equipFightLb

    self:initPage()

    self.descBgSp= CCSprite:create("public/hero/heroequip/equipBigBg.jpg")
    self.descBgSp:setAnchorPoint(ccp(0.5,1))
    self.descBgSp:setPosition(ccp(self.containerSp:getContentSize().width/2,spriteShapeInfor:getPositionY()-spriteShapeInfor:getContentSize().height))
    self.containerSp:addChild(self.descBgSp)
    self.descBgSp:setScaleX(0.97)
    self.descBgSp:setScaleY(self.descBgScaleY)     
    self:initEquipIcon(nil,nil,true)
end

-- 
function heroEquipDialogTab1:initEquipIcon(shwoSelectedIndex,eid,isInit)
    -- 6个装备区域
    local function inputHandler(hd,fn,idx)
        if self.isPlaying==true then
            return
        end
       if self and self.selectedEquipSp and self["equipBgSp"..(idx-100)] then
            local newX = self["equipBgSp"..(idx-100)]:getPositionX()
            local newY = self["equipBgSp"..(idx-100)]:getPositionY()
            self.selectedEquipSp:setPosition(ccp(newX,newY))
            if (idx-100)==3 or (idx-100)==6 then
                self:showEquipInfo(idx-100,false)
            else
                self:showEquipInfo(idx-100,true)
            end
       end
    end
    local iconSize = CCSizeMake(100,100)
    local iconY
    if G_getIphoneType() == G_iphoneX then
        iconY = 90
    elseif G_getIphoneType() == G_iphone5 then
        iconY = 70
    else
        iconY = 40
    end
    local function showEquipItem(i,v)
            local equipBgSp = heroEquipVoApi:getEquipIcon(self.heroVo.hid,iconSize,v,inputHandler,nil,self.heroVo.productOrder,1)    
            equipBgSp:setAnchorPoint(ccp(0.5,0.5))
            local rowSpace = equipBgSp:getContentSize().width+50
            local colSpace = equipBgSp:getContentSize().height+15
            local row_index = i%3
            if row_index==0 then
                row_index=3
            end
            local col_index = math.floor((i-1)/3)
            local temX=self.containerSp:getContentSize().width/2-rowSpace+rowSpace*(row_index-1)
            local temY=self.containerSp:getContentSize().height/2-colSpace*(col_index-1)+iconY
            equipBgSp:setPosition(ccp(temX,temY))
            self.containerSp:addChild(equipBgSp,2)
            equipBgSp:setTag(i+100)
            self["equipBgSp"..i]=equipBgSp
            equipBgSp:setTouchPriority(-(self.layerNum-1)*20-2)
            return equipBgSp:getPositionX(),equipBgSp:getPositionY()
    end

    -- if shwoSelectedIndex and eid and self and self["equipBgSp"..shwoSelectedIndex] then
    --     self["equipBgSp"..shwoSelectedIndex]:removeFromParentAndCleanup(true)
    --     self["equipBgSp"..shwoSelectedIndex]=nil

    --     showEquipItem(shwoSelectedIndex,eid)
    -- else
        
        
    -- end
    for i,v in pairs(heroEquipVoApi:getHeroEidList()) do
        if self["equipBgSp"..i] then
            self["equipBgSp"..i]:removeFromParentAndCleanup(true)
            self["equipBgSp"..i]=nil
        end
        local iconPx,iconPy=showEquipItem(i,v)
        if isInit==true and i==1 then
            self.selectedEquipSp=CCSprite:createWithSpriteFrameName("equipSelectedRect.png") 
            self.selectedEquipSp:setPosition(ccp(iconPx,iconPy))
            self.selectedEquipSp:setScale((iconSize.width+10)/self.selectedEquipSp:getContentSize().width)
            self.containerSp:addChild(self.selectedEquipSp,3)
            self:showEquipInfo(i)
        end
    end
end

-- idx装备索引，isCommonEquip是否为普通装备，isCommonUpgrade是否为普通强化
function heroEquipDialogTab1:showEquipInfo(idx,isCommonEquip,isCommonUpgrade)
    local eid = heroEquipVoApi:getHeroEidList()[idx]
    local iconSize = CCSizeMake(100,100)
    local temH=self.descBgSp:getPositionY()-self.descBgSp:getContentSize().height*self.descBgScaleY-10
    local upgradeDescH = 30
    local equipIconY=12
    local equipIconScale = 1
    local equipButtomSpY = 20
    local lineY = 0
    if G_isIphone5()==true then
        iconSize = CCSizeMake(120,120)
        upgradeDescH = 40
        equipIconY=30
        equipIconScale=1.2
        equipButtomSpY = 0
        lineY = 15
    end
    if G_getIphoneType() == G_iphoneX then
        upgradeDescH = 70
        equipIconY = 40
        equipIconScale = 1.2
        equipButtomSpY = 0
    end
    local function touch( ... )
    end

    if isCommonEquip==nil then
        isCommonEquip=true
    end
    local lv,maxLv = heroEquipVoApi:getUpLevelByEidAndIndex(self.heroVo.hid,eid)
    if isCommonUpgrade==nil then
        if lv>=maxLv then
            isCommonUpgrade=false
        else
            isCommonUpgrade=true
        end
    end

    if self and self.equipInfoBgSp then
        self.equipLevelLb=nil
        self.exValueLb=nil
        self.upgradeTitleLb=nil
        self.equipInfoBgSp:removeFromParentAndCleanup(true)
        self.equipInfoBgSp=nil
    end

    -- 装备详细信息及强化信息
    local function touch( ... )
        
    end
    --下面的背景板子
    self.equipInfoBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray2.png",CCRect(20, 20, 1, 1),touch)
    self.equipInfoBgSp:setAnchorPoint(ccp(0.5,0))
    self.equipInfoBgSp:setContentSize(CCSizeMake(self.containerSp:getContentSize().width-37,temH))
    self.equipInfoBgSp:setPosition(ccp(self.containerSp:getContentSize().width/2,10))
    self.containerSp:addChild(self.equipInfoBgSp,3)

    local awakenLv=heroEquipVoApi:getAwakenLevelByEidAndIndex(self.heroVo.hid,eid)
    local awakenMaxLv=heroEquipVoApi:getAwakenMaxLevel(self.heroVo.hid,eid)
    for i=1,awakenMaxLv do
        local starSp
        if i<=awakenLv then
            starSp=CCSprite:createWithSpriteFrameName("StarIcon.png") 
        else
            starSp=CCSprite:createWithSpriteFrameName("gameoverstar_black.png") 
        end
        starSp:setScale(24/starSp:getContentSize().width)
        local starX = 90
        if G_getIphoneType() == G_iphoneX then
            starX = 150
        end  
        starSp:setPosition(ccp(starX,self.equipInfoBgSp:getContentSize().height-equipIconY-24*i))
        self.equipInfoBgSp:addChild(starSp)
    end

    local equipIconPic = heroEquipVoApi:getEquipIconPic(self.heroVo.hid,eid)
    self.equipBgSp = LuaCCSprite:createWithSpriteFrameName(equipIconPic,touch)
    self.equipBgSp:setAnchorPoint(ccp(0.5,1))
    local  equipX = 180    
    if G_getIphoneType() == G_iphoneX then
        equipX = 270
    end  
    self.equipBgSp:setPosition(ccp(equipX,self.equipInfoBgSp:getContentSize().height-equipIconY))
    self.equipInfoBgSp:addChild(self.equipBgSp,2)
    self.equipBgSp:setScale(equipIconScale)

    local equipButtomSp = LuaCCSprite:createWithSpriteFrameName("acMeteoriteLanding_2.png",touch)
    equipButtomSp:setPosition(ccp(equipX,self.equipInfoBgSp:getContentSize().height-self.equipBgSp:getContentSize().height+equipButtomSpY))
    equipButtomSp:setAnchorPoint(ccp(0.5,1))
    self.equipInfoBgSp:addChild(equipButtomSp,1)
    equipButtomSp:setScale(equipIconScale)
    local needWidth = 400
    if G_getCurChoseLanguage() =="ar" then
        needWidth =200
    end
    local equipNameLb = GetTTFLabelWrap(heroEquipVoApi:getEquipName(self.heroVo.hid,eid),24,CCSize(needWidth, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
    equipNameLb:setAnchorPoint(ccp(0,1))
    equipNameLb:setPosition(ccp(self.equipBgSp:getPositionX()+self.equipBgSp:getContentSize().width+20,self.equipInfoBgSp:getContentSize().height-equipIconY-8))
    self.equipInfoBgSp:addChild(equipNameLb)
    local jinjieLv,maxJinjieLv,unEquipLevel=heroEquipVoApi:getJinjieLevelByEidAndIndex(self.heroVo.hid,eid,self.heroVo.productOrder)
    equipNameLb:setColor(heroEquipVoApi:getEquipNameColor(jinjieLv))
    
    local levelStr = getlocal("RankScene_level")..":"..lv.."/"..maxLv
    self.equipLevelLb = GetTTFLabelWrap(levelStr,20,CCSize(needWidth, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    self.equipLevelLb:setAnchorPoint(ccp(0.5,0.5))
    self.equipLevelLb:setPosition(ccp(equipNameLb:getPositionX()+self.equipLevelLb:getContentSize().width/2,equipNameLb:getPositionY()-equipNameLb:getContentSize().height-equipIconY))
    self.equipInfoBgSp:addChild(self.equipLevelLb)

    local attList=heroEquipVoApi:getAttList(self.heroVo.hid,eid,nil,self.heroVo.productOrder)
    local linePy = 1
    if attList and SizeOfTable(attList)>0 then
        local index = 0
        for k,v in pairs(attList) do
            local propertyStr = v["lb"][1]..":+"..v.value
            -- if k~="first" then
            if v["key"]~="first" then    
                propertyStr = v["lb"][1]..":+"..(v.value).."%"
            end
            self["equipPropertyLb"..index] = GetTTFLabelWrap(propertyStr,20,CCSize(needWidth, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            local py1 = self.equipLevelLb:getPositionY()-self.equipLevelLb:getContentSize().height/2-(self["equipPropertyLb"..index]:getContentSize().height+5)*index-5
            self["equipPropertyLb"..index]:setAnchorPoint(ccp(0,1))
            self["equipPropertyLb"..index]:setPosition(ccp(equipNameLb:getPositionX(),py1))
            self.equipInfoBgSp:addChild(self["equipPropertyLb"..index])  
            index=index+1  
            linePy=py1-35-lineY
        end
    end

    local lineSp2 = CCSprite:createWithSpriteFrameName("LineCross.png");
    lineSp2:setAnchorPoint(ccp(0.5,0.5));
    if G_getIphoneType() == G_iphoneX then
        linePy = linePy - 50
    end
    lineSp2:setPosition(self.equipInfoBgSp:getContentSize().width/2,linePy)
    self.equipInfoBgSp:addChild(lineSp2,2)
    lineSp2:setScaleX((self.equipInfoBgSp:getContentSize().width-30)/lineSp2:getContentSize().width)

    local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 20, 10, 10),function ()end)
    titleBg:setContentSize(CCSizeMake(300,45))
    titleBg:setScaleX((self.equipInfoBgSp:getContentSize().width-20)/titleBg:getContentSize().width)
    titleBg:setPosition(ccp((self.equipInfoBgSp:getContentSize().width)/2,lineSp2:getPositionY()-lineSp2:getContentSize().height-15))
    self.equipInfoBgSp:addChild(titleBg,2)

    local upgradeTitleStr = ""
    
    local xpIconPic
    if isCommonUpgrade==true then
        local upgradeDescParam = ""
        if eid=="e5" then
            xpIconPic="icon_exp_e2.png"
            upgradeDescParam=getlocal("equip_upgrade_Desc2")
        elseif eid=="e6" then
            xpIconPic="icon_exp_e3.png"
            upgradeDescParam=getlocal("equip_upgrade_Desc3")
        else
            xpIconPic="icon_exp_e1.png"
            upgradeDescParam=getlocal("equip_upgrade_Desc1")
        end
        local upgradeDescStr = ""
        local upCostItemArr,xpValue,needXpNum,xpname = heroEquipVoApi:getUpCostProp(self.heroVo.hid,eid)    
        
        upgradeDescStr=getlocal("equip_upgrade_Desc").."\n"..upgradeDescParam
        upgradeTitleStr=""..xpValue

        local strSize2 = 20
        local strPos2 = 200
        if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
            strSize2 =23
            strPos2 =60
        end

        local xpIconSp1=CCSprite:createWithSpriteFrameName(xpIconPic)
        xpIconSp1:setPosition(ccp(self.equipInfoBgSp:getContentSize().width/2,titleBg:getPositionY()))
        self.equipInfoBgSp:addChild(xpIconSp1,3)
        xpIconSp1:setScale(0.5)

        local hasLb = GetTTFLabelWrap(getlocal("propOwned"),20,CCSize(self.equipInfoBgSp:getContentSize().width-60, 0),kCCTextAlignmentRight,kCCVerticalTextAlignmentTop)
        hasLb:setAnchorPoint(ccp(1,0.5))
        hasLb:setPosition(ccp(self.equipInfoBgSp:getContentSize().width/2-xpIconSp1:getContentSize().width*0.5,titleBg:getPositionY()))
        self.equipInfoBgSp:addChild(hasLb,3)
        hasLb:setColor(G_ColorYellowPro)

        self.upgradeTitleLb = GetTTFLabelWrap(upgradeTitleStr,20,CCSize(self.equipInfoBgSp:getContentSize().width*0.5-strPos2, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        self.upgradeTitleLb:setAnchorPoint(ccp(0,0.5))
        self.upgradeTitleLb:setPosition(ccp(self.equipInfoBgSp:getContentSize().width/2+xpIconSp1:getContentSize().width*0.5,titleBg:getPositionY()))
        self.equipInfoBgSp:addChild(self.upgradeTitleLb,3)
        self.upgradeTitleLb:setColor(G_ColorYellowPro)
        
        local upgradeDescLb = GetTTFLabelWrap(upgradeDescStr,strSize2,CCSize(self.equipInfoBgSp:getContentSize().width-40, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        upgradeDescLb:setAnchorPoint(ccp(0.5,1))
        upgradeDescLb:setPosition(ccp(self.equipInfoBgSp:getContentSize().width/2,titleBg:getPositionY()-titleBg:getContentSize().height/2-upgradeDescH))
        self.equipInfoBgSp:addChild(upgradeDescLb)
        
        -- 判断是否已经达到最大等级
        local maxUpLv = heroEquipVoApi:getCanUpgradeMaxUpLevel(unEquipLevel)
        if maxUpLv<=lv then

            local maxLvLb = GetTTFLabelWrap(getlocal("equip_maxLv1"),20,CCSize(self.equipInfoBgSp:getContentSize().width-40, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
            maxLvLb:setAnchorPoint(ccp(0.5,0.5))
            maxLvLb:setPosition(ccp(self.equipInfoBgSp:getContentSize().width/2,80))
            self.equipInfoBgSp:addChild(maxLvLb)
            maxLvLb:setColor(G_ColorYellowPro)
            return
        end

        local function touchCallback(tag,object)
            local upCostItemArr2,xpValue2,needXpNum2,xpname2 = heroEquipVoApi:getUpCostProp(self.heroVo.hid,eid)
            if tonumber(needXpNum2)>tonumber(xpValue2) then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("noenough_equipXp",{xpname}),28)
                return
            end
            if self.isPlaying==true then
                return
            end
            local function upgradeHandler(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    if sData and sData.data and sData.data.equip then
                        local oldLv = heroEquipVoApi:getUpLevelByEidAndIndex(self.heroVo.hid,eid)
                        heroEquipVoApi:formatData(sData.data.equip)
                        local newLv,maxLv2 = heroEquipVoApi:getUpLevelByEidAndIndex(self.heroVo.hid,eid)

                        local playNum = newLv-oldLv
                        if playNum>1 then
                            local index = 1
                            local function playActionHandler( ... )
                                if (oldLv+index)>newLv then
                                    return
                                end
                                if newLv>=maxLv2 and (oldLv+index)==newLv then
                                    self:showEquipInfo(idx,isCommonEquip)    
                                else
                                    self:refreshInfo(eid,isCommonUpgrade,(oldLv+index),playActionHandler)
                                end
                                index=index+1       
                            end
                            self:refreshInfo(eid,isCommonUpgrade,(oldLv+index),playActionHandler)
                        else
                            if newLv>=maxLv2 then
                                self:showEquipInfo(idx,isCommonEquip)
                            else
                                self:refreshInfo(eid,isCommonUpgrade,newLv)
                            end
                        end
                        self:initEquipIcon(idx,eid)
                        if self and self.parentDialog then
                            self.parentDialog:refreshTabStage()
                        end
                        -- if newLv>=maxLv2 then
                        --     self:showEquipInfo(idx,isCommonEquip)
                        -- else
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("equip_grow_success"),28)
                        -- end
                    end
                end
            end
            if tag==20 then
                socketHelper:equipUpgrade(self.heroVo.hid,eid,2,upgradeHandler)
            else
                socketHelper:equipUpgrade(self.heroVo.hid,eid,1,upgradeHandler)
            end
        end
        local strSize2 = 22
        if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="tw" then
            strSize2 =25
        end
        local btnMenu = CCMenu:create()
        local xpIconPx=self.equipInfoBgSp:getContentSize().width/2
        -- if isCommonEquip==true then
            local upgradeBtnFontSize=24
            if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
                upgradeBtnFontSize=24
            else
                upgradeBtnFontSize=22
            end
            local upgradeBtn= GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",touchCallback,2,getlocal("super_weapon_rebuildAuto"),upgradeBtnFontSize/0.8,11)
            upgradeBtn:setScale(0.8)
            local btnLb = upgradeBtn:getChildByTag(11)
            if btnLb then
                btnLb = tolua.cast(btnLb,"CCLabelTTF")
                btnLb:setFontName("Helvetica-bold")
            end
            btnMenu:addChild(upgradeBtn)
            upgradeBtn:setTag(20)
            xpIconPx=self.equipInfoBgSp:getContentSize().width/7*5-20
        -- end
        local upgradeAllBtn= GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",touchCallback,2,getlocal("super_weapon_rebuild"),24/0.8,11)
        upgradeAllBtn:setScale(0.8)
        local btnLb = upgradeAllBtn:getChildByTag(11)
        if btnLb then
            btnLb = tolua.cast(btnLb,"CCLabelTTF")
            btnLb:setFontName("Helvetica-bold")
        end
        btnMenu:addChild(upgradeAllBtn)
        upgradeAllBtn:setTag(21)
        
        btnMenu:alignItemsHorizontallyWithPadding(50)
        btnMenu:setTouchPriority(-(self.layerNum-1)*20-3)
        self.equipInfoBgSp:addChild(btnMenu)
        btnMenu:setPosition(ccp(self.equipInfoBgSp:getContentSize().width/2, 55))

        for k,v in pairs(upCostItemArr) do
            local xpIconSp=CCSprite:createWithSpriteFrameName(xpIconPic)
            xpIconSp:setPosition(ccp(xpIconPx,95))
            self.equipInfoBgSp:addChild(xpIconSp)
            xpIconSp:setAnchorPoint(ccp(1,0))
            xpIconSp:setScale(0.4)

            self.exValueLb = GetTTFLabelWrap(v.num.."",23,CCSize(150, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)    
            self.exValueLb:setAnchorPoint(ccp(0,0))
            self.exValueLb:setPosition(ccp(xpIconPx,95))
            self.equipInfoBgSp:addChild(self.exValueLb)
            if xpValue<v.num then
                self.exValueLb:setColor(G_ColorRed)
            end
        end
    else
        local costProp = heroEquipVoApi:getJinjieCostProp(self.heroVo.hid,eid,self.heroVo.productOrder)
        local ifCanJinjie = true
        local pointValue = 0
        if isCommonEquip==true then
            upgradeTitleStr=getlocal("equip_upgrade_cost")
            local upgradeTitleLb = GetTTFLabelWrap(upgradeTitleStr,20,CCSize(self.equipInfoBgSp:getContentSize().width-60, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
            upgradeTitleLb:setAnchorPoint(ccp(0.5,0.5))
            upgradeTitleLb:setPosition(ccp(self.equipInfoBgSp:getContentSize().width/2,titleBg:getPositionY()))
            self.equipInfoBgSp:addChild(upgradeTitleLb,3)
            upgradeTitleLb:setColor(G_ColorYellowPro)
        else
            local award = FormatItem(costProp)
            if eid=="e5" then
                pointValue=arenaVoApi:getPoint()
                upgradeTitleStr=""..pointValue
                xpIconPic="icon_medal_sports.png"
            elseif eid=="e6" then
                pointValue=expeditionVoApi:getPoint()
                upgradeTitleStr=""..pointValue
                xpIconPic="expeditionPoint.png"
            end    
            local xpIconSp1=CCSprite:createWithSpriteFrameName(xpIconPic)
            xpIconSp1:setPosition(ccp(self.equipInfoBgSp:getContentSize().width/2,titleBg:getPositionY()))
            self.equipInfoBgSp:addChild(xpIconSp1,3)
            xpIconSp1:setScale(0.5)

            local hasLb = GetTTFLabelWrap(getlocal("propOwned"),20,CCSize(self.equipInfoBgSp:getContentSize().width-60, 0),kCCTextAlignmentRight,kCCVerticalTextAlignmentTop)
            hasLb:setAnchorPoint(ccp(1,0.5))
            hasLb:setPosition(ccp(self.equipInfoBgSp:getContentSize().width/2-40,titleBg:getPositionY()))
            self.equipInfoBgSp:addChild(hasLb,3)
            hasLb:setColor(G_ColorYellowPro)

            self.upgradeTitleLb = GetTTFLabelWrap(upgradeTitleStr,23,CCSize(self.equipInfoBgSp:getContentSize().width-60, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            self.upgradeTitleLb:setAnchorPoint(ccp(0,0.5))
            self.upgradeTitleLb:setPosition(ccp(self.equipInfoBgSp:getContentSize().width/2+40,titleBg:getPositionY()))
            self.equipInfoBgSp:addChild(self.upgradeTitleLb,3)
            self.upgradeTitleLb:setColor(G_ColorYellowPro)
        end
        
        
        

        -- 判断是否已经达到最大等级
        local maxUpLv = heroEquipVoApi:getCanUpgradeMaxUpLevel(unEquipLevel)
        if maxUpLv<=lv then

            local maxLvLb = GetTTFLabelWrap(getlocal("equip_maxLv1"),20,CCSize(self.equipInfoBgSp:getContentSize().width-40, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
            maxLvLb:setAnchorPoint(ccp(0.5,0.5))
            maxLvLb:setPosition(ccp(self.equipInfoBgSp:getContentSize().width/2,80))
            self.equipInfoBgSp:addChild(maxLvLb)
            maxLvLb:setColor(G_ColorYellowPro)
            return
        end
        
        if isCommonEquip==true then
            -- 进阶消耗的道具
            local costProp = heroEquipVoApi:getJinjieCostProp(self.heroVo.hid,eid,self.heroVo.productOrder)
            if costProp==nil then
                return
            end
            local award = FormatItem(costProp)
            local propNum = SizeOfTable(award)
            local function sortA(a,b)
                if a and b and a.id and b.id then
                    return a.id < b.id
                end
            end
            table.sort( award, sortA )
            
            for i,v in pairs(award) do
                local item = v
                local curNum = bagVoApi:getItemNumId(item.id)
                local needNum = item.num
                local isShowInfo = true
                if curNum<needNum then
                    isShowInfo = false
                end
                local function showInfoHandler()
                    local function callback2()
                        -- if self and self.parentDialog then
                        --     self.parentDialog:closeParentDialog()
                        -- end
                        --刷新当前将领装备页面
                        if idx == 3 or idx == 6 then
                            self:showEquipInfo(idx,false)
                        else
                            self:showEquipInfo(idx,true)
                        end

                        if self and self.parentDialog then
                            --刷新将领装备页面将领列表的状态
                            self.parentDialog:refreshTabStage()
                        end
                    end

                    if curNum<needNum then
                        local challangeList,rtype=heroEquipVoApi:getPropChannelList(item.id)
                        if #challangeList>0 then
                            smallDialog:showHeroEquipPropJumpDialog(item,curNum,needNum,challangeList,rtype,self.layerNum+1,callback2)
                        end
                    end
                end
                local icon = G_getItemIcon(item,100,isShowInfo,self.layerNum+1,showInfoHandler)
                icon:ignoreAnchorPointForPosition(false)
                icon:setAnchorPoint(ccp(0.5,1))
                local xSpace = icon:getContentSize().width+10
                local px=self.equipInfoBgSp:getContentSize().width/2-xSpace/2*(propNum-1)+xSpace*(i-1)
                icon:setPosition(ccp(px,titleBg:getPositionY()-titleBg:getContentSize().height/2-upgradeDescH))
                icon:setIsSallow(false)
                icon:setTouchPriority(-(self.layerNum-1)*20-2)
                self.equipInfoBgSp:addChild(icon,1)
                icon:setTag(i)

                local propNumLb = GetTTFLabelWrap(curNum.."/"..needNum,20,CCSize(icon:getContentSize().width, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
                propNumLb:setAnchorPoint(ccp(0.5,0))
                propNumLb:setPosition(ccp(icon:getContentSize().width/2,10))
                icon:addChild(propNumLb,2)
                if curNum<needNum then
                    propNumLb:setColor(G_ColorRed)
                    ifCanJinjie=false
                    local function tmpFunc( ... )
                        -- body
                    end
                    local maskSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,2,2),tmpFunc)
                    maskSp:setPosition(getCenterPoint(icon))
                    maskSp:setScale(icon:getContentSize().width/maskSp:getContentSize().width)
                    icon:addChild(maskSp)
                    local addSp=LuaCCScale9Sprite:createWithSpriteFrameName("ProduceTankIconMore.png",CCRect(10,10,2,2),tmpFunc)
                    addSp:setPosition(getCenterPoint(icon))
                    icon:addChild(addSp,1)
                end
                
            end
        else
            local award = FormatItem(costProp)
            if award then
                local propname = award[1].name 
                local upgradeDescStr = getlocal("equip_upgrade_cost1",{heroEquipVoApi:getEquipName(self.heroVo.hid,eid),propname})
                upgradeDescStr=upgradeDescStr.."\n"..getlocal("get_equipXp_channel"..idx)
                local upgradeDescLb = GetTTFLabelWrap(upgradeDescStr,20,CCSize(self.equipInfoBgSp:getContentSize().width-40, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
                upgradeDescLb:setAnchorPoint(ccp(0.5,1))
                upgradeDescLb:setPosition(ccp(self.equipInfoBgSp:getContentSize().width/2,titleBg:getPositionY()-titleBg:getContentSize().height/2-upgradeDescH))
                self.equipInfoBgSp:addChild(upgradeDescLb)
            end
            local xpIconPx=self.equipInfoBgSp:getContentSize().width/2
            for k,v in pairs(award) do
                local xpIconSp=CCSprite:createWithSpriteFrameName(xpIconPic)
                xpIconSp:setPosition(ccp(xpIconPx,95))
                self.equipInfoBgSp:addChild(xpIconSp)
                xpIconSp:setAnchorPoint(ccp(1,0))
                xpIconSp:setScale(0.4)

                self.exValueLb = GetTTFLabelWrap(v.num.."",20,CCSize(150, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)    
                self.exValueLb:setAnchorPoint(ccp(0,0))
                self.exValueLb:setPosition(ccp(xpIconPx,95))
                self.equipInfoBgSp:addChild(self.exValueLb)
                if pointValue<v.num then
                    self.exValueLb:setColor(G_ColorRed)
                    ifCanJinjie=false
                end
            end
        end
        
        local function touchCallback2(tag,object)
            if self.isPlaying==true then
                return
            end
            --判断能不能进阶
            local canAdvance,errorCode = heroEquipVoApi:checkIfCanUpOrJinjie(self.heroVo.hid,eid,self.heroVo.productOrder)
            if canAdvance == false then
                if(errorCode==3 or errorCode==4)then
                    smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("backstage9033"),nil,self.layerNum + 1)
                else
                    smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("backstage18002"),nil,self.layerNum + 1)
                end
                return
            end

            if ifCanJinjie==false then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("noenough_prop1"),28)
                return
            end


            local function advanceHandler(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    if sData and sData.data and sData.data.equip then
                        heroEquipVoApi:formatData(sData.data.equip)
                        local lv3,maxLv3 = heroEquipVoApi:getUpLevelByEidAndIndex(self.heroVo.hid,eid)
                        if lv3<maxLv3 then
                            self:showEquipInfo(idx,isCommonEquip)
                        end
                        self:initEquipIcon(idx,eid)
                        if self and self.parentDialog then
                            self.parentDialog:refreshTabStage()
                        end
                        --装备进阶成功后，弹出进阶弹板
                        local titleStr = getlocal("equip_upgrade_success")
                        smallDialog:showHeroEquipUpgradeDialog(self.heroVo.hid,eid,self.heroVo.productOrder,titleStr,self.layerNum+1,nil,true)
                    end
                end
            end
            socketHelper:equipAdvance(self.heroVo.hid,eid,advanceHandler)
        end
        local upgradeBtn= GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",touchCallback2,2,getlocal("super_weapon_lvUp"),24/0.8,101)
        upgradeBtn:setScale(0.8)
        local btnLb = upgradeBtn:getChildByTag(101)
        if btnLb then
            btnLb = tolua.cast(btnLb,"CCLabelTTF")
            btnLb:setFontName("Helvetica-bold")
        end
        local btnMenu = CCMenu:create()
        btnMenu:addChild(upgradeBtn)
        btnMenu:alignItemsHorizontallyWithPadding(50)
        btnMenu:setTouchPriority(-(self.layerNum-1)*20-3)
        self.equipInfoBgSp:addChild(btnMenu)
        btnMenu:setPosition(ccp(self.equipInfoBgSp:getContentSize().width/2, 55))
    end
   
end

-- showLv当前应该显示的等级
function heroEquipDialogTab1:refreshInfo(eid,isCommonUpgrade,showLv,callback)
    if isCommonUpgrade==true then
        if self.equipLevelLb then
            self.isPlaying=true
            local lv,maxLv = heroEquipVoApi:getUpLevelByEidAndIndex(self.heroVo.hid,eid)
            local levelStr = getlocal("RankScene_level")..":"..showLv.."/"..maxLv
            self.equipLevelLb:setString(levelStr)

            -- 动画
            local scaleBy1 = CCScaleBy:create(0.15,2)
            local scaleBy2 = CCScaleBy:create(0.15,0.5)
            local carray=CCArray:create()
            carray:addObject(scaleBy1)
            carray:addObject(scaleBy2)
            local seq=CCSequence:create(carray)
            self.equipLevelLb:runAction(seq);

            local equipLine1 = CCParticleSystemQuad:create("public/hero/equipLine.plist")
            equipLine1.positionType=kCCPositionTypeFree
            equipLine1:setPosition(ccp(self.equipBgSp:getPositionX()+20,self.equipBgSp:getPositionY()-100))
            self.bgLayer:addChild(equipLine1,3)
            local function removeLine1( ... )
                if equipLine1 then
                    equipLine1:stopAllActions()
                    equipLine1:removeFromParentAndCleanup(true)
                    equipLine1=nil
                    self.isPlaying=false
                    if callback then
                        callback()
                    end
                end
            end
            local mvTo1=CCMoveTo:create(0.35,ccp(self.equipBgSp:getPositionX()+20,self.equipBgSp:getPositionY()+20))
            local fc1= CCCallFunc:create(removeLine1)
            local carray1=CCArray:create()
            carray1:addObject(mvTo1)
            carray1:addObject(fc1)
            local seq1 = CCSequence:create(carray1)
            equipLine1:runAction(seq1)

            local equipStar1 = CCParticleSystemQuad:create("public/hero/equipStar.plist")
            equipStar1.positionType=kCCPositionTypeFree
            equipStar1:setPosition(ccp(self.equipBgSp:getPositionX()+20,self.equipBgSp:getPositionY()-100))
            self.bgLayer:addChild(equipStar1,3)
            local function removeLine2( ... )
                if equipStar1 then
                    equipStar1:stopAllActions()
                    equipStar1:removeFromParentAndCleanup(true)
                    equipStar1=nil
                    
                end
            end
            local mvTo2=CCMoveTo:create(0.5,ccp(self.equipBgSp:getPositionX()+20,self.equipBgSp:getPositionY()+20))
            local fc2= CCCallFunc:create(removeLine2)
            local carray2=CCArray:create()
            carray2:addObject(mvTo2)
            carray2:addObject(fc2)
            local seq2 = CCSequence:create(carray2)
            equipStar1:runAction(seq2)
        end
        local upCostItemArr,xpValue,needXpNum,xpname = heroEquipVoApi:getUpCostProp(self.heroVo.hid,eid,showLv)
        if self.upgradeTitleLb then
            local upgradeTitleStr=""..xpValue
            self.upgradeTitleLb:setString(upgradeTitleStr)
        end
        if self.exValueLb then
            for k,v in pairs(upCostItemArr) do
                self.exValueLb:setString(v.num.."")
                if xpValue<v.num then
                    self.exValueLb:setColor(G_ColorRed)
                end
            end
        end
        local attList=heroEquipVoApi:getAttList(self.heroVo.hid,eid,nil,self.heroVo.productOrder,showLv)
        if attList and SizeOfTable(attList)>0 then
            local index = 0
            for k,v in pairs(attList) do
                local propertyStr = v["lb"][1]..":+"..v.value
                if self["equipPropertyLb"..index] then
                    -- if k~="first" then
                    if v["key"]~="first" then    
                        propertyStr = v["lb"][1]..":+"..(v.value).."%"
                    end
                    self["equipPropertyLb"..index]:setString(propertyStr)
                end
                index=index+1  
            end
        end

    end
    
    if self and self.equipFightLb then
        local fightValue=heroEquipVoApi:getEquipFight(self.heroVo.hid,self.heroVo.productOrder,showLv,eid)
        self.equipFightLb:setString(getlocal("equipFight")..fightValue)
    end
end

function heroEquipDialogTab1:tick()

end

function heroEquipDialogTab1:dispose()
         CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acMeteoriteLanding.plist")
    if self.containerSp then
        self.containerSp:removeFromParentAndCleanup(true)
        self.containerSp=nil
    end

    self.bgLayer:removeFromParentAndCleanup(true)
    self.parentDialog=nil
    self.layerNum=nil
    self.bgLayer=nil
    self.equipLevelLb=nil
    self.isPlaying=false                    --是否在播放动画
end