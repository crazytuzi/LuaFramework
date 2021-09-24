
heroInfoDialog = commonDialog:new()

function heroInfoDialog:new(heroVo, parent, layerNum)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    nc.leftBtn = nil
    nc.expandIdx = {}
    nc.layerNum = layerNum
    nc.heroVo = heroVo
    nc.parent = parent
    nc.sbSkillNum = 0 --普通技能的个数
    nc.nbSkillNum = 0 --授勋技能的个数
    return nc
end

function heroInfoDialog:updateSkillNum()
    self.sbSkillNum = SizeOfTable(heroListCfg[self.heroVo.hid].skills)
    if heroVoApi:heroHonorIsOpen() == true and self.heroVo and self.heroVo.hid then
        self.nbSkillNum = #heroVoApi:getUsedRealiseSkill(self.heroVo.hid)
    end
end

--设置或修改每个Tab页签
function heroInfoDialog:resetTab()
    spriteController:addPlist("public/nbSkill.plist")
    spriteController:addTexture("public/nbSkill.png")
    spriteController:addPlist("public/datebaseShow.plist")
    spriteController:addTexture("public/datebaseShow.png")
    spriteController:addPlist("public/acAnniversary.plist")
    spriteController:addTexture("public/acAnniversary.png")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage2.plist")
    local index = 0
    local tabHeight = 0
    for k, v in pairs(self.allTabs) do
        local tabBtnItem = v
        
        if index == 0 then
            tabBtnItem:setPosition(tabBtnItem:getContentSize().width / 2 + 20, self.bgSize.height - tabBtnItem:getContentSize().height / 2 - 80 - tabHeight)
        elseif index == 1 then
            tabBtnItem:setPosition(tabBtnItem:getContentSize().width / 2 + 23 + tabBtnItem:getContentSize().width, self.bgSize.height - tabBtnItem:getContentSize().height / 2 - 80 - tabHeight)
        elseif index == 2 then
            tabBtnItem:setPosition(521, self.bgSize.height - tabBtnItem:getContentSize().height / 2 - 80 - tabHeight)
            
        end
        if index == self.selectedTabIndex then
            tabBtnItem:setEnabled(false)
        end
        index = index + 1
    end
    
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 20, G_VisibleSizeHeight - 100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth / 2, self.bgLayer:getContentSize().height / 2 - 36))
    
    self:updateSkillNum()
    self:initLayer()
    local function honorListener(event, data)
        self:dealWithEvent(event, data)
    end
    self.honorListener = honorListener
    eventDispatcher:addEventListener("hero.honor", honorListener)
end

