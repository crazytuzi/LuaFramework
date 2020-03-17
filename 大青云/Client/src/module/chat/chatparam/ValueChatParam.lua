--[[
值
参数格式:type,value
lizhuangzhuang
2014年9月17日21:24:37
]]
_G.classlist['ValueChatParam'] = 'ValueChatParam'
_G.ValueChatParam = setmetatable({},{__index=ChatParam});
ValueChatParam.objName = 'ValueChatParam'
function ValueChatParam:GetType()
	return ChatConsts.ChatParam_Value;
end

function ValueChatParam:DecodeToText(paramStr,withLink)
	local params = self:Decode(paramStr);
	if #params < 1 then return ""; end
	return params[1];
end