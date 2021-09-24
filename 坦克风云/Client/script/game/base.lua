base = {
    serverTime = 0,
    localServerTime = 0,
    timeCheckDate = 0,
    curIndex = 0,
    releaseLoadingImg = false,
    waitLayer,
    netWaitLayer,
    waitParent,
    allNeedRefreshDialogs = {}, --显示的需要刷新的面板
    tipsQueue = {}, --自动消失的提示框显示队列
    showNextTip = true,
    lastRecordResourceTime = 0,
    lastEnterBackGroundTimeSpan = 0, --最后一次进入后台运行经过的时间（毫秒）
    allShowedCommonDialog = 0, --当前所有显示在屏幕上的继承至commonDialog的对话框数量
    lastAutoSyncTime = 0, --同步数据用的时间
    buildingSortTb = nil, --建筑用于排序的列表
    tickID,
    fastTickID,
    commonDialogOpened_WeakTb = {},
    userInfoDaily_honors = 0,
    daily_buy_energy = {},
    daily_award = 0,
    lastEventTime = 0, --同步新事件时间
    setWaitTime = 0,
    curZoneID = 1, --服务器ID
    
    curOldZoneID = nil, --合服前的服编号
    curZoneServerName = "", --当前选择的服务器名称
    curCountry, --当前服务器国家
    curArea, --当前服务器名称
    tmpUserName = "", --登录时临时存放的用户填写的绑定过的用户名
    tmpUserPassword = "", --登录时临时存放的用户填写的绑定过的用户密码
    lastSyncTime = 0, --最后一次同步的时间
    lastSetWaitTime = 0, --最后一次设置等待的时间
    curZeroTime = 0, --今天的零点
    lastServerTime = 0,
    access_token = "0",
    logints = 0,
    curUid = 0,
    lastSendPayTime = 0, --上一次发送支付请求时间
    
    sendPayTimes = 5, --一共发多少次
    curTimeZone = 8, --当前时区
    needLoginChatServer = false, --是否需要发送登录聊天服务器请求
    lastSelectedServer, --登录的服务器
    lastOnlineTime = 0, --最后一次在线的时间（用于统计同时在线使用）
    isShowFeedDialog = false, --是否显示feed面板
    platformUserId = nil, --接入平台返回的用户ID
    token = nil,
    allianceTime = nil, --记录返回军团改变信息时间戳
    lastGetMyAllianceDataTime = 0, --上一次从后台获取自己的公会信息时间
    isAllianceOpen = true, --公会功能已开启标记
    isAllianceSwitch = 1, --公会开关 1为开启 0为关闭
    isAllianceSkillSwitch = 1, --公会技能开关 1为开启 0为关闭
    isSignSwitch = 1, --签到开关
    isAllianceFubenSwitch = 0, --公会副本开关 1为开启 0为关闭
    isCodeSwitch = 0, --激活码开关
    ifFriendOpen = 0, --好友功能是否开放
    ifAccessoryOpen = 0, --配件功能是否开放
    isAllianceWarSwitch = 0, --军团战开关
    isSkin = 0, --基地外观开关
    isDonateall = 0, -- 开关一键捐献
    isAf = 0, -- 开关军团旗帜
    
    efunLoginParms = nil, --efun 平台需要后台验证用户的合法性
    loginurl = nil, --登录地址
    payurl = nil, --支付地址
    getSvrConfigFromHttpSuccess = false,
    lastPullActivityDataTime = 0, --上一次调用活动voApi tick方法的时间,每隔10秒调用一次
    pauseSync = false, --暂停同步
    serverIp = "", --服务器
    serverUserIp = "", --用户存储的服务器IP
    switchServerTime = 0, --切换服务器的次数
    nextDay = nil, --明日战力暴增
    isNd = 0, --战力暴增开关
    ifAllianceShopOpen = 0, --军团商店开关
    ifMilitaryOpen = 0, --军事演习开关
    isPayOpen = 1, --支付开关
    isPay1Open = 0, --日本支付方式修改
    
    ifOnlinePackageOpen = 0, -- 在线礼包开关
    landFormOpen = 0, --地形系统开关
    isUserEvaluate = 0, --领没领过评价
    isEvaluateOnOff = 0, --评价开关
    lastSendTime = 0, --上一次发送聊天时间
    lastSendEmojiTime = 0, --上一次发送表情时间
    client_ip = "127.0.0.1", --用户客户端ip
    platusername = "", ---平台返回的玩家角色名称
    loginAccountType = 0, --使用rayjoy账号系统时使用 0:facebook进入的  1:rayjoy账号进入的  2:游客账号进入的 3:google账号进入的
    allShowedSmallDialog = 0, --当前所有显示在屏幕上的继承至smallDialog的对话框数量
    stateOfGarrsion = 1, --驻防状态
    -- vip新特权
    vipPrivilegeSwitch = {
        -- vip 增加战斗经验
        vax = 0,
        --配件合成概率提高
        vea = 0,
        --创建军团不花金币
        vca = 0,
        --装置车间增加可制造物品
        vap = 0,
        -- 高级抽奖每日免费1次
        vfn = 0,
        -- 仓库保护资源量*2
        vps = 0,
        -- 每日捐献次数上限+2
        vdn = 0,
        --精英副本扫荡
        vec = 0,
        --每日签到奖励翻倍
        vsr = 0,
    },
    monthlyCardOpen = 0, --军需卡功能开关
    monthlyCardBuyOpen = 0, --军需卡购买开关
    
    firstAChatFlick = 0, --第一次进入游戏，军团聊天闪光
    joinReward = -1, --是否领取首次加入军团奖励
    --主线任务开关
    mainTaskSwitch = 0,
    heroSwitch = 0, --英雄开关
    
    serverWarTeamSwitch = 0, --军团跨服战开关
    isBackendPushOpen = 0, --后台推送功能的开关
    isPlatShopOpen = 0, --平台币直接购买商品的开关
    expeditionSwitch = 0, --远征开关
    ecshop = 0, --配件兑换商店的开关
    richMineOpen = 0, --富矿系统开关
    rpShop = 0, --军功商店
    rpShopOpen = 0, --军功商店为了方便测试, 所以加一个控制军功商店开放的开关
    gflogUrl = nil, --玩家滚服统计地址
    kfzUrl = nil, --跨服战地址
    qq, -- 腾讯活动开关
    dailychoice = 0, --答题开关
    boss = 0,
    datiTime = 0, --答题的时间
    drew1 = 0, -- 每日体力
    drew2 = 0,
    ttjj = 0,
    xstz = 0, -- 限时挑战(普通)
    xstzh = 0, -- 限时挑战(地狱)
    ydhk = 0, -- 月度回馈
    xsjx = 0,
    meirilingjiangTime, -- 每日领体力 服务器时间
    alien = 0, --异星科技开关
    worldWarSwitch = 0, --世界争霸开关
    worldWarChampion = nil, --是否显示冠军的建筑
    vipshop = 0, --vip新增特权礼包开关
    googleTime = 0,
    succinct = 0, --精炼系统的开关
    amap = 0, --异星矿场
    isGarrsionOpen = 0, --驻防优化开关
    mailBlackList = 0, --邮件屏蔽功能
    herofeat = 0, --将领授勋开关
    herofeat2 = 0, --将领二次授勋开关
    isCheckVersion = 0, --申请版号，判断是否为锁死的ID，0：不是，1：是
    localWarSwitch = 0, --区域战开关
    isRandomGift = 0, --韩国交叉广告，0：不是，1：是
    byh = 0, -- 建筑显示优化
    loginTime = 0,
    isConvertGems = 0, --等级满级 或 是声望满级 兑换水晶的开关
    isCheckCode = 0, --验证码开关，1是开
    gxh = 0, -- 头像与称号开关
    rewardcenter = 0, --奖励中心开关，1是开
    ifGmOpen = 0, --自有客服系统
    ifSuperWeaponOpen = 0, --超级武器开关
    ifTmpSlotOpen = 0, --临时建造队列的开关
    serverPlatID = 0, --后台存储的平台ID，前端的不同混服渠道对应后台的同一个平台
    platWarSwitch = 0, --平台战开关
    ifAndroidBackFunctionOpen = 0, --安卓设备点击返回键的时候不是退出游戏而是关闭面板
    ifChatTransOpen = 0, --聊天自动翻译开关
    etank = 0, -- 精锐坦克开关
    serverWarLocalSwitch = 0, --群雄争霸开关
    he = 0, -- 将领装备开关
    ea = 0, -- 远征扫荡
    ma = 0, -- 军事演习改版开关，此开关开，军事演习开关必开
    pwNoticeSwitch = 0, --平台战全平台公告开关，0未开启，1正常，2只允许选择几句话
    ladder = 0, --天梯榜建筑开关
    chatReportSwitch = 0, --聊天战报优化开关,战报数据存后台
    autoUpgrade = 0, -- 建筑自动升级的功能开关
    accessoryTech = 0, --配件科技开关
    accessoryBind = 0, --配件绑定和突破的开关
    isNewBufPos = 0, --战斗画面内坦克的BUF新的摆放方式
    allianceHelpSwitch = 0, --军团协助开关
    fs = 0, -- vip免费升级加速
    allShowTipStrTb = {}, -- 里面存得是飘字提示的内容
    dailyAcYouhuaSwitch = 0, --每日活动优化开关
    banDialog = false, -- 登录会走两遍checkserverdate,防止弹板两次
    allianceWar2Switch = 0, --新军团战开关
    allianceAcYouhua = 0, --军团活跃优化
    dimensionalWarSwitch = 0, --异元战场开关
    isGlory = 0, --繁荣度开关
    bs = 0, -- 将领经验书一键使用开关
    wl = 0, -- 世界等级开关
    goldmine = 0, -- 金矿系统开关
    privatemine = 0, --保护矿系统开关
    newSign = 0, --新签到开关
    minellvl = 0, --矿点升级开关
    chatLvLimit = 5, --聊天玩家等级限制，未达到等级自己发送只能自己看到，默认是5级
    mustmodel = 0, --（活动改版）
    nbSkillOpen = 0, --NB技能系统的开关
    heroOpenLv = nil, --将领功能的开放等级
    heroEquipOpenLv = nil, --将领装备功能开放等级
    alienTechOpenLv = nil, --异星科技功能开放等级
    superWeaponOpenLv = nil, --超级武器功能开放等级
    expeditionOpenLv = nil, --远征功能开放等级
    newRechargeSwitch = 0, --新的首充双倍开关
    fbboss = 0, --军团boss副本开关
    isRebelOpen = 0, --叛军开关
    ubh = 0, -- 援建改到军衔中的开关
    emblemSwitch = 0, --军徽系统的开关
    weekCard = 0, --周卡开关
    raids = 0, --关卡扫荡开关
    sctlv = 0, --不能侦察比自己高10级以上的矿点的开关
    scroll = 0,
    clanUserID = nil, --阿拉伯的聊天特殊需求，clan工具的用户ID
    hs = 0, -- 心得书熔炼
    newDailyTask = 0, --2016年10月版新任务
    redAcc = 0, --橙色配件是否能突破到5阶红色配件开关
    isWinter = false, --冬季皮肤开关 前端自己控制
    deviceID = nil, --设备ID
    armor = 0, --装甲矩阵开关
    fsaok = 0, --反扫矿开关（矿点等级高于玩家等级10级后对金矿和富矿的处理）
    checkRecharge = 0, --充值是否检测设备ID
    dnews = 0, -- 每日捷报
    webpageRecharge = 0, --是否开放网页版充值
    speedUpPropSwitch = 0, --加速道具使用开关
    hexieMode = 0, --抽奖必给道具模式的开关
    plane = 0, --空中打击功能开关
    powerGuide2017 = 0, -- 战斗引导2017版
    ltzdz = 0, -- 领土争夺战
    ltzdzTb = nil, -- 赛季
    clancrossinfoBnum = nil,
    clancrossinfoRpoint = nil,
    smmap = 0, --缩小地图范围开关
    allianceCitySwitch = 0, --军团城市的开关
    allianceGiftSwitch = 0, -- 军团礼包
    warStatueSwitch = 0, --战争塑像系统开关
    rankPointLimit = 0, --等级相差15级以上战斗不得军功的开关
    bRace = 0, --狂热分子功能开关
    bab = 0, --狂热分子自动匹配5次的开关
    avt = 0, --成就系统开关
    needRefreshObjectTb = nil, --需要刷新的对象
    emblemTroopSwitch = 0, --军徽部队的开关
    stewardSwitch = 0, --军务管家功能开关
    reNameSwitch = 0, --改名卡功能开关
    championshipWarSwitch = 0, --军团锦标赛系统开关
    armorbr = 0, --紫色装甲矩阵突破开关
    AITroopsSwitch = 0, --AI部队系统开关
    rbSwitch = 0, --拆除建筑优化开关
    tskinSwitch = 0, --坦克皮肤开关
    adjSwitch = 0, --将领副官功能开关
    migration = 0, --迁移码功能开关（控制某些平台不显示迁移码）
    moji = 0, --聊天表情开关
    bjSwitch = 0, --补给商店的开关
    prSwitch = 0, --个人叛军开关
    militaryOrders = 0, --军令开关
    shutChatSwitch = 0, --关闭聊天的开关
    planeRefit = 0, --飞机改装开关
    newUIOff = 0, --关闭新版UI的开关（为1时是关闭新版ui，使用旧版ui）
    strategyCenter=0, --战略中心开关
    vfy = 0, --实名认证开关
    memoryServerIp=nil, --怀旧服入口机域名
    memoryServerPlatId=nil,--服务器列表配置中记录的平台id(即玩家实际登录的平台id，后端校验用)，因怀旧服所有平台公用，接口无法返回平台id所以需要列表中配置出来
    virtualKeyboard = 1, --虚拟键盘开关 (暂时默认为1开启状态)
    redAccessoryPromote=0, --红色配件晋升开关
    airShipSwitch=0,--飞艇开关
}
function base:init()
    -- if GM_UidCfg[playerVoApi:getUid()] then--用于GM判断
    --       self.isGlory = 0
    -- end
    if CCUserDefault:sharedUserDefault():getStringForKey("tank_gunfulog") ~= "" then
        self.gflogUrl = CCUserDefault:sharedUserDefault():getStringForKey("tank_gunfulog")
    end
    
    if CCUserDefault:sharedUserDefault():getStringForKey("tank_kfz_url") ~= "" then
        self.kfzUrl = CCUserDefault:sharedUserDefault():getStringForKey("tank_kfz_url")
    end
    
    if self.kfzUrl == nil then
        if platCfg.platServerWarUrl ~= nil then
            self.kfzUrl = platCfg.platServerWarUrl[G_curPlatName()]
            if (G_curPlatName() == "1" or G_curPlatName() == "42") and tonumber(base.curZoneID) >= 13 and tonumber(base.curZoneID) < 997 then
                self.kfzUrl = "119.29.4.24,17002"
            end
        end
    end
    
    setmetatable(self.commonDialogOpened_WeakTb, {__mode = "kv"})
    local function tmptick()
        return self:tick()
    end
    self.tickID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tmptick, 1, false)
    
    if G_isSendAchievementToGoogle() > 0 and G_isLoginGoole then
        require "luascript/script/game/newguid/achievements"
        achievements:clearAll()
    end
    
end

function base:fastTickInit()
    
    local function tmpFastTick(dt)
        return self:fastTick(dt)
    end
    self.fastTickID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tmpFastTick, 0, false)
end

function base:setServerTime(t) --设置服务器时间
    self.serverTime = t
end

function base:addTipsQueue(dialog)
    if #self.tipsQueue > 3 then --防止提示过多
        local index = 1
        for k, v in pairs(self.tipsQueue) do
            if index > 1 then
                self.tipsQueue[k] = nil
            end
            index = index + 1
        end
    end
    table.insert(self.tipsQueue, dialog)
end

function base:playNextTip()
    self.showNextTip = true
end
--不出现loading动画的遮挡
function base:setWait()
    self.lastSetWaitTime = G_getCurDeviceMillTime()
    self.setWaitTime = G_getCurDeviceMillTime()
    if self.waitLayer ~= nil then
        do
            return
        end
        --self.waitLayer:removeFromParentAndCleanup(true)
        --self.waitLayer=nil
    end
    
    self.waitLayer = CCLayer:create()
    self.waitLayer:setTouchEnabled(true)
    self.waitLayer:setBSwallowsTouches(true)
    self.waitLayer:setTouchPriority(-188)
    self.waitLayer:setContentSize(G_VisibleSize)
    self.waitParent = CCDirector:sharedDirector():getRunningScene()
    CCDirector:sharedDirector():getRunningScene():addChild(self.waitLayer)
end

--网络loading动画的遮挡
function base:setNetWait()
    if self.netWaitLayer ~= nil then
        --self.netWaitLayer:removeFromParentAndCleanup(true)
        --self.netWaitLayer=nil
        do
            return
        end
    end
    local function tmpFunc()
        
    end
    
    self.netWaitLayer = LuaCCSprite:createWithSpriteFrameName("BlackAlphaBg.png", tmpFunc)
    self.netWaitLayer:setOpacity(0)
    self.netWaitLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.netWaitLayer:setPosition(ccp(G_VisibleSize.width / 2, G_VisibleSize.height / 2))
    self.netWaitLayer:setScale(50)
    self.netWaitLayer:setTouchPriority(-128)
    
    local pzFrameName = "loading1.png" --loading动画
    local metalSp = CCSprite:createWithSpriteFrameName(pzFrameName)
    local pzArr = CCArray:create()
    for kk = 1, 10 do
        local nameStr = "loading"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        pzArr:addObject(frame)
    end
    local animation = CCAnimation:createWithSpriteFrames(pzArr)
    animation:setDelayPerUnit(0.1)
    local animate = CCAnimate:create(animation)
    metalSp:setAnchorPoint(ccp(0.5, 0.5))
    metalSp:setScale(1 / 50)
    metalSp:setPosition(ccp(self.netWaitLayer:getContentSize().width / 2, self.netWaitLayer:getContentSize().height / 2))
    self.netWaitLayer:addChild(metalSp)
    local repeatForever = CCRepeatForever:create(animate)
    metalSp:runAction(repeatForever)
    self.waitParent = CCDirector:sharedDirector():getRunningScene()
    CCDirector:sharedDirector():getRunningScene():addChild(self.netWaitLayer, 100)
end

function base:cancleWait()
    self.lastSetWaitTime = 0
    if self.waitLayer ~= nil then
        local temLayer = tolua.cast(self.waitLayer, "CCLayer")
        if temLayer ~= nil and temLayer.removeFromParentAndCleanup then
            local curScene = CCDirector:sharedDirector():getRunningScene()
            if(self.waitParent ~= curScene)then
                self.waitLayer = nil
                do return end
            end
            temLayer:removeFromParentAndCleanup(true)
            temLayer = nil
        end
        
        self.waitLayer = nil
    end
    self:cancleNetWait()
end

function base:cancleNetWait()
    if self.netWaitLayer ~= nil and self.netWaitLayer.removeFromParentAndCleanup then
        local curScene = CCDirector:sharedDirector():getRunningScene()
        if(self.waitParent ~= curScene)then
            self.netWaitLayer = nil
            do return end
        end
        self.netWaitLayer:removeFromParentAndCleanup(true)
        self.netWaitLayer = nil
    end
end

function base:addNeedRefresh(dialog)
    table.insert(self.allNeedRefreshDialogs, dialog)
end

function base:removeFromNeedRefresh(dialog)
    for k, v in pairs(self.allNeedRefreshDialogs) do
        if v == dialog then
            self.allNeedRefreshDialogs[k] = nil
        end
    end
end

