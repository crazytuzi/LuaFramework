--VipConst.lua

-- vip特权类型
-- 1   战斗跳过无等待时间，类型值=0
-- 2   武将突破消耗银两减少X%，类型值=X，百分比，配100就是免费，配50就是减少50%。
-- 3   洗练X次资格开启，X=5 X=10，只做2种
-- 4   装备强化+2几率X%，类型值=X，百分比，填50就是增加50%。
-- 5   装备强化+3几率X%，类型值=X，百分比，填50就是增加50%。
-- 6   宝物精炼消耗银两减少X%，类型值=X，百分比，配100就是免费，配50就是减少50%。
-- 7   主线副本每日可以重置X次，类型值=X，配1就是每天可以重置1次，配10就是每天可以重置10次。
-- 8   闯关每日可以重置X次，类型值=X，配1就是每天可以重置1次，配10就是每天可以重置10次。
-- 9   攻略剧情副本时，引用一个加生命的passiveskill,类型值=id
-- 10  攻略剧情副本时，引用一个加攻击的passiveskill,类型值=id
-- 11  每日可以购买出征令的次数=X，配置5就是每天可以购买5次，配置100就是每天可以购买100次。
-- 12  神秘商店每日可以刷新X次，配置5就是每天可以刷新5次，配置10就是每天可以刷新10次，每日0点（暂定）重置。
-- 13  开启20连抽功能，20连抽需要抽卡系统做特殊处理，必出一个橙将。类型值=0
-- 14  VIP副本中引用一个加攻击的passiveskill，类型值=id
-- 15  VIP副本中引用一个加生命的passiveskill,类型值=id
-- 16  每日VIP次数增加至X次，类型值=X，绝对值，配置10就是10.
-- 17.每日剧情副本次数=X，类型值=X
-- 18  巡逻效率
-- 19.每日帮助好友处理暴动事件X次
-- 20.军团-封禅祭天-开启100元宝的苍璧礼天
-- 21.日常副本购买次数
-- 22.觉醒商店刷新次数

local VipConst = {
	FIGHT = 1,
	KNIGHTJINJIE = 2,
	KNIGHTXILIAN = 3,
	EQUIPMENTSTRENGTH2 = 4,
	EQUIPMENTSTRENGTH3 = 5,
	TREASUREJINGLIAN = 6,
	DUNGONRESET = 7,
	TOWERRESET = 8,
	STORYDUNGONLIFE = 9,
	STORYDUNGONATTACK = 10,
	CHUZHENGTIMES = 11,
	SECRETSHOP = 12,
	GETKNIGHT20 = 13,
	VIPDUNGONLIFE = 14,
	VIPDUNGONATTACK = 15,
	VIPDUNGONTIMES = 16,
	STORYDUNGONTIMES = 17,
	CITYTYPE = 18,
	CITYFRIEND = 19,
	LEGION100 = 20,
	VIPDUNGONRESET = 21,
	HEROJUEXING = 22,
	REBELBOSS = 25,
	ROBRICE = 26,
	ROBRICEREVENGE = 27,
	PETSHOP = 31,  --战宠商店
	KNIGHTBAGVIPEXTRA = 32,
	TREASUREBAGVIPEXTRA = 33,
	HERO_SOUL_TRIAL = 34, --名将试炼挑战次数
	FORTUNE = 35, -- 招财符VIP相关次数
}
-- 要使用G_GlobalFunc.showVipNeedDialog的弹框的记得去langTemplate里
-- 加上对应id的LANG_MSGBOX_VIPLEVEL和LANG_MSGBOX_VIPMAX

return VipConst
