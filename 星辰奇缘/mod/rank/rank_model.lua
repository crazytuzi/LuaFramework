RankModel = RankModel or BaseClass(BaseModel)

function RankModel:__init()
    self.lastRefreshMomentList = {}
    self.datalist = {}
    self:InitData()
    self.guildData = {}
    self.lastShowMomentList = {}
    self.rankTeamShowList = {}
end

function RankModel:InitData()
    self.rank_type = {
        Lev = 1 --1等级
        ,Pet = 2 --2:宠物
        ,Shouhu = 3 --3:守护
        ,RenQiHistory = 4 --4 历史人气
        ,SendFlower = 5  -- 送花
        ,GetFlower = 6 -- 收花
        ,Weapon = 10 --10:武器
        ,Cloth = 11 --11:衣服
        ,Belt = 12 --12:腰带
        ,Pant = 13 --13:裤子
        ,Shoes = 15 --15:鞋子
        ,Ring = 16 --16:戒指
        ,Nacklace = 17 --17:项链
        ,Bracelet = 19 --19:手镯
        ,Universe = 20          -- 综合实力
        ,Sword = 21             -- 狂剑实力
        ,Magic = 22             -- 魔导实力
        ,Arrow = 23             -- 战弓实力
        ,Orc = 24               -- 兽灵实力
        ,Devine = 25            -- 秘言实力
        ,Moon = 26            -- 月魂实力
        ,Temple = 27            -- 圣骑实力
        ,Jingji_cup = 30 --30:竞技杯
        ,Guild = 31             --31:公会活跃
        ,Duanwei = 32 --31:段位赛
        ,WarriorNewTalent = 33  -- 勇士新秀组
        ,WarriorElite = 34      -- 勇士精锐组
        ,WarriorCourage = 35    -- 勇士勇武组
        ,WarriorHero = 36       -- 勇士英雄组
        ,ClassesChallenge = 37  -- 职业挑战
        ,AdventureSkill = 7    -- 冒险技能
        ,Achievement = 38      -- 成就
        ,RenQiWeekly = 39     -- 本周人气
        ,GuildBattle = 40       -- 公会战
        ,TopChallenge = 41      -- 巅峰挑战
        ,Hero = 42              -- 荣耀战场
        ,DragonBoat = 46        -- 赛龙舟
        ,Wise = 47              -- 智慧闯关
        ,MasqHero = 48         -- 幻境争霸英雄组
        ,MasqCourage = 49      -- 幻境争霸勇武组
        ,MasqElite = 50        -- 幻境争霸精锐组
        ,MasqNewTalent = 51    -- 幻境争霸新秀组
        ,Home = 52              -- 家园排行
        ,Child = 55             -- 子女
        ,Glory = 56             -- 爵位挑战
        ,LoveHistory = 98       -- 历史恩爱 4
        ,LoveWeekly = 99        -- 本周恩爱 3
        ,Teacher = 100          -- 一代宗师
        ,Students = 101         -- 育徒榜
        ,GoodVoice = 54         -- 好声音人气榜
        ,GoodVoice_ = 53         -- 好声音废弃
        ,GoodVoice2 = 60         -- 好声音实力榜
        ,StarChallenge = 65      -- 龙王试炼
        ,ApocalypseLord = 66     -- 天启试炼

        ,GodswarNewTalent = 67        --诸神之战新星组
        ,GodswarElite = 68            --诸神之战超凡组
        ,GodswarCourage = 69          --诸神之战绝尘组
        ,GodswarHero = 70             --诸神之战登峰组
        ,GodswarKing = 71             --诸神之战王者组

        ,WorldchampionElite = 72        --武道会精锐组
        ,WorldchampionCourage = 73      --武道会骁勇组
        ,WorldchampionHero = 74         --武道会英雄组
        ,WorldchampionEpic = 75         --武道会史诗组
        ,WorldchampionLegend = 76       --武道会传说组
        ,WorldchampionExtreme = 77      --武道会至尊组
        ,WorldchampionFairy = 78        --武道会神话组

        ,canyonYoungster = 79       --本服峡谷之巅新秀组
        ,canyonElite = 80           --本服峡谷之巅精锐组
        ,canyonValiant = 81         --本服峡谷之巅骁勇组
        ,canyonHero = 82            --本服峡谷之巅英雄组
        ,allCanyonYoungster = 83    --全服峡谷之巅新秀组
        ,allCanyonElite = 84        --全服峡谷之巅精锐组
        ,allCanyonValiant = 85      --全服峡谷之巅骁勇组
        ,allCanyonHero = 86         --全服峡谷之巅英雄组
    }
    self.loveRankType = {
        [self.rank_type.LoveHistory] = 4
        , [self.rank_type.LoveWeekly] = 3
    }

    self.childRankType = {
        [self.rank_type.Child] = 1,
    }

    self.Warrior = {
        {name = TI18N("新秀组"), icon = "AttrIcon57"}
        ,{name = TI18N("精锐组"), icon = "AttrIcon58"}
        ,{name = TI18N("勇武组"), icon = "AttrIcon59"}
        ,{name = TI18N("英雄组"), icon = "AttrIcon60"}
    }

    self.Masq = {
        {name = TI18N("新秀组"), icon = "AttrIcon57"}
        ,{name = TI18N("精锐组"), icon = "AttrIcon58"}
        ,{name = TI18N("勇武组"), icon = "AttrIcon59"}
        ,{name = TI18N("英雄组"), icon = "AttrIcon60"}
    }

    self.Gods = {
        {name = TI18N("新星组"), icon = "AttrIcon57"}
        ,{name = TI18N("超凡组"), icon = "AttrIcon82"}
        ,{name = TI18N("绝尘组"), icon = "AttrIcon85"}
        ,{name = TI18N("登峰组"), icon = "AttrIcon84"}
        ,{name = TI18N("王者组"), icon = "AttrIcon88"}
    }

    self.Champion = {
        {name = TI18N("精锐组"), icon = "AttrIcon58"}
        ,{name = TI18N("骁勇组"), icon = "AttrIcon89"}
        ,{name = TI18N("英雄组"), icon = "AttrIcon60"}
        ,{name = TI18N("史诗组"), icon = "AttrIcon87"}
        ,{name = TI18N("传说组"), icon = "AttrIcon83"}
        ,{name = TI18N("至尊组"), icon = "AttrIcon90"}
        ,{name = TI18N("神话组"), icon = "AttrIcon86"}
    }

    self.Canyon = {
        {name = TI18N("新秀组"), icon = "AttrIcon57"}
        ,{name = TI18N("精锐组"), icon = "AttrIcon58"}
        ,{name = TI18N("勇武组"), icon = "AttrIcon59"}
        ,{name = TI18N("英雄组"), icon = "AttrIcon60"}
    }

    self.GodsWarLevel = {TI18N("冠军"), TI18N("亚军"), TI18N("季军"), TI18N("四强"), TI18N("八强"), TI18N("十六强")}

    local commonDesc = TI18N("每天<color=#ffff00>00:00</color>刷新排行榜数据")
    local commonDesc2 = TI18N("活动结束后更新排行榜数据")
    local commonDesc3 = TI18N("1、显示全服玩家排名\n2、显示十六强队伍\n3、活动结束后刷新排行榜数据\n4、4-16名根据胜场场次、队伍战力进行排名")
    local classTitle = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), TI18N("角色评分")}
    local classScoreDesc = TI18N("我的实力:")
    self.classList = {
        {name = TI18N("个人信息"), icon = "Sword", subList = {
                {name = TI18N("竞技场"), icon = "AttrIcon41", type = self.rank_type.Jingji_cup, desc = TI18N("收录昨天竞技场积分最高的<color=#ffff00>100</color>名玩家,每天<color=#ffff00>00:00</color>刷新"), title = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), ""}, scoreDesc = TI18N("我的成绩:"), num = 100, refreshMoment = 0, friendSupported = true}
                , {name = TI18N("实力榜"), icon = "AttrIcon32", type = self.rank_type.Universe, desc = TI18N("收录昨天综合实力最高的<color=#ffff00>100</color>名玩家,每天<color=#ffff00>00:00</color>刷新"), title = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), TI18N("综合评分")}, scoreDesc = TI18N("我的综合实力:"), num = 100, refreshMoment = 0, friendSupported = false, notice = {TI18N("综合实力是<color='#ffff00'>人物实力</color>加最高评分的<color='#ffff00'>三只宝宝</color>的总和")}}
                , {name = TI18N("爵位挑战"), icon = "AttrIcon40", type = self.rank_type.Glory, desc = TI18N("根据每周排行发放奖励，<color='#ffff00'>前三</color>可获得<color='#ffff00'>幻翼·王爵紫蝶</color>"), title = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), TI18N("层数")}, scoreDesc = TI18N("我的爵位层数:"), num = 100, refreshMoment = 0, friendSupported = true}
                , {name = TI18N("成 就"), icon = "AttrIcon62", type = self.rank_type.Achievement, desc = commonDesc, title = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), TI18N("成就评分")}, scoreDesc = TI18N("我的成就评分:"), num = 100, refreshMoment = 0, friendSupported = true}
                , {name = TI18N("等 级"), icon = "AttrIcon4", type = self.rank_type.Lev, desc = commonDesc, title = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), TI18N("人物等级"), TI18N("突破次数")}, scoreDesc = TI18N("我的等级:"), num = 100, refreshMoment = 0, friendSupported = true, titleIndex = {1, 2, 4, 5, 3}}
                , {name = TI18N("宠 物"), icon = "AttrIcon38", type = self.rank_type.Pet, desc = commonDesc, title = {TI18N("排名"), TI18N("宠物主人"), TI18N("宠物名称"), TI18N("宠物评分")}, scoreDesc = TI18N("我的宠物评分:"), num = 100, refreshMoment = 0, friendSupported = true}
                , {name = TI18N("家 园"), icon = "AttrIcon62", type = self.rank_type.Home, desc = commonDesc, title = {TI18N("排名"), TI18N("主人"), TI18N("评价"), TI18N("家园等级"), TI18N("繁华度")}, scoreDesc = TI18N("我的家园评分:"), num = 100, refreshMoment = 0, friendSupported = false, titleIndex = {1, 2, 4, 5, 3}}
                , {name = TI18N("守 护"), icon = "AttrIcon43", type = self.rank_type.Shouhu, desc = commonDesc, title = {TI18N("排名"), TI18N("守护主人"),  TI18N("守护名称"), TI18N("守护评分")}, scoreDesc = TI18N("我的守护评分:"), num = 100, refreshMoment = 0, friendSupported = true}
                , {name = TI18N("冒险技能"), icon = "AttrIcon61", type = self.rank_type.AdventureSkill, desc = commonDesc, title = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), TI18N("冒险总等级")}, scoreDesc = TI18N("我的冒险总等级:"), num = 100, refreshMoment = 0, friendSupported = false}
                , {name = TI18N("子 女"), icon = "AttrIcon75", type = self.rank_type.Child, desc = commonDesc, title = {TI18N("排名"), TI18N("父母"), TI18N("子女名称"), TI18N("子女评分")}, scoreDesc = TI18N("我的子女评分:"), num = 100, refreshMoment = 0, friendSupported = false}
            }
        }
        , {name = TI18N("职业排行"), icon = "ClassesIcon", subList = {
                {name = TI18N("狂 剑"), icon = "AttrIcon64", type = self.rank_type.Sword, desc = commonDesc, title = classTitle, scoreDesc = classScoreDesc, num = 100, refreshMoment = 0, friendSupported = false}
                , {name = TI18N("魔 导"), icon = "AttrIcon65", type = self.rank_type.Magic, desc = commonDesc, title = classTitle, scoreDesc = classScoreDesc, num = 100, refreshMoment = 0, friendSupported = false}
                , {name = TI18N("战 弓"), icon = "AttrIcon66", type = self.rank_type.Arrow, desc = commonDesc, title = classTitle, scoreDesc = classScoreDesc, num = 100, refreshMoment = 0, friendSupported = false}
                , {name = TI18N("兽 灵"), icon = "AttrIcon67", type = self.rank_type.Orc, desc = commonDesc, title = classTitle, scoreDesc = classScoreDesc, num = 100, refreshMoment = 0, friendSupported = false}
                , {name = TI18N("秘 言"), icon = "AttrIcon68", type = self.rank_type.Devine, desc = commonDesc, title = classTitle, scoreDesc = classScoreDesc, num = 100, refreshMoment = 0, friendSupported = false}
                , {name = TI18N("月 魂"), icon = "AttrIcon68", type = self.rank_type.Moon, desc = commonDesc, title = classTitle, scoreDesc = classScoreDesc, num = 100, refreshMoment = 0, friendSupported = false}
                , {name = TI18N("圣 骑"), icon = "AttrIcon72", type = self.rank_type.Temple, desc = commonDesc, title = classTitle, scoreDesc = classScoreDesc, num = 100, refreshMoment = 0, friendSupported = false}
            }
        }
        -- , [2] = {name = "装备排行", icon = "Blacksmiths", subList = {
        --         [1] = {name = "武 器", icon = "AttrIcon52", type = self.rank_type.Weapon, desc = "每天<color=#ffff00>24</color>点刷新排行榜数据", title = {"排名", "角色名", "武器名称", "武器评分"}, scoreDesc = "我的武器评分:"}
        --         , [2] = {name = "衣 服", icon = "AttrIcon48", type = self.rank_type.Cloth, desc = "每天<color=#ffff00>24</color>点刷新排行榜数据", title = {"排名", "角色名", "衣服名称", "衣服评分"}, scoreDesc = "我的衣服评分:"}
        --         , [3] = {name = "腰 带", icon = "AttrIcon42", type = self.rank_type.Belt, desc = "每天<color=#ffff00>24</color>点刷新排行榜数据", title = {"排名", "角色名", "腰带名称", "腰带评分"}, scoreDesc = "我的腰带评分:"}
        --         , [4] = {name = "戒 指", icon = "AttrIcon51", type = self.rank_type.Ring, desc = "每天<color=#ffff00>24</color>点刷新排行榜数据", title = {"排名", "角色名", "戒指名称", "戒指评分"}, scoreDesc = "我的戒指评分:"}
        --         , [5] = {name = "项 链", icon = "AttrIcon44", type = self.rank_type.Nacklace, desc = "每天<color=#ffff00>24</color>点刷新排行榜数据", title = {"排名", "角色名", "项链名称", "项链评分"}, scoreDesc = "我的项链评分:"}
        --         , [6] = {name = "裤 子", icon = "AttrIcon45", type = self.rank_type.Pant, desc = "每天<color=#ffff00>24</color>点刷新排行榜数据", title = {"排名", "角色名", "裤子名称", "裤子评分"}, scoreDesc = "我的裤子评分:"}
        --         , [7] = {name = "鞋 子", icon = "AttrIcon53", type = self.rank_type.Shoes, desc = "每天<color=#ffff00>24</color>点刷新排行榜数据", title = {"排名", "角色名", "鞋子名称", "鞋子评分"}, scoreDesc = "我的鞋子评分:"}
        --         , [8] = {name = "手 镯", icon = "AttrIcon46", type = self.rank_type.Bracelet, desc = "每天<color=#ffff00>24</color>点刷新排行榜数据", title = {"排名", "角色名", "手镯名称", "手镯评分"}, scoreDesc = "我的手镯评分:"}
        --     }
        -- }
        , {name = TI18N("公会排行"), icon = "GuildIcon", subList = {
                {name = TI18N("公会战"), icon = "GuildBattle", path = AssetConfig.rank_textures, type = self.rank_type.GuildBattle, desc = commonDesc, title = {TI18N("排名"), TI18N("公会名称"), TI18N("公会积分"), TI18N("胜利数"), TI18N("会长")}, scoreDesc = TI18N("我的公会积分:"), num = 20, refreshMoment = 75600, friendSupported = false, nocache = true, titleIndex = {1, 2, 4, 3, 5}, notice = {TI18N("1.公会战赛季结束时，排行榜第一的公会将获得<color=#ffff00>天下第一会</color>的称号", "2.排行榜以赛季累计的<color=#ffff00>胜利积分</color>与<color=#ffff00>胜利数</color>排次，赛季结束后清空","3.每场公会战胜利方获得<color=#ffff00>200</color>积分，失败方获得<color=#ffff00>20</color>积分，平局各获得<color=#ffff00>60</color>积分")}}
                -- ,{name = "财 富", icon = "AttrIcon27", type = self.rank_type.Guild, desc = "每天<color=#ffff00>00:00</color>刷新排行榜数据", title = {"排名", "公会名称","公会资金",  "公会等级", "会长"}, scoreDesc = "我的公会等级:", num = 20, refreshMoment = 0, friendSupported = false, titleIndex = {1, 2, 4, 3, 5}}
                ,{name = TI18N("活 跃"), icon = "AttrIcon27", type = self.rank_type.Guild, desc = commonDesc, title = {TI18N("排名"), TI18N("公会名称"), TI18N("活跃度"), TI18N("公会等级"), TI18N("会长")}, scoreDesc = TI18N("我的公会等级:"), num = 20, refreshMoment = 0, friendSupported = false, titleIndex = {1, 2, 4, 3, 5}}
            }
        }
        , {name = TI18N("社交榜"), icon = "FlowerIcon", subList = {
                {name = TI18N("送花榜"), icon = "AttrIcon56", type = self.rank_type.SendFlower, desc = commonDesc, title = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), TI18N("送花数")}, scoreDesc = TI18N("我的送花数:"), num = 100, refreshMoment = 0, friendSupported = true}
                , {name = TI18N("收花榜"), icon = "AttrIcon56", type = self.rank_type.GetFlower, desc = commonDesc, title = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), TI18N("收花数")}, scoreDesc = TI18N("我的收花数:"), num = 100, refreshMoment = 0, friendSupported = true}
                , {name = TI18N("好声音偶像"), icon = "AttrIcon28", type = self.rank_type.GoodVoice, desc = TI18N("<color='#ffff00'>赛季结束</color>后更新排行榜数据"), title = {TI18N("排名"), TI18N("角色名"), TI18N("好评数"), TI18N("播放")}, scoreDesc = TI18N("我的好评数:"), num = 100, refreshMoment = 0, friendSupported = false}
                , {name = TI18N("好声音实力"), icon = "AttrIcon28", type = self.rank_type.GoodVoice2, desc = TI18N("<color='#ffff00'>赛季结束</color>后更新排行榜数据"), title = {TI18N("排名"), TI18N("角色名"), TI18N("好听数"), TI18N("播放")}, scoreDesc = TI18N("我的好听数:"), num = 100, refreshMoment = 0, friendSupported = false}
            }
        }
        , {name = TI18N("活动排行"), icon = "ActitIcon", subList = {
                -- {name = "赛龙舟", icon = "AttrIcon71", type = self.rank_type.DragonBoat, desc = "每<color=#ffff00>30</color>分钟刷新排行榜数据，<color=#ffff00>23:30</color>发放结算奖励", title = {"排名", "角色名", "职业", "用时"}, scoreDesc = "我的用时:", num = 100, refreshMoment = 84600, friendSupported = false, nocache = true}
                {name = TI18N("龙王试炼"), icon = "AttrIcon10", type = self.rank_type.StarChallenge, desc = TI18N("活动每周一5点刷新并发放奖励"), title = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), TI18N("阶段"), TI18N("时间")}, scoreDesc = TI18N("我的回合数:"), num = 100, refreshMoment = 0, friendSupported = false, cacheTime = 30}
                ,{name = TI18N("天启试炼"), icon = "AttrIcon10", type = self.rank_type.ApocalypseLord, desc = TI18N("活动每周一5点刷新并发放奖励"), title = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), TI18N("阶段"), TI18N("时间")}, scoreDesc = TI18N("我的回合数:"), num = 100, refreshMoment = 0, friendSupported = false, cacheTime = 30}
                , {name = TI18N("段位赛"), icon = "AttrIcon32", type = self.rank_type.Duanwei, desc = TI18N("每天<color=#ffff00>22</color>点段位赛结束后刷新排行榜数据"), title = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), TI18N("段位分")}, scoreDesc = TI18N("我的段位分:"), num = 100, refreshMoment = 79200, friendSupported = false}
                , {name = TI18N("巅峰对决"), icon = "TopChallege", type = self.rank_type.TopChallenge, desc = TI18N("<color=#ffff00>巅峰对决</color>活动结束后刷新排行榜数据"), title = {TI18N("排名"), TI18N("角色名"), TI18N("总积分"), TI18N("巅峰积分"), TI18N("职业")}, scoreDesc = TI18N("我的总积分:"), num = 100, refreshMoment = 0, friendSupported = false, titleIndex = {1, 2, 5, 4, 3}, path = AssetConfig.rank_textures}
                , {name = TI18N("荣耀战场"), icon = "TopChallege", type = self.rank_type.Hero, desc = TI18N("<color=#ffff00>荣耀战场</color>活动结束后刷新排行榜数据"), title = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), TI18N("荣耀积分")}, scoreDesc = TI18N("我的积分:"), num = 100, refreshMoment = 0, friendSupported = false, path = AssetConfig.rank_textures, nocache = true}
                , {name = TI18N("职业挑战"), icon = "AttrIcon5", type = self.rank_type.ClassesChallenge, desc = TI18N("<color=#ffff00>职业挑战</color>活动结束后刷新排行榜数据"), title = {TI18N("排名"), TI18N("角色名"), TI18N("用时"), TI18N("职业"), TI18N("难度")}, scoreDesc = TI18N("我的难度:"), num = 100, refreshMoment = 82800, friendSupported = false, titleIndex = {1, 2, 4, 5, 3}}
                , {name = TI18N("智慧闯关"), icon = "AttrIcon61", type = self.rank_type.Wise, desc = commonDesc, title = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), TI18N("分数")}, scoreDesc = TI18N("我的分数:"), num = 100, refreshMoment = 0, friendSupported = false, nocache = false}
                , {name = TI18N("勇士战场"), icon = "AttrIcon59", type = self.rank_type.WarriorNewTalent, desc = TI18N("活动当天<color='#00ff00'>21:00</color>刷新排行榜并颁发奖励"), title = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), TI18N("功勋")}, scoreDesc = TI18N("我的功勋:"), num = 100, refreshMoment = 75600, friendSupported = false}
                , {name = TI18N("勇士战场"), icon = "AttrIcon58", type = self.rank_type.WarriorElite, desc = TI18N("活动当天<color='#00ff00'>21:00</color>刷新排行榜并颁发奖励"), title = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), TI18N("功勋")}, scoreDesc = TI18N("我的功勋:"), num = 100, refreshMoment = 75600, friendSupported = false}
                , {name = TI18N("勇士战场"), icon = "AttrIcon59", type = self.rank_type.WarriorCourage, desc = TI18N("活动当天<color='#00ff00'>21:00</color>刷新排行榜并颁发奖励"), title = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), TI18N("功勋")}, scoreDesc = TI18N("我的功勋:"), num = 100, refreshMoment = 75600, friendSupported = false}
                , {name = TI18N("勇士战场"), icon = "AttrIcon60", type = self.rank_type.WarriorHero, desc = TI18N("活动当天<color='#00ff00'>21:00</color>刷新排行榜并颁发奖励"), title = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), TI18N("功勋")}, scoreDesc = TI18N("我的功勋:"), num = 100, refreshMoment = 75600, friendSupported = false}
                , {name = TI18N("精灵幻境"), icon = "GuildBattle", path = AssetConfig.rank_textures, type = self.rank_type.MasqNewTalent, desc = TI18N("每周五晚<color='#ffff00'>21：00</color>活动结束后更新"), title = {TI18N("排名"), TI18N("角色名"), TI18N("等级"), TI18N("职业"), TI18N("能量")}, scoreDesc = TI18N("我的功勋:"), num = 100, refreshMoment = 75600, friendSupported = false}
                , {name = TI18N("精灵幻境"), icon = "GuildBattle", path = AssetConfig.rank_textures, type = self.rank_type.MasqElite, desc = TI18N("每周五晚<color='#ffff00'>21：00</color>活动结束后更新"), title = {TI18N("排名"), TI18N("角色名"), TI18N("等级"), TI18N("职业"), TI18N("能量")}, scoreDesc = TI18N("我的功勋:"), num = 100, refreshMoment = 75600, friendSupported = false}
                , {name = TI18N("精灵幻境"), icon = "GuildBattle", path = AssetConfig.rank_textures, type = self.rank_type.MasqCourage, desc = TI18N("每周五晚<color='#ffff00'>21：00</color>活动结束后更新"), title = {TI18N("排名"), TI18N("角色名"), TI18N("等级"), TI18N("职业"), TI18N("能量")}, scoreDesc = TI18N("我的功勋:"), num = 100, refreshMoment = 75600, friendSupported = false}
                , {name = TI18N("精灵幻境"), icon = "GuildBattle", path = AssetConfig.rank_textures, type = self.rank_type.MasqHero, desc = TI18N("每周五晚<color='#ffff00'>21：00</color>活动结束后更新排行榜数据"), title = {TI18N("排名"), TI18N("角色名"), TI18N("等级"), TI18N("职业"), TI18N("能量")}, scoreDesc = TI18N("我的功勋:"), num = 100, refreshMoment = 75600, friendSupported = false}
                , {name = TI18N("峡谷之巅"), icon = "AttrIcon4", type = self.rank_type.canyonYoungster, desc = TI18N("活动当天<color='#7FFF00'>21：00</color>刷新排行榜"), title = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), TI18N("积分")}, scoreDesc = TI18N("我的积分:"), num = 100, refreshMoment = 75600, friendSupported = false}
                , {name = TI18N("峡谷之巅"), icon = "AttrIcon4", type = self.rank_type.canyonElite, desc = TI18N("活动当天<color='#7FFF00'>21：00</color>刷新排行榜"), title = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), TI18N("积分")}, scoreDesc = TI18N("我的积分:"), num = 100, refreshMoment = 75600, friendSupported = false}
                , {name = TI18N("峡谷之巅"), icon = "AttrIcon4", type = self.rank_type.canyonValiant, desc = TI18N("活动当天<color='#7FFF00'>21：00</color>刷新排行榜"), title = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), TI18N("积分")}, scoreDesc = TI18N("我的积分:"), num = 100, refreshMoment = 75600, friendSupported = false}
                , {name = TI18N("峡谷之巅"), icon = "AttrIcon4", type = self.rank_type.canyonHero, desc = TI18N("活动当天<color='#7FFF00'>21：00</color>刷新排行榜"), title = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), TI18N("积分")}, scoreDesc = TI18N("我的积分:"), num = 100, refreshMoment = 75600, friendSupported = false}
                -- , {name = TI18N("峡谷之巅"), icon = "AttrIcon59", type = self.rank_type.allCanyonYoungster, desc = TI18N("活动当天<color='#7FFF00'>21：00</color>刷新排行榜"), title = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), TI18N("积分")}, scoreDesc = TI18N("我的积分:"), num = 100, refreshMoment = 75600, friendSupported = false}
                -- , {name = TI18N("峡谷之巅"), icon = "AttrIcon58", type = self.rank_type.allCanyonElite, desc = TI18N("活动当天<color='#7FFF00'>21：00</color>刷新排行榜"), title = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), TI18N("积分")}, scoreDesc = TI18N("我的积分:"), num = 100, refreshMoment = 75600, friendSupported = false}
                -- , {name = TI18N("峡谷之巅"), icon = "AttrIcon59", type = self.rank_type.allCanyonValiant, desc = TI18N("活动当天<color='#7FFF00'>21：00</color>刷新排行榜"), title = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), TI18N("积分")}, scoreDesc = TI18N("我的积分:"), num = 100, refreshMoment = 75600, friendSupported = false}
                -- , {name = TI18N("峡谷之巅"), icon = "AttrIcon60", type = self.rank_type.allCanyonHero, desc = TI18N("活动当天<color='#7FFF00'>21：00</color>刷新排行榜"), title = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), TI18N("积分")}, scoreDesc = TI18N("我的积分:"), num = 100, refreshMoment = 75600, friendSupported = false}

            }
        }
        -- , [3] = {name = "其他排行", icon = "OtherIcon", subList = {
        --         -- [1] = {name = "成 就", icon = "", type = self.rank_type.Guild, desc = "", title = {"排名", "", "", ""}}
        --     }
        -- }

        , {name = TI18N("赛事排行"), icon = "matchIcon", subList = {
                {name = TI18N("武道大会"), icon = "AttrIcon55", type = self.rank_type.WorldchampionElite, desc = commonDesc2, title = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), TI18N("头衔")}, scoreDesc = TI18N("我的头衔:"), num = 100, refreshMoment = 0, friendSupported = false, cacheTime = 30000}
                ,{name = TI18N("武道大会"), icon = "AttrIcon55", type = self.rank_type.WorldchampionCourage, desc = commonDesc2, title = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), TI18N("头衔")}, scoreDesc = TI18N("我的头衔:"), num = 100, refreshMoment = 0, friendSupported = false, cacheTime = 30000}
                ,{name = TI18N("武道大会"), icon = "AttrIcon55", type = self.rank_type.WorldchampionHero, desc = commonDesc2, title = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), TI18N("头衔")}, scoreDesc = TI18N("我的头衔:"), num = 100, refreshMoment = 0, friendSupported = false, cacheTime = 30000}
                ,{name = TI18N("武道大会"), icon = "AttrIcon55", type = self.rank_type.WorldchampionEpic, desc = commonDesc2, title = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), TI18N("头衔")}, scoreDesc = TI18N("我的头衔:"), num = 100, refreshMoment = 0, friendSupported = false, cacheTime = 30000}
                ,{name = TI18N("武道大会"), icon = "AttrIcon55", type = self.rank_type.WorldchampionLegend, desc = commonDesc2, title = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), TI18N("头衔")}, scoreDesc = TI18N("我的头衔:"), num = 100, refreshMoment = 0, friendSupported = false, cacheTime = 30000}
                ,{name = TI18N("武道大会"), icon = "AttrIcon55", type = self.rank_type.WorldchampionExtreme, desc = commonDesc2, title = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), TI18N("头衔")}, scoreDesc = TI18N("我的头衔:"), num = 100, refreshMoment = 0, friendSupported = false, cacheTime = 30000}
                ,{name = TI18N("武道大会"), icon = "AttrIcon55", type = self.rank_type.WorldchampionFairy, desc = commonDesc2, title = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), TI18N("头衔")}, scoreDesc = TI18N("我的头衔:"), num = 100, refreshMoment = 0, friendSupported = false, cacheTime = 30000}
                , {name = TI18N("诸神之战"), icon = "AttrIcon55", type = self.rank_type.GodswarNewTalent, desc = commonDesc3, title = {TI18N("排名"), TI18N("战队名"), TI18N("服务器"), TI18N("诸神")}, scoreDesc = TI18N("我的诸神:"), num = 100, refreshMoment = 0, friendSupported = false}
                , {name = TI18N("诸神之战"), icon = "AttrIcon55", type = self.rank_type.GodswarElite, desc = commonDesc3, title = {TI18N("排名"), TI18N("战队名"), TI18N("服务器"), TI18N("诸神")}, scoreDesc = TI18N("我的诸神:"), num = 100, refreshMoment = 0, friendSupported = false}
                , {name = TI18N("诸神之战"), icon = "AttrIcon55", type = self.rank_type.GodswarCourage, desc = commonDesc3, title = {TI18N("排名"), TI18N("战队名"), TI18N("服务器"), TI18N("诸神")}, scoreDesc = TI18N("我的诸神:"), num = 100, refreshMoment = 0, friendSupported = false}
                , {name = TI18N("诸神之战"), icon = "AttrIcon55", type = self.rank_type.GodswarHero, desc = commonDesc3, title = {TI18N("排名"), TI18N("战队名"), TI18N("服务器"), TI18N("诸神")}, scoreDesc = TI18N("我的诸神:"), num = 100, refreshMoment = 0, friendSupported = false}
                , {name = TI18N("诸神之战"), icon = "AttrIcon55", type = self.rank_type.GodswarKing, desc = commonDesc3, title = {TI18N("排名"), TI18N("战队名"), TI18N("服务器"), TI18N("诸神")}, scoreDesc = TI18N("我的诸神:"), num = 100, refreshMoment = 0, friendSupported = false}
            }
        }

        , {name = TI18N("人气排行"), icon = "Popularity", subList = {
                {name = TI18N("本周人气榜"), icon = "AttrIcon55", type = self.rank_type.RenQiWeekly, desc = commonDesc, title = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), TI18N("人气值")}, scoreDesc = TI18N("我的人气值:"), num = 100, refreshMoment = 0, friendSupported = false}
                , {name = TI18N("历史人气榜"), icon = "AttrIcon55", type = self.rank_type.RenQiHistory, desc = commonDesc, title = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), TI18N("人气值")}, scoreDesc = TI18N("我的人气值:"), num = 100, refreshMoment = 0, friendSupported = false}
            }
        }
        , {name = TI18N("恩爱榜"), icon = "LoveWeekly", subList = {
                {name = TI18N("本周恩爱榜"), icon = "LoveHistory", type = self.rank_type.LoveWeekly, desc = commonDesc, title = {TI18N("排名"), TI18N("                                     喜结良缘"), TI18N(""), TI18N("典礼类型"), TI18N("恩爱值")}, scoreDesc = TI18N("我的恩爱值:"), num = 100, refreshMoment = 0, friendSupported = false, path = AssetConfig.rank_textures, nocache = true}
                , {name = TI18N("历史恩爱榜"), icon = "LoveHistory", type = self.rank_type.LoveHistory, desc = commonDesc, title = {TI18N("排名"), TI18N("                                     喜结良缘"), TI18N(""), TI18N("典礼类型"), TI18N("恩爱值")}, scoreDesc = TI18N("我的恩爱值:"), num = 100, refreshMoment = 0, friendSupported = false, path = AssetConfig.rank_textures, nocache = true}
            }
        }
        , {name = TI18N("良师榜"), icon = "GoodTeacher", subList = {
                {name = TI18N("一代宗师"), icon = "AttrIcon32", type = self.rank_type.Teacher, desc = commonDesc, title = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), TI18N("师道值")}, scoreDesc = TI18N("我的师道值:"), num = 100, refreshMoment = 0, friendSupported = false, nocache = false}
                , {name = TI18N("桃李天下"), icon = "AttrIcon43", type = self.rank_type.Students, desc = commonDesc, title = {TI18N("排名"), TI18N("角色名"), TI18N("职业"), TI18N("徒弟数")}, scoreDesc = TI18N("我的徒弟数:"), num = 100, refreshMoment = 0, friendSupported = false, nocache = false}
            }
        }
    }

    self.rankTypeToPageIndexList = {}
    for k1,v1 in pairs(self.classList) do
        for k2,v2 in pairs(v1.subList) do
            self.rankTypeToPageIndexList[v2.type] = {main = k1, sub = k2}
        end
    end

    self.loveTypeToRankType = {}
    for k,v in pairs(self.loveRankType) do
        self.loveTypeToRankType[v] = k
    end

    self.childTypeToRankType = {}
    for k,v in pairs(self.childRankType) do
        self.childTypeToRankType[v] = k
    end

    self.colorList = {
        Color(218/255, 72/255, 72/255),
        Color(159/255, 55/255, 231/255),
        Color(103/255, 81/255, 207/255),
        Color(198/255, 248/255, 254/255)
    }

    -- 记录页签是否显示，表里面没有的类型默认显示
    self.showFuncTab = {
        [self.rank_type.Sword] = function() return Application.platform == RuntimePlatform.WindowsEditor or CampaignManager.Instance.open_srv_time < 1499907600 end;
        [self.rank_type.Arrow] = function() return Application.platform == RuntimePlatform.WindowsEditor or CampaignManager.Instance.open_srv_time < 1499907600 end;
        [self.rank_type.Orc] = function() return Application.platform == RuntimePlatform.WindowsEditor or CampaignManager.Instance.open_srv_time < 1499907600 end;
        [self.rank_type.Devine] = function() return Application.platform == RuntimePlatform.WindowsEditor or CampaignManager.Instance.open_srv_time < 1499907600 end;
        [self.rank_type.Moon] = function() return Application.platform == RuntimePlatform.WindowsEditor or CampaignManager.Instance.open_srv_time < 1499907600 end;
        [self.rank_type.Magic] = function() return Application.platform == RuntimePlatform.WindowsEditor or CampaignManager.Instance.open_srv_time < 1499907600 end;
        [self.rank_type.Temple] = function() return Application.platform == RuntimePlatform.WindowsEditor or CampaignManager.Instance.open_srv_time < 1499907600 end;
        [self.rank_type.Universe] = function() return Application.platform == RuntimePlatform.WindowsEditor or CampaignManager.Instance.open_srv_time < 1499907600 end;
        [self.rank_type.Home] = function() return RoleManager.Instance.world_lev >= 50 end,
        [self.rank_type.Child] = function() return RoleManager.Instance.world_lev >= 60 end,
        [self.rank_type.Guild] = function() return Application.platform == RuntimePlatform.WindowsEditor or CampaignManager.Instance.open_srv_time < 1503594000 end,
        [self.rank_type.WarriorElite] = function() return false end,
        [self.rank_type.WarriorCourage] = function() return false end,
        [self.rank_type.WarriorHero] = function() return false end,
        [self.rank_type.MasqElite] = function() return false end,
        [self.rank_type.MasqCourage] = function() return false end,
        [self.rank_type.MasqHero] = function() return false end,

        [self.rank_type.WorldchampionElite] = function() return RoleManager.Instance.RoleData.lev >= 70 end,
        [self.rank_type.WorldchampionCourage] = function() return false end,
        [self.rank_type.WorldchampionHero] = function() return false end,
        [self.rank_type.WorldchampionEpic] = function() return false end,
        [self.rank_type.WorldchampionLegend] = function() return false end,
        [self.rank_type.WorldchampionExtreme] = function() return false end,
        [self.rank_type.WorldchampionFairy] = function() return false end,

        [self.rank_type.GodswarNewTalent] = function() return RoleManager.Instance.RoleData.lev >= 80 end,
        [self.rank_type.GodswarElite] = function() return false end,
        [self.rank_type.GodswarCourage] = function() return false end,
        [self.rank_type.GodswarHero] = function() return false end,
        [self.rank_type.GodswarKing] = function() return false end,

        [self.rank_type.canyonYoungster] = function() return (RoleManager.Instance.world_lev >= 70 and RoleManager.Instance.RoleData.lev >= 70) end,
        [self.rank_type.canyonElite] = function() return false end,
        [self.rank_type.canyonValiant] = function() return false end,
        [self.rank_type.canyonHero] = function() return false end,
        [self.rank_type.allCanyonYoungster] = function() return false end,
        [self.rank_type.allCanyonElite] = function() return false end,
        [self.rank_type.allCanyonValiant] = function() return false end,
        [self.rank_type.allCanyonHero] = function() return false end,
    }
