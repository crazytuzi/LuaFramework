-- 邮件内容

function packetHandlerMail()
	local tempArrayCount = 0;
	local id = nil;
	local caption = nil;
	local text = nil;
	local time = nil;
	local wildCardParams = {};
	local attachements = {};

-- 邮件ID
	id = networkengine:parseInt();
-- 邮件标题
	local strlength = networkengine:parseInt();
if strlength > 0 then
		caption = networkengine:parseString(strlength);
else
		caption = "";
end
-- 邮件内容
	local strlength = networkengine:parseInt();
if strlength > 0 then
		text = networkengine:parseString(strlength);
else
		text = "";
end
-- 邮件时间
	time = networkengine:parseUInt64();
-- 通配符参数,最多5个
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
	local strlength = networkengine:parseInt();
if strlength > 0 then
			wildCardParams[i] = networkengine:parseString(strlength);
else
			wildCardParams[i] = "";
end
	end
-- 附件表,最多20
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		attachements[i] = ParseMailAttachment();
	end

	MailHandler( id, caption, text, time, wildCardParams, attachements );
end

