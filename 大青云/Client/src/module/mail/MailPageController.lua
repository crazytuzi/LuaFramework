_G.MailPageController = {};

MailPageController.PageShowNum = 12	   					--每页显示数量	
MailPageController.CurrentPageIndex = 1 				--从1开始的当前页
MailPageController.TotalPageNum = 0   					--总的页数
MailPageController.TotalMailNum	= 0						--总的邮件数

MailPageController.NoReadCurrentPageIndex = 1 				--未读从1开始的当前页
MailPageController.NoReadTotalPageNum = 0   				--未读的页数
MailPageController.NoReadTotalMailNum	= 0					--未读的邮件数

MailPageController.ReadCurrentPageIndex = 1 				--已读从1开始的当前页
MailPageController.ReadTotalPageNum = 0   					--已读总的页数
MailPageController.ReadTotalMailNum	= 0						--已读总的邮件数

function MailPageController:Init(totalNum)
	self.TotalMailNum = totalNum
	self.TotalPageNum = math.ceil(self.TotalMailNum/self.PageShowNum)
	
	self.NoReadTotalMailNum = MailModel:GetNoReadNum()
	self.NoReadTotalPageNum = math.ceil(self.NoReadTotalMailNum/self.PageShowNum)
	
	self.ReadTotalMailNum = MailModel:GetReadNum()
	self.ReadTotalPageNum = math.ceil(self.ReadTotalMailNum/self.PageShowNum)
end

--param @mType 0全部1未读2已读
function MailPageController:GetCurrentPageMails(mType)
	local currentPageMails = {}
	local startIndex = 0
	
	if self.NoReadCurrentPageIndex <= 1 then self.NoReadCurrentPageIndex = 1 end
	if self.ReadCurrentPageIndex <= 1 then self.ReadCurrentPageIndex = 1 end
	if self.CurrentPageIndex <= 1 then self.CurrentPageIndex = 1 end
	--SpiritsUtil:Print('MailPageController:GetCurrentPageMails self.CurrentPageIndex'..self.CurrentPageIndex)
	--SpiritsUtil:Print(mType)
	if mType == 1 then
		startIndex = (self.NoReadCurrentPageIndex - 1)*self.PageShowNum + 1
		for i = startIndex, startIndex+self.PageShowNum-1 do
			if MailModel.noReadMailList[i] then
				table.push(currentPageMails, MailModel.noReadMailList[i])
			end
		end
	elseif mType == 2 then
		startIndex = (self.ReadCurrentPageIndex - 1)*self.PageShowNum + 1
		for i = startIndex, startIndex+self.PageShowNum-1 do
			if MailModel.readMailList[i] then
				table.push(currentPageMails, MailModel.readMailList[i])
			end
		end
	else
		startIndex = (self.CurrentPageIndex - 1)*self.PageShowNum + 1
		--SpiritsUtil:Print(startIndex)
		--SpiritsUtil:Print(startIndex+self.PageShowNum-1)
		--SpiritsUtil:Trace(MailModel.mailList)
		for i = startIndex, startIndex+self.PageShowNum-1 do
			if MailModel.mailList[i] then
				table.push(currentPageMails, MailModel.mailList[i])
			end
		end
	end
	--SpiritsUtil:Trace(currentPageMails)
	return currentPageMails
end

function MailPageController:GetOnDeleteCurrentPageMails(mType)
	if self.NoReadCurrentPageIndex >= self.TotalPageNum then self.NoReadCurrentPageIndex = self.TotalPageNum end
	if self.ReadCurrentPageIndex >= self.TotalPageNum then self.ReadCurrentPageIndex = self.TotalPageNum end
	if self.CurrentPageIndex >= self.TotalPageNum then self.CurrentPageIndex = self.TotalPageNum end
	
	if self.NoReadCurrentPageIndex <= 1 then self.NoReadCurrentPageIndex = 1 end
	if self.ReadCurrentPageIndex <= 1 then self.ReadCurrentPageIndex = 1 end
	if self.CurrentPageIndex <= 1 then self.CurrentPageIndex = 1 end
	--SpiritsUtil:Print("GetOnDeleteCurrentPageMails"..self.CurrentPageIndex)
	return self:GetCurrentPageMails(mType)
end

function MailPageController:GotoNextPage(mType)
	if not self:IsNextPage(mType) then
		return nil
	end
	
	if mType == 1 then
		self.NoReadCurrentPageIndex = self.NoReadCurrentPageIndex + 1
		--SpiritsUtil:Print("MailPageController"..self.NoReadCurrentPageIndex)
	elseif mType == 2 then
		self.ReadCurrentPageIndex = self.ReadCurrentPageIndex + 1
		--SpiritsUtil:Print("MailPageController"..self.ReadCurrentPageIndex)
	else
		self.CurrentPageIndex = self.CurrentPageIndex + 1
		--SpiritsUtil:Print("MailPageController"..self.CurrentPageIndex)
	end
	
	return self:GetCurrentPageMails(mType)
end

function MailPageController:GotoPrePage(mType)
	if not self:IsPrePage(mType) then
		return nil
	end
	
	if mType == 1 then
		self.NoReadCurrentPageIndex = self.NoReadCurrentPageIndex - 1
		--SpiritsUtil:Print("MailPageController"..self.NoReadCurrentPageIndex)
	elseif mType == 2 then
		self.ReadCurrentPageIndex = self.ReadCurrentPageIndex - 1
		--SpiritsUtil:Print("MailPageController"..self.ReadCurrentPageIndex)
	else
		self.CurrentPageIndex = self.CurrentPageIndex - 1
		--SpiritsUtil:Print("MailPageController"..self.CurrentPageIndex)
	end
	
	return self:GetCurrentPageMails()
end

function MailPageController:IsPrePage(mType)
	if mType == 1 then
		if self.NoReadCurrentPageIndex <= 1 then self.NoReadCurrentPageIndex = 1 return false end
	elseif mType == 2 then
		if self.ReadCurrentPageIndex <= 1 then self.ReadCurrentPageIndex = 1 return false end
	else
		if self.CurrentPageIndex <= 1 then self.CurrentPageIndex = 1 return false end
	end
	
	return true
end

function MailPageController:IsNextPage(mType)
	if mType == 1 then
		if self.NoReadCurrentPageIndex >= self.TotalPageNum then self.NoReadCurrentPageIndex = self.TotalPageNum return false end
	elseif mType == 2 then
		if self.ReadCurrentPageIndex >= self.TotalPageNum then self.ReadCurrentPageIndex = self.TotalPageNum return false end
	else
		if self.CurrentPageIndex >= self.TotalPageNum then self.CurrentPageIndex = self.TotalPageNum return false end
	end
	
	return true
end