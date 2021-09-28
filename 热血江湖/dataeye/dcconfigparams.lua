DCConfigParams = { };

--[[在线参数更新接口，在进入游戏时调用，该接口会将参数更新到本地并保存起来，在需要获取参数时调用getParams获取即可]]
function DCConfigParams.update()
	if i3k_game_data_eye_valid() then
		DCLuaConfigParams:update();
	end
end

--[[获取参数接口
	key:参数ID String类型
	defaultValue:参数默认值，可以为String\Number\bool三种类型
]]
function DCConfigParams.getParamNumber(key, defaultValue)
	if i3k_game_data_eye_valid() then
		return DCLuaConfigParams:getParameter(key, defaultValue);
	end
end

function DCConfigParams.getParamString(key, defaultValue)
	if i3k_game_data_eye_valid() then
		return DCLuaConfigParams:getParameter(key, defaultValue);
	end
end

function DCConfigParams.getParamBool(key, defaultValue)
	if i3k_game_data_eye_valid() then
		return DCLuaConfigParams:getParameter(key, defaultValue);
	end
end

return DCConfigParams;
