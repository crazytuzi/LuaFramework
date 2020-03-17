--[[
时间戳
参数:type,yyyy,mm,dd
haohu
2015年12月31日16:32:53
]]

_G.TimestampChatParam = setmetatable({},{__index=ChatParam});

function TimestampChatParam:GetType()
	return ChatConsts.ChatParam_Timestamp;
end

function TimestampChatParam:DecodeToText(paramStr,withLink)
	local params = self:Decode(paramStr);
	if #params < 3 then return "" end
	local str = string.format( StrConfig['chat604'], params[1], params[2], params[3] )
	str = "<font color='#ffffff'>"..str.."</font>";
	return str;
end
