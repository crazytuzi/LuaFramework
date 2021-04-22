--[[
	新的战队相关数据类
--]]
local QBaseModel = import("...models.QBaseModel")
local QTeamManager = class("QTeamManager",QBaseModel)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local ByteArray =  import("....framework.cc.utils.ByteArray")

QTeamManager.INSTANCE_TEAM = "INSTANCE_TEAM" --副本战队
QTeamManager.ARENA_DEFEND_TEAM = "ARENA_DEFEND_TEAM" --竞技场防守战队
QTeamManager.ARENA_ATTACK_TEAM = "ARENA_ATTACK_TEAM" --竞技场进攻战队
QTeamManager.SUNWAR_ATTACK_TEAM = "SUNWAR_ATTACK_TEAM" --太阳井第一战队
QTeamManager.SUNWAR_ATTACK_SECOND_TEAM = "SUNWAR_ATTACK_SECOND_TEAM" --太阳井第二战队
QTeamManager.SOCIETYDUNGEON_ATTACK_TEAM = "SOCIETYDUNGEON_ATTACK_TEAM" --公会副本小分队
QTeamManager.TIME_MACHINE_TEAM = "TIME_MACHINE_TEAM" --时光传送器小分队
QTeamManager.POWER_TEAM = "POWER_TEAM" --力量试练小分队
QTeamManager.INTELLECT_TEAM = "INTELLECT_TEAM" --智力试练小分队
QTeamManager.GLORY_TEAM = "GLORY_TEAM" --荣耀之塔小分队
QTeamManager.GLORY_DEFEND_TEAM = "GLORY_DEFEND_TEAM" --荣耀之塔防守小分队
QTeamManager.THUNDER_TEAM = "THUNDER_TEAM" --雷电王座小分队
QTeamManager.INVASION_TEAM = "INVASION_TEAM" --要塞入侵小分队
QTeamManager.WORLDBOSS_TEAM = "WORLDBOSS_TEAM" --要塞世界BOSS小分队
QTeamManager.SILVERMINE_ATTACK_TEAM = "SILVERMINE_ATTACK_TEAM" --银矿战（宝石矿洞）进攻小分队
QTeamManager.SILVERMINE_DEFEND_TEAM = "SILVERMINE_DEFEND_TEAM" --银矿战（宝石矿洞）防守小分队
QTeamManager.STORM_ARENA_ATTACK_TEAM1 = "STORM_ARENA_ATTACK_TEAM1" --巅峰竞技场 进攻战队1
QTeamManager.STORM_ARENA_ATTACK_TEAM2 = "STORM_ARENA_ATTACK_TEAM2" --巅峰竞技场 进攻战队2
QTeamManager.STORM_ARENA_DEFEND_TEAM1 = "STORM_ARENA_DEFEND_TEAM1" --巅峰竞技场 防守战队1
QTeamManager.STORM_ARENA_DEFEND_TEAM2 = "STORM_ARENA_DEFEND_TEAM2" --巅峰竞技场 防守战队2
QTeamManager.BLACK_ROCK_FRIST_TEAM = "BLACK_ROCK_FRIST_TEAM" --黑石塔第一战队
QTeamManager.BLACK_ROCK_SECOND_TEAM = "BLACK_ROCK_SECOND_TEAM" --黑石塔第二战队
QTeamManager.PLUNDER_ATTACK_TEAM = "PLUNDER_ATTACK_TEAM" --公会矿战进攻小分队
QTeamManager.PLUNDER_DEFEND_TEAM = "PLUNDER_DEFEND_TEAM" --公会矿战防守小分队
QTeamManager.MARITIME_ATTACK_TEAM1 = "MARITIME_ATTACK_TEAM1" --海商 进攻战队1
QTeamManager.MARITIME_ATTACK_TEAM2 = "MARITIME_ATTACK_TEAM2" --海商 进攻战队2
QTeamManager.MARITIME_DEFEND_TEAM1 = "MARITIME_DEFEND_TEAM1" --海商 防守战队1
QTeamManager.MARITIME_DEFEND_TEAM2 = "MARITIME_DEFEND_TEAM2" --海商 防守战队2
QTeamManager.UNION_DRAGON_WAR_ATTACK_TEAM = "UNION_DRAGON_WAR_ATTACK_TEAM" --公会龙战 进攻战队
QTeamManager.SPARFIELD_TEAM = "SPARFIELD_TEAM" --晶石场进攻小分队
QTeamManager.SANCTUARY_ATTACK_TEAM1 = "SANCTUARY_ATTACK_TEAM1" --全大陆精英 进攻战队1
QTeamManager.SANCTUARY_ATTACK_TEAM2 = "SANCTUARY_ATTACK_TEAM2" --全大陆精英 进攻战队2
QTeamManager.SANCTUARY_DEFEND_TEAM1 = "SANCTUARY_DEFEND_TEAM1" --全大陆精英 防守战队1
QTeamManager.SANCTUARY_DEFEND_TEAM2 = "SANCTUARY_DEFEND_TEAM2" --全大陆精英 防守战队2
QTeamManager.TEAMARENA_ATTACK_TEAM = "TEAMARENA_ATTACK_TEAM" --组队竞技小分队
QTeamManager.HOLYLIGHT_ATTACK_TEAM = "HOLYLIGHT_ATTACK_TEAM" --圣光试炼小分队
QTeamManager.CONSORTIA_WAR_DEFEND_TEAM1 = "CONSORTIA_WAR_DEFEND_TEAM1" --宗门战防守小分队1
QTeamManager.CONSORTIA_WAR_DEFEND_TEAM2 = "CONSORTIA_WAR_DEFEND_TEAM2" --宗门战防守小分队2
QTeamManager.CONSORTIA_WAR_ATTACK_TEAM1 = "CONSORTIA_WAR_ATTACK_TEAM1" --宗门战进攻小分队1
QTeamManager.CONSORTIA_WAR_ATTACK_TEAM2 = "CONSORTIA_WAR_ATTACK_TEAM2" --宗门战进攻小分队2
QTeamManager.FIGHT_CLUB_ATTACK_TEAM = "FIGHT_CLUB_ATTACK_TEAM" --地狱杀戮场 进攻战队
QTeamManager.FIGHT_CLUB_DEFEND_TEAM = "FIGHT_CLUB_DEFEND_TEAM" --地狱杀戮场 防守战队
QTeamManager.LAND_OF_LAVA_ATTACK_TEAM = "LAND_OF_LAVA_ATTACK_TEAM" --熔岩之地 进攻战队
QTeamManager.ARATHI_DEFEND_TEAM = "ARATHI_DEFEND_TEAM" --阿拉希战场 防守战队
QTeamManager.METAL_CIRY_ATTACK_TEAM1 = "METAL_CIRY_ATTACK_TEAM1" --金属之城 进攻战队1
QTeamManager.METAL_CIRY_ATTACK_TEAM2 = "METAL_CIRY_ATTACK_TEAM2" --金属之城 进攻战队2
QTeamManager.SOTO_TEAM_ATTACK_TEAM = "SOTO_TEAM_ATTACK_TEAM" --索坨团队进攻阵容
QTeamManager.SOTO_TEAM_DEFEND_TEAM = "SOTO_TEAM_DEFEND_TEAM" --索坨团队防守阵容
QTeamManager.MOCK_BATTLE_TEAM = "MOCK_BATTLE_TEAM" --大师赛战队
QTeamManager.TOTEM_CHALLENGE_TEAM1 = "TOTEM_CHALLENGE_TEAM1" --圣柱挑战进攻小分队1
QTeamManager.TOTEM_CHALLENGE_TEAM2 = "TOTEM_CHALLENGE_TEAM2" --圣柱挑战进攻小分队2
QTeamManager.MOCK_BATTLE_DOUBLE_TEAM1 = "MOCK_BATTLE_DOUBLE_TEAM1" --双队模拟赛小分队1
QTeamManager.MOCK_BATTLE_DOUBLE_TEAM2 = "MOCK_BATTLE_DOUBLE_TEAM2" --双队模拟赛小分队2
QTeamManager.SOUL_TOWER_BATTLE_TEAM = "SOUL_TOWER_BATTLE_TEAM" --升灵台战队
QTeamManager.SILVES_ARENA_TEAM = "SILVES_ARENA_TEAM" --西尔维斯大斗魂场阵容
QTeamManager.MAZE_EXPLORE_TEAM = "MAZE_EXPLORE_TEAM" --破碎位面阵容
QTeamManager.METAL_ABYSS_TEAM1 = "METAL_ABYSS_TEAM1" --金属深渊阵容分队1
QTeamManager.METAL_ABYSS_TEAM2 = "METAL_ABYSS_TEAM2" --金属深渊阵容分队2
QTeamManager.METAL_ABYSS_TEAM3 = "METAL_ABYSS_TEAM3" --金属深渊阵容分队3

