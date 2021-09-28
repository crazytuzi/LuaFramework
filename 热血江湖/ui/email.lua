-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_email = i3k_class("wnd_email", ui.wnd_base)

local YJFWB = "ui/widgets/yjfwb"
local YJT3 = "ui/widgets/yjt3"

local mailIconImg = {
	readed = 862,
	unRead = 863,
}

local mailStateImg = {
	unRead = 3461,
	selected = 3462,
	readed = 3461,
}

local mailStateColor = {
	unRead = {delColor = "FFc93034", titleColor = "FF966856"},
	selected = {delColor = "FFc93034", titleColor = "FF966856"},
	readed = {delColor = "FFc93034", titleColor = "FF966856"},
}

function GetType(id)
	id = tonumber(id)
	if id <= 196605 and id >= 131073 then
		return 1
	elseif id <= 131071 and id >= 65537 then
		return 2
	elseif id > 10000000 then
		return 3
	end
end


function wnd_email:ctor()
	self._state = 1    --1为系统邮件页，2为临时邮件页, 3为帮派邮件

	self._index = nil
	self._emailNow = nil
	self._currentPageSys = 1
	self._currentPageTemp = 1
	self._currentPageSect = 1
	self._mailBeforN = nil
	self._mailNowN = nil
	--self._child = {}

	self._sysAnis = true
	self._tempAnis = true

	self._widgets = {}
end

function wnd_email:configure(...)
	self._layout.vars.close:onClick(self, self.closeUI)
	self._widgets.sysEmail = self._layout.vars.sysEmail
	self._widgets.sysEmail:onClick(self, self.syncSysEmail)
	self._widgets.tempEmail = self._layout.vars.tempEmail
	self._widgets.tempEmail:onClick(self, self.syncTempEmail)

	self._widgets.factionBtn = self._layout.vars.factionBtn
	self._widgets.factionBtn:onClick(self, self.onFactionBtn)

	self._layout.vars.pageLeft:onClick(self, self.pageBefore)
	self._layout.vars.pageRight:onClick(self, self.pageNext)
	
	self._widgets.noEmailWord = self._layout.vars.noEmail
	self._widgets.scroll = self._layout.vars.emailScroll

	self._widgets.sysEmail:stateToPressed()
	self._layout.vars.emailDesc:hide()

	self._layout.vars.haveUnread:hide()
	self._widgets.sysRed = self._layout.vars.haveUnread
	self._layout.vars.haveTemp:hide()
	self._widgets.tempRed = self._layout.vars.haveTemp

	self._widgets.getAdditional = self._layout.vars.getAdditional
	self._widgets.getWord = self._layout.vars.getWord

	self._widgets.getAllAdditional = self._layout.vars.getAllAnnex

	self._widgets.notice_content = self._layout.vars.notice_content

	self._widgets.email_info = self._layout.vars.email_info
	self._widgets.notice_info = self._layout.vars.notice_info
end

function wnd_email:syncSysEmail(sender)
	--self._child = nil
	self._index = nil
	local syncSys = i3k_sbean.mail_syncsys_req.new()
	syncSys.pageNO = self._currentPageSys
	i3k_game_send_str_cmd(syncSys, "mail_syncsys_res")

	if self._state ~= 1 then
		self._mailBeforN = nil
		self._mailNowN = nil

		self._state = 1
	end
	self._widgets.tempEmail:stateToNormal()
	self._widgets.factionBtn:stateToNormal()
	self._widgets.sysEmail:stateToPressed()
	self._widgets.email_info:show()
	self._widgets.notice_info:hide()
end

function wnd_email:syncTempEmail(sender)
	--self._child = nil
	self._index = nil
	local syncTemp = i3k_sbean.mail_synctmp_req.new()
	syncTemp.pageNO = self._currentPageTemp
	i3k_game_send_str_cmd(syncTemp, "mail_synctmp_res")


	if self._state ~= 2 then
		self._mailBeforN = nil
		self._mailNowN = nil
		self._state = 2
	end

	self._widgets.sysEmail:stateToNormal()
	self._widgets.factionBtn:stateToNormal()
	self._widgets.tempEmail:stateToPressed()
	self._widgets.email_info:show()
	self._widgets.notice_info:hide()
