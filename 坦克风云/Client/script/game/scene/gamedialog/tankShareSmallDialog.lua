tankShareSmallDialog=shareSmallDialog:new()
function tankShareSmallDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function tankShareSmallDialog:showTankInfoSmallDialog(player,tankInfo,layerNum,bgSrc,inRect)
    local sd=tankShareSmallDialog:new()
    sd:create(bgSrc,inRect,CCSizeMake(550,500),player,tankInfo,layerNum,nil,true)
end

function tankShareSmallDialog:init()
    if newGuidMgr:isNewGuiding()==true then
        do
            return
        end
    end

    local tankInfo=self.share
    local titleBgH=65
    local bgWidth=550
    local cellWidth=bgWidth-40
    local lbSize=CCSize(440,0)
    local labelSize=20
    local iconSize=60
    local bgHeight=0
    local id=tankInfo.tid
    local skillIcon
    local skillDesc=""
    local skillName=""
    bgHeight=bgHeight+titleBgH+10

    local function getCellHeight()
        local cellHeight=0    
        if tankCfg[id].tankAgainst and type(tankCfg[id].tankAgainst)=="table" and SizeOfTable(tankCfg[id].tankAgainst)~=0 then
            local type=tankCfg[id].tankAgainst[1]

            local desStr=getlocal("tank_kz_des_" .. type,{tankCfg[id].tankAgainst[2]})
            local kzDesLb,lbHeight=G_getRichTextLabel(desStr,{G_ColorWhite,G_ColorGreen},labelSize-2,lbSize.width,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            cellHeight=cellHeight+lbHeight+5+iconSize
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
            cellHeight=cellHeight+lbHeight+5+iconSize
        end
        local skill=tankInfo.s --技能
        if skill then
            local sid=skill[1]
            local slv=skill[2]
            local aCfg=abilityCfg[sid][slv]
            skillName=getlocal(aCfg.name)
            local descParm={}
            local rNum = G_specTankId[id] or 100
            if aCfg.value1 then
                table.insert(descParm,aCfg.value1*rNum)
            end
            if aCfg.value2 then
                table.insert(descParm,aCfg.value2*rNum)
            end
            skillDesc=getlocal(aCfg.desc,descParm)
            skillIcon=CCSprite:createWithSpriteFrameName(aCfg.icon)

            local skillDescLb=GetTTFLabelWrap(skillDesc,labelSize-2,lbSize,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            skillHeight=iconSize+skillDescLb:getContentSize().height

            cellHeight=cellHeight+skillHeight+20
        end
        local pbase=tankInfo.b
        if pbase then
            local count=SizeOfTable(pbase)
            if count%2>0 then
                count=math.floor(count/2)+1
            else
                count=math.floor(count/2)
            end
            cellHeight=cellHeight+count*iconSize+(count-1)*10+20
        end
        local pextra=tankInfo.e
        if pextra then
            local count=SizeOfTable(pextra)
            if count%2>0 then
                count=math.floor(count/2)+1
            else
                count=math.floor(count/2)
            end
            cellHeight=cellHeight+count*iconSize+(count-1)*10+15
        end
        local restrain = tankInfo.restrain or {} --坦克涂装的克制关系
        if restrain[1] and restrain[2] and tonumber(restrain[1])>0 and tonumber(restrain[2])>0 then
            local restrainDescStr=tankSkinVoApi:getAttributeNameStr("restrain",restrain[1]).."<rayimg>"..restrain[2].."%".."<rayimg>"
            local descLb,lbHeight=G_getRichTextLabel(restrainDescStr,{G_ColorWhite,G_ColorGreen},labelSize-2,lbSize.width,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            cellHeight = cellHeight + lbHeight + 25 + iconSize
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

    self.detailBg:setContentSize(CCSizeMake(cellWidth,tvHeight+40))
    bgHeight=bgHeight+self.detailBg:getContentSize().height+20
    local skinId = tankInfo.tskin
    local tankScale=0.7
    local tankIcon=tankVoApi:getTankIconSp(id,skinId,nil,false)--CCSprite:createWithSpriteFrameName(tankCfg[id].icon)
    tankIcon:setAnchorPoint(ccp(0,0.5))
    tankIcon:setScale(tankScale)
    self.bgLayer:addChild(tankIcon,2)

    local tankSize=tankIcon:getContentSize()
    bgHeight=bgHeight+tankSize.height*0.7+10
    
    local lbName=GetTTFLabelWrap(getlocal(tankCfg[id].name),28,CCSizeMake(bgWidth-300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    lbName:setAnchorPoint(ccp(0,0.5))
    self.bgLayer:addChild(lbName,2)

    self.bgLayer:setContentSize(CCSizeMake(bgWidth,bgHeight))
    tankIcon:setPosition(ccp(30,bgHeight-titleBgH-tankSize.height*tankScale*0.5-15))
    lbName:setPosition(tankIcon:getPositionX()+tankSize.width*tankScale+20,tankIcon:getPositionY())
    self.detailBg:setPosition(bgWidth/2,tankIcon:getPositionY()-tankSize.height*tankScale*0.5-10)

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
            local labelWidth=150
            local labelSize=20
            local firstPosX=20
            if tankCfg[id].tankAgainst and type(tankCfg[id].tankAgainst)=="table" and SizeOfTable(tankCfg[id].tankAgainst)~=0 then
                local type=tankCfg[id].tankAgainst[1]

                local kzPic="tank_kz_icon_" ..type.. ".png"
                local kzSp=CCSprite:createWithSpriteFrameName(kzPic)
                local iconScale=iconSize/kzSp:getContentSize().width
                kzSp:setAnchorPoint(ccp(0,1))
                kzSp:setPosition(firstPosX,posY)
                cell:addChild(kzSp,2)
                kzSp:setScale(iconScale)

                local nameStr=getlocal("tank_kz_name_" .. type)
                local kzNameLb=GetTTFLabel(nameStr,labelSize)
                kzNameLb:setAnchorPoint(ccp(0,0.5))
                kzNameLb:setPosition(ccp(kzSp:getPositionX()+iconSize+10,kzSp:getPositionY()-iconSize/2))
                cell:addChild(kzNameLb)

                local desStr=getlocal("tank_kz_des_" .. type,{tankCfg[id].tankAgainst[2]})
                local kzDesLb,lbHeight=G_getRichTextLabel(desStr,{G_ColorWhite,G_ColorGreen},labelSize-2,lbSize.width,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                kzDesLb:setAnchorPoint(ccp(0,1))
                kzDesLb:setPosition(firstPosX,kzSp:getPositionY()-iconSize)
                cell:addChild(kzDesLb,2)
                posY=posY-iconSize-lbHeight-5
            end
            if tankCfg[id].buffShow and type(tankCfg[id].buffShow)=="table" then
                local type=tankCfg[id].buffShow[1]
                local ghPic="tank_gh_icon_" ..type.. ".png"
                local ghSp=CCSprite:createWithSpriteFrameName(ghPic)
                local iconScale=iconSize/ghSp:getContentSize().width
                ghSp:setAnchorPoint(ccp(0,1))
                ghSp:setPosition(firstPosX,posY)
                cell:addChild(ghSp,2)
                ghSp:setScale(iconScale)

                local nameStr=getlocal("tank_gh_name_" .. type)
                local ghNameLb=GetTTFLabel(nameStr,labelSize)
                ghNameLb:setAnchorPoint(ccp(0,0.5))
                ghNameLb:setPosition(ccp(ghSp:getPositionX()+iconSize+10,ghSp:getPositionY()-iconSize/2))
                cell:addChild(ghNameLb)

                local ghLvLb=GetTTFLabel(getlocal("fightLevel",{tankCfg[id].buffShow[2]}),20)
                ghLvLb:setAnchorPoint(ccp(0,0.5))
                ghLvLb:setPosition(ccp(ghNameLb:getPositionX()+ghNameLb:getContentSize().width+25,ghNameLb:getPositionY()))
                ghLvLb:setColor(G_ColorYellowPro)
                cell:addChild(ghLvLb)

                local value

                if tonumber(tankCfg[id].buffvalue)<1 then
                    value=tonumber(tankCfg[id].buffvalue)*100
                else
                    value=tonumber(tankCfg[id].buffvalue)
                end
                local desStr=getlocal("tank_gh_des_" .. type,{value})
                local ghDesLb,lbHeight=G_getRichTextLabel(desStr,{G_ColorWhite,G_ColorGreen},labelSize-2,lbSize.width,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                ghDesLb:setAnchorPoint(ccp(0,1))
                ghDesLb:setPosition(firstPosX,ghSp:getPositionY()-iconSize)
                cell:addChild(ghDesLb,2)
                posY=posY-iconSize-lbHeight-5
            end
            local skill=tankInfo.s
            if skill then
                local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine5.png", CCRect(4, 0, 2, 2), function ()end)
                lineSp:setAnchorPoint(ccp(0.5,1))
                lineSp:setPosition(cellWidth/2,posY)
                lineSp:setContentSize(CCSizeMake(cellWidth-20,2))
                cell:addChild(lineSp,2)
                lineSp:setScaleX((cellWidth-50)/lineSp:getContentSize().width)

                skillIcon:setAnchorPoint(ccp(0,1))
                skillIcon:setPosition(firstPosX,posY-15)
                cell:addChild(skillIcon,2)
                skillIcon:setScale(iconSize/skillIcon:getContentSize().width)

                local skillNameLb=GetTTFLabel(skillName,labelSize)
                skillNameLb:setAnchorPoint(ccp(0,0.5))
                skillNameLb:setPosition(ccp(skillIcon:getPositionX()+iconSize+10,skillIcon:getPositionY()-iconSize/2))
                cell:addChild(skillNameLb)

                local skillLvLb=GetTTFLabel(getlocal("fightLevel",{skill[2]}),20)
                skillLvLb:setAnchorPoint(ccp(0,0.5))
                skillLvLb:setPosition(ccp(skillNameLb:getPositionX()+skillNameLb:getContentSize().width+25,skillNameLb:getPositionY()))
                skillLvLb:setColor(G_ColorYellowPro)
                cell:addChild(skillLvLb)

                local skillDescLb=GetTTFLabelWrap(skillDesc,labelSize-2,lbSize,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                skillDescLb:setAnchorPoint(ccp(0,1))
                skillDescLb:setPosition(firstPosX,skillIcon:getPositionY()-iconSize)
                cell:addChild(skillDescLb,2)

                posY=posY-iconSize-skillDescLb:getContentSize().height-20
            end
            
            local pbase=tankInfo.b
            if pbase then
                local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine5.png", CCRect(4, 0, 2, 2), function ()end)
                lineSp:setAnchorPoint(ccp(0.5,1))
                lineSp:setPosition(cellWidth/2,posY)
                lineSp:setContentSize(CCSizeMake(cellWidth-20,2))
                cell:addChild(lineSp,2)
                lineSp:setScaleX((cellWidth-50)/lineSp:getContentSize().width)
                posY=posY-15
                local picCfg={"pro_ship_attack.png",nil,"pro_ship_life.png","tank_carry_icon.png"}
                local nameCfg={"tankAtk",nil,"tankBlood","sample_tech_name_24"}
                for k,v in pairs(pbase) do
                    local pic=picCfg[k]
                    local name=nameCfg[k]
                    if k==2 then
                        name="pro_ship_attacktype_"..v[1]
                        pic=name..".png"
                    end
                    if pic and name then
                        local posX=firstPosX
                        if k%2==0 then
                            posX=cellWidth/2+20
                        end
                        local iconSp=CCSprite:createWithSpriteFrameName(pic)
                        local iconScale=iconSize/iconSp:getContentSize().width
                        iconSp:setAnchorPoint(ccp(0,1))
                        iconSp:setPosition(posX,posY-math.floor((k-1)/2)*(iconSize+10))
                        cell:addChild(iconSp,2)
                        iconSp:setScale(iconScale)
                        
                        local nameLb=GetTTFLabelWrap(getlocal(name),labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                        if k==2 then
                            nameLb:setAnchorPoint(ccp(0,0.5))
                        else
                            nameLb:setAnchorPoint(ccp(0,0))
                        end
                        nameLb:setPosition(ccp(iconSp:getPositionX()+iconSize+10,iconSp:getPositionY()-iconSize/2))
                        cell:addChild(nameLb)
                        if k~=2 then
                            local valueLb=GetTTFLabel(v[1],20)
                            valueLb:setAnchorPoint(ccp(0,1))
                            valueLb:setPosition(ccp(iconSp:getPositionX()+iconSize+10,iconSp:getPositionY()-iconSize/2))
                            cell:addChild(valueLb)
                            if v[2] then
                                local addLb=GetTTFLabel("+"..v[2],20)
                                addLb:setAnchorPoint(ccp(0,1))
                                addLb:setPosition(ccp(valueLb:getPositionX()+valueLb:getContentSize().width,valueLb:getPositionY()))
                                addLb:setColor(G_ColorGreen)
                                cell:addChild(addLb)
                            end
                        end
                    end
                end
                local count=SizeOfTable(pbase)
                if count%2>0 then
                    count=math.floor(count/2)+1
                else
                    count=math.floor(count/2)
                end
                posY=posY-count*iconSize-(count-1)*10-5
            end
            local pextra=tankInfo.e
            if pextra then
                local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine5.png", CCRect(4, 0, 2, 2), function ()end)
                lineSp:setAnchorPoint(ccp(0.5,1))
                lineSp:setPosition(cellWidth/2,posY)
                lineSp:setContentSize(CCSizeMake(cellWidth-20,2))
                cell:addChild(lineSp,2)
                lineSp:setScaleX((cellWidth-50)/lineSp:getContentSize().width)
                posY=posY-15
                local picCfg={"skill_01.png","skill_02.png","skill_03.png","skill_04.png","attributeARP.png","attributeArmor.png","skill_110.png","skill_111.png"}
                local nameCfg={"sample_skill_name_101","sample_skill_name_102","sample_skill_name_103","sample_skill_name_104","accessory_prop_name_1","accessory_prop_name_2","property_critDmg","property_decritDmg"}
                for k,v in pairs(pextra) do
                    local pic=picCfg[k]
                    local name=nameCfg[k]
                    if pic and name then
                        local posX=firstPosX
                        if k%2==0 then
                            posX=cellWidth/2+20
                        end
                        local iconSp=CCSprite:createWithSpriteFrameName(pic)
                        local iconScale=iconSize/iconSp:getContentSize().width
                        iconSp:setAnchorPoint(ccp(0,1))
                        iconSp:setPosition(posX,posY-math.floor((k-1)/2)*(iconSize+10))
                        cell:addChild(iconSp,2)
                        iconSp:setScale(iconScale)
                        
                        local nameLb=GetTTFLabelWrap(getlocal(name),labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                        nameLb:setAnchorPoint(ccp(0,0))
                        nameLb:setPosition(ccp(iconSp:getPositionX()+iconSize+10,iconSp:getPositionY()-iconSize/2))
                        cell:addChild(nameLb)
                        local color=G_ColorWhite
                        if name=="accessory_prop_name_1" or name=="accessory_prop_name_2" or name=="property_critDmg" or name=="property_decritDmg" then
                            color=G_ColorGreen
                        end
                        local valueLb=GetTTFLabel(v[1],20)
                        valueLb:setAnchorPoint(ccp(0,1))
                        valueLb:setPosition(ccp(iconSp:getPositionX()+iconSize+10,iconSp:getPositionY()-iconSize/2))
                        cell:addChild(valueLb)
                        valueLb:setColor(color)
                        
                        if v[2] then
                            local addLb=GetTTFLabel("+"..v[2],20)
                            addLb:setAnchorPoint(ccp(0,1))
                            addLb:setPosition(ccp(valueLb:getPositionX()+valueLb:getContentSize().width,valueLb:getPositionY()))
                            addLb:setColor(G_ColorGreen)
                            cell:addChild(addLb)
                        end
                    end
                end
                local count=SizeOfTable(pextra)
                if count%2>0 then
                    count=math.floor(count/2)+1
                else
                    count=math.floor(count/2)
                end
                posY=posY-count*iconSize-(count-1)*10-5
            end

            local restrain = tankInfo.restrain or {} --坦克涂装的克制关系
            if restrain[1] and restrain[2] and tonumber(restrain[1])>0 and tonumber(restrain[2])>0 then
                posY = posY - 5
                local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine5.png", CCRect(4, 0, 2, 2), function ()end)
                lineSp:setAnchorPoint(ccp(0.5,0.5))
                lineSp:setPosition(cellWidth/2,posY)
                lineSp:setContentSize(CCSizeMake(cellWidth-50,2))
                cell:addChild(lineSp,2)

                posY = posY - 10 - iconSize/2

                local restrainSp = tankSkinVoApi:getSkinRestrainIconSp(id, restrainType)
                if restrainSp then
                    restrainSp:setScale(iconSize/restrainSp:getContentSize().width)
                    restrainSp:setPosition(firstPosX,posY)
                    restrainSp:setAnchorPoint(ccp(0,0.5))
                    cell:addChild(restrainSp)

                    local nameLb = GetTTFLabel(getlocal("tankSkin_restrain_name"),labelSize)
                    nameLb:setAnchorPoint(ccp(0,0.5))
                    nameLb:setPosition(firstPosX+iconSize+10,restrainSp:getPositionY())
                    cell:addChild(nameLb)

                    posY = posY - 30
                    local restrainDescStr=tankSkinVoApi:getAttributeNameStr("restrain",restrain[1]).."<rayimg>"..restrain[2].."%".."<rayimg>"
                    local restrainDescLb,lbHeight=G_getRichTextLabel(restrainDescStr,{G_ColorWhite,G_ColorGreen},labelSize-2,lbSize.width,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                    restrainDescLb:setAnchorPoint(ccp(0,1))
                    restrainDescLb:setPosition(firstPosX,posY)
                    cell:addChild(restrainDescLb,2)
                end
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
    self.tv:setPosition(ccp(0,20))
    self.detailBg:addChild(self.tv,2)
    if scrollFlag==true then
        self.tv:setMaxDisToBottomOrTop(120)
    else
        self.tv:setMaxDisToBottomOrTop(0)
    end
end