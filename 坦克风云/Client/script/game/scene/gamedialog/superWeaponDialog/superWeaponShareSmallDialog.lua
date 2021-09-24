superWeaponShareSmallDialog=shareSmallDialog:new()
function superWeaponShareSmallDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function superWeaponShareSmallDialog:showSwInfoSmallDialog(player,superWeapon,layerNum)
    local sd=superWeaponShareSmallDialog:new()
    sd:create(bgSrc,inRect,CCSizeMake(550,500),player,superWeapon,layerNum,nil,true)
end

function superWeaponShareSmallDialog:init()
    if newGuidMgr:isNewGuiding()==true then
        do
            return
        end
    end
    spriteController:addPlist("public/nbSkill.plist")
    spriteController:addTexture("public/nbSkill.png")

    local superWeapon=self.share
    local bgHeight=0
    local titleBgH=80
    bgHeight=bgHeight+titleBgH+10
    local bgWidth=550
    local cellWidth=bgWidth-40
    local lbSize=CCSize(440,0)
    local labelSize=20
    local iconSize=60
    local labelWidth=150
    local labelSize=20
    local id=superWeapon.id
    local nameStr=superWeapon.name
    local level=superWeapon.lv --超级武器等级
    local skillLv=superWeapon.s[1] --技能等级
    local lvParamStr=""
    local effectFlag=superWeapon.s[2] --是否有技能效果
    if effectFlag==1 then
        lvParamStr="(+1)"
    end
    local skillName=""
    local skillDesc=""
    local property=superWeapon.p --属性加成
    local slots=superWeapon.slots --能量结晶

    local function getCellHeight()
        local cellHeight=10
        local cfg=abilityCfg[superWeaponCfg.weaponCfg[id]["skillID"]][skillLv]
        skillName=getlocal(cfg.name).." "..getlocal("fightLevel",{skillLv})..lvParamStr

        local skillNameLb=GetTTFLabelWrap(skillName,25,CCSizeMake(cellWidth-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)

        if effectFlag==1 then
            cfg=abilityCfg[superWeaponCfg.weaponCfg[id]["skillID"]][skillLv+1]
        end
        local v1=cfg.value1
        local v2=cfg.value2
        local v3=cfg.SpTop
        if(v1 and v1<1)then
            v1=G_keepNumber(v1*100,0).."%%"
        end
        if(v2 and v2<1)then
            v2=G_keepNumber(v2*100,0).."%%"
        end
        skillDesc=getlocal(cfg.desc,{v1,v2,v3})
        local descLb=GetTTFLabelWrap(skillDesc,25,CCSizeMake(cellWidth-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)

        cellHeight=cellHeight+skillNameLb:getContentSize().height+descLb:getContentSize().height+20
        if property then
            local count=SizeOfTable(property)
            if count>0 then
                if count%2>0 then
                    count=math.floor(count/2)+1
                else
                    count=math.floor(count/2)
                end
                cellHeight=cellHeight+count*iconSize+(count-1)*10+20
            end
        end
        if slots then
            local count=SizeOfTable(slots)
            if count>0 then
                if count%2>0 then
                    count=math.floor(count/2)+1
                else
                    count=math.floor(count/2)
                end
                cellHeight=cellHeight+count*iconSize+(count-1)*10+100
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

    self.detailBg:setContentSize(CCSizeMake(cellWidth,tvHeight+20))
    bgHeight=bgHeight+self.detailBg:getContentSize().height+20

    local scale=1
    local pic=superWeaponCfg.weaponCfg[id]["icon"]
    local swIcon=CCSprite:createWithSpriteFrameName(pic)
    swIcon:setAnchorPoint(ccp(0,0.5))
    swIcon:setScale(scale)
    self.bgLayer:addChild(swIcon,2)

    local swSize=swIcon:getContentSize()
    bgHeight=bgHeight+swSize.height*scale+10
 
    local swnameStr=getlocal(superWeaponCfg.weaponCfg[id]["name"])
    local lbName=GetTTFLabelWrap(swnameStr,28,CCSizeMake(bgWidth-140,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
    lbName:setAnchorPoint(ccp(0,0))
    self.bgLayer:addChild(lbName,2)
    local hlvLb=GetTTFLabel(G_LV()..level,24)
    hlvLb:setAnchorPoint(ccp(0,1))
    self.bgLayer:addChild(hlvLb)

    self.bgLayer:setContentSize(CCSizeMake(bgWidth,bgHeight))

    swIcon:setPosition(ccp(30,bgHeight-titleBgH-swSize.height*scale*0.5-15))
    lbName:setPosition(swIcon:getPositionX()+swSize.width*scale+20,swIcon:getPositionY()+5)
    hlvLb:setPosition(ccp(lbName:getPositionX(),swIcon:getPositionY()-5))
    self.detailBg:setPosition(bgWidth/2,swIcon:getPositionY()-swSize.height*scale*0.5-10)

    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return 1
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(cellWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            local posY=cellHeight-10
            local firstPosX=20
            local skillNameLb=GetTTFLabelWrap(skillName,25,CCSizeMake(cellWidth-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            skillNameLb:setColor(G_ColorYellowPro)
            skillNameLb:setAnchorPoint(ccp(0,1))
            skillNameLb:setPosition(ccp(firstPosX,posY))
            cell:addChild(skillNameLb)
            posY=posY-skillNameLb:getContentSize().height

            local descLb=GetTTFLabelWrap(skillDesc,25,CCSizeMake(cellWidth-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            descLb:setAnchorPoint(ccp(0,1))
            descLb:setPosition(ccp(firstPosX,posY))
            cell:addChild(descLb)
            posY=posY-descLb:getContentSize().height-10

            local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
            lineSp:setAnchorPoint(ccp(0.5,1))
            lineSp:setPosition(cellWidth/2,posY)
            cell:addChild(lineSp,2)
            lineSp:setScaleX((cellWidth-50)/lineSp:getContentSize().width)

            posY=posY-20
            for k,item in pairs(property) do
                local attKey=item[1]
                local value=item[2]
                if attKey and value then
                    local posX=firstPosX
                    if k%2==0 then
                        posX=cellWidth/2+20
                    end
                    local pic=buffEffectCfg[attKey].icon
                    if(pic and pic~="")then
                        local iconSp=CCSprite:createWithSpriteFrameName(pic)
                        if(iconSp)then
                            iconSp:setScale(iconSize/iconSp:getContentSize().width)
                            iconSp:setAnchorPoint(ccp(0,1))
                            iconSp:setPosition(ccp(posX,posY-math.floor((k-1)/2)*(iconSize+10)))
                            cell:addChild(iconSp)
                            local nameStr=getlocal(buffEffectCfg[attKey].name)
                            local nameLb=GetTTFLabelWrap(nameStr,labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
                            nameLb:setAnchorPoint(ccp(0,0))
                            nameLb:setPosition(ccp(iconSp:getPositionX()+iconSize+10,iconSp:getPositionY()-iconSize/2))
                            cell:addChild(nameLb)

                            local valueLb=GetTTFLabel(value,labelSize)
                            valueLb:setAnchorPoint(ccp(0,1))
                            valueLb:setPosition(ccp(nameLb:getPositionX(),nameLb:getPositionY()))
                            cell:addChild(valueLb)
                        end
                    end
                end
            end
            local count=SizeOfTable(property)
            if count%2>0 then
                count=math.floor(count/2)+1
            else
                count=math.floor(count/2)
            end
            posY=posY-count*iconSize-(count-1)*10-10

            count=SizeOfTable(slots)
            if count>0 then
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

                titlePic="nbSkillTitle1.png"
                titleStr=getlocal("super_weapon_title_4")
                local titleSp=CCSprite:createWithSpriteFrameName(titlePic)
                titleSp:setAnchorPoint(ccp(0.5,1))
                titleSp:setPosition((cellWidth)/2,posY)
                cell:addChild(titleSp,1)
                local titleLb=GetTTFLabel(titleStr,25)
                titleLb:setAnchorPoint(ccp(0.5,1))
                titleLb:setPosition(cellWidth/2,posY-titleSp:getContentSize().height)
                cell:addChild(titleLb,1)
                posY=posY-80
                for k,item in pairs(slots) do
                    local cid=item[1]
                    local colorType=item[2]
                    local level=item[3]
                    local bgName=""
                    if colorType==1 then
                        bgName="crystalIconRedBg.png"
                    elseif colorType==2 then
                        bgName="crystalIconYellowBg.png"
                    else
                        bgName="crystalIconBlueBg.png"
                    end
                    local posX=firstPosX
                    if k%2==0 then
                        posX=cellWidth/2+20
                    end
                    local cfg=superWeaponCfg.crystalCfg[tostring(cid)]
                    if cfg then
                        local iconName=cfg.icon
                        local nameStr=getlocal(cfg.name)
                        local bgSp=CCSprite:createWithSpriteFrameName(bgName)
                        local iconSp=CCSprite:createWithSpriteFrameName(iconName)
                        iconSp:setAnchorPoint(ccp(0,0))
                        iconSp:setPosition(ccp(0,0))
                        bgSp:addChild(iconSp)
                        bgSp:setScale(iconSize/bgSp:getContentSize().height)
                        bgSp:setAnchorPoint(ccp(0,1))
                        bgSp:setPosition(ccp(posX,posY-math.floor((k-1)/2)*(iconSize+10)))
                        cell:addChild(bgSp)
                        local nameLb=GetTTFLabelWrap(nameStr,labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
                        nameLb:setAnchorPoint(ccp(0,0))
                        nameLb:setPosition(ccp(bgSp:getPositionX()+iconSize+10,bgSp:getPositionY()-iconSize/2))
                        cell:addChild(nameLb)
                        local lvLb=GetTTFLabel(getlocal("fightLevel",{level}),labelSize)
                        lvLb:setAnchorPoint(ccp(0,1))
                        lvLb:setPosition(ccp(nameLb:getPositionX(),bgSp:getPositionY()-iconSize/2))
                        cell:addChild(lvLb)
                    end
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
    self.tv:setPosition(ccp(0,10))
    self.detailBg:addChild(self.tv,2)
    if scrollFlag==true then
        self.tv:setMaxDisToBottomOrTop(120)
    else
        self.tv:setMaxDisToBottomOrTop(0)
    end
end

function superWeaponShareSmallDialog:tick()
end

function superWeaponShareSmallDialog:dispose() --释放方法
    if self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil
    end
    self.touchDialogBg=nil
    spriteController:removePlist("public/nbSkill.plist")
    spriteController:removeTexture("public/nbSkill.png")
end
