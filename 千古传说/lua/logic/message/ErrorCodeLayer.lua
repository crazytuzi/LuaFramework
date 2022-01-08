--	ErrorCodeLayer
-- Author: Your Name
-- Date: 2014-03-03 15:09:11
--

local ErrorCodeLayer = class("ErrorCodeLayer", BaseLayer)

--CREATE_SCENE_FUN(ErrorCodeLayer)
CREATE_PANEL_FUN(ErrorCodeLayer)


function ErrorCodeLayer:ctor(data)
    self.super.ctor(self,data)
    if data.type == nil or data.type == 0 then
    	self:init("lua.uiconfig_mango_new.message.ErrorCodeSingle")
    else
    	self:init("lua.uiconfig_mango_new.message.ErrorCodeDouble")
    end

    if data.errorCode then
    	self:setCodeId(data.errorCode)
    end

    if data.type == nil then 
    	self:addBtnHandle(nil , nil)
    end
end


function ErrorCodeLayer:initUI(ui)
	self.super.initUI(self,ui)

    self.btn_ok             = TFDirector:getChildByPath(ui, 'btn_ok')
    self.btn_cancel         = TFDirector:getChildByPath(ui, 'btn_cancel')
    self.txt_info         	= TFDirector:getChildByPath(ui, 'txt_info')

    self.btn_ok.logic       = self
    if self.btn_cancel then
    	self.btn_cancel.logic   = self
    end
end

function ErrorCodeLayer:removeUI()
	self.super.removeUI(self)

    self.btn_ok             = nil
    self.btn_cancel         = nil
    self.txt_info         	= nil
    self.errorCode          = nil
end

function ErrorCodeLayer:setCodeId( errorCode  )
    self.errorCode = errorCode 
    local str = TFLanguageManager:getString(errorCode)
    self.txt_info:setText(str)
   	--self.txt_info:setText(errorCode)
end

function ErrorCodeLayer:addOkBtnHandle( ok_handle )
	if ok_handle then
	    self.btn_ok:addMEListener(TFWIDGET_CLICK, audioClickfun(ok_handle),1)
	else
		ADD_ALERT_CLOSE_LISTENER(self, self.btn_ok)
	end

	if self.btn_cancel then 		
		ADD_ALERT_CLOSE_LISTENER(self, self.btn_cancel)
	end
end

function ErrorCodeLayer:addBtnHandle( ok_handle , cancel_handle )
	if ok_handle then
	    self.btn_ok:addMEListener(TFWIDGET_CLICK, audioClickfun(ok_handle),1)
	else
		ADD_ALERT_CLOSE_LISTENER(self, self.btn_ok)
	end

	if self.btn_cancel then 
		if cancel_handle then 
			self.btn_cancel:addMEListener(TFWIDGET_CLICK, audioClickfun(cancel_handle),1)
		else
			ADD_ALERT_CLOSE_LISTENER(self, self.btn_cancel)
		end
	end
end

function ErrorCodeLayer:registerEvents()
    self.super.registerEvents(self)
    --self.btn_ok:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onOKBtnClickHandle))
    --self.btn_cancel:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCancelBtnClickHandle))
end


return ErrorCodeLayer
