-- 显示将领装备强化道具跳转面板,challangeList渠道列表，rtype:跳转面板的类型
function smallDialog:showHeroEquipPropJumpDialog(item,curNum,needNum,challangeList,rtype,layerNum,successCallBack)
      local sd=smallDialog:new()
      local dialog=sd:initHeroEquipPropJumpDialog(item,curNum,needNum,challangeList,rtype,layerNum,successCallBack)
      return sd
end
function smallDialog:initHeroEquipPropJumpDialog(item,curNum,needNum,challangeList,rtype,layerNum,successCallBack)
    self.layerNum=layerNum
    self.isTouch=true
    self.isUseAmi=true
    local function touchHandler()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),touchHandler)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgLayer:setTouchPriority(-(layerNum-1)*20-2)

    local size=CCSizeMake(600,660)
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    self:userHandler()

    local function touchLuaSpr()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    local function close()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
    closeBtnItem:setPosition(ccp(0,0))
    closeBtnItem:setAnchorPoint(ccp(0,0))

    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn,2)

    local LbY = 530
    -- 道具信息
    local icon = G_getItemIcon(item,100,false,layerNum+1)
    -- local icon = LuaCCSprite:createWithSpriteFrameName(pic,showInfoHandler)
    icon:ignoreAnchorPointForPosition(false)
    icon:setAnchorPoint(ccp(0.5,1))
    icon:setPosition(ccp(100,self.bgSize.height-40))
    icon:setIsSallow(false)
    icon:setTouchPriority(-(self.layerNum-1)*20-2)
    self.bgLayer:addChild(icon,1)


    local propNameLb=GetTTFLabelWrap(item.name,28,CCSize(300, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    propNameLb:setPosition(icon:getPositionX()+icon:getContentSize().width+10,self.bgSize.height-50)
    propNameLb:setAnchorPoint(ccp(0,1));
    self.bgLayer:addChild(propNameLb)

    local propNumLb = GetTTFLabelWrap(getlocal("propOwned")..curNum.."/"..needNum,23,CCSize(300, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    propNumLb:setAnchorPoint(ccp(0,1))
    propNumLb:setPosition(ccp(icon:getPositionX()+icon:getContentSize().width+10,propNameLb:getPositionY()-propNameLb:getContentSize().height-10))
    self.bgLayer:addChild(propNumLb)

    local function touch( ... )

    end
    local temH = icon:getPositionY()-icon:getContentSize().height-30
    local bgSp = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray2.png",CCRect(20, 20, 1, 1),touch)
    bgSp:setAnchorPoint(ccp(0.5,0))
    bgSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,temH))
    bgSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,20))
    self.bgLayer:addChild(bgSp)

    local getPropDescLb=GetTTFLabelWrap(getlocal("get_prop_channel_Desc"),23,CCSize(bgSp:getContentSize().width-20, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    getPropDescLb:setPosition(bgSp:getContentSize().width/2,bgSp:getContentSize().height-10)
    getPropDescLb:setAnchorPoint(ccp(0.5,1));
    bgSp:addChild(getPropDescLb)
    getPropDescLb:setColor(G_ColorYellowPro)


    local isMoved=false
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            -- return SizeOfTable(heroEquipVoApi:getPropChannelList(item.id))
            return #challangeList
        elseif fn=="tableCellSizeForIndex" then
            local cellWidth=self.bgSize.width-40
            local cellHeight=130
            local tmpSize=CCSizeMake(cellWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            local temHeight = 110
            local temLbHeight = 28
            local function cellClick( ... )

            end
            local titleStr = ""
            local subDescStr = ""
            local isUnlock=false
            local pointId = challangeList[idx+1]
            local chapterId,index=heroEquipChallengeVoApi:getChapterIdByPointId(pointId)
            if rtype==1 then

                titleStr = getlocal("equip_explore_title")
                subDescStr = heroEquipChallengeVoApi:getLocalPointName(chapterId,index)
                isUnlock=heroEquipChallengeVoApi:checkPointIsUnlock(chapterId,index)
            elseif rtype==2 then
                titleStr = getlocal("equip_lab_title")
                subDescStr = getlocal("get_prop_channel_Desc1",{item.name})
                isUnlock=true
            elseif rtype==3 then
                titleStr = getlocal("equip_lab_title")
                subDescStr = getlocal("get_prop_channel_Desc1",{item.name})
                isUnlock=true
            elseif rtype==4 then
                titleStr = getlocal("activity_timelimit_open")
                subDescStr = getlocal("activity_seikostone_shop_title")
                local seikoShopVo = activityVoApi:getActivityVo("seikoStoneShop")
                if seikoShopVo ~= nil and activityVoApi:isStart(seikoShopVo) == true then
                    isUnlock=true
                end
            elseif rtype==5 then --活动产出，因不确定是哪个活动产出，所以不需要跳转
                titleStr=getlocal("output_from_activity2")
                subDescStr=getlocal("output_from_activity")
                isUnlock=true
            elseif rtype==99 then
                titleStr = getlocal("prop_noOpen")
                subDescStr = getlocal("alliance_notOpen")
                isUnlock=false
            end
            local function clickEquipHandler( ... )
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                end
                if self.refreshData.tableView and self.refreshData.tableView:getScrollEnable()==true and self.refreshData.tableView:getIsScrolled()==true then
                    return
                end
                if isUnlock==false then
                    return
                end
                if rtype==5 then
                    do return end
                end
                self:close()
                -- if successCallBack then
                --     successCallBack()
                -- end
                if rtype==1 then
                    --请求打开装备探索页面
                    heroEquipChallengeVoApi:openSpecifiedPointDialog(chapterId,index,self.layerNum + 1,successCallBack)
                    -- heroEquipChallengeVoApi:openSpecifiedPointDialog(chapterId,pointIndex,layerNum,endBattleCallBack)
                    -- heroEquipChallengeVoApi:openExploreDialog(chapterId,index,self.layerNum-3)
                elseif rtype==2 then
                    heroEquipVoApi:openEquipLabDialog(self.layerNum+1,true,successCallBack)
                elseif rtype==3 then
                    heroEquipVoApi:openEquipLabDialog(self.layerNum+1,false,successCallBack)
                elseif rtype==4 then
                    local isEnable,level = acSeikoStoneShopVoApi:isCanJoinActivity()
                    if isEnable == false then
                        --弹出等级不足的提示
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_newyearseve_lvllack",{level}),30)
                    else
                        acSeikoStoneShopVoApi:openSeikoStoneShopDialog(self.layerNum+1)
                    end
                end
            end
            local sprieBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),clickEquipHandler)
            sprieBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,temHeight-10))
            sprieBg:setAnchorPoint(ccp(0.5,1))
            sprieBg:setPosition(ccp((self.bgLayer:getContentSize().width-40)/2,temHeight))
            sprieBg:setTouchPriority(-(self.layerNum-1)*20-3)
            cell:addChild(sprieBg)

            local subTitleSp=CCSprite:createWithSpriteFrameName("platWarNameBg1.png")
            subTitleSp:setAnchorPoint(ccp(0,0.5))
            subTitleSp:setPosition(ccp(0,sprieBg:getContentSize().height+3))
            cell:addChild(subTitleSp,2)


            local subTitleLb=GetTTFLabelWrap(titleStr,26,CCSize(subTitleSp:getContentSize().width-20, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
            subTitleLb:setPosition(ccp((subTitleSp:getContentSize().width-20)/2,subTitleSp:getContentSize().height/2+2))
            subTitleLb:setAnchorPoint(ccp(0.5,0.5));
            subTitleSp:addChild(subTitleLb)


            local subDescLb=GetTTFLabelWrap(subDescStr,22,CCSize(sprieBg:getContentSize().width-120, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            subDescLb:setPosition(ccp(5,sprieBg:getContentSize().height-subTitleSp:getContentSize().height/2-10))
            subDescLb:setAnchorPoint(ccp(0,1));
            sprieBg:addChild(subDescLb)


            if isUnlock==true then
                if rtype~=5 then
                    local equipBtn=GetButtonItem("IconReturnBtn.png","IconReturnBtn_Down.png","IconReturnBtn.png",clickEquipHandler,11,nil,0)
                    local equipMenu=CCMenu:createWithItem(equipBtn)
                    equipMenu:setAnchorPoint(ccp(0.5,0.5))
                    equipMenu:setPosition(ccp(sprieBg:getContentSize().width-50,sprieBg:getContentSize().height/2))
                    equipMenu:setTouchPriority(-(self.layerNum-1)*20-3)
                    sprieBg:addChild(equipMenu,1)
                end
            else
                local unlockStr="local_war_stage_1"
                if rtype==4 then
                    unlockStr="backstage1985"
                end
                local lockLb=GetTTFLabel(getlocal(unlockStr),23)
                lockLb:setPosition(ccp(sprieBg:getContentSize().width-25,sprieBg:getContentSize().height/2))
                lockLb:setAnchorPoint(ccp(1,0.5));
                sprieBg:addChild(lockLb)
                lockLb:setColor(G_ColorRed)
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
    local cellWidth=self.bgLayer:getContentSize().width-40
    local hd= LuaEventHandler:createHandler(tvCallBack)
    self.refreshData.tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,temH-80),nil)
    self.refreshData.tableView:setTableViewTouchPriority(-(layerNum-1)*20-4)
    self.refreshData.tableView:setPosition(ccp(10,20))
    self.refreshData.tableView:setAnchorPoint(ccp(0.5,0))
    bgSp:addChild(self.refreshData.tableView,2)
    self.refreshData.tableView:setMaxDisToBottomOrTop(120)

    self:addForbidSp(self.bgLayer,size,layerNum)


    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0))
    return self.dialogLayer
