heroEquipDialogTab2={}
function heroEquipDialogTab2:new(selectedIndex,heroVoList,parentDialog)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.heroVo=nil                      --当前选择的将领
    self.selectedEquipSp=nil                --选中的武器sp
    self.equipInfoBgSp=nil
    self.selectedIndex=selectedIndex        --当前选择的将领索引
    self.heroVoList=heroVoList              --所有的将领vo数组
    self.containerSp=nil
    self.parentDialog=parentDialog
    return nc
end


function heroEquipDialogTab2:init(layerNum)
    self.layerNum=layerNum
    self.bgLayer=CCLayer:create()
    self.heroVo=self.heroVoList[self.selectedIndex]
    self:switchHero()
    return self.bgLayer
end

function heroEquipDialogTab2:initPage()
    local function leftPageHandler()
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
    -- else
    --     leftMenu:setPosition(ccp(px,py+size.height/2))
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
    -- else
    --     rightMenu:setPosition(ccp(px+size.width,py+size.height/2))
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


function heroEquipDialogTab2:switchHero(selectedIndex)
    if selectedIndex then
        self.selectedIndex=selectedIndex
        self.heroVo=self.heroVoList[self.selectedIndex]
    end
    if self.containerSp then
        self.containerSp:removeFromParentAndCleanup(true)

        self.containerSp=nil
        self.equipInfoBgSp = nil
        for i,v in pairs(heroEquipVoApi:getHeroEidList()) do
            self["equipBgSp"..i] = nil
        end
    end
    self.containerSp=CCSprite:create()
    self.containerSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width,self.bgLayer:getContentSize().height))
    self.containerSp:setAnchorPoint(ccp(0.5,0.5))
    self.containerSp:setPosition(getCenterPoint(self.bgLayer))
    self.bgLayer:addChild(self.containerSp)
    self:initTableView()

end

--设置对话框里的tableView
function heroEquipDialogTab2:initTableView()

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

function heroEquipDialogTab2:initEquipIcon(shwoSelectedIndex,eid,isInit)
    -- 6个装备区域
    local function inputHandler(hd,fn,idx)
        if self.isPlaying==true then
            return
        end
       if self and self.selectedEquipSp and self["equipBgSp"..(idx-100)] then
            -- self.selectedEquipSp:removeFromParentAndCleanup(false)
            local newX = self["equipBgSp"..(idx-100)]:getPositionX()
            local newY = self["equipBgSp"..(idx-100)]:getPositionY()
            self.selectedEquipSp:setPosition(ccp(newX,newY))
            -- self["equipBgSp"..(idx-100)]:addChild(self.selectedEquipSp)
            -- if (idx-100)==3 or (idx-100)==6 then
            --     self:showEquipInfo(idx-100,false)
            -- else
                self:showEquipInfo(self.heroVo.hid,idx-100)
            -- end
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
        local equipBgSp = heroEquipVoApi:getEquipIcon(self.heroVo.hid,iconSize,v,inputHandler,nil,self.heroVo.productOrder,2)    
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
        
        for i,v in pairs(heroEquipVoApi:getHeroEidList()) do
            if self["equipBgSp"..i] then
                self["equipBgSp"..i]:removeFromParentAndCleanup(true)

                self["equipBgSp"..i]=nil
            end
            local iconPx,iconPy=showEquipItem(i,v)
            if isInit==true and i==1 then
                -- self.selectedEquipSp=G_addRectFlicker(equipBgSp,iconScale,iconScale)
                self.selectedEquipSp=CCSprite:createWithSpriteFrameName("equipSelectedRect.png") 
                self.selectedEquipSp:setPosition(ccp(iconPx,iconPy))
                self.selectedEquipSp:setScale((iconSize.width+10)/self.selectedEquipSp:getContentSize().width)
                self.containerSp:addChild(self.selectedEquipSp,3)
                self:showEquipInfo(self.heroVo.hid,i)
            end
        end
    -- end
end

function heroEquipDialogTab2:showMaxLvEquipInfo(hid,idx)

end

