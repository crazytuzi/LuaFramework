ltzdzPlayerInfoDialog = commonDialog:new()

function ltzdzPlayerInfoDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.layerNum=layerNum
    -- spriteController:addPlist("public/acAnniversary.plist")
    -- spriteController:addTexture("public/acAnniversary.png")
    return nc
end

function ltzdzPlayerInfoDialog:resetTab()
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
	self.panelLineBg:setContentSize(CCSizeMake(620,G_VisibleSize.height-100))
end

function ltzdzPlayerInfoDialog:initTableView( )
end

function ltzdzPlayerInfoDialog:doUserHandler()
	local startH=self.bgLayer:getContentSize().height-90-70
    local childTb={}
    local photoName=playerVoApi:getPersonPhotoName()
    table.insert(childTb,{pic=photoName,order=2,tag=2,size=90})
    table.insert(childTb,{pic="icon_bg_gray.png",order=1,tag=1,size=100})
    local function nilFunc()
       
    end
    local composeIcon=G_getComposeIcon(nilFunc,CCSizeMake(100,100),childTb)
    composeIcon:setPosition(70,startH)
    self.bgLayer:addChild(composeIcon)
    composeIcon:setTouchPriority(-(self.layerNum-1)*20-2)

    local nameStr=playerVoApi:getPlayerName()
    local nameLb=GetTTFLabel(nameStr,25)
    self.bgLayer:addChild(nameLb)
    nameLb:setAnchorPoint(ccp(0,0.5))
    nameLb:setPosition(140,startH+30)

    local clancrossinfo=ltzdzVoApi.clancrossinfo or {}
    local rpoint=tonumber(clancrossinfo.rpoint or 0)
    local seg,smallLevel,totalSeg=ltzdzVoApi:getSegByLevel(rpoint)
    local segName=ltzdzVoApi:getSegName(seg,smallLevel)
    local segLb=GetTTFLabel(segName,22)
    self.bgLayer:addChild(segLb)
    segLb:setAnchorPoint(ccp(0,0.5))
    segLb:setPosition(140,startH-30)
    segLb:setColor(G_ColorYellowPro)

    local function onShare()
        if G_checkClickEnable()==false then
            do
                return
            end
        end
        PlayEffect(audioCfg.mouseClick)

        local share={}
        share.pic=playerVoApi:getPic() or 1
        share.nickname=playerVoApi:getPlayerName()
        share.rpoint=clancrossinfo.rpoint or 0
        share.fc=playerVoApi:getPlayerPower()
        share.record=clancrossinfo.record or {}
        share.defeat=clancrossinfo.defeat or 0
        share.most=clancrossinfo.most
        share.stype=5
        share.titleStr=getlocal("ltzdz_compete_file")
        

        local message=getlocal("ltzdz_share_des")
        local tipStr=getlocal("shareSuccess")
        G_shareHandler(share,message,tipStr,self.layerNum+1)
    end
    local shareItem=GetButtonItem("newShareBtn.png","newShareBtn_Down.png","newShareBtn_Down.png",onShare)
    local shareBtn=CCMenu:createWithItem(shareItem)
    shareBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    shareBtn:setPosition(G_VisibleSizeWidth-63,startH)
    self.bgLayer:addChild(shareBtn)

    local centerH=startH-70
    local function nilFunc()
    end
    local centerSp =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),nilFunc)
    centerSp:setContentSize(CCSizeMake(G_VisibleSize.width-40,centerH-100))
    self.bgLayer:addChild(centerSp)
    centerSp:setAnchorPoint(ccp(0.5,1))
    -- centerSp:setPosition(0,0) 
    centerSp:setPosition(self.bgLayer:getContentSize().width/2,centerH)
    centerSp:setTouchPriority(-(self.layerNum-1)*20-1)

    local centerSize=centerSp:getContentSize()
    local titleFontSize,descFontSize=22,20

    local title1H=centerSize.height
	local  titleBg1=LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,16,1,1),nilFunc)
	titleBg1:setAnchorPoint(ccp(0,1))
	titleBg1:setPosition(5,title1H-2)
	titleBg1:setContentSize(CCSizeMake(500,titleBg1:getContentSize().height))
	centerSp:addChild(titleBg1)

    local clancrossinfo=ltzdzVoApi.clancrossinfo
    local season=clancrossinfo.season
	local titleLb=GetTTFLabel(getlocal("ltzdz_season",{season}),titleFontSize)
	titleLb:setAnchorPoint(ccp(0,0.5))
	titleLb:setPosition(ccp(15,titleBg1:getContentSize().height/2))
	titleBg1:addChild(titleLb,1)

	local content1H=title1H-titleBg1:getContentSize().height-40
    local startW1=20
    local startW2=200
    local fightLb=GetTTFLabelWrap(getlocal("ltzdz_fight"),descFontSize,CCSizeMake(startW2-startW1,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    -- GetTTFLabel(getlocal("ltzdz_fight"),22)
    fightLb:setAnchorPoint(ccp(0,0.5))
    centerSp:addChild(fightLb)
    fightLb:setPosition(startW1,content1H)
    fightLb:setColor(G_ColorGreen)

    local fightNum=GetTTFLabelWrap(FormatNumber(playerVoApi:getPlayerPower()),descFontSize,CCSizeMake(180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    fightNum:setAnchorPoint(ccp(0,0.5))
    fightNum:setPosition(startW2,content1H)
    centerSp:addChild(fightNum)

    content1H=content1H-50
    local serverLb=GetTTFLabelWrap(getlocal("serverWarLocal_server",{""}),descFontSize,CCSizeMake(startW2-startW1,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    -- GetTTFLabel(getlocal("ltzdz_fight"),22)
    serverLb:setAnchorPoint(ccp(0,0.5))
    centerSp:addChild(serverLb)
    serverLb:setPosition(startW1,content1H)
    serverLb:setColor(G_ColorGreen)

    local serverNum=GetTTFLabelWrap(GetServerNameByID(base.curZoneID),descFontSize,CCSizeMake(180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    serverNum:setAnchorPoint(ccp(0,0.5))
    serverNum:setPosition(startW2,content1H)
    centerSp:addChild(serverNum)

    content1H=content1H-50
    local recordLb=GetTTFLabelWrap(getlocal("ltzdz_record"),descFontSize,CCSizeMake(startW2-startW1,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    -- GetTTFLabel(getlocal("ltzdz_fight"),22)
    recordLb:setAnchorPoint(ccp(0,0.5))
    centerSp:addChild(recordLb)
    recordLb:setPosition(startW1,content1H)
    recordLb:setColor(G_ColorGreen)

    local record=clancrossinfo.record or {}
    local recordNum=GetTTFLabelWrap(getlocal("ltzdz_record_des",{record[1] or 0,record[3] or 0,record[2] or 0}),descFontSize,CCSizeMake(180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    recordNum:setAnchorPoint(ccp(0,0.5))
    recordNum:setPosition(startW2,content1H)
    centerSp:addChild(recordNum)

    content1H=content1H-50
    local forceLb=GetTTFLabelWrap(getlocal("ltzdz_defeated_force"),descFontSize,CCSizeMake(startW2-startW1,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    -- GetTTFLabel(getlocal("ltzdz_fight"),22)
    forceLb:setAnchorPoint(ccp(0,0.5))
    centerSp:addChild(forceLb)
    forceLb:setPosition(startW1,content1H)
    forceLb:setColor(G_ColorGreen)

    local defeat=clancrossinfo.defeat or 0
    local forceNum=GetTTFLabelWrap(defeat or 0,descFontSize,CCSizeMake(180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    forceNum:setAnchorPoint(ccp(0,0.5))
    forceNum:setPosition(startW2,content1H)
    centerSp:addChild(forceNum)

    -- 常用部队
    local dialogBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ()end)
    dialogBg2:setContentSize(CCSizeMake(200,200))
    dialogBg2:setAnchorPoint(ccp(0.5,0.5))
    dialogBg2:setPosition(centerSize.width-120,content1H+50+15)
    centerSp:addChild(dialogBg2)

    -- 标题
    local commonLb=GetTTFLabelWrap(getlocal("ltzdz_common_troop"),descFontSize,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
    -- GetTTFLabel(getlocal("ltzdz_fight"),22)
    commonLb:setAnchorPoint(ccp(0.5,0))
    dialogBg2:addChild(commonLb,2)
    commonLb:setPosition(dialogBg2:getContentSize().width/2,dialogBg2:getContentSize().height-commonLb:getContentSize().height-5)

    local lightSp=CCSprite:createWithSpriteFrameName("newGreenFadeLight.png")
    lightSp:setAnchorPoint(ccp(0.5,0))
    lightSp:setScaleX(180/lightSp:getContentSize().width)
    lightSp:setPosition(dialogBg2:getContentSize().width/2,commonLb:getPositionY())
    dialogBg2:addChild(lightSp)

    if clancrossinfo.most and clancrossinfo.most~="" then
        -- -- 展示坦克
        local tankSp=G_addTankById(clancrossinfo.most,nil,nil,true,dialogBg2)
        dialogBg2:addChild(tankSp)
        -- tankSp:setPosition(dialogBg2:getContentSize().width/2,dialogBg2:getContentSize().height/2)
        local id = tonumber(clancrossinfo.most) and tonumber(clancrossinfo.most) or tonumber(RemoveFirstChar(clancrossinfo.most))
        if id~=G_pickedList(id) then
            local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
            tankSp:addChild(pickedIcon)
            pickedIcon:setPosition(tankSp:getContentSize().width-30,30)
            pickedIcon:setScale(1.5)
        end
    else
        -- 无
        local noneLb=GetTTFLabelWrap(getlocal("alliance_scene_info_null"),descFontSize,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        -- GetTTFLabel(getlocal("ltzdz_fight"),22)
        noneLb:setAnchorPoint(ccp(0.5,0.5))
        dialogBg2:addChild(noneLb,2)
        noneLb:setPosition(dialogBg2:getContentSize().width/2,dialogBg2:getContentSize().height/2)
    end

    -- 第二个标题
    local title2H=content1H-50
	local  titleBg2=LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,16,1,1),nilFunc)
	titleBg2:setAnchorPoint(ccp(0,1))
	titleBg2:setPosition(5,title2H-2)
	titleBg2:setContentSize(CCSizeMake(500,titleBg2:getContentSize().height))
	centerSp:addChild(titleBg2)

	local titleLb2=GetTTFLabel(getlocal("ltzdz_segment_detail"),titleFontSize)
	titleLb2:setAnchorPoint(ccp(0,0.5))
	titleLb2:setPosition(ccp(15,titleBg2:getContentSize().height/2))
	titleBg2:addChild(titleLb2,1)

	local content2H=title2H-titleBg2:getContentSize().height-40
	local segLb2=GetTTFLabel(segName,titleFontSize)
    centerSp:addChild(segLb2)
    segLb2:setAnchorPoint(ccp(0,0.5))
    segLb2:setPosition(startW1,content2H)
    segLb2:setColor(G_ColorYellowPro)

    content2H=content2H-50
    local colorTab={G_ColorWhite,G_ColorYellowPro}
    local resBuff=ltzdzFightApi:getTitleBuff(segment,1)
    if resBuff>0 then
        local segDes1Lb=G_getRichTextLabel(getlocal("ltzdz_seg_des1",{resBuff*100}),colorTab,descFontSize,500,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,0)
        centerSp:addChild(segDes1Lb)
        segDes1Lb:setAnchorPoint(ccp(0,0.5))
        segDes1Lb:setPosition(startW1,content2H)

        content2H=content2H-50
        local segDes2Lb=G_getRichTextLabel(getlocal("ltzdz_seg_des2",{resBuff*100}),colorTab,descFontSize,500,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,0)
        centerSp:addChild(segDes2Lb)
        segDes2Lb:setAnchorPoint(ccp(0,0.5))
        segDes2Lb:setPosition(startW1,content2H)

        content2H=content2H-50
    end

    local function touchOtherInfo()
        ltzdzVoApi:showSegmentInfoDialog(self.layerNum+1)
    end
    local otherSegItem,otherSegBtn=G_createBotton(centerSp,ccp(centerSp:getContentSize().width-100,content2H+40),{getlocal("ltzdz_other_segment"),titleFontSize},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",touchOtherInfo,0.7,-(self.layerNum-1)*20-4,nil,nil)

    local desStr3=""
    if seg==1 then
        desStr3=getlocal("ltzdz_seg_des3_1")
    else
        desStr3=getlocal("ltzdz_seg_des3")
    end
    local segDes3Lb=G_getRichTextLabel(desStr3,colorTab,descFontSize,500,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,0)
    centerSp:addChild(segDes3Lb)
    segDes3Lb:setAnchorPoint(ccp(0,0.5))
    segDes3Lb:setPosition(startW1,content2H)

    content2H=content2H-80
    local reardDes=getlocal("ltzdz_settlement_reward")
    local reardLb=GetTTFLabelWrap(reardDes,descFontSize,CCSizeMake(160,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	reardLb:setAnchorPoint(ccp(0,0.5))
	reardLb:setPosition(startW1,content2H)
	centerSp:addChild(reardLb)

    local tempLb=GetTTFLabel(reardDes,descFontSize)
    local realW=tempLb:getContentSize().width
    if realW>reardLb:getContentSize().width then
        realW=reardLb:getContentSize().width
    end
    local iconSize=80

	-- 添加奖励
    local seg,smallLevel,totalSeg=ltzdzVoApi:getSegment()
    local rewardlist=ltzdzVoApi:getFinalRewards(totalSeg)
    for k,item in pairs(rewardlist) do
        local function showNewPropInfo()
            G_showNewPropInfo(self.layerNum+1,true,true,nil,item)
            return false
        end
        local iconSp,scale=G_getItemIcon(item,80,true,self.layerNum+1,showNewPropInfo)
        iconSp:setTouchPriority(-(self.layerNum-1)*20-3)
        iconSp:setAnchorPoint(ccp(0,0.5))
        iconSp:setPosition(reardLb:getPositionX()+realW+(k-1)*(iconSize+10),reardLb:getPositionY())
        centerSp:addChild(iconSp)

        local numLb=GetTTFLabel(item.num,18)
        numLb:setAnchorPoint(ccp(1,0))
        numLb:setScale(1/scale)
        numLb:setPosition(iconSp:getContentSize().width-5,3)
        iconSp:addChild(numLb)
    end

	-- 注意
	local careLb=GetTTFLabelWrap(getlocal("ltzdz_detail_care"),25,CCSizeMake(550,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	careLb:setAnchorPoint(ccp(0.5,0.5))
	careLb:setPosition(self.bgLayer:getContentSize().width/2,60)
	self.bgLayer:addChild(careLb)

end

function ltzdzPlayerInfoDialog:tick()
end

function ltzdzPlayerInfoDialog:fastTick()  
end

function ltzdzPlayerInfoDialog:dispose()
    -- spriteController:removePlist("public/acAnniversary.plist")
    -- spriteController:removeTexture("public/acAnniversary.png")
end