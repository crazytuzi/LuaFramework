--[[
活动
参数:type,活动id
lizhuangzhuang
2015年3月31日11:58:16
]]

_G.ActivityChatParam = setmetatable({},{__index=ChatParam});

function ActivityChatParam:GetType()
	return ChatConsts.ChatParam_Activity;
end

function ActivityChatParam:DecodeToText(paramStr,withLink)
	local params = self:Decode(paramStr);
	local activityId = toint(params[1]);
	local cfg = t_activity[activityId];
	if not cfg then return ""; end
	local str = "<font color='#ffffff'>"..cfg.name.."</font>";
	return str;

end
