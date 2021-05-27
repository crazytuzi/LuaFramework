ClientTaskMenuType = {
	MoveNpc = 1, -- 移动到npc
	OpenView = 2, -- 打开面板
}
ClientTaskMenuCfg = {
	[1] = {title="万兽谱",type = ClientTaskMenuType.MoveNpc, scene_id = 5, x = 78, y = 72, npc_id = 170, view_name = "", index_name = "",tel_id = 135},
	[2] = {title="石墓烧猪",type = ClientTaskMenuType.MoveNpc, scene_id = 4, x = 49, y = 67, npc_id = 133, view_name = "", index_name = "",tel_id = 108},
	[3] = {title="屠龙深渊",type = ClientTaskMenuType.MoveNpc, scene_id = 4, x = 47, y = 73, npc_id = 107, view_name = "", index_name = "",tel_id = 107},
	[4] = {title="材料副本",type = ClientTaskMenuType.MoveNpc, scene_id = 5, x = 75, y = 61, npc_id = 104, view_name = "", index_name = "",tel_id = 232},
	[5] = {title="血战到底",type = ClientTaskMenuType.MoveNpc, scene_id = 5, x = 75, y = 78, npc_id = 172, view_name = "", index_name = "",tel_id = 125},
	[6] = {title="答题活动",type = ClientTaskMenuType.MoveNpc, scene_id = 4, x = 54, y = 70, npc_id = 171, view_name = "", index_name = "",tel_id = 123},
	[7] = {title="锁妖冢",type = ClientTaskMenuType.MoveNpc,scene_id = 5, x = 73, y = 75, npc_id = 131, view_name = "", index_name = "",tel_id = 203},
	[8] = {title="装备副本",type = ClientTaskMenuType.OpenView,scene_id = 1, x = 1, y = 1, npc_id = 123, view_name = "Boss", index_name = "boss_fuben_equipment"},
	[9] = {title="野外挂机",type = ClientTaskMenuType.MoveNpc,scene_id = 5, x = 76, y = 70, npc_id = 100, view_name = "", index_name = "",tel_id = 109},
	[10] = {title="玛雅神殿",type = ClientTaskMenuType.MoveNpc,scene_id = 5, x = 79, y = 65, npc_id = 132, view_name = "", index_name = "",tel_id = 202},
	[11] = {title="BOSS之家",type = ClientTaskMenuType.MoveNpc, scene_id = 5, x = 82, y = 68, npc_id = 134, view_name = "", index_name = "",tel_id = 201,task_id = {705,706}},
	[12] = {title="装备合成",type = ClientTaskMenuType.OpenView, scene_id = 5, x = 73, y = 80, npc_id = 143, view_name = "Equipment", index_name = "equipment_compound"},
	[13] = {title="伏魔任务",type = ClientTaskMenuType.MoveNpc,scene_id = 5, x = 76, y = 62, npc_id = 103, view_name = "", index_name = "",tel_id = 150},
}

--定义特殊的任务id,打开对应的面板,括号内为id,view_name为模块名称,index_name为标签页名称
ClientTaskOpenViewByIdCfg = 
{
	[8001] = {view_name = "Activity", index_name = "activity_target",act_id = 14},
	[8002] = {view_name = "Activity", index_name = "activity_target",act_id = 5},
	--[8003] = {view_name = "Activity", index_name = "activity_target"},
	[8004] = {view_name = "Activity", index_name = "activity_target",act_id = 35},
}

ClientTaskComplete = {
	task_id = 706 -- 最后一个主线任务的任务Id
}
