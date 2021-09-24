ltzdzPlayerInfoSmallDialog=smallDialog:new()

function ltzdzPlayerInfoSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
    nc.allTabs={}
	return nc
end

-- alreadyUseIdTb 已经激活的坦克id 20005,30005
function ltzdzPlayerInfoSmallDialog:showInfo(layerNum,istouch,isuseami,callBack,titleStr,infoTb)
	local sd=ltzdzPlayerInfoSmallDialog:new()
    sd:initInfo(layerNum,istouch,isuseami,callBack,titleStr,infoTb)
    return sd
end

function ltzdzPlayerInfoSmallDialog:initInfo(layerNum,istouch,isuseami,pCallBack,titleStr,infoTb)
	self.isTouch=istouch
    self.isUseAmi=isuseami
    self.layerNum=layerNum

    ltzdzVoApi:addOrRemoveOpenDialog(1,"ltzdzPlayerInfoSmallDialog",self)


    base:removeFromNeedRefresh(self) --停止刷新

    local function tmpFunc()
    end
    local rrect=CCRect(0, 50, 1, 1)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setTouchEnabled(true)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true)

     local function touchLuaSpr()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
        
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    -- touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    local bgSize=CCSizeMake(600,480)

    local function closeFunc()
        self:close()
    end
    local dialogBg=G_getNewDialogBg(bgSize,titleStr,25,nil,self.layerNum,false,closeFunc,nil)
    self.dialogLayer:addChild(dialogBg,2)
    dialogBg:setTouchPriority(-(layerNum-1)*20-1)
    dialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.bgLayer=dialogBg

    -- 头像
    local startH=self.bgLayer:getContentSize().height-70-70
    local childTb={}
    local photoName=playerVoApi:getPersonPhotoName(infoTb.pic)
    table.insert(childTb,{pic=photoName,order=2,tag=2,size=90})
    table.insert(childTb,{pic="icon_bg_gray.png",order=1,tag=1,size=100})
    local function nilFunc()
       
    end
    local composeIcon=G_getComposeIcon(nilFunc,CCSizeMake(100,100),childTb)
    composeIcon:setPosition(70,startH)
    self.bgLayer:addChild(composeIcon)
    composeIcon:setTouchPriority(-(self.layerNum-1)*20-2)

    local nameLb=GetTTFLabel(infoTb.nickname,25)
    self.bgLayer:addChild(nameLb)
    nameLb:setAnchorPoint(ccp(0,0.5))
    nameLb:setPosition(140,startH+30)
    -- nameLb:setColor(G_ColorYellowPro)

    local rpoint=tonumber(infoTb.rpoint or 0)
    local seg,smallLevel=ltzdzVoApi:getSegByLevel(rpoint)
    local segName=ltzdzVoApi:getSegName(seg,smallLevel)
    local segLb=GetTTFLabel(segName,22)
    self.bgLayer:addChild(segLb)
    segLb:setAnchorPoint(ccp(0,0.5))
    segLb:setPosition(140,startH-30)
    segLb:setColor(G_ColorYellowPro)

    startH=startH-80
    local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("new_cutline.png",CCRect(27,3,1,1),function ()end)
    lineSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,lineSp:getContentSize().height))
    lineSp:setPosition(self.bgLayer:getContentSize().width/2,startH)
    self.bgLayer:addChild(lineSp)

    startH=startH-40
    local startW1=20
    local startW2=200
    local fightLb=GetTTFLabelWrap(getlocal("ltzdz_fight"),22,CCSizeMake(startW2-startW1,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    -- GetTTFLabel(getlocal("ltzdz_fight"),22)
    fightLb:setAnchorPoint(ccp(0,0.5))
    self.bgLayer:addChild(fightLb)
    fightLb:setPosition(startW1,startH)
    fightLb:setColor(G_ColorGreen)

    local fightNum=GetTTFLabelWrap(FormatNumber(infoTb.fc),22,CCSizeMake(180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    fightNum:setAnchorPoint(ccp(0,0.5))
    fightNum:setPosition(startW2,startH)
    self.bgLayer:addChild(fightNum)

    startH=startH-50
    local serverLb=GetTTFLabelWrap(getlocal("serverWarLocal_server",{""}),22,CCSizeMake(startW2-startW1,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    -- GetTTFLabel(getlocal("ltzdz_fight"),22)
    serverLb:setAnchorPoint(ccp(0,0.5))
    self.bgLayer:addChild(serverLb)
    serverLb:setPosition(startW1,startH)
    serverLb:setColor(G_ColorGreen)

    local zid=infoTb.zid or base.curZoneID
    local serverNum=GetTTFLabelWrap(GetServerNameByID(zid),22,CCSizeMake(180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    serverNum:setAnchorPoint(ccp(0,0.5))
    serverNum:setPosition(startW2,startH)
    self.bgLayer:addChild(serverNum)

    startH=startH-50
    local recordLb=GetTTFLabelWrap(getlocal("ltzdz_record"),22,CCSizeMake(startW2-startW1,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    -- GetTTFLabel(getlocal("ltzdz_fight"),22)
    recordLb:setAnchorPoint(ccp(0,0.5))
    self.bgLayer:addChild(recordLb)
    recordLb:setPosition(startW1,startH)
    recordLb:setColor(G_ColorGreen)

    local recordNum=GetTTFLabelWrap(getlocal("ltzdz_record_des",{infoTb.record[1] or 0,infoTb.record[3] or 0,infoTb.record[2] or 0}),22,CCSizeMake(180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    recordNum:setAnchorPoint(ccp(0,0.5))
    recordNum:setPosition(startW2,startH)
    self.bgLayer:addChild(recordNum)

    startH=startH-50
    local forceLb=GetTTFLabelWrap(getlocal("ltzdz_defeated_force"),22,CCSizeMake(startW2-startW1,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    -- GetTTFLabel(getlocal("ltzdz_fight"),22)
    forceLb:setAnchorPoint(ccp(0,0.5))
    self.bgLayer:addChild(forceLb)
    forceLb:setPosition(startW1,startH)
    forceLb:setColor(G_ColorGreen)

    local forceNum=GetTTFLabelWrap(infoTb.defeat or 0,22,CCSizeMake(180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    forceNum:setAnchorPoint(ccp(0,0.5))
    forceNum:setPosition(startW2,startH)
    self.bgLayer:addChild(forceNum)

    -- 常用部队
    local dialogBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ()end)
    dialogBg2:setContentSize(CCSizeMake(200,200))
    dialogBg2:setAnchorPoint(ccp(0.5,0.5))
    dialogBg2:setPosition(self.bgLayer:getContentSize().width-120,startH+50+15)
    self.bgLayer:addChild(dialogBg2)

    -- 标题
    local commonLb=GetTTFLabelWrap(getlocal("ltzdz_common_troop"),22,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
    -- GetTTFLabel(getlocal("ltzdz_fight"),22)
    commonLb:setAnchorPoint(ccp(0.5,0))
    dialogBg2:addChild(commonLb,2)
    commonLb:setPosition(dialogBg2:getContentSize().width/2,dialogBg2:getContentSize().height-commonLb:getContentSize().height-5)

    local lightSp=CCSprite:createWithSpriteFrameName("newGreenFadeLight.png")
    lightSp:setAnchorPoint(ccp(0.5,0))
    lightSp:setScaleX(180/lightSp:getContentSize().width)
    lightSp:setPosition(dialogBg2:getContentSize().width/2,commonLb:getPositionY())
    dialogBg2:addChild(lightSp)

    if infoTb.most and infoTb.most~="" then
        -- -- 展示坦克
        print("infoTb.most------->>>",infoTb.most)
        local skinId = 0
        if tonumber(infoTb.uid)==tonumber(playerVoApi:getUid()) then --只有自己做一下坦克涂装的处理
            skinId = ltzdzFightApi:getSkinIdByTankId(infoTb.most)
        end
        local tankSp=G_addTankById(infoTb.most,nil,nil,true,dialogBg2,skinId)
        -- G_addTankById(clancrossinfo.most)
        dialogBg2:addChild(tankSp)
        -- tankSp:setPosition(dialogBg2:getContentSize().width/2,dialogBg2:getContentSize().height/2)
        local id = tonumber(infoTb.most) and tonumber(infoTb.most) or tonumber(RemoveFirstChar(infoTb.most))
        if id~=G_pickedList(id) then
            local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
            tankSp:addChild(pickedIcon)
            pickedIcon:setPosition(tankSp:getContentSize().width-30,30)
            pickedIcon:setScale(1.5)
        end
    else
        -- 无
        local noneLb=GetTTFLabelWrap(getlocal("alliance_scene_info_null"),25,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        -- GetTTFLabel(getlocal("ltzdz_fight"),22)
        noneLb:setAnchorPoint(ccp(0.5,0.5))
        dialogBg2:addChild(noneLb,2)
        noneLb:setPosition(dialogBg2:getContentSize().width/2,dialogBg2:getContentSize().height/2)
    end




    -- 下面的点击屏幕继续
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


    

    sceneGame:addChild(self.dialogLayer,layerNum)
    return self.dialogLayer
end

function ltzdzPlayerInfoSmallDialog:dispose()
    ltzdzVoApi:addOrRemoveOpenDialog(2,"ltzdzPlayerInfoSmallDialog")
end


