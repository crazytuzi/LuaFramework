ltzdzTankInfoDialog={}
function ltzdzTankInfoDialog:new()
    local nc={
            bgLayer,
            touchDialogBg,
            isUseAmi,
            require4={}, --4个需求
            id,

            attLbAdd,
            lifeLbAdd,
            penetrateLb,
            armorLb,

            accurateLbAdd,
            criticalLbAdd,
            avoidLbAdd,
            decriticalLbAdd,

            critDmgLb,
            decritDmgLb,
          }
    setmetatable(nc,self)
    self.__index=self
    return nc
end
--container:父容器 category:build,skill等 id:ID type:type 
function ltzdzTankInfoDialog:create(container,id,layerNum,hideNum,tankInfo)
    self.id=id
    self.isUseAmi=true
    
    local td=self:new()
    td:init(container,id,layerNum,hideNum,tankInfo)
    
end


function ltzdzTankInfoDialog:init(parent,id,layerNum,hideNum,tankInfo)
    spriteController:addPlist("public/acAnniversary.plist")
    spriteController:addTexture("public/acAnniversary.png")

    local function touchDialog()
        if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
            PlayEffect(audioCfg.mouseClick)
            self:close()
        end
    end
    
    local rect = CCRect(0, 0, 400, 350)
    local capInSet = CCRect(130, 50, 1, 1)
    local capInSet1 = CCRect(10, 10, 1, 1)

    local cellWidth=500
    local bgHeight=600
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",capInSet,touchDialog);
    if base.ifAccessoryOpen==1 then
        bgHeight=bgHeight+70
    end
    local tvHeight=bgHeight-60


    local lbSize = CCSize(440, 0);
    
    -- if G_isIOS()==false then
    --     lbSize = CCSize(450, 0);
    -- end
    local textSizeD  --面板文字描述size
    if platCfg.platCfgBMImage[G_curPlatName()]~=nil then
        textSizeD=23
    else
        textSizeD=25
    end

    local skillHeight=0
    local isHasAbility=false
    local abilityID=tankInfo.abilityID
    local abilityLv=tankInfo.abilityLv
    local skillName=""
    local skillDesc=""
    local skillIcon=nil
    local labelSize=20

    --异星科技增加技能点数
    if base.alien==1 and base.richMineOpen==1 then
        bgHeight=bgHeight+70
        tvHeight=tvHeight+70
    end

    if abilityID and abilityID~="" and abilityLv and abilityLv~="" and tonumber(abilityLv) and tonumber(abilityLv)>0 then
        abilityLv=tonumber(abilityLv)
        local aCfg=abilityCfg[abilityID][abilityLv]
        skillName=getlocal(aCfg.name)
        local descParm={}
        local rNum = G_specTankId[self.id] or 100
        if aCfg.value1 then
            table.insert(descParm,aCfg.value1*rNum)
        end
        if aCfg.value2 then
            table.insert(descParm,aCfg.value2*rNum)
        end
        skillDesc=getlocal(aCfg.desc,descParm)
        skillIcon=CCSprite:createWithSpriteFrameName(aCfg.icon)

        local skillDescLb1=GetTTFLabelWrap(skillDesc,labelSize-2,lbSize,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        skillHeight=90+skillDescLb1:getContentSize().height

        isHasAbility=true
        bgHeight=bgHeight+skillHeight
        tvHeight=tvHeight+skillHeight
    end

    
    bgHeight=bgHeight-100
    tvHeight=tvHeight-100
    local addH=0
    if tankCfg[id].tankAgainst and type(tankCfg[id].tankAgainst)=="table" and SizeOfTable(tankCfg[id].tankAgainst)~=0 then
        local type=tankCfg[id].tankAgainst[1]

        local desStr=getlocal("tank_kz_des_" .. type,{tankCfg[id].tankAgainst[2]})
        local kzDesLb,lbHeight=G_getRichTextLabel(desStr,{G_ColorWhite,G_ColorGreen},labelSize-2,lbSize.width,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        -- GetTTFLabelWrap(desStr,labelSize-2,lbSize,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)

        -- local desH=kzDesLb:getContentSize().height

        -- bgHeight=bgHeight+desH+5+50
        tvHeight=tvHeight+lbHeight+5+50
        addH=addH+5+50
    end
    if tankCfg[id].buffShow and type(tankCfg[id].buffShow)=="table" then
        local type=tankCfg[id].buffShow[1]

        local value
        if tonumber(tankCfg[id].buffvalue)<1 then
            value=tonumber(tankCfg[id].buffvalue)*100
        else
            value=tonumber(tankCfg[id].buffvalue)
        end
        local desStr=getlocal("tank_gh_des_" .. type,{value})
        local ghDesLb,lbHeight=G_getRichTextLabel(desStr,{G_ColorWhite,G_ColorGreen},labelSize-2,lbSize.width,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        -- GetTTFLabelWrap(desStr,labelSize-2,lbSize,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)

        -- local desH=ghDesLb:getContentSize().height
        bgHeight=bgHeight+lbHeight+5+50
        tvHeight=tvHeight+lbHeight+5+50
    end

    dialogBg:setContentSize(CCSizeMake(cellWidth,bgHeight))
    self.bgLayer=dialogBg

    self.touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",capInSet1,touchDialog);
    self.touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect1=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    self.touchDialogBg:setContentSize(rect1)
    self.touchDialogBg:setOpacity(180)
    self.touchDialogBg:setPosition(getCenterPoint(sceneGame))
    sceneGame:addChild(self.touchDialogBg,layerNum);



    local cellHeight=tvHeight--+skillHeight
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return 1
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(cellWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            self.container=cell
            
            local dialogBgHeight=cellHeight+20

            local skinId = ltzdzFightApi:getSkinIdByTankId(id)
            local spriteIcon = tankVoApi:getTankIconSp(id,skinId,nil,false)
            spriteIcon:setAnchorPoint(ccp(0,0.5));
            spriteIcon:setScale(0.7)
            spriteIcon:setPosition(30,dialogBgHeight-80)
            self.container:addChild(spriteIcon,2)

            if G_pickedList(id)~=id then
                local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
                spriteIcon:addChild(pickedIcon)
                pickedIcon:setPosition(spriteIcon:getContentSize().width*0.7,spriteIcon:getContentSize().height*0.5-20)
            end
            
            local strWidth = 320
            if G_getCurChoseLanguage() =="ar" then
                strWidth =220 
            end
            local lbName=GetTTFLabelWrap(getlocal(tankCfg[id].name),26,CCSizeMake(strWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
           lbName:setPosition(160,dialogBgHeight-50)
           lbName:setAnchorPoint(ccp(0,0.5));
           self.container:addChild(lbName,2)

           local tankTypeStr=""
           if G_pickedList(id)~=id then
            tankTypeStr=getlocal("ltzdz_tank_type",{getlocal("world_war_sub_title13")})
           else
            tankTypeStr=getlocal("ltzdz_tank_type",{getlocal("merge_precent_name3")})
           end
            local tankTypeLb=GetTTFLabel(tankTypeStr,26)
            tankTypeLb:setPosition(ccp(150,dialogBgHeight-100))
            tankTypeLb:setAnchorPoint(ccp(0,1))
            self.container:addChild(tankTypeLb,2)
            

            local firstSpX = 50-10
            local firstLbX = 110-10
            
            local secndSpX = 230+30
            local secndLbX = 290+30

            local labelSize = 20
            local labelWidth = 150

            local kzH=dialogBgHeight-180
            dialogBgHeight=dialogBgHeight+120
            if tankCfg[id].tankAgainst and type(tankCfg[id].tankAgainst)=="table" and SizeOfTable(tankCfg[id].tankAgainst)~=0 then
                local type=tankCfg[id].tankAgainst[1]

                local kzPic="tank_kz_icon_" ..type.. ".png"
                local kzSp = CCSprite:createWithSpriteFrameName(kzPic);
                local iconScale= 50/kzSp:getContentSize().width
                kzSp:setAnchorPoint(ccp(0,0.5));
                kzSp:setPosition(firstSpX,kzH)
                self.container:addChild(kzSp,2)
                kzSp:setScale(iconScale)

                local nameStr=getlocal("tank_kz_name_" .. type)
                local kzNameLb=GetTTFLabel(nameStr,labelSize)
                kzNameLb:setAnchorPoint(ccp(0,0.5))
                kzNameLb:setPosition(ccp(firstLbX,kzH))
                self.container:addChild(kzNameLb)

                local desStr=getlocal("tank_kz_des_" .. type,{tankCfg[id].tankAgainst[2]})
                local kzDesLb,lbHeight=G_getRichTextLabel(desStr,{G_ColorWhite,G_ColorGreen},labelSize-2,lbSize.width,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)

                -- GetTTFLabelWrap(desStr,labelSize-2,lbSize,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                kzDesLb:setPosition(firstSpX,kzH-30)
                kzDesLb:setAnchorPoint(ccp(0,1))
                self.container:addChild(kzDesLb,2)

                -- local desH=kzDesLb:getContentSize().height
                kzH=kzH-50-lbHeight-10

                dialogBgHeight=dialogBgHeight-lbHeight-50-10
            end
            if tankCfg[id].buffShow and type(tankCfg[id].buffShow)=="table" then
                local type=tankCfg[id].buffShow[1]

                local ghPic="tank_gh_icon_" ..type.. ".png"
                local ghSp = CCSprite:createWithSpriteFrameName(ghPic);
                local iconScale= 50/ghSp:getContentSize().width
                ghSp:setAnchorPoint(ccp(0,0.5));
                ghSp:setPosition(firstSpX,kzH)
                self.container:addChild(ghSp,2)
                ghSp:setScale(iconScale)

                local nameStr=getlocal("tank_gh_name_" .. type)
                local ghNameLb=GetTTFLabel(nameStr,labelSize)
                ghNameLb:setAnchorPoint(ccp(0,0.5))
                ghNameLb:setPosition(ccp(firstLbX,kzH))
                self.container:addChild(ghNameLb)

                local ghLvLb=GetTTFLabel(getlocal("fightLevel",{tankCfg[id].buffShow[2]}),20)
                ghLvLb:setAnchorPoint(ccp(0,0.5))
                ghLvLb:setPosition(ccp(firstLbX+ghNameLb:getContentSize().width+25,kzH))
                self.container:addChild(ghLvLb)
                ghLvLb:setColor(G_ColorYellowPro)

                local value
                if tonumber(tankCfg[id].buffvalue)<1 then
                    value=tonumber(tankCfg[id].buffvalue)*100
                else
                    value=tonumber(tankCfg[id].buffvalue)
                end
                local desStr=getlocal("tank_gh_des_" .. type,{value})
                local ghDesLb,lbHeight=G_getRichTextLabel(desStr,{G_ColorWhite,G_ColorGreen},labelSize-2,lbSize.width,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                -- GetTTFLabelWrap(desStr,labelSize-2,lbSize,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                ghDesLb:setPosition(firstSpX,kzH-30)
                ghDesLb:setAnchorPoint(ccp(0,1))
                self.container:addChild(ghDesLb,2)


                -- local desH=ghDesLb:getContentSize().height
                dialogBgHeight=dialogBgHeight-lbHeight-50-10
            end
            dialogBgHeight=dialogBgHeight-10
            
            if isHasAbility==true and skillIcon then
                local lineSp3 = CCSprite:createWithSpriteFrameName("LineEntity.png");
                lineSp3:setAnchorPoint(ccp(0.5,0.5));
                lineSp3:setPosition(cellWidth/2,dialogBgHeight-275)
                self.container:addChild(lineSp3,2)
                lineSp3:setScaleX((cellWidth-50)/lineSp3:getContentSize().width)
                lineSp3:setScaleY(2)

                skillIcon:setAnchorPoint(ccp(0,0.5));
                skillIcon:setPosition(firstSpX,dialogBgHeight-315)
                self.container:addChild(skillIcon,2)
                skillIcon:setScale(50/skillIcon:getContentSize().width)

                local skillNameLb=GetTTFLabel(skillName,labelSize)
                skillNameLb:setAnchorPoint(ccp(0,0.5))
                skillNameLb:setPosition(ccp(firstLbX,dialogBgHeight-315))
                self.container:addChild(skillNameLb)

                local skillLvLb=GetTTFLabel(getlocal("fightLevel",{abilityLv}),20)
                skillLvLb:setAnchorPoint(ccp(0,0.5))
                skillLvLb:setPosition(ccp(firstLbX+skillNameLb:getContentSize().width+25,dialogBgHeight-315))
                self.container:addChild(skillLvLb)
                skillLvLb:setColor(G_ColorYellowPro)

                local skillDescLb=GetTTFLabelWrap(skillDesc,labelSize-2,lbSize,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                skillDescLb:setAnchorPoint(ccp(0,1))
                skillDescLb:setPosition(firstSpX,dialogBgHeight-350)
                self.container:addChild(skillDescLb,2)

                dialogBgHeight=dialogBgHeight-skillHeight
            end
 
            local attack,life,accurate,avoid,critical,decritical,armor,penetrate,critDmg,decritDmg,baseAttackAdd,baseLifeAdd=tankVoApi:getTankAddProperty(id);
            local baseAttack=tonumber(tankCfg[id].attack)
            local baseLife=tonumber(tankCfg[id].life)
            local carryResource=tonumber(tankCfg[id].carryResource)
        --攻击    
            local attackSp = CCSprite:createWithSpriteFrameName("pro_ship_attack.png");
            local iconScale= 50/attackSp:getContentSize().width
            attackSp:setAnchorPoint(ccp(0,0.5));
            attackSp:setPosition(firstSpX,dialogBgHeight-320)
            self.container:addChild(attackSp,2)
            attackSp:setScale(iconScale)
            
            local attLb=GetTTFLabel(baseAttack,20)
            attLb:setAnchorPoint(ccp(0,0.5))
            attLb:setPosition(ccp(firstLbX,dialogBgHeight-320-14))
            self.container:addChild(attLb)
            
            self.attLbAdd=GetTTFLabel("+"..(tankInfo.dmg-baseAttack),20)
            self.attLbAdd:setAnchorPoint(ccp(0,0.5))
            self.attLbAdd:setPosition(ccp(firstLbX+attLb:getContentSize().width,dialogBgHeight-320-14))
            self.attLbAdd:setColor(G_ColorGreen)
            self.container:addChild(self.attLbAdd)
            
            local attNameLb=GetTTFLabelWrap(getlocal("tankAtk"),labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            attNameLb:setAnchorPoint(ccp(0,0.5))
            attNameLb:setPosition(ccp(firstLbX,dialogBgHeight-320+14))
            self.container:addChild(attNameLb)
        --血量
            local lifeSp = CCSprite:createWithSpriteFrameName("pro_ship_life.png");
            lifeSp:setAnchorPoint(ccp(0,0.5));
            lifeSp:setPosition(firstSpX,dialogBgHeight-390)
            self.container:addChild(lifeSp,2)
            lifeSp:setScale(iconScale)
            
            local lifeLb=GetTTFLabel(baseLife,20)
            lifeLb:setAnchorPoint(ccp(0,0.5))
            lifeLb:setPosition(ccp(firstLbX,dialogBgHeight-390-14))
            self.container:addChild(lifeLb)
            
            self.lifeLbAdd=GetTTFLabel("+"..(tankInfo.maxhp-baseLife),20)
            self.lifeLbAdd:setAnchorPoint(ccp(0,0.5))
            self.lifeLbAdd:setPosition(ccp(firstLbX+lifeLb:getContentSize().width,dialogBgHeight-390-14))
            self.lifeLbAdd:setColor(G_ColorGreen)
            self.container:addChild(self.lifeLbAdd)
            
            local lifeNameLb=GetTTFLabelWrap(getlocal("tankBlood"),labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            lifeNameLb:setAnchorPoint(ccp(0,0.5))
            lifeNameLb:setPosition(ccp(firstLbX,dialogBgHeight-390+14))
            self.container:addChild(lifeNameLb)

        -- 载重 carryResource
        -- local carrySp = CCSprite:createWithSpriteFrameName("tank_carry_icon.png");
        -- carrySp:setAnchorPoint(ccp(0,0.5));
        -- carrySp:setPosition(secndSpX,dialogBgHeight-390)
        -- self.container:addChild(carrySp,2)
        -- carrySp:setScale(iconScale)
        
        -- local carryLb=GetTTFLabel(carryResource,20)
        -- carryLb:setAnchorPoint(ccp(0,0.5))
        -- carryLb:setPosition(ccp(secndLbX,dialogBgHeight-390-14))
        -- self.container:addChild(carryLb)
        
        -- local tankTb={{id,1}}
        -- local totalCarry=tankVoApi:getAttackTanksCarryResource(tankTb)
        -- self.carryAdd=GetTTFLabel("+"..(totalCarry-carryResource),20)
        -- self.carryAdd:setAnchorPoint(ccp(0,0.5))
        -- self.carryAdd:setPosition(ccp(secndLbX+carryLb:getContentSize().width,dialogBgHeight-390-14))
        -- self.carryAdd:setColor(G_ColorGreen)
        -- self.container:addChild(self.carryAdd)
        
        -- local carryNameLb=GetTTFLabelWrap(getlocal("sample_tech_name_24"),labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        -- carryNameLb:setAnchorPoint(ccp(0,0.5))
        -- carryNameLb:setPosition(ccp(secndLbX,dialogBgHeight-390+14))
        -- self.container:addChild(carryNameLb)
        --精准    
            local accurateSp = CCSprite:createWithSpriteFrameName("skill_01.png");
            accurateSp:setAnchorPoint(ccp(0,0.5));
            accurateSp:setPosition(firstSpX,dialogBgHeight-460)
            self.container:addChild(accurateSp,2)
            accurateSp:setScale(iconScale)
            
            local baseAccurate=tonumber(tankCfg[id].accurate)
            local accurateLb=GetTTFLabel(baseAccurate.."%",20)
            accurateLb:setAnchorPoint(ccp(0,0.5))
            accurateLb:setPosition(ccp(firstLbX,dialogBgHeight-474))
            self.container:addChild(accurateLb)
            
            -- print("tankInfo.accuracy",tankInfo.accuracy,baseAccurate)
            self.accurateLbAdd=GetTTFLabel("+"..(tankInfo.accuracy-baseAccurate/100)*100 .. "%",20)
            self.accurateLbAdd:setAnchorPoint(ccp(0,0.5))
            self.accurateLbAdd:setPosition(ccp(firstLbX+accurateLb:getContentSize().width,dialogBgHeight-474))
            self.accurateLbAdd:setColor(G_ColorGreen)
            self.container:addChild(self.accurateLbAdd)

            local accurateNameLb=GetTTFLabelWrap(getlocal("sample_skill_name_101"),labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            accurateNameLb:setAnchorPoint(ccp(0,0.5))
            accurateNameLb:setPosition(ccp(firstLbX,dialogBgHeight-446))
            self.container:addChild(accurateNameLb)

        --暴击    
            local criticalSp = CCSprite:createWithSpriteFrameName("skill_03.png");
            criticalSp:setAnchorPoint(ccp(0,0.5));
            criticalSp:setPosition(firstSpX,dialogBgHeight-530)
            self.container:addChild(criticalSp,2)
            criticalSp:setScale(iconScale)
            
            local baseCritical=tonumber(tankCfg[id].critical)
            local criticalLb=GetTTFLabel(baseCritical.."%",20)
            criticalLb:setAnchorPoint(ccp(0,0.5))
            criticalLb:setPosition(ccp(firstLbX,dialogBgHeight-530-14))
            self.container:addChild(criticalLb)
            
            self.criticalLbAdd=GetTTFLabel("+"..(tankInfo.crit-baseCritical/100)*100 .. "%",20)
            self.criticalLbAdd:setAnchorPoint(ccp(0,0.5))
            self.criticalLbAdd:setPosition(ccp(firstLbX+criticalLb:getContentSize().width,dialogBgHeight-530-14))
            self.criticalLbAdd:setColor(G_ColorGreen)
            self.container:addChild(self.criticalLbAdd)
            
            local criticalNameLb=GetTTFLabelWrap(getlocal("sample_skill_name_103"),labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            criticalNameLb:setAnchorPoint(ccp(0,0.5))
            criticalNameLb:setPosition(ccp(firstLbX,dialogBgHeight-530+14))
            self.container:addChild(criticalNameLb)
            
        --闪避    
            local avoidSp = CCSprite:createWithSpriteFrameName("skill_02.png");
            avoidSp:setAnchorPoint(ccp(0,0.5));
            avoidSp:setPosition(secndSpX,dialogBgHeight-460)
            self.container:addChild(avoidSp,2)
            avoidSp:setScale(iconScale)
            
            local baseAvoid=tonumber(tankCfg[id].avoid)
            local avoidLb=GetTTFLabel(baseAvoid.."%",20)
            avoidLb:setAnchorPoint(ccp(0,0.5))
            avoidLb:setPosition(ccp(secndLbX,dialogBgHeight-460-14))
            self.container:addChild(avoidLb)
            
            self.avoidLbAdd=GetTTFLabel("+"..(tankInfo.evade-baseAvoid/100)*100 .. "%",20)
            self.avoidLbAdd:setAnchorPoint(ccp(0,0.5))
            self.avoidLbAdd:setPosition(ccp(secndLbX+avoidLb:getContentSize().width,dialogBgHeight-460-14))
            self.avoidLbAdd:setColor(G_ColorGreen)
            self.container:addChild(self.avoidLbAdd)
            
            local avoidNameLb=GetTTFLabelWrap(getlocal("sample_skill_name_102"),labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            avoidNameLb:setAnchorPoint(ccp(0,0.5))
            avoidNameLb:setPosition(ccp(secndLbX,dialogBgHeight-460+14))
            self.container:addChild(avoidNameLb)
            
        --坚韧    
            local decriticalSp = CCSprite:createWithSpriteFrameName("skill_04.png");
            decriticalSp:setAnchorPoint(ccp(0,0.5));
            decriticalSp:setPosition(secndSpX,dialogBgHeight-530)
            self.container:addChild(decriticalSp,2)
            decriticalSp:setScale(iconScale)
            
            local baseDecritical=tonumber(tankCfg[id].decritical)
            local decriticalLb=GetTTFLabel(baseDecritical.."%",20)
            decriticalLb:setAnchorPoint(ccp(0,0.5))
            decriticalLb:setPosition(ccp(secndLbX,dialogBgHeight-530-14))
            self.container:addChild(decriticalLb)
            
            self.decriticalLbAdd=GetTTFLabel("+"..(tankInfo.anticrit-baseDecritical/100)*100 .. "%",20)
            self.decriticalLbAdd:setAnchorPoint(ccp(0,0.5))
            self.decriticalLbAdd:setPosition(ccp(secndLbX+decriticalLb:getContentSize().width,dialogBgHeight-530-14))
            self.decriticalLbAdd:setColor(G_ColorGreen)
            self.container:addChild(self.decriticalLbAdd)
            
            local decriticalNameLb=GetTTFLabelWrap(getlocal("sample_skill_name_104"),labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            decriticalNameLb:setAnchorPoint(ccp(0,0.5))
            decriticalNameLb:setPosition(ccp(secndLbX,dialogBgHeight-530+14))
            self.container:addChild(decriticalNameLb)

        --配件开关
            if base.ifAccessoryOpen==1 then
                --击破  
                local penetrateSp = CCSprite:createWithSpriteFrameName("attributeARP.png");
                penetrateSp:setAnchorPoint(ccp(0,0.5));
                penetrateSp:setPosition(firstSpX,dialogBgHeight-600)
                self.container:addChild(penetrateSp,2)
                penetrateSp:setScale(iconScale)
                
                self.penetrateLb=GetTTFLabel(tankInfo.arp or 0,20)
                self.penetrateLb:setAnchorPoint(ccp(0,0.5))
                self.penetrateLb:setPosition(ccp(firstLbX,dialogBgHeight-600-14))
                self.container:addChild(self.penetrateLb)
                self.penetrateLb:setColor(G_ColorGreen)

                local penetrateNameLb=GetTTFLabelWrap(getlocal("accessory_prop_name_1"),labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                penetrateNameLb:setAnchorPoint(ccp(0,0.5))
                penetrateNameLb:setPosition(ccp(firstLbX,dialogBgHeight-600+14))
                self.container:addChild(penetrateNameLb)

                --防护
                local armorSp = CCSprite:createWithSpriteFrameName("attributeArmor.png");
                armorSp:setAnchorPoint(ccp(0,0.5));
                armorSp:setPosition(secndSpX,dialogBgHeight-600)
                self.container:addChild(armorSp,2)
                armorSp:setScale(iconScale)
                
                self.armorLb=GetTTFLabel(tankInfo.armor or 0,20)
                self.armorLb:setAnchorPoint(ccp(0,0.5))
                self.armorLb:setPosition(ccp(secndLbX,dialogBgHeight-600-14))
                self.container:addChild(self.armorLb)
                self.armorLb:setColor(G_ColorGreen)
                
                local armorNameLb=GetTTFLabelWrap(getlocal("accessory_prop_name_2"),labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                armorNameLb:setAnchorPoint(ccp(0,0.5))
                armorNameLb:setPosition(ccp(secndLbX,dialogBgHeight-600+14))
                self.container:addChild(armorNameLb)
            end
            --异星科技
            if base.alien==1 and base.richMineOpen==1 then
                --暴击伤害增加 
                local critDmgSp = CCSprite:createWithSpriteFrameName("skill_110.png");
                critDmgSp:setAnchorPoint(ccp(0,0.5));
                critDmgSp:setPosition(firstSpX,dialogBgHeight-600-70)
                self.container:addChild(critDmgSp,2)
                critDmgSp:setScale(iconScale)
                
                self.critDmgLb=GetTTFLabel((tankInfo.critDmg*100 or 0).."%",20)
                self.critDmgLb:setAnchorPoint(ccp(0,0.5))
                self.critDmgLb:setPosition(ccp(firstLbX,dialogBgHeight-600-14-70))
                self.container:addChild(self.critDmgLb)
                self.critDmgLb:setColor(G_ColorGreen)

                local critDmgNameLb=GetTTFLabelWrap(getlocal("property_critDmg"),labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                -- local critDmgNameLb=GetTTFLabelWrap("啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊",labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                critDmgNameLb:setAnchorPoint(ccp(0,0.5))
                critDmgNameLb:setPosition(ccp(firstLbX,dialogBgHeight-600+14-70))
                self.container:addChild(critDmgNameLb)

                --暴击伤害减少
                local decritDmgSp = CCSprite:createWithSpriteFrameName("skill_111.png");
                decritDmgSp:setAnchorPoint(ccp(0,0.5));
                decritDmgSp:setPosition(secndSpX,dialogBgHeight-600-70)
                self.container:addChild(decritDmgSp,2)
                decritDmgSp:setScale(iconScale)
                
                self.decritDmgLb=GetTTFLabel((tankInfo.decritDmg*100 or 0).."%",20)
                self.decritDmgLb:setAnchorPoint(ccp(0,0.5))
                self.decritDmgLb:setPosition(ccp(secndLbX,dialogBgHeight-600-14-70))
                self.container:addChild(self.decritDmgLb)
                self.decritDmgLb:setColor(G_ColorGreen)
                
                local decritDmgNameLb=GetTTFLabelWrap(getlocal("property_decritDmg"),labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                -- local decritDmgNameLb=GetTTFLabelWrap("啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊",labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                decritDmgNameLb:setAnchorPoint(ccp(0,0.5))
                decritDmgNameLb:setPosition(ccp(secndLbX,dialogBgHeight-600+14-70))
                self.container:addChild(decritDmgNameLb)
            end

            local typeStr = "pro_ship_attacktype_"..tankCfg[id].attackNum
            if tonumber(tankCfg[id].weaponType) > 10 then
                -- print("tankCfg[id].weaponType...",tankCfg[id].weaponType)
                typeStr ="pro_ship_attacktype_"..tankCfg[id].weaponType
            end
            local attackTypeSp = CCSprite:createWithSpriteFrameName(typeStr..".png");
            attackTypeSp:setAnchorPoint(ccp(0,0.5));
            attackTypeSp:setPosition(secndSpX,dialogBgHeight-320)
            self.container:addChild(attackTypeSp,2)
            attackTypeSp:setScale(iconScale)
            
            -- if abilityCfg[tankCfg[id].abilityID]~=nil then
            --     local nameS=abilityCfg[tankCfg[id].abilityID][tonumber(tankCfg[id].abilityLv)].icon
            --     local attackTypeSp = CCSprite:createWithSpriteFrameName(nameS);
            --     attackTypeSp:setAnchorPoint(ccp(0,0.5));
            --     attackTypeSp:setPosition(secndSpX,dialogBgHeight-390)
            --     self.container:addChild(attackTypeSp,2)
            --     attackTypeSp:setScale(iconScale)
                
            --     local nameN=abilityCfg[tankCfg[id].abilityID][tonumber(tankCfg[id].abilityLv)].name
            --     local attackTypeLb=GetTTFLabelWrap(getlocal(nameN),20,CCSizeMake(24*8,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)--第二列第二行增加宽度限制
            --     attackTypeLb:setAnchorPoint(ccp(0,0.5))
            --     attackTypeLb:setPosition(ccp(secndLbX,dialogBgHeight-390))
            --     self.container:addChild(attackTypeLb)

            -- end
            

            local attTypeLb=GetTTFLabelWrap(getlocal(typeStr),labelSize,CCSizeMake(160,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            attTypeLb:setAnchorPoint(ccp(0,0.5))
            attTypeLb:setPosition(ccp(secndLbX,dialogBgHeight-320))
            self.container:addChild(attTypeLb)

            
            local lineSp1 = CCSprite:createWithSpriteFrameName("LineEntity.png");
            lineSp1:setAnchorPoint(ccp(0.5,0.5));
            lineSp1:setPosition(cellWidth/2,dialogBgHeight-275)
            self.container:addChild(lineSp1,2)
            lineSp1:setScaleX((cellWidth-50)/lineSp1:getContentSize().width)
            lineSp1:setScaleY(2)
            
            local lineSp2 = CCSprite:createWithSpriteFrameName("LineEntity.png");
            lineSp2:setAnchorPoint(ccp(0.5,0.5));
            lineSp2:setPosition(cellWidth/2,dialogBgHeight-423)
            self.container:addChild(lineSp2,2)
            lineSp2:setScaleX((cellWidth-50)/lineSp2:getContentSize().width)
            lineSp2:setScaleY(2)
    
            return cell
        elseif fn=="ccTouchBegan" then
            self.isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            self.isMoved=true
        elseif fn=="ccTouchEnded"  then

        end
    end
    local hd= LuaEventHandler:createHandler(tvCallBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,bgHeight-60),nil)
    self.tv:setTableViewTouchPriority(-(layerNum-1)*20-3)
    self.tv:setPosition(ccp(0,30))
    dialogBg:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)   
    



    self.bgLayer:setPosition(getCenterPoint(sceneGame))
    sceneGame:addChild(self.bgLayer,layerNum+1)
    self:show()
end

--显示面板,加效果
function ltzdzTankInfoDialog:show()

    --if self.isUseAmi~=nil then
       local moveTo=CCMoveTo:create(0.3,CCPointMake(G_VisibleSize.width/2,G_VisibleSize.height/2))
       
       local scaleTo1=CCScaleTo:create(0.1, 1.1);
       local scaleTo2=CCScaleTo:create(0.07, 1);

       local acArr=CCArray:create()
       acArr:addObject(scaleTo1)
       acArr:addObject(scaleTo2)
       -- acArr:addObject(callFunc)
        
       local seq=CCSequence:create(acArr)
       self.bgLayer:runAction(seq)
   --end
   table.insert(G_SmallDialogDialogTb,self)   
   
end

function ltzdzTankInfoDialog:close()

    if self.isUseAmi~=nil then
    local function realClose()
    self.touchDialogBg:removeFromParentAndCleanup(true)
        return self:realClose()
    end
   local fc= CCCallFunc:create(realClose)
    local scaleTo1=CCScaleTo:create(0.1, 1.1);
   local scaleTo2=CCScaleTo:create(0.07, 0.8);

   local acArr=CCArray:create()
   acArr:addObject(scaleTo1)
   acArr:addObject(scaleTo2)
   acArr:addObject(fc)
    
   local seq=CCSequence:create(acArr)
   self.bgLayer:runAction(seq)
   else
        self:realClose()

   end
    for k,v in pairs(G_SmallDialogDialogTb) do
        if v==self then
            v=nil
            G_SmallDialogDialogTb[k]=nil
        end
    end
   
   
end
function ltzdzTankInfoDialog:realClose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil

end
function ltzdzTankInfoDialog:tick()

    
end

function ltzdzTankInfoDialog:dispose() --释放方法
    spriteController:removePlist("public/acAnniversary.plist")
    spriteController:removeTexture("public/acAnniversary.png")
 self.touchDialogBg=nil
    self.bgLayer=nil
    for k,v in pairs(self.pp4) do
         k=nil
         v=nil
    end

    self.have4=nil
    self.id=nil
    self.attLbAdd=nil
    self.lifeLbAdd=nil
    self.penetrateLb=nil
    self.armorLb=nil
    self.accurateLbAdd=nil
    self.criticalLbAdd=nil
    self.avoidLbAdd=nil
    self.decriticalLbAdd=nil
    self.critDmgLb=nil
    self.decritDmgLb=nil
end