end

function wnd_email:onFactionBtn(sender)
	self._index = nil

	if self._state ~= 3 then
		self._state = 3
	end

	i3k_sbean.mail_syncsect(self._currentPageSect)

	
	self._widgets.sysEmail:stateToNormal()
	self._widgets.tempEmail:stateToNormal()
	self._widgets.factionBtn:stateToPressed()
	self._widgets.email_info:show()
	self._widgets.notice_info:hide()
end

function wnd_email:closeUI(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Email)
end

function wnd_email:onShow()

end

function wnd_email:getAllCB()
	if self._index then
		if self._index<=self._widgets.scroll:getChildrenCount() then
			local node = self._widgets.scroll:getChildAtIndex(self._index)
			self:OpenEmail(node.rootVar)
		else
			self._index = nil
		end
	end
end


function wnd_email:getAllAnnexCB(sender)
	if self._state == 1 then
		local takeAllSys = i3k_sbean.mail_takeallsys_req.new()
		takeAllSys.page = self._currentPageSys
		takeAllSys.callback = function (page)
			local syncSys = i3k_sbean.mail_syncsys_req.new()
			syncSys.pageNO = page
			--if self._index then
				syncSys.callback = function ()
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_Email, "getAllCB")
				end
			--end
			i3k_game_send_str_cmd(syncSys, "mail_syncsys_res")
		end
		i3k_game_send_str_cmd(takeAllSys, "mail_takeallsys_res")
	else
		local takeAllTmp = i3k_sbean.mail_takealltmp_req.new()
		takeAllTmp.page = self._currentPageTemp
		takeAllTmp.callback = function (page)
			local syncTemp = i3k_sbean.mail_synctmp_req.new()
			syncTemp.pageNO = page
			--if self._index then
				syncTemp.callback = function ()
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_Email, "getAllCB")
				end
			--end
			i3k_game_send_str_cmd(syncTemp, "mail_synctmp_res")
		end
		i3k_game_send_str_cmd(takeAllTmp, "mail_takealltmp_res")
	end
end


--------------------------------------------------------------------


function wnd_email:setPageInfo(currentPage, pageCount, unreadCount, totalCount)
	if pageCount==0 then
		currentPage = 0
	end
	self._layout.vars.page:setText(currentPage.."/"..pageCount)
	self._layout.vars.numberOfEmail:setText(totalCount)
	local unreadStr = string.format("%d", unreadCount)
	self._layout.vars.unread:setText(unreadCount)
	if unreadCount == 0 then
		if self._state == 1 then
		self._widgets.sysRed:hide()
		elseif self._state == 2 then
		self._widgets.tempRed:hide()
		elseif self._state == 3 then
			self._layout.vars.sectRed:hide()
		end
	end

	local fade = self._layout.vars.fade
	if self._unreadCount<unreadCount and currentPage==1 then
		local fadeout = fade:createFadeOut(0.5)
		local fadein = fade:createFadeIn(0.5)
		local seq = fade:createSequence(fadeout, fadein)
		local repeatForever = fade:createRepeatForever(seq)
		if self._state==1 and self._sysAnis then
			fade:show()
			fade:runAction(repeatForever)
			self._sysAnis = false
		elseif self._state==2 and self._tempAnis then
			fade:show()
			fade:runAction(repeatForever)
			self.tempAnis = false
		else
			fade:hide()
		end
	else
		fade:hide()
	end
end


function wnd_email:setUnreadRedPoint(sysUnreadCount, tempUnreadCount, sectUnreadCount)
	if sysUnreadCount>0 then
		self._widgets.sysRed:show()
	else
		self._widgets.sysRed:hide()
	end
	if tempUnreadCount>0 then
		self._widgets.tempRed:show()
	else
		self._widgets.tempRed:hide()
	end
	if sectUnreadCount > 0 then
		self._layout.vars.sectRed:show()
	else
		self._layout.vars.sectRed:hide()
	end