QTeamManager.TEAM_INDEX_MAIN = 1 --主力战队
QTeamManager.TEAM_INDEX_HELP = 2 --援助战队1
QTeamManager.TEAM_INDEX_HELP2 = 3 --援助战队2 
QTeamManager.TEAM_INDEX_HELP3 = 4 --援助战队3 
QTeamManager.TEAM_INDEX_GODARM = 5 --神器 
QTeamManager.TEAM_INDEX_SKILL = 2 --援助战队1 
QTeamManager.TEAM_INDEX_SKILL2 = 3 --援助战队2
QTeamManager.TEAM_INDEX_SKILL3 = 4 --援助战队3 
 
--战队类型
QTeamManager.NORMAL_TEAM = "NORMAL_TEAM" --普通战队
QTeamManager.THREE_TEAM = "THREE_TEAM" --3V3战队
QTeamManager.METAL_CITY_TEAM = "METAL_CITY_TEAM" --1小队+多援助战队
QTeamManager.ALTERNATE_TEAM = "ALTERNATE_TEAM" --替补型战队
QTeamManager.MOCK_TEAM = "MOCK_TEAM" --大师赛战斗 魂师带暗器

--事件
QTeamManager.EVENT_UPDATE_TEAM = "EVENT_UPDATE_TEAM" --阵容更新在快速换队的界面
QTeamManager.ACTIVITE_POS = "ACTIVITE_POS" --激活援助位事件

--战队的序列化版本号，最多三位
QTeamManager.TEAM_VERSION = "1.1.0" 


