newPropShowSmallDialog=smallDialog:new()

function newPropShowSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end
--specialUse 活动或是功能特殊使用
-- specialUse = {”活动或功能名字“={放自己使用的参数},hasAni=true,useBgSp=2,useBgSpSize={},useSureOrCancleBtn=1,sureBtnStr="",cancleBtnStr=""}
-- useBgSp ：使用自己的背景，1为默认，目前加到 2 ；useBgSpSize: 图片的Rect size ; useSureOrCancleBtn：0或nil 无确定取消按钮（当前默认的效果），1确定，2取消，3确定取消按钮都有，4右上角close 5全套 6确定+close按钮 （目前没有添加相关逻辑）   逻辑没加的请自行补齐
function newPropShowSmallDialog:showPropInfo(layerNum,istouch,isuseami,callBack,propItem,hideNum,addStr,addStrColor,specialUse,isShow)
    spriteController:addPlist("public/datebaseShow.plist")
    spriteController:addTexture("public/datebaseShow.png")
    if propItem and propItem.type and propItem.type=="pl" and propItem.key then --飞机的技能详情显示
        local eType=string.sub(propItem.key,1,1)
        if eType=="s" then
            planeVoApi:showInfoSmallDialog(propItem.key,layerNum+1,false)
        end
        do return end
    elseif propItem.type=="se" then
        local cfg = emblemVoApi:getEquipCfgById(propItem.key)
        local eVo = emblemVo:new(cfg)
        if(eVo)then
            eVo:initWithData(propItem.key,0,0)
            emblemVoApi:showInfoDialog(eVo,layerNum,true)
        end
        do return end
     elseif propItem.type=="at" then
        local eType=string.sub(propItem.key,1,1)
        if eType=="a" then --AI部队
            local troopsVo = AITroopsVoApi:getMaxLvAITroopsVo(propItem.key, true)
            AITroopsVoApi:showTroopsInfoDialog(troopsVo, true, layerNum + 1)
            do return end
        end
    end
	local sd=newPropShowSmallDialog:new()
    sd:initPropInfo(layerNum,istouch,isuseami,callBack,propItem,hideNum,addStr,addStrColor,specialUse,isShow)
    return sd
end

