--[[
武魂
参数:type,武魂id
lizhuangzhuang
2015年3月6日10:43:17
]]
_G.classlist['WuHunChatParam'] = 'WuHunChatParam'
_G.WuHunChatParam = setmetatable({},{__index=ChatParam});
WuHunChatParam.objName = 'WuHunChatParam'
function WuHunChatParam:GetType()
	return ChatConsts.ChatParam_WuHun;
end

function WuHunChatParam:DecodeToText(paramStr,withLink)
	local params = self:Decode(paramStr);
	local wuHunId = toint(params[1]);
	local cfg = t_wuhun[wuHunId];
	if not cfg then return ""; end
	local str = "<font color='#ffffff'>"..cfg.name.."</font>";
	return str;
end