local teamConfig = {}
--[战队enum] = {key,是否防守阵容,战队类型, 战队处理函数, teamNum:用来计算解锁等级, isPVP:是否是PVP战斗类型}
table.insert(teamConfig, {key = QTeamManager.INSTANCE_TEAM, isSaveAtServer = false, teamType = QTeamManager.NORMAL_TEAM, teamHandlerClass = "QTeamNormal"})
table.insert(teamConfig, {key = QTeamManager.ARENA_DEFEND_TEAM, isSaveAtServer = true,	teamType = QTeamManager.NORMAL_TEAM, teamHandlerClass = "QTeamNormal", isPVP = true})
table.insert(teamConfig, {key = QTeamManager.ARENA_ATTACK_TEAM, isSaveAtServer = false,	teamType = QTeamManager.NORMAL_TEAM, teamHandlerClass = "QTeamNormal", isPVP = true})
table.insert(teamConfig, {key = QTeamManager.SUNWAR_ATTACK_TEAM, 	isSaveAtServer = false,	teamType = QTeamManager.NORMAL_TEAM, teamHandlerClass = "QTeamNormal", isPVP = true})
table.insert(teamConfig, {key = QTeamManager.SUNWAR_ATTACK_SECOND_TEAM, isSaveAtServer = false,teamType = QTeamManager.NORMAL_TEAM, teamHandlerClass = "QTeamNormal", isPVP = true})
table.insert(teamConfig, {key = QTeamManager.SOCIETYDUNGEON_ATTACK_TEAM, isSaveAtServer = false,teamType = QTeamManager.NORMAL_TEAM, teamHandlerClass = "QTeamNormal"})
table.insert(teamConfig, {key = QTeamManager.TIME_MACHINE_TEAM, isSaveAtServer = false,teamType = QTeamManager.NORMAL_TEAM, teamHandlerClass = "QTeamNormal"})
table.insert(teamConfig, {key = QTeamManager.POWER_TEAM, isSaveAtServer = false,teamType = QTeamManager.NORMAL_TEAM, teamHandlerClass = "QTeamNormal"})
table.insert(teamConfig, {key = QTeamManager.INTELLECT_TEAM, isSaveAtServer = false,teamType = QTeamManager.NORMAL_TEAM, teamHandlerClass = "QTeamNormal"})
table.insert(teamConfig, {key = QTeamManager.GLORY_TEAM, isSaveAtServer = false,teamType = QTeamManager.NORMAL_TEAM, teamHandlerClass = "QTeamNormal", isPVP = true})
table.insert(teamConfig, {key = QTeamManager.GLORY_DEFEND_TEAM, isSaveAtServer = true,teamType = QTeamManager.NORMAL_TEAM, teamHandlerClass = "QTeamNormal", isPVP = true})
table.insert(teamConfig, {key = QTeamManager.THUNDER_TEAM, isSaveAtServer = false,teamType = QTeamManager.NORMAL_TEAM, teamHandlerClass = "QTeamNormal"})
table.insert(teamConfig, {key = QTeamManager.INVASION_TEAM, isSaveAtServer = false,teamType = QTeamManager.NORMAL_TEAM, teamHandlerClass = "QTeamNormal"})
table.insert(teamConfig, {key = QTeamManager.WORLDBOSS_TEAM, isSaveAtServer = false,teamType = QTeamManager.NORMAL_TEAM, teamHandlerClass = "QTeamNormal"})
table.insert(teamConfig, {key = QTeamManager.SILVERMINE_ATTACK_TEAM, isSaveAtServer = false,teamType = QTeamManager.NORMAL_TEAM, teamHandlerClass = "QTeamNormal", isPVP = true})
table.insert(teamConfig, {key = QTeamManager.SILVERMINE_DEFEND_TEAM, isSaveAtServer = true,teamType = QTeamManager.NORMAL_TEAM, teamHandlerClass = "QTeamNormal", isPVP = true})
table.insert(teamConfig, {key = QTeamManager.STORM_ARENA_ATTACK_TEAM1, isSaveAtServer = false,teamType = QTeamManager.METAL_CITY_TEAM, teamHandlerClass = "QTeamStorm", teamTypeNum = 2,isPVP = true})
table.insert(teamConfig, {key = QTeamManager.STORM_ARENA_DEFEND_TEAM1, isSaveAtServer = true,teamType = QTeamManager.METAL_CITY_TEAM, teamHandlerClass = "QTeamStorm", teamTypeNum = 2,isPVP = true})
table.insert(teamConfig, {key = QTeamManager.STORM_ARENA_ATTACK_TEAM2, isSaveAtServer = false,teamType = QTeamManager.METAL_CITY_TEAM, teamHandlerClass = "QTeamStorm", teamTypeNum = 2,teamNum = 2, isPVP = true})
table.insert(teamConfig, {key = QTeamManager.STORM_ARENA_DEFEND_TEAM2, isSaveAtServer = true,teamType = QTeamManager.METAL_CITY_TEAM, teamHandlerClass = "QTeamStorm", teamTypeNum = 2,teamNum = 2, isPVP = true})
table.insert(teamConfig, {key = QTeamManager.BLACK_ROCK_FRIST_TEAM, isSaveAtServer = false,teamType = QTeamManager.NORMAL_TEAM, teamHandlerClass = "QTeamNormal"})
table.insert(teamConfig, {key = QTeamManager.BLACK_ROCK_SECOND_TEAM, isSaveAtServer = false,teamType = QTeamManager.NORMAL_TEAM, teamHandlerClass = "QTeamNormal"})
table.insert(teamConfig, {key = QTeamManager.PLUNDER_ATTACK_TEAM, isSaveAtServer = false,teamType = QTeamManager.NORMAL_TEAM, teamHandlerClass = "QTeamNormal", isPVP = true})
table.insert(teamConfig, {key = QTeamManager.PLUNDER_DEFEND_TEAM, isSaveAtServer = true,teamType = QTeamManager.NORMAL_TEAM, teamHandlerClass = "QTeamNormal", isPVP = true})
table.insert(teamConfig, {key = QTeamManager.MARITIME_ATTACK_TEAM1, isSaveAtServer = false,teamType = QTeamManager.METAL_CITY_TEAM, teamHandlerClass = "QTeamStorm", teamTypeNum = 2,isPVP = true})
table.insert(teamConfig, {key = QTeamManager.MARITIME_DEFEND_TEAM1, isSaveAtServer = true,teamType = QTeamManager.METAL_CITY_TEAM, teamHandlerClass = "QTeamStorm", teamTypeNum = 2,isPVP = true})
table.insert(teamConfig, {key = QTeamManager.MARITIME_ATTACK_TEAM2, isSaveAtServer = false,teamType = QTeamManager.METAL_CITY_TEAM, teamHandlerClass = "QTeamStorm",teamTypeNum = 2, teamNum = 2, isPVP = true})
table.insert(teamConfig, {key = QTeamManager.MARITIME_DEFEND_TEAM2, isSaveAtServer = true,teamType = QTeamManager.METAL_CITY_TEAM, teamHandlerClass = "QTeamStorm", teamTypeNum = 2,teamNum = 2, isPVP = true})
table.insert(teamConfig, {key = QTeamManager.UNION_DRAGON_WAR_ATTACK_TEAM, isSaveAtServer = false,teamType = QTeamManager.NORMAL_TEAM, teamHandlerClass = "QTeamNormal"})
table.insert(teamConfig, {key = QTeamManager.SPARFIELD_TEAM, isSaveAtServer = false,teamType = QTeamManager.THREE_TEAM, teamHandlerClass = "QTeamStorm"})
table.insert(teamConfig, {key = QTeamManager.SANCTUARY_ATTACK_TEAM1, isSaveAtServer = false,teamType = QTeamManager.METAL_CITY_TEAM, teamHandlerClass = "QTeamStorm", teamTypeNum = 2,isPVP = true})
table.insert(teamConfig, {key = QTeamManager.SANCTUARY_DEFEND_TEAM1, isSaveAtServer = true,teamType = QTeamManager.METAL_CITY_TEAM, teamHandlerClass = "QTeamStorm", teamTypeNum = 2,isPVP = true})
table.insert(teamConfig, {key = QTeamManager.SANCTUARY_ATTACK_TEAM2, isSaveAtServer = false,teamType = QTeamManager.METAL_CITY_TEAM, teamHandlerClass = "QTeamStorm", teamTypeNum = 2,teamNum = 2, isPVP = true})
table.insert(teamConfig, {key = QTeamManager.SANCTUARY_DEFEND_TEAM2, isSaveAtServer = true,teamType = QTeamManager.METAL_CITY_TEAM, teamHandlerClass = "QTeamStorm", teamTypeNum = 2,teamNum = 2, isPVP = true})
table.insert(teamConfig, {key = QTeamManager.TEAMARENA_ATTACK_TEAM, isSaveAtServer = true,teamType = QTeamManager.THREE_TEAM, teamHandlerClass = "QTeamStorm"})
table.insert(teamConfig, {key = QTeamManager.HOLYLIGHT_ATTACK_TEAM, isSaveAtServer = false,teamType = QTeamManager.THREE_TEAM, teamHandlerClass = "QTeamStorm"})
table.insert(teamConfig, {key = QTeamManager.CONSORTIA_WAR_DEFEND_TEAM1, isSaveAtServer = true,teamType = QTeamManager.THREE_TEAM, teamHandlerClass = "QTeamStorm", teamTypeNum = 2,isPVP = true})
table.insert(teamConfig, {key = QTeamManager.CONSORTIA_WAR_DEFEND_TEAM2, isSaveAtServer = true,teamType = QTeamManager.THREE_TEAM, teamHandlerClass = "QTeamStorm", teamTypeNum = 2,teamNum = 2, isPVP = true})
table.insert(teamConfig, {key = QTeamManager.CONSORTIA_WAR_ATTACK_TEAM1, isSaveAtServer = false,teamType = QTeamManager.THREE_TEAM, teamHandlerClass = "QTeamStorm", teamTypeNum = 2,isPVP = true})
table.insert(teamConfig, {key = QTeamManager.CONSORTIA_WAR_ATTACK_TEAM2, isSaveAtServer = false,teamType = QTeamManager.THREE_TEAM, teamHandlerClass = "QTeamStorm", teamTypeNum = 2,teamNum = 2, isPVP = true})
table.insert(teamConfig, {key = QTeamManager.FIGHT_CLUB_ATTACK_TEAM, isSaveAtServer = false,teamType = QTeamManager.NORMAL_TEAM, teamHandlerClass = "QTeamNormal", isPVP = true})
table.insert(teamConfig, {key = QTeamManager.FIGHT_CLUB_DEFEND_TEAM, isSaveAtServer = true,teamType = QTeamManager.NORMAL_TEAM, teamHandlerClass = "QTeamNormal", isPVP = true})
table.insert(teamConfig, {key = QTeamManager.LAND_OF_LAVA_ATTACK_TEAM, isSaveAtServer = false,teamType = QTeamManager.NORMAL_TEAM, teamHandlerClass = "QTeamNormal"})
table.insert(teamConfig, {key = QTeamManager.ARATHI_DEFEND_TEAM, isSaveAtServer = true,teamType = QTeamManager.NORMAL_TEAM, teamHandlerClass = "QTeamNormal"})
table.insert(teamConfig, {key = QTeamManager.METAL_CIRY_ATTACK_TEAM1, isSaveAtServer = false, teamType = QTeamManager.METAL_CITY_TEAM, teamHandlerClass = "QTeamMetalCity",teamTypeNum = 2,})
table.insert(teamConfig, {key = QTeamManager.METAL_CIRY_ATTACK_TEAM2, isSaveAtServer = false, teamType = QTeamManager.METAL_CITY_TEAM, teamHandlerClass = "QTeamMetalCity", teamTypeNum = 2,teamNum = 2})
table.insert(teamConfig, {key = QTeamManager.SOTO_TEAM_ATTACK_TEAM, isSaveAtServer = false, teamType = QTeamManager.ALTERNATE_TEAM, teamHandlerClass = "QTeamAlternate", isPVP = true})
table.insert(teamConfig, {key = QTeamManager.SOTO_TEAM_DEFEND_TEAM, isSaveAtServer = true, teamType = QTeamManager.ALTERNATE_TEAM, teamHandlerClass = "QTeamAlternate", isPVP = true}) 
table.insert(teamConfig, {key = QTeamManager.MOCK_BATTLE_TEAM, isSaveAtServer = true, teamType = QTeamManager.MOCK_TEAM, teamHandlerClass = "QTeamMock", isPVP = true})
table.insert(teamConfig, {key = QTeamManager.TOTEM_CHALLENGE_TEAM1, isSaveAtServer = false, teamType = QTeamManager.METAL_CITY_TEAM, teamHandlerClass = "QTeamStorm",teamTypeNum = 2,})
table.insert(teamConfig, {key = QTeamManager.TOTEM_CHALLENGE_TEAM2, isSaveAtServer = false, teamType = QTeamManager.METAL_CITY_TEAM, teamHandlerClass = "QTeamStorm", teamTypeNum = 2,teamNum = 2})
table.insert(teamConfig, {key = QTeamManager.MOCK_BATTLE_DOUBLE_TEAM1, isSaveAtServer = true, teamType = QTeamManager.MOCK_TEAM, teamHandlerClass = "QTeamMock", isPVP = true})
table.insert(teamConfig, {key = QTeamManager.MOCK_BATTLE_DOUBLE_TEAM2, isSaveAtServer = true, teamType = QTeamManager.MOCK_TEAM, teamHandlerClass = "QTeamMock", isPVP = true})
table.insert(teamConfig, {key = QTeamManager.SOUL_TOWER_BATTLE_TEAM, isSaveAtServer = false,teamType = QTeamManager.NORMAL_TEAM, teamHandlerClass = "QTeamNormal"})
table.insert(teamConfig, {key = QTeamManager.SILVES_ARENA_TEAM, isSaveAtServer = true,teamType = QTeamManager.NORMAL_TEAM, teamHandlerClass = "QTeamNormal", isPVP = true})
table.insert(teamConfig, {key = QTeamManager.MAZE_EXPLORE_TEAM, isSaveAtServer = false,teamType = QTeamManager.NORMAL_TEAM, teamHandlerClass = "QTeamNormal"})
table.insert(teamConfig, {key = QTeamManager.METAL_ABYSS_TEAM1, isSaveAtServer = false,teamType = QTeamManager.NORMAL_TEAM, teamHandlerClass = "QTeamMetalAbyss", teamTypeNum = 1,teamNum = 3, isPVP = true})
table.insert(teamConfig, {key = QTeamManager.METAL_ABYSS_TEAM2, isSaveAtServer = false,teamType = QTeamManager.NORMAL_TEAM, teamHandlerClass = "QTeamMetalAbyss", teamTypeNum = 2,teamNum = 3, isPVP = true})
table.insert(teamConfig, {key = QTeamManager.METAL_ABYSS_TEAM3, isSaveAtServer = false,teamType = QTeamManager.NORMAL_TEAM, teamHandlerClass = "QTeamMetalAbyss", teamTypeNum = 3,teamNum = 3, isPVP = true})