function newPropShowSmallDialog:initPropInfo(layerNum,istouch,isuseami,pCallBack,propItem,hideNum,addStr,addStrColor,specialUse,isShow)
	
    if not isShow then
        isShow = true
    end
    self.isTouch=istouch
    self.isUseAmi=isuseami
    self.layerNum=layerNum
    self.specialUse = specialUse
    local hideNumFlag=hideNum or false
    local nameFontSize=30


    base:removeFromNeedRefresh(self) --停止刷新

    

    local function tmpFunc()
    end
    local rrect=CCRect(0, 50, 1, 1)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setTouchEnabled(true)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true)

    local function touchLuaSpr()
        if self.specialUse == nil or self.specialUse.useSureOrCancleBtn == nil then
            PlayEffect(audioCfg.mouseClick)
            if pCallBack then
            	pCallBack()
            end
            return self:close()
        end
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    -- touchDialogBg:setOpacity(180)
    touchDialogBg:setIsSallow(true)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    local dialogBgWidth=560
    local dialogBg2Width=dialogBgWidth-40
    local desStr
    if propItem.finalDesc == true then
        desStr=propItem.desc
    elseif((propItem.type=="w" and propItem.eType=="f") or (propItem.eType=="c" and propItem.type=="w"))then
      desStr=propItem.desc
    elseif propItem.noLocal then
      desStr=propItem.desc
    else
      -- if tonumber(propItem.id) and propItem.id > 4823 and propItem.id <4828 then
      if (tonumber(propItem.id) and propItem.id > 4819 and propItem.id <4828) or (tonumber(propItem.id) and propCfg["p"..propItem.id] and propCfg["p"..propItem.id].composeGetProp) then
            desStr=getlocal(propItem.desc,{propCfg["p"..propItem.id].composeGetProp[1]})
    elseif (propItem.id == 5042 or propItem.id == 5043 or propItem.id == 5044) and militaryOrdersVoApi then --军令特权钥匙
        desStr = getlocal(propItem.desc, {militaryOrdersVoApi:getItemDescParamById(propItem.id)})
      else
            desStr=getlocal(propItem.desc)
      end
    end
    -- getlocal(propItem.desc)
    local lbdesX=30
    local lbDescription=GetTTFLabelWrap(desStr,25,CCSizeMake(dialogBg2Width-lbdesX*2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    local addStrLb
    if addStr and addStr~="" then
        addStrLb=GetTTFLabelWrap(addStr,25,CCSizeMake(dialogBg2Width-lbdesX*2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    end
    local dialogBgH=200+lbDescription:getContentSize().height
    if addStrLb then
        dialogBgH=dialogBgH+addStrLb:getContentSize().height+20
    end
    dialogBgH=dialogBgH+40
    -- if dialogBgH<bgSize.height then
    --     dialogBgH=bgSize.height
    -- end
    local bgSize=CCSizeMake(560,dialogBgH)

    if self.specialUse then
        self:specialShow(bgSize)
    end

    -- rewardItem
    local function touchHandler()
    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg1.png",CCRect(30, 30, 1, 1),touchHandler)
    if self.specialUse then
        if self.specialUse.ydjl2 then
            dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),touchHandler)
        end
    end
    self.bgLayer=dialogBg
    -- self.bgLayer:setTouchPriority(-(layerNum-1)*20-2)
    self.bgLayer:setContentSize(bgSize)
    self:show()
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)

    local lineSp1=CCSprite:createWithSpriteFrameName("rewardPanelLine.png")
    lineSp1:setAnchorPoint(ccp(0.5,1))
    lineSp1:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height))
    self.bgLayer:addChild(lineSp1)
    local lineSp2=CCSprite:createWithSpriteFrameName("rewardPanelLine.png")
    lineSp2:setAnchorPoint(ccp(0.5,0))
    lineSp2:setPosition(ccp(self.bgLayer:getContentSize().width/2,lineSp2:getContentSize().height))
    self.bgLayer:addChild(lineSp2)
    lineSp2:setRotation(180)

    -- local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
    -- pointSp1:setPosition(ccp(5,self.bgLayer:getContentSize().height/2))
    -- self.bgLayer:addChild(pointSp1)
    -- local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
    -- pointSp2:setPosition(ccp(self.bgLayer:getContentSize().width-5,self.bgLayer:getContentSize().height/2))
    -- self.bgLayer:addChild(pointSp2)


    -- 内容
    local dialogBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ()end)
    dialogBg2:setContentSize(CCSizeMake(dialogBg2Width,bgSize.height-60))
    dialogBg2:setAnchorPoint(ccp(0.5,0.5))
    dialogBg2:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2)
    self.bgLayer:addChild(dialogBg2)
    local dialogBg2Size=dialogBg2:getContentSize()

    local showInfoFlag=isShow or false
    local pid=propItem.key
    local showFlag
    if(pid and propCfg[pid]) and propItem.type=="p" then
        showFlag=propCfg[pid].isShow
    else
        showFlag=0
    end
    local function showDetailDialog()
        if showFlag and showFlag==1 then
            local sbReward=G_rewardFromPropCfg(pid)
            local titleStr=getlocal(propCfg[pid].name)
            local desStr
            local random=propCfg[pid].isRandom
            if random and random==1 then
              desStr=getlocal("database_des1")
            else
              desStr=getlocal("database_des2")
            end
            if propCfg[pid].useGetOne then
                desStr=getlocal("database_des3")
            end
            local btnTb={}
            bagVoApi:showPropDisplaySmallDialog(self.layerNum+1,sbReward,titleStr,desStr,btnTb)
        end
        return false
    end
    local showHandler
    if showInfoFlag==true then
        showHandler=showDetailDialog
    end
    local icon= nil 
    if propItem.universal then--非道具使用
        if propItem.hasIcon then
            icon = propItem.icon
        else
            icon = GetBgIcon(propItem.icon,nil,propItem.bg,propItem.iconSize,propItem.bgSize)
        end
    else
        icon = G_getItemIcon(propItem,100,showInfoFlag,self.layerNum,showHandler)
    end
    
    icon:setAnchorPoint(ccp(0,0.5))
    icon:setPosition(30,dialogBg2Size.height-70)
    dialogBg2:addChild(icon)
    if showInfoFlag==true and showFlag and showFlag==1 then --显示放大镜
        icon:setTouchPriority(-(self.layerNum-1)*20-3)
        local fangdajinSp=CCSprite:createWithSpriteFrameName("datebaseShow2.png")
        fangdajinSp:setAnchorPoint(ccp(1,0))
        fangdajinSp:setPosition(icon:getContentSize().width-5,5)
        icon:addChild(fangdajinSp,2)
    end

    local nameStr=propItem.name
    local nameColor=G_ColorYellowPro
    local lbStartX=140
    local lbName=GetTTFLabelWrap(nameStr,28,CCSizeMake(dialogBg2Size.width-lbStartX-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    lbName:setPosition(lbStartX,dialogBg2Size.height-30-lbName:getContentSize().height/2)
    lbName:setAnchorPoint(ccp(0,0.5));
    dialogBg2:addChild(lbName,2)
    lbName:setColor(nameColor)

    if self.specialUse then
        self:iconAddSpInSpecial(icon)
    end

    local lbNum = nil
    if hideNumFlag==false then
        local propNum=getlocal("propInfoNum",{propItem.num})
        lbNum=GetTTFLabel(propNum,25)
        lbNum:setPosition(lbStartX,dialogBg2Size.height-110+lbNum:getContentSize().height/2)
        lbNum:setAnchorPoint(ccp(0,0.5));
        dialogBg2:addChild(lbNum,2)
    end
    if self.specialUse then
        lbName:setPositionY(lbName:getPositionY() + 20)
        lbNum:setPositionY(lbNum:getPositionY() + 20)

        self:addLbInSpecial(ccp(lbStartX,lbNum:getPositionY() - 40),dialogBg2)
    end

    local newLineSp = LuaCCScale9Sprite:createWithSpriteFrameName("new_cutline.png",CCRect(27,3,1,1),function ()end)
    newLineSp:setContentSize(CCSizeMake(dialogBg2Size.width-40,newLineSp:getContentSize().height))
    newLineSp:setPosition(ccp(dialogBg2Size.width/2,dialogBg2Size.height-70-50-20-newLineSp:getContentSize().height/2))
    dialogBg2:addChild(newLineSp)
    local posY=newLineSp:getPositionY()-newLineSp:getContentSize().height/2-14
    if addStrLb then
        posY=posY-addStrLb:getContentSize().height/2
        local strColor=addStrColor or G_ColorYellow
        addStrLb:setPosition(30,newLineSp:getPositionY()/2)
        addStrLb:setColor(strColor)
        addStrLb:setAnchorPoint(ccp(0,0.5))
        addStrLb:setPosition(30,posY)
        dialogBg2:addChild(addStrLb,2)
        posY=posY-addStrLb:getContentSize().height/2-20
    end
    lbDescription:setPosition(30,posY-lbDescription:getContentSize().height/2)
    lbDescription:setAnchorPoint(ccp(0,0.5));
    dialogBg2:addChild(lbDescription,2)

    if lbNum and lbName and icon and lbName:getContentSize().height >=icon:getContentSize().height*0.65 then
        if G_isIOS() then
            lbName:setPosition(ccp(lbName:getPositionX(),lbNum:getPositionY()+lbNum:getContentSize().height+10))
        else
            lbName:setPosition(ccp(lbName:getPositionX(),lbNum:getPositionY()+lbNum:getContentSize().height+25))
        end
    end

	-- 下面的点击屏幕继续
    if self.specialUse ==nil or self.specialUse.hasAni then
    	local clickLbPosy=-80
        local tmpLb=GetTTFLabel(getlocal("click_screen_continue"),25)
        local clickLb=GetTTFLabelWrap(getlocal("click_screen_continue"),25,CCSizeMake(400,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        clickLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,clickLbPosy))
        self.bgLayer:addChild(clickLb)
        local arrowPosx1,arrowPosx2
        local realWidth,maxWidth=tmpLb:getContentSize().width,clickLb:getContentSize().width
        if realWidth>maxWidth then
            arrowPosx1=self.bgLayer:getContentSize().width/2-maxWidth/2
            arrowPosx2=self.bgLayer:getContentSize().width/2+maxWidth/2
        else
            arrowPosx1=self.bgLayer:getContentSize().width/2-realWidth/2
            arrowPosx2=self.bgLayer:getContentSize().width/2+realWidth/2
        end
        local smallArrowSp1=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
        smallArrowSp1:setPosition(ccp(arrowPosx1-15,clickLbPosy))
        self.bgLayer:addChild(smallArrowSp1)
        local smallArrowSp2=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
        smallArrowSp2:setPosition(ccp(arrowPosx1-25,clickLbPosy))
        self.bgLayer:addChild(smallArrowSp2)
        smallArrowSp2:setOpacity(100)
        local smallArrowSp3=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
        smallArrowSp3:setPosition(ccp(arrowPosx2+15,clickLbPosy))
        self.bgLayer:addChild(smallArrowSp3)
        smallArrowSp3:setRotation(180)
        local smallArrowSp4=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
        smallArrowSp4:setPosition(ccp(arrowPosx2+25,clickLbPosy))
        self.bgLayer:addChild(smallArrowSp4)
        smallArrowSp4:setOpacity(100)
        smallArrowSp4:setRotation(180)

        local space=20
        smallArrowSp1:runAction(G_actionArrow(1,space))
        smallArrowSp2:runAction(G_actionArrow(1,space))
        smallArrowSp3:runAction(G_actionArrow(-1,space))
        smallArrowSp4:runAction(G_actionArrow(-1,space))
    end

    if self.specialUse then
        if self.specialUse.ydjl2 then
            dialogBg2:setOpacity(0)
            lineSp1:setVisible(false)
            lineSp2:setVisible(false)
        end
        self:changePosInSpecial()
    end

    sceneGame:addChild(self.dialogLayer,layerNum)
    return self.dialogLayer

end

function newPropShowSmallDialog:changePosInSpecial()
    if self.specialUse.useBgSp then
        if self.specialUse.useBgSp ==2 then
            self.bgLayer:setPositionY(self.bgLayer:getPositionY()+30)
            if self.specialUse.ydjl2 then
                local midPos = self.bgLayer:getContentSize().width*0.5

                local limitStr = GetTTFLabel(self.specialUse.ydjl2[1],25)
                limitStr:setColor(G_ColorYellowPro)
                limitStr:setAnchorPoint(ccp(0.5,1))
                limitStr:setPosition(ccp(midPos,-20))
                self.bgLayer:addChild(limitStr)
                local refreshLimit = self.specialUse.ydjl2[5] or 1
                if self.specialUse.ydjl2[3] >= refreshLimit then
                    -- limitStr:setVisible(false)
                    local graySp = GraySprite:createWithSpriteFrameName("newGrayBtn.png")
                    graySp:setScale(0.7)
                    graySp:setPosition(ccp(midPos,-30 - limitStr:getContentSize().height-25))
                    self.bgLayer:addChild(graySp)
                    local changedStr = GetTTFLabel(self.specialUse.sureBtnStr,32)
                    changedStr:setPosition(getCenterPoint(graySp))
                    graySp:addChild(changedStr)

                    
                else

                    local refreshCall = self.specialUse.ydjl2[2] or nil

                    local function touchItem(tag)
                        self:close()
                        if refreshCall then
                            refreshCall()
                        end
                    end
                    local limitItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",touchItem,2,self.specialUse.sureBtnStr,32)
                    limitItem:setAnchorPoint(ccp(0.5,0.5))
                    limitItem:setScale(0.7)
                    local limitBtn=CCMenu:createWithItem(limitItem);
                    limitBtn:setTouchPriority(-(self.layerNum-1)*20-4);
                    limitBtn:setPosition(ccp(midPos,-30 - limitStr:getContentSize().height-25))
                    self.bgLayer:addChild(limitBtn)
                end
            elseif self.specialUse.wsj2018 then
                local midPos = self.bgLayer:getContentSize().width*0.5

                local limitStr=GetTTFLabelWrap(self.specialUse.wsj2018[1],22,CCSize(self.bgLayer:getContentSize().width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                limitStr:setColor(self.specialUse.wsj2018[3])
                limitStr:setAnchorPoint(ccp(0.5,0.5))
                limitStr:setPosition(ccp(midPos,-limitStr:getContentSize().height/2-5))
                self.bgLayer:addChild(limitStr)

                if self.specialUse.wsj2018[2] then
                    local function touchItem(tag)
                        PlayEffect(audioCfg.mouseClick)
                        self:close()
                        activityAndNoteDialog:closeAllDialog()
                        vipVoApi:showRechargeDialog(self.layerNum+1)
                    end
                    local limitItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",touchItem,2,self.specialUse.sureBtnStr,32)
                    limitItem:setAnchorPoint(ccp(0.5,0.5))
                    limitItem:setScale(0.7)
                    local limitBtn=CCMenu:createWithItem(limitItem);
                    limitBtn:setTouchPriority(-(self.layerNum-1)*20-4);
                    limitBtn:setPosition(ccp(midPos,-30 - limitStr:getContentSize().height-25))
                    self.bgLayer:addChild(limitBtn)
                else
                    local unLockTip = GetTTFLabel(self.specialUse.sureBtnStr,30)
                    unLockTip:setColor(G_ColorGray)
                    unLockTip:setPosition(midPos,-30 - limitStr:getContentSize().height-25)
                    self.bgLayer:addChild(unLockTip)
                end
            end
        end
    end
end

function newPropShowSmallDialog:iconAddSpInSpecial(icon)
    if self.specialUse.ydjl2 and self.specialUse.ydjl2[4] then
          local refIcon = CCSprite:createWithSpriteFrameName("refreshIcon.png")
          refIcon:setAnchorPoint(ccp(1,1))
          refIcon:setPosition(ccp(icon:getContentSize().width-8,icon:getContentSize().height-8))
          icon:addChild(refIcon)
    end
end

function newPropShowSmallDialog:addLbInSpecial(cCp,parent)
    if self.specialUse.doubleUse then
        local costNum,halfNum = self.specialUse.costNum,self.specialUse.halfNum
        local priceStr = GetTTFLabel(getlocal("priceStr")..": ",24)
        priceStr:setAnchorPoint(ccp(0,0.5))
        priceStr:setPosition(cCp)
        parent:addChild(priceStr)

        local costStr = GetTTFLabel(costNum,24)
        costStr:setAnchorPoint(ccp(0,0.5))
        costStr:setPosition(ccp(priceStr:getPositionX() + priceStr:getContentSize().width + 10,priceStr:getPositionY()))
        parent:addChild(costStr,1)
        costStr:setColor(G_ColorRed)

        local goldIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
        goldIcon:setScale(0.8)
        goldIcon:setAnchorPoint(ccp(0,0.5))
        goldIcon:setPosition(ccp(costStr:getPositionX()+costStr:getContentSize().width + 5,priceStr:getPositionY()))
        parent:addChild(goldIcon,1)

        local rline = CCSprite:createWithSpriteFrameName("redline.jpg")
        rline:setScaleX((costStr:getContentSize().width+ 5)/ rline:getContentSize().width)
        rline:setPosition(getCenterPoint(costStr))
        costStr:addChild(rline,1)

        local costStr2 = GetTTFLabel(halfNum,24)
        costStr2:setPosition(ccp(goldIcon:getPositionX()+goldIcon:getContentSize().width + 20,priceStr:getPositionY()))
        parent:addChild(costStr2,1)

        local goldIcon2 = CCSprite:createWithSpriteFrameName("IconGold.png")
        goldIcon2:setScale(0.8)
        goldIcon2:setPosition(ccp(costStr2:getPositionX()+costStr2:getContentSize().width,priceStr:getPositionY()))
        parent:addChild(goldIcon2,1)
    end
end

function newPropShowSmallDialog:specialShow(bgSize)
    if self.specialUse.useBgSp then

        if self.specialUse.useBgSp ==2 then
            local function closeCall( )
                -- self.specialUse = nil
                -- self.baseDialog = nil
                return self:close()
            end
            self.baseDialog = G_getNewDialogBg(CCSizeMake(bgSize.width+20,bgSize.height+200),getlocal("playerInfo"),30,nil,self.layerNum+1,true,closeCall)
            self.dialogLayer:addChild(self.baseDialog,1)
            self.baseDialog:setPosition(getCenterPoint(self.dialogLayer))
        end

    end
end

function newPropShowSmallDialog:dispose()
    spriteController:removePlist("public/datebaseShow.plist")
    spriteController:removeTexture("public/datebaseShow.png")
end