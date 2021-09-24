baseBuilding = {}
function baseBuilding:new(bid)
    require "luascript/script/game/scene/gamedialog/resourceBuildDialog"
    require "luascript/script/game/scene/gamedialog/homeBuildUpgradeDialog"
    require "luascript/script/game/scene/gamedialog/arenaDialog/arenaDialog"
    require "luascript/script/game/scene/gamedialog/arenaDialog/arenaTotalDialog"
    local nc = {
        rgbv,
        needChange = false,
        ccprogress,
        lvTip,
        lvLb,
        parent,
        isArea = true,
        lastStatus,
        produceTipSp,
        curProduceTipTid,
        curProduceTipSp,
        buildAnimSp,
        buildableIcon,
        specialIcon,
        tipX = 0,
        tipY = 0,
        cueSp, --建筑功能提示sprite
        cueId, --当前建筑提示的id
        floorSp, --新增地板
        movTipSp, --移动提示标示
        buildingTipSp = nil, --新的建筑功能提示图标
        arenaTipFlag = false, --作战中心tip的记录标识（用于切换新加的tip和老的tip）
        arenaTipType = 0, --记录原先的作战中心功能tip类型
        lastArenaTipType = 0, --先前的作战中心的tip类型
    }
    setmetatable(nc, self)
    self.__index = self
    nc.bid = bid
    return nc
end

function baseBuilding:getBid()
    return self.bid
end

function baseBuilding:getBuildVo()
    return buildingVoApi:getBuildiingVoByBId(self.bid)
end

function baseBuilding:getName()
    return self:getBuildVo().name
end

function baseBuilding:getLevel()
    return self:getBuildVo().level
end

function baseBuilding:getType()
    local bVo = self:getBuildVo()
    if(bVo and bVo.type)then
        return bVo.type
    else
        return - 1
    end
end

function baseBuilding:getStatus()
    -- return self:getBuildVo().status
    local bVo = self:getBuildVo()
    if(bVo and bVo.status)then
        return bVo.status
    else
        return - 1
    end
end

function baseBuilding:getPercent()
    return self:getBuildVo().upgradePercent
end

function baseBuilding:getNeedChange() --需要换图片时设置true
    return self.needChange
end