end

function RankModel:OpenWindow()
    if BaseUtils.IsVerify == true then
        return
    end
    if self.rankWin == nil then
        self.rankWin = RankWindow.New(self)
    end

    local tabs = nil
    if self.args == nil then
        self.currentTab = 1
    elseif self.args[1] == 1 then
        self.currentTab = 1
        if self.args[2] == nil then
            tabs = self.rankTypeToPageIndexList[self.rank_type.Jingji_cup]
        else
            tabs = self.rankTypeToPageIndexList[self.args[2]]
        end
    elseif self.args[1] == 2 then
        self.currentTab = 2
        if self.args[2] == nil then
            tabs = {main = 1, sub = 1}
        elseif self.args[3] == nil then
            tabs = {main = self.args[2], sub = 1}
        else
            tabs = {main = self.args[2], sub = self.args[3]}
        end
    else
        self.currentTab = 1
    end

    if tabs ~= nil then
        self.currentMain = tabs.main
        self.currentSub = tabs.sub
    else
        self.currentMain = 1
        self.currentSub = 1
    end

    self.rankWin:Open()
end

function RankModel:__delete()
    if self.rankWin ~= nil then
        self.rankWin:DeleteMe()
    end
    self.rankWin = nil
end

function RankModel:CloseWin()
    WindowManager.Instance:CloseWindow(self.rankWin)
