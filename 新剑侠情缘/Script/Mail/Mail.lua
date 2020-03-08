--更新邮件数
function Mail:OnUpdateMailCount(nTotalCount, nUnreadMailCount, nSerNewestMailId, nOldMailTime)
	self.nUnreadMailCount = nUnreadMailCount;
	self.nTotalCount 	  = nTotalCount;
	if nTotalCount >= 180 then
		self.nLastNotifyCount =  self.nLastNotifyCount or 0;
		if nTotalCount > self.nLastNotifyCount then
			self.nLastNotifyCount = nTotalCount
			Ui:SynNotifyMsg({
				szType = "ToMuchMailList";
		        nTimeOut = GetTime() + 600;
		        nId = 1;
				})
		end
	end
--[[
	if nOldMailTime and nOldMailTime ~= 0 and GetTime() - nOldMailTime  >= Mail.AUTO_TAKE_TIME_INTERVAL then
		if self.nTryAutoTakeMailAttachDay ~= Lib:GetLocalDay() then
			self.nTryAutoTakeMailAttachDay = Lib:GetLocalDay()
			RemoteServer.TryAutoTakeOldTimeMailAttach();
		end
	end
]]

	self.nSerNewestMailId = nSerNewestMailId;
	UiNotify.OnNotify(UiNotify.emNOTIFY_NOTIFY_NEW_MAIL); --这里的只是更新数字通知了
end

function Mail:RequestMailData()
	local nNow = GetTime();
	if self.nSerNewestMailId ~= self.nClentNewstMailId and (nNow - self.nRequestTime  > 3 ) then
		RemoteServer.RequestMailData(self.nSelfLoadIndex)
		self.nRequestTime = nNow
	end
end

function Mail:OnSyncMailData(tbMails, nSelfLoadIndex)
	if nSelfLoadIndex == self.nSelfLoadIndex then
		return
	end
	for i,v in ipairs(tbMails) do
		table.insert(self.tbAllMails, v)
		if v.ID > self.nClentNewstMailId then
			self.nClentNewstMailId = v.ID
		end
	end
	self.nSelfLoadIndex   = nSelfLoadIndex
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_MAIL_DATA)
end

function Mail:OnDeleteAllMail(nSelfLoadIndex)
	self.nSelfLoadIndex   = nSelfLoadIndex
	self.nClentNewstMailId = 0;
	self.tbAllMails = {};
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_MAIL_DATA)
end

--打开时做这个操作就行了 更新本地邮件数据，-同时按反顺序输出
function Mail:GetMailData()
	local nTimeNow = GetTime()
	local tbAllMails = self.tbAllMails
	local tbReverse = {}
	for i = #tbAllMails, 1, -1 do
		local tbMail = tbAllMails[i]
		if (tbMail.ReadFlag and not tbMail.tbAttach and not tbMail.bNotAutoDelete)  then --or tbMail.RecyleTime <= nTimeNow
			table.remove(tbAllMails, i)
		else
			table.insert(tbReverse, tbMail)
		end
	end

	return tbReverse
end

function Mail:Record(nMaildId, bAutoDelete)
	self.nUnreadMailCount = self.nUnreadMailCount - 1
	RemoteServer.RecordReadMails(nMaildId, bAutoDelete)
	UiNotify.OnNotify(UiNotify.emNOTIFY_NOTIFY_NEW_MAIL);
end

function Mail:TakeAttach(nMaildId)
	for i,v in ipairs(self.tbAllMails) do
		if v.ID == nMaildId then
			v.ReadFlag = true
			v.tbAttach = nil
			me.CenterMsg("领取附件成功")
			UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_MAIL_DATA, nMaildId, true)
			break;
		end
	end
end

function Mail:RemoveOneMail(nMaildId)
	for i,v in ipairs(self.tbAllMails) do
		if v.ID == nMaildId then
			table.remove(self.tbAllMails, i)
			UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_MAIL_DATA, nMaildId, true)
			break;
		end
	end
end


function Mail:DelAllNormalMail()
	local tbDels = {}
	local nDelUnReadNum = 0
	for i = #self.tbAllMails, 1, - 1 do
		local v = self.tbAllMails[i]
		if not v.tbAttach then
			tbDels[v.ID] = true
			if not v.ReadFlag then
				nDelUnReadNum = nDelUnReadNum + 1

			end
			table.remove(self.tbAllMails, i)
		end
	end
	self.nTotalCount = #self.tbAllMails;
	if next(tbDels) then
		if nDelUnReadNum > 0 then
			self.nUnreadMailCount = self.nUnreadMailCount - nDelUnReadNum
			UiNotify.OnNotify(UiNotify.emNOTIFY_NOTIFY_NEW_MAIL);
		end
		for k,v in pairs(tbDels) do
			RemoteServer.RecordReadMails(k, v)
		end

		return true
	else
		me.CenterMsg("无可删除邮件")
	end
end

function Mail:GetUnreadMailCount()
	return self.nUnreadMailCount
end

function Mail:UpdateShowedMailId()
	self.nShowedMailId = self.nSerNewestMailId;
end

function Mail:IsShowMailNotify()
	return self.nShowedMailId ~= self.nSerNewestMailId and self:GetUnreadMailCount() > 0;
end

function Mail:OnTakeInvalidMail(nMailId)
	for i,v in ipairs(self.tbAllMails) do
		if v.ID == nMailId then
			me.CenterMsg("已过期的邮件！")
			Ui:CloseWindow("MailDetailedPanel")
			table.remove(self.tbAllMails, i)
			UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_MAIL_DATA)
			return
		end
	end
end


function Mail:Clear()
	self.nUnreadMailCount = 0;
	self.nTotalCount 	  = 0;
	self.nSelfLoadIndex   = 0;
	self.nSerNewestMailId = 0;
	self.nClentNewstMailId= 0;
	self.nShowedMailId    = 0;
	self.nRequestTime 	  = 0;
	self.tbAllMails 	  = {}
	self.nLastNotifyCount = nil;
	self.nTryAutoTakeMailAttachDay = nil;
end

Mail:Clear()