function baseBuilding:show(pscene, changeImage, ttg)
    if self.refreshListener == nil then
        if self:getType() == 106 or self:getType() == 107 or self:getType() == 7 or self:getType() == 18 then
            local function refreshBuild(event, data)
                self:refreshBuild(data)
            end
            self.refreshListener = refreshBuild
            eventDispatcher:addEventListener("baseBuilding.build.refresh", self.refreshListener)
        end
    end
    
    local buildScale = homeCfg:getBuildingScale(self.bid, self:getType())
    self.parent = pscene
    self.needChange = false
    local _posX, _posY = homeCfg:getBuildingPosById(self.bid)
    
    local function clickBuilding()
        if pscene.isMoved == true or pscene.touchEnable == false then
            if pscene.isMoved == true then
                pscene.isMoved = false
            end
            do
                return
            end
        end
        
        if newGuidMgr:isNewGuiding() == true then
            if self:getBid() == 12 then
                do
                    return
                end
            end
            
            if newGuidMgr.curStep == 20 and self:getBid() ~= 20 then
                do
                    return
                end
            end
            if newGuidMgr.curStep == 23 and self:getBid() ~= 19 then
                do
                    return
                end
            end
            if newGuidMgr.curStep == 26 and self:getBid() ~= 18 then
                do
                    return
                end
            end
        end
        if G_checkClickEnable() == false then
            do
                return
            end
        end
        
        if self:getType() == 102 then
            local newFlag = buildingVoApi:newBuildingVisible(self:getBid())
            if not newFlag then
                return
            end
        end
        
        if self:getType() == 12 then
            if base.heroSwitch == 0 then
                do
                    return
                end
            end
        end
        base:setWait()
        PlayEffect(audioCfg.mouseClick)
        
        local delayAction
        if self:getStatus() ~= -1 then
            G_isBuildingAnim = true
            local fadeOut = CCTintTo:create(0.3, 80, 80, 80)
            local fadeIn = CCTintTo:create(0.3, self.rgbv, self.rgbv, self.rgbv)
            local seq = CCSequence:createWithTwoActions(fadeOut, fadeIn)
            self.buildSp:runAction(seq)
            if self.lvTip ~= nil then
                local fadeOut2 = CCTintTo:create(0.3, 80, 80, 80)
                local fadeIn2 = CCTintTo:create(0.3, self.rgbv, self.rgbv, self.rgbv)
                local seq2 = CCSequence:createWithTwoActions(fadeOut2, fadeIn2)
                self.lvTip:runAction(seq2)
            end
            
            self:playBuildReactionEffect()
            
            if self.bid == 102 and playerVoApi:getPlayerLevel() < 25 then
                delayAction = CCDelayTime:create(0)
            else
                delayAction = CCDelayTime:create(0.6)
            end
            local function runBuildTintAction(target) --点击建筑动画
                if target == nil then
                    do return end
                end
                local fadeOut = CCTintTo:create(0.3, 80, 80, 80)
                local fadeIn = CCTintTo:create(0.3, self.rgbv, self.rgbv, self.rgbv)
                local seq = CCSequence:createWithTwoActions(fadeOut, fadeIn)
                target:runAction(seq)
            end
            local buildType = self:getType()
            if buildType == 107 then --战争塑像
                local statueSp = tolua.cast(self.buildSp:getChildByTag(buildType), "CCSprite")
                if statueSp then
                    runBuildTintAction(statueSp)
                end
            end
        else
            delayAction = CCDelayTime:create(0)
        end
        local function callBack(...)
            G_isBuildingAnim = false
            base:cancleWait()
            -- print("self:getType()====>>>>",self:getType())
            if self.bid > 45 and self.bid < 100 then--钛矿 移除选项
                mainLandScene:removeShowTip()
            elseif self.bid > 15 and self.bid < 100 then
                local allBuildsVo = buildingVoApi:getHomeBuilding()
                for k, v in pairs(allBuildsVo) do
                    if buildings.allBuildings[v.id].movTipSpChange == true then
                        do return end
                    end
                end
            end
            --执行具体的事件
            if self.bid < 16 or self.bid > 100 or self.bid == 52 then --port场景建筑
                self.lastStatus = self:getStatus()
                if self:getStatus() == -1 then
                    print("port_scene_building_tip_", tostring(self.bid - 1))
                    
                    smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("port_scene_building_tip_"..tostring(self.bid - 1)), nil, 4)
                else
                    if self:getType() ~= 12 and self:getType() ~= 15 and self:getType() ~= 16 and self:getType() ~= 17 and self:getType() ~= 11 and self:getType() ~= 13 and self:getType() ~= 101 and self:getType() ~= 103 and self:getType() ~= 104 and self:getType() ~= 105 and self:getType() ~= 106 and self:getType() ~= 107 and self:getBid() ~= 108 and self:getBid() ~= 109 and self:getBid() ~= 52 then
                        PlayEffect(audioCfg["build_audio_"..self:getType()])
                    end
                    if self:getType() == 7 then
                        require "luascript/script/game/scene/gamedialog/portbuilding/commanderCenterDialog"
                        local td = commanderCenterDialog:new(self.bid)
                        local bName = getlocal(buildingCfg[self:getType()].buildName)
                        local tbArr = {getlocal("building"), getlocal("shuoming")}
                        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, bName.."("..G_LV()..self:getLevel() .. ")", true)
                        sceneGame:addChild(dialog, 3)
                    elseif self:getType() == 8 then
                        require "luascript/script/game/scene/gamedialog/portbuilding/techCenterDialog"
                        local td = techCenterDialog:new(self.bid, 3)
                        local bName = getlocal(buildingCfg[self:getType()].buildName)
                        local tbArr = {getlocal("building"), getlocal("startResearch")}
                        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, bName.."("..G_LV()..self:getLevel() .. ")", true, 3)
                        sceneGame:addChild(dialog, 3)
                    elseif self:getType() == 10 or self:getType() == 5 then
                        local td = homeBuildUpgradeDialog:new(self.bid)
                        local tbArr = {getlocal("building")}
                        local bName = getlocal(buildingCfg[self:getType()].buildName)
                        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, bName.."("..G_LV()..self:getLevel() .. ")", true)
                        sceneGame:addChild(dialog, 3)
                    elseif self:getType() == 9 then
                        buildingVoApi:showWorkshop(self.bid, self:getType(), 3, self:getLevel())
                        
                    elseif self:getType() == 6 then
                        require "luascript/script/game/scene/gamedialog/portbuilding/tankFactoryDialog"
                        local td = tankFactoryDialog:new(self.bid, 3)
                        local bName = getlocal(buildingCfg[self:getType()].buildName)
                        local tbArr = {getlocal("buildingTab"), getlocal("startProduce"), getlocal("chuanwu_scene_process")}
                        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, bName.."("..G_LV()..self:getLevel() .. ")", true, 3)
                        sceneGame:addChild(dialog, 3)
                        if newGuidMgr:isNewGuiding() then --新手引导跳入下一步
                            newGuidMgr:toNextStep()
                            if newGuidMgr.curStep == 5 then
                                td:tabClick(1)
                                td:cellClick(1000)
                            end
                        end
                    elseif self:getType() == 14 then
                        require "luascript/script/game/scene/gamedialog/portbuilding/tankTuningDialog"
                        local td = tankTuningDialog:new(self.bid)
                        local bName = getlocal(buildingCfg[self:getType()].buildName)
                        local tbArr = {getlocal("buildingTab"), getlocal("smelt"), getlocal("smelt_progress")}
                        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, bName.."("..G_LV()..self:getLevel() .. ")", true, 3)
                        sceneGame:addChild(dialog, 3)
                    elseif self:getType() == 15 then
                        if base.isAllianceSwitch == 0 then
                            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("alliance_willOpen"), nil, 5)
                            do
                                return
                            end
                        end
                        -- if allianceVoApi:isHasAlliance()==false then
                        --     require "luascript/script/game/scene/gamedialog/allianceDialog/allianceDialog"
                        --     local td=allianceDialog:new(1,3)
                        --     G_AllianceDialogTb[1]=td
                        --     local tbArr={getlocal("recommendList"),getlocal("alliance_list_scene_create")}
                        --     local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("alliance_list_scene_name"),true,3)
                        --     sceneGame:addChild(dialog,3)
                        -- else
                        --     allianceEventVoApi:clear()
                        --     require "luascript/script/game/scene/gamedialog/allianceDialog/allianceExistDialog"
                        --     local td=allianceExistDialog:new(1,3)
                        --     G_AllianceDialogTb[1]=td
                        --     local tbArr={getlocal("alliance_info_title"),getlocal("alliance_function"),getlocal("alliance_list_scene_list")}
                        --     local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("alliance_list_scene_name"),true,3)
                        --     sceneGame:addChild(dialog,3)
                        --     --td:tabClick(1)
                        -- end
                        allianceVoApi:showAllianceDialog(3)
                    elseif self:getType() == 16 then
                        local td = arenaTotalDialog:new()
                        local tbArr = {}
                        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("arena_total"), true, 3)
                        sceneGame:addChild(dialog, 3)
                    elseif self:getType() == 17 then
                        if FuncSwitchApi:isEnabled("diku_repair") == false then
                            tankWarehouseScene:setShow()
                        else
                            tankVoApi:showTankWarehouseDialog(3)
                        end
                    elseif self:getType() == 12 then
                        if base.heroSwitch == 0 then
                            do
                                return
                            end
                        end
                        local function openHeroTotalDialog(...)
                            require "luascript/script/game/scene/gamedialog/heroDialog/heroTotalDialog"
                            local td = heroTotalDialog:new()
                            local tbArr = {}
                            local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("sample_build_name_12"), true, 3)
                            sceneGame:addChild(dialog, 3)
                        end
                        local heroEquipOpenLv = base.heroEquipOpenLv or 30
                        if base.he == 1 and playerVoApi:getPlayerLevel() >= heroEquipOpenLv then
                            if heroEquipVoApi and heroEquipVoApi.ifNeedSendRequest == true then
                                local function callbackHandler4()
                                    openHeroTotalDialog()
                                end
                                heroEquipVoApi:equipGet(callbackHandler4)
                            else
                                openHeroTotalDialog()
                            end
                        else
                            openHeroTotalDialog()
                        end
                        
                    elseif self:getType() == 101 then
                        local playerLv = playerVoApi:getPlayerLevel()
                        if playerLv < accessoryCfg.accessoryUnlockLv then
                            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("purifying_unlock_player_level", {8}), nil, 3)
                            do return end
                        end
                        
                        require "luascript/script/game/scene/gamedialog/purifying/purifyingTotalDialog"
                        local td = purifyingTotalDialog:new()
                        local tbArr = {}
                        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("accessory_factory"), true, 3)
                        sceneGame:addChild(dialog, 3)
                    elseif self:getType() == 103 then
                        -- local playerLv=playerVoApi:getPlayerLevel()
                        -- if playerLv<8 then
                        --     smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("purifying_unlock_player_level",{8}),nil,3)
                        --     do return end
                        -- end
                        ladderVoApi:openLadderDialog(3)
                    elseif self:getType() == 11 or self:getType() == 13 then
                        if base.alien == 0 or base.richMineOpen == 0 then
                            do
                                return
                            end
                        end
                        
                        local playerLv = playerVoApi:getPlayerLevel()
                        if playerLv < alienTechCfg.openlevel then
                            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("alien_tech_unlock_player_level", {alienTechCfg.openlevel}), nil, 3)
                            do return end
                        end
                        
                        if self:getType() == 11 then
                            require "luascript/script/game/scene/gamedialog/alienTechDialog/alienTechDialog"
                            local td = alienTechDialog:new()
                            local tbArr = {getlocal("alien_tech_sub_title1"), getlocal("alien_tech_sub_title2"), getlocal("alien_tech_sub_title3")}
                            local vd = td:init("panelBg.png", true, CCSizeMake(768, 800), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("alien_tech_title"), true, 3)
                            sceneGame:addChild(vd, 3)
                        elseif self:getType() == 13 then
                            alienTechVoApi:showAlienTechFactoryDialog(3)
                        end
                    elseif self:getType() == 102 then
                        -- if base.ifSuperWeaponOpen==0 then
                        --     do
                        --         return
                        --     end
                        -- end
                        local newFlag = buildingVoApi:newBuildingVisible(self:getBid())
                        if not newFlag then
                            return
                        end
                        local openlevel = base.superWeaponOpenLv or 25
                        if playerVoApi:getPlayerLevel() < openlevel then
                            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("port_scene_building_tip_102", {openlevel}), nil, 4)
                            return
                        end
                        
                        if superWeaponVoApi and superWeaponVoApi.showMainDialog then
                            superWeaponVoApi:showMainDialog(3)
                        end
                    elseif self:getType() == 104 then
                        --军徽部队已开放的话打开功能列表，否则直接打开军徽列表页面
                        if emblemTroopVoApi:checkIfEmblemTroopIsOpen() == true then
                            require "luascript/script/game/scene/gamedialog/emblem/emblemFunctionListDialog"
                            local td = emblemFunctionListDialog:new()
                            local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), {}, nil, nil, getlocal("emblem_title"), true, 3)
                            sceneGame:addChild(dialog, 3)
                        else
                            emblemVoApi:showMainDialog(3)
                        end
                    elseif self:getType() == 105 then
                        -- if armorMatrixVoApi and armorMatrixVoApi:isOpenArmorMatrix()==true then
                        -- else
                        --     do return end
                        -- end
                        local permitLevel = armorMatrixVoApi:getPermitLevel()
                        local bName = getlocal(buildingCfg[self:getType()].buildName)
                        if permitLevel and playerVoApi:getPlayerLevel() < permitLevel then
                            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("armorMatrix_building_not_permit", {bName, permitLevel}), nil, 3)
                            do return end
                        end
                        local isCan = armorMatrixVoApi:canOpenArmorMatrixDialog(true)
                        if isCan == true then
                            local function showCallback()
                                armorMatrixVoApi:showArmorMatrixDialog(4)
                            end
                            armorMatrixVoApi:armorGetData(showCallback)
                        end
                    elseif self:getType() == 106 then --空中打击
                        planeVoApi:showMainDialog(4)
                    elseif self:getType() == 107 then --战争塑像
                        warStatueVoApi:showWarStatueDialog(3)
                    elseif self:getType() == 108 then --AI部队
                        AITroopsVoApi:showAITroopsDialog(3)
                    elseif self:getType() == 109 then --战略中心
                        strategyCenterVoApi:showMainDialog(3)
                    elseif self:getType() == 18 then --飞艇
                        airShipVoApi:showMainDialog(3)
                    end
                end
            else --home场景建筑
                if self:getType() == -1 then --新建建筑
                    local td = resourceBuildDialog:new(self.bid)
                    local tbArr = {getlocal("building")}
                    
                    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("resourceBuilding"), true)
                    sceneGame:addChild(dialog, 3)
                    if newGuidMgr:isNewGuiding() then --新手引导
                        if newGuidMgr.curStep == 20 then
                            td:cellClick(1000)
                        elseif newGuidMgr.curStep == 23 then
                            td:cellClick(1001)
                        elseif newGuidMgr.curStep == 26 then
                            td:cellClick(1002)
                        end
                        newGuidMgr:toNextStep()
                        
                    end
                else --正常的或升级的建筑
                    PlayEffect(audioCfg["build_audio_"..self:getType()])
                    local td = homeBuildUpgradeDialog:new(self.bid)
                    
                    local tbArr = {getlocal("building")}
                    local bName = getlocal(buildingCfg[self:getType()].buildName)
                    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, bName.."("..G_LV()..self:getLevel() .. ")", true)
                    sceneGame:addChild(dialog, 3)
                    table.insert(G_CheckMem, td)
                end
            end
        end
        local callFunc = CCCallFunc:create(callBack)
        local seq3 = CCSequence:createWithTwoActions(delayAction, callFunc)
        self.buildSp:runAction(seq3)
    end
    if changeImage == true then
        if self.buildSp ~= nil then
            -- self.buildSp:stopAllActions()
            self.bAnimSpTb = {}
            self:removeBuildingTipSp()
            self.buildSp:removeFromParentAndCleanup(true)
            self.buildSp = nil
            self.lvLb = nil
            self.ccprogress = nil
            self.lvTip = nil
            self.nameTip = nil
            self.nameLb = nil
            self.buildAnimSp = nil
            self.buildableIcon = nil
            self.specialIcon = nil
            self.bAnimSpTb = nil
        end
    end
    if self:getBid() == 52 or self:getBid() == 7 then
        print("self:getBid()=====>>>", self:getBid(), self:getType(), self:getStatus(), self:getLevel())
    end
    if self:getType() ~= -1 then
        self.isArea = false
        -- self.buildSp=LuaCCSprite:createWithSpriteFrameName(buildingCfg[self:getType()].style,clickBuilding)
        if (platCfg.platUseUIWindow[G_curPlatName()] ~= nil and platCfg.platUseUIWindow[G_curPlatName()] == 2) or G_isShowNewMapAndBuildings() == 1 then
            
            if self:getType() == 1 or self:getType() == 2 or self:getType() == 4 or self:getType() == 3 then
                local function nilfunction(...)
                end
                self.buildSp = LuaCCSprite:createWithSpriteFrameName(buildingCfg[self:getType()].style, nilfunction)
                local buildClickSp = LuaCCSprite:createWithSpriteFrameName("smallGreen2QuadrateBg.png", clickBuilding)
                -- local buildClickSp = LuaCCSprite:createWithSpriteFrameName("jiaowai_ziyuan.png",clickBuilding)
                buildClickSp:setPosition(ccp(self.buildSp:getContentSize().width * 0.4, self.buildSp:getContentSize().height * 0.6))
                buildClickSp:setTouchPriority(-10)
                buildClickSp:setIsSallow(false)
                buildClickSp:setScaleX(3.7)
                buildClickSp:setScaleY(2.6)
                buildClickSp:setVisible(false)
                self.buildSp:addChild(buildClickSp, 2)
                
            else
                self.buildSp = LuaCCSprite:createWithSpriteFrameName(buildingCfg[self:getType()].style, clickBuilding)
                
            end
            
        else
            local imgStr = buildingCfg[self:getType()].style
            local function nilFunc()
            end
            local callback = clickBuilding
            if buildingVoApi:isYouhua() and (self:getBid() < 16 or self:getBid() == 101 or self:getBid() == 103 or self:getBid() == 104 or self:getBid() == 105 or self:getBid() == 106 or self:getBid() == 107 or self:getBid() == 108 or self:getBid() == 109 or self:getBid() == 52) then
                local isVisibleFlag = buildingVoApi:isBuildingVisible(self:getBid())
                if isVisibleFlag == false then
                    callback = nilFunc
                end
                
            end
            if self:getType() == 1 or self:getType() == 2 then
                -- 铁矿石油
                self.buildSp = LuaCCSprite:createWithSpriteFrameName("di_kuai_normal.png", callback)
                self.buildSp:setOpacity(0)
            elseif self:getType() == 3 or self:getType() == 4 then
                -- 铅矿钛矿
                self.buildSp = LuaCCSprite:createWithSpriteFrameName("di_kuai_normal.png", callback)
                self.buildSp:setOpacity(0)
                self.buildAnimSp = CCSprite:createWithSpriteFrameName(imgStr)
                self.buildAnimSp:setAnchorPoint(ccp(0, 0))
                self.buildAnimSp:setScale(0.6)
                if self:getType() == 4 then
                    self.buildAnimSp:setPosition(ccp(15, 10))
                else
                    self.buildAnimSp:setPosition(ccp(28, 12))
                end
                self.buildSp:addChild(self.buildAnimSp)
            else
                -- 通用
                -- print("imgStr=======>>>>>>",imgStr)
                self.buildSp = LuaCCSprite:createWithSpriteFrameName(imgStr, callback)
                if self:getType() == 7 then
                    local skinId = buildDecorateVoApi:getNowUse()
                    self.oldSkinId = skinId
                    if skinId and (skinId == "b11" or skinId == "b12" or skinId == "b13") then
                        local buildingPic = exteriorCfg.exteriorLit[skinId].decorateSp
                        local posCx, posCy = self.buildSp:getContentSize().width * 0.5, self.buildSp:getContentSize().height * 0.5
                        if skinId == "b11" then
                            local bSp, bTb = G_buildingAction1(buildingPic, self.buildSp, ccp(posCx - 5, posCy - 15), nil, 0.85)
                            self.bAnimSpTb = bTb
                        elseif skinId == "b12" then
                            local bSp, bTb = G_buildingAction2(buildingPic, self.buildSp, ccp(posCx - 5, posCy - 15), nil, 0.85)
                            self.bAnimSpTb = bTb
                        else
                            local bSp, bTb = G_buildingAction3(buildingPic, self.buildSp, ccp(posCx - 5, posCy - 15), nil, 0.85)
                            self.bAnimSpTb = bTb
                        end
                        self.buildSp:setOpacity(0)
                    end
                    print("skinId is over~~~~~~")
                end
            end
            if buildingVoApi:isYouhua() and (self:getBid() < 16 or self:getBid() == 101 or self:getBid() == 103 or self:getBid() == 104 or self:getBid() == 105 or self:getBid() == 106 or self:getBid() == 107 or self:getBid() == 108 or self:getBid() == 109 or self:getBid() == 52) then
                local isVisibleFlag = buildingVoApi:isBuildingVisible(self:getBid())
                if isVisibleFlag == false then
                    self.buildSp:setVisible(false)
                end
            end
        end
        
        local buildingType = tonumber(self:getType())
        G_setWholeSkin(G_isOpenWinterSkin)
        
        if (base.alien == 0 or base.richMineOpen == 0) and (self:getType() == 11 or self:getType() == 13) then
            self.buildSp:setVisible(false)
        end
        
        if (base.heroSwitch == 0) and (self:getType() == 12) then
            self.buildSp:setVisible(false)
        end
        
        -- if (base.ifSuperWeaponOpen==0) and (self:getType()==102) then
        --     self.buildSp:setVisible(false)
        -- end
        if self:getType() == 102 then
            local newFlag = buildingVoApi:newBuildingVisible(self:getBid())
            if newFlag then
                self.buildSp:setVisible(true)
            else
                self.buildSp:setVisible(false)
            end
        end
        
        if self:getBid() == 102 then
            local newFlag = buildingVoApi:newBuildingVisible(102)
            local openlevel = base.superWeaponOpenLv or 25
            
            if newFlag and playerVoApi:getPlayerLevel() < openlevel then
                local btype = homeCfg.buildingUnlock[self:getBid()].type
                local grayBuildSp = GraySprite:createWithSpriteFrameName(buildingCfg[tonumber(btype)].style)
                grayBuildSp:setAnchorPoint(ccp(0, 0))
                grayBuildSp:setTag(tonumber(self:getBid() .. 111))
                self.buildSp:addChild(grayBuildSp)
            else
                local grayBuildSp = tolua.cast(self.buildSp:getChildByTag(tonumber(self:getBid() .. 111)), "GraySprite")
                if grayBuildSp ~= nil then
                    grayBuildSp:removeFromParentAndCleanup(true)
                    grayBuildSp = nil
                end
            end
        end
        -- if self:getBid() == 52 then
        --   local openlevel = airShipVoApi:getOpenLv()
        --   local btype = homeCfg.buildingUnlock[self:getBid()].type
        --   if airShipVoApi:isOpen() then
        --     if playerVoApi:getPlayerLevel() < openlevel then
        --          local btype=homeCfg.buildingUnlock[self:getBid()].type
        --          local grayBuildSp=GraySprite:createWithSpriteFrameName(buildingCfg[tonumber(btype)].style)
        --          grayBuildSp:setAnchorPoint(ccp(0,0))
        --          grayBuildSp:setTag(tonumber(self:getBid() .. 112))
        --          self.buildSp:addChild(grayBuildSp)
        --       else
        --           local grayBuildSp = tolua.cast(self.buildSp:getChildByTag(tonumber(self:getBid() .. 112)),"GraySprite")
        --           if grayBuildSp then
        --               grayBuildSp:removeFromParentAndCleanup(true)
        --               grayBuildSp=nil
        --           end
        --       end
        --   end
        -- end
        
        -- 军徽更换地板图片,冬天地图图片自带地板，与此图片位置重合(位置变动时需注意冬天地图)
        -- if(self:getBid()==104 or self:getBid()==105) and self.floorSp==nil then
        --     local floorSp = CCSprite:createWithSpriteFrameName("portModifyFloor.png")
        --     -- floorSp:setPosition(ccp(_posX + 13,_posY + 37))
        --     floorSp:setPosition(ccp(homeCfg.newFloorPos[1],homeCfg.newFloorPos[2]))
        --     pscene.sceneSp:addChild(floorSp)
        --     self.floorSp=floorSp
        -- end
        
        if self:getType() == 11 then --异星科技建筑特效
            local animSp, animSpTb = alienTechVoApi:createAlienTechBase()
            animSp:setPosition(getCenterPoint(self.buildSp))
            self.buildSp:addChild(animSp)
            self.bAnimSpTb = animSpTb
        end
        --local buildAnimSp
        local buildAction
        local frameName
        local animArr = CCArray:create()
        if self:getType() == 1 or self:getType() == 2 or self:getType() == 5 or self:getType() == 106 then
            --math.random()
            local playSpeed = 0.1
            local stIndex = math.ceil((deviceHelper:getRandom() / 100) * 9)
            if stIndex == 0 then
                stIndex = 1
            end
            if self:getType() == 1 then
                if stIndex >= 8 then
                    stIndex = 8
                end
                frameName = "tie_kuang_building_"..stIndex..".png"
                for kk = stIndex + 1, 8 do
                    local nameStr = "tie_kuang_building_"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    animArr:addObject(frame)
                end
                for kk = 1, stIndex do
                    local nameStr = "tie_kuang_building_"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    animArr:addObject(frame)
                end
            elseif self:getType() == 2 then
                if stIndex >= 8 then
                    stIndex = 8
                end
                frameName = "shi_you_building_"..stIndex..".png"
                for kk = stIndex + 1, 8 do
                    local nameStr = "shi_you_building_"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    animArr:addObject(frame)
                end
                for kk = 1, stIndex do
                    local nameStr = "shi_you_building_"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    animArr:addObject(frame)
                end
                playSpeed = 0.2
            elseif self:getType() == 5 then
                
                frameName = "shui_jing_gong_chang_building_"..stIndex..".png"
                if stIndex >= 10 then
                    stIndex = 9
                end
                for kk = stIndex + 1, 17 do
                    local nameStr = "shui_jing_gong_chang_building_"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    animArr:addObject(frame)
                end
                for kk = 1, stIndex do
                    local nameStr = "shui_jing_gong_chang_building_"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    animArr:addObject(frame)
                end
            elseif self:getType() == 106 then
                stIndex = 0
                playSpeed = 0.1
                frameName = "radarFrame"..stIndex..".png"
                for kk = stIndex + 1, 8 do
                    local nameStr = "radarFrame"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    animArr:addObject(frame)
                end
                local animation = CCAnimation:createWithSpriteFrames(animArr)
                animation:setDelayPerUnit(playSpeed)
                local animate = CCAnimate:create(animation)
                local reverseAc = animate:reverse()
                local delayAction = CCDelayTime:create(1.5)
                local delayAction2 = CCDelayTime:create(1.5)
                local acArr = CCArray:create()
                acArr:addObject(animate)
                acArr:addObject(delayAction)
                acArr:addObject(reverseAc)
                acArr:addObject(delayAction2)
                local seq = CCSequence:create(acArr)
                buildAction = CCRepeatForever:create(seq)
            end
            self.buildAnimSp = CCSprite:createWithSpriteFrameName(frameName)
            self.buildAnimSp:setAnchorPoint(ccp(0, 0))
            if self:getStatus() == 0 and self:getType() ~= 106 then --解锁了还没有建造不能播放生产动画
                self.buildAnimSp:setVisible(false)
            end
            
            -- 修正位置
            if self:getType() == 1 then
                -- 铁矿
                self.buildAnimSp:setPosition(ccp(0, 12))
                self.buildAnimSp:setScale(0.6)
            elseif self:getType() == 2 then
                -- 石油
                self.buildAnimSp:setPosition(ccp(10, 10))
                self.buildAnimSp:setScale(0.6)
            end
            
            self.buildSp:addChild(self.buildAnimSp)
            if buildAction then
                self.buildAnimSp:runAction(buildAction)
            else
                local animation = CCAnimation:createWithSpriteFrames(animArr)
                animation:setDelayPerUnit(playSpeed)
                local animate = CCAnimate:create(animation)
                local repeatForever = CCRepeatForever:create(animate)
                self.buildAnimSp:runAction(repeatForever)
            end
            
        end
        self.rgbv = 255
        
        self.lvTip = CCSprite:createWithSpriteFrameName("IconLevel.png")
        self.lvLb = GetTTFLabel(self:getLevel(), 30)
        self.lvLb:setPosition(ccp(self.lvTip:getContentSize().width / 2, self.lvTip:getContentSize().height / 2))
        self.lvTip:setScale(0.7)
        self.lvTip:addChild(self.lvLb)
        self.buildableIcon = CCSprite:createWithSpriteFrameName("buildingIcon.png")
        self.buildableIcon:setAnchorPoint(ccp(0.5, 0))
        
        -- 添加建筑名称
        if G_checkUseAuditUI() == true then
            self.nameTip = LuaCCScale9Sprite:createWithSpriteFrameName("building_name_tishen.png", CCRect(52, 24, 1, 1), function ()end)
        elseif G_getGameUIVer() == 1 then
            self.nameTip = CCSprite:create("public/building_name.png")
        else
            self.nameTip = LuaCCScale9Sprite:createWithSpriteFrameName("building_name1.png", CCRect(10.5, 14, 0.5, 1), function ()end)
            self.nameTip:setTouchPriority(1)
        end
        local str = getlocal(buildingCfg[self:getType()].buildName)
        
        local fontSize = 27
        if self:getBid() > 15 and self:getBid() ~= 101 and self:getBid() ~= 102 and self:getBid() ~= 103 and self:getBid() ~= 104 and self:getBid() ~= 105 and self:getBid() ~= 106 and self:getBid() ~= 107 and self:getBid() ~= 108 and self:getBid() ~= 109 and self:getBid() ~= 52 then
            fontSize = 20
        end
        if G_getGameUIVer() == 2 then
            fontSize = 20
            if self:getType() < 5 then
                fontSize = 14
            end
        end
        
        self.nameLb = GetTTFLabel(str, fontSize)
        self.nameLb:setAnchorPoint(ccp(0.5, 0.5))
        self.nameLb:setPosition(ccp(self.nameTip:getContentSize().width / 2, self.nameTip:getContentSize().height / 2))
        if G_checkUseAuditUI() == true or G_getGameUIVer() == 2 then
            self.nameLb:setColor(ccc3(255, 255, 255))
        else
            self.nameLb:setColor(ccc3(255, 255, 0))
        end
        self.nameLb:setScale(1 / buildScale)
        if G_checkUseAuditUI() == true then
            -- self.nameTip:setScaleY(0.9/buildScale)
            self.nameTip:setContentSize(CCSizeMake(self.nameLb:getContentSize().width + 50, self.nameLb:getContentSize().height + 16))
            if self:getType() == 107 then
                self.nameTip:setScale(1 / buildScale)
            end
        elseif G_getGameUIVer() == 1 then
            self.nameTip:setScaleY(0.9 / buildScale)
            self.nameTip:setScaleX((self.nameLb:getContentSize().width + 50) / self.nameTip:getContentSize().width)
        else
            self.nameTip:setContentSize(CCSizeMake(self.nameLb:getContentSize().width + 26, self.nameLb:getContentSize().height + 6))
            self.nameTip:setScaleY(0.9 / buildScale)
            if self:getType() == 107 then
                self.nameTip:setScaleY(1 / buildScale)
            end
        end
        
        if G_checkUseAuditUI() ~= true and G_getGameUIVer() ~= 2 and self:getBid() > 15 and self:getBid() ~= 101 and self:getBid() ~= 102 and self:getBid() ~= 103 and self:getBid() ~= 104 and self:getBid() ~= 105 and self:getBid() ~= 106 and self:getBid() ~= 107 and self:getBid() ~= 108 and self:getBid() ~= 109 and self:getBid() ~= 52 then
            self.nameTip:setScaleY(0.6)
        end
        -- self.nameLb:setScaleY(1/0.8)
        -- self.nameLb:setScaleX(self.nameTip:getContentSize().width/(self.nameLb:getContentSize().width+40))
        -- self.nameTip:addChild(self.nameLb)
        -- self.nameTip:setVisible(false)
        
        if(self:getStatus() ~= 0)then
            self.buildableIcon:setOpacity(0)
        end
        if self:getLevel() <= 0 then
            self.lvTip:setOpacity(0)
            self.lvLb:setString("")
            if G_isApplyVersion() == true then
                self.lvTip:setVisible(false)
            end
        else
            self.lvTip:setOpacity(255)
            if G_isApplyVersion() == true then
                self.lvTip:setVisible(true)
            end
        end
        local tmpIcon
        local tmpIcon1
        if(self:getType() == 16)then
            local function goFunctionDialog()
                local td = arenaTotalDialog:new(3, self.arenaTipType)
                local tbArr = {}
                local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("arena_total"), true, 3)
                sceneGame:addChild(dialog, 3)
            end
            self.specialIcon = LuaCCSprite:createWithSpriteFrameName("productItemBg.png", goFunctionDialog)
            self.specialIcon:setAnchorPoint(ccp(0.5, 0))
        elseif(self:getType() == 12)then
            -- self.specialIcon=CCSprite:createWithSpriteFrameName("productItemBg.png")
            -- self.specialIcon:setAnchorPoint(ccp(0.5,0))
            -- tmpIcon=CCSprite:createWithSpriteFrameName("recruitIcon.png")
            -- -- tmpIcon:setPosition(ccp(self.specialIcon:getContentSize().width/2-0.5,self.specialIcon:getContentSize().height/2+6))
            -- -- tmpIcon:setScale(61/tmpIcon:getContentSize().width)
            -- tmpIcon:setTag(3)
            -- self.specialIcon:addChild(tmpIcon)
        elseif(self:getType() == 101)then
            -- self.specialIcon=CCSprite:createWithSpriteFrameName("productItemBg.png")
            -- self.specialIcon:setAnchorPoint(ccp(0.5,0))
            -- tmpIcon=CCSprite:createWithSpriteFrameName("icon_supply_lines.png")
            -- -- tmpIcon:setPosition(ccp(self.specialIcon:getContentSize().width/2-0.5,self.specialIcon:getContentSize().height/2+6))
            -- -- tmpIcon:setScale(61/tmpIcon:getContentSize().width)
            -- tmpIcon:setTag(1)
            -- self.specialIcon:addChild(tmpIcon)
            
            -- tmpIcon1=CCSprite:createWithSpriteFrameName("jiyou.png")
            -- -- tmpIcon1:setPosition(ccp(self.specialIcon:getContentSize().width/2-0.5,self.specialIcon:getContentSize().height/2+6))
            -- -- tmpIcon1:setScale(64/tmpIcon1:getContentSize().width)
            -- tmpIcon1:setTag(2)
            -- self.specialIcon:addChild(tmpIcon1)
        elseif(self:getType() == 102)then
            -- self.specialIcon=CCSprite:createWithSpriteFrameName("productItemBg.png")
            -- self.specialIcon:setAnchorPoint(ccp(0.5,0))
            CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/superWeapon/swChallenge.plist")
            -- tmpIcon=CCSprite:createWithSpriteFrameName("sw_2.png")
            -- -- tmpIcon:setPosition(ccp(self.specialIcon:getContentSize().width/2-0.5,self.specialIcon:getContentSize().height/2+6))
            -- -- tmpIcon:setScale(61/tmpIcon:getContentSize().width)
            -- tmpIcon:setTag(1)
            -- self.specialIcon:addChild(tmpIcon)
            
            -- tmpIcon1=CCSprite:createWithSpriteFrameName("sw_3.png")
            -- -- tmpIcon1:setPosition(ccp(self.specialIcon:getContentSize().width/2-0.5,self.specialIcon:getContentSize().height/2+6))
            -- -- tmpIcon1:setScale(64/tmpIcon1:getContentSize().width)
            -- tmpIcon1:setTag(2)
            -- self.specialIcon:addChild(tmpIcon1)
        elseif(self:getType() == 103)then
            self.specialIcon = CCSprite:createWithSpriteFrameName("buildingTipBg.png")
            self.specialIcon:setAnchorPoint(ccp(0.5, 0))
            -- self.specialIcon:setScale(1.2)
            if ladderVoApi then
                
                local championName, serverName = ladderVoApi:getChampionName()
                local serverNameLb = GetTTFLabel(serverName, 22)
                serverNameLb:setPosition(ccp(self.specialIcon:getContentSize().width / 2, self.specialIcon:getContentSize().height - serverNameLb:getContentSize().height - 18))
                self.specialIcon:addChild(serverNameLb)
                
                local championNameLb = GetTTFLabel(championName, 22)
                championNameLb:setPosition(ccp(self.specialIcon:getContentSize().width / 2, self.specialIcon:getContentSize().height - serverNameLb:getContentSize().height - championNameLb:getContentSize().height - 16))
                self.specialIcon:addChild(championNameLb)
                
                local ladderLight = CCParticleSystemQuad:create("homeBuilding/ladderLight.plist")
                ladderLight.positionType = kCCPositionTypeFree
                ladderLight:setPosition(ccp(self.specialIcon:getContentSize().width / 2, 10))
                self.specialIcon:addChild(ladderLight, 1)
                
                local add = 10
                local function func1()
                    if self and self.specialIcon then
                        
                        local opacity = self.specialIcon:getOpacity()
                        -- print("----dmj----1---getOpacity:"..opacity)
                        if opacity == 255 then
                            self.specialIcon:setOpacity(opacity - add)
                            championNameLb:setOpacity(opacity - add)
                            serverNameLb:setOpacity(opacity - add)
                        elseif opacity == 155 then
                            self.specialIcon:setOpacity(opacity + add + 5)
                            championNameLb:setOpacity(opacity + add + 5)
                            serverNameLb:setOpacity(opacity + add + 5)
                        elseif opacity % 10 == 0 then
                            if opacity == 250 then
                                self.specialIcon:setOpacity(opacity + 5)
                                championNameLb:setOpacity(opacity + 5)
                                serverNameLb:setOpacity(opacity + 5)
                            else
                                self.specialIcon:setOpacity(opacity + add)
                                championNameLb:setOpacity(opacity + add)
                                serverNameLb:setOpacity(opacity + add)
                            end
                        else
                            self.specialIcon:setOpacity(opacity - add)
                            championNameLb:setOpacity(opacity - add)
                            serverNameLb:setOpacity(opacity - add)
                        end
                    end
                end
                
                local callFunc1 = CCCallFunc:create(func1)
                local delay = CCDelayTime:create(0.2)
                local acArr = CCArray:create()
                acArr:addObject(callFunc1)
                acArr:addObject(delay)
                local seq = CCSequence:create(acArr)
                local repeatForever = CCRepeatForever:create(seq)
                self.specialIcon:runAction(repeatForever)
            end
        end
        if(self.specialIcon)then
            self.specialIcon:setVisible(false)
        end
        if(tmpIcon) and (self.specialIcon) then
            tmpIcon:setPosition(ccp(self.specialIcon:getContentSize().width / 2, self.specialIcon:getContentSize().height / 2 + 6))
            tmpIcon:setScaleX(60 / tmpIcon:getContentSize().width)
            tmpIcon:setScaleY(60 / tmpIcon:getContentSize().height)
        end
        if(tmpIcon1) and (self.specialIcon) then
            tmpIcon1:setPosition(ccp(self.specialIcon:getContentSize().width / 2, self.specialIcon:getContentSize().height / 2 + 6))
            tmpIcon1:setScaleX(60 / tmpIcon1:getContentSize().width)
            tmpIcon1:setScaleY(60 / tmpIcon1:getContentSize().height)
        end
        self.lvTip:setAnchorPoint(CCPointMake(0.5, 0.5))
        local tagPointSub = buildingCfg[self:getType()].tagPos
        if self:getType() == 15 and self:getLevel() == 0 and allianceVoApi:getSelfAlliance() then
            self.lvTip:setOpacity(255)
            self.lvTip:setVisible(true)
            self.lvLb:setString("1")
        end
        
        -- 一键帮助（帮助军团玩家升级）
        if self:getType() == 15 and base.allianceHelpSwitch == 1 then
            -- local function helpOtherCallback()
            --     if G_checkClickEnable()==false then
            --         do
            --             return
            --         end
            --     else
            --         base.setWaitTime=G_getCurDeviceMillTime()
            --     end
            --     PlayEffect(audioCfg.mouseClick)
            
            --     if self.helpOtherSp and self.helpOtherSp:isVisible()==false then
            --       return
            --     end
            --     local list=allianceHelpVoApi:getList(1)
            --     if list and SizeOfTable(list)>0 then
            --         local selfAlliance=allianceVoApi:getSelfAlliance()
            --         if selfAlliance then
            --             local aid=selfAlliance.aid
            --             local httpUrl="http://"..base.serverIp.."/tank-server/public/index.php/api/alliancehelp/help"
            --             local reqStr="zoneid="..base.curZoneID.."&uid="..playerVoApi:getUid().."&aid="..aid
            --             -- print(httpUrl)
            --             -- print(reqStr)
            --             -- HttpRequestHelper:sendAsynHttpRequest(httpUrl.."?"..reqStr,"")
            --             G_sendAsynHttpRequestNoResponse(httpUrl.."?"..reqStr)
            --             -- local retStr=G_sendHttpRequest(httpUrl.."?"..reqStr,"")
            --             -- print(retStr)
            --             -- if(retStr~="")then
            --             --     local retData=G_Json.decode(retStr)
            --             --     if (retData["ret"]==0 or retData["ret"]=="0") and retData.data then
            --                     allianceHelpVoApi:clearList(1)
            --                     allianceHelpVoApi:setHasMore(false)
            --                     smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_help_help_all_success"),30)
            --                     if self.helpOtherSp then
            --                         self.helpOtherSp:setVisible(false)
            --                     end
            --                     local params={uid=playerVoApi:getUid()}
            --                     chatVoApi:sendUpdateMessage(31,params,aid+1)
            --             --     end
            --             -- end
            --         end
            --     end
            -- end
            -- self.helpOtherSp=LuaCCSprite:createWithSpriteFrameName("helpAll.png",helpOtherCallback)
            -- self.helpOtherSp:setPosition(ccp(self.buildSp:getContentSize().width/2,self.buildSp:getContentSize().height-self.helpOtherSp:getContentSize().height/2))
            -- self.helpOtherSp:setVisible(false)
            -- self.helpOtherSp:setTouchPriority(-11)
            -- self.helpOtherSp:setIsSallow(true)
            -- self.helpOtherSp:setAnchorPoint(ccp(0.5,0))
            -- self.buildSp:addChild(self.helpOtherSp)
            -- self.helpOtherSp:setScale(1.2)
        end
        
        --以下设置等级和可建造图标的坐标
        local tipX, tipY = 0, 0
        if platCfg.platUseUIWindow[G_curPlatName()] ~= nil and platCfg.platUseUIWindow[G_curPlatName()] == 2 then
            if self:getType() == 5 then --水晶工厂等级图标
                tipX = 50
                tipY = -30
            elseif self:getType() == 6 or self:getType() == 14 then --坦克工厂和改装车间
                tipX = 15
                tipY = 10
            elseif self:getType() == 7 then --指挥中心
                tipX = 45
                tipY = 12
            elseif self:getType() == 8 then --科研中心
                tipX = 20
                tipY = -10
            elseif self:getType() == 9 then --装置车间
                tipX = -10
                tipY = 5
            elseif self:getType() == 10 then --仓库
                tipX = 5
                tipY = 0
                -- elseif self:getType()==2 then --油井
                --     tipX=-45
                --     tipY=-5
            elseif self:getType() == 15 then --军团
                tipX = 10
                tipY = -10
            elseif self:getType() == 16 then --作战中心
                tipX = -30
                tipY = 70
            elseif self:getType() == 12 then --军事学院
                tipY = 20
            end
            
        else
            if self:getType() == 5 then --水晶工厂等级图标
                tipX = -6
                tipY = 30
            elseif self:getType() == 7 then
                tipX = 30
                tipY = 0
                if G_getGameUIVer() == 2 then
                    tipX = 0
                    tipY = 0
                end
                -- elseif self:getType()==2 then
                --      tipX=-46
                --      tipY=-5
            elseif self:getType() == 15 then
                tipX = -10
                tipY = -10
            elseif self:getType() == 16 then --作战中心
                if G_isShowNewMapAndBuildings() == 1 then
                    tipX = 10
                    tipY = 40
                else
                    tipX = -30
                    tipY = 70
                end
            elseif self:getType() == 12 then --军事学院
                tipY = 20
            elseif self:getType() == 101 then
                tipY = 45
            elseif self:getType() == 102 then
                tipY = 70
            elseif self:getType() == 8 then --科研中心
                if G_isShowNewMapAndBuildings() == 1 then
                    tipX = 20
                    tipY = 0
                end
            elseif self:getType() == 103 then --天梯榜
                tipX = -25
                tipY = 8
            end
            
        end
        self.tipX = tipX
        self.tipY = tipY
        --以上设置等级图标
        self.lvTip:setPosition(ccp(self.buildSp:getContentSize().width / 2 + tagPointSub.x + tipX, self.buildSp:getContentSize().height / 2 + tagPointSub.y + tipY))
        self.buildableIcon:setPosition(ccp(self.buildSp:getContentSize().width / 2 + tagPointSub.x + tipX, self.buildSp:getContentSize().height / 2 + tagPointSub.y + tipY))
        self.buildSp:addChild(self.lvTip, 2)
        self.buildSp:addChild(self.buildableIcon, 2)
        
        self.nameTip:setPosition(ccp(self.buildSp:getContentSize().width / 2 + tagPointSub.x + tipX, self.buildSp:getContentSize().height / 2 + tagPointSub.y + tipY))
        self.nameLb:setPosition(ccp(self.buildSp:getContentSize().width / 2 + tagPointSub.x + tipX, self.buildSp:getContentSize().height / 2 + tagPointSub.y + tipY))
        self.buildSp:addChild(self.nameTip, 2)
        self.buildSp:addChild(self.nameLb, 2)
        
        local time = 0.07
        local rotate1 = CCRotateTo:create(time, 30)
        local rotate2 = CCRotateTo:create(time, -30)
        local rotate3 = CCRotateTo:create(time, 20)
        local rotate4 = CCRotateTo:create(time, -20)
        local rotate5 = CCRotateTo:create(time, 0)
        
        local delay = CCDelayTime:create(1)
        local acArr = CCArray:create()
        acArr:addObject(rotate1)
        acArr:addObject(rotate2)
        acArr:addObject(rotate3)
        acArr:addObject(rotate4)
        acArr:addObject(rotate5)
        acArr:addObject(delay)
        local seq = CCSequence:create(acArr)
        local repeatForever = CCRepeatForever:create(seq)
        self.buildableIcon:runAction(repeatForever)
        
        if(self.specialIcon)then
            self.specialIcon:setPosition(ccp(self.buildSp:getContentSize().width / 2 + tagPointSub.x + tipX, self.buildSp:getContentSize().height / 2 + tagPointSub.y + tipY + 20))
            self.buildSp:addChild(self.specialIcon, 2)
        end
    elseif self:getBid() < 16 or self:getBid() == 52 then --port显示灰色建筑和0等级建筑
        local function nilFunc()
        end
        local callBack = clickBuilding
        if buildingVoApi:isYouhua() and (self:getBid() < 16 or self:getBid() == 52) then
            local isVisibleFlag = buildingVoApi:isBuildingVisible(self:getBid())
            if isVisibleFlag == false then
                callBack = nilFunc
            end
        end
        
        local btype = homeCfg.buildingUnlock[self:getBid()].type
        self.buildSp = LuaCCSprite:createWithSpriteFrameName(buildingCfg[tonumber(btype)].style, callBack)
        
        if self:getStatus() == -1 then --未解锁
            -- 显示的开关（建筑）
            if buildingVoApi:isYouhua() and (self:getBid() < 16 or self:getBid() == 52) then
                -- 添加逻辑方法
                local isVisibleFlag = buildingVoApi:isBuildingVisible(self:getBid())
                if isVisibleFlag == false then
                    self.buildSp:setVisible(false)
                else
                    self.grayBuildSp = GraySprite:createWithSpriteFrameName(buildingCfg[tonumber(btype)].style)
                    self.grayBuildSp:setAnchorPoint(ccp(0, 0))
                    self.buildSp:addChild(self.grayBuildSp)
                end
            else
                self.grayBuildSp = GraySprite:createWithSpriteFrameName(buildingCfg[tonumber(btype)].style)
                self.grayBuildSp:setAnchorPoint(ccp(0, 0))
                self.buildSp:addChild(self.grayBuildSp)
                --self.grayBuildSp:setOpacity(150)
            end
            
        else
            if self.grayBuildSp ~= nil then
                self.grayBuildSp:removeFromParentAndCleanup(true)
                self.grayBuildSp = nil
            end
            self.rgbv = 255
            self.buildSp:setColor(ccc3(self.rgbv, self.rgbv, self.rgbv))
            self.buildSp:setOpacity(130)
            
        end
    elseif self:getBid() >= 16 then --home显示地块
        self.isArea = true
        if (platCfg.platUseUIWindow[G_curPlatName()] ~= nil and platCfg.platUseUIWindow[G_curPlatName()] == 2) or G_isShowNewMapAndBuildings() == 1 then
            
            local function clickNilBuilding()
            end
            if homeCfg.buildingUnlock[self:getBid()].type == 4 then
                self.buildSp = LuaCCSprite:createWithSpriteFrameName("di_kuai_tai.png", clickNilBuilding)
            else
                self.buildSp = LuaCCSprite:createWithSpriteFrameName("di_kuai_normal.png", clickNilBuilding)
            end
            local buildClickSp = LuaCCSprite:createWithSpriteFrameName("smallGreen2QuadrateBg.png", clickBuilding)
            -- local buildClickSp = LuaCCSprite:createWithSpriteFrameName("jiaowai_ziyuan.png",clickBuilding)
            buildClickSp:setPosition(ccp(self.buildSp:getContentSize().width * 0.4, self.buildSp:getContentSize().height * 0.5))
            buildClickSp:setTouchPriority(-10)
            buildClickSp:setScaleX(4)
            buildClickSp:setScaleY(2.5)
            -- buildClickSp:setOpacity(0)
            buildClickSp:setIsSallow(false)
            -- buildClickSp:setVisible(false)
            self.buildSp:addChild(buildClickSp, 2)
        else
            if homeCfg.buildingUnlock[self:getBid()].type == 4 then
                self.buildSp = LuaCCSprite:createWithSpriteFrameName("di_kuai_tai.png", clickBuilding)
            else
                self.buildSp = LuaCCSprite:createWithSpriteFrameName("di_kuai_normal.png", clickBuilding)
            end
            buildScale = 0.85
        end
        self.rgbv = 255
        
    end
    self.buildSp:setTouchPriority(0)
    self.buildSp:setIsSallow(true)
    self.buildSp:setAnchorPoint(ccp(0.5, 0.5))
    self.buildSp:setScale(buildScale)
    self.buildSp:setPosition(ccp(_posX, _posY))
    local bxx, byy = homeCfg:getBuildingPosById(self:getBid())
    local useNum = byy
    if self:getType() and tonumber(self:getType()) == 10 then--主城车队仓库的遮挡问题造成如此处理
        useNum = 801
    end
    pscene.sceneSp:addChild(self.buildSp, base:getBuildingOrderIDByBid(useNum) + 5)
    
    local useBid = self:getBid()
    if useBid > 15 and useBid < 45 then--移动标识
        local function chooseCall()
            if G_checkClickEnable() == false then
                do return end
            else
                base.setWaitTime = G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
            end
            
            PlayEffect(audioCfg.mouseClick)
            if pscene.isMoved == true then
                pscene.isMoved = false
                do return end
            end
            if self:getStatus() == 2 then
                pscene:removeShowTip()
                do return end
            end
            local useBid = self:getBid()
            local isFirstChooseId = false
            print("chooseCall~~~~~~~~~~~~", useBid)
            local allBuildsVo = buildingVoApi:getHomeBuilding()
            for k, v in pairs(allBuildsVo) do
                if v.id == useBid and buildings.allBuildings[v.id].movTipSpChange == true then
                    isFirstChooseId = true
                    do break end
                end
            end
            if not isFirstChooseId then
                self:chooseBuilding(useBid)
                pscene.movMaskBg:setOpacity(150)
                pscene:showTip(getlocal("movConfirmStr2"), true, useBid)
            end
        end
        self.movTipSpChose = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), chooseCall)
        self.movTipSpChose:setContentSize(CCSizeMake(80, 80))
        self.movTipSpChose:setOpacity(0)
        self.movTipOldPos = ccp(-100, -100)
        self.movTipUsePos = ccp(_posX, _posY)
        self.movTipSpChange = false--只用于要替换的地块（第一个点击的建筑地块）
        self.movTipSpChose:setPosition(self.movTipOldPos)
        self.movTipSpChose:setTouchPriority(-1)
        self.movTipSpChose:setIsSallow(true)
        pscene.sceneSp:addChild(self.movTipSpChose, base:getBuildingOrderIDByBid(byy) + 4)
        self.movTipSpChose:setVisible(false)
        
        self.movTipSp = CCSprite:createWithSpriteFrameName("chooseLots.png")
        self.movTipSp:setScale(0.8)
        self.movTipSp:setPosition(getCenterPoint(self.movTipSpChose))
        self.movTipSpChose:addChild(self.movTipSp)
    end
    --空中打击系统建筑效果
    if base.plane == 1 and self:getType() == 106 then
        local youhuaFlag = buildingVoApi:isYouhua()
        local isVisibleFlag = buildingVoApi:isBuildingVisible(self:getBid())
        if (youhuaFlag == true and isVisibleFlag == true) or (youhuaFlag == false) then
            -- local baseSp=CCSprite:createWithSpriteFrameName("planePark.png")
            -- baseSp:setPosition(500,830)
            -- baseSp:setScale(buildScale)
            -- pscene.sceneSp:addChild(baseSp,base:getBuildingOrderIDByBid(byy)-1)
            local function showPlane()
                local posCfg = {{260, 120}, {205, 55}, {205, 95}, {260, 90}}
                local planeList = planeVoApi:getPlaneList()
                for i = 1, 4 do
                    local pic = "parkPlane_p"..i..".png"
                    local planeSp
                    local pid = "p"..i
                    local unlockFlag = planeVoApi:isPlaneUnlock(pid)
                    if unlockFlag == true then
                        planeSp = CCSprite:createWithSpriteFrameName(pic)
                    else
                        planeSp = GraySprite:createWithSpriteFrameName(pic)
                    end
                    if planeSp then
                        planeSp:setPosition(posCfg[i][1], posCfg[i][2])
                        planeSp:setTag(10000 + i)
                        self.buildSp:addChild(planeSp)
                    end
                end
            end
            planeVoApi:planeGet(showPlane)
        end
    elseif self:getType() == 107 then
        local posCfg = {ccp(96, 36.5), ccp(98, 38.5), ccp(97.5, 39.5), ccp(92.5, 44.5), ccp(96, 41.5), ccp(98, 46.5), ccp(99.5, 40.5)}
        if G_getGameUIVer() == 2 then
            posCfg = {ccp(148, 50.5), ccp(151, 52.5), ccp(150.5, 53.5), ccp(145.5, 58.5), ccp(150, 56.5), ccp(152.5, 57), ccp(151, 60.5)}
        end
        local tag = self:getType()
        local sid = warStatueVoApi:getSelectSid()
        if statueCfg.room["s"..sid] == nil then
            sid = SizeOfTable(posCfg)
        end
        local statuePos = posCfg[sid]
        if statuePos == nil then
            statuePos = ccp(99.5, 40.5)
            if G_getGameUIVer() == 2 then
                statuePos = ccp(151, 60.5)
            end
        end
        local statuePic = "smallws_"..sid..".png"
        local statueSp = CCSprite:createWithSpriteFrameName(statuePic)
        statueSp:setPosition(statuePos)
        statueSp:setTag(tag)
        self.buildSp:addChild(statueSp)
    elseif self:getType() == 109 then --战略中心
        local statueSp = CCSprite:createWithSpriteFrameName("strategic_statue.png")
        statueSp:setPosition(244.5, 125)
        self.buildSp:addChild(statueSp)
        local radarSp = CCSprite:createWithSpriteFrameName("strategic_radar1.png")
        G_playFrame(radarSp, {frmn = 8, frname = "strategic_radar", perdelay = 0.1, forever = {0, 0}})
        radarSp:setPosition(178.5, 201)
        self.buildSp:addChild(radarSp)
        
        self.bAnimSpTb = {statueSp, radarSp}
    elseif self:getType() == 18 then --飞艇
        local yanSp = CCSprite:createWithSpriteFrameName("airship_yan1.png")
        yanSp:setPosition(201, 208.5)
        G_playFrame(yanSp, {frmn = 10, frname = "airship_yan", perdelay = 0.1, forever = {0, 0.1}, blendType = 0})
        self.buildSp:addChild(yanSp)
        local liangSp11 = CCSprite:createWithSpriteFrameName("airship_liang1.png")
        liangSp11:setPosition(self.buildSp:getContentSize().width / 2 - 100, self.buildSp:getContentSize().height / 2 + 24)
        self.buildSp:addChild(liangSp11)
        G_playFade(liangSp11, {startOpacity = 255 * 0.4, fv = {255, 0, 255 * 0.4}, ft = {0.3, 0.5, 0.2}, forever = {1, 0}, blend = 1})
        
        local liangSp12 = CCSprite:createWithSpriteFrameName("airship_liang2.png")
        liangSp12:setPosition(self.buildSp:getContentSize().width / 2 - 97, self.buildSp:getContentSize().height / 2 + 7)
        self.buildSp:addChild(liangSp12)
        G_playFade(liangSp12, {startOpacity = 255, fv = {0, 255}, ft = {0.5, 0.5}, forever = {1, 0}, blend = 1})
        
        local liangSp13 = CCSprite:createWithSpriteFrameName("airship_liang3.png")
        liangSp13:setPosition(self.buildSp:getContentSize().width / 2 - 93, self.buildSp:getContentSize().height / 2 - 2)
        self.buildSp:addChild(liangSp13)
        G_playFade(liangSp13, {startOpacity = 255 * 0.5, fv = {255, 255 * 0.5}, ft = {0.5, 0.5}, forever = {1, 0}, blend = 1})
        
        local liangSp21 = CCSprite:createWithSpriteFrameName("airship_liang1.png")
        liangSp21:setPosition(self.buildSp:getContentSize().width / 2 - 41, self.buildSp:getContentSize().height / 2 - 6)
        self.buildSp:addChild(liangSp21)
        G_playFade(liangSp21, {startOpacity = 255 * 0.6, fv = {0, 255, 255 * 0.6}, ft = {0.3, 0.5, 0.2}, forever = {1, 0}, blend = 1})
        
        local liangSp22 = CCSprite:createWithSpriteFrameName("airship_liang2.png")
        liangSp22:setPosition(self.buildSp:getContentSize().width / 2 + 23, self.buildSp:getContentSize().height / 2 - 52)
        self.buildSp:addChild(liangSp22)
        G_playFade(liangSp22, {startOpacity = 0, fv = {255, 0}, ft = {0.5, 0.5}, forever = {1, 0}, blend = 1})
        
        local liangSp23 = CCSprite:createWithSpriteFrameName("airship_liang3.png")
        liangSp23:setPosition(self.buildSp:getContentSize().width / 2 + 26, self.buildSp:getContentSize().height / 2 - 61)
        self.buildSp:addChild(liangSp23)
        G_playFade(liangSp23, {startOpacity = 255, fv = {255 * 0.5, 255}, ft = {0.5, 0.5}, forever = {1, 0}, blend = 1})
        local huohuaTb = {{92, 26.5}, {49, 49}, {13, 66}, {-21, 84}, {-66, 89}}
        --播放电焊动画
        local function playHuohua()
            local rIdx = math.random(1, 5)
            local huohuaSp = CCSprite:createWithSpriteFrameName("airship_huohua1.png")
            huohuaSp:setPosition(self.buildSp:getContentSize().width / 2 + huohuaTb[rIdx][1], self.buildSp:getContentSize().height / 2 + huohuaTb[rIdx][2])
            self.buildSp:addChild(huohuaSp)
            local function playEnd()
                huohuaSp:removeFromParentAndCleanup(true)
                huohuaSp = nil
            end
            G_playFrame(huohuaSp, {frmn = 9, frname = "airship_huohua", perdelay = 0.1, forever = {-1, 0}, blendType = 0, callback = playEnd})
        end
        local huohuaAc = CCSequence:createWithTwoActions(CCCallFunc:create(playHuohua), CCDelayTime:create(1.5))
        self.buildSp:runAction(CCRepeatForever:create(huohuaAc))
        
        self:refreshBuild({btype = self:getType()})
    end
    
    self:tick()
