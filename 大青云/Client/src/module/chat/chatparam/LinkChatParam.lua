--[[
链接
参数格式:type,服务器脚本参数,自由参数...
自由参数定义:
	script=		脚本名
	text=		文本
	t_param=	配表脚本参数
lizhuangzhuang
2014年9月17日21:26:36
]]
_G.classlist['LinkChatParam'] = 'LinkChatParam'
_G.LinkChatParam = setmetatable({},{__index=ChatParam});
LinkChatParam.objName = 'LinkChatParam'
function LinkChatParam:GetType()
	return ChatConsts.ChatParam_Link;
end

function LinkChatParam:DecodeToText(paramStr,withLink)
	local params = self:Decode(paramStr);
	if #params <= 0 then return ""; end
	local str = "";
	for i,s in ipairs(params) do
		if s:lead("text=") then
			str = string.sub(s,6,#s);
		end
	end
	str = "<font color='#00ff00'>" .. str .. "</font>";
	if withLink then
		return self:GetLinkStr(str,paramStr);
	else
		return str;
	end
end

function LinkChatParam:DoLink(paramStr)
	local params = self:Decode(paramStr);
	local scriptName = nil;
	local cfgParamList = {};--配表参数
	local serverParamList = {};--服务器发来的参数列表
	for i=1,#params do
		local s = params[i];
		if s:lead("script=") then
			scriptName = string.sub(s,8,#s);
		elseif s:lead("t_param=") then
			local t_param = string.sub(s,9,#s);
			cfgParamList = split(t_param,";");
		elseif s:lead("text=") then
		
		else
			table.push(serverParamList,s);
		end
	end
	if not scriptName then return; end
	local paramlist = {};
	for i,param in ipairs(serverParamList) do
		table.push(paramlist,param);
	end
	for i,param in ipairs(cfgParamList) do
		table.push(paramlist,param);
	end
	NoticeScriptManager:DoScript(scriptName,paramlist);
end