function load_scenesrv_script()
	-- Utils
	dofile("./script/utils/Utils.lua")
	--cfg
	dofile("./data/config/ExtremityConfig.lua")
	dofile("./data/config/MonkeytimeConfig.lua")
	dofile("./data/config/CampAwardConfig.lua")
	dofile("./script/guild/UnionCityWarConfig.lua")
	dofile("./script/guild/UnionWarConfig.lua")
	dofile("./data/config/ZhuzairoadConfig.lua")
	dofile("./data/config/JiguanConfig.lua")
	
	--北仓界
	dofile("./data/config/BeicangjiemonsterConfig.lua")
	dofile("./data/config/BeicangjieConfig.lua")
	--守卫北仓
	dofile("./data/config/ShouweibeicangConfig.lua")
	dofile("./data/config/BeicanggroupConfig.lua")
	
	--灵路试炼
	dofile("./data/config/LiushuifubenConfig.lua")
	--常量表
	dofile("./data/config/ConstsConfig.lua")

	--极限副本
	dofile("./data/config/LimitfightConfig.lua")	
	dofile("./data/config/LimitrewardConfig.lua")
	--跨服BOSS
	dofile("./data/config/KuafubossConfig.lua")

	--抢门
	dofile("./data/config/SnatchdoorConfig.lua")	
	--个人boss
	dofile("./data/config/PersonalbossConfig.lua")
	--骑战副本
	dofile("./data/config/RidedungeonConfig.lua")
	-- 物品脚本
    dofile("./script/item/ItemUse.lua")

    -- AI脚本
    dofile("./script/ai/AICombat.lua")
	dofile("./script/ai/AI.lua")

	--挑战副本
	dofile("./data/config/TiaozhanfubenConfig.lua")
	-- 怪物脚本
	dofile("./data/config/MonsterConfig.lua")
	-- 金币BOSS
	dofile("./data/config/GoldbossConfig.lua")
	dofile("./data/config/GoldbossparConfig.lua")
	-- 任务副本BOSS
	dofile("./data/config/QuestdungeonConfig.lua")
	-- 抢宝箱
	dofile("./data/config/TreasureboxConfig.lua")
	-- 怪物位置
	dofile("./data/config/PositionConfig.lua")
	--跨服任务
	dofile("./data/config/KuafuscenebossConfig.lua")
	--讨伐任务
	dofile("./data/config/TaofaConfig.lua")
	--诛仙阵
	dofile("./data/config/ZhuxianzhenConfig.lua")
	--牧野之战
	dofile("./data/config/MuyewarConfig.lua")
	
	dofile("./data/config/OpenservercomConfig.lua")
end

------------------------------------------------------------------------------------------------------------------

load_scenesrv_script()