end

function baseBuilding:chooseBuilding(chooseBid)
    local allBuildsVo = buildingVoApi:getHomeBuilding()
    for k, v in pairs(allBuildsVo) do
        if buildings.allBuildings[v.id] and buildings.allBuildings[v.id].movTipSp and chooseBid ~= v.id and buildings.allBuildings[v.id].movTipSpChange == false then
            buildings.allBuildings[v.id]:stopChooseAction()
        end
    end
end
function baseBuilding:runChooseAction()--移动标识 动画
    local scaleTo1 = CCScaleTo:create(0.8, 1);
    local scaleTo2 = CCScaleTo:create(1, 0.8);
    local arr = CCArray:create()
    arr:addObject(scaleTo1)
    arr:addObject(scaleTo2)
    local seq = CCSequence:create(arr)
    local repeatForever = CCRepeatForever:create(seq)
    self.movTipSp:runAction(repeatForever)
end
function baseBuilding:stopChooseAction()--移动标识 停止动画
    self.movTipSp:stopAllActions()
    if self.movTipSpChange then
        self.movTipSpChange = false
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("chooseLots.png")
        if frame then
            tolua.cast(self.movTipSp, "CCSprite"):setDisplayFrame(frame)
        end
    end
    self.movTipSpChose:setVisible(false)
    self.movTipSpChose:setPosition(self.movTipOldPos)
