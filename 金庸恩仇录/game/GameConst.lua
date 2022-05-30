if device.platform == "windows" or device.platform == "mac" then
	GAME_DEBUG = true
end
USE_NAME_REXUE = false
ENABLE_HUASHAN_SHOP = true
ENABLE_DAILY_TASK = true
ENABLE_GAME_WORKS = false
ENABLE_ZHENRONG = true
ENABLE_IAP_BUY = true
ENABLE_LUNJIAN = true
ENABLE_WORLDBOSS = true
ENABLE_KUAFU = false
NO_MUSIC = false
SHOW_MASK_LAYER = false
SHOW_TUTO_SKIP = false
ENABLE_NUQI = true
ENABLE_SHENTONG = true
ENABLE_YUEQIAN = true
ENABLE_RECHARGE = true
ENABLE_DENGJITOUZI = true
ENABLE_CHEAT = false
ENABLE_GUILD = true
GAME_TUTO_SKIP = false
GAME_APPSTORE_VERIFY = true
MppUI = require("utility.MppUI")
ResMgr = require("utility.ResMgr")
TutoMgr = require("game.Tutorial.TutoMgr")
DramaMgr = require("game.Drama.DramaMgr")
OpenCheck = require("game.OpenSystem.OpenCheck")
RewardLayerMgr = require("utility.RewardLayerMgr")
ModelMgr = require("game.model.ModelMgr")
DEVICE_TYPE = {
HIGH = 1,
MEDIUM = 2,
LOW = 3
}
NORMAL_FUBEN = 1
JINGYING_FUBEN = 2
HUODONG_FUBEN = 3
ARENA_FUBEN = 4
DUOBAO_FUBEN = 5
DRAMA_FUBEN = 6
WORLDBOSS_FUBEN = 7
LUNJIAN = 8
GUILD_QLBOSS_FUBEN = 9
GUILD_FUBEN = 10
FRIEND_PK = 11
ZHENSHEN_FUBEN = 12
KUAFU_ZHAN = 13
GUILD_BATTLE_WALL_BOSS = 14
GUILD_BATTLE_WALL_FIGHT = 15
GAME_STATE = {
STATE_NONE = 0,
STATE_LOGO = 1,
STATE_MAIN_MENU = 2,
STATE_ZHENRONG = 3,
STATE_FUBEN = 4,
STATE_HUODONG = 5,
STATE_BEIBAO = 6,
STATE_SHOP = 7,
STATE_HEROS = 8,
STATE_EQUIPMENT = 9,
STATE_JINGMAI = 10,
STATE_FRIENDS = 11,
STATE_SETTING = 12,
STATE_LIANHUALU = 13,
STATE_JINGYUAN = 14,
STATE_XIAKE = 15,
STATE_JIANGHULU = 16,
STATE_TIAOZHAN = 17,
STATE_ARENA = 18,
STATE_ARENA_BATTLE = 19,
STATE_JINGYING_BATTLE = 20,
STATE_DUOBAO = 21,
STATE_DUOBAO_BATTLE = 22,
STATE_JINGCAI_HUODONG = 23,
STATE_MAIL = 24,
STATE_NORMAL_BATTLE = 25,
STATE_HUODONG_BATTLE = 26,
STATE_JINGMAI = 27,
STATE_SUBMAP = 28,
STATE_LOGIN = 29,
STATE_VERSIONCHECK = 30,
DRAMA_SCENE = 31,
DRAMA_BATTLE = 32,
STATE_WORLD_BOSS_NORMAL = 33,
STATE_WORLD_BOSS = 34,
STATE_HUASHAN = 35,
STATE_HANDBOOK = 36,
STATE_GUILD = 37,
STATE_GUILD_GUILDLIST = 38,
STATE_GUILD_MAINSCENE = 39,
STATE_GUILD_ALLMEMBER = 40,
STATE_GUILD_VERIFY = 41,
STATE_GUILD_DADIAN = 42,
STATE_GUILD_DYNAMIC = 43,
STATE_HUASHAN_SHOP = 44,
STATE_BIWU = 45,
STATE_BIWU_BATTLE = 46,
STATE_GUILD_QL_BOSS = 47,
STATE_RANK_SCENE = 48,
STATE_GUILD_SHOP = 49,
STATE_YABIAO_SCENE = 50,
STATE_YABIAO_BATTLE_SCENE = 51,
STATE_GUILD_FUBEN = 52,
STATE_FRIEND_PK = 53,
STATE_CULIAN_MAIN = 54,
STATE_BATTLE_FISRT = 55,
STATE_PET = 56,
STATE_KUAFU_MAIN = 57,
STATE_GUILD_BATTLE = 58,
STATE_MIJI = 59,
STATE_CHUANGDANG = 60,
STATE_HANDBOOK_CHEATS = 61,
STATE_HANDBOOK_PET = 62
}
G_BOTTOM_BTN = {
GAME_STATE.STATE_MAIN_MENU,
GAME_STATE.STATE_ZHENRONG,
GAME_STATE.STATE_FUBEN,
GAME_STATE.STATE_HUODONG,
GAME_STATE.STATE_BEIBAO,
GAME_STATE.STATE_SHOP
}

