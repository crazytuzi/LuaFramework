tankInfoDialog={}
function tankInfoDialog:new()
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
--container:父容器 category:build,skill等 id:ID type:type isAmata:阿玛塔坦克播放战斗动画按钮
-- battleCallback 播放战斗动画  (isAmata,battleCallback  要同时传值  除了一开始写的isAmata) baseFlag：只显示基础属性
--otherData坦克属性面板里显示所需的其他数据都可以放在otherData里面，比如坦克涂装数据
--otherTankFlag：展示的是否是自己的坦克
--accessoryPer:继承配件属性的百分比
function tankInfoDialog:create(container,id,layerNum,hideNum,isAmata,battleCallback,baseFlag,otherData,otherTankFlag,accessoryPer)
    self.id=id
    self.isUseAmi=true
    self.baseFlag=(baseFlag or false)
    self.otherData=otherData
    self.otherTankFlag=(otherTankFlag==nil) and true or otherTankFlag
    self.accessoryPer = accessoryPer
    local function realInit()
        local td=self:new()
        td:init(container,id,layerNum,hideNum,isAmata,battleCallback)
    end
    
    if self.baseFlag==false then
        local function initInfo()
            if base.ifAccessoryOpen==1 and accessoryVoApi.dataNeedRefresh==true then
                accessoryVoApi:refreshData(realInit)
            else
                realInit()
            end
        end
        local alienTechOpenLv=base.alienTechOpenLv or 22
        --异星科技增加技能点数
        if base.alien==1 and base.richMineOpen==1 and alienTechVoApi and alienTechVoApi.getTechData and playerVoApi:getPlayerLevel()>=alienTechOpenLv then
            alienTechVoApi:getTechData(initInfo)
        else
            initInfo()
        end
    else
        realInit()
    end
end


