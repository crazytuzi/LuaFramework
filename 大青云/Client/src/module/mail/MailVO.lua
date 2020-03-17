--[[
邮件VO
liyuan
2014年9月27日10:11:28
]]

_G.MailVO = {}

MailVO.mailid = 0; -- 邮件id
MailVO.read = 0; -- 是否读过0 - 未读， 1 - 已读"/>
MailVO.item = 0; -- 0 - 没有附件， 1 - 有附件没领， 2 - 有附件已领
MailVO.sendTime = 0; -- 发件时间
MailVO.leftTime = 0; -- 剩余时间
MailVO.mailtitle = 0; -- 邮件标题
MailVO.mailTxtId = 0;--配表id

MailVO.isSelected = false
MailVO.isGetMailContent = false

MailVO.mailcontnet = ''
MailVO.MailItemList = {}

--[[
MailItemVoVO = {
	itemid = 0; -- 附件物品id
	itemcount = 0; -- 附件物品数量
}
]]

function MailVO:new()
	local obj = setmetatable({},{__index = self})
	return obj
end

