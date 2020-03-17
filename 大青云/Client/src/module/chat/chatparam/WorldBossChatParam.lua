--[[
世界Boss
参数:type,活动id
将活动id解析为世界Boss名
lizhuangzhuang
2015年2月16日17:04:27
]]
_G.classlist['WorldBossChatParam'] = 'WorldBossChatParam'
_G.WorldBossChatParam = setmetatable({},{__index=ChatParam});
WorldBossChatParam.objName = 'WorldBossChatParam'
function WorldBossChatParam:GetType()
	return ChatConsts.ChatParam_WorldBoss;
end

function WorldBossChatParam:DecodeToText(paramStr,withLink)
	local params = self:Decode(paramStr);
	if params[1] then
		local acvitityId = toint(params[1]);
		local activityCfg = t_activity[acvitityId];
		if not activityCfg then return ""; end
		if activityCfg.type ~= ActivityConsts.T_WorldBoss then
			return "";
		end
		local worldBossCfg = t_worldboss[activityCfg.param1];
		if not worldBossCfg then return ""; end
		local monsterCfg = t_monster[worldBossCfg.monster];
		if not monsterCfg then return ""; end
		return "<font color='#ffffff'>【"..monsterCfg.name.."】</font>";
	else
		return "";
	end
end
