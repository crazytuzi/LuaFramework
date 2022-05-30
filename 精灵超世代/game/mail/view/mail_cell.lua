-- --------------------------------------------------------------------
-- 竖版邮件单个
-- 
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
MailCell = class("MailCell", function()
	return ccui.Widget:create()
end)

function MailCell:ctor()
	self.ctrl = MailController:getInstance()
	self:configUI()
	self:registerEvent()
end

function MailCell:configUI()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("mail/mail_item"))
	
    self:setAnchorPoint(cc.p(0, 1))
    self:addChild(self.root_wnd)
	self:setCascadeOpacityEnabled(true)
	self:setContentSize(cc.size(616,124))
	self:setTouchEnabled(true)

    self.main_container = self.root_wnd:getChildByName("main_container")
	self.main_container:setTouchEnabled(true)
	self.main_container:setSwallowTouches(false)

	self.mail_con = self.main_container:getChildByName("mail_con")
	self.icon = self.mail_con:getChildByName("icon")
	self.mail_title = self.mail_con:getChildByName("title")
	self.time = self.mail_con:getChildByName("time")
	self.unread = self.mail_con:getChildByName("unread")
	self.unread:setString(TI18N("未读"))

	self.notice_con = self.main_container:getChildByName("notice_con")
	self.notice_title = self.notice_con:getChildByName("title")
	self.notice_content = self.notice_con:getChildByName("content")
end

function MailCell:setData(data)
	self.data = data
	if data["status"] then --邮件
		self.mail_con:setVisible(true)
		self.notice_con:setVisible(false)
		local show_time = TimeTool.getDayOrHour(GameNet:getInstance():getTime()-data.send_time)
		if show_time then
			self.time:setString(string.format(TI18N("%s前"), show_time))
		else
			self.time:setString("")
		end
		self:changeIcon(self.data.status)
		self.mail_title:setString(data.subject)
	elseif data["flag"] then --公告
		self.mail_con:setVisible(false)
		self.notice_con:setVisible(true)
		self.notice_title:setString(data.title)
		self.notice_content:setString(data.summary)
		self:setGray(data.flag == 1)
	end
end

function MailCell:getData(  )
	return self.data
end

function MailCell:addCallBack( value )
	self.callback =  value
end

function MailCell:registerEvent()
	self:addTouchEventListener(function(sender, event_type) 
		if event_type == ccui.TouchEventType.ended then
			self.touch_end = sender:getTouchEndPosition()
			local is_click = true
			if self.touch_began ~= nil then
				is_click =
					math.abs(self.touch_end.x - self.touch_began.x) <= 20 and
					math.abs(self.touch_end.y - self.touch_began.y) <= 20
			end
			if is_click == true then
				playButtonSound2()
				if self.callback then
					self:callback()
				end
			end
		elseif event_type == ccui.TouchEventType.moved then
		elseif event_type == ccui.TouchEventType.began then
			self.touch_began = sender:getTouchBeganPosition()
		elseif event_type == ccui.TouchEventType.canceled then
		end
	end)
end

function MailCell:updateIconStatus()
	if self.data == nil then return end
	local status = self.data.status
	self:changeIcon(status)
end

--邮件的icon改变
function MailCell:changeIcon( status )
	if status == nil then return end
	if self.cell_status == status then return end
	self.cell_status = status
	
	--[[
	if status == 1 then --已读
		self:setGray(true)
		if #self.data.assets>0 or #self.data.items>0 then --读了没领
			loadSpriteTexture(self.icon, PathTool.getResFrame("mail", "mail_icon4"), LOADTEXT_TYPE_PLIST)
		elseif #self.data.assets==0 or #self.data.items==0 then --读了领了
			loadSpriteTexture(self.icon, PathTool.getResFrame("mail", "mail_icon3"), LOADTEXT_TYPE_PLIST)
		end
	elseif status == 2 then --领了
		self:setGray(true)
		loadSpriteTexture(self.icon, PathTool.getResFrame("mail", "mail_icon3"), LOADTEXT_TYPE_PLIST)
	elseif status == 0 then --未读
		if #self.data.assets>0 or #self.data.items>0 then --有物品
			loadSpriteTexture(self.icon, PathTool.getResFrame("mail", "mail_icon2"), LOADTEXT_TYPE_PLIST)
		else
			loadSpriteTexture(self.icon, PathTool.getResFrame("mail", "mail_icon1"), LOADTEXT_TYPE_PLIST)
		end
		self:setGray(false)
	end
	]]

	if status == 1 then --已读
		self:setGray(true)
		if self.data.has_items == 1 then --读了没领
			loadSpriteTexture(self.icon, PathTool.getResFrame("mail", "mail_icon4"), LOADTEXT_TYPE_PLIST)
		else
			loadSpriteTexture(self.icon, PathTool.getResFrame("mail", "mail_icon3"), LOADTEXT_TYPE_PLIST)
		end
	elseif status == 2 then --领了
		self:setGray(true)
		loadSpriteTexture(self.icon, PathTool.getResFrame("mail", "mail_icon3"), LOADTEXT_TYPE_PLIST)
	elseif status == 0 then --未读
		if self.data.has_items == 1 then --有物品
			loadSpriteTexture(self.icon, PathTool.getResFrame("mail", "mail_icon2"), LOADTEXT_TYPE_PLIST)
		else
			loadSpriteTexture(self.icon, PathTool.getResFrame("mail", "mail_icon1"), LOADTEXT_TYPE_PLIST)
		end
		self:setGray(false)
	end
end

--是否变灰  读了就变灰
function MailCell:setGray( status )
	if status then
		self:setOpacity(178)
		self.unread:setVisible(false)
	else
		self:setOpacity(255)
		self.unread:setVisible(true)
	end
end

--是否领取了 
function MailCell:setGet(status)
end

function MailCell:DeleteMe()
	self:removeAllChildren()
	self:removeFromParent()
end