end

function RankModel:OpenRankTeamShowPanel(args)
    if self.rankShow == nil then
        self.rankShow = RankTeamShowPanel.New(self)
    end
    self.rankShow:Show(args)
end

function RankModel:CloseRankTeamShowPanel()
    if self.rankShow ~= nil then
        self.rankShow:DeleteMe()
        self.rankShow = nil
    end
end

function RankModel:SetData(main, sub, type, data)

    if self.datalist == nil then
        self.datalist = {}
    end
    if self.datalist[main] == nil then
        self.datalist[main] = {}
    end
    if self.datalist[main][sub] == nil then
        self.datalist[main][sub] = {}
    end
    if self.datalist[main][sub][type] == nil then
        self.datalist[main][sub][type] = {}
    end
    --BaseUtils.dump(data,"&&&&&&&&&&&")
    local datalist = self.datalist[main][sub][type]
    if data ~= nil then
        for k,v in pairs(data.rank_list) do
            datalist[v.rank] = v
        end
    else
        self.datalist[main][sub][type] = nil
    end

    --BaseUtils.dump(self.datalist[main][sub][type],"self.datalist")

    RankManager.Instance.OnUpdateList:Fire("ReloadRankpanel")

    if self.classList[main].subList[sub].type == self.rank_type.StarChallenge then
        local myData = nil
        local roleData = RoleManager.Instance.RoleData
        for i,v in ipairs(data.rank_list) do
            if v.rid == roleData.id and v.platform == roleData.platform and v.zone_id == roleData.zone_id then
                myData = {type = self.rank_type.StarChallenge, rank = i, val1 = v.wave}
                break
            end
        end
        if myData ~= nil then
            self:SetMyData(main, sub, myData)
        end
    end

    if self.classList[main].subList[sub].type == self.rank_type.ApocalypseLord then
        local myData = nil
        local roleData = RoleManager.Instance.RoleData
        for i,v in ipairs(data.rank_list) do
            if v.rid == roleData.id and v.platform == roleData.platform and v.zone_id == roleData.zone_id then
                myData = {type = self.rank_type.ApocalypseLord, rank = i, val1 = v.wave}
                break
            end
        end
        if myData ~= nil then
            self:SetMyData(main, sub, myData)
        end
    end
    --自身武道数据处理
    if self:CheckChampionType(self.classList[main].subList[sub].type) then
        local myData = nil
        local roleData = RoleManager.Instance.RoleData
        for i,v in ipairs(data.rank_list) do
            if v.rid == roleData.id and v.platform == roleData.platform and v.zone_id == roleData.zone_id then
                myData = {type = self.classList[main].subList[sub].type, rank = i, val1 = v.rank_lev}
                break
            end
        end
        if myData ~= nil then
            self:SetMyData(main, sub, myData)
        end
    end
