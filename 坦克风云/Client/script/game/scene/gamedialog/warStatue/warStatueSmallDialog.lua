warStatueSmallDialog=smallDialog:new()

function warStatueSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function warStatueSmallDialog:showHeroBuffDialog(sid,hid,layerNum,callback)
    local function addPlist()
        spriteController:addPlist("public/youhuaUI3.plist")
        spriteController:addTexture("public/youhuaUI3.png")
    end
    G_addResource8888(addPlist)
	local dialog=warStatueSmallDialog:new()
	dialog:initHeroBuffDialog(sid,hid,layerNum,callback)
	return dialog
end

function warStatueSmallDialog:showUpgradeBuffDialog(lastStatueVo,statueVo,layerNum,callback)
    spriteController:addPlist("public/vipFinal.plist")
    spriteController:addTexture("public/vipFinal.plist")
	local dialog=warStatueSmallDialog:new()
	dialog:initUpgradeBuffDialog(lastStatueVo,statueVo,layerNum,callback)
	return dialog
end

function warStatueSmallDialog:initHeroBuffDialog(sid,hid,layerNum,callback)
	self.isTouch=false
    self.isUseAmi=true
    self.layerNum=layerNum

    local dialogWidth,dialogHeight=560,200
    local scfg=statueCfg.arr1[sid]
    local heroBuffCfg=scfg[hid]

    local statueList=warStatueVoApi:getStatueList()
    local statueVo=statueList[sid]
    local colorLv=statueVo.hero[hid] or 0

    local labelWidth,labelSize,iconHeight=dialogWidth-40,24,70
    local buffDescLb1=GetTTFLabelWrap(getlocal("heroColorBuffEffectStr1"),labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    local buffDescLb2=GetTTFLabelWrap(getlocal("heroColorBuffEffectStr2"),labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    dialogHeight=dialogHeight+buffDescLb1:getContentSize().height+buffDescLb2:getContentSize().height+80+2*iconHeight

    local function close()
    	self:close()
        spriteController:removePlist("public/youhuaUI3.plist")
        spriteController:removeTexture("public/youhuaUI3.png")
    end
    self.bgSize=CCSizeMake(dialogWidth,dialogHeight)

    local dialogBg=G_getNewDialogBg(self.bgSize,getlocal("heroColorBuffTitle"),30,nil,self.layerNum,true,close)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.bgLayer=dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self:show()

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)
    self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)

    buffDescLb1:setAnchorPoint(ccp(0,0.5))
    buffDescLb2:setAnchorPoint(ccp(0,0.5))
    buffDescLb1:setPosition(20,dialogHeight-buffDescLb1:getContentSize().height/2-86)
    buffDescLb2:setPosition(20,buffDescLb1:getPositionY()-buffDescLb1:getContentSize().height/2-buffDescLb2:getContentSize().height/2-iconHeight-40)
    self.bgLayer:addChild(buffDescLb1)
    self.bgLayer:addChild(buffDescLb2)


    local spaceW=30
    local firstPosX=(self.bgSize.width-5*iconHeight-4*spaceW)*0.5
    for k,v in pairs(heroBuffCfg) do
       for kk,buffValue in pairs(v) do
            local posY=0
            if kk==1 then
                posY=buffDescLb1:getPositionY()-iconHeight*0.5-buffDescLb1:getContentSize().height*0.5-20
            else
                posY=buffDescLb2:getPositionY()-iconHeight*0.5-buffDescLb2:getContentSize().height*0.5-20
            end
            local iconSp=CCSprite:createWithSpriteFrameName("warstatue_star"..k..".png")
            iconSp:setPosition(firstPosX+(2*k-1)*iconHeight*0.5+(k-1)*spaceW,posY)
            local maxScale1=iconHeight/iconSp:getContentSize().height
            local minScale1=0.9*maxScale1
            iconSp:setScale(minScale1)
            self.bgLayer:addChild(iconSp)

            local buffColor=G_ColorWhite
            if k==colorLv then
                local lightSp=CCSprite:createWithSpriteFrameName("warstatue_star.png")
                lightSp:setPosition(iconSp:getPosition())
                local maxScale2=(iconHeight+6)/lightSp:getContentSize().height
                local minScale2=0.9*maxScale2
                lightSp:setScale(minScale2)
                lightSp:setOpacity(0)
                self.bgLayer:addChild(lightSp)
                local blendFunc=ccBlendFunc:new()
                blendFunc.src=GL_SRC_ALPHA
                blendFunc.dst=GL_ONE
                lightSp:setBlendFunc(blendFunc)

                local at=0.5
                local acArr=CCArray:create()
                local fadeTo1=CCFadeTo:create(at,140)
                local fadeTo2=CCFadeTo:create(at,0)
                acArr:addObject(fadeTo1)
                acArr:addObject(fadeTo2)
                local seq=CCSequence:create(acArr)
                local repeatAc=CCRepeatForever:create(seq)
                lightSp:runAction(repeatAc)

                for i=1,2 do
                    local actionSp=lightSp
                    local maxScale,minScale=maxScale2,minScale2
                    if i==1 then
                        actionSp=iconSp
                        maxScale,minScale=maxScale1,minScale1
                    end
                    local acArr=CCArray:create()
                    local scaleTo1=CCScaleTo:create(at,maxScale)
                    local scaleTo2=CCScaleTo:create(at,minScale)
                    acArr:addObject(scaleTo1)
                    acArr:addObject(scaleTo2)
                    local seq=CCSequence:create(acArr)
                    local repeatAc=CCRepeatForever:create(seq)
                    actionSp:runAction(repeatAc)
                end
                buffColor=G_ColorGreen
            end

            local buffLb=GetTTFLabel((buffValue*100).."%",18)
            local buffBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function () end)
            buffBg:setContentSize(CCSizeMake(iconHeight,buffLb:getContentSize().height+2))
            buffBg:setOpacity(150)
            buffBg:setPosition(iconSp:getPosition())

            self.bgLayer:addChild(buffBg,3)
            buffLb:setPosition(getCenterPoint(buffBg))
            buffLb:setColor(buffColor)
            buffBg:addChild(buffLb)
       end
    end

	
	local priority=-(self.layerNum-1)*20-4
    local btnScale=0.8
    local confirmBtnPos=ccp(self.bgSize.width/2,60)
    if colorLv<statueCfg.openStatue then
        local function goHandler() --跳转将领详情页面
            G_goToDialog2("hero",self.layerNum+1,false,nil,hid,"heroinfo")
        end
        local upgradeHeroBtn=G_createBotton(self.bgLayer,ccp(self.bgSize.width/2-120,60),{getlocal("breakthrough")},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",goHandler,btnScale,priority)
        confirmBtnPos=ccp(self.bgSize.width/2+120,60)
    end

    local function confirm()
        close()
    end
    local confirmBtn=G_createBotton(self.bgLayer,confirmBtnPos,{getlocal("confirm")},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",confirm,btnScale,priority)

    local function touchLuaSpr()
    end
    local touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchLuaSpr)
    touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    sceneGame:addChild(self.dialogLayer,self.layerNum)
    self.dialogLayer:setPosition(ccp(0,0))
end

function warStatueSmallDialog:initUpgradeBuffDialog(lastStatueVo,statueVo,layerNum,callback)
	self.isTouch=true
    self.isUseAmi=true
    self.layerNum=layerNum

    local dialogWidth,dialogHeight=560,90
    local buffDetailTb={}

    local sid=statueVo.sid
    local buffCfg,heroBuffCfg=statueCfg.skill[sid],statueCfg.arr1[sid]
    
    local lastBuffLv=warStatueVoApi:getWarStatueBuffLv(nil,lastStatueVo)
    local buffLv=warStatueVoApi:getWarStatueBuffLv(nil,statueVo)
    local lastBuff,curBuff=G_clone((buffCfg[lastBuffLv] or {})),G_clone((buffCfg[buffLv] or {}))
    if lastBuff.dmg and lastBuff.dmg>0 then
        lastBuff.dmage=lastBuff.dmg --攻击转换成伤害显示
        lastBuff.dmg=0
    end
    if curBuff.dmg and curBuff.dmg>0 then
        curBuff.dmage=curBuff.dmg --攻击转换成伤害显示
        curBuff.dmg=0
    end
    for hid,lv in pairs(lastStatueVo.hero) do
        local cfg=heroBuffCfg[hid][lv] or {0,0}
        lastBuff.dmg,lastBuff.maxhp=(lastBuff.dmg or 0)+cfg[1],(lastBuff.maxhp or 0)+cfg[2]
    end
    for hid,lv in pairs(statueVo.hero) do
        local cfg=heroBuffCfg[hid][lv] or {0,0}
        curBuff.dmg,curBuff.maxhp=(curBuff.dmg or 0)+cfg[1],(curBuff.maxhp or 0)+cfg[2]
    end

    for k,v in pairs(curBuff) do
        local lastValue=lastBuff[k] or 0
        if tonumber(lastValue)<tonumber(v) then
            local buffDescStr=warStatueVoApi:getBuffDesc(k,lastValue)
            local upgradeValueStr=warStatueVoApi:getBuffDesc(k,v,true)
            local strWidth = 100
            if G_getCurChoseLanguage() == "ar" then
                strWidth = 350
            end
            local descLb=GetTTFLabelWrap(buffDescStr,22,CCSizeMake(dialogWidth-strWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            local upgradeValueLb=GetTTFLabel(upgradeValueStr,22)

            local buffId=buffKeyMatchCodeCfg[k]
            local buffShowCfg=buffEffectCfg[buffId]
            local sortId=buffShowCfg.index
            buffDetailTb[sortId]={descLb,upgradeValueLb}

            dialogHeight=dialogHeight+descLb:getContentSize().height+30
        end
    end
    dialogHeight=dialogHeight+60

    local function close()
        self:close()
        if callback then
            callback()
        end
        spriteController:removePlist("public/vipFinal.plist")
        spriteController:removeTexture("public/vipFinal.plist")
    end
    self.bgSize=CCSizeMake(dialogWidth,dialogHeight)
    local dialogBg=G_getNewDialogBg(self.bgSize,getlocal("upgradeEffectStr"),30,nil,self.layerNum,true,close)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.bgLayer=dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self:show()

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)
    self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)

    local dialogBg2=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ()end)
    dialogBg2:setContentSize(CCSizeMake(dialogWidth-40,dialogHeight-150))
    dialogBg2:setPosition(dialogWidth/2,30+(dialogHeight-120)/2)
    self.bgLayer:addChild(dialogBg2)

    local posY=dialogBg2:getContentSize().height-15
	for k,v in pairs(buffDetailTb) do
        local descLb,upgradeValueLb=v[1],v[2]
        descLb:setAnchorPoint(ccp(0,0.5))
        descLb:setPosition(20,posY-descLb:getContentSize().height/2)
        dialogBg2:addChild(descLb)

        local upArrowSp=CCSprite:createWithSpriteFrameName("vipUpArrow.png")
        upArrowSp:setPosition(ccp(dialogBg2:getContentSize().width-110,descLb:getPositionY()))
        dialogBg2:addChild(upArrowSp)

        upgradeValueLb:setAnchorPoint(ccp(0,0.5))
        upgradeValueLb:setPosition(dialogBg2:getContentSize().width-80,descLb:getPositionY())
        upgradeValueLb:setColor(G_ColorGreen)
        dialogBg2:addChild(upgradeValueLb)

        posY=posY-descLb:getContentSize().height-30
    end

    local function touchLuaSpr()
    end
    local touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchLuaSpr)
    touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    sceneGame:addChild(self.dialogLayer,self.layerNum)
    self.dialogLayer:setPosition(ccp(0,0))
end

function warStatueSmallDialog:dispose()

end