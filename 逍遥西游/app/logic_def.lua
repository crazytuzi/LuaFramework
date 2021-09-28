require("app.war.war_def")
WAR_CODE_IS_SERVER = false
ZUOQITYPE_BAIMA = 70001
ZUOQITYPE_LUOTUO = 70002
ZUOQITYPE_BAILANG = 70003
ZUOQITYPE_TUONIAO = 70004
ZUOQITYPE_DAXIANG = 70005
ZUOQITYPE_DUJIAOXIYI = 70006
ZUOQITYPE_PENHUONIU = 70007
ZUOQITYPE_QILIN = 70008
ZUOQITYPE_MINGQIAO = 70009
ZUOQITYPE_EMPTY6ZUOQI = 79999
All_6_ZUOQI_List = {
  ZUOQITYPE_PENHUONIU,
  ZUOQITYPE_QILIN,
  ZUOQITYPE_DUJIAOXIYI,
  ZUOQITYPE_MINGQIAO
}
DIRECTIOIN_UP = 1
DIRECTIOIN_RIGHTUP = 2
DIRECTIOIN_RIGHT = 3
DIRECTIOIN_RIGHTDOWN = 4
DIRECTIOIN_DOWN = 5
DIRECTIOIN_LEFTDOWN = 6
DIRECTIOIN_LEFT = 7
DIRECTIOIN_LEFTUP = 8
DIRECTIOIN_VECTOR = {
  [DIRECTIOIN_UP] = {0, 1},
  [DIRECTIOIN_RIGHTUP] = {1, 1},
  [DIRECTIOIN_RIGHT] = {1, 0},
  [DIRECTIOIN_RIGHTDOWN] = {1, -1},
  [DIRECTIOIN_DOWN] = {0, -1},
  [DIRECTIOIN_LEFTDOWN] = {-1, -1},
  [DIRECTIOIN_LEFT] = {-1, 0},
  [DIRECTIOIN_LEFTUP] = {-1, 1}
}
DIRECTIOIN_FOR_USEWAR = {
  [DIRECTIOIN_UP] = DIRECTIOIN_LEFTUP,
  [DIRECTIOIN_RIGHTUP] = DIRECTIOIN_LEFTUP,
  [DIRECTIOIN_RIGHT] = DIRECTIOIN_RIGHTDOWN,
  [DIRECTIOIN_RIGHTDOWN] = DIRECTIOIN_RIGHTDOWN,
  [DIRECTIOIN_DOWN] = DIRECTIOIN_RIGHTDOWN,
  [DIRECTIOIN_LEFTDOWN] = DIRECTIOIN_RIGHTDOWN,
  [DIRECTIOIN_LEFT] = DIRECTIOIN_RIGHTDOWN,
  [DIRECTIOIN_LEFTUP] = DIRECTIOIN_LEFTUP
}
TELEPOINT_2_MAP_DICT = {
  [108] = {
    305,
    306,
    307
  },
  [114] = {
    301,
    302,
    303,
    304
  },
  [115] = {
    308,
    309,
    310,
    311
  }
}
FOLLOW_DIS = 60
FOLLOW_DIS_DETECT_TIMES = 4
FOLLOW_DETECT_FINDROUTE = FOLLOW_DIS + 20
FOLLOWCAPTAIN_DIS_HOLD = (FOLLOW_DIS - 15) * (FOLLOW_DIS - 15)
local d = FOLLOW_DIS
local sin_45 = math.pow(2, 0.5) / 2
local d_opp_angle = sin_45 * d
FOLLOW_DELTA_DIS = {
  [DIRECTIOIN_UP] = {
    0,
    -d
  },
  [DIRECTIOIN_RIGHTUP] = {
    -d_opp_angle,
    -d_opp_angle
  },
  [DIRECTIOIN_RIGHT] = {
    -d,
    0
  },
  [DIRECTIOIN_RIGHTDOWN] = {
    -d_opp_angle,
    d_opp_angle
  },
  [DIRECTIOIN_DOWN] = {0, d},
  [DIRECTIOIN_LEFTDOWN] = {d_opp_angle, d_opp_angle},
  [DIRECTIOIN_LEFT] = {d, 0},
  [DIRECTIOIN_LEFTUP] = {
    d_opp_angle,
    -d_opp_angle
  }
}
ROLE_STATE_STAND = "stand"
ROLE_STATE_WALK = "walk"
ZUOQIRACE_ALL = 0
Role_SpecialID_RandomNPC = -3
Role_SpecialID_Partner = -2
Role_SpecialID_Screen = -1
Role_SpecialID_NpcBtn = 0
Role_SpecialID_Player = 1
Role_SpecialID_Partner = -2
Role_SpecialID_Shimen = 2
MissionKind_Divisor = 10000
MissionKind_Main = 1
MissionKind_Branch = 2
MissionKind_Shimen = 3
MissionKind_Faction = 4
MissionKind_Activity = 5
MissionKind_Jingying = 6
MissionKind_Guide = 7
MissionKind_Shilian = 8
MissionKind_SanJieLiLian = 9
MissionKind_Jiehun = 10
MissionKind_Jieqi = 11
MissionKind_JieRi = 12
MissionKind_JieBai = 13
MissionKind_ShiTu = 14
MissionKind_Couple = 99
Mission_Recommend = 100
Mission_Recommend_Kinds = {
  MissionKind_Activity,
  MissionKind_Shimen,
  MissionKind_Faction,
  MissionKind_Guide,
  MissionKind_SanJieLiLian,
  MissionKind_Jiehun,
  MissionKind_Jieqi,
  MissionKind_JieBai,
  MissionKind_ShiTu
}
MissionSortType = {
  [MissionKind_Main] = 2,
  [MissionKind_Guide] = 3,
  [MissionKind_Faction] = 4,
  [MissionKind_Shimen] = 5,
  [MissionKind_Activity] = 6,
  [MissionKind_Jingying] = 7,
  [MissionKind_Shilian] = 8,
  [MissionKind_Branch] = 9
}
MissionType_TalkNpc = 101
MissionType_GotoMap = 102
MissionType_War = 201
MissionType_CollectInWar = 202
MissionType_KillInWar = 203
MissionType_GuideInWar = 204
MissionType_WarWithMapMonster = 208
MissionType_WarForObjWithMonster = 209
MissionType_GetObjByNpc = 301
MissionType_UseObjInMap = 401
MissionType_GiveObjToNpc = 402
MissionType_Guide = 501
MissionType_ZhuaGui = 601
MissionType_GuiWang = 602
MissionType_TBSJ = 603
MissionType_XiuLuo = 604
MissionType_TianDiQiShu = 605
MMissionType_MiTan = 606
MissionType_BaoHuGuangGun = 607
MissionType_TMZZBaoMing = 608
MissionType_DuoBaoQiBing = 609
MissionType_YaBiao = 610
MissionType_MoJieFengYin = 611
MissionType_Tianing = 702
MissionType_ShiMenZC = 705
MissionType_SanJieLiLian = 801
MissionType_SanJieLiLianS = 802
MissionType_SanJieLiLianA = 803
MissionType_SanJieLiLianG = 804
MissionType_BangPaiTotem = 901
MissionType_BangPaiChuMo = 906
MissionType_BangPaiAnZhan = 907
MissionType_JiehunDati = 1001
MissionType_JiehunSjzf = 1002
MissionType_JiehunJiaoqian = 1003
MissionType_JieqiLingqi = 1101
MissionType_JieqiJiaoqian = 1002
MissionType_QingYuanJTH = 1004
MissionType_QingYuanJS = 1005
MissionType_QingYuanXYQ = 1006
MissionType_JieRiCommonFight = 1201
MissionType_JieRiCommonTeamFight = 1202
MissionType_JieRiCommonZhiShu = 1203
MissionType_JieRiCommonSummit = 1204
MissionType_BPRunTask_AnZhan = 1301
MissionType_BPRunTask_QieCuo = 1302
MissionType_BPRunTask_XunLuo = 1303
MissionType_BPRunTask_ChuJian = 1304
MissionType_JieBai = 1401
MissionType_ShiTu_War = 1501
MissionType_ShiTu_DaTi = 1502
ZhuaGui_MissionId = 50001
ZhuaGui_MaxCircle = 10
DaTingCangBaoTu_MissionId = 50004
DaTingCangBaoTu_MaxCircle = 10
TBSJ_MissionId = 50005
TBSJ_MaxCircle = 9
ExchangeMissionId = 50002
GuiWang_MissionId = 50003
GuiWang_MaxCircle = 10
XiuLuo_MissionId = 50006
XiuLuo_MaxCircle = 10
DaTingCangBaoTu_MissionId = 50004
DaTingCangBaoTu_MaxCircle = 10
TBSJ_MissionId = 50005
TBSJ_MaxCircle = 9
BHGG_MissionId = 50007
BHGG_MaxCircle = 20
YuanDan_MissionId_start = 56001
YuanDan_MissionId_fu = 56002
YuanDan_MissionId_lu = 56003
YuanDan_MissionId_shou = 56004
YuanDan_MissionId_end = 56005
TMZZBaoMing_MissionId = 55001
Totem_MissionId = 40001
Exorcism_MissionId = 40002
Business_MissionId = 40003
TaskToken_MuJi_MissionId = 40004
TaskToken_AnZhan_MissionId = 40005
TaskToken_ChuMo_MissionId = 40006
ShoujiZhufu_MissionId = 100003
BpMiTan_MissionId = 54001
DuoBaoQingBing_Nor_MissionId = 57001
YaBiao_MissionId = 58001
JieBai_MissionId = 130001
JieBai_DailiMissionId = 130002
MoJieFengYin_MissionId = 59001
KuaFuMissionDir = {
  [ZhuaGui_MissionId] = 1,
  [GuiWang_MissionId] = 1,
  [XiuLuo_MissionId] = 1
}
TASKTOKEN_MUJI = 1
TASKTOKEN_ANZHAN = 2
TASKTOKEN_CHUMO = 3
GuideId_Shimen = 103
GuideId_Skill = 104
GuideId_Zhuagui = 105
GuideId_Zuoqi = 106
GuideId_Biwu = 107
GuideId_Tianting = 108
GuideId_Dayanta = 109
GuideId_setHeroPro = 110
GuideId_ManagePet = 111
GuideId_UpgradeEquipe = 112
GuideId_Lianhua = 113
GuideId_GetPet = 114
GuideId_GetMate = 115
GuideId_Dazao = 116
GuideId_Xiangqian = 117
GuideId_SanJieLiLian = 118
GuideId_ShengHuoJiNeng = 119
GuideId_DuJie = 120
GuideId_DuoBaoQiBing = 121
GuideId_TianFu = 122
GuideId_JieBai = 123
GuideId_ZhuangYuanUpgrade = 124
GuideId_CombineFabao = 125
GuideId_NeedUpdateDetect = {
  [GuideId_GetPet] = 1,
  [GuideId_Zuoqi] = 1,
  [GuideId_GetMate] = 1
}
Fuben_Teleporter_Id = 19999
NPC_QINGUANGWANG_ID = 90899
NPC_BAIJINGJING_ID = 90900
NPC_FUBEN_ID = 90001
NPC_TIEJIANG_ID = 90002
NPC_FUZHANGSHANGREN_ID = 90003
NPC_XUNYANGSHI_ID = 90004
NPC_YIZHANCHEFU_ID = 90005
NPC_XUNSHOULAOWENG_ID = 90006
NPC_ZHUAGUIZHONGKUI_ID = 90007
NPC_LONGWANG_ID = 90010
NPC_GUIWANG_ID = 90011
NPC_BangPaiShiYe_ID = 90019
NPC_BangPaiShangRen_ID = 90020
NPC_HuangChengShouJiang_ID = 90025
NPC_LingShouXian_ID = 90302
NPC_DUYUANCHANSHI_ID = 90901
NPC_SUNPOPO_ID = 90902
NPC_ZHENYUANDASHI_ID = 90903
NPC_GUANYIN_ID = 90904
NPC_NIUMOWANG_ID = 90905
NPC_QINXIAXIANZI_ID = 90906
NPC_ZIXIAXIANZI_ID = 90907
NPC_ZHAHUOSHANG_ID = 90908
NPC_CHENXIAOJIN_ID = 90909
NPC_YAODIANLAOBAN_ID = 90910
NPC_TANGSENG_ID = 90911
NPC_CHENGONGZI_ID = 90912
NPC_CUNMING_ID = 90913
NPC_ZUOFANGZONGGUAN_ID = 90914
NPC_JIUGUANLAOBAN_ID = 90915
NPC_HongNiang_ID = 90983
NPC_RanSeShi_ID = 95079
NPC_XiuLuo_ID = 90035
NPC_ShenKuiGongZi_ID = 95080
NPC_TianShuLaoRen_ID = 90037
NPC_ChangEXianZi_ID = 90034
NPC_DuECanShi_ID = 95121
NPC_SUNSIMIAO_ID = 90973
NPC_DaNanGua_ID = 95122
NPC_ZhiXinDaJieJie_ID = 95123
NPC_BangPaiHuFa_ID = 90039
NPC_LiJing_ID = 90303
NPC_BPLeader_ID = 95185
NPC__ShengDanShu_ID = 95124
NPC__ShengDanXiongMao_ID = 95125
NPC_DuoBaoQiBing_ID = 95187
NPC_SiChouShangRen_ID = 90040
NPC_DuoBaoQiBing_ID = 95187
NPC_ChuMiLaoRen_ID = 95129
NPC_YanHuaShiZe_ID = 95134
NPC_ShenLong_ID = 95186
NPC_ShuXianZi_ID = 95135
NPC_RaoSheDaRen_ID = 95140
NPC_ChaSheLaoBan_ID = 95139
NPC_YuCunZhangZhe_ID = 95137
NPC_XuYuanShu_ID = 95141
NPC_TaoHuaXianZi_ID = 95136
NPC_ShenShouXianZi_ID = 90026
NPC_ChangAnZhuBu_ID = 90041
NPC_Market_ID = 90024
NPC_TuDiGong_ID = 90943
NPC_YuCunXiaoNVHai_ID = 95240
NPC_YuCunXiaoNanHai_ID = 95241
NPC_YuCunCunZhang_ID = 95242
NPC_YuCunCunChangGe_ID = 95243
NPC_ShiGuangTongZi_ID = 95244
NPC_ShiGuangLaoRen_ID = 95247
NPC_ZongXiaoXian_ID = 95249
NPC_ZhouNianQing_ID = 95251
NPC_STJGuanYuan_ID = 90042
NPC_STJZhShi_ID = 90043
NPC_MoJieFengYin_ID = 95254
NPC_PetLuanDou_ID = 95255
NPC_YunYouShangRen = 95264
Shimen_NPCId = {
  [RACE_REN] = {
    [HERO_MALE] = NPC_DUYUANCHANSHI_ID,
    [HERO_FEMALE] = NPC_SUNPOPO_ID
  },
  [RACE_XIAN] = {
    [HERO_MALE] = NPC_ZHENYUANDASHI_ID,
    [HERO_FEMALE] = NPC_GUANYIN_ID
  },
  [RACE_MO] = {
    [HERO_MALE] = NPC_NIUMOWANG_ID,
    [HERO_FEMALE] = NPC_QINXIAXIANZI_ID
  },
  [RACE_GUI] = {
    [HERO_MALE] = NPC_QINGUANGWANG_ID,
    [HERO_FEMALE] = NPC_BAIJINGJING_ID
  }
}
Eqpt_Upgrade_CreateType = 1
Eqpt_Upgrade_LianhuaType = 2
Eqpt_Upgrade_ChonglianType = 3
Eqpt_Upgrade_QianghuaType = 4
BoxResultType_Normal = 1
BoxResultType_Super = 2
BoxResultType_NormalTen = 3
BoxResultType_SuperTen = 4
JiuGuanResult_snyy = 1
JiuGuanResult_bnyy = 2
JiuGuanResult_qnyy = 3
JiuGuanResult_Ten = 4
ITEM_LARGE_TYPE_SENIOREQPT_MinLv = 1
ITEM_LARGE_TYPE_SENIOREQPT_MaxLv = 2
ITEM_LARGE_TYPE_XIANQI_MaxLv = 8
ITEM_LARGE_TYPE_SHENBING_MaxLv = 5
ITEM_LARGE_TYPE_HUOBANEQPT_CANCHONGZHU = 3
ITEM_CHIBANG_MaxLv = 5
BoxOpenType_Item = 1
BoxOpenType_Pet = 2
BoxOpenType_Res = 3
BoxOpenType_Hero = 4
BoxOpenType_Fabao = 5
MapPosType_Grid = 1
MapPosType_EditorGrid = 2
MapPosType_PixelPos = 3
NpcTouchOpenView_MinDis = 64
NpcTouchOpenView_MaxDis = 200
UpdateRoleForMap_Width_Half = 715
UpdateRoleForMap_Height_Half = 535
ServerMapRankSize = {1440, 1080}
ServermapBlockSize = {
  ServerMapRankSize[1] / 3,
  ServerMapRankSize[2] / 3
}
PackageAllPosNum = 192
PackageLockPage = 6
CanExpandMaxGridNum = 112
CangKuLockPage = 2
MissionPro_NotAccept = -1
MissionPro_0 = 0
MissionPro_1 = 1
MissionPro_2 = 2
RESTYPE_COIN = 1
RESTYPE_GOLD = 2
RESTYPE_EXP = 3
RESTYPE_CHENGJIU = 4
RESTYPE_TILI = 5
RESTYPE_Honour = 6
RESTYPE_SILVER = 7
RESTYPE_BPCONSTRUCT = 8
RESTYPE_HUOLI = 9
RESTYPE_BAOSHIDU = 10
RESTYPE_XIAYI = 11
RESTYPE_GONGJI = 12
RESTYPE_VIPExp = 13
RESTYPE_GoldWithVIP = 14
RESTYPE_ZhuangYuanJiFen = 15
RESTYPE_ZhuangYuanMuCai = 16
RESTYPE_LingQi = 17
RESTYPE_ShiDeDian = 18
RESTYPE_QingYuan = 19
RESTYPELIST = {
  RESTYPE_COIN,
  RESTYPE_GOLD,
  RESTYPE_EXP,
  RESTYPE_CHENGJIU,
  RESTYPE_TILI,
  RESTYPE_Honour,
  RESTYPE_SILVER,
  RESTYPE_BPCONSTRUCT,
  RESTYPE_HUOLI,
  RESTYPE_BAOSHIDU,
  RESTYPE_XIAYI,
  RESTYPE_GONGJI,
  RESTYPE_VIPExp,
  RESTYPE_GoldWithVIP,
  RESTYPE_ZhuangYuanJiFen,
  RESTYPE_ZhuangYuanMuCai,
  RESTYPE_LingQi,
  RESTYPE_ShiDeDian,
  RESTYPE_QingYuan
}
RESNameDict = {
  [RESTYPE_COIN] = "铜币",
  [RESTYPE_GOLD] = "仙玉",
  [RESTYPE_EXP] = "经验",
  [RESTYPE_CHENGJIU] = "帮派成就点",
  [RESTYPE_TILI] = "体力",
  [RESTYPE_Honour] = "荣誉",
  [RESTYPE_SILVER] = "银币",
  [RESTYPE_BPCONSTRUCT] = "帮派贡献",
  [RESTYPE_HUOLI] = "活力",
  [RESTYPE_BAOSHIDU] = "饱食度",
  [RESTYPE_XIAYI] = "侠义值",
  [RESTYPE_GONGJI] = "帮派功绩",
  [RESTYPE_VIPExp] = "VIP经验",
  [RESTYPE_GoldWithVIP] = "仙玉",
  [RESTYPE_ZhuangYuanJiFen] = "庄园积分",
  [RESTYPE_ZhuangYuanMuCai] = "庄园木材",
  [RESTYPE_LingQi] = "灵气",
  [RESTYPE_ShiDeDian] = "师德点",
  [RESTYPE_QingYuan] = "情缘值"
}
REST_GET_NUM_FUNC_NAME = {
  [RESTYPE_COIN] = "getCoin",
  [RESTYPE_GOLD] = "getGold",
  [RESTYPE_CHENGJIU] = "getArch",
  [RESTYPE_TILI] = "getTili",
  [RESTYPE_SILVER] = "getSilver",
  [RESTYPE_BPCONSTRUCT] = "getBpConstruct",
  [RESTYPE_BAOSHIDU] = "getLifeSkillBSD",
  [RESTYPE_XIAYI] = "getXiaYiNum",
  [RESTYPE_LingQi] = "getLingQi",
  [RESTYPE_QingYuan] = "getQingYuan"
}
PET_ATTRTIPKEY_CONVERT = {
  PDEFEND = "PET_PDEFEND",
  KFENG = "PET_KFENG",
  KHUO = "PET_KHUO",
  KSHUI = "PET_KSHUI",
  KLEI = "PET_KLEI",
  KHUNLUAN = "PET_KHUNLUAN",
  KFENGYIN = "PET_KFENGYIN",
  KHUNSHUI = "PET_KHUNSHUI",
  KZHONGDU = "PET_KZHONGDU",
  KSHUAIRUO = "PET_KSHUAIRUO",
  KXIXUE = "PET_KXIXUE",
  KGUIHUO = "PET_KGUIHUO",
  KYIWANG = "PET_KYIWANG",
  KZHENSHE = "PET_KZHENSHE"
}
SBD_POINT_MAX_VALUE = 120
TILI_VALUE_NORMAL_FUBEN = 6
TILI_VALUE_SUPER_FUBEN = 12
TILI_VALUE_LIMIT = 120
TILI_VALUE_MAX = 500
TILI_VALUE_BUYNUM = 120
RESET_CATCH_NEEDGOLD = 20
AwardPromptType_Mission = 1
AwardPromptType_ShowInWar = 2
AwardPromptType_NotShowInWar = 3
MapId_DongHaiYuCun = 1
MapId_Changan = 2
MapId_YiZhanDaoDi = 15
MapId_XueZhanShaChang = 16
MapId_DuelMap = 17
MapGrid_Size = 32
MapId_TianDiQiShuMap = 18
MapId_BangPaiMap = 20
MapId_BangPaiTanMiMap = 21
MapId_TianMingZhiZhanMapA = 22
MapId_TianMingZhiZhanMapB = 23
MapId_BangPaiWarMap = 200
MapId_CaiQuan = 25
MapId_NvErGuo = 7
Month_Chinese = {
  "一",
  "二",
  "三",
  "四",
  "五",
  "六",
  "七",
  "八",
  "九",
  "十",
  "十一",
  "十二"
}
TEAMCAPTAIN_NO = 0
TEAMCAPTAIN_YES = 1
TEAMSTATE_LEAVE = 0
TEAMSTATE_FOLLOW = 1
TEAMSTATUS_ONLINE = 0
TEAMSTATUS_OUTLINE = 1
RACENAME_DICT = {
  [RACE_REN] = "人族",
  [RACE_MO] = "魔族",
  [RACE_XIAN] = "仙族",
  [RACE_GUI] = "鬼族"
}
GAMESTATUS_OUTLINE = 0
GAMESTATUS_ONLINE = 1
CHECKINSTATUS_CANACCEPT = 1
CHECKINSTATUS_BASEACCEPTED = 2
CHECKINSTATUS_HADACCEPTALL = 3
RE_CHECKIN_COST = 10
PROMULGATETEAM_LEVELSPACE = 30
MapMonsterType_Zhuagui = 1
MapMonsterType_Precious = 2
MapMonsterType_Mission = 3
MapMonsterType_Dayanta = 4
MapMonsterType_Tianing = 5
MapMonsterType_GuiWang = 6
MapMonsterType_Totem = 7
MapMonsterType_ChuMo = 8
MapMonsterType_AnZhan = 9
MapMonsterType_xingxiu = 10
MapMonsterType_GuanKa = 11
MapMonsterType_XiuLuo = 12
MapMonsterType_TiandiQiShu = 13
MapMonsterType_shituchangan = 14
MapMonsterType_BaoHuGuangGun = 15
MapMonsterType_BangPaiJiaoFei = 16
MapMonsterType_TMZZBaoMing = 17
MapMonsterType_DuoBaoQingBing = 18
MapMonsterType_GeniusFight = 19
MapMonsterType_BaoWeiXinChun = 20
MapMonsterType_CommonFestival = 21
MapMonsterType_BPRunTask = 22
MapMonsterType_JieBaiTask = 23
MapMonsterType_CommonMapMonster = 24
MapMonsterType_TIANGANG = 25
MapMonsterType_ERTONGJIE = 26
MapMonsterType_MoJieFengYin_Boss = 27
MapMonsterType_MoJieFengYin_little = 28
KejuType_None = 0
KejuType_1 = 1
KejuType_2 = 2
KejuType_3 = 3
OPEN_FUNC_Type_Hide = 0
OPEN_FUNC_Type_Gray = 1
OPEN_Func_Zhaohuanshou = 2
OPEN_Func_Jiuguan = 4
OPEN_Func_Beibao = 5
OPEN_Func_Xinjian = 6
OPEN_Func_Guanqia = 7
OPEN_Func_Shejiao = 8
OPEN_Func_Duiwu = 9
OPEN_Func_Biwu = 10
OPEN_Func_Huodong = 11
OPEN_Func_Chongzhi = 12
OPEN_Func_Shangcheng = 13
OPEN_Func_Zuoqi = 14
OPEN_Func_Shaofa = 15
OPEN_Func_Keju = 16
OPEN_Func_Zhuagui = 18
OPEN_Func_SaoDang = 21
OPEN_Func_JingYing = 22
OPEN_Func_DoubleExp = 23
OPEN_Func_EqptUpgrade = 24
OPEN_Func_Market = 25
OPEN_Func_Guiwang = 26
OPEN_Func_SanJieLiLian = 27
OPEN_Func_BangPai = 28
OPEN_Func_Rank = 29
OPEN_Func_XunYang = 30
OPEN_Func_LifeSkill = 31
OPEN_Func_TTHJ = 32
OPEN_Func_CangBaoTu = 33
OPEN_Func_WorldChat = 34
OPEN_Func_RolePoint = 35
OPEN_Func_Friend = 36
OPEN_Func_FestivalGift = 37
OPEN_Func_LocalChat = 38
OPEN_Func_HuoLi = 41
OPEN_Func_XiuLuo = 42
OPEN_Func_XiaoLaBa = 43
OPEN_Func_TianDiQiShu = 44
OPEN_Func_Genius = 45
OPEN_Func_ZhuangYuan = 46
OPEN_Func_FaBao = 47
OPEN_Func_RoleZhuangShi = 48
Skill_AddSkill_Normal = 1
Skill_AddSkill_Marry = 2
PETLV_HEROLV_MAXDEL = 8
MAX_JIUGUAN_FRIEND_HERO_NUM = 15
MAX_PACKAGE_NUM = 80
MAX_CANGKU_NUM = 120
MAX_PACKAGE_MAINHERO_NUM = 192
Gold_ExChange_COIN = 10000
Gold_ExChange_SILVER = 100
AccountType_Unknown = 0
AccountType_Nmg = 1
AccountType_Guest = 2
AccountType_Momo = 3
AccountType_Channel = 4
ServerStatus_Full = 1
ServerStatus_Recommend = 2
ServerStatus_New = 3
PromulgateTeamTarget_ZhuaGui = 1
PromulgateTeamTarget_DYT = 2
PromulgateTeamTarget_TianTing = 3
PromulgateTeamTarget_GuiWang = 4
PromulgateTeamTarget_BangPai = 6
PromulgateTeamTarget_YZDD = 13
PromulgateTeamTarget_ZXJQ = 11
PromulgateTeamTarget_TBSJ = 12
PromulgateTeamTarget_XZSC = 15
PromulgateTeamTarget_XiuLuo = 16
KuaFuPromulgateTeamTarget = {
  [PromulgateTeamTarget_ZhuaGui] = 1,
  [PromulgateTeamTarget_GuiWang] = 1,
  [PromulgateTeamTarget_XiuLuo] = 1
}
RouteType_Npc = 1
RouteType_Monster = 2
RouteType_Mission = 3
RouteType_BPWarItem = 4
BattlAward_LowestRanking = 6000
DontJumpMapRouteType = {
  [RouteType_Npc] = 1,
  [RouteType_Monster] = 1,
  [RouteType_Mission] = 1
}
SyncPlayerType_Max = 1
SyncPlayerType_Middle = 2
SyncPlayerType_Min = 3
SyncPlayerNumWithMinType = 0
SyncPlayerNumWithMiddleType = 15
SpecialShapeId_LocalPlayer = 100
SpecialShapeId_ShengDanXM = 30016
DailyActivityEventItem_ID = 10025