end

function baseBuilding:refreshBuild(data)
    if data == nil then
        do return end
    end
    local btype = data.btype or 0
    if btype ~= self:getType() then
        do return end
    end
    if btype == 106 then --空中打击建筑飞机解锁状态刷新
        local planeList = planeVoApi:getPlaneList()
        for i = 1, 4 do
            local pic = "parkPlane_p"..i..".png"
            local planeSp = self.buildSp:getChildByTag(10000 + i)
            if planeSp then
                local px, py = planeSp:getPosition()
                planeSp:removeFromParentAndCleanup(true)
                planeSp = nil
                local pid = "p"..i
                local unlockFlag = planeVoApi:isPlaneUnlock(pid)
                if unlockFlag == true then
                    planeSp = CCSprite:createWithSpriteFrameName(pic)
                else
                    planeSp = GraySprite:createWithSpriteFrameName(pic)
                end
                if planeSp then
                    planeSp:setPosition(px, py)
                    planeSp:setTag(10000 + i)
                    self.buildSp:addChild(planeSp)
                end
            end
        end
    elseif btype == 107 then
        local statueSp = tolua.cast(self.buildSp:getChildByTag(btype), "CCSprite")
        if statueSp then
            local posCfg = {ccp(96, 36.5), ccp(98, 38.5), ccp(97.5, 39.5), ccp(92.5, 44.5), ccp(96, 41.5), ccp(98, 46.5), ccp(99.5, 40.5)}
            if G_getGameUIVer() == 2 then
                posCfg = {ccp(148, 50.5), ccp(151, 52.5), ccp(150.5, 53.5), ccp(145.5, 58.5), ccp(150, 56.5), ccp(152.5, 57), ccp(151, 60.5)}
            end
            local sid = warStatueVoApi:getSelectSid()
            if statueCfg.room["s"..sid] == nil then
                sid = SizeOfTable(posCfg)
            end
            local statuePos = posCfg[sid]
            if statuePos == nil then
                statuePos = ccp(99.5, 40.5)
                if G_getGameUIVer() == 2 then
                    statuePos = ccp(151, 60.5)
                end
            end
            local statuePic = "smallws_"..sid..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(statuePic)
            if frame then
                statueSp:setDisplayFrame(frame)
                statueSp:setPosition(statuePos)
            end
        end
    elseif btype == 7 then
        base.buildingSortTb = nil --置为空，重新排序建筑层级
        self:show(self.parent, true)
    elseif btype == 18 and airShipVoApi:isCanEnter() == true then --刷新飞艇建筑的悬浮飞艇
        if self.airShipSp and tolua.cast(self.airShipSp, "CCSprite") then
            self.airShipSp:removeFromParentAndCleanup(true)
            self.airShipSp = nil
        end
        local airShipSp = G_showAirShip(airShipVoApi:getCurShowAirShip())
        airShipSp:setPosition(2451.5, 1239.5)
        airShipSp:setScale(0.45)
        self.parent.sceneSp:addChild(airShipSp, self.buildSp:getZOrder() + 1)
        --飞艇做翻转操作
        G_setSpriteFlip(airShipSp, {x = true, y = false}, false)
        --飞艇做漂浮动作
        local movBy = CCMoveBy:create(1.5, ccp(0, 5))
        airShipSp:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(movBy, movBy:reverse())))
        
        self.airShipSp = airShipSp
    end
