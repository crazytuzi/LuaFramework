----------------------------------------------------------------
local require = require

require("i3k_global");

-- 技能分组
eSG_Attack		= 0;	-- 普攻
eSG_Skill		= 1;	-- 技能
eSG_TriSkill	= 2;	-- 触发技能

-- 光环类型
e_AURA_Type_O	= 1		-- 己方
e_AURA_Type_E	= 2 	-- 敌方


-- 伤害类型
eSD_ATN			= 1; -- 物理伤害
eSD_FIRE		= 2; -- 法术伤害(火焰)
eSD_FROST		= 3; -- 法术伤害(冰霜)
eSD_THUNDER		= 4; -- 法术伤害(雷电)
eSD_POISON		= 5; -- 法术伤害(毒素)
eSD_HOLY		= 6; -- 法术伤害(神圣)

-- 技能范围类型
eSScopT_Owner	= 1;	-- 自身
eSScopT_Single	= 2;	-- 单点
eSScopT_CricleO	= 3;	-- 自身圆心
eSScopT_CricleT	= 4;	-- 目标圆心
eSScopT_SectorO	= 5;	-- 自身前方扇形
eSScopT_RectO	= 6;	-- 自身前方矩形
eSScopT_MulC	= 7;	-- 自身周围多个圆形区域
eSScopT_Ellipse = 8;	-- 自身周围椭圆区域


-- 特化公式定义
eSpecFunc_Cast	= 1;	-- 引导

-- 技能释放阶段
eSStep_Unknown	= 0;
eSStep_Spell	= 1;
eSStep_End		= 2;

-- 心法改变子事件类型
eSCEvent_time = 1 --伤害子时间时间点
eSCEvent_odds = 2 --伤害子事件概率
eSCEvent_arg1 = 3 --伤害子事件伤害乘数(废弃)
eSCEvent_arg2 = 4 --伤害子事件伤害加数(废弃)
eSCEvent_sodds1 = 5 --状态子事件一概率
eSCEvent_sodds2 = 6 --状态子事件二概率

-- 心法改变通用属性类型
eSCCommon_time = 1;		-- 技能时长
eSCCommon_cooltime = 2;		-- 冷却时间
eSCCommon_rushdist = 3;		-- 更改冲锋距离
eSCCommon_shiftodds = 4;	-- 更改击退概率
eSCCommon_casttime = 5;		-- 延长引导技能持续时间
eSCCommon_auratime = 6;		-- 更改光环存在时间
eSCCommon_movespeed = 7;		-- 更改召唤物的移动速度

-- 心法改变值类型
eSCValueType_add = 0	-- 相加
eSCValueType_mul = 1 -- 相乘
eSCValueType_instead = 3 -- 取代

-- 心法改变类型
eSCType_Event = 0	-- 事件
eSCType_Common = 1	-- 基础
