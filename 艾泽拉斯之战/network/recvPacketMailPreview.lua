-- 邮件预览

function packetHandlerMailPreview()
	local tempArrayCount = 0;
	local beginIndex = nil;
	local mailPreviews = {};

-- 邮件列表起始索引
	beginIndex = networkengine:parseInt();
-- 邮件预览表
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		mailPreviews[i] = ParseMailPreview();
	end

	MailPreviewHandler( beginIndex, mailPreviews );
end