end



-- 进阶成功面板
-- hid英雄id,eid当前装备id，nextEid下个等级的装备id,titleStr标题，,productOrder英雄品阶,isAdvance--是否是进阶
function smallDialog:showHeroEquipUpgradeDialog(hid,eid,productOrder,titleStr,layerNum,callBack,isAdvance)
      local sd=smallDialog:new()
      local dialog=sd:initHeroEquipUpgradeDialog(hid,eid,productOrder,titleStr,layerNum,callBack,isAdvance)
      return sd
end
function smallDialog:initHeroEquipUpgradeDialog(hid,eid,productOrder,titleStr,layerNum,callBack,isAdvance)
    self.layerNum=layerNum
    self.isTouch=true
    self.isUseAmi=true
    local function touchHandler()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),touchHandler)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgLayer:setTouchPriority(-(layerNum-1)*20-2)

    local size=CCSizeMake(540,580)
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    self:userHandler()

    local function touchLuaSpr()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    local spriteTitle = CCSprite:createWithSpriteFrameName("ShapeTank.png");
    spriteTitle:setAnchorPoint(ccp(0.5,0.5));
    spriteTitle:setPosition(ccp(self.bgSize.width/2,self.bgSize.height))
    self.bgLayer:addChild(spriteTitle,2)

    local spriteTitle1 = CCSprite:createWithSpriteFrameName("ShapeGift.png");
    spriteTitle1:setAnchorPoint(ccp(0.5,0.5));
    spriteTitle1:setPosition(ccp(self.bgSize.width/2,self.bgSize.height))
    self.bgLayer:addChild(spriteTitle1,2)

    local spriteShapeAperture = CCSprite:createWithSpriteFrameName("ShapeAperture.png");
    spriteShapeAperture:setAnchorPoint(ccp(0.5,0.5));
    spriteShapeAperture:setPosition(ccp(self.bgSize.width/2,self.bgSize.height))
    self.bgLayer:addChild(spriteShapeAperture,1)


    local titleLb=GetTTFLabelWrap(titleStr,40,CCSize(self.bgLayer:getContentSize().width-40, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    titleLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-60))
    titleLb:setAnchorPoint(ccp(0.5,1));
    self.bgLayer:addChild(titleLb)
    titleLb:setColor(G_ColorYellowPro)

    local lineSp1 = CCSprite:createWithSpriteFrameName("LineCross.png");
    lineSp1:setAnchorPoint(ccp(0.5,0.5));
    lineSp1:setPosition(self.bgLayer:getContentSize().width/2,titleLb:getPositionY()-titleLb:getContentSize().height-25)
    self.bgLayer:addChild(lineSp1,2)
    lineSp1:setScaleX((self.bgLayer:getContentSize().width-30)/lineSp1:getContentSize().width)

    local function clickIconHandler( ... )

    end
    local iconSize = CCSizeMake(100,100)
    local equipIconSp1 = nil
    if isAdvance ~= nil and isAdvance == true then
        equipIconSp1 = heroEquipVoApi:getEquipIcon(hid,iconSize,eid,clickIconHandler,nil,productOrder,nil,-1)
    else
        equipIconSp1 = heroEquipVoApi:getEquipIcon(hid,iconSize,eid,clickIconHandler,-1,productOrder)
    end
    equipIconSp1:setAnchorPoint(ccp(0.5,1))
    equipIconSp1:setPosition(ccp(150,lineSp1:getPositionY()-30))
    self.bgLayer:addChild(equipIconSp1)

    local equipIconSp2 = heroEquipVoApi:getEquipIcon(hid,iconSize,eid,clickIconHandler,nil,productOrder)
    equipIconSp2:setAnchorPoint(ccp(0.5,1))
    equipIconSp2:setPosition(ccp(self.bgLayer:getContentSize().width-150,lineSp1:getPositionY()-30))
    self.bgLayer:addChild(equipIconSp2)

    local arowSp=CCSprite:createWithSpriteFrameName("GuideArow.png")
    arowSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,lineSp1:getPositionY()-30-equipIconSp2:getContentSize().height/2))
    self.bgLayer:addChild(arowSp)
    arowSp:setRotation(-90)

    local equipNameStr = nil
    if isAdvance and isAdvance == true then
        equipNameStr = heroEquipVoApi:getEquipName(hid,eid,nil)
    else
        equipNameStr = heroEquipVoApi:getEquipName(hid,eid,-1)
    end

    local equipNameLb1=GetTTFLabel(equipNameStr,23)
    equipNameLb1:setPosition(equipIconSp1:getPositionX(),equipIconSp1:getPositionY()-equipIconSp1:getContentSize().height-20)
    equipNameLb1:setAnchorPoint(ccp(0.5,1));
    self.bgLayer:addChild(equipNameLb1)
    equipNameLb1:setColor(G_ColorYellowPro)

    local equipNameLb2=GetTTFLabel(heroEquipVoApi:getEquipName(hid,eid,nil),23)
    equipNameLb2:setPosition(equipIconSp2:getPositionX(),equipIconSp2:getPositionY()-equipIconSp2:getContentSize().height-20)
    equipNameLb2:setAnchorPoint(ccp(0.5,1));
    self.bgLayer:addChild(equipNameLb2)
    equipNameLb2:setColor(G_ColorYellowPro)


    local lineSp2 = CCSprite:createWithSpriteFrameName("LineCross.png");
    lineSp2:setAnchorPoint(ccp(0.5,0.5));
    lineSp2:setPosition(self.bgLayer:getContentSize().width/2,equipNameLb2:getPositionY()-equipNameLb2:getContentSize().height-25)
    self.bgLayer:addChild(lineSp2,2)
    lineSp2:setScaleX((self.bgLayer:getContentSize().width-30)/lineSp2:getContentSize().width)

    local attList1 = nil
    if isAdvance and isAdvance == true then
        attList1=heroEquipVoApi:getAttList(hid,eid,nil,productOrder,nil,-1)
    else
        attList1=heroEquipVoApi:getAttList(hid,eid,-1,productOrder)
    end
    local titleBgY = 0
    if attList1 and SizeOfTable(attList1)>0 then
        local index = 0
        for k,v in pairs(attList1) do
            local equipAttrNameLb1=GetTTFLabel(v["lb"][1],23)
            local py1 = lineSp2:getPositionY()-(equipNameLb1:getContentSize().height+5)*index-30
            equipAttrNameLb1:setAnchorPoint(ccp(1,0.5));
            self.bgLayer:addChild(equipAttrNameLb1)
            local propertyStr = ":+"..v.value
            -- if k~="first" then
            if v["key"]~="first" then
                propertyStr = ":+"..(v.value).."%"
            end
            local equipAttrNumLb1=GetTTFLabel(propertyStr,23)
            equipAttrNumLb1:setAnchorPoint(ccp(0,0.5));
            self.bgLayer:addChild(equipAttrNumLb1)
            index=index+1
            local temW = equipAttrNameLb1:getContentSize().width-equipAttrNumLb1:getContentSize().width
            equipAttrNameLb1:setPosition(ccp(equipIconSp1:getPositionX()+temW/2,py1))
            equipAttrNumLb1:setPosition(ccp(equipIconSp1:getPositionX()+temW/2,py1))
            titleBgY=py1-equipAttrNameLb1:getContentSize().height-8
        end
    end

    local attList2=heroEquipVoApi:getAttList(hid,eid,nil,productOrder)
    if attList2 and SizeOfTable(attList2)>0 then
        local index = 0
        for k,v in pairs(attList2) do
            local equipAttrNameLb2=GetTTFLabel(v["lb"][1],23)
            local py1 = lineSp2:getPositionY()-(equipNameLb2:getContentSize().height+5)*index-30
            equipAttrNameLb2:setAnchorPoint(ccp(1,0.5))
            self.bgLayer:addChild(equipAttrNameLb2)
            local propertyStr = ":+"..v.value
            -- if k~="first" then
            if v["key"]~="first" then
                propertyStr = ":+"..(v.value).."%"
            end
            local equipAttrNumLb2=GetTTFLabel(propertyStr,23)
            equipAttrNumLb2:setAnchorPoint(ccp(0,0.5));
            self.bgLayer:addChild(equipAttrNumLb2)
            equipAttrNumLb2:setColor(G_ColorGreen)
            index=index+1
            local temW = equipAttrNameLb2:getContentSize().width-equipAttrNumLb2:getContentSize().width
            equipAttrNameLb2:setPosition(ccp(equipIconSp2:getPositionX()+temW/2,py1))
            equipAttrNumLb2:setPosition(ccp(equipIconSp2:getPositionX()+temW/2,py1))
        end
    end
    local awakenLv = heroEquipVoApi:getAwakenLevelByEidAndIndex(hid,eid)
    if eid=="e1" and awakenLv==1 then
        local skillNameStr=""
        local skillDesStr = ""
        local skillList=heroEquipVoApi:getSkillList(hid,eid)
        if skillList then
            for k,v in pairs(skillList) do
                local lvStr,value,isMax,skillLevel=heroVoApi:getHeroSkillLvAndValue(hid,v,productOrder,true)
                skillNameStr=getlocal(heroSkillCfg[v].name)
                -- skillDesStr=getlocal(heroSkillCfg[v].des)
                skillDesStr=getlocal(heroSkillCfg[v].des,{value})
            end
            local titleStr = getlocal("equip_skill_tip1",{skillNameStr})
            local skillTitleLb = GetTTFLabelWrap(titleStr,23,CCSize(self.bgLayer:getContentSize().width-60, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
            skillTitleLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,titleBgY))
            self.bgLayer:addChild(skillTitleLb)
        end

    end


    local function confirmHandler()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local confirmBtnItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",confirmHandler,2,getlocal("confirm"),25)
    -- confirmBtnItem:setPosition(ccp(self.dialogLayer:getContentSize().width/2,25))
    -- confirmBtnItem:setAnchorPoint(ccp(0.5,0))

    local confirmBtnMenu = CCMenu:createWithItem(confirmBtnItem)
    confirmBtnMenu:setTouchPriority(-(layerNum-1)*20-4)
    confirmBtnMenu:setPosition(ccp(self.bgSize.width/2,57))
    self.bgLayer:addChild(confirmBtnMenu,2)


    self:addForbidSp(self.bgLayer,size,layerNum)
    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0))
    return self.dialogLayer
