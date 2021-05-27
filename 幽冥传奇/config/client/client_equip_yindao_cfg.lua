ClientYinDaiIconList = {
	---- 新手训练营
	--{
	--	res = "46",		--
	-- 	view_pos = nil, -- 图标打开类名（view_def查看), 如果需要传送NPC设为nil
	-- 	npc_id = 223, 
	--  	check_func = "CondId115",
    --
	--},
    --
	--{
	--	res = "01",      -- 图标id 
	--	view_pos = ViewDef.Boss, 			-- 图标打开类名（view_def查看), 如果需要传送NPC设为nil
	--	check_func = "CondId115"
	--},
	{
		res = "47",      -- 激战BOSS
		view_pos = "NewlyBossView#Wild#MayaBoss", 			-- 图标打开类名（view_def查看), 如果需要传送NPC设为nil
		check_func = "CondId78"
	},		
	--{
	--	res = "18",      -- 首充
	--	view_pos = "ChargeFirst", 			-- 图标打开类名（view_def查看), 如果需要传送NPC设为nil
	--	check_func = "CondId51",
	--	is_need_Info = true, --需要特殊判断是否开放
	--},
	-- {
	-- 	res = "02",      -- 探索宝藏
	-- 	view_pos = "Explore", 			-- 图标打开类名（view_def查看), 如果需要传送NPC设为nil
	-- 	--npc_id = 229, 
	-- 	check_func = "CondId24"
	-- },

}

ClientVipTaskId = 25