function base:addNeedRefreshObject(object)
    if self.needRefreshObjectTb == nil then
        self.needRefreshObjectTb = {}
    end
    table.insert(self.needRefreshObjectTb, object)
end

function base:removeNeedRefreshObject(object)
    for k, v in pairs(self.needRefreshObjectTb) do
        if v == object then
            self.needRefreshObjectTb[k] = nil
        end
    end
end

function base:fastTick(dt) --按帧tick,快速tick
    
    if self.lastSetWaitTime ~= 0 then
        if (G_getCurDeviceMillTime() - self.lastSetWaitTime) >= 1000 then --大于一秒后显示loading动画
            
            self:setNetWait()
        end
        
        if (G_getCurDeviceMillTime() - self.lastSetWaitTime) >= 10000 then --大于10秒后,取消全部遮挡
            G_cancleLoginLoading()
            base:cancleWait()
            base:cancleNetWait()
        end
    end
    
    if loginScene.loginSuccess == true then
        worldScene:tick()
        battleScene:fastTick()
        portScene:fastTick()
        mainLandScene:fastTick()
        storyScene:fastTick()
    end
    for k, v in pairs(self.allNeedRefreshDialogs) do
        if v and v.fastTick then
            v:fastTick(dt)
        end
    end
    if self.needRefreshObjectTb then
        for k, v in pairs(self.needRefreshObjectTb) do
            if v and v.fastTick then
                v:fastTick(dt)
            end
        end
    end
end

function base:reSetSendPayParms()
    self.lastSendPayTime = 0
    self.sendPayTimes = 5
    G_setPayment("")
    G_setPaymentUid("")
    
end

function base:tick() --游戏tick入口,每秒tick
    self.googleTime = self.googleTime + 1
    if self.googleTime >= 5 and G_isSendAchievementToGoogle() > 0 and G_isLoginGoole then
        require "luascript/script/game/newguid/achievements"
        achievements:judgeAchievements()
        self.googleTime = 0
    end
    
    self.datiTime = self.datiTime + 1
    self.meirilingjiangTime = self.meirilingjiangTime + 1
    if playerVo.energycd > 0 then
        playerVo.energycd = playerVo.energycd - 1
    end
    
    if playerVoApi.isPlayerLevelUpgrade ~= nil then
        if playerVoApi:isPlayerLevelUpgrade() == true then
            local tmpTb = {}
            tmpTb["action"] = "playerLevelUpgrade"
            tmpTb["parms"] = {}
            tmpTb["parms"]["zoneid"] = tonumber(base.curZoneID)
            tmpTb["parms"]["level"] = playerVoApi:getPlayerLevel()
            local cjson = G_Json.encode(tmpTb)
            G_accessCPlusFunction(cjson)
        end
    end
    
    -- 角色等级提升
    if playerVoApi and playerVoApi.playerLastLevel and playerVoApi.playerLastLevel ~= 0 and playerVoApi:getPlayerLevel() ~= 0 and playerVoApi:getPlayerLevel() > playerVoApi.playerLastLevel and (battleScene == nil or battleScene.isBattleing == false) and (newGuidMgr == nil or newGuidMgr:isNewGuiding() == false) and (otherGuideMgr == nil or otherGuideMgr.isGuiding == false) then
        local lastLevel = playerVoApi.playerLastLevel
        playerVoApi:setPlayerLastLevel(playerVoApi:getUid(), playerVoApi:getPlayerLevel())
        if(G_isHexie() == false)then
            if stewardVoApi and stewardVoApi:isOpen() == true and buildingCueMgr then
                buildingCueMgr:getTipData()
            end
            newTipSmallDialog:showUpgradeDialog(bgSrc, size, fullRect, inRect, textContnt, textSize, lastLevel)
        end
        eventDispatcher:dispatchEvent("player.data.lvlup", lastLevel)
        playerVoApi:onPlayerLvChanged(lastLevel) --玩家等级发生变化的回调
    elseif playerVoApi and playerVoApi.playerLastLevel and playerVoApi.playerLastLevel ~= 0 and playerVoApi:getPlayerLevel() ~= 0 and playerVoApi:getPlayerLevel() > playerVoApi.playerLastLevel and (battleScene == nil or battleScene.isBattleing == false) then
        local lastLevel = playerVoApi.playerLastLevel
        playerVoApi:setPlayerLastLevel(playerVoApi:getUid(), playerVoApi:getPlayerLevel())
        
    end
    
    if playerVoApi and playerVoApi.tick then
        playerVoApi:tick()
    end
    if planeVoApi and planeVoApi.tick then
        planeVoApi:tick()
    end
    if buildDecorateVoApi and buildDecorateVoApi.tick then
        buildDecorateVoApi:tick()
    end
    if supplyShopVoApi and supplyShopVoApi.tick then
        supplyShopVoApi:tick()
    end
    
    if playerVoApi:getPlayerIsATag() == 1 then
        --get
        if (self.lastGetMyAllianceDataTime == 0 or (G_getCurDeviceMillTime() - self.lastGetMyAllianceDataTime) > 60000) and base.pauseSync == false then
            self.lastGetMyAllianceDataTime = G_getCurDeviceMillTime()
            base.allianceTime = nil
            G_getAlliance()
        end
        
    elseif playerVoApi:getPlayerIsATag() == 2 then
        --关面板
        if SizeOfTable(G_AllianceDialogTb) > 0 then
            for k, v in pairs(G_AllianceDialogTb) do
                if v ~= nil and v.close ~= nil then
                    v:close()
                end
            end
        end
        allianceVoApi:clear()--清空自己军团信息和列表信息
        allianceMemberVoApi:clear()--清空成员列表
        allianceApplicantVoApi:clear()--清空
        playerVoApi:clearAllianceData()
    end
    
    G_sendPayment()
    --[[
  if G_getPayment()~="" and playerVoApi:getUid()~=nil and tonumber(G_getPaymentUid())==playerVoApi:getUid() then
    if self.lastSendPayTime==0 then
        self.lastSendPayTime=self.serverTime
    end
 
    if self.serverTime-self.lastSendPayTime>=25 and self.sendPayTimes>0 then
 
        self.lastSendPayTime=self.serverTime;
        self.sendPayTimes=self.sendPayTimes-1;
        local function callback(fn,data)
            local success=base:checkServerData(data)
            if success==true then
            end
        end
        G_sendPayment()
        --socketHelper:userPayment(G_getPayment(),1,callback)
     end
  end
  ]]
    
    if self.lastOnlineTime == 0 or (base.serverTime - self.lastOnlineTime) > 300 then
        self.lastOnlineTime = base.serverTime
        if self.lastOnlineTime == 0 then
            self.lastOnlineTime = 1
        end
        local userRegdate = playerVoApi:getRegdate()
        local today0clock = G_getWeeTs(userRegdate)
        local nowDay = math.floor((base.serverTime - today0clock) / (60 * 60 * 24))
        statisticsHelper:online(nowDay)
    end
    
    if base.needLoginChatServer == true then
        if playerVoApi:getUid() ~= nil then
            socketHelper:chatServerLogin(base.curUid, base.access_token, base.logints, false)
            base.needLoginChatServer = false
        end
    end
    
    if self.lastAutoSyncTime == 0 then
        self.lastAutoSyncTime = self.serverTime
    end
    
    base.curIndex = base.curIndex + 1
    if base.pauseSync == false and battleScene.isBattleing == false and (self.serverTime - self.lastAutoSyncTime) >= 60 and (self.serverTime - base.lastSyncTime) >= 60 then
        self.lastAutoSyncTime = self.serverTime
        local function userSyncCallBack(fn, data)
            --local retTb=OBJDEF:decode(data)
            if self:checkServerData(data) == true then
            end
        end
        if newGuidMgr:isNewGuiding() == false then
            socketHelper:userSync(userSyncCallBack)
        end
        
        if base.isWinter then
            G_setWholeSkin(G_isOpenWinterSkin)
        end
    end
    
    --[[
    if battleScene.isBattleing==false and (self.serverTime-self.lastEventTime)>=300000 then
        self.lastEventTime=self.serverTime
        local function userEventCallBack(fn,data)
            local success,retTb=self:checkServerData(data,false)
            if success==true and retTb.data~=nil and retTb.data.event~=nil then
                local eventData=retTb.data.event
                if eventData.m~=nil then
                    local etype=eventData.m
                    if etype~=3 then
                        G_updateEmailList(etype)
                    end
                end
                if eventData.f==1 then
                    G_SyncData()
                end
            end
        end
        if newGuidMgr:isNewGuiding()==false then
            socketHelper:userEvent(userEventCallBack)
        end
    end
    ]]
    
    base.serverTime = self.localServerTime + math.floor((G_getCurDeviceMillTime() - self.timeCheckDate) / 1000)
    base.curZeroTime = G_getWeeTs(base.serverTime)
    if(base.lastServerTime < base.curZeroTime and base.lastServerTime > 0)then
        eventDispatcher:dispatchEvent("overADay")
        playerVoApi:resetDailyOnlineTime()
    end
    base.lastServerTime = base.serverTime
    playerVoApi:addOnlineTimeAfterTick()
    -- if(deviceHelper and deviceHelper.getDeviceSystemName and deviceHelper:getDeviceSystemName()~="iOS")then
    --     if self.lastServerTime>0 then
    --           if base.serverTime<self.lastServerTime then
    --                 base.serverTime=self.lastServerTime
    --           end
    --     end
    
    --     self.lastServerTime=base.serverTime
    -- end
    if base.lastRecordResourceTime == 0 then
        base.lastRecordResourceTime = base.serverTime
    end
    
    if base.curIndex % 1 == 0 then
        if mainUI:isVisible() == true then
            mainUI:tick(); --刷新mainUI
        end
    end
    
    if mainLandScene ~= nil and mainLandScene.isShowed == true then
        mainLandScene:tick() --刷新地块
    end
    portScene:tick() --刷新port场景地块
    
    if G_phasedGuideOnOff() then
        if playerVoApi:getPlayerLevel() <= 20 then
            touchScene:tick()
        end
    end
    
    if base.curIndex % 10 == 0 then --10秒指挥中心升级一级（测试专用）
        --buildingVoApi:getBuildingVoByBtype(7)[1].level=buildingVoApi:getBuildingVoByBtype(7)[1].level+1
        --buildingVoApi:getBuildingVoByBtype(8)[1].level=buildingVoApi:getBuildingVoByBtype(8)[1].level+1
    end
    
    if worldBaseVoApi and worldBaseVoApi.tick then
        worldBaseVoApi:tick()
    end
    buildingSlotVoApi:tick() --刷新建筑队列
    technologySlotVoApi:tick() --刷新科技队列
    workShopSlotVoApi:tick() --刷新道具生产队列
    tankSlotVoApi:tick() --坦克生产队列
    tankUpgradeSlotVoApi:tick() --坦克改装队列
    useItemSlotVoApi:tick() --使用增益道具队列
    attackTankSoltVoApi:tick() --出战坦克队列
    alienMinesVoApi:tick() -- 异星矿场零点刷新
    allianceFubenVoApi:tick() --军团副本刷新
    if arenaVoApi ~= nil then --刷新竞技场cdtime
        arenaVoApi:tick()
    end
    if base.curIndex % 1 == 0 then --1秒建筑刷新一次
        buildings:tick()
    end
    for k, v in pairs(self.allNeedRefreshDialogs) do
        v:tick()
    end
    if self.showNextTip == true then
        
        if #self.tipsQueue > 0 then
            self.showNextTip = false
            for k, v in pairs(self.tipsQueue) do
                v:showTips()
                self.tipsQueue[k] = nil
                do
                    break
                end
            end
        end
    end
    
    --[[
    if (base.serverTime-base.lastRecordResourceTime)>=60 then --计算资源产量
         local ptime=math.floor((base.serverTime-base.lastRecordResourceTime)/60) --取整，60秒一个生产周期
         
         base.lastRecordResourceTime=base.lastRecordResourceTime+ptime*60
         
 
         playerVoApi:produceResource(ptime)
    end
    ]]
    --计算能量恢复
    --世界地图刷新
    --worldScene:tick()
    global:tick()
    battleScene:showZWTick()
    socketHelper:slowTick()
    if worldScene.clayer ~= nil then
        worldScene:worldBaseTick()
    end
    --[[
    --主基地升级feed
    if battleScene.isBattleing==false and self.isShowFeedDialog==true then
        self.isShowFeedDialog=false
        smallDialog:showUpgradeFeedDialog("PanelPopup.png",CCSizeMake(500,380),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,7)
    end
    ]]
    if self.releaseLoadingImg == true then
        self.releaseLoadingImg = false
        CCTextureCache:sharedTextureCache():removeTextureForKey("scene/lodingxin.jpg")
        --CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
    end
    if base.lastPullActivityDataTime == 0 then
        base.lastPullActivityDataTime = base.serverTime
    end
    if (base.serverTime - base.lastPullActivityDataTime) >= 10 then
        base.lastPullActivityDataTime = base.serverTime
        activityVoApi:tick()
    end
    
    local vo = activityVoApi:getActivityVo("double11")
    if vo and activityVoApi:isStart(vo) == true and acDouble11VoApi:getStEdTime() ~= nil then
        local isInTime, curTimeHour, curTimeMin, isFirstChat = acDouble11VoApi:isInTime()
        if acDouble11VoApi:isLastTim() == false and (isInTime or isFirstChat) then
            if tonumber(curTimeMin) > 54 and acDouble11VoApi:getChatSillValue() == 0 then
                acDouble11VoApi:setChatSillValue(1)
                local otherData, shopIdx2 = acDouble11VoApi:returWhiPanicShop(true)
                shopIdx2 = isFirstChat == true and 1 or shopIdx2
                local paramTab = {}
                paramTab.functionStr = "double11"
                paramTab.addStr = "goTo_see_see"
                local params = {subType = 4, contentType = 3, message = {key = "double11_willSell_chatSystemMessage", param = {getlocal("activity_double11_shopName_"..shopIdx2), 60 - curTimeMin}}, ts = base.serverTime, paramTab = paramTab}
                chatVoApi:addChat(1, 0, "", 0, "", params, base.serverTime)
            elseif tonumber(curTimeMin) < 54 and acDouble11VoApi:getChatSillValue() == 1 then
                acDouble11VoApi:setChatSillValue(0)
                local otherData, shopIdx = acDouble11VoApi:returWhiPanicShop()
                local paramTab = {}
                paramTab.functionStr = "double11"
                paramTab.addStr = "goTo_see_see"
                local params = {subType = 4, contentType = 3, message = {key = "double11_SellNow_chatSystemMessage", param = {getlocal("activity_double11_shopName_"..shopIdx)}}, ts = base.serverTime, paramTab = paramTab}
                chatVoApi:addChat(1, 0, "", 0, "", params, base.serverTime)
            end
        end
    end
    local vo = activityVoApi:getActivityVo("new112018")
    if vo and activityVoApi:isStart(vo) == true and acDoubleOneVoApi:getStEdTime() ~= nil then
        local isInTime, curTimeHour, curTimeMin, isFirstChat = acDoubleOneVoApi:isInTime()
        if acDoubleOneVoApi:isLastTim() == false and (isInTime or isFirstChat) then
            if tonumber(curTimeMin) > 54 and acDoubleOneVoApi:getChatSillValue() == 0 then
                acDoubleOneVoApi:setChatSillValue(1)
                local otherData, shopIdx2 = acDoubleOneVoApi:returWhiPanicShop(true)
                shopIdx2 = isFirstChat == true and 1 or shopIdx2
                local paramTab = {}
                paramTab.functionStr = "new112018"
                paramTab.addStr = "goTo_see_see"
                local params = {subType = 4, contentType = 3, message = {key = "new112018_willSell_chatSystemMessage", param = {getlocal("activity_double11_shopName_"..shopIdx2), 60 - curTimeMin}}, ts = base.serverTime, paramTab = paramTab}
                chatVoApi:addChat(1, 0, "", 0, "", params, base.serverTime)
            elseif tonumber(curTimeMin) < 54 and acDoubleOneVoApi:getChatSillValue() == 1 then
                acDoubleOneVoApi:setChatSillValue(0)
                local otherData, shopIdx = acDoubleOneVoApi:returWhiPanicShop()
                local paramTab = {}
                paramTab.functionStr = "new112018"
                paramTab.addStr = "goTo_see_see"
                local params = {subType = 4, contentType = 3, message = {key = "new112018_SellNow_chatSystemMessage", param = {getlocal("activity_double11_shopName_"..shopIdx)}}, ts = base.serverTime, paramTab = paramTab}
                chatVoApi:addChat(1, 0, "", 0, "", params, base.serverTime)
            end
        end
    end
    
    local vo = activityVoApi:getActivityVo("onlineReward")
    if vo and activityVoApi:isStart(vo) == true then
        acOnlineRewardVoApi:addOnlineTimeAfterTick()
    end
    
    local vo = activityVoApi:getActivityVo("online2018")
    if vo and activityVoApi:isStart(vo) == true then
        acOnlineRewardXVIIIVoApi:addOnlineTimeAfterTick()
    end
    
    if allianceFubenScene then
        allianceFubenScene:tick() --军团副本更新
    end
    
    if serverWarPersonalVoApi and serverWarPersonalVoApi.tick then
        serverWarPersonalVoApi:tick()
    end
    -- 跨天礼物刷新
    if friendInfoVoApi and friendInfoVoApi.updateGift then
        friendInfoVoApi:updateGift()
    end
    
    if base.serverWarTeamSwitch == 1 and serverWarTeamVoApi and serverWarTeamVoApi.tick then
        serverWarTeamVoApi:tick()
    end
    
    if base.boss == 1 and BossBattleVoApi and BossBattleVoApi.tick then
        BossBattleVoApi:tick()
    end
    
    if base.worldWarSwitch == 1 and worldWarVoApi and worldWarVoApi.tick then
        worldWarVoApi:tick()
    end
    
    if base.dailychoice == 1 and dailyAnswerVoApi and dailyAnswerVoApi.tick then
        dailyAnswerVoApi:tick()
    end
    
    if base.ifSuperWeaponOpen == 1 and superWeaponVoApi and superWeaponVoApi.tick then
        local superWeaponOpenLv = base.superWeaponOpenLv or 25
        if(playerVoApi:getPlayerLevel() >= superWeaponOpenLv)then
            superWeaponVoApi:tick()
        end
    end
    if base.rewardcenter == 1 then
        if rewardCenterVoApi and rewardCenterVoApi.rtime == base.serverTime then
            local function callback(fn, data)
                local ret, sData = base:checkServerData(data)
            end
            socketHelper:getRewardCenterList(1, rewardCenterVoApi:getMaxNum(), callback)
        end
    end
    
    if base.allianceHelpSwitch == 1 and allianceHelpVoApi and allianceHelpVoApi.tick then
        allianceHelpVoApi:tick()
    end
    
    G_checkAsynHttpTb()
    
    -- 飘字提示
    if self.allShowTipStrTb and SizeOfTable(self.allShowTipStrTb) > 0 then
        if type(self.allShowTipStrTb[1]) == "table" then
            if self.allShowTipStrTb[1][2] > 0 then
                self.allShowTipStrTb[1][2] = self.allShowTipStrTb[1][2] - 1
            elseif self.allShowTipStrTb[1][1] then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), self.allShowTipStrTb[1][1], 30, nil, false)
                table.remove(self.allShowTipStrTb, 1)
            end
        elseif self.allShowTipStrTb[1] then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), self.allShowTipStrTb[1], 30, nil, false)
            table.remove(self.allShowTipStrTb, 1)
        end
    end
    
    if buildingCueMgr and buildingCueMgr.tick then
        buildingCueMgr:tick()
    end
    
    if protocolController and protocolController.tick then
        protocolController:tick()
    end
    if noteVoApi and noteVoApi.tick then
        noteVoApi:tick()
    end
    if ltzdzVoApi and ltzdzVoApi.tick then
        ltzdzVoApi.tick()
    end
    if ltzdzFightApi and ltzdzFightApi.tick then
        ltzdzFightApi.tick()
    end
    if believerVoApi and believerVoApi.tick then
        believerVoApi:tick()
    end
    -- local recoverLeft=rebelVoApi:getEnergyRecoverTs() - base.serverTime
    -- print(getlocal("worldRebel_buyEnergyConfirm1",{GetTimeStr(recoverLeft)}))
