--[[
    文件名：HomeLayer.lua
    描述：首页Layer的显示
    创建人：heguanghui
    创建时间：2017.3.6
-- ]]

-- 重新进入该页面的玩家Id列表
local ReEnterPlayer = {}

local HomeLayer = class("HomeLayer", function(params)
    return display.newLayer()
end)

-- defaultModule: 默认打开的模块
function HomeLayer:ctor(params)
    self.mParams = params or {}
    -- 以模块ID为索引保存页面内按钮
    self.mModuleButton = {}

    -- 初始化页面控件
    self:initUI()
    -- 最底部导航按钮页面(因为底部导航按钮应该显示在最上面，所以需要最后 addChild)
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.eHome,
    })
    self.mCommonLayer_ = tempLayer
    self:addChild(tempLayer)

    -- 重要：预请求一次绝学列表，很面很多地方要用，不能删（不会重复请求接口）
    -- 判断时装功能是否开启,再刷新
    if ModuleInfoObj:moduleIsOpen(ModuleSub.eFashion, false) then
        FashionObj:getFashionList(function () end)
    end
    -- 判断副本功能是否开启,再刷新
    if ModuleInfoObj:moduleIsOpen(ModuleSub.eBattleNormal, false) then
        BattleObj:getAllChapterInfo(function () end)
    end
end

-- 初始化页面控件
function HomeLayer:initUI()
    -- 创建背景层
    local bgLayer = require("home.HomeBgLayer"):create()
    self:addChild(bgLayer)
    -- 页面中间部分控件的Parent
    self.mMiddleParent = ui.newStdLayer()
    self:addChild(self.mMiddleParent)
    -- 玩家属性控件的parent
    self.mInfoParent = ui.newStdLayer()
    self:addChild(self.mInfoParent)
    -- 顶部按钮控件的parent
    self.mTopParent = ui.newStdLayer()
    self:addChild(self.mTopParent)
    -- 等级礼包按钮控件的parent
	self.mLvGiftParent = ui.newStdLayer()
	self:addChild(self.mLvGiftParent)
    -- 底部按钮控件的parent
    self.mBottomParent = ui.newStdLayer()
    self:addChild(self.mBottomParent)

    -- 创建玩家属性相关控件
    self:createPlayerInfo()
    -- 创建顶部按钮
    self:createTopBtn()

    -- 创建底部按钮
    self:createBottomBtn()
    -- 创建人物模型
    -- self:createHeroModel()
    -- 创建测试按钮(上帝模式按钮)
    self:createTestBtn()
    -- 创建触摸事件层
    -- self:createTouchEventLayer()
    -- 创建等级礼包按钮
	self:createLvGiftBtn()
end

-- 添加触摸事件处理
function HomeLayer:createTouchEventLayer()
    local touchLayer = display.newLayer()

    --设置滑动操作
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            -- 自动关闭morebutton
            if not tolua.isnull(self.mMoreSprite) then
                self:showMoreButtons()
            end
            return true
        elseif eventType == "moved" then
        elseif eventType == "ended"  then
        elseif eventType == "cancelled" then
        end
    end

    local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(
        function(touch, event)
            local p = touch:getLocation()
            return onTouch("began", p.x, p.y)
        end,
        cc.Handler.EVENT_TOUCH_BEGAN)
    listenner:registerScriptHandler(
        function(touch, event)
            local p = touch:getLocation()
            onTouch("moved", p.x, p.y)
        end,
        cc.Handler.EVENT_TOUCH_MOVED)
    listenner:registerScriptHandler(
        function(touch, event)
            local p = touch:getLocation()
            onTouch("ended", p.x, p.y)
        end,
        cc.Handler.EVENT_TOUCH_ENDED)
    listenner:registerScriptHandler(
        function(touch, event)
            local p = touch:getLocation()
            onTouch("cancelled", p.x, p.y)
        end,
        cc.Handler.EVENT_TOUCH_CANCELLED)

    local eventDispatcher = touchLayer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self)

    self:addChild(touchLayer)
end

-- 创建玩家属性相关控件
function HomeLayer:createPlayerInfo()
    -- up玩家信息的背景
    local infoBgSprite = ui.newScale9Sprite("c_83.png", cc.size(640, 121))
    infoBgSprite:setAnchorPoint(cc.p(0, 1))
    infoBgSprite:setPosition(0, 1136)
    self.mInfoParent:addChild(infoBgSprite)

    -- 玩家头像背景
    local headBgSprite = ui.newSprite("sy_36.png")
    headBgSprite:setAnchorPoint(cc.p(0, 0))
    headBgSprite:setPosition(100, 29)
    infoBgSprite:addChild(headBgSprite)

    -- -- 体力气力背景
    -- local vitBgSprite = ui.newScale9Sprite("c_24.png", cc.size(320, 86))
    -- vitBgSprite:setPosition(cc.p(475, 75))
    -- infoBgSprite:addChild(vitBgSprite)

    -- 玩家头像
    local tempCard = CardNode:create({
        allowClick = true,
        onClickCallback = function()
            -- 查看角色信息
            LayerManager.addLayer({
                name = "home.PlayerInfoLayer",
                data = {},
                cleanUp=false
            })
        end
    })
    local Exp = PlayerAttrObj:getPlayerAttrByName("ExpAddR")
    if Exp > 0 then
        local expAddLabel = ui.newLabel({
            text = TR("经验+%d%%", math.floor(Exp/100)),
            color = Enums.Color.eGreen,
            outlineColor = Enums.Color.eOutlineColor,
            size = 18,
            })
        expAddLabel:setPosition(55, 100)
        infoBgSprite:addChild(expAddLabel, 100)
    end
    
    local function getHeroCreateConfig()
        local playerHeadModeId = PlayerAttrObj:getPlayerInfo().HeadImageId
        local headType = math.floor(playerHeadModeId / 10000)
        local heroInfo = {
            FashionModelID = PlayerAttrObj:getPlayerAttrByName("FashionModelId"),
            pvpInterLv = PlayerAttrObj:getPlayerInfo().DesignationId,
        }
        heroInfo.ModelId = playerHeadModeId
        if Utility.isIllusion(headType) then 
            heroInfo.IllusionModelId = playerHeadModeId
        end 

        return heroInfo
    end

    local function setPlayerHeader( ... )
        local headType = math.floor((PlayerAttrObj:getPlayerInfo().HeadImageId) / 10000)
        tempCard:setHero(getHeroCreateConfig(), {CardShowAttr.eBorder})
    end
    setPlayerHeader()
    tempCard:setPosition(54, 71)
    infoBgSprite:addChild(tempCard) 
    
    -- 注册头像改变事件
    Notification:registerAutoObserver(tempCard, function ()
        setPlayerHeader()
    end, {EventsName.eHeadImageId})
    
    -- 体力、气力
    local startPosX, startPosY = 340, 1133
    for index1, typeSub in pairs({ResourcetypeSub.eVIT,ResourcetypeSub.eSTA}) do
        local tmpPos = cc.p(startPosX + (index1 - 1) * 150, startPosY - 10)
    
        local tempNode = ui.createResCount(typeSub)
        tempNode.Label:enableOutline(cc.c3b(0x46, 0x22, 0x0d), 2)
        tempNode:setPosition(tmpPos)
        tempNode:setAnchorPoint(cc.p(0, 1))
        self.mInfoParent:addChild(tempNode)
    end

    --元宝、铜币
    local needAddAttr = {
        [ResourcetypeSub.eGold] = 2,
    }
    if ModuleInfoObj:moduleIsOpen(ModuleSub.eCharge, false) then
        needAddAttr[ResourcetypeSub.eDiamond] = 1
    end
    local topInfo = {ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}

    for index2, typeSub in pairs(topInfo) do
        local tmpPos = cc.p(startPosX + (index2 - 1) * 150, startPosY - 50)

        local isTable = type(typeSub) == "table"
        local resType = isTable and (typeSub.resourceTypeSub or typeSub.resourcetypeSub) or typeSub
        local modelId = isTable and typeSub.modelId or nil
        local tempNode = ui.createResCount(resType, needAddAttr[resType], modelId)
        tempNode.Label:enableOutline(cc.c3b(0x46, 0x22, 0x0d), 2)
        tempNode:setPosition(tmpPos)
        tempNode:setAnchorPoint(cc.p(0, 1))
        self.mInfoParent:addChild(tempNode)
    end

    -- 经验进度条
    local expProgBar = require("common.ProgressBar"):create({
        bgImage = "sy_40.png",
        barImage = "sy_34.png",
    })
    expProgBar:setAnchorPoint(cc.p(0, 0))
    expProgBar:setPosition(125, 29)
    infoBgSprite:addChild(expProgBar)
    -- 注册玩家经验和等级改变后，经验进度条改变的事件
    local function setExpProgress(progBar)
        local player = PlayerAttrObj:getPlayerInfo()
        local currLvExpTotal, nextLvExpTotal = 0, 100
        if player.Lv <= PlayerLvRelation.items_count and player.Lv > 0 then
            if player.Lv > 0 then
                currLvExpTotal = PlayerLvRelation.items[player.Lv].EXPTotal
            end
            if PlayerLvRelation.items[player.Lv + 1] then
                nextLvExpTotal = PlayerLvRelation.items[player.Lv + 1].EXPTotal
            end
        end
        progBar:setMaxValue(nextLvExpTotal - currLvExpTotal)
        progBar:setCurrValue(player.EXP - currLvExpTotal)
    end
    setExpProgress(expProgBar)
    Notification:registerAutoObserver(expProgBar, setExpProgress, {EventsName.eEXP, EventsName.eLv})

    -- 玩家名字
    local nameStr = PlayerAttrObj:getPlayerInfo().PlayerName
    local nameLabel = ui.newLabel({
        text = nameStr,
        size = 22,
        color = cc.c3b(0xcc, 0xfe, 0xff),
        outlineColor = cc.c3b(0x0f, 0x6b, 0xa0),
    })
    nameLabel:setAnchorPoint(cc.p(0, 0.5))
    nameLabel:setPosition(cc.p(110, 90))
    infoBgSprite:addChild(nameLabel)
    -- 玩家名更新
    Notification:registerAutoObserver(nameLabel, function()
        nameLabel:setString(PlayerAttrObj:getPlayerInfo().PlayerName)
    end, {EventsName.ePlayerName})

    -- 玩家VIP等级
    if ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eVIP) then
        local vipStartPosX = nameLabel:getContentSize().width + 115
        local vipNode = ui.createVipNode(PlayerAttrObj:getPlayerInfo().Vip)
        vipNode:setPosition(vipStartPosX, 90)
        infoBgSprite:addChild(vipNode)
        -- vip自动更新
        Notification:registerAutoObserver(vipNode.vipLabel, function()
            -- 玩家名变化需要修改vip的位置
            local vipStartPosX = nameLabel:getContentSize().width + 115
            vipNode:setPosition(vipStartPosX, 90)
            vipNode.vipLabel:setString(tostring(PlayerAttrObj:getPlayerInfo().Vip))
        end, {EventsName.eVip, EventsName.ePlayerName})
    end

    -- 玩家等级背景
    local lvPos = cc.p(115, 40)
    local lvBgSprite = ui.newSprite("sy_35.png")
    lvBgSprite:setPosition(lvPos)
    infoBgSprite:addChild(lvBgSprite)
    -- 人物等级
    local levelLabel = ui.newLabel({
        text = tostring(PlayerAttrObj:getPlayerInfo().Lv),
        size = 18,
        color = cc.c3b(0xFF, 0xFB, 0xCE),
        outlineColor = Enums.Color.eBlack,
        outlineSize = 1,
    })
    levelLabel:setPosition(lvPos)
    infoBgSprite:addChild(levelLabel)
    --添加等级更新
    Notification:registerAutoObserver(levelLabel, function ()
        levelLabel:setString(tostring(PlayerAttrObj:getPlayerInfo().Lv))
    end, {EventsName.eLv})

    -- 战力
    local fapLabel = ui.newLabel({
        text = TR("战力 %s",Utility.numberFapWithUnit(PlayerAttrObj:getPlayerInfo().FAP)),
        outlineColor = Enums.Color.eBlack,
        size = 20,
        color = cc.c3b(241, 220, 173),
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
    })
    fapLabel:setPosition(cc.p(135, 60))
    fapLabel:setAnchorPoint(cc.p(0, 0.5))
    infoBgSprite:addChild(fapLabel)
    --添加战斗力更新
    Notification:registerAutoObserver(fapLabel, function ()
        fapLabel:setString(Utility.numberFapWithUnit(PlayerAttrObj:getPlayerInfo().FAP))
    end, {EventsName.eFAP})
