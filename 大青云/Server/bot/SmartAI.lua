--[[
1=对话任务
2=杀怪任务
3=杀怪收集
4=地面采集
5=回收道具
6=穿装备
7=使用道具
8=送信
9=达到坐标
10=特殊打怪副本
11=传送任务
12=引导任务
--]]

_G.enAttrType =
{
    --基本属性
    eaName         = 1,
    eaProf         = 2,     --职业 1:洛神(萝莉), 2:摩牱(男魔), 3:太古(男人), 4:九幽(御姐)
    eaSex          = 3,
    eaVIPLevel     = 4,     --VIP等级
    eaZone         = 5,     --区服ID
    eaLevel        = 6,     --等级
    eaExp          = 7,     --角色的当前经验,可以消耗减少
    eaLeftPoint    = 8,     --角色剩余属性点    角色当前可用来增加4个一级属性的属性点
    eaTotalPoint   = 9,     --角色总属性点      角色累计获得的总属性点
    eaBindGold     = 10,    --绑定金币          角色在游戏内的货币，游戏内产出及消耗，数值可极大,不可交易
    eaUnBindGold   = 11,    --非绑定金币        非绑定金币可替代绑定金币的全部功能,可交易
    eaUnBindMoney  = 12,    --元宝              可通过特殊途径交易，普通交易不可交易；
    eaBindMoney    = 13,    --礼金              和绑定金币类似的货币， 可购买绑定的道具，不可交易
    eaZhenQi       = 14,    --灵力              角色在游戏内的另一种代币，数值可极大， 不可交易
    
    --战斗属性
    eaHunLi        = 15,    --魂力              影响角色攻击力
    eaTiPo         = 16,    --体魄              主要影响角色生命上限，次要影响角色防御
    eaShenFa       = 17,    --身法              主要影响角色命中和闪避，次要影响爆击和韧性
    eaJingShen     = 18,    --精神              主要影响角色爆击和韧性，次要影响命中和闪避
    
    eaHp           = 19,    --生命值
    eaMaxHp        = 20,    --生命上限
    eaHpReback     = 21,   	--生命恢复速度      角色生命值恢复速度，每30秒恢复一次
    
    eaMp           = 22,    --内力值            角色当前内力值，释放技能需要消耗该值
    eaMaxMp        = 23,    --内力上限
    eaMpReback     = 24,   	--内力恢复速度      角色内力恢复速度，每30秒恢复一次
    
    eaTiLi         = 25,    --体力值            角色体力值，释放体力值技能需要消耗该值
    eaMaxTiLi      = 26,    --体力值上限
    eaTiLiReback   = 27,    --体力恢复速度      角色体力值恢复速度，每30秒恢复一次
    
    eaGongJi       = 28,    --攻击力            角色攻击力，带入伤害公式计算伤害时使用
    eaFangYu       = 29,    --防御力            角色防御力，带入伤害公式计算伤害时使用
    eaMingZhong    = 30,    --命中              角色命中值，带入命中公式计算是否命中
    eaShanBi       = 31,    --闪避              角色闪避值，带入命中公式计算是否命中
    eaBaoJi        = 32,    --爆击              角色爆击值，带入爆击公式计算是否爆击
    eaRenXing      = 33,    --韧性              角色韧性，带入爆击公式计算是否爆击
    
    eaGongJiSpeed  = 34,    --攻击速度         角色攻击速度，影响角色攻击间隔及技能公共CD间隔；
    eaMoveSpeed    = 35,    --移动速度           影响角色移动速度
    
    eaBaoJiHurt    = 36,    --爆伤              正整数，显示为百分比，例如：200%；带入伤害公式计算，影响角色爆击后的伤害值
    eaBaoJiDefense = 37,    --免爆            正整数，显示为百分比，例如：200%；带入伤害公式计算，影响角色被爆击后的伤害值
        
    eaChuanCiHurt  = 38,    --穿刺             无视防御的伤害值，带入伤害公式计算伤害值；
    eaGeDang       = 39,    --格挡值           角色格挡生效后减免的伤害值，带入伤害公式计算；
    eaHurtAdd      = 40,    --伤害增强         正整数，显示为百分比，例如：50%；角色最终伤害增加的比例，带入伤害公式计算；
    eaHurtSub      = 41,    --伤害减免         正整数，显示为百分比，例如：50%；角色最终伤害减免的比例，带入伤害公式计算
    eaGeDangLv     = 42,    --格挡率           正整数，显示为百分比，例如：100%；角色格挡生效的几率
    eaWuHunSP      = 43,    --武魂豆  角色武魂值，使用武魂技能协议消耗;
    eaMaxWuHunSP   = 44,    --武魂豆最大上限;
    eaWuHunSPRe    = 45,    --武魂豆恢复速度 角色武魂豆恢复速度，每5s恢复一次;
    eaFight        = 46,    --战斗力;
    eaMultiKill    = 47,    --连斩数;
    eaSubdef       = 48,    --破防
    eaDropVal      = 49,    --打宝活力值
    eaPKVal        = 50,    --pk值(善恶值)
    eaHonor        = 51,    --竞技场荣誉值
    eaSuper        = 52,    --卓越一击几率
    eaSuperValue   = 53,    --卓越一击伤害
    eaLingZhi      = 54,    --灵值
    eaRealmExp     = 55,    --境界经验
    eaPiLao        = 56,    --打宝疲劳
    eaDominJingLi  = 57,    --主宰之路精力
    eaEnergy       = 58,    --装备打造活力值
	
	eaRealmLvl 	   = 99,	--境界等级
----------------------下面这些服务器不发------------------
    eaKillHp         = 100,     --杀怪回血值
    eaKillMp         = 101,     --杀怪回蓝值
    eaHitHp          = 102,     --攻击命中时回血值
    eaShpre          = 103,     --每秒回血值
    eaGoldDrop       = 104,     --金币掉率百分比
    eaItemDrop       = 105,     --道具掉落百分比
    eaExtraDamage    = 106,     --攻击额外扣血值
    eaExtraSubDamage = 107,     --伤害减免值
	--
	eaHpX			= 108,		--最大生命百分比
	eaMpX			= 109,		--最大内力百分比
	eaAtkX			= 110,		--攻击百分比
	eaDefX			= 111,		--防御百分比
	eaHitX			= 112,		--命中百分比
	eaDodgeX		= 113,		--闪避百分比
	eaCriX			= 114,		--暴击百分比
	eaDefCriX		= 115,		--韧性百分比
	eaAbsAttX		= 116,		--穿刺百分比
	eaParryRateX	= 117,		--格挡率百分比
	eaParryValueX	= 118,		--格挡值百分比
	eaSubDefX		= 119,		--破防百分比
	eaAdddamagemon	= 120,		--对小怪伤害
	eaAdddamagemonx	= 121,		--对小怪伤害百分比
	eaAdddamageboss	= 122,		--对Boss伤害
	eaAdddamagebossx= 123,		--对Boss伤害百分比
}