end

function base:formatPlayerData(data)
    local sData = data
    
    if sData.access_token ~= nil then
        self.access_token = sData.access_token
    end
    
    if sData.logints ~= nil then
        self.logints = sData.logints
    end
    
    --设置最大等级相关配置
    if sData.data.lv ~= nil then
        local lvTb = sData.data.lv
        for k, v in pairs(lvTb) do
            print("aa=", k, v)
        end
        for k, v in pairs(playerVoApi.maxLevelKeyTb) do
            playerVoApi:setMaxLvByKey(lvTb[k], v)
        end
        for k, v in pairs(playerVoApi.maxLevelTb) do
            print("maxLevelTb=", k, v)
        end
    end
    if sData.timezone ~= nil then
        base.curTimeZone = tonumber(sData.timezone)
        print("时区是什么", base.curTimeZone)
    end
    
    if sData.data == nil then
        do
            return
        end
    end
    --[[
      if sData.data.userinfo_ext~=nil and sData.data.userinfo_ext.daily_honors~=nil then
        local userInfoDaily_honors=sData.data.userinfo_ext.daily_honors
        self.userInfoDaily_honors=userInfoDaily_honors
      end
      ]]
    
    local meirilingjiang = sData.data.dailyenergy
    if meirilingjiang then
        self.meirilingjiangNoon = meirilingjiang.r[1]
        self.meirilingjiangNight = meirilingjiang.r[2]
        self.meirilingjiangDayTs = meirilingjiang.t
    end
    if(self.meirilingjiangDayTs and self.meirilingjiangDayTs < G_getWeeTs(base.serverTime))then
        self.meirilingjiangNoon = 0
        self.meirilingjiangNight = 0
        if(receivereward1Vo)then
            receivereward1Vo:setReceive(false)
            receivereward1VoApi.flag = false
        end
        if(receivereward2Vo)then
            receivereward2Vo:setReceive(false)
            receivereward2VoApi.flag = false
        end
    end
    
    local userInfo = sData.data.userinfo
    if userInfo ~= nil then
        if G_curPlatName() == "androidzhongshouyouru" or G_curPlatName() == "12" then --俄罗斯平台需要按照玩家等级弹板
            local tmpLvTb = {4, 10, 15, 20}
            local tmpPropTb = {1030, 1031, 1032, 1033}
            local hasArrivedLv = false
            local arrivedLv = 1
            local propId = 0
            for kk = 1, 4 do
                if playerVoApi:getPlayerLevel() == (tonumber(tmpLvTb[kk]) - 1) and userInfo.level == tonumber(tmpLvTb[kk]) then
                    hasArrivedLv = true
                    arrivedLv = tonumber(tmpLvTb[kk])
                    propId = tmpPropTb[kk]
                end
            end
            if hasArrivedLv == true then
                smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("playerLevelArrivedLevel", {arrivedLv, getlocal("sample_prop_name_"..propId)}), nil, 50000)
            end
        end
        playerVoApi:add(userInfo)
        if userInfo.alliancename == nil then
            global.hasAllianceFunc = false
        else
            global.hasAllianceFunc = true
        end
        
        if userInfo.flags ~= nil then
            local userFlags = userInfo.flags
            if userFlags.daily_honors ~= nil then
                local userInfoDaily_honors = userFlags.daily_honors
                self.userInfoDaily_honors = userInfoDaily_honors
            end
            -- daily_buy_energy={"num":0,"ts":}
            if userFlags.daily_buy_energy ~= nil then
                self.daily_buy_energy = userFlags.daily_buy_energy
            end
            --每日抽奖
            if userFlags.daily_lottery ~= nil then
                local dailyData = userFlags
                --[[
                          dailyVoApi:clearDaily()
                          dailyVoApi:formatData(dailyData)
                          ]]
                if dailyData and dailyData.daily_lottery then
                    dailyVoApi:clearDaily()
                    dailyVoApi:formatData(dailyData.daily_lottery)
                end
            end
            if userFlags.newuser_7d_award then
                newGiftsVoApi:clear()
                newGiftsVoApi:formatData(userFlags.newuser_7d_award)
            else
                newGiftsVoApi:clear()
                newGiftsVoApi:formatData()
            end
            if userFlags.daily_award ~= nil then
                self.daily_award = userFlags.daily_award
            end
            activityVoApi:updateIsReward(userFlags.active)
            --明日战力暴增是否领取
            if userFlags.nextday ~= nil then
                self.nextDay = userFlags.nextday
            end
            
            --游戏设置与后台通信
            if userFlags.gameSetting ~= nil then
                local gameSettingData = userFlags.gameSetting
                --是否自动补充防守舰队
                if gameSettingData.s4 ~= nil then
                    local switch = tonumber(gameSettingData.s4)
                    if switch == 1 then
                        CCUserDefault:sharedUserDefault():setIntegerForKey(G_local_autoDefence, 2)
                        CCUserDefault:sharedUserDefault():flush()
                    elseif switch == 0 then
                        CCUserDefault:sharedUserDefault():setIntegerForKey(G_local_autoDefence, 1)
                        CCUserDefault:sharedUserDefault():flush()
                    end
                end
            end
            
            --签到
            if userFlags.sign then
                signVoApi:clear()
                signVoApi:formatData(userFlags.sign)
            end
            if userFlags.newSign then
                if userFlags.newSign.signST then
                    if G_getDate(userFlags.newSign.signST).month == G_getDate(base.serverTime).month then
                        newSignInVoApi:resetData(userFlags.newSign)
                    elseif userFlags.newSign.ver then
                        newSignInVoApi:setVer(userFlags.newSign.ver)
                        -- newSignInVoApi:setCurMonTH( )
                    end
                else
                    newSignInVoApi:resetData(userFlags.newSign)
                end
            end
            --公告领奖
            if userFlags.cmp then
                noteVoApi:setHadReward(userFlags.cmp)
            end
            if userFlags.evaluate ~= nil then
                self.isUserEvaluate = userFlags.evaluate
            end
            if userFlags.sadf then
                self.stateOfGarrsion = userFlags.sadf
            end
            if userFlags.goldMine then --记录每日累计采集的金币数
                local gemsData = {gems = userFlags.goldMine[1], ts = userFlags.goldMine[2]}
                goldMineVoApi:setDailyGemsData(gemsData)
            end
            if(userFlags.real)then
                playerVoApi.realNameRegist = true
            end
            if(userFlags.gerb)then
                dailyActivityVoApi.movgaBindFlag = tonumber(userFlags.gerb)
            end
        end
        --推送功能后台存储的用户ID
        if userInfo.email ~= nil then
            pushController:setServerUserID(userInfo.email)
        end
    end
    
    if sData.data.jobs ~= nil and sData.cmd == "user.login" then
        if self.localWarSwitch == 1 and localWarVoApi and localWarVoApi.setSelfOffice then
            localWarVoApi:setSelfOffice(sData.data.jobs)
        end
    end
    
    ---更新建筑信息
    if SizeOfTable(buildingVoApi.allBuildings) == 0 then
        buildingVoApi:init()
    end
    if sData.data.buildings ~= nil then
        -- dmj添加自动建造时，临时注释
        -- buildingVoApi:clear()
        -- buildingVoApi:init()
        -- local buildsData=sData.data.buildings
        -- for k,v in pairs(buildsData) do
        --     if k~="queue" then
        --         local bid=tonumber(RemoveFirstChar(k))
        --         local btype=v[1]
        --         local blevel=v[2]
        --         buildingVoApi:initBuild(bid,btype,blevel)
        --     end
        -- end
        -- buildingVoApi:unlockBuildingByCommanderCenterLevel()
        
        buildingVoApi:clear()
        buildingVoApi:init()
        local buildsData = sData.data.buildings
        for k, v in pairs(buildsData) do
            --print("buildingsData",k,v)
            if k ~= "queue" and k ~= "auto" and k ~= "auto_expire" and k ~= "remove_ts" then
                local bid = tonumber(RemoveFirstChar(k))
                -- print("init get bid=====>>>>",bid,v[1],v[2])
                local btype = v[1]
                local blevel = v[2]
                buildingVoApi:initBuild(bid, btype, blevel)
            end
        end
        
        if buildsData.queue ~= nil then
            -- print("更新建筑升级队列")
            local buildingQueue = buildsData.queue
            if sData.cmd == "user.sync" then
                local bSlot = buildingQueue
                buildingSlotVoApi:judgeAndShowSlot(bSlot)
            end
            buildingSlotVoApi:clear()
            local bSlot = buildingQueue
            for k, v in pairs(bSlot) do
                -- print("更新建筑升级队列")
                buildingSlotVoApi:add(tonumber(RemoveFirstChar(v.id)), v.st, v.et, v.hid)
            end
        end
        
        buildingVoApi:unlockBuildingByCommanderCenterLevel()
        
        -- 是否开启自动升级
        buildingVoApi:setAutoUpgradeBuilding(buildsData.auto)
        -- 自动升级道具剩余时间
        buildingVoApi:setAutoUpgradeExpire(buildsData.auto_expire)
        --设置拆除建筑的cd时间
        buildingVoApi:setRemoveBuildTs(buildsData.remove_ts)
        
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
    ---更新技能
    if sData.data.skills ~= nil then
        local skills = sData.data.skills
        skillVoApi:update(sData.data.skills)
    end
    ---更新科技
    if sData.data.techs ~= nil then
        local techs = sData.data.techs
        local tmpTb = {}
        for k, v in pairs(techs) do
            if k ~= "queue" then
                tmpTb[tonumber(RemoveFirstChar(k))] = tonumber(v)
            end
        end
        if SizeOfTable(tmpTb) > 0 then
            technologyVoApi:update(tmpTb)
        end
    end
    
    ---更新建筑队列
    
    if sData.data.buildings ~= nil and sData.data.buildings.queue ~= nil then
        local buildingQueue = sData.data.buildings.queue
        if sData.cmd == "user.sync" then
            local bSlot = buildingQueue
            buildingSlotVoApi:judgeAndShowSlot(bSlot)
        end
        buildingSlotVoApi:clear()
        local bSlot = buildingQueue
        for k, v in pairs(bSlot) do
            buildingSlotVoApi:add(tonumber(RemoveFirstChar(v.id)), v.st, v.et, v.hid)
        end
    end
    ---更新科技队列
    -- if sData.data.queue~=nil and sData.data.queue.tech~=nil then
    if sData.data.techs ~= nil and sData.data.techs.queue ~= nil then
        local oldNum = 0
        local allSlots = technologySlotVoApi:getAllSlots()
        if allSlots then
            oldNum = SizeOfTable(allSlots)
        end
        technologySlotVoApi:clear()
        -- local tSlot=sData.data.queue.tech
        local tSlot = sData.data.techs.queue
        for k, v in pairs(tSlot) do
            technologySlotVoApi:add(tonumber(RemoveFirstChar(v.id)), v.st, v.et, v.timeConsume, v.slotid, v.hid)
        end
        technologyVoApi:resetStatus()
        local newNum = 0
        local allSlots1 = technologySlotVoApi:getAllSlots()
        if allSlots1 then
            newNum = SizeOfTable(allSlots1)
        end
        print("oldNum,newNum", oldNum, newNum)
        if oldNum ~= newNum then
            technologySlotVoApi:setFlag(0)
        end
    end
    ---更新道具建造队列
    -- if sData.data.queue~=nil and sData.data.queue.prop~=nil then
    -- local propQueue=sData.data.queue.prop
    if sData.data.props ~= nil and sData.data.props.queue ~= nil then
        local propQueue = sData.data.props.queue
        if sData.cmd == "user.sync" then
            workShopSlotVoApi:judgeAndShowSlot(propQueue)
        end
        workShopSlotVoApi:clear()
        local bSlot = propQueue
        for k, v in pairs(bSlot) do
            local tid = tonumber(RemoveFirstChar(v.id))
            workShopSlotVoApi:add(v.slotid, tid, v.nums, v.st, v.et, v.st, v.timeConsume)
        end
        
    end
    
    ---更新坦克改装队列
    -- if sData.data.queue~=nil and sData.data.queue.tankdiy1~=nil then
    -- local tankdiyQueue=sData.data.queue.tankdiy1
    if sData.data.troops ~= nil and sData.data.troops.queue ~= nil and sData.data.troops.queue.tankdiy1 ~= nil then
        local tankdiyQueue = sData.data.troops.queue.tankdiy1
        if sData.cmd == "user.sync" then
            tankUpgradeSlotVoApi:judgeAndShowSlot(13, tankdiyQueue)
        end
        tankUpgradeSlotVoApi:clear(13)
        local bSlot = tankdiyQueue
        for k, v in pairs(bSlot) do
            local tid = tonumber(RemoveFirstChar(v.id))
            tankUpgradeSlotVoApi:add(13, v.slotid, tid, v.nums, v.st, v.et, v.st, v.timeConsume)
        end
        
    end
    ---更新坦克制造队列
    -- if sData.data.queue~=nil and sData.data.queue.tank~=nil and sData.data.queue.tank.b11~=nil then
    -- local tankQueue1=sData.data.queue.tank.b11
    if sData.data.troops ~= nil and sData.data.troops.queue ~= nil and sData.data.troops.queue.tank1 ~= nil then
        local tankQueue1 = sData.data.troops.queue.tank1
        if sData.cmd == "user.sync" then
            tankSlotVoApi:judgeAndShowSlot(11, tankQueue1)
        end
        tankSlotVoApi:clear(11)
        local bSlot = tankQueue1
        for k, v in pairs(bSlot) do
            local tid = tonumber(RemoveFirstChar(v.id))
            tankSlotVoApi:add(11, v.slotid, tid, v.nums, v.st, v.et, v.st, v.timeConsume)
        end
        
    end
    -- if sData.data.queue~=nil and sData.data.queue.tank~=nil and sData.data.queue.tank.b12~=nil then
    -- local tankQueue2=sData.data.queue.tank.b12
    if sData.data.troops ~= nil and sData.data.troops.queue ~= nil and sData.data.troops.queue.tank2 ~= nil then
        local tankQueue2 = sData.data.troops.queue.tank2
        if sData.cmd == "user.sync" then
            tankSlotVoApi:judgeAndShowSlot(12, tankQueue2)
        end
        tankSlotVoApi:clear(12)
        local bSlot = tankQueue2
        for k, v in pairs(bSlot) do
            local tid = tonumber(RemoveFirstChar(v.id))
            tankSlotVoApi:add(12, v.slotid, tid, v.nums, v.st, v.et, v.st, v.timeConsume)
        end
        
    end
    --更新增益道具队列
    if sData.data.props ~= nil and sData.data.props.info ~= nil then
        useItemSlotVoApi:clear()
        local bSlot = sData.data.props.info
        for k, v in pairs(bSlot) do
            local itemId = tonumber(RemoveFirstChar(v.id))
            useItemSlotVoApi:add(itemId, v.st, v.et)
        end
    end
    --更新军功商店购买信息
    if sData.data.props ~= nil and sData.data.props.shop ~= nil then
        dailyActivityVoApi:formatData({rpShop = sData.data.props.shop})
        if sData.data.props.shop.buy then
            checkPointVoApi:setBuyRaidsData(sData.data.props.shop.buy)
        end
    end
    --更新坦克
    if sData.data.troops ~= nil and sData.data.troops.troops ~= nil then
        
        tankVoApi:clearTanks()
        if SizeOfTable(sData.data.troops.troops) == 0 then
            portScene:initTanks()
        else
            local bSlot = sData.data.troops.troops
            for k, v in pairs(bSlot) do
                local itemId = tonumber(RemoveFirstChar(k))
                local count = v
                tankVoApi:addTank(itemId, count)
            end
            portScene:initTanks()
        end
        if FuncSwitchApi:isEnabled("diku_repair") == false then
            tankWarehouseScene:initOldTanks()
        end
    end
    
    ---更新背包
    
    if sData.data.bag ~= nil and sData.data.bag.info ~= nil then
        bagVoApi:clear()
        local bSlot = sData.data.bag.info
        for k, v in pairs(bSlot) do
            local itemId = tonumber(RemoveFirstChar(k))
            bagVoApi:addBag(itemId, v, sData.cmd == "user.login")
        end
    end
    --更新优惠商店道具购买数据
    if sData.data.bag ~= nil and sData.data.bag.binfo ~= nil then
        allShopVoApi:setSpecialShopBuyData(sData.data.bag.binfo)
    end
    --使用异星科技类物品
    if sData.cmd == "prop.use" and sData.data.alien then
        if base.alien == 1 and alienTechVoApi then
            alienTechVoApi:setTechData(sData.data.alien)
            alienTechVoApi:getTreeCfg()
            alienTechVoApi:setResFlag(0)
        end
    end
    
    if sData.data.mail ~= nil then
        --打开邮件列表 分页显示
        if sData.cmd == "mail.list" then
            local emails = sData.data.mail
            emailVoApi:formatData(emails)
            alienMinesEmailVoApi:formatData(emails)
        end
        --发送邮件
        if sData.cmd == "mail.send" and sData.data.mail.sent then
            local data = sData.data.mail.sent
            emailVoApi:addEmail(3, data)
        end
        --侦查报告
        if (sData.cmd == "map.scout" or sData.cmd == "map.rebelscout") and sData.data.mail.report then
            local data = sData.data.mail.report
            emailVoApi:addEmail(2, data)
        end
        if sData.cmd == "map.alienscout" and sData.data.mail.alienreport then
            local data = sData.data.mail.alienreport
            alienMinesEmailVoApi:addEmail(data)
        end
        --未读信息
        if sData.data.mail.unread then
            local unreadData = sData.data.mail.unread
            emailVoApi:formatUnread(unreadData)
            alienMinesEmailVoApi:formatUnread(unreadData)
        end
    end
    
    ---查看邮件内容
    if sData.cmd == "mail.read" and sData.data.msg ~= nil then
        local data = sData.data.msg
        if data then
            if data.type and tonumber(data.type) and tonumber(data.type) == 4 then
                alienMinesEmailVoApi:addContent(data)
            else
                emailVoApi:addContent(data)
            end
        end
    end
    
    -- 设置邮件状态
    if sData.data.mailstate ~= nil then
        emailVoApi:formatAutoDeleteAndReceive(sData.data.mailstate)
    end
    
    ---更新收藏
    if sData.data.bookmark ~= nil and sData.data.bookmark.info ~= nil then
        bookmarkVoApi:clearBookmark()
        local bSlot = sData.data.bookmark.info
        if type(bSlot) == type(table) then
            for k, v in pairs(bSlot) do
                local mid = tonumber(RemoveFirstChar(k))
                if v[2] ~= nil and v[3] ~= nil then
                    bookmarkVoApi:addBookmark(mid, v[4], v[1], v[2], v[3], v[5])
                else
                    bookmarkVoApi:addBookmark(mid, v.type, v.name, v.mapx, v.mapy)
                end
            end
        end
        
    end
    
    --用户的关卡数据
    if sData.data.challenge ~= nil then
        local challengeData = sData.data.challenge
        checkPointVoApi:formatStoryData(challengeData)
    end
    ---关卡数据
    if sData.cmd == "challenge.list" and sData.data.challenge ~= nil then
        if sData.data.challenge then
            local data = {}
            if sData.data.challenge.info then
                data = sData.data.challenge.info
            end
            checkPointVoApi:formatData(data)
        end
    end
    --关卡战斗
    if sData.cmd == "challenge.battle" and sData.data ~= nil then
        if sData.data.challenge ~= nil and sData.data.challenge then
            local challenge = sData.data.challenge
            checkPointVoApi:updateChapter(challenge)
        end
    end
    --关卡科技
    if sData.cmd == "challenge.rewardlist" and sData.data ~= nil then
        checkPointVoApi:formatTechData(sData.data)
    end
    
    --更新防守坦克
    if sData.data.troops ~= nil and sData.data.troops.defense ~= nil then
        tankVoApi:clearTemDefenseTanks()
        local bSlot = sData.data.troops.defense
        for k, v in pairs(bSlot) do
            if SizeOfTable(v) > 0 then
                local mid = tonumber(RemoveFirstChar(v[1]))
                tankVoApi:setTemDefenseTanks(k, mid, v[2])
            end
        end
        
    end
    --更新修复坦克
    if sData.data.troops ~= nil and sData.data.troops.damaged ~= nil then
        tankVoApi:clearRepairTanks()
        local bSlot = sData.data.troops.damaged
        for k, v in pairs(bSlot) do
            local mid = tonumber(RemoveFirstChar(k))
            tankVoApi:setRepairTanks(mid, v)
        end
        tankVoApi:clearProdamagedTanks() --清空保护的坦克数量
        if sData.data.troops.prodamaged then
            tankVoApi:setProdamagedTanks(sData.data.troops.prodamaged)
        end
    end
    --更新出战坦克队列
    if sData.data.troops ~= nil and sData.data.troops.attack ~= nil then
        attackTankSoltVoApi:updateAttackSlots(sData.data)
    end
    
    --[[
      --每日抽奖
      if sData.data.userinfo_ext~=nil then
          local data=sData.data.userinfo_ext
          dailyVoApi:clearDaily()
          dailyVoApi:formatData(data)
      end
      ]]
    
    --普通任务更新
    if sData.data.task ~= nil then
        local data = sData.data.task.info
        if data then
            taskVoApi:clearTasks()
            taskVoApi:formatTask(data)
            taskVoApi:setRefreshFlag(0)
        end
    end
    
    --日常任务更新
    if sData.data.dailytask ~= nil then
        local isShowNew = taskVoApi:isShowNew()
        -- local data=sData.data.dailytask.info
        local data--=sData.data.dailytask.newinfo
        if isShowNew == true then--最新版，重新用旧的info
            data = sData.data.dailytask.info
        else
            data = sData.data.dailytask.newinfo
        end
        if data then
            taskVoApi:clearDailyTasks()
            if isShowNew == true then
                taskVoApi:initNewDailyTask()
                taskVoApi:formatNewDailyTask(data)
            else
                taskVoApi:formatDailyTask(data)
            end
            taskVoApi:setRefreshFlag(0)
        end
        if sData.data.dailytask.flag then
            taskVoApi:setFlag(sData.data.dailytask.flag)
        end
    end
    
    ---战斗力排行榜 分页显示
    if sData.cmd == "ranking.fc" and sData.data ~= nil then
        local rankData = sData.data
        --rankVoApi:clearFightingRank()
        rankVoApi:formatRank(1, rankData)
    end
    ---关卡排行榜 分页显示
    if sData.cmd == "ranking.challenge" and sData.data ~= nil then
        local rankData = sData.data
        --rankVoApi:clearStarRank()
        rankVoApi:formatRank(2, rankData)
    end
    ---荣誉排行榜 分页显示
    if sData.cmd == "ranking.honors" and sData.data ~= nil then
        local rankData = sData.data
        --rankVoApi:clearCreditRank()
        rankVoApi:formatRank(3, rankData)
    end
    
    --敌军来袭
    if sData.data.troops ~= nil and sData.data.troops.invade ~= nil then
        local invade = sData.data.troops.invade
        enemyVoApi:formatData(invade)
        if worldScene ~= nil then
            worldScene:checkEndTankSlot(true)
        end
    end
    --协防
    if sData.data.troops ~= nil and sData.data.troops.helpdefense ~= nil then
        local helpdefense = sData.data.troops.helpdefense
        helpDefendVoApi:clear()
        helpDefendVoApi:formatData(helpdefense)
    end
    --协防部队
    -- if sData.data.helpDefenseInfo~=nil then
    --     print("sData.data.helpDefenseInfo",sData.data.helpDefenseInfo)
    --     local defenseInfo=sData.data.helpDefenseInfo
    --     helpDefendVoApi:formatTankInfo(defenseInfo)
    -- end
    if sData.data.championwar then --军团锦标赛赛季相关时间
        championshipWarVoApi:setChampionshipWarSeasonInfo(sData.data.championwar)
    end
    
    --登录统计
    if sData.cmd == "user.login" then
        local userRegdate = playerVoApi:getRegdate()
        local today0clock = G_getWeeTs(userRegdate)
        local nowDay = math.floor((base.serverTime - today0clock) / (60 * 60 * 24))
        --发送连续登录天数
        local isactive
        if(sData.data and sData.data.userinfo)then
            isactive = sData.data.userinfo.isactive
        end
        if(G_isGlobalServer())then
            statisticsHelper.appid = G_getPlatAppID()
        end
        statisticsHelper:login(nowDay, isactive)
    end
    
    --军团
    
    --[[
      --已经申请的军团aid列表
      if sData.data.alliance~=nil and sData.data.alliance.user~=nil and sData.data.alliance.user.requests then
          local requestsList=sData.data.alliance.user.requests
          if type(requestsList)=="table" then
              allianceVoApi:updateRequestsList(requestsList)
          end
      end
      ]]
    --初始化军团信息
    if sData.data.alliance ~= nil and sData.data.alliance.alliance ~= nil then
        
        if sData.data.alliance.alliance.updated_at ~= nil then
            base.allianceTime = sData.data.alliance.alliance.updated_at;
        end
        if(sData.data.alliance.allianceMaxLevel ~= nil)then
            allianceVoApi:setMaxLevel(sData.data.alliance.allianceMaxLevel)
        end
        if SizeOfTable(sData.data.alliance.alliance) == 0 then
            allianceVoApi:clearSelfAlliance()
        else
            if sData.data.alliance.user ~= nil then
                local userData = sData.data.alliance.user
                if userData.role ~= nil then
                    allianceVoApi:setRole(userData)
                end
            end
            if sData.data.alliance.alliance ~= nil then
                local allianceData = sData.data.alliance.alliance
                allianceVoApi:formatSelfAllianceData(allianceData)
                local skillTb = sData.data.alliance.alliance.skills
                allianceSkillVoApi:addAllianceSkill(skillTb)
            end
        end
        
        if sData.data.alliance.alliance.glevel or sData.data.alliance.alliance.gexp then--军团礼包
            allianceGiftVoApi:updateSpecialData(sData.data.alliance.alliance)
        end
        if sData.data.alliance.user ~= nil then
            playerVoApi:setCreateAt(sData.data.alliance.user.create_at)
        end
    end
    if sData.data.alliance ~= nil and sData.data.alliance.apply ~= nil then
        allianceVoApi:formatAllianceWrData(sData.data.alliance.apply)
    end
    if sData.data.alliance ~= nil and sData.data.alliance.allianceDonateMembers ~= nil then
        allianceVoApi:setAllianceDonateMembers(sData.data.alliance.allianceDonateMembers)
    end
    if sData.data.alliance ~= nil and sData.data.alliance.addDonateCount ~= nil then
        allianceVoApi:setAllianceAddDonateCount(sData.data.alliance.addDonateCount)
    end
    --是否领取首次加入军团的奖励
    if sData.data.alliance ~= nil and sData.data.alliance.user ~= nil then
        if self.joinReward == -1 then
            self.joinReward = 0
        end
        if sData.data.alliance.user.oc ~= nil then
            self.joinReward = tonumber(sData.data.alliance.user.oc)
        end
    end
    
    --军团列表
    if sData.data.alliance ~= nil and (sData.data.alliance.list or sData.data.alliance.ranklist or sData.data.alliance.searchlist or sData.data.alliance.mylist) then
        allianceVoApi:formatData(sData.data.alliance)
    end
    
    if sData.data.alliance ~= nil and sData.data.alliance.alliance ~= nil and sData.data.alliance.alliance.members ~= nil then
        
        local allianceMemberTab = sData.data.alliance.alliance.members
        for k, v in pairs(allianceMemberTab) do
            allianceMemberVoApi:addMember(v)
        end
        
    end
    --初始化军团申请列表
    if sData.data.alliance ~= nil and sData.data.alliance.alliance ~= nil and sData.data.alliance.alliance.requests ~= nil then
        local allianceApplicantTab = sData.data.alliance.alliance.requests
        for k, v in pairs(allianceApplicantTab) do
            allianceApplicantVoApi:addApplicant(v)
        end
        
    end
    --军团为读取的军团事件个数
    if sData.data.alliance ~= nil and sData.data.alliance.enum then
        allianceVoApi:setUnReadEventNum(sData.data.alliance.enum)
    end
    --军团副本
    if sData.data.achallenge ~= nil then
        allianceFubenVoApi:formatData(sData.data.achallenge)
    end
    --军团副本boss
    if (sData.cmd == "achallenge.getboss" or sData.cmd == "achallenge.battleboss") and sData.data ~= nil then
        allianceFubenVoApi:formatBossData(sData.data)
    end
    
    --配件挑战关卡
    if sData.data.ecNum ~= nil then
        local ecNum = tonumber(sData.data.ecNum) or 0
        accessoryVoApi:setECNum(ecNum)
    end
    
    ---更新活动
    if sData.data.active ~= nil then
        local activeData = sData.data.active
        activityVoApi:formatData(activeData)
    end
    
    if sData.data.newnotice ~= nil or sData.data.hasnotice ~= nil then
        local newNotice = nil
        local hasNotice = nil
        if sData.data.newnotice ~= nil then
            newNotice = tonumber(sData.data.newnotice)
            noteVoApi:setNewNum(newNotice, hasNotice)
        end
        if sData.data.hasnotice ~= nil then
            hasNotice = tonumber(sData.data.hasnotice)
            noteVoApi:setNewNum(newNotice, hasNotice)
        end
    end
    if sData.data.gu then--添加GM uid
        GM_UidCfg = {}
        for k, v in pairs(sData.data.gu) do
            GM_UidCfg[tonumber(v)] = 1
        end
        -- GM_UidCfg = sData.data.gu
    end
    --GM_UidCfg[1001042] = 1
    if sData.data.useractive ~= nil then
        activityVoApi:formatDetailData(sData.data.useractive)
    end
    if sData.data.accessory ~= nil then
        if sData.data.accessory.m_level then
            accessoryVoApi:setSuccinct_level(sData.data.accessory.m_level)
        end
        if sData.data.accessory.succ_at then
            accessoryVoApi:setSucc_at(sData.data.accessory.succ_at)
        end
        
    end
    
    if sData and sData.data and sData.data.unLockChatFrame then
        playerVoApi:setUnLockChatFrame(sData.data.unLockChatFrame)
    end
    
    if sData and sData.data and sData.data.unLockHead then
        playerVoApi:setUnLockHead(sData.data.unLockHead)
    end
    
    if sData and sData.data and sData.data.unLockTitle then
        playerVoApi:setUnLockTitle(sData.data.unLockTitle)
    end
    
    if sData and sData.data and sData.data.unLockEmoji then
        playerVoApi:setUnLockChatEmoji(sData.data.unLockEmoji)
    end
    
    if sData ~= nil and sData.cmd == "user.login" then
        
        if sData.data.personrebles then
            if sData.data.personrebles[1] and sData.data.personrebles[3] then
                rebelVoApi:setCurEnergy(sData.data.personrebles[1], sData.data.personrebles[3])
            end
            if sData.data.personrebles[2] then
                rebelVoApi:setNowCDTimer(sData.data.personrebles[2])
            end
        end
        if sData.ts then
            self.loginTime = sData.ts
        end
        if sData.data and sData.data.exerwar then --跨服联合演习时间
            exerWarVoApi:setWarTime(sData.data.exerwar)
        end
        if sData.data and sData.data.acrossinit then
            self.serverWarTeamSwitch = 1
            if sData.data.acrossinit.st then
                serverWarTeamVoApi.startTime = sData.data.acrossinit.st
            end
            if sData.data.acrossinit.et then
                serverWarTeamVoApi.endTime = sData.data.acrossinit.et
            end
        end
        if sData.data ~= nil and sData.data.userinfo ~= nil and tonumber(sData.data.userinfo.alliance) == 0 then
            local function getAllianceCallback()
                G_getActiveList()
            end
            G_getAlliance(getAllianceCallback)
        elseif sData.data ~= nil and sData.data.userinfo ~= nil then
            G_getActiveList()
        end
        if sData.data and sData.data.crossinit then
            G_getServerCfgFromHttp(true)
            serverWarPersonalVoApi:getWarInfo()
        end
        --群雄争霸的开始结束时间
        if sData.data and sData.data.areawarinit then
            self.serverWarLocalSwitch = 1
            serverWarLocalVoApi:setTimeData(sData.data.areawarinit)
            serverWarLocalVoApi:getInitData()
        end
        --群雄争霸剩余军饷
        if sData.data and sData.data.areawar and sData.data.areawar.gems then
            playerVoApi:setServerWarLocalUsegems(tonumber(sData.data.areawar.gems))
        end
        -- 狂热分子计算赛季与时间
        if sData.data and sData.data.believer then
            local timeTb = sData.data.believer
            -- 初始化赛季时间与偏移
            believerVoApi:initSeasonTimeData(timeTb)
            -- 计算赛季
            believerVoApi:computeSeason()
        end
        
        -- 异星矿场调用邮件发奖励
        if base.amap == 1 and(sData.data.alienreward == nil or sData.data.alienreward ~= 1)then
            alienMinesVoApi:checkIsActive3()
        end
        if sData.data and sData.data.worldwarinit then
            self.worldWarSwitch = 1
            if sData.data.worldwarinit.st and tonumber(sData.data.worldwarinit.st) then
                worldWarVoApi.startTime = tonumber(sData.data.worldwarinit.st)
            end
            
            if sData.data.worldwarinit.et and tonumber(sData.data.worldwarinit.et) then
                worldWarVoApi.endTime = tonumber(sData.data.worldwarinit.et)
            end
        end
        if(pushController:checkPushServiceVersion() == 1 and pushController:checkModule("gameSettings_pushWhole"))then
            local timeZero = G_getWeeTs(base.serverTime)
            local time = base.serverTime
            for i = 1, 8 do
                local time1 = timeZero + 3600 * 12 + 86400 * (i - 1)
                local time2 = time1 - time
                G_cancelPush("s"..i..G_timeTag, G_timeTag)
                if time2 > 0 then
                    G_pushMessage(getlocal("push_tip_1"), time2, "s"..i..G_timeTag, G_timeTag)
                end
                local time3 = timeZero + 3600 * 18 + 86400 * (i - 1)
                local time4 = time3 - time
                G_cancelPush("s"..i..G_timeTag2, G_timeTag2)
                if time4 > 0 then
                    G_pushMessage(getlocal("push_tip_2"), time4, "s"..i..G_timeTag2, G_timeTag2)
                end
            end
        end
        if sData.data and sData.data.alien then
            alienTechVoApi:setTechData(sData.data.alien)
            alienTechVoApi:setResFlag(0)
        end
    end
    --世界争霸冠军的数据 {1,1000034,1110000,"yoyo",69} 服务器，id，战力，名字，等级
    if sData.data.worldfirst ~= nil then
        local firstData = sData.data.worldfirst
        if firstData then
            local serverID = firstData[1] or 0
            local id = firstData[2] or 0
            local power = firstData[3] or 0
            local name = firstData[4] or ""
            local level = firstData[5] or 0
            self.worldWarChampion = {serverID = serverID, id = id, power = power, name = name, level = level}
        end
    end
    
    --军团战用户信息初始化数据
    if sData.data.useralliancewar ~= nil then
        if self.allianceWar2Switch == 1 then
            allianceWar2VoApi:initBattlefieldUser(sData.data)
        else
            allianceWarVoApi:initBattlefieldUser(sData.data.useralliancewar)
        end
    end
    
    --军团战战场初始化数据
    if sData.data.alliancewar ~= nil then
        if self.allianceWar2Switch == 1 then
            allianceWar2VoApi:initBattlefield(sData.data.alliancewar)
        else
            allianceWarVoApi:initBattlefield(sData.data.alliancewar)
        end
    end
    
    --初始化军事演习数据
    if sData.data.userarena ~= nil then
        arenaVoApi:initData(sData.data.userarena)
        if sData.data.weets then
            arenaVoApi:setWeets(sData.data.weets)
        end
    end
    
    --聊天是否被禁言,禁言结束时间
    if sData.cmd == "user.login" or sData.cmd == "user.sync" then
        -- chatVoApi:setChatLimitEndTime(sData.data)
        if sData.data then
            G_forbidType = sData.data.ntype or 0
            G_isNotice = sData.data.nnotice or 0
            G_forbidEndTime = sData.data.nst or 0
        end
    end
    --初始化英雄
    if sData.data.hero ~= nil then
        heroVoApi:init(sData.data.hero)
    end
    
    --初始化好友
    if sData.data.friends ~= nil then
        if sData.data.friends.info then
            friendMailVoApi:clear()
            friendMailVoApi:initData(sData.data.friends.info)
        end
        friendInfoVoApi:initData(sData.data.friends)
    end
    
    --初始化远征
    if sData.data ~= nil and sData.data.expedition ~= nil then
        expeditionVoApi:initVo(sData.data.expedition)
    end
    
    --初始化远征商店
    if sData.data ~= nil and sData.data.expeditionshop ~= nil then
        expeditionVoApi:initShop(sData.data.expeditionshop, sData.data.rt)
        if self.ea == 1 then
            expeditionVoApi:initRfcAdnRft(sData.data.rfc, sData.data.rft)
            expeditionVoApi:setBuy(sData.data.buy)
        end
    end
    
    --版号值：1：锁死UID 0：普通玩家  版号特殊处理
    if sData.data ~= nil and sData.data.isBH ~= nil then
        self.isCheckVersion = sData.data.isBH
    end
    
    --韩国交叉广告：1：开
    if sData.config ~= nil and sData.config and sData.config.kp ~= nil then
        self.isRandomGift = sData.config.kp
    end
    
    --等级满级 或 是声望满级 兑换水晶的开关
    if sData.config ~= nil and sData.config and sData.config.exg ~= nil then
        self.isConvertGems = sData.config.exg
    end
    --验证码开关
    if sData.config ~= nil and sData.config and sData.config.checkcode ~= nil then
        self.isCheckCode = sData.config.checkcode
    end
    --客服系统开关
    if sData.config and sData.config.kefu then
        self.ifGmOpen = tonumber(sData.config.kefu)
    end
    --奖励中心开关
    if sData.config ~= nil and sData.config and sData.config.rewardcenter ~= nil then
        self.rewardcenter = sData.config.rewardcenter
    end
    --聊天即时翻译开关
    if sData.config ~= nil and sData.config and sData.config.ct ~= nil then
        self.ifChatTransOpen = tonumber(sData.config.ct)
        --聊天翻译功能除了依托后台开关之外还要判断底层是否支持异步http协议
        if(self.ifChatTransOpen == 1 and (HttpRequestHelper:shared().sendAsynHttpRequestPost == nil or HttpRequestHelper:shared().sendAsynHttpRequestGet == nil))then
            self.ifChatTransOpen = 0
        end
    end
    if sData.config and sData.config.abf then
        self.ifAndroidBackFunctionOpen = tonumber(sData.config.abf) or 0
    end
    -- 奖励中心数据
    if sData.data.rewardcenter ~= nil and sData.data.rewardcenter then
        if rewardCenterVoApi then
            rewardCenterVoApi:formatData(sData.data.rewardcenter)
        end
    end
    
    --初始化军事演习商店(新)
    if sData.data ~= nil and sData.data.arenashop ~= nil then
        arenaVoApi:initShop(sData.data.arenashop, sData.data.rt)
        arenaVoApi:initRfcAdnRft(sData.data.rfc, sData.data.rft)
        arenaVoApi:setBuy(sData.data.buy)
    end
    --平台战的开始结束时间
    if sData.data and sData.data.platwarinit then
        self.platWarSwitch = 1
        if sData.data.platwarinit.st and tonumber(sData.data.platwarinit.st) then
            platWarVoApi.startTime = tonumber(sData.data.platwarinit.st)
        end
        if sData.data.platwarinit.et and tonumber(sData.data.platwarinit.et) then
            platWarVoApi.endTime = tonumber(sData.data.platwarinit.et)
        end
    end
    --平台战全平台公告开关
    if sData.config ~= nil and sData.config.ptnoc ~= nil then
        self.pwNoticeSwitch = tonumber(sData.config.ptnoc)
    end
    --聊天战报优化开关
    if sData.config ~= nil and sData.config.cm ~= nil then
        self.chatReportSwitch = tonumber(sData.config.cm)
    end
    if sData.data and sData.data.pid then
        self.serverPlatID = tostring(sData.data.pid)
    end
    if self.memoryServerPlatId and self.memoryServerPlatId ~= "" then --怀旧服配置中记录了玩家登录的平台id，则直接用此变量即可
        self.serverPlatID  = tostring(self.memoryServerPlatId)
    end
    if sData.cmd == "user.login" and (self.serverPlatID == "rayjoy_android" or self.serverPlatID == "gNet_jp") then
        --统计国内安卓和日本不支持跨服军团战的用户，如果SocketHandler2为空的话说明不支持平台跨服战
        if(SocketHandler2 == nil)then
            statisticsHelper:noSocket2()
        end
    end
    --天梯榜建筑开关
    if sData.config ~= nil and sData.config.ladder ~= nil then
        self.ladder = tonumber(sData.config.ladder)
    end
    -- 初始化天梯榜冠军数据
    if sData.data.ladder ~= nil and sData.data.ladder then
        if ladderVoApi then
            ladderVoApi:formatData(sData.data.ladder)
        end
    end
    
    --繁荣度开关
    if sData.config ~= nil and sData.config.boom ~= nil then
        self.isGlory = sData.config.boom
        -- print("self.isGlory======",self.isGlory)
        if sData.data.boom then
            gloryVoApi:addPlayerGlory(sData.data.boom)
        end
    end
    --冬季皮肤
    
    if sData.config and sData.config.iswk then
        self.isWinter = sData.config.iswk == 1 and true or false
    end
    --世界等级开关
    if sData.config ~= nil and sData.config.wl ~= nil then
        self.wl = sData.config.wl
        -- print("self.wl======",self.wl)
    end
    --金矿系统开关
    if sData.config ~= nil and sData.config.goldmine ~= nil then
        self.goldmine = sData.config.goldmine
        -- print("self.goldmine======",self.goldmine)
    end
    --保护矿系统开关
    if sData.config ~= nil and sData.config.privatemine ~= nil then
        self.privatemine = sData.config.privatemine
        -- print("self.privatemine======",self.privatemine)
    end
    --新签到
    if sData.config ~= nil and sData.config.newSign ~= nil then
        self.newSign = sData.config.newSign
        -- print("self.newSign======",self.newSign)
    end
    --矿产升级开关
    if sData.config ~= nil and sData.config.minellvl ~= nil then
        self.minellvl = sData.config.minellvl
        -- print("self.minellvl======",self.minellvl)
    end
    --世界等级同步
    if sData.data.wlvl then
        -- print("登录返回世界等级为：",sData.data.wlvl)
        playerVoApi:setWorldLv(sData.data.wlvl)
    end
    if sData.data.wexp then
        -- print("sData.data.wexp========",sData.data.wexp)
        playerVoApi:setCurWorldExp(tonumber(sData.data.wexp))
    end
    --军团boss副本开关
    if sData.config ~= nil and sData.config.fbboss ~= nil then
        self.fbboss = sData.config.fbboss
    end
    --军徽系统开关
    if sData.config and sData.config.sequip then
        self.emblemSwitch = tonumber(sData.config.sequip)
    end
    --军徽部队开关
    if sData.config and sData.config.smaster then
        self.emblemTroopSwitch = tonumber(sData.config.smaster)
    end
    --军团锦标赛系统开关
    if sData.config and sData.config.lcs then
        self.championshipWarSwitch = tonumber(sData.config.lcs)
    end
    --技能书熔炼开关
    if sData.config and sData.config.hs then
        self.hs = tonumber(sData.config.hs)
    end
    -- 装甲矩阵 （差量增加）
    if sData and sData.data and sData.data.amreward then
        for k, v in pairs(sData.data.amreward) do
            armorMatrixVoApi:addArmorInfoById(k, v)
        end
    end
    
    --反扫矿开关
    if sData.config and sData.config.fsaok then
        self.fsaok = sData.config.fsaok
    end
    if sData.config and sData.config.wpay then
        self.webpageRecharge = tonumber(sData.config.wpay)
        --飞流的巨兽崛起包，写死到一定等级才开放第三方支付
        -- if(G_curPlatName()=="51")then
        --     if(playerVoApi and playerVoApi.getPlayerLevel and playerVoApi:getPlayerLevel() and playerVoApi:getPlayerLevel()>10)then
        --         self.webpageRecharge=tonumber(sData.config.wpay)
        --     else
        --         self.webpageRecharge=0
        --     end
        -- end
    end
    -- 加速道具投放使用开关
    if sData.config and sData.config.sup then
        self.speedUpPropSwitch = tonumber(sData.config.sup)
    end
    --和谐模式开关
    if sData.config and sData.config.hx then
        -- if(G_curPlatName()=="qihoo" or G_curPlatName()=="7" or G_curPlatName()=="0")then
        self.hexieMode = tonumber(sData.config.hx)
        -- end
    end
    if sData.config and sData.config.plane then
        self.plane = sData.config.plane
    end
    if sData.config and sData.config.acity then --军团城市开关
        self.allianceCitySwitch = sData.config.acity
    end
    if sData.config and sData.config.agift then --军团城市开关
        self.allianceGiftSwitch = sData.config.agift
    end
    if sData.config and sData.config.statue then --战争塑像系统开关
        self.warStatueSwitch = sData.config.statue
    end
    if sData.config and sData.config.rpl then --相差15级不给军功的开关
        self.rankPointLimit = tonumber(sData.config.rpl)
    end
    if sData.config and sData.config.bRace then --狂热分子功能开关
        self.bRace = sData.config.bRace
    end
    if sData.config and sData.config.bab then --狂热分子自动匹配5次开关
        self.bab = sData.config.bab
    end
    if sData.config and sData.config.avt then --成就系统开关
        self.avt = sData.config.avt
    end
    if sData.config and sData.config.jw then --军务管家功能开关
        self.stewardSwitch = sData.config.jw
    end
    if sData.config and sData.config.mo then --军令开关
        self.militaryOrders = sData.config.mo
    end
    if sData.config and sData.config.prefit then --飞机改装开关
        self.planeRefit = sData.config.prefit
    end
    if sData.config and sData.config.zl then --战略中心开关
        self.strategyCenter = sData.config.zl
    end
    if sData.config and sData.config.hpjs then --红色配件晋升开关
        self.redAccessoryPromote = sData.config.hpjs
    end
    -- 战斗结算2017版
    if sData.config ~= nil and sData.config.power7 ~= nil then
        self.powerGuide2017 = sData.config.power7
    end
    if sData.config and sData.config.cw then
        self.ltzdz = sData.config.cw
    end
    if sData.data and sData.data.cw then
        self.ltzdzTb = sData.data.cw
    end
    if sData.config and sData.config.smmap then
        self.smmap = sData.config.smmap
    end
    if sData.config and sData.config.rn then --改名卡功能开关
        self.reNameSwitch = sData.config.rn
    end
    if sData.config and sData.config.armorbr then --紫色装甲矩阵突破开关
        self.armorbr = sData.config.armorbr
    end
    if sData.config and sData.config.ait then --AI部队功能开关
        self.AITroopsSwitch = sData.config.ait
    end
    if sData.config and sData.config.rb then --拆除建筑优化功能开关
        self.rbSwitch = sData.config.rb
    end
    if sData.config and sData.config.tskin then --坦克皮肤功能开关
        self.tskinSwitch = sData.config.tskin
    end
    if sData.config and sData.config.adj then --将领副官功能开关
        self.adjSwitch = sData.config.adj
    end
    if sData.config and sData.config.bj then --补给商店的开关
        self.bjSwitch = sData.config.bj
    end
    if sData.config and sData.config.mgr then --迁移码功能开关
        self.migration = sData.config.mgr
    end
    if sData.config and sData.config.moji then --聊天表情开关
        self.moji = sData.config.moji
    end
    if sData.config and sData.config.pr then --个人叛军开关
        self.prSwitch = sData.config.pr
    end
    if sData.config and sData.config.vfy then --实名认证开关
        self.vfy = sData.config.vfy
    end
    if sData.config and sData.config.ars then --飞艇开关
        self.airShipSwitch = sData.config.ars
    end
    if sData.config and sData.config.vkb then --世界地图搜索地图虚拟键盘开关
        self.virtualKeyboard = sData.config.vkb
    end
    --和谐版关闭部分功能
    if(G_isHexie())then
        self.alien = 0
        self.ifSuperWeaponOpen = 0
        self.heroSwitch = 0
        self.amap = 0
        self.localWarSwitch = 0
        self.dimensionalWarSwitch = 0
        self.emblemSwitch = 0
        self.accessoryTech = 0
        self.armor = 0
    end
    --初始化军徽数据 user.sync接口目前只返回军徽部队出征状态
    if self.emblemSwitch == 1 and sData.cmd ~= "user.sync" then
        emblemVoApi:initData(sData.data.sequip)
    end
    
    -- 初始化世界地图数据
    if sData.data and sData.data.userinfo and worldBaseVoApi then
        worldBaseVoApi:initdata(sData.data.userinfo)
    end
    
    -- 刷新将领数据
    if sData.data and sData.data.userinfo and acMingjiangpeiyangSmallDialog then
        acMingjiangpeiyangSmallDialog:initPersonalReward(sData.data.userinfo)
    end
    
    --刷新飞机数据 user.sync接口目前只返回飞机出征状态
    if self.plane == 1 and sData.data.plane and sData.cmd ~= "user.sync" then
        planeVoApi:initData(sData.data)
    end
    
    -- 刷新好友礼物数据
    if sData.data and sData.data.userinfo and friendInfoVoApi then
        friendInfoVoApi:initFriendGiftData(data)
    end
    
    --德国第三方支付数据
    if sData.data.thirdPayLimit then
        if(vipVoApi)then
            vipVoApi.thirdPayCfg = sData.data.thirdPayLimit
        end
    end
    
    -- 初始化皮肤数据
    if sData.data and sData.data.userinfo and buildDecorateVoApi then
        buildDecorateVoApi:initSkin(sData.data.userinfo)
    end
    
    -- 初始化礼包数据
    if sData.data and sData.data.userinfo and giftPushVoApi then
        giftPushVoApi:initReward(sData.data.userinfo)
    end
    
    --加速攻击叛军
    if sData.cmd == "cron.attack" and sData.data.rebelInfo then
        local uid = playerVoApi:getUid()
        local rebelData = sData.data.rebelInfo
        if rebelData then
            local reflectId = rebelData.id
            local rebelLeftLife = rebelData.rebelLeftLife
            local rebelInfo = {id = reflectId, rebelLeftLife = rebelLeftLife}
            local params = {uid = uid, rebelInfo = rebelInfo}
            chatVoApi:sendUpdateMessage(40, params, 1)
        end
    end
    
    if sData.cmd == "user.sync" then
        if sData.data and sData.data.userinfo then
            local userFlags = sData.data.userinfo.flags
            if userFlags and userFlags.goldMine then --记录每日累计采集的金币数
                local gemsData = {gems = userFlags.goldMine[1], ts = userFlags.goldMine[2]}
                goldMineVoApi:setDailyGemsData(gemsData)
            end
        end
    end
    
    -- 初始化天天基金的基金初始数据
    if sData.data and sData.data.userinfo and dailyTtjjVoApi then
        dailyTtjjVoApi:initFund(sData.data.userinfo)
    end
    
    if sData.cmd == "user.login" and sData.data and sData.data.clancrossinfo then
        if sData.data.clancrossinfo.bnum then
            self.clancrossinfoBnum = sData.data.clancrossinfo.bnum
        end
        if sData.data.clancrossinfo.rpoint then
            self.clancrossinfoRpoint = sData.data.clancrossinfo.rpoint
        end
    end
    
    if sData.data then
        --同步AI部队的出征状态
        if sData.data.aitroops and type(sData.data.aitroops) == "table" and sData.data.aitroops.stats then
            AITroopsFleetVoApi:syncStats(sData.data.aitroops.stats)
        end
        --同步飞机的出征状态
        if sData.data.plane and type(sData.data.plane) == "table" and sData.data.plane.stats then
            planeVoApi:syncStats(sData.data.plane.stats)
        end
        --同步军徽的出征状态
        if sData.data.sequip and type(sData.data.sequip) == "table" and sData.data.sequip.stats then
            emblemVoApi:syncStats(sData.data.sequip.stats)
        end
         --同步飞艇的出征状态
        if sData.data.airship and type(sData.data.airship) == "table" and sData.data.airship.stats then
            airShipVoApi:syncStatus(sData.data.airship.stats)
        end
    end

    --战略中心数据
    if sData.cmd == "user.login" and sData.data and sData.data.strategy and strategyCenterVoApi then
        strategyCenterVoApi:initData(sData.data)
    end
