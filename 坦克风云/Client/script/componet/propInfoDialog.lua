propInfoDialog={}
function propInfoDialog:new()
    local nc={
            container,
     	   	touchDialogBg,
            isUseAmi,
            id,
          }
    setmetatable(nc,self)
    self.__index=self
    return nc
end
--container:父容器 item:物品信息  hideNum 是否隐藏数量显示 isOwn 数量是否显示成拥有数量  replaceNumStr 替换数量的文字
function propInfoDialog:create(container,item,layerNum,isUseLocal,isAddBg,addDesc,descColor,isFile,isAccOrFrag,hideNum,isOwn,isHuoxianmingjianggai,replaceNumStr,ChunjiepanshengVersion,btnName,btnHandler)
    if item.type and item.type=="pl" and item.key then --飞机的技能详情显示
        local eType=string.sub(item.key,1,1)
        if eType=="s" then
            planeVoApi:showInfoSmallDialog(item.key,layerNum+1,false)
        end
        do return end
    end
    local td=self:new()
    td:init(container,item,layerNum,isUseLocal,isAddBg,addDesc,descColor,isFile,isAccOrFrag,hideNum,isOwn,isHuoxianmingjianggai,replaceNumStr,ChunjiepanshengVersion,btnName,btnHandler)
    self.isUseAmi=true
end