function heroInfoDialog:initLayer()
    local heroIcon = heroVoApi:getHeroIcon(self.heroVo.hid, self.heroVo.productOrder)
    heroIcon:setPosition(ccp(130, G_VisibleSizeHeight - 180))
    heroIcon:setTag(201)
    self.bgLayer:addChild(heroIcon)
    
    local function itemTouch(...)
        -- 这一句打开之后，当滑动下面的tableView时就不能在点击了
        -- if self.tv:getIsScrolled()==true then
        --   return
        -- end
        
        if G_checkClickEnable() == false then
            return
        end
        
        -- 显示英雄信息
        local td = smallDialog:new()
        
        -- 获取hero描述lable的高度，动态的传给smallDialog
        local lable = GetTTFLabelWrap(heroVoApi:getHeroDes(self.heroVo.hid), 25, CCSize(400, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        
        local dialog = td:initHeroInfo("PanelPopup.png", CCSizeMake(500, 200 + lable:getContentSize().height + 25 + 60), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, true, true, self.layerNum + 1, self.heroVo, 28, tabColor)
        sceneGame:addChild(dialog, self.layerNum + 1)
        PlayEffect(audioCfg.mouseClick)
        
    end
    -- 添加英雄信息按钮
    local heroInfoItem = GetButtonItem("hero_infoBtn.png", "hero_infoBtn.png", "hero_infoBtn.png", itemTouch, 11, nil, nil)
    local menu = CCMenu:createWithItem(heroInfoItem)
    menu:setPosition(ccp(555, G_VisibleSizeHeight - 140))
    menu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    self.bgLayer:addChild(menu)
    
    local lbx = 250
    local exp, per = heroVoApi:getHeroLeftExp(self.heroVo)
    
    --local mLv =  ..self.heroVo.level
    local mLv = G_LV()..self.heroVo.level.."/"..G_LV()..heroCfg.heroLevel[self.heroVo.productOrder]
    
    if heroVoApi:isHeroMaxLv(self.heroVo.hid, self.heroVo.productOrder) then
        mLv = G_LV()..self.heroVo.level.." ("..getlocal("alliance_lvmax") .. ")"
    end
    
    local color = heroVoApi:getHeroColor(self.heroVo.productOrder)
    local sid = heroListCfg[self.heroVo.hid].fusionId
    local soulNum = heroVoApi:getSoulNumListBySid(sid)
    local soulNumStr = getlocal("soulNum", {soulNum})
    local str4Size = 26
    if G_getCurChoseLanguage() == "ru" then
        str4Size = 19
    end
    local needExpStr
    --UI
    local lbTB = {
        {str = getlocal(heroListCfg[self.heroVo.hid].heroName), size = 24, pos = {lbx, G_VisibleSizeHeight - 130}, aPos = {0, 0.5}, color = color, tag = 104, bold = true},
        {str = mLv, size = 20, pos = {lbx, G_VisibleSizeHeight - 170}, aPos = {0, 0.5}, tag = 101},
        {str = soulNumStr, size = 20, pos = {lbx, G_VisibleSizeHeight - 210}, aPos = {0, 0.5}, tag = 103},
        {str = getlocal("upgradeExpRequired", {exp}), size = 20, pos = {lbx, G_VisibleSizeHeight - 270}, aPos = {0, 0.5}, tag = 102},
        
    }
    for k, v in pairs(lbTB) do
        local strLb = GetTTFLabel(v.str, v.size, v.bold)
        if v.aPos then
            strLb:setAnchorPoint(ccp(v.aPos[1], v.aPos[2]))
        end
        if v.color then
            strLb:setColor(v.color)
        end
        strLb:setPosition(ccp(v.pos[1], v.pos[2]))
        self.bgLayer:addChild(strLb)
        if(self.heroVo.productOrder > heroFeatCfg.fusionLimit and k == 3)then
            strLb:setVisible(false)
        elseif(heroVoApi:isHeroMaxLv(self.heroVo.hid, self.heroVo.productOrder) and k == 4)then
            if(self.heroVo.productOrder < heroVoApi:getHeroMaxProduct())then
                strLb:setString(getlocal("hero_honor_breakToLvlup"))
                strLb:setPositionY(G_VisibleSizeHeight - 240)
            else
                strLb:setVisible(false)
            end
        end
        if v.tag ~= nil then
            strLb:setTag(v.tag)
        end
        if k == 2 then
            local checkInfoBtn = LuaCCSprite:createWithSpriteFrameName("datebaseShow2.png", function ()
                heroVoApi:showMaxHeroInfo(self.heroVo.hid, self.layerNum + 1)
            end)
            checkInfoBtn:setAnchorPoint(ccp(0, 0.5))
            checkInfoBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
            checkInfoBtn:setTag(399)
            checkInfoBtn:setPosition(strLb:getPositionX() + strLb:getContentSize().width + 5, strLb:getPositionY())
            self.bgLayer:addChild(checkInfoBtn)
        end
    end
    -- atk={20,0.1}, --增加伤害
    --       hlp={20,0.1}, --减少伤害
    --       hit={1,0.1}, --命中
    --       eva={1,0.1}, --闪避
    --       cri={1,0.1}, --暴击
    --       res={1,0.1}, --免暴
    local atb = heroVoApi:getAddBuffTb(self.heroVo)
    
    local tb = {atk = {icon = "attributeARP.png", lb = {getlocal("dmg"), }},
        hlp = {icon = "attributeArmor.png", lb = {getlocal("hlp"), }},
        hit = {icon = "skill_01.png", lb = {getlocal("sample_skill_name_101"), }},
        eva = {icon = "skill_02.png", lb = {getlocal("sample_skill_name_102"), }},
        cri = {icon = "skill_03.png", lb = {getlocal("sample_skill_name_103"), }},
        res = {icon = "skill_04.png", lb = {getlocal("sample_skill_name_104"), }},
        first = {icon = "positiveHead.png", lb = {getlocal("firstValue"), }},
    }
    self.adTb = {}
    for k, v in pairs(heroListCfg[self.heroVo.hid].heroAtt) do
        table.insert(self.adTb, k)
    end
    local temH = 80
    local temY = 270
    
    local equipOpenLv = base.heroEquipOpenLv or 30
    if base.he == 1 and playerVoApi:getPlayerLevel() >= equipOpenLv then
        local newAllAttList = {}
        self.equipAttList, newAllAttList = heroEquipVoApi:getAttListByHid(self.heroVo.hid, nil, self.heroVo.productOrder)
        for k, v in pairs(newAllAttList) do
            local ifHas = false
            for kk, vv in pairs(self.adTb) do
                if vv == v.key then
                    ifHas = true
                    break
                end
            end
            if ifHas == false then
                table.insert(self.adTb, v.key)
            end
        end
        self.lbTb2 = {}
        temH = 55
        temY = 285
    end
    
    if heroAdjutantVoApi:isOpen() == true and heroAdjutantVoApi:isCanEquipAdjutant(self.heroVo) then
        local adjAttTb
        adjAttTb, self.adjAttTb = heroAdjutantVoApi:getExtraProperty(self.heroVo.hid, 1)
        for k, v in pairs(adjAttTb) do
            local ifHas = false
            for kk, vv in pairs(self.adTb) do
                if vv == v.key then
                    ifHas = true
                    break
                end
            end
            if ifHas == false then
                table.insert(self.adTb, v.key)
            end
        end
        if self.lbTb2 == nil then
            self.lbTb2 = {}
        end
        temY = temY + 170
        local adjData = heroAdjutantVoApi:getAdjutant(self.heroVo.hid)
        local adjIconStartPosX
        local adjIconScapeW = 20
        for i = 1, 4 do
            local adjId, adjActivateState, adjCurLv, adjIconCallFunc
            if adjData and adjData[i] then
                if adjData[i][1] == 1 then
                    adjActivateState = true
                    adjIconCallFunc = function()
                        heroAdjutantVoApi:showAdjutantInfoDialog(self.layerNum + 1, self.heroVo, self)
                    end
                end
                if adjData[i][3] then
                    adjId = adjData[i][3]
                    adjCurLv = adjData[i][4]
                    adjIconCallFunc = function()
                        heroAdjutantVoApi:showInfoSmallDialog(self.layerNum + 1, {adjId, adjCurLv, nil, nil, i})
                    end
                end
            end
            local needStarLv = heroAdjutantVoApi:getAdjutantCfg().needHeroStar[i]
            if (not adjActivateState) and self.heroVo.productOrder >= needStarLv then
                adjIconCallFunc = function()
                    heroAdjutantVoApi:showAdjutantInfoDialog(self.layerNum + 1, self.heroVo, self)
                end
            end
            local adjIcon = heroAdjutantVoApi:getAdjutantIcon(adjId, adjActivateState, true, adjIconCallFunc, true, i)
            adjIcon:setScale(0.45)
            if adjIconStartPosX == nil then
                adjIconStartPosX = (G_VisibleSizeWidth - (adjIcon:getContentSize().width * adjIcon:getScale() * 4 + (4 - 1) * adjIconScapeW)) / 2
            end
            adjIcon:setAnchorPoint(ccp(0, 1))
            adjIcon:setPosition(adjIconStartPosX + (i - 1) * (adjIcon:getContentSize().width * adjIcon:getScale() + adjIconScapeW), G_VisibleSizeHeight - 315)
            adjIcon:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
            adjIcon:setTag(30000 + i)
            self.bgLayer:addChild(adjIcon)
            if adjId and adjCurLv then
                heroAdjutantVoApi:setAdjLevel(adjIcon, adjId, adjCurLv)
            else
                local tipsStr, tipsLabelColor
                if adjActivateState == true then --可装配
                    tipsStr = getlocal("skill_equip_empty2")
                    tipsLabelColor = G_ColorGreen
                else
                    if self.heroVo.productOrder >= needStarLv then --可激活
                        tipsStr = getlocal("heroAdjutant_activateTips")
                        tipsLabelColor = G_ColorGreen
                    else --将领星级达到x星可解锁
                        tipsStr = getlocal("heroAdjutant_starUnlockTips", nil, {needStarLv})
                        tipsLabelColor = G_ColorRed
                    end
                end
                local tipsLabel = GetTTFLabelWrap(tipsStr, 35, CCSizeMake(adjIcon:getContentSize().width - 6, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
                tipsLabel:setPosition(adjIcon:getContentSize().width / 2, 55)
                tipsLabel:setColor(tipsLabelColor)
                adjIcon:addChild(tipsLabel)
            end
        end
        local lineSp = CCSprite:createWithSpriteFrameName("LineCross.png");
        lineSp:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 310 - 165));
        self.bgLayer:addChild(lineSp, 1)
    end
    
    self.lbTb1 = {}
    local sPosX1 = 28
    local sPosX2 = 5
    local strSize2 = 33
    if G_getCurChoseLanguage() == "cn" or G_getCurChoseLanguage() == "ja" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() == "tw" then
        sPosX1 = 0
        sPosX2 = 0
        strSize2 = 40
    end
    local _size = 20
    -- for i=1,SizeOfTable(heroListCfg[self.heroVo.hid].heroAtt) do
    local strWidth = 230
    for i = 1, #self.adTb do
        local attackSp = CCSprite:createWithSpriteFrameName(tb[self.adTb[i]].icon)
        if self.adTb[i] == "first" then
            attackSp = GetBgIcon(tb[self.adTb[i]].icon, nil, nil, 55)
        end
        local iconScale = 50 / attackSp:getContentSize().width
        strSize2 = _size / iconScale
        attackSp:setAnchorPoint(ccp(0, 0.5))
        local width = i % 2
        local chanWidth = 230
        if width == 0 then
            width = 2
            chanWidth = chanWidth + 30
        else
            chanWidth = chanWidth - sPosX1
        end
        attackSp:setPosition(ccp(-180 + chanWidth * width, self.bgLayer:getContentSize().height - temY - math.ceil(i / 2) * temH))
        self.bgLayer:addChild(attackSp, 2)
        attackSp:setScale(iconScale)
        local strLb1 = GetTTFLabel(tb[self.adTb[i]].lb[1], strSize2)
        if self.adTb[i] == "first" then
            strLb1 = GetTTFLabel(tb[self.adTb[i]].lb[1], 20 / iconScale)
        end
        attackSp:addChild(strLb1)
        local txtWidth = strLb1:getContentSize().width * iconScale
        
        local strLb2
        if atb[self.adTb[i]] then
            strLb2 = GetTTFLabel("+"..atb[self.adTb[i]] .. "%", strSize2)
            attackSp:addChild(strLb2)
            self.lbTb1[i] = strLb2
            txtWidth = txtWidth + strLb2:getContentSize().width * iconScale + 5
        end
        
        local strLb3, lb3Value
        local equipOpenLv = base.heroEquipOpenLv or 30
        if base.he == 1 and playerVoApi:getPlayerLevel() >= equipOpenLv and self.equipAttList and SizeOfTable(self.equipAttList) then
            if self.equipAttList[self.adTb[i]] then
                strLb3 = GetTTFLabel("+"..self.equipAttList[self.adTb[i]].value.."%", strSize2)
                if self.adTb[i] == "first" then
                    strLb3 = GetTTFLabel("+"..self.equipAttList[self.adTb[i]].value, 20 / iconScale)
                end
                strLb3:setAnchorPoint(ccp(0, 0.5))
                txtWidth = txtWidth + strLb3:getContentSize().width * iconScale + 5
                attackSp:addChild(strLb3)
                self.lbTb2[i] = strLb3
                strLb3:setColor(G_ColorGreen)
                lb3Value = self.equipAttList[self.adTb[i]].value
            end
        end
        
        if heroAdjutantVoApi:isOpen() == true and heroAdjutantVoApi:isCanEquipAdjutant(self.heroVo) then
            if self.adjAttTb[self.adTb[i]] then
                if lb3Value then
                    strLb3:setString("+" .. lb3Value + self.adjAttTb[self.adTb[i]] .. "%")
                    if self.adTb[i] == "first" then
                        strLb3:setString("+" .. lb3Value + self.adjAttTb[self.adTb[i]])
                    end
                else
                    strLb3 = GetTTFLabel("+"..self.adjAttTb[self.adTb[i]] .. "%", strSize2)
                    if self.adTb[i] == "first" then
                        strLb3 = GetTTFLabel("+"..self.adjAttTb[self.adTb[i]], 20 / iconScale)
                    end
                    strLb3:setAnchorPoint(ccp(0, 0.5))
                    txtWidth = txtWidth + strLb3:getContentSize().width * iconScale + 5
                    attackSp:addChild(strLb3)
                    self.lbTb2[i] = strLb3
                    strLb3:setColor(G_ColorGreen)
                end
            end
        end
        
        local posX = attackSp:getContentSize().width + 10
        local posY = attackSp:getContentSize().height / 2
        local anchor = ccp(0, 0.5)
        if txtWidth > strWidth then
            strLb1:setAnchorPoint(ccp(0, 0))
            strLb1:setPosition(ccp(posX, posY + 5))
            posY = attackSp:getContentSize().height / 2 - 5
            anchor = ccp(0, 1)
        else
            strLb1:setAnchorPoint(ccp(0, 0.5))
            strLb1:setPosition(ccp(posX, posY))
            posX = posX + strLb1:getContentSize().width + 5
        end
        if strLb2 then
            strLb2:setAnchorPoint(anchor)
            strLb2:setPosition(ccp(posX, posY))
            posX = posX + strLb2:getContentSize().width + 5
        end
        if strLb3 then
            strLb3:setAnchorPoint(anchor)
            if strLb2 == nil then
                strLb1:setColor(G_ColorGreen)
            end
            strLb3:setPosition(posX, posY)
        end
    end
    
    AddProgramTimer(self.bgLayer, ccp(380, G_VisibleSizeHeight - 240), 10, nil, nil, "VipIconYellowBarBg.png", "VipIconYellowBar.png", 11, 0.6)
    self.timerSprite = tolua.cast(self.bgLayer:getChildByTag(10), "CCProgressTimer")
    self.timerSprite:setPercentage(per)
    self.timerSpriteBg = tolua.cast(self.bgLayer:getChildByTag(11), "CCSprite")
    if(heroVoApi:isHeroMaxLv(self.heroVo.hid, self.heroVo.productOrder))then
        self.timerSprite:setVisible(false)
        self.timerSpriteBg:setVisible(false)
    end
    
    local lineSp = CCSprite:createWithSpriteFrameName("LineCross.png");
    lineSp:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 310));
    self.bgLayer:addChild(lineSp, 1)
    
    --判断如果是满级为突破按钮 如果不是为升级按钮 会做不同的操作
    local function callBack()
        if self.heroVo.level < heroCfg.heroLevel[self.heroVo.productOrder] then
            -- require "luascript/script/game/scene/gamedialog/heroDialog/heroUpgradeDialog"
            -- local td=heroUpgradeDialog:new(self.heroVo,self,self.layerNum+1)
            
            -- local tbArr={}
            -- local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("heroUpgrade"),true,self.layerNum+1)
            -- sceneGame:addChild(dialog,self.layerNum+1)
            self:showUpgradeOrUpgrade2()
            
        else
            if(heroVoApi:heroHonorIsOpen() and heroVoApi:checkCanHonor(self.heroVo))then
                heroVoApi:showHonorTaskDialog(self.heroVo, self.layerNum + 1)
            else
                if self.heroVo.productOrder >= math.min(playerVoApi:getMaxLvByKey("unlockThroughLevel"), 4) then
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("throughMaxLv"), 30)
                    do
                        return
                    end
                end
                require "luascript/script/game/scene/gamedialog/heroDialog/heroBreakthroughDialog"
                local td = heroBreakthroughDialog:new(self.heroVo, self, self.layerNum + 1)
                
                local tbArr = {}
                local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("heroBreakthrough"), true, self.layerNum + 1)
                sceneGame:addChild(dialog, self.layerNum + 1)
            end
        end
    end
    
    local heroStr = getlocal("breakthrough")
    if self.heroVo.level < heroCfg.heroLevel[self.heroVo.productOrder] then
        heroStr = getlocal("upgradeBuild")
    elseif(heroVoApi:heroHonorIsOpen() and heroVoApi:checkCanHonor(self.heroVo))then
        heroStr = getlocal("hero_honor_doHonor")
    end
    
    local isMax
    if(self.heroVo.level < heroCfg.heroLevel[self.heroVo.productOrder])then
        isMax = false
    elseif(self.heroVo.productOrder >= heroVoApi:getHeroMaxProduct())then
        isMax = true
    else
        isMax = false
    end
    
    local okItem = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", callBack, nil, heroStr, 24 / 0.8, 101)
    okItem:setScale(0.8)
    local btnLb = okItem:getChildByTag(101)
    if btnLb then
        btnLb = tolua.cast(btnLb, "CCLabelTTF")
        btnLb:setFontName("Helvetica-bold")
    end
    local okBtn = CCMenu:createWithItem(okItem)
    okBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    okBtn:setAnchorPoint(ccp(1, 0.5))
    okBtn:setPosition(ccp(self.bgLayer:getContentSize().width / 2, 60))
    okBtn:setTag(202)
    if(isMax == false)then
        self.bgLayer:addChild(okBtn)
    end
    local function onShare()
        if G_checkClickEnable() == false then
            do
                return
            end
        end
        PlayEffect(audioCfg.mouseClick)
        local share = self:getShareData()
        if share then
            local message = getlocal("mything", {getlocal("heroTitle")}) .. ":" .. "【"..getlocal(heroListCfg[self.heroVo.hid].heroName) .. "】"
            local tipStr = getlocal("send_share_sucess", {getlocal("heroTitle")})
            G_shareHandler(share, message, tipStr, self.layerNum + 1)
        end
    end
    local shareItem = GetButtonItem("anniversarySend.png", "anniversarySendDown.png", "anniversarySendDown.png", onShare)
    local shareBtn = CCMenu:createWithItem(shareItem)
    shareBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    shareBtn:setPosition(555, G_VisibleSizeHeight - 210)
    self.bgLayer:addChild(shareBtn)
    
    if G_getCurChoseLanguage() == "cn" or G_getCurChoseLanguage() == "ja" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() == "tw" then
        shareBtn:setPosition(555, G_VisibleSizeHeight - 240)
    end
