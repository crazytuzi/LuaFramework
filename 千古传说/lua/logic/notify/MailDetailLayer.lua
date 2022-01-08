

local MailDetailLayer = class("MailDetailLayer", BaseLayer)

function MailDetailLayer:ctor(data)
    self.super.ctor(self, data)
    self:init("lua.uiconfig_mango_new.notify.MailDetailLayer")
end

function MailDetailLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.ui = ui

    self.btn_del =  TFDirector:getChildByPath(ui, 'btn_shanchu')
end

function MailDetailLayer:registerEvents(ui)
    self.super.registerEvents(self)
    local closeBtn = TFDirector:getChildByPath(ui, 'closeBtn')
    closeBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(function()  AlertManager:close(AlertManager.TWEEN_1); end))

    ui:setTouchEnabled(true)
    ui:addMEListener(TFWIDGET_CLICK, audioClickfun(function()  AlertManager:close(AlertManager.TWEEN_1); end))


    self.btn_del.logic = self
    self.btn_del:addMEListener(TFWIDGET_CLICK, audioClickfun(self.OnclikDelEmail))

    self.delEmailCallBack = function(event)
        AlertManager:close()
    end

    TFDirector:addMEGlobalListener(NotifyManager.MSG_DEL_EMAIL, self.delEmailCallBack)

end

function MailDetailLayer:removeEvents()
    self.super.removeEvents(self)

    TFDirector:removeMEGlobalListener(NotifyManager.MSG_DEL_EMAIL, self.delEmailCallBack)
    self.delEmailCallBack = nil

end

function MailDetailLayer:setText(title, subTitle, text)
    local titleLabel = TFDirector:getChildByPath(self.ui, 'titleLabel')
    titleLabel:setText(title)

    local subTitileLabel = TFDirector:getChildByPath(self.ui, 'subTitileLabel')
    subTitle = subTitle or ""
    subTitileLabel:setText(subTitle)

    local textLabel = TFDirector:getChildByPath(self.ui, 'textLabel')
    textLabel:setText(text)

    textLabel:setTextAreaSize(CCSizeMake(736,0))
    local height = textLabel:getContentSize().height

    local scrollview = TFDirector:getChildByPath(self.ui, 'scrollview')
    local scroll_size = scrollview:getInnerContainerSize()
    height = math.max(300,height)
    if height > 300 then
        scrollview:setBounceEnabled(true)
    else
        scrollview:setBounceEnabled(false)
    end
    scrollview:setInnerContainerSize(CCSizeMake(scroll_size.width, height))
    textLabel:setPositionY(height)
end


function MailDetailLayer:setNotifyId(notifyId, canget)
    self.notifyId   = notifyId
    self.canget     = canget

    self.btn_del:setVisible(not self.canget)


end

function MailDetailLayer.OnclikDelEmail(sender)
    local self = sender.logic
    -- if self.canget then
    --     toastMessage("附件没有领取，不能删除!")
    --     return
    -- end

    -- local notifyInfo = NotifyManager:changeEmailStatus(self.notifyId)

    -- if notifyInfo then
    --     -- print("notifyInfo = ",notifyInfo)
    --     local totalSecond = MainPlayer:getNowtime() - math.floor(notifyInfo.time/1000)
    --     -- 大于邮件保护时间 允许删除
    --     if totalSecond < 12 * 60 * 60 then
    --         toastMessage("邮件处于保护期内, 不能删除")
    --         return
    --     end
    -- end

    NotifyManager:delEmail(self.notifyId)
end

return MailDetailLayer