function tankInfoDialog:init(parent,id,layerNum,hideNum,isAmata,battleCallback)
    if newGuidMgr:isNewGuiding()==true then
        do
            return
        end
    end
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

    local cellWidth=550
    local bgHeight=640
    --local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",capInSet,touchDialog);
    if (base.ifAccessoryOpen == 1 and self.baseFlag == true and self.accessoryPer) or base.ifAccessoryOpen==1 then
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
    local abilityID=tankCfg[id].abilityID
    local abilityLv=tankCfg[id].abilityLv
    local skillName=""
    local skillDesc=""
    local skillIcon=nil
    local labelSize=20

    --异星科技增加技能点数
    if base.alien==1 and base.richMineOpen==1 and self.baseFlag==false then
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
    local restrainDescStr = ""    
    if self.baseFlag~=true then
        local restrainType=tankSkinVoApi:getTankSkinRestrainType(id)
        local skinAttriTb=tankSkinVoApi:getAttributeByTankId(id) or {} --坦克涂装属性总加成
        local restrainValue = skinAttriTb["restrain"] or 0 --新增坦克涂装克制
        if restrainValue > 0 then
            restrainDescStr=tankSkinVoApi:getAttributeNameStr("restrain",restrainType).."<rayimg>"..restrainValue.."%".."<rayimg>"
            local descLb,lbHeight=G_getRichTextLabel(restrainDescStr,{G_ColorWhite,G_ColorGreen},labelSize-2,lbSize.width,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            -- bgHeight = bgHeight + lbHeight + 25 + 50
            tvHeight = tvHeight + lbHeight + 25 + 50
        end
    end
    
    local dialogBg = G_getNewDialogBg2(CCSizeMake(cellWidth,bgHeight),layerNum)
    -- dialogBg:setContentSize(CCSizeMake(cellWidth,bgHeight))
    self.bgLayer=dialogBg

    self.touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),touchDialog);
    self.touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect1=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    self.touchDialogBg:setContentSize(rect1)
    self.touchDialogBg:setOpacity(255*0.8)
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
            local skinId,isCheckSelf
            if self.otherData and self.otherTankFlag==false then
                skinId,isCheckSelf=self.otherData.skin,false
            end
            local spriteIcon=tankVoApi:getTankIconSp(id,skinId,nil,isCheckSelf)
            spriteIcon:setAnchorPoint(ccp(0,0.5));
            spriteIcon:setScale(0.7)
            spriteIcon:setPosition(30,dialogBgHeight-80)
            self.container:addChild(spriteIcon,2)
            
            local strWidth = 320
            if G_getCurChoseLanguage() =="ar" then
                strWidth =220 
            end
            local lbName=GetTTFLabelWrap(getlocal(tankCfg[id].name),24,CCSizeMake(strWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
           lbName:setPosition(160,dialogBgHeight-40)
           lbName:setAnchorPoint(ccp(0,0.5));
           self.container:addChild(lbName,2)
           
            if (hideNum == false or hideNum == nil) and self.baseFlag==false then
               local lbNum=GetTTFLabel(getlocal("schedule_ship_num",{""}),20)
               lbNum:setPosition(160,dialogBgHeight-80)
               lbNum:setAnchorPoint(ccp(0,0.5));
               self.container:addChild(lbNum,2)

               -- 普通坦克数量和精英坦克数量
               local sp1=CCSprite:createWithSpriteFrameName("picked_icon2.png")
               self.container:addChild(sp1,2)
               sp1:setPosition(180,dialogBgHeight-120)

               local num1Lb = GetTTFLabel(tankVoApi:getTankCountByItemId(id),20)
               num1Lb:setAnchorPoint(ccp(0,0.5))
               num1Lb:setPosition(sp1:getContentSize().width, sp1:getContentSize().height/2)
               sp1:addChild(num1Lb)

               if tankVoApi:getTankCountByItemId(id+40000)>0 then
                   local sp2=CCSprite:createWithSpriteFrameName("picked_icon2.png")
                   self.container:addChild(sp2,2)
                   sp2:setPosition(340,dialogBgHeight-120)
               
                   local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
                   sp2:addChild(pickedIcon)
                   pickedIcon:setPosition(sp2:getContentSize().width-10,sp2:getContentSize().height/2)
                   pickedIcon:setScale(0.9)

                   local num2Lb = GetTTFLabel(tankVoApi:getTankCountByItemId(id+40000),24)
                   num2Lb:setAnchorPoint(ccp(0,0.5))
                   num2Lb:setPosition(sp2:getContentSize().width+10, sp2:getContentSize().height/2)
                   sp2:addChild(num2Lb)
               end
              
            end

            

            -- local lbDescription=GetTTFLabelWrap(getlocal(tankCfg[id].description),textSizeD,lbSize,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            -- lbDescription:setPosition(30,dialogBgHeight-200)
            -- lbDescription:setAnchorPoint(ccp(0,0.5))
            -- self.container:addChild(lbDescription,2)
            

            -- 阿玛塔播放动画
            if isAmata then
                local function touchAction(tag,object )
                    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                        if G_checkClickEnable()==false then
                            do
                                return
                            end
                        else
                            base.setWaitTime=G_getCurDeviceMillTime()
                        end
                        self.actionTouchFir:setEnabled(false)
                        PlayEffect(audioCfg.mouseClick)
                        self:close()
                        if battleCallback then
                            battleCallback()
                        else
                            self:showBattle()
                        end
                        
                    end
                    
                end 
                self.actionTouchFir = GetButtonItem("cameraBtn.png","cameraBtn_down.png","cameraBtn.png",touchAction,nil,nil,0)
                self.actionTouchFir:setAnchorPoint(ccp(0.5,0))
                local actionTouchFirMenu = CCMenu:createWithItem(self.actionTouchFir)
                actionTouchFirMenu:setTouchPriority(-(layerNum-1)*20-2)
                actionTouchFirMenu:setPosition(ccp(cellWidth-80,dialogBgHeight-120))
                self.container:addChild(actionTouchFirMenu)

            end


            local firstSpX = 50-10
            local firstLbX = 110-10
            
            local secndSpX = 250+30
            local secndLbX = 310+30

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
                local lineSp3=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine5.png", CCRect(4, 0, 2, 2), function ()end)
                lineSp3:setAnchorPoint(ccp(0.5,0.5));
                lineSp3:setPosition(cellWidth/2,dialogBgHeight-275)
                lineSp3:setContentSize(CCSizeMake(cellWidth-50,2))
                self.container:addChild(lineSp3,2)

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
            local attack,life,accurate,avoid,critical,decritical,armor,penetrate,critDmg,decritDmg,baseAttackAdd,baseLifeAdd=0,0,0,0,0,0,0,0,0,0,0,0
            if self.baseFlag==false then
                attack,life,accurate,avoid,critical,decritical,armor,penetrate,critDmg,decritDmg,baseAttackAdd,baseLifeAdd=tankVoApi:getTankAddProperty(id)
            end
            local baseAttack=tonumber(tankCfg[id].attack)+baseAttackAdd
            local baseLife=tonumber(tankCfg[id].life)+baseLifeAdd
            local carryResource=tonumber(tankCfg[id].carryResource)

            if base.ifAccessoryOpen == 1 and self.baseFlag == true and self.accessoryPer then
                if id and accessoryVoApi then
                    if tankCfg and tankCfg[id] and tankCfg[id].type then
                        local equipAddTab=accessoryVoApi:getTankAttAdd(tankCfg[id].type)
                        local eAttackAdd=tonumber(equipAddTab[1]) or 0
                        local eLifeAdd=tonumber(equipAddTab[2]) or 0
                        local eArmorAdd=tonumber(equipAddTab[3]) or 0
                        local ePenetrateAdd=tonumber(equipAddTab[4]) or 0
                        local per = self.accessoryPer / 100
                        eAttackAdd = eAttackAdd * per
                        eLifeAdd = eLifeAdd * per
                        eArmorAdd = eArmorAdd * per
                        ePenetrateAdd = ePenetrateAdd * per
                        attack = eAttackAdd / 100 * baseAttack
                        life = eLifeAdd / 100 * baseLife
                        --保留2位小数
                        attack = G_keepNumber(attack, 2)
                        life = G_keepNumber(life, 2)
                        penetrate = G_keepNumber(ePenetrateAdd, 2)
                        armor = G_keepNumber(eArmorAdd, 2)
                    end
                end
            end

        --攻击    
            local attackSp = CCSprite:createWithSpriteFrameName("pro_ship_attack.png");
            local iconScale= 50/attackSp:getContentSize().width
            attackSp:setAnchorPoint(ccp(0,0.5));
            attackSp:setPosition(firstSpX,dialogBgHeight-320)
            self.container:addChild(attackSp,2)
            attackSp:setScale(iconScale)
            
            local attLb=GetTTFLabel(baseAttack,18)
            attLb:setAnchorPoint(ccp(0,0.5))
            attLb:setPosition(ccp(firstLbX,dialogBgHeight-320-14))
            self.container:addChild(attLb)
            
            if self.baseFlag==false or (base.ifAccessoryOpen == 1 and self.baseFlag == true and self.accessoryPer) then
                self.attLbAdd=GetTTFLabel("+"..(attack),18)
                self.attLbAdd:setAnchorPoint(ccp(0,0.5))
                self.attLbAdd:setPosition(ccp(firstLbX+attLb:getContentSize().width,dialogBgHeight-320-14))
                self.attLbAdd:setColor(G_ColorGreen)
                self.container:addChild(self.attLbAdd)
            end
            
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
            
            local lifeLb=GetTTFLabel(baseLife,18)
            lifeLb:setAnchorPoint(ccp(0,0.5))
            lifeLb:setPosition(ccp(firstLbX,dialogBgHeight-390-14))
            self.container:addChild(lifeLb)
            
            if self.baseFlag==false or (base.ifAccessoryOpen == 1 and self.baseFlag == true and self.accessoryPer) then
                self.lifeLbAdd=GetTTFLabel("+"..(life),18)
                self.lifeLbAdd:setAnchorPoint(ccp(0,0.5))
                self.lifeLbAdd:setPosition(ccp(firstLbX+lifeLb:getContentSize().width,dialogBgHeight-390-14))
                self.lifeLbAdd:setColor(G_ColorGreen)
                self.container:addChild(self.lifeLbAdd)
            end
            
            local lifeNameLb=GetTTFLabelWrap(getlocal("tankBlood"),labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            lifeNameLb:setAnchorPoint(ccp(0,0.5))
            lifeNameLb:setPosition(ccp(firstLbX,dialogBgHeight-390+14))
            self.container:addChild(lifeNameLb)

        -- 载重 carryResource
        local carrySp = CCSprite:createWithSpriteFrameName("tank_carry_icon.png");
        carrySp:setAnchorPoint(ccp(0,0.5));
        carrySp:setPosition(secndSpX,dialogBgHeight-390)
        self.container:addChild(carrySp,2)
        carrySp:setScale(iconScale)
        
        local carryLb=GetTTFLabel(carryResource,18)
        carryLb:setAnchorPoint(ccp(0,0.5))
        carryLb:setPosition(ccp(secndLbX,dialogBgHeight-390-14))
        self.container:addChild(carryLb)
        
        local tankTb={{id,1}}
        local totalCarry=tankVoApi:getAttackTanksCarryResource(tankTb)

        if self.baseFlag==false then
            local carryValue = tonumber(string.format("%.3f", totalCarry-carryResource))
            self.carryAdd=GetTTFLabel("+"..carryValue,18)
            self.carryAdd:setAnchorPoint(ccp(0,0.5))
            self.carryAdd:setPosition(ccp(secndLbX+carryLb:getContentSize().width,dialogBgHeight-390-14))
            self.carryAdd:setColor(G_ColorGreen)
            self.container:addChild(self.carryAdd)
        end
        
        local carryNameLb=GetTTFLabelWrap(getlocal("sample_tech_name_24"),labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        carryNameLb:setAnchorPoint(ccp(0,0.5))
        carryNameLb:setPosition(ccp(secndLbX,dialogBgHeight-390+14))
        self.container:addChild(carryNameLb)
        --精准    
            local accurateSp = CCSprite:createWithSpriteFrameName("skill_01.png");
            accurateSp:setAnchorPoint(ccp(0,0.5));
            accurateSp:setPosition(firstSpX,dialogBgHeight-460)
            self.container:addChild(accurateSp,2)
            accurateSp:setScale(iconScale)
            
            local accurateLb=GetTTFLabel(tankCfg[id].accurate.."%",18)
            accurateLb:setAnchorPoint(ccp(0,0.5))
            accurateLb:setPosition(ccp(firstLbX,dialogBgHeight-474))
            self.container:addChild(accurateLb)
            
            if self.baseFlag==false then
                self.accurateLbAdd=GetTTFLabel("+"..accurate.."%",18)
                self.accurateLbAdd:setAnchorPoint(ccp(0,0.5))
                self.accurateLbAdd:setPosition(ccp(firstLbX+accurateLb:getContentSize().width,dialogBgHeight-474))
                self.accurateLbAdd:setColor(G_ColorGreen)
                self.container:addChild(self.accurateLbAdd)
            end
            
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
            
            local criticalLb=GetTTFLabel(tankCfg[id].critical.."%",18)
            criticalLb:setAnchorPoint(ccp(0,0.5))
            criticalLb:setPosition(ccp(firstLbX,dialogBgHeight-530-14))
            self.container:addChild(criticalLb)
            
            if self.baseFlag==false then
                self.criticalLbAdd=GetTTFLabel("+"..critical.."%",18)
                self.criticalLbAdd:setAnchorPoint(ccp(0,0.5))
                self.criticalLbAdd:setPosition(ccp(firstLbX+criticalLb:getContentSize().width,dialogBgHeight-530-14))
                self.criticalLbAdd:setColor(G_ColorGreen)
                self.container:addChild(self.criticalLbAdd) 
            end
            
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
            
            local avoidLb=GetTTFLabel(tankCfg[id].avoid.."%",18)
            avoidLb:setAnchorPoint(ccp(0,0.5))
            avoidLb:setPosition(ccp(secndLbX,dialogBgHeight-460-14))
            self.container:addChild(avoidLb)
            
            if self.baseFlag==false then
                self.avoidLbAdd=GetTTFLabel("+"..avoid.."%",18)
                self.avoidLbAdd:setAnchorPoint(ccp(0,0.5))
                self.avoidLbAdd:setPosition(ccp(secndLbX+avoidLb:getContentSize().width,dialogBgHeight-460-14))
                self.avoidLbAdd:setColor(G_ColorGreen)
                self.container:addChild(self.avoidLbAdd)
            end
            
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
            
            local decriticalLb=GetTTFLabel(tankCfg[id].decritical.."%",18)
            decriticalLb:setAnchorPoint(ccp(0,0.5))
            decriticalLb:setPosition(ccp(secndLbX,dialogBgHeight-530-14))
            self.container:addChild(decriticalLb)
            
            if self.baseFlag==false then
                self.decriticalLbAdd=GetTTFLabel("+"..decritical.."%",18)
                self.decriticalLbAdd:setAnchorPoint(ccp(0,0.5))
                self.decriticalLbAdd:setPosition(ccp(secndLbX+decriticalLb:getContentSize().width,dialogBgHeight-530-14))
                self.decriticalLbAdd:setColor(G_ColorGreen)
                self.container:addChild(self.decriticalLbAdd) 
            end
            
            local decriticalNameLb=GetTTFLabelWrap(getlocal("sample_skill_name_104"),labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            decriticalNameLb:setAnchorPoint(ccp(0,0.5))
            decriticalNameLb:setPosition(ccp(secndLbX,dialogBgHeight-530+14))
            self.container:addChild(decriticalNameLb)

        --配件开关
            if base.ifAccessoryOpen==1 and (self.baseFlag==false or (self.baseFlag == true and self.accessoryPer)) then
                --击破  
                local penetrateSp = CCSprite:createWithSpriteFrameName("attributeARP.png");
                penetrateSp:setAnchorPoint(ccp(0,0.5));
                penetrateSp:setPosition(firstSpX,dialogBgHeight-600)
                self.container:addChild(penetrateSp,2)
                penetrateSp:setScale(iconScale)
                
                self.penetrateLb=GetTTFLabel(penetrate,18)
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
                
                self.armorLb=GetTTFLabel(armor,18)
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
            if base.alien==1 and base.richMineOpen==1 and self.baseFlag==false then
                --暴击伤害增加 
                local critDmgSp = CCSprite:createWithSpriteFrameName("skill_110.png");
                critDmgSp:setAnchorPoint(ccp(0,0.5));
                critDmgSp:setPosition(firstSpX,dialogBgHeight-600-70)
                self.container:addChild(critDmgSp,2)
                critDmgSp:setScale(iconScale)
                
                self.critDmgLb=GetTTFLabel(critDmg.."%",18)
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
                
                self.decritDmgLb=GetTTFLabel(decritDmg.."%",18)
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
                print("tankCfg[id].weaponType...",tankCfg[id].weaponType)
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

            local lineSp1=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine5.png", CCRect(4, 0, 2, 2), function ()end)
            lineSp1:setAnchorPoint(ccp(0.5,0.5));
            lineSp1:setPosition(cellWidth/2,dialogBgHeight-275)
            lineSp1:setContentSize(CCSizeMake(cellWidth-50,2))
            self.container:addChild(lineSp1,2)
            
            local lineSp2=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine5.png", CCRect(4, 0, 2, 2), function ()end)
            lineSp2:setAnchorPoint(ccp(0.5,0.5));
            lineSp2:setPosition(cellWidth/2,dialogBgHeight-423)
            lineSp2:setContentSize(CCSizeMake(cellWidth-50,2))
            self.container:addChild(lineSp2,2)
            if base.tskinSwitch==1 and self.baseFlag~=true then
                if restrainDescStr and restrainDescStr~="" then
                    local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine5.png", CCRect(4, 0, 2, 2), function ()end)
                    lineSp:setAnchorPoint(ccp(0.5,0.5))
                    lineSp:setPosition(cellWidth/2,dialogBgHeight-705)
                    lineSp:setContentSize(CCSizeMake(cellWidth-50,2))
                    self.container:addChild(lineSp,2)

                    local restrainSp = tankSkinVoApi:getSkinRestrainIconSp(id, restrainType)
                    if restrainSp then
                        restrainSp:setScale(50/restrainSp:getContentSize().width)
                        restrainSp:setPosition(firstSpX,dialogBgHeight-740)
                        restrainSp:setAnchorPoint(ccp(0,0.5))
                        self.container:addChild(restrainSp)

                        local nameLb = GetTTFLabel(getlocal("tankSkin_restrain_name"),labelSize)
                        nameLb:setAnchorPoint(ccp(0,0.5))
                        nameLb:setPosition(firstLbX,restrainSp:getPositionY())
                        self.container:addChild(nameLb)

                        local restrainDescLb,lbHeight=G_getRichTextLabel(restrainDescStr,{G_ColorWhite,G_ColorGreen},labelSize-2,lbSize.width,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                        restrainDescLb:setAnchorPoint(ccp(0,1))
                        restrainDescLb:setPosition(firstSpX,restrainSp:getPositionY()-30)
                        self.container:addChild(restrainDescLb,2)
                    end
                end
            end

            local function onShare()
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                end
                if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    PlayEffect(audioCfg.mouseClick)
                    local id=self.id
                    if id==nil then
                        return
                    end
                    local attack,life,accurate,avoid,critical,decritical,armor,penetrate,critDmg,decritDmg,baseAttackAdd,baseLifeAdd=tankVoApi:getTankAddProperty(self.id)
                    local baseAttack=tonumber(tankCfg[id].attack)+baseAttackAdd
                    local baseLife=tonumber(tankCfg[id].life)+baseLifeAdd
                    local carryResource=tonumber(tankCfg[id].carryResource)
                    local share={}
                    share.stype=1 --分享的类型
                    share.name=playerVoApi:getPlayerName()
                    share.tid=id
                    if isHasAbility==true and skillIcon then
                        local skill={abilityID,abilityLv}
                        share.s=skill --技能数据
                    end
                    local pbase={}
                    pbase[1]={baseAttack,attack} --攻击
                    local wt=tankCfg[id].attackNum
                    if tonumber(tankCfg[id].weaponType)>10 then
                        wt=tankCfg[id].weaponType
                    end
                    pbase[2]={wt}
                    pbase[3]={baseLife,life} --血量
                    pbase[4]={carryResource,(totalCarry-carryResource)} --载重
                    share.b=pbase --基础属性
                    local extra={}
                    extra[1]={tankCfg[id].accurate.."%",accurate.."%"} --精准
                    extra[2]={tankCfg[id].avoid.."%",avoid.."%"} --闪避
                    extra[3]={tankCfg[id].critical.."%",critical.."%"} --暴击
                    extra[4]={tankCfg[id].decritical.."%",decritical.."%"} --装甲(坚韧)
                    if base.ifAccessoryOpen==1 then
                        extra[5]={penetrate} --击破
                        extra[6]={armor} --防护
                    end
                    if base.alien==1 and base.richMineOpen==1 then
                        extra[7]={critDmg.."%"} --暴伤
                        extra[8]={decritDmg.."%"} --韧性
                    end
                    share.e=extra --附加属性

                    local skinId=tankSkinVoApi:getEquipSkinByTankId(id)
                    share.tskin=skinId --坦克装扮的皮肤数据
                    share.restrain={restrainType,restrainValue} --坦克涂装克制关系
                    
                    local message=getlocal("mything",{getlocal("fleetInfoTitle2")})..":".."【"..getlocal(tankCfg[id].name).."】"
                    local tipStr=getlocal("send_share_sucess",{getlocal("fleetInfoTitle2")})
                    G_shareHandler(share,message,tipStr,layerNum+1)
                end
            end
            if (isAmata==nil or isAmata==false) and self.baseFlag==false then
                local shareItem=GetButtonItem("anniversarySend.png","anniversarySendDown.png","anniversarySendDown.png",onShare)
                local shareBtn=CCMenu:createWithItem(shareItem)
                shareBtn:setTouchPriority(-(layerNum-1)*20-2)
                shareBtn:setPosition(cellWidth-80,cellHeight-40)
                cell:addChild(shareBtn,2)

                local rect=CCSizeMake(100,100)
                local addTouchBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),onShare)
                addTouchBg:setTouchPriority(-(layerNum-1)*20-1)
                addTouchBg:setContentSize(rect)
                -- addTouchBg:setAnchorPoint(ccp(1,0.5))
                addTouchBg:setOpacity(0)
                addTouchBg:setPosition(ccp(cellWidth-80,cellHeight-40))
                cell:addChild(addTouchBg,1)
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

function tankInfoDialog:showBattle()
    local battleStr=acHongchangyuebingVoApi:returnTankData()
    local report=G_Json.decode(battleStr)
    local isAttacker=true
    local data={data={report=report},isAttacker=isAttacker,isReport=true}
    local playerData=data.data.report.p
    local nameStr1 = getlocal(tostring(playerData[1][1]))
    local nameStr2 = getlocal(tostring(playerData[2][1]))
    data.data.report.p[1][1]=nameStr1
    data.data.report.p[2][1]=nameStr2
    battleScene:initData(data,true)
end

--显示面板,加效果
function tankInfoDialog:show()

    --if self.isUseAmi~=nil then
       local moveTo=CCMoveTo:create(0.3,CCPointMake(G_VisibleSize.width/2,G_VisibleSize.height/2))
       local function callBack()
            if self.baseFlag==true and self.accessoryPer == nil then
                base:cancleWait()
                do return end
            end
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
                                if base.ifAccessoryOpen == 1 and self.baseFlag == true and self.accessoryPer then
                                    attack, life, penetrate, armor = 0, 0, 0, 0
                                    if self.id and accessoryVoApi then
                                        if tankCfg and tankCfg[self.id] and tankCfg[self.id].type then
                                            local equipAddTab=accessoryVoApi:getTankAttAdd(tankCfg[self.id].type)
                                            local baseAttack=tonumber(tankCfg[self.id].attack)+baseAttackAdd
                                            local baseLife=tonumber(tankCfg[self.id].life)+baseLifeAdd
                                            local eAttackAdd=tonumber(equipAddTab[1]) or 0
                                            local eLifeAdd=tonumber(equipAddTab[2]) or 0
                                            local eArmorAdd=tonumber(equipAddTab[3]) or 0
                                            local ePenetrateAdd=tonumber(equipAddTab[4]) or 0
                                            local per = self.accessoryPer / 100
                                            eAttackAdd = eAttackAdd * per
                                            eLifeAdd = eLifeAdd * per
                                            eArmorAdd = eArmorAdd * per
                                            ePenetrateAdd = ePenetrateAdd * per
                                            attack = eAttackAdd / 100 * baseAttack
                                            life = eLifeAdd / 100 * baseLife
                                            --保留2位小数
                                            attack = G_keepNumber(attack, 2)
                                            life = G_keepNumber(life, 2)
                                            penetrate = G_keepNumber(ePenetrateAdd, 2)
                                            armor = G_keepNumber(eArmorAdd, 2)
                                        end
                                    end
                                end

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
   table.insert(G_SmallDialogDialogTb,self)   
   
end


--关卡科技加成数据更新
function tankInfoDialog:updateAddAttNum()
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
function tankInfoDialog:refreshAddAttNum()
    if self.baseFlag==true then
        do return end
    end
    if self and self.id then
        local attack,life,accurate,avoid,critical,decritical,armor,penetrate,critDmg,decritDmg,baseAttackAdd,baseLifeAdd=tankVoApi:getTankAddProperty(self.id, self.accessoryPer)
        --保留2位小数
        attack = G_keepNumber(attack, 2)
        life = G_keepNumber(life, 2)
        penetrate = G_keepNumber(penetrate, 2)
        armor = G_keepNumber(armor, 2)
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
                self.penetrateLb:setString(tostring(penetrate))
            end
        end
        if self.armorLb then
            self.armorLb=tolua.cast(self.armorLb,"CCLabelTTF")
            if self.armorLb then
                self.armorLb:setString(tostring(armor))
            end
        end
    end
end



function tankInfoDialog:close()

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
function tankInfoDialog:realClose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil

end
function tankInfoDialog:tick()

    
end

function tankInfoDialog:dispose() --释放方法
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