end
--判断服务器返回的数据是否有效
function base:checkServerData(data, needCheck)
    print("服务器返回的数据", data)
    local stidx = string.find(data, "rayjoy_thief_start")
    if stidx ~= nil then
        data = string.sub(data, stidx + 18)
        local edidx = string.find(data, "rayjoy_thief_end")
        data = string.sub(data, 1, edidx - 1)
    end
    
    if needCheck == nil then
        needCheck = true
    end
    --接收到了服务器返回的应答
    self:cancleWait()
    self:cancleNetWait()
    local beforeE = G_getCurDeviceMillTime()
    local sData = G_Json.decode(tostring(data))
    -- sData.ret=-133
    if sData ~= nil then
        --更新服务器时间
        if sData.ts ~= nil then
            self.datiTime = sData.ts
            if math.abs(base.serverTime - sData.ts) >= 2 or base.serverTime > sData.ts then
                self.timeCheckDate = G_getCurDeviceMillTime()
                self.localServerTime = sData.ts
                base.serverTime = sData.ts
            end
            self.meirilingjiangTime = sData.ts
        end
        if sData.cmd == "user.sync" and base.pauseSync == true then
            do
                return false, sData
            end
        end
    end
    
    -------------旧格式开关开始---------------
    --军团开关设置if sData.
    if sData.config ~= nil and sData.config.alliance ~= nil and sData.config.alliance.enable ~= nil then
        self.isAllianceSwitch = sData.config.alliance.enable
        if tonumber(self.isAllianceSwitch) == 0 and self.isAllianceOpen == true then
            if SizeOfTable(G_AllianceDialogTb) > 0 then
                for k, v in pairs(G_AllianceDialogTb) do
                    if v ~= nil and v.close ~= nil then
                        v:close()
                    end
                end
            end
            self.isAllianceOpen = false
            allianceVoApi:clear()--清空自己军团信息和列表信息
            allianceMemberVoApi:clear()--清空成员列表
            allianceApplicantVoApi:clear()--清空
            playerVoApi:clearAllianceData()
            helpDefendVoApi:clear()--协防
        end
    end
    if sData.config ~= nil and sData.config.alliance ~= nil and sData.config.alliance.skills ~= nil then
        self.isAllianceSkillSwitch = sData.config.alliance.skills
    end
    if sData.config ~= nil and sData.config.alliance ~= nil and sData.config.alliance.achallenge ~= nil then
        self.isAllianceFubenSwitch = sData.config.alliance.achallenge
    end
    --军团战开关
    if sData.config ~= nil and sData.config.alliance ~= nil and sData.config.alliance.war ~= nil then
        self.isAllianceWarSwitch = sData.config.alliance.war
    end
    
    --签到开关
    if sData.config ~= nil and sData.config.sign ~= nil and sData.config.sign.enable ~= nil then
        self.isSignSwitch = sData.config.sign.enable
    end
    
    --激活码开关
    if sData.config ~= nil and sData.config.code ~= nil and sData.config.code.enable ~= nil then
        self.isCodeSwitch = sData.config.code.enable
    end
    
    --好友开关
    if sData.config ~= nil and sData.config.friend ~= nil and sData.config.friend.enable ~= nil then
        self.ifFriendOpen = sData.config.friend.enable
    end
    
    --配件开关
    if sData.config ~= nil and sData.config.ec ~= nil and sData.config.ec.enable ~= nil then
        self.ifAccessoryOpen = sData.config.ec.enable
    end
    
    --战力暴增开关
    if sData.config ~= nil and sData.config.nd ~= nil and sData.config.nd.enable ~= nil then
        self.isNd = sData.config.nd.enable
    end
    
    --军事演习开关
    if sData.config ~= nil and sData.config.military ~= nil and sData.config.military.enable ~= nil then
        self.ifMilitaryOpen = sData.config.military.enable
    end
    
    --军团商店开关
    if sData.config ~= nil and sData.config.alliance ~= nil and sData.config.alliance.shop ~= nil then
        self.ifAllianceShopOpen = sData.config.alliance.shop
    end
    
    --在线礼包开关
    if sData.config ~= nil and sData.config.ol ~= nil and sData.config.ol.enable ~= nil then
        self.ifOnlinePackageOpen = sData.config.ol.enable
    end
    --地形系统开关
    if sData.config ~= nil and sData.config.lf ~= nil and sData.config.lf.enable ~= nil then
        self.landFormOpen = sData.config.lf.enable
    end
    --支付开关
    if sData.config ~= nil and sData.config.pay ~= nil and sData.config.pay.enable ~= nil then
        self.isPayOpen = sData.config.pay.enable
        --陆战雄狮已经下架了，充值关闭
        if(G_curPlatName() == "androidflbaidu")then
            self.isPayOpen = 0
        end
    end
    --支付方式开关
    if sData.config ~= nil and sData.config.pay1 ~= nil then
        self.isPay1Open = sData.config.pay1
    end
    --日本这个包没有第三方支付
    if(G_curPlatName() == "20" and G_Version > 2)then
        self.isPay1Open = 0
    elseif(G_curPlatName() == "5" and G_Version <= 11)then
        self.isPay1Open = 1
    end
    --英雄开关
    if sData.config ~= nil and sData.config.hero ~= nil then
        self.heroSwitch = sData.config.hero
    end
    -- 基地外观
    if sData.config ~= nil and sData.config.jdskin ~= nil then
        self.isSkin = sData.config.jdskin
    end
    --远征开关
    if sData.config ~= nil and sData.config.expedition ~= nil then
        self.expeditionSwitch = sData.config.expedition
    end
    
    -- 腾讯活动开关
    if sData.config ~= nil and sData.config.qq ~= nil then
        self.qq = sData.config.qq
    end
    -- 每日领取奖励
    if sData.config ~= nil and sData.config.drew1 ~= nil then
        self.drew1 = sData.config.drew1
    end
    
    --每日答题开关
    if sData.config ~= nil and sData.config.dailychoice ~= nil then
        self.dailychoice = sData.config.dailychoice
    end
    if sData.config ~= nil and sData.config.drew2 ~= nil then
        self.drew2 = sData.config.drew2
    end
    --天天基金开关
    if sData.config ~= nil and sData.config.ttjj ~= nil then
        self.ttjj = sData.config.ttjj
    end
    -- 限时挑战开关
    if sData.config ~= nil and sData.config.xstz ~= nil then
        self.xstz = sData.config.xstz
        self.xstzh = sData.config.xstz
    end
    -- 月度回馈开关
    if sData.config ~= nil and sData.config.ydhk ~= nil then
        self.ydhk = sData.config.ydhk
    end
    
    if sData.config ~= nil and sData.config.xsjx ~= nil then
        self.xsjx = sData.config.xsjx
    end
    if sData.logints ~= nil then
        self.logints = sData.logints
    end
    if sData.access_token ~= nil then
        self.access_token = sData.access_token
    end
    if sData.uid ~= nil then
        self.curUid = tonumber(sData.uid)
    end
    
    --评价开关
    if sData.config ~= nil and sData.config.evaluate ~= nil and sData.config.evaluate.enable ~= nil then
        self.isEvaluateOnOff = sData.config.evaluate.enable
    end
    
    --vip新特权开关
    if sData.config ~= nil then
        -- vip 增加战斗经验
        if sData.config.vax then
            if type(sData.config.vax) == "table" and sData.config.vax.enable ~= nil then
                self.vipPrivilegeSwitch.vax = sData.config.vax.enable
            else
                self.vipPrivilegeSwitch.vax = sData.config.vax
            end
        end
        --配件合成概率提高
        if sData.config.vea then
            if type(sData.config.vea) == "table" and sData.config.vea.enable ~= nil then
                self.vipPrivilegeSwitch.vea = sData.config.vea.enable
            else
                self.vipPrivilegeSwitch.vea = sData.config.vea
            end
        end
        --创建军团不花金币
        if sData.config.vca then
            if type(sData.config.vca) == "table" and sData.config.vca.enable ~= nil then
                self.vipPrivilegeSwitch.vca = sData.config.vca.enable
            else
                self.vipPrivilegeSwitch.vca = sData.config.vca
            end
        end
        --装置车间增加可制造物品
        if sData.config.vap then
            if type(sData.config.vap) == "table" and sData.config.vap.enable ~= nil then
                self.vipPrivilegeSwitch.vap = sData.config.vap.enable
            else
                self.vipPrivilegeSwitch.vap = sData.config.vap
            end
        end
        -- 高级抽奖每日免费1次
        if sData.config.vfn then
            if type(sData.config.vfn) == "table" and sData.config.vfn.enable ~= nil then
                self.vipPrivilegeSwitch.vfn = sData.config.vfn.enable
            else
                self.vipPrivilegeSwitch.vfn = sData.config.vfn
            end
        end
        -- 仓库保护资源量*2
        if sData.config.vps then
            if type(sData.config.vps) == "table" and sData.config.vps.enable ~= nil then
                self.vipPrivilegeSwitch.vps = sData.config.vps.enable
            else
                self.vipPrivilegeSwitch.vps = sData.config.vps
            end
        end
        -- 每日捐献次数上限+2
        if sData.config.vdn then
            if type(sData.config.vdn) == "table" and sData.config.vdn.enable ~= nil then
                self.vipPrivilegeSwitch.vdn = sData.config.vdn.enable
            else
                self.vipPrivilegeSwitch.vdn = sData.config.vdn
            end
        end
        --精英副本扫荡
        if sData.config.vec then
            if type(sData.config.vec) == "table" and sData.config.vec.enable ~= nil then
                self.vipPrivilegeSwitch.vec = sData.config.vec.enable
            else
                self.vipPrivilegeSwitch.vec = sData.config.vec
            end
        end
        --每日签到奖励翻倍
        if sData.config.vsr then
            if(type(sData.config.vsr) == "table" and sData.config.vsr.enable)then
                self.vipPrivilegeSwitch.vsr = tonumber(sData.config.vsr.enable)
            else
                self.vipPrivilegeSwitch.vsr = tonumber(sData.config.vsr)
            end
        end
    end
    
    -- 主线任务开关
    if sData.config ~= nil and sData.config.mt ~= nil then
        if type(sData.config.mt) == "table" and sData.config.mt.enable ~= nil then
            self.mainTaskSwitch = sData.config.mt.enable
        else
            self.mainTaskSwitch = sData.config.mt
        end
    end
    --后台推送功能的开关
    if sData.config ~= nil and sData.config.push ~= nil then
        self.isBackendPushOpen = tonumber(sData.config.push)
    end
    --军需卡功能开关
    if sData.config ~= nil and sData.config.mc then
        self.monthlyCardOpen = tonumber(sData.config.mc)
        if(G_curPlatName() == "5" and G_Version >= 12)then
            self.monthlyCardOpen = 0
        elseif(G_curPlatName() == "58")then
            self.monthlyCardOpen = 0
        end
    end
    --军需卡的购买开关
    if sData.config ~= nil and sData.config.bmc then
        self.monthlyCardBuyOpen = tonumber(sData.config.bmc)
    end
    --平台币商店的开关
    if sData.config ~= nil and sData.config.ps then
        if (G_curPlatName() == "qihoo" and G_Version >= 10) or G_curPlatName() == "0" then
            self.isPlatShopOpen = tonumber(sData.config.ps)
        end
    end
    --配件商店的开关
    if sData.config and sData.config.ecshop then
        self.ecshop = tonumber(sData.config.ecshop)
    end
    if sData.config ~= nil and sData.config.heat then
        self.richMineOpen = tonumber(sData.config.heat)
    end
    --军功商店的开关
    if sData.config and sData.config.rpshop then
        self.rpShop = tonumber(sData.config.rpshop)
    end
    if sData.config and sData.config.rpshopopen then
        self.rpShopOpen = tonumber(sData.config.rpshopopen)
    end
    
    --世界boss
    if sData.config and sData.config.boss then
        self.boss = tonumber(sData.config.boss)
    end
    
    --异星科技的开关
    if sData.config and sData.config.alien then
        self.alien = tonumber(sData.config.alien)
    end
    -- vip新增特权礼包开关
    if sData.config and sData.config.vipshop then
        self.vipshop = tonumber(sData.config.vipshop)
    end
    
    --精炼系统的开关
    if sData.config and sData.config.succinct then
        self.succinct = tonumber(sData.config.succinct)
    end
    -- 建筑自动升级功能开关
    if sData.config and sData.config.autobuild then
        self.autoUpgrade = sData.config.autobuild
    end
    
    --异星矿场的开关
    if sData.config and sData.config.amap then
        self.amap = tonumber(sData.config.amap)
    end
    
    --建筑显示优化的开关
    if sData.config and sData.config.byh then
        self.byh = tonumber(sData.config.byh)
    end
    
    -- 开关一键捐献
    if sData.config ~= nil and sData.config.donateall ~= nil then
        self.isDonateall = sData.config.donateall
    end
    
    -- 开关军团旗帜
    if sData.config ~= nil and sData.config.af ~= nil then
        self.isAf = sData.config.af
    end
    
    if sData.config and sData.config.sethelp then
        self.isGarrsionOpen = tonumber(sData.config.sethelp)
    end
    
    --邮件屏蔽的开关
    if sData.config and sData.config.mbl then
        self.mailBlackList = tonumber(sData.config.mbl)
    end
    
    -- 将领授勋开关
    if sData.config and sData.config.herofeat then
        self.herofeat = tonumber(sData.config.herofeat)
    end
    
    -- 区域战开关
    if sData.config and sData.config.areawar then
        self.localWarSwitch = tonumber(sData.config.areawar)
    end
    if sData.config and sData.config.sw then
        self.ifSuperWeaponOpen = tonumber(sData.config.sw)
    end
    --临时建造队列开关
    if sData.config and sData.config.tempslots then
        self.ifTmpSlotOpen = tonumber(sData.config.tempslots)
    end
    -- 头像与称号开关
    if sData.config and sData.config.gxh then
        self.gxh = tonumber(sData.config.gxh)
    end
    
    if sData.config and sData.config.etank then
        self.etank = tonumber(sData.config.etank)
    end
    -- 将领装备开关
    if sData.config and sData.config.he then
        self.he = tonumber(sData.config.he)
    end
    
    -- 远征扫荡
    if sData.config and sData.config.ea then
        self.ea = tonumber(sData.config.ea)
    end
    
    -- 新军事演习（军事演习改版）
    if sData.config and sData.config.ma then
        self.ma = tonumber(sData.config.ma)
    end
    -- 配件绑定的开关
    if sData.config and sData.config.ab then
        self.accessoryBind = tonumber(sData.config.ab)
    end
    -- 配件科技的开关
    if sData.config and sData.config.at then
        self.accessoryTech = tonumber(sData.config.at)
    end
    --战斗画面内坦克的BUF新的摆放方式(1 新 0 旧)
    if sData.config and sData.config.c2 then
        self.isNewBufPos = tonumber(sData.config.c2)
    end
    
    -- vip免费升级加速
    if sData.config and sData.config.fs then
        self.fs = tonumber(sData.config.fs)
    end
    -- 每日活动优化开关
    if sData.config and sData.config.c1 then
        self.dailyAcYouhuaSwitch = tonumber(sData.config.c1)
    end
    
    -- 军团协助开关
    if sData.config and sData.config.alliancehelp then
        self.allianceHelpSwitch = tonumber(sData.config.alliancehelp)
    end
    -- 新军团战开关
    if sData.config and sData.config.alliancewarnew then
        self.allianceWar2Switch = tonumber(sData.config.alliancewarnew)
        if self.allianceWar2Switch == 1 then
            self.isAllianceWarSwitch = 0
        end
    end
    -- 军团活跃优化
    if sData.config and sData.config.c3 then
        self.allianceAcYouhua = tonumber(sData.config.c3)
    end
    -- 异元战场开关
    if sData.config and sData.config.userwar then
        self.dimensionalWarSwitch = tonumber(sData.config.userwar)
    end
    
    -- 经验书一键使用
    if sData.config and sData.config.bs then
        self.bs = tonumber(sData.config.bs)
    end
    
    -- 聊天玩家等级限制
    if sData.config and sData.config.chatlevel then
        self.chatLvLimit = tonumber(sData.config.chatlevel)
    end
    
    -- 活动改版的开关
    if sData.config and sData.config.mustmodel then
        self.mustmodel = tonumber(sData.config.mustmodel)
    end
    --NB技能系统的开关
    if sData.config and sData.config.nbs then
        self.nbSkillOpen = tonumber(sData.config.nbs)
    end
    --将领开放等级
    if(sData.config and sData.config.hl)then
        self.heroOpenLv = tonumber(sData.config.hl)
    end
    --将领装备开放等级
    if(sData.config and sData.config.hel)then
        self.heroEquipOpenLv = tonumber(sData.config.hel)
    end
    --超级武器开放等级
    if(sData.config and sData.config.wel)then
        self.superWeaponOpenLv = tonumber(sData.config.wel)
    end
    --异星科技开放等级
    if(sData.config and sData.config.al)then
        self.alienTechOpenLv = tonumber(sData.config.al)
        if(alienTechCfg)then
            alienTechCfg.openlevel = self.alienTechOpenLv
        end
    end
    --远征开放等级
    if(sData.config and sData.config.el)then
        self.expeditionOpenLv = tonumber(sData.config.el)
        if(expeditionCfg)then
            expeditionCfg.openLevel = self.expeditionOpenLv
        end
    end
    --远征开放等级
    if(sData.config and sData.config.nrce)then
        self.newRechargeSwitch = tonumber(sData.config.nrce)
    end
    --叛军系统开关
    if(sData.config and sData.config.acerebel)then
        self.isRebelOpen = tonumber(sData.config.acerebel)
    end
    -- 援建开关
    if sData.config ~= nil and sData.config.ubh ~= nil then
        self.ubh = sData.config.ubh
    end
    -- 周卡开关
    if sData.config ~= nil and sData.config.wc ~= nil then
        self.weekCard = sData.config.wc
    end
    -- 关卡扫荡开关
    if sData.config ~= nil and sData.config.cr ~= nil then
        self.raids = sData.config.cr
    end
    --不能侦察比自己高10级以上的矿点的开关
    if(sData.config and sData.config.sctlv)then
        self.sctlv = tonumber(sData.config.sctlv)
    end
    -- 消息滚动开关
    if sData.config ~= nil and sData.config.scroll ~= nil then
        self.scroll = sData.config.scroll
    end
    -- 将领二次授勋开关
    if sData.config and sData.config.hf2 then
        self.herofeat2 = tonumber(sData.config.hf2)
    end
    -- 新版每日任务
    if sData.config ~= nil and sData.config.ndtk ~= nil then
        self.newDailyTask = sData.config.ndtk
    end
    -- 5阶红色配件开关
    if sData.config ~= nil and sData.config.ra ~= nil then
        self.redAcc = sData.config.ra
    end
    -- 装甲矩阵开关
    if sData.config ~= nil and sData.config.armor ~= nil then
        self.armor = sData.config.armor
    end
    if sData.config and sData.config.pdev then
        self.checkRecharge = tonumber(sData.config.pdev)
        if(G_curPlatName() == "androidtencentyxb" or G_curPlatName() == "androidfltencent" or G_curPlatName() == "5" or G_curPlatName() == "61")then
            self.checkRecharge = 0
        end
    end
    -- 每日捷报开关
    if sData.config ~= nil and sData.config.dnews ~= nil then
        self.dnews = sData.config.dnews
    end
    if sData.config and sData.config.chts then --关闭聊天的开关
        self.shutChatSwitch = sData.config.chts
    end
    if sData.config and sData.config.uin then --新版UI的开关
        self.newUIOff = sData.config.uin
    end
    -------------旧格式开关结束---------------
    
    -------------新格式开关开始---------------
    --如有新格式，走新格式，重新赋值且默认为1,打开状态
    if sData.newconfig then
        self.isAllianceSwitch = 1--公会开关 1为开启 0为关闭
        self.isAllianceSkillSwitch = 1--公会技能开关 1为开启 0为关闭
        self.isSignSwitch = 1--签到开关
        self.isAllianceFubenSwitch = 1--公会副本开关 1为开启 0为关闭
        self.isCodeSwitch = 1--激活码开关
        self.ifFriendOpen = 1 --好友功能是否开放
        self.ifAccessoryOpen = 1 --配件功能是否开放
        self.isAllianceWarSwitch = 1--军团战开关
        self.isNd = 1--战力暴增开关
        self.ifAllianceShopOpen = 1--军团商店开关
        self.ifMilitaryOpen = 1--军事演习开关
        self.isPayOpen = 1--支付开关
        self.ifOnlinePackageOpen = 1 -- 在线礼包开关
        self.landFormOpen = 1--地形系统开关
        self.isEvaluateOnOff = 1--评价开关
        -- vip新特权
        self.vipPrivilegeSwitch = {
            -- vip 增加战斗经验
            vax = 1,
            --配件合成概率提高
            vea = 1,
            --创建军团不花金币
            vca = 1,
            --装置车间增加可制造物品
            vap = 1,
            -- 高级抽奖每日免费1次
            vfn = 1,
            -- 仓库保护资源量*2
            vps = 1,
            -- 每日捐献次数上限+2
            vdn = 1,
            --精英副本扫荡
            vec = 1,
            --每日签到奖励翻倍
            vsr = 0,
        }
        --主线任务开关
        self.mainTaskSwitch = 1
        
        --军团科技
        if sData.newconfig.allianceskills then
            self.isAllianceSkillSwitch = sData.newconfig.allianceskills
        end
        --军团开关
        if sData.newconfig.alliance then
            self.isAllianceSwitch = sData.newconfig.alliance
        end
        --军团关卡
        if sData.newconfig.allianceachallenge then
            self.isAllianceFubenSwitch = sData.newconfig.allianceachallenge
        end
        --军团战
        if sData.newconfig.alliancewar then
            self.isAllianceWarSwitch = sData.newconfig.alliancewar
        end
        --军团商店
        if sData.newconfig.allianceshop then
            self.ifAllianceShopOpen = sData.newconfig.allianceshop
        end
        --好友
        if sData.newconfig.friend then
            self.ifFriendOpen = sData.newconfig.friend
        end
        --签到
        if sData.newconfig.sign then
            self.isSignSwitch = sData.newconfig.sign
        end
        --激活码
        if sData.newconfig.code then
            self.isCodeSwitch = sData.newconfig.code
        end
        --精英关卡和配件
        if sData.newconfig.ec then
            self.ifAccessoryOpen = sData.newconfig.ec
        end
        --明日战力暴增，次日风暴
        if sData.newconfig.nd then
            self.isNd = sData.newconfig.nd
        end
        --成长计划
        if sData.newconfig.gw then
            -- sData.newconfig.gw
        end
        --在线礼包
        if sData.newconfig.ol then
            self.ifOnlinePackageOpen = sData.newconfig.ol
        end
        --北美视频功能
        if sData.newconfig.video then
            -- sData.newconfig.video
        end
        --军事演习
        if sData.newconfig.military then
            self.ifMilitaryOpen = sData.newconfig.military
        end
        -- 评论
        if sData.newconfig.evaluate then
            self.isEvaluateOnOff = sData.newconfig.evaluate
        end
        --充值开关
        if sData.newconfig.pay then
            self.isPayOpen = sData.newconfig.pay
        end
        -- landform 地形
        if sData.newconfig.lf then
            self.landFormOpen = sData.newconfig.lf
        end
        --军需卡功能开关
        if sData.newconfig.mc then
            self.monthlyCardOpen = tonumber(sData.newconfig.mc)
        end
        --军需卡的购买开关
        if sData.newconfig.bmc then
            self.monthlyCardBuyOpen = tonumber(sData.newconfig.bmc)
        end
        --vip新特权开关
        -- vip 增加战斗经验
        if sData.newconfig.vax then
            if type(sData.newconfig.vax) == "table" and sData.newconfig.vax.enable ~= nil then
                self.vipPrivilegeSwitch.vax = sData.newconfig.vax.enable
            else
                self.vipPrivilegeSwitch.vax = sData.newconfig.vax
            end
        end
        --配件合成概率提高
        if sData.newconfig.vea then
            if type(sData.newconfig.vea) == "table" and sData.newconfig.vea.enable ~= nil then
                self.vipPrivilegeSwitch.vea = sData.newconfig.vea.enable
            else
                self.vipPrivilegeSwitch.vea = sData.newconfig.vea
            end
        end
        --创建军团不花金币
        if sData.newconfig.vca then
            if type(sData.newconfig.vca) == "table" and sData.newconfig.vca.enable ~= nil then
                self.vipPrivilegeSwitch.vca = sData.newconfig.vca.enable
            else
                self.vipPrivilegeSwitch.vca = sData.newconfig.vca
            end
        end
        --装置车间增加可制造物品
        if sData.newconfig.vap then
            if type(sData.newconfig.vap) == "table" and sData.newconfig.vap.enable ~= nil then
                self.vipPrivilegeSwitch.vap = sData.newconfig.vap.enable
            else
                self.vipPrivilegeSwitch.vap = sData.newconfig.vap
            end
        end
        -- 高级抽奖每日免费1次
        if sData.newconfig.vfn then
            if type(sData.newconfig.vfn) == "table" and sData.newconfig.vfn.enable ~= nil then
                self.vipPrivilegeSwitch.vfn = sData.newconfig.vfn.enable
            else
                self.vipPrivilegeSwitch.vfn = sData.newconfig.vfn
            end
        end
        -- 仓库保护资源量*2
        if sData.newconfig.vps then
            if type(sData.newconfig.vps) == "table" and sData.newconfig.vps.enable ~= nil then
                self.vipPrivilegeSwitch.vps = sData.newconfig.vps.enable
            else
                self.vipPrivilegeSwitch.vps = sData.newconfig.vps
            end
        end
        -- 每日捐献次数上限+2
        if sData.newconfig.vdn then
            if type(sData.newconfig.vdn) == "table" and sData.newconfig.vdn.enable ~= nil then
                self.vipPrivilegeSwitch.vdn = sData.newconfig.vdn.enable
            else
                self.vipPrivilegeSwitch.vdn = sData.newconfig.vdn
            end
        end
        --精英副本扫荡
        if sData.newconfig.vec then
            if type(sData.config.vec) == "table" and sData.newconfig.vec.enable ~= nil then
                self.vipPrivilegeSwitch.vec = sData.newconfig.vec.enable
            else
                self.vipPrivilegeSwitch.vec = sData.newconfig.vec
            end
        end
        -- 主线任务开关
        if sData.newconfig.mt then
            if type(sData.newconfig.mt) == "table" and sData.newconfig.mt.enable ~= nil then
                self.mainTaskSwitch = sData.newconfig.mt.enable
            else
                self.mainTaskSwitch = sData.newconfig.mt
            end
        end
    end
    -------------新格式开关结束---------------
    
    --OBJDEF:decode(data)
    socketHelper:receivedResponse(sData.cmd, sData.rnum)
    if(mainUI)then
        mainUI.needRefreshPlayerInfo = true
    end
    if sData.cfgVer ~= nil then --服务器返回了配置文件的版本号
        local serverCfgVersion = CCUserDefault:sharedUserDefault():getIntegerForKey(G_local_svrCfgVersion)
        
        if serverCfgVersion == 0 then
            if platCfg.platServerCfgVersion ~= nil then
                if platCfg.platServerCfgVersion[G_curPlatName()] ~= nil then
                    serverCfgVersion = platCfg.platServerCfgVersion[G_curPlatName()]
                end
            end
        end
        
        if tonumber(sData.cfgVer) > serverCfgVersion then --需要让用户重新获取服务器的getconfig方法
            base.getSvrConfigFromHttpSuccess = false
            serverMgr:clear() --清空一下服务器数据
            if G_getServerCfgFromHttp(true) == true then --获取成功
                CCUserDefault:sharedUserDefault():setIntegerForKey(G_local_svrCfgVersion, tonumber(sData.cfgVer))
                CCUserDefault:sharedUserDefault():flush()
                base.curZoneServerName = GetServerName(Split(base.curServerCfgName, ",")[2])
                ----记录当前选择的服务器的zoneID
                local k1, k2 = Split(base.curServerCfgName, ",")[1], Split(base.curServerCfgName, ",")[2]
                local serverData = serverCfg:getServerInfo(k1, k2)
                local svrIP = Split(serverData.ip, ",")[1]
                local userIP = serverData.userip
                serverCfg.statisticsUrl = "http://"..svrIP..serverCfg.statisticsDir
                serverCfg.payUrl = "http://"..svrIP..serverCfg.payDir
                base.serverIp = svrIP
                base.serverUserIp = userIP
                base.memoryServerIp = serverData.msip --怀旧服入口机地址
                base.memoryServerPlatId = serverData.mspid --服务器数据中记录的各平台的平台id
                base.loginurl = serverData.loginurl
                base.payurl = serverData.payurl
                base.orderurl = serverData.orderurl
                base.curZoneID = serverData.zoneid
                base.curOldZoneID = serverData.oldzoneid
                base.curCountry = k1
                base.curArea = k2
                local domainIp = serverCfg:gucenterServerIp()
                serverCfg.baseUrl = "http://"..domainIp..serverData.domain
            end
        end
    end
    --if  sData.msg~="Success" then
    if sData.ret < 0 then
        --测试弹板
        ---129:强制更新 127:已经支付 124:请求串非法125:同一账重复登录 -130:订单创建成功，但物品添加失败 -132:通知用户退出程序更新lua
        local function sureCallBackHandler()
            if sData.ret == -129 then
                base:changeServer()
                if G_isIOS() then
                    if G_curPlatName() == "1" or G_curPlatName() == "42" then
                        PlatformManage:shared():forceUpdate()
                    else
                        if platCfg["platCfgUpdateUrl"][G_curPlatName()] ~= nil then
                            local upUrl = G_getFLUpdateUrl()
                            print("upUrlupUrl=", upUrl)
                            local updateUrl
                            if G_curPlatName() ~= "11" then
                                updateUrl = G_sendHttpRequest(upUrl, "")
                            else
                                updateUrl = upUrl
                            end
                            if updateUrl ~= nil and updateUrl ~= "" then
                                local tmpTb = {}
                                tmpTb["action"] = "openUrl"
                                tmpTb["parms"] = {}
                                tmpTb["parms"]["url"] = updateUrl
                                local cjson = G_Json.encode(tmpTb)
                                G_accessCPlusFunction(cjson)
                            end
                        else
                            AppStorePayment:shared():forceUpdate();
                        end
                    end
                else
                    local updateCfgUrl = platCfg.platCfgUpdateUrl[G_curPlatName()]
                    local updateUrl = nil
                    if updateCfgUrl ~= nil then
                        local thetmpTb = {}
                        thetmpTb["action"] = "getChannel"
                        local thecjson = G_Json.encode(thetmpTb)
                        local thechannelid = G_accessCPlusFunction(thecjson)
                        if thechannelid ~= nil and thechannelid ~= "" then
                            updateCfgUrl = updateCfgUrl.."&channelid="..thechannelid
                        else
                            updateCfgUrl = updateCfgUrl
                        end
                        updateUrl = G_sendHttpRequest(updateCfgUrl, "")
                    end
                    local realUrl = serverCfg.updateurl
                    if updateUrl ~= nil and updateUrl ~= "" then
                        realUrl = updateUrl
                    else
                        realUrl = serverCfg.updateurl
                    end
                    if G_curPlatName() == "androidom2" then
                        local tmpTb = {}
                        tmpTb["action"] = "openUrl"
                        tmpTb["parms"] = {}
                        tmpTb["parms"]["url"] = realUrl
                        local cjson = G_Json.encode(tmpTb)
                        G_accessCPlusFunction(cjson)
                    else
                        PlatformManage:shared():forceUpdateAppForAndroid(realUrl, "", "", "")
                    end
                end
            elseif sData.ret == -8023 then
                if SizeOfTable(G_AllianceDialogTb) > 0 then
                    for k, v in pairs(G_AllianceDialogTb) do
                        v:close()
                    end
                end
                allianceVoApi:clear()--清空自己军团信息和列表信息
                allianceMemberVoApi:clear()--清空成员列表
                allianceApplicantVoApi:clear()--清空
                base.allianceTime = nil
                G_getAlliance()
            elseif (sData.ret == -124 or sData.ret == -125) then
                base:changeServer()
            elseif sData.ret == -132 then
                --制造错误让程序闪退
                local ccsp = CCSprite:create()
                sceneGame:addChild(ccsp)
                ccsp:release()
                ccsp:release()
                do return end
            elseif sData.ret == -1993 or sData.ret == -2030 then
                --判断是否为交叉广告
                if self.isRandomGift == 1 then
                    local dataKey = "currWithRandomGift@"..tostring(playerVoApi:getUid()) .. "@"..tostring(base.curZoneID)
                    CCUserDefault:sharedUserDefault():setIntegerForKey(dataKey, 0)--需要拿到领奖的时间戳
                    CCUserDefault:sharedUserDefault():flush()
                end
            end
        end
        local codeStr = "backstage"..RemoveFirstChar(sData.ret)
        -- 处理有关好友申请的一些异常
        local friendErCode = ""
        if sData.ret >= -34006 and sData.ret <= -34001 then
            -- 特殊处理荣耀回归
            friendErCode = getlocal("backstage"..RemoveFirstChar(sData.ret))
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), friendErCode, 28)
            do return end
        end
        
        if sData.ret == -12001 then
            friendErCode = getlocal("friend_newSys_err_12001")
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), friendErCode, 28)
            do return end
        end
        if sData.ret == -12002 then
            friendErCode = getlocal("friend_newSys_err_12002")
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), friendErCode, 28)
            do return end
        end
        if sData.ret == -12003 then
            friendErCode = getlocal("friend_newSys_err_12003")
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), friendErCode, 28)
            do return end
        end
        if sData.ret == -12004 then
            friendErCode = getlocal("friend_newSys_err_12004")
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), friendErCode, 28)
            do return end
        end
        if sData.ret == -12005 then
            friendErCode = getlocal("friend_newSys_err_12005")
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), friendErCode, 28)
            do return end
        end
        if sData.ret == -12007 then
            friendErCode = getlocal("friend_newSys_err_12007")
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), friendErCode, 28)
            do return end
        end
        if sData.ret == -12008 then
            friendErCode = getlocal("friend_newSys_err_12008")
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), friendErCode, 28)
            do return end
        end
        if sData.ret == -12009 then
            friendErCode = getlocal("friend_newSys_err_12009")
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), friendErCode, 28)
            do return end
        end
        if sData.ret == -12010 then
            friendErCode = getlocal("")
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), friendErCode, 28)
            do return end
        end

        if sData.ret == -151 then --世界地图请求次数过多，认定为外挂加入冷却时间
            self:cancleNetWait()
            self.mapCoolingEndTs = sData and sData.data and sData.data.forbidTs or base.serverTime + 3600
            G_showCoolingTimeTip(-151)
            do return end
        end

        if sData.ret == -200 then--- 请求次数过多认为可能是外挂操作，后端报错提示要求验证
            if not self.veriIsTrue then--当前 只开验证面板一次
                self.veriIsTrue = true
                G_veriHttpRequest()
            end
            do return end
        end
        if sData.ret == -201 then -- 验证码输入错误过多 后端给报错加入冷却时间，该冷却时间内不允许弹出验证码
            self.verifyCoolingEndTs = sData and sData.data and sData.data.forbidTs or base.serverTime + 3600
            G_showCoolingTimeTip(-201)
            do return end
        end
        if sData.ret == -135 then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("backstage135"), nil, 8)
            do return end
        end

        if sData.ret == -1973 then
            if G_getBHVersion() == 2 then
                if sData.cmd == "user.troopsup" then
                    --hero.lottery
                    --user.troopsup
                    --user.dailylottery
                    --user.dailylottery
                    --"cmd":"hero.tenlottery"
                    local dataKey = "playerTab1@"..tostring(playerVoApi:getUid()) .. "@"..tostring(base.curZoneID)
                    CCUserDefault:sharedUserDefault():setStringForKey(dataKey, tostring(10))
                    CCUserDefault:sharedUserDefault():flush()
                    local dataKey = "playerTab1TimeNow@"..tostring(playerVoApi:getUid()) .. "@"..tostring(base.curZoneID)-- upperTen_small
                    CCUserDefault:sharedUserDefault():setStringForKey(dataKey, base.serverTime)
                    CCUserDefault:sharedUserDefault():flush()
                elseif sData.cmd == "user.dailylottery" and sData.isLuckyWhat == 1 then
                    local dataKey = "dailiTwoDialog@"..tostring(playerVoApi:getUid()) .. "@"..tostring(base.curZoneID)
                    CCUserDefault:sharedUserDefault():setStringForKey(dataKey, tostring(10))
                    CCUserDefault:sharedUserDefault():flush()
                elseif sData.cmd == "user.dailylottery" and sData.isLuckyWhat == 2 then
                    local dataKey = "dailiTwoDialog2@"..tostring(playerVoApi:getUid()) .. "@"..tostring(base.curZoneID)
                    CCUserDefault:sharedUserDefault():setStringForKey(dataKey, tostring(10))
                    CCUserDefault:sharedUserDefault():flush()
                elseif sData.cmd == "hero.lottery" then
                    local dataKey = "playeridx1@"..tostring(playerVoApi:getUid()) .. "@"..tostring(base.curZoneID)
                    CCUserDefault:sharedUserDefault():setStringForKey(dataKey, tostring(10))
                    CCUserDefault:sharedUserDefault():flush()
                    local dataKeys = "hero_1TimeNow@"..tostring(playerVoApi:getUid()) .. "@"..tostring(base.curZoneID)
                    local timeNow1 = base.serverTime
                    CCUserDefault:sharedUserDefault():setStringForKey(dataKeys, tostring(timeNow1))
                    CCUserDefault:sharedUserDefault():flush()
                elseif sData.cmd == "hero.tenlottery" then
                    local dataKey = "playeridx2@"..tostring(playerVoApi:getUid()) .. "@"..tostring(base.curZoneID)
                    CCUserDefault:sharedUserDefault():setStringForKey(dataKey, tostring(10))
                    CCUserDefault:sharedUserDefault():flush()
                    local dataKeys = "hero_2TimeNow@"..tostring(playerVoApi:getUid()) .. "@"..tostring(base.curZoneID)
                    local timeNow1 = base.serverTime
                    CCUserDefault:sharedUserDefault():setStringForKey(dataKeys, tostring(timeNow1))
                    CCUserDefault:sharedUserDefault():flush()
                end
                smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("upperTen"), nil, 8)
            end
        end
        if sData.ret == -127 then
            base:reSetSendPayParms()
        end
        if sData.ret ~= -127 and sData.ret ~= -130 and sData.ret ~= -128 and sData.ret ~= -1 and sData.ret ~= -5015 and sData.ret ~= -21013 and sData.ret ~= -1973 then
            -- -5001部队不在行军状态 需要同步数据不弹出错误面板 -110 建筑正在升级 -111 建筑已完成 -5015 跨服站设置部队错误，部队数和后台不匹配 -5006 繁荣度发生变化导致带兵量变化
            if sData.ret == -5001 or sData.ret == -110 or sData.ret == -111 then
                G_SyncData()
            else
                if sData.ret == -129 then
                    G_cancleLoginLoading()
                    base:cancleWait()
                end
                if sData.ret == -100 and sData.cmd == "alliance.help" then
                    codeStr = "alliance_help_too_many"
                end
                if sData.ret == -5006 then
                    G_SyncData()
                    local strLb = {getlocal("needShowStrWithRed"), getlocal("backstage5006")}
                    local colorTb = {G_ColorRed, nil}
                    local sizeTb = {30, 30}
                    smallDialog:showTableViewSureWithColorTb("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), strLb, colorTb, false, 29, nil, sizeTb)
                elseif sData.ret == -133 then
                    local function banFunc()
                        self.banDialog = false
                        if not loginScene.isShowing then
                            loginScene:close()
                            base:changeServer()
                        end
                    end
                    if sData.bannedInfo and self.banDialog ~= true then
                        self.banDialog = true
                        if math.abs(sData.bannedInfo[2] - sData.bannedInfo[1]) >= 365 * 24 * 60 * 60 then
                            local reasonStr
                            if(tonumber(sData.bannedInfo[3]) == 0)then
                                if(sData.bannedInfo[4])then
                                    reasonStr = sData.bannedInfo[4]
                                else
                                    reasonStr = getlocal("ban_reason1")
                                end
                            else
                                reasonStr = getlocal("ban_reason" .. (sData.bannedInfo[3] or 1))
                            end
                            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), reasonStr, nil, 8, nil, banFunc)
                            G_cancleLoginLoading()
                        else
                            banSmallDialog:showBanInfo("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), sData.bannedInfo, nil, 8, {nil, G_ColorRed, G_ColorRed}, banFunc)
                            G_cancleLoginLoading()
                        end
                    elseif(self.banDialog ~= true)then
                        self.banDialog = true
                        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal(codeStr), nil, 8, nil, banFunc)
                    end
                elseif self.banDialog ~= true then
                    smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal(codeStr), nil, 8, nil, sureCallBackHandler)
                end
            end
        end
        do
            return false, sData
        end
    end
    if needCheck == false then
        do
            return true, sData
        end
    end
    local beforeE = G_getCurDeviceMillTime()
    
    if sData.uid ~= nil and sData.cmd ~= "user.login" then
        if sData.uid ~= (playerVoApi:getUid() == nil and 0 or playerVoApi:getUid()) then
            do
                return false, sData
            end
        end
    end
    
    self:formatPlayerData(sData)
    otherGuideMgr:init()
    if G_phasedGuideOnOff() then
        phasedGuideMgr:init()
    end
    return true, sData
