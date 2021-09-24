require "luascript/script/game/scene/gamedialog/arenaDialog/arenaDialog"

arenaTotalDialog = commonDialog:new()

function arenaTotalDialog:new(layerNum, jumpType)
    
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("serverWar/serverWar2.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("worldWar/worldWarCommon.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/localWar/localWar.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/platWar/platWarImage.plist")
    spriteController:addPlist("public/serverWarLocal/serverWarLocalCommon.plist")
    spriteController:addTexture("public/serverWarLocal/serverWarLocalCommon.png")
    spriteController:addPlist("public/dimensionalWar/dimensionalWar.plist")
    spriteController:addTexture("public/dimensionalWar/dimensionalWar.png")
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.leftBtn = nil
    self.expandIdx = {}
    self.layerNum = layerNum
    self.tipSp = nil
    self.tipSpTb = {}
    self.tipShowFlagTb = {}
    self.jumpType = jumpType
    self.callbackTb = {} --存储各个大战的跳转回调
    
    return nc
end

--设置或修改每个Tab页签
function arenaTotalDialog:resetTab()
    
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
    
end

function arenaTotalDialog:initFunctionTb()
    self.guildFuncItem = nil --教学引导的item
    local function callBack1()
        G_openArenaDialog(self.layerNum + 1)
    end
    
    local function callBack11()
        local td = smallDialog:new()
        local tabStr = {}
        if base.ma == 1 then
            local str1 = getlocal("arena_ExercisesDes1")
            local str2 = getlocal("shamBattle_ExercisesDes1")
            local str3 = getlocal("shamBattle_ExercisesDes2")
            local str4 = getlocal("shamBattle_ExercisesDes3")
            local str5 = getlocal("shamBattle_ExercisesDes4")
            local str6 = getlocal("shamBattle_ExercisesDes5")
            tabStr = {" ", str6, str5, str4, str3, str2, str1, " "}
        else
            local str1 = getlocal("arena_ExercisesDes1")
            local str2 = getlocal("arena_ExercisesDes2")
            local str3 = getlocal("arena_ExercisesDes3")
            local str4 = getlocal("arena_ExercisesDes4")
            local str5 = getlocal("arena_ExercisesDes5")
            tabStr = {" ", str5, str4, str3, str2, str1, " "}
        end
        local dialog = td:init("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, true, true, self.layerNum + 1, tabStr, 28)
        sceneGame:addChild(dialog, self.layerNum + 1)
    end
    
    local function callBack2()
        serverWarPersonalVoApi:showMainDialog(self.layerNum + 1)
    end
    self.callbackTb[1] = callBack2
    
    local function callBack21()
        local td = smallDialog:new()
        local str1 = getlocal("serverwar_info1")
        local str2 = getlocal("serverwar_info2")
        local str3 = getlocal("serverwar_info3")
        local str4 = getlocal("serverwar_info4")
        local tabStr = {" ", str4, str3, str2, str1, " "}
        local colorTb = {nil, G_ColorRed, G_ColorWhite, G_ColorWhite, G_ColorWhite, nil}
        local dialog = td:init("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, true, true, self.layerNum + 1, tabStr, 28, colorTb)
        sceneGame:addChild(dialog, self.layerNum + 1)
    end
    
    local function callBack3()
        if(SocketHandler2 == nil)then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("socket2notSupport"), true, self.layerNum + 1)
            do return end
        end
        serverWarTeamVoApi:showMainDialog(self.layerNum + 1)
    end
    self.callbackTb[2] = callBack3
    
    local function callBack31()
        local td = smallDialog:new()
        local str1 = getlocal("serverwarteam_info1")
        local str2 = getlocal("serverwarteam_info2")
        local str3 = getlocal("serverwarteam_info3")
        local str4 = getlocal("serverwarteam_info4")
        local str5 = getlocal("serverwarteam_info5")
        local tabStr = {" ", str5, str4, str3, str2, str1, " "}
        local colorTb = {nil, G_ColorRed, G_ColorWhite, G_ColorWhite, G_ColorWhite, G_ColorWhite, nil}
        local dialog = td:init("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, true, true, self.layerNum + 1, tabStr, 28, colorTb)
        sceneGame:addChild(dialog, self.layerNum + 1)
    end
    
    local function callBack4()
        if alienMinesVoApi:checkIsActive() == true or G_isTestServer() == true then
            if alienMinesVoApi:checkOpen() == true then
                local function callback(fn, data)
                    local ret, sData = base:checkServerData(data)
                    if ret == true then
                        if sData and sData.data then
                            alienMinesVoApi:setInfoVo(sData.data)
                            require "luascript/script/game/scene/gamedialog/alienMines/alienMinesMapDialog"
                            local td = alienMinesMapDialog:new()
                            local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, nil, nil, getlocal("alienMines"), true, self.layerNum + 1)
                            sceneGame:addChild(dialog, self.layerNum + 1)
                        end
                    end
                    
                end
                local startTime = alienMinesVoApi:getBeginAndEndtime(true)
                if startTime then
                    require "luascript/script/game/scene/gamedialog/alienMines/alienMinesMapDialog"
                    local td = alienMinesMapDialog:new()
                    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, nil, nil, getlocal("alienMines"), true, self.layerNum + 1)
                    sceneGame:addChild(dialog, self.layerNum + 1)
                else
                    socketHelper:alienMinesGet(callback)
                end
                
            else
                local level
                if(base.alienTechOpenLv and base.alienTechOpenLv > alienMineCfg.needLevel)then
                    level = base.alienTechOpenLv
                else
                    level = alienMineCfg.needLevel
                end
                
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("elite_challenge_unlock_level", {level}), 30)
            end
        else
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("backstage5019"), 30)
        end
    end
    
    local function callBack41()
        local td = smallDialog:new()
        local time1 = string.format("%02d:%02d", alienMineCfg.startTime[1], alienMineCfg.startTime[2])
        local time2 = string.format("%02d:%02d", alienMineCfg.endTime[1], alienMineCfg.endTime[2])
        local str1 = getlocal("alienMines_info1")
        local str2 = getlocal("alienMines_info2", {time1, time2})
        local needlevel
        if(base.alienTechOpenLv and base.alienTechOpenLv > alienMineCfg.needLevel)then
            needlevel = base.alienTechOpenLv
        else
            needlevel = alienMineCfg.needLevel
        end
        local str3 = getlocal("alienMines_info3", {needlevel})
        local str4 = "3." .. getlocal("alienMines_info4")
        
        local tabStr = {" ", str4, str3, str2, str1, " "}
        local colorTb = {nil, G_ColorRed, G_ColorWhite, G_ColorWhite, G_ColorYellowPro, nil}
        local dialog = td:init("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, true, true, self.layerNum + 1, tabStr, 28, colorTb)
        sceneGame:addChild(dialog, self.layerNum + 1)
    end
    
    self.functionTb = {
        {icon = "arenaIcon.png", nameKey = "arena_title", callBack = callBack1, callBack2 = callBack11, type = 1},
    }
    local getServerListFlag = false
    if(serverWarPersonalVoApi:checkShowServerWar())then
        local serverWarTb = {icon = "serverWarPIcon.png", nameKey = "serverwar_title", callBack = callBack2, callBack2 = callBack21, type = 2}
        table.insert(self.functionTb, serverWarTb)
        getServerListFlag = true
    end
    
    if base.serverWarTeamSwitch == 1 then
        local function getWarInfoHandler()
            if(serverWarTeamVoApi:checkShowServerWar())then
                local serverWarTb = {icon = "serverWarTIcon.png", nameKey = "serverwarteam_title", callBack = callBack3, callBack2 = callBack31, type = 3}
                table.insert(self.functionTb, serverWarTb)
                
                if self.tv then
                    self.tv:reloadData()
                end
            end
        end
        if(serverWarTeamVoApi.endTime and base.serverTime > serverWarTeamVoApi.endTime)then
        else
            serverWarTeamVoApi:getWarInfo(getWarInfoHandler)
        end
        getServerListFlag = true
    end
    
    local function callBack3()
        local openLv = base.expeditionOpenLv or 25
        if playerVoApi:getPlayerLevel() < openLv then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("expeditionNotEnough", {openLv}), 30)
            do return end
        end
        
        local function callback(fn, data)
            local ret, sData = base:checkServerData(data)
            if ret == true then
                require "luascript/script/game/scene/gamedialog/expedition/expeditionDialog"
                local vrd = expeditionDialog:new()
                local vd = vrd:init(self.layerNum + 1)
            end
        end
        socketHelper:expeditionGet(callback)
        
    end
    
    local function callBack31()
        local td = smallDialog:new()
        local equipOpenLv = base.expeditionOpenLv or 25
        local str1 = getlocal("expeditionTotalInfo1", {equipOpenLv})
        local str2 = getlocal("expeditionTotalInfo2")
        local str3 = getlocal("expeditionTotalInfo3")
        local tabStr = {" ", str3, str2, str1, " "}
        local dialog = td:init("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, true, true, self.layerNum + 1, tabStr, 28)
        sceneGame:addChild(dialog, self.layerNum + 1)
    end
    
    if base.heroSwitch == 1 and base.expeditionSwitch == 1 then
        local yuanzhengTb = {icon = "epdtIcon.png", nameKey = "expedition", callBack = callBack3, callBack2 = callBack31}
        table.insert(self.functionTb, yuanzhengTb)
    end
    
    -- 异星矿场
    local alienMinesTb = {icon = "Icon_BG.png", nameKey = "alienMines", callBack = callBack4, callBack2 = callBack41, type = 4}
    if base.alien == 1 and (base.amap == 1 or tonumber(base.curZoneID) >= 900) then
        table.insert(self.functionTb, alienMinesTb)
    end
    
    if worldWarVoApi and worldWarVoApi:checkShowWorldWar() then
        local function callBack4()
            -- if playerVoApi:getPlayerLevel()<25 then
            --   smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("expeditionNotEnough"),30)
            --   do return end
            -- end
            
            -- local function callback(fn,data)
            --     local ret,sData=base:checkServerData(data)
            --     if ret==true then
            worldWarVoApi:showMainDialog(self.layerNum + 1)
            --     end
            -- end
            -- socketHelper:expeditionGet(callback)
        end
        local function callBack41()
            local td = smallDialog:new()
            local str1 = getlocal("world_war_outtip1")
            local str2 = getlocal("world_war_outtip2")
            local str3 = getlocal("world_war_outtip3")
            local tabStr = {" ", str3, str2, str1, " "}
            local dialog = td:init("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, true, true, self.layerNum + 1, tabStr, 28)
            sceneGame:addChild(dialog, self.layerNum + 1)
        end
        local worldWarTb = {icon = "ww_icon.png", nameKey = "world_war_title", callBack = callBack4, callBack2 = callBack41}
        table.insert(self.functionTb, worldWarTb)
        getServerListFlag = true
        self.callbackTb[3] = callBack4
    end
    
    -- 军团战
    local function callBack6()
        if base.isAllianceWarSwitch == 0 then --军团战开关
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("backstage4012"), 30)
            do return end
        end
        local selfAlliance = allianceVoApi:getSelfAlliance()
        if(selfAlliance == nil or selfAlliance.aid <= 0)then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("allianceWar_errorNeedAlliance"), 30)
        else
            local td = allianceWarOverviewDialog:new(self.layerNum + 1)
            local tbArr = {}
            local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("alliance_war"), false, self.layerNum + 1)
            sceneGame:addChild(dialog, self.layerNum + 1)
        end
    end
    
    local function callBack61()
        local td = smallDialog:new()
        local str1 = getlocal("alliance_active_des1")
        local str2 = getlocal("alliance_active_des2")
        local tabStr = {" ", str2, str1, " "}
        local dialog = td:init("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, true, true, self.layerNum + 1, tabStr, 28)
        sceneGame:addChild(dialog, self.layerNum + 1)
    end
    
    local LegionTb = {icon = "Icon_BG.png", nameKey = "alliance_war", callBack = callBack6, callBack2 = callBack61, type = 6}
    if buildingVoApi:isYouhua() and base.isAllianceWarSwitch ~= 0 then
        table.insert(self.functionTb, LegionTb)
    end
    
    if base.localWarSwitch == 1 then
        local needDay = localWarCfg.prepareTime
        if G_getCurChoseLanguage() ~= "cn" or G_getCurChoseLanguage() ~= "tw" then-------文字做特殊处理
            if needDay ~= 0 then
                needDay = getlocal("week_day_"..needDay)
            else
                needDay = getlocal("week_day_7")
            end
            if needDay == nil then
                print("needDay has nil!!!!!")
            end
        end
        local function callBack71()
            local td = smallDialog:new()
            local str1 = getlocal("local_war_info1")
            local str2 = getlocal("local_war_info2", {needDay})
            local str3 = getlocal("local_war_info3")
            local str4 = getlocal("local_war_info4")
            local str5 = getlocal("local_war_info5", {localWarCfg.limitLevel})
            local tabStr = {" ", str5, str4, str3, str2, str1, " "}
            local dialog = td:init("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, true, true, self.layerNum + 1, tabStr, 28)
            sceneGame:addChild(dialog, self.layerNum + 1)
        end
        local function callBack7()
            if playerVoApi:getPlayerLevel() < localWarCfg.limitLevel then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("local_war_level_limit", {localWarCfg.limitLevel}), 30)
                do return end
            end
            local function getApplyDataCallback()
                require "luascript/script/game/gamemodel/localWar/localWarFightVoApi"
                localWarVoApi:showMainDialog(self.layerNum + 1)
            end
            localWarVoApi:getApplyData(getApplyDataCallback)
        end
        local localWarTb = {icon = "RegionalStationsIcon.png", nameKey = "local_war_title", callBack = callBack7, callBack2 = callBack71}
        table.insert(self.functionTb, localWarTb)
        self.callbackTb[4] = callBack7
    end
    
    if platWarVoApi:checkStatus() > 0 then
        local function callBack81()
            local td = smallDialog:new()
            local str1 = getlocal("plat_war_info1")
            local str2 = getlocal("plat_war_info2")
            local str3 = getlocal("plat_war_info3")
            local str4 = getlocal("plat_war_info4")
            local tabStr = {" ", str4, str3, str2, str1, " "}
            local dialog = td:init("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, true, true, self.layerNum + 1, tabStr, 28)
            sceneGame:addChild(dialog, self.layerNum + 1)
        end
        local function callBack8()
            platWarVoApi:showMainDialog(self.layerNum + 1)
        end
        local platWarTb = {icon = "platWarIcon.png", nameKey = "plat_war_title", callBack = callBack8, callBack2 = callBack81}
        table.insert(self.functionTb, platWarTb)
        getServerListFlag = true
        self.callbackTb[5] = callBack8
    end
    
    if serverWarLocalVoApi and serverWarLocalVoApi:checkStatus() > 0 then
        local function callBack91()
            local td = smallDialog:new()
            local str1 = getlocal("serverWarLocal_info1")
            -- local str2 = getlocal("serverWarLocal_info2")
            -- local str3 = getlocal("serverWarLocal_info3")
            local tabStr = {" ", str1, " "}
            local dialog = td:init("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, true, true, self.layerNum + 1, tabStr, 28)
            sceneGame:addChild(dialog, self.layerNum + 1)
        end
        local function callBack9()
            if serverWarLocalVoApi:checkStatus() <= 0 then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("local_war_stage_1"), 30)
                do return end
            end
            if playerVoApi:getPlayerLevel() < serverWarLocalCfg.limitLevel then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("local_war_level_limit", {serverWarLocalCfg.limitLevel}), 30)
                do return end
            end
            if(SocketHandler2 == nil)then
                smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("socket2notSupport"), true, self.layerNum + 1)
                do return end
            end
            local selfAlliance = allianceVoApi:getSelfAlliance()
            if selfAlliance and selfAlliance.aid then
                local function getInitDataCallback()
                    local function getApplyDataCallback()
                        require "luascript/script/game/gamemodel/serverWarLocal/serverWarLocalVoApi"
                        serverWarLocalVoApi:showMainDialog(self.layerNum + 1)
                        if serverWarLocalVoApi:checkStatus() >= 30 and serverWarLocalVoApi:getFunds() > 0 then
                            serverWarLocalVoApi:extractFunds(self.layerNum + 2)
                        end
                    end
                    serverWarLocalVoApi:getApplyData(getApplyDataCallback)
                end
                serverWarLocalVoApi:getInitData(getInitDataCallback)
            else
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("serverWarLocal_no_alliance_tip"), 30)
            end
        end
        local serverWarLocalTb = {icon = "serverWarLocalIcon.png", nameKey = "serverWarLocal_title", callBack = callBack9, callBack2 = callBack91}
        table.insert(self.functionTb, serverWarLocalTb)
        self.callbackTb[6] = callBack9
    end
    
    if base.allianceWar2Switch == 1 then
        local function callBack10()
            if base.allianceWar2Switch == 0 then --新军团战开关
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("backstage4012"), 30)
                do return end
            end
            local selfAlliance = allianceVoApi:getSelfAlliance()
            if(selfAlliance == nil or selfAlliance.aid <= 0)then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("allianceWar_errorNeedAlliance"), 30)
            else
                local td = allianceWar2OverviewDialog:new(self.layerNum + 1)
                local tbArr = {}
                local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("alliance_war"), true, self.layerNum + 1)
                sceneGame:addChild(dialog, self.layerNum + 1)
            end
        end
        local function callBack101()
            local td = smallDialog:new()
            local str1 = getlocal("alliance_active_des1")
            local str2 = getlocal("alliance_active_des2")
            local tabStr = {" ", str2, str1, " "}
            local dialog = td:init("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, true, true, self.layerNum + 1, tabStr, 28)
            sceneGame:addChild(dialog, self.layerNum + 1)
        end
        local allianceWarTb = {icon = "Icon_BG.png", nameKey = "alliance_war", callBack = callBack10, callBack2 = callBack101, type = 6}
        table.insert(self.functionTb, allianceWarTb)
    end
    
    if base.dimensionalWarSwitch == 1 then
        local function callBack11()
            if playerVoApi:getPlayerLevel() < userWarCfg.limitLevel then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("local_war_level_limit", {userWarCfg.limitLevel}), 30)
                do return end
            end
            local function getApplyDataCallback(...)
                dimensionalWarVoApi:showMainDialog(self.layerNum + 1)
            end
            dimensionalWarVoApi:getApplyData(getApplyDataCallback)
        end
        local function callBack111()
            local td = smallDialog:new()
            local str1 = getlocal("dimensionalWar_enter_desc1")
            local str2 = getlocal("dimensionalWar_enter_desc2", {userWarCfg.limitLevel})
            local str3 = getlocal("dimensionalWar_enter_desc3")
            local str4 = getlocal("dimensionalWar_enter_desc4", {userWarCfg.maxApplyNum})
            local str5 = getlocal("dimensionalWar_enter_desc5")
            local tabStr = {" ", str5, str4, str3, str2, str1, " "}
            local colorTb = {nil, G_ColorRed, G_ColorWhite, G_ColorWhite, G_ColorWhite, G_ColorWhite, nil}
            local dialog = td:init("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, true, true, self.layerNum + 1, tabStr, 28, colorTb)
            sceneGame:addChild(dialog, self.layerNum + 1)
        end
        local dimensionalWarTb = {icon = "dimensionalWarIcon.png", nameKey = "dimensionalWar_title", callBack = callBack11, callBack2 = callBack111}
        table.insert(self.functionTb, dimensionalWarTb)
        self.callbackTb[7] = callBack11
    end
    
    if ltzdzVoApi and ltzdzVoApi:isOpen() then
        local function callBack12()
            local openLv = ltzdzVoApi:getOpenLv()
            if playerVoApi:getPlayerLevel() < openLv then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("elite_challenge_unlock_level", {openLv}), 30)
                do return end
            end
            local isActive, dt = ltzdzVoApi:checkIsActive()
            if isActive == false then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("ltzdz_openTips", {G_formatActiveDate(dt)}), 30)
                do return end
            end
            ltzdzVoApi:showTotalDialog(self.layerNum + 1)
        end
        self.callbackTb[8] = callBack12
        local function callBack121()
            local td = smallDialog:new()
            local str1 = getlocal("ltzdz_function_rule1")
            local str2 = getlocal("ltzdz_function_rule2", {ltzdzVoApi:getOpenLv()})
            local str3 = getlocal("ltzdz_function_rule3")
            local str4 = getlocal("ltzdz_function_rule4", {ltzdzVoApi:getWarCfg().rankLast})
            local str5 = getlocal("ltzdz_function_rule5")
            local tabStr = {" ", str5, str4, str3, str2, str1, " "}
            local colorTb = {nil, G_ColorWhite, G_ColorWhite, G_ColorWhite, G_ColorWhite, G_ColorWhite, nil}
            local dialog = td:init("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, true, true, self.layerNum + 1, tabStr, 28, colorTb)
            sceneGame:addChild(dialog, self.layerNum + 1)
        end
        
        local ltzdzTb = {icon = "ltzdzIcon.png", nameKey = "ltzdz_title", callBack = callBack12, callBack2 = callBack121}
        table.insert(self.functionTb, ltzdzTb)
    end
    
    if believerVoApi and believerVoApi:isOpen() ~= 2 and believerVoApi:isShowBeliever() == true then
        local function callBack13()
            local showFlag, startTime = believerVoApi:isReachSeasonSt()
            if showFlag == false then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("believer_openTimeStr", {G_getDataTimeStr(startTime)}), 30)
                do return end
            end
            local flag, openLv = believerVoApi:isOpen()
            if flag == 3 then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("elite_challenge_unlock_level", {openLv}), 30)
                do return end
            end
            --状态，数据维护倒计时
            local status, cdTime = believerVoApi:checkSeasonStatus()
            --数据维护期,不能进入
            if status == 3 then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("believer_clear_data_stauts_prompt", {GetTimeStrForFleetSlot(cdTime)}), 30)
                do return end
            end
            believerVoApi:showBelieverDialog(self.layerNum + 1)
        end
        self.callbackTb[9] = callBack13
        local function callBack131()
            local believerCfg = believerVoApi:getBelieverCfg()
            local td = smallDialog:new()
            local str1 = getlocal("believer_desce_info_1")
            local str2 = getlocal("believer_desce_info_2")
            local str3 = getlocal("believer_desce_info_3", {believerCfg.levelLimit})
            local tabStr = {" ", str3, str2, str1, " "}
            local colorTb = {nil, G_ColorWhite, G_ColorWhite, G_ColorWhite, nil}
            local dialog = td:init("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, true, true, self.layerNum + 1, tabStr, 28, colorTb)
            sceneGame:addChild(dialog, self.layerNum + 1)
        end
        
        local believerTb = {icon = "believerIcon.png", nameKey = "believer_title", callBack = callBack13, callBack2 = callBack131}
        table.insert(self.functionTb, believerTb)
    end
    
    if base.championshipWarSwitch == 1 then
        local function callBack14()
            local openFlag, openLv = championshipWarVoApi:isOpen()
            if openFlag ~= 1 then
                local tipStr = ""
                if openFlag == -1 then
                    tipStr = getlocal("elite_challenge_unlock_level", {openLv})
                elseif openFlag == -2 then
                    tipStr = getlocal("championshipWar_no_alliance")
                end
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tipStr, 30)
                do return end
            end
            local state, dt = championshipWarVoApi:getWarState()
            if state == 40 then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("championshipWar_restbattle_tip", {G_formatActiveDate(dt)}), 30)
                do return end
            end
            championshipWarVoApi:showMainDialog(self.layerNum + 1)
        end
        local function callBack141()
            local warCfg = championshipWarVoApi:getWarCfg()
            local td = smallDialog:new()
            local tabStr = {" ", getlocal("championshipWar_rule3"), getlocal("championshipWar_rule2"), getlocal("championshipWar_rule1", {math.floor(warCfg.warCycle / 86400)}), " "}
            local dialog = td:init("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, true, true, self.layerNum + 1, tabStr, 28)
            sceneGame:addChild(dialog, self.layerNum + 1)
        end
        local championshipTb = {icon = "csi_icon.png", nameKey = "championshipWar_title", callBack = callBack14, callBack2 = callBack141}
        table.insert(self.functionTb, championshipTb)
    end
    if exerWarVoApi:isOpen()~=3 then --跨服联合演习
        local function callBack15()
            exerWarVoApi:showExerWarDialog(self.layerNum + 1)
        end
        local function callBack151()
            local td = smallDialog:new()
            local tabStr = {" ", getlocal("exerwar_helpTitle1Desc6"), getlocal("exerwar_helpTitle1Desc5"), getlocal("exerwar_helpTitle1Desc4"), getlocal("exerwar_helpTitle1Desc3", {exerWarVoApi:getWinNum()}), getlocal("exerwar_helpTitle1Desc2"), getlocal("exerwar_helpTitle1Desc1"), " "}
            local dialog = td:init("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, true, true, self.layerNum + 1, tabStr, 28)
            sceneGame:addChild(dialog, self.layerNum + 1)
        end
        local exerwarTb = {icon = "exerWar_icon.png", nameKey = "exerwar_title", callBack = callBack15, callBack2 = callBack151}
        table.insert(self.functionTb, exerwarTb)
    end
    
    if(getServerListFlag)then
        G_getServerCfgFromHttp(true)
    end
    local nameKeyTb = {}
    nameKeyTb["serverwar_title"] = 1
    nameKeyTb["serverwarteam_title"] = 2
    nameKeyTb["world_war_title"] = 3
    nameKeyTb["local_war_title"] = 4
    nameKeyTb["plat_war_title"] = 5
    nameKeyTb["serverWarLocal_title"] = 6
    nameKeyTb["dimensionalWar_title"] = 7
    nameKeyTb["ltzdz_title"] = 8
    nameKeyTb["believer_title"] = 9
    nameKeyTb["championshipWar_title"] = 10
    nameKeyTb["exerwar_title"] = 11

    self.nameKeyTb = nameKeyTb
end

--设置对话框里的tableView
function arenaTotalDialog:initTableView()
    self:initFunctionTb()
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    local height = 0;
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.bgLayer:getContentSize().width - 10, self.bgLayer:getContentSize().height - 25 - 120), nil)
    self.bgLayer:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition(ccp(30, 30))
    self.bgLayer:addChild(self.tv)
    
    self.tv:setMaxDisToBottomOrTop(120)
    if self.jumpType then --跳转到指定的大战页面
        local jumpHandler = self.callbackTb[self.jumpType]
        if jumpHandler then
            jumpHandler()
        end
    end
    
    if self.jumpType == nil and self.guildFuncItem then
        if otherGuideMgr.isGuiding and otherGuideMgr.curStep == 41 then --势力战入口引导
            if otherGuideMgr:checkGuide(42) == false then
                if self.tv then
                    local guideIdx = 0
                    for k, v in pairs(self.functionTb) do
                        if v.nameKey == "ltzdz_title" then
                            guideIdx = k
                            do break end
                        end
                    end
                    -- print("guideIdx----???",guideIdx)
                    local recordPoint = self.tv:getRecordPoint()
                    recordPoint.y = recordPoint.y + (guideIdx - 1) * 130
                    self.tv:recoverToRecordPoint(recordPoint)
                end
                local x, y, width, height = G_getSpriteWorldPosAndSize(self.guildFuncItem, 1)
                y = y + G_VisibleSizeHeight
                otherGuideCfg[42].clickRect = CCRectMake(x, y, width, height)
                otherGuideMgr:toNextStep()
            end
        end
    end
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function arenaTotalDialog:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return SizeOfTable(self.functionTb)
    elseif fn == "tableCellSizeForIndex" then
        local tmpSize
        tmpSize = CCSizeMake(400, 130)
        
        return tmpSize
        
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick(hd, fn, idx)
            --return self:cellClick(idx)
        end
        
        local hei = 120
        local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png", capInSet, cellClick)
        backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width - 60, hei))
        backSprie:ignoreAnchorPointForPosition(false);
        backSprie:setAnchorPoint(ccp(0, 0));
        backSprie:setTag(1000 + idx)
        backSprie:setIsSallow(false)
        backSprie:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
        cell:addChild(backSprie, 1)
        
        local iconPosX, iconPosY, iconSize = 60, backSprie:getContentSize().height / 2, 100
        local mIcon = CCSprite:createWithSpriteFrameName(self.functionTb[idx + 1].icon)
        if mIcon then
            mIcon:setAnchorPoint(ccp(0.5, 0.5))
            mIcon:setPosition(ccp(iconPosX, iconPosY))
            mIcon:setScale(iconSize / mIcon:getContentSize().width)
            backSprie:addChild(mIcon)
        end
        if(self.functionTb[idx + 1].nameKey == "plat_war_title" and platWarVoApi)then
            local status = platWarVoApi:checkStatus()
            if(status < 30)then
                local metalSp = CCSprite:createWithSpriteFrameName("RotatingEffect1.png")
                local pzArr = CCArray:create()
                for kk = 1, 20 do
                    local nameStr = "RotatingEffect"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    pzArr:addObject(frame)
                end
                local animation = CCAnimation:createWithSpriteFrames(pzArr)
                animation:setDelayPerUnit(0.1)
                local animate = CCAnimate:create(animation)
                metalSp:setScale((iconSize + 6) / metalSp:getContentSize().width)
                local repeatForever = CCRepeatForever:create(animate)
                metalSp:runAction(repeatForever)
                metalSp:setPosition(iconPosX, iconPosY)
                backSprie:addChild(metalSp, 2)
            end
        end
        
        if self.functionTb[idx + 1].type == 4 then
            local spMine = CCSprite:createWithSpriteFrameName("alien_mines3.png")
            spMine:setPosition(iconPosX, iconPosY)
            spMine:setScale(0.6)
            backSprie:addChild(spMine, 1)
        end
        
        if self.functionTb[idx + 1].type == 6 then
            local spMine = CCSprite:createWithSpriteFrameName("mainBtnFireware.png")
            spMine:setPosition(iconPosX, iconPosY)
            spMine:setScale(0.8)
            backSprie:addChild(spMine, 1)
        end
        
        local qualityLb = GetTTFLabelWrap(getlocal(self.functionTb[idx + 1].nameKey), 24, CCSizeMake(200, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
        qualityLb:setAnchorPoint(ccp(0, 0.5))
        qualityLb:setPosition(iconPosX + iconSize / 2 + 15, iconPosY)
        backSprie:addChild(qualityLb)
        
        local function callBack()
            if self.tv:getScrollEnable() == true and self.tv:getIsScrolled() == false then
                if G_checkClickEnable() == false then
                    do return end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                self.functionTb[idx + 1].callBack2()
            end
        end
        
        local menuItem = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", callBack, 11, nil, nil)
        local menu = CCMenu:createWithItem(menuItem);
        menu:setPosition(ccp(365, backSprie:getContentSize().height / 2));
        menu:setTouchPriority(-(self.layerNum - 1) * 20 - 2);
        backSprie:addChild(menu, 3);
        
        local function onSelectAll()
            if self.tv:getScrollEnable() == true and self.tv:getIsScrolled() == false then
                if G_checkClickEnable() == false then
                    do return end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                self.functionTb[idx + 1].callBack()
                if self.functionTb[idx + 1].nameKey == "ltzdz_title" then
                    if otherGuideMgr.isGuiding and otherGuideMgr.curStep == 42 then
                        otherGuideMgr:toNextStep()
                    end
                end
            end
        end
        local selectAllItem = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", onSelectAll, nil, getlocal("allianceWar_enter"), 25, 100)
        selectAllItem:setAnchorPoint(ccp(1, 0.5))
        selectAllItem:setScale(0.8)
        local lb = selectAllItem:getChildByTag(100)
        if lb then
            lb = tolua.cast(lb, "CCLabelTTF")
            lb:setFontName("Helvetica-bold")
        end
        local selectAllBtn = CCMenu:createWithItem(selectAllItem);
        selectAllBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 2);
        selectAllBtn:setPosition(ccp(backSprie:getContentSize().width - 10, backSprie:getContentSize().height / 2))
        backSprie:addChild(selectAllBtn)
        
        if self.functionTb[idx + 1].type == 3 then
            self.tipSp = CCSprite:createWithSpriteFrameName("IconTip.png")
            self.tipSp:setPosition(ccp(selectAllItem:getContentSize().width - 10, selectAllItem:getContentSize().height - 10))
            self.tipSp:setTag(11)
            self.tipSp:setVisible(false)
            selectAllItem:addChild(self.tipSp)
            if serverWarTeamVoApi:isTotalShowTip() == true then
                self.tipSp:setVisible(true)
            end
        end
        
        local item = self.functionTb[idx + 1]
        if item then
            self.tipSpTb[item.nameKey] = nil
            local tipSp = CCSprite:createWithSpriteFrameName("IconTip.png")
            tipSp:setPosition(ccp(selectAllItem:getContentSize().width - 10, selectAllItem:getContentSize().height - 10))
            selectAllItem:addChild(tipSp)
            self.tipSpTb[item.nameKey] = tipSp
            local tipFlag = self:getFunctionTipFlag(item.nameKey)
            tipSp:setVisible(tipFlag)
        end
        
        if self.functionTb[idx + 1].nameKey == "ltzdz_title" then --势力战引导处理
            if otherGuideMgr.isGuiding and otherGuideMgr.curStep == 41 then
                self.guildFuncItem = selectAllItem
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

--点击tab页签 idx:索引
function arenaTotalDialog:tabClick(idx)
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
function arenaTotalDialog:doUserHandler()
    
end

--点击了cell或cell上某个按钮
function arenaTotalDialog:cellClick(idx)
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

function arenaTotalDialog:tick()
    if self.tipSp then
        if serverWarTeamVoApi:isTotalShowTip() == true then
            self.tipSp:setVisible(true)
        else
            self.tipSp:setVisible(false)
        end
    end
    if self.tipSpTb then
        for nameKey, tipSp in pairs(self.tipSpTb) do
            local tipFlag = self:getFunctionTipFlag(nameKey)
            tipSp = tolua.cast(tipSp, "CCSprite")
            if tipSp then
                tipSp:setVisible(tipFlag)
            end
        end
    end
end

function arenaTotalDialog:getFunctionTipFlag(nameKey)
    local tipFlag = false
    if nameKey == "expedition" then
        tipFlag = expeditionVoApi:canReward()
    elseif nameKey == "arena_title" then
        tipFlag = arenaVoApi:isHaveScoreReward()
    elseif nameKey == "exerwar_title" then
        tipFlag = exerWarVoApi:isShowRedPoint()
    else
        if self.nameKeyTb and self.nameKeyTb[nameKey] and buildingVoApi.arenaTipTypeTb then
            local tipType = self.nameKeyTb[nameKey]
            local flag = buildingVoApi.arenaTipTypeTb[tipType]
            if flag == nil or flag == false then
                tipFlag = false
            else
                tipFlag = true
            end
        end
    end
    return tipFlag
end

function arenaTotalDialog:dispose()
    self.tipSp = nil
    self.expandIdx = nil
    self.jumpType = nil
    self.nameKeyTb = {}
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/serverWar2.plist")
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/localWar/localWar.plist")
    -- CCTextureCache:sharedTextureCache():removeTextureForKey("public/localWar/localWar.pvr.ccz")
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/platWar/platWarImage.plist")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/platWar/platWarImage.png")
    spriteController:removePlist("public/serverWarLocal/serverWarLocalCommon.plist")
    spriteController:removeTexture("public/serverWarLocal/serverWarLocalCommon.png")
    spriteController:removePlist("public/dimensionalWar/dimensionalWar.plist")
    spriteController:removeTexture("public/dimensionalWar/dimensionalWar.png")
    self = nil
    
end