--[[
	name -玩法名称
	resIdx -icon QRES中sync_formation_icon_idx 的 索引id
	attack_keys  攻击阵容teamIdx 数组
	defence_keys  防守阵容teamIdx 数组
	checkTime  是否需要时间检测
	fontSize 文字颜色
]]
QTeamManager.teamSingleConfigs = {}	--单队玩法
table.insert(QTeamManager.teamSingleConfigs, {name ="副本"  
	-- , battleType = BattleTypeEnum.DUNGEON_NORMAL
	, resIdx = 1,attack_keys = {QTeamManager.INSTANCE_TEAM}})
table.insert(QTeamManager.teamSingleConfigs, {name ="斗魂场" ,unlock ="UNLOCK_ARENA"
	, battleType =BattleTypeEnum.ARENA, resIdx = 2
	, attack_keys= {QTeamManager.ARENA_ATTACK_TEAM} , defence_keys ={ QTeamManager.ARENA_DEFEND_TEAM} })
table.insert(QTeamManager.teamSingleConfigs, {name ="试炼宝屋" ,unlock ="UNLOCK_BPPTY_BAY", resIdx = 3
	, attack_keys = {QTeamManager.TIME_MACHINE_TEAM,QTeamManager.POWER_TEAM,QTeamManager.INTELLECT_TEAM} })
table.insert(QTeamManager.teamSingleConfigs, {name ="杀戮之都" ,unlock ="UNLOCK_THUNDER", resIdx = 4
	, attack_keys = {QTeamManager.THUNDER_TEAM} })
table.insert(QTeamManager.teamSingleConfigs, {name ="极北之地",isUnion = true  ,unlock ="UNLOCK_KF_YKZ"
	, battleType =BattleTypeEnum.KUAFU_MINE, resIdx = 5, checkTime = true 
	, attack_keys = {QTeamManager.PLUNDER_ATTACK_TEAM} , defence_keys ={ QTeamManager.PLUNDER_DEFEND_TEAM}})
table.insert(QTeamManager.teamSingleConfigs, {name ="宗门副本" ,isUnion = true , resIdx = 6, attack_keys = {QTeamManager.SOCIETYDUNGEON_ATTACK_TEAM} })
table.insert(QTeamManager.teamSingleConfigs, {name ="武魂争霸" ,isUnion = true ,unlock ="SOCIATY_DRAGON_FIGHT" , resIdx = 7
	, attack_keys = {QTeamManager.UNION_DRAGON_WAR_ATTACK_TEAM} })
table.insert(QTeamManager.teamSingleConfigs, {name ="魂兽入侵" ,unlock ="UNLOCK_FORTRESS",  resIdx = 8, attack_keys = {QTeamManager.INVASION_TEAM} })
table.insert(QTeamManager.teamSingleConfigs, {name ="魔鲸来袭" ,unlock ="UNLOCK_SHIJIEBOSS",  resIdx = 22, attack_keys = {QTeamManager.WORLDBOSS_TEAM} }) --shortcut_id nil
table.insert(QTeamManager.teamSingleConfigs, {name ="海神岛" ,unlock ="UNLOCK_SUNWELL",  resIdx = 9, attack_keys = {QTeamManager.SUNWAR_ATTACK_TEAM} }) -- ,QTeamManager.SUNWAR_ATTACK_SECOND_TEAM 第二队为零时阵容 不保存 
table.insert(QTeamManager.teamSingleConfigs, {name ="魂兽森林" ,unlock ="UNLOCK_SILVERMINE"
	, battleType = BattleTypeEnum.SILVER_MINE , resIdx = 10
	, attack_keys = {QTeamManager.SILVERMINE_ATTACK_TEAM} , defence_keys ={ QTeamManager.SILVERMINE_DEFEND_TEAM}})
table.insert(QTeamManager.teamSingleConfigs, {name ="大魂师赛" ,unlock ="UNLOCK_TOWER_OF_GLORY"
	, battleType = BattleTypeEnum.GLORY_TOWER , resIdx = 11
	, attack_keys = {QTeamManager.GLORY_TEAM} , defence_keys ={ QTeamManager.GLORY_DEFEND_TEAM}})
