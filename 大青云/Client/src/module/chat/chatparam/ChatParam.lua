--[[
聊天参数编解码基类
lizhuangzhuang
2014年9月17日20:45:53
]]

_G.ChatParam = {};

--参数列表
ChatParam.params = {};

function ChatParam:new()
	local obj = setmetatable({},{__index=self});
	return obj;
end

function ChatParam:GetType()
	return 0;
end

--解码
--将字符串解码为参数列表
--@param paramStr 要解码的字符串
function ChatParam:Decode(paramStr)
	self.params = split(paramStr,",");
	if #self.params > 0 then
		table.remove(self.params,1);
	end
	return self.params;
end

--编码
--将参数列表编码为字符串
--@param paramList 参数列表
function ChatParam:Encode(...)
	local str = "{";
	str = str .. tostring(self:GetType());
	for i,v in ipairs({...}) do
		str = str .. "," .. tostring(v);
	end
	str = str .. "}";
	return str;
end

--解码为文本
--@param 是否有链接
function ChatParam:DecodeToText(paramStr,withLink)
	return "";
end

--为文本加上链接
function ChatParam:GetLinkStr(str,paramStr)
	return "<a href='asfunction:hrefevent,"..paramStr.."'><u>" ..str.."</u></a>";
end

--点击后执行的操作
function ChatParam:DoLink(paramStr)

end

--鼠标移上后的操作
function ChatParam:DoLinkOver(paramStr)

end