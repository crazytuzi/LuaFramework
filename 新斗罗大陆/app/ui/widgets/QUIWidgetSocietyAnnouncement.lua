--[[	
	文件名称：QUIWidgetSocietyAnnouncement.lua
	创建时间：2016-04-28 14:38:05
	作者：nieming
	描述：QUIWidgetSocietyAnnouncement
]]

local QUIWidget = import(".QUIWidget")
local QUIWidgetSocietyAnnouncement = class("QUIWidgetSocietyAnnouncement", QUIWidget)
local QUIWidgetSocietyAnnouncementSheet = import("..widgets.QUIWidgetSocietyAnnouncementSheet")
local QListView = import("...views.QListView")
local QUIDialogUnionAnnouncement = import("..dialogs.QUIDialogUnionAnnouncement")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
--初始化
function QUIWidgetSocietyAnnouncement:ctor(options)
	local ccbFile = "Widget_society_announcement.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerChangeAnnouncement", callback = handler(self, QUIWidgetSocietyAnnouncement._onTriggerChangeAnnouncement)},
		{ccbCallbackName = "onTriggerMessage", callback = handler(self, QUIWidgetSocietyAnnouncement._onTriggerMessage)},
	}
	QUIWidgetSocietyAnnouncement.super.ctor(self,ccbFile,callBacks,options)
end

--置顶留言
function QUIWidgetSocietyAnnouncement:setMessageTop( x, y, touchNodeNode, list )
	if not (remote.user.userConsortia.rank and remote.user.userConsortia.rank == SOCIETY_OFFICIAL_POSITION.BOSS) then
		return
	end

	local index = list:getCurTouchIndex()
	local message = self._messages[index]

	if message and message.messageId then 
		if message.isTop then
			app:alert({content = "请选择对该留言进行操作", title = "系统提示", btns={ALERT_BTN.BTN_OK, ALERT_BTN.BTN_CANCEL_RED, ALERT_BTN.BTN_CLOSE}, btnDesc = {"取消置顶"}, 
				callback = function(state)
					if state == ALERT_TYPE.CONFIRM then
						remote.union:unionMessageSetTopRequest(message.messageId,function (data)
							local tempData = data.consortiaBillboardList
							if tempData then
								self:setInfo(tempData.mainMessage, tempData.consortiaBillboard) 
							end
						end)
					elseif state == ALERT_TYPE.CANCEL then
						remote.union:unionMessageDeleteRequest(message.messageId,function (data)
							self:deleteMessage(message.messageId)
						end)
					end
				end})
		else
			app:alert({content = "请选择对该留言进行操作", title = "系统提示", btns={ALERT_BTN.BTN_OK, ALERT_BTN.BTN_CANCEL_RED, ALERT_BTN.BTN_CLOSE}, btnDesc = {"置顶"}, 
				callback = function(state)
					if state == ALERT_TYPE.CONFIRM then
						remote.union:unionMessageSetTopRequest(message.messageId,function (data)
							local tempData = data.consortiaBillboardList
							if tempData then
								self:setInfo(tempData.mainMessage, tempData.consortiaBillboard) 
							end
						end)
					elseif state == ALERT_TYPE.CANCEL then
						remote.union:unionMessageDeleteRequest(message.messageId,function ()
							self:deleteMessage(message.messageId)
						end)
					end
				end})
		end
		
	end

end

function QUIWidgetSocietyAnnouncement:deleteMessage(messageId)
	for k, value in pairs(self._messages) do
		if value.messageId == messageId then
			table.remove(self._messages, k)
		end
	end

	self:setInfo(self._announcement, self._messages)
end

function QUIWidgetSocietyAnnouncement:updateAuthorInfo()
	local author = remote.union.consortia.main_message_author
	if author and author ~= "" then
		local authorTbl = string.split(author, ",")
		local str = ""
		if authorTbl[1] == "3" then
			str = "宗主："
		elseif authorTbl[1] == "2" then
			str = "副宗主："
		end
		self._ccbOwner.presidentName:setString(str..(authorTbl[2] or ""))
	else
		author = remote.union.consortia.presidentName or ""
		self._ccbOwner.presidentName:setString("宗主："..author)
	end
end