end


function wnd_email:setMailData(mails)
	self._layout.vars.emailDesc:hide()
	self._layout.vars.cartoon:show()
	self._widgets.scroll:setBounceEnabled(false)
	self._widgets.scroll:removeAllChildren()
	local count = 0
	for _,v in pairs(mails) do
		count = count + 1
	end
	if count>0 then
		self._widgets.noEmailWord:hide()
		self._widgets.scroll:show()
	else
		self._widgets.noEmailWord:show()
		self._widgets.scroll:hide()
	end
	self._unreadCount = 0
	local isHaveAnnex = false
	for i=1,count do
		local yjt = require("ui/widgets/yjt")()
		local sendTimeLabel = yjt.vars.sendTime
		local deleteTimeLabel = yjt.vars.deleteTime
		local mailTitleLabel = yjt.vars.mailTitle
		local emailIcon = yjt.vars.emailIcon
		local haveAnnex = yjt.vars.haveAnnex
		local currentEmail = yjt.vars.currentEmail
		local mailState = yjt.vars.state
		local newImg = yjt.vars.newImg

		currentEmail:hide()
		newImg:hide()

		if mails[i].state==0 then
			emailIcon:setImage(g_i3k_db.i3k_db_get_icon_path(mailIconImg.unRead))
			mailState:setImage(g_i3k_db.i3k_db_get_icon_path(mailStateImg.unRead))
			deleteTimeLabel:setTextColor(mailStateColor.unRead.delColor)
			mailTitleLabel:setTextColor(mailStateColor.unRead.titleColor)
			newImg:show()
			self._unreadCount = self._unreadCount + 1
			if mails[i].attCount==0 then
				haveAnnex:hide()
			else
				isHaveAnnex = true
				haveAnnex:show()
				haveAnnex:enable()
			end
		elseif mails[i].state==1 then
			emailIcon:setImage(g_i3k_db.i3k_db_get_icon_path(mailIconImg.readed))
			mailState:setImage(g_i3k_db.i3k_db_get_icon_path(mailStateImg.readed))
			deleteTimeLabel:setTextColor(mailStateColor.readed.delColor)
			mailTitleLabel:setTextColor(mailStateColor.readed.titleColor)
			if mails[i].attCount==0 then
				haveAnnex:hide()
			else
				isHaveAnnex = true
				haveAnnex:show()
				haveAnnex:enable()
			end
		elseif mails[i].state==2 then
			emailIcon:setImage(g_i3k_db.i3k_db_get_icon_path(mailIconImg.unRead))
			mailState:setImage(g_i3k_db.i3k_db_get_icon_path(mailStateImg.unRead))
			deleteTimeLabel:setTextColor(mailStateColor.unRead.delColor)
			mailTitleLabel:setTextColor(mailStateColor.unRead.titleColor)
			haveAnnex:disable()
		else
			emailIcon:setImage(g_i3k_db.i3k_db_get_icon_path(mailIconImg.readed))
			mailState:setImage(g_i3k_db.i3k_db_get_icon_path(mailStateImg.readed))
			deleteTimeLabel:setTextColor(mailStateColor.readed.delColor)
			mailTitleLabel:setTextColor(mailStateColor.readed.titleColor)
			if mails[i].attCount==0 then
				haveAnnex:hide()
			else
				haveAnnex:disable()
			end
		end
		--只用6、7、8
		local sendTime=os.date("%Y-%m-%d", g_i3k_get_GMTtime(mails[i].sendTime))
		sendTimeLabel:setText(sendTime)
		if mails[i].type~=-1 then
			if mails[i].type ~= 1 and mails[i].type ~= 2 then
				mailTitleLabel:setText(g_i3k_db.i3k_db_get_mail_title_text(mails[i].type, nil, mails[i].title))
			else
				mailTitleLabel:setText(mails[i].title)
			end
		else
			mailTitleLabel:setText(string.format("掉落信件"))
		end
		if mailTitleLabel:getText() == "" then
			mailTitleLabel:setText("系统信件")
		end
		local openEmail = yjt.rootVar
		if openEmail then
			openEmail:setTag(1000+i)
			openEmail:onClick(self, self.OpenEmail)
		end
		self._widgets.scroll:addItem(yjt)
	end
	if isHaveAnnex then
		self._widgets.getAllAdditional:enableWithChildren()
		self._widgets.getAllAdditional:onClick(self, self.getAllAnnexCB)
	else
		self._widgets.getAllAdditional:disableWithChildren()
	end
	if self._state == 3 then
		self._widgets.getAllAdditional:disableWithChildren()
		self._widgets.getAdditional:disableWithChildren()
	else
		self._widgets.getAllAdditional:enableWithChildren()
		self._widgets.getAdditional:enableWithChildren()
	end
	local scrollContentSize = self._widgets.scroll:getContentSize()
	self._widgets.scroll:setContainerSize(scrollContentSize.width, scrollContentSize.height)