end

function RankModel:GetDataList(type, subtype)
    local pos = self.rankTypeToPageIndexList[type]
    return (((self.datalist or {})[pos.main] or {})[pos.sub] or {})[subtype] or {}
end

function RankModel:SetMyData(main, sub, data)
    if self.mydata == nil then
        self.mydata = {}
    end
    if self.mydata[main] == nil then
        self.mydata[main] = {}
    end
    if self.mydata[main][sub] == nil then
        self.mydata[main][sub] = {}
    end

    local mydata = self.mydata[main][sub]
    if data ~= nil then
        mydata.rank = data.rank
        mydata.val1 = data.val1
    else
        mydata.rank = 0
        mydata.val1 = 0
    end

    RankManager.Instance.OnUpdateList:Fire("ReloadMydata")
end

function RankModel:GetMyData(type)
    local pos = self.rankTypeToPageIndexList[type]
    return ((self.mydata or {})[pos.main] or {})[pos.sub] or {}
end

function RankModel:CheckAskData(type,sub_type)
    --print("CheckAskData"..type.."&&"..sub_type)
    local pos = self.rankTypeToPageIndexList[type]
    local currentMoment = BaseUtils.BASE_TIME   -- 格林尼治时间
    local deltaTimeZone = tonumber(os.date("%H", 0)) * 3600     -- 时区校正
    local rankClass = self.classList[pos.main].subList[pos.sub]
    --print(pos.main.."pos.main")
    --print(pos.sub.."pos.sub")
    --BaseUtils.dump(rankClass,"rankClass")
    local refreshMoment = (rankClass.refreshMoment - 1) % 86400 + 1 + currentMoment - currentMoment % 86400 - deltaTimeZone
    if (rankClass.nocache == true)      -- 不缓存
        or (self.datalist[pos.main] == nil or self.datalist[pos.main][pos.sub] == nil or self.datalist[pos.main][pos.sub][sub_type] == nil)     -- 没有数据
        or (self.lastRefreshMomentList[type] == nil
            or (self.lastRefreshMomentList[type] < refreshMoment and refreshMoment <= currentMoment)                    -- 每天时刻失效
            or (rankClass.cacheTime ~= nil and self.lastRefreshMomentList[type] + rankClass.cacheTime < currentMoment)  -- 缓存定时失效
        )
        then
        RankManager.Instance:send12500({type = type, page = 1, num = rankClass.num, sub_type = sub_type})
        RankManager.Instance:send12501({type = type})
    end
    self.lastRefreshMomentList[type] = currentMoment