G_BOTTOM_BTN_NAME ={
"mainSceneBtn",
"formSettingBtn",
"battleBtn",
"activityBtn",
"bagBtn",
"shopBtn"
}

local ccs = ccs or {}
ccs.MovementEventType = {
START = 0,
COMPLETE = 1,
LOOP_COMPLETE = 2
}
MAIN_MENU_SUBMENU = {
XIAKE = 20,
ZHUANGBEI = 21,
JINGMAI = 22,
FRIEND = 23,
CHAT = 24,
SETTING = 25,
BAG = 26,
SHOP = 27
}
BOX_ZORDER = {
BASE = 100,
MIN = 200,
MED = 500,
MAX = 1000
}
CCB_TAG = {
mm_shouye = "tag_shouye",
mm_zhenrong = "tag_zhenrong",
mm_fuben = "tag_fuben",
mm_huodong = "tag_huodong",
mm_beibao = "tag_beibao",
mm_shop = "tag_shop"
}
CCB_PLAYER_INFO = {
mm_name = "info_box",
mm_lv = "tag_lv",
mm_vip = "tag_vip",
mm_silver = "tag_silver",
mm_gold = "tag_gold",
mm_tili = "tag_tili",
mm_tili_bar = "tag_tili_bar",
mm_naili = "tag_naili",
mm_zhanli = "tag_zhanli",
mm_exp = "tag_exp",
label_vip = "label_vip",
label_zhanli = "label_zhanli",
label_tili = "label_tili",
label_naili = "label_naili",
label_exp = "label_exp",
label_silver = "label_silver",
label_gold = "label_gold"
}
MM_TAG = {
mm_xiake = "tag_xiake",
mm_equip = "tag_equip",
mm_jingmai = "tag_jingmai",
mm_friend = "tag_friend",
mm_chat = "tag_chat",
mm_setting = "tag_setting",
mm_tiaozhan = "tag_tiaozhan"
}

IMAGE_PLIST_PATH = {
bigmap = {
"bigmap/bigmap.png",
"bigmap/bigmap.plist"
},
submap = {
"ui/ui_submap.png",
"ui/ui_submap.plist"
}
}

FONTS_NAME = {
font_haibao = "fonts/FZCuYuan-M03S.ttf",
font_fzcy = "fonts/FZCuYuan-M03S.ttf",
font_time = "fonts/font_time.fnt",
font_vip = "fonts/font_vip.fnt",
font_zhanli = "fonts/font_zhanli.fnt",
font_property = "fonts/font_property.fnt",
font_btns = "fonts/font_buttons.fnt",
font_zhaojiang = "fonts/font_zhaojiang.fnt",
font_battle_round = "fonts/font_battle_round.fnt",
font_title = "fonts/font_title.fnt"
}

