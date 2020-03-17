--[[邮件
liyuan
2014年9月28日10:33:06
]]

_G.MailModel = Module:new();

MailModel.mailList = {}--全部
MailModel.readMailList = {}--已读
MailModel.noReadMailList = {}--未读

MailModel.MailInitNum = -1
-- 邮件列表
function MailModel:UpdateMailList(msgList)
	self.mailList = {}
	self.readMailList = {}
	self.noReadMailList = {}
	for index, mailInfo in pairs(msgList) do
		local mailVO = MailVO:new()
		for attrName, attrValue in pairs(mailInfo) do
			mailVO[attrName] = attrValue
		end	
		table.push(self.mailList, mailVO)
		if mailVO.read == 0 then table.push(self.noReadMailList, mailVO)
		elseif mailVO.read == 1 then table.push(self.readMailList, mailVO) 
		end
	end
	
	if #self.mailList>0 then table.sort(self.mailList, MailUtil.MailSortFunc) end
	if #self.readMailList>0 then table.sort(self.readMailList, MailUtil.MailSortFunc) end
	if #self.noReadMailList>0 then table.sort(self.noReadMailList, MailUtil.MailSortFunc) end
	
	MailPageController:Init(#self.mailList)
	Notifier:sendNotification(NotifyConsts.MailListUpdate, {isDelete=false});
end

-- 获取邮件内容
function MailModel:OpenMail(msg)
	local mailVO = self:GetMailById(msg.mailid)
	mailVO.isGetMailContent = true
	mailVO.read = 1
	mailVO.item = msg.item--是否领取过附件0 - 没有领取附件
	mailVO.mailcontnet = msg.mailcontnet
	mailVO.MailItemList = {}
	for i, itemVO in pairs(msg.MailItemList) do
		local mailItemVO = {}
		for attrName, attrValue in pairs(itemVO) do
			mailItemVO[attrName] = attrValue
		end
		table.push(mailVO.MailItemList, mailItemVO)
	end
	Notifier:sendNotification(NotifyConsts.MailContentInfoUpdate, {mailid=msg.mailid});
	Notifier:sendNotification(NotifyConsts.MailListUpdate, {isDelete=false});
	Notifier:sendNotification(NotifyConsts.MailNumChanged,{num=self:GetNoReadNum(), getContent=true});
	self:OnReadMail(msg.mailid)
	
	local vo = {}
	vo.mailcount = self:GetNoReadNum()
	
	RemindController:AddRemind(RemindConsts.Type_NewMail, vo )
--[[
MailItemVoVO = {
	itemid = 0; -- 附件物品id
	itemcount = 0; -- 附件物品数量
}
]]
end

-- 领取附件
function MailModel:GetMailItem(mailList)

	for i, resVO in pairs(mailList) do
		if resVO.result == 0 then 
			local mailVO = self:GetMailById(resVO.mailid)
			if mailVO then
				mailVO.item = 2
				mailVO.read = 1
				self:OnReadMail(resVO.mailid)
			end
		end
	end
	
	local itemList = {}
	if mailList and #mailList == 1 then
		local mailVO = self:GetMailById(mailList[1].mailid)
		if mailVO then
			if mailVO.MailItemList and mailList[1].result == 0 then
				for k, itemVO in pairs (mailVO.MailItemList) do
					if itemVO.itemid and itemVO.itemid ~= 0 and itemVO.itemcount ~= 0 then
						local vo = {}
						vo.id = tonumber(itemVO.itemid);
						vo.count = tonumber(itemVO.itemcount);
						vo.bind = BagConsts.Bind_GetBind;--默认获取绑定
						table.push(itemList, vo)
					end
				end
			end		
		end
	end
	Notifier:sendNotification(NotifyConsts.MailContentInfoUpdate, {mailid=0});
	Notifier:sendNotification(NotifyConsts.MailListUpdate, {isDelete=false});
	if #itemList > 0 then
		Notifier:sendNotification(NotifyConsts.MailGetItem, {itemList=itemList});
	end
end

-- 删除邮件
function MailModel:DelMail(mailList)
	for i, delVO in pairs(mailList) do
		for index, mailVO in pairs(self.mailList) do
			if delVO.mailid == mailVO.mailid then
				table.remove(self.mailList,index);
				break
			end
		end
		for index1, mailVO1 in pairs(self.noReadMailList) do
			if delVO.mailid == mailVO1.mailid then
				table.remove(self.noReadMailList,index1);
				break
			end
		end
		for index2, mailVO2 in pairs(self.readMailList) do
			if delVO.mailid == mailVO2.mailid then
				table.remove(self.readMailList,index2);
				break
			end
		end
	end
	
	MailPageController:Init(#self.mailList)
	
	Notifier:sendNotification(NotifyConsts.MailListUpdate, {isDelete=true});
	local vo = {}
	vo.mailcount = self:GetNoReadNum()
	-- FPrint('未读邮件数量：'..vo.mailcount)
	Notifier:sendNotification(NotifyConsts.MailNumChanged,{num=vo.mailcount, getContent=true});
	RemindController:AddRemind(RemindConsts.Type_NewMail, vo )
end

function MailModel:OnReadMail(mailid)
	local mailVO = nil
	for index2, mailVO2 in pairs(self.noReadMailList) do
		if mailid == mailVO2.mailid then
			mailVO = mailVO2
			table.remove(self.noReadMailList,index2)
			break
		end
	end
	if mailVO then table.insert(self.readMailList,mailVO) end
	
	if #self.mailList>0 then table.sort(self.mailList, MailUtil.MailSortFunc) end
	if #self.readMailList>0 then table.sort(self.readMailList, MailUtil.MailSortFunc) end
	if #self.noReadMailList>0 then table.sort(self.noReadMailList, MailUtil.MailSortFunc) end
	MailPageController:Init(#self.mailList)
end

-- 由附件的位置得到附件的道具id
function MailModel:GetMailItemByIndex(mailid, index)
	local mailVO = self:GetMailById(mailid)
	for i, itemVO in pairs(mailVO.MailItemList) do
		if index == i then return itemVO.itemid end
	end
	
	return nil
end

-- 所有选中的邮件
function MailModel:GetAllSelectedMails()
	local resList = {}
	for i, mailVO in pairs(self.mailList) do
		if mailVO.isSelected then table.push(resList, mailVO.mailid) end
	end 
	
	
	return resList
end

-- 所有未领取附件的邮件
function MailModel:GetAllItemMails()
	local resList = {}
	for i, mailVO in pairs(self.mailList) do
		if mailVO.item == 1 then table.push(resList, mailVO.mailid) end
	end 
	
	return resList
end

-- 取一个mailVO
function MailModel:GetMailById(mailid)
	for index, mailVO in pairs(self.mailList) do
		if mailid == mailVO.mailid then
			return mailVO
		end
	end
	
	return nil
end

-- 未读邮件个数
function MailModel:GetNoReadNum()
	local num = 0
	for index, mailVO in pairs(self.mailList) do
		if 0 == mailVO.read then
			num = num + 1
		end
	end
	
	return num
end

-- 已读邮件个数
function MailModel:GetReadNum()
	local num = 0
	for index, mailVO in pairs(self.mailList) do
		if 1 == mailVO.read then
			num = num + 1
		end
	end
	
	return num
end

-- 邮件总数
function MailModel:GetMailTotalNum()
	return #self.mailList
end