end

function wnd_email:refreshLeftState(mailId)
	local emailTable = nil
	if self._state==1 then
		emailTable = g_i3k_game_context:GetSysMail()
	elseif self._state == 2 then
		emailTable = g_i3k_game_context:GetTempMail()
	elseif self._state == 3 then
		emailTable = g_i3k_game_context:GetSectMail()
	end
	local children = self._layout.vars.emailScroll:getAllChildren()
	for i,v in ipairs(emailTable) do
		local node = children[i]
		if v.id~=mailId and node then
			if v.state==0 or v.state==2 then--未读
				node.vars.state:setImage(g_i3k_db.i3k_db_get_icon_path(mailStateImg.unRead))
				node.vars.deleteTime:setTextColor(mailStateColor.unRead.delColor)
				node.vars.mailTitle:setTextColor(mailStateColor.unRead.titleColor)
			else--已读
				node.vars.state:setImage(g_i3k_db.i3k_db_get_icon_path(mailStateImg.readed))
				node.vars.deleteTime:setTextColor(mailStateColor.readed.delColor)
				node.vars.mailTitle:setTextColor(mailStateColor.readed.titleColor)
			end
		end
	end
end

function wnd_email:OpenEmail(sender)
	self._layout.vars.emailDesc:hide()
	local tag = sender:getTag()-1000
	self._index = tag

	if self._state == 1 then
		self._emailNow = g_i3k_game_context:GetSysMail()[tag]
	elseif self._state == 2 then
		self._emailNow = g_i3k_game_context:GetTempMail()[tag]
	elseif self._state == 3 then
		self._emailNow = g_i3k_game_context:GetSectMail()[tag]
	end

	if not self._emailNow then
		return
	end
	if self._state==1 then
		local readEmail = i3k_sbean.mail_readsys_req.new()
		readEmail.mailId = self._emailNow.id
		readEmail.oldState = self._emailNow.state
		readEmail.page = self._currentPageSys
		i3k_game_send_str_cmd(readEmail, "mail_readsys_res")
	elseif self._state == 2 then
		local readEmail = i3k_sbean.mail_readtmp_req.new()
		readEmail.mailId = self._emailNow.id
		readEmail.oldState = self._emailNow.state
		readEmail.page = self._currentPageTemp
		i3k_game_send_str_cmd(readEmail, "mail_readtmp_res")
	elseif self._state == 3 then
		i3k_sbean.mail_readsect(self._emailNow.id, self._emailNow.state, self._currentPageSect)
	end
	--[[
	--local readEmail = i3k_sbean.mail_read_req.new()
	readEmail.mailId = self._emailNow.id
	readEmail.oldState = self._emailNow.state
	--readEmail.state = self._state
	if self._state==1 then
		readEmail.page = self._currentPageSys
		i3k_game_send_str_cmd(readEmail, "mail_readsys_res")
	else
		readEmail.page = self._currentPageTemp
		i3k_game_send_str_cmd(readEmail, "mail_readtmp_res")
	end
	--i3k_game_send_str_cmd(readEmail, "mail_read_res")
	]]
