--[[
帮派
参数:type,帮派id,帮派名
lizhuangzhuang
2015年1月3日17:09:51
]]

_G.GuildChatParam = setmetatable({},{__index=ChatParam});

function GuildChatParam:GetType()
	return ChatConsts.ChatParam_Guild;
end

function GuildChatParam:DecodeToText(paramStr,withLink)
	local params = self:Decode(paramStr);
	if params[2] then
		return "<font color='#ffffff'>【"..params[2].."】</font>";
	else
		return "";
	end
end