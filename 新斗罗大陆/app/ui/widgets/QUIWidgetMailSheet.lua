
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMailSheet = class(".QUIWidgetMailSheet", QUIWidget)

local QUIViewController = import("..QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")


function QUIWidgetMailSheet:ctor(options)
	local ccbFile = "ccb/Widget_Email_sheet.ccbi"
	
	QUIWidgetMailSheet.super.ctor(self, ccbFile, nil, options)
    self._ccbOwner.sp_ishave:setVisible(false)
end

function QUIWidgetMailSheet:setInfo( info )
    -- body
    self.mail = info
    self._ccbOwner.title:setString(self.mail.title)
    self._ccbOwner.from:setString(self.mail.from or "")
    self._ccbOwner.from:setVisible(true)
    local date = q.date("*t", self.mail.publishTime/1000)
    self._ccbOwner.timestamp:setString(tostring(date.year) .. "-" .. tostring(date.month) .. "-" .. tostring(date.day))

    self._ccbOwner.sp_ishave:setVisible(false)
    if self.mail.readed == true and ((self.mail.awards ~= nil and #self.mail.awards > 0) or (self.mail.awards~=nil and #self.mail.items > 0)) then
        self._ccbOwner.sp_ishave:setVisible(true)
    end
   

    self._ccbOwner.node_icon:setVisible(false)
    self._ccbOwner.node_email_close:setVisible(false)
    self._ccbOwner.node_email_open:setVisible(false)
    self._ccbOwner.node_awards:setVisible(false)
    self._ccbOwner.notRead:setVisible(false)
    self._ccbOwner.alreadyRead:setVisible(false)
    self._ccbOwner.thumbnail:setVisible(false)

    -- if self.mail.readed == true and not ((self.mail.awards ~= nil and #self.mail.awards > 0) or (self.mail.awards~=nil and #self.mail.items > 0))then
    -- WOW-16176 因为领奖之后要保留邮件，所以会有readed为true并且awards存在的情况，这个时候，也要显示为已读邮件 change by Kumo
    if self.mail.readed == true then
        self._ccbOwner.alreadyRead:setVisible(true)
    else
        self._ccbOwner.notRead:setVisible(true)
    end

    if not self._mailIcon then
        local mailIcon = QUIWidgetItemsBox.new()
        self._ccbOwner.thumbnail:addChild(mailIcon:getView())
        self._mailIcon = mailIcon
    end
  
    if self.mail.items == nil or self.mail.items[1] == nil then
       
        if self.mail.awards ~= nil and #self.mail.awards > 0 then
            self._mailIcon:setGoodsInfo(nil, self.mail.awards[1].type , 0)
            self._ccbOwner.thumbnail:setVisible(true)
        elseif self.mail.readed == true then
            self._ccbOwner.node_email_open:setVisible(true)
             self._ccbOwner.node_icon:setVisible(true)
        elseif self.mail.readed == false then
            self._ccbOwner.node_email_close:setVisible(true)
             self._ccbOwner.node_icon:setVisible(true)
        end
    else
        if #self.mail.items > 0 then
            self._mailIcon:setGoodsInfo(self.mail.items[1].itemId, ITEM_TYPE.ITEM , 0)
            self._ccbOwner.thumbnail:setVisible(true)
        end
    end
end

function QUIWidgetMailSheet:getContentSize( ... )
    return self._ccbOwner.btn_click:getContentSize()
end

function QUIWidgetMailSheet:onEnter()
end

function QUIWidgetMailSheet:onExit()
end


return QUIWidgetMailSheet
