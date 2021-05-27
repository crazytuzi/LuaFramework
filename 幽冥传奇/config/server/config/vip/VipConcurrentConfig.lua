--并行的VIP
--策划案/X-系统/T-特权.xlsx
--#include "..\..\language\LangCode.txt" once

--[[

//并行VIP特权
enum enConcVipPrivType
{
	enConcVipPriv_No,						//占位
	enConcVipPriv_BossHomeIdx,				//特权专属BOSS之家，1-贵族BOSS之家，2-王者BOSS之家，3-至尊BOSS之家（占位不使用）
	enConcVipPriv_MaterialBuyNum,			//材料副本额外的购买次数
	enConcVipPriv_KillMonsterExpRate,		//杀怪经验加成
	enConcVipPriv_BookQuestNum,				//每日伏魔任务数量
	enConcVipPriv_SpecialShopBuyPower,		//特权商店购买（占位不使用）
	enConcVipPriv_DealTax,					//交易税收减免（占位不使用）
	enConcVipPriv_EquipDrapRate,			//降低装备掉落概率(百分比)
	enConcVipPriv_StoneTombMasterCount,		//专属法神数量
	enConcVipPriv_DrawBossSoul,				//抽取兽魂
	enConcVipPriv_HeroReliveNum,			//英雄复活次数
	enConcVipPriv_RecycleEquipAddExpRate,	//普通装备回收获得经验加成（百分比）
	enConcVipPriv_Max,	
};

Privilege = 
{
	第1位	： （占位不使用）特权专属BOSS之家，1-贵族BOSS之家，2-王者BOSS之家，3-至尊BOSS之家（占位不使用）
	第2位   ： 材料副本额外的购买次数（每日）
	第3位   ： （占位不使用）杀怪经验加成（百分比）
	第4位	： 每日伏魔任务数量
	第5位	： （占位不使用）特权商店购买
	第6位	： （占位不使用）交易税收减免
	第7位	： 降低装备掉落概率(百分比)
	第8位	： （占位不使用）剑阁试炼，可购买九天玄女数量
	第9位	： （占位不使用）增加抽取兽魂的数量
	第10位	： 英雄复活次数
	第11位	： 普通装备回收获得经验加成（百分比）
	第12位	： （占位不使用）特权boss
},
]]
--并行VIP（特权）的配置
VipConcCfg = 
{
	allBuyNeedYB = 88888,									--团购（四种特权一起买）需要的元宝
	Vips = 
	{
		{
			vipType = 1,  									--VIP类型 青铜卡(enConcVip1)
			vipName = Lang.ScriptTips.vipConc001,
			vipDesc	= Lang.ScriptTips.vipConc006,			--VIP描述
			buyNeedYB 		= 6888,							--购买需要元宝
			buyLastDay 		= 30,							--购买持续时间（天）
			renewalNeedYB 	= 6888,							--续费需要元宝
			renewalLastDay	= 30,							--续费时间
			jobBuff			= {1049,1050,1051},					--按职业区分的Buff
			vipBuff 		= {1048},						--VIP的Buff组
			vipBuffDesc 	= 								--VIP描述
			{
				--[[{ type = 24, value = 0.1},		--最大物防]]
				{ type = 64, value = 1},		--经验加成
				{ type = 11, value = 100, job=1},	--最大物理攻击
				{ type = 15, value = 100, job=2},	--最大魔法攻击
				{ type = 19, value = 100, job=3},	--最大道术攻击

			},
			titleId		= 0,								--头衔
			effectId 	= 0,								--特效（不使用）
			effectTime 	= 0,								--特效时间（秒）（不使用）
			privilege = 									--VIP特权
			{
				0,  0,  0,  0, 0, 0, 0, 0, 0,  5,  100
			},

			--[[buyVipGift = 									--购买特权赠送的礼包（每次购买和续费的礼包）
			{
				--{type = 0, id = 1040, count = 1, quality = 0, strong = 0, bind=1},
			},]]
			dailyVipGift = 									--VIP礼包（每日领取一次）
			{
				{type = 0, id = 4018, count = 50, quality = 0, strong = 0, bind=1},	--绑元票(中)
				{type = 0, id = 4272, count = 1, quality = 0, strong = 0, bind=1},	--金锄头
				{type = 0, id = 4264, count = 5, quality = 0, strong = 0, bind=1},	--BOSS卷轴
			},
			boss = 
			{
				vipType = 1,
				sceneId		= 88,
				fubenId		= 12,
				enterTimesLimit = 1,
				enterPos		= {18,24},
				autoFreshMonster= true,
				monsters = 
				{ 
					{ monsterId=1670, sceneId=88, num=1, pos={22,30},isBoss=true, livetime=600, },
				},
				showAwards =
				{
					{ type = 0, id = 4712, bind = 1, },
					{ type = 0, id = 4712, bind = 1, },
					{ type = 0, id = 4713, bind = 1, },
					{ type = 0, id = 4713, bind = 1, },
				},
			},
		},

		{
			vipType = 2,								--白银卡(enConcVip2)
			vipName = Lang.ScriptTips.vipConc002,
			vipDesc	= Lang.ScriptTips.vipConc007,
			buyNeedYB 		= 38888,
			buyLastDay 		= 30,
			renewalNeedYB 	= 38888,
			renewalLastDay	= 30,
			jobBuff			= {1053,1054,1055},
			vipBuff 		= {1052},
			vipBuffDesc 	=
			{
				--[[{ type = 6, value = 0.05}, --生命上限]]
				--{ type = 31, value = 2}, --敏捷
				{ type = 64, value = 1},		--经验加成
				{ type = 11, value = 200, job = 1},	--最大物理攻击
				{ type = 15, value = 200, job = 2},	--最大魔法攻击
				{ type = 19, value = 200, job = 3},	--最大道术攻击
			},
			titleId		= 0, 
			effectId 	= 0,
			effectTime 	= 0,
			privilege = 
			{
				0,  0,  0,  5, 0, 0, 0, 0, 0,  10, 200
			},

			--[[buyVipGift =
			{
				--{type = 0, id = 1040, count = 1, quality = 0, strong = 0, bind=1},
			},]]

			dailyVipGift =
			{
				{type = 0, id = 4018, count = 100, quality = 0, strong = 0, bind=1},	--绑元票(中)
				{type = 0, id = 4272, count = 1, quality = 0, strong = 0, bind=1},	--金锄头
				{type = 0, id = 4265, count = 1, quality = 0, strong = 0, bind=1},	--锁妖冢卷轴
			},
			boss = 
			{
				vipType		= 2,
				sceneId		= 88,
				fubenId		= 12,
				enterTimesLimit = 1,
				enterPos		= {18,24},
				autoFreshMonster= true,
				monsters = 
				{ 
					{ monsterId=1671, sceneId=88, num=1, pos={22,30},isBoss=true, livetime=600, },
				},
				showAwards =
				{
					{ type = 0, id = 4712, bind = 1, },
					{ type = 0, id = 4712, bind = 1, },
					{ type = 0, id = 4713, bind = 1, },
					{ type = 0, id = 4713, bind = 1, },
				},
			},
		},

		{
			vipType = 3,								--黄金卡(enConcVip3)
			vipName = Lang.ScriptTips.vipConc003,
			vipDesc	= Lang.ScriptTips.vipConc008,
			buyNeedYB 		= 68888,
			buyLastDay 		= 30,
			renewalNeedYB 	= 68888,
			renewalLastDay	= 30,
			jobBuff			= {1057,1058,1059},
			vipBuff 		= {1056},
			vipBuffDesc 	=
			{
				--[[{ type = 119, value = 500},  --暴击几率]]
				--{ type = 29, value = 2}, --准确加成
				{ type = 64, value = 1},		--经验加成
				{ type = 11, value = 300, job = 1},	--最大物理攻击
				{ type = 15, value = 300, job = 2},	--最大魔法攻击
				{ type = 19, value = 300, job = 3},	--最大道术攻击
			},
			titleId		= 0,
			effectId 	= 0,
			effectTime 	= 0,
			privilege = 
			{
				0,  0,  0,  5, 0, 0, 20, 0, 0, 15, 300
			},

			--[[buyVipGift =
			{
				--{type = 0, id = 1039, count = 1, quality = 0, strong = 0, bind=1},
			},]]

			dailyVipGift =
			{
				{type = 0, id = 4018, count = 150, quality = 0, strong = 0, bind=1},	--绑元票(中)
				{type = 0, id = 4272, count = 1, quality = 0, strong = 0, bind=1},	--金锄头
				{type = 0, id = 4265, count = 2, quality = 0, strong = 0, bind=1},	--锁妖冢卷轴	
				
			},
			boss = 
			{
				vipType 	= 3,
				sceneId		= 88,
				fubenId		= 12,
				enterTimesLimit = 1,
				enterPos		= {18,24},
				autoFreshMonster= true,
				monsters = 
				{ 
					{ monsterId=1672, sceneId=88, num=1, pos={22,30},isBoss=true, livetime=600, },
				},
				showAwards =
				{
					{ type = 0, id = 4712, bind = 1, },
					{ type = 0, id = 4712, bind = 1, },
					{ type = 0, id = 4713, bind = 1, },
					{ type = 0, id = 4713, bind = 1, },
				},
			},
		},
	},
}


