--[[
境界
参数:type,境界id
lizhuangzhuang
2015年3月6日11:23:36
]]
_G.classlist['JingJieChatParam'] = 'JingJieChatParam'
_G.JingJieChatParam = setmetatable({},{__index=ChatParam});
JingJieChatParam.objName = 'JingJieChatParam'
function JingJieChatParam:GetType()
	return ChatConsts.ChatParam_JingJie;
end

function JingJieChatParam:DecodeToText(paramStr,withLink)
	local params = self:Decode(paramStr);
	local jingJieId = toint(params[1]);
	local cfg = t_jingjie[jingJieId];
	if not cfg then return ""; end
	local str = "<font color='#ffffff'>"..cfg.name.."</font>";
	return str;
end