end

function RankModel:OnTick()
    local pos = nil
    local typeList = {}
    local delay = 300
    if IS_DEBUG then
        delay = 10
    end
    for type,moment in pairs(self.lastShowMomentList) do
        pos = self.rankTypeToPageIndexList[type]
        if moment ~= nil and BaseUtils.BASE_TIME - moment > (self.classList[pos.main].subList[pos.sub].cacheTime or delay) then
            self.datalist[pos.main][pos.sub] = self.datalist[pos.main][pos.sub] or {}
            self.datalist[pos.main][pos.sub][1] = nil
            self.datalist[pos.main][pos.sub][2] = nil
            table.insert(typeList, type)
        end
    end
    for _,type in ipairs(typeList) do
        self.lastShowMomentList[type] = nil
    end
end

function RankModel:CheckWarriorType(typ)
    local temp = false
    if typ == self.rank_type.WarriorNewTalent or typ == self.rank_type.WarriorElite or typ == self.rank_type.WarriorCourage or typ == self.rank_type.WarriorHero then
        temp = true
    end
    return temp
end

function RankModel:CheckMasqType(typ)
    local temp = false
    if typ == self.rank_type.MasqHero or typ == self.rank_type.MasqCourage or typ == self.rank_type.MasqElite or typ == self.rank_type.MasqNewTalent then
        temp = true
    end
    return temp