end

function base:checkServerData2(data, needCheck)
    print("socket2返回的数据", data)
    if needCheck == nil then
        needCheck = true
    end
    --接收到了服务器返回的应答
    self:cancleWait()
    self:cancleNetWait()
    local beforeE = G_getCurDeviceMillTime()
    local sData = G_Json.decode(tostring(data))
    if sData ~= nil then
        if sData.cmd == "user.sync" and base.pauseSync == true then
            do
                return false, sData
            end
        end
    end
    if sData.logints ~= nil then
        self.logints = sData.logints
    end
    if sData.access_token ~= nil then
        self.access_token = sData.access_token
    end
    if sData.uid ~= nil then
        self.curUid = tonumber(sData.uid)
    end
    
    socketHelper2:receivedResponse(sData.cmd, sData.rnum)
    if sData.ret < 0 then
        --21100到22000是军团跨服战战场的错误码
        if(sData.ret <= -21100 and sData.ret >= -22000)then
            if(serverWarTeamFightVoApi)then
                serverWarTeamFightVoApi:serverError(sData.ret)
            elseif(serverWarLocalFightVoApi)then
                serverWarLocalFightVoApi:serverError(sData.ret)
            end
        else
            local _msgStr = getlocal("backstage"..RemoveFirstChar(sData.ret))
            if tonumber(RemoveFirstChar(sData.ret)) == 1905 and acNewYearsEveVoApi and acNewYearsEveVoApi:getAcShowType() == acNewYearsEveVoApi.acShowType.TYPE_2 then
                _msgStr = getlocal("backstage"..RemoveFirstChar(sData.ret) .. "_1")
            end
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), _msgStr, 30)
        end
        return false, sData
    end
    if needCheck == false then
        do
            return true, sData
        end
    end
    if sData.uid ~= nil and sData.cmd ~= "user.login" then
        if sData.uid ~= (playerVoApi:getUid() == nil and 0 or playerVoApi:getUid()) then
            do
                return false, sData
            end
        end
    end
    self:formatPlayerData(sData)
    return true, sData