function QUIWidgetSocietyAnnouncement:setInfo( announcement, messages )
	-- body
	if announcement and announcement ~= "" then
		self._announcement = announcement
	else
		self._announcement = string.format("欢迎来到%s，大家一起共创美好未来！~",remote.union.consortia.name or "")
	end

	self._messages = messages or {}
	self._ccbOwner.announcementStr:setString(string.format("　　%s",self._announcement))
	self:updateAuthorInfo()

	if remote.union:checkUnionRight() then
		self._ccbOwner.node_btn_changeAnnouncement:setVisible(true)
	else
		self._ccbOwner.node_btn_changeAnnouncement:setVisible(false)
	end
	
	
	if not self._listView then
 		local cfg = {
            renderItemCallBack = function( list, index, info )
                local isCacheNode = true
                local item = list:getItemFromCache()
                if not item then
                    item = QUIWidgetSocietyAnnouncementSheet.new()
                    isCacheNode = false
                end
                if index  == 1 then
                	item:setInfo(self._messages[index],true)
                else
                	item:setInfo(self._messages[index])
                end
                
                info.item = item
                info.size = item:getContentSize()


             	list:registerClickHandler(index, "self", function()
             		return true
             	end, nil, handler(self,self.setMessageTop))
                return isCacheNode
            end,
            totalNumber = #self._messages,
            spaceY = 6,
            enableShadow = false
        }  
        self._listView = QListView.new(self._ccbOwner.listView, cfg)
        -- self._loginHistoryList:scrollToIndex(1,true)
	else
		self._listView:reload({totalNumber = #self._messages})
	end
end

function QUIWidgetSocietyAnnouncement:_onTriggerChangeAnnouncement(e)
	--屏蔽公告
	if true then
		return
	end
	if q.buttonEventShadow(e, self._ccbOwner.btn_changeAnnouncement) == false then return end
    app.sound:playSound("common_small")
	if not remote.union:checkUnionRight() then
		return
	end

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogUnionAnnouncement", 
        options = {type = QUIDialogUnionAnnouncement.TYPE_UNION_ANNOUNCEMENT, word = "", confirmCallback = function (word)
        	if #word > 0 then
        		remote.union:unionChangeAnnouncementRequest(word, function ( )
        			--send a message to the union chat room
        			self:sendMessage(word)
        			self._announcement = word
        			self._ccbOwner.announcementStr:setString(string.format("　　%s",self._announcement))
        			self:updateAuthorInfo()
    			end)
            end
        end}}, {isPopCurrentDialog = false})

end

function QUIWidgetSocietyAnnouncement:sendMessage(word)
	local message = "宗主##o"..remote.user.nickname.."##d修改了公告："..(word or "")
	local misc = {type = "admin", channelId = CHANNEL_TYPE.UNION_CHANNEL}
    app:getServerChatData():sendMessage(message, CHANNEL_TYPE.UNION_CHANNEL, nil, "", remote.user.avatar, misc)
end

--describe：
function QUIWidgetSocietyAnnouncement:_onTriggerMessage(e)
	--屏蔽留言
	if true then
		return
	end
	if q.buttonEventShadow(e, self._ccbOwner.btn_message) == false then return end
    app.sound:playSound("common_small")
	local maxMessage = QStaticDatabase.sharedDatabase():getConfigurationValue("DAILY_MESSAGE_LIMITED")
	if not maxMessage then
		maxMessage = 0
	end
	
	local curMessageCount = remote.user.userConsortia.dailyLeaveMessageCount or 0
	
	if maxMessage and curMessageCount >= maxMessage then
		app.tip:floatTip("今日留言次数已达上限")
		return
	end

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogUnionAnnouncement", 
        options = {type = QUIDialogUnionAnnouncement.TYPE_UNION_LEAVE_MESSAGE, word = "", confirmCallback = function (word)
        	if #word > 0 then
        		remote.union:unionLeaveMessageRequest(word, function ( data)
        			local temp = remote.user.userConsortia.dailyLeaveMessageCount or 0
        			remote.user.userConsortia.dailyLeaveMessageCount = temp + 1
        			local tempData = data.consortiaBillboardList
					if tempData then
						self:setInfo(tempData.mainMessage, tempData.consortiaBillboard) 
					end
        		end)
            end
        end}}, {isPopCurrentDialog = false})

end

--describe：onEnter 
--function QUIWidgetSocietyAnnouncement:onEnter()
	----代码
--end

--describe：onExit 
--function QUIWidgetSocietyAnnouncement:onExit()
	----代码
--end

--describe：setInfo 
--function QUIWidgetSocietyAnnouncement:setInfo(info)
	----代码
--end

--describe：getContentSize 
--function QUIWidgetSocietyAnnouncement:getContentSize()
	----代码
--end

return QUIWidgetSocietyAnnouncement