end

function RankModel:CheckChampionType(typ)
    local temp = false
    if typ == self.rank_type.WorldchampionElite or typ == self.rank_type.WorldchampionCourage or typ == self.rank_type.WorldchampionHero or typ == self.rank_type.WorldchampionEpic or typ == self.rank_type.WorldchampionLegend or typ == self.rank_type.WorldchampionExtreme or typ == self.rank_type.WorldchampionFairy then
        temp = true
    end
    return temp
end

function RankModel:CheckGodswarType(typ)
    local temp = false
    if typ == self.rank_type.GodswarNewTalent or typ == self.rank_type.GodswarElite or typ == self.rank_type.GodswarCourage or typ == self.rank_type.GodswarHero or typ == self.rank_type.GodswarKing then
        temp = true
    end
    return temp
end

function RankModel:CheckCanyonType(typ)
    local temp = false
    if typ == self.rank_type.canyonYoungster or typ == self.rank_type.canyonElite or typ == self.rank_type.canyonValiant or typ == self.rank_type.canyonHero or typ == self.rank_type.allCanyonYoungster or typ == self.rank_type.allCanyonElite or typ == self.rank_type.allCanyonValiant or typ == self.rank_type.allCanyonHero then
        temp = true
    end
    return temp
end

function RankModel:GetCurrFirstType()
    local temptype = self.classList[self.currentMain].subList[self.currentSub].type
    if self:CheckMasqType(temptype) then
        return self.rank_type.MasqNewTalent
    elseif self:CheckWarriorType(temptype) then
        return self.rank_type.WarriorNewTalent
    elseif self:CheckChampionType(temptype) then
        return self.rank_type.WorldchampionElite
    elseif self:CheckGodswarType(temptype) then
        return self.rank_type.GodswarNewTalent
    elseif self:CheckCanyonType(temptype) then
        return self.rank_type.canyonYoungster
    else
        return temptype
    end
end

function RankModel:CheckMyselfChampionDevel()
    local Devel = 1
    local lev = RoleManager.Instance.RoleData.lev
    local isBreak = RoleManager.Instance.RoleData.lev_break_times
    if lev < 80 then
        Devel = 1
    elseif lev < 90 then
        Devel = 2
    elseif lev <= 100 and isBreak == 0 then
        Devel = 3
    elseif lev < 100 and isBreak > 0 then
        Devel = 4
    elseif lev < 110 then
        Devel = 5
    elseif lev < 120 then
        Devel = 6
    elseif lev >= 120 then
        Devel = 7
    end
    return Devel
end

function RankModel:CheckMyselfGodwarsDevel()
    local Devel = 1
    local lev = RoleManager.Instance.RoleData.lev
    local isBreak = RoleManager.Instance.RoleData.lev_break_times
    if lev < 90 then
        Devel = 1
    elseif lev < 100 and isBreak == 0 then
        Devel = 2
    elseif lev < 100 and isBreak > 0 then
        Devel = 3
    elseif lev < 110 then
        Devel = 4
    elseif lev >= 110 then
        Devel = 5
    end
    return Devel
end