end

function base:netHandler(fn, type, isLogin, data)
    print("返回值=", fn, type, isLogin, data)
    
    if type == 1 then --显示网络loading动画
        self:setNetWait()
    elseif type == 2 then --取消loading动画(弹出网络故障)
        self:cancleWait()
        self:cancleNetWait()
        local flag = false
        if(socketHelper and socketHelper.requestArr and socketHelper.requestArr[1] and socketHelper.requestArr[1][3] == "user.login")then
            flag = true
        end
        local function onConfirm()
            if(flag)then
                if(loginScene and loginScene.close)then
                    loginScene:close()
                end
                base:changeServer()
            end
        end
        --网络故障 取消所有未发送的请求队列
        socketHelper:cancleAllWaitQueue()
        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("timeout"), nil, 200, nil, onConfirm)
    elseif type == 3 then --取消loading动画（网络已经联通,数据已经返回）
        self:cancleWait()
        self:cancleNetWait()
    elseif type == 5 then --网络不通，但不需要弹出网络故障
        self:cancleWait()
        self:cancleNetWait()
        socketHelper:cancleAllWaitQueue()
        --socketHelper:receivedErr()
    elseif type == 8 then --网络断开重新连接后
        if loginScene.loginSuccess == false then
            do
                return
            end
        end
        local function callback(fn, data)
            base:checkServerData(data)
            base.allianceTime = nil
            local function getAllianceCallback()
                G_getActiveList()
            end
            G_getAlliance(getAllianceCallback)
        end
        socketHelper:cancleAllWaitQueue()
        socketHelper:userLogin(callback, 0, G_getTankUserName(), G_getTankUserPassWord(), false)
    end
