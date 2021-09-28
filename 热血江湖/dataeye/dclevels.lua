DCLevels = { };

--[[进入头卡或者开始关卡
	levelId:关卡名称或者ID String类型
]]
function DCLevels.begin(levelId)
	if i3k_game_data_eye_valid() then
		DCLuaLevels:begin(levelId);
	end
end

--[[成功完成关卡
	levelId:关卡名称或者ID String类型
]]
function DCLevels.complete(levelId)
	if i3k_game_data_eye_valid() then
		DCLuaLevels:complete(levelId);
	end
end

--[[关卡失败
	levelId:关卡名称或者ID String类型
]]
function DCLevels.fail(levelId, failPoint)
	if i3k_game_data_eye_valid() then
		DCLuaLevels:fail(levelId, failPoint);
	end
end

return DCLevels;