end

function wnd_email:setMailDetail(email, oldState)
	if self._index then
		self._layout.vars.emailDesc:show()
		self._layout.vars.cartoon:hide()
		self._emailNow = email
		local fromName = self._layout.vars.fromName
		local mailTitle = self._layout.vars.mailTitle
		local mailContent = self._layout.vars.content
		mailContent:hide()

		local annexCount = 0
		local annexTable = {}
		for i,v in pairs(email.attachment) do
			annexCount = annexCount + 1
			table.insert(annexTable, v)
		end
		if annexCount>0 then
			g_i3k_game_context:SetEquipFromEmail(annexTable)
		else
			g_i3k_game_context:SetEquipFromEmail(nil)
		end

		local emailScroll = self._layout.vars.emailScroll

		local scrollChild = emailScroll:getAllChildren()
		for i,v in pairs(scrollChild) do
			v.vars.currentEmail:hide()
		end
		local child = emailScroll:getChildAtIndex(self._index)
		child.vars.currentEmail:show()
		child.vars.newImg:hide()
		child.vars.emailIcon:setImage(g_i3k_db.i3k_db_get_icon_path(mailIconImg.readed))
		child.vars.state:setImage(g_i3k_db.i3k_db_get_icon_path(mailStateImg.selected))
		child.vars.mailTitle:setTextColor(mailStateColor.selected.titleColor)
		child.vars.deleteTime:setTextColor(mailStateColor.selected.delColor)
		self:refreshLeftState(email.id)

		fromName:setText(email.fromName~="" and email.fromName or "系统")
		if fromName:getText()=="系统" then
			fromName:setTextColor(g_i3k_get_cond_color(false))
		end
		local msgText = ""
		if email.type~=8 and email.type~=10 then
			if email.type~=1 and email.type~=2 then
				mailTitle:setText(g_i3k_db.i3k_db_get_mail_title_text(email.type, email.additional, email.title))
			else
				mailTitle:setText(email.title)
			end
			--mailContent:setText(g_i3k_db.i3k_db_get_mail_content_text(email.type, email.additional, email.sendTime, email.content) or email.content)
			msgText = g_i3k_db.i3k_db_get_mail_content_text(email.type, email.additional, email.sendTime, email.content) or email.content
		else
			if email.type==8 then--正邪道场邮件
			--正邪道场逻辑不通特殊处理
				if email.additional[1]==g_i3k_game_context:GetRoleId() then
					mailTitle:setText(i3k_get_string(432))
					local bwType = email.additional[3] ==1 and "正派道场" or "邪派道场"
					--mailContent:setText(i3k_get_string(433, bwType, email.additional[2]))
					msgText = i3k_get_string(433, bwType, email.additional[2])
				else
					mailTitle:setText(i3k_get_string(430))
					local bwType = email.additional[3] ==1 and "正派道场" or "邪派道场"
					local sectAndName = string.split(email.content, "|")
					--mailContent:setText(i3k_get_string(431, sectAndName[2], bwType, email.additional[2], sectAndName[1], i3k_db_taoist.needLvl))
					msgText = i3k_get_string(431, sectAndName[2], bwType, email.additional[2], sectAndName[1], i3k_db_taoist.needLvl)
				end
			elseif email.type==10 then--好友改名
				mailTitle:setText(g_i3k_db.i3k_db_get_mail_title_text(email.type))
				local contentTab = string.split(email.content, "|")
				--mailContent:setText(i3k_get_string(609, contentTab[1], contentTab[2]))
				msgText = i3k_get_string(609, contentTab[1], contentTab[2])
			end
		end
		if mailTitle:getText() == "" then
			mailTitle:setText("系统信件")
		end
		self._layout.vars.scroll:removeAllChildren()
		local ContextNode = require(YJFWB)()
		ContextNode.vars.text:setText(msgText)
		g_i3k_ui_mgr:AddTask(self, {ContextNode}, function(ui)
			local textUI = ContextNode.vars.text
			local size = ContextNode.rootVar:getContentSize()
			local height = textUI:getInnerSize().height
			local width = size.width
			height = size.height > height and size.height or height
			if size.height >= height then
				self._layout.vars.scroll:stateToNoSlip()
			else
				self._layout.vars.scroll:stateToSlip()
			end
			ContextNode.rootVar:changeSizeInScroll(self._layout.vars.scroll, width, height, true)
		end,1)
		self._layout.vars.scroll:addItem(ContextNode)
		if annexCount>0 then
			self._layout.vars.itemScroll:removeAllChildren()
			for i=1, annexCount do
				local id = annexTable[i].id
				local count = annexTable[i].count
				local node = require("ui/widgets/yjt2")()
				node.vars.root:show()
				node.vars.root:enableWithChildren()
				node.vars.root:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
				node.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
				local isBind = g_i3k_common_item_has_binding_icon(id)
				node.vars.lock:setVisible(isBind)
				node.vars.btn:onClick(self, self.onTips, id)
				node.vars.count:setText(i3k_get_num_to_show(count))
				if email.state>=2 then
					node.vars.root:disableWithChildren()
				end
				self._layout.vars.itemScroll:addItem(node)
			end
			if email.state>=2 then
				self._widgets.getAdditional:disableWithChildren()
			else
				self._widgets.getAdditional:enableWithChildren()
				self._widgets.getAdditional:onClick(self, self.getAnnex)
			end
		else
			self._layout.vars.itemScroll:removeAllChildren()
			self._widgets.getAdditional:disable()
			self._widgets.getWord:disable()
		end

		if oldState==0 then
			local pageText = self._layout.vars.page:getText()
			local pageTable = string.split(pageText, "/")
			local currentPage = tonumber(pageTable[1])
			local pageCount = tonumber(pageTable[2])

			local totalCount = tonumber(self._layout.vars.numberOfEmail:getText())
			local unreadCount = tonumber(self._layout.vars.unread:getText())-1

			self:setPageInfo(currentPage, pageCount, unreadCount, totalCount)
		end
	end