end

-- 创建顶部按钮
function HomeLayer:createTopBtn()
    local normalPic = PlayerAttrObj:getPlayerAttrByName("ActivityPic")
    local holidayPic = PlayerAttrObj:getPlayerAttrByName("HolidayActivityPic")
    --活动按钮列表
    self.mTopBtnInfos = {
        --充值
        {
            normalImage = "tb_78.png",
            moduleId = ModuleSub.eCharge,
            clickAction = function ()
                LayerManager.showSubModule(ModuleSub.eCharge)
            end
        },
        --首冲
        {
            normalImage = "tb_05.png",
            moduleId = ModuleSub.eFirstRecharge,
            clickAction = function ()
                local layerParams = {
                    callBack = function()
                        self:refreshActivityBtnPos()
                    end
                }
                LayerManager.addLayer({
                    name = "recharge.FirstRechargeLayer",
                    data = layerParams,
                })
            end
        },
        --成就奖励
        {
            normalImage = "tb_01.png",
            moduleId = ModuleSub.eOpenActivity,
            clickAction = function ()
                LayerManager.addLayer({
                    name = "achievement.AchievementMainLayer",
                })
            end
        },
        --七日大奖
        {
            normalImage = "tb_80.png",
            moduleId = ModuleSub.eSuccessReward,
            clickAction = function ()
                LayerManager.addLayer({
                    name = "achievement.SevenDayMainLayer",
                })
            end
        },
        -- 精彩活动
        {
            normalImage = "tb_02.png",
            moduleId = ModuleSub.eExtraActivity,
            clickAction = function ()
                LayerManager.addLayer({
                    name = "activity.ActivityMainLayer",
                    data = {moduleId = ModuleSub.eExtraActivity},
                })
            end
        },
        -- 限时活动
        {
            normalImage = (normalPic and string.len(normalPic) > 0) and normalPic or "tb_06.png",
            title = PlayerAttrObj:getPlayerAttrByName("ActivityName"),
            moduleId = ModuleSub.eTimedActivity,
            needNew = true, -- 是否需要检查new标识
            clickAction = function ()
                LayerManager.addLayer({
                    name = "activity.ActivityMainLayer",
                    data = {moduleId = ModuleSub.eTimedActivity},
                })
            end
        },
        -- 节日活动
        --[[
        {
            normalImage = (holidayPic and string.len(holidayPic) > 0) and holidayPic or "jrhd_26.png",
            title = PlayerAttrObj:getPlayerAttrByName("HolidayActivityName"),
            moduleId = ModuleSub.eChristmasActivity,
            needNew = true, -- 是否需要检查new标识
            clickAction = function ()
                LayerManager.addLayer({
                    name = "activity.ActivityMainLayer",
                    data = {moduleId = ModuleSub.eChristmasActivity},
                })
            end
        },--]]
        -- 国庆活动
        {
            normalImage = "tb_330.png",
            moduleId = ModuleSub.eAnniversary,
            clickAction = function ()
                LayerManager.addLayer({
                    name = "festival.NationalHomeLayer",
                    cleanUp = false,
                    needRestore = true,
                })
            end
        },
        -- 寻宝
        {
            normalImage = "tb_191.png",
            moduleId = ModuleSub.eDice,
            clickAction = function ()
                LayerManager.addLayer({name = "festival.NationalDiceLayer"})
            end
        },
        -- 限时掉落
        {
            normalImage = "tb_193.png",
            moduleId = ModuleSub.eTimedHolidayDrop,
            clickAction = function ()
                LayerManager.showSubModule(ModuleSub.eTimedHolidayDrop)
            end
        },
        -- 拼图活动
        {
            normalImage = "tb_194.png",
            moduleId = ModuleSub.eTimedPuzzle,
            clickAction = function ()
                LayerManager.addLayer({name = "festival.PuzzleLayer"})
            end
        },
        -- -- -- 微信关注礼包
        -- {
        --     normalImage= "tb_223.png",
        --     moduleId = ModuleSub.eExtraActivityWeChat,
        --     clickAction = function ()
        --         LayerManager.addLayer({
        --             name = "activity.ActivityWeChatLayer",
        --         })
        --     end
        -- },
        -- -- 微信礼包
        -- {
        --     normalImage= "tb_326.png",
        --     moduleId = ModuleSub.eRedBag,
        --     clickAction = function ()
        --         LayerManager.addLayer({
        --             name = "activity.ActivityWeRedBagLayer",
        --         })
        --     end
        -- },
        -- 微信红包
        -- {
        --     normalImage= "tb_04.png",
        --     isWeChatBag = true,
        --     clickAction = function ()
        --         LayerManager.addLayer({
        --             name = "redbag.WeChatRedBagMainLayer",
        --             data = {}
        --         })
        --     end
        -- },
        -- -- 限时商店
        -- {
        --     normalImage="tb_08.png",
        --     hintBgImg = "c_55.png",
        --     moduleId = ModuleSub.eTrader,
        --     needHint = true,
        --     clickAction = function ()
        --         LayerManager.addLayer({
        --             name = "shop.LimitStoreLayer",
        --             cleanUp=false
        --         })
        --     end
        -- },
        --领奖中心
        {
            normalImage = "tb_77.png",
            moduleId = ModuleSub.eRewardCenter,
            clickAction = function ()
                local layerParams = {
                    callBack = function()
                        self:refreshActivityBtnPos()
                    end
                }
                LayerManager.addLayer({
                    name = "more.RewardCenterLayer",
                    data = layerParams,
                    cleanUp = false
                })
            end
        },
        --守卫襄阳
        {
            normalImage = "tb_33.png",
            moduleId = ModuleSub.eTeambattleInvite,
            clickAction = function()
                --
                Utility.showTeambattleInvitedLayer()
            end
        },
        -- 开服比拼
        {
            normalImage = "tb_81.png",
            moduleId = ModuleSub.eOpenContest,
            clickAction = function ()
                LayerManager.addLayer({
                    name = "home.OpenContestLayer"
                })
            end
        },
        -- 十万元宝
        {
            normalImage = "tb_155.png",
            moduleId = ModuleSub.eShiWanYuanBao,
            clickAction = function ()
                LayerManager.addLayer({
                    name = "activity.ActivityMainLayer",
                    data = {
                        moduleId = ModuleSub.eExtraActivity,
                        showSubModelId = ModuleSub.eShiWanYuanBao,
                    },
                })
            end
        },

        --限时秒杀
        {
            normalImage = "tb_176.png",
            moduleId = ModuleSub.eTimedMiaoSha,
            --needHint = true, -- 是否显示倒计时提示
            clickAction = function ()
                LayerManager.addLayer({
                    name = "activity.ActivityTimeSeckill",
                    cleanUp = false,
                    data = {
                        moduleId = ModuleSub.eTimedActivity,
                        showSubModelId = ModuleSub.eTimedMiaoSha,
                    },
                })
            end
        },
        --限时船只兑换
        {
            normalImage = "tb_189.png",
            moduleId = ModuleSub.eTimedMountExchange,
            clickAction = function ()
                LayerManager.addLayer({
                    name = "activity.ActivityAdvanced",
                    cleanUp = true,
                    data = {
                        moduleId = ModuleSub.eTimedActivity,
                        showSubModelId = ModuleSub.eTimedMountExchange,
                    },
                })
            end
        },
        -- 武林盟主
        {
            normalImage = "tb_203.png",
            moduleId = ModuleSub.eWhosTheGod,
            clickAction = function()
                -- 根据时间显示主界面和膜拜界面
                -- 是否是比赛时间(星期天)
                --转换出服务器日期
                local days = MqTime.getLocalDate()
                local inOpenTime = false
                if days.wday == 1 and (((days.hour >= 18 and days.min >=30) or days.hour >= 19) and days.hour <= 21) then
                    inOpenTime = true
                end
                if inOpenTime then
                    LayerManager.addLayer({
                        name = "challenge.PvpTopHomeLayer",
                    })
                else
                    LayerManager.addLayer({
                        name = "challenge.PvpTopWorshipLayer",
                    })
                end
            end
        },
        --整点秒杀活动
        {
            normalImage = "tb_204.png",
            moduleId = ModuleSub.eTimedZhengdianMiaosha,
            clickAction = function ()
                LayerManager.addLayer({
                    name = "activity.ActivityZhengDianMiaoSha",
                    cleanUp = false,
                })
            end
        },
        -- 限时--元旦祈福
        {
            normalImage = "tb_231.png",
            moduleId = ModuleSub.eChristmasActivity17,
            clickAction = function ()
                LayerManager.showSubModule(ModuleSub.eChristmasActivity17)
            end
        },
        -- 拍卖行
        {
            normalImage = "mjrq_24.png",
            moduleId = ModuleSub.eWorldBossAuction,
            clickAction = function ()
                LayerManager.addLayer({name = "activity.AuctionHouseLayer", cleanUp = false,})
            end
        },
        -- boss预览按钮
        {
            normalImage = "mjrq_29.png",
            moduleId = ModuleSub.eShowTheWorldBoss,
            clickAction = function ()
                LayerManager.addLayer({name = "sect.SectBossPerViewLayer", cleanUp = false,})
            end
        },
        -- 挑战活动
        {
            normalImage = "tb_214.png",
            moduleId = ModuleSub.eTimedChallenge,
            clickAction = function ()
                LayerManager.addLayer({name = "festival.TopChallengeLayer", cleanUp = true,})
            end
        },
        --转盘活动
        {
            normalImage = "tb_221.png",
            moduleId = ModuleSub.eTimedLuckyTurntable,
            clickAction = function ()
                LayerManager.addLayer({
                    name = "activity.ActivityTurntableLayer",
                    cleanUp = true,
                })
            end
        },
        --金猪赛跑
        {
            normalImage = "tb_329.png",
            moduleId = ModuleSub.eCommonHoliday29,
            clickAction = function ()
                LayerManager.addLayer({
                    name = "activity.ActivityPigCompetitionLayer",
                    cleanUp = true,
                })
            end
        },
        --幻化置换
        {
            normalImage = "tb_337.png",
            moduleId = ModuleSub.eCommonHoliday30,
            clickAction = function ()
                LayerManager.addLayer({
                    name = "activity.ActivityZhihuanLayer",
                    cleanUp = true,
                })
            end
        },
        -- 礼包套餐-限时折扣
        {
            normalImage = "tb_217.png",
            moduleId = ModuleSub.eCommonHoliday15,
            clickAction = function ()
                LayerManager.addLayer({name = "recharge.GiftRechargeLayer",})
            end
        },

        -- 神雕送礼
        {
            normalImage = "tb_227.png",
            moduleId = ModuleSub.eCommonHoliday16,
            clickAction = function ()
                LayerManager.addLayer({name = "activity.ActivityHawkGiftLayer", cleanUp = true,})
            end
        },
        -- 拼图大赛
        {
            normalImage = "tb_234.png",
            moduleId = ModuleSub.eCommonHoliday17,
            clickAction = function ()
                LayerManager.addLayer({name = "festival.JigsawPuzzleLayer", cleanUp = true,})
            end
        },
        -- 猜灯谜
        {
            normalImage = "tb_257.png",
            moduleId = ModuleSub.eCommonHoliday21,
            clickAction = function ()
                LayerManager.addLayer({name = "festival.GuessLightRiddle", cleanUp = true,})
            end
        },
        -- 祈愿树
        {
            normalImage = "tb_251.png",
            moduleId = ModuleSub.eCommonHoliday18,
            clickAction = function ()
                LayerManager.addLayer({name = "festival.WiseTreeLayer", cleanUp = true,})
            end
        },
        -- 金龙宝藏
        {
            normalImage = "tb_306.png",
            moduleId = ModuleSub.eCommonHoliday26,
            clickAction = function ()
                LayerManager.addLayer({name = "activity.ActivityDragonTreasureLayer", cleanUp = true,})
            end
        },
        -- 神兵谷
        {
            normalImage = "tb_316.png",
            moduleId = ModuleSub.eCommonHoliday27,
            clickAction = function ()
                LayerManager.addLayer({name = "activity.ActivityTreasureLayer", cleanUp = true,})
            end
        },
        -- 限时特惠
        {
            normalImage = "tb_319.png",
            moduleId = ModuleSub.eCommonHoliday28,
            clickAction = function ()
                LayerManager.addLayer({name = "activity.ActivityPreferentialLayer", cleanUp = false,})
            end
        },
        -- 孔明灯
        {
            normalImage = "tb_250.png",
            moduleId = ModuleSub.eCommonHoliday19,
            clickAction = function ()
                LayerManager.addLayer({name = "festival.KongminLightLayer", cleanUp = true,})
            end
        },
        -- 集5福
        {
            normalImage = "tb_276.png",
            moduleId = ModuleSub.eTimedFiveFu,
            clickAction = function ()
                LayerManager.addLayer({name = "festival.CollectFiveFuLayer", cleanUp = true,})
            end
        },
        -- 至尊宝藏
        {
            normalImage = "tb_277.png",
            moduleId = ModuleSub.eTimedSupreme,
            clickAction = function ()
                LayerManager.addLayer({name = "festival.spremeTreasureLayer", cleanUp = true,})
            end
        },
        --挖宝活动
        {
            normalImage = "jrhd_110.png",
            moduleId = ModuleSub.eTimedDigTreasure,
            clickAction = function ()
                LayerManager.addLayer({
                    name = "festival.DigTreasureLayer",
                    cleanUp = true,
                })
            end
        },
        --射靶活动
        {
            normalImage = "tb_290.png",
            moduleId = ModuleSub.eTimedShoottarget,
            clickAction = function ()
                LayerManager.addLayer({
                    name = "activity.ActivityShootArrowLayer",
                })
            end
        },
        -- 守卫光明顶挂机
        {
            normalImage = "tb_241.png",
            moduleId = ModuleSub.eExpedition,
            hintBgImg = "c_55.png", -- 倒计时背景图
            needHint = true, -- 是否显示倒计时提示
            clickAction = function()
                -- 回到挑战打开光明顶模块
                LayerManager.addLayer({
                    name = "challenge.ChallengeLayer",
                    data = {autoOpenModule = ModuleSub.eExpedition}
                })
            end
        },
        --VIP贵宾
        {
            normalImage="tb_244.png",
            moduleId = ModuleSub.eSVIP,
            clickAction = function ()
                local layerParams = {
                    callBack = function()
                        self:refreshTopBtnPos()
                    end
                }
                LayerManager.addLayer({
                    name = "home.VipGuestLayer", 
                    data = layerParams,
                    cleanUp = false,
                })
            end
        },
        --限时赏金
        -- 雪鹰里的图是 “限时任务”， 这里没找到
        {
            normalImage = "tb_03.png",
            moduleId = ModuleSub.eTimeLimitTheBounty,
            hintBgImg = "c_55.png", -- 倒计时背景图
            needHint = true, -- 是否显示倒计时提示
            clickAction = function ()
                LayerManager.addLayer({
                    name = "home.TimeLimitTheBountyLayer",
                    cleanUp = false
                })
            end
        },
        --种菜活动
        {
            normalImage = "tb_264.png",
            moduleId = ModuleSub.eTimedvegetables,
            clickAction = function ()
                LayerManager.addLayer({
                    name = "activity.VegetablesHomeLayer",
                })
            end
        },
        --祝福任务
        {
            normalImage = "tb_292.png",
            moduleId = ModuleSub.eTimedBlessingTask,
            clickAction = function ()
                LayerManager.addLayer({
                    name = "festival.BlessingTaskLayer",
                })
            end
        },
        --QQ会员特权
        {
            normalImage = "tb_270.png",
            moduleId = ModuleSub.ePrivilege,
            clickAction = function ()
                LayerManager.addLayer({
                    name = "activity.QQVipWelfareLayer",
                    cleanUp = false,
                })
        
            end
        },
        --分享有礼
        {
            normalImage = "fx_12.png",
            moduleId = ModuleSub.eTimedShare,
            clickAction = function ()
                LayerManager.addLayer({
                    name = "activity.ActivityShareLayer",
                    cleanUp = false,
                })
        
            end
        },
        --邀请有礼
        {
            normalImage = "yq_7.png",
            moduleId = ModuleSub.eInvite,
            clickAction = function ()
                LayerManager.addLayer({
                    name = "activity.ActivityInviteLayer",
                })
            end
        },
        --限时-限时签到
        {
            normalImage = "tb_302.png",
            moduleId = ModuleSub.eCommonHoliday25,
            clickAction = function ()
                LayerManager.addLayer({
                    name = "activity.ActivityMourningSignLayer",
                })
            end
        },
        --充值返利
        {
            normalImage = "fl_8.png",
            moduleId = ModuleSub.eTimedChargeRebate,
            clickAction = function ()
                LayerManager.addLayer({
                    name = "activity.ActivityTimedChargeRebateLayer",
                })
        
            end
        },
        --会员中心
        {
            normalImage = "hyzx_01.png",
            moduleId = ModuleSub.eVIPcenter,
            clickAction = function ()
                IPlatform:getInstance():invoke("OpenGDMemberCenter", "", function() end)        
            end
        },      
        --江湖秘藏
        {
            normalImage = "tb_356.png",
            moduleId = ModuleSub.eCommonHoliday31,
            clickAction = function ()
                LayerManager.addLayer({
                    name = "activity.ActivityWorldSecretLayer",
                })
            end
        },
        -- 在线奖励
        {
            normalImage = "tb_07.png",
            moduleId = ModuleSub.eOnlineReward,
            hintBgImg = "c_55.png", -- 倒计时背景图
            needHint = true, -- 是否显示倒计时提示
            clickAction = function()
                local tempStatus = OnlineRewardObj:getRewardStatus()
                if tempStatus ~= Enums.OnlineRewardStatus.eHaveInfo then
                    ui.showFlashView(TR("没有在线奖励可以领取"))
                    return
                end
                -- 奖励还不能领取
                if not OnlineRewardObj:allowReward() then
                    LayerManager.addLayer({
                        name = "home.OnlineRewardLayer",
                        cleanUp = false,
                        data = {
                            resourceList = OnlineRewardObj:getResourceList()
                        }
                    })
                    return
                end

                OnlineRewardObj:requestDrawOnlineReward(function(response)
                    if not response or response.Status ~= 0 then
                        -- 获取奖励返回失败后，重新获取在线奖励信息
                        OnlineRewardObj:reset()
                        OnlineRewardObj:requestOnlineRewardInfo()
                        return
                    end
                    ui.ShowRewardGoods(response.Value.BaseGetGameResourceList, true)
                end)
            end
        },
        -- 限时在线奖励
        {
            normalImage = "tb_357.png",
            moduleId = ModuleSub.eCommonHoliday32,
            hintBgImg = "c_55.png", -- 倒计时背景图
            needHint = true, -- 是否显示倒计时提示
            clickAction = function()
                LayerManager.addLayer({name = "activity.ActivityTimeOnlineLayer", cleanUp = false})
            end
        },
        -- 代理侠客
        {
            normalImage = "tb_359.png",
            moduleId = ModuleSub.eGuaji,
            clickAction = function()
                LayerManager.addLayer({name = "home.DlgGuajiLayer", cleanUp = false})
            end
        },
    }

    for _, btnInfo in ipairs(self.mTopBtnInfos) do
        -- 部分活动添加标题
        if btnInfo.title then
            btnInfo.text = btnInfo.title
            btnInfo.fontSize = 20
            btnInfo.textColor = Enums.Color.eWhite          -- #fbea08
            btnInfo.outlineColor = cc.c3b(0x0b, 0x0b, 0x0b) -- #804715
            btnInfo.outlineSize = 2
            btnInfo.titlePosRateY = 0.185
        end

        -- 创建按钮
        local tempBtn = ui.newButton(btnInfo)
        self.mTopParent:addChild(tempBtn)
        btnInfo.buttonObj = tempBtn
        local btnSize = tempBtn:getContentSize()

        if btnInfo.moduleId == ModuleSub.eOnlineReward then -- 在线奖励
            local tempStatus = OnlineRewardObj:getRewardStatus()
            if tempStatus == Enums.OnlineRewardStatus.eGetSvrData then  -- 需要请求在线奖励服务器数据
                OnlineRewardObj:requestOnlineRewardInfo()
            end
        elseif btnInfo.moduleId == ModuleSub.eCommonHoliday32 then -- 限时在线奖励
            -- 刷新奖励倒计时
            if ActivityObj:getActivityItem(btnInfo.moduleId) then
                require("activity.ActivityTimeOnlineLayer").refreshRewardCount()
            end
        elseif btnInfo.moduleId == ModuleSub.eExpedition then -- 光明顶挂机
            if ExpediGuaJiObj:getIsGuaJi() and ExpediGuaJiObj:getGuaJiInfo() == nil then 
                ExpediGuaJiObj:requestExpediGuaJiInfo()
            end 
        elseif btnInfo.moduleId == ModuleSub.eFirstRecharge then    -- 至尊首冲
            ui.newEffect({
                parent = tempBtn,
                effectName = "effect_ui_zhizhunshouchong",
                position = cc.p(btnSize.width / 2, btnSize.height / 2),
                loop = true,
                endRelease = true,
                rotationY = true,
            })
        elseif btnInfo.moduleId == ModuleSub.eCharge then    -- 充值
            ui.newEffect({
                parent = tempBtn,
                effectName = "effect_ui_tubiaotexiao",
                position = cc.p(btnSize.width / 2, btnSize.height / 2),
                loop = true,
                endRelease = true,
            })
        elseif btnInfo.moduleId == ModuleSub.eAnniversary then    -- 国庆活动
            ui.newEffect({
                parent = tempBtn,
                effectName = "effect_ui_shuangjiekuanghuan",
                position = cc.p(btnSize.width / 2, btnSize.height / 2),
                loop = true,
                endRelease = true,
            })
        elseif btnInfo.moduleId == ModuleSub.eShowTheWorldBoss then    -- 国庆活动
            ui.newEffect({
                parent = tempBtn,
                effectName = "effect_ui_mojiaoruqin",
                position = cc.p(btnSize.width / 2, btnSize.height / 2),
                loop = true,
                endRelease = true,
            })
        end

        -- 提示信息的位置
        local hintPos = cc.p(btnSize.width / 2, -10)
        if btnInfo.hintBgImg and btnInfo.hintBgImg ~= "" then
            local tempSprite = ui.newScale9Sprite(btnInfo.hintBgImg, cc.size(100, 20))
            tempSprite:setPosition(hintPos)
            tempBtn:addChild(tempSprite)

            btnInfo.hintBgSprite = tempSprite
        end
        if btnInfo.needHint then
            local tempLabel = ui.newLabel({
                text = "00:00:00",
                size = 18,
                color = cc.c3b(0x80, 0xFF, 0x33),
            })
            tempLabel:setAnchorPoint(cc.p(0.5, 0.5))
            tempLabel:setPosition(hintPos)
            tempBtn:addChild(tempLabel)

            btnInfo.hintLabel = tempLabel
        end

        if btnInfo.moduleId or btnInfo.isWeChatBag then
            -- 限时活动的new标识逻辑
            if btnInfo.needNew then
                -- 处理new标识是否显示的函数
                local function dealNewVisible(newSprite)
                    newSprite:setVisible(RedDotInfoObj:isNewValid(btnInfo.moduleId))
                end
                ui.createAutoBubble({parent = tempBtn, isNew = true, refreshFunc = dealNewVisible,
                    eventName = RedDotInfoObj:getNewEvents(btnInfo.moduleId)})
            end

            -- 小红点逻辑
            local function dealRedDotVisible(redDotSprite)
                local redDotData = false
                if btnInfo.isWeChatBag then
                else
                    redDotData = RedDotInfoObj:isValid(btnInfo.moduleId)
                    if redDotData and ModuleSub.eTimeLimitTheBounty == btnInfo.moduleId then -- 限时任务
                        local tempConfig = TimeLimitObj:getConfigItem()
                        if not tempConfig or tempConfig.receiveLV > PlayerAttrObj:getPlayerAttrByName("Lv") then
                            redDotData = false
                        end
                    end
                end
                redDotSprite:setVisible(redDotData)
            end
            -- 事件名
            local eventNames = btnInfo.isWeChatBag and {} or RedDotInfoObj:getEvents(btnInfo.moduleId)
            ui.createAutoBubble({parent = tempBtn, eventName = eventNames, refreshFunc = dealRedDotVisible})

            if btnInfo.moduleId then
                self.mModuleButton[btnInfo.moduleId] = tempBtn
            end

            -- 拍卖行被竞拍的小红点
            if btnInfo.moduleId == ModuleSub.eWorldBossAuction then
                local function dealWorldBossRedDotVisible(redDotSprite)
                    redDotSprite:setVisible(RedDotInfoObj:isValid(ModuleSub.eWorldBossAuctionRedPoint))
                end
                ui.createAutoBubble({parent = tempBtn, imgName ="c_115.png", 
                    eventName = RedDotInfoObj:getEvents(ModuleSub.eWorldBossAuctionRedPoint), refreshFunc = dealWorldBossRedDotVisible})
            end
            if btnInfo.moduleId == ModuleSub.eWhosTheGod then
                 local function dealPvpTopRedDotVisible(redDotSprite)
                    redDotSprite:setVisible(RedDotInfoObj:isValid(Enums.ClientRedDot.ePvpTop))
                end
                ui.createAutoBubble({parent = tempBtn, 
                    eventName = RedDotInfoObj:getEvents(Enums.ClientRedDot.ePvpTop), refreshFunc = dealPvpTopRedDotVisible})
            end 
            -- svip会员小红点
            if btnInfo.moduleId == ModuleSub.eSVIP then
            	local function dealSVIPRedDotVisible(redDotSprite)
            		local svipState = PlayerAttrObj:getPlayerAttrByName("SvipState")
                    redDotSprite:setVisible(svipState == 1)
                end
                ui.createAutoBubble({parent = tempBtn, eventName = EventsName.eSvipState, refreshFunc = dealSVIPRedDotVisible})
            end
        end
    end

    -- 注册顶部按钮显示变化的事件
    local eventNames = {
        EventsName.eHasDrawSuccessReward,  --七日大奖是否领取
        EventsName.eIsZhiZunFirstCharge, -- 是否显示首充
        EventsName.eOpencontestState, -- 开服比拼
        EventsName.eTriggerLv,  -- 当前触发限时赏金等级
        EventsName.eIsTriggerReceived, -- 是否已领取限时赏金奖励 用于最后一次领取
        EventsName.eSvipState, -- 是否VIP贵宾
        EventsName.eExpeditionGuaJi, -- 光明顶挂机
        EventsName.eRedDotPrefix .. tostring(ModuleSub.eOnlineReward), -- 在线奖励
        EventsName.eRedDotPrefix .. tostring(ModuleSub.eTrader), -- 限时商店
        EventsName.eRedDotPrefix .. tostring(ModuleSub.eRewardCenter), --  领奖中心
        EventsName.eSocketPushPrefix .. tostring(ModuleSub.eTeambattleInvite), --  守卫襄阳
        EventsName.eRedDotPrefix .. tostring(ModuleSub.eTimeLimitTheBounty), -- 限时赏金
        EventsName.eRedDotPrefix .. tostring(ModuleSub.eShiWanYuanBao), -- 十万元宝
        EventsName.eRedDotPrefix .. tostring(ModuleSub.eTimedMiaoSha), -- 限时秒杀
        EventsName.eRedDotPrefix .. tostring(ModuleSub.eTimedMountExchange), -- 限时兑换船只
        EventsName.eRedDotPrefix .. tostring(ModuleSub.eWorldBossAuction), -- 拍卖行
    }
    Notification:registerAutoObserver(self.mTopParent, function() self:refreshTopBtnPos() end, eventNames)
    self:refreshTopBtnPos()