end

function baseBuilding:tick()
    if self.isArea == true and self:getType() ~= -1 then --有了建筑了但没有显示图片
        self:show(self.parent, true)
        do
            return
        end
    end
    if self.ccprogress == nil and self:getStatus() == 2 then --添加升级进度条
        --node:父容器 point:坐标 tagPro:proGress tag值  tagLabel: label tag值 labelText:显示的文字 spriteNameBg:背景图帧名 spriteNamePro:前景图帧名
        if self:getType() == -1 then
            do
                return
            end
        end
        local tagPointSub = buildingCfg[self:getType()].tagPos
        local ysub = 0
        if self:getType() < 5 then
            ysub = ysub + 40
        elseif self:getType() == 5 then
            ysub = ysub - 10
        end
        local progressScaleX = 1
        if self.bid >= 16 then
            progressScaleX = 0.7
        end
        AddProgramTimer(self.buildSp, ccp(self.buildSp:getContentSize().width / 2 + tagPointSub.x, 30 + ysub), 10, nil, nil, "BuildUpBarBg.png", "BuildUpBar.png", 11, progressScaleX)
        self.ccprogress = self.buildSp:getChildByTag(10)
        self.ccprogress = tolua.cast(self.ccprogress, "CCProgressTimer")
        self.ccprogress:setPercentage(self:getPercent() * 100)
    elseif self:getStatus() == 2 then --刷新升级进度条
        self.ccprogress = tolua.cast(self.ccprogress, "CCProgressTimer")
        self.ccprogress:setPercentage(self:getPercent() * 100)
    elseif self:getStatus() == 1 then --升级完成
        if self.ccprogress ~= nil then
            self.ccprogress:removeFromParentAndCleanup(true)
            self.ccprogress = nil
            tolua.cast(self.buildSp:getChildByTag(11), "CCSprite"):removeFromParentAndCleanup(true)
        end
    elseif self:getStatus() == 0 then --取消建造
        if self.ccprogress ~= nil then
            self.ccprogress:removeFromParentAndCleanup(true)
            self.ccprogress = nil
            tolua.cast(self.buildSp:getChildByTag(11), "CCSprite"):removeFromParentAndCleanup(true)
            self.rgbv = 255
            self.buildSp:setColor(ccc3(self.rgbv, self.rgbv, self.rgbv))
            self.buildSp:setOpacity(130)
            -- self:ajiw(self.buildSp)
        end
    end
    local blevel = self:getLevel()
    if self.lvLb ~= nil and tolua.cast(self.lvLb, "CCLabelTTF") then
        if blevel > 0 then
            self.lvLb:setString(blevel)
            self.lvTip:setOpacity(255)
            if G_isApplyVersion() == true then
                self.lvTip:setVisible(true)
            end
        else
            self.lvTip:setOpacity(0)
            self.lvLb:setString("")
            if G_isApplyVersion() == true then
                self.lvTip:setVisible(false)
            end
        end
        if self:getType() == 15 and self:getLevel() == 0 and allianceVoApi:getSelfAlliance() then
            self.lvTip:setOpacity(255)
            self.lvTip:setVisible(true)
            if allianceVoApi:getSelfAlliance().level ~= nil then
                self.lvLb:setString(allianceVoApi:getSelfAlliance().level)
            end
            
        end
    end
    if self.nameLb ~= nil and tolua.cast(self.nameLb, "CCLabelTTF") then
        if self:getType() and buildingCfg[self:getType()] and buildingCfg[self:getType()].buildName then
            local str = getlocal(buildingCfg[self:getType()].buildName)
            if self:getType() == 15 then
                local selfAlliance = allianceVoApi:getSelfAlliance()
                if selfAlliance and selfAlliance.name then
                    str = selfAlliance.name
                end
            end
            if blevel > 0 then
                local newstr = str .. " "..getlocal("lower_level") .. blevel
                if self:getType() == 17 then
                    newstr = str
                end
                self.nameLb:setString(newstr)
                if G_checkUseAuditUI() == true then
                    self.nameTip:setContentSize(CCSizeMake(self.nameLb:getContentSize().width + 50, self.nameLb:getContentSize().height + 16))
                elseif G_getGameUIVer() == 2 then
                    self.nameTip:setContentSize(CCSizeMake(self.nameLb:getContentSize().width + 26, self.nameLb:getContentSize().height + 8))
                    if self:getType() < 5 then
                        self.nameTip:setContentSize(CCSizeMake(self.nameLb:getContentSize().width + 16, self.nameLb:getContentSize().height + 10))
                    end
                else
                    self.nameTip:setScaleX((self.nameLb:getContentSize().width + 50) / self.nameTip:getContentSize().width)
                end
                -- self.nameLb:setScaleX(self.nameTip:getContentSize().width/(self.nameLb:getContentSize().width+10))
            else
                if self:getType() == 15 then
                    self.nameTip:setContentSize(CCSizeMake(self.nameLb:getContentSize().width + 26, self.nameLb:getContentSize().height + 8))
                end
                self.nameLb:setString(str)
            end
        end
    end
    local numKey = CCUserDefault:sharedUserDefault():getIntegerForKey("gameSettings_buildingDisplay")
    if numKey == 2 or numKey == 0 then
        if self.nameTip and tolua.cast(self.nameTip, "CCNode") then
            self.nameTip:setVisible(true)
        end
        if self.nameLb and tolua.cast(self.nameLb, "CCNode") then
            self.nameLb:setVisible(true)
        end
        if self.lvTip and tolua.cast(self.lvTip, "CCNode") then
            self.lvTip:setVisible(false)
        end
        if self.lvLb and tolua.cast(self.lvLb, "CCNode") then
            self.lvLb:setVisible(false)
        end
        
    else
        if self.nameTip and tolua.cast(self.nameTip, "CCNode") then
            self.nameTip:setVisible(false)
        end
        if self.nameLb and tolua.cast(self.nameLb, "CCNode") then
            self.nameLb:setVisible(false)
        end
        if self.lvTip and tolua.cast(self.lvTip, "CCNode") then
            self.lvTip:setVisible(true)
        end
        if self.lvLb and tolua.cast(self.lvLb, "CCNode") then
            self.lvLb:setVisible(true)
        end
        if G_isApplyVersion() == true and buildingVoApi:isBuildShowLvByType(self:getType()) == false then
            if self.lvTip and tolua.cast(self.lvTip, "CCNode") and self.lvLb and tolua.cast(self.lvLb, "CCNode") then
                self.lvTip:setVisible(false)
                self.lvLb:setVisible(false)
            end
        end
    end
    
    if(self.buildableIcon)then
        local type = self:getType()
        --军团军事演习和地库，异星科技，异星工厂，无需建造, 因此没有可建造图标
        if(type == 11 or type == 13 or type == 15 or type == 16 or type == 17 or type == 102 or type == 103 or type == 104 or type == 105 or type == 106 or type == 107 or type == 108 or type == 109 or type == 18 or self:getStatus() ~= 0)then
            if G_isApplyVersion() == true then
                self.buildableIcon:setVisible(false)
            end
            self.buildableIcon:setOpacity(0)
        else
            if G_isApplyVersion() == true then
                self.buildableIcon:setVisible(true)
            end
            self.buildableIcon:setOpacity(255)
        end
    end
    
    if self.buildAnimSp ~= nil and self:getStatus() > 0 and self.buildAnimSp:isVisible() == false then
        
        self.buildAnimSp:setVisible(true)
    end
    
    if self.bid < 16 and self:getBuildVo().lastStatus == -1 and self:getStatus() == 0 then
        --port场景变颜色
        if self:getType() ~= 15 then
            self:getBuildVo().lastStatus = 0
            self:show(self.parent, true, true)
            self.rgbv = 255
            self.buildSp:setColor(ccc3(self.rgbv, self.rgbv, self.rgbv))
            self.buildSp:setOpacity(130)
        end
    end
    
    if buildingVoApi:isYouhua() and buildingVoApi:isBuildingVisible(self:getBid()) and self.buildSp:isVisible() == false and (self.bid < 16 or self.bid == 101 or self:getBid() == 103 or self:getBid() == 104 or self:getBid() == 105 or self:getBid() == 106 or self:getBid() == 107 or self:getBid() == 108 or self:getBid() == 109 or self:getBid() == 52) then
        self:show(self.parent, true)
    end
    
    if self.bid == 102 then
        if self.buildSp:isVisible() == false and buildingVoApi:newBuildingVisible(self.bid) then
            self:show(self.parent, true)
            return
        end
        local openlevel = base.superWeaponOpenLv or 25
        local grayBuildSp = tolua.cast(self.buildSp:getChildByTag(tonumber(self:getBid() .. 111)), "GraySprite")
        if grayBuildSp and playerVoApi:getPlayerLevel() >= openlevel then
            self:show(self.parent, true)
            return
        end
    end
    if self:getBid() == 52 then
        local openlevel = airShipVoApi:getOpenLv()
        local grayBuildSp = tolua.cast(self.buildSp:getChildByTag(tonumber(self:getBid() .. 112)), "GraySprite")
        if grayBuildSp and playerVoApi:getPlayerLevel() >= openlevel then
            self:show(self.parent, true)
        end
    end
    
    local openlevel = base.superWeaponOpenLv or 25
    if(self.bid == 102 and self.buildSp:isVisible() and playerVoApi:getPlayerLevel() >= openlevel and otherGuideMgr:checkGuide(5) == false)then
        eventDispatcher:dispatchEvent("superWeapon.guide.show")
    end
    
    if self:getType() == 8 then --科研中心
        -- if SizeOfTable(technologySlotVoApi.allSlots)>0 then
        --     local ptechVo=technologySlotVoApi:getCurProduceSlot()
        --     if self.produceTipSp==nil then
        --         self.produceTipSp=CCSprite:createWithSpriteFrameName("productItemBg.png")
        --         self.buildSp:addChild(self.produceTipSp,2)
        --         self.curProduceTipTid=ptechVo.id
        --         local tcfg=techCfg[tonumber(ptechVo.id)]
        --         self.curProduceTipSp=CCSprite:createWithSpriteFrameName(tcfg.icon)
        
        --         -- self.curProduceTipSp:setAnchorPoint(ccp(0.5,0.5))
        --         -- self.curProduceTipSp:setScale(0.5)
        --         -- self.curProduceTipSp:setPosition(ccp(self.produceTipSp:getContentSize().width/2,self.produceTipSp:getContentSize().height/2+5))
        --         self.produceTipSp:addChild(self.curProduceTipSp)
        --         local tagPointSub=buildingCfg[self:getType()].tagPos
        --         if G_isShowNewMapAndBuildings()==1 then
        --             self.produceTipSp:setPosition(ccp(self.buildSp:getContentSize().width/2+tagPointSub.x+10,self.buildSp:getContentSize().height-40))
        --         else
        --             self.produceTipSp:setPosition(ccp(self.buildSp:getContentSize().width/2+tagPointSub.x,self.buildSp:getContentSize().height+20))
        --         end
        
        --     end
        --     if self.curProduceTipTid~=ptechVo.id then
        --         self.curProduceTipTid=ptechVo.id
        --         if self.curProduceTipSp~=nil then
        --             self.curProduceTipSp:removeFromParentAndCleanup(true)
        --             local tcfg=techCfg[tonumber(ptechVo.id)]
        --             self.curProduceTipSp=CCSprite:createWithSpriteFrameName(tcfg.icon)
        --             -- self.curProduceTipSp:setAnchorPoint(ccp(0.5,0.5))
        --             -- self.curProduceTipSp:setScale(0.5)
        --             -- self.curProduceTipSp:setPosition(ccp(self.produceTipSp:getContentSize().width/2,self.produceTipSp:getContentSize().height/2+5))
        --             self.produceTipSp:addChild(self.curProduceTipSp)
        --         end
        --     end
        -- else
        --     if self.produceTipSp~=nil then
        --         self.produceTipSp:removeFromParentAndCleanup(true)
        --         self.produceTipSp=nil
        --     end
        -- end
    elseif self:getType() == 6 then --坦克生产工厂
        -- if SizeOfTable(tankSlotVoApi:getSoltByBid(self.bid))>0 then
        --     local slotVo=tankSlotVoApi:getCurProduceSlot(self.bid)
        --     if self.produceTipSp==nil then
        --         self.produceTipSp=CCSprite:createWithSpriteFrameName("productItemBg.png")
        --         self.buildSp:addChild(self.produceTipSp,2)
        --         self.curProduceTipTid=slotVo.itemId
        --         local tcfg=tankCfg[tonumber(slotVo.itemId)]
        --         self.curProduceTipSp=CCSprite:createWithSpriteFrameName(tcfg.icon)
        
        --         -- self.curProduceTipSp:setAnchorPoint(ccp(0.5,0.5))
        --         -- self.curProduceTipSp:setScale(0.4)
        --         -- self.curProduceTipSp:setPosition(ccp(self.produceTipSp:getContentSize().width/2,self.produceTipSp:getContentSize().height/2+5))
        --         self.produceTipSp:addChild(self.curProduceTipSp)
        --         local tagPointSub=buildingCfg[self:getType()].tagPos
        --         self.produceTipSp:setPosition(ccp(self.buildSp:getContentSize().width/2+tagPointSub.x,self.buildSp:getContentSize().height+20))
        
        --     end
        --     if self.curProduceTipTid~=slotVo.itemId then
        --         self.curProduceTipTid=slotVo.itemId
        --         if self.curProduceTipSp~=nil then
        --             self.curProduceTipSp:removeFromParentAndCleanup(true)
        --             local tcfg=tankCfg[tonumber(slotVo.itemId)]
        --             self.curProduceTipSp=CCSprite:createWithSpriteFrameName(tcfg.icon)
        --             -- self.curProduceTipSp:setAnchorPoint(ccp(0.5,0.5))
        --             -- self.curProduceTipSp:setScale(0.4)
        --             -- self.curProduceTipSp:setPosition(ccp(self.produceTipSp:getContentSize().width/2,self.produceTipSp:getContentSize().height/2+5))
        --             self.produceTipSp:addChild(self.curProduceTipSp)
        --         end
        --     end
        -- else
        --     if self.produceTipSp~=nil then
        --         self.produceTipSp:removeFromParentAndCleanup(true)
        --         self.produceTipSp=nil
        --     end
        -- end
    elseif self:getType() == 14 then --坦克改装工厂
        -- if SizeOfTable(tankUpgradeSlotVoApi:getSoltByBid(self.bid))>0 then
        --     local slotVo=tankUpgradeSlotVoApi:getCurProduceSlot(self.bid)
        --     if self.produceTipSp==nil then
        --         self.produceTipSp=CCSprite:createWithSpriteFrameName("productItemBg.png")
        --         self.buildSp:addChild(self.produceTipSp,2)
        --         self.curProduceTipTid=slotVo.itemId
        --         local tcfg=tankCfg[tonumber(slotVo.itemId)]
        --         self.curProduceTipSp=CCSprite:createWithSpriteFrameName(tcfg.icon)
        
        --         -- self.curProduceTipSp:setAnchorPoint(ccp(0.5,0.5))
        --         -- self.curProduceTipSp:setScale(0.4)
        --         -- self.curProduceTipSp:setPosition(ccp(self.produceTipSp:getContentSize().width/2,self.produceTipSp:getContentSize().height/2+5))
        --         self.produceTipSp:addChild(self.curProduceTipSp)
        --         local tagPointSub=buildingCfg[self:getType()].tagPos
        --         self.produceTipSp:setPosition(ccp(self.buildSp:getContentSize().width/2+tagPointSub.x,self.buildSp:getContentSize().height+20))
        --     end
        --     if self.curProduceTipTid~=slotVo.itemId then
        --         self.curProduceTipTid=slotVo.itemId
        --         if self.curProduceTipSp~=nil then
        --             self.curProduceTipSp:removeFromParentAndCleanup(true)
        --             local tcfg=tankCfg[tonumber(slotVo.itemId)]
        --             self.curProduceTipSp=CCSprite:createWithSpriteFrameName(tcfg.icon)
        --             -- self.curProduceTipSp:setAnchorPoint(ccp(0.5,0.5))
        --             -- self.curProduceTipSp:setScale(0.4)
        --             -- self.curProduceTipSp:setPosition(ccp(self.produceTipSp:getContentSize().width/2,self.produceTipSp:getContentSize().height/2+5))
        --             self.produceTipSp:addChild(self.curProduceTipSp)
        --         end
        --     end
        -- else
        --     if self.produceTipSp~=nil then
        --         self.produceTipSp:removeFromParentAndCleanup(true)
        --         self.produceTipSp=nil
        --     end
        -- end
    elseif self:getType() == 9 then --道具制造车间
        -- if SizeOfTable(workShopSlotVoApi.allSlots)>0 then
        --     local slotVo=workShopSlotVoApi:getProductSolt()
        --     if self.produceTipSp==nil then
        --         self.produceTipSp=CCSprite:createWithSpriteFrameName("productItemBg.png")
        --         self.buildSp:addChild(self.produceTipSp,2)
        --         self.curProduceTipTid=slotVo.itemId
        --         local pid="p"..slotVo.itemId
        --         local tcfg=propCfg[pid]
        --         self.curProduceTipSp=CCSprite:createWithSpriteFrameName(tcfg.icon)
        
        --         -- self.curProduceTipSp:setAnchorPoint(ccp(0.5,0.5))
        --         -- self.curProduceTipSp:setScale(0.6)
        --         -- self.curProduceTipSp:setPosition(ccp(self.produceTipSp:getContentSize().width/2,self.produceTipSp:getContentSize().height/2+5))
        --         self.produceTipSp:addChild(self.curProduceTipSp)
        --         local tagPointSub=buildingCfg[self:getType()].tagPos
        --         self.produceTipSp:setPosition(ccp(self.buildSp:getContentSize().width/2+tagPointSub.x,self.buildSp:getContentSize().height+20))
        --     end
        --     if self.curProduceTipTid~=slotVo.itemId then
        --         self.curProduceTipTid=slotVo.itemId
        --         if self.curProduceTipSp~=nil then
        --             self.curProduceTipSp:removeFromParentAndCleanup(true)
        --             local pid="p"..slotVo.itemId
        --             local tcfg=propCfg[pid]
        --             self.curProduceTipSp=CCSprite:createWithSpriteFrameName(tcfg.icon)
        --             -- self.curProduceTipSp:setAnchorPoint(ccp(0.5,0.5))
        --             -- self.curProduceTipSp:setScale(0.4)
        --             -- self.curProduceTipSp:setPosition(ccp(self.produceTipSp:getContentSize().width/2,self.produceTipSp:getContentSize().height/2+5))
        --             self.produceTipSp:addChild(self.curProduceTipSp)
        --         end
        --     end
        -- else
        --     if self.produceTipSp~=nil then
        --         self.produceTipSp:removeFromParentAndCleanup(true)
        --         self.produceTipSp=nil
        --     end
        -- end
    elseif self:getType() == 12 then --军事学院，可以抽取英雄显示图标
        -- if base.heroSwitch==1 and heroVoApi and heroVoApi.isHasFreeLottery and heroVoApi.getHeroInfo then
        --     local heroInfo=heroVoApi:getHeroInfo()
        --     if heroInfo and SizeOfTable(heroInfo)>0 then
        --         heroVoApi:getHeroInfo()
        --         self:setSpecialIconVisible(3,heroVoApi:isHasFreeLottery(),12)
        --     end
        -- end
    elseif self:getType() == 101 then --精炼系统（配件工厂）
        -- if accessoryVoApi and accessoryVoApi:succinctIsOpen() and accessoryVoApi:checkFree() then
        --   self:setSpecialIconVisible(2,accessoryVoApi:checkFree(),101,false)
        
        -- elseif base.ifAccessoryOpen==1 and accessoryVoApi and accessoryVoApi:getLeftECNum()>0  then
        --   self:setSpecialIconVisible(1,accessoryVoApi:getLeftECNum()>0,101,false)
        -- else
        --   self:setSpecialIconVisible(1,false,101,false)
        --   self:setSpecialIconVisible(2,false,101,false)
        -- end
    elseif self:getType() == 102 then
        -- if(superWeaponVoApi and superWeaponVoApi:getResetCost()==0)then
        --     self:setSpecialIconVisible(1,true,102,false)
        -- elseif(superWeaponVoApi and superWeaponVoApi:setCurEnergy() and superWeaponVoApi:setCurEnergy()>=weaponrobCfg.energyMax)then
        --     self:setSpecialIconVisible(2,true,102,false)
        -- else
        --     self:setSpecialIconVisible(1,false,102,false)
        --     self:setSpecialIconVisible(2,false,102,false)
        -- end
    elseif self:getType() == 103 then--天梯榜建筑
        if ladderVoApi and ladderVoApi:getChampionName() ~= "" then
            self:setSpecialIconVisible(1, true, 103, false)
        else
            self:setSpecialIconVisible(1, false, 103, false)
        end
    end
    
    --重新设置curProduceTipSp的缩放比例和坐标
    if self.curProduceTipSp and self.produceTipSp then
        self.curProduceTipSp:setAnchorPoint(ccp(0.5, 0.5))
        self.curProduceTipSp:setScaleX(60 / self.curProduceTipSp:getContentSize().width)
        self.curProduceTipSp:setScaleY(60 / self.curProduceTipSp:getContentSize().height)
        self.curProduceTipSp:setPosition(ccp(self.produceTipSp:getContentSize().width / 2, self.produceTipSp:getContentSize().height / 2 + 6))
    end
    -- 一键帮助按钮显示
    
    -- if self.helpOtherSp then
    --     self.helpOtherSp:setVisible(false)
    --     local selfAlliance=allianceVoApi:getSelfAlliance()
    --     if selfAlliance then
    --         local list=allianceHelpVoApi:getList(1)
    --         if list and SizeOfTable(list)>0 then
    --             self.helpOtherSp:setVisible(true)
    --             local num = self.helpOtherSp:numberOfRunningActions() or 0
    --             if num==0 then
    --                 self.helpOtherSp:runAction(self:getTipSpAnimy())
    --             end
    --         else
    --             local initFlag=allianceHelpVoApi:getInitFlag()
    --             if initFlag==-1 then
    --                 local function helpCallback( ... )
    --                     local list1=allianceHelpVoApi:getList(1)
    --                     if list1 and SizeOfTable(list1)>0 then
    --                         self.helpOtherSp:setVisible(true)
    --                         local num = self.helpOtherSp:numberOfRunningActions() or 0
    --                         if num==0 then
    --                             self.helpOtherSp:runAction(self:getTipSpAnimy())
    --                         end
    --                     end
    --                 end
    --                 allianceHelpVoApi:formatData(1,helpCallback)
    --                 allianceHelpVoApi:setInitFlag(1)
    --             end
    --         end
    --     end
    -- end
    
    --新版建筑图标显示
    if self.buildSp and self.parent and self.parent.sceneSp then
        local tip = buildingCueMgr:getBuildingTip(self:getType(), self.bid)
        if tip then
            if self.buildingTipSp then
                self.buildingTipSp = tolua.cast(self.buildingTipSp, "LuaCCSprite")
                -- print("self.gettype,tip.pic,tip.type,tip.tag,self.buildingTipSp",self:getType(),tip.pic,tip.type,tip.tag,self.buildingTipSp)
                local lastTag = self.buildingTipSp:getTag()
                local tag = tip.tag or 0
                if tag ~= lastTag then
                    self:removeBuildingTipSp()
                end
            end
            
            local tagPointSub = buildingCfg[self:getType()].tagPos
            
            if self.buildingTipSp == nil then
                self.buildingTipSp = self:createBuildingTipSp(tip)
                self.buildingTipSp:setScale((1 / self.buildSp:getScale()) * (0.75 / self.parent.sceneSp:getScale()))
                self.buildingTipSp:setAnchorPoint(ccp(0.5, 0))
                local tipPosX, tipPosY = self.buildSp:getContentSize().width / 2 + tagPointSub.x + self.tipX, self.buildSp:getContentSize().height / 2 + tagPointSub.y + self.tipY
                self.buildSp:addChild(self.buildingTipSp, 2)
                tipPosY = tipPosY + 20
                if self:getType() == 1 or self:getType() == 2 or self:getType() == 3 or self:getType() == 4 then --四种资源建筑
                    local offsetXCfg = {10, 0, 10, 0}
                    tipPosX = self.buildSp:getContentSize().width / 2 + (offsetXCfg[self:getType()] or 0)
                    tipPosY = tipPosY + 20
                elseif self:getType() == 15 then --军团
                    tipPosY = tipPosY + 50
                elseif self:getType() == 104 then --军徽
                    tipPosY = tipPosY + 30
                elseif self:getType() == 105 then --装甲矩阵
                    tipPosY = tipPosY + 10
                elseif self:getType() == 107 then --战争塑像
                    tipPosX = tipPosX - 4
                    tipPosY = tipPosY + 20
                elseif self:getType() == 108 then --AI部队
                    tipPosX = tipPosX - 20
                    tipPosY = tipPosY + 20
                end
                self.buildingTipSp:setPosition(tipPosX, tipPosY)
            end
            if self:getType() == 16 then --作战中心
                self.arenaTipFlag = true
                if self.specialIcon then
                    self.specialIcon:setVisible(false)
                end
            end
            
            if tip.type and tip.type == "gift" and self.allianceGiftPerBar then--军团礼包
                if allianceGiftVoApi and allianceGiftVoApi.getCurGiftNumsPer then
                    self.allianceGiftPerBar:setPercentage(allianceGiftVoApi:getCurGiftNumsPer())
                end
            end
        else
            self:removeBuildingTipSp()
            if self.arenaTipFlag == true and self:getType() == 16 then
                if self.arenaTipType > 0 then
                    self:setSpecialIconVisible(self.arenaTipType, true, self:getType()) --显示原先的图标
                    self.arenaTipFlag = false
                end
            end
        end
    end
    if self.lvTip and G_isApplyVersion() == true then --提审服对某些建筑的等级图标隐藏
        local blevel = self:getLevel()
        if buildingVoApi:isBuildShowLvByType(self:getType()) == false or blevel <= 0 then
            self.lvTip:setVisible(false)
        end
    end
