------------------------------------------------------
local require = require
eAiTypeTrigger		=  0;
eAITypeEvent		=  1;
------------------------------------------------------
eTEventSkill		=  1;
eTEventDead			=  2;
eTEventSyncope		=  3;
eTEventHit			=  4;
eTEventDamage		=  5;
eTEventHeal			=  6;
eTEventIdle			=  7;
eTEventAttack		=  8; -- 攻击、伤害结算之前; 可能会影响结算数值
eTEventBuff			=  9; -- BUFF
eTEventDodge		=  10; -- 闪避
eTEventToHit		=  11; -- 攻击
eTEventMiss			=  12; -- 未命中
eTEventChange		=  13; -- 进入变身和结束变身


eTEventFirst		=  1;
eTEventLast			=  13;

------------------------------------------------------
-- 触发条件
eTFuncDead					=  1; -- 死亡N人
eTFuncODead					=  2; -- 自己死亡
eTFuncUseSkill				=  3; -- 释放技能
eTFuncHP					=  4; -- 生命值
eTFuncDirectDamage			=  5; -- 受到N次直接伤害
eTFuncDamageVal				=  6; -- 受到一定伤害
eTFuncEnemies				=  7; -- 附加有敌方
eTFuncLoseHP				=  8; -- 损失气血
eTFuncIdle					=  9; -- 待机
eTFuncInDirectDamage		= 10; -- 受到N次间接伤害
eTFuncTick					= 11; -- 每隔N秒
eTFuncDamageClosing			= 12; --每次伤害/治疗，进行结算时
eTFuncBuff					= 13; -- BUFF
eTFuncDodge					= 14; -- 闪避
eTFuncProcessDirectDamage	= 15; -- 造成N次直接伤害
eTFuncHPPercentOnDamage		= 16; -- 当血量指定指定比例时受到伤害时（每次）（配置100%表示任意伤害）
eTFuncHPPercentToDamage		= 17; -- 对血量低于X%的单位造成伤害结算时 大于或小于（0小于，1大于）
eTFuncMiss					= 18; -- 未命中
eTFuncStatusToDamage		= 19; -- 对持有指定状态的单位进行伤害结算时
eTFuncIsChange 				= 20; --进入变身&结束变身	触发类型：（1：进入变身，2：结束变身，3：全部）
eTFuncSufferDmg 			= 21; --当受到伤害时（需要把伤害值传给触发行为）
eTFuncBreakHiding   		= 22; --主动施放技能打破隐身时（需要把技能信息传递给触发行为）
eTFuncStatusByDamage		= 23; -- 自己持有某状态时,受到伤害结算时	 伤害类型(1: 伤害, 2: 治疗)


eTFuncFirst			=  1;
eTFuncLast			= 23;

------------------------------------------------------
--触发行为
eTBehaviorTalk		=	1; -- 对白
eTBehaviorSkill		=	2; -- 使用技能
eTBehaviorBuff		=	3; -- 释放BUFF
eTBehaviorAction	=	4; -- 动作
eTBehaviorChgDmgVal	=	5; -- 修改伤害修正
eTBehaviorDecDmg	=	6; -- 被打者减少伤害修正
eTBehaviorSkillCoolDown	=  7; -- 加快指定技能冷却
eTBehaviorRecoverHp	=	8; --根据受到伤害，回复气血
eTBehaviorAddDmg 	= 11 --根据攻击者属性增加本次结算伤害


eTBehaviorFirst		=  1;
eTBehaviorLast		=  11;

------------------------------------------------------