end

-- 创建底部按钮
function HomeLayer:createBottomBtn()
    self.mBottomBtnInfos = {
        -- 宝阁
        {
            normalImage = "tb_238.png",
            moduleId = Enums.ClientRedDot.eHomeShop,
            clickAction = function()
                LayerManager.addLayer({
                    name = "home.ShopEntranceLayer",
                    cleanUp = false,
                    needRestore = true
                })
                -- 仅首页进入时播放音效
                MqAudio.playEffect("baoge_open.mp3")
            end
        },
        --帮派
        {
            normalImage = "tb_237.png",
            moduleId = ModuleSub.eGuild,
            clickAction = function()
                if not ModuleInfoObj:moduleIsOpen(ModuleSub.eGuild, true) then
                    return
                end

                local guildInfo = GuildObj:getGuildInfo()
                if Utility.isEntityId(guildInfo.Id) then
                    LayerManager.addLayer({
                        name = "guild.GuildHomeLayer"
                    })
                else
                    LayerManager.addLayer({name = "guild.GuildSearchLayer"})
                end
            end
        },
        -- 任务
        {
            normalImage = "tb_239.png",
            moduleId = ModuleSub.eDaliyTask,
            clickAction = function()
                if not ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eDaliyTask, true) then
                    return
                end
                LayerManager.addLayer({
                    name = "dailytask.DailyTaskLayer",
                    data = params or {},
                    cleanUp = false,
                    needRestore = true,
                })
            end
        },
        { -- 包裹
            normalImage = "tb_129.png",
            moduleId = ModuleSub.eBag,
            newModuleId = ModuleSub.eBag,
            clickAction = function (pSender)
                 LayerManager.addLayer({
                    name = "bag.BagLayer"
                })
            end
        },
    }
    -- 部分模块需要达到开放等级才显示
    if ModuleInfoObj:moduleIsOpen(ModuleSub.eSect, false) then
        -- 八大门派
        table.insert(self.mBottomBtnInfos, {
            normalImage = "tb_236.png",
            moduleId = ModuleSub.eSect,
            clickAction = function()
                SectObj:getSectInfo(function(response)
                    if response.IsJoinIn then
                        LayerManager.addLayer({name = "sect.SectLayer", data = {}})
                    else
                        LayerManager.addLayer({name = "sect.SectSelectLayer", data = {}})
                    end
                end)
            end
        })
    end
    if ModuleInfoObj:moduleIsOpen(ModuleSub.eDisassemble, false) then
        -- 铸炼
        table.insert(self.mBottomBtnInfos, {
            normalImage = "tb_235.png",
            moduleId = ModuleSub.eDisassemble,
            clickAction = function(pSender)
                LayerManager.addLayer({name = "disassemble.DisassembleLayer", data = params or {}})
            end
        })
    end
    if ModuleInfoObj:moduleIsOpen(ModuleSub.eJiangHuKill, false) then
        -- 江湖杀
        table.insert(self.mBottomBtnInfos, {
            normalImage = "tb_300.png",
            moduleId = ModuleSub.eJiangHuKill,
            clickAction = function()
                LayerManager.addLayer({name = "jianghuKill.JianghuKillMapLayer"})
                -- 结束引导
                local _, _, eventID = Guide.manager:getGuideInfo()
                if eventID == 10052 then
                    Guide.manager:nextStep(eventID, true)
                    Guide.manager:removeGuideLayer()
                end
            end
        })
    end
    if ModuleInfoObj:moduleIsOpen(ModuleSub.eZhenshou, false) then
        -- 珍兽
        table.insert(self.mBottomBtnInfos, {
            normalImage = "tb_311.png",
            moduleId = ModuleSub.eZhenshou,
            clickAction = function()
                LayerManager.addLayer({name = "zhenshou.ZhenshouMainLayer",})
            end
        })
    end
    -- 修炼
    if ModuleInfoObj:moduleIsOpen(ModuleSub.eZhenyuanRecruit, false) then
        table.insert(self.mBottomBtnInfos, { 
            normalImage = "tb_285.png",
            isPractice = true,
            clickAction = function (pSender)
                -- 显示修炼按钮界面
                self:showPracticeButtons(pSender)
            end
        })
    end
    -- 更多
    table.insert(self.mBottomBtnInfos, { -- 更多
        normalImage = "tb_09.png",
        isShowMore = true, -- 是否是更多按钮
        btnTag = moreButtonTag,
        clickAction = function (pSender)
            -- 显示更多按钮界面
            self:showMoreButtons(pSender)
        end
    })

    local rowCount, btnIndex = 5, 0
    local cellSize = cc.size(500 / rowCount, 92)
    local startPosX, startPosY = 564, 158
    for _, btnInfo in ipairs(self.mBottomBtnInfos) do
        local needVisible = not btnInfo.moduleId or ModuleInfoObj:moduleIsOpenInServer(btnInfo.moduleId)

        if needVisible then
            btnIndex = btnInfo.position and btnIndex or (btnIndex + 1)
            local tempPosX = startPosX - math.mod((btnIndex - 1), rowCount) * cellSize.width
            local tempPosY = startPosY + math.floor((btnIndex - 1) / rowCount) * cellSize.height
            local tempBtn = ui.newButton(btnInfo)
            tempBtn:setPosition(btnInfo.position or cc.p(tempPosX, tempPosY))
            self.mBottomParent:addChild(tempBtn)
            btnInfo.buttonObj = tempBtn

            local btnSize = tempBtn:getContentSize()
            -- 添加特效
            if btnInfo.moduleId == ModuleSub.eJiangHuKill then  -- 江湖杀
                if require("jianghuKill.JianghuKillSelectForceLayer").isWarTime() then
                    ui.newEffect({
                            parent = tempBtn,
                            effectName = "effect_ui_jianghusha",
                            position = cc.p(btnSize.width / 2, btnSize.height / 2),
                            loop = true,
                        })
                end
            end

            -- 小红点逻辑 和 new 标识逻辑
            if btnInfo.moduleId or btnInfo.isShowMore or btnInfo.isPractice then
                local usedModuleId = btnInfo.moduleId
                if btnInfo.isShowMore then
                    usedModuleId = Enums.ClientRedDot.eHomeMore
                elseif btnInfo.isPractice then
                    usedModuleId = Enums.ClientRedDot.eHomePractice
                end
                -- 小红点

                if btnInfo.newModuleId then
                    -- 处理new标识是否显示的函数
                    local function dealNewVisible(newSprite)
                        newSprite:setVisible(RedDotInfoObj:isNewValid(btnInfo.newModuleId))
                    end
                    ui.createAutoBubble({parent = tempBtn, isNew = true, position = btnInfo.newPosition, refreshFunc = dealNewVisible,
                        eventName = RedDotInfoObj:getNewEvents(btnInfo.newModuleId)})
                end

                local function dealRedDotVisible(redDotSprite)
                    redDotSprite:setVisible(RedDotInfoObj:isValid(usedModuleId))
                end
                ui.createAutoBubble({parent = tempBtn, eventName = RedDotInfoObj:getEvents(usedModuleId), refreshFunc = dealRedDotVisible})
            end

            -- 保存按钮
            if btnInfo.isShowMore then
                self.mMoreBtn = tempBtn
            elseif btnInfo.isPractice then
                self.mPracticeBtn = tempBtn
            elseif btnInfo.moduleId then
                self.mModuleButton[btnInfo.moduleId] = tempBtn
            end
        end
    end
