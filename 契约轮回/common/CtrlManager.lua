--
-- Author: LaoY
-- Date: 2018-06-28 20:47:35
--

local function add(ctrl)
    Constant.GlobalControll[#Constant.GlobalControll + 1] = ctrl
end
add("game.system.PreloadManager")
add("game.loading.loadingCtrl") --loading
add("game.system.SoundManager")
add("base.NetManager")
add('game.scene.SceneControler')
add('game.bag.BagController')
add("game.login.LoginController")

add('platform.TDManager')
add('platform.OssManager')
add('platform.AvatarManager')
add('platform.UIAdaptManager')

add("game.system.ShaderManager")

add("game.system.SystemTipManager")
add('game.system.opentip.OpenTipController')

add('game.roleinfo.RoleInfoController')
add('game.main.MainController')
add('game.fight.FightController')
add('game.fight.SkillController')
add('game.chat.ChatController')
add('game.goods.GoodsController')
add('game.goods.GoodsTipController')
add('game.equip.EquipController')
add('game.task.TaskController')
add('game.mail.MailController')
add('game.mount.MountCtrl');
add('game.combine.CombineController')
add('game.dungeon.DungeonCtrl')
add('game.skill.SkillUIController')
add('game.team.TeamController')
add('game.shop.ShopController')
add("game.blood.BloodCtrl");
add("game.wake.WakeController");
add("game.vip.VipController");
add("game.search_treasure.SearchTreasureController")
add("game.search_treasure.YYSmallRController")
add("game.faction.FactionController")
add("game.faction.FactionSkillController")
add("game.faction.FactionWareController")
add("game.magiccard.MagicCardCtrl");
add("game.title.TitleController");
add("game.magictower_treasure.MagictowerTreasureController");
add("game.mail.FriendController")
add("game.fashion.FashionController")
add("game.pet.PetController") --宠物
add("game.market.MarketController")
add("game.book.BookController")
add('game.activity.ActivityController')
add("game.beast.BeastCtrl");
add("game.operate.OperateController")
add("game.daily.DailyController")
add("game.daily.WeeklyController")
add("game.rank.RankController")
add("game.guide.GuideController")
add("game.welfare.WelfareController") --福利模块
add("game.notice.NoticeController") --公告板
add("game.factionEscort.FactionEscortController")
add("game.realname.RealNameController")
add("game.candy.CandyController")
add("game.selectserver.SelectServerController")
add("game.setting.SettingController")
add("game.factionBattle.FactionBattleController") --公会战
add("game.hardware.HardwareController") --硬件相关
add("game.sevenDay.SevenDayController") --七日登录
add("game.openHigh.OpenHighController") --开服狂欢
add("game.tips.TipsCtrl") --tips相关
add("game.dailyRecharge.DailyRechargeController") --每日累充
add("game.achieve.AchieveController") --成就

add("game.operate.sevenDayActive.SevenDayActiveController") --七天活动
add("game.firstPay.FirstPayController") --首充
add("game.secPay.SecPayController") --充值活动
add("game.guildhouse.GuildHouseController") --帮会驻地
add("game.freeGift.FreeGiftController") --0元礼包
add("common.model.UIModelManager") --UI模型管理
add("game.wanted.WantedController") --悬赏令

add("game.arena.ArenaController") --竞技场

add("game.factionPacket.FPacketController") --帮派红包



add("game.marry.MarryController")  --结婚

add("game.peakArena.PeakArenaController") --巅峰竞技

add("game.warrior.WarriorController") --勇者祭坛

add("game.baby.BabyController") --子女系统

add("game.nation.NationController") --国庆活动
add("game.casthouse.CasthouseController")    --铸造小屋

add("game.god.GodController") --神灵系统

add("game.godcele.GodCelebrationController") --神灵活动

add("game.proba.ProbaTipController")
add("game.stigmas.StigmasController") --圣痕秘境

add("game.stigmata.StigmataController") --圣痕系统--


add("game.banner.BannerController") --游戏横幅


add("game.limittower.LimitTowerController") --限时爬塔

add("game.vipfree.VipFreeController")

add("game.quickBuy.QuickBuyController")  --快捷购买


add("game.compete.CompeteController")  --钻石擂台

add("game.illustration.illustrationController")  --图鉴系统

add("game.childAct.ChildActCtrl")  --子女冲榜

add("game.race.RaceController")  --机甲竞速

add("game.dungeon.timeboss.TimeBossController")

add("game.illInvest.IllInvestCtr") -- 投资活动

add("game.dial.DialController")             --转盘（运营活动）
add("game.machinearmor.MachineArmorController") --机甲系统
--add("game.act_recharge.ActRechargeController")             --充值活动
add("game.siegewar.SiegewarController")
add("game.gundam_act.GundamActController")        --机甲来袭

add("game.otherwelfare.OtherWelfareController")  --点赞 分享 绑定奖励


add("game.dungeon.thronestar.ThroneStarController") --星之王座


add("game.richman.RichManController") --大富豪

add("game.faction.factionSerWar.FactionSerWarController") --跨服公会战

add("game.luckywheel.LuckyWheelController")  --幸运转盘
add("game.worthWelfare.WorthWelfareController") --超值福利

--VipSmallController
add("game.vipSmall.VipSmallController")

--神器系统
add("game.artifact.ArtifactController")


--图腾
add("game.toems.ToemsController")

--翻牌好礼
add("game.flopGift.FlopGiftController")


require "game.bag.BaseBagModel"

CtrlManager = CtrlManager or class("CtrlManager")

function CtrlManager:ctor()
    CtrlManager.Instance = self
    -- 通用控件
    PreloadManager()

    ShaderManager()

    -- 系统模块 飘窗提示 传闻 获取物品
    SystemTipManager()

    -- 网络模块
    NetManager()

    UIAdaptManager()
    -- 登录模块
    LoginController()
    -- 场景
    SceneControler()

    -- 信息界面
    RoleInfoController()

    -- 第三方数据收集 初始化要再RoleInfoController 后面
    TDManager()

    --oss(远端存储文件相关)
    OssManager()

    -- 头像管理
    AvatarManager()

    -- 主场景大界面
    MainController()

    --技能、战斗
    FightController()
    SkillController()

    --背包
    BagController()

    --装备操作
    EquipController()
    --物品操作
    GoodsController()
    GoodsTipController()

    --任务
    TaskController()

    ChatController()

    MailController()
    --坐骑
    MountCtrl()

    CombineController()

    DungeonCtrl();

    --技能界面
    SkillUIController()

    --队伍
    TeamController()

    --商城界面
    ShopController()

    --模块开放界面
    OpenTipController()

    BloodCtrl()

    WakeController()

    --Vip界面
    VipController()

    --寻宝
    SearchTreasureController()

    --小R活动
    YYSmallRController()

    --帮派
    FactionController()
    FactionWareController()

    --魔法卡
    MagicCardCtrl();

    --称号界面
    TitleController()

    --魔法塔寻宝
    MagictowerTreasureController()

    --好友
    FriendController()

    --时装
    FashionController()
    --宠物
    PetController()
    MarketController()

    -- 玩法活动
    ActivityController()

    -- 运营活动
    OperateController()

    --天书
    BookController()
    BeastCtrl();

    --日常
    DailyController()
    WeeklyController()

    ---排行榜
    RankController()

    --新手指引
    GuideController()

    --福利模块
    WelfareController()

    --公告板
    NoticeController()
    --护送
    FactionEscortController()
    ---防沉迷
    RealNameController()

    --糖果屋
    CandyController()
    --选择服务器
    SelectServerController()
    --设置
    SettingController()

    --公会战战斗UI
    FactionBattleController()

    soundMgr = SoundManager.GetInstance()
    ---硬件相关
    HardwareController()
    --七日登录
    SevenDayController();

    LoadingCtrl();

    TipsCtrl();

    --每日累充
    DailyRechargeController()

    --成就
    AchieveController()



    --七天活动
    SevenDayActiveController()

    --首充
    FirstPayController()
    --充值活动
    SecPayController()

    --帮会驻地
    GuildHouseController()

    --0元礼包
    FreeGiftController()

    UIModelManager()

    --悬赏令
    WantedController()

    --帮派红包
    FPacketController()



    --竞技场
    ArenaController()


    --结婚
    MarryController()

    OpenHighController()

    --巅峰竞技
    PeakArenaController()

    --勇者祭坛
    WarriorController()

    --子女系统
    BabyController()

    --国庆活动
    NationController()
    --神灵系统
    GodController()

    --神灵活动
    GodCelebrationController()

    CasthouseController()

    ProbaTipController()
    --圣痕秘境
    StigmasController()

    --圣痕系统
    StigmataController()


    --游戏横幅
    BannerController()

    --限时爬塔
    LimitTowerController()

    --连充送vip
    VipFreeController()

    --快捷购买
    QuickBuyController()



    --钻石擂台
    CompeteController()

    --图鉴系统
    illustrationController()

    --机甲竞速
    RaceController()

    TimeBossController()

    IllInvestCtr()

    --转盘(运营活动)
    DialController()
    --充值活动
    --ActRechargeController()

    --机甲系统
    MachineArmorController()
    --  子女冲榜
    ChildActCtrl()
    --夺城战
    SiegewarController()
    --机甲来袭
    GundamActController()

    OtherWelfareController()

    --星之王座
    ThroneStarController()

    --大富豪
    RichManController()

    --跨服公会战
    FactionSerWarController()

    --幸运转盘
    LuckyWheelController()

    --超值福利
    WorthWelfareController()

    --小贵族
    VipSmallController()

    --神器系统
    ArtifactController()

    --图腾
    ToemsController()

    --翻牌好礼
    FlopGiftController()
end

function CtrlManager:dctor()
end

CtrlManager.IsInit = false
function CtrlManager.Start()
    local time_id
    local len = #Constant.GlobalControll
    local curIndex = 1
    local frameCount = 8

    local function step()
        local startIndex = curIndex
        local endIndex = startIndex + frameCount - 1
        endIndex = endIndex > len and len or endIndex
        for i = startIndex, endIndex do
            require(Constant.GlobalControll[i])
        end
        curIndex = endIndex + 1
        if endIndex >= len then
            if time_id then
                GlobalSchedule:Stop(time_id)
            end
            CtrlManager()

            --功能跳转链接
            require('Common.LinkConfig')

            GlobalEvent:Brocast(EventName.HotUpdateSuccess)

            CtrlManager.IsInit = true

            if AppConfig.Debug and ProfilerDebug then
                CtrlManager.StartProfiler()
            end
        end
    end
    time_id = GlobalSchedule:Start(step, 0)
    step()
end

ProfilerDebug = false
if ProfilerDebug then
    Profiler = require("tolua/UnityEngine/Profiler")
end
function CtrlManager.StartProfiler()
    Profiler:start()
end

function CtrlManager:GetInstance()
    if not CtrlManager.Instance then
        CtrlManager()
    end
    return CtrlManager.Instance
end
