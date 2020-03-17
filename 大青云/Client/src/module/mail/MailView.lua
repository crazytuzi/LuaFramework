--[[邮件界面主面板
liyuan
2014年9月28日10:33:06
]]

_G.UIMail = BaseUI:new("UIMail") 
UIMail.mailType = 0 --0全部1未读2已读
UIMail.mailid = nil
UIMail.isNoTip = false
function UIMail:Create()
	self:AddSWF("mailPanel.swf", true, "center")
end

function UIMail:OnLoaded(objSwf,name)
	objSwf.btnClose.click = function() self:OnBtnCloseClick() end
	
	objSwf.mailList.itemBtnClick = function(e) self:OnBtnDelClick(e) end
	objSwf.mailList.checkBoxClick = function(e) self:OnCheckBoxClick(e) end
	objSwf.mailList.itemRollOver = function(e) self:OnMailRollOverHanlder(e) end
	objSwf.mailList.itemRollOut = function(e) self:OnMailRollOutHanlder(e) end
	objSwf.mailList.itemClick = function(e) self:OnMailListClick(e) end
	
	objSwf.btnPre.click = function() self:OnPreClick() end
	objSwf.btnNext.click = function() self:OnNextClick() end
	
	objSwf.btnAll.click = function() self:OnAllMailClick() end
	objSwf.btnUnread.click = function() self:OnUnreadClick() end
	objSwf.btnRead.click = function() self:OnReadClick() end
	
	objSwf.btnSelectAll.click = function() self:OnbtnSelectAllClick() end
	objSwf.btnNoSelect.click = function() self:OnbtnNoSelectClick() end
	objSwf.btnDelete.click = function() self:OnbtnDeleteClick() end
	objSwf.btnDeleteSelected.click = function() self:OnbtnDeleteSelectedClick() end
	objSwf.btnGetAll.click = function() self:OnbtnGetAllClick() end
	objSwf.btnGet.click = function() self:OnbtnGetClick() end	
	
	objSwf.textAreaDetail.hrefEvent = function(e) self:OnLinkClick(e); end
	for i = 1,8 do 
		objSwf['itemGet'..i]._visible = false
		--FPrint('邮件附件3')
	end
	RewardManager:RegisterListTips( objSwf.levelRewardList )
end

function UIMail:IsTween()
	return true
end

function UIMail:GetPanelType()
	return 1
end

function UIMail:BeforeTween()
	self.tweenStartPos = UIMainTop:GetMailBtnPos()
end

function UIMail:GetWidth(szName)
	return 1146 
end

function UIMail:GetHeight(szName)
	return 687
end

function UIMail:OnShow(name)
	local objSwf = self.objSwf
	if not objSwf then return end
	if MailModel:GetNoReadNum() > 0 then
		self:OnUnreadClick()
		objSwf.btnUnread.selected = true
	else
		self:OnAllMailClick()
		objSwf.btnAll.selected = true
	end
	self:ClearCurrent()
	MailController:GetMailList()
	
	
end

--点击关闭按钮
function UIMail:OnBtnCloseClick()
	self:Hide() 
end

function UIMail:OnHide()
end

---------------------------------ui事件处理------------------------------------
-- checkbox点击
function UIMail:OnCheckBoxClick(e)
	--SpiritsUtil:Print("checkbox点击:"..e.item.mailid.."selected:"..e.item.isSelected)
	local mailVO = MailModel:GetMailById(e.item.mailid)
	if not mailVO then return; end
	if e.item.isSelected == 1 then mailVO.isSelected = true else mailVO.isSelected = false end
end

function UIMail:OnMailRollOverHanlder(e)
	-- e.renderer:delBtnVisible(1)
end

function UIMail:OnMailRollOutHanlder(e)
	-- e.renderer:delBtnVisible(0)
end

function UIMail:OnPreClick()
	local list = MailPageController:GotoPrePage(self.mailType)
	if list then self:ClearCurrent() self:UpdateMailList(list) end
end

function UIMail:OnNextClick()
	local list = MailPageController:GotoNextPage(self.mailType)
	if list then self:ClearCurrent() self:UpdateMailList(list) end
end

-- 查看全部
function UIMail:OnAllMailClick()
	self.mailType = 0
	
	self:ClearCurrent()
	local list = MailPageController:GetCurrentPageMails(0)
	UIMail:UpdateMailList(list)
end

-- 查看未读
function UIMail:OnUnreadClick()
	self.mailType = 1
	
	self:ClearCurrent()
	local list = MailPageController:GetCurrentPageMails(1)
	UIMail:UpdateMailList(list)
end

-- 查看已读
function UIMail:OnReadClick()
	self.mailType = 2
	
	self:ClearCurrent()
	local list = MailPageController:GetCurrentPageMails(2)
	UIMail:UpdateMailList(list)
