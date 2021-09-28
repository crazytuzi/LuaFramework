------------------------------------------------------
--Added by mxr 2015-4-14 17:02:09
-----------------------------------------------------
require("logic/entity/i3k_entity_def");
-- Trap state  陷阱基础态
eSTrapBase	= 10000;
eSTrapLocked	= 10001;	--未激活状态
eSTrapActive	= 10002;	--激活未触发状态
eSTrapAttack	= 10003;	--激活触发状态
eSTrapClosed	= 10004;	--关闭/损坏状态
eSTrapsInjured  = 10005;

eSTrapMine = 10101;	--资源点专用状态

-- Trap state  陷阱类型
eEntityTrapType_General		= 1;	-- 无触发效果类型
eEntityTrapType_Trigger		= 2;    -- 开关触发器类型 
eEntityTrapType_Barrier		= 3;    -- 屏障类型 active with trigger 
eEntityTrapType_AOE			= 4;    -- AOE 技能类型(对敌方)
eEntityTrapType_Reset		= 5;    -- 陷阱重置器（测试用）
eEntityTrapType_Broken		= 6;    -- 可破坏类 
eEntityTrapType_Boomer		= 7;    -- 可破坏类(对己方) 
eEntityTrapType_ResourcePoint	= 8;    -- 资源点类型 

-- 状态转换条件组
eTrapTransAreaClear	= 1;	--怪物清除
eTrapTransLinkActive	= 2;	--区域关联

-- 触发条件组
eTrapActiveClick	= 1;	--点击触发
eTrapActiveAttack	= 2;	--攻击触发