table.insert(QTeamManager.teamSingleConfigs, {name ="地狱杀戮场" ,unlock ="UNLOCK_FIGHT_CLUB"
	, battleType = BattleTypeEnum.FIGHT_CLUB , resIdx = 12 ,fontSize = 18
	, attack_keys = {QTeamManager.FIGHT_CLUB_ATTACK_TEAM} , defence_keys ={ QTeamManager.FIGHT_CLUB_DEFEND_TEAM}})
table.insert(QTeamManager.teamSingleConfigs, {name ="传灵塔" ,unlock ="UNLOCK_BLACKROCK" ,  resIdx = 13
, attack_keys = {QTeamManager.BLACK_ROCK_FRIST_TEAM} }) -- ,QTeamManager.BLACK_ROCK_SECOND_TEAM 第二队为零时阵容 不保存 
table.insert(QTeamManager.teamSingleConfigs, {name ="升灵台" ,unlock ="UNLOCK_SOUL_TOWER" ,  resIdx = 14
	, attack_keys = {QTeamManager.SOUL_TOWER_BATTLE_TEAM} })
table.insert(QTeamManager.teamSingleConfigs, {name ="西尔维斯" ,unlock ="UNLOCK_SILVES_ARENA"
	, battleType =BattleTypeEnum.SILVES_ARENA, resIdx = 15
	, defence_keys = {QTeamManager.SILVES_ARENA_TEAM}, checkTime = true , replay = true })
-- table.insert(teamSingleConfigs, {name ="魂力试炼" , attack_keys = {QTeamManager.INSTANCE_TEAM} })


QTeamManager.teamDoubleConfigs = {}	--双队玩法
table.insert(QTeamManager.teamDoubleConfigs, {name ="宗门战" ,isUnion = true ,unlock ="UNLOCK_CONSORTIA_WAR"
	, battleType =BattleTypeEnum.CONSORTIA_WAR, resIdx = 23
	, attack_keys = {QTeamManager.CONSORTIA_WAR_ATTACK_TEAM1,QTeamManager.CONSORTIA_WAR_ATTACK_TEAM2} 
	, defence_keys = {QTeamManager.CONSORTIA_WAR_DEFEND_TEAM1,QTeamManager.CONSORTIA_WAR_DEFEND_TEAM2}})
table.insert(QTeamManager.teamDoubleConfigs, {name ="全大陆精英赛" ,unlock ="UNLOCK_SANCTRUARY"
	, battleType =BattleTypeEnum.SANCTUARY_WAR, resIdx = 16,fontSize = 18
	, attack_keys = {QTeamManager.SANCTUARY_ATTACK_TEAM1,QTeamManager.SANCTUARY_ATTACK_TEAM2} 
	, defence_keys = {QTeamManager.SANCTUARY_DEFEND_TEAM1,QTeamManager.SANCTUARY_DEFEND_TEAM2} 
	, replay = true, checkTime = true})
table.insert(QTeamManager.teamDoubleConfigs, {name ="金属之城" ,unlock ="UNLOCK_METALCITY",  resIdx = 17
	, attack_keys = {QTeamManager.METAL_CIRY_ATTACK_TEAM1,QTeamManager.METAL_CIRY_ATTACK_TEAM2} })
table.insert(QTeamManager.teamDoubleConfigs, {name ="索托斗魂场" ,unlock ="UNLOCK_STORM_ARENA"
	, battleType =BattleTypeEnum.STORM, resIdx = 18,fontSize = 18
	, attack_keys = {QTeamManager.STORM_ARENA_ATTACK_TEAM1,QTeamManager.STORM_ARENA_ATTACK_TEAM2} 
	, defence_keys = {QTeamManager.STORM_ARENA_DEFEND_TEAM1,QTeamManager.STORM_ARENA_DEFEND_TEAM2}})
table.insert(QTeamManager.teamDoubleConfigs, {name ="圣柱挑战" ,unlock ="UNLOCK_SHENGZHUTIAOZHAN", resIdx = 19
	, attack_keys = {QTeamManager.TOTEM_CHALLENGE_TEAM1,QTeamManager.TOTEM_CHALLENGE_TEAM2} })
table.insert(QTeamManager.teamDoubleConfigs, {name ="仙品聚宝盆" ,unlock ="UNLOCK_MARITIME"
	, battleType =BattleTypeEnum.MARITIME, resIdx = 20,fontSize = 18
	, attack_keys = {QTeamManager.MARITIME_ATTACK_TEAM1,QTeamManager.MARITIME_ATTACK_TEAM2} 
	, defence_keys = {QTeamManager.MARITIME_DEFEND_TEAM1,QTeamManager.MARITIME_DEFEND_TEAM2}})

QTeamManager.teamSotoConfigs = {}	--单队玩法
table.insert(QTeamManager.teamSotoConfigs, {name ="云顶之战" ,unlock ="UNLOCK_SOTO_TEAM", battleType =BattleTypeEnum.SOTO_TEAM, resIdx = 21
	, attack_keys = {QTeamManager.SOTO_TEAM_ATTACK_TEAM} , defence_keys = {QTeamManager.SOTO_TEAM_DEFEND_TEAM}})

-- QTeamManager.teamConfig = teamConfig

function QTeamManager:ctor(options)
	QTeamManager.super.ctor(self)
	self._teams = {} --本地魂师数据
	self._initTempData = {}
	self._isInit = false
	self._flags = {}
	
end

--登陆之前初始化
function QTeamManager:didappear()
	for _,config in ipairs(teamConfig) do
		local handlerClassName = config.teamHandlerClass
		if handlerClassName == nil then 
			handlerClassName = "QTeamNormal"
		end
		local teamVO = import(app.packageRoot .. ".network.models.teams." ..handlerClassName).new({config = config})
		self._teams[config.key] = teamVO
	end

	self._proxy = cc.EventProxy.new(remote)
	self._proxy:addEventListener(remote.DUNGEON_UPDATE_EVENT, handler(self, self.initData))
end

function QTeamManager:disappear()
	if self._proxy ~= nil then
		self._proxy:removeAllEventListeners()
		self._proxy = nil
	end
end

function QTeamManager:initData()
	if self._proxy ~= nil then
		self._proxy:removeAllEventListeners()
		self._proxy = nil
	end
	for key,fomation in pairs(self._initTempData) do
        local teamVO = self:getTeamByKey(key)
        teamVO:setTeamDataWithBattleFormation(fomation)
	end
	self._initTempData = {}
	self._isInit = true
end

--在前面初始化的时候好像本地战队数据并没有加载完
function QTeamManager:loginEnd()
	for key,config in ipairs(teamConfig) do
		local teamVO = self:getTeamByKey(config.key, true)
		if teamVO:getIsDefense() == false then
			self:loadLocalTeam(teamVO:getTeamKey())
		end
	end
end

--检查所有战队阵容
function QTeamManager:checkTeam()
	for key,config in ipairs(teamConfig) do
		local teamVO = self:getTeamByKey(config.key, true)
		if teamVO:getIsDefense() == false then
			self:loadLocalTeam(teamVO:getTeamKey())
		end
	end
end

--[[
	通过TeamKey--检查战队阵容
]]
function QTeamManager:checkTeamByKey(teamKey)
	local teamVO = self._teams[teamKey]
	if teamVO then
		teamVO:checkTeam()
	end
end

--[[
	通过TeamKey获取战队数据类
]]
function QTeamManager:getTeamByKey(teamKey, isCheck)
	if isCheck ~= false then
		local teamVO = self._teams[teamKey]
		if teamVO then
			teamVO:checkTeam()
		end
	end
	return self._teams[teamKey]
