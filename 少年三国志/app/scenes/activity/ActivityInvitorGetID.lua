
local ActivityInvitorGetID = class("ActivityInvitorGetID", UFCCSModelLayer)

function ActivityInvitorGetID:ctor(...)
    self.super.ctor(self,...)
    self:showAtCenter(true)

    self._titleLabel = self:getLabelByName("Label_title")
    self._textField =  self:getTextFieldByName("TextField_input")

    self._titleLabel:setText(G_lang:get("LANG_INVITOR_GETID_TITLE"))
    self._titleLabel:createStroke(Colors.strokeBrown, 1)

    self:registerBtnClickEvent("Button_cancel", function()
        self:animationToClose()
    end)
    self:registerBtnClickEvent("Button_close", function()
        self:animationToClose()
    end)
    self:registerBtnClickEvent("Button_ok", function()
        local id = self._textField:getStringValue()
        -- G_HandlersManager.activityHandler:sendRegisterId(id)
        if type(id) ~= "string" or #id < 1 then 
            self:animationToClose()
            return 
        end
        G_HandlersManager.activityHandler:sendGetInvitorName(id)
    end)
end

function ActivityInvitorGetID.create(...)
    local layer = ActivityInvitorGetID.new("ui_layout/activity_ActivityInvitorGetID.json",require("app.setting.Colors").modelColor,...) 
    return layer
end

function ActivityInvitorGetID:onLayerEnter()
    self:closeAtReturn(true)

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_REGISTERID, self._onRegisterIdRsp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GETINVITORNAME, self._onGetInvitorNameRsp, self)
end

function ActivityInvitorGetID:_onRegisterIdRsp(data)
    if data.ret == 1 then
        self:animationToClose()
    end
end

function ActivityInvitorGetID:_onGetInvitorNameRsp(data)
    if data.ret == 1 then
        local str = G_lang:get("LANG_INVITED_MESSAGE",{serverName=G_ServerList:getServerById(data.sid).name,name=data.name})
        MessageBoxEx.showYesNoMessage(nil,str,false,function()
            local id = self._textField:getStringValue()
            G_HandlersManager.activityHandler:sendRegisterId(id)
        end,nil,nil,nil)
    end
end

function ActivityInvitorGetID:onLayerExit( ... )
    uf_eventManager:removeListenerWithTarget(self)
end

return ActivityInvitorGetID