end

function baseBuilding:createBuildingTipSp(tip)
    -- print("tip.pic,tip.tag,tip.type,self:getType(),self.bid------->",tip.pic,tip.tag,tip.type,self:getType(),self.bid)
    local tipSp
    local function tipHandler()
        if tip.handler then
            local function callback()
                if tip.doFlag and tip.doFlag == true then --如果是可以直接操作的，操作完后直接移除掉图标
                    -- print("self:getType(),self.bid,tip.pic,tip.type-------->",self:getType(),self.bid,tip.pic,tip.type)
                    self:removeBuildingTipSp()
                end
            end
            tip.handler(callback)
        end
    end
    if tip.doFlag and tip.doFlag == true then --可以直接点击图标处理逻辑的
        tipSp = LuaCCSprite:createWithSpriteFrameName(tip.pic, tipHandler)
    else--newAlliance_gift.png
        tipSp = LuaCCSprite:createWithSpriteFrameName("productItemBg.png", tipHandler)
        local iconSp = CCSprite:createWithSpriteFrameName(tip.pic)
        if iconSp then
            iconSp:setScale(60 / iconSp:getContentSize().width)
            iconSp:setPosition(tipSp:getContentSize().width / 2, tipSp:getContentSize().height / 2 + 6)
            tipSp:addChild(iconSp, 2)
            if tip.bgname then
                local tipBg = CCSprite:createWithSpriteFrameName(tip.bgname)
                tipBg:setScale(60 / iconSp:getContentSize().width)
                tipBg:setPosition(iconSp:getPosition())
                tipSp:addChild(tipBg)
            end
        end
        if tip.type and tip.type == "gift" and tipSp then -- 礼包tip上要加上进度条
            if allianceGiftVoApi and allianceGiftVoApi.getCurGiftNumsPer then
                if self.allianceGiftPerBar then
                    self.allianceGiftPerBar = nil
                end
                local curPerNum = allianceGiftVoApi:getCurGiftNumsPer()
                AddProgramTimer(tipSp, ccp(tipSp:getContentSize().width * 0.5, 25), 110, nil, nil, "VipIconYellowBarBg.png", "VipIconYellowBar.png", 111)
                giftBar = tolua.cast(tipSp:getChildByTag(110), "CCProgressTimer")
                giftBarBg = tolua.cast(tipSp:getChildByTag(111), "CCSprite")
                giftBarBg:setRotation(180)
                giftBar:setRotation(180)
                giftBar:setScaleX(55 / giftBar:getContentSize().width)
                giftBarBg:setScaleX(55 / giftBarBg:getContentSize().width)
                giftBar:setScaleY(14 / giftBar:getContentSize().height)
                giftBarBg:setScaleY(14 / giftBarBg:getContentSize().height)
                giftBar:setMidpoint(ccp(1, 0))
                giftBar:setPercentage(curPerNum or 100)
                self.allianceGiftPerBar = giftBar
            end
        end
    end
    if tipSp then
        local tag = tip.tag or 0
        tipSp:setTag(tag)
        if tip.doFlag and tip.doFlag == true then
            tipSp:runAction(self:getTipSpAnimy())
        end
    end
    return tipSp