FONT_COLOR = {
WHITE = cc.c3b(255, 255, 255),
BLACK = cc.c3b(0, 0, 0),
GREEN = cc.c3b(0, 255, 0),
GREEN_1 = cc.c3b(0, 228, 48),
BLUE = cc.c3b(0, 168, 255),
PURPLE = cc.c3b(192, 0, 255),
ORANGE = cc.c3b(255, 165, 0),
YELLOW = cc.c3b(255, 252, 0),
RED = cc.c3b(221, 0, 0),
LIGHT_ORANGE = cc.c3b(237, 188, 119),
GRAY = cc.c3b(100, 100, 100),
LIGHT_GREEN = cc.c3b(0, 255, 186),
RED_GRAY = cc.c3b(192, 172, 164),
DARK_RED = cc.c3b(126, 0, 0),
BLOOD_RED = cc.c3b(130, 13, 0),
TITLE_COLOR = cc.c3b(150, 255, 0),
TITLE_OUTLINECOLOR = cc.c3b(4, 75, 0),
PLAYER_NAME = cc.c3b(160, 229, 228),
COIN_SILVER = cc.c3b(255, 255, 255),
COIN_GOLD = cc.c3b(255, 210, 0),
COMMON_FONT_COLOR = cc.c3b(110, 0, 0),
NOTE_TITLE = cc.c3b(255, 228, 0),
NOTE_TITLE_OUTLINE = cc.c3b(85, 1, 0),
NOTE_TEXT = cc.c3b(110, 0, 0),
LEVEL_NAME = cc.c3b(255, 246, 0)
}

NAME_COLOR = {
cc.c3b(141, 141, 141),
FONT_COLOR.GREEN_1,
cc.c3b(0, 146, 238),
FONT_COLOR.PURPLE,
cc.c3b(224, 169, 0),
cc.c3b(224, 169, 0)
--cc.c3b(205, 38, 38)
}

NAME_COLOR_HEX = {
"#8d8d8d",
"#00e430",
"#0092ee",
"#c000ff",
"#e0a900"
}
QUALITY_COLOR = {
[1] = ccc3(141, 141, 141),
[2] = FONT_COLOR.GREEN,
[3] = ccc3(0, 146, 238),
[4] = FONT_COLOR.PURPLE,
[5] = ccc3(224, 169, 0)
}
QUALITY_COLOR_HEX = {
"#8d8d8d",
"#00e430",
"#0092ee",
"#c000ff",
"#e0a900"
}

ARENA_SHOP_TYPE = 1
HUASHAN_SHOP_TYPE = 2
ENUM_GUILD_SHOP_TYPE = 3
CREDIT_SHOP_TYPE = 4
ENUM_KUAFU_SHOP_TYPE = 5
ENUM_GUILDBATTLE_SHOP_TYPE = 6
BIWU_SHOP_TYPE = 7
XIANSHI_SHOP_TYPE = 8
ZHENQIDAN_EXCHANGE_TYPE = 9