-- idx装备索引，isCommonEquip是否为普通装备，isCommonUpgrade是否为普通强化
function heroEquipDialogTab2:showEquipInfo(hid,idx)
    local eid = heroEquipVoApi:getHeroEidList()[idx]
    local attList2,ifMaxLv=heroEquipVoApi:getAttList(self.heroVo.hid,eid,1,self.heroVo.productOrder)
    
    local iconSize = CCSizeMake(100,100)
    local temH=self.descBgSp:getPositionY()-self.descBgSp:getContentSize().height*self.descBgScaleY-10
    local upgradeDescH = 48
    local equipIconY=12
    local equipIconScale = 1
    local equipButtomSpY = 20
    local lineY = 0
    if G_isIphone5()==true then
        iconSize = CCSizeMake(120,120)
        upgradeDescH = 58
        equipIconY=30
        equipIconScale=1.2
        equipButtomSpY = 0
        lineY = 15
    end
    
    -- local eid = heroEquipVoApi:getHeroEidList()[idx]
    -- local iconSize = CCSizeMake(100,100)
    -- local temH=self.descBgSp:getPositionY()-self.descBgSp:getContentSize().height*self.descBgScaleY-10
    -- local upgradeDescH = 25
    -- local lineY = 5
    -- local equipIconY=10
    -- if G_isIphone5()==true then
    --     iconSize = CCSizeMake(120,120)
    --     lineY = 20
    --     equipIconY=30
    --     upgradeDescH=40
    -- end
    if self and self.equipInfoBgSp then
        self.equipInfoBgSp:removeFromParentAndCleanup(true)

        self.equipInfoBgSp=nil
    end


    -- 装备详细信息及强化信息
    local function touch( ... )
        
    end
    local function clickIconHandler( ... )
        -- body
    end
    self.equipInfoBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray2.png",CCRect(20, 20, 1, 1),touch)
    self.equipInfoBgSp:setAnchorPoint(ccp(0.5,0))
    self.equipInfoBgSp:setContentSize(CCSizeMake(self.containerSp:getContentSize().width-37,temH))
    self.equipInfoBgSp:setPosition(ccp(self.containerSp:getContentSize().width/2,10))
    self.containerSp:addChild(self.equipInfoBgSp,3)
    -- self.equipInfoBgSp:setVisible(false)
    
    local iconSize = CCSizeMake(100,100)
    local titleBgY = 0
    if ifMaxLv==true then
        local lv,maxLv = heroEquipVoApi:getUpLevelByEidAndIndex(self.heroVo.hid,eid)
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
            starSp:setPosition(ccp(90,self.equipInfoBgSp:getContentSize().height-equipIconY-24*i))
            self.equipInfoBgSp:addChild(starSp)
        end

        local equipIconPic = heroEquipVoApi:getEquipIconPic(self.heroVo.hid,eid)
        self.equipBgSp = LuaCCSprite:createWithSpriteFrameName(equipIconPic,touch)
        self.equipBgSp:setAnchorPoint(ccp(0.5,1))
        self.equipBgSp:setPosition(ccp(180,self.equipInfoBgSp:getContentSize().height-equipIconY))
        self.equipInfoBgSp:addChild(self.equipBgSp,2)
        self.equipBgSp:setScale(equipIconScale)

        local equipButtomSp = LuaCCSprite:createWithSpriteFrameName("acMeteoriteLanding_2.png",touch)
        equipButtomSp:setPosition(ccp(180,self.equipInfoBgSp:getContentSize().height-self.equipBgSp:getContentSize().height+equipButtomSpY))
        equipButtomSp:setAnchorPoint(ccp(0.5,1))
        self.equipInfoBgSp:addChild(equipButtomSp,1)
        equipButtomSp:setScale(equipIconScale)

        local equipNameLb = GetTTFLabelWrap(heroEquipVoApi:getEquipName(self.heroVo.hid,eid),30,CCSize(400, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        equipNameLb:setAnchorPoint(ccp(0,1))
        equipNameLb:setPosition(ccp(self.equipBgSp:getPositionX()+self.equipBgSp:getContentSize().width+20,self.equipInfoBgSp:getContentSize().height-equipIconY-8))
        self.equipInfoBgSp:addChild(equipNameLb)
        local jinjieLv,maxJinjieLv,unEquipLevel=heroEquipVoApi:getJinjieLevelByEidAndIndex(self.heroVo.hid,eid,self.heroVo.productOrder)
        equipNameLb:setColor(heroEquipVoApi:getEquipNameColor(jinjieLv))
        
        local levelStr = getlocal("RankScene_level")..":"..lv.."/"..maxLv
        self.equipLevelLb = GetTTFLabel(levelStr,23)
        self.equipLevelLb:setAnchorPoint(ccp(0.5,0.5))
        self.equipLevelLb:setPosition(ccp(equipNameLb:getPositionX()+self.equipLevelLb:getContentSize().width/2,equipNameLb:getPositionY()-equipNameLb:getContentSize().height-equipIconY))
        self.equipInfoBgSp:addChild(self.equipLevelLb)

        local attList=heroEquipVoApi:getAttList(self.heroVo.hid,eid,nil,self.heroVo.productOrder)
        
        if attList and SizeOfTable(attList)>0 then
            local index = 0
            for k,v in pairs(attList) do
                local propertyStr = v["lb"][1]..":+"..v.value
                -- if k~="first" then
                if v["key"]~="first" then    
                    propertyStr = v["lb"][1]..":+"..(v.value).."%"
                end
                self["equipPropertyLb"..index] = GetTTFLabelWrap(propertyStr,23,CCSize(400, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                local py1 = self.equipLevelLb:getPositionY()-self.equipLevelLb:getContentSize().height/2-(self["equipPropertyLb"..index]:getContentSize().height+5)*index-5
                self["equipPropertyLb"..index]:setAnchorPoint(ccp(0,1))
                self["equipPropertyLb"..index]:setPosition(ccp(equipNameLb:getPositionX(),py1))
                self.equipInfoBgSp:addChild(self["equipPropertyLb"..index])  
                index=index+1  
                titleBgY=py1-35-lineY
            end
        end
    else
        local equipIconSp1 = heroEquipVoApi:getEquipIcon(hid,iconSize,eid,clickIconHandler,nil,self.heroVo.productOrder)    
        equipIconSp1:setAnchorPoint(ccp(0.5,1))
        equipIconSp1:setPosition(ccp(170,self.equipInfoBgSp:getContentSize().height-equipIconY))
        self.equipInfoBgSp:addChild(equipIconSp1)
        -- equipIconSp1:setScale(0.8)

        local equipIconSp2 = heroEquipVoApi:getEquipIcon(hid,iconSize,eid,clickIconHandler,1,self.heroVo.productOrder)    
        equipIconSp2:setAnchorPoint(ccp(0.5,1))
        equipIconSp2:setPosition(ccp(self.equipInfoBgSp:getContentSize().width-170,self.equipInfoBgSp:getContentSize().height-equipIconY))
        self.equipInfoBgSp:addChild(equipIconSp2)
        -- equipIconSp2:setScale(0.8)

        local arowSp=CCSprite:createWithSpriteFrameName("GuideArow.png")
        arowSp:setPosition(ccp(self.equipInfoBgSp:getContentSize().width/2,self.equipInfoBgSp:getContentSize().height-equipIconY-equipIconSp2:getContentSize().height/2))
        self.equipInfoBgSp:addChild(arowSp)
        arowSp:setRotation(-90)

        local attList1=heroEquipVoApi:getAttList(self.heroVo.hid,eid,nil,self.heroVo.productOrder)
        
        if attList1 and SizeOfTable(attList1)>0 then
            local index = 0
            for k,v in pairs(attList1) do

                local equipAttrNameLb1=GetTTFLabel(v["lb"][1],20)
                local py1 = equipIconSp1:getPositionY()-equipIconSp1:getContentSize().height-10-(equipAttrNameLb1:getContentSize().height+5)*index
                equipAttrNameLb1:setAnchorPoint(ccp(1,1));
                self.equipInfoBgSp:addChild(equipAttrNameLb1)
                local propertyStr = ":+"..v.value
                -- if k~="first" then
                if v["key"]~="first" then    
                    propertyStr = ":+"..(v.value).."%"
                end
                local equipAttrNumLb1=GetTTFLabel(propertyStr,20)
                equipAttrNumLb1:setAnchorPoint(ccp(0,1));
                self.equipInfoBgSp:addChild(equipAttrNumLb1)
                -- equipAttrNumLb1:setColor(G_ColorGreen)
                index=index+1  

                local temW = equipAttrNameLb1:getContentSize().width-equipAttrNumLb1:getContentSize().width
                equipAttrNameLb1:setPosition(ccp(equipIconSp1:getPositionX()+temW/2,py1))
                equipAttrNumLb1:setPosition(ccp(equipIconSp1:getPositionX()+temW/2,py1))


            end
        end

        
        if attList2 and SizeOfTable(attList2)>0 then
            local index = 0
            for k,v in pairs(attList2) do

                local equipAttrNameLb1=GetTTFLabel(v["lb"][1],20)
                local py1 = equipIconSp1:getPositionY()-equipIconSp1:getContentSize().height-10-(equipAttrNameLb1:getContentSize().height+5)*index
                equipAttrNameLb1:setAnchorPoint(ccp(1,1));
                self.equipInfoBgSp:addChild(equipAttrNameLb1)
                local propertyStr = ":+"..v.value
                -- if k~="first" then
                if v["key"]~="first" then    
                    propertyStr = ":+"..(v.value).."%"
                end
                local equipAttrNumLb1=GetTTFLabel(propertyStr,20)
                equipAttrNumLb1:setAnchorPoint(ccp(0,1));
                self.equipInfoBgSp:addChild(equipAttrNumLb1)
                equipAttrNumLb1:setColor(G_ColorGreen)
                index=index+1  

                local temW = equipAttrNameLb1:getContentSize().width-equipAttrNumLb1:getContentSize().width
                equipAttrNameLb1:setPosition(ccp(equipIconSp2:getPositionX()+temW/2,py1))
                equipAttrNumLb1:setPosition(ccp(equipIconSp2:getPositionX()+temW/2,py1))
                titleBgY=py1-33-lineY
            end
        end
    end
    

    local function skillBgHandler( ... )
        -- body
    end
    
    local lineSp2 = CCSprite:createWithSpriteFrameName("LineCross.png");
    lineSp2:setAnchorPoint(ccp(0.5,0.5));
    if G_getIphoneType() == G_iphoneX then
        titleBgY = titleBgY - 50
    end
    lineSp2:setPosition(self.equipInfoBgSp:getContentSize().width/2,titleBgY)
    self.equipInfoBgSp:addChild(lineSp2,2)
    lineSp2:setScaleX((self.equipInfoBgSp:getContentSize().width-30)/lineSp2:getContentSize().width)

    local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 20, 10, 10),function ()end)
    titleBg:setContentSize(CCSizeMake(300,45))
    titleBg:setScaleX((self.equipInfoBgSp:getContentSize().width-20)/titleBg:getContentSize().width)
    titleBg:setPosition(ccp((self.equipInfoBgSp:getContentSize().width)/2,titleBgY))
    self.equipInfoBgSp:addChild(titleBg,2)
    titleBg:setAnchorPoint(ccp(0.5,1))

    local subTitleStr
    local skillOldNameStr = ""
    local skillNameStr = ""
    local skillDesStr 
    local awakenLv = heroEquipVoApi:getAwakenLevelByEidAndIndex(self.heroVo.hid,eid)
    local skillList=heroEquipVoApi:getSkillList(self.heroVo.hid,eid)
    local skillTitleColor = nil
    local skillDescColor = nil
    local skillExtraDescColor = nil
    local skillDesStrExtra = nil
    if awakenLv==0 then
        if skillList==nil then--尚未觉醒    其他装备
            subTitleStr=getlocal("equip_skill_2")
            skillDesStr=getlocal("equip_skill_desc_2")
            skillTitleColor=G_ColorGreen
        else                  --尚未觉醒    【武器】带技能
            for k,v in pairs(skillList) do
                subTitleStr=getlocal("equip_skill_1")
                local lvStr,value,isMax,skillLevel=heroVoApi:getHeroSkillLvAndValue(self.heroVo.hid,k,self.heroVo.productOrder,false,v)
                skillOldNameStr=getlocal(heroSkillCfg[k].name)
                skillNameStr=getlocal(heroSkillCfg[v].name)

                local oldValue=""
                if type(heroSkillCfg[k].attType) == "table" then
                    local attTypeSize = SizeOfTable(heroSkillCfg[k].attType)
                    for kk, vv in pairs(heroSkillCfg[k].attType) do
                        local tempV = skillLevel*heroSkillCfg[k].attValuePerLv[kk]
                        if(vv~="first" and vv~="antifirst")then
                            oldValue = oldValue .. (tempV * 100) .. "%%"
                        else
                            oldValue = oldValue .. tempV
                        end
                        if k ~= attTypeSize then
                            oldValue = oldValue .. ","
                        end
                    end
                else
                    oldValue=skillLevel*heroSkillCfg[k].attValuePerLv
                    if(heroSkillCfg[k].attType~="first" and heroSkillCfg[k].attType~="antifirst")then
                        oldValue=(oldValue*100).."%%"
                    end
                end
                local newValue=""
                if type(heroSkillCfg[v].attType) == "table" then
                    local attTypeSize = SizeOfTable(heroSkillCfg[v].attType)
                    for kk, vv in pairs(heroSkillCfg[v].attType) do
                        local tempV = skillLevel*heroSkillCfg[v].attValuePerLv[kk]
                        if(vv~="first" and vv~="antifirst")then
                            newValue = newValue .. (tempV * 100) .. "%%"
                        else
                            newValue = newValue .. tempV
                        end
                        if k ~= attTypeSize then
                            newValue = newValue .. ","
                        end
                    end
                else
                    newValue=skillLevel*heroSkillCfg[v].attValuePerLv
                    if(heroSkillCfg[v].attType~="first" and heroSkillCfg[v].attType~="antifirst")then
                        newValue=(newValue*100).."%%"
                    end
                end

                -- local oldValue=skillLevel*heroSkillCfg[k].attValuePerLv
                -- local newValue=skillLevel*heroSkillCfg[v].attValuePerLv
                -- if(heroSkillCfg[k].attType~="first" and heroSkillCfg[k].attType~="antifirst")then
                --     oldValue=(oldValue*100).."%%"
                -- end
                -- if(heroSkillCfg[v].attType~="first" and heroSkillCfg[v].attType~="antifirst")then
                --     newValue=(newValue*100).."%%"
                -- end

                skillDesStr=getlocal("equip_skill_desc_1",{skillOldNameStr..G_LV()..skillLevel,skillNameStr..G_LV()..skillLevel,oldValue,newValue})
                skillDesStrExtra = getlocal("equip_skill_desc_4",{skillNameStr})
            end
            -- skillDesStr=getlocal("equip_skill_desc_1")
            skillTitleColor=G_ColorBlue
            skillDescColor=G_ColorWhite
            skillExtraDescColor=G_ColorGreen
        end
    else
        if skillList==nil then--已觉醒 其他装备
            subTitleStr=getlocal("equip_skill_2")
            skillDesStr=getlocal("equip_skill_desc_2")
            skillTitleColor=G_ColorGreen
        else                  --已觉醒 【武器】带技能
            for k,v in pairs(skillList) do
                local lvStr,value,isMax,skillLevel=heroVoApi:getHeroSkillLvAndValue(self.heroVo.hid,v,self.heroVo.productOrder,true,k)
                skillNameStr=getlocal(heroSkillCfg[v].name)
                skillDesStr=getlocal("equip_skill_desc_4",{skillNameStr})
                skillDesStrExtra = getlocal("equip_skill_desc_3")
            end
            
            subTitleStr=getlocal("equip_awaken_title")
            -- skillDesStr=getlocal("equip_skill_desc_1")
            skillTitleColor=G_ColorYellowPro
            skillDescColor=G_ColorWhite
            skillExtraDescColor=G_ColorGreen
        end
    end
    
    local subTitleLb = GetTTFLabelWrap(subTitleStr,24,CCSize(self.equipInfoBgSp:getContentSize().width-60, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop,"Helvetica-bold")
    subTitleLb:setAnchorPoint(ccp(0.5,0.5))
    subTitleLb:setPosition(ccp(self.equipInfoBgSp:getContentSize().width/2,titleBg:getPositionY()-titleBg:getContentSize().height/2))
    self.equipInfoBgSp:addChild(subTitleLb,3)
    if skillTitleColor then
        subTitleLb:setColor(skillTitleColor)
    end

    local desWidth=G_VisibleSize.width-60
    -- local desHeight=100
    -- local adaptSize = 20
    -- if G_isIphone5()==true then
    --     desHeight=150
    -- end
    -- if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
    --     adaptSize = 23
    --     desHeight = 200 
    -- end
    local desHeight = (G_getIphoneType() == G_iphone4) and 100 or 145
    local adaptSize = 22
    local skillDesTb={skillDesStr,skillDesStrExtra}
    local skillDesColorTb={G_ColorWhite,G_ColorGreen}
    local desTv,desLabel = G_LabelTableView(CCSizeMake(desWidth,desHeight),skillDesTb,adaptSize,kCCTextAlignmentCenter,skillDesColorTb)
    self.equipInfoBgSp:addChild(desTv)
    desTv:setPosition(ccp((self.equipInfoBgSp:getContentSize().width-desWidth)/2,titleBg:getPositionY()-titleBg:getContentSize().height-desHeight))
    desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    desTv:setMaxDisToBottomOrTop(80)
    
    -- local skillNameStrLb = GetTTFLabelWrap(skillNameStr,23,CCSize(160, 0),kCCTextAlignmentRight,kCCVerticalTextAlignmentTop)
    -- skillNameStrLb:setAnchorPoint(ccp(1,0.5))
    -- skillNameStrLb:setPosition(ccp(175,titleBg:getPositionY()-titleBg:getContentSize().height-upgradeDescH))
    -- self.equipInfoBgSp:addChild(skillNameStrLb,3)
    -- skillNameStrLb:setColor(G_ColorYellowPro)

    -- local skillDescStrLb = GetTTFLabelWrap(skillDesStr,23,CCSize(420, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    -- skillDescStrLb:setAnchorPoint(ccp(0,0.5))
    -- skillDescStrLb:setPosition(ccp(180,titleBg:getPositionY()-titleBg:getContentSize().height-upgradeDescH))
    -- if skillNameStr=="" then
        -- skillDescStrLb = GetTTFLabelWrap(skillDesStr,23,CCSize(self.equipInfoBgSp:getContentSize().width-60, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        -- skillDescStrLb:setAnchorPoint(ccp(0.5,0.5))
        -- skillDescStrLb:setPosition(ccp(self.equipInfoBgSp:getContentSize().width/2,titleBg:getPositionY()-titleBg:getContentSize().height-upgradeDescH))
        -- if skillDesStrExtra then
        --     local skillDescExtraLb = GetTTFLabelWrap(skillDesStrExtra,23,CCSize(self.equipInfoBgSp:getContentSize().width-60, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        --     skillDescExtraLb:setAnchorPoint(ccp(0.5,0.5))
        --     skillDescExtraLb:setPosition(ccp(self.equipInfoBgSp:getContentSize().width/2,skillDescStrLb:getPositionY() - upgradeDescH/2 - skillDescExtraLb:getContentSize().height/2 - 5))
        --     self.equipInfoBgSp:addChild(skillDescExtraLb,3)
        --     if skillExtraDescColor then
        --         skillDescExtraLb:setColor(skillExtraDescColor)
        --     end
        -- end

    -- end
    -- self.equipInfoBgSp:addChild(skillDescStrLb,3)
    -- if skillDescColor then
    --     skillDescStrLb:setColor(skillDescColor)
    -- end

    if ifMaxLv==true then
        local maxLvLb = GetTTFLabelWrap(getlocal("equip_maxLv2"),30,CCSize(self.equipInfoBgSp:getContentSize().width-40, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        maxLvLb:setAnchorPoint(ccp(0.5,0.5))
        maxLvLb:setPosition(ccp(self.equipInfoBgSp:getContentSize().width/2,80))
        self.equipInfoBgSp:addChild(maxLvLb)
        maxLvLb:setColor(G_ColorYellowPro)
        return
    end

    -- 觉醒消耗的道具
    local costProp = heroEquipVoApi:getAwakenCostProp(self.heroVo.hid,eid)
    if costProp==nil then
        return
    end
    local ifCanAwaken = true
    local award = FormatItem(costProp)
    local propNum = SizeOfTable(award)
    for i=1,propNum do
        local item = award[i]
        local curNum = bagVoApi:getItemNumId(item.id)
        local needNum = item.num
        local isShowInfo = true
        if curNum<needNum then
            isShowInfo = false
        end
        local function showInfoHandler()
            if curNum<needNum then
                local function callback2()
                    -- if self and self.parentDialog then
                    --     self.parentDialog:closeParentDialog()
                    -- end
                    if not self.bgLayer then
                        do return end
                    end
                    --刷新当前将领装备页面
                    self.heroVo=self.heroVoList[self.selectedIndex]
                    self:switchHero(self.selectedIndex)

                    if self and self.selectedEquipSp and self["equipBgSp"..idx] then
                        local newX = self["equipBgSp"..idx]:getPositionX()
                        local newY = self["equipBgSp"..idx]:getPositionY()
                        self.selectedEquipSp:setPosition(ccp(newX,newY))
                        self:showEquipInfo(self.heroVo.hid,idx)
                    end

                    if self and self.parentDialog then
                        --刷新将领装备页面将领列表的状态
                        self.parentDialog:refreshTabStage()
                    end
                end
                local challangeList,rtype=heroEquipVoApi:getPropChannelList(item.id)
                -- if #challangeList>0 then
                    smallDialog:showHeroEquipPropJumpDialog(item,curNum,needNum,challangeList,rtype,self.layerNum+1,callback2)
                -- end
            end
        end
        local icon = G_getItemIcon(item,100,isShowInfo,self.layerNum+1,showInfoHandler)
        icon:ignoreAnchorPointForPosition(false)
        icon:setAnchorPoint(ccp(0.5,0))
        local xSpace = icon:getContentSize().width+10
        local px=30+xSpace/2+xSpace*(i-1)
        icon:setPosition(ccp(px,15))
        icon:setIsSallow(false)
        icon:setTouchPriority(-(self.layerNum-1)*20-4)
        self.equipInfoBgSp:addChild(icon,1)
        icon:setTag(i)

        local propNumLb = GetTTFLabelWrap(curNum.."/"..needNum,23,CCSize(icon:getContentSize().width, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        propNumLb:setAnchorPoint(ccp(0.5,0))
        propNumLb:setPosition(ccp(icon:getContentSize().width/2,10))
        icon:addChild(propNumLb,2)
        if curNum<needNum then
            propNumLb:setColor(G_ColorRed)
            ifCanAwaken=false
            local function tmpFunc( ... )
                
            end
            local maskSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,2,2),tmpFunc)
            maskSp:setPosition(getCenterPoint(icon))
            maskSp:setScale(icon:getContentSize().width/maskSp:getContentSize().width)
            icon:addChild(maskSp)
            local addSp=LuaCCScale9Sprite:createWithSpriteFrameName("ProduceTankIconMore.png",CCRect(10,10,2,2),tmpFunc)
            addSp:setPosition(getCenterPoint(icon))
            -- addSp:setScale(icon:getContentSize().width/addSp:getContentSize().width)
            icon:addChild(addSp,1)
            -- IconCheck.png
        end
        
    end
    local function touchCallback2(tag,object)
        if ifCanAwaken==false then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("noenough_prop1"),28)
            return
        end
       
        local function awakenHandler(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                if sData and sData.data and sData.data.equip then
                    heroEquipVoApi:formatData(sData.data.equip)
                    self:showEquipInfo(self.heroVo.hid,idx)
                    self:initEquipIcon(idx,eid)
                    local titleStr = getlocal("equip_awaken_success")
                    smallDialog:showHeroEquipUpgradeDialog(self.heroVo.hid,eid,self.heroVo.productOrder,titleStr,self.layerNum+1)
                    if self and self.equipFightLb then
                        local fightValue=heroEquipVoApi:getEquipFight(self.heroVo.hid,self.heroVo.productOrder)
                        self.equipFightLb:setString(getlocal("equipFight")..fightValue)
                    end
                    if self and self.parentDialog then
                        self.parentDialog:refreshTabStage()
                    end
                end
            end
        end
        socketHelper:equipAwaken(self.heroVo.hid,eid,awakenHandler)
    end
    local upgradeBtn= GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",touchCallback2,2,getlocal("awaken"),24/0.8,101)
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
    btnMenu:setPosition(ccp(self.equipInfoBgSp:getContentSize().width-upgradeBtn:getContentSize().width/2-10, 50))
end


function heroEquipDialogTab2:tick()

end

function heroEquipDialogTab2:dispose()
    if self.containerSp then
        self.containerSp:removeFromParentAndCleanup(true)
        self.containerSp=nil
    end

    self.bgLayer:removeFromParentAndCleanup(true)
    self.layerNum=nil
    self.bgLayer=nil
    self.heroVo=nil                      --当前选择的将领
    self.selectedEquipSp=nil                --选中的武器sp
    self.equipInfoBgSp=nil
    self.selectedIndex=nil        --当前选择的将领索引
    self.heroVoList=nil              --所有的将领vo数组
    self.containerSp=nil
    self.parentDialog=nil
end