end

function base:netHandler2(fn, type, isLogin, data)
    print("rita返回值=", fn, type, isLogin, data)
    
    if type == 1 then --显示网络loading动画
        self:setNetWait()
    elseif type == 2 then --取消loading动画(弹出网络故障)
        self:cancleWait()
        self:cancleNetWait()
        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("timeout"), nil, 200)
        --网络故障 取消所有未发送的请求队列
        socketHelper2:cancleAllWaitQueue()
    elseif type == 3 then --取消loading动画（网络已经联通,数据已经返回）
        self:cancleWait()
        self:cancleNetWait()
    elseif type == 5 then --网络不通，但不需要弹出网络故障
        self:cancleWait()
        self:cancleNetWait()
        socketHelper2:cancleAllWaitQueue()
    elseif type == 8 then --网络断开重新连接后
        print("网络断开，重新连接后，尚未处理")
        if ltzdzFightApi then
            ltzdzFightApi:rSetTid()
        end
    end
end

function base:getBuildingOrderIDByBid(bPosY)
    if self.buildingSortTb == nil then
        self.buildingSortTb = {}
        local bcfgTb = homeCfg.buildingUnlock
        
        for k, v in pairs(bcfgTb) do
            if G_isApplyVersion() == true and buildingApplyUnlock[k] then --因为提审服部分建筑坐标做了调整，所以要特殊处理一下
                table.insert(self.buildingSortTb, {y = buildingApplyUnlock[k][2]})
            else
                local x, y = homeCfg:getBuildingPosById(v.bid)
                table.insert(self.buildingSortTb, {y = y})
            end
        end
        table.insert(self.buildingSortTb, {y = mainLandScene.portSpPoint.y})
        
        for k, v in pairs(tankCfg) do
            table.insert(self.buildingSortTb, {y = tonumber(v.homey)})
        end
        if homeCfg and homeCfg.tankPosition then
            for k, v in pairs(homeCfg.tankPosition) do
                table.insert(self.buildingSortTb, {y = tonumber(v.homey)})
            end
        end
        local bx, by = homeCfg:getChampionBuildingPos()
        table.insert(self.buildingSortTb, {y = tonumber(by)})
        table.sort(self.buildingSortTb, function(a, b) return a.y > b.y end)
    end
    local yindex = 1
    for k, v in pairs(self.buildingSortTb) do
        if tonumber(v.y) == tonumber(bPosY) then
            do
                return yindex
            end
        end
        yindex = yindex + 1
    end
    return 2