end

-- 全选本页
function UIMail:OnbtnSelectAllClick()
	--SpiritsUtil:Print("全选本页")

	local list = MailPageController:GetCurrentPageMails(self.mailType)
	if #list <= 0 then 
		FloatManager:AddCenter(StrConfig['mail11'])
		return 
	end
	
	for i, mailVO in pairs(list) do
		mailVO.isSelected = 1
	end 
	
	UIMail:UpdateMailList(list)
end

-- 取消全选
function UIMail:OnbtnNoSelectClick()
	local list = MailModel.mailList
	if #list <= 0 then 
		FloatManager:AddCenter(StrConfig['mail9'])
		return 
	end
	
	for i, mailVO in pairs(list) do
		mailVO.isSelected = 0
	end 
	
	local cList = MailPageController:GetCurrentPageMails(self.mailType)
	UIMail:UpdateMailList(cList)
end

-- 删除选中
function UIMail:OnbtnDeleteSelectedClick()
	local mlist = MailModel:GetAllSelectedMails()
	if #mlist <= 0 then 
		FloatManager:AddCenter(StrConfig['mail9'])
		return 
	end
	
	self:DeleteMailsHanlder(mlist)
end

-- 删除当前
UIMail.delList = {}
function UIMail:OnbtnDeleteClick()
	if not self.mailid then return end
	
	self:DeleteMailsHanlder({self.mailid})
end

-- 在列表中点×删除
function UIMail:OnBtnDelClick(e)
	local mid = e.item.mailid
	if not mid then return end
	self:DeleteMailsHanlder({mid})
end

function UIMail:DeleteMailsHanlder(list)
	self.delList = list
	local confirmFunc = function(isNoTip)
		if isNoTip then	self.isNoTip = isNoTip end
		MailController:ReqDelMail(self.delList)
	end
	
	if self:CheckMailIsItem(list) then
		UIConfirm:Open(StrConfig['mail5'], confirmFunc, nil, StrConfig['mail8'], StrConfig['mail7'] )
	else
	   if self.isNoTip then 
			MailController:ReqDelMail(self.delList) 
	   else
			UIConfirmWithNoTip:Open(StrConfig['mail4'], confirmFunc, nil, StrConfig['mail8'], StrConfig['mail7'], StrConfig['mai20'] )
	   end
	end
end

function UIMail:CheckMailIsItem(list)
	for i, mId in pairs(list) do
		local mVO = MailModel:GetMailById(mId)
		if mVO.item == 1 then
			return true
		end
	end
	
	return false
end


