
require "fightbuffer"

--CONST
--SKILL_TYPE                              id区间（编辑技能请按照id区间分段）
SkillManager_TYPE_ACTIVE_ROUND   =  0   --[0000,0100)--主动，回合，使用时需要在其后加上!!!间隔!!!回合数，
SkillManager_TYPE_ACTIVE_ENTER   = -1   --[0100,0200)--主动，上场
SkillManager_TYPE_ACTIVE_COUNTER = -2   --[0200,0300)--主动，反击
SkillManager_TYPE_ACTIVE_EXIT    = -3   --[0300,0400)--主动，下场
SkillManager_TYPE_PASSIVE_PROB   = -4   --[0400,0500)--被动，增幅(概率判定)
SkillManager_TYPE_PASSIVE_HPHP   = -5   --[0500,0600)--被动，增幅(血量对比判定)
SkillManager_TYPE_PASSIVE_BUFF   = -6   --[0600,0700)--被动，增幅(敌方Buffer判定)
SkillManager_TYPE_PASSIVE_DEAD   = -7   --[0700,0800)--被动，增幅(敌方死亡人数判定)
SkillManager_TYPE_PASSIVE_TRAN   = -101 --[1500,1600)--被动，增幅(物攻转法攻、法攻转物攻)
SkillManager_TYPE_PASSIVE_IMAT   = -8   --[0800,0900)--被动，免疫攻击（类似闪避）
SkillManager_TYPE_PASSIVE_REDU   = -9   --[0900,1000)--被动，减伤
SkillManager_TYPE_PASSIVE_SETA   = -10  --[1000,1100)--被动，结算，主动方
SkillManager_TYPE_PASSIVE_SETP   = -11  --[1100,1200)--被动，结算，被动方
SkillManager_TYPE_PASSIVE_IMBF   = -12  --[1200,1300)--被动，免疫Buffer
SkillManager_TYPE_PASSIVE_REVIVE = -13  --无推荐号段 --被动，复活技能
SkillManager_TYPE_PASSIVE_FINI   = -99  --[1300,1400)--被动，结束，回合结束触发
SkillManager_TYPE_PASSIVE_REBOUND= -102 --无推荐号段 --被动，反弹伤害
SkillManager_TYPE_MANUAL         = -100 --[1400,1500)--手动触发

--SELECT_TARGET_TYPE
SkillManager_OWN_RANDOM_3 = -9 --己方随机3个
SkillManager_OWN_RANDOM_2 = -8 --己方随机2个
SkillManager_OWN_RANDOM_1 = -7 --己方随机1个
SkillManager_OWN_OTHER    = -6 --己方除自己
SkillManager_OWN_100      = -5 --己方血量百分比最大
SkillManager_OWN_0        = -4 --己方血量百分比最小
SkillManager_OWN_STRONG   = -3 --己方最强
SkillManager_OWN_WEAK     = -2 --己方最弱
SkillManager_OWN_SELF     = -1 --己方自己
SkillManager_OWN_ALL      =  0 --己方所有
----------------------------------------------己方对方分界线
SkillManager_SINGLE_FRONT   = 1 --单体前排
SkillManager_SINGLE_BACK    = 2 --单体后排
SkillManager_SINGLE_WEAK    = 3 --单体血量最少
SkillManager_SINGLE_STRONG  = 4 --单体血量最多
SkillManager_SINGLE_COUNTER = 5 --单体反击
SkillManager_SINGLE_0       = 6 --单体血量百分比最小
SkillManager_SINGLE_100     = 7 --单体血量百分比最大
SkillManager_MULTI_ROW_1    = 8 --前排
SkillManager_MULTI_ROW_2    = 9 --后排
SkillManager_MULTI_COLS     = 10 --本列
SkillManager_MULTI_RANDOM_1 = 11 --随机1个
SkillManager_MULTI_RANDOM_2 = 12 --随机2个
SkillManager_MULTI_RANDOM_3 = 13 --随机3个
SkillManager_MULTI_RANDOM_4 = 14 --随机4个
SkillManager_MULTI_RANDOM_5 = 15 --随机5个
SkillManager_MULTI_ALL      = 16 --全体

--属性备注
--runType 必须，释放技能移动类型，
--		0 无需跑动
--		1 普通跑动，需要条件 target == SkillManager_SINGLE_FRONT,SkillManager_MULTI_ROW_1,SkillManager_MULTI_COLS,SkillManager_MULTI_ALL
--		2 近身跑动，需要条件 target == SkillManager_SINGLE_FRONT,SkillManager_SINGLE_BACK,SkillManager_SINGLE_WEAK,SkillManager_SINGLE_STRONG,SkillManager_SINGLE_0,SkillManager_SINGLE_100,SkillManager_SINGLE_COUNTER,SkillManager_MULTI_RANDOM_1
--      3 毛氏跑动，需要条件 非手动的攻击对方技能。
--      4 毛毛跑动，需要条件 非手动的攻击对方技能。

--shakable 可选（默认为false），该技能是否允许震屏，主动、手动技能有效。
--      true，false

SkillManager = {} --SkillManager表
SkillManager[-3] = --反弹伤害技能
	{
		name = "反弹伤害技能",
		desc = function (lv)
				return "反弹伤害技能"
			end,
		type = SkillManager_TYPE_PASSIVE_REBOUND,
		reboundFunc = function(lv,actualDamage,myBuffers) --必须，lv：技能等级；actualDamage：实际受到的伤害；myBuffers：自身带有的Buffers
				local thisBufferIDs = {BUFFER_TYPE_POISON, BUFFER_TYPE_BURN, BUFFER_TYPE_CURSE}
				local thisPercent = 0.2 --基础转化比例
				local plusPercent = 0.1 --额外转化比例
				local bufferCount = 0
				for i = 1,#thisBufferIDs do
					for j = 1,#myBuffers do
						if thisBufferIDs[i] == myBuffers[j] then
							bufferCount = bufferCount + 1
						end
					end
				end
				return actualDamage*(thisPercent+bufferCount*plusPercent)
			end,
	}
SkillManager[-2] = --物攻转法攻、法攻转物攻
	{
		name = "物攻转法攻、法攻转物攻",
		desc = function (lv)
				return "物攻转法攻、法攻转物攻"
			end,
		type = SkillManager_TYPE_PASSIVE_TRAN,
		addFunc = function(lv,isMana,phscAtt,manaAtt,probability) --必须，lv：技能等级；isMana：主动技能是否法术；phscAtt：角色的物理攻击；manaAtt：角色的法术攻击；probability：[0,1)随机数
				local thisProbability = 1
				local thisPercent = 0.5 --转化比例
				if thisProbability > probability then
					return thisPercent * (isMana and phscAtt or manaAtt)
				else
					return thisPercent * 0
				end
			end,
	}
SkillManager[-1] = --复活技能样例
	{
		name = "测试复活",
		desc = function(lv)
				return "测试用的复活技能"
			end,
		type = SkillManager_TYPE_PASSIVE_REVIVE,
		reviveFunc = function(lv,whichTime,probability)
				local thisMaxReviveCount = 1000 --[0,无穷大),允许的复活次数
				local thisProbability = 1 --[0,1] 每一次的复活概率,数值越大,概率越高
				return thisMaxReviveCount >= whichTime and thisProbability >= probability
			end,
		hpAttackDefence = function(lv,whichTime,hpMax,hpLmt,phscAtt,manaAtt,phscDef,manaDef)
				local retHpLmt = hpMax --!!!该返回值不能为0
				local retHpCur = hpLmt --!!!该返回值不能为0
				local retPhscAtt=phscAtt
				local retManaAtt=manaAtt
				local retPhscDef=phscDef
				local retManaDef=manaDef
				return retHpLmt,retHpCur,retPhscAtt,retManaAtt,retPhscDef,retManaDef
			end,
	}
SkillManager[0000] =
	{
		name = "天墓之魂", --萧玄
		desc = function (lv)
				return "死亡时释放，提升己方全体英雄30%攻击力（持续2次攻击）" 			
			end,		
		type = SkillManager_TYPE_ACTIVE_EXIT, --属性含义参照SkillManager_TYPE_ACTIVE_ROUND
		--start属性无效
		isMana = true,
		target = SkillManager_OWN_OTHER,
		runType = 0,
		bannerType = false,
		ignoreIMRE = false,
		attackAction = 3,
		injureAction = 0,
		--prepareActionF= 0,
		--missileAction= -4, 
		effectAction = 20,
		damageRatio = 1,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferIncrease(3,2,0.3,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
-------------------------------------------------------法攻单体
SkillManager[273] =
	{
		name = "魔蛇噬", --凌影
		desc = function (lv)
				return "对敌方单体造成100%法术攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		--prepareActionB = 0, 
		--prepareActionF = 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers,isWorldBoss) 
				return att_all
			end,
	}
SkillManager[0001] =
	{
		name = "魔蛇噬", --凌影
		desc = function (lv)
				return "对敌方单体造成100%法术攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		--prepareActionB = 0, 
		--prepareActionF = 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		subHpLimit = function(lv,damage,probability,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,myBuffers,enemyBuffers)
				local thisProbability   = 1 --(0,1] 生成概率,数值越大,概率越高
				local subHpLimitPercent = 0.5 --生命上限降低百分比（基于伤害）
				if thisProbability > probability then
					return damage * subHpLimitPercent
				else
					return 0
				end
			end,
	}
SkillManager[0002] =
	{
		name = "魂手印", 
		desc = function (lv)
				return "对单个敌人造成90%法术伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 0.9,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers)
				return att_all
			end,
	}
SkillManager[0003] =
	{
		name = "重岩壁", --云棱
		desc = function (lv)
				return "对敌方单体造成50%法术攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 0.5,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0,  
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0004] =
	{
		name = "凤火冲击", --
		desc = function (lv)
				return "对敌方单体造成60%法术攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 0.6,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0005] =
	{
		name = "碎魂冥掌", --
		desc = function (lv)
				return "对单个敌人造成120%法术攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 1.2,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0006] =
	{
		name = "碎石掌", --萧媚
		desc = function (lv)
				return "对敌方单体造成60%法术攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 0.6,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0007] =
	{
		name = "水曼陀罗", --若琳导师
		desc = function (lv)
				return "对单个敌人造成120%法术伤害，100%概率使对方晕眩（失去1个回合行动力），第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_1, 
		damageRatio = 1.2,
		runType = 0, 
		bannerType = false,
		shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 8, 
		effectAction = 7, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferStun(0,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0008] =
	{
		name = "天凰步", --凰天
		desc = function (lv)
				return "对纵列敌人造成110%法术伤害，第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 1.1,
		runType = 1, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 2, 
		injureAction = 1, 
		--missileAction= , 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0009] =
	{
		name = "海焰戟", --韩枫
		desc = function (lv)
				return "对敌方单体造成200%法术攻击伤害，第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 2,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0010] =
	{
		name = "黄沙漫天", --宋清
		desc = function (lv)
				return "对敌方单体造成70%法术攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 0.7,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0011] =
	{
		name = "惊雷闪", --xx
		desc = function (lv)
				return "对敌方单体造成75%法术攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 0.75,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0012] =
	{
		name = "焚炎掌", --唐震
		desc = function (lv)
				return "对随机1名敌人造成100%法术攻击伤害，45%概率产生伤害值50%的灼烧效果（持续2回合），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_1, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.45 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(5,2,damage,0.5) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0013] =
	{
		name = "玄火动", --xx
		desc = function (lv)
				return "对敌方单体造成90%法术攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 0.9,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
	
	------------------------------------------------------------法攻持续不能加血
SkillManager[0014] =
	{
		name = "骨皇裂天", --魂殿副殿主
		desc = function (lv)
				return "对单个英雄造成120%法术攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 1.2,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 4, 
		effectAction = 10, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,			
	}
SkillManager[0015] =
	{
		name = "半月护灵", --丘陵
		desc = function (lv)
				return "对随机2个敌人造成200%物理伤害，45%概率使目标无法被治疗，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_2, 
		damageRatio = 2,
		runType = 1, 
		--bannerType = true,
		bannerType = true,
		shout = true,
		prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.45 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferCureless(0,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,			
	}
SkillManager[0016] =
	{
		name = "万风缠缚", --云山
		desc = function (lv)
				return "对全体敌人造成180%法术伤害,80%概率使目标失去1次被治疗机会，第1回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 1.8,
		runType = 0, 
		bannerType = true,
		shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 4, 
		effectAction = 10, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.8 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferCureless(0,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,			
	}
------------------------------------------------------------------------法攻单体无视减免

SkillManager[0017] =
	{
		name = "幽冥妖火臂", --慕骨老人
		desc = function (lv)
				return "对单个敌人造成100%物理伤害，100%概率使目标失去1次被治疗机会，第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = false, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,

	    		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferCureless(0,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0018] =
	{
		name = "游龙掌", --叶重
		desc = function (lv)
				return "对敌方单体造成100%法术攻击伤害，无视免疫和伤害减免效果，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = true, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0019] =
	{
		name = "死寂之门", --魂千陌
		desc = function (lv)
				return "对单个敌人造成110%法术攻击伤害，无视免疫和伤害减免效果，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 1.1,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = true, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0020] =
	{
		name = "七杀枪", --易尘
		desc = function (lv)
				return "对敌方单体造成60%法术攻击伤害，无视免疫和伤害减免效果，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 0.6,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = true, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0021] =
	{
		name = "升龙斩", --
		desc = function (lv)
				return "对所有敌人造成60%法术攻击伤害，无视免疫和伤害减伤效果，每1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = true, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 4, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0022] =
	{
		name = "力透千钧", --妖暝
		desc = function (lv)
				return "对随机3个敌人造成150%法术攻击伤害，并使对方失去一次治疗机会，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_3, 
		damageRatio = 1.5,
		runType = 1, 
		bannerType = true,
		shout = true,
		shakable = true,
		prepareActionF= 2, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction = 13, 
		effectAction = 12, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferCureless(0,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0023] =
	{
		name = "玄心九转", --
		desc = function (lv)
				return "对单个敌人造成280%法术伤害，45%概率使对方虚弱（减少30%攻击力，持续2次），第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 2.8,
		runType = 0, 
		bannerType = true,
		shout = true,
		shakable = true,
		prepareActionF= 0, 
		ignoreIMRE = true, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.45 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferDecrease(4,2,0.3,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
-------------------------------------------------------------------------------------法攻反击
SkillManager[0024] =
	{ 	name = "花落满天",--花锦
		desc = function (lv)
				return "受到攻击时有40%概率进行反击，对敌人造成50%法术攻击伤害" 			
			end,
		type = SkillManager_TYPE_ACTIVE_COUNTER,--属性含义参照SkillManager_TYPE_ACTIVE_ROUND
		--start属性无效
		isMana = true,
		target = SkillManager_SINGLE_COUNTER,
		counterProbability = 0.4, --反击概率
		ignoreIMRE = false,
		attackAction = 0,
		injureAction = 0,
		effectAction = 0,
		--prepareActionF= 0,
		--missileAction= 0,
		--bannerType = true,
		runType = 0,
		damageRatio = 0.5,

	}
SkillManager[0025] =
	{ 	name = "三星附魔",--通玄长老 
		desc = function (lv)
				return "为己方随机2名英雄增加护盾（减少40%攻击伤害，抵挡2次攻击），第1回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 1, 
		isMana = false, 
		target = SkillManager_OWN_RANDOM_2, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false, 
		prepareActionF= 4, 
		ignoreIMRE = false, 
		attackAction = 3, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferReduction(6,2,0.4,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,

	}
SkillManager[0026] =
	{
		name = "血脉复苏",--
		desc = function (lv)
				return "治疗己方血量最少的英雄（100%），第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_OWN_0, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 3, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 
		regeFunc = function(lv,att_all) 
				return att_all
			end,
	}
-----------------------------------------------------------------------------法攻减伤
SkillManager[0027] =
	{
		name = "土玄地火盾",--宋清 
		desc = function (lv)
				return "受到法术攻击时50%概率减少30%伤害" 			
			end,
		type = SkillManager_TYPE_PASSIVE_REDU,

		reduceFunc = function(lv,isMana,damage,probability) --必须，lv：技能等级；isMana：主动技能是否法术
				local thisIsMana = true --true:法术减伤;false:物理减伤
				local thisProbability = 0.5
				local thisPercent = 0.3
				local thisNumber = 0
				return (thisIsMana == isMana and thisProbability > probability) and damage*thisPercent or 0
			end,
	}
-----------------------------------------------------------------------------法攻降攻击
SkillManager[0028] =
	{
		name = "回春术", --药星极
		desc = function (lv)
				return "治疗己方血量最少的英雄（120%），第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = true, 
		target = SkillManager_OWN_0, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = false, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 3, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 
		regeFunc = function(lv,att_all) 
				return att_all*1.2
			end,		
	}
SkillManager[0029] =
	{
		name = "碎星刀", --摘星老鬼，邙天尺，青海尊者，莫天行，小公主
		desc = function (lv)
				return "对单个敌人造成150%法术伤害，第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 1.5,
		runType = 0, 
		bannerType = false,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 8, 
		effectAction = 7, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,		
	}
SkillManager[0030] =
	{
		name = "碎星刀", --黄泉尊者
		desc = function (lv)
				return "对单个敌人造成120%法术伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 1.2,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 8, 
		effectAction = 7, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,		
	}
--SkillManager[0030] =
--	{
--		name = "大裂妖爪", --九凤
--		desc = function (lv)
--				return "对敌方随机2名英雄造成30%法术攻击伤害，20%概率降低敌人30%攻击力（持续2次），第2回合释放，冷却时间1回合" 			
--			end,
--		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
--		start = 2, 
--		isMana = true, 
--		target = SkillManager_MULTI_RANDOM_2, 
--		damageRatio = 0.3,
--		runType = 0, 
--		--bannerType = true,
--		--prepareActionF= 0, 
--		ignoreIMRE = false, 
--		attackAction = 1, 
--		injureAction = 0, 
--		missileAction= 8, 
--		effectAction = 10, 
--		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
--				return att_all
--			end,
--		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
--				local thisProbability = 0.2 --(0,1] 生成概率,数值越大,概率越高
--				if thisProbability > probability then
--					return createBufferDecrease(0,2,0.3,0) --createBuffer*****参考fighterbuffer.lua
--				else
--					return nil
--				end
--			end,			
--	}
SkillManager[0031] =
	{
		name = "灭魂掌", --
		desc = function (lv)
				return "对随机2个敌人造成240%法术伤害，50%概率使对方虚弱（减少20%攻击力，持续2次），第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_2, 
		damageRatio = 2.4,
		runType = 0, 
		bannerType = false,
		shout = true, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 3, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.5 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferDecrease(2,2,0.2,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,			
	}
SkillManager[0032] =
	{
		name = "天魔要诀", --青海尊者
		desc = function (lv)
				return "对后排敌人造成180%法术伤害，50%概率使目标失去2次被治疗机会，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 1.8,
		runType = 1, 
		bannerType = false, 
		--bannerType = true,
		shout = true,
		prepareActionF= 4, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,	

			setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.5 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferCureless(1,2) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,			
	}
SkillManager[0033] =
	{
		name = "冰晶雨", --冰元
		desc = function (lv)
				return "对敌方随机2名英雄造成80%法术攻击伤害，40%概率降低敌人30%攻击力（持续2次），第3回合释放，冷却时间3回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 3, 
		start = 3, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_2, 
		damageRatio = 0.8,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 4, 
		missileAction= 0, 
		effectAction = 20, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.4 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferDecrease(0,2,0.3,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,			
	}
-------------------------------------------------------------------------------法攻生命最少
SkillManager[0034] =
	{
		name = "大血菩噬", --范痨
		desc = function (lv)
				return "对敌方生命最少的英雄造成100%法术攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_0, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 2, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0035] =
	{
		name = "陨火玄指", --九凤
		desc = function (lv)
				return "对敌方生命最少的英雄造成40%法术攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_0, 
		damageRatio = 0.4,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 2, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0036] =
	{
		name = "兽王啸", --古妖
		desc = function (lv)
				return "对单个敌人造成110%法术伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 1.1,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 2, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0037] =
	{
		name = "烈光焰", --炎利
		desc = function (lv)
				return "对敌方生命最少的英雄造成40%法术攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_0, 
		damageRatio = 0.4,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 2, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0038] =
	{
		name = "地爆星罡", --xxx
		desc = function (lv)
				return "对敌方生命最少的英雄造成60%法术攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_0, 
		damageRatio = 0.6,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 2, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0039] =
	{
		name = "化骨血煞掌", --范凌
		desc = function (lv)
				return "对敌方生命最少的英雄造成40%法术攻击伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_SINGLE_0, 
		damageRatio = 0.4,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 2, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0040] =
	{
		name = "妖凰复仇", --凰天
		desc = function (lv)
				return "受到攻击伤害时，40%概率进行反击，对前排敌人造成100%法术伤害" 			
			end,
		type = SkillManager_TYPE_ACTIVE_COUNTER,--属性含义参照SkillManager_TYPE_ACTIVE_ROUND
		--start属性无效
		isMana = true,
		target = SkillManager_MULTI_ROW_1,
		counterProbability = 0.3,--反击概率
		damageRatio = 1,
		attackAction = 0,
		injureAction = 0,
		--prepareActionF= 0,
		--missileAction= 0,
		bannerType = false,
		effectAction = 0,
		runType = 0,
		ignoreIMRE = false,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers)
				return att_all
			end,
	}
SkillManager[0041] =
	{
		name = "万兽枪法", --xxx
		desc = function (lv)
				return "对敌方生命最少的英雄造成180%法术攻击伤害，第3回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 3, 
		isMana = true, 
		target = SkillManager_SINGLE_0, 
		damageRatio = 1.8,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 3, 
		effectAction = 10, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0042] =
	{
		name = "太阴神雷", --莫天行
		desc = function (lv)
				return "对血量最少的敌人造成320%法术伤害，第3回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 3, 
		isMana = true, 
		target = SkillManager_SINGLE_0, 
		damageRatio = 3.2,
		runType = 0, 
		bannerType = true,
		shout = true,
		prepareActionF= 1, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 2, 
		effectAction = 12, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0043] =
	{
		name = "天凰蚀体", --凰天
		desc = function (lv)
				return "对纵列敌人造成260%法术伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 2.6,
		runType = 0, 
		--bannerType = true,
		bannerType = true,
		shout = true,
		prepareActionF= 2, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 13, 
		effectAction = 12, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
----------------------------------------------------------------------------------------法攻后排单体
SkillManager[0044] =
	{
		name = "风杀指", --风尊者，鹰山老人
		desc = function (lv)
				return "对后排单个敌人造成180%物理伤害，第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = false, 
		target = SkillManager_SINGLE_BACK, 
		damageRatio = 1.8,
		runType = 1, 
		bannerType = false,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 4, 
		effectAction = 10, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,

		
	}
SkillManager[0045] =
	{
		name = "火龙冲天", --炎利
		desc = function (lv)
				return "对敌方后排单体造成50%法术攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_BACK, 
		damageRatio = 0.5,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 1, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0046] =
	{
		name = "守护之刃", --萧薰儿
				desc = function (lv)
				return "每个回合行动结束时，回复30%生命" 			
			end,
		type = SkillManager_TYPE_PASSIVE_FINI,

		finishFunc = function(lv,probability) --必须，lv：技能等级；返回：
				local thisProbability    = 1
				local thisAttackPercent  = 0 --[0,1]攻击百分比,谁的回合谁增加攻击
				local thisDefencePercent = 0 --[0,1]防御百分比,谁的回合谁增加防御
				local thisHPPercent      = 0.3 --[0,1]回血百分比,谁的回合谁回复血量
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,
	}
SkillManager[0047] =
	{
		name = "星火长空", --火云老祖，西龙王
		desc = function (lv)
				return "对纵列敌人造成90%法术伤害，第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 0.9,
		runType = 1, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 2, 
		injureAction = 1, 
		--missileAction= , 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0048] =
	{
		name = "九转风游步", --
		desc = function (lv)
				return "对后排单个敌人造成100%法术伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_BACK, 
		damageRatio = 0.6,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 2, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0049] =
	{
		name = "磬龙灭法", --月媚
		desc = function (lv)
				return "对敌方后排单体造成70%法术攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_BACK, 
		damageRatio = 0.7,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 2, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0050] =
	{
		name = "疾风破", --妖暝
		desc = function (lv)
				return "对前排敌人造成75%法术攻击伤害，第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 0.75,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 12, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0051] =
	{
		name = "三鲨刺", --蝎毕岩
		desc = function (lv)
				return "对敌方后排单体造成80%法术攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_BACK, 
		damageRatio = 0.8,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 11, 
		effectAction = 10, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0052] =
	{
		name = "裂石步", --银老
		desc = function (lv)
				return "对敌方后排单体造成80%法术攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_BACK, 
		damageRatio = 0.8,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 11, 
		effectAction = 10, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0053] =
	{
		name = "裂风旋舞", --云韵
		desc = function (lv)
				return "对后排敌人造成150%法术伤害，50%概率使目标失去1次被治疗机会，第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 1.5,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 8, 
		effectAction = 7, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.5 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferCureless(1,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
-----------------------------------------------------------------------------------法攻后排
SkillManager[0054] =
	{
		name = "魂手印", --萧玄
		desc = function (lv)
				return "对随机2个敌人造成90%法术伤害，血量每下降1%增加2%攻击力，第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 0.9,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 1, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all*(2-srcHP/srcHPMax)
			end,
	}
SkillManager[0055] =
	{
		name = "流星火雨", --
		desc = function (lv)
				return "对敌方后排全体英雄造成20%法术攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 0.2,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 2, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0056] =
	{
		name = "血蚀箭", --范凌
		desc = function (lv)
				return "对敌方后排全体英雄造成20%法术攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 0.2,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 3, 
		effectAction = 10, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0057] =
	{
		name = "万虫蚀天", --xx
		desc = function (lv)
				return "对敌方后排全体英雄造成25%法术攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 0.25,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 11, 
		effectAction = 10, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0058] =
	{
		name = "花间游", --花锦
		desc = function (lv)
				return "对敌方后排全体英雄造成25%法术攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 0.25,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0059] =
	{
		name = "大地震裂杀", --古华 
		desc = function (lv)
				return "对单个敌人造成280%法术伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 2.8,
		runType = 1, 
		bannerType = false, 
		shout = true,
		prepareActionF= 4, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 7, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0060] =
	{
		name = "海浪滔天", --萧玉
		desc = function (lv)
				return "对前排敌人造成120%法术攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 1.2,
		runType = 0, 
		bannerType = false,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,

		
	}
SkillManager[0061] =
	{
		name = "大风手印", --云山
		desc = function (lv)
				return "对单个敌人造成290%法术伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 2.9,
		runType = 0, 
		bannerType = false, 
		--shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 1, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0062] =
	{
		name = "斩帝鬼血刃", --魂天帝
		desc = function (lv)
				return "对单个敌人造成320%法术攻击伤害，70%概率增加敌方死亡人数乘以10%的攻击力（最大增幅50%），第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 3.2,
		runType = 0, 
		bannerType = false, 
		--shout = true,
		prepareActionF= 2, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 12,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				local thisProbability = 0.7
				if thisProbability > probability then
					if enemyDeath > 5 then
						return att_all*1.5
					else
						return att_all*(1+enemyDeath*0.1)
					end
				else
					return att_all
				end
			end,
	}
SkillManager[0063] =
	{
		name = "风雷祭", --风尊者
		desc = function (lv)
				return "对后排敌人造成80%物理伤害，若目标已虚弱额外增加160%物理伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 0.8,
		runType = 0, 
		bannerType = false, 
		--shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 6, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
							local thisBuffers ={BUFFER_TYPE_DECREASE}
				for i = 1,#enemyBuffers do
					for j = 1,#thisBuffers do
						if enemyBuffers[i] == thisBuffers[j] then
					    return att_all*2.5
						end
					end
				end
				return att_all
			end,
	}
SkillManager[0064] =
	{
		name = "心魔焚身", --韩枫

		desc = function (lv)
				return "对随机2个敌人造成220%法术伤害，80%概率产生攻击伤害25%灼烧（持续2回合），第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_2, 
		damageRatio = 2.2,
		runType = 0, 
		bannerType = false, 
		shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 1, 
		effectAction = 4, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.8 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(6,2,damage,0.25) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0065] =
	{
		name = "风刃刀舞", --萧媚
		desc = function (lv)
				return "对敌方后排全体英雄造成75%法术攻击伤害，第3回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 3, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 0.75,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 9, 
		effectAction = 10, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0066] =
	{
		name = "鼠影重重", --金石
		desc = function (lv)
				return "对随机2个敌人造成180%法术伤害，无视免疫和伤害减免效果，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_2, 
		damageRatio = 1.8,
		runType = 0, 
		bannerType = true,
		shout = true,
		prepareActionF= 4, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}


	SkillManager[0067] =
	{
		name = "凝雷掌", --琥乾
		desc = function (lv)
				return "对敌方随机2名英雄造成120%法术攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_2, 
		damageRatio = 1.2,
		runType = 0, 
		bannerType = false,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 1, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}

SkillManager[0068] =
	{
		name = "厚土之力", --宋清
		desc = function (lv)
				return "对敌方后排全体英雄造成100%法术攻击伤害，第3回合释放，冷却时间3回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 3, 
		start = 3, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0069] =
	{
		name = "灵魂烙印", 
		desc = function (lv)
				return "攻击对方并造成伤害时，65%概率降低对方20%基础防御力" 			
			end,
		type = SkillManager_TYPE_PASSIVE_SETA,
		sattlementFunc = function(lv,probability) --必须，lv：技能等级；
				local thisProbability    = 0.65
				local thisAttackPercent  = 0 --[-1,0)攻击百分比,被攻击方降低攻击；[0,1]攻击方增加攻击
				local thisDefencePercent = -0.2 --[-1,0)防御百分比,被攻击方降低防御；[0,1]攻击方增加防御
				local thisHPPercent      = 0 --[0,1] 吸血百分比,攻击方吸血
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,
	}
SkillManager[0070] =
	{
		name = "血煞掌", --易尘
		desc = function (lv)
				return "对敌方后排全体英雄造成100%法术攻击伤害，第4回合释放，冷却时间3回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 3, 
		start = 4, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 3, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0071] =
	{
		name = "血神裂天", --
		desc = function (lv)
				return "对后排敌人造成180%法术伤害，第4回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 4, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 1.8,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 4, 
		effectAction = 10, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
	------------------------------------------------------------------------------------------法攻前排
SkillManager[0072] =
	{
		name = "无色连环", --
		desc = function (lv)
				return "对随机1名敌人造成90%法术攻击伤害，70%概率产生伤害值100%的灼烧效果（持续2回合），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_1, 
		damageRatio = 0.9,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.7 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(9,2,damage,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0073] =
	{
		name = "叶舞术", --
		desc = function (lv)
				return "对敌方前排全体英雄造成30%法术攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 0.3,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0074] =
	{
		name = "血魂变",--加刑天
		desc = function (lv)
				return "攻击对方并造成伤害时，提升自身20%基础防御力" 			
			end,
		type = SkillManager_TYPE_PASSIVE_SETA,
		sattlementFunc = function(lv,probability) --必须，lv：技能等级；
				local thisProbability    = 1
				local thisAttackPercent  = 0 --[-1,0)攻击百分比,被攻击方降低攻击；[0,1]攻击方增加攻击
				local thisDefencePercent = 0.2 --[-1,0)防御百分比,被攻击方降低防御；[0,1]攻击方增加防御
				local thisHPPercent      = 0 --[0,1] 吸血百分比,攻击方吸血
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,
	}
SkillManager[0075] =
	{
		name = "古帝碎涅指", --
		desc = function (lv)
				return "对纵列敌人造成80%法术攻击伤害，第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_COLS,
		damageRatio = 0.8,
		runType = 1, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 2, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0076] =
	{
		name = "血魔蚀心雷", --魂天帝
		desc = function (lv)
				return "对前排敌人造成90%法术攻击伤害，第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 0.9,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0077] =
	{
		name = "千烈凤屏", --韩月
		desc = function (lv)
				return "对后排敌人造成120%法术伤害，30%概率冻结目标1回合，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 1.2,
		runType = 0, 
		bannerType = true, 
		shout = true,
		shakable = true,
		prepareActionF= 4, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 5, 
		effectAction = 7, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
			setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.3 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferFreeze(0,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,	
	}

	
SkillManager[0078] =
	{
		name = "炙炎旋流", --火云老祖
		desc = function (lv)
				return "对随机1个敌人造成300%法术伤害，60%概率产生伤害40%的灼烧效果（持续2回合），第2回合释放，冷却时间3回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 3, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_1, 
		damageRatio = 3,
		runType = 0, 
		bannerType = false, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 1, 
		effectAction = 12, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.6 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(1,2,att,0.4) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0079] =
	{
		name = "金帝焚天阵", --萧薰儿
		desc = function (lv)
				return "对后排敌人造成250%法术伤害，自身带有异常状态时，额外增加100%法术伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 2.5,
		runType = 0, 
		bannerType = false, 
		shakable = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 1, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				local thisBuffers ={BUFFER_TYPE_POISON, BUFFER_TYPE_BURN, BUFFER_TYPE_CURSE, BUFFER_TYPE_DECREASE,BUFFER_TYPE_CURELESS}
				for i = 1,#myBuffers do
					for j = 1,#thisBuffers do
						if myBuffers[i] == thisBuffers[j] then
					    return att_all*1.6
						end
					end
				end
				return att_all
			end,
	}
SkillManager[0080] =
	{
		name = "水影鞭", --若琳导师
				desc = function (lv)
				return "替补上阵时立刻释放，对血量最多的敌人造成240%法术伤害，80%概率额外增加140%法术伤害" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ENTER,
		--start属性无效
		isMana = true,
		target = SkillManager_SINGLE_100,
		damageRatio = 2.4,
		runType = 0,
		bannerType = false,
		bannerType = true,
		shout = true,
		ignoreIMRE = false,
		attackAction = 1,
		injureAction = 0,
		--prepareActionF= 0,
		missileAction= 5,
		effectAction = 21,  
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				local thisProbability = 0.8
				if thisProbability > probability then
					return att_all*2.4
				else
					return att_all
				end
			end,
	}
SkillManager[0081] =
	{
		name = "幽木毒蛇藤", --琥嘉
		desc = function (lv)
				return "对前排敌人造成125%法术伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 1.25,
		runType = 0, 
		bannerType = false,
		shout = true, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0082] =
	{
		name = "四方风壁", --云韵
		desc = function (lv)
				return "对血量最少的敌人造成220%法术伤害，100%概率使目标失去1次被治疗机会，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_0, 
		damageRatio = 2.2,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 4, 
		effectAction = 10, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
        
	        setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferCureless(1,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
		
	}
SkillManager[0083] =
	{
		name = "地灵束缚", --银老
		desc = function (lv)
				return "对敌方前排全体英雄造成50%法术攻击伤害，第2回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 0.5,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 17, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0084] =
	{
		name = "乾天罡气", --通玄长老
		desc = function (lv)
				return "对前排敌人造成140%法术伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 1.4,
		runType = 0, 
		bannerType = true,
		shout = true,
		prepareActionF= 1, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 0, 
		effectAction = 12, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0085] =
	{
		name = "气贯天地", --萧玄
		desc = function (lv)
				return "对前排敌人造成150%法术攻击伤害，血量每减少1%增加2%攻击力，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 1.5,
		runType = 0, 
		bannerType = true,
		shout = true,
		prepareActionF= 2, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 12, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all*(2-srcHP/srcHPMax)
			end,
	}
SkillManager[0086] =
	{
		name = "龙皇真身", --紫妍
		desc = function (lv)
				return "对所有负面状态免疫（中毒、灼烧、封印等）" 			
			end,
		type = SkillManager_TYPE_PASSIVE_IMBF,
		immunityBufferFunc = function(lv,bufferID,probability) --必须，lv：技能等级；bufferID：待检测的bufferID
				local thisProbability = 1
				local thisBufferIDs = {BUFFER_TYPE_POISON, BUFFER_TYPE_BURN, BUFFER_TYPE_CURSE, BUFFER_TYPE_DECREASE,BUFFER_TYPE_FREEZE,BUFFER_TYPE_STUN,BUFFER_TYPE_SEAL,BUFFER_TYPE_CURELESS} --免疫的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua） --免疫的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua）
				if thisProbability > probability then
					for i = 1,#thisBufferIDs do
						if thisBufferIDs[i] == bufferID then
							return true
						end
					end
				end
				return false
			end,
	}
SkillManager[0087] =
	{
		name = "九幽魂手", --摘星老鬼
		desc = function (lv)
				return "对单个敌人造成300%法术伤害，80%概率使敌人被封印（失去1个回合行动力），第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 3,
		runType = 0, 
		bannerType = true,
		--shout = true,
		prepareActionF= 4, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 7, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.8 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferSeal(0,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0088] =
	{
		name = "雷劫掌", --雷尊者
		desc = function (lv)
				return "对随机3个敌人造成180%法术伤害，若自身被虚弱则每个目标额外受到150%物理伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_3, 
		damageRatio = 1.8,
		runType = 0, 
		bannerType = true,
		shout = true,
		prepareActionF= 1, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 1, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
					local thisBuffers ={BUFFER_TYPE_DECREASE}
				for i = 1,#myBuffers do
					for j = 1,#thisBuffers do
						if myBuffers[i] == thisBuffers[j] then
					    return att_all*2.5
						end
					end
				end
				return att_all
			end,	
	}
SkillManager[0089] =
	{
		name = "朱雀振翅", --古妖 雅妃
		desc = function (lv)
				return "每个回合行动结束后，回复20%血量" 			
			end,
				type = SkillManager_TYPE_PASSIVE_FINI,

		finishFunc = function(lv,probability) --必须，lv：技能等级；返回：
				local thisProbability    = 1
				local thisAttackPercent  = 0 --[0,1]攻击百分比,谁的回合谁增加攻击
				local thisDefencePercent = 0 --[0,1]防御百分比,谁的回合谁增加防御
				local thisHPPercent      = 0.20 --[0,1]回血百分比,谁的回合谁回复血量
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,
	}
SkillManager[0090] =
	{
		name = "九龙雷罡", --唐震
desc = function (lv)
				return "对单个敌人造成330%物理伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 3.3,
		runType = 1, 
		--bannerType = true,
		bannerType = true,
		shout = true,
		prepareActionF= 4, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 10, 
		effectAction = 12, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
----------------------------------------------------------------------------------------法攻随机2
	SkillManager[0091] = 
	{  
		name = "浮生万刃",--琥乾
		desc = function (lv)
				return "死亡时释放，回复己方全体英雄血量（200%）" 			
			end,		
		type = SkillManager_TYPE_ACTIVE_EXIT, --属性含义参照SkillManager_TYPE_ACTIVE_ROUND
		--start属性无效
		isMana = true,
		target = SkillManager_OWN_OTHER,
		runType = 0,
		bannerType = true,
		shout = true,
		ignoreIMRE = false,
		attackAction = 3,
		injureAction = 0,
		--prepareActionF= 0,
		--missileAction= 0, 
		effectAction = 19,
		damageRatio = 1,
		regeFunc = function(lv,att_all) 
				return att_all*2
			end,		
	}
SkillManager[0092] =
	{
		name = "厄难毒体", 
		desc = function (lv)
				return "对随机1名敌人造成90%法术伤害，60%概率产生伤害值80%的中毒效果（持续2个回合），第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_1, 
		damageRatio = 0.9,
		runType = 0, 
		--bannerType = true,
		prepareActionF= 3, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 4, 
		missileAction= 9, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.6 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferPoison(7,2,damage,0.8) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,	
	}
SkillManager[0093] =
	{
		name = "离魂符", --
		desc = function (lv)
				return "对单个敌人造成110%法术伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 1.1,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0094] =
	{
		name = "大寂灭术", --古妖
		desc = function (lv)
				return "攻击对方并造成伤害时，45%概率永久提升10%基础攻击力" 			
			end,
		type = SkillManager_TYPE_PASSIVE_SETA,
		sattlementFunc = function(lv,probability) --必须，lv：技能等级；
				local thisProbability    = 0.45
				local thisAttackPercent  = 0.1 --[-1,0)攻击百分比,被攻击方降低攻击；[0,1]攻击方增加攻击
				local thisDefencePercent = 0 --[-1,0)防御百分比,被攻击方降低防御；[0,1]攻击方增加防御
				local thisHPPercent      = 0 --[0,1] 吸血百分比,攻击方吸血
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,
	}
SkillManager[0095] =
	{
		name = "青龙云屏", --莫天行
		desc = function (lv)
				return "对随机2个敌人造成200%法术伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_2, 
		damageRatio = 2,
		runType = 0, 
		bannerType = false, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 14, 
		effectAction = 21, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
------------------------------------------------------------------------------------法攻随机3
SkillManager[0096] =
	{
		name = "金灵疾空", --雅妃
		desc = function (lv)
				return "治疗己方血量最少的英雄（280%），同时解除目标除了定身状态之外的一切负面状态，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_OWN_0, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false, 
		--prepareActionF= 0, 
		ignoreIMRE = true, 
		attackAction = 3, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 
		

	        regeFunc = function(lv,att_all) 
				return att_all*2.8
			end,

		clearFunc = function(lv) 
				return {BUFFER_TYPE_POISON,BUFFER_TYPE_BURN,BUFFER_TYPE_DECREASE,BUFFER_TYPE_CURELESS}
			end,
	}
SkillManager[0097] =
	{
		name = "青鸾一舞", --
		desc = function (lv)
				return "对敌方随机3名英雄造成40%法术攻击伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_3, 
		damageRatio = 0.4,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 9, 
		effectAction = 10, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0098] =
	{
		name = "风推势", --云韵
		desc = function (lv)
				return "对后排单个敌人造成330%法术伤害，50%概率使目标失去1次被治疗机会，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_SINGLE_BACK, 
		damageRatio = 3.3,
		runType = 0, 
		bannerType = true,
		shout = true,
		prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 5, 
		haloAction = 2, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,

			 setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.5 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferCureless(1,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0099] =
	{
		name = "死亡之碑", --魂千陌
		desc = function (lv)
				return "对随机3名敌人造成160%法术攻击伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_3, 
		damageRatio = 1.6,
		runType = 0, 
		bannerType = true,
		shout = true,
		prepareActionF= 4, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 8, 
		effectAction = 7, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0100] =
	{
		name = "苍龙盖天", --xx
		desc = function (lv)
				return "对敌方随机3名英雄造成50%法术攻击伤害，第3回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 3, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_3, 
		damageRatio = 0.5,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 13, 
		effectAction = 12, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0101] =
	{
		name = "神使焰", --火云老祖，西龙王
		desc = function (lv)
				return "对纵列敌人造成240%法术伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 2.4,
		runType = 0, 
		bannerType = true,
		shout = true,
		prepareActionF= 2, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 13, 
		effectAction = 12, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0102] =
	{
		name = "雷霆星空", --xx
		desc = function (lv)
				return "对敌方随机3名英雄造成100%法术攻击伤害，第3回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 3, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_3, 
		damageRatio = 1,
		runType = 0, 
		bannerType = true,
		prepareActionF= 4, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 8, 
		effectAction = 7, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0103] =
	{
		name = "雷龙杀", --蝎毕岩
		desc = function (lv)
				return "对敌方随机3名英雄造成100%法术攻击伤害，第3回合释放，冷却时间3回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 3, 
		start = 3, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_3, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 12, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0104] =
	{
		name = "逆转丹行", --药万归
		desc = function (lv)
				return "对敌方随机3名英雄造成80%法术攻击伤害，第5回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 5, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_3, 
		damageRatio = 0.8,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 6, 
		effectAction = 12, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
------------------------------------------------------------------------------------------法攻直线

SkillManager[0105] =
	{
		name = "地灵束缚", --琥嘉
		desc = function (lv)
				return "对随机3个敌人造成150%法术伤害，第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_3, 
		damageRatio = 1.5,
		runType = 1, 
		--bannerType = true,
		--prepareActionF= 0,
		shakable = true, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction = 13, 
		effectAction = 12, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0106] =
	{
		name = "风刹湮罡", --云山
		desc = function (lv)
				return "对单个敌人造成120%法术伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 1.2,
		runType = 1, 
		bannerType = false,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0107] =
	{
		name = "狂龙风", --xx
		desc = function (lv)
				return "对敌方纵列英雄造成30%法术攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 0.3,
		runType = 1, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 2, 
		injureAction = 1, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0108] =
	{
		name = "金鼠啸", --金石
		desc = function (lv)
				return "对单个敌人造成75%法术伤害，35%概率使对方晕眩（失去1个回合行动力），第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 0.75,
		runType = 1, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 2, 
		injureAction = 1, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.35 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferStun(0,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,	
	}
SkillManager[0109] =
	{
		name = "凝火成束", --药万归
		desc = function (lv)
				return "对敌方纵列英雄造成30%法术攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 0.3,
		runType = 1, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 2, 
		injureAction = 1, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0110] =
	{
		name = "丹彩回光", -- 法犸
		desc = function (lv)
				return "治疗己方血量最少的英雄（280%），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_OWN_0, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 
		regeFunc = function(lv,att_all) 
				return att_all*2.8
			end,
	}
SkillManager[0111] =
	{
		name = "霹雳咒", --通玄长老
		desc = function (lv)
				return "对单个敌人造成100%法术伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 1,
		runType = 1, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0112] =
	{
		name = "狮山裂", --萧战
		desc = function (lv)
				return "对敌方纵列英雄造成35%法术攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 0.35,
		runType = 1, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 2, 
		injureAction = 1, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0113] =
	{
		name = "横剑摆渡", --柳翎
		desc = function (lv)
				return "对敌方纵列英雄造成35%法术攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 0.35,
		runType = 1, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 2, 
		injureAction = 1, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0114] =
	{
		name = "黄泉之路", --妖天啸
		desc = function (lv)
				return "对后排敌人造成70%法术伤害，第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 0.7,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0115] =
	{
		name = "青蛇夺魄", --青鳞
		desc = function (lv)
				return "对纵列敌人造成180%法术伤害，若目标被封印则多承受150%额外伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 1.8,
		runType = 1, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 2, 
		injureAction = 1, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				local thisBuffers ={BUFFER_TYPE_SEAL}
				for i = 1,#enemyBuffers do
					for j = 1,#thisBuffers do
						if enemyBuffers[i] == thisBuffers[j] then
					    return att_all*2.5
						end
					end
				end
				return att_all
			end,
	}
SkillManager[0116] =
	{
		name = "玄冰旋杀", --海波东
		desc = function (lv)
				return "对纵列敌人造成120%法术伤害，第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 1.2,
		runType = 1, 
		bannerType = false,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 2, 
		injureAction = 1, 
		--missileAction= 14, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0117] =
	{
		name = "英雄斩", --纳兰桀
		desc = function (lv)
				return "对敌方纵列英雄造成50%法术攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 0.5,
		runType = 1, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 2, 
		injureAction = 1, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0118] =
	{
		name = "雷电击", --雷尊者
		desc = function (lv)
				return "对单个敌人造成180%法术伤害，若自身已虚弱额外造成120%物理伤害，第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 1.8,
		runType = 1, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 14, 
		effectAction = 21, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
			local thisBuffers ={BUFFER_TYPE_DECREASE}
				for i = 1,#myBuffers do
					for j = 1,#thisBuffers do
						if myBuffers[i] == thisBuffers[j] then
					    return att_all*2.2
						end
					end
				end
				return att_all
			end,
	}
SkillManager[0119] =
	{
		name = "圣龙吐息", --
		desc = function (lv)
				return "对随机4个敌人造成220%法术攻击伤害，自身血量高于对方血量时增加30%攻击力，无视免疫和伤害减伤效果，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_4, 
		damageRatio = 2.2,
		runType = 0, 
		bannerType = true, 
		shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = true, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 13, 
		effectAction = 12, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				--local thisProbability = 0.6
				if srcHP > dstHP then
					return att_all*1.3
				else		
					return att_all
				end
			end,
	}
SkillManager[0120] =
	{
		name = "天妖血蛊", --
		desc = function (lv)
				return "对纵列敌人造成200%法术伤害，第1回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 2,
		runType = 1, 
		bannerType = false,
		shout = true, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 4, 
		effectAction = 10, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
------------------------------------------------------------------------------------------封印
SkillManager[0121] =
	{
		name = "万花冰镜", --海波东
		desc = function (lv)
				return "对随机3个敌人造成180%法术伤害，50%概率封印目标1回合，第2回合释放，冷却时间1个回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_3, 
		damageRatio = 1.8,
		runType = 0, 
		bannerType = true,
		shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 14, 
		effectAction = 21, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.5 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferFreeze(0,1) --crcreateBufferFreezeeateBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,		
	}
SkillManager[0122] =
	{
		name = "妖瞳控体", --青鳞
		desc = function (lv)
				return "65%概率封印随机2个敌人（失去1个回合行动能力），第2回合释放，冷却时间1个回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_2, 
		damageRatio = 1,
		runType = 0, 
		bannerType = true,
		shout = true,
		prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 4, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.65 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferSeal(0,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,	
	}
SkillManager[0123] =
	{
		name = "凝水牢", --萧玉
		desc = function (lv)
				return "入场时释放，80%概率使随机3个敌人冰冻（失去1个回合行动能力）" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ENTER, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_3, 
		damageRatio = 1,
		runType = 0, 
		bannerType = true,
		shout = true, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.8 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferFreeze(0,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,	
	}
SkillManager[0124] =
	{
		name = "天凰震慑", --九凤
		desc = function (lv)
				return "25%概率使敌方随机3名英雄失去1个回合行动能力，第3回合释放，冷却时间1个回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 3, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_3, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.25 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferSeal(0,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,	
	}
SkillManager[0125] =
	{
		name = "空间黑洞", --
		desc = function (lv)
				return "对随机2名敌人造成120%法术攻击伤害，80%概率使敌人被封印（失去1个回合行动能力），第2回合释放，冷却时间1个回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_2, 
		damageRatio = 1.2,
		runType = 0, 
		bannerType = true,
		shout = true,
		prepareActionF= 4, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 8, 
		effectAction = 7, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.8 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferSeal(0,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
------------------------------------------------------------------------------------------------概率法攻免疫
SkillManager[0126] = 
	{
		name = "灵火护体",--曜天火
		desc = function (lv)
				return "受到物理攻击时减少40%伤害" 			
			end,
		type = SkillManager_TYPE_PASSIVE_REDU,
		reduceFunc = function(lv,isMana,damage,probability) --必须，lv：技能等级；isMana：主动技能是否法术
				local thisIsMana = false --true:法术减伤;false:物理减伤
				local thisProbability = 1
				local thisPercent = 0.4
				local thisNumber = 0
				return (thisIsMana == isMana and thisProbability > probability) and damage*thisPercent or 0
			end,
	}
	
SkillManager[0127] = 
	{
		name = "魔法护环",--银老
		desc = function (lv)
				return "受到法术攻击时有30%概率免疫伤害" 			
			end,	
		type = SkillManager_TYPE_PASSIVE_IMAT,
		immunityAttackFunc = function(lv,isMana,probability) --必须，lv：技能等级；isMana：主动技能是否法术；probability：[0,1)随机数
				local thisIsMana = true  --true:法术免疫；false:物理免疫
				local thisProbability = 0.3 --[0,1]免疫概率，数值越大，概率越高
				return thisIsMana == isMana and thisProbability > probability
			end,
	}
SkillManager[0128] = 
	{
		name = "魔神之怒",--
		desc = function (lv)
				return "对所有敌人造成150%物理攻击伤害，50%概率使对手失去一次治疗机会，第3回合释放，冷却时间2回合" 			
			end,	

		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 3, 
		isMana = false, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 1.5,
		runType = 0, 
		bannerType = true,
		shout = true,
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--prepareActionF= 0, 
		missileAction= 10, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.5 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferCureless(0,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0129] = 
	{
		name = "魂影灭迹",--魂殿副殿主  
		desc = function (lv)
				return "受到法术攻击时有40%概率免疫伤害" 			
			end,	
		type = SkillManager_TYPE_PASSIVE_IMAT,
		immunityAttackFunc = function(lv,isMana,probability) --必须，lv：技能等级；isMana：主动技能是否法术；probability：[0,1)随机数
				local thisIsMana = true  --true:法术免疫；false:物理免疫
				local thisProbability = 0.4 --[0,1]免疫概率，数值越大，概率越高
				return thisIsMana == isMana and thisProbability > probability
			end,
	}
SkillManager[0130] = 
	{
		name = "海皇降世",--米特尔
		desc = function (lv)
				return "受到物理攻击时有30%概率免疫伤害" 			
			end,	
		type = SkillManager_TYPE_PASSIVE_IMAT,
		immunityAttackFunc = function(lv,isMana,probability) --必须，lv：技能等级；isMana：主动技能是否法术；probability：[0,1)随机数
				local thisIsMana = false  --true:法术免疫；false:物理免疫
				local thisProbability = 0.3 --[0,1]免疫概率，数值越大，概率越高
				return thisIsMana == isMana and thisProbability > probability
			end,
	}
SkillManager[0131] = 
	{
		name = "孤鹰傲世",--xxx
		desc = function (lv)
				return "受到物理攻击时有20%概率免疫伤害" 			
			end,	
		type = SkillManager_TYPE_PASSIVE_IMAT,
		immunityAttackFunc = function(lv,isMana,probability) --必须，lv：技能等级；isMana：主动技能是否法术；probability：[0,1)随机数
				local thisIsMana = false  --true:法术免疫；false:物理免疫
				local thisProbability = 0.2 --[0,1]免疫概率，数值越大，概率越高
				return thisIsMana == isMana and thisProbability > probability
			end,
	}
SkillManager[0132] = 
	{
		name = "炎之族人",--火炫
		desc = function (lv)
				return "受到物理攻击时有20%概率免疫伤害" 			
			end,	
		type = SkillManager_TYPE_PASSIVE_IMAT,
		immunityAttackFunc = function(lv,isMana,probability) --必须，lv：技能等级；isMana：主动技能是否法术；probability：[0,1)随机数
				local thisIsMana = false  --true:法术免疫；false:物理免疫
				local thisProbability = 0.2 --[0,1]免疫概率，数值越大，概率越高
				return thisIsMana == isMana and thisProbability > probability
			end,
	}
SkillManager[0133] = 
	{
		name = "龙翔九天",--烛离
		desc = function (lv)
				return "替补上阵时立刻释放，为己方前排增加护盾（减少30%攻击伤害，抵挡2次攻击）" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ENTER,
		--start属性无效
		isMana = true,
		target = SkillManager_OWN_RANDOM_3,
		runType = 0,
		bannerType = false,
		ignoreIMRE = false,
		attackAction = 1,
		injureAction = 1,
		--prepareActionF= 0,
		--missileAction= 0,
		effectAction = 20,  
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferReduction(3,2,0.3,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0134] = 
	{
		name = "妖蛊蚀体",--
		desc = function (lv)
				return "受到法术攻击时有40%概率免疫伤害" 			
			end,	
		type = SkillManager_TYPE_PASSIVE_IMAT,
		immunityAttackFunc = function(lv,isMana,probability) --必须，lv：技能等级；isMana：主动技能是否法术；probability：[0,1)随机数
				local thisIsMana = true  --true:法术免疫；false:物理免疫
				local thisProbability = 0.4 --[0,1]免疫概率，数值越大，概率越高
				return thisIsMana == isMana and thisProbability > probability
			end,
	}
------------------------------------------------------------------------------------------------------------高血量攻击加成
SkillManager[0135] =
	{
		name = "风光刃",--古道
		desc = function (lv)
				return "对所有敌人造成60%物理伤害，45%概率增加80%攻击力，第1回合释放，冷却时间3回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 3, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 0.6,
		runType = 0, 
		bannerType = false, 
		prepareActionF= 2, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 12, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				local thisProbability = 0.45
				if thisProbability > probability then
					return att_all*1.8
				else
					return att_all
				end
			end,
	}
SkillManager[0136] =
	{
		name = "风火木壁",--云棱
		desc = function (lv)
				return "攻击目标血量高于自身时，增加30%基础攻击" 			
			end,
		type = SkillManager_TYPE_PASSIVE_HPHP,
		addFunc = function(lv,att,srcHP,dstHP) --必须，lv：技能等级；att：角色的基础攻击；srcHP、dstHP：攻击方、被攻击方HP
				local thisPercent = 0.3 --[0,1]攻击增幅百分比
				local thisNumber = 0  --[0,+)攻击增幅自然数
				--     dstHP > srcHP  --更改判断符号
				return dstHP > srcHP and att * thisPercent + thisNumber or 0
			end,
	}

--------------------------------------------------------------------------------------后排单体法攻失去行动力
SkillManager[0137] =
	{
		name = "锋芒影刺", --若琳导师
		desc = function (lv)
				return "对前排敌人造成150%法术伤害，35%概率使对方晕眩（失去1个回合行动力）第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 1.5,
		runType = 0, 
		bannerType = false,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 4, 
		missileAction= 0, 
		effectAction = 20, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,

			setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.35 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferStun(0,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,

			
	}
SkillManager[0138] =
	{
		name = "冻天掌", 
		desc = function (lv)
				return "对单个敌人造成250%法术伤害，40%概率使对方失去1个回合行动力，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 2.5,
		runType = 0, 
		bannerType = true,
		shout = true,
		prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 4, 
		missileAction= 0, 
		effectAction = 20, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,	
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.4 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferFreeze(0,1) --crcreateBufferFreezeeateBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,			
	}
SkillManager[0139] =
	{
		name = "魔音入耳", --金石
		desc = function (lv)
				return "替补上阵时立刻释放，100%概率使血量最多的敌人晕眩（失去1个回合行动力）" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ENTER,
		--start属性无效
		isMana = true,
		target = SkillManager_SINGLE_100,
		needRun = false,
		bannerType = false,
		ignoreIMRE = false,
		attackAction = 0,
		injureAction = 1,
		--prepareAction= 0,
		--missileAction= 0,
		effectAction = 20,  	
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferStun(0,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,				
	}
--------------------------------------------------------------------------------------------回春
SkillManager[0140] =
	{
		name = "沐春风", --
		desc = function (lv)
				return "治疗己方全体英雄（80%），第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = true, 
		target = SkillManager_OWN_ALL, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 
		regeFunc = function(lv,att_all) 
				return att_all*0.8
			end,
	}
SkillManager[0141] =
	{
		name = "沐春风", --
		desc = function (lv)
				return "使己方随机3名英雄10%概率获得回春（持续回血2回合），第2回合释放，冷却时间3回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 3, 
		start = 2, 
		isMana = true, 
		target = SkillManager_OWN_RANDOM_3, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferRege(0,2,att,0.3) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0142] =
	{
		
		name = "清风薪荣", -- 法犸
		desc = function (lv)
				return "治疗己方全体英雄（350%），第2回合释放，冷却时间3回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 3, 
		start = 2, 
		isMana = true, 
		target = SkillManager_OWN_ALL, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false,
		--shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 
		regeFunc = function(lv,att_all) 
				return att_all*3.5
			end,
	}
---------------------------------------------------------------------------------------------------------------回合结算
SkillManager[0143] = 
	{
		name = "烽火连天",--加刑天 韩月
		desc = function (lv)
				return "每个回合行动结束时，回复25%生命" 			
			end,
		type = SkillManager_TYPE_PASSIVE_FINI,

		finishFunc = function(lv,probability) --必须，lv：技能等级；返回：
				local thisProbability    = 1
				local thisAttackPercent  = 0 --[0,1]攻击百分比,谁的回合谁增加攻击
				local thisDefencePercent = 0 --[0,1]防御百分比,谁的回合谁增加防御
				local thisHPPercent      = 0.25 --[0,1]回血百分比,谁的回合谁回复血量
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,
	}
SkillManager[0144] = 
	{
		name = "金雁还春",--雁落天
		desc = function (lv)
				return "每个回合行动结束时，30%概率回复30%生命" 			
			end,
		type = SkillManager_TYPE_PASSIVE_FINI,

		finishFunc = function(lv,probability) --必须，lv：技能等级；返回：
				local thisProbability    = 0.3
				local thisAttackPercent  = 0 --[0,1]攻击百分比,谁的回合谁增加攻击
				local thisDefencePercent = 0 --[0,1]防御百分比,谁的回合谁增加防御
				local thisHPPercent      = 0.3 --[0,1]回血百分比,谁的回合谁回复血量
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,
	}
SkillManager[0145] = 
	{
		name = "雷霆光铧 ",--柳翎
		desc = function (lv)
				return "每个回合行动结束时，20%概率回复15%生命" 			
			end,
		type = SkillManager_TYPE_PASSIVE_FINI,

		finishFunc = function(lv,probability) --必须，lv：技能等级；返回：
				local thisProbability    = 0.2
				local thisAttackPercent  = 0 --[0,1]攻击百分比,谁的回合谁增加攻击
				local thisDefencePercent = 0 --[0,1]防御百分比,谁的回合谁增加防御
				local thisHPPercent      = 0.15 --[0,1]回血百分比,谁的回合谁回复血量
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,
	}
SkillManager[0146] = 
	{
		name = "惊雷破军",--黑擎，邙天尺
		desc = function (lv)
				return "攻击敌人并造成伤害时，100%概率永久降低对方30%基础防御力" 			
			end,
		type = SkillManager_TYPE_PASSIVE_SETA,
		sattlementFunc = function(lv,probability) --必须，lv：技能等级；
				local thisProbability    = 1
				local thisAttackPercent  = 0 --[-1,0)攻击百分比,被攻击方降低攻击；[0,1]攻击方增加攻击
				local thisDefencePercent = -0.3 --[-1,0)防御百分比,被攻击方降低防御；[0,1]攻击方增加防御
				local thisHPPercent      = 0 --[0,1] 吸血百分比,攻击方吸血
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,
	}
SkillManager[0147] = 
	{
		name = "青蛇妖瞳",--青鳞
		desc = function (lv)
				return "替补上阵时立刻释放，100%概率封印血量最多的1个敌人（失去2个回合行动能力）" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ENTER, 
		--start = 3, 
		isMana = true, 
		target = SkillManager_SINGLE_100, 
		--damageRatio = 1.8,
		runType = 0, 
		bannerType = true,
		shout = true,
		prepareActionF= 3, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 4, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferSeal(1,2) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0148] = 
	{
		name = "雷蛇舞",--翎泉
		desc = function (lv)
				return "每个回合行动结束时，50%概率永久提升5%基础防御力" 			
			end,
		type = SkillManager_TYPE_PASSIVE_FINI,

		finishFunc = function(lv,probability) --必须，lv：技能等级；返回：
				local thisProbability    = 0.5
				local thisAttackPercent  = 0 --[0,1]攻击百分比,谁的回合谁增加攻击
				local thisDefencePercent = 0.05 --[0,1]防御百分比,谁的回合谁增加防御
				local thisHPPercent      = 0 --[0,1]回血百分比,谁的回合谁回复血量
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,
	}
SkillManager[0149] = 
	{
		name = "风沙甘霖术",--风尊者
		desc = function (lv)
				return "对后排敌人造成180%物理伤害，100%概率使对方虚弱（减少95%攻击力，持续1次）第1回合释放，冷却时间3回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 3, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 1.8,
		runType = 0, 
		bannerType = true, 
		shout = true,
		shakable = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 10, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
							return att_all
					end,
		
		setupBuffer = function(lv,att,damage,probability)
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferDecrease(30,1,0.95,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0150] = 
	{
		name = "百魂锁甲",--九天尊
		desc = function (lv)
				return "为自身增加护盾（减少35%伤害，抵挡3次攻击），第1回合释放，冷却时间3回合" 			
			end,
			type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 1, 
		isMana = false, 
		target = SkillManager_OWN_SELF, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--prepareActionF = 0, 
		--prepareActionB = 0, 
		--missileAction= 0, 
		effectAction = 20, 		
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferReduction(4,3,0.35,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0151] = 
	{
		name = "九龙诀",--
		desc = function (lv)
				return "每个回合行动结束时，80%概率提升20%基础攻击力" 			
			end,
		type = SkillManager_TYPE_PASSIVE_FINI,

		finishFunc = function(lv,probability) --必须，lv：技能等级；返回：
				local thisProbability    = 0.8
				local thisAttackPercent  = 0.2 --[0,1]攻击百分比,谁的回合谁增加攻击
				local thisDefencePercent = 0 --[0,1]防御百分比,谁的回合谁增加防御
				local thisHPPercent      = 0 --[0,1]回血百分比,谁的回合谁回复血量
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,
	}
---------------------------------------------------------------------------------------------------------------减伤
SkillManager[0152] =
	{
		name = "青木护体",--
		desc = function (lv)
				return "为自身增加护盾（减少40%攻击伤害，抵挡2次攻击），第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = false, 
		target = SkillManager_OWN_SELF, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false, 
		prepareActionF= 3, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferReduction(4,2,0.4,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
---------------------------------------------------------------------------------------------------------------己方死亡人数加成
	SkillManager[0153] =
	{
		name = "清风剑影", --铁剑尊者
		desc = function (lv)
				return "对前排敌人造成115%物理伤害，第3回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 3, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 1.15,
		runType = 0, 
		bannerType = false, 
		shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 10, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0154] =
	{
		name = "毁灭之印", --魂天帝
		desc = function (lv)
				return "对所有敌人造成200%法术攻击伤害，无视免疫和减伤效果，第3回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 3, 
		isMana = true, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 2,
		runType = 0, 
		bannerType = true,
		shout = true,
		--prepareActionF= 2, 
		--ignoreIMRE = true, 
		--attackAction = 1, 
		--injureAction = 0, 
		--missileAction= 0, 
		--effectAction = 12, 
		prepareActionF = 0,
		prepareActionB = 4, 
		ignoreIMRE = true, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= -8, 
		effectAction = 0, 
		shakable = true,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0155] =
	{
		name = "移形换影", --
		desc = function (lv)
				return "增加己方死亡人数乘以20%的基础攻击力" 			
			end,
		type = SkillManager_TYPE_PASSIVE_DEAD,
		addFunc = function(lv,att,myDeath,enemyDeath) --必须，lv：技能等级；att：角色的基础攻击；myDeath：主动方的死亡人数；enemyDeath：被动方的死亡人数
				return att * myDeath * 0.2 --人数*每单位的伤害值
			end,
	}
	
SkillManager[0156] =
	{
		name = "画地为牢",--萧媚
		desc = function (lv)
				return "发动攻击时，攻击目标附有中毒、灼烧、诅咒、虚弱状态时，增加30%攻击" 			
			end,
		type = SkillManager_TYPE_PASSIVE_BUFF,
		addFunc = function(lv,att,enemyBuffers) --必须，lv：技能等级；att：角色的基础攻击；enemyBuffers：被动方身上的bufferIDs表
				local thisBuffers = {BUFFER_TYPE_POISON, BUFFER_TYPE_BURN, BUFFER_TYPE_CURSE, BUFFER_TYPE_DECREASE} --攻击增幅触发的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua）
				local thisPercent = 0.3  --[0,1]攻击增幅百分比
				local thisNumber = 0   --[0,+)攻击增幅自然数
				for i = 1,#enemyBuffers do
					for j = 1,#thisBuffers do
						if enemyBuffers[i] == thisBuffers[j] then
							return att * thisPercent + thisNumber
						end
					end
				end
				return 0
			end,
	}

---------------------------------------------------------------------------------------------------------------法攻降攻持续
SkillManager[0157] =
	{
		name = "千足虫掌", --蜈崖
		desc = function (lv)
				return "对敌方随机1名英雄造成60%法术攻击伤害，30%概率降低对方30%基础攻击（持续1次），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_1, 
		damageRatio = 0.6,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 4, 
		missileAction= 5, 
		effectAction = 21, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.3 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferDecrease(0,1,0.3,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,		
	}
SkillManager[0158] =
	{
		name = "黄泉指", --xxx
		desc = function (lv)
				return "对敌方随机1名英雄造成40%法术攻击伤害，10%概率降低对方10%基础攻击（持续1次），第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_1, 
		damageRatio = 0.4,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 6, 
		effectAction = 12, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferDecrease(0,1,0.1,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,		
	}
SkillManager[0159] =
	{
		name = "云龙身纵", --烛离
		desc = function (lv)
				return "对单个敌人造成320%物理攻击伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 3.2,
		runType = 1, 
		bannerType = true,
		shout = true,
		prepareActionF= 1, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 1, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,	
	}
SkillManager[0160] =
	{
		name = "落雷诀", --天雷子
		desc = function (lv)
				return "对单个敌人造成200%物理伤害，第3回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 3, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 2,
		runType = 0, 
		bannerType = false, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 14, 
		effectAction = 21, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,	
	}
SkillManager[0161] =
	{
		name = "玄火刀", --辰闲
		desc = function (lv)
				return "对敌方随机1名英雄造成80%法术攻击伤害，20%概率降低对方50%基础攻击（持续2次），第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_1, 
		damageRatio = 0.8,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 12, 
		effectAction = 0, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.2 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferDecrease(0,2,0.5,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,		
	}
SkillManager[0162] =
	{
		name = "银鹰掠地", --柳翎
		desc = function (lv)
				return "对敌方随机1名英雄造成80%法术攻击伤害，20%概率降低对方50%基础攻击（持续2次），第2回合释放，冷却时间3回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 3, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_1, 
		damageRatio = 0.8,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 2, 
		effectAction = 0, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.2 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferDecrease(0,2,0.5,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,		
	}
SkillManager[0163] =
	{
		name = "死神之指", --魂殿副殿主
		desc = function (lv)
				return "对生命最少的英雄造成220%法术攻击伤害，自身血量高于对方血量时，增加50%攻击力，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2,
		isMana = true, 
		target = SkillManager_SINGLE_0, 
		damageRatio = 2.2,
		runType = 0, 
		bannerType = true,
		shout = true,
		prepareActionF = 4, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 11, 
		effectAction = 10, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers)
				if srcHP > dstHP then
					return att_all*1.5
				else
					return att_all
				end 
			end,
	}
SkillManager[0164] =
	{
		name = "海浪滔天", --沈云
		desc = function (lv)
				return "对敌方随机1名英雄造成150%法术攻击伤害，80%概率降低对方30%基础攻击（持续1次），第4回合释放，冷却时间3回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 3, 
		start = 4,
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_1, 
		damageRatio = 1.5,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 2, 
		effectAction = 0, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.8 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferDecrease(0,1,0.3,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,		
	}
---------------------------------------------------------------------------------------------------------免疫减血虚弱
SkillManager[0165] = --skillmanager[0165] to [0169]
	{
		name = "远古守护",--费天，墨巴斯，纳兰桀
		desc = function (lv)
				return "对中毒，灼烧，诅咒，虚弱免疫" 			
			end,	
		type = SkillManager_TYPE_PASSIVE_IMBF,
		immunityBufferFunc = function(lv,bufferID) --必须，lv：技能等级；bufferID：待检测的bufferID
				local thisBufferIDs = {BUFFER_TYPE_POISON, BUFFER_TYPE_BURN, BUFFER_TYPE_CURSE, BUFFER_TYPE_DECREASE} --免疫的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua）
				for i = 1,#thisBufferIDs do
					if thisBufferIDs[i] == bufferID then
						return true
					end
				end
				return false
			end,
	}
SkillManager[0165] = --skillmanager[0165] to [0169]
	{
		name = "龙源守护",--南龙王，唐震
		desc = function (lv)
				return "受到攻击伤害时，增加8%基础防御" 			
			end,
		type = SkillManager_TYPE_PASSIVE_SETP,
		sattlementFunc = function(lv,probability) --必须，lv：技能等级；
				local thisProbability    = 1
				local thisAttackPercent  = 0 --[-1,0)攻击百分比,攻击方降低攻击；[0,1]被攻击方增加攻击
				local thisDefencePercent = 0.08 --[-1,0)防御百分比,攻击方降低防御；[0,1]被攻击方增加防御
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent
				else
					return 0,0
				end
			end,
	}
---------------------------------------------------------------------------------------------------------免疫无法行动
SkillManager[0170] = --skillmanager[0170] to [0174]
	{
		name = "幻魂身法",--冰符，萧鼎
		desc = function (lv)
				return "对冰冻、晕眩、封印免疫" 			
			end,	
		type = SkillManager_TYPE_PASSIVE_IMBF,
		immunityBufferFunc = function(lv,bufferID) --必须，lv：技能等级；bufferID：待检测的bufferID
				local thisBufferIDs = {BUFFER_TYPE_FREEZE,BUFFER_TYPE_STUN,BUFFER_TYPE_SEAL} --免疫的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua）
				for i = 1,#thisBufferIDs do
					if thisBufferIDs[i] == bufferID then
						return true
					end
				end
				return false
			end,
	}
SkillManager[0171] = --skillmanager[0170] to [0174]
	{
		name = "幻魂大法",--青海尊者
		desc = function (lv)
				return "死亡时触发，对敌方前排造成270%法术伤害，80%概率使目标失去2次被治疗机会" 			
			end,	
		type = SkillManager_TYPE_ACTIVE_EXIT, --属性含义参照SkillManager_TYPE_ACTIVE_ROUND
		--start属性无效
		isMana = true,
		target = SkillManager_MULTI_ROW_1,
		needRun = false,
		bannerType = false,
		shout = true,
		shakable = true,
		ignoreIMRE = false,
		attackAction = 3,
		injureAction = 0,
		prepareAction= 4,
		--missileAction= -4, 
		effectAction = 17,
		damageRatio = 2.7,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,

			setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.8 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferCureless(1,2) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
	
SkillManager[0172] = --skillmanager[0170] to [0174]
	{
		name = "百鬼聚灵",--摘星老鬼
		desc = function (lv)
				return "60%概率封印后排敌人（失去1个回合行动能力），第2回合释放，冷却时间2个回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 1,
		runType = 0, 
		bannerType = true,
		shout = true,
		prepareActionF= 4, 
		ignoreIMRE = false, 
		attackAction = 3, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.6--[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferSeal(0,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0173] =
	{
		name = "彩云追月", --韩月
		desc = function (lv)
				return "对后排单个敌人造成100%法术伤害，80%概率冻结目标1回合，第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_BACK, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true, 
		--shout = true,
		--shakable = true,
		--prepareActionF= 4, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 5, 
		effectAction = 7, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,

			setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.80 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferFreeze(0,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
--------------------------------------------------------------------------------------------------------buff攻击加成
SkillManager[0175] =
	{
		name = "狂狮怒吼",--萧战
		desc = function (lv)
				return "发动攻击时，攻击目标附有中毒、灼烧、虚弱状态时，增加25%攻击" 			
			end,
		type = SkillManager_TYPE_PASSIVE_BUFF,
		addFunc = function(lv,att,enemyBuffers) --必须，lv：技能等级；att：角色的基础攻击；enemyBuffers：被动方身上的bufferIDs表
				local thisBuffers = {BUFFER_TYPE_POISON, BUFFER_TYPE_BURN, BUFFER_TYPE_CURSE, BUFFER_TYPE_DECREASE} --攻击增幅触发的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua）
				local thisPercent = 0.25  --[0,1]攻击增幅百分比
				local thisNumber = 0   --[0,+)攻击增幅自然数
				for i = 1,#enemyBuffers do
					for j = 1,#thisBuffers do
						if enemyBuffers[i] == thisBuffers[j] then
							return att * thisPercent + thisNumber
						end
					end
				end
				return 0
			end,
	}
SkillManager[0176] =
	{
		name = "幻海潮升",--沈云
		desc = function (lv)
				return "发动攻击时，攻击目标附有冰冻、晕眩、封印状态时，增加10%攻击" 			
			end,
		type = SkillManager_TYPE_PASSIVE_BUFF,
		addFunc = function(lv,att,enemyBuffers) --必须，lv：技能等级；att：角色的基础攻击；enemyBuffers：被动方身上的bufferIDs表
				local thisBuffers = {BUFFER_TYPE_FREEZE,BUFFER_TYPE_STUN,BUFFER_TYPE_SEAL} --攻击增幅触发的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua）
				local thisPercent = 0.1  --[0,1]攻击增幅百分比
				local thisNumber = 0   --[0,+)攻击增幅自然数
				for i = 1,#enemyBuffers do
					for j = 1,#thisBuffers do
						if enemyBuffers[i] == thisBuffers[j] then
							return att * thisPercent + thisNumber
						end
					end
				end
				return 0
			end,
	}
SkillManager[0177] =
	{
		name = "魅蛇毒气",--月媚
		desc = function (lv)
				return "发动攻击时，攻击目标附有冰冻、晕眩、封印状态时，增加20%攻击" 			
			end,
		type = SkillManager_TYPE_PASSIVE_BUFF,
		addFunc = function(lv,att,enemyBuffers) --必须，lv：技能等级；att：角色的基础攻击；enemyBuffers：被动方身上的bufferIDs表
				local thisBuffers = {BUFFER_TYPE_FREEZE,BUFFER_TYPE_STUN,BUFFER_TYPE_SEAL} --攻击增幅触发的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua）
				local thisPercent = 0.2  --[0,1]攻击增幅百分比
				local thisNumber = 0   --[0,+)攻击增幅自然数
				for i = 1,#enemyBuffers do
					for j = 1,#thisBuffers do
						if enemyBuffers[i] == thisBuffers[j] then
							return att * thisPercent + thisNumber
						end
					end
				end
				return 0
			end,
	}
--------------------------------------------------------------------------------------------------------全体法攻
SkillManager[0178] =
	{
		name = "焰分噬浪", --药老
		desc = function (lv)
				return "对所有敌人造成250%法术伤害，80%概率使敌人虚弱（攻击减少30%，持续2次），第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 2.5,
		runType = 4, 
		bgAction = 1,
		bannerType = true,
		shout = true,
		shakable = true,
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 2, 
		prepareActionF= 7, 
		prepareActionB= 8, 
		missileAction= -11, 
		effectAction = 20, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.8 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferDecrease(3,2,0.3,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0179] =
	{
		name = "鸾鸣惊魂", --
		desc = function (lv)
				return "对敌方全体英雄造成6%法术攻击伤害，第3回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 3, 
		isMana = true, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 0.06,
		runType = 0, 
		--bannerType = true,
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--prepareActionF= 0, 
		missileAction= 10, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
--------------------------------------------------------------------------------------------------入场技
SkillManager[0180] =
	{ 
		name = "龙啸九天",--
		desc = function (lv)
				return "替补上阵时立刻释放，50%概率为己方英雄增加护盾（减少30%攻击伤害，持续2次）" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ENTER,
		--start属性无效
		isMana = true,
		target = SkillManager_OWN_OTHER,
		runType = 0,
		--bannerType = true,
		ignoreIMRE = false,
		attackAction = 1,
		injureAction = 1,
		--prepareActionF= 0,
		--missileAction= 0,
		effectAction = 20,  
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.5 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferReduction(0,2,0.3,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0181] =
	{ 
		name = "千风罡",--纳兰嫣然
		desc = function (lv)
				return "替补上阵时立刻释放，对全体敌人造成100%物理伤害，50%概率使对方虚弱（减少20%攻击力，持续2次）" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ENTER,
		--start属性无效
		isMana = false,
		target = SkillManager_MULTI_ALL,
		damageRatio = 1,
		runType = 0,
		bannerType = true,
		shout = true,
		shakable = true,
		ignoreIMRE = false,
		attackAction = 1,
		injureAction = 0,
		--prepareActionF= 0,
		missileAction= 3,
		effectAction = 10,  
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.5 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferDecrease(2,2,0.2,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0182] =
	{ 
		name = "翔叶术",--琥嘉
		desc = function (lv)
				return "替补上阵时立刻释放，35%概率使随机4名敌人虚弱（减少50%攻击力，持续1次）" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ENTER,
		--start属性无效
		isMana = true,
		target = SkillManager_MULTI_RANDOM_4,
		damageRatio = 0.2,
		runType = 0,
		bannerType = false,
		ignoreIMRE = false,
		attackAction = 0,
		injureAction = 1,
		--prepareActionF= 0,
		--missileAction= 0,
		effectAction = 20,  
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.35 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferDecrease(3,1,0.5,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0183] =
	{ 
		name = "风游春雪",--韩雪
		desc = function (lv)
				return "替补上阵时立刻释放，50%概率使敌方随机2名英雄失去下一回合行动力" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ENTER,
		--start属性无效
		isMana = false,
		target = SkillManager_MULTI_RANDOM_2,
		runType = 0,
		--bannerType = true,
		ignoreIMRE = false,
		attackAction = 0,
		injureAction = 1,
		--prepareActionF= 0,   
		--missileAction= 0,
		effectAction = 20,  
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.5 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferStun(0,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,	
	}
SkillManager[0184] =
	{ 
		name = "青炫风杀",--林修崖
		desc = function (lv)
				return "替补上阵时立刻释放，对血量最高的敌人造成300%物理伤害，自身血量高于对方血量时增加30%攻击力，无视伤害减免" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ENTER,
		--start属性无效
		isMana = false,
		target = SkillManager_SINGLE_100,
		damageRatio = 3,
		runType = 0,
		bannerType = true,
		shout = true,
		shakable = true,
		ignoreIMRE = true,
		attackAction = 1,
		injureAction = 0,
		--prepareActionF= 0,
		missileAction= 4,
		effectAction = 10,  
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				if srcHP > dstHP then
					return att_all*1.3
				else
					return att_all
				end
			end,
	}
SkillManager[0185] =
	{ 
		name = "金属翻天",--
		desc = function (lv)
				return "替补上阵时立刻释放，对敌方随机4名英雄造成80%物理攻击伤害，20%概率减少敌人20%攻击力（持续2次）" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ENTER,
		--start属性无效
		isMana = false,
		target = SkillManager_MULTI_RANDOM_4,
		damageRatio = 0.8,
		runType = 0,
		--bannerType = true,
		ignoreIMRE = false,
		attackAction = 1,
		injureAction = 0,
		--prepareActionF= 0,
		missileAction= 13,
		effectAction = 12,  
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.2 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferDecrease(0,2,0.2,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0186] =
	{ 
		name = "丹香入骨",--丹塔长老
		desc = function (lv)
				return "对中毒和灼烧效果免疫" 			
			end,
		type = SkillManager_TYPE_PASSIVE_IMBF,
		immunityBufferFunc = function(lv,bufferID,probability) --必须，lv：技能等级；bufferID：待检测的bufferID
				local thisProbability = 1
				local thisBufferIDs = {BUFFER_TYPE_POISON, BUFFER_TYPE_BURN} --免疫的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua）
				if thisProbability > probability then
					for i = 1,#thisBufferIDs do
						if thisBufferIDs[i] == bufferID then
							return true
						end
					end
				end
				return false
			end,
	}
SkillManager[0187] =
	{ 
		name = "影血闪",--
		desc = function (lv)
				return "替补上阵时立刻释放，60%概率增加己方全体英雄20%基础攻击（持续2次）" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ENTER,
		--start属性无效
		isMana = true,
		target = SkillManager_OWN_OTHER,
		runType = 0,
		--bannerType = true,
		ignoreIMRE = false,
		attackAction = 1,
		injureAction = 1,
		--prepareActionF= 0,
		--missileAction= 0,
		effectAction = 20,  
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.6 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferIncrease(0,2,0.2,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0188] =
	{ 
		name = "大杀四方",--叶重
		desc = function (lv)
				return "替补上阵时立刻释放，60%概率增加己方英雄15%基础攻击（持续2次）" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ENTER,
		--start属性无效
		isMana = true,
		target = SkillManager_OWN_OTHER,
		runType = 0,
		--bannerType = true,
		ignoreIMRE = false,
		attackAction = 1,
		injureAction = 1,
		--prepareActionF= 0,
		--missileAction= 0,
		effectAction = 20,  
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.6 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferIncrease(0,2,0.15,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0189] =
	{ 
		name = "浴火重生",--xx
		desc = function (lv)
				return "替补上阵时立刻释放，回复己方全体英雄大量生命" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ENTER,
		--start属性无效
		isMana = true,
		target = SkillManager_OWN_OTHER,
		runType = 0,
		bannerType = true,
		ignoreIMRE = false,
		attackAction = 1,
		injureAction = 1,
		prepareActionF= 3,
		--missileAction= 0,
		effectAction = 20,  
		--恢复生命
		regeFunc = function(lv,att_all) 
				return att_all*0.5
			end,
	}
---------------------------------------------------------------------------------------------伤害结算
SkillManager[0190] = 
	{
		name = "电闪雷鸣",--xx
		desc = function (lv)
				return "攻击对方并造成伤害时，30%概率永久减少对方10%基础防御力" 			
			end,
		type = SkillManager_TYPE_PASSIVE_SETA,
		sattlementFunc = function(lv,probability) --必须，lv：技能等级；
				local thisProbability    = 0.3
				local thisAttackPercent  = 0 --[-1,0)攻击百分比,被攻击方降低攻击；[0,1]攻击方增加攻击
				local thisDefencePercent = -0.1 --[-1,0)防御百分比,被攻击方降低防御；[0,1]攻击方增加防御
				local thisHPPercent      = 0 --[0,1] 吸血百分比,攻击方吸血
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,
	}
SkillManager[0191] = 
	{
		name = "冰毒双修",
		desc = function (lv)
				return "对中毒和冰冻效果免疫" 			
			end,
		type = SkillManager_TYPE_PASSIVE_IMBF,
		immunityBufferFunc = function(lv,bufferID,probability) --必须，lv：技能等级；bufferID：待检测的bufferID
				local thisProbability = 1
				local thisBufferIDs = {BUFFER_TYPE_POISON, BUFFER_TYPE_FREEZE} --免疫的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua）
				if thisProbability > probability then
					for i = 1,#thisBufferIDs do
						if thisBufferIDs[i] == bufferID then
							return true
						end
					end
				end
				return false
			end,
	}
SkillManager[0192] = 
	{
		name = "寂灭黄泉",--
		desc = function (lv)
				return "对单个敌人造成350%法术攻击伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 3.5,
		runType = 0, 
		bannerType = false,
		shakable = true,
		--prepareActionF= 0, 
		ignoreIMRE = true, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 12, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0193] = 
	{
		name = "战神源力",--药星极
		desc = function (lv)
				return "己方全体英雄45%概率提升20%攻击力（持续1次），第3回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 3, 
		isMana = false, 
		target = SkillManager_OWN_ALL, 
		damageRatio = 0.9,
		runType = 0, 
		bannerType = true, 
		shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1,
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.45 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferIncrease(2,1,0.2,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0194] = 
	{
		name = "紫月扇影",--辰闲
		desc = function (lv)
				return "攻击对方并造成伤害时，20%概率永久减少对方5%基础防御力" 			
			end,
		type = SkillManager_TYPE_PASSIVE_SETA,
		sattlementFunc = function(lv,probability) --必须，lv：技能等级；
				local thisProbability    = 0.2
				local thisAttackPercent  = 0 --[-1,0)攻击百分比,被攻击方降低攻击；[0,1]攻击方增加攻击
				local thisDefencePercent = -0.05 --[-1,0)防御百分比,被攻击方降低防御；[0,1]攻击方增加防御
				local thisHPPercent      = 0 --[0,1] 吸血百分比,攻击方吸血
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,
	}
SkillManager[0195] = 
	{
		name = "天妖复仇",
		desc = function (lv)
				return "受到攻击伤害时，60%概率对前排敌人进行反击，造成150%物理攻击伤害" 			
			end,
		type = SkillManager_TYPE_ACTIVE_COUNTER,--属性含义参照SkillManager_TYPE_ACTIVE_ROUND
		--start属性无效
		isMana = false,
		target = SkillManager_MULTI_ROW_1,
		counterProbability = 0.6,--反击概率
		damageRatio = 1.5,
		attackAction = 0,
		injureAction = 0,
		--prepareActionF= 0,
		--missileAction= 0,
		bannerType = fasle,
		effectAction = 0,
		runType = 0,
		ignoreIMRE = false,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers)
				return att_all
			end,
	}
SkillManager[0196] = 
	{
		name = "无之旋涡",--，柳擎
		desc = function (lv)
				return "对除了封印，晕眩，冰冻负面状态之外的所有负面状态免疫" 			
			end,
		type = SkillManager_TYPE_PASSIVE_IMBF,
		immunityBufferFunc = function(lv,bufferID) --必须，lv：技能等级；bufferID：待检测的bufferID
				local thisBufferIDs = {BUFFER_TYPE_POISON, BUFFER_TYPE_BURN, BUFFER_TYPE_CURSE, BUFFER_TYPE_DECREASE,BUFFER_TYPE_CURELESS} --免疫的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua）
				for i = 1,#thisBufferIDs do
					if thisBufferIDs[i] == bufferID then
						return true
					end
				end
				return false
			end,
	}
SkillManager[0197] = 
	{
		name = "枯魂护体",--魂千陌
		desc = function (lv)
				return "为己方随机2名英雄增加护盾（减少80%攻击伤害，抵挡1次攻击），第2回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 2, 
		isMana = false, 
		target = SkillManager_OWN_RANDOM_2, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false,
		prepareActionF= 4, 
		ignoreIMRE = false, 
		attackAction = 3, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferReduction(8,1,0.8,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0198] = 
	{
		name = "红尘一啸",--
		desc = function (lv)
				return "攻击对方并造成伤害时，10%概率永久增加自身5%基础防御力" 
			end,
		type = SkillManager_TYPE_PASSIVE_SETA,
		sattlementFunc = function(lv,probability) --必须，lv：技能等级；
				local thisProbability    = 0.1
				local thisAttackPercent  = 0 --[-1,0)攻击百分比,被攻击方降低攻击；[0,1]攻击方增加攻击
				local thisDefencePercent = 0.05 --[-1,0)防御百分比,被攻击方降低防御；[0,1]攻击方增加防御
				local thisHPPercent      = 0 --[0,1] 吸血百分比,攻击方吸血
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,
	}
SkillManager[0199] = 
	{
		name = "不屈熊体",--熊战
		desc = function (lv)
				return "攻击对方并造成伤害时，80%概率增加自身20%基础防御力" 			
			end,
		type = SkillManager_TYPE_PASSIVE_SETA,
		sattlementFunc = function(lv,probability) --必须，lv：技能等级；
				local thisProbability    = 0.8
				local thisAttackPercent  = 0 --[-1,0)攻击百分比,被攻击方降低攻击；[0,1]攻击方增加攻击
				local thisDefencePercent = 0.2 --[-1,0)防御百分比,被攻击方降低防御；[0,1]攻击方增加防御
				local thisHPPercent      = 0 --[0,1] 吸血百分比,攻击方吸血
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,
	}
SkillManager[0200] = 
	{
		name = "海音回梦",--萧玉
		desc = function (lv)
				return "使对方每一个英雄都有20%概率进入冰冻状态，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 1,
		runType = 0, 
		bannerType = true,
		shout = true, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.2 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferFreeze(0,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,	
	}
	
SkillManager[0201] = 
	{
		name = "大裂风",--妖花邪君
		desc = function (lv)
				return "攻击对方并造成伤害时，40%概率永久增加自身5%基础防御力" 			
			end,
		type = SkillManager_TYPE_PASSIVE_SETA,
		sattlementFunc = function(lv,probability) --必须，lv：技能等级；
				local thisProbability    = 0.4
				local thisAttackPercent  = 0 --[-1,0)攻击百分比,被攻击方降低攻击；[0,1]攻击方增加攻击
				local thisDefencePercent = 0.05 --[-1,0)防御百分比,被攻击方降低防御；[0,1]攻击方增加防御
				local thisHPPercent      = 0 --[0,1] 吸血百分比,攻击方吸血
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,
	}
SkillManager[0202] = 
	{
		name = "风刃刀舞",--穆蛇
		desc = function (lv)
				return "攻击对方并造成伤害时，30%概率永久增加自身10%基础攻击力" 			
			end,
		type = SkillManager_TYPE_PASSIVE_SETA,
		sattlementFunc = function(lv,probability) --必须，lv：技能等级；
				local thisProbability    = 0.3
				local thisAttackPercent  = 0.1 --[-1,0)攻击百分比,被攻击方降低攻击；[0,1]攻击方增加攻击
				local thisDefencePercent = 0 --[-1,0)防御百分比,被攻击方降低防御；[0,1]攻击方增加防御
				local thisHPPercent      = 0 --[0,1] 吸血百分比,攻击方吸血
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,
	}
SkillManager[0203] = 
	{
		name = "蝠鸭避火步",--林焱
		desc = function (lv)
				return "受到法术攻击时有40%概率免疫伤害" 			
			end,	
		type = SkillManager_TYPE_PASSIVE_IMAT,
		immunityAttackFunc = function(lv,isMana,probability) --必须，lv：技能等级；isMana：主动技能是否法术；probability：[0,1)随机数
				local thisIsMana = true  --true:法术免疫；false:物理免疫
				local thisProbability = 0.4 --[0,1]免疫概率，数值越大，概率越高
				return thisIsMana == isMana and thisProbability > probability
			end,
	}
SkillManager[0204] = 
	{
		name = "游气化金",--
		desc = function (lv)
				return "攻击对方并造成伤害时，100%概率永久增加自身20%基础攻击力" 			
			end,
		type = SkillManager_TYPE_PASSIVE_SETA,
		sattlementFunc = function(lv,probability) --必须，lv：技能等级；
				local thisProbability    = 1
				local thisAttackPercent  = 0.2 --[-1,0)攻击百分比,被攻击方降低攻击；[0,1]攻击方增加攻击
				local thisDefencePercent = 0 --[-1,0)防御百分比,被攻击方降低防御；[0,1]攻击方增加防御
				local thisHPPercent      = 0 --[0,1] 吸血百分比,攻击方吸血
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,
	}
SkillManager[0205] = 
	{
		name = "噬血骨手",--易尘
		desc = function (lv)
				return "攻击对方并造成伤害时，20%概率增加自身20%基础攻击力" 			
			end,
		type = SkillManager_TYPE_PASSIVE_SETA,
		sattlementFunc = function(lv,probability) --必须，lv：技能等级；
				local thisProbability    = 0.2
				local thisAttackPercent  = 0.2 --[-1,0)攻击百分比,被攻击方降低攻击；[0,1]攻击方增加攻击
				local thisDefencePercent = 0 --[-1,0)防御百分比,被攻击方降低防御；[0,1]攻击方增加防御
				local thisHPPercent      = 0 --[0,1] 吸血百分比,攻击方吸血
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,
	}
------------------------------------------------------------------------------------回复血量最少
SkillManager[0206] =
	{
		name = "千焰丹罡", --丹王古河
		desc = function (lv)
				return "治疗己方血量最少的英雄（300%），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_OWN_0, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 3, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 
		regeFunc = function(lv,att_all) 
				return att_all*3
			end,
	}
SkillManager[0207] =
	{
		name = "如露含光", --药老
		desc = function (lv)
				return "治疗己方血量最少的英雄（380%），第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_OWN_0, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 3, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 
		regeFunc = function(lv,att_all) 
				return att_all*3.8
			end,
	}
--SkillManager[0208] =
--	{
--		name = "气疗术浸", --药万归
--		desc = function (lv)
--				return "为己方血量最少的英雄持续回复生命2回合，第3回合释放，冷却时间1回合" 			
--			end,
--		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
--		start = 3, 
--		isMana = true, 
--		target = SkillManager_OWN_0, 
--		damageRatio = 1,
--		runType = 0, 
--		--bannerType = true,
--		--prepareActionF= 0, 
--		ignoreIMRE = false, 
--		attackAction = 1, 
--		injureAction = 0, 
--		--missileAction= 0, 
--		effectAction = 20, 
--		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
--				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
--				if thisProbability > probability then
--					return createBufferRege(0,2,damage,0.2) --createBuffer*****参考fighterbuffer.lua
--				else
--					return nil
--				end
--			end,
--	}
SkillManager[0209] =
	{
		name = "清风咒", --法犸
		desc = function (lv)
				return "清除己方英雄所有封印、冰冻、晕眩状态，第2回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 2, 
		isMana = true, 
		target = SkillManager_OWN_ALL, 
		damageRatio = 0.9,
		runType = 0, 

		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 
		clearFunc = function(lv) 
				return {BUFFER_TYPE_FREEZE,BUFFER_TYPE_STUN,BUFFER_TYPE_SEAL}
			end,
	}
SkillManager[0210] =
	{
		name = "落花飞絮", --小公主
		desc = function (lv)
				return "为随机2名英雄增加护盾（减少65%攻击伤害，抵挡1次攻击），第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_OWN_RANDOM_2, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false, 
		shout = true,
		prepareActionF= 3, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferReduction(7,1,0.65,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
--------------------------------------------------------------------------------------伤害结算 被动方
SkillManager[0211] = 
	{  
		name = "妖凰圣像",-- 凤清儿
		desc = function (lv)
				return "每个回合行动结束后，回复25%血量，增加5%攻击，增加10%防御" 			
			end,
		type = SkillManager_TYPE_PASSIVE_FINI,

		finishFunc = function(lv,probability) --必须，lv：技能等级；返回：
				local thisProbability    = 1
				local thisAttackPercent  = 0.05 --[0,1]攻击百分比,谁的回合谁增加攻击
				local thisDefencePercent = 0.1 --[0,1]防御百分比,谁的回合谁增加防御
				local thisHPPercent      = 0.25 --[0,1]回血百分比,谁的回合谁回复血量
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,		
	}
SkillManager[0212] = 
	{  
		name = "碧落黄泉",--妖天啸
		desc = function (lv)
				return "对后排单个敌人造成300%物理伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_SINGLE_BACK, 
		damageRatio = 3,
		runType = 0, 
		bannerType = false, 
		--shout = true,
		prepareActionF= 4, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 10, 
		effectAction = 12, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,		
	}
SkillManager[0213] = 
	{  
		name = "万影缚",--凌影
		desc = function (lv)
				return "受到攻击伤害时，15%概率减少敌方10%基础攻击和10%基础防御" 			
			end,
		type = SkillManager_TYPE_PASSIVE_SETP,
		sattlementFunc = function(lv,probability) --必须，lv：技能等级；
				local thisProbability    = 0.15
				local thisAttackPercent  = -0.1 --[-1,0)攻击百分比,攻击方降低攻击；[0,1]被攻击方增加攻击
				local thisDefencePercent = -0.1 --[-1,0)防御百分比,攻击方降低防御；[0,1]被攻击方增加防御
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent
				else
					return 0,0
				end
			end,		
	}
SkillManager[0214] = 
	{  
		name = "纯阳绵手",--xx
		desc = function (lv)
				return "受到攻击伤害时，30%概率增加自身5%攻击和10%防御" 			
			end,
		type = SkillManager_TYPE_PASSIVE_SETP,
		sattlementFunc = function(lv,probability) --必须，lv：技能等级；
				local thisProbability    = 0.3
				local thisAttackPercent  = 0.1 --[-1,0)攻击百分比,攻击方降低攻击；[0,1]被攻击方增加攻击
				local thisDefencePercent = 0.05 --[-1,0)防御百分比,攻击方降低防御；[0,1]被攻击方增加防御
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent
				else
					return 0,0
				end
			end,		
	}
SkillManager[0215] = 
	{  
		name = "血寒极冻天",--地魔老鬼
		desc = function (lv)
				return "对灼烧、中毒效果免疫" 			
			end,
		type = SkillManager_TYPE_PASSIVE_IMBF,
		immunityBufferFunc = function(lv,bufferID,probability) --必须，lv：技能等级；bufferID：待检测的bufferID
				local thisProbability = 1
				local thisBufferIDs = {BUFFER_TYPE_BURN,BUFFER_TYPE_POISON} --免疫的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua）
				if thisProbability > probability then
					for i = 1,#thisBufferIDs do
						if thisBufferIDs[i] == bufferID then
							return true
						end
					end
				end
				return false
			end,	
	}
SkillManager[0216] = 
	{  
		name = "大寂灭术",
		desc = function (lv)
				return "受到攻击伤害时，15%概率永久增加自身10%基础攻击和5%基础防御" 			
			end,
		type = SkillManager_TYPE_PASSIVE_SETP,
		sattlementFunc = function(lv,probability) --必须，lv：技能等级；
				local thisProbability    = 0.15
				local thisAttackPercent  = 0.1 --[-1,0)攻击百分比,攻击方降低攻击；[0,1]被攻击方增加攻击
				local thisDefencePercent = 0.05 --[-1,0)防御百分比,攻击方降低防御；[0,1]被攻击方增加防御
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent
				else
					return 0,0
				end
			end,		
	}
SkillManager[0217] = 
	{  
		name = "彩凤朝元",--
		desc = function (lv)
				return "对所有敌人造成150%物理伤害，第3回合释放，冷却时间2回合" 			
			end,	

		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 3, 
		isMana = false, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 1.5,
		runType = 0, 
		bannerType = true,
		shakable = true,
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--prepareActionF= 0, 
		missileAction= 7, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,		
	}


		SkillManager[0218] =
	{
		name = "九天落雷", --琥乾
		desc = function (lv)
				return "对敌方后排全体英雄造成150%法术伤害，第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 1.5,
		runType = 0, 
		bannerType = true,
		shout = 1,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= -5, 
		effectAction = 7, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
------------------------------------------------------------------------------------------------死亡技能
SkillManager[0219] =
	{
		name = "三千雷动",--雷尊者
		desc = function (lv)
				return "受到物理攻击时有60%概率免疫伤害" 			
			end,	
		type = SkillManager_TYPE_PASSIVE_IMAT,
		immunityAttackFunc = function(lv,isMana,probability) --必须，lv：技能等级；isMana：主动技能是否法术；probability：[0,1)随机数
				local thisIsMana = false  --true:法术免疫；false:物理免疫
				local thisProbability = 0.6 --[0,1]免疫概率，数值越大，概率越高
				return thisIsMana == isMana and thisProbability > probability
			end,
	}
SkillManager[0220] =
	{
		name = "缚海网",--慕骨老人
		desc = function (lv)
				return "替补上阵时立刻释放，对所有敌人造成120%物理伤害，50%概率使目标失去3次被治疗机会" 			
			end,		
		type =SkillManager_TYPE_ACTIVE_ENTER, 
		--start = 3, 
		isMana = false, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 1.2,
		runType = 0, 
		--bgAction = 1,
		bannerType = true,
		shout = true,
		shakable = true,
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--prepareActionF= 7, 
		--prepareActionB= 8, 
		missileAction= 11, 
		effectAction = 0, 
		shakable = true,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,

			setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.5 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferCureless(5,3) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0221] =
	{
		name = "魔毒斑",--蝎毕岩
		desc = function (lv)
				return "死亡时释放，对敌方全体英雄造成15%法术攻击伤害，20%概率减少敌方20%基础攻击（持续1次）" 			
			end,		
		type = SkillManager_TYPE_ACTIVE_EXIT, --属性含义参照SkillManager_TYPE_ACTIVE_ROUND
		--start属性无效
		isMana = true,
		target = SkillManager_MULTI_ALL,
		runType = 0,
		--bannerType = true,
		ignoreIMRE = false,
		attackAction = 3,
		injureAction = 0,
		--prepareActionF= 0,
		--missileAction= 0, 
		effectAction = 0,
		damageRatio = 0.15,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.2 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferDecrease(0,1,0.2,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0222] =
	{
		name = "死祭之蛊",--蜈崖
		desc = function (lv)
				return "死亡时释放，对敌方随机3名英雄造成50%法术攻击伤害，30%概率产生伤害100%的中毒效果（持续1回合）" 			
			end,		
		type = SkillManager_TYPE_ACTIVE_EXIT, --属性含义参照SkillManager_TYPE_ACTIVE_ROUND
		--start属性无效
		isMana = true,
		target = SkillManager_MULTI_RANDOM_3,
		runType = 0,
		--bannerType = true,
		ignoreIMRE = false,
		attackAction = 3,
		injureAction = 0,
		--prepareActionF= 0,
		missileAction= 8, 
		effectAction = 10,
		damageRatio = 0.5,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.3 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferPoison(0,1,damage,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0223] =
	{
		name = "死亡缠绕",--古华 慕青鸾
		desc = function (lv)
				return "死亡时释放，对所有敌人造成200%法术伤害，对所有生命上限大于自己生命上限的目标造成双倍伤害" 			
			end,		
		type = SkillManager_TYPE_ACTIVE_EXIT, --属性含义参照SkillManager_TYPE_ACTIVE_ROUND
		--start属性无效
		isMana = true,
		target = SkillManager_MULTI_ALL,
		runType = 0,
		bannerType = false,
		shakable = true,
		ignoreIMRE = false,
		attackAction = 3,
		injureAction = 0,
		--prepareActionF= 0,
		missileAction= -4, 
		effectAction = 10,
		damageRatio = 2,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
						if srcHPMax < dstHPMax	then
							return att_all*2
						else	
							return att_all
						end
			end,
	}
SkillManager[0224] =
	{
		name = "古玉令",--翎泉
		desc = function (lv)
				return "死亡时释放，使己方全体英雄50%概率获取护盾（减少30%攻击伤害，持续2次）" 			
			end,		
		type = SkillManager_TYPE_ACTIVE_EXIT, --属性含义参照SkillManager_TYPE_ACTIVE_ROUND
		--start属性无效
		isMana = true,
		target = SkillManager_OWN_OTHER,
		runType = 0,
		--bannerType = true,
		ignoreIMRE = false,
		attackAction = 3,
		injureAction = 0,
		--prepareActionF= 0,
		--missileAction= 0, 
		effectAction = 20,
		damageRatio = 0.3,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.5 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferReduction(0,2,0.3,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0225] =
	{
		name = "天龙焰",--西龙王
		desc = function (lv)
				return "对所有敌人造成150%物理伤害，第3回合释放，冷却时间2回合" 			
			end,	

		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 3, 
		isMana = false, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 1.5,
		runType = 0, 
		bannerType = false,
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--prepareActionF= 0, 
		missileAction= 10, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0226] =
	{
		name = "浮生万刃",--丘陵 韩枫
		desc = function (lv)
				return "死亡时释放，回复己方全体英雄血量（450%）" 			
			end,		
		type = SkillManager_TYPE_ACTIVE_EXIT, --属性含义参照SkillManager_TYPE_ACTIVE_ROUND
		--start属性无效
		isMana = true,
		target = SkillManager_OWN_OTHER,
		runType = 0,
		bannerType = true,
		shout = true,
		ignoreIMRE = false,
		attackAction = 3,
		injureAction = 0,
		--prepareActionF= 0,
		--missileAction= 0, 
		effectAction = 19,
		damageRatio = 1,
		regeFunc = function(lv,att_all) 
				return att_all*4.5
			end,
	}
SkillManager[0227] =
	{
		name = "魂之葬礼",--鹜护法
		desc = function (lv)
				return "死亡时释放，对敌方随机4名英雄造成120%物理攻击伤害，60%概率使敌方无法被治疗（持续2次）" 			
			end,		
		type = SkillManager_TYPE_ACTIVE_EXIT, --属性含义参照SkillManager_TYPE_ACTIVE_ROUND
		--start属性无效
		isMana = false,
		target = SkillManager_MULTI_RANDOM_4,
		runType = 0,
		--bannerType = true,
		ignoreIMRE = false,
		attackAction = 3,
		injureAction = 0,
		--prepareActionF= 0,
		missileAction= 4, 
		effectAction = 0,
		damageRatio = 1.2,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.6 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferCureless(0,2) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0228] =
	{
		name = "厄难毒体",--小医仙
		desc = function (lv)
				return "死亡时释放，对所有敌人造成200%法术伤害，85%概率产生伤害值200%的中毒效果（持续2回合）" 			
			end,		
		type = SkillManager_TYPE_ACTIVE_EXIT, --属性含义参照SkillManager_TYPE_ACTIVE_ROUND
		--start属性无效
		isMana = true,
		target = SkillManager_MULTI_ALL,
		runType = 0,
		bannerType = true,
		shout = true,
		shakable = true,
		ignoreIMRE = false,
		attackAction = 3,
		injureAction = 0,
		--prepareActionF= 0,
		missileAction= 8, 
		effectAction = 7,
		damageRatio = 2,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.85 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferPoison(30,2,damage,2) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,	
	}
SkillManager[0229] =
	{
		name = "九幽蛇影",--妖天啸
		desc = function (lv)
				return "替补上阵时立刻释放，对血量最多的敌人造成100%法术伤害，30%概率增加300%攻击力" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ENTER,
		--start属性无效
		isMana = true,
		target = SkillManager_SINGLE_100,
		damageRatio = 1,
		runType = 0,
		--bannerType = true,
		bannerType = true,
		shout = true,
		shakable = true,
		ignoreIMRE = false,
		attackAction = 1,
		injureAction = 0,
		prepareActionF= 4,
		missileAction= 8,
		effectAction = 7,  
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				local thisProbability = 0.3
				if thisProbability > probability then
					return att_all*4
				else
					return att_all
				end
			end,
	}
SkillManager[0230] =
	{
		name = "冰封天地",--天蛇
		desc = function (lv)
				return "对随机1个敌人造成200%物理伤害，30%概率冰冻使对手失去1个回合行动力，第1回合释放，冷却时间3回合" 			
			end,		
		type = SkillManager_TYPE_ACTIVE_ROUND + 3, 
		start = 1, 
		isMana = false,
		target = SkillManager_MULTI_RANDOM_1,
		runType = 0,
		bannerType = true,
		shout = true,
		ignoreIMRE = false,
		attackAction = 3,
		injureAction = 0,
		prepareActionF= 0,
		missileAction= 0, 
		effectAction = 0,
		damageRatio = 2,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.3 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferFreeze(0,1) --crcreateBufferFreezeeateBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0231] =
	{
		name = "凝灵献祭",--
		desc = function (lv)
				return "死亡时释放，30%使敌方随机5名英雄虚弱（减少30%攻击力，持续2次攻击）" 			
			end,		
		type = SkillManager_TYPE_ACTIVE_EXIT, --属性含义参照SkillManager_TYPE_ACTIVE_ROUND
		--start属性无效
		isMana = false,
		target = SkillManager_MULTI_RANDOM_5,
		runType = 0,
		--bannerType = true,
		ignoreIMRE = false,
		attackAction = 3,
		injureAction = 0,
		--prepareActionF= 0,
		--missileAction= 0, 
		effectAction = 20,
		damageRatio = 0.4,

		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.3 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferDecrease(0,2,0.3,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0232] =
	{
		name = "光耀印",--
		desc = function (lv)
				return "死亡时释放，60%使敌方随机5名英雄虚弱（减少30%攻击力，持续2次攻击）" 			
			end,		
		type = SkillManager_TYPE_ACTIVE_EXIT, --属性含义参照SkillManager_TYPE_ACTIVE_ROUND
		--start属性无效
		isMana = false,
		target = SkillManager_MULTI_RANDOM_5,
		runType = 0,
		--bannerType = true,
		ignoreIMRE = false,
		attackAction = 3,
		injureAction = 0,
		--prepareActionF= 0,
		--missileAction= 0, 
		effectAction = 20,
		damageRatio = 0.4,

		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.6 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferDecrease(0,2,0.3,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
-----------------------------------------------------------------------------------------------随1人法攻持续伤害
SkillManager[0233] =
	{
		name = "三千雷动", --费天
		desc = function (lv)
				return "对敌方随机1名造成50%法术攻击伤害，30%概率产生伤害50%的灼烧效果（持续2回合），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_1, 
		damageRatio = 0.5,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 14, 
		effectAction = 21, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.3 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(0,2,att,0.5) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,	
	}
SkillManager[0234] =
	{
		name = "天壤劫火", --沈云
		desc = function (lv)
				return "对敌方随机1名造成60%法术攻击伤害，50%概率产生伤害50%的灼烧效果（持续2回合），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_1, 
		damageRatio = 0.6,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 6, 
		effectAction = 0 , 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.5 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(0,2,att,0.5) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,	
	}
SkillManager[0235] =
	{
		name = "寂灭黄泉", --黄泉尊者
		desc = function (lv)
				return "每次受到攻击伤害时，减少对方10%基础攻击力，最多累计减少50%" 			
			end,
		type = SkillManager_TYPE_PASSIVE_SETP,
		sattlementFunc = function(lv,probability) --必须，lv：技能等级；
				local thisProbability    = 1
				local thisAttackPercent  = 0.1 --[-1,0)攻击百分比,攻击方降低攻击；[0,1]被攻击方增加攻击
				local thisDefencePercent = 0 --[-1,0)防御百分比,攻击方降低防御；[0,1]被攻击方增加防御
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent
				else
					return 0,0
				end
			end,	
	}
SkillManager[0236] =
	{
		name = "丹火燎原", 
		desc = function (lv)
				return "对所有敌人造成80%法术伤害，50%概率产生伤害150%的灼烧效果（持续减血2回合），第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 0.8,
		runType = 0, 
		bannerType = false, 
		shout = true,
		shakable = true,
		prepareActionF= 2, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 2, 
		effectAction = 12, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.5 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(12,2,att,1.5) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,	
	}
SkillManager[0237] =
	{
		name = "大风手印", --云棱
		desc = function (lv)
				return "对敌方随机1名造成80%法术攻击伤害，50%概率产生伤害20%的诅咒效果（持续2回合），第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_1, 
		damageRatio = 0.8,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 1, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.5 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferCurse(0,2,att, 0.2) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0238] =
	{
		name = "香气袭人", --花锦
		desc = function (lv)
				return "对敌方随机1名造成70%法术攻击伤害，50%概率产生伤害40%的诅咒效果（持续减血2回合），第4回合释放，冷却时间3回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 3, 
		start = 4, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_1, 
		damageRatio = 0.7,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 17, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.5 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferCurse(0,2,att, 0.4) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0239] =
	{
		name = "雁落九天", --雁落天
		desc = function (lv)
				return "对敌方随机1名造成100%法术攻击伤害，40%概率产生伤害50%的诅咒效果（持续2回合），第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_1, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 1, 
		missileAction= 7, 
		effectAction = 0, 

		
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.4 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferCurse(0,2,att, 0.5) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
-----------------------------------------------------------------------------------------
--SkillManager[0240] =
--	{
--		name = "随1人法攻持续伤害", --xx
--		desc = function (lv)
--				return "对敌方随机1名造成40%法术攻击伤害，40%概率使敌方被诅咒（持续减血2回合），第2回合释放，冷却时间1回合" 			
--			end,
--		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
--		start = 2, 
--		isMana = true, 
--		target = SkillManager_MULTI_RANDOM_1, 
--		damageRatio = 1,
--		runType = 0, 
--		--bannerType = true,
--		--prepareActionF= 0, 
--		ignoreIMRE = false, 
--		attackAction = 0, 
--		injureAction = 0, 
--		missileAction= 0, 
--		effectAction = 0, 
--		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
--				local thisProbability = 0.4 --(0,1] 生成概率,数值越大,概率越高
--				if thisProbability > probability then
--					return createBufferCurse(0,2,att, 0.5) --createBuffer*****参考fighterbuffer.lua
--				else
--					return nil
--				end
--			end,
--	}
------------------------------------------------------------------------------------------------随机2护盾持续
SkillManager[0240] =
	{
		name = "十方俱灭", --妖暝
		desc = function (lv)
				return "受到法术攻击时80%概率减少50%伤害" 			
			end,
		type = SkillManager_TYPE_PASSIVE_REDU,
		reduceFunc = function(lv,isMana,damage,probability) --必须，lv：技能等级；isMana：主动技能是否法术
				local thisIsMana = true --true:法术减伤;false:物理减伤
				local thisProbability = 0.8
				local thisPercent = 0.5
				local thisNumber = 0
				return (thisIsMana == isMana and thisProbability > probability) and damage*thisPercent or 0
			end,
	}
SkillManager[0241] =
	{
		name = "神鹰展翅", --鹰山老人
		desc = function (lv)
				return "为自身增加护盾（减少40%攻击伤害，抵挡2次攻击），第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = false, 
		target = SkillManager_OWN_SELF, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false,
		--shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferReduction(4,2,0.4,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0242] =
	{
		name = "古帝之镜", --
		desc = function (lv)
				return "为自身增加护盾（减少100%攻击伤害，抵挡2次攻击），第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = false, 
		target = SkillManager_OWN_SELF, 
		damageRatio = 1,
		runType = 0, 
		bannerType = true,
		shout = true,
		prepareActionF= 3, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferReduction(10,2,1,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0243] =
	{
		name = "暗影守护", --凌影
		desc = function (lv)
				return "60%概率为己方随机2名英雄添加护盾（减少50%攻击伤害，持续2次），第3回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 3, 
		isMana = false, 
		target = SkillManager_OWN_RANDOM_2, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.6 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferReduction(0,2,0.5,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0244] =
	{
		name = "乙木仙术", --药星极
		desc = function (lv)
				return "治疗己方全体英雄（80%），第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_OWN_ALL, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 
		regeFunc = function(lv,att_all) 
				return att_all*0.8 
			end,
	}
SkillManager[0245] =
	{
		name = "残影连断掌", --加刑天
		desc = function (lv)
				return "对单个敌人造成100%法术伤害，100%概率使对方虚弱（减少60%攻击力，持续1次），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 1,
		runType = 1, 
		bannerType = false, 
		shout = true,
		prepareActionF= 0, 
		ignoreIMRE = true, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferDecrease(3,1,0.6,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0246] =
	{
		name = "古帝之镜", --古刑
		desc = function (lv)
				return "为自身增加护盾（减少40%攻击伤害，持续2次），第1回合释放，冷却时间3回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 3, 
		start = 1, 
		isMana = false, 
		target = SkillManager_OWN_SELF, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferReduction(4,2,0.4,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
-------------------------------------------------------------------------------------------------------随机2攻击持续减血
SkillManager[0247] =
	{
		name = "冰火掌", --xxx
		desc = function (lv)
				return "对敌方随机2名英雄造成10%法术攻击伤害，80%概率产生攻击伤害100%的灼烧效果（持续5回合），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_2, 
		damageRatio = 0.1,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 4, 
		missileAction= 0, 
		effectAction = 20, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.8 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(0,5,damage,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0248] =
	{
		name = "三段魂锁", --鹜护法
		desc = function (lv)
				return "对敌方随机2名英雄造成40%法术攻击伤害，60%概率产生攻击伤害50%的诅咒效果（持续2回合），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_2, 
		damageRatio = 0.4,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 10, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.3 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferCurse(0,2,damage, 0.5) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0249] =
	{
		name = "金帝焚天斩", --萧薰儿
		desc = function (lv)
				return "替补上场时释放，对随机2个敌人造成300%法术伤害，增加己方死亡人数乘以30%的攻击力（最大增幅150%）" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ENTER,
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_2, 
		damageRatio = 3.5,
		runType = 0, 
		bannerType = true,
		shout = true,
		prepareActionF= 1, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 5,
		haloAction = 2, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				local thisProbability = 1
				if thisProbability > probability then
					if myDeath > 5 then
						return att_all*2.5
					else
						return att_all*(1+myDeath*0.3)
					end
				else
					return att_all
				end
			end,
	}
SkillManager[0250] =
	{
		name = "千烈凤屏", --火炫
		desc = function (lv)
				return "对敌方随机2名英雄造成90%法术攻击伤害，60%概率产生攻击伤害40%的灼烧效果（持续减血2回合），第3回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 3, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_2, 
		damageRatio = 0.9,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.6 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(0,2,damage,0.4) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0251] =
	{
		name = "太极云手", --xx
		desc = function (lv)
				return "对敌方随机2名英雄造成30%物理攻击伤害，30%概率产生攻击伤害20%的灼烧效果（持续2回合），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_2, 
		damageRatio = 0.3,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 7, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.3 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(0,2,damage,0.2) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0252] =
	{
		name = "火龙缠绕", --唐火儿
		desc = function (lv)
				return "对随机2名敌人造成150%法术伤害，45%概率使敌人被封印（失去1个回合行动能力），第2回合释放，冷却时间1个回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_2, 
		damageRatio = 1.5,
		runType = 0, 
		bannerType = false, 
		shout = true,
		prepareActionF= 4, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 8, 
		effectAction = 7, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.45 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferSeal(0,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0253] =
	{
		name = "残月斩", --火稚
		desc = function (lv)
				return "对敌方随机2名英雄造成70%物理攻击伤害，60%概率产生攻击伤害20%的灼烧效果（持续2回合），第2回合释放，冷却时间3回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 3, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_2, 
		damageRatio = 0.7,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 6, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.6 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(0,2,damage,0.2) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0254] =
	{
		name = "腾龙霸枪", --
		desc = function (lv)
				return "对后排敌人造成150%物理伤害，无视免疫和减伤效果，80%概率使对方虚弱（减少30%攻击力，持续1次），第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 1.5,
		runType = 0, 
		bannerType = true,
		shout = true,
		shakable = true,
		prepareActionF= 0, 
		ignoreIMRE = true, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 3, 
		effectAction = 12, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.8 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferDecrease(3,1,0.3,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}

------------------------------------------------------------------------------------------------------------随机2护盾持续
SkillManager[0255] =
	{
		name = "玄冰盾", --海波东
		desc = function (lv)
				return "给自身添加护盾（减少35%攻击伤害，持续2次），第1回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 1, 
		isMana = false, 
		target = SkillManager_OWN_SELF, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferReduction(3,2,0.35,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0256] =
	{
		name = "星罡护盾", --莫崖
		desc = function (lv)
				return "50%概率为己方随机2名英雄添加护盾（减少30%攻击伤害，持续2次），第2回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 2, 
		isMana = false, 
		target = SkillManager_OWN_RANDOM_2, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.5 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferReduction(0,2,0.3,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0257] =
	{
		name = "魔王护持", --墨巴斯
		desc = function (lv)
				return "50%概率为己方随机2名英雄添加护盾（减少50%攻击伤害，持续2次），第2回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 2, 
		isMana = false, 
		target = SkillManager_OWN_RANDOM_2, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.5 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferReduction(0,2,0.5,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0258] =
	{
		name = "裂山盾", --萧战
		desc = function (lv)
				return "60%概率为己方随机2名英雄添加护盾（减少50%攻击伤害，持续2次），第2回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 2, 
		isMana = false, 
		target = SkillManager_OWN_RANDOM_2, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.6 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferReduction(0,2,0.5,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0259] =
	{
		name = "噬血甲", --范痨
		desc = function (lv)
				return "60%概率为己方随机2名英雄添加护盾（减少50%攻击伤害，持续2次），第2回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 2, 
		isMana = false, 
		target = SkillManager_OWN_RANDOM_2, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.6 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferReduction(0,2,0.5,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0260] =
	{
		name = "魂葬之门", --
		desc = function (lv)
				return "治疗己方全体英雄（100%），并消除中毒和灼烧效果，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_OWN_ALL, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false,
		--shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 
		regeFunc = function(lv,att_all) 
				return att_all*1
			end,
		clearFunc = function(lv) 
				return {BUFFER_TYPE_BURN,BUFFER_TYPE_POISON}
			end,
	}
SkillManager[0261] =
	{
		name = "帝国荣光", --夭夜
		desc = function (lv)
				return "60%概率为己方随机2名英雄添加护盾（减少50%攻击伤害，持续2次），第3回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 3, 
		isMana = false, 
		target = SkillManager_OWN_RANDOM_2, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.6 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferReduction(0,2,0.5,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0262] =
	{
		name = "魂灵壁", --
		desc = function (lv)
				return "对前排敌人造成140%物理伤害，无视免疫和减伤效果，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 1.4,
		runType = 1, 
		bannerType = false,
		--shout = true,
		prepareActionF= 4, 
		ignoreIMRE = true, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0263] =
	{
		name = "冰霜壁", --冰符
		desc = function (lv)
				return "40%概率为己方随机2名英雄添加护盾（减少50%攻击伤害，持续2次），第3回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 3, 
		isMana = false, 
		target = SkillManager_OWN_RANDOM_2, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.4 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferReduction(0,2,0.5,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0264] =
	{
		name = "玄冥护体", --辰天南
		desc = function (lv)
				return "70%概率为己方随机2名英雄添加护盾（减少50%攻击伤害，持续2次），第3回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 3, 
		isMana = false, 
		target = SkillManager_OWN_RANDOM_2, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.7 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferReduction(0,2,0.5,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
-------------------------------------------------------------------------------------------------------随机3人攻击持续减血
SkillManager[0265] =
	{
		name = "天毒牢界", --小医仙
		desc = function (lv)
				return "对随机1个敌人造成200%法术伤害，若自身有中毒效果攻击增加100%，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_1, 
		damageRatio = 2,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 9, 
		effectAction = 10, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
			local thisBuffers ={BUFFER_TYPE_POISON}
				for i = 1,#myBuffers do
					for j = 1,#thisBuffers do
						if myBuffers[i] == thisBuffers[j] then
					    return att_all*1.5
						end
					end
				end
				return att_all
			end,
			
	}
SkillManager[0266] =
	{
		name = "寒骨灵火", --药老
		desc = function (lv)
				return "对随机2个敌人造成280%法术伤害，80%概率产生攻击伤害值300%的灼烧效果（持续1回合），第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_2, 
		damageRatio = 2.8,
		runType = 0, 
		bannerType = false,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 2, 
		effectAction = 12, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.8 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(24,1,damage,3) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,	
	}
SkillManager[0267] =
	{
		name = "黄泉天怒", --黄泉尊者
		desc = function (lv)
				return "死亡时触发，对敌方前排造成220%法术伤害,80%概率产生伤害100%的灼烧效果（持续2回合）"	
			end,	
		type = SkillManager_TYPE_ACTIVE_EXIT, --属性含义参照SkillManager_TYPE_ACTIVE_ROUND
		--start属性无效
		isMana = true,
		target = SkillManager_MULTI_ROW_1,
		needRun = false,
		bannerType = true,
		shout = true,
		shakable = true,
		ignoreIMRE = false,
		attackAction = 2,
		injureAction = 0,
		--prepareAction= 0,
		--missileAction= -4, 
		effectAction = 3,
		damageRatio = 2.2,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,	
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.8 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(0,2,damage, 1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0268] =
	{
		name = "碎魂天袭", --花蛇儿
		desc = function (lv)
				return "对敌方随机3名英雄造成30%法术攻击伤害，40%概率产生伤害30%的诅咒效果（持续2回合），第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_3, 
		damageRatio = 0.3,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.4 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferCurse(0,2,damage, 0.3) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,	
	}
SkillManager[0269] =
	{
		name = "地刺封印", --美杜莎
		desc = function (lv)
				return "对敌方随机3名英雄造成280%物理攻击伤害，自身血量低于对方血量时增加80%攻击力，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_3, 
		damageRatio = 2.8,
		runType = 0, 
		bannerType = true,
		shout = true,
		shakable = true,
		prepareActionF= 3, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 5, 
		--missileAction= 0, 
		effectAction = 8, 
		haloAction = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				if srcHP < dstHP then
					return att_all*1.2
				else
					return att_all
				end 
			end,
	}
SkillManager[0270] =
	{
		name = "千幻毒刺", --蜈崖
		desc = function (lv)
				return "对敌方随机3名英雄造成60%物理攻击伤害，60%概率产生伤害20%的中毒效果（持续2回合），第3回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 3, 
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_3, 
		damageRatio = 0.6,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 5, 
		--missileAction= 0, 
		effectAction = 8,
		haloAction = 1, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.6 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferPoison(0,2,damage,0.2) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,	
	}
------------------------------------------------------------------------------------------------物理单体
SkillManager[0275] =
	{
		name = "剑指苍穹", --[0274]--[0279]天雷子
		desc = function (lv)
				return "对纵列敌人造成90%物理伤害，第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 0.9,
		runType = 1, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 2, 
		injureAction = 1, 
		--missileAction= , 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0274] =
	{
		name = "苍穹雷动", --[0274]--[0279]南龙王，雁落天，萧炎，韩雪
		desc = function (lv)
				return "对单个敌人造成120%物理伤害，第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = false, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 1.2,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 6, 
		effectAction = 0,	
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0280] =
	{
		name = "碎火刀", --[0280]--[0282]曜天火，天冥老妖，吴昊，丘陵
		desc = function (lv)
				return "对单个敌人造成150%物理攻击伤害，满血状态增加30%攻击力，无视免疫和伤害减免效果，第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = false, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 1.5,
		runType = 1, 
		bannerType = false,
		--prepareActionF= 0, 
		ignoreIMRE = true, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
			if srcHP == srcHPMax then
				return att_all*1.3
			else
				return att_all
			end
			end,
	}

	SkillManager[0281] =
	{
		name = "碎火刀", --[0280]--[0282]曜天火
		desc = function (lv)
				return "对单个敌人造成150%物理攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 1.5,
		runType = 1, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0283] =
	{
		name = "回旋枪", --[0283]--[0284]四天尊，古刑
		desc = function (lv)
				return "对前排敌人造成70%物理伤害，第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 0.7,
		runType = 1,
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 11, 
		effectAction = 10, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0285] =
	{
		name = "裂地斩", 
		desc = function (lv)
				return "对前排敌人造成80%物理攻击伤害，当敌人附带灼烧效果时增加30%攻击力，第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 0.8,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 12, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				local thisBuffers = {BUFFER_TYPE_BURN} --攻击增幅触发的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua）
				for i = 1,#enemyBuffers do
					for j = 1,#thisBuffers do
						if enemyBuffers[i] == thisBuffers[j] then
							return att_all*1.3
						end
					end
				end
				return att_all
			end,
	}
SkillManager[0286] =
	{
		name = "九幽魂手", --九天尊
		desc = function (lv)
				return "对单个敌人造成320%物理伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 3.2,
		runType = 1, 
		bannerType = true,
		shout = true,
		prepareActionF= 4, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 10, 
		effectAction = 12, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
-------------------------------------------------------------------------------------------物攻不能加血
SkillManager[0287] =
	{
		name = "湮灭之刃", --
		desc = function (lv)
				return "对后排单个敌人造成120%物理伤害，无视免疫和减伤效果，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_SINGLE_BACK, 
		damageRatio = 1.2,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = true, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0288] =
	{
		name = "气化天地", --[0288][0289]--妖花邪君，冰符
		desc = function (lv)
				return "对敌方随机2名英雄造成40%物理攻击伤害，20%概率使敌方无法被治疗，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_2, 
		damageRatio = 0.4,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.2 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferCureless(0,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0290] =
	{
		name = "玄冥剑", --洪天啸
		desc = function (lv)
				return "对敌方随机2名英雄造成150%物理攻击伤害，50%概率使敌方无法被治疗，第4回合释放，冷却时间3回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 3, 
		start = 4, 
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_2, 
		damageRatio = 1.5,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 4, 
		missileAction= 0, 
		effectAction = 20, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.5 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferCureless(0,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
-------------------------------------------------------------------------------------------物理单体无视减免
SkillManager[0291] =
	{
		name = "缠蛇手", --林修崖
		desc = function (lv)
				return "对单个敌人造成100%物理伤害，无视免疫和伤害减免效果，第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = false, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = true, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0292] =
	{
		name = "浪剑淘沙", --[0292] [0293]剑尊者
		desc = function (lv)
				return "对单个敌人造成180%物理伤害，无视免疫和伤害减免效果，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 1.8,
		runType = 1, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = true, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0294] =
	{
		name = "枯叶掌", --丹塔长老
		desc = function (lv)
				return "对单个敌人造成120%物理攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 1.2,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0295] =
	{
		name = "天羽指", --[0295] [0296]古道，辰天南
		desc = function (lv)
				return "对前排敌人造成80%物理攻击伤害，第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 0.8,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0297] =
	{
		name = "蚀焰还身", --[0297] --[0299 ]铁剑尊者，火炫
		desc = function (lv)
				return "对单个敌人造成105%物理伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 1.05,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0300] =
	{
		name = "毒龙蚀天", --墨巴斯
		desc = function (lv)
				return "对敌方单体造成80%物理攻击伤害，无视免疫和伤害减免效果，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 0.8,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = true, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0301] =
	{
		name = "疯斧狂斩", --苏千
		desc = function (lv)
				return "对单个敌人造成100%物理伤害，100%概率产生攻击伤害值40%的灼烧效果（持续2回合），第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = false, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 0.6,
		runType = 1, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
			setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(20,2,damage,0.4) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
		
	}
SkillManager[0302] =
	{
		name = "铁山拳", --苏千 吴昊
		desc = function (lv)
				return "对敌方单体造成280%物理伤害，满血状态增加30%攻击力，无视免疫和伤害减免效果，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 2.8,
		runType = 1, 
		bannerType = false,
		shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = true, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 2, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
			if srcHP == srcHPMax then
				return att_all*1.3
			else
				return att_all
			end
			end,
	}
SkillManager[0303] =
	{
		name = "九幽淬寒剑", --苏千
		desc = function (lv)
				return "对敌方全体造成150%物理伤害，无视免疫和伤害减免效果，第1回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 1.5,
		runType = 0, 
		bannerType = true,
		shout = true,
		shakable = true,
		--prepareActionF= 0, 
		ignoreIMRE = true, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 9, 
		effectAction = 10, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0304] =
	{
		name = "黑湮聚力", --
		desc = function (lv)
				return "我方随机2名英雄增加40%攻击力（持续2次攻击），第1回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 1, 
		isMana = false, 
		target = SkillManager_OWN_RANDOM_2, 
		damageRatio = 1.2,
		runType = 0, 
		bannerType = false, 
		shakable = true,
		--prepareActionF= 0, 
		ignoreIMRE = true, 
		attackAction = 3, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferIncrease(4,2,0.4,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
------------------------------------------------------------------------------物攻反击
SkillManager[0305] =
	{ 	
	        name = "雷弧三段舞", --[0292] [0293]剑尊者
		desc = function (lv)
				return "对前排敌人造成150%物理伤害，无视免疫和伤害减免效果，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 1.5,
		runType = 1, 
		bannerType = false,
		shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = true, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0306] =
	{ 	name = "玄天鬼诀",--四天尊
		desc = function (lv)
				return "发动攻击时，目标附有灼烧状态时，增加20%攻击" 			
			end,
		type = SkillManager_TYPE_PASSIVE_BUFF,
		addFunc = function(lv,att,enemyBuffers) --必须，lv：技能等级；att：角色的基础攻击；enemyBuffers：被动方身上的bufferIDs表
				local thisBuffers = {BUFFER_TYPE_BURN} --攻击增幅触发的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua）
				local thisPercent = 0.2  --[0,1]攻击增幅百分比
				local thisNumber = 0   --[0,+)攻击增幅自然数
				for i = 1,#enemyBuffers do
					for j = 1,#thisBuffers do
						if enemyBuffers[i] == thisBuffers[j] then
							return att * thisPercent + thisNumber
						end
					end
				end
				return 0
			end,
	}
SkillManager[0307] =
	{
		name = "皇室军魂",--夭夜
		desc = function (lv)
				return "发动物理攻击时，50%概率增加50%基础攻击力" 			
			end,
		type = SkillManager_TYPE_PASSIVE_PROB,
		addFunc = function(lv,isMana,att,probability) --必须，lv：技能等级；isMana：主动技能是否法术；att：角色的基础攻击；probability：[0,1)随机数
				local thisIsMana = false  --true:法术增幅;false:物理增幅
				local thisProbability = 0.5 --[0,1]攻击增幅概率，数值越大，概率越高
				local thisPercent = 0.5     --[0,1]攻击增幅百分比
				local thisNumber = 0      --[0,+)攻击增幅自然数
				return (isMana == thisIsMana and thisProbability > probability ) and att * thisPercent + thisNumber or 0
			end,
	}
SkillManager[0308] =
	{
		name = "玄冰盾",--冰元
		desc = function (lv)
				return "受到物理攻击时60%概率减少40%攻击伤害" 			
			end,
		type = SkillManager_TYPE_PASSIVE_REDU,
		reduceFunc = function(lv,isMana,damage,probability) --必须，lv：技能等级；isMana：主动技能是否法术
				local thisIsMana = false --true:法术减伤;false:物理减伤
				local thisProbability = 0.6
				local thisPercent = 0.4
				local thisNumber = 0
				return (thisIsMana == isMana and thisProbability > probability) and damage*thisPercent or 0
			end,
	}

SkillManager[0309] =
	{
		name = "疯斧狂斩", --林焱 
		desc = function (lv)
				return "对单个敌人造成100%物理伤害，100%概率产生攻击伤害值80%的灼烧效果（持续2回合），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 0.6,
		runType = 1, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
			setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(20,2,damage,0.8) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
		
	}
--SkillManager[0309] =
--	{
--		name = "古天极震", --洪天啸
--		desc = function (lv)
--				return "对敌方随机2名英雄造成30%物理攻击伤害，10%概率使敌方虚弱（减少20%基础攻击，持续2回合），每回合释放" 			
--			end,
--		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
--		start = 1, 
--		isMana = false, 
--		target = SkillManager_MULTI_RANDOM_2, 
--		damageRatio = 0.3,
--		runType = 0, 
--		--bannerType = true,
--		--prepareActionF= 0, 
--		ignoreIMRE = false, 
--		attackAction = 0, 
--		injureAction = 0, 
--		--missileAction= 0, 
--		effectAction = 0, 
--		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
--				return att_all
--			end,
--		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
--				local thisProbability = 0.1 --(0,1] 生成概率,数值越大,概率越高
--				if thisProbability > probability then
--					return createBufferDecrease(0,2,0.2,0) --createBuffer*****参考fighterbuffer.lua
--				else
--					return nil
--				end
--			end,
--	}
SkillManager[0310] =
	{
		name = "魂灭斩", 
		desc = function (lv)
				return "对后排敌人造成70%物理攻击伤害，第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 0.7,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0311] =
	{
		name = "银鹰掠地", --鹰山老人
		desc = function (lv)
				return "对随机2名敌人造成180%物理伤害，80%概率使敌方虚弱（减少20%攻击力，持续2次），第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_2, 
		damageRatio = 1.8,
		runType = 0, 
		bannerType = true, 
		shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 7,
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.8 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferDecrease(2,2,0.2,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0312] =
	{
		name = "雷光箭雨", --费天
		desc = function (lv)
				return "对敌方随机2名英雄造成40%物理攻击伤害，30%概率使敌方虚弱（减少10%基础攻击，持续2回合），第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_2, 
		damageRatio = 0.4,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.3 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferDecrease(0,2,0.1,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0313] =
	{
		name = "清风明月", --古青阳，林修崖
		desc = function (lv)
				return "对前排敌人造成150%物理伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 1.5,
		runType = 0, 
		bannerType = false, 
		shout = true,
		prepareActionF= 1, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 0, 
		effectAction = 12, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
------------------------------------------------------------------------------物攻生命最少
SkillManager[0314] =
	{
		name = "诸刃灭", --金老
		desc = function (lv)
				return "对敌方生命最少的英雄造成40%物理攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_SINGLE_0, 
		damageRatio = 0.4,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 12, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0315] =
	{
		name = "冰神弓", --天蛇
		desc = function (lv)
				return "对单个敌人造成90%物理伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 0.9,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 4, 
		missileAction= 0, 
		effectAction = 20, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0316] =
	{
		name = "惊蛰枪法", --萧厉
		desc = function (lv)
				return "对敌方生命最少的英雄造成80%物理攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_SINGLE_0, 
		damageRatio = 0.8,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 12, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,

			
	}
SkillManager[0317] =
	{
		name = "神龙摆尾", --北龙王
		desc = function (lv)
				return "对前排敌人造成80%物理伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 0.8,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 4, 
		missileAction= 5, 
		effectAction = 21, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,

		
	}
SkillManager[0318] =
	{
		name = "狱龙破甲", --北龙王，柳擎
		desc = function (lv)
				return "血量高于攻击对象时，增加60%攻击" 			
			end,
		type = SkillManager_TYPE_PASSIVE_HPHP,
		addFunc = function(lv,att,srcHP,dstHP) --必须，lv：技能等级；att：角色的基础攻击；srcHP、dstHP：攻击方、被攻击方HP
				local thisPercent = 0.6 --[0,1]攻击增幅百分比
				local thisNumber = 0  --[0,+)攻击增幅自然数
				--     dstHP > srcHP  --更改判断符号
				return dstHP < srcHP and att * thisPercent + thisNumber or 0
			end,
	}
SkillManager[0319] =
	{
		name = "飞天连斩", --金老
		desc = function (lv)
				return "对敌方生命最少的英雄造成160%物理攻击伤害，第4回合释放，冷却时间3回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 3, 
		start = 4, 
		isMana = false, 
		target = SkillManager_SINGLE_0, 
		damageRatio = 1.6,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 4, 
		haloAction = 2,
		
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
-----------------------------------------------------------------------------物攻无法行动
SkillManager[0320] =
	{
		name = "拳震山河", --古青阳
		desc = function (lv)
				return "对敌方随机1名英雄造成200%物理伤害，60%概率使敌方失去1个回合行动力，第3回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 3, 
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_1, 
		damageRatio = 2,
		runType = 0, 
		bannerType = false, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 21, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.6 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferSeal(0,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0321] =
	{
		name = "千幻玄冰刺", --地魔老鬼
		desc = function (lv)
				return "对纵列敌人造成120%法术伤害，100%概率使敌方虚弱（减少30%攻击力，持续2次），第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 1.2,
		runType = 0, 
		bannerType = true,
		shout = true,
		shakable = true,
		prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 3, 
		injureAction = 1, 
		missileAction= 9, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,

				setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferDecrease(2,2,0.3,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
		--setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
		--		local thisProbability = 0.3 --[0,1] 生成概率,数值越大,概率越高
		--		if thisProbability > probability then
		--			return createBufferFreeze(0,1) --crcreateBufferFreezeeateBuffer*****参考fighterbuffer.lua
		--		else
		--			return nil
		--		end
		--	end,
	}
SkillManager[0322] =
	{
		name = "雷霆震落", --炎烬
		desc = function (lv)
				return "攻击敌人并造成伤害时，70%概率永久降低对方30%基础防御力" 			
			end,
		type = SkillManager_TYPE_PASSIVE_SETA,
		sattlementFunc = function(lv,probability) --必须，lv：技能等级；
				local thisProbability    = 0.7
				local thisAttackPercent  = 0 --[-1,0)攻击百分比,被攻击方降低攻击；[0,1]攻击方增加攻击
				local thisDefencePercent = -0.3 --[-1,0)防御百分比,被攻击方降低防御；[0,1]攻击方增加防御
				local thisHPPercent      = 0 --[0,1] 吸血百分比,攻击方吸血
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,
	}
----------------------------------------------------------------------------------------物后单
SkillManager[0323] =
	{
		name = "炙火舞", --唐火儿
		desc = function (lv)
				return "对随机1名敌人造成120%法术伤害，65%概率产生伤害值70%的灼烧效果（持续2回合），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_1, 
		damageRatio = 1.2,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.65 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(8,2,damage,0.7) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
--SkillManager[0325] =
--	{
--		name = "断魂灭魄", --[0324][0325][0326]
--		desc = function (lv)
--				return "对后排敌人造成180%物理伤害，第1回合释放，冷却时间1回合" 			
--			end,
--		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
--		start = 1, 
--		isMana = false, 
--		target = SkillManager_MULTI_ROW_2, 
--		damageRatio = 1.8,
--		runType = 0, 
--		--bannerType = true,
--		--prepareActionF= 0, 
--		ignoreIMRE = false, 
--		attackAction = 1, 
--		injureAction = 0, 
--		missileAction= 1, 
--		effectAction = 0, 
--		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
--				return att_all
--			end,
--	}
SkillManager[0325] = 
	{
		name = "天赐蛇甲",--美杜莎
		desc = function (lv)
				return "为自身增加护盾（减少60%攻击伤害，抵挡3次攻击），第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = false, 
		target = SkillManager_OWN_SELF, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false,
		--shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferReduction(6,3,0.6,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,

	}
SkillManager[0324] =
	{
		name = "断魂灭魄", --
		desc = function (lv)
				return "对后排敌人造成80%物理伤害，第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 0.8,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 1, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0327] =
	{
		name = "龙爪裂天", --[0327][0328][0329][0330]，熊战
		desc = function (lv)
				return "对后排单个敌人造成120%物理伤害，第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = false, 
		target = SkillManager_SINGLE_BACK, 
		damageRatio = 1.2,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 1, 
		effectAction = 12, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0328] =
	{
		name = "威爪裂天", --[0327][0328][0329][0330]烛离，凰轩
		desc = function (lv)
				return "对单个敌人造成100%物理攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 1, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0331] =
	{
		name = "冰蟒臂", --冰元
		desc = function (lv)
				return "对敌方后排单体英雄造成65%物理攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_SINGLE_BACK, 
		damageRatio = 0.65,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 4, 
		missileAction= 0, 
		effectAction = 20, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0332] =
	{
		name = "旋风斧", --[0332][0333]黑擎，古青阳
		desc = function (lv)
				return "对单个敌人造成110%物理伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 1.1,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 10, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0334] =
	{
		name = "风灵分形剑", --[0334][0335][0336]纳兰嫣然，
		desc = function (lv)
				return "对单个敌人造成100%物理伤害，自身任何的负面状态都会使攻击提高50%，第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = false, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 12, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
							local thisBuffers ={BUFFER_TYPE_POISON, BUFFER_TYPE_BURN, BUFFER_TYPE_CURSE, BUFFER_TYPE_DECREASE,BUFFER_TYPE_CURELESS,}
				for i = 1,#myBuffers do
					for j = 1,#thisBuffers do
						if myBuffers[i] == thisBuffers[j] then
					    return att_all*1.5
						end
					end
				end
				return att_all
			end,
	}
	
SkillManager[0335] =
	{
		name = "流风指", --凤清儿
		desc = function (lv)
				return "对单个敌人造成220%物理伤害，100%概率击晕目标（效果持续1回合），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 2.2,
		runType = 0, 
		shout = true,
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 12, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
					return att_all
			end,

                setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferStun(0,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
                
	}
--SkillManager[0337] =
--	{
--		name = "屠龙剑", --
--		desc = function (lv)
--				return "对敌方后排单体英雄造成180%物理攻击伤害，第1回合释放，冷却时间2回合" 			
--			end,
--		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
--		start = 1, 
--		isMana = false, 
--		target = SkillManager_SINGLE_BACK, 
--		damageRatio = 1.8,
--		runType = 0, 
--		--bannerType = true,
--		--prepareActionF= 0, 
--		ignoreIMRE = false, 
--		attackAction = 1, 
--		injureAction = 0, 
--		--missileAction= 0, 
--		effectAction = 5, 
--		haloAction = 2,
--		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
--				return att_all
--			end,
--	}
SkillManager[0338] =
	{
		name = "天凰霸拳", --凰轩
		desc = function (lv)
				return "对随机2个敌人造成220%物理伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_2, 
		damageRatio = 2.2,
		runType = 0, 
		--bannerType = true,
		bannerType = true,
		shout = true,
		prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 1, 
		effectAction = 12, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
----------------------------------------------------------------------------------------物后排
SkillManager[0339] =
	{
		name = "瞬风劫", --火稚
		desc = function (lv)
				return "对敌方后排全体英雄造成20%物理攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 0.2,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0340] =
	{
		name = "落雁掌", --辰闲
		desc = function (lv)
				return "对敌方后排全体英雄造成70%物理攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 0.7,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0341] =
	{
		name = "嗜血蛇纹", --美杜莎
		desc = function (lv)
				return "攻击对方并造成伤害，100%概率将50%伤害值转化为自身生命" 			
			end,
		type = SkillManager_TYPE_PASSIVE_SETA,
		sattlementFunc = function(lv,probability) --必须，lv：技能等级；
				local thisProbability    = 1
				local thisAttackPercent  = 0 --[-1,0)攻击百分比,被攻击方降低攻击；[0,1]攻击方增加攻击
				local thisDefencePercent = 0 --[-1,0)防御百分比,被攻击方降低防御；[0,1]攻击方增加防御
				local thisHPPercent      = 0.5 --[0,1] 吸血百分比,攻击方吸血
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,
	}
SkillManager[0342] =
	{
		name = "天神震怒", --[0342][0343]丹塔长老
		desc = function (lv)
				return "对全体敌人造成80%物理伤害，对方处于虚弱状态时增加200%攻击力，第3回合开始每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 3, 
		isMana = false, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 0.8,
		runType = 0, 
		bannerType = true,
		shout = true,
		shakable = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 12, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				local thisBuffers ={BUFFER_TYPE_DECREASE}
				for i = 1,#enemyBuffers do
					for j = 1,#thisBuffers do
						if enemyBuffers[i] == thisBuffers[j] then
							return att_all*3
						end
					end
				end
				return att_all
			end,
	}
SkillManager[0344] =
	{
		name = "太虚一击", --紫妍
		desc = function (lv)
				return "对血量最低的敌人造成340%物理伤害，自身血量高于对方血量时增加额外180%攻击力，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_SINGLE_0, 
		damageRatio = 3.4,
		runType = 0,
		bannerType = true,
		shout = true,
		shakable = true,
		prepareActionF= 4, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 0, 
		effectAction = 1, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				if srcHP > dstHP then
					return att_all*1.8
				else
					return att_all
				end
			end,
	}
SkillManager[0345] =
	{
		name = "幻影飞斧", --黑擎
		desc = function (lv)
				return "对单个敌人造成300%物理伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 3,
		runType = 1, 
		bannerType = true,
		shout = true,
		prepareActionF= 4, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 10, 
		effectAction = 12, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0346] =
	{
		name = "裂风虎啸掌", --
		desc = function (lv)
				return "对后排敌人造成160%物理攻击伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 1.6,
		runType = 0, 
		bannerType = true,
		shout = true,
		shakable = true,
		prepareActionF= 2, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 21, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0347] =
	{
		name = "鼠尾一击", --
		desc = function (lv)
				return "对敌方后排英雄造成100%物理攻击伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0348] =
	{
		name = "邪风斩", --妖花邪君
		desc = function (lv)
				return "对敌方后排英雄造成80%物理攻击伤害，第3回合释放，冷却时间3回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 3, 
		start = 3, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 0.8,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0349] =
	{
		name = "百蛊啖魂", --四天尊
		desc = function (lv)
				return "对所有敌人造成100%物理伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 1,
		runType = 0, 
		bannerType = true,
		shout = true,
		shakable = true,
		prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= -4, 
		effectAction = 10, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
-----------------------------------------------------------------------------------物攻无法行动
SkillManager[0350] =
	{
		name = "星落长空", --曹单
		desc = function (lv)
				return "对敌方随机1名英雄造成65%物理攻击伤害，20%概率使敌方失去下一回合行动力，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_1, 
		damageRatio = 0.65,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.2 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferStun(0,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,	
	}
SkillManager[0351] =
	{
		name = "涅槃重生", --唐火儿
		desc = function (lv)
				return "对中毒和灼烧效果免疫" 			
			end,
		type = SkillManager_TYPE_PASSIVE_IMBF,
		immunityBufferFunc = function(lv,bufferID) --必须，lv：技能等级；bufferID：待检测的bufferID
				local thisBufferIDs = {BUFFER_TYPE_POISON, BUFFER_TYPE_BURN} --免疫的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua）
				for i = 1,#thisBufferIDs do
					if thisBufferIDs[i] == bufferID then
						return true
					end
				end
				return false
			end,
	}
-----------------------------------------------------------------------------------物前排
SkillManager[0352] =
	{
		name = "长枪突刺", --夭夜
		desc = function (lv)
				return "对敌方前排全体英雄造成20%物理攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 0.2,
		runType = 1, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0353] =
	{
		name = "六合游身尺", --萧炎
		desc = function (lv)
				return "对前排敌人造成120%物理伤害，50%概率增加20%攻击力，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 1.5,
		runType = 1, 
		bannerType = true,
		shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 4, 
		injureAction = 3, 
		--missileAction= 1, 
		effectAction = 20,
		shakable = true, 
		
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				local thisProbability = 0.3
				if thisProbability > probability then
					return att_all*1.2
				else		
					return att_all
				end
			end,
	}
SkillManager[0354] =
	{
		name = "剑荡平山", --[0354][0355]，铁剑尊者
		desc = function (lv)
				return "对随机1个敌人造成300%物理伤害，自身血量低于对方血量时增加20%攻击力，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_1, 
		damageRatio = 3,
		runType = 0, 
		bannerType = true,
		shout = true,
		prepareActionF= 0, 
		ignoreIMRE = false,  
		attackAction = 1, 
		injureAction = 4, 
		missileAction= 5, 
		effectAction = 21, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				if srcHP < dstHP then
					return att_all*1.2
				else
					return att_all
				end
			end,
	}
SkillManager[0355] =
	{
		name = "血魔附体",
		desc = function (lv)
				return "攻击对方并造成伤害时，80%概率永久提升15%基础攻击力" 			
			end,
		type = SkillManager_TYPE_PASSIVE_SETA,
		sattlementFunc = function(lv,probability) --必须，lv：技能等级；
				local thisProbability    = 0.8
				local thisAttackPercent  = 0.15 --[-1,0)攻击百分比,被攻击方降低攻击；[0,1]攻击方增加攻击
				local thisDefencePercent = 0 --[-1,0)防御百分比,被攻击方降低防御；[0,1]攻击方增加防御
				local thisHPPercent      = 0 --[0,1] 吸血百分比,攻击方吸血
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,
	}
SkillManager[0356] =
	{
		name = "魂帝斩", --[0356][0357]南龙王
		desc = function (lv)
				return "对血量最少的敌人造成300%物理伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_SINGLE_0, 
		damageRatio = 3,
		runType = 0, 
		bannerType = true,
		shout = true,
		prepareActionF= 1, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0357] =
	{
		name = "魂帝斩", 
		desc = function (lv)
				return "对后排单个敌人造成330%物理攻击伤害，50%概率产生伤害值60%灼烧效果（持续1回合），第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_SINGLE_BACK, 
		damageRatio = 3.3,
		runType = 0, 
		bannerType = true,
		shout = true,
		shakable = true,
		prepareActionF= 1, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 8, 
		effectAction = 7, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.5 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(1,1,damage,0.6) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
		
	}
SkillManager[0358] =
	{
		
		name = "风沙盾",--凤清儿
		desc = function (lv)
				return "为自身增加护盾（减少30%攻击伤害，抵挡3次攻击），第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = false, 
		target = SkillManager_OWN_SELF, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false,
		--shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferReduction(3,3,0.3,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0359] =
	{
		name = "血裂斩", --慕骨老人
		desc = function (lv)
				return "对前排敌人造成150%物理伤害，70%概率使目标失去1次被治疗机会，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 1.5,
		runType = 0, 
		bannerType = false, 
		--shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 4, 
		effectAction = 10, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,

				setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.7 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferCureless(0,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,

		
	}
SkillManager[0360] =
	{
		name = "奔雷枪术", --米特尔
		desc = function (lv)
				return "对敌方前排英雄造成35%物理攻击伤害，第3回合释放，冷却时间3回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 3, 
		start = 3, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 0.35,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0361] =
	{
		name = "大裂劈棺爪", --柳擎
		desc = function (lv)
				return "对前排敌人造成100%物理伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 1,
		runType = 1, 
		bannerType = false,
		shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 7, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0362] =
	{
		name = "雷鸣剑气", --天雷子，邙天尺
		desc = function (lv)
				return "对随机3个敌人造成160%法术伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_3, 
		damageRatio = 1.6,
		runType = 0, 
		prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		bannerType = true,
		shout = true,
		--missileAction= 0, 
		effectAction = 5, 
		haloAction = 2,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0363] =
	{
		name = "电光银链", --萧厉
		desc = function (lv)
				return "对敌方前排全体英雄造成100%物理攻击伤害，第4回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 3, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 10, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
----------------------------------------------------------------------------------------物随机
SkillManager[0364] =
	{
		name = "御天一击", --米特尔
		desc = function (lv)
				return "对敌方随机2名英雄造成30%物理攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_2, 
		damageRatio = 0.3,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 2, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0365] =
	{
		name = "回风落雁剑", --曹单
		desc = function (lv)
				return "对敌方随机2名英雄造成40%物理攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_2, 
		damageRatio = 0.4,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 12, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0366] =
	{
		name = "回魂术", -- 慕青鸾
		desc = function (lv)
				return "治疗己方全体英雄（400%），第2回合释放，冷却时间3回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 3, 
		start = 2, 
		isMana = true, 
		target = SkillManager_OWN_ALL, 
		damageRatio = 1,
		runType = 0, 
		shout = true,
		bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 
		regeFunc = function(lv,att_all) 
				return att_all*4
			end,
	}
SkillManager[0367] =
	{
		name = "狂魔霸天", --金老
		desc = function (lv)
				return "对敌方随机2名英雄造成50%物理攻击伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_2, 
		damageRatio = 0.5,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 6, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0368] =
	{
		name = "冰神箭", --天蛇
		desc = function (lv)
				return "对纵列敌人造成210%物理伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 2.1,
		runType = 0, 
		bannerType = false, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 2, 
		injureAction = 1, 
		--missileAction= 14, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0369] =
	{
		name = "狮寸劲", --莫崖
		desc = function (lv)
				return "对敌方随机2名英雄造成80%物理攻击伤害，第3回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_2, 
		damageRatio = 0.8,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0370] =
	{
		name = "凝瑰龙影", --紫妍
		desc = function (lv)
				return "攻击对方并造成伤害，100%概率将100%伤害值转化为自身生命" 			
			end,
		type = SkillManager_TYPE_PASSIVE_SETA,
		sattlementFunc = function(lv,probability) --必须，lv：技能等级；
				local thisProbability    = 1
				local thisAttackPercent  = 0 --[-1,0)攻击百分比,被攻击方降低攻击；[0,1]攻击方增加攻击
				local thisDefencePercent = 0 --[-1,0)防御百分比,被攻击方降低防御；[0,1]攻击方增加防御
				local thisHPPercent      = 1 --[0,1] 吸血百分比,攻击方吸血
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,
	}
SkillManager[0371] =
	{
		name = "佛怒火莲", --萧炎
		desc = function (lv)
				return "对随机3个敌人造成120%物理伤害，90%概率产生攻击伤害值150%的灼烧效果（持续2回合），第1回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_3, 
		damageRatio = 2,
		runType = 0, 
		bannerType = false, 
		prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 1, 
		effectAction = 12, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.9 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(15,2,damage,1.5) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0372] =
	{
		name = "天冥玄雷", --天冥老妖
		desc = function (lv)
				return "对随机1个敌人造成120%物理攻击伤害，第4回合开始每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 4, 
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_1, 
		damageRatio = 1.2,
		runType = 0, 
		bannerType = false, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 4, 
		missileAction= 14, 
		effectAction = 20, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0373] =
	{
		name = "龙熊甩尾", --熊战
		desc = function (lv)
				return "对随机3个敌人造成160%物理伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_3, 
		damageRatio = 1.6,
		runType = 0, 
		bannerType = true, 
		shout = true,
		shakable = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 12, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0374] =
	{
		name = "狂狮吟", --穆蛇
		desc = function (lv)
				return "对敌方随机3名英雄造成60%物理攻击伤害，第3回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 3, 
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_3, 
		damageRatio = 0.6,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 1, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0375] =
	{
		name = "风之极", --纳兰嫣然
		desc = function (lv)
				return "对随机3个敌人造成180%物理伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_3, 
		damageRatio = 1.8,
		runType = 0, 
		bannerType = true,
		shout = true,
		shakable = true,
		prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 5,
		haloAction = 2, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0376] =
	{
		name = "龙旋掌", --北龙王，
		desc = function (lv)
				return "对前排敌人造成140%物理伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 1.4,
		runType = 0, 
		bannerType = true,
		shout = true,
		shakable = true,
		prepareActionF= 2, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 1, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0377] =
	{
		name = "裂风虎啸", --
		desc = function (lv)
				return "对敌方随机3名英雄造成150%物理伤害，第3回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 3, 
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_3, 
		damageRatio = 1.5,
		runType = 0, 
		bannerType = false, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 4, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
-----------------------------------------------------------------------物直
SkillManager[0378] =
	{
		name = "碎地拳", --莫崖
		desc = function (lv)
				return "对敌方纵列英雄造成27%物理攻击伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 0.27,
		runType = 1, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 2, 
		injureAction = 1, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0379] =
	{
		name = "幻影突刺", --炎烬
		desc = function (lv)
				return "对随机2名敌人造成90%物理攻击伤害，第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_2, 
		damageRatio = 0.9,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 1, 
		missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0380] =
	{
		name = "幻魂身法", --九天尊
		desc = function (lv)
				return "对单个敌人造成100%物理伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 1,
		runType = 1, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0381] =
	{
		name = "玄冰火诀", --地魔老鬼
		desc = function (lv)
				return "对随机1个敌人造成150%法术伤害，100%概率产生伤害40%灼烧效果（持续3回合），第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_1, 
		damageRatio = 1.5,
		runType = 1, 
		bannerType = false,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 9, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(4,2,damage,0.4) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0382] =
	{
		name = "破天三斧", 
		desc = function (lv)
				return "对单个敌人造成280%物理攻击伤害，当敌人附带灼烧效果时增加50%攻击力，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 2.8,
		runType = 1, 
		--bannerType = true,
		shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 12, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				local thisBuffers = {BUFFER_TYPE_BURN} --攻击增幅触发的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua）
				for i = 1,#enemyBuffers do
					for j = 1,#thisBuffers do
						if enemyBuffers[i] == thisBuffers[j] then
							return att_all*1.5
						end
					end
				end
				return att_all
			end,
	}
SkillManager[0383] =
	{
		name = "大裂岩", --
		desc = function (lv)
				return "对敌方纵列英雄造成50%物理攻击伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 0.5,
		runType = 1, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 2, 
		injureAction = 1, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0384] =
	{
		name = "骨皇裂天", --
		desc = function (lv)
				return "对后排单个敌人造成300%物理伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_SINGLE_BACK, 
		damageRatio = 3,
		runType = 0, 
		bannerType = false,
		shout = true,
		prepareActionF= 2, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 1,
		shakable = true,
		effectAction = 12, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0385] =
	{
		name = "碧波掌", --韩雪
		desc = function (lv)
				return "对敌方纵列英雄造成60%物理攻击伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 0.6,
		runType = 1, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 1, 
		missileAction= 9, 
		effectAction = 10, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0386] =
	{
		name = "残火护身", --林焱
		desc = function (lv)
				return "死亡时释放，为己方随机3名英雄增加护盾（减少20%攻击伤害，抵挡4次攻击）" 			
			end,		
		type = SkillManager_TYPE_ACTIVE_EXIT, --属性含义参照SkillManager_TYPE_ACTIVE_ROUND
		--start属性无效
		isMana = true,
		target = SkillManager_OWN_RANDOM_3,
		runType = 0,
		bannerType = true,
		shout = true,
		ignoreIMRE = false,
		attackAction = 3,
		injureAction = 0,
		--prepareActionF= 0,
		--missileAction= -4, 
		effectAction = 20,
		damageRatio = 1,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferReduction(2,4,0.2,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0387] =
	{
		name = "刀碎虚空", --古道
		desc = function (lv)
				return "对随机2个敌人造成240%物理伤害，对方剩余血量高于60%时增加30%攻击力，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_2, 
		damageRatio = 2.4,
		runType = 1, 
		bannerType = true,
		shout = true,
		prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				if dstHP > dstHPMax then
					return att_all*1.3
				else
					return att_all
			end
		end,
	}
SkillManager[0388] =
	{
		name = "御剑冲灵", --剑尊者
		desc = function (lv)
				return "替补上阵时立刻释放，对纵列敌人造成240%物理伤害，无视免疫和伤害减免效果" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ENTER , 
		--start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 2.4,
		runType = 1, 
		bannerType = true,
		shout = true,
		shakable = true,
		prepareActionF= 0, 
		ignoreIMRE = true, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 5, 
		haloAction = 2,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0389] =
	{
		name = "千碎雷锤", --洪辰
		desc = function (lv)
				return "对敌方纵列英雄造成80%物理攻击伤害，第3回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 3, 
		isMana = false, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 0.8,
		runType = 1, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 2, 
		injureAction = 1, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[0390] =
	{
		name = "黄泉腐尸臂", --天冥老妖
		desc = function (lv)
				return "对前排敌人造成140%物理攻击伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 1.4,
		runType = 0, 
		bannerType = true,
		shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 4, 
		missileAction= 14, 
		effectAction = 20, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
---------------------------------------------------------------------------吸血
SkillManager[0391] = 
	{
		name = "黑极崩劲",--
		desc = function (lv)
				return "攻击对方并造成伤害时，50%概率将90%伤害值转化为自身生命" 			
			end,
		type = SkillManager_TYPE_PASSIVE_SETA,
		sattlementFunc = function(lv,probability) --必须，lv：技能等级；
				local thisProbability    = 0.5
				local thisAttackPercent  = 0 --[-1,0)攻击百分比,被攻击方降低攻击；[0,1]攻击方增加攻击
				local thisDefencePercent = 0 --[-1,0)防御百分比,被攻击方降低防御；[0,1]攻击方增加防御
				local thisHPPercent      = 0.90 --[0,1] 吸血百分比,攻击方吸血
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,
	}
SkillManager[0392] = 
	{
		name = "吸血",--吴昊
		desc = function (lv)
				return "攻击对方并造成伤害时，60%概率将45%伤害值转化为自身生命" 			
			end,
		type = SkillManager_TYPE_PASSIVE_SETA,
		sattlementFunc = function(lv,probability) --必须，lv：技能等级；
				local thisProbability    = 0.6
				local thisAttackPercent  = 0 --[-1,0)攻击百分比,被攻击方降低攻击；[0,1]攻击方增加攻击
				local thisDefencePercent = 0 --[-1,0)防御百分比,被攻击方降低防御；[0,1]攻击方增加防御
				local thisHPPercent      = 0.45 --[0,1] 吸血百分比,攻击方吸血
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,
	}
SkillManager[0393] = 
	{
		name = "九森百噬魂",--鹜护法
		desc = function (lv)
				return "对敌方随机2名英雄造成100%法术攻击伤害，100%概率产生攻击伤害50%的诅咒效果（持续2回合），第2回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_2, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 10, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferCurse(0,2,damage, 0.5) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0394] = 
	{
		name = "血魔蚀主",--范凌
		desc = function (lv)
				return "攻击对方并造成伤害时，20%概率将10%伤害值转化为自身生命" 			
			end,
		type = SkillManager_TYPE_PASSIVE_SETA,
		sattlementFunc = function(lv,probability) --必须，lv：技能等级；
				local thisProbability    = 0.2
				local thisAttackPercent  = 0 --[-1,0)攻击百分比,被攻击方降低攻击；[0,1]攻击方增加攻击
				local thisDefencePercent = 0 --[-1,0)防御百分比,被攻击方降低防御；[0,1]攻击方增加防御
				local thisHPPercent      = 0.1 --[0,1] 吸血百分比,攻击方吸血
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,
	}
SkillManager[0395] = 
	{
		name = "血魂变",--范痨
		desc = function (lv)
				return "攻击对方并造成伤害时，30%概率将10%伤害值转化为自身生命" 			
			end,
		type = SkillManager_TYPE_PASSIVE_SETA,
		sattlementFunc = function(lv,probability) --必须，lv：技能等级；
				local thisProbability    = 0.3
				local thisAttackPercent  = 0 --[-1,0)攻击百分比,被攻击方降低攻击；[0,1]攻击方增加攻击
				local thisDefencePercent = 0 --[-1,0)防御百分比,被攻击方降低防御；[0,1]攻击方增加防御
				local thisHPPercent      = 0.1 --[0,1] 吸血百分比,攻击方吸血
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,
	}
----------------------------------------------------------
SkillManager[0396] =
	{
		name = "倾国倾城", --雅妃
		desc = function (lv)
				return "我方随机2名英雄100%概率增加50%攻击力（持续2次攻击），第1回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 1, 
		isMana = false, 
		target = SkillManager_OWN_RANDOM_2, 
		damageRatio = 1,
		runType = 0, 
		bannerType = true, 
		shout = true, 
		--prepareActionF= 0, 
		ignoreIMRE = true, 
		attackAction = 3, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferIncrease(3,2,0.5,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
----------------------------------------------------------------------持续增攻
SkillManager[0397] =
	{
		name = "火狼护体", --曹单
		desc = function (lv)
				return "30%概率增加我方随机1名英雄40%基础攻击（持续2次），第1回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 1, 
		isMana = false, 
		target = SkillManager_OWN_RANDOM_1, 
		damageRatio = 0.9,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.3 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferIncrease(0,2,0.4,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0398] =
	{
		name = "风雷杀", --洪辰
		desc = function (lv)
				return "25%概率增加己方随机1名英雄120%基础攻击（持续1次），第1回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 1, 
		isMana = false, 
		target = SkillManager_OWN_RANDOM_1, 
		damageRatio = 0.9,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.25 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferIncrease(0,1,1.2,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0399] =
	{
		name = "炎之帝身", --炎烬
		desc = function (lv)
				return "对随机1个敌人造成250%物理攻击伤害，60%概率产生攻击伤害80%灼烧（持续2回合），第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_1, 
		damageRatio = 2.5,
		runType = 0, 
		bannerType = true,
		shout = true,
		shakable = true,
		prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 0, 
		effectAction = 12, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.6 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(20,2,damage,0.8) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0400] =
	{
		name = "潜龙地啸", --叶重
		desc = function (lv)
				return "30%概率增加我方随机1名英雄30%基础攻击（持续2次），第4回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 4, 
		isMana = false, 
		target = SkillManager_OWN_RANDOM_1, 
		damageRatio = 0.9,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 0, 
		effectAction = 0, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.3 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferIncrease(0,2,0.3,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
-------------------------------------------------------------------------治疗
SkillManager[0401] =
	{
		name = "天蚀雨", --小医仙
		desc = function (lv)
				return "治疗我方血量最少的英雄（250%），第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_OWN_0, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false,
		--shout = true,
		prepareActionF= 4, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 
		
		regeFunc = function(lv,att_all) 
				return att_all*2.5
			end,
	}

SkillManager[0402] =
	{
		name = "天蚀雨", --怪物小医仙
		desc = function (lv)
				return "治疗我方血量最少的英雄（80%），第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_OWN_0, 
		damageRatio = 1,
		runType = 0, 
		bannerType = true,
		shout = true,
		prepareActionF= 4, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 
		
		regeFunc = function(lv,att_all) 
				return att_all*0.8
			end,
	}
SkillManager[0403] =
	{
		name = "回气净体", --小公主
		desc = function (lv)
				return "治疗我方血量最少的英雄（150%），第3回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 3, 
		isMana = true, 
		target = SkillManager_OWN_0, 
		damageRatio = 1.5,
		runType = 0, 
		bannerType = false,
		shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 
		regeFunc = function(lv,att_all) 
				return att_all*1.5
			end,
	}
SkillManager[0404] =
	{
		name = "药皇荣光", --丹王古河
		desc = function (lv)
				return "治疗己方全体英雄（280%），第2回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 2, 
		isMana = true, 
		target = SkillManager_OWN_ALL, 
		damageRatio = 1,
		runType = 0, 
		bannerType = true,
		shout = true, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 
		regeFunc = function(lv,att_all) 
				return att_all*2.8
			end,
	}
SkillManager[0405] =
	{
		name = "浸沐春风", --炎利
		desc = function (lv)
				return "回复我方随机3名英雄生命，第3回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 3, 
		isMana = true, 
		target = SkillManager_OWN_RANDOM_3, 
		damageRatio = 0.9,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 
		regeFunc = function(lv,att_all) 
				return att_all*0.35
			end,
	}
SkillManager[0406] =
	{
		name = "扭转乾坤", --丹王古河
		desc = function (lv)
				return "治疗己方全体英雄（50%），清除己方全体英雄身上的灼烧与中毒负面状态，第1回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 1, 
		isMana = true, 
		target = SkillManager_OWN_ALL, 
		damageRatio = 0.9,
		runType = 0, 
		bannerType = false,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 
		regeFunc = function(lv,att_all) 
				return att_all*0.5
			end,
		clearFunc = function(lv) 
				return {BUFFER_TYPE_POISON,BUFFER_TYPE_BURN}
			end,
	}
SkillManager[0407] =
	{
		name = "浴火重生", --
		desc = function (lv)
				return "治疗己方全体英雄（100%），并消除封印、冰冻、晕眩、虚弱效果，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_OWN_ALL, 
		damageRatio = 1,
		runType = 0, 
		bannerType = true,
		shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 
		regeFunc = function(lv,att_all) 
				return att_all
			end,
		clearFunc = function(lv) 
				return {BUFFER_TYPE_FREEZE,BUFFER_TYPE_STUN,BUFFER_TYPE_SEAL,BUFFER_TYPE_DECREASE}
			end,
	}

SkillManager[0408] =
	{
		name = "龙旋掌", --曜天火
		desc = function (lv)
				return "对随机3个敌人造成100%物理伤害，90%概率产生攻击伤害值80%的灼烧效果（持续2回合），第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_3, 
		damageRatio = 1,
		runType = 0, 
		bannerType = true, 
		shout = true,
		prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 1, 
		effectAction = 12, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.9 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(15,2,damage,0.8) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
------------------------------------------------------------------手动技能
SkillManager[0500] =
	{
		name = "嗜血甲",
		desc = function (lv)
				return "使我方随机2个英雄受到下一次攻击时减少"..(lv*100).."点伤害，聚气1回合"	
			end,
		type = SkillManager_TYPE_MANUAL,
		cd = 1,
		isMana = false,
		target = SkillManager_OWN_RANDOM_2,
		ignoreIMRE = false,
		--bgAction = 0,
		bannerType = true,
		injureAction = 0,
		--missileAction= 1,  
		effectAction = 20,
		--damageRatio = 1,
		--attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers)
		--		return att_all
		--	end,
		setupBuffer = function(lv,att,damage,probability) --可选，技能附带的Buffer，lv：技能等级；att：角色的基础攻击；damage：最终造成的伤害值（没有attackFunc时无意义）
				local thisProbability = 1 --(0,1] 生成概率，数值越大，概率越高
				if thisProbability > probability then
					return createBufferReduction(0,1,0,100 * lv) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
			
	}
SkillManager[0501] =
	{
		name = "风雷祭", 
		desc = function (lv)
				return "使我方随机2名英雄提升"..(lv*100).."点攻击力，持续2次攻击，聚气1回合" 
			end,
		type = SkillManager_TYPE_MANUAL,
		cd = 1,
		isMana = true,
		target = SkillManager_OWN_RANDOM_2,
		ignoreIMRE = false,
		--bgAction = 0,
		bannerType = true,
		injureAction = 0,
		--missileAction= 1,
		effectAction = 20,
		--damageRatio = 1,
		--attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers)
		--		return att_all
		--	end,
		setupBuffer = function(lv,att,damage,probability) --可选，技能附带的Buffer，lv：技能等级；att：角色的基础攻击；damage：最终造成的伤害值（没有attackFunc时无意义）
				local thisProbability = 1 --(0,1] 生成概率，数值越大，概率越高
				
				if thisProbability > probability then
					return createBufferIncrease(0,2,0,lv*100) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}

SkillManager[0502] =
	{
		name ="丹融天",
		desc = function (lv)
				return "为我方随机两名英雄持续回血2个回合，每次回复"..(lv*200).."点生命，聚气1回合" 		
			end,
		type = SkillManager_TYPE_MANUAL,
		cd = 1,
		isMana = true,
		target = SkillManager_OWN_RANDOM_2,
		ignoreIMRE = false,
		--bgAction = 0,
		bannerType = true,
		injureAction = 0,
		--missileAction= 1,
		effectAction = 19,
		--damageRatio = 1,
		--attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers)
		--		return att_all
		--	end,
		setupBuffer = function(lv,att,damage,probability) --可选，技能附带的Buffer，lv：技能等级；att：角色的基础攻击；damage：最终造成的伤害值（没有attackFunc时无意义）
				local thisProbability = 1 --(0,1] 生成概率，数值越大，概率越高
				if thisProbability > probability then
					return createBufferRege(0,2,att,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0503] =
	{
		name = "黑极崩劲",
		desc = function (lv)
				return "对敌方随机1名英雄造成"..(lv*800).."点物理攻击伤害，聚气2回合" 			
			end,
		type = SkillManager_TYPE_MANUAL,
		cd = 2,
		isMana = false,
		target = SkillManager_MULTI_RANDOM_1,
		ignoreIMRE = false,
		--bgAction = 0,
		bannerType = true,
		injureAction = 0,
		--missileAction= 1,
		effectAction = 3,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers)
				return lv*800
			end,
	}
SkillManager[0504] =
	{
		name = "毁灭之印",
		desc = function (lv)
				return "对敌方全体造成"..(lv*300).."点物理攻击伤害，聚气3回合" 			
			end,
		type = SkillManager_TYPE_MANUAL,
		cd = 3,
		isMana = false,
		target = SkillManager_MULTI_ALL,
		ignoreIMRE = false,
		--bgAction = 0,
		bannerType = true,
		injureAction = 0,
		missileAction= -8,
		effectAction = 0,
		shakable = true,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers)
				return lv*300
			end,
	}
SkillManager[0505] =
	{
		name = "空间绞杀",
		desc = function (lv)
				return "对敌方前排造成"..(lv*600).."点物理攻击伤害，聚气1回合" 			
			end,
		type = SkillManager_TYPE_MANUAL,
		cd = 1,
		isMana = false,
		target = SkillManager_MULTI_ROW_1,
		ignoreIMRE = false,
		--bgAction = 0,
		bannerType = true,
		injureAction = 0,
		--missileAction= -4,
		effectAction = 10,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers)
				return  lv*600
			end,
	}
SkillManager[0506] =
	{
		name = "焰分噬浪",
		desc = function (lv)
				return "对敌方后排造成"..(lv*600).."点物理攻击伤害，聚气2回合" 			
			end,
		type = SkillManager_TYPE_MANUAL,
		cd = 2,
		isMana = false,
		target = SkillManager_MULTI_ROW_2,
		ignoreIMRE = false,
		--bgAction = 0,
		bannerType = true,
		injureAction = 0,
		--missileAction= -4,
		effectAction = 0,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers)
				return  lv*600
			end,
	}
SkillManager[0507] =
	{
		name = "玄冰旋杀",
		desc = function (lv)
				return "对敌方随机2名英雄造成"..(lv*600).."点物理攻击伤害，聚气3回合" 			
			end,
		type = SkillManager_TYPE_MANUAL,
		cd = 3,
		isMana = false,
		target = SkillManager_MULTI_RANDOM_2,
		ignoreIMRE = false,
		--bgAction = 0,
		bannerType = true,
		injureAction = 0,
		--missileAction= -4,
		effectAction = 21,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers)
				return  lv*600
			end,
	}
SkillManager[0508] =
	{
		name = "金帝焚天",
		desc = function (lv)
				return "对敌方随机1名英雄造成"..(lv*600).."点法术攻击伤害，聚气1回合" 			
			end,
		type = SkillManager_TYPE_MANUAL,
		cd = 1,
		isMana = true,
		target = SkillManager_MULTI_RANDOM_1,
		ignoreIMRE = false,
		--bgAction = 0,
		bannerType = true,
		injureAction = 0,
		--missileAction= -4,
		effectAction = 4,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers)
				return  lv*600
			end,
	}
SkillManager[0509] =
	{
		name = "佛怒火莲",
		desc = function (lv)
				return "对敌方随机3个英雄造成"..(lv*600).."点法术攻击伤害，聚气3回合" 			
			end,
		type = SkillManager_TYPE_MANUAL,
		cd = 3,
		isMana = true,
		target = SkillManager_MULTI_RANDOM_3,
		ignoreIMRE = false,
		--bgAction = 0,
		bannerType = true,
		injureAction = 0,
		--missileAction= -4,
		effectAction = 0,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers)
				return  lv*600
			end,
	}
SkillManager[0510] =
	{
		name = "魂之葬礼",
		desc = function (lv)
				return "对敌方前排造成"..(lv*600).."点法术攻击伤害，聚气1回合" 			
			end,
		type = SkillManager_TYPE_MANUAL,
		cd = 1,
		isMana = true,
		target = SkillManager_MULTI_ROW_1,
		ignoreIMRE = false,
		--bgAction = 0,
		bannerType = true,
		injureAction = 0,
		--missileAction= -4,
		effectAction = 7,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers)
				return  lv*600
			end,
	}
SkillManager[0511] =
	{
		name = "九幽冥手",
		desc = function (lv)
				return "对敌方后排造成"..(lv*600).."点法术攻击伤害，聚气2回合" 			
			end,
		type = SkillManager_TYPE_MANUAL,
		cd = 2,
		isMana = true,
		target = SkillManager_MULTI_ROW_2,
		ignoreIMRE = false,
		--bgAction = 0,
		bannerType = true,
		injureAction = 0,
		--missileAction= -4,
		effectAction = 10,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers)
				return  lv*600
			end,
	}
SkillManager[0512] =
	{
		name = "水曼陀罗",
		desc = function (lv)
				return "对敌方随机2名英雄造成"..(lv*600).."点法术攻击伤害，聚气2回合" 			
			end,
		type = SkillManager_TYPE_MANUAL,
		cd = 2,
		isMana = true,
		target = SkillManager_MULTI_RANDOM_2,
		ignoreIMRE = false,
		--bgAction = 0,
		bannerType = true,
		injureAction = 0,
		--missileAction= -4,
		effectAction = 0,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers)
				return  lv*600
			end,
	}
SkillManager[0513] =
	{
		name = "天罗炼火",
		desc = function (lv)
				return "对敌方随机1名英雄造成"..(lv*600).."点物理攻击伤害，50%概率产生伤害30%中毒效果（持续2回合），聚气2回合" 			
			end,
		type = SkillManager_TYPE_MANUAL,
		cd = 2,
		isMana = false,
		target = SkillManager_MULTI_RANDOM_1,
		ignoreIMRE = false,
		--bgAction = 0,
		bannerType = true,
		injureAction = 0,
		--missileAction= -4,
		effectAction = 0,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return lv*600
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.5 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferPoison(0,2,att,0.3) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0514] =
	{
		name = "雨蚀苍穹",
		desc = function (lv)
				return "对敌方随机2名英雄造成"..(lv*600).."点物理攻击伤害，30%概率产生伤害50%中毒效果（持续2回合），聚气1回合" 		
			end,
		type = SkillManager_TYPE_MANUAL,
		cd = 1,
		isMana = false,
		target = SkillManager_MULTI_RANDOM_2,
		ignoreIMRE = false,
		--bgAction = 0,
		bannerType = true,
		injureAction = 0,
		--missileAction= -4,
		effectAction = 0,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers)
				return  lv*600
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.3 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferPoison(0,2,att,0.5) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0515] =
	{
		name = "大噬血术",
		desc = function (lv)
				return "对敌方随机1名英雄造成"..(lv*600).."点法术攻击伤害，50%概率产生伤害30%中毒效果（持续2回合），聚气2回合" 			
			end,
		type = SkillManager_TYPE_MANUAL,
		cd = 2,
		isMana = true,
		target = SkillManager_MULTI_RANDOM_1,
		ignoreIMRE = false,
		--bgAction = 0,
		bannerType = true,
		injureAction = 0,
		--missileAction= -4,
		effectAction = 0,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return lv*600
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.5 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferPoison(0,2,att,0.3) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0516] =
	{
		name = "千幻毒泉",
		desc = function (lv)
				return "对敌方随机2名英雄造成"..(lv*600).."点法术攻击伤害，30%概率产生伤害50%中毒效果（持续2回合），聚气1回合" 		
			end,
		type = SkillManager_TYPE_MANUAL,
		cd = 1,
		isMana = true,
		target = SkillManager_MULTI_RANDOM_2,
		ignoreIMRE = false,
		--bgAction = 0,
		bannerType = true,
		injureAction = 0,
		--missileAction= -4,
		effectAction = 0,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers)
				return  lv*600
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.3 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferPoison(0,2,att,0.5) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0517] =
	{
		name = "万影缚魂",
		desc = function (lv)
				return "对敌方随机1名英雄造成"..(lv*300).."点法术攻击伤害，50%概率失去下一回合行动力，无聚气等待" 			
			end,
		type = SkillManager_TYPE_MANUAL,
		cd = 0,
		isMana = true,
		target = SkillManager_MULTI_RANDOM_1,
		ignoreIMRE = false,
		--bgAction = 0,
		bannerType = true,
		injureAction = 0,
		--missileAction= -4,
		effectAction = 0,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return lv*300
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.5 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferSeal(0,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0518] =
	{
		name = "妖瞳控体",
		desc = function (lv)
				return "对敌方随机2名英雄造成"..(lv*150).."点法术攻击伤害，60%概率失去下一回合行动力，聚气3回合" 			
			end,
		type = SkillManager_TYPE_MANUAL,
		cd = 3,
		isMana = true,
		target = SkillManager_MULTI_RANDOM_2,
		ignoreIMRE = false,
		--bgAction = 0,
		bannerType = true,
		injureAction = 0,
		--missileAction= -4,
		effectAction = 0,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers)
				return  lv*150
			end,
				setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.4 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferSeal(0,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[0519] =
	{
		name = "紫晶封印",
		desc = function (lv)
				return "对敌方前排造成"..(lv*600).."点物理攻击伤害，聚气4回合" 			
			end, 
		type = SkillManager_TYPE_MANUAL,
		cd = 4,
		isMana = false,
		target = SkillManager_MULTI_ROW_1,
		ignoreIMRE = false,
		--bgAction = 0,
		bannerType = true,
		injureAction = 0,
		--missileAction= -4,
		effectAction = 0,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers)
				return  lv*600
			end,
	}
SkillManager[0520] =
	{
		name = "雷动八荒",
		desc = function (lv)
				return "对敌方后排造成"..(lv*600).."点法术攻击伤害，聚气3回合" 			
			end,
		type = SkillManager_TYPE_MANUAL,
		cd = 3,
		isMana = true,
		target = SkillManager_MULTI_ROW_2,
		ignoreIMRE = false,
		--bgAction = 0,
		bannerType = true,
		injureAction = 0,
		--missileAction= -4,
		effectAction = 0,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers)
				return  lv*600
			end,
	}
SkillManager[0521] =
	{
		name = "化血",
		desc = function (lv)
				return "回复己方血量最少的英雄"..(lv*200).."点生命，聚气2回合" 			
			end,
		type = SkillManager_TYPE_MANUAL,
		cd = 2,
		isMana = false,
		target = SkillManager_OWN_0,
		ignoreIMRE = false,
		--bgAction = 0,
		bannerType = true,
		injureAction = 0,
		--missileAction= -4,
		effectAction = 19,
		damageRatio = 1,
		regeFunc = function(lv,att_all) 
				return lv*200
			end,
	}
SkillManager[0522] =
	{
		name = "升灵",
		desc = function (lv)
				return "回复己方随机2名英雄"..(lv*300).."点生命，聚气1回合" 			
			end,
		type = SkillManager_TYPE_MANUAL,
		cd = 1,
		isMana = false,
		target = SkillManager_OWN_RANDOM_2,
		ignoreIMRE = false,
		--bgAction = 0,
		bannerType = true,
		injureAction = 0,
		--missileAction= -4,
		effectAction = 19,
		damageRatio = 1,
		regeFunc = function(lv,att_all) 
				return lv*300
			end,
	}
SkillManager[0523] =
	{
		name = "回天",
		desc = function (lv)
				return "回复己方全体英雄"..(lv*100).."点生命，聚气3回合" 				
			end,
		type = SkillManager_TYPE_MANUAL,
		cd = 3,
		isMana = false,
		target = SkillManager_OWN_ALL,
		ignoreIMRE = false,
		--bgAction = 0,
		bannerType = true,
		injureAction = 0,
		--missileAction= -4,
		effectAction = 19,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers)
				return  lv*100
			end,
	}
	--------------------------------------------------------------------------普通数据------------------------------------------
SkillManager[600] =
	{
		name = "疾风刺", --
		desc = function (lv)
				return "对单个敌人造成100%物理伤害，第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = false, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 1,
		runType = 1, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[601] =
	{ 
		name = "冲刺杀", --
		desc = function (lv) 
				return "对前排单个敌人造成90%物理伤害，第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = false, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 0.9,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 1, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[602] =
	{
		name = "太阴拳",--
		desc = function (lv)
				return "对随机1个敌人造成110%的物理伤害，第1回合释放，冷却时间1回合"	
			end,	
		type = SkillManager_TYPE_ACTIVE_ROUND + 1,
		start = 1,
		isMana = false,
		target = SkillManager_MULTI_RANDOM_1,
		needRun = false,
		--bannerType = true,
		ignoreIMRE = false,
		attackAction = 1,
		injureAction = 0,
		--prepareAction= 0,
		missileAction= 1,
		effectAction = 0,
		damageRatio = 1.1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[603] =
	{
		name = "风啸斩", --
		desc = function (lv)
				return "对单个敌人造成250%物理伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 2.5,
		runType = 1, 
		bannerType = false, 
		--shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[604] =
	{ 
		name = "电闪长空", --
		desc = function (lv) 
				return "对前排单个敌人造成230%物理伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 2.3,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 11, 
		effectAction = 10, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[605] =
	{
		name = "魂飞魄散",--
		desc = function (lv)
				return "对随机1个敌人造成240%的物理伤害，第2回合释放，冷却时间1回合"	
			end,	
		type = SkillManager_TYPE_ACTIVE_ROUND + 1,
		start = 2,
		isMana = false,
		target = SkillManager_SINGLE_FRONT,
		needRun = false,
		bannerType = false,
		ignoreIMRE = false,
		attackAction = 0,
		injureAction = 0,
		--prepareAction= 0,
		--missileAction= 1,
		effectAction = 12,
		damageRatio = 2.4,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[606] =
	{
		name = "横扫千军", --
		desc = function (lv)
				return "对前排敌人造成140%物理伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 1.4,
		runType = 1, 
		bannerType = false,
		--shout = true, 
		--shakable = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,dstHP,myDeath,enemyDeath,probability,buffers) 
				return att_all
			end,
	}
SkillManager[607] =
	{
		name = "冲破云霄", --银老
		desc = function (lv)
				return "对后排敌人造成125%物理伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 1.25,
		runType = 0, 
		bannerType = false,
		--shout = true, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 6, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,dstHP,myDeath,enemyDeath,probability,buffers) 
				return att_all
			end,
	}
SkillManager[608] =
	{
		name = "亡命七杀", --银老
		desc = function (lv)
				return "对随机2个敌人造成160%物理伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_2, 
		damageRatio = 1.6,
		runType = 0, 
		bannerType = false,
		--shout = true, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 12, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,dstHP,myDeath,enemyDeath,probability,buffers) 
				return att_all
			end,
	}
SkillManager[609] =
	{
		name = "力透千钧", --银老
		desc = function (lv)
				return "对纵列敌人造成160%物理伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 1.6,
		runType = 0, 
		bannerType = false,
		--shout = true, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 2, 
		injureAction = 1, 
		--missileAction= 1, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,dstHP,myDeath,enemyDeath,probability,buffers) 
				return att_all
			end,
	}
SkillManager[610] =
	{
		name = "地动山摇", --银老
		desc = function (lv)
				return "对所有敌人造成70%物理伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 0.7,
		runType = 0, 
		bannerType = false,
		--shout = true, 
		prepareActionF= 1, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 1, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,dstHP,myDeath,enemyDeath,probability,buffers) 
				return att_all
			end,
	}
SkillManager[611] =
	{
		name = "无痕之刃", --
		desc = function (lv)
				return "对随机1个敌人造成200%物理伤害，第3回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 3, 
		isMana = false, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 2,
		runType = 1, 
		bannerType = false, 
		shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 8, 
		effectAction = 7, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[612] =
	{
		name = "剑走偏锋", --
		desc = function (lv)
				return "对前排单个敌人造成180%物理伤害，第3回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 3, 
		isMana = false, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 1.8,
		runType = 1, 
		bannerType = false,
		shout = true, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 1, 
		effectAction = 12, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
	
SkillManager[613] =
	{
		name = "剑走偏锋", --
		desc = function (lv)
				return "对血量最少的敌人造成200%物理伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_SINGLE_WEAK, 
		damageRatio = 2,
		runType = 0, 
		bannerType = false,
		shout = true, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 1, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[614] =
	{
		name = "厄难毒体",--小医仙神秘山洞
		desc = function (lv)
				return "死亡时释放，对所有敌人造成200%法术伤害，100%概率产生伤害值200%的中毒效果（持续2回合）" 			
			end,		
		type = SkillManager_TYPE_ACTIVE_EXIT, --属性含义参照SkillManager_TYPE_ACTIVE_ROUND
		--start属性无效
		isMana = true,
		target = SkillManager_MULTI_ALL,
		runType = 0,
		bannerType = true,
		shout = true,
		shakable = true,
		ignoreIMRE = false,
		attackAction = 3,
		injureAction = 0,
		--prepareActionF= 0,
		missileAction= 8, 
		effectAction = 7,
		damageRatio = 2,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferPoison(30,2,damage,2) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,	
	}
SkillManager[700] =
	{
		name = "风切电", --
		desc = function (lv)
				return "对单个敌人造成100%法术伤害，第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = false, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[701] =
	{ 
		name = "雷音咒", --
		desc = function (lv) 
				return "对前排单个敌人造成90%法术伤害，第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = false, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 0.9,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 11, 
		effectAction = 10, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[702] =
	{
		name = "旋灵之力",--
		desc = function (lv)
				return "对随机1个敌人造成110%的法术伤害，第1回合释放，冷却时间1回合"	
			end,	
		type = SkillManager_TYPE_ACTIVE_ROUND + 1,
		start = 1,
		isMana = false,
		target = SkillManager_SINGLE_FRONT,
		needRun = false,
		--bannerType = true,
		ignoreIMRE = false,
		attackAction = 1,
		injureAction = 0,
		--prepareAction= 0,
		missileAction= 1,
		effectAction = 0,
		damageRatio = 1.1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[703] =
	{
		name = "神鬼一笑", --
		desc = function (lv)
				return "对单个敌人造成250%法术伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 2.5,
		runType = 1, 
		bannerType = false, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 4, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[704] =
	{ 
		name = "鹰击长空", --
		desc = function (lv) 
				return "对后排单个敌人造成220%法术伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 2.2,
		runType = 0, 
		bannerType = false, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 1, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[705] =
	{
		name = "五行伏魔",--
		desc = function (lv)
				return "对随机1个敌人造成240%的法术伤害，第2回合释放，冷却时间1回合"	
			end,	
		type = SkillManager_TYPE_ACTIVE_ROUND + 1,
		start = 2,
		isMana = false,
		target = SkillManager_MULTI_RANDOM_1,
		needRun = false,
		bannerType = false,
		ignoreIMRE = false,
		attackAction = 1,
		injureAction = 0,
		--prepareAction= 0,
		missileAction= 10,
		effectAction = 0,
		damageRatio = 2.4,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[706] =
	{
		name = "天煞孤星", --
		desc = function (lv)
				return "对前排敌人造成140%法术伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 1.4,
		runType = 0, 
		bannerType = false,
		--shout = true, 
		prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 1, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,dstHP,myDeath,enemyDeath,probability,buffers) 
				return att_all
			end,
	}
SkillManager[707] =
	{
		name = "亡灵暗影", --
		desc = function (lv)
				return "对前排敌人造成125%法术伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 1.25,
		runType = 0, 
		bannerType = false,
		--shout = true, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 4, 
		effectAction = 10, 
		attackFunc = function(lv,att_all,isMana,srcHP,dstHP,myDeath,enemyDeath,probability,buffers) 
				return att_all
			end,
	}
SkillManager[708] =
	{
		name = "凰妖展翅", --
		desc = function (lv)
				return "对随机2个敌人造成160%法术伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_2, 
		damageRatio = 1.6,
		runType = 0, 
		bannerType = false,
		--shout = true, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 1, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,dstHP,myDeath,enemyDeath,probability,buffers) 
				return att_all
			end,
	}
SkillManager[709] =
	{
		name = "长虹贯日", --银老
		desc = function (lv)
				return "对纵列敌人造成160%法术伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 1.6,
		runType = 0, 
		bannerType = false,
		--shout = true, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 2, 
		injureAction = 1, 
		--missileAction= 1, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,dstHP,myDeath,enemyDeath,probability,buffers) 
				return att_all
			end,
	}

SkillManager[710] =
	{
		name = "杀神附体", --银老
		desc = function (lv)
				return "对所有敌人造成70%法术伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 0.7,
		runType = 0, 
		bannerType = false,
		--shout = true, 
		--shakable = 
		prepareActionF= 2, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 1, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,dstHP,myDeath,enemyDeath,probability,buffers) 
				return att_all
			end,
	}
SkillManager[711] =
	{
		name = "血魔之怒", --
		desc = function (lv)
				return "对随机1个敌人造成200%法术伤害，第3回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 3, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 2,
		runType = 1, 
		bannerType = false,
		shout = true,
		shakable = true, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 12, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[712] =
	{
		name = "古神震怒", --
		desc = function (lv)
				return "对血量最少的敌人造成180%法术伤害，第3回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 3,
		isMana = true, 
		target = SkillManager_SINGLE_0, 
		damageRatio = 1.8,
		runType = 1, 
		--bannerType = true,
		prepareActionF= 4, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 3, 
		--missileAction= 1, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}

	SkillManager[0720] =
	{
		
		name = "清风薪荣", -- 护法
		desc = function (lv)
				return "治疗己方全体英雄（30%），第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_OWN_ALL, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false,
		--shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 
		regeFunc = function(lv,att_all) 
				return att_all*0.3
			end,
	}

	SkillManager[721] =
	{
		name = "回春", --
		desc = function (lv)
				return "治疗己方血量最少的英雄（80%），第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = true, 
		target = SkillManager_OWN_0, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 
		regeFunc = function(lv,att_all) 
				return att_all*0.8
			end,
	}


SkillManager[800] = 
	{
		name = "土灵护体",--
		desc = function (lv)
				return "为自身增加护盾（减少30%攻击伤害，抵挡1次攻击），第1回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 1, 
		isMana = false, 
		target = SkillManager_OWN_SELF, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = false, 
		--prepareActionF= 4, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferReduction(4,1,0.3,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[801] = --skillmanager[0170] to [0174]
	{
		name = "幻魂大法",--
		desc = function (lv)
				return "死亡时触发，对敌方前排造成70%法术伤害" 			
			end,	
		type = SkillManager_TYPE_ACTIVE_EXIT, --属性含义参照SkillManager_TYPE_ACTIVE_ROUND
		--start属性无效
		isMana = false,
		target = SkillManager_MULTI_ROW_1,
		needRun = false,
		bannerType = false,
		shakable = true,
		ignoreIMRE = false,
		attackAction = 3,
		injureAction = 0,
		prepareAction= 4,
		missileAction= 8, 
		effectAction = 7,
		damageRatio = 0.7,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}

SkillManager[802] = 
	{
		name = "复仇之怒",
		desc = function (lv)
				return "受到攻击伤害时，30%概率进行反击，造成90%物理攻击伤害" 			
			end,
		type = SkillManager_TYPE_ACTIVE_COUNTER,--属性含义参照SkillManager_TYPE_ACTIVE_ROUND
		--start属性无效
		isMana = false,
		target = SkillManager_SINGLE_COUNTER,
		counterProbability = 0.3,--反击概率
		damageRatio = 0.9,
		attackAction = 0,
		injureAction = 0,
		--prepareActionF= 0,
		--missileAction= 0,
		bannerType = false,
		shout = true,
		effectAction = 0,
		runType = 0,
		ignoreIMRE = false,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers)
				return att_all
			end,
	}
SkillManager[803] =
	{
		name = "聚气凝神",--"
		desc = function (lv)
				return "发动物理攻击时，有30%概率额外增加20%基础攻击力" 			
			end,
		type = SkillManager_TYPE_PASSIVE_PROB,
		addFunc = function(lv,isMana,att,probability) --必须，lv：技能等级；isMana：主动技能是否法术；att：角色的基础攻击；probability：[0,1)随机数
				local thisIsMana = false  --true:法术增幅;false:物理增幅
				local thisProbability = 0.3 --[0,1]攻击增幅概率，数值越大，概率越高
				local thisPercent = 0.2     --[0,1]攻击增幅百分比
				local thisNumber = 0      --[0,+)攻击增幅自然数
				return (isMana == thisIsMana and thisProbability > probability ) and att * thisPercent + thisNumber or 0
			end,
	}
SkillManager[804] =
	{
		name = "凝魂猛攻",--"
		desc = function (lv)
				return "发动法术攻击时，有30%概率额外增加20%基础攻击力" 			
			end,
		type = SkillManager_TYPE_PASSIVE_PROB,
		addFunc = function(lv,isMana,att,probability) --必须，lv：技能等级；isMana：主动技能是否法术；att：角色的基础攻击；probability：[0,1)随机数
				local thisIsMana = true  --true:法术增幅;false:物理增幅
				local thisProbability = 0.3 --[0,1]攻击增幅概率，数值越大，概率越高
				local thisPercent = 0.2     --[0,1]攻击增幅百分比
				local thisNumber = 0      --[0,+)攻击增幅自然数
				return (isMana == thisIsMana and thisProbability > probability ) and att * thisPercent + thisNumber or 0
			end,
	}
SkillManager[805] =
	{
		name = "蚀血碎骨",--
		desc = function (lv)
				return "攻击目标血量高于自身时，增加20%攻击力" 			
			end,
		type = SkillManager_TYPE_PASSIVE_HPHP,
		addFunc = function(lv,att,srcHP,dstHP) --必须，lv：技能等级；att：角色的基础攻击；srcHP、dstHP：攻击方、被攻击方HP
				local thisPercent = 0.2 --[0,1]攻击增幅百分比
				local thisNumber = 0  --[0,+)攻击增幅自然数
				--     dstHP > srcHP  --更改判断符号
				return dstHP > srcHP and att * thisPercent + thisNumber or 0
			end,
	}
SkillManager[806] = 
	{
		name = "火灵护体",--
		desc = function (lv)
				return "为自身增加护盾（减少60%攻击伤害，抵挡2次攻击），第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = false, 
		target = SkillManager_OWN_SELF, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = false, 
		--prepareActionF= 4, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferReduction(4,2,0.6,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[900] =
	{
		name = "回春", --
		desc = function (lv)
				return "治疗己方血量最少的英雄（260%），第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = true, 
		target = SkillManager_OWN_0, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 
		regeFunc = function(lv,att_all) 
				return att_all*2.6
			end,
	}
SkillManager[901] =
	{
		name = "浴火重生", --
		desc = function (lv)
				return "治疗己方全体英雄（100%），第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_OWN_ALL, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false,
		--shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 
		regeFunc = function(lv,att_all) 
				return att_all
			end,
	}
SkillManager[902] =
	{
		name = "鸾凤回巢", -- 慕青鸾
		desc = function (lv)
				return "治疗己方血量最少的英雄（300%），同时解除一切负面状态，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_OWN_0, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 
		regeFunc = function(lv,att_all) 
				return att_all*3
			end,

		clearFunc = function(lv) 
				return {BUFFER_TYPE_POISON,BUFFER_TYPE_FREEZE,BUFFER_TYPE_STUN,BUFFER_TYPE_SEAL,BUFFER_TYPE_BURN,BUFFER_TYPE_DECREASE,BUFFER_TYPE_CURELESS}
			end,
	}

	
	--------------------------------------录像技能数据
SkillManager[1000] =
	{
		name = "萧炎1-1",
		desc = function (lv)
				return "第一招" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 5, 
		start = 1, 
		isMana = false, 
		target = SkillManager_SINGLE_BACK, 
		damageRatio = 0.3,
		runType = 0, 
		--bannerType = true,
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--prepareActionF = 0, 
		--prepareActionB = 0, 
		--missileAction= 0, 
		effectAction = 1, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[1001] =
	{
		name = "萧炎1-2",
		desc = function (lv)
				return "风车" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 1.2,
		runType = 1, 
		bannerType = true,
		ignoreIMRE = false, 
		attackAction = 4, 
		injureAction = 3, 
		--prepareActionF = 0, 
		--prepareActionB = 0, 
		--missileAction= 0, 
		effectAction = 20, 		
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[1002] =
	{
		name = "萧炎1-3",
		desc = function (lv)
				return "xxx" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 3, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 1.5,
		runType = 4, 
		--bannerType = true,
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		prepareActionF = 7, 
		prepareActionB = 8, 
		missileAction= -11, 
		effectAction = 20, 	
		bgAction = 1,
		shakable = true,	
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[1004] =	--云岚宗长老录像技能
	{
		name = "闪电1-1",
		desc = function (lv)
				return "连锁闪电" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_2, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		ignoreIMRE = false, 
		injureAction = 0, 
		attackAction = 1, 
		--injureAction = 0, 
		missileAction= 14, 
		effectAction = 21,		
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[1003] =
	{
		name = "海波东1-2",
		desc = function (lv)
				return "加攻击" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 4, 
		start = 1, 
		isMana = false, 
		target = SkillManager_OWN_ALL, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--prepareActionF = 0, 
		--prepareActionB = 0, 
		--missileAction= 0, 
		effectAction = 20, 		
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferIncrease(0,2,0.2,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[1005] =
	{
		name = "海波东1-3",
		desc = function (lv)
				return "纵列" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 1,
		runType = 1, 
		--bannerType = true,
		ignoreIMRE = false, 
		attackAction = 2, 
		injureAction = 1, 
		--prepareActionF = 0, 
		--prepareActionB = 0,  
		--missileAction= 0, 
		effectAction = 0, 		
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[1006] =
	{
		name = "凌影1-1",
		desc = function (lv)
				return "前排" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 1,
		runType = 1, 
		--bannerType = true,
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		prepareActionF = 2, 
		--prepareActionB = 0, 
		--missileAction= 0, 
		effectAction = 12, 		
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[1007] =
	{
		name = "凌影1-2",
		desc = function (lv)
				return "护盾" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 5, 
		start = 1, 
		isMana = false, 
		target = SkillManager_OWN_OTHER, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--prepareActionF = 0, 
		--prepareActionB = 0, 
		--missileAction= 0, 
		effectAction = 20, 		
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferReduction(0,3,0.3,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[1008] =
	{
		name = "凌影1-3",
		desc = function (lv)
				return "xxx" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 3, 
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_2, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--prepareActionF = 0, 
		--prepareActionB = 0, 
		missileAction= 1, 
		effectAction = 12, 		
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[1009] =
	{
		name = "美杜莎1-1",
		desc = function (lv)
				return "xxx" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--prepareActionF = 0, 
		--prepareActionB = 0, 
		--missileAction= 8, 
		effectAction = 0, 		
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[1010] =
	{
		name = "美杜莎1-2",
		desc = function (lv)
				return "xxx" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--prepareActionF = 0, 
		--prepareActionB = 0, 
		--missileAction= 0, 
		effectAction = 8,
		haloAction = 1,		
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[1011] =
	{
		name = "美杜莎1-3",
		desc = function (lv)
				return "xxx" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 3, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_3, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--prepareActionF = 0, 
		--prepareActionB = 0, 
		missileAction= 8, 
		effectAction = 7, 		
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferPoison(0,2,att,0.1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[1012] =
	{
		name = "纳然嫣然1-1",
		desc = function (lv)
				return "回血" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 5, 
		start = 1, 
		isMana = true, 
		target = SkillManager_OWN_OTHER, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		prepareActionF = 4, 
		--prepareActionB = 0, 
		--missileAction= 1, 
		effectAction = 19, 		
		regeFunc = function(lv,att_all) 
				return att_all*0.2
			end,
	}
SkillManager[1013] =
	{
		name = "纳然嫣然1-2",
		desc = function (lv)
				return "前进单体" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 1,
		runType = 1, 
		--bannerType = true,
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		prepareActionF = 0, 
		--prepareActionB = 6, 
		--missileAction= 11, 
		effectAction = 10, 	
		--shakable = true,		
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[1014] =
	{
		name = "纳然嫣然1-3",
		desc = function (lv)
				return "后退群体" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 5, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--prepareActionF = 0, 
		--prepareActionB = 4, 
		missileAction= 8, 
		effectAction = 7, 		
		--haloAction = 2,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferSeal(0,3) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,	
	}
SkillManager[1097] = 
	{
		name = "美杜莎入场技",
		desc = function (lv)
				return "入场技" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ENTER, 
		--start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 5, 
		prepareActionF = 0, 
		--prepareActionB = 6, 
		--missileAction= -10, 
		effectAction = 8, 	
		--shakable = true,	
		haloAction = 1,
		clearFunc = function(lv) 
				return {BUFFER_TYPE_POISON}
			end,
	}
SkillManager[1098] = 
	{
		name = "美杜莎入场技",
		desc = function (lv)
				return "入场技" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ENTER, 
		--start = 1, 
		isMana = false, 
		target = SkillManager_OWN_OTHER, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		prepareActionF = 4, 
		--prepareActionB = 6, 
		--missileAction= -10, 
		effectAction = 19, 	
		--shakable = true,	
		--haloAction = 2,
		clearFunc = function(lv) 
				return {BUFFER_TYPE_SEAL}
			end,
	}
SkillManager[1099] =
	{
		name = "纳然嫣然1-4",
		desc = function (lv)
				return "大招" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 5, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 1,
		runType = 3, 
		bannerType = true,
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		prepareActionF = 5, 
		prepareActionB = 6, 
		missileAction= -10, 
		effectAction = 20, 	
		shakable = true,	
		--haloAction = 2,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[1015] =
	{
		name = "云棱1-1",
		desc = function (lv)
				return "xxx" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = false, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--prepareActionF = 0, 
		--prepareActionB = 0, 
		--missileAction= 0, 
		effectAction = 0, 		
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[1016] =
	{
		name = "云棱1-2",
		desc = function (lv)
				return "xxx" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_SINGLE_0, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--prepareActionF = 0, 
		--prepareActionB = 0, 
		missileAction= 12, 
		effectAction = 0, 		
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[1017] =
	{
		name = "云棱1-3",
		desc = function (lv)
				return "xxx" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 3, 
		isMana = true, 
		target = SkillManager_OWN_OTHER, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--prepareActionF = 0, 
		--prepareActionB = 0, 
		--missileAction= 0, 
		effectAction = 20, 		
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferReduction(0,1,0.1,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[1018] =
	{
		name = "云山1-1",
		desc = function (lv)
				return "xxx" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--prepareActionF = 0, 
		--prepareActionB = 0, 
		missileAction= 1, 
		effectAction = 12, 		
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[1019] =
	{
		name = "云山1-2",
		desc = function (lv)
				return "xxx" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		prepareActionF = -1, 
		--prepareActionB = 0, 
		missileAction= -9, 
		effectAction = 0, 		
		bgAction = -1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return 50000
			end,
	}
SkillManager[1020] =
	{
		name = "普通弟子1-1",
		desc = function (lv)
				return "xxx" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT,
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--prepareActionF = 0, 
		--prepareActionB = 0, 
		--missileAction= 0, 
		effectAction = 0, 		
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[1021] =
	{
		name = "普通弟子1-2",
		desc = function (lv)
				return "xxx" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_COLS,
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--prepareActionF = 0, 
		--prepareActionB = 0, 
		--missileAction= 0, 
		effectAction = 0, 		
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[1022] =
	{
		name = "长老1-1",
		desc = function (lv)
				return "xxx" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT,
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--prepareActionF = 0, 
		--prepareActionB = 0, 
		--missileAction= 0, 
		effectAction = 0, 		
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[1023] =
	{
		name = "长老1-2",
		desc = function (lv)
				return "xxx" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_SINGLE_0,
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--prepareActionF = 0, 
		--prepareActionB = 0, 
		--missileAction= 0, 
		effectAction = 0, 		
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
SkillManager[1024] =
	{
		name = "焰分噬浪", --萧炎天火录像
		desc = function (lv)
				return "对所有敌人造成250%法术伤害，80%概率使敌人虚弱（攻击减少30%，持续2次）" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 1.5,
		runType = 4, 
		bgAction = 1,
		bannerType = true,
		shout = true,
		shakable = true,
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 2, 
		prepareActionF= 7, 
		prepareActionB= 8, 
		missileAction= -11, 
		effectAction = 20, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.8 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferDecrease(3,2,0.3,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[1025] =
	{
		name = "六合游身尺", --萧炎天火录像
		desc = function (lv)
				return "对前排敌人造成120%物理伤害，50%概率增加20%攻击力" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 1.5,
		runType = 1, 
		bannerType = true,
		shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 4, 
		injureAction = 3, 
		--missileAction= 1, 
		effectAction = 20,
		shakable = true, 
		
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				local thisProbability = 0.3
				if thisProbability > probability then
					return att_all*1.2
				else		
					return att_all
				end
			end,
	}

SkillManager[1500] =
	{
		name = "天凰碎指",
		desc = function (lv)
				return "对敌方生命值最低的英雄造成100%法术攻击伤害" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1,
		start = 1,
		isMana = true,
		target = SkillManager_SINGLE_0,
		runType = 0,
		--bannerType = true,
		ignoreIMRE = false,
		attackAction = 1,
		injureAction = 0,
		--prepareActionF= 0,
		missileAction= 8,
		effectAction = 7,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all * 1.2
			end,
	}
SkillManager[1503] =
	{
		name = "天凰碎指2",
		desc = function (lv)
				return "对敌方生命值最低的英雄造成100%法术攻击伤害" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1,
		start = 1,
		isMana = true,
		target = SkillManager_SINGLE_0,
		runType = 0,
		--bannerType = true,
		ignoreIMRE = false,
		attackAction = 1,
		injureAction = 1,
		--prepareActionF= 0,
		missileAction= 4,
		effectAction = 0,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all * 1.2
			end,
	}
SkillManager[1501] =
	{
		name = "金帝焚天",
		desc = function (lv)
				return "全体" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1,
		start = 2,
		isMana = true,
		target = SkillManager_MULTI_ALL,
		runType = 0,
		bannerType = true,
		ignoreIMRE = false,
		attackAction = 0,
		injureAction = 0,
		prepareActionF= 0,
		effectAction = 5, --必须，[0,0]，0-0号打击光效
		haloAction = 2,
		--missileAction= 8,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all * 1.2
			end,
	}
SkillManager[1502] =
	{
		name = "焰分噬浪",
		desc = function (lv)
				return "xxx" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_ALL,
		damageRatio = 1,
		runType = 4, 
		bannerType = true,
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 2, 
		prepareActionF = 7, 
		prepareActionB = 8, 
		missileAction= -11, 
		effectAction = 20, 		
		bgAction = 1,
		shakable = true,
		shout = true,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all*3
			end,
	}
SkillManager[1503] =
	{
		name = "天凰碎指2",
		desc = function (lv)
				return "单体血量最少" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1,
		start = 1,
		isMana = true,
		target = SkillManager_SINGLE_0,
		runType = 0,
		--bannerType = true,
		ignoreIMRE = false,
		attackAction = 1,
		injureAction = 0,
		--prepareActionF= 0,
		missileAction= 1,
		effectAction = 0,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all * 1.2
			end,
	}
SkillManager[1504] =
	{
		name = "前排",--
		desc = function (lv)
				return "对敌方前排"
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0,
		start = 1,
		isMana = true,
		target = SkillManager_MULTI_ROW_1,
		runType = 0,
		ignoreIMRE = false,
		attackAction = 0,
		injureAction = 0, --恢复技能 此参数无效
		prepareActionF= 0,
		--missileAction= 14,
		effectAction = 7,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all * 1
			end,
	}
SkillManager[1505] =
	{
		name = "前排",
		desc = function (lv)
				return "对敌方前排"
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2,
		start = 1,
		isMana = true,
		target = SkillManager_MULTI_ROW_1,
		runType = 0,
		ignoreIMRE = false,
		attackAction = 1,
		injureAction = 0, --恢复技能 此参数无效
		prepareActionF= 1,
		missileAction= 1,
		effectAction = 0,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all * 1
			end,
	}
SkillManager[1506] =
	{
		name = "单体",
		desc = function (lv)
				return "对敌方前排"
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 3,
		start = 1,
		isMana = true,
		target = SkillManager_SINGLE_FRONT,
		runType = 0,
		ignoreIMRE = false,
		attackAction = 0,
		injureAction = 0, --恢复技能 此参数无效
		--prepareActionF= 4,
		--missileAction= 8,
		effectAction = 0,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all * 1
			end,
	}
SkillManager[1507] =
	{
		name = "单体",
		desc = function (lv)
				return "对敌方前排"
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2,
		start = 2,
		isMana = true,
		target = SkillManager_SINGLE_FRONT,
		runType = 1,
		ignoreIMRE = false,
		attackAction = 0,
		injureAction = 0, --恢复技能 此参数无效
		--prepareActionF= 4,
		--missileAction= 8,
		effectAction = 0,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all * 1
			end,
	}
SkillManager[1508] =
	{
		name = "单体",
		desc = function (lv)
				return "对敌方前排"
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2,
		start = 2,
		isMana = true,
		target = SkillManager_SINGLE_FRONT,
		runType = 1,
		ignoreIMRE = false,
		attackAction = 0,
		injureAction = 0, --恢复技能 此参数无效
		--prepareActionF= 4,
		--missileAction= 8,
		effectAction = 0,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all * 1
			end,
	}
SkillManager[1509] =
	{
		name = "后排",
		desc = function (lv)
				return "对敌方前排"
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2,
		start = 1,
		isMana = true,
		target = SkillManager_MULTI_ROW_2,
		runType = 0,
		ignoreIMRE = false,
		attackAction = 0,
		injureAction = 0, --恢复技能 此参数无效
		prepareActionF= 0,
		missileAction= 14,
		effectAction = 21,
		damageRatio = 1,
		bannerType = true,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all * 1
			end,
	}
SkillManager[1510] =
	{
		name = "后排",
		desc = function (lv)
				return "对敌方前排"
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2,
		start = 1,
		isMana = true,
		target = SkillManager_MULTI_ROW_2,
		runType = 0,
		ignoreIMRE = false,
		attackAction = 1,
		injureAction = 0, --恢复技能 此参数无效
		prepareActionF= 1,
		missileAction= 3,
		effectAction = 12,
		bannerType = true,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all * 1
			end,
	}
SkillManager[1511] =
	{
		name = "后排",
		desc = function (lv) 
				return "对敌方前排"
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0,
		start = 1,
		isMana = true,
		target = SkillManager_SINGLE_FRONT,
		runType = 0,
		ignoreIMRE = false,
		attackAction = 0,
		injureAction = 0, --恢复技能 此参数无效
		bannerType = true,
		prepareActionF= 0,
		--missileAction= 10,
		effectAction = 5,
		haloAction = 2,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all * 1
			end,
	}
SkillManager[1512] =
	{
		name = "回血",
		desc = function (lv)
				return "对敌方前排"
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2,
		start = 1,
		isMana = true,
		target = SkillManager_OWN_ALL,
		runType = 0,
		ignoreIMRE = false,
		attackAction = 0,
		injureAction = 0, --恢复技能 此参数无效
		prepareActionF= 3,
		--missileAction= 10,
		bannerType = true,
		effectAction = 19,
		damageRatio = 1,
		regeFunc = function(lv,att_all) 
				return 1000
			end,
	}
SkillManager[1513] =
	{
		name = "全体",
		desc = function (lv)
				return "对敌方前排"
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0,
		start = 1,
		isMana = true,
		target = SkillManager_MULTI_ALL,
		runType = 3,
		ignoreIMRE = false,
		attackAction = 1,
		injureAction = 0, --恢复技能 此参数无效
		prepareActionF= 5,
		prepareAction= 6,	
		--missileAction= 10,
		effectAction = 0,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all * 1
			end,
	}
SkillManager[1514] =
	{
		name = "焰分噬浪",
		desc = function (lv)
				return "对敌方前排"
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2,
		start = 3,
		isMana = true,
		target = SkillManager_MULTI_ALL,
		runType = 4,
		ignoreIMRE = false,
		attackAction = 1,
		injureAction = 2, --恢复技能 此参数无效
		prepareActionF= 7,
		prepareActionB= 8,
		bgAction = 1,
		missileAction= -11,
		effectAction = 20,
		shakable = true,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all * 5
			end,
	}
	

SkillManager[1515] =
	{
		name = "纵列",
		desc = function (lv)
				return "对敌方前排"
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 3,
		start = 1,
		isMana = true,
		target = SkillManager_MULTI_COLS,
		runType = 1,
		ignoreIMRE = false,
		attackAction = 1,
		injureAction = 0, --恢复技能 此参数无效
		prepareActionF= 4,
		missileAction= 4,
		effectAction = 10,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all * 1
			end,
	}
SkillManager[1516] =
	{
		name = "填充1",
		desc = function (lv)
				return "对敌方前排"
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 3,
		start = 2,
		isMana = true,
		target = SkillManager_MULTI_COLS,
		runType = 1,
		ignoreIMRE = false,
		attackAction = 2,
		injureAction = 0, --恢复技能 此参数无效
		--prepareActionF= 2,
		--missileAction= -5,
		effectAction = 0,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all * 1
			end,
	}
SkillManager[1517] =
	{
		name = "填充2",
		desc = function (lv)
				return "对敌方前排"
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 3,
		start = 3,
		isMana = true,
		target = SkillManager_MULTI_COLS,
		runType = 1,
		ignoreIMRE = false,
		attackAction = 2,
		injureAction = 0, --恢复技能 此参数无效
		--prepareActionF= 2,
		--missileAction= -5,
		effectAction = 0,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all * 1
			end,
	}
SkillManager[1518] =
	{
		name = "小怪通用技能",
		desc = function (lv)
				return "对敌方前排单体"
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1,
		start = 2,
		isMana = true,
		target = SkillManager_SINGLE_FRONT,
		runType = 1,
		ignoreIMRE = false,
		attackAction = 0,
		injureAction = 0, --恢复技能 此参数无效
		--prepareActionF= 2,
		--missileAction= -5,
		effectAction = 0,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all * 1
			end,
	}
SkillManager[1519] =
	{
		name = "3回合天冲技能",
		desc = function (lv)
				return "对敌方前排单体"
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0,
		start = 3,
		isMana = true,
		target = SkillManager_SINGLE_FRONT,
		runType = 1,
		ignoreIMRE = false,
		attackAction = 0,
		injureAction = 0, --恢复技能 此参数无效
		--prepareActionF= 2,
		--missileAction= -5,
		effectAction = 0,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all * 1
			end,
	}
----------------------------------------------new skill---------------------------------------------

SkillManager[1200] =
	{
		name = "地动山摇", --萧战
		desc = function (lv)
				return "对所有敌人造成85%物理伤害，第2回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 0.85,
		runType = 0, 
		bannerType = false,
		shout = true, 
		shakable = true,
		prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 1, 
		effectAction = 12, 
		attackFunc = function(lv,att_all,isMana,srcHP,dstHP,myDeath,enemyDeath,probability,buffers) 
				return att_all
			end,
	}
SkillManager[1201] =
	{
		name = "亡魂地刺", --萧鼎
		desc = function (lv)
				return "对后排敌人造成125%物理伤害，第2回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 1.25,
		runType = 0, 
		bannerType = false,
		--bannerType = true,
		shout = true,
		shakable = true,
		prepareActionF= 3, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 5, 
		--missileAction= 0, 
		effectAction = 8, 
		haloAction = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,dstHP,myDeath,enemyDeath,probability,buffers) 
				return att_all
			end,
	}
SkillManager[1202] =
	{
		name = "奔雷印", --萧厉
		desc = function (lv)
				return "对所有敌人造成85%物理伤害，第2回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 0.85,
		runType = 0, 
		bannerType = false,
		shout = true, 
		shakable = true,
		--runType = 0, 
		--bgAction = 1,
		prepareActionF = 0,
		prepareActionB = 4, 
		ignoreIMRE = true, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= -8, 
		effectAction = 0, 
		shakable = true,
		attackFunc = function(lv,att_all,isMana,srcHP,dstHP,myDeath,enemyDeath,probability,buffers) 
				return att_all
			end,
	}
	
SkillManager[1203] = 
	{
		name = "天赐蛇甲",--鬼武者
		desc = function (lv)
				return "为自身增加护盾（减少99%攻击伤害，抵挡6次攻击），第1回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 1, 
		isMana = false, 
		target = SkillManager_OWN_SELF, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false,
		--shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferReduction(10,6,0.99,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,

	}
SkillManager[1204] =
	{
		name = "灭魂斩", --鬼武者
		desc = function (lv)
				return "对前排敌人造成60%物理伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 0.8,
		runType = 0, 
		bannerType = false,
		shout = true, 
		shakable = true,
		runType = 1, 
		--bgAction = 1,
		prepareActionF = 0,
		prepareActionB = 4, 
		ignoreIMRE = true, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= -8, 
		effectAction = 12, 
		shakable = true,
		attackFunc = function(lv,att_all,isMana,srcHP,dstHP,myDeath,enemyDeath,probability,buffers) 
				return att_all
			end,
	}
SkillManager[1205] =
	{
		name = "鬼影斩", --鬼武者
		desc = function (lv)
				return "对前排敌人造成120%物理伤害，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 1.5,
		runType = 0, 
		bannerType = false,
		shout = true, 
		shakable = true,
		runType = 3, 
		ignoreIMRE = true, 
		--bgAction = 1,
		prepareActionF = 0,
		prepareActionB = 4, 
		attackAction = 4, 
		injureAction = 3, 
		missileAction= 14, 
		effectAction = 21, 
		shakable = true,
		attackFunc = function(lv,att_all,isMana,srcHP,dstHP,myDeath,enemyDeath,probability,buffers) 
				return att_all
			end,
	}
SkillManager[1600] =
	{
		name = "风灵分形剑", --魂风
		desc = function (lv)
				return "对单个敌人造成100%法术伤害，100%概率使对方虚弱（减少50%攻击力，持续2次），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 14, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,

		setupBuffer = function(lv,att,damage,probability)
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferDecrease(5,2,0.5,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
			
	}
SkillManager[1601] =
	{
		name = "裂风虎啸掌", --魂风
		desc = function (lv)
				return "对敌方全体造成150%法术攻击伤害，100%概率使敌方无法被治疗（持续5次），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 1.5,
		runType = 0, 
		bannerType = true,
		shout = true,
		shakable = true,
		prepareActionF= 2, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 13, 
		effectAction = 21, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,

		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferCureless(5,5) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[1602] = 
	{
		name = "黑极崩劲",--魂风
		desc = function (lv)
				return "受到攻击时有必定进行反击，造成250%法术伤害,无视免疫和伤害减免效果，必定使对方虚弱（减少30%攻击力，持续1次）" 			
			end,
		type = SkillManager_TYPE_ACTIVE_COUNTER,--属性含义参照SkillManager_TYPE_ACTIVE_ROUND
		--start属性无效
		isMana = true,
		target = SkillManager_SINGLE_COUNTER,
		counterProbability = 1, --反击概率
		ignoreIMRE = true,
		attackAction = 0,
		injureAction = 0,
		effectAction = 0,
		--prepareActionF= 0,
		missileAction= 14,
		bannerType = false,
		runType = 0,
		damageRatio = 2.5,

		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,

		setupBuffer = function(lv,att,damage,probability)
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferDecrease(3,1,0.3,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
			
	}


SkillManager[1603] =
	{
		name = "断魂灭魄", --魂崖
		desc = function (lv)
				return "对血量最多敌人造成220%物理伤害，90%概率产生伤害值80%的中毒效果（持续2回合）,第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = false, 
		target = SkillManager_SINGLE_100, 
		damageRatio = 2.2,
		runType = 0, 
		bannerType = false,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 1, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,

		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.9 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferPoison(8,2,damage,0.8) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}

	SkillManager[1604] =
	{
		name = "裂风虎啸", --魂崖
		desc = function (lv)
				return "对敌方随机3名英雄造成150%物理伤害，60%概率产生伤害值40%的中毒效果（持续2回合）,第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_3, 
		damageRatio = 1.5,
		runType = 0, 
		bannerType = true, 
		shout = true,
		shakable = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 1, 
		effectAction = 4, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,

		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.6 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferPoison(2,2,damage,0.4) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}

SkillManager[1605] =
	{
		name = "骨皇裂天", --魂崖
		desc = function (lv)
				return "受到攻击时有100%概率进行反击，对敌人全体造成50%物理攻击伤害，若目标已中毒，额外造成100%物理伤害" 			
			end,
		type = SkillManager_TYPE_ACTIVE_COUNTER,--属性含义参照SkillManager_TYPE_ACTIVE_ROUND
		--start属性无效
		isMana = false,
		target = SkillManager_MULTI_ALL,
		counterProbability = 1, --反击概率
		ignoreIMRE = true,
		attackAction = 0,
		injureAction = 0,
		effectAction = 0,
		--prepareActionF= 0,
		missileAction= 1,
		bannerType = false,
		runType = 0,
		damageRatio = 0.5,

		

		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				local thisBuffers ={BUFFER_TYPE_POISON}
				for i = 1,#enemyBuffers do
					for j = 1,#thisBuffers do
						if enemyBuffers[i] == thisBuffers[j] then
					    return att_all*3
						end
					end
				end
				return att_all
			end,
	}

	SkillManager[1606] =
	{
		name = "碎魂冥掌", --魂厉
		desc = function (lv)
				return "对前排敌人造成120%法术攻击伤害，50%概率击晕目标（持续2回合），第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 1.2,
		runType = 0, 
		bannerType = true,
		shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 4, 
		effectAction = 10, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,

		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.5--[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferStun(1,2) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}

	SkillManager[1607] =
	{
		name = "血神裂天", --魂厉
		desc = function (lv)
				return "对前排敌人造成80%法术伤害，若目标被击晕额外增加100%法术伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 4, 
		effectAction = 10, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				local thisBuffers ={BUFFER_TYPE_STUN}
				for i = 1,#enemyBuffers do
					for j = 1,#thisBuffers do
						if enemyBuffers[i] == thisBuffers[j] then
					    return att_all*1.8
						end
					end
				end
				return att_all*0.8
			end,
	}

	SkillManager[1608] =
	{
		name = "天妖血蛊", --魂厉
		desc = function (lv)
				return "死亡时触发，击晕任意两个敌方目标（持续1回合）" 			
			end,
		type = SkillManager_TYPE_ACTIVE_EXIT, --属性含义参照SkillManager_TYPE_ACTIVE_ROUND
		--start属性无效
		isMana = true,
		target = SkillManager_MULTI_RANDOM_2,
		needRun = false,
		bannerType = true,
		shout = true,
		shakable = true,
		ignoreIMRE = false,
		attackAction = 2,
		injureAction = 0,
		--prepareAction= 0,
		--missileAction= -4, 
		effectAction = 3,
		damageRatio = 1,
		
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferStun(0,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[1609] =
	{
		name = "灭魂掌", --魂玉
		desc = function (lv)
				return "己方全体增加20%基础攻击力（持续2次），第1回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 1, 
		isMana = true,
		target = SkillManager_OWN_ALL, 
		damageRatio = 1,
		runType = 0, 
		bannerType = true,
		shout = true, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 3, 
		
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferIncrease(2,2,0.2,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,			
	}

	SkillManager[1610] =
	{
		name = "离魂符", --魂玉
		desc = function (lv)
				return "治疗己方血量最少的英雄（300%），同时解除除定身效果外一切负面状态，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_OWN_0, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 
		regeFunc = function(lv,att_all) 
				return att_all*3
			end,

		clearFunc = function(lv) 
				return {BUFFER_TYPE_POISON,BUFFER_TYPE_BURN,BUFFER_TYPE_DECREASE,BUFFER_TYPE_CURELESS}
			end,
	}

	SkillManager[1611] = 
	{
		name = "妖蛊蚀体",--魂玉
		desc = function (lv)
				return "替补入场时释放，回复己方全体英雄血量（200%），同时解除除去定身效果之外所有的负面状态" 			
			end,	
		type = SkillManager_TYPE_ACTIVE_ENTER,   --[0100,0200)--主动，上场, --属性含义参照SkillManager_TYPE_ACTIVE_ROUND
		--start属性无效
		isMana = true,
		target = SkillManager_OWN_ALL,
		runType = 0,
		bannerType = true,
		shout = true,
		ignoreIMRE = false,
		attackAction = 3,
		injureAction = 0,
		--prepareActionF= 0,
		--missileAction= 0, 
		effectAction = 19,
		damageRatio = 1,
		regeFunc = function(lv,att_all) 
				return att_all*2
			end,
		clearFunc = function(lv) 
				return {BUFFER_TYPE_POISON,BUFFER_TYPE_BURN,BUFFER_TYPE_DECREASE,BUFFER_TYPE_CURELESS}
			end,
	}

		SkillManager[1612] =
	{
		name = "魂手印", --曹颖
		desc = function (lv)
				return "对纵列敌人造成220%法术伤害，100%概率产生伤害50%的灼烧效果（持续2次），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target =SkillManager_MULTI_COLS, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 1, 
		effectAction = 0, 

		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all*2.2
			end,

			setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(5,2,damage,0.5) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}

		SkillManager[1613] =
	{
		name = "灵魂烙印", --曹颖
		desc = function (lv)
				return "攻击任何处于灼烧状态下的目标，目标额外受到50%法术伤害" 			
			end,
		type = SkillManager_TYPE_PASSIVE_BUFF,
		addFunc = function(lv,att,enemyBuffers) --必须，lv：技能等级；att：角色的基础攻击；enemyBuffers：被动方身上的bufferIDs表
				local thisBuffers = {BUFFER_TYPE_BURN} --攻击增幅触发的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua）
				local thisPercent = 0.5  --[0,1]攻击增幅百分比
				local thisNumber = 0   --[0,+)攻击增幅自然数
				for i = 1,#enemyBuffers do
					for j = 1,#thisBuffers do
						if enemyBuffers[i] == thisBuffers[j] then
							return att * thisPercent + thisNumber
						end
					end
				end
				return 0
			end,
	}
SkillManager[1614] =
	{
		name = "丹火燎原", --曹颖
		desc = function (lv)
				return "死亡时释放，对所有敌人造成200%法术伤害，90%概率产生伤害100%的灼烧效果（持续1回合）" 			
			end,
		type = SkillManager_TYPE_ACTIVE_EXIT, 
		isMana = true, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 2,
		runType = 0, 
		bannerType = true, 
		shout = true,
		shakable = true,
		prepareActionF= 2, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 1, 
		effectAction = 12, 

		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.9 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(10,1,damage,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,	
	}

	SkillManager[1615] =
	{
	
				name = "追魂噬骨",--魂灭生
		desc = function (lv)
				return "发动攻击时，攻击目标附有不能被治疗状态时，增加150%攻击力" 			
			end,
		type = SkillManager_TYPE_PASSIVE_BUFF,
		addFunc = function(lv,att,enemyBuffers) --必须，lv：技能等级；att：角色的基础攻击；enemyBuffers：被动方身上的bufferIDs表
				local thisBuffers = {BUFFER_TYPE_CURELESS} --攻击增幅触发的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua）
				local thisPercent = 1.5  --[0,1]攻击增幅百分比
				local thisNumber = 0   --[0,+)攻击增幅自然数
				for i = 1,#enemyBuffers do
					for j = 1,#thisBuffers do
						if enemyBuffers[i] == thisBuffers[j] then
							return att * thisPercent + thisNumber
						end
					end
				end
				return 0
			end,
	}

		SkillManager[1616] =
	{
		name = "魂生魂灭",--魂灭生
		desc = function (lv)
				return "50%概率免疫任意攻击伤害" 			
			end,	
		type = SkillManager_TYPE_PASSIVE_IMAT,
		immunityAttackFunc = function(lv,isMana,probability) --必须，lv：技能等级；isMana：主动技能是否法术；probability：[0,1)随机数
				  --true:法术免疫；false:物理免疫
				 --[0,1]免疫概率，数值越大，概率越高
				if isMana then
					return  0.5 > probability
				else
					return  0.5 > probability
				end
				--print("jjjjjjjjjjjjjjjjjjjjjjjjjjjjj")
				
			end,
	}

	SkillManager[1617] =
		{
		name = "魂灭斩",--魂灭生
		desc = function (lv)
				return "对后排敌人造成50%物理伤害，80%概率使敌方晕眩（持续1回合），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 0.5,
		runType = 4, 
		
		bannerType = true,
		shout = true,
		shakable = true,
		ignoreIMRE = false, 

		--prepareActionF= 3, 
		--ignoreIMRE = false, 
		--attackAction = 1, 
		--injureAction = 5, 
		--effectAction = 8, 
		--haloAction = 1,

		prepareActionF= -1,
		bgAction = -1,
		blood = true,
		attackAction = 1, 
		injureAction = 2, 
		missileAction= -13, 
		effectAction = 20, 


		
		
		attackFunc = function(lv,att_all,isMana,srcHP,dstHP,myDeath,enemyDeath,probability,buffers) 
				return att_all
			end,
			setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.8 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferStun(0,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}

SkillManager[1618] =
	{
		name = "六合游身尺", --新萧炎
		desc = function (lv)
				return "对前排敌人造成180%物理伤害，无视伤害减免效果，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 1.8,
		runType = 1, 
		bannerType = false,
		--shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = true, 
		attackAction = 4, 
		injureAction = 3, 
		--missileAction= 1, 
		effectAction = 20,
		shakable = true, 
		
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				
					return att_all		
			end,
	}


SkillManager[1619] =
	{
		name = "苍穹雷动", --新萧炎
		desc = function (lv)
				return "对随机3个敌人造成240%物理伤害，90%概率产生攻击伤害值150%的灼烧效果（持续2回合），第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_3, 
		damageRatio = 2.4,
		runType = 3, 
		bannerType = true, 
		shout = true,

		prepareActionF= -1,
		bgAction = -1,
		attackAction = 1, 
		injureAction = 0, 
		prepareActionF= -1,
		bgAction = -1,
		missileAction= -5, --可选，[-8,5]，导弹号，负数为全屏导弹，非负数为单体导弹，否则没有导弹
		effectAction = 12, 		
		shakable = true,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.9 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(15,2,damage,1.5) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}

SkillManager[1620] =
	{
		name = "异火游龙", --新萧炎
		desc = function (lv)
				return "对全体敌人造成200%物理伤害，30%概率使敌方晕眩（持续1回合），第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 2,
		runType = 3, 
		bgAction = 1,
		bannerType = true,
		shout = true,
		shakable = true,
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 2, 
		prepareActionF= 7, 
		prepareActionB= 8, 
		missileAction= -10, 
		effectAction = 20, 
		
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
		
					return att_all
					
			end,

			setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.3 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferStun(0,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
	


	SkillManager[1621] =
	{
		name = "玄天丹魂", --玄衣
		desc = function (lv)
				return "驱散己方全体英雄虚弱、灼烧、中毒状态，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_OWN_ALL, 
		damageRatio = 1,
		runType = 0, 
		--shout = true,
		bannerType = false,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 

		clearFunc = function(lv) 
				return {BUFFER_TYPE_POISON,BUFFER_TYPE_BURN,BUFFER_TYPE_DECREASE}
			end,
	}
SkillManager[1622] =
	{
		name = "丹甲术", --玄衣
		desc = function (lv)
				return "为自己增加护盾（减少50%攻击伤害，抵挡3次攻击），第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = false, 
		target = SkillManager_OWN_SELF, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false,
		--shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferReduction(6,3,0.5,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[1623] =
	{
		name = "赤血丹心", --玄衣
		desc = function (lv)
				return "为己方全体英雄增加持续回血状态（500%，不受海心焰影响，持续2次），每回合释放（可以对处于不可以被治疗状态下的英雄生效）" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_OWN_ALL, 
		damageRatio = 1,
		runType = 0, 
		shout = true,
		bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferRege(10,2,att,5) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[1624] =
	{
		name = "夺命寒冰", --冰尊者
		desc = function (lv)
				return "对后排敌人造成50%法术伤害，50%概率冰冻目标（持续2回合），第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 0.5,
		runType = 0, 
		bannerType = false,
		prepareActionF= 3, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 4, 
		missileAction= 9, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.5 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferFreeze(2,2) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,	
	}

	SkillManager[1625] =
	{
		name = "冻天掌", --冰尊者
		desc = function (lv)
				return "对生命最少敌人造成200%法术伤害，若目标被冰冻额外增加150%法术伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_0, 
		damageRatio = 2,
		runType = 0, 
		bannerType = true,
		shout = true,
		prepareActionF= 1, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				local thisBuffers ={BUFFER_TYPE_FREEZE}
				for i = 1,#enemyBuffers do
					for j = 1,#thisBuffers do
						if enemyBuffers[i] == thisBuffers[j] then
					    return att_all*1.75
						end
					end
				end
				return att_all
			end,			
	}

	SkillManager[1626] = 
	{
		name = "冰毒双修", --冰尊者
		desc = function (lv)
				return "对中毒、灼烧和冰冻效果免疫" 			
			end,
		type = SkillManager_TYPE_PASSIVE_IMBF,
		immunityBufferFunc = function(lv,bufferID,probability) --必须，lv：技能等级；bufferID：待检测的bufferID
				local thisProbability = 1
				local thisBufferIDs = {BUFFER_TYPE_POISON, BUFFER_TYPE_FREEZE,BUFFER_TYPE_BURN} --免疫的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua）
				if thisProbability > probability then
					for i = 1,#thisBufferIDs do
						if thisBufferIDs[i] == bufferID then
							return true
						end
					end
				end
				return false
			end,
	}

	
	SkillManager[1627] =
	{
		name = "力透千钧", --烛坤
		desc = function (lv)
				return "对纵列敌人造成300%物理伤害，自身血量高于对方血量时增加额外140%攻击力，每回合释放" 	
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 3,
		runType = 0,
		bannerType = true,
		shout = true,
		shakable = true,
		prepareActionF= 4, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 0, 
		effectAction = 1, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				if srcHP > dstHP then
					return att_all*1.4
				else
					return att_all
				end
			end,
	}
SkillManager[1628] =
	{
		name = "无双龙影", --烛坤
		desc = function (lv)
				return "替补上场时释放，对随机3个敌人造成400%物理伤害，此技能可以击穿所有英雄护盾和技能免疫伤害效果，但是无法突破异火防御" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ENTER,
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_3, 
		damageRatio = 4,
		runType = 4, 
		bgAction = 1,
		bannerType = true,
		shout = true,
		shakable = true,
		prepareActionF= 4, 
		ignoreIMRE = true, 
		attackAction = 1, 
		injureAction = 2, 
		prepareActionF= 7, 
		prepareActionB= 8, 
		missileAction= 0, 
		effectAction = 1, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				
					return att_all			
			end,
	}
SkillManager[1629] =
	{
		name = "龙皇真身", --烛坤
		desc = function (lv)
				return "对所有负面状态免疫（中毒、灼烧、封印等）" 			
			end,
		type = SkillManager_TYPE_PASSIVE_IMBF,
		immunityBufferFunc = function(lv,bufferID,probability) --必须，lv：技能等级；bufferID：待检测的bufferID
				local thisProbability = 1
				local thisBufferIDs = {BUFFER_TYPE_POISON, BUFFER_TYPE_BURN, BUFFER_TYPE_CURSE, BUFFER_TYPE_DECREASE,BUFFER_TYPE_FREEZE,BUFFER_TYPE_STUN,BUFFER_TYPE_SEAL,BUFFER_TYPE_CURELESS} --免疫的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua） --免疫的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua）
				if thisProbability > probability then
					for i = 1,#thisBufferIDs do
						if thisBufferIDs[i] == bufferID then
							return true
						end
					end
				end
				return false
			end,
	}


		SkillManager[1630] =
	{
		name = "毒龙钻", --北龙王
		desc = function (lv)
				return "对全体敌人造成50%法术伤害，100%概率产生伤害值150%的中毒效果（持续2回合），每回合释放" 	
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 0.5,
		runType = 0,
		bannerType = false,
		--shout = true,
		shakable = true,
		prepareActionF= 4, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 4, 
		missileAction= 14, 
		effectAction = 1, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,

		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferPoison(20,2,damage,1.5) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}


		SkillManager[1631] =
	{
		name = "神龙摆尾", --北龙王
		desc = function (lv)
				return "对前排敌人造成220%法术伤害，若目标已中毒额外增加180%法术伤害，第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 2.2,
		runType = 0, 
		bannerType = true,
		shout = true,
		prepareActionF= 4, 
		shakable = true,
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 4, 
		missileAction= 14, 
		effectAction = 1, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				local thisBuffers ={BUFFER_TYPE_POISON}
				for i = 1,#enemyBuffers do
					for j = 1,#thisBuffers do
						if enemyBuffers[i] == thisBuffers[j] then
					    return att_all*1.8
						end
					end
				end
				return att_all
			end,
	}
			

		SkillManager[1632] =
	{
		name = "见龙卸甲", --北龙王
		desc = function (lv)
				return "血量高于攻击对象时，增加80%攻击" 			
			end,
		type = SkillManager_TYPE_PASSIVE_HPHP,
		addFunc = function(lv,att,srcHP,dstHP) --必须，lv：技能等级；att：角色的基础攻击；srcHP、dstHP：攻击方、被攻击方HP
				local thisPercent = 0.8 --[0,1]攻击增幅百分比
				local thisNumber = 0  --[0,+)攻击增幅自然数
				--     dstHP > srcHP  --更改判断符号
				return dstHP < srcHP and att * thisPercent + thisNumber or 0
			end,
	}
SkillManager[1633] =
	{
		name = "升龙破甲", --南龙王
		desc = function (lv)
				return "对全体敌人造成75%物理伤害，50%概率产生致命效果（伤害翻倍），每回合释放" 	
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 0.75,
		runType = 0,
		bannerType = false,
		--shout = true,
		shakable = true,
		prepareActionF= 4, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 7, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				local thisProbability = 0.5
				if thisProbability > probability then
					return att_all*2
				else		
					return att_all
				end
			end,		
	}

		SkillManager[1634] =
	{
		name = "穿火龙", --南龙王
		desc = function (lv)
				return "对全体敌人造成100%物理伤害，自身任何负面效果都会使自身攻击力翻倍，每回合释放" 	
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 1,
		runType = 1,
		bannerType = true,
		shout = true,
		shakable = true,
		prepareActionF= 4, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 2, 
		missileAction= -10, 
		effectAction = 20, 
		--prepareActionF= 7, 
		--prepareActionB= 8, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				local thisBuffers ={BUFFER_TYPE_POISON, BUFFER_TYPE_BURN, BUFFER_TYPE_CURSE, BUFFER_TYPE_DECREASE,BUFFER_TYPE_CURELESS}
				for i = 1,#myBuffers do
					for j = 1,#thisBuffers do
						if myBuffers[i] == thisBuffers[j] then
					    return att_all*2
						end
					end
				end
				return att_all
			end,	
	}
SkillManager[1635] = 
	{  
		name = "南龙圣像",--南龙王
		desc = function (lv)
				return "每个回合行动结束后，回复40%血量，增加10%攻击，增加15%防御" 			
			end,
		type = SkillManager_TYPE_PASSIVE_FINI,

		finishFunc = function(lv,probability) --必须，lv：技能等级；返回：
				local thisProbability    = 1
				local thisAttackPercent  = 0.1 --[0,1]攻击百分比,谁的回合谁增加攻击
				local thisDefencePercent = 0.15 --[0,1]防御百分比,谁的回合谁增加防御
				local thisHPPercent      = 0.4 --[0,1]回血百分比,谁的回合谁回复血量
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,		
	}


	
	SkillManager[1636] =
	{
		name = "西海冰龙", --西龙王
		desc = function (lv)
				return "80%概率冰冻随机2个敌人（失去1个回合行动能力），第1回合释放，冷却时间1个回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_2, 
		damageRatio = 1,
		runType = 0, 
		bannerType = true,
		--shout = true,
		prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 4, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.8 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferFreeze(0,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,	
	}

SkillManager[1637] =
	{
		name = "冰龙锥", --西龙王
		desc = function (lv)
				return "60%概率冰冻前排3个敌人（失去2个回合行动能力），第2回合释放，冷却时间1个回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 1,
		runType = 0, 
		bannerType = true,
		shout = true,
		prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 4, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.6 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferFreeze(1,2) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,	
	}

SkillManager[1638] =
	{
		name = "龙王幻身", --西龙王
		desc = function (lv)
				return "免疫除灼烧，中毒外所有负面状态" 			
			end,
		type = SkillManager_TYPE_PASSIVE_IMBF,
		immunityBufferFunc = function(lv,bufferID,probability) --必须，lv：技能等级；bufferID：待检测的bufferID
				local thisProbability = 1
				local thisBufferIDs = {BUFFER_TYPE_CURSE, BUFFER_TYPE_DECREASE,BUFFER_TYPE_FREEZE,BUFFER_TYPE_STUN,BUFFER_TYPE_SEAL,BUFFER_TYPE_CURELESS} --免疫的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua） --免疫的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua）
				if thisProbability > probability then
					for i = 1,#thisBufferIDs do
						if thisBufferIDs[i] == bufferID then
							return true
						end
					end
				end
				return false
			end,
	}
SkillManager[1639] =
	{
		name = "玄心九转", --//玄空子
		desc = function (lv)
				return "对纵列敌人造成50%法术伤害，100%概率使对方虚弱（减少80%攻击力，持续2次），第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 0.5,
		runType = 0, 
		bannerType = true,
		shout = true,
		shakable = true,
		prepareActionF= 0, 
		ignoreIMRE = true, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 8, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferDecrease(29,2,0.8,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}

SkillManager[1640] =
	{
		name = "丹心寂灭", --//玄空子
		desc = function (lv)
				return "对前排目标造成30%法术伤害，100%概率使对方虚弱（减少60%攻击力，持续2次），第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 0.3,
		runType = 0, 
		bannerType = true,
		shout = true,
		shakable = true,
		prepareActionF= 0, 
		ignoreIMRE = true, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 8, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferDecrease(25,2,0.6,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}

	
	SkillManager[1641] =
	{
		name = "玄空法印", --玄空子
		desc = function (lv)
				return "每次受到攻击伤害时，减少对方10%基础攻击力，最多累计减少50%" 			
			end,
		type = SkillManager_TYPE_PASSIVE_SETP,
		sattlementFunc = function(lv,probability) --必须，lv：技能等级；
				local thisProbability    = 1
				local thisAttackPercent  = 0.1 --[-1,0)攻击百分比,攻击方降低攻击；[0,1]被攻击方增加攻击
				local thisDefencePercent = 0 --[-1,0)防御百分比,攻击方降低防御；[0,1]被攻击方增加防御
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent
				else
					return 0,0
				end
			end,	
	}
	
	--SkillManager[1605] =
	--{
	--	name = "骨皇裂天", --魂崖
	--	desc = function (lv)
	--			return "受到攻击时有100%概率进行反击，对敌人全体造成50%物理攻击伤害，若目标已中毒，额外造成100%物理伤害" 			
	--		end,
	--	type = SkillManager_TYPE_ACTIVE_COUNTER,--属性含义参照SkillManager_TYPE_ACTIVE_ROUND
	--	--start属性无效
	--	isMana = false,
	--	target = SkillManager_MULTI_ALL,
	--	counterProbability = 1, --反击概率
	--	ignoreIMRE = true,
	--	attackAction = 0,
	--	injureAction = 0,
	--	effectAction = 0,
	--	--prepareActionF= 0,
	--	missileAction= 1,
	--	bannerType = false,
	--	runType = 0,
	--	damageRatio = 0.5,

			SkillManager[1642] =
	{
		name = "烈阳剑", --古烈
		desc = function (lv)
				return "对敌方血量最多敌人造成520%法术伤害，每回合释放,无视伤害减免效果" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_SINGLE_100, 
		damageRatio = 5.2,
		ignoreIMRE = true, 
		runType = 1, 
		bannerType = true,
		shout = true,
		prepareActionF= 4, 
		shakable = true,
		prepareActionF= 1,
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 4, 
		effectAction = 5,
		haloAction = 2,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
			
				return att_all
			end,
			subHpLimit = function(lv,damage,probability,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,myBuffers,enemyBuffers)
				local thisProbability   = 1 --(0,1] 生成概率,数值越大,概率越高
				local subHpLimitPercent = 1--生命上限降低百分比（基于伤害）
				if thisProbability > probability then
					return damage * subHpLimitPercent
				else
					return 0
				end
		end,
	}


SkillManager[1643] =
	{
		name = "古族之怒", --古烈
		desc = function (lv)
				return "受到伤害时有100%概率进行反击，对前排敌人造成200%法术伤害，回合结束后回复20%生命" 		
			end,
		type = SkillManager_TYPE_ACTIVE_COUNTER,--属性含义参照SkillManager_TYPE_ACTIVE_ROUND
		--start属性无效
		isMana = true,
		target = SkillManager_MULTI_ROW_1,
		counterProbability = 1, --反击概率

		damageRatio = 2,
		runType = 0, 
		bannerType = false,
		shout = true,
		prepareActionF= 4, 
		shakable = true,
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 4, 
		effectAction = 10, 
		
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,

		subHpLimit = function(lv,damage,probability,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,myBuffers,enemyBuffers)
				local thisProbability   = 1 --(0,1] 生成概率,数值越大,概率越高
				local subHpLimitPercent = 1--生命上限降低百分比（基于伤害）
				if thisProbability > probability then
					return damage * subHpLimitPercent
				else
					return 0
				end
		end,
		
	}


		SkillManager[1644] = 
	{  
		name = "古魂附身",--古烈
		desc = function (lv)
				return "造成伤害的100%转化为锁魂伤害（在一场战斗中，锁魂伤害造成的生命流失，任何治疗或者回复类技能都不能治愈）" 			
			end,
		type = SkillManager_TYPE_PASSIVE_FINI,

		finishFunc = function(lv,probability) --必须，lv：技能等级；返回：
				local thisProbability    = 1
				local thisAttackPercent  = 0 --[0,1]攻击百分比,谁的回合谁增加攻击
				local thisDefencePercent = 0 --[0,1]防御百分比,谁的回合谁增加防御
				local thisHPPercent      = 0.2 --[0,1]回血百分比,谁的回合谁回复血量
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,		
	}
SkillManager[1645] = 
	{
		name = "盘蛇望月",--妖瞑
		desc = function (lv)
				return "给我方随机3名英雄添加一个护盾（减少60%攻击伤害，抵挡1次攻击），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_OWN_RANDOM_3, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false,
		--shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferReduction(6,1,0.6,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[1646] =
	{
		name = "风蛇绕树", --妖瞑
		desc = function (lv)
				return "对前排敌方造成230%法术伤害，100%概率使敌方无法被治疗（持续2次），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 2.3,
		runType = 0, 
		bannerType = true,
		shout = true,
		shakable = true,
		prepareActionF= 2, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction = 13, 
		effectAction = 12, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,

		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferCureless(2,2) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[1647] =
	{
		name = "天蛇真体",--妖瞑
		desc = function (lv)
				return "受到法术攻击时有70%概率免疫伤害" 			
			end,	
		type = SkillManager_TYPE_PASSIVE_IMAT,
		immunityAttackFunc = function(lv,isMana,probability) --必须，lv：技能等级；isMana：主动技能是否法术；probability：[0,1)随机数
				local thisIsMana = true  --true:法术免疫；false:物理免疫
				local thisProbability = 0.7 --[0,1]免疫概率，数值越大，概率越高
				return thisIsMana == isMana and thisProbability > probability
			end,
	}
SkillManager[1648] =
	{
		name = "六合游身尺", --萧炎觉醒
		desc = function (lv)
				return "对前排敌人造成240%物理伤害，无视伤害减免效果，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 2.4,
		runType = 1, 
		bannerType = false,
		--shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = true, 
		attackAction = 4, 
		injureAction = 3, 
		--missileAction= 1, 
		effectAction = 20,
		shakable = true, 
		
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				
					return att_all
					
			end,
	}


SkillManager[1649] =
	{
		name = "离火焚天", --萧炎觉醒
		desc = function (lv)
				return "对全体敌人造成240%物理伤害，60%概率增加200%的火焰灼烧攻击，第1回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 2.4,
		runType = 3, 
		bannerType = true, 
		shout = true,
		ignoreIMRE = false, 
		prepareActionF= -1,
		bgAction = -1,
		attackAction = 1, 
		injureAction = 0, 
		prepareActionF= -1,
		bgAction = -1,
		missileAction= -5, --可选，[-8,5]，导弹号，负数为全屏导弹，非负数为单体导弹，否则没有导弹
		effectAction = 12, 		
		shakable = true,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				local thisProbability = 0.6--[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return att_all*2
				else
					return att_all
				end
			end,
	}

SkillManager[1650] =
	{
		name = "毁灭火莲", --萧炎觉醒
		desc = function (lv)
				return "对全体敌人造成240%物理伤害，50%概率使敌方晕眩（持续1回合），第2回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 2.4,
		runType = 3, 
		bgAction = 1,
		bannerType = true,
		shout = true,
		shakable = true,
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 2, 
		prepareActionF= 7, 
		prepareActionB= 8, 
		missileAction= -12, 
		effectAction = 20, 
		
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
		
					return att_all
					
			end,

			setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.5 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferStun(0,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[1651] =
	{
		name = "金刚琉璃身", --萧炎觉醒
		desc = function (lv)
				return "对所有负面状态免疫（中毒、灼烧、封印等）" 			
			end,
		type = SkillManager_TYPE_PASSIVE_IMBF,
		immunityBufferFunc = function(lv,bufferID,probability) --必须，lv：技能等级；bufferID：待检测的bufferID
				local thisProbability = 1
				local thisBufferIDs = {BUFFER_TYPE_POISON, BUFFER_TYPE_BURN, BUFFER_TYPE_CURSE, BUFFER_TYPE_DECREASE,BUFFER_TYPE_FREEZE,BUFFER_TYPE_STUN,BUFFER_TYPE_SEAL,BUFFER_TYPE_CURELESS} --免疫的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua） --免疫的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua）
				if thisProbability > probability then
					for i = 1,#thisBufferIDs do
						if thisBufferIDs[i] == bufferID then
							return true
						end
					end
				end
				return false
			end,
	}
SkillManager[1652] =
		{
		name = "黑炎火雨",--虚无吞炎
		desc = function (lv)
				return "对敌方全体造成180%法术伤害，100%概率产生伤害值200%的火焰灼烧效果（持续1回合），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 1.8,
		runType = 0, 
		
		bannerType = false,
		shout = false,
		shakable = true,
		ignoreIMRE = false, 

		prepareActionF= -1,
		bgAction = -1,
		--blood = true,
		attackAction = 0, 
		injureAction = 2, 
		missileAction= -13, 
		effectAction = 12, 

		attackFunc = function(lv,att_all,isMana,srcHP,dstHP,myDeath,enemyDeath,probability,buffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(20,1,damage,2) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,

	}
SkillManager[1653] =
	{
		name = "吞天噬地", --虚无吞炎
		desc = function (lv)
				return "死亡时释放，对所有敌人造成200%法术伤害，并转化为锁魂伤害（无法回复和治疗）" 			
			end,
		type = SkillManager_TYPE_ACTIVE_EXIT, 
		isMana = true, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 2,
		runType = 0, 
		bannerType = true, 
		shout = true,
		shakable = true,
		prepareActionF= 2, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 1, 
		effectAction = 12, 

		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		subHpLimit = function(lv,damage,probability,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,myBuffers,enemyBuffers)
				local thisProbability   = 1 --(0,1] 生成概率,数值越大,概率越高
				local subHpLimitPercent = 1--生命上限降低百分比（基于伤害）
				if thisProbability > probability then
					return damage * subHpLimitPercent
				else
					return 0
				end
		end,	
	}
SkillManager[1654] = 
	{
		name = "无相无形",--虚无吞炎
		desc = function(lv)
				return "死亡后100%概率复活（1次机会），恢复自身70%血量，增加20%防御，并清除所有状态"
			end,
		type = SkillManager_TYPE_PASSIVE_REVIVE,
		reviveFunc = function(lv,whichTime,probability)
				local thisMaxReviveCount = 1 --[0,无穷大),允许的复活次数
				local thisProbability = 1 --[0,1] 每一次的复活概率,数值越大,概率越高
				return thisMaxReviveCount >= whichTime and thisProbability >= probability
			end,
		hpAttackDefence = function(lv,whichTime,hpMax,hpLmt,phscAtt,manaAtt,phscDef,manaDef)
				local retHpLmt = hpMax --!!!该返回值不能为0
				local retHpCur = hpMax*0.7 --!!!该返回值不能为0
				local retPhscAtt=phscAtt
				local retManaAtt=manaAtt
				local retPhscDef=phscDef*1.2
				local retManaDef=manaDef*1.2
				return retHpLmt,retHpCur,retPhscAtt,retManaAtt,retPhscDef,retManaDef
			end,
	}
SkillManager[1655] =
	{
		name = "寒骨灵火", --药老觉醒
		desc = function (lv)
				return "对随机3个敌人造成280%法术伤害，80%概率产生攻击伤害值300%的灼烧效果（持续1回合），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_3, 
		damageRatio = 2.8,
		runType = 0, 
		bannerType = false,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 2, 
		effectAction = 12, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.8 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(24,1,damage,3) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,	
	}
SkillManager[1656] =
	{
		name = "如露含光", --药老觉醒
		desc = function (lv)
				return "治疗己方血量最少的英雄（900%），并驱散所有负面状态，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_OWN_0, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 3, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 
		regeFunc = function(lv,att_all) 
				return att_all*9
			end,
		clearFunc = function(lv) 
				return {BUFFER_TYPE_POISON,BUFFER_TYPE_BURN,BUFFER_TYPE_DECREASE,BUFFER_TYPE_FREEZE,BUFFER_TYPE_STUN,BUFFER_TYPE_SEAL,BUFFER_TYPE_CURSE,BUFFER_TYPE_CURELESS}
			end,
	}
SkillManager[1657] =
	{
		name = "焰分噬浪", --药老觉醒
		desc = function (lv)
				return "对所有敌人造成250%法术伤害，80%概率使敌人虚弱（攻击减少30%，持续2次），第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 2.5,
		runType = 4, 
		bgAction = 1,
		bannerType = true,
		shout = true,
		shakable = true,
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 2, 
		prepareActionF= 7, 
		prepareActionB= 8, 
		missileAction= -11, 
		effectAction = 20, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.8 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferDecrease(3,2,0.3,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[1658] = 
	{
		name = "不屈戒灵",--药老觉醒
		desc = function(lv)
				return "死亡后60%概率复活（3次机会），恢复自身60%血量，并清除所有状态"
			end,
		type = SkillManager_TYPE_PASSIVE_REVIVE,
		reviveFunc = function(lv,whichTime,probability)
				local thisMaxReviveCount = 3 --[0,无穷大),允许的复活次数
				local thisProbability = 0.55 --[0,1] 每一次的复活概率,数值越大,概率越高
				return thisMaxReviveCount >= whichTime and thisProbability >= probability
			end,
		hpAttackDefence = function(lv,whichTime,hpMax,hpLmt,phscAtt,manaAtt,phscDef,manaDef)
				local retHpLmt = hpMax --!!!该返回值不能为0
				local retHpCur = hpMax*0.6 --!!!该返回值不能为0
				local retPhscAtt=phscAtt
				local retManaAtt=manaAtt
				local retPhscDef=phscDef
				local retManaDef=manaDef
				return retHpLmt,retHpCur,retPhscAtt,retManaAtt,retPhscDef,retManaDef
			end,
	}
SkillManager[1659] =
	{
		name = "九幽灵泉", --幽泉
		desc = function (lv)
				return "对纵列敌人造成250%物理攻击伤害，血量每减少1%增加1%攻击力，当目标血量高于50%时全部伤害转为锁魂伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 2.5,
		runType = 0, 
		bannerType = true,
		shout = true,
		shakable = true,
		prepareActionF= 0, 
		ignoreIMRE = true, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 8, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all*(2-srcHP/srcHPMax)
			end,
		subHpLimit = function(lv,damage,probability,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,myBuffers,enemyBuffers)
				--local thisProbability   = 1 --(0,1] 生成概率,数值越大,概率越高
				local subHpLimitPercent = 1--生命上限降低百分比（基于伤害）
				if dstHP > dstHPMax * 0.5 then
					return damage * subHpLimitPercent
				else
					return 0
				end
		end,
	}
SkillManager[1660] =
	{
		name = "藤甲术", --幽泉
		desc = function (lv)
				return "为自己增加护盾（减少50%攻击伤害，抵挡2次攻击），第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = false, 
		target = SkillManager_OWN_SELF, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false,
		--shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferReduction(5,2,0.5,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[1661] =
	{
		name = "碧水枯源", --幽泉
		desc = function (lv)
				return "攻击对方并造成伤害，100%概率将40%伤害值转化为自身生命" 			
			end,
		type = SkillManager_TYPE_PASSIVE_SETA,
		sattlementFunc = function(lv,probability) --必须，lv：技能等级；
				local thisProbability    = 1
				local thisAttackPercent  = 0 --[-1,0)攻击百分比,被攻击方降低攻击；[0,1]攻击方增加攻击
				local thisDefencePercent = 0 --[-1,0)防御百分比,被攻击方降低防御；[0,1]攻击方增加防御
				local thisHPPercent      = 0.4 --[0,1] 吸血百分比,攻击方吸血
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,
	}
SkillManager[1662] =
	{
		name = "风灵分形剑", --魂风觉醒
		desc = function (lv)
				return "对纵列敌人造成200%法术伤害，100%概率使对方虚弱（减少50%攻击力，持续2次），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 2,
		runType = 0, 
		bannerType = false,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 14, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,

		setupBuffer = function(lv,att,damage,probability)
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferDecrease(5,2,0.5,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
			
	}
SkillManager[1663] =
	{
		name = "裂风虎啸掌", --魂风觉醒
		desc = function (lv)
				return "对敌方全体造成200%法术攻击伤害，100%概率使敌方无法被治疗（持续5次），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 2,
		runType = 0, 
		bannerType = true,
		shout = true,
		shakable = true,
		prepareActionF= 2, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 13, 
		effectAction = 21, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,

		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferCureless(5,5) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[1664] = 
	{
		name = "聚灵甲",--魂风觉醒
		desc = function (lv)
				return "为自身增加护盾（减少50%攻击伤害，抵挡2次攻击），第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = false, 
		target = SkillManager_OWN_SELF, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false,
		--shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferReduction(6,2,0.5,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,

	}	
SkillManager[1665] = 
	{
		name = "黑风斩杀",--魂风觉醒
		desc = function (lv)
				return "受到攻击时100%概率进行反击，造成250%法术伤害，70%概率直接秒杀血量低于30%的目标，无视免疫和伤害减免效果" 			
			end,
		type = SkillManager_TYPE_ACTIVE_COUNTER,--属性含义参照SkillManager_TYPE_ACTIVE_ROUND
		--start属性无效
		isMana = true,
		target = SkillManager_SINGLE_COUNTER,
		counterProbability = 1, --反击概率
		ignoreIMRE = true,
		attackAction = 0,
		injureAction = 0,
		effectAction = 0,
		--prepareActionF= 0,
		missileAction= 14,
		bannerType = false,
		runType = 0,
		damageRatio = 2.5,

		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				local thisProbability = 0.7
				if thisProbability > probability and dstHP < dstHPMax*0.3 then	
					return att_all*999999999
				else
					return att_all
				end
			end,			
	}	
SkillManager[1666] = 
	{
		name = "天赐蛇甲",--美杜莎觉醒
		desc = function (lv)
				return "为自身增加护盾（减少60%攻击伤害，抵挡3次攻击），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_OWN_SELF, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false,
		--shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferReduction(6,3,0.6,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,

	}
SkillManager[1667] =
	{
		name = "地刺封印", --美杜莎觉醒
		desc = function (lv)
				return "对敌方随机3名英雄造成340%物理攻击伤害，自身血量低于对方血量时增加120%攻击力，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_3, 
		damageRatio = 3.4,
		runType = 0, 
		bannerType = true,
		shout = true,
		shakable = true,
		prepareActionF= 3, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 5, 
		--missileAction= 0, 
		effectAction = 8, 
		haloAction = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
					return att_all
			end,
		subHpLimit = function(lv,damage,probability,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,myBuffers,enemyBuffers)
				local thisProbability   = 1 --(0,1] 生成概率,数值越大,概率越高
				local subHpLimitPercent = 1--生命上限降低百分比（基于伤害）
				if thisProbability > probability then
					return damage * subHpLimitPercent
				else
					return 0
				end
		end,
	}
SkillManager[1668] =
	{
		name = "嗜血蛇纹", --美杜莎觉醒
		desc = function (lv)
				return "攻击对方并造成伤害，100%概率将60%伤害值转化为自身生命" 			
			end,
		type = SkillManager_TYPE_PASSIVE_SETA,
		sattlementFunc = function(lv,probability) --必须，lv：技能等级；
				local thisProbability    = 1
				local thisAttackPercent  = 0 --[-1,0)攻击百分比,被攻击方降低攻击；[0,1]攻击方增加攻击
				local thisDefencePercent = 0 --[-1,0)防御百分比,被攻击方降低防御；[0,1]攻击方增加防御
				local thisHPPercent      = 0.6 --[0,1] 吸血百分比,攻击方吸血
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,
	}
SkillManager[1669] =
	{
		name = "七彩吞天",--美杜莎觉醒
		desc = function (lv)
				return "造成伤害的100%转化为锁魂伤害（在一场战斗中，锁魂伤害造成的生命流失，任何治疗或者回复类技能都不能治愈）" 			
			end,
		type = SkillManager_TYPE_PASSIVE_HPHP,
		addFunc = function(lv,att,srcHP,dstHP) --必须，lv：技能等级；att：角色的基础攻击；srcHP、dstHP：攻击方、被攻击方HP
				local thisPercent = 0.5 --[0,1]攻击增幅百分比
				local thisNumber = 0  --[0,+)攻击增幅自然数
				--     dstHP > srcHP  --更改判断符号
				return dstHP > srcHP and att * thisPercent + thisNumber or 0
			end,
	}
SkillManager[1670] = 
	{
		name = "勾魂夺魄",--潇潇
		desc = function (lv)
				return "对所有敌人造成220%法术伤害，50%概率使敌人虚弱（攻击减少50%，持续2次），第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 2.2,
		runType = 0, 
		bannerType = true, 
		shout = false,
		shakable = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 10, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
							return att_all
					end,
		
		setupBuffer = function(lv,att,damage,probability)
				local thisProbability = 0.5 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferDecrease(5,2,0.5,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[1671] =
	{
		name = "吞天咒印", --潇潇
		desc = function (lv)
				return "对随机三个敌人造成240%法术伤害，70%概率使敌人被封印（失去2个回合行动力），第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_3, 
		damageRatio = 2.4,
		runType = 0, 
		bannerType = true,
		shout = true,
		prepareActionF= 4, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 8, 
		effectAction = 7,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
					return att_all
			end, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.7 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferSeal(0,2) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[1672] =
	{
		name = "灵蛇护体", --潇潇
		desc = function (lv)
				return "对所有负面状态免疫（中毒、灼烧、封印等）" 			
			end,
		type = SkillManager_TYPE_PASSIVE_IMBF,
		immunityBufferFunc = function(lv,bufferID,probability) --必须，lv：技能等级；bufferID：待检测的bufferID
				local thisProbability = 1
				local thisBufferIDs = {BUFFER_TYPE_POISON, BUFFER_TYPE_BURN, BUFFER_TYPE_CURSE, BUFFER_TYPE_DECREASE,BUFFER_TYPE_FREEZE,BUFFER_TYPE_STUN,BUFFER_TYPE_SEAL,BUFFER_TYPE_CURELESS} --免疫的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua） --免疫的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua）
				if thisProbability > probability then
					for i = 1,#thisBufferIDs do
						if thisBufferIDs[i] == bufferID then
							return true
						end
					end
				end
				return false
			end,
	}
SkillManager[1673] =
	{
		name = "金帝焚天阵", --古元
		desc = function (lv)
				return "对后排敌人造成300%法术伤害，100%概率产生伤害值150%的灼烧效果（持续2回合），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 3,
		runType = 0, 
		bannerType = false, 
		shakable = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 1, 
		 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(15,2,damage,1.5) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[1674] =
	{
		name = "金帝焚天斩", --古元
		desc = function (lv)
				return "替补上场时释放，对随机2个敌人造成300%法术伤害，增加己方存活人数乘以30%的攻击力（最大增幅210%）" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ENTER,
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_2, 
		damageRatio = 3,
		runType = 0, 
		bannerType = true,
		shout = true,
		prepareActionF= 1, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 5,
		haloAction = 2, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				local thisProbability = 1
				if thisProbability > probability then
					if (9-myDeath)*0.3 < 2.1 then
						return att_all*(9-myDeath)*0.3
					else
						return att_all*2.1
					end
				else
					return att_all
				end
			end,
	}
SkillManager[1675] =
	{
		name = "阴阳流转诀", --古元
		desc = function (lv)
				return "攻击对方时，自身30%物攻属性转化为法攻属性" 			
			end,
		type = SkillManager_TYPE_PASSIVE_TRAN,
		addFunc = function(lv,isMana,phscAtt,manaAtt,probability) --必须，lv：技能等级；isMana：主动技能是否法术；phscAtt：角色的物理攻击；manaAtt：角色的法术攻击；probability：[0,1)随机数
				local thisProbability = 1
				local thisPercent = 0.3 --转化比例
				if thisProbability > probability then
					return thisPercent * (isMana and phscAtt or manaAtt)
				else
					return thisPercent * 0
				end
			end,
	}
SkillManager[1676] =
	{
		name = "天毒牢界", --小医仙觉醒
		desc = function (lv)
				return "对随机3个敌人造成240%法术伤害，80%概率产生伤害值120%的中毒效果（持续1回合），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_3, 
		damageRatio = 2.4,
		runType = 0, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 9, 
		effectAction = 10, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.8 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferPoison(12,1,damage,1.2) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[1677] =
	{
		name = "天蚀雨", --小医仙觉醒
		desc = function (lv)
				return "治疗我方全体英雄（250%），解除中毒负面效果，第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_OWN_ALL, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false,
		--shout = true,
		prepareActionF= 4, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 
		
		regeFunc = function(lv,att_all) 
				return att_all*2.5
			end,
		clearFunc = function(lv) 
				return {BUFFER_TYPE_POISON}
			end,
	}
SkillManager[1678] =
	{
		name = "厄难毒体",--小医仙觉醒
		desc = function (lv)
				return "死亡时释放，对所有敌人造成240%法术伤害，85%概率产生伤害值240%的中毒效果（持续2回合）" 			
			end,		
		type = SkillManager_TYPE_ACTIVE_EXIT, --属性含义参照SkillManager_TYPE_ACTIVE_ROUND
		--start属性无效
		isMana = true,
		target = SkillManager_MULTI_ALL,
		runType = 0,
		bannerType = true,
		shout = true,
		shakable = true,
		ignoreIMRE = false,
		attackAction = 3,
		injureAction = 0,
		--prepareActionF= 0,
		missileAction= 8, 
		effectAction = 7,
		damageRatio = 2.4,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.85 --[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferPoison(32,2,damage,2.4) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,	
	}
SkillManager[1679] = --反弹伤害技能
	{
		name = "厄难毒体•解", --小医仙觉醒
		desc = function (lv)
				return "当自身受到伤害时将伤害值的45%施加于造成当前伤害的敌人，若自身处于中毒状态则施加效果额外增加10%"
			end,
		type = SkillManager_TYPE_PASSIVE_REBOUND,
		reboundFunc = function(lv,actualDamage,myBuffers) --必须，lv：技能等级；actualDamage：实际受到的伤害；myBuffers：自身带有的Buffers
				local thisBufferIDs = {BUFFER_TYPE_POISON}
				local thisPercent = 0.45 --基础转化比例
				local plusPercent = 0.1 --额外转化比例
				local bufferCount = 0
				for i = 1,#thisBufferIDs do
					for j = 1,#myBuffers do
						if thisBufferIDs[i] == myBuffers[j] then
							bufferCount = bufferCount + 1
						end
					end
				end
				return actualDamage*(thisPercent+bufferCount*plusPercent)
			end,
	}
SkillManager[1680] =
	{
	
				name = "追魂噬骨",--魂灭生觉醒
		desc = function (lv)
				return "发动攻击时，攻击目标附有不能被治疗状态时，增加180%攻击力" 			
			end,
		type = SkillManager_TYPE_PASSIVE_BUFF,
		addFunc = function(lv,att,enemyBuffers) --必须，lv：技能等级；att：角色的基础攻击；enemyBuffers：被动方身上的bufferIDs表
				local thisBuffers = {BUFFER_TYPE_CURELESS} --攻击增幅触发的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua）
				local thisPercent = 1.8  --[0,1]攻击增幅百分比
				local thisNumber = 0   --[0,+)攻击增幅自然数
				for i = 1,#enemyBuffers do
					for j = 1,#thisBuffers do
						if enemyBuffers[i] == thisBuffers[j] then
							return att * thisPercent + thisNumber
						end
					end
				end
				return 0
			end,
	}
SkillManager[1681] =
	{
		name = "魂生魂灭",--魂灭生觉醒
		desc = function (lv)
				return "55%概率免疫任意攻击伤害" 			
			end,	
		type = SkillManager_TYPE_PASSIVE_IMAT,
		immunityAttackFunc = function(lv,isMana,probability) --必须，lv：技能等级；isMana：主动技能是否法术；probability：[0,1)随机数
				  --true:法术免疫；false:物理免疫
				 --[0,1]免疫概率，数值越大，概率越高
				if isMana then
					return  0.55 > probability
				else
					return  0.55 > probability
				end
				
			end,
	}
SkillManager[1682] =
		{
		name = "魂灭斩",--魂灭生觉醒
		desc = function (lv)
				return "对后排敌人造成100%物理伤害，80%概率使敌方晕眩（持续1回合），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 1,
		runType = 4, 
		
		bannerType = true,
		shout = true,
		shakable = true,
		ignoreIMRE = false, 

		--prepareActionF= 3, 
		--ignoreIMRE = false, 
		--attackAction = 1, 
		--injureAction = 5, 
		--effectAction = 8, 
		--haloAction = 1,

		prepareActionF= -1,
		bgAction = -1,
		blood = true,
		attackAction = 1, 
		injureAction = 2, 
		missileAction= -13, 
		effectAction = 20, 
		attackFunc = function(lv,att_all,isMana,srcHP,dstHP,myDeath,enemyDeath,probability,buffers) 
				return att_all
			end,
			setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.8 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferStun(0,1) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[1683] = 
	{  
		name = "天罗封魔阵",-- 魂灭生觉醒
		desc = function (lv)
				return "每个回合行动结束后，回复25%血量" 			
			end,
		type = SkillManager_TYPE_PASSIVE_FINI,

		finishFunc = function(lv,probability) --必须，lv：技能等级；返回：
				local thisProbability    = 1
				local thisAttackPercent  = 0 --[0,1]攻击百分比,谁的回合谁增加攻击
				local thisDefencePercent = 0 --[0,1]防御百分比,谁的回合谁增加防御
				local thisHPPercent      = 0.25 --[0,1]回血百分比,谁的回合谁回复血量
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,		
	}

SkillManager[1684] =
	{
		name = "力透千钧", --烛坤觉醒
		desc = function (lv)
				return "对纵列敌人造成340%物理伤害，自身血量高于对方血量时增加额外160%攻击力，每回合释放" 	
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 3.4,
		runType = 0,
		bannerType = true,
		shout = true,
		shakable = true,
		prepareActionF= 4, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 0, 
		effectAction = 1, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				if srcHP > dstHP then
					return att_all*1.6
				else
					return att_all
				end
			end,
	}

SkillManager[1685] =
	{
		name = "无双龙影", --烛坤觉醒
		desc = function (lv)
				return "替补上场时释放，对随机3个敌人造成440%物理伤害，此技能可以击穿所有英雄护盾和技能免疫伤害效果，但是无法突破异火防御" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ENTER,
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_3, 
		damageRatio = 4.4,
		runType = 4, 
		bgAction = 1,
		bannerType = true,
		shout = true,
		shakable = true,
		prepareActionF= 4, 
		ignoreIMRE = true, 
		attackAction = 1, 
		injureAction = 2, 
		prepareActionF= 7, 
		prepareActionB= 8, 
		missileAction= 0, 
		effectAction = 1, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				
					return att_all
				
			end,
	}

SkillManager[1686] =
	{
		name = "龙皇真身", --烛坤觉醒
		desc = function (lv)
				return "对所有负面状态免疫（中毒、灼烧、封印等）" 			
			end,
		type = SkillManager_TYPE_PASSIVE_IMBF,
		immunityBufferFunc = function(lv,bufferID,probability) --必须，lv：技能等级；bufferID：待检测的bufferID
				local thisProbability = 1
				local thisBufferIDs = {BUFFER_TYPE_POISON, BUFFER_TYPE_BURN, BUFFER_TYPE_CURSE, BUFFER_TYPE_DECREASE,BUFFER_TYPE_FREEZE,BUFFER_TYPE_STUN,BUFFER_TYPE_SEAL,BUFFER_TYPE_CURELESS} --免疫的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua） --免疫的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua）
				if thisProbability > probability then
					for i = 1,#thisBufferIDs do
						if thisBufferIDs[i] == bufferID then
							return true
						end
					end
				end
				return false
			end,
	}
SkillManager[1687] =
	{
		name = "太虚秘法", --烛坤觉醒技能新
		desc = function (lv)
				return "攻击时，把自身40%的法攻属性转化为物攻属性" 			
			end,
		type = SkillManager_TYPE_PASSIVE_TRAN,
		addFunc = function(lv,isMana,phscAtt,manaAtt,probability) --必须，lv：技能等级；isMana：主动技能是否法术；phscAtt：角色的物理攻击；manaAtt：角色的法术攻击；probability：[0,1)随机数
				if isMana then
					local thisProbability = 1
					local thisPercent = 0.4 --转化比例
					if thisProbability > probability then
						return thisPercent * manaAtt
					else
						return thisPercent * 0
					end
				end
				return 0
			end,
	}
SkillManager[1688] =
	{
		name = "噬魂生术", --魂虚子
		desc = function (lv)
				return "为己方全体英雄增加持续回血状态（550%，不受海心焰影响，持续2次），每回合释放（可以对处于不可以被治疗状态下的英雄生效）" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_OWN_ALL, 
		damageRatio = 1,
		runType = 0, 
		shout = true,
		bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferRege(10,2,att,5.5) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[1689] = 
	{
		name = "死神之指",--魂虚子
		desc = function (lv)
				return "对随机3个敌人造成240%法术伤害，80%概率使敌人虚弱（攻击减少60%，持续2次），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_3, 
		damageRatio = 2.4,
		runType = 0, 
		bannerType = false, 
		shout = false,
		shakable = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 3, 
		effectAction = 10, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
							return att_all
					end,
		
		setupBuffer = function(lv,att,damage,probability)
				local thisProbability = 0.8 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferDecrease(6,2,0.6,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[1690] =
	{
		name = "降灵血咒", --魂虚子
		desc = function (lv)
				return "治疗己方血量最少的英雄（600%），并驱散所有负面状态，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_OWN_0, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 3, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 
		regeFunc = function(lv,att_all) 
				return att_all*6
			end,
		clearFunc = function(lv) 
				return {BUFFER_TYPE_POISON,BUFFER_TYPE_BURN,BUFFER_TYPE_DECREASE,BUFFER_TYPE_FREEZE,BUFFER_TYPE_STUN,BUFFER_TYPE_SEAL,BUFFER_TYPE_CURSE,BUFFER_TYPE_CURELESS}
			end,
	}
SkillManager[1691] =
	{
		name = "太虚一击", --紫妍觉醒
		desc = function (lv)
				return "对血量最低的敌人造成380%物理伤害，自身血量高于对方血量时增加额外200%攻击力，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_SINGLE_0, 
		damageRatio = 3.8,
		runType = 0,
		bannerType = true,
		shout = true,
		shakable = true,
		prepareActionF= 4, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 0, 
		effectAction = 1, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers,isWorldBoss) 

				local thisProbability = 0.8
				if isWorldBoss then
					return att_all
				else 
					if thisProbability > probability and dstHP < dstHPMax*0.4 then
						return att_all*999999999
					else
						return att_all
					end
				end
			end,
	}
SkillManager[1692] =
	{
		name = "凝瑰龙影", --紫妍觉醒
		desc = function (lv)
				return "攻击对方并造成伤害，100%概率将100%伤害值转化为自身生命" 			
			end,
		type = SkillManager_TYPE_PASSIVE_SETA,
		sattlementFunc = function(lv,probability) --必须，lv：技能等级；
				local thisProbability    = 1
				local thisAttackPercent  = 0 --[-1,0)攻击百分比,被攻击方降低攻击；[0,1]攻击方增加攻击
				local thisDefencePercent = 0 --[-1,0)防御百分比,被攻击方降低防御；[0,1]攻击方增加防御
				local thisHPPercent      = 1.2 --[0,1] 吸血百分比,攻击方吸血
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,
	}
SkillManager[1693] =
	{
		name = "龙皇真身", --紫妍觉醒
		desc = function (lv)
				return "对所有负面状态免疫（中毒、灼烧、封印等）" 			
			end,
		type = SkillManager_TYPE_PASSIVE_IMBF,
		immunityBufferFunc = function(lv,bufferID,probability) --必须，lv：技能等级；bufferID：待检测的bufferID
				local thisProbability = 1
				local thisBufferIDs = {BUFFER_TYPE_POISON, BUFFER_TYPE_BURN, BUFFER_TYPE_CURSE, BUFFER_TYPE_DECREASE,BUFFER_TYPE_FREEZE,BUFFER_TYPE_STUN,BUFFER_TYPE_SEAL,BUFFER_TYPE_CURELESS} --免疫的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua） --免疫的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua）
				if thisProbability > probability then
					for i = 1,#thisBufferIDs do
						if thisBufferIDs[i] == bufferID then
							return true
						end
					end
				end
				return false
			end,
	}
SkillManager[1694] =
	{
		name = "屠龙剑", --紫妍觉醒
		desc = function (lv)
				return "目标血量低于40%时，有80%几率直接造成必杀攻击,无视伤害减免（对世界boss无效）" 			
			end,
		type = SkillManager_TYPE_PASSIVE_HPHP,
		addFunc = function(lv,att,srcHP,dstHP) --必须，lv：技能等级；att：角色的基础攻击；srcHP、dstHP：攻击方、被攻击方HP
				local thisPercent = 1 --[0,1]攻击增幅百分比
				local thisNumber = 0  --[0,+)攻击增幅自然数
				--     dstHP > srcHP  --更改判断符号
				return dstHP < srcHP and att * thisPercent + thisNumber or 0
			end,
	}
SkillManager[1695] =
	{
		name = "普济莲心", --药灵
		desc = function (lv)
				return "治疗己方全体英雄（400%），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_OWN_ALL, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false,
		shout = false, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 
		regeFunc = function(lv,att_all) 
				return att_all*4
			end,
	}
SkillManager[1696] =
	{
		name = "济世为怀", --药灵
		desc = function (lv)
				return "驱散已方全体英雄负面状态（锁魂状态除外），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_OWN_ALL, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 3, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 

		clearFunc = function(lv) 
				return {BUFFER_TYPE_POISON,BUFFER_TYPE_BURN,BUFFER_TYPE_DECREASE,BUFFER_TYPE_FREEZE,BUFFER_TYPE_STUN,BUFFER_TYPE_SEAL,BUFFER_TYPE_CURSE,BUFFER_TYPE_CURELESS}
			end,
	}
SkillManager[1697] =
	{
		name = "慈航普渡", --药灵
		desc = function (lv)
				return "已方全体增加40%基础攻击力（持续2次），第1回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 1, 
		isMana = true,
		target = SkillManager_OWN_ALL, 
		damageRatio = 1,
		runType = 0, 
		bannerType = true,
		shout = true, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 3, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 20, 
		
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferIncrease(2,2,0.4,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,			
	}
SkillManager[1698] = 
	{
		name = "勾魂夺魄",--潇潇觉醒
		desc = function (lv)
				return "对所有敌人造成260%法术伤害，60%概率使敌人虚弱（攻击减少50%，持续2次），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 2.6,
		runType = 0, 
		bannerType = true, 
		shout = false,
		shakable = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 10, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
							return att_all
					end,
		
		setupBuffer = function(lv,att,damage,probability)
				local thisProbability = 0.6 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferDecrease(5,2,0.5,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[1699] =
	{
		name = "吞天咒印", --潇潇觉醒
		desc = function (lv)
				return "对随机三个敌人造成300%法术伤害，70%概率使敌人被封印（失去2个回合行动力），第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_3, 
		damageRatio = 3,
		runType = 0, 
		bannerType = true,
		shout = true,
		prepareActionF= 4, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 8, 
		effectAction = 7,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
					return att_all
			end, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.7 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferSeal(0,2) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[1700] =
	{
		name = "灵蛇护体", --潇潇觉醒
		desc = function (lv)
				return "对所有负面状态免疫（中毒、灼烧、封印等）" 			
			end,
		type = SkillManager_TYPE_PASSIVE_IMBF,
		immunityBufferFunc = function(lv,bufferID,probability) --必须，lv：技能等级；bufferID：待检测的bufferID
				local thisProbability = 1
				local thisBufferIDs = {BUFFER_TYPE_POISON, BUFFER_TYPE_BURN, BUFFER_TYPE_CURSE, BUFFER_TYPE_DECREASE,BUFFER_TYPE_FREEZE,BUFFER_TYPE_STUN,BUFFER_TYPE_SEAL,BUFFER_TYPE_CURELESS} --免疫的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua） --免疫的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua）
				if thisProbability > probability then
					for i = 1,#thisBufferIDs do
						if thisBufferIDs[i] == bufferID then
							return true
						end
					end
				end
				return false
			end,
	}
SkillManager[1701] = 
	{  
		name = "炎帝封印",--潇潇觉醒
		desc = function (lv)
				return "每个回合行动结束后，回复20%血量，增加30%攻击，增加20%防御" 			
			end,
		type = SkillManager_TYPE_PASSIVE_FINI,

		finishFunc = function(lv,probability) --必须，lv：技能等级；返回：
				local thisProbability    = 1
				local thisAttackPercent  = 0.3 --[0,1]攻击百分比,谁的回合谁增加攻击
				local thisDefencePercent = 0.2 --[0,1]防御百分比,谁的回合谁增加防御
				local thisHPPercent      = 0.2 --[0,1]回血百分比,谁的回合谁回复血量
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,		
	}
SkillManager[1702] =
	{
		name = "裂地斩", --萧晨
		desc = function (lv)
				return "对前排敌人造成200%物理伤害，自身带有异常状态时，额外增加60%物理伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 2,
		runType = 0, 
		bannerType = false, 
		shakable = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 1, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				local thisBuffers ={BUFFER_TYPE_POISON, BUFFER_TYPE_BURN, BUFFER_TYPE_CURSE, BUFFER_TYPE_DECREASE,BUFFER_TYPE_CURELESS}
				for i = 1,#myBuffers do
					for j = 1,#thisBuffers do
						if myBuffers[i] == thisBuffers[j] then
					    return att_all*1.6
						end
					end
				end
				return att_all
			end,
	}
SkillManager[1703] =
	{
		name = "破天三斧", --萧晨
		desc = function (lv)
				return "替补上场时释放，对随机3个敌人造成240%物理伤害，可击穿所有英雄护盾和技能免疫伤害效果，但是无法突破异火防御" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ENTER,
		isMana = false, 
		target = SkillManager_MULTI_RANDOM_3, 
		damageRatio = 2.4,
		runType = 4, 
		bgAction = 1,
		bannerType = true,
		shout = true,
		shakable = true,
		prepareActionF= 4, 
		ignoreIMRE = true, 
		attackAction = 1, 
		injureAction = 2, 
		prepareActionF= 7, 
		prepareActionB= 8, 
		missileAction= 0, 
		effectAction = 1, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 			
					return att_all			
			end,
	}
SkillManager[1704] =
	{
		name = "傲断苍穹", --萧晨
		desc = function (lv)
				return "对血量最低的敌人造成320%物理伤害，自身血量高于对方血量时增加额外120%攻击力，第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = false, 
		target = SkillManager_SINGLE_0, 
		damageRatio = 3.2,
		runType = 0,
		bannerType = true,
		shout = true,
		shakable = true,
		prepareActionF= 4, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 0, 
		effectAction = 1, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				if srcHP > dstHP then
					return att_all*1.4
				else
					return att_all
				end
			end,
	}
SkillManager[1705] = 
	{  
		name = "能量自愈",--萧玄
		desc = function (lv)
				return "每个回合行动结束后，回复自身40%血量" 			
			end,
		type = SkillManager_TYPE_PASSIVE_FINI,

		finishFunc = function(lv,probability) --必须，lv：技能等级；返回：
				local thisProbability    = 1
				local thisAttackPercent  = 0 --[0,1]攻击百分比,谁的回合谁增加攻击
				local thisDefencePercent = 0 --[0,1]防御百分比,谁的回合谁增加防御
				local thisHPPercent      = 0.4 --[0,1]回血百分比,谁的回合谁回复血量
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,		
	}
SkillManager[1706] =
	{
		name = "玄元旋杀", --萧玄
		desc = function (lv)
				return "对全体敌人造成240%物理伤害，自身血量高于对方血量时增加额外160%攻击力，每回合释放" 	
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 2.4,
		runType = 0,
		bannerType = false,
		--shout = true,
		shakable = true,
		prepareActionF= 4, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 7, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				if srcHP > dstHP then
					return att_all*1.8
				else
					return att_all
				end
			end,
	}
SkillManager[1707] =
	{
		name = "灵魂自燃",--萧玄
		desc = function (lv)
				return "死亡时释放，对所有敌人造成220%物理伤害，并转化为锁魂伤害（在一场战斗中，任何治疗或者回复类技能都不能治愈）" 			
			end,		
		type = SkillManager_TYPE_ACTIVE_EXIT, --属性含义参照SkillManager_TYPE_ACTIVE_ROUND
		--start属性无效
		isMana = false,
		target = SkillManager_MULTI_ALL,
		runType = 3,
		bannerType = true,
		shout = true,
		shakable = true,
		ignoreIMRE = false,
		attackAction = 1,
		injureAction = 0,
		prepareActionF= -1,
		missileAction= -5, 
		effectAction = 12,
		damageRatio = 2.2,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		subHpLimit = function(lv,damage,probability,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,myBuffers,enemyBuffers)
				local thisProbability   = 1 --(0,1] 生成概率,数值越大,概率越高
				local subHpLimitPercent = 1--生命上限降低百分比（基于伤害）
				if thisProbability > probability then
					return damage * subHpLimitPercent
				else
					return 0
				end
		end,	
	}
SkillManager[1708] =
	{
		name = "金帝焚天阵", --萧薰儿觉醒
		desc = function (lv)
				return "对后排敌人造成300%法术伤害，自身带有异常状态时，额外增加100%法术伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 3,
		runType = 0, 
		bannerType = false, 
		shakable = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 1, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				local thisBuffers ={BUFFER_TYPE_POISON, BUFFER_TYPE_BURN, BUFFER_TYPE_CURSE, BUFFER_TYPE_DECREASE,BUFFER_TYPE_CURELESS}
				for i = 1,#myBuffers do
					for j = 1,#thisBuffers do
						if myBuffers[i] == thisBuffers[j] then
					    return att_all*1.6
						end
					end
				end
				return att_all
			end,
	}
SkillManager[1709] =
	{
		name = "守护之刃", --萧薰儿觉醒
				desc = function (lv)
				return "每个回合行动结束时，回复35%生命" 			
			end,
		type = SkillManager_TYPE_PASSIVE_FINI,

		finishFunc = function(lv,probability) --必须，lv：技能等级；返回：
				local thisProbability    = 1
				local thisAttackPercent  = 0 --[0,1]攻击百分比,谁的回合谁增加攻击
				local thisDefencePercent = 0 --[0,1]防御百分比,谁的回合谁增加防御
				local thisHPPercent      = 0.35 --[0,1]回血百分比,谁的回合谁回复血量
				if thisProbability > probability then
					return thisAttackPercent,thisDefencePercent,thisHPPercent
				else
					return 0,0,0
				end
			end,
	}
SkillManager[1710] =
	{
		name = "金帝焚天斩", --萧薰儿觉醒
		desc = function (lv)
				return "替补上场时释放，对随机3个敌人造成340%法术伤害，增加己方死亡人数乘以30%的攻击力（最大增幅150%）" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ENTER,
		isMana = true, 
		target = SkillManager_MULTI_RANDOM_3, 
		damageRatio = 3.7,
		runType = 0, 
		bannerType = true,
		shout = true,
		prepareActionF= 1, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 5,
		haloAction = 2, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				local thisProbability = 1
				if thisProbability > probability then
					if myDeath > 5 then
						return att_all*2.5
					else
						return att_all*(1+myDeath*0.3)
					end
				else
					return att_all
				end
			end,
	}
SkillManager[1711] =
	{
		name = "神品血脉", --萧薰儿觉醒
		desc = function (lv)
				return "攻击对方时，自身40%物攻属性转化为法攻属性" 			
			end,
		type = SkillManager_TYPE_PASSIVE_TRAN,
		addFunc = function(lv,isMana,phscAtt,manaAtt,probability) --必须，lv：技能等级；isMana：主动技能是否法术；phscAtt：角色的物理攻击；manaAtt：角色的法术攻击；probability：[0,1)随机数
				local thisProbability = 1
				local thisPercent = 0.4 --转化比例
				if thisProbability > probability then
					return thisPercent * (isMana and phscAtt or manaAtt)
				else
					return thisPercent * 0
				end
			end,
	}
SkillManager[1712] =
	{
		name = "陨火玄指", --炎烬
		desc = function (lv)
				return "对前排敌人造成240%法术伤害，80%概率产生伤害值150%的火焰灼烧效果（持续3回合），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 2.4,
		runType = 0, 
		bannerType = false,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 2, 
		effectAction = 12, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.8 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(15,1.5,damage,3) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,	
	}
SkillManager[1713] =
	{
		name = "焱炎焚天", --炎烬
		desc = function (lv)
				return "对全体敌人造成200%法术伤害，80%概率增加150%的火焰灼烧攻击，若目标有灼烧状态，额外增加100%的法术伤害，第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 2,
		runType = 1, 
		bannerType = true,
		shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 12, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				local att_temp = att_all
				local thisProbability = 0.8
				if thisProbability > probability then
					att_temp = att_all*1.5
				else		
					att_temp = att_all
				end
				local thisBuffers = {BUFFER_TYPE_BURN} --攻击增幅触发的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua）
				for i = 1,#enemyBuffers do
					for j = 1,#thisBuffers do
						if enemyBuffers[i] == thisBuffers[j] then
							return att_temp*2
						end
					end
				end
				return att_temp
			end,
	}
SkillManager[1714] =
	{
		name = "焚天大法", --炎烬
		desc = function (lv)
				return "死亡时释放，对所有敌人造成220%法术伤害，80%概率产生伤害值200%的火焰灼烧效果（持续3回合）" 			
			end,
		type = SkillManager_TYPE_ACTIVE_EXIT, 
		isMana = true, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 2.2,
		runType = 0, 
		bannerType = true, 
		shout = true,
		shakable = true,
		prepareActionF= 2, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 1, 
		effectAction = 12, 

		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.8 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(20,2,damage,3) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,	
	}
SkillManager[1715] =
	{
		name = "血魔蚀心雷", --魂天帝
		desc = function (lv)
				return "对敌方全体造成200%法术攻击伤害，100%概率使敌方无法被治疗（持续5次），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 2,
		runType = 0, 
		bannerType = false,
		shout = false,
		shakable = false,
		prepareActionF= 2, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 13, 
		effectAction = 21, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,

		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferCureless(5,5) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[1716] =
	{
		name = "噬灵绝生阵", --魂天帝
		desc = function (lv)
				return "对后排敌人造成240%法术伤害，60%概率使敌人被击晕（失去2个回合行动力），第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 1, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 2.4,
		runType = 0, 
		shout = true,
		shakable = true,
		prepareActionF= 3, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 5, 
		--missileAction= 0, 
		effectAction = 8, 
		haloAction = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,

		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 0.6--[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferStun(1,2) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[1717] =
	{
		name = "毁灭之印", -- 魂天帝
		desc = function (lv)
				return "对血量最少的敌人造成500%法术伤害，无视免疫和伤害减免效果，第2回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 2, 
		start = 2, 
		isMana = true, 
		target = SkillManager_SINGLE_0, 
		damageRatio = 5,
		runType = 0, 
		bannerType = true,
		shout = true,
		prepareActionF= 1, 
		ignoreIMRE = true, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}
	


---------------------------------------------------------------------------------------------------------
	
SkillManager[2000] =
	{
		name = "世界boss技能1",
		desc = function (lv)
				return "攻击全体，无视减免"
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0,
		start = 1,
		isMana = true,
		target = SkillManager_MULTI_ALL,
		runType = 0,
		ignoreIMRE = true,
		attackAction = 0,
		injureAction = 0, --恢复技能 此参数无效
		--prepareActionF= 2,
		--missileAction= -5,
		effectAction = 0,
		damageRatio = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all * 1
			end,
	}
SkillManager[2001] =
	{
		name = "世界boss技能2",
		desc = function (lv)
				return "免疫各种buff" 			
			end,	
		type = SkillManager_TYPE_PASSIVE_IMBF,
		immunityBufferFunc = function(lv,bufferID,probability) --必须，lv：技能等级；bufferID：待检测的bufferID
				local thisProbability = 1
				local thisBufferIDs = {BUFFER_TYPE_FREEZE,BUFFER_TYPE_STUN,BUFFER_TYPE_SEAL,BUFFER_TYPE_POISON,BUFFER_TYPE_BURN,BUFFER_TYPE_CURSE,BUFFER_TYPE_DECREASE,BUFFER_TYPE_CURELESS} --免疫的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua）
				if thisProbability > probability then
					for i = 1,#thisBufferIDs do
						if thisBufferIDs[i] == bufferID then
							return true
						end
					end
				end
				return false
			end,
	}
	
--------------妖尔莫斯穆力战斗专用-------------------------------------------------------------------------------------------
--穆力变身准备技能
SkillManager[3000] = 
	{
		name = "妖火附体",--穆力
		desc = function (lv)
				return "为己方随机2名英雄增加护盾（减少80%攻击伤害，抵挡1次攻击），第3回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 100, 
		start = 1, 
		isMana = false, 
		target = SkillManager_OWN_SELF, 
		damageRatio = 1,
		runType = 0, 
		bannerType = true,
		prepareActionF= 4, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 
		regeFunc = function(lv,att_all) 
				return att_all*1.5
			end,
	}
    --佣兵之神普通技能
	SkillManager[3001] =
		{
		name = "疾风刺", --
		desc = function (lv)
				return "对单个敌人造成100%物理伤害，每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_SINGLE_FRONT, 
		damageRatio = 1,
		runType = 1, 
		--bannerType = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
	}

	--佣兵之魂三连击

	SkillManager[3002] =
	{
		name = "亡魂地刺",
		desc = function (lv)
				return "对后排敌人造成125%物理伤害，第2回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 50, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 1.25,
		runType = 0, 
		animation = "",
		--animation = "image/fight_skill_name_dcfy.png", 
		shout = true,
		shakable = true,
		prepareActionF= 3, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 5, 
		--missileAction= 0, 
		effectAction = 8, 
		haloAction = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,dstHP,myDeath,enemyDeath,probability,buffers) 
				return 6000
			end,
	}
	--佣兵之魂三连击

	SkillManager[3003] =
		{
		name = "亡魂地刺",
		desc = function (lv)
				return "对后排敌人造成125%物理伤害，第2回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 1.25,
		runType = 0, 
		animation = "",
		--animation = "image/fight_skill_name_dcfy.png", 
		shout = true,
		shakable = true,
		prepareActionF= 3, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 5, 
		--missileAction= 0, 
		effectAction = 8, 
		haloAction = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,dstHP,myDeath,enemyDeath,probability,buffers) 
				return 7000
			end,
	}
	
	
	--药老入场加血
	SkillManager[3005] =
	{
		name = "如露含光", --药老
		desc = function (lv)
				return "治疗己方血量最少的英雄（120%），第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 50, 
		start = 1, 
		isMana = true, 
		target = SkillManager_OWN_OTHER, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 3, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 
		regeFunc = function(lv,att_all) 
				return 25000
			end,
	}
	--穆力召唤术
	SkillManager[3006] =
	{
		name = "复活术", --药老
		desc = function (lv)
				return "治疗己方血量最少的英雄（120%），第2回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 1, 
		isMana = true, 
		target = SkillManager_OWN_OTHER, 
		damageRatio = 1,
		runType = 0, 
		bannerType = true, 
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 3, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 19, 
		regeFunc = function(lv,att_all) 
				return 25000
			end,
	}
	-- 净莲妖火 变场景技能 
	SkillManager[3011] =
	{
		name = "人间炼狱",
		desc = function (lv)
				return "全屏幕" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 5000, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 1,
		runType = 0, 
		bannerType = true,
		--animation = "image/fight_skill_name_round.png", 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		prepareActionF= -1,
		bgAction = -1,
		missileAction= -9, --可选，[-8,5]，导弹号，负数为全屏导弹，非负数为单体导弹，否则没有导弹
		effectAction = 12, 		
		shakable = true,
		--prepareActionB = 0, 
		--missileAction= 1, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all * 1.2
			end,
	}

	--穆力高级刺
	SkillManager[3012] =
	{
		name = "亡魂地刺",
		desc = function (lv)
				return "对后排敌人造成125%物理伤害，第2回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 1.25,
		runType = 3, 
		--animation = "",
		--animation = "image/fight_skill_name_dcfy.png", 
		shout = true,
		shakable = true,
		prepareActionF= 9, 
		prepareActionB= 10, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= -12, 
		effectAction = 20, 
		blood = true,
		--haloAction = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,dstHP,myDeath,enemyDeath,probability,buffers) 
				return 6000
			end,
			
	}
	
	SkillManager[3013] =
	{
	name = "亡魂地刺",
		desc = function (lv)
				return "对后排敌人造成125%物理伤害，第2回合释放，冷却时间2回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 0, 
		start = 3, 
		isMana = false, 
		target = SkillManager_MULTI_ALL, 
		damageRatio = 1.25,
		runType = 3, 
		--animation = "",
		--animation = "image/fight_skill_name_dcfy.png", 
		shout = true,
		shakable = true,
		prepareActionF= -1,
		bgAction = -1,
		blood = true,
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 2, 
		missileAction= -13, 
		effectAction = 20, 
		--haloAction = 1,
		attackFunc = function(lv,att_all,isMana,srcHP,dstHP,myDeath,enemyDeath,probability,buffers) 
				return 6000
			end,
	}

	SkillManager[3050] =
	{
		name = "龙皇真身", --世界BOSS免疫BUFF
		desc = function (lv)
				return "对所有负面状态免疫（中毒、灼烧、封印等）" 			
			end,
		type = SkillManager_TYPE_PASSIVE_IMBF,
		immunityBufferFunc = function(lv,bufferID,probability) --必须，lv：技能等级；bufferID：待检测的bufferID
				local thisProbability = 1
				local thisBufferIDs = {BUFFER_TYPE_POISON, BUFFER_TYPE_BURN, BUFFER_TYPE_CURSE, BUFFER_TYPE_DECREASE,BUFFER_TYPE_FREEZE,BUFFER_TYPE_STUN,BUFFER_TYPE_SEAL,BUFFER_TYPE_CURELESS} --免疫的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua） --免疫的Buffer列表(逗号,分割)，BUFFER_TYPE_****（查看fightbuffer.lua）
				if thisProbability > probability then
					for i = 1,#thisBufferIDs do
						if thisBufferIDs[i] == bufferID then
							return true
						end
					end
				end
				return false
			end,
	}

	SkillManager[3051] =
	{
		
		name = "逆天而行",--魂天帝世界BOSS，1回合，加盾
		desc = function (lv)
				return "为自身增加护盾（减少50%攻击伤害，抵挡10000次攻击），第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 4, 
		start = 1, 
		isMana = false, 
		target = SkillManager_OWN_SELF, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = false,
		--shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferReduction(10000,10000,0.8,0) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}

	SkillManager[3052] = 
	{
		name = "逆天而行",--魂天帝世界BOSS，2回合，前排
		desc = function (lv)
				return "对后排敌人造成180%物理伤害，100%概率使对方虚弱（减少95%攻击力，持续1次）第1回合释放，冷却时间3回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 4, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false, 
		shout = true,
		shakable = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 10, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
							return att_all
					end,
		
		
	}

	SkillManager[3053] =
	{
		name = "逆天而行", --魂天帝世界BOSS，3回合，纵列
		desc = function (lv)
				return "对纵列敌人造成220%法术伤害，100%概率产生伤害50%的灼烧效果（持续2次），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 4, 
		start = 3, 
		isMana = true, 
		target =SkillManager_MULTI_COLS, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = false,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 1, 
		effectAction = 0, 

		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,

			
	}

		SkillManager[3054] =
	{
		name = "逆天而行", --魂天帝世界BOSS，4回合，纵列
		desc = function (lv)
				return "对纵列敌人造成220%法术伤害，100%概率产生伤害50%的灼烧效果（持续2次），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 4, 
		start = 4, 
		isMana = false, 
		target =SkillManager_MULTI_COLS, 
		damageRatio = 1,
		runType = 0, 
		shout = true,
		bannerType = false,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 1, 
		effectAction = 0, 

		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,

			
	}

		SkillManager[3055] =
	{
		name = "逆天而行", --魂天帝世界BOSS，5回合，纵列
		desc = function (lv)
				return "对纵列敌人造成220%法术伤害，100%概率产生伤害50%的灼烧效果（持续2次），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 4, 
		start = 5, 
		isMana = true, 
		target =SkillManager_MULTI_COLS, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = false,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 1, 
		effectAction = 0, 

		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,

	}

	SkillManager[3056] =
	{
		name = "势不可挡",--古烈世界BOSS，物理免疫
		desc = function (lv)
				return "受到物理攻击时有60%概率免疫伤害" 			
			end,	
		type = SkillManager_TYPE_PASSIVE_IMAT,
		immunityAttackFunc = function(lv,isMana,probability) --必须，lv：技能等级；isMana：主动技能是否法术；probability：[0,1)随机数
				local thisIsMana = false  --true:法术免疫；false:物理免疫
				local thisProbability = 1 --[0,1]免疫概率，数值越大，概率越高
				return thisIsMana == isMana and thisProbability > probability
			end,
	}

		SkillManager[3057] = 
	{
		name = "势不可挡",--古烈世界BOSS，1回合，后排
		desc = function (lv)
				return "对后排敌人造成180%物理伤害，100%概率使对方虚弱（减少95%攻击力，持续1次）第1回合释放，冷却时间3回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 4, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false, 
		shout = true,
		shakable = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 8, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
							return att_all
					end,
		
	}

	SkillManager[3058] = 
	{
		name = "势不可挡",--古烈世界BOSS，2回合，前排
		desc = function (lv)
				return "对后排敌人造成180%物理伤害，100%概率使对方虚弱（减少95%攻击力，持续1次）第1回合释放，冷却时间3回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 4, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true, 
		--shout = true,
		shakable = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 8, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
							return att_all
					end,
		
	}

		SkillManager[3059] =
	{
		name = "势不可挡", --古烈世界BOSS，3回合，纵列
		desc = function (lv)
				return "对纵列敌人造成220%法术伤害，100%概率产生伤害50%的灼烧效果（持续2次），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 4, 
		start = 3, 
		isMana = false, 
		target =SkillManager_MULTI_COLS, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false,
		shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 8, 
		effectAction = 0, 

		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,

			
	}

			SkillManager[3060] =
	{
		name = "势不可挡", --古烈世界BOSS，4回合，纵列
		desc = function (lv)
				return "对纵列敌人造成220%法术伤害，100%概率产生伤害50%的灼烧效果（持续2次），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 4, 
		start = 4, 
		isMana = true, 
		target =SkillManager_MULTI_COLS, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = false,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 8, 
		effectAction = 0, 

		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,

			
	}

			SkillManager[3061] =
	{
		name = "势不可挡", --古烈世界BOSS，5回合，纵列
		desc = function (lv)
				return "对纵列敌人造成220%法术伤害，100%概率产生伤害50%的灼烧效果（持续2次），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 4, 
		start = 5, 
		isMana = false, 
		target =SkillManager_MULTI_COLS, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false,
		shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 8, 
		effectAction = 0, 

		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,

			
	}


		SkillManager[3062] =
	{
		name = "岂有此理",--妖暝世界BOSS，法术免疫
		desc = function (lv)
				return "受到物理攻击时有60%概率免疫伤害" 			
			end,	
		type = SkillManager_TYPE_PASSIVE_IMAT,
		immunityAttackFunc = function(lv,isMana,probability) --必须，lv：技能等级；isMana：主动技能是否法术；probability：[0,1)随机数
				local thisIsMana = true  --true:法术免疫；false:物理免疫
				local thisProbability = 1 --[0,1]免疫概率，数值越大，概率越高
				return thisIsMana == isMana and thisProbability > probability
			end,
	}

		SkillManager[3063] = 
	{
		name = "岂有此理",--妖暝世界BOSS，1回合，纵列
		desc = function (lv)
				return "对后排敌人造成180%物理伤害，100%概率使对方虚弱（减少95%攻击力，持续1次）第1回合释放，冷却时间3回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 4, 
		start = 1, 
		isMana = false, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false, 
		shout = true,
		shakable = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 6, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
							return att_all
					end,
		
	}

	SkillManager[3064] = 
	{
		name = "岂有此理",--妖暝世界BOSS，2回合，纵列
		desc = function (lv)
				return "对后排敌人造成180%物理伤害，100%概率使对方虚弱（减少95%攻击力，持续1次）第1回合释放，冷却时间3回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 4, 
		start = 2, 
		isMana = true, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true, 
		--shout = true,
		shakable = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 6, 
		effectAction = 0, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
							return att_all
					end,
		
	}

		SkillManager[3065] =
	{
		name = "岂有此理", --妖暝世界BOSS，3回合，纵列
		desc = function (lv)
				return "对纵列敌人造成220%法术伤害，100%概率产生伤害50%的灼烧效果（持续2次），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 4, 
		start = 3, 
		isMana = false, 
		target =SkillManager_MULTI_COLS, 
		damageRatio = 1,
		runType = 0,
		shout = true,
		bannerType = false,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 6, 
		effectAction = 0, 

		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,

			
	}

			SkillManager[3066] =
	{
		name = "岂有此理", --妖暝世界BOSS，4回合，后排
		desc = function (lv)
				return "对纵列敌人造成220%法术伤害，100%概率产生伤害50%的灼烧效果（持续2次），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 4, 
		start = 4, 
		isMana = true, 
		target =SkillManager_MULTI_ROW_2, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = false,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 6, 
		effectAction = 0, 

		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,

			
	}

		SkillManager[3067] =
	{
		name = "岂有此理", --妖暝世界BOSS，5回合，前排
		desc = function (lv)
				return "对纵列敌人造成220%法术伤害，100%概率产生伤害50%的灼烧效果（持续2次），每回合释放" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 4, 
		start = 5, 
		isMana = false, 
		target =SkillManager_MULTI_ROW_1, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false,
		shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 6, 
		effectAction = 0, 

		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,

			
	}

	SkillManager[3068] =
	{
		name = "万劫不复", --北龙王 封印两回合，1回合
		desc = function (lv)
				return "65%概率封印随机2个敌人（失去1个回合行动能力），第2回合释放，冷却时间1个回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 5, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		--shout = true,
		prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 4, 
		--missileAction= 0, 
		effectAction = 20, 
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferSeal(2,2) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,	
	}
	SkillManager[3069] =
	{
		name = "万劫不复", --北龙王 晕眩后排，2回合
		desc = function (lv)
				return "对前排敌人造成50%法术攻击伤害，50%概率击晕目标（持续2回合），第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 5, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 1.2,
		runType = 0, 
		--bannerType = true,
		--shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 4, 
		effectAction = 10, 
		

		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1--[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferStun(2,2) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}

	SkillManager[3070] =
	{
		name = "万劫不复", --北龙王 前排3回合
		desc = function (lv)
				return "对随机3个敌人造成180%法术伤害，50%概率封印目标1回合，第2回合释放，冷却时间1个回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 5, 
		start = 3, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 1.8,
		runType = 0, 
		bannerType = false,
		shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 14, 
		effectAction = 21, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		
	}

	SkillManager[3071] =
	{
		name = "万劫不复", --北龙王 晕眩后排，4回合
		desc = function (lv)
				return "对前排敌人造成50%法术攻击伤害，50%概率击晕目标（持续2回合），第1回合释放，冷却时间1回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 5, 
		start = 4, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true,
		--shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 0, 
		injureAction = 0, 
		missileAction= 4, 
		effectAction = 10, 
		

		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1--[0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferFreeze(2,2) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,
	}
SkillManager[3072] =
	{
		name = "万劫不复", --北龙王 后排5回合
		desc = function (lv)
				return "对随机3个敌人造成180%法术伤害，50%概率封印目标1回合，第2回合释放，冷却时间1个回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 5, 
		start = 5, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 1.8,
		runType = 0, 
		bannerType = false,
		shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 14, 
		effectAction = 21, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		
	}

	SkillManager[3073] =
	{
		name = "万劫不复", --北龙王 后排5回合
		desc = function (lv)
				return "对随机3个敌人造成180%法术伤害，50%概率封印目标1回合，第2回合释放，冷却时间1个回合" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 5, 
		start = 6, 
		isMana = false, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false,
		shout = true,
		--prepareActionF= 0, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 14, 
		effectAction = 21, 
		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		
	}

	SkillManager[3074] =
	{
		name = "送你去投胎", --炎烬 世界BOSS 1回合前排BUFF
		desc = function (lv)
				return "死亡时释放，对所有敌人造成200%法术伤害，90%概率产生伤害100%的灼烧效果（持续1回合）" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 7, 
		start = 1, 
		isMana = true, 
		target = SkillManager_MULTI_ROW_1, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true, 
		shout = true,
		shakable = true,
		prepareActionF= 2, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 1, 
		effectAction = 12, 

		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(1000,1000,damage,9000000000) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,	
	}

	SkillManager[3075] =
	{
		name = "送你去投胎", --炎烬 世界BOSS 2回合后排直伤
		desc = function (lv)
				return "死亡时释放，对所有敌人造成200%法术伤害，90%概率产生伤害100%的灼烧效果（持续1回合）" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 7, 
		start = 2, 
		isMana = false, 
		target = SkillManager_MULTI_ROW_2, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false, 
		shout = true,
		shakable = true,
		prepareActionF= 2, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 1, 
		effectAction = 12, 

		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all*1000000000
			end,
		
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(1000,1000,damage,9000000000) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,	
	}

	SkillManager[3076] =
	{
		name = "送你去投胎", --炎烬 纵列BUFF
		desc = function (lv)
				return "死亡时释放，对所有敌人造成200%法术伤害，90%概率产生伤害100%的灼烧效果（持续1回合）" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 7, 
		start = 3, 
		isMana = true, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true, 
		--shout = true,
		shakable = true,
		prepareActionF= 2, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 1, 
		effectAction = 12, 

		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(1000,1000,damage,9000000000) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,	
	}

	SkillManager[3077] =
	{
		name = "送你去投胎", --炎烬 纵列直伤
		desc = function (lv)
				return "死亡时释放，对所有敌人造成200%法术伤害，90%概率产生伤害100%的灼烧效果（持续1回合）" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 7, 
		start = 4, 
		isMana = false, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false, 
		shout = true,
		shakable = true,
		prepareActionF= 2, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 1, 
		effectAction = 12, 

		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all*1000000000
			end,
		
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(1000,1000,damage,9000000000) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,	
	}


		SkillManager[3078] =
	{
		name = "送你去投胎", --炎烬 纵列BUFF
		desc = function (lv)
				return "死亡时释放，对所有敌人造成200%法术伤害，90%概率产生伤害100%的灼烧效果（持续1回合）" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 7, 
		start = 5, 
		isMana = true, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true, 
		--shout = true,
		shakable = true,
		prepareActionF= 2, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 1, 
		effectAction = 12, 

		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(1000,1000,damage,9000000000) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,	
	}

		SkillManager[3079] =
	{
		name = "送你去投胎", --炎烬 纵列直伤
		desc = function (lv)
				return "死亡时释放，对所有敌人造成200%法术伤害，90%概率产生伤害100%的灼烧效果（持续1回合）" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 7, 
		start = 6, 
		isMana = false, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false, 
		shout = true,
		shakable = true,
		prepareActionF= 2, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 1, 
		effectAction = 12, 

		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all*1000000000
			end,
		
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(1000,1000,damage,9000000000) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,	
	}

		SkillManager[3080] =
	{
		name = "送你去投胎", --炎烬 纵列BUFF
		desc = function (lv)
				return "死亡时释放，对所有敌人造成200%法术伤害，90%概率产生伤害100%的灼烧效果（持续1回合）" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 7, 
		start = 7, 
		isMana = true, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 1,
		runType = 0, 
		--bannerType = true, 
		--shout = true,
		shakable = true,
		prepareActionF= 2, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 1, 
		effectAction = 12, 

		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all
			end,
		
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(1000,1000,damage,9000000000) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,	
	}

		SkillManager[3081] =
	{
		name = "送你去投胎", --炎烬 纵列直伤
		desc = function (lv)
				return "死亡时释放，对所有敌人造成200%法术伤害，90%概率产生伤害100%的灼烧效果（持续1回合）" 			
			end,
		type = SkillManager_TYPE_ACTIVE_ROUND + 7, 
		start = 8, 
		isMana = false, 
		target = SkillManager_MULTI_COLS, 
		damageRatio = 1,
		runType = 0, 
		bannerType = false, 
		shout = true,
		shakable = true,
		prepareActionF= 2, 
		ignoreIMRE = false, 
		attackAction = 1, 
		injureAction = 0, 
		missileAction= 1, 
		effectAction = 12, 

		attackFunc = function(lv,att_all,isMana,srcHP,srcHPMax,dstHP,dstHPMax,myDeath,enemyDeath,probability,myBuffers,enemyBuffers) 
				return att_all*1000000000
			end,
		
		setupBuffer = function(lv,att,damage,probability) --可选,技能附带的Buffer,lv：技能等级；att：角色的基础攻击；
				local thisProbability = 1 --(0,1] 生成概率,数值越大,概率越高
				if thisProbability > probability then
					return createBufferBurn(1000,1000,damage,9000000000) --createBuffer*****参考fighterbuffer.lua
				else
					return nil
				end
			end,	
	}	