end



-- 装备探索，点击关卡的小面板
-- chapterId章节id,pointId关卡id
function smallDialog:showExplorePointDialog(allReward,chapterId,pointId,curStarNum,maxStarNum,layerNum,callBack,callBack2)
      local sd=smallDialog:new()
      local dialog=sd:initExplorePointDialog(allReward,chapterId,pointId,curStarNum,maxStarNum,layerNum,callBack,callBack2)
      return sd
end
function smallDialog:initExplorePointDialog(allReward,chapterId,pointId,curStarNum,maxStarNum,layerNum,callBack,callBack2)
    self.layerNum=layerNum
    self.isTouch=true
    self.isUseAmi=true

    local size = CCSizeMake(600,510)
    local titleStr = heroEquipChallengeVoApi:getLocalPointName(chapterId,pointId)
    local titleSize = 28
    self.bgSize = size

    local function closeCallBack( ... )
        return self:close()
    end
    -- 采用新式小板子
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.dialogLayer:setPosition(ccp(0,0))
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    sceneGame:addChild(self.dialogLayer,layerNum)

    local dialogBg = G_getNewDialogBg(size,titleStr,titleSize,nil,layerNum,true,closeCallBack,G_ColorYellowPro)
    self.bgLayer=dialogBg
    self.bgLayer:setContentSize(size)
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)

    self:show()
    self:userHandler()

    local function touchLuaSpr()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    local posTopY = 425

    local function showInfoHandler(hd,fn,idx)
    end
    local pic="equipPoint1.png"
    local iconSpW=90
    local iconSpX = 95
    if pointId==5 then
        pic="equipPoint2.png"
        iconSpW=100
        iconSpX=105
    end
    local pointBgSp

    pointBgSp = LuaCCSprite:createWithSpriteFrameName(pic,showInfoHandler)
    local pointX,pointY = iconSpX,posTopY-130
    pointBgSp:setPosition(ccp(pointX,pointY))
    self.bgLayer:addChild(pointBgSp,2)

    local iconPic = heroEquipChallengeVoApi:getPointPic(chapterId,pointId)
    local pointIcon
    if pointId==5 then
        local heroImageStr="ship/Hero_Icon/"..iconPic
        if platCfg.platCfgHeroCartoonPhoto[G_curPlatName()]~=nil then
            heroImageStr="ship/Hero_Icon_Cartoon/"..iconPic
        end
        pointIcon = CCSprite:create(heroImageStr)
    else
        pointIcon = CCSprite:createWithSpriteFrameName(iconPic)
    end

    pointIcon:setAnchorPoint(ccp(0.5,0.5))
    pointIcon:setPosition(ccp(pointBgSp:getContentSize().width/2,pointBgSp:getContentSize().height-55))
    pointBgSp:addChild(pointIcon)
    -- pointIcon:setScale(iconSpScale)
    pointIcon:setScale(iconSpW/pointIcon:getContentSize().width)

    local costEnergyNumLb = GetTTFLabelWrap(getlocal("equip_cost_energy",{heroEquipChallengeVoApi:getUseEnergyNum()}),20,CCSize(200, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    costEnergyNumLb:setAnchorPoint(ccp(0,1))
    costEnergyNumLb:setPosition(ccp(30,posTopY-230))
    self.bgLayer:addChild(costEnergyNumLb)

    local function touch( ... )
        -- body
    end
    local capInSet = CCRect(15, 15, 2, 2)
    local bgSp = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",capInSet,touch)
    bgSp:setAnchorPoint(ccp(0,1))
    bgSp:setContentSize(CCSizeMake(400,300))
    bgSp:setPosition(ccp(180,posTopY-10))
    self.bgLayer:addChild(bgSp)

    local starSpace=70
    for j=1,maxStarNum do
        local starSp
        if curStarNum>=j then
            starSp=CCSprite:createWithSpriteFrameName("StarIcon.png")
        else
            starSp=CCSprite:createWithSpriteFrameName("gameoverstar_black.png")
        end
        starSp:setAnchorPoint(ccp(0.5,1))
        starSp:setScale(starSpace/starSp:getContentSize().width)
        local px=bgSp:getContentSize().width/2-starSpace/2*(maxStarNum-1)+starSpace*(j-1)
        local py=bgSp:getContentSize().height-10
        starSp:setPosition(ccp(px,py))
        bgSp:addChild(starSp,1)
    end

    local curNum,maxNum = heroEquipChallengeVoApi:getPointAttackNum(chapterId,pointId)
    local numLb = GetTTFLabelWrap(getlocal("equip_explore_num",{curNum.."/"..maxNum}),20,CCSize(bgSp:getContentSize().width-20, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    numLb:setAnchorPoint(ccp(0,1))
    numLb:setPosition(ccp(15,bgSp:getContentSize().height-starSpace-10))
    bgSp:addChild(numLb)
    local sid=heroEquipChallengeVoApi:getChapterNum()*(chapterId-1)+pointId
    local xpReward = hChallengeCfg.list[sid].clientReward.base
    local award2 = FormatItem(xpReward)
    local xpLb
    if award2 then
        -- xpLb = GetTTFLabelWrap(getlocal("sample_prop_name_e1").."："..award2[1].num,20,CCSize(bgSp:getContentSize().width-20, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        xpLb = GetTTFLabel(getlocal("sample_prop_name_e1").."："..award2[1].num,20)
        xpLb:setAnchorPoint(ccp(0,1))
        xpLb:setPosition(ccp(15,numLb:getPositionY()-numLb:getContentSize().height-5))
        bgSp:addChild(xpLb)
        -- xpLb:setColor(G_ColorYellowPro)
        local addValue = strategyCenterVoApi:getAttributeValue(12)
        if addValue and addValue > 0 then
            local addValueLb = GetTTFLabel("+" .. math.ceil(award2[1].num * addValue), 20)
            addValueLb:setAnchorPoint(ccp(0, 0.5))
            addValueLb:setPosition(ccp(xpLb:getPositionX() + xpLb:getContentSize().width, xpLb:getPositionY() - xpLb:getContentSize().height / 2))
            addValueLb:setColor(G_ColorGreen)
            bgSp:addChild(addValueLb)
        end
    end


    local propLb = GetTTFLabelWrap(getlocal("equip_explore_prop"),20,CCSize(bgSp:getContentSize().width-20, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    propLb:setAnchorPoint(ccp(0,1))
    if xpLb then
        propLb:setPosition(ccp(15,xpLb:getPositionY()-xpLb:getContentSize().height-5))
    else
        propLb:setPosition(ccp(15,numLb:getPositionY()-numLb:getContentSize().height-5))
    end

    bgSp:addChild(propLb)
    propLb:setColor(G_ColorYellowPro)

    local award2 = FormatItem(allReward)
    local award = {}
    for k,v in pairs(award2) do
        if v.type and v.type=="h" and v.eType and v.eType=="s" then
            v.sort=1
        elseif v.id and (v.id>=451 and v.id<=468) then
            v.sort=2
        elseif v.id and (v.id>=469 and v.id<=499) then
            v.sort=3
        elseif v.id and (v.id>=446 and v.id<=450) then
            v.sort=4
        end

        table.insert(award,v)
    end
    local function sortB(a,b)
        if a and b and a.sort and b.sort then
            return a.sort<b.sort
        end
    end
    table.sort(award,sortB)
    local isMoved=false
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return #award
        elseif fn=="tableCellSizeForIndex" then
            local cellWidth=110
            local cellHeight=120
            local tmpSize=CCSizeMake(cellWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            local temHeight = 110
            local temLbHeight = 28
            local function cellClick( ... )

            end

            if award and award[idx+1] then
                -- for k,v in pairs(award) do
                    local iSize=100
                    local v = award[idx+1]
                    local icon,iiScale=G_getItemIcon(v,iSize,true,layerNum+1,cellClick)
                    icon:setTouchPriority(-(layerNum-1)*20-4)
                    if icon:getContentSize().height > icon:getContentSize().width then
                        icon:setScale(iSize / icon:getContentSize().height)
                    else
                        icon:setScale(iSize / icon:getContentSize().width)
                    end
                    local px,py=20,20
                    icon:setPosition(ccp(px,py))
                    icon:setAnchorPoint(ccp(0,0))
                    cell:addChild(icon)

                    local numLb = GetTTFLabel("x"..FormatNumber(v.num), 20)
                    numLb:setAnchorPoint(ccp(1, 0.5))
                    local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), function ()end)
                    numBg:setAnchorPoint(ccp(1, 0))
                    numBg:setContentSize(CCSizeMake(numLb:getContentSize().width + 5, numLb:getContentSize().height - 5))
                    numBg:setPosition(ccp(icon:getContentSize().width - 3, 7))
                    numBg:setOpacity(150)
                    icon:addChild(numBg, 2)
                    numLb:setPosition(numBg:getContentSize().width - 2, numBg:getContentSize().height / 2)
                    numBg:addChild(numLb)
                    numBg:setScale(1 / icon:getScale())
                -- end

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
    local cellWidth=bgSp:getContentSize().width-20
    local hd= LuaEventHandler:createHandler(tvCallBack)
    self.refreshData.tableView=LuaCCTableView:createHorizontalWithEventHandler(hd,CCSizeMake(cellWidth,120),nil)
    self.refreshData.tableView:setTableViewTouchPriority(-(layerNum-1)*20-5)
    self.refreshData.tableView:setPosition(ccp(10,0))
    bgSp:addChild(self.refreshData.tableView,2)
    self.refreshData.tableView:setMaxDisToBottomOrTop(120)


    local function touchCallback(tag,object)
        -- 检测是否还有攻击次数
        if curNum<=0 then
            local curResetNum,maxResetNum,gold,vipLevel,maxVipLevel=heroEquipChallengeVoApi:getResetNumAndGold(chapterId,pointId)
            if curResetNum>=maxResetNum then
                if vipLevel>=maxVipLevel then
                    smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("equip_sweep_tip2"),nil,self.layerNum+1)
                else
                    local str = getlocal("equip_sweep_tip2").."\n"..getlocal("equip_sweep_tip3",{vipLevel})
                    local function gotoVipHandler()
                        if G_checkClickEnable()==false then
                            do
                                return
                            end
                        end
                        if newGuidMgr:isNewGuiding() then
                            do return end
                        end
                        -- require "luascript/script/game/scene/gamedialog/vipDialog"
                        -- local vd1 = vipDialog:new();
                        -- local vd = vd1:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("vipTitle"),true,self.layerNum+1);
                        -- sceneGame:addChild(vd,5);
                        vipVoApi:openVipDialog(self.layerNum+1)
                        PlayEffect(audioCfg.mouseClick)
                        self:close()
                    end
                    local function cancleCallBack()
                        self:close()
                    end
                    smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),gotoVipHandler,getlocal("dialog_title_prompt"),str,nil,self.layerNum+1,nil,nil,cancleCallBack,getlocal("gotoVip"))
                end
            else
                local str2 = getlocal("equip_sweep_tip4",{gold,curResetNum})
                local function resetHandler()
                    local sid = (chapterId-1)*heroEquipChallengeVoApi:getChapterNum()+pointId
                    local function resetCallBack(fn,data)
                        local ret,sData=base:checkServerData(data)
                        if ret==true then
                            if sData and sData.data and sData.data.hchallenge then
                                heroEquipChallengeVoApi:formatData(sData.data.hchallenge)
                                --重置成功后刷新一下扫荡页面的攻打次数
                                curNum,maxNum = heroEquipChallengeVoApi:getPointAttackNum(chapterId,pointId)
                                tolua.cast(numLb,"CCLabelTTF"):setString(getlocal("equip_explore_num",{curNum.."/"..maxNum}))
                                --弹出重置攻打次数成功的飘窗
                                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("equip_buy_attacknum_success"),30)
                            end
                        end
                        --self:close()
                    end
                    if playerVoApi:getGems()<gold then
                        GemsNotEnoughDialog(nil,nil,gold-playerVoApi:getGems(),self.layerNum+1,gold)
                        do
                            return
                        end
                    end
                    socketHelper:equipBuyrestnum(sid,resetCallBack)
                end
                local function cancleCallBack()
                    self:close()
                end
                smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),resetHandler,getlocal("dialog_title_prompt"),str2,nil,self.layerNum+1,nil,nil,cancleCallBack)
            end
            return
        end
        local attackNum = 1
        local sid = heroEquipChallengeVoApi:getChapterNum()*(chapterId-1)+pointId
        if tag==21 then
            attackNum=curNum
        end
        if heroEquipChallengeVoApi:getUseEnergyNum()*attackNum>playerVoApi:getEnergy() then
            --弹出购买能量成功的飘窗提示
            local function supplySuccess()
                eventDispatcher:dispatchEvent("equipExplore.dataChange",nil)
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("energySupplySuccess"),30)
            end
            --弹出能量不足，提示购买能量的页面
            -- G_buyEnergy(self.layerNum+1,true,supplySuccess)
            smallDialog:showEnergySupplementDialog(self.layerNum + 1, supplySuccess)
            -- local function supplyEnergy()
            --     --调用补充体力的接口
            --     G_buyEnergy(self.layerNum+1,supplySuccess)
            -- end
            -- local function cancelCallBack()
            --     self:close()
            -- end
            -- smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),supplyEnergy,getlocal("dialog_title_prompt"),getlocal("elite_challenge_raid_energy"),nil,self.layerNum+1,nil,nil,cancelCallBack)
            return
        end
        if tag==20 or tag==21 then
            if curStarNum<maxStarNum then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage18021"),30)
                return
            end
            local action = 1
            if tag==21 then--扫荡多次
                action=0
                local vipLv = playerVoApi:getVipLevel()
                local needVipLv = playerCfg.vipRelatedCfg.hchallengeSweepNeedVip
                if vipLv<needVipLv then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("equip_sweep_tip6",{needVipLv}),30)
                    return
                end
            end
            local function battleHandler(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    if sData and sData.data and sData.data.hchallenge then
                        heroEquipChallengeVoApi:formatData(sData.data.hchallenge)
                    end
                    if sData and sData.data and sData.data.equip then
                        heroEquipVoApi:formatData(sData.data.equip)
                    end
                    local allReward = sData.data.allReward
                    if callBack and allReward then
                        callBack(allReward)
                        self:close()
                    end
                end
                heroEquipChallengeVoApi:setIfNeedSendECRequest(true)
            end
            socketHelper:equipMultiplebattle(action,sid,battleHandler,true)
        elseif tag==22 then
            PlayEffect(audioCfg.mouseClick)
            self:close()
            local function callBack3()
                if callBack2 then
                    callBack2()
                end
            end
            require "luascript/script/game/scene/gamedialog/warDialog/tankStoryDialog"
            local td=tankStoryDialog:new(nil,nil,nil,nil,nil,nil,sid,callBack3)
            local tbArr={getlocal("fleetCard"),getlocal("dispatchCard"),getlocal("repair")}
            print("----dmj----layerNum:"..layerNum)
            local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("goFighting"),true,7)
            sceneGame:addChild(dialog,7)
        end
    end
    local tBtnScale = 0.8
    local canSweepNum = 3
    local btnMenu = CCMenu:create()
    local sweepBtn= GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",touchCallback,2,getlocal("elite_challenge_raid_btn"),24/tBtnScale)
    sweepBtn:setScale(tBtnScale)
    btnMenu:addChild(sweepBtn)
    sweepBtn:setTag(20)
    local sweepMoreBtn= GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",touchCallback,2,getlocal("sweep_more",{canSweepNum}),24/tBtnScale,11)
    btnMenu:addChild(sweepMoreBtn)
    sweepMoreBtn:setTag(21)
    sweepMoreBtn:setScale(tBtnScale)
    local challengeBtn= GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",touchCallback,2,getlocal("alliance_challenge_fight"),24/tBtnScale,11)
    btnMenu:addChild(challengeBtn)
    challengeBtn:setTag(22)
    challengeBtn:setScale(tBtnScale)

    btnMenu:alignItemsHorizontallyWithPadding(20)
    btnMenu:setTouchPriority(-(self.layerNum-1)*20-3)
    self.bgLayer:addChild(btnMenu)
    btnMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2, 58))

    self:addForbidSp(self.bgLayer,size,layerNum)

    return self.dialogLayer