NoticeKey = {
MainMenuScene_Update = "MainMenuScene_Update",
MAINSCENE_HIDE_BOTTOM_LAYER = "MAINSCENE_HIDE_BOTTOM_LAYER",
MAINSCENE_SHOW_BOTTOM_LAYER = "MAINSCENE_SHOW_BOTTOM_LAYER",
SpiritUpgradeScene_UpdateExpBar = "SpiritUpgradeScene_UpdateExpBar",
CommonUpdate_Label_Silver = "CommonUpdate_Label_Silver",
CommonUpdate_Label_Gold = "CommonUpdate_Label_Gold",
CommonUpdate_Label_Tili = "CommonUpdate_Label_Tili",
CommonUpdate_Label_Naili = "CommonUpdate_Label_Naili",
CommonUpdate_PAY_RESULT = "CommonUpdatePayResult",
ArenaRestTime = "ArenaRestTime",
SwitchArenaTimeType = "SwitchArenaTimeType",
BROADCAST_SHOW_PLAYERGETHERO = "Broadcast_show_playerGetHero",
BROADCAST_SHOW_HEROLEVELUP = "Broadcast_show_heroLevelUp",
MainMenuScene_OnlineReward = "MainMenuScene_OnlineReward",
MainMenuScene_RewardCenter = "MainMenuScene_RewardCenter",
MainMenuScene_ChengZhangZhilu = "MainMenuScene_ChengZhangZhilu",
MainMenuScene_KaifuLibao = "MainMenuScene_KaifuLibao",
MainMenuScene_DengjiLibao = "MainMenuScene_DengjiLibao",
MainMenuScene_Qiandao = "MainMenuScene_Qiandao",
BottomLayer_Chouka = "BottomLayer_Chouka",
BottomLayer_JiangHu = "BottomLayer_JiangHu",
BottomLayer_ZhenRong = "BottomLayer_ZhenRong",
MainMenuScene_chatNewNum = "MainMenuScene_chatNewNum",
MainMenuScene_challenge = "MainMenuScene_challenge",
MainMenuScene_Music = "MainMenuScene_Music",
MainMenuScene_UrgencyBroadcast = "MainMenuScene_UrgencyBroadcast",
MainMenuScene_Shouchong = "MainMenuScene_Shouchong",
MainMenuScene_kaifukuanghuan = "MainMenuScene_kaifukuanghuan",
MainMenuScene_xiakes = "MainMenuScene_xiakes",
MainMenuScene_equipments = "MainMenuScene_equipments",
MainMenuScene_pet = "MainMenuScene_pet",
BIWu_update_naili = "BIWu_update_naili",
BIWu_update_Title_on = "BIWu_update_Title_on",
BIWu_update_Title_off = "BIWu_update_Title_off",
Yabiao_repair_enemy = "Yabiao_repair_enemy",
Yabiao_run_car = "Yabiao_run_car",
REMOVE_TUTOLAYER = "REMOVE_TUTOLAYER",
REMOVE_MASKLAYER = "REMOVE_MASKLAYER",
REV_TUTO_MASK = "REV_TUTO_MASK",
REV_BEF_TUTO_MASK = "REV_BEF_TUTO_MASK",
LOCK_TABLEVIEW = "LOCK_TABLEVIEW",
UNLOCK_TABLEVIEW = "UNLOCK_TABLEVIEW",
LOCK_BOTTOM = "LOCK_BOTTOM",
UNLOCK_BOTTOM = "UNLOCK_BOTTOM",
MAIL_TIP_UPDATE = "mail_tip_update",
GUILD_UPDATE_ZIJIAN = "guild_update_zijian",
UPDATE_FRIEND = "UPDATE_FRIEND",
UPDATE_GUILDFULI_TIME = "update_guildFuli_time",
UP_FRIEND_ICON_ACT = "UP_FRIEND_ICON_ACT",
UPDATE_GUILD_MAINSCENE_MSG_DATA = "UPDATE_GUILD_MAINSCENE_MSG_DATA",
UPDATE_GUILD_MAINSCENE_BUILD_LEVEL = "UPDATE_GUILD_MAINSCENE_BUILD_LEVEL",
CHECK_GUILD_APPLY_NUM = "CHECK_GUILD_APPLY_NUM",
CHECK_IS_SHOW_APPLY_NOTICE = "CHECK_IS_SHOW_APPLY_NOTICE",
APP_ENTER_FOREGROUND_EVENT_IN_GAME = "APP_ENTER_FOREGROUND_EVENT_IN_GAME",
}
local test = {
__index = function(k)
	dump("=======================")
	dump("=======================")
	dump("==============卧槽=========")
	dump("=======================")
	dump(k)
	dump(k)
end
}
setmetatable(NoticeKey, test)
LIAN_HUA_TYEP = {
HERO = 1,
EQUIP = 2,
SKILL = 3,
PET = 4,
SHIZHUANG = 5,
CHEATS = 6
}
BASE_PROP_MAPPPING = {
31,
32,
33,
34,
77,
78
}
EQUIP_BASE_PROP_MAPPPING = {
21,
22,
23,
24,
77,
78
}
OPENCHECK_TYPE = {
DengJiLiBao = 1,
QianDao = 2,
JiYing_FuBen = 3,
ShenMiShangDian = 4,
LianJuaLu = 5,
QunxiaLu = 6,
JunTuan = 7,
JingMai = 8,
HuoDong_FuBen = 9,
XiLian = 10,
MeiRi_RenWu = 11,
ZhenQi = 12,
ChongWu = 13,
ZhenRong = 14,
XiaoHuoBan = 15,
JingJiChang = 16,
DuoBao = 17,
NeiWaiGong_JingLian = 18,
ZhenRong_XiTong = 19,
XiaKe_JinJie = 20,
ShenTong = 21,
ZhaoMu_XiaKe = 22,
ZhuangBei_QiangHua = 23,
ZhenQi_XiTong = 24,
ShenMi_Shop = 25,
Tiaoguo_NormalFuben = 26,
LianShici_Zhenqi = 27,
WorldBoss_AutoBattle = 28,
Chat_Touxiang = 29,
Tiaoguo_HuodongFuben = 30,
JiefuJipin = 31,
XingxiaZhangyi = 32,
ChubaoAnliang = 33,
ShilianZhan_FuBen = 34,
Tiaoguo_JingyingFuben = 35,
Tiaoguo_HuashanLunjian = 36,
HuashanLunjian = 37,
DengjiTouzi_buy = 38,
Mail = 39,
Guild = 40,
LimitHero = 41,
BiWu = 42,
DailyTask = 43,
RANK_LIST = 44,
YABIAO = 45,
TanBao = 46,
WaBao = 47,
SHOP = 48,
Tiaoguo_guildFuben = 49,
ZHUANGBEICULIAN = 51,
QIANGHUADASHI = 52,
TianJiangMengChong = 54,
Diaoyu = 55,
ZhenShen_FuBen = 56,
KuaFuZhan = 57,
Zhenqi_ZhuanHuan = 58,
Tiaoguo_ZhenShenFuben = 59,
Fashion = 60,
ZhuZhen = 61,
Cheats = 62,
ChuangDang = 63,
CheatsOpen = 64
}
DRAMA_ZORDER = 13000
BEF_MASK_ZORDER = 11000
TUTO_MASK_ZORDER = 12000
MASK_LAYER_ZORDER = 10000000
OPENCHECK_ICON_NAME = {
{
1,
"#toplayer_dengjilibao.png"
},
{
1,
"#toplayer_qiandao.png"
},
{
2,
"#b3_tiaozhan.png"
},
{0, ""},
{
2,
"#b2_lianhualu.png"
},
{
2,
"#b2_qunxialu.png"
},
{0, ""},
{
2,
"#b2_jingmai.png"
},
{
2,
"#b3_tiaozhan.png"
},
{
2,
"#b2_equip.png"
},
{0, ""},
{
2,
"#b2_jingyuan.png"
},
{
2,
"#b2_pet.png"
},
{
3,
"#bl_zhenrong_up.png"
},
{0, ""},
{
10,
"ui/ui_huodong/ui_huodong_jingjichang.jpg"
},
{
10,
"ui/ui_huodong/ui_huodong_duobao.jpg"
},
{
3,
"#bl_beibao_up.png"
},
{
3,
"#bl_zhenrong_up.png"
},
{
2,
"#b2_hero.png"
},
{
2,
"#b2_hero.png"
},
{
3,
"#bl_shop_up.png"
},
{
2,
"#b2_equip.png"
},
{
2,
"#b2_jingyuan.png"
},
{
4,
"#nbhuodong_shenmiShop.png"
},
{},
{},
{},
{},
{},
{
10,
"ui/ui_huodong_fb/hd_fb_jiefujipin.png"
},
{
10,
"ui/ui_huodong_fb/hd_fb_xingxiazhangyi.png"
},
{
10,
"ui/ui_huodong_fb/hd_fb_chubaoanliang.png"
},
{},
{},
{},
{
10,
"ui/ui_huodong/ui_huodong_lunjian.jpg"
},
{},
{},
{},
{},
{
10,
"ui/ui_huodong/ui_huodong_biwu.jpg"
},
{
1,
"#toplayer_chengzhang.png"
}
}
SFX_NAME = {
u_guanbi = "u_guanbi",
u_yeqian = "u_yeqian",
u_queding = "u_queding",
u_shengli = "u_shengli",
u_shibai = "u_shibai",
u_shengji = "u_shengji",
u_qianghua = "u_qianghua",
u_jinglianfeixing = "u_jinglianfeixing",
u_xiakeqianghua = "u_xiakeqianghua",
u_xiakejingjie = "u_xiakejingjie",
u_duobaohecheng = "u_duobaohecheng",
u_lianhualu = "u_lianhualu",
u_zhaomu = "u_zhaomu",
u_zhaomushi = "u_zhaomushi",
u_jianghulu = "u_jianghulu",
u_qianghuachenggong = "u_qianghuachenggong",
u_fanpai = "u_fanpai",
u_caiquan_fanpai = "u_caiquan_fanpai",
u_caiquanshengli = "u_caiquanshengli",
u_caiquanshibai = "u_caiquanshibai",
u_duobaohecheng1 = "u_duobaohecheng1",
u_shilianchouchuxian = "u_shilianchouchuxian",
u_shilianchoufanzhuan = "u_shilianchoufanzhuan"
}
BAG_TYPE = {
zhuangbei = 1,
shizhuang = 2,
zhuangbei_suipian = 3,
wuxue = 4,
canhun = 5,
zhenqi = 6,
daoju = 7,
xiake = 8,
neigong_suipian = 9,
waigong_suipian = 10,
chongwu = 12,
chongwu_suipian = 13,
lipin = 14,
cheats = 15,
cheats_suipian = 16
}
ITEM_TYPE = {
zhuangbei = 1,
shizhuang = 2,
zhuangbei_suipian = 3,
wuxue = 4,
canhun = 5,
zhenqi = 6,
daoju = 7,
xiake = 8,
neigong_suipian = 9,
waigong_suipian = 10,
lipin = 11,
cailiao = 12,
chongwu_suipian = 13,
chongwu = 14,
zhenshen = 15,
cheats = 17,
xinfa_suipian = 18,
juexue_suipian = 19
}
nbActivityShowType = {
VipShouchong = 1,
VipFuli = 2,
MonthCard = 3,
VipLibao = 4,
KeZhan = 5,
CaiQuan = 6,
ShenMi = 7,
LeijiLogin = 8,
Yueqian = 9,
DengjiTouzi = 10,
LimitHero = 11,
DialyActivity = 12,
xianshiDuiHuan = 13,
huanggongTanBao = 14,
migongWaBao = 15,
xianshiShop = 16,
chongzhihuikui = 17,
tuanGousai = 18,
chongzhiqiandao = 19,
creditShop = 20,
chongwuchouka = 21,
luckyPool = 22,
diaoyu = 23
}
QuickAccess = {
SLEEP = 1,
BOSS = 2,
LIMITCARD = 3,
CAIQUAN = 4,
GUILD_BOSS = 5,
GUILD_BBQ = 6,
YABIAO = 7,
TANBAO = 8,
WABAO = 9,
SHOP = 10,
CREDIT_SHOP = 11,
LUCKY_POOL = 12,
DIAOYU_ACT = 13
}
APPOPEN_STATE = {close = 0, open = 1}
RewardLayerMgrType = {
chat = 1,
dailyLogin = 2,
kaifuReward = 3,
levelReward = 4,
onlineReward = 5,
rewardCenter = 6,
dailyTask = 7,
chatGuild = 8
}
CHAT_TYPE_TOTAL = 5
CHAT_TYPE = {
world = 1,
private = 2,
guild = 3,
gm = 4,
friend = 5
}
KUANGHUAN_TYPE = {
KAIFU = 0,
HEFU = 1,
CHUNJIE = 2
}
CHALLENGE_TYPE = {
JINGYING_VIEW = 1,
HUODONG_VIEW = 2,
ZHENSHEN_VIEW = 3
}
HEROINFOLAYER_FROM = {FROM_NORMAL = 1, FROM_ZHENWEI = 2}
HelpLineDesType = {
HPType = 1,
AttackType = 2,
DefType = 3
}
FormSettingType = {
HuaShanType = 1,
KuaFuZhanType = 2,
BangPaiZhanType = 3,
BangPaiFuBenType = 4,
HuoDongFuBenType = 5,
ZhenShenFuBenType = 6
}
HERO_STATE = {
unselected = -1,
selected = 1,
hasJoined = 3,
zhuzhen = 4
}

POS_SHIZHUANG = 16

TUTO_ZORDER = 999999
GAMENOTE_ZORDER = TUTO_ZORDER + 1
MonthCardTYPE = 2000
SECRETKEY = "asfasfasasdsadf"
ENCODESIGN = "=QP="