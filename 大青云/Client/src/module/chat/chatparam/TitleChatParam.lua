--[[
称号
参数:type,称号id
lizhuangzhuang
2015年1月3日17:25:44
]]
_G.classlist['TitleChatParam'] = 'TitleChatParam'
_G.TitleChatParam = setmetatable({},{__index=ChatParam});
TitleChatParam.objName = 'TitleChatParam'
function TitleChatParam:GetType()
	return ChatConsts.ChatParam_Title;
end

function TitleChatParam:DecodeToText(paramStr,withLink)
	local params = self:Decode(paramStr);
	local titleId = toint(params[1]);
	local cfg = t_title[titleId];
	if not cfg then return ""; end
	local str = "<font color='#ffffff'>【"..cfg.name.."】</font>";
	return str;
end