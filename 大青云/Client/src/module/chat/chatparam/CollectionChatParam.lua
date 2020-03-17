--[[
采集物
参数格式:type,collectionid
houxudong
2016年7月30日23:02:30
]]

_G.CollectionChatParam = setmetatable({},{__index=ChatParam});

--获得常量类型
function CollectionChatParam:GetType()
	return ChatConsts.ChatParam_Collection;
end

--解析服务器发过来的字符串
function CollectionChatParam:DecodeToText(paramStr,withLink)
	local params = self:Decode(paramStr);
	local collectionId = toint(params[1]);
	local cfg = t_collection[collectionId];
	if not cfg then return ""; end
	local str = "";
	str = string.format(" %s",cfg.name);
	str = "<font color='#ffffff'>"..str.."</font>";
	return str;
end