end

function wnd_email:pageBefore(sender)
	self._index = nil
	local page = self._layout.vars.page
	local pageString = page:getText()
	local index = string.find(pageString, "/", 1)
	local pageNow = nil
	local pageTotal = nil
	if index then
		pageNow = tonumber(string.sub(pageString, 1, index-1))
		pageTotal = tonumber(string.sub(pageString, index+1, string.len(pageString)))
	end
	if pageNow == 1 then
		g_i3k_ui_mgr:PopupTipMessage("自己是第一页")
	else
		if pageNow~=0 then
			self._mailBeforN = nil
			self._mailNowN = nil

			if self._state==1 then
				self._currentPageSys = self._currentPageSys-1
				local syncSys = i3k_sbean.mail_syncsys_req.new()
				syncSys.pageNO = self._currentPageSys
				i3k_game_send_str_cmd(syncSys, "mail_syncsys_res")
			elseif self._state == 2 then
				self._currentPageTemp = self._currentPageTemp-1
				local syncTemp = i3k_sbean.mail_synctmp_req.new()
				syncTemp.pageNO = self._currentPageTemp
				i3k_game_send_str_cmd(syncTemp, "mail_synctmp_res")
			elseif self._state == 3 then
				self._currentPageSect = self._currentPageSect - 1
				i3k_sbean.mail_syncsect(self._currentPageSect)
			end
		end
	end
end

