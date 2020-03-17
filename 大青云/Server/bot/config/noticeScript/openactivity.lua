--[[
打开活动
参数:
@param activityId 活动id
lizhuangzhuang
2015年5月25日18:03:28
]]

NoticeScriptCfg:Add(
{
	name = "openactivity",
	execute = function(activityId)
		if not activityId then return false; end
		local activityId = toint(activityId);
		if not activityId then return false; end
		FuncManager:OpenFunc(FuncConsts.Activity,false,activityId);
		return true;
	end
}
);