function propInfoDialog:init(parent,item,layerNum,isUseLocal,isAddBg,addDesc,descColor,isFile,isAccOrFrag,hideNum,isOwn,isHuoxianmingjianggai,replaceNumStr,ChunjiepanshengVersion,btnName,btnHandler)
    local strSize2 = 23
    local isfL = true --外语
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
        strSize2 =25
        isfL = false
    end
    local function touchDialog()
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end

    local capInSet = CCRect(10, 10, 1, 1)
    local dialogBgWidth=500
    local dialogBg2Width=dialogBgWidth-40

    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg1.png",CCRect(30, 30, 1, 1),touchDialog)
    if addDesc then
        dialogBg:setContentSize(CCSizeMake(500,400))
    else
        dialogBg:setContentSize(CCSizeMake(500,350))
    end

    local lineSp1=CCSprite:createWithSpriteFrameName("rewardPanelLine.png")
    lineSp1:setAnchorPoint(ccp(0.5,1))
    lineSp1:setPosition(ccp(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height))
    dialogBg:addChild(lineSp1)
    local lineSp2=CCSprite:createWithSpriteFrameName("rewardPanelLine.png")
    lineSp2:setAnchorPoint(ccp(0.5,0))
    lineSp2:setPosition(ccp(dialogBg:getContentSize().width/2,lineSp2:getContentSize().height))
    dialogBg:addChild(lineSp2)
    lineSp2:setRotation(180)

    local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
    pointSp1:setPosition(ccp(5,dialogBg:getContentSize().height/2))
    dialogBg:addChild(pointSp1)
    local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
    pointSp2:setPosition(ccp(dialogBg:getContentSize().width-5,dialogBg:getContentSize().height/2))
    dialogBg:addChild(pointSp2)

    -- 内容
    local dialogBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ()end)
    dialogBg2:setContentSize(CCSizeMake(dialogBg2Width,dialogBg:getContentSize().height-60))
    dialogBg2:setAnchorPoint(ccp(0.5,0.5))
    dialogBg2:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height/2)
    dialogBg:addChild(dialogBg2)
    local dialogBg2Size=dialogBg2:getContentSize()

    local newLineSp = LuaCCScale9Sprite:createWithSpriteFrameName("new_cutline.png",CCRect(27,3,1,1),function ()end)
    newLineSp:setContentSize(CCSizeMake(dialogBg2Size.width-40,newLineSp:getContentSize().height))
    newLineSp:setPosition(ccp(dialogBg2Size.width/2,dialogBg2Size.height-70-50-20-newLineSp:getContentSize().height/2))
    dialogBg2:addChild(newLineSp)

    if btnName then
        local height=dialogBg:getContentSize().height
        height=height+50
        dialogBg:setContentSize(CCSizeMake(500,height))

        local function callBack( ... )
            if btnHandler then
                btnHandler()
                PlayEffect(audioCfg.mouseClick)
                self:close()
            end
        end
        local confirmItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",callBack,nil,btnName,25/0.7,11)
        confirmItem:setScale(0.7)
        confirmItem:setAnchorPoint(ccp(0.5,0))
        local confirmMenu=CCMenu:createWithItem(confirmItem)
        confirmMenu:setTouchPriority(-(layerNum-1)*20-4)
        confirmMenu:setPosition(dialogBg:getContentSize().width/2,20)
        dialogBg:addChild(confirmMenu)

        -- 修正位置
        lineSp1:setPositionY(dialogBg:getContentSize().height)
        dialogBg2:setPositionY(dialogBg2:getPositionY()+50)
    end
    self.container=dialogBg
    
    self.touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",capInSet,touchDialog);
    self.touchDialogBg:setTouchPriority(-(layerNum-1)*20-2)
    local rect1=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    self.touchDialogBg:setContentSize(rect1)
    self.touchDialogBg:setOpacity(180)
    self.touchDialogBg:setPosition(getCenterPoint(sceneGame))
    sceneGame:addChild(self.touchDialogBg,layerNum);
    
    local dialogBgHeight =dialogBg:getContentSize().height-20

    local function touch()

    end
    local spriteIcon
    local nameColor=G_ColorYellowPro
    if item.type=="w" and item.eType and item.eType=="f" then
        spriteIcon=superWeaponVoApi:getFragmentIcon(item.key,touch)
    elseif item.type=="w" and item.eType and item.eType=="c" then
        isUseLocal=true
        spriteIcon=superWeaponVoApi:getCrystalIcon(item.key,touch)
        local sbItem=superWeaponCfg.crystalCfg[item.key]
        local lvl=sbItem and sbItem.lvl or nil
        if lvl then
            if  lvl<=4 then
                nameColor=G_ColorGreen
            elseif lvl>4 and lvl<=7 then
                nameColor=G_ColorBlue3
            else
                nameColor=G_ColorPurple
            end
        end

    elseif item.type=="h" then
        spriteIcon=heroVoApi:getHeroIcon(item.key,1,false,touch)
    elseif item.type=="p" and item.equipId then
        eType=string.sub(item.equipId,1,1)
        if eType=="a" then
            spriteIcon=accessoryVoApi:getAccessoryIcon(item.equipId,nil,100,touch)
        elseif eType=="f" then
            spriteIcon=accessoryVoApi:getFragmentIcon(item.equipId,nil,100,touch)
        else
            spriteIcon = CCSprite:createWithSpriteFrameName(item.pic)
        end
    elseif item.type=="p" and propCfg[item.key] and propCfg[item.key].useGetHero then
        local heroData={h=G_clone(propCfg[item.key].useGetHero)}
        local hItmeTb=FormatItem(heroData)
        local hItme=hItmeTb[1]
        if hItme and hItme.type=="h" then
            if hItme.eType=="h" then
                local productOrder=hItme.num
                spriteIcon = heroVoApi:getHeroIcon(hItme.key,productOrder,true,touch,nil,nil,nil,{adjutants={}})
            else
                spriteIcon = heroVoApi:getHeroIcon(hItme.key,1,false,touch)
            end
        end
    elseif isAccOrFrag==true then
        if item.eType=="a" then
            spriteIcon=accessoryVoApi:getAccessoryIcon(item.id,nil,100,touch)
        elseif item.eType=="f" then
            spriteIcon=accessoryVoApi:getFragmentIcon(item.id,nil,100,touch)
        else
            spriteIcon = CCSprite:createWithSpriteFrameName(item.pic)
        end
    elseif isFile==true then
        spriteIcon = LuaCCSprite:createWithFileName(item.pic,touch)
    elseif isAddBg==true then
        --bgname：需要添加的背景框名称（结晶有用到）
        if item.bgname and item.bgname~="" then
            spriteIcon = GetBgIcon(item.pic,nil,item.bgname,80,100)
        else
            spriteIcon = GetBgIcon(item.pic,nil,nil,80,100)
        end
    else
        -- bgname：新增道具有可能会单独配置bgname
        if item.bgname and item.bgname~="" then
            spriteIcon = G_getItemIcon(item,100,false,layerNum+1,nil,nil,nil,nil,nil,ChunjiepanshengVersion)
        elseif item.type=="ac" and item.eType=="o" then --周年狂欢2019活动数字卡片
            spriteIcon = G_getItemIcon(item)
        else
            spriteIcon = CCSprite:createWithSpriteFrameName(item.pic)
        end
        
    end
    spriteIcon:setAnchorPoint(ccp(0,0.5))
    if spriteIcon:getContentSize().height>spriteIcon:getContentSize().width then
        spriteIcon:setScale(100/spriteIcon:getContentSize().height)
    else
        spriteIcon:setScale(100/spriteIcon:getContentSize().width)
    end
    spriteIcon:setPosition(30,dialogBgHeight-80)
    self.container:addChild(spriteIcon,2)
    
    local nameStr=item.name
    if item and item.type and item.type=="c" then
        nameStr=getlocal(item.name,{item.num})
    end
    if isHuoxianmingjianggai==true then
        nameStr=nameStr .. "(" .. getlocal("active_mingjiang_soul") .. ")"
    end
    local strWidth2 = 320
    if G_getCurChoseLanguage() == "ru" then
        strWidth2 = 350
    end
    local lbName=GetTTFLabelWrap(nameStr,28,CCSizeMake(strWidth2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    lbName:setPosition(140,dialogBgHeight-60)
    lbName:setAnchorPoint(ccp(0,0.5));
    self.container:addChild(lbName,2)
    lbName:setColor(nameColor)
    
    local lbNum = nil
    if replaceNumStr and replaceNumStr~="" then
        lbNum=GetTTFLabel(replaceNumStr,25)
    elseif isOwn == true then
        lbNum=GetTTFLabel(getlocal("ownedGem",{item.num}),25)
    elseif item.type == "c" then
        lbNum=GetTTFLabel(getlocal("buffLv",{item.num}),25)
    else
        if isHuoxianmingjianggai==true then
            lbNum=GetTTFLabel(getlocal("propInfoNum",{170}),25)
        else
            lbNum=GetTTFLabel(getlocal("propInfoNum",{item.num}),25)
        end
    end
    lbNum:setPosition(140,dialogBgHeight-100)
    lbNum:setAnchorPoint(ccp(0,0.5));
    self.container:addChild(lbNum,2)
    if hideNum == true then
        lbNum:setVisible(false)
    end

    local labelSize = CCSize(400, 0);
    local desc=""

    if item.eType=="c" and item.type=="w" then
        desc=item.desc
    elseif item.noLocal then
        desc=item.desc
    else
        desc=getlocal(item.desc)
    end

    if isUseLocal or (item and item.type=="w" and item.eType=="f") then
        desc=item.desc
    elseif item and item.type and item.type=="c" then
        local techCfg=checkPointVoApi:getChallengeTechCfg()
        if techCfg and item.key and techCfg[item.key] and techCfg[item.key].value then
            local valueTb=techCfg[item.key].value
            if valueTb and valueTb[item.num] then
                local percent=(valueTb[item.num]*100).."%%"
                desc=getlocal(item.desc,{percent})
            end
        end
    end

    if (tonumber(item.id) and item.id > 4819 and item.id <4828) or (tonumber(item.id) and propCfg["p"..item.id] and propCfg["p"..item.id].composeGetProp) then
        desc=getlocal(item.desc,{propCfg["p"..item.id].composeGetProp[1]})
    end

    local lbDescription=GetTTFLabelWrap(desc,strSize2,labelSize,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    lbDescription:setPosition(30,105)
    lbDescription:setAnchorPoint(ccp(0,0.5));
    self.container:addChild(lbDescription,2)
    if descColor then
        lbDescription:setColor(descColor)
    end

    local addDescLb
    if addDesc then
        local lbAddDesc=GetTTFLabelWrap(addDesc,strSize2,labelSize,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        lbAddDesc:setPosition(30,dialogBgHeight-160)
        lbAddDesc:setAnchorPoint(ccp(0,0.5))
        self.container:addChild(lbAddDesc,2)
        lbAddDesc:setColor(G_ColorYellow)
        addDescLb=lbAddDesc
    end
    if btnName then
        if addDescLb then
            lbDescription:setPosition(30,dialogBgHeight-180-addDescLb:getContentSize().height/2-lbDescription:getContentSize().height/2)
        else
            if spriteIcon and isfL ==true then
                lbDescription:setAnchorPoint(ccp(0,1))
                lbDescription:setFontSize(21)
                lbDescription:setPosition(ccp(30,dialogBgHeight-spriteIcon:getContentSize().height-35))
            else
                lbDescription:setPosition(30,dialogBgHeight-222)
            end
        end
    end

    -- 点击屏幕继续
    do
        local clickLbPosy=-80
        local tmpLb=GetTTFLabel(getlocal("click_screen_continue"),25)
        local clickLb=GetTTFLabelWrap(getlocal("click_screen_continue"),25,CCSizeMake(400,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        clickLb:setPosition(ccp(self.container:getContentSize().width/2,clickLbPosy))
        self.container:addChild(clickLb)
        local arrowPosx1,arrowPosx2
        local realWidth,maxWidth=tmpLb:getContentSize().width,clickLb:getContentSize().width
        if realWidth>maxWidth then
            arrowPosx1=self.container:getContentSize().width/2-maxWidth/2
            arrowPosx2=self.container:getContentSize().width/2+maxWidth/2
        else
            arrowPosx1=self.container:getContentSize().width/2-realWidth/2
            arrowPosx2=self.container:getContentSize().width/2+realWidth/2
        end
        local smallArrowSp1=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
        smallArrowSp1:setPosition(ccp(arrowPosx1-15,clickLbPosy))
        self.container:addChild(smallArrowSp1)
        local smallArrowSp2=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
        smallArrowSp2:setPosition(ccp(arrowPosx1-25,clickLbPosy))
        self.container:addChild(smallArrowSp2)
        smallArrowSp2:setOpacity(100)
        local smallArrowSp3=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
        smallArrowSp3:setPosition(ccp(arrowPosx2+15,clickLbPosy))
        self.container:addChild(smallArrowSp3)
        smallArrowSp3:setRotation(180)
        local smallArrowSp4=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
        smallArrowSp4:setPosition(ccp(arrowPosx2+25,clickLbPosy))
        self.container:addChild(smallArrowSp4)
        smallArrowSp4:setOpacity(100)
        smallArrowSp4:setRotation(180)

        local space=20
        smallArrowSp1:runAction(G_actionArrow(1,space))
        smallArrowSp2:runAction(G_actionArrow(1,space))
        smallArrowSp3:runAction(G_actionArrow(-1,space))
        smallArrowSp4:runAction(G_actionArrow(-1,space))
    end

    self.container:setPosition(getCenterPoint(sceneGame))
    sceneGame:addChild(self.container,layerNum+1)
    self:show()
end

--显示面板,加效果
function propInfoDialog:show()

    --if self.isUseAmi~=nil then
       local moveTo=CCMoveTo:create(0.3,CCPointMake(G_VisibleSize.width/2,G_VisibleSize.height/2))
       local function callBack()
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
       self.container:runAction(seq)
   --end
   
   table.insert(G_SmallDialogDialogTb,self)
end

function propInfoDialog:close()

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
   self.container:runAction(seq)
   else
        self:realClose()

   end
   
   
end
function propInfoDialog:realClose()
    self.container:removeFromParentAndCleanup(true)
    self.container=nil
    for k,v in pairs(G_SmallDialogDialogTb) do
        if v==self then
            v=nil
            G_SmallDialogDialogTb[k]=nil
        end
    end
end
function propInfoDialog:tick()

    
end

function propInfoDialog:dispose() --释放方法

 self.touchDialogBg=nil
    self.container=nil
    for k,v in pairs(self.pp4) do
         k=nil
         v=nil
    end

    self.have4=nil
end
