--RelationConstant.lua
--/*-----------------------------------------------------------------
 --* Module:  RelationConstant.lua
 --* Author:  seezon
 --* Modified: 2014年4月21日
 --* Purpose: 好友常量定义
 -------------------------------------------------------------------*/

FRIENDNUM = 30
ENEMYNUM = 30
BLACKNUM = 30
MEETNUM = 30
RECORDMAXNUM = 20
RECOMMENDNUM = 15
SUCCESS = 0

RELATION_REALFRIEND_REWARDID = 2276

FLOWERRECORDNUM2DB = 5
CANGIVEFLOWERDAILY = 5	--玩家每天可赠花次数
FLOWER_SEND_NUM = 1
RELATIONACTIVELEVEL = g_configMgr:getNewFuncLevel(9)	--开启等级
--赠花方式
GiveFlowerStye = {
	style1 = 1, --消耗金币1000获得10真气
	style2 = 2, --消耗9元宝获得30真气
	style3 = 3, --消耗99元宝获得99真气
    style4 = 4, --消耗880元宝获得 声望
}

--处理礼物类型
DealGiftType = {
	gift = 1, --赠送
	pickGift = 2, --领取礼物
}


RelationKind = {
    Friend = 1,     --好友
    Enemy = 2,      --仇敌
    Black = 3,      --黑名单
	Meet = 4,      --熟人
	Near = 5,      --附近人
}

NotifyType = {
    Kill = 1,     --杀普通人
    Bekill = 2,      --被杀
    KillBOSS = 3,      --杀BOSS
	KillEnemy = 4,      --杀仇敌
}


--------------RELATION_TIPS---------------
RELATION_ERR_FRIEND_EXSIT = -1	--好友已经存在了
RELATION_ERR_ENEMY_EXSIT = -2	--仇敌已经存在了
RELATION_ERR_BLACK_EXSIT = -3	--对象存在黑名单，不能添加
RELATION_ERR_TARGET_OFFLINE = -4	--目标不存在或不在线
RELATION_ERR_FRIEND_ENOUGH = -5	--好友已达30个，不能添加了
RELATION_ERR_ENEMY_ENOUGH = -6	--【XXX】将您击败，仇人数量已达30，记录仇人列表失败
RELATION_ERR_BLACK_ENOUGH = -7	--黑名单已达30个，不能添加了

RELATION_ERR_NO_GIVE_TIME = -8	--剩余赠花次数为0
RELATION_ERR_HAVE_GIVE = -9	--该玩家已经赠送过花了
RELATION_ERR_MONEY_NOT_ENOUGH = -10	--玩家选择的赠花方式钱不够
RELATION_ERR_FRIEND_ONLINE = -11	--您的好友【XXX】上线了
RELATION_ERR_ENEMY_ONLINE = -12	--您的仇敌【XXX】上线了

RELATION_ERR_FRIEND_KILL = -13 --您的好友【XXX】在【XXX】地图击败了玩家【XXX】
RELATION_ERR_ENEMY_KILL = -14 --您的仇人【XXX】在【XXX】地图击败了玩家【XXX】
RELATION_ERR_KILL_ENEMY1 = -15 --您将仇敌【XXX】击败
RELATION_ERR_KILL_ENEMY2 = -16 --您战胜了仇敌【XXX】。
RELATION_ERR_KILL_ENEMY3 = -17 --您的仇敌【XXX】被您击杀多次，做人不要太绝啊！
RELATION_ERR_KILL_ENEMY4 = -18 --您的仇敌【XXX】的实力太弱了，建议你高台贵手留一条活路！
RELATION_ERR_KILL_ENEMY5 = -19 --求求您饶过仇敌【XXX】吧！
RELATION_ERR_BEKILL_BY_ENEMY1 = -20 -- 仇敌【XXX】将你击败
RELATION_ERR_BEKILL_BY_ENEMY2 = -21 --仇敌【XXX】将你斩杀。
RELATION_ERR_BEKILL_BY_ENEMY3 = -22 --您又被仇敌【XXX】杀了，快去报仇吧。
RELATION_ERR_BEKILL_BY_ENEMY4 = -23 --你弱爆了已经被仇敌【XXX】，斩杀多次，快提升实力一雪前耻吧！
RELATION_ERR_BEKILL_BY_ENEMY5 = -24 --你被仇敌【XXX】杀爆了快逃吧！
RELATION_ERR_FRIEND_BEKILL = -25 --您的好友【XXX】被【XXX】在【XXX地图】击败了
RELATION_ERR_ENEMY_BEKILL = -26 --您的仇人【XXX】被【XXX】在【XXX地图】击败了

