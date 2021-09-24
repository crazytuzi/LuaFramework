tankInfoEnhanceDialog={}
function tankInfoEnhanceDialog:new()
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

            titleStr,
            selectedTabIndex=0,  --当前选中的tab
            oldSelectedTabIndex=0,--上一次选中的tab
            allTabs={},

          }
    setmetatable(nc,self)
    self.__index=self
    return nc
end
--container:父容器 category:build,skill等 id:ID type:type
function tankInfoEnhanceDialog:create(container,id,layerNum,hideNum,titleStr)
    local td=self:new()
    self.titleStr = titleStr
    self.id=id
    td:init(container,id,layerNum,hideNum)
    self.isUseAmi=true

end


function tankInfoEnhanceDialog:init(parent,id,layerNum,hideNum)
    if newGuidMgr:isNewGuiding()==true then
        do
            return
        end
    end
    table.insert(G_SmallDialogDialogTb,self)
    
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


    local lbSize = CCSize(450, 0);
    
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
    local abilityID=tankCfg[id].abilityID
    local abilityLv=tankCfg[id].abilityLv
    local skillName=""
    local skillDesc=""
    local skillIcon=nil

    --异星科技增加技能点数
    if base.alien==1 and base.richMineOpen==1 then
        if alienTechVoApi.getAlienAddSkill then
            local abilityIDAlien,abilityLvAlienAdd=alienTechVoApi:getAlienAddSkill(id)
            if abilityID==nil or abilityID=="" then
                if abilityIDAlien and abilityIDAlien~="" then
                    abilityID=abilityIDAlien
                end
            end
            if abilityLvAlienAdd and abilityLvAlienAdd>0 then
                abilityLv=abilityLvAlienAdd
            end
        end
        bgHeight=bgHeight+80
        tvHeight=tvHeight+80
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

        local skillDescLb1=GetTTFLabelWrap(skillDesc,textSizeD,lbSize,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        skillHeight=90+skillDescLb1:getContentSize().height

        isHasAbility=true
        bgHeight=bgHeight+skillHeight
        tvHeight=tvHeight+skillHeight
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

            local titleLabel = GetTTFLabel(self.titleStr, 32, true)
            titleLabel:setPosition(ccp(cellWidth/2,dialogBgHeight-50))
            titleLabel:setColor(G_ColorYellowPro)
            self.container:addChild(titleLabel,2)

            local spriteIcon = tankVoApi:getTankIconSp(id)
            spriteIcon:setAnchorPoint(ccp(0,0.5));
            spriteIcon:setScale(0.7)
            spriteIcon:setPosition(30,dialogBgHeight-140)
            self.container:addChild(spriteIcon,2)
            
            local lbName=GetTTFLabelWrap(getlocal(tankCfg[id].name),24,CCSizeMake(320,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
           lbName:setPosition(160,dialogBgHeight-120)
           lbName:setAnchorPoint(ccp(0,0.5));
           self.container:addChild(lbName,2)
           
            if hideNum == false or hideNum == nil then
               local lbNum=GetTTFLabel(getlocal("schedule_ship_num",{tankVoApi:getTankCountByItemId(id)}),20)
               lbNum:setPosition(160,dialogBgHeight-160)
               lbNum:setAnchorPoint(ccp(0,0.5));
               self.container:addChild(lbNum,2)
            end


            -- local lbDescription=GetTTFLabelWrap(getlocal(tankCfg[id].description),textSizeD,lbSize,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            -- lbDescription:setPosition(30,dialogBgHeight-200)
            -- lbDescription:setAnchorPoint(ccp(0,0.5))
            -- self.container:addChild(lbDescription,2)

            local function touchItem(idx)
                self.oldSelectedTabIndex=self.selectedTabIndex
                self:tabClickColor(idx)
                return self:tabClick(idx)
            end
            local titleItem1=CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
            titleItem1:setScale(0.8)
            self.allTabs[1]=titleItem1
            titleItem1:setTag(1)
            titleItem1:registerScriptTapHandler(touchItem)
            titleItem1:setEnabled(false)
            local tabMenu1=CCMenu:createWithItem(titleItem1)
            tabMenu1:setPosition(ccp(20+titleItem1:getContentSize().width/2*0.8,dialogBgHeight-257))
            tabMenu1:setTouchPriority(-(layerNum-1)*20-3)
            self.container:addChild(tabMenu1,2)
            self.titleItem1=titleItem1

            local titleLb1 = GetTTFLabel(getlocal("alien_tech_item_tab1"),24,true)
            titleItem1:addChild(titleLb1)
            titleLb1:setPosition(ccp(titleItem1:getContentSize().width/2,titleItem1:getContentSize().height/2))

            self.isSpecial = tankCfg[id].isSpecial
            if self.isSpecial==0 then
                local titleItem2=CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
                titleItem2:setScale(0.8)
                titleItem2:setTag(2)
                titleItem2:registerScriptTapHandler(touchItem)
                self.allTabs[2]=titleItem2
                local tabMenu2=CCMenu:createWithItem(titleItem2)
                tabMenu2:setPosition(ccp(20+titleItem2:getContentSize().width/2*3*0.8,dialogBgHeight-257))
                tabMenu2:setTouchPriority(-(layerNum-1)*20-3)
                self.container:addChild(tabMenu2,2)
                self.titleItem2=titleItem2

                local titleLb2 = GetTTFLabel(getlocal("alien_tech_item_tab2"),24,true)
                titleItem2:addChild(titleLb2)
                titleLb2:setPosition(ccp(titleItem2:getContentSize().width/2,titleItem2:getContentSize().height/2))
            end

            local function click()
            end
            self.bgSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),click)
            self.bgSprie:setContentSize(CCSizeMake(cellWidth-40,cellHeight-253))
            self.bgSprie:setAnchorPoint(ccp(0,0))
            self.bgSprie:setPosition(ccp(20,0))
            self.container:addChild(self.bgSprie)

            -- 页签2
            if self.isSpecial==0 then
                local wd1=220
                local wd2 = 360
                local ht = dialogBgHeight-300
                local addH = 11
                local typeLb=GetTTFLabel(getlocal("resourceType"),20)
                typeLb:setAnchorPoint(ccp(0.5,0.5))
                typeLb:setPosition(ccp(wd1-130,ht))
                self.container:addChild(typeLb)
                typeLb:setVisible(false)
                self.typeLb = typeLb

                local resourceLb=GetTTFLabel(getlocal("resourceRequire"),20)
                resourceLb:setAnchorPoint(ccp(0.5,0.5))
                resourceLb:setPosition(ccp(wd1,ht))
                self.container:addChild(resourceLb)
                resourceLb:setVisible(false)
                self.resourceLb = resourceLb

                local ownLb=GetTTFLabel(getlocal("resourceOwned"),20)
                ownLb:setAnchorPoint(ccp(0.5,0.5))
                ownLb:setPosition(ccp(wd2,ht))
                self.container:addChild(ownLb)
                ownLb:setVisible(false)
                self.ownLb = ownLb

                local reR1,reR2,reR3,reR4,reUpgradedTime = tankVoApi:getProduceTankResources(id)
                local tb={
                    {titleStr="metal",spName="resourse_normal_metal.png",needStr=FormatNumber(reR1),haveStr=FormatNumber(playerVoApi:getR1()),num1=playerVoApi:getR1(),num2=tonumber(reR1)},
                    {titleStr="oil",spName="resourse_normal_oil.png",needStr=FormatNumber(reR2),haveStr=FormatNumber(playerVoApi:getR2()),num1=playerVoApi:getR2(),num2=tonumber(reR2)},
                    {titleStr="silicon",spName="resourse_normal_silicon.png",needStr=FormatNumber(reR3),haveStr=FormatNumber(playerVoApi:getR3()),num1=playerVoApi:getR3(),num2=tonumber(reR3)},
                    {titleStr="uranium",spName="resourse_normal_uranium.png",needStr=FormatNumber(reR4),haveStr=FormatNumber(playerVoApi:getR4()),num1=playerVoApi:getR4(),num2=tonumber(reR4)},
                }

                for k,v in pairs(tb) do
                    local r1Sp=CCSprite:createWithSpriteFrameName(v.spName)
                    r1Sp:setAnchorPoint(ccp(0.5,0.5))
                    r1Sp:setPosition(ccp(wd1-130,ht-50+addH-(k-1)*60))
                    self.container:addChild(r1Sp)
                    r1Sp:setScale(0.5)
                    self["r".. k .. "Sp"] = r1Sp
                    self["r".. k .. "Sp"]:setVisible(false)

                    local needR1Lb=GetTTFLabel(v.needStr,20)
                    needR1Lb:setAnchorPoint(ccp(0.5,0.5))
                    needR1Lb:setPosition(ccp(wd1,ht-50+addH-(k-1)*60))
                    self.container:addChild(needR1Lb)
                    self["needR".. k .. "Lb"] = needR1Lb
                    self["needR".. k .. "Lb"]:setVisible(false)

                    local haveR1Lb=GetTTFLabel(v.haveStr,20)
                    haveR1Lb:setAnchorPoint(ccp(0.5,0.5))
                    haveR1Lb:setPosition(ccp(wd2,ht-50+addH-(k-1)*60))
                    self.container:addChild(haveR1Lb)
                    self["haveR".. k .. "Lb"] = haveR1Lb
                    self["haveR".. k .. "Lb"]:setVisible(false)

                end

                self.bgSprie1=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),click)
                self.bgSprie1:setContentSize(CCSizeMake(170,80))
                self.bgSprie1:setScaleY(0.8)
                self.bgSprie1:setAnchorPoint(ccp(0,0))
                self.bgSprie1:setPosition(ccp(cellWidth-220,dialogBgHeight-610))
                self.bgSprie1:setVisible(false)
                self.container:addChild(self.bgSprie1)

                local timeSp = CCSprite:createWithSpriteFrameName("IconTime.png");
                timeSp:setAnchorPoint(ccp(0,0.5));
                timeSp:setPosition(300,dialogBgHeight-580)
                self.container:addChild(timeSp,2)
                timeSp:setVisible(false)
                self.timeSp=timeSp


                local alienTechSpeedUp=0
                if id and base.alien==1 and alienTechVoApi and alienTechVoApi.getProduceSpeedUpTb then
                    local speedUpTb=alienTechVoApi:getProduceSpeedUpTb()
                    local techId=speedUpTb["a"..id]
                    local tLevel=alienTechVoApi:getTechLevel(techId) or 0
                    if alienTechCfg and alienTechCfg.talent and alienTechCfg.talent[techId] and alienTechCfg.talent[techId][alienTechCfg.keyCfg.value] and techId and tLevel>0 then
                        local valueTb=alienTechCfg.talent[techId][alienTechCfg.keyCfg.value]
                        if valueTb[tLevel] and valueTb[tLevel][200] then
                            alienTechSpeedUp=valueTb[tLevel][200] or 0
                        end
                    end
                end
                local timeConsume=tonumber(tankCfg[id].timeConsume)-alienTechSpeedUp
                local lbTime=GetTTFLabel(GetTimeStr(timeConsume),20)
                lbTime:setPosition(350,dialogBgHeight-575-3)
                lbTime:setAnchorPoint(ccp(0,0.5));
                lbTime:setVisible(false)
                self.container:addChild(lbTime,2)
                self.lbTime = lbTime
            end




                -- 页签1
            -- if not titleItem1:isEnabled() then 
            local firstSpX = 50
            local firstLbX = 110
            
            local secndSpX = 230+30
            local secndLbX = 290+30

            local labelSize = 18
            local labelWidth = 140
            self.isHasAbility=isHasAbility
            self.skillIcon=skillIcon        
            if isHasAbility==true and skillIcon then
                local lineSp3 = CCSprite:createWithSpriteFrameName("LineEntity.png");
                lineSp3:setAnchorPoint(ccp(0.5,0.5));
                lineSp3:setPosition(cellWidth/2,dialogBgHeight-275)
                self.container:addChild(lineSp3,2)
                lineSp3:setScaleX((cellWidth-50)/lineSp3:getContentSize().width)
                lineSp3:setScaleY(2)
                self.lineSp3=lineSp3

                skillIcon:setAnchorPoint(ccp(0,0.5));
                skillIcon:setPosition(firstSpX,dialogBgHeight-315)
                self.container:addChild(skillIcon,2)
                skillIcon:setScale(50/skillIcon:getContentSize().width)
                self.skillIcon=skillIcon

                local skillNameLb=GetTTFLabel(skillName,20)
                skillNameLb:setAnchorPoint(ccp(0,0.5))
                skillNameLb:setPosition(ccp(firstLbX,dialogBgHeight-315))
                self.container:addChild(skillNameLb)
                self.skillNameLb=skillNameLb

                local skillLvLb=GetTTFLabel(getlocal("fightLevel",{abilityLv}),20)
                skillLvLb:setAnchorPoint(ccp(0,0.5))
                skillLvLb:setPosition(ccp(firstLbX+skillNameLb:getContentSize().width+25,dialogBgHeight-315))
                self.container:addChild(skillLvLb)
                skillLvLb:setColor(G_ColorYellowPro)
                self.skillLvLb=skillLvLb

                local skillDescLb=GetTTFLabelWrap(skillDesc,textSizeD,lbSize,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                skillDescLb:setAnchorPoint(ccp(0,1))
                skillDescLb:setPosition(30,dialogBgHeight-350)
                self.container:addChild(skillDescLb,2)
                self.skillDescLb=skillDescLb



                dialogBgHeight=dialogBgHeight-skillHeight
            end

            
            local attack,life,accurate,avoid,critical,decritical,armor,penetrate,critDmg,decritDmg,baseAttackAdd,baseLifeAdd=tankVoApi:getTankAddProperty(id);
            local baseAttack=tonumber(tankCfg[id].attack)+baseAttackAdd
            local baseLife=tonumber(tankCfg[id].life)+baseLifeAdd

        --攻击    
            local attackSp = CCSprite:createWithSpriteFrameName("pro_ship_attack.png");
            local iconScale= 50/attackSp:getContentSize().width
            attackSp:setAnchorPoint(ccp(0,0.5));
            attackSp:setPosition(firstSpX,dialogBgHeight-320)
            self.container:addChild(attackSp,2)
            attackSp:setScale(iconScale)
            self.attackSp=attackSp
            
            local attLb=GetTTFLabel(baseAttack,20)
            attLb:setAnchorPoint(ccp(0,0.5))
            attLb:setPosition(ccp(firstLbX,dialogBgHeight-320-14))
            self.container:addChild(attLb)
            self.attLb=attLb
            
            self.attLbAdd=GetTTFLabel("+"..(attack),20)
            self.attLbAdd:setAnchorPoint(ccp(0,0.5))
            self.attLbAdd:setPosition(ccp(firstLbX+attLb:getContentSize().width,dialogBgHeight-320-14))
            self.attLbAdd:setColor(G_ColorGreen)
            self.container:addChild(self.attLbAdd)

            
            local attNameLb=GetTTFLabelWrap(getlocal("tankAtk"),labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            attNameLb:setAnchorPoint(ccp(0,0.5))
            attNameLb:setPosition(ccp(firstLbX,dialogBgHeight-320+14))
            self.container:addChild(attNameLb)
            self.attNameLb=attNameLb
        --血量
            local lifeSp = CCSprite:createWithSpriteFrameName("pro_ship_life.png");
            lifeSp:setAnchorPoint(ccp(0,0.5));
            lifeSp:setPosition(firstSpX,dialogBgHeight-390)
            self.container:addChild(lifeSp,2)
            lifeSp:setScale(iconScale)
            self.lifeSp=lifeSp
            
            local lifeLb=GetTTFLabel(baseLife,20)
            lifeLb:setAnchorPoint(ccp(0,0.5))
            lifeLb:setPosition(ccp(firstLbX,dialogBgHeight-390-14))
            self.container:addChild(lifeLb)
            self.lifeLb=lifeLb
            
            self.lifeLbAdd=GetTTFLabel("+"..(life),20)
            self.lifeLbAdd:setAnchorPoint(ccp(0,0.5))
            self.lifeLbAdd:setPosition(ccp(firstLbX+lifeLb:getContentSize().width,dialogBgHeight-390-14))
            self.lifeLbAdd:setColor(G_ColorGreen)
            self.container:addChild(self.lifeLbAdd)
            
            local lifeNameLb=GetTTFLabelWrap(getlocal("tankBlood"),labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            lifeNameLb:setAnchorPoint(ccp(0,0.5))
            lifeNameLb:setPosition(ccp(firstLbX,dialogBgHeight-390+14))
            self.container:addChild(lifeNameLb)
            self.lifeNameLb=lifeNameLb
            

        --精准    
            local accurateSp = CCSprite:createWithSpriteFrameName("skill_01.png");
            accurateSp:setAnchorPoint(ccp(0,0.5));
            accurateSp:setPosition(firstSpX,dialogBgHeight-460)
            self.container:addChild(accurateSp,2)
            accurateSp:setScale(iconScale)
            self.accurateSp=accurateSp
            
            local accurateLb=GetTTFLabel(tankCfg[id].accurate.."%",20)
            accurateLb:setAnchorPoint(ccp(0,0.5))
            accurateLb:setPosition(ccp(firstLbX,dialogBgHeight-474))
            self.container:addChild(accurateLb)
            self.accurateLb=accurateLb
            
            self.accurateLbAdd=GetTTFLabel("+"..accurate.."%",20)
            self.accurateLbAdd:setAnchorPoint(ccp(0,0.5))
            self.accurateLbAdd:setPosition(ccp(firstLbX+accurateLb:getContentSize().width,dialogBgHeight-474))
            self.accurateLbAdd:setColor(G_ColorGreen)
            self.container:addChild(self.accurateLbAdd)

            local accurateNameLb=GetTTFLabelWrap(getlocal("sample_skill_name_101"),labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            accurateNameLb:setAnchorPoint(ccp(0,0.5))
            accurateNameLb:setPosition(ccp(firstLbX,dialogBgHeight-446))
            self.container:addChild(accurateNameLb)
            self.accurateNameLb=accurateNameLb

        --暴击    
            local criticalSp = CCSprite:createWithSpriteFrameName("skill_03.png");
            criticalSp:setAnchorPoint(ccp(0,0.5));
            criticalSp:setPosition(firstSpX,dialogBgHeight-530)
            self.container:addChild(criticalSp,2)
            criticalSp:setScale(iconScale)
            self.criticalSp=criticalSp
            
            local criticalLb=GetTTFLabel(tankCfg[id].critical.."%",20)
            criticalLb:setAnchorPoint(ccp(0,0.5))
            criticalLb:setPosition(ccp(firstLbX,dialogBgHeight-530-14))
            self.container:addChild(criticalLb)
            self.criticalLb=criticalLb
            
            self.criticalLbAdd=GetTTFLabel("+"..critical.."%",20)
            self.criticalLbAdd:setAnchorPoint(ccp(0,0.5))
            self.criticalLbAdd:setPosition(ccp(firstLbX+criticalLb:getContentSize().width,dialogBgHeight-530-14))
            self.criticalLbAdd:setColor(G_ColorGreen)
            self.container:addChild(self.criticalLbAdd)
            
            local criticalNameLb=GetTTFLabelWrap(getlocal("sample_skill_name_103"),labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            criticalNameLb:setAnchorPoint(ccp(0,0.5))
            criticalNameLb:setPosition(ccp(firstLbX,dialogBgHeight-530+14))
            self.container:addChild(criticalNameLb)
            self.criticalNameLb=criticalNameLb
            
        --闪避    
            local avoidSp = CCSprite:createWithSpriteFrameName("skill_02.png");
            avoidSp:setAnchorPoint(ccp(0,0.5));
            avoidSp:setPosition(secndSpX,dialogBgHeight-460)
            self.container:addChild(avoidSp,2)
            avoidSp:setScale(iconScale)
            self.avoidSp=avoidSp
            
            local avoidLb=GetTTFLabel(tankCfg[id].avoid.."%",20)
            avoidLb:setAnchorPoint(ccp(0,0.5))
            avoidLb:setPosition(ccp(secndLbX,dialogBgHeight-460-14))
            self.container:addChild(avoidLb)
            self.avoidLb=avoidLb
            
            self.avoidLbAdd=GetTTFLabel("+"..avoid.."%",20)
            self.avoidLbAdd:setAnchorPoint(ccp(0,0.5))
            self.avoidLbAdd:setPosition(ccp(secndLbX+avoidLb:getContentSize().width,dialogBgHeight-460-14))
            self.avoidLbAdd:setColor(G_ColorGreen)
            self.container:addChild(self.avoidLbAdd)
            
            local avoidNameLb=GetTTFLabelWrap(getlocal("sample_skill_name_102"),labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            avoidNameLb:setAnchorPoint(ccp(0,0.5))
            avoidNameLb:setPosition(ccp(secndLbX,dialogBgHeight-460+14))
            self.container:addChild(avoidNameLb)
            self.avoidNameLb=avoidNameLb
            
        --坚韧    
            local decriticalSp = CCSprite:createWithSpriteFrameName("skill_04.png");
            decriticalSp:setAnchorPoint(ccp(0,0.5));
            decriticalSp:setPosition(secndSpX,dialogBgHeight-530)
            self.container:addChild(decriticalSp,2)
            decriticalSp:setScale(iconScale)
            self.decriticalSp=decriticalSp
            
            local decriticalLb=GetTTFLabel(tankCfg[id].decritical.."%",20)
            decriticalLb:setAnchorPoint(ccp(0,0.5))
            decriticalLb:setPosition(ccp(secndLbX,dialogBgHeight-530-14))
            self.container:addChild(decriticalLb)
            self.decriticalLb=decriticalLb
            
            self.decriticalLbAdd=GetTTFLabel("+"..decritical.."%",20)
            self.decriticalLbAdd:setAnchorPoint(ccp(0,0.5))
            self.decriticalLbAdd:setPosition(ccp(secndLbX+decriticalLb:getContentSize().width,dialogBgHeight-530-14))
            self.decriticalLbAdd:setColor(G_ColorGreen)
            self.container:addChild(self.decriticalLbAdd)
            
            local decriticalNameLb=GetTTFLabelWrap(getlocal("sample_skill_name_104"),labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            decriticalNameLb:setAnchorPoint(ccp(0,0.5))
            decriticalNameLb:setPosition(ccp(secndLbX,dialogBgHeight-530+14))
            self.container:addChild(decriticalNameLb)
            self.decriticalNameLb=decriticalNameLb

        --配件开关
            if base.ifAccessoryOpen==1 then
                --击破  
                local penetrateSp = CCSprite:createWithSpriteFrameName("attributeARP.png");
                penetrateSp:setAnchorPoint(ccp(0,0.5));
                penetrateSp:setPosition(firstSpX,dialogBgHeight-600)
                self.container:addChild(penetrateSp,2)
                penetrateSp:setScale(iconScale)
                self.penetrateSp=penetrateSp
                
                self.penetrateLb=GetTTFLabel(penetrate,20)
                self.penetrateLb:setAnchorPoint(ccp(0,0.5))
                self.penetrateLb:setPosition(ccp(firstLbX,dialogBgHeight-600-14))
                self.container:addChild(self.penetrateLb)
                self.penetrateLb:setColor(G_ColorGreen)

                local penetrateNameLb=GetTTFLabelWrap(getlocal("accessory_prop_name_1"),labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                penetrateNameLb:setAnchorPoint(ccp(0,0.5))
                penetrateNameLb:setPosition(ccp(firstLbX,dialogBgHeight-600+14))
                self.container:addChild(penetrateNameLb)
                self.penetrateNameLb=penetrateNameLb

                --防护
                local armorSp = CCSprite:createWithSpriteFrameName("attributeArmor.png");
                armorSp:setAnchorPoint(ccp(0,0.5));
                armorSp:setPosition(secndSpX,dialogBgHeight-600)
                self.container:addChild(armorSp,2)
                armorSp:setScale(iconScale)
                self.armorSp=armorSp
                
                self.armorLb=GetTTFLabel(armor,20)
                self.armorLb:setAnchorPoint(ccp(0,0.5))
                self.armorLb:setPosition(ccp(secndLbX,dialogBgHeight-600-14))
                self.container:addChild(self.armorLb)
                self.armorLb:setColor(G_ColorGreen)
                
                local armorNameLb=GetTTFLabelWrap(getlocal("accessory_prop_name_2"),labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                armorNameLb:setAnchorPoint(ccp(0,0.5))
                armorNameLb:setPosition(ccp(secndLbX,dialogBgHeight-600+14))
                self.container:addChild(armorNameLb)
                self.armorNameLb=armorNameLb
            end

            --异星科技
            if base.alien==1 and base.richMineOpen==1 then
                --暴击伤害增加 
                local critDmgSp = CCSprite:createWithSpriteFrameName("skill_110.png");
                critDmgSp:setAnchorPoint(ccp(0,0.5));
                critDmgSp:setPosition(firstSpX,dialogBgHeight-600-70)
                self.container:addChild(critDmgSp,2)
                critDmgSp:setScale(iconScale)
                self.critDmgSp=critDmgSp
                
                self.critDmgLb=GetTTFLabel(critDmg.."%",20)
                self.critDmgLb:setAnchorPoint(ccp(0,0.5))
                self.critDmgLb:setPosition(ccp(firstLbX,dialogBgHeight-600-14-70))
                self.container:addChild(self.critDmgLb)
                self.critDmgLb:setColor(G_ColorGreen)

                local critDmgNameLb=GetTTFLabelWrap(getlocal("property_critDmg"),labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                -- local critDmgNameLb=GetTTFLabelWrap("啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊",labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                critDmgNameLb:setAnchorPoint(ccp(0,0.5))
                critDmgNameLb:setPosition(ccp(firstLbX,dialogBgHeight-600+14-70))
                self.container:addChild(critDmgNameLb)
                self.critDmgNameLb=critDmgNameLb

                --暴击伤害减少
                local decritDmgSp = CCSprite:createWithSpriteFrameName("skill_111.png");
                decritDmgSp:setAnchorPoint(ccp(0,0.5));
                decritDmgSp:setPosition(secndSpX,dialogBgHeight-600-70)
                self.container:addChild(decritDmgSp,2)
                decritDmgSp:setScale(iconScale)
                self.decritDmgSp=decritDmgSp
                
                self.decritDmgLb=GetTTFLabel(decritDmg.."%",20)
                self.decritDmgLb:setAnchorPoint(ccp(0,0.5))
                self.decritDmgLb:setPosition(ccp(secndLbX,dialogBgHeight-600-14-70))
                self.container:addChild(self.decritDmgLb)
                self.decritDmgLb:setColor(G_ColorGreen)
                
                local decritDmgNameLb=GetTTFLabelWrap(getlocal("property_decritDmg"),labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                -- local decritDmgNameLb=GetTTFLabelWrap("啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊",labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                decritDmgNameLb:setAnchorPoint(ccp(0,0.5))
                decritDmgNameLb:setPosition(ccp(secndLbX,dialogBgHeight-600+14-70))
                self.container:addChild(decritDmgNameLb)
                self.decritDmgNameLb=decritDmgNameLb
            end


            local typeStr = "pro_ship_attacktype_"..tankCfg[id].attackNum

            local attackTypeSp = CCSprite:createWithSpriteFrameName(typeStr..".png");
            attackTypeSp:setAnchorPoint(ccp(0,0.5));
            attackTypeSp:setPosition(secndSpX,dialogBgHeight-320)
            self.container:addChild(attackTypeSp,2)
            attackTypeSp:setScale(iconScale)
            self.attackTypeSp=attackTypeSp
            
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
            

            local attTypeLb=GetTTFLabelWrap(getlocal(typeStr),20,CCSizeMake(24*8,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            attTypeLb:setAnchorPoint(ccp(0,0.5))
            attTypeLb:setPosition(ccp(secndLbX,dialogBgHeight-320))
            self.container:addChild(attTypeLb)
            self.attTypeLb=attTypeLb

            
            local lineSp1 = CCSprite:createWithSpriteFrameName("LineEntity.png");
            lineSp1:setAnchorPoint(ccp(0.5,0.5));
            lineSp1:setPosition(cellWidth/2,dialogBgHeight-275)
            self.container:addChild(lineSp1,2)
            lineSp1:setScaleX((cellWidth-50)/lineSp1:getContentSize().width)
            lineSp1:setScaleY(2)
            self.lineSp1=lineSp1
            
            local lineSp2 = CCSprite:createWithSpriteFrameName("LineEntity.png");
            lineSp2:setAnchorPoint(ccp(0.5,0.5));
            lineSp2:setPosition(cellWidth/2,dialogBgHeight-423)
            self.container:addChild(lineSp2,2)
            lineSp2:setScaleX((cellWidth-50)/lineSp2:getContentSize().width)
            lineSp2:setScaleY(2)
            self.lineSp2=lineSp2
            -- end

            return cell
        elseif fn=="ccTouchBegan" then
            isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            isMoved=true
        elseif fn=="ccTouchEnded"  then

        end
    end
    local hd= LuaEventHandler:createHandler(tvCallBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(layerNum-1)*20-3)
    self.tv:setPosition(ccp(0,30))
    dialogBg:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)
    



    self.bgLayer:setPosition(getCenterPoint(sceneGame))
    sceneGame:addChild(self.bgLayer,layerNum+1)
    self:show()

end

function tankInfoEnhanceDialog:refresh()

end


--显示面板,加效果
function tankInfoEnhanceDialog:show()

    --if self.isUseAmi~=nil then
       local moveTo=CCMoveTo:create(0.3,CCPointMake(G_VisibleSize.width/2,G_VisibleSize.height/2))
       local function callBack()
        
            if base.ifAccessoryOpen==1 and accessoryVoApi.dataNeedRefresh==true then
                --没有装备数据
                local function onRequestEnd(fn,data)
                    if self==nil then
                        do
                            return
                        end
                    end
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                        if sData and sData.data and sData.data.accessory then
                            accessoryVoApi:onRefreshData(sData.data.accessory)
                            if self and self.id then
                                local attack,life,accurate,avoid,critical,decritical,armor,penetrate,critDmg,decritDmg,baseAttackAdd,baseLifeAdd=tankVoApi:getTankAddProperty(self.id)
                                if self.attLbAdd then
                                    self.attLbAdd=tolua.cast(self.attLbAdd,"CCLabelTTF")
                                    if self.attLbAdd then
                                        self.attLbAdd:setString("+"..(attack))
                                    end
                                end
                                if self.lifeLbAdd then
                                    self.lifeLbAdd=tolua.cast(self.lifeLbAdd,"CCLabelTTF")
                                    if self.lifeLbAdd then
                                        self.lifeLbAdd:setString("+"..(life))
                                    end
                                end
                                if self.penetrateLb then
                                    self.penetrateLb=tolua.cast(self.penetrateLb,"CCLabelTTF")
                                    if self.penetrateLb then
                                        self.penetrateLb:setString(penetrate)
                                    end
                                end
                                if self.armorLb then
                                    self.armorLb=tolua.cast(self.armorLb,"CCLabelTTF")
                                    if self.armorLb then
                                        self.armorLb:setString(armor)
                                    end
                                end
                            end
                        end
                        self:updateAddAttNum()
                    end
                end
                socketHelper:getAllAccesory(onRequestEnd,false)
            else
                self:updateAddAttNum()
            end
            base:cancleWait()
       end
       local callFunc=CCCallFunc:create(callBack)
       
       local scaleTo1=CCScaleTo:create(0.1, 1.1);
       local scaleTo2=CCScaleTo:create(0.07, 1);

       local acArr=CCArray:create()
       acArr:addObject(scaleTo1)
       acArr:addObject(scaleTo2)
       acArr:addObject(callFunc)
        
       local seq=CCSequence:create(acArr)
       self.bgLayer:runAction(seq)
   --end
   
   
end


--关卡科技加成数据更新
function tankInfoEnhanceDialog:updateAddAttNum()
    local techFlag=checkPointVoApi:getTechFlag()
    if techFlag==-1 then
        local function challengeRewardlistCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                self:refreshAddAttNum()
                checkPointVoApi:setTechFlag(1)
            end
        end
        socketHelper:challengeRewardlist(challengeRewardlistCallback)
    else
        self:refreshAddAttNum()
    end
end

--更新坦克属性加成
function tankInfoEnhanceDialog:refreshAddAttNum()
    if self and self.id then
        local attack,life,accurate,avoid,critical,decritical,armor,penetrate,critDmg,decritDmg,baseAttackAdd,baseLifeAdd=tankVoApi:getTankAddProperty(self.id)
        if self.attLbAdd then
            self.attLbAdd=tolua.cast(self.attLbAdd,"CCLabelTTF")
            if self.attLbAdd then
                self.attLbAdd:setString("+"..(attack))
            end
        end
        if self.lifeLbAdd then
            self.lifeLbAdd=tolua.cast(self.lifeLbAdd,"CCLabelTTF")
            if self.lifeLbAdd then
                self.lifeLbAdd:setString("+"..(life))
            end
        end
        if self.accurateLbAdd then
            self.accurateLbAdd=tolua.cast(self.accurateLbAdd,"CCLabelTTF")
            if self.accurateLbAdd then
                self.accurateLbAdd:setString("+"..accurate.."%")
            end
        end
        if self.criticalLbAdd then
            self.criticalLbAdd=tolua.cast(self.criticalLbAdd,"CCLabelTTF")
            if self.criticalLbAdd then
                self.criticalLbAdd:setString("+"..critical.."%")
            end
        end
        if self.avoidLbAdd then
            self.avoidLbAdd=tolua.cast(self.avoidLbAdd,"CCLabelTTF")
            if self.avoidLbAdd then
                self.avoidLbAdd:setString("+"..avoid.."%")
            end
        end
        if self.decriticalLbAdd then
            self.decriticalLbAdd=tolua.cast(self.decriticalLbAdd,"CCLabelTTF")
            if self.decriticalLbAdd then
                self.decriticalLbAdd:setString("+"..decritical.."%")
            end
        end
        if self.penetrateLb then
            self.penetrateLb=tolua.cast(self.penetrateLb,"CCLabelTTF")
            if self.penetrateLb then
                self.penetrateLb:setString(penetrate)
            end
        end
        if self.armorLb then
            self.armorLb=tolua.cast(self.armorLb,"CCLabelTTF")
            if self.armorLb then
                self.armorLb:setString(armor)
            end
        end
    end
end



function tankInfoEnhanceDialog:close()

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
   
   
end
function tankInfoEnhanceDialog:realClose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    for k,v in pairs(G_SmallDialogDialogTb) do
        if v==self then
            v=nil
            G_SmallDialogDialogTb[k]=nil
        end
    end
end
function tankInfoEnhanceDialog:tick()
    if self.titleItem1:isEnabled() then
    end
    
end

function tankInfoEnhanceDialog:tabClickColor(idx)
    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            local tabBtnItem = v
            -- local tabBtnLabel=tolua.cast(tabBtnItem:getChildByTag(31),"CCLabelTTF")
            -- tabBtnLabel:setColor(G_ColorWhite)

         else
            v:setEnabled(true)
            local tabBtnItem = v
            -- local tabBtnLabel=tolua.cast(tabBtnItem:getChildByTag(31),"CCLabelTTF")
            -- tabBtnLabel:setColor(G_TabLBColorGreen)

         end
    end
end
function tankInfoEnhanceDialog:tabClick(idx)
    PlayEffect(audioCfg.mouseClick)
    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx           
         else            
            v:setEnabled(true)
         end
    end
    if idx==1 then
        if self.isHasAbility==true and self.skillIcon then
            self.lineSp3:setVisible(true)
            self.skillIcon:setVisible(true)
            self.skillNameLb:setVisible(true)
            self.skillLvLb:setVisible(true)
            self.skillDescLb:setVisible(true)
        end

        self.attackSp:setVisible(true)
        self.attLb:setVisible(true)
        self.attLbAdd:setVisible(true)
        self.attNameLb:setVisible(true)

        self.lifeSp:setVisible(true)
        self.lifeLb:setVisible(true)
        self.lifeLbAdd:setVisible(true)
        
        self.lifeNameLb:setVisible(true)

        self.accurateSp:setVisible(true)
        self.accurateLb:setVisible(true)
        self.accurateLbAdd:setVisible(true)
        self.accurateNameLb:setVisible(true)

        self.criticalSp:setVisible(true)
        self.criticalLb:setVisible(true)
        self.criticalLbAdd:setVisible(true)
        self.criticalNameLb:setVisible(true)

        self.avoidSp:setVisible(true)
        self.avoidLb:setVisible(true)
        self.avoidLbAdd:setVisible(true)
        self.avoidNameLb:setVisible(true)

        self.decriticalSp:setVisible(true)
        self.decriticalLb:setVisible(true)
        self.decriticalLbAdd:setVisible(true)
        self.decriticalNameLb:setVisible(true)

        if base.ifAccessoryOpen==1 then
            self.penetrateSp:setVisible(true)
            self.penetrateLb:setVisible(true)
            self.penetrateNameLb:setVisible(true)

            self.armorSp:setVisible(true)
            self.armorLb:setVisible(true)
            self.armorNameLb:setVisible(true)

        end

        if base.alien==1 and base.richMineOpen==1 then
            self.critDmgSp:setVisible(true)
            self.critDmgLb:setVisible(true)
            self.critDmgNameLb:setVisible(true)

            self.decritDmgSp:setVisible(true)
            self.decritDmgLb:setVisible(true)
            self.decritDmgNameLb:setVisible(true)
        end

        self.attackTypeSp:setVisible(true)
        self.attTypeLb:setVisible(true)
        self.lineSp1:setVisible(true)
        self.lineSp2:setVisible(true)

         for k=1,4 do
            self["r".. k .. "Sp"]:setVisible(false)
            self["needR".. k .. "Lb"]:setVisible(false)
            self["haveR".. k .. "Lb"]:setVisible(false)
        end
        self.bgSprie1:setVisible(false)
        self.timeSp:setVisible(false)
        self.typeLb:setVisible(false)
        self.resourceLb:setVisible(false)
        self.lbTime:setVisible(false)
        self.ownLb:setVisible(false)
    else
        if self.isHasAbility==true and self.skillIcon then
            self.lineSp3:setVisible(false)
            self.skillIcon:setVisible(false)
            self.skillNameLb:setVisible(false)
            self.skillLvLb:setVisible(false)
            self.skillDescLb:setVisible(false)
        end

        self.attackSp:setVisible(false)
        self.attLb:setVisible(false)
        self.attLbAdd:setVisible(false)
        self.attNameLb:setVisible(false)

        self.lifeSp:setVisible(false)
        self.lifeLb:setVisible(false)
        if self.lifeLbAdd then
            self.lifeLbAdd:setVisible(false)
        end
        self.lifeNameLb:setVisible(false)

        self.accurateSp:setVisible(false)
        self.accurateLb:setVisible(false)
        self.accurateLbAdd:setVisible(false)
        self.accurateNameLb:setVisible(false)

        self.criticalSp:setVisible(false)
        self.criticalLb:setVisible(false)
        self.criticalLbAdd:setVisible(false)
        self.criticalNameLb:setVisible(false)

        self.avoidSp:setVisible(false)
        self.avoidLb:setVisible(false)
        self.avoidLbAdd:setVisible(false)
        self.avoidNameLb:setVisible(false)

        self.decriticalSp:setVisible(false)
        self.decriticalLb:setVisible(false)
        self.decriticalLbAdd:setVisible(false)
        self.decriticalNameLb:setVisible(false)

        if base.ifAccessoryOpen==1 then
            self.penetrateSp:setVisible(false)
            self.penetrateLb:setVisible(false)
            self.penetrateNameLb:setVisible(false)

            self.armorSp:setVisible(false)
            self.armorLb:setVisible(false)
            self.armorNameLb:setVisible(false)

        end

        if base.alien==1 and base.richMineOpen==1 then
            self.critDmgSp:setVisible(false)
            self.critDmgLb:setVisible(false)
            self.critDmgNameLb:setVisible(false)

            self.decritDmgSp:setVisible(false)
            self.decritDmgLb:setVisible(false)
            self.decritDmgNameLb:setVisible(false)
        end

        self.attackTypeSp:setVisible(false)
        self.attTypeLb:setVisible(false)
        self.lineSp1:setVisible(false)
        self.lineSp2:setVisible(false)

        for k=1,4 do
            self["r".. k .. "Sp"]:setVisible(true)
            self["needR".. k .. "Lb"]:setVisible(true)
            self["haveR".. k .. "Lb"]:setVisible(true)
        end
        self.bgSprie1:setVisible(true)
        self.timeSp:setVisible(true)
        self.typeLb:setVisible(true)
        self.resourceLb:setVisible(true)
        self.lbTime:setVisible(true)
        self.ownLb:setVisible(true)
    end

end

function tankInfoEnhanceDialog:dispose() --释放方法

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
