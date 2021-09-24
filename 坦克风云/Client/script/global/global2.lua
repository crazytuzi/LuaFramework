G_GoldFontSrc2 = "public/number_gold2.fnt"--橘黄色
--添加红点数量提示
G_isOpenWinterSkin = false ---冬季皮肤的前台开关
G_battleSpeed = 1 --战斗加速(只用于战斗加速！！！！)
G_curSnowTime = {} --当前下雪的开启时间 {周几，几点，几分}
G_specTankId = {[10163] = 1, [10164] = 1, [10165] = 1, }--用于abilityCfg value1 value2 特殊坦克数值的处理
G_specRocketId = {[10163] = 1, [10164] = 1, [10165] = 1, [10082] = 1, [10083] = 1, [10084] = 1, }
G_acHxghAutoFlag = false --航线规划活动自动规划的标识
G_minMapx = 1 --世界地图最小x坐标
G_maxMapx = 600 --世界地图最大x坐标
G_minMapy = 1 --世界地图最小y坐标
G_maxMapy = 600 --世界地图最大y坐标
G_iphone4 = 1 --iphone4分辨率
G_iphone5 = 2 --iphone5分辨率
G_iphoneX = 3 --iphoneX分辨率
G_ColorGreen3 = ccc3(20, 250, 250)
G_ColorHighGreen = ccc3(0, 255, 150)

G_LowfiColorGreen = ccc3(22, 223, 115) --低保和绿
G_LowfiColorRed = ccc3(240, 90, 90) --低保和红
G_LowfiColorRed2 = ccc3(255, 70, 70) --低保和红2
G_HighSATColorGreen = ccc3(0, 255, 50) --高饱和绿
G_ColorGray2 = ccc3(182, 182, 182)
G_ColorYellowPro3 = ccc3(244, 210, 25)
G_ColorHealthYellow = ccc3(199, 184, 140) --防沉迷的黄色
G_ColorHealthGray = ccc3(145, 145, 145) --防沉迷的灰色
G_vrgoldnumber = "public/vr_goldnumber.fnt"
G_vrorangenumber = "public/vr_orangenumber.fnt"

AuditOp = {
    LOGINUI = 100, --进入登录页面
    MAINUI = 101, --进入游戏主界面
    RECHARGEUI = 102, --进入充值页面
    RECHARGE = 103, --点击充值
    RECHARGE_SUCCESS = 104, --充值成功
    RECHARGE_FAIL = 105, --充值失败
    UMLAND = 106, --进入郊区
}

--战报中资源排序
G_reportResSort = {
    {r1 = 1, r2 = 2, r3 = 3, r4 = 4, gold = 5},
    -- { r1=1, r2=2, r3=3, r4=4, r5=5, r6=6, gem=7, gems=7 },
    {r1 = 1, r2 = 2, r3 = 3, gem = 4, gems = 4},
}

--初始化一下部分全局变量
function G_initGlobalVar()
    if base.smmap == 1 then --缩小地图范围
        G_maxMapx, G_maxMapy = 300, 300
    else
        G_maxMapx, G_maxMapy = 600, 600
    end
end

function G_addNumTip(parent, pos, visible, num, scale)
    if parent == nil then
        return
    end
    local size = 25
    local width = 36
    local height = 36
    local num = num or 0
    local isVisible = visible or false
    local scale = scale or 1
    local numLb = GetTTFLabel(num, size)
    numLb:setTag(11)
    local rect = CCRect(17, 17, 1, 1)
    local function touchClick()
    end
    local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png", rect, touchClick)
    if numLb:getContentSize().width + 10 > width then
        width = numLb:getContentSize().width + 10
    end
    numBg:setContentSize(CCSizeMake(width, height))
    numBg:ignoreAnchorPointForPosition(false)
    numBg:setAnchorPoint(CCPointMake(1, 0.5))
    numBg:setPosition(pos)
    numBg:addChild(numLb, 1)
    numBg:setTag(10)
    numBg:setVisible(isVisible)
    numLb:setPosition(getCenterPoint(numBg))
    numBg:setScale(scale)
    parent:addChild(numBg)
end

--更新红点数量提示
function G_refreshNumTip(parent, visible, num)
    if parent == nil then
        return
    end
    local tipSp = parent:getChildByTag(10)
    if tipSp ~= nil then
        if tipSp:isVisible() ~= visible then
            tipSp:setVisible(visible)
        end
        if tipSp:isVisible() == true then
            local numLb = tolua.cast(tipSp:getChildByTag(11), "CCLabelTTF")
            if numLb ~= nil then
                if num and numLb:getString() ~= tostring(num) then
                    numLb:setString(num)
                    local width = 36
                    if numLb:getContentSize().width + 10 > width then
                        width = numLb:getContentSize().width + 10
                    end
                    tipSp:setContentSize(CCSizeMake(width, 36))
                    numLb:setPosition(getCenterPoint(tipSp))
                end
            end
        end
    end
end

--移除红点数量提示
function G_removeNumTip(parent)
    if parent then
        local tipSp = parent:getChildByTag(10)
        if tipSp then
            tipSp:removeFromParentAndCleanup(true)
            tipSp = nil
        end
    end
end

-- closeFlag 是否关闭现在所有的板子 --index 第几个页签
function G_goToDialog2(type, layerNum, closeFlag, index, subIdx, subType)
    if closeFlag then
        activityAndNoteDialog:closeAllDialog()
    end
    if type == "up" then
        require "luascript/script/game/scene/gamedialog/portbuilding/workshopDialog"
        local bid, typpe, level = 6, 9, 1
        if buildingVoApi:getBuildiingVoByBId(bid).status < 1 then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("port_scene_building_tip_5"), nil, 3)
            do return end
        end
        
        local bName = getlocal(buildingCfg[typpe].buildName)
        local td = workshopDialog:new(bid)
        local tbArr
        if level == 0 then
            tbArr = {getlocal("buildingTab"), getlocal("startProduceProp"), getlocal("chuanwu_scene_process")}
        else
            tbArr = {getlocal("startProduceProp"), getlocal("chuanwu_scene_process")}
        end
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, bName, true, 3)
        sceneGame:addChild(dialog, 3)
        if td.tabClick and index then
            td:tabClick(index)
        end
    elseif type == "bn" then
        local td = shopVoApi:showPropDialog(layerNum)
        td:tabClick(1, false)
    elseif type == "ut" then
        local buildingVo = buildingVoApi:getBuildiingVoByBId(13)
        if buildingVoApi:getBuildiingVoByBId(13).status < 1 then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("port_scene_building_tip_12"), nil, 3)
            do return end
        end
        require "luascript/script/game/scene/gamedialog/portbuilding/tankTuningDialog"
        local td, bName = tankTuningDialog:new(13), getlocal(buildingCfg[14].buildName)
        local tbArr = {getlocal("buildingTab"), getlocal("smelt"), getlocal("smelt_progress")}
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, bName.."("..G_LV()..buildingVo.level..")", true, 3)
        sceneGame:addChild(dialog, 3)
        if td.tabClick and index then
            td:tabClick(index)
        end
    elseif type == "tp" then
        local openLimit = (planeCfg and planeCfg.openLevel) and planeCfg.openLevel[1] or 50
        if base.plane == 0 then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("backstage17000"), nil, 3)--planeBuildOpenFactor
            do return end
        end
        if planeVoApi then
            planeVoApi:showMainDialog(layerNum)
        end
    elseif type == "alliance" then
        if base.isAllianceSwitch == 0 then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("alliance_willOpen"), nil, 5)
            do
                return
            end
        end
        local flag = allianceVoApi:isHasAlliance()
        if flag == true then
            if layerNum == nil then
                layerNum = 3
            end
            allianceVoApi:showAllianceDialog(layerNum)
            allianceVoApi:showAllianceMemeberDialog(layerNum + 1, 0, 2)
        end
    elseif type == "alliance_technology" then
        if base.isAllianceSwitch == 0 then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("alliance_willOpen"), nil, 5)
            do
                return
            end
        end
        local flag = allianceVoApi:isHasAlliance()
        if flag == true then
            if layerNum == nil then
                layerNum = 3
            end
            allianceVoApi:showAllianceDialog(layerNum, type, 1)
        end
    elseif type == "allianceActive" then
        local td = allianceActiveDialog:new()
        local title = getlocal("alliance_activie")
        local tbArr = {getlocal("world_scene_info"), getlocal("alliance_activie_reward")}
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, title, true, layerNum)
        sceneGame:addChild(dialog, layerNum)
        if td.tabClick and index then
            td:tabClick(index)
        end
    elseif type == "fb" then
        if base.emblemSwitch ~= 1 then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("backstage17000"), nil, 3)
            do return end
        end
        local permitLevel = emblemVoApi:getPermitLevel()
        if permitLevel and playerVoApi:getPlayerLevel() < permitLevel then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("emblem_building_not_permit", {permitLevel}), nil, 3)
            do return end
        end
        emblemVoApi:showMainDialog(4)
        
        if(otherGuideMgr.isGuiding and otherGuideMgr.curStep == 17)then
            otherGuideMgr:toNextStep()
        end
        emblemVoApi:showGetDialog(5)
    elseif type == "armor" then
        if armorMatrixVoApi:canOpenArmorMatrixDialog(true) then
            local function showCallback()
                armorMatrixVoApi:showArmorMatrixDialog(layerNum)
                if subType == "recruit" then
                    armorMatrixVoApi:showRecruitDialog(layerNum + 1)
                end
            end
            armorMatrixVoApi:armorGetData(showCallback)
            return
        end
    elseif type == "dressUp" then--指挥中心 装扮
        if base.isSkin == 1 and playerVoApi:getPlayerLevel() >= buildDecorateVoApi:getLevelLimit() then
            if buildDecorateVoApi.getLevelLimit and playerVoApi:getPlayerLevel() >= buildDecorateVoApi:getLevelLimit() then
                buildDecorateVoApi:showDialog(layerNum + 2, 3)
            else
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("decorateNotLevel", {buildDecorateVoApi:getLevelLimit()}), 30)
            end
        end
    elseif type == "rankDialog" then
        rankVoApi:clear()
        require "luascript/script/game/scene/gamedialog/rankDialog"
        local td = rankDialog:new()
        local tbArr = {getlocal("RankScene_power"), getlocal("RankScene_star"), getlocal("military_rank_battlePoint")}
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("rank"), false, layerNum)
        sceneGame:addChild(dialog, layerNum)
    elseif type == "superWeapon" then
        local function addCallback()
            superWeaponVoApi:showSuperWeaponDialog(layerNum + 1)
        end
        superWeaponVoApi:showMainDialog(layerNum, nil, addCallback)
    elseif type == "crystal" then
        local function addCallback()
            superWeaponVoApi:showEnergyCrystalDialog(layerNum + 1)
            if(otherGuideMgr.isGuiding and otherGuideMgr.curStep == 12)then
                otherGuideMgr:toNextStep()
            end
        end
        superWeaponVoApi:showMainDialog(layerNum, nil, addCallback)
    elseif type == "alien" then
        require "luascript/script/game/scene/gamedialog/alienTechDialog/alienTechDialog"
        local td = alienTechDialog:new()
        local tbArr = {getlocal("alien_tech_sub_title1"), getlocal("alien_tech_sub_title2"), getlocal("alien_tech_sub_title3")}
        local vd = td:init("panelBg.png", true, CCSizeMake(768, 800), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("alien_tech_title"), true, layerNum)
        sceneGame:addChild(vd, layerNum)
    elseif type == "heroM" then
        if base.heroSwitch == 0 then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("heroSwitch_false"), 30)
            do return end
        end
        
        if base.he == 0 then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("he_false"), 30)
            do return end
        end
        if closeFlag then
            activityAndNoteDialog:closeAllDialog()
        end
        
        local function openHeroMDialog()
            require "luascript/script/game/scene/gamedialog/heroDialog/heroTotalDialog"
            local td = heroTotalDialog:new()
            local tbArr = {}
            local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("sample_build_name_12"), true, 3)
            sceneGame:addChild(dialog, 3)
            
            require "luascript/script/game/scene/gamedialog/heroDialog/heroManagerDialog"
            local td = heroManagerDialog:new()
            local tbArr = {}
            local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("heroManage"), true, layerNum)
            sceneGame:addChild(dialog, layerNum)
        end
        
        local heroEquipOpenLv = base.heroEquipOpenLv or 30
        if base.he == 1 and playerVoApi:getPlayerLevel() >= heroEquipOpenLv then
            if heroEquipVoApi and heroEquipVoApi.ifNeedSendRequest == true then
                local function callbackHandler4()
                    openHeroMDialog()
                end
                heroEquipVoApi:equipGet(callbackHandler4)
            else
                openHeroMDialog()
            end
        else
            openHeroMDialog()
        end
    elseif type == "ltzdz" or type == "mr" then
        local flag = ltzdzVoApi:isOpen()
        if flag then
            local level = ltzdzVoApi:getOpenLv()
            local pLevel = playerVoApi:getPlayerLevel()
            if pLevel >= level then
                require "luascript/script/game/scene/gamedialog/arenaDialog/arenaTotalDialog"
                local td = arenaTotalDialog:new()
                local tbArr = {}
                local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("arena_total"), true, 3)
                sceneGame:addChild(dialog, layerNum)
                if ltzdzVoApi:checkIsActive() == true then
                    ltzdzVoApi:showTotalDialog(layerNum + 1)
                end
            else
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("elite_challenge_unlock_level", {level}), 30)
                do return end
            end
        else
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("ltzdz_no_open"), 30)
            do return end
        end
    elseif type == "aiTroop" or type =="aitroops" then
        AITroopsVoApi:showAITroopsDialog(layerNum)
    elseif type == "emblemTroop" then
        if emblemTroopVoApi:checkIfEmblemTroopIsOpen() == true then
            require "luascript/script/game/scene/gamedialog/emblem/emblemFunctionListDialog"
            local td = emblemFunctionListDialog:new()
            local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), {}, nil, nil, getlocal("emblem_title"), true, 3)
            sceneGame:addChild(dialog, 3)
            
            if td and td.functionTb and index then
                td.functionTb[index].callBack()
            end
        end
    elseif type == "jb" then
        local td = allShopVoApi:showAllPropDialog(3, "gems")
    elseif type == "junyan" then
        if base.ifMilitaryOpen == 0 then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("arena_noOpen"), 30)
            do
                return
            end
        end
        local limitLv = 10
        if playerVoApi:getPlayerLevel() < limitLv then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("arena_limit", {limitLv}), 30)
            do
                return
            end
        end
        
        if closeFlag then
            activityAndNoteDialog:closeAllDialog()
        end
        
        require "luascript/script/game/scene/gamedialog/arenaDialog/arenaTotalDialog"
        local td = arenaTotalDialog:new()
        local tbArr = {}
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("arena_total"), true, 3)
        sceneGame:addChild(dialog, 3)
        
        G_openArenaDialog(layerNum)
    elseif type == "allianceCity" then
        allianceCityVoApi:showAllianceCityDialog(layerNum + 1)
    elseif type == "hero" then
        if base.heroSwitch == 0 then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("heroSwitch_false"), 30)
            do return end
        end
        if subType and subType == "heroinfo" then
            local hid = subIdx
            local heroVo = heroVoApi:getHeroByHid(hid)
            if heroVo == nil then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("backstage11002"), 30)
                do return end
            end
            require "luascript/script/game/scene/gamedialog/heroDialog/heroInfoDialog"
            local td = heroInfoDialog:new(heroVo, nil, layerNum)
            
            local tbArr = {}
            local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("heroManage"), true, layerNum)
            sceneGame:addChild(dialog, layerNum)
        end
    elseif type == "personAvt" then --成就系统
        local openFlag, openLv = achievementVoApi:isOpen()
        if openFlag ~= 1 then
            if openFlag == 0 then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("achievement_noopen"), 28)
            elseif openFlag == 2 then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("achievement_openlevel", {openLv}), 28)
            end
            do return end
        end
        local avtId = index --成就线id
        local cfg = achievementVoApi:getAchievementCfg()
        if cfg.person[avtId] == nil then
            do return end
        end
        local moduleId = cfg.person[avtId].type
        local unlockFlag, openLv = achievementVoApi:getAvtModuleUnlockFlag(moduleId)
        if unlockFlag ~= 1 then --成就模块未解锁的话给出不跳转的原因
            local stateStr = ""
            if unlockFlag == 0 then
                stateStr = getlocal("achievement_willOpen")
            elseif unlockFlag == 2 then
                stateStr = getlocal("alliance_unlock_str2", {openLv})
            elseif unlockFlag == 3 then
                stateStr = getlocal("achievement_unlock_effectstr2", {openLv})
            end
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), stateStr, 28)
            do return end
        end
        achievementVoApi:showAvtDetailDialog(1, avtId, layerNum, nil, subIdx)
    elseif type == "heroAdjutant" then --将领副官
        if base.heroSwitch == 0 then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("heroSwitch_false"), 30)
            do return end
        end
        if heroAdjutantVoApi:isOpen() then
            if closeFlag then
                activityAndNoteDialog:closeAllDialog()
            end
            local function openHeroTotalDialog(...)
                require "luascript/script/game/scene/gamedialog/heroDialog/heroTotalDialog"
                local td = heroTotalDialog:new()
                local tbArr = {}
                local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("sample_build_name_12"), true, 3)
                sceneGame:addChild(dialog, layerNum)
                
                local heroList = heroVoApi:getHeroList()
                local heroCount = SizeOfTable(heroList)
                if heroCount <= 0 then
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("heroAdjutant_notHeroTips"), 30)
                    do return end
                end
                require "luascript/script/game/scene/gamedialog/heroDialog/heroAdjutantDialog"
                local td = heroAdjutantDialog:new(layerNum + 1)
                local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), {}, nil, nil, getlocal("heroAdjutant_title"), true, layerNum + 1)
                sceneGame:addChild(dialog, layerNum + 1)
            end
            if base.he == 1 then
                local equipLv = base.heroEquipOpenLv or 30
                if playerVoApi:getPlayerLevel() >= equipLv and heroEquipVoApi and heroEquipVoApi.ifNeedSendRequest == true and heroEquipChallengeVoApi then
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
        else
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("backstage36001"), 30)
            do return end
        end
    elseif type == "supply" then --补给线
        if base.ifAccessoryOpen == 0 then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("backstage6004"), 30)
            do return end
        end
        if (playerVoApi:getPlayerLevel() < accessoryCfg.accessoryUnlockLv) then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("elite_challenge_unlock_level", {accessoryCfg.accessoryUnlockLv}), 30)
            do return end
        end
        accessoryVoApi:showSupplyDialog(layerNum)
    elseif type == "vip" then --vip界面
        local function callback(fn, data)
            local ret, sData = base:checkServerData(data)
            if ret == true then
                if sData and sData.data and sData.data.vipRewardCfg then
                    vipVoApi:setVipReward(sData.data.vipRewardCfg)
                    local vf = vipVoApi:getVf(vf)
                    for k, v in pairs(vf) do
                        vipVoApi:setRealReward(v)
                    end
                    vipVoApi:setVipFlag(true)
                    vipVoApi:openVipDialog(layerNum, true)
                end
            end
        end
        if base.heroSwitch == 1 and base.vipshop == 1 then
            if vipVoApi:getVipFlag() == false then
                socketHelper:vipgiftreward(callback)
            else
                vipVoApi:openVipDialog(layerNum, true)
            end
        else
            vipVoApi:openVipDialog(layerNum)
        end
    elseif type == "zd" then --战力引导界面
        playerVoApi:showPowerGuideDialog(layerNum)
    elseif type == "cr" then --指挥中心
        G_taskJumpTo({group = 6})
    else
        G_goToDialog(type, layerNum, closeFlag, index)
    end
end

function G_goAllianceFunctionDialog(nameKey, layerNum, subIdx)
    if nameKey == nil then
        return
    end
    if layerNum == nil then
        layerNum = 3
    end
    local isOpen = false
    local flag = allianceVoApi:isHasAlliance()
    if flag == true then
        if nameKey == "alliance_duplicate" then --军团副本
            if base.isAllianceFubenSwitch == 1 then
                isOpen = true
                require "luascript/script/game/scene/gamedialog/allianceDialog/allianceFuDialog"
                local td = allianceFuDialog:new(layerNum)
                local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, nil, nil, getlocal("alliance_duplicate"), true, layerNum)
                sceneGame:addChild(dialog, layerNum)
            end
        elseif nameKey == "alliance_scene_event_title" then --军团事件
            isOpen = true
            require "luascript/script/game/scene/gamedialog/allianceDialog/allianceEventDialog"
            local td = allianceEventDialog:new(layerNum)
            local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, nil, nil, getlocal("alliance_scene_event_title"), true, layerNum)
            sceneGame:addChild(dialog, layerNum)
        elseif nameKey == "alliance_help" then --军团协助
            if base.allianceHelpSwitch == 1 then
                isOpen = true
                require "luascript/script/game/scene/gamedialog/allianceDialog/allianceHelpDialog"
                local td = allianceHelpDialog:new(layerNum)
                local tbArr = {getlocal("alliance_help_tab1"), getlocal("alliance_help_tab2"), getlocal("alliance_help_tab3")}
                local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("alliance_help"), true, layerNum)
                sceneGame:addChild(dialog, layerNum)
            end
        elseif nameKey == "alliance_rebel_detail" then --叛军详情
            if base.isRebelOpen == 1 then
                isOpen = true
                require "luascript/script/game/scene/gamedialog/allianceDialog/rebelDialog"
                local td = rebelDialog:new(layerNum)
                local tbArr = {}
                local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("alliance_rebel_info"), true, layerNum)
                sceneGame:addChild(dialog, layerNum)
            end
        elseif nameKey == "allianceShop" then --军团商店
            if base.ifAllianceShopOpen == 1 then
                isOpen = true
                require "luascript/script/game/gamemodel/alliance/allianceShopVoApi"
                allianceShopVoApi:showShopDialog(layerNum)
            end
        elseif nameKey == "alliance_technology" then --军团科技
            if base.isAllianceSkillSwitch == 1 then
                isOpen = true
                require "luascript/script/game/scene/gamedialog/allianceDialog/allianceSkillDialog"
                local td = allianceSkillDialog:new(nil, layerNum, subIdx)
                local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, nil, nil, getlocal("alliance_technology"), true, layerNum)
                sceneGame:addChild(dialog, layerNum)
            end
        elseif nameKey == "alliance_gift_title" then--军团礼包
            if base.allianceGiftSwitch == 1 then
                isOpen = true
                require "luascript/script/game/scene/gamedialog/allianceDialog/allianceGiftDialog"
                local td = allianceGiftDialog:new(layerNum)
                local tbArr = {}
                local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("alliance_gift"), true, layerNum)
                sceneGame:addChild(dialog, layerNum)
            end
        elseif nameKey == "alliance_setGarrsion" then --驻防接收
            -- if base.isGarrsionOpen==1 then
            -- isOpen=true
            -- require "luascript/script/game/scene/gamedialog/allianceDialog/setGarrisonDialog"
            -- local td=setGarrsionDialog:new(layerNum)
            -- local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0,0,400,350),CCRect(168,86,10,10),nil,nil,nil,getlocal("alliance_setGarrsion"),true,layerNum)
            -- sceneGame:addChild(dialog,layerNum)
            -- end
        end
    end
    if isOpen == false then
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("not_open"), 30)
    end
end

-- i 里的信息
function G_addMenuInfo(parent, layerNum, pos, tabStr, colorTab, scale, strSize, YCallback, newImage, newT)
    local function touchInfo()
        if G_checkClickEnable() == false then
            do
                return
            end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if YCallback then
            YCallback()
            return
        end
        if strSize == nil then
            strSize = 28
        end
        local td = smallDialog:new()
        local dialog = td:init("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, true, true, layerNum + 1, tabStr, strSize, colorTab)
        sceneGame:addChild(dialog, layerNum + 1)
    end
    local menuItem
    if newImage then
        menuItem = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", touchInfo, 11, nil, nil)
    else
        menuItem = GetButtonItem("BtnInfor.png", "BtnInfor_Down.png", "BtnInfor_Down.png", touchInfo, 11, nil, nil)
    end
    if scale then
        menuItem:setScale(scale)
    end
    local menu = CCMenu:createWithItem(menuItem)
    menu:setPosition(pos)
    local useT = newT or 4
    menu:setTouchPriority(-(layerNum - 1) * 20 - useT)
    parent:addChild(menu, 3)
    return menu, menuItem
end

-- 用RGBA8888加载
function G_addResource8888(callback)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    
    if callback then
        callback()
    end
    
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
end

-- currentNum 当前值  taskTb：任务值table
-- return 当前进度条的百分比
function G_getPercentage(currentNum, taskTb)
    local alreadyCost = currentNum
    local cost = taskTb
    local numDuan = SizeOfTable(cost)
    local per = 0
    if numDuan == 0 then
        numDuan = 5
    end
    local everyPer = 100 / numDuan
    
    local per = 0
    
    local diDuan = 0
    for i = 1, numDuan do
        if alreadyCost <= cost[i] then
            diDuan = i
            break
        end
    end
    
    if alreadyCost >= cost[numDuan] then
        per = 100
    elseif diDuan == 1 then
        per = alreadyCost / cost[1] / numDuan * 100
    else
        per = (diDuan - 1) * everyPer + (alreadyCost - cost[diDuan - 1]) / (cost[diDuan] - cost[diDuan - 1]) / numDuan * 100
    end
    return per
end

--alignType 1：左对齐，pos第一个位置；2：居中，pos中点位置；3：右对齐
--space 图间距；num 图数量
function G_getIconSequencePosx(alignType, space, pos, num)
    local posTb = {}
    for i = 1, num do
        local px
        if alignType == 1 then
            px = pos + (i - 1) * space
        elseif alignType == 2 then
            px = pos - ((num - 1) / 2) * space + (i - 1) * space
        elseif alignType == 3 then
            px = pos - (i - 1) * space
        end
        table.insert(posTb, px)
    end
    return posTb
end

function G_setchildPosX(parent, child1, child2)
    local pwidth = parent:getContentSize().width / 2
    local width1 = child1:getContentSize().width * child1:getScaleX()
    local width2 = child2:getContentSize().width * child2:getScaleX()
    child1:setPositionX(pwidth - width2 / 2)
    child2:setPositionX(pwidth + width1 / 2)
end

function G_showNumberChange(oldNum, newNum)
    if oldNum and newNum then
        for k, v in pairs(G_SmallDialogDialogTb) do
            if v and v.type == "powerchangeeffect" and v.close then
                v:close()
            end
        end
        local oldpower = tonumber(oldNum)
        local newpower = tonumber(newNum)
        local function onShowPowerChange()
            smallDialog:showPowerChangeEffect(oldpower, newpower)
        end
        local callFunc = CCCallFunc:create(onShowPowerChange)
        local delay = CCDelayTime:create(0.5)
        local acArr = CCArray:create()
        acArr:addObject(delay)
        acArr:addObject(callFunc)
        local seq = CCSequence:create(acArr)
        sceneGame:runAction(seq)
    end
end

function G_showNumberScaleByAction(acSp, delayT, scaleSize)--
    local curDelayT = delayT and delayT or 0.12
    local curSSize = scaleSize and scaleSize or 1.15
    local delaytime = CCDelayTime:create(0.1)
    local scaleTo1 = CCScaleBy:create(curDelayT, curSSize)
    local scaleTo2 = scaleTo1:reverse()
    local arr = CCArray:create()
    arr:addObject(scaleTo1)
    arr:addObject(delaytime)
    arr:addObject(scaleTo2)
    local seq = CCSequence:create(arr)
    acSp:runAction(seq)
end

--跳转到指定分享页面
function G_goToShareDialog(player, share, layerNum)
    if share then
        local stype = share.stype
        if stype == 1 then --坦克分享
            require "luascript/script/game/scene/gamedialog/tankShareSmallDialog"
            tankShareSmallDialog:showTankInfoSmallDialog(player, share, layerNum)
        elseif stype == 2 then --将领分享
            require "luascript/script/game/scene/gamedialog/heroDialog/heroShareSmallDialog"
            heroShareSmallDialog:showHeroInfoSmallDialog(player, share, layerNum)
        elseif stype == 3 then --超级武器分享
            require "luascript/script/game/scene/gamedialog/superWeaponDialog/superWeaponShareSmallDialog"
            superWeaponShareSmallDialog:showSwInfoSmallDialog(player, share, layerNum)
        elseif stype == 4 then --配件分享
            require "luascript/script/game/scene/gamedialog/accessory/accessoryShareSmallDialog"
            accessoryShareSmallDialog:showAccessorySmallDialog(player, share, layerNum)
        elseif stype == 5 then --领土争夺战信息分享
            require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzPlayerInfoSmallDialog"
            ltzdzPlayerInfoSmallDialog:showInfo(layerNum, true, true, nil, share.titleStr, share)
        elseif stype == 6 then --成就系统信息分享
            achievementVoApi:showAchievementShareDialog(share, layerNum)
        end
    end
end

G_shareTime = 0 --分享时的时间，判断是否分享过于频繁使用

function G_checkShare() --判断是否可以分享
    if G_shareTime ~= 0 and base.serverTime - G_shareTime <= 10 then --10秒内视为频繁分享
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("activity_zhanyoujijie_share_fail1"), 28)
        return false
    end
    return true
end

function G_syncShareTime() --同步分享时间
    G_shareTime = base.serverTime
end
--share：要分享的数据，message：聊天文本，tipstr分享成功的提示，callback分享成功后的回调，params预留的发送数据
function G_shareHandler(share, message, tipStr, layerNum, callback, params)
    local function shareHandler(tag, object)
        if base.shutChatSwitch == 1 then
            G_showTipsDialog(getlocal("chat_sys_notopen"))
            do return end
        end
        local channelType = tag or 1
        local sender = playerVoApi:getUid()
        local senderName = playerVoApi:getPlayerName()
        local aid = playerVoApi:getPlayerAid()
        if message == nil then
            message = ""
        end
        local chatData
        if params then
            chatData = params
        else
            base.lastSendTime = base.serverTime
            local senderName = playerVoApi:getPlayerName()
            local level = playerVoApi:getPlayerLevel()
            local language = G_getCurChoseLanguage()
            local rank = playerVoApi:getRank()
            local allianceName
            local allianceRole
            if allianceVoApi:isHasAlliance() then
                local allianceVo = allianceVoApi:getSelfAlliance()
                allianceName = allianceVo.name
                allianceRole = allianceVo.role
            end
            chatData = {brType = 16, subType = channelType, contentType = 2, level = level, rank = rank, power = playerVoApi:getPlayerPower(), uid = playerVoApi:getUid(), name = playerVoApi:getPlayerName(), pic = playerVoApi:getPic(), ts = base.serverTime, vip = playerVoApi:getVipLevel(), title = playerVoApi:getTitle(), allianceName = allianceName, allianceRole = allianceRole, language = language, message = message, report = share}
        end
        if channelType == 1 then
            chatVoApi:sendChatMessage(1, sender, senderName, 0, "", chatData)
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tipStr, 28)
        elseif aid then
            chatVoApi:sendChatMessage(aid + 1, sender, senderName, 0, "", chatData)
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tipStr, 28)
        end
        if callback then
            callback()
        end
        G_syncShareTime()
    end
    if G_checkShare() == false then --10秒内视为频繁分享
        do return end
    end
    local hasAlliance = allianceVoApi:isHasAlliance()
    if hasAlliance == false then
        shareHandler(1)
    else
        allianceSmallDialog:selectChannelDialog("PanelHeaderPopup.png", CCSizeMake(450, 350), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), true, layerNum, shareHandler, true)
    end
end

function G_setWholeSkin(isOpen)
    --[[print("in G_setWholeSkin~~~~~~~~~")
    local baseBuilding = buildings:getAllBuildingSp()
    local mapSkin = buildingSkinAddress["mapSkin"]
    -- local showSkinTipWithTime = CCUserDefault:sharedUserDefault():getIntegerForKey("showSkinTipWithTime")
    -- local isShowSkinTip = CCUserDefault:sharedUserDefault():getBoolForKey("isShowSkinTip")
    -- print("isOpen ------->",isOpen)
    -- print("showSkinTipWithTime--------->",showSkinTipWithTime)
    -- if showSkinTipWithTime == 0 then do return end end--第一次弹板
    if isOpen then
        
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("homeBuilding/buildingWinterSkin.plist")
        CCTextureCache:sharedTextureCache():addImage("homeBuilding/buildingWinterSkin.png")
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("homeBuilding/buildingWinterSkin2.plist")
        CCTextureCache:sharedTextureCache():addImage("homeBuilding/buildingWinterSkin2.png")
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        
        if baseBuilding and SizeOfTable(baseBuilding) > 0 then
            -- print("in baseBuilding------>>>>",SizeOfTable(baseBuilding))
            for k, v in pairs(baseBuilding) do
                if v.buildSp and v.buildSp:getChildByTag(1124) == nil then
                    local buildType = v:getType()
                    local winSkinStr = nil
                    local curType = homeCfg.buildingUnlock[v:getBid()].type
                    -- print("buildType------>",buildType)
                    if buildType > 0 then
                        winSkinStr = buildingSkinCfg[buildType].winterSkin
                    elseif type(curType) ~= "table" then
                        if curType ~= 4 or v:getLevel() > 0 then
                            winSkinStr = buildingSkinCfg[curType].winterSkin
                        end
                    end
                    local winterSkin = winSkinStr and CCSprite:createWithSpriteFrameName(winSkinStr) or nil
                    if winSkinStr and winterSkin then
                        winterSkin:setAnchorPoint(ccp(0.5, 0.5))
                        winterSkin:setPosition(getCenterPoint(v.buildSp))
                        winterSkin:setTag(1124)
                        v.buildSp:addChild(winterSkin, 1)
                        -- if buildType == 104 then
                        -- v.buildSp:setPosition(ccp(1240,1180))--{+10,+15} 1230,1165
                        -- end
                    end
                end
            end
        end
        if worldScene.curShowBases and SizeOfTable(worldScene.curShowBases) > 0 then
            local curShowBases = worldScene.curShowBases
            for k, v in pairs(curShowBases) do
                for kk, vv in pairs(v) do
                    local baseVo = worldBaseVoApi:getBaseVo(math.floor(kk / 1000), kk % 1000)
                    -- print("baseVo.type----->",baseVo.type)
                    if baseVo.type > 6 or baseVo.type == 0 then --叛军
                        -- print("baseVo.type------->",baseVo.type)
                    elseif vv and vv:getChildByTag(1124) == nil then
                        
                        if baseVo.type > 5 then
                            local skin = worldBaseVoApi:getBaseSkinStr(4, baseVo.level, baseVo.oid)-- 4 冬季
                            local winterSkin = CCSprite:createWithSpriteFrameName(skin)
                            if winterSkin then
                                winterSkin:setAnchorPoint(ccp(0.5, 0.5))
                                winterSkin:setPosition(getCenterPoint(vv))
                                winterSkin:setTag(1124)
                                vv:addChild(winterSkin, 1)
                            end
                        else
                            local winterSkin = CCSprite:createWithSpriteFrameName(buildingSkinCfg["common"][baseVo.type].winterSkin)
                            if winterSkin then
                                winterSkin:setAnchorPoint(ccp(0.5, 0.5))
                                winterSkin:setPosition(getCenterPoint(vv))
                                winterSkin:setTag(1124)
                                vv:addChild(winterSkin, 1)
                            end
                            
                        end
                    end
                end
            end
        end
        for i = 1, 2 do
            if mapSkin[i][3] and mapSkin[i][3]:getChildByTag(1124) == nil then
                local url_1 = i == 1 and "http://"..base.serverUserIp.."/tankheroclient/" .. "tankimg/homeMap_mi_win.jpg" or "http://"..base.serverUserIp.."/tankheroclient/" .. "tankimg/outskirtMap_mi_win.jpg"
                --{1:clayer,2:size,3:oldSp,4:oldRealSp,5:newRealSpscale,6:newSpScale}
                local function onLoadIcon_1(fn, icon)
                    local mapSkin = buildingSkinAddress["mapSkin"]
                    local picTb = mapSkin[i]
                    if picTb[1] and picTb[2] and picTb[3] and picTb[3]:getChildByTag(1124) == nil then
                        
                        icon:setContentSize(picTb[2])
                        icon:setScale(picTb[5])
                        icon:setTag(1124)
                        icon:setAnchorPoint(ccp(0, 0))
                        picTb[3]:addChild(icon)
                        if picTb[7] == nil then
                            picTb[7] = picTb[4]:getOpacity()
                        end
                        picTb[4]:setOpacity(0)
                    end
                end
                
                CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
                CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
                local webImage = LuaCCWebImage:createWithURL(url_1, onLoadIcon_1)
                CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
                CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
                if i == 2 then
                    CCUserDefault:sharedUserDefault():setIntegerForKey("isDownWinterSkin", 2)
                    CCUserDefault:sharedUserDefault():flush()
                end
            end
        end
        if mainLandScene.portSp and mainLandScene.portSp:getChildByTag(1124) == nil then
            local winterSp = CCSprite:createWithSpriteFrameName("outskirt_zhu_ji_di_win.png")
            winterSp:setAnchorPoint(ccp(0.5, 0.5))
            -- winterSp:setPosition(getCenterPoint(mainLandScene.portSp))
            winterSp:setPosition(ccp(mainLandScene.portSp:getContentSize().width * 0.5 - 2, mainLandScene.portSp:getContentSize().height * 0.5 + 2))
            winterSp:setTag(1124)
            mainLandScene.portSp:addChild(winterSp)
        end
        if buildingSkinAddress["worldMap"] == nil then
            local url_3 = "http://"..base.serverUserIp.."/tankheroclient/" .. "tankimg/world_map_mi_win.jpg"
            local function onLoadWorldMap(fn, icon)
                if buildingSkinAddress["worldMap"] == nil then
                    buildingSkinAddress["worldMap"] = icon
                end
            end
            CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
            CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
            local worldMapImage = LuaCCWebImage:createWithURL(url_3, onLoadWorldMap)
            CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
            CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        end
        if buildingSkinAddress["worldMap"] and buildingSkinAddress["worldMapNeedSHowIndexs"] and SizeOfTable(buildingSkinAddress["worldMapNeedSHowIndexs"]) > 0 then
            for k, v in pairs(buildingSkinAddress["worldMapNeedSHowIndexs"]) do
                if worldScene.clayer:getChildByTag(700 + k) then
                    tolua.cast(worldScene.clayer:getChildByTag(700 + k), "CCSprite"):removeFromParentAndCleanup(true)
                end
                if worldScene.clayer:getChildByTag(800 + k) == nil then
                    local url_3 = "http://"..base.serverUserIp.."/tankheroclient/" .. "tankimg/world_map_mi_win.jpg"
                    local function onLoadWorldMap(fn, icon)
                        icon:setTag(800 + k)
                        icon:setAnchorPoint(ccp(0, 0))
                        icon:setPosition((v[1] - 1) * worldScene.spSize.width, (v[2] - 1) * worldScene.spSize.height)
                        worldScene.clayer:addChild(icon)
                        worldScene.mapSprites[k] = icon
                    end
                    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
                    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
                    local worldMapImage = LuaCCWebImage:createWithURL(url_3, onLoadWorldMap)
                    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
                    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
                end
            end
        end
        if newGuidMgr:isNewGuiding() == false then
            local isBeginSnow = G_beginSnowTime()
            if isBeginSnow and sceneGame:getChildByTag(1124) == nil then
                
                buildingSkinAddress["isSnowing"] = true
                local particleS2 = CCParticleSystemQuad:create("public/snow2.plist")--冬天效果
                particleS2.positionType = kCCPositionTypeFree
                particleS2:setPosition(ccp(320, G_VisibleSizeHeight + 20))
                particleS2:setTag(1124)
                sceneGame:addChild(particleS2, 1)
            end
            if isBeginSnow == false and sceneGame:getChildByTag(1124) and buildingSkinAddress["isSnowing"] then
                tolua.cast(sceneGame:getChildByTag(1124), "CCParticleSystemQuad"):stopSystem()
                -- print("ccps~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",ccps)
                buildingSkinAddress["isSnowing"] = false
                if sceneGame:getChildByTag(1124) then
                    local function removeCall()
                        tolua.cast(sceneGame:getChildByTag(1124), "CCSprite"):removeFromParentAndCleanup(true)
                    end
                    local delayTime = CCDelayTime:create(10)
                    local callFunc = CCCallFuncN:create(removeCall)
                    local acArr = CCArray:create()
                    acArr:addObject(delayTime)
                    acArr:addObject(callFunc)
                    local seq = CCSequence:create(acArr)
                    tolua.cast(sceneGame:getChildByTag(1124), "CCParticleSystemQuad"):runAction(seq)
                    
                end
            end
        end
    else
        if sceneGame:getChildByTag(1124) then
            tolua.cast(sceneGame:getChildByTag(1124), "CCSprite"):removeFromParentAndCleanup(true)
        end
        if baseBuilding then
            for k, v in pairs(baseBuilding) do
                if v.buildSp and v.buildSp:getChildByTag(1124) then
                    local buildType = v:getType()
                    -- if buildType == 104 then
                    -- v.buildSp:setPosition(ccp(1285,1205))
                    -- end
                    tolua.cast(v.buildSp:getChildByTag(1124), "CCSprite"):removeFromParentAndCleanup(true)
                end
            end
        end
        if worldScene.curShowBases then
            for k, v in pairs(worldScene.curShowBases) do
                for kk, vv in pairs(v) do
                    if vv and vv:getChildByTag(1124) then
                        tolua.cast(vv:getChildByTag(1124), "CCSprite"):removeFromParentAndCleanup(true)
                    end
                end
            end
        end
        for i = 1, 2 do
            if mapSkin[i][3] and mapSkin[i][3]:getChildByTag(1124) ~= nil then
                tolua.cast(mapSkin[i][3]:getChildByTag(1124), "CCSprite"):removeFromParentAndCleanup(true)
                if mapSkin[i][7] then
                    mapSkin[i][4]:setOpacity(mapSkin[i][7])
                end
            end
        end
        if mainLandScene.portSp and mainLandScene.portSp:getChildByTag(1124) then
            tolua.cast(mainLandScene.portSp:getChildByTag(1124), "CCSprite"):removeFromParentAndCleanup(true)
        end
        if buildingSkinAddress["worldMapNeedSHowIndexs"] and SizeOfTable(buildingSkinAddress["worldMapNeedSHowIndexs"]) > 0 then
            for k, v in pairs(buildingSkinAddress["worldMapNeedSHowIndexs"]) do
                if worldScene.clayer:getChildByTag(800 + k) then
                    tolua.cast(worldScene.clayer:getChildByTag(800 + k), "CCSprite"):removeFromParentAndCleanup(true)
                end
                if worldScene.clayer:getChildByTag(700 + k) == nil then
                    local tmpSp = CCSprite:create("scene/world_map_mi.jpg")
                    tmpSp:setTag(700 + k)
                    tmpSp:setAnchorPoint(ccp(0, 0))
                    tmpSp:setPosition((v[1] - 1) * worldScene.spSize.width, (v[2] - 1) * worldScene.spSize.height)
                    worldScene.clayer:addChild(tmpSp)
                    worldScene.mapSprites[k] = tmpSp
                end
            end
        end
        CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("homeBuilding/buildingWinterSkin.plist")
        CCTextureCache:sharedTextureCache():removeTextureForKey("homeBuilding/buildingWinterSkin.png")
        CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("homeBuilding/buildingWinterSkin2.plist")
        CCTextureCache:sharedTextureCache():removeTextureForKey("homeBuilding/buildingWinterSkin2.png")
        
    end]]
end

function G_onlyInitWorldMap(needShowIndexs)
    for k, v in pairs(needShowIndexs) do
        if worldScene.clayer:getChildByTag(700 + k) then
            tolua.cast(worldScene.clayer:getChildByTag(700 + k), "CCSprite"):removeFromParentAndCleanup(true)
        end
        if worldScene.clayer:getChildByTag(800 + k) == nil then
            local url_3 = "http://"..base.serverUserIp.."/tankheroclient/" .. "tankimg/world_map_mi_win.jpg"
            local function onLoadWorldMap(fn, icon)
                icon:setTag(800 + k)
                icon:setAnchorPoint(ccp(0, 0))
                icon:setPosition((v[1] - 1) * worldScene.spSize.width, (v[2] - 1) * worldScene.spSize.height)
                worldScene.clayer:addChild(icon)
                worldScene.mapSprites[k] = icon
            end
            CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
            CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
            local worldMapImage = LuaCCWebImage:createWithURL(url_3, onLoadWorldMap)
            CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
            CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        end
    end
end
function G_downNewMapAndInitWinterSkin()
    do 
        return 
    end
    local function needDownCall()
        -- print("begin~~~ to  ~~~ downLoad Image~~~~~",base.serverUserIp)
        local url_1 = "http://"..base.serverUserIp.."/tankheroclient/" .. "tankimg/homeMap_mi_win.jpg"
        local url_2 = "http://"..base.serverUserIp.."/tankheroclient/" .. "tankimg/outskirtMap_mi_win.jpg"
        local url_3 = "http://"..base.serverUserIp.."/tankheroclient/" .. "tankimg/world_map_mi_win.jpg"
        local showSkinTipWithTime = CCUserDefault:sharedUserDefault():getIntegerForKey("showSkinTipWithTime")
        CCUserDefault:sharedUserDefault():setIntegerForKey("showSkinTipWithTime", base.serverTime)
        CCUserDefault:sharedUserDefault():flush()
        CCUserDefault:sharedUserDefault():setIntegerForKey("gameSettings_seasonEffect2017", 2)
        CCUserDefault:sharedUserDefault():flush()
        CCUserDefault:sharedUserDefault():setBoolForKey("isShowSkinTip", true)
        CCUserDefault:sharedUserDefault():flush()
        
        local function onLoadWorldMap(fn, icon)
            if buildingSkinAddress["worldMap"] == nil then
                buildingSkinAddress["worldMap"] = icon
            end
        end
        
        local function onLoadIcon_1(fn, icon)--{1:clayer,2:size,3:oldSp,4:oldRealSp,5:newRealSpscale,6:newSpScale}
            local picTb_1 = buildingSkinAddress["mapSkin"][1]
            if picTb_1[1] and picTb_1[2] and picTb_1[3] and picTb_1[3]:getChildByTag(1124) == nil then
                -- print("onLoadIcon_1~~~~~~~~~~~")
                CCUserDefault:sharedUserDefault():setIntegerForKey("isDownWinterSkin", 2)
                CCUserDefault:sharedUserDefault():flush()
                icon:setContentSize(picTb_1[2])
                icon:setScale(picTb_1[5])
                icon:setAnchorPoint(ccp(0, 0))
                icon:setTag(1124)
                picTb_1[3]:addChild(icon)
                
                picTb_1[4]:setOpacity(0)
            end
        end
        
        local function onLoadIcon_2(fn, icon2)--{1:clayer,2:size,3:oldSp,4:oldRealSp,5:newRealSpscale,6:newSpScale}
            local picTb_2 = buildingSkinAddress["mapSkin"][2]
            if picTb_2[1] and picTb_2[2] and picTb_2[3] and picTb_2[3]:getChildByTag(1124) == nil then
                
                CCUserDefault:sharedUserDefault():setIntegerForKey("isDownWinterSkin", 2)
                CCUserDefault:sharedUserDefault():flush()
                
                icon2:setContentSize(picTb_2[2])
                icon2:setScale(picTb_2[5])
                icon2:setTag(1124)
                icon2:setAnchorPoint(ccp(0, 0))
                picTb_2[3]:addChild(icon2)
                
                picTb_2[4]:setOpacity(0)
            elseif icon2 then
                
                picTb_2[8] = icon2
                CCUserDefault:sharedUserDefault():setIntegerForKey("isDownWinterSkin", 2)
                CCUserDefault:sharedUserDefault():flush()
            end
        end
        
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        local worldMapImage = LuaCCWebImage:createWithURL(url_3, onLoadWorldMap)
        local webImage = LuaCCWebImage:createWithURL(url_1, onLoadIcon_1)
        local webImage = LuaCCWebImage:createWithURL(url_2, onLoadIcon_2)
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        G_isOpenWinterSkin = true
        G_setWholeSkin(G_isOpenWinterSkin)
    end
    local function cancelCall()
        -- G_isOpenWinterSkin = false
        local showSkinTipWithTime = CCUserDefault:sharedUserDefault():getIntegerForKey("showSkinTipWithTime")
        CCUserDefault:sharedUserDefault():setIntegerForKey("showSkinTipWithTime", base.serverTime)
        CCUserDefault:sharedUserDefault():flush()
        
        CCUserDefault:sharedUserDefault():setIntegerForKey("gameSettings_seasonEffect2017", 1)
        CCUserDefault:sharedUserDefault():flush()
        -- G_setWholeSkin(false)
    end
    local showSkinTipWithTime = CCUserDefault:sharedUserDefault():getIntegerForKey("showSkinTipWithTime") --showSkinTipWithTime ==false 显示对勾，标示不需要提示
    local isShowCheck = showSkinTipWithTime == false and true or false
    -- print("initSKin-------->showSkinTipWithTime,isShowCheck",showSkinTipWithTime,isShowCheck)
    local function checkCall(isCurShowCheck)
        -- print("in checkCall------->isShowCheck",isShowCheck,isCurShowCheck)
        if isCurShowCheck then--不在提示--
            CCUserDefault:sharedUserDefault():setBoolForKey("isShowSkinTip", true)
            CCUserDefault:sharedUserDefault():flush()
        else
            CCUserDefault:sharedUserDefault():setIntegerForKey("showSkinTipWithTime", base.serverTime)
            CCUserDefault:sharedUserDefault():flush()
            CCUserDefault:sharedUserDefault():setBoolForKey("isShowSkinTip", false)
            CCUserDefault:sharedUserDefault():flush()
        end
    end
    smallDialog:showSureAndCancleAndCheckTip("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), needDownCall, getlocal("dialog_title_prompt"), getlocal("isNeedWinterSkin"), nil, 2, nil, nil, cancelCall, nil, nil, nil, nil, nil, nil, true, getlocal("evaluate_never"), 24, isShowCheck, checkCall)
    do return end
end

function G_beginSnowTime()
    --[[print("G_beginSnowTime-----in here??????")
    local weekDay = G_getFormatWeekDay()
    local zeroTime=G_getWeeTs(base.serverTime)
    local hour=math.floor((base.serverTime - zeroTime)/3600)
    local curMin=math.floor(((base.serverTime - zeroTime)%3600)/60)
    
    local beginTime = mapForSnowCfg[weekDay]["beginTime"]
    local lastTime = mapForSnowCfg[weekDay]["lastTime"]
    -- print("G_beginSnowTime---weekDay--in here??????",weekDay,hour)
    local isInTime =nil
    for k,v in pairs(beginTime) do
        if v[1] == hour then
            isInTime = k
            -- print("isInTime----->",isInTime)
            G_curSnowTime ={k,mapForSnowCfg[weekDay]["beginTime"][isInTime][1],mapForSnowCfg[weekDay]["beginTime"][isInTime][2]}
            do break end
        end
    end
    if isInTime and curMin - G_curSnowTime[3] >= 0 and  curMin - G_curSnowTime[3] <= lastTime[isInTime][1] then
        return true
    elseif isInTime ==nil then
        for k,v in pairs(beginTime) do
            if v[1] == hour - 1 and curMin+60 <= v[2]+lastTime[k][1] then
                return true
            end
        end
    end
    print(" return false??????????")]]
    return false
end

function G_removeSkinData()
    buildingSkinAddress = {["mapSkin"] = {[1] = {}, [2] = {}}, ["mainSkin"] = {}, ["graySkin"] = {}, ["commonSkin"] = {}, ["baseSkin"] = {}, }
end

function G_initWinterSkinFirst()
    do 
        return 
    end
    if base.isWinter then
        local skinSetting = CCUserDefault:sharedUserDefault():getIntegerForKey("gameSettings_seasonEffect2017")--默认开关
        local showSkinTipWithTime = CCUserDefault:sharedUserDefault():getIntegerForKey("showSkinTipWithTime") --上一次关闭提示板的时间戳
        local isShowSkinTip = CCUserDefault:sharedUserDefault():getBoolForKey("isShowSkinTip") --是否不再提示   因为默认是false 所以 对勾悬了 不提示用true
        -- print("base.isWinter---------skinSetting------>",base.isWinter,skinSetting,showSkinTipWithTime,isShowSkinTip,newGuidMgr:isNewGuiding())
        if newGuidMgr:isNewGuiding() == false then
            
            if skinSetting == 2 then
                
                local isDownWinterSkin = CCUserDefault:sharedUserDefault():getIntegerForKey("isDownWinterSkin")
                -- print("isDownWinterSkin------->",isDownWinterSkin)
                if isDownWinterSkin == 2 then
                    G_isOpenWinterSkin = true
                    G_setWholeSkin(G_isOpenWinterSkin)
                elseif showSkinTipWithTime == 0 or (isShowSkinTip == false and showSkinTipWithTime and G_isToday(showSkinTipWithTime) == false) then
                    G_downNewMapAndInitWinterSkin()
                end
                
            elseif showSkinTipWithTime == 0 or (isShowSkinTip == false and showSkinTipWithTime and G_isToday(showSkinTipWithTime) == false) then
                G_downNewMapAndInitWinterSkin()
            end
        elseif skinSetting == 2 and isShowSkinTip == true then
            -- print("newGuidMgr------>",newGuidMgr:isNewGuiding())
            G_isOpenWinterSkin = true
            G_setWholeSkin(G_isOpenWinterSkin)
            
        end
    end
end

---新增加三种颜色的flicker
--@ picName ： b-蓝色，g-绿色，p-紫色，r-红色，y-黄色
function G_addRectFlicker2(parentBg, scaleX, scaleY, flickerIdx, picName, flickerPos, lnum, adaMark)--picName flickerIdx: 黄色 y 3  蓝色 b 1  紫色 p 2 绿色 g 4
    -- adaMark 新的自动放缩适配，非写死的
    if parentBg:getChildByTag(10101 + flickerIdx) then
        return parentBg:getChildByTag(10101 + flickerIdx)
    end
    if parentBg then
        local m_iconScaleX, m_iconScaleY = scaleX, scaleY
        local pzFrameName = picName.."Flicker_1.png"
        local metalSp = CCSprite:createWithSpriteFrameName(pzFrameName)
        local pzArr = CCArray:create()
        for kk = 1, 15 do
            local nameStr = picName.."Flicker_"..kk..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            pzArr:addObject(frame)
        end
        local animation = CCAnimation:createWithSpriteFrames(pzArr)
        animation:setDelayPerUnit(0.1)
        local animate = CCAnimate:create(animation)
        metalSp:setAnchorPoint(ccp(0.5, 0.5))
        if adaMark then
            metalSp:setScaleX(parentBg:getContentSize().width / 90)
            metalSp:setScaleY(parentBg:getContentSize().height / 90)
        else
            if m_iconScaleX ~= nil then
                metalSp:setScaleX(m_iconScaleX)
            end
            if m_iconScaleY ~= nil then
                metalSp:setScaleY(m_iconScaleY)
            end
        end
        
        metalSp:setPosition(ccp(parentBg:getContentSize().width / 2, parentBg:getContentSize().height / 2))
        metalSp:setTag(10101 + flickerIdx)
        if lnum == nil then
            lnum = 5
        end
        parentBg:addChild(metalSp, lnum)
        local repeatForever = CCRepeatForever:create(animate)
        metalSp:runAction(repeatForever)
        return metalSp
    end
end

--获取需要下载的图片的url地址，pathStr：要下载的路径
function G_downloadUrl(pathStr)
    local downLoadIP
    local platName = G_curPlatName()
    --全球混服不从入口机下载，还从原平台的入口机下载
    --港台
    if(platName == "efunandroidtw" or platName == "3" or platName == "androidlongzhong")then
        downLoadIP = "tank001.efuntw.com"
        --北美
    elseif(platName == "14" or platName == "androidkunlun" or platName == "androidkunlunz")then
        downLoadIP = "tank-na-in.raysns.com"
        --德国
    elseif(platName == "androidsevenga" or platName == "11")then
        downLoadIP = "tank-ger-web01.raysns.com"
    else
        downLoadIP = base.serverUserIp
    end
    return "http://"..downLoadIP.."/tankheroclient/" .. "tankimg/"..pathStr
end
function G_removeFlicker2(parentBg)
    if parentBg ~= nil then
        local temSp = tolua.cast(parentBg, "CCNode")
        local metalSp = nil;
        if temSp ~= nil then
            for i = 1, 3 do
                metalSp = tolua.cast(temSp:getChildByTag(10101 + i), "CCSprite")
                if metalSp ~= nil then
                    metalSp:removeFromParentAndCleanup(true)
                    metalSp = nil
                    -- do break end
                end
            end
        end
    end
end

function G_getLbColorByPid(pid)
    local color = G_ColorWhite
    if pid and propCfg[pid] and propCfg[pid].iconbg then
        local iconbg = propCfg[pid].iconbg
        if iconbg == "equipBg_gray.png" then
            color = G_ColorWhite
        elseif iconbg == "equipBg_green.png" then
            color = G_ColorGreen
        elseif iconbg == "equipBg_blue.png" then
            color = G_ColorBlue
        elseif iconbg == "equipBg_purple.png" then
            color = G_ColorPurple
        elseif iconbg == "equipBg_orange.png" then
            color = G_ColorOrange
        elseif iconbg == "equipBg_red.png" then
            color = G_ColorRed
        end
    end
    return color
end

--flag：1或-1，1是先往左，-1是先往右
--space：晃动距离
function G_actionArrow(flag, space, interval)
    if space == nil then
        space = 20
    end
    local scale1 = 1
    local scale2 = 2
    if flag == 1 then
        scale1 = 1
        scale2 = 2
    end
    local acArr1 = CCArray:create()
    local mvBy1 = CCMoveBy:create(interval or 1, ccp(-space * flag, 0))
    -- local scaleTo=CCScaleTo:create(1,scale1)
    acArr1:addObject(mvBy1)
    -- acArr1:addObject(scaleTo)
    local spawn1 = CCSpawn:create(acArr1)
    
    local acArr2 = CCArray:create()
    local mvBy2 = CCMoveBy:create(interval or 1, ccp(space * flag, 0))
    -- local scaleTo2=CCScaleTo:create(1,scale2)
    acArr2:addObject(mvBy2)
    -- acArr2:addObject(scaleTo2)
    local spawn2 = CCSpawn:create(acArr2)
    
    local acArr = CCArray:create()
    acArr:addObject(spawn1)
    acArr:addObject(spawn2)
    local seq = CCSequence:create(acArr)
    local repeatForever = CCRepeatForever:create(seq)
    return repeatForever
end

--是否是全球混服
function G_isGlobalServer()
    -- do return true end
    local platName = G_curPlatName()
    local zoneID = tonumber(base.curZoneID)
    --港台
    if(platName == "efunandroidtw" or platName == "3" or platName == "androidlongzhong" or
        --北美
    platName == "14" or platName == "androidkunlun" or platName == "androidkunlunz")then
    -- --德国
    -- platName=="androidsevenga" or platName=="11" or platName=="0")then
    if(zoneID > 100 and zoneID < 500)then
        return true
    elseif(zoneID > 900)then
        if(socketHelper and socketHelper.curHost and string.find(socketHelper.curHost, "global") ~= nil)then
            return true
        else
            return false
        end
    else
        return false
    end
end
return false
end

--全球混服之后，不能再像以前那样取统计ID，而是需要做一个新的映射
function G_getPlatAppID()
    if(G_isGlobalServer())then
        return platCfg.platCfgAppid2[G_curPlatName()]
    else
        return platCfg.platCfgAppid[G_curPlatName()]
    end
end

--全球混服之后，不能再像以前那样取商店配置，而是需要做一个新的映射
function G_getPlatStoreCfg()
    if platCfg.platCfgStoreCfg3[G_curPlatName()] then --充值档位特殊化配置
        local storeCfg = platCfg.platCfgStoreCfg3[G_curPlatName()]["ramadan"]
        if storeCfg then
            if acRamadanVoApi and acRamadanVoApi:isUseNewStoreCfg() == true then --阿拉伯斋月活动处理
                return storeCfg
            end
        end
    end
    if(platCfg.platCfgStoreCfg2[G_curPlatName()] and G_isGlobalServer())then
        return platCfg.platCfgStoreCfg2[G_curPlatName()]
    else
        if(platCfg.platCfgStoreCfg[G_curPlatName()])then
            return platCfg.platCfgStoreCfg[G_curPlatName()]
        else
            return localCfg
        end
    end
end

--全球混服之后，不能再像以前那样取VIP配置，而是需要做一个新的映射
function G_getPlatVipCfg()
    if(platCfg.platCfgPlayerVipCfg2[G_curPlatName()] and G_isGlobalServer())then
        return platCfg.platCfgPlayerVipCfg2[G_curPlatName()]
    else
        if(platCfg.platCfgPlayerVipCfg[G_curPlatName()])then
            return platCfg.platCfgPlayerVipCfg[G_curPlatName()]
        else
            return playerCfg.gem4vip
        end
    end
end

--date_time="{1}/{2}/{3} {4}:{5}:{6}",
function G_formatDate(time)
    local tab = G_getDate(time)
    --获得time时间table，有year,month,day,hour,min,sec等元素。
    local function format(num)
        if num < 10 then
            return "0" .. num
        else
            return num
        end
    end
    local date = getlocal("date_time", {tab.year, format(tab.month), format(tab.day), format(tab.hour), format(tab.min), format(tab.sec)})
    return date
end

--active_date_time="{1}d {2}:{3}:{4}",
function G_formatActiveDate(ts)
    local timeStr = ""
    local time = 0
    if ts and ts > 0 then
        local day = math.floor(ts / (3600 * 24))
        if day and day > 0 then
            timeStr = day.."d "
            time = ts - (day * 3600 * 24)
        else
            time = ts
        end
    end
    -- 将一位数补齐为两位数
    local function addOneNum(num)
        if num < 10 then
            return "0"..num
        else
            return num
        end
    end
    if time >= 3600 then
        timeStr = timeStr .. addOneNum(math.floor(time / 3600)) .. ":"..addOneNum(math.floor((time % 3600) / 60)) .. ":"..addOneNum(math.floor(time % 60))
    elseif time < 3600 and time >= 0 then
        timeStr = timeStr .. "00:"..addOneNum(math.floor(time / 60)) .. ":"..addOneNum(math.floor(time % 60))
    else
        timeStr = timeStr .. "00:00:00"
    end
    return timeStr
end

--获取每日活动时间显示的方法
function G_getDailyActivityTimeShow(acVo)
    local timeStr = ""
    if acVo then
        if acVo.type == "dailyLottery" or acVo.type == "isSignSwitch" or acVo.type == "dnews" then
            timeStr = getlocal("growingPlanTime")
        elseif acVo.type == "drew1" or acVo.type == "drew2" or acVo.type == "boss" or acVo.type == "rpShop" then
            local st, et
            if acVo.type == "drew1" then
                st = getEnergyNoonCfg.opentime[1]
                et = getEnergyNoonCfg.opentime[2]
            elseif acVo.type == "drew2" then
                st = getEnergyNightCfg.opentime[1]
                et = getEnergyNightCfg.opentime[2]
            elseif acVo.type == "boss" then
                st, et = acVo.st, acVo.et
            elseif acVo.type == "rpShop" then
                local week = G_getFormatWeekDay(base.serverTime)
                local zeroTime = G_getWeeTs(base.serverTime)
                st = zeroTime + (6 - week) * 86400
                et = st + 2 * 86400
            end
            if st and et then
                if type(st) == "number" and type(et) == "number" then
                    if base.serverTime < st then
                        timeStr = getlocal("beginCountDown", {G_formatActiveDate(st - base.serverTime)})
                    elseif base.serverTime >= st and base.serverTime < et then
                        timeStr = getlocal("endCountDown", {G_formatActiveDate(et - base.serverTime)})
                    else
                        timeStr = getlocal("beginCountDown", {G_formatActiveDate(st + 86400 - base.serverTime)})
                    end
                elseif type(st) == "table" and type(et) == "table" then
                    local diffTime = base.serverTime - G_getWeeTs(base.serverTime)
                    local startTime = (st[1] * 3600 + st[2] * 60)
                    local endTime = (et[1] * 3600 + et[2] * 60)
                    if diffTime < startTime then
                        timeStr = getlocal("beginCountDown", {G_formatActiveDate(startTime - diffTime)})
                    elseif diffTime >= startTime and diffTime < endTime then
                        timeStr = getlocal("endCountDown", {G_formatActiveDate(endTime - diffTime)})
                    else
                        timeStr = getlocal("beginCountDown", {G_formatActiveDate(startTime + 86400 - diffTime)})
                    end
                end
            end
        end
    end
    return timeStr
end

--acVo：活动的vo数据，acTimeLb：活动时间的label，rewardTimeLb：领奖时间的label，isAddWz：是否需要添加活动时间或者领奖时间的文字，rewardFlag：是否有领奖时间
function G_updateActiveTime(acVo, acTimeLb, rewardTimeLb, isAddWz, rewardFlag, hasReward)
    if G_isGlobalServer() == true then
        if acVo and acVo.st and acVo.et then
            local acEt
            if acVo.acEt then
                acEt = acVo.acEt
            else
                acEt = acVo.et
            end
            -- if rewardFlag and rewardFlag==true then
            if rewardTimeLb or hasReward then
                acEt = acVo.et - 86400
            end
            if acTimeLb then
                acTimeLb = tolua.cast(acTimeLb, "CCLabelTTF")
                if acTimeLb then
                    local timeStr = activityVoApi:getActivityTimeStr(acVo.st, acEt, acVo.et)
                    if isAddWz and isAddWz == true then
                        timeStr = getlocal("activity_timeLabel") .. ": "..timeStr
                    end
                    acTimeLb:setString(timeStr)
                end
            end
            if rewardTimeLb then
                rewardTimeLb = tolua.cast(rewardTimeLb, "CCLabelTTF")
                if rewardTimeLb then
                    local rewardTimeStr = activityVoApi:getActivityRewardTimeStr(acEt, 0, 86400, true)
                    if isAddWz and isAddWz == true then
                        rewardTimeStr = getlocal("recRewardTime") .. ": "..rewardTimeStr
                    end
                    rewardTimeLb:setString(rewardTimeStr)
                end
            end
        end
    end
end

--return {1}d {2}:{3}:{4}
function G_getCDTimeStr(endTs)
    local cdTimeStr = "00:00:00"
    if endTs then
        local cdTime = endTs - base.serverTime
        if cdTime >= 0 then
            cdTimeStr = G_formatActiveDate(cdTime)
        end
    end
    return cdTimeStr
end

-- childTb={{pic=".png",tag=,order=,Size}}
function G_getComposeIcon(callback, iconSize, childTb)
    local composeIcon = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), callback)
    composeIcon:setContentSize(iconSize)
    composeIcon:setOpacity(0)
    
    for k, v in pairs(childTb) do
        local childSp = CCSprite:createWithSpriteFrameName(v.pic)
        if not childSp then
            childSp = CCSprite:create(v.pic)
        end
        composeIcon:addChild(childSp, v.order)
        childSp:setTag(v.tag)
        childSp:setPosition(getCenterPoint(composeIcon))
        childSp:setScale(v.size / childSp:getContentSize().width)
    end
    return composeIcon
end

--是否在邮件面板显示飞机信息
--rType:战报类型(暂时没用上，处理特殊需求) 1.邮件，2.军事演习，3远征，4.异星矿场，5.超级武器抢夺，6.军团跨服战
function G_isShowPlaneInReport(report, rType)
    if base.plane == 1 and report and report.plane and ((report.plane[1] and report.plane[1][1] and report.plane[1][1] ~= 0) or (report.plane[2] and report.plane[2][1] and report.plane[2][1] ~= 0)) then
        return true
    end
    return false
end

function G_getPlaneReportHeight()
    return 380
end
--在邮件tv里添加plane数据
function G_addReportPlane(report, cell, isAttacker, cellHeight)
    if report and cell then
        local hCellWidth = G_VisibleSizeWidth - 50
        local hCellHeight = 380
        if cellHeight then
            hCellHeight = cellHeight
        end
        local planeTitleBg = LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png", CCRect(20, 20, 10, 10), function ()end)
        planeTitleBg:setContentSize(CCSizeMake(hCellWidth, 50))
        planeTitleBg:ignoreAnchorPointForPosition(false)
        planeTitleBg:setAnchorPoint(ccp(0, 0))
        planeTitleBg:setIsSallow(false)
        cell:addChild(planeTitleBg, 1)
        planeTitleBg:setPosition(ccp(0, hCellHeight - 50))
        
        local planeTitleLb = GetTTFLabel(getlocal("plane_infoTitle"), 24)
        planeTitleLb:setPosition(getCenterPoint(planeTitleBg))
        planeTitleBg:addChild(planeTitleLb, 2)
        
        local lineSp = CCSprite:createWithSpriteFrameName("LineCross.png")
        lineSp:setAnchorPoint(ccp(0.5, 0.5))
        lineSp:setPosition(ccp(hCellWidth / 2, (hCellHeight - 50) / 2))
        lineSp:setScaleX((hCellHeight - 30) / lineSp:getContentSize().width)
        lineSp:setRotation(90)
        cell:addChild(lineSp, 1)
        
        local ownerPlaneStr = getlocal("plane_emailOwn")
        local enemyPlaneStr = getlocal("plane_emailEnemy")
        local myPlane, myPlaneStrong
        local enemyPlane, enemyPlaneStrong

        local planeData = report.plane or {{0, 0}, {0, 0}}
        if planeData then
            if isAttacker == true or isAttacker == nil then
                if planeData[1] and type(planeData[1]) == "table" then
                    if planeData[1][1] and planeData[1][1] ~= 0 then
                        myPlane = planeData[1][1]
                    end
                    myPlane = planeData[1][1] ~= 0 and planeData[1][1] or nil
                    if planeData[1][2] then
                        myPlaneStrong = tonumber(planeData[1][2]) or 0
                    end
                end
                if planeData[2] and type(planeData[2]) == "table" then
                    if planeData[2][1] and planeData[2][1] ~= 0 then
                        enemyPlane = planeData[2][1]
                    end
                    if planeData[2][2] then
                        enemyPlaneStrong = tonumber(planeData[2][2]) or 0
                    end
                end
            else
                if planeData[2] and type(planeData[2]) == "table" then
                    if planeData[2][1] and planeData[2][1] ~= 0 then
                        myPlane = planeData[2][1]
                    end
                    if planeData[2][2] then
                        myPlaneStrong = tonumber(planeData[2][2]) or 0
                    end
                end
                if planeData[1] and type(planeData[1]) == "table" then
                    if planeData[1][1] and planeData[1][1] ~= 0 then
                        enemyPlane = planeData[1][1]
                    end
                    if planeData[1][2] then
                        enemyPlaneStrong = tonumber(planeData[1][2]) or 0
                    end
                end
            end
        end
        
        local ownerPlaneLb = GetTTFLabelWrap(ownerPlaneStr, 24, CCSizeMake(hCellWidth / 2 - 20, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        ownerPlaneLb:setAnchorPoint(ccp(0.5, 0.5))
        ownerPlaneLb:setPosition(ccp(hCellWidth / 4, hCellHeight - 85))
        cell:addChild(ownerPlaneLb, 2)
        ownerPlaneLb:setColor(G_ColorGreen)
        
        local enemyPlaneLb = GetTTFLabelWrap(enemyPlaneStr, 24, CCSizeMake(hCellWidth / 2 - 20, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        enemyPlaneLb:setAnchorPoint(ccp(0.5, 0.5))
        enemyPlaneLb:setPosition(ccp(hCellWidth / 4 * 3, hCellHeight - 85))
        cell:addChild(enemyPlaneLb, 2)
        enemyPlaneLb:setColor(G_ColorRed)
        
        local myPlaneIcon
        if myPlane then
            myPlaneIcon = planeVoApi:getPlaneIcon(myPlane, myPlaneStrong)
        else
            myPlaneIcon = planeVoApi:getPlaneIconNull()
        end
        myPlaneIcon:setAnchorPoint(ccp(0.5, 0))
        myPlaneIcon:setPosition(ccp(hCellWidth / 4, hCellHeight - 370))
        cell:addChild(myPlaneIcon)
        
        local enemyPlaneIcon
        if enemyPlane then
            enemyPlaneIcon = planeVoApi:getPlaneIcon(enemyPlane, enemyPlaneStrong)
        else
            enemyPlaneIcon = planeVoApi:getPlaneIconNull()
        end
        enemyPlaneIcon:setAnchorPoint(ccp(0.5, 0))
        enemyPlaneIcon:setPosition(ccp(hCellWidth / 4 * 3, hCellHeight - 370))
        cell:addChild(enemyPlaneIcon)
    end
end

function G_touchedItem(touchSp, callback, targetScale)
    if touchSp then
        local targetScale = targetScale or 0.9
        local scale = touchSp:getScale()
        local scaleTo1 = CCScaleTo:create(0.1, targetScale)
        local scaleTo2 = CCScaleTo:create(0.1, scale)
        local acArr = CCArray:create()
        acArr:addObject(scaleTo1)
        acArr:addObject(scaleTo2)
        local function actionEnd()
            if callback then
                callback()
            end
        end
        local callFunc = CCCallFunc:create(actionEnd)
        acArr:addObject(callFunc)
        local seq = CCSequence:create(acArr)
        touchSp:runAction(seq)
    end
end

function G_getNewDialogBg(size, titleStr, titleSize, callback, layerNum, isShowClose, closeCallBack, titleColor, newPicTb)
    local function touchHandler()
        if callback then
            callback()
        end
    end
    local bgPicStr = "newSmallPanelBg.png"
    local bgPicRect = CCRect(170, 80, 22, 10)
    local bgPicAp = ccp(0.5, 1)
    local titleBgPicStr = "newTitleBg.png"

    if newPicTb then
        if newPicTb[1] == "dlbz" or newPicTb[1] == "hljbEx" or newPicTb[1] == "hljbKeep" or newPicTb[1] == "hryx" then
            bgPicStr = newPicTb[2]
            titleBgPicStr = newPicTb[3]
            bgPicRect = newPicTb[4]
            bgPicAp = newPicTb[5]
        elseif not newPicTb[3] then
            if newPicTb[1] == "airShipPartsTotal" then
                bgPicStr = newPicTb[2]
                titleBgPicStr = nil
                bgPicRect = newPicTb[4]
                bgPicAp = newPicTb[5]
            end
        end
    end
    
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgPicStr, bgPicRect, touchHandler)
    dialogBg:setContentSize(size)
    
    local titleLb, titleBg
    if titleBgPicStr and titleStr and titleSize then
        titleBg = CCSprite:createWithSpriteFrameName(titleBgPicStr)
        titleBg:setAnchorPoint(bgPicAp)
        titleBg:setPosition(size.width / 2, size.height)
        dialogBg:addChild(titleBg)
        titleLb = GetTTFLabelWrap(titleStr, titleSize, CCSizeMake(size.width - 40, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
        titleLb:setPosition(getCenterPoint(titleBg))
        titleBg:addChild(titleLb)
        if titleColor then
            titleLb:setColor(titleColor)
        end
    end
    
    local closeBtn, closeBtnItem
    if isShowClose and isShowClose == true then
        local function close()
            PlayEffect(audioCfg.mouseClick)
            if closeCallBack then
                closeCallBack()
            end
        end
        closeBtnItem = GetButtonItem("newCloseBtn.png", "newCloseBtn_Down.png", "newCloseBtn.png", close, nil, nil, nil);
        closeBtnItem:setPosition(ccp(0, 0))
        closeBtnItem:setAnchorPoint(CCPointMake(0, 0))
        
        closeBtn = CCMenu:createWithItem(closeBtnItem)
        closeBtn:setTouchPriority(-(layerNum - 1) * 20 - 8)
        closeBtn:setPosition(ccp(size.width - closeBtnItem:getContentSize().width - 4, size.height - closeBtnItem:getContentSize().height - 4))
        dialogBg:addChild(closeBtn, 2)
        
        local touchBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), close)
        touchBg:setTouchPriority(-(layerNum - 1) * 20 - 7)
        touchBg:setContentSize(CCSizeMake(80, 80))
        touchBg:setPosition(closeBtn:getPositionX() + closeBtnItem:getContentSize().width / 2, closeBtn:getPositionY() + closeBtnItem:getContentSize().height / 2)
        touchBg:setOpacity(0)
        dialogBg:addChild(touchBg, 1)
    end
    
    return dialogBg, titleBg, titleLb, closeBtnItem, closeBtn
end

--点击屏幕继续的文字提示（也可以加别的提示）
function G_addArrowPrompt(parent, promptStr, lbPosy)
    if parent == nil then
        do return end
    end
    local clickLbPosy = lbPosy or - 80
    local promptStr = promptStr or getlocal("click_screen_continue")
    local tmpLb = GetTTFLabel(promptStr, 25)
    local clickLb = GetTTFLabelWrap(promptStr, 25, CCSizeMake(400, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    clickLb:setPosition(ccp(parent:getContentSize().width / 2, clickLbPosy))
    parent:addChild(clickLb)
    local arrowPosx1, arrowPosx2
    local realWidth, maxWidth = tmpLb:getContentSize().width, clickLb:getContentSize().width
    if realWidth > maxWidth then
        arrowPosx1 = parent:getContentSize().width / 2 - maxWidth / 2
        arrowPosx2 = parent:getContentSize().width / 2 + maxWidth / 2
    else
        arrowPosx1 = parent:getContentSize().width / 2 - realWidth / 2
        arrowPosx2 = parent:getContentSize().width / 2 + realWidth / 2
    end
    local smallArrowSp1 = CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp1:setPosition(ccp(arrowPosx1 - 15, clickLbPosy))
    parent:addChild(smallArrowSp1)
    local smallArrowSp2 = CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp2:setPosition(ccp(arrowPosx1 - 25, clickLbPosy))
    parent:addChild(smallArrowSp2)
    smallArrowSp2:setOpacity(100)
    local smallArrowSp3 = CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp3:setPosition(ccp(arrowPosx2 + 15, clickLbPosy))
    parent:addChild(smallArrowSp3)
    smallArrowSp3:setRotation(180)
    local smallArrowSp4 = CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp4:setPosition(ccp(arrowPosx2 + 25, clickLbPosy))
    parent:addChild(smallArrowSp4)
    smallArrowSp4:setOpacity(100)
    smallArrowSp4:setRotation(180)
    
    local space = 20
    smallArrowSp1:runAction(G_actionArrow(1, space))
    smallArrowSp2:runAction(G_actionArrow(1, space))
    smallArrowSp3:runAction(G_actionArrow(-1, space))
    smallArrowSp4:runAction(G_actionArrow(-1, space))
end

function G_showNewPropInfo(layerNum, istouch, isuseami, callBack, propItem, hideNum, addStr, addStrColor, specialUse, isShow)
    require "luascript/script/game/scene/gamedialog/newPropShowSmallDialog"
    local propInFoDia = newPropShowSmallDialog:showPropInfo(layerNum, istouch, isuseami, callBack, propItem, hideNum, addStr, addStrColor, specialUse, isShow)
    return propInFoDia
end

function G_showPropList(layerNum, istouch, isuseami, callBack, titleStr, listDes, propList)
    require "luascript/script/game/scene/gamedialog/propListShowSmallDialog"
    propListShowSmallDialog:showListProp(layerNum, istouch, isuseami, callBack, titleStr, listDes, propList)
end

function G_isPopBoard(keyName)
    local dataKey = keyName .. "@"..tostring(playerVoApi:getUid()) .. "@"..tostring(base.curZoneID)
    local localData = CCUserDefault:sharedUserDefault():getStringForKey(dataKey)
    if localData and localData ~= "" then
        local arrTb = Split(localData, "_")
        if G_isToday(tonumber(arrTb[1])) then
            if tonumber(arrTb[2]) == 1 then
                return false
            else
                return true
            end
        else
            return true
        end
    end
    return true

end

-- sValue time_0 time_1
function G_changePopFlag(keyName, sValue)
    local dataKey = keyName .. "@"..tostring(playerVoApi:getUid()) .. "@"..tostring(base.curZoneID)
    local localData = CCUserDefault:sharedUserDefault():setStringForKey(dataKey, sValue)
    CCUserDefault:sharedUserDefault():flush()
end

--showType:显示类型，1：统率升级二次确认
function G_showSecondConfirm(layerNum, istouch, isuseami, titleStr, contentDes, isCheck, callback1, callback2, cancelCallback, desInfo, addStrTb, btn1, btn2, closeFlag, nocancel, showType, checkInfoStr, titleStr2)
    require "luascript/script/game/scene/gamedialog/secondConfirmShowSmallDialog"
    return secondConfirmShowSmallDialog:showListProp(layerNum, istouch, isuseami, titleStr, contentDes, isCheck, callback1, callback2, cancelCallback, desInfo, addStrTb, btn1, btn2, closeFlag, nocancel, showType, checkInfoStr, titleStr2)
end

--是否需要使用新的地图（默认关闭）
function G_isUseNewMap()
    return true
end
function G_createItemKuang(size, callback)
    local function touchHandler()
        if callback then
            callback()
        end
    end
    local kuangSp = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png", CCRect(19, 19, 2, 2), touchHandler)
    kuangSp:setContentSize(size)
    local pointSp1 = CCSprite:createWithSpriteFrameName("pointThree.png")
    pointSp1:setPosition(ccp(2, kuangSp:getContentSize().height / 2))
    kuangSp:addChild(pointSp1)
    local pointSp2 = CCSprite:createWithSpriteFrameName("pointThree.png")
    pointSp2:setPosition(ccp(kuangSp:getContentSize().width - 2, kuangSp:getContentSize().height / 2))
    kuangSp:addChild(pointSp2)
    return kuangSp
end
function G_getNewDialogBg2(size, layerNum, callback, titleStr, titleSize, titleColor, fontType)
    local function touchHandler()
        if callback then
            callback()
        end
    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg1.png", CCRect(30, 30, 1, 1), touchHandler)
    dialogBg:setContentSize(size)
    dialogBg:setTouchPriority(-(layerNum - 1) * 20 - 1)
    local lineSp1 = CCSprite:createWithSpriteFrameName("rewardPanelLine.png")
    lineSp1:setAnchorPoint(ccp(0.5, 1))
    lineSp1:setPosition(ccp(size.width / 2, size.height))
    dialogBg:addChild(lineSp1)
    local lineSp2 = CCSprite:createWithSpriteFrameName("rewardPanelLine.png")
    lineSp2:setAnchorPoint(ccp(0.5, 0))
    lineSp2:setPosition(ccp(size.width / 2, lineSp2:getContentSize().height))
    dialogBg:addChild(lineSp2)
    lineSp2:setRotation(180)
    if titleStr then
        local titleBg = CCSprite:createWithSpriteFrameName("newTitleBg2.png")
        titleBg:setPosition(size.width / 2, size.height)
        dialogBg:addChild(titleBg)
        local titleLb = GetTTFLabelWrap(titleStr, titleSize or 25, CCSizeMake(titleBg:getContentSize().width, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, fontType)
        titleLb:setPosition(getCenterPoint(titleBg))
        titleLb:setColor(titleColor or G_ColorWhite)
        titleBg:addChild(titleLb)
    end
    
    return dialogBg, lineSp1, lineSp2
end

--是否是中国大陆的平台
function G_isChina()
    if G_getCurChoseLanguage() == "cn" and G_curPlatName() ~= "4" and G_curPlatName() ~= "efunandroiddny" then
        return true
    else
        return false
    end
end

--是否是德国的平台
function G_isGermany()
    if G_curPlatName() == "androidsevenga" or G_curPlatName() == "11" then
        return true
    end
    return false
end
--标题 + 背景色
function G_createNewTitle(title, size, flag, isNeedHeght, fontType)
    local titleStr = title[1] or ""
    local fontSize = title[2] or 28
    local color = title[3] or G_ColorWhite
    local titleBg = CCSprite:createWithSpriteFrameName("newGreenFadeLight.png")
    titleBg:setAnchorPoint(ccp(0.5, 0))
    local scaleX = size.width / titleBg:getContentSize().width
    titleBg:setScaleX(scaleX)
    
    local fontType = fontType or "Helvetica"
    local titleLb = GetTTFLabelWrap(titleStr, fontSize, CCSizeMake(size.width - 60, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, fontType)
    titleLb:setScaleX(1 / scaleX)
    titleLb:setPosition(titleBg:getContentSize().width / 2, 2 + titleLb:getContentSize().height / 2)
    titleLb:setColor(color)
    titleBg:addChild(titleLb)
    
    if flag == nil then
        flag = true
    end
    if flag then
        for i = 1, 2 do
            local pointSp = CCSprite:createWithSpriteFrameName("newPointRect.png")
            pointSp:setPosition(20 + (i - 1) * (titleBg:getContentSize().width - 40), titleLb:getPositionY())
            pointSp:setScaleX(1 / scaleX)
            titleBg:addChild(pointSp)
            
            local pointLineSp = CCSprite:createWithSpriteFrameName("newPointLine.png")
            local angle, posX = 0, 20 + pointLineSp:getContentSize().width / 2
            if i == 1 then
                angle, posX = 180, -posX + 8
            end
            pointLineSp:setPosition(posX, pointSp:getContentSize().height / 2)
            pointLineSp:setRotation(angle)
            pointSp:addChild(pointLineSp)
        end
    end
    local titleHeight = nil
    if isNeedHeght then
        titleHeight = titleLb:getContentSize().height
    end
    return titleBg, titleLb, titleHeight
end

-- toSmall 按下瞬间产生效果
function G_createBotton(parent, pos, btnStrInfo, normalPic, selectPic, disablePic, callback, scale, priority, zorder, btnTag, newAnchorPoint, isbrigtht, selectNText, selectNTextPos, toSmall)
    local function touchHandler(tag, object)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if callback then
            callback(tag, object)
        end
    end
    local btnItem
    if btnStrInfo then
        local btnStr = btnStrInfo[1] or ""
        local strSize = btnStrInfo[2] or 25
        local color = btnStrInfo[3] or G_ColorWhite
        local strokeTb = btnStrInfo[4]
        if isbrigtht then
            btnItem = GetButtonItem(normalPic, selectPic, disablePic, touchHandler, btnTag, btnStr, strSize / scale, 101, nil, nil, selectNText, selectNTextPos, isbrigtht, toSmall)
        else
            btnItem = GetButtonItem(normalPic, selectPic, disablePic, touchHandler, btnTag, btnStr, strSize / scale, 101, nil, nil, selectNText, selectNTextPos, nil, toSmall)
        end
        local strLb = tolua.cast(btnItem:getChildByTag(101), "CCLabelTTF")
        if strLb then
            strLb:setColor(color)
            if type(strokeTb) == "table" then--添加描边效果
                local strokeColor = strokeTb[1] or ccc3(0, 0, 0)
                local strokeWidth = strokeTb[2] or 2
                local strStrokeLb = GetTTFLabel(strLb:getString(), strLb:getFontSize(), strLb:getFontName())
                strStrokeLb:setPosition(strLb:getContentSize().width / 2 + strokeWidth, strLb:getContentSize().height / 2 - strokeWidth)
                strStrokeLb:setColor(strokeColor)
                strStrokeLb:setTag(10)
                strLb:addChild(strStrokeLb, -1)
            end
        end
    else
        if isbrigtht then
            btnItem = GetButtonItem(normalPic, selectPic, disablePic, touchHandler, btnTag, nil, nil, nil, nil, nil, selectNText, selectNTextPos, isbrigtht, toSmall)
        else
            btnItem = GetButtonItem(normalPic, selectPic, disablePic, touchHandler, btnTag, nil, nil, nil, nil, nil, selectNText, selectNTextPos, isbrigtht, toSmall)
        end
    end
    if newAnchorPoint then
        btnItem:setAnchorPoint(newAnchorPoint)
    end
    btnItem:setScale((scale or 1))
    local btnMenu = CCMenu:createWithItem(btnItem)
    btnMenu:setTouchPriority(priority or - 1)
    btnMenu:setPosition(pos)
    parent:addChild(btnMenu, (zorder or 0))
    
    return btnItem, btnMenu
end

-- 点击屏幕继续
function G_clickSreenContinue(parent)
    local childTb = {}
    -- 下面的点击屏幕继续
    local clickLbPosy = -80
    local tmpLb = GetTTFLabel(getlocal("click_screen_continue"), 25)
    local clickLb = GetTTFLabelWrap(getlocal("click_screen_continue"), 25, CCSizeMake(400, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    clickLb:setPosition(ccp(parent:getContentSize().width / 2, clickLbPosy))
    parent:addChild(clickLb)
    table.insert(childTb, clickLb)
    local arrowPosx1, arrowPosx2
    local realWidth, maxWidth = tmpLb:getContentSize().width, clickLb:getContentSize().width
    if realWidth > maxWidth then
        arrowPosx1 = parent:getContentSize().width / 2 - maxWidth / 2
        arrowPosx2 = parent:getContentSize().width / 2 + maxWidth / 2
    else
        arrowPosx1 = parent:getContentSize().width / 2 - realWidth / 2
        arrowPosx2 = parent:getContentSize().width / 2 + realWidth / 2
    end
    local smallArrowSp1 = CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp1:setPosition(ccp(arrowPosx1 - 15, clickLbPosy))
    parent:addChild(smallArrowSp1)
    local smallArrowSp2 = CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp2:setPosition(ccp(arrowPosx1 - 25, clickLbPosy))
    parent:addChild(smallArrowSp2)
    smallArrowSp2:setOpacity(100)
    local smallArrowSp3 = CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp3:setPosition(ccp(arrowPosx2 + 15, clickLbPosy))
    parent:addChild(smallArrowSp3)
    smallArrowSp3:setRotation(180)
    local smallArrowSp4 = CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp4:setPosition(ccp(arrowPosx2 + 25, clickLbPosy))
    parent:addChild(smallArrowSp4)
    smallArrowSp4:setOpacity(100)
    smallArrowSp4:setRotation(180)
    
    table.insert(childTb, smallArrowSp1)
    table.insert(childTb, smallArrowSp2)
    table.insert(childTb, smallArrowSp3)
    table.insert(childTb, smallArrowSp4)
    
    local space = 20
    smallArrowSp1:runAction(G_actionArrow(1, space))
    smallArrowSp2:runAction(G_actionArrow(1, space))
    smallArrowSp3:runAction(G_actionArrow(-1, space))
    smallArrowSp4:runAction(G_actionArrow(-1, space))
    
    return childTb
end

-- smallDialog(小板子上下左右添加屏蔽层)
function G_addForbidForSmallDialog(parent, dialogBg, priority, callBack)
    local dialogSize = dialogBg:getContentSize()
    local posX, posY = dialogBg:getPosition()
    
    local leftSize = CCSizeMake(posX - dialogSize.width / 2, G_VisibleSizeHeight)
    local upSize = CCSizeMake(dialogSize.width, G_VisibleSizeHeight - posY - dialogSize.height / 2)
    local downSize = CCSizeMake(dialogSize.width, posY - dialogSize.height / 2)
    
    local function forbidClick()
        if callBack then
            callBack()
        end
    end
    local capInSet = CCRect(20, 20, 10, 10)
    -- 左
    local leftforbidSp = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png", capInSet, forbidClick)
    leftforbidSp:setContentSize(leftSize)
    leftforbidSp:setAnchorPoint(ccp(0, 0))
    parent:addChild(leftforbidSp)
    leftforbidSp:setPosition(0, 0)
    
    -- 右
    local rightforbidSp = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png", capInSet, forbidClick)
    parent:addChild(rightforbidSp)
    rightforbidSp:setContentSize(leftSize)
    rightforbidSp:setAnchorPoint(ccp(1, 0))
    rightforbidSp:setPosition(G_VisibleSizeWidth, 0)
    -- 上
    local upforbidSp = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png", capInSet, forbidClick)
    parent:addChild(upforbidSp)
    upforbidSp:setContentSize(upSize)
    upforbidSp:setAnchorPoint(ccp(0.5, 1))
    upforbidSp:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight)
    -- 下
    local downforbidSp = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png", capInSet, forbidClick)
    parent:addChild(downforbidSp)
    downforbidSp:setContentSize(downSize)
    downforbidSp:setAnchorPoint(ccp(0.5, 0))
    downforbidSp:setPosition(G_VisibleSizeWidth / 2, 0)
    
    leftforbidSp:setTouchPriority(priority)
    rightforbidSp:setTouchPriority(priority)
    upforbidSp:setTouchPriority(priority)
    downforbidSp:setTouchPriority(priority)
    
    leftforbidSp:setVisible(false)
    rightforbidSp:setVisible(false)
    upforbidSp:setVisible(false)
    downforbidSp:setVisible(false)
    
end

function G_getThreePointBg(bgSize, callBack, anchorPoint, pos, parent)
    local function touchBg(hd, fn, idx)
        if callBack then
            callBack(hd, fn, idx)
        end
    end
    local bgSp = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png", CCRect(19, 19, 2, 2), touchBg)
    bgSp:setContentSize(bgSize)
    parent:addChild(bgSp)
    bgSp:setAnchorPoint(anchorPoint or ccp(0.5, 0.5))
    bgSp:setPosition(pos)
    
    -- local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
    -- pointSp1:setPosition(ccp(5,bgSp:getContentSize().height/2))
    -- bgSp:addChild(pointSp1)
    -- local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
    -- pointSp2:setPosition(ccp(bgSp:getContentSize().width-5,bgSp:getContentSize().height/2))
    -- bgSp:addChild(pointSp2)
    
    return bgSp
end

function G_giftAction(...)
    
    local acArr = CCArray:create()
    local time = 0.14
    local leftRotate = CCRotateTo:create(time, 30)
    local rightRotate = CCRotateTo:create(time, -30)
    local leftRotate1 = CCRotateTo:create(time, 20)
    local rightRotate1 = CCRotateTo:create(time, -20)
    local midRotate = CCRotateTo:create(time, 0)
    local delay = CCDelayTime:create(1)
    
    acArr:addObject(leftRotate)
    acArr:addObject(rightRotate)
    acArr:addObject(leftRotate1)
    acArr:addObject(rightRotate1)
    acArr:addObject(midRotate)
    acArr:addObject(delay)
    local giftRotate = CCSequence:create(acArr)
    local giftRepeat = CCRepeatForever:create(giftRotate)
    return giftRepeat
end

--获取战报中配件内容的高度，如果传的cellHeight有值则不计算
function G_getAccessoryReportHeight(report, isAttacker, cellWidth, cellHeight)
    if cellHeight == nil then
        local function cellClick()
        end
        local backSprite = LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png", CCRect(20, 20, 10, 10), cellClick)
        backSprite:setContentSize(CCSizeMake(cellWidth, 50))
        
        local accessory = report.accessory or {}
        local attAccData = {}
        local defAccData = {}
        local isAttacker = isAttacker or false
        if isAttacker == true then
            attAccData = accessory[1] or {}
            defAccData = accessory[2] or {}
        else
            attAccData = accessory[2] or {}
            defAccData = accessory[1] or {}
        end
        local attScore = attAccData[1] or 0
        local defScore = defAccData[1] or 0
        local attTab = attAccData[2] or {0, 0, 0}
        local defTab = defAccData[2] or {0, 0, 0}
        
        for i = 1, 2 do
            local content = {}
            content[i] = {}
            
            local campStr = ""
            local scoreStr = getlocal("report_accessory_score")
            local score = 0
            
            if i == 1 then
                campStr = getlocal("report_accessory_owner")
                score = attScore
                
            elseif i == 2 then
                campStr = getlocal("report_accessory_enemy")
                score = defScore
                
            end
            
            table.insert(content[i], {campStr, G_ColorGreen})
            table.insert(content[i], {scoreStr, G_ColorGreen})
            table.insert(content[i], {score, G_ColorWhite})
            
            local contentLbHight = 60
            for k, v in pairs(content[i]) do
                local contentMsg = v
                local message = ""
                local color
                if type(contentMsg) == "table" then
                    message = contentMsg[1]
                else
                    message = contentMsg
                end
                local contentLb
                contentLb = GetTTFLabelWrap(message, 28, CCSizeMake((backSprite:getContentSize().width - 50) / 2, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                if k == 1 then
                    contentLbHight = contentLbHight + (contentLb:getContentSize().height + 100)
                    if accessoryVoApi:isUpgradeQualityRed() == true or (attTab and SizeOfTable(attTab) >= 5) or (defTab and SizeOfTable(defTab) >= 5) then
                        contentLbHight = contentLbHight + 40
                    end
                elseif k == 2 then
                    contentLbHight = contentLbHight + (contentLb:getContentSize().height + 5)
                else
                    contentLbHight = contentLbHight + (contentLb:getContentSize().height + 25)
                end
            end
            contentLbHight = contentLbHight + 30
            if cellHeight ~= nil and tonumber(cellHeight) ~= nil then
                if tonumber(cellHeight) < contentLbHight then
                    cellHeight = contentLbHight
                end
            else
                cellHeight = contentLbHight
            end
        end
    end
    return cellHeight
end

function G_addAccessoryReport(report, cell, isAttacker, cellWidth, cellHeight, layerNum)
    local function cellClick()
    end
    local backSprite = LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png", CCRect(20, 20, 10, 10), cellClick)
    backSprite:setContentSize(CCSizeMake(cellWidth, 50))
    backSprite:ignoreAnchorPointForPosition(false)
    backSprite:setAnchorPoint(ccp(0, 0))
    backSprite:setIsSallow(false)
    backSprite:setTouchPriority(-(layerNum - 1) * 20 - 2)
    cell:addChild(backSprite, 1)
    
    local titleLabel5 = GetTTFLabel(getlocal("report_accessory_compare"), 30)
    titleLabel5:setPosition(getCenterPoint(backSprite))
    backSprite:addChild(titleLabel5, 2)
    
    local accessory = report.accessory or {}
    local attAccData = {}
    local defAccData = {}
    local isAttacker = isAttacker or false
    if isAttacker == true then
        attAccData = accessory[1] or {}
        defAccData = accessory[2] or {}
    else
        attAccData = accessory[2] or {}
        defAccData = accessory[1] or {}
    end
    local attScore = attAccData[1] or 0
    local defScore = defAccData[1] or 0
    local attTab = attAccData[2] or {0, 0, 0, 0}
    local defTab = defAccData[2] or {0, 0, 0, 0}
    if accessoryVoApi:isUpgradeQualityRed() == true then
        if attTab[5] == nil then
            attTab[5] = 0
        end
        if defTab[5] == nil then
            defTab[5] = 0
        end
    end
    
    local htSpace = 50
    local lbHeight = cellHeight - htSpace
    local lbWidth = backSprite:getContentSize().width / 2 + 10
    
    backSprite:setPosition(ccp(0, cellHeight - backSprite:getContentSize().height))
    
    local function tipTouch()
        local sd = smallDialog:new()
        local dialogLayer = sd:init("TankInforPanel.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, true, true, layerNum + 1, {" ", getlocal("report_accessory_desc"), " "}, 25)
        sceneGame:addChild(dialogLayer, layerNum + 1)
        dialogLayer:setPosition(ccp(0, 0))
    end
    local tipItem = GetButtonItem("BtnInfor.png", "BtnInfor_Down.png", "BtnInfor_Down.png", tipTouch, 11, nil, nil)
    local spScale = 0.7
    tipItem:setScale(spScale)
    local tipMenu = CCMenu:createWithItem(tipItem)
    tipMenu:setPosition(ccp(backSprite:getContentSize().width - tipItem:getContentSize().width / 2 * spScale + 10, cellHeight - 50 - tipItem:getContentSize().height / 2 * spScale + 55))
    tipMenu:setTouchPriority(-(layerNum - 1) * 20 - 2)
    cell:addChild(tipMenu, 1)
    
    for i = 1, 2 do
        local content = {}
        content[i] = {}
        
        local campStr = ""
        local scoreStr = getlocal("report_accessory_score")
        local score = 0
        
        if i == 1 then
            campStr = getlocal("report_accessory_owner")
            score = attScore
        elseif i == 2 then
            campStr = getlocal("report_accessory_enemy")
            score = defScore
        end
        
        table.insert(content[i], {campStr, G_ColorGreen})
        table.insert(content[i], {scoreStr, G_ColorGreen})
        table.insert(content[i], {score, G_ColorWhite})
        
        local contentLbHight = 0
        for k, v in pairs(content[i]) do
            local contentMsg = v
            local message = ""
            local color
            if type(contentMsg) == "table" then
                message = contentMsg[1]
                color = contentMsg[2]
            else
                message = contentMsg
            end
            local contentLb
            contentLb = GetTTFLabelWrap(message, 28, CCSizeMake((backSprite:getContentSize().width - 50) / 2, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
            local contentShowLb
            contentShowLb = GetTTFLabelWrap(message, 28, CCSizeMake((backSprite:getContentSize().width - 50) / 2, 500), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
            contentShowLb:setAnchorPoint(ccp(0, 1))
            if contentLbHight == 0 then
                contentLbHight = cellHeight - 60
            end
            if i == 1 then
                contentShowLb:setPosition(ccp(10, contentLbHight))
            else
                contentShowLb:setPosition(ccp(lbWidth, contentLbHight))
            end
            if k == 1 then
                local accNum = 0
                local accTab = {}
                if i == 1 then
                    accNum = SizeOfTable(attTab)
                    accTab = attTab
                else
                    accNum = SizeOfTable(defTab)
                    accTab = defTab
                end
                if accNum > 0 then
                    for n = 1, accNum do
                        -- if n<accNum or (n==accNum and accTab[n] and accTab[n]>0) then
                        local iWidth
                        if i == 1 then
                            iWidth = 10 + ((n + 1) % 2) * 100
                        else
                            iWidth = lbWidth + ((n + 1) % 2) * 100
                        end
                        local iHeight = contentLbHight - contentLb:getContentSize().height - 25 - math.floor((n - 1) / 2) * 45
                        
                        local iSize = 30
                        
                        local icon = CCSprite:createWithSpriteFrameName("uparrow"..n..".png")
                        local scale = iSize / icon:getContentSize().width
                        -- icon:setAnchorPoint(ccp(0.5,0.5))
                        icon:setScale(scale)
                        icon:setPosition(ccp(iWidth + iSize / 2, iHeight))
                        cell:addChild(icon, 1)
                        
                        local numLb
                        if i == 1 then
                            numLb = GetTTFLabel((attTab[n] or 0), 25)
                        else
                            numLb = GetTTFLabel((defTab[n] or 0), 25)
                        end
                        -- numLb:setAnchorPoint(ccp(0.5,0.5))
                        numLb:setPosition(ccp(iWidth + iSize + 15, iHeight))
                        cell:addChild(numLb, 1)
                        -- end
                    end
                end
            end
            if k == 1 then
                contentLbHight = contentLbHight - (contentLb:getContentSize().height + 100)
                if accessoryVoApi:isUpgradeQualityRed() == true or (attTab and SizeOfTable(attTab) >= 5) or (defTab and SizeOfTable(defTab) >= 5) then
                    contentLbHight = contentLbHight - 40
                end
            elseif k == 2 then
                contentLbHight = contentLbHight - (contentLb:getContentSize().height + 5)
            else
                contentLbHight = contentLbHight - (contentLb:getContentSize().height + 25)
            end
            cell:addChild(contentShowLb, 1)
            if color ~= nil then
                contentShowLb:setColor(color)
            end
        end
    end
end

--军徽战报内容的高度
function G_getEmblemReportHeight()
    return 410
end

--初始化军徽战报
function G_addEmblemReport(report, cell, isAttacker, cellWidth, cellHeight, layerNum)
    local hCellHeight = G_getEmblemReportHeight()
    if cellHeight then
        hCellHeight = cellHeight
    end
    local function cellClick()
    end
    local emblemTitleBg = LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png", CCRect(20, 20, 10, 10), cellClick)
    emblemTitleBg:setContentSize(CCSizeMake(cellWidth, 50))
    emblemTitleBg:ignoreAnchorPointForPosition(false)
    emblemTitleBg:setAnchorPoint(ccp(0, 0))
    emblemTitleBg:setIsSallow(false)
    emblemTitleBg:setTouchPriority(-(layerNum - 1) * 20 - 2)
    cell:addChild(emblemTitleBg, 1)
    emblemTitleBg:setPosition(ccp(0, hCellHeight - 50))
    
    local emblemTitleLb = GetTTFLabel(getlocal("emblem_infoTitle"), 30)
    emblemTitleLb:setPosition(getCenterPoint(emblemTitleBg))
    emblemTitleBg:addChild(emblemTitleLb, 2)
    
    local lineSp = CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setAnchorPoint(ccp(0.5, 0.5))
    lineSp:setPosition(ccp(cellWidth / 2, (hCellHeight - 50) / 2))
    lineSp:setScaleX((hCellHeight - 30) / lineSp:getContentSize().width)
    lineSp:setRotation(90)
    cell:addChild(lineSp, 1)

    local ownerEmblemStr = getlocal("emblem_emailOwn")
    local enemyEmblemStr = getlocal("emblem_emailEnemy")
    local myEmblem, myEmblemCfg, myEmblemSkill, myEmblemStrong
    local enemyEmblem, enemyEmblemCfg, enemyEmblemSkill, enemyEmblemStrong
    
    local emblemData = report.emblemID or {nil, nil}
    local isAttacker = isAttacker or false
    if emblemData then
        if isAttacker == true then
            myEmblem = emblemData[1] ~= 0 and emblemData[1] or nil
            enemyEmblem = emblemData[2] ~= 0 and emblemData[2] or nil
        else
            myEmblem = emblemData[2] ~= 0 and emblemData[2] or nil
            enemyEmblem = emblemData[1] ~= 0 and emblemData[1] or nil
        end
        if myEmblem then
            myEmblemCfg = emblemVoApi:getEquipCfgById(myEmblem)
            myEmblemSkill = myEmblemCfg.skill
            myEmblemStrong = myEmblemCfg.qiangdu
        end
        
        if enemyEmblem then
            enemyEmblemCfg = emblemVoApi:getEquipCfgById(enemyEmblem)
            enemyEmblemSkill = enemyEmblemCfg.skill
            enemyEmblemStrong = enemyEmblemCfg.qiangdu
        end
    end
    
    local ownerEmblemLb = GetTTFLabelWrap(ownerEmblemStr, 28, CCSizeMake(cellWidth / 2 - 20, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    ownerEmblemLb:setAnchorPoint(ccp(0.5, 0.5))
    ownerEmblemLb:setPosition(ccp(cellWidth / 4, hCellHeight - 85))
    cell:addChild(ownerEmblemLb, 2)
    ownerEmblemLb:setColor(G_ColorGreen)
    
    local enemyEmblemLb = GetTTFLabelWrap(enemyEmblemStr, 28, CCSizeMake(cellWidth / 2 - 20, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    enemyEmblemLb:setAnchorPoint(ccp(0.5, 0.5))
    enemyEmblemLb:setPosition(ccp(cellWidth / 4 * 3, hCellHeight - 85))
    cell:addChild(enemyEmblemLb, 2)
    enemyEmblemLb:setColor(G_ColorRed)
    
    local myEmblemIcon
    if myEmblem then
        myEmblemIcon = emblemVoApi:getEquipIcon(myEmblem, nil, nil, nil, myEmblemStrong)
    else
        myEmblemIcon = emblemVoApi:getEquipIconNull()
    end
    myEmblemIcon:setAnchorPoint(ccp(0.5, 0))
    myEmblemIcon:setPosition(ccp(cellWidth / 4, 60))
    cell:addChild(myEmblemIcon)
    
    local enemyEmblemIcon
    if enemyEmblem then
        enemyEmblemIcon = emblemVoApi:getEquipIcon(enemyEmblem, nil, nil, nil, enemyEmblemStrong)
    else
        enemyEmblemIcon = emblemVoApi:getEquipIconNull()
    end
    enemyEmblemIcon:setAnchorPoint(ccp(0.5, 0))
    enemyEmblemIcon:setPosition(ccp(cellWidth / 4 * 3, 60))
    cell:addChild(enemyEmblemIcon)
    
    --我方装备信息（技能+强度）
    if myEmblemSkill ~= nil then
        local mySkillLb = GetTTFLabelWrap(emblemVoApi:getEquipSkillNameById(myEmblemSkill[1], myEmblemSkill[2]), 25, CCSizeMake(cellWidth / 2 - 20, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        mySkillLb:setAnchorPoint(ccp(0.5, 0.5))
        mySkillLb:setPosition(ccp(cellWidth / 4, 30))
        cell:addChild(mySkillLb, 2)
    end
    
    --敌方装备信息（技能+强度）
    if enemyEmblemSkill ~= nil then
        local enemySkillLb = GetTTFLabel(emblemVoApi:getEquipSkillNameById(enemyEmblemSkill[1], enemyEmblemSkill[2]), 25)
        enemySkillLb:setAnchorPoint(ccp(0.5, 0.5))
        enemySkillLb:setPosition(ccp(cellWidth / 4 * 3, 30))--85
        cell:addChild(enemySkillLb, 2)
    end
end

--将领战报的高度
function G_getHeroReportHeight()
    return 530
end

--初始化将领的战报
function G_addHeroReport(report, cell, isAttacker, cellWidth, cellHeight, layerNum)
    local hCellWidth = cellWidth
    local hCellHeight = cellHeight or G_getHeroReportHeight()
    local function cellClick()
    end
    local backSprite = LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png", CCRect(20, 20, 10, 10), cellClick)
    backSprite:setContentSize(CCSizeMake(cellWidth, 50))
    backSprite:ignoreAnchorPointForPosition(false)
    backSprite:setAnchorPoint(ccp(0, 0))
    backSprite:setIsSallow(false)
    backSprite:setTouchPriority(-(layerNum - 1) * 20 - 2)
    cell:addChild(backSprite, 1)
    backSprite:setPosition(ccp(0, hCellHeight - 50))
    
    local titleLabel6 = GetTTFLabel(getlocal("report_hero_message"), 30)
    titleLabel6:setPosition(getCenterPoint(backSprite))
    backSprite:addChild(titleLabel6, 2)
    
    local lineSp = CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setAnchorPoint(ccp(0.5, 0.5))
    lineSp:setPosition(ccp(hCellWidth / 2, (hCellHeight - 50) / 2))
    lineSp:setScaleX((hCellHeight - 30) / lineSp:getContentSize().width)
    lineSp:setRotation(90)
    cell:addChild(lineSp, 1)
    
    local ownerHeroStr = getlocal("report_hero_owner")
    local enemyHeroStr = getlocal("report_hero_enemy")
    local scoreStr = getlocal("report_hero_score")
    
    local myHero = {}
    local enemyHero = {}
    local myScore = 0
    local enemyScore = 0
    local heroData = report.hero or {{{}, 0}, {{}, 0}}
    local isAttacker = isAttacker or false
    if heroData then
        if isAttacker == true then
            if heroData[1] then
                myHero = heroData[1][1] or {}
                myScore = heroData[1][2] or 0
            end
            if heroData[2] then
                enemyHero = heroData[2][1] or {}
                enemyScore = heroData[2][2] or 0
            end
        else
            if heroData[1] then
                enemyHero = heroData[1][1] or {}
                enemyScore = heroData[1][2] or 0
            end
            if heroData[2] then
                myHero = heroData[2][1] or {}
                myScore = heroData[2][2] or 0
            end
        end
    end
    
    local ownerHeroLb = GetTTFLabelWrap(ownerHeroStr, 28, CCSizeMake(hCellWidth / 2 - 20, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    ownerHeroLb:setAnchorPoint(ccp(0.5, 0.5))
    ownerHeroLb:setPosition(ccp(hCellWidth / 4, hCellHeight - 85))
    cell:addChild(ownerHeroLb, 2)
    ownerHeroLb:setColor(G_ColorGreen)
    
    local enemyHeroLb = GetTTFLabelWrap(enemyHeroStr, 28, CCSizeMake(hCellWidth / 2 - 20, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    enemyHeroLb:setAnchorPoint(ccp(0.5, 0.5))
    enemyHeroLb:setPosition(ccp(hCellWidth / 4 * 3, hCellHeight - 85))
    cell:addChild(enemyHeroLb, 2)
    enemyHeroLb:setColor(G_ColorGreen)
    
    for i = 1, 6 do
        local wSpace = 20
        local hSpace = 10
        local iconSize = 90
        local posX = hCellWidth / 4 + iconSize / 2 + wSpace / 2 - math.floor((i - 1) / 3) * (iconSize + wSpace)
        local posY = hCellHeight - iconSize / 2 - ((i - 1) % 3) * (iconSize + hSpace) - 120
        
        local mHid = nil
        local mLevel = nil
        local mProductOrder = nil
        local adjutants = {}
        if myHero and myHero[i] then
            local myHeroArr = Split(myHero[i], "-")
            mHid = myHeroArr[1]
            mLevel = myHeroArr[2]
            mProductOrder = myHeroArr[3]
            adjutants = heroAdjutantVoApi:decodeAdjutant(myHero[i])
        end
        local myIcon = heroVoApi:getHeroIcon(mHid, mProductOrder, false, nil, nil, nil, nil, {adjutants = adjutants, showAjt = true})
        if myIcon then
            myIcon:setScale(iconSize / myIcon:getContentSize().width)
            myIcon:setPosition(ccp(posX, posY))
            cell:addChild(myIcon, 2)
        end
        
        local ehid = nil
        local elevel = nil
        local eproductOrder = nil
        local eadjutants = {}
        if enemyHero and enemyHero[i] then
            local enemyHeroArr = Split(enemyHero[i], "-")
            ehid = enemyHeroArr[1]
            elevel = enemyHeroArr[2]
            eproductOrder = enemyHeroArr[3]
            eadjutants = heroAdjutantVoApi:decodeAdjutant(enemyHero[i])
        end
        posX = hCellWidth / 4 * 3 + iconSize / 2 + wSpace / 2 - math.floor((i - 1) / 3) * (iconSize + wSpace)
        local enemyIcon = heroVoApi:getHeroIcon(ehid, eproductOrder, false, nil, nil, nil, nil, {adjutants = eadjutants, showAjt = true})
        if enemyIcon then
            enemyIcon:setScale(iconSize / myIcon:getContentSize().width)
            enemyIcon:setPosition(ccp(posX, posY))
            cell:addChild(enemyIcon, 2)
        end
    end
    
    local scoreLb1 = GetTTFLabelWrap(scoreStr, 28, CCSizeMake(hCellWidth / 2 - 20, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    scoreLb1:setAnchorPoint(ccp(0.5, 0.5))
    scoreLb1:setPosition(ccp(hCellWidth / 4, 85))
    cell:addChild(scoreLb1, 2)
    scoreLb1:setColor(G_ColorGreen)
    
    local scoreLb2 = GetTTFLabelWrap(scoreStr, 28, CCSizeMake(hCellWidth / 2 - 20, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    scoreLb2:setAnchorPoint(ccp(0.5, 0.5))
    scoreLb2:setPosition(ccp(hCellWidth / 4 * 3, 85))
    cell:addChild(scoreLb2, 2)
    scoreLb2:setColor(G_ColorGreen)
    
    local myScoreLb = GetTTFLabel(myScore, 28)
    myScoreLb:setAnchorPoint(ccp(0.5, 0.5))
    myScoreLb:setPosition(ccp(hCellWidth / 4, 40))
    cell:addChild(myScoreLb, 2)
    
    local enemyScoreLb = GetTTFLabel(enemyScore, 28)
    enemyScoreLb:setAnchorPoint(ccp(0.5, 0.5))
    enemyScoreLb:setPosition(ccp(hCellWidth / 4 * 3, 40))
    cell:addChild(enemyScoreLb, 2)
end

--将领战报的高度
function G_getAITroopsReportHeight()
    return 530
end

--初始化将领的战报
--btype:战斗类型
function G_addAITroopsReport(report, cell, isAttacker, cellWidth, cellHeight, layerNum, btype)
    local hCellWidth = cellWidth
    local hCellHeight = cellHeight or G_getHeroReportHeight()
    local function cellClick()
    end
    local backSprite = LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png", CCRect(20, 20, 10, 10), cellClick)
    backSprite:setContentSize(CCSizeMake(cellWidth, 50))
    backSprite:ignoreAnchorPointForPosition(false)
    backSprite:setAnchorPoint(ccp(0, 0))
    backSprite:setIsSallow(false)
    backSprite:setTouchPriority(-(layerNum - 1) * 20 - 2)
    cell:addChild(backSprite, 1)
    backSprite:setPosition(ccp(0, hCellHeight - 50))
    
    local titleLabel6 = GetTTFLabel(getlocal("aitroopsInformation"), 30)
    titleLabel6:setPosition(getCenterPoint(backSprite))
    backSprite:addChild(titleLabel6, 2)
    
    local lineSp = CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setAnchorPoint(ccp(0.5, 0.5))
    lineSp:setPosition(ccp(hCellWidth / 2, (hCellHeight - 50) / 2))
    lineSp:setScaleX((hCellHeight - 30) / lineSp:getContentSize().width)
    lineSp:setRotation(90)
    cell:addChild(lineSp, 1)
    
    local ownerAITroopsStr = getlocal("report_aitroops_owner")
    local enemyAITroopsStr = getlocal("report_aitroops_enemy")
    local strengthStr = getlocal("aitroops_title")..getlocal("plane_power")
    
    local myAITroops = {}
    local enemyAITroops = {}
    local myStrength = 0
    local enemyStrength = 0
    local aitroopsData = report.aitroops or {{{0, 0, 0, 0, 0, 0}, 0}, {{0, 0, 0, 0, 0, 0}, 0}}
    local isAttacker = isAttacker or false
    if aitroopsData then
        if btype == 6 then
            if aitroopsData[1] then
                myAITroops = aitroopsData[1][1] or {0, 0, 0, 0, 0, 0}
                myStrength = aitroopsData[1][2] or 0
            end
            if aitroopsData[2] then
                enemyAITroops = aitroopsData[2][1] or {0, 0, 0, 0, 0, 0}
                enemyStrength = aitroopsData[2][2] or 0
            end
        else
            if isAttacker == true then
                if aitroopsData[1] then
                    myAITroops = aitroopsData[1][1] or {0, 0, 0, 0, 0, 0}
                    myStrength = aitroopsData[1][2] or 0
                end
                if aitroopsData[2] then
                    enemyAITroops = aitroopsData[2][1] or {0, 0, 0, 0, 0, 0}
                    enemyStrength = aitroopsData[2][2] or 0
                end
            else
                if aitroopsData[1] then
                    enemyAITroops = aitroopsData[1][1] or {0, 0, 0, 0, 0, 0}
                    enemyStrength = aitroopsData[1][2] or 0
                end
                if aitroopsData[2] then
                    myAITroops = aitroopsData[2][1] or {0, 0, 0, 0, 0, 0}
                    myStrength = aitroopsData[2][2] or 0
                end
            end
        end
    end
    
    local ownerHeroLb = GetTTFLabelWrap(ownerAITroopsStr, 28, CCSizeMake(hCellWidth / 2 - 20, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    ownerHeroLb:setAnchorPoint(ccp(0.5, 0.5))
    ownerHeroLb:setPosition(ccp(hCellWidth / 4, hCellHeight - 85))
    cell:addChild(ownerHeroLb, 2)
    ownerHeroLb:setColor(G_ColorGreen)
    
    local enemyHeroLb = GetTTFLabelWrap(enemyAITroopsStr, 28, CCSizeMake(hCellWidth / 2 - 20, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    enemyHeroLb:setAnchorPoint(ccp(0.5, 0.5))
    enemyHeroLb:setPosition(ccp(hCellWidth / 4 * 3, hCellHeight - 85))
    cell:addChild(enemyHeroLb, 2)
    enemyHeroLb:setColor(G_ColorGreen)
    
    for i = 1, 6 do
        local wSpace = 20
        local hSpace = 10
        local iconSize = 90
        local posX = hCellWidth / 4 + iconSize / 2 + wSpace / 2 - math.floor((i - 1) / 3) * (iconSize + wSpace)
        local posY = hCellHeight - iconSize / 2 - ((i - 1) % 3) * (iconSize + hSpace) - 120
        
        local myaitInfo = myAITroops[i]
        if myaitInfo then
            myaitInfo = Split(myaitInfo, "-")
            local atid, lv, grade = myaitInfo[1], myaitInfo[2], (myaitInfo[3] or 1)
            if atid and tonumber(atid) ~= 0 and atid ~= "" and lv then
                local aitroopsIcon = AITroopsVoApi:getAITroopsSimpleIcon(atid, lv, grade, false)
                aitroopsIcon:setPosition(posX, posY)
                aitroopsIcon:setScale(iconSize / aitroopsIcon:getContentSize().width)
                cell:addChild(aitroopsIcon)
            else
                local tankIconBg = CCSprite:createWithSpriteFrameName("troopNull.png")
                tankIconBg:setPosition(ccp(posX, posY))
                tankIconBg:setScale(iconSize / tankIconBg:getContentSize().width)
                cell:addChild(tankIconBg)
            end
        else
            local tankIconBg = CCSprite:createWithSpriteFrameName("troopNull.png")
            tankIconBg:setPosition(ccp(posX, posY))
            tankIconBg:setScale(iconSize / tankIconBg:getContentSize().width)
            cell:addChild(tankIconBg)
        end
        
        posX = hCellWidth / 4 * 3 + iconSize / 2 + wSpace / 2 - math.floor((i - 1) / 3) * (iconSize + wSpace)
        
        local enemyaitInfo = enemyAITroops[i]
        if enemyaitInfo then
            enemyaitInfo = Split(enemyaitInfo, "-")
            local atid, lv, grade = enemyaitInfo[1], enemyaitInfo[2], (enemyaitInfo[3] or 1)
            if atid and tonumber(atid) ~= 0 and atid ~= "" and lv then
                local aitroopsIcon = AITroopsVoApi:getAITroopsSimpleIcon(atid, lv, grade, false)
                aitroopsIcon:setPosition(posX, posY)
                aitroopsIcon:setScale(iconSize / aitroopsIcon:getContentSize().width)
                cell:addChild(aitroopsIcon)
            else
                local tankIconBg = CCSprite:createWithSpriteFrameName("troopNull.png")
                tankIconBg:setPosition(ccp(posX, posY))
                tankIconBg:setScale(iconSize / tankIconBg:getContentSize().width)
                cell:addChild(tankIconBg)
            end
        else
            local tankIconBg = CCSprite:createWithSpriteFrameName("troopNull.png")
            tankIconBg:setPosition(ccp(posX, posY))
            tankIconBg:setScale(iconSize / tankIconBg:getContentSize().width)
            cell:addChild(tankIconBg)
        end
    end
    
    local scoreLb1 = GetTTFLabelWrap(strengthStr, 28, CCSizeMake(hCellWidth / 2 - 20, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    scoreLb1:setAnchorPoint(ccp(0.5, 0.5))
    scoreLb1:setPosition(ccp(hCellWidth / 4, 85))
    cell:addChild(scoreLb1, 2)
    scoreLb1:setColor(G_ColorGreen)
    
    local scoreLb2 = GetTTFLabelWrap(strengthStr, 28, CCSizeMake(hCellWidth / 2 - 20, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    scoreLb2:setAnchorPoint(ccp(0.5, 0.5))
    scoreLb2:setPosition(ccp(hCellWidth / 4 * 3, 85))
    cell:addChild(scoreLb2, 2)
    scoreLb2:setColor(G_ColorGreen)
    
    local myStrengthLb = GetTTFLabel(myStrength, 28)
    myStrengthLb:setAnchorPoint(ccp(0.5, 0.5))
    myStrengthLb:setPosition(ccp(hCellWidth / 4, 40))
    cell:addChild(myStrengthLb, 2)
    
    local enemyStrengthLb = GetTTFLabel(enemyStrength, 28)
    enemyStrengthLb:setAnchorPoint(ccp(0.5, 0.5))
    enemyStrengthLb:setPosition(ccp(hCellWidth / 4 * 3, 40))
    cell:addChild(enemyStrengthLb, 2)
end

--点击屏幕继续的文字提示（也可以加别的提示）
function G_addArrowPrompt(parent, promptStr, lbPosy)
    if parent == nil then
        do return end
    end
    local clickLbPosy = lbPosy or - 80
    local promptStr = promptStr or getlocal("click_screen_continue")
    local tmpLb = GetTTFLabel(promptStr, 25)
    local clickLb = GetTTFLabelWrap(promptStr, 25, CCSizeMake(400, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    clickLb:setPosition(ccp(parent:getContentSize().width / 2, clickLbPosy))
    parent:addChild(clickLb)
    local arrowPosx1, arrowPosx2
    local realWidth, maxWidth = tmpLb:getContentSize().width, clickLb:getContentSize().width
    if realWidth > maxWidth then
        arrowPosx1 = parent:getContentSize().width / 2 - maxWidth / 2
        arrowPosx2 = parent:getContentSize().width / 2 + maxWidth / 2
    else
        arrowPosx1 = parent:getContentSize().width / 2 - realWidth / 2
        arrowPosx2 = parent:getContentSize().width / 2 + realWidth / 2
    end
    local smallArrowSp1 = CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp1:setPosition(ccp(arrowPosx1 - 15, clickLbPosy))
    parent:addChild(smallArrowSp1)
    local smallArrowSp2 = CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp2:setPosition(ccp(arrowPosx1 - 25, clickLbPosy))
    parent:addChild(smallArrowSp2)
    smallArrowSp2:setOpacity(100)
    local smallArrowSp3 = CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp3:setPosition(ccp(arrowPosx2 + 15, clickLbPosy))
    parent:addChild(smallArrowSp3)
    smallArrowSp3:setRotation(180)
    local smallArrowSp4 = CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp4:setPosition(ccp(arrowPosx2 + 25, clickLbPosy))
    parent:addChild(smallArrowSp4)
    smallArrowSp4:setOpacity(100)
    smallArrowSp4:setRotation(180)
    
    local space = 20
    smallArrowSp1:runAction(G_actionArrow(1, space))
    smallArrowSp2:runAction(G_actionArrow(1, space))
    smallArrowSp3:runAction(G_actionArrow(-1, space))
    smallArrowSp4:runAction(G_actionArrow(-1, space))
end

-- commonDialog 下的渐变条
function G_addCommonGradient(parent, posY)
    local fadeBg = LuaCCScale9Sprite:createWithSpriteFrameName("newTopBorder.png", CCRect(110, 0, 1, 42), function ()end)
    fadeBg:setAnchorPoint(ccp(0.5, 1))
    fadeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, 42))
    fadeBg:setPosition(G_VisibleSizeWidth / 2, posY)
    parent:addChild(fadeBg)
    return fadeBg
end

function G_battleWinAni(parent, pCallback, posY)
    local function runWinAni()
        local sunSp = {}
        local tankPic = CCSprite:createWithSpriteFrameName("win_r_tank.png")
        tankPic:setPosition(ccp(G_VisibleSizeWidth * 0.5, posY))
        tankPic:setOpacity(0)
        tankPic:setScale(3)
        parent:addChild(tankPic, 4)
        
        local delayAc = CCDelayTime:create(0.3)
        local delayAc5 = CCDelayTime:create(0.4)
        local fadeIn1 = CCFadeIn:create(0)
        local ScaleAction4 = CCScaleTo:create(0.1, 0.8)
        local ScaleAction5 = CCScaleTo:create(0.08, 1.1)
        local ScaleAction6 = CCScaleTo:create(0.08, 1)
        
        local function roteCall()
            if sunSp[1] then
                sunSp[1]:setVisible(true)
            end
            if sunSp[2] then
                sunSp[2]:setVisible(true)
            end
            if pCallback then
                pCallback()
            end
        end
        -- local function readyShake( )
        --     self:shakingNow()
        -- end
        -- local shakeCall = CCCallFunc:create(readyShake)
        local ccCall = CCCallFunc:create(roteCall)
        local acArr2 = CCArray:create()
        acArr2:addObject(delayAc)
        acArr2:addObject(fadeIn1)
        acArr2:addObject(ScaleAction4)
        acArr2:addObject(ScaleAction5)
        acArr2:addObject(ScaleAction6)
        -- acArr2:addObject(shakeCall)
        acArr2:addObject(delayAc5)
        
        acArr2:addObject(ccCall)
        local seq1 = CCSequence:create(acArr2)
        tankPic:runAction(seq1)
        
        for i = 1, 2 do
            local realLight = CCSprite:createWithSpriteFrameName("win_r_sun"..i..".png")
            realLight:setPosition(ccp(tankPic:getPositionX(), tankPic:getPositionY()))
            parent:addChild(realLight, 2)
            realLight:setVisible(false)
            sunSp[i] = realLight
            
            local roteSize = i == 1 and 360 or - 360
            local rotate1 = CCRotateBy:create(10, roteSize)
            local repeatForever = CCRepeatForever:create(rotate1)
            realLight:runAction(repeatForever)
        end
        
        local tankBg = CCSprite:createWithSpriteFrameName("win_r_1.png")
        tankBg:setPosition(ccp(tankPic:getPositionX(), tankPic:getPositionY() - 50))
        tankBg:setOpacity(0)
        tankBg:setScale(2)
        parent:addChild(tankBg, 3)
        
        local delayAc2 = CCDelayTime:create(0.8)
        local fadeIn2 = CCFadeIn:create(0)
        local pzArr = CCArray:create()
        for kk = 1, 22 do
            local nameStr = "win_r_"..kk..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            -- frame:setScale(1.5)
            pzArr:addObject(frame)
        end
        local animation = CCAnimation:createWithSpriteFrames(pzArr)
        animation:setDelayPerUnit(0.06)
        local animate = CCAnimate:create(animation)
        
        local acArr3 = CCArray:create()
        acArr3:addObject(delayAc2)
        acArr3:addObject(fadeIn2)
        acArr3:addObject(animate)
        local seq2 = CCSequence:create(acArr3)
        tankBg:runAction(seq2)
    end
    G_addResource8888(runWinAni)
end
function G_battleLoseAni(parent, pCallback, posY)
    local function runCloseAni()
        local tankBg = CCSprite:createWithSpriteFrameName("loseR_3.png")
        local lastPosY = posY
        tankBg:setPosition(ccp(G_VisibleSizeWidth * 0.5, lastPosY))
        tankBg:setVisible(false)
        parent:addChild(tankBg, 5)
        
        local loseAniPic2 = CCSprite:createWithSpriteFrameName("loseR_1.png")--翅膀
        loseAniPic2:setPosition(ccp(G_VisibleSizeWidth * 0.5, lastPosY + 300))
        loseAniPic2:setScale(5)
        loseAniPic2:setOpacity(0)
        parent:addChild(loseAniPic2, 4)
        
        local loseAniPic1 = CCSprite:createWithSpriteFrameName("loseR_2.png")--坦克
        loseAniPic1:setPosition(ccp(G_VisibleSizeWidth * 0.5, lastPosY + 300))
        parent:addChild(loseAniPic1, 4)
        
        local delayAc1 = CCDelayTime:create(0.3)
        local fadeIn1 = CCFadeIn:create(0.25)
        local movTo1 = CCMoveTo:create(0.25, ccp(G_VisibleSizeWidth * 0.5, lastPosY))
        local scal1 = CCScaleTo:create(0.25, 1)
        local arr1 = CCArray:create()
        arr1:addObject(fadeIn1)
        arr1:addObject(movTo1)
        arr1:addObject(scal1)
        local spawn1 = CCSpawn:create(arr1)
        local seq1 = CCSequence:createWithTwoActions(delayAc1, spawn1)
        loseAniPic2:runAction(seq1)
        
        local delayAc2 = CCDelayTime:create(0.5)
        local movTo2 = CCMoveTo:create(0.25, ccp(G_VisibleSizeWidth * 0.5, lastPosY))
        local rotate1 = CCRotateTo:create(0.1, 10)
        local rotate2 = CCRotateTo:create(0.1, -10)
        local rotate3 = CCRotateTo:create(0.05, 5)
        local rotate4 = CCRotateTo:create(0.05, -5)
        local rotate5 = CCRotateTo:create(0.05, 0)
        local function roteCall()
            tankBg:setVisible(true)
            loseAniPic1:setVisible(false)
            loseAniPic2:setVisible(false)
            if pCallback then
                pCallback()
            end
        end
        local ccCall = CCCallFunc:create(roteCall)
        local arr2 = CCArray:create()
        arr2:addObject(delayAc2)
        arr2:addObject(movTo2)
        arr2:addObject(rotate1)
        arr2:addObject(rotate2)
        arr2:addObject(rotate3)
        arr2:addObject(rotate4)
        arr2:addObject(rotate5)
        arr2:addObject(ccCall)
        local seq2 = CCSequence:create(arr2)
        loseAniPic1:runAction(seq2)
    end
    G_addResource8888(runCloseAni)
end

function G_getNewDialogBg3(size, titleStr, titleSize, callback, layerNum, isShowClose, closeCallBack, titleColor, isBold)
    local function touchHandler()
        if callback then
            callback()
        end
    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("newSmallPanelBg3.png", CCRect(121, 44, 1, 1), touchHandler)
    dialogBg:setContentSize(size)
    local titleBg = LuaCCScale9Sprite:createWithSpriteFrameName("newTitleBg3.png", CCRect(73, 20, 1, 1), function ()end)
    -- CCSprite:createWithSpriteFrameName("newTitleBg3.png")
    titleBg:setContentSize(CCSizeMake(322, titleBg:getContentSize().height))
    titleBg:setAnchorPoint(ccp(0.5, 1))
    titleBg:setPosition(size.width / 2, size.height)
    dialogBg:addChild(titleBg)
    local titleLb
    if titleStr and titleSize then
        titleLb = GetTTFLabelWrap(titleStr, titleSize, CCSizeMake(size.width - 40, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, isBold and "Helvetica-bold" or nil)
        titleLb:setPosition(getCenterPoint(titleBg))
        titleBg:addChild(titleLb)
        if titleColor then
            titleLb:setColor(titleColor)
        end
    end
    
    local closeBtn, closeBtnItem
    if isShowClose and isShowClose == true then
        local function close()
            PlayEffect(audioCfg.mouseClick)
            if closeCallBack then
                closeCallBack()
            end
        end
        closeBtnItem = GetButtonItem("newCloseBtn.png", "newCloseBtn_Down.png", "newCloseBtn.png", close, nil, nil, nil);
        closeBtnItem:setPosition(ccp(0, 0))
        closeBtnItem:setAnchorPoint(CCPointMake(0, 0))
        
        closeBtn = CCMenu:createWithItem(closeBtnItem)
        closeBtn:setTouchPriority(-(layerNum - 1) * 20 - 8)
        closeBtn:setPosition(ccp(size.width - closeBtnItem:getContentSize().width - 4, size.height - closeBtnItem:getContentSize().height - 4))
        dialogBg:addChild(closeBtn, 2)
    end
    
    return dialogBg, titleBg, titleLb, closeBtnItem, closeBtn
end

function G_getFormatDate(time, withMonth, withYear)
    local function getStr(value)
        if tonumber(value) < 10 then
            return "0"..tostring(value)
        end
        return tostring(value)
    end
    local date = G_getDate(time)
    local hour = getStr(date["hour"])
    local min = getStr(date["min"])
    if withMonth and withMonth == true then
        local month = getStr(date["month"])
        local day = getStr(date["day"])
        return getlocal("day_time", {month, day, hour, min})
    end
    if withYear and withYear == true then
        local year = date["year"]
        local month = getStr(date["month"])
        local day = getStr(date["day"])
        return getlocal("note_time", {year, month, day, hour, min})
    end
    return getlocal("timeLabel2", {hour, min})
end

--获取一个有渐变条的标题条
function G_getTitleFadeBg(target, size)
    local function nilFunc()
    end
    local fadeBg = LuaCCScale9Sprite:createWithSpriteFrameName("titleFadeBg.png", CCRect(5, 0, 4, 10), nilFunc)
    fadeBg:setContentSize(size)
    target:addChild(fadeBg)
    
    local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("newItemKuang2.png", CCRect(2, 2, 1, 1), nilFunc)
    lineSp:setContentSize(CCSizeMake(4, size.height))
    lineSp:setAnchorPoint(ccp(0, 0.5))
    lineSp:setPosition(0, size.height / 2)
    fadeBg:addChild(lineSp)
    
    return fadeBg
end

--skinId坦克涂装id，如果不传取玩家自身的坦克涂装数据
function G_addTankById(tankid, priority, callback, isaddName, parent, skinId)
    local tankId = tonumber(tonumber(tankid) or RemoveFirstChar(tankid))
    
    local function touchMostTank()
        if callback then
            callback()
        end
    end
    -- local orderId=GetTankOrderByTankId(tonumber(tankId))
    -- local tankStr="t"..orderId.."_1.png"
    local tskinId = skinId or tankSkinVoApi:getEquipSkinByTankId(tankId)
    local tankSp
    if tskinId and tonumber(tskinId) ~= 0 and tostring(tskinId) ~= "" then
        tankSp = tankVoApi:getTankIconSp(tankId, tskinId, touchMostTank, false)
    else
        local tankIconPic = tankCfg[tankId].icon
        tankSp = LuaCCSprite:createWithSpriteFrameName(tankIconPic, touchMostTank)
    end
    tankSp:setScale(0.8)
    if priority then
        tankSp:setTouchPriority(priority)
    end
    -- dialogBg2:addChild(tankSp)
    -- tankSp:setPosition(dialogBg2:getContentSize().width/2,dialogBg2:getContentSize().height/2-10)
    
    -- local tankBarrel="t"..orderId.."_1_1.png"  --炮管 第6层
    -- local tankBarrelSP=CCSprite:createWithSpriteFrameName(tankBarrel)
    -- if tankBarrelSP then
    --     tankBarrelSP:setPosition(ccp(tankSp:getContentSize().width*0.5,tankSp:getContentSize().height*0.5))
    --     tankBarrelSP:setAnchorPoint(ccp(0.5,0.5))
    --     tankSp:addChild(tankBarrelSP)
    -- end
    -- print("++++++tankId",tankId)
    tankSp:setPosition(parent:getContentSize().width / 2, parent:getContentSize().height / 2)
    
    -- if tankId==20155 then
    -- tankSp:setPosition(parent:getContentSize().width/2,parent:getContentSize().height/2-15)
    -- end
    
    if isaddName then
        local nameStr = getlocal(tankCfg[tankId].name)
        local nameLb = GetTTFLabelWrap(nameStr, 22, CCSizeMake(tankSp:getContentSize().width + 6, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
        nameLb:setAnchorPoint(ccp(0.5, 1))
        tankSp:addChild(nameLb)
        nameLb:setPosition(tankSp:getContentSize().width / 2, 5)
        nameLb:setScale(1 / tankSp:getScale())
        -- if tankId==20155 then
        -- nameLb:setPosition(tankSp:getContentSize().width/2,40)
        -- end
        
    end
    return tankSp
end

-- anchorpoint flag 1:1 2:0.5 3:0
function G_addForbidForSmallDialog2(parent, tvBg, priority, callBack, flag)
    local dialogSize = tvBg:getContentSize()
    local posX, posY = tvBg:getPosition()
    
    local upPosY
    local downPosY
    local leftPosX = posX - dialogSize.width / 2
    local rightPosX = posX + dialogSize.width / 2
    if flag == 1 then
        upPosY = posY
        downPosY = posY - dialogSize.height
    elseif flag == 2 then
        upPosY = posY + dialogSize.height / 2
        downPosY = posY - dialogSize.height / 2
    else
        upPosY = posY + dialogSize.height
        downPosY = posY
    end
    
    local function forbidClick()
        if callBack then
            callBack()
        end
    end
    local capInSet = CCRect(20, 20, 10, 10)
    -- 左
    local leftforbidSp = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png", capInSet, forbidClick)
    leftforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    leftforbidSp:setAnchorPoint(ccp(1, 0))
    parent:addChild(leftforbidSp)
    leftforbidSp:setPosition(leftPosX, 0)
    
    -- 右
    local rightforbidSp = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png", capInSet, forbidClick)
    parent:addChild(rightforbidSp)
    rightforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    rightforbidSp:setAnchorPoint(ccp(0, 0))
    rightforbidSp:setPosition(rightPosX, 0)
    -- 上
    local upforbidSp = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png", capInSet, forbidClick)
    parent:addChild(upforbidSp)
    upforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    upforbidSp:setAnchorPoint(ccp(0.5, 0))
    upforbidSp:setPosition(G_VisibleSizeWidth / 2, upPosY)
    -- 下
    local downforbidSp = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png", capInSet, forbidClick)
    parent:addChild(downforbidSp)
    downforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    downforbidSp:setAnchorPoint(ccp(0.5, 1))
    downforbidSp:setPosition(G_VisibleSizeWidth / 2, downPosY)
    
    leftforbidSp:setTouchPriority(priority)
    rightforbidSp:setTouchPriority(priority)
    upforbidSp:setTouchPriority(priority)
    downforbidSp:setTouchPriority(priority)
    
    leftforbidSp:setVisible(false)
    rightforbidSp:setVisible(false)
    upforbidSp:setVisible(false)
    downforbidSp:setVisible(false)
end

function G_decodeMap(str)
    local tmpTb = {}
    tmpTb["action"] = "compressMD5"
    tmpTb["parms"] = {}
    tmpTb["parms"]["type"] = "decode"
    local cjson = G_Json.encode(tmpTb)
    return G_accessCPlusFunction(cjson)
end

function G_encodeMap(str)
    local tmpTb = {}
    tmpTb["action"] = "compressMD5"
    tmpTb["parms"] = {}
    tmpTb["parms"]["value"] = "encode"
    local cjson = G_Json.encode(tmpTb)
    return G_accessCPlusFunction(cjson)
end

function G_addBlackLayer(parent, opcity)
    local clayer = CCLayerColor:create(ccc4(0, 0, 0, opcity))
    parent:addChild(clayer)
    clayer:setPosition(0, 0)
end

function G_showNewSureSmallDialog(layerNum, istouch, isuseami, titleStr, contentDes, pCallback)
    require "luascript/script/game/scene/gamedialog/newShowSureSmallDialog"
    local sureDialog = newShowSureSmallDialog:showNewSure(layerNum, istouch, isuseami, titleStr, contentDes, pCallback)
    return sureDialog
end

--创建一个红点提示
function G_createTipSp(target, pos, scale, visible)
    if target == nil then
        do return nil end
    end
    local scale = scale or 0.6
    local pos = pos or ccp(target:getContentSize().width - 15, target:getContentSize().height - 15)
    local visible = visible or false
    local freeTipSp = CCSprite:createWithSpriteFrameName("NumBg.png")
    freeTipSp:setScale(scale)
    freeTipSp:setPosition(pos)
    freeTipSp:setVisible(visible)
    target:addChild(freeTipSp, 1)
    
    return freeTipSp
end

--获取一个坐标的标签
function G_getCoordinateLb(target, coords, fontSize, callback, priority, underlineFlag)
    local coordinateLb = GetTTFLabel(getlocal("alienMines_coordinate", {coords.x, coords.y}), fontSize)
    coordinateLb:setTag(101)
    target:addChild(coordinateLb)
    underlineFlag = underlineFlag or true
    if underlineFlag == true then
        local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("croodsline.png", CCRect(4, 0, 1, 1), function () end)
        lineSp:setContentSize(CCSizeMake(coordinateLb:getContentSize().width, 2))
        lineSp:setPosition(coordinateLb:getContentSize().width / 2, -1)
        coordinateLb:addChild(lineSp)
    end
    if callback then
        local function touchHandler()
            if G_checkClickEnable() == false then
                do
                    return
                end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            callback()
        end
        local touchAreaSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), touchHandler)
        touchAreaSp:setTouchPriority(priority)
        local rect = CCSizeMake(coordinateLb:getContentSize().width + 10, coordinateLb:getContentSize().height + 10)
        touchAreaSp:setTag(99)
        touchAreaSp:setContentSize(rect)
        touchAreaSp:setOpacity(0)
        touchAreaSp:setPosition(getCenterPoint(coordinateLb))
        coordinateLb:addChild(touchAreaSp)
    end
    
    return coordinateLb
end

--更新坐标标签
function G_updateCoordinateLb(target, coords)
    if target then
        local coordinateLb = tolua.cast(target:getChildByTag(101), "CCLabelTTF")
        if coordinateLb then
            coordinateLb:setString(getlocal("alienMines_coordinate", {coords.x, coords.y}))
            local touchAreaSp = tolua.cast(coordinateLb:getChildByTag(99), "LuaCCScale9Sprite")
            if touchAreaSp then
                touchAreaSp:setContentSize(coordinateLb:getContentSize().width + 10, coordinateLb:getContentSize().height + 10)
            end
        end
    end
end

--有些地方需要领土争夺战段位提升的爆炸效果，故写了个方法
function G_playBoomAction(target, pos, callback, dt, scale)
    if target == nil then
        do return end
    end
    G_addResource8888(function()
        spriteController:addPlist("public/ltzdz/ltzdzSegUpImgs.plist")
        spriteController:addTexture("public/ltzdz/ltzdzSegUpImgs.png")
    end)
    
    local targetScale = scale or 3.5
    local frameSp = CCSprite:createWithSpriteFrameName("tisheng1.png")
    local frameArr = CCArray:create()
    for k = 1, 10 do
        local nameStr = "tisheng"..k..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        frameArr:addObject(frame)
    end
    local animation = CCAnimation:createWithSpriteFrames(frameArr)
    animation:setDelayPerUnit(0.1)
    local animate = CCAnimate:create(animation)
    frameSp:setAnchorPoint(ccp(0.5, 0.5))
    frameSp:setPosition(pos)
    frameSp:setScale(targetScale)
    target:addChild(frameSp)
    
    local blendFunc = ccBlendFunc:new()
    blendFunc.src = GL_ONE
    blendFunc.dst = GL_ONE_MINUS_SRC_COLOR
    frameSp:setBlendFunc(blendFunc)
    local function showSp()
        frameSp:setOpacity(255)
    end
    local function removeSp()
        frameSp:removeFromParentAndCleanup(true)
        spriteController:removePlist("public/ltzdz/ltzdzSegUpImgs.plist")
        spriteController:removeTexture("public/ltzdz/ltzdzSegUpImgs.png")
    end
    local showCallFunc = CCCallFuncN:create(showSp)
    local removeCallFunc = CCCallFuncN:create(removeSp)
    local acArr = CCArray:create()
    acArr:addObject(showCallFunc)
    acArr:addObject(animate)
    acArr:addObject(removeCallFunc)
    local seq = CCSequence:create(acArr)
    frameSp:runAction(seq)
    
    local acArr2 = CCArray:create()
    if dt and dt > 0 then
        local delayAction = CCDelayTime:create(dt)
        acArr2:addObject(delayAction)
    end
    local function playEnd()
        if callback then
            callback()
        end
    end
    local endCallBack = CCCallFuncN:create(playEnd)
    acArr2:addObject(endCallBack)
    local seq2 = CCSequence:create(acArr2)
    target:runAction(seq2)
end

--获取一个精灵的世界坐标和尺寸（默认中心点坐标）,用于教学引导获取显示元素的坐标和尺寸(anchorFlag--> 1：左下角)
function G_getSpriteWorldPosAndSize(sprite, anchorFlag, parent)
    if sprite == nil then
        return nil, nil
    end
    local worldPos = sprite:getParent():convertToWorldSpace(ccp(sprite:getPosition()))
    if parent then
        worldPos = parent:convertToWorldSpace(ccp(sprite:getPosition()))
    end
    local size = sprite:getContentSize()
    local scaleX, scaleY = sprite:getScaleX(), sprite:getScaleY()
    local width, height = size.width * scaleX, size.height * scaleY
    local anchor = sprite:getAnchorPoint()
    local x, y = worldPos.x + width * (0.5 - anchor.x), worldPos.y + height * (0.5 - anchor.y)
    if anchorFlag and anchorFlag == 1 then
        x, y = (x - width * 0.5), (y - height * 0.5)
    end
    -- print("x,y,width,height---》".."{"..x..","..y..","..width..","..height.."}")
    return x, y, width, height
end

function G_LabelTableViewNew(size, content, fontSize, alignment, color, hspace, rich, realSizeFlag)
    local kCCTextAlignment = alignment or kCCTextAlignmentLeft
    local fontSize = fontSize or 22
    local fontColor = color or G_ColorWhite
    local richFlag = rich or false
    local hspace = hspace or 0
    local cellHeight = 0
    if content and type(content) == "table" then
        for k, v in pairs(content) do
            local str, color, fs, richFlag = v[1], (v[2] or fontColor), (v[3] or fontSize), (v[4] or richFlag)
            if richFlag == true then
                local descLb, lbheight = G_getRichTextLabel(str, {}, fs, size.width, kCCTextAlignment, kCCVerticalTextAlignmentCenter, hspace)
                cellHeight = cellHeight + lbheight
                if k > 1 then
                    cellHeight = cellHeight + hspace
                end
            else
                local descLb = GetTTFLabelWrap(str, fs, CCSizeMake(size.width, 0), kCCTextAlignment, kCCVerticalTextAlignmentCenter)
                cellHeight = cellHeight + descLb:getContentSize().height
                if k > 1 then
                    cellHeight = cellHeight + hspace
                end
            end
        end
    else
        if richFlag == true then
            local descLb, lbheight = G_getRichTextLabel(content, {}, fontSize, size.width, kCCTextAlignment, kCCVerticalTextAlignmentCenter, hspace)
            cellHeight = cellHeight + lbheight
        else
            local descLb = GetTTFLabelWrap(content, fontSize, CCSizeMake(size.width, 0), kCCTextAlignment, kCCVerticalTextAlignmentCenter)
            cellHeight = cellHeight + descLb:getContentSize().height
        end
    end
    
    local function eventHandler(handler, fn, idx, cel)
        if fn == "numberOfCellsInTableView" then
            return 1
        elseif fn == "tableCellSizeForIndex" then
            local tmpSize = CCSizeMake(size.width, cellHeight)
            return tmpSize
        elseif fn == "tableCellAtIndex" then
            local cell = CCTableViewCell:new()
            cell:autorelease()
            
            local lbPosx, lbPosy = 0, cellHeight
            if content and type(content) == "table" then
                for k, v in pairs(content) do
                    local str, color, fs, richFlag = v[1], (v[2] or fontColor), (v[3] or fontSize), (v[4] or richFlag)
                    if richFlag == true then
                        lbPosx = 0
                        local colorTb = {}
                        if type(color) ~= "table" then
                            colorTb = {color}
                        else
                            colorTb = color
                        end
                        local descLb, lbheight = G_getRichTextLabel(str, colorTb, fs, size.width, kCCTextAlignment, kCCVerticalTextAlignmentCenter, hspace)
                        descLb:setAnchorPoint(ccp(0, 1))
                        descLb:setPosition(lbPosx, lbPosy)
                        cell:addChild(descLb)
                        lbPosy = lbPosy - lbheight
                    else
                        local anchor = ccp(0, 0.5)
                        if kCCTextAlignment == kCCTextAlignmentCenter then
                            lbPosx = size.width / 2
                            anchor = ccp(0.5, 0.5)
                        end
                        local descLb = GetTTFLabelWrap(str, fs, CCSizeMake(size.width, 0), kCCTextAlignment, kCCVerticalTextAlignmentCenter)
                        descLb:setAnchorPoint(anchor)
                        descLb:setPosition(lbPosx, lbPosy - descLb:getContentSize().height / 2)
                        descLb:setColor(color)
                        cell:addChild(descLb)
                        lbPosy = lbPosy - descLb:getContentSize().height - hspace
                    end
                end
            else
                if richFlag == true then
                    local colorTb = {}
                    if type(fontColor) ~= "table" then
                        colorTb = {fontColor}
                    else
                        colorTb = fontColor
                    end
                    local descLb, lbheight = G_getRichTextLabel(content, colorTb, fontSize, size.width, kCCTextAlignment, kCCVerticalTextAlignmentCenter, hspace)
                    descLb:setAnchorPoint(ccp(0, 1))
                    descLb:setPosition(lbPosx, lbPosy + lbheight / 2)
                    cell:addChild(descLb)
                else
                    local anchor = ccp(0, 0.5)
                    if kCCTextAlignment == kCCTextAlignmentCenter then
                        lbPosx = size.width / 2
                        anchor = ccp(0.5, 0.5)
                    end
                    local descLb = GetTTFLabelWrap(content, fontSize, CCSizeMake(size.width, 0), kCCTextAlignment, kCCVerticalTextAlignmentCenter)
                    descLb:setAnchorPoint(anchor)
                    descLb:setPosition(lbPosx, lbPosy - descLb:getContentSize().height / 2)
                    descLb:setColor(fontColor)
                    cell:addChild(descLb)
                end
            end
            
            return cell
        elseif fn == "ccTouchBegan" then
            return true
        elseif fn == "ccTouchMoved" then
        elseif fn == "ccTouchEnded" then
        end
    end
    
    local tvHeight = size.height
    if realSizeFlag == true then
        if cellHeight < tvHeight then
            tvHeight = cellHeight
        end
    end
    local function callBack(...)
        return eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    local tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(size.width, tvHeight), nil)
    return tv, cellHeight, tvHeight
end

function G_getContentScaleFactor()
    local tmpTb = {}
    tmpTb["action"] = "contentScaleFactor"
    tmpTb["parms"] = {}
    local cjson = G_Json.encode(tmpTb)
    local bInRetinaMode = G_accessCPlusFunction(cjson)
    return bInRetinaMode
end

--设置部队页面的统一背景
function G_getTroopsBg(size, offestH)
    local troopsBg = LuaCCScale9Sprite:createWithSpriteFrameName("st_background.png", CCRect(5, 5, 1, 1), function ()end)
    troopsBg:setContentSize(size)
    troopsBg:setAnchorPoint(ccp(0.5, 1))
    
    local upLineSp = CCSprite:createWithSpriteFrameName("LineCross.png")
    upLineSp:setScaleX(size.width / upLineSp:getContentSize().width)
    upLineSp:setPosition(G_VisibleSizeWidth / 2, size.height)
    troopsBg:addChild(upLineSp)
    
    local bottomLineSp = CCSprite:createWithSpriteFrameName("LineCross.png")
    bottomLineSp:setScaleX(size.width / bottomLineSp:getContentSize().width)
    bottomLineSp:setPosition(G_VisibleSizeWidth / 2, 0)
    troopsBg:addChild(bottomLineSp)
    
    local frameOffestH = offestH or 0
    
    local leftFrameBg2 = CCSprite:createWithSpriteFrameName("st_frameBg2.jpg")
    leftFrameBg2:setAnchorPoint(ccp(0, 0.5))
    leftFrameBg2:setPosition(ccp(0, size.height / 2 + frameOffestH))
    troopsBg:addChild(leftFrameBg2)
    local rightFrameBg2 = CCSprite:createWithSpriteFrameName("st_frameBg2.jpg")
    rightFrameBg2:setFlipX(true)
    rightFrameBg2:setFlipY(true)
    rightFrameBg2:setAnchorPoint(ccp(1, 0.5))
    rightFrameBg2:setPosition(size.width, size.height / 2 + frameOffestH)
    troopsBg:addChild(rightFrameBg2)
    local leftFrameBg1 = CCSprite:createWithSpriteFrameName("st_frameBg1.png")
    leftFrameBg1:setAnchorPoint(ccp(0, 0.5))
    leftFrameBg1:setPosition(ccp(0, size.height / 2 + frameOffestH))
    troopsBg:addChild(leftFrameBg1)
    local rightFrameBg1 = CCSprite:createWithSpriteFrameName("st_frameBg1.png")
    rightFrameBg1:setFlipX(true)
    rightFrameBg1:setAnchorPoint(ccp(1, 0.5))
    rightFrameBg1:setPosition(ccp(size.width, size.height / 2 + frameOffestH))
    troopsBg:addChild(rightFrameBg1)
    
    return troopsBg
end

--前端合并奖励
function G_mergeAllRewards(rewardTb)
    local rewardlist = {}
    local total = {}
    for k, v in pairs(rewardTb) do
        for kk, vv in pairs(v) do
            if total[kk] then
                for m, n in pairs(vv) do
                    table.insert(total[kk], n)
                end
            else
                total[kk] = vv
            end
        end
    end
    
    for k, v in pairs(total) do
        rewardlist[k] = {}
        local reward = {}
        for m, n in pairs(v) do
            if m ~= nil and n ~= nil then
                local key, num, index
                for i, j in pairs(n) do
                    if i == "index" then
                        index = j
                        if reward[key] then
                            reward[key][2] = index
                        else
                            reward[key] = {0, index}
                        end
                    else
                        key, num = i, j
                        if reward[key] then
                            reward[key][1] = (reward[key][1] or 0) + num
                        else
                            reward[key] = {num}
                        end
                    end
                end
            end
        end
        for key, value in pairs(reward) do
            local item = {}
            if value[1] then
                item[key] = value[1]
            end
            if value[2] then
                item["index"] = value[2]
            end
            table.insert(rewardlist[k], item)
        end
    end
    return rewardlist
end

--合并formatItem之后的奖励
function G_mergeAllFormatRewards(rewardTb, sortByIndex)
    local rewardlist = {}
    local total = {}
    for k, v in pairs(rewardTb) do
        for kk, item in pairs(v) do
            table.insert(total, item)
        end
    end
    local mergeTb = {}
    for k, v in pairs(total) do
        if mergeTb[v.key] then
            mergeTb[v.key].num = mergeTb[v.key].num + v.num
        else
            mergeTb[v.key] = v
        end
    end
    for k, v in pairs(mergeTb) do
        table.insert(rewardlist, v)
    end
    if rewardlist and SizeOfTable(rewardlist) > 0 then
        local function sortAsc(a, b)
            if sortByIndex then
                if a.index and b.index and tonumber(a.index) and tonumber(b.index) then
                    return a.index < b.index
                end
            else
                if a.type == b.type then
                    if a.index and b.index and tonumber(a.index) and tonumber(b.index) then
                        return a.index < b.index
                    end
                end
            end
        end
        table.sort(rewardlist, sortAsc)
    end
    
    return rewardlist
end

--播放宝箱后面的闪光效果
function G_playShineEffect(target, pos, scale, zorder)
    if target == nil then
        do return end
    end
    local scale = scale or 1
    local zorder = zorder or 0
    local guangSp1 = CCSprite:createWithSpriteFrameName("equipShine.png")
    guangSp1:setPosition(pos)
    target:addChild(guangSp1, zorder)
    local guangSp2 = CCSprite:createWithSpriteFrameName("equipShine.png")
    guangSp2:setPosition(pos)
    target:addChild(guangSp2, zorder)
    guangSp1:setScale(scale)
    guangSp2:setScale(scale)
    local rotateBy = CCRotateBy:create(4, 360)
    local reverseBy = rotateBy:reverse()
    guangSp1:runAction(CCRepeatForever:create(rotateBy))
    guangSp2:runAction(CCRepeatForever:create(reverseBy))
    
    return guangSp1, guangSp2
end

function G_isAsia()--判断是否为亚洲文字（一般情况下，文字适配亚洲文字为一种情况，其他国家文字为一种情况）
    local curLan = G_getCurChoseLanguage()
    if curLan == "cn" or curLan == "tw" or curLan == "ja" or curLan == "ko" then
        return true
    end
    return false
end

function G_acGetItem(key)
    local name = ""
    local pic = ""
    local desc = ""
    local id = 0
    local index = 0
    local eType = ""
    local equipId
    local bgname = ""--icon背景图名称
    local arr = Split(key, "_")
    if arr and #arr >= 2 then -- arr[1] 活动的key，arr[2] 活动道具的id
        id = arr[2]
        eType = string.sub(id, 1, 1)
        local acVo = activityVoApi:getActivityVo(arr[1])
        if acVo and activityVoApi:isStart(acVo) == true then
            local voApi = activityVoApi:getVoApiByType(arr[1])
            if voApi and voApi.getActivePropInfo then
                local pinfo = voApi:getActivePropInfo(key, id)
                name = pinfo.name or ""
                desc = pinfo.desc or ""
                pic = pinfo.pic or "Icon_BG.png"
                bgname = pinfo.bgname or "Icon_BG.png"
            end
        end
    else
        eType = string.sub(key, 1, 1)
        if eType == "m" then --情人节活动礼盒
            local eValue = string.sub(key, 2)
            if acLmqrjVoApi then
                local boxData = acLmqrjVoApi:getBoxItem(tonumber(eValue))
                name = boxData.name
                -- pic=组合拼装的icon
                desc = boxData.desc
            end
        elseif eType == "c" then -- 春节活动奖券
            if acXcjhVoApi and activityVoApi:isStart(acXcjhVoApi:getAcVo()) == true then
                name, desc = acXcjhVoApi:getAcNameAndDesc(key)
                pic = acXcjhVoApi:getActivePropImg(key)
                if key == "c1" or key == "c3" then
                    bgname = "equipBg_orange.png"
                elseif key == "c2" or key == "c4" then
                    bgname = "equipBg_purple.png"
                else
                end
            end
        elseif eType == "a" then
            if key == "a1" and acXlpdVoApi and activityVoApi:isStart(acXlpdVoApi:getAcVo()) == true then
                local itemData = acXlpdVoApi:getAcNameAndDesc()
                if itemData then
                    name = itemData.name
                    desc = itemData.desc
                    pic = itemData.pic
                    bgname = itemData.bgname
                end
            end
            if key == "a2" and acXssd2019VoApi and activityVoApi:isStart(acXssd2019VoApi:getAcVo()) == true then
                local itemData = acXssd2019VoApi:getAcNameAndDesc()
                if itemData then
                    name = itemData.name
                    desc = itemData.desc
                    pic = itemData.pic
                    bgname = itemData.bgname
                end
            end
        elseif eType == "b" then --军令币
            if militaryOrdersVoApi then
                local itemData = militaryOrdersVoApi:getItemData(key)
                if itemData then
                    name = itemData.name
                    desc = itemData.desc
                    pic = itemData.pic
                end
            end
        elseif eType == "o" then --周年狂欢2019活动数字道具
            if acZnkh19VoApi and activityVoApi:isStart(acZnkh19VoApi:getAcVo()) == true then
                pic, bgname, name, desc = acZnkh19VoApi:getNumeralPropShowInfo(key)
                bgname = ""
            end
        end
    end
    
    return name, pic, desc, id, index, eType, equipId, bgname
end

function G_acGetItemIcon(key, showInfoHandler, item)
    local icon
    local arr = Split(key, "_")
    if arr and #arr >= 2 then -- arr[1] 活动的key，arr[2] 活动道具的id
        local acVo = activityVoApi:getActivityVo(arr[1])
        if acVo and activityVoApi:isStart(acVo) == true then
            local voApi = activityVoApi:getVoApiByType(arr[1])
            if voApi and voApi.getActivePropIcon then
                icon = voApi:getActivePropIcon(item, showInfoHandler)
            end
            if icon == nil and item.pic and item.pic ~= "" then
                icon = GetBgIcon(item.pic, showInfoHandler, item.bgname)
            end
        end
    else
        local eType = string.sub(key, 1, 1)
        if eType == "m" then --情人节活动礼盒
            local eValue = string.sub(key, 2)
            if acLmqrjVoApi then
                local boxData = acLmqrjVoApi:getBoxItem(tonumber(eValue))
                icon = LuaCCSprite:createWithSpriteFrameName(boxData.icon[1], showInfoHandler)
                local lidSp = CCSprite:createWithSpriteFrameName(boxData.icon[2])
                if acLmqrjVoApi:getVersion() == 2 then
                    lidSp:setPosition(icon:getContentSize().width / 2 + 7, icon:getContentSize().height - 7)
                else
                    lidSp:setPosition(icon:getContentSize().width / 2, icon:getContentSize().height / 2 + 30)
                end
                lidSp:setTag(1)
                icon:addChild(lidSp)
            end
        elseif eType == "c" then
            local eValue = string.sub(key, 2)
            if acXcjhVoApi and activityVoApi:isStart(acXcjhVoApi:getAcVo()) == true then
                local src = acXcjhVoApi:getActivePropImg(key)
                icon = LuaCCSprite:createWithSpriteFrameName(src, showInfoHandler)
            end
        elseif eType == "b" then --军令币
            if militaryOrdersVoApi then
                local itemData = militaryOrdersVoApi:getItemData(key)
                if itemData then
                    icon = LuaCCScale9Sprite:createWithSpriteFrameName("Icon_BG.png", CCRect(20, 20, 10, 10), showInfoHandler)
                    icon:setContentSize(CCSizeMake(100, 100))
                    local iconSp = CCSprite:createWithSpriteFrameName(itemData.pic)
                    iconSp:setScale(90 / iconSp:getContentSize().width)
                    iconSp:setPosition(icon:getContentSize().width / 2, icon:getContentSize().height / 2)
                    icon:addChild(iconSp)
                end
            end
        elseif eType == "o" then --周年狂欢2019活动数字道具
            if acZnkh19VoApi and activityVoApi:isStart(acZnkh19VoApi:getAcVo()) == true then
                icon = acZnkh19VoApi:getNumeralPropIcon(key, showInfoHandler)
            end
        end
    end
    
    return icon
end
function G_universalAcGetItemIcon(item, showInfoHandler)--非道具使用（简单通用）
    local icon, iconBg, iconSize, bgSize = item.icon, item.iconBg, item.iconSize, item.bgSize
    local useIcon = GetBgIcon(icon, showInfoHandler, iconBg, iconSize, bgSize)
    return useIcon, iconSize / useIcon:getContentSize().width
end
--获取分辨率类型
function G_getIphoneType()
    if((G_VisibleSize.height / G_VisibleSize.width) >= 1250 / 640)then
        return G_iphoneX
    end
    if G_isIphone5() == true then
        return G_iphone5
    end
    return G_iphone4
end

--通过建筑bid来获取其所需的任务组id
function G_getGroupIdByBid(bid)
    local bvo = buildingVoApi:getBuildiingVoByBId(bid)
    local btype = bvo.type
    local groupId
    if btype == 1 then
        groupId = 8
    elseif btype == 2 then
        groupId = 9
    elseif btype == 3 then
        groupId = 10
    elseif btype == 4 then
        groupId = 11
    elseif btype == 5 then
        groupId = 7
    elseif btype == 7 then
        groupId = 6
    elseif btype == 8 then
        groupId = 12
    elseif btype == 10 then
        groupId = 13
    elseif btype == 6 then
        groupId = 14
    end
    return groupId
end

function G_playParticle(target, pos, plist, positionType, autoRemoveFlag, scale, anchor, zorder, angle)
    if target == nil then
        do return end
    end
    local particleSp = CCParticleSystemQuad:create(plist)
    particleSp:setPositionType(positionType or kCCPositionTypeFree)
    particleSp:setAnchorPoint(anchor or ccp(0.5, 0.5))
    particleSp:setPosition(pos)
    particleSp:setAutoRemoveOnFinish(autoRemoveFlag or false)
    particleSp:setScale(scale or 1)
    particleSp:setRotation(angle or 0)
    target:addChild(particleSp, (zorder or 0))
    
    return particleSp
end

--给文字加描边
function G_addStroke(parent, textLb, textStr, fontSize, bold, zorder, offset)
    if parent == nil then
        do return nil end
    end
    local textLbTb = {}
    local space = offset or 2
    for i = 1, 4 do
        local lb = GetTTFLabel(textStr, fontSize, bold)
        local px, py = textLb:getPosition()
        local scale = textLb:getScale()
        if i == 1 then
            px, py = px - space, py
        elseif i == 2 then
            px, py = px, py - space
        elseif i == 3 then
            px, py = px + space, py
        elseif i == 4 then
            px, py = px, py + space
        end
        textLbTb[i] = lb
        lb:setColor(ccc3(0, 0, 0))
        lb:setPosition(ccp(px, py))
        lb:setScale(scale)
        parent:addChild(lb, (zorder or 0))
    end
    return textLbTb
end

--给文字加投影
function G_addShadow(parent, textLb, textStr, fontSize, bold, zorder, offset)
    if parent == nil then
        do return nil end
    end
    local textLbTb = {}
    local space = offset or 2
    local lb = GetTTFLabel(textStr, fontSize, bold)
    local px, py = textLb:getPosition()
    local scale = textLb:getScale()
    px, py = px, py - space
    textLbTb[1] = lb
    lb:setColor(ccc3(0, 0, 0))
    lb:setPosition(ccp(px, py))
    lb:setScale(scale)
    parent:addChild(lb, (zorder or 0))
    return lb
end

function G_requireLua(path)
    local m = require("luascript/script/"..path)
    return m
end

function G_destroyLua(path)
    package.loaded[path] = nil
end

--战报部队信息cell的高度
function G_getBattleReportTroopsHeight(report)
    local xixueLbHeight = 0
    if tonumber(report.xixue) == 1 and tonumber(report.effect) == 1 then
        local xixueLb = GetTTFLabelWrap(getlocal("reportXixueTipDesc"), 20, CCSizeMake(G_VisibleSizeWidth / 2 - 20, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        xixueLbHeight = xixueLb:getContentSize().height
    end
    if report.troops then
        return 32 + 60 + 3 * 140 + xixueLbHeight
    else
        local fontSize = 20
        local attackerLostNum = 0
        local defenderLostNum = 0
        local attackerTotalNum = 0
        local defenderTotalNum = 0
        if report.lostShip.attackerTotal then
            if report.lostShip.attackerTotal.o then
                attackerTotalNum = SizeOfTable(report.lostShip.attackerTotal.o)
            else
                attackerTotalNum = SizeOfTable(report.lostShip.attackerTotal)
            end
        end
        if report.lostShip.defenderTotal then
            if report.lostShip.defenderTotal.o then
                defenderTotalNum = SizeOfTable(report.lostShip.defenderTotal.o)
            else
                defenderTotalNum = SizeOfTable(report.lostShip.defenderTotal)
            end
        end
        if report.lostShip.attackerLost then
            if report.lostShip.attackerLost.o then
                attackerLostNum = SizeOfTable(report.lostShip.attackerLost.o)
            else
                attackerLostNum = SizeOfTable(report.lostShip.attackerLost)
            end
        end
        if report.lostShip.defenderLost then
            if report.lostShip.defenderLost.o then
                defenderLostNum = SizeOfTable(report.lostShip.defenderLost.o)
            else
                defenderLostNum = SizeOfTable(report.lostShip.defenderLost)
            end
        end
        if attackerTotalNum > 0 or defenderTotalNum > 0 then
            height = (fontSize + 30) * (4 + attackerTotalNum + defenderTotalNum) + 80
        else
            height = (fontSize + 10) * (4 + attackerLostNum + defenderLostNum) + 80
        end
        return height + xixueLbHeight
    end
end

--战报部队信息
function G_getBattleReportTroopsLayout(cell, cellWidth, cellHeight, troops, layerNum, report, isAttacker, isVisibleTitleLine)
    local titleBg = G_createReportTitle(cellWidth - 20, getlocal("forceInformation"), isVisibleTitleLine)
    titleBg:setAnchorPoint(ccp(0.5, 1))
    titleBg:setPosition(cellWidth / 2, cellHeight)
    cell:addChild(titleBg, 2)
    local fontSize = 20
    if report.troops then --有troops字段说明是新的战报数据格式
        local tskinList = {{}, {}}
        if isAttacker == true then
            tskinList = report.tskinList or {{}, {}}
        else
            tskinList = {report.tskinList[2] or {}, report.tskinList[1] or {}}
        end
        local iconWidth, spaceX, spaceY = 100, 40, 40
        for i = 1, 2 do
            local itemBgPic = (i == 1) and "reportBlueBg.png" or "reportRedBg.png"
            local itemBg = LuaCCScale9Sprite:createWithSpriteFrameName(itemBgPic, CCRect(4, 4, 1, 1), function ()end)
            itemBg:setContentSize(CCSizeMake(cellWidth / 2, cellHeight))
            itemBg:setPosition(cellWidth * (2 * i - 1) / 4, cellHeight / 2)
            cell:addChild(itemBg)
            for kidx = 1, 2 do
                local battleIndexStr = (kidx == 1) and getlocal("front") or getlocal("back")
                local posX = itemBg:getContentSize().width / 2 + (3 - 2 * i) * (spaceX + iconWidth) / 2 + (kidx - 1) * ((2 * i - 3) * (iconWidth + spaceX))
                local indexLb = GetTTFLabel(battleIndexStr, 20)
                indexLb:setAnchorPoint(ccp(0.5, 1))
                indexLb:setPosition(posX, cellHeight - 32 - 20)
                itemBg:addChild(indexLb)
            end
            
            local firstPosY = cellHeight - 32 - 60
            local troopsInfo = troops[i] or {}
            local tskinTb = tskinList[i] or {}
            for j = 1, 6 do
                local tank = troopsInfo[j]
                local posX = itemBg:getContentSize().width / 2 + (3 - 2 * i) * (spaceX + iconWidth) / 2 + math.floor((j - 1) / 3) * ((2 * i - 3) * (iconWidth + spaceX))
                local posY = firstPosY - iconWidth / 2 - math.floor((j - 1) % 3) * (iconWidth + 40)
                
                if tank and tank[1] then
                    local tankId, totalNum, leftNum = tank[1], (tank[2] or 0), (tank[3] or 0)
                    local lostNum = totalNum - leftNum
                    tankId = tonumber(tankId) or tonumber(RemoveFirstChar(tankId))
                    
                    local tmpTankCfg = tankCfg[tankId]
                    local iconScale, fontSize = 1, 25
                    local skinId = tskinTb[tankSkinVoApi:convertTankId(tankId)]
                    local tankIcon = tankVoApi:getTankIconSp(tankId, skinId, nil, false)
                    tankIcon:setPosition(posX, posY)
                    tankIcon:setScale(iconWidth / tankIcon:getContentSize().width)
                    itemBg:addChild(tankIcon)
                    local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("newBlackFadeBar.png", CCRect(0, 0, 1, 9), function ()end)
                    numBg:setRotation(180)
                    numBg:setContentSize(CCSizeMake(80, 20))
                    numBg:setPosition(tankIcon:getPositionX() + iconWidth / 2 - numBg:getContentSize().width / 2 - 5, tankIcon:getPositionY() - iconWidth / 2 + numBg:getContentSize().height / 2 + 2)
                    itemBg:addChild(numBg)
                    local lostLb = GetTTFLabel("-"..tostring(lostNum), fontSize - 4)
                    lostLb:setAnchorPoint(ccp(1, 0.5))
                    lostLb:setColor(G_ColorRed)
                    lostLb:setPosition(numBg:getPositionX() + numBg:getContentSize().width / 2 - 5, numBg:getPositionY())
                    itemBg:addChild(lostLb, 2)
                    local leftLb = GetTTFLabel(leftNum.."/"..totalNum, fontSize - 4)
                    leftLb:setAnchorPoint(ccp(0.5, 1))
                    leftLb:setPosition(posX, posY - iconWidth / 2 - 5)
                    itemBg:addChild(leftLb)
                    
                    if G_pickedList(tankId) ~= tonumber(tankId) then
                        local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
                        tankIcon:addChild(pickedIcon)
                        pickedIcon:setPosition(tankIcon:getContentSize().width * 0.7, tankIcon:getContentSize().height * 0.5 - 10)
                    end
                else
                    local tankIconBg = CCSprite:createWithSpriteFrameName("troopNull.png")
                    tankIconBg:setPosition(ccp(posX, posY))
                    tankIconBg:setScale(iconWidth / tankIconBg:getContentSize().width)
                    itemBg:addChild(tankIconBg)
                end
            end
            local xixueStr
            if tonumber(report.xixue) == 1 and tonumber(report.effect) == 1 then
                if isAttacker ~= true and i == 1 then
                    xixueStr = getlocal("reportXixueTipDesc")
                elseif isAttacker == true and i == 2 then
                    xixueStr = getlocal("reportXixueTipDesc")
                end
            end
            if xixueStr then
                local xixueLb = GetTTFLabelWrap(xixueStr, 20, CCSizeMake(G_VisibleSizeWidth / 2 - 20, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
                xixueLb:setPosition(itemBg:getContentSize().width / 2, xixueLb:getContentSize().height / 2)
                xixueLb:setColor(G_ColorYellowPro)
                itemBg:addChild(xixueLb)
            end
        end
    else --老的战报数据格式部队信息处理
        local islandType, attacker, defender, attackerAllianceName, defenderAllianceName, helpDefender, helpDefenderAllianceName, hasHelpDefender, aLandform, dLandform, landform = reportVoApi:formatReportData(report)
        local attTotal, attLost, defTotal, defLost = troops[1], troops[2], troops[3], troops[4] --部队损失情况
        local attackerStr = ""
        local attackerLost = ""
        local defenderStr = ""
        local defenderLost = ""
        local attackerTotal = ""
        local defenderTotal = ""
        local repairStr = ""
        local content = {}

        local htSpace = 0
        local perSpace = fontSize + 10

        local attackerLostNum = SizeOfTable(attLost)
        local defenderLostNum = SizeOfTable(defLost)
        local attackerTotalNum = SizeOfTable(attTotal)
        local defenderTotalNum = SizeOfTable(defTotal)
        if attackerTotalNum > 0 or defenderTotalNum > 0 then
            perSpace = fontSize + 30
            --损失的船
            local armysContent = {getlocal("battleReport_armysName"), getlocal("battleReport_armysNums"), getlocal("battleReport_armysLosts"), getlocal("battleReport_armysleaves")}
            local showColor = {G_ColorWhite, G_ColorOrange2, G_ColorRed, G_ColorGreen}--所有需要显示的文字颜色
            local defHeight, attOrDefTotal, attOrDefLost
            for g = 1, 2 do
                if g == 2 then
                    cellHeight = defHeight - 20
                end
                if g == 1 then
                    personStr = getlocal("fight_content_attacker", {attacker})
                    attOrDefTotal = G_clone(attTotal)
                    attOrDefLost = G_clone(attLost)
                elseif g == 2 then
                    attOrDefTotal = G_clone(defTotal)
                    attOrDefLost = G_clone(defLost)
                    local defendName = defender
                    if hasHelpDefender == true then
                        defendName = helpDefender
                    end
                    if isAttacker == true then
                        if report.islandType == 7 then
                            local rebelData = report.rebel or {}
                            local rebelLv = rebelData.rebelLv or 1
                            local rebelID = rebelData.rebelID or 1
                            personStr = defenderStr..getlocal("fight_content_defender", {G_getIslandName(islandType, nil, rebelLv, rebelID, true, rebelData.rpic)})
                        elseif report.islandType == 6 or report.islandType == 8 then
                            personStr = defenderStr..getlocal("fight_content_defender", {defendName})
                        else
                            if report.islandOwner > 0 then
                                personStr = defenderStr..getlocal("fight_content_defender", {defendName})
                            else
                                personStr = defenderStr..getlocal("fight_content_defender", {G_getIslandName(islandType)})
                            end
                        end
                    else
                        personStr = defenderStr..getlocal("fight_content_defender", {defendName})
                    end
                end
                local attContent = GetTTFLabel(personStr, fontSize)
                attContent:setAnchorPoint(ccp(0, 0.5))
                attContent:setPosition(ccp(10, cellHeight - 50))
                cell:addChild(attContent, 2)
                
                if g == 1 then
                    attContent:setColor(G_ColorGreen)
                elseif g == 2 then
                    attContent:setColor(G_ColorRed)
                end
                
                local function sortAsc(a, b)
                    if sortByIndex then
                        if a.id and b.id and tonumber(a.id) and tonumber(b.id) then
                            return a.id < b.id
                        end
                    else
                        if a.type == b.type then
                            if a.id and b.id and tonumber(a.id) and tonumber(b.id) then
                                return a.id < b.id
                            end
                        end
                    end
                end
                table.sort(attOrDefTotal, sortAsc)
                local lablSize = fontSize - 9
                local lablSizeO = fontSize - 8
                if G_getCurChoseLanguage() == "cn" or G_getCurChoseLanguage() == "tw" or G_getCurChoseLanguage() == "ko" then
                    lablSize = fontSize
                    lablSizeO = fontSize - 3
                end
                local lbPosWIdth = 6
                for k, v in pairs(armysContent) do
                    local armyLb = GetTTFLabelWrap(v, lablSize, CCSizeMake(cellWidth * 0.1 + 70, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
                    armyLb:setAnchorPoint(ccp(0.5, 0.5))
                    if k > 1 then
                        lbPosWIdth = 7
                    end
                    armyLb:setPosition(ccp(cellWidth * k / lbPosWIdth + ((k - 1) * 70), cellHeight - 90))
                    cell:addChild(armyLb, 2)
                    armyLb:setColor(showColor[k])
                end

                local localLeaves = {}
                for i = 1, 4 do
                    local localStr
                    local pos = 50
                    if i == 1 then
                        for k, v in pairs(attOrDefTotal) do
                            if v and v.name then
                                localStr = v.name
                                local armyStr = GetTTFLabelWrap(localStr, lablSizeO, CCSizeMake(cellWidth * 0.1 + 70, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
                                armyStr:setAnchorPoint(ccp(0.5, 0.5))
                                armyStr:setPosition(ccp(cellWidth * i / 6 + ((i - 1) * 70), cellHeight - 90 - ((pos - 1) * k)))
                                cell:addChild(armyStr, 2)
                                armyStr:setColor(showColor[i])
                            end
                            if tankCfg[v.id].isElite == 1 then
                                local pickedSp = CCSprite:createWithSpriteFrameName("picked_icon1.png")
                                -- pickedSp:setScale()
                                pickedSp:setAnchorPoint(ccp(0.5, 0.5))
                                pickedSp:setPosition(ccp(30, cellHeight - 90 - (49 * k)))
                                cell:addChild(pickedSp, 2)
                            end
                            if k == SizeOfTable(attOrDefTotal) then
                                defHeight = cellHeight - 90 - ((pos - 1) * k)
                            end
                        end
                    end
                    if i == 2 then
                        for k, v in pairs(attOrDefTotal) do
                            table.insert(localLeaves, {num = v.num})
                        end
                        for k, v in pairs(attOrDefTotal) do
                            if v and v.num then
                                localStr = v.num
                                local armyStr = GetTTFLabelWrap(localStr, fontSize, CCSizeMake(cellWidth - 10, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
                                armyStr:setAnchorPoint(ccp(0.5, 0.5))
                                armyStr:setPosition(ccp(cellWidth * i / 7 + ((i - 1) * 70), cellHeight - 90 - ((pos - 1) * k)))
                                cell:addChild(armyStr, 2)
                                armyStr:setColor(showColor[i])
                                
                            end
                        end
                    end
                    if i == 3 then
                        local lostNum
                        if SizeOfTable(attOrDefLost) == 0 then
                            lostNum = attOrDefTotal
                        elseif SizeOfTable(attOrDefLost) > 0 and SizeOfTable(attOrDefLost) ~= SizeOfTable(attOrDefTotal) then
                            local ishere = 0
                            for k, v in pairs(attOrDefTotal) do
                                for m, n in pairs(attOrDefLost) do
                                    if m then
                                        if v.id == n.id then
                                            ishere = 0
                                            break
                                        else
                                            ishere = 1
                                        end
                                    end
                                end
                                if ishere == 1 then
                                    table.insert(attOrDefLost, v)
                                    for h, j in pairs(attOrDefLost) do
                                        if j.id == v.id then
                                            j.num = 0
                                        end
                                    end
                                    ishere = 0
                                end
                            end
                            lostNum = attOrDefLost
                        else
                            lostNum = attOrDefLost
                        end
                        local function sortAsc(a, b)
                            if sortByIndex then
                                if a.id and b.id and tonumber(a.id) and tonumber(b.id) then
                                    return a.id < b.id
                                end
                            else
                                if a.type == b.type then
                                    if a.id and b.id and tonumber(a.id) and tonumber(b.id) then
                                        return a.id < b.id
                                    end
                                end
                            end
                        end
                        table.sort(lostNum, sortAsc)
                        for k, v in pairs(lostNum) do
                            if v and v.num and SizeOfTable(attOrDefLost) >= 1 then
                                localStr = v.num
                            else
                                localStr = 0
                            end
                            local armyStr = GetTTFLabelWrap(localStr, fontSize, CCSizeMake(cellWidth - 10, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
                            armyStr:setAnchorPoint(ccp(0.5, 0.5))
                            armyStr:setPosition(ccp(cellWidth * i / 7 + ((i - 1) * 70), cellHeight - 90 - ((pos - 1) * k)))
                            cell:addChild(armyStr, 2)
                            armyStr:setColor(showColor[i])
                            if localLeaves and localLeaves[k] and localLeaves[k].num then
                                localLeaves[k].num = localLeaves[k].num - localStr
                            end
                        end
                    end
                    if i == 4 then
                        for k, v in pairs(localLeaves) do
                            if v and v.num then
                                localStr = v.num
                                local armyStr = GetTTFLabelWrap(localStr, fontSize, CCSizeMake(cellWidth - 10, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
                                armyStr:setAnchorPoint(ccp(0.5, 0.5))
                                armyStr:setPosition(ccp(cellWidth * i / 7 + ((i - 1) * 70), cellHeight - 90 - ((pos - 1) * k)))
                                cell:addChild(armyStr, 2)
                                armyStr:setColor(showColor[i])
                            end
                        end
                        localLeaves = nil
                    end
                end
            end
            if SizeOfTable(attOrDefTotal) >= 1 and tonumber(report.xixue) ~= 1 then
                repairStr = getlocal("fight_content_tip_1")
                local repairLb = GetTTFLabelWrap(repairStr, 24, CCSizeMake(cellWidth - 10, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
                repairLb:setPosition(ccp(10, defHeight - 70))
                repairLb:setAnchorPoint(ccp(0, 0.5))
                cell:addChild(repairLb, 2)
                repairLb:setColor(G_ColorOrange2)
            end
        else
            --损失的船
            attackerStr = getlocal("fight_content_attacker", {attacker}) .. "\n"
            table.insert(content, {attackerStr, htSpace})
            for k, v in pairs(attLost) do
                if v and v.name and v.num then
                    attackerLost = attackerLost.."    " .. (v.name) .. " -"..tostring(v.num) .. "\n"
                end
            end
            table.insert(content, {attackerLost, perSpace + htSpace, G_ColorRed})
            local defendName = defender
            if hasHelpDefender == true then
                defendName = helpDefender
            end
            if isAttacker == true then
                if report.islandType == 7 then
                    local rebelData = report.rebel or {}
                    local rebelLv = rebelData.rebelLv or 1
                    local rebelID = rebelData.rebelID or 1
                    defenderStr = defenderStr..getlocal("fight_content_defender", {G_getIslandName(islandType, nil, rebelLv, rebelID, nil, rebelData.rpic)}) .. "\n"
                elseif report.islandType == 6 or report.islandType == 8 then
                    defenderStr = defenderStr..getlocal("fight_content_defender", {defendName}) .. "\n"
                else
                    if report.islandOwner > 0 then
                        defenderStr = defenderStr..getlocal("fight_content_defender", {defendName}) .. "\n"
                    else
                        defenderStr = defenderStr..getlocal("fight_content_defender", {G_getIslandName(islandType)}) .. "\n"
                    end
                end
            else
                --defenderStr=defenderStr..getlocal("fight_content_defender",{playerVoApi:getPlayerName()}).."\n"
                defenderStr = defenderStr..getlocal("fight_content_defender", {defendName}) .. "\n"
            end
            table.insert(content, {defenderStr, perSpace * attackerLostNum + perSpace + htSpace})
            for k, v in pairs(defLost) do
                if v and v.name and v.num then
                    defenderLost = defenderLost.."    " .. (v.name) .. " -"..tostring(v.num) .. "\n"
                end
            end
            table.insert(content, {defenderLost, perSpace * attackerLostNum + perSpace * 2 + htSpace, G_ColorRed})
            if tonumber(report.xixue) ~= 1 then
                repairStr = getlocal("fight_content_tip_1")
                table.insert(content, {repairStr, perSpace * (2 + attackerLostNum + defenderLostNum) + htSpace})
            end
            local cellHeight = perSpace * (4 + attackerLostNum + defenderLostNum) + htSpace
            for k, v in pairs(content) do
                if v ~= nil and v ~= "" then
                    local contentMsg = content[k]
                    local message = ""
                    local pos = 0
                    local color
                    if type(contentMsg) == "table" then
                        message = contentMsg[1]
                        pos = contentMsg[2]
                        color = contentMsg[3]
                    else
                        message = contentMsg
                    end
                    if message ~= nil and message ~= "" then
                        local contentLb = GetTTFLabel(message, fontSize)
                        if k == 2 then
                            contentLb = GetTTFLabelWrap(message, fontSize, CCSizeMake(cellWidth - 10, 60 * attackerLostNum), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                        elseif k == 4 then
                            contentLb = GetTTFLabelWrap(message, fontSize, CCSizeMake(cellWidth - 10, 60 * defenderLostNum), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                        elseif k == 5 then
                            contentLb = GetTTFLabelWrap(message, fontSize, CCSizeMake(cellWidth, 60 * 1.5), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                        end
                        contentLb:setAnchorPoint(ccp(0, 1))
                        contentLb:setPosition(ccp(10, cellHeight - pos))
                        cell:addChild(contentLb, 2)
                        if color ~= nil then
                            contentLb:setColor(color)
                        end
                    end
                end
            end
        end
    end
end

--获取战报繁荣度信息cell高度
function G_getReportGloryHeight()
    return 32 + 200
end

--战报繁荣度的信息
function G_getReportGloryLayout(cell, cellWidth, cellHeight, bm, isAttacker, layerNum, isVisibleTitleLine)
    local titleBg = G_createReportTitle(cellWidth - 20, getlocal("gloryAndCity"), isVisibleTitleLine)
    titleBg:setAnchorPoint(ccp(0.5, 1))
    titleBg:setPosition(cellWidth / 2, cellHeight)
    cell:addChild(titleBg, 2)
    local gloryInfo = {}
    if isAttacker == true then
        gloryInfo[1], gloryInfo[2] = bm[2], bm[1]
    else
        gloryInfo = bm
    end
    for i = 1, 2 do
        local itemBgPic = (i == 1) and "reportBlueBg.png" or "reportRedBg.png"
        local itemBg = LuaCCScale9Sprite:createWithSpriteFrameName(itemBgPic, CCRect(4, 4, 1, 1), function ()end)
        itemBg:setContentSize(CCSizeMake(cellWidth / 2, cellHeight))
        itemBg:setPosition(cellWidth * (2 * i - 1) / 4, cellHeight / 2)
        cell:addChild(itemBg)
        
        local buildPic = playerVoApi:getPlayerBuildPic(gloryInfo[i][4])
        local buildIcon = CCSprite:createWithSpriteFrameName(buildPic)
        buildIcon:setAnchorPoint(ccp(0.5, 0))
        buildIcon:setPosition(cellWidth / 4, 70)
        buildIcon:setScale(0.65)
        itemBg:addChild(buildIcon, 1)
        
        if gloryInfo[i][5] and gloryInfo[i][5] == 1 then
            buildIcon:setColor(ccc3(136, 136, 136))
            local pzFrameName = "bf1.png"
            local metalSp = CCSprite:createWithSpriteFrameName(pzFrameName)
            metalSp:setAnchorPoint(ccp(0.5, 0.5))
            metalSp:setTag(881)
            metalSp:setScale(buildIcon:getContentSize().width * 0.62 / metalSp:getContentSize().width)
            metalSp:setPosition(ccp(buildIcon:getContentSize().width * 0.55, buildIcon:getContentSize().height * 0.28))
            local pzArr = CCArray:create()
            for kk = 1, 11 do
                local nameStr = "bf"..kk..".png"
                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                pzArr:addObject(frame)
            end
            local animation = CCAnimation:createWithSpriteFrames(pzArr)
            animation:setDelayPerUnit(0.08)
            local animate = CCAnimate:create(animation)
            local repeatForever = CCRepeatForever:create(animate)
            metalSp:runAction(repeatForever)
            buildIcon:addChild(metalSp)
        end
        
        local newNum = gloryInfo[i][1] + gloryInfo[i][2]
        if newNum > gloryInfo[i][3] then
            newNum = gloryInfo[i][3]
        elseif newNum < 0 then
            newNum = 0
        end
        local gloryInfoLb = GetTTFLabel(math.ceil(newNum) .. "/"..gloryInfo[i][3], 20)
        gloryInfoLb:setPosition(buildIcon:getPositionX(), 70)
        gloryInfoLb:setAnchorPoint(ccp(0.5, 1))
        itemBg:addChild(gloryInfoLb, 2)
        
        local addSubGlory = math.ceil(gloryInfo[i][2])
        local addStr, color = G_LowfiColorGreen, ""
        if i == 1 then
            if isAttacker == true then
                color = G_LowfiColorGreen
                addStr = "+"
            else
                color = G_LowfiColorRed
                addStr = "-"
            end
        elseif i == 2 then
            if isAttacker == true then
                color = G_LowfiColorRed
                addStr = "-"
            else
                color = G_LowfiColorGreen
                addStr = "+"
            end
        end
        if addSubGlory < 0 then
            addStr = ""
        end
        local gloryLb = GetTTFLabel(addStr..addSubGlory, 20)
        gloryLb:setPosition(buildIcon:getPositionX(), gloryInfoLb:getPositionY() - gloryInfoLb:getContentSize().height - 5)
        gloryLb:setAnchorPoint(ccp(0.5, 1))
        gloryLb:setColor(color)
        itemBg:addChild(gloryLb, 2)
    end
end

--根据岛屿类型取岛屿图标
function G_getIslandIcon(islandType, rebelLv, rebelID, rpic)
    if islandType > 0 and islandType <= 6 then --普通资源和玩家基地
        if islandType < 6 then
            local resImgArr = {"tie_kuang_building_1", "shi_you_building_1", "qian_kuang_building", "tai_kuang_building", "shui_jing_world_building_1"}
            return CCSprite:createWithSpriteFrameName(resImgArr[islandType] .. ".png")
        end
        return CCSprite:createWithSpriteFrameName("world_island_"..islandType..".png")
    elseif islandType == 7 then --叛军
        if rpic and rpic >= 100 then
            local pickName = rebelVoApi:getSpecialRebelPic(rpic)
            if pickName then
                return CCSprite:createWithSpriteFrameName(pickName)
            end
        end
        local tankId = rebelVoApi:getRebelIconTank(rebelLv, rebelID)
        local tid = tonumber(tankId) or tonumber(RemoveFirstChar(tankId))
        return G_getTankPic(tid)
    elseif islandType == 8 then --军团城市
        spriteController:addPlist("scene/allianceCityImages.plist")
        spriteController:addTexture("scene/allianceCityImages.png")
        local sp = CCSprite:createWithSpriteFrameName("allianceCity.png")
        local radarSp = CCSprite:createWithSpriteFrameName("acityRadar1.png")
        radarSp:setAnchorPoint(ccp(0.5, 0.5))
        radarSp:setPosition(132, 163)
        sp:addChild(radarSp)
        return sp
    end
end

function G_createReportTitle(_titleWidth, _titleStr, _isVisibleLine)
    local titleBg = LuaCCScale9Sprite:createWithSpriteFrameName("reportTitleBg.png", CCRect(35, 15, 2, 2), function()end)
    titleBg:setContentSize(CCSizeMake(388, 32))
    titleBg:setOpacity(255 * 0.1)
    local titleBgLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function()end)
    titleBgLine:setContentSize(CCSizeMake(_titleWidth, 2))
    titleBgLine:setPosition(titleBg:getContentSize().width / 2, titleBg:getContentSize().height)
    titleBgLine:setRotation(180)
    -- titleBgLine:setOpacity(255*0.06)
    if type(_isVisibleLine) == "boolean" then
        titleBgLine:setVisible(_isVisibleLine)
    end
    titleBg:addChild(titleBgLine, -1)
    local titleLb = GetTTFLabel(_titleStr, 22, true)
    titleLb:setPosition(titleBg:getContentSize().width / 2, titleBg:getContentSize().height / 2)
    titleBg:addChild(titleLb, 1)
    return titleBg, titleLb
end

function G_reportFormatResource(_resourceTb)
    local resTb = {}
    for k, v in pairs(_resourceTb) do
        if v.type == "u" and (v.key == "r1" or v.key == "r2" or v.key == "r3" or v.key == "r4" or v.key == "gold") then
            if resTb[1] == nil then
                resTb[1] = {}
            end
            -- table.insert(resTb[1],G_reportResSort[1][v.key],v)
            resTb[1][G_reportResSort[1][v.key]] = v
        elseif v.type == "r" or (v.type == "u" and (v.key == "gem" or v.key == "gems")) then
            if resTb[2] == nil then
                resTb[2] = {}
            end
            -- table.insert(resTb[2],G_reportResSort[2][v.key],v)
            resTb[2][G_reportResSort[2][v.key]] = v
        else
            if resTb[3] == nil then
                resTb[3] = {}
            end
            table.insert(resTb[3], v)
        end
    end
    --------------------------TODO TEST---------------------------
    -- for i=1,8 do
    -- if resTb[3]==nil then
    -- resTb[3]={}
    -- end
    -- local v={
    -- type="p",
    -- key="p878",
    -- pic="item_baoxiang_09.png",
    -- num=55,
    -- name="AAA",
    -- id=878,
    -- desc="AAABBB",
    -- }
    -- table.insert(resTb[3],v)
    -- end
    --------------------------TODO TEST---------------------------
    -- if resTb[1] then
    -- table.sort(resTb[1],function(a,b) return G_reportResSort[1][a.key]>G_reportResSort[1][b.key] end)
    -- end
    -- if resTb[2] then
    -- table.sort(resTb[2],function(a,b) return G_reportResSort[2][a.key]>G_reportResSort[2][b.key] end)
    -- end
    return resTb
end

function G_reportResourceCellHeight(_resourceTb)
    local height = 0
    if _resourceTb then
        height = height + 40
        height = height + 10 --local posY=titleBg:getPositionY()-titleBg:getContentSize().height-10
        local zyLb = GetTTFLabel(getlocal("search_fleet_report_desc_6")..FormatNumber(0), 20)
        local resTb = G_reportFormatResource(_resourceTb)
        height = height + zyLb:getContentSize().height + 10 --posY=zyLb:getPositionY()-zyLb:getContentSize().height-10
        if resTb then
            for i = 1, 3 do
                if resTb[i] then
                    if i < 3 then
                        height = height + 10 --posY=lineSp:getPositionY()-10
                        
                        height = height + 35 --posY=posY-35
                    else
                        local resTbSize = SizeOfTable(resTb[i])
                        local rowNum = 5
                        local iconSize = 95
                        local spaceX, spaceY = 25, 25
                        height = height + 10 --local firstPosY=posY-10
                        height = height + math.ceil(resTbSize / rowNum) * iconSize + (math.ceil(resTbSize / rowNum) - 1) * spaceY
                        height = height + 10
                    end
                end
            end
        end
    end
    return height
end

function G_reportResourceLayout(_parentBg, cellWidth, cellHeight, _resourceTb, _titleStr, _layerNum, report, isAttacker)
    local titleBg = LuaCCScale9Sprite:createWithSpriteFrameName("reportRewardTitleBg.png", CCRect(4, 19, 1, 2), function()end)
    titleBg:setContentSize(CCSizeMake(cellWidth, 40))
    titleBg:ignoreAnchorPointForPosition(false)
    titleBg:setAnchorPoint(ccp(0.5, 1))
    titleBg:setPosition(ccp(cellWidth / 2, cellHeight))
    _parentBg:addChild(titleBg)
    
    local titleLabel = GetTTFLabel(_titleStr, 22, true)
    titleLabel:setPosition(getCenterPoint(titleBg))
    titleBg:addChild(titleLabel)
    
    local contentBg = LuaCCScale9Sprite:createWithSpriteFrameName("reportRewardTitleBg2.png", CCRect(4, 4, 1, 1), function()end)
    contentBg:setContentSize(CCSizeMake(titleBg:getContentSize().width, cellHeight - titleBg:getContentSize().height))
    contentBg:setAnchorPoint(ccp(0.5, 1))
    contentBg:setPosition(cellWidth / 2, titleBg:getPositionY() - titleBg:getContentSize().height)
    _parentBg:addChild(contentBg)
    
    local posY = titleBg:getPositionY() - titleBg:getContentSize().height - 10
    
    local resTb = G_reportFormatResource(_resourceTb)
    local _totalRes = 0
    local zyLb = GetTTFLabel(getlocal("search_fleet_report_desc_6")..FormatNumber(_totalRes), 20)
    zyLb:setAnchorPoint(ccp(0, 1))
    zyLb:setPosition(10, posY)
    _parentBg:addChild(zyLb)
    posY = zyLb:getPositionY() - zyLb:getContentSize().height - 10
    
    if report and report.rp then --军功
        local rankPoint = 0
        if isAttacker == true then
            rankPoint = tonumber(report.rp[1]) or 0
        else
            rankPoint = tonumber(report.rp[2]) or 0
        end
        local rankPointStr = getlocal("email_rankPoint")..rankPoint
        local rankPointLb = GetTTFLabel(rankPointStr, 20)
        rankPointLb:setAnchorPoint(ccp(1, 1))
        rankPointLb:setPosition(cellWidth - 10, zyLb:getPositionY())
        _parentBg:addChild(rankPointLb)
    end
    
    local resourceAddFlag = true --是否是增加资源的标识，被掠夺的话就为false
    if report and report.type == 1 then --如果是战斗报告的话，存在掠夺或被掠夺的问题
        if isAttacker and isAttacker == true then
            if report.isVictory == 1 then --我方胜利
                resourceAddFlag = true
            else --我方失败
                resourceAddFlag = false
            end
        else
            if report.isVictory == 1 then --我方失败
                resourceAddFlag = false
            else --我方胜利
                resourceAddFlag = true
            end
        end
    end
    
    if resTb then
        for i = 1, 3 do
            if resTb[i] then
                if i < 3 then
                    local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("reportWhiteLine.png", CCRect(4, 0, 1, 2), function()end)
                    lineSp:setContentSize(CCSizeMake(cellWidth - 20, 2))
                    lineSp:setPosition(cellWidth / 2, posY)
                    lineSp:setOpacity(255 * 0.06)
                    _parentBg:addChild(lineSp)
                    posY = lineSp:getPositionY() - 10
                    
                    for k, v in pairs(G_reportResSort[i]) do
                        local _tag = tonumber(i.."000") + v
                        if _parentBg:getChildByTag(_tag) == nil then
                            local resData = resTb[i][v]
                            local picName = nil
                            local scale = 1
                            local offsetX = 0
                            local lbOffsetX = 0
                            if i == 1 or (tostring(k) == "gem" or tostring(k) == "gems") then
                                picName = G_getResourceIcon(k)
                            else
                                local id = RemoveFirstChar(k)
                                picName = "alien_mines"..id.."_"..id..".png"
                                scale = 0.5
                                if k == "r1" then
                                    scale = 0.45
                                    offsetX = -8
                                    lbOffsetX = -4
                                elseif k == "r2" or k == "r3" then
                                    scale = 0.38
                                    offsetX = -4
                                end
                            end
                            if picName then
                                local resPic = CCSprite:createWithSpriteFrameName(picName)
                                resPic:setAnchorPoint(ccp(0, 0.5))
                                resPic:setPosition(10 + (v - 1) * ((cellWidth - 20) / 5) + offsetX, posY - 10)
                                resPic:setScale(scale)
                                _parentBg:addChild(resPic)
                                resPic:setTag(_tag)
                                local addStr, color = "+", G_LowfiColorGreen
                                local resNum = 0
                                if resData then
                                    resNum = resData.num
                                    if resourceAddFlag == true or (tostring(k) == "gem" or tostring(k) == "gems") then --金币不存在掠夺或者被掠夺的问题
                                        _totalRes = _totalRes + resData.num
                                        addStr, color = "+", G_LowfiColorGreen
                                    else
                                        _totalRes = _totalRes - resData.num
                                        addStr, color = "-", G_LowfiColorRed
                                    end
                                end
                                local resLb = GetTTFLabel(addStr..FormatNumber(resNum), 18)
                                resLb:setAnchorPoint(ccp(0, 0.5))
                                resLb:setPosition(resPic:getPositionX() + resPic:getContentSize().width * resPic:getScale() + lbOffsetX, resPic:getPositionY())
                                resLb:setColor(color)
                                _parentBg:addChild(resLb)
                            end
                        end
                    end
                    posY = posY - 35
                else
                    local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("reportWhiteLine.png", CCRect(4, 0, 1, 2), function()end)
                    lineSp:setContentSize(CCSizeMake(cellWidth - 20, 2))
                    lineSp:setPosition(cellWidth / 2, posY)
                    lineSp:setOpacity(255 * 0.06)
                    _parentBg:addChild(lineSp)
                    local rowNum = 5
                    local iconSize = 95
                    local spaceX, spaceY = 25, 25
                    local firstPosX = (cellWidth - (iconSize * rowNum + spaceX * (rowNum - 1))) / 2
                    local firstPosY = posY - 10
                    for k, v in pairs(resTb[i]) do
                        local function showNewPropInfo()
                            G_showNewPropInfo(_layerNum + 1, true, true, nil, v)
                        end
                        local icon = G_getItemIcon(v, 100, false, _layerNum, showNewPropInfo)
                        icon:setAnchorPoint(ccp(0, 1))
                        local scale = iconSize / icon:getContentSize().width
                        icon:setScale(scale)
                        icon:setPosition(firstPosX + ((k - 1) % rowNum) * (iconSize + spaceX), firstPosY - math.floor(((k - 1) / rowNum)) * (iconSize + spaceY))
                        icon:setTouchPriority(-(_layerNum - 1) * 20 - 2)
                        _parentBg:addChild(icon)
                        
                        local numLb = GetTTFLabel(FormatNumber(v.num), 20)
                        local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("newBlackFadeBar.png", CCRect(0, 0, 1, 9), function ()end)
                        numBg:setContentSize(CCSizeMake(65, numLb:getContentSize().height - 5))
                        numBg:setPosition(ccp(icon:getPositionX() + icon:getContentSize().width * scale - numBg:getContentSize().width / 2 - 5, icon:getPositionY() - icon:getContentSize().height * scale + numBg:getContentSize().height / 2 + 5))
                        numBg:setRotation(180)
                        _parentBg:addChild(numBg, 3)
                        numLb:setAnchorPoint(ccp(1, 0.5))
                        numLb:setPosition(ccp(numBg:getPositionX() + numBg:getContentSize().width / 2 - 5, numBg:getPositionY()))
                        _parentBg:addChild(numLb, 4)
                    end
                end
            end
        end
        if _totalRes < 0 then
            zyLb:setString(getlocal("search_fleet_report_desc_6") .. "-"..FormatNumber(math.abs(_totalRes)))
            zyLb:setColor(G_LowfiColorRed)
        else
            zyLb:setString(getlocal("search_fleet_report_desc_6") .. "+"..FormatNumber(_totalRes))
            zyLb:setColor(G_LowfiColorGreen)
        end
    end
end

--战斗资源相关
function G_getReportResource(report)
    local award = {} --普通战利品
    local acAward = {} --相关活动的奖励
    if report.award.u or report.award.p then
        award = FormatItem(report.award, false) or {}
    else
        award = G_clone(report.award or {})
    end
    local maxLevel = playerVoApi:getMaxLvByKey("roleMaxLevel") --当前服 最大等级
    local expTb = Split(playerCfg.level_exps, ",")
    local maxExp = expTb[maxLevel] --当前服 最大经验值
    local playerExp = playerVoApi:getPlayerExp() --用户当前的经验值
    for k, v in pairs(award) do
        if v.name == getlocal("sample_general_exp") and base.isConvertGems == 1 and tonumber(playerExp) >= tonumber(maxExp) then
            v.name, v.num, v.pic, v.type, v.key, v.desc = getlocal("money"), playerVoApi:convertGems(1, v.num), "resourse_normal_gold.png", "u", "gold", getlocal("resourse_gold_desc")
            do break end
        end
    end
    if report.acaward then
        local reward = {reportAcReward = {}}
        for k, v in pairs(report.acaward) do
            reward.reportAcReward[k] = v
        end
        acAward = FormatItem(reward, false) or {}
    end
    local resource = {} --掠夺或被掠夺的资源
    if report.resource and (report.resource.u or report.resource.r) then
        resource = FormatItem(report.resource)
    else
        resource = G_clone(report.resource or {})
    end
    if resource then
        local _resNum = 0
        for k, v in pairs(resource) do
            if v and v.num then
                _resNum = _resNum + v.num
            end
        end
        if _resNum == 0 then
            resource = {}
        end
    end
    local midautumnRes = {}
    if report.acData and report.acData.midautumn then --中秋赏月活动送的道具
        midautumnRes = FormatItem(report.acData.midautumn)
    end
    local resourceTb = G_mergeAllFormatRewards({award, acAward, resource, midautumnRes}) --将三种资源合并

    return resourceTb
end

--前端合并奖励
function G_mergeAllRewards(rewardTb)
    local rewardlist = {}
    local total = {}
    for k, v in pairs(rewardTb) do
        for kk, vv in pairs(v) do
            if total[kk] then
                for m, n in pairs(vv) do
                    table.insert(total[kk], n)
                end
            else
                total[kk] = vv
            end
        end
    end
    
    for k, v in pairs(total) do
        rewardlist[k] = {}
        local reward = {}
        for m, n in pairs(v) do
            if m ~= nil and n ~= nil then
                local key, num, index
                for i, j in pairs(n) do
                    if i == "index" then
                        index = j
                        if reward[key] then
                            reward[key][2] = index
                        else
                            reward[key] = {0, index}
                        end
                    else
                        key, num = i, j
                        if reward[key] then
                            reward[key][1] = (reward[key][1] or 0) + num
                        else
                            reward[key] = {num}
                        end
                    end
                end
            end
        end
        for key, value in pairs(reward) do
            local item = {}
            if value[1] then
                item[key] = value[1]
            end
            if value[2] then
                item["index"] = value[2]
            end
            table.insert(rewardlist[k], item)
        end
    end
    return rewardlist
end

--合并formatItem之后的奖励
function G_mergeAllFormatRewards(rewardTb, sortByIndex)
    local rewardlist = {}
    local total = {}
    for k, v in pairs(rewardTb) do
        for kk, item in pairs(v) do
            table.insert(total, item)
        end
    end
    local mergeTb = {}
    for k, v in pairs(total) do
        if mergeTb[v.key] then
            mergeTb[v.key].num = mergeTb[v.key].num + v.num
        else
            mergeTb[v.key] = v
        end
    end
    for k, v in pairs(mergeTb) do
        table.insert(rewardlist, v)
    end
    if rewardlist and SizeOfTable(rewardlist) > 0 then
        local function sortAsc(a, b)
            if sortByIndex then
                if a.index and b.index and tonumber(a.index) and tonumber(b.index) then
                    return a.index < b.index
                end
            else
                if a.type == b.type then
                    if a.index and b.index and tonumber(a.index) and tonumber(b.index) then
                        return a.index < b.index
                    end
                end
            end
        end
        table.sort(rewardlist, sortAsc)
    end
    
    return rewardlist
end

function G_createReportPositionLabel(_ccp, _fontSize, _callback, _isShowLine, color)
    if not color then
        color = G_LowfiColorGreen
    end
    if _isShowLine == nil then
        _isShowLine = true
    end
    local function jumpToPosition()
        if playerVoApi:getPlayerLevel() < 3 then
            do return end
        end
        if _callback then
            _callback()
        end
        activityAndNoteDialog:closeAllDialog()
        G_closeAllSmallDialog()
        mainUI:changeToWorld()
        worldScene:focus(_ccp.x, _ccp.y)
    end
    local posLb = GetTTFLabel("(".._ccp.x..",".._ccp.y..")", _fontSize)
    posLb:setColor(color)
    local menuItem = CCMenuItemLabel:create(posLb)
    if _isShowLine == true then
        local lineLb = GetTTFLabel("_", _fontSize)
        lineLb:setAnchorPoint(ccp(0.5, 0))
        lineLb:setPosition(posLb:getContentSize().width / 2 + 2, -2)
        lineLb:setScaleX(posLb:getContentSize().width / lineLb:getContentSize().width)
        lineLb:setColor(color)
        posLb:addChild(lineLb)
        menuItem:registerScriptTapHandler(jumpToPosition)
    end
    local menu = CCMenu:createWithItem(menuItem)
    return menu, menuItem, posLb
end

--装甲矩阵战报信息的cell高度
function G_getReportArmorMatrixHeight()
    local height = 32
    local promptLb = GetTTFLabelWrap(getlocal("report_accessory_num"), 22, CCSizeMake(280, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    height = height + promptLb:getContentSize().height + 20
    local num = 2
    if base.armorbr == 1 then
        num = 3
    end
    height = height + (30 + 10) * num + 40 --配件的icon尺寸是30，显示间距是20
    
    return height
end

--显示装甲矩阵信息
function G_getReportArmorMatrixLayout(cell, cellWidth, cellHeight, layerNum, report, isAttacker)
    local titleBg = G_createReportTitle(cellWidth - 20, getlocal("armorMatrix"))
    titleBg:setAnchorPoint(ccp(0.5, 1))
    titleBg:setPosition(cellWidth / 2, cellHeight)
    cell:addChild(titleBg, 2)
    
    local fontSize, iSize, iSpace = 22, 30, 10
    local armor = report.armor or {}
    local myArmorData, enemyArmorData = {}, {}
    if isAttacker == true then
        myArmorData, enemyArmorData = (armor[1] or {}), (armor[2] or {})
    else
        myArmorData, enemyArmorData = (armor[2] or {}), (armor[1] or {})
    end
    for i = 1, 2 do
        local itemBgPic = (i == 1) and "reportBlueBg.png" or "reportRedBg.png"
        local itemBg = LuaCCScale9Sprite:createWithSpriteFrameName(itemBgPic, CCRect(4, 4, 1, 1), function ()end)
        itemBg:setContentSize(CCSizeMake(cellWidth / 2, cellHeight))
        itemBg:setPosition(cellWidth * (2 * i - 1) / 4, cellHeight / 2)
        cell:addChild(itemBg)
        
        local promptLb = GetTTFLabelWrap(getlocal("report_armorMatrix_num"), fontSize, CCSizeMake(280, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        promptLb:setPosition(itemBg:getContentSize().width / 2, cellHeight - 32 - 10 - promptLb:getContentSize().height / 2)
        itemBg:addChild(promptLb)
        
        local firstPosY = promptLb:getPositionY() - promptLb:getContentSize().height / 2 - 10
        
        local armorNum, armorScore = 0, 0
        local armorMatirxTb = {}
        if i == 1 then
            armorMatirxTb = myArmorData[1] or ((base.armorbr == 1) and {0, 0, 0, 0, 0} or {0, 0, 0, 0})
            armorScore = myArmorData[2] or 0
        else
            armorMatirxTb = enemyArmorData[1] or ((base.armorbr == 1) and {0, 0, 0, 0, 0} or {0, 0, 0, 0})
            armorScore = enemyArmorData[2] or 0
        end
        armorNum = SizeOfTable(armorMatirxTb)
        
        if armorNum > 0 then
            if base.armorbr == 1 and armorNum < 5 then
                armorNum = 5
            elseif base.armorbr == 0 and armorNum == 5 then --理论上不能出现这种情况，否则就是人为操作错误
                armorNum = 4
            end
            for n = 1, armorNum do
                local posX = 60 + ((n + 1) % 2) * 100
                local posY = firstPosY - iSize / 2 - math.floor((n - 1) / 2) * (iSize + iSpace)
                local icon = CCSprite:createWithSpriteFrameName("armorMatrixUpArrow"..n..".png")
                local scale = iSize / icon:getContentSize().width
                icon:setScale(scale)
                icon:setPosition(posX + iSize / 2, posY)
                itemBg:addChild(icon, 1)
                
                local numLb = GetTTFLabel((armorMatirxTb[n] or 0), fontSize - 2)
                numLb:setPosition(ccp(icon:getPositionX() + iSize / 2 + 15, posY))
                itemBg:addChild(numLb, 1)
            end
        end
        local alignment, anchor, posX = kCCTextAlignmentLeft, ccp(0, 1), 20
        if i == 2 then
            alignment, anchor, posX = kCCTextAlignmentRight, ccp(1, 1), cellWidth / 2 - 20
        end
        local num = 2
        if base.armorbr == 1 then
            num = 3
        end
        local strengthStr = getlocal("plane_power") .. "：" .. "<rayimg>"..FormatNumber(armorScore) .. "<rayimg>"
        local strengthLb = G_getRichTextLabel(strengthStr, {nil, G_ColorYellowPro, nil}, fontSize - 2, 280, alignment, kCCVerticalTextAlignmentTop)
        strengthLb:setAnchorPoint(anchor)
        strengthLb:setPosition(posX, firstPosY - num * (iSize + iSpace))
        itemBg:addChild(strengthLb)
    end
end

--配件战报信息的cell高度
function G_getReportAccessoryHeight()
    local height = 32
    local promptLb = GetTTFLabelWrap(getlocal("report_accessory_num"), 22, CCSizeMake(280, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    height = height + promptLb:getContentSize().height + 20
    
    local num = 2
    if accessoryVoApi:isUpgradeQualityRed() == true then
        num = 3
    end
    height = height + (30 + 10) * num + 40 --配件的icon尺寸是30，显示间距是20
    
    return height
end

--显示配件信息
function G_getReportAccessoryLayout(cell, cellWidth, cellHeight, layerNum, report, isAttacker)
    local titleBg = G_createReportTitle(cellWidth - 20, getlocal("report_accessory_compare"))
    titleBg:setAnchorPoint(ccp(0.5, 1))
    titleBg:setPosition(cellWidth / 2, cellHeight)
    cell:addChild(titleBg, 2)
    
    local tabStr = {" ", getlocal("report_accessory_desc"), " "}
    G_addMenuInfo(cell, layerNum, ccp(cellWidth - 30, cellHeight - 30), tabStr, nil, 0.6, 25, nil, true)
    
    local fontSize, iSize, iSpace = 22, 30, 10
    local accessory = report.accessory or {}
    local myAccData, enemyAccData = {}, {}
    if isAttacker == true then
        myAccData, enemyAccData = (accessory[1] or {}), (accessory[2] or {})
    else
        myAccData, enemyAccData = (accessory[2] or {}), (accessory[1] or {})
    end
    for i = 1, 2 do
        local itemBgPic = (i == 1) and "reportBlueBg.png" or "reportRedBg.png"
        local itemBg = LuaCCScale9Sprite:createWithSpriteFrameName(itemBgPic, CCRect(4, 4, 1, 1), function ()end)
        itemBg:setContentSize(CCSizeMake(cellWidth / 2, cellHeight))
        itemBg:setPosition(cellWidth * (2 * i - 1) / 4, cellHeight / 2)
        cell:addChild(itemBg)
        
        local promptLb = GetTTFLabelWrap(getlocal("report_accessory_num"), fontSize, CCSizeMake(280, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        promptLb:setPosition(itemBg:getContentSize().width / 2, cellHeight - 32 - 10 - promptLb:getContentSize().height / 2)
        itemBg:addChild(promptLb)
        
        local firstPosY = promptLb:getPositionY() - promptLb:getContentSize().height / 2 - 10
        
        local accNum, accScore = 0, 0
        local accTab = {}
        if i == 1 then
            accTab = myAccData[2] or {0, 0, 0, 0}
            accScore = myAccData[1] or 0
        else
            accTab = enemyAccData[2] or {0, 0, 0, 0}
            accScore = enemyAccData[1] or 0
        end
        if accessoryVoApi:isUpgradeQualityRed() == true then
            accTab[5] = (accTab[5] or 0)
        end
        accNum = SizeOfTable(accTab)
        
        if accNum > 0 then
            for n = 1, accNum do
                local posX = 60 + ((n + 1) % 2) * 100
                local posY = firstPosY - iSize / 2 - math.floor((n - 1) / 2) * (iSize + iSpace)
                local icon = CCSprite:createWithSpriteFrameName("uparrow"..n..".png")
                local scale = iSize / icon:getContentSize().width
                icon:setScale(scale)
                icon:setPosition(posX + iSize / 2, posY)
                itemBg:addChild(icon, 1)
                
                local numLb = GetTTFLabel((accTab[n] or 0), fontSize - 2)
                numLb:setPosition(ccp(icon:getPositionX() + iSize / 2 + 15, posY))
                itemBg:addChild(numLb, 1)
            end
        end
        
        local num = 2
        if accessoryVoApi:isUpgradeQualityRed() == true then
            num = 3
        end
        local alignment, anchor, posX = kCCTextAlignmentLeft, ccp(0, 1), 20
        if i == 2 then
            alignment, anchor, posX = kCCTextAlignmentRight, ccp(1, 1), cellWidth / 2 - 20
        end
        local strengthStr = getlocal("plane_power") .. "：" .. "<rayimg>"..FormatNumber(accScore) .. "<rayimg>"
        local strengthLb = G_getRichTextLabel(strengthStr, {nil, G_ColorYellowPro, nil}, fontSize - 2, 280, alignment, kCCVerticalTextAlignmentTop)
        strengthLb:setAnchorPoint(anchor)
        strengthLb:setPosition(posX, firstPosY - num * (iSize + iSpace))
        itemBg:addChild(strengthLb)
    end
end

--战报将领信息的cell高度
function G_getReportHeroLayoutHeight()
    return 32 + 3 * (100 + 40) + 40 + 60 --icon的尺寸100，间距40
end

--显示战报将领信息
function G_getReportHeroLayout(cell, cellWidth, cellHeight, layerNum, report, isAttacker)
    local titleBg = G_createReportTitle(cellWidth - 20, getlocal("report_hero_message"))
    titleBg:setAnchorPoint(ccp(0.5, 1))
    titleBg:setPosition(cellWidth / 2, cellHeight)
    cell:addChild(titleBg, 2)
    local fontSize = 20
    if report.hero then
        local myHero, enemyHero = {}, {}
        if isAttacker == true then
            myHero, enemyHero = report.hero[1], report.hero[2]
        else
            myHero, enemyHero = report.hero[2], report.hero[1]
        end
        local iconWidth, spaceX, spaceY = 100, 40, 40
        for i = 1, 2 do
            local itemBgPic = (i == 1) and "reportBlueBg.png" or "reportRedBg.png"
            local itemBg = LuaCCScale9Sprite:createWithSpriteFrameName(itemBgPic, CCRect(4, 4, 1, 1), function ()end)
            itemBg:setContentSize(CCSizeMake(cellWidth / 2, cellHeight))
            itemBg:setPosition(cellWidth * (2 * i - 1) / 4, cellHeight / 2)
            cell:addChild(itemBg)
            for kidx = 1, 2 do
                local battleIndexStr = (kidx == 1) and getlocal("front") or getlocal("back")
                local posX = itemBg:getContentSize().width / 2 + (3 - 2 * i) * (spaceX + iconWidth) / 2 + (kidx - 1) * ((2 * i - 3) * (iconWidth + spaceX))
                local indexLb = GetTTFLabel(battleIndexStr, 20)
                indexLb:setAnchorPoint(ccp(0.5, 1))
                indexLb:setPosition(posX, cellHeight - 32 - 20)
                itemBg:addChild(indexLb)
            end
            
            local heroData
            local firstPosY = cellHeight - 32 - 60
            
            if (i == 1) then
                heroData = myHero or ({{}, 0})
            else
                heroData = enemyHero or ({{}, 0})
            end
            heroData[1] = heroData[1] or {}
            heroData[2] = tonumber(heroData[2]) or 0
            
            for j = 1, 6 do
                local posX = itemBg:getContentSize().width / 2 + (3 - 2 * i) * (spaceX + iconWidth) / 2 + math.floor((j - 1) / 3) * ((2 * i - 3) * (iconWidth + spaceX))
                local posY = firstPosY - iconWidth / 2 - math.floor((j - 1) % 3) * (iconWidth + 40)
                
                local heroStr = heroData[1][j]
                if heroStr == nil or heroStr == "" or type(heroStr) ~= "string" then
                    local emptyHeroSp = CCSprite:createWithSpriteFrameName("heroNull.png")
                    emptyHeroSp:setPosition(ccp(posX, posY))
                    emptyHeroSp:setScale(iconWidth / emptyHeroSp:getContentSize().width)
                    itemBg:addChild(emptyHeroSp)
                else
                    local arr = Split(heroStr, "-")
                    local hid, level, productOrder = arr[1], arr[2], arr[3]
                    local adjutants = heroAdjutantVoApi:decodeAdjutant(heroStr)
                    local heroSp = heroVoApi:getHeroIcon(hid, productOrder, false, nil, nil, nil, nil, {adjutants = adjutants, showAjt = true})
                    if tonumber(level) and tonumber(level) > 0 and heroSp then
                        heroSp:setScale(iconWidth / heroSp:getContentSize().width)
                        heroSp:setPosition(ccp(posX, posY))
                        itemBg:addChild(heroSp)
                        local lvBg = LuaCCScale9Sprite:createWithSpriteFrameName("newBlackFadeBar.png", CCRect(0, 0, 1, 9), function ()end)
                        lvBg:setContentSize(CCSizeMake(60, 20))
                        lvBg:setRotation(180)
                        lvBg:setPosition(heroSp:getPositionX() + iconWidth / 2 - lvBg:getContentSize().width / 2 - 7, heroSp:getPositionY() - iconWidth / 2 + lvBg:getContentSize().height / 2 + 7)
                        itemBg:addChild(lvBg, 1)
                        local levelLb = GetTTFLabel(getlocal("fightLevel", {level}), fontSize - 4)
                        levelLb:setAnchorPoint(ccp(1, 0.5))
                        levelLb:setPosition(lvBg:getPositionX() + lvBg:getContentSize().width / 2 - 5, lvBg:getPositionY())
                        itemBg:addChild(levelLb, 2)
                    else
                        local emptyHeroSp = CCSprite:createWithSpriteFrameName("heroNull.png")
                        emptyHeroSp:setPosition(ccp(posX, posY))
                        emptyHeroSp:setScale(iconWidth / emptyHeroSp:getContentSize().width)
                        itemBg:addChild(emptyHeroSp)
                    end
                end
            end
            local alignment, anchor, posX = kCCTextAlignmentLeft, ccp(0, 1), 20
            if i == 2 then
                alignment, anchor, posX = kCCTextAlignmentRight, ccp(1, 1), cellWidth / 2 - 20
            end
            local score = heroData[2]
            local strengthStr = getlocal("plane_power") .. "：" .. "<rayimg>"..FormatNumber(score) .. "<rayimg>"
            local strengthLb = G_getRichTextLabel(strengthStr, {nil, G_ColorYellowPro, nil}, fontSize - 2, 280, alignment, kCCVerticalTextAlignmentTop)
            strengthLb:setAnchorPoint(anchor)
            strengthLb:setPosition(posX, firstPosY - 3 * (iconWidth + spaceY))
            itemBg:addChild(strengthLb)
        end
    end
end

--战报超级武器信息的cell高度
function G_getReportSuperWeaponLayoutHeight()
    return 32 + 3 * (100 + 40) + 40 + 60 --icon的尺寸100，间距40
end

--显示战报超级武器信息
function G_getReportSuperWeaponLayout(cell, cellWidth, cellHeight, layerNum, report, isAttacker)
    local titleBg = G_createReportTitle(cellWidth - 20, getlocal("super_weapon_title_1"))
    titleBg:setAnchorPoint(ccp(0.5, 1))
    titleBg:setPosition(cellWidth / 2, cellHeight)
    cell:addChild(titleBg, 2)
    local fontSize = 20
    if report.weapon then
        local myWeapon, enemyWeapon = {}, {}
        if isAttacker == true then
            myWeapon, enemyWeapon = report.weapon[1], report.weapon[2]
        else
            myWeapon, enemyWeapon = report.weapon[2], report.weapon[1]
        end
        local iconWidth, spaceX, spaceY = 100, 40, 40
        for i = 1, 2 do
            local itemBgPic = (i == 1) and "reportBlueBg.png" or "reportRedBg.png"
            local itemBg = LuaCCScale9Sprite:createWithSpriteFrameName(itemBgPic, CCRect(4, 4, 1, 1), function ()end)
            itemBg:setContentSize(CCSizeMake(cellWidth / 2, cellHeight))
            itemBg:setPosition(cellWidth * (2 * i - 1) / 4, cellHeight / 2)
            cell:addChild(itemBg)
            for kidx = 1, 2 do
                local battleIndexStr = (kidx == 1) and getlocal("front") or getlocal("back")
                local posX = itemBg:getContentSize().width / 2 + (3 - 2 * i) * (spaceX + iconWidth) / 2 + (kidx - 1) * ((2 * i - 3) * (iconWidth + spaceX))
                local indexLb = GetTTFLabel(battleIndexStr, 20)
                indexLb:setAnchorPoint(ccp(0.5, 1))
                indexLb:setPosition(posX, cellHeight - 32 - 20)
                itemBg:addChild(indexLb)
            end
            
            local swData
            local firstPosY = cellHeight - 32 - 60
            if i == 1 then
                if myWeapon == nil or type(myWeapon) ~= "table" or SizeOfTable(myWeapon) == 0 then
                    swData = {{}, 0}
                else
                    swData = myWeapon
                end
            else
                if enemyWeapon == nil or type(enemyWeapon) ~= "table" or SizeOfTable(enemyWeapon) == 0 then
                    swData = {{}, 0}
                else
                    swData = enemyWeapon
                end
            end
            for j = 1, 6 do
                local posX = itemBg:getContentSize().width / 2 + (3 - 2 * i) * (spaceX + iconWidth) / 2 + math.floor((j - 1) / 3) * ((2 * i - 3) * (iconWidth + spaceX))
                local posY = firstPosY - iconWidth / 2 - math.floor((j - 1) % 3) * (iconWidth + 40)
                local swStr = swData[1][j]
                if swStr == nil or tonumber(swStr) == 0 then
                    local emptySp = CCSprite:createWithSpriteFrameName("superWeaponNull.png")
                    emptySp:setPosition(ccp(posX, posY))
                    emptySp:setScale(iconWidth / emptySp:getContentSize().width)
                    itemBg:addChild(emptySp)
                else
                    local arr = Split(swStr, "-")
                    local superWeaponId, lv = arr[1], arr[2]
                    local weaponSp = CCSprite:createWithSpriteFrameName(superWeaponCfg.weaponCfg[superWeaponId].icon)
                    if weaponSp then
                        weaponSp:setScale(iconWidth / weaponSp:getContentSize().width)
                        weaponSp:setPosition(ccp(posX, posY))
                        itemBg:addChild(weaponSp)
                        local lvBg = LuaCCScale9Sprite:createWithSpriteFrameName("newBlackFadeBar.png", CCRect(0, 0, 1, 9), function ()end)
                        lvBg:setRotation(180)
                        lvBg:setContentSize(CCSizeMake(60, 20))
                        lvBg:setPosition(weaponSp:getPositionX() + iconWidth / 2 - lvBg:getContentSize().width / 2 - 7, weaponSp:getPositionY() - iconWidth / 2 + lvBg:getContentSize().height / 2 + 4)
                        itemBg:addChild(lvBg, 1)
                        local levelLb = GetTTFLabel(getlocal("fightLevel", {lv}), fontSize - 4)
                        levelLb:setAnchorPoint(ccp(1, 0.5))
                        levelLb:setPosition(lvBg:getPositionX() + lvBg:getContentSize().width / 2 - 5, lvBg:getPositionY())
                        itemBg:addChild(levelLb, 2)
                    end
                end
            end
            local alignment, anchor, posX = kCCTextAlignmentLeft, ccp(0, 1), 20
            if i == 2 then
                alignment, anchor, posX = kCCTextAlignmentRight, ccp(1, 1), cellWidth / 2 - 20
            end
            local strengthLb = G_getRichTextLabel(getlocal("plane_power") .. "：" .. "<rayimg>"..FormatNumber((swData[2] or 0)) .. "<rayimg>", {nil, G_ColorYellowPro, nil}, fontSize - 2, 280, alignment, kCCVerticalTextAlignmentTop)
            strengthLb:setAnchorPoint(anchor)
            strengthLb:setPosition(posX, firstPosY - 3 * (iconWidth + spaceY))
            itemBg:addChild(strengthLb)
        end
    end
end

--获取战报军徽信息的高度
function G_getReportEmblemLayoutHeight()
    return 32 + 220
end

--获取战报军徽信息
function G_getReportEmblemLayout(cell, cellWidth, cellHeight, layerNum, report, isAttacker)
    local titleBg = G_createReportTitle(cellWidth - 20, getlocal("emblem_infoTitle"))
    titleBg:setAnchorPoint(ccp(0.5, 1))
    titleBg:setPosition(cellWidth / 2, cellHeight)
    cell:addChild(titleBg, 2)
    local fontSize = 20
    if report.emblemID then
        local emblem = report.emblemID or {nil, nil}
        local myEmblem, enemyEmblem
        if emblem then
            if isAttacker == true then
                myEmblem, enemyEmblem = (emblem[1] or nil), (emblem[2] or nil)
            else
                myEmblem, enemyEmblem = (emblem[2] or nil), (emblem[1] or nil)
            end
        end
        local iconWidth, spaceX, spaceY = 100, 40, 40
        for i = 1, 2 do
            local itemBgPic = (i == 1) and "reportBlueBg.png" or "reportRedBg.png"
            local itemBg = LuaCCScale9Sprite:createWithSpriteFrameName(itemBgPic, CCRect(4, 4, 1, 1), function ()end)
            itemBg:setContentSize(CCSizeMake(cellWidth / 2, cellHeight))
            itemBg:setPosition(cellWidth * (2 * i - 1) / 4, cellHeight / 2)
            cell:addChild(itemBg)
            
            local emblemId
            if i == 1 then
                emblemId = myEmblem
            else
                emblemId = enemyEmblem
            end
            local emblemSp, nameStr, color, strength
            if emblemId == nil or tonumber(emblemId) == 0 then
                emblemSp = CCSprite:createWithSpriteFrameName("emblemNull.png")
                nameStr = getlocal("skill_equip_empty2")
                color = G_ColorWhite
                strength = 0
            else
                emblemSp = emblemVoApi:getEquipIconNoBg(emblemId)
                nameStr = emblemVoApi:getEquipName(emblemId)
                color = emblemVoApi:getEquipColor(emblemId)
                strength = emblemVoApi:getEquipStrengthById(emblemId)
            end
            if nameStr then
                local nameLb = GetTTFLabelWrap(nameStr, fontSize, CCSizeMake(cellWidth / 2 - 30, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
                nameLb:setAnchorPoint(ccp(0.5, 1))
                nameLb:setPosition(itemBg:getContentSize().width / 2, cellHeight - 32 - 10)
                itemBg:addChild(nameLb)
                nameLb:setColor(color)
            end
            if emblemSp then
                emblemSp:setPosition(itemBg:getContentSize().width / 2, cellHeight - 32 - 60 - iconWidth / 2)
                emblemSp:setScale(iconWidth / emblemSp:getContentSize().width)
                itemBg:addChild(emblemSp)
            end
            local alignment, anchor, posX = kCCTextAlignmentLeft, ccp(0, 1), 20
            if i == 2 then
                alignment, anchor, posX = kCCTextAlignmentRight, ccp(1, 1), cellWidth / 2 - 20
            end
            local strengthStr = getlocal("plane_power") .. "：<rayimg>"..FormatNumber(strength) .. "<rayimg>"
            local strengthLb, lbheight = G_getRichTextLabel(strengthStr, {nil, G_ColorYellowPro, nil}, fontSize - 2, 280, alignment, kCCVerticalTextAlignmentTop)
            strengthLb:setAnchorPoint(anchor)
            strengthLb:setPosition(posX, emblemSp:getPositionY() - iconWidth / 2 - 20)
            itemBg:addChild(strengthLb)
        end
    end
end

--获取战报飞机信息的高度
function G_getReportPlaneLayoutHeight()
    return 32 + 220
end

--获取战报飞机技能信息的高度
function G_getReportPlaneSkillLayoutHeight()
    return 32 + 220
end

--获取战报军徽信息
function G_getReportPlaneLayout(cell, cellWidth, cellHeight, layerNum, report, isAttacker)
    local titleBg = G_createReportTitle(cellWidth - 20, getlocal("plane_infoTitle"))
    titleBg:setAnchorPoint(ccp(0.5, 1))
    titleBg:setPosition(cellWidth / 2, cellHeight)
    cell:addChild(titleBg, 2)
    local fontSize = 20
    if report.plane then
        local planeData = report.plane or {{0, 0}, {0, 0}}
        local myPlane, enemyPlane
        if isAttacker == true or isAttacker == nil then
            myPlane, enemyPlane = (planeData[1] or {0, 0}), (planeData[2] or {0, 0})
        else
            myPlane, enemyPlane = (planeData[2] or {0, 0}), (planeData[1] or {0, 0})
        end
        local iconWidth, spaceX, spaceY = 100, 40, 40
        for i = 1, 2 do
            local itemBgPic = (i == 1) and "reportBlueBg.png" or "reportRedBg.png"
            local itemBg = LuaCCScale9Sprite:createWithSpriteFrameName(itemBgPic, CCRect(4, 4, 1, 1), function ()end)
            itemBg:setContentSize(CCSizeMake(cellWidth / 2, cellHeight))
            itemBg:setPosition(cellWidth * (2 * i - 1) / 4, cellHeight / 2)
            cell:addChild(itemBg)
            
            local planeId, strength
            if i == 1 then
                planeId, strength = (myPlane[1] or 0), (myPlane[2] or 0)
            else
                planeId, strength = (enemyPlane[1] or 0), (enemyPlane[2] or 0)
            end
            local planeSp, nameStr, xixueStr
            if planeId == nil or tonumber(planeId) == 0 then
                planeSp = CCSprite:createWithSpriteFrameName("planeNull.png")
                nameStr = getlocal("skill_equip_empty2")
            else
                planeSp = planeVoApi:getPlaneIconNoBg(itemBg, planeId, nil, true)
                nameStr = getlocal("plane_name_"..planeId)
                
                if report.xixue == 1 then
                    if isAttacker == true and i == 1 then
                        xixueStr = getlocal("battleLogEffectXiXue")
                    elseif isAttacker ~= true and i == 2 then
                        xixueStr = getlocal("battleLogEffectXiXue")
                    end
                end
            end
            if nameStr then
                local nameLb = GetTTFLabelWrap(nameStr, fontSize, CCSizeMake(cellWidth / 2 - 30, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
                nameLb:setAnchorPoint(ccp(0.5, 1))
                nameLb:setPosition(itemBg:getContentSize().width / 2, cellHeight - 32 - 10)
                itemBg:addChild(nameLb)
            end
            if xixueStr then
                -- 戏谑是否生效
                local xixueLb = GetTTFLabelWrap(xixueStr, fontSize, CCSizeMake(cellWidth / 2 - 30, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
                xixueLb:setAnchorPoint(ccp(0.5, 1))
                xixueLb:setPosition(itemBg:getContentSize().width / 2, cellHeight - 32 - 10 - 24)
                xixueLb:setColor(G_ColorYellowPro)
                itemBg:addChild(xixueLb)
            end
            if planeSp then
                planeSp:setPosition(itemBg:getContentSize().width / 2, cellHeight - 32 - 60 - iconWidth / 2)
                planeSp:setScale(iconWidth / planeSp:getContentSize().width)
                itemBg:addChild(planeSp)
            end
            local alignment, anchor, posX = kCCTextAlignmentLeft, ccp(0, 1), 20
            if i == 2 then
                alignment, anchor, posX = kCCTextAlignmentRight, ccp(1, 1), cellWidth / 2 - 20
            end
            local strengthStr = getlocal("plane_power") .. "：<rayimg>"..FormatNumber(strength) .. "<rayimg>"
            local strengthLb, lbheight = G_getRichTextLabel(strengthStr, {nil, G_ColorYellowPro, nil}, fontSize - 2, 280, alignment, kCCVerticalTextAlignmentTop)
            strengthLb:setAnchorPoint(anchor)
            strengthLb:setPosition(posX, planeSp:getPositionY() - iconWidth / 2 - 20)
            itemBg:addChild(strengthLb)
        end
    end
end

--获取战报飞机技能信息
function G_getReportPlaneSkillLayout(cell, cellWidth, cellHeight, layerNum, report, isAttacker)
    local titleBg = G_createReportTitle(cellWidth - 20, getlocal("report_planeSkillInfoText"))
    titleBg:setAnchorPoint(ccp(0.5, 1))
    titleBg:setPosition(cellWidth / 2, cellHeight)
    cell:addChild(titleBg, 2)
    local fontSize = 20
    if report.plane then
        local planeData = report.plane or {{0, 0}, {0, 0}}
        local myPlane, enemyPlane
        if isAttacker == true or isAttacker == nil then
            myPlane, enemyPlane = (planeData[1] or {0, 0}), (planeData[2] or {0, 0})
        else
            myPlane, enemyPlane = (planeData[2] or {0, 0}), (planeData[1] or {0, 0})
        end
        local iconWidth, spaceX, spaceY = 100, 40, 40
        for i = 1, 2 do
            local itemBgPic = (i == 1) and "reportBlueBg.png" or "reportRedBg.png"
            local itemBg = LuaCCScale9Sprite:createWithSpriteFrameName(itemBgPic, CCRect(4, 4, 1, 1), function ()end)
            itemBg:setContentSize(CCSizeMake(cellWidth / 2, cellHeight))
            itemBg:setPosition(cellWidth * (2 * i - 1) / 4, cellHeight / 2)
            cell:addChild(itemBg)
            
            local planeSkillId, strength = 0, 0
            if i == 1 then
                planeSkillId = myPlane[3]
            else
                planeSkillId = enemyPlane[3]
            end
            local planeSkillSp, nameStr, nameColor
            if planeSkillId == nil or tonumber(planeSkillId) == 0 then
                planeSkillSp = CCSprite:createWithSpriteFrameName("activeSkillBg1.png")
                nameStr = getlocal("skill_equip_empty2")
            else
                planeSkillSp = planeVoApi:getSkillIcon(planeSkillId, iconWidth)
                nameStr = planeVoApi:getSkillInfoById(planeSkillId, true)
                local scfg, gcfg = planeVoApi:getSkillCfgById(planeSkillId)
                nameColor = planeVoApi:getColorByQuality(gcfg.color)
                strength = gcfg.skillStrength
            end
            if nameStr then
                local nameLb = GetTTFLabelWrap(nameStr, fontSize, CCSizeMake(cellWidth / 2 - 30, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
                nameLb:setAnchorPoint(ccp(0.5, 1))
                nameLb:setPosition(itemBg:getContentSize().width / 2, cellHeight - 32 - 10)
                if nameColor then
                    nameLb:setColor(nameColor)
                end
                itemBg:addChild(nameLb)
            end
            if planeSkillSp then
                planeSkillSp:setPosition(itemBg:getContentSize().width / 2, cellHeight - 32 - 60 - iconWidth / 2)
                planeSkillSp:setScale(iconWidth / planeSkillSp:getContentSize().width)
                itemBg:addChild(planeSkillSp)
            end
            local alignment, anchor, posX = kCCTextAlignmentLeft, ccp(0, 1), 20
            if i == 2 then
                alignment, anchor, posX = kCCTextAlignmentRight, ccp(1, 1), cellWidth / 2 - 20
            end
            local strengthStr = getlocal("plane_skill_powerText") .. "：<rayimg>"..FormatNumber(strength) .. "<rayimg>"
            local strengthLb, lbheight = G_getRichTextLabel(strengthStr, {nil, G_ColorYellowPro, nil}, fontSize - 2, 280, alignment, kCCVerticalTextAlignmentTop)
            strengthLb:setAnchorPoint(anchor)
            strengthLb:setPosition(posX, planeSkillSp:getPositionY() - iconWidth / 2 - 20)
            itemBg:addChild(strengthLb)
        end
    end
end

--显示战报地形信息
--_aIslandID,_dIslandID: 攻/守方地形ID
function G_showReportIslandInfo(layerNum, _aIslandID, _dIslandID)
    local sd = smallDialog:new()
    sd.isUseAmi = true
    local bgSize = CCSizeMake(450, 300)
    if _aIslandID and _dIslandID == nil then
        bgSize.height = 200
    end
    local function closeCallBack()
        sd:close()
    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg1.png", CCRect(30, 30, 1, 1), closeCallBack)
    sd.dialogLayer = CCLayer:create()
    sd.bgLayer = dialogBg
    sd.bgLayer:setContentSize(bgSize)
    sd:show()
    
    local tabContent = {}
    local function addContent(_islandID)
        local attackCfg = worldGroundCfg[_islandID]
        for k, v in pairs(attackCfg.attType) do
            local valueStr, color
            if attackCfg.attValue[k] > 0 then
                valueStr = "+"..attackCfg.attValue[k]
                color = G_ColorGreen
            else
                valueStr = attackCfg.attValue[k]
                color = G_ColorRed
            end
            valueStr = getlocal("world_ground_effect_"..v) .. " "..valueStr.."%"
            table.insert(tabContent, {valueStr, color})
        end
    end
    if _aIslandID then
        local _str = ""
        if _dIslandID then
            _str = getlocal("battleCamp1") .. "["..getlocal("world_ground_name_".._aIslandID) .. "]"
        else
            _str = getlocal("world_ground_name_".._aIslandID)
        end
        table.insert(tabContent, {_str, G_ColorWhite})
        addContent(_aIslandID)
    end
    
    if _aIslandID and _dIslandID then
        local _str = getlocal("battleCamp2") .. "["..getlocal("world_ground_name_".._dIslandID) .. "]"
        table.insert(tabContent, {_str, G_ColorWhite})
        addContent(_dIslandID)
    end
    
    local startX = 0
    local spaceY = 10
    local totalHeight = 0
    local valueHeight = {}
    local _valueHeightIndex = 0
    for k, v in pairs(tabContent) do
        local _fontSize = 20
        if (k - 1) % 3 == 0 then
            _fontSize = 22
            _valueHeightIndex = _valueHeightIndex + 1
            valueHeight[_valueHeightIndex] = 0
        end
        local lb = GetTTFLabel(v[1], _fontSize)
        if lb:getContentSize().width > startX then
            startX = lb:getContentSize().width
        end
        totalHeight = totalHeight + lb:getContentSize().height + spaceY
        if (k - 1) % 3 ~= 0 then
            valueHeight[_valueHeightIndex] = valueHeight[_valueHeightIndex] + lb:getContentSize().height + spaceY
        end
    end
    totalHeight = totalHeight - spaceY
    startX = (bgSize.width - startX) / 2
    local startY = (bgSize.height + totalHeight) / 2
    _valueHeightIndex = 0
    for k, v in pairs(tabContent) do
        local _posX = startX
        local _fontSize = 20
        local valueBg
        if (k - 1) % 3 == 0 then
            _posX = startX - 130
            _fontSize = 22
            _valueHeightIndex = _valueHeightIndex + 1
            local valueBgHeight = valueHeight[_valueHeightIndex]
            valueBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png", CCRect(20, 20, 1, 1), function()end)
            valueBg:setContentSize(CCSizeMake(bgSize.width - _posX * 2, valueBgHeight))
            valueBg:setAnchorPoint(ccp(0.5, 1))
        else
            _posX = startX - 80
        end
        local lb = GetTTFLabel(v[1], _fontSize)
        lb:setAnchorPoint(ccp(0, 1))
        lb:setPosition(_posX, startY)
        lb:setColor(v[2])
        sd.bgLayer:addChild(lb, 1)
        startY = lb:getPositionY() - lb:getContentSize().height - spaceY
        if valueBg then
            valueBg:setPosition(bgSize.width / 2, startY + spaceY / 2)
            sd.bgLayer:addChild(valueBg)
        end
    end
    
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), closeCallBack)
    touchDialogBg:setTouchPriority(-(layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(sd.dialogLayer))
    sd.dialogLayer:addChild(touchDialogBg, 1)
    
    sd.bgLayer:setPosition(getCenterPoint(sd.dialogLayer))
    sd.dialogLayer:addChild(sd.bgLayer, 2)
    sd.dialogLayer:setTouchPriority(-(layerNum - 1) * 20 - 1)
    
    -- 下面的点击屏幕继续
    G_addArrowPrompt(sd.bgLayer)
    
    sceneGame:addChild(sd.dialogLayer, layerNum)
end

--popKey：花费金币二次确认弹窗的key
function G_showBatchBuyPropSmallDialog(_pid, layerNum, callBack, btnStr, limitNum, truePrice, popKey)
    local _price = propCfg[_pid].gemCost
    if playerVoApi:getGems() < _price then
        GemsNotEnoughDialog(nil, nil, _price - playerVoApi:getGems(), layerNum, _price)
        do return end
    end
    local function touchBuy(num)
        local function realBuy()
            local function callbackBuyprop(fn, data)
                if base:checkServerData(data) == true then
                    --统计购买物品
                    statisticsHelper:buyItem(_pid, _price, 1, _price)
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("buyPropPrompt", {getlocal(propCfg[_pid].name)}), 28)
                    if callBack then
                        callBack()
                    end
                end
            end
            socketHelper:buyProc(RemoveFirstChar(_pid), callbackBuyprop, num)
        end
        if popKey then
            local costGems = num * _price
            local function secondTipFunc(sbFlag)
                local sValue = base.serverTime .. "_" .. sbFlag
                G_changePopFlag(popKey, sValue)
            end
            if G_isPopBoard(popKey) then
                G_showSecondConfirm(layerNum + 1, true, true, getlocal("dialog_title_prompt"), getlocal("second_tip_des", {costGems}), true, realBuy, secondTipFunc)
                do return end
            else
                realBuy()
            end
        else
            realBuy()
        end
    end
    shopVoApi:showBatchBuyPropSmallDialog(_pid, layerNum, touchBuy, btnStr, limitNum, truePrice)
end

--给一个精灵添加晃动动画
function G_addShake(target, shakeRange, shakeRate, repeatNum, dt)
    if target == nil then
        do return end
    end
    local time = shakeRate or 0.1
    local range = shakeRange or 20
    local delayTime = dt or 2
    local rotate1 = CCRotateTo:create(time, range)
    local rotate2 = CCRotateTo:create(2 * time, -range)
    local rotate3 = CCRotateTo:create(2 * time, range / 2)
    local rotate4 = CCRotateTo:create(2 * time, -range / 2)
    local rotate5 = CCRotateTo:create(time, 0)
    local delay = CCDelayTime:create(delayTime)
    local acArr = CCArray:create()
    acArr:addObject(rotate1)
    acArr:addObject(rotate2)
    acArr:addObject(rotate3)
    acArr:addObject(rotate4)
    acArr:addObject(rotate5)
    acArr:addObject(delay)
    local seq = CCSequence:create(acArr)
    if repeatNum and repeatNum > 0 then
        target:runAction(CCRepeat:create(seq, num))
    else
        target:runAction(CCRepeatForever:create(seq))
        
    end
end

--获取指定月份的总天数
function G_getMonthDay(month, year)
    --获取月份对应的天数
    local daysOfNormalMonthCfg = {[1] = 31, [2] = nil, [3] = 31, [4] = 30, [5] = 31, [6] = 30, [7] = 31, [8] = 31, [9] = 30, [10] = 31, [11] = 30, [12] = 31}
    local date = G_getDate(base.serverTime)
    local year, month = (year or date.year), (month or date.month)
    if month == 2 then
        if (year % 4 == 0 and year % 100 ~= 0) or (year % 100 == 0 and year % 400 == 0) then
            return 29
        else
            return 28
        end
    else
        return daysOfNormalMonthCfg[month]
    end
end

--获取当前时间距离本月末的时间
function G_getIntervalTimeEOM()
    local eomTs = G_getEOM()
    return eomTs - base.serverTime
end

--获取本月末时间戳
function G_getEOM()
    local date = G_getDate(base.serverTime)
    local weeTs = G_getWeeTs(base.serverTime) --当天零点时间戳
    local monthDay = G_getMonthDay() --本月总天数
    return weeTs + (monthDay - date.day + 1) * 86400--本月末时间戳
end

--获取本月初时间戳
function G_getBOM()
    local date = G_getDate(base.serverTime)
    local weeTs = G_getWeeTs(base.serverTime) --当天零点时间戳
    return weeTs - (date.day - 1) * 86400
end

function G_formatSecond(sc, useT)--useT:1 天 2 小时 3 分钟 （没有的逻辑 自己加上）
    if useT == 1 then
        return sc >= 86400 and sc / 86400 or 0
    elseif useT == 2 then
        
    elseif useT == 3 then
    end
end

--关闭所有打开的小面板
function G_closeAllSmallDialog()
    for k, v in pairs(G_SmallDialogDialogTb) do
        local dialog = G_SmallDialogDialogTb[k]
        if(dialog and dialog.forceClose)then
            dialog:forceClose()
        elseif dialog ~= nil and dialog.close then
            dialog:close()
        end
    end
    G_SmallDialogDialogTb = {}
end

--根据属性的类型来获取其数据
function G_getAttributeInfoByType(attType)
    local buffId = buffKeyMatchCodeCfg[attType]
    if buffId and buffEffectCfg[buffId] then
        return buffEffectCfg[buffId]
    end
    return nil
end

--获取指定长度的字符串，超出部分用...替代
--@param    str:要切割的字符串
--@param    splitlen：显示英文字个数，中文字为2的倍数,包含了...的长度
function G_getShortStr(str, splitlen)
    if str == nil or splitlen == nil then
        return ""
    end
    local nLenInByte = #str--G_utfstrlen(str, true)
    if nLenInByte <= splitlen then
        return str
    end
    splitlen = splitlen - 3
    local cnt = 0
    local showStr = ""
    for i = 1, nLenInByte do
        local curByte = string.byte(str, i)
        local byteCount = 0
        if curByte > 0 and curByte <= 127 then
            byteCount = 1
        elseif curByte >= 192 and curByte < 223 then
            byteCount = 2
        elseif curByte >= 224 and curByte < 239 then
            byteCount = 3
        elseif curByte >= 240 and curByte <= 247 then
            byteCount = 4
        end
        local subChar = nil
        if byteCount > 0 then
            subChar = string.sub(str, i, i + byteCount - 1)
            i = i + byteCount - 1
        end
        if G_curPlatName() == "21" or G_curPlatName() == "androidarab" then
            cnt = cnt + 1
        else
            if byteCount == 1 then
                cnt = cnt + 1
            elseif byteCount > 1 then
                cnt = cnt + 2
            end
        end
        -- print("cnt,splitlen,byteCount,subChar--->>>",cnt,splitlen,byteCount,subChar)
        if cnt <= splitlen then
            if subChar and subChar ~= "" then
                showStr = showStr .. subChar
            end
            -- print("showStr--->>>",showStr)
        else
            do break end
        end
    end
    showStr = showStr .. "..."
    
    return showStr
end

-- 通过pid获取完整格式的道具项目
function GetItembyPid(pid)
    local formatData = {}
    local key = pid
    local type1 = "p"
    local name = ""
    local pic = ""
    local desc = ""
    local id = 0
    local index = 0
    local eType = ""
    local bgname = nil
    local equipId
    name, pic, desc, id, index, eType, equipId = getItem(key, type1)
    table.insert(formatData, {name = name, pic = pic, desc = desc, id = id, type = type1, index = index, key = key, eType = eType, equipId = equipId, bgname = bgname})
    return formatData
end

-- 获取k-v table的size
function G_getSizeForKV(tb)
    local count = 0
    for k, v in pairs(tb) do
        count = count + 1
    end
    return count
end

--获取格式化之后的道具描述
function G_getItemDesc(item)
    local desc = ""
    if item.type == "p" then
        if tonumber(item.id) and tonumber(item.id) > 4819 and tonumber(item.id) < 4828 then
            desc = getlocal(item.desc, {propCfg["p"..item.id].composeGetProp[1]})
        else
            desc = getlocal(item.desc)
        end
    elseif item.type == "w" then
        if item.eType == "f" or item.eType == "c" then
            desc = item.desc
        else
            desc = getlocal(item.desc)
        end
    elseif item.type == "am" then
        if item.key == "exp" then
            desc = getlocal(item.desc)
        else
            desc = item.desc
        end
    else
        desc = getlocal(item.desc)
    end
    return desc
end

--十进制转二进制
function G_Dec2Bin(dec)
    local temp = {}
    local quo
    while (dec > 0) do
        quo = dec % 2
        dec = math.floor(dec / 2)
        table.insert(temp, quo)
    end
    return temp
end

--二进制转十进制
function G_Bin2Dec(binTb)
    local dec = 0
    for k, v in pairs(binTb) do
        dec = dec + tonumber(v) * (2 ^ (k - 1))
    end
    return math.floor(dec)
end

--十进制按位与
function G_BitwiseAND(dec1, dec2)
    local bin1 = G_Dec2Bin(dec1)
    local bin2 = G_Dec2Bin(dec2)
    local n1, n2 = #bin1, #bin2
    local n = n1 > n2 and n1 or n2
    for k = 1, n do
        bin2[k] = tonumber(bin2[k] or 0) * tonumber(bin1[k] or 0)
    end
    return G_Bin2Dec(bin2)
end
--x轴下 取两点之间的角度
function G_getAngle(clockwise, p1, p2)--clockwise :顺时针 p1:起始坐标，p2:终点坐标    
    if clockwise then
        local angle = math.atan2((p2.y - p1.y), (p2.x - p1.x))--弧度
        local theta = angle * (180 / math.pi)--角度 math.pi:圆周率
        return theta
    else
        local angle = math.atan2((p1.y - p2.y), (p2.x - p1.x))--弧度
        local theta = angle * (180 / math.pi)--角度 math.pi:圆周率
        return theta
    end
end
--两点之间直线距离
function G_straightLineDistance(p1, p2)
    local xx = (p1.x - p2.x) * (p1.x - p2.x)
    local yy = (p1.y - p2.y) * (p1.y - p2.y)
    local value = math.abs(math.sqrt(xx + yy))
    return value
end

--战报部队信息cell的高度
function G_getBattleReportAITroopsHeight()
    return 32 + 3 * (100 + 40) + 40 + 60 --icon的尺寸100，间距40
end

--战报部队信息
function G_getBattleReportAITroopsLayout(cell, cellWidth, cellHeight, aitroops, layerNum, report, isAttacker, isVisibleTitleLine)
    local titleBg = G_createReportTitle(cellWidth - 20, getlocal("aitroopsInformation"), isVisibleTitleLine)
    titleBg:setAnchorPoint(ccp(0.5, 1))
    titleBg:setPosition(cellWidth / 2, cellHeight)
    cell:addChild(titleBg, 2)
    local fontSize = 20
    local iconWidth, spaceX, spaceY = 100, 40, 40
    local aitroopsTb
    if isAttacker == true then
        aitroopsTb = aitroops
    else
        aitroopsTb = {aitroops[2], aitroops[1]}
    end
    for i = 1, 2 do
        local itemBgPic = (i == 1) and "reportBlueBg.png" or "reportRedBg.png"
        local itemBg = LuaCCScale9Sprite:createWithSpriteFrameName(itemBgPic, CCRect(4, 4, 1, 1), function ()end)
        itemBg:setContentSize(CCSizeMake(cellWidth / 2, cellHeight))
        itemBg:setPosition(cellWidth * (2 * i - 1) / 4, cellHeight / 2)
        cell:addChild(itemBg)
        for kidx = 1, 2 do
            local battleIndexStr = (kidx == 1) and getlocal("front") or getlocal("back")
            local posX = itemBg:getContentSize().width / 2 + (3 - 2 * i) * (spaceX + iconWidth) / 2 + (kidx - 1) * ((2 * i - 3) * (iconWidth + spaceX))
            local indexLb = GetTTFLabel(battleIndexStr, 20)
            indexLb:setAnchorPoint(ccp(0.5, 1))
            indexLb:setPosition(posX, cellHeight - 32 - 20)
            itemBg:addChild(indexLb)
        end
        
        local firstPosY = cellHeight - 32 - 60
        
        local aitb = aitroopsTb[i][1] or {}
        for j = 1, 6 do
            local posX = itemBg:getContentSize().width / 2 + (3 - 2 * i) * (spaceX + iconWidth) / 2 + math.floor((j - 1) / 3) * ((2 * i - 3) * (iconWidth + spaceX))
            local posY = firstPosY - iconWidth / 2 - math.floor((j - 1) % 3) * (iconWidth + 40)
            
            local aitInfo = aitb[j]
            if aitInfo then
                aitInfo = Split(aitInfo, "-")
                local atid, lv, grade = aitInfo[1], aitInfo[2], (aitInfo[3] or 1)
                if atid and tonumber(atid) ~= 0 and atid ~= "" and lv then
                    local aitroopsIcon = AITroopsVoApi:getAITroopsSimpleIcon(atid, lv, grade, false)
                    aitroopsIcon:setPosition(posX, posY)
                    aitroopsIcon:setScale(iconWidth / aitroopsIcon:getContentSize().width)
                    itemBg:addChild(aitroopsIcon)
                else
                    local tankIconBg = CCSprite:createWithSpriteFrameName("troopNull.png")
                    tankIconBg:setPosition(ccp(posX, posY))
                    tankIconBg:setScale(iconWidth / tankIconBg:getContentSize().width)
                    itemBg:addChild(tankIconBg)
                end
            else
                local tankIconBg = CCSprite:createWithSpriteFrameName("troopNull.png")
                tankIconBg:setPosition(ccp(posX, posY))
                tankIconBg:setScale(iconWidth / tankIconBg:getContentSize().width)
                itemBg:addChild(tankIconBg)
            end
        end
        
        local strength = aitroopsTb[i][2] or 0
        local alignment, anchor, posX = kCCTextAlignmentLeft, ccp(0, 1), 20
        if i == 2 then
            alignment, anchor, posX = kCCTextAlignmentRight, ccp(1, 1), cellWidth / 2 - 20
        end
        local strengthStr = getlocal("plane_power") .. "：" .. "<rayimg>"..FormatNumber(strength) .. "<rayimg>"
        local strengthLb = G_getRichTextLabel(strengthStr, {nil, G_ColorYellowPro, nil}, fontSize, 280, alignment, kCCVerticalTextAlignmentTop)
        strengthLb:setAnchorPoint(anchor)
        strengthLb:setPosition(posX, firstPosY - 3 * (iconWidth + spaceY))
        itemBg:addChild(strengthLb)
    end
end

--判断战报中是否显示AI部队
function G_isShowAITroopsInReport(report)
    if base.AITroopsSwitch == 1 and report and report.aitroops then
        local hasAI = false
        for k, v in pairs(report.aitroops) do
            if v[1] and type(v[1]) == "table" then
                for kk, vv in pairs(v[1]) do
                    if vv and tonumber(vv) ~= 0 and vv ~= "" then
                        hasAI = true
                    end
                end
            end
        end
        return hasAI
    end
    return false
end

--设置混合模式
function G_setBlendFunc(sprite, src, dst)
    if sprite == nil or (src == nil and dst == nil) then
        do return end
    end
    local blendFunc = ccBlendFunc:new()
    if src then
        blendFunc.src = src
    end
    if dst then
        blendFunc.dst = dst
    end
    sprite:setBlendFunc(blendFunc)
end

--获得当前充值金币对应名称
function G_getCurMoneyName()
    local moneyName = ""
    if(G_curPlatName() == "11"or G_curPlatName() == "androidsevenga")then
        local tmpTb = {}
        tmpTb["action"] = "customAction"
        tmpTb["parms"] = {}
        tmpTb["parms"]["value"] = "getCurrency"
        local cjson = G_Json.encode(tmpTb)
        moneyName = G_accessCPlusFunction(cjson)
        if(moneyName ~= "EUR" and moneyName ~= "CHF")then
            moneyName = "EUR"
        end
    else
        moneyName = GetMoneyName()
    end
    return moneyName
end

-- 获取礼包图标
-- 需要事先加载 packsImage 和 acThfb 两个plist
function G_getPacksImg(id, num)
    local imgStr
    if tonumber(id) == 1 then
        -- 特等奖
        imgStr = "gold_pack.png"
    else
        imgStr = "packs" .. (num - id + 2) .. ".png"
    end
    return imgStr
end

--领取成功/也可输出其他文字
function G_ShowFloatingBoard(newStr)
    local showStr = newStr or getlocal("receivereward_received_success")
    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), showStr, 28)
end

--解析新增的战报数据（以后战报新增功能数据都放在这里）
function G_formatExtraReportInfo(ri)
    --ri={{攻击方},{防守方}}
    local tskinList = {{}, {}}--坦克皮肤数据
    if ri then --战报额外信息
        local attackerInfo = ri[1] or {} --进攻方数据
        local defenderInfo = ri[2] or {} --防守方数据
        tskinList = {attackerInfo[1] or {}, defenderInfo[1] or {}} --第一个字段代表部队坦克皮肤的数据（key为坦克id，value为皮肤id）
    end
    return tskinList
end

--清空设置部队页面的数据
function G_clearEditTroopsLayer(battleType)
    if G_editLayer[battleType] and G_editLayer[battleType].dispose then
        G_editLayer[battleType]:dispose()
    end
end

--补充道具（目前策划那边要求在用道具执行某些操作时，当道具不足需要直接弹板提示用金币补充道具来执行此操作）
function G_supplyPropConfirmHandler(propId, buyNum, confirmStr, supplyCallBack, layerNum)
    local pid = tonumber(propId) and ("p"..propId) or propId
    local price = propCfg[pid].gemCost
    local gemCost = buyNum * price --消耗的金币数
    
    local function confirmHandler()
        local gemsNum = playerVoApi:getGems()
        if gemsNum < gemCost then --金币不足则跳转充值页面
            GemsNotEnoughDialog(nil, nil, gemCost - gemsNum, layerNum, gemCost)
        else
            local function buyHandler(fn, data)
                local ret, sData = base:checkServerData(data)
                if ret == true then
                    if supplyCallBack then
                        supplyCallBack()
                    end
                    --统计购买的道具
                    statisticsHelper:buyItem(pid, price, buyNum, gemCost)
                end
            end
            --购买需要补充的道具
            local id = tonumber(RemoveFirstChar(pid))
            socketHelper:buyProc(id, buyHandler, buyNum)
        end
    end
    G_showSecondConfirm(layerNum, true, true, getlocal("dialog_title_prompt"), confirmStr, false, confirmHandler)
end

--是否提审版本
function G_isApplyVersion()
    -- do return true end
    if G_curPlatName() == "androidewantest" then
        return true
    end
    if G_curPlatName() ~= "66" then
        if tonumber(base.curZoneID) == 999 then
            return true
        end
    end
    if PlatformManage ~= nil and PlatformManage:shared().getAudit and PlatformManage:shared():getAudit() == "1" then
        return true
    end
    return false
end

function G_checkUseAuditUI()
    if G_isApplyVersion() == true and G_curPlatName() == "66" then
        return true
    end
    return false
end

function G_notShowWorldMap()
    if G_isApplyVersion() == true and G_curPlatName() ~= "androidewantest" and G_curPlatName() ~= "0" then
        return true
    end
    return false
end

function G_setShaderProgramAllChildren(childObj, callBack)
    do 
        return 
    end
    if tolua.cast(childObj, "CCNode") then
        local childArray = childObj:getChildren()
        if tolua.cast(childArray, "CCArray") then
            local childCount = childArray:count()
            for i = 0, childCount - 1 do
                local obj = childArray:objectAtIndex(i)
                --过滤掉CCLabelTTF文本组件
                -- if tolua.cast(obj, "CCLabelTTF") == nil and type(callBack) == "function" then
                if obj and obj.setString == nil and type(callBack) == "function" then
                    -- if type(callBack) == "function" then
                    callBack(obj)
                end
                G_setShaderProgramAllChildren(obj, callBack)
            end
        end
    end
end

--设置透明度穿透
function G_setCascadeOpacityEnabled(ccNode, cascadeOpacityEnabled)
    if type(cascadeOpacityEnabled) ~= "boolean" then
        return
    end
    if ccNode then
        if ccNode.setCascadeOpacityEnabled then
            ccNode:setCascadeOpacityEnabled(cascadeOpacityEnabled)
        else
            local childArray = ccNode:getChildren()
            if tolua.cast(childArray, "CCArray") then
                local childCount = childArray:count()
                for i = 0, childCount - 1 do
                    local obj = childArray:objectAtIndex(i)
                    if obj and obj.setOpacity then
                        obj:setOpacity(cascadeOpacityEnabled and ccNode:getOpacity() or 255)
                    end
                end
            end
        end
    end
end

--是否使用老的登录显示
function G_isUseOldLogin()
    do 
        return false 
    end
    if G_curPlatName() == "66" then
        return true
    end
    return false
end

--矿点(目前只支持基础矿)icon 和 name
function G_getMineIconAndName(newType, layerNum, callback, newAnchPoint, touchLevel, iconBg, iconSize, iconBgSize)
    if not touchLevel then
        touchLevel = 2
    end
    
    if not iconBg then
        iconBg = "Icon_BG.png"
    end
    if not iconSize then
        iconSize = 70
    end
    if not iconBgSize then
        iconBgSize = 100
    end
    local mineIconStr, mineName = nil, nil
    if mapScoutCfg and mapScoutCfg.common then
        for k, v in pairs(mapScoutCfg.common) do
            if v.type == newType then
                mineIconStr = v.icon
                mineName = getlocal(v.name)
                do break end
            end
        end
    end
    if not mineIconStr then print("<<<<<<<  e r r o r --- t y p e  >>>>>>>", newType) do return end end

    local function touchSpIcon(object, fn, idx)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        if callBack then
            callBack(object, fn, idx)
        end
    end
    
    local mineIcon = GetBgIcon(mineIconStr, touchSpIcon, iconBg, iconSize, iconBgSize)
    mineIcon:setTouchPriority(-(layerNum - 1) * 20 - touchLevel)
    if newAnchPoint then
        mineIcon:setAnchorPoint(newAnchPoint)
    end
    return mineIcon, mineName
end

function G_getHistoryAccount()
    if G_isBindMailAndResetPwd() == false then
        do return end
    end

    local accountListJsonStr = CCUserDefault:sharedUserDefault():getStringForKey("rayjoyHistoryAccountList")
    local accountList
    if accountListJsonStr and accountListJsonStr ~= "" then
        accountList = G_Json.decode(accountListJsonStr)
        if type(accountList) == "table" then
            table.sort(accountList, function(a, b) return tonumber(a[3]) > tonumber(b[3]) end)
        end
    end
    return accountList
end

function G_saveHistoryAccount(accountDataTb, isResetSave)
    if G_isBindMailAndResetPwd() == false then
        do return end
    end
    
    if type(accountDataTb) ~= "table" then
        do return end
    end
    local accountList
    if isResetSave == true then
        accountList = accountDataTb
    else
        local MAX_HISTORY_ACCOUNT_COUNT = 10 --最大历史账号个数
        accountList = G_getHistoryAccount()
        if accountList then
            table.sort(accountList, function(a, b) return tonumber(a[3]) > tonumber(b[3]) end)
            local isExist = false
            for k, v in pairs(accountList) do
                if k > MAX_HISTORY_ACCOUNT_COUNT then
                    break
                end
                if v[1] == accountDataTb[1] then
                    accountList[k][2] = accountDataTb[2]
                    accountList[k][3] = accountDataTb[3]
                    isExist = true
                    break
                end
            end
            if isExist == false then
                table.insert(accountList, 1, accountDataTb)
                local accountListSize = SizeOfTable(accountList)
                if accountListSize > MAX_HISTORY_ACCOUNT_COUNT then
                    for i = 1, accountListSize - MAX_HISTORY_ACCOUNT_COUNT do
                        table.remove(accountList, SizeOfTable(accountList))
                    end
                end
            end
        else
            accountList = {accountDataTb}
        end
    end
    CCUserDefault:sharedUserDefault():setStringForKey("rayjoyHistoryAccountList", G_Json.encode(accountList))
end

--登录界面是否显示智齿客服系统
function G_isShowContactSys()
    if G_curPlatName() == "0" or G_curPlatName() == "51" or G_curPlatName() == "58" or G_curPlatName() == "60" or G_curPlatName() == "5" or G_curPlatName() == "flandroid" or G_curPlatName() == "63" or G_curPlatName() == "flandroid_rgame" or G_curPlatName() == "68" then
        return true
    end
    return false
end

--显示智齿客服系统
function G_showZhichiContactSys()
    local tmpTb = {}
    tmpTb["action"] = "openUrl"
    tmpTb["parms"] = {}
    tmpTb["parms"]["url"] = "https://www.sobot.com/chat/pc/index.html?sysNum=6456e9315f4948b0922d5aec9c84190d"
    tmpTb["parms"]["connect"] = "https://www.sobot.com/chat/pc/index.html?sysNum=6456e9315f4948b0922d5aec9c84190d"
    local cjson = G_Json.encode(tmpTb)
    G_accessCPlusFunction(cjson)
end

-- 解析 desc
function G_formatStr(item)
    if item.finalDesc == true then
        desStr = item.desc
    elseif((item.type == "w" and item.eType == "f") or (item.eType == "c" and item.type == "w"))then
        desStr = item.desc
    elseif item.noLocal then
        desStr = item.desc
    else
        -- if tonumber(item.id) and item.id > 4823 and item.id <4828 then
        if (tonumber(item.id) and item.id > 4819 and item.id < 4828) or (tonumber(item.id) and propCfg["p"..item.id] and propCfg["p"..item.id].composeGetProp) then
            desStr = getlocal(item.desc, {propCfg["p"..item.id].composeGetProp[1]})
        else
            desStr = getlocal(item.desc)
        end
    end
    return desStr
end

--跳转强制更新的链接
function G_goForceUpdateUrl()
    local tmpTb = {}
    tmpTb["action"] = "openUrl"
    tmpTb["parms"] = {}
    --飞流正版老包跳转下载巨兽崛起新包
    if(G_curPlatName() == "58" or G_curPlatName() == "60" or G_curPlatName() == "5")then
        tmpTb["parms"]["url"] = "https://itunes.apple.com/cn/app/%E5%9D%A6%E5%85%8B%E9%A3%8E%E4%BA%91-%E5%B7%A8%E5%85%BD%E5%B4%9B%E8%B5%B7/id1434663744?mt=8"
        tmpTb["parms"]["connect"] = "https://itunes.apple.com/cn/app/%E5%9D%A6%E5%85%8B%E9%A3%8E%E4%BA%91-%E5%B7%A8%E5%85%BD%E5%B4%9B%E8%B5%B7/id1434663744?mt=8"
    elseif G_curPlatName() == "flandroid" then
        tmpTb["parms"]["url"] = "http://tank-android-download.raygame1.com/download/tank_v1.0_1_c1.apk"
        tmpTb["parms"]["connect"] = "http://tank-android-download.raygame1.com/download/tank_v1.0_1_c1.apk"
    elseif G_curPlatName() == "63" then
        tmpTb["parms"]["url"] = "https://www.xyzs.com/app/100004712.html"
        tmpTb["parms"]["connect"] = "https://www.xyzs.com/app/100004712.html"
    end
    local cjson = G_Json.encode(tmpTb)
    G_accessCPlusFunction(cjson)
end

--是否弹出强制迁移的公告
function G_isForceMigration()
    --飞流正版各个包需要迁移账号
    if G_curPlatName() == "58" or G_curPlatName() == "60" or G_curPlatName() == "5" or G_curPlatName() == "flandroid" or G_curPlatName() == "63" then
        if G_curPlatName() == "51" then --1 代表非强制下载新包方式的迁移（在本包迁移）
            return true, 1
        else --2 代表需要强制下载新包去迁移（在下载的新包迁移）
            return true, 2
        end
    end
    return false, 0
end

--是否显示接受游戏内pk玩法的功能
function G_isShowAcceptPk()
    local serverpid = G_getServerPlatId()
    if serverpid == "rayjoy_android" or serverpid == "fl_yueyu" or serverpid == "5" or G_isChina() == true then
        return true
    end
    return false
end

--获取大平台id
function G_getServerPlatId()
    if base.serverPlatID ~= 0 then
        do return base.serverPlatID end
    end
    if G_curPlatName() == "5" or G_curPlatName() == "51" or G_curPlatName() == "58" or G_curPlatName() == "64" or G_curPlatName() == "60" or G_curPlatName() == "61" or G_curPlatName() == "66" or G_curPlatName() == "androidappstore" or G_curPlatName() == "65" or G_curPlatName() == "45" or G_curPlatName() == "48" or G_curPlatName() == "androidtencentyxb" or G_curPlatName() == "androidfltencent" then
        return "5"
    end
    if G_curPlatName() == "androidflbaidu" or G_curPlatName() == "6" or G_curPlatName() == "7" or G_curPlatName() == "8" or G_curPlatName() == "9" or G_curPlatName() == "10" or G_curPlatName() == "16" or G_curPlatName() == "46" or G_curPlatName() == "50" or G_curPlatName() == "63" or G_curPlatName() == "69" or G_curPlatName() == "70" or G_curPlatName() == "flandroid" or G_curPlatName() == "flandroid_rgame" or G_curPlatName() == "androiddidi" or G_curPlatName() == "androidxyzs" then
        return "fl_yueyu"
    end
    return 0
end

--获取平台
function G_getPlatGmUrl()
    if(G_curPlatName() == "0")then
        return "http://192.168.8.213/test_gm_index/platformwar/"
        -- return "http://192.168.103.73:8888/tank/server/allgm/tank_gm/tankgm_213/platformwar/"
    else
        return "http://gm.rayjoy.com/tank_gm/gm_index/platformwar/"
    end
end

function G_getGmPlatName()
    if(G_curPlatName() == "0")then
        return "gm_207"
    elseif(G_curPlatName() == "androidzhongshouyouko" or G_curPlatName() == "13" or G_curPlatName() == "andgamesdealko" or G_curPlatName() == "androidzsykonaver") then
        return "gm_korea"
    elseif(G_curPlatName() == "androidkakaogoogle" or G_curPlatName() == "androidkakaonaver" or G_curPlatName() == "androidkakaotstore")then
        return "gm_korea_kk"
    elseif(G_curPlatName() == "42" or G_curPlatName() == "1" or G_curPlatName() == "flandroid" or G_curPlatName() == "63" or G_curPlatName() == "flandroid_rgame" or G_curPlatName() == "68")then
        return "gm_feiliuyueyu"
    elseif(G_curPlatName() == "51" or G_curPlatName() == "58" or G_curPlatName() == "60" or G_curPlatName() == "5" or G_curPlatName() == "66") then
        return "gm_feiliu"
    end
    return nil
end

function G_isRayjoyLoginType()
    if platCfg.platCfgLoginSceneBtnType[G_curPlatName()] == 8 or platCfg.platCfgLoginSceneBtnType[G_curPlatName()] == 9 or platCfg.platCfgLoginSceneBtnType[G_curPlatName()] == 10 then
        return true
    end
    return false
end

--登录页面是否显示绑定邮箱和重置密码的功能
function G_isBindMailAndResetPwd()
    if G_curPlatName() == "51" or G_curPlatName() == "66" then
        return true
    end
    return false
end

function G_getServerIp()
    local svrcfg = platCfg.platCfgServerIp[G_curPlatName()]
    if svrcfg then
        if G_isApplyVersion() == true then --审核时取审核的ip
            return svrcfg[1]
        else --否则取域名
            return svrcfg[2]
        end
    end
    return ""
end

function G_showTipsDialog(tipsString, tipsFontSize, newLayerNum)
    tipsFontSize = tipsFontSize or 30
    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tipsString, tipsFontSize, nil, nil, nil, nil, nil, newLayerNum)
end

--目前针对AI部队内的显示问题
function G_noVisibleInIcon(item, itemSp, tag)
    if item then
        if item.type == "at" then
            local eType = string.sub(item.key, 1, 1)
            if eType == "a" then
                local label = itemSp:getChildByTag(tag)
                if label then
                    label:setVisible(false)
                end
            end
        end
    end
end

--审核打点统计
function G_statisticsAuditRecord(rtype)
    if G_isApplyVersion() == false then
        do return end
    end
    local platname = G_getGmPlatName()
    if platname == nil or rtype == nil then
        do return end
    end
    local url = G_getPlatGmUrl()
    local recordURL = url.."audit"
    local uid = playerVoApi:getUid() or 0
    local parms = "plat="..platname.."&channel="..G_curPlatName() .. "&cver="..deviceHelper:getCVersion() .. "&type="..rtype
    if uid then
        parms = parms.."&uid="..uid
    end
    if base.curZoneID then
        parms = parms.."&zid="..base.curZoneID
    end
    print("审核打点", recordURL.."?"..parms)
    local function callback(data, result)
    end
    local result = G_sendHttpAsynRequest(recordURL, parms, callback, 2)
end

--每日二次确认
function G_dailyConfirm(funcKey, confirmStr, callback, layerNum, operateTime)
    local function confirm()
        if callback then
            callback()
        end
    end
    --更新二次确认弹板时间
    local function changeFlag(sbFlag)
        local serverTime = operateTime or base.serverTime
        local sValue = serverTime .. "_" .. sbFlag
        G_changePopFlag(funcKey, sValue)
    end
    if G_isPopBoard(funcKey) then
        G_showSecondConfirm(layerNum, true, true, getlocal("dialog_title_prompt"), confirmStr, true, confirm, changeFlag)
    else
        confirm()
    end
end

function G_createMultiTabbed(tabNameTb, tabPic, tabSelectPic, callbackTb, fontSize, lspace)
    require "luascript/script/componet/multiTabbed"
    local multiTab = multiTabbed:new()
    multiTab:createTabs(tabNameTb, tabPic, tabSelectPic, callbackTb, fontSize, lspace)
    return multiTab
end

--保留n位小数
function G_GetPreciseDecimal(nNum, n)
    if type(nNum) ~= "number" then
        return nNum
    end
    n = n or 0
    n = math.floor(n)
    if n < 0 then
        n = 0
    end
    local nDecimal = 1 / (10 ^ n)
    if nDecimal == 1 then
        nDecimal = nNum
    end
    local nLeft = nNum % nDecimal
    return nNum - nLeft
end

function G_createTableView(tvSize, cellNum, cellSize, cellCallFunc, isHorizontal)
    local cellCount = cellNum or 0
    if type(cellNum) == "function" then
        cellCount = cellNum()
    end
    local function tvCallBack(handler, fn, idx, cel)
        if fn == "numberOfCellsInTableView" then
            if type(cellNum) == "function" then
                cellCount = cellNum()
            end
            return cellCount
        elseif fn == "tableCellSizeForIndex" then
            return (type(cellSize) == "function") and cellSize(idx, cellCount) or cellSize
        elseif fn == "tableCellAtIndex" then
            local cell = CCTableViewCell:new()
            cell:autorelease()
            if type(cellCallFunc) == "function" then
                local cSize = (type(cellSize) == "function") and cellSize(idx, cellCount) or cellSize
                cellCallFunc(cell, cSize, idx, cellCount)
            end
            return cell
        elseif fn == "ccTouchBegan" then
            return true
        elseif fn == "ccTouchMoved" then
        elseif fn == "ccTouchEnded" then
        end
    end
    local hd = LuaEventHandler:createHandler(function(...) return tvCallBack(...) end)
    if isHorizontal == true then
        return LuaCCTableView:createHorizontalWithEventHandler(hd, tvSize, nil)
    else
        return LuaCCTableView:createWithEventHandler(hd, tvSize, nil)
    end
end

function G_playFrame(framePlayer, frameController)
    if framePlayer == nil or frameController == nil then
        do return end
    end
    local frmn = frameController.frmn --帧数
    local perdelay = frameController.perdelay or 0.01 --帧间隔时间
    local forever = frameController.forever or {-1, 0} --循环播放数据{循环次数，循环间隔时间}其中循环次数 -1：不循环 0：无限循环，>0: 循环多次
    local frname = frameController.frname --帧名称前缀
    local blendType = frameController.blendType --混合模式
    local callback = frameController.callback --播放结束回调
    local frnameFormat = frameController.frnameFormat
    
    local frameArr = CCArray:create()
    for k = 1, frmn do
        local nameStr = frname..k..".png"
        if frnameFormat then
            nameStr = frname..string.format(frnameFormat[1], frnameFormat[2] + k) .. ".png"
        end
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        frameArr:addObject(frame)
    end
    local animation = CCAnimation:createWithSpriteFrames(frameArr)
    animation:setDelayPerUnit(perdelay)
    local animate = CCAnimate:create(animation)
    
    local blendFunc
    if blendType == 1 then
        blendFunc = ccBlendFunc:new()
        blendFunc.src = GL_ONE
        blendFunc.dst = GL_ONE
    end
    if blendFunc then
        framePlayer:setBlendFunc(blendFunc)
    end
    if forever[1] == -1 then
        if callback then
            local acArr = CCArray:create()
            acArr:addObject(animate)
            acArr:addObject(CCCallFunc:create(callback))
            framePlayer:runAction(CCSequence:create(acArr))
        else
            framePlayer:runAction(animate)
        end
    elseif forever[1] == 0 then
        local acArr = CCArray:create()
        acArr:addObject(animate)
        acArr:addObject(CCDelayTime:create(forever[2] or 0))
        local repeatForever = CCRepeatForever:create(CCSequence:create(acArr))
        framePlayer:runAction(repeatForever)
    else
        local acArr = CCArray:create()
        acArr:addObject(animate)
        acArr:addObject(CCDelayTime:create(forever[2] or 0))
        local repeatAc = CCRepeat:create(CCSequence:create(acArr), forever[1])
        framePlayer:runAction(repeatAc)
    end
end
function G_showSureAndCancle(tipLb, sureCallBack, cancleCallBack)
    smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), sureCallBack, getlocal("dialog_title_prompt"), tipLb, nil, 80, nil, nil, cancleCallBack)
end

--创建复选框组件
--@defaultPic : 默认资源(未选中状态)
--@selectedPic : 已选中状态资源
--@callback : 点击事件的回调函数
function G_createCheckBox(defaultPic, selectedPic, callback)
    local switchSp1 = CCSprite:createWithSpriteFrameName(defaultPic)
    local switchSp2 = CCSprite:createWithSpriteFrameName(defaultPic)
    local menuItemSp1 = CCMenuItemSprite:create(switchSp1, switchSp2)
    local switchSp3 = CCSprite:createWithSpriteFrameName(selectedPic)
    local switchSp4 = CCSprite:createWithSpriteFrameName(selectedPic)
    local menuItemSp2 = CCMenuItemSprite:create(switchSp3, switchSp4)
    local checkBoxItem = CCMenuItemToggle:create(menuItemSp1)
    checkBoxItem:addSubItem(menuItemSp2)
    checkBoxItem:setAnchorPoint(ccp(0.5, 0.5))
    checkBoxItem:registerScriptTapHandler(function(...) 
        if type(callback) == "function" then 
            callback(...) 
        end 
    end)
    local checkBox = CCMenu:create()
    checkBox:addChild(checkBoxItem)
    return checkBox, checkBoxItem
end

--计算圆的轨迹路线上的点
--@bottomPos : 圆的最底部的一个坐标
--@radius : 圆的半径
--@radiusAngle : 半径的旋转度数(以数学坐标系为标准的角度值)
function G_getPointOfCircle(bottomPos, radius, radiusAngle)
    local angleValue = radiusAngle * math.pi / 180;
    local a = -1 / math.tan(angleValue)
    local tangentAngle = math.atan(a) * 180 / math.pi
    if radiusAngle > 0 and radiusAngle < 180 then
        tangentAngle = 180 + tangentAngle
    end
    local x = bottomPos.x + radius * math.cos(angleValue)
    local y = (bottomPos.y + radius) + radius * math.sin(angleValue)
    local c = tangentAngle * math.pi / 180 --该点在圆上的切线角度
    return ccp(x, y) --圆上的点坐标
end

function G_tableContains(tb, key)
    for _, v in pairs(tb) do
        if v == key then return true end
    end
    return false
end

----建筑1 （小人蓄势爆发）特效
function G_buildingAction1(buildingPic, parent, pos, aPos, scaleSize, isClickShow)
    local animateSpTb = {}
    local buildingSp = CCSprite:createWithSpriteFrameName(buildingPic)
    table.insert(animateSpTb, buildingSp)
    if aPos then
        buildingSp:setAnchorPoint(aPos)
    end
    if scaleSize then
        buildingSp:setScale(scaleSize)
    end
    if pos then
        buildingSp:setPosition(pos)
    else
        buildingSp:setPosition(getCenterPoint(parent))
    end
    parent:addChild(buildingSp)
    
    local buildingSpCenterPosx, buildingSpCenterPosy = buildingSp:getContentSize().width * 0.5, buildingSp:getContentSize().height * 0.5
    local buildingSpWidth, buildingSpHeight = buildingSp:getContentSize().width, buildingSp:getContentSize().height
    
    local buildingSp2
    if isClickShow then
        local function clickHandle()
            if buildingSp2 then
                local acArr = CCArray:create()
                local rgbv = 255
                local fadeOut = CCTintTo:create(0.2, 80, 80, 80)
                local fadeIn = CCTintTo:create(0.2, rgbv, rgbv, rgbv)
                
                acArr:addObject(fadeOut)
                acArr:addObject(fadeIn)
                local seq = CCSequence:create(acArr)
                buildingSp2:runAction(seq)
            end
        end
        
        buildingSp2 = LuaCCSprite:createWithSpriteFrameName("hryx_base_building2_1.png", clickHandle)
        --地图 默认layerNum 4
        buildingSp2:setTouchPriority(-(3) * 20 - 4)
        buildingSp2:setIsSallow(false)
    else
        buildingSp2 = CCSprite:createWithSpriteFrameName("hryx_base_building2_1.png")
    end
    
    table.insert(animateSpTb, buildingSp2)
    buildingSp2:setPosition(getCenterPoint(buildingSp))
    buildingSp:addChild(buildingSp2, 1)
    
    ---------------------- l e f t ----------------------
    local l_wingRoot = CCSprite:createWithSpriteFrameName("l_wingRoot.png")
    l_wingRoot:setPosition(buildingSpCenterPosx - 42, buildingSpCenterPosy + 69)
    buildingSp:addChild(l_wingRoot)
    local l_wingRoot2 = CCSprite:createWithSpriteFrameName("l_wingRoot.png")
    l_wingRoot2:setPosition(getCenterPoint(l_wingRoot))
    l_wingRoot:addChild(l_wingRoot2, 6)
    
    local l_rootCenterPosx, l_rootCenterPosy = l_wingRoot:getContentSize().width * 0.5, l_wingRoot:getContentSize().height * 0.5
    -- local anPosx,anPosy = 18,-15--锚点偏移坐标
    local l_wingMovPosTb = {
        ccp(-12, -35),
        ccp(-33, -35),
        ccp(-48, -43),
        ccp(-54, -52),
        ccp(-54, -52)
    }
    local l_wingScaleTb = {1, 0.755, 0.57, 0.48, 0.40}
    local l_wingRoTb = {54, 33, 15, 2, -16}
    local l_wingCdTb = {0.33, 0.66, 1, 1.33, 1.66}
    local l_wingrotateTb = {{48, 54}, {28, 33}, {7, 15}, {-8, 2}, {-30, -16}}
    
    for idx = 1, 5 do
        local l_wing = CCSprite:createWithSpriteFrameName("l_wing.png")
        local usePosx, usePosy = l_wing:getContentSize().width - 229, l_wing:getContentSize().height - 40
        l_wing:setPosition(l_wingMovPosTb[idx].x + usePosx + l_rootCenterPosx, l_wingMovPosTb[idx].y + usePosy + l_rootCenterPosy)
        l_wing:setAnchorPoint(ccp(1, 1))
        l_wing:setScale(l_wingScaleTb[idx])
        l_wing:setRotation(l_wingRoTb[idx])
        l_wingRoot:addChild(l_wing, 5 - idx)
        
        local l_wingDarkLightSp = CCSprite:createWithSpriteFrameName("l_flowingLight1.png")
        l_wingDarkLightSp:setPosition(getCenterPoint(l_wing))
        l_wing:addChild(l_wingDarkLightSp)
        local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
        blendFunc.src = GL_ONE
        blendFunc.dst = GL_ONE
        l_wingDarkLightSp:setBlendFunc(blendFunc)
        
        local l_wingRedLightSp = CCSprite:createWithSpriteFrameName("l_wingRedLight.png")
        l_wingRedLightSp:setPosition(getCenterPoint(l_wing))
        l_wing:addChild(l_wingRedLightSp)
        local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
        blendFunc.src = GL_ONE
        blendFunc.dst = GL_ONE
        l_wingRedLightSp:setBlendFunc(blendFunc)
        
        local l_fHightLightSp = CCSprite:createWithSpriteFrameName("l_fHightLight1.png")
        l_fHightLightSp:setPosition(getCenterPoint(l_wing))
        l_wing:addChild(l_fHightLightSp)
        local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
        blendFunc.src = GL_ONE
        blendFunc.dst = GL_ONE
        l_fHightLightSp:setBlendFunc(blendFunc)
        l_fHightLightSp:setVisible(false)
        
        --翅膀动态图
        local arr = CCArray:create()
        local deT = CCDelayTime:create(l_wingCdTb[idx])
        local RotateTo1 = CCRotateTo:create((4 - l_wingCdTb[idx]) * 0.5, l_wingrotateTb[idx][1])
        local RotateTo2 = CCRotateTo:create((4 - l_wingCdTb[idx]) * 0.5, l_wingrotateTb[idx][2])
        arr:addObject(deT)
        arr:addObject(RotateTo1)
        arr:addObject(RotateTo2)
        local seq = CCSequence:create(arr)
        local repeatEverAction = CCRepeatForever:create(seq)
        l_wing:runAction(repeatEverAction)
        
        --红灯待机 + 爆发
        local redArr = CCArray:create()
        for i = 1, 3 do
            local fadeIn = CCFadeIn:create(0.133)
            local RedDeT = CCDelayTime:create(0.066)
            local fadeOut = CCFadeOut:create(0.133)
            redArr:addObject(fadeIn)
            redArr:addObject(RedDeT)
            redArr:addObject(fadeOut)
        end
        local fadeIn = CCFadeIn:create(0.133)
        local RedDeT = CCDelayTime:create(0.066)
        local fadeOut = CCFadeOut:create(2)
        redArr:addObject(fadeIn)
        redArr:addObject(RedDeT)
        redArr:addObject(fadeOut)
        local readyEruptingCd = CCDelayTime:create(1.05)
        redArr:addObject(readyEruptingCd)
        local fadeIn = CCFadeIn:create(0)
        local RedDeT = CCDelayTime:create(0.133)
        local fadeOut = CCFadeOut:create(3)
        redArr:addObject(fadeIn)
        redArr:addObject(RedDeT)
        redArr:addObject(fadeOut)
        
        local overCd = CCDelayTime:create(8 - 6.328 - 1.05)
        redArr:addObject(overCd)
        local RedSeq = CCSequence:create(redArr)
        local redForever = CCRepeatForever:create(RedSeq)
        l_wingRedLightSp:runAction(redForever)
        
        ------ 翅膀 待机流光 --l_wingDarkLightSp ------
        local animArr1 = CCArray:create()
        for kk = 1, 17 do
            local nameStr = "l_flowingLight"..kk..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            animArr1:addObject(frame)
        end
        local animation1 = CCAnimation:createWithSpriteFrames(animArr1)
        animation1:setDelayPerUnit(0.12)
        local animate1 = CCAnimate:create(animation1)
        local deT_1 = CCDelayTime:create(8 - 17 * 0.12)
        local arr1 = CCArray:create()
        arr1:addObject(animate1)
        arr1:addObject(deT_1)
        local wingArr1 = CCSequence:create(arr1)
        
        local repeat1 = CCRepeatForever:create(wingArr1)
        l_wingDarkLightSp:runAction(repeat1)
        
        ------ 翅膀 爆发流光 --l_fHightLightSp ------
        local eDeT1 = CCDelayTime:create(3 + 1.05)
        local function showEruptingFunction()
            if l_fHightLightSp then
                l_fHightLightSp:setVisible(true)
            end
        end
        local showHandler = CCCallFunc:create(showEruptingFunction)
        local animArr2 = CCArray:create()
        for kk = 1, 10 do
            local nameStr = "l_fHightLight"..kk..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            animArr2:addObject(frame)
        end
        local animation2 = CCAnimation:createWithSpriteFrames(animArr2)
        animation2:setDelayPerUnit(0.066)
        local animate2 = CCAnimate:create(animation2)
        local function hiddenEruptingFunction()
            if l_fHightLightSp then
                l_fHightLightSp:setVisible(false)
            end
        end
        local hiddenHandler = CCCallFunc:create(hiddenEruptingFunction)
        local eDeT2 = CCDelayTime:create(8 - 3 - 1.05 - 0.66)
        local arr2 = CCArray:create()
        arr2:addObject(eDeT1)
        arr2:addObject(showHandler)
        arr2:addObject(animate2)
        arr2:addObject(hiddenHandler)
        arr2:addObject(eDeT2)
        local wingArr2 = CCSequence:create(arr2)
        local repeat2 = CCRepeatForever:create(wingArr2)
        l_fHightLightSp:runAction(repeat2)
    end

    ---------------------- r i g h t ----------------------
    local r_wingRoot = CCSprite:createWithSpriteFrameName("r_wingRoot.png")
    r_wingRoot:setPosition(buildingSpCenterPosx - 7, buildingSpCenterPosy + 91)
    buildingSp:addChild(r_wingRoot)
    local r_wingRoot2 = CCSprite:createWithSpriteFrameName("r_wingRoot.png")
    r_wingRoot2:setPosition(getCenterPoint(r_wingRoot))
    r_wingRoot:addChild(r_wingRoot2, 6)
    
    local r_rootCenterPosx, r_rootCenterPosy = r_wingRoot:getContentSize().width * 0.5, r_wingRoot:getContentSize().height * 0.5
    local r_wingMovPosTb = {
        ccp(-2, 38),
        ccp(4, 42),
        ccp(12, 48),
        ccp(8, 42),
        ccp(0, 32)
    }
    local r_wingScaleTb = {1, 0.7, 0.48, 0.38, 0.35}
    local r_wingRoTb = {16, 23, 30, 39, 46}
    local r_wingCdTb = {0.33, 0.66, 1, 1.33, 1.66}
    local r_wingrotateTb = {{19, 16}, {27, 23}, {35, 30}, {44, 39}, {52, 46}}
    
    for idx = 1, 5 do
        local r_wing = CCSprite:createWithSpriteFrameName("r_wing.png")
        local usePosx, usePosy = r_wing:getContentSize().width - 69, r_wing:getContentSize().height - 296
        r_wing:setPosition(r_wingMovPosTb[idx].x + r_rootCenterPosx, r_wingMovPosTb[idx].y - usePosy + r_rootCenterPosy)
        r_wing:setAnchorPoint(ccp(0.5, 0))
        r_wing:setScale(r_wingScaleTb[idx])
        r_wing:setRotation(r_wingRoTb[idx])
        r_wingRoot:addChild(r_wing, 5 - idx)
        
        local r_wingDarkLightSp = CCSprite:createWithSpriteFrameName("r_flowingLight1.png")
        r_wingDarkLightSp:setPosition(getCenterPoint(r_wing))
        r_wing:addChild(r_wingDarkLightSp)
        local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
        blendFunc.src = GL_ONE
        blendFunc.dst = GL_ONE
        r_wingDarkLightSp:setBlendFunc(blendFunc)
        
        local r_wingRedLightSp = CCSprite:createWithSpriteFrameName("r_wingRedLight.png")
        r_wingRedLightSp:setPosition(getCenterPoint(r_wing))
        r_wing:addChild(r_wingRedLightSp)
        local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
        blendFunc.src = GL_ONE
        blendFunc.dst = GL_ONE
        r_wingRedLightSp:setBlendFunc(blendFunc)
        
        local r_fHightLightSp = CCSprite:createWithSpriteFrameName("r_fHightLight1.png")
        r_fHightLightSp:setPosition(getCenterPoint(r_wing))
        r_wing:addChild(r_fHightLightSp)
        local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
        blendFunc.src = GL_ONE
        blendFunc.dst = GL_ONE
        r_fHightLightSp:setBlendFunc(blendFunc)
        r_fHightLightSp:setVisible(false)
        
        local arr = CCArray:create()
        local deT = CCDelayTime:create(r_wingCdTb[idx])
        local RotateTo1 = CCRotateTo:create((4 - r_wingCdTb[idx]) * 0.5, r_wingrotateTb[idx][1])
        local RotateTo2 = CCRotateTo:create((4 - r_wingCdTb[idx]) * 0.5, r_wingrotateTb[idx][2])
        arr:addObject(deT)
        arr:addObject(RotateTo1)
        arr:addObject(RotateTo2)
        local seq = CCSequence:create(arr)
        local repeatEverAction = CCRepeatForever:create(seq)
        r_wing:runAction(repeatEverAction)
        
        --红灯待机 + 爆发
        local redArr = CCArray:create()
        for i = 1, 3 do
            local fadeIn = CCFadeIn:create(0.133)
            local RedDeT = CCDelayTime:create(0.066)
            local fadeOut = CCFadeOut:create(0.133)
            redArr:addObject(fadeIn)
            redArr:addObject(RedDeT)
            redArr:addObject(fadeOut)
        end
        local fadeIn = CCFadeIn:create(0.133)
        local RedDeT = CCDelayTime:create(0.066)
        local fadeOut = CCFadeOut:create(2)
        redArr:addObject(fadeIn)
        redArr:addObject(RedDeT)
        redArr:addObject(fadeOut)
        local readyEruptingCd = CCDelayTime:create(1.05)
        redArr:addObject(readyEruptingCd)
        local fadeIn = CCFadeIn:create(0)
        local RedDeT = CCDelayTime:create(0.133)
        local fadeOut = CCFadeOut:create(3)
        redArr:addObject(fadeIn)
        redArr:addObject(RedDeT)
        redArr:addObject(fadeOut)
        
        local overCd = CCDelayTime:create(8 - 6.328 - 1.05)
        redArr:addObject(overCd)
        local RedSeq = CCSequence:create(redArr)
        local redForever = CCRepeatForever:create(RedSeq)
        r_wingRedLightSp:runAction(redForever)
        
        --翅膀 待机流光 --r_wingDarkLightSp
        local animArr1 = CCArray:create()
        for kk = 1, 20 do
            local nameStr = "r_flowingLight"..kk..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            animArr1:addObject(frame)
        end
        local animation1 = CCAnimation:createWithSpriteFrames(animArr1)
        animation1:setDelayPerUnit(0.12)
        local animate1 = CCAnimate:create(animation1)
        local deT_1 = CCDelayTime:create(8 - 20 * 0.12)
        local arr1 = CCArray:create()
        arr1:addObject(animate1)
        arr1:addObject(deT_1)
        local wingArr1 = CCSequence:create(arr1)
        
        local repeat1 = CCRepeatForever:create(wingArr1)
        r_wingDarkLightSp:runAction(repeat1)
        
        ------ 翅膀 爆发流光 --l_fHightLightSp ------
        local function showEruptingFunction()
            if r_fHightLightSp then
                r_fHightLightSp:setVisible(true)
            end
        end
        local showHandler = CCCallFunc:create(showEruptingFunction)
        local eDeT1 = CCDelayTime:create(3 + 1.05)
        local animArr2 = CCArray:create()
        for kk = 1, 20 do
            local nameStr = "r_fHightLight"..kk..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            animArr2:addObject(frame)
        end
        local animation2 = CCAnimation:createWithSpriteFrames(animArr2)
        animation2:setDelayPerUnit(0.066)
        local animate2 = CCAnimate:create(animation2)
        local function hiddenEruptingFunction()
            if r_fHightLightSp then
                r_fHightLightSp:setVisible(false)
            end
        end
        local hiddenHandler = CCCallFunc:create(hiddenEruptingFunction)
        local eDeT2 = CCDelayTime:create(8 - 3 - 1.05 - 1.32)
        local arr2 = CCArray:create()
        arr2:addObject(eDeT1)
        arr2:addObject(showHandler)
        arr2:addObject(animate2)
        arr2:addObject(hiddenHandler)
        arr2:addObject(eDeT2)
        local wingArr2 = CCSequence:create(arr2)
        local repeat2 = CCRepeatForever:create(wingArr2)
        r_fHightLightSp:runAction(repeat2)
    end
    
    ------------------------------------------ r u n ----- a c t i o n ------------------------------------------
    local l_wingRotateTo1 = CCRotateTo:create(2, -5)
    local l_wingRotateTo2 = CCRotateTo:create(2, 0)
    local l_wingSeq = CCSequence:createWithTwoActions(l_wingRotateTo1, l_wingRotateTo2)
    local l_wingRepeatEver = CCRepeatForever:create(l_wingSeq)
    l_wingRoot:runAction(l_wingRepeatEver)
    
    local r_wingRotateTo1 = CCRotateTo:create(2, 3)
    local r_wingRotateTo2 = CCRotateTo:create(2, 0)
    local r_wingSeq = CCSequence:createWithTwoActions(r_wingRotateTo1, r_wingRotateTo2)
    local r_wingRepeatEver = CCRepeatForever:create(r_wingSeq)
    r_wingRoot:runAction(r_wingRepeatEver)
    
    --------------------------------------------------------------------------------------------------------------
    
    local yellowRingSp = CCSprite:createWithSpriteFrameName("yellowRing.png")
    yellowRingSp:setPosition(buildingSpCenterPosx - 1, buildingSpCenterPosy + 87.5)
    yellowRingSp:setOpacity(0)
    yellowRingSp:setScaleY(0.5)
    buildingSp:addChild(yellowRingSp, 9)
    
    local yellowRingRealSp = CCSprite:createWithSpriteFrameName("yellowRing.png")
    yellowRingRealSp:setPosition(getCenterPoint(yellowRingSp))
    yellowRingSp:addChild(yellowRingRealSp)
    local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
    blendFunc.src = GL_ONE
    blendFunc.dst = GL_ONE
    yellowRingRealSp:setBlendFunc(blendFunc)

    local blueRingSp = CCSprite:createWithSpriteFrameName("blueRing.png")
    blueRingSp:setPosition(buildingSpCenterPosx - 1, buildingSpCenterPosy + 87.5)
    blueRingSp:setOpacity(0)
    blueRingSp:setScaleY(0.5)
    buildingSp:addChild(blueRingSp, 9)
    
    local blueRingRealSp = CCSprite:createWithSpriteFrameName("blueRing.png")
    blueRingRealSp:setPosition(getCenterPoint(blueRingSp))
    blueRingSp:addChild(blueRingRealSp)
    local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
    blendFunc.src = GL_ONE
    blendFunc.dst = GL_ONE
    blueRingRealSp:setBlendFunc(blendFunc)
    
    local playerHoldingSp = CCSprite:createWithSpriteFrameName("pHolding_1.png")
    playerHoldingSp:setPosition(buildingSpCenterPosx - 3, buildingSpCenterPosy + 142)
    buildingSp:addChild(playerHoldingSp, 9)
    -- local blendFunc=ccBlendFunc:new()--混合模式为 ONE ONE
    -- blendFunc.src=GL_ONE
    -- blendFunc.dst=GL_ONE
    -- playerHoldingSp:setBlendFunc(blendFunc)
    
    local playerEruptingSp = CCSprite:createWithSpriteFrameName("pErupting_1.png")
    playerEruptingSp:setPosition(buildingSpCenterPosx - 3, buildingSpCenterPosy + 142)
    playerEruptingSp:setVisible(false)
    buildingSp:addChild(playerEruptingSp, 9)
    local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
    blendFunc.src = GL_ONE
    blendFunc.dst = GL_ONE
    playerEruptingSp:setBlendFunc(blendFunc)
    
    local upingBeamSp = CCSprite:createWithSpriteFrameName("upingBeam_1.png")
    upingBeamSp:setPosition(buildingSpCenterPosx - 2, buildingSpCenterPosy + 159)
    buildingSp:addChild(upingBeamSp, 9)
    local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
    blendFunc.src = GL_ONE
    blendFunc.dst = GL_ONE
    upingBeamSp:setBlendFunc(blendFunc)
    
    --upLightColumn_1
    local columnPosTb = {ccp(buildingSpCenterPosx - 144.5, buildingSpCenterPosy - 5),
        ccp(buildingSpCenterPosx - 0.5, buildingSpCenterPosy - 77),
    ccp(buildingSpCenterPosx + 143.5, buildingSpCenterPosy - 5)}
    for i = 1, 3 do
        local columnSp = CCSprite:createWithSpriteFrameName("upLightColumn_1.png")
        columnSp:setPosition(columnPosTb[i])
        buildingSp:addChild(columnSp, 7)
        local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
        blendFunc.src = GL_ONE
        blendFunc.dst = GL_ONE
        columnSp:setBlendFunc(blendFunc)
        
        local animArr = CCArray:create()
        for kk = 1, 15 do
            local nameStr = "upLightColumn_"..kk..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            animArr:addObject(frame)
        end
        local animation = CCAnimation:createWithSpriteFrames(animArr)
        animation:setDelayPerUnit(0.066)
        local animate = CCAnimate:create(animation)
        local columnSpRepeat = CCRepeatForever:create(animate)
        columnSp:runAction(columnSpRepeat)
    end

    
    --光圈效果
    local yRotateTo = CCRotateTo:create(2.5, 180)
    local yRotateTo2 = CCRotateTo:create(2.5, 360)
    local yArr = CCArray:create()
    yArr:addObject(yRotateTo)
    yArr:addObject(yRotateTo2)
    local ySeq = CCSequence:create(yArr)
    local rototeRepeat1 = CCRepeatForever:create(ySeq)
    yellowRingRealSp:runAction(rototeRepeat1)
    
    local bRotateTo = CCRotateTo:create(2.5, -180)
    local bRotateTo2 = CCRotateTo:create(2.5, -360)
    local bArr = CCArray:create()
    bArr:addObject(bRotateTo)
    bArr:addObject(bRotateTo2)
    local bSeq = CCSequence:create(bArr)
    local rototeRepeat2 = CCRepeatForever:create(bSeq)
    blueRingRealSp:runAction(rototeRepeat2)
    
    -----建筑上面爆发效果图
    local eruptingSp = CCSprite:createWithSpriteFrameName("bBaseErupting_1.png")
    eruptingSp:setPosition(buildingSpCenterPosx - 3, buildingSpCenterPosy + 142)
    local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
    blendFunc.src = GL_ONE
    blendFunc.dst = GL_ONE
    eruptingSp:setBlendFunc(blendFunc)
    eruptingSp:setVisible(false)
    buildingSp:addChild(eruptingSp, 9)
    
    local animArr = CCArray:create()
    for kk = 1, 15 do
        local nameStr = "pHolding_"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        animArr:addObject(frame)
    end
    local animation = CCAnimation:createWithSpriteFrames(animArr)
    animation:setDelayPerUnit(0.2)
    local animate = CCAnimate:create(animation)
    local playerActionForever = CCRepeatForever:create(animate)
    playerHoldingSp:runAction(playerActionForever)
    
    local eruptingDeT = CCDelayTime:create(3)
    local function pHoldingCallback()
        if playerHoldingSp then
            playerHoldingSp:setVisible(false)
        end
        if playerEruptingSp then
            playerEruptingSp:setVisible(true)
        end
    end
    local funcHandler = CCCallFunc:create(pHoldingCallback)
    
    local eruptingAnimArr = CCArray:create()
    for kk = 1, 27 do
        local nameStr = "pErupting_"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        eruptingAnimArr:addObject(frame)
    end
    local eruptingAnimation = CCAnimation:createWithSpriteFrames(eruptingAnimArr)
    eruptingAnimation:setDelayPerUnit(0.066)
    local eruptingAnimate = CCAnimate:create(eruptingAnimation)
    
    local function eruptingCallback()
        if playerHoldingSp then
            playerHoldingSp:setVisible(true)
        end
        if playerEruptingSp then
            playerEruptingSp:setVisible(false)
        end
    end
    local funcHandler2 = CCCallFunc:create(eruptingCallback)
    
    local eruptingDeT2 = CCDelayTime:create(3.218)
    local eruptingArr = CCArray:create()
    eruptingArr:addObject(eruptingDeT)
    eruptingArr:addObject(funcHandler)
    eruptingArr:addObject(eruptingAnimate)
    eruptingArr:addObject(funcHandler2)
    eruptingArr:addObject(eruptingDeT2)
    
    local eruptingSeq = CCSequence:create(eruptingArr)
    local playerEruptingForever = CCRepeatForever:create(eruptingSeq)
    playerEruptingSp:runAction(playerEruptingForever)
    
    local eruptingSpDeT = CCDelayTime:create(3 + 1.05)
    local function eruptingShowCallback()
        if eruptingSp then
            eruptingSp:setVisible(true)
        end
    end
    local eruptingSpHandler = CCCallFunc:create(eruptingShowCallback)
    
    local eruptingAnimArr = CCArray:create()
    for kk = 1, 10 do
        local nameStr = "bBaseErupting_"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        eruptingAnimArr:addObject(frame)
    end
    local eruptingAnimation = CCAnimation:createWithSpriteFrames(eruptingAnimArr)
    eruptingAnimation:setDelayPerUnit(0.066)
    local eruptingAnimate = CCAnimate:create(eruptingAnimation)
    
    local function eruptingHiddenCallback()
        if eruptingSp then
            eruptingSp:setVisible(false)
        end
    end
    local eruptingSpHandler2 = CCCallFunc:create(eruptingHiddenCallback)
    
    local eruptingSpDeT2 = CCDelayTime:create(8 - 3 - 1.05 - 0.66)
    local eruptingSpArr = CCArray:create()
    eruptingSpArr:addObject(eruptingSpDeT)
    eruptingSpArr:addObject(eruptingSpHandler)
    eruptingSpArr:addObject(eruptingAnimate)
    eruptingSpArr:addObject(eruptingSpHandler2)
    eruptingSpArr:addObject(eruptingSpDeT2)
    
    local eruptingSpSeq = CCSequence:create(eruptingSpArr)
    local eruptingSpForever = CCRepeatForever:create(eruptingSpSeq)
    eruptingSp:runAction(eruptingSpForever)
    
    local upingBeamArr = CCArray:create()
    for kk = 1, 15 do
        local nameStr = "upingBeam_"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        upingBeamArr:addObject(frame)
    end
    local upingBeamAnimation = CCAnimation:createWithSpriteFrames(upingBeamArr)
    upingBeamAnimation:setDelayPerUnit(0.066)
    local upingBeamAnimate = CCAnimate:create(upingBeamAnimation)
    local upingBeamForever = CCRepeatForever:create(upingBeamAnimate)
    upingBeamSp:runAction(upingBeamForever)
    return buildingSp, animateSpTb
end
----建筑2 （普通版，五角星）特效
function G_buildingAction2(buildingPic, parent, pos, aPos, scaleSize, isClickShow)
    local animateSpTb = {}
    local buildingSp = CCSprite:createWithSpriteFrameName(buildingPic)
    table.insert(animateSpTb, buildingSp)
    if aPos then
        buildingSp:setAnchorPoint(aPos)
    end
    if scaleSize then
        buildingSp:setScale(scaleSize)
    end
    if pos then
        buildingSp:setPosition(pos)
    else
        buildingSp:setPosition(getCenterPoint(parent))
    end
    parent:addChild(buildingSp)
    
    local buildingSpCenterPosx, buildingSpCenterPosy = buildingSp:getContentSize().width * 0.5, buildingSp:getContentSize().height * 0.5
    local buildingSpWidth, buildingSpHeight = buildingSp:getContentSize().width, buildingSp:getContentSize().height
    
    local buildingSp2
    if isClickShow then
        local function clickHandle()
            if buildingSp2 then
                local acArr = CCArray:create()
                local rgbv = 255
                local fadeOut = CCTintTo:create(0.2, 80, 80, 80)
                local fadeIn = CCTintTo:create(0.2, rgbv, rgbv, rgbv)
                
                acArr:addObject(fadeOut)
                acArr:addObject(fadeIn)
                local seq = CCSequence:create(acArr)
                buildingSp2:runAction(seq)
            end
        end
        
        buildingSp2 = LuaCCSprite:createWithSpriteFrameName("hryx_base_building2_2.png", clickHandle)
        --地图 默认layerNum 4
        buildingSp2:setTouchPriority(-(3) * 20 - 4)
        buildingSp2:setIsSallow(false)
    else
        buildingSp2 = CCSprite:createWithSpriteFrameName("hryx_base_building2_2.png")
    end
    
    table.insert(animateSpTb, buildingSp2)
    buildingSp2:setPosition(getCenterPoint(buildingSp))
    buildingSp:addChild(buildingSp2, 1)
    
    ---------------------- l e f t ----------------------
    local l_wingRoot = CCSprite:createWithSpriteFrameName("l_wingRoot2.png")
    l_wingRoot:setPosition(buildingSpCenterPosx - 41, buildingSpCenterPosy + 69)
    buildingSp:addChild(l_wingRoot)
    local l_wingRoot2 = CCSprite:createWithSpriteFrameName("l_wingRoot2.png")
    l_wingRoot2:setPosition(getCenterPoint(l_wingRoot))
    l_wingRoot:addChild(l_wingRoot2, 6)
    
    local l_rootCenterPosx, l_rootCenterPosy = l_wingRoot:getContentSize().width * 0.5, l_wingRoot:getContentSize().height * 0.5
    
    local l_wingMovPosTb = {
        ccp(-33, -35),
        ccp(-48, -43),
        ccp(-54, -56)
    }
    local l_wingScaleTb = {0.755, 0.57, 0.48}
    local l_wingRoTb = {33, 15, 2}
    local l_wingCdTb = {0.66, 1, 1.33}
    local l_wingrotateTb = {{28, 33}, {7, 15}, {-8, 2}}
    
    for idx = 1, 3 do
        local l_wing = CCSprite:createWithSpriteFrameName("l_wing.png")
        local usePosx, usePosy = l_wing:getContentSize().width - 229, l_wing:getContentSize().height - 40
        l_wing:setPosition(l_wingMovPosTb[idx].x + usePosx + l_rootCenterPosx, l_wingMovPosTb[idx].y + usePosy + l_rootCenterPosy)
        l_wing:setAnchorPoint(ccp(1, 1))
        l_wing:setScale(l_wingScaleTb[idx])
        l_wing:setRotation(l_wingRoTb[idx])
        l_wingRoot:addChild(l_wing, 5 - idx)
        
        local l_wingDarkLightSp = CCSprite:createWithSpriteFrameName("l_flowingLight1.png")
        l_wingDarkLightSp:setPosition(getCenterPoint(l_wing))
        l_wing:addChild(l_wingDarkLightSp)
        local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
        blendFunc.src = GL_ONE
        blendFunc.dst = GL_ONE
        l_wingDarkLightSp:setBlendFunc(blendFunc)
        
        local l_wingRedLightSp = CCSprite:createWithSpriteFrameName("l_wingRedLight.png")
        l_wingRedLightSp:setPosition(getCenterPoint(l_wing))
        l_wing:addChild(l_wingRedLightSp)
        local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
        blendFunc.src = GL_ONE
        blendFunc.dst = GL_ONE
        l_wingRedLightSp:setBlendFunc(blendFunc)
        
        --翅膀动态图
        local arr = CCArray:create()
        local deT = CCDelayTime:create(l_wingCdTb[idx])
        local RotateTo1 = CCRotateTo:create((4 - l_wingCdTb[idx]) * 0.5, l_wingrotateTb[idx][1])
        local RotateTo2 = CCRotateTo:create((4 - l_wingCdTb[idx]) * 0.5, l_wingrotateTb[idx][2])
        arr:addObject(deT)
        arr:addObject(RotateTo1)
        arr:addObject(RotateTo2)
        local seq = CCSequence:create(arr)
        local repeatEverAction = CCRepeatForever:create(seq)
        l_wing:runAction(repeatEverAction)
        
        --红灯待机 + 爆发
        local redArr = CCArray:create()
        for i = 1, 3 do
            local fadeIn = CCFadeIn:create(0.133)
            local RedDeT = CCDelayTime:create(0.066)
            local fadeOut = CCFadeOut:create(0.133)
            redArr:addObject(fadeIn)
            redArr:addObject(RedDeT)
            redArr:addObject(fadeOut)
        end
        local fadeIn = CCFadeIn:create(0.133)
        local RedDeT = CCDelayTime:create(0.066)
        local fadeOut = CCFadeOut:create(2)
        redArr:addObject(fadeIn)
        redArr:addObject(RedDeT)
        redArr:addObject(fadeOut)
        
        local overCd = CCDelayTime:create(4 - 3.195)
        redArr:addObject(overCd)
        local RedSeq = CCSequence:create(redArr)
        local redForever = CCRepeatForever:create(RedSeq)
        l_wingRedLightSp:runAction(redForever)
        
        ------ 翅膀 待机流光 --l_wingDarkLightSp ------
        local animArr1 = CCArray:create()
        for kk = 1, 17 do
            local nameStr = "l_flowingLight"..kk..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            animArr1:addObject(frame)
        end
        local animation1 = CCAnimation:createWithSpriteFrames(animArr1)
        animation1:setDelayPerUnit(0.12)
        local animate1 = CCAnimate:create(animation1)
        local deT_1 = CCDelayTime:create(4 - 17 * 0.12)
        local arr1 = CCArray:create()
        arr1:addObject(animate1)
        arr1:addObject(deT_1)
        local wingArr1 = CCSequence:create(arr1)
        
        local repeat1 = CCRepeatForever:create(wingArr1)
        l_wingDarkLightSp:runAction(repeat1)
    end
    
    local l_wingRotateTo1 = CCRotateTo:create(2, -5)
    local l_wingRotateTo2 = CCRotateTo:create(2, 0)
    local l_wingSeq = CCSequence:createWithTwoActions(l_wingRotateTo1, l_wingRotateTo2)
    local l_wingRepeatEver = CCRepeatForever:create(l_wingSeq)
    l_wingRoot:runAction(l_wingRepeatEver)
    
    ---------------------- r i g h t ----------------------
    local r_wingRoot = CCSprite:createWithSpriteFrameName("r_wingRoot2.png")
    r_wingRoot:setPosition(buildingSpCenterPosx - 7, buildingSpCenterPosy + 91)
    buildingSp:addChild(r_wingRoot)
    local r_wingRoot2 = CCSprite:createWithSpriteFrameName("r_wingRoot2.png")
    r_wingRoot2:setPosition(getCenterPoint(r_wingRoot))
    r_wingRoot:addChild(r_wingRoot2, 6)
    
    local r_rootCenterPosx, r_rootCenterPosy = r_wingRoot:getContentSize().width * 0.5, r_wingRoot:getContentSize().height * 0.5
    local r_wingMovPosTb = {
        ccp(4, 42),
        ccp(12, 48),
        ccp(8, 42)
    }
    local r_wingScaleTb = {0.7, 0.48, 0.38}
    local r_wingRoTb = {23, 30, 39}
    local r_wingCdTb = {0.66, 1, 1.33}
    local r_wingrotateTb = {{27, 23}, {35, 30}, {44, 39}}
    
    for idx = 1, 3 do
        local r_wing = CCSprite:createWithSpriteFrameName("r_wing.png")
        local usePosx, usePosy = r_wing:getContentSize().width - 69, r_wing:getContentSize().height - 296
        r_wing:setPosition(r_wingMovPosTb[idx].x + r_rootCenterPosx, r_wingMovPosTb[idx].y - usePosy + r_rootCenterPosy)
        r_wing:setAnchorPoint(ccp(0.5, 0))
        r_wing:setScale(r_wingScaleTb[idx])
        r_wing:setRotation(r_wingRoTb[idx])
        r_wingRoot:addChild(r_wing, 5 - idx)
        
        local r_wingDarkLightSp = CCSprite:createWithSpriteFrameName("r_flowingLight1.png")
        r_wingDarkLightSp:setPosition(getCenterPoint(r_wing))
        r_wing:addChild(r_wingDarkLightSp)
        local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
        blendFunc.src = GL_ONE
        blendFunc.dst = GL_ONE
        r_wingDarkLightSp:setBlendFunc(blendFunc)
        
        local r_wingRedLightSp = CCSprite:createWithSpriteFrameName("r_wingRedLight.png")
        r_wingRedLightSp:setPosition(getCenterPoint(r_wing))
        r_wing:addChild(r_wingRedLightSp)
        local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
        blendFunc.src = GL_ONE
        blendFunc.dst = GL_ONE
        r_wingRedLightSp:setBlendFunc(blendFunc)
        
        local arr = CCArray:create()
        local deT = CCDelayTime:create(r_wingCdTb[idx])
        local RotateTo1 = CCRotateTo:create((4 - r_wingCdTb[idx]) * 0.5, r_wingrotateTb[idx][1])
        local RotateTo2 = CCRotateTo:create((4 - r_wingCdTb[idx]) * 0.5, r_wingrotateTb[idx][2])
        arr:addObject(deT)
        arr:addObject(RotateTo1)
        arr:addObject(RotateTo2)
        local seq = CCSequence:create(arr)
        local repeatEverAction = CCRepeatForever:create(seq)
        r_wing:runAction(repeatEverAction)
        
        --红灯待机 + 爆发
        local redArr = CCArray:create()
        for i = 1, 3 do
            local fadeIn = CCFadeIn:create(0.133)
            local RedDeT = CCDelayTime:create(0.066)
            local fadeOut = CCFadeOut:create(0.133)
            redArr:addObject(fadeIn)
            redArr:addObject(RedDeT)
            redArr:addObject(fadeOut)
        end
        local fadeIn = CCFadeIn:create(0.133)
        local RedDeT = CCDelayTime:create(0.066)
        local fadeOut = CCFadeOut:create(2)
        redArr:addObject(fadeIn)
        redArr:addObject(RedDeT)
        redArr:addObject(fadeOut)
        
        local overCd = CCDelayTime:create(4 - 3.195)
        redArr:addObject(overCd)
        local RedSeq = CCSequence:create(redArr)
        local redForever = CCRepeatForever:create(RedSeq)
        r_wingRedLightSp:runAction(redForever)
        
        --翅膀 待机流光 --r_wingDarkLightSp
        local animArr1 = CCArray:create()
        for kk = 1, 20 do
            local nameStr = "r_flowingLight"..kk..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            animArr1:addObject(frame)
        end
        local animation1 = CCAnimation:createWithSpriteFrames(animArr1)
        animation1:setDelayPerUnit(0.12)
        local animate1 = CCAnimate:create(animation1)
        local deT_1 = CCDelayTime:create(4 - 20 * 0.12)
        local arr1 = CCArray:create()
        arr1:addObject(animate1)
        arr1:addObject(deT_1)
        local wingArr1 = CCSequence:create(arr1)
        
        local repeat1 = CCRepeatForever:create(wingArr1)
        r_wingDarkLightSp:runAction(repeat1)
    end
    local r_wingRotateTo1 = CCRotateTo:create(2, 3)
    local r_wingRotateTo2 = CCRotateTo:create(2, 0)
    local r_wingSeq = CCSequence:createWithTwoActions(r_wingRotateTo1, r_wingRotateTo2)
    local r_wingRepeatEver = CCRepeatForever:create(r_wingSeq)
    r_wingRoot:runAction(r_wingRepeatEver)
    
    -------------------------------------------------------------------------------------------
    local outSideRingSp = CCSprite:createWithSpriteFrameName("blueRing2.png")
    outSideRingSp:setPosition(buildingSpCenterPosx - 1, buildingSpCenterPosy + 108)
    outSideRingSp:setOpacity(0)
    outSideRingSp:setScaleY(0.5)
    buildingSp:addChild(outSideRingSp, 9)
    
    local outSideRingRealSp = CCSprite:createWithSpriteFrameName("blueRing2.png")
    outSideRingRealSp:setPosition(getCenterPoint(outSideRingSp))
    outSideRingSp:addChild(outSideRingRealSp)
    local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
    blendFunc.src = GL_ONE
    blendFunc.dst = GL_ONE
    outSideRingRealSp:setBlendFunc(blendFunc)

    local blueRingSp = CCSprite:createWithSpriteFrameName("blueRing2.png")
    blueRingSp:setPosition(buildingSpCenterPosx - 1, buildingSpCenterPosy + 89)
    blueRingSp:setOpacity(0)
    blueRingSp:setScaleY(0.44)
    blueRingSp:setScaleX(0.88)
    buildingSp:addChild(blueRingSp, 9)
    
    local blueRingRealSp = CCSprite:createWithSpriteFrameName("blueRing2.png")
    blueRingRealSp:setPosition(getCenterPoint(blueRingSp))
    blueRingSp:addChild(blueRingRealSp)
    local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
    blendFunc.src = GL_ONE
    blendFunc.dst = GL_ONE
    
    local upingBeamSp = CCSprite:createWithSpriteFrameName("upingBeam2_1.png")
    upingBeamSp:setPosition(buildingSpCenterPosx + 3, buildingSpCenterPosy + 126)
    buildingSp:addChild(upingBeamSp, 9)
    local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
    blendFunc.src = GL_ONE
    blendFunc.dst = GL_ONE
    upingBeamSp:setBlendFunc(blendFunc)
    
    --Starlight.png
    local starLightSp = CCSprite:createWithSpriteFrameName("Starlight.png")
    starLightSp:setPosition(buildingSpCenterPosx, buildingSpCenterPosy + 136)
    buildingSp:addChild(starLightSp, 8)
    local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
    blendFunc.src = GL_ONE
    blendFunc.dst = GL_ONE
    starLightSp:setBlendFunc(blendFunc)
    
    local starSp = CCSprite:createWithSpriteFrameName("Pentagram_1.png")
    starSp:setPosition(buildingSpCenterPosx, buildingSpCenterPosy + 136)
    buildingSp:addChild(starSp, 9)
    -- local blendFunc=ccBlendFunc:new()--混合模式为 ONE ONE
    -- blendFunc.src=GL_ONE
    -- blendFunc.dst=GL_ONE
    -- starSp:setBlendFunc(blendFunc)
    
    --光圈效果
    local yRotateTo = CCRotateTo:create(6, 180)
    local yRotateTo2 = CCRotateTo:create(6, 360)
    local yArr = CCArray:create()
    yArr:addObject(yRotateTo)
    yArr:addObject(yRotateTo2)
    local ySeq = CCSequence:create(yArr)
    local rototeRepeat1 = CCRepeatForever:create(ySeq)
    outSideRingRealSp:runAction(rototeRepeat1)
    
    local bRotateTo = CCRotateTo:create(6, -180)
    local bRotateTo2 = CCRotateTo:create(6, -360)
    local bArr = CCArray:create()
    bArr:addObject(bRotateTo)
    bArr:addObject(bRotateTo2)
    local bSeq = CCSequence:create(bArr)
    local rototeRepeat2 = CCRepeatForever:create(bSeq)
    blueRingRealSp:runAction(rototeRepeat2)
    
    --向上光效
    local upingBeamArr = CCArray:create()
    for kk = 1, 15 do
        local nameStr = "upingBeam2_"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        upingBeamArr:addObject(frame)
    end
    local upingBeamAnimation = CCAnimation:createWithSpriteFrames(upingBeamArr)
    upingBeamAnimation:setDelayPerUnit(0.07)
    local upingBeamAnimate = CCAnimate:create(upingBeamAnimation)
    local upingBeamForever = CCRepeatForever:create(upingBeamAnimate)
    upingBeamSp:runAction(upingBeamForever)
    
    --五角星旋转
    local starAcArr = CCArray:create()
    for kk = 1, 8 do
        local nameStr = "Pentagram_"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        starAcArr:addObject(frame)
    end
    local starAnimation = CCAnimation:createWithSpriteFrames(starAcArr)
    starAnimation:setDelayPerUnit(0.1)
    local starAnimate = CCAnimate:create(starAnimation)
    local starForever = CCRepeatForever:create(starAnimate)
    starSp:runAction(starForever)
    
    --五星背面星光 缩放
    local lightScaleTo1 = CCScaleTo:create(1.33, 0.6)
    local lightScaleTo2 = CCScaleTo:create(1.33, 1)
    local lightScaleTo3 = CCScaleTo:create(1.33, 0.6)
    local lightArr = CCArray:create()
    lightArr:addObject(lightScaleTo1)
    lightArr:addObject(lightScaleTo2)
    lightArr:addObject(lightScaleTo3)
    local lightSeq = CCSequence:create(lightArr)
    local lightRepeat = CCRepeatForever:create(lightSeq)
    starLightSp:runAction(lightRepeat)
    
    --upLightColumn2_1
    local columnPosTb = {ccp(buildingSpCenterPosx - 142, buildingSpCenterPosy + 40),
        ccp(buildingSpCenterPosx, buildingSpCenterPosy - 32),
        ccp(buildingSpCenterPosx + 144, buildingSpCenterPosy + 40)
    }
    for i = 1, 3 do
        local columnSp = CCSprite:createWithSpriteFrameName("upLightColumn2_1.png")
        columnSp:setPosition(columnPosTb[i])
        buildingSp:addChild(columnSp, 7)
        local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
        blendFunc.src = GL_ONE
        blendFunc.dst = GL_ONE
        columnSp:setBlendFunc(blendFunc)
        
        local animArr = CCArray:create()
        for kk = 1, 10 do
            local nameStr = "upLightColumn2_"..kk..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            animArr:addObject(frame)
        end
        local animation = CCAnimation:createWithSpriteFrames(animArr)
        animation:setDelayPerUnit(0.066)
        local animate = CCAnimate:create(animation)
        local columnSpRepeat = CCRepeatForever:create(animate)
        columnSp:runAction(columnSpRepeat)
    end
    return buildingSp, animateSpTb
end

function G_buildingAction3(buildingPic, parent, pos, aPos, scaleSize, isClickShow)
    local animateSpTb = {}
    local buildingSp = CCSprite:createWithSpriteFrameName(buildingPic)
    table.insert(animateSpTb, buildingSp)
    if aPos then
        buildingSp:setAnchorPoint(aPos)
    end
    if scaleSize then
        buildingSp:setScale(scaleSize)
    else
        scaleSize = 1
    end
    if pos then
        buildingSp:setPosition(pos)
    else
        buildingSp:setPosition(getCenterPoint(parent))
    end
    parent:addChild(buildingSp)
    
    local cPosx, cPosy = buildingSp:getContentSize().width * 0.5, buildingSp:getContentSize().height * 0.5
    local SpWidth, SpHeight = buildingSp:getContentSize().width, buildingSp:getContentSize().height
    
    local buildingSp2
    if isClickShow then
        local function clickHandle()
            if buildingSp2 then
                local acArr = CCArray:create()
                local rgbv = 255
                local fadeOut = CCTintTo:create(0.2, 80, 80, 80)
                local fadeIn = CCTintTo:create(0.2, rgbv, rgbv, rgbv)
                
                acArr:addObject(fadeOut)
                acArr:addObject(fadeIn)
                local seq = CCSequence:create(acArr)
                buildingSp2:runAction(seq)
            end
        end
        
        buildingSp2 = LuaCCSprite:createWithSpriteFrameName("map_base_building_14.png", clickHandle)
        --地图 默认layerNum 4
        buildingSp2:setTouchPriority(-(3) * 20 - 4)
        buildingSp2:setIsSallow(false)
    else
        buildingSp2 = CCSprite:createWithSpriteFrameName("map_base_building_14.png")
    end
    
    table.insert(animateSpTb, buildingSp2)
    buildingSp2:setPosition(getCenterPoint(buildingSp))
    buildingSp:addChild(buildingSp2, 1)
    ----------------------------------------a n im a t e  b e g i n -----------------------------------------------
    ---------- 齿 轮 ----------
    local gearSp = CCSprite:createWithSpriteFrameName("gear_1.png")
    gearSp:setPosition(cPosx, cPosy)
    buildingSp2:addChild(gearSp)
    
    local gearAnimtArr = CCArray:create()
    for kk = 1, 8 do
        local nameStr = "gear_"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        gearAnimtArr:addObject(frame)
    end
    local gearAnimation = CCAnimation:createWithSpriteFrames(gearAnimtArr)
    gearAnimation:setDelayPerUnit(0.08)
    local gearAnimate = CCAnimate:create(gearAnimation)
    local gearForever = CCRepeatForever:create(gearAnimate)
    gearSp:runAction(gearForever)
    
    ------------------------------
    local delayTb = {0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 0.5, 2.84, 1.58, 1.92} -- 11 个
    local everyPosTb = {ccp(cPosx - 141, cPosy + 89),
        ccp(cPosx - 131, cPosy + 138),
        ccp(cPosx - 57, cPosy + 127),
        ccp(cPosx - 115, cPosy + 96),
        ccp(cPosx - 21, cPosy + 174),
        ccp(cPosx - 137, cPosy + 144),
        ccp(cPosx - 78, cPosy + 168),
        ccp(cPosx - 85.5, cPosy + 137.5),
        ccp(cPosx - 85.5, cPosy + 137.5),
        ccp(cPosx - 85.5, cPosy + 137.5),
        ccp(cPosx - 85.5, cPosy + 137.5)
    }
    local animateStrTb = {"fw_r_", "fw_y_", "fw_b_", "fw_b_", "fw_r_", "fw_y_", "fw_b_", "fw2020_", "fw2020_", "Streamer2020_", "Streamer2020_"}
    
    ------
    local useTimeTb1 = {1.58, 1.92, 2.17, 2.42, 2.75, 3.08, 3.42, 3.75} -- 8
    local fadeColorTb1 = {0, 1.0, 1.0, 0.4, 0.8, 0.3, 0.2, 0}
    local useTimeTb2 = {1.92, 2.25, 2.58, 2.92, 3.25} -- 5
    local fadeColorTb2 = {0, 0.5, 0, 0.15, 0}
    
    for idx = 1, 11 do
        local function newYearAnimateHandle()
            local pngIdx = "1.png"
            if idx == 9 then
                pngIdx = "19.png"
            elseif idx == 11 then
                pngIdx = "2.png"
            end
            local ny1Sp = CCSprite:createWithSpriteFrameName(animateStrTb[idx]..pngIdx)
            -- print("animateStrTb[idx]..pngIdx=====>>>",animateStrTb[idx]..pngIdx,ny1Sp)
            ny1Sp:setScale(idx < 8 and 1.08 or 1)
            ny1Sp:setPosition(everyPosTb[idx])
            buildingSp:addChild(ny1Sp)
            local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
            blendFunc.src = GL_ONE
            blendFunc.dst = GL_ONE
            ny1Sp:setBlendFunc(blendFunc)
            
            if idx < 10 then
                local spNum = idx < 8 and 20 or 19
                
                local ny1AnimtArr = CCArray:create()
                
                if idx < 9 then
                    for kk = 1, spNum do
                        local nameStr = animateStrTb[idx]..kk..".png"
                        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                        ny1AnimtArr:addObject(frame)
                    end
                else
                    for i = 19, 1, -1 do
                        local nameStr = animateStrTb[idx]..i..".png"
                        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                        ny1AnimtArr:addObject(frame)
                    end
                end
                local function spCallBack()
                    if ny1Sp then
                        ny1Sp:stopAllActions()
                        ny1Sp:removeFromParentAndCleanup(true)
                    end
                end
                local funcHandler = CCCallFunc:create(spCallBack)
                local ny1Animation = CCAnimation:createWithSpriteFrames(ny1AnimtArr)
                ny1Animation:setDelayPerUnit(idx == 8 and 0.13 or 0.08)
                local ny1Animate = CCAnimate:create(ny1Animation)
                local seq = CCSequence:createWithTwoActions(ny1Animate, funcHandler)
                ny1Sp:runAction(seq)
            else
                local forNum = 8
                local subT = useTimeTb1[1]
                local useTimeTb = useTimeTb1
                local fadeColorTb = fadeColorTb1
                if idx == 11 then
                    forNum = 5
                    subT = useTimeTb2[1]
                    useTimeTb = useTimeTb2
                    fadeColorTb = fadeColorTb2
                end
                
                local spArr = CCArray:create()
                for i = 1, forNum do
                    local useFadeT = useTimeTb[i] - subT
                    subT = useTimeTb[i]
                    local fadeAni = CCFadeTo:create(useFadeT, 255 * fadeColorTb[i])
                    spArr:addObject(fadeAni)
                end
                local function endFadeHandle()
                    if ny1Sp then
                        ny1Sp:stopAllActions()
                        ny1Sp:removeFromParentAndCleanup(true)
                    end
                end
                local funcHandler = CCCallFunc:create(endFadeHandle)
                local arrSeq = CCSequence:create(spArr)
                local seq = CCSequence:createWithTwoActions(arrSeq, funcHandler)
                ny1Sp:runAction(seq)
            end
        end
        local useDet = delayTb[idx]
        local deT = CCDelayTime:create(useDet)
        local newYearHandler = CCCallFunc:create(newYearAnimateHandle)
        local lastT = 5 - useDet
        local deT2 = CCDelayTime:create(lastT)
        local spArr = CCArray:create()
        spArr:addObject(deT)
        spArr:addObject(newYearHandler)
        spArr:addObject(deT2)
        local spSeq = CCSequence:create(spArr)
        local spRepeat = CCRepeatForever:create(spSeq)
        buildingSp:runAction(spRepeat)
    end
    
    ----------------------------------------a n i m a t e     e n d -----------------------------------------------
    return buildingSp, animateSpTb
end

--获取ui版本
--return 1：旧版本ui，2：新版本ui
function G_getGameUIVer()
    -- do return 2 end
    --审核版本开关默认为1
    if G_isApplyVersion() == true or G_checkUseAuditUI() == true then
        return 1
    end
    local ver = CCUserDefault:sharedUserDefault():getIntegerForKey("gameSetting_newMainUI")
    if ver == 0 then
        G_uiver = 2
        CCUserDefault:sharedUserDefault():setIntegerForKey("gameSetting_newMainUI", G_uiver)
    end
    if G_uiver == nil then
        G_uiver = ver
    end
    return G_uiver
    -- if base.newUIOff == 1 then --关闭新版ui
    -- return 1
    -- else
    -- return G_uiver
    -- end
end
--设置ui版本
function G_setGameUIVer(ver)
    CCUserDefault:sharedUserDefault():setIntegerForKey("gameSetting_newMainUI", ver)
end

--图片叠加模式
function G_playBlendGL(targetSp, src, dst)
    local blendFunc = ccBlendFunc:new()
    blendFunc.src = src
    blendFunc.dst = dst
    targetSp:setBlendFunc(blendFunc)
end

--重新加载lua模块
--@moduleName<string> : 要重新加载的模块名
--@tableName<string> :  要重新加载的表名
function G_reloadModule(moduleName, tableName)
    if type(tableName) == "string" then
        _G[tableName] = nil
    end
    if type(moduleName) == "string" then
        _G.package.loaded[moduleName] = nil
        require(moduleName)
    end
end

--格式化阿拉伯数字
--@digit : 0-10的数字
function G_formatArabicDigit(digit)
    local digitTb = {"Ⅰ", "Ⅱ", "Ⅲ", "Ⅳ", "Ⅴ", "Ⅵ", "Ⅶ", "Ⅷ", "Ⅸ", "Ⅹ"}
    return (digitTb[digit] or digit)
end

function G_showCustomizeSmallDialog(layerNum, needTb)--自定义弹板 、强制要求———— needtb[1] : 自定义弹板标识（必须有！）needtb[2] : 弹板标题（getlocal("fsjklfjsadlf")）
    require "luascript/script/game/scene/gamedialog/activityAndNote/acThrivingSmallDialog"
    local sd = acThrivingSmallDialog:new(layerNum, needTb)
    sd:init()
end

--判断是否是怀旧服(否则即为老服)
function G_isMemoryServer(serverData)
    if serverData then
        if serverData.MS == 1 then
            return true
        end
    else
        if base.memoryServerIp and base.memoryServerIp ~= "" then
            return true
        end
    end
    return false
end

--简易 数字文本输入框 -- useInVeri: 用于验证码使用
function G_editBoxWithNumberShow(parent, zorder, pos, boxSp, bosSize, min, max, newNum, numLb, inputCallBack, useInVeri)
    local function editHandle(fn, eB, str, type)
        if not tonumber(str) then
            numLb:setVisible(false)
            eB:setText("")
        end
        if type == 1 then--检测文本内容变化
            numLb:setVisible(false)
            if str == nil then
                eB:setText(tostring(min))
            else
                local num = tonumber(str)
                if num then
                    if num > max then
                        num = max
                        eB:setText(tostring(num))
                    elseif num < min then
                        num = min
                        eB:setText(tostring(num))
                    else
                        eB:setText(str)
                    end
                    if useInVeri then
                        if tonumber(str) > max or tonumber(str) < min then
                            newNum = num
                        else
                            newNum = str
                        end
                    else
                        newNum = num
                    end
                    numLb:setString(tostring(newNum))
                    if inputCallBack then
                        inputCallBack(newNum)
                    end
                end
            end
        elseif type == 2 then
            eB:setVisible(false)
            numLb:setVisible(true)
        end
    end
    local editXBox = CCEditBox:createForLua(bosSize, boxSp, nil, nil, editHandle)
    editXBox:setPosition(pos)
    if G_isIOS() == true then
        editXBox:setInputMode(CCEditBox.kEditBoxInputModePhoneNumber)
    else
        editXBox:setInputMode(CCEditBox.kEditBoxInputModeAny)
    end
    editXBox:setVisible(false)
    parent:addChild(editXBox, zorder or 5)
    
    return editXBox, newNum
end

function G_veriHttpRequest()--请求验证前的 拉取要验证的图
    require "luascript/script/global/luaBase64"
    local httpURL = "http://" .. base.serverIp .. "/tank-server/public/index.php/api/verifica/code"
    local requestParams = "uid="..playerVoApi:getUid() .. "&zoneid="..base.curZoneID --string.format("uid=%s&zoneid=%s",playerVoApi:getUid(), base.curZoneID)
    -- print("url======>",httpURL.."?"..requestParams)
    local function getNewImageHandle(responseStr)
        base:cancleNetWait()
        -- print("responseStr====>>>",responseStr)
        if responseStr and responseStr ~= "" then
            local sData = G_Json.decode(responseStr)
            if sData and sData.ret == 0 then
                if sData.data and sData.data.img then
                    local path = CCFileUtils:sharedFileUtils():getWritablePath() .. "webImg/"--veriFile
                    local imgData = string.gsub(sData.data.img, '\r\n', '')
                    local deCodeData = ZZBase64:decode(imgData)--deviceHelper:base64Decode(imgData)
                    local imgPath = path.."veriImg.png"
                    local file = io.open(imgPath, "w")
                    file:write(deCodeData)
                    file:close()
                    
                    local needTb = {"veri", getlocal("veriStr"), imgPath, true}
                    G_showCustomizeSmallDialog(1000, needTb) -- layNum : 1000 给个最大的层级，里面所有的层级都以1000 为基础
                end
            elseif sData and sData.ret == -201 then
                base.verifyCoolingEndTs = sData and sData.data and sData.data.forbidTs or base.serverTime + 3600
                G_showCoolingTimeTip(-201)
                do return end
            end
        end
    end
    G_sendHttpAsynRequest(httpURL, requestParams, getNewImageHandle, 2)
    base:setNetWait()
end

function G_showCoolingTimeTip(ctype, layNum)--冷却时间提示
    local tipStr = ""
    if ctype == -151 then
        if base.mapCoolingEndTs and base.serverTime < base.mapCoolingEndTs then
            tipStr = getlocal("mapget_frequently", {GetTimeStr(base.mapCoolingEndTs - base.serverTime)})
        end
    elseif ctype == -201 then
        if base.verifyCoolingEndTs and base.serverTime < base.verifyCoolingEndTs then
            tipStr = getlocal("vrify_frequently", {GetTimeStr(base.verifyCoolingEndTs - base.serverTime)})
        end
    end
    if tipStr ~= "" then
        G_showTipsDialog(tipStr, nil, layNum or 1111)
    end
end

--任务描述
function G_getTaskWithDescLb(key, curNum, limitNum, isFull)
    local taskLb = ""
    if key == "gb" then
        key = "gba"
    end
    if isFull then
        curNum = limitNum
    else
        curNum = curNum < limitNum and curNum or curNum % limitNum
    end
    if key == "hy" then
        taskTitleStr = getlocal("activity_smcz_"..key.."_title", {curNum, limitNum})
    else
        taskTitleStr = getlocal("activity_chunjiepansheng_"..key.."_title", {curNum, limitNum})
    end
    return taskTitleStr
end

--跳转到对应功能板子 二次判断
function G_goToDialog2NeedSecondTurn(taskKey)
    local typeName = taskKey
    if typeName == "gba" then
        typeName = "gb"
    elseif typeName == "bc" then
        typeName = "cn"
    elseif typeName == "jg" then
        typeName = "pp"
    elseif typeName == "jx" then
        typeName = "alliance_technology"
    elseif typeName == "ua" or typeName == "ta" then
        typeName = "armor"
    elseif typeName == "uh" or typeName == "th" then
        typeName = "heroM"
    elseif typeName == "pr" then
        typeName = "tp"
    elseif typeName == "ac" or typeName == "ai1" or typeName == "ai2" then
        typeName = "aiTroop"
    elseif typeName == "st" or typeName == "sj" then
        typeName = "emblemTroop"
    end
    -- print("G_goToDialog2NeedSecondTurn=====>>>>typeName=====>>>>>",typeName)
    local useIdx = nil
    if taskKey == "st" then
        useIdx = 2
    elseif taskKey == "sj" then
        useIdx = 1
    end
    G_goToDialog2(typeName, 4, true, useIdx)
end

--充值方法
--@itemIndex : 充值档位
--@rechargeMoney : 充值金额
--@itemName : 商品名称
function G_rechargeHandler(itemIndex, rechargeMoney, itemName, layerNum)
    deviceHelper:luaPrint(string.format("cjl --------->>>> 充值档位：%d，充值金额：%d", itemIndex, rechargeMoney))
    
    if base.isPayOpen == 0 then
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("betaNoRecharge"), 28)
        do return end
    end
    if itemIndex and rechargeMoney then
        local flag, status, rlimit = healthyApi:getHealthyRechargeStatus(rechargeMoney)
        if flag == false then
            local str = getlocal("healthy_recharge_tip"..status, {rlimit})
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("healthy_tip"), str, nil, 8)
            do return end
        end
        global.rechargeFailedNoticed = false --如果充值失败了是否要弹出失败面板 false:弹出  true:不弹
        
        local curPlatformName = G_curPlatName()
        local moneyName, tempMoneyName
        --德国movga支付分语言特殊处理，调用底层获取语言
        if (curPlatformName == "11" and G_Version >= 11) or (curPlatformName == "androidsevenga" and G_Version >= 16) then
            local tmpTb = {}
            tmpTb["action"] = "customAction"
            tmpTb["parms"] = {}
            tmpTb["parms"]["value"] = "getCurrency"
            local cjson = G_Json.encode(tmpTb)
            moneyName = G_accessCPlusFunction(cjson)
            if moneyName ~= "EUR" and self.moneyName ~= "CHF" then
                moneyName = "EUR"
            end
            tempMoneyName = moneyName
        else
            moneyName = GetMoneyName()
        end
        
        -- if G_judgeEncryption(itemIndex, rechargeMoney, tempMoneyName) == true then
        -- do return end
        -- end
        --统计充值
        statisticsHelper:recharge("orderId", tonumber(rechargeMoney), tonumber(itemIndex), "appStore")
        CCUserDefault:sharedUserDefault():setStringForKey("UserOrderInfo", rechargeMoney .. "," .. itemIndex)
        CCUserDefault:sharedUserDefault():flush()
        
        local productName = itemName or getlocal("tk_gold_"..itemIndex.."_desc")
        if PlatformManage ~= nil then --判断是否存在PlatformManage类
            if G_isIOS() then
                if base.webpageRecharge == 1 then
                    local platID = G_getUserPlatID()
                    if G_curPlatName() ~= "51" then --正版的平台id为玩家自定义账号名
                        local index = string.find(platID, "_")
                        if index then
                            platID = string.sub(platID, index + 1)
                        else
                            platID = nil
                        end
                    end
                    local url = "http://" .. base.serverUserIp
                    if G_curPlatName() == "androidsevenga" or G_curPlatName() == "11" then
                        local mPrice = tostring(rechargeMoney)
                        local goldNum = 0
                        local orderID = playerVoApi:getUid() .. "_" .. base.curZoneID .. "_ios_" .. playerVoApi:getPlayerLevel() .. "_" .. playerVoApi:getVipLevel() .. "_" .. base.serverTime .. "_" .. platID .. "_" .. itemIndex .. "_0_" .. mPrice
                        local productID = "tksvg_gold_" .. tostring(tonumber(itemIndex) + 10)
                        url = url .. "/tank_rayapi/index.php/tank_rayapi/iosmovga3thpayBegin?game_server_id=" .. base.curZoneID .. "&game_user_id=" .. playerVoApi:getUid() .. "&game_user_name=" .. playerVoApi:getPlayerName() .. "&mobile=1&country=" .. string.upper(G_country) .. "&currency=" .. moneyName .. "&amount=" .. mPrice .. "&game_coin_amout=" .. goldNum .. "&product_id=" .. productID .. "&platform_user_id=" .. platID .. "&game_orderid=" .. orderID
                    else
                        local zoneID
                        if base.curOldZoneID and base.curOldZoneID ~= 0 and base.curOldZoneID ~= "0" and base.curOldZoneID ~= "" then
                            zoneID = base.curOldZoneID
                        else
                            zoneID = base.curZoneID
                        end
                        -- url = url.."/tank_rayapi/index.php/iapppayweb?game_user_id="..playerVoApi:getUid() .. "&zoneid="..zoneID.."&itemid="..itemIndex .. "&channel="..G_curPlatName() .. "&os=ios"
                        -- if(platID)then
                        --     url = url.."&platform_user_id="..platID
                        -- end
                        --由于爱贝被查，该支付废弃，暂时接入雷神天津那边的微信支付宝网页支付
                        url = "http://gd-weiduan-sdk02.leishenhuyu.com/rsdk-base-server/pay/create_order/1010001000/h5rgame-1010001001/v1"
                        local productId = itemIndex
                        local productName = HttpRequestHelper:URLEncode(productName)
                        local mPrice = tostring(rechargeMoney)
                        local goldNum = 0
                        local channelId = G_curPlatName() .. "___" .. G_getServerPlatId() --渠道名和平台名，G_getServerPlatId是sdk那边区分域名用
                        -- if G_getServerPlatId()=="fl_yueyu" then --越狱平台老包因为“|”问题有些包打不开链接
                        --     -- productName = goldNum.."gold"
                        --     channelId = G_curPlatName().."___"..G_getServerPlatId()
                        -- end
                        local params = "product_id=" .. productId .. "&game_server_id=" .. zoneID .. "&product_count=1" .. "&product_name=" .. productName .. "&platform_user_id=" .. (platID or "") .. "&game_user_id=" .. playerVoApi:getUid() .. "&private_data=" .. channelId .. "&cost=" .. mPrice .. "&coin_num=" .. goldNum .. "&os=h5&product_type=gold" .. "&wares_id=1&nonce_str=" .. tostring(G_getCurDeviceMillTime())
                        url = url .. "?" .. params
                    end
                    local tmpTb = {}
                    tmpTb["action"] = "openUrl"
                    tmpTb["parms"] = {}
                    tmpTb["parms"]["url"] = url
                    local cjson = G_Json.encode(tmpTb)
                    G_accessCPlusFunction(cjson)
                elseif curPlatformName == "0" or curPlatformName == "2" or curPlatformName == "5" or curPlatformName == "45" or curPlatformName == "48" or curPlatformName == "58" or curPlatformName == "60" then --为0 是appstore平台支付 2:yeahmobi
                    if base.isPay1Open == 1 then
                        local tmpTb = {}
                        tmpTb["action"] = "3thpay"
                        tmpTb["parms"] = {}
                        tmpTb["parms"]["itemIndex"] = itemIndex
                        tmpTb["parms"]["itemid"] = "tk_gold_" .. itemIndex
                        tmpTb["parms"]["name"] = productName
                        tmpTb["parms"]["desc"] = ""
                        tmpTb["parms"]["price"] = tonumber(rechargeMoney)
                        tmpTb["parms"]["count"] = 1
                        tmpTb["parms"]["pic"] = ""
                        tmpTb["parms"]["zoneid"] = tostring(base.curZoneID)
                        tmpTb["parms"]["currency"] = moneyName
                        tmpTb["parms"]["ext1"] = ""
                        tmpTb["parms"]["ext2"] = ""
                        tmpTb["parms"]["ext3"] = ""
                        local cjson = G_Json.encode(tmpTb)
                        G_accessCPlusFunction(cjson)
                    else
                        AppStorePayment:shared():buyItemByType(tonumber(itemIndex))
                    end
                elseif base.isPay1Open == 1 and (curPlatformName == "41" or curPlatformName == "20" or curPlatformName == "50" or curPlatformName == "31" or curPlatformName == "62") then
                    local tmpTb = {}
                    tmpTb["action"] = "3thpay"
                    tmpTb["parms"] = {}
                    tmpTb["parms"]["itemIndex"] = itemIndex
                    tmpTb["parms"]["itemid"] = "tk_gold_" .. itemIndex
                    tmpTb["parms"]["name"] = productName
                    tmpTb["parms"]["desc"] = ""
                    tmpTb["parms"]["price"] = tonumber(rechargeMoney)
                    tmpTb["parms"]["count"] = 1
                    tmpTb["parms"]["pic"] = ""
                    tmpTb["parms"]["zoneid"] = tostring(base.curZoneID)
                    tmpTb["parms"]["currency"] = moneyName
                    tmpTb["parms"]["ext1"] = ""
                    tmpTb["parms"]["ext2"] = ""
                    tmpTb["parms"]["ext3"] = ""
                    local cjson = G_Json.encode(tmpTb)
                    G_accessCPlusFunction(cjson)
                elseif curPlatformName == "1" or curPlatformName == "42" then --为1 是快用平台支付
                    if base.platformUserId ~= nil then
                        local tmpTb = {}
                        tmpTb["action"] = "buyItemByNewKY"
                        tmpTb["parms"] = {}
                        tmpTb["parms"]["fee"] = tostring(rechargeMoney)
                        tmpTb["parms"]["subject"] = productName
                        tmpTb["parms"]["itemid"] = tostring(itemIndex)
                        local cjson = G_Json.encode(tmpTb)
                        G_accessCPlusFunction(cjson)
                    end
                elseif curPlatformName == "3" or curPlatformName == "4" then --3 是EFUNios平台支付
                    PlatformManage:shared():buyItemByType(tonumber(itemIndex))
                elseif curPlatformName == "6" then --91
                    local tmpTb = {}
                    tmpTb["action"] = "buyItemByProductId91"
                    tmpTb["parms"] = {}
                    tmpTb["parms"]["productId"] = "tk_gold_" .. itemIndex
                    tmpTb["parms"]["productName"] = productName
                    tmpTb["parms"]["price"] = tonumber(rechargeMoney)
                    local cjson = G_Json.encode(tmpTb)
                    G_accessCPlusFunction(cjson)
                elseif curPlatformName == "7" then --pp
                    local tmpTb = {}
                    tmpTb["action"] = "buyItemByPricePP"
                    tmpTb["parms"] = {}
                    tmpTb["parms"]["price"] = tonumber(rechargeMoney)
                    tmpTb["parms"]["billTitle"] = productName
                    tmpTb["parms"]["itemId"] = tostring(itemIndex)
                    tmpTb["parms"]["zoneid"] = base.curOldZoneID
                    local cjson = G_Json.encode(tmpTb)
                    G_accessCPlusFunction(cjson)
                elseif curPlatformName == "8" or curPlatformName == "70" then --TBT
                    local tmpTb = {}
                    tmpTb["action"] = "buyItemByPriceTBT"
                    tmpTb["parms"] = {}
                    tmpTb["parms"]["price"] = tonumber(rechargeMoney)
                    tmpTb["parms"]["desc"] = productName
                    tmpTb["parms"]["itemId"] = tostring(itemIndex)
                    local cjson = G_Json.encode(tmpTb)
                    G_accessCPlusFunction(cjson)
                elseif curPlatformName == "9" or curPlatformName == "10" then --飞流越狱
                    local tmpTb = {}
                    tmpTb["action"] = "buyItemByPriceFeiliu"
                    tmpTb["parms"] = {}
                    tmpTb["parms"]["price"] = tonumber(rechargeMoney) * 100 --飞流是以分为单位 所以*100
                    tmpTb["parms"]["desc"] = productName
                    tmpTb["parms"]["itemId"] = tostring(itemIndex)
                    local cjson = G_Json.encode(tmpTb)
                    G_accessCPlusFunction(cjson)
                elseif curPlatformName == "66" then --fl-app新渠道包提审用appstore支付，之后会切换为网页支付
                    AppStorePayment:shared():buyItemByType(tonumber(itemIndex))
                else
                    if platCfg.platSureBuy[G_curPlatName()] ~= nil then
                        local function callBack()
                            local tmpTb = {}
                            tmpTb["action"] = "buyItemByTypeForIOS"
                            tmpTb["parms"] = {}
                            tmpTb["parms"]["itemIndex"] = itemIndex
                            tmpTb["parms"]["itemid"] = "tk_gold_" .. itemIndex
                            tmpTb["parms"]["name"] = productName
                            tmpTb["parms"]["desc"] = ""
                            tmpTb["parms"]["price"] = tonumber(rechargeMoney)
                            tmpTb["parms"]["count"] = 1
                            tmpTb["parms"]["pic"] = ""
                            if(base.serverPlatID == "fl_yueyu")then
                                tmpTb["parms"]["zoneid"] = tostring(base.curOldZoneID)
                            else
                                tmpTb["parms"]["zoneid"] = tostring(base.curZoneID)
                            end
                            tmpTb["parms"]["currency"] = moneyName
                            tmpTb["parms"]["ext1"] = ""
                            tmpTb["parms"]["ext2"] = ""
                            tmpTb["parms"]["ext3"] = ""
                            local cjson = G_Json.encode(tmpTb)
                            G_accessCPlusFunction(cjson)
                        end
                        local moneyStr = G_getPlatStoreCfg()["moneyType"][moneyName] .. rechargeMoney
                        if G_curPlatName() == "13" or G_curPlatName() == "androidzsykonaver" or G_curPlatName() == "androidzsykoolleh" or G_curPlatName() == "androidzsykotstore" or G_curPlatName() == "androidzhongshouyouko" or G_isKakao() or G_curPlatName() == "59" or G_curPlatName() == "androidcmge" then
                            moneyStr = rechargeMoney .. G_getPlatStoreCfg()["moneyType"][moneyName]
                        end
                        local tipsStr = getlocal("sureBuy_newText", {moneyStr, itemName})
                        smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), callBack, getlocal("dialog_title_prompt"), tipsStr, nil, layerNum + 1)
                    else
                        local itemId
                        if G_curPlatName() == "66" then
                            itemId = "hj_gold_" .. itemIndex
                        else
                            itemId = "tk_gold_" .. itemIndex
                        end
                        local tmpTb = {}
                        tmpTb["action"] = "buyItemByTypeForIOS"
                        tmpTb["parms"] = {}
                        tmpTb["parms"]["itemIndex"] = itemIndex
                        tmpTb["parms"]["itemid"] = itemId
                        tmpTb["parms"]["name"] = productName
                        tmpTb["parms"]["desc"] = ""
                        tmpTb["parms"]["price"] = tonumber(rechargeMoney)
                        tmpTb["parms"]["count"] = 1
                        tmpTb["parms"]["pic"] = ""
                        if base.serverPlatID == "fl_yueyu" then
                            tmpTb["parms"]["zoneid"] = tostring(base.curOldZoneID)
                        else
                            tmpTb["parms"]["zoneid"] = tostring(base.curZoneID)
                        end
                        tmpTb["parms"]["currency"] = moneyName
                        tmpTb["parms"]["ext1"] = ""
                        tmpTb["parms"]["ext2"] = ""
                        tmpTb["parms"]["ext3"] = ""
                        local cjson = G_Json.encode(tmpTb)
                        G_accessCPlusFunction(cjson)
                    end
                end
            else
                if base.webpageRecharge == 1 then
                    local platID = G_getUserPlatID()
                    local index = string.find(platID, "_")
                    if index then
                        platID = string.sub(platID, index + 1)
                    else
                        platID = nil
                    end
                    local url = "http://"..base.serverUserIp
                    if G_curPlatName() == "androidsevenga" or G_curPlatName() == "11" then
                        local mPrice = tostring(rechargeMoney)
                        local goldNum = 0
                        local orderID = playerVoApi:getUid() .. "_" .. base.curZoneID .. "_ios_" .. playerVoApi:getPlayerLevel() .. "_" .. playerVoApi:getVipLevel() .. "_" .. base.serverTime .. "_" .. platID .. "_" .. itemIndex .. "_0_" .. mPrice
                        local productID = "tk_gold_" .. tostring(tonumber(itemIndex) + 10)
                        url = url .. "/tank_rayapi/index.php/tank_rayapi/androidmovga3thpayBegin?game_server_id=" .. base.curZoneID .. "&game_user_id=" .. playerVoApi:getUid() .. "&game_user_name=" .. playerVoApi:getPlayerName() .. "&mobile=1&country=" .. string.upper(G_country) .. "&currency=" .. self.moneyName .. "&amount=" .. mPrice .. "&game_coin_amout=" .. goldNum .. "&product_id=" .. productID .. "&platform_user_id=" .. platID .. "&game_orderid=" .. orderID
                    else
                        local zoneID
                        if base.curOldZoneID and base.curOldZoneID ~= 0 and base.curOldZoneID ~= "0" and base.curOldZoneID ~= "" then
                            zoneID = base.curOldZoneID
                        else
                            zoneID = base.curZoneID
                        end
                        -- url = url.."/tank_rayapi/index.php/iapppayweb?game_user_id="..playerVoApi:getUid() .. "&zoneid="..zoneID.."&itemid="..sortCfg[selectIndex] .. "&channel="..G_curPlatName() .. "&os=ios"
                        -- if(platID)then
                        --     url = url.."&platform_user_id="..platID
                        -- end
                        --由于爱贝被查，该支付废弃，暂时接入雷神天津那边的微信支付宝网页支付
                        url = "http://gd-weiduan-sdk02.leishenhuyu.com/rsdk-base-server/pay/create_order/1010001000/h5rgame-1010001001/v1"
                        local productId = itemIndex
                        local productName = HttpRequestHelper:URLEncode(productName)
                        local mPrice = tostring(rechargeMoney)
                        local goldNum = 0
                        local channelId = G_curPlatName() .. "___" .. G_getServerPlatId() --渠道名和平台名，G_getServerPlatId是sdk那边区分域名用
                        local params = "product_id=" .. productId .. "&game_server_id=" .. zoneID .. "&product_count=1" .. "&product_name=" .. productName .. "&platform_user_id=" .. (platID or "") .. "&game_user_id=" .. playerVoApi:getUid() .. "&private_data=" .. channelId .. "&cost=" .. mPrice .. "&coin_num=" .. goldNum .. "&os=h5&product_type=gold" .. "&wares_id=1&nonce_str=" .. tostring(G_getCurDeviceMillTime())
                        url = url .. "?" .. params
                    end
                    local tmpTb = {}
                    tmpTb["action"] = "openUrl"
                    tmpTb["parms"] = {}
                    tmpTb["parms"]["url"] = url
                    local cjson = G_Json.encode(tmpTb)
                    G_accessCPlusFunction(cjson)
                elseif platCfg.platSureBuy[G_curPlatName()] ~= nil then
                    local function callBack()
                        local ext1 = ""
                        if curPlatformName == "efunandroidtw" or curPlatformName == "efunandroiddny" then
                            local shopItemArr = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"}
                            ext1 = "pay" .. (shopItemArr[tonumber(itemIndex)] or itemIndex)
                        end
                        local itemId = "tk_gold_" .. itemIndex
                        AppStorePayment:shared():buyItemByTypeForAndroid(itemId, productName, "", rechargeMoney, 1, "", base.curZoneID, ext1, "0")
                    end
                    local moneyStr = G_getPlatStoreCfg()["moneyType"][moneyName] .. rechargeMoney
                    if G_curPlatName() == "13" or G_curPlatName() == "androidzsykonaver" or G_curPlatName() == "androidzsykoolleh" or G_curPlatName() == "androidzsykotstore" or G_curPlatName() == "androidzhongshouyouko" or G_isKakao() or G_curPlatName() == "59" or G_curPlatName() == "androidcmge" then
                        moneyStr = rechargeMoney .. G_getPlatStoreCfg()["moneyType"][moneyName]
                    end
                    local tipsStr = getlocal("sureBuy_newText", {moneyStr, itemName})
                    smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), callBack, getlocal("dialog_title_prompt"), tipsStr, nil, layerNum + 1)
                else
                    local ext1 = ""
                    if curPlatformName == "efunandroidtw" or curPlatformName == "efunandroiddny" then
                        local shopItemArr = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"}
                        ext1 = "pay" .. (shopItemArr[tonumber(itemIndex)] or itemIndex)
                    end
                    local itemId = "tk_gold_" .. itemIndex
                    local curZid = G_mappingZoneid()
                    if base.curOldZoneID ~= nil and base.curOldZoneID ~= 0 and base.curOldZoneID ~= "0" then
                        curZid = base.curOldZoneID
                        if G_curPlatName() == "qihoo" or G_curPlatName() == "androidqihoohjdg" then
                            if tonumber(base.curZoneID) >= 220 and tonumber(base.curZoneID) < 1000 then
                                do
                                    curZid = tostring(tonumber(base.curOldZoneID) - 94)
                                end
                            end
                            if tonumber(base.curZoneID) == 1000 or tonumber(base.curZoneID) == 997 or tonumber(base.curZoneID) == 998 then
                                curZid = base.curOldZoneID
                            end
                        end
                    end
                    AppStorePayment:shared():buyItemByTypeForAndroid(itemId, productName, "", rechargeMoney, 1, "", curZid, ext1, "0")
                end
            end
        else
            AppStorePayment:shared():buyItemByType(tonumber(itemIndex))
        end
    end
end

--获取战报飞机信息的高度
function G_getReportAirShipLayoutHeight()
    return 32 + 220
end

function G_getReportAirShipLayout(cell, cellWidth, cellHeight, report, isAttacker)
    local titleBg = G_createReportTitle(cellWidth - 20, getlocal("airShip_text"))
    titleBg:setAnchorPoint(ccp(0.5, 1))
    titleBg:setPosition(cellWidth / 2, cellHeight)
    cell:addChild(titleBg, 2)
    local fontSize = 20
    if report.airship then
        if isAttacker == true or isAttacker == nil then
            myAirShip, enemyAirShip = report.airship[1], report.airship[2]
        else
            myAirShip, enemyAirShip = report.airship[2], report.airship[1]
        end
        local iconWidth, spaceX, spaceY = 100, 40, 40
        for i = 1, 2 do
            local itemBgPic = (i == 1) and "reportBlueBg.png" or "reportRedBg.png"
            local itemBg = LuaCCScale9Sprite:createWithSpriteFrameName(itemBgPic, CCRect(4, 4, 1, 1), function ()end)
            itemBg:setContentSize(CCSizeMake(cellWidth / 2, cellHeight))
            itemBg:setPosition(cellWidth * (2 * i - 1) / 4, cellHeight / 2)
            cell:addChild(itemBg)
            
            local airShipData
            if i == 1 then
                if myAirShip then
                    airShipData = {
                        id = myAirShip[1],
                        name = myAirShip[2],
                        equip = myAirShip[3],
                        strength = myAirShip[4],
                    }
                end
            else
                if enemyAirShip then
                    airShipData = {
                        id = enemyAirShip[1],
                        name = enemyAirShip[2],
                        equip = enemyAirShip[3],
                        strength = enemyAirShip[4],
                    }
                end
            end
            if airShipData then
                local nameStr = airShipData.name or getlocal("skill_equip_empty2")
                if nameStr == "" and airShipData.id then
                    nameStr = airShipVoApi:getAirshipDefaultName(tonumber(RemoveFirstChar(airShipData.id)))
                end
                local nameLb = GetTTFLabelWrap(nameStr, fontSize, CCSizeMake(cellWidth / 2 - 30, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
                nameLb:setAnchorPoint(ccp(0.5, 1))
                nameLb:setPosition(itemBg:getContentSize().width / 2, cellHeight - 32 - 10)
                itemBg:addChild(nameLb)
                if airShipData.id then
                    local airShipIcon = G_showAirShip(tonumber(RemoveFirstChar(airShipData.id)), nil, true)
                    airShipIcon:setPosition(itemBg:getContentSize().width / 2, cellHeight - 32 - 60 - iconWidth / 2)
                    airShipIcon:setScale(iconWidth / airShipIcon:getContentSize().width)
                    itemBg:addChild(airShipIcon)
                    if airShipData.equip then
                        local qualityIconSize = 20
                        for k, v in pairs(airShipData.equip) do
                            if v > 0 then
                                local equipQuality = CCSprite:createWithSpriteFrameName("airship_quality"..v..".png")
                                equipQuality:setScale(qualityIconSize / equipQuality:getContentSize().width)
                                if k <= 3 then
                                    equipQuality:setAnchorPoint(ccp(1, 0.5))
                                    equipQuality:setPositionX(itemBg:getContentSize().width / 2 - iconWidth / 2 - 10)
                                    equipQuality:setPositionY((airShipIcon:getPositionY() + qualityIconSize + 5) - (k - 1) * (qualityIconSize + 5))
                                else
                                    equipQuality:setAnchorPoint(ccp(0, 0.5))
                                    equipQuality:setPositionX(itemBg:getContentSize().width / 2 + iconWidth / 2 + 10)
                                    equipQuality:setPositionY((airShipIcon:getPositionY() + qualityIconSize + 5) - (k - 4) * (qualityIconSize + 5))
                                end
                                itemBg:addChild(equipQuality)
                            end
                        end
                    end
                else
                    local nullAirshipSp = CCSprite:createWithSpriteFrameName("report_airshipnull.png")
                    nullAirshipSp:setPosition(itemBg:getContentSize().width / 2, cellHeight - 32 - 60 - iconWidth / 2)
                    nullAirshipSp:setScale(iconWidth / nullAirshipSp:getContentSize().width)
                    itemBg:addChild(nullAirshipSp)
                end
                local alignment, anchor, posX = kCCTextAlignmentLeft, ccp(0, 1), 20
                if i == 2 then
                    alignment, anchor, posX = kCCTextAlignmentRight, ccp(1, 1), cellWidth / 2 - 20
                end
                local strengthStr = getlocal("plane_power") .. "：<rayimg>"..FormatNumber(airShipData.strength or 0) .. "<rayimg>"
                local strengthLb, lbheight = G_getRichTextLabel(strengthStr, {nil, G_ColorYellowPro, nil}, fontSize - 2, 280, alignment, kCCVerticalTextAlignmentTop)
                strengthLb:setAnchorPoint(anchor)
                strengthLb:setPosition(posX, cellHeight - 32 - 60 - iconWidth / 2 - iconWidth / 2 - 20)
                itemBg:addChild(strengthLb)
            end
        end
    end
end

---飞艇的相关图 （非UI） 目前只针对 朝向上面的飞艇plist（无运输艇！）
function G_addingOrRemovingAirShipImage(isAdd, shipIdx, isAll)--isAdd : 如果为 false 或 nil  表示 remove
    if isAdd then
        if shipIdx then
            spriteController:addPlist("public/arpl_ship"..shipIdx.."_2.plist")
            spriteController:addTexture("public/arpl_ship"..shipIdx.."_2.png")
            if shipIdx == 6 or shipIdx == 7 then
                spriteController:addPlist("public/arpl_shipPropellerImage"..shipIdx.."_2.plist")
                spriteController:addTexture("public/arpl_shipPropellerImage"..shipIdx.."_2.png")
            end
        elseif isAll then
            for idx = 1, 7 do
                spriteController:addPlist("public/arpl_ship"..idx.."_2.plist")
                spriteController:addTexture("public/arpl_ship"..idx.."_2.png")
                if idx == 6 or idx == 7 then
                    spriteController:addPlist("public/arpl_shipPropellerImage"..idx.."_2.plist")
                    spriteController:addTexture("public/arpl_shipPropellerImage"..idx.."_2.png")
                end
            end
        end
        spriteController:addPlist("public/arpl_shipUniversalImage2.plist")
        spriteController:addTexture("public/arpl_shipUniversalImage2.png")
    else--remove
        if shipIdx then
            spriteController:removePlist("public/arpl_ship"..shipIdx.."_2.plist")
            spriteController:removeTexture("public/arpl_ship"..shipIdx.."_2.png")
            if shipIdx == 6 or shipIdx == 7 then
                spriteController:removePlist("public/arpl_shipPropellerImage"..shipIdx.."_2.plist")
                spriteController:removeTexture("public/arpl_shipPropellerImage"..shipIdx.."_2.png")
            end
        elseif isAll then
            for idx = 1, 7 do
                spriteController:removePlist("public/arpl_ship"..idx.."_2.plist")
                spriteController:removeTexture("public/arpl_ship"..idx.."_2.png")
                if idx == 6 or idx == 7 then
                    spriteController:removePlist("public/arpl_shipPropellerImage"..idx.."_2.plist")
                    spriteController:removeTexture("public/arpl_shipPropellerImage"..idx.."_2.png")
                end
            end
        end
        spriteController:removePlist("public/arpl_shipUniversalImage2.plist")
        spriteController:removeTexture("public/arpl_shipUniversalImage2.png")
    end
end

--播放精灵透明度动作序列
function G_playFade(fadeSp, fadeController)
    if fadeSp == nil then
        do return end
    end
    local startOpacity = fadeController.startOpacity or 255
    local fv = fadeController.fv or {} --透明度值序列
    local ft = fadeController.ft or {} --透明度变化时间
    local forever = fadeController.forever or {0, 0} --{是否循环, 循环间隔时间}
    local blend = fadeController.blend or 0 --颜色混合
    
    fadeSp:setOpacity(startOpacity)
    local arr = CCArray:create()
    for k, v in pairs(fv) do
        local fac = CCFadeTo:create(ft[k] or 0, v)
        arr:addObject(fac)
    end
    local fadeAc = CCSequence:create(arr)
    if forever[1] == 0 then
        fadeSp:runAction(fadeAc)
    elseif forever[2] == 0 then
        fadeSp:runAction(CCRepeatForever:create(fadeAc))
    elseif forever[2] > 0 then
        fadeSp:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCDelayTime:create(forever[2]), fadeAc)))
    end
    
    if blend == 1 then
        -- local blendFunc=ccBlendFunc:new()
        --    blendFunc.src=GL_ONE
        --    blendFunc.dst=GL_ONE
        --    fadeSp:setBlendFunc(blendFunc)
    end
    
    fv = {}
    fv = nil
    ft = {}
    ft = nil
    forever = {}
    forever = nil
end
----飞艇动画 isNoAni: 只返回 飞艇单图 、 isReverse : true 飞艇朝向上面，false（nil) 为默认朝向下面（正面）
----isUseInBattle:(类型table) 战斗内使用, addShadow:添加阴影
function G_showAirShip(airShipId, isReverse, isNoAni, isAddClick, callBack, isUseInBattle, addShadow)--airShipId : 1, 2, 3, 4...
    airShipId = tonumber(airShipId)
    local pIdx = isReverse and 2 or 1
    -- print("airShipId------>>>>",airShipId, pIdx)
    local airShipSp, defutAddPic, shadowSp
    
    if isAddClick then
        local function clickCallBack(hd, fn, index)
            if callBack then callBack(hd, fn, index) end
        end
        airShipSp = LuaCCSprite:createWithSpriteFrameName("arpl_ship"..airShipId.."_"..pIdx..".png", clickCallBack)
    else
        airShipSp = CCSprite:createWithSpriteFrameName("arpl_ship"..airShipId.."_"..pIdx..".png")
    end
    
    if airShipId == 1 or airShipId == 6 or airShipId == 7 then
        defutAddPic = CCSprite:createWithSpriteFrameName("arpl_ship"..airShipId.."_"..pIdx.."_propeller1.png")
    else
        defutAddPic = CCSprite:createWithSpriteFrameName("arpl_shipUniversalRopeller"..pIdx.."_1.png")
    end
    defutAddPic:setPosition(getCenterPoint(airShipSp, 10))
    airShipSp:addChild(defutAddPic, 5)
    
    if isNoAni then
        return airShipSp
    end
    
    if airShipId > 1 then
        if addShadow then
            local shadowStr = "shipShadow_"..pIdx..".png"
            if airShipId == 6 then
                shadowStr = "shipShadowG1_"..pIdx..".png"
            elseif airShipId == 7 then
                shadowStr = "shipShadowG2_"..pIdx..".png"
            end
            
            shadowSp = CCSprite:createWithSpriteFrameName(shadowStr)
            shadowSp:setPosition(296, -84)
            shadowSp:setScale(2)
            airShipSp:addChild(shadowSp)
        end
        
        local airShipSp2 = CCSprite:createWithSpriteFrameName("arpl_ship"..airShipId.."_"..pIdx..".png")
        airShipSp2:setPosition(getCenterPoint(airShipSp))
        airShipSp:addChild(airShipSp2, 3)
    end
    
    local shipWidth, shiHeight = airShipSp:getContentSize().width, airShipSp:getContentSize().height
    
    if not isReverse then--正向
        local propellerNum = 7
        if airShipId == 1 then
            propellerNum = 6
        elseif airShipId == 6 then
            propellerNum = 8
        end
        
        local pzArr = CCArray:create()
        if airShipId == 1 or airShipId == 6 or airShipId == 7 then
            for kk = 1, propellerNum do
                local nameStr = "arpl_ship"..airShipId.."_"..pIdx.."_propeller"..kk..".png"
                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                pzArr:addObject(frame)
            end
        else
            for kk = 1, propellerNum do
                local nameStr = "arpl_shipUniversalRopeller"..pIdx.."_"..kk..".png"
                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                pzArr:addObject(frame)
            end
        end
        local animation = CCAnimation:createWithSpriteFrames(pzArr)
        animation:setDelayPerUnit(0.08)
        local animate = CCAnimate:create(animation)
        local repeatAnimt = CCRepeatForever:create(animate)
        defutAddPic:runAction(repeatAnimt)
        
        if airShipId < 5 then
            if airShipId == 1 then
                local sideLgithBlueSp = CCSprite:createWithSpriteFrameName("arpl_ship1_1_sideLightBlue.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                sideLgithBlueSp:setBlendFunc(blendFunc)
                
                sideLgithBlueSp:setPosition(shipWidth * 0.5 - 10, 210)
                airShipSp:addChild(sideLgithBlueSp, 5)
                
                local FadeIn = CCFadeIn:create(1.2)
                local FadeOut = CCFadeOut:create(1.2)
                local fseq = CCSequence:createWithTwoActions(FadeIn, FadeOut)
                local repeatFseq = CCRepeatForever:create(fseq)
                sideLgithBlueSp:runAction(repeatFseq)
                
                local flickerSp1 = CCSprite:createWithSpriteFrameName("arpl_ship1_1_flickerBlue1.png")
                flickerSp1:setScale(0.9)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                flickerSp1:setBlendFunc(blendFunc)
                
                local flArr1 = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_ship1_1_flickerBlue"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    flArr1:addObject(frame)
                end
                local animation = CCAnimation:createWithSpriteFrames(flArr1)
                animation:setDelayPerUnit(0.03)
                local animate = CCAnimate:create(animation)
                local repeatForever = CCRepeatForever:create(animate)
                flickerSp1:setPosition(ccp(231, 175))
                flickerSp1:runAction(repeatForever)
                airShipSp:addChild(flickerSp1, 5)
                
                local flickerSp2 = CCSprite:createWithSpriteFrameName("arpl_ship1_1_flickerBlue1.png")
                flickerSp2:setScale(1.2)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                flickerSp2:setBlendFunc(blendFunc)
                
                local flArr2 = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_ship1_1_flickerBlue"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    flArr2:addObject(frame)
                end
                local animation2 = CCAnimation:createWithSpriteFrames(flArr2)
                animation2:setDelayPerUnit(0.03)
                local animate = CCAnimate:create(animation2)
                local repeatForever = CCRepeatForever:create(animate)
                flickerSp2:setPosition(ccp(257, 119))
                flickerSp2:runAction(repeatForever)
                airShipSp:addChild(flickerSp2, 5)
                
                --117 231 arpl_ship1_1_spinWipes1 15
                local spinWipesSp = CCSprite:createWithSpriteFrameName("arpl_ship1_1_spinWipes1.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                spinWipesSp:setBlendFunc(blendFunc)
                
                local spinArr = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_ship1_1_spinWipes"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    spinArr:addObject(frame)
                end
                local animation2 = CCAnimation:createWithSpriteFrames(spinArr)
                animation2:setDelayPerUnit(0.07)
                local animate = CCAnimate:create(animation2)
                local repeatForever = CCRepeatForever:create(animate)
                spinWipesSp:setPosition(ccp(117, 238))
                spinWipesSp:runAction(repeatForever)
                airShipSp:addChild(spinWipesSp, 5)
                
                --305 255
                local stripWipesSp = CCSprite:createWithSpriteFrameName("arpl_ship1_1_stripWipes1.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                stripWipesSp:setBlendFunc(blendFunc)
                
                local stripArr = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_ship1_1_stripWipes"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    stripArr:addObject(frame)
                end
                local animation2 = CCAnimation:createWithSpriteFrames(stripArr)
                animation2:setDelayPerUnit(0.07)
                local animate = CCAnimate:create(animation2)
                local repeatForever = CCRepeatForever:create(animate)
                stripWipesSp:setPosition(ccp(281, 244))
                stripWipesSp:runAction(repeatForever)
                airShipSp:addChild(stripWipesSp, 5)
            elseif airShipId == 2 then
                
                local flickerSp = CCSprite:createWithSpriteFrameName("arpl_shipLightFlicker1.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                flickerSp:setBlendFunc(blendFunc)
                
                local filickerArr = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_shipLightFlicker"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    filickerArr:addObject(frame)
                end
                local flickerAnim = CCAnimation:createWithSpriteFrames(filickerArr)
                flickerAnim:setDelayPerUnit(0.05)
                local animate = CCAnimate:create(flickerAnim)
                local repeatForever = CCRepeatForever:create(animate)
                flickerSp:setPosition(ccp(127, 82))
                flickerSp:runAction(repeatForever)
                airShipSp:addChild(flickerSp, 5)
                
                local lightOrgSp = CCSprite:createWithSpriteFrameName("arpl_ship2_1_lightOrg.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                lightOrgSp:setBlendFunc(blendFunc)
                
                lightOrgSp:setPosition(113, 92)
                airShipSp:addChild(lightOrgSp, 5)
                
                local orgLightSp = CCSprite:createWithSpriteFrameName("arpl_ship2_1_orgLight.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                orgLightSp:setBlendFunc(blendFunc)
                
                local orgLgithFadeOut = CCFadeTo:create(0.4, 255 * 0.4)
                local orgLgithFadeIn = CCFadeTo:create(0.6, 255)
                local orgLightArr = CCArray:create()
                orgLightArr:addObject(orgLgithFadeOut)
                orgLightArr:addObject(orgLgithFadeIn)
                local orgLightSeq = CCSequence:create(orgLightArr)
                local orgLightRepeat = CCRepeatForever:create(orgLightSeq)
                orgLightSp:runAction(orgLightRepeat)
                orgLightSp:setPosition(182, 111)
                airShipSp:addChild(orgLightSp, 5)
                
                local org1Sp = CCSprite:createWithSpriteFrameName("arpl_ship2_1_org1.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                org1Sp:setBlendFunc(blendFunc)
                
                if isUseInBattle then
                    if isUseInBattle.start then
                        org1Sp:setVisible(false)
                        local bDet1 = CCDelayTime:create(isUseInBattle.inT)
                        local function org1VisibleTrueCall()
                            org1Sp:setVisible(true)
                            
                            local org1FadeOut = CCFadeTo:create(1, 255 * 0.2)
                            local org1FadeIn = CCFadeTo:create(1, 255)
                            local org1Det = CCDelayTime:create(1.32 * G_battleSpeed)
                            local org1Arr = CCArray:create()
                            org1Arr:addObject(org1FadeOut)
                            org1Arr:addObject(org1FadeIn)
                            org1Arr:addObject(org1Det)
                            local org1Seq = CCSequence:create(org1Arr)
                            local org1Repeat = CCRepeatForever:create(org1Seq)
                            org1Sp:runAction(org1Repeat)
                        end
                        local org1VisCall = CCCallFunc:create(org1VisibleTrueCall)
                        local bArr = CCArray:create()
                        bArr:addObject(bDet1)
                        bArr:addObject(org1VisCall)
                        local bSeq = CCSequence:create(bArr)
                        org1Sp:runAction(bSeq)
                    end
                else
                    local org1FadeOut = CCFadeTo:create(1, 255 * 0.2)
                    local org1FadeIn = CCFadeTo:create(1, 255)
                    local org1Det = CCDelayTime:create(1.32)
                    local org1Arr = CCArray:create()
                    org1Arr:addObject(org1FadeOut)
                    org1Arr:addObject(org1FadeIn)
                    org1Arr:addObject(org1Det)
                    local org1Seq = CCSequence:create(org1Arr)
                    local org1Repeat = CCRepeatForever:create(org1Seq)
                    
                    org1Sp:runAction(org1Repeat)
                end
                org1Sp:setPosition(244, 126)
                airShipSp:addChild(org1Sp, 5)
                
                local org2Sp = CCSprite:createWithSpriteFrameName("arpl_ship2_1_org2.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                org2Sp:setBlendFunc(blendFunc)
                
                if isUseInBattle then
                    if isUseInBattle.start then
                        org2Sp:setVisible(false)
                        local bDet1 = CCDelayTime:create(isUseInBattle.inT)
                        local function org2VisibleTrueCall()
                            org2Sp:setVisible(true)
                            
                            local org2Det1 = CCDelayTime:create(0.66 * G_battleSpeed)
                            local org2FadeOut = CCFadeTo:create(1, 255 * 0.2)
                            local org2FadeIn = CCFadeTo:create(1, 255)
                            local org2Det2 = CCDelayTime:create(0.66 * G_battleSpeed)
                            local org2Arr = CCArray:create()
                            org2Arr:addObject(org2Det1)
                            org2Arr:addObject(org2FadeOut)
                            org2Arr:addObject(org2FadeIn)
                            org2Arr:addObject(org2Det2)
                            local org2Seq = CCSequence:create(org2Arr)
                            local org2Repeat = CCRepeatForever:create(org2Seq)
                            org2Sp:runAction(org2Repeat)
                        end
                        local org2VisCall = CCCallFunc:create(org2VisibleTrueCall)
                        local bArr = CCArray:create()
                        bArr:addObject(bDet1)
                        bArr:addObject(org2VisCall)
                        local bSeq = CCSequence:create(bArr)
                        org2Sp:runAction(bSeq)
                    end
                else
                    local org2Det1 = CCDelayTime:create(0.66)
                    local org2FadeOut = CCFadeTo:create(1, 255 * 0.2)
                    local org2FadeIn = CCFadeTo:create(1, 255)
                    local org2Det2 = CCDelayTime:create(0.66)
                    local org2Arr = CCArray:create()
                    org2Arr:addObject(org2Det1)
                    org2Arr:addObject(org2FadeOut)
                    org2Arr:addObject(org2FadeIn)
                    org2Arr:addObject(org2Det2)
                    local org2Seq = CCSequence:create(org2Arr)
                    local org2Repeat = CCRepeatForever:create(org2Seq)
                    
                    org2Sp:runAction(org2Repeat)
                end
                org2Sp:setPosition(263, 135)
                airShipSp:addChild(org2Sp, 5)
                
                local org3Sp = CCSprite:createWithSpriteFrameName("arpl_ship2_1_org3.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                org3Sp:setBlendFunc(blendFunc)
                
                if isUseInBattle then
                    if isUseInBattle.start then
                        org3Sp:setVisible(false)
                        local bDet1 = CCDelayTime:create(isUseInBattle.inT)
                        local function org3VisibleTrueCall()
                            org3Sp:setVisible(true)
                            
                            local org3Det = CCDelayTime:create(1.32 * G_battleSpeed)
                            local org3FadeOut = CCFadeTo:create(1, 255 * 0.2)
                            local org3FadeIn = CCFadeTo:create(1, 255)
                            local org3Arr = CCArray:create()
                            org3Arr:addObject(org3Det)
                            org3Arr:addObject(org3FadeOut)
                            org3Arr:addObject(org3FadeIn)
                            
                            local org3Seq = CCSequence:create(org3Arr)
                            local org3Repeat = CCRepeatForever:create(org3Seq)
                            org3Sp:runAction(org3Repeat)
                        end
                        local org3VisCall = CCCallFunc:create(org3VisibleTrueCall)
                        local bArr = CCArray:create()
                        bArr:addObject(bDet1)
                        bArr:addObject(org3VisCall)
                        local bSeq = CCSequence:create(bArr)
                        org3Sp:runAction(bSeq)
                    end
                else
                    local org3Det = CCDelayTime:create(1.32)
                    local org3FadeOut = CCFadeTo:create(1, 255 * 0.2)
                    local org3FadeIn = CCFadeTo:create(1, 255)
                    local org3Arr = CCArray:create()
                    org3Arr:addObject(org3Det)
                    org3Arr:addObject(org3FadeOut)
                    org3Arr:addObject(org3FadeIn)
                    
                    local org3Seq = CCSequence:create(org3Arr)
                    local org3Repeat = CCRepeatForever:create(org3Seq)
                    
                    org3Sp:runAction(org3Repeat)
                end
                org3Sp:setPosition(280, 145)
                airShipSp:addChild(org3Sp, 5)
                
                local blueLight1Sp = CCSprite:createWithSpriteFrameName("arpl_ship2_1_bluelight.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                blueLight1Sp:setBlendFunc(blendFunc)
                
                local blFadeOut = CCFadeTo:create(1, 255 * 0.4)
                local blFadeIn = CCFadeTo:create(1, 255)
                local blArr = CCArray:create()
                blArr:addObject(blFadeOut)
                blArr:addObject(blFadeIn)
                local blSeq = CCSequence:create(blArr)
                local blRepeat = CCRepeatForever:create(blSeq)
                blueLight1Sp:runAction(blRepeat)
                blueLight1Sp:setPosition(309, 167)
                airShipSp:addChild(blueLight1Sp, 5)
                
                local blueLight2Sp = CCSprite:createWithSpriteFrameName("arpl_ship2_1_bluelight.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                blueLight2Sp:setBlendFunc(blendFunc)
                
                local bl2FadeOut = CCFadeTo:create(1, 255 * 0.4)
                local bl2FadeIn = CCFadeTo:create(1, 255)
                local bl2Arr = CCArray:create()
                bl2Arr:addObject(bl2FadeOut)
                bl2Arr:addObject(bl2FadeIn)
                local bl2Seq = CCSequence:create(bl2Arr)
                local bl2Repeat = CCRepeatForever:create(bl2Seq)
                blueLight2Sp:runAction(bl2Repeat)
                blueLight2Sp:setPosition(274, 150)
                airShipSp:addChild(blueLight2Sp, 5)
                
                local blueLight3Sp = CCSprite:createWithSpriteFrameName("arpl_ship2_1_bluelight.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                blueLight3Sp:setBlendFunc(blendFunc)
                
                local bl3FadeOut = CCFadeTo:create(1, 255 * 0.4)
                local bl3FadeIn = CCFadeTo:create(1, 255)
                local bl3Arr = CCArray:create()
                bl3Arr:addObject(bl3FadeOut)
                bl3Arr:addObject(bl3FadeIn)
                local bl3Seq = CCSequence:create(bl3Arr)
                local bl3Repeat = CCRepeatForever:create(bl3Seq)
                blueLight3Sp:setFlipX(true)
                blueLight3Sp:setRotation(25)
                blueLight3Sp:runAction(bl3Repeat)
                blueLight3Sp:setPosition(120, 165)
                airShipSp:addChild(blueLight3Sp, 1)
                
                --19
                local blueWipesSp = CCSprite:createWithSpriteFrameName("arpl_ship2_1_blue_1.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                blueWipesSp:setBlendFunc(blendFunc)
                
                local bwArr = CCArray:create()
                for kk = 1, 19 do
                    local nameStr = "arpl_ship2_1_blue_"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    bwArr:addObject(frame)
                end
                local bwAnim = CCAnimation:createWithSpriteFrames(bwArr)
                bwAnim:setDelayPerUnit(0.07)
                local animate = CCAnimate:create(bwAnim)
                local repeatForever = CCRepeatForever:create(animate)
                blueWipesSp:setPosition(ccp(227, 175))
                blueWipesSp:runAction(repeatForever)
                airShipSp:addChild(blueWipesSp, 5)
                
                local shipTailSmokeSp = CCSprite:createWithSpriteFrameName("arpl_shipSmoke1.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                shipTailSmokeSp:setBlendFunc(blendFunc)
                
                local tmArr = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_shipSmoke"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    tmArr:addObject(frame)
                end
                local tmAnim = CCAnimation:createWithSpriteFrames(tmArr)
                tmAnim:setDelayPerUnit(0.05)
                local animate = CCAnimate:create(tmAnim)
                local repeatForever = CCRepeatForever:create(animate)
                shipTailSmokeSp:setPosition(ccp(290, 185))
                shipTailSmokeSp:runAction(repeatForever)
                airShipSp:addChild(shipTailSmokeSp, 1)
                
                local shipTailFlameSp = CCSprite:createWithSpriteFrameName("arpl_shipFire1.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                shipTailFlameSp:setBlendFunc(blendFunc)
                
                local tfArr = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_shipFire"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    tfArr:addObject(frame)
                end
                local tfAnim = CCAnimation:createWithSpriteFrames(tfArr)
                tfAnim:setDelayPerUnit(0.05)
                local animate = CCAnimate:create(tfAnim)
                if isUseInBattle then
                    if isUseInBattle.start then
                        local function fireVisibleFalseHandl() shipTailFlameSp:setVisible(false) end
                        local flameVisCall = CCCallFunc:create(fireVisibleFalseHandl)
                        local function fireVisibleTrueHandl() shipTailFlameSp:setVisible(true) end
                        local flameVisCall2 = CCCallFunc:create(fireVisibleTrueHandl)
                        local det1 = CCDelayTime:create(isUseInBattle.inT + isUseInBattle.dlT1 + isUseInBattle.dlT2)
                        local battleArr = CCArray:create()
                        battleArr:addObject(flameVisCall)
                        battleArr:addObject(det1)
                        battleArr:addObject(flameVisCall2)
                        local repeatForever = CCRepeatForever:create(animate)
                        battleArr:addObject(repeatForever)
                        local battleSeq = CCSequence:create(battleArr)
                        shipTailFlameSp:runAction(battleSeq)
                    end
                else
                    local repeatForever = CCRepeatForever:create(animate)
                    shipTailFlameSp:runAction(repeatForever)
                end
                shipTailFlameSp:setPosition(ccp(290, 185))
                airShipSp:addChild(shipTailFlameSp, 1)
            elseif airShipId == 3 then
                
                local flickerSp1 = CCSprite:createWithSpriteFrameName("arpl_shipLightFlicker1.png")
                flickerSp1:setScale(0.9)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                flickerSp1:setBlendFunc(blendFunc)
                
                local filickerArr = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_shipLightFlicker"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    filickerArr:addObject(frame)
                end
                local flickerAnim = CCAnimation:createWithSpriteFrames(filickerArr)
                flickerAnim:setDelayPerUnit(0.05)
                local animate = CCAnimate:create(flickerAnim)
                local repeatForever = CCRepeatForever:create(animate)
                flickerSp1:setPosition(ccp(147, 139))
                flickerSp1:runAction(repeatForever)
                airShipSp:addChild(flickerSp1, 5)
                
                local flickerSp2 = CCSprite:createWithSpriteFrameName("arpl_shipLightFlicker1.png")
                flickerSp2:setScale(0.9)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                flickerSp2:setBlendFunc(blendFunc)
                
                local filickerArr2 = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_shipLightFlicker"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    filickerArr2:addObject(frame)
                end
                local flickerAnim2 = CCAnimation:createWithSpriteFrames(filickerArr2)
                flickerAnim2:setDelayPerUnit(0.05)
                local animate = CCAnimate:create(flickerAnim2)
                local repeatForever = CCRepeatForever:create(animate)
                flickerSp2:setPosition(ccp(243, 92))
                flickerSp2:runAction(repeatForever)
                airShipSp:addChild(flickerSp2, 5)
                
                --arpl_ship3_1_orgLight1.png
                local orgLight1 = CCSprite:createWithSpriteFrameName("arpl_ship3_1_orgLight1.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                orgLight1:setBlendFunc(blendFunc)
                
                local olFadeOut = CCFadeTo:create(0.5, 255 * 0.25)
                local olFadeIn = CCFadeTo:create(0.5, 255)
                local olArr = CCArray:create()
                olArr:addObject(olFadeOut)
                olArr:addObject(olFadeIn)
                local olSeq = CCSequence:create(olArr)
                local olRepeat = CCRepeatForever:create(olSeq)
                orgLight1:runAction(olRepeat)
                orgLight1:setPosition(267, 201)
                airShipSp:addChild(orgLight1, 5)
                
                local orgLight2 = CCSprite:createWithSpriteFrameName("arpl_ship3_1_orgLight2.png")
                orgLight2:setOpacity(255 * 0.25)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                orgLight2:setBlendFunc(blendFunc)
                
                local ol2FadeOut = CCFadeTo:create(0.5, 255)
                local ol2FadeIn = CCFadeTo:create(0.5, 255 * 0.25)
                local ol2Arr = CCArray:create()
                ol2Arr:addObject(ol2FadeOut)
                ol2Arr:addObject(ol2FadeIn)
                local ol2Seq = CCSequence:create(ol2Arr)
                local ol2Repeat = CCRepeatForever:create(ol2Seq)
                orgLight2:runAction(ol2Repeat)
                orgLight2:setPosition(260, 131)
                airShipSp:addChild(orgLight2, 5)
                
                local jetSp = CCSprite:createWithSpriteFrameName("arpl_ship3_1_jetLight1.png")
                jetSp:setScale(0.9)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                jetSp:setBlendFunc(blendFunc)
                
                local jetArr = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_ship3_1_jetLight"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    jetArr:addObject(frame)
                end
                local jetAnimtion = CCAnimation:createWithSpriteFrames(jetArr)
                jetAnimtion:setDelayPerUnit(0.03)
                local animate = CCAnimate:create(jetAnimtion)
                local repeatForever = CCRepeatForever:create(animate)
                jetSp:setPosition(ccp(149.5, 108.5))
                jetSp:runAction(repeatForever)
                airShipSp:addChild(jetSp, 5)
                --
                local shipTailSmokeSp = CCSprite:createWithSpriteFrameName("arpl_shipSmoke1.png")
                shipTailSmokeSp:setScale(0.75)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                shipTailSmokeSp:setBlendFunc(blendFunc)
                
                local tmArr = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_shipSmoke"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    tmArr:addObject(frame)
                end
                local tmAnim = CCAnimation:createWithSpriteFrames(tmArr)
                tmAnim:setDelayPerUnit(0.03)
                local animate = CCAnimate:create(tmAnim)
                local repeatForever = CCRepeatForever:create(animate)
                shipTailSmokeSp:setPosition(ccp(276, 194))
                shipTailSmokeSp:runAction(repeatForever)
                airShipSp:addChild(shipTailSmokeSp, 1)
                
                local shipTailFlameSp = CCSprite:createWithSpriteFrameName("arpl_shipFire1.png")
                shipTailFlameSp:setScale(0.75)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                shipTailFlameSp:setBlendFunc(blendFunc)
                
                if isUseInBattle then
                    if isUseInBattle.start then
                        local function fireVisibleFalseHandl() shipTailFlameSp:setVisible(false) end
                        local flameVisCall = CCCallFunc:create(fireVisibleFalseHandl)
                        local function fireVisibleTrueHandl()
                            shipTailFlameSp:setVisible(true)
                            
                            local tfArr = CCArray:create()
                            for kk = 1, 15 do
                                local nameStr = "arpl_shipFire"..kk..".png"
                                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                                tfArr:addObject(frame)
                            end
                            local tfAnim = CCAnimation:createWithSpriteFrames(tfArr)
                            tfAnim:setDelayPerUnit(0.05)
                            local animate = CCAnimate:create(tfAnim)
                            
                            local repeatForever = CCRepeatForever:create(animate)
                            shipTailFlameSp:runAction(repeatForever)
                        end
                        local flameVisCall2 = CCCallFunc:create(fireVisibleTrueHandl)
                        local det1 = CCDelayTime:create(isUseInBattle.inT + isUseInBattle.dlT1 + isUseInBattle.dlT2)
                        local battleArr = CCArray:create()
                        battleArr:addObject(flameVisCall)
                        battleArr:addObject(det1)
                        battleArr:addObject(flameVisCall2)
                        local battleSeq = CCSequence:create(battleArr)
                        shipTailFlameSp:runAction(battleSeq)
                    end
                else
                    local tfArr = CCArray:create()
                    for kk = 1, 15 do
                        local nameStr = "arpl_shipFire"..kk..".png"
                        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                        tfArr:addObject(frame)
                    end
                    local tfAnim = CCAnimation:createWithSpriteFrames(tfArr)
                    tfAnim:setDelayPerUnit(0.05)
                    local animate = CCAnimate:create(tfAnim)
                    
                    local repeatForever = CCRepeatForever:create(animate)
                    shipTailFlameSp:runAction(repeatForever)
                end
                shipTailFlameSp:setPosition(ccp(276, 194))
                airShipSp:addChild(shipTailFlameSp, 1)
                ----
                local shipTailSmokeSp2 = CCSprite:createWithSpriteFrameName("arpl_shipSmoke1.png")
                shipTailSmokeSp2:setScale(0.9)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                shipTailSmokeSp2:setBlendFunc(blendFunc)
                
                local tmArr2 = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_shipSmoke"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    tmArr2:addObject(frame)
                end
                local tmAnim2 = CCAnimation:createWithSpriteFrames(tmArr2)
                tmAnim2:setDelayPerUnit(0.03)
                local animate = CCAnimate:create(tmAnim2)
                local repeatForever = CCRepeatForever:create(animate)
                shipTailSmokeSp2:setPosition(ccp(325, 176))
                shipTailSmokeSp2:runAction(repeatForever)
                airShipSp:addChild(shipTailSmokeSp2, 1)
                
                local shipTailFlameSp2 = CCSprite:createWithSpriteFrameName("arpl_shipFire1.png")
                shipTailFlameSp2:setScale(0.9)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                shipTailFlameSp2:setBlendFunc(blendFunc)
                
                if isUseInBattle then
                    if isUseInBattle.start then
                        local function fireVisibleFalseHandl() shipTailFlameSp2:setVisible(false) end
                        local flameVisCall = CCCallFunc:create(fireVisibleFalseHandl)
                        local function fireVisibleTrueHandl()
                            shipTailFlameSp2:setVisible(true)
                            
                            local tfArr2 = CCArray:create()
                            for kk = 1, 15 do
                                local nameStr = "arpl_shipFire"..kk..".png"
                                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                                tfArr2:addObject(frame)
                            end
                            local tfAnim2 = CCAnimation:createWithSpriteFrames(tfArr2)
                            tfAnim2:setDelayPerUnit(0.05)
                            local animate2 = CCAnimate:create(tfAnim2)
                            local repeatForever = CCRepeatForever:create(animate2)
                            shipTailFlameSp2:runAction(repeatForever)
                        end
                        local flameVisCall2 = CCCallFunc:create(fireVisibleTrueHandl)
                        local det1 = CCDelayTime:create(isUseInBattle.inT + isUseInBattle.dlT1 + isUseInBattle.dlT2)
                        local battleArr = CCArray:create()
                        battleArr:addObject(flameVisCall)
                        battleArr:addObject(det1)
                        battleArr:addObject(flameVisCall2)
                        local battleSeq = CCSequence:create(battleArr)
                        shipTailFlameSp2:runAction(battleSeq)
                    end
                else
                    local tfArr2 = CCArray:create()
                    for kk = 1, 15 do
                        local nameStr = "arpl_shipFire"..kk..".png"
                        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                        tfArr2:addObject(frame)
                    end
                    local tfAnim2 = CCAnimation:createWithSpriteFrames(tfArr2)
                    tfAnim2:setDelayPerUnit(0.05)
                    local animate2 = CCAnimate:create(tfAnim2)
                    local repeatForever = CCRepeatForever:create(animate2)
                    shipTailFlameSp2:runAction(repeatForever)
                end
                shipTailFlameSp2:setPosition(ccp(325, 176))
                airShipSp:addChild(shipTailFlameSp2, 1)
            elseif airShipId == 4 then
                
                local triangleSp = CCSprite:createWithSpriteFrameName("arpl_ship4_1_triangleOrgLight.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                triangleSp:setBlendFunc(blendFunc)
                
                triangleSp:setPosition(174.5, 91.5)
                airShipSp:addChild(triangleSp, 5)
                
                local circleSp = CCSprite:createWithSpriteFrameName("arpl_ship4_1_circleOrgLight.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                circleSp:setBlendFunc(blendFunc)
                
                if isUseInBattle then
                    if isUseInBattle.start then
                        circleSp:setVisible(false)
                        local det = CCDelayTime:create(isUseInBattle.inT)
                        local blink = CCBlink:create(1, 3)
                        local function cSpShowHandl() circleSp:setVisible(true) end
                        local cSpCall = CCCallFunc:create(cSpShowHandl)
                        local cArr = CCArray:create()
                        cArr:addObject(det)
                        cArr:addObject(blink)
                        cArr:addObject(cSpCall)
                        local cSeq = CCSequence:create(cArr)
                        circleSp:runAction(cSeq)
                    end
                end
                
                circleSp:setPosition(310, 145)
                airShipSp:addChild(circleSp, 5)
                
                local flickerSp1 = CCSprite:createWithSpriteFrameName("arpl_shipLightFlicker1.png")
                flickerSp1:setScale(0.8)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                flickerSp1:setBlendFunc(blendFunc)
                
                local filickerArr = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_shipLightFlicker"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    filickerArr:addObject(frame)
                end
                local flickerAnim = CCAnimation:createWithSpriteFrames(filickerArr)
                flickerAnim:setDelayPerUnit(0.03)
                local animate = CCAnimate:create(flickerAnim)
                local repeatForever = CCRepeatForever:create(animate)
                flickerSp1:setPosition(ccp(151, 132))
                flickerSp1:runAction(repeatForever)
                airShipSp:addChild(flickerSp1, 5)
                
                local flickerSp2 = CCSprite:createWithSpriteFrameName("arpl_shipLightFlicker1.png")
                flickerSp2:setScale(1.5)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                flickerSp2:setBlendFunc(blendFunc)
                
                local filickerArr2 = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_shipLightFlicker"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    filickerArr2:addObject(frame)
                end
                local flickerAnim2 = CCAnimation:createWithSpriteFrames(filickerArr2)
                flickerAnim2:setDelayPerUnit(0.03)
                local animate = CCAnimate:create(flickerAnim2)
                local repeatForever = CCRepeatForever:create(animate)
                flickerSp2:setPosition(ccp(121, 103))
                flickerSp2:runAction(repeatForever)
                airShipSp:addChild(flickerSp2, 5)
                
                local flickerSp3 = CCSprite:createWithSpriteFrameName("arpl_shipLightFlicker1.png")
                flickerSp3:setScale(0.85)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                flickerSp3:setBlendFunc(blendFunc)
                
                local filickerArr3 = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_shipLightFlicker"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    filickerArr3:addObject(frame)
                end
                local flickerAnim3 = CCAnimation:createWithSpriteFrames(filickerArr3)
                flickerAnim3:setDelayPerUnit(0.03)
                local animate = CCAnimate:create(flickerAnim3)
                local repeatForever = CCRepeatForever:create(animate)
                flickerSp3:setPosition(ccp(121, 85))
                flickerSp3:runAction(repeatForever)
                airShipSp:addChild(flickerSp3, 5)
                
                local verticalBar = CCSprite:createWithSpriteFrameName("arpl_ship4_1_verticalBarOrgLight.png")
                verticalBar:setOpacity(255 * 0.25)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                verticalBar:setBlendFunc(blendFunc)
                
                local vbFadeOut = CCFadeTo:create(1, 255 * 0.5)
                local vbFadeIn = CCFadeTo:create(1, 255)
                local vbArr = CCArray:create()
                vbArr:addObject(vbFadeOut)
                vbArr:addObject(vbFadeIn)
                local vbSeq = CCSequence:create(vbArr)
                local vbRepeat = CCRepeatForever:create(vbSeq)
                verticalBar:runAction(vbRepeat)
                verticalBar:setPosition(268.5, 196.5)
                airShipSp:addChild(verticalBar, 5)
                
                local squareOrgLightSp = CCSprite:createWithSpriteFrameName("arpl_ship4_1_squareOrgLight.png")
                squareOrgLightSp:setOpacity(0)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                squareOrgLightSp:setBlendFunc(blendFunc)
                
                local solFadeOut = CCFadeTo:create(0.75, 255)
                local solFadeIn = CCFadeTo:create(0.75, 0)
                local solArr = CCArray:create()
                solArr:addObject(solFadeOut)
                solArr:addObject(solFadeIn)
                local solSeq = CCSequence:create(solArr)
                local solRepeat = CCRepeatForever:create(solSeq)
                squareOrgLightSp:runAction(solRepeat)
                squareOrgLightSp:setPosition(272.5, 155)
                airShipSp:addChild(squareOrgLightSp, 5)
                
                local squareOrgLightSp2 = CCSprite:createWithSpriteFrameName("arpl_ship4_1_squareOrgLight.png")
                squareOrgLightSp2:setOpacity(0)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                squareOrgLightSp2:setBlendFunc(blendFunc)
                
                local function runFadeHandl()
                    local sol2FadeOut = CCFadeTo:create(0.75, 255)
                    local sol2FadeIn = CCFadeTo:create(0.75, 0)
                    local sol2Arr = CCArray:create()
                    sol2Arr:addObject(sol2FadeOut)
                    sol2Arr:addObject(sol2FadeIn)
                    local sol2Seq = CCSequence:create(sol2Arr)
                    local sol2Repeat = CCRepeatForever:create(sol2Seq)
                    squareOrgLightSp2:runAction(sol2Repeat)
                end
                local fadeCall = CCCallFunc:create(runFadeHandl)
                local solDet = CCDelayTime:create(0.45)
                local solbeginArr = CCArray:create()
                solbeginArr:addObject(solDet)
                solbeginArr:addObject(fadeCall)
                local solbeginSeq = CCSequence:create(solbeginArr)
                squareOrgLightSp2:runAction(solbeginSeq)
                
                squareOrgLightSp2:setPosition(264.5, 151)
                airShipSp:addChild(squareOrgLightSp2, 5)
                
                local squareOrgLightSp3 = CCSprite:createWithSpriteFrameName("arpl_ship4_1_squareOrgLight.png")
                squareOrgLightSp3:setOpacity(0)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                squareOrgLightSp3:setBlendFunc(blendFunc)
                
                local function runFadeHandl3()
                    local sol3FadeOut = CCFadeTo:create(0.75, 255)
                    local sol3FadeIn = CCFadeTo:create(0.75, 0)
                    local sol3Arr = CCArray:create()
                    sol3Arr:addObject(sol3FadeOut)
                    sol3Arr:addObject(sol3FadeIn)
                    local sol3Seq = CCSequence:create(sol3Arr)
                    local sol3Repeat = CCRepeatForever:create(sol3Seq)
                    squareOrgLightSp3:runAction(sol3Repeat)
                end
                local fadeCall3 = CCCallFunc:create(runFadeHandl3)
                local solDet3 = CCDelayTime:create(0.9)
                local solbeginArr3 = CCArray:create()
                solbeginArr3:addObject(solDet3)
                solbeginArr3:addObject(fadeCall3)
                local solbeginSeq3 = CCSequence:create(solbeginArr3)
                squareOrgLightSp3:runAction(solbeginSeq3)
                
                squareOrgLightSp3:setPosition(256.5, 147.5)
                airShipSp:addChild(squareOrgLightSp3, 5)
                
                local shipTailSmokeSp = CCSprite:createWithSpriteFrameName("arpl_shipSmoke1.png")
                shipTailSmokeSp:setScale(0.75)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                shipTailSmokeSp:setBlendFunc(blendFunc)
                
                local tmArr = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_shipSmoke"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    tmArr:addObject(frame)
                end
                local tmAnim = CCAnimation:createWithSpriteFrames(tmArr)
                tmAnim:setDelayPerUnit(0.03)
                local animate = CCAnimate:create(tmAnim)
                local repeatForever = CCRepeatForever:create(animate)
                shipTailSmokeSp:setPosition(ccp(322, 204))
                shipTailSmokeSp:runAction(repeatForever)
                airShipSp:addChild(shipTailSmokeSp, 1)
                
                local shipTailFlameSp = CCSprite:createWithSpriteFrameName("arpl_shipFire1.png")
                shipTailFlameSp:setScale(0.75)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                shipTailFlameSp:setBlendFunc(blendFunc)
                
                if isUseInBattle then
                    if isUseInBattle.start then
                        local function fireVisibleFalseHandl() shipTailFlameSp:setVisible(false) end
                        local flameVisCall = CCCallFunc:create(fireVisibleFalseHandl)
                        local function fireVisibleTrueHandl()
                            shipTailFlameSp:setVisible(true)
                            
                            local tfArr = CCArray:create()
                            for kk = 1, 15 do
                                local nameStr = "arpl_shipFire"..kk..".png"
                                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                                tfArr:addObject(frame)
                            end
                            local tfAnim = CCAnimation:createWithSpriteFrames(tfArr)
                            tfAnim:setDelayPerUnit(0.05)
                            local animate = CCAnimate:create(tfAnim)
                            
                            local repeatForever = CCRepeatForever:create(animate)
                            shipTailFlameSp:runAction(repeatForever)
                        end
                        local flameVisCall2 = CCCallFunc:create(fireVisibleTrueHandl)
                        local det1 = CCDelayTime:create(isUseInBattle.inT + isUseInBattle.dlT1 + isUseInBattle.dlT2)
                        local battleArr = CCArray:create()
                        battleArr:addObject(flameVisCall)
                        battleArr:addObject(det1)
                        battleArr:addObject(flameVisCall2)
                        local battleSeq = CCSequence:create(battleArr)
                        shipTailFlameSp:runAction(battleSeq)
                    end
                else
                    local tfArr = CCArray:create()
                    for kk = 1, 15 do
                        local nameStr = "arpl_shipFire"..kk..".png"
                        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                        tfArr:addObject(frame)
                    end
                    local tfAnim = CCAnimation:createWithSpriteFrames(tfArr)
                    tfAnim:setDelayPerUnit(0.05)
                    local animate = CCAnimate:create(tfAnim)
                    
                    local repeatForever = CCRepeatForever:create(animate)
                    shipTailFlameSp:runAction(repeatForever)
                end
                shipTailFlameSp:setPosition(ccp(322, 204))
                airShipSp:addChild(shipTailFlameSp, 1)
                ----
                local shipTailSmokeSp2 = CCSprite:createWithSpriteFrameName("arpl_shipSmoke1.png")
                shipTailSmokeSp2:setScale(0.9)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                shipTailSmokeSp2:setBlendFunc(blendFunc)
                
                local tmArr2 = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_shipSmoke"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    tmArr2:addObject(frame)
                end
                local tmAnim2 = CCAnimation:createWithSpriteFrames(tmArr2)
                tmAnim2:setDelayPerUnit(0.03)
                local animate = CCAnimate:create(tmAnim2)
                local repeatForever = CCRepeatForever:create(animate)
                shipTailSmokeSp2:setPosition(ccp(328, 172))
                shipTailSmokeSp2:runAction(repeatForever)
                airShipSp:addChild(shipTailSmokeSp2, 1)
                
                local shipTailFlameSp2 = CCSprite:createWithSpriteFrameName("arpl_shipFire1.png")
                shipTailSmokeSp2:setScale(0.9)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                shipTailFlameSp2:setBlendFunc(blendFunc)
                
                if isUseInBattle then
                    if isUseInBattle.start then
                        local function fireVisibleFalseHandl() shipTailFlameSp2:setVisible(false) end
                        local flameVisCall = CCCallFunc:create(fireVisibleFalseHandl)
                        local function fireVisibleTrueHandl()
                            shipTailFlameSp2:setVisible(true)
                            
                            local tfArr2 = CCArray:create()
                            for kk = 1, 15 do
                                local nameStr = "arpl_shipFire"..kk..".png"
                                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                                tfArr2:addObject(frame)
                            end
                            local tfAnim2 = CCAnimation:createWithSpriteFrames(tfArr2)
                            tfAnim2:setDelayPerUnit(0.05)
                            local animate = CCAnimate:create(tfAnim2)
                            
                            local repeatForever = CCRepeatForever:create(animate)
                            shipTailFlameSp2:runAction(repeatForever)
                        end
                        local flameVisCall2 = CCCallFunc:create(fireVisibleTrueHandl)
                        local det1 = CCDelayTime:create(isUseInBattle.inT + isUseInBattle.dlT1 + isUseInBattle.dlT2)
                        local battleArr = CCArray:create()
                        battleArr:addObject(flameVisCall)
                        battleArr:addObject(det1)
                        battleArr:addObject(flameVisCall2)
                        local battleSeq = CCSequence:create(battleArr)
                        shipTailFlameSp2:runAction(battleSeq)
                    end
                else
                    local tfArr2 = CCArray:create()
                    for kk = 1, 15 do
                        local nameStr = "arpl_shipFire"..kk..".png"
                        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                        tfArr2:addObject(frame)
                    end
                    local tfAnim2 = CCAnimation:createWithSpriteFrames(tfArr2)
                    tfAnim2:setDelayPerUnit(0.05)
                    local animate = CCAnimate:create(tfAnim2)
                    
                    local repeatForever = CCRepeatForever:create(animate)
                    shipTailFlameSp2:runAction(repeatForever)
                end
                shipTailFlameSp2:setPosition(ccp(328, 172))
                airShipSp:addChild(shipTailFlameSp2, 1)
            end
        else
            if airShipId == 5 then
                
                local yellowBeamSp = CCSprite:createWithSpriteFrameName("arpl_ship5_1_yellowBeam.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                yellowBeamSp:setBlendFunc(blendFunc)
                
                local ybFadeOut = CCFadeTo:create(1, 255 * 0.5)
                local ybFadeIn = CCFadeTo:create(1, 255)
                local ybArr = CCArray:create()
                ybArr:addObject(ybFadeOut)
                ybArr:addObject(ybFadeIn)
                local ybSeq = CCSequence:create(ybArr)
                local ybRepeat = CCRepeatForever:create(ybSeq)
                yellowBeamSp:runAction(ybRepeat)
                yellowBeamSp:setPosition(293.5, 146.5)
                airShipSp:addChild(yellowBeamSp, 5)
                
                local yellowLightSp = CCSprite:createWithSpriteFrameName("arpl_ship5_1_yellowLight.png")
                yellowLightSp:setOpacity(255 * 0.5)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                yellowLightSp:setBlendFunc(blendFunc)
                
                local ylFadeOut = CCFadeTo:create(1, 255)
                local ylFadeIn = CCFadeTo:create(1, 255 * 0.5)
                local ylArr = CCArray:create()
                ylArr:addObject(ylFadeOut)
                ylArr:addObject(ylFadeIn)
                local ylSeq = CCSequence:create(ylArr)
                local ylRepeat = CCRepeatForever:create(ylSeq)
                yellowLightSp:runAction(ylRepeat)
                yellowLightSp:setPosition(227.5, 182)
                airShipSp:addChild(yellowLightSp, 5)
                
                local shipTailSmokeSp = CCSprite:createWithSpriteFrameName("arpl_shipSmoke1.png")
                shipTailSmokeSp:setScale(0.75)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                shipTailSmokeSp:setBlendFunc(blendFunc)
                
                local tmArr = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_shipSmoke"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    tmArr:addObject(frame)
                end
                local tmAnim = CCAnimation:createWithSpriteFrames(tmArr)
                tmAnim:setDelayPerUnit(0.03)
                local animate = CCAnimate:create(tmAnim)
                local repeatForever = CCRepeatForever:create(animate)
                shipTailSmokeSp:setPosition(ccp(271.5, 199))
                shipTailSmokeSp:runAction(repeatForever)
                airShipSp:addChild(shipTailSmokeSp, 1)
                
                local shipTailFlameSp = CCSprite:createWithSpriteFrameName("arpl_shipFire1.png")
                shipTailFlameSp:setScale(0.75)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                shipTailFlameSp:setBlendFunc(blendFunc)
                
                if isUseInBattle then
                    if isUseInBattle.start then
                        local function fireVisibleFalseHandl() shipTailFlameSp:setVisible(false) end
                        local flameVisCall = CCCallFunc:create(fireVisibleFalseHandl)
                        local function fireVisibleTrueHandl()
                            shipTailFlameSp:setVisible(true)
                            
                            local tfArr = CCArray:create()
                            for kk = 1, 15 do
                                local nameStr = "arpl_shipFire"..kk..".png"
                                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                                tfArr:addObject(frame)
                            end
                            local tfAnim = CCAnimation:createWithSpriteFrames(tfArr)
                            tfAnim:setDelayPerUnit(0.03)
                            local animate = CCAnimate:create(tfAnim)
                            
                            local repeatForever = CCRepeatForever:create(animate)
                            shipTailFlameSp:runAction(repeatForever)
                        end
                        local flameVisCall2 = CCCallFunc:create(fireVisibleTrueHandl)
                        local det1 = CCDelayTime:create(isUseInBattle.inT + isUseInBattle.dlT1 + isUseInBattle.dlT2)
                        local battleArr = CCArray:create()
                        battleArr:addObject(flameVisCall)
                        battleArr:addObject(det1)
                        battleArr:addObject(flameVisCall2)
                        local battleSeq = CCSequence:create(battleArr)
                        shipTailFlameSp:runAction(battleSeq)
                    end
                else
                    local tfArr = CCArray:create()
                    for kk = 1, 15 do
                        local nameStr = "arpl_shipFire"..kk..".png"
                        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                        tfArr:addObject(frame)
                    end
                    local tfAnim = CCAnimation:createWithSpriteFrames(tfArr)
                    tfAnim:setDelayPerUnit(0.03)
                    local animate = CCAnimate:create(tfAnim)
                    
                    local repeatForever = CCRepeatForever:create(animate)
                    shipTailFlameSp:runAction(repeatForever)
                end
                shipTailFlameSp:setPosition(ccp(271.5, 199))
                airShipSp:addChild(shipTailFlameSp, 1)
                ----
                local shipTailSmokeSp2 = CCSprite:createWithSpriteFrameName("arpl_shipSmoke1.png")
                shipTailSmokeSp2:setScale(0.9)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                shipTailSmokeSp2:setBlendFunc(blendFunc)
                
                local tmArr2 = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_shipSmoke"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    tmArr2:addObject(frame)
                end
                local tmAnim2 = CCAnimation:createWithSpriteFrames(tmArr2)
                tmAnim2:setDelayPerUnit(0.03)
                local animate = CCAnimate:create(tmAnim2)
                local repeatForever = CCRepeatForever:create(animate)
                shipTailSmokeSp2:setPosition(ccp(311, 182))
                shipTailSmokeSp2:runAction(repeatForever)
                airShipSp:addChild(shipTailSmokeSp2, 1)
                
                local shipTailFlameSp2 = CCSprite:createWithSpriteFrameName("arpl_shipFire1.png")
                shipTailSmokeSp2:setScale(0.9)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                shipTailFlameSp2:setBlendFunc(blendFunc)
                
                if isUseInBattle then
                    if isUseInBattle.start then
                        local function fireVisibleFalseHandl() shipTailFlameSp2:setVisible(false) end
                        local flameVisCall = CCCallFunc:create(fireVisibleFalseHandl)
                        local function fireVisibleTrueHandl()
                            shipTailFlameSp2:setVisible(true)
                            
                            local tfArr2 = CCArray:create()
                            for kk = 1, 15 do
                                local nameStr = "arpl_shipFire"..kk..".png"
                                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                                tfArr2:addObject(frame)
                            end
                            local tfAnim2 = CCAnimation:createWithSpriteFrames(tfArr2)
                            tfAnim2:setDelayPerUnit(0.03)
                            local animate = CCAnimate:create(tfAnim2)
                            
                            local repeatForever = CCRepeatForever:create(animate)
                            shipTailFlameSp2:runAction(repeatForever)
                        end
                        local flameVisCall2 = CCCallFunc:create(fireVisibleTrueHandl)
                        local det1 = CCDelayTime:create(isUseInBattle.inT + isUseInBattle.dlT1 + isUseInBattle.dlT2)
                        local battleArr = CCArray:create()
                        battleArr:addObject(flameVisCall)
                        battleArr:addObject(det1)
                        battleArr:addObject(flameVisCall2)
                        local battleSeq = CCSequence:create(battleArr)
                        shipTailFlameSp2:runAction(battleSeq)
                    end
                else
                    local tfArr2 = CCArray:create()
                    for kk = 1, 15 do
                        local nameStr = "arpl_shipFire"..kk..".png"
                        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                        tfArr2:addObject(frame)
                    end
                    local tfAnim2 = CCAnimation:createWithSpriteFrames(tfArr2)
                    tfAnim2:setDelayPerUnit(0.03)
                    local animate = CCAnimate:create(tfAnim2)
                    
                    local repeatForever = CCRepeatForever:create(animate)
                    shipTailFlameSp2:runAction(repeatForever)
                end
                shipTailFlameSp2:setPosition(ccp(311, 182))
                airShipSp:addChild(shipTailFlameSp2, 1)
            elseif airShipId == 6 then
                
                local flickerSp1 = CCSprite:createWithSpriteFrameName("arpl_shipLightFlicker1.png")
                flickerSp1:setScale(0.95)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                flickerSp1:setBlendFunc(blendFunc)
                
                local filickerArr = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_shipLightFlicker"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    filickerArr:addObject(frame)
                end
                local flickerAnim = CCAnimation:createWithSpriteFrames(filickerArr)
                flickerAnim:setDelayPerUnit(0.03)
                local animate = CCAnimate:create(flickerAnim)
                local repeatForever = CCRepeatForever:create(animate)
                flickerSp1:setPosition(ccp(204, 97))
                flickerSp1:runAction(repeatForever)
                airShipSp:addChild(flickerSp1, 5)
                
                local yellowSpikeSp = CCSprite:createWithSpriteFrameName("arpl_ship6_1_yellowSpike.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                yellowSpikeSp:setBlendFunc(blendFunc)
                
                local ysFadeOut = CCFadeTo:create(1, 255 * 0.2)
                local ysFadeIn = CCFadeTo:create(1, 255)
                local ysArr = CCArray:create()
                ysArr:addObject(ysFadeOut)
                ysArr:addObject(ysFadeIn)
                local ysSeq = CCSequence:create(ysArr)
                local ysRepeat = CCRepeatForever:create(ysSeq)
                yellowSpikeSp:runAction(ysRepeat)
                yellowSpikeSp:setPosition(59, 161.5)
                airShipSp:addChild(yellowSpikeSp, 5)
                
                local redLightSp = CCSprite:createWithSpriteFrameName("arpl_ship6_1_redLight1.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                redLightSp:setBlendFunc(blendFunc)
                
                local rlFadeOut = CCFadeTo:create(0.125, 255 * 0.5)
                local rlFadeIn = CCFadeTo:create(0.125, 255)
                local rlFadeOut2 = CCFadeTo:create(0.125, 255 * 0.5)
                local rlFadeIn2 = CCFadeTo:create(0.125, 255)
                local rlFadeOut3 = CCFadeTo:create(0.75, 255 * 0.1)
                local rlFadeIn3 = CCFadeTo:create(0.75, 255)
                local rlArr = CCArray:create()
                rlArr:addObject(rlFadeOut)
                rlArr:addObject(rlFadeIn)
                rlArr:addObject(rlFadeOut2)
                rlArr:addObject(rlFadeIn2)
                rlArr:addObject(rlFadeOut3)
                rlArr:addObject(rlFadeIn3)
                local rlSeq = CCSequence:create(rlArr)
                local rlRepeat = CCRepeatForever:create(rlSeq)
                redLightSp:runAction(rlRepeat)
                redLightSp:setPosition(465, 428)
                airShipSp:addChild(redLightSp, 5)
                
                local redLightSp2 = CCSprite:createWithSpriteFrameName("arpl_ship6_1_redLight2.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                redLightSp2:setBlendFunc(blendFunc)
                
                local rlDet = CCDelayTime:create(1)
                local function detRun()
                    local rl2FadeOut = CCFadeTo:create(0.125, 255 * 0.5)
                    local rl2FadeIn = CCFadeTo:create(0.125, 255)
                    local rl2FadeOut2 = CCFadeTo:create(0.125, 255 * 0.5)
                    local rl2FadeIn2 = CCFadeTo:create(0.125, 255)
                    local rl2FadeOut3 = CCFadeTo:create(0.75, 255 * 0.1)
                    local rl2FadeIn3 = CCFadeTo:create(0.75, 255)
                    local rl2Arr = CCArray:create()
                    rl2Arr:addObject(rl2FadeOut)
                    rl2Arr:addObject(rl2FadeIn)
                    rl2Arr:addObject(rl2FadeOut2)
                    rl2Arr:addObject(rl2FadeIn2)
                    rl2Arr:addObject(rl2FadeOut3)
                    rl2Arr:addObject(rl2FadeIn3)
                    local rl2Seq = CCSequence:create(rl2Arr)
                    local rl2Repeat = CCRepeatForever:create(rl2Seq)
                    redLightSp2:runAction(rl2Repeat)
                end
                local rlCCFun = CCCallFunc:create(detRun)
                local rl22Arr = CCArray:create()
                rl22Arr:addObject(rlDet)
                rl22Arr:addObject(rlCCFun)
                local rl22Seq = CCSequence:create(rl22Arr)
                redLightSp2:runAction(rl22Seq)
                
                redLightSp2:setPosition(486.5, 445)
                airShipSp:addChild(redLightSp2, 5)
                
                local orgLightSp = CCSprite:createWithSpriteFrameName("arpl_ship6_1_orgLight.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                orgLightSp:setBlendFunc(blendFunc)
                
                local olFadeOut = CCFadeTo:create(1, 255 * 0.2)
                local olFadeIn = CCFadeTo:create(1, 255)
                local olArr = CCArray:create()
                olArr:addObject(olFadeOut)
                olArr:addObject(olFadeIn)
                local olSeq = CCSequence:create(olArr)
                local olRepeat = CCRepeatForever:create(olSeq)
                orgLightSp:runAction(olRepeat)
                orgLightSp:setPosition(211, 145)
                airShipSp:addChild(orgLightSp, 5)
                
                local orgBeamSp = CCSprite:createWithSpriteFrameName("arpl_ship6_1_orgBeam.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                orgBeamSp:setBlendFunc(blendFunc)
                
                if isUseInBattle then
                    if isUseInBattle.start then
                        orgBeamSp:setVisible(false)
                        local det = CCDelayTime:create(isUseInBattle.inT)
                        local blink = CCBlink:create(1, 3)
                        local function obSpShowHandl()
                            orgBeamSp:setVisible(true)
                            local obFadeOut = CCFadeTo:create(1, 255 * 0.5)
                            local obFadeIn = CCFadeTo:create(1, 255)
                            local obArr = CCArray:create()
                            obArr:addObject(obFadeOut)
                            obArr:addObject(obFadeIn)
                            local obSeq = CCSequence:create(obArr)
                            local obRepeat = CCRepeatForever:create(obSeq)
                            orgBeamSp:runAction(obRepeat)
                        end
                        local obSpCall = CCCallFunc:create(obSpShowHandl)
                        local obArr = CCArray:create()
                        obArr:addObject(det)
                        obArr:addObject(blink)
                        obArr:addObject(obSpCall)
                        local obSeq = CCSequence:create(obArr)
                        orgBeamSp:runAction(obSeq)
                    end
                else
                    local obFadeOut = CCFadeTo:create(1, 255 * 0.5)
                    local obFadeIn = CCFadeTo:create(1, 255)
                    local obArr = CCArray:create()
                    obArr:addObject(obFadeOut)
                    obArr:addObject(obFadeIn)
                    local obSeq = CCSequence:create(obArr)
                    local obRepeat = CCRepeatForever:create(obSeq)
                    orgBeamSp:runAction(obRepeat)
                end
                orgBeamSp:setPosition(271, 137)
                airShipSp:addChild(orgBeamSp, 5)
                --
                local orgBeamSp2 = CCSprite:createWithSpriteFrameName("arpl_ship6_1_orgBeam.png")
                orgBeamSp2:setRotation(18)
                orgBeamSp2:setFlipX(true)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                orgBeamSp2:setBlendFunc(blendFunc)
                
                if isUseInBattle then
                    if isUseInBattle.start then
                        orgBeamSp2:setVisible(false)
                        local det2 = CCDelayTime:create(isUseInBattle.inT)
                        local blink2 = CCBlink:create(1, 3)
                        local function obSpShowHandl()
                            local ob2FadeOut = CCFadeTo:create(1, 255 * 0.5)
                            local ob2FadeIn = CCFadeTo:create(1, 255)
                            local ob2Arr = CCArray:create()
                            ob2Arr:addObject(ob2FadeOut)
                            ob2Arr:addObject(ob2FadeIn)
                            local ob2Seq = CCSequence:create(ob2Arr)
                            local ob2Repeat = CCRepeatForever:create(ob2Seq)
                            orgBeamSp2:runAction(ob2Repeat)
                        end
                        local obSpCall2 = CCCallFunc:create(obSpShowHandl)
                        local obArr2 = CCArray:create()
                        obArr2:addObject(det2)
                        obArr2:addObject(blink2)
                        obArr2:addObject(obSpCall2)
                        local obSeq2 = CCSequence:create(obArr2)
                        orgBeamSp2:runAction(obSeq2)
                    end
                else
                    local ob2FadeOut = CCFadeTo:create(1, 255 * 0.5)
                    local ob2FadeIn = CCFadeTo:create(1, 255)
                    local ob2Arr = CCArray:create()
                    ob2Arr:addObject(ob2FadeOut)
                    ob2Arr:addObject(ob2FadeIn)
                    local ob2Seq = CCSequence:create(ob2Arr)
                    local ob2Repeat = CCRepeatForever:create(ob2Seq)
                    orgBeamSp2:runAction(ob2Repeat)
                end
                
                orgBeamSp2:setPosition(195, 164.5)
                airShipSp:addChild(orgBeamSp2, 1)
                
                local shipTailSmokeSp2 = CCSprite:createWithSpriteFrameName("arpl_shipSmoke1.png")
                shipTailSmokeSp2:setScale(0.9)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                shipTailSmokeSp2:setBlendFunc(blendFunc)
                
                local tmArr2 = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_shipSmoke"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    tmArr2:addObject(frame)
                end
                local tmAnim2 = CCAnimation:createWithSpriteFrames(tmArr2)
                tmAnim2:setDelayPerUnit(0.03)
                local animate = CCAnimate:create(tmAnim2)
                local repeatForever = CCRepeatForever:create(animate)
                shipTailSmokeSp2:setPosition(ccp(310, 194))
                shipTailSmokeSp2:runAction(repeatForever)
                airShipSp:addChild(shipTailSmokeSp2, 1)
                
                local shipTailFlameSp2 = CCSprite:createWithSpriteFrameName("arpl_shipFire1.png")
                shipTailFlameSp2:setScale(0.9)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                shipTailFlameSp2:setBlendFunc(blendFunc)
                
                if isUseInBattle then
                    if isUseInBattle.start then
                        local function fireVisibleFalseHandl() shipTailFlameSp2:setVisible(false) end
                        local flameVisCall = CCCallFunc:create(fireVisibleFalseHandl)
                        local function fireVisibleTrueHandl()
                            shipTailFlameSp2:setVisible(true)
                            
                            local tfArr2 = CCArray:create()
                            for kk = 1, 15 do
                                local nameStr = "arpl_shipFire"..kk..".png"
                                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                                tfArr2:addObject(frame)
                            end
                            local tfAnim2 = CCAnimation:createWithSpriteFrames(tfArr2)
                            tfAnim2:setDelayPerUnit(0.03)
                            local animate = CCAnimate:create(tfAnim2)
                            
                            local repeatForever = CCRepeatForever:create(animate)
                            shipTailFlameSp2:runAction(repeatForever)
                        end
                        local flameVisCall2 = CCCallFunc:create(fireVisibleTrueHandl)
                        local det1 = CCDelayTime:create(isUseInBattle.inT + isUseInBattle.dlT1 + isUseInBattle.dlT2)
                        local battleArr = CCArray:create()
                        battleArr:addObject(flameVisCall)
                        battleArr:addObject(det1)
                        battleArr:addObject(flameVisCall2)
                        local battleSeq = CCSequence:create(battleArr)
                        shipTailFlameSp2:runAction(battleSeq)
                    end
                else
                    local tfArr2 = CCArray:create()
                    for kk = 1, 15 do
                        local nameStr = "arpl_shipFire"..kk..".png"
                        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                        tfArr2:addObject(frame)
                    end
                    local tfAnim2 = CCAnimation:createWithSpriteFrames(tfArr2)
                    tfAnim2:setDelayPerUnit(0.03)
                    local animate = CCAnimate:create(tfAnim2)
                    
                    local repeatForever = CCRepeatForever:create(animate)
                    shipTailFlameSp2:runAction(repeatForever)
                end
                shipTailFlameSp2:setPosition(ccp(310, 194))
                airShipSp:addChild(shipTailFlameSp2, 1)
            elseif airShipId == 7 then
                
                local spkesYellowSp = CCSprite:createWithSpriteFrameName("arpl_ship7_1_spikesYellowLight.png")
                spkesYellowSp:setOpacity(255 * 0.4)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                spkesYellowSp:setBlendFunc(blendFunc)
                
                local syFadeOut = CCFadeTo:create(1, 255)
                local syFadeIn = CCFadeTo:create(1, 255 * 0.4)
                local syArr = CCArray:create()
                syArr:addObject(syFadeOut)
                syArr:addObject(syFadeIn)
                local sySeq = CCSequence:create(syArr)
                local syRepeat = CCRepeatForever:create(sySeq)
                spkesYellowSp:runAction(syRepeat)
                spkesYellowSp:setPosition(173, 147.1)
                airShipSp:addChild(spkesYellowSp, 5)
                
                local spkesYellowSp2 = CCSprite:createWithSpriteFrameName("arpl_ship7_1_spikesYellowLight.png")
                spkesYellowSp2:setScale(0.95)
                spkesYellowSp2:setOpacity(255 * 0.4)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                spkesYellowSp2:setBlendFunc(blendFunc)
                
                local sy2FadeOut = CCFadeTo:create(1, 255)
                local sy2FadeIn = CCFadeTo:create(1, 255 * 0.4)
                local sy2Arr = CCArray:create()
                sy2Arr:addObject(sy2FadeOut)
                sy2Arr:addObject(sy2FadeIn)
                local sy2Seq = CCSequence:create(sy2Arr)
                local sy2Repeat = CCRepeatForever:create(sy2Seq)
                spkesYellowSp2:runAction(sy2Repeat)
                spkesYellowSp2:setPosition(29, 218.6)
                airShipSp:addChild(spkesYellowSp2, 5)
                
                local tailLightSp = CCSprite:createWithSpriteFrameName("arpl_ship7_1_tailLightyellow.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                tailLightSp:setBlendFunc(blendFunc)
                
                local tlFadeOut = CCFadeTo:create(1, 255 * 0.3)
                local tlFadeIn = CCFadeTo:create(1, 255)
                local tlArr = CCArray:create()
                tlArr:addObject(tlFadeOut)
                tlArr:addObject(tlFadeIn)
                local tlSeq = CCSequence:create(tlArr)
                local tlRepeat = CCRepeatForever:create(tlSeq)
                tailLightSp:runAction(tlRepeat)
                tailLightSp:setPosition(487.5, 416.5)
                airShipSp:addChild(tailLightSp, 5)
                --arpl_ship7_1_blueLight
                local blueLightSp = CCSprite:createWithSpriteFrameName("arpl_ship7_1_blueLight.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                blueLightSp:setBlendFunc(blendFunc)
                
                local blFadeOut = CCFadeTo:create(1, 255 * 0.3)
                local blFadeIn = CCFadeTo:create(1, 255)
                local blArr = CCArray:create()
                blArr:addObject(blFadeOut)
                blArr:addObject(blFadeIn)
                local blSeq = CCSequence:create(blArr)
                local blRepeat = CCRepeatForever:create(blSeq)
                blueLightSp:runAction(blRepeat)
                blueLightSp:setPosition(326, 139)
                airShipSp:addChild(blueLightSp, 5)
                
                local smokeSp = CCSprite:createWithSpriteFrameName("arpl_ship7_1_smoke1.png")
                local skArr = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_ship7_1_smoke"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    skArr:addObject(frame)
                end
                local skAnim = CCAnimation:createWithSpriteFrames(skArr)
                skAnim:setDelayPerUnit(0.03)
                local animate = CCAnimate:create(skAnim)
                local repeatForever = CCRepeatForever:create(animate)
                smokeSp:setPosition(ccp(282, 440))
                smokeSp:runAction(repeatForever)
                airShipSp:addChild(smokeSp, 5)
                
                if isUseInBattle then
                    if isUseInBattle.start then
                        smokeSp:setOpacity(130)
                        
                        local det = CCDelayTime:create(isUseInBattle.inT)
                        local fadeIn = CCFadeTo:create(isUseInBattle.dlT1, 255)
                        local sArr = CCArray:create()
                        sArr:addObject(det)
                        sArr:addObject(fadeIn)
                        local sSeq = CCSequence:create(sArr)
                        smokeSp:runAction(sSeq)
                    end
                end
                
                local smokeSp2 = CCSprite:createWithSpriteFrameName("arpl_ship7_1_smoke1.png")
                smokeSp2:setScale(0.6)
                local skArr2 = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_ship7_1_smoke"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    skArr2:addObject(frame)
                end
                local skAnim2 = CCAnimation:createWithSpriteFrames(skArr2)
                skAnim2:setDelayPerUnit(0.03)
                local animate2 = CCAnimate:create(skAnim2)
                local repeatForever2 = CCRepeatForever:create(animate2)
                smokeSp2:setPosition(ccp(385, 410))
                smokeSp2:runAction(repeatForever2)
                airShipSp:addChild(smokeSp2, 5)
                
                if isUseInBattle then
                    if isUseInBattle.start then
                        smokeSp2:setOpacity(130)
                        
                        local det = CCDelayTime:create(isUseInBattle.inT)
                        local fadeIn = CCFadeTo:create(isUseInBattle.dlT1, 255)
                        local sArr = CCArray:create()
                        sArr:addObject(det)
                        sArr:addObject(fadeIn)
                        local sSeq = CCSequence:create(sArr)
                        smokeSp2:runAction(sSeq)
                    end
                end
                ---
                local bridgeOrgSp = CCSprite:createWithSpriteFrameName("arpl_ship7_1_bridgeOrgLight1.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                bridgeOrgSp:setBlendFunc(blendFunc)
                
                local boFadeOut = CCFadeTo:create(1, 255 * 0.2)
                local boFadeIn = CCFadeTo:create(1, 255)
                local boArr = CCArray:create()
                boArr:addObject(boFadeOut)
                boArr:addObject(boFadeIn)
                local boSeq = CCSequence:create(boArr)
                local boRepeat = CCRepeatForever:create(boSeq)
                bridgeOrgSp:runAction(boRepeat)
                bridgeOrgSp:setPosition(214, 261)
                airShipSp:addChild(bridgeOrgSp, 5)
                
                local bridgeOrgSp2 = CCSprite:createWithSpriteFrameName("arpl_ship7_1_bridgeOrgLight2.png")
                bridgeOrgSp2:setOpacity(255 * 0.4)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                bridgeOrgSp2:setBlendFunc(blendFunc)
                
                local bo2FadeOut = CCFadeTo:create(1, 255)
                local bo2FadeIn = CCFadeTo:create(1, 255 * 0.4)
                local bo2Arr = CCArray:create()
                bo2Arr:addObject(bo2FadeOut)
                bo2Arr:addObject(bo2FadeIn)
                local bo2Seq = CCSequence:create(bo2Arr)
                local bo2Repeat = CCRepeatForever:create(bo2Seq)
                bridgeOrgSp2:runAction(bo2Repeat)
                bridgeOrgSp2:setPosition(220.5, 256)
                airShipSp:addChild(bridgeOrgSp2, 5)
                --------1111111111
                local topOrgLightSp = CCSprite:createWithSpriteFrameName("arpl_ship7_1_ConesTopOrgLight.png")
                topOrgLightSp:setOpacity(0)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                topOrgLightSp:setBlendFunc(blendFunc)
                
                local tolFadeOut = CCFadeTo:create(1, 255)
                local tolFadeIn = CCFadeTo:create(1, 0)
                local tolDet = CCDelayTime:create(0.4)
                local tolArr = CCArray:create()
                tolArr:addObject(tolFadeOut)
                tolArr:addObject(tolFadeIn)
                tolArr:addObject(tolDet)
                local tolSeq = CCSequence:create(tolArr)
                local tolRepeat = CCRepeatForever:create(tolSeq)
                topOrgLightSp:runAction(tolRepeat)
                topOrgLightSp:setPosition(295.2, 140)
                airShipSp:addChild(topOrgLightSp, 5)
                
                local orgLightSp2 = CCSprite:createWithSpriteFrameName("arpl_ship7_1_coonesOrgLight.png")
                orgLightSp2:setOpacity(0)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                orgLightSp2:setBlendFunc(blendFunc)
                
                local function runFadeHandl()
                    local tol2FadeOut = CCFadeTo:create(1, 255)
                    local tol2FadeIn = CCFadeTo:create(1, 0)
                    local tolDet2 = CCDelayTime:create(0.4)
                    local tol2Arr = CCArray:create()
                    tol2Arr:addObject(tol2FadeOut)
                    tol2Arr:addObject(tol2FadeIn)
                    tol2Arr:addObject(tolDet2)
                    local tol2Seq = CCSequence:create(tol2Arr)
                    local tol2Repeat = CCRepeatForever:create(tol2Seq)
                    orgLightSp2:runAction(tol2Repeat)
                end
                local fadeCall = CCCallFunc:create(runFadeHandl)
                local tol2Det = CCDelayTime:create(0.67)
                local tol2beginArr = CCArray:create()
                tol2beginArr:addObject(tol2Det)
                tol2beginArr:addObject(fadeCall)
                local tol2beginSeq = CCSequence:create(tol2beginArr)
                orgLightSp2:runAction(tol2beginSeq)
                
                orgLightSp2:setPosition(293, 129)
                airShipSp:addChild(orgLightSp2, 5)
                
                local orgLightSp3 = CCSprite:createWithSpriteFrameName("arpl_ship7_1_coonesOrgLight.png")
                orgLightSp3:setOpacity(0)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                orgLightSp3:setBlendFunc(blendFunc)
                
                local function runFadeHandl3()
                    local tol3FadeOut = CCFadeTo:create(1, 255)
                    local tol3FadeIn = CCFadeTo:create(1, 0)
                    local tolDet3 = CCDelayTime:create(0.4)
                    local tol3Arr = CCArray:create()
                    tol3Arr:addObject(tol3FadeOut)
                    tol3Arr:addObject(tol3FadeIn)
                    tol3Arr:addObject(tolDet3)
                    local tol3Seq = CCSequence:create(tol3Arr)
                    local tol3Repeat = CCRepeatForever:create(tol3Seq)
                    orgLightSp3:runAction(tol3Repeat)
                end
                local fadeCall3 = CCCallFunc:create(runFadeHandl3)
                local tol3Det3 = CCDelayTime:create(1.34)
                local tol3beginArr3 = CCArray:create()
                tol3beginArr3:addObject(tol3Det3)
                tol3beginArr3:addObject(fadeCall3)
                local tol3beginSeq3 = CCSequence:create(tol3beginArr3)
                orgLightSp3:runAction(tol3beginSeq3)
                
                orgLightSp3:setPosition(295.2, 111)
                airShipSp:addChild(orgLightSp3, 5)
                --------222222222
                local topOrgLightSp2 = CCSprite:createWithSpriteFrameName("arpl_ship7_1_ConesTopOrgLight.png")
                topOrgLightSp2:setOpacity(0)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                topOrgLightSp2:setBlendFunc(blendFunc)
                
                local tol2FadeOut = CCFadeTo:create(1, 255)
                local tol2FadeIn = CCFadeTo:create(1, 0)
                local tol2Det = CCDelayTime:create(0.4)
                local tol2Arr = CCArray:create()
                tol2Arr:addObject(tol2FadeOut)
                tol2Arr:addObject(tol2FadeIn)
                tol2Arr:addObject(tol2Det)
                local tol2Seq = CCSequence:create(tol2Arr)
                local tol2Repeat = CCRepeatForever:create(tol2Seq)
                topOrgLightSp2:runAction(tol2Repeat)
                topOrgLightSp2:setPosition(150.2, 213)
                airShipSp:addChild(topOrgLightSp2, 5)
                
                local orgLightSp22 = CCSprite:createWithSpriteFrameName("arpl_ship7_1_coonesOrgLight.png")
                orgLightSp22:setOpacity(0)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                orgLightSp22:setBlendFunc(blendFunc)
                
                local function runFadeHandl2()
                    local tol22FadeOut = CCFadeTo:create(1, 255)
                    local tol22FadeIn = CCFadeTo:create(1, 0)
                    local tolDet22 = CCDelayTime:create(0.4)
                    local tol22Arr = CCArray:create()
                    tol22Arr:addObject(tol22FadeOut)
                    tol22Arr:addObject(tol22FadeIn)
                    tol22Arr:addObject(tolDet22)
                    local tol22Seq = CCSequence:create(tol22Arr)
                    local tol22Repeat = CCRepeatForever:create(tol22Seq)
                    orgLightSp22:runAction(tol22Repeat)
                end
                local fadeCall = CCCallFunc:create(runFadeHandl2)
                local tol22Det = CCDelayTime:create(0.67)
                local tol22beginArr = CCArray:create()
                tol22beginArr:addObject(tol22Det)
                tol22beginArr:addObject(fadeCall)
                local tol22beginSeq = CCSequence:create(tol22beginArr)
                orgLightSp22:runAction(tol22beginSeq)
                
                orgLightSp22:setPosition(148, 201.7)
                airShipSp:addChild(orgLightSp22, 5)
                
                local orgLightSp33 = CCSprite:createWithSpriteFrameName("arpl_ship7_1_coonesOrgLight.png")
                orgLightSp33:setOpacity(0)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                orgLightSp33:setBlendFunc(blendFunc)
                
                local function runFadeHandl3()
                    local tol33FadeOut = CCFadeTo:create(1, 255)
                    local tol33FadeIn = CCFadeTo:create(1, 0)
                    local tolDet33 = CCDelayTime:create(0.4)
                    local tol33Arr = CCArray:create()
                    tol33Arr:addObject(tol33FadeOut)
                    tol33Arr:addObject(tol33FadeIn)
                    tol33Arr:addObject(tolDet33)
                    local tol33Seq = CCSequence:create(tol33Arr)
                    local tol33Repeat = CCRepeatForever:create(tol33Seq)
                    orgLightSp33:runAction(tol33Repeat)
                end
                local fadeCall3 = CCCallFunc:create(runFadeHandl3)
                local tol33Det3 = CCDelayTime:create(1.34)
                local tol33beginArr3 = CCArray:create()
                tol33beginArr3:addObject(tol33Det3)
                tol33beginArr3:addObject(fadeCall3)
                local tol33beginSeq3 = CCSequence:create(tol33beginArr3)
                orgLightSp33:runAction(tol33beginSeq3)
                
                orgLightSp33:setPosition(150.2, 184)
                airShipSp:addChild(orgLightSp33, 5)
            end
        end
    else
        local propellerNum = airShipId == 7 and airShipId or 8
        
        local pzArr = CCArray:create()
        if airShipId == 6 or airShipId == 7 then
            for kk = 1, propellerNum do
                local nameStr = "arpl_ship"..airShipId.."_"..pIdx.."_propeller"..kk..".png"
                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                pzArr:addObject(frame)
            end
        else
            for kk = 1, propellerNum do
                local nameStr = "arpl_shipUniversalRopeller"..pIdx.."_"..kk..".png"
                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                pzArr:addObject(frame)
            end
        end
        local animation = CCAnimation:createWithSpriteFrames(pzArr)
        animation:setDelayPerUnit(0.08)
        local animate = CCAnimate:create(animation)
        local repeatAnimt = CCRepeatForever:create(animate)
        defutAddPic:runAction(repeatAnimt)
        
        ----无运输艇动画，如果需要自行添加
        if airShipId < 5 then
            if airShipId == 2 then
                local blueLight1Sp = CCSprite:createWithSpriteFrameName("arpl_ship2_1_bluelight.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                blueLight1Sp:setBlendFunc(blendFunc)
                
                local blFadeOut = CCFadeTo:create(1, 255 * 0.4)
                local blFadeIn = CCFadeTo:create(1, 255)
                local blArr = CCArray:create()
                blArr:addObject(blFadeOut)
                blArr:addObject(blFadeIn)
                local blSeq = CCSequence:create(blArr)
                local blRepeat = CCRepeatForever:create(blSeq)
                blueLight1Sp:runAction(blRepeat)
                blueLight1Sp:setPosition(460.5, 239)
                airShipSp:addChild(blueLight1Sp, 4)
                
                local blueLight2Sp = CCSprite:createWithSpriteFrameName("arpl_ship2_1_bluelight.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                blueLight2Sp:setBlendFunc(blendFunc)
                
                local bl2FadeOut = CCFadeTo:create(1, 255 * 0.4)
                local bl2FadeIn = CCFadeTo:create(1, 255)
                local bl2Arr = CCArray:create()
                bl2Arr:addObject(bl2FadeOut)
                bl2Arr:addObject(bl2FadeIn)
                local bl2Seq = CCSequence:create(bl2Arr)
                local bl2Repeat = CCRepeatForever:create(bl2Seq)
                blueLight2Sp:runAction(bl2Repeat)
                blueLight2Sp:setPosition(423, 221)
                airShipSp:addChild(blueLight2Sp, 4)
                
                ---
                local org1Sp = CCSprite:createWithSpriteFrameName("arpl_ship2_2_org1.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                org1Sp:setBlendFunc(blendFunc)
                
                if isUseInBattle then
                    if isUseInBattle.start then
                        org1Sp:setVisible(false)
                        local bDet1 = CCDelayTime:create(isUseInBattle.inT)
                        local function org1VisibleTrueCall()
                            org1Sp:setVisible(true)
                            
                            local org1FadeOut = CCFadeTo:create(1, 255 * 0.2)
                            local org1FadeIn = CCFadeTo:create(1, 255)
                            local org1Det = CCDelayTime:create(1.32 * G_battleSpeed)
                            local org1Arr = CCArray:create()
                            org1Arr:addObject(org1FadeOut)
                            org1Arr:addObject(org1FadeIn)
                            org1Arr:addObject(org1Det)
                            local org1Seq = CCSequence:create(org1Arr)
                            local org1Repeat = CCRepeatForever:create(org1Seq)
                            org1Sp:runAction(org1Repeat)
                        end
                        local org1VisCall = CCCallFunc:create(org1VisibleTrueCall)
                        local bArr = CCArray:create()
                        bArr:addObject(bDet1)
                        bArr:addObject(org1VisCall)
                        -- bArr:addObject(org1Repeat)
                        local bSeq = CCSequence:create(bArr)
                        org1Sp:runAction(bSeq)
                    end
                else
                    local org1FadeOut = CCFadeTo:create(1, 255 * 0.2)
                    local org1FadeIn = CCFadeTo:create(1, 255)
                    local org1Det = CCDelayTime:create(1.32)
                    local org1Arr = CCArray:create()
                    org1Arr:addObject(org1FadeOut)
                    org1Arr:addObject(org1FadeIn)
                    org1Arr:addObject(org1Det)
                    local org1Seq = CCSequence:create(org1Arr)
                    local org1Repeat = CCRepeatForever:create(org1Seq)
                    
                    org1Sp:runAction(org1Repeat)
                end
                org1Sp:setPosition(366, 187)
                airShipSp:addChild(org1Sp, 5)
                
                local org2Sp = CCSprite:createWithSpriteFrameName("arpl_ship2_2_org2.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                org2Sp:setBlendFunc(blendFunc)
                
                if isUseInBattle then
                    if isUseInBattle.start then
                        org2Sp:setVisible(false)
                        local bDet1 = CCDelayTime:create(isUseInBattle.inT)
                        local function org2VisibleTrueCall()
                            org2Sp:setVisible(true)
                            
                            local org2Det1 = CCDelayTime:create(0.66 * G_battleSpeed)
                            local org2FadeOut = CCFadeTo:create(1, 255 * 0.2)
                            local org2FadeIn = CCFadeTo:create(1, 255)
                            local org2Det2 = CCDelayTime:create(0.66 * G_battleSpeed)
                            local org2Arr = CCArray:create()
                            org2Arr:addObject(org2Det1)
                            org2Arr:addObject(org2FadeOut)
                            org2Arr:addObject(org2FadeIn)
                            org2Arr:addObject(org2Det2)
                            local org2Seq = CCSequence:create(org2Arr)
                            local org2Repeat = CCRepeatForever:create(org2Seq)
                            org2Sp:runAction(org2Repeat)
                        end
                        local org2VisCall = CCCallFunc:create(org2VisibleTrueCall)
                        local bArr = CCArray:create()
                        bArr:addObject(bDet1)
                        bArr:addObject(org2VisCall)
                        local bSeq = CCSequence:create(bArr)
                        org2Sp:runAction(bSeq)
                    end
                else
                    local org2Det1 = CCDelayTime:create(0.66)
                    local org2FadeOut = CCFadeTo:create(1, 255 * 0.2)
                    local org2FadeIn = CCFadeTo:create(1, 255)
                    local org2Det2 = CCDelayTime:create(0.66)
                    local org2Arr = CCArray:create()
                    org2Arr:addObject(org2Det1)
                    org2Arr:addObject(org2FadeOut)
                    org2Arr:addObject(org2FadeIn)
                    org2Arr:addObject(org2Det2)
                    local org2Seq = CCSequence:create(org2Arr)
                    local org2Repeat = CCRepeatForever:create(org2Seq)
                    
                    org2Sp:runAction(org2Repeat)
                end
                org2Sp:setPosition(387, 195)
                airShipSp:addChild(org2Sp, 5)
                
                local org3Sp = CCSprite:createWithSpriteFrameName("arpl_ship2_2_org3.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                org3Sp:setBlendFunc(blendFunc)
                
                if isUseInBattle then
                    if isUseInBattle.start then
                        org3Sp:setVisible(false)
                        local bDet1 = CCDelayTime:create(isUseInBattle.inT)
                        local function org3VisibleTrueCall()
                            org3Sp:setVisible(true)
                            
                            local org3Det = CCDelayTime:create(1.32)
                            local org3FadeOut = CCFadeTo:create(1, 255 * 0.2)
                            local org3FadeIn = CCFadeTo:create(1, 255)
                            local org3Arr = CCArray:create()
                            org3Arr:addObject(org3Det)
                            org3Arr:addObject(org3FadeOut)
                            org3Arr:addObject(org3FadeIn)
                            
                            local org3Seq = CCSequence:create(org3Arr)
                            local org3Repeat = CCRepeatForever:create(org3Seq)
                            org3Sp:runAction(org3Repeat)
                        end
                        local org3VisCall = CCCallFunc:create(org3VisibleTrueCall)
                        local bArr = CCArray:create()
                        bArr:addObject(bDet1)
                        bArr:addObject(org3VisCall)
                        local bSeq = CCSequence:create(bArr)
                        org3Sp:runAction(bSeq)
                    end
                else
                    local org3Det = CCDelayTime:create(1.32)
                    local org3FadeOut = CCFadeTo:create(1, 255 * 0.2)
                    local org3FadeIn = CCFadeTo:create(1, 255)
                    local org3Arr = CCArray:create()
                    org3Arr:addObject(org3Det)
                    org3Arr:addObject(org3FadeOut)
                    org3Arr:addObject(org3FadeIn)
                    
                    local org3Seq = CCSequence:create(org3Arr)
                    local org3Repeat = CCRepeatForever:create(org3Seq)
                    
                    org3Sp:runAction(org3Repeat)
                end
                org3Sp:setPosition(406, 205)
                airShipSp:addChild(org3Sp, 5)
                
                local tailOrgSp = CCSprite:createWithSpriteFrameName("arpl_shipTailOrgLight.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                tailOrgSp:setBlendFunc(blendFunc)
                
                local tailOrgFadeOut = CCFadeTo:create(0.5, 255 * 0.5)
                local tailOrgFadeIn = CCFadeTo:create(1.5, 255)
                local tailOrgArr = CCArray:create()
                tailOrgArr:addObject(tailOrgFadeOut)
                tailOrgArr:addObject(tailOrgFadeIn)
                
                local tailOrgSeq = CCSequence:create(tailOrgArr)
                local tailOrgRepeat = CCRepeatForever:create(tailOrgSeq)
                tailOrgSp:runAction(tailOrgRepeat)
                tailOrgSp:setPosition(109, 192)
                airShipSp:addChild(tailOrgSp, 5)
                
                local shipTailSmokeSp = CCSprite:createWithSpriteFrameName("arpl_shipSmoke1.png")
                shipTailSmokeSp:setFlipX(true)
                shipTailSmokeSp:setRotation(-50)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                shipTailSmokeSp:setBlendFunc(blendFunc)
                
                local tmArr = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_shipSmoke"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    tmArr:addObject(frame)
                end
                local tmAnim = CCAnimation:createWithSpriteFrames(tmArr)
                tmAnim:setDelayPerUnit(0.05)
                local animate = CCAnimate:create(tmAnim)
                local repeatForever = CCRepeatForever:create(animate)
                shipTailSmokeSp:setPosition(ccp(299, 181))
                shipTailSmokeSp:runAction(repeatForever)
                airShipSp:addChild(shipTailSmokeSp, 5)
                
                local shipTailFlameSp = CCSprite:createWithSpriteFrameName("arpl_shipFire1.png")
                shipTailFlameSp:setFlipX(true)
                shipTailFlameSp:setRotation(-50)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                shipTailFlameSp:setBlendFunc(blendFunc)
                
                local tfArr = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_shipFire"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    tfArr:addObject(frame)
                end
                local tfAnim = CCAnimation:createWithSpriteFrames(tfArr)
                tfAnim:setDelayPerUnit(0.05)
                local animate = CCAnimate:create(tfAnim)
                if isUseInBattle then
                    if isUseInBattle.start then
                        local function fireVisibleFalseHandl() shipTailFlameSp:setVisible(false) end
                        local flameVisCall = CCCallFunc:create(fireVisibleFalseHandl)
                        local function fireVisibleTrueHandl() shipTailFlameSp:setVisible(true) end
                        local flameVisCall2 = CCCallFunc:create(fireVisibleTrueHandl)
                        local det1 = CCDelayTime:create(isUseInBattle.inT + isUseInBattle.dlT1 + isUseInBattle.dlT2)
                        local battleArr = CCArray:create()
                        battleArr:addObject(flameVisCall)
                        battleArr:addObject(det1)
                        battleArr:addObject(flameVisCall2)
                        local repeatForever = CCRepeatForever:create(animate)
                        battleArr:addObject(repeatForever)
                        local battleSeq = CCSequence:create(battleArr)
                        shipTailFlameSp:runAction(battleSeq)
                    end
                else
                    local repeatForever = CCRepeatForever:create(animate)
                    shipTailFlameSp:runAction(repeatForever)
                end
                shipTailFlameSp:setPosition(ccp(299, 181))
                airShipSp:addChild(shipTailFlameSp, 5)
                
                local flickerSp = CCSprite:createWithSpriteFrameName("arpl_shipLightFlicker1.png")
                flickerSp:setFlipX(true)
                flickerSp:setRotation(-50)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                flickerSp:setBlendFunc(blendFunc)
                
                local filickerArr = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_shipLightFlicker"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    filickerArr:addObject(frame)
                end
                local flickerAnim = CCAnimation:createWithSpriteFrames(filickerArr)
                flickerAnim:setDelayPerUnit(0.05)
                local animate = CCAnimate:create(flickerAnim)
                local repeatForever = CCRepeatForever:create(animate)
                flickerSp:setPosition(ccp(462, 243))
                flickerSp:runAction(repeatForever)
                airShipSp:addChild(flickerSp, 2)
                
                local lightOrgSp = CCSprite:createWithSpriteFrameName("arpl_ship2_1_lightOrg.png")
                lightOrgSp:setFlipX(true)
                lightOrgSp:setRotation(-50)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                lightOrgSp:setBlendFunc(blendFunc)
                
                lightOrgSp:setPosition(470, 263)
                airShipSp:addChild(lightOrgSp, 2)
            elseif airShipId == 3 then
                
                local tailOrgSp = CCSprite:createWithSpriteFrameName("arpl_shipTailOrgLight.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                tailOrgSp:setBlendFunc(blendFunc)
                
                local tailOrgFadeOut = CCFadeTo:create(0.5, 255 * 0.5)
                local tailOrgFadeIn = CCFadeTo:create(1.5, 255)
                local tailOrgArr = CCArray:create()
                tailOrgArr:addObject(tailOrgFadeOut)
                tailOrgArr:addObject(tailOrgFadeIn)
                
                local tailOrgSeq = CCSequence:create(tailOrgArr)
                local tailOrgRepeat = CCRepeatForever:create(tailOrgSeq)
                tailOrgSp:runAction(tailOrgRepeat)
                tailOrgSp:setPosition(109, 192)
                airShipSp:addChild(tailOrgSp, 5)
                
                local shipTailSmokeSp = CCSprite:createWithSpriteFrameName("arpl_shipSmoke1.png")
                shipTailSmokeSp:setFlipX(true)
                shipTailSmokeSp:setRotation(-50)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                shipTailSmokeSp:setBlendFunc(blendFunc)
                
                local tmArr = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_shipSmoke"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    tmArr:addObject(frame)
                end
                local tmAnim = CCAnimation:createWithSpriteFrames(tmArr)
                tmAnim:setDelayPerUnit(0.05)
                local animate = CCAnimate:create(tmAnim)
                local repeatForever = CCRepeatForever:create(animate)
                shipTailSmokeSp:setPosition(ccp(259, 175))
                shipTailSmokeSp:runAction(repeatForever)
                airShipSp:addChild(shipTailSmokeSp, 5)
                
                local shipTailFlameSp = CCSprite:createWithSpriteFrameName("arpl_shipFire1.png")
                shipTailFlameSp:setFlipX(true)
                shipTailFlameSp:setRotation(-50)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                shipTailFlameSp:setBlendFunc(blendFunc)
                
                if isUseInBattle then
                    if isUseInBattle.start then
                        local function fireVisibleFalseHandl() shipTailFlameSp:setVisible(false) end
                        local flameVisCall = CCCallFunc:create(fireVisibleFalseHandl)
                        local function fireVisibleTrueHandl()
                            shipTailFlameSp:setVisible(true)
                            
                            local tfArr = CCArray:create()
                            for kk = 1, 15 do
                                local nameStr = "arpl_shipFire"..kk..".png"
                                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                                tfArr:addObject(frame)
                            end
                            local tfAnim = CCAnimation:createWithSpriteFrames(tfArr)
                            tfAnim:setDelayPerUnit(0.05)
                            local animate = CCAnimate:create(tfAnim)
                            
                            local repeatForever = CCRepeatForever:create(animate)
                            shipTailFlameSp:runAction(repeatForever)
                        end
                        local flameVisCall2 = CCCallFunc:create(fireVisibleTrueHandl)
                        local det1 = CCDelayTime:create(isUseInBattle.inT + isUseInBattle.dlT1 + isUseInBattle.dlT2)
                        local battleArr = CCArray:create()
                        battleArr:addObject(flameVisCall)
                        battleArr:addObject(det1)
                        battleArr:addObject(flameVisCall2)
                        local battleSeq = CCSequence:create(battleArr)
                        shipTailFlameSp:runAction(battleSeq)
                    end
                else
                    local tfArr = CCArray:create()
                    for kk = 1, 15 do
                        local nameStr = "arpl_shipFire"..kk..".png"
                        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                        tfArr:addObject(frame)
                    end
                    local tfAnim = CCAnimation:createWithSpriteFrames(tfArr)
                    tfAnim:setDelayPerUnit(0.05)
                    local animate = CCAnimate:create(tfAnim)
                    
                    local repeatForever = CCRepeatForever:create(animate)
                    shipTailFlameSp:runAction(repeatForever)
                end
                
                shipTailFlameSp:setPosition(ccp(259, 175))
                airShipSp:addChild(shipTailFlameSp, 5)
                
                local shipTailSmokeSp2 = CCSprite:createWithSpriteFrameName("arpl_shipSmoke1.png")
                shipTailSmokeSp2:setFlipX(true)
                shipTailSmokeSp2:setRotation(-50)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                shipTailSmokeSp2:setBlendFunc(blendFunc)
                
                local tmArr2 = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_shipSmoke"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    tmArr2:addObject(frame)
                end
                local tmAnim2 = CCAnimation:createWithSpriteFrames(tmArr2)
                tmAnim2:setDelayPerUnit(0.05)
                local animate2 = CCAnimate:create(tmAnim2)
                local repeatForever = CCRepeatForever:create(animate2)
                shipTailSmokeSp2:setPosition(ccp(295, 156))
                shipTailSmokeSp2:runAction(repeatForever)
                airShipSp:addChild(shipTailSmokeSp2, 5)
                
                local shipTailFlameSp2 = CCSprite:createWithSpriteFrameName("arpl_shipFire1.png")
                shipTailFlameSp2:setFlipX(true)
                shipTailFlameSp2:setRotation(-50)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                shipTailFlameSp2:setBlendFunc(blendFunc)
                
                if isUseInBattle then
                    if isUseInBattle.start then
                        local function fireVisibleFalseHandl() shipTailFlameSp2:setVisible(false) end
                        local flameVisCall = CCCallFunc:create(fireVisibleFalseHandl)
                        local function fireVisibleTrueHandl()
                            shipTailFlameSp2:setVisible(true)
                            
                            local tfArr2 = CCArray:create()
                            for kk = 1, 15 do
                                local nameStr = "arpl_shipFire"..kk..".png"
                                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                                tfArr2:addObject(frame)
                            end
                            local tfAnim2 = CCAnimation:createWithSpriteFrames(tfArr2)
                            tfAnim2:setDelayPerUnit(0.05)
                            local animate2 = CCAnimate:create(tfAnim2)
                            local repeatForever = CCRepeatForever:create(animate2)
                            shipTailFlameSp2:runAction(repeatForever)
                        end
                        local flameVisCall2 = CCCallFunc:create(fireVisibleTrueHandl)
                        local det1 = CCDelayTime:create(isUseInBattle.inT + isUseInBattle.dlT1 + isUseInBattle.dlT2)
                        local battleArr = CCArray:create()
                        battleArr:addObject(flameVisCall)
                        battleArr:addObject(det1)
                        battleArr:addObject(flameVisCall2)
                        local battleSeq = CCSequence:create(battleArr)
                        shipTailFlameSp2:runAction(battleSeq)
                    end
                else
                    local tfArr2 = CCArray:create()
                    for kk = 1, 15 do
                        local nameStr = "arpl_shipFire"..kk..".png"
                        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                        tfArr2:addObject(frame)
                    end
                    local tfAnim2 = CCAnimation:createWithSpriteFrames(tfArr2)
                    tfAnim2:setDelayPerUnit(0.05)
                    local animate2 = CCAnimate:create(tfAnim2)
                    local repeatForever = CCRepeatForever:create(animate2)
                    shipTailFlameSp2:runAction(repeatForever)
                end
                
                shipTailFlameSp2:setPosition(ccp(295, 156))
                airShipSp:addChild(shipTailFlameSp2, 5)
                
                local orgLight1 = CCSprite:createWithSpriteFrameName("arpl_ship3_2_orgLight1.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                orgLight1:setBlendFunc(blendFunc)
                
                local olFadeOut = CCFadeTo:create(0.5, 255 * 0.5)
                local olFadeIn = CCFadeTo:create(0.5, 255)
                local olArr = CCArray:create()
                olArr:addObject(olFadeOut)
                olArr:addObject(olFadeIn)
                local olSeq = CCSequence:create(olArr)
                local olRepeat = CCRepeatForever:create(olSeq)
                orgLight1:runAction(olRepeat)
                orgLight1:setPosition(432, 280)
                airShipSp:addChild(orgLight1, 4)
                
                local orgLight2 = CCSprite:createWithSpriteFrameName("arpl_ship3_2_orgLight2.png")
                orgLight2:setOpacity(255 * 0.5)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                orgLight2:setBlendFunc(blendFunc)
                
                local ol2FadeOut = CCFadeTo:create(0.5, 255)
                local ol2FadeIn = CCFadeTo:create(0.5, 255 * 0.5)
                local ol2Arr = CCArray:create()
                ol2Arr:addObject(ol2FadeOut)
                ol2Arr:addObject(ol2FadeIn)
                local ol2Seq = CCSequence:create(ol2Arr)
                local ol2Repeat = CCRepeatForever:create(ol2Seq)
                orgLight2:runAction(ol2Repeat)
                orgLight2:setPosition(429, 204)
                airShipSp:addChild(orgLight2, 4)
                
                local flickerSp1 = CCSprite:createWithSpriteFrameName("arpl_shipLightFlicker1.png")
                flickerSp1:setScale(0.9)
                flickerSp1:setFlipX(true)
                flickerSp1:setRotation(-50)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                flickerSp1:setBlendFunc(blendFunc)
                
                local filickerArr = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_shipLightFlicker"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    filickerArr:addObject(frame)
                end
                local flickerAnim = CCAnimation:createWithSpriteFrames(filickerArr)
                flickerAnim:setDelayPerUnit(0.05)
                local animate = CCAnimate:create(flickerAnim)
                local repeatForever = CCRepeatForever:create(animate)
                flickerSp1:setPosition(ccp(441, 187))
                flickerSp1:runAction(repeatForever)
                airShipSp:addChild(flickerSp1, 1)
            elseif airShipId == 4 then
                
                local tailOrgSp = CCSprite:createWithSpriteFrameName("arpl_shipTailOrgLight.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                tailOrgSp:setBlendFunc(blendFunc)
                
                local tailOrgFadeOut = CCFadeTo:create(0.5, 255 * 0.5)
                local tailOrgFadeIn = CCFadeTo:create(1.5, 255)
                local tailOrgArr = CCArray:create()
                tailOrgArr:addObject(tailOrgFadeOut)
                tailOrgArr:addObject(tailOrgFadeIn)
                
                local tailOrgSeq = CCSequence:create(tailOrgArr)
                local tailOrgRepeat = CCRepeatForever:create(tailOrgSeq)
                tailOrgSp:runAction(tailOrgRepeat)
                tailOrgSp:setPosition(109.5, 191.5)
                airShipSp:addChild(tailOrgSp, 5)
                
                local shipTailSmokeSp = CCSprite:createWithSpriteFrameName("arpl_shipSmoke1.png")
                shipTailSmokeSp:setFlipX(true)
                shipTailSmokeSp:setRotation(-50)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                shipTailSmokeSp:setBlendFunc(blendFunc)
                
                local tmArr = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_shipSmoke"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    tmArr:addObject(frame)
                end
                local tmAnim = CCAnimation:createWithSpriteFrames(tmArr)
                tmAnim:setDelayPerUnit(0.05)
                local animate = CCAnimate:create(tmAnim)
                local repeatForever = CCRepeatForever:create(animate)
                shipTailSmokeSp:setPosition(ccp(258, 140))
                shipTailSmokeSp:runAction(repeatForever)
                airShipSp:addChild(shipTailSmokeSp, 5)
                
                local shipTailFlameSp = CCSprite:createWithSpriteFrameName("arpl_shipFire1.png")
                shipTailFlameSp:setFlipX(true)
                shipTailFlameSp:setRotation(-50)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                shipTailFlameSp:setBlendFunc(blendFunc)
                
                if isUseInBattle then
                    if isUseInBattle.start then
                        local function fireVisibleFalseHandl() shipTailFlameSp:setVisible(false) end
                        local flameVisCall = CCCallFunc:create(fireVisibleFalseHandl)
                        local function fireVisibleTrueHandl()
                            shipTailFlameSp:setVisible(true)
                            
                            local tfArr = CCArray:create()
                            for kk = 1, 15 do
                                local nameStr = "arpl_shipFire"..kk..".png"
                                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                                tfArr:addObject(frame)
                            end
                            local tfAnim = CCAnimation:createWithSpriteFrames(tfArr)
                            tfAnim:setDelayPerUnit(0.05)
                            local animate = CCAnimate:create(tfAnim)
                            
                            local repeatForever = CCRepeatForever:create(animate)
                            shipTailFlameSp:runAction(repeatForever)
                        end
                        local flameVisCall2 = CCCallFunc:create(fireVisibleTrueHandl)
                        local det1 = CCDelayTime:create(isUseInBattle.inT + isUseInBattle.dlT1 + isUseInBattle.dlT2)
                        local battleArr = CCArray:create()
                        battleArr:addObject(flameVisCall)
                        battleArr:addObject(det1)
                        battleArr:addObject(flameVisCall2)
                        local battleSeq = CCSequence:create(battleArr)
                        shipTailFlameSp:runAction(battleSeq)
                    end
                else
                    local tfArr = CCArray:create()
                    for kk = 1, 15 do
                        local nameStr = "arpl_shipFire"..kk..".png"
                        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                        tfArr:addObject(frame)
                    end
                    local tfAnim = CCAnimation:createWithSpriteFrames(tfArr)
                    tfAnim:setDelayPerUnit(0.05)
                    local animate = CCAnimate:create(tfAnim)
                    
                    local repeatForever = CCRepeatForever:create(animate)
                    shipTailFlameSp:runAction(repeatForever)
                end
                
                shipTailFlameSp:setPosition(ccp(258, 140))
                airShipSp:addChild(shipTailFlameSp, 5)
                
                local shipTailSmokeSp2 = CCSprite:createWithSpriteFrameName("arpl_shipSmoke1.png")
                shipTailSmokeSp2:setFlipX(true)
                shipTailSmokeSp2:setRotation(-50)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                shipTailSmokeSp2:setBlendFunc(blendFunc)
                
                local tmArr2 = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_shipSmoke"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    tmArr2:addObject(frame)
                end
                local tmAnim2 = CCAnimation:createWithSpriteFrames(tmArr2)
                tmAnim2:setDelayPerUnit(0.05)
                local animate2 = CCAnimate:create(tmAnim2)
                local repeatForever = CCRepeatForever:create(animate2)
                shipTailSmokeSp2:setPosition(ccp(265, 172))
                shipTailSmokeSp2:runAction(repeatForever)
                airShipSp:addChild(shipTailSmokeSp2, 5)
                
                local shipTailFlameSp2 = CCSprite:createWithSpriteFrameName("arpl_shipFire1.png")
                shipTailFlameSp2:setFlipX(true)
                shipTailFlameSp2:setRotation(-50)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                shipTailFlameSp2:setBlendFunc(blendFunc)
                
                if isUseInBattle then
                    if isUseInBattle.start then
                        local function fireVisibleFalseHandl() shipTailFlameSp2:setVisible(false) end
                        local flameVisCall = CCCallFunc:create(fireVisibleFalseHandl)
                        local function fireVisibleTrueHandl()
                            shipTailFlameSp2:setVisible(true)
                            
                            local tfArr2 = CCArray:create()
                            for kk = 1, 15 do
                                local nameStr = "arpl_shipFire"..kk..".png"
                                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                                tfArr2:addObject(frame)
                            end
                            local tfAnim2 = CCAnimation:createWithSpriteFrames(tfArr2)
                            tfAnim2:setDelayPerUnit(0.05)
                            local animate = CCAnimate:create(tfAnim2)
                            
                            local repeatForever = CCRepeatForever:create(animate)
                            shipTailFlameSp2:runAction(repeatForever)
                        end
                        local flameVisCall2 = CCCallFunc:create(fireVisibleTrueHandl)
                        local det1 = CCDelayTime:create(isUseInBattle.inT + isUseInBattle.dlT1 + isUseInBattle.dlT2)
                        local battleArr = CCArray:create()
                        battleArr:addObject(flameVisCall)
                        battleArr:addObject(det1)
                        battleArr:addObject(flameVisCall2)
                        local battleSeq = CCSequence:create(battleArr)
                        shipTailFlameSp2:runAction(battleSeq)
                    end
                else
                    local tfArr2 = CCArray:create()
                    for kk = 1, 15 do
                        local nameStr = "arpl_shipFire"..kk..".png"
                        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                        tfArr2:addObject(frame)
                    end
                    local tfAnim2 = CCAnimation:createWithSpriteFrames(tfArr2)
                    tfAnim2:setDelayPerUnit(0.05)
                    local animate = CCAnimate:create(tfAnim2)
                    
                    local repeatForever = CCRepeatForever:create(animate)
                    shipTailFlameSp2:runAction(repeatForever)
                end
                
                shipTailFlameSp2:setPosition(ccp(265, 172))
                airShipSp:addChild(shipTailFlameSp2, 5)
                
                ----
                local flickerSp1 = CCSprite:createWithSpriteFrameName("arpl_shipLightFlicker1.png")
                flickerSp1:setScale(0.9)
                flickerSp1:setFlipX(true)
                flickerSp1:setRotation(-50)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                flickerSp1:setBlendFunc(blendFunc)
                
                local filickerArr = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_shipLightFlicker"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    filickerArr:addObject(frame)
                end
                local flickerAnim = CCAnimation:createWithSpriteFrames(filickerArr)
                flickerAnim:setDelayPerUnit(0.05)
                local animate = CCAnimate:create(flickerAnim)
                local repeatForever = CCRepeatForever:create(animate)
                flickerSp1:setPosition(ccp(475, 253))
                flickerSp1:runAction(repeatForever)
                airShipSp:addChild(flickerSp1, 1)
                
                local flickerSp2 = CCSprite:createWithSpriteFrameName("arpl_shipLightFlicker1.png")
                flickerSp2:setScale(0.75)
                flickerSp2:setFlipX(true)
                flickerSp2:setRotation(-50)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                flickerSp2:setBlendFunc(blendFunc)
                
                local filickerArr2 = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_shipLightFlicker"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    filickerArr2:addObject(frame)
                end
                local flickerAnim2 = CCAnimation:createWithSpriteFrames(filickerArr2)
                flickerAnim2:setDelayPerUnit(0.05)
                local animate = CCAnimate:create(flickerAnim2)
                local repeatForever = CCRepeatForever:create(animate)
                flickerSp2:setPosition(ccp(475, 239))
                flickerSp2:runAction(repeatForever)
                airShipSp:addChild(flickerSp2, 1)
                
                local circleSp = CCSprite:createWithSpriteFrameName("arpl_ship4_2_circleOrgLight.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                circleSp:setBlendFunc(blendFunc)
                
                if isUseInBattle then
                    if isUseInBattle.start then
                        circleSp:setVisible(false)
                        local det = CCDelayTime:create(isUseInBattle.inT)
                        local blink = CCBlink:create(1, 3)
                        local function cSpShowHandl() circleSp:setVisible(true) end
                        local cSpCall = CCCallFunc:create(cSpShowHandl)
                        local cArr = CCArray:create()
                        cArr:addObject(det)
                        cArr:addObject(blink)
                        cArr:addObject(cSpCall)
                        local cSeq = CCSequence:create(cArr)
                        circleSp:runAction(cSeq)
                    end
                end
                
                circleSp:setPosition(309, 136.5)
                airShipSp:addChild(circleSp, 5)
                
                local verticalBar = CCSprite:createWithSpriteFrameName("arpl_ship4_2_verticalBarOrgLight.png")
                verticalBar:setOpacity(255 * 0.25)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                verticalBar:setBlendFunc(blendFunc)
                
                local vbFadeOut = CCFadeTo:create(1, 255 * 0.5)
                local vbFadeIn = CCFadeTo:create(1, 255)
                local vbArr = CCArray:create()
                vbArr:addObject(vbFadeOut)
                vbArr:addObject(vbFadeIn)
                local vbSeq = CCSequence:create(vbArr)
                local vbRepeat = CCRepeatForever:create(vbSeq)
                verticalBar:runAction(vbRepeat)
                verticalBar:setPosition(428.5, 274.5)
                airShipSp:addChild(verticalBar, 4)
                
                local triangleSp = CCSprite:createWithSpriteFrameName("arpl_ship4_2_irregularOrgLight.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                triangleSp:setBlendFunc(blendFunc)
                
                triangleSp:setPosition(436, 217)
                airShipSp:addChild(triangleSp, 5)
                
                ---------
                local squareOrgLightSp = CCSprite:createWithSpriteFrameName("arpl_ship4_1_squareOrgLight.png")
                squareOrgLightSp:setScaleY(0.2)
                squareOrgLightSp:setOpacity(0)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                squareOrgLightSp:setBlendFunc(blendFunc)
                
                local solFadeOut = CCFadeTo:create(0.75, 255)
                local solFadeIn = CCFadeTo:create(0.75, 0)
                local solArr = CCArray:create()
                solArr:addObject(solFadeOut)
                solArr:addObject(solFadeIn)
                local solSeq = CCSequence:create(solArr)
                local solRepeat = CCRepeatForever:create(solSeq)
                squareOrgLightSp:runAction(solRepeat)
                squareOrgLightSp:setPosition(339, 194)
                airShipSp:addChild(squareOrgLightSp, 5)
                
                local squareOrgLightSp2 = CCSprite:createWithSpriteFrameName("arpl_ship4_1_squareOrgLight.png")
                squareOrgLightSp2:setScaleY(0.6)
                squareOrgLightSp2:setOpacity(0)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                squareOrgLightSp2:setBlendFunc(blendFunc)
                
                local function runFadeHandl()
                    local sol2FadeOut = CCFadeTo:create(0.75, 255)
                    local sol2FadeIn = CCFadeTo:create(0.75, 0)
                    local sol2Arr = CCArray:create()
                    sol2Arr:addObject(sol2FadeOut)
                    sol2Arr:addObject(sol2FadeIn)
                    local sol2Seq = CCSequence:create(sol2Arr)
                    local sol2Repeat = CCRepeatForever:create(sol2Seq)
                    squareOrgLightSp2:runAction(sol2Repeat)
                end
                local fadeCall = CCCallFunc:create(runFadeHandl)
                local solDet = CCDelayTime:create(0.45)
                local solbeginArr = CCArray:create()
                solbeginArr:addObject(solDet)
                solbeginArr:addObject(fadeCall)
                local solbeginSeq = CCSequence:create(solbeginArr)
                squareOrgLightSp2:runAction(solbeginSeq)
                
                squareOrgLightSp2:setPosition(347, 192)
                airShipSp:addChild(squareOrgLightSp2, 5)
                
                local squareOrgLightSp3 = CCSprite:createWithSpriteFrameName("arpl_ship4_1_squareOrgLight.png")
                squareOrgLightSp3:setOpacity(0)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                squareOrgLightSp3:setBlendFunc(blendFunc)
                
                local function runFadeHandl3()
                    local sol3FadeOut = CCFadeTo:create(0.75, 255)
                    local sol3FadeIn = CCFadeTo:create(0.75, 0)
                    local sol3Arr = CCArray:create()
                    sol3Arr:addObject(sol3FadeOut)
                    sol3Arr:addObject(sol3FadeIn)
                    local sol3Seq = CCSequence:create(sol3Arr)
                    local sol3Repeat = CCRepeatForever:create(sol3Seq)
                    squareOrgLightSp3:runAction(sol3Repeat)
                end
                local fadeCall3 = CCCallFunc:create(runFadeHandl3)
                local solDet3 = CCDelayTime:create(0.9)
                local solbeginArr3 = CCArray:create()
                solbeginArr3:addObject(solDet3)
                solbeginArr3:addObject(fadeCall3)
                local solbeginSeq3 = CCSequence:create(solbeginArr3)
                squareOrgLightSp3:runAction(solbeginSeq3)
                
                squareOrgLightSp3:setPosition(355, 191)
                airShipSp:addChild(squareOrgLightSp3, 5)
            end
        else
            if airShipId == 5 then
                
                local tailOrgSp = CCSprite:createWithSpriteFrameName("arpl_shipTailOrgLight.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                tailOrgSp:setBlendFunc(blendFunc)
                
                local tailOrgFadeOut = CCFadeTo:create(0.5, 255 * 0.5)
                local tailOrgFadeIn = CCFadeTo:create(1.5, 255)
                local tailOrgArr = CCArray:create()
                tailOrgArr:addObject(tailOrgFadeOut)
                tailOrgArr:addObject(tailOrgFadeIn)
                
                local tailOrgSeq = CCSequence:create(tailOrgArr)
                local tailOrgRepeat = CCRepeatForever:create(tailOrgSeq)
                tailOrgSp:runAction(tailOrgRepeat)
                tailOrgSp:setPosition(109, 192)
                airShipSp:addChild(tailOrgSp, 5)
                
                local shipTailSmokeSp = CCSprite:createWithSpriteFrameName("arpl_shipSmoke1.png")
                shipTailSmokeSp:setFlipX(true)
                shipTailSmokeSp:setRotation(-50)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                shipTailSmokeSp:setBlendFunc(blendFunc)
                
                local tmArr = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_shipSmoke"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    tmArr:addObject(frame)
                end
                local tmAnim = CCAnimation:createWithSpriteFrames(tmArr)
                tmAnim:setDelayPerUnit(0.03)
                local animate = CCAnimate:create(tmAnim)
                local repeatForever = CCRepeatForever:create(animate)
                shipTailSmokeSp:setPosition(ccp(330, 185.5))
                shipTailSmokeSp:runAction(repeatForever)
                airShipSp:addChild(shipTailSmokeSp, 5)
                
                local shipTailFlameSp = CCSprite:createWithSpriteFrameName("arpl_shipFire1.png")
                shipTailFlameSp:setFlipX(true)
                shipTailFlameSp:setRotation(-50)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                shipTailFlameSp:setBlendFunc(blendFunc)
                
                if isUseInBattle then
                    if isUseInBattle.start then
                        local function fireVisibleFalseHandl() shipTailFlameSp:setVisible(false) end
                        local flameVisCall = CCCallFunc:create(fireVisibleFalseHandl)
                        local function fireVisibleTrueHandl()
                            shipTailFlameSp:setVisible(true)
                            
                            local tfArr = CCArray:create()
                            for kk = 1, 15 do
                                local nameStr = "arpl_shipFire"..kk..".png"
                                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                                tfArr:addObject(frame)
                            end
                            local tfAnim = CCAnimation:createWithSpriteFrames(tfArr)
                            tfAnim:setDelayPerUnit(0.03)
                            local animate = CCAnimate:create(tfAnim)
                            
                            local repeatForever = CCRepeatForever:create(animate)
                            shipTailFlameSp:runAction(repeatForever)
                        end
                        local flameVisCall2 = CCCallFunc:create(fireVisibleTrueHandl)
                        local det1 = CCDelayTime:create(isUseInBattle.inT + isUseInBattle.dlT1 + isUseInBattle.dlT2)
                        local battleArr = CCArray:create()
                        battleArr:addObject(flameVisCall)
                        battleArr:addObject(det1)
                        battleArr:addObject(flameVisCall2)
                        local battleSeq = CCSequence:create(battleArr)
                        shipTailFlameSp:runAction(battleSeq)
                    end
                else
                    local tfArr = CCArray:create()
                    for kk = 1, 15 do
                        local nameStr = "arpl_shipFire"..kk..".png"
                        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                        tfArr:addObject(frame)
                    end
                    local tfAnim = CCAnimation:createWithSpriteFrames(tfArr)
                    tfAnim:setDelayPerUnit(0.03)
                    local animate = CCAnimate:create(tfAnim)
                    
                    local repeatForever = CCRepeatForever:create(animate)
                    shipTailFlameSp:runAction(repeatForever)
                end
                shipTailFlameSp:setPosition(ccp(330, 185.5))
                airShipSp:addChild(shipTailFlameSp, 5)
                
                local shipTailSmokeSp2 = CCSprite:createWithSpriteFrameName("arpl_shipSmoke1.png")
                shipTailSmokeSp2:setFlipX(true)
                shipTailSmokeSp2:setRotation(-50)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                shipTailSmokeSp2:setBlendFunc(blendFunc)
                
                local tmArr2 = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_shipSmoke"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    tmArr2:addObject(frame)
                end
                local tmAnim2 = CCAnimation:createWithSpriteFrames(tmArr2)
                tmAnim2:setDelayPerUnit(0.03)
                local animate2 = CCAnimate:create(tmAnim2)
                local repeatForever = CCRepeatForever:create(animate2)
                shipTailSmokeSp2:setPosition(ccp(281.5, 210.5))
                shipTailSmokeSp2:runAction(repeatForever)
                airShipSp:addChild(shipTailSmokeSp2, 1)
                
                local shipTailFlameSp2 = CCSprite:createWithSpriteFrameName("arpl_shipFire1.png")
                shipTailFlameSp2:setFlipX(true)
                shipTailFlameSp2:setRotation(-50)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                shipTailFlameSp2:setBlendFunc(blendFunc)
                
                if isUseInBattle then
                    if isUseInBattle.start then
                        local function fireVisibleFalseHandl() shipTailFlameSp2:setVisible(false) end
                        local flameVisCall = CCCallFunc:create(fireVisibleFalseHandl)
                        local function fireVisibleTrueHandl()
                            shipTailFlameSp2:setVisible(true)
                            
                            local tfArr2 = CCArray:create()
                            for kk = 1, 15 do
                                local nameStr = "arpl_shipFire"..kk..".png"
                                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                                tfArr2:addObject(frame)
                            end
                            local tfAnim2 = CCAnimation:createWithSpriteFrames(tfArr2)
                            tfAnim2:setDelayPerUnit(0.03)
                            local animate = CCAnimate:create(tfAnim2)
                            
                            local repeatForever = CCRepeatForever:create(animate)
                            shipTailFlameSp2:runAction(repeatForever)
                        end
                        local flameVisCall2 = CCCallFunc:create(fireVisibleTrueHandl)
                        local det1 = CCDelayTime:create(isUseInBattle.inT + isUseInBattle.dlT1 + isUseInBattle.dlT2)
                        local battleArr = CCArray:create()
                        battleArr:addObject(flameVisCall)
                        battleArr:addObject(det1)
                        battleArr:addObject(flameVisCall2)
                        local battleSeq = CCSequence:create(battleArr)
                        shipTailFlameSp2:runAction(battleSeq)
                    end
                else
                    local tfArr2 = CCArray:create()
                    for kk = 1, 15 do
                        local nameStr = "arpl_shipFire"..kk..".png"
                        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                        tfArr2:addObject(frame)
                    end
                    local tfAnim2 = CCAnimation:createWithSpriteFrames(tfArr2)
                    tfAnim2:setDelayPerUnit(0.03)
                    local animate = CCAnimate:create(tfAnim2)
                    
                    local repeatForever = CCRepeatForever:create(animate)
                    shipTailFlameSp2:runAction(repeatForever)
                end
                shipTailFlameSp2:setPosition(ccp(281.5, 210.5))
                airShipSp:addChild(shipTailFlameSp2, 1)
                
                local yellowBeamSp = CCSprite:createWithSpriteFrameName("arpl_ship5_2_yellowBeam.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                yellowBeamSp:setBlendFunc(blendFunc)
                
                local ybFadeOut = CCFadeTo:create(1, 255 * 0.5)
                local ybFadeIn = CCFadeTo:create(1, 255)
                local ybArr = CCArray:create()
                ybArr:addObject(ybFadeOut)
                ybArr:addObject(ybFadeIn)
                local ybSeq = CCSequence:create(ybArr)
                local ybRepeat = CCRepeatForever:create(ybSeq)
                yellowBeamSp:runAction(ybRepeat)
                yellowBeamSp:setPosition(426, 216)
                airShipSp:addChild(yellowBeamSp, 5)
                
                local yellowLightSp = CCSprite:createWithSpriteFrameName("arpl_ship5_2_yellowLight.png")
                yellowLightSp:setOpacity(255 * 0.5)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                yellowLightSp:setBlendFunc(blendFunc)
                
                local ylFadeOut = CCFadeTo:create(1, 255)
                local ylFadeIn = CCFadeTo:create(1, 255 * 0.5)
                local ylArr = CCArray:create()
                ylArr:addObject(ylFadeOut)
                ylArr:addObject(ylFadeIn)
                local ylSeq = CCSequence:create(ylArr)
                local ylRepeat = CCRepeatForever:create(ylSeq)
                yellowLightSp:runAction(ylRepeat)
                yellowLightSp:setPosition(433, 303.5)
                airShipSp:addChild(yellowLightSp, 5)
            elseif airShipId == 6 then
                
                local shipTailSmokeSp = CCSprite:createWithSpriteFrameName("arpl_shipSmoke1.png")
                shipTailSmokeSp:setFlipX(true)
                shipTailSmokeSp:setRotation(-50)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                shipTailSmokeSp:setBlendFunc(blendFunc)
                
                local tmArr = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_shipSmoke"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    tmArr:addObject(frame)
                end
                local tmAnim = CCAnimation:createWithSpriteFrames(tmArr)
                tmAnim:setDelayPerUnit(0.05)
                local animate = CCAnimate:create(tmAnim)
                local repeatForever = CCRepeatForever:create(animate)
                shipTailSmokeSp:setPosition(ccp(305, 191))
                shipTailSmokeSp:runAction(repeatForever)
                airShipSp:addChild(shipTailSmokeSp, 5)
                
                local shipTailFlameSp = CCSprite:createWithSpriteFrameName("arpl_shipFire1.png")
                shipTailFlameSp:setFlipX(true)
                shipTailFlameSp:setRotation(-50)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                shipTailFlameSp:setBlendFunc(blendFunc)
                
                if isUseInBattle then
                    if isUseInBattle.start then
                        local function fireVisibleFalseHandl() shipTailFlameSp:setVisible(false) end
                        local flameVisCall = CCCallFunc:create(fireVisibleFalseHandl)
                        local function fireVisibleTrueHandl()
                            shipTailFlameSp:setVisible(true)
                            
                            local tfArr2 = CCArray:create()
                            for kk = 1, 15 do
                                local nameStr = "arpl_shipFire"..kk..".png"
                                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                                tfArr2:addObject(frame)
                            end
                            local tfAnim2 = CCAnimation:createWithSpriteFrames(tfArr2)
                            tfAnim2:setDelayPerUnit(0.03)
                            local animate = CCAnimate:create(tfAnim2)
                            
                            local repeatForever = CCRepeatForever:create(animate)
                            shipTailFlameSp:runAction(repeatForever)
                        end
                        local flameVisCall2 = CCCallFunc:create(fireVisibleTrueHandl)
                        local det1 = CCDelayTime:create(isUseInBattle.inT + isUseInBattle.dlT1 + isUseInBattle.dlT2)
                        local battleArr = CCArray:create()
                        battleArr:addObject(flameVisCall)
                        battleArr:addObject(det1)
                        battleArr:addObject(flameVisCall2)
                        local battleSeq = CCSequence:create(battleArr)
                        shipTailFlameSp:runAction(battleSeq)
                    end
                else
                    local tfArr2 = CCArray:create()
                    for kk = 1, 15 do
                        local nameStr = "arpl_shipFire"..kk..".png"
                        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                        tfArr2:addObject(frame)
                    end
                    local tfAnim2 = CCAnimation:createWithSpriteFrames(tfArr2)
                    tfAnim2:setDelayPerUnit(0.03)
                    local animate = CCAnimate:create(tfAnim2)
                    
                    local repeatForever = CCRepeatForever:create(animate)
                    shipTailFlameSp:runAction(repeatForever)
                end
                shipTailFlameSp:setPosition(ccp(305, 191))
                airShipSp:addChild(shipTailFlameSp, 5)
                
                local flickerSp1 = CCSprite:createWithSpriteFrameName("arpl_shipLightFlicker1.png")
                flickerSp1:setScale(0.9)
                flickerSp1:setFlipX(true)
                flickerSp1:setRotation(-50)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                flickerSp1:setBlendFunc(blendFunc)
                
                local filickerArr = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_shipLightFlicker"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    filickerArr:addObject(frame)
                end
                local flickerAnim = CCAnimation:createWithSpriteFrames(filickerArr)
                flickerAnim:setDelayPerUnit(0.05)
                local animate = CCAnimate:create(flickerAnim)
                local repeatForever = CCRepeatForever:create(animate)
                flickerSp1:setPosition(ccp(404.5, 197.5))
                flickerSp1:runAction(repeatForever)
                airShipSp:addChild(flickerSp1, 1)
                
                local orgBeamSp = CCSprite:createWithSpriteFrameName("arpl_ship6_2_orgBeam.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                orgBeamSp:setBlendFunc(blendFunc)
                
                if isUseInBattle then
                    if isUseInBattle.start then
                        orgBeamSp:setVisible(false)
                        local det = CCDelayTime:create(isUseInBattle.inT)
                        local blink = CCBlink:create(1, 3)
                        local function obSpShowHandl()
                            orgBeamSp:setVisible(true)
                            local obFadeOut = CCFadeTo:create(1, 255 * 0.5)
                            local obFadeIn = CCFadeTo:create(1, 255)
                            local obArr = CCArray:create()
                            obArr:addObject(obFadeOut)
                            obArr:addObject(obFadeIn)
                            local obSeq = CCSequence:create(obArr)
                            local obRepeat = CCRepeatForever:create(obSeq)
                            orgBeamSp:runAction(obRepeat)
                        end
                        local obSpCall = CCCallFunc:create(obSpShowHandl)
                        local obArr = CCArray:create()
                        obArr:addObject(det)
                        obArr:addObject(blink)
                        obArr:addObject(obSpCall)
                        local cSeq = CCSequence:create(obArr)
                        orgBeamSp:runAction(cSeq)
                    end
                else
                    local obFadeOut = CCFadeTo:create(1, 255 * 0.5)
                    local obFadeIn = CCFadeTo:create(1, 255)
                    local obArr = CCArray:create()
                    obArr:addObject(obFadeOut)
                    obArr:addObject(obFadeIn)
                    local obSeq = CCSequence:create(obArr)
                    local obRepeat = CCRepeatForever:create(obSeq)
                    orgBeamSp:runAction(obRepeat)
                end
                orgBeamSp:setPosition(400, 202.5)
                airShipSp:addChild(orgBeamSp, 5)
                
                local yellowSpikeSp = CCSprite:createWithSpriteFrameName("arpl_ship6_2_yellowSpike.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                yellowSpikeSp:setBlendFunc(blendFunc)
                
                local ysFadeOut = CCFadeTo:create(1, 255 * 0.2)
                local ysFadeIn = CCFadeTo:create(1, 255)
                local ysArr = CCArray:create()
                ysArr:addObject(ysFadeOut)
                ysArr:addObject(ysFadeIn)
                local ysSeq = CCSequence:create(ysArr)
                local ysRepeat = CCRepeatForever:create(ysSeq)
                yellowSpikeSp:runAction(ysRepeat)
                yellowSpikeSp:setPosition(561, 412)
                airShipSp:addChild(yellowSpikeSp, 5)
                
                local redLightSp = CCSprite:createWithSpriteFrameName("arpl_ship6_2_redLight1.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                redLightSp:setBlendFunc(blendFunc)
                
                local rlFadeOut = CCFadeTo:create(0.125, 255 * 0.5)
                local rlFadeIn = CCFadeTo:create(0.125, 255)
                local rlFadeOut2 = CCFadeTo:create(0.125, 255 * 0.5)
                local rlFadeIn2 = CCFadeTo:create(0.125, 255)
                local rlFadeOut3 = CCFadeTo:create(0.75, 255 * 0.1)
                local rlFadeIn3 = CCFadeTo:create(0.75, 255)
                local rlArr = CCArray:create()
                rlArr:addObject(rlFadeOut)
                rlArr:addObject(rlFadeIn)
                rlArr:addObject(rlFadeOut2)
                rlArr:addObject(rlFadeIn2)
                rlArr:addObject(rlFadeOut3)
                rlArr:addObject(rlFadeIn3)
                local rlSeq = CCSequence:create(rlArr)
                local rlRepeat = CCRepeatForever:create(rlSeq)
                redLightSp:runAction(rlRepeat)
                redLightSp:setPosition(126, 266)
                airShipSp:addChild(redLightSp, 5)
                
                local redLightSp2 = CCSprite:createWithSpriteFrameName("arpl_ship6_2_redLight2.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                redLightSp2:setBlendFunc(blendFunc)
                
                local rlDet = CCDelayTime:create(1)
                local function detRun()
                    local rl2FadeOut = CCFadeTo:create(0.125, 255 * 0.5)
                    local rl2FadeIn = CCFadeTo:create(0.125, 255)
                    local rl2FadeOut2 = CCFadeTo:create(0.125, 255 * 0.5)
                    local rl2FadeIn2 = CCFadeTo:create(0.125, 255)
                    local rl2FadeOut3 = CCFadeTo:create(0.75, 255 * 0.1)
                    local rl2FadeIn3 = CCFadeTo:create(0.75, 255)
                    local rl2Arr = CCArray:create()
                    rl2Arr:addObject(rl2FadeOut)
                    rl2Arr:addObject(rl2FadeIn)
                    rl2Arr:addObject(rl2FadeOut2)
                    rl2Arr:addObject(rl2FadeIn2)
                    rl2Arr:addObject(rl2FadeOut3)
                    rl2Arr:addObject(rl2FadeIn3)
                    local rl2Seq = CCSequence:create(rl2Arr)
                    local rl2Repeat = CCRepeatForever:create(rl2Seq)
                    redLightSp2:runAction(rl2Repeat)
                end
                local rlCCFun = CCCallFunc:create(detRun)
                local rl22Arr = CCArray:create()
                rl22Arr:addObject(rlDet)
                rl22Arr:addObject(rlCCFun)
                local rl22Seq = CCSequence:create(rl22Arr)
                redLightSp2:runAction(rl22Seq)
                
                redLightSp2:setPosition(148, 269)
                airShipSp:addChild(redLightSp2, 5)
            elseif airShipId == 7 then
                
                local tailLightSp = CCSprite:createWithSpriteFrameName("arpl_ship7_2_tailLightYellow.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                tailLightSp:setBlendFunc(blendFunc)
                
                local tlFadeOut = CCFadeTo:create(1, 255 * 0.3)
                local tlFadeIn = CCFadeTo:create(1, 255)
                local tlArr = CCArray:create()
                tlArr:addObject(tlFadeOut)
                tlArr:addObject(tlFadeIn)
                local tlSeq = CCSequence:create(tlArr)
                local tlRepeat = CCRepeatForever:create(tlSeq)
                tailLightSp:runAction(tlRepeat)
                tailLightSp:setPosition(114, 237)
                airShipSp:addChild(tailLightSp, 5)
                
                local spkesYellowSp = CCSprite:createWithSpriteFrameName("arpl_ship7_1_spikesYellowLight.png")
                spkesYellowSp:setFlipX(true)
                spkesYellowSp:setRotation(-50)
                spkesYellowSp:setOpacity(255 * 0.4)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                spkesYellowSp:setBlendFunc(blendFunc)
                
                local syFadeOut = CCFadeTo:create(1, 255)
                local syFadeIn = CCFadeTo:create(1, 255 * 0.4)
                local syArr = CCArray:create()
                syArr:addObject(syFadeOut)
                syArr:addObject(syFadeIn)
                local sySeq = CCSequence:create(syArr)
                local syRepeat = CCRepeatForever:create(sySeq)
                spkesYellowSp:runAction(syRepeat)
                spkesYellowSp:setPosition(427.5, 423.5)
                airShipSp:addChild(spkesYellowSp, 5)
                
                local spkesYellowSp2 = CCSprite:createWithSpriteFrameName("arpl_ship7_1_spikesYellowLight.png")
                spkesYellowSp2:setFlipX(true)
                spkesYellowSp2:setRotation(-50)
                spkesYellowSp2:setScale(0.95)
                spkesYellowSp2:setOpacity(255 * 0.4)
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                spkesYellowSp2:setBlendFunc(blendFunc)
                
                local sy2FadeOut = CCFadeTo:create(1, 255)
                local sy2FadeIn = CCFadeTo:create(1, 255 * 0.4)
                local sy2Arr = CCArray:create()
                sy2Arr:addObject(sy2FadeOut)
                sy2Arr:addObject(sy2FadeIn)
                local sy2Seq = CCSequence:create(sy2Arr)
                local sy2Repeat = CCRepeatForever:create(sy2Seq)
                spkesYellowSp2:runAction(sy2Repeat)
                spkesYellowSp2:setPosition(572.5, 351.5)
                airShipSp:addChild(spkesYellowSp2, 5)
                
                local blueLightSp = CCSprite:createWithSpriteFrameName("arpl_ship7_1_blueLight.png")
                local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                blueLightSp:setBlendFunc(blendFunc)
                
                local blFadeOut = CCFadeTo:create(1, 255 * 0.3)
                local blFadeIn = CCFadeTo:create(1, 255)
                local blArr = CCArray:create()
                blArr:addObject(blFadeOut)
                blArr:addObject(blFadeIn)
                local blSeq = CCSequence:create(blArr)
                local blRepeat = CCRepeatForever:create(blSeq)
                blueLightSp:runAction(blRepeat)
                blueLightSp:setPosition(441, 205.5)
                airShipSp:addChild(blueLightSp, 5)
                
                local smokeSp = CCSprite:createWithSpriteFrameName("arpl_ship7_1_smoke1.png")
                smokeSp:setFlipX(true)
                local skArr = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_ship7_1_smoke"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    skArr:addObject(frame)
                end
                local skAnim = CCAnimation:createWithSpriteFrames(skArr)
                skAnim:setDelayPerUnit(0.03)
                local animate = CCAnimate:create(skAnim)
                local repeatForever = CCRepeatForever:create(animate)
                smokeSp:setPosition(ccp(319, 482))
                smokeSp:runAction(repeatForever)
                airShipSp:addChild(smokeSp, 5)
                
                if isUseInBattle then
                    if isUseInBattle.start then
                        smokeSp:setOpacity(130)
                        
                        local det = CCDelayTime:create(isUseInBattle.inT)
                        local fadeIn = CCFadeTo:create(isUseInBattle.dlT1, 255)
                        local sArr = CCArray:create()
                        sArr:addObject(det)
                        sArr:addObject(fadeIn)
                        local sSeq = CCSequence:create(sArr)
                        smokeSp:runAction(sSeq)
                    end
                end
                
                local smokeSp2 = CCSprite:createWithSpriteFrameName("arpl_ship7_1_smoke1.png")
                smokeSp2:setFlipX(true)
                smokeSp2:setScale(0.6)
                local skArr2 = CCArray:create()
                for kk = 1, 15 do
                    local nameStr = "arpl_ship7_1_smoke"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    skArr2:addObject(frame)
                end
                local skAnim2 = CCAnimation:createWithSpriteFrames(skArr2)
                skAnim2:setDelayPerUnit(0.03)
                local animate2 = CCAnimate:create(skAnim2)
                local repeatForever2 = CCRepeatForever:create(animate2)
                smokeSp2:setPosition(ccp(216, 343))
                smokeSp2:runAction(repeatForever2)
                airShipSp:addChild(smokeSp2, 5)
                
                if isUseInBattle then
                    if isUseInBattle.start then
                        smokeSp2:setOpacity(130)
                        
                        local det = CCDelayTime:create(isUseInBattle.inT)
                        local fadeIn = CCFadeTo:create(isUseInBattle.dlT1, 255)
                        local sArr = CCArray:create()
                        sArr:addObject(det)
                        sArr:addObject(fadeIn)
                        local sSeq = CCSequence:create(sArr)
                        smokeSp2:runAction(sSeq)
                    end
                end
            end
        end
    end
    
    return airShipSp, shadowSp
end