end

--[[
	通过TeamKey和index获取战队的魂师数据
]]
function QTeamManager:getActorIdsByKey(teamKey, index)
	if index == nil then index = 1 end
	local teamVO = self:getTeamByKey(teamKey)
	if teamVO ~= nil then
		return teamVO:getTeamActorsByIndex(index)
	end
	return {}
end

--[[
	通过TeamKey和index获取战队的魂师数据
]]
function QTeamManager:getGodArmIdsByKey(teamKey, index)
	if index == nil then index = 1 end
	local teamVO = self:getTeamByKey(teamKey)
	if teamVO ~= nil then
		return teamVO:getTeamGodarmByIndex(index)
	end
	return {}
end

--[[
	通过TeamKey和index获取战队的技能数据
]]
function QTeamManager:getSkillByKey(teamKey, index)
	if index == nil then index = 1 end
	local teamVO = self:getTeamByKey(teamKey)
	if teamVO ~= nil then
		return teamVO:getTeamSkillByIndex(index)
	end
	return {}
end

--[[
	通过TeamKey和index获取战队的上阵精灵数据
]]
function QTeamManager:getSpiritIdsByKey(teamKey, index)
	if index == nil then index = 1 end
	local teamVO = self:getTeamByKey(teamKey)
	if teamVO ~= nil then
		return teamVO:getTeamSpiritsByIndex(index)
	end
	return {}
end

--[[
	通过TeamKey和index获取战队的上阵替补数据
]]
function QTeamManager:getAlternateIdsByKey(teamKey, index)
	if index == nil then index = 1 end
	local teamVO = self:getTeamByKey(teamKey)
	if teamVO ~= nil then
		return teamVO:getTeamAlternatesByIndex(index)
	end
	return {}
end

--更新战队的数据
function QTeamManager:updateTeamData(teamKey, teamData)
	local teamVO = self:getTeamByKey(teamKey, false)
	teamVO:setTeamData(teamData)
	if teamVO:getIsDefense() == false then
		self:saveTeamToLocal(teamVO, teamKey)
	end
end

--保存战队到本地
function QTeamManager:saveTeamToLocal(teamVO, teamKey)
	local teamData = teamVO:getAllTeam()
	local teamStr = self:teamToString(teamData)
	app:getUserData():setUserValueForKey(teamKey, teamStr)
end

--序列化战队
function QTeamManager:teamToString(team)
	if q.isEmpty(team) == false then
		return "version="..self.TEAM_VERSION..table.tostring(team)
	end
end

--加载本地战队
function QTeamManager:loadLocalTeam(teamKey)
	local teamStr = app:getUserData():getUserValueForKey(teamKey)
	local tbl = self:_stringToTeam(teamStr)
	local teamVO = self:getTeamByKey(teamKey, false)
	-- print("read local team", teamKey)
	-- printTable(tbl)
	if teamVO ~= nil then
		teamVO:setTeamData(tbl)
		teamVO:sortTeam()
	end
	return tbl
end

--清除本地战队
function QTeamManager:clearLocalTeam(teamKey)
	app:getUserData():setUserValueForKey(teamKey, "")
end

--清除缓存中的战队
function QTeamManager:clearCacheTeam(teamKey)
	local teamVO = self:getTeamByKey(teamKey, false)
	if teamVO ~= nil then
		teamVO:setTeamData({})
	end
end

--删除某个魂师从所有战队中
function QTeamManager:delHeroFromAllTeams(actorId)
	for key, teamVO in pairs(self._teams) do
		local maxIndex = teamVO:getTeamMaxIndex()
		for i=1,maxIndex do
			teamVO:delHeroByIndex(i, actorId)
			teamVO:delAssistHeroByIndex(i, actorId)
		end
	end
end

--删除某个精灵从所有战队中
function QTeamManager:delSpiritFromAllTeams(spiritId)
	for key, teamVO in pairs(self._teams) do
		local maxIndex = teamVO:getTeamMaxIndex()
		for i=1,maxIndex do
			teamVO:delElfByIndex(i, spiritId)
		end
	end
end

--检查某个精灵是否存在某个战队中
function QTeamManager:checkSpiritIsExistByTeamKey(spiritId, teamKeys)
	if teamKeys == nil then
		teamKeys = {}
		for _,config in ipairs(teamConfig) do
			if config.isSaveAtServer then
				table.insert(teamKeys, config.key)
			end
		end
	end
	for _,key in ipairs(teamKeys) do
		local teamVO = self._teams[key]
		if teamVO:containsSpirit(spiritId) then
			return true
		end
	end
	return false
end

--[[
	排序魂师列表
--]]
function QTeamManager:sortTeam(heros, isNeedCreatModel)
	self._isNeedCreatModel = isNeedCreatModel or false 
	if heros ~= nil and #heros > 1 then 
		table.sort(heros, handler(self,self._sortHero))
	end
end

--[[
	战力排序魂师列表
--]]
function QTeamManager:sortTeamByForce(heros)
	local sortTeamFunc = function(a, b)
		if a == nil and a == nil then 
			return false
		end
	 	local heroA, heroB
		if type(a) == "table" and type(b) == "table" then
			heroA = a
			heroB = b
		else
			heroA = remote.herosUtil:getHeroByID(a)
			heroB = remote.herosUtil:getHeroByID(b)
		end

		if heroA == nil and heroB == nil then 
			return a > b
		end
		if heroA == nil and heroB ~= nil then
			return false
		elseif heroA ~= nil and heroB == nil then
			return true
		end
		
		local forceA = app:createHeroWithoutCache(heroA):getBattleForce()
		local forceB = app:createHeroWithoutCache(heroB):getBattleForce()

		if forceA ~= forceB then
			return forceA > forceB
		else
			return false
		end
	end
	if heros ~= nil and #heros > 1 then 
		table.sort(heros, sortTeamFunc)
	end
end

--当没有设置阵容 返回一个默认整容
function QTeamManager:getDefaultTeam(teamKey)
	local teamVO = self:getTeamByKey(teamKey, false)
	return teamVO:getDefaultTeam()
end

--[[
	将战队信息组合成 BattleFormation 的格式
]]
function QTeamManager:encodeBattleFormation(team)
	local battleFormation = {}
	if team ~= nil then
		battleFormation.mainHeroIds = {}
		battleFormation.sub1HeroIds = {}
		battleFormation.sub2HeroIds = {}
		battleFormation.sub3HeroIds = {}
		battleFormation.soulSpiritId = {}

		battleFormation.activeSub1HeroId = 0
		battleFormation.activeSub2HeroId = 0
		battleFormation.activeSub3HeroId = 0
		-- battleFormation.soulSpiritId = 0
		battleFormation.alternateHeroIds = {}
		battleFormation.godArmIdList = {}

		if team[1] ~= nil then
			battleFormation.mainHeroIds = team[1].actorIds or {}
			battleFormation.alternateHeroIds = team[1].alternateIds or {}
			-- battleFormation.soulSpiritId = (team[1].spiritIds or {})[1] or 0
			battleFormation.soulSpiritId = team[1].spiritIds or {}
		end
		if team[2] ~= nil then
			battleFormation.sub1HeroIds = team[2].actorIds or {}
			if team[2].skill ~= nil then
				battleFormation.activeSub1HeroId = team[2].skill[1] or 0
				battleFormation.activeSub2HeroId = team[2].skill[2] or 0
			end
		end
		if team[3] ~= nil then
			battleFormation.sub2HeroIds = team[3].actorIds or {}
			if team[3].skill ~= nil then
				battleFormation.activeSub2HeroId = team[3].skill[1] or 0
			end
		end
		if team[4] ~= nil then
			battleFormation.sub3HeroIds = team[4].actorIds or {}
			if team[4].skill ~= nil then
				battleFormation.activeSub3HeroId = team[4].skill[1] or 0
			end
		end
		if team[5] ~= nil then
			battleFormation.godArmIdList = team[5].godarmIds or {}
		end
	end
	return battleFormation