-- 领取所有附件
function UIMail:OnbtnGetAllClick()
	local mList = MailModel:GetAllItemMails()
	--SpiritsUtil:Print("#mlist"..#mList)
	--SpiritsUtil:Trace(mList)
	if #mList <= 0 then 
		FloatManager:AddCenter(StrConfig['mail10'])
		return 
	end
	
	MailController:GetItem(mList)
end

-- 领取当前附件
function UIMail:OnbtnGetClick()
	if not self.mailid then return end
	MailController:GetItem({self.mailid})
end

function UIMail:OnItemOver1(e) self:AddItemTip(1) end
function UIMail:OnItemOver2(e) self:AddItemTip(2) end
function UIMail:OnItemOver3(e) self:AddItemTip(3) end
function UIMail:OnItemOver4(e) self:AddItemTip(4) end
function UIMail:OnItemOver5(e) self:AddItemTip(5) end
function UIMail:OnItemOver6(e) self:AddItemTip(6) end
function UIMail:OnItemOver7(e) self:AddItemTip(7) end
function UIMail:OnItemOver8(e) self:AddItemTip(8) end

function UIMail:AddItemTip(index)
	if not self.mailid then return end
	local itemId = MailModel:GetMailItemByIndex(self.mailid, index)
	if not itemId then return end
	
	local objSwf = self:GetSWF("UIMail")
	if not objSwf then return end
	
	TipsManager:ShowItemTips(itemId)
end

function UIMail:OnItemOut(e)
	TipsManager:Hide()
end

-- 选中某个邮件
function UIMail:OnMailListClick(e)
	local mailVO = MailModel:GetMailById(e.item.mailid)
	if mailVO.isGetMailContent then 
		self:UpdateMailContent(mailVO)
	else
		MailController:GetMialById(e.item.mailid)
	end
end

---------------------------------消息处理------------------------------------
--监听消息
function UIMail:ListNotificationInterests()
	return {
		NotifyConsts.MailContentInfoUpdate, 
		NotifyConsts.MailListUpdate,
		NotifyConsts.MailNumChanged,   
		NotifyConsts.MailGetItem,
	} 
end

--处理消息
function UIMail:HandleNotification(name, body)
	if not self.bShowState then return end
	local objSwf = self.objSwf
	if not objSwf then return end
	
	if name == NotifyConsts.MailContentInfoUpdate then
		if body.mailid == 0 then
			if self.mailid then local curMailVO = MailModel:GetMailById(self.mailid) self:UpdateMailContent(curMailVO) end
		else
			local curMailVO = MailModel:GetMailById(body.mailid)
			if curMailVO then self:UpdateMailContent(curMailVO) end
		end
		
	elseif name == NotifyConsts.MailListUpdate then
		if body.isDelete then
			self:ClearCurrent()
			local list = MailPageController:GetOnDeleteCurrentPageMails(self.mailType)
			self:UpdateMailList(list)
		else
			-- self:ClearCurrent()
			local list = MailPageController:GetCurrentPageMails(UIMail.mailType)
			self:UpdateMailList(list)
		end
	elseif name == NotifyConsts.MailNumChanged then
		if body.getContent then return end
		
		MailController:GetMailList()
	elseif name == NotifyConsts.MailGetItem then
		local rewardList = {}
		local startPos = UIManager:PosLtoG(objSwf.item1,0,0)
		-- FTrace(body.itemList)
		RewardManager:FlyIcon(body.itemList,startPos,6,true,60)
		SoundManager:PlaySfx(2041)
		local mailRender = objSwf.mailList:getRendererAt(0)
		if mailRender then
			if mailRender.data.item == 1 then
				mailRender.selected = true
				local itemE = {}
				itemE.item = mailRender.data
				UIMail:OnMailListClick(itemE)
			end
		end
	end
end
---------------------------------ui逻辑------------------------------------
function UIMail:UpdateMailList(list)
	local objSwf = self:GetSWF("UIMail") 
	if not objSwf then return end
	
	if not list then
		objSwf.mailList.dataProvider:cleanUp()
		objSwf.mailList:invalidateData()
		for i = 1,8 do 
			objSwf['itemGet'..i]._visible = false
			--FPrint('邮件附件4')
		end
		return
	end
	--SpiritsUtil:Print('UIMail:UpdateMailList(list)')
	--SpiritsUtil:Trace(list)
	
	objSwf.mailList.dataProvider:cleanUp() 
	-- for i = 1,8 do 
		-- objSwf['itemGet'..i]._visible = false
		-- --FPrint('邮件附件5')
	-- end
	for i, mailVO in pairs(list) do
		local node = {}
		for attrName, attrValue in pairs(mailVO) do
			node[attrName] = attrValue
		end	
		if mailVO.read == 1 then
			node.readStr = UIStrConfig['mail6'] -- 是否读过
		else
			node.readStr = UIStrConfig['mail5']
		end
		
		local year,month,day,hour,min1,sec = CTimeFormat:todate(toint(mailVO.sendTime), true)  -- 发件时间
		node.sendTime = year..'-'..month..'-'..day
		local day,hour,min1,sec = CTimeFormat:sec2formatEx(toint(node.leftTime)) 				-- 剩余时间
		node.leftTime = string.format(StrConfig['mail1'],day)
		
		if mailVO.mailTxtId and mailVO.mailTxtId ~= 0 then
			node.mailtitle = self:GetContentStr(mailVO.mailtitle, mailVO.mailTxtId, true)
		else
			node.mailtitle = mailVO.mailtitle
		end
		
		objSwf.mailList.dataProvider:push( UIData.encode(node) )
	end
	objSwf.mailList:invalidateData()
	
	if self.mailid then 
		for j,vo in ipairs(list) do
			if vo.mailid == self.mailid then
				objSwf.mailList.selectedIndex = j-1
			end
		end
	end
	
	local totalNum = 1
	local curPage = 1
	if self.mailType == 1 then
		totalNum = MailPageController.NoReadTotalPageNum
		curPage = MailPageController.NoReadCurrentPageIndex
	elseif self.mailType == 2 then
		totalNum = MailPageController.ReadTotalPageNum
		curPage = MailPageController.ReadCurrentPageIndex
	else
		totalNum = MailPageController.TotalPageNum
		curPage = MailPageController.CurrentPageIndex
	end
	if totalNum <= 0 then totalNum = 1 end
	if curPage <= 0 then curPage = 1 end
	objSwf.txtPage.text = curPage..'/'..totalNum
	
	if MailPageController:IsPrePage(self.mailType) then 
		objSwf.btnPre.disabled = false else objSwf.btnPre.disabled = true
	end
	
	if MailPageController:IsNextPage(self.mailType) then
		objSwf.btnNext.disabled = false else objSwf.btnNext.disabled = true
	end
	objSwf.txtMailNum.htmlText = string.format(StrConfig['mail2'], MailPageController.NoReadTotalMailNum, MailPageController.TotalMailNum)
end

function UIMail:UpdateMailContent(mailVO)
	-- if not self.mailid then return end
	local objSwf = self:GetSWF("UIMail") 
	if not objSwf then return end
	--SpiritsUtil:Print('UIMail:UpdateMailContent(mailVO)')
	--SpiritsUtil:Trace(mailVO)
	
	self.mailid = mailVO.mailid
	-- mailVO.mailcontnet = '212,1:0,1:0'
	
	if mailVO.mailTxtId and mailVO.mailTxtId ~= 0 then
		objSwf.textAreaDetail.htmlText = self:GetContentStr(mailVO.mailcontnet, mailVO.mailTxtId, false)
	else
		objSwf.textAreaDetail.htmlText = mailVO.mailcontnet
	end
	
	-- for i = 1,8 do 
		-- objSwf['itemGet'..i]._visible = false
	-- end
	
	local itemStr = ""
	local i = 1
	for index, itemVO in pairs(mailVO.MailItemList) do
		if itemVO.itemid > 0 then
			if mailVO.item == 2 then
				objSwf['itemGet'..i]._visible = true;
				--FPrint('邮件附件7')
			else
				objSwf['itemGet'..i]._visible = false;
				--FPrint('邮件附件6')
			end
			if i == 1 then
				itemStr = itemStr .. tostring(itemVO.itemid) .. ',' .. tostring(itemVO.itemcount)				
			else
				itemStr = itemStr .. "#" .. tostring(itemVO.itemid) .. ',' .. tostring(itemVO.itemcount)	
			end
		else
			objSwf['itemGet'..i]._visible = false
			--FPrint('邮件附件1')
		end
		i = i + 1
	end
	
	objSwf.levelRewardList.dataProvider:cleanUp()
	objSwf.levelRewardList.dataProvider:push( unpack( RewardManager:Parse( itemStr ) ) )
	objSwf.levelRewardList:invalidateData()

	
	objSwf.btnDelete.disabled = false
	if mailVO.item == 1 then 
		objSwf.btnGet.disabled = false 
	else 
		objSwf.btnGet.disabled = true 
	end
end

function UIMail:ClearCurrent()
	local objSwf = self:GetSWF("UIMail") 
	if not objSwf then return end
	
	self.mailid = nil
	objSwf.mailList.dataProvider:cleanUp() 
	for i = 1,8 do 
		objSwf['itemGet'..i]._visible = false
		--FPrint('邮件附件2')
	end
	objSwf.mailList:invalidateData()
	objSwf.btnGet.disabled = true
	objSwf.btnDelete.disabled = true
	objSwf.textAreaDetail.text = ''
	objSwf.levelRewardList.dataProvider:cleanUp()
	objSwf.levelRewardList:invalidateData()
end

function UIMail:OnLinkClick(e)
	--FPrint(e.param)
	_sys:browse(e.param);
end

function UIMail:GetContentStr(paramStr,mailTxtId,isTitle)
	local contentStr = ""
	if not t_mailContent[toint(mailTxtId)] then return "" end
	if isTitle then
		contentStr = t_mailContent[toint(mailTxtId)].title
	else
		contentStr = t_mailContent[toint(mailTxtId)].content
	end
	if not paramStr or paramStr == "" then return contentStr end 
	local paramList = split(paramStr, ",")
	if not paramList or #paramList <= 0 then return contentStr end
	
	local contentList = {}
	local formatStr = ""
	for k,v in pairs (paramList) do
		local itemList = split(v, ":")
		if itemList and #itemList > 1 then
			if toint(itemList[2]) == 1 then
				table.push(contentList, itemList[1])
			elseif toint(itemList[2]) == 2 then
				local timeData = CTimeFormat:todate(itemList[1], false);
				table.push(contentList, timeData)
			end

		end
	end
	if #contentList == 1 then
		contentStr = string.format(contentStr, contentList[1])
	elseif #contentList == 2 then
		contentStr = string.format(contentStr, contentList[1], contentList[2])
	elseif #contentList == 3 then
		contentStr = string.format(contentStr, contentList[1], contentList[2], contentList[3])
	elseif #contentList == 4 then
		contentStr = string.format(contentStr, contentList[1], contentList[2], contentList[3], contentList[4])
	elseif #contentList == 5 then
		contentStr = string.format(contentStr, contentList[1], contentList[2], contentList[3], contentList[4], contentList[5])
	elseif #contentList == 6 then
		contentStr = string.format(contentStr, contentList[1], contentList[2], contentList[3], contentList[4], contentList[5], contentList[6])
	end
	return contentStr
end


function UIMail:IsShowSound()
	return true;
end

function UIMail:IsShowLoading()
	return true;
end









