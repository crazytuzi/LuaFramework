 ------------------------------
-- 窗口ID配置
-- ------------------------------
WindowConfig = WindowConfig or {}

-------------------------------------------------------------------------------
-- id命名规则: 前三位按照相应功能的协议前三位，后两位是具体的序号，方便分类
--------------------------------------------------------------------------------
WindowConfig.WinID = {
    ui_gm = 99001, --GM

    createrolewindow = 10000,--创建角色界面
    autoaddpoint = 10001,--角色智能属性加点设置
    classeschangewindow = 10002, --职业转换
    classeschangesuccesswindow = 10003, --职业转换成功

    worldmapwindow = 10100,--世界地图

    taskwindow = 10200,--任务主面板
    taskdrama = 10201, -- 剧情任务
    taskstar = 10202,--星级任务界面
    practice = 10203,--历练任务
    biblemain = 10204,--宝典
    automodeselectwindow = 10205,-- 历练自动模式选择 -- by 嘉俊 2017/8/28 17:24

    achievement = 10250, --成就
    newAchievement = 10251, --新增成就
    achievementshopwindow = 10252, --成就兑换

    backpack = 10300,--背包主面板
    addpoint = 10301,--背包属性加点面板
    addpointPet = 10302,--宠物属性加点面板
    backpack_expand = 10303, -- 背包扩展界面
    selectitem = 10304,--选择物品面板
    info_window = 10305,    --信息窗口
    info_honor_window = 10306,    --信息称号窗口
    addpointChild = 10307, -- 子女加点

    chatwindow = 10400,--聊天主面板
    chatmini = 10401,--聊天小面板
    chatshow = 10402,--聊天道具表情选择面板
    email_win = 10403, --邮件详细内容
    chat_voice = 10404, --语音提示
    face_merge = 10405, -- 表情合成

    pet = 10500,--宠物主面板
    pet_learnskill = 10501,--宠物学习技能面板
    petpotentialwindow = 10502,--宠物潜能面板
    petgemwindow = 10503,--宠物宝石面板zp
    petgetskillwindow = 10504,--宠物抽取技能面板
    petshopwindow = 10505,--宠物商店
    pet_attribute_add = 10506,--宠物加点
    pet_exchange = 10507,--神兽兑换
    pet_feed = 10508,--宠物喂养
    pet_upgrade = 10509, --宠物进阶
    petquickshow = 10510, --宠物查看
    petgemwash = 10511, --宠物符石技能重置
    petreceive = 10512, --宠物领取
    petselect = 10513, --选择宠物

    recommendskillpanel = 10514, -- 宠物技能推荐
    newpetwashskillwindow = 10515, -- 宠物洗髓必出全部技能提醒
    petartificewindow = 10516, -- 宠物炼化
    petbreakskillview = 10517, -- 宠物突破新技能提示
    petbreakwindow = 10518, -- 宠物突破
    pet_child_upgrade = 10519, -- 子女进阶
    pet_wash = 10520, --宠物洗髓
    petchildgemwindow = 10521, -- 子女护符
    pet_child_feed = 10522,--子女喂养
    pet_change_telnet = 10523, -- 子女切换天赋
    pet_skin_window = 10524, -- 宠物皮肤
    petfusewindow = 10525, -- 宠物合成
    petspiritwindow = 10526, -- 宠物附灵界面
    petgenselect = 10527, -- 宠物选择超级护符窗口
    ChildSkinWindow = 10528, --子女皮肤窗口

    eqmadvance = 10600,--人物装备提升面板
    eqmputin = 10601,--宝石放入
    eqmupgrade = 10602,--宝石升级
    eqmaddlucky = 10603,--放入幸运石
    eqmfuse = 10604,--宝石合成
    eqmtrans = 10605, --装备转换
    gemchangewindow = 10606, --宝石转换
    talismanchangewindow = 10607, --宝石转换
    eqmtappointeffectwinrans = 10608, -- 洗练指定特效

    skill = 10800,--技能主面板
    skill_life_produce = 10801, --生活技能栽培面板
    skill_life_activity = 10802, --获得活力必做活动面板
    skill_use_energy = 10803, --活力值使用
    skilltalentwindow = 10804, --新天赋
    marryskillwindow = 10805, -- 激活伴侣技能
    newmarryskillwindow = 10806, -- 新伴侣技能

    guardian = 10900,--守护主面板
    guardianequip = 10901,--守护装备面板
    guardianequiprecsuccesswindow = 10902,--招募守护成功界面
    guardianWakeupLook = 10903, --获得新的守护觉醒外观

    guildwindow = 11100,--帮派查找
    guildcreatewindow = 11101,--帮派创建
    guildinfowindow = 11102,--帮派信息
    guildpositionwindow = 11103,--帮派设置职位
    guildbuildmanagewindow = 11104,--帮派建筑管理
    guildchangepurposewindow = 11106,--帮派改宗旨
    guildstorewindow = 11108,--帮派货栈
    guildchangesignaturewindow = 11110,--公会成员改个性签名
    guild_apply_list_win = 11111, --公会申请列表界面
    guild_pray_win = 11112, --公会祈祷界面
    guild_red_bag_win = 11113, --公会红包界面
    guild_red_bag_unopen_win = 11114, --公会红包未开启界面
    guild_shenshou_win = 11115, --公会神兽界面
    guild_soldier_win = 11116, --公会佣兵界面
    guild_soldier_look_win = 11117, --公会佣兵查看界面
    guild_change_shenshou_win = 11118, --更改神兽名字面板
    guild_totem_win = 11119, --公会图腾
    guild_question_win = 11120, --公会温泉答题面板
    guild_question_enter_win = 11121, --公会温泉答题入口面板
    guild_recommend_win = 11122, --公会温泉答题入口面板
    guild_find_win = 11123, --公会查找面板
    guild_mem_manage_win = 11124, --公会成员管理面板
    guild_red_bag_set_win = 11125, --公会红包设置面吧
    guild_red_bag_money_win = 11126, --公会红包选钱面板
    guild_merge_tips_win = 11127, --公会合并提示界面
    guild_merge_win = 11128, --公会合并面板
    guild_npc_exchange_win = 11129, --公会npc兑换面板
    guild_healthy_win = 11130, --公会合并面板
    guild_fight_window = 11131, --公会战信息界面
    guild_fight_settime_window = 11132, --公会战宝藏开启时间设定界面
    guild_league_window = 11133, --冠军联赛界面
    guild_pray_window = 11134, --公会祈福界面

    guild_siege_castle_window = 11135, -- 冠军联赛城堡地图窗口
    guild_siege_settle = 11136,         -- 新冠军联赛结算面板
    guild_pray_speed_window = 11138, --公会祈福加速界面
    guild_restriction_select_window = 11139, -- 公会加速额度选择界面

    home_window = 11200,--家园窗口
    homepettrainview = 11201,--家园宠物训练窗口
    createhomewindow = 11202,--创建家园窗口
    gethome = 11203,--获得新家园窗口
    visithomewindow = 11204, -- 拜访家园
    magicbeenpanel = 11205, -- 培育魔豆
    invitemagicbeenwindow = 11206, -- 魔豆邀请
    furniturelistwindow = 11207, -- 家园家具列表

    shop = 11300,--商城窗口
    recharge_explain = 11301,   -- 充值说明

    npcshop = 11400,--NPC商店窗口

    -- settingwindow = 11500,--游戏设置面板
    -- new_setting_window = 11501,--游戏设置面板

    wing_flytips = 11600, --翅膀飞行提示
    wing_book = 11601, --翅膀图鉴
    wingawakenwindow = 11602, -- 翅膀觉醒技能
    model_show_window = 11603,  -- 翅膀模型预览
    wings_turnplant = 11604,  -- 翅膀模型预览

    team = 11700,--组队界面
    teamaddfriend = 11701,--组队邀请好友

    collectionwindow = 43,--收藏册界面
    collectiontipswindow = 44,--收藏册提示界面

    friend = 11800,--好友推送界面
    friendpush = 11801,--好友推送界面
    zone_otherswin = 11802,--他人空间界面
    zone_mywin = 11802,--自己空间界面
    giftsetwindow = 11803,--空间礼物设置界面
    giftwindow = 11804,--空间礼物设置界面
    friendselect = 11805,--弹出好友列表选择好友

    pushsetwindow = 12000,--日程推送设置窗口
    agendamain = 12002, --日程主界面
    autofarmwin = 12001,--自动挂机
    towerwin = 12101,--天空之塔界面
    dungeonendwin = 12102,--副本结算界面
	towerrafflewin = 12103,-- 准通用开宝箱界面
    dungeon_video_window = 12104, -- 81副本霸主录像
    dungeonhelpwindow = 12105,  -- 夺宝奇兵
    dungeonclearbuff = 12106,   -- 通关buff
    starpark = 12107,  -- 星辰乐园
    starpark_exchange = 12108, -- 星辰乐园商店

    arena_window = 12200, --竞技场
    exitconfirm_window = 12201, -- 借个地方用，退出确定窗口
    arena_victory_window = 12202, -- 胜利之路
    arenasettlementwindow = 12203, -- 竞技场结算

    fubenrollwin = 12300,--副本roll点
    fubenendwin = 12301, -- 塔结算界面

    -- improvementwin = 45, --提升引导系统

    ui_rank = 12500,    --排行榜界面

    market = 12400,--市场界面
    sell = 12401, -- 出售界面
    buynotify = 12402, -- 快速购买通知
    sell_gold = 12403,  -- 金币市场出售界面

    convoy = 12600,--护送界面
    convoyanswer = 12601,--护送答题
    convoygift = 12602,--护送箱子奖励

    newHonorView = 12700,--获得新称号

    buffpanel = 12800, -- 战斗外buff信息

    formation = 12900, -- 阵法

    world_boss = 13000, --世界boss主界面
    world_boss_honor_list = 13001, --世界boss名人榜主界面

    trialwindow = 13100, --极寒试炼界面
    eaterwindow = 13300, -- 吃货界面

    fashion_window = 14100, --时装
    fashion_face_win = 13200,
    fashion_exchange = 13201, -- 时装兑换

    qualifying_window = 13500, --时空段位赛
    qualifying_reward_tips = 13502, --时空段位赛奖励tips
    invite_win = 13501, --邀请面板
    qualifying_match_window = 13502, --匹配界面

    treasuremapwindow = 13600, --藏宝图抽奖窗口
    treasureexchangewindow = 13601, --藏宝图兑换窗口

    shippingwindow = 13700, -- 远航商人界面
    shiphelpwindow = 13701, -- 远航求助界面
    shipwindow = 13702, -- 远航接任务界面
    tohelpwindow = 13703, -- 远航帮助他人界面

    glory_window = 13800, -- 荣耀试炼界面
    glory_confirm_window = 13801, -- 荣耀试炼战斗过后结算面板
    glory_video = 13802,        -- 爵位挑战回放
    glory_new_record_window = 13803, -- 爵位挑战新记录窗口
    glory_reward = 13804,        -- 爵位奖励

    godanimal_window = 13705, --神兽兑换
    godanimal_change_window = 13706, --神兽兑换

    firstrecharge_window = 13707, --首充礼包
    buffpanel = 13708, --buff界面
    satiation_window = 13709, --饱食度界面
    setting_window = 13710, --设置

    warrior_window = 13901, -- 勇士战场总排名面板
    warrior_settle_window = 13902, -- 勇士战场结算面板

    chest_box_win = 9902, --npc宝箱开启抽奖面板

    ui_gm = 99001, --GM
    betatestwindow = 14000, -- 封测活动界面
    openbetawindow = 14001, -- 公测活动
    campaign_uniwin = 14003,    -- 活动通用界面，详情请查询campaign_model

    luckey_chest_window = 14002, -- 幸运宝箱

    summer_activity_window = 14022, --暑假活动界面

    national_day_window = 14070, --国庆活动主界面
    national_day_defense_question_window = 14082, --保卫蛋糕答题界面
    national_day_other_window = 1000003,    -- 国庆活动额外界面

    double_eleven_window = 1212121, -- 双十一活动主界面

    satiety_refuel_panel = 50000, -- 饱食度窗口
    confirmwindow = 50001,

    exam_main_win = 14500, --科举答题主ui
    exam_final_win = 14501, --科举答题主ui 决赛

    exchange_window = 9909, --资产兑换界面

    fairy_land_box = 14600, --幻境宝箱
    fairy_land_key = 14601, --幻境钥匙
    fairy_land_letter = 14602, --幻境手札
    store = 14603, --道具宠物仓库
    fairylandluckdrawwindow = 14604, --彩虹魔盒

    alchemy_window = 14900, --炼化主界面
    alchemy_item_window = 14901, --炼化道具主界面

    top_compete_finish_win = 20001, --巅峰对决

    marry_propose_window = 15000, --结缘申请界面
    marry_bepropose_window = 15001, --被结缘申请界面
    marry_propose_answer_window = 15002, --结缘申请答案界面
    marry_wedding_window = 15003, --典礼选择界面
    marry_invite_window = 15004, --典礼邀请宾客界面
    marry_beinvite_window = 15005, --收到请帖界面
    marry_theinvitation_window = 15006, --收到请帖界面
    marry_request_window = 15007, --收到进入典礼请求界面
    marry_now_wedding_window = 15008, --当前典礼界面
    marry_atmosp_tips = 15009, --浪漫值tips
    marry_divorce_window = 15010, --离婚界面
    marriage_certificate_window = 15011, --结缘证界面
    weddingday_window = 15012, --结缘纪念日界面
    marryhonor_window = 15013, --结缘称谓界面

    constellation_profile_window = 15206,--星座驾照窗口
    constellation_honor_window = 15207,--星座驾照荣耀一览窗口
    open_server_window = 16000, -- 开服活动

    teacher_window = 16100, --师徒界面
    apprenticesignupwindow = 16101, --师傅寄语界面
    findteacherwindow = 16102, --找师傅界面

    loveteamwindow = 9999999, -- 情缘匹配

    apprenticeship = 16200, -- 师徒日常界面
    guildfightelite_window = 16300, --公会精英战界面
    -- guildfight_team_window = 16301, --公会战便捷组队界面

    ridewindow = 17050, -- 坐骑
    rideequip = 17051, -- 坐骑装备
    rideskillwash = 17052, -- 坐骑技能洗炼
    ridewash = 17053, -- 坐骑洗髓
    getride = 17054, -- 获得新坐骑
    rideshowwindow = 17055, -- 展示坐骑
    ridefeedwindow = 17056, -- 坐骑精力补充
    rideskillpreviewwindow = 17057, -- 坐骑技能预览
    ridedyewindow = 17058, -- 坐骑技能预览

    force_improve = 17000, -- 战力提升界面
    force_improve_recommend = 17001, -- 战力推荐界面

    hero_rank_window = 18000, -- 武道大会排名面板
    hero_settle_window = 18001, -- 武道战场结算面板

    download_win = 19000,  -- 下载进度窗口

    masquerade_rank_window = 16500,     -- 幻境争霸排名
    masquerade_preview_window = 16501,  -- 幻境争霸模型预览

    strategy_window = 16600,        -- 攻略

    merge_server = 16001,   -- 合服活动
	worldchampion = 16400,	-- 天下第一武道会
    worldchampionshare = 16401, --武道会分享界面

    seven_day_window = 14101,   -- 新七天登录

    backend = 14050,  -- 后台活动
    backend_rank = 14051,   -- 后台活动排行榜

    sing_main_window = 16800, -- 好声音主面板
    sing_signup_window = 16801, -- 好声音报名
    sing_advert_window = 16802, -- 好声音宣传
    sing_time_window = 16803,   -- 好声音阶段
    sing_desc_window = 16804,   -- 好声音描述

    lottery_main = 16900, -- 一闷夺宝主界面

    auction_window = 16700,   -- 新七天登录

    handbook_main = 17100, -- 幻化收藏手册主界面

    endless_rank_panel = 17200, -- 无尽挑战排行

    mid_autumn_question = 14055,    -- 中秋答题
    mid_autumn_settle = 14056,      -- 孔明灯会结算
    mid_autumn_letitgo = 14057,     -- 赏月
    mid_autumn_window = 14058,      --中秋窗口
    mid_autumn_exchange = 14059,      --中秋兑换
    mid_autumn_danmaku = 14060,      --中秋弹幕

    levelbreakwindow = 17400, -- 等级突破
    exchangepointwindow  = 17405, --兑换属性点
    levelbreaksuccesswindow  = 17401, --突破成功

    share_main = 17500, -- 分享界面
    share_shop = 17501, -- 分享兑换界面
    share_bind = 17502, -- 分享兑换界面

    portraitwindow = 17300, --自定义头像

    new_moon_window = 14087,    -- 新月降临

    halloweenwindow = 14089, -- 万圣节
    halloweenmatchwindow = 14090, -- 万圣节南瓜精匹配界面
    halloweendeadtips = 14091, -- 万圣节南瓜精死亡倒计时
    halloween_exchange = 14092, -- 万圣节兑换

    sworn_progress_window = 17700,  -- 结拜进度窗口
    sworn_desc_window = 17701,      -- 结拜之前
    sworn_friend_choose = 17702,    -- 邀请好友
    sworn_getout = 17703,           -- 请离
    sworn_reason = 17704,           -- 请离
    sworn_invite_window = 17705,    -- 结拜投票表态
    sworn_modify_window = 17706,    -- 修改称号
    sworn_confirm_window = 17707,   -- 确认窗口

    godswar_main = 17900, -- 诸神之战主界面
    godswar_video = 17901, -- 诸神录像界面
    godswar_vote = 17902, -- 诸神投票界面

    guildleaguewindow = 17600, --冠军联赛
    guildleague_guess = 17602, -- 联赛竞猜

    guildleague_cup = 17603, -- 联赛历届冠军

    regression_window = 9938, --老玩家回归
    invitationfriendreturnwindow = 9939, --邀请好友回归
    inputrecruitidwindow = 9940, --输入邀请人id

    thanksgiving = 14093,       -- 感恩节

    warrior_desc_window = 13903,    -- 勇士战场说明界面

    -- elementdungeonwindow = 99999, -- 元素副本
    notnamedtreasurewindow = 99999, -- 未命名宝藏

    christmas_snowman = 17817, -- 圣诞节萌萌雪人

    continue_recharge = 17818,  -- 连续充值

    newyearwindow = 17800,      -- 元旦活动
    newyear_exchange = 17801,   -- 元旦兑换

    newlabourwindow = 17820,  -- 2017 新劳动节

    cakeexchangwindow = 17822,  -- 周年庆兑换活动

    passblesswindow = 17823,  -- 传递花语活动
    passblesssubwindow = 17824,  -- 传递花语子窗口

    snowball_match = 17802,  -- 打雪仗活动

    reward_back_window = 18400,     -- 奖励找回

    child_birth_window = 17803,     -- 子女系统资料片
    child_birth_sub_window = 17804,
    child_shop_window = 17805,      -- 子女商店

    world_red_bag_win = 188500, -- 世界红包设置金额
    world_red_bag_unopen_win = 188501, -- 世界红包未开启
    world_red_bag_set_win = 188502, --世界红包设置面吧
    world_red_bag_money_win = 188503, --世界红包选钱面板
    world_red_bag_list_win = 188504, --世界红包列表面板

    child_get_win = 18600, --获取子女界面
    child_container_panel = 18601, --子女买瓶子界面
    child_whater_win = 18602, --子女采集水界面
    child_single_way = 18603, --子女单人接任务界面
    child_study_win = 18604, -- 子女学习界面
    childquickshow = 18605, -- 子女分享界面
    childgenwash = 18607, -- 子女项链洗炼界面
    childgiveup = 18608, -- 子女抛弃界面
    childplan = 18609, -- 子女学习计划

    spring_festival = 17806,        -- 春节活动
    spring_festival_exchange = 17807,   -- 新春兑换

    teamdungeonwindow = 12130, -- 组队副本
    teamdungeonwindow_floattipsbystring = 12131, -- 上浮组队副本提示语

    valentine_window = 17808,       -- 元宵+情人节
    valentine_exchange = 17809,

    love_wish = 17810,      -- 许愿
    love_wish_back = 17811, -- 还愿

    maze_window = 18800,  -- 宝藏迷城
    playerkill = 19300, -- 英雄擂台
    playerkillbest = 19301, -- 英雄擂台冠军风采
    petevaluation = 20000,
    signreward_window = 14102, --签到抽奖

    leveljumpwindow = 17499, -- 等级跃升


    toyreward_window = 14094, --扭蛋抽奖
    marchevent_window = 14095, --3月活动
    pumpkin_damaku_window = 14096,  -- 南瓜
    fullsubtractionshop = 14097,  --满减商城

    foolwindow = 17812,

    talisman_window = 19600,        -- 法宝
    talisman_absorb = 19602,
    talisman_fusion = 19603,        -- 熔炼

    guilddungeonwindow = 19500, -- 公会副本窗口
    guilddungeonbosswindow = 19501, -- 公会副本boss窗口
    guilddungeonsoldierwindow = 19502, -- 公会副本小兵窗口
    guilddungeonherorank = 19503, -- 公会副本英雄榜
    guilddungeonsettlementwindow = 19504,
    truthordareagendawindow = 19505, -- 公会活动，真心话大冒险
    truthordareeditorwindow = 19506, -- 公会活动，真心话大冒险，编辑题目

    guildauctionwindow = 19700, -- 公会拍卖行


    animal_chess_match = 17847,     -- 斗兽棋匹配
    animal_chess_settle = 17848,    -- 斗兽棋结算

    may_iou_window = 17846,         -- 520情人节

    firstrechargedevelop_window = 17849, -- 新的首充界面

    dragonboatrankscorewin = 19906, -- 划龙舟排行

    dragon_boat_festival = 17850,   --端午

    specialitem_window = 19907,

    rebatereward_window = 19908, --小额双倍奖励活动
    rebatereward_main_window = 19909, --小额双倍奖励主界面
    world_lev_window = 17851,  --世界等级活动界面
    guild_npc_exchange_fund_win = 19910,
    warmheart_main_window = 19911,

    magicegg_window = 19920,       --精灵蛋活动
    campaign_inquiry_window = 19921,      -- 功能预告活动
    luckydogwindow = 19922,     --幸运儿面板

    quest_king_scroll_mark = 10211, -- 皇家任务羊皮卷
    quest_king_progress = 10212,        -- 皇家任务进度

    campbox_main_window = 19912, --九宫格抽奖相关活动主窗口
    campbox_tab_window = 19913, -- 九宫格抽奖相关活动页签窗口
    campbox_window = 19914, --九宫格抽奖活动界面·
    mesh_fashion_special = 19915, -- 未来战士机甲

    ingot_crash_content = 20002,       -- 元宝争霸对阵表
    ingot_crash_vote = 20003,       -- 元宝争霸投票
    ingot_crash_rank = 20004,       -- 元宝争霸排行榜
    ingot_crash_settle = 20005,     -- 元宝结算
    ingot_crash_watch = 20006,      -- 观战列表
    ingot_crash_show = 20007,       -- 展示面板
    ingot_crash_reward = 20008,     -- 奖励展示

    newexamdescwindow = 20100,       -- 答题说明面板

    summer_main_window = 20101,

    starchallengewindow = 20200, -- 星辰挑战
    enterstarchallengescene = 20201, -- 进入星辰挑战场景


    bigsummer_main_window = 20202,
    summercarnival_main_window = 20203,
    summercarnival_tab_window = 20204,
    summercarnival_tab_second_window = 20205,

    beginautumn_main_window = 20206,
    discountshopwindow = 20207,
    lovematch = 20208,
    love_check = 20209,

    campaign_secondarywin = 20210, --活动管理次级窗口(页签右
    campaign_secondarytopwin = 20302, --次级活动(页签上置窗口)

    star_challenge_help_window = 20211, -- 星辰挑战场景的帮助奖励窗口 by 嘉俊 2017/8/29

    discountshopwindow2 = 20212,
    exquisite_shelf = 20300,        -- 玲珑宝阁
    exquisite_shelf_reward = 20301, -- 玲珑宝阁翻牌奖励
    exquisite_shelf_show_window = 20303, -- 玲珑宝阁显示窗口

    face_get_effect = 20304, -- 天使飞包获得表情界面

    campaign_autumn_friend_window = 20305, -- 金秋砍价活动好友预览界面
    campaign_autumn_help_window = 20306, -- 金秋砍价活动好友帮助界面

    itemsavegetwindow = 20308, -- 物品交换窗口

    rideChooseWindow = 20309, --新手宠物选择界面
    petchildselect = 20311,
    rideChooseEndWindow = 20310, -- 新手宠物过时界面

    inquiry_select_win = 20311, -- 功能预告答题界面

    guilddragon_main = 20500,     -- 公会斗魔龙主界面
    guilddragon_rod = 20501,      -- 公会斗魔龙掠夺选择
    guilddragon_settle = 20502,   -- 公会斗魔龙结算
    guilddragon_endfight = 20503,   -- 挑战魔龙结束
    guilddragon_endrod = 20504,     -- 掠夺结束
    fashion_selection_window = 20505, -- 时装评选界面
    fashion_help_window = 20506,--时装帮助投票界面
    fashion_selection_show_window = 20507, --时装最终获奖界面
    fashion_selection_lucky_window = 20508, --时装幸运获奖界面
    childSpirtWindow = 20509, -- 子女附灵界面
    chief_challenge_window = 20510, -- 职业首席挑战界面
    exercise_window = 20511, -- 历练界面
    fashion_discount_window = 20512,   --时装打折主界面
    fashion_discount_detail_window = 20513, --时装打折购买界面
    godswarshowwin = 20514, -- 诸神徽章分享界面
    chancetipswin = 20515,
    new_year_turnable_window = 20516,   --新春转盘界面

    godswar_worship_window = 20520,--诸神膜拜
    rushtop_signup_window = 20517,  -- 冲顶大会报名界面
    rushtop_main = 20518,  --冲顶大会主界面
    exercisequickbuywindow = 20519, --诸神膜拜
    signdrawwindow = 20410,  --签到抽奖
    zero_buy_win = 20411, --开服0元购
    godswarworship_video = 20412, -- 诸神膜拜录像
    integralexchangewindow = 20413, --冬季积分兑换活动
    integralobtainwin = 20414, --冬季积分兑换活动任务窗口
    warmheartgift_window = 20415, --暖心礼包窗口
    directpackagewindow = 20416,  --直购礼包窗口
    luckytreewindow = 20417,    --幸运树活动窗口
    warorderwindow = 20418, --战令活动窗口
    warorderbuywindow = 20419, --战令购买窗口

    ArborDay_Reward_Win = 20525,  --摇摇乐十抽奖励界面


    AprilTreasure_win = 20521,   -- 愚人节欢乐寻宝主界面
    AprilReward_win = 20522,   -- 愚人节欢乐寻宝奖励界面
    --AprilTurnDice_win = 20523,   -- 愚人节欢乐寻宝幸运骰子界面
    CrossVoiceWindow = 20526,  --传声界面
    CrossVoicecontent = 20527,  --传声界面

    crossarenawindow = 20700,  --跨服擂台主窗口
    crossarenaroomlistwindow = 20701,  --跨服擂台房间列表窗口
    crossarenacreateteamwindow = 20702,  --跨服擂台创建房间窗口
    crossarenaroomwindow = 20703,  --跨服擂台房间窗口
    crossarenalogwindow = 20704, --跨服擂台录像窗口

    ApocalypseLordwindow = 20800, -- 天启挑战
    enterApocalypseLordscene = 20801, -- 进入天启挑战场景
    ApocalypseLord_help_window = 20211, -- 天启挑战场景的帮助奖励窗口

    dragon_chess_match = 20908, --龙凤棋匹配
    dragon_chess_settle = 20911,   -- 龙凤棋结算

    praytreasurewindow = 21200, --祈愿宝阁窗口
}


WindowConfig.OpenFunc = {
    -- [WindowConfig.WinID.demo] = function(args) DemoManager.Instance:Open(args) end,
    [WindowConfig.WinID.backpack] = function(args) BackpackManager.Instance:Open(args) end,
    [WindowConfig.WinID.agendamain] = function(args) AgendaManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.npcshop] = function (args) NpcshopManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.team] = function(args) TeamManager.Instance:OpenMain(args) end,
    [WindowConfig.WinID.world_boss] = function(args) WorldBossManager.Instance.model:OpenWorldBossUI() end,
    [WindowConfig.WinID.world_boss_honor_list] = function(args) WorldBossManager.Instance.model:OpenWorldBossRankUI() end,
    [WindowConfig.WinID.ui_rank] = function (args) RankManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.formation] = function(args) FormationManager.Instance:OpenMain(args) end,
    [WindowConfig.WinID.qualifying_window] = function(args) QualifyManager.Instance.model:OpenQualifyMainUI(args) end,
    [WindowConfig.WinID.market] = function (args) MarketManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.sell] = function () MarketManager.Instance:OpenWindow({4}) end,
    [WindowConfig.WinID.pet] = function(args) PetManager.Instance.model:OpenPetWindow(args) end,
    [WindowConfig.WinID.pet_learnskill] = function(args) PetManager.Instance.model:OpenPetSkillWindow(args) end,
    [WindowConfig.WinID.pet_feed] = function(args) PetManager.Instance.model:OpenPetFeedWindow(args) end,
    [WindowConfig.WinID.pet_child_feed] = function(args) PetManager.Instance.model:OpenChildFeed(args) end,
    [WindowConfig.WinID.pet_change_telnet] = function(args) PetManager.Instance.model:OpenChildTelentChange(args) end,
    [WindowConfig.WinID.pet_skin_window] = function(args) PetManager.Instance.model:OpenPetSkinWindow(args) end,
    [WindowConfig.WinID.petfusewindow] = function(args) PetManager.Instance.model:OpenPetFuseWindow(args) end,
    [WindowConfig.WinID.petquickshow] = function(args) PetManager.Instance.model:OpenPetQuickShowWindow(args) end,
    [WindowConfig.WinID.petgemwindow] = function(args) PetManager.Instance.model:OpenPetGemWindow(args) end,
    [WindowConfig.WinID.petgenselect] = function(args) PetManager.Instance.model:OpenPetGemSelectWindow(args) end,
    [WindowConfig.WinID.petchildgemwindow] = function(args) PetManager.Instance.model:OpenChildGemWindow(args) end,
    [WindowConfig.WinID.pet_upgrade] = function(args) PetManager.Instance.model:OpenPetUpgradeWindow(args) end,
    [WindowConfig.WinID.petgemwash] = function(args) PetManager.Instance.model:OpenPetGemWashWindow(args) end,
    [WindowConfig.WinID.petreceive] = function(args) PetManager.Instance.model:OpenPetReceiveWindow(args) end,
    [WindowConfig.WinID.petselect] = function(args) PetManager.Instance.model:OpenPetSelectWindow(args) end,
    [WindowConfig.WinID.petchildselect] = function(args) PetManager.Instance.model:OpenPetChildSelectWindow(args) end,
    [WindowConfig.WinID.ChildSkinWindow] = function(args) PetManager.Instance.model:OpenChildSkinWindow(args) end,
    [WindowConfig.WinID.recommendskillpanel] = function(args) PetManager.Instance.model:OpenRecommendSkillWindow(args) end,
    [WindowConfig.WinID.newpetwashskillwindow] = function(args) PetManager.Instance.model:OpenNewPetWashSkillWindow(args) end,
    [WindowConfig.WinID.petartificewindow] = function(args) PetManager.Instance.model:OpenPetArtificeWindow(args) end,
    [WindowConfig.WinID.petbreakskillview] = function(args) PetManager.Instance.model:OpenPetBreakSkillView(args) end,
    [WindowConfig.WinID.petbreakwindow] = function(args) PetManager.Instance.model:OpenPetBreakWindow(args) end,
    [WindowConfig.WinID.pet_child_upgrade] = function(args) PetManager.Instance.model:OpenChildUpgrade(args) end,
    [WindowConfig.WinID.shop] = function(args) ShopManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.skill] = function(args) SkillManager.Instance.model:OpenSkillWindow(args) end,
    [WindowConfig.WinID.skill_use_energy] = function(args) SkillManager.Instance.model:OpenUseEnergy(args) end,
    [WindowConfig.WinID.marryskillwindow] = function(args) SkillManager.Instance.model:OpenMarrySkillWindow(args) end,
    [WindowConfig.WinID.newmarryskillwindow] = function(args) SkillManager.Instance.model:OpenNewMarrySkillWindow(args) end,
    [WindowConfig.WinID.guardian] = function(args) ShouhuManager.Instance.model:OpenShouhuMainUI(args) end,
    [WindowConfig.WinID.guardianWakeupLook] = function(args) ShouhuManager.Instance.model:OpenGetWakeUpLookWindow(args) end,
    [WindowConfig.WinID.worldmapwindow] = function(args) WorldMapManager.Instance.model:OpenWindow(args) end,
    [WindowConfig.WinID.arena_window] = function (args) ArenaManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.arena_victory_window] = function (args) ArenaManager.Instance:OpenVictoryWindow(args) end,
    [WindowConfig.WinID.arenasettlementwindow] = function (args) ArenaManager.Instance.model:OpenSettlementWindow(args) end,
    [WindowConfig.WinID.trialwindow] = function (args) TrialManager.Instance.model:OpenWindow() end,
    [WindowConfig.WinID.shipwindow] = function (args) ShippingManager.Instance.model:OpenShipWin() end,
    [WindowConfig.WinID.shippingwindow] = function (args) ShippingManager.Instance.model:OpenMain() end,
    [WindowConfig.WinID.shiphelpwindow] = function (args) ShippingManager.Instance.model:FriendHelp() end,
    [WindowConfig.WinID.biblemain] = function (args) BibleManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.treasuremapwindow] = function (args) TreasuremapManager.Instance.model:OpenWindow() end,
    [WindowConfig.WinID.treasureexchangewindow] = function (args) TreasuremapManager.Instance.model:OpenExchangeWindow() end,
    [WindowConfig.WinID.eqmadvance] = function(args) EquipStrengthManager.Instance.model:OpenEquipStrengthMainUI(args) end,
    [WindowConfig.WinID.guildwindow] = function (args) GuildManager.Instance.model:OpenGuildUI(args) end,
    [WindowConfig.WinID.glory_window] = function (args) GloryManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.glory_confirm_window] = function(args) GloryManager.Instance:OpenConfirm(args) end,
    [WindowConfig.WinID.glory_new_record_window] = function(args) GloryManager.Instance:OpenNewRecored(args) end,
    [WindowConfig.WinID.glory_video] = function(args) GloryManager.Instance:OpenVideo(args) end,
    [WindowConfig.WinID.exam_main_win] = function (args) ExamManager.Instance.model:InitMainUI(args) end,
    [WindowConfig.WinID.exam_final_win] = function (args) ExamManager.Instance.model:OpenFinalExamUI(args) end,
    [WindowConfig.WinID.friend] = function (args) FriendManager.Instance.model:OpenWindow(args) end,
    [WindowConfig.WinID.friendselect] = function (args) FriendManager.Instance.model:OpenFriendSelect(args) end,
    [WindowConfig.WinID.guild_recommend_win] = function (args) GuildManager.Instance.model:InitRecommendUI(args) end,
    [WindowConfig.WinID.autofarmwin] = function (args) AutoFarmManager.Instance.model:OpenMain(args) end,
    [WindowConfig.WinID.eqmfuse] = function (args) FuseManager.Instance.model:OpenMain(args) end,
    [WindowConfig.WinID.godanimal_window] = function (args) GodAnimalManager.Instance.model:OpenWindow(args) end,
    [WindowConfig.WinID.godanimal_change_window] = function (args) GodAnimalManager.Instance.model:OpenChangeWindow(args) end,
    [WindowConfig.WinID.warrior_window] = function(args) WarriorManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.firstrecharge_window] = function(args) FirstRechargeManager.Instance.model:OpenWindow(args) end,
    [WindowConfig.WinID.buffpanel] = function(args) BuffPanelManager.Instance.model:OpenWindow(args) end,
    [WindowConfig.WinID.satiation_window] = function(args) SatiationManager.Instance.model:OpenWindow(args) end,
    [WindowConfig.WinID.setting_window] = function(args) SettingManager.Instance.model:OpenWindow(args) end,
    [WindowConfig.WinID.warrior_settle_window] = function(args) WarriorManager.Instance:OpenSettle(args) end,
    [WindowConfig.WinID.exchange_window] = function(args) ExchangeManager.Instance.model:OpenWindow(args) end,
    [WindowConfig.WinID.newHonorView] = function(args) HonorManager.Instance.model:OpenNewHonorWindow(args) end,
    [WindowConfig.WinID.guildbuildmanagewindow] = function(args) GuildManager.Instance.model:InitBuildUI(args) end,
    [WindowConfig.WinID.fashion_window] = function(args) FashionManager.Instance.model:OpenFashionUI(args) end,
    [WindowConfig.WinID.fashion_exchange] = function(args) FashionManager.Instance.model:OpenFashionExchange(args) end,
    [WindowConfig.WinID.giftwindow] = function(args) GivepresentManager.Instance:OpenGiveWin(args) end,
    [WindowConfig.WinID.skill_life_produce] = function(args) SkillManager.Instance.model:OpenSkillLifeProduceWindow(args) end,
    [WindowConfig.WinID.wing_book] = function (args) WingsManager.Instance:OpenBook(args) end,
    [WindowConfig.WinID.wingawakenwindow] = function (args) WingsManager.Instance:OpenWingaWakenWindow(args) end,
    [WindowConfig.WinID.addpoint] = function (args) AddPointManager.Instance:Open({1}) end,
    [WindowConfig.WinID.addpointPet] = function (args) AddPointManager.Instance:Open({2}) end,
    [WindowConfig.WinID.addpointChild] = function (args) AddPointManager.Instance:Open({3}) end,
    [WindowConfig.WinID.store] = function(args) BackpackManager.Instance.storeModel:OpenWindow(args) end,
    [WindowConfig.WinID.newAchievement] = function(args) AchievementManager.Instance.model:OpenNewAchievementWindow(args) end,
    [WindowConfig.WinID.achievementshopwindow] = function(args) AchievementManager.Instance.model:OpenAchievementShopWindow(args) end,
    [WindowConfig.WinID.alchemy_window] = function(args) AlchemyManager.Instance.model:InitMainUI(args) end,
    [WindowConfig.WinID.taskwindow] = function(args) QuestManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.taskdrama] = function(args) QuestManager.Instance:OpenDramaWindow(args) end,
    [WindowConfig.WinID.guild_merge_win] = function(args) GuildManager.Instance.model:InitGuildMergeUI(args) end,
    [WindowConfig.WinID.guild_healthy_win] = function(args) GuildManager.Instance.model:InitGuildHealthyUI(args) end,
    [WindowConfig.WinID.guild_merge_tips_win] = function(args) GuildManager.Instance.model:InitGuildMergeTipsUI(args) end,
    [WindowConfig.WinID.guild_npc_exchange_win] = function(args) GuildManager.Instance.model:InitGuildNpcExchangeUI(args) end,
    [WindowConfig.WinID.marry_propose_window] = function(args) MarryManager.Instance.model:OpenProposeWindow(args) end,
    [WindowConfig.WinID.marry_bepropose_window] = function(args) MarryManager.Instance.model:OpenBeProposeWindow(args) end,
    [WindowConfig.WinID.marry_propose_answer_window] = function(args) MarryManager.Instance.model:OpenProposeAnswerWindow(args) end,
    [WindowConfig.WinID.marry_wedding_window] = function(args) MarryManager.Instance.model:OpenWeddingWindow(args) end,
    [WindowConfig.WinID.marry_divorce_window] = function(args) MarryManager.Instance.model:OpenDivorceWindow(args) end,
    [WindowConfig.WinID.marriage_certificate_window] = function(args) MarryManager.Instance.model:OpenMarriageCertificateWindow(args) end,
    [WindowConfig.WinID.weddingday_window] = function(args) MarryManager.Instance.model:OpenWeddingDayWindow(args) end,
    [WindowConfig.WinID.marryhonor_window] = function(args) MarryManager.Instance.model:OpenMarryHonorWindow(args) end,
    [WindowConfig.WinID.marry_invite_window] = function(args) MarryManager.Instance.model:OpenInviteWindow(args) end,
    [WindowConfig.WinID.marry_beinvite_window] = function(args) MarryManager.Instance.model:OpenBeinviteWindow(args) end,
    [WindowConfig.WinID.marry_theinvitation_window] = function(args) MarryManager.Instance.model:OpenTheinvitationWindow(args) end,
    [WindowConfig.WinID.marry_request_window] = function(args) MarryManager.Instance.model:OpenRequestWindow(args) end,
    [WindowConfig.WinID.marry_now_wedding_window] = function(args) MarryManager.Instance.model:OpenNowWeddingWindow(args) end,
    [WindowConfig.WinID.guild_fight_window] = function(args) GuildfightManager.Instance.model:OpenWindow(args) end,
    [WindowConfig.WinID.marry_atmosp_tips] = function(args) MarryManager.Instance.model:OpenAtmospTipsWindow(args) end,
    [WindowConfig.WinID.eqmtrans] = function(args) EquipStrengthManager.Instance.model:OpenEquipTransUI(args) end,
    [WindowConfig.WinID.eqmtappointeffectwinrans] = function(args) EquipStrengthManager.Instance.model:OpenAppointEffectWindow(args) end,
    [WindowConfig.WinID.open_server_window] = function(args) OpenServerManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.constellation_profile_window] = function(args) ConstellationManager.Instance.model:OpenProfileWindow(args) end,
    [WindowConfig.WinID.constellation_honor_window] = function(args) ConstellationManager.Instance.model:OpenHonorWindow(args) end,
    [WindowConfig.WinID.guild_fight_settime_window] = function(args) GuildfightManager.Instance.model:Send11177ForInfo() end,
    [WindowConfig.WinID.loveteamwindow] = function(args) TeamManager.Instance.model:OpenLoveTeamWindow(args) end,
    [WindowConfig.WinID.skilltalentwindow] = function(args) SkillManager.Instance.model:OpenSkillTalentWindow(args) end,
    [WindowConfig.WinID.teacher_window] = function(args) TeacherManager.Instance.model:OpenWindow(args) end,
    [WindowConfig.WinID.apprenticeship] = function(args) TeacherManager.Instance.model:OpenDailyWindow(args) end,
    [WindowConfig.WinID.force_improve] = function(args) ForceImproveManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.force_improve_recommend] = function(args) ForceImproveManager.Instance.model:OpenForceImproveRecommendWindow(args) end,
    [WindowConfig.WinID.hero_rank_window] = function(args) HeroManager.Instance:OpenRankWindow(args) end,
    [WindowConfig.WinID.hero_settle_window] = function(args) HeroManager.Instance.model:OpenSettleWindow(args) end,
    [WindowConfig.WinID.guildfightelite_window] = function(args) GuildFightEliteManager.Instance.model:OpenWindow(args) end,
    [WindowConfig.WinID.ridewindow] = function(args) RideManager.Instance.model:OpenWindow(args) end,
    [WindowConfig.WinID.rideequip] = function(args) RideManager.Instance.model:OpenRideEquipWindow(args) end,
    [WindowConfig.WinID.rideskillwash] = function(args) RideManager.Instance.model:OpenRideSkillWash(args) end,
    [WindowConfig.WinID.ridewash] = function(args) RideManager.Instance.model:OpenRideWashWindow(args) end,
    [WindowConfig.WinID.getride] = function(args) RideManager.Instance.model:OpenGetRideWindow(args) end,
    [WindowConfig.WinID.rideshowwindow] = function(args) RideManager.Instance.model:OpenRideShowWindow(args) end,
    [WindowConfig.WinID.selectitem] = function(args) BackpackManager.Instance.selectItemModel:OpenMain(args) end,
    [WindowConfig.WinID.download_win] = function(args) DownLoadManager.Instance.model:OpenWindow(args) end,
    [WindowConfig.WinID.towerrafflewin] = function(args) DungeonManager.Instance:OpenUniversalEnd(args) end,
	[WindowConfig.WinID.merge_server] = function(args) MergeServerManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.recharge_explain] = function(args) ShopManager.Instance:OpenRechargeExplain(args) end,
    [WindowConfig.WinID.home_window] = function(args) HomeManager.Instance.model:OpenWindow(args) end,
    [WindowConfig.WinID.homepettrainview] = function(args) HomeManager.Instance.model:OpenPetTrainWindow(args) end,
    [WindowConfig.WinID.visithomewindow] = function(args) HomeManager.Instance.model:OpenVisitHomeWindow(args) end,
    [WindowConfig.WinID.magicbeenpanel] = function(args) HomeManager.Instance.model:OpenMagicBeenPanel(args) end,
    [WindowConfig.WinID.invitemagicbeenwindow] = function(args) HomeManager.Instance.model:OpenInviteMagicBeenWindow(args) end,
    [WindowConfig.WinID.furniturelistwindow] = function(args) HomeManager.Instance.model:OpenFurnitureListWindow(args) end,
    [WindowConfig.WinID.masquerade_rank_window] = function(args) MasqueradeManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.masquerade_preview_window] = function(args) MasqueradeManager.Instance:OpenPreviewWindow(args) end,
    [WindowConfig.WinID.worldchampion] = function(args) WorldChampionManager.Instance.model:OpenMainWindow(args) end,
    [WindowConfig.WinID.worldchampionshare] = function(args) WorldChampionManager.Instance.model:OpenShareWindow(args) end,
    [WindowConfig.WinID.strategy_window] = function(args) StrategyManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.dungeon_video_window] = function(args) DungeonManager.Instance:OpenVideoWindow(args) end,
    [WindowConfig.WinID.summer_activity_window] = function(args) SummerManager.Instance.model:InitMainUI(args) end,
    [WindowConfig.WinID.national_day_window] = function(args) NationalDayManager.Instance.model:InitMainUI(args) end,
    [WindowConfig.WinID.national_day_other_window] = function(args) NationalDayManager.Instance.model:OpenOtherWindow(args) end,
    [WindowConfig.WinID.double_eleven_window] = function(args) DoubleElevenManager.Instance.model:OpenWindow() end,
    [WindowConfig.WinID.seven_day_window] = function(args) SevendayManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.createhomewindow] = function(args) HomeManager.Instance.model:OpenCreateHomeWindow(args) end,
    [WindowConfig.WinID.gethome] = function(args) HomeManager.Instance.model:OpenGetHomeWindow(args) end,
    [WindowConfig.WinID.backend] = function(args) BackendManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.sing_main_window] = function(args) SingManager.Instance:OpenMain(args) end,
    [WindowConfig.WinID.sing_signup_window] = function(args) SingManager.Instance.model:OpenSignup(args) end,
    [WindowConfig.WinID.sing_advert_window] = function(args) SingManager.Instance.model:OpenAdvert(args) end,
    [WindowConfig.WinID.seven_day_window] = function(args) SevendayManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.auction_window] = function(args) AuctionManager.Instance.model:OpenWindow(args) end,
    [WindowConfig.WinID.sing_time_window] = function(args) SingManager.Instance:OpenTime(args) end,
    [WindowConfig.WinID.sing_desc_window] = function(args) SingManager.Instance:OpenDesc(args) end,
    [WindowConfig.WinID.lottery_main] = function(args) LotteryManager.Instance.model:OpenMain(args) end,
    [WindowConfig.WinID.backpack_expand] = function(args) BackpackManager.Instance.mainModel:OpenExpand(args) end,
    [WindowConfig.WinID.openbetawindow] = function(args) OpenBetaManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.luckey_chest_window] = function(args) LuckeyChestManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.dungeonhelpwindow] = function(args) DungeonManager.Instance:OpenHelp(args) end,
    [WindowConfig.WinID.ridefeedwindow] = function(args) RideManager.Instance.model:OpenRideFeedPanel(args) end,
    [WindowConfig.WinID.rideskillpreviewwindow] = function(args) RideManager.Instance.model:OpenRideSkillPreview(args) end,
    [WindowConfig.WinID.handbook_main] = function(args) HandbookManager.Instance.model:OpenMain(args) end,
    [WindowConfig.WinID.endless_rank_panel] = function(args) UnlimitedChallengeManager.Instance.model:OpenRankPanel() end,
    [WindowConfig.WinID.mid_autumn_question] = function(args) MidAutumnFestivalManager.Instance:OpenQuestion(args) end,
    [WindowConfig.WinID.mid_autumn_settle] = function(args) MidAutumnFestivalManager.Instance:OpenSettle(args) end,
    [WindowConfig.WinID.mid_autumn_letitgo] = function(args) MidAutumnFestivalManager.Instance:OpenLetItGo(args) end,
    [WindowConfig.WinID.levelbreakwindow] = function(args) LevelBreakManager.Instance.model:OpenWindow() end,
    [WindowConfig.WinID.exchangepointwindow] = function(args) LevelBreakManager.Instance.model:OpenExchangeWindow() end,
    [WindowConfig.WinID.guild_league_window] = function(args) GuildLeagueManager.Instance.model:OpenWindow(args) end,
    [WindowConfig.WinID.guild_pray_window] = function(args) GuildManager.Instance.model:InitPrayUI(args) end,
    [WindowConfig.WinID.guild_pray_speed_window] = function(args) GuildManager.Instance.model:InitBuildSpeedupUI(args) end,
    [WindowConfig.WinID.mid_autumn_window] = function (args) MidAutumnFestivalManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.mid_autumn_exchange] = function (args) MidAutumnFestivalManager.Instance:OpenExchange(args) end,
    [WindowConfig.WinID.share_main] = function(args) ShareManager.Instance.model:OpenMain(args) end,
    [WindowConfig.WinID.share_shop] = function(args) ShareManager.Instance.model:OpenShop(args) end,
    [WindowConfig.WinID.share_bind] = function(args) ShareManager.Instance.model:OpenBind(args) end,
    [WindowConfig.WinID.mid_autumn_danmaku] = function(args) MidAutumnFestivalManager.Instance:OpenDanmaku(args) end,
    [WindowConfig.WinID.portraitwindow] = function(args) PortraitManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.info_window] = function(args) BackpackManager.Instance:OpenInfoWindow(args) end,
    [WindowConfig.WinID.info_honor_window] = function(args) BackpackManager.Instance:OpenInfoHonorWindow(args) end,
    [WindowConfig.WinID.classeschangewindow] = function(args) ClassesChangeManager.Instance.model:OpenClassesChangeWindow(args) end,
    [WindowConfig.WinID.classeschangesuccesswindow] = function(args) ClassesChangeManager.Instance.model:OpenClassesChangeSuccessWindow(args) end,
    [WindowConfig.WinID.gemchangewindow] = function(args) ClassesChangeManager.Instance.model:OpenGemChangeWindow(args) end,
    [WindowConfig.WinID.talismanchangewindow] = function(args) ClassesChangeManager.Instance.model:OpenTalismanChangeWindow(args) end,
    [WindowConfig.WinID.backend_rank] = function(args) BackendManager.Instance:OpenRank(args) end,
    [WindowConfig.WinID.new_moon_window] = function(args) NewMoonManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.halloweenwindow] = function(args) HalloweenManager.Instance.model:InitMainUI(args) end,
    [WindowConfig.WinID.sworn_progress_window] = function(args) SwornManager.Instance:OpenProgressWindow(args) end,
    [WindowConfig.WinID.godswar_main] = function(args) GodsWarManager.Instance.model:OpenMain(args) end,
    [WindowConfig.WinID.godswar_vote] = function(args) GodsWarManager.Instance.model:OpenVote(args) end,
    [WindowConfig.WinID.godswar_video] = function(args) GodsWarManager.Instance.model:OpenVideo(args) end,
    [WindowConfig.WinID.halloweenmatchwindow] = function(args) HalloweenManager.Instance.model:OpenHalloweenMatchWindow(args) end,
    [WindowConfig.WinID.halloweendeadtips] = function(args) HalloweenManager.Instance.model:OpenHalloweenDeadTips(args) end,
    [WindowConfig.WinID.sworn_desc_window] = function(args) SwornManager.Instance:OpenDescWindow(args) end,
    [WindowConfig.WinID.halloween_exchange] = function(args) HalloweenManager.Instance:OpenExchange(args) end,
    [WindowConfig.WinID.sworn_friend_choose] = function(args) SwornManager.Instance.model:OpenInvite(args) end,
    [WindowConfig.WinID.sworn_getout] = function(args) SwornManager.Instance.model:OpenGetout(args) end,
    [WindowConfig.WinID.sworn_reason] = function(args) SwornManager.Instance.model:OpenReason(args) end,
    [WindowConfig.WinID.guildleague_guess] = function(args) GuildLeagueManager.Instance.model:OpenGuessWindow() end,
    [WindowConfig.WinID.guildleaguewindow] = function(args) GuildLeagueManager.Instance.model:OpenWindow() end,
    [WindowConfig.WinID.sworn_invite_window] = function(args) SwornManager.Instance.model:OpenVote(args) end,
    [WindowConfig.WinID.sworn_modify_window] = function(args) SwornManager.Instance.model:OpenModify(args) end,
    [WindowConfig.WinID.sworn_confirm_window] = function() SwornManager.Instance.model:OpenConfirm() end,
    [WindowConfig.WinID.dungeonclearbuff] = function(args) DungeonManager.Instance:OpenClearBuff(args) end,
    [WindowConfig.WinID.sell_gold] = function(args) MarketManager.Instance:OpenSellWindow(args) end,
    [WindowConfig.WinID.guildleague_cup] = function(args) GuildLeagueManager.Instance.model:OpenCupWindow(args) end,
    [WindowConfig.WinID.regression_window] = function(args) RegressionManager.Instance.model:OpenRegressionWindow(args) end,
    [WindowConfig.WinID.invitationfriendreturnwindow] = function(args) RegressionManager.Instance.model:OpenInvitationFriendReturnWindow(args) end,
    [WindowConfig.WinID.inputrecruitidwindow] = function(args) RegressionManager.Instance.model:OpenInputRecruitidWindow(args) end,
    [WindowConfig.WinID.thanksgiving] = function(args) ThanksgivingManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.warrior_desc_window] = function(args) WarriorManager.Instance:OpenDesc(args) end,
    -- [WindowConfig.WinID.elementdungeonwindow] = function(args) ElementDungeonManager.Instance.model:OpenWindow(args) end,
    [WindowConfig.WinID.notnamedtreasurewindow] = function(args) NotNamedTreasureManager.Instance.model:OpenWindow(args) end,
    [WindowConfig.WinID.christmas_snowman] = function(args) DoubleElevenManager.Instance.model:OpenSnowmanWindow(args) end,
    [WindowConfig.WinID.continue_recharge] = function(args) FirstRechargeManager.Instance.model:OpenContinueCharge(args) end,
    [WindowConfig.WinID.newyearwindow] = function(args) NewYearManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.newyear_exchange] = function(args) NewYearManager.Instance:OpenExchange(args) end,
    [WindowConfig.WinID.newlabourwindow] = function(args) NewLabourManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.cakeexchangwindow] = function(args) CakeExchangeManager.Instance.model:OpenWindow(args) end,
    [WindowConfig.WinID.passblesswindow] = function(args) SignDrawManager.Instance.model:OpenPassBlessWindow(args) end,
    [WindowConfig.WinID.passblesssubwindow] = function(args) SignDrawManager.Instance.model:OpenPassBlessSubWindow(args) end,
    [WindowConfig.WinID.snowball_match] = function(args) SnowBallManager.Instance.model:OpenMatchWindow() end,
    [WindowConfig.WinID.reward_back_window] = function(args) RewardBackManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.child_birth_window] = function(args) ChildBirthManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.child_birth_sub_window] = function(args) ChildBirthManager.Instance:OpenSubWindow(args) end,
    [WindowConfig.WinID.child_shop_window] = function(args) ChildBirthManager.Instance:OpenShop(args) end,
    [WindowConfig.WinID.child_study_win] = function(args) ChildrenManager.Instance.model:OpenEduWindow(args) end,
    [WindowConfig.WinID.child_get_win] = function(args) ChildrenManager.Instance.model:OpenGetWindow() end,
    [WindowConfig.WinID.child_container_panel] = function(args) ChildrenManager.Instance.model:OpenContainerPanel() end,
    [WindowConfig.WinID.child_whater_win] = function(args) ChildrenManager.Instance.model:OpenWaterWindow() end,
    [WindowConfig.WinID.child_single_way] = function(args) ChildrenManager.Instance.model:OpenGetWayPanel() end,
    [WindowConfig.WinID.childquickshow] = function(args) ChildrenManager.Instance.model:OpenChildQuickShow() end,
    [WindowConfig.WinID.childgenwash] = function(args) ChildrenManager.Instance.model:OpenChildGenWash() end,
    [WindowConfig.WinID.spring_festival] = function(args) SpringFestivalManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.spring_festival_exchange] = function(args) SpringFestivalManager.Instance:OpenExchange(args) end,
    [WindowConfig.WinID.childgiveup] = function(args) ChildrenManager.Instance.model:OpenGiveUpWindow(args) end,
    [WindowConfig.WinID.childplan] = function(args) ChildrenManager.Instance.model:OpenStudyPlan(args) end,
    [WindowConfig.WinID.teamdungeonwindow] = function(args) TeamDungeonManager.Instance.model:OpenTeamDungeonWindowByHand(args) end,
    [WindowConfig.WinID.teamdungeonwindow_floattipsbystring] = function(args) NoticeManager.Instance:FloatTipsByString(TI18N("<color='#ffff00'>打开日程-副本挑战</color>，可挑战副本获取奖励")) end,
    [WindowConfig.WinID.valentine_window] = function(args) ValentineManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.valentine_exchange] = function(args) ValentineManager.Instance:OpenExchange(args) end,
    -- [WindowConfig.WinID.guildfight_team_window] = function(args) GuildfightManager.Instance.model:ShowGuildFightTeamWindow(true,args) end,
    [WindowConfig.WinID.maze_window] = function(args) TreasureMazeManager.Instance.model:OpenMazeWindow(args) end,
    [WindowConfig.WinID.guild_siege_castle_window] = function(args) GuildSiegeManager.Instance:OpenCastleWindow(args) end,
    [WindowConfig.WinID.playerkill] = function(args) PlayerkillManager.Instance.model:OpenMainWindow(args) end,
    [WindowConfig.WinID.playerkillbest] = function(args) PlayerkillManager.Instance:Send19304() end,
    [WindowConfig.WinID.petevaluation]  = function(args) PetEvaluationManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.starpark]  = function(args) StarParkManager.Instance.model:OpenStarParkMainUI(args) end,
    [WindowConfig.WinID.starpark_exchange]  = function(args) StarParkManager.Instance.model:OpenShop(args) end,
    [WindowConfig.WinID.love_wish] = function(args) ValentineManager.Instance:OpenWish(args) end,
    [WindowConfig.WinID.love_wish_back] = function(args) ValentineManager.Instance:OpenWishBack(args) end,
    [WindowConfig.WinID.guild_siege_settle] = function(args) GuildSiegeManager.Instance:OpenSettle(args) end,
    [WindowConfig.WinID.guildstorewindow] = function(args) GuildManager.Instance.model:InitStoreUI(args) end,
    [WindowConfig.WinID.signreward_window] = function(args) SignRewardManager.Instance.model:OpenWindow(args) end,
    [WindowConfig.WinID.leveljumpwindow] = function(args) LevelJumpManager.Instance.model:OpenWindow(args) end,

    [WindowConfig.WinID.toyreward_window] = function() ToyRewardManager.Instance.model:OpenWindow() end,
    [WindowConfig.WinID.marchevent_window] = function(args) MarchEventManager.Instance.model:OpenWindow(args) end,

    [WindowConfig.WinID.foolwindow] = function(args) FoolManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.talisman_window] = function(args) TalismanManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.talisman_absorb] = function(args) TalismanManager.Instance:OpenAbsorb(args) end,
    [WindowConfig.WinID.guilddungeonwindow] = function(args) GuildDungeonManager.Instance.model:OpenWindow(args) end,
    [WindowConfig.WinID.guilddungeonbosswindow] = function(args) GuildDungeonManager.Instance.model:OpenBossWindow(args) end,
    [WindowConfig.WinID.guilddungeonsoldierwindow] = function(args) GuildDungeonManager.Instance.model:OpenSoldierWindow(args) end,
    [WindowConfig.WinID.guilddungeonherorank] = function(args) GuildDungeonManager.Instance.model:OpenHeroRankWindow(args) end,
    [WindowConfig.WinID.guildauctionwindow] = function(args) GuildAuctionManager.Instance.model:OpenWindow(args) end,
    [WindowConfig.WinID.talisman_fusion] = function(args) TalismanManager.Instance:OpenFusion(args) end,

    [WindowConfig.WinID.fullsubtractionshop] = function(args) MagicEggManager.Instance.model:OpenFullShopWindow(args) end,
    [WindowConfig.WinID.pumpkin_damaku_window] = function(args) HalloweenManager.Instance:OpenDamaku() end,
    [WindowConfig.WinID.animal_chess_match] = function(args) AnimalChessManager.Instance:OpenMatch(args) end,
    [WindowConfig.WinID.animal_chess_settle] = function(args) AnimalChessManager.Instance:OpenSettle(args) end,
    [WindowConfig.WinID.may_iou_window] = function(args) MayIOUManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.world_lev_window] = function(args) WorldLevManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.dragon_boat_festival] = function(args) DragonBoatFestivalManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.firstrechargedevelop_window] = function(args) FirstRechargeManager.Instance.model:OpenWindow(args) end,
    [WindowConfig.WinID.dragonboatrankscorewin] = function(args) DragonBoatManager.Instance:send19906() end,
    [WindowConfig.WinID.specialitem_window]  = function (args)  SpecialItemManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.rebatereward_window] = function (args) RebateRewardManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.rebatereward_main_window] = function (args) RebateRewardManager.Instance:OpenMainWindow(args) end,
    [WindowConfig.WinID.warmheartgift_window]  = function (args)  SpecialItemManager.Instance:OpenWarmHeartWindow(args) end,
    [WindowConfig.WinID.directpackagewindow]  = function (args)  SignDrawManager.Instance.model:OpenDirectPackageWindow(args) end,
    [WindowConfig.WinID.luckytreewindow]  = function (args)  CampaignProtoManager.Instance.model:OpenLuckyTreeWindow(args) end,
    [WindowConfig.WinID.warorderwindow]  = function (args)  CampaignProtoManager.Instance.model:OpenWarOrderWindow(args) end,
    [WindowConfig.WinID.warorderbuywindow]  = function (args)  CampaignProtoManager.Instance.model:OpenWarOrderBuyWindow(args) end,
    
    [WindowConfig.WinID.model_show_window] = function(args) WingsManager.Instance:OpenShow(args) end,
    [WindowConfig.WinID.guild_npc_exchange_fund_win] = function(args) GuildManager.Instance.model:InitGuildNpcFundExchangeUI(args) end,
    [WindowConfig.WinID.quest_king_scroll_mark] = function(args) QuestKingManager.Instance:OpenScrollMark(args) end,
    [WindowConfig.WinID.quest_king_progress] = function(args) QuestKingManager.Instance:OpenProgress(args) end,
    [WindowConfig.WinID.warmheart_main_window]  = function(args)  WarmHeartManager.Instance:OpenMainWindow(args) end,
    [WindowConfig.WinID.zone_mywin] = function(args) ZoneManager.Instance:OpenSelfZone(args) end,
    [WindowConfig.WinID.campbox_main_window] = function(args) CampBoxManager.Instance:OpenMainWindow(args) end,
    [WindowConfig.WinID.campbox_tab_window] = function(args) CampBoxManager.Instance:OpenTabWindow(args) end,
    [WindowConfig.WinID.campbox_window] = function() CampBoxManager.Instance:OpenWindow() end,
    [WindowConfig.WinID.ingot_crash_content] = function(args) IngotCrashManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.ingot_crash_rank] = function(args) IngotCrashManager.Instance:OpenRank(args) end,
    [WindowConfig.WinID.ingot_crash_vote] = function(args) IngotCrashManager.Instance:OpenVote(args) end,
    [WindowConfig.WinID.ingot_crash_settle] = function(args) IngotCrashManager.Instance:OpenSettle(args) end,
    [WindowConfig.WinID.ingot_crash_watch] = function(args) IngotCrashManager.Instance:OpenWatchList(args) end,
    [WindowConfig.WinID.ingot_crash_show] = function(args) IngotCrashManager.Instance:OpenShow(args) end,
    [WindowConfig.WinID.ingot_crash_reward] = function(args) IngotCrashManager.Instance:OpenReward(args) end,
    [WindowConfig.WinID.newexamdescwindow] = function(args) NewExamManager.Instance.model:OpenNewExamDesc(args) end,
    [WindowConfig.WinID.summer_main_window] = function(args) SummerGiftManager.Instance:OpenMainWindow(args) end,

    [WindowConfig.WinID.starchallengewindow] = function(args) StarChallengeManager.Instance.model:OpenWindow(args) end,
    [WindowConfig.WinID.enterstarchallengescene] = function(args) StarChallengeManager.Instance.model:EnterScene(args) end,
    [WindowConfig.WinID.ApocalypseLordwindow] = function(args) ApocalypseLordManager.Instance.model:OpenWindow(args) end,
    [WindowConfig.WinID.enterApocalypseLordscene] = function(args) StarChallengeManager.Instance.model:EnterScene(args) end,
    [WindowConfig.WinID.bigsummer_main_window] = function(args) BigSummerManager.Instance.model:OpenMainWindow(args) end,
    [WindowConfig.WinID.summercarnival_main_window] = function(args)  SummerCarnivalManager.Instance.model:OpenMainWindow(args) end,
    [WindowConfig.WinID.summercarnival_tab_window] = function(args)  SummerCarnivalManager.Instance.model:OpenTabWindow(args) end,
    [WindowConfig.WinID.summercarnival_tab_second_window] = function(args)  SummerCarnivalManager.Instance.model:OpenTabSecondWindow(args) end,

    [WindowConfig.WinID.glory_reward] = function(args) GloryManager.Instance:OpenReward(args) end,

    [WindowConfig.WinID.guild_restriction_select_window] = function(args) GuildManager.Instance.model:InitBuildRestrictionSelectWindow(args) end,

    [WindowConfig.WinID.beginautumn_main_window] = function(args) BeginAutumnManager.Instance:OpenMainWindow(args) end,
    [WindowConfig.WinID.discountshopwindow] = function(args) BeginAutumnManager.Instance.model:OpenDisCountShopWindow(args) end,
    [WindowConfig.WinID.campaign_uniwin] = function(args) CampaignManager.Instance.model:OpenWindow(args) end,
    [WindowConfig.WinID.mesh_fashion_special] = function(args) SpecialItemManager.Instance.model:OpenMeshFashion(args) end,
    [WindowConfig.WinID.lovematch] = function(args) QiXiLoveManager.Instance.model:OpenLoveMatchWindow(args) end,
    [WindowConfig.WinID.love_check] = function(args) QiXiLoveManager.Instance.model:OpenLoveCheckWindow(args) end,
    [WindowConfig.WinID.face_merge] = function(args) FaceManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.star_challenge_help_window] = function(args) StarChallengeManager.Instance.model:OpenHelp(args) end, -- by 嘉俊 2017/8/29
    [WindowConfig.WinID.ApocalypseLord_help_window] = function(args) ApocalypseLordManager.Instance.model:OpenHelp(args) end,
    [WindowConfig.WinID.campaign_secondarywin] = function(args) CampaignManager.Instance.model:OpenSecondaryWindow(args) end,
    [WindowConfig.WinID.exquisite_shelf] = function(args) ExquisiteShelfManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.exquisite_shelf_reward] = function(args) ExquisiteShelfManager.Instance:OpenReward(args) end,
    [WindowConfig.WinID.campaign_secondarytopwin] = function(args) CampaignManager.Instance.model:OpenSecondaryTopWindow(args) end,
    [WindowConfig.WinID.exquisite_shelf_show_window] = function(args) ExquisiteShelfManager.Instance.model:OpenShowWindow(args) end,
    [WindowConfig.WinID.face_get_effect] = function(args) FaceManager.Instance.model:OpenEffect(args) end,

    [WindowConfig.WinID.campaign_autumn_friend_window] = function(args) CampaignAutumnManager.Instance:OpenFriendWindow(args) end,
    [WindowConfig.WinID.campaign_autumn_help_window] = function(args) CampaignAutumnManager.Instance:OpenHelpWindow(args) end,

    [WindowConfig.WinID.campaign_autumn_help_window] = function(args) CampaignAutumnManager.Instance:OpenHelpWindow(args) end,

    [WindowConfig.WinID.itemsavegetwindow] = function(args) HonorManager.Instance.model:OpenGetWindow(args) end,
    [WindowConfig.WinID.discountshopwindow2] = function(args) BeginAutumnManager.Instance.model:OpenDisCountShopWindow2(args) end,
    [WindowConfig.WinID.rideChooseWindow] = function(args) RideManager.Instance.model:OpenRideChooseWindow(args) end,
    [WindowConfig.WinID.wings_turnplant] = function(args) WingsManager.Instance:OpenTurnplant(args) end,
    [WindowConfig.WinID.rideChooseEndWindow] = function(args) RideManager.Instance.model:OpenRideChooseEndWindow(args) end,
    [WindowConfig.WinID.magicegg_window] = function(args) MagicEggManager.Instance.model:OpenWindow(args) end,
    [WindowConfig.WinID.luckydogwindow] = function(args) MagicEggManager.Instance.model:OpenLuckyDogWindow(args) end,
    [WindowConfig.WinID.guilddragon_main] = function(args) GuildDragonManager.Instance:OpenMain(args) end,
    [WindowConfig.WinID.guilddragon_rod] = function(args) GuildDragonManager.Instance:OpenRod(args) end,
    [WindowConfig.WinID.guilddragon_settle] = function(args) GuildDragonManager.Instance:OpenSettle(args) end,
    [WindowConfig.WinID.campaign_inquiry_window] = function(args) CampaignInquiryManager.Instance:OpenWindow(args) end,
    [WindowConfig.WinID.guilddragon_endfight] = function(args) GuildDragonManager.Instance.model:OpenEndFight(args) end,
    [WindowConfig.WinID.guilddragon_endrod] = function(args) GuildDragonManager.Instance.model:OpenEndRod(args) end,
    [WindowConfig.WinID.inquiry_select_win] = function(args) CampaignInquiryManager.Instance.model:OpenSelectWindow(args) end,
    [WindowConfig.WinID.fashion_selection_window] = function(args) FashionSelectionManager.Instance.model:OpenFashionSelectionWin(args) end,
    [WindowConfig.WinID.fashion_help_window] = function(args) FashionSelectionManager.Instance.model:OpenFashionHelpWin(args) end,
    [WindowConfig.WinID.fashion_selection_show_window] = function(args) FashionSelectionManager.Instance.model:OpenFashionShowWin(args) end,
    [WindowConfig.WinID.fashion_selection_lucky_window] = function(args) FashionSelectionManager.Instance.model:OpenFashionLuckyWin(args) end,
    [WindowConfig.WinID.fashion_discount_window] = function(args) FashionDiscountManager.Instance.model:OpenMainWindow(args) end,
    [WindowConfig.WinID.fashion_discount_detail_window] = function(args) FashionDiscountManager.Instance.model:OpenDetailWindow(args) end,
    [WindowConfig.WinID.childSpirtWindow] = function(args) PetManager.Instance.model:OpenChildSpirtWindow(args) end,
    [WindowConfig.WinID.chief_challenge_window] = function(args) ClassesChallengeManager.Instance:OpenChiefChallengeWindow(args) end,
    [WindowConfig.WinID.exercise_window] = function(args) SkillManager.Instance.model:OpenExerciseWindow(args) end,
    [WindowConfig.WinID.godswarshowwin] = function(args) GodsWarManager.Instance.model:OpenJiFenShowWin(args) end,
    [WindowConfig.WinID.chancetipswin] = function(args) TipsManager.Instance.model:OpenChancewindow(args) end,
    [WindowConfig.WinID.new_year_turnable_window] = function(args) NewYearTurnableManager.Instance.model:OpenMainWindow(args) end,

    [WindowConfig.WinID.godswar_worship_window] = function(args) GodsWarWorShipManager.Instance.model:OpenWindow(args) end,
    [WindowConfig.WinID.rushtop_signup_window] = function(args) RushTopManager.Instance.model:OpenSignUp(args) end,
    [WindowConfig.WinID.rushtop_main] = function(args) RushTopManager.Instance.model:OpenMain(args) end,
    [WindowConfig.WinID.exercisequickbuywindow]= function(args) SkillManager.Instance.model:OpenExerciseQuickBuyWindow(args) end,
    [WindowConfig.WinID.signdrawwindow]= function(args) SignDrawManager.Instance.model:OpenWindow(args) end,
    [WindowConfig.WinID.godswarworship_video] = function(args) GodsWarWorShipManager.Instance.model:OpenVedioWindow(args) end,
    [WindowConfig.WinID.ArborDay_Reward_Win]= function(args) ArborDayShakeManager.Instance.model:OpenRewardWindow(args) end,
    [WindowConfig.WinID.zero_buy_win]= function(args) OpenServerManager.Instance.model:OpenZeroBuyWindow(args) end,

    --欢乐寻宝
    [WindowConfig.WinID.AprilTreasure_win]= function(args) AprilTreasureManager.Instance.model:OpenMainWindow(args) end,
    [WindowConfig.WinID.AprilReward_win]= function(args) AprilTreasureManager.Instance.model:OpenRewardWindow(args) end,
    --[WindowConfig.WinID.AprilTurnDice_win]= function(args) AprilTreasureManager.Instance.model:OpenDiceWindow(args) end,

    [WindowConfig.WinID.crossarenawindow]= function(args) CrossArenaManager.Instance.model:OpenCrossArenaWindow(args) end,
    [WindowConfig.WinID.crossarenaroomlistwindow]= function(args) CrossArenaManager.Instance.model:OpenCrossArenaRoomListWindow(args) end,
    [WindowConfig.WinID.crossarenacreateteamwindow]= function(args) CrossArenaManager.Instance.model:OpenCrossArenaCreateTeamWindow(args) end,
    [WindowConfig.WinID.crossarenaroomwindow]= function(args) CrossArenaManager.Instance.model:OpenCrossArenaRoomWindow(args) end,
    [WindowConfig.WinID.crossarenalogwindow]= function(args) CrossArenaManager.Instance.model:OpenCrossArenaLogWindow(args) end,
    [WindowConfig.WinID.CrossVoiceWindow]= function(args) CrossVoiceManager.Instance.model:OpenCrossVoiceWindow(args) end,
    [WindowConfig.WinID.CrossVoicecontent]= function(args) CrossVoiceManager.Instance.model:OpenCrossVoiceContent(args) end,

    --龙凤棋
    [WindowConfig.WinID.dragon_chess_match]= function(args) DragonPhoenixChessManager.Instance.model:OpenMatch(args) end,
    [WindowConfig.WinID.dragon_chess_settle]= function(args) DragonPhoenixChessManager.Instance.model:OpenSettlePanel(args) end,
    
    [WindowConfig.WinID.truthordareagendawindow]= function(args) TruthordareManager.Instance.model:OpenWindow(args) end,
    [WindowConfig.WinID.truthordareeditorwindow]= function(args) TruthordareManager.Instance.model:OpenEditorWindow(args) end,

    [WindowConfig.WinID.integralexchangewindow]= function(args) IntegralExchangeManager.Instance.model:OpenWindow(args) end,
    [WindowConfig.WinID.integralobtainwin]= function(args) IntegralExchangeManager.Instance.model:OpenIntegralObtainPanel(args) end,

    [WindowConfig.WinID.praytreasurewindow]  = function (args)  CampaignProtoManager.Instance.model:OpenPrayTreasureWindow(args) end,
}