end

--[[
	计算战力通过BattleFormation格式
]]
function QTeamManager:countBattleFormationForce(battleFormation)
	local force = 0
	local countHeroForce = function (heros)
		if heros ~= nil then
			for _,actorId in ipairs(heros) do
				local heroInfo = remote.herosUtil:getHeroByID(actorId)
				if not q.isEmpty(heroInfo) then
					force = force + heroInfo.force
				else
					isRemoveHero = true
				end
			end
		end
	end
	countHeroForce(battleFormation.mainHeroIds)
	countHeroForce(battleFormation.alternateIds)
	countHeroForce(battleFormation.sub1HeroIds)
	countHeroForce(battleFormation.sub2HeroIds)
	countHeroForce(battleFormation.sub3HeroIds)

	if battleFormation.soulSpiritId then
		local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(battleFormation.soulSpiritId)
		if soulSpiritInfo then
			force = force + (soulSpiritInfo.force or 0)
		end
	end
	return force
end

--[[
	获取某一个战队的战力
]]
function QTeamManager:getBattleForceForAllTeam(teamKey, isLocal, isPVP)
	local teamVO = self:getTeamByKey(teamKey, false)
	return teamVO:getTeamBattleForce(isLocal, isPVP)
end

--给指定部队添加相应属性并计算出战斗力增加与减少
function QTeamManager:getAddBuffTeamForce( helpTeam , prop ,extends_name)
	remote.herosUtil:removeExtendsProp(extends_name)
	local old_force = remote.herosUtil:countForceByHeros(helpTeam, true) 
	remote.herosUtil:addExtendsProp( prop, extends_name)
	local new_force = remote.herosUtil:countForceByHeros(helpTeam, true) 
	remote.herosUtil:removeExtendsProp( extends_name)
	local force = new_force - old_force
	return force
end


--[[
	检查某一个战队的魂师是否满员
]]
function QTeamManager:checkTeamIsFull(teamKey, index)
	if index == nil then index = 1 end
	local teamVO = self:getTeamByKey(teamKey, false)
	if teamVO:checkTeamIsFullByIndex(index) == false then
		return false
	end
	if teamVO:checkSpiritIsFullByIndex(index) == false then
		return false
	end
	if teamVO:checkAlternateIsFullByIndex(index) == false then
		return false
	end
	return true
end

--[[
	检查三小队战队是否满员
]]
function QTeamManager:checkTeamStormIsFull(teamKey)
	local teamVO = self:getTeamByKey(teamKey, false)
	local maxIndex = teamVO:getTeamMaxIndex()
	for i = 1, maxIndex do
		if teamVO:checkTeamIsFullByIndex(i) == false then
			return false
		end
		if teamVO:checkSpiritIsFullByIndex(i) == false then
			return false
		end
		if teamVO:checkAlternateIsFullByIndex(i) == false then
			return false
		end
	end

	return true
end

--[[
先设置好这里的数据等待loginEnd之后再来初始化
因为在登陆的时候副本阵容的数据跟着过来了，但是这个时候还没有初始化，因为副本的数据等信息没拉到，
本地的战队数据并没有初始化，而在初始化的时候又会清理掉线上发过来的数据，而且在设置数据的时候，
因为副本数据没有拉取到，无法判断是否解锁格子等信息，所以先放在这里存储一下，之后再初始化进去
]]

function QTeamManager:setInitTeamData(teamKey, initData)
	if self._isInit then
        local teamVO = self:getTeamByKey(teamKey)
        teamVO:setTeamDataWithBattleFormation(initData)
	else
		self._initTempData[teamKey] = initData
	end
end

-----------------------------援助位激活-----------------------------
function QTeamManager:setActiviteInfo(flag)
	self._flags = {}
	local index = 1
	while true do
		self._flags[index] = flag%2
		if flag >= 2 then
			flag = math.floor(flag/2)
			index = index + 1
		else
			break
		end
	end
	self:dispatchEvent({name = QTeamManager.ACTIVITE_POS})
end

function QTeamManager:getIsActiviteByPos(pos)
	return self._flags[pos] == 1
end

