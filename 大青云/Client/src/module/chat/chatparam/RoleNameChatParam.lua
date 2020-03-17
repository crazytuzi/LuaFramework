--[[
玩家名
参数格式:type,roleID,roleName,teamId,guildId,guildPos,vip,lvl,icon,cityPos,vflag
lizhuangzhuang
2014年9月17日21:13:57
]]

_G.RoleNameChatParam = setmetatable({},{__index=ChatParam});

function RoleNameChatParam:GetType()
	return ChatConsts.ChatParam_RoleName;
end

function RoleNameChatParam:DecodeToText(paramStr,withLink)
	local params = self:Decode(paramStr);
	if not params[2] then return ""; end
	local str = params[2];
	str = "<font color='#52d584'>" .. str .. "</font>";
	if withLink and #params>2 then
		return self:GetLinkStr(str,paramStr);
	else
		return str;
	end
end

function RoleNameChatParam:DoLink(paramStr)
	local chatRoleVO = ChatRoleVO:new();
	chatRoleVO:ParseStr(paramStr);
	UIChatRoleOper:Open(chatRoleVO);
end