end

function base:dispose()
    self.serverTime = 0
    self.curIndex = 0
    self.waitLayer = nil
    self.netWaitLayer = nil
    self.allNeedRefreshDialogs = {} --显示的需要刷新的面板
    self.tipsQueue = {} --自动消失的提示框显示队列
    self.showNextTip = true
    self.lastRecordResourceTime = 0
    self.lastEnterBackGroundTimeSpan = 0 --最后一次进入后台运行经过的时间（毫秒）
    self.allShowedCommonDialog = 0 --当前所有显示在屏幕上的继承至commonDialog的对话框数量
    self.lastAutoSyncTime = 0 --同步数据用的时间
    self.buildingSortTb = nil --建筑用于排序的列表
    self.commonDialogOpened_WeakTb = {}
    G_SmallDialogDialogTb = {}
    self.lastSelectedServer = nil
    self.isShowFeedDialog = nil
    self.platformUserId = nil
    self.token = nil
    SimpleAudioEngine:sharedEngine():stopBackgroundMusic()
    self.lastGetMyAllianceDataTime = 0
    self.allianceTime = nil
    self.pauseSync = false
    self.lastPullActivityDataTime = 0 --上一次调用活动voApi tick方法的时间,每隔10秒调用一次
    self.switchServerTime = self.switchServerTime + 1
    self.nextDay = nil--明日战力暴增
    self.isNd = 0--战力暴增开关
    self.ifAllianceShopOpen = 0--军团商店开关
    self.lastSendTime = 0--上一次发送聊天时间
    self.lastSendEmojiTime = 0--上一次发送表情时间
    self.client_ip = "127.0.0.1"--用户客户端ip
    self.platusername = "" ---平台返回的玩家角色名称
    self.firstAChatFlick = 0--第一次进入游戏，军团聊天闪光
    self.joinReward = -1--是否领取首次加入军团奖励
    self.mainTaskSwitch = 0
    self.efunLoginParms = nil
    self.heroSwitch = 0
    self.serverWarTeamSwitch = 0
    self.curOldZoneID = nil
    self.worldWarSwitch = 0
    self.worldWarChampion = nil
    self.isGarrsionOpen = 0 --驻防优化开关
    self.herofeat = 0 --将领授勋开关
    self.herofeat2 = 0
    self.localWarSwitch = 0
    self.ifSuperWeaponOpen = 0
    self.loginTime = 0
    self.gxh = 0
    self.etank = 0
    self.serverWarLocalSwitch = 0
    self.ifTmpSlotOpen = 0
    self.serverPlatID = 0
    self.ifChatTransOpen = 0
    self.he = 0
    self.ea = 0
    self.ma = 0
    self.xstz = 0
    self.xstzh = 0
    self.ydhk = 0
    self.pwNoticeSwitch = 0
    self.autoUpgrade = 0 -- 建筑自动升级的功能开关
    self.allShowTipStrTb = {}
    self.dailyAcYouhuaSwitch = 0
    self.allianceWar2Switch = 0
    self.allianceAcYouhua = 0
    self.dimensionalWarSwitch = 0
    self.bs = 0
    self.isGlory = 0
    self.wl = 0 -- 世界等级开关
    self.goldmine = 0 -- 金矿系统开关
    self.minellvl = 0 --矿点升级开关
    self.chatLvLimit = 5
    self.mustmodel = 0
    self.heroOpenLv = nil
    self.heroEquipOpenLv = nil
    self.alienTechOpenLv = nil
    self.superWeaponOpenLv = nil
    self.expeditionOpenLv = nil
    self.newRechargeSwitch = 0
    self.fbboss = 0 --军团boss副本开关
    self.isRebelOpen = 0
    self.ubh = 0
    self.weekCard = 0
    self.raids = 0
    self.scroll = 0
    self.amap = 0
    self.drew1 = 0
    self.drew2 = 0
    self.alien = 0
    self.ecshop = 0
    self.richMineOpen = 0
    self.rpShop = 0
    self.boss = 0
    self.vipshop = 0
    self.succinct = 0
    self.byh = 0
    self.ifAndroidBackFunctionOpen = 0
    self.ladder = 0
    self.accessoryTech = 0
    self.accessoryBind = 0
    self.banDialog = false
    self.nbSkillOpen = 0
    self.sctlv = 0
    self.hs = 0
    self.newDailyTask = 0
    self.redAcc = 0
    self.armor = 0
    self.checkRecharge = 0
    self.isWinter = false
    G_isOpenWinterSkin = false
    self.dnews = 0
    self.webpageRecharge = 0
    self.speedUpPropSwitch = 0
    self.hexieMode = 0
    self.plane = 0
    self.powerGuide2017 = 0
    self.ltzdz = 0
    self.ltzdzTb = nil
    self.clancrossinfoBnum = nil
    self.clancrossinfoRpoint = nil
    self.smmap = 0
    self.allianceCitySwitch = 0
    self.allianceGiftSwitch = 0
    self.warStatueSwitch = 0
    self.rankPointLimit = 0
    self.bRace = 0
    self.ttjj = 0
    self.avt = 0
    self.stewardSwitch = 0
    self.needRefreshObjectTb = nil
    self.emblemTroopSwitch = 0
    self.reNameSwitch = 0
    self.championshipWarSwitch = 0
    self.armorbr = 0
    self.AITroopsSwitch = 0
    self.isDonateall = 0
    self.isAf = 0
    self.isSkin = 0
    self.rbSwitch = 0
    self.tskinSwitch = 0
    self.adjSwitch = 0
    self.bjSwitch = 0
    self.privatemine = 0
    self.newSign = 0
    self.migration = 0
    self.moji = 0
    self.prSwitch = 0
    self.militaryOrders = 0
    self.xsjx = 0
    self.shutChatSwitch = 0
    self.planeRefit = 0
    self.newUIOff = 0
    G_uiver = nil
    self.strategyCenter=0
    self.vfy = 0
    self.memoryServerIp=nil
    self.memoryServerPlatId=nil
    self.mapCoolingEndTs = nil
    self.verifyCoolingEndTs = nil
    self.veriIsTrue = nil
    self.virtualKeyboard = 1
    self.redAccessoryPromote=0
    self.airShipSwitch = 0
end

function base:changeServer(ip, port)
    
    print("============1")
    SocketHandler:shared():disConnect()
    if self.tickID ~= nil then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.tickID)
    end
    if self.fastTickID ~= nil then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.fastTickID)
    end
    if global.loginTickHandler ~= nil then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(global.loginTickHandler)
        global.loginTickHandler = nil
        global.waitLayer = nil
        global.netWaitLayer = nil
    end
    print("============2")
    if battleScene.isBattleing == true then
        battleScene:disposeWhenChangeServer()
        battleScene:dispose()
    end
    print("============4")
    G_language = ""
    G_isRefreshGetpoint = true
    playerVoApi:dispose()
    buildingVoApi:clear()
    buildingSlotVoApi:clear()
    technologySlotVoApi:clear()
    workShopSlotVoApi:clear()
    tankUpgradeSlotVoApi:clear(13)
    tankSlotVoApi:clear(11)
    tankSlotVoApi:clear(12)
    useItemSlotVoApi:clear()
    technologyVoApi:clear()
    tankVoApi:clear()
    bagVoApi:clear()
    bagVoApi:clearCache()
    bookmarkVoApi:clearBookmark()
    if checkPointVoApi and checkPointVoApi.clear then
        checkPointVoApi:clear()
    end
    attackTankSoltVoApi:clear()
    dailyVoApi:clearDaily()
    taskVoApi:clearTasks()
    taskVoApi:clearDailyTasks()
    emailVoApi:clearEmails()
    worldBaseVoApi:clear()
    chatVoApi:clear()
    rankVoApi:clear()
    reportVoApi:deleteAll()
    skillVoApi:clear()
    enemyVoApi:clear()
    newGiftsVoApi:clear()
    activityVoApi:clear()
    noteVoApi:clear()
    signVoApi:clear()
    accessoryVoApi:clear()
    allianceWarVoApi:clear()
    if allianceWar2VoApi and allianceWar2VoApi.clear then
        allianceWar2VoApi:clear()
    end
    if FuncSwitchApi:isEnabled("diku_repair") == false then
        tankWarehouseScene:dispose()
    end
    arenaVoApi:clear()
    arenaReportVoApi:clear()
    alienTechVoApi:clear()
    eventDispatcher:clear()
    print("============5")
    self:dispose()
    battleScene:dispose()
    mainLandScene:dispose()
    mainUI:dispose()
    portScene:dispose()
    storyScene:dispose()
    worldScene:dispose()
    buildings:dispose()
    socketHelper:dispose()
    if(socketHelper2)then
        socketHelper2:dispose()
    end
    allianceFubenScene:dispose()
    base:dispose()
    allianceVoApi:clear()--清空自己军团信息和列表信息
    allianceMemberVoApi:clear()--清空成员列表
    allianceApplicantVoApi:clear()--清空
    allianceSkillVoApi:clear()--清空公会技能
    allianceEventVoApi:clear()--清空公会事件
    helpDefendVoApi:clear()--清空协防
    allianceFubenVoApi:clear()--军团副本
    allianceWarRecordVoApi:clear()--军团战战报
    if allianceWar2RecordVoApi and allianceWar2RecordVoApi.clear then
        allianceWar2RecordVoApi:clear()--新军团战战报
    end
    allianceShopVoApi:clear()
    arenaVoApi:clear()--军事演习
    loginScene:stopTick()
    loginScene:showLoginScene()
    friendVoApi:clear()
    vipVoApi:clear()
    newGuidMgr:clear()
    if otherGuideMgr ~= nil then
        otherGuideMgr:clear()
    end
    shopVoApi:clear()
    pushController:clear()
    alienMinesEmailVoApi:clearEmails()
    worldWarVoApi:clear()
    
    serverWarPersonalVoApi:clear()
    playerVoApi:clear()
    heroVoApi:clear()
    serverWarTeamVoApi:clear()
    friendMailVoApi:clear()
    expeditionVoApi:clear()
    dailyActivityVoApi:clear()
    alienMinesVoApi:clear() --异形矿场
    alienMinesEnemyInfoVoApi:clear()
    alienMinesReportVoApi:deleteAll()
    if(localWarVoApi and localWarVoApi.clear)then
        localWarVoApi:clear()
    end
    if(platWarVoApi and platWarVoApi.clear)then
        platWarVoApi:clear()
    end
    if G_phasedGuideOnOff() then
        touchScene:clear()
        phasedGuideMgr:clear()
    end
    if(superWeaponVoApi and superWeaponVoApi.clear)then
        superWeaponVoApi:clear()
    end
    if allianceHelpVoApi and allianceHelpVoApi.clear then
        allianceHelpVoApi:clear()
    end
    if serverWarLocalVoApi then
        serverWarLocalVoApi:clear()
        if(serverWarLocalFightVoApi)then
            serverWarLocalFightVoApi:clear()
        end
    end
    if privateMineVoApi and privateMineVoApi.clear then
        privateMineVoApi:clear()
    end
    if (goldMineVoApi and goldMineVoApi.clear) then
        goldMineVoApi:clear()
    end
    
    self.expeditionSwitch = 0
    G_isStoryAutoHero = false
    G_isAtkAutoHero = false
    self.dailychoice = 0
    self.isPay1Open = 0
    if G_isSendAchievementToGoogle() > 0 then
        require "luascript/script/game/newguid/achievements"
        achievements:clearAll()
    end
    self.stateOfGarrsion = 1
    self.mailBlackList = 0
    G_blackList = nil
    G_blackCallbackExist = false
    self.isCheckVersion = 0
    self.isRandomGift = 0
    self.isConvertGems = 0
    self.isCheckCode = 0
    self.ifGmOpen = 0
    self.rewardcenter = 0
    if heroEquipVoApi then
        heroEquipVoApi:clear()
    end
    self.platWarSwitch = 0
    if ladderVoApi then
        ladderVoApi:clear()
    end
    if dimensionalWarVoApi and dimensionalWarVoApi.clear then
        dimensionalWarVoApi:clear()
    end
    if rebelVoApi and rebelVoApi.clear then
        rebelVoApi:clear()
    end
    self.chatReportSwitch = 0
    self.isNewBufPos = 0
    self.allianceHelpSwitch = 0
    self.fs = 0
    if buildingGuildMgr and buildingGuildMgr.clear then
        buildingGuildMgr:clear()
    end
    self.byh = 0
    self.emblemSwitch = 0
    if(emblemVoApi and emblemVoApi.clear)then
        emblemVoApi:clear()
    end
    if(emblemTroopVoApi and emblemTroopVoApi.clear)then
        emblemTroopVoApi:clear()
    end
    if(jumpScrollMgr and jumpScrollMgr.clear)then
        jumpScrollMgr:clear()
    end
    if(buildingCueMgr and buildingCueMgr.clear)then
        buildingCueMgr:clear()
    end
    if(protocolController and protocolController.clear)then
        protocolController:clear()
    end
    if(noticeMgr and noticeMgr.clear)then
        noticeMgr:clear()
    end
    if satelliteSearchVoApi then
        satelliteSearchVoApi:clear()
    end
    if armorMatrixVoApi then
        armorMatrixVoApi:clear()
    end
    if friendInfoVoApi then
        friendInfoVoApi:clear()
    end
    if dailyNewsVoApi then
        dailyNewsVoApi:clear()
    end
    if planeVoApi and planeVoApi.clear then
        planeVoApi:clear()
    end
    if ltzdzVoApi and ltzdzVoApi.clear then
        ltzdzVoApi:clear()
    end
    if workShopApi and workShopApi.clear then
        workShopApi:clear()
    end
    if allianceCityVoApi and allianceCityVoApi.clear then
        allianceCityVoApi:clear()
    end
    if allShopVoApi and allShopVoApi.clear then
        allShopVoApi:clear()
    end
    
    if believerVoApi and believerVoApi.clear then
        believerVoApi:clear()
    end
    if achievementVoApi and achievementVoApi.clear then
        achievementVoApi:clear()
    end
    if stewardVoApi and stewardVoApi.clear then
        stewardVoApi:clear()
    end
    
    if supplyShopVoApi and supplyShopVoApi.clear then
        supplyShopVoApi:clear()
    end
    
    if militaryOrdersVoApi and militaryOrdersVoApi.clear then
        militaryOrdersVoApi:clear()
    end
    
    if gloryVoApi and gloryVoApi.clearAll then
        gloryVoApi:clearAll()
    end
    if newSignInVoApi and newSignInVoApi.clearAll then
        newSignInVoApi:clearAll()
    end
    if buildDecorateVoApi and buildDecorateVoApi.clearAll then
        buildDecorateVoApi:clearAll()
    end
    
    if limitChallengeVoApi and limitChallengeVoApi.clearAll then
        limitChallengeVoApi:clearAll()
    end
    
    if championshipWarVoApi and championshipWarVoApi.clear then
        championshipWarVoApi:clear()
    end
    if AITroopsVoApi and AITroopsVoApi.clear then
        AITroopsVoApi:clear()
    end
    if AITroopsFleetVoApi and AITroopsFleetVoApi.clear then
        AITroopsFleetVoApi:clear()
    end
    if tankSkinVoApi and tankSkinVoApi.clear then
        tankSkinVoApi:clear()
    end
    if gDouble11rTb and SizeOfTable(gDouble11rTb) > 0 then
        gDouble11rTb = {}
    end
    if exerWarVoApi and exerWarVoApi.clear then
        exerWarVoApi:clear()
    end
    if migrationVoApi and migrationVoApi.clear then
        migrationVoApi:clear()
    end
    if strategyCenterVoApi and strategyCenterVoApi.clear then
        strategyCenterVoApi:clear()
    end
    if FuncSwitchApi and FuncSwitchApi.clear then
        FuncSwitchApi:clear()
    end
    if G_tzzkSaleData then
        G_tzzkSaleData = nil
    end
    if verifyApi and verifyApi.clear then
        verifyApi:clear()
    end
    if healthyApi and healthyApi.clear then
        healthyApi:clear()
    end
    if airShipVoApi and airShipVoApi.clear then
        airShipVoApi:clear()
    end

    G_removeSkinData()
end