end

function heroInfoDialog:getShareData()
    if self.heroVo and self.adTb and self.sbSkillNum and self.nbSkillNum then
        local atb = heroVoApi:getAddBuffTb(self.heroVo)
        local share = {}
        share.heroVo = self.heroVo
        share.stype = 2 --将领分享类型
        share.name = playerVoApi:getPlayerName()
        share.hid = self.heroVo.hid --将领id
        share.lv = self.heroVo.level --将领等级
        share.gd = self.heroVo.productOrder --将领品阶
        share.ajt = heroAdjutantVoApi:encodeAdjutant(self.heroVo.hid) --将领副官数据
        local property = {} --属性加成
        local _, adjAttList = heroAdjutantVoApi:getExtraProperty(self.heroVo.hid, 1)
        for i = 1, #self.adTb do
            property[i] = {}
            local strLb2
            if atb[self.adTb[i]] then
                property[i][1] = atb[self.adTb[i]] .. "%"
            else
                property[i][1] = "-"
            end
            local pValue = 0
            local equipOpenLv = base.heroEquipOpenLv or 30
            if base.he == 1 and playerVoApi:getPlayerLevel() >= equipOpenLv and self.equipAttList and SizeOfTable(self.equipAttList) then
                if self.equipAttList[self.adTb[i]] then
                    -- property[i][2]=self.equipAttList[self.adTb[i]].value.."%"
                    -- if self.adTb[i]=="first" then
                    --   property[i][2]=self.equipAttList[self.adTb[i]].value
                    -- end
                    pValue = self.equipAttList[self.adTb[i]].value
                end
            end
            if heroAdjutantVoApi:isOpen() == true and heroAdjutantVoApi:isCanEquipAdjutant(self.heroVo) and adjAttList then
                if adjAttList[self.adTb[i]] then
                    pValue = pValue + adjAttList[self.adTb[i]]
                end
            end
            if pValue > 0 then
                property[i][2] = pValue .. "%"
                if self.adTb[i] == "first" then
                    property[i][2] = pValue
                end
            end
            if property[i][2] == nil then
                property[i][2] = "-"
            end
            property[i][3] = self.adTb[i]
        end
        share.p = property --将领的属性的加成
        local skillTb = {} --常规技能
        for i = 1, self.sbSkillNum do
            if i > self.heroVo.productOrder then
                do break end
            end
            local sid = heroListCfg[self.heroVo.hid].skills[i][1]
            local lvStr, value, isMax, skillLv = heroVoApi:getHeroSkillLvAndValue(self.heroVo.hid, sid, self.heroVo.productOrder)
            local awakenSid = sid
            if self.heroVo.skill[sid] == nil and equipCfg[self.heroVo.hid]["e1"].awaken.skill then
                local awakenSkill = equipCfg[self.heroVo.hid]["e1"].awaken.skill
                if awakenSkill[sid] then
                    awakenSid = awakenSkill[sid]
                end
            end
            local skill = {sid, skillLv, awakenSid}
            skillTb[i] = skill
        end
        share.sb = skillTb --常规技能
        local nbSkillTb = {}
        local totalNum = 1
        if(heroVoApi:heroHonor2IsOpen())then
            totalNum = totalNum + 1
        end
        if(self.nbSkillNum == 0)then
            totalNum = 0
        end
        for i = 1, totalNum do
            if(i > self.nbSkillNum)then
                break
            end
            local sid = self.heroVo.honorSkill[i][1]
            local skillLv = self.heroVo.honorSkill[i][2]
            local lvStr, value, isMax, skillLv = heroVoApi:getHeroHonorSkillLvAndValue(self.heroVo.hid, sid, self.heroVo.productOrder, skillLv)
            local skill = {sid, skillLv}
            nbSkillTb[i] = skill
        end
        share.nb = nbSkillTb --授勋技能
        
        return share
    end
    return nil
