--[[
打开死亡遗迹
参数:
@param activityId 活动id
lizhuangzhuang
2015年11月26日04:35:56
]]

NoticeScriptCfg:Add(
{
	name = "openswyj",
	execute = function(activityId)
		if not activityId then return false; end
		local activityId = toint(activityId);
		if not activityId then return false; end
		ActivityController:EnterActivity(activityId,{param1=1})
		return true;
	end
}
);