RELATION_ERR_ADD_ENEMY = -30 --【XXX】将您击败，已记录仇人列表
RELATION_ERR_BEGIVE_FLOWER = -31  --【XXX】赠送您【X】朵花
RELATION_ERR_GOTO_LIMIT = -32  --传送功能只能10秒一次
RELATION_ERR_QUERY_LIMIT = -33  --查询功能只能10S秒次
RELATION_ERR_YUANBAO_NOT_ENOUGH = -34  --所需元宝不足
RELATION_ERR_BINDYUANBAO_NOT_ENOUGH = -35  --所需绑定元宝不足
RELATION_ERR_LEVEL_NOT_ENOUGH = -36  --没到好友系统激活等级
RELATION_ERR_ADD_SELF = -37  --不能添加自己
RELATION_ERR_GOTO_JINGJI = -38  --不能传送竞技场
RELATION_ERR_GOTO_COPY = -39  --不能传送副本

RELATION_ERR_ADD_FRIEND_SUCCESS = -40 --添加好友【XXX】成功
RELATION_ERR_ADD_BLACK_SUCCESS = -41 --添加黑名单【XXX】成功
RELATION_ERR_GIVE_FLOWER_SUCCESS = -42 --给玩家【XXX】送花成功
RELATION_ERR_REMOVE_FRIEND = -43 --删除好友【XXX】成功
RELATION_ERR_REMOVE_ENEMY = -44 --删除仇敌【XXX】成功
RELATION_ERR_REMOVE_BLACK = -45 --删除黑名单【XXX】成功
RELATION_ERR_BE_ADD_FRIEND = -46 --【XXX】增加您为好友

RELATION_ERR_GOTO_GUAJI = -47  --不能传送元神挂机地图
RELATION_ERR_ADD_OFF_RELATION = -48  --离线添加关系

RELATION_ERR_FRIEND_DELETE = -49  --您的好友已删除角色
RELATION_ERR_ENEMY_DELETE = -50  --仇敌删除角色
RELATION_ERR_BLACK_DELETE = -51  --黑名单删除角色
RELATION_ERR_GIVE_FLOWER_SELF = -52	--不能赠花给自己
RELATION_ERR_ADD_OFF_BLACK = -53  --离线添加黑名单
RELATION_ERR_BE_ADD_BLACK = -54  --【XXX】将你拉入黑名单
RELATION_ERR_KILL = -55  --你战胜了【XXX】
RELATION_ERR_BE_KILL = -56  --【XXX】击败了你
RELATION_ERR_BE_SEND_FLOWER = -57 		-- XXX送了XX朵花给你
RELATION_ERR_NO_PLAYER = -59  --该玩家不存在
RELATION_ERR_GAIN_BY_GIFT = -60  --领取奖励成功，获得金币%s
RELATION_ERR_GIVE_FLOWER_SUCCESS_2 = -61 --给玩家【XXX】送浓情玫瑰成功
RELATION_ERR_BEGIVE_FLOWER_2 = -62 		--【XXX】赠送您【X】朵浓情玫瑰
RELATION_ERR_BE_SEND_FLOWER_2 = -63 		-- XXX送了XX朵浓情玫瑰给你

RELATION_ADD_FRIEND_MSG = '勇士,天大地大,今后你我一心,同去同归!'
--------------RELATION_TIPS---------------