end

function heroInfoDialog:refresh(adjPoint)
    self.heroVo = heroVoApi:getHeroByHid(self.heroVo.hid)
    local str = G_LV()..self.heroVo.level.."/"..G_LV()..heroCfg.heroLevel[self.heroVo.productOrder]
    if heroVoApi:isHeroMaxLv(self.heroVo.hid, self.heroVo.productOrder) then
        str = G_LV()..self.heroVo.level.." ("..getlocal("alliance_lvmax") .. ")"
    end
    local lb = self.bgLayer:getChildByTag(101)
    lb = tolua.cast(lb, "CCLabelTTF")
    lb:setString(str)
    local checkInfoBtn = tolua.cast(self.bgLayer:getChildByTag(399), "CCSprite")
    if checkInfoBtn then
        checkInfoBtn:setPositionX(lb:getPositionX() + lb:getContentSize().width + 5)
    end
    
    local color = heroVoApi:getHeroColor(self.heroVo.productOrder)
    local lb = self.bgLayer:getChildByTag(104)
    lb = tolua.cast(lb, "CCLabelTTF")
    lb:setColor(color)
    
    local exp, per = heroVoApi:getHeroLeftExp(self.heroVo)
    self.timerSprite:setPercentage(per)
    local str2 = getlocal("upgradeExpRequired", {exp})
    local lb2 = self.bgLayer:getChildByTag(102)
    lb2 = tolua.cast(lb2, "CCLabelTTF")
    if(heroVoApi:isHeroMaxLv(self.heroVo.hid, self.heroVo.productOrder))then
        self.timerSprite:setVisible(false)
        self.timerSpriteBg:setVisible(false)
        if(self.heroVo.productOrder < heroVoApi:getHeroMaxProduct())then
            lb2:setPositionY(G_VisibleSizeHeight - 240)
            lb2:setString(getlocal("hero_honor_breakToLvlup"))
        else
            lb2:setVisible(false)
        end
    else
        self.timerSprite:setVisible(true)
        self.timerSpriteBg:setVisible(true)
        local exp, per = heroVoApi:getHeroLeftExp(self.heroVo)
        lb2:setPositionY(G_VisibleSizeHeight - 270)
        lb2:setString(getlocal("upgradeExpRequired", {exp}))
        lb2:setVisible(true)
    end
    
    local sid = heroListCfg[self.heroVo.hid].fusionId
    local soulNum = heroVoApi:getSoulNumListBySid(sid)
    local soulNumStr = getlocal("soulNum", {soulNum})
    local soulLb = self.bgLayer:getChildByTag(103)
    soulLb = tolua.cast(soulLb, "CCLabelTTF")
    if(self.heroVo.productOrder > heroFeatCfg.fusionLimit)then
        soulLb:setVisible(false)
    else
        soulLb:setVisible(true)
        soulLb:setString(soulNumStr)
    end
    
    local atb1 = heroVoApi:getAddBuffTb(self.heroVo)
    for i = 1, SizeOfTable(self.lbTb1) do
        local lb = tolua.cast(self.lbTb1[i], "CCLabelTTF")
        lb:setString("+"..atb1[self.adTb[i]] .. "%")
    end
    
    self:updateSkillNum()
    local recordPoint = self.tv:getRecordPoint()
    self.tv:reloadData()
    self.tv:recoverToRecordPoint(recordPoint)
    if self.bgLayer:getChildByTag(201) ~= nil then
        local sp = self.bgLayer:getChildByTag(201)
        sp:removeFromParentAndCleanup(true)
    end
    local heroIcon = heroVoApi:getHeroIcon(self.heroVo.hid, self.heroVo.productOrder)
    heroIcon:setPosition(ccp(130, G_VisibleSizeHeight - 180))
    heroIcon:setTag(201)
    self.bgLayer:addChild(heroIcon)
    
    if self.bgLayer:getChildByTag(202) ~= nil then
        local sp = self.bgLayer:getChildByTag(202)
        sp:removeFromParentAndCleanup(true)
    end
    --判断如果是满级为突破按钮 如果不是为升级按钮 会做不同的操作
    local function callBack()
        if self.heroVo.level < heroCfg.heroLevel[self.heroVo.productOrder] then
            -- require "luascript/script/game/scene/gamedialog/heroDialog/heroUpgradeDialog"
            -- local td=heroUpgradeDialog:new(self.heroVo,self,self.layerNum+1)
            
            -- local tbArr={}
            -- local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("heroUpgrade"),true,self.layerNum+1)
            -- sceneGame:addChild(dialog,self.layerNum+1)
            self:showUpgradeOrUpgrade2()
            
        else
            if(heroVoApi:heroHonorIsOpen() and heroVoApi:checkCanHonor(self.heroVo))then
                heroVoApi:showHonorTaskDialog(self.heroVo, self.layerNum + 1)
            else
                if self.heroVo.productOrder >= math.min(playerVoApi:getMaxLvByKey("unlockThroughLevel"), 4) then
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("throughMaxLv"), 30)
                    do
                        return
                    end
                end
                require "luascript/script/game/scene/gamedialog/heroDialog/heroBreakthroughDialog"
                local td = heroBreakthroughDialog:new(self.heroVo, self, self.layerNum + 1)
                local tbArr = {}
                local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("heroBreakthrough"), true, self.layerNum + 1)
                sceneGame:addChild(dialog, self.layerNum + 1)
            end
        end
    end
    
    local heroStr = getlocal("breakthrough")
    if self.heroVo.level < heroCfg.heroLevel[self.heroVo.productOrder] then
        heroStr = getlocal("upgradeBuild")
    elseif(heroVoApi:heroHonorIsOpen() and heroVoApi:checkCanHonor(self.heroVo))then
        heroStr = getlocal("hero_honor_doHonor")
    end
    
    local okItem = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", callBack, nil, heroStr, 24 / 0.8, 101)
    okItem:setScale(0.8)
    local btnLb = okItem:getChildByTag(101)
    if btnLb then
        btnLb = tolua.cast(btnLb, "CCLabelTTF")
        btnLb:setFontName("Helvetica-bold")
    end
    local okBtn = CCMenu:createWithItem(okItem)
    okBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    okBtn:setAnchorPoint(ccp(1, 0.5))
    okBtn:setPosition(ccp(self.bgLayer:getContentSize().width / 2, 70))
    okBtn:setTag(202)
    self.bgLayer:addChild(okBtn)
    
    if adjPoint and self.bgLayer:getChildByTag(30000 + adjPoint) then
        local adjData = heroAdjutantVoApi:getAdjutant(self.heroVo.hid)
        if adjData and adjData[adjPoint] then
            local adjActivateState = (adjData[adjPoint][1] == 1) and true or nil
            local adjId, adjCurLv = adjData[adjPoint][3], adjData[adjPoint][4]
            local adjIcon = tolua.cast(self.bgLayer:getChildByTag(30000 + adjPoint), "CCSprite")
            local adjIconScale = adjIcon:getScale()
            local adjIconAncorPoint = adjIcon:getAnchorPoint()
            local adjIconPositionX, adjIconPositionY = adjIcon:getPosition()
            local adjIconTag = adjIcon:getTag()
            local adjIconParent = adjIcon:getParent()
            adjIcon:removeFromParentAndCleanup(true)
            adjIcon = nil
            local adjIconCallFunc
            if adjActivateState == true then
                adjIconCallFunc = function()
                    heroAdjutantVoApi:showAdjutantInfoDialog(self.layerNum + 1, self.heroVo, self)
                end
            end
            if adjId and adjCurLv then
                adjIconCallFunc = function()
                    heroAdjutantVoApi:showInfoSmallDialog(self.layerNum + 1, {adjId, adjCurLv, nil, nil, adjPoint})
                end
            end
            local needStarLv = heroAdjutantVoApi:getAdjutantCfg().needHeroStar[adjPoint]
            if (not adjActivateState) and self.heroVo.productOrder >= needStarLv then
                adjIconCallFunc = function()
                    heroAdjutantVoApi:showAdjutantInfoDialog(self.layerNum + 1, self.heroVo, self)
                end
            end
            adjIcon = heroAdjutantVoApi:getAdjutantIcon(adjId, adjActivateState, true, adjIconCallFunc, true, adjPoint)
            adjIcon:setScale(adjIconScale)
            adjIcon:setAnchorPoint(adjIconAncorPoint)
            adjIcon:setPosition(adjIconPositionX, adjIconPositionY)
            adjIcon:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
            adjIcon:setTag(adjIconTag)
            adjIconParent:addChild(adjIcon)
            if adjId and adjCurLv then
                heroAdjutantVoApi:setAdjLevel(adjIcon, adjId, adjCurLv)
            else
                local tipsStr, tipsLabelColor
                if adjActivateState == true then --可装配
                    tipsStr = getlocal("skill_equip_empty2")
                    tipsLabelColor = G_ColorGreen
                else
                    if self.heroVo.productOrder >= needStarLv then --可激活
                        tipsStr = getlocal("heroAdjutant_activateTips")
                        tipsLabelColor = G_ColorGreen
                    else --将领星级达到x星可解锁
                        tipsStr = getlocal("heroAdjutant_starUnlockTips", nil, {needStarLv})
                        tipsLabelColor = G_ColorRed
                    end
                end
                local tipsLabel = GetTTFLabelWrap(tipsStr, 35, CCSizeMake(adjIcon:getContentSize().width - 6, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
                tipsLabel:setPosition(adjIcon:getContentSize().width / 2, 55)
                tipsLabel:setColor(tipsLabelColor)
                adjIcon:addChild(tipsLabel)
            end
            
            if self.lbTb2 then
                local _, adjAttTb = heroAdjutantVoApi:getExtraProperty(self.heroVo.hid, 1)
                for i = 1, #self.adTb do
                    if adjAttTb[self.adTb[i]] then
                        local lb = tolua.cast(self.lbTb2[i], "CCLabelTTF")
                        local lbStr = lb:getString()
                        local startI, endI = string.find(lbStr, "%%")
                        if startI then
                            lb:setString("+" .. tonumber(string.sub(lbStr, 2, endI - 1)) + adjAttTb[self.adTb[i]] .. "%")
                        else
                            lb:setString("+" .. tonumber(string.sub(lbStr, 2)) + adjAttTb[self.adTb[i]])
                        end
                    end
                end
            end
        end
    end
    
end

--设置对话框里的tableView
function heroInfoDialog:initTableView()
    
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    local height = 600;
    local equipOpenLv = base.heroEquipOpenLv or 30
    if base.he == 1 and playerVoApi:getPlayerLevel() >= equipOpenLv then
        height = 650
    end
    if heroAdjutantVoApi:isOpen() == true and heroAdjutantVoApi:isCanEquipAdjutant(self.heroVo) then
        height = height + 170
    end
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(G_VisibleSizeWidth - 40, self.bgLayer:getContentSize().height - height), nil)
    -- self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition(ccp(20, 110))
    self.bgLayer:addChild(self.tv)
    
    self.tv:setMaxDisToBottomOrTop(120)
    
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function heroInfoDialog:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        if(heroVoApi:heroHonorIsOpen())then
            return 2
        else
            return 1
        end
    elseif fn == "tableCellSizeForIndex" then
        if(idx == 0)then
            return CCSizeMake(G_VisibleSizeWidth - 40, 100 + math.ceil(self.sbSkillNum / 2) * 100)
        else
            if(self.nbSkillNum == 0)then
                return CCSizeMake(G_VisibleSizeWidth - 40, 100 + 100)
            else
                return CCSizeMake(G_VisibleSizeWidth - 40, 100 + math.ceil(self.nbSkillNum / 2) * 100)
            end
        end
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        local cellWidth = G_VisibleSizeWidth - 40
        local cellHeight
        local nameFontSize, lvFontSize = 24, 20
        if G_isChina() == false then
            nameFontSize, lvFontSize = 18, 18
        end
        --上面一格是普通技能
        if(idx == 0)then
            cellHeight = 100 + math.ceil(self.sbSkillNum / 2) * 100
            local lineSp = CCSprite:createWithSpriteFrameName("LineCross.png")
            lineSp:setScale((cellWidth - 20) / lineSp:getContentSize().width)
            lineSp:setPosition((cellWidth) / 2, cellHeight - 2)
            cell:addChild(lineSp)
            local titleSp = CCSprite:createWithSpriteFrameName("nbSkillTitle1.png")
            titleSp:setAnchorPoint(ccp(0.5, 1))
            titleSp:setPosition((cellWidth) / 2, cellHeight)
            cell:addChild(titleSp, 1)
            local titleLb = GetTTFLabel(getlocal("hero_honor_commonSkill"), 24, true)
            titleLb:setColor(G_ColorYellowPro)
            titleLb:setAnchorPoint(ccp(0.5, 1))
            titleLb:setPosition(cellWidth / 2, cellHeight - titleSp:getContentSize().height)
            cell:addChild(titleLb, 1)
            local titleBg = CCSprite:createWithSpriteFrameName("heroInfoHeaderBg.png")
            titleBg:setScale(0.5)
            titleBg:setAnchorPoint(ccp(0.5, 1))
            titleBg:setPosition(cellWidth / 2, cellHeight - 1)
            cell:addChild(titleBg)
            
            local posY = cellHeight - titleSp:getContentSize().height - titleLb:getContentSize().height - 5
            for i = 1, self.sbSkillNum do
                local sid = heroListCfg[self.heroVo.hid].skills[i][1]
                local awakenSid = sid
                if self.heroVo.skill[sid] == nil and equipCfg[self.heroVo.hid]["e1"].awaken.skill then
                    local awakenSkill = equipCfg[self.heroVo.hid]["e1"].awaken.skill
                    if awakenSkill[sid] then
                        awakenSid = awakenSkill[sid]
                    end
                end
                local lvStr, value, isMax, skillLv = heroVoApi:getHeroSkillLvAndValue(self.heroVo.hid, sid, self.heroVo.productOrder)
                local function showSkillDesc(...)
                    if self.tv:getIsScrolled() == true then
                        do return end
                    end
                    if G_checkClickEnable() == false then
                        do return end
                    else
                        base.setWaitTime = G_getCurDeviceMillTime()
                    end
                    heroVoApi:showHeroSkillDescDialog(self.heroVo.hid, awakenSid, self.heroVo.productOrder, skillLv, false, self.layerNum + 1)
                end
                local icon = LuaCCSprite:createWithFileName(heroVoApi:getSkillIconBySid(sid), showSkillDesc)
                icon:setScale(80 / icon:getContentSize().width)
                icon:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                local posX
                if(i % 2 == 1)then
                    posX = 0
                    if(i > 1)then
                        posY = posY - 100
                    end
                else
                    posX = cellWidth / 2 + 5
                end
                icon:setAnchorPoint(ccp(0, 1))
                icon:setPosition(posX, posY - 10)
                cell:addChild(icon)
                local icon2 = CCSprite:createWithSpriteFrameName("datebaseShow2.png")
                icon2:setAnchorPoint(ccp(1, 0))
                icon2:setPosition(icon:getContentSize().width - 5, 5)
                icon:addChild(icon2, 1)
                local color = G_ColorWhite
                if skillLv then
                    color = heroVoApi:getSkillColorByLv(skillLv)
                end
                local nameLb = GetTTFLabelWrap(getlocal(heroSkillCfg[awakenSid].name), nameFontSize, CCSizeMake(cellWidth / 2 - 80 - 64, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
                nameLb:setColor(color)
                nameLb:setAnchorPoint(ccp(0, 0.5))
                nameLb:setPosition(posX + 80 + 5, posY - 50 + 20)
                cell:addChild(nameLb)
                local lvLb = GetTTFLabel(lvStr, lvFontSize)
                lvLb:setAnchorPoint(ccp(0, 0.5))
                lvLb:setPosition(posX + 80 + 5, posY - 50 - 25)
                cell:addChild(lvLb)
                local function onUpgrade()
                    if self.tv:getIsScrolled() == true then
                        do return end
                    end
                    if G_checkClickEnable() == false then
                        do return end
                    else
                        base.setWaitTime = G_getCurDeviceMillTime()
                    end
                    if isMax == true then
                        heroVoApi:showSkillResetDialog(self.layerNum + 1, self.heroVo.hid, awakenSid, skillLv, function() self:refresh() end)
                    else
                        require "luascript/script/game/scene/gamedialog/heroDialog/heroSkillUpgradeDialog"
                        local td = heroSkillUpgradeDialog:new()
                        td:init(self.heroVo, sid, self.layerNum + 1, self)
                    end
                end
                local menuItemImage1, menuItemImage2 = "yh_BtnUp.png", "yh_BtnUp_Down.png"
                if isMax == true then
                    menuItemImage1, menuItemImage2 = "yh_hero_switch1.png", "yh_hero_switch2.png"
                end
                local menuItem = GetButtonItem(menuItemImage1, menuItemImage2, menuItemImage1, onUpgrade, 10)
                menuItem:setScale(0.7)
                local menu = CCMenu:createWithItem(menuItem)
                menu:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
                menu:setPosition(posX + cellWidth / 2 - 35, posY - 50)
                -- if(isMax~=true)then
                cell:addChild(menu)
                -- end
                if(i > self.heroVo.productOrder)then
                    menuItem:setEnabled(false)
                    menuItem:setVisible(false)
                    lvLb:setString(getlocal("starUnlock", {i}))
                    lvLb:setColor(G_ColorRed)
                    nameLb:setColor(ccc3(150, 150, 150))
                    local grayIcon = GraySprite:create(heroVoApi:getSkillIconBySid(sid))
                    grayIcon:setAnchorPoint(ccp(0, 0))
                    grayIcon:setPosition(0, 0)
                    icon:addChild(grayIcon)
                    local function nilFunc(...)
                    end
                    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), nilFunc)
                    touchDialogBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
                    touchDialogBg:setContentSize(CCSizeMake(cellWidth / 2, 100))
                    touchDialogBg:setOpacity(0)
                    touchDialogBg:setAnchorPoint(ccp(0, 1))
                    touchDialogBg:setPosition(posX, posY)
                    cell:addChild(touchDialogBg, 4)
                elseif(isMax ~= true)then
                    local touchSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), onUpgrade)
                    touchSp:setContentSize(CCSizeMake(cellWidth / 2, 80))
                    touchSp:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
                    touchSp:setOpacity(0)
                    touchSp:setPosition(posX + cellWidth / 4, posY - 50)
                    cell:addChild(touchSp)
                end
            end
            --下面一格是授勋技能
        else
            if(self.nbSkillNum == 0)then
                cellHeight = 100 + 100
            else
                cellHeight = 100 + math.ceil(self.nbSkillNum / 2) * 100
            end
            local lineSp = CCSprite:createWithSpriteFrameName("LineCross.png")
            lineSp:setScale((cellWidth - 20) / lineSp:getContentSize().width)
            lineSp:setPosition((cellWidth) / 2, cellHeight - 2)
            cell:addChild(lineSp)
            local titleSp = CCSprite:createWithSpriteFrameName("nbSkillTitle2.png")
            titleSp:setAnchorPoint(ccp(0.5, 1))
            titleSp:setPosition((cellWidth) / 2, cellHeight)
            cell:addChild(titleSp, 1)
            local titleLb = GetTTFLabel(getlocal("hero_honor_used_honor_skill"), 24, true)
            titleLb:setColor(G_ColorYellowPro)
            titleLb:setAnchorPoint(ccp(0.5, 1))
            titleLb:setPosition(cellWidth / 2, cellHeight - titleSp:getContentSize().height)
            cell:addChild(titleLb, 1)
            local titleBg = CCSprite:createWithSpriteFrameName("heroInfoHeaderBg.png")
            titleBg:setScale(0.5)
            titleBg:setAnchorPoint(ccp(0.5, 1))
            titleBg:setPosition(cellWidth / 2, cellHeight - 1)
            cell:addChild(titleBg)
            local posY = cellHeight - titleSp:getContentSize().height - titleLb:getContentSize().height - 5
            if(self.nbSkillNum == 0)then
                local unlockStr = getlocal("hero_honor_tip_2")
                unlockStr = string.gsub(unlockStr, "2.", "")
                local unlockDesc = GetTTFLabelWrap(unlockStr, lvFontSize, CCSizeMake(cellWidth - 20, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
                unlockDesc:setPosition(cellWidth / 2, posY - 50)
                cell:addChild(unlockDesc)
            end
            local totalNum = 1
            if(heroVoApi:heroHonor2IsOpen())then
                totalNum = totalNum + 1
            end
            if(self.nbSkillNum == 0)then
                totalNum = 0
            end
            for i = 1, totalNum do
                if(i > self.nbSkillNum)then
                    local posX
                    if(i % 2 == 1)then
                        posX = 5
                    else
                        posX = cellWidth / 2 + 5
                    end
                    local iconBg = GraySprite:createWithSpriteFrameName("accessoryMetalBg.png")
                    iconBg:setScale(90 / iconBg:getContentSize().width)
                    iconBg:setAnchorPoint(ccp(0, 1))
                    iconBg:setPosition(posX - 5, posY - 5)
                    cell:addChild(iconBg)
                    local lockIcon = CCSprite:createWithSpriteFrameName("LockIcon.png")
                    lockIcon:setScale(0.8)
                    lockIcon:setPosition(posX + 40, posY - 50)
                    cell:addChild(lockIcon)
                    local lockLb = GetTTFLabelWrap(getlocal("hero_honor_unlock2"), nameFontSize, CCSizeMake(cellWidth / 2 - 10 - 80, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
                    lockLb:setAnchorPoint(ccp(0, 0.5))
                    lockLb:setPosition(posX + 95, posY - 50)
                    cell:addChild(lockLb)
                    break
                end
                local sid = self.heroVo.honorSkill[i][1]
                local skillLv = self.heroVo.honorSkill[i][2]
                local lvStr, value, isMax, skillLv = heroVoApi:getHeroHonorSkillLvAndValue(self.heroVo.hid, sid, self.heroVo.productOrder, skillLv)
                local function showSkillDesc(...)
                    if self.tv:getIsScrolled() == true then
                        do return end
                    end
                    if G_checkClickEnable() == false then
                        do return end
                    else
                        base.setWaitTime = G_getCurDeviceMillTime()
                    end
                    heroVoApi:showHeroSkillDescDialog(self.heroVo.hid, sid, self.heroVo.productOrder, skillLv, true, self.layerNum + 1)
                end
                local icon = LuaCCSprite:createWithFileName(heroVoApi:getSkillIconBySid(sid), showSkillDesc)
                icon:setScale(80 / icon:getContentSize().width)
                icon:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                local posX
                if(i % 2 == 1)then
                    posX = 5
                    if(i > 1)then
                        posY = posY - 100
                    end
                else
                    posX = cellWidth / 2 + 5
                end
                icon:setAnchorPoint(ccp(0, 1))
                icon:setPosition(posX, posY - 10)
                cell:addChild(icon, 1)
                local iconBg = CCSprite:createWithSpriteFrameName("accessoryMetalBg.png")
                iconBg:setScale(90 / iconBg:getContentSize().width)
                iconBg:setAnchorPoint(ccp(0, 1))
                iconBg:setPosition(posX - 5, posY - 5)
                cell:addChild(iconBg)
                local icon2 = CCSprite:createWithSpriteFrameName("datebaseShow2.png")
                icon2:setAnchorPoint(ccp(1, 0))
                icon2:setPosition(icon:getContentSize().width - 5, 5)
                icon:addChild(icon2)
                local color = G_ColorWhite
                if skillLv then
                    color = heroVoApi:getSkillColorByLv(skillLv)
                end
                local nameLb = GetTTFLabelWrap(getlocal(heroSkillCfg[sid].name), nameFontSize, CCSizeMake(cellWidth / 2 - 80 - 64, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
                nameLb:setColor(color)
                nameLb:setAnchorPoint(ccp(0, 0.5))
                nameLb:setPosition(posX + 80 + 10, posY - 50 + 25)
                cell:addChild(nameLb)
                local lvLb = GetTTFLabel(lvStr, lvFontSize)
                lvLb:setAnchorPoint(ccp(0, 0.5))
                lvLb:setPosition(posX + 80 + 10, posY - 50 - 25)
                cell:addChild(lvLb)
                local function onRealise()
                    if self.tv:getIsScrolled() == true then
                        do return end
                    end
                    if G_checkClickEnable() == false then
                        do return end
                    else
                        base.setWaitTime = G_getCurDeviceMillTime()
                    end
                    heroVoApi:showHeroRealiseDialog(self.heroVo, self.layerNum + 1, self)
                end
                local touchSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), onRealise)
                touchSp:setContentSize(CCSizeMake(cellWidth / 2, 80))
                touchSp:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
                touchSp:setOpacity(0)
                touchSp:setPosition(posX + cellWidth / 4, posY - 50)
                cell:addChild(touchSp)
                local menuItem = GetButtonItem("yh_hero_switch1.png", "yh_hero_switch2.png", "yh_hero_switch1.png", onRealise, 10)
                menuItem:setScale(0.8)
                local menu = CCMenu:createWithItem(menuItem)
                menu:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
                menu:setPosition(posX + cellWidth / 2 - 35, posY - 65)
                cell:addChild(menu)
            end
        end
        return cell
    elseif fn == "ccTouchBegan" then
        self.isMoved = false
        return true
    elseif fn == "ccTouchMoved" then
        self.isMoved = true
    elseif fn == "ccTouchEnded" then
        
    end
end

function heroInfoDialog:refreshTv()
    self.heroVo = heroVoApi:getHeroByHid(self.heroVo.hid)
    self:updateSkillNum()
    local recordPoint = self.tv:getRecordPoint()
    self.tv:reloadData()
    self.tv:recoverToRecordPoint(recordPoint)
end

--点击tab页签 idx:索引
function heroInfoDialog:tabClick(idx)
    if newGuidMgr:isNewGuiding() then --新手引导
        if newGuidMgr.curStep == 39 and idx ~= 1 then
            do
                return
            end
        end
    end
    PlayEffect(audioCfg.mouseClick)
    
    for k, v in pairs(self.allTabs) do
        if v:getTag() == idx then
            v:setEnabled(false)
            self.selectedTabIndex = idx
            self:tabClickColor(idx)
            self:doUserHandler()
            self:getDataByType(idx)
            
        else
            v:setEnabled(true)
        end
    end
    
    self:resetForbidLayer()
end

--用户处理特殊需求,没有可以不写此方法
function heroInfoDialog:doUserHandler()
    
end

--点击了cell或cell上某个按钮
function heroInfoDialog:cellClick(idx)
    if self.tv:getScrollEnable() == true and self.tv:getIsScrolled() == false then
        if self.expandIdx["k" .. (idx - 1000)] == nil then
            self.expandIdx["k" .. (idx - 1000)] = idx - 1000
            self.tv:openByCellIndex(idx - 1000, 120)
        else
            self.expandIdx["k" .. (idx - 1000)] = nil
            self.tv:closeByCellIndex(idx - 1000, 800)
        end
    end
end

function heroInfoDialog:tick()
    
end

function heroInfoDialog:showUpgradeOrUpgrade2()
    if base.bs == 1 then
        local function showUpgrade2()
            require "luascript/script/game/scene/gamedialog/heroDialog/heroUpgrade2Dialog"
            local td = heroUpgrade2Dialog:new(self.heroVo, self, self.layerNum + 1)
            local tbArr = {}
            local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("heroUpgrade"), true, self.layerNum + 1)
            sceneGame:addChild(dialog, self.layerNum + 1)
        end
        if heroVoApi:isHaveBookChangeExp() then
            local function callback(fn, data)
                local ret, sData = base:checkServerData(data)
                if ret == true then
                    local idTb = {446, 447, 448}
                    for k, v in pairs(idTb) do
                        local num = bagVoApi:getItemNumId(v)
                        if num > 0 then
                            bagVoApi:useItemNumId(v, num)
                        end
                    end
                    showUpgrade2()
                end
            end
            local pids = heroVoApi:getHeroExpBookList()
            socketHelper:bookChangeExp(pids, callback)
        else
            showUpgrade2()
        end
        
    else
        require "luascript/script/game/scene/gamedialog/heroDialog/heroUpgradeDialog"
        local td = heroUpgradeDialog:new(self.heroVo, self, self.layerNum + 1)
        
        local tbArr = {}
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("heroUpgrade"), true, self.layerNum + 1)
        sceneGame:addChild(dialog, self.layerNum + 1)
    end
    
end

function heroInfoDialog:dealWithEvent(event, data)
    if(data.type == "success")then
        self:close()
    end
end

function heroInfoDialog:dispose()
    eventDispatcher:removeEventListener("hero.honor", self.honorListener)
    if self.parent and self.parent.refresh then
        self.parent:refresh()
    end
    self.expandIdx = nil
    self.skillNum = 0
    spriteController:removePlist("public/nbSkill.plist")
    spriteController:removeTexture("public/nbSkill.png")
    spriteController:removePlist("public/datebaseShow.plist")
    spriteController:removeTexture("public/datebaseShow.png")
    spriteController:removePlist("public/acAnniversary.plist")
    spriteController:removeTexture("public/acAnniversary.png")
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/accessoryImage2.plist")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/accessoryImage2.png")
end
