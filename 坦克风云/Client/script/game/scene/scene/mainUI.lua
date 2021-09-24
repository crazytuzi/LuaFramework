require "luascript/script/game/scene/scene/sceneController"
require "luascript/script/game/scene/gamedialog/allianceDialog/allianceWar/allianceWarOverviewDialog"
require "luascript/script/game/scene/gamedialog/allianceDialog/allianceWar2/allianceWar2OverviewDialog"
require "luascript/script/game/scene/gamedialog/mergerServersChangeNameDialog"

mainUI = {
    myUILayer,
    mySpriteMain,
    mySpriteLeft,
    mySpriteRight,
    mySpriteDown,
    mySpriteWorld,
    m_labelMoney,
    m_labelGold,
    m_labelR1,
    m_labelR2,
    m_labelR3,
    m_labelR4,
    m_labelLevel,
    m_menuToggle,
    m_menuToggleSmall,
    tv,
    m_luaSpTab,
    m_luaLayer,
    m_luaSp1,
    m_luaSp2,
    m_luaSp3,
    m_luaSp4,
    m_luaSp5,
    m_luaSp6,
    m_luaSp7,
    m_luaSpBuff,
    m_luaSpBuffSp1,
    m_luaSpBuffSp2,
    m_luaSpBuffSp3,
    m_skillHeigh,
    m_dis,
    m_luaTime,
    m_pointLuaSp,
    m_pointVip,
    m_menuToggleVip,
    m_vipLevel,
    m_iconScaleX,
    m_iconScaleY,
    m_dailySp,
    m_taskSp,
    m_enemyComingSp,
    m_countdownLabel,
    m_travelSp,
    m_travelTimeLabel,
    m_travelType,
    m_newsIconTab,
    m_newsNumTab,
    m_lastSearchXValue = 0,
    m_lastSearchYValue = 0,
    m_chatBg,
    m_chatBtn,
    m_labelLastType,
    m_labelLastMsg,
    m_labelLastName,
    m_bookmak,
    m_labelX,
    m_labelY,
    m_flagTab,
    needRefreshPlayerInfo = false,
    m_rankMainUI = nil,
    m_rechargeBtn,
    m_showWelcome = true,
    m_newGiftsSp,
    m_dailyRewardSp,
    m_acAndNoteSp, -- 活动和新闻图标
    dialog_acAndNote, -- 活动和公告的弹出面板
    m_leftIconTab = {},
    m_rightTopIconTab = {},
    m_isNewGuide = nil,
    m_isShowDaily = nil,
    m_newYearIcon = nil,
    m_noticeIcon = nil,
    m_helpDefendIcon = nil,
    m_helpDefendLabel = nil,
    m_signIcon = nil,
    m_functionBtnTb = nil,
    fbInviteBtnHasShow = false,
    onlinePackageBtn = nil,
    tenxunhuodongBtn = nil,
    nameLb,
    isShowNextDay = false,
    mainUIBTNTb = {},
    btnList = {},
    btnTipsList = {},
    isShowEvaluate = false,
    isShowAct = false,
    
    isClickFirstRechargeBtn = false,
    giftPushBtn = nil,
    firstRechargeBg = nil,
    firstRechargeFlicker = nil,
    m_joinAllianceSp = nil,
    
    platformAwardsFlicker = nil,
    platformAwardsBg = nil,
    isShowplatformAwards = false,
    isRequestPlatformAwards = false,
    
    m_mainTaskBg = nil, --主线任务背景
    m_mainTaskBtn = nil, --展开和收起主线任务按钮
    showMainTask = true, --主线任务是否展开
    -- mainTaskBgCanMove=true,
    isNewGuideShow = true, --是否是新手引导显示主线任务
    m_showInterval = 10, --显示时间间隔
    m_lastShowTime = 0, --上一次显示的时间
    m_lastMainTaskId = 0, --上一次显示的主线任务id
    m_lastFinish = nil, --上一次显示的主线任务是否完成
    m_mtRefresh = true, --是否重置主线任务
    isShowFundsExtract = nil, --是否显示过提取军团跨服战资金面板
    isShowFundsExtract1 = nil, --是否显示过提取群雄争霸资金面板
    m_showFriendTime = 300, --定时拉好友数据
    
    addChangename = true, --是否加载玩家改名面板
    m_showKoreaAdver = nil, --韩国广告按钮
    rewardCenterBtn = nil, --奖励中心的按钮
    rewardCenterBtnBg = nil, --奖励中心的按钮背景
    
    gloryBg = nil, --左上角繁荣度tip
    m_gloryPic = nil,
    isGloryOver = false, ----繁荣度沦陷状态判断
    gatherResLbTb = nil, --金矿系统存放采集资源的数量标签
    
    menuAllSmall = nil,
    m_haveAddDirectSign = false, --是否已经添加方向标
    m_directSign = nil, --方向标按钮，self.mainUI的子节点，tag为3001
    m_directSignItem = nil, --方向标图标
    m_distanceLabel = nil, --方向标上面的距离显示label，m_directSign的子节点，tag为3002
    
    showMiniFleetSlotFlag = false, -- 是否显示行军队列小面板
    miniFleetSlotLayer = nil, -- 行军队列缩略小面板
    miniFleetSlotTv = nil, -- 行军队列缩略的tableview
    fleetSlotTab = nil, -- 行军队列数据
    tickFleetIcon = {}, -- 用于刷新行军队列的icon
    tickFleetTimer = {}, -- 用于刷新行军队列的进度条
    slotLeftBtn = nil, --行军队列缩放按钮
    slotShowState = 0, --行军队列缩放状态，0显示，1缩放，2正在播放动画
    fleetSlotCellTb = {}, --行军队列tableview的cell
    isShowAction = false, --是否在动画
    goldButtonBtn = nil,
    rechargeFlick = nil,
    wjdcIconBg = nil, --问卷调查图标
    chatTabShowIndex = nil,
    chatPrivateReciverUid = nil,
    chatPrivateReciverName = nil,
    studySid = nil, --战机革新正在研究的技能id
    m_stewardSp = nil, --军务管家图标
    m_militaryOrdersSp = nil, --军令图标
    mysteryBoxSp = nil, --神秘宝箱图标
    flashSaleSp = nil, --限时惊喜图标
    flashSaleFlicker = nil,
}

function mainUI:initButton()
    if G_isSendAchievementToGoogle() > 0 then
        G_setIsLoginGoole()
    end
    
    --b1:关卡，b2:部队，b3:配件，b4:商店，b5:背包，b6:邮件，b7:排行榜，b8:兑换，b9:帮助，b10:官网,b11:设置 b12:军团战 b13:好友 b14:引导
    local function callback1()
        storyScene:setShow()
        if newGuidMgr:isNewGuiding() then --新手引导
            newGuidMgr:toNextStep()
        end
        local menuItem = self.m_functionBtnTb["b1"]
        if(menuItem ~= nil)then
            G_removeFlicker(menuItem)
        end
    end
    local function callback2()
        require "luascript/script/game/scene/gamedialog/warDialog/tankDefenseDialog"
        local td = tankDefenseDialog:new(3)
        local tbArr = {getlocal("fleetCard"), getlocal("dispatchCard"), getlocal("repair")}
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("defenceSetting"), true, 3)
        sceneGame:addChild(dialog, 3)
    end
    local function callback3()
        if(playerVoApi:getPlayerLevel() < accessoryCfg.accessoryUnlockLv)then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("elite_challenge_unlock_level", {accessoryCfg.accessoryUnlockLv}), 30)
        else
            local menuItem = self.m_functionBtnTb["b3"]
            if(menuItem ~= nil)then
                G_removeFlicker(menuItem)
            end
            accessoryVoApi:showAccessoryDialog(sceneGame, 3)
        end
    end
    local function callback4()
        local td = allShopVoApi:showAllPropDialog(3, "gems")
        -- local td=shopVoApi:showPropDialog(3,true)
        -- td:tabClick(1,false)
    end
    local function callback5()
        local td = shopVoApi:showPropDialog(3, true)
    end
    local function callback6()
        require "luascript/script/game/scene/gamedialog/emailDialog/emailDialog"
        require "luascript/script/game/scene/gamedialog/emailDialog/emailDialogTab1"
        require "luascript/script/game/scene/gamedialog/emailDialog/emailDialogTab2"
        require "luascript/script/game/scene/gamedialog/emailDialog/emailDialogTab3"
        local td = emailDialog:new()
        local tbArr = {getlocal("email_email"), getlocal("email_report"), getlocal("email_send")}
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("email_title"), true, 3)
        sceneGame:addChild(dialog, 3)
    end
    local function callback7()
        local rankLimitLv = 20
        if G_isMemoryServer() == true then --怀旧服排行榜开启等级为5级
            rankLimitLv = 5
        end
        if tonumber(playerVoApi:getPlayerLevel())<rankLimitLv then
            G_showTipsDialog(getlocal("rank_userInfo_alert",{rankLimitLv}))
        else
            rankVoApi:clear()
            require "luascript/script/game/scene/gamedialog/rankDialog"
            local td = rankDialog:new()
            -- local tbArr={getlocal("RankScene_power"),getlocal("RankScene_star"),getlocal("RankScene_honor")}
            local tbArr = {getlocal("RankScene_power"), getlocal("RankScene_star"), getlocal("help2_t1_t3")}
            local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("rank"), false, 3)
            sceneGame:addChild(dialog, 3)
        end
    end
    local function callback8()
        smallDialog:showCodeRewardDialog("PanelHeaderPopup.png", CCSizeMake(550, 450), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), true, 3)
    end
    local function callback9()
        if platCfg.platCfgHelpConnection[G_curPlatName()] ~= nil and platCfg.platCfgHelpConnection[G_curPlatName()][G_getCurChoseLanguage()] ~= nil then
            local url = platCfg.platCfgHelpConnection[G_curPlatName()][G_getCurChoseLanguage()]
            local tmpTb = {}
            tmpTb["action"] = "openUrlInAppWithClose"
            tmpTb["parms"] = {}
            tmpTb["parms"]["connect"] = tostring(url)
            local cjson = G_Json.encode(tmpTb)
            G_accessCPlusFunction(cjson)
        else
            require "luascript/script/game/scene/gamedialog/helpDialog"
            local dd = helpDialog:new()
            local vd = dd:init("panelBg.png", true, CCSizeMake(760, 800), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, nil, nil, getlocal("help_title"), false, 3);
            sceneGame:addChild(vd, 3)
            
        end
    end
    local function callback10()
        local tmpTb = {}
        tmpTb["action"] = "openUrlInAppWithClose"
        tmpTb["parms"] = {}
        tmpTb["parms"]["connect"] = serverCfg.officialUrl
        local cjson = G_Json.encode(tmpTb)
        G_accessCPlusFunction(cjson)
    end
    local function callback11()
        
        local tmpTb = {}
        tmpTb["action"] = "settingWindowOpen"
        tmpTb["parms"] = {}
        local cjson = G_Json.encode(tmpTb)
        G_accessCPlusFunction(cjson)
        
        require "luascript/script/game/scene/gamedialog/settingsDialog/settingsDialog"
        local td = settingsDialog:new()
        local tbArr = {}
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("options"), true, 3)
        sceneGame:addChild(dialog, 3)
    end
    local function callback12()
        if base.isAllianceWarSwitch == 0 then --军团战开关
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("backstage4012"), 30)
            do return end
        end
        local selfAlliance = allianceVoApi:getSelfAlliance()
        if(selfAlliance == nil or selfAlliance.aid <= 0)then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("allianceWar_errorNeedAlliance"), 30)
        else
            local td = allianceWarOverviewDialog:new(3)
            local tbArr = {}
            local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("alliance_war"), false, 3)
            sceneGame:addChild(dialog, 3)
        end
    end
    local function callback13()
        if self.m_showFriendTime >= 300 then
            friendInfoVo.lastGiftTime = base.serverTime
            self.m_showFriendTime = 0
            local function callback(fn, data)
                local ret, sData = base:checkServerData(data)
                if ret == true then
                    friendInfoVoApi:showDialog(3)
                end
            end
            socketHelper:friendsList(callback)
        else
            friendInfoVoApi:showDialog(3)
        end
    end
    
    local function callback14()
        require "luascript/script/game/scene/gamedialog/becomeStrongDialog"
        local td = becomeStrongDialog:new()
        local tbArr = {}
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("become_strong_title"), false, 3)
        sceneGame:addChild(dialog, 3)
    end
    --国内概率公示
    local function callback15()
        local tmpTb = {}
        tmpTb["action"] = "openUrlInAppWithClose"
        tmpTb["parms"] = {}
        if(G_curPlatName() == "android3kwan" or G_curPlatName() == "android3ktencent")then
            if G_isMemoryServer() == true then
                tmpTb["parms"]["connect"] = "http://hjtk.kkk5.com/gonggao/202001_25488.html"
            else
                tmpTb["parms"]["connect"] = "http://hjtk.kkk5.com/gonggao/201605_23090.html"
            end
        else
            if G_isMemoryServer() == true then
                tmpTb["parms"]["connect"] = "http://tk.rayjoy.com/tank/notice/2020/0107/397.html"
            else
                tmpTb["parms"]["connect"] = "http://tk.rayjoy.com/wap.php?action=article&id=263"
            end
        end
        local cjson = G_Json.encode(tmpTb)
        G_accessCPlusFunction(cjson)
    end
    
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        self.mainUIBTNTb = {b1 = {bName1 = "mainBtnCheckpoint.png", bName2 = "mainBtnCheckpoint_Down.png", btnLb = "mainCheckPoint", callback = callback1, tag = 0, sortId = 1},
            b2 = {bName1 = "mainBtnTeam.png", bName2 = "mainBtnTeam_Down.png", btnLb = "mainFleet", callback = callback2, tag = 1, sortId = 3},
            b3 = {bName1 = "mainBtnAccessory.png", bName2 = "mainBtnAccessory_Down.png", btnLb = "accessory", callback = callback3, tag = 2, sortId = 4},
            b4 = {bName1 = "mainBtnItems.png", bName2 = "mainBtnItems_Down.png", btnLb = "market", callback = callback4, tag = 3, sortId = 5},
            b5 = {bName1 = "mainBtnBag.png", bName2 = "mainBtnBag_Down.png", btnLb = "bundle", callback = callback5, tag = 4, sortId = 6},
            b6 = {bName1 = "mainBtnMail.png", bName2 = "mainBtnMail_Down.png", btnLb = "mainMail", callback = callback6, tag = 5, sortId = 7},
            b7 = {bName1 = "mainBtnRank.png", bName2 = "mainBtnRank_Down.png", btnLb = "mainRank", callback = callback7, tag = 6, sortId = 8},
            b8 = {bName1 = "mainBtnGift.png", bName2 = "mainBtnGiftDown.png", btnLb = "code_gift", callback = callback8, tag = 7, sortId = 9},
            b9 = {bName1 = "mainBtnHelp.png", bName2 = "mainBtnHelp_Down.png", btnLb = "help", callback = callback9, tag = 8, sortId = 10},
            b10 = {bName1 = "mainBtnWebsite.png", bName2 = "mainBtnWebsite_Down.png", btnLb = "officialWeb", callback = callback10, tag = 9, sortId = 11},
            b11 = {bName1 = "mainBtnSet.png", bName2 = "mainBtnSet_Down.png", btnLb = "mainOpt", callback = callback11, tag = 10, sortId = 20},
            b12 = {bName1 = "mainBtnFireware.png", bName2 = "mainBtnFireware_Down.png", btnLb = "alliance_war", callback = callback12, tag = 10, sortId = 2},
            b13 = {bName1 = "mainBtnFriend.png", bName2 = "mainBtnFriend_Down.png", btnLb = "bookmarksFriend", callback = callback13, tag = 11, sortId = 13},
            b14 = {bName1 = "mainBtnStrong.png", bName2 = "mainBtnStrong_Down.png", btnLb = "become_strong_title", callback = callback14, tag = 12, sortId = 21},
        b15 = {bName1 = "mainBtnWebsite.png", bName2 = "mainBtnWebsite_Down.png", btnLb = "probability_show_title", callback = callback15, tag = 13, sortId = 19}}
    else
        self.mainUIBTNTb = {b1 = {bName1 = "mainBtnCheckpoint1.png", bName2 = "mainBtnCheckpoint1_Down.png", btnLb = "mainCheckPoint", callback = callback1, tag = 0, sortId = 1},
            b2 = {bName1 = "mainBtnTeam1.png", bName2 = "mainBtnTeam1_Down.png", btnLb = "mainFleet", callback = callback2, tag = 1, sortId = 3},
            b3 = {bName1 = "mainBtnAccessory1.png", bName2 = "mainBtnAccessory1_Down.png", btnLb = "accessory", callback = callback3, tag = 2, sortId = 4},
            b4 = {bName1 = "mainBtnItems1.png", bName2 = "mainBtnItems1_Down.png", btnLb = "market", callback = callback4, tag = 3, sortId = 5},
            b5 = {bName1 = "mainBtnBag1.png", bName2 = "mainBtnBag1_Down.png", btnLb = "bundle", callback = callback5, tag = 4, sortId = 6},
            b6 = {bName1 = "mainBtnMail1.png", bName2 = "mainBtnMail1_Down.png", btnLb = "mainMail", callback = callback6, tag = 5, sortId = 7},
            b7 = {bName1 = "mainBtnRank1.png", bName2 = "mainBtnRank1_Down.png", btnLb = "mainRank", callback = callback7, tag = 6, sortId = 8},
            b8 = {bName1 = "mainBtnGift1.png", bName2 = "mainBtnGiftDown1.png", btnLb = "code_gift", callback = callback8, tag = 7, sortId = 9},
            b9 = {bName1 = "mainBtnHelp1.png", bName2 = "mainBtnHelp1_Down.png", btnLb = "help", callback = callback9, tag = 8, sortId = 10},
            b10 = {bName1 = "mainBtnWebsite1.png", bName2 = "mainBtnWebsite1_Down.png", btnLb = "officialWeb", callback = callback10, tag = 9, sortId = 11},
            b11 = {bName1 = "mainBtnSet1.png", bName2 = "mainBtnSet1_Down.png", btnLb = "mainOpt", callback = callback11, tag = 10, sortId = 20},
            b12 = {bName1 = "mainBtnFireware1.png", bName2 = "mainBtnFireware1_Down.png", btnLb = "alliance_war", callback = callback12, tag = 10, sortId = 2},
            b13 = {bName1 = "mainBtnFriend1.png", bName2 = "mainBtnFriend1_Down.png", btnLb = "bookmarksFriend", callback = callback13, tag = 11, sortId = 13},
            b14 = {bName1 = "mainBtnStrong1.png", bName2 = "mainBtnStrong1_Down.png", btnLb = "become_strong_title", callback = callback14, tag = 12, sortId = 21},
        b15 = {bName1 = "mainBtnWebsite1.png", bName2 = "mainBtnWebsite1_Down.png", btnLb = "probability_show_title", callback = callback15, tag = 13, sortId = 19}}
    end
    if platCfg.platCfgBMImage[G_curPlatName()] ~= nil then
        self.mainUIBTNTb.b10.btnLb = "forum"
    end
    
    -- if GM_UidCfg[playerVoApi:getUid()] then
    --     self.btnList = {"b6","b11"}
    -- else
    self.btnList = {"b1", "b2", "b4", "b5", "b6", "b7", "b8", "b9", "b11", "b12", "b13", "b14"} --要显示的按钮
    -- end
    
    if platCfg.platCfgMainUIButton[G_curPlatName()] ~= nil then
        self.btnList = platCfg.platCfgMainUIButton[G_curPlatName()]
    end
    -- if(tonumber(base.curZoneID)>900 and tonumber(base.curZoneID)<1000)then
    if(tonumber(base.curZoneID) == 999)then
        for k, v in pairs(self.btnList) do
            if(v == "b7")then
                table.remove(self.btnList, k)
                break
            end
        end
    end
    
    if G_isApplyVersion() == true then --提审服特殊处理
        for k, v in pairs(self.btnList) do
            if(v == "b6" or v == "b4")then --去掉商店和邮件
                table.remove(self.btnList, k)
            end
        end
    end
    
    if base.isCodeSwitch == 0 then --兑换开关
        for k, v in pairs(self.btnList) do
            if v == "b8" then
                table.remove(self.btnList, k)
            end
        end
    end
    if base.ifAccessoryOpen == 0 then --配件开关
        for k, v in pairs(self.btnList) do
            if v == "b3" then
                table.remove(self.btnList, k)
            end
        end
    end
    if base.isAllianceWarSwitch == 0 then --军团战开关
        for k, v in pairs(self.btnList) do
            if v == "b12" then
                table.remove(self.btnList, k)
            end
        end
    end
    
    -- 建筑优化开关
    if buildingVoApi:isYouhua() then
        for k, v in pairs(self.btnList) do
            if v == "b12" then
                table.remove(self.btnList, k)
            end
        end
    end
    if buildingVoApi:isYouhua() then
        for k, v in pairs(self.btnList) do
            if v == "b14" then
                table.remove(self.btnList, k)
            end
        end
    end
    if buildingVoApi:isYouhua() then
        for k, v in pairs(self.btnList) do
            if v == "b8" then
                table.remove(self.btnList, k)
            end
        end
    end
    --国内平台除3k之外都要加概率公示
    if(G_isChina() and tonumber(base.curZoneID) ~= 999)then
        local flag = false
        for k, v in pairs(self.btnList) do
            if(v == "b15")then
                flag = true
                break
            end
        end
        if(flag ~= true)then
            table.insert(self.btnList, "b15")
        end
    end
    
    if G_isApplyVersion() == true then --提审服特殊处理
        self.btnTipsList = {"b2", "b3", "b5"} --需要刷新tip的按钮
    else
        self.btnTipsList = {"b2", "b3", "b5", "b6"} --需要刷新tip的按钮
    end
    table.sort(self.btnList, function(a, b) return tonumber(self.mainUIBTNTb[a].sortId) < tonumber(self.mainUIBTNTb[b].sortId) end) --排序
    
end

function mainUI:showUI()
    local function callback(fn, data)
        local ret, sData = base:checkServerData(data)
    end
    socketHelper:friendsList(callback)
    
    local function refreshSlot(event, data)
        self:clearFleetSlotTv()
    end
    self.refreshSlotListener = refreshSlot
    eventDispatcher:addEventListener("attackTankSlot.refreshSlot", refreshSlot)
    
    local isGM = GM_UidCfg[playerVoApi:getUid()] and true or false
    self:initButton()
    if G_curPlatName() == "6" or G_curPlatName() == "7" or G_curPlatName() == "8" or G_curPlatName() == "23" or G_curPlatName() == "26" or G_curPlatName() == "22" then
        local tmpTb = {}
        tmpTb["action"] = "flmobClick"
        local cjson = G_Json.encode(tmpTb)
        G_accessCPlusFunction(cjson)
    end
    
    local function touch(object, name, tag)
        if self.m_menuToggle:getSelectedIndex() == 2 then
            do
                return
            end
        end
        if G_checkClickEnable() == false then
            do
                return
            end
        end
        PlayEffect(audioCfg.mouseClick)
        if tag == 1 then
            
        elseif tag == 2 then
            
        end
        
    end
    
    --世界地图UI
    -- print("===========jlkljjljj")
    self.myUILayer = CCLayer:create()
    sceneGame:addChild(self.myUILayer, 3);
    local heightPos = 5
    -- 世界地图上面信息条背景
    local function pbUIhandler()
    end
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        self.mySpriteWorld = LuaCCSprite:createWithSpriteFrameName("goldmine_bg.png", pbUIhandler)
    else
        self.mySpriteWorld = LuaCCSprite:createWithSpriteFrameName("goldmine_bg1.png", pbUIhandler)
    end
    self.mySpriteWorld:setAnchorPoint(ccp(0, 0.5));
    self.mySpriteWorld:setPosition(0, 999333);
    self.myUILayer:addChild(self.mySpriteWorld, 13);
    self.mySpriteWorld:setTouchPriority(-21)
    local function dwHandler() --定位
        PlayEffect(audioCfg.mouseClick)
        worldScene:focus(playerVoApi:getMapX(), playerVoApi:getMapY())
    end
    -- 定位图标
    local dwSprite
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        dwSprite = GetButtonItem("worldBtnPosition.png", "worldBtnPosition_Down.png", "worldBtnPosition_Down.png", dwHandler, nil, nil, nil)
    else
        dwSprite = GetButtonItem("worldBtnPosition1.png", "worldBtnPosition1_Down.png", "worldBtnPosition1_Down.png", dwHandler, nil, nil, nil)
    end
    dwSprite:setAnchorPoint(ccp(0, 1))
    local dwSpriteMenu = CCMenu:createWithItem(dwSprite);
    
    dwSpriteMenu:setTouchPriority(-22);
    self.mySpriteWorld:addChild(dwSpriteMenu)
    
    -- 定位文字
    local heightPosV2 = -4
    local dwLabel = GetTTFLabel(getlocal("world_scene_location"), 18);
    dwLabel:setAnchorPoint(ccp(0.5, 0.5))
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        dwSpriteMenu:setPosition(ccp(20, self.mySpriteWorld:getContentSize().height - 10 + heightPos))
        dwLabel:setPosition(dwSprite:getContentSize().width / 2 - 2, heightPos)
    else
        dwSpriteMenu:setPosition(ccp(20, self.mySpriteWorld:getContentSize().height - 10 + heightPos-3))
        dwLabel:setPosition(dwSprite:getContentSize().width / 2 - 1, heightPosV2)
    end
    dwSprite:addChild(dwLabel)
    local function scHandler() --收藏
        if G_checkClickEnable() == false then
            do
                return
            end
        end
        require "luascript/script/game/scene/gamedialog/bookmarkDialog"
        local layerNum = 3
        local td = bookmarkDialog:new()
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), {}, nil, nil, getlocal("collect_border_title"), false, layerNum)
        sceneGame:addChild(dialog, layerNum)
        PlayEffect(audioCfg.mouseClick)
    end
    
    local scSprite
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        scSprite = GetButtonItem("worldBtnCollection.png", "worldBtnCollection_Down.png", "worldBtnPosition_Down.png", scHandler, nil, nil, nil)
    else
        scSprite = GetButtonItem("worldBtnCollection1.png", "worldBtnCollection1_Down.png", "worldBtnPosition1_Down.png", scHandler, nil, nil, nil)
    end
    scSprite:setAnchorPoint(ccp(0, 1))
    local scSpriteMenu = CCMenu:createWithItem(scSprite);
    scSpriteMenu:setTouchPriority(-22);
    self.mySpriteWorld:addChild(scSpriteMenu)
    
    local scLabel = GetTTFLabel(getlocal("world_scene_collect"), 18)
    scLabel:setAnchorPoint(ccp(0.5, 0.5))
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        scSpriteMenu:setPosition(ccp(110, self.mySpriteWorld:getContentSize().height - 10 + heightPos))
        scLabel:setPosition(scSprite:getContentSize().width / 2 - 2, heightPos)
    else
        scSpriteMenu:setPosition(ccp(110, self.mySpriteWorld:getContentSize().height - 10 + heightPos-3))
        scLabel:setPosition(scSprite:getContentSize().width / 2 - 1, heightPosV2)
    end
    scSprite:addChild(scLabel)
    
    local function xxHandler() --信息
        PlayEffect(audioCfg.mouseClick)
        worldScene:setShowInfo()
    end
    
    local xxSprite
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        xxSprite = GetButtonItem("worldBtnInfor.png", "worldBtnInfor_Down.png", "worldBtnPosition_Down.png", xxHandler, nil, nil, nil)
    else
        xxSprite = GetButtonItem("worldBtnInfor1.png", "worldBtnInfor1_Down.png", "worldBtnPosition1_Down.png", xxHandler, nil, nil, nil)
    end
    xxSprite:setAnchorPoint(ccp(0, 1))
    local xxSpriteMenu = CCMenu:createWithItem(xxSprite);
    xxSpriteMenu:setTouchPriority(-22);
    self.mySpriteWorld:addChild(xxSpriteMenu)
    
    local xxLabel = GetTTFLabel(getlocal("world_scene_info"), 18)
    xxLabel:setAnchorPoint(ccp(0.5, 0.5))
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        xxSpriteMenu:setPosition(ccp(200, self.mySpriteWorld:getContentSize().height - 10 + heightPos))
        xxLabel:setPosition(xxSprite:getContentSize().width / 2 - 2, heightPos)
    else
        xxSpriteMenu:setPosition(ccp(200, self.mySpriteWorld:getContentSize().height - 10 + heightPos-3))
        xxLabel:setPosition(xxSprite:getContentSize().width / 2 - 1, heightPosV2)
    end
    xxSprite:addChild(xxLabel)
    
    local function syClick()
    end
    
    local xLabel = GetTTFLabel("X", 20)
    xLabel:setAnchorPoint(ccp(0, 0))
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        xLabel:setPosition(308, 35)
    else
        xLabel:setPosition(307, 31)
    end
    
    self.mySpriteWorld:addChild(xLabel)
    local function tthandler()
        
    end
    local function callBackXHandler(fn, eB, str, type)
        
        if type == 1 then --检测文本内容变化
            if str == "" then
                self.m_lastSearchXValue = playerVoApi:getMapX()
                self.m_labelX:setString(self.m_lastSearchXValue)
                do
                    return
                end
            end
            if tonumber(str) == nil then
                eB:setText(self.m_lastSearchXValue)
            else
                if tonumber(str) >= G_minMapx and tonumber(str) <= G_maxMapx then
                    self.m_lastSearchXValue = tonumber(str)
                else
                    if tonumber(str) < G_minMapx then
                        eB:setText(G_minMapx)
                        self.m_lastSearchXValue = G_minMapx
                    end
                    if tonumber(str) > G_maxMapx then
                        eB:setText(G_maxMapx)
                        self.m_lastSearchXValue = G_maxMapx
                    end
                    
                end
            end
            self.m_labelX:setString(self.m_lastSearchXValue)
        elseif type == 2 then --检测文本输入结束
            eB:setVisible(false)
        end
    end
    self.m_labelX = GetTTFLabel("", 20)
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        self.m_labelX:setPosition(ccp(368, 50))
    else
        self.m_labelX:setPosition(ccp(365, 42))
    end
    self.mySpriteWorld:addChild(self.m_labelX, 2)
    self.m_labelX:setString(playerVoApi:getMapX())
    self.m_lastSearchXValue = playerVoApi:getMapX()
    
    local editXBox
    if base.virtualKeyboard == 0 then
        local xBox
        if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
            xBox = LuaCCScale9Sprite:createWithSpriteFrameName("worldInputBg.png", CCRect(10, 10, 5, 5), tthandler)
        else
            xBox = LuaCCScale9Sprite:createWithSpriteFrameName("worldInputBg1.png", CCRect(10, 10, 5, 5), tthandler)
        end
        if G_isIOS() == true then
            if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                editXBox = CCEditBox:createForLua(CCSize(90, 50), xBox, nil, nil, callBackXHandler)
            else
                editXBox = CCEditBox:createForLua(CCSize(84, 42), xBox, nil, nil, callBackXHandler)
            end
        else
            if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                editXBox = CCEditBox:createForLua(CCSize(130, 80), xBox, nil, nil, callBackXHandler)
            else
                editXBox = CCEditBox:createForLua(CCSize(124, 72), xBox, nil, nil, callBackXHandler)
            end
        end
        if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
            editXBox:setPosition(ccp(368, 51))
            editXBox:setScale(0.9)
        else
            editXBox:setPosition(ccp(364, 42))
            editXBox:setScale(0.8)
        end

        if G_isIOS() == true then
            editXBox:setInputMode(CCEditBox.kEditBoxInputModePhoneNumber)
        else
            editXBox:setInputMode(CCEditBox.kEditBoxInputModeAny)
        end
        editXBox:setVisible(false)
        self.mySpriteWorld:addChild(editXBox, 3)
    end
    
    local xBoxBg
    local function tthandler2()
        PlayEffect(audioCfg.mouseClick)
        if base.virtualKeyboard == 1 then
            xBoxBg:setOpacity(255)
            self.m_labelX:setString("")
            require "luascript/script/componet/virtualKeyboard"
            virtualKeyboard:getInstance():show(self.m_labelX, 3, function(keyValue)
                if keyValue == virtualKeyboard_key_mapping_DELETE then
                    local curStr = self.m_labelX:getString()
                    if string.len(curStr) > 0 then
                        self.m_lastSearchXValue = tonumber(curStr)
                    end
                elseif keyValue == virtualKeyboard_key_mapping_ENTER or keyValue == virtualKeyboard_eventType_CLOSED then
                    xBoxBg:setOpacity(0)
                    local curStr = self.m_labelX:getString()
                    if string.len(curStr) == 0 then
                        self.m_lastSearchXValue = playerVoApi:getMapX()
                        self.m_labelX:setString(self.m_lastSearchXValue)
                    end
                else
                    local curStr = self.m_labelX:getString()
                    if tonumber(curStr) >= G_minMapx and tonumber(curStr) <= G_maxMapx then
                        self.m_lastSearchXValue = tonumber(curStr)
                    else
                        if tonumber(curStr) < G_minMapx then
                            self.m_lastSearchXValue = G_minMapx
                        end
                        if tonumber(curStr) > G_maxMapx then
                            self.m_lastSearchXValue = G_maxMapx
                        end
                    end
                    self.m_labelX:setString(self.m_lastSearchXValue)
                end
            end)
        else
            if editXBox then
                editXBox:setVisible(true)
            end
        end
    end
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        xBoxBg = LuaCCScale9Sprite:createWithSpriteFrameName("worldInputBg.png", CCRect(10, 10, 5, 5), tthandler2)
    else
        xBoxBg = LuaCCScale9Sprite:createWithSpriteFrameName("worldInputBg1.png", CCRect(10, 10, 5, 5), tthandler2)
    end
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        xBoxBg:setPosition(ccp(368, 60))
        xBoxBg:setContentSize(CCSize(80, 40))
    else
        xBoxBg:setPosition(ccp(364, 40))
        xBoxBg:setContentSize(CCSize(72, 30))
    end
    xBoxBg:setTouchPriority(-22)
    xBoxBg:setOpacity(0)
    self.mySpriteWorld:addChild(xBoxBg)
    
    local yLabel = GetTTFLabel("Y", 20)
    yLabel:setAnchorPoint(ccp(0, 0))
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        yLabel:setPosition(415, 35)
    else
        yLabel:setPosition(415, 31)
    end
    self.mySpriteWorld:addChild(yLabel)
    
    local function callBackYHandler(fn, eB, str, type)
        if type == 1 then --检测文本内容变化
            if str == "" then
                self.m_lastSearchYValue = playerVoApi:getMapY()
                self.m_labelY:setString(self.m_lastSearchYValue)
                do
                    return
                end
            end
            if tonumber(str) == nil then
                eB:setText(self.m_lastSearchYValue)
            else
                if tonumber(str) >= G_minMapy and tonumber(str) <= G_maxMapy then
                    self.m_lastSearchYValue = tonumber(str)
                else
                    if tonumber(str) < G_minMapy then
                        eB:setText(G_minMapy)
                        self.m_lastSearchYValue = G_minMapy
                    end
                    if tonumber(str) > G_maxMapy then
                        eB:setText(G_maxMapy)
                        self.m_lastSearchYValue = G_maxMapy
                    end
                    
                end
            end
            self.m_labelY:setString(self.m_lastSearchYValue)
        elseif type == 2 then --
            eB:setVisible(false)
        end
    end
    
    self.m_labelY = GetTTFLabel("", 20)
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        self.m_labelY:setPosition(ccp(480, 50))
    else
        self.m_labelY:setPosition(ccp(477, 42))
    end
    self.m_labelY:setString(playerVoApi:getMapY())
    self.m_lastSearchYValue = playerVoApi:getMapY()
    self.mySpriteWorld:addChild(self.m_labelY, 2)
    
    local editYBox
    if base.virtualKeyboard == 0 then
        local yBox
        if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
            yBox = LuaCCScale9Sprite:createWithSpriteFrameName("worldInputBg.png", CCRect(10, 10, 5, 5), tthandler)
        else
            yBox = LuaCCScale9Sprite:createWithSpriteFrameName("worldInputBg1.png", CCRect(10, 10, 5, 5), tthandler)
        end
        if G_isIOS() == true then
            if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                editYBox = CCEditBox:createForLua(CCSize(90, 50), yBox, nil, nil, callBackYHandler)
            else
                editYBox = CCEditBox:createForLua(CCSize(84, 42), yBox, nil, nil, callBackYHandler)
            end
        else
            if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                editYBox = CCEditBox:createForLua(CCSize(130, 80), yBox, nil, nil, callBackYHandler)
            else
                editYBox = CCEditBox:createForLua(CCSize(124, 72), yBox, nil, nil, callBackYHandler)
            end
        end
        
        if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
            editYBox:setPosition(ccp(480, 51))
            editYBox:setScale(0.9)
        else
            editYBox:setPosition(ccp(478, 42))
            editYBox:setScale(0.8)
        end
        editYBox:setVisible(false)
        if G_isIOS() == true then
            editYBox:setInputMode(CCEditBox.kEditBoxInputModePhoneNumber)
        else
            editYBox:setInputMode(CCEditBox.kEditBoxInputModeAny)
        end
        self.mySpriteWorld:addChild(editYBox, 3)
    end
    
    local yBoxBg
    local function tthandler3()
        PlayEffect(audioCfg.mouseClick)
        if base.virtualKeyboard == 1 then
            yBoxBg:setOpacity(255)
            self.m_labelY:setString("")
            require "luascript/script/componet/virtualKeyboard"
            virtualKeyboard:getInstance():show(self.m_labelY, 3, function(keyValue)
                if keyValue == virtualKeyboard_key_mapping_DELETE then
                    local curStr = self.m_labelY:getString()
                    if string.len(curStr) > 0 then
                        self.m_lastSearchYValue = tonumber(curStr)
                    end
                elseif keyValue == virtualKeyboard_key_mapping_ENTER or keyValue == virtualKeyboard_eventType_CLOSED then
                    yBoxBg:setOpacity(0)
                    local curStr = self.m_labelY:getString()
                    if string.len(curStr) == 0 then
                        self.m_lastSearchYValue = playerVoApi:getMapY()
                        self.m_labelY:setString(self.m_lastSearchYValue)
                    end
                else
                    local curStr = self.m_labelY:getString()
                    if tonumber(curStr) >= G_minMapy and tonumber(curStr) <= G_maxMapy then
                        self.m_lastSearchYValue = tonumber(curStr)
                    else
                        if tonumber(curStr) < G_minMapy then
                            self.m_lastSearchYValue = G_minMapy
                        end
                        if tonumber(curStr) > G_maxMapy then
                            self.m_lastSearchYValue = G_maxMapy
                        end
                    end
                    self.m_labelY:setString(self.m_lastSearchYValue)
                end
            end)
        else
            if editYBox then
                editYBox:setVisible(true)
            end
        end
    end
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        yBoxBg = LuaCCScale9Sprite:createWithSpriteFrameName("worldInputBg.png", CCRect(10, 10, 5, 5), tthandler3)
    else
        yBoxBg = LuaCCScale9Sprite:createWithSpriteFrameName("worldInputBg1.png", CCRect(10, 10, 5, 5), tthandler3)
    end
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        yBoxBg:setPosition(ccp(480, 60))
        yBoxBg:setContentSize(CCSize(80, 40))
    else
        yBoxBg:setPosition(ccp(478, 40))
        yBoxBg:setContentSize(CCSize(70, 30))
    end
    yBoxBg:setTouchPriority(-22)
    yBoxBg:setOpacity(0)
    self.mySpriteWorld:addChild(yBoxBg)

    --///////@cjl test
    -- local testLb = GetTTFLabel("次数：0", 35, true)
    -- local function onClickTest(tag, obj)
    --     --服务器测试扫矿次数代码
    --     local retMinX,retMinY,retMaxX,retMaxY=9999,9999,0,0
    --     local  minX,maxX,minY,maxY=worldScene:getMinAndMaxXYByAreaID(10*1000+10)
    --     if retMinX>minX then
    --         retMinX=minX
    --     end
    --     if retMinY>minY then
    --         retMinY=minY
    --     end
    --     if maxX>retMaxX then
    --         retMaxX=maxX
    --     end
    --     if maxY>retMaxY then
    --         retMaxY=maxY
    --     end
    --     self.requestFlag=self.requestFlag or true
    --     self.rcount=self.rcount or 0
    --     local function callback(fn,data)                       
    --         local retStr,retTb=base:checkServerData(data,false)
    --         self.requestFlag=true
    --         self.rcount=self.rcount+1
    --         testLb:setString(self.rcount)
    --         print("self.rcount---------->",self.rcount)
    --     end
    --     if self.requestFlag==true then
    --         print("<-----------getWorldMap----------->")
    --         local goldmineflag
    --         if base.wl == 1 and base.goldmine == 1 then
    --             goldmineflag = 1
    --         end
    --         local privatemineFlag = base.privatemine == 1 and 1 or nil
    --         --鹰眼技能
    --         local eagleEye = skillVoApi:checkEagleEyeInit()
    --         -- socketHelper:getWorldMap(retMinX,retMinY,retMaxX,retMaxY,eagleEye and nil or 1,goldmineflag,privatemineFlag,callback)
    --         socketHelper:getWorldMap(307,210,319,229,eagleEye and nil or 1,goldmineflag,privatemineFlag,callback)
    --         self.requestFlag=false
    --     end
    --     --服务器测试扫矿次数代码结束
    -- end
    -- local testBtn = GetButtonItem("yh_BigBtnBlue.png", "yh_BigBtnBlue_Down.png", "yh_BigBtnBlue.png", onClickTest, nil, "扫矿外挂测试", 24)
    -- local testMenu = CCMenu:createWithItem(testBtn)
    -- testMenu:setPosition(ccp(0, 0))
    -- testMenu:setTouchPriority(-9999)
    -- self.mySpriteWorld:addChild(testMenu, 99999)
    -- testBtn:setAnchorPoint(ccp(1, 1))
    -- testBtn:setPosition(ccp(600, -50))
    -- testLb:setAnchorPoint(ccp(1, 0.5))
    -- testLb:setPosition(ccp(testBtn:getPositionX() - testBtn:getContentSize().width - 15, testBtn:getPositionY()))
    -- self.mySpriteWorld:addChild(testLb, 99999)
    --///////@cjl test

    local function ssHandler() --搜索
        PlayEffect(audioCfg.mouseClick)
        worldScene:focus(self.m_lastSearchXValue, self.m_lastSearchYValue)
        worldBaseVoApi:setSearchFlag(true)
    end
    
    local ssSprite
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        ssSprite = GetButtonItem("worldBtnSearch.png", "worldBtnSearch_Down.png", "worldBtnPosition_Down.png", ssHandler, nil, nil, nil)
        ssSprite:setAnchorPoint(ccp(0, 1))
    else
        ssSprite = GetButtonItem("worldBtnSearch1.png", "worldBtnSearch1_Down.png", "worldBtnPosition1_Down.png", ssHandler, nil, nil, nil)
    end
    
    local ssSpriteMenu = CCMenu:createWithItem(ssSprite);
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        ssSpriteMenu:setPosition(ccp(540, self.mySpriteWorld:getContentSize().height - 10 + heightPos))
    else
        ssSpriteMenu:setPosition(ccp(590, self.mySpriteWorld:getContentSize().height - 10 + heightPos-35))
    end
    ssSpriteMenu:setTouchPriority(-23);
    self.mySpriteWorld:addChild(ssSpriteMenu)
    
    if base.wl == 1 and base.goldmine == 1 then
        --世界地图上采集资源的条
        self.gatherResLbTb = {}
        local function showCollectResDialog()
            require "luascript/script/game/scene/gamedialog/mineSmallDialog"
            local layerNum = 3
            if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                smallDialog:showMineGatherDialog("TaskHeaderBg.png", CCSizeMake(500, 700), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, true, true, layerNum)
            else
                smallDialog:showMineGatherDialog("TaskHeaderBg1.png", CCSizeMake(500, 700), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, true, true, layerNum)
            end
        end
        local resBarSprite
        if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
            resBarSprite = GetButtonItem("goldmine_res_bg.png", "goldmine_res_down.png", "goldmine_res_bg.png", showCollectResDialog, nil, nil, nil)
        else
            resBarSprite = GetButtonItem("goldmine_res_bg1.png", "goldmine_res_bg1.png", "goldmine_res_bg1.png", showCollectResDialog, nil, nil, nil, nil,CCRect(1, 20, 1, 1),CCSizeMake(G_VisibleSizeWidth,42))
        end
        local barMenu = CCMenu:createWithItem(resBarSprite);
        barMenu:setTouchPriority(-21);
        resBarSprite:setAnchorPoint(ccp(0, 1));
        barMenu:setPosition(0, 0);
        barMenu:setTag(1)
        self.mySpriteWorld:addChild(barMenu)
        
        local barWidth = resBarSprite:getContentSize().width - 40
        
        local resTb, resCount = goldMineVoApi:getGatherResList()
        local spaceX = tonumber(barWidth / resCount)
        local resindex = 0
        for k, v in pairs(resTb) do
            local resType = k
            for key, res in pairs(v) do
                local picName = nil
                local scale = 1
                local offsetX = 0
                local offsetY = 0
                if resType == "u" then
                    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                        picName = G_getResourceIcon(key)
                        if key == "gems" then
                            offsetX = 10
                        end
                    else
                        picName = "IconGold_mainUI.png"
                        if key == "gems" then
                            offsetX = -30
                        end
                    end
                elseif resType == "r" then
                    local id = RemoveFirstChar(key)
                    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                        picName = "alien_mines"..id.."_"..id..".png"
                        scale = 0.5
                    else
                        picName = "alien_mines"..id.."_"..id.."_1.png"
                        scale = 1
                    end
                    
                    offsetX = -30
                    if key == "r2" or key == "r3" then
                        scale = 0.4
                        offsetX = -5
                    end
                    if key == "r1" then
                        if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                            offsetY = 3
                        end
                    end
                    if key == "r3" then
                        offsetY = -2
                    end
                end
                if picName then
                    local resPic = CCSprite:createWithSpriteFrameName(picName)
                    resPic:setAnchorPoint(ccp(0, 0.5))
                    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                        resPic:setPosition(ccp(20 + resindex * spaceX + offsetX, resBarSprite:getContentSize().height / 2 + offsetY))
                        resPic:setScale(scale)
                    else
                        resPic:setPosition(ccp(20 + resindex * spaceX + offsetX+20, resBarSprite:getContentSize().height / 2 + offsetY))
                        if key~="gems" then
                            local resourcesLine = CCSprite:createWithSpriteFrameName("resourcesLine.png")
                            resourcesLine:setAnchorPoint(ccp(0,0.5))
                            resourcesLine:setPosition(ccp(resPic:getPositionX()-5,resBarSprite:getContentSize().height / 2))
                            resBarSprite:addChild(resourcesLine)
                        end
                    end
                    
                    resBarSprite:addChild(resPic)
                    local color = G_ColorWhite
                    if res.cur >= res.max then
                        res.cur = res.max
                        color = G_ColorRed
                    end
                    local resLb = GetTTFLabel(FormatNumber(res.cur), 20)
                    resLb:setAnchorPoint(ccp(0, 0.5))
                    resLb:setPosition(ccp(resPic:getPositionX() + resPic:getContentSize().width * resPic:getScaleX(), resBarSprite:getContentSize().height / 2))
                    resLb:setColor(color)
                    resBarSprite:addChild(resLb, 5)
                    table.insert(self.gatherResLbTb, {resLb = resLb, type = resType, key = key})
                    resindex = resindex + 1
                end
            end
        end
    end
    
    --世界地图上面的小地图
    self:addMiniMap()
    local ssLabel
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        ssLabel = GetTTFLabel(getlocal("world_scene_search"), 18);
        ssLabel:setAnchorPoint(ccp(0.5, 0.5))
        ssLabel:setPosition(ssSprite:getContentSize().width / 2, heightPos)
        ssSprite:addChild(ssLabel)
    end
    -- 基地ui
    
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        self.mySpriteMain = LuaCCSprite:createWithSpriteFrameName("mainUiTop.png", touch);
    else
        self.mySpriteMain = LuaCCScale9Sprite:createWithSpriteFrameName("mainUiTop1.png", CCRect(5, 5, 2, 2), touch)
        self.mySpriteMain:setContentSize(CCSizeMake(G_VisibleSizeWidth,107))
    end

    self.mySpriteMain:setAnchorPoint(ccp(0, 1));
    self.mySpriteMain:setPosition(ccp(0, G_VisibleSizeHeight))
    self.myUILayer:addChild(self.mySpriteMain, 13);
    
    local function pushLeft()
        
        if self.m_menuToggle:getSelectedIndex() == 2 then --or isGM
            do
                return
            end
        end
        if G_checkClickEnable() == false then
            do
                return
            end
        end
        PlayEffect(audioCfg.mouseClick)
        if newGuidMgr:isNewGuiding() and newGuidMgr.curStep == 43 then --新手引导
            do
                return
            end
        end
        
        -- local td=playerDialog:new(1,3)
        -- local tbArr={getlocal("playerInfo"),getlocal("skillTab"),getlocal("buildingTab")}
        -- local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("playerRole"),true,3)
        -- sceneGame:addChild(dialog,3)
        local td = playerVoApi:showPlayerDialog(1, 3)
        
        if platCfg.platNewGuideVersion[G_curPlatName()] == 1 then
            if newGuidMgr:getSign() == 15 then
                td:tabClick(1)
            end
        end
        
        if newGuidMgr:isNewGuiding() and newGuidMgr.curStep ~= 43 then --新手引导
            newGuidMgr:toNextStep()
        end
    end
    -- 玩家基础信息框
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        self.mySpriteLeft = GetButtonItem("mainUiTop_topLeft.png", "mainUiTop_topLeft_down.png", "mainUiTop_topLeft_down.png", pushLeft, nil, nil, nil)
    else
        self.mySpriteLeft = GetButtonItem("mainUiTop_topLeft1.png", "mainUiTop_topLeft1_down.png", "mainUiTop_topLeft1_down.png", pushLeft, nil, nil, nil)
    end
    local leftMenu = CCMenu:createWithItem(self.mySpriteLeft);
    leftMenu:setTouchPriority(-21);
    self.mySpriteLeft:setAnchorPoint(ccp(0, 1));
    leftMenu:setPosition(0, self.mySpriteMain:getContentSize().height);
    leftMenu:setTag(1)
    self.mySpriteMain:addChild(leftMenu)
    
    local function pushRight()
        if self.m_menuToggle:getSelectedIndex() == 2 then --or isGM
            do
                return
            end
        end
        if G_checkClickEnable() == false then
            do
                return
            end
        end
        PlayEffect(audioCfg.mouseClick)
        if newGuidMgr:isNewGuiding() and (newGuidMgr.curStep == 36 or newGuidMgr.curStep == 26) then --新手引导
            do
                return
            end
        end
        require "luascript/script/game/scene/gamedialog/isLandStateDialog"
        local td = isLandStateDialog:new()
        local tbArr = {getlocal("resource"), getlocal("state")}
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("islandState"), true, 3)
        sceneGame:addChild(dialog, 3)
        if newGuidMgr:isNewGuiding() then --新手引导
            newGuidMgr:toNextStep()
        end
        
    end
    -- 资源信息条
    local rightMenu
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        self.mySpriteRight = GetButtonItem("mainUiTop_bottom.png", "mainUiTop_bottom_down.png", "mainUiTop_bottom.png", pushRight, nil, nil, nil)
        rightMenu = CCMenu:createWithItem(self.mySpriteRight);
        self.mySpriteRight:setAnchorPoint(ccp(0, 0));
        rightMenu:setPosition(0, 0);
    else
        self.mySpriteRight = GetButtonItem("mainUiTop_bottom1.png", "mainUiTop_bottom1_down.png", "mainUiTop_bottom1.png", pushRight, nil, nil, nil)
        rightMenu = CCMenu:createWithItem(self.mySpriteRight);
        self.mySpriteRight:setAnchorPoint(ccp(1, 0));
        rightMenu:setPosition(G_VisibleSizeWidth, -6);
    end
    rightMenu:setTouchPriority(-21);

    rightMenu:setTag(1)
    self.mySpriteMain:addChild(rightMenu)
    -- 金币按钮
    local function showRechargeDialog()
        
        if newGuidMgr:isNewGuiding() then --or isGM
            do return end
        end
        if G_checkClickEnable() == false then
            do
                return
            end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        -- if base.isPayOpen==0 then
        --   smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("betaNoRecharge"),28)
        --   do return end
        -- end
        vipVoApi:showRechargeDialog(3)
    end
    
    local goldButton,spcSp
    local spcArr = CCArray:create()
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        goldButton = GetButtonItem("mainUiTop_topRight.png", "mainUiTop_topRight_down.png", "mainUiTop_topRight.png", showRechargeDialog, nil, nil, nil)
        spcSp = CCSprite:createWithSpriteFrameName("buy_light_0.png")
        for kk = 0, 11 do
            local nameStr = "buy_light_"..kk..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            spcArr:addObject(frame)
        end
    else
        goldButton = GetButtonItem("mainUiTop_topRight1.png", "mainUiTop_topRight1_down.png", "mainUiTop_topRight1.png", showRechargeDialog, nil, nil, nil)
        spcSp = CCSprite:createWithSpriteFrameName("buy_light_0_1.png")
        for kk = 0, 13 do
            local nameStr = "buy_light_"..kk.."_1.png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            local blendFunc = ccBlendFunc:new()
            blendFunc.src = GL_ONE
            blendFunc.dst = GL_ONE
            spcSp:setBlendFunc(blendFunc)
            spcArr:addObject(frame)
        end
    end
    
    local animation = CCAnimation:createWithSpriteFrames(spcArr)
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        animation:setDelayPerUnit(0.06)
    else
        animation:setDelayPerUnit(0.08)
    end
    local animate = CCAnimate:create(animation)
    spcSp:setAnchorPoint(ccp(0.5, 0.5))
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        spcSp:setPosition(ccp(goldButton:getContentSize().width / 2, goldButton:getContentSize().height / 2))
    else
        spcSp:setPosition(ccp(goldButton:getContentSize().width / 2-1.5, goldButton:getContentSize().height / 2))
    end
    goldButton:addChild(spcSp)
    local delayAction = CCDelayTime:create(7)
    local seq = CCSequence:createWithTwoActions(animate, delayAction)
    local repeatForever = CCRepeatForever:create(seq)
    spcSp:runAction(repeatForever)
    
    local goldMenu = CCMenu:createWithItem(goldButton);
    goldMenu:setTouchPriority(-21);
    goldButton:setAnchorPoint(ccp(1, 1));
    
    if G_checkUseAuditUI() == true then
        self.m_labelMoney = GetTTFLabel(FormatNumber(playerVoApi:getGems()), 20, true); --isGM and 0 or
        self.m_labelMoney:setAnchorPoint(ccp(0.5, 0));
        self.m_labelMoney:setPosition(ccp(goldButton:getContentSize().width / 2 + 25, goldButton:getContentSize().height / 2 - 10));
        goldButton:addChild(self.m_labelMoney, 6);
        
        local goldSp = CCSprite:createWithSpriteFrameName("IconGold.png");
        goldSp:setScale(1.6)
        goldSp:setAnchorPoint(ccp(1, 0.5));
        goldSp:setPosition(ccp(2, self.m_labelMoney:getContentSize().height / 2));
        self.m_labelMoney:addChild(goldSp);
        goldMenu:setPosition(self.mySpriteMain:getContentSize().width, self.mySpriteMain:getContentSize().height);
    elseif G_getGameUIVer()==1 then
        self.m_labelMoney = GetTTFLabel(FormatNumber(playerVoApi:getGems()), 20, true); --isGM and 0 or
        self.m_labelMoney:setAnchorPoint(ccp(0.5, 0));
        self.m_labelMoney:setPosition(ccp(goldButton:getContentSize().width / 2 + 12, goldButton:getContentSize().height / 2 + 2));
        goldButton:addChild(self.m_labelMoney, 6);
        
        local goldSp = CCSprite:createWithSpriteFrameName("IconGold.png");
        goldSp:setAnchorPoint(ccp(1, 0.5));
        goldSp:setPosition(ccp(0, self.m_labelMoney:getContentSize().height / 2));
        self.m_labelMoney:addChild(goldSp);
        
        local getGoldLb = GetTTFLabel(getlocal("getGold"), 20, true);
        getGoldLb:setAnchorPoint(ccp(0.5, 1))
        getGoldLb:setPosition(ccp(goldButton:getContentSize().width / 2, goldButton:getContentSize().height / 2 - 2));
        goldButton:addChild(getGoldLb, 6);
        self.goldButtonBtn = goldButton
        goldMenu:setPosition(self.mySpriteMain:getContentSize().width, self.mySpriteMain:getContentSize().height);
    else
        self.m_labelMoney = GetTTFLabel(FormatNumber(playerVoApi:getGems()), 22); --isGM and 0 or
        self.m_labelMoney:setAnchorPoint(ccp(0.5, 0.5));
        self.m_labelMoney:setPosition(ccp(goldButton:getContentSize().width / 2 + 16, goldButton:getContentSize().height / 2 ));
        goldButton:addChild(self.m_labelMoney, 6);
        
        local goldSp = CCSprite:createWithSpriteFrameName("IconGold_mainUI.png");
        goldSp:setAnchorPoint(ccp(1, 0.5));
        goldSp:setPosition(ccp(-4, self.m_labelMoney:getContentSize().height / 2));
        self.m_labelMoney:addChild(goldSp);
        
        self.goldButtonBtn = goldButton
        goldMenu:setPosition(self.mySpriteMain:getContentSize().width-4, self.mySpriteMain:getContentSize().height);
    end
    
    
    goldMenu:setTag(1)
    self.mySpriteMain:addChild(goldMenu)
    
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        self.mySpriteDown = LuaCCSprite:createWithSpriteFrameName("mainUiBottom.png", touch);
    else
        self.mySpriteDown = LuaCCSprite:createWithSpriteFrameName("mainUiBottom1.png", touch);
    end
    local downBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), function ()end)
    downBg:setContentSize(CCSizeMake(self.mySpriteDown:getContentSize().width, self.mySpriteDown:getContentSize().height - 8))
    downBg:setAnchorPoint(ccp(0.5, 0));
    downBg:setPosition(G_VisibleSizeWidth / 2, 0);
    self.myUILayer:addChild(downBg, 2);
    -- 场景下方信息条的背景框
    -- self.mySpriteDown = LuaCCSprite:createWithSpriteFrameName("mainUiBottom.png",touch);
    self.mySpriteDown:setAnchorPoint(ccp(0.5, 0));
    self.mySpriteDown:setPosition(G_VisibleSizeWidth / 2, 0);
    self.myUILayer:addChild(self.mySpriteDown, 2);
    self.mySpriteDown:setTouchPriority(-21);
    
    --聊天
    
    local function chatHandler()
        if G_checkClickEnable() == false then
            do
                return
            end
        end
        if newGuidMgr:isNewGuiding() == true then
            do return end
        end
        local layerNum = 3
        if chatVoApi:getUnReadCount(2) > 0 then
            chatVoApi:showChatDialog(layerNum, 2, nil, nil, true)
        else
            chatVoApi:showChatDialog(layerNum, self.chatTabShowIndex, self.chatPrivateReciverUid, self.chatPrivateReciverName)
        end
    end
    local chatSpriteMenu
    if G_checkUseAuditUI() == true then
        self.m_chatBtn = GetButtonItem("newFrChat.png", "newFrChat_down.png", "newFrChat.png", chatHandler, nil, nil, nil)
        self.m_chatBtn:setAnchorPoint(ccp(1, 0))
        chatSpriteMenu = CCMenu:createWithItem(self.m_chatBtn)
        self.m_chatBtn:setScale(1.1)
        chatSpriteMenu:setPosition(ccp(G_VisibleSizeWidth, self.mySpriteDown:getContentSize().height + 3))
        chatSpriteMenu:setTouchPriority(-21)
        self.myUILayer:addChild(chatSpriteMenu, 3)
    elseif G_getGameUIVer()==1 then
        self.m_chatBtn = GetButtonItem("newFrChat.png", "newFrChat_down.png", "newFrChat.png", chatHandler, nil, nil, nil)
        self.m_chatBtn:setAnchorPoint(ccp(1, 0))
        chatSpriteMenu = CCMenu:createWithItem(self.m_chatBtn)
        chatSpriteMenu:setPosition(ccp(G_VisibleSizeWidth, self.mySpriteDown:getContentSize().height - 1))
        chatSpriteMenu:setTouchPriority(-21)
        self.myUILayer:addChild(chatSpriteMenu, 3)
    else
        -- self.m_chatBtn = GetButtonItem("newFrChat1.png", "newFrChat1_down.png", "newFrChat1.png", chatHandler, nil, nil, nil)
        -- self.m_chatBtn:setAnchorPoint(ccp(1, 0))
        -- chatSpriteMenu = CCMenu:createWithItem(self.m_chatBtn)
        -- chatSpriteMenu:setPosition(ccp(G_VisibleSizeWidth, self.mySpriteDown:getContentSize().height - 2.5))
    end

    
    
    local function nilFunc(...)
        
    end
    local newsIcon
    if G_checkUseAuditUI() == true or G_getGameUIVer()==1 then
        newsIcon = LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png", CCRect(17, 17, 1, 1), nilFunc)
        newsIcon:setScale(0.7)
    else
        newsIcon = LuaCCScale9Sprite:createWithSpriteFrameName("NumBg1.png", CCRect(17, 17, 1, 1), nilFunc)
        newsIcon:setScale(0.6)
    end
    newsIcon:setContentSize(CCSizeMake(36, 36))
    newsIcon:ignoreAnchorPointForPosition(false)
    newsIcon:setAnchorPoint(ccp(0.5, 0.5))
    newsIcon:setPosition(ccp(G_VisibleSizeWidth - 15, self.mySpriteDown:getContentSize().height + 53))
    newsIcon:setVisible(false)
    self.myUILayer:addChild(newsIcon, 4)
    self.newsIcon = newsIcon
    
    local num = chatVoApi:getUnReadCount(2) > 99 and 99 or chatVoApi:getUnReadCount(2)
    local numLb = GetTTFLabel(num, 18, true)
    numLb:setAnchorPoint(ccp(0.5, 0.5))
    numLb:setPosition(G_VisibleSizeWidth - 15, self.mySpriteDown:getContentSize().height + 53)
    self.myUILayer:addChild(numLb, 5)
    numLb:setVisible(false)
    self.numLb = numLb
    
    local chatSprite
    if G_checkUseAuditUI() == true then
        chatSprite = CCSprite:createWithSpriteFrameName("newFr.png")
        chatSprite:setScale(1.1)
        chatSprite:setPosition(ccp(G_VisibleSizeWidth - 44, self.mySpriteDown:getContentSize().height + 26))
    elseif G_getGameUIVer()==1 then
        chatSprite = CCSprite:createWithSpriteFrameName("newFr.png")
        chatSprite:setPosition(ccp(G_VisibleSizeWidth - 55, self.mySpriteDown:getContentSize().height + 25))
    else
        chatSprite = CCSprite:createWithSpriteFrameName("newFr1.png")
        chatSprite:setPosition(ccp(G_VisibleSizeWidth - 34, self.mySpriteDown:getContentSize().height + 20))
    end
    chatSprite:setAnchorPoint(ccp(0.5, 0.5))
    self.chatSprite = chatSprite
    self.myUILayer:addChild(chatSprite, 3)
    self:refreshRedpoint()
    
    local function openNewFriend(...)
        friendInfoVoApi:showDialog(3)
    end
    local newFriendTipSprite = LuaCCSprite:createWithSpriteFrameName("newFrTip.png", openNewFriend)
    newFriendTipSprite:setAnchorPoint(ccp(0.5, 0.5))
    newFriendTipSprite:setPosition(ccp(G_VisibleSizeWidth, 330))
    newFriendTipSprite:setTouchPriority(-21)
    self.myUILayer:addChild(newFriendTipSprite, 3)
    self.newFriendTipSprite = newFriendTipSprite
    newFriendTipSprite:setVisible(false)
    
    -- self.m_chatBg = LuaCCSprite:createWithSpriteFrameName("mainChatBg.png",chatHandler)
    if G_checkUseAuditUI() == true or G_getGameUIVer()==1 then
        self.m_chatBg = LuaCCScale9Sprite:createWithSpriteFrameName("cin_mainChatBgSmall.png", CCRect(4, 25, 2, 4), chatHandler)
        self.m_chatBg:setContentSize(CCSizeMake(535 + 105, 58))
    else
        self.m_chatBg = LuaCCScale9Sprite:createWithSpriteFrameName("cin_mainChatBgSmall1.png", CCRect(4, 25, 2, 4), chatHandler)
        self.m_chatBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, 51))
    end
    self.m_chatBg:setAnchorPoint(ccp(0, 0))
    local chatTopLine_tishen
    if G_checkUseAuditUI() == true then
        self.m_chatBg:setPosition(0, self.mySpriteDown:getContentSize().height)
        chatTopLine_tishen = CCSprite:createWithSpriteFrameName("chatTopLine_tishen.png")
        chatTopLine_tishen:setAnchorPoint(ccp(0, 1))
        chatTopLine_tishen:setPosition(ccp(0, self.m_chatBg:getContentSize().height))
        self.m_chatBg:addChild(chatTopLine_tishen)
        self.m_chatBg:setOpacity(255 * 0.8)
        self.myUILayer:addChild(self.m_chatBg, 2)
    elseif G_getGameUIVer()==1 then
        self.m_chatBg:setPosition(0, self.mySpriteDown:getContentSize().height)
        self.m_chatBg:setOpacity(255 * 0.8)
        self.myUILayer:addChild(self.m_chatBg, 2)
    else
        self.m_chatBg:setPosition(0, self.mySpriteDown:getContentSize().height-5)
        self.myUILayer:addChild(self.m_chatBg, 1)
    end
    self.m_chatBg:setTouchPriority(-21)
    
    self:setLastChat()
    
    if base.mailBlackList == 1 then
        local function initCallback()
            chatVoApi:filterPlayer()
            self:setLastChat()
        end
        G_initBlackList(initCallback)
    end
    
    --右边板子 label  资源进度条
    local r1P, r2P, r3P, r4P, rGP = buildingVoApi:getResourcePercent();
    
    local lbSize = 20
    if G_checkUseAuditUI() == true or G_getGameUIVer()==1 then
        AddProgramTimer(self.mySpriteRight, ccp(94, 93), 9, nil, nil, nil, "resourceBar.png");
        local moneyTimerSprite = tolua.cast(self.mySpriteRight:getChildByTag(9), "CCProgressTimer")
        moneyTimerSprite:setPercentage(0);
        
        AddProgramTimer(self.mySpriteRight, ccp(84, 34), 10, nil, nil, nil, "resourceBar.png");
        local goldTimerSprite = tolua.cast(self.mySpriteRight:getChildByTag(10), "CCProgressTimer")
        goldTimerSprite:setPercentage(rGP);
        
        self.m_labelGold = GetTTFLabel(FormatNumber(playerVoApi:getGold()), lbSize, true); --isGM and 0 or
        self.m_labelGold:setAnchorPoint(ccp(0.5, 0.5));
        self.m_labelGold:setPosition(getCenterPoint(goldTimerSprite));
        self.m_labelGold:setColor(G_ColorWhite);
        goldTimerSprite:addChild(self.m_labelGold, 5);
        
        AddProgramTimer(self.mySpriteRight, ccp(208, 34), 11, nil, nil, nil, "resourceBar.png");
        local r1TimerSprite = tolua.cast(self.mySpriteRight:getChildByTag(11), "CCProgressTimer")
        r1TimerSprite:setPercentage(r1P);
        
        self.m_labelR1 = GetTTFLabel(FormatNumber(playerVoApi:getR1()), lbSize, true); --isGM and 0 or
        self.m_labelR1:setAnchorPoint(ccp(0.5, 0.5));
        self.m_labelR1:setPosition(getCenterPoint(r1TimerSprite));
        r1TimerSprite:addChild(self.m_labelR1, 5);
        
        AddProgramTimer(self.mySpriteRight, ccp(332, 34), 12, nil, nil, nil, "resourceBar.png");
        local r2TimerSprite = tolua.cast(self.mySpriteRight:getChildByTag(12), "CCProgressTimer")
        r2TimerSprite:setPercentage(r2P);
        
        self.m_labelR2 = GetTTFLabel(FormatNumber(playerVoApi:getR2()), lbSize, true); --isGM and 0 or
        self.m_labelR2:setAnchorPoint(ccp(0.5, 0.5));
        self.m_labelR2:setPosition(getCenterPoint(r2TimerSprite));
        self.m_labelR2:setColor(G_ColorWhite);
        r2TimerSprite:addChild(self.m_labelR2, 5);
        
        AddProgramTimer(self.mySpriteRight, ccp(456, 34), 13, nil, nil, nil, "resourceBar.png");
        local r3TimerSprite = tolua.cast(self.mySpriteRight:getChildByTag(13), "CCProgressTimer")
        r3TimerSprite:setPercentage(r3P);
        
        self.m_labelR3 = GetTTFLabel(FormatNumber(playerVoApi:getR3()), lbSize, true); --isGM and 0 or
        self.m_labelR3:setAnchorPoint(ccp(0.5, 0.5));
        self.m_labelR3:setPosition(getCenterPoint(r3TimerSprite));
        self.m_labelR3:setColor(G_ColorWhite);
        r3TimerSprite:addChild(self.m_labelR3, 5);
        
        AddProgramTimer(self.mySpriteRight, ccp(579, 34), 14, nil, nil, nil, "resourceBar.png");
        local r4TimerSprite = tolua.cast(self.mySpriteRight:getChildByTag(14), "CCProgressTimer")
        r4TimerSprite:setPercentage(r4P);
        
        self.m_labelR4 = GetTTFLabel(FormatNumber(playerVoApi:getR4()), lbSize, true); --isGM and 0 or
        self.m_labelR4:setAnchorPoint(ccp(0.5, 0.5));
        self.m_labelR4:setPosition(getCenterPoint(r4TimerSprite));
        self.m_labelR4:setColor(G_ColorWhite);
        r4TimerSprite:addChild(self.m_labelR4, 5);
    else
        lbSize = 17
        AddProgramTimer(self.mySpriteRight, ccp(94, 93), 9, nil, nil, nil, "resourceBar1.png");
        local moneyTimerSprite = tolua.cast(self.mySpriteRight:getChildByTag(9), "CCProgressTimer")
        moneyTimerSprite:setPercentage(0);
        
        AddProgramTimer(self.mySpriteRight, ccp(53, 16), 10, nil, nil, nil, "resourceBar1.png");
        local goldTimerSprite = tolua.cast(self.mySpriteRight:getChildByTag(10), "CCProgressTimer")
        goldTimerSprite:setPercentage(rGP);
        
        self.m_labelGold = GetTTFLabel(FormatNumber(playerVoApi:getGold()), lbSize); --isGM and 0 or
        self.m_labelGold:setAnchorPoint(ccp(0.5, 0.5));
        self.m_labelGold:setPosition(ccp(goldTimerSprite:getContentSize().width/2+10,goldTimerSprite:getPositionY()+2));
        self.m_labelGold:setColor(G_ColorWhite);
        goldTimerSprite:addChild(self.m_labelGold, 5);
        
        AddProgramTimer(self.mySpriteRight, ccp(160, 16), 11, nil, nil, nil, "resourceBar1.png");
        local r1TimerSprite = tolua.cast(self.mySpriteRight:getChildByTag(11), "CCProgressTimer")
        r1TimerSprite:setPercentage(r1P);
        
        self.m_labelR1 = GetTTFLabel(FormatNumber(playerVoApi:getR1()), lbSize); --isGM and 0 or
        self.m_labelR1:setAnchorPoint(ccp(0.5, 0.5));
        self.m_labelR1:setPosition(ccp(r1TimerSprite:getContentSize().width/2+10,r1TimerSprite:getPositionY()+2));
        r1TimerSprite:addChild(self.m_labelR1, 5);
        
        AddProgramTimer(self.mySpriteRight, ccp(263, 16), 12, nil, nil, nil, "resourceBar1.png");
        local r2TimerSprite = tolua.cast(self.mySpriteRight:getChildByTag(12), "CCProgressTimer")
        r2TimerSprite:setPercentage(r2P);
        
        self.m_labelR2 = GetTTFLabel(FormatNumber(playerVoApi:getR2()), lbSize); --isGM and 0 or
        self.m_labelR2:setAnchorPoint(ccp(0.5, 0.5));
        self.m_labelR2:setPosition(ccp(r2TimerSprite:getContentSize().width/2+10,r2TimerSprite:getPositionY()+2));
        self.m_labelR2:setColor(G_ColorWhite);
        r2TimerSprite:addChild(self.m_labelR2, 5);
        
        AddProgramTimer(self.mySpriteRight, ccp(370, 16), 13, nil, nil, nil, "resourceBar1.png");
        local r3TimerSprite = tolua.cast(self.mySpriteRight:getChildByTag(13), "CCProgressTimer")
        r3TimerSprite:setPercentage(r3P);
        
        self.m_labelR3 = GetTTFLabel(FormatNumber(playerVoApi:getR3()), lbSize); --isGM and 0 or
        self.m_labelR3:setAnchorPoint(ccp(0.5, 0.5));
        self.m_labelR3:setPosition(ccp(r3TimerSprite:getContentSize().width/2+10,r3TimerSprite:getPositionY()+2));
        self.m_labelR3:setColor(G_ColorWhite);
        r3TimerSprite:addChild(self.m_labelR3, 5);
        
        AddProgramTimer(self.mySpriteRight, ccp(478, 16), 14, nil, nil, nil, "resourceBar1.png");
        local r4TimerSprite = tolua.cast(self.mySpriteRight:getChildByTag(14), "CCProgressTimer")
        r4TimerSprite:setPercentage(r4P);
        
        self.m_labelR4 = GetTTFLabel(FormatNumber(playerVoApi:getR4()), lbSize); --isGM and 0 or
        self.m_labelR4:setAnchorPoint(ccp(0.5, 0.5));
        self.m_labelR4:setPosition(ccp(r4TimerSprite:getContentSize().width/2+10,r4TimerSprite:getPositionY()+2));
        self.m_labelR4:setColor(G_ColorWhite);
        r4TimerSprite:addChild(self.m_labelR4, 5);
    end

    
    if G_checkUseAuditUI() == true then
        self.m_labelGold:setPosition(ccp(goldTimerSprite:getContentSize().width / 2, goldTimerSprite:getContentSize().height / 2 + 6))
        self.m_labelR1:setPosition(ccp(r1TimerSprite:getContentSize().width / 2, r1TimerSprite:getContentSize().height / 2 + 6))
        self.m_labelR2:setPosition(ccp(r2TimerSprite:getContentSize().width / 2, r2TimerSprite:getContentSize().height / 2 + 6))
        self.m_labelR3:setPosition(ccp(r3TimerSprite:getContentSize().width / 2, r3TimerSprite:getContentSize().height / 2 + 6))
        self.m_labelR4:setPosition(ccp(r4TimerSprite:getContentSize().width / 2, r4TimerSprite:getContentSize().height / 2 + 6))
    end
    
    local protectResource = buildingVoApi:getProtectResource()
    if playerVoApi:getR1() > protectResource then
        self.m_labelR1:setColor(G_ColorYellowPro);
    end
    if playerVoApi:getR2() > protectResource then
        self.m_labelR2:setColor(G_ColorYellowPro);
    end
    if playerVoApi:getR3() > protectResource then
        self.m_labelR3:setColor(G_ColorYellowPro);
    end
    if playerVoApi:getR4() > protectResource then
        self.m_labelR4:setColor(G_ColorYellowPro);
    end
    if playerVoApi:getGold() > protectResource then
        self.m_labelGold:setColor(G_ColorYellowPro);
    end
    
    --左边板子进度条  能量和等级进度条
    
    
    
    if G_checkUseAuditUI() == true then
        AddProgramTimer(self.mySpriteLeft, ccp(174, 52.5), 11, nil, nil, nil, "xpBar.png");
        AddProgramTimer(self.mySpriteLeft, ccp(174, 23), 10, nil, nil, nil, "energyBar.png");
    elseif G_getGameUIVer()==1 then
        AddProgramTimer(self.mySpriteLeft, ccp(174, 52.5), 11, nil, nil, nil, "xpBar.png");
        AddProgramTimer(self.mySpriteLeft, ccp(174, 22.5), 10, nil, nil, nil, "energyBar.png");
    else
        AddProgramTimer(self.mySpriteLeft, ccp(66, 61.5), 11, nil, nil, nil, "xpBar1.png");
        AddProgramTimer(self.mySpriteLeft, ccp(66, 53.5), 10, nil, nil, nil, "energyBar1.png");
    end
    local expTimerSprite = tolua.cast(self.mySpriteLeft:getChildByTag(11), "CCProgressTimer")
    expTimerSprite:setPercentage(playerVoApi:getLvPercent());
    local timerSprite = tolua.cast(self.mySpriteLeft:getChildByTag(10), "CCProgressTimer");
    timerSprite:setPercentage(playerVoApi:getEnergyPercent() * 100);
    
    --左边板子 等级label 姓名label
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        self.nameLb = GetTTFLabel(playerVoApi:getPlayerName(), 20, true);
        self.nameLb:setAnchorPoint(ccp(0, 0.5));
        self.nameLb:setPosition(ccp(90, 74));
        self.m_labelLevel = GetTTFLabel(getlocal("fightLevel", {playerVoApi:getPlayerLevel()}), 20); --isGM and 1 or
        self.m_labelLevel:setAnchorPoint(ccp(0, 0.5));
        self.m_labelLevel:setPosition(ccp(92, 53));
        self.nameLb:setColor(G_ColorWhite);
        self.mySpriteLeft:addChild(self.nameLb, 5);
    else
        self.m_labelLevel = GetTTFLabel(playerVoApi:getPlayerLevel(), 18); --isGM and 1 or
        self.m_labelLevel:setAnchorPoint(ccp(0.5, 0.5));
        self.m_labelLevel:setPosition(ccp(21, 58));
    end
    self.m_labelLevel:setColor(G_ColorWhite);
    self.mySpriteLeft:addChild(self.m_labelLevel, 5);
    
    local energyIconSp
    if G_checkUseAuditUI() == true then
        energyIconSp = CCSprite:createWithSpriteFrameName("energyIcon.png");
        energyIconSp:setAnchorPoint(ccp(0, 0.5));
        energyIconSp:setPosition(ccp(90, 21.5));
        self.mySpriteLeft:addChild(energyIconSp, 5);
    elseif G_getGameUIVer()==1 then
        energyIconSp = CCSprite:createWithSpriteFrameName("energyIcon.png");
        energyIconSp:setAnchorPoint(ccp(0, 0.5));
        energyIconSp:setPosition(ccp(90, 24.5));
        self.mySpriteLeft:addChild(energyIconSp, 5);
    else

    end
    
    -- local noBianSp = CCSprite:createWithSpriteFrameName("no_bian_gray.png")
    -- noBianSp:setScale(72 / noBianSp:getContentSize().width)
    -- noBianSp:setPosition(ccp(43, self.mySpriteLeft:getContentSize().height / 2 + 1));
    -- self.mySpriteLeft:addChild(noBianSp, 5);
    
    -- local personPhotoName="photo"..playerVoApi:getPic()..".png"

    local personPhoto
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        personPhoto = playerVoApi:getPersonPhotoSp(playerVoApi:getPic(), 70)
        personPhoto:setPosition(ccp(42, self.mySpriteLeft:getContentSize().height / 2));
    else
        personPhoto = playerVoApi:getPersonPhotoSp(playerVoApi:getPic(), 80)
        personPhoto:setAnchorPoint(ccp(0.5,1))
        personPhoto:setPosition(ccp(self.mySpriteLeft:getContentSize().width / 2, self.mySpriteLeft:getContentSize().height-12));
    end
    -- if isGM then
    --     personPhoto = CCSprite:createWithSpriteFrameName(GM_Icon)
    --     personPhoto:setScale(0.75)
    -- end
    -- personPhoto:setAnchorPoint(ccp(0.5,0.5));
    personPhoto:setTag(767)
    self.mySpriteLeft:addChild(personPhoto, 5);
    
    --头像框
    local frameSp = playerVoApi:getPlayerHeadFrameSp()
    if frameSp then
        frameSp:setPosition(personPhoto:getContentSize().width / 2, personPhoto:getContentSize().height / 2)
        frameSp:setScale((personPhoto:getContentSize().width + 7) / frameSp:getContentSize().width)
        personPhoto:addChild(frameSp)
    end
    
    local function playerIconChange(event, data)
        self:playerIconChange(data)
    end
    self.playerIconChangeListener = playerIconChange
    eventDispatcher:addEventListener("playerIcon.Change", playerIconChange)
    
    local function onUserNameChange()
        if self.nameLb then
            self.nameLb:setString(playerVoApi:getPlayerName())
        end
    end
    self.nameChangedListener = onUserNameChange
    eventDispatcher:addEventListener("user.name.change", onUserNameChange)
    
    local rankStr = playerVoApi:getRankIconName()
    self.m_rankMainUI = playerVoApi:getRank();
    local rankSP = CCSprite:createWithSpriteFrameName(rankStr);

    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        rankSP:setAnchorPoint(ccp(0.5, 0.5));
        rankSP:setPosition(ccp(65, self.mySpriteLeft:getContentSize().height / 2 - 20));
        rankSP:setScale(0.6)
    else
        rankSP:setAnchorPoint(ccp(0.5, 1));
        rankSP:setPosition(ccp(self.mySpriteLeft:getContentSize().width / 2+20, self.mySpriteLeft:getContentSize().height/2 + 30));
        rankSP:setScale(0.7)
    end
    rankSP:setTag(50)
    self.mySpriteLeft:addChild(rankSP, 6);
    if isGM then
        rankSP:setVisible(false)
    end
    
    -- 一串按钮 main_ui_42.png
    local function pushSmallMenu(tag, object)
        self:pushSmallMenu(tag, object)
    end
    
    -- 基地右侧缩放按钮
    local selectSp1,selectSp2,selectSp3,selectSp4
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        selectSp1 = CCSprite:createWithSpriteFrameName("mainBtnDown.png");
        selectSp2 = CCSprite:createWithSpriteFrameName("mainBtnDown_Down.png");
        selectSp3 = CCSprite:createWithSpriteFrameName("mainBtnUp.png");
        selectSp4 = CCSprite:createWithSpriteFrameName("mainBtnUp_Down.png");
    else
        selectSp1 = CCSprite:createWithSpriteFrameName("mainBtnDown1.png");
        selectSp2 = CCSprite:createWithSpriteFrameName("mainBtnDown1_Down.png");
        selectSp3 = CCSprite:createWithSpriteFrameName("mainBtnUp1.png");
        selectSp4 = CCSprite:createWithSpriteFrameName("mainBtnUp1_Down.png");
    end
    local menuItemSp1 = CCMenuItemSprite:create(selectSp1, selectSp2); --(90,80)
    local menuItemSp2 = CCMenuItemSprite:create(selectSp3, selectSp4);
    
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        self.m_pointLuaSp = ccp(G_VisibleSizeWidth - menuItemSp1:getContentSize().width / 2, G_VisibleSizeHeight - 185);
    else
        self.m_pointLuaSp = ccp(G_VisibleSizeWidth - menuItemSp1:getContentSize().width / 2 - 4, G_VisibleSizeHeight - 155);
    end
    
    self.m_menuToggleSmall = CCMenuItemToggle:create(menuItemSp1);
    self.m_menuToggleSmall:addSubItem(menuItemSp2)
    
    self.m_menuToggleSmall:registerScriptTapHandler(pushSmallMenu)
    if newGuidMgr:isNewGuiding() == true then
        self.m_menuToggleSmall:setSelectedIndex(0)
    else
        self.m_menuToggleSmall:setSelectedIndex(1)
    end
    
    self.menuAllSmall = CCMenu:createWithItem(self.m_menuToggleSmall);
    self.menuAllSmall:setPosition(self.m_pointLuaSp);
    self.menuAllSmall:setTouchPriority(-23);
    self.myUILayer:addChild(self.menuAllSmall, 10);
    
    local function touchLuaSp(object, name, tag)
        self:touchLuaSp(object, name, tag)
    end
    
    --[[
    self.m_luaSp1 = LuaCCSprite:createWithSpriteFrameName("Icon_BG.png",touchLuaSp);
    self.m_luaSp1:setPosition(self.m_pointLuaSp);
    self.m_luaSp1:setTag(101);
    self.myUILayer:addChild(self.m_luaSp1,1);
    self.m_luaSp1:setTouchPriority(-21);
    
    
    self.m_luaSp2 = LuaCCSprite:createWithSpriteFrameName("Icon_BG.png",touchLuaSp);
    self.m_luaSp2:setPosition(self.m_pointLuaSp);
    self.m_luaSp2:setTag(102);
    self.myUILayer:addChild(self.m_luaSp2,2);
    self.m_luaSp2:setTouchPriority(-21);
    ]]
    -- 图标背景
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        self.m_luaSp6 = LuaCCSprite:createWithSpriteFrameName("Icon_BG.png", touchLuaSp);
        self.m_luaSp7 = LuaCCSprite:createWithSpriteFrameName("Icon_BG.png", touchLuaSp);
    else
        self.m_luaSp6 = LuaCCSprite:createWithSpriteFrameName("Icon_BG1.png", touchLuaSp);
        self.m_luaSp7 = LuaCCSprite:createWithSpriteFrameName("Icon_BG1.png", touchLuaSp);
    end

    self.m_luaSp6:setPosition(self.m_pointLuaSp);
    self.m_luaSp6:setTag(106);
    self.myUILayer:addChild(self.m_luaSp6, 3);
    self.m_luaSp6:setTouchPriority(-21);
    
    self.m_luaSp7:setPosition(self.m_pointLuaSp);
    self.m_luaSp7:setTag(107);
    self.myUILayer:addChild(self.m_luaSp7, 4);
    self.m_luaSp7:setTouchPriority(-21);
    --[[
    local spriteSp1 = CCSprite:createWithSpriteFrameName("Icon_mainui_02.png")
    spriteSp1:setPosition(getCenterPoint(self.m_luaSp1))
    self.m_luaSp1:addChild(spriteSp1,1);
    
    local scaleX =  self.m_luaSp1:getContentSize().width/spriteSp1:getContentSize().width
    local scaleY =  self.m_luaSp1:getContentSize().height/spriteSp1:getContentSize().height
    spriteSp1:setScaleX(scaleX)
    spriteSp1:setScaleY(scaleY)
    self.m_iconScaleX = scaleX
    self.m_iconScaleY = scaleY
    
    local spriteSp2 = CCSprite:createWithSpriteFrameName("Icon_mainui_01.png")
    spriteSp2:setPosition(getCenterPoint(self.m_luaSp2))
    self.m_luaSp2:addChild(spriteSp2,1);
    spriteSp2:setScaleX(scaleX)
    spriteSp2:setScaleY(scaleY)
    ]]
    local spriteSp1 = CCSprite:createWithSpriteFrameName("Icon_mainui_02.png")
    
    local scaleX = self.m_luaSp6:getContentSize().width / spriteSp1:getContentSize().width
    local scaleY = self.m_luaSp6:getContentSize().height / spriteSp1:getContentSize().height
    self.m_iconScaleX = scaleX
    self.m_iconScaleY = scaleY
    -- 建筑加速的图标
    local spriteSp3
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        spriteSp3= CCSprite:createWithSpriteFrameName("tech_build_speed_up.png")
    else
        spriteSp3= CCSprite:createWithSpriteFrameName("tech_build_speed_up1.png")
    end
    spriteSp3:setPosition(getCenterPoint(self.m_luaSp6))
    self.m_luaSp6:addChild(spriteSp3, 1);
    local scaleX3 = self.m_luaSp6:getContentSize().width / spriteSp3:getContentSize().width
    local scaleY3 = self.m_luaSp6:getContentSize().height / spriteSp3:getContentSize().height
    spriteSp3:setScaleX(scaleX3)
    spriteSp3:setScaleY(scaleY3)
    -- 购买建造位的图标
    local spriteSp4
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        spriteSp4= CCSprite:createWithSpriteFrameName("new_build_process.png")
    else
        spriteSp4= CCSprite:createWithSpriteFrameName("new_build_process1.png")
    end
    spriteSp4:setPosition(getCenterPoint(self.m_luaSp7))
    self.m_luaSp7:addChild(spriteSp4, 1);
    spriteSp4:setScaleX(scaleX)
    spriteSp4:setScaleY(scaleY)
    
    self.m_newsIconTab = {}
    self.m_newsNumTab = {}
    self.m_functionBtnTb = {}
    local function travelHandler(object, name, tag)
        if G_checkClickEnable() == false then
            do
                return
            end
        end
        if self.m_travelSp:isVisible() == false then
            do
                return
            end
        end
        require "luascript/script/game/scene/gamedialog/warDialog/tankDefenseDialog"
        local dlayerNum = 3
        local td = tankDefenseDialog:new(dlayerNum)
        local tbArr = {getlocal("fleetCard"), getlocal("dispatchCard"), getlocal("repair")}
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("defenceSetting"), true, dlayerNum)
        td:tabClick(1)
        sceneGame:addChild(dialog, dlayerNum)
    end
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        self.m_travelSp = LuaCCSprite:createWithSpriteFrameName("Icon_BG.png", travelHandler)
    else
        self.m_travelSp = LuaCCSprite:createWithSpriteFrameName("Icon_BG1.png", travelHandler)
    end

    self.m_travelSp:setPosition(self.m_pointLuaSp)
    self.myUILayer:addChild(self.m_travelSp)
    self.m_travelSp:setVisible(false)
    self.m_travelSp:setTouchPriority(-21);
    
    if playerVoApi:getOriginBuildingSlotNum() ~= buildingSlotVoApi:getVersionMaxSlots() then
        self.m_luaSpTab = {self.m_luaSp6, self.m_luaSp7, self.m_travelSp}
    else
        self.m_luaSpTab = {self.m_luaSp6, self.m_travelSp}
    end
    
    -- if GM_UidCfg[playerVoApi:getUid()] then
    --       for  k,v in pairs(self.m_luaSpTab) do
    --         v:setVisible(false)
    --       end
    -- end
    
    if buildingVoApi:isAllBuildingsMax() then
        for k, v in pairs(self.m_luaSpTab) do
            if v == self.m_luaSp6 then
                self.m_luaSp6:setPosition(0,999999)
                table.remove(self.m_luaSpTab, k)
                break
            end
        end
    end
    
    self:addShortcuts(touchLuaSp);
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        self.m_skillHeigh = self.m_luaSp6:getContentSize().height;
    else
        self.m_skillHeigh = self.m_luaSp6:getContentSize().height+6;
    end
    self.m_luaTime = 0.1;
    self.m_dis = 1;
    
    -- vip按钮
    self:switchVipIcon()
    
    --左边一列按钮
    self.m_flagTab = {}
    self.m_leftIconTab = {}
    self.m_rightTopIconTab = {}
    --切换幸运抽奖是否有免费
    if base.dailyAcYouhuaSwitch == 1 then
    else
        self:switchDailyIcon()
    end
    --繁荣度
    if self.isNewGuideShow == false and base.isGlory == 1 then
        self:showGloryNow()
    end
    
    --新手7天礼包
    self:switchNewGiftsIcon()
    --7天之后显示  签到
    if base.dailyAcYouhuaSwitch == 1 then
    else
        local newGiftsState = newGiftsVoApi:hasReward()
        if newGiftsState == -1 then
            self:switchSignIcon()
        end
    end
    --加载和切换任务图片
    self:switchTaskIcon(false)
    --加载和切换每日领取图片
    self:switchDailyRewardIcon()
    --活动
    -- self:switchNewYearIcon()
    -- 活动图标统一
    -- self.myUILayer:addChild(activityUI:show())
    
    self:switchStateIcon()
    
    --显示公告
    -- self:switchNoticeIcon()
    
    --显示公告
    self.m_flagTab.acAndNoteState = activityVoApi:hadNewActivity() == true or noteVoApi:hadNewNote() == true or activityVoApi:oneCanReward() == true or dailyActivityVoApi:oneCanReward() -- 是否需要显示动画
    self.m_flagTab.hadAcAndNote = activityVoApi:hadActivity() or noteVoApi:hadNote() or dailyActivityVoApi:getActivityNum() > 0 -- 是否有活动或公告
    -- self.m_flagTab.newAcAndNoteNum = activityVoApi.newNum + noteVoApi.newNum -- 新活动和新公告个数之和
    if base.dailyAcYouhuaSwitch == 1 then
        self.m_flagTab.newAcAndNoteNum = activityVoApi.newNum + noteVoApi.newNum + dailyActivityVoApi:canRewardNum() -- 新活动和新公告个数之和+每日活动中当前进行的活动
    else
        self.m_flagTab.newAcAndNoteNum = activityVoApi.newNum + noteVoApi.newNum -- 新活动和新公告个数之和
    end
    self:switchActivityAndNoteIcon()
    require "luascript/script/game/scene/gamedialog/militaryOrdersVoApi"
    self:switchMilitaryOrdersIcon()
    self:switchStewardIcon()
    
    --协防
    self:switchHelpDefendIcon()
    
    --设置左边按钮位置
    self:resetLeftIconPos()
    --底下切换按钮
    -- 基地按钮
    local select11,select12,menuItem1,selectLabel1
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        select11 = CCSprite:createWithSpriteFrameName("mainUiBase.png");
        select12 = CCSprite:createWithSpriteFrameName("mainUiBase_Down.png");
        menuItem1 = CCMenuItemSprite:create(select11, select12); --(90,80)
        selectLabel1 = GetTTFLabel(getlocal("main_scene_port"), 20);
        selectLabel1:setAnchorPoint(ccp(0.5, 0.5))
        selectLabel1:setColor(G_ColorGreen)
        selectLabel1:setPosition(menuItem1:getContentSize().width / 2 - 9, 15)
    else
        select11 = CCSprite:createWithSpriteFrameName("mainUiBase1.png");
        select12 = CCSprite:createWithSpriteFrameName("mainUiBase1_Down.png");
        menuItem1 = CCMenuItemSprite:create(select11, select12); --(90,80)
        selectLabel1 = GetTTFLabel(getlocal("main_scene_port"), 20);
        selectLabel1:setAnchorPoint(ccp(0.5, 0.5))
        selectLabel1:setPosition(menuItem1:getContentSize().width / 2, 26)
        G_addStroke(menuItem1,selectLabel1,getlocal("main_scene_port"),20,false,nil,1)
    end
    menuItem1:setTag(21);
    menuItem1:addChild(selectLabel1)
    
    -- 郊外按钮
    local select21,select22,menuItem2,selectLabel2
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        select21 = CCSprite:createWithSpriteFrameName("mainUiOutskirts.png");
        select22 = CCSprite:createWithSpriteFrameName("mainUiOutskirts_Down.png");
        menuItem2 = CCMenuItemSprite:create(select21, select22);
        selectLabel2 = GetTTFLabel(getlocal("main_scene_island"), 20);
        selectLabel2:setAnchorPoint(ccp(0.5, 0.5))
        selectLabel2:setColor(G_ColorGreen)
        selectLabel2:setPosition(menuItem2:getContentSize().width / 2 - 9, 15)
    else
        select21 = CCSprite:createWithSpriteFrameName("mainUiOutskirts1.png");
        select22 = CCSprite:createWithSpriteFrameName("mainUiOutskirts1_Down.png");
        menuItem2 = CCMenuItemSprite:create(select21, select22);
        selectLabel2 = GetTTFLabel(getlocal("main_scene_island"), 20);
        selectLabel2:setAnchorPoint(ccp(0.5, 0.5))
        selectLabel2:setPosition(menuItem2:getContentSize().width / 2, 26)
        G_addStroke(menuItem2,selectLabel2,getlocal("main_scene_island"),20,false,nil,1)
    end
    menuItem2:setTag(22);
    menuItem2:addChild(selectLabel2)
    -- 世界按钮
    local select31,select32,menuItem3,selectLabel3
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        select31 = CCSprite:createWithSpriteFrameName("mainUiWorld.png");
        select32 = CCSprite:createWithSpriteFrameName("mainUiWorld_Down.png");
        menuItem3 = CCMenuItemSprite:create(select31, select32);
        selectLabel3 = GetTTFLabel(getlocal("main_scene_world"), 20);
        selectLabel3:setAnchorPoint(ccp(0.5, 0.5))
        selectLabel3:setColor(G_ColorGreen)
        selectLabel3:setPosition(menuItem3:getContentSize().width / 2 - 9, 15)
    else
        select31 = CCSprite:createWithSpriteFrameName("mainUiWorld1.png");
        select32 = CCSprite:createWithSpriteFrameName("mainUiWorld1_Down.png");
        menuItem3 = CCMenuItemSprite:create(select31, select32);
        selectLabel3 = GetTTFLabel(getlocal("main_scene_world"), 20);
        selectLabel3:setAnchorPoint(ccp(0.5, 0.5))
        selectLabel3:setPosition(menuItem3:getContentSize().width / 2, 26)
        G_addStroke(menuItem3,selectLabel3,getlocal("main_scene_world"),20,false,nil,1)
    end
    menuItem3:setTag(23);
    menuItem3:addChild(selectLabel3)
    
    if G_checkUseAuditUI() == true then
        selectLabel1:setPosition(menuItem1:getContentSize().width / 2 + 4, 22)
        selectLabel2:setPosition(menuItem2:getContentSize().width / 2 + 4, 22)
        selectLabel3:setPosition(menuItem3:getContentSize().width / 2 + 4, 22)
    end

    --切换场景
    local menuAll
    local function pushMenu(tag, object)
        -- if GM_UidCfg[playerVoApi:getUid()] then
        --   for  k,v in pairs(self.m_luaSpTab) do
        --     v:setVisible(false)
        --   end
        --   do return end
        -- end
        if newGuidMgr:isNewGuiding() and newGuidMgr.curStep == 10 then
            self.m_menuToggle:setSelectedIndex(0)
            do return end
        end
        PlayEffect(audioCfg.mouseClick)
        --print("xing",playerVoApi:getMapX(),playerVoApi:getPlayerLevel())
        if self.m_menuToggle:getSelectedIndex() == 2 then
            if G_notShowWorldMap() == true then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("alliance_notOpen"), 28)
                do return end
            end
            if tonumber(playerVoApi:getPlayerLevel()) < 3 and tonumber(playerVoApi:getMapX()) == -1 then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("worldSceneWillOpenDesc"), 28)
                do
                    self:changeToMyPort()
                    return
                end
            end
            
        end
        --print("smgui")
        -- if G_isApplyVersion()==true then
        --     local lightpos = ccp(menuAll:getPositionX()+6,menuAll:getPositionY()+3)
        --     local dialogBgHeight = 84
        --     self:initSunShine(self.mySpriteDown,dialogBgHeight,lightpos)
        -- end
        sceneController:changeSceneByIndex(self.m_menuToggle:getSelectedIndex())
        self:changeMainUI(self.m_menuToggle:getSelectedIndex())
        if newGuidMgr:isNewGuiding() then --新手引导
            newGuidMgr:toNextStep()
        end
    end
    
    self.m_menuToggle = CCMenuItemToggle:create(menuItem1);
    self.m_menuToggle:addSubItem(menuItem2)
    self.m_menuToggle:addSubItem(menuItem3)
    self.m_menuToggle:setSelectedIndex(0)
    self.m_menuToggle:registerScriptTapHandler(pushMenu)
    
    menuAll = CCMenu:createWithItem(self.m_menuToggle);
    
    if G_checkUseAuditUI() == true then
        menuAll:setPosition(ccp(68, 58))
    elseif G_getGameUIVer()==1 then
        menuAll:setPosition(ccp(84, 64));
    else
        menuAll:setPosition(ccp(menuItem1:getContentSize().width/2,menuItem1:getContentSize().height/2+1.5))
    end
    menuAll:setTouchPriority(-23);
    self.mySpriteDown:addChild(menuAll, 1);

    if G_getGameUIVer()==2 then
        self:menuItemLight( self.m_menuToggle,1,1,nil,nil )
    end
    
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    if G_checkUseAuditUI() == true then
        self.tv = LuaCCTableView:createHorizontalWithEventHandler(hd, CCSizeMake(470, 105), nil)
        self.tv:setAnchorPoint(ccp(0, 0));
        self.tv:setPosition(ccp(160, 10))
    elseif G_getGameUIVer()==1 then
        self.tv = LuaCCTableView:createHorizontalWithEventHandler(hd, CCSizeMake(440, 105), nil)
        self.tv:setAnchorPoint(ccp(0, 0));
        self.tv:setPosition(ccp(180, 10))
    else
        self.tv = LuaCCTableView:createHorizontalWithEventHandler(hd, CCSizeMake(520, 90), nil)
        self.tv:setAnchorPoint(ccp(0, 0));
        self.tv:setPosition(ccp(124, 0))
    end
    self.tv:setTableViewTouchPriority(-23);
    self.mySpriteDown:addChild(self.tv, 90)
    
    -- self:pushSmallMenu()
    self.m_showWelcome = true
    
    if base.plane == 1 then --战机革新技能研究队列监听器
        self:refreshPlaneStudySkill()
        local function planeStudySkillRefresh(event, data)
            self:refreshPlaneStudySkill(data)
        end
        self.planeStudySkillListener = planeStudySkillRefresh
        eventDispatcher:addEventListener("plane.newskill.refresh", planeStudySkillRefresh)
    end
    
    local function sysTipRefresh(event, data)
        self:refreshPlayerIconTip(data)
    end
    self.sysTipRefreshListener = sysTipRefresh
    eventDispatcher:addEventListener("player.sys.tipRefresh", sysTipRefresh)
    
    if G_isApplyVersion() == true then
        G_setShaderProgramAllChildren(self.myUILayer, function(ccNode)
            CCShader:setShaderProgram(ccNode, "kShader_ApplyVersion_HSL")
        end)
    end
    G_statisticsAuditRecord(AuditOp.MAINUI) --记录进入主界面
end

--左下角切换按钮刷光
function mainUI:menuItemLight( parentBg,scaleX,scaleY,flickerPos,lnum )
    if parentBg   then
        local m_iconScaleX,m_iconScaleY=scaleX,scaleY
        local pzFrameName="menuItemLight_1.png"
        local metalSp=CCSprite:createWithSpriteFrameName(pzFrameName)
        local pzArr=CCArray:create()
        for kk=1,14 do
            local nameStr="menuItemLight_"..kk..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            pzArr:addObject(frame)
        end
        local blendFunc = ccBlendFunc:new()
        blendFunc.src = GL_ONE
        blendFunc.dst = GL_ONE
        metalSp:setBlendFunc(blendFunc)
        
        local animation=CCAnimation:createWithSpriteFrames(pzArr)
        animation:setDelayPerUnit(0.08)
        local animate=CCAnimate:create(animation)
        metalSp:setAnchorPoint(ccp(0.5,0.5))
        if m_iconScaleX~=nil then
            metalSp:setScaleX(m_iconScaleX)
        end
        if m_iconScaleY~=nil then
            metalSp:setScaleY(m_iconScaleY)
        end
        metalSp:setPosition(ccp(parentBg:getContentSize().width/2,parentBg:getContentSize().height/2))
        metalSp:setTag(10101)
        if lnum==nil then
            lnum=5
        end

        parentBg:addChild(metalSp,lnum)
        local delayAction=CCDelayTime:create(6.0)
        local seq=CCSequence:createWithTwoActions(delayAction,animate)
        local repeatForever=CCRepeatForever:create(seq)
        metalSp:runAction(repeatForever)

        local circle1 = CCSprite:createWithSpriteFrameName("menuItemLight_circle_1.png")
        circle1:setBlendFunc(blendFunc)
        circle1:setPosition(ccp(parentBg:getContentSize().width/2-1,parentBg:getContentSize().height/2+4))
        circle1:setBlendFunc(blendFunc)    
        parentBg:addChild(circle1,lnum) 
        local rotate1=CCRotateBy:create(22.5, -180)
        local finalAc1 = CCRepeatForever:create(rotate1)
        circle1:runAction(finalAc1)

        local circle2 = CCSprite:createWithSpriteFrameName("menuItemLight_circle_2.png")
        circle2:setBlendFunc(blendFunc)
        circle2:setPosition(ccp(parentBg:getContentSize().width/2-1,parentBg:getContentSize().height/2+4))
        circle2:setBlendFunc(blendFunc)    
        parentBg:addChild(circle2,lnum) 
        local rotate1=CCRotateBy:create(45, 180)
        local finalAc2 = CCRepeatForever:create(rotate1)
        circle2:runAction(finalAc2)

        local circle3 = CCSprite:createWithSpriteFrameName("menuItemLight_circle_3.png")
        circle3:setBlendFunc(blendFunc)
        circle3:setPosition(ccp(parentBg:getContentSize().width/2-1,parentBg:getContentSize().height/2+4))
        circle3:setBlendFunc(blendFunc)    
        parentBg:addChild(circle3,lnum) 
        local rotate3=CCRotateBy:create(45, -180)
        local finalAc2 = CCRepeatForever:create(rotate3)
        circle3:runAction(finalAc2)

        local circle4 = CCSprite:createWithSpriteFrameName("menuItemLight_circle_4.png")
        circle4:setBlendFunc(blendFunc)
        circle4:setPosition(ccp(parentBg:getContentSize().width/2-1,parentBg:getContentSize().height/2+4))
        parentBg:addChild(circle4,lnum)
        
        return metalSp,circle1
    end
end
-- 让右侧展开
function mainUI:touchLuaSpExpnd()
    -- if GM_UidCfg[playerVoApi:getUid()] then--用于GM判断
    --    self.m_menuToggleSmall:setVisible(false)
    --    do return end
    -- end
    if newGuidMgr:isNewGuiding() == true then
        self.m_menuToggleSmall:setSelectedIndex(0)
    else
        self.m_menuToggleSmall:setSelectedIndex(1)
        if sceneController and sceneController.curIndex ~= 2 then
            for k, v in pairs(self.m_luaSpTab) do
                v:stopAllActions();
                self:moveDown(v, ccp(self.m_pointLuaSp.x, self.m_pointLuaSp.y - k * self.m_skillHeigh - k * self.m_dis), self.m_luaTime + 0.02 * k);
                local tagV = v:getTag();
            end
        end
    end
    
end

function mainUI:touchLuaSp(object, name, tag)
    
    if G_checkClickEnable() == false then
        do
            return
        end
    end
    if newGuidMgr:isNewGuiding() then
        do
            return
        end
    end
    local isPlayEffect = true;
    if tag == 101 then
        require "luascript/script/game/scene/gamedialog/isLandStateDialog"
        local td = isLandStateDialog:new()
        local tbArr = {getlocal("resource"), getlocal("state")}
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("islandState"), true, 3)
        sceneGame:addChild(dialog, 3)
        
    elseif tag == 102 then
        require "luascript/script/game/scene/gamedialog/isLandStateDialog"
        local td = isLandStateDialog:new()
        local tbArr = {getlocal("resource"), getlocal("state")}
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("islandState"), true, 3)
        td:tabClick(1)
        sceneGame:addChild(dialog, 3)
        isPlayEffect = false;
        
    elseif tag == 103 then
        local tabbuildings = buildingVoApi:getBuildingVoByBtype(9)
        local nbid = 0;
        for k, v in pairs(tabbuildings) do
            nbid = v.id
        end
        
        local level = buildingVoApi:getBuildiingVoByBId(6).level
        buildingVoApi:showWorkshop(nbid, 9, 3, level)
    elseif tag == 104 then
        local tabbuildings = buildingVoApi:getBuildingVoByBtype(8)
        local nbid = 0;
        local nlevel = 0
        for k, v in pairs(tabbuildings) do
            nbid = v.id
            nlevel = v.level
        end
        
        require "luascript/script/game/scene/gamedialog/portbuilding/techCenterDialog"
        local td = techCenterDialog:new(nbid, 3)
        local bName = getlocal(buildingCfg[8].buildName)
        local tbArr = {getlocal("building"), getlocal("startResearch")}
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, bName.."("..G_LV()..nlevel..")", true)
        td:tabClick(1)
        sceneGame:addChild(dialog, 3)
        isPlayEffect = false;
        
    elseif tag == 105 then
        local bid = 11;
        local tankSlot1 = tankSlotVoApi:getSoltByBid(11)
        local tankSlot2 = tankSlotVoApi:getSoltByBid(12)
        if SizeOfTable(tankSlot1) == 0 and SizeOfTable(tankSlot2) == 0 then
            bid = 11;
        elseif SizeOfTable(tankSlot1) == 0 and SizeOfTable(tankSlot2) > 0 then
            bid = 11;
        elseif SizeOfTable(tankSlot1) > 0 and SizeOfTable(tankSlot2) == 0 then
            bid = 12;
        elseif SizeOfTable(tankSlot1) > 0 and SizeOfTable(tankSlot2) > 0 then
            bid = 11;
        end
        
        local buildingVo = buildingVoApi:getBuildiingVoByBId(bid)
        if buildingVo.level == 0 then
            bid = 11;
            buildingVo = nil
            buildingVo = buildingVoApi:getBuildiingVoByBId(bid)
        end
        require "luascript/script/game/scene/gamedialog/portbuilding/tankFactoryDialog"
        local td = tankFactoryDialog:new(bid, 3)
        local bName = getlocal(buildingCfg[6].buildName)
        
        local tbArr = {getlocal("buildingTab"), getlocal("startProduce"), getlocal("chuanwu_scene_process")}
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, bName.."("..G_LV()..buildingVo.level..")", true, 3)
        td:tabClick(1)
        sceneGame:addChild(dialog, 3)
        
    elseif tag == 106 then
        -- local td=playerDialog:new(3,3)
        -- local tbArr={getlocal("playerInfo"),getlocal("skillTab"),getlocal("buildingTab")}
        -- local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("playerRole"),true,3)
        -- --td:tabClick(2)
        -- sceneGame:addChild(dialog,3)
        local td = playerVoApi:showPlayerDialog(3, 3)
    elseif tag == 107 then
        
        local vipLv = playerVoApi:getVipLevel()
        local buildQueue = tonumber(Split(playerCfg.vip4BuildQueue, ",")[vipLv + 1])--当前vip可购买建造位
        local mybuildQueue = playerVoApi:getOriginBuildingSlotNum()--当前拥有建造位
        local maxVipLv = tonumber(playerVoApi:getMaxLvByKey("maxVip")) or 10
        local maxbuildQueue = tonumber(Split(playerCfg.vip4BuildQueue, ",")[maxVipLv])
        
        if mybuildQueue < buildQueue then
            local function callBack()
                if playerVoApi:getGems() < tonumber(playerCfg.buildQueuePrice[mybuildQueue + 1]) then
                    smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("notEnoughGem"), nil, 4)
                    do
                        return
                    end
                end
                
                local function serverBuyBuildingSolt(fn, data)
                    --local retTb=OBJDEF:decode(data)
                    if base:checkServerData(data) == true then
                        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("promptBuyBuildingQueue", {mybuildQueue + 1}), nil, 4)
                    end
                    
                    if base.autoUpgrade == 1 then
                        print("建造位个数"..buildingSlotVoApi:getFreeSlotNum())
                        if buildingSlotVoApi:getFreeSlotNum() > 0 and buildingVoApi:getAutoUpgradeBuilding() == 1 and buildingVoApi:getAutoUpgradeExpire() - base.serverTime > 0 then
                            local function callBack(fn, data)
                                if base:checkServerData(data) == true then
                                    base.refreshupgrade = true
                                    print("base.refreshupgrade支撑true")
                                end
                            end
                            local bvo = buildingVoApi:getNextUpgradeVo()
                            if bvo ~= nil then
                                print("发送请求")
                                socketHelper:autoUpgradesyc(bvo.id, bvo.type, callBack)
                            end
                        end
                    end
                end
                socketHelper:buyBuildingSlot(serverBuyBuildingSolt)
            end
            smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), callBack, getlocal("dialog_title_prompt"), getlocal("buyQueueContent", {playerCfg.buildQueuePrice[mybuildQueue + 1]}), nil, 4)
            
        elseif mybuildQueue == maxbuildQueue then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("buidQueueMax"), nil, 4)
            
        else
            
            local needvip = playerCfg.vip4BuildQueueNeed[mybuildQueue + 1]
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("needVipContent", {needvip}), nil, 4)
            
        end
        
        --tankVoApi:getBestTanks()
        --[[
            require "luascript/script/game/scene/gamedialog/warDialog/tankAttackDialog"
            local td=tankAttackDialog:new(2,4)
            local tbArr={getlocal("AEFFighting"),getlocal("dispatchCard"),getlocal("repair")}
            local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("AEFFighting"),true,7)
            sceneGame:addChild(dialog,4)
            ]]
    elseif tag == 108 then --战机革新研究技能跳转
        local sid
        local studyList = planeVoApi:getStudyList()
        if studyList and studyList[1] then
            sid = studyList[1].sid
        end
        planeVoApi:showMainDialog(4, 2, nil, nil, sid)
    end
    if isPlayEffect == true then
        PlayEffect(audioCfg.mouseClick)
    end
    
end

--判断是否应该有快捷键
function mainUI:addShortcuts(touchLuaSp)
    --判断是否开启某种建筑 加进对应的右侧按钮
    if buildingVoApi:getBuildingVoIsBuildByBtype(9) == true and self.m_luaSp3 == nil then
        local sp
        if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
            self.m_luaSp3 = LuaCCSprite:createWithSpriteFrameName("Icon_BG.png", touchLuaSp);
            sp = CCSprite:createWithSpriteFrameName("Icon_dao_ju.png")--11111右边第一个
        else
            self.m_luaSp3 = LuaCCSprite:createWithSpriteFrameName("Icon_BG1.png", touchLuaSp);
            sp = CCSprite:createWithSpriteFrameName("Icon_dao_ju1.png")
        end
        self.m_luaSp3:setPosition(self.m_pointLuaSp);
        self.m_luaSp3:setTag(103);
        self.myUILayer:addChild(self.m_luaSp3, 2);
        self.m_luaSp3:setTouchPriority(-21);
        table.insert(self.m_luaSpTab, 1, self.m_luaSp3)
        
        local scale = self.m_luaSp3:getContentSize().width / sp:getContentSize().width
        sp:setScale(scale)
        sp:setTag(10)
        sp:setPosition(getCenterPoint(self.m_luaSp3))
        self.m_luaSp3:addChild(sp)
        
    end
    
    if buildingVoApi:getBuildingVoIsBuildByBtype(8) == true and self.m_luaSp4 == nil then
        if technologyVoApi:isAllTechnologyMaxLv() then
            for k, v in pairs(self.m_luaSpTab) do
                if v == self.m_luaSp4 then
                    table.remove(self.m_luaSpTab, k)
                    break
                end
            end
        else
            local sp
            if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                self.m_luaSp4 = LuaCCSprite:createWithSpriteFrameName("Icon_BG.png", touchLuaSp);
                sp = CCSprite:createWithSpriteFrameName("Icon_ke_yan_zhong_xin.png")--11111右边第一个
            else
                self.m_luaSp4 = LuaCCSprite:createWithSpriteFrameName("Icon_BG1.png", touchLuaSp);
                sp = CCSprite:createWithSpriteFrameName("Icon_ke_yan_zhong_xin1.png")
            end
            
            self.m_luaSp4:setPosition(self.m_pointLuaSp);
            self.m_luaSp4:setTag(104);
            self.myUILayer:addChild(self.m_luaSp4, 2);
            self.m_luaSp4:setTouchPriority(-21);
            if self.m_luaSp3 ~= nil then
                table.insert(self.m_luaSpTab, 2, self.m_luaSp4)
            else
                table.insert(self.m_luaSpTab, 1, self.m_luaSp4)
            end
            
            local scale = self.m_luaSp4:getContentSize().width / sp:getContentSize().width
            sp:setScale(scale)
            sp:setTag(10)
            sp:setPosition(getCenterPoint(self.m_luaSp4))
            self.m_luaSp4:addChild(sp)
        end
    end
    
    if buildingVoApi:getBuildingVoIsBuildByBtype(6) == true and self.m_luaSp5 == nil then
        local sp
        if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
            self.m_luaSp5 = LuaCCSprite:createWithSpriteFrameName("Icon_BG.png", touchLuaSp);
            sp = CCSprite:createWithSpriteFrameName("Icon_tan_ke_gong_chang.png")
        else
            self.m_luaSp5 = LuaCCSprite:createWithSpriteFrameName("Icon_BG1.png", touchLuaSp);
            sp = CCSprite:createWithSpriteFrameName("Icon_tan_ke_gong_chang1.png")
        end

        self.m_luaSp5:setPosition(self.m_pointLuaSp);
        self.m_luaSp5:setTag(105);
        self.myUILayer:addChild(self.m_luaSp5, 2);
        self.m_luaSp5:setTouchPriority(-21);
        local num = SizeOfTable(self.m_luaSpTab) - 1
        table.insert(self.m_luaSpTab, num, self.m_luaSp5)
        
        local scale = self.m_luaSp5:getContentSize().width / sp:getContentSize().width
        sp:setScale(scale)
        sp:setTag(10)
        sp:setPosition(getCenterPoint(self.m_luaSp5))
        self.m_luaSp5:addChild(sp)
        
    end
    local capInSet = CCRect(5, 5, 1, 1);
    local function touchClick()
        
    end
    --[[
    if self.m_luaSp1:getChildByTag(2)==nil then
        local tab1=useItemSlotVoApi:getAllSlots()
        local str1=useItemSlotVoApi:getNumByState2().."/".."4"
        local label1=GetTTFLabel(str1,20);
        label1:setPosition(ccp(self.m_luaSp1:getContentSize().width/2,10))
        label1:setTag(2)
        self.m_luaSp1:addChild(label1,5)
        
        
        local lbSpBg1 =LuaCCScale9Sprite:createWithSpriteFrameName("IconBgNum.png",capInSet,touchClick)
        lbSpBg1:setContentSize(CCSizeMake(label1:getContentSize().width+12,20))
        lbSpBg1:setPosition(ccp(self.m_luaSp1:getContentSize().width/2,10))
        lbSpBg1:setTag(3)
        self.m_luaSp1:addChild(lbSpBg1,4)
        
        local str2=useItemSlotVoApi:getNumByState1().."/".."5"
        local label2=GetTTFLabel(str2,20);
        label2:setPosition(ccp(self.m_luaSp2:getContentSize().width/2,10))
        label2:setTag(2)
        self.m_luaSp2:addChild(label2,5)
        local lbSpBg2 =LuaCCScale9Sprite:createWithSpriteFrameName("IconBgNum.png",capInSet,touchClick)
        lbSpBg2:setContentSize(CCSizeMake(label2:getContentSize().width+12,20))
        lbSpBg2:setPosition(ccp(self.m_luaSp2:getContentSize().width/2,10))
        lbSpBg2:setTag(3)
        self.m_luaSp2:addChild(lbSpBg2,4)
    
    end]]
    
    if self.m_luaSp3 ~= nil and self.m_luaSp3:getChildByTag(2) == nil then
        local tab3 = workShopSlotVoApi:getAllSolts()
        local str3;
        if SizeOfTable(tab3) == 0 then
            str3 = "0" .. "/" .. "1"
        else
            local voshop = workShopSlotVoApi:getProductSolt()
            local time = voshop.et - base.serverTime
            str3 = GetTimeStr(time)
            
        end
        local label3 = GetTTFLabel(str3, 20);
        label3:setPosition(ccp(self.m_luaSp3:getContentSize().width / 2, 10))
        label3:setTag(2)
        self.m_luaSp3:addChild(label3, 5)
        
        local lbSpBg3
        if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
            lbSpBg3 = LuaCCScale9Sprite:createWithSpriteFrameName("IconBgNum.png", capInSet, touchClick)
        else
            lbSpBg3 = LuaCCScale9Sprite:createWithSpriteFrameName("IconBgNum1.png", capInSet, touchClick)
        end
        lbSpBg3:setContentSize(CCSizeMake(label3:getContentSize().width + 12, 20))
        lbSpBg3:setPosition(ccp(self.m_luaSp3:getContentSize().width / 2, 10))
        lbSpBg3:setTag(3)
        self.m_luaSp3:addChild(lbSpBg3, 4)
    end
    
    if self.m_luaSp4 ~= nil and self.m_luaSp4:getChildByTag(2) == nil then
        local tab4 = technologySlotVoApi:getAllSlotSortBySt()
        local str4 = "";
        if SizeOfTable(tab4) == 0 then
            str4 = "0" .. "/" .. "1"
        else
            local voshop = tab4[1]
            if voshop.et ~= nil then
                local time = voshop.et - base.serverTime
                str4 = GetTimeStr(time)
            end
        end
        local label4 = GetTTFLabel(str4, 20);
        label4:setPosition(ccp(self.m_luaSp4:getContentSize().width / 2, 10))
        label4:setTag(2)
        self.m_luaSp4:addChild(label4, 5)
        
        local lbSpBg4
        if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
            lbSpBg4 = LuaCCScale9Sprite:createWithSpriteFrameName("IconBgNum.png", capInSet, touchClick)
        else
            lbSpBg4 = LuaCCScale9Sprite:createWithSpriteFrameName("IconBgNum1.png", capInSet, touchClick)
        end
        lbSpBg4:setContentSize(CCSizeMake(label4:getContentSize().width + 12, 20))
        lbSpBg4:setPosition(ccp(self.m_luaSp4:getContentSize().width / 2, 10))
        lbSpBg4:setTag(3)
        self.m_luaSp4:addChild(lbSpBg4, 4)
    end
    
    if self.m_luaSp5 ~= nil and self.m_luaSp5:getChildByTag(2) == nil then
        
        local tab5 = buildingVoApi:getBuildingVoHaveByBtype(6)
        local num = 0
        local tankTab1 = tankSlotVoApi:getSoltByBid(11)
        local tankTab2 = tankSlotVoApi:getSoltByBid(12)
        print("mainui=", SizeOfTable(tankTab1), SizeOfTable(tankTab2))
        
        local tankSVO;
        local str5;
        if SizeOfTable(tankTab1) > 0 and SizeOfTable(tankTab2) > 0 and tankTab1[1] and tankTab2[1] and tankTab1[1].et and tankTab2[1].et then
            if tankTab1[1].et > tankTab2[1].et then
                str5 = GetTimeStr(tankTab2[1].et - base.serverTime)
            else
                str5 = GetTimeStr(tankTab1[1].et - base.serverTime)
            end
            
        else
            num = num + 1;
            str5 = num.."/"..SizeOfTable(tab5)
        end
        
        local label5 = GetTTFLabel(str5, 20);
        label5:setPosition(ccp(self.m_luaSp5:getContentSize().width / 2, 10))
        label5:setTag(2)
        self.m_luaSp5:addChild(label5, 5)
        
        local lbSpBg5
        if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
            lbSpBg5 = LuaCCScale9Sprite:createWithSpriteFrameName("IconBgNum.png", capInSet, touchClick)
        else
            lbSpBg5 = LuaCCScale9Sprite:createWithSpriteFrameName("IconBgNum1.png", capInSet, touchClick)
        end
        lbSpBg5:setContentSize(CCSizeMake(label5:getContentSize().width + 12, 20))
        lbSpBg5:setPosition(ccp(self.m_luaSp5:getContentSize().width / 2, 10))
        lbSpBg5:setTag(3)
        self.m_luaSp5:addChild(lbSpBg5, 4)
    end
    
    if self.m_luaSp6 ~= nil and self.m_luaSp6:getChildByTag(2) == nil then
        local buildingSlotNum = SizeOfTable(buildingSlotVoApi:getAllBuildingSlots())
        local str6;
        if buildingSlotNum < playerVoApi:getBuildingSlotNum() then
            str6 = buildingSlotNum.."/"..playerVoApi:getBuildingSlotNum()
        else
            local tab = buildingSlotVoApi:getShortestSlot()
            local bsvo = tab
            local time = bsvo.et - base.serverTime
            str6 = GetTimeStr(time)
        end
        if self.m_luaSp6:getChildByTag(2) == nil then
            local label6 = GetTTFLabel(str6, 20);
            label6:setPosition(ccp(self.m_luaSp6:getContentSize().width / 2, 10))
            label6:setTag(2)
            self.m_luaSp6:addChild(label6, 5)

            local lbSpBg6
            if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                lbSpBg6 = LuaCCScale9Sprite:createWithSpriteFrameName("IconBgNum.png", capInSet, touchClick)
            else
                lbSpBg6 = LuaCCScale9Sprite:createWithSpriteFrameName("IconBgNum1.png", capInSet, touchClick)
            end
            lbSpBg6:setContentSize(CCSizeMake(label6:getContentSize().width + 12, 20))
            lbSpBg6:setPosition(ccp(self.m_luaSp6:getContentSize().width / 2, 10))
            lbSpBg6:setTag(3)
            self.m_luaSp6:addChild(lbSpBg6, 4)
        end
        
    end
    
end
function mainUI:pushSmallMenu(tag, object)
    PlayEffect(audioCfg.mouseClick)
    if newGuidMgr:isNewGuiding() then
        self.m_menuToggleSmall:setSelectedIndex(0)
        do
            return
        end
    end
    if self.m_menuToggleSmall:getSelectedIndex() == 1 then
        local function touchLuaSp(object, name, tag)
            self:touchLuaSp(object, name, tag)
        end
        self:addShortcuts(touchLuaSp);
        
        for k, v in pairs(self.m_luaSpTab) do
            
            v:stopAllActions();
            self:moveDown(v, ccp(self.m_pointLuaSp.x, self.m_pointLuaSp.y - k * self.m_skillHeigh - k * self.m_dis), self.m_luaTime + 0.02 * k);
            local tagV = v:getTag();
        end
        
    elseif self.m_menuToggleSmall:getSelectedIndex() == 0 then
        
        local function touchLuaSp(object, name, tag)
            self:touchLuaSp(object, name, tag)
        end
        self:addShortcuts(touchLuaSp);
        
        for k, v in pairs(self.m_luaSpTab) do
            
            v:stopAllActions();
            local pointV = ccp(v:getPositionX(), v:getPositionY())
            self:moveUp(v, pointV, self.m_pointLuaSp, 0.1, 0.1);
            --local tag = v:getTag();
        end
        
    end
    
end

--刷新快捷键队列
function mainUI:refreshQueue()
    --lb1刷新
    --[[
    local label1=self.m_luaSp1:getChildByTag(2)
    if label1~=nil then
        label1=tolua.cast(label1,"CCLabelTTF")
        local str1=useItemSlotVoApi:getNumByState1().."/".."5"
        label1:setString(str1);
    end
 
    local label2=self.m_luaSp2:getChildByTag(2)
    if label2~=nil then
        label2=tolua.cast(label2,"CCLabelTTF")
        local str2=useItemSlotVoApi:getNumByState2().."/".."4"
        label2:setString(str2);
    end
    ]]
    --lb3刷新
    
    if self.m_luaSp3 ~= nil and self.m_luaSp3:getChildByTag(2) ~= nil then
        local label3 = self.m_luaSp3:getChildByTag(2)
        label3 = tolua.cast(label3, "CCLabelTTF")
        local tab3 = workShopSlotVoApi:getAllSolts()
        local str3;
        if SizeOfTable(tab3) == 0 then
            if self.m_luaSp3:getChildByTag(11) ~= nil then
                self.m_luaSp3:getChildByTag(11):removeFromParentAndCleanup(true)
            end
            str3 = "0" .. "/" .. "1"
        else
            local voshop = workShopSlotVoApi:getProductSolt()
            if self.m_luaSp3:getChildByTag(11) == nil then
                local pid = "p"..voshop.itemId
                local sp = CCSprite:createWithSpriteFrameName(propCfg[pid].icon)
                local scale = self.m_luaSp3:getContentSize().width / sp:getContentSize().width
                sp:setScale(scale)
                sp:setTag(11)
                sp:setPosition(getCenterPoint(self.m_luaSp3))
                self.m_luaSp3:addChild(sp)
                
            end
            local time = voshop.et - base.serverTime
            str3 = GetTimeStr(time)
            
        end
        label3:setString(str3);
        local sp3 = self.m_luaSp3:getChildByTag(3)
        sp3:setContentSize(CCSizeMake(label3:getContentSize().width + 12, 20))
        
    end
    
    --lb4刷新
    
    if self.m_luaSp4 ~= nil and self.m_luaSp4:getChildByTag(2) ~= nil then
        local label4 = self.m_luaSp4:getChildByTag(2)
        label4 = tolua.cast(label4, "CCLabelTTF")
        local tab4 = technologySlotVoApi:getAllSlotSortBySt()
        local str4;
        if SizeOfTable(tab4) == 0 then
            if self.m_luaSp4:getChildByTag(11) ~= nil then
                self.m_luaSp4:getChildByTag(11):removeFromParentAndCleanup(true)
            end
            str4 = "0" .. "/" .. "1"
        else
            if self.m_luaSp4:getChildByTag(11) ~= nil then
                self.m_luaSp4:getChildByTag(11):removeFromParentAndCleanup(true)
            end
            if self.m_luaSp4:getChildByTag(11) == nil then
                local sp = CCSprite:createWithSpriteFrameName(techCfg[tonumber(tab4[1].tid)].icon)
                local scale = self.m_luaSp4:getContentSize().width / sp:getContentSize().width
                sp:setScale(scale)
                sp:setTag(11)
                sp:setPosition(getCenterPoint(self.m_luaSp4))
                self.m_luaSp4:addChild(sp)
            end
            local voshop = tab4[1]
            local time = voshop.et - base.serverTime
            str4 = GetTimeStr(time)
        end
        label4:setString(str4);
        
        local sp4 = self.m_luaSp4:getChildByTag(3)
        sp4:setContentSize(CCSizeMake(label4:getContentSize().width + 12, 20))
    end
    
    --lb5刷新
    if self.m_luaSp5 ~= nil and self.m_luaSp5:getChildByTag(2) ~= nil then
        local label5 = self.m_luaSp5:getChildByTag(2)
        label5 = tolua.cast(label5, "CCLabelTTF")
        
        local tab5 = buildingVoApi:getBuildingVoHaveByBtype(6)
        local num = 0
        local tankTab1 = tankSlotVoApi:getSoltByBid(11)
        local tankTab2 = tankSlotVoApi:getSoltByBid(12)
        local tankSVO;
        local str5;
        if SizeOfTable(tankTab1) > 0 and SizeOfTable(tankTab2) > 0 then
            if tankSlotVoApi:getProducingSlotByBid(11).et > tankSlotVoApi:getProducingSlotByBid(12).et then
                if self.m_luaSp5:getChildByTag(11) == nil then
                    local sp = CCSprite:createWithSpriteFrameName(tankCfg[tonumber(tankSlotVoApi:getProducingSlotByBid(12).itemId)].icon)
                    local scale = self.m_luaSp5:getContentSize().width / sp:getContentSize().width
                    sp:setScale(scale)
                    sp:setTag(11)
                    sp:setPosition(getCenterPoint(self.m_luaSp5))
                    self.m_luaSp5:addChild(sp)
                end
                str5 = GetTimeStr(tankSlotVoApi:getProducingSlotByBid(12).et - base.serverTime)
            else
                if self.m_luaSp5:getChildByTag(11) == nil then
                    local sp = CCSprite:createWithSpriteFrameName(tankCfg[tonumber(tankSlotVoApi:getProducingSlotByBid(11).itemId)].icon)
                    local scale = self.m_luaSp5:getContentSize().width / sp:getContentSize().width
                    sp:setScale(scale)
                    sp:setTag(11)
                    sp:setPosition(getCenterPoint(self.m_luaSp5))
                    self.m_luaSp5:addChild(sp)
                end
                str5 = GetTimeStr(tankSlotVoApi:getProducingSlotByBid(11).et - base.serverTime)
            end
            
        elseif SizeOfTable(tankTab1) > 0 or SizeOfTable(tankTab2) > 0 then
            if self.m_luaSp5:getChildByTag(11) ~= nil then
                self.m_luaSp5:getChildByTag(11):removeFromParentAndCleanup(true)
            end
            num = num + 1;
            str5 = num.."/"..SizeOfTable(tab5)
        else
            if self.m_luaSp5:getChildByTag(11) ~= nil then
                self.m_luaSp5:getChildByTag(11):removeFromParentAndCleanup(true)
            end
            num = 0;
            str5 = num.."/"..SizeOfTable(tab5)
        end
        
        label5:setString(str5);
        
        local sp5 = self.m_luaSp5:getChildByTag(3)
        sp5:setContentSize(CCSizeMake(label5:getContentSize().width + 12, 20))
    end
    
    --lb6刷新
    
    if self.m_luaSp6 ~= nil and self.m_luaSp6:getChildByTag(2) ~= nil then
        local label6 = self.m_luaSp6:getChildByTag(2)
        label6 = tolua.cast(label6, "CCLabelTTF")
        local buildingSlotNum = SizeOfTable(buildingSlotVoApi:getAllBuildingSlots())
        local str6;
        if buildingSlotNum < playerVoApi:getBuildingSlotNum() then
            str6 = buildingSlotNum.."/"..playerVoApi:getBuildingSlotNum()
        else
            local tab = buildingSlotVoApi:getShortestSlot()
            local bsvo = tab
            local time = bsvo.et - base.serverTime
            if time < 0 then
                time = 0;
            end
            str6 = GetTimeStr(time)
        end
        label6:setString(str6);
        local sp6 = self.m_luaSp6:getChildByTag(3)
        sp6:setContentSize(CCSizeMake(label6:getContentSize().width + 12, 20))
    end
    
end

function mainUI:moveDown(node, point, time)
    local scaleTo = CCScaleTo:create(0.01,1,1)
    local moveTo1 = CCMoveTo:create(time, ccp(point.x, point.y - 20));
    local moveTo2 = CCMoveTo:create(0.3, point);
    local acArr = CCArray:create()
    acArr:addObject(scaleTo)
    acArr:addObject(moveTo1)
    acArr:addObject(moveTo2)
    local seq = CCSequence:create(acArr);
    node:runAction(seq);
end

function mainUI:moveUp(node, point1, point2, time1, time2)
    local moveTo1 = CCMoveTo:create(time1, ccp(point1.x, point1.y - 5));
    local moveTo2 = CCMoveTo:create(time2, point2);
    local scaleTo = CCScaleTo:create(0.01,1,0)
    local acArr = CCArray:create()
    acArr:addObject(moveTo1)
    acArr:addObject(moveTo2)
    acArr:addObject(scaleTo)
    local seq = CCSequence:create(acArr);
    node:runAction(seq);
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function mainUI:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        local cNum = SizeOfTable(self.btnList)
        return cNum
    elseif fn == "tableCellSizeForIndex" then
        local tmpSize
        if G_checkUseAuditUI() == true then
            tmpSize = CCSizeMake(95, 105)
        elseif G_getGameUIVer()==1 then
            tmpSize = CCSizeMake(82, 105)
        else
            tmpSize = CCSizeMake(88, 105)
        end
        return tmpSize
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()

        local select31;
        local select32;
        local menuItem3;
        local titleLb;
        
        local function touch1(tag, object)
            
            if self.tv and self.tv:getIsScrolled() == false then
                if newGuidMgr:isNewGuiding() == true then
                    if newGuidMgr.curStep == 10 and tag ~= 11 then
                        do
                            return
                        end
                    end
                    
                    if newGuidMgr.curStep == 31 and tag ~= 13 then
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
                PlayEffect(audioCfg.mouseClick)
                self.mainUIBTNTb[self.btnList[idx + 1]].callback()
                
            end
            
        end
        
        local numHeight = 20
        if G_getGameUIVer()==2 then
            numHeight = 24
        end
        local newsNumLabel = GetTTFLabel("0", numHeight)
        newsNumLabel:setTag(10)
        local capInSet = CCRect(17, 17, 1, 1)
        local function touchClick()
        end
        local newsIcon
        if G_checkUseAuditUI() == true or G_getGameUIVer()==1 then
            newsIcon = LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png", CCRect(17, 17, 1, 1), touchClick)
        else
            newsIcon = LuaCCScale9Sprite:createWithSpriteFrameName("NumBg1.png", CCRect(17, 17, 1, 1), touchClick)
        end
        newsIcon:setContentSize(CCSizeMake(36, 36))
        newsIcon:ignoreAnchorPointForPosition(false)
        newsIcon:setAnchorPoint(CCPointMake(0.5, 0))
        newsIcon:addChild(newsNumLabel, 1)
        newsIcon:setVisible(false)
        newsNumLabel:setPosition(ccp(newsIcon:getContentSize().width / 2, newsIcon:getContentSize().height / 2))
        
        local btnId = self.btnList[idx + 1]
        local btnName1 = self.mainUIBTNTb[btnId].bName1
        local btnName2 = self.mainUIBTNTb[btnId].bName2
        local btnLbStr = self.mainUIBTNTb[btnId].btnLb

        local fontsize = 20
        if G_checkUseAuditUI() == true or G_getGameUIVer()==1 then
            newsIcon:setPosition(ccp(65, 53))
        else
            fontsize = 18
            newsIcon:setScale(0.7)
            newsIcon:setPosition(ccp(70, 57))
        end
        
        select31 = CCSprite:createWithSpriteFrameName(btnName1);
        select32 = CCSprite:createWithSpriteFrameName(btnName2);
        titleLb = GetTTFLabel(getlocal(btnLbStr), fontsize);
        
        menuItem3 = CCMenuItemSprite:create(select31, select32);
        menuItem3:setAnchorPoint(ccp(0, 0));
        menuItem3:setPosition(ccp(0, 0))
        
        
        if G_checkUseAuditUI() == true or G_getGameUIVer()==1 then
            titleLb:setPosition(ccp(menuItem3:getContentSize().width / 2, -3))
            titleLb:setColor(G_ColorGreen)
        else
            titleLb:setColor(ccc3(131, 169, 158))
        end
        if G_checkUseAuditUI() == true then
            if idx ~= 7 then
                local lineSp = CCSprite:createWithSpriteFrameName("mainVerticalBar.png")
                lineSp:setPosition(ccp(menuItem3:getContentSize().width - 3, menuItem3:getContentSize().height / 2 + 5))
                cell:addChild(lineSp)
            end
            titleLb:setColor(ccc3(170, 255, 177))
        elseif G_getGameUIVer()==2 then
            -- if idx ~= 9 then
            --     local lineSp = CCSprite:createWithSpriteFrameName("mainVerticalBar1.png")
            --     lineSp:setAnchorPoint(ccp(0.5,0.5))
            --     lineSp:setPosition(ccp(menuItem3:getContentSize().width - 3, menuItem3:getContentSize().height / 2 + 17))
            --     cell:addChild(lineSp)
            -- end
            titleLb:setAnchorPoint(ccp(0.5,0))
            titleLb:setPosition(ccp(menuItem3:getContentSize().width / 2, 8))
        else

        end
        
        menuItem3:addChild(titleLb, 6)
        menuItem3:addChild(newsIcon, 6)
        menuItem3:setTag(idx + 11)
        if(skinMgr and skinMgr.getCurrentSkin)then
            local curSkin = skinMgr:getCurrentSkin()
            if(curSkin == "winter2017")then
                local btnSkin = CCSprite:createWithSpriteFrameName("winterskinbtn"..RemoveFirstChar(self.btnList[idx + 1] .. ".png"))
                if(btnSkin)then
                    btnSkin:setPosition(getCenterPoint(menuItem3))
                    menuItem3:addChild(btnSkin)
                end
            end
        end
        
        for k, v in pairs(self.btnTipsList) do
            if v == self.btnList[idx + 1] then
                self.m_newsNumTab[self.btnList[idx + 1]] = newsIcon
            end
        end
        local index = idx + 1
        self.m_functionBtnTb[self.btnList[idx + 1]] = menuItem3
        local menu3 = CCMenu:createWithItem(menuItem3);
        menu3:setAnchorPoint(ccp(0, 0));
        
        if G_checkUseAuditUI() == true then
            menu3:setScale(0.9)
            menu3:setPosition(ccp(0, 22))
        elseif G_getGameUIVer()==1 then
            menu3:setPosition(ccp(0, 18))
        else
            menu3:setPosition(ccp(0, 18.5))
        end
        menuItem3:registerScriptTapHandler(touch1)
        menu3:setTouchPriority(-22);
        
        cell:addChild(menu3, 6)
        
        return cell
    elseif fn == "ccTouchBegan" then
        self.isMoved = false
    elseif fn == "ccTouchMoved" then
        
        self.isMoved = true
    elseif fn == "ccTouchEnded" then
        
    elseif fn == "ccScrollEnable" then
        if newGuidMgr:isNewGuiding() == true then
            return 0
        else
            return 1
        end
    end
end

function mainUI:setNewsNum(num, newsIcon)
    local strLb = newsIcon:getChildByTag(10)
    strLb = tolua.cast(strLb, "CCLabelTTF")
    strLb:setString(num)
    local width = newsIcon:getContentSize().width
    local height = newsIcon:getContentSize().height
    if strLb:getContentSize().width + 10 > width then
        width = strLb:getContentSize().width + 10
    end
    newsIcon:setContentSize(CCSizeMake(width, height))
    strLb:setPosition(getCenterPoint(newsIcon))
    newsIcon:setVisible(true)
end
function mainUI:refreshButtonTips()
    local num = 0
    for k, v in pairs(self.m_newsNumTab) do
        local btnIcon = v:getParent()
        local tipIcon
        if k == "b2" then
            num = SizeOfTable(attackTankSoltVoApi:getAllAttackTankSlots()) + SizeOfTable(tankVoApi:getRepairTanks())
        elseif k == "b3" then
            num = accessoryVoApi:getLeftECNum()
        elseif k == "b6" then
            num = emailVoApi:getHasUnread()
        elseif k == "b5" then
            num = bagVoApi:getItemRedPointNumByType(-1)
            tipIcon = btnIcon:getChildByTag(11111)
        end
        if num > 0 then
            v:setVisible(true)
            if k == "b5" and num > bagVoApi.redPointMaxNum then
                num = "···"
            end
            self:setNewsNum(num, v)
        elseif v:isVisible() == true then
            v:setVisible(false)
        end
        if k == "b5" and num == 0 and bagVoApi:isCompound(-1) then
            if tipIcon == nil then
                local _x, _y = v:getPosition()
                if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                    tipIcon = CCSprite:createWithSpriteFrameName("IconTip.png")
                    tipIcon:setAnchorPoint(v:getAnchorPoint())
                    tipIcon:setPosition(_x, _y - 3)
                else
                    tipIcon = CCSprite:createWithSpriteFrameName("IconTip1.png")
                    tipIcon:setAnchorPoint(v:getAnchorPoint())
                    tipIcon:setPosition(_x, _y)
                    tipIcon:setScale(0.65)
                end
                -- tipIcon:setScale(v:getContentSize().width/tipIcon:getContentSize().width)
                tipIcon:setTag(11111)
                btnIcon:addChild(tipIcon)
            end
            tipIcon:setVisible(true)
        elseif tipIcon then
            tipIcon:removeFromParentAndCleanup(true)
            tipIcon = nil
        end
    end
    
end

function mainUI:runChatButtonAction(...)
    if self.chatRepeat then
    else
        local moveTime = 0.5
        local scaleTo1 = CCScaleTo:create(moveTime, 1.1)
        local scaleTo2 = CCScaleTo:create(moveTime, 1)
        local scaleTo1 = CCScaleTo:create(moveTime, 1.1)
        local scaleTo2 = CCScaleTo:create(moveTime, 1)
        local delay = CCDelayTime:create(moveTime * 2)
        local acArr = CCArray:create()
        acArr:addObject(scaleTo1)
        acArr:addObject(scaleTo2)
        acArr:addObject(scaleTo1)
        acArr:addObject(scaleTo2)
        acArr:addObject(delay)
        local chatScale = CCSequence:create(acArr)
        local chatRepeat = CCRepeatForever:create(chatScale)
        chatRepeat:setTag(1016)
        self.chatRepeat = chatRepeat
        self.chatSprite:runAction(chatRepeat)
    end
end

-- 好友提示动画
function mainUI:runFriendTipAction(...)
    if self.repeatEver then
    else
        local fade1 = CCFadeTo:create(1, 150)
        local fade2 = CCFadeTo:create(1, 255)
        local delay = CCDelayTime:create(1.5)
        local acArr = CCArray:create()
        acArr:addObject(fade1)
        acArr:addObject(fade2)
        acArr:addObject(delay)
        local seq = CCSequence:create(acArr)
        local repeatEver = CCRepeatForever:create(seq)
        repeatEver:setTag(1016)
        self.repeatEver = repeatEver
        self.newFriendTipSprite:runAction(repeatEver)
    end
    
end

function mainUI:refreshRedpoint(...)
    
    -- 收到未查看的私聊一直展示放大缩小动画,加红点
    if chatVoApi:getUnReadCount(2) > 0 then
        self:runChatButtonAction()
        self.newsIcon:setVisible(true)
        local num = chatVoApi:getUnReadCount(2) > 99 and 99 or chatVoApi:getUnReadCount(2)
        self.numLb:setVisible(true)
        self.numLb:setString(num)
    else
        if self.chatRepeat then
            self.chatSprite:stopActionByTag(1016)
        end
        self.chatRepeat = nil
        self.newsIcon:setVisible(false)
        self.numLb:setVisible(false)
    end
    
end

function mainUI:tick()
    verifyApi:checkVerifyShow() --检测是否实名认证
    healthyApi:checkHealthyShow() --检测弹出健康游戏提示
    
    if base.rewardcenter == 1 then
        mainUI:showRewardCenterBtn()
    end
    self:refreshRedpoint()
    if friendInfoVoApi:isHasInvite() == true or friendInfoVoApi:isHasUnreceiveNum() == true then
        self.newFriendTipSprite:setVisible(true)
        if rewardCenterVoApi and rewardCenterVoApi:isShowRewardBtn() == true then
            self.newFriendTipSprite:setPosition(ccp(G_VisibleSizeWidth / 2 + 70, 330))
        else
            self.newFriendTipSprite:setPosition(ccp(G_VisibleSizeWidth / 2 + 160, 330))
        end
        self:runFriendTipAction()
    else
        self.newFriendTipSprite:setVisible(false)
        self.newFriendTipSprite:setPosition(ccp(9999, 330))
        if self.repeatEver then
            self.newFriendTipSprite:stopActionByTag(1016)
        end
        self.repeatEver = nil
    end
    
    -- 每秒检查行军队列缩略面板
    self:checkFleetSlotChange()
    
    self:refreshQueue()
    self:refreshButtonTips()
    self:refreshBuffState()
    self.m_showFriendTime = self.m_showFriendTime + 1
    
    if string.find(playerVoApi:getPlayerName(), "@") ~= nil and self.addChangename == true and newGuidMgr:isNewGuiding() == false then
        self.addChangename = false
        mergerServersChangeNameDialog:create(5, getlocal("player_changeName"), getlocal("alliance_changeContent", {getlocal("player_playerName"), getlocal("player_playerName"), getlocal("player_playerName")}), 1)
    end
    
    --是否已经领取过评价奖励
    local evaluateRewarded = true
    if(G_curPlatName() == "14" or G_curPlatName() == "androidkunlun" or G_curPlatName() == "androidkunlunz")then
        if(base.isUserEvaluate ~= 2)then
            evaluateRewarded = false
        else
            evaluateRewarded = true
        end
    else
        if(base.isUserEvaluate ~= 1)then
            evaluateRewarded = false
        else
            evaluateRewarded = true
        end
    end
    --弹出评价面板
    if platCfg.platEvaluate[G_curPlatName()] ~= nil and base.isEvaluateOnOff == 1 and self.isShowEvaluate == false and evaluateRewarded == false and newGuidMgr:isNewGuiding() == false then
        --阿拉伯的弹法和其他平台规则不同, 每过5级试一次
        if(G_curPlatName() == "21" or G_curPlatName() == "androidarab")then
            if((playerVoApi:getPlayerLevel()) % (platCfg.platEvaluate[G_curPlatName()]) == 0)then
                local localData = CCUserDefault:sharedUserDefault():getIntegerForKey("evaluate_version"..G_Version)
                if(localData == 0 or localData == nil or localData <= playerVoApi:getPlayerLevel())then
                    popDialog:createSimpleEvaluate(sceneGame, 30)
                    self.isShowEvaluate = true
                    CCUserDefault:sharedUserDefault():setIntegerForKey("evaluate_version"..G_Version, playerVoApi:getPlayerLevel() + platCfg.platEvaluate[G_curPlatName()])
                end
            end
        elseif playerVoApi:getPlayerLevel() >= platCfg.platEvaluate[G_curPlatName()] then
            popDialog:createEvaluate(sceneGame, 30, getlocal("evaluateGift"))
            self.isShowEvaluate = true
        end
    end
    if(self.isShowEvaluate ~= true and self.checkMovgaBind ~= true and dailyActivityVoApi and dailyActivityVoApi.movgaBindFlag == 0 and dailyActivityVoApi.checkShowMovgaBind and dailyActivityVoApi:checkShowMovgaBind() and newGuidMgr:isNewGuiding() == false and otherGuideMgr.isGuiding ~= true)then
        self.checkMovgaBind = true
        local pid = G_getTankUserName()
        if(pid == nil)then
            pid = 0
        end
        local lastShowTs = tonumber(CCUserDefault:sharedUserDefault():getIntegerForKey("movga_bind_ts_"..pid))
        if(lastShowTs == nil or lastShowTs == 0 or base.serverTime - lastShowTs >= 86400 * 7)then
            require "luascript/script/game/scene/gamedialog/activityAndNote/acMovgaBindEmailSmallDialog"
            local sd = acMovgaBindEmailSmallDialog:new()
            sd:init(3)
            CCUserDefault:sharedUserDefault():setIntegerForKey("movga_bind_ts_"..pid, base.serverTime)
            CCUserDefault:sharedUserDefault():flush()
        end
    end
    if self.m_rankMainUI ~= playerVoApi:getRank() then
        local rankSp = self.mySpriteLeft:getChildByTag(50)
        rankSp:removeFromParentAndCleanup(true)
        self.m_rankMainUI = playerVoApi:getRank();
        local rankStr = playerVoApi:getRankIconName()
        local rankSP = CCSprite:createWithSpriteFrameName(rankStr);
        if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
            rankSP:setAnchorPoint(ccp(0.5, 0.5));
            rankSP:setPosition(ccp(65, self.mySpriteLeft:getContentSize().height / 2 - 20));
        else
            rankSP:setAnchorPoint(ccp(0.5, 1));
            rankSP:setPosition(ccp(self.mySpriteLeft:getContentSize().width / 2, self.mySpriteLeft:getContentSize().height - 12));
        end
        rankSP:setAnchorPoint(ccp(0.5, 0.5));
        rankSP:setPosition(ccp(65, self.mySpriteLeft:getContentSize().height / 2 - 20));
        rankSP:setScale(0.6)
        rankSP:setTag(50)
        self.mySpriteLeft:addChild(rankSP, 6);
        
    end
    --GM 放开
    -- if GM_UidCfg[playerVoApi:getUid()] == nil then
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        self.nameLb:setString(playerVoApi:getPlayerName())
        self.m_labelLevel:setString(getlocal("fightLevel", {playerVoApi:getPlayerLevel()}))
    else
        self.m_labelLevel:setString(playerVoApi:getPlayerLevel())
    end
    self.m_labelMoney:setString(FormatNumber(playerVoApi:getGems()))
    self.m_labelGold:setString(FormatNumber(playerVoApi:getGold()))
    self.m_labelR1:setString(FormatNumber(playerVoApi:getR1()))
    self.m_labelR2:setString(FormatNumber(playerVoApi:getR2()))
    self.m_labelR3:setString(FormatNumber(playerVoApi:getR3()))
    self.m_labelR4:setString(FormatNumber(playerVoApi:getR4()))
    -- end
    --金矿系统采集资源量刷新
    if base.wl == 1 and base.goldmine == 1 then
        --检测异星科技资源隔天刷新
        alienTechVoApi:checkUpdateDailyRes()
        --检测金币资源隔天刷新
        goldMineVoApi:checkUpdateDailyGems()
        if goldMineVoApi:getRefreshGemsFlag() == true or alienTechVoApi:getResDailyFlag() == 0 then
            if self.gatherResLbTb and type(self.gatherResLbTb) == "table" then
                for k, v in pairs(self.gatherResLbTb) do
                    if v.resLb and v.type and v.key then
                        local cur, max = goldMineVoApi:getGatherRes(v.type, v.key)
                        if cur and max then
                            v.resLb:setString(FormatNumber(cur))
                            if tonumber(cur) == tonumber(max) then
                                v.resLb:setColor(G_ColorRed)
                            else
                                v.resLb:setColor(G_ColorWhite)
                            end
                        end
                    end
                end
                if goldMineVoApi:getRefreshGemsFlag() == true then
                    goldMineVoApi:setRefreshGemsFlag(false)
                end
                if alienTechVoApi:getResDailyFlag() == 0 then
                    alienTechVoApi:setResDailyFlag(1)
                end
            end
        end
    end
    if self.needRefreshPlayerInfo == true then
        self.needRefreshPlayerInfo = false
        local timerSprite = self.mySpriteLeft:getChildByTag(10);
        timerSprite = tolua.cast(timerSprite, "CCProgressTimer")
        timerSprite:setPercentage(playerVoApi:getEnergyPercent() * 100);
        
        local expTimerSprite = self.mySpriteLeft:getChildByTag(11);
        expTimerSprite = tolua.cast(expTimerSprite, "CCProgressTimer")
        expTimerSprite:setPercentage(playerVoApi:getLvPercent());
        
        -- self.m_labelMoney:setString(FormatNumber(playerVoApi:getGems()))
        -- self.m_labelGold:setString(FormatNumber(playerVoApi:getGold()))
        -- self.m_labelR1:setString(FormatNumber(playerVoApi:getR1()))
        -- self.m_labelR2:setString(FormatNumber(playerVoApi:getR2()))
        -- self.m_labelR3:setString(FormatNumber(playerVoApi:getR3()))
        -- self.m_labelR4:setString(FormatNumber(playerVoApi:getR4()))
        -- self.m_labelLevel:setString(getlocal("fightLevel",{playerVoApi:getPlayerLevel()}))
        
        local protectResource = buildingVoApi:getProtectResource()
        if playerVoApi:getR1() > protectResource then
            self.m_labelR1:setColor(G_ColorYellowPro);
        else
            self.m_labelR1:setColor(G_ColorWhite);
        end
        if playerVoApi:getR2() > protectResource then
            self.m_labelR2:setColor(G_ColorYellowPro);
        else
            self.m_labelR2:setColor(G_ColorWhite);
        end
        if playerVoApi:getR3() > protectResource then
            self.m_labelR3:setColor(G_ColorYellowPro);
        else
            self.m_labelR3:setColor(G_ColorWhite);
        end
        if playerVoApi:getR4() > protectResource then
            self.m_labelR4:setColor(G_ColorYellowPro);
        else
            self.m_labelR4:setColor(G_ColorWhite);
        end
        if playerVoApi:getGold() > protectResource then
            self.m_labelGold:setColor(G_ColorYellowPro);
        else
            self.m_labelGold:setColor(G_ColorWhite);
        end
        
        local r1P, r2P, r3P, r4P, rGP = buildingVoApi:getResourcePercent();
        
        local r5TimerSprite = tolua.cast(self.mySpriteRight:getChildByTag(10), "CCProgressTimer")
        r5TimerSprite:setPercentage(rGP);
        
        local r1TimerSprite = tolua.cast(self.mySpriteRight:getChildByTag(11), "CCProgressTimer")
        r1TimerSprite:setPercentage(r1P);
        
        local r2TimerSprite = tolua.cast(self.mySpriteRight:getChildByTag(12), "CCProgressTimer")
        r2TimerSprite:setPercentage(r2P);
        
        local r3TimerSprite = tolua.cast(self.mySpriteRight:getChildByTag(13), "CCProgressTimer")
        r3TimerSprite:setPercentage(r3P);
        
        local r4TimerSprite = tolua.cast(self.mySpriteRight:getChildByTag(14), "CCProgressTimer")
        r4TimerSprite:setPercentage(r4P);
    end
    
    --外出打仗
    local travelTimeTab = attackTankSoltVoApi:getLeftTimeAll()
    self:showTravelIcon(travelTimeTab)
    
    --幸运抽奖图标
    if base.dailyAcYouhuaSwitch == 1 then
    else
        if FuncSwitchApi:isEnabled("luck_lottery") == false then
        else
            local hasReward = dailyVoApi:isFree()
            if hasReward then
                if self.m_flagTab.dailyHasReward == false then
                    self:switchDailyIcon()
                    self.m_flagTab.dailyHasReward = true
                end
            elseif self.m_flagTab.dailyHasReward == true then
                self:switchDailyIcon()
                self.m_flagTab.dailyHasReward = false
            end
        end
    end
    
    --新手7天礼包
    local newGiftsState = newGiftsVoApi:hasReward()
    if newGiftsState ~= self.m_flagTab.hasNewGifts then
        self:switchNewGiftsIcon()
        self.m_flagTab.hasNewGifts = newGiftsState
        self:resetLeftIconPos()
    end
    --7天之后显示签到
    if base.dailyAcYouhuaSwitch == 1 then
    else
        if newGiftsState == -1 then
            local isTodaySign = signVoApi:isTodaySign()
            -- if canSign>0 then
            --     canSign=1
            -- end
            if isTodaySign ~= self.m_flagTab.isTodaySign then
                self:switchSignIcon()
                self.m_flagTab.isTodaySign = isTodaySign
            end
        end
    end
    
    --任务
    local tflag = taskVoApi:getRefreshFlag()
    if tflag == 0 or self.isNewGuideShow ~= newGuidMgr:isNewGuiding() then
        if self.isNewGuideShow ~= newGuidMgr:isNewGuiding() then
            self.isNewGuideShow = newGuidMgr:isNewGuiding()
            self.m_lastShowTime = base.serverTime
        end
        self:switchTaskIcon()
    else
        if (self.m_lastShowTime + self.m_showInterval) < base.serverTime then
            if self.m_mainTaskBg ~= nil then
                self:switchMainTask()
            end
        end
    end
    if self.m_mtRefresh == true then
        -- local mtSwitch=CCUserDefault:sharedUserDefault():getIntegerForKey("gameSettings_mainTaskGuide")
        -- if mtSwitch==2 then
        self.m_lastShowTime = base.serverTime
        -- end
        self:switchMainTask()
        self.m_mtRefresh = false
    end
    
    --每日领奖图标
    local daily_award = base.daily_award
    if G_isToday(daily_award) then
        if self.m_flagTab.dailyRewardGems == true then
            self:switchDailyRewardIcon()
            self.m_flagTab.dailyRewardGems = false
            self:resetLeftIconPos()
        end
    elseif self.m_flagTab.dailyRewardGems == false then
        self:switchDailyRewardIcon()
        self.m_flagTab.dailyRewardGems = true
        self:resetLeftIconPos()
    end
    --活动
    -- local newYearReward=activityVoApi:canReward("newyear")
    -- if newYearReward~=self.m_flagTab.hasNewYearReward then
    -- self:switchNewYearIcon()
    -- self.m_flagTab.hasNewYearReward=newYearReward
    -- self:resetLeftIconPos()
    -- end
    
    --敌军来袭倒计时
    local isArrive, attackerName,islandType = enemyVoApi:enemyArrive()
    self:showEnemyComingIcon(isArrive, attackerName, islandType)
    --协防
    self:switchHelpDefendIcon()
    --vip图标
    self:switchVipIcon()
    
    --聊天
    self:setLastChat()
    
    --搜索默认值
    if self.m_labelX ~= nil and self.m_labelX:getString() == "-1" then
        if playerVoApi:getMapX() ~= -1 then
            self.m_lastSearchXValue = playerVoApi:getMapX()
            self.m_labelX:setString(self.m_lastSearchXValue)
        end
    end
    
    if self.m_labelY ~= nil and self.m_labelY:getString() == "-1" then
        if playerVoApi:getMapY() ~= -1 then
            self.m_lastSearchYValue = playerVoApi:getMapY()
            self.m_labelY:setString(self.m_lastSearchYValue)
            local allianceName, banner
            if allianceVoApi:isHasAlliance() then
                allianceName = allianceVoApi:getSelfAlliance().name
                banner = allianceVoApi:getSelfAlliance().banner
            end
            local params = {uid = playerVoApi:getUid(), oldx = 0, oldy = 0, newx = self.m_lastSearchXValue, newy = self.m_lastSearchYValue, id = 100, oid = playerVoApi:getUid(), name = playerVoApi:getPlayerName(), type = 6, level = 1, x = self.m_lastSearchXValue, y = self.m_lastSearchYValue, ptEndTime = playerVoApi:getProtectEndTime(), power = playerVoApi:getPlayerPower(), rank = playerVoApi:getRank(), pic = playerVoApi:getPic(), allianceName = allianceName, banner = banner}
            chatVoApi:sendUpdateMessage(3, params)
        end
    end
    
    if self.m_showWelcome == true then
        -- if  GM_UidCfg[playerVoApi:getUid()] then
        --   do return end
        -- end
        if newGuidMgr:isNewGuiding() == false then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("welcomePlayerTip", {playerVoApi:getPlayerName()}), 30, nil, true)
        end
        self.m_showWelcome = false
    end
    if newGuidMgr:isNewGuiding() then
        self:resetLeftFlicker(false)
    else
        self:resetLeftFlicker(true)
    end
    if base.isNd == 1 and base.nextDay == nil and self.isShowNextDay == false and G_getWeeTs(base.serverTime) ~= G_getWeeTs(playerVoApi:getRegdate()) and newGuidMgr:isNewGuiding() == false then
        
        self.isShowNextDay = true
        popDialog:createPowerSurge(sceneGame, 30, getlocal("powerSurgeTitle2"), getlocal("powerSurgeDesc2"), 2)
        self.m_isShowDaily = true
        
    elseif self.m_isShowDaily == nil or self.m_isShowDaily == false then
        self.m_isShowDaily = true
        if FuncSwitchApi:isEnabled("luck_lottery") == false then
        else
            if dailyVoApi:isFreeByType(1) and newGuidMgr:isNewGuiding() == false then
                if platCfg.platBeimeiNewGuide[G_curPlatName()] ~= nil then
                    
                else
                    if G_isIOS() == true then
                        self:showDailyDialog()
                    end
                end
                
            end
            self:showAct()
        end
    end
    --弹出公告面板（有的平台会有需求 根据平台判断）
    
    --显示公告
    -- self:switchNoticeIcon()
    
    local acAndNoteState = activityVoApi:hadNewActivity() == true or noteVoApi:hadNewNote() == true or activityVoApi:oneCanReward() == true or dailyActivityVoApi:oneCanReward()
    local hadAcAndNote = activityVoApi:hadActivity() or noteVoApi:hadNote() or dailyActivityVoApi:getActivityNum() > 0
    local newAcAndNoteNum = activityVoApi:newAcNum() + noteVoApi:newNoteNum()
    if base.dailyAcYouhuaSwitch == 1 then
        newAcAndNoteNum = newAcAndNoteNum + dailyActivityVoApi:canRewardNum()
    end
    
    if self.m_flagTab.acAndNoteState ~= acAndNoteState or self.m_flagTab.hadAcAndNote ~= hadAcAndNote or self.m_flagTab.newAcAndNoteNum ~= newAcAndNoteNum then -- 判断是否需要刷新
        if self.m_flagTab.acAndNoteState ~= acAndNoteState then
            self.m_flagTab.acAndNoteState = acAndNoteState
        end
        if self.m_flagTab.hadAcAndNote ~= hadAcAndNote then
            self.m_flagTab.hadAcAndNote = hadAcAndNote
        end
        
        if self.m_flagTab.newAcAndNoteNum ~= newAcAndNoteNum then
            self.m_flagTab.newAcAndNoteNum = newAcAndNoteNum
        end
        self:switchActivityAndNoteIcon()
        self:resetLeftIconPos()
    end
    self:switchMilitaryOrdersIcon()
    self:switchStewardIcon()
    
    self:showFBInviteBtn()
    -- 在线礼包
    self:showOnlincePackageBtn()
    --首充奖励按钮
    self:showFirstRechargeBtn()
    -- 礼包推送
    self:showGiftPush()
    --腾讯应用宝礼包
    self:showPlatformAwards()
    
    if self.onlinePackageBtn ~= nil then
        local dialog = self.onlinePackageBtn.dialog
        if dialog ~= nil and dialog:checkIfBoxOpen() == true then
            dialog:updateOnlinePackage()
        end
    end
    
    --加入军团提示面板，统率书图标
    self:showAddAllianceBtn()
    
    -- 腾讯活动
    self:showTenxunhuodong()
    
    --韩国全平台广告（包括卡考）
    self:showKoreaAdver()
    --[[
    local function callback(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
 
        end
    end
    local dataTb={p2=1}
    socketHelper:adminAddprop(dataTb,callback)
    ]]
    
    newGuidMgr:JudgeNewStageGuid()
    if(self.powerLb and self.playerPower ~= playerVoApi:getPlayerPower()) then
        -- and GM_UidCfg[playerVoApi:getUid()] == nil
        self.playerPower = playerVoApi:getPlayerPower()
        self.powerLb:setString(FormatNumber(self.playerPower))
    end
    
    --军团跨服战提取军饷
    if newGuidMgr:isNewGuiding() == false and base.allShowedCommonDialog == 0 and SizeOfTable(G_SmallDialogDialogTb) == 0 then
        if self.isShowFundsExtract == true then
        else
            if base.serverWarTeamSwitch == 1 then
                if serverWarTeamVoApi and serverWarTeamVoApi.getServerWarId then
                    local warId = playerVoApi:getServerWarTeamId()
                    local curWarId = serverWarTeamVoApi:getServerWarId()
                    if curWarId and warId then
                        if warId == curWarId then
                        else
                            if serverWarTeamVoApi and serverWarTeamVoApi.extractFunds then
                                serverWarTeamVoApi:extractFunds(2)
                            end
                            self.isShowFundsExtract = true
                        end
                    end
                end
            else
                if serverWarTeamVoApi and serverWarTeamVoApi.extractFunds then
                    serverWarTeamVoApi:extractFunds(2)
                end
                self.isShowFundsExtract = true
            end
        end
    end
    --群雄争霸提取军饷
    if newGuidMgr:isNewGuiding() == false and base.allShowedCommonDialog == 0 and SizeOfTable(G_SmallDialogDialogTb) == 0 then
        if self.isShowFundsExtract1 == true then
        else
            if base.serverWarLocalSwitch == 1 and serverWarLocalVoApi then
                if serverWarLocalVoApi:checkStatus() >= 30 and serverWarLocalVoApi:getFunds() > 0 then
                    serverWarLocalVoApi:extractFunds(2)
                    self.isShowFundsExtract1 = true
                end
            else
                usegems = playerVoApi:getServerWarLocalUsegems()
                if usegems and usegems > 0 then
                    serverWarLocalVoApi:extractFunds(2)
                    self.isShowFundsExtract1 = true
                end
            end
        end
    end
    self:refreshGift()
    
    local ssbbFlag = true
    if ltzdzVoApi and ltzdzVoApi:isOpen() and ltzdzVoApi:checkIsActive() == true then
        local playerLv = playerVoApi:getPlayerLevel()
        if playerLv >= ltzdzVoApi:getOpenLv() and ltzdzVoApi:checkIsActive() == true then
            if(buildings.allBuildings)then
                for k, v in pairs(buildings.allBuildings) do
                    if(v:getType() == 16)then
                        ssbbFlag = false
                        v:setSpecialIconVisible(8, true)
                        break
                    end
                end
            end
        end
    end
    
    if base.dimensionalWarSwitch == 1 then
        if dimensionalWarVoApi and dimensionalWarVoApi:getIsInit() ~= true then
            dimensionalWarVoApi:setIsInit(true)
            dimensionalWarVoApi:getApplyData(nil, ssbbFlag)
        end
    end
    
    if self.isNewGuideShow == false and base.isGlory == 1 and self.gloryBg == nil then
        self:showGloryNow()
    end
    
    if base.isGlory == 1 and self.gloryBg ~= nil then
        local newLevel = playerVoApi:getPlayerLevel()
        local buildIcon = tolua.cast(self.gloryBg:getChildByTag(1641), "CCSprite")
        if self.m_gloryPic ~= nil and self.m_gloryPic ~= playerVoApi:getPlayerBuildPic(newLevel) then
            print("update buildingLevel~~~~~~~")
            
            self.m_gloryPic = playerVoApi:getPlayerBuildPic(newLevel)
            if buildIcon ~= nil then
                buildIcon:stopAllActions()
                buildIcon:removeFromParentAndCleanup(true)
                buildIcon = CCSprite:createWithSpriteFrameName(self.m_gloryPic)
                buildIcon:setScaleX(self.gloryBg:getContentSize().width / buildIcon:getContentSize().width)
                buildIcon:setScaleY(self.gloryBg:getContentSize().width / buildIcon:getContentSize().width)
                buildIcon:setAnchorPoint(ccp(0.5, 0.5))
                buildIcon:setPosition(getCenterPoint(self.gloryBg))
                self.gloryBg:addChild(buildIcon)
            end
        end
        -- print("gloryVo---->",gloryVo.curBoom ,gloryVo.curBoomMax)
        self.isGloryOver = gloryVoApi:isGloryOver()
        if self.isGloryOver == true then
            local renewPic = tolua.cast(self.gloryBg:getChildByTag(771), "CCSprite")
            if renewPic ~= nil then
                renewPic:stopAllActions()
                renewPic:removeFromParentAndCleanup(true)
                renewPic = nil
            end
            if buildIcon ~= nil and tolua.cast(buildIcon:getChildByTag(881), "CCSprite") == nil then
                self:fireBuildingAction(buildIcon)
            end
        elseif gloryVo and gloryVo.curBoom < gloryVo.curBoomMax then
            if buildIcon ~= nil then
                local fireAc = tolua.cast(buildIcon:getChildByTag(881), "CCSprite")
                if fireAc ~= nil then
                    fireAc:stopAllActions()
                    fireAc:removeFromParentAndCleanup(true)
                    fireAc = nil
                end
            end
            if tolua.cast(self.gloryBg:getChildByTag(771), "CCSprite") == nil then
                self:renewGlory()
            end
        else
            local renewPic = tolua.cast(self.gloryBg:getChildByTag(771), "CCSprite")
            if renewPic ~= nil then
                renewPic:stopAllActions()
                renewPic:removeFromParentAndCleanup(true)
                renewPic = nil
            end
            if buildIcon ~= nil then
                local fireAc = tolua.cast(buildIcon:getChildByTag(881), "CCSprite")
                if fireAc ~= nil then
                    fireAc:stopAllActions()
                    fireAc:removeFromParentAndCleanup(true)
                    fireAc = nil
                end
            end
        end
    end
    
    if self and self.goldButtonBtn then
        local rechargeFlick = false
        local firstRechargeCanReward = false
        if acFirstRechargeVoApi then
            local isReward, isShowDouble, isCanReward = acFirstRechargeVoApi:canReward()
            if isReward == true and isCanReward == true then
                firstRechargeCanReward = true
            end
        end
        if firstRechargeCanReward == true or (base.monthlyCardOpen == 1 and vipVoApi and vipVoApi:checkCanGetMonthlyCardReward() == true) then
            rechargeFlick = true
        end
        if self.rechargeFlick ~= rechargeFlick then
            G_removeFlicker(self.goldButtonBtn)
            if rechargeFlick == true then
                if G_getGameUIVer()==2 then
                    G_addGoldRectFlicker(self.goldButtonBtn, 1, 1, nil, 0)
                else
                    G_addRectFlicker(self.goldButtonBtn, 2.2, 1.2, nil, 0)
                end
            end
            self.rechargeFlick = rechargeFlick
        end
    end
    
    if base.scroll == 1 and jumpScrollMgr:isGuiding() then
        jumpScrollMgr:showScrollMessage()
    end
    --登录后是否显示通知面板的处理（目前是弹出三周年庆的通知面板，每日首次登录弹一次）
    local flag = noticeMgr:isShowNoticeDialog()
    if flag == true then
        require "luascript/script/game/scene/gamedialog/noticeDialog"
        local nd = noticeDialog:new()
        nd:showNoticeDialog(10)
    end
    
    if dailyNewsVoApi then
        dailyNewsVoApi:isPopDialog()
    end
    
    --问卷调查图标
    local isShowWjdcIcon = false
    if acWjdcVoApi and acWjdcVoApi.isShowIcon then
        local wjdcHadReward = acWjdcVoApi:isShowIcon()
        if wjdcHadReward == false then
            isShowWjdcIcon = true
        end
    end
    if isShowWjdcIcon == true and newGuidMgr:isNewGuiding() == false then
        if self.wjdcIconBg == nil then
            local function showWjdcDialog(...)
                if G_checkClickEnable() == false then
                    do
                        return
                    end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                if newGuidMgr:isNewGuiding() then
                    do return end
                end
                PlayEffect(audioCfg.mouseClick)
                
                acWjdcVoApi:showWjdcDialog(3)
            end
            if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                self.wjdcIconBg = LuaCCSprite:createWithSpriteFrameName("Icon_BG.png", showWjdcDialog)
            else
                self.wjdcIconBg = LuaCCSprite:createWithSpriteFrameName("Icon_BG1.png", showWjdcDialog)
            end
            self.wjdcIconBg:setIsSallow(true)
            self.wjdcIconBg:setTouchPriority(-24)
            self.myUILayer:addChild(self.wjdcIconBg, 1)
            self.m_rightTopIconTab.icon9 = self.wjdcIconBg
            self:resetRightTopIconPos()
            local wjdcIcon = LuaCCSprite:createWithSpriteFrameName("acWjdcIcon.png", showWjdcDialog)
            wjdcIcon:setScale(0.7)
            wjdcIcon:setPosition(getCenterPoint(self.wjdcIconBg))
            self.wjdcIconBg:addChild(wjdcIcon)
            if G_getGameUIVer()==2 then
                G_addNewMainUIRectFlicker(self.wjdcIconBg, 78/100, 78/100)
            else
                G_addFlicker(self.wjdcIconBg, 2, 2)
            end
        end
    else
        if self.wjdcIconBg then
            self.wjdcIconBg:removeFromParentAndCleanup(true)
            self.wjdcIconBg = nil
            self.m_rightTopIconTab.icon9 = nil
            self:resetRightTopIconPos()
        end
    end
    
    --战机革新相关刷新
    if self.m_luaSp8 then
        if self.studySid then --刷新战机革新研究技能的倒计时
            local studySkillSp = self.m_luaSp8:getChildByTag(108)
            if studySkillSp and tolua.cast(studySkillSp, "CCSprite") then
                local timerLb = studySkillSp:getChildByTag(5)
                local lefttime = planeVoApi:getStudyLeftTime(self.studySid)
                if lefttime >= 0 and timerLb and tolua.cast(timerLb, "CCLabelTTF") then
                    timerLb:setString(GetTimeStr(lefttime))
                end
            end
        end
        --检测是否有可以使用的主动技能
        local tipSp = self.m_luaSp8:getChildByTag(109)
        local flag = planeVoApi:isNewActiveSkillUseSlotEmpty()
        if flag == true then
            if tipSp == nil then
                local tipWidth = 30
                if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                    tipSp = CCSprite:createWithSpriteFrameName("IconTip.png")
                else
                    tipSp = CCSprite:createWithSpriteFrameName("IconTip1.png")
                end
                tipSp:setTag(109)
                tipSp:setScale(tipWidth / tipSp:getContentSize().width)
                tipSp:setPosition(self.m_luaSp8:getContentSize().width - tipWidth / 2, self.m_luaSp8:getContentSize().height - tipWidth / 2)
                self.m_luaSp8:addChild(tipSp, 3)
            end
        else
            if tipSp and tolua.cast(tipSp, "CCSprite") then
                tipSp:removeFromParentAndCleanup(true)
                tipSp = nil
            end
        end
    end
    migrationVoApi:checkShow()
    --神秘宝箱
    self:showMysteryBox()
    --限时惊喜
    self:showFlashSale()
end

function mainUI:showAct()
    if platCfg.platBeimeiNewGuide[G_curPlatName()] ~= nil then
        if self.isShowAct == false and newGuidMgr:isNewGuiding() == false then
            -- activityVoApi:updateAllShowState()
            -- local acAndNote = activityAndNoteDialog:new()
            -- local tbArr={getlocal("activity"),getlocal("dailyActivity_title"),getlocal("note")}
            -- local vd = acAndNote:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("activityAndNote_title"),true,3);
            -- if  noteVoApi:hadNewNote() == true then
            --     acAndNote:tabClick(2)
            -- end
            -- sceneGame:addChild(vd,3);
            self.isShowAct = true
        end
        
    end
end
-- 显示领奖中心的按钮
function mainUI:showRewardCenterBtn()
    if newGuidMgr:isNewGuiding() == true then
        return
    end
    local function callback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true and sData then
            local rdialog = rewardCenterDialog:new()
            local vd = rdialog:initTableView(4)
            sceneGame:addChild(vd, 99)
        end
    end
    
    if rewardCenterVoApi and rewardCenterVoApi:isShowRewardBtn() == true then
        if self and self.rewardCenterBtn == nil then
            local function onclick(...)
                
                -- if rewardCenterVoApi:getNewNum()>0 or rewardCenterVoApi:isHasReward()==false then
                socketHelper:getRewardCenterList(1, rewardCenterVoApi:getMaxNum(), callback)
                -- else
                -- local rdialog=rewardCenterDialog:new()
                -- local vd=rdialog:initTableView(4)
                -- sceneGame:addChild(vd,3)
                -- end
                
            end
            CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/bubbleImage.plist")
            self.rewardCenterBtnBg = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
            self.rewardCenterBtnBg:setOpacity(0)
            self.rewardCenterBtnBg:setAnchorPoint(ccp(0.5, 0.5))
            self.myUILayer:addChild(self.rewardCenterBtnBg, 2)
            self.rewardCenterBtnBg:setPosition(ccp(G_VisibleSizeWidth - self.rewardCenterBtnBg:getContentSize().width / 2 - 50, 330))
            for i = 1, 2 do
                local realLight = CCSprite:createWithSpriteFrameName("equipShine.png")
                realLight:setAnchorPoint(ccp(0.5, 0.5))
                realLight:setScale(1.4)
                realLight:setPosition(getCenterPoint(self.rewardCenterBtnBg))
                self.rewardCenterBtnBg:addChild(realLight)
                local roteSize = i == 1 and 360 or - 360
                local rotate1 = CCRotateBy:create(4, roteSize)
                local repeatForever = CCRepeatForever:create(rotate1)
                realLight:runAction(repeatForever)
            end
            
            self.rewardCenterBtn = LuaCCSprite:createWithSpriteFrameName("friendBtn.png", onclick)
            self.rewardCenterBtn:setAnchorPoint(ccp(0.5, 0.5))
            -- self.rewardCenterBtn:setPosition(ccp(G_VisibleSizeWidth-self.rewardCenterBtn:getContentSize().width/2-120,330))
            -- self.rewardCenterBtn:setScale(0.8)
            self.rewardCenterBtn:setPosition(ccp(self.rewardCenterBtnBg:getContentSize().width / 2, self.rewardCenterBtnBg:getContentSize().height / 2))
            self.rewardCenterBtn:setIsSallow(true)
            self.rewardCenterBtn:setTouchPriority(-24)
            self.rewardCenterBtnBg:addChild(self.rewardCenterBtn, 1);
            
            --
            local nameTip
            nameLb = GetTTFLabel(getlocal("rewardCenterTitle"), 20)
            nameLb:setAnchorPoint(ccp(0.5, 0))
            if G_checkUseAuditUI()==true then
                nameTip =LuaCCScale9Sprite:createWithSpriteFrameName("building_name_tishen.png",CCRect(52, 24, 1, 1),function ()end)
                nameLb:setColor(ccc3(255, 255, 255))
            else
                nameTip = CCSprite:create("public/building_name.png")
                nameLb:setColor(ccc3(255, 255, 0))
            end 
            
            nameTip:setScaleY(0.7)
            nameTip:setScaleX((nameLb:getContentSize().width + 25) / nameTip:getContentSize().width)
            nameTip:setAnchorPoint(ccp(0.5, 0))
            if G_checkUseAuditUI() == true or G_getGameUIVer()==2 then
                nameLb:setPosition(ccp(self.rewardCenterBtnBg:getContentSize().width * 0.5, 55))
                nameTip:setPosition(ccp(self.rewardCenterBtnBg:getContentSize().width * 0.5, 45))
            else
                nameLb:setPosition(ccp(self.rewardCenterBtnBg:getContentSize().width * 0.5, 60))
                nameTip:setPosition(ccp(self.rewardCenterBtnBg:getContentSize().width * 0.5, 50))
            end
            self.rewardCenterBtnBg:addChild(nameTip, 2)
            self.rewardCenterBtnBg:addChild(nameLb, 3)
            
            local time = 0.14
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
            self.rewardCenterBtn:runAction(repeatForever)
        end
    else
        if self and self.rewardCenterBtn ~= nil then
            self.rewardCenterBtn:stopAllActions()
            self.rewardCenterBtn:removeFromParentAndCleanup(true)
            self.rewardCenterBtn = nil
            CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/bubbleImage.plist")
        end
        if self and self.rewardCenterBtnBg ~= nil then
            self.rewardCenterBtnBg:removeFromParentAndCleanup(true)
            self.rewardCenterBtnBg = nil
        end
    end
end

--显示神秘宝箱
function mainUI:showMysteryBox()
    if acMysteryBoxVoApi and acMysteryBoxVoApi:isCanEnter(false) == true then
        local vo = acMysteryBoxVoApi:getAcVo()
        if vo and activityVoApi:isStart(vo) == true then
            local function onClickMysteryBox()
                if acMysteryBoxVoApi:isCanEnter(true) == true then
                    local layerNum = 3
                    local td = acMysteryBoxDialog:new(layerNum)
                    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, nil, nil, acMysteryBoxVoApi:getActiveTitle(), true, layerNum)
                    sceneGame:addChild(dialog, layerNum)
                end
            end
            if self.mysteryBoxSp == nil then
                self.mysteryBoxSp = LuaCCSprite:createWithSpriteFrameName("mysteryBox_icon.png", onClickMysteryBox)
                self.mysteryBoxSp:setAnchorPoint(ccp(0.5, 0.5))
                self.mysteryBoxSp:setPosition(ccp(G_VisibleSizeWidth - self.mysteryBoxSp:getContentSize().width / 2 - 400, G_VisibleSizeHeight - 185))
                self.mysteryBoxSp:setScale(0.8)
                self.mysteryBoxSp:setIsSallow(true)
                self.mysteryBoxSp:setTouchPriority(-24)
                self.myUILayer:addChild(self.mysteryBoxSp, 1)
                self.m_rightTopIconTab.icon10 = self.mysteryBoxSp
                self:resetRightTopIconPos()
            end
        else
            if self.mysteryBoxSp then
                self.mysteryBoxSp:removeFromParentAndCleanup(true)
                self.mysteryBoxSp = nil
            end
            if self.m_rightTopIconTab.icon10 then
                self.m_rightTopIconTab.icon10 = nil
                self:resetRightTopIconPos()
            end
        end
    end
end

--显示限时惊喜
function mainUI:showFlashSale()
    if acFlashSaleVoApi then
        local vo = acFlashSaleVoApi:getAcVo()
        if vo and activityVoApi:isStart(vo) == true then
            local function onClickMysteryBox()
                acFlashSaleVoApi:netRequest("get", nil, function()
                    local layerNum = 3
                    local td = acFlashSaleDialog:new(layerNum)
                    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, nil, nil, getlocal("acFlashSale_title"), true, layerNum)
                    sceneGame:addChild(dialog, layerNum)
                end)
            end
            if self.flashSaleSp == nil then
                self.flashSaleSp = LuaCCSprite:createWithSpriteFrameName("acFlashSale_icon.png", onClickMysteryBox)
                self.flashSaleSp:setAnchorPoint(ccp(0.5, 0.5))
                self.flashSaleSp:setPosition(ccp(G_VisibleSizeWidth - self.flashSaleSp:getContentSize().width / 2 - 400, G_VisibleSizeHeight - 185))
                self.flashSaleSp:setScale(0.8)
                self.flashSaleSp:setIsSallow(true)
                self.flashSaleSp:setTouchPriority(-24)
                self.myUILayer:addChild(self.flashSaleSp, 1)
                self.m_rightTopIconTab.icon11 = self.flashSaleSp
                self:resetRightTopIconPos()
            end
            if acFlashSaleVoApi:canReward() then
                if self.flashSaleFlicker == nil then
                    if G_getGameUIVer()==2 then
                        self.flashSaleFlicker = G_addNewMainUIRectFlicker(self.flashSaleSp, 1 , 1 )
                    else
                        self.flashSaleFlicker = G_addFlicker(self.flashSaleSp, 1 / (self.m_iconScaleX / 2), 1 / (self.m_iconScaleY / 2))
                    end
                end
            else
                if self.flashSaleFlicker ~= nil then
                    self.flashSaleFlicker:removeFromParentAndCleanup(true)
                    self.flashSaleFlicker = nil
                end
            end
        else
            if self.flashSaleSp then
                self.flashSaleSp:removeFromParentAndCleanup(true)
                self.flashSaleSp = nil
            end
            if self.m_rightTopIconTab.icon11 then
                self.m_rightTopIconTab.icon11 = nil
                self:resetRightTopIconPos()
            end
        end
    end
end

function mainUI:showFirstRechargeBtn()
    local vo = activityVoApi:getActivityVo("firstRecharge")
    if newGuidMgr:isNewGuiding() == false and platCfg.platShowFirstRechargeBtn[G_curPlatName()] ~= nil and vo ~= nil and activityVoApi:isStart(vo) and vo.over ~= nil and vo.over == false and vo.hasData == true then
        local function onclick()
            self.isClickFirstRechargeBtn = true
            if self.firstRechargeFlicker ~= nil then
                self.firstRechargeFlicker:removeFromParentAndCleanup(true)
                self.firstRechargeFlicker = nil
            end
            local openDialog = acFirstRechargeDialog:new()
            openDialog:initVo(vo)
            openDialog:init(3)
        end
        if self.firstRechargeBg == nil then
            if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                self.firstRechargeBg = LuaCCSprite:createWithSpriteFrameName("firstRechargeIcon.png", onclick)
                self.firstRechargeBg:setPosition(ccp(G_VisibleSizeWidth - self.firstRechargeBg:getContentSize().width / 2 - 400, G_VisibleSizeHeight - 185))
            else
                self.firstRechargeBg = LuaCCSprite:createWithSpriteFrameName("firstRechargeIcon1.png", onclick)
                self.firstRechargeBg:setPosition(ccp(G_VisibleSizeWidth - self.firstRechargeBg:getContentSize().width / 2 - 400, G_VisibleSizeHeight - 156))
            end
            self.firstRechargeBg:setAnchorPoint(ccp(0.5, 0.5))
            self.firstRechargeBg:setScale(0.78)
            self.firstRechargeBg:setIsSallow(true)
            self.firstRechargeBg:setTouchPriority(-24)
            self.myUILayer:addChild(self.firstRechargeBg, 1);
            self.m_rightTopIconTab.icon3 = self.firstRechargeBg
            self:resetRightTopIconPos()
        end
        
        if self.isClickFirstRechargeBtn == false then
            if self.firstRechargeFlicker == nil then
                if G_getGameUIVer()==2 then
                    self.firstRechargeFlicker = G_addNewMainUIRectFlicker(self.firstRechargeBg, 1 , 1 )
                else
                    self.firstRechargeFlicker = G_addFlicker(self.firstRechargeBg, 1 / (self.m_iconScaleX / 2), 1 / (self.m_iconScaleY / 2))
                end
            end
        else
            if self.firstRechargeFlicker ~= nil then
                self.firstRechargeFlicker:removeFromParentAndCleanup(true)
                self.firstRechargeFlicker = nil
            end
        end
    else
        
        if self.firstRechargeBg ~= nil then
            --G_removeFlicker(self.firstRecharBg)
            self.firstRechargeBg:removeFromParentAndCleanup(true)
            self.firstRechargeBg = nil
            
        end
        if self.m_rightTopIconTab.icon3 ~= nil then
            self.m_rightTopIconTab.icon3 = nil
            self:resetRightTopIconPos()
        end
    end
end

-- 礼包推送
function mainUI:showGiftPush(...)
    require "luascript/script/game/gamemodel/activity/giftPushVoApi"
    if newGuidMgr:isNewGuiding() == false and playerVoApi:getPlayerLevel() >= giftPushVoApi:getLevelLimit() and playerVoApi:getXsjxPop() == true then
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        spriteController:addPlist("public/xsjx.plist")
        spriteController:addTexture("public/xsjx.png")
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        if self.giftPushBtn == nil then
            local function onclick(...)
                require "luascript/script/game/scene/gamedialog/giftPushSmallDialog"
                giftPushSmallDialog:showDialog(3)
            end
            if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                self.giftPushBtn = LuaCCSprite:createWithSpriteFrameName("xsjx_icon.png", onclick)
                self.giftPushBtn:setAnchorPoint(ccp(0.5, 0.5))
                self.giftPushBtn:setPosition(ccp(G_VisibleSizeWidth - self.giftPushBtn:getContentSize().width / 2 - 400, G_VisibleSizeHeight - 185))
            else
                self.giftPushBtn = LuaCCSprite:createWithSpriteFrameName("xsjx_icon1.png", onclick)
                self.giftPushBtn:setAnchorPoint(ccp(0.5, 0.5))
                self.giftPushBtn:setPosition(ccp(G_VisibleSizeWidth - self.giftPushBtn:getContentSize().width / 2 - 400, G_VisibleSizeHeight - 156))
            end
            self.giftPushBtn:setScale(0.8)
            self.giftPushBtn:setIsSallow(true)
            self.giftPushBtn:setTouchPriority(-24)
            self.myUILayer:addChild(self.giftPushBtn, 1);
            self.m_rightTopIconTab.icon4 = self.giftPushBtn
            self:resetRightTopIconPos()
        end
        
        if not self.giftPushFlicker and playerVoApi:getRechargeNum() >= giftPushVoApi:rechargeNum() then
            if G_getGameUIVer()==2 then
                self.giftPushFlicker = G_addNewMainUIRectFlicker(self.giftPushBtn, 1, 1)
            else
                self.giftPushFlicker = G_addFlicker(self.giftPushBtn, 3.0, 3.0)
            end
        end
        if base.xsjx == 1 and playerVoApi:getRechargeNum() < giftPushVoApi:rechargeNum() and playerVoApi:isXsjxValid() == false then
            playerVoApi:setXsjxPop()
            if giftPushVoApi:isValid() == true then
                giftPushVoApi:refreshData()
            end
        end
    else
        if base.xsjx == 1 and playerVoApi:getXsjxPop() == false and playerVoApi:isXsjxValid() == true and giftPushVoApi:isValid() == true then
            giftPushVoApi:refreshData()
        end
        
        if self.giftPushBtn then
            self.giftPushBtn:removeFromParentAndCleanup(true)
            self.giftPushBtn = nil
        end
        if self.m_rightTopIconTab.icon4 ~= nil then
            self.m_rightTopIconTab.icon4 = nil
            self:resetRightTopIconPos()
        end
    end
end

function mainUI:showPlatformAwards()
    if newGuidMgr:isNewGuiding() == true then
        do return end
    end
    
    local showAwards = {}
    if (G_curPlatName() == "androidtencently") and self.isRequestPlatformAwards == false then
        
        --local httpUrl="http://devsdk.raysns.com/tank_rayapi3/index.php/androidtencentawardslist"
        local httpUrl = "http://tank-android-01.raysns.com/tank_rayapi/index.php/androidtencentawardslist"
        local reqStr = "pid="..base.platformUserId.."&token="..base.token
        --local reqStr="pid=".."TX_225689C9BBBCC131C7A1967FF6E10B0A".."&token=".."A4F5D01440308509035AA79A38766F7D"
        
        local retStr = G_sendHttpRequestPost(httpUrl, reqStr)
        print("..............retStr", retStr)
        if(retStr ~= "")then
            -- retStr="[[1609,1],[1610,1],[1611,2],[1612,2]]"
            showAwards = G_Json.decode(retStr)
            if showAwards == nil or (showAwards and type(showAwards) ~= "table") or (showAwards and SizeOfTable(showAwards) <= 0) or (showAwards and showAwards[1] and type(showAwards[1]) ~= "table") then
                self.isRequestPlatformAwards = true
                self.isShowplatformAwards = false
            else
                --showAwards=Split(retStr,"_")
                
                for k, v in pairs(showAwards) do
                    if v and type(v) == "table" and v[1] then
                        showAwards[k][1] = tonumber(v[1])
                    end
                end
                playerVoApi:setPlatformCanReward(showAwards)
                self.isRequestPlatformAwards = true
                self.isShowplatformAwards = true
            end
        end
    end
    if self.isShowplatformAwards == true then
        local function onclick()
            platformAwardsDialog:create(4, showAwards)
        end
        if self.platformAwardsBg == nil then
            if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                self.platformAwardsBg = LuaCCSprite:createWithSpriteFrameName("Icon_novicePacks.png", onclick)
                self.platformAwardsBg:setAnchorPoint(ccp(0.5, 0.5))
                self.platformAwardsBg:setPosition(ccp(G_VisibleSizeWidth - self.platformAwardsBg:getContentSize().width / 2 - 400, G_VisibleSizeHeight - 185))
            else
                self.platformAwardsBg = LuaCCSprite:createWithSpriteFrameName("Icon_novicePacks1.png", onclick)
                self.platformAwardsBg:setAnchorPoint(ccp(0.5, 0.5))
                self.platformAwardsBg:setPosition(ccp(G_VisibleSizeWidth - self.platformAwardsBg:getContentSize().width / 2 - 400, G_VisibleSizeHeight - 156))
            end
            self.platformAwardsBg:setScale(0.8)
            self.platformAwardsBg:setIsSallow(true)
            self.platformAwardsBg:setTouchPriority(-24)
            self.myUILayer:addChild(self.platformAwardsBg, 1);
            self.m_rightTopIconTab.icon6 = self.platformAwardsBg
            self:resetRightTopIconPos()
        end
        if self.platformAwardsFlicker == nil then
            if G_getGameUIVer()==2 then
                self.platformAwardsFlicker = G_addNewMainUIRectFlicker(self.platformAwardsBg, 1 , 1 )
            else
                self.platformAwardsFlicker = G_addFlicker(self.platformAwardsBg, 1 / (self.m_iconScaleX / 2), 1 / (self.m_iconScaleY / 2))
            end
        end
    else
        
        if self.platformAwardsBg ~= nil then
            --G_removeFlicker(self.firstRecharBg)
            self.platformAwardsBg:removeFromParentAndCleanup(true)
            self.platformAwardsBg = nil
            
        end
        if self.m_rightTopIconTab.icon6 ~= nil then
            self.m_rightTopIconTab.icon6 = nil
            self:resetRightTopIconPos()
        end
    end
end

function mainUI:showOnlincePackageBtn()
    local t = playerVo.onlineTime
    if t == nil or t < 0 then
        do
            return
        end
    end
    
    if newGuidMgr:isNewGuiding() == false and playerVoApi:checkIfGetAllOnlinePackage() == false and base.ifOnlinePackageOpen == 1 then -- 在线礼包没有领取完
        if self.onlinePackageBtn == nil then
            local function onclick()
                if newGuidMgr:isNewGuiding() == true then
                    do
                        return
                    end
                end
                PlayEffect(audioCfg.mouseClick)
                self.onlinePackageBtn.dialog = popDialog:createOnlinePackage(sceneGame, 3)
            end
            local iconBg,icon
            local iconStr = string.match(playerCfg.onlinePackage[playerVo.onlinePackage + 1].icon, 'item_baoxiang_%d+').."_1.png"
            if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                iconBg = LuaCCSprite:createWithSpriteFrameName("Icon_BG.png", onclick);
                iconBg:setAnchorPoint(ccp(0.5, 0.5))
                iconBg:setPosition(ccp(G_VisibleSizeWidth - iconBg:getContentSize().width / 2 - 250, G_VisibleSizeHeight - 185))
                icon = CCSprite:createWithSpriteFrameName(playerCfg.onlinePackage[playerVo.onlinePackage + 1].icon) -- todo 动态获取
            else
                iconBg = LuaCCSprite:createWithSpriteFrameName("Icon_BG1.png", onclick);
                iconBg:setAnchorPoint(ccp(0.5, 0.5))
                iconBg:setPosition(ccp(G_VisibleSizeWidth - iconBg:getContentSize().width / 2 - 250, G_VisibleSizeHeight - 156))
                icon = CCSprite:createWithSpriteFrameName(iconStr) -- todo 动态获取
            end
            self.myUILayer:addChild(iconBg, 1);
            iconBg:setTouchPriority(-24);
            icon:setPosition(getCenterPoint(iconBg))
            iconBg:addChild(icon, 1);
            
            local scaleX = iconBg:getContentSize().width / icon:getContentSize().width
            local scaleY = iconBg:getContentSize().height / icon:getContentSize().height
            icon:setScaleX(scaleX)
            icon:setScaleY(scaleY)
            
            -- 更新按钮状态
            -- local tLable=GetTTFLabel(getlocal("canReward"),30)
            -- tLable:setAnchorPoint(ccp(0.5,0.5))
            -- tLable:setPosition(ccp(icon:getContentSize().width/2,50))
            -- icon:addChild(tLable,1)
            -- tLable:setColor(G_ColorYellowPro)
            -- 时间
            local function cellClick(...)
            end
            
            local timeBg
            if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                timeBg = LuaCCScale9Sprite:createWithSpriteFrameName("IconBgNum.png", CCRect(5, 5, 1, 1), cellClick)
            else
                timeBg = LuaCCScale9Sprite:createWithSpriteFrameName("IconBgNum1.png", CCRect(5, 5, 1, 1), cellClick)
            end
            timeBg:setContentSize(CCSizeMake(100, 30))
            timeBg:setAnchorPoint(ccp(0.5, 0))
            timeBg:setPosition(ccp(icon:getContentSize().width / 2, 0))
            icon:addChild(timeBg, 2)
            
            local needTime = playerVoApi:getLastNeedOnlineTime()
            local showTime = GetTimeForItemStrState(needTime)
            local timeLable = GetTTFLabel(tostring(showTime), 30)
            timeLable:setAnchorPoint(ccp(0.5, 0.5))
            timeLable:setPosition(ccp(timeBg:getContentSize().width / 2, timeBg:getContentSize().height / 2))
            timeBg:addChild(timeLable)
            timeLable:setColor(G_ColorYellowPro)
            
            -- self.onlinePackageBtn={icon=iconBg, tLable = tLable, timeLable = timeLable}
            self.onlinePackageBtn = {icon = iconBg, timeLable = timeLable}
            self.m_rightTopIconTab.icon2 = iconBg
            self:resetRightTopIconPos()
        end
        
        if self.onlinePackageBtn ~= nil then
            local icon = self.onlinePackageBtn.icon
            -- local tLable = self.onlinePackageBtn.tLable
            local timeLable = self.onlinePackageBtn.timeLable
            local flicker = self.onlinePackageBtn.flicker
            local showTime = GetTimeForItemStrState(playerVoApi:getLastNeedOnlineTime())
            timeLable:setString(tostring(showTime))
            if playerVoApi:getLastNeedOnlineTime() == 0 then
                -- tLable:setVisible(true)
                if flicker == nil then
                    if G_getGameUIVer()==2 then
                        flicker = G_addNewMainUIRectFlicker(icon, 78/100, 78/100)
                    else
                        flicker = G_addFlicker(icon, 1 / (self.m_iconScaleX / 2), 1 / (self.m_iconScaleY / 2))
                    end
                end
                self.onlinePackageBtn.flicker = flicker
            else
                -- tLable:setVisible(false)
                if flicker ~= nil then
                    flicker:removeFromParentAndCleanup(true)
                    self.onlinePackageBtn.flicker = nil
                end
            end
        end
    else
        if self.onlinePackageBtn ~= nil then
            local icon = self.onlinePackageBtn.icon
            icon:removeFromParentAndCleanup(true)
            self.onlinePackageBtn = nil
            self.m_rightTopIconTab.icon2 = nil
            self:resetRightTopIconPos()
        end
    end
    
end
function mainUI:showKoreaAdver()
    if newGuidMgr:isNewGuiding() ~= true then
        if ((G_isKakao() == true and G_Version >= 5) or ((G_curPlatName() == "androidzhongshouyouko" or G_curPlatName() == "androidzsykonaver" or G_curPlatName() == "androidzsykoolleh" or G_curPlatName() == "androidzsykotstore") and G_Version >= 9)) and base.isRandomGift == 1 then
            
            if G_checkClickEnable() == false then
                do
                    return
                end
            end
            if self.m_showKoreaAdver == nil then
                local function onclick()
                    if newGuidMgr:isNewGuiding() == true then
                        do
                            return
                        end
                    end
                    
                    local tmpTb = {}
                    tmpTb["action"] = "customAction"
                    tmpTb["parms"] = {}
                    tmpTb["parms"]["type"] = 1
                    local cjson = G_Json.encode(tmpTb)
                    G_accessCPlusFunction(cjson)
                    
                    local dataKey = "currWithRandomGift@"..tostring(playerVoApi:getUid()) .. "@"..tostring(base.curZoneID)
                    local currWithRandomGift = CCUserDefault:sharedUserDefault():getIntegerForKey(dataKey)
                    if currWithRandomGift == nil then
                        currWithRandomGift = 0
                    elseif G_isToday(currWithRandomGift) == false then
                        local dataKey = "currWithRandomGift@"..tostring(playerVoApi:getUid()) .. "@"..tostring(base.curZoneID)
                        CCUserDefault:sharedUserDefault():setIntegerForKey(dataKey, 0)
                        CCUserDefault:sharedUserDefault():flush()
                    end
                    if G_isToday(currWithRandomGift) ~= true then
                        local function sendWithRandomGift(fn, data)
                            local ret, sData = base:checkServerData(data)
                            if ret == true and sData then
                                if sData then
                                    --bagVoApi:addBag(id,num)
                                    local dataKey = "currWithRandomGift@"..tostring(playerVoApi:getUid()) .. "@"..tostring(base.curZoneID)
                                    CCUserDefault:sharedUserDefault():setIntegerForKey(dataKey, sData.ts)--需要拿到领奖的时间戳
                                    CCUserDefault:sharedUserDefault():flush()
                                    smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("showKoreaAdver"), nil, 3)
                                end
                            elseif ret == -2030 then
                                base.isRandomGift = 0
                            end
                        end
                        socketHelper:getrandomgift(sendWithRandomGift)
                    end
                end
                local buttonKoreaAdver
                local selectN = CCSprite:create("zsyImage/KoreaAdver.png");
                local selectS = CCSprite:create("zsyImage/KoreaAdver.png");
                local selectD = GraySprite:create("zsyImage/KoreaAdver.png");
                buttonKoreaAdver = CCMenuItemSprite:create(selectN, selectS, selectD);
                buttonKoreaAdver:registerScriptTapHandler(onclick)
                buttonKoreaAdver:setAnchorPoint(ccp(0.5, 0.5))
                
                self.m_showKoreaAdver = CCMenu:createWithItem(buttonKoreaAdver);
                if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                    self.m_showKoreaAdver:setPosition(ccp(G_VisibleSizeWidth - 6 * 135, G_VisibleSizeHeight - 185))
                else
                    self.m_showKoreaAdver:setPosition(ccp(G_VisibleSizeWidth - 6 * 135, G_VisibleSizeHeight - 156))
                end
                self.m_showKoreaAdver:setTouchPriority(-23);
                self.myUILayer:addChild(self.m_showKoreaAdver, 10)
                self.m_rightTopIconTab.icon8 = self.m_showKoreaAdver
            end
        else
            if self.m_showKoreaAdver then
                self.m_showKoreaAdver:removeFromParentAndCleanup(true)
                self.m_showKoreaAdver = nil
                self.m_rightTopIconTab.icon8 = nil
            end
        end
        self:resetRightTopIconPos()
    end
end
function mainUI:showFBInviteBtn()
    if (base.ifFriendOpen == 1 and self.fbInviteBtnHasShow == false and newGuidMgr:isNewGuiding() == false and G_curPlatName() ~= "efunandroidmemoriki" and G_curPlatName() ~= "efunandroid360" and G_curPlatName() ~= "androidom2") then
        local function onclick()
            if newGuidMgr:isNewGuiding() == true then
                do
                    return
                end
            end
            if(G_curPlatName() == "4") or G_curPlatName() == "efunandroiddny" or G_curPlatName() == "efunandroiddnych" or G_curPlatName() == "efunandroidnm" or G_curPlatName() == "15" or G_curPlatName() == "47" then
                local tmpTb = {}
                tmpTb["action"] = "showSocialView"
                tmpTb["parms"] = {}
                tmpTb["parms"]["uid"] = tostring(G_getTankUserName())
                tmpTb["parms"]["zoneid"] = tostring(base.curZoneID)
                tmpTb["parms"]["gameid"] = tostring(playerVoApi:getUid())
                
                local cjson = G_Json.encode(tmpTb)
                G_accessCPlusFunction(cjson)
            else
                friendVoApi:showFriendDialog()
            end
        end
        local buttonInvite
        
        if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
            if G_curPlatName() == "androidzhongshouyouru" or G_curPlatName() == "12" then
                buttonInvite = GetButtonItem("VK.png", "VK_down.png", "VK_down.png", onclick, nil, nil, nil)
            elseif(G_isKakao() or G_curPlatName() == "0")then
                local selectN = CCSprite:create("zsyImage/kakao_friendBtn.png");
                local selectS = CCSprite:create("zsyImage/kakao_friendBtn.png");
                local selectD = GraySprite:create("zsyImage/kakao_friendBtn.png");
                buttonInvite = CCMenuItemSprite:create(selectN, selectS, selectD);
                buttonInvite:registerScriptTapHandler(onclick)
            else
                buttonInvite = GetButtonItem("facebook.png", "facebook_down.png", "facebook_down.png", onclick, nil, nil, nil)
            end
        else
            if G_curPlatName() == "androidzhongshouyouru" or G_curPlatName() == "12" then
                buttonInvite = GetButtonItem("VK1.png", "VK1_down.png", "VK1_down.png", onclick, nil, nil, nil)
            elseif(G_isKakao() or G_curPlatName() == "0")then
                local selectN = CCSprite:create("zsyImage/kakao_friendBtn.png");
                local selectS = CCSprite:create("zsyImage/kakao_friendBtn.png");
                local selectD = GraySprite:create("zsyImage/kakao_friendBtn.png");
                buttonInvite = CCMenuItemSprite:create(selectN, selectS, selectD);
                buttonInvite:registerScriptTapHandler(onclick)
            else
                buttonInvite = GetButtonItem("facebook1.png", "facebook1_down.png", "facebook1_down.png", onclick, nil, nil, nil)
            end
        end
        if(platCfg.platCfgBMImage[G_curPlatName()] ~= nil)then
            local spcSp = CCSprite:createWithSpriteFrameName("light01.png")
            local spcArr = CCArray:create()
            for i = 1, 17 do
                local indexStr
                if(i < 10)then
                    indexStr = "0"..i
                else
                    indexStr = i
                end
                local nameStr = "light"..indexStr..".png"
                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                spcArr:addObject(frame)
            end
            local animation = CCAnimation:createWithSpriteFrames(spcArr)
            animation:setDelayPerUnit(0.08)
            local animate = CCAnimate:create(animation)
            spcSp:setAnchorPoint(ccp(0.5, 0.5))
            spcSp:setPosition(ccp(buttonInvite:getContentSize().width / 2, buttonInvite:getContentSize().height / 2))
            buttonInvite:addChild(spcSp)
            local delayAction = CCDelayTime:create(4)
            local seq = CCSequence:createWithTwoActions(animate, delayAction)
            local repeatForever = CCRepeatForever:create(seq)
            spcSp:runAction(repeatForever)
        end
        buttonInvite:setAnchorPoint(ccp(0.5, 0.5))
        self.fbBtn = buttonInvite
        local InviteMenu = CCMenu:createWithItem(buttonInvite);
        if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
            InviteMenu:setPosition(ccp(G_VisibleSizeWidth - buttonInvite:getContentSize().width / 2 - buttonInvite:getContentSize().width, G_VisibleSizeHeight - 185))
        else
            InviteMenu:setPosition(ccp(G_VisibleSizeWidth - buttonInvite:getContentSize().width / 2 - buttonInvite:getContentSize().width, G_VisibleSizeHeight - 156))
        end

        InviteMenu:setPosition(ccp(G_VisibleSizeWidth - buttonInvite:getContentSize().width / 2 - buttonInvite:getContentSize().width, G_VisibleSizeHeight - 185))
        InviteMenu:setTouchPriority(-23);
        self.myUILayer:addChild(InviteMenu, 10)
        self.m_rightTopIconTab.icon1 = InviteMenu
        self:resetRightTopIconPos()
        self.fbInviteBtnHasShow = true
    end
end

function mainUI:showAddAllianceBtn()
    local isReward = base.joinReward--是否领取首次加入军团奖励
    local buildVo = buildingVoApi:getBuildingVoByBtype(15)[1]--军团建筑
    if base.isAllianceSwitch == 1 and buildVo and buildVo.status >= 0 and (allianceVoApi:isHasAlliance() == false and (playerVoApi:getPlayerAid() == 0 or playerVoApi:getPlayerAid() == nil) or isReward == 0) then
        if self and self.m_joinAllianceSp == nil then
            local function showJoinAllianceDialog()
                local sd = allianceJoinSmallDialog:new()
                sd:showJoinAllianceDialog("yh_panelBg.png", CCSizeMake(525, 440), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), true, 3, getlocal("alliance_list_scene_name"), true)
            end
            
            local rewardTab = FormatItem(playerCfg.firstJoinAllianceCfg.reward) or {}
            local reward = rewardTab[1]
            if reward then
                local scale = 1
                -- self.m_joinAllianceSp,scale=G_getItemIcon(reward,80,false,3,showJoinAllianceDialog)
                if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                    self.m_joinAllianceSp = GetBgIcon("alliance_join_icon.png", showJoinAllianceDialog, nil, 70)
                else
                    self.m_joinAllianceSp = GetBgIcon("alliance_join_icon.png", showJoinAllianceDialog, "Icon_BG1.png", 70)
                end

                -- LuaCCSprite:createWithSpriteFrameName("alliance_join_icon.png",showJoinAllianceDialog)
                self.m_joinAllianceSp:setAnchorPoint(ccp(0.5, 0.5))
                self.m_joinAllianceSp:setPosition(ccp(G_VisibleSizeWidth - self.m_joinAllianceSp:getContentSize().width / 2 - 250, G_VisibleSizeHeight - 185))
                self.myUILayer:addChild(self.m_joinAllianceSp, 1)
                self.m_joinAllianceSp:setTouchPriority(-24)
                self.m_joinAllianceSp:setScale(scale)
                if G_getGameUIVer()==2 then
                    G_addNewMainUIRectFlicker(self.m_joinAllianceSp, 78/100, 78/100)
                else
                    G_addFlicker(self.m_joinAllianceSp, 1 / (scale / 2), 1 / (scale / 2))
                end
                self.m_rightTopIconTab.icon5 = self.m_joinAllianceSp
            end
        end
    else
        if self and self.m_joinAllianceSp ~= nil then
            self.m_joinAllianceSp:removeFromParentAndCleanup(true)
            self.m_joinAllianceSp = nil
            self.m_rightTopIconTab.icon5 = nil
        end
    end
    if self then
        self:resetRightTopIconPos()
    end
end

function mainUI:showTenxunhuodong()
    if base.qq == 1 and playerVoApi:getQQ() == 0 then
        if self and self.kongjianSp == nil and (G_curPlatName() == "androidtencent" or G_curPlatName() == "androidtencently") then
            local function showTenxunhuodongDialog()
                require "luascript/script/game/scene/gamedialog/acTenxunhuodongDialog"
                local td = acTenxunhuodongDialog:new(3)
                
                local tbArr = {}
                local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, "下载注册送豪礼", true, 3)
                sceneGame:addChild(dialog, 3)
                G_removeFlicker(self.kongjianSp)
            end            
            
            if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                self.kongjianSp = LuaCCSprite:createWithFileName("public/kongjian.png", showTenxunhuodongDialog)
                self.kongjianSp:setAnchorPoint(ccp(0.5, 0.5))
                self.kongjianSp:setPosition(ccp(G_VisibleSizeWidth - self.kongjianSp:getContentSize().width / 2 - 250, G_VisibleSizeHeight - 185))
            else
                self.kongjianSp = LuaCCSprite:createWithFileName("public/kongjian1.png", showTenxunhuodongDialog)
                self.kongjianSp:setAnchorPoint(ccp(0.5, 0.5))
                self.kongjianSp:setPosition(ccp(G_VisibleSizeWidth - self.kongjianSp:getContentSize().width / 2 - 250, G_VisibleSizeHeight - 156))
            end

            self.myUILayer:addChild(self.kongjianSp, 1)
            self.kongjianSp:setTouchPriority(-24)
            self.kongjianSp:setScale(0.7)
            if G_getGameUIVer()==2 then
                G_addNewMainUIRectFlicker(self.kongjianSp, 1, 1)
            else
                G_addFlicker(self.kongjianSp, 2.3, 2.3)
            end
            self.m_rightTopIconTab.icon7 = self.kongjianSp
            
        end
    else
        if self and self.kongjianSp ~= nil then
            self.kongjianSp:removeFromParentAndCleanup(true)
            self.kongjianSp = nil
            self.m_rightTopIconTab.icon7 = nil
        end
    end
    if self then
        self:resetRightTopIconPos()
    end
end

function mainUI:switchVipIcon()
    local viplevel = playerVoApi:getVipLevel()
    if self.m_vipLevel == nil or self.m_vipLevel ~= viplevel then
        self.m_vipLevel = viplevel
        if self.m_menuToggleVip then
            self.myUILayer:removeChild(self.m_menuToggleVip, true)
            self.m_menuToggleVip = nil;
        end
        local function openVipView(tag, object)
            if G_checkClickEnable() == false then --用于GM判断or GM_UidCfg[playerVoApi:getUid()]
                do
                    return
                end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            
            if newGuidMgr:isNewGuiding() then
                do return end
            end
            PlayEffect(audioCfg.mouseClick)
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
                        -- require "luascript/script/game/scene/gamedialog/vipDialogNew"
                        -- local tabTb = {getlocal("playerInfo"), getlocal("vip_tequanlibao")}
                        -- local vd1 = vipDialogNew:new()
                        -- local vd = vd1:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tabTb,nil,nil,getlocal("vipTitle"),true,3)
                        -- sceneGame:addChild(vd,3);
                        vipVoApi:openVipDialog(3, true)
                    end
                end
            end
            if base.heroSwitch == 1 and base.vipshop == 1 then
                if vipVoApi:getVipFlag() == false then
                    socketHelper:vipgiftreward(callback)
                else
                    -- require "luascript/script/game/scene/gamedialog/vipDialogNew"
                    -- local tabTb = {getlocal("playerInfo"), getlocal("vip_tequanlibao")}
                    -- local vd1 = vipDialogNew:new()
                    -- local vd = vd1:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tabTb,nil,nil,getlocal("vipTitle"),true,3)
                    -- sceneGame:addChild(vd,3);
                    vipVoApi:openVipDialog(3, true)
                end
            else
                -- require "luascript/script/game/scene/gamedialog/vipDialog"
                -- local vd1 = vipDialog:new();
                -- local vd = vd1:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tabTb,nil,nil,getlocal("vipTitle"),true,3)
                -- sceneGame:addChild(vd,3);
                vipVoApi:openVipDialog(3)
            end
        end
        
        local vip1,vip2,vipMenu1,vipMenu2,vipMenu3,vipScale
        if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
            vip1 = CCSprite:createWithSpriteFrameName("mainUiTop_topMiddle.png");
            vip2 = CCSprite:createWithSpriteFrameName("mainUiTop_topMiddle_down.png");
            vipMenu1 = CCSprite:createWithSpriteFrameName("mainUiTop_topMiddle.png");
            vipMenu2 = CCSprite:createWithSpriteFrameName("mainUiTop_topMiddle_down.png");
            vipMenu3 = GraySprite:createWithSpriteFrameName("mainUiTop_topMiddle_down.png");
            vipScale = 0.65
        else
            vip1 = CCSprite:createWithSpriteFrameName("mainUiTop_topMiddle1.png");
            vip2 = CCSprite:createWithSpriteFrameName("mainUiTop_topMiddle1_down.png");
            vipMenu1 = CCSprite:createWithSpriteFrameName("mainUiTop_topMiddle1.png");
            vipMenu2 = CCSprite:createWithSpriteFrameName("mainUiTop_topMiddle1_down.png");
            vipMenu3 = GraySprite:createWithSpriteFrameName("mainUiTop_topMiddle1_down.png");
            vipScale = 1
        end
        vip1:setScaleX(vipScale)
        vip2:setScaleX(vipScale)
        vipMenu1:setScaleX(vipScale)
        vipMenu2:setScaleX(vipScale)
        vipMenu3:setScaleX(vipScale)

        local menuItemVip = CCMenuItemSprite:create(vip1, vip2)
        self.m_pointVip = ccp(menuItemVip:getContentSize().width / 2 - 2, G_VisibleSizeHeight - 152);
        self.m_menuToggleVip = CCMenuItemToggle:create(menuItemVip);
        self.m_menuToggleVip:registerScriptTapHandler(openVipView);
        
        menuItemVip:setAnchorPoint(ccp(0, 1)); 
        
        local vipButton = CCMenuItemSprite:create(vipMenu1, vipMenu2, vipMenu3);
        vipButton:registerScriptTapHandler(openVipView)
        vipButton:setAnchorPoint(ccp(0, 1));
        vipButton:setTag(51);
        
        local vipLevel = CCSprite:createWithSpriteFrameName("Vip"..playerVoApi:getVipLevel() .. ".png");
        vipLevel:setPosition(vipButton:getContentSize().width / 2 * vipScale, vipButton:getContentSize().height / 2);
        vipLevel:setAnchorPoint(ccp(0.5, 0.5));
        vipButton:addChild(vipLevel, 30);
        if G_isHexie()==true then
            vipLevel:setScale(1.3)
        end
        
        local menuAllVip = CCMenu:createWithItem(vipButton);
        if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
            menuAllVip:setPosition(self.mySpriteLeft:getContentSize().width, self.mySpriteMain:getContentSize().height);
        else
            menuAllVip:setPosition(self.mySpriteLeft:getContentSize().width+2, self.mySpriteMain:getContentSize().height);
        end

        menuAllVip:setTouchPriority(-23);
        self.mySpriteMain:addChild(menuAllVip)
        
        local function showPowerGuide()
            -- if GM_UidCfg[playerVoApi:getUid()] then
            --   do return end
            -- end
            playerVoApi:showPowerGuideDialog(3)
        end

        local powerMenu1,powerMenu2,powerMenu3
        if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
            powerMenu1 = CCSprite:createWithSpriteFrameName("mainUiTop_topMiddle.png")
            powerMenu2 = CCSprite:createWithSpriteFrameName("mainUiTop_topMiddle_down.png")
            powerMenu3 = CCSprite:createWithSpriteFrameName("mainUiTop_topMiddle_down.png")
        else
            powerMenu1 = CCSprite:createWithSpriteFrameName("mainUiTop_topMiddleSword.png")
            powerMenu2 = CCSprite:createWithSpriteFrameName("mainUiTop_topMiddleSword_down.png")
            powerMenu3 = CCSprite:createWithSpriteFrameName("mainUiTop_topMiddleSword_down.png")
        end

        local powerMenu = CCMenuItemSprite:create(powerMenu1, powerMenu2, powerMenu3)
        powerMenu:registerScriptTapHandler(showPowerGuide)
        powerMenu:setAnchorPoint(ccp(0, 1))
        self.playerPower = playerVoApi:getPlayerPower()
        --GM_UidCfg[playerVoApi:getUid()] and 0 or
        self.powerLb = GetTTFLabel(FormatNumber(self.playerPower), 20, true)
        self.powerLb:setAnchorPoint(ccp(0.5, 0))
        self.powerLb:setPosition(ccp(powerMenu:getContentSize().width / 2, powerMenu:getContentSize().height / 2 + 2))
        
        local powerBtn
        if G_checkUseAuditUI() == true then
            self.powerLb:setPosition(ccp(powerMenu:getContentSize().width / 2 + 25, powerMenu:getContentSize().height / 2 - 10))
            local powerpic = CCSprite:createWithSpriteFrameName("mainUISword.png")
            powerpic:setPosition(ccp(powerMenu:getContentSize().width / 2 - 25, powerMenu:getContentSize().height / 2 + 5))
            powerMenu:addChild(powerpic)
            powerBtn = CCMenu:createWithItem(powerMenu)
            powerBtn:setPosition(ccp(self.mySpriteLeft:getContentSize().width + vipButton:getContentSize().width * vipScale, self.mySpriteMain:getContentSize().height))
        elseif G_getGameUIVer()==1 then
            local powerDescLb = GetTTFLabel(getlocal("showAttackRank"), 20, true)
            powerDescLb:setAnchorPoint(ccp(0.5, 1))
            powerDescLb:setPosition(ccp(powerMenu:getContentSize().width / 2, powerMenu:getContentSize().height / 2 - 2))
            powerMenu:addChild(powerDescLb)
            powerBtn = CCMenu:createWithItem(powerMenu)
            powerBtn:setPosition(ccp(self.mySpriteLeft:getContentSize().width + vipButton:getContentSize().width * vipScale, self.mySpriteMain:getContentSize().height))
        else
            self.powerLb = GetTTFLabel(FormatNumber(self.playerPower), 22)
            self.powerLb:setAnchorPoint(ccp(0.5, 0))
            self.powerLb:setPosition(ccp(powerMenu:getContentSize().width / 2 + 24, powerMenu:getContentSize().height / 2 - 14))
            local powerpic = CCSprite:createWithSpriteFrameName("mainUISword1.png")
            powerpic:setPosition(ccp(powerMenu:getContentSize().width / 2 - 36, powerMenu:getContentSize().height / 2 ))
            powerMenu:addChild(powerpic)
            powerBtn = CCMenu:createWithItem(powerMenu)
            powerBtn:setPosition(ccp(self.mySpriteLeft:getContentSize().width + vipButton:getContentSize().width * vipScale+6, self.mySpriteMain:getContentSize().height))
        end
        powerMenu:addChild(self.powerLb)
        powerBtn:setTouchPriority(-23)
        self.mySpriteMain:addChild(powerBtn)
    end
end
function mainUI:iconFlicker(icon, m_iconScaleX, m_iconScaleY)
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        return G_addFlicker(icon, 1 / (m_iconScaleX / 2), 1 / (m_iconScaleY / 2))
    else
        return G_addNewMainUIRectFlicker(icon, 1, 1 / (m_iconScaleY / 2))
    end
end

function mainUI:showDailyDialog()
    if G_checkClickEnable() == false then
        do
            return
        end
    end
    -- if(tonumber(base.curZoneID)>900 and tonumber(base.curZoneID)<1000)then
    if(tonumber(base.curZoneID) == 999)then
        do return end
    end
    PlayEffect(audioCfg.mouseClick)
    --dailyVoApi:updateRewardNum()
    dailyVoApi:showDailyDialog(3)
end
function mainUI:showNewGiftsDialog()
    if G_checkClickEnable() == false then
        do
            return
        end
    end
    PlayEffect(audioCfg.mouseClick)
    if newGuidMgr:isNewGuiding() then --新手引导
        do
            return
        end
    end
    require "luascript/script/game/scene/gamedialog/newGiftsDialog"
    local nd = newGiftsDialog:new()
    --local tbArr={getlocal("lotteryCommon"),getlocal("lotterySenior")}
    local tbArr = {}
    local vd = nd:init("panelBg.png", true, CCSizeMake(768, 800), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("newGiftsTitle"), true, 3);
    sceneGame:addChild(vd, 3);
    
end
function mainUI:showSignDialog()
    if G_checkClickEnable() == false then
        do
            return
        end
    end
    PlayEffect(audioCfg.mouseClick)
    if newGuidMgr:isNewGuiding() then --新手引导
        do
            return
        end
    end
    if base.newSign == 1 then
        newSignInVoApi:showSignDialog(3)
    else
        signVoApi:showSignDialog(3)
    end
end

function mainUI:showAcAndNote()
    if G_checkClickEnable() == false then
        do
            return
        end
    end
    PlayEffect(audioCfg.mouseClick)
    if newGuidMgr:isNewGuiding() then --新手引导
        do
            return
        end
    end
    if self.dialog_acAndNote ~= nil then
        self.dialog_acAndNote = nil
    end
    activityVoApi:updateAllShowState()
    self.dialog_acAndNote = activityAndNoteDialog:new()
    local tbArr = {getlocal("activity"), getlocal("dailyActivity_title"), getlocal("note")}
    local vd = self.dialog_acAndNote:init("panelBg.png", true, CCSizeMake(768, 800), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("activityAndNote_title"), true, 3);
    if activityVoApi:hadNewActivity() == false and noteVoApi:hadNewNote() == true then
        self.dialog_acAndNote:tabClick(2)
    end
    sceneGame:addChild(vd, 3);
end

function mainUI:updateAcAndNote()
    if self.dialog_acAndNote ~= nil then
        self.dialog_acAndNote:updateNewNum()
    end
end

function mainUI:showTaskDialog()
    if G_checkClickEnable() == false then
        do
            return
        end
    else
        base.setWaitTime = G_getCurDeviceMillTime()
    end
    taskVoApi:updateDailyTaskNum()
    
    require "luascript/script/game/scene/gamedialog/taskDialog"
    require "luascript/script/game/scene/gamedialog/taskDialogTab1"
    require "luascript/script/game/scene/gamedialog/taskDialogTab2"
    local td = taskDialog:new()
    local tbArr = {getlocal("taskPage"), getlocal("dailyTaskPage")}
    local vd = td:init("panelBg.png", true, CCSizeMake(768, 800), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("task"), true, 3)
    sceneGame:addChild(vd, 3)
    -- td:tabClick(1)
    if self.selectSp then
        self.selectSp:removeFromParentAndCleanup(true)
        self.selectSp = nil
    end
    
end
function mainUI:switchStateIcon()
    
    local function touchLuaSp()
        if G_checkClickEnable() == false then
            do
                return
            end
        end
        PlayEffect(audioCfg.mouseClick)
        require "luascript/script/game/scene/gamedialog/buffStateDialog"
        local vrd = buffStateDialog:new()
        local vd = vrd:init(4)
        
    end
    local spriteSp1
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        self.m_luaSpBuff = LuaCCSprite:createWithSpriteFrameName("Icon_BG.png", touchLuaSp);
        spriteSp1 = CCSprite:createWithSpriteFrameName("Icon_mainui_01.png")
    else
        self.m_luaSpBuff = LuaCCSprite:createWithSpriteFrameName("Icon_BG1.png", touchLuaSp);
        spriteSp1 = CCSprite:createWithSpriteFrameName("Icon_mainui_01_1.png")
    end

    self.m_luaSpBuff:setAnchorPoint(ccp(0, 0))
    self.m_luaSpBuff:setPosition(0, G_VisibleSizeHeight - 225);
    self.m_luaSpBuff:setTag(101);
    self.myUILayer:addChild(self.m_luaSpBuff, 1);
    self.m_luaSpBuff:setTouchPriority(-21);
    
    spriteSp1:setPosition(getCenterPoint(self.m_luaSpBuff))
    self.m_luaSpBuff:addChild(spriteSp1, 1);
    
    local scaleX = self.m_luaSpBuff:getContentSize().width / spriteSp1:getContentSize().width
    local scaleY = self.m_luaSpBuff:getContentSize().height / spriteSp1:getContentSize().height
    spriteSp1:setScaleX(scaleX)
    spriteSp1:setScaleY(scaleY)
    self:refreshStateIcon()
    if self.m_leftIconTab.icon1 ~= nil then
        self.m_leftIconTab.icon1 = nil
    end
    self.m_leftIconTab.icon1 = self.m_luaSpBuff
end
function mainUI:switchDailyIcon()
    if FuncSwitchApi:isEnabled("luck_lottery") == false then
        do return end
    end
    if self.m_dailySp then
        self.myUILayer:removeChild(self.m_dailySp, true)
        self.m_dailySp = nil;
        
        if self.m_leftIconTab.icon2 ~= nil then
            self.m_leftIconTab.icon2 = nil
        end
        if self.m_leftIconTab.flicker2 ~= nil then
            self.m_leftIconTab.flicker2 = nil
        end
    end
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        self.m_dailySp = LuaCCSprite:createWithSpriteFrameName("item_baoxiang_09.png", self.showDailyDialog)
    else
        self.m_dailySp = LuaCCSprite:createWithSpriteFrameName("item_baoxiang_09_1.png", self.showDailyDialog)
    end
    self.m_dailySp:setTag(1001)
    self.m_dailySp:setAnchorPoint(ccp(0, 0))
    self.m_dailySp:setTouchPriority(-23)
    self.m_dailySp:setPosition(0, G_VisibleSizeHeight - 304);
    self.m_dailySp:setScaleX(self.m_iconScaleX)
    self.m_dailySp:setScaleY(self.m_iconScaleY)
    -- if(tonumber(base.curZoneID)>900 and tonumber(base.curZoneID)<1000)then
    if(tonumber(base.curZoneID) == 999)then
        self.m_dailySp:setVisible(false)
    end
    self.myUILayer:addChild(self.m_dailySp);
    self.m_flagTab.dailyHasReward = false
    if dailyVoApi:isFree() then
        self.m_flagTab.dailyHasReward = true
        -- self.m_leftIconTab.flicker2=self:iconFlicker(self.m_dailySp,self.m_iconScaleX,self.m_iconScaleY)
        if G_getGameUIVer()==2 then
            self.m_leftIconTab.flicker2 = G_addNewMainUIRectFlicker(self.m_dailySp, 1, 1)
        else
            self.m_leftIconTab.flicker2 = G_addFlicker(self.m_dailySp, 1 / (self.m_iconScaleX / 2), 1 / (self.m_iconScaleY / 2))
        end
    end
    self.m_leftIconTab.icon2 = self.m_dailySp
end
function mainUI:switchNewGiftsIcon()
    if self.m_newGiftsSp then
        self.myUILayer:removeChild(self.m_newGiftsSp, true)
        self.m_newGiftsSp = nil;
        
        if self.m_leftIconTab.icon3 ~= nil then
            self.m_leftIconTab.icon3 = nil
        end
        if self.m_leftIconTab.flicker3 ~= nil then
            self.m_leftIconTab.flicker3 = nil
        end
    end
    local newGiftsState = newGiftsVoApi:hasReward()
    if newGiftsState ~= -1 then
        if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
            self.m_newGiftsSp = LuaCCSprite:createWithSpriteFrameName("7days.png", self.showNewGiftsDialog)
        else
            self.m_newGiftsSp = LuaCCSprite:createWithSpriteFrameName("7days1.png", self.showNewGiftsDialog)
        end
        self.m_newGiftsSp:setTag(1008)
        self.m_newGiftsSp:setAnchorPoint(ccp(0, 0))
        self.m_newGiftsSp:setTouchPriority(-23)
        self.m_newGiftsSp:setPosition(0, G_VisibleSizeHeight - 304 - 80)
        self.m_newGiftsSp:setScaleX(self.m_iconScaleX)
        self.m_newGiftsSp:setScaleY(self.m_iconScaleY)
        self.myUILayer:addChild(self.m_newGiftsSp)
        if newGiftsState == 1 then
            -- self.m_leftIconTab.flicker3=self:iconFlicker(self.m_newGiftsSp,self.m_iconScaleX,self.m_iconScaleY)
            if G_getGameUIVer()==2 then
                self.m_leftIconTab.flicker3 = G_addNewMainUIRectFlicker(self.m_newGiftsSp, 1, 1)
            else
                self.m_leftIconTab.flicker3 = G_addFlicker(self.m_newGiftsSp, 1 / (self.m_iconScaleX / 2), 1 / (self.m_iconScaleY / 2))
            end
        end
        self.m_leftIconTab.icon3 = self.m_newGiftsSp
    else
        --[[
    if self.m_taskSp then
      self.m_taskSp:setPosition(0,G_VisibleSizeHeight-304-80);
    end
    if self.m_enemyComingSp then
      self.m_enemyComingSp:setPosition(0,G_VisibleSizeHeight-304-80*2);
    end
    ]]
    end
    self.m_flagTab.hasNewGifts = newGiftsState
end
function mainUI:switchSignIcon()
    if self.m_signIcon then
        self.myUILayer:removeChild(self.m_signIcon, true)
        self.m_signIcon = nil;
        
        if self.m_leftIconTab.icon3 ~= nil then
            self.m_leftIconTab.icon3 = nil
        end
        if self.m_leftIconTab.flicker3 ~= nil then
            self.m_leftIconTab.flicker3 = nil
        end
        self:resetLeftIconPos()
    end
    if base.isSignSwitch == 0 then
        do return end
    end
    
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        self.m_signIcon = LuaCCSprite:createWithSpriteFrameName("30dayIcon.png", self.showSignDialog)
    else
        self.m_signIcon = LuaCCSprite:createWithSpriteFrameName("30dayIcon1.png", self.showSignDialog)
    end
    self.m_signIcon:setTag(1009)
    self.m_signIcon:setAnchorPoint(ccp(0, 0))
    self.m_signIcon:setTouchPriority(-23)
    self.m_signIcon:setPosition(0, G_VisibleSizeHeight - 304 - 80)
    self.m_signIcon:setScaleX(self.m_iconScaleX)
    self.m_signIcon:setScaleY(self.m_iconScaleY)
    self.myUILayer:addChild(self.m_signIcon)
    local isTodaySign = signVoApi:isTodaySign()
    if isTodaySign == false then
        -- self.m_leftIconTab.flicker3=self:iconFlicker(self.m_signIcon,self.m_iconScaleX,self.m_iconScaleY)
        if G_getGameUIVer()==2 then
            self.m_leftIconTab.flicker3 = G_addNewMainUIRectFlicker(self.m_signIcon, 1, 1)
        else
            self.m_leftIconTab.flicker3 = G_addFlicker(self.m_signIcon, 1 / (self.m_iconScaleX / 2), 1 / (self.m_iconScaleY / 2))
        end
    end
    self.m_leftIconTab.icon3 = self.m_signIcon
    
    self:resetLeftIconPos()
end
function mainUI:switchTaskIcon(isShowMainTask)
    local pic = taskVoApi:showIcon()
    local m_iconScaleX, m_iconScaleY
    if pic and pic ~= "" then
        if self.m_taskSp then
            self.myUILayer:removeChild(self.m_taskSp, true)
            self.m_taskSp = nil;
            
            if self.m_leftIconTab.icon4 ~= nil then
                self.m_leftIconTab.icon4 = nil
            end
            if self.m_leftIconTab.flicker4 ~= nil then
                self.m_leftIconTab.flicker4 = nil
            end
        end
        local function showLeftTaskDialog()
            if G_checkClickEnable() == false then
                do
                    return
                end
            end
            PlayEffect(audioCfg.mouseClick)
            
            self:showTaskDialog()
            if newGuidMgr:isNewGuiding() then --新手引导
                newGuidMgr:toNextStep()
            end
        end
        local startIndex, endIndex = string.find(pic, "^rank(%d+).png$")
        if startIndex ~= nil and endIndex ~= nil then
            self.m_taskSp = GetBgIcon(pic, showLeftTaskDialog, self.m_taskSp)
        else
            self.m_taskSp = LuaCCSprite:createWithSpriteFrameName(pic, showLeftTaskDialog)
            if self.m_taskSp:getContentSize().width > 100 then
                self.m_taskSp:setScaleX(2 / 3 * self.m_iconScaleX)
                self.m_taskSp:setScaleY(2 / 3 * self.m_iconScaleY)
                m_iconScaleX = 2 / 3 * self.m_iconScaleX
                m_iconScaleY = 2 / 3 * self.m_iconScaleY
            else
                self.m_taskSp:setScaleX(self.m_iconScaleX)
                self.m_taskSp:setScaleY(self.m_iconScaleY)
                m_iconScaleX = self.m_iconScaleX
                m_iconScaleY = self.m_iconScaleY
            end
        end
        self.m_taskSp:setTag(1002)
        self.m_taskSp:setAnchorPoint(ccp(0, 0))
        self.m_taskSp:setTouchPriority(-23)
        self.myUILayer:addChild(self.m_taskSp, 1);
        --self.m_taskSp:setPosition(0,G_VisibleSizeHeight-382);
        if self.m_newGiftsSp then
            self.m_taskSp:setPosition(0, G_VisibleSizeHeight - 304 - 80 * 2)
        else
            self.m_taskSp:setPosition(0, G_VisibleSizeHeight - 304 - 80)
        end
        self.m_leftIconTab.icon4 = self.m_taskSp
    end
    local taskIdx = 6
    local tasksNum = taskVoApi:hadCompletedTask()
    if tasksNum > 0 then
        if self.m_taskSp then
            -- self.m_leftIconTab.flicker4=self:iconFlicker(self.m_taskSp,m_iconScaleX,m_iconScaleY)
            if G_getGameUIVer()==2 then
                self.m_leftIconTab.flicker4 = G_addNewMainUIRectFlicker(self.m_taskSp, 1, 1)
            else
                self.m_leftIconTab.flicker4 = G_addFlicker(self.m_taskSp, 1 / (self.m_iconScaleX / 2), 1 / (self.m_iconScaleY / 2))
            end
        end
        
        -- if self.m_newsNumTab and self.m_newsNumTab[taskIdx] then
        -- if self.m_newsNumTab[taskIdx]:isVisible()==false then
        -- self.m_newsNumTab[taskIdx]:setVisible(true)
        -- end
        -- local newsNumLabel=tolua.cast(self.m_newsNumTab[taskIdx]:getChildByTag(200+taskIdx),"CCLabelTTF")
        -- if newsNumLabel:getString()~=tostring(tasksNum) then
        -- self:setNewsNum(tasksNum,tolua.cast(self.m_newsNumTab[taskIdx]:getChildByTag(200+taskIdx),"CCLabelTTF"),self.m_newsNumTab[taskIdx])
        -- end
        -- end
    else
        -- if self.m_newsNumTab and self.m_newsNumTab[taskIdx] and self.m_newsNumTab[taskIdx]:isVisible()==true then
        -- self.m_newsNumTab[taskIdx]:setVisible(false)
        -- end
    end
    taskVoApi:setRefreshFlag(1)
    self:resetLeftIconPos()
    
    if playerVoApi:getTutorial() >= 10 and (G_curPlatName() == "18" or G_curPlatName() == "androidtuerqi" or G_curPlatName() == "0") and playerVoApi:getPlayerLevel() < 10 then
        self:addSelectSp()
    end
    
    self:switchMainTask(isShowMainTask)
end
function mainUI:switchMainTask(isShowMainTask)
    -- if GM_UidCfg[playerVoApi:getUid()] then
    --     do return end
    -- end
    local isShow = false
    local mtSwitch = CCUserDefault:sharedUserDefault():getIntegerForKey("gameSettings_mainTaskGuide")
    local mainTask = taskVoApi:getMainTask(true)
    if mtSwitch == 2 and isShowMainTask ~= false and self and newGuidMgr:isNewGuiding() == false and mainTask and SizeOfTable(mainTask) > 0 then
        local isFinish = taskVoApi:isCompletedTask(mainTask.sid)
        -- print("isFinish",isFinish)
        -- print("(self.m_lastShowTime+self.m_showInterval)",(self.m_lastShowTime+self.m_showInterval))
        -- print("base.serverTime",base.serverTime)
        -- print("self.m_lastMainTaskId,mainTask.sid,self.m_lastFinish,isFinish",self.m_lastMainTaskId,mainTask.sid,self.m_lastFinish,isFinish)
        isShow = true
        if isFinish == true then
        elseif (self.m_lastShowTime + self.m_showInterval) < base.serverTime and self.m_lastMainTaskId == mainTask.sid and self.m_lastFinish == isFinish then
            isShow = false
        end
        if isShow == true then
            local spSize = 60
            local function clickHandler()
                if newGuidMgr:isNewGuiding() then
                    do return end
                end
                if G_checkClickEnable() == false then
                    do
                        return
                    end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                
                local mainTask1 = taskVoApi:getMainTask(true)
                if mainTask1 then
                    local isFinish1 = taskVoApi:isCompletedTask(mainTask1.sid)
                    if isFinish1 == true then
                        -- local taskNumOld=taskVoApi:getCurrentTasksNum()
                        local function taskFinishHandler(fn, data)
                            if base:checkServerData(data) == true then
                                -- local awardTab = taskVoApi:getAwardBySid(mainTask1.sid)
                                -- G_showRewardTip(awardTab,true)
                                local awardStr, awardTab = taskVoApi:getAwardStr(mainTask1.sid)
                                local realReward = playerVoApi:getTrueReward(awardTab)
                                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), awardStr, 28, nil, nil, realReward)
                                self:switchTaskIcon()
                            end
                        end
                        local taskid = "t"..tostring(mainTask1.sid)
                        socketHelper:taskFinish(taskid, taskFinishHandler)
                    else
                        --跳转
                        local taskCfg = taskVoApi:getTaskFromCfg(mainTask1.sid)
                        if taskCfg and SizeOfTable(taskCfg) > 0 then
                            G_taskJumpTo(taskCfg)
                        end
                    end
                end
            end
            if self.m_mainTaskBg == nil then
                if G_checkUseAuditUI() == true then
                    local capInSet = CCRect(20, 20, 10, 10)
                    
                    self.m_mainTaskBg = LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg_tishen.png", capInSet, clickHandler)
                    self.m_mainTaskBg:setContentSize(CCSizeMake(450, spSize))
                    self.m_mainTaskBg:ignoreAnchorPointForPosition(false)
                    self.m_mainTaskBg:setAnchorPoint(ccp(0, 0.5))
                    self.m_mainTaskBg:setIsSallow(true)
                    self.m_mainTaskBg:setTouchPriority(-22)
                    self.myUILayer:addChild(self.m_mainTaskBg)
                    
                    local nameStr = taskVoApi:getTaskInfoById(mainTask.sid, true)
                    local nameLb = GetTTFLabelWrap(nameStr, 20, CCSizeMake(self.m_mainTaskBg:getContentSize().width - 100, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
                    nameLb:setAnchorPoint(ccp(0, 0.5))
                    nameLb:setPosition(ccp(170, self.m_mainTaskBg:getContentSize().height / 2))
                    nameLb:setTag(12)
                    self.m_mainTaskBg:addChild(nameLb, 1)
                    nameLb:setColor(G_ColorYellow)
                    
                    local Guide_tishen = CCSprite:createWithSpriteFrameName("Guide_tishen.png")
                    Guide_tishen:setAnchorPoint(ccp(0, 0))
                    Guide_tishen:setPosition(ccp(self.m_mainTaskBg:getContentSize().width / 6, self.m_mainTaskBg:getPositionY() + self.m_mainTaskBg:getContentSize().height - 1))
                    self.m_mainTaskBg:addChild(Guide_tishen, 1)
                    
                    local finishSp = CCSprite:createWithSpriteFrameName("IconCheck_tishen.png")
                    finishSp:setPosition(ccp(self.m_mainTaskBg:getContentSize().width - finishSp:getContentSize().width / 2 - 10, self.m_mainTaskBg:getContentSize().height / 2))
                    finishSp:setTag(13)
                    self.m_mainTaskBg:addChild(finishSp, 1)
                    
                    local unfinishSp = CCSprite:createWithSpriteFrameName("questionMark_tishen.png")
                    unfinishSp:setPosition(ccp(self.m_mainTaskBg:getContentSize().width - unfinishSp:getContentSize().width / 2 - 10, self.m_mainTaskBg:getContentSize().height / 2))
                    unfinishSp:setTag(14)
                    self.m_mainTaskBg:addChild(unfinishSp, 1)
                    
                    local function nilFunc()
                    end
                    local halo = LuaCCScale9Sprite:createWithSpriteFrameName("guide_res_tishen.png", CCRect(28, 28, 2, 2), nilFunc)
                    halo:setContentSize(CCSize(self.m_mainTaskBg:getContentSize().width + 6, self.m_mainTaskBg:getContentSize().height + 6))
                    halo:setPosition(getCenterPoint(self.m_mainTaskBg))
                    halo:setTag(15)
                    self.m_mainTaskBg:addChild(halo)
                else
                    local capInSet = CCRect(20, 20, 10, 10)
                    
                    if G_getGameUIVer()==1 then
                        self.m_mainTaskBg = LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png", capInSet, clickHandler)
                        self.m_mainTaskBg:setContentSize(CCSizeMake(300, spSize))
                    else
                        self.m_mainTaskBg = LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg1.png", capInSet, clickHandler)
                        self.m_mainTaskBg:setContentSize(CCSizeMake(410, spSize))
                    end
                    self.m_mainTaskBg:ignoreAnchorPointForPosition(false)
                    self.m_mainTaskBg:setAnchorPoint(ccp(0, 0.5))
                    self.m_mainTaskBg:setIsSallow(true)
                    self.m_mainTaskBg:setTouchPriority(-22)
                    self.myUILayer:addChild(self.m_mainTaskBg)
                    
                    local nameStr = taskVoApi:getTaskInfoById(mainTask.sid, true)
                    local nameLb = GetTTFLabelWrap(nameStr, 20, CCSizeMake(self.m_mainTaskBg:getContentSize().width - 65, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
                    nameLb:setAnchorPoint(ccp(0, 0.5))
                    if G_getGameUIVer()==1 then
                        nameLb:setPosition(ccp(10, self.m_mainTaskBg:getContentSize().height / 2))
                    else
                        nameLb:setPosition(ccp(130, self.m_mainTaskBg:getContentSize().height / 2))
                    end
                    nameLb:setTag(12)
                    self.m_mainTaskBg:addChild(nameLb, 1)
                    nameLb:setColor(G_ColorYellow)
                    
                    local finishSp,unfinishSp
                    if G_getGameUIVer()==1 then 
                        finishSp = CCSprite:createWithSpriteFrameName("IconCheck.png")
                        unfinishSp = CCSprite:createWithSpriteFrameName("questionMark.png")
                    else
                        finishSp = CCSprite:createWithSpriteFrameName("IconCheck1.png")
                        unfinishSp = CCSprite:createWithSpriteFrameName("questionMark1.png")
                    end

                    finishSp:setPosition(ccp(self.m_mainTaskBg:getContentSize().width - finishSp:getContentSize().width / 2 - 10, self.m_mainTaskBg:getContentSize().height / 2))
                    finishSp:setTag(13)
                    self.m_mainTaskBg:addChild(finishSp, 1)
                    
                    unfinishSp:setPosition(ccp(self.m_mainTaskBg:getContentSize().width - unfinishSp:getContentSize().width / 2 - 10, self.m_mainTaskBg:getContentSize().height / 2))
                    unfinishSp:setTag(14)
                    self.m_mainTaskBg:addChild(unfinishSp, 1)
                    
                    local function nilFunc()
                    end
                    local halo
                    if G_getGameUIVer()==1 then
                        halo = LuaCCScale9Sprite:createWithSpriteFrameName("guide_res.png", CCRect(28, 28, 2, 2), nilFunc)
                        halo:setContentSize(CCSize(self.m_mainTaskBg:getContentSize().width + 10, self.m_mainTaskBg:getContentSize().height + 10))
                    else
                        halo = LuaCCScale9Sprite:createWithSpriteFrameName("guide_res1.png", CCRect(28, 28, 2, 2), nilFunc)
                        halo:setContentSize(CCSize(self.m_mainTaskBg:getContentSize().width + 15, self.m_mainTaskBg:getContentSize().height + 10))
                        halo:setAnchorPoint(ccp(0.5,0.5))
                    end
                                        
                    halo:setPosition(getCenterPoint(self.m_mainTaskBg))
                    halo:setTag(15)
                    self.m_mainTaskBg:addChild(halo)
                end
            end
            
            local nameStr = taskVoApi:getTaskInfoById(mainTask.sid, true)
            local nameLb = tolua.cast(self.m_mainTaskBg:getChildByTag(12), "CCLabelTTF")
            if nameLb then
                nameLb:setString(nameStr)
            end
            local fSp = tolua.cast(self.m_mainTaskBg:getChildByTag(13), "CCSprite")
            local ufSp = tolua.cast(self.m_mainTaskBg:getChildByTag(14), "CCSprite")
            local haloSp = tolua.cast(self.m_mainTaskBg:getChildByTag(15), "LuaCCScale9Sprite")
            
            if isFinish == true then
                if fSp then
                    fSp:setVisible(true)
                end
                if ufSp then
                    ufSp:setVisible(false)
                end
                if haloSp then
                    haloSp:setVisible(true)
                end
            else
                if fSp then
                    fSp:setVisible(false)
                end
                if ufSp then
                    ufSp:setVisible(true)
                end
                if haloSp then
                    haloSp:setVisible(false)
                end
            end
            
            local btnWidth = 130
            local scale = 1
            if self.m_mainTaskBtn == nil then
                local itemMainTask
                if G_checkUseAuditUI() == true then
                    itemMainTask = GetButtonItem("mainTaskBtn_tishen.png", "mainTaskBtn_tishen.png", "mainTaskBtn_tishen.png", clickHandler, 11, getlocal("task"), 25, 12)
                    scale = btnWidth / itemMainTask:getContentSize().width + 0.1
                    itemMainTask:setScale(scale)
                    itemMainTask:setAnchorPoint(ccp(0, 0.5))
                    self.m_mainTaskBtn = CCMenu:createWithItem(itemMainTask)
                    self.m_mainTaskBtn:setTouchPriority(-23)
                    self.myUILayer:addChild(self.m_mainTaskBtn, 2)
                elseif G_getGameUIVer()==1 then
                    itemMainTask = GetButtonItem("mainTaskBtn.png", "mainTaskBtn.png", "mainTaskBtn.png", clickHandler, 11, getlocal("task"), 25, 12)
                    scale = btnWidth / itemMainTask:getContentSize().width
                    itemMainTask:setScale(scale)
                    itemMainTask:setAnchorPoint(ccp(1, 0.5))
                    self.m_mainTaskBtn = CCMenu:createWithItem(itemMainTask)
                    self.m_mainTaskBtn:setTouchPriority(-23)
                    self.myUILayer:addChild(self.m_mainTaskBtn, 2)
                else
                    itemMainTask = GetButtonItem("mainTaskBtn1.png", "mainTaskBtn1.png", "mainTaskBtn1.png", clickHandler, 11, getlocal("task"), 25, 12)
                    scale = btnWidth / itemMainTask:getContentSize().width
                    itemMainTask:setScale(scale)
                    itemMainTask:setAnchorPoint(ccp(1, 0.5))
                    self.m_mainTaskBtn = CCMenu:createWithItem(itemMainTask)
                    self.m_mainTaskBtn:setTouchPriority(-23)
                    self.myUILayer:addChild(self.m_mainTaskBtn, 2)
                end
                
                local lb = tolua.cast(itemMainTask:getChildByTag(12), "CCLabelTTF")
                lb:setScale(1 / scale)
            end
            local itemSp = tolua.cast(self.m_mainTaskBtn:getChildByTag(11), "CCMenuItemSprite")
            
            local posX = (G_VisibleSizeWidth - (btnWidth + self.m_mainTaskBg:getContentSize().width)) / 2 + btnWidth
            if G_checkUseAuditUI() == true then
                self.m_mainTaskBtn:setPosition(ccp(posX - 50, 218))
                self.m_mainTaskBg:setPosition(ccp(posX - 50, 218))
            elseif G_getGameUIVer()==1 then
                self.m_mainTaskBtn:setPosition(ccp(posX + 2, 218))
                self.m_mainTaskBg:setPosition(ccp(posX - 2, 218))
            else
                self.m_mainTaskBg:setPosition(ccp((G_VisibleSizeWidth-self.m_mainTaskBg:getContentSize().width)/2, 198))
                self.m_mainTaskBtn:setPosition(ccp(posX + 63, 196))
            end
            
            self.m_lastShowTime = base.serverTime
            self.m_lastMainTaskId = mainTask.sid
            self.m_lastFinish = isFinish
        elseif self then
            if self.m_mainTaskBg then
                self.m_mainTaskBg:removeFromParentAndCleanup(true)
                self.m_mainTaskBg = nil
            end
            if self.m_mainTaskBtn then
                self.m_mainTaskBtn:removeFromParentAndCleanup(true)
                self.m_mainTaskBtn = nil
            end
        end
    elseif self then
        if self.m_mainTaskBg then
            self.m_mainTaskBg:removeFromParentAndCleanup(true)
            self.m_mainTaskBg = nil
        end
        if self.m_mainTaskBtn then
            self.m_mainTaskBtn:removeFromParentAndCleanup(true)
            self.m_mainTaskBtn = nil
        end
    end
end
-- function mainUI:mainTaskBgMove(isShow,callback)
--     if self.m_mainTaskBg then
--         if self.mainTaskBgCanMove==true then
--             if self.showMainTask==true then
--                 if isShow==true then
--                     do return end
--                 end
--                 local function moveHandler()
--                     self.mainTaskBgCanMove=true
--                     if self.m_mainTaskBtn then
--                         tolua.cast(self.m_mainTaskBtn:getChildByTag(11),"CCMenuItemSprite"):setRotation(180)
--                     end

--                     local fSp=tolua.cast(self.m_mainTaskBg:getChildByTag(13),"CCSprite")
--                     local ufSp=tolua.cast(self.m_mainTaskBg:getChildByTag(14),"CCSprite")
--                     if fSp then
--                         fSp:setVisible(false)
--                     end
--                     if ufSp then
--                         ufSp:setVisible(false)
--                     end

--                     if callback then
--                         callback()
--                     end
--                 end
--                 self.mainTaskBgCanMove=false
--                 local moveBy=CCMoveBy:create(0.5,ccp(-(self.m_mainTaskBg:getContentSize().width-40),0))
--                 -- local moveTo=CCMoveTo:create(time, ccp(point.x,point.y-20));
--                 local callFunc=CCCallFunc:create(moveHandler)
--                 local acArr=CCArray:create()
--                 -- acArr:addObject(moveTo)
--                 acArr:addObject(moveBy)
--                 acArr:addObject(callFunc)
--                 local seq=CCSequence:create(acArr)
--                 self.m_mainTaskBg:runAction(seq)

--                 self.showMainTask=false
--             elseif self.showMainTask==false then
--                 local fSp=tolua.cast(self.m_mainTaskBg:getChildByTag(13),"CCSprite")
--                 local ufSp=tolua.cast(self.m_mainTaskBg:getChildByTag(14),"CCSprite")
--                 -- local haloSp=tolua.cast(self.m_mainTaskBg:getChildByTag(15),"LuaCCScale9Sprite")

--                 local mainTask=taskVoApi:getMainTask()
--                 if mainTask then
--                     local isFinish=taskVoApi:isCompletedTask(mainTask.sid)
--                     if isFinish==true then
--                         if fSp then
--                             fSp:setVisible(true)
--                         end
--                         if ufSp then
--                             ufSp:setVisible(false)
--                         end
--                         -- if haloSp then
--                         --     haloSp:setVisible(true)
--                         -- end
--                     else
--                         if fSp then
--                             fSp:setVisible(false)
--                         end
--                         if ufSp then
--                             ufSp:setVisible(true)
--                         end
--                         -- if haloSp then
--                         --     haloSp:setVisible(false)
--                         -- end
--                     end
--                 end

--                 local function moveHandler1()
--                     self.mainTaskBgCanMove=true
--                     if self.m_mainTaskBtn then
--                         tolua.cast(self.m_mainTaskBtn:getChildByTag(11),"CCMenuItemSprite"):setRotation(0)
--                     end

--                     if callback then
--                         callback()
--                     end
--                 end
--                 self.mainTaskBgCanMove=false
--                 local moveBy=CCMoveBy:create(0.8,ccp(self.m_mainTaskBg:getContentSize().width-40,0))
--                 -- local moveTo=CCMoveTo:create(time, ccp(point.x,point.y-20));
--                 local callFunc=CCCallFunc:create(moveHandler1)
--                 local acArr=CCArray:create()
--                 -- acArr:addObject(moveTo)
--                 acArr:addObject(moveBy)
--                 acArr:addObject(callFunc)
--                 local seq=CCSequence:create(acArr)
--                 self.m_mainTaskBg:runAction(seq)

--                 self.showMainTask=true
--             end
--         end
--     end

-- end
function mainUI:switchDailyRewardIcon()
    if G_curPlatName() ~= "0" then
        do return end
    end
    if self.m_dailyRewardSp then
        self.myUILayer:removeChild(self.m_dailyRewardSp, true)
        self.m_dailyRewardSp = nil
        
        if self.m_leftIconTab.icon6 ~= nil then
            self.m_leftIconTab.icon6 = nil
        end
        if self.m_leftIconTab.flicker6 ~= nil then
            self.m_leftIconTab.flicker6 = nil
        end
    end
    if G_isToday(base.daily_award) then
        self.m_flagTab.dailyRewardGems = false
        --[[
    if self.m_enemyComingSp then
      if self.m_newGiftsSp then
        self.m_enemyComingSp:setPosition(0,G_VisibleSizeHeight-304-80*3)
      else
        self.m_enemyComingSp:setPosition(0,G_VisibleSizeHeight-304-80*2)
      end
    end
    ]]
    else
        self.m_flagTab.dailyRewardGems = true
        local function dailyRewardHandler(hd, fn, idx)
            if G_checkClickEnable() == false then
                do
                    return
                end
            end
            local function gratisgoodsHandler(fn, data)
                if base:checkServerData(data) == true then
                    --smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("daily_scene_get"),rewardStr,nil,4)
                    if self.m_dailyRewardSp then
                        self.myUILayer:removeChild(self.m_dailyRewardSp, true)
                        self.m_dailyRewardSp = nil
                        
                        if self.m_leftIconTab.icon6 ~= nil then
                            self.m_leftIconTab.icon6 = nil
                        end
                        if self.m_leftIconTab.flicker6 ~= nil then
                            self.m_leftIconTab.flicker6 = nil
                        end
                        self:resetLeftIconPos()
                        local honorNum = playerVoApi:getRankDailyHonor(playerVoApi:getRank())
                        local gemNum = playerCfg.dailyAwardGem
                        local rewardStr = getlocal("dailyRewardDesc", {gemNum, honorNum})
                        local award = {u = {{honors = honorNum}, {gem = gemNum}}}
                        award = FormatItem(award)
                        popDialog:createNewGuid(sceneGame, 4, getlocal("dailyRewardTitle"), rewardStr, award)
                    end
                end
            end
            socketHelper:gratisgoods(gratisgoodsHandler)
        end
        if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
            self.m_dailyRewardSp = LuaCCSprite:createWithSpriteFrameName("Icon_prestige.png", dailyRewardHandler)
        else
            self.m_dailyRewardSp = LuaCCSprite:createWithSpriteFrameName("Icon_prestige1.png", dailyRewardHandler)
        end
        self.m_dailyRewardSp:setTag(1009)
        self.m_dailyRewardSp:setAnchorPoint(ccp(0, 0))
        self.m_dailyRewardSp:setTouchPriority(-23)
        self.m_dailyRewardSp:setScaleX(self.m_iconScaleX)
        self.m_dailyRewardSp:setScaleY(self.m_iconScaleY)
        self.myUILayer:addChild(self.m_dailyRewardSp)
        if self.m_newGiftsSp then
            self.m_dailyRewardSp:setPosition(0, G_VisibleSizeHeight - 304 - 80 * 3)
            if G_getGameUIVer()==2 then
                self.m_dailyRewardSp:setPosition(4, G_VisibleSizeHeight - 304 - 80 * 3)
            end
        else
            self.m_dailyRewardSp:setPosition(0, G_VisibleSizeHeight - 304 - 80 * 2)
            if G_getGameUIVer()==2 then
                self.m_dailyRewardSp:setPosition(4, G_VisibleSizeHeight - 304 - 80 * 2)
            end
        end
        -- self.m_leftIconTab.flicker6=self:iconFlicker(self.m_dailyRewardSp,self.m_iconScaleX,self.m_iconScaleY)
        if G_getGameUIVer()==2 then
            self.m_leftIconTab.flicker6 = G_addNewMainUIRectFlicker(self.m_dailyRewardSp, 1, 1)
        else
            self.m_leftIconTab.flicker6 = G_addFlicker(self.m_dailyRewardSp, 1 / (self.m_iconScaleX / 2), 1 / (self.m_iconScaleY / 2))
        end
        --[[
    if self.m_enemyComingSp then
      if self.m_newGiftsSp then
        self.m_enemyComingSp:setPosition(0,G_VisibleSizeHeight-304-80*4)
      else
        self.m_enemyComingSp:setPosition(0,G_VisibleSizeHeight-304-80*3)
      end
    end
    ]]
        self.m_leftIconTab.icon6 = self.m_dailyRewardSp
    end
end

function mainUI:showEnemyComingIcon(isArrive, attackerName, islandType)
    local diffTime = isArrive
    if diffTime > 0 then
        if self.m_enemyComingSp ~= nil and self.m_countdownLabel ~= nil then
            self.m_countdownLabel:setString(GetTimeStr(diffTime))
        else
            local function showEnemyComingDialog(object, name, tag)
                smallDialog:showEnemyComingDialog("PanelHeaderPopupRed.png", CCSizeMake(600, 500), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), true, true, getlocal("attackedTitle"), 3, enemyAll)
            end
            if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                self.m_enemyComingSp = LuaCCSprite:createWithSpriteFrameName("Icon_warn.png", showEnemyComingDialog)
            else
                self.m_enemyComingSp = LuaCCSprite:createWithSpriteFrameName("Icon_warn1.png", showEnemyComingDialog)
            end
            self.m_enemyComingSp:setTag(1003)
            self.m_enemyComingSp:setAnchorPoint(ccp(0, 0))
            self.m_enemyComingSp:setTouchPriority(-23)
            if self.m_iconScaleX == nil or self.m_iconScaleY == nil then
                self.m_iconScaleX = 0.78
                self.m_iconScaleY = 0.78
            end
            self.m_enemyComingSp:setScaleX(self.m_iconScaleX)
            self.m_enemyComingSp:setScaleY(self.m_iconScaleY)
            self.m_countdownLabel = GetTTFLabel(GetTimeStr(diffTime), 20 / self.m_iconScaleX)
            --self.m_countdownLabel:setAnchorPoint(ccp(0.5,0))
            --self.m_countdownLabel:setPosition(ccp(self.m_enemyComingSp:getContentSize().width/2,0))
            local capInSet = CCRect(5, 5, 1, 1);
            local function touchClick()
            end
            local lbSpBg
            if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                lbSpBg = LuaCCScale9Sprite:createWithSpriteFrameName("IconBgNum.png", capInSet, touchClick)
            else
                lbSpBg = LuaCCScale9Sprite:createWithSpriteFrameName("IconBgNum1.png", capInSet, touchClick)
            end
            lbSpBg:setContentSize(CCSizeMake(100, 20 / self.m_iconScaleX))
            lbSpBg:ignoreAnchorPointForPosition(false)
            lbSpBg:setAnchorPoint(CCPointMake(0.5, 0))
            lbSpBg:setPosition(ccp(self.m_enemyComingSp:getContentSize().width / 2, 0))
            --lbSpBg:setTag(3)
            lbSpBg:addChild(self.m_countdownLabel, 4)
            self.m_countdownLabel:setPosition(getCenterPoint(lbSpBg))
            self.m_enemyComingSp:addChild(lbSpBg, 1)
            
            local height = G_VisibleSizeHeight - 304 - 80 * 2
            if self.m_newGiftsSp then
                height = height - 80
            end
            if self.m_dailyRewardSp then
                height = height - 80
            end
            self.m_enemyComingSp:setPosition(0, height)
            self.myUILayer:addChild(self.m_enemyComingSp);

            local tipStr = ""
            if tonumber(islandType)<6 then
                tipStr = getlocal("promptEnemyComing2",{attackerName})
            elseif tonumber(islandType)==8 then
                tipStr = getlocal("promptEnemyComing3",{attackerName})
            else
                tipStr = getlocal("promptEnemyComing",{attackerName})
            end
            
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tipStr, 30)
            PlayEffect(audioCfg.attack_alert)
            self.m_leftIconTab.icon7 = self.m_enemyComingSp
            self:resetLeftIconPos()
        end
        --[[
    if diffTime==0 then
        local hasEnemy=enemyVoApi:hasEnemy()
        if hasEnemy==true then
        else
          if self.m_enemyComingSp then
            self.myUILayer:removeChild(self.m_enemyComingSp,true)
            self.m_enemyComingSp=nil
            self.m_countdownLabel=nil
 
          end
        end
    end
        ]]
    else
        if self.m_enemyComingSp then
            self.myUILayer:removeChild(self.m_enemyComingSp, true)
            self.m_enemyComingSp = nil
            self.m_countdownLabel = nil
            
            if self.m_leftIconTab.icon7 ~= nil then
                self.m_leftIconTab.icon7 = nil
            end
            self:resetLeftIconPos()
        end
    end
end

function mainUI:switchNewYearIcon()
    if self.m_newYearIcon then
        self.myUILayer:removeChild(self.m_newYearIcon, true)
        self.m_newYearIcon = nil;
        
        if self.m_leftIconTab.icon9 ~= nil then
            self.m_leftIconTab.icon9 = nil
        end
        if self.m_leftIconTab.flicker9 ~= nil then
            self.m_leftIconTab.flicker9 = nil
        end
        self:resetLeftIconPos()
    end
    local newYearState = activityVoApi:canReward("newyear")
    if newYearState == true then
        local function newyearRewardHandler(hd, fn, idx)
            local function newyearRewardCallback(fn, data)
                if base:checkServerData(data) == true then
                    -- if true then
                    if self.m_newYearIcon then
                        self.myUILayer:removeChild(self.m_newYearIcon, true)
                        self.m_newYearIcon = nil
                        
                        if self.m_leftIconTab.icon9 ~= nil then
                            self.m_leftIconTab.icon9 = nil
                        end
                        if self.m_leftIconTab.flicker9 ~= nil then
                            self.m_leftIconTab.flicker9 = nil
                        end
                        self:resetLeftIconPos()
                        local activityVo = activityVoApi:getActivityVo("newyear")
                        local award = activityVo.award
                        popDialog:createNewGuid(sceneGame, 4, getlocal("activity_newYearTitle"), getlocal("activity_newYearDesc"), award)
                    end
                end
            end
            -- newyearRewardCallback(nil,nil)
            socketHelper:activeReward("newyear", newyearRewardCallback)
        end
        --self.m_newYearIcon=LuaCCSprite:createWithSpriteFrameName("7days.png",newyearRewardHandler)
        if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
            self.m_newYearIcon = LuaCCSprite:createWithFileName("public/newYearIcon.png", newyearRewardHandler)
        else
            self.m_newYearIcon = LuaCCSprite:createWithFileName("newYearIcon1.png", newyearRewardHandler)
        end
        self.m_newYearIcon:setTag(1010)
        self.m_newYearIcon:setAnchorPoint(ccp(0, 0))
        self.m_newYearIcon:setTouchPriority(-23)
        self.m_newYearIcon:setPosition(0, G_VisibleSizeHeight - 304 - 80)
        self.m_newYearIcon:setScaleX(self.m_iconScaleX)
        self.m_newYearIcon:setScaleY(self.m_iconScaleY)
        self.myUILayer:addChild(self.m_newYearIcon)
        -- self.m_leftIconTab.flicker9=self:iconFlicker(self.m_newYearIcon,self.m_iconScaleX,self.m_iconScaleY)
        if G_getGameUIVer()==2 then
            self.m_leftIconTab.flicker9 = G_addNewMainUIRectFlicker(self.m_newYearIcon, 1 , 1 )
        else
            self.m_leftIconTab.flicker9 = G_addFlicker(self.m_newYearIcon, 1 / (self.m_iconScaleX / 2), 1 / (self.m_iconScaleY / 2))
        end
        self.m_leftIconTab.icon9 = self.m_newYearIcon
        self:resetLeftIconPos()
    end
    self.m_flagTab.hasNewYearReward = newYearState
end

--只有360平台用
function mainUI:switchNoticeIcon()
    if G_curPlatName() ~= "qihoo" then
        do return end
    end
    if platFormCfg and platFormCfg.noticeTitle and platFormCfg.noticeContent then
        local isShowNoticeIcon = false
        if base.curZoneID == 5 then
            G_noticeEndTime = 1392688800
        elseif base.curZoneID == 6 then
            G_noticeEndTime = 1392861600
        else
            G_noticeEndTime = 0
        end
        if base.serverTime > G_noticeStartTime and base.serverTime < G_noticeEndTime then
            --[[
            local showNoticeTime=CCUserDefault:sharedUserDefault():getIntegerForKey(G_local_showNoticeTime)
            if showNoticeTime==nil or showNoticeTime==0 then
                isShowNoticeIcon=true
            elseif showNoticeTime<G_getWeeTs(base.serverTime) then
                isShowNoticeIcon=true
            end
            ]]
            isShowNoticeIcon = true
        end
        
        if isShowNoticeIcon == true then
            if self.m_noticeIcon == nil then
                local function showNoticeHandler(hd, fn, idx)
                    local noticeTitle = ""
                    local noticeContent = ""
                    if platFormCfg and platFormCfg.noticeTitle and platFormCfg.noticeContent then
                        local tmpContent = platFormCfg["noticeContent"..base.curZoneID]
                        if tmpContent == nil then
                            tmpContent = platFormCfg.noticeContent
                        end
                        smallDialog:showTableViewSure("PanelHeaderPopup.png", CCSizeMake(600, 800), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), platFormCfg.noticeTitle, tmpContent, true, 3)
                        
                        CCUserDefault:sharedUserDefault():setIntegerForKey(G_local_showNoticeTime, base.serverTime)
                        CCUserDefault:sharedUserDefault():flush()
                        
                        self.myUILayer:removeChild(self.m_noticeIcon, true)
                        self.m_noticeIcon = nil;
                        
                        if self.m_leftIconTab.icon10 ~= nil then
                            self.m_leftIconTab.icon10 = nil
                        end
                        if self.m_leftIconTab.flicker10 ~= nil then
                            self.m_leftIconTab.flicker10 = nil
                        end
                        self:resetLeftIconPos()
                    end
                end
                --self.m_noticeIcon=LuaCCSprite:createWithSpriteFrameName("Icon_taskDone.png",showNoticeHandler)
                if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                    self.m_noticeIcon = LuaCCSprite:createWithFileName("public/newYearIcon.png", showNoticeHandler)
                else
                    self.m_noticeIcon = LuaCCSprite:createWithFileName("newYearIcon1.png", showNoticeHandler)
                end
                self.m_noticeIcon:setAnchorPoint(ccp(0, 0))
                self.m_noticeIcon:setTouchPriority(-23)
                --self.m_noticeIcon:setPosition(0,G_VisibleSizeHeight-304-80)
                self.m_noticeIcon:setScaleX(self.m_iconScaleX)
                self.m_noticeIcon:setScaleY(self.m_iconScaleY)
                self.myUILayer:addChild(self.m_noticeIcon)
                -- self.m_leftIconTab.flicker10=self:iconFlicker(self.m_noticeIcon,self.m_iconScaleX,self.m_iconScaleY)
                if G_getGameUIVer()==2 then
                    self.m_leftIconTab.flicker10 = G_addNewMainUIRectFlicker(self.m_noticeIcon, 1 , 1)
                else
                    self.m_leftIconTab.flicker10 = G_addFlicker(self.m_noticeIcon, 1 / (self.m_iconScaleX / 2), 1 / (self.m_iconScaleY / 2))
                end
                self.m_leftIconTab.icon10 = self.m_noticeIcon
                self:resetLeftIconPos()
            else
                self:resetLeftIconPos()
            end
        else
            if self.m_noticeIcon then
                self.myUILayer:removeChild(self.m_noticeIcon, true)
                self.m_noticeIcon = nil;
                
                if self.m_leftIconTab.icon10 ~= nil then
                    self.m_leftIconTab.icon10 = nil
                end
                if self.m_leftIconTab.flicker10 ~= nil then
                    self.m_leftIconTab.flicker10 = nil
                end
                self:resetLeftIconPos()
            end
        end
    end
end

function mainUI:switchStewardIcon()
    if stewardVoApi == nil or stewardVoApi:isOpen() ~= true then
        do return end
    end
    if self.m_stewardSp == nil then
        local function stewardHandler()
            local layerNum = 3
            require "luascript/script/game/scene/gamedialog/stewardDialog"
            stewardDialog:showStewardDialog(layerNum, getlocal("steward_title"))
        end
        if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
            self.m_stewardSp = LuaCCSprite:createWithSpriteFrameName("steward_mainUI_icon.png", stewardHandler)
        else
            self.m_stewardSp = LuaCCSprite:createWithSpriteFrameName("steward_mainUI_icon1.png", stewardHandler)
        end
        self.m_stewardSp:setAnchorPoint(ccp(0, 0))
        self.m_stewardSp:setTouchPriority(-23)
        -- self.m_stewardSp:setScaleX(self.m_iconScaleX)
        -- self.m_stewardSp:setScaleY(self.m_iconScaleY)
        self.myUILayer:addChild(self.m_stewardSp, 4)
        
        -- self.m_leftIconTab.flicker12=G_addFlicker(self.m_stewardSp,1/(self.m_iconScaleX/2),1/(self.m_iconScaleY/2))
        
        self.m_leftIconTab.icon12 = self.m_stewardSp
        self:resetLeftIconPos()
    end
    if self.m_stewardSp then
        local _stewardState = stewardVoApi:getStewardIconState()
        if self.m_stewardSpIsRuningAction == nil and _stewardState == true then
            local scale1 = CCScaleTo:create(0.5, 0.8)
            local scale2 = CCScaleTo:create(0.5, 1)
            local seq = CCSequence:createWithTwoActions(scale1, scale2)
            self.m_stewardSp:runAction(CCRepeatForever:create(seq))
            self.m_stewardSpIsRuningAction = true
        elseif self.m_stewardSpIsRuningAction == true and _stewardState == false then
            self.m_stewardSp:stopAllActions()
            self.m_stewardSpIsRuningAction = nil
            self.m_stewardSp:setScale(1)
        end
    end
    
end

function mainUI:switchMilitaryOrdersIcon()
    if militaryOrdersVoApi == nil or militaryOrdersVoApi:isOpen() ~= true then
        do return end
    end
    if self.m_militaryOrdersSp == nil then
        local function militaryOrdersHandler()
            local layerNum = 3
            militaryOrdersVoApi:showMainDialog(layerNum)
        end
        if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
            self.m_militaryOrdersSp = LuaCCSprite:createWithSpriteFrameName("moi_icon.png", militaryOrdersHandler)
        else
            self.m_militaryOrdersSp = LuaCCSprite:createWithSpriteFrameName("moi_icon1.png", militaryOrdersHandler)
        end
        self.m_militaryOrdersSp:setAnchorPoint(ccp(0, 0))
        self.m_militaryOrdersSp:setTouchPriority(-23)
        self.m_militaryOrdersSp:setScaleX(self.m_iconScaleX)
        self.m_militaryOrdersSp:setScaleY(self.m_iconScaleY)
        self.myUILayer:addChild(self.m_militaryOrdersSp, 4)
        self.m_leftIconTab.icon11 = self.m_militaryOrdersSp
        self:resetLeftIconPos()
    end
    if self.m_militaryOrdersSp then
        local moState = militaryOrdersVoApi:mainUIIconStatus(function()
            if militaryOrdersVoApi:mainUIIconStatus() == true then
                if self.m_militaryOrdersSpFlicker == nil then
                    if G_getGameUIVer()==2 then
                        self.m_militaryOrdersSpFlicker = G_addNewMainUIRectFlicker(self.m_militaryOrdersSp, 1 , 1)
                    else
                        self.m_militaryOrdersSpFlicker = G_addFlicker(self.m_militaryOrdersSp, 1 / (self.m_iconScaleX / 2), 1 / (self.m_iconScaleY / 2))
                    end
                end
            elseif self.m_militaryOrdersSpFlicker then
                self.m_militaryOrdersSpFlicker:removeFromParentAndCleanup(true)
                self.m_militaryOrdersSpFlicker = nil
            end
        end)
        if moState == true then
            if self.m_militaryOrdersSpFlicker == nil then
                if G_getGameUIVer()==2 then
                    self.m_militaryOrdersSpFlicker = G_addNewMainUIRectFlicker(self.m_militaryOrdersSp, 1 , 1 )
                else
                    self.m_militaryOrdersSpFlicker = G_addFlicker(self.m_militaryOrdersSp, 1 / (self.m_iconScaleX / 2), 1 / (self.m_iconScaleY / 2))
                end
                
            end
        elseif self.m_militaryOrdersSpFlicker then
            self.m_militaryOrdersSpFlicker:removeFromParentAndCleanup(true)
            self.m_militaryOrdersSpFlicker = nil
        end
    end
end

function mainUI:switchActivityAndNoteIcon()
    --[[
    if G_ifDebug~=1 then
        if G_curPlatName()~="1" and G_curPlatName()~="42" and G_curPlatName()~="qihoo" and G_curPlatName()~="4" and G_curPlatName()~="efunandroiddny" and G_curPlatName()~="androiduc" then
            do
                return
            end
        end
    end
    ]]
    
    if self.m_acAndNoteSp then
        self.myUILayer:removeChild(self.m_acAndNoteSp, true)
        self.m_acAndNoteSp = nil
        
        if self.m_leftIconTab.icon5 ~= nil then
            self.m_leftIconTab.icon5 = nil
        end
        if self.m_leftIconTab.flicker5 ~= nil then
            self.m_leftIconTab.flicker5 = nil
        end
    end
    if self.m_flagTab.hadAcAndNote == true then
        local function acAndNoteHandler(hd, fn, idx)
            self:showAcAndNote()
        end
        if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
            self.m_acAndNoteSp = LuaCCSprite:createWithSpriteFrameName("acAndNote.png", acAndNoteHandler)
        else
            self.m_acAndNoteSp = LuaCCSprite:createWithSpriteFrameName("acAndNote1.png", acAndNoteHandler)
        end
        self.m_acAndNoteSp:setAnchorPoint(ccp(0, 0))
        self.m_acAndNoteSp:setTouchPriority(-23)
        self.m_acAndNoteSp:setScaleX(self.m_iconScaleX)
        self.m_acAndNoteSp:setScaleY(self.m_iconScaleY)
        self.myUILayer:addChild(self.m_acAndNoteSp, 4)
        
        if self.m_flagTab.acAndNoteState then
            -- self.m_leftIconTab.flicker5=self:iconFlicker(self.m_acAndNoteSp,self.m_iconScaleX,self.m_iconScaleY)
            if G_getGameUIVer()==2 then
                self.m_leftIconTab.flicker5 = G_addNewMainUIRectFlicker(self.m_acAndNoteSp, 1 , 1 )
            else
                self.m_leftIconTab.flicker5 = G_addFlicker(self.m_acAndNoteSp, 1 / (self.m_iconScaleX / 2), 1 / (self.m_iconScaleY / 2))
            end
        end
        self.m_leftIconTab.icon5 = self.m_acAndNoteSp
        if self.m_flagTab.newAcAndNoteNum > 0 then
            local numHeight = 20
            if G_getGameUIVer()==2 then
                numHeight = 24
            end
            local iconWidth = 36
            local iconHeight = 36
            local newsNumLabel = GetTTFLabel(tonumber(self.m_flagTab.newAcAndNoteNum), numHeight)
            local capInSet1 = CCRect(17, 17, 1, 1)
            local function touchClick()
            end
            local newsIcon
            if G_checkUseAuditUI() == true or G_getGameUIVer()==1 then
                newsIcon = LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png", CCRect(17, 17, 1, 1), touchClick)
            else
                newsIcon = LuaCCScale9Sprite:createWithSpriteFrameName("NumBg1.png", CCRect(17, 17, 1, 1), touchClick)
                newsIcon:setScale(0.8)
            end
            newsIcon:ignoreAnchorPointForPosition(false)
            if platCfg.platLanguageNote[G_curPlatName()] ~= nil then
                newsIcon:setScale(0.6)
                newsIcon:setPosition(ccp(95, 90))
            else
                if newsNumLabel:getContentSize().width + 10 > iconWidth then
                    iconWidth = newsNumLabel:getContentSize().width + 10
                end
                newsIcon:setContentSize(CCSizeMake(iconWidth, iconHeight))
                newsIcon:setAnchorPoint(CCPointMake(1, 0.5))
                newsIcon:setPosition(ccp(110, 90))
                newsIcon:addChild(newsNumLabel, 1)
                newsNumLabel:setPosition(getCenterPoint(newsIcon))
            end
            self.m_acAndNoteSp:addChild(newsIcon,5)
            
        end
        
    end
end
--协防
function mainUI:switchHelpDefendIcon()
    local helpDefendVo = helpDefendVoApi:getTimeLeast()
    local diffTime = 0
    if helpDefendVo and helpDefendVo.time then
        diffTime = helpDefendVo.time - base.serverTime
        if diffTime < 0 then
            diffTime = 0
        end
    end
    if helpDefendVo and SizeOfTable(helpDefendVo) > 0 then
        if self.m_helpDefendIcon == nil then
            local function showNoticeHandler(hd, fn, idx)
                allianceSmallDialog:showHelpDefendDialog("PanelHeaderPopup.png", CCSizeMake(600, 500), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), false, true, getlocal("coverTitle"), 3)
            end
            if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                self.m_helpDefendIcon = LuaCCSprite:createWithSpriteFrameName("IconHelp.png", showNoticeHandler)
            else
                self.m_helpDefendIcon = LuaCCSprite:createWithSpriteFrameName("IconHelp1.png", showNoticeHandler)
            end
            self.m_helpDefendIcon:setAnchorPoint(ccp(0, 0))
            self.m_helpDefendIcon:setTouchPriority(-23)
            self.m_helpDefendIcon:setScaleX(self.m_iconScaleX)
            self.m_helpDefendIcon:setScaleY(self.m_iconScaleY)
            self.myUILayer:addChild(self.m_helpDefendIcon)
            self.m_leftIconTab.icon8 = self.m_helpDefendIcon
            
            self.m_helpDefendLabel = GetTTFLabel(GetTimeStr(diffTime), 20 / self.m_iconScaleX)
            
            local capInSet = CCRect(5, 5, 1, 1)
            local function touchClick()
            end
            local lbSpBg
            if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                lbSpBg = LuaCCScale9Sprite:createWithSpriteFrameName("IconBgNum.png", capInSet, touchClick)
            else
                lbSpBg = LuaCCScale9Sprite:createWithSpriteFrameName("IconBgNum1.png", capInSet, touchClick)
            end
            lbSpBg:setContentSize(CCSizeMake(100, 20 / self.m_iconScaleX))
            lbSpBg:ignoreAnchorPointForPosition(false)
            lbSpBg:setAnchorPoint(CCPointMake(0.5, 0))
            lbSpBg:setTag(33)
            lbSpBg:setPosition(ccp(self.m_helpDefendIcon:getContentSize().width / 2, 0))
            lbSpBg:addChild(self.m_helpDefendLabel, 4)
            self.m_helpDefendLabel:setPosition(getCenterPoint(lbSpBg))
            self.m_helpDefendIcon:addChild(lbSpBg, 4)
            
            if diffTime <= 0 then
                lbSpBg:setVisible(false)
            end
            self:resetLeftIconPos()
        else
            if self.m_helpDefendIcon:getChildByTag(33) then
                if diffTime > 0 then
                    tolua.cast(self.m_helpDefendIcon:getChildByTag(33), "LuaCCScale9Sprite"):setVisible(true)
                    if self.m_helpDefendLabel ~= nil then
                        self.m_helpDefendLabel:setString(GetTimeStr(diffTime))
                    end
                else
                    tolua.cast(self.m_helpDefendIcon:getChildByTag(33), "LuaCCScale9Sprite"):setVisible(false)
                end
            end
            self:resetLeftIconPos()
        end
    else
        if self.m_helpDefendIcon then
            self.m_helpDefendIcon:removeFromParentAndCleanup(true)
            self.m_helpDefendIcon = nil
            self.m_helpDefendLabel = nil
            
            if self.m_leftIconTab.icon8 ~= nil then
                self.m_leftIconTab.icon8 = nil
            end
            -- if self.m_leftIconTab.flicker8~=nil then
            --     self.m_leftIconTab.flicker8=nil
            -- end
            self:resetLeftIconPos()
        end
        --测试数据
        -- data={{id=1,name="player1",ts=1402969845,status=0},{id=2,name="player2",ts=0,status=1},{id=3,name="player3",ts=1392870545,status=2},{id=3,name="player4",ts=1392979845,status=1},{id=3,name="player5",ts=1333870545,status=1}}
        -- helpDefendVoApi:formatData(data)
    end
end

function mainUI:resetLeftIconPos()
    -- if GM_UidCfg[playerVoApi:getUid()] then--用于GM判断
    --       for k,v in pairs(self.m_leftIconTab) do
    --         v:setPositionX(v:getPositionX()-100)
    --         v:setVisible(false)
    --       end
    --       do return end
    --   end
    -- if self.m_leftIconTab then
    --    if base.isGlory == 1 and self.isNewGuideShow ==false then --self.m_leftIconTab["flicker"..i]:setPosition(ccp(0,G_VisibleSizeHeight-225-i*80))
    --      if self.gloryBg then
    --        self.gloryBg:setPosition(0,G_VisibleSizeHeight-225)
    --      end
    --      local height=G_VisibleSizeHeight-304
    --      for i=1,15 do
    --        if self.m_leftIconTab["icon"..i]~=nil then
    --                  if self.m_leftIconTab["icon"..i].getPositionY~=height then
    --                    self.m_leftIconTab["icon"..i]:setPosition(0,height)
    --                  end
    --          height=height-78
    --        end
    --      end
    --    else
    --      if self.gloryBg then
    --        self.gloryBg:setPosition(0,10000)
    --      end
    --      if self.m_leftIconTab.icon1 then
    --        self.m_leftIconTab.icon1:setPosition(0,G_VisibleSizeHeight-225)
    --      end
    --  local height=G_VisibleSizeHeight-304
    --  for i=2,15 do
    --  if self.m_leftIconTab["icon"..i]~=nil then
    --                  if self.m_leftIconTab["icon"..i].getPositionY~=height then
    --      self.m_leftIconTab["icon"..i]:setPosition(0,height)
    --                  end
    --  height=height-78
    --  end
    --  end
    --    end
    -- end
    if sceneController and sceneController.curIndex ~= 2 then
        if self.m_leftIconTab then
            if base.isGlory == 1 and self.isNewGuideShow == false then --self.m_leftIconTab["flicker"..i]:setPosition(ccp(0,G_VisibleSizeHeight-225-i*80))
                if self.gloryBg then
                    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                        self.gloryBg:setPosition(0, G_VisibleSizeHeight - 225)
                    else
                        self.gloryBg:setPosition(4, G_VisibleSizeHeight - 280)
                    end
                end
                local height
                if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                    height = G_VisibleSizeHeight - 304
                else
                    height = G_VisibleSizeHeight - 363 --11111左边第二个图标开始的位置
                end
                for i = 1, 20 do
                    if self.m_leftIconTab["icon"..i] ~= nil then
                        if self.m_leftIconTab["icon"..i].getPositionY ~= height then
                            if i == 12 then
                                height = height - 25
                            end
                            self.m_leftIconTab["icon"..i]:setPosition(0, height)
                            if G_getGameUIVer()== 2 then
                                self.m_leftIconTab["icon"..i]:setPosition(4, height)
                            end
                        end
                        if G_getGameUIVer()==2 then
                            height = height - 84
                        else
                            height = height - 78
                        end
                    end
                end
            else
                if self.gloryBg then
                    self.gloryBg:setPosition(0, 10000)
                end
                if self.m_leftIconTab.icon1 then
                    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                        self.m_leftIconTab.icon1:setPosition(0, G_VisibleSizeHeight - 225)
                    else
                        self.m_leftIconTab.icon1:setPosition(4, G_VisibleSizeHeight - 247)
                    end
                end
                local height
                if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                    height = G_VisibleSizeHeight - 304
                else
                    height = G_VisibleSizeHeight - 330 --11111左边第二个图标开始的位置
                end
                for i = 2, 20 do
                    if self.m_leftIconTab["icon"..i] ~= nil then
                        if self.m_leftIconTab["icon"..i].getPositionY ~= height then
                            if i == 12 then
                                height = height - 25
                            end
                            if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                                self.m_leftIconTab["icon"..i]:setPosition(0, height)
                            else
                                self.m_leftIconTab["icon"..i]:setPosition(4, height)
                            end
                        end
                        if G_getGameUIVer()==2 then
                            height = height - 84
                        else
                            height = height - 78
                        end
                    end
                end
            end
        end
    else
        if self.m_leftIconTab then
            for i = 1, 20 do
                if self.m_leftIconTab["icon"..i] ~= nil then
                    if i == 7 then
                        self.m_leftIconTab["icon"..i]:setPosition(0, 275)
                        if G_getGameUIVer()== 2 then
                            self.m_leftIconTab["icon"..i]:setPosition(4, 275)
                        end
                    elseif i == 8 then
                        self.m_leftIconTab["icon"..i]:setPosition(0, 195)
                        if G_getGameUIVer()== 2 then
                            self.m_leftIconTab["icon"..i]:setPosition(4, 195)
                        end
                    else
                        self.m_leftIconTab["icon"..i]:setPosition(0, 10000)
                    end
                end
            end
            if self.gloryBg then
                self.gloryBg:setPosition(0, 10000)
            end
        end
    end
end

-- 右上角按钮（首充奖励按钮、在线礼包和facebook 好友列表按钮）
function mainUI:resetRightTopIconPos()
    -- if GM_UidCfg[playerVoApi:getUid()] then--用于GM判断
    --     for k,v in pairs(self.m_rightTopIconTab) do
    --       v:setVisible(false)
    --     end
    --     do return end
    -- end
    if sceneController and sceneController.curIndex ~= 2 then
        if self.m_rightTopIconTab then
            local iconX = G_VisibleSizeWidth - 135
            if G_getGameUIVer()== 2 then
                iconX = G_VisibleSizeWidth - 128
            end
            local icon = nil
            local iconIdx = 1
            for i = 1, 11 do
                icon = self.m_rightTopIconTab["icon"..i]
                if icon ~= nil then
                    if icon:getPositionX() ~= iconX then
                        if iconIdx > 6 then
                            if G_checkUseAuditUI()==true or (G_getGameUIVer)==1 then
                                icon:setPosition(iconX, G_VisibleSizeHeight - 280)
                            else
                                icon:setPosition(iconX, G_VisibleSizeHeight - 250.5)
                            end
                        else
                            if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                                icon:setPosition(iconX, G_VisibleSizeHeight - 185)
                            else
                                icon:setPosition(iconX, G_VisibleSizeHeight - 155.5)
                            end
                        end
                    end
                    if iconIdx % 6 ~= 0 then
                        if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                            iconX = iconX - 90
                        else
                            iconX = iconX - 86
                        end
                    else
                        iconX = G_VisibleSizeWidth - 135
                        if G_getGameUIVer()== 2 then
                            iconX = G_VisibleSizeWidth - 128
                        end
                    end
                    iconIdx = iconIdx + 1
                end
            end
        end
    else
        if self.m_rightTopIconTab then
            for i = 1, 11 do
                icon = self.m_rightTopIconTab["icon"..i]
                if icon and icon.setPosition then
                    icon:setPosition(ccp(0, 10000))
                end
            end
        end
    end
end

--世界地图显示或隐藏周边按钮
function mainUI:showOrHideQuicklyBtn()
    self:resetLeftIconPos()
    self:resetRightTopIconPos()
    if sceneController and sceneController.curIndex == 2 then
        if self.m_menuToggleSmall then
            self.menuAllSmall:setPosition(ccp(0, 10000))
        end
        if self.m_luaSpTab then
            for k, v in pairs(self.m_luaSpTab) do
                if v and v.setPosition then
                    v:setPosition(ccp(0, 10000))
                end
            end
        end
        if self.m_luaSp7 then
            self.m_luaSp7:setPosition(ccp(0, 10000))
        end
        self:showOrHideSelectSp(false)
    else
        if self.m_menuToggleSmall and self.m_pointLuaSp then
            self.menuAllSmall:setPosition(self.m_pointLuaSp)
            if self.m_luaSpTab then
                self:pushSmallMenu()
            end
        end
        self:showOrHideSelectSp(true)
    end
end

-- 世界地图上的方向标
function mainUI:addDirectionSign()
    
    local function onDirectSign()
        worldScene:focus(playerVoApi:getMapX(), playerVoApi:getMapY())
        -- 方向标在屏幕内，不显示
        if self.m_directSign ~= nil then
            self.m_directSign:setVisible(false)
        end
    end
    -- 方向标按钮
    -- self.m_directSignItem = GetButtonItem("directionSign.png","directionSign.png","directionSign.png",onDirectSign,nil,nil,nil)
    -- self.m_directSignItem:setScale(1.2)
    -- self.m_directSignItem:setAnchorPoint(ccp(1,0.5))
    -- self.m_directSignItem:setTag(3003)
    -- self.m_directSign = CCMenu:createWithItem(self.m_directSignItem)
    -- self.m_directSign:setPosition(ccp(self.myUILayer:getContentSize().width,self.myUILayer:getContentSize().height/2))
    -- self.m_directSign:setTouchPriority(-23)
    -- self.m_directSign:setTag(3001)
    -- self.myUILayer:addChild(self.m_directSign,1000)
    
    if self.m_directSign == nil then
        -- self.m_directSign = LuaCCSprite:createWithFileName("public/directionSign.png",onDirectSign)
        self.m_directSign = LuaCCSprite:createWithSpriteFrameName("directionSign.png", onDirectSign)
        self.m_directSign:setScale(1.2)
        self.m_directSign:setAnchorPoint(ccp(1, 0.5))
        -- self.m_directSign:setTag(3003)
        self.m_directSign:setPosition(ccp(self.myUILayer:getContentSize().width, self.myUILayer:getContentSize().height / 2))
        self.m_directSign:setTouchPriority(-23)
        self.m_directSign:setTag(3001)
        self.myUILayer:addChild(self.m_directSign, 1000)
        
        -- 方向标按钮上有个距离显示的label
        self.m_distanceLabel = GetTTFLabel("0KM", 16)
        self.m_distanceLabel:setAnchorPoint(ccp(0.5, 0.5))
        self.m_distanceLabel:setPosition(ccp(self.m_directSign:getContentSize().width * 0.6, self.m_directSign:getContentSize().height / 2))
        self.m_distanceLabel:setTag(3002)
        --haiLiLabel:setPosition(ccp(directSignItem:getContentSize().width*0.7,directSignItem:getContentSize().height/2))
        self.m_directSign:addChild(self.m_distanceLabel, 1)
        --directSignItem:addChild(haiLiLabel,1)
        -- 刚添加不显示方向标
        self.m_directSign:setVisible(false)
        self.m_directSign:setPosition(ccp(0, 10000))
        self.m_haveAddDirectSign = true
    end
end

-- 拖动世界地图，方向标跟着动
function mainUI:directSignMove(point)
    -- 获取基地位置
    local playerX = tonumber(playerVoApi:getMapX())
    local playerY = tonumber(playerVoApi:getMapY())
    local viewCenterX = tonumber(point.x)
    local viewCenterY = tonumber(point.y)
    -- 如果方向标为空，或者还没有添加方向标则返回
    if self.m_directSign == nil or self.m_haveAddDirectSign == false then
        return
    end
    -- 移动地图数，判断基地在不在视野内，在视野内则隐藏方向标
    if ((playerX > (viewCenterX - 3)) and (playerX < (viewCenterX + 3))) and ((playerY > (viewCenterY - 5)) and (playerY < (viewCenterY + 5))) then
        self.m_directSign:setVisible(false)
        self.m_directSign:setPosition(ccp(0, 10000))
        return
    else
        self.m_directSign:setVisible(true)
    end
    -- if playerY ~= 300 then
    --     playerY = 600 - playerY
    -- end
    -- -- 圆周率
    -- local pai = 3.14159265358979323846
    
    -- -- 偏移距离X
    -- local distanceX = viewCenterX - playerX
    -- -- 转换坐标系
    -- viewCenterY = 600 - viewCenterY
    -- -- 偏移距离Y
    -- local distanceY = viewCenterY - playerY
    
    -- 自己基地的实际位置
    local playerPos = CCPointMake(tonumber(playerVoApi:getMapX()), tonumber(playerVoApi:getMapY()))
    playerPos = worldScene:toPiexl(ccp(playerPos.x, playerPos.y))
    -- playerPos=ccp(playerPos.x,worldScene.worldSize.height-playerPos.y)
    -- 获得当前屏幕位置
    local screenCenterPosInClayer = worldScene.clayer:convertToNodeSpace(ccp(G_VisibleSize.width / 2, G_VisibleSize.height / 2))
    local screenPos = ccp(screenCenterPosInClayer.x, worldScene.worldSize.height - screenCenterPosInClayer.y)
    -- print("playerPos",playerPos.x,playerPos.y)
    -- print("screenPos",screenPos.x,screenPos.y)
    distanceX = screenPos.x - playerPos.x
    distanceY = screenPos.y - playerPos.y
    
    -- print("distanceX,distanceY",distanceX,distanceY)
    -- 绝对值 Y / X
    local tanYX = distanceY / distanceX
    local atan = math.atan
    local deg = math.deg
    -- 旋转弧度
    local radian = atan(tanYX)
    -- 转换成旋转角度
    local angle = deg(radian)
    -- -- 处理当x轴或y轴距离等于0
    -- if (distanceX >= 0 and distanceY >= 0) or (distanceX >= 0 and distanceY < 0) then
    --     angle = -(180-angle)
    -- end
    -- angle = -angle
    if distanceX > 0 then
        angle = angle + 180
    end
    -- print("angle",angle)
    -- 旋转方向标
    if self.m_directSign then
        self.m_directSign:setRotation(angle)
    end
    -- 手机屏幕size
    local mapSize = self.myUILayer:getContentSize()
    local maxX = mapSize.width
    local minX = 0
    local maxY = mapSize.height - 98 - 20
    local minY = 164 + 28
    -- 计算方向标在mainUI中的位置
    local posX = 0
    local posY = 0
    -- 视野在左上角
    if angle >= 0 and angle < 90 then
        -- 0~45
        if angle >= 0 and angle < 45 then
            posX = maxX
            posY = (maxY + 98) / 2 - (angle / 90) * (maxY - minY)
            -- 45~90
        else
            posX = maxX / 2 + ((90 - angle) / 90) * maxX
            posY = minY
        end
        
        -- 视野在右上角
    elseif angle >= 90 and angle < 180 then
        -- 90~135
        if angle >= 90 and angle < 135 then
            posX = ((135 - angle) / 90) * maxX
            posY = minY
            -- 135~180
        else
            posX = minX
            posY = (maxY + 98) / 2 - ((180 - angle) / 90) * (maxY - minY)
        end
        
        -- 视野在左下角
    elseif angle >= -90 and angle < 0 then
        -- -90~-45
        if angle >= -90 and angle < -45 then
            posX = maxX / 2 + ((90 + angle) / 90) * maxX
            posY = maxY
            -- -45~0
        else
            posX = maxX
            posY = (maxY + 98) / 2 + ((-angle) / 90) * (maxY - minY)
        end
        
        -- 视野在右下角
    elseif angle >= 180 and angle <= 270 then
        -- 180~-225
        if angle >= 180 and angle < 225 then
            posX = minX
            posY = (maxY + 98) / 2 + ((angle - 180) / 90) * (maxY - minY)
            -- 225~-270
        else
            posX = ((45 - (270 - angle)) / 90) * maxX
            posY = maxY
        end
    end
    -- UI上方与下方都有方框 设置最大最小y
    if posY > maxY then
        posY = maxY
    end
    if posY < minY then
        posY = minY
    end
    --设置方向标位置
    self.m_directSign:setPosition(ccp(posX, posY))
    local floor = math.floor
    local sqrt = math.sqrt
    local pow = math.pow
    -- 计算直线距离
    local distance = floor(sqrt(pow(point.x - playerVoApi:getMapX(), 2) + pow(point.y - playerVoApi:getMapY(), 2)))
    self.m_distanceLabel:setString(distance.."KM")
    if posX < maxX / 2 then
        self.m_distanceLabel:setFlipY(true)
        self.m_distanceLabel:setFlipX(true)
    else
        self.m_distanceLabel:setFlipY(false)
        self.m_distanceLabel:setFlipX(false)
    end
end

-- 初始化行军缩略信息面板
function mainUI:initMiniFleetSlotLayer()
    if self.miniFleetSlotLayer == nil then
        -- 获取出征table 判断是否还有数据没显示
        self.fleetSlotTab = attackTankSoltVoApi:getAllAttackTankSlots()
        if self.fleetSlotTab == nil or (#self.fleetSlotTab <= 0) then
            do return end
        end
        local function nilFunc(...)
            
        end
        self.miniFleetSlotLayer = LuaCCScale9Sprite:createWithSpriteFrameName("fleet_slot_mini_bg.png", CCRect(70, 43, 1, 1), nilFunc)
        -- self.miniFleetSlotLayer = LuaCCScale:createWithSpriteFrameName("fleet_slot_mini_bg.png",nilFunc)
        -- self.miniFleetSlotLayer = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),nilFunc)
        if self.miniFleetSlotLayer == nil then
            do return end
        end
        -- 一行数据的高度是41个像素
        local layerHeight = 46 * (#self.fleetSlotTab) + 30
        -- 82是2行数据的最小高度，40是title的高度，5是下边空出来的地方
        -- layerHeight = layerHeight<92 and (92+40) or (layerHeight+40)
        local layerSize = CCSizeMake(218, layerHeight)
        -- local layerSize = CCSizeMake(self.miniFleetSlotLayer:getContentSize().width,layerHeight)
        self.miniFleetSlotLayer:setContentSize(layerSize)
        self.miniFleetSlotLayer:setAnchorPoint(ccp(0, 1))
        local layerPosX = 0
        local layerPosY = G_VisibleSize.height - 145--115
        self.miniFleetSlotLayer:setPosition(ccp(layerPosX, layerPosY))
        self.myUILayer:addChild(self.miniFleetSlotLayer, 10)
        self.miniFleetSlotLayer:setTouchPriority(-9)
        self.miniFleetSlotLayer:setIsSallow(true)
        
        -- local titleSp = CCSprite:createWithSpriteFrameName("fleet_slot_mini_title.png")
        -- -- local titleSp = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),nilFunc)
        -- -- titleSp:setContentSize(CCSizeMake(80,35))
        -- titleSp:setAnchorPoint(ccp(1,1))
        -- titleSp:setPosition(ccp(self.miniFleetSlotLayer:getContentSize().width-6.5,self.miniFleetSlotLayer:getContentSize().height-7))
        -- titleSp:setTag(1101)
        -- self.miniFleetSlotLayer:addChild(titleSp,1)
        
        -- local titleLb = GetTTFLabel(getlocal("fleet_slot_title"),16)
        -- titleLb:setPosition(ccp(titleSp:getContentSize().width/2+8,titleSp:getContentSize().height/2))
        -- titleSp:addChild(titleLb,1)
        
        -- 收缩行军队列缩率面板
        local function pushMiniFleetFunc(tag, object)
            PlayEffect(audioCfg.mouseClick)
            if G_checkClickEnable() == false then
                local toggleMenu = tolua.cast(object, "CCMenuItemToggle")
                if toggleMenu ~= nil then
                    if toggleMenu:getSelectedIndex() == 0 then
                        toggleMenu:setSelectedIndex(1)
                    else
                        toggleMenu:setSelectedIndex(0)
                    end
                end
                do return end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            local toggleMenu = tolua.cast(object, "CCMenuItemToggle")
            if toggleMenu ~= nil then
                if toggleMenu:getSelectedIndex() == 1 then
                    toggleMenu:setSelectedIndex(0)
                    local moveTo = CCMoveTo:create(0.3, ccp(-(layerSize.width + 2), layerPosY))
                    local function setIndexFunc()
                        toggleMenu:setSelectedIndex(1)
                    end
                    local indexCallBack = CCCallFunc:create(setIndexFunc)
                    local seq = CCSequence:createWithTwoActions(moveTo, indexCallBack)
                    self.miniFleetSlotLayer:runAction(seq)
                    
                    local leftMenu = tolua.cast(self.miniFleetSlotLayer:getChildByTag(1102), "CCMenu")
                    if leftMenu ~= nil then
                        local moveBy = CCMoveBy:create(0.3, ccp(5, 0))
                        leftMenu:runAction(moveBy)
                    end
                else
                    toggleMenu:setSelectedIndex(1)
                    local moveTo = CCMoveTo:create(0.3, ccp(layerPosX, layerPosY))
                    local function setIndexFunc()
                        toggleMenu:setSelectedIndex(0)
                    end
                    local indexCallBack = CCCallFunc:create(setIndexFunc)
                    local seq = CCSequence:createWithTwoActions(moveTo, indexCallBack)
                    self.miniFleetSlotLayer:runAction(seq)
                    
                    local leftMenu = tolua.cast(self.miniFleetSlotLayer:getChildByTag(1102), "CCMenu")
                    if leftMenu ~= nil then
                        local moveBy = CCMoveBy:create(0.3, ccp(-5, 0))
                        leftMenu:runAction(moveBy)
                    end
                end
            end
        end
        -- 基地左侧缩放按钮
        local selectSp1 = CCSprite:createWithSpriteFrameName("fleet_slot_left_btn.png")
        local flagSp1 = CCSprite:createWithSpriteFrameName("fleet_slot_left_flag.png")
        local flagXoff = 0
        local flagYoff = 0
        flagSp1:setPosition(ccp(selectSp1:getContentSize().width / 2 + flagXoff, selectSp1:getContentSize().height / 2 + flagYoff))
        -- flagSp1:setRotation(180)
        flagSp1:setScale(0.85)
        selectSp1:addChild(flagSp1, 1)
        local selectSp2 = CCSprite:createWithSpriteFrameName("fleet_slot_left_btn_down.png")
        local flagSp2 = CCSprite:createWithSpriteFrameName("fleet_slot_left_flag.png")
        -- flagSp2:setRotation(180)
        flagSp2:setScale(0.85)
        flagSp2:setPosition(ccp(selectSp2:getContentSize().width / 2 + flagXoff, selectSp2:getContentSize().height / 2 + flagYoff))
        selectSp2:addChild(flagSp2, 1)
        local menuItemSp1 = CCMenuItemSprite:create(selectSp1, selectSp2)
        
        local selectSp3 = CCSprite:createWithSpriteFrameName("fleet_slot_left_btn.png")
        local flagSp3 = CCSprite:createWithSpriteFrameName("fleet_slot_left_flag.png")
        
        flagSp3:setPosition(ccp(selectSp3:getContentSize().width / 2 + flagXoff, selectSp2:getContentSize().height / 2 + flagYoff))
        flagSp3:setRotation(180)
        flagSp3:setScale(0.85)
        selectSp3:addChild(flagSp3, 1)
        local selectSp4 = CCSprite:createWithSpriteFrameName("fleet_slot_left_btn_down.png")
        local flagSp4 = CCSprite:createWithSpriteFrameName("fleet_slot_left_flag.png")
        flagSp4:setPosition(ccp(selectSp4:getContentSize().width / 2 + flagXoff, selectSp4:getContentSize().height / 2 + flagYoff))
        flagSp4:setRotation(180)
        flagSp4:setScale(0.85)
        selectSp4:addChild(flagSp4, 1)
        local menuItemSp2 = CCMenuItemSprite:create(selectSp3, selectSp4)
        
        local menuToggleSmall = CCMenuItemToggle:create(menuItemSp1)
        menuToggleSmall:addSubItem(menuItemSp2)
        menuToggleSmall:registerScriptTapHandler(pushMiniFleetFunc)
        menuToggleSmall:setSelectedIndex(0)
        menuToggleSmall:setTag(1)
        
        local menuAllSmall = CCMenu:createWithItem(menuToggleSmall)
        local posX = self.miniFleetSlotLayer:getContentSize().width + menuToggleSmall:getContentSize().width / 2 - 5--18
        local posY = self.miniFleetSlotLayer:getContentSize().height - menuToggleSmall:getContentSize().height / 2
        menuAllSmall:setPosition(ccp(posX, posY))
        menuAllSmall:setTouchPriority(-22)
        menuAllSmall:setTag(1102)
        self.miniFleetSlotLayer:addChild(menuAllSmall, -1)
        
        -- local slotLeftPosX,slotLeftPosY=layerSize.width,self.miniFleetSlotLayer:getContentSize().height-40
        -- -- 收缩行军队列缩率面板
        -- local function pushMiniFleetFunc()
        --     if G_checkClickEnable()==false then
        --         do return end
        --     else
        --         base.setWaitTime=G_getCurDeviceMillTime()
        --     end
        --     PlayEffect(audioCfg.mouseClick)
        
        --     if self.slotLeftBtn and self.slotShowState~=2 then
        --         if self.slotShowState==0 then
        --             self.slotShowState=2
        --             local moveTo = CCMoveTo:create(0.3,ccp(layerSize.width+self.slotLeftBtn:getContentSize().width/2,self.miniFleetSlotLayer:getContentSize().height-40))
        --             local function setIndexFunc()
        --                 self.slotLeftBtn:setFlipX(true)
        --                 self.slotShowState=1
        --             end
        --             local indexCallBack = CCCallFunc:create(setIndexFunc)
        --             local seq = CCSequence:createWithTwoActions(moveTo,indexCallBack)
        --             self.slotLeftBtn:runAction(seq)
        
        --             local moveTo1 = CCMoveTo:create(0.3,ccp(-(layerSize.width+2),layerPosY))
        --             self.miniFleetSlotLayer:runAction(moveTo1)
        --         elseif self.slotShowState==1 then
        --             self.slotShowState=2
        
        --             local moveTo = CCMoveTo:create(0.3,ccp(slotLeftPosX,self.miniFleetSlotLayer:getContentSize().height-40))
        --             local function setIndexFunc()
        --                 self.slotLeftBtn:setFlipX(false)
        --                 self.slotShowState=0
        --             end
        --             local indexCallBack = CCCallFunc:create(setIndexFunc)
        --             local seq = CCSequence:createWithTwoActions(moveTo,indexCallBack)
        --             self.slotLeftBtn:runAction(seq)
        
        --             local moveTo1 = CCMoveTo:create(0.3,ccp(layerPosX,layerPosY))
        --             self.miniFleetSlotLayer:runAction(moveTo1)
        --         end
        --     end
        -- end
        -- self.slotLeftBtn=LuaCCSprite:createWithSpriteFrameName("fleet_slot_left_btn.png",pushMiniFleetFunc)
        -- self.slotLeftBtn:setPosition(ccp(slotLeftPosX,slotLeftPosY))
        -- self.slotLeftBtn:setTouchPriority(-22)
        -- self.miniFleetSlotLayer:addChild(self.slotLeftBtn,5)
        
        print("初始化行军队列的tableview")
        -- 初始化行军队列的tableview
        self:initFleetSlotTableView()
        -- 重新设置面板size
        -- self:resetFleetSlotLayerSize()
    end
end

-- 初始化行军缩略信息的tableview
function mainUI:initFleetSlotTableView()
    local isMoved = false
    local layerNum = 3
    self.fleetSlotCellTb = {}
    local function tvHandler(handler, fn, idx, cel)
        if fn == "numberOfCellsInTableView" then
            local num = SizeOfTable(attackTankSoltVoApi:getAllAttackTankSlots())
            -- print("miniFleetSlotTv num",num)
            return num
        elseif fn == "tableCellSizeForIndex" then
            local cellWidth = self.miniFleetSlotLayer:getContentSize().width
            local cellHeight = 45
            local tmpSize = CCSizeMake(cellWidth, cellHeight)
            -- print("miniFleetSlotTv size",cellWidth,cellHeight)
            return tmpSize
        elseif fn == "tableCellAtIndex" then
            -- print("miniFleetSlotTv refresh",idx)
            local cell = CCTableViewCell:new()
            cell:autorelease()
            local cellWidth = self.miniFleetSlotLayer:getContentSize().width
            local cellHeight = 45
            local travelIdx = idx
            -- 获取出征table 判断是否还有数据没显示
            self.fleetSlotTab = attackTankSoltVoApi:getAllAttackTankSlots()
            
            -- 开始添加cell
            if self.fleetSlotTab[travelIdx + 1] ~= nil then -- 出征
                local cellTankSlot = self.fleetSlotTab[travelIdx + 1]
                local rect = CCRect(0, 0, 50, 50)
                local capInSet = CCRect(25, 25, 1, 1)
                local whiteBg = LuaCCScale9Sprite:createWithSpriteFrameName("white_line.png", CCRect(13, 1, 1, 1), function ()end)
                local function cellClick()
                    -- print("slotCellClick ",idx)
                    PlayEffect(audioCfg.mouseClick)
                    if G_checkClickEnable() == false then
                        do return end
                    else
                        base.setWaitTime = G_getCurDeviceMillTime()
                    end
                    
                    if whiteBg and self.isShowAction == false then
                        self.isShowAction = true
                        local function touchCallback()
                            worldScene:focusTankSlotSp(cellTankSlot)
                            self.isShowAction = false
                        end
                        -- local fadeIn=CCFadeIn:create(0.2)
                        -- local fadeOut=CCFadeOut:create(0.2)
                        local fadeIn = CCFadeTo:create(0.2, 180)
                        --local delay=CCDelayTime:create(2)
                        local fadeOut = CCFadeTo:create(0.2, 0)
                        local callFunc = CCCallFuncN:create(touchCallback)
                        local acArr = CCArray:create()
                        acArr:addObject(fadeIn)
                        --acArr:addObject(delay)
                        acArr:addObject(fadeOut)
                        acArr:addObject(callFunc)
                        local seq = CCSequence:create(acArr)
                        whiteBg:runAction(seq)
                    end
                end
                -- local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("LegionInputBg.png",capInSet,cellClick)
                local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("fleet_slot_cell_bg.png", capInSet, cellClick)
                backSprie:setContentSize(CCSizeMake(cellWidth - 20, cellHeight - 2))
                backSprie:ignoreAnchorPointForPosition(false)
                backSprie:setAnchorPoint(ccp(0, 0.5))
                -- backSprie:setOpacity(0)
                backSprie:setPosition(ccp(0, cellHeight / 2))
                backSprie:setTag(5001 + idx)
                backSprie:setIsSallow(false)
                backSprie:setTouchPriority(-20)
                cell:addChild(backSprie, 1)
                whiteBg:setContentSize(CCSizeMake(150, 38))
                whiteBg:ignoreAnchorPointForPosition(false)
                whiteBg:setAnchorPoint(ccp(0, 0.5))
                whiteBg:setPosition(ccp(0, cellHeight / 2))
                backSprie:addChild(whiteBg, 11)
                whiteBg:setOpacity(0)
                
                -- 状态图标size
                local iconWidth = 40
                local nameStr = ""
                -- if cellTankSlot.type>0 and cellTankSlot.type<6 then
                --     nameStr = getlocal("world_island_"..cellTankSlot.type).." Lv."..cellTankSlot.level --.."("..cellTankSlot.targetid[1]..","..cellTankSlot.targetid[2]..")"
                -- else
                --     nameStr = cellTankSlot.tName.." Lv."..cellTankSlot.level
                -- end
                
                local nameSize = 15
                local btnSize = 20
                if G_getCurChoseLanguage() == "ru" or G_getCurChoseLanguage() == "fr" or G_getCurChoseLanguage() == "de" or G_getCurChoseLanguage() == "en" then
                    nameSize = 12
                    btnSize = 13
                end
                
                local labName = GetTTFLabel(nameStr, nameSize)
                labName:setAnchorPoint(ccp(0.5, 1))
                labName:setPosition(ccp(90, backSprie:getContentSize().height - 3))
                backSprie:addChild(labName, 3)
                labName:setTag(501)
                local barName = "fleet_slot_bar_green.png"
                local barBgName = "fleet_slot_bar_bg.png"
                -- 采集或者协防状态
                if (cellTankSlot.isGather == 2 or cellTankSlot.isGather == 3) and cellTankSlot.bs == nil then
                    barName = "fleet_slot_bar_yellow.png"
                    barBgName = "fleet_slot_bar_bg.png"
                end
                AddProgramTimer(backSprie, ccp(64 + 10, backSprie:getContentSize().height / 2), 9, 12, "", barBgName, barName, 11, nil, nil, nil, nil, 16)
                local moneyTimerSprite = tolua.cast(backSprie:getChildByTag(9), "CCProgressTimer")
                self.tickFleetTimer[travelIdx + 1] = moneyTimerSprite
                --判断如果不为采集满 并且不为协防已经到达那种 就显示正确的进度条
                if cellTankSlot.isGather ~= 3 and cellTankSlot.isGather ~= 4 and cellTankSlot.isGather ~= 5 then
                    local lefttime, totaletime = attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(cellTankSlot.slotId)
                    local per = (totaletime - lefttime) / totaletime * 100
                    moneyTimerSprite:setPercentage(per)
                end
                local lbPer = tolua.cast(moneyTimerSprite:getChildByTag(12), "CCLabelTTF")
                lbPer:setAnchorPoint(ccp(0.5, 0))
                lbPer:setPosition(ccp(90, 0))
                local iconSp -- 状态图标
                local processItem -- 处理按钮item
                
                local cityFlag
                if cellTankSlot.type == 8 then
                    cityFlag = 1
                end
                --情况1 采集中的时候
                if cellTankSlot.isGather == 2 and cellTankSlot.bs == nil then
                    iconSp = CCSprite:createWithSpriteFrameName(G_getResourceIconByIndex(cellTankSlot.type))
                    iconSp:setTag(101)
                    local nowRes, maxRes = attackTankSoltVoApi:getLeftResAndTotalResBySlotId(cellTankSlot.slotId)
                    local per = nowRes / maxRes * 100
                    moneyTimerSprite:setPercentage(per)
                    if nowRes >= maxRes then
                        nowRes = maxRes
                    end
                    nameStr = getlocal("fleet_slot_state_gather")
                    labName:setString(nameStr)
                    -- lbPer:setString(getlocal("scheduleChapter",{FormatNumber(nowRes),FormatNumber(maxRes)}))
                    local time = GetTimeStrForFleetSlot(attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(cellTankSlot.slotId))
                    lbPer:setString(time)
                    local function backTouch()
                        PlayEffect(audioCfg.mouseClick)
                        if G_checkClickEnable() == false then
                            do return end
                        else
                            base.setWaitTime = G_getCurDeviceMillTime()
                        end
                        if self.miniFleetSlotTv:getIsScrolled() == true then
                            do return end
                        end
                        local nowRes, maxRes = attackTankSoltVoApi:getLeftResAndTotalResBySlotId(cellTankSlot.slotId)
                        if nowRes < maxRes then
                            local function backSure()
                                local function serverBack(fn, data)
                                    if base:checkServerData(data) == true then
                                        self:clearFleetSlotTv()
                                        enemyVoApi:deleteEnemy(cellTankSlot.targetid[1], cellTankSlot.targetid[2])
                                        eventDispatcher:dispatchEvent("worldScene.mineChange", {{x = cellTankSlot.targetid[1], y = cellTankSlot.targetid[2]}})
                                    end
                                end
                                socketHelper:troopBack(cellTankSlot.slotId, serverBack, nil, cityFlag)
                            end
                            smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), backSure, getlocal("dialog_title_prompt"), getlocal("fleetStaying"), nil, layerNum + 1)
                        else
                            local function serverBack(fn, data)
                                if base:checkServerData(data) == true then
                                    self:clearFleetSlotTv()
                                    enemyVoApi:deleteEnemy(cellTankSlot.targetid[1], cellTankSlot.targetid[2])
                                    eventDispatcher:dispatchEvent("worldScene.mineChange", {{x = cellTankSlot.targetid[1], y = cellTankSlot.targetid[2]}})
                                end
                            end
                            socketHelper:troopBack(cellTankSlot.slotId, serverBack, nil, cityFlag)
                        end
                    end
                    processItem = GetButtonItem("IconReturnBtn.png", "IconReturnBtn_Down.png", "IconReturnBtn_Down.png", backTouch)
                    --情况2 采集满的时候
                elseif cellTankSlot.isGather == 3 and cellTankSlot.bs == nil then
                    iconSp = CCSprite:createWithSpriteFrameName(G_getResourceIconByIndex(cellTankSlot.type))
                    iconSp:setTag(101)
                    local nowRes, maxRes = attackTankSoltVoApi:getLeftResAndTotalResBySlotId(cellTankSlot.slotId)
                    local per = 100
                    moneyTimerSprite:setPercentage(per)
                    nameStr = getlocal("fleet_slot_state_gather_end")
                    labName:setString(nameStr)
                    labName:setPosition(ccp(labName:getPositionX(), backSprie:getContentSize().height / 2 + labName:getContentSize().height / 2))
                    -- lbPer:setString(getlocal("scheduleChapter",{FormatNumber(maxRes),FormatNumber(maxRes)}))
                    lbPer:setString("")
                    local function backTouch()
                        PlayEffect(audioCfg.mouseClick)
                        if G_checkClickEnable() == false then
                            do return end
                        else
                            base.setWaitTime = G_getCurDeviceMillTime()
                        end
                        if self.miniFleetSlotTv:getIsScrolled() == true then
                            do return end
                        end
                        local function serverBack(fn, data)
                            if base:checkServerData(data) == true then
                                self:clearFleetSlotTv()
                                enemyVoApi:deleteEnemy(cellTankSlot.targetid[1], cellTankSlot.targetid[2])
                                eventDispatcher:dispatchEvent("worldScene.mineChange", {{x = cellTankSlot.targetid[1], y = cellTankSlot.targetid[2]}})
                            end
                        end
                        socketHelper:troopBack(cellTankSlot.slotId, serverBack, nil, cityFlag)
                    end
                    -- processItem = GetButtonItem("fleet_slot_option_btn.png","fleet_slot_option_btn_down.png","fleet_slot_option_btn_down.png",backTouch,nil,getlocal("coverFleetBack"),btnSize)
                    processItem = GetButtonItem("IconReturnBtn.png", "IconReturnBtn_Down.png", "IconReturnBtn_Down.png", backTouch)
                    --情况3 协防正在进行时
                elseif (cellTankSlot.isHelp ~= nil and cellTankSlot.bs == nil and cellTankSlot.isGather ~= 4 and cellTankSlot.isGather ~= 5) or (cellTankSlot.isDef > 0 and cellTankSlot.bs == nil and cellTankSlot.isGather ~= 5 and cellTankSlot.isGather ~= 6) then
                    iconSp = CCSprite:createWithSpriteFrameName("IconAttack.png")
                    -- local iconAttackSp = CCSprite:createWithSpriteFrameName("IconAttack.png")
                    -- iconAttackSp:setPosition(getCenterPoint(iconSp))
                    -- iconSp:addChild(iconAttackSp,1)
                    iconSp:setTag(104)
                    local function touch1()
                        PlayEffect(audioCfg.mouseClick)
                        if G_checkClickEnable() == false then
                            do return end
                        else
                            base.setWaitTime = G_getCurDeviceMillTime()
                        end
                        if self.miniFleetSlotTv:getIsScrolled() == true then
                            do return end
                        end
                        local function cronBack()
                            local function cronAttackCallBack(fn, data)
                                local retTb = G_Json.decode(tostring(data))
                                if base:checkServerData(data) == true then
                                    local vo = activityVoApi:getActivityVo("speedupdisc")
                                    if vo and activityVoApi:isStart(vo) then
                                        local open = acSpeedUpDiscVoApi:checkIfOpen("troop")
                                        if open and vo.currentCost > 0 and vo.rand > 0 then
                                            local getTip = getlocal("activity_speedupdisc_realDis", {vo.currentCost, vo.rand})
                                            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getTip, 28)
                                            vo:resetDiscountAndCost()
                                        end
                                    end
                                    for k, v in pairs(self.tickFleetTimer) do
                                        v:removeFromParentAndCleanup(true)
                                        v = nil
                                    end
                                    self:clearFleetSlotTv()
                                    if base.heroSwitch == 1 then
                                        --请求英雄数据
                                        local function heroGetlistHandler(fn, data)
                                            local ret, sData = base:checkServerData(data)
                                            if ret == true then
                                                
                                            end
                                        end
                                        socketHelper:heroGetlist(heroGetlistHandler)
                                    end
                                end
                            end
                            local cronidSend = cellTankSlot.slotId;
                            local targetSend = cellTankSlot.targetid;
                            local attackerSend = playerVoApi:getUid()
                            socketHelper:cronAttack(cronidSend, targetSend, attackerSend, 1, cronAttackCallBack);
                        end
                        local leftTime = attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(cellTankSlot.slotId)
                        if leftTime >= 0 then
                            local needGemsNum = TimeToGems(leftTime)
                            local needGems = getlocal("speedUp", {needGemsNum})
                            if needGemsNum > playerVoApi:getGems() then --金币不足
                                GemsNotEnoughDialog(nil, nil, needGemsNum - playerVoApi:getGems(), layerNum + 1, needGemsNum)
                                do return end
                            else
                                local addContent
                                local vo = activityVoApi:getActivityVo("speedupdisc")
                                if vo and activityVoApi:isStart(vo) then
                                    local open = acSpeedUpDiscVoApi:checkIfOpen("troop")
                                    if open and vo.speedup and vo.speedup["troop"] then
                                        local speedCfg = vo.speedup["troop"]
                                        addContent = getlocal("activity_speedupdisc_discount", {math.ceil(speedCfg[1] * needGemsNum), math.ceil(speedCfg[2] * needGemsNum)})
                                    end
                                end
                                if addContent then
                                    smallDialog:showSureAndCancle2("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), cronBack, getlocal("dialog_title_prompt"), needGems, addContent, nil, layerNum + 1)
                                else
                                    smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), cronBack, getlocal("dialog_title_prompt"), needGems, nil, layerNum + 1)
                                end
                            end
                        end
                    end
                    -- nameStr = getlocal("fleet_slot_state_go",{cellTankSlot.targetid[1],cellTankSlot.targetid[2]})
                    nameStr = "("..cellTankSlot.targetid[1] .. ","..cellTankSlot.targetid[2] .. ")"
                    labName:setString(nameStr)
                    local time = GetTimeStrForFleetSlot(attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(cellTankSlot.slotId))
                    lbPer:setString(time)
                    -- processItem = GetButtonItem("fleet_slot_option_btn.png","fleet_slot_option_btn_down.png","fleet_slot_option_btn_down.png",touch1,10,getlocal("accelerateBuild"),btnSize)
                    processItem = GetButtonItem("BtnRight.png", "BtnRight_Down.png", "BtnRight_Down.png", touch1)
                    --情况4 协防已经达到的时候
                elseif (cellTankSlot.isGather == 4 or cellTankSlot.isGather == 5) and cellTankSlot.bs == nil then
                    iconSp = CCSprite:createWithSpriteFrameName("IconDefense.png")
                    -- local iconDefenseSp = CCSprite:createWithSpriteFrameName("IconDefense.png")
                    -- iconDefenseSp:setPosition(getCenterPoint(iconSp))
                    -- iconSp:addChild(iconDefenseSp,1)
                    iconSp:setTag(105)
                    local stateStr, backFlag = nil, true
                    if cellTankSlot.isGather == 4 then
                        stateStr = getlocal("standbying")
                    elseif cellTankSlot.isGather == 5 and cellTankSlot.isDef == 0 and cellTankSlot.isHelp == 1 then --协防玩家城市
                        stateStr = getlocal("defensing")
                    elseif cellTankSlot.isGather == 5 and cellTankSlot.isDef == 0 and cellTankSlot.isHelp == nil and cellTankSlot.type == 8 then --军团城市战斗中
                        stateStr = getlocal("cityattacking")
                        backFlag = attackTankSoltVoApi:isCanBackTroops(cellTankSlot)
                    elseif cellTankSlot.isGather == 5 and cellTankSlot.isDef > 0 then --军团城市驻防中
                        stateStr = getlocal("citydefending")
                    end
                    local per = 100
                    moneyTimerSprite:setPercentage(per)
                    labName:setString(stateStr)
                    -- labName:setPosition(ccp(labName:getPositionX(),backSprie:getContentSize().height-5))
                    nameStr = "("..cellTankSlot.targetid[1] .. ","..cellTankSlot.targetid[2] .. ")"
                    lbPer:setString(nameStr)
                    -- lbPer:setAnchorPoint(ccp(0.5,0.5))
                    -- lbPer:setPosition(ccp(lbPer:getPositionX(),8))
                    local function backTouch()
                        PlayEffect(audioCfg.mouseClick)
                        if G_checkClickEnable() == false then
                            do return end
                        else
                            base.setWaitTime = G_getCurDeviceMillTime()
                        end
                        if self.miniFleetSlotTv:getIsScrolled() == true then
                            do return end
                        end
                        local function serverBack(fn, data)
                            if base:checkServerData(data) == true then
                                self:clearFleetSlotTv()
                                enemyVoApi:deleteEnemy(cellTankSlot.targetid[1], cellTankSlot.targetid[2])
                            end
                        end
                        socketHelper:troopBack(cellTankSlot.slotId, serverBack, nil, cityFlag)
                    end
                    -- processItem = GetButtonItem("fleet_slot_option_btn.png","fleet_slot_option_btn_down.png","fleet_slot_option_btn_down.png",backTouch,nil,getlocal("coverFleetBack"),btnSize)
                    processItem = GetButtonItem("IconReturnBtn.png", "IconReturnBtn_Down.png", "IconReturnBtn_Down.png", backTouch)
                    processItem:setEnabled(backFlag)
                    processItem:setVisible(backFlag)
                    --情况5 返航的时候
                elseif cellTankSlot.bs ~= nil then
                    local function touch1()
                        PlayEffect(audioCfg.mouseClick)
                        if G_checkClickEnable() == false then
                            do return end
                        else
                            base.setWaitTime = G_getCurDeviceMillTime()
                        end
                        if self.miniFleetSlotTv:getIsScrolled() == true then
                            do return end
                        end
                        local function speedBack()
                            local function troopBackSpeedupCallBack(fn, data)
                                local retTb = G_Json.decode(tostring(data))
                                if base:checkServerData(data) == true then
                                    local vo = activityVoApi:getActivityVo("speedupdisc")
                                    if vo and activityVoApi:isStart(vo) then
                                        local open = acSpeedUpDiscVoApi:checkIfOpen("troop")
                                        if open and vo.currentCost > 0 and vo.rand > 0 then
                                            local getTip = getlocal("activity_speedupdisc_realDis", {vo.currentCost, vo.rand})
                                            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getTip, 28)
                                            vo:resetDiscountAndCost()
                                        end
                                    end
                                    for k, v in pairs(self.tickFleetTimer) do
                                        if(v and tolua.cast(v, "CCNode"))then
                                            v:removeFromParentAndCleanup(true)
                                            self.tickFleetTimer[k] = nil
                                        end
                                    end
                                    self:clearFleetSlotTv()
                                    self:resetFleetSlotLayerSize()
                                end
                            end
                            if cellTankSlot ~= nil then
                                local cidSend = cellTankSlot.slotId
                                socketHelper:troopBackSpeedup(cidSend, troopBackSpeedupCallBack)
                            end
                        end
                        local leftTime = attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(cellTankSlot.slotId)
                        if leftTime >= 0 then
                            local needGemsNum = TimeToGems(leftTime)
                            local needGems = getlocal("speedUp", {needGemsNum})
                            if needGemsNum > playerVoApi:getGems() then --金币不足
                                GemsNotEnoughDialog(nil, nil, needGemsNum - playerVoApi:getGems(), layerNum + 1, needGemsNum)
                                do return end
                            else
                                local addContent
                                local vo = activityVoApi:getActivityVo("speedupdisc")
                                if vo and activityVoApi:isStart(vo) then
                                    local open = acSpeedUpDiscVoApi:checkIfOpen("troop")
                                    if open and vo.speedup and vo.speedup["troop"] then
                                        local speedCfg = vo.speedup["troop"]
                                        addContent = getlocal("activity_speedupdisc_discount", {math.ceil(speedCfg[1] * needGemsNum), math.ceil(speedCfg[2] * needGemsNum)})
                                    end
                                end
                                if addContent then
                                    smallDialog:showSureAndCancle2("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), speedBack, getlocal("dialog_title_prompt"), needGems, addContent, nil, layerNum + 1)
                                else
                                    smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), speedBack, getlocal("dialog_title_prompt"), needGems, nil, layerNum + 1)
                                end
                            end
                        end
                    end
                    iconSp = CCSprite:createWithSpriteFrameName("IconReturn-.png")
                    -- local iconReturnSp = CCSprite:createWithSpriteFrameName("IconReturn-.png")
                    -- iconReturnSp:setPosition(getCenterPoint(iconSp))
                    -- iconSp:addChild(iconReturnSp,1)
                    iconSp:setTag(102)
                    nameStr = getlocal("coverFleetBack")
                    labName:setString(nameStr)
                    local time = GetTimeStrForFleetSlot(attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(cellTankSlot.slotId))
                    lbPer:setString(time)
                    -- processItem = GetButtonItem("fleet_slot_option_btn.png","fleet_slot_option_btn_down.png","fleet_slot_option_btn_down.png",touch1,10,getlocal("accelerateBuild"),btnSize)
                    processItem = GetButtonItem("BtnRight.png", "BtnRight_Down.png", "BtnRight_Down.png", touch1)
                    --情况6 部队前行中
                else
                    local function touch1()
                        PlayEffect(audioCfg.mouseClick)
                        if G_checkClickEnable() == false then
                            do return end
                        else
                            base.setWaitTime = G_getCurDeviceMillTime()
                        end
                        if self.miniFleetSlotTv:getIsScrolled() == true then
                            do return end
                        end
                        local function cronBack()
                            local function cronAttackCallBack(fn, data)
                                local retTb = G_Json.decode(tostring(data))
                                if base:checkServerData(data) == true then
                                    local vo = activityVoApi:getActivityVo("speedupdisc")
                                    if vo and activityVoApi:isStart(vo) then
                                        local open = acSpeedUpDiscVoApi:checkIfOpen("troop")
                                        if open and vo.currentCost > 0 and vo.rand > 0 then
                                            local getTip = getlocal("activity_speedupdisc_realDis", {vo.currentCost, vo.rand})
                                            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getTip, 28)
                                            vo:resetDiscountAndCost()
                                        end
                                    end
                                    for k, v in pairs(self.tickFleetTimer) do
                                        v:removeFromParentAndCleanup(true)
                                        v = nil
                                    end
                                    if(cellTankSlot.targetid[1] and cellTankSlot.targetid[2])then
                                        eventDispatcher:dispatchEvent("worldScene.mineChange", {{x = cellTankSlot.targetid[1], y = cellTankSlot.targetid[2]}})
                                    end
                                    self:clearFleetSlotTv()
                                    self:resetFleetSlotLayerSize()
                                    if base.heroSwitch == 1 then
                                        --请求英雄数据
                                        local function heroGetlistHandler(fn, data)
                                            local ret, sData = base:checkServerData(data)
                                            if ret == true then
                                                
                                            end
                                        end
                                        socketHelper:heroGetlist(heroGetlistHandler)
                                    end
                                end
                            end
                            local cronidSend = cellTankSlot.slotId
                            local targetSend = cellTankSlot.targetid
                            local attackerSend = playerVoApi:getUid()
                            socketHelper:cronAttack(cronidSend, targetSend, attackerSend, 1, cronAttackCallBack)
                        end
                        local leftTime = attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(cellTankSlot.slotId)
                        if leftTime >= 0 then
                            local needGemsNum = TimeToGems(leftTime)
                            local needGems = getlocal("speedUp", {needGemsNum})
                            if needGemsNum > playerVoApi:getGems() then --金币不足
                                print("金币不足，请充值面板")
                                GemsNotEnoughDialog(nil, nil, needGemsNum - playerVoApi:getGems(), layerNum + 1, needGemsNum)
                                do return end
                            else
                                print("确定是否加速面板")
                                local addContent
                                local vo = activityVoApi:getActivityVo("speedupdisc")
                                if vo and activityVoApi:isStart(vo) then
                                    local open = acSpeedUpDiscVoApi:checkIfOpen("troop")
                                    if open and vo.speedup and vo.speedup["troop"] then
                                        local speedCfg = vo.speedup["troop"]
                                        addContent = getlocal("activity_speedupdisc_discount", {math.ceil(speedCfg[1] * needGemsNum), math.ceil(speedCfg[2] * needGemsNum)})
                                    end
                                end
                                if addContent then
                                    smallDialog:showSureAndCancle2("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), cronBack, getlocal("dialog_title_prompt"), needGems, addContent, nil, layerNum + 1)
                                else
                                    smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), cronBack, getlocal("dialog_title_prompt"), needGems, nil, layerNum + 1)
                                end
                            end
                        end
                    end
                    iconSp = CCSprite:createWithSpriteFrameName("IconAttack.png")
                    -- local iconAttackSp = CCSprite:createWithSpriteFrameName("IconAttack.png")
                    -- iconAttackSp:setPosition(getCenterPoint(iconSp))
                    -- iconSp:addChild(iconAttackSp,1)
                    iconSp:setTag(103)
                    -- nameStr = getlocal("fleet_slot_state_go",{,cellTankSlot.targetid[2]})
                    nameStr = "("..cellTankSlot.targetid[1] .. ","..cellTankSlot.targetid[2] .. ")"
                    labName:setString(nameStr)
                    local time = GetTimeStrForFleetSlot(attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(cellTankSlot.slotId))
                    lbPer:setString(time)
                    -- processItem = GetButtonItem("fleet_slot_option_btn.png","fleet_slot_option_btn_down.png","fleet_slot_option_btn_down.png",touch1,10,getlocal("accelerateBuild"),btnSize)
                    processItem = GetButtonItem("BtnRight.png", "BtnRight_Down.png", "BtnRight_Down.png", touch1)
                end
                local iconScale = iconWidth / iconSp:getContentSize().width
                iconSp:setScale(iconScale)
                iconSp:setAnchorPoint(ccp(0, 0.5))
                iconSp:setPosition(ccp(0, backSprie:getContentSize().height / 2 - 1))
                backSprie:addChild(iconSp, 3)
                self.tickFleetIcon[travelIdx + 1] = iconSp
                
                local scale = 0.5
                processItem:setScale(scale)
                local processMenu = CCMenu:createWithItem(processItem)
                processMenu:setPosition(ccp(backSprie:getContentSize().width - processItem:getContentSize().width * scale / 2 - 5, backSprie:getContentSize().height / 2))
                processMenu:setTouchPriority(-21)
                backSprie:addChild(processMenu, 3)
            end
            self.fleetSlotCellTb[travelIdx + 1] = cell
            return cell
        elseif fn == "ccTouchBegan" then
            isMoved = false
            return true
        elseif fn == "ccTouchMoved" then
            isMoved = true
        elseif fn == "ccTouchEnded" then
        end
    end
    local tvWidth = self.miniFleetSlotLayer:getContentSize().width
    local tvHeight = self.miniFleetSlotLayer:getContentSize().height - 30
    local hd = LuaEventHandler:createHandler(tvHandler)
    self.miniFleetSlotTv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(tvWidth, tvHeight), nil)
    self.miniFleetSlotTv:setTableViewTouchPriority(-22)
    self.miniFleetSlotTv:setAnchorPoint(ccp(0, 0))
    self.miniFleetSlotTv:setPosition(ccp(5, 8 + 5))
    self.miniFleetSlotLayer:addChild(self.miniFleetSlotTv)
    self.miniFleetSlotTv:setMaxDisToBottomOrTop(0)
    
end

-- 根据tableview的行数调整背景size
function mainUI:resetFleetSlotLayerSize()
    if self.miniFleetSlotTv ~= nil then
        -- 获取出征table 判断是否还有数据没显示
        self.fleetSlotTab = attackTankSoltVoApi:getAllAttackTankSlots()
        if self.fleetSlotTab == nil or (#self.fleetSlotTab <= 0) then
            do return end
        end
        -- 行数据的高度是41个像素
        local layerHeight = 46 * (#self.fleetSlotTab) + 30
        -- 刷新tv的position
        local posX = self.miniFleetSlotTv:getPositionX()
        local posY = 13
        -- 46是1行数据的最小高度，30是间距
        if layerHeight <= (46 + 30) then
            layerHeight = 46 + 30
            -- posY = 10
        end
        
        local layerSize = CCSizeMake(self.miniFleetSlotLayer:getContentSize().width, layerHeight)
        print("resetSize", layerSize.width, layerSize.height)
        -- 修改面板size
        self.miniFleetSlotLayer:setContentSize(layerSize)
        -- 修改tableview的size
        self.miniFleetSlotTv:setViewSize(CCSizeMake(layerSize.width, layerSize.height - 30))
        self.miniFleetSlotTv:setPosition(ccp(5, posY))
        self.miniFleetSlotTv:recoverToRecordPoint(ccp(0, 0))
        -- 修改title的位置
        -- local titleSp = tolua.cast(self.miniFleetSlotLayer:getChildByTag(1101),"CCSprite")
        -- posX = titleSp:getPositionX()
        -- posY = self.miniFleetSlotLayer:getContentSize().height-7
        -- if titleSp~=nil then
        --     titleSp:setPosition(ccp(posX,posY))
        -- end
        -- 修改缩回按钮的位置
        local leftMenu = tolua.cast(self.miniFleetSlotLayer:getChildByTag(1102), "CCMenu")
        if leftMenu ~= nil then
            local toggleItem = tolua.cast(leftMenu:getChildByTag(1), "CCMenuItemToggle")
            posX = leftMenu:getPositionX()
            posY = self.miniFleetSlotLayer:getContentSize().height - toggleItem:getContentSize().height / 2
            leftMenu:setPosition(ccp(posX, posY))
        end
        -- -- 修改缩回按钮的位置
        -- if self.slotLeftBtn and self.miniFleetSlotLayer then
        --     self.slotLeftBtn:setPosition(ccp(self.slotLeftBtn:getPositionX(),self.miniFleetSlotLayer:getContentSize().height-40))
        -- end
    end
end

-- 重新加载行军队列的tableview
function mainUI:clearFleetSlotTv()
    if self.miniFleetSlotTv then
        self.tickFleetIcon = {}
        self.tickFleetTimer = {}
        self.fleetSlotTab = {}
        self.fleetSlotTab = attackTankSoltVoApi:getAllAttackTankSlots()
        self.miniFleetSlotTv:reloadData()
    end
end

-- 每秒刷新行军队列每一行的状态
function mainUI:refreshFleetSlotTimer()
    for k, v in pairs(self.tickFleetTimer) do
        -- 采集中
        if self.fleetSlotTab[k].isGather == 2 and self.fleetSlotTab[k].bs == nil then
            if self.tickFleetIcon[k]:getTag() ~= 101 then
                self:clearFleetSlotTv()
            end
            local nowRes, maxRes = attackTankSoltVoApi:getLeftResAndTotalResBySlotId(self.fleetSlotTab[k].slotId)
            local per = nowRes / maxRes
            v:setPercentage(per * 100)
            local totleRes = maxRes
            local lbPer = tolua.cast(v:getChildByTag(12), "CCLabelTTF")
            if nowRes >= totleRes then
                nowRes = totleRes
            end
            local time = GetTimeStrForFleetSlot(attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(self.fleetSlotTab[k].slotId))
            lbPer:setString(time)
            -- 采集满
        elseif self.fleetSlotTab[k].isGather == 3 and self.fleetSlotTab[k].bs == nil then
            if self.tickFleetIcon[k]:getTag() ~= 101 then
                self:clearFleetSlotTv()
            end
            local nowRes, maxRes = attackTankSoltVoApi:getLeftResAndTotalResBySlotId(self.fleetSlotTab[k].slotId)
            v:setPercentage(100)
            -- local totleRes=maxRes
            -- local lbPer = tolua.cast(v:getChildByTag(12),"CCLabelTTF")
            -- 协防进行时
        elseif (self.fleetSlotTab[k].isHelp ~= nil and self.fleetSlotTab[k].bs == nil and self.fleetSlotTab[k].isGather ~= 4 and self.fleetSlotTab[k].isGather ~= 5) or (self.fleetSlotTab[k].isDef > 0 and self.fleetSlotTab[k].bs == nil and self.fleetSlotTab[k].isGather ~= 5 and self.fleetSlotTab[k].isGather ~= 6) then
            if self.tickFleetIcon[k]:getTag() ~= 104 then
                self:clearFleetSlotTv()
            end
            local lefttime, totletime = attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(self.fleetSlotTab[k].slotId)
            local per = (totletime - lefttime) / totletime * 100
            v:setPercentage(per)
            local lbPer = tolua.cast(v:getChildByTag(12), "CCLabelTTF")
            local time = GetTimeStrForFleetSlot(attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(self.fleetSlotTab[k].slotId))
            lbPer:setString(time)
            -- 协防到达
        elseif (self.fleetSlotTab[k].isGather == 4 or self.fleetSlotTab[k].isGather == 5) and self.fleetSlotTab[k].bs == nil then
            if self.tickFleetIcon[k]:getTag() ~= 105 then
                self:clearFleetSlotTv()
            end
            v:setPercentage(100)
            local lbPer = tolua.cast(v:getChildByTag(12), "CCLabelTTF")
            local stateStr = nil
            if self.fleetSlotTab[k].isGather == 4 then
                stateStr = getlocal("standbying")
            elseif self.fleetSlotTab[k].isGather == 5 and self.fleetSlotTab[k].isDef == 0 and self.fleetSlotTab[k].isHelp == 1 then
                stateStr = getlocal("defensing")
            elseif self.fleetSlotTab[k].isGather == 5 and self.fleetSlotTab[k].isDef == 0 and self.fleetSlotTab[k].isHelp == nil and self.fleetSlotTab[k].type == 8 then
                stateStr = getlocal("cityattacking")
            elseif self.fleetSlotTab[k].isGather == 5 and self.fleetSlotTab[k].isDef > 0 then
                stateStr = getlocal("citydefending")
            end
            if self.fleetSlotCellTb and self.fleetSlotCellTb[k] then
                local backSprie = self.fleetSlotCellTb[k]:getChildByTag(5001)
                if backSprie then
                    backSprie = tolua.cast(backSprie, "LuaCCScale9Sprite")
                    local nameLb = backSprie:getChildByTag(501)
                    if nameLb then
                        nameLb = tolua.cast(nameLb, "CCLabelTTF")
                        nameLb:setString(stateStr)
                    end
                end
            end
            -- if lbPer~=nil then
            --     lbPer:setString(stateStr)
            -- end
            -- 返航
        elseif self.fleetSlotTab[k].bs ~= nil then
            if self.tickFleetIcon[k]:getTag() ~= 102 then
                self:clearFleetSlotTv()
            end
            local lefttime, totletime = attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(self.fleetSlotTab[k].slotId)
            local per = (totletime - lefttime) / totletime * 100
            v:setPercentage(per)
            local lbPer = tolua.cast(v:getChildByTag(12), "CCLabelTTF")
            local time = GetTimeStrForFleetSlot(attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(self.fleetSlotTab[k].slotId))
            lbPer:setString(time)
            if lefttime <= 0 then
                self:clearFleetSlotTv()
            end
            -- 前进
        else
            if self.tickFleetIcon[k]:getTag() ~= 103 then
                self:clearFleetSlotTv()
            end
            local lefttime, totletime = attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(self.fleetSlotTab[k].slotId)
            local per = (totletime - lefttime) / totletime * 100
            v:setPercentage(per)
            local lbPer = tolua.cast(v:getChildByTag(12), "CCLabelTTF")
            local time = GetTimeStrForFleetSlot(attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(self.fleetSlotTab[k].slotId))
            lbPer:setString(time)
            if lefttime <= 0 then
                if self.fleetSlotTab[k].signState == 1 then
                    self:clearFleetSlotTv()
                end
            end
        end
        
    end
end

-- 检查是否显示行军队列缩略信息
function mainUI:checkFleetSlotChange()
    if self.showMiniFleetSlotFlag == true then
        self.fleetSlotTab = attackTankSoltVoApi:getAllAttackTankSlots()
        -- 如果没有行军队列，则移除掉tableview和面板
        if self.fleetSlotTab == nil or SizeOfTable(self.fleetSlotTab) <= 0 then
            if self.miniFleetSlotTv ~= nil then
                self.miniFleetSlotTv:removeFromParentAndCleanup(true)
                self.miniFleetSlotTv = nil
            end
            if self.miniFleetSlotLayer ~= nil then
                self.miniFleetSlotLayer:removeFromParentAndCleanup(true)
                self.miniFleetSlotLayer = nil
            end
            do return end
        end
        self:initMiniFleetSlotLayer()
        local fleetSlotCount = SizeOfTable(self.fleetSlotTab)
        if fleetSlotCount ~= SizeOfTable(self.tickFleetTimer) then
            self:clearFleetSlotTv()
            -- 重新设置面板和tableview的位置，后面必须跟reloadData()方法
            self:resetFleetSlotLayerSize()
            self.miniFleetSlotTv:reloadData()
            do return end
        else
            self:refreshFleetSlotTimer()
        end
    end
end

-- 显示左上角的行军路线缩略信息
function mainUI:showFleetSlotMiniPanel()
    self:initMiniFleetSlotLayer()
    self.showMiniFleetSlotFlag = true
    if self.miniFleetSlotLayer ~= nil then
        self.miniFleetSlotLayer:setVisible(true)
    end
end

-- 隐藏左上角的行军路线缩略信息
function mainUI:hideFleetSlotMiniPanel()
    self.showMiniFleetSlotFlag = false
    if self.miniFleetSlotLayer ~= nil then
        self.miniFleetSlotLayer:setVisible(false)
    end
end

function mainUI:resetLeftFlicker(isVisible)
    if self.m_leftIconTab then
        for i = 2, 10 do
            if self.m_leftIconTab["flicker"..i] ~= nil then
                self.m_leftIconTab["flicker"..i]:setVisible(isVisible)
            end
        end
    end
end

function mainUI:showTravelIcon(travelTimeTab)
    if travelTimeTab ~= nil and SizeOfTable(travelTimeTab) > 0 then
        self.m_travelSp:setVisible(true)
        local travelData = travelTimeTab[1]
        local time = travelData.time
        local type = travelData.type
        local place = travelData.place
        local isGather = travelData.isGather
        local percentRes = travelData.percentRes
        if self.m_travelType ~= type then
            
            if self.m_travelSp ~= nil then
                --self.myUILayer:removeChild(self.m_travelSp,true)
                --self.m_travelSp=nil
                self.m_travelTimeLabel = nil
                
            end
            self.m_travelType = type
        end
        if time >= 0 then
            if time == 0 then
                if type ~= 3 then
                    if type == 2 then
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("promptFleetBackHome"), 30)
                        --elseif type==1 and isGather==false then
                        --smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("promptFleetBack",{place.x,place.y}),30)
                    end
                    
                    if self.m_travelSp ~= nil then
                        --self.myUILayer:removeChild(self.m_travelSp,true)
                        --self.m_travelSp=nil
                        self.m_travelTimeLabel = nil
                        
                    end
                    
                    if type == 1 then
                        --更新邮件
                        --G_updateEmailList(2)
                    end
                end
            end
            if self.m_travelTimeLabel ~= nil then
                if type == 3 and percentRes ~= nil then
                    if percentRes == 100 and self.m_travelTimeLabel:getString() ~= 100 then
                        self.m_travelTimeLabel:setString("100%")
                    else
                        self.m_travelTimeLabel:setString(percentRes.."%")
                    end
                elseif type ~= 5 then
                    self.m_travelTimeLabel = tolua.cast(self.m_travelTimeLabel, "CCLabelTTF")
                    self.m_travelTimeLabel:setString(GetTimeStr(time))
                end
            elseif type == 5 then
                if self.m_travelSp:getChildByTag(3) ~= nil then
                    
                    self.m_travelSp:getChildByTag(3):removeFromParentAndCleanup(true)
                    self.m_travelTimeLabel = nil
                end
                if self.m_travelSp:getChildByTag(2) ~= nil then
                    
                    self.m_travelSp:getChildByTag(2):removeFromParentAndCleanup(true)
                end
                if self.m_travelSp:getChildByTag(2) == nil then
                    local iconSp = CCSprite:createWithSpriteFrameName("IconDefense.png")
                    iconSp:setPosition(getCenterPoint(self.m_travelSp))
                    self.m_travelSp:addChild(iconSp)
                    iconSp:setTag(2);
                end
                
            else
                local function travelHandler(object, name, tag)
                    if G_checkClickEnable() == false then
                        do
                            return
                        end
                    end
                    require "luascript/script/game/scene/gamedialog/warDialog/tankDefenseDialog"
                    local dlayerNum = 3
                    local td = tankDefenseDialog:new(dlayerNum)
                    local tbArr = {getlocal("fleetCard"), getlocal("dispatchCard"), getlocal("repair")}
                    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("defenceSetting"), true, dlayerNum)
                    td:tabClick(1)
                    sceneGame:addChild(dialog, dlayerNum)
                end
                local travelIcon
                local travelIconNameStr = nil
                if type == 1 then
                    travelIconNameStr = "IconAttack.png"
                elseif type == 2 then
                    travelIconNameStr = "IconReturn-.png"
                elseif type == 3 then
                    travelIconNameStr = "IconOccupy.png"
                elseif type == 4 then
                    travelIconNameStr = "IconAttack.png"
                elseif type == 5 then
                    travelIconNameStr = "IconDefense.png"
                end
                
                if self.m_travelSp:getChildByTag(2) ~= nil then
                    
                    self.m_travelSp:getChildByTag(2):removeFromParentAndCleanup(true)
                end
                if self.m_travelSp:getChildByTag(2) == nil then
                    local iconSp = CCSprite:createWithSpriteFrameName(travelIconNameStr)
                    iconSp:setPosition(getCenterPoint(self.m_travelSp))
                    self.m_travelSp:addChild(iconSp)
                    iconSp:setTag(2);
                end
                
                self.m_travelSp:setAnchorPoint(ccp(0.5, 0.5))
                self.m_travelSp:setTouchPriority(-22)
                --self.m_travelSp:setScaleX(self.m_iconScaleX)
                --self.m_travelSp:setScaleY(self.m_iconScaleY)
                if type == 3 and percentRes ~= nil then
                    self.m_travelTimeLabel = GetTTFLabel(percentRes.."%", 20)
                elseif type ~= 5 then
                    self.m_travelTimeLabel = GetTTFLabel(GetTimeStr(time), 20);
                else
                    self.m_travelTimeLabel = nil
                end
                --self.m_travelTimeLabel:setAnchorPoint(ccp(0.5,0))
                --self.m_travelTimeLabel:setPosition(self.m_travelSp:getContentSize().width/2,0)
                
                if self.m_travelTimeLabel ~= nil then
                    local capInSet = CCRect(5, 5, 1, 1);
                    local function touchClick()
                    end
                    local lbSpBg = LuaCCScale9Sprite:createWithSpriteFrameName("IconBgNum.png", capInSet, touchClick)
                    lbSpBg:setContentSize(CCSizeMake(75, 20))
                    lbSpBg:ignoreAnchorPointForPosition(false)
                    lbSpBg:setAnchorPoint(CCPointMake(0.5, 0))
                    lbSpBg:setPosition(ccp(self.m_travelSp:getContentSize().width / 2, 0))
                    lbSpBg:setTag(3)
                    lbSpBg:addChild(self.m_travelTimeLabel, 4)
                    self.m_travelTimeLabel:setPosition(getCenterPoint(lbSpBg))
                    self.m_travelSp:addChild(lbSpBg, 1)
                end
                
                --self.m_travelSp:addChild(self.m_travelTimeLabel,1)
                local height = self.m_pointVip.y - 115 - 78 * 2
                
                -- 让右侧展开
                self.m_menuToggleSmall:setSelectedIndex(1)
                if sceneController and sceneController.curIndex ~= 2 then
                    for k, v in pairs(self.m_luaSpTab) do
                        
                        v:stopAllActions();
                        self:moveDown(v, ccp(self.m_pointLuaSp.x, self.m_pointLuaSp.y - k * self.m_skillHeigh - k * self.m_dis), self.m_luaTime + 0.02 * k);
                        local tagV = v:getTag();
                    end
                end
            end
        else
            self.m_travelSp:setVisible(false)
            self.m_travelTimeLabel = nil
            --[[
      if self.m_travelSp~=nil then
        self.myUILayer:removeChild(self.m_travelSp,true)
        self.m_travelSp=nil
        self.m_travelTimeLabel=nil
      end]]
        end
    else
        self.m_travelSp:setVisible(false)
        self.m_travelTimeLabel = nil
        --[[
    if self.m_travelSp~=nil then
      self.myUILayer:removeChild(self.m_travelSp,true)
      self.m_travelSp=nil
      self.m_travelTimeLabel=nil
    end]]
    end
end

function mainUI:showAllList()
    -- 让右侧展开
    self.m_menuToggleSmall:setSelectedIndex(1)
    if sceneController and sceneController.curIndex ~= 2 then
        for k, v in pairs(self.m_luaSpTab) do
            
            v:stopAllActions();
            self:moveDown(v, ccp(self.m_pointLuaSp.x, self.m_pointLuaSp.y - k * self.m_skillHeigh - k * self.m_dis), self.m_luaTime + 0.02 * k);
            local tagV = v:getTag();
        end
    end
end

function mainUI:refreshStateIcon()
    
    local function touchLuaSp()
        require "luascript/script/game/scene/gamedialog/buffStateDialog"
        local vrd = buffStateDialog:new()
        local vd = vrd:init(4)
        -- sceneGame:addChild(vd,4)
    end
    
    self.m_luaSpBuffSp1 = LuaCCSprite:createWithSpriteFrameName("IconProtectUi.png", touchLuaSp);
    self.m_luaSpBuffSp1:setAnchorPoint(ccp(0, 0))
    self.m_luaSpBuffSp1:setPosition(self.m_luaSpBuff:getContentSize().width, self.m_luaSpBuff:getContentSize().height - self.m_luaSpBuffSp1:getContentSize().height);
    self.m_luaSpBuff:addChild(self.m_luaSpBuffSp1, 1);
    self.m_luaSpBuffSp1:setTouchPriority(-21);
    
    self.m_luaSpBuffSp2 = LuaCCSprite:createWithSpriteFrameName("IconAttackUi.png", touchLuaSp);
    self.m_luaSpBuffSp2:setAnchorPoint(ccp(0, 0))
    self.m_luaSpBuffSp2:setPosition(self.m_luaSpBuff:getContentSize().width, self.m_luaSpBuff:getContentSize().height - self.m_luaSpBuffSp1:getContentSize().height * 2);
    self.m_luaSpBuff:addChild(self.m_luaSpBuffSp2, 1);
    self.m_luaSpBuffSp2:setTouchPriority(-21);
    
    self.m_luaSpBuffSp3 = LuaCCSprite:createWithSpriteFrameName("IconResourceUi.png", touchLuaSp);
    self.m_luaSpBuffSp3:setAnchorPoint(ccp(0, 0))
    self.m_luaSpBuffSp3:setPosition(self.m_luaSpBuff:getContentSize().width, self.m_luaSpBuff:getContentSize().height - self.m_luaSpBuffSp1:getContentSize().height * 3);
    self.m_luaSpBuff:addChild(self.m_luaSpBuffSp3, 1);
    self.m_luaSpBuffSp3:setTouchPriority(-21);
    self.m_luaSpBuffSp1:setVisible(false)
    self.m_luaSpBuffSp2:setVisible(false)
    self.m_luaSpBuffSp3:setVisible(false)
    
end
function mainUI:refreshBuffState()
    local point1 = ccp(self.m_luaSpBuff:getContentSize().width, self.m_luaSpBuff:getContentSize().height - self.m_luaSpBuffSp1:getContentSize().height)
    local point2 = ccp(self.m_luaSpBuff:getContentSize().width, self.m_luaSpBuff:getContentSize().height - self.m_luaSpBuffSp1:getContentSize().height * 2)
    local point3 = ccp(self.m_luaSpBuff:getContentSize().width, self.m_luaSpBuff:getContentSize().height - self.m_luaSpBuffSp1:getContentSize().height * 3)
    if useItemSlotVoApi:getSlotById(14) == nil then
        self.m_luaSpBuffSp1:setVisible(false)
    else
        self.m_luaSpBuffSp1:setVisible(true)
    end
    if useItemSlotVoApi:isShowState3() == false then
        self.m_luaSpBuffSp2:setVisible(false)
    else
        self.m_luaSpBuffSp2:setVisible(true)
    end
    if useItemSlotVoApi:getNumByState1() == 0 then
        self.m_luaSpBuffSp3:setVisible(false)
    else
        self.m_luaSpBuffSp3:setVisible(true)
    end
    
    if self.m_luaSpBuffSp1:isVisible() == true then
        self.m_luaSpBuffSp1:setPosition(point1)
        if self.m_luaSpBuffSp2:isVisible() == true then
            self.m_luaSpBuffSp2:setPosition(point2)
            self.m_luaSpBuffSp3:setPosition(point3)
        else
            self.m_luaSpBuffSp3:setPosition(point2)
        end
    else
        if self.m_luaSpBuffSp2:isVisible() == true then
            self.m_luaSpBuffSp2:setPosition(point1)
            self.m_luaSpBuffSp3:setPosition(point2)
        else
            self.m_luaSpBuffSp3:setPosition(point1)
        end
    end
    
end

function mainUI:setLastChat(forceRefresh)
    if chatVoApi:getHasNewData(0) == true or forceRefresh then
        local chatVo = chatVoApi:getLast(1)
        if chatVo and chatVo.subType then
            local typeStr, color, icon = chatVoApi:getTypeStr(chatVo.subType)
            --最后聊天不用修改
            local isGM = GM_UidCfg[chatVo.sender] and true or false
            if isGM then
                GM_Name[tonumber(chatVo.sender)] = chatVo.senderName
            end
            local sizeSp = 45
            if icon and self.m_chatBg then
                if self.m_labelLastType then
                    self.m_labelLastType:removeFromParentAndCleanup(true)
                    self.m_labelLastType = nil
                end
                self.m_labelLastType = CCSprite:createWithSpriteFrameName(icon)
                local typeScale = sizeSp / self.m_labelLastType:getContentSize().width
                self.m_labelLastType:setAnchorPoint(ccp(0.5, 0.5))
                if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                    self.m_labelLastType:setPosition(ccp(5 + sizeSp / 2, self.m_chatBg:getContentSize().height / 2))
                else
                    self.m_labelLastType:setPosition(ccp(sizeSp / 2-1, self.m_chatBg:getContentSize().height / 2+4))
                end
                self.m_chatBg:addChild(self.m_labelLastType, 2)
                self.m_labelLastType:setScale(typeScale)
            end
            -- if self.m_labelLastType then
            -- self.m_labelLastType:setString(typeStr)
            -- self.m_labelLastType:setColor(color)
            -- else
            --     self.m_labelLastType=GetTTFLabel(typeStr,30)
            --     self.m_labelLastType:setAnchorPoint(ccp(0,0.5))
            --     self.m_labelLastType:setPosition(ccp(5,self.m_chatBg:getContentSize().height/2))
            --     self.m_chatBg:addChild(self.m_labelLastType,2)
            -- self.m_labelLastType:setColor(color)
            -- end
            
            local nameStr = chatVoApi:getNameStr(chatVo.type, chatVo.subType, chatVo.senderName, chatVo.reciverName, chatVo.sender)
            local chatfontsize
            if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                chatfontsize = 26
            else
                chatfontsize = 22
            end
            --nameStr=nameStr..":"
            if nameStr ~= nil and nameStr ~= "" and chatVo.type <= 3 and chatVo.contentType ~= 3 then
                nameStr = nameStr..":"
                if self.m_labelLastName then
                    self.m_labelLastName:setString(nameStr)
                    if color then
                        self.m_labelLastName:setColor(color)
                    end
                else
                    self.m_labelLastName = GetTTFLabel(nameStr, chatfontsize)
                    self.m_labelLastName:setAnchorPoint(ccp(0, 0.5))
                    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                        self.m_labelLastName:setPosition(ccp(10 + sizeSp, self.m_chatBg:getContentSize().height / 2))
                    else
                        self.m_labelLastName:setPosition(ccp(40 + sizeSp, self.m_chatBg:getContentSize().height / 2))
                    end
                    self.m_chatBg:addChild(self.m_labelLastName, 2)
                    if color then
                        self.m_labelLastName:setColor(color)
                    end
                end
                if isGM then
                    self.m_labelLastName:setColor(GM_Color)
                end
            end
            
            local message = chatVo.content
            if(base.ifChatTransOpen == 1 and chatVo.showTranslate == true and chatVo.translateContent and chatVo.translateContent[G_getCurChoseLanguage()])then
                message = chatVo.translateContent[G_getCurChoseLanguage()]
            end
            if chatVo.params and chatVo.params.emojiId then --动态表情
                message = getlocal("chatEmoji_msgReceiveTips")
            end
            if message == nil then
                message = ""
            end
            local msgFont = nil
            --处理ios表情在安卓不显示问题
            if G_isIOS() == false then
                if platCfg.platCfgSameServerWithIos[G_curPlatName()] then
                    local tmpTb = {}
                    tmpTb["action"] = "EmojiConv"
                    tmpTb["parms"] = {}
                    tmpTb["parms"]["str"] = tostring(message)
                    local cjson = G_Json.encode(tmpTb)
                    message = G_accessCPlusFunction(cjson)
                    msgFont = G_EmojiFontSrc
                end
            end
            
            local xPos
            if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                xPos = sizeSp + 10
            else
                xPos = sizeSp + 40
            end
            if self.m_labelLastName and chatVo.type <= 3 then
                if chatVo.contentType == 3 then
                    --self.m_labelLastName:setString(nameStr)
                    self.m_labelLastName:setString("")
                else
                    xPos = xPos + self.m_labelLastName:getContentSize().width
                end
            end
            local message = string.gsub(message, "<rayimg>", "")
            --local tmpLb=GetTTFLabel(message,30)
            if self.m_labelLastMsg then
                self.m_labelLastMsg:setString(message)
                if msgFont then
                    self.m_labelLastMsg:setFontName(msgFont)
                end
            else
                --self.m_labelLastMsg=GetTTFLabel(message,30)
                self.m_labelLastMsg = GetTTFLabelWrap(message, chatfontsize, CCSizeMake(self.m_chatBg:getContentSize().width - xPos - 105, 35), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, msgFont)
                self.m_labelLastMsg:setAnchorPoint(ccp(0, 0.5))
                self.m_labelLastMsg:setPosition(ccp(xPos, self.m_chatBg:getContentSize().height / 2))
                self.m_chatBg:addChild(self.m_labelLastMsg, 2)
            end
            
            self.m_labelLastMsg:setDimensions(CCSize(self.m_chatBg:getContentSize().width - xPos - 105, 40))
            if chatVo.contentType and chatVo.contentType == 2 then --战报
                self.m_labelLastMsg:setColor(G_ColorYellow)
            else
                local isChangeColor = false
                if chatVo.contentType and chatVo.contentType == 1 and message == getlocal("activity_koulinghongbao_desc") and acKoulinghongbaoVoApi then
                    local acVo = acKoulinghongbaoVoApi:getAcVo()
                    if acVo and activityVoApi:isStart(acVo) == true then
                        self.m_labelLastMsg:setColor(G_ColorRed3)
                        isChangeColor = true
                    end
                end
                if isChangeColor == false then
                    self.m_labelLastMsg:setColor(color)
                end
            end
            if isGM then
                self.m_labelLastMsg:setColor(GM_Color)
            end
            self.m_labelLastMsg:setPosition(ccp(xPos, self.m_chatBg:getContentSize().height / 2))
            
        end
        chatVoApi:setNoNewData(0)
    end
end

function mainUI:changeToMyPort()
    if mainLandScene and mainLandScene.removeShowTip then
        mainLandScene:removeShowTip()
    end
    sceneController:changeSceneByIndex(0)
    self.m_menuToggle:setSelectedIndex(0)
    self:changeMainUI(0)
end

--coords：切换到世界地图的指定坐标
function mainUI:changeToWorld(coords, targetType)
    if G_notShowWorldMap()==true then
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("alliance_notOpen"), 28)
        do return end
    end
    if tonumber(playerVoApi:getPlayerLevel()) < 3 and tonumber(playerVoApi:getMapX()) == -1 then
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("worldSceneWillOpenDesc"), 28)
        do
            self:changeToMyPort()
            do return false end
        end
        
    end
    
    sceneController:changeSceneByIndex(2, coords, targetType)
    self.m_menuToggle:setSelectedIndex(2)
    self:changeMainUI(2)
    return true
end
function mainUI:changeToMainLand()
    
    sceneController:changeSceneByIndex(1)
    self.m_menuToggle:setSelectedIndex(1)
    self:changeMainUI(1)
end

function mainUI:destroySelf()
    
    mainUI = nil;
    
end

function mainUI:changeMainUI(sceneIndex)
    
    if sceneIndex == 0 then --港口
        self.mySpriteWorld:setPosition(0, 999333);
        self.mySpriteMain:setPosition(0, G_VisibleSizeHeight);
        self.mySpriteMain:setVisible(true)
        
        tipDialog:showTipsBar(self.myUILayer, ccp(320, G_VisibleSizeHeight + 46), ccp(320, G_VisibleSizeHeight - 26 - 150), getlocal("window1"), 80, 11);
        
        if self.m_directSign ~= nil then
            -- 切换到基地，删除方向标
            self.myUILayer:removeChild(self.m_directSign, true)
            self.m_directSign = nil
        end
        
        -- 显示快捷键
        self:showOrHideQuicklyBtn()
        -- -- 隐藏行军队列缩略面板
        self:hideFleetSlotMiniPanel()
        
    elseif sceneIndex == 1 then --岛屿
        self.mySpriteWorld:setPosition(0, 999333);
        self.mySpriteMain:setPosition(0, G_VisibleSizeHeight);
        self.mySpriteMain:setVisible(true)
        
        tipDialog:showTipsBar(self.myUILayer, ccp(320, G_VisibleSizeHeight + 46), ccp(320, G_VisibleSizeHeight - 26 - 150), getlocal("window2"), 80, 11);
        
    elseif sceneIndex == 2 then --世界
        self.mySpriteWorld:setPosition(0, G_VisibleSizeHeight - self.mySpriteWorld:getContentSize().height/2);
        self.mySpriteMain:setPosition(0, G_VisibleSizeHeight + 500);
        self.mySpriteMain:setVisible(false)
        tipDialog:showTipsBar(self.myUILayer, ccp(320, G_VisibleSizeHeight + 46), ccp(320, G_VisibleSizeHeight - 26 - 150), getlocal("window3"), 80, 11);
        
        -- 切换到世界，添加方向标
        self:addDirectionSign()
        -- 获得当前屏幕中心在世界地图的坐标
        local screenCenterPos = worldScene:getScreenPos()
        self:directSignMove(screenCenterPos)
        
        -- 隐藏快捷键
        self:showOrHideQuicklyBtn()
        -- -- 显示行军队列缩略面板
        self:showFleetSlotMiniPanel()
        
    end
end

function mainUI:setHide()
    self.myUILayer:setVisible(false)
end
function mainUI:isVisible()
    return self.myUILayer:isVisible()
end
function mainUI:setShow()
    self.myUILayer:setVisible(true)
    self:tick()
end

--取名字的板子
function mainUI:showCreateNewRole()
    self:showCreateNewRoleKunlunNew(true)
    do return end
--PlayEffect(audioCfg.mouseClick)
    local layerNum = 8
    local function touch()
        
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    
    local bgSp = LuaCCScale9Sprite:createWithSpriteFrameName("panelBg.png", CCRect(168, 86, 10, 10), touch)
    
    local rect = CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight)
    bgSp:setContentSize(rect)
    bgSp:setPosition(CCPointMake(G_VisibleSize.width / 2, G_VisibleSize.height / 2))
    bgSp:ignoreAnchorPointForPosition(false)
    sceneGame:addChild(bgSp, 19)
    bgSp:setTouchPriority(-(layerNum - 1) * 20 - 1);
    bgSp:setIsSallow(true)
    bgSp:setOpacity(0)
    
    -- 背景
    -- creatRole_bg1
    local diBg = CCSprite:create("public/creatRole_bg1.jpg")
    bgSp:addChild(diBg)
    diBg:setAnchorPoint(ccp(0.5, 0))
    diBg:setPosition(bgSp:getContentSize().width / 2, 0)
    if G_isIphone5() == false then
        diBg:setContentSize(CCSizeMake(diBg:getContentSize().width, diBg:getContentSize().height - 70))
    else
        diBg:setContentSize(CCSizeMake(diBg:getContentSize().width, diBg:getContentSize().height - 40))
    end
    
    local mohu1Sp = CCSprite:createWithSpriteFrameName("creatRole_mohu.png")
    diBg:addChild(mohu1Sp)
    mohu1Sp:setScaleX(diBg:getContentSize().width / mohu1Sp:getContentSize().width)
    mohu1Sp:setAnchorPoint(ccp(0.5, 1))
    mohu1Sp:setPosition(diBg:getContentSize().width / 2, diBg:getContentSize().height)
    
    local mohu2Sp = CCSprite:createWithSpriteFrameName("creatRole_mohu.png")
    diBg:addChild(mohu2Sp)
    mohu2Sp:setScaleX(diBg:getContentSize().width / mohu2Sp:getContentSize().width)
    mohu2Sp:setAnchorPoint(ccp(0.5, 1))
    mohu2Sp:setPosition(diBg:getContentSize().width / 2, 0)
    mohu2Sp:setRotation(180)
    
    local centerBg1 = CCSprite:createWithSpriteFrameName("creatRole1.png")
    centerBg1:setAnchorPoint(ccp(0, 0))
    bgSp:addChild(centerBg1, 1)
    centerBg1:setPosition(0, diBg:getContentSize().height)
    
    local centerBg2 = CCSprite:createWithSpriteFrameName("creatRole1.png")
    centerBg2:setAnchorPoint(ccp(0, 0))
    bgSp:addChild(centerBg2, 1)
    centerBg2:setPosition(320, diBg:getContentSize().height)
    centerBg2:setFlipX(true)
    
    local upBg = CCSprite:create("public/creatRole_bg2.jpg")
    bgSp:addChild(upBg)
    upBg:setAnchorPoint(ccp(0.5, 0))
    upBg:setPosition(bgSp:getContentSize().width / 2, diBg:getContentSize().height + centerBg2:getContentSize().height - 2)
    
    local rect = CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight)
    local titleLb = GetTTFLabel(getlocal("createRoleTitleNew"), 40)
    titleLb:setAnchorPoint(ccp(0.5, 0.5))
    titleLb:setPosition(ccp(bgSp:getContentSize().width / 2, bgSp:getContentSize().height - titleLb:getContentSize().height / 2 - 6))
    bgSp:addChild(titleLb, 1)
    
    local titleBg = CCSprite:createWithSpriteFrameName("allianceHeaderBg_black.png")
    titleBg:setAnchorPoint(ccp(0.5, 0.5))
    titleBg:setPosition(titleLb:getPosition())
    bgSp:addChild(titleBg)
    titleBg:setScaleX((titleLb:getContentSize().width + 200) / titleBg:getContentSize().width)
    titleBg:setScaleY(60 / titleBg:getContentSize().height)
    titleBg:setOpacity(180)
    
    --[[
    local function close()
        PlayEffect(audioCfg.mouseClick)
        bgSp:removeFromParentAndCleanup(true)
     end
   local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
        closeBtnItem:setPosition(0, 0)
        closeBtnItem:setAnchorPoint(CCPointMake(0,0))
     
    local closeBtn = CCMenu:createWithItem(closeBtnItem)
    closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    closeBtn:setPosition(ccp(rect.width-closeBtnItem:getContentSize().width,rect.height-closeBtnItem:getContentSize().height))
    bgSp:addChild(closeBtn)
    ]]
    
    local function bgAnimationSelected()
        local scaleTo = CCScaleTo:create(0.1, 1);
        local fadeOut = CCTintTo:create(0.1, 255, 255, 255)
        --local fadeOut=CCFadeTo:create(0.1,255)
        local carray = CCArray:create()
        carray:addObject(scaleTo)
        carray:addObject(fadeOut)
        local spa = CCSpawn:create(carray)
        return spa;
    end
    
    local function bgAnimationSelected2()
        local scaleTo = CCScaleTo:create(0.1, 0.7);
        local fadeOut = CCTintTo:create(0.1, 150, 150, 150)
        --local fadeOut=CCFadeTo:create(0.1,60)
        local carray = CCArray:create()
        carray:addObject(scaleTo)
        carray:addObject(fadeOut)
        local spa = CCSpawn:create(carray)
        return spa;
    end
    
    local roleType = 1;
    local roleName = "";
    local roleTb = {"public/man.png", "public/woman.png"}
    if(G_curPlatName() == "androidflbaidu" or G_curPlatName() == "48")then
        roleTb = {"flBaiduImage/man.png", "flBaiduImage/woman.png"}
    end
    
    -- 旧逻辑
    --   local rolePh={}
    --   local function touchPhoto(object,name,tag)
    --   local sp1=bgSp:getChildByTag(tag);
    --  local sp2=sp1:getChildByTag(2);
    --   local spa1=bgAnimationSelected()
    --        sp1:runAction(spa1)
    --   local fadeOut=CCTintTo:create(0.1,255,255,255)
    --   sp2:runAction(fadeOut)
    
    --   for k,v in pairs(rolePh) do
    --       if v:getTag()~=tag then
    
    --    local spa1=bgAnimationSelected2()
    --    local sp2=v:getChildByTag(2);
    --    local fadeOut=CCTintTo:create(0.1,150,150,150)
    --           v:runAction(spa1)
    --    sp2:runAction(fadeOut)
    
    --       end
    --   end
    
    --       roleType=tag;
    
    --   end
    --   local sign=0;
    --   local function touchBg()
    
    --   end
    --   for k,v in pairs(roleTb) do
    --      sign=sign+1
    --      local name=v
    --      local spBg=LuaCCSprite:createWithFileName("public/framebtn.png",touchPhoto);
    --      local chSp= LuaCCSprite:createWithFileName(name,touchBg);
    --  chSp:setTag(2)
    --      if sign<=3 then
    --          spBg:setPosition(ccp(185+(sign-1)*270,bgSp:getContentSize().height/2+100));
    --          chSp:setPosition(getCenterPoint(spBg));
    --      else
    --          spBg:setPosition(ccp(155+(sign-4)*160,bgSp:getContentSize().height/2-270));
    --          chSp:setPosition(getCenterPoint(spBg));
    --      end
    --  if k==2 then
    --     spBg:setScale(0.7)
    -- spBg:setColor(ccc3(150,150,150))
    -- chSp:setColor(ccc3(150,150,150))
    --  end
    --      spBg:setTag(sign);
    --      spBg:setIsSallow(true)
    --      spBg:setTouchPriority(-(layerNum-1)*20-2)
    --      rolePh[k]=spBg
    --      bgSp:addChild(spBg,1)
    --      spBg:addChild(chSp,2)
    --   end
    
    -- 新逻辑
    local bigIconScale = 1.1
    local bigIconH = 600
    if G_isIphone5() then
        bigIconScale = 1.5
        bigIconH = 710
    end
    local roleTbSmall = {"photo1.png", "photo2.png"}
    -- local nowBigIcon=CCSprite:create(roleTb[roleType])
    -- bgSp:addChild(nowBigIcon)
    -- nowBigIcon:setPosition(bgSp:getContentSize().width/2,bigIconH)
    -- nowBigIcon:setScale(bigIconScale)
    
    local tvW = 540
    local everyX = 110
    local selectSpTb = {}
    local tagetSelect
    
    local creatPage
    local clickFlag = false
    
    local function touchSelectHero(object, name, tag, nbFlag)
        if not nbFlag then
            if G_checkClickEnable() == false then
                do
                    return
                end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
        end
        if roleType == tag then
            return
        end
        clickFlag = true
        if tag == 1 then
            local child1 = tolua.cast(selectSpTb[1]:getChildByTag(1), "CCSprite")
            child1:setOpacity(0)
            local child2 = tolua.cast(selectSpTb[2]:getChildByTag(1), "CCSprite")
            child2:setOpacity(255)
            
            selectSpTb[1]:setScale(120 / selectSpTb[1]:getContentSize().width)
            selectSpTb[2]:setScale(100 / selectSpTb[2]:getContentSize().width)
            
            tagetSelect:setPositionX(tvW / 2 - 60)
        else
            local child1 = tolua.cast(selectSpTb[1]:getChildByTag(1), "CCSprite")
            child1:setOpacity(255)
            local child2 = tolua.cast(selectSpTb[2]:getChildByTag(1), "CCSprite")
            child2:setOpacity(0)
            selectSpTb[1]:setScale(100 / selectSpTb[1]:getContentSize().width)
            selectSpTb[2]:setScale(120 / selectSpTb[2]:getContentSize().width)
            tagetSelect:setPositionX(tvW / 2 + 60)
        end
        -- nowBigIcon:removeFromParentAndCleanup(true)
        -- nowBigIcon=CCSprite:create(roleTb[tag])
        -- bgSp:addChild(nowBigIcon)
        -- nowBigIcon:setScale(bigIconScale)
        -- nowBigIcon:setPosition(bgSp:getContentSize().width/2,bigIconH)
        if not nbFlag then
            if tag == 1 then
                creatPage:leftPage(true, tag, nil)
            else
                creatPage:rightPage(true, tag, nil)
            end
            
        end
        clickFlag = false
        roleType = tag
    end
    local selectBgH = diBg:getContentSize().height
    
    local selectBgH = diBg:getContentSize().height
    local function eventHandler(handler, fn, idx, cel)
        if fn == "numberOfCellsInTableView" then
            return 1
        elseif fn == "tableCellSizeForIndex" then
            return CCSizeMake(tvW, 137)
        elseif fn == "tableCellAtIndex" then
            local cell = CCTableViewCell:new()
            cell:autorelease()
            
            for k, v in pairs(roleTbSmall) do
                -- local selectBg=GetBgIcon(v,touchSelectHero,"creatRole_kuang.png",100,100)
                local childTb = {{pic = "creatRole_kuang.png", tag = 1, order = 2, size = 100}, {pic = v, tag = 2, order = 1, size = 95}}
                local selectBg = G_getComposeIcon(touchSelectHero, CCSizeMake(100, 100), childTb)
                cell:addChild(selectBg)
                selectBg:setPositionY(137 / 2)
                selectBg:setTag(k)
                selectBg:setTouchPriority(-(layerNum - 1) * 20 - 2)
                selectSpTb[k] = selectBg
                
                if k == 1 then
                    selectBg:setScale(120 / selectBg:getContentSize().height)
                    selectBg:setPositionX(tvW / 2 - 60)
                    local child = tolua.cast(selectBg:getChildByTag(1), "CCSprite")
                    child:setOpacity(0)
                else
                    selectBg:setScale(100 / selectBg:getContentSize().height)
                    selectBg:setPositionX(tvW / 2 + 60)
                end
            end
            
            tagetSelect = CCSprite:createWithSpriteFrameName("creatRole_kuang_select.png")
            cell:addChild(tagetSelect, 1)
            tagetSelect:setPosition(tvW / 2 - 60, 137 / 2)
            tagetSelect:setScale(120 / tagetSelect:getContentSize().height)
            
            local guangSelect = CCSprite:createWithSpriteFrameName("creatRole_kuang_guang.png")
            tagetSelect:addChild(guangSelect, 1)
            guangSelect:setPosition(getCenterPoint(tagetSelect))
            guangSelect:setScale(0.9)
            
            return cell
        elseif fn == "ccTouchBegan" then
            return true
        elseif fn == "ccTouchMoved" then
        elseif fn == "ccTouchEnded" then
        end
    end
    local hd = LuaEventHandler:createHandler(eventHandler)
    local selectTv = LuaCCTableView:createHorizontalWithEventHandler(hd, CCSizeMake(tvW, 137), nil)
    -- selectTv:setTableViewTouchPriority(-(layerNum-1)*20-1)
    selectTv:setPosition(ccp((bgSp:getContentSize().width - tvW) / 2, selectBgH))
    selectTv:setMaxDisToBottomOrTop(0)
    bgSp:addChild(selectTv, 2)
    
    -- 增加滑动
    -- local clayer=CCLayer:create()
    -- clayer:setTouchEnabled(true)
    -- clayer:setTouchPriority(-(layerNum-1)*20-1)
    -- local isMoved=nil
    -- local touchArr={}
    -- local touchEnable=true
    -- local multTouch=false
    -- local point=ccp(0,0)
    -- local lastBulletTime=0
    -- local function tmpHandler(fn,x,y,touch)
    --   if fn=="began" then
    --       if touchEnable==false or SizeOfTable(touchArr)>=1 then
    --            return 0
    --       end
    --       isMoved=false
    --       touchArr[touch]=touch
    --       point=ccp(x,y)
    
    --       if SizeOfTable(touchArr)>1 then
    --           multTouch=true
    --       else
    --           multTouch=false
    --       end
    --       return 1
    --   elseif fn=="moved" then
    --       if touchEnable==false then
    --            do
    --               return
    --            end
    --       end
    --       isMoved=true
    --       if multTouch==true then --双点触摸
    
    --       else --单点触摸
    
    --       end
    --   elseif fn=="ended" then
    --       if touchEnable==false then
    --            do
    --               return
    --            end
    --       end
    
    --       if multTouch==true then --双点触摸
    
    --       elseif G_getCurDeviceMillTime()>=lastBulletTime then
    
    --           local temTouch= tolua.cast(touchArr[touch],"CCTouch")
    --           -- local point = temTouch:getLocation()
    
    --           local delX = x-point.x
    
    --           if delX>15 then
    --             lastBulletTime=lastBulletTime+200
    --             local tag=roleType-1
    --             if tag==0 then
    --               tag=2
    --             end
    --             touchSelectHero(nil,nil,tag)
    --           elseif delX<-15 then
    --             lastBulletTime=lastBulletTime+200
    --             local tag=roleType+1
    --             if tag==3 then
    --               tag=1
    --             end
    --             touchSelectHero(nil,nil,tag)
    --           end
    
    --       end
    
    --       touchArr=nil
    --       touchArr={}
    --   end
    
    -- end
    -- clayer:registerScriptTouchHandler(tmpHandler,false,-(layerNum-1)*20-2,false)
    -- clayer:setPosition(0,0)
    -- bgSp:addChild(clayer)
    
    -- 改为翻页
    local list = {}
    local dlist = {}
    require "luascript/script/game/scene/gamedialog/creatRolePage"
    for i = 1, #roleTb do
        local bagPage = creatRolePage:new()
        local bagLayer = bagPage:init(roleTb[i], bigIconScale, bigIconH)
        bgSp:addChild(bagLayer)
        list[i] = bagLayer
        dlist[i] = bagPage
    end
    creatPage = pageDialog:new()
    local page = roleType
    local isShowBg = false
    local isShowPageBtn = false
    
    local function onPage(topage)
        page = topage
    end
    local function movedCallback(turnType, isTouch)
        if turnType == 1 then -- 左
            page = page - 1
            if page < 1 then
                page = #roleTb
            end
        else
            page = page + 1
            local totalNum = #roleTb
            if page > totalNum then
                page = 1
            end
        end
        if clickFlag == false then
            touchSelectHero(nil, nil, page, true)
        end
        return true
    end
    
    local posY = 300
    local startH = diBg:getContentSize().height
    
    local touchRect = {x = bgSp:getContentSize().width / 2, y = startH + (bgSp:getContentSize().height - startH) / 2, width = bgSp:getContentSize().width, height = bgSp:getContentSize().height - startH}
    
    local leftBtnPos = ccp(60, posY)
    local rightBtnPos = ccp(bgSp:getContentSize().width - 60, posY)
    local pageLayer = creatPage:create("panelItemBg.png", CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight), CCRect(20, 20, 10, 10), bgSp, ccp(0, 0), layerNum, page, list, isShowBg, isShowPageBtn, onPage, leftBtnPos, rightBtnPos, movedCallback, -(layerNum - 1) * 20 - 3, touchRect, "vipArrow.png", true, nil, 50, true)
    
    -- for k,v in pairs(roleTbSmall) do
    --   local selectBg=GetBgIcon(v,touchSelectHero,"equipBg_purple.png",70,100)
    --   bgSp:addChild(selectBg)
    
    --   selectBg:setTag(k)
    --   selectBg:setTouchPriority(-(layerNum-1)*20-2)
    --   if k==1 then
    --     selectBg:setPosition(bgSp:getContentSize().width/2-100,selectBgH)
    --   else
    --     selectBg:setPosition(bgSp:getContentSize().width/2+100,selectBgH)
    --   end
    -- end
    
    local subH = 0
    if G_isIphone5() == false then
        subH = 25
    end
    local function tthandler()
        
    end
    local function callBackXHandler(fn, eB, str)
        if str ~= nil then
            roleName = str;
            roleName = G_stringGsub(roleName, " ", "")
            if self.clickHereTipLabel ~= nil then
                self.clickHereTipLabel:setVisible(false)
            end
        end
    end
    
    -- local nameBox=LuaCCScale9Sprite:createWithSpriteFrameName("creatRole2.png",CCRect(70,35,1,1),tthandler)
    local nameBox = CCSprite:createWithSpriteFrameName("creatRole2.png")
    -- nameBox:setContentSize(CCSize(420,80))
    nameBox:setPosition(ccp(bgSp:getContentSize().width / 2, 220 - subH))
    bgSp:addChild(nameBox)
    
    local targetBoxLabel = GetTTFLabel("", 30)
    targetBoxLabel:setAnchorPoint(ccp(0.5, 0.5))
    targetBoxLabel:setPosition(ccp(nameBox:getContentSize().width / 2, nameBox:getContentSize().height / 2))
    local customEditBox = customEditBox:new()
    local length = 20
    customEditBox:init(nameBox, targetBoxLabel, "creatRole2.png", nil, (-(layerNum - 1) * 20 - 2), length, callBackXHandler, nil, nil)
    
    if platCfg.platCfgShowDefaultRoleName[G_curPlatName()] == nil then
        --这里开始
        
        local tipLabel = GetTTFLabel(getlocal("limitLength", {12}), 26)
        tipLabel:setAnchorPoint(ccp(0.5, 1))
        tipLabel:setPosition(ccp(bgSp:getContentSize().width / 2, 185 - subH))
        bgSp:addChild(tipLabel, 2)
        tipLabel:setColor(G_ColorRed)
        
        self.clickHereTipLabel = GetTTFLabel("点击这里输入名称", 30)
        self.clickHereTipLabel:setAnchorPoint(ccp(0.5, 0.5))
        self.clickHereTipLabel:setPosition(ccp(bgSp:getContentSize().width / 2, 220 - subH))
        bgSp:addChild(self.clickHereTipLabel, 10)
        self.clickHereTipLabel:setColor(G_ColorYellow)
        
        -- local cannotInputLabel=GetTTFLabel(getlocal("cannotInput"),26)
        -- cannotInputLabel:setAnchorPoint(ccp(0,1))
        -- cannotInputLabel:setPosition(ccp(bgSp:getContentSize().width/2-20,185-subH))
        -- bgSp:addChild(cannotInputLabel,2)
        -- cannotInputLabel:setColor(G_ColorGreen)
        
        --     local clickHereLabel=GetTTFLabel(getlocal("clickHere"),26)
        -- clickHereLabel:setAnchorPoint(ccp(0,1))
        -- clickHereLabel:setPosition(ccp(bgSp:getContentSize().width/2+108,185-subH))
        -- bgSp:addChild(clickHereLabel,2)
        -- clickHereLabel:setColor(G_ColorGreen)
        
        local male1 = {"阿波", "阿道", "阿尔", "阿姆", "阿诺", "阿奇", "埃达", "埃德", "埃迪", "埃尔", "埃里", "埃玛", "埃文", "艾比", "艾伯", "艾布", "艾丹", "艾德", "艾登", "艾尔", "艾富", "艾理", "艾伦", "艾略", "艾谱", "艾萨", "艾塞", "艾丝", "艾文", "艾西", "爱得", "爱德", "爱迪", "爱尔", "爱格", "爱莉", "爱罗", "爱曼", "安得", "安德", "安迪", "安东", "安格", "安纳", "安其", "安斯", "奥布", "奥德", "奥尔", "奥古", "奥劳", "奥利", "奥斯", "奥特", "巴德", "巴顿", "巴尔", "巴克", "巴里", "巴伦", "巴罗", "巴奈", "巴萨", "巴特", "巴泽", "柏得", "柏德", "柏格", "柏塔", "柏特", "柏宜", "拜尔", "拜伦", "班克", "班奈", "班尼", "宝儿", "保罗", "鲍比", "鲍伯", "贝尔", "贝克", "贝齐", "本恩", "本杰", "本森", "比尔", "比利", "比其", "彼得", "毕维", "毕夏", "宾尔", "波顿", "波特", "波文", "伯顿", "伯恩", "伯里", "伯尼"}
        local male2 = {"伯特", "博格", "布德", "布拉", "布莱", "布赖", "布兰", "布朗", "布雷", "布里", "布鲁", "布伦", "布尼", "布兹", "采尼", "查德", "查尔", "达尔", "达伦", "达尼", "大卫", "戴夫", "戴纳", "丹尼", "丹普", "道格", "得利", "德博", "德尔", "德里", "德维", "德文", "邓肯", "狄克", "迪得", "迪恩", "迪克", "迪伦", "迪姆", "迪斯", "蒂安", "蒂莫", "杜克", "杜鲁", "多夫", "多洛", "多明", "尔德", "尔特", "范尼", "菲比", "菲蕾", "菲力", "菲利", "菲兹", "斐迪", "费恩", "费力", "费奇", "费兹", "费滋", "佛里", "夫兰", "弗德", "弗恩", "弗兰", "弗朗", "弗莉", "弗罗", "弗农", "弗瑞", "福特", "富宾", "富兰", "盖尔", "盖克", "高达", "高德", "戈登", "格吉", "格拉", "格里", "格林", "格罗", "格纳", "葛里", "葛列", "葛瑞", "古斯", "哈帝", "哈乐", "哈里", "哈利", "哈伦", "哈瑞", "哈威", "海顿", "海勒", "海洛", "海曼"}
        local male3 = {"韩弗", "汉克", "汉米", "汉姆", "汉特", "赫伯", "赫达", "赫尔", "赫瑟", "亨利", "华纳", "霍伯", "霍尔", "霍根", "霍华", "基诺", "吉伯", "吉蒂", "吉恩", "吉罗", "吉米", "吉姆", "吉榭", "加百", "加比", "加尔", "加菲", "加里", "加文", "迦勒", "迦利", "嘉比", "贾艾", "贾斯", "杰弗", "杰克", "杰奎", "杰拉", "杰罗", "杰农", "杰瑞", "杰西", "杰伊", "捷勒", "卡尔", "卡萝", "卡洛", "卡玛", "卡梅", "卡斯", "卡特", "凯尔", "凯里", "凯理", "凯伦", "凯撒", "凯斯", "凯文", "凯希", "凯伊", "康拉", "康那", "康奈", "康斯", "考伯", "考尔", "柯帝", "柯利", "科迪", "科尔", "科林", "科兹", "克拉", "克莱", "克劳", "克雷", "克里", "克利", "克林", "克洛", "克思", "克斯", "肯姆", "肯尼", "寇里", "昆廷", "拉丁", "拉罕", "拉里", "拉斯", "莱德", "莱姆", "莱斯", "赖安", "兰德", "兰迪", "兰斯", "兰特", "劳伦", "劳瑞"}
        
        if platCfg.platCfgDefaultLocal[G_curPlatName()] == "tw" then
            male1 = {"阿波", "阿道", "阿爾", "阿姆", "阿諾", "阿奇", "埃達", "埃德", "埃迪", "埃爾", "埃裏", "埃瑪", "埃文", "艾比", "艾伯", "艾布", "艾丹", "艾德", "艾登", "艾爾", "艾富", "艾理", "艾倫", "艾略", "艾譜", "艾薩", "艾塞", "艾絲", "艾文", "艾西", "愛得", "愛德", "愛迪", "愛爾", "愛格", "愛莉", "愛羅", "愛曼", "安得", "安德", "安迪", "安東", "安格", "安納", "安其", "安斯", "奧布", "奧德", "奧爾", "奧古", "奧勞", "奧利", "奧斯", "奧特", "巴德", "巴頓", "巴爾", "巴克", "巴裏", "巴倫", "巴羅", "巴奈", "巴薩", "巴特", "巴澤", "柏得", "柏德", "柏格", "柏塔", "柏特", "柏宜", "拜爾", "拜倫", "班克", "班奈", "班尼", "寶兒", "保羅", "鮑比", "鮑伯", "貝爾", "貝克", "貝齊", "本恩", "本傑", "本森", "比爾", "比利", "比其", "彼得", "畢維", "畢夏", "賓爾", "波頓", "波特", "波文", "伯頓", "伯恩", "伯裏", "伯尼"}
            male2 = {"伯特", "博格", "布德", "布拉", "布萊", "布賴", "布蘭", "布朗", "布雷", "布裏", "布魯", "布倫", "布尼", "布茲", "采尼", "查德", "查爾", "達爾", "達倫", "達尼", "大衛", "戴夫", "戴納", "丹尼", "丹普", "道格", "得利", "德博", "德爾", "德裏", "德維", "德文", "鄧肯", "狄克", "迪得", "迪恩", "迪克", "迪倫", "迪姆", "迪斯", "蒂安", "蒂莫", "杜克", "杜魯", "多夫", "多洛", "多明", "爾德", "爾特", "範尼", "菲比", "菲蕾", "菲力", "菲利", "菲茲", "斐迪", "費恩", "費力", "費奇", "費茲", "費滋", "佛裏", "夫蘭", "弗德", "弗恩", "弗蘭", "弗朗", "弗莉", "弗羅", "弗農", "弗瑞", "福特", "富賓", "富蘭", "蓋爾", "蓋克", "高達", "高德", "戈登", "格吉", "格拉", "格裏", "格林", "格羅", "格納", "葛裏", "葛列", "葛瑞", "古斯", "哈帝", "哈樂", "哈裏", "哈利", "哈倫", "哈瑞", "哈威", "海頓", "海勒", "海洛", "海曼"}
            male3 = {"韓弗", "漢克", "漢米", "漢姆", "漢特", "赫伯", "赫達", "赫爾", "赫瑟", "亨利", "華納", "霍伯", "霍爾", "霍根", "霍華", "基諾", "吉伯", "吉蒂", "吉恩", "吉羅", "吉米", "吉姆", "吉榭", "加百", "加比", "加爾", "加菲", "加裏", "加文", "迦勒", "迦利", "嘉比", "賈艾", "賈斯", "傑弗", "傑克", "傑奎", "傑拉", "傑羅", "傑農", "傑瑞", "傑西", "傑伊", "捷勒", "卡爾", "卡蘿", "卡洛", "卡瑪", "卡梅", "卡斯", "卡特", "凱爾", "凱裏", "凱理", "凱倫", "凱撒", "凱斯", "凱文", "凱希", "凱伊", "康拉", "康那", "康奈", "康斯", "考伯", "考爾", "柯帝", "柯利", "科迪", "科爾", "科林", "科茲", "克拉", "克萊", "克勞", "克雷", "克裏", "克利", "克林", "克洛", "克思", "克斯", "肯姆", "肯尼", "寇裏", "昆廷", "拉丁", "拉罕", "拉裏", "拉斯", "萊德", "萊姆", "萊斯", "賴安", "蘭德", "蘭迪", "蘭斯", "蘭特", "勞倫", "勞瑞"}
        end
        
        local helpmebtn
        local function randRoleName(tag, object, sb1, sb2, flag)
            --roleName="克里斯来看看"
            --targetBoxLabel:setString(roleName)
            if not flag then
                local scaleAc1 = CCScaleTo:create(0.1, 0.9)
                local scaleAc2 = CCScaleTo:create(0.1, 1)
                local seq = CCSequence:createWithTwoActions(scaleAc1, scaleAc2)
                helpmebtn:runAction(seq)
            end
            self.clickHereTipLabel:setVisible(false)
            local orderTb = {}
            local maleT = deviceHelper:getRandom()
            if maleT <= 33 then
                orderTb[1] = male1
                orderTb[2] = male2
                orderTb[3] = male3
            elseif maleT > 66 then
                orderTb[1] = male3
                orderTb[2] = male1
                orderTb[3] = male2
            else
                orderTb[1] = male2
                orderTb[2] = male3
                orderTb[3] = male1
            end
            --越南随机名字特殊处理
            if(G_curPlatName() == "49" or G_curPlatName() == "androidyuenan" or G_curPlatName() == "0" or G_curPlatName() == "53" or G_curPlatName() == "androidyuenan2")then
                require "luascript/script/config/gameconfig/nameCfg"
                orderTb[1] = viNameCfg.firstName
                if(roleType == 1)then
                    orderTb[2] = viNameCfg.maleName
                else
                    orderTb[2] = viNameCfg.femaleName
                end
                for k, v in pairs(orderTb[3]) do
                    orderTb[3][k] = ""
                end
            end
            local rand1 = deviceHelper:getRandom()
            local rand2 = deviceHelper:getRandom()
            local rand3 = deviceHelper:getRandom()
            local realName = orderTb[1][rand1 == 0 and 1 or rand1]..orderTb[2][rand2 == 0 and 1 or rand2]..orderTb[3][rand3 == 0 and 1 or rand3]
            roleName = realName
            targetBoxLabel:setString(realName)
        end
        helpmebtn = GetButtonItem("DiceBtn.png", "DiceBtn.png", "DiceBtn.png", randRoleName, nil, nil, 25)
        -- helpmebtn:setOpacity(0)
        helpmebtn:registerScriptTapHandler(randRoleName)
        local helpmeMenu = CCMenu:createWithItem(helpmebtn);
        helpmeMenu:setPosition(ccp(bgSp:getContentSize().width / 2 + 200, 220 - subH))
        helpmeMenu:setTouchPriority(-(layerNum - 1) * 20 - 4);
        bgSp:addChild(helpmeMenu, 1)
        
        randRoleName(nil, nil, nil, nil, true)
        ---这里结束
    else
        local tipLabel = GetTTFLabel(getlocal("limitLength", {12}), 26)
        tipLabel:setAnchorPoint(ccp(0.5, 1))
        tipLabel:setPosition(ccp(bgSp:getContentSize().width / 2, 185 - subH))
        bgSp:addChild(tipLabel, 2)
        tipLabel:setColor(G_ColorRed)
    end
    
    local function createRole()
        local hasEmjoy = G_checkEmjoy(roleName)
        if hasEmjoy == false then
            do return end
        end
        local count = G_utfstrlen(roleName, true)
        if platCfg.platCfgKeyWord[G_curPlatName()] ~= nil then --设置屏蔽字
            if keyWordCfg:keyWordsJudge(roleName) == false then
                do
                    return
                end
            end
        end
        if G_match(roleName) ~= nil then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("alliance_illegalCharacters"), true, 20, G_ColorRed)
            do
                return
            end
        end
        print("roleName=", roleName)
        if string.find(roleName, ' ') ~= nil then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("blankCharacter"), true, 20, G_ColorRed)
            do
                return
            end
        end
        
        local strFisrt = G_stringGetAt(roleName, 0, 1)
        if tonumber(strFisrt) ~= nil then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("firstCharNoNum"), true, 20, G_ColorRed)
            do
                return
            end
        end
        
        if roleName == "" then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("nameNullCharacter"), true, 20, G_ColorRed)
            do
                return
            end
        end
        if count > 12 then
            
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("namelengthwrong"), true, 20, G_ColorRed)
        elseif count < 3 then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("roleNameMinLen"), true, 20, G_ColorRed)
            
        else
            local function serverUserSigupHandler(fn, data)
                --local sData=G_Json.decode(data)
                local result, sData = base:checkServerData(data, false)
                if tonumber(sData.ret) >= 0 and tonumber(sData.uid) > 0 then --登记角色名,选择头像成功
                    bgSp:removeFromParentAndCleanup(true)
                    if newGuidMgr.curBMStep ~= nil then
                        newGuidMgr.curBMStep = 6
                    end
                    
                    self.mySpriteLeft:getChildByTag(767):removeFromParentAndCleanup(true)
                    --local personPhotoName="photo"..roleType..".png"
                    --local personPhoto = CCSprite:createWithSpriteFrameName(personPhotoName);
                    local personPhoto = playerVoApi:getPersonPhotoSp(roleType)
                    personPhoto:setAnchorPoint(ccp(0.5, 0.5));
                    personPhoto:setPosition(ccp(42, self.mySpriteLeft:getContentSize().height / 2));
                    personPhoto:setTag(767)
                    self.mySpriteLeft:addChild(personPhoto, 5);
                    G_cancleLoginLoading()
                    newGuidMgr:toNextStep()
                else
                    smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("namehasbeenused"), true, 20, G_ColorRed)
                    G_cancleLoginLoading() --注册角色名失败 取消loading
                end
                
            end
            G_showLoginLoading() --加loading
            if newGuidMgr.curBMStep ~= nil then
                newGuidMgr.curBMStep = 7
            end
            socketHelper:userRename(roleName, roleType, serverUserSigupHandler)
        end
    end
    local menuItemCreate = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", createRole, nil, getlocal("createRole"), 28);
    
    local createBtn = CCMenu:createWithItem(menuItemCreate)
    createBtn:setTouchPriority(-(layerNum - 1) * 20 - 4)
    createBtn:setPosition(ccp(bgSp:getContentSize().width / 2, 100 - subH))
    bgSp:addChild(createBtn)
    
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    
end

--取名字的板子
function mainUI:showCreateNewRoleKunlun()
    -- local platName=G_curPlatName()
    -- if (platName=="14" or platName=="androidkunlun" or platName=="androidkunlunz" or platName=="0") then
    -- else
    self:showCreateNewRoleKunlunNew()
    do return end
-- end
    
    --PlayEffect(audioCfg.mouseClick)
    local layerNum = 8
    local function touch()
        
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    
    local bgSp = LuaCCScale9Sprite:createWithSpriteFrameName("panelBgKunlun.png", CCRect(168, 86, 10, 10), touch)
    
    local rect = CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight)
    bgSp:setContentSize(rect)
    bgSp:setPosition(CCPointMake(G_VisibleSize.width / 2, G_VisibleSize.height / 2))
    bgSp:ignoreAnchorPointForPosition(false)
    sceneGame:addChild(bgSp, 19)
    bgSp:setTouchPriority(-(layerNum - 1) * 20 - 1);
    bgSp:setIsSallow(true)
    
    local rect = CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight)
    local titleLb = GetTTFLabel(getlocal("createRoleTitle"), 40)
    titleLb:setAnchorPoint(ccp(0.5, 0.5))
    titleLb:setPosition(ccp(bgSp:getContentSize().width / 2, bgSp:getContentSize().height - titleLb:getContentSize().height / 2 - 15))
    bgSp:addChild(titleLb)
    
    local roleType = math.random(1, 6)
    local manPath1 = "public/man.png"
    local manPath2 = "public/woman.png"
    
    local namePath = "kunlunImage/"
    if G_curPlatName() == "android360ausgoogle" then
        namePath = "auImage/"
    end
    if platCfg.platNewGuideNMChose[G_curPlatName()] ~= nil then
        namePath = "nmImage/"
        manPath1 = "nmImage/man_1.png"
        manPath2 = "nmImage/woman_1.png"
    end
    
    local roleTb = {
        {icon = "photo5.png", img = namePath.."man_3.png", type = 5},
        {icon = "photo6.png", img = namePath.."woman_3.png", type = 6},
        {icon = "photo3.png", img = namePath.."man_2.png", type = 3},
        {icon = "photo4.png", img = namePath.."woman_2.png", type = 4},
        {icon = "photo1.png", img = manPath1, type = 1},
        {icon = "photo2.png", img = manPath2, type = 2},
    }
    local function touchBg()
        
    end
    
    local spBg = LuaCCSprite:createWithFileName("public/framebtn.png", touchBg);
    local rkey = 1
    for k, v in pairs(roleTb) do
        if v.type == roleType then
            rkey = k
        end
    end
    local chSp = LuaCCSprite:createWithFileName(roleTb[rkey].img, touchBg);
    chSp:setTag(20)
    spBg:setAnchorPoint(ccp(0.5, 1))
    spBg:setPosition(ccp(bgSp:getContentSize().width / 2 - 80, bgSp:getContentSize().height - 160));
    chSp:setPosition(getCenterPoint(spBg));
    spBg:addChild(chSp)
    bgSp:addChild(spBg)
    
    local wkuangSp
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        wkuangSp = LuaCCScale9Sprite:createWithSpriteFrameName("guide_res.png", CCRect(28, 28, 2, 2), touchBg)
    else
        wkuangSp = LuaCCScale9Sprite:createWithSpriteFrameName("guide_res1.png", CCRect(28, 28, 2, 2), touchBg)
    end

    wkuangSp:setContentSize(CCSizeMake(108, 100))
    
    local lanTb = {}
    local function touch(object, name, tag)
        local sp1 = bgSp:getChildByTag(tag);
        wkuangSp:setPosition(sp1:getPosition())
        sp1:setScale(1.2)
        local node = spBg:getChildByTag(20)
        node:removeFromParentAndCleanup(true)
        local chSp = LuaCCSprite:createWithFileName(roleTb[tag].img, touchBg);
        chSp:setPosition(getCenterPoint(spBg));
        chSp:setTag(20)
        spBg:addChild(chSp)
        roleType = roleTb[tag].type
        for k, v in pairs(lanTb) do
            if v:getTag() ~= tag then
                v:setScale(1)
            end
        end
    end
    
    for k, v in pairs(roleTb) do
        local name = roleTb[k].icon
        local chSp = LuaCCSprite:createWithSpriteFrameName(name, touch)
        chSp:setPosition(ccp(530, bgSp:getContentSize().height - 70 - (95 * k)))
        chSp:setTag(k)
        chSp:setIsSallow(true)
        chSp:setTouchPriority(-(layerNum - 1) * 20 - 2)
        local kuangSp = LuaCCSprite:createWithSpriteFrameName("kuangKunlun.png", touchBg);
        kuangSp:setPosition(getCenterPoint(chSp))
        kuangSp:setScale(1.4)
        chSp:addChild(kuangSp)
        bgSp:addChild(chSp, 2)
        if roleTb[k].type == roleType then
            wkuangSp:setPosition(chSp:getPosition())
            bgSp:addChild(wkuangSp, 3)
            chSp:setScale(1.2)
        end
        lanTb[k] = chSp
    end
    
    local function tthandler()
        
    end
    local function callBackXHandler(fn, eB, str)
        if str ~= nil then
            roleName = str;
            roleName = G_stringGsub(roleName, " ", "")
            if self.clickHereTipLabel ~= nil then
                self.clickHereTipLabel:setVisible(false)
            end
        end
    end
    
    local nameBox = LuaCCScale9Sprite:createWithSpriteFrameName("inputNameBg.png", CCRect(70, 35, 1, 1), tthandler)
    nameBox:setContentSize(CCSize(420, 80))
    nameBox:setPosition(ccp(bgSp:getContentSize().width / 2, 220))
    bgSp:addChild(nameBox)
    
    local targetBoxLabel = GetTTFLabel("", 30)
    targetBoxLabel:setAnchorPoint(ccp(0, 0.5))
    targetBoxLabel:setPosition(ccp(10, nameBox:getContentSize().height / 2))
    local customEditBox = customEditBox:new()
    local length = 20
    customEditBox:init(nameBox, targetBoxLabel, "inputNameBg.png", nil, (-(layerNum - 1) * 20 - 2), length, callBackXHandler, nil, nil)
    
    if platCfg.platCfgShowDefaultRoleName[G_curPlatName()] == nil then
        --这里开始
        
        local tipLabel = GetTTFLabel(getlocal("limitLength", {12}), 26)
        tipLabel:setAnchorPoint(ccp(0.5, 1))
        tipLabel:setPosition(ccp(bgSp:getContentSize().width / 2 - 130, 185))
        bgSp:addChild(tipLabel, 2)
        tipLabel:setColor(G_ColorRed)
        
        self.clickHereTipLabel = GetTTFLabel("点击这里输入名称", 30)
        self.clickHereTipLabel:setAnchorPoint(ccp(0.5, 0.5))
        self.clickHereTipLabel:setPosition(ccp(bgSp:getContentSize().width / 2, 220))
        bgSp:addChild(self.clickHereTipLabel, 10)
        self.clickHereTipLabel:setColor(G_ColorYellow)
        
        local cannotInputLabel = GetTTFLabel(getlocal("cannotInput"), 26)
        cannotInputLabel:setAnchorPoint(ccp(0, 1))
        cannotInputLabel:setPosition(ccp(bgSp:getContentSize().width / 2 - 20, 185))
        bgSp:addChild(cannotInputLabel, 2)
        cannotInputLabel:setColor(G_ColorGreen)
        
        local clickHereLabel = GetTTFLabel(getlocal("clickHere"), 26)
        clickHereLabel:setAnchorPoint(ccp(0, 1))
        clickHereLabel:setPosition(ccp(bgSp:getContentSize().width / 2 + 108, 185))
        bgSp:addChild(clickHereLabel, 2)
        clickHereLabel:setColor(G_ColorGreen)
        
        local male1 = {"阿波", "阿道", "阿尔", "阿姆", "阿诺", "阿奇", "埃达", "埃德", "埃迪", "埃尔", "埃里", "埃玛", "埃文", "艾比", "艾伯", "艾布", "艾丹", "艾德", "艾登", "艾尔", "艾富", "艾理", "艾伦", "艾略", "艾谱", "艾萨", "艾塞", "艾丝", "艾文", "艾西", "爱得", "爱德", "爱迪", "爱尔", "爱格", "爱莉", "爱罗", "爱曼", "安得", "安德", "安迪", "安东", "安格", "安纳", "安其", "安斯", "奥布", "奥德", "奥尔", "奥古", "奥劳", "奥利", "奥斯", "奥特", "巴德", "巴顿", "巴尔", "巴克", "巴里", "巴伦", "巴罗", "巴奈", "巴萨", "巴特", "巴泽", "柏得", "柏德", "柏格", "柏塔", "柏特", "柏宜", "拜尔", "拜伦", "班克", "班奈", "班尼", "宝儿", "保罗", "鲍比", "鲍伯", "贝尔", "贝克", "贝齐", "本恩", "本杰", "本森", "比尔", "比利", "比其", "彼得", "毕维", "毕夏", "宾尔", "波顿", "波特", "波文", "伯顿", "伯恩", "伯里", "伯尼"}
        local male2 = {"伯特", "博格", "布德", "布拉", "布莱", "布赖", "布兰", "布朗", "布雷", "布里", "布鲁", "布伦", "布尼", "布兹", "采尼", "查德", "查尔", "达尔", "达伦", "达尼", "大卫", "戴夫", "戴纳", "丹尼", "丹普", "道格", "得利", "德博", "德尔", "德里", "德维", "德文", "邓肯", "狄克", "迪得", "迪恩", "迪克", "迪伦", "迪姆", "迪斯", "蒂安", "蒂莫", "杜克", "杜鲁", "多夫", "多洛", "多明", "尔德", "尔特", "范尼", "菲比", "菲蕾", "菲力", "菲利", "菲兹", "斐迪", "费恩", "费力", "费奇", "费兹", "费滋", "佛里", "夫兰", "弗德", "弗恩", "弗兰", "弗朗", "弗莉", "弗罗", "弗农", "弗瑞", "福特", "富宾", "富兰", "盖尔", "盖克", "高达", "高德", "戈登", "格吉", "格拉", "格里", "格林", "格罗", "格纳", "葛里", "葛列", "葛瑞", "古斯", "哈帝", "哈乐", "哈里", "哈利", "哈伦", "哈瑞", "哈威", "海顿", "海勒", "海洛", "海曼"}
        local male3 = {"韩弗", "汉克", "汉米", "汉姆", "汉特", "赫伯", "赫达", "赫尔", "赫瑟", "亨利", "华纳", "霍伯", "霍尔", "霍根", "霍华", "基诺", "吉伯", "吉蒂", "吉恩", "吉罗", "吉米", "吉姆", "吉榭", "加百", "加比", "加尔", "加菲", "加里", "加文", "迦勒", "迦利", "嘉比", "贾艾", "贾斯", "杰弗", "杰克", "杰奎", "杰拉", "杰罗", "杰农", "杰瑞", "杰西", "杰伊", "捷勒", "卡尔", "卡萝", "卡洛", "卡玛", "卡梅", "卡斯", "卡特", "凯尔", "凯里", "凯理", "凯伦", "凯撒", "凯斯", "凯文", "凯希", "凯伊", "康拉", "康那", "康奈", "康斯", "考伯", "考尔", "柯帝", "柯利", "科迪", "科尔", "科林", "科兹", "克拉", "克莱", "克劳", "克雷", "克里", "克利", "克林", "克洛", "克思", "克斯", "肯姆", "肯尼", "寇里", "昆廷", "拉丁", "拉罕", "拉里", "拉斯", "莱德", "莱姆", "莱斯", "赖安", "兰德", "兰迪", "兰斯", "兰特", "劳伦", "劳瑞"}
        
        if platCfg.platCfgDefaultLocal[G_curPlatName()] == "tw" then
            male1 = {"阿波", "阿道", "阿爾", "阿姆", "阿諾", "阿奇", "埃達", "埃德", "埃迪", "埃爾", "埃裏", "埃瑪", "埃文", "艾比", "艾伯", "艾布", "艾丹", "艾德", "艾登", "艾爾", "艾富", "艾理", "艾倫", "艾略", "艾譜", "艾薩", "艾塞", "艾絲", "艾文", "艾西", "愛得", "愛德", "愛迪", "愛爾", "愛格", "愛莉", "愛羅", "愛曼", "安得", "安德", "安迪", "安東", "安格", "安納", "安其", "安斯", "奧布", "奧德", "奧爾", "奧古", "奧勞", "奧利", "奧斯", "奧特", "巴德", "巴頓", "巴爾", "巴克", "巴裏", "巴倫", "巴羅", "巴奈", "巴薩", "巴特", "巴澤", "柏得", "柏德", "柏格", "柏塔", "柏特", "柏宜", "拜爾", "拜倫", "班克", "班奈", "班尼", "寶兒", "保羅", "鮑比", "鮑伯", "貝爾", "貝克", "貝齊", "本恩", "本傑", "本森", "比爾", "比利", "比其", "彼得", "畢維", "畢夏", "賓爾", "波頓", "波特", "波文", "伯頓", "伯恩", "伯裏", "伯尼"}
            male2 = {"伯特", "博格", "布德", "布拉", "布萊", "布賴", "布蘭", "布朗", "布雷", "布裏", "布魯", "布倫", "布尼", "布茲", "采尼", "查德", "查爾", "達爾", "達倫", "達尼", "大衛", "戴夫", "戴納", "丹尼", "丹普", "道格", "得利", "德博", "德爾", "德裏", "德維", "德文", "鄧肯", "狄克", "迪得", "迪恩", "迪克", "迪倫", "迪姆", "迪斯", "蒂安", "蒂莫", "杜克", "杜魯", "多夫", "多洛", "多明", "爾德", "爾特", "範尼", "菲比", "菲蕾", "菲力", "菲利", "菲茲", "斐迪", "費恩", "費力", "費奇", "費茲", "費滋", "佛裏", "夫蘭", "弗德", "弗恩", "弗蘭", "弗朗", "弗莉", "弗羅", "弗農", "弗瑞", "福特", "富賓", "富蘭", "蓋爾", "蓋克", "高達", "高德", "戈登", "格吉", "格拉", "格裏", "格林", "格羅", "格納", "葛裏", "葛列", "葛瑞", "古斯", "哈帝", "哈樂", "哈裏", "哈利", "哈倫", "哈瑞", "哈威", "海頓", "海勒", "海洛", "海曼"}
            male3 = {"韓弗", "漢克", "漢米", "漢姆", "漢特", "赫伯", "赫達", "赫爾", "赫瑟", "亨利", "華納", "霍伯", "霍爾", "霍根", "霍華", "基諾", "吉伯", "吉蒂", "吉恩", "吉羅", "吉米", "吉姆", "吉榭", "加百", "加比", "加爾", "加菲", "加裏", "加文", "迦勒", "迦利", "嘉比", "賈艾", "賈斯", "傑弗", "傑克", "傑奎", "傑拉", "傑羅", "傑農", "傑瑞", "傑西", "傑伊", "捷勒", "卡爾", "卡蘿", "卡洛", "卡瑪", "卡梅", "卡斯", "卡特", "凱爾", "凱裏", "凱理", "凱倫", "凱撒", "凱斯", "凱文", "凱希", "凱伊", "康拉", "康那", "康奈", "康斯", "考伯", "考爾", "柯帝", "柯利", "科迪", "科爾", "科林", "科茲", "克拉", "克萊", "克勞", "克雷", "克裏", "克利", "克林", "克洛", "克思", "克斯", "肯姆", "肯尼", "寇裏", "昆廷", "拉丁", "拉罕", "拉裏", "拉斯", "萊德", "萊姆", "萊斯", "賴安", "蘭德", "蘭迪", "蘭斯", "蘭特", "勞倫", "勞瑞"}
        end
        
        local function randRoleName()
            --roleName="克里斯来看看"
            --targetBoxLabel:setString(roleName)
            self.clickHereTipLabel:setVisible(false)
            local orderTb = {}
            local maleT = deviceHelper:getRandom()
            if maleT <= 33 then
                orderTb[1] = male1
                orderTb[2] = male2
                orderTb[3] = male3
            elseif maleT > 66 then
                orderTb[1] = male3
                orderTb[2] = male1
                orderTb[3] = male2
            else
                orderTb[1] = male2
                orderTb[2] = male3
                orderTb[3] = male1
            end
            local rand1 = deviceHelper:getRandom()
            local rand2 = deviceHelper:getRandom()
            local rand3 = deviceHelper:getRandom()
            local realName = orderTb[1][rand1 == 0 and 1 or rand1]..orderTb[2][rand2 == 0 and 1 or rand2]..orderTb[3][rand3 == 0 and 1 or rand3]
            roleName = realName
            targetBoxLabel:setString(realName)
        end
        local helpmebtn = GetButtonItem("LoadingSelectServerBtn.png", "LoadingSelectServerBtn_Down.png", "LoadingSelectServerBtn.png", randRoleName, nil, getlocal("serverList"), 25)
        helpmebtn:setOpacity(0)
        helpmebtn:registerScriptTapHandler(randRoleName)
        local helpmeMenu = CCMenu:createWithItem(helpmebtn);
        helpmeMenu:setPosition(ccp(bgSp:getContentSize().width / 2 + 170, 160))
        helpmeMenu:setTouchPriority(-(layerNum - 1) * 20 - 4);
        bgSp:addChild(helpmeMenu, 1)
        
        randRoleName()
        ---这里结束
    else
        local tipLabel = GetTTFLabel(getlocal("limitLength", {12}), 26)
        tipLabel:setAnchorPoint(ccp(0.5, 1))
        tipLabel:setPosition(ccp(bgSp:getContentSize().width / 2, 185))
        bgSp:addChild(tipLabel, 2)
        tipLabel:setColor(G_ColorRed)
    end
    
    if platCfg.platNewGuideNMChose[G_curPlatName()] ~= nil then
        require "luascript/script/config/gameconfig/nameCfg"
        local function randomName()
            if G_getCurChoseLanguage() == "en" then
                local name1 = nmNameCfg[math.random(1, 800)]
                local name2 = nmNameCfg[math.random(1, 800)]
                
                roleName = name1.."-"..name2
                targetBoxLabel:setString(name1.."-"..name2)
                
            elseif G_getCurChoseLanguage() == "pt" then
                
                if roleType == 1 or roleType == 3 or roleType == 5 then
                    local name1 = nmNameCfg1[math.random(1, 400)]
                    local name2 = nmFirstNameCfg[math.random(1, 398)]
                    roleName = name1.."-"..name2
                    targetBoxLabel:setString(name1.."-"..name2)
                elseif roleType == 2 or roleType == 4 or roleType == 6 then
                    local name1 = nmNameCfg2[math.random(1, 400)]
                    local name2 = nmFirstNameCfg[math.random(1, 398)]
                    roleName = name1.."-"..name2
                    targetBoxLabel:setString(name1.."-"..name2)
                end
                
            end
        end
        randomName()
        
        local function pbUIhandler()
            randomName()
        end
        local diceBtnSp = LuaCCSprite:createWithSpriteFrameName("DiceBtn.png", pbUIhandler)
        diceBtnSp:setIsSallow(true)
        diceBtnSp:setTouchPriority(-(layerNum - 1) * 20 - 4)
        diceBtnSp:setAnchorPoint(ccp(0, 0.5));
        diceBtnSp:setPosition(510, 220);
        diceBtnSp:setScale(0.9)
        bgSp:addChild(diceBtnSp, 13);
        nameBox:setPosition(ccp(bgSp:getContentSize().width / 2 - 40, 220))
        
    end
    
    local function createRole()
        
        local count = G_utfstrlen(roleName, true)
        if platCfg.platCfgKeyWord[G_curPlatName()] ~= nil then --设置屏蔽字
            if keyWordCfg:keyWordsJudge(roleName) == false then
                do
                    return
                end
            end
        end
        if G_match(roleName) ~= nil then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("alliance_illegalCharacters"), true, 20, G_ColorRed)
            do
                return
            end
        end
        print("roleName=", roleName)
        if string.find(roleName, ' ') ~= nil then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("blankCharacter"), true, 20, G_ColorRed)
            do
                return
            end
        end
        
        local strFisrt = G_stringGetAt(roleName, 0, 1)
        if tonumber(strFisrt) ~= nil then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("firstCharNoNum"), true, 20, G_ColorRed)
            do
                return
            end
        end
        
        if roleName == "" then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("nameNullCharacter"), true, 20, G_ColorRed)
            do
                return
            end
        end
        if count > 12 then
            
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("namelengthwrong"), true, 20, G_ColorRed)
        elseif count < 3 then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("roleNameMinLen"), true, 20, G_ColorRed)
            
        else
            local function serverUserSigupHandler(fn, data)
                --local sData=G_Json.decode(data)
                local result, sData = base:checkServerData(data, false)
                if tonumber(sData.ret) >= 0 and tonumber(sData.uid) > 0 then --登记角色名,选择头像成功
                    bgSp:removeFromParentAndCleanup(true)
                    if newGuidMgr.curBMStep ~= nil then
                        newGuidMgr.curBMStep = 6
                    end
                    
                    self.mySpriteLeft:getChildByTag(767):removeFromParentAndCleanup(true)
                    --local personPhotoName="photo"..roleType..".png"
                    --local personPhoto = CCSprite:createWithSpriteFrameName(personPhotoName);
                    local personPhoto = playerVoApi:getPersonPhotoSp(roleType)
                    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                        personPhoto:setAnchorPoint(ccp(0.5, 0.5));
                        personPhoto:setPosition(ccp(42, self.mySpriteLeft:getContentSize().height / 2));
                    else
                        personPhoto:setAnchorPoint(ccp(0.5,1))
                        personPhoto:setScale(1.1)
                        personPhoto:setPosition(ccp(self.mySpriteLeft:getContentSize().width / 2, self.mySpriteLeft:getContentSize().height-12));
                    end
                    personPhoto:setTag(767)
                    self.mySpriteLeft:addChild(personPhoto, 5);
                    G_cancleLoginLoading()
                    newGuidMgr:toNextStep()
                else
                    
                    smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("namehasbeenused"), true, 20, G_ColorRed)
                    G_cancleLoginLoading() --注册角色名失败 取消loading
                end
                
            end
            G_showLoginLoading() --加loading
            if newGuidMgr.curBMStep ~= nil then
                newGuidMgr.curBMStep = 7
            end
            
            socketHelper:userRename(roleName, roleType, serverUserSigupHandler)
        end
    end
    local menuItemCreate = GetButtonItem("LoadingBtn.png", "LoadingBtn_Down.png", "LoadingBtn.png", createRole, nil, getlocal("createRole"), 25);
    
    local createBtn = CCMenu:createWithItem(menuItemCreate)
    createBtn:setTouchPriority(-(layerNum - 1) * 20 - 4)
    createBtn:setPosition(ccp(bgSp:getContentSize().width / 2, 95))
    bgSp:addChild(createBtn)
    
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    
end

--取名字的板子
function mainUI:showCreateNewRoleKunlunNew(addRole)
    --PlayEffect(audioCfg.mouseClick)
    local layerNum = 8
    local function touch()
        
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    
    local bgSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), touch)
    
    local rect = CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight)
    bgSp:setContentSize(rect)
    bgSp:setPosition(CCPointMake(G_VisibleSize.width / 2, G_VisibleSize.height / 2))
    bgSp:ignoreAnchorPointForPosition(false)
    sceneGame:addChild(bgSp, 19)
    bgSp:setTouchPriority(-(layerNum - 1) * 20 - 1);
    bgSp:setOpacity(0)
    bgSp:setIsSallow(true)
    
    -- 新加 屏蔽层
    local function touchDialog()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), touchDialog);
    touchDialogBg:setTouchPriority(-(layerNum - 1) * 20 - 10)
    local rect = CCSizeMake(bgSp:getContentSize().width, bgSp:getContentSize().height)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setVisible(false)
    touchDialogBg:setIsSallow(true)
    touchDialogBg:setPosition(100000, 100000)
    bgSp:addChild(touchDialogBg, 1)
    
    -- 背景
    -- creatRole_bg1
    local diBg = CCSprite:create("public/creatRole_bg1.jpg")
    bgSp:addChild(diBg)
    diBg:setAnchorPoint(ccp(0.5, 0))
    diBg:setPosition(bgSp:getContentSize().width / 2, 0)
    if G_isIphone5() == false then
        diBg:setContentSize(CCSizeMake(diBg:getContentSize().width, diBg:getContentSize().height - 70))
    else
        diBg:setContentSize(CCSizeMake(diBg:getContentSize().width, diBg:getContentSize().height - 40))
    end
    
    local mohu1Sp = CCSprite:createWithSpriteFrameName("creatRole_mohu.png")
    diBg:addChild(mohu1Sp)
    mohu1Sp:setScaleX(diBg:getContentSize().width / mohu1Sp:getContentSize().width)
    mohu1Sp:setAnchorPoint(ccp(0.5, 1))
    mohu1Sp:setPosition(diBg:getContentSize().width / 2, diBg:getContentSize().height)
    
    local mohu2Sp = CCSprite:createWithSpriteFrameName("creatRole_mohu.png")
    diBg:addChild(mohu2Sp)
    mohu2Sp:setScaleX(diBg:getContentSize().width / mohu2Sp:getContentSize().width)
    mohu2Sp:setAnchorPoint(ccp(0.5, 1))
    mohu2Sp:setPosition(diBg:getContentSize().width / 2, 0)
    mohu2Sp:setRotation(180)
    
    local centerBg1 = CCSprite:createWithSpriteFrameName("creatRole1.png")
    centerBg1:setAnchorPoint(ccp(0, 0))
    bgSp:addChild(centerBg1, 1)
    centerBg1:setPosition(0, diBg:getContentSize().height)
    
    local centerBg2 = CCSprite:createWithSpriteFrameName("creatRole1.png")
    centerBg2:setAnchorPoint(ccp(0, 0))
    bgSp:addChild(centerBg2, 1)
    centerBg2:setPosition(320, diBg:getContentSize().height)
    centerBg2:setFlipX(true)
    
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
    local subH = diBg:getContentSize().height + centerBg2:getContentSize().height
    local nodeSize = CCSizeMake(bgSp:getContentSize().width, G_VisibleSizeHeight - subH + 1)
    local clipperNode = CCClippingNode:create()
    
    local stencil = CCDrawNode:getAPolygon(nodeSize, 1, 1)
    stencil:setPosition(0, 0)
    clipperNode:setStencil(stencil)
    
    clipperNode:setAnchorPoint(ccp(0.5, 1))
    clipperNode:setContentSize(nodeSize)
    bgSp:addChild(clipperNode)
    clipperNode:setPosition(ccp(G_VisibleSizeWidth / 2, bgSp:getContentSize().height))
    
    local upBg = CCSprite:create("public/creatRole_bg2.jpg")
    clipperNode:addChild(upBg)
    upBg:setAnchorPoint(ccp(0.5, 1))
    upBg:setPosition(clipperNode:getContentSize().width / 2, clipperNode:getContentSize().height)
    if G_getIphoneType() == G_iphoneX then
        upBg:setScaleY((upBg:getContentSize().height + 114) / upBg:getContentSize().height)
    end
    -- upBg:setAnchorPoint(ccp(0.5,0))
    -- upBg:setPosition(bgSp:getContentSize().width/2,diBg:getContentSize().height+centerBg2:getContentSize().height-2)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    
    local rect = CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight)
    local titleLb = GetTTFLabel(getlocal("createRoleTitleNew"), 32)
    titleLb:setAnchorPoint(ccp(0.5, 0.5))
    titleLb:setPosition(ccp(bgSp:getContentSize().width / 2, bgSp:getContentSize().height - titleLb:getContentSize().height / 2 - 6))
    bgSp:addChild(titleLb, 1)
    
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local titleBg = CCSprite:createWithSpriteFrameName("allianceHeaderBg_black.png")
    titleBg:setAnchorPoint(ccp(0.5, 0.5))
    titleBg:setPosition(titleLb:getPosition())
    bgSp:addChild(titleBg)
    titleBg:setScaleX((titleLb:getContentSize().width + 200) / titleBg:getContentSize().width)
    titleBg:setScaleY(44 / titleBg:getContentSize().height)
    titleBg:setOpacity(180)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    
    local roleType = math.random(1, 6)
    -- if addRole then
    --   roleType=math.random(1,8)
    -- else
    --   roleType=math.random(1,6)
    -- end
    
    local roleName = ""
    
    local roleTb = {
        {icon = "photo101.png", img = "public/newRole1.png", type = 101},
        {icon = "photo102.png", img = "public/newRole2.png", type = 102},
        {icon = "photo103.png", img = "public/newRole3.png", type = 103},
        {icon = "photo104.png", img = "public/newRole4.png", type = 104},
        {icon = "photo105.png", img = "public/newRole5.png", type = 105},
        {icon = "photo106.png", img = "public/newRole6.png", type = 106},
    }
    
    if addRole then
        table.insert(roleTb, {icon = "photo1.png", img = "public/man.png", type = 1})
        table.insert(roleTb, {icon = "photo2.png", img = "public/woman.png", type = 2})
    end
    
    -- 新逻辑
    local tvW = 540
    local everyX = 110
    local sbId = 0
    local totalRoleNum = #roleTb
    -- print("totalRoleNum",totalRoleNum)
    local function setPostionXCallback(target, roleType)
        local tag = target:getTag()
        local child = tolua.cast(target:getChildByTag(1), "CCSprite")
        local subNum = roleType - tag
        if subNum == 0 then
            target:setPositionX(tvW / 2)
            target:setScale(120 / target:getContentSize().height)
            child:setOpacity(0)
        elseif subNum == -1 or subNum == totalRoleNum - 1 then
            target:setPositionX(tvW / 2 + everyX)
            target:setScale(1)
            child:setOpacity(255)
        elseif subNum == 1 or subNum == -(totalRoleNum - 1) then
            target:setPositionX(tvW / 2 - everyX)
            target:setScale(1)
            child:setOpacity(255)
        elseif subNum == -2 or subNum == totalRoleNum - 2 then
            target:setPositionX(tvW / 2 + 2 * everyX)
            target:setScale(1)
            child:setOpacity(255)
        elseif subNum == 2 or subNum == -(totalRoleNum - 2) then
            target:setPositionX(tvW / 2 - 2 * everyX)
            target:setScale(1)
            child:setOpacity(255)
        else
            target:setPositionX(1000)
            target:setScale(1)
            child:setOpacity(255)
            sbId = tag
        end
    end
    
    local bigIconScale = 1
    local bigIconH = 640
    if G_isIphone5() then
        bigIconH = 710
    else
        bigIconScale = 0.8
    end
    
    -- local nowBigIcon=CCSprite:create(roleTb[roleType].img)
    -- bgSp:addChild(nowBigIcon)
    -- nowBigIcon:setPosition(bgSp:getContentSize().width/2,bigIconH)
    -- nowBigIcon:setScale(bigIconScale)
    local selectSpTb = {}
    local tagetSelect
    local moveTime = 0.06
    -- moveTime=3
    
    local creatPage
    local clickFlag = false
    -- 新
    local function touchSelectHero(object, name, tag, nbFlag)
        if G_checkClickEnable() == false then
            do
                return
            end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        if roleType == tag then
            return
        end
        local pox1 = selectSpTb[tag]:getPositionX()
        local pox2 = selectSpTb[roleType]:getPositionX()
        local subX = pox1 - pox2
        if subX > 0 then
            creatPage:rightPage(true, tag, nil)
        else
            creatPage:leftPage(true, tag, nil)
        end
        
    end
    local selectBgH = diBg:getContentSize().height
    local function eventHandler(handler, fn, idx, cel)
        if fn == "numberOfCellsInTableView" then
            return 1
        elseif fn == "tableCellSizeForIndex" then
            return CCSizeMake(tvW, 137)
        elseif fn == "tableCellAtIndex" then
            local cell = CCTableViewCell:new()
            cell:autorelease()
            
            for k, v in pairs(roleTb) do
                local childTb
                if k > 6 then
                    childTb = {{pic = "creatRole_kuang.png", tag = 1, order = 2, size = 100}, {pic = v.icon, tag = 2, order = 1, size = 95}}
                else
                    childTb = {{pic = "creatRole_kuang.png", tag = 1, order = 3, size = 100}, {pic = "newPhotoBg.png", tag = 2, order = 1, size = 95}, {pic = v.icon, tag = 3, order = 2, size = 95}}
                end
                local selectBg = G_getComposeIcon(touchSelectHero, CCSizeMake(100, 100), childTb)
                
                cell:addChild(selectBg)
                selectBg:setPositionY(137 / 2)
                selectBg:setTag(k)
                setPostionXCallback(selectBg, roleType)
                selectBg:setTouchPriority(-(layerNum - 1) * 20 - 2)
                selectSpTb[k] = selectBg
                if roleType == k then
                    selectBg:setScale(120 / selectBg:getContentSize().height)
                    local child = tolua.cast(selectBg:getChildByTag(1), "CCSprite")
                    child:setOpacity(0)
                end
            end
            
            tagetSelect = CCSprite:createWithSpriteFrameName("creatRole_kuang_select.png")
            cell:addChild(tagetSelect, 1)
            tagetSelect:setPosition(tvW / 2, 137 / 2)
            tagetSelect:setScale(120 / tagetSelect:getContentSize().height)
            
            local guangSelect = CCSprite:createWithSpriteFrameName("creatRole_kuang_guang.png")
            tagetSelect:addChild(guangSelect, 1)
            guangSelect:setPosition(getCenterPoint(tagetSelect))
            guangSelect:setScale(0.9)
            
            return cell
        elseif fn == "ccTouchBegan" then
            return true
        elseif fn == "ccTouchMoved" then
        elseif fn == "ccTouchEnded" then
        end
    end
    local hd = LuaEventHandler:createHandler(eventHandler)
    local selectTv = LuaCCTableView:createHorizontalWithEventHandler(hd, CCSizeMake(tvW, 137), nil)
    -- selectTv:setTableViewTouchPriority(-(layerNum-1)*20-1)
    selectTv:setPosition(ccp((bgSp:getContentSize().width - tvW) / 2, selectBgH))
    selectTv:setMaxDisToBottomOrTop(0)
    bgSp:addChild(selectTv, 2)
    
    local list = {}
    local dlist = {}
    require "luascript/script/game/scene/gamedialog/creatRolePage"
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    for i = 1, #roleTb do
        local bagPage = creatRolePage:new()
        local iconScale = bigIconScale
        local iconH = bigIconH
        if i == 7 or i == 8 then
            if G_isIphone5() then
                iconScale = 1.4
            else
                iconH = 620
                iconScale = 1.2
            end
        end
        
        local bagLayer = bagPage:init(roleTb[i].img, iconScale, iconH)
        bgSp:addChild(bagLayer)
        list[i] = bagLayer
        dlist[i] = bagPage
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    
    creatPage = pageDialog:new()
    local page = roleType
    local isShowBg = false
    local isShowPageBtn = false
    
    local function onPage(topage)
        -- print("topage++++",topage)
        page = topage
        roleType = page
        for k, v in pairs(selectSpTb) do
            setPostionXCallback(v, topage)
        end
        
    end
    local function movedCallback(turnType, isTouch)
        return true
    end
    
    local posY = 300
    -- local startH=diBg:getPositionY()+diBg:getContentSize().height+centerBg1:getContentSize().height
    local startH = diBg:getPositionY() + diBg:getContentSize().height
    
    local touchRect = {x = bgSp:getContentSize().width / 2, y = startH + (bgSp:getContentSize().height - startH) / 2, width = bgSp:getContentSize().width, height = bgSp:getContentSize().height - startH}
    
    local leftBtnPos = ccp(60, posY)
    local rightBtnPos = ccp(bgSp:getContentSize().width - 60, posY)
    local pageLayer = creatPage:create("panelItemBg.png", CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight), CCRect(20, 20, 10, 10), bgSp, ccp(0, 0), layerNum, page, list, isShowBg, isShowPageBtn, onPage, leftBtnPos, rightBtnPos, movedCallback, -(layerNum - 1) * 20 - 3, touchRect, "vipArrow.png", true, nil, 50, true)
    
    local function tthandler()
        
    end
    local function callBackXHandler(fn, eB, str)
        if str ~= nil then
            roleName = str;
            roleName = G_stringGsub(roleName, " ", "")
            if self.clickHereTipLabel ~= nil then
                self.clickHereTipLabel:setVisible(false)
            end
        end
    end
    
    local subH = 0
    if G_isIphone5() == false then
        subH = 25
    end
    -- local nameBox=LuaCCScale9Sprite:createWithSpriteFrameName("creatRole2.png",CCRect(131,26,1,1),tthandler)
    local nameBox = CCSprite:createWithSpriteFrameName("creatRole2.png")
    -- nameBox:setContentSize(CCSize(420,80))
    nameBox:setPosition(ccp(bgSp:getContentSize().width / 2, 220 - subH))
    bgSp:addChild(nameBox)
    
    local targetBoxLabel = GetTTFLabel("", 30)
    targetBoxLabel:setAnchorPoint(ccp(0.5, 0.5))
    targetBoxLabel:setPosition(ccp(nameBox:getContentSize().width / 2, nameBox:getContentSize().height / 2))
    local customEditBox = customEditBox:new()
    local length = 20
    customEditBox:init(nameBox, targetBoxLabel, "creatRole2.png", nil, (-(layerNum - 1) * 20 - 2), length, callBackXHandler, nil, nil)
    
    if platCfg.platCfgShowDefaultRoleName[G_curPlatName()] == nil then
        --这里开始
        
        local tipLabel = GetTTFLabel(getlocal("limitLength", {12}), 26)
        tipLabel:setAnchorPoint(ccp(0.5, 1))
        tipLabel:setPosition(ccp(bgSp:getContentSize().width / 2, 185 - subH))
        bgSp:addChild(tipLabel, 2)
        tipLabel:setColor(G_ColorRed)
        
        self.clickHereTipLabel = GetTTFLabel("点击这里输入名称", 30)
        self.clickHereTipLabel:setAnchorPoint(ccp(0.5, 0.5))
        self.clickHereTipLabel:setPosition(ccp(bgSp:getContentSize().width / 2, 220 - subH))
        bgSp:addChild(self.clickHereTipLabel, 10)
        self.clickHereTipLabel:setColor(G_ColorYellow)
        
        -- local cannotInputLabel=GetTTFLabel(getlocal("cannotInput"),26)
        -- cannotInputLabel:setAnchorPoint(ccp(0,1))
        -- cannotInputLabel:setPosition(ccp(bgSp:getContentSize().width/2-20,185-subH))
        -- bgSp:addChild(cannotInputLabel,2)
        -- cannotInputLabel:setColor(G_ColorGreen)
        
        --     local clickHereLabel=GetTTFLabel(getlocal("clickHere"),26)
        -- clickHereLabel:setAnchorPoint(ccp(0,1))
        -- clickHereLabel:setPosition(ccp(bgSp:getContentSize().width/2+108,185-subH))
        -- bgSp:addChild(clickHereLabel,2)
        -- clickHereLabel:setColor(G_ColorGreen)
        
        local male1 = {"阿波", "阿道", "阿尔", "阿姆", "阿诺", "阿奇", "埃达", "埃德", "埃迪", "埃尔", "埃里", "埃玛", "埃文", "艾比", "艾伯", "艾布", "艾丹", "艾德", "艾登", "艾尔", "艾富", "艾理", "艾伦", "艾略", "艾谱", "艾萨", "艾塞", "艾丝", "艾文", "艾西", "爱得", "爱德", "爱迪", "爱尔", "爱格", "爱莉", "爱罗", "爱曼", "安得", "安德", "安迪", "安东", "安格", "安纳", "安其", "安斯", "奥布", "奥德", "奥尔", "奥古", "奥劳", "奥利", "奥斯", "奥特", "巴德", "巴顿", "巴尔", "巴克", "巴里", "巴伦", "巴罗", "巴奈", "巴萨", "巴特", "巴泽", "柏得", "柏德", "柏格", "柏塔", "柏特", "柏宜", "拜尔", "拜伦", "班克", "班奈", "班尼", "宝儿", "保罗", "鲍比", "鲍伯", "贝尔", "贝克", "贝齐", "本恩", "本杰", "本森", "比尔", "比利", "比其", "彼得", "毕维", "毕夏", "宾尔", "波顿", "波特", "波文", "伯顿", "伯恩", "伯里", "伯尼"}
        local male2 = {"伯特", "博格", "布德", "布拉", "布莱", "布赖", "布兰", "布朗", "布雷", "布里", "布鲁", "布伦", "布尼", "布兹", "采尼", "查德", "查尔", "达尔", "达伦", "达尼", "大卫", "戴夫", "戴纳", "丹尼", "丹普", "道格", "得利", "德博", "德尔", "德里", "德维", "德文", "邓肯", "狄克", "迪得", "迪恩", "迪克", "迪伦", "迪姆", "迪斯", "蒂安", "蒂莫", "杜克", "杜鲁", "多夫", "多洛", "多明", "尔德", "尔特", "范尼", "菲比", "菲蕾", "菲力", "菲利", "菲兹", "斐迪", "费恩", "费力", "费奇", "费兹", "费滋", "佛里", "夫兰", "弗德", "弗恩", "弗兰", "弗朗", "弗莉", "弗罗", "弗农", "弗瑞", "福特", "富宾", "富兰", "盖尔", "盖克", "高达", "高德", "戈登", "格吉", "格拉", "格里", "格林", "格罗", "格纳", "葛里", "葛列", "葛瑞", "古斯", "哈帝", "哈乐", "哈里", "哈利", "哈伦", "哈瑞", "哈威", "海顿", "海勒", "海洛", "海曼"}
        local male3 = {"韩弗", "汉克", "汉米", "汉姆", "汉特", "赫伯", "赫达", "赫尔", "赫瑟", "亨利", "华纳", "霍伯", "霍尔", "霍根", "霍华", "基诺", "吉伯", "吉蒂", "吉恩", "吉罗", "吉米", "吉姆", "吉榭", "加百", "加比", "加尔", "加菲", "加里", "加文", "迦勒", "迦利", "嘉比", "贾艾", "贾斯", "杰弗", "杰克", "杰奎", "杰拉", "杰罗", "杰农", "杰瑞", "杰西", "杰伊", "捷勒", "卡尔", "卡萝", "卡洛", "卡玛", "卡梅", "卡斯", "卡特", "凯尔", "凯里", "凯理", "凯伦", "凯撒", "凯斯", "凯文", "凯希", "凯伊", "康拉", "康那", "康奈", "康斯", "考伯", "考尔", "柯帝", "柯利", "科迪", "科尔", "科林", "科兹", "克拉", "克莱", "克劳", "克雷", "克里", "克利", "克林", "克洛", "克思", "克斯", "肯姆", "肯尼", "寇里", "昆廷", "拉丁", "拉罕", "拉里", "拉斯", "莱德", "莱姆", "莱斯", "赖安", "兰德", "兰迪", "兰斯", "兰特", "劳伦", "劳瑞"}
        
        if platCfg.platCfgDefaultLocal[G_curPlatName()] == "tw" then
            male1 = {"阿波", "阿道", "阿爾", "阿姆", "阿諾", "阿奇", "埃達", "埃德", "埃迪", "埃爾", "埃裏", "埃瑪", "埃文", "艾比", "艾伯", "艾布", "艾丹", "艾德", "艾登", "艾爾", "艾富", "艾理", "艾倫", "艾略", "艾譜", "艾薩", "艾塞", "艾絲", "艾文", "艾西", "愛得", "愛德", "愛迪", "愛爾", "愛格", "愛莉", "愛羅", "愛曼", "安得", "安德", "安迪", "安東", "安格", "安納", "安其", "安斯", "奧布", "奧德", "奧爾", "奧古", "奧勞", "奧利", "奧斯", "奧特", "巴德", "巴頓", "巴爾", "巴克", "巴裏", "巴倫", "巴羅", "巴奈", "巴薩", "巴特", "巴澤", "柏得", "柏德", "柏格", "柏塔", "柏特", "柏宜", "拜爾", "拜倫", "班克", "班奈", "班尼", "寶兒", "保羅", "鮑比", "鮑伯", "貝爾", "貝克", "貝齊", "本恩", "本傑", "本森", "比爾", "比利", "比其", "彼得", "畢維", "畢夏", "賓爾", "波頓", "波特", "波文", "伯頓", "伯恩", "伯裏", "伯尼"}
            male2 = {"伯特", "博格", "布德", "布拉", "布萊", "布賴", "布蘭", "布朗", "布雷", "布裏", "布魯", "布倫", "布尼", "布茲", "采尼", "查德", "查爾", "達爾", "達倫", "達尼", "大衛", "戴夫", "戴納", "丹尼", "丹普", "道格", "得利", "德博", "德爾", "德裏", "德維", "德文", "鄧肯", "狄克", "迪得", "迪恩", "迪克", "迪倫", "迪姆", "迪斯", "蒂安", "蒂莫", "杜克", "杜魯", "多夫", "多洛", "多明", "爾德", "爾特", "範尼", "菲比", "菲蕾", "菲力", "菲利", "菲茲", "斐迪", "費恩", "費力", "費奇", "費茲", "費滋", "佛裏", "夫蘭", "弗德", "弗恩", "弗蘭", "弗朗", "弗莉", "弗羅", "弗農", "弗瑞", "福特", "富賓", "富蘭", "蓋爾", "蓋克", "高達", "高德", "戈登", "格吉", "格拉", "格裏", "格林", "格羅", "格納", "葛裏", "葛列", "葛瑞", "古斯", "哈帝", "哈樂", "哈裏", "哈利", "哈倫", "哈瑞", "哈威", "海頓", "海勒", "海洛", "海曼"}
            male3 = {"韓弗", "漢克", "漢米", "漢姆", "漢特", "赫伯", "赫達", "赫爾", "赫瑟", "亨利", "華納", "霍伯", "霍爾", "霍根", "霍華", "基諾", "吉伯", "吉蒂", "吉恩", "吉羅", "吉米", "吉姆", "吉榭", "加百", "加比", "加爾", "加菲", "加裏", "加文", "迦勒", "迦利", "嘉比", "賈艾", "賈斯", "傑弗", "傑克", "傑奎", "傑拉", "傑羅", "傑農", "傑瑞", "傑西", "傑伊", "捷勒", "卡爾", "卡蘿", "卡洛", "卡瑪", "卡梅", "卡斯", "卡特", "凱爾", "凱裏", "凱理", "凱倫", "凱撒", "凱斯", "凱文", "凱希", "凱伊", "康拉", "康那", "康奈", "康斯", "考伯", "考爾", "柯帝", "柯利", "科迪", "科爾", "科林", "科茲", "克拉", "克萊", "克勞", "克雷", "克裏", "克利", "克林", "克洛", "克思", "克斯", "肯姆", "肯尼", "寇裏", "昆廷", "拉丁", "拉罕", "拉裏", "拉斯", "萊德", "萊姆", "萊斯", "賴安", "蘭德", "蘭迪", "蘭斯", "蘭特", "勞倫", "勞瑞"}
        end
        local helpmebtn
        local function randRoleName(tag, object, sb1, sb2, flag)
            --roleName="克里斯来看看"
            --targetBoxLabel:setString(roleName)
            if not flag then
                local scaleAc1 = CCScaleTo:create(0.1, 0.9)
                local scaleAc2 = CCScaleTo:create(0.1, 1)
                local seq = CCSequence:createWithTwoActions(scaleAc1, scaleAc2)
                helpmebtn:runAction(seq)
            end
            
            self.clickHereTipLabel:setVisible(false)
            local orderTb = {}
            local maleT = deviceHelper:getRandom()
            if maleT <= 33 then
                orderTb[1] = male1
                orderTb[2] = male2
                orderTb[3] = male3
            elseif maleT > 66 then
                orderTb[1] = male3
                orderTb[2] = male1
                orderTb[3] = male2
            else
                orderTb[1] = male2
                orderTb[2] = male3
                orderTb[3] = male1
            end
            local rand1 = deviceHelper:getRandom()
            local rand2 = deviceHelper:getRandom()
            local rand3 = deviceHelper:getRandom()
            local realName = orderTb[1][rand1 == 0 and 1 or rand1]..orderTb[2][rand2 == 0 and 1 or rand2]..orderTb[3][rand3 == 0 and 1 or rand3]
            roleName = realName
            targetBoxLabel:setString(realName)
        end
        helpmebtn = GetButtonItem("DiceBtn.png", "DiceBtn.png", "DiceBtn.png", randRoleName, nil, nil, 25)
        -- helpmebtn:setOpacity(0)
        helpmebtn:registerScriptTapHandler(randRoleName)
        local helpmeMenu = CCMenu:createWithItem(helpmebtn);
        helpmeMenu:setPosition(ccp(bgSp:getContentSize().width / 2 + 200, 220 - subH))
        helpmeMenu:setTouchPriority(-(layerNum - 1) * 20 - 4);
        bgSp:addChild(helpmeMenu, 1)
        
        randRoleName(nil, nil, nil, nil, true)
        ---这里结束
    else
        local tipLabel = GetTTFLabel(getlocal("limitLength", {12}), 26)
        tipLabel:setAnchorPoint(ccp(0.5, 1))
        tipLabel:setPosition(ccp(bgSp:getContentSize().width / 2, 185 - subH))
        bgSp:addChild(tipLabel, 2)
        tipLabel:setColor(G_ColorRed)
    end
    
    if platCfg.platNewGuideNMChose[G_curPlatName()] ~= nil then
        require "luascript/script/config/gameconfig/nameCfg"
        local diceBtnSp
        local function randomName(tag, object, sb1, sb2, flag)
            if not flag then
                local scaleAc1 = CCScaleTo:create(0.1, 0.9)
                local scaleAc2 = CCScaleTo:create(0.1, 1)
                local seq = CCSequence:createWithTwoActions(scaleAc1, scaleAc2)
                diceBtnSp:runAction(seq)
            end
            if G_getCurChoseLanguage() == "en" then
                local name1 = nmNameCfg[math.random(1, 800)]
                local name2 = nmNameCfg[math.random(1, 800)]
                
                roleName = name1.."-"..name2
                targetBoxLabel:setString(name1.."-"..name2)
                
            elseif G_getCurChoseLanguage() == "pt" then
                
                if roleType == 1 or roleType == 3 or roleType == 5 then
                    local name1 = nmNameCfg1[math.random(1, 400)]
                    local name2 = nmFirstNameCfg[math.random(1, 398)]
                    roleName = name1.."-"..name2
                    targetBoxLabel:setString(name1.."-"..name2)
                elseif roleType == 2 or roleType == 4 or roleType == 6 then
                    local name1 = nmNameCfg2[math.random(1, 400)]
                    local name2 = nmFirstNameCfg[math.random(1, 398)]
                    roleName = name1.."-"..name2
                    targetBoxLabel:setString(name1.."-"..name2)
                end
                
            end
        end
        randomName(nil, nil, nil, nil, true)
        
        local function pbUIhandler()
            randomName()
        end
        diceBtnSp = LuaCCSprite:createWithSpriteFrameName("DiceBtn.png", pbUIhandler)
        diceBtnSp:setIsSallow(true)
        diceBtnSp:setTouchPriority(-(layerNum - 1) * 20 - 4)
        diceBtnSp:setAnchorPoint(ccp(0.5, 0.5));
        diceBtnSp:setPosition(bgSp:getContentSize().width / 2 + 200, 220 - subH);
        -- diceBtnSp:setScale(0.9)
        bgSp:addChild(diceBtnSp, 13);
        nameBox:setPosition(ccp(bgSp:getContentSize().width / 2, 220 - subH))
        
    end
    
    local function createRole()
        
        local count = G_utfstrlen(roleName, true)
        if platCfg.platCfgKeyWord[G_curPlatName()] ~= nil then --设置屏蔽字
            if keyWordCfg:keyWordsJudge(roleName) == false then
                do
                    return
                end
            end
        end
        if G_match(roleName) ~= nil then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("alliance_illegalCharacters"), true, 20, G_ColorRed)
            do
                return
            end
        end
        print("roleName=", roleName)
        if string.find(roleName, ' ') ~= nil then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("blankCharacter"), true, 20, G_ColorRed)
            do
                return
            end
        end
        
        local strFisrt = G_stringGetAt(roleName, 0, 1)
        if tonumber(strFisrt) ~= nil then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("firstCharNoNum"), true, 20, G_ColorRed)
            do
                return
            end
        end
        
        if roleName == "" then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("nameNullCharacter"), true, 20, G_ColorRed)
            do
                return
            end
        end
        if count > 12 then
            
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("namelengthwrong"), true, 20, G_ColorRed)
        elseif count < 3 then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("roleNameMinLen"), true, 20, G_ColorRed)
            
        else
            local function serverUserSigupHandler(fn, data)
                --local sData=G_Json.decode(data)
                local result, sData = base:checkServerData(data, false)
                if tonumber(sData.ret) >= 0 and tonumber(sData.uid) > 0 then --登记角色名,选择头像成功
                    bgSp:removeFromParentAndCleanup(true)
                    if newGuidMgr.curBMStep ~= nil then
                        newGuidMgr.curBMStep = 6
                    end
                    
                    self.mySpriteLeft:getChildByTag(767):removeFromParentAndCleanup(true)
                    --local personPhotoName="photo"..roleType..".png"
                    --local personPhoto = CCSprite:createWithSpriteFrameName(personPhotoName);
                    local pic = roleTb[roleType].type
                    local personPhoto = playerVoApi:getPersonPhotoSp(pic)
                    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                        personPhoto:setAnchorPoint(ccp(0.5, 0.5));
                        personPhoto:setPosition(ccp(42, self.mySpriteLeft:getContentSize().height / 2));
                    else
                        personPhoto:setAnchorPoint(ccp(0.5,1))
                        personPhoto:setScale(1.1)
                        personPhoto:setPosition(ccp(self.mySpriteLeft:getContentSize().width / 2, self.mySpriteLeft:getContentSize().height-12));
                    end
                    personPhoto:setTag(767)
                    self.mySpriteLeft:addChild(personPhoto, 5);
                    G_cancleLoginLoading()
                    newGuidMgr:toNextStep()
                else
                    
                    smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("namehasbeenused"), true, 20, G_ColorRed)
                    G_cancleLoginLoading() --注册角色名失败 取消loading
                end
                
            end
            G_showLoginLoading() --加loading
            if newGuidMgr.curBMStep ~= nil then
                newGuidMgr.curBMStep = 7
            end
            socketHelper:userRename(roleName, roleTb[roleType].type, serverUserSigupHandler)
        end
    end
    local menuItemCreate = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", createRole, nil, getlocal("createRole"), 28);
    
    local createBtn = CCMenu:createWithItem(menuItemCreate)
    createBtn:setTouchPriority(-(layerNum - 1) * 20 - 4)
    createBtn:setPosition(ccp(bgSp:getContentSize().width / 2, 100 - subH))
    bgSp:addChild(createBtn)
    
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    
end

--世界地图上面的小地图
function mainUI:addMiniMap()
    local function onShowMap()
        local tmpBtn = tolua.cast(self.mySpriteWorld:getChildByTag(512), "CCMenu")
        local tmpMap = tolua.cast(self.mySpriteWorld:getChildByTag(513), "CCSprite")
        if(tmpBtn and tmpMap)then
            if(tmpMap:isVisible())then
                self:showMiniMap(tmpBtn, tmpMap, false, self.rotateChild)
            else
                self:showMiniMap(tmpBtn, tmpMap, true, self.rotateChild)
            end
        end
    end
    -- miniMapBtn_down
    local mapBtn = GetButtonItem("miniMapBtn2.png", "miniMapBtn2_down.png", "miniMapBtn2_down.png", onShowMap, nil, nil, nil)
    -- miniMapBtn2_pointer
    local rotateChild = CCSprite:createWithSpriteFrameName("miniMapBtn2_pointer.png")
    mapBtn:addChild(rotateChild)
    self.rotateChild = rotateChild
    local centerPoint = getCenterPoint(rotateChild)
    rotateChild:setPosition(centerPoint.x, centerPoint.y)
    local mapMenu = CCMenu:createWithItem(mapBtn)
    mapMenu:setPosition(ccp(G_VisibleSizeWidth, -G_VisibleSizeHeight + 355))
    mapMenu:setTouchPriority(-25)
    mapMenu:setTag(512)
    self.mySpriteWorld:addChild(mapMenu, 1)
    
    local function onClickMiniMap(object, fn, tag)
        -- body
    end
    local miniMap = LuaCCSprite:createWithSpriteFrameName("miniMapNew.png", onClickMiniMap)
    miniMap:setAnchorPoint(ccp(1, 0))
    miniMap:setPosition(ccp(999333, -G_VisibleSizeHeight + 315))
    miniMap:setVisible(false)
    miniMap:setTouchPriority(-25)
    miniMap:setTag(513)
    self.miniMap = miniMap
    
    self.mySpriteWorld:addChild(miniMap)
    local mapSetting = CCUserDefault:sharedUserDefault():getIntegerForKey("gameSettings_miniMapSetting")
    if(mapSetting == 1)then
        mapMenu:setPositionX(999333)
        mapMenu:setVisible(false)
    end
    
    local miniMapSize = miniMap:getContentSize()
    
    -- 在miniMap 上贴一层获得触摸点
    local clayer = CCLayerColor:create(ccc4(0, 0, 0, 0))
    
    clayer:setTouchEnabled(true)
    clayer:setTouchPriority(-26)
    -- clayer:setBSwallowsTouches(false)
    local function tmpHandler(fn, x, y, touch)
        if G_isMemoryServer() == true then
            do return end
        end
        if(self.m_menuToggle == nil or tolua.cast(self.m_menuToggle, "CCMenuItemToggle") == nil)then
            do return end
        end
        if self.m_menuToggle:getSelectedIndex() == 2 and miniMap:isVisible() then
            if fn == "began" then
                return 1
            elseif fn == "ended" then
                local point = miniMap:convertToNodeSpace(ccp(x, y))
                if point.x > 0 and point.x < miniMapSize.width and point.y > 0 and point.y < miniMapSize.height then
                    local posX = math.floor(point.x / miniMapSize.width * G_maxMapx)
                    local posY = math.floor((miniMapSize.height - point.y) / miniMapSize.height * G_maxMapy)
                    if posX == 0 then
                        posX = G_minMapx
                    end
                    if posY == 0 then
                        posY = G_minMapy
                    end
                    if posX > G_maxMapx then
                        posX = G_maxMapx
                    end
                    if posY > G_maxMapy then
                        posY = G_maxMapy
                    end
                    worldScene:focus(posX, posY)
                end
                
            end
        end
        
    end
    clayer:registerScriptTouchHandler(tmpHandler, false, -26, false)
    clayer:setPosition(0, 0)
    miniMap:addChild(clayer)
    clayer:setContentSize(miniMap:getContentSize())
    -- 添加地图边装饰
    local decorationSp = CCSprite:createWithSpriteFrameName("miniMapNew_ decoration.png")
    miniMap:addChild(decorationSp)
    decorationSp:setPosition(miniMapSize.width + 10, decorationSp:getContentSize().height / 2 - 5)
    
    -- 添加东南西北
    local posTb = {{"W", ccp(20, miniMapSize.height / 2)}, {"S", ccp(miniMapSize.width / 2, 20)}, {"E", ccp(miniMapSize.width - 20, miniMapSize.height / 2)}, {"N", ccp(miniMapSize.width / 2, miniMapSize.height - 20)}}
    for k, v in pairs(posTb) do
        local directionLb = GetTTFLabel(v[1], 22)
        miniMap:addChild(directionLb)
        directionLb:setPosition(v[2])
        directionLb:setColor(G_ColorGreen)
    end
    
    -- 添加上一次定位位置
    local function onClickLastPos()
        if G_isMemoryServer() == true then
            do return end
        end
        local placeDataTab = satelliteSearchVoApi:getLastPos()
        if placeDataTab then
            local view = tolua.cast(miniMap:getChildByTag(515), "CCSprite")
            worldScene:focus(placeDataTab.x, placeDataTab.y, true)
            if view then
                local posX = placeDataTab.x / G_maxMapx * miniMapSize.width
                local posY = miniMapSize.height - placeDataTab.y / G_maxMapy * miniMapSize.height
                view:setPosition(posX + 1, posY)
            end
        end
    end
    local laskPSp = LuaCCSprite:createWithSpriteFrameName("miniMapNew_locate1.png", onClickLastPos)
    laskPSp:setTouchPriority(-26)
    miniMap:addChild(laskPSp, 4)
    laskPSp:setAnchorPoint(ccp(0.5, 0))
    laskPSp:setPosition(99939, 99939)
    self.laskPSp = laskPSp
    
    local placeDataTab = satelliteSearchVoApi:getLastPos()
    if placeDataTab then
        local posX = placeDataTab.x / G_maxMapx * miniMapSize.width
        local posY = miniMapSize.height - placeDataTab.y / G_maxMapy * miniMapSize.height
        laskPSp:setPosition(posX, posY)
    end
    
    local function gpsCallback(pos)
        local posX = pos[1] / G_maxMapx * miniMapSize.width
        local posY = miniMapSize.height - pos[2] / G_maxMapy * miniMapSize.height
        laskPSp:setPosition(posX, posY)
        worldScene:focus(pos[1], pos[2], true)
    end
    -- 添加卫星搜索按钮
    local function onShowSearchDialog()
        if G_checkClickEnable() == false then
            do
                return
            end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        
        local function showSearchDialog()
            local title = getlocal("satelliteSearch")
            satelliteSearchVoApi:showSearchDialog("TankInforPanel.png", CCSizeMake(570, 720), CCRect(0, 0, 400, 350), CCRect(130, 50, 1, 1), true, 3, title, gpsCallback)
        end
        
        local cmdStr = "map.worldsearch.info"
        satelliteSearchVoApi:mapWorldSearch(cmdStr, nil, nil, nil, showSearchDialog)
        
    end
    local searchBtn = GetButtonItem("miniMapBtn_search.png", "miniMapBtn_search_down.png", "miniMapBtn_search_down.png", onShowSearchDialog, nil, nil, nil)
    local searchMenu = CCMenu:createWithItem(searchBtn)
    searchMenu:setPosition(ccp(miniMapSize.width + searchBtn:getContentSize().width / 2, miniMapSize.height / 2 - 32))
    searchMenu:setTouchPriority(-26)
    miniMap:addChild(searchMenu)
    
    -- 扩大点击区域
    local sbBigSp = LuaCCSprite:createWithSpriteFrameName("miniMapNew.png", onShowSearchDialog)
    sbBigSp:setScaleX(80 / sbBigSp:getContentSize().width)
    sbBigSp:setScale(100 / sbBigSp:getContentSize().height)
    -- sbBigSp:setContentSize(CCSizeMake(100,150))
    sbBigSp:setAnchorPoint(ccp(0, 0))
    sbBigSp:setPosition(0, 0)
    sbBigSp:setTouchPriority(-25)
    searchBtn:addChild(sbBigSp)
    sbBigSp:setVisible(false)
    
    local mapSize = miniMap:getContentSize()
    local mapBorderWidth = 6
    local mapRealHeight = mapSize.height - mapBorderWidth * 2
    local mapRealWidth = mapSize.width - mapBorderWidth * 2
    local myPoint = CCSprite:createWithSpriteFrameName("miniMapLocation.png")
    myPoint:setTag(514)
    myPoint:setPosition(ccp(playerVoApi:getMapX() / G_maxMapx * mapRealWidth + mapBorderWidth, mapSize.height - mapBorderWidth - playerVoApi:getMapY() / G_maxMapy * mapRealHeight))
    miniMap:addChild(myPoint, 3)
    
    local eagleEyePos = skillVoApi:getEagleEyePos()
    if(eagleEyePos)then
        local minePoint
        if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
            minePoint = CCSprite:createWithSpriteFrameName("NumBg.png")
        else
            minePoint = CCSprite:createWithSpriteFrameName("NumBg1.png")
        end
        minePoint:setTag(516)
        minePoint:setScale(0.4)
        minePoint:setPosition(ccp(eagleEyePos[1] / G_maxMapx * mapRealWidth + mapBorderWidth, mapSize.height - mapBorderWidth - eagleEyePos[2] / G_maxMapy * mapRealHeight))
        miniMap:addChild(minePoint, 2)
    end
    
    mapRealWidth = mapSize.width - mapBorderWidth * 2
    mapRealHeight = mapSize.height - mapBorderWidth * 2
    local myView = CCSprite:createWithSpriteFrameName("miniMapBtn_select.png")
    myView:setTag(515)
    local viewSize = myView:getContentSize()
    local posX = playerVoApi:getMapX() / G_maxMapx * mapRealWidth + mapBorderWidth
    if(posX + viewSize.width / 2 > mapRealWidth + mapBorderWidth)then
        posX = mapBorderWidth + mapRealWidth - viewSize.width / 2
    elseif(posX - viewSize.width / 2 < mapBorderWidth)then
        posX = mapBorderWidth + viewSize.width / 2
    end
    local posY = mapSize.height - (playerVoApi:getMapY() / G_maxMapy * mapRealHeight + mapBorderWidth)
    if(posY + viewSize.height / 2 > mapRealHeight + mapBorderWidth)then
        posY = mapSize.height - mapBorderWidth - viewSize.height / 2
    elseif(posY - viewSize.height / 2 < mapBorderWidth)then
        posY = mapBorderWidth + viewSize.height / 2
    end
    myView:setPosition(ccp(posX, posY))
    miniMap:addChild(myView, 5)
    local function onBaseMove(event, data)
        self:myBaseMove()
    end
    self.baseMoveListener = onBaseMove
    eventDispatcher:addEventListener("user.basemove", onBaseMove)
    local function onEagleEyeChange(event, data)
        local tmpMap = tolua.cast(self.mySpriteWorld:getChildByTag(513), "CCSprite")
        if(tmpMap)then
            local tmpPoint = tolua.cast(tmpMap:getChildByTag(516), "CCSprite")
            if(tmpPoint)then
                tmpPoint:removeFromParentAndCleanup(true)
            end
            local eagleEyePos = skillVoApi:getEagleEyePos()
            if(eagleEyePos)then
                local minePoint
                if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                    minePoint = CCSprite:createWithSpriteFrameName("NumBg.png")
                else
                    minePoint = CCSprite:createWithSpriteFrameName("NumBg1.png")
                end
                minePoint:setTag(516)
                minePoint:setScale(0.4)
                minePoint:setPosition(ccp(eagleEyePos[1] / G_maxMapx * mapRealWidth + mapBorderWidth, mapSize.height - mapBorderWidth - eagleEyePos[2] / G_maxMapy * mapRealHeight))
                tmpMap:addChild(minePoint, 2)
            end
        end
    end
    self.eagleEyeListener = onEagleEyeChange
    eventDispatcher:addEventListener("skill.eagleeye.change", onEagleEyeChange)
end

--根据设置，显示或者不显示小地图
--param visible: true or false, 是否显示
function mainUI:switchMiniMap(visible)
    local tmpBtn = tolua.cast(self.mySpriteWorld:getChildByTag(512), "CCMenu")
    local tmpMap = tolua.cast(self.mySpriteWorld:getChildByTag(513), "CCSprite")
    if(tmpBtn and tmpMap)then
        tmpBtn:stopAllActions()
        tmpMap:stopAllActions()
        tmpMap:setPositionX(999333)
        tmpMap:setVisible(false)
        if(visible)then
            tmpBtn:setPositionX(G_VisibleSizeWidth)
            tmpBtn:setVisible(true)
        else
            tmpBtn:setPositionX(999333)
            tmpBtn:setVisible(false)
        end
    end
end

--点击按钮, 显示或者隐藏小地图
--param btn 地图按钮
--param map 地图
--param isShow: true or false, true是显示, false是隐藏
-- childRotate 按钮上半圈
function mainUI:showMiniMap(btn, map, isShow, rotateChild)
    btn:stopAllActions()
    map:stopAllActions()
    if(isShow)then
        map:setScale(0.1)
        map:setPositionX(999333)
        btn:setPositionX(G_VisibleSizeWidth)
        local function onBtnShow()
            map:setVisible(true)
            map:setPositionX(G_VisibleSizeWidth - 80)
            local scaleTo = CCScaleTo:create(0.3, 1)
            local acArr2 = CCArray:create()
            acArr2:addObject(scaleTo)
            local seq2 = CCSequence:create(acArr2)
            map:runAction(seq2)
        end
        local callFunc = CCCallFunc:create(onBtnShow)
        local moveTo = CCMoveTo:create(0.2, CCPointMake(G_VisibleSizeWidth - 44, -G_VisibleSizeHeight + 355))
        
        local function rotateFunc()
            local rotateT1 = CCRotateBy:create(0.2, 360)
            local rotateT2 = CCRotateBy:create(0.5, 360)
            local seq = CCSequence:createWithTwoActions(rotateT1, rotateT2)
            rotateChild:runAction(seq)
        end
        local callFunc2 = CCCallFunc:create(rotateFunc)
        local delayAc = CCDelayTime:create(0.2)
        
        local acArr = CCArray:create()
        acArr:addObject(moveTo)
        acArr:addObject(callFunc2)
        acArr:addObject(delayAc)
        acArr:addObject(callFunc)
        local seq = CCSequence:create(acArr)
        btn:runAction(seq)
        
    else
        map:setScale(1)
        map:setPositionX(G_VisibleSizeWidth - 80)
        btn:setPositionX(G_VisibleSizeWidth - 44)
        local function onMapHide()
            map:setVisible(false)
            map:setPositionX(999333)
            local moveTo = CCMoveTo:create(0.2, CCPointMake(G_VisibleSizeWidth, -G_VisibleSizeHeight + 355))
            local acArr2 = CCArray:create()
            acArr2:addObject(moveTo)
            local seq2 = CCSequence:create(acArr2)
            btn:runAction(seq2)
        end
        local callFunc = CCCallFunc:create(onMapHide)
        local scaleTo = CCScaleTo:create(0.3, 0.1)
        local acArr = CCArray:create()
        acArr:addObject(scaleTo)
        acArr:addObject(callFunc)
        local seq = CCSequence:create(acArr)
        map:runAction(seq)
        
    end
end

--拖动世界地图, 小地图上的框跟着动
function mainUI:worldLandMove(point)
    local tmpMap = tolua.cast(self.mySpriteWorld:getChildByTag(513), "CCSprite")
    if(tmpMap)then
        local view = tolua.cast(tmpMap:getChildByTag(515), "CCSprite")
        if(view)then
            local mapSize = tmpMap:getContentSize()
            local mapBorderWidth = 6
            local mapRealWidth = mapSize.width - mapBorderWidth * 2
            local mapRealHeight = mapSize.height - mapBorderWidth * 2
            local viewSize = view:getContentSize()
            local posX = point.x / G_maxMapx * mapRealWidth + mapBorderWidth
            local posY = mapSize.height - (point.y / G_maxMapy * mapRealHeight + mapBorderWidth)
            if(posX + viewSize.width / 2 > mapRealWidth + mapBorderWidth)then
                posX = mapBorderWidth + mapRealWidth - viewSize.width / 2
            elseif(posX - viewSize.width / 2 < mapBorderWidth)then
                posX = mapBorderWidth + viewSize.width / 2
            end
            if(posY + viewSize.height / 2 > mapRealHeight + mapBorderWidth)then
                posY = mapSize.height - mapBorderWidth - viewSize.height / 2
            elseif(posY - viewSize.height / 2 < mapBorderWidth)then
                posY = mapBorderWidth + viewSize.height / 2
            end
            view:setPosition(ccp(posX, posY))
        end
    end
end

--搬家之后小地图上面的自己基地点跟着移动
function mainUI:myBaseMove()
    local tmpMap = tolua.cast(self.mySpriteWorld:getChildByTag(513), "CCSprite")
    if(tmpMap)then
        local tmpPoint = tolua.cast(tmpMap:getChildByTag(514), "CCSprite")
        if(tmpPoint)then
            local mapSize = tmpMap:getContentSize()
            local mapBorderWidth = 6
            local mapRealHeight = mapSize.height - mapBorderWidth * 2
            local mapRealWidth = mapSize.width - mapBorderWidth * 2
            tmpPoint:setPosition(ccp(playerVoApi:getMapX() / G_maxMapx * mapRealWidth + mapBorderWidth, mapSize.height - mapBorderWidth - playerVoApi:getMapY() / G_maxMapy * mapRealHeight))
        end
    end
end

function mainUI:addSelectSp()    
    if self.selectSp == nil then
        local function clickAreaHandler()
        end
        if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
            self.selectSp = LuaCCScale9Sprite:createWithSpriteFrameName("guide_res.png", CCRect(28, 28, 2, 2), clickAreaHandler)
        else
            self.selectSp = LuaCCScale9Sprite:createWithSpriteFrameName("guide_res1.png", CCRect(28, 28, 2, 2), clickAreaHandler)
        end
        self.selectSp:setAnchorPoint(ccp(0, 0))
        self.selectSp:setPosition(ccp(self.m_taskSp:getPositionX()-2.5, self.m_taskSp:getPositionY()))    
        self.selectSp:setTouchPriority(-1)
        self.selectSp:setIsSallow(false)
        self.selectSp:setContentSize(CCSize(self.m_taskSp:getContentSize().width * 0.8, self.m_taskSp:getContentSize().height * 0.8))
        self.myUILayer:addChild(self.selectSp, 3)
        
        self.arrow = CCSprite:createWithSpriteFrameName("GuideArow.png")
        self.arrow:setAnchorPoint(ccp(0.5, 0))
        
        self.arrow:setPosition(ccp(self.selectSp:getContentSize().width + 5, self.selectSp:getContentSize().height / 2))
        self.arrow:setRotation(90)
        self.selectSp:addChild(self.arrow)
        
        local pos1 = ccp(self.arrow:getPositionX(), self.arrow:getPositionY())
        local pos2 = ccp(self.arrow:getPositionX() + 100, self.arrow:getPositionY())
        
        local mvTo = CCMoveTo:create(0.35, pos1)
        local mvBack = CCMoveTo:create(0.35, pos2)
        local seq = CCSequence:createWithTwoActions(mvTo, mvBack)
        self.arrow:runAction(CCRepeatForever:create(seq))
    end
    
    self.selectSp:setPosition(ccp(self.m_taskSp:getPositionX()-2.5, self.m_taskSp:getPositionY()))
end
function mainUI:showOrHideSelectSp(isShow)
    if self.selectSp then
        if isShow == true then
            self.selectSp:setVisible(true)
        else
            self.selectSp:setVisible(false)
        end
    end
end

function mainUI:playerIconChange(data)
    local personPhoto = self.mySpriteLeft:getChildByTag(767)
    if personPhoto then
        personPhoto:removeFromParentAndCleanup(true)
        personPhoto = nil
    end
    local personPhotoName = playerVoApi:getPersonPhotoSp()
    personPhoto = playerVoApi:getPersonPhotoSp()
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        personPhoto:setAnchorPoint(ccp(0.5, 0.5));
        personPhoto:setPosition(ccp(42, self.mySpriteLeft:getContentSize().height / 2));
    else
        personPhoto:setAnchorPoint(ccp(0.5,1))
        personPhoto:setPosition(ccp(self.mySpriteLeft:getContentSize().width / 2, self.mySpriteLeft:getContentSize().height-12));
    end
    personPhoto:setTag(767)
    self.mySpriteLeft:addChild(personPhoto, 5)
    
    --头像框
    local frameSp = playerVoApi:getPlayerHeadFrameSp()
    if frameSp then
        frameSp:setPosition(personPhoto:getContentSize().width / 2, personPhoto:getContentSize().height / 2)
        frameSp:setScale((personPhoto:getContentSize().width + 7) / frameSp:getContentSize().width)
        personPhoto:addChild(frameSp)
    end
end

function mainUI:refreshGift()
    if(base.ifFriendOpen == 1 and self.fbInviteBtnHasShow == true and newGuidMgr:isNewGuiding() == false)then
        if(G_curPlatName() == "21" or G_curPlatName() == "androidarab")then
            local function giftStatusChange()
                local btn = self.fbBtn
                if(btn)then
                    local flicker = btn:getChildByTag(101)
                    if(friendVoApi:checkCanAccept() and friendVoApi:getGiftNum() > 0)then
                        if(flicker == nil)then
                            local pzFrameName = "CircleEffect_1.png"
                            local flicker = CCSprite:createWithSpriteFrameName(pzFrameName)
                            flicker:setTag(101)
                            flicker:setPosition(getCenterPoint(btn))
                            flicker:setScale(1 / (self.m_iconScaleX / 2))
                            btn:addChild(flicker)
                            local pzArr = CCArray:create()
                            for kk = 1, 31 do
                                local nameStr = "CircleEffect_"..kk..".png"
                                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                                pzArr:addObject(frame)
                            end
                            local animation = CCAnimation:createWithSpriteFrames(pzArr)
                            animation:setDelayPerUnit(0.03)
                            local animate = CCAnimate:create(animation)
                            local repeatForever = CCRepeatForever:create(animate)
                            flicker:runAction(repeatForever)
                        end
                    else
                        if(flicker)then
                            flicker:removeFromParentAndCleanup(true)
                        end
                    end
                end
            end
            self.giftStatusListener = giftStatusChange
            if(self.giftRefreshTime == nil)then
                self.giftRefreshTime = base.serverTime + 10
                eventDispatcher:addEventListener("friend.gift", self.giftStatusListener)
            end
            if(base.serverTime >= self.giftRefreshTime)then
                friendVoApi:refreshGift(giftStatusChange)
                self.giftRefreshTime = base.serverTime + 60
            end
        end
    end
end
--11111左边第一个图标
function mainUI:showGloryNow()
    
    local function gloryShowBgCall()
        -- print("in gloryShowBgCall~~~~~")
        local function showBgNow()
            local sd = gloryInPlayerLabel:new(3, 1)
            local dialog = sd:init(nil)
        end
        gloryVoApi:refreshNewData(showBgNow)
    end
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        self.gloryBg = LuaCCScale9Sprite:createWithSpriteFrameName("Icon_BG.png", CCRect(20, 20, 10, 10), gloryShowBgCall)
        self.gloryBg:setAnchorPoint(ccp(0, 0))
        self.gloryBg:setPosition(0, G_VisibleSizeHeight - 225)
    else
        self.gloryBg = LuaCCScale9Sprite:createWithSpriteFrameName("Icon_BG1.png", CCRect(20, 20, 10, 10), gloryShowBgCall)
        self.gloryBg:setAnchorPoint(ccp(0, 0))
        self.gloryBg:setPosition(4, G_VisibleSizeHeight - 280)
    end   
    self.gloryBg:setTouchPriority(-23)
    
    self.myUILayer:addChild(self.gloryBg)
    -- self.gloryBg:setTouchPriority(-(self.layerNum-1)*20-2)
    local curLevel = playerVoApi:getPlayerLevel()
    self.m_gloryPic = playerVoApi:getPlayerBuildPic(curLevel)
    local buildIcon = CCSprite:createWithSpriteFrameName(self.m_gloryPic)
    buildIcon:setScaleX(self.gloryBg:getContentSize().width / buildIcon:getContentSize().width)
    buildIcon:setScaleY(self.gloryBg:getContentSize().width / buildIcon:getContentSize().width)
    buildIcon:setAnchorPoint(ccp(0.5, 0.5))
    buildIcon:setPosition(getCenterPoint(self.gloryBg))
    buildIcon:setTag(1641)
    self.gloryBg:addChild(buildIcon)
    
    self.isGloryOver = gloryVoApi:isGloryOver()
    
    if self.isGloryOver == true then
        self:fireBuildingAction(buildIcon)
    elseif gloryVo and gloryVo.curBoom < gloryVo.curBoomMax then
        self:renewGlory()
    end
end

function mainUI:renewGlory()
    if self.isGloryOver == false then
        local pzFrameName = "up1.png"
        local metalSp = CCSprite:createWithSpriteFrameName(pzFrameName)
        metalSp:setAnchorPoint(ccp(1, 0))
        metalSp:setTag(771)
        
        metalSp:setPosition(ccp(self.gloryBg:getContentSize().width, 5))
        local pzArr = CCArray:create()
        for kk = 1, 8 do
            local nameStr = "up"..kk..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            pzArr:addObject(frame)
        end
        local animation = CCAnimation:createWithSpriteFrames(pzArr)
        animation:setDelayPerUnit(0.3)
        local animate = CCAnimate:create(animation)
        local repeatForever = CCRepeatForever:create(animate)
        metalSp:runAction(repeatForever)
        self.gloryBg:addChild(metalSp)
        
        -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/slotMachine.plist")
        -- local  arowShowTb = {}
        
        -- for i=1,3 do
        --     local arowBg = CCSprite:createWithSpriteFrameName("SlotArow.png")
        --     arowBg:setAnchorPoint(ccp(1,0.5))
        --     arowBg:setRotation(180)
        --     arowBg:setPosition(ccp(self.gloryBg:getContentSize().width,self.gloryBg:getContentSize().height*0.3*i-10))
        --     arowBg:setTag(770+i)
        --     self.gloryBg:addChild(arowBg,5)
        
        --     local arow = CCSprite:createWithSpriteFrameName("SlotArowRed.png")
        --     arow:setAnchorPoint(ccp(1,0.5))
        --     arow:setRotation(180)
        --     arow:setPosition(ccp(self.gloryBg:getContentSize().width,self.gloryBg:getContentSize().height*0.3*i-10))
        --     arow:setTag(870+i)
        --     self.gloryBg:addChild(arow,5)
        --     table.insert(arowShowTb,arow)
        --     arow:setVisible(false)
        -- end
        
        -- local isArow = 3
        -- local function shwoArowCall( )
        
        --    if arowShowTb and SizeOfTable(arowShowTb)>0 then
        --       if isArow ==3 then
        --         for k,v in pairs(arowShowTb) do
        --           if k%2 ~=0 then
        --             v:setVisible(true)
        --           else
        --             v:setVisible(false)
        --           end
        --         end
        --         isArow =2
        --       elseif isArow ==2 then
        --         for k,v in pairs(arowShowTb) do
        --           if k%2 ~=0 then
        --             v:setVisible(false)
        --           else
        --             v:setVisible(true)
        --           end
        --         end
        --         isArow =3
        --       end
        --    end
        -- end
        -- local shwoArow = CCCallFunc:create(shwoArowCall)
        -- local acArr = CCArray:create()
        -- local delay = CCDelayTime:create(0.3)
        -- acArr:addObject(delay)
        -- acArr:addObject(shwoArow)
        -- local seq=CCSequence:create(acArr)
        -- local repeatForever=CCRepeatForever:create(seq)
        -- self.gloryBg:runAction(repeatForever)
    end
end

function mainUI:fireBuildingAction(buildIcon)
    if self.isGloryOver == true then
        -- buildIcon:setColor(ccc3(136,136,136))
        local pzFrameName = "bf1.png"
        local metalSp = CCSprite:createWithSpriteFrameName(pzFrameName)
        metalSp:setAnchorPoint(ccp(0.5, 0.5))
        metalSp:setTag(881)
        metalSp:setScale(buildIcon:getContentSize().width * 0.9 / metalSp:getContentSize().width)
        metalSp:setPosition(ccp(buildIcon:getContentSize().width * 0.55, buildIcon:getContentSize().height * 0.35))
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
        local x = 1
        metalSp:runAction(repeatForever)
        buildIcon:addChild(metalSp)
        
        local redBgShow = CCSprite:createWithSpriteFrameName("redMaskT.png")
        redBgShow:setAnchorPoint(ccp(0.5, 0.5))
        redBgShow:setScale((metalSp:getContentSize().width + 10) / redBgShow:getContentSize().width)
        redBgShow:setPosition(ccp(metalSp:getContentSize().width * 0.45, metalSp:getContentSize().height * 0.6))
        metalSp:addChild(redBgShow)
        local fadeIn = CCFadeIn:create(1)
        local fadeInUn = fadeIn:reverse()
        local acArr = CCArray:create()
        acArr:addObject(fadeIn)
        acArr:addObject(fadeInUn)
        local seq = CCSequence:create(acArr)
        local repeatForever = CCRepeatForever:create(seq)
        redBgShow:runAction(repeatForever)
    end
end

function mainUI:showGloryUpgradeDialog()
    local sd = gloryUpgradeShowDialog:new(2, 3)
    local dialog = sd:init(nil)
end

--开关2017新版冬季皮肤
function mainUI:switchWinterSkin(flag)
    if(self.mySpriteMain and tolua.cast(self.mySpriteMain, "CCNode"))then
        local skinSp1 = tolua.cast(self.mySpriteMain:getChildByTag(701), "CCNode")
        if(skinSp1 == nil and flag)then
            skinSp1 = CCSprite:createWithSpriteFrameName("winterskinui1.png")
            skinSp1:setTag(701)
            skinSp1:setAnchorPoint(ccp(1, 1))
            skinSp1:setPosition(ccp(90, self.mySpriteMain:getContentSize().height))
            self.mySpriteMain:addChild(skinSp1, 6)
        end
        if(skinSp1)then
            skinSp1:setVisible(flag)
        end
        local skinSp21 = tolua.cast(self.mySpriteMain:getChildByTag(721), "CCNode")
        if(skinSp21 == nil and flag)then
            skinSp21 = CCSprite:createWithSpriteFrameName("winterskinui21.png")
            skinSp21:setTag(721)
            skinSp21:setAnchorPoint(ccp(0, 0))
            skinSp21:setPosition(ccp(0, self.mySpriteMain:getContentSize().height - 90))
            self.mySpriteMain:addChild(skinSp21, 6)
        end
        if(skinSp21)then
            skinSp21:setVisible(flag)
        end
        local skinSp3 = tolua.cast(self.mySpriteMain:getChildByTag(703), "CCNode")
        if(skinSp3 == nil and flag)then
            skinSp3 = CCSprite:createWithSpriteFrameName("winterskinui3.png")
            skinSp3:setTag(703)
            skinSp3:setAnchorPoint(ccp(1, 1))
            skinSp3:setPosition(ccp(self.mySpriteMain:getContentSize().width, self.mySpriteMain:getContentSize().height))
            self.mySpriteMain:addChild(skinSp3, 1)
        end
        if(skinSp3)then
            skinSp3:setVisible(flag)
        end
        local skinSp2 = tolua.cast(self.mySpriteMain:getChildByTag(702), "CCNode")
        if(skinSp2 == nil and flag)then
            skinSp2 = CCSprite:createWithSpriteFrameName("winterskinui2.png")
            skinSp2:setTag(702)
            skinSp2:setAnchorPoint(ccp(1, 1))
            skinSp2:setPosition(ccp(self.mySpriteMain:getContentSize().width - skinSp3:getContentSize().width, self.mySpriteMain:getContentSize().height))
            self.mySpriteMain:addChild(skinSp2, 1)
        end
        if(skinSp2)then
            skinSp2:setVisible(flag)
        end
        local skinSp4 = tolua.cast(self.mySpriteMain:getChildByTag(704), "CCNode")
        if(skinSp4 == nil and flag)then
            skinSp4 = CCSprite:createWithSpriteFrameName("winterskinui4.png")
            skinSp4:setTag(704)
            skinSp4:setAnchorPoint(ccp(0, 1))
            skinSp4:setPosition(ccp(0, 63))
            self.mySpriteMain:addChild(skinSp4, 1)
        end
        if(skinSp4)then
            skinSp4:setVisible(flag)
        end
        local skinSp5 = tolua.cast(self.mySpriteMain:getChildByTag(705), "CCNode")
        if(skinSp5 == nil and flag)then
            skinSp5 = CCSprite:createWithSpriteFrameName("winterskinui5.png")
            skinSp5:setTag(705)
            skinSp5:setAnchorPoint(ccp(0, 1))
            skinSp5:setPosition(ccp(skinSp4:getContentSize().width, 63))
            self.mySpriteMain:addChild(skinSp5, 1)
        end
        if(skinSp5)then
            skinSp5:setVisible(flag)
        end
        local skinSp6 = tolua.cast(self.mySpriteMain:getChildByTag(706), "CCNode")
        if(skinSp6 == nil and flag)then
            skinSp6 = CCSprite:createWithSpriteFrameName("winterskinui6.png")
            skinSp6:setTag(706)
            skinSp6:setAnchorPoint(ccp(1, 1))
            skinSp6:setPosition(ccp(self.mySpriteMain:getContentSize().width, 63))
            self.mySpriteMain:addChild(skinSp6, 1)
        end
        if(skinSp6)then
            skinSp6:setVisible(flag)
        end
        local skinSp7 = tolua.cast(self.mySpriteMain:getChildByTag(707), "CCNode")
        if(skinSp7 == nil and flag)then
            skinSp7 = CCSprite:createWithSpriteFrameName("winterskinui7.png")
            skinSp7:setTag(707)
            skinSp7:setAnchorPoint(ccp(0, 1))
            skinSp7:setPosition(ccp(0, 10))
            self.mySpriteMain:addChild(skinSp7, 1)
        end
        if(skinSp7)then
            skinSp7:setVisible(flag)
        end
        local skinSp8 = tolua.cast(self.mySpriteMain:getChildByTag(708), "CCNode")
        if(skinSp8 == nil and flag)then
            skinSp8 = CCSprite:createWithSpriteFrameName("winterskinui8.png")
            skinSp8:setTag(708)
            skinSp8:setAnchorPoint(ccp(1, 1))
            skinSp8:setPosition(ccp(self.mySpriteMain:getContentSize().width, 10))
            self.mySpriteMain:addChild(skinSp8, 1)
        end
        if(skinSp8)then
            skinSp8:setVisible(flag)
        end
    end
    if(self.m_chatBg and tolua.cast(self.m_chatBg, "CCNode"))then
        local skinSp9 = tolua.cast(self.m_chatBg:getChildByTag(709), "CCNode")
        if(skinSp9 == nil and flag)then
            skinSp9 = CCSprite:createWithSpriteFrameName("winterskinui9.png")
            skinSp9:setTag(709)
            skinSp9:setAnchorPoint(ccp(0, 1))
            skinSp9:setPosition(ccp(0, self.m_chatBg:getContentSize().height + 5))
            self.m_chatBg:addChild(skinSp9, 1)
        end
        if(skinSp9)then
            skinSp9:setVisible(flag)
        end
        local skinSp10 = tolua.cast(self.m_chatBg:getChildByTag(710), "CCNode")
        if(skinSp10 == nil and flag)then
            skinSp10 = CCSprite:createWithSpriteFrameName("winterskinui10.png")
            skinSp10:setTag(710)
            skinSp10:setAnchorPoint(ccp(0, 1))
            skinSp10:setPosition(ccp(skinSp9:getContentSize().width, self.m_chatBg:getContentSize().height + 5))
            self.m_chatBg:addChild(skinSp10, 1)
        end
        if(skinSp10)then
            skinSp10:setVisible(flag)
        end
        local skinSp11 = tolua.cast(self.m_chatBg:getChildByTag(711), "CCNode")
        if(skinSp11 == nil and flag)then
            skinSp11 = CCSprite:createWithSpriteFrameName("winterskinui11.png")
            skinSp11:setTag(711)
            skinSp11:setAnchorPoint(ccp(1, 1))
            skinSp11:setPosition(ccp(G_VisibleSizeWidth, self.m_chatBg:getContentSize().height + 5))
            self.m_chatBg:addChild(skinSp11, 1)
        end
        if(skinSp11)then
            skinSp11:setVisible(flag)
        end
    end
    if(self.mySpriteDown and tolua.cast(self.mySpriteDown, "CCNode"))then
        local skinSp12 = tolua.cast(self.mySpriteDown:getChildByTag(712), "CCNode")
        if(skinSp12 == nil and flag)then
            skinSp12 = CCSprite:createWithSpriteFrameName("winterskinui12.png")
            skinSp12:setTag(712)
            skinSp12:setAnchorPoint(ccp(0, 1))
            skinSp12:setPosition(ccp(0, self.mySpriteDown:getContentSize().height + 5))
            self.mySpriteDown:addChild(skinSp12, 1)
        end
        if(skinSp12)then
            skinSp12:setVisible(flag)
        end
        local skinSp13 = tolua.cast(self.mySpriteDown:getChildByTag(713), "CCNode")
        if(skinSp13 == nil and flag)then
            skinSp13 = CCSprite:createWithSpriteFrameName("winterskinui13.png")
            skinSp13:setTag(713)
            skinSp13:setAnchorPoint(ccp(0, 1))
            skinSp13:setPosition(ccp(skinSp12:getContentSize().width, self.mySpriteDown:getContentSize().height + 5))
            self.mySpriteDown:addChild(skinSp13, 1)
        end
        if(skinSp13)then
            skinSp13:setVisible(flag)
        end
        local skinSp14 = tolua.cast(self.mySpriteDown:getChildByTag(714), "CCNode")
        if(skinSp14 == nil and flag)then
            skinSp14 = CCSprite:createWithSpriteFrameName("winterskinui14.png")
            skinSp14:setTag(714)
            skinSp14:setAnchorPoint(ccp(1, 1))
            skinSp14:setPosition(ccp(G_VisibleSizeWidth, self.mySpriteDown:getContentSize().height + 5))
            self.mySpriteDown:addChild(skinSp14, 1)
        end
        if(skinSp14)then
            skinSp14:setVisible(flag)
        end
        local skinSp15 = tolua.cast(self.mySpriteDown:getChildByTag(715), "CCNode")
        if(skinSp15 == nil and flag)then
            skinSp15 = CCSprite:createWithSpriteFrameName("winterskinui15.png")
            skinSp15:setTag(715)
            skinSp15:setAnchorPoint(ccp(0, 0))
            skinSp15:setPosition(ccp(0, 0))
            self.mySpriteDown:addChild(skinSp15, 1)
        end
        if(skinSp15)then
            skinSp15:setVisible(flag)
        end
        local skinSp16 = tolua.cast(self.mySpriteDown:getChildByTag(716), "CCNode")
        if(skinSp16 == nil and flag)then
            skinSp16 = CCSprite:createWithSpriteFrameName("winterskinui16.png")
            skinSp16:setTag(716)
            skinSp16:setAnchorPoint(ccp(0, 0))
            skinSp16:setPosition(ccp(skinSp15:getContentSize().width, 0))
            self.mySpriteDown:addChild(skinSp16, 1)
        end
        if(skinSp16)then
            skinSp16:setVisible(flag)
        end
        local skinSp17 = tolua.cast(self.mySpriteDown:getChildByTag(717), "CCNode")
        if(skinSp17 == nil and flag)then
            skinSp17 = CCSprite:createWithSpriteFrameName("winterskinui17.png")
            skinSp17:setTag(717)
            skinSp17:setAnchorPoint(ccp(0, 0))
            skinSp17:setPosition(ccp(skinSp15:getContentSize().width + skinSp16:getContentSize().width, 0))
            self.mySpriteDown:addChild(skinSp17, 1)
        end
        if(skinSp17)then
            skinSp17:setVisible(flag)
        end
        local skinSp18 = tolua.cast(self.mySpriteDown:getChildByTag(718), "CCNode")
        if(skinSp18 == nil and flag)then
            skinSp18 = CCSprite:createWithSpriteFrameName("winterskinui18.png")
            skinSp18:setTag(718)
            skinSp18:setAnchorPoint(ccp(1, 0))
            skinSp18:setPosition(ccp(G_VisibleSizeWidth, 0))
            self.mySpriteDown:addChild(skinSp18, 1)
        end
        if(skinSp18)then
            skinSp18:setVisible(flag)
        end
    end
    if(self.mySpriteWorld and tolua.cast(self.mySpriteWorld, "CCNode"))then
        local skinSp20 = tolua.cast(self.mySpriteWorld:getChildByTag(720), "CCNode")
        if(skinSp20 == nil and flag)then
            skinSp20 = CCSprite:createWithSpriteFrameName("winterskinui20.png")
            skinSp20:setTag(720)
            skinSp20:setAnchorPoint(ccp(0, 1))
            skinSp20:setPosition(ccp(0, self.mySpriteWorld:getContentSize().height))
            self.mySpriteWorld:addChild(skinSp20, 1)
        end
        if(skinSp20)then
            skinSp20:setVisible(flag)
        end
        local skinSp3 = tolua.cast(self.mySpriteWorld:getChildByTag(703), "CCNode")
        if(skinSp3 == nil and flag)then
            skinSp3 = CCSprite:createWithSpriteFrameName("winterskinui3.png")
            skinSp3:setTag(703)
            skinSp3:setAnchorPoint(ccp(1, 1))
            skinSp3:setPosition(ccp(self.mySpriteWorld:getContentSize().width, self.mySpriteWorld:getContentSize().height))
            self.mySpriteWorld:addChild(skinSp3, 1)
        end
        if(skinSp3)then
            skinSp3:setVisible(flag)
        end
        local skinSp2 = tolua.cast(self.mySpriteWorld:getChildByTag(702), "CCNode")
        if(skinSp2 == nil and flag)then
            skinSp2 = CCSprite:createWithSpriteFrameName("winterskinui2.png")
            skinSp2:setTag(702)
            skinSp2:setAnchorPoint(ccp(1, 1))
            skinSp2:setPosition(ccp(self.mySpriteWorld:getContentSize().width - skinSp3:getContentSize().width, self.mySpriteWorld:getContentSize().height))
            self.mySpriteWorld:addChild(skinSp2, 1)
        end
        if(skinSp2)then
            skinSp2:setVisible(flag)
        end
        if base.wl == 1 and base.goldmine == 1 then
            local skinSp4 = tolua.cast(self.mySpriteWorld:getChildByTag(704), "CCNode")
            if(skinSp4 == nil and flag)then
                skinSp4 = CCSprite:createWithSpriteFrameName("winterskinui4.png")
                skinSp4:setTag(704)
                skinSp4:setAnchorPoint(ccp(0, 1))
                skinSp4:setPosition(ccp(0, 0))
                self.mySpriteWorld:addChild(skinSp4, 1)
            end
            if(skinSp4)then
                skinSp4:setVisible(flag)
            end
            local skinSp5 = tolua.cast(self.mySpriteWorld:getChildByTag(705), "CCNode")
            if(skinSp5 == nil and flag)then
                skinSp5 = CCSprite:createWithSpriteFrameName("winterskinui5.png")
                skinSp5:setTag(705)
                skinSp5:setAnchorPoint(ccp(0, 1))
                skinSp5:setPosition(ccp(skinSp4:getContentSize().width, 0))
                self.mySpriteWorld:addChild(skinSp5, 1)
            end
            if(skinSp5)then
                skinSp5:setVisible(flag)
            end
            local skinSp6 = tolua.cast(self.mySpriteWorld:getChildByTag(706), "CCNode")
            if(skinSp6 == nil and flag)then
                skinSp6 = CCSprite:createWithSpriteFrameName("winterskinui6.png")
                skinSp6:setTag(706)
                skinSp6:setAnchorPoint(ccp(1, 1))
                skinSp6:setPosition(ccp(self.mySpriteWorld:getContentSize().width, 0))
                self.mySpriteWorld:addChild(skinSp6, 1)
            end
            if(skinSp6)then
                skinSp6:setVisible(flag)
            end
        end
    end
    if(self.tv and tolua.cast(self.tv, "LuaCCTableView"))then
        self.tv:reloadData()
    end
end

function mainUI:initSunShine(parent, titleHeight, leftPos)
    if self.realLight then
        self.realLight:removeFromParentAndCleanup(true)
        self.realLight = nil
    end
    self.realLight = CCSprite:createWithSpriteFrameName("mainUiClickShine.png")
    print("self.realLight---------", self.realLight)
    self.realLight:setPosition(leftPos)
    local blendFunc = ccBlendFunc:new()
    blendFunc.src = GL_ONE
    blendFunc.dst = GL_ONE
    self.realLight:setBlendFunc(blendFunc)
    parent:addChild(self.realLight, 8)
    self.realLight:setOpacity(255)
    
    local arr1 = CCArray:create()
    local rotate1 = CCRotateBy:create(1, 360)
    arr1:addObject(rotate1)
    local fadeTo1 = CCFadeTo:create(1, 0)
    arr1:addObject(fadeTo1)
    local spawn1 = CCSpawn:create(arr1)
    local arr2 = CCArray:create()
    local function actionEnd()
        if self.realLight then
            self.realLight:removeFromParentAndCleanup(true)
            self.realLight = nil
        end
    end
    local callFunc = CCCallFunc:create(actionEnd)
    arr2:addObject(spawn1)
    arr2:addObject(callFunc)
    self.realLight:runAction(spawn1)
end

--战机革新正在研究的技能图标
function mainUI:refreshPlaneStudySkill()
    if base.plane == 1 and planeVoApi:isSkillTreeSystemOpen() then
        if self.m_luaSp8 == nil then
            local function touchLuaSp(object, name, tag)
                print("tag====", tag)
                self:touchLuaSp(object, name, tag)
            end
            if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                self.m_luaSp8 = LuaCCSprite:createWithSpriteFrameName("Icon_BG.png", touchLuaSp)
            else
                self.m_luaSp8 = LuaCCSprite:createWithSpriteFrameName("Icon_BG1.png", touchLuaSp)
            end
            self.m_luaSp8:setPosition(self.m_pointLuaSp)
            self.m_luaSp8:setTag(108)
            self.myUILayer:addChild(self.m_luaSp8, 5)
            self.m_luaSp8:setTouchPriority(-21)
            if self.m_travelSp and self.m_travelSp:isVisible() == false then
                local num = SizeOfTable(self.m_luaSpTab)
                table.insert(self.m_luaSpTab, num, self.m_luaSp8)
            else
                table.insert(self.m_luaSpTab, self.m_luaSp8)
            end
        end
        local studySkillSp = self.m_luaSp8:getChildByTag(108)
        if studySkillSp and tolua.cast(studySkillSp, "CCSprite") then
            studySkillSp:removeFromParentAndCleanup(true)
            studySkillSp = nil
        end
        local studyList = planeVoApi:getStudyList()
        if studyList then --有研究队列
            local studySkill = studyList[1]
            self.studySid = studySkill.sid
            studySkillSp = planeVoApi:getNewSkillIcon(self.studySid)
            local scale = (self.m_luaSp8:getContentSize().width - 8) / studySkillSp:getContentSize().width
            studySkillSp:setScale(scale)
            local timerBg
            if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                timerBg = LuaCCScale9Sprite:createWithSpriteFrameName("IconBgNum.png", CCRect(5, 5, 1, 1), function () end)
            else
                timerBg = LuaCCScale9Sprite:createWithSpriteFrameName("IconBgNum1.png", CCRect(5, 5, 1, 1), function () end)
            end
            timerBg:setContentSize(CCSizeMake(studySkillSp:getContentSize().width, 25))
            timerBg:setPosition(studySkillSp:getContentSize().width / 2 + 1, 10)
            timerBg:setTag(3)
            studySkillSp:addChild(timerBg, 3)
            local lefttime = planeVoApi:getStudyLeftTime(self.studySid)
            local timerLb = GetTTFLabel(GetTimeStr(lefttime), 20)
            timerLb:setPosition(timerBg:getPosition())
            timerLb:setTag(5)
            studySkillSp:addChild(timerLb, 4)
        else --无研究队列
            self.studySid = nil
            if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                studySkillSp = LuaCCSprite:createWithSpriteFrameName("planeskill_freeIcon.png", function () end)
            else
                studySkillSp = LuaCCSprite:createWithSpriteFrameName("planeskill_freeIcon1.png", function () end)
            end
            local scale = self.m_luaSp8:getContentSize().width / studySkillSp:getContentSize().width
            studySkillSp:setScale(scale)
            local nscfg = planeVoApi:getNewSkillCfg()
            local freeSlotLb = GetTTFLabel("0/"..nscfg.process, 20)
            local slotBg
            if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                slotBg = LuaCCScale9Sprite:createWithSpriteFrameName("IconBgNum.png", CCRect(5, 5, 1, 1), function () end)
            else
                slotBg = LuaCCScale9Sprite:createWithSpriteFrameName("IconBgNum1.png", CCRect(5, 5, 1, 1), function () end)
            end
            slotBg:setContentSize(CCSizeMake(freeSlotLb:getContentSize().width + 10, 20))
            slotBg:setPosition(studySkillSp:getContentSize().width / 2, 10)
            slotBg:setScale(1 / scale)
            slotBg:setTag(3)
            studySkillSp:addChild(slotBg, 3)
            freeSlotLb:setPosition(getCenterPoint(slotBg))
            slotBg:addChild(freeSlotLb, 4)
        end
        if studySkillSp then
            studySkillSp:setTag(108)
            studySkillSp:setTouchPriority(-1)
            studySkillSp:setPosition(getCenterPoint(self.m_luaSp8))
            self.m_luaSp8:addChild(studySkillSp, 1)
        end
        self:resetRightDownMenu()
    end
end

--重置右侧下拉菜单的坐标
function mainUI:resetRightDownMenu()
    for k, v in pairs(self.m_luaSpTab) do
        v:stopAllActions()
        v:setPosition(self.m_pointLuaSp.x, self.m_pointLuaSp.y - k * self.m_skillHeigh - k * self.m_dis)
    end
end

--刷新主界面玩家头像红点提示（有些功能状态发生变化需要给出红点提示）
function mainUI:refreshPlayerIconTip(data)
    local flag = false
    if achievementVoApi and achievementVoApi:isOpen() == 1 then
        flag = achievementVoApi:hasReward() --成就系统有奖励可以领取
    end
    if flag == true then
        if self.playerIconTipSp == nil then
            local playerIconSp = tolua.cast(self.mySpriteLeft:getChildByTag(767), "CCSprite")
            if playerIconSp then
                local tipSp
                if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
                    tipSp = CCSprite:createWithSpriteFrameName("IconTip.png")
                    tipSp:setPosition(playerIconSp:getPositionX() + playerIconSp:getContentSize().width * playerIconSp:getScaleX() / 2, playerIconSp:getPositionY() + playerIconSp:getContentSize().height * playerIconSp:getScaleY() / 2 - 2)
                    tipSp:setScale(0.6)
                else
                    tipSp = CCSprite:createWithSpriteFrameName("IconTip1.png")
                    tipSp:setPosition(ccp(self.mySpriteLeft:getContentSize().width-15,self.mySpriteLeft:getContentSize().height-15))
                    tipSp:setScale(0.5)
                end
                self.mySpriteLeft:addChild(tipSp, 8)
                self.playerIconTipSp = tipSp
            end
        end
    else
        if self.playerIconTipSp then
            self.playerIconTipSp:removeFromParentAndCleanup(true)
            self.playerIconTipSp = nil
        end
    end
end

function mainUI:dispose()
    self.chatSprite = nil
    self.newFriendTipSprite = nil
    self.numLb = nil
    self.chatRepeat = nil
    self.repeatEver = nil
    self.isGloryOver = false
    self.gloryBg = nil
    self.m_gloryPic = nil
    self.myUILayer = nil
    self.mySpriteLeft = nil
    self.mySpriteRight = nil
    self.mySpriteDown = nil
    self.mySpriteWorld = nil
    self.m_labelMoney = nil
    self.m_labelGold = nil
    self.m_labelR1 = nil
    self.m_labelR2 = nil
    self.m_labelR3 = nil
    self.m_labelR4 = nil
    self.m_labelLevel = nil
    self.m_menuToggle = nil
    self.m_menuToggleSmall = nil
    self.tv = nil
    self.m_luaSpTab = nil
    self.m_luaLayer = nil
    self.m_luaSp1 = nil
    self.m_luaSp2 = nil
    self.m_luaSp3 = nil
    self.m_luaSp4 = nil
    self.m_luaSp5 = nil
    self.m_luaSp6 = nil
    self.m_luaSp7 = nil
    self.m_skillHeigh = nil
    self.m_dis = nil
    self.m_luaTime = nil
    self.m_pointLuaSp = nil
    self.m_pointVip = nil
    self.m_menuToggleVip = nil
    self.m_vipLevel = nil
    self.m_iconScaleX = nil
    self.m_iconScaleY = nil
    self.m_dailySp = nil
    self.m_taskSp = nil
    self.m_enemyComingSp = nil
    self.m_countdownLabel = nil
    self.m_travelTimeLabel = nil
    self.m_travelSp = nil
    self.m_newsIconTab = nil
    self.m_newsNumTab = nil
    self.m_lastSearchXValue = 0
    self.m_lastSearchYValue = 0
    self.m_chatBg = nil
    self.m_chatBtn = nil
    self.m_labelLastType = nil
    self.m_labelLastMsg = nil
    self.m_labelLastName = nil
    self.m_bookmak = nil
    self.m_labelX = nil
    self.m_labelY = nil
    self.m_flagTab = nil
    self.m_rechargeBtn = nil
    self.m_showWelcome = nil
    self.m_luaSpBuff = nil
    self.m_luaSpBuffSp1 = nil
    self.m_luaSpBuffSp2 = nil
    self.m_luaSpBuffSp3 = nil
    self.m_newGiftsSp = nil
    self.m_dailyRewardSp = nil
    self.m_acAndNoteSp = nil
    self.dialog_acAndNote = nil
    self.m_leftIconTab = nil
    self.m_rightTopIconTab = nil
    self.m_isNewGuide = nil
    self.m_isShowDaily = nil
    self.m_newYearIcon = nil
    self.m_noticeIcon = nil
    self.m_helpDefendIcon = nil
    self.m_helpDefendLabel = nil
    self.fbInviteBtnHasShow = false
    self.onlinePackageBtn = nil
    self.m_signIcon = nil
    m_functionBtnTb = nil
    self.isShowAct = false
    self.isClickFirstRechargeBtn = false
    self.giftPushBtn = nil
    self.firstRechargeBg = nil
    self.firstRechargeFlicker = nil
    
    self.platformAwardsBg = nil
    self.platformAwardsFlicker = nil
    self.isShowplatformAwards = false
    self.isRequestPlatformAwards = false
    self.m_joinAllianceSp = nil
    
    self.m_mainTaskBg = nil
    self.m_mainTaskBtn = nil
    self.showMainTask = true
    -- self.mainTaskBgCanMove=true
    self.isNewGuideShow = true
    self.m_showInterval = 10
    self.m_lastShowTime = 0
    self.m_lastMainTaskId = 0
    self.m_lastFinish = nil
    self.m_mtRefresh = true
    eventDispatcher:removeEventListener("user.basemove", self.baseMoveListener)
    eventDispatcher:removeEventListener("playerIcon.Change", self.playerIconChangeListener)
    if self.planeStudySkillListener then
        eventDispatcher:removeEventListener("plane.newskill.refresh", self.planeStudySkillListener)
        self.planeStudySkillListener = nil
    end
    self.baseMoveListener = nil
    self.isShowFundsExtract = nil
    self.isShowFundsExtract1 = nil
    self.m_showFriendTime = 300
    self.addChangename = true
    self.selectSp = nil
    self.m_showKoreaAdver = nil
    self.rewardCenterBtn = nil
    self.rewardCenterBtnBg = nil
    self.giftRefreshTime = nil
    self.gatherResLbTb = nil
    self.menuAllSmall = nil
    self.m_haveAddDirectSign = false
    self.giftPushFlicker = nil
    self.m_directSign = nil --方向标按钮，self.mainUI的子节点，tag为3001
    self.m_directSignItem = nil
    self.m_distanceLabel = nil --方向标上面的距离显示label，m_directSign的子节点，tag为3002
    self.showMiniFleetSlotFlag = false -- 是否显示行军队列小面板
    self.miniFleetSlotLayer = nil -- 行军队列缩略小面板
    self.miniFleetSlotTv = nil -- 行军队列缩略的tableview
    self.fleetSlotTab = nil -- 行军队列数据
    self.tickFleetIcon = {} -- 用于刷新行军队列的icon
    self.tickFleetTimer = {} -- 用于刷新行军队列的进度条
    self.slotLeftBtn = nil --行军队列缩放按钮
    self.slotShowState = 0 --行军队列缩放状态，0显示，1缩放，2正在播放动画
    self.fleetSlotCellTb = {}
    self.isShowAction = false
    self.goldButtonBtn = nil
    self.rechargeFlick = nil
    self.wjdcIconBg = nil
    self.chatTabShowIndex = nil
    self.chatPrivateReciverUid = nil
    self.chatPrivateReciverName = nil
    self.m_luaSp8 = nil
    self.studySid = nil
    self.m_stewardSp = nil
    self.m_stewardSpIsRuningAction = nil
    self.m_militaryOrdersSp = nil
    self.m_militaryOrdersSpFlicker = nil
    self.mysteryBoxSp = nil
    self.flashSaleSp = nil
    self.flashSaleFlicker = nil
    spriteController:removePlist("public/xsjx.plist")
    spriteController:removeTexture("public/xsjx.png")
    eventDispatcher:removeEventListener("friend.gift", self.giftStatusListener)
    eventDispatcher:removeEventListener("skill.eagleeye.change", self.eagleEyeListener)
    if self.refreshSlotListener then
        eventDispatcher:removeEventListener("attackTankSlot.refreshSlot", self.refreshSlotListener)
        self.refreshSlotListener = nil
    end

    self.playerIconTipSp = nil
    if self.sysTipRefreshListener then
        eventDispatcher:removeEventListener("player.sys.tipRefresh", self.sysTipRefreshListener)
        self.sysTipRefreshListener = nil
    end
    if self.nameChangedListener then
        eventDispatcher:removeEventListener("user.name.change", self.nameChangedListener)
        self.nameChangedListener = nil
    end
end
