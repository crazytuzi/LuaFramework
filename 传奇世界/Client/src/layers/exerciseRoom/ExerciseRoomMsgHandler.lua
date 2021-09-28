--练功房

local function skillTestHurt(buff)
	local data = g_msgHandlerInst:convertBufferToTable("SkillPkTestHurt", buff)
	dump(data,"skillTestHurt")
	if G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isExerciseRoom and G_MAINSCENE.map_layer.exerciseDamgeShow then
 		G_MAINSCENE.map_layer.exerciseDamgeShow:showDamge(data)
 	end
end







--攻击伤害下发
g_msgHandlerInst:registerMsgHandler(EVENT_EXERCISEROOM, skillTestHurt)