function wnd_email:pageNext(sender)
	self._index = nil
	local fade = self._layout.vars.fade
	fade:stopAllActions()
	fade:hide()
	local page = self._layout.vars.page
	local pageString = page:getText()
	local index = string.find(pageString, "/", 1)
	local pageNow = nil
	local pageTotal = nil
	if index then
		pageNow = tonumber(string.sub(pageString, 1, index-1))
		pageTotal = tonumber(string.sub(pageString, index+1, string.len(pageString)))
	end
	if pageNow == pageTotal then
		if pageNow==0 then

		else
			g_i3k_ui_mgr:PopupTipMessage("已经是最后一页了")
		end
	else
		self._mailBeforN = nil
		self._mailNowN = nil

		if self._state==1 then
			self._currentPageSys = self._currentPageSys+1
			local syncSys = i3k_sbean.mail_syncsys_req.new()
			syncSys.pageNO = self._currentPageSys
			i3k_game_send_str_cmd(syncSys, "mail_syncsys_res")
		elseif self._state == 2 then
			self._currentPageTemp = self._currentPageTemp+1
			local syncTemp = i3k_sbean.mail_synctmp_req.new()
			syncTemp.pageNO = self._currentPageTemp
			i3k_game_send_str_cmd(syncTemp, "mail_synctmp_res")
		elseif self._state == 3 then
			self._currentPageSect = self._currentPageSect + 1
			i3k_sbean.mail_syncsect(self._currentPageSect)
		end
	end
end

function wnd_email:onTips(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_email:getAnnex(sender)
	local equipTable = g_i3k_game_context:GetEquipFromEmail()

	local isEnoughTable = { }
	for i,v in pairs(equipTable) do
		isEnoughTable[v.id] = v.count
	end
	local isenough = g_i3k_game_context:IsBagEnough(isEnoughTable)

	if self._emailNow.state<2 then
		if isenough then
			local take
			if self._state==1 then
				take = i3k_sbean.mail_takesys_req.new()
				take.mailId = self._emailNow.id
				take.id = self._emailNow.id
				i3k_game_send_str_cmd(take, "mail_takesys_res")
			else
				take = i3k_sbean.mail_taketmp_req.new()
				take.mailId = self._emailNow.id
				take.id = self._emailNow.id
				i3k_game_send_str_cmd(take, "mail_taketmp_res")
			end
			--[[
			--local take = i3k_sbean.mail_take_req.new()
			take.mailId = self._emailNow.id
			take.id = self._emailNow.id
			if self._state==1 then
				i3k_game_send_str_cmd(take, "mail_takesys_res")
			else
				i3k_game_send_str_cmd(take, "mail_taketmp_res")
			end
			--i3k_game_send_str_cmd(take, "mail_take_res")]]
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(123))
		end
	end
end


function wnd_email:getAnnexCB(mailId)
	local child = self._layout.vars.itemScroll:getAllChildren()
	for i,v in pairs(child) do
		v.vars.root:disableWithChildren()
	end
	local sysEmail = g_i3k_game_context:GetSysMail()
	local index
	for i,v in pairs(sysEmail) do
		if v.id==mailId then
			index = i
			sysEmail[i].state = 3
		end
	end
	if not index then
		local tempEmail = g_i3k_game_context:GetTempMail()
		for i,v in pairs(tempEmail) do
			if v.id == mailId then
				index = i
				tempEmail[i].state = 3
			end
		end
	end
	local yjt = self._widgets.scroll:getChildAtIndex(index)
	yjt.vars.haveAnnex:disable()

	self._widgets.getAdditional:disableWithChildren()
	--g_i3k_ui_mgr:InvokeUIFunction(eUIID_DB, "updateMoney")
	g_i3k_ui_mgr:PopupTipMessage("附件已成功收入包裹")
end