end

-- 创建左下角人物模型
function HomeLayer:createHeroModel()
    local tempNode = cc.Node:create()
    self.mMiddleParent:addChild(tempNode)

    local tempHeight = 450
    local function createHero()
        tempNode:removeAllChildren()

        local tempHero = Figure.newHero({
            heroModelID = PlayerAttrObj:getPlayerInfo().HeadImageId,
            position = cc.p(80, -60),
            scale = 0.35,
            swallow = true,
            buttonAction = function()
                LayerManager.addLayer({
                    name = "team.TeamLayer",
                })
            end
        })
        tempNode:addChild(tempHero)

        Utility.performWithDelay(tempHero, function()
            local skeletonSize = tempHero.button:getContentSize()
            local scale = tempHero:getScale()
            local tempY = tempHeight - skeletonSize.height * scale
            -- 重设神将的位置
            tempHero:setPosition(80, tempY)
        end, 0.001)
    end
    -- 注册角色模型改变事件
    Notification:registerAutoObserver(tempNode, createHero, {EventsName.eHeadImageId})
    createHero()
end

-- 创建等级礼包按钮
function HomeLayer:createLvGiftBtn()
    -- 判断模块是否开启
    if not ModuleInfoObj:moduleIsOpen(ModuleSub.eFunctionOpen, false) then
        return
    end
    -- 判断是否已结束
    if not PlayerAttrObj:getPlayerAttrByName("IsFunctionOpen") then
        return
    end

    -- 图标按钮
    local tempBtn = ui.newButton({
        normalImage = "xgnkq8.png",
        clickAction = function()
            LayerManager.addLayer({name = "home.DlgFunctionOpenLayer", cleanUp = false})
        end,
    })
    tempBtn:setPosition(560, 350)
    self.mLvGiftParent:addChild(tempBtn)
    -- 注册小红点
    local function dealRedDotVisible(redDotSprite)
        redDotSprite:setVisible(RedDotInfoObj:isValid(ModuleSub.eFunctionOpen))
    end
    local eventNames = RedDotInfoObj:getEvents(ModuleSub.eFunctionOpen)
    ui.createAutoBubble({parent = tempBtn, eventName = eventNames, refreshFunc = dealRedDotVisible})
