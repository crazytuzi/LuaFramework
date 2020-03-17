--[[
超链接
参数:type,超链接
lizhuangzhuang
2015年3月6日19:59:17
]]
_G.classlist['WebLinkChatParam'] = 'WebLinkChatParam'
_G.WebLinkChatParam = setmetatable({},{__index=ChatParam});
WebLinkChatParam.objName = 'WebLinkChatParam'
function WebLinkChatParam:GetType()
	return ChatConsts.ChatParam_WebLink;
end

function WebLinkChatParam:DecodeToText(paramStr,withLink)
	local params = self:Decode(paramStr);
	if #params <= 0 then return ""; end
	if not withLink then
		return params[1];
	end
	local str = "<font color='#00ff00'>" .. params[1] .. "</font>";
	return self:GetLinkStr(str,paramStr);
end

function WebLinkChatParam:DoLink(paramStr)
	local params = self:Decode(paramStr);
	_sys:browse(params[1]);
end