end


-- chapterId章节id,pointId关卡id
function smallDialog:showExploreSweepDialog(allReward,attackNum,chapterId,pointId,layerNum,callBack)
      local sd=smallDialog:new()
      local dialog=sd:initExploreSweepDialog(allReward,attackNum,chapterId,pointId,layerNum,callBack)
      return sd
end
function smallDialog:initExploreSweepDialog(allReward,attackNum,chapterId,pointId,layerNum,callBack)
    self.layerNum=layerNum
    self.isTouch=true
    self.isUseAmi=true
    
    local size = CCSizeMake(600,520)
    local titleStr = getlocal("elite_challenge_raid_btn")
    local titleSize = 30
    self.bgSize = size

    local function closeCallBack( ... )
        return self:close()
    end

    -- 采用新式小板子
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.dialogLayer:setPosition(ccp(0,0))
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    sceneGame:addChild(self.dialogLayer,layerNum)

    local dialogBg = G_getNewDialogBg(size,titleStr,titleSize,nil,layerNum,true,closeCallBack,G_ColorYellowPro)
    self.bgLayer=dialogBg
    self.bgLayer:setContentSize(size)
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)

    self:show()
    self:userHandler()

    local function touchLuaSpr()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    local function close()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end

    local posTopY = 434
    local capInSet = CCRect(15, 15, 2, 2)
    local bgSp = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",capInSet,touchLuaSpr)
    bgSp:setAnchorPoint(ccp(0.5,1))
    bgSp:setContentSize(CCSizeMake(self.bgSize.width-40,self.bgSize.height-180))
    bgSp:setPosition(ccp(self.bgSize.width/2, posTopY))
    self.bgLayer:addChild(bgSp)

    local isMoved=false
    local isMoreReward = false
    local isEnd = false
    local temAllReward
    if type(allReward)=="table" and SizeOfTable(allReward)>1 then
        temAllReward={}
        isMoreReward=true
    else
        temAllReward=allReward
    end
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return SizeOfTable(temAllReward)
        elseif fn=="tableCellSizeForIndex" then
            local cellWidth=self.bgSize.width-60
            local cellHeight=220
            local tmpSize=CCSizeMake(cellWidth,cellHeight)
            if isMoreReward==true and isEnd==true and SizeOfTable(temAllReward)==(idx+1) then
                tmpSize=CCSizeMake(cellWidth,cellHeight+60)
            end
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            local temHeight = 200
            if isMoreReward==true and isEnd==true and SizeOfTable(temAllReward)==(idx+1) then
                temHeight=260
            end
            local temLbHeight = 28
            local function cellClick( ... )

            end
            local bgSp1=CCSprite:createWithSpriteFrameName("believerTitleBg.png")
            bgSp1:setPosition(300,temHeight-10)
            cell:addChild(bgSp1)

            local subTitleLb=GetTTFLabelWrap(getlocal("sweep_challenge_num",{idx+1}),23,CCSize(bgSp1:getContentSize().width, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
            subTitleLb:setPosition(ccp(300,temHeight-10))
            cell:addChild(subTitleLb)
            ----阿拉伯文字调整
            local descLb=GetTTFLabelWrap(getlocal("sample_prop_name_e1").."：",23,CCSize(self.bgSize.width*0.5-30, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            descLb:setPosition(ccp(15,temHeight-35))
            descLb:setAnchorPoint(ccp(0,1));
            cell:addChild(descLb)
            descLb:setColor(G_ColorYellowPro)

            local award = FormatItem(temAllReward[idx+1])
            local xp_e1 = 0
            if award then
                local index = 1
                for k,v in pairs(award) do
                    if v.type and v.type=="f" then
                        xp_e1=v.num
                    else
                        local iSize=100
                        local icon,iiScale=G_getItemIcon(v,iSize,true,layerNum)
                        icon:setTouchPriority(-(layerNum-1)*20-4)
                        local px,py=20+(k-1)*120,descLb:getPositionY()-100
                        icon:setPosition(ccp(px,py))
                        icon:setAnchorPoint(ccp(0,0.5))
                        if icon:getContentSize().height > icon:getContentSize().width then
                            icon:setScale(iSize / icon:getContentSize().height)
                        else
                            icon:setScale(iSize / icon:getContentSize().width)
                        end
                        cell:addChild(icon)

                        local numLb = GetTTFLabel("x"..FormatNumber(v.num), 20)
                        numLb:setAnchorPoint(ccp(1, 0.5))
                        local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), function ()end)
                        numBg:setAnchorPoint(ccp(1, 0))
                        numBg:setContentSize(CCSizeMake(numLb:getContentSize().width + 5, numLb:getContentSize().height - 5))
                        numBg:setPosition(ccp(icon:getContentSize().width - 3, 7))
                        numBg:setOpacity(150)
                        icon:addChild(numBg, 2)
                        numLb:setPosition(numBg:getContentSize().width - 2, numBg:getContentSize().height / 2)
                        numBg:addChild(numLb)
                        numBg:setScale(1 / icon:getScale())

                        index=index+1
                    end
                end

            end
            descLb:setString(getlocal("sample_prop_name_e1").."："..xp_e1)
            if isMoreReward==true and isEnd==true and SizeOfTable(temAllReward)==(idx+1) then
                local endLb=GetTTFLabelWrap(getlocal("super_weapon_challenge_raid_complete"),30,CCSize(self.bgSize.width-60, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
                endLb:setPosition(ccp(270,30))
                endLb:setAnchorPoint(ccp(0.5,0));
                cell:addChild(endLb)
                endLb:setColor(G_ColorYellowPro)
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
    local cellWidth=self.bgLayer:getContentSize().width-50
    local hd= LuaEventHandler:createHandler(tvCallBack)
    self.refreshData.tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,bgSp:getContentSize().height-25),nil)
    self.refreshData.tableView:setTableViewTouchPriority(-(layerNum-1)*20-5)
    self.refreshData.tableView:setPosition(ccp(20,105))
    self.bgLayer:addChild(self.refreshData.tableView,2)
    self.refreshData.tableView:setMaxDisToBottomOrTop(120)

    local function showBtn( ... )
        local btnMenu = CCMenu:create()

        if attackNum and attackNum>0 then
            local function touchCallback( ... )
                local sid = heroEquipChallengeVoApi:getChapterNum()*(chapterId-1)+pointId
                local action = 1
                local function battleHandler(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                        if sData and sData.data and sData.data.hchallenge then
                            heroEquipChallengeVoApi:formatData(sData.data.hchallenge)
                        end
                        if sData and sData.data and sData.data.equip then
                            heroEquipVoApi:formatData(sData.data.equip)
                        end
                        local newAllReward = sData.data.allReward
                        if callBack and newAllReward then
                            callBack(newAllReward)
                        end
                    end
                    heroEquipChallengeVoApi:setIfNeedSendECRequest(true)
                end
                if heroEquipChallengeVoApi:getUseEnergyNum()*attackNum>playerVoApi:getEnergy() then
                    --弹出购买能量成功的飘窗提示
                    local function supplySuccess()
                        eventDispatcher:dispatchEvent("equipExplore.dataChange",nil)
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("energySupplySuccess"),30)
                    end
                    --弹出能量不足，提示购买能量的页面
                    -- G_buyEnergy(self.layerNum+1,true,supplySuccess)
                    smallDialog:showEnergySupplementDialog(self.layerNum + 1, supplySuccess)
                    return
                end
                socketHelper:equipMultiplebattle(action,sid,battleHandler,true)
                self:close()
            end
            local challengeBtn= GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",touchCallback,2,getlocal("sweep_again"),24/0.7,11)
            btnMenu:addChild(challengeBtn)
            challengeBtn:setScale(0.7)
        end
        local sweepBtn= GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",close,2,getlocal("confirm"),24/0.7)
        sweepBtn:setScale(0.7)
        btnMenu:addChild(sweepBtn)
        btnMenu:alignItemsHorizontallyWithPadding(50)
        btnMenu:setTouchPriority(-(self.layerNum-1)*20-4)
        self.bgLayer:addChild(btnMenu)
        btnMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2, 50))
    end
    if type(allReward)=="table" and SizeOfTable(allReward)>1 then
        local acArr=CCArray:create()
        for k,v in pairs(allReward) do
            local function showNextMsg()
                if self and self.refreshData.tableView and v then
                    table.insert(temAllReward,v)
                    if k==SizeOfTable(allReward) then
                        isEnd=true
                        showBtn()
                    end
                    self.refreshData.tableView:insertCellAtIndex(k-1)
                end
            end
            local callFunc1=CCCallFuncN:create(showNextMsg)
            local delay=CCDelayTime:create(1)

            acArr:addObject(delay)
            acArr:addObject(callFunc1)
        end
        local seq=CCSequence:create(acArr)
        self.bgLayer:runAction(seq)
    end

    if isMoreReward==false then
        showBtn()
    end

    self:addForbidSp(self.bgLayer,size,layerNum)

    return self.dialogLayer
end