function wnd_email:onUpdate(dTime)
	local scroll = self._layout.vars.emailScroll
	if self._state==1 then--系统邮件
		--if self._child then
		local child = scroll:getAllChildren()
		local sysEmail = g_i3k_game_context:GetSysMail()
		if #sysEmail==#child then
			for i,v in ipairs(child) do
				--if sysEmail then
				--local logic = i3k_game_get_logic()
				local sendTimeStamp = tonumber(g_i3k_logic:GetCurrentTimeStamp(sysEmail[i].sendTime))
				local lifeStamp = tonumber(sysEmail[i].lifeTime)
				local timeNow = g_i3k_get_GMTtime(i3k_game_get_time())
				local deleteTime = child[i].vars.deleteTime
				if timeNow-sendTimeStamp>lifeStamp then
					deleteTime:setText("该删除了")
				else
					local life = lifeStamp-(timeNow-sendTimeStamp)
					local day = math.floor(life/86400)--tonumber(os.date("%d", life ))
					local hour = math.floor(life/3600)--tonumber(os.date("%H", life))
					local min = math.floor(life/60)--tonumber(os.date("%M", life))
					local sec = life--tonumber(os.date("%S", life))
					if day>0 then
						deleteTime:setText(day.."天后删除")
					elseif hour>0 then
						deleteTime:setText(hour.."小时后删除")
					elseif min>0 then
						deleteTime:setText(min.."分钟后删除")
					elseif sec>0 then
						deleteTime:setText(sec.."秒后删除")
					end
				end
			end
		end
	elseif self._state == 2 then
		--if self._child then
		local child = scroll:getAllChildren()
		local tempEmail = g_i3k_game_context:GetTempMail()
		if #tempEmail==#child then
			for i,v in ipairs(child) do
				--if tempEmail then
				--local logic = i3k_game_get_logic()
				local sendTimeStamp = tonumber(g_i3k_logic:GetCurrentTimeStamp(tempEmail[i].sendTime))
				local lifeStamp = tonumber(tempEmail[i].lifeTime)
				local timeNow = g_i3k_get_GMTtime(i3k_game_get_time())
				local deleteTime = child[i].vars.deleteTime
				if timeNow-sendTimeStamp>lifeStamp then
					deleteTime:setText("该删除了")
				else
					local life = lifeStamp-(timeNow-sendTimeStamp)
					local day = math.floor(life/86400)--tonumber(os.date("%d", life ))
					local hour = math.floor(life/3600)--tonumber(os.date("%H", life))
					local min = math.floor(life/60)--tonumber(os.date("%M", life))
					local sec = life--tonumber(os.date("%S", life))
					if day>0 then
						deleteTime:setText(day.."天后删除")
					elseif hour>0 then
						deleteTime:setText(hour.."小时后删除")
					elseif min>0 then
						deleteTime:setText(min.."分钟后删除")
					elseif sec>0 then
						deleteTime:setText(sec.."秒后删除")
					end
				end
			end
		end
	elseif self._state == 3 then
		local child = scroll:getAllChildren()
		local tempEmail = g_i3k_game_context:GetSectMail()
		if #tempEmail==#child then
			for i,v in ipairs(child) do
				local sendTimeStamp = tonumber(g_i3k_logic:GetCurrentTimeStamp(tempEmail[i].sendTime))
				local lifeStamp = tonumber(tempEmail[i].lifeTime)
				local timeNow = g_i3k_get_GMTtime(i3k_game_get_time())
				local deleteTime = child[i].vars.deleteTime
				if timeNow-sendTimeStamp>lifeStamp then
					deleteTime:setText("该删除了")
				else
					local life = lifeStamp-(timeNow-sendTimeStamp)
					local day = math.floor(life/86400)--tonumber(os.date("%d", life ))
					local hour = math.floor(life/3600)--tonumber(os.date("%H", life))
					local min = math.floor(life/60)--tonumber(os.date("%M", life))
					local sec = life--tonumber(os.date("%S", life))
					if day>0 then
						deleteTime:setText(day.."天后删除")
					elseif hour>0 then
						deleteTime:setText(hour.."小时后删除")
					elseif min>0 then
						deleteTime:setText(min.."分钟后删除")
					elseif sec>0 then
						deleteTime:setText(sec.."秒后删除")
					end
				end
			end
		end
	end

end


function wnd_create(layout, ...)
	local wnd = wnd_email.new();

	wnd:create(layout, ...);

	return wnd;
end
