powerGuideSmallDialog=smallDialog:new()

function powerGuideSmallDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    nc.layerNum = nil -- 层级
    nc.bgSize = nil
    nc.classIndex = nil
    nc.classData = nil
    nc.callBack = nil
    nc.tv = nil
    nc.cellHeight=180
    spriteController:addPlist("public/commonBtn1.plist")
    spriteController:addTexture("public/commonBtn1.png")
    return nc
end


--layerNum:层次
function powerGuideSmallDialog:init(layerNum,classIndex,classData,nameStr,callFun,closeFun)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/resource_youhua.plist")
    spriteController:addTexture("public/resource_youhua.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    self.layerNum = layerNum
    self.classIndex = classIndex
    self.classData = classData
    print("SizeOfTable(self.classData)",SizeOfTable(self.classData))
    self.callBack = callFun

    if G_getCurChoseLanguage() =="ru" then
        self.cellHeight =260
    end


    if self.classIndex == 5 then--异星武器
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/superWeapon/swChallenge.plist")
    end

    self.bgSize=CCSizeMake(560,670)
    local totalH=100
    local heightFlag=false
    local cellNum=SizeOfTable(self.classData)
    totalH=cellNum*self.cellHeight+totalH
    if totalH<self.bgSize.height then
        self.bgSize.height=totalH
        heightFlag=true
    end

    local fontSize = 32
    local function close()
        PlayEffect(audioCfg.mouseClick)    
        if closeFun then
            closeFun()
        end
        self:close()
    end
    local dialogBg,titleBg,titleLb,closeBtnItem,closeBtn=G_getNewDialogBg(self.bgSize,nameStr,fontSize,nil,layerNum,true,close,nil)

    -- local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),function()end)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5,0.5))
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setTouchPriority(-(layerNum-1)*20-2)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
    self.dialogLayer:addChild(self.bgLayer,2)

    
    -- local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close)
    -- closeBtnItem:setPosition(0,0)
    -- closeBtnItem:setAnchorPoint(CCPointMake(0,0))
     
    -- local closeBtn = CCMenu:createWithItem(closeBtnItem)
    -- closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    -- closeBtn:setPosition(ccp(dialogBg:getContentSize().width-closeBtnItem:getContentSize().width,dialogBg:getContentSize().height-closeBtnItem:getContentSize().height))
    -- dialogBg:addChild(closeBtn)


    -- 点击阴影区域关闭面板
    local function touchBackSpFunc()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        -- return self:close()
    end
    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchBackSpFunc)
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    -- touchDialogBg:setOpacity(50)
    touchDialogBg:setAnchorPoint(ccp(0.5,0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
    self.dialogLayer:addChild(touchDialogBg,1)



    local tvX,tvY=10,20
    local tvHeight = self.bgSize.height-95
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgSize.width-20,tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.tv:setPosition(ccp(tvX,tvY))
    self.tv:setMaxDisToBottomOrTop(110)
    if heightFlag then
        self.tv:setMaxDisToBottomOrTop(0)
        self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-1)
    end
    dialogBg:addChild(self.tv,1)

    sceneGame:addChild(self.dialogLayer,self.layerNum)
end


function powerGuideSmallDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        if self.classData ~= nil then
            return SizeOfTable(self.classData)
        end
        return 0
    elseif fn=="tableCellSizeForIndex" then
        return  CCSizeMake(self.bgSize.width-20,self.cellHeight)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local cellWidth = self.bgSize.width-20
        local cellHeight = self.cellHeight
        local itemIndex = idx+1
        local itemData = self.classData[itemIndex]
        if itemData then
            local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),function () end)
            backSprie:setContentSize(CCSizeMake(cellWidth, cellHeight-5))
            backSprie:ignoreAnchorPointForPosition(false)
            backSprie:setAnchorPoint(ccp(0,0))
            backSprie:setPosition(ccp(0,5))
            cell:addChild(backSprie,1)

            local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
            pointSp1:setPosition(ccp(5,backSprie:getContentSize().height/2))
            backSprie:addChild(pointSp1)
            local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
            pointSp2:setPosition(ccp(backSprie:getContentSize().width-5,backSprie:getContentSize().height/2))
            backSprie:addChild(pointSp2)
            
            local function onClickIcon(object,fn,tag)
                if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                      do return end
                    else
                      base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    self:showCellTip(tag)
                end
            end
            local percent = itemData[1]
            local clickable

            --部分图标显示时再计算，减轻数据计算时的压力
            local  upStr,downStr,icon,picStr,addBg,clickable = self:getShowIcon(itemIndex,onClickIcon,itemData)
            
            if clickable == nil then--在当前页面不能判断是否可点击的才在统一数据计算时计算
                clickable  = itemData[2]
            end

            if icon == nil and picStr == nil then
                if type(itemData[4])=="string" then
                    picStr = itemData[4]
                elseif type(itemData[4])=="table" then
                    picStr = itemData[4][1]
                    addBg = itemData[4][2]
                end
            end

            if upStr == nil and itemData[5] then
                upStr = itemData[5]
            end

            if downStr == nil and itemData[3] then
                downStr = itemData[3]
            end
            
            if picStr then
                if addBg then
                    icon = LuaCCSprite:createWithSpriteFrameName(addBg,onClickIcon)
                    local icon1
                    -- if self.classIndex==powerGuideVoApi.CLASS_hero and itemIndex==1 then
                    --     icon1=CCSprite:create(picStr)
                    -- else
                        icon1=CCSprite:createWithSpriteFrameName(picStr)
                    -- end
                    if not icon1 then
                        icon1=CCSprite:create(picStr)
                    end
                     -- = LuaCCSprite:createWithSpriteFrameName(picStr,onClickIcon)
                    local max = math.max(icon1:getContentSize().width,icon1:getContentSize().height)
                    icon1:setScale((icon:getContentSize().width - 15)/max)
                    icon1:setPosition(getCenterPoint(icon))
                    icon:addChild(icon1,2)
                    icon1:setTag(99)
                else 
                    icon = LuaCCSprite:createWithSpriteFrameName("Icon_BG.png",onClickIcon)
                    icon:setOpacity(0)
                     local icon1
                    -- if self.classIndex==powerGuideVoApi.CLASS_hero and itemIndex==1 then
                    --     icon1=CCSprite:create(picStr)
                    -- else
                        icon1=CCSprite:createWithSpriteFrameName(picStr)
                    -- end
                    if not icon1 then
                        icon1=CCSprite:create(picStr)
                    end
                     -- = LuaCCSprite:createWithSpriteFrameName(picStr,onClickIcon)
                    local max = math.max(icon1:getContentSize().width,icon1:getContentSize().height)
                    icon1:setScale((icon:getContentSize().width - 15)/max)
                    icon1:setPosition(getCenterPoint(icon))
                    icon:addChild(icon1,2)
                    icon1:setTag(88)

                end 
            end

            local startX=70
            if icon then
                local scale=100/icon:getContentSize().width
                icon:setScale(scale)
                icon:setPosition(ccp(startX,cellHeight/2))
                icon:setTag(itemIndex)
                icon:setTouchPriority(-(self.layerNum-1)*20-3)
                cell:addChild(icon,2)
                local child1=tolua.cast(icon:getChildByTag(99),"CCSprite")
                if child1 then
                    local max = math.max(child1:getContentSize().width,child1:getContentSize().height)
                    child1:setScale(1/scale*90/max)
                end
                local child2=tolua.cast(icon:getChildByTag(88),"CCSprite")
                if child2 then
                    local max = math.max(child2:getContentSize().width,child2:getContentSize().height)
                    child2:setScale(1/scale*100/max)
                end
            end

            local addX=70
            local upLb=GetTTFLabelWrap(upStr,24,CCSizeMake(G_VisibleSizeWidth-350,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom,"Helvetica-bold")
            upLb:setAnchorPoint(ccp(0,0))
            upLb:setPosition(ccp(startX+addX-5,cellHeight/2+22))
            cell:addChild(upLb,3)
            upLb:setColor(G_ColorGreen)

            percent = percent * 100

            if percent>=100 then
                AddProgramTimer(cell,ccp(0,0),518,nil,nil,"res_progressbg.png","resyellow_progress.png",519)
            else
                AddProgramTimer(cell,ccp(0,0),518,nil,nil,"res_progressbg.png","resblue_progress.png",519)
            end
            
            
            
            local powerBar = tolua.cast(cell:getChildByTag(518),"CCProgressTimer")
            local setScaleX=310/powerBar:getContentSize().width
            local setScaleY=40/powerBar:getContentSize().height
            powerBar:setScaleX(setScaleX)
            powerBar:setScaleY(setScaleY)
            powerBar:setAnchorPoint(ccp(0,0.5))
            powerBar:setPosition(ccp(startX+addX-5,cellHeight/2))
            powerBar:setPercentage(percent)

            local powerBarBg=tolua.cast(cell:getChildByTag(519),"CCSprite")
            powerBarBg:setScaleX(setScaleX)
            powerBarBg:setScaleY(setScaleY)
            powerBarBg:setAnchorPoint(ccp(0,0.5))
            powerBarBg:setPosition(ccp(startX+addX-5,cellHeight/2))

            local percentLb=GetTTFLabel(string.format("%.2f",percent).."%",20)
            percentLb:setAnchorPoint(ccp(0.5,0.5))
            percentLb:setPosition(powerBar:getContentSize().width/2,powerBar:getContentSize().height/2)
            powerBar:addChild(percentLb,4)
            percentLb:setScaleX(1/setScaleX)
            percentLb:setScaleY(1/setScaleY)


            local lbSize=20
            if G_getCurChoseLanguage()=="ar" then
                lbSize=20
            end
            local downLb=GetTTFLabelWrap(downStr,lbSize,CCSizeMake(G_VisibleSizeWidth-350,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            downLb:setAnchorPoint(ccp(0,1))
            downLb:setPosition(ccp(startX+addX-5,cellHeight/2-22))
            cell:addChild(downLb,5)


            local function onClickGoto(tag,object)
              if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                  do return end
                else
                  base.setWaitTime=G_getCurDeviceMillTime()
                end
                if self.callBack then
                    self.callBack(self.classIndex,tag)
                    if self.classIndex == powerGuideVoApi.CLASS_alienweapon then
                        -- CCSpriteFrameCache:removeSpriteFramesFromFile():addSpriteFramesWithFile("public/superWeapon/swChallenge.plist")
                        -- CCTextureCache:sharedTextureCache():removeTextureForKey("public/superWeapon/swChallenge.pvr.ccz")
                        
                    end
                    self:close()
                end
              end
            end
            local gotoMenu=GetButtonItem("gotoBtn.png","gotoBtn_down.png","gotoBtn_down.png",onClickGoto,itemIndex,nil,25)
            -- gotoMenu:setScale(0.8)
            gotoMenu:setEnabled(clickable)
            local gotoBtn=CCMenu:createWithItem(gotoMenu)
            gotoBtn:setTouchPriority(-(self.layerNum-1)*20-3)
            gotoBtn:setPosition(ccp(cellWidth-50,cellHeight/2))
            cell:addChild(gotoBtn,6)
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

--得到显示图标信息
function powerGuideSmallDialog:getShowIcon(itemIndex,onClickIcon,itemData)
    local percent = itemData[1]
    local downData = itemData[3]
    local picStr,addBg,icon
    local upStr,downStr
    local clickable
    if self.classIndex == powerGuideVoApi.CLASS_player then
        if itemIndex == 1 then--统率等级
            picStr = "item_shuji_04.png"
            upStr=getlocal("powerGuide_leaderPercent",{""})
            downStr=getlocal("powerGuide_leftLeader",{bagVoApi:getItemNumId(20)})
        elseif itemIndex == 2 then--技能等级
            picStr = "item_xunzhang_02.png"
            upStr=getlocal("powerGuide_skillPercent",{""})
            downStr=getlocal("powerGuide_leftSkill",{bagVoApi:getItemNumId(19)})
        elseif itemIndex == 3 then
            picStr = "Icon_ke_yan_zhong_xin.png"
            upStr=getlocal("powerGuide_techPercent",{""})
        elseif itemIndex == 4 then
            picStr = "alliance_icon.png"
            upStr=getlocal("powerGuide_allianceSkillPercent",{""})
            if(base.isAllianceOpen~=true)then
                upStr=getlocal("alliance_notOpen")
            end
        elseif itemIndex == 5 then
            upStr=getlocal("powerGuide_tankStrength",{""})
        elseif itemIndex == 6 then
            picStr = "Icon_tan_ke_gong_chang.png"
            upStr=getlocal("powerGuide_tankNumPercent",{""})
        elseif itemIndex == 7 then
            local curLevel=playerVoApi:getPlayerLevel()
            picStr = playerVoApi:getPlayerBuildPic(curLevel)
            addBg = "Icon_BG.png"
            upStr=getlocal("powerGuide_up1_7")
        end
    elseif self.classIndex == powerGuideVoApi.CLASS_armor then
        if itemIndex == 1 then--海兵方阵品质
            picStr = "armorMatrix_6.png"
            upStr = getlocal("powerGuide_up2_1")
            addBg = (base.armorbr==1) and "equipBg_orange.png" or "equipBg_purple.png"
        elseif itemIndex == 2 then--海兵方阵强化等级
            picStr = "armorMatrix_1.png"
            upStr = getlocal("accessory_lv",{""})
            addBg = "equipBg_gray.png"
        end

    elseif self.classIndex == powerGuideVoApi.CLASS_accessory then
        if itemIndex == 1 then
            if(base.ifAccessoryOpen~=1)then
                icon=GetBgIcon("mainBtnAccessory.png",onClickIcon,nil,80,100)
                downStr=""
            else
                icon=accessoryVoApi:getFragmentIcon("f0",80,100,onClickIcon)
                upStr=getlocal("powerGuide_accessoryQualityPercent",{""})
                -- local unEquipedNum=powerGuideVoApi:getUnEquipedPurpleAccessoryNum()
                downStr=getlocal("powerGuide_accessoryQualityDesc",downData)
            end

        elseif itemIndex == 2 then
            local vo=powerGuideVoApi:getMinUpgradeAccessory()
            if(vo)then
                icon=accessoryVoApi:getAccessoryIcon(vo.type,80,100,onClickIcon)
            else
                icon=GetBgIcon("mainBtnAccessory.png",onClickIcon,nil,80,100)
            end
            upStr=getlocal("accessory_lv",{""})
            local canUpgrade=powerGuideVoApi:checkCanUpgrade()
            clickable = false
            if(canUpgrade==0)then
                downStr=getlocal("powerGuide_accessoryUpgradeDesc")
                clickable=true
            elseif(canUpgrade==2)then
                downStr=getlocal("resourcelimit")
                clickable=true
            elseif(canUpgrade==false)then
                downStr=getlocal("powerGuide_accessoryUpgradeDesc2")
                clickable=false
            end
            if(base.ifAccessoryOpen~=1)then
                downStr=""
                clickable=false
            end
        elseif itemIndex == 3 then
            local vo=powerGuideVoApi:getMinSmeltAccessory()
            if(vo)then
                icon=accessoryVoApi:getAccessoryIcon(vo.type,80,100,onClickIcon)
            else
                icon=GetBgIcon("mainBtnAccessory.png",onClickIcon,nil,80,100)
            end
            upStr=getlocal("accessory_rank",{""})

            local canSmelt=powerGuideVoApi:checkCanSmelt()
            clickable = false
            if(canSmelt==0)then
                downStr=getlocal("powerGuide_accessorySmeltDesc")
                clickable=true
            elseif(canSmelt==false)then
                downStr=getlocal("powerGuide_accessorySmeltDesc2")
                clickable=false
            elseif(canSmelt>=20 and canSmelt<30)then
                downStr=getlocal("powerGuide_accessorySmeltDesc3")
                clickable=true
            end
            if(base.ifAccessoryOpen~=1)then
                downStr=""
                clickable=false
            end
        elseif itemIndex == 4 then
            -- purpleBg.png
            icon=GetBgIcon("tank1accessory_1.png",onClickIcon,"purpleBg.png",80,100)
            upStr = getlocal("powerGuide_up3_4")
            if percent < 1  then
                clickable = true
                downStr = getlocal("powerGuide_down"..self.classIndex.."_"..itemIndex.."_0",downData)
            else
                clickable = false
                downStr = getlocal("powerGuide_down"..self.classIndex.."_"..itemIndex.."_1")
            end
            -- 判断是否有紫色配件（是否能精炼）
            local equip=accessoryVoApi.equip
            local flag=false
            if equip then
                for tid,value in pairs(equip) do
                    for pid,vo in pairs(value) do
                        if vo then
                            if vo:getConfigData("quality")>2 then
                                flag=true
                                break
                            end
                        end
                    end
                    if flag then
                        break
                    end
                end
            end
            if not flag then
                clickable = false
                downStr = getlocal("accessory_noSinc")
            end
        elseif itemIndex == 5 then
            icon=GetBgIcon("tank1accessory_1.png",onClickIcon,"orangeBg.png",80,100)
            upStr = getlocal("powerGuide_up3_5")
            if percent < 1  then
                clickable = true
                downStr = getlocal("powerGuide_down"..self.classIndex.."_"..itemIndex.."_0",downData)
            else
                clickable = false
                downStr = getlocal("powerGuide_down"..self.classIndex.."_"..itemIndex.."_1")
            end
            -- 判断是否有橙色配件并绑定（是否能精炼）
            local equip=accessoryVoApi.equip
            local flag=false
            if equip then
                for tid,value in pairs(equip) do
                    for pid,vo in pairs(value) do
                        if vo then
                            if vo:getConfigData("quality")>3 and vo.bind==1 and base.accessoryTech==1 then
                                flag=true
                                break
                            end
                        end
                    end
                    if flag then
                        break
                    end
                end
            end
            if not flag then
                clickable = false
                downStr = getlocal("accessory_noTech")
            end
        end
        if(base.ifAccessoryOpen~=1)then
            upStr=getlocal("alliance_notOpen")
        end
    elseif self.classIndex == powerGuideVoApi.CLASS_hero then
        local sbIcon = "hero_icon_1.png"
        picStr ="ship/Hero_Icon/"..sbIcon
        if platCfg.platCfgHeroCartoonPhoto[G_curPlatName()]~=nil then
            picStr ="ship/Hero_Icon_Cartoon/"..sbIcon
        end
        addBg = "Icon_BG.png"
        if itemIndex == 1 then
            addBg = "orangeBg.png"
            local bestHeroId = powerGuideVoApi:getMaxQualityHero()
            local heroIcon=sbIcon
            if bestHeroId then
                heroIcon = heroListCfg[bestHeroId]["heroIcon"]
            end
            picStr ="ship/Hero_Icon/"..heroIcon
            if platCfg.platCfgHeroCartoonPhoto[G_curPlatName()]~=nil then
                picStr ="ship/Hero_Icon_Cartoon/"..heroIcon
            end
        elseif itemIndex == 3 then
            local bestHeroId = powerGuideVoApi:getMaxQualityHero()
            if bestHeroId then
                -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/hero/heroSkillsImage.plist")
                local sId = heroListCfg[bestHeroId]["skills"][1][1]
                local cfg = heroSkillCfg[sId]
                if cfg then
                    picStr= heroVoApi:getSkillIconBySid(sId)
                end
                addBg = nil
            end
        elseif itemIndex == 4 then
            picStr = "heroEquipLabIcon.png"
            addBg = nil
        elseif itemIndex == 5 then
            picStr = "adj_funcIcon.png"
            addBg = nil
        end
        
        if percent < 1  then
            clickable = true
            downStr = getlocal("powerGuide_down"..self.classIndex.."_"..itemIndex.."_0",downData)
        else
            clickable = false
            downStr = getlocal("powerGuide_down"..self.classIndex.."_"..itemIndex.."_1")
        end
    elseif self.classIndex == powerGuideVoApi.CLASS_alienweapon then
        
        if percent < 1  then
            clickable = true
            downStr = getlocal("powerGuide_down"..self.classIndex.."_"..itemIndex.."_0",downData)
        else
            clickable = false
            downStr = getlocal("powerGuide_down"..self.classIndex.."_"..itemIndex.."_1")
        end
        local challengeVo=superWeaponVoApi:getSWChallenge()
        if itemIndex==1 or itemIndex==2 then
            if itemIndex==1 then
                picStr="superWeaponIcon5.png"
            else
                picStr="superWeaponIcon1.png"
            end
            
            if challengeVo.maxClearPos==0 then
                clickable=false
                if itemIndex==1 then
                    downStr=getlocal("super_weapon_noQuality")
                else
                    downStr=getlocal("super_weapon_noLevel")
                end
            end
        else
            picStr="sw_4.png"
            if challengeVo.maxClearPos<20 then
                clickable=false
                downStr=getlocal("super_weapon_noCrystal")
            end
        end
        
    elseif self.classIndex == powerGuideVoApi.CLASS_alientech then
        if(itemIndex==1)then--常规军舰
            picStr = "TankLv5.png"
            upStr = getlocal("alien_tech_common_tank")..":"
        elseif(itemIndex==2)then--特战军舰
            picStr = "wukelanLv3.png"
            upStr = getlocal("alien_tech_special_tank")..":"
        end
        if percent < 1  then
            clickable = true
            downStr = getlocal("powerGuide_down"..self.classIndex.."_1_0",downData)
        else
            clickable = false
            local typeStr
            if itemIndex == 1 then
                typeStr = getlocal("alien_tech_common_tank") 
            elseif itemIndex == 2 then
                typeStr = getlocal("alien_tech_special_tank")
            end
            downStr = getlocal("powerGuide_down"..self.classIndex.."_1_1",{typeStr})
        end
    elseif self.classIndex == powerGuideVoApi.CLASS_superequip then
        if(itemIndex==1)then--战斗类装备品质
            picStr = "public/emblem/icon/emblemIcon_e63.png"
            addBg = "equipBg_orange.png"
        elseif(itemIndex==2)then--战斗类装备等级
            picStr = "public/emblem/icon/emblemIcon_e52.png"
            addBg = "equipBg_purple.png"
        end

        if percent < 1  then
            clickable = true
            downStr = getlocal("powerGuide_down"..self.classIndex.."_"..itemIndex.."_0",downData)
        else
            clickable = false
            downStr = getlocal("powerGuide_down"..self.classIndex.."_"..itemIndex.."_1")
        end
    elseif self.classIndex == powerGuideVoApi.CLASS_plane then
        if(itemIndex==1)then--战斗类装备品质
            picStr = "public/plane/icon/plane_skill_icon_s10.png"
            addBg = "equipBg_orange.png"
        elseif(itemIndex==2)then--战斗类装备等级
            picStr = "public/plane/icon/plane_skill_icon_s5.png"
            addBg = "equipBg_purple.png"
        elseif(itemIndex==3)then--战机改装
            picStr = "planeRefit_powerGuideIcon.png"
            -- addBg = "equipBg_orange.png"
        end

        if percent < 1  then
            clickable = true
            downStr = getlocal("powerGuide_down"..self.classIndex.."_"..itemIndex.."_0",downData)
        else
            clickable = false
            downStr = getlocal("powerGuide_down"..self.classIndex.."_"..itemIndex.."_1")
        end
    elseif self.classIndex == powerGuideVoApi.CLASS_strategy then --战略中心
        clickable = true
        if itemIndex == 1 then
            picStr = "sc_powerGuideIcon_1.png"
        elseif itemIndex == 2 then
            picStr = "sc_powerGuideIcon_2.png"
        end
        downStr = getlocal("powerGuide_down" .. self.classIndex .. "_" .. itemIndex, downData)
    elseif self.classIndex == powerGuideVoApi.CLASS_airship then --战争飞艇
        clickable = true
        if itemIndex == 1 then
            picStr = "airShip_bossIcon_7.png"
        end
        downStr = getlocal("powerGuide_down" .. self.classIndex .. "_" .. itemIndex, downData)
    end

    if upStr == nil then
        upStr = getlocal("powerGuide_up"..self.classIndex.."_"..itemIndex)
    end

    return upStr,downStr,icon,picStr,addBg,clickable
end


function powerGuideSmallDialog:showCellTip(id)
    local str
    local param
    if self.classIndex == powerGuideVoApi.CLASS_player then
        if id < 5 then
            str=getlocal("powerGuide_tip"..id)
        elseif id < 7 then
            str=getlocal("powerGuide_tip"..(id + 3))
        else
            str=getlocal("powerGuide_tip1_7")
        end
    elseif self.classIndex == powerGuideVoApi.CLASS_accessory then
        if(id==1)then
            if(accessoryCfg.maxQuality==3)then
                param=getlocal("accessory_purpleQuality")
            elseif(accessoryCfg.maxQuality==4)then
                param=getlocal("accessory_orangeQuality")
            elseif(accessoryCfg.maxQuality==5)then
                param=getlocal("accessory_redQuality")
            end
            str=getlocal("powerGuide_tip7",{param})
        elseif id == 2 then
            str=getlocal("powerGuide_tip5")
        elseif id == 3 then
            str=getlocal("powerGuide_tip6")
        elseif id == 4 or id == 5 then
            str = getlocal("powerGuide_tip"..self.classIndex.."_"..id)
        else
            str=getlocal("powerGuide_tip6")
        end
    elseif self.classIndex == powerGuideVoApi.CLASS_alientech then
        local typeStr
        if id == 1 then
            typeStr = getlocal("alien_tech_common_tank") 
        elseif id == 2 then
            typeStr = getlocal("alien_tech_special_tank")
        end
        str = getlocal("powerGuide_tip6_1",{typeStr})
    else
        str = getlocal("powerGuide_tip"..self.classIndex.."_"..id)
    end
    PlayEffect(audioCfg.mouseClick)
    local tabStr={}
    local tabColor ={}
    local td=smallDialog:new()
    tabStr = {"\n",str,"\n"}
    local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,{nil,G_ColorYellow,nil})
    sceneGame:addChild(dialog,self.layerNum+1)
end


function powerGuideSmallDialog:dispose()
    if self.bgLayer~=nil then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer = nil
    end

    if self.dialogLayer~=nil then
        self.dialogLayer:removeFromParentAndCleanup(true)
        self.dialogLayer = nil
    end

    self.bgSize = nil
    self.layerNum = nil
    self.classIndex = nil
    self.classData = nil
    self.callBack = nil
    self.tv = nil
    spriteController:removePlist("public/commonBtn1.plist")
    spriteController:removeTexture("public/commonBtn1.png")
    spriteController:removePlist("public/resource_youhua.plist")
    spriteController:removeTexture("public/resource_youhua.png")
end

