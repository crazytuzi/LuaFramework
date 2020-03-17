--[[
坐骑
参数:type,坐骑id
lizhuangzhuang
2015年3月6日10:49:53
]]
_G.classlist['HorseChatParam'] = 'HorseChatParam'
_G.HorseChatParam = setmetatable({},{__index=ChatParam});
HorseChatParam.objName = 'HorseChatParam'
function HorseChatParam:GetType()
	return ChatConsts.ChatParam_Ride;
end

function HorseChatParam:DecodeToText(paramStr,withLink)
	local params = self:Decode(paramStr);
	local horseId = toint(params[1]);
	local cfg = t_horse[horseId];
	if not cfg then return ""; end
	local str = "<font color='#ffffff'>"..cfg.name.."</font>";
	return str;
end