--请求激活援助位
function QTeamManager:heroHelpOpenRequest(position, success, fail)
	local heroHelpOpenRequest = {position = position}
    local request = {api = "HERO_HELPER_OPEN", heroHelpOpenRequest = heroHelpOpenRequest}
    app:getClient():requestPackageHandler("HERO_HELPER_OPEN", request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-----------------------------新手引导需要的---------------------------

--[[
	添加魂师到战队列表 新手引导
--]]
function QTeamManager:joinHero(heros, fragment)
	local herosTemp = {}
	local teamVO = self:getTeamByKey(QTeamManager.INSTANCE_TEAM)
	for _, actorId in pairs(heros) do
		if remote.herosUtil:getHeroByID(actorId) == nil then
			table.insert(herosTemp, actorId)
			if fragment == 0 then
				teamVO:addHeroByIndex(1, actorId)
			end
		end
	end
	self._joinHero = herosTemp
	self._joinHeroFragment = fragment
	self:saveTeamToLocal(teamVO, QTeamManager.INSTANCE_TEAM)
end

--[[
	解锁战队通过副本ID
]]
function QTeamManager:unlockTeamForDungeon(dungeonId)
	for i = 1, 2, 1 do
		local dungeonHero = QStaticDatabase:sharedDatabase():getDungeonHeroByIndex(i)
		if dungeonHero then
			local dungeonInfo = remote.instance:getDungeonById(dungeonHero.dungeon_id)
			if dungeonInfo.dungeon_id == dungeonId and remote.instance:checkIsPassByDungeonId(dungeonId) == false then
				dungeonInfo.info = {}
				self:joinHero({dungeonHero.hero_actor_id}, dungeonHero.fragment)
			end
		end
    end
end

--[[
	获取新手魂师 新手引导
	仅仅适用副本战队
--]]
function QTeamManager:getJoinHero()
	local heros = self._joinHero
	local fragment = self._joinHeroFragment
	-- self._joinHero = nil
	return heros, fragment
end

--[[
-- @xurui
	初始化新手魂师变量
--]]
function QTeamManager:initJoinHero()
	if self._joinHero ~= nil and self._joinHeroFragment == 1 then
		remote.herosUtil:removeHeroes(self._joinHero)
	end
	self._joinHero = nil
	self._joinHeroFragment = nil
	self._joinHeroInfo = nil
end

--[[
-- @xurui
	检查是不是不需要加入战队的新手魂师
--]]
function QTeamManager:checkIsNoNeedHero()
	-- 血蹄
	local hero1 = {
		actorId = 1004, 
		breakthrough = 2,
		level = 10,
		skills = {1, 2, 3}, -- 必须按照 普1、普2、手、其余技能的顺序填写
		rankCode = "R0",
		exp = 100
	}
	-- 莉莉娅
	local hero2 = {			
		actorId = 1003, 
		breakthrough = 0,
		level = 12,
		skills = {25, 26}, -- 必须按照 普1、普2、手、其余技能的顺序填写
		rankCode = "R0",
		exp = 100
	}
	if self._joinHero ~= nil and self._joinHeroFragment == 1 then
		if hero1.actorId == self._joinHero[1] then
			self._joinHeroInfo = hero1
		end
		if hero2.actorId == self._joinHero[1] then
			self._joinHeroInfo = hero2
		end
	end
end

-----------------------------private------------------------------
--反序列化战队
function QTeamManager:_stringToTeam(teamStr)
	if teamStr ~= nil then
		local version, index = string.gsub(teamStr, "version=([%d][%.][%d][%.][%d]).*", "%1")
		if index == 1 then
			teamStr = string.sub(teamStr, #("version="..version)+1)
			return self:_teamEncodeByVersion(version, teamStr)
		else
			return self:_teamEncodeByOld(teamStr)
		end
	end
	return {}
end

--根据版本来解析战队数据
function QTeamManager:_teamEncodeByVersion(version, teamStr)
	if version == "1.1.0" then
		return self:_teamEncodeByVersion1(teamStr)
	end
	return {}
end

--按照版本1来解析字符串
function QTeamManager:_teamEncodeByVersion1(teamStr)
	local f = loadstring("return " .. teamStr)
	if f ~= nil then
		return f()
	else
		return {}
	end
end

--最早的字符串拼接处理
function QTeamManager:_teamEncodeByOld(teamStr)
    if teamStr == nil then
        return {}
    end

    local arr1 = string.split(teamStr, "|")
    local tbl = {}
    for index,team in pairs(arr1) do
        if tbl[index] == nil then
            tbl[index] = {}
        end
        local arr2 = string.split(team, ";")
        for index2,actorId in pairs(arr2) do
            tbl[index][index2] = tonumber(actorId)
        end
    end
    local teamTbl = {}
    teamTbl[1] = {actorIds = tbl[1]}
    teamTbl[2] = {actorIds = tbl[2], skill = tbl[3]}
    teamTbl[3] = {actorIds = tbl[4], skill = tbl[5]}
    teamTbl[4] = {actorIds = tbl[6], skill = tbl[7]}
    return teamTbl
end


--职业（ T > 治疗 > DPS）> 等级 > 经验 > 创建时间
function QTeamManager:_sortHero(a,b)
	if a == nil or b == nil then
		return false
	end

	local heroA
	local heroB
	if type(a) == "table" and type(b) == "table" then
		heroA = a
		heroB = b
	else
		heroA = remote.herosUtil:getHeroByID(a)
		heroB = remote.herosUtil:getHeroByID(b)
	end
	if heroA == nil and heroB == nil then 
		return a > b
	end
	if heroA == nil and heroB ~= nil then
		return false
	elseif heroA ~= nil and heroB == nil then
		return true
	end
	local characherA = QStaticDatabase:sharedDatabase():getCharacterByID(heroA.actorId)
	local characherB = QStaticDatabase:sharedDatabase():getCharacterByID(heroB.actorId)
	if characherA == nil and characherB ~= nil then
		return false
	elseif characherB == nil and characherA ~= nil then
		return true
	end
	if characherA == nil and characherB == nil then
		return heroA.actorId < heroB.actorId
	end
	if characherA.hatred == nil or characherB.hatred == nil then
		return heroA.actorId < heroB.actorId
	end
	if characherA.hatred ~= characherB.hatred then
		return characherA.hatred < characherB.hatred
	end

	local forceA = 0
	local forceB = 0

	if self._isNeedCreatModel == true then
		forceA = app:createHeroWithoutCache(heroA):getBattleForce()
		forceB = app:createHeroWithoutCache(heroB):getBattleForce()
	else
		forceA = heroA.force
		forceB = heroB.force
	end
	if forceA ~= forceB then
		return forceA < forceB
	end
	if characherA.func == nil or characherB.func == nil then
		return heroA.actorId < heroB.actorId
	end
	if characherA.func ~= characherB.func then
		if characherA.func == 'health' then
			return true
		elseif characherB.func == 'health' then
			return false
		elseif characherA.func == 't' then
			return true
		elseif characherB.func == 't' then
			return false
		end
	end
	
	if characherA.attack_type == nil or characherB.attack_type == nil then
		return heroA.actorId < heroB.actorId
	end
	if characherA.attack_type ~= characherB.attack_type then
	  return  characherA.attack_type > characherB.attack_type
	end
	return heroA.actorId < heroB.actorId
end

-- 援助位subHeros排序 actorId1, actorId2, 其他actorId
function QTeamManager:sortSubHeros(subHeros, actorId1, actorId2)
	if not subHeros or next(subHeros) == nil then
		return {}
	end
	table.sort(subHeros, function(a, b)
			return a.actorId < b.actorId
		end)

	local heros = {}
	for i, hero in pairs(subHeros) do
		if actorId1 == hero.actorId then
			table.insert(heros, 1, hero)
		elseif actorId2 == hero.actorId then
			if heros[1] and heros[1].actorId == actorId1 then
				table.insert(heros, 2, hero)
			else
				table.insert(heros, 1, hero)
			end
		else
			table.insert(heros, hero)
		end
	end

	return heros
end

-- 援助位subActorIds排序 actorId1, actorId2, 其他actorId
function QTeamManager:sortSubActorIds(subActorIds, actorId1, actorId2)
	if not subActorIds or next(subActorIds) == nil then
		return {}
	end
	local actorIds = table.mapToArray(subActorIds)
	table.sort(actorIds, function(a, b)
			return a < b
		end)

	local heros = {}
	for i, actorId in pairs(actorIds) do
		if actorId1 == actorId then
			table.insert(heros, 1, actorId1)
		elseif actorId2 == actorId then
			if heros[1] and heros[1] == actorId1 then
				table.insert(heros, 2, actorId)
			else
				table.insert(heros, 1, actorId)
			end
		else
			table.insert(heros, actorId)
		end
	end
	return heros
end

-- 设置上阵顺序
function QTeamManager:setHeroUpOrder(index, selectOrder)
	if index == 1 then
		self._selectOrder1 = {}
		for i, actorId in pairs(selectOrder) do
			table.insert(self._selectOrder1, actorId)
		end
	else
		self._selectOrder2 = {}
		for i, actorId in pairs(selectOrder) do
			table.insert(self._selectOrder2, actorId)
		end
	end
end

-- 获取上阵顺序
function QTeamManager:getHeroUpOrder(index)
	local orders
	if index == 1 then
		orders = self._selectOrder1 or {}
	else
		orders = self._selectOrder2 or {}
	end
	return orders
end

-- 调整顺序
function QTeamManager:updateHeroOrder(index, actorId, isUp)
	local orders
	if index == 1 then
		orders = self._selectOrder1 or {}
	else
		orders = self._selectOrder2 or {}
	end

	-- 处理上下顺序
	for i, id in pairs(orders) do
		if id == actorId then
			table.remove(orders, i)
			break
		end
	end
	if isUp then
		table.insert(orders, actorId)
	end
end

function QTeamManager:getOtherTeamKey(teamKey)
	local length = string.len(teamKey)
	local teamName = string.sub(teamKey, 0, length-1)
	local teamNum = string.sub(teamKey, length)
	if teamNum == "1" then
		return teamName.."2"
	elseif teamNum == "2" then
		return teamName.."1"
	else
		return teamKey
	end
end

return QTeamManager