end

function baseBuilding:removeBuildingTipSp()
    if self.allianceGiftPerBar then
        self.allianceGiftPerBar = nil
    end
    if self.buildingTipSp then
        self.buildingTipSp:removeFromParentAndCleanup(true)
        self.buildingTipSp = nil
    end
end

--设置特殊图标的显示与否
--param type: 如果建筑id是12(军事学院)的话无用, 如果建筑id是16(作战中心)的话表示要显示那个图标
--1是个人跨服战, 2是工会跨服战, 3是世界争霸, 4是区域战, 5是跨平台战, 6是群雄争霸, 7是异元战场 8是领土争夺战
--param visible: 显示与否  flag:配件工厂的显示标志
function baseBuilding:setSpecialIconVisible(type, isVisible, bType, flag)
    if bType == 12 then
        if(self.specialIcon)then
            self.specialIcon:setVisible(isVisible)
            local openlevel = base.heroOpenLv or 20
            if playerVoApi:getPlayerLevel() < openlevel then
                self.specialIcon:setVisible(false)
            end
        end
    elseif bType == 101 or bType == 102 then
        if(self.specialIcon)then
            self.specialIcon:setVisible(isVisible)
            local child1
            local child2
            child1 = tolua.cast(self.specialIcon:getChildByTag(1), "CCSprite")
            child2 = tolua.cast(self.specialIcon:getChildByTag(2), "CCSprite")
            
            if type == 1 then
                if child1 then
                    child1:setVisible(isVisible)
                end
                if child2 then
                    child2:setVisible(flag)
                end
            else
                if child1 then
                    child1:setVisible(flag)
                end
                if child2 then
                    child2:setVisible(isVisible)
                end
            end
        end
    elseif bType == 103 then
        if(self.specialIcon)then
            self.specialIcon:setVisible(isVisible)
        end
    else
        if(self.specialIcon)then
            if(isVisible)then
                local tmpIcon
                if self:getType() == 16 then
                    buildingVoApi.arenaTipTypeTb[type] = true
                    self.arenaTipType = type
                    tmpIcon = tolua.cast(self.specialIcon:getChildByTag(self.arenaTipType), "CCSprite")
                    if self.arenaTipType ~= self.lastArenaTipType then
                        self.lastArenaTipType = self.arenaTipType
                        if tmpIcon then
                            tmpIcon:removeFromParentAndCleanup(true)
                            tmpIcon = nil
                        end
                    end
                    -- print("self.arenaTipType------->>",self.arenaTipType)
                end
                if tmpIcon == nil then
                    if(type == 1)then
                        tmpIcon = CCSprite:createWithSpriteFrameName("serverWarPIcon.png")
                    elseif(type == 2)then
                        tmpIcon = CCSprite:createWithSpriteFrameName("serverWarTIcon.png")
                    elseif(type == 3)then
                        tmpIcon = CCSprite:createWithSpriteFrameName("ww_icon.png")
                        if(tmpIcon == nil)then
                            CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("worldWar/worldWarCommon.plist")
                            tmpIcon = CCSprite:createWithSpriteFrameName("ww_icon.png")
                        end
                    elseif(type == 4)then
                        tmpIcon = CCSprite:createWithSpriteFrameName("RegionalStationsIcon.png")
                        if(tmpIcon == nil)then
                            CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/localWar/localWar.plist")
                            tmpIcon = CCSprite:createWithSpriteFrameName("RegionalStationsIcon.png")
                        end
                    elseif(type == 5)then
                        tmpIcon = CCSprite:createWithSpriteFrameName("platWarIcon.png")
                        if(tmpIcon == nil)then
                            CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/platWar/platWarImage.plist")
                            tmpIcon = CCSprite:createWithSpriteFrameName("platWarIcon.png")
                        end
                    elseif(type == 6)then
                        tmpIcon = CCSprite:createWithSpriteFrameName("serverWarLocalIcon.png")
                        if(tmpIcon == nil)then
                            spriteController:addPlist("public/serverWarLocal/serverWarLocalCommon.plist")
                            tmpIcon = CCSprite:createWithSpriteFrameName("serverWarLocalIcon.png")
                        end
                    elseif(type == 7)then
                        tmpIcon = CCSprite:createWithSpriteFrameName("dimensionalWarIcon.png")
                    elseif(type == 8)then
                        tmpIcon = CCSprite:createWithSpriteFrameName("ltzdzIcon.png")
                    end
                    if(tmpIcon)then
                        tmpIcon:setTag(type)
                        tmpIcon:setPosition(ccp(self.specialIcon:getContentSize().width / 2, self.specialIcon:getContentSize().height / 2 + 6))
                        tmpIcon:setScaleX(60 / tmpIcon:getContentSize().width)
                        tmpIcon:setScaleY(60 / tmpIcon:getContentSize().height)
                        -- tmpIcon:setScale(60/tmpIcon:getContentSize().width)
                        self.specialIcon:addChild(tmpIcon)
                        self.specialIcon:setVisible(true)
                    end
                else
                    tmpIcon:setVisible(true)
                    self.specialIcon:setVisible(true)
                end
            else
                if self:getType() == 16 then
                    buildingVoApi.arenaTipTypeTb[type] = false
                end
                self.specialIcon:setVisible(false)
            end
        end
    end
end

function baseBuilding:getTipSpAnimy()
    local time = 0.07
    local rotate1 = CCRotateTo:create(time, 30)
    local rotate2 = CCRotateTo:create(time, -30)
    local rotate3 = CCRotateTo:create(time, 20)
    local rotate4 = CCRotateTo:create(time, -20)
    local rotate5 = CCRotateTo:create(time, 0)
    
    local delay = CCDelayTime:create(1)
    local acArr = CCArray:create()
    acArr:addObject(rotate1)
    acArr:addObject(rotate2)
    acArr:addObject(rotate3)
    acArr:addObject(rotate4)
    acArr:addObject(rotate5)
    acArr:addObject(delay)
    local seq = CCSequence:create(acArr)
    local repeatForever = CCRepeatForever:create(seq)
    return repeatForever
end

--播放点击建筑的效果
function baseBuilding:playBuildReactionEffect()
    if self.buildSp == nil or tolua.cast(self.buildSp, "LuaCCSprite") == nil then
        do return end
    end
    if self.bAnimSpTb and type(self.bAnimSpTb) == "table" then
        for k, v in pairs(self.bAnimSpTb) do
            local fadeOut3 = CCTintTo:create(0.3, 80, 80, 80)
            local fadeIn3 = CCTintTo:create(0.3, self.rgbv, self.rgbv, self.rgbv)
            local seq3 = CCSequence:createWithTwoActions(fadeOut3, fadeIn3)
            v:runAction(seq3)
        end
    end
    if self.buildAnimSp ~= nil then
        local fadeOut3 = CCTintTo:create(0.3, 80, 80, 80)
        local fadeIn3 = CCTintTo:create(0.3, self.rgbv, self.rgbv, self.rgbv)
        local seq3 = CCSequence:createWithTwoActions(fadeOut3, fadeIn3)
        self.buildAnimSp:runAction(seq3)
    end
end
--播放点击建筑的效果
function baseBuilding:playBuildReactionEffect()
    if self.buildSp == nil or tolua.cast(self.buildSp, "LuaCCSprite") == nil then
        do return end
    end
    if self.bAnimSpTb and type(self.bAnimSpTb) == "table" then
        for k, v in pairs(self.bAnimSpTb) do
            local fadeOut3 = CCTintTo:create(0.3, 80, 80, 80)
            local fadeIn3 = CCTintTo:create(0.3, self.rgbv, self.rgbv, self.rgbv)
            local seq3 = CCSequence:createWithTwoActions(fadeOut3, fadeIn3)
            v:runAction(seq3)
        end
    end
    if self.buildAnimSp ~= nil then
        local fadeOut3 = CCTintTo:create(0.3, 80, 80, 80)
        local fadeIn3 = CCTintTo:create(0.3, self.rgbv, self.rgbv, self.rgbv)
        local seq3 = CCSequence:createWithTwoActions(fadeOut3, fadeIn3)
        self.buildAnimSp:runAction(seq3)
    end
end

function baseBuilding:dispose()
    if self.refreshListener then
        eventDispatcher:removeEventListener("baseBuilding.build.refresh", self.refreshListener)
        self.refreshListener = nil
    end
    self.oldTipNum = nil
    self.bAnimSpTb = nil
    self.rgbv = nil
    self.needChange = nil
    self.ccprogress = nil
    self.lvTip = nil
    self.lvLb = nil
    self.parent = nil
    self.isArea = nil
    self.produceTipSp = nil
    self.curProduceTipTid = nil
    self.curProduceTipSp = nil
    self.buildAnimSp = nil
    self.buildableIcon = nil
    self.specialIcon = nil
    self.cueSp = nil
    self.cueId = nil
    self.floorSp = nil
    self.movTipSp = nil
    self.movTipSpChose = nil
    self.buildingTipSp = nil
    self.arenaTipFlag = false
    self.arenaTipType = 0
    self.lastArenaTipType = 0
    self.bAnimSpTb = nil
    self.airShipSp = nil
    self = nil
end

