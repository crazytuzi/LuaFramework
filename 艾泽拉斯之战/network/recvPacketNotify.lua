-- 系统通知

function packetHandlerNotify()
	local tempArrayCount = 0;
	local notifyType = nil;
	local text = nil;
	local wildCardParams = {};

-- 服务器主动向客户端发送通知，类型
	notifyType = networkengine:parseInt();
-- 通知内容
	local strlength = networkengine:parseInt();
if strlength > 0 then
		text = networkengine:parseString(strlength);
else
		text = "";
end
-- 通配符参数
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
	local strlength = networkengine:parseInt();
if strlength > 0 then
			wildCardParams[i] = networkengine:parseString(strlength);
else
			wildCardParams[i] = "";
end
	end

	NotifyHandler( notifyType, text, wildCardParams );
end