end

-- 创建测试按钮(上帝模式按钮)
function HomeLayer:createTestBtn()
    -- 如果是正式版本，则不能显示相关内容
    if not Utility.isDebugVersion() then
        return
    end

    local tempLayer = ui.newStdLayer()
    self:addChild(tempLayer)

    --
    local tempBtn = ui.newButton({
        normalImage = "c_75.png",
        clickAction = function()
            print("按下上帝模式按钮")
            LayerManager.addLayer({name = "home.TestLayer"})
        end,
    })
    tempBtn:setPosition(20, 520)
    tempLayer:addChild(tempBtn)
end

-- 创建“修炼”按钮
function HomeLayer:showPracticeButtons()
    if not self.mPracticeBtn or tolua.isnull(self.mPracticeBtn) then
        return
    end

    if self.mPracticeSprite and not tolua.isnull(self.mPracticeSprite) then
        local actList = {
            cc.ScaleTo:create(0.25, 0.2),
            cc.CallFunc:create(function ()
                self.mPracticeSprite:removeFromParent()
                self.mPracticeSprite = nil
            end)
        }
        self.mPracticeSprite:runAction(cc.Sequence:create(actList))
    else
        -- 添加更多内按钮
        local practiceButtons = {
            --练气
            {
                normalImage = "tb_222.png",
                moduleId = ModuleSub.eZhenyuan,
                clickAction = function()
                    if not ModuleInfoObj:moduleIsOpen(ModuleSub.eZhenyuan, true) then
                        return
                    end
                    LayerManager.addLayer({
                        name = "zhenyuan.ZhenYuanTabLayer",
                        data = {},
                    })
                end
            },
        }
        -- 冥想
        if ModuleInfoObj:moduleIsOpen(ModuleSub.eNeiliMingxiang, false) then
            table.insert(practiceButtons, {
                normalImage = "nl_26.png",
                moduleId = ModuleSub.eNeiliMingxiang,
                clickAction = function ()
                    if not ModuleInfoObj:moduleIsOpen(ModuleSub.eNeiliMingxiang, true) then
                        return
                    end
                    LayerManager.addLayer({
                        name = "hero.MeditationLayer",
                    })
                end
            })
        end
        -- 炼丹
        if ModuleInfoObj:moduleIsOpen(ModuleSub.eMedicine, false) then
            table.insert(practiceButtons, {
                normalImage = "tb_232.png",
                moduleId = ModuleSub.eMedicine,
                clickAction = function ()
                    if not ModuleInfoObj:moduleIsOpen(ModuleSub.eMedicine, true) then
                        return
                    end
                    LayerManager.addLayer({name = "quench.QuenchAlchemyLayer",})
                end
            })
        end
        -- 珍兽牢狱
        if ModuleInfoObj:moduleIsOpen(ModuleSub.eZhenshouLaoyu, false) then
            table.insert(practiceButtons, {
                normalImage = "tb_312.png",
                moduleId = ModuleSub.eZhenshouLaoyu,
                clickAction = function ()
                    if not ModuleInfoObj:moduleIsOpen(ModuleSub.eZhenshouLaoyu, true) then
                        return
                    end
                    LayerManager.addLayer({name = "zsly.ZslyMainLayer",})
                end
            })
        end

        -- 创建更多按钮的背景框
        local parentPosX, parentPosY = self.mPracticeBtn:getPosition()
        local tempSize = cc.size(220, 200)
        local heightNum = math.ceil(#practiceButtons/2)
        if heightNum > 1 then
            tempSize = cc.size(220, 200+(heightNum-1)*100)
        end
        self.mPracticeSprite = ui.newScale9Sprite("gd_01.png", tempSize)
        self.mPracticeSprite:setPosition(parentPosX, parentPosY - 35)

        self.mPracticeSprite:setAnchorPoint(cc.p(0.25, 0))
        -- 吞并下层事件
        ui.registerSwallowTouch({node=self.mPracticeSprite, beganEvent = function (touch, event)
            if not ui.touchInNode(touch, self.mPracticeSprite) then
                -- 点击做生意区域则收回弹框
                self:showPracticeButtons()
            end
            return true
        end})

        -- 设置更多按钮的动画效果
        self.mPracticeSprite:setScale(0.2)
        local actList = {
            cc.ScaleTo:create(0.25, 1.0),
            cc.CallFunc:create(function ()
                -- 继续引导
                local _, _, eventID = Guide.manager:getGuideInfo()
                if eventID == 10017 or eventID == 10018 or eventID == 10067 then
                    Guide.manager:nextStep(eventID)
                    self:executeGuide()
                end
            end)
        }
        self.mPracticeSprite:runAction(cc.Sequence:create(actList))
        self.mBottomParent:addChild(self.mPracticeSprite, -1)


        for k, btnInfo in ipairs(practiceButtons) do
            btnInfo.position = cc.p(((k-1)%2)*tempSize.width/2+tempSize.width/4, tempSize.height-(math.floor((k-1)/2)*95 + 55))
            local tempBtn = ui.newButton(btnInfo)
            self.mPracticeSprite:addChild(tempBtn)

            -- 有模块Id的按钮需要添加小红点的逻辑
            if btnInfo.moduleId then
                local function dealRedDotVisible(redDotSprite)
                    redDotSprite:setVisible(RedDotInfoObj:isValid(btnInfo.moduleId))
                end
                -- 事件名
                local eventNames = RedDotInfoObj:getEvents(btnInfo.moduleId)
                ui.createAutoBubble({parent = tempBtn, eventName = eventNames, refreshFunc = dealRedDotVisible})

                -- 保存用于新手引导
                self.mModuleButton[btnInfo.moduleId] = tempBtn
            end
        end
    end
end

-- 创建“更多”按钮
function HomeLayer:showMoreButtons()
    if not self.mMoreBtn or tolua.isnull(self.mMoreBtn) then
        return
    end

    if self.mMoreSprite and not tolua.isnull(self.mMoreSprite) then
        local actList = {
            cc.ScaleTo:create(0.25, 0.2),
            cc.CallFunc:create(function ()
                self.mMoreSprite:removeFromParent()
                self.mMoreSprite = nil
            end)
        }
        self.mMoreSprite:runAction(cc.Sequence:create(actList))
    else
        -- 添加更多内按钮
        local moreButtons = {
            --公告
            {
                normalImage = "gd_02.png",
                moduleId = ModuleSub.eBulletin,
                clickAction = function()
                    LayerManager.addLayer({
                        name = "more.NoticeLayer",
                        cleanUp = false,
                        zOrder = Enums.ZOrderType.eAnnounce,
                    })
                end
            },
            -- 图鉴
            {
                normalImage = "gd_07.png",
                clickAction = function ()
                    LayerManager.addLayer({
                        name = "Illustrations.IllustrationsLayer",
                        --cleanUp = false,
                    })
                end
            },
            -- 设置界面
            {
                normalImage = "gd_06.png",
                clickAction = function()
                    local layerParams = {}
                    LayerManager.addLayer({
                        name = "more.SystemOptionLayer",
                        cleanUp = false
                    })
                end
            },
            -- 账号切换
            {
                normalImage = "gd_09.png",
                clickAction = function()
                    IPlatform:getInstance():logout()
                    -- LayerManager.addLayer({
                    --     name = "more.LogoutAccoutLayer",
                    --     cleanUp = false
                    -- })
                end
            },
            -- -- 攻略
            -- {
            --     normalImage = "gd_23.png",
            --     clickAction = function()
            --         LayerManager.addLayer({
            --             name = "more.StrategyLayer",
            --             cleanUp = false
            --         })
            --     end
            -- },
            -- 联系客服
            -- {
            --     normalImage = "gd_05.png",
            --     clickAction = function ()
            --         LayerManager.addLayer({
            --             name = "more.QuestionLayer",
            --             cleanUp = false,
            --         })
            --     end
            -- },
        }

        if ModuleInfoObj:moduleIsOpen(ModuleSub.eFriend, false) then
            table.insert(moreButtons,
            -- 好友
            {
                normalImage = "gd_03.png",
                moduleId = ModuleSub.eFriend,
                clickAction = function()
                    LayerManager.addLayer({
                        name = "more.FriendLayer",
                        -- cleanUp = false,
                    })
                end
            })
        end
        -- if ModuleInfoObj:moduleIsOpen(ModuleSub.eEnemy, false) then
        --     table.insert(moreButtons,
        --     -- 黑名单
        --     {
        --         normalImage = "gd_04.png",
        --         moduleId = ModuleSub.eEnemy,
        --         clickAction = function()
        --             LayerManager.addLayer({
        --                 name = "Chat.BlackListLayer",
        --                 -- cleanUp = false,
        --             })
        --         end
        --     })
        -- end
        if ModuleInfoObj:moduleIsOpen(ModuleSub.eEmail, false) then
            table.insert(moreButtons,
            -- 邮件
            {
                normalImage = "gd_08.png",
                moduleId = ModuleSub.eEmail,
                clickAction = function()
                    LayerManager.addLayer({
                        name = "more.MailLayer",
                        -- cleanUp = false,
                    })
                end
            })
        end
        if ModuleInfoObj:moduleIsOpen(ModuleSub.eLeaderBoard, false) then
            table.insert(moreButtons,
            -- 排行榜
            {
                normalImage = "gd_31.png",
                moduleId = ModuleSub.eLeaderBoard,
                clickAction = function()
                    LayerManager.addLayer({
                        name = "pvpinter.OverallRankMainLayer",
                        -- cleanUp = false,
                    })
                end
            })
        end
        if ModuleInfoObj:moduleIsOpen(ModuleSub.eDrama, false) then
            table.insert(moreButtons,
            -- 剧情场景
            {
                normalImage = "jq_44.png",
                moduleId = ModuleSub.eDrama,
                clickAction = function()
                    LayerManager.addLayer({
                        name = "more.DramaHomeLayer",
                    })
                    -- 结束引导
                    local _, _, eventID = Guide.manager:getGuideInfo()
                    if eventID == 10023 then
                        Guide.manager:nextStep(eventID, true)
                        Guide.manager:removeGuideLayer()
                    end
                end
            })
        end
        if ModuleInfoObj:moduleIsOpen(ModuleSub.eTitle, false) then
            table.insert(moreButtons,
            -- 名望称号
            {
                normalImage = "tb_271.png",
                moduleId = ModuleSub.eTitle,
                clickAction = function()
                    LayerManager.addLayer({
                        name = "more.PlayerTitleLayer",
                    })
                    -- 结束引导
                    local _, _, eventID = Guide.manager:getGuideInfo()
                    if eventID == 10043 then
                        Guide.manager:nextStep(eventID, true)
                        Guide.manager:removeGuideLayer()
                    end
                end
            })
        end
        if ModuleInfoObj:moduleIsOpen(ModuleSub.eIllustrated, false) then
        -- 群侠谱
        table.insert(moreButtons, {
            normalImage = "tb_233.png",
            moduleId = ModuleSub.eIllustrated,
            clickAction = function()
                LayerManager.addLayer({name = "hero.IllustrateHomeLayer"})

                -- 结束引导
                local _, _, eventID = Guide.manager:getGuideInfo()
                if eventID == 10003 then
                    Guide.manager:nextStep(eventID, true)
                    Guide.manager:removeGuideLayer()
                end
            end
        })
    end

        -- 创建更多按钮的背景框
        local parentPosX, parentPosY = self.mMoreBtn:getPosition()
        local tempSize = cc.size(220, 480)
        if #moreButtons > 8 then
            tempSize = cc.size(290, 480)
        end
        self.mMoreSprite = ui.newScale9Sprite("gd_01.png", tempSize)
        self.mMoreSprite:setPosition(parentPosX, parentPosY - 35)
        -- local moreBgFlippedX = (parentPosX + tempSize.width) > 640
        -- self.mMoreSprite:setFlippedX(false)
        if #moreButtons > 8 then
            self.mMoreSprite:setAnchorPoint(cc.p(0.5, 0))
        else
            self.mMoreSprite:setAnchorPoint(cc.p(0.73, 0))
        end
        -- 吞并下层事件
        ui.registerSwallowTouch({node=self.mMoreSprite, beganEvent = function (touch, event)
            if not ui.touchInNode(touch, self.mMoreSprite) then
                -- 点击做生意区域则收回弹框
                self:showMoreButtons()
            end
            return true
        end})

        -- 设置更多按钮的动画效果
        self.mMoreSprite:setScale(0.2)
        local actList = {
            cc.ScaleTo:create(0.25, 1.0),
            cc.CallFunc:create(function ()
                -- 继续引导
                local _, _, eventID = Guide.manager:getGuideInfo()
                if eventID == 10022 or eventID == 10042 or eventID == 10002 then
                    Guide.manager:nextStep(eventID)
                    self:executeGuide()
                end
            end)
        }
        self.mMoreSprite:runAction(cc.Sequence:create(actList))
        self.mBottomParent:addChild(self.mMoreSprite, -1)


        for k, btnInfo in ipairs(moreButtons) do
            btnInfo.position = cc.p(math.floor((k-1) / 4) * 95 + 53, 423 - ((k - 1) % 4) * 98)
            local tempBtn = ui.newButton(btnInfo)
            self.mMoreSprite:addChild(tempBtn)

            -- 有模块Id的按钮需要添加小红点的逻辑
            if btnInfo.moduleId then
                local function dealRedDotVisible(redDotSprite)
                    redDotSprite:setVisible(RedDotInfoObj:isValid(btnInfo.moduleId))
                end
                -- 事件名
                local eventNames = RedDotInfoObj:getEvents(btnInfo.moduleId)
                ui.createAutoBubble({parent = tempBtn, eventName = eventNames, refreshFunc = dealRedDotVisible})

                -- 保存用于新手引导
                self.mModuleButton[btnInfo.moduleId] = tempBtn
            end
        end
    end
end

-- 刷新上排活动按钮的倒计时信息
--[[
-- 参数
    needTimeBtnInfos: 需要显示倒计时信息的按钮信息列表
]]
function HomeLayer:refreshTopTime(needTimeBtnInfos)
    --dump(needTimeBtnInfos, "sadjasjd-----askdaskd00---")
    self.mTopParent:stopAllActions()
    if not needTimeBtnInfos or  #needTimeBtnInfos == 0 then
        return
    end

    local defaultString = "--:--:--"
    Utility.schedule(self.mTopParent, function()
        -- local miaoshaTime = PlayerAttrObj:getPlayerAttrByName("LimitTimeSeckill")
        -- print("~~~~~~~~~~~~", miaoshaTime)
        for index, btnInfo in pairs(needTimeBtnInfos) do
            local tempLabel, tempHintSprite = btnInfo.hintLabel, btnInfo.hintBgSprite
            if not tolua.isnull(tempLabel) then
                if btnInfo.moduleId == ModuleSub.eOnlineReward then
                    if OnlineRewardObj:allowReward() then
                        tempLabel:setString(TR("可领取"))
                        if tolua.isnull(btnInfo.buttonObj.actionObj) then
                            local array = {
                                cc.MoveBy:create(0.2, cc.p(0, 20)),
                                cc.MoveBy:create(0.3, cc.p(0, -20)),
                                cc.DelayTime:create(2),
                            }
                            local tempAction = cc.RepeatForever:create(cc.Sequence:create(array))
                            btnInfo.buttonObj.actionObj = btnInfo.buttonObj:runAction(tempAction)
                        end
                    else
                        tempLabel:setString(MqTime.formatAsHour(OnlineRewardObj:getNextCooledTime()))
                        if not tolua.isnull(btnInfo.buttonObj.actionObj) then
                            btnInfo.buttonObj:stopAction(btnInfo.buttonObj.actionObj)
                            btnInfo.buttonObj.actionObj = nil
                        end
                    end
                elseif btnInfo.moduleId == ModuleSub.eCommonHoliday32 then
                    local timeLeft = PlayerAttrObj:getPlayerAttrByName("TimedOnlineRewardCountdown")
                    if not timeLeft or timeLeft < 0 then
                        tempLabel:setString(TR("等待开启"))
                    elseif timeLeft == 0 then
                        tempLabel:setString(TR("可领取"))
                    else
                        tempLabel:setString(string.format("%s", MqTime.formatAsDay(timeLeft)))
                        timeLeft = timeLeft - 1
                        PlayerAttrObj:changeAttr({TimedOnlineRewardCountdown = timeLeft})
                    end
                elseif btnInfo.moduleId == ModuleSub.eExpedition then  
                    if ExpediGuaJiObj:getNextCooledTime() <= 0 then
                        tempLabel:setString(TR("可领取"))
                        if tolua.isnull(btnInfo.buttonObj.actionObj) then
                            local array = {
                                cc.MoveBy:create(0.2, cc.p(0, 20)),
                                cc.MoveBy:create(0.3, cc.p(0, -20)),
                                cc.DelayTime:create(2),
                            }
                            local tempAction = cc.RepeatForever:create(cc.Sequence:create(array))
                            btnInfo.buttonObj.actionObj = btnInfo.buttonObj:runAction(tempAction)
                        end
                    else
                        tempLabel:setString(MqTime.formatAsHour(ExpediGuaJiObj:getNextCooledTime()))
                        if not tolua.isnull(btnInfo.buttonObj.actionObj) then
                            btnInfo.buttonObj:stopAction(btnInfo.buttonObj.actionObj)
                            btnInfo.buttonObj.actionObj = nil
                        end
                    end
                elseif btnInfo.moduleId == ModuleSub.eTimeLimitTheBounty then
                    local currTime = Player:getCurrentTime()
                    local tempInfo = TimeLimitObj:getTimeLimitInfo()
                    local tempStr = defaultString
                    if tempInfo and tempInfo.EndDate and tempInfo.EndDate > 0 and currTime < tempInfo.EndDate then
                        tempStr = MqTime.formatAsHour(tempInfo.EndDate - currTime)
                    end
                    tempLabel:setString(tempStr)
                    tempLabel:setVisible((tempStr ~= defaultString))
                    tempHintSprite:setVisible((tempStr ~= defaultString))
                elseif btnInfo.moduleId == ModuleSub.eTrader then
                    local currTime = Player:getCurrentTime()
                    local traderTime = PlayerAttrObj:getPlayerAttrByName("TraderTime")
                    local tempStr = defaultString
                    if traderTime > 0 and traderTime > currTime then
                        tempStr = MqTime.formatAsHour(traderTime - currTime)
                    elseif RedDotInfoObj:isValid(btnInfo.moduleId) then
                        -- 如小红点存在则关闭
                        RedDotInfoObj:setSocketRedDotInfo{
                            [tostring(ModuleSub.eTrader)] = {Default=false},
                        }
                        self:refreshTopBtnPos()
                    end
                    tempLabel:setString(tempStr)
                    tempLabel:setVisible((tempStr ~= defaultString))
                    tempHintSprite:setVisible((tempStr ~= defaultString))
                elseif btnInfo.moduleId == ModuleSub.eTimedMiaoSha then
                    local currTime = Player:getCurrentTime()
                    local miaoshaTime = PlayerAttrObj:getPlayerAttrByName("LimitTimeSeckill")
                    print("~~~~~~~~~~~~", miaoshaTime)
                end
            end
        end
    end, 1)
end

--更新上排活动按钮的位置
function HomeLayer:refreshTopBtnPos()
    local needTimeBtnInfos = {}
    local rowCount, btnIndex = 6, 0
    local cellSize = cc.size(640 / rowCount, 92)
    local startPosX, startPosY = cellSize.width / 2, 980
    for _, btnInfo in ipairs(self.mTopBtnInfos) do
        local needVisible = self:moduleAllowVisible(btnInfo)
        
        local tempBtn = btnInfo.buttonObj
        tempBtn:setVisible(needVisible)

        -- 整理需要显示倒计时相关信息
        if needVisible then
            if btnInfo.moduleId == ModuleSub.eOnlineReward or  -- 在线奖励
                btnInfo.moduleId == ModuleSub.eTimeLimitTheBounty or
                btnInfo.moduleId == ModuleSub.eTrader or  -- 限时赏金
                btnInfo.moduleId == ModuleSub.eTimedMiaoSha or --限时秒杀
                btnInfo.moduleId == ModuleSub.eCommonHoliday32 or --限时在线奖励
                btnInfo.moduleId == ModuleSub.eExpedition then --光明顶挂机

                if not tolua.isnull(tempBtn.actionObj) then
                    tempBtn:stopAction(tempBtn.actionObj)
                    tempBtn.actionObj = nil
                end
                table.insert(needTimeBtnInfos, btnInfo)
            end

            -- 重设特惠购买图标
            if btnInfo.moduleId == ModuleSub.eCommonHoliday28 then
            	local activityInfo = ActivityObj:getActivityItem(btnInfo.moduleId)[1]
            	if activityInfo.ExtraInfo.Icon and activityInfo.ExtraInfo.Icon ~= "" then
	            	tempBtn:loadTextures(activityInfo.ExtraInfo.Icon, activityInfo.ExtraInfo.Icon)
	            end
            end

            btnIndex = btnIndex + 1
            local tempPosX = startPosX + math.mod((btnIndex - 1), rowCount) * cellSize.width
            local tempPosY = startPosY - math.floor((btnIndex - 1) / rowCount) * cellSize.height
            tempBtn:setPosition(tempPosX, tempPosY)

        end
    end

    -- 刷新上排活动按钮的倒计时信息
    self:refreshTopTime(needTimeBtnInfos)
end

-- 判断模块是否可以显示
function HomeLayer:moduleAllowVisible(btnInfo)
    if btnInfo.isWeChatBag then
        local ret = false
        local redBagInfo = PlayerAttrObj:getRedBagInfo()
        for key, value in pairs(redBagInfo or {}) do
            if value == true then
                ret = true
                break
            end
        end
        return ret
    end

    local moduleId = btnInfo.moduleId
    if not moduleId or moduleId == ModuleSub.eExtraActivity then  -- 模块为空或部分模块，一直返回true
        return true
    end
    if not ModuleInfoObj:moduleIsOpenInServer(moduleId) or not ModuleInfoObj:modulePlayerIsOpen(moduleId, false) then
        return false
    end

    -- 通过模块ID开关的活动
    if moduleId == ModuleSub.eAnniversary or moduleId == ModuleSub.eExtraActivityWeChat then
        return true
    end
    -- 代理侠客
    if moduleId == ModuleSub.eGuaji then
        return true
    end

    -- 玩家属性信息
    local playerInfo = PlayerAttrObj:getPlayerInfo()
    -- 该模块的小红点信息
    local redDotData = RedDotInfoObj:isValid(moduleId)

    --成就奖励
    if moduleId == ModuleSub.eOpenActivity then
        return playerInfo.HasDrawSuccessReward and playerInfo.HasDrawSuccessReward >= 1
    end

    -- 开服比拼
    if moduleId == ModuleSub.eOpenContest then
        -- 开服比拼
        return playerInfo.OpencontestState == true
    end

    -- 限时赏金
    if moduleId == ModuleSub.eTimeLimitTheBounty then
        local tempStatus = TimeLimitObj:getRewardStatus()
        if tempStatus == Enums.TimeLimitStatus.eGetSvrData then
            -- 请求限时赏金信息
            TimeLimitObj:requestGetInfo()
        end

        return tempStatus ~= Enums.TimeLimitStatus.eNoneInfo
    end

    --七日大奖
    if moduleId == ModuleSub.eSuccessReward then
        -- if playerInfo.HasDrawSuccessReward == 0 then
        --     local guideID, ordinal, eventID = Guide.manager:getGuideInfo(true, true)
        --     if eventID and (eventID == 2201 or eventID == 2202) then
        --         return false
        --     else
        --         return true
        --     end
        -- end
        return playerInfo.HasDrawSuccessReward == 0
    end

    --充值
    if moduleId == ModuleSub.eCharge then
        return playerInfo.IsZhiZunFirstCharge ~= true
    end

    --首冲
    if moduleId == ModuleSub.eFirstRecharge then
        return playerInfo.IsZhiZunFirstCharge == true
    end

    --VIP贵宾
    if moduleId ==  ModuleSub.eSVIP then
        return playerInfo.SvipState == 1 or playerInfo.SvipState == 2
    end

    --守卫襄阳
    if moduleId ==  ModuleSub.eTeambattleInvite then
        local tempStatus = PlayerAttrObj:getPlayerAttrByName("TeamBattleStatus")
        return tempStatus and tempStatus ~= Enums.TeamBattleStatus.eNone
    end

    -- 限时活动、节日活动、通用活动
    if moduleId ==  ModuleSub.eTimedActivity or
        moduleId == ModuleSub.eChristmasActivity or
        moduleId == ModuleSub.eCommonHoliday then
        return ActivityObj:haveMainActivity(moduleId)
    end

    -- "大主宰"
    if moduleId == ModuleSub.eWhosTheGod then
        return true
    end

    -- 在线奖励
    if moduleId == ModuleSub.eOnlineReward then
        local tempStatus = OnlineRewardObj:getRewardStatus()
        return tempStatus == Enums.OnlineRewardStatus.eHaveInfo
    end

    -- 光明顶挂机
    if moduleId == ModuleSub.eExpedition then
        local isGuji = ExpediGuaJiObj:getIsGuaJi( )
        return isGuji
    end

    -- 超级QQ会员特权
    if moduleId == ModuleSub.ePrivilege then
        local loginType = PlayerAttrObj:getPlayerAttrByName("LoginType")
        -- QQ登录返回true
        return loginType == 1 or loginType == 2
    end

    -- 邀请有礼
    if moduleId == ModuleSub.eInvite then
        return true
    end

    -- 会员中心
    if moduleId == ModuleSub.eVIPcenter then
        return true
    end

    -- 活动配置是否开放
    if moduleId == ModuleSub.eTimedMiaoSha or          -- 限时秒杀
        moduleId == ModuleSub.eTimedMountExchange or   -- 限时兑换船只
        moduleId == ModuleSub.eTimedHolidayDrop or     -- 限时掉落
        moduleId == ModuleSub.eTimedPuzzle or          -- 拼图
        moduleId == ModuleSub.eTimedZhengdianMiaosha or -- 整点秒杀
        moduleId == ModuleSub.eChristmasActivity17 or -- 限时美食盛宴
        moduleId == ModuleSub.eTimedChallenge or       -- 挑战活动
        moduleId == ModuleSub.eTimedLuckyTurntable or   -- 转盘活动
        moduleId == ModuleSub.eCommonHoliday29 or       -- 金猪赛跑
        moduleId == ModuleSub.eCommonHoliday30 or       -- 幻化置换
        moduleId == ModuleSub.eCommonHoliday15 or        -- 限时折扣-礼包套餐
        moduleId == ModuleSub.eCommonHoliday16 or        -- 神雕送礼
        moduleId == ModuleSub.eCommonHoliday17 or        -- 拼图大赛
        moduleId == ModuleSub.eCommonHoliday18 or        -- 祈愿树
        moduleId == ModuleSub.eCommonHoliday19 or        -- 孔明灯
        moduleId == ModuleSub.eCommonHoliday21 or        -- 猜灯谜
        moduleId == ModuleSub.eTimedvegetables or        -- 钟菜
        moduleId == ModuleSub.eTimedFiveFu or        -- 集五福
        moduleId == ModuleSub.eTimedSupreme or        -- 至尊宝藏
        moduleId == ModuleSub.eTimedDigTreasure or     -- 挖宝活动
        moduleId == ModuleSub.eTimedShare or          -- 分享奖励
        moduleId == ModuleSub.eTimedChargeRebate or   -- 充值返利
        moduleId == ModuleSub.eTimedShoottarget or     -- 射靶活动
        moduleId == ModuleSub.eTimedBlessingTask or     -- 祝福任务活动
        moduleId == ModuleSub.eDice or               -- 寻宝
        moduleId == ModuleSub.eCommonHoliday25 or          -- 限时-限时签到
        moduleId == ModuleSub.eTimedChargeRebate or          -- 充值返利
        moduleId == ModuleSub.eCommonHoliday26 or        -- 金龙宝藏
        moduleId == ModuleSub.eCommonHoliday27 or        -- 神兵谷
        moduleId == ModuleSub.eCommonHoliday31 or        -- 江湖秘藏
        moduleId == ModuleSub.eCommonHoliday32 or        -- 限时在线奖励
        moduleId == ModuleSub.eCommonHoliday28 then        -- 限时特惠
        
        return ActivityObj:getActivityItem(moduleId) and true or false
    end

    -- 其它按钮都返回小红点信息
    return redDotData
end

-- ========================== 新手引导 ===========================

function HomeLayer:onEnterTransitionFinish()
    local haveGuide = self:executeGuide()

    -- 如果当前没有新手引导
    if not haveGuide then
        -- 自动打开指定模块
        if self.mParams.defaultModule then
            for k,v in pairs(self.mModuleButton) do
                print(self.mParams.defaultModule , k, "self.mParams.defaultModule == v.moduleId")
                if self.mParams.defaultModule == k then
                    v.mClickAction()
                    return
                end
            end
        end
        -- 打开一次购买礼包提示
        local currLv = PlayerAttrObj:getPlayerAttrByName("Lv")
        if not LocalData:getGameDataValue("VIP6BuyGiftNotice") and currLv >= 12 then
            LayerManager.addLayer({name = "Guide.SpecialVipLayer", data = {popType = 2},
                cleanUp = false, zOrder = Enums.ZOrderType.ePopLayer})
            LocalData:saveGameDataValue("VIP6BuyGiftNotice", true)
        end
        -- 打开一次公告
        local playerId = PlayerAttrObj:getPlayerAttrByName("PlayerId")
        if not ReEnterPlayer[playerId] and device.platform ~= "mac" then
            LayerManager.addLayer({
                name = "more.NoticeLayer",
                cleanUp = false,
                zOrder = Enums.ZOrderType.eAnnounce,
            })
            ReEnterPlayer[playerId] = true
        end
    end
end

function HomeLayer:executeGuide()
    local next_ = handler(self, self.executeGuide)

    -- 检查战斗后剧情，有必要时恢复
    --[[当前引导和战斗后引导可能并不匹配，导致无法触发
    local afterBattleGuide = Guide.manager:getGuideInfoByType(GuideTriggerType.eBattleNodeOrdinalEnd)
    local guideStep = GuideObj:getGuideInfo()
    for _, id in pairs(afterBattleGuide) do
        local ord = guideStep[id]
        if ord and ord == 1 then
            local eID = Guide.manager:getGuideEventID(id, ord)
            Guide.helper:executeGuide({
                [eID] = next_,
            })
            return
        end
    end--]]

    -- 如果第一步引导未触发，则恢复引导
    local guideID, ordinal, eventID = Guide.manager:getGuideInfo()
    local newEventID = eventID
    if guideID and ordinal == 1 then
        newEventID = Guide.config.bootCorrectTable[eventID]
        if newEventID then
            Guide.manager:saveGuideStep(guideID, nil, newEventID)
        end
    end
    -- 12级恢复引导时，继续弹送VIP
    if newEventID and newEventID == 9002 then
        LayerManager.addLayer({name = "Guide.SpecialVipLayer", data = {popType = 1}, cleanUp = false, zOrder = Enums.ZOrderType.eAnnounce})
    end

    -- 25级 选择势力
    if newEventID and newEventID == 902 then
        LayerManager.addLayer({
                name = "jianghuKill.JianghuKillLetter",
                cleanUp = false,
            })
    end

    local inGuide = Guide.helper:executeGuide({
        -- 对话
        [10100] = {nextStep = function ()
            -- 此处弹充值提示，高于新手引导
            LayerManager.addLayer({name = "Guide.SpecialVipLayer", data = {}, cleanUp = false, zOrder = Enums.ZOrderType.eAnnounce})
            -- 继续执行新手引导
            self:executeGuide()
        end},
        -- 指向副本
        [10200] = {clickNode = self.mCommonLayer_:getNavBtnObj(Enums.MainNav.eBattle)},
        -- 培养升10次之后，引导进入江湖
        [10304] = {clickNode = self.mCommonLayer_:getNavBtnObj(Enums.MainNav.eBattle)},
        -- 培养突破之后，对话进副本
        [10311] = {nextStep = next_},
        [10312] = {clickNode = self.mCommonLayer_:getNavBtnObj(Enums.MainNav.eBattle)},
        -- 闯荡江湖开启
        [11001] = {clickNode = self.mCommonLayer_:getNavBtnObj(Enums.MainNav.ePractice)},
        -- 武林谱开启，引导进江湖
        [108] = {clickNode = self.mCommonLayer_:getNavBtnObj(Enums.MainNav.eBattle)},
        -- 拜师学艺开启，引导进历练
        [10805] = {nextStep = next_},
        [109] = {clickNode = self.mCommonLayer_:getNavBtnObj(Enums.MainNav.ePractice)},
        -- 行侠仗义，引导进挑战
        [113051] = {clickNode = self.mCommonLayer_:getNavBtnObj(Enums.MainNav.eChallenge)},
        -- 神兵对话
        [112] = {nextStep = next_},
        -- 新增一个武器图纸
        [112021] = {nextStep = function(eventID, isGot)
            if isGot then
                -- 领取服务器物品成功执行下一步
                Guide.manager:nextStep(112021)
            end
            self:executeGuide()
        end},
        [11201] = {clickNode = self.mCommonLayer_:getNavBtnObj(Enums.MainNav.eFormation)},
        [11209] = {clickNode = self.mCommonLayer_:getNavBtnObj(Enums.MainNav.eFormation)},
        -- 神兵升级
        [113] = {clickNode = self.mCommonLayer_:getNavBtnObj(Enums.MainNav.eFormation)},
        -- 江湖悬赏
        [11501] = {clickNode = self.mCommonLayer_:getNavBtnObj(Enums.MainNav.ePractice)},
        -- 自动战斗(挂机)
        [1201] = {clickNode = self.mCommonLayer_:getNavBtnObj(Enums.MainNav.eBattle)},
        -- 装备锻造
        [11801] = {clickNode = self.mCommonLayer_:getNavBtnObj(Enums.MainNav.eFormation)},
        -- 斗酒功能
        [112101] = {clickNode = self.mCommonLayer_:getNavBtnObj(Enums.MainNav.ePractice)},
        -- 华山论剑
        [11601] = {clickNode = self.mCommonLayer_:getNavBtnObj(Enums.MainNav.eChallenge)},
        -- 比武招亲
        [115101] = {clickNode = self.mCommonLayer_:getNavBtnObj(Enums.MainNav.eChallenge)},
        -- 武林大会
        [11701] = {clickNode = self.mCommonLayer_:getNavBtnObj(Enums.MainNav.eChallenge)},
        -- 守卫襄阳，对话
        [119] = {nextStep = next_},
        [11901] = {clickNode = self.mCommonLayer_:getNavBtnObj(Enums.MainNav.ePractice)},
        -- 每日任务
        [802] = {clickNode = self.mModuleButton[ModuleSub.eDaliyTask]},
        -- 帮派开启
        [905] = {clickNode = self.mModuleButton[ModuleSub.eGuild]},
        -- 指向守卫光明顶
        [402] = {clickNode = self.mCommonLayer_:getNavBtnObj(Enums.MainNav.eChallenge)},
        -- 指向武林争霸
        [5002] = {clickNode = self.mCommonLayer_:getNavBtnObj(Enums.MainNav.eChallenge)},
        -- 指向决战桃花岛
        [6002] = {clickNode = self.mCommonLayer_:getNavBtnObj(Enums.MainNav.eChallenge)},
        -- 指向经脉
        [7002] = {clickNode = self.mCommonLayer_:getNavBtnObj(Enums.MainNav.eFormation)},
        -- 指向门派
        [8002] = {clickNode = self.mModuleButton[ModuleSub.eSect]},
        -- 指向大侠之路
        [9002] = {clickNode = ChatBtnLayer.roadBtn},
        [9005] = {clickNode = ChatBtnLayer.roadBtn},
        -- 指向群侠谱
        [10002] = {clickNode = self.mMoreBtn},
        [10003] = {clickNode = self.mModuleButton[ModuleSub.eIllustrated]},
        -- 指向练气
        [10017] = {clickNode = self.mPracticeBtn},
        [10012] = {clickNode = self.mModuleButton[ModuleSub.eZhenyuan]},
        -- 指向炼丹
        [10018] = {clickNode = self.mPracticeBtn},
        [10015] = {clickNode = self.mModuleButton[ModuleSub.eMedicine]},
        -- 指向侠影戏
        [10022] = {clickNode = self.mMoreBtn},
        [10023] = {clickNode = self.mModuleButton[ModuleSub.eDrama]},
        -- 指向绝情谷
        [10032] = {clickNode = self.mCommonLayer_:getNavBtnObj(Enums.MainNav.eChallenge)},
        -- 名望
        [10042] = {clickNode = self.mMoreBtn},
        [10043] = {clickNode = self.mModuleButton[ModuleSub.eTitle]},
        -- 江湖杀开启
        [10052] = {clickNode = self.mModuleButton[ModuleSub.eJiangHuKill]},
        -- 珍兽
        [10062] = {nextStep = function(eventID, isGot)
            if isGot then
                -- 领取服务器物品成功执行下一步
                Guide.manager:nextStep(10062)
            end
            self:executeGuide()
        end},
        [10063] = {clickNode = self.mModuleButton[ModuleSub.eZhenshou]},
        [10067] = {clickNode = self.mPracticeBtn},
        [10068] = {clickNode = self.mModuleButton[ModuleSub.eZhenshouLaoyu]},
    }, nil, true)

    if not inGuide then
        -- 检查所有功能开启的eventID
        for k in pairs(Guide.config.moduleOpenConfig) do
            if Guide.helper:executeGuide({
                [k] = {},
            }) then
                return true
            end
        end
    end

    return inGuide
end

return HomeLayer
