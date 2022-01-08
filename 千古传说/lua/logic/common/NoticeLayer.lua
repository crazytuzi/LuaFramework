
local NoticeLayer = class("NoticeLayer", BaseLayer)

--CREATE_SCENE_FUN(OperateSure)
CREATE_PANEL_FUN(NoticeLayer)


function NoticeLayer:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.common.Notice")
end

function NoticeLayer:initUI(ui)
	self.super.initUI(self,ui)

    self.btn_ok             = TFDirector:getChildByPath(ui, 'btn_ok')
    self.Btn_close         = TFDirector:getChildByPath(ui, 'Btn_close')
    self.txt_biaoti          = TFDirector:getChildByPath(ui, 'txt_biaoti')

    self.txt_message = {}
    for i=1,5 do
        self.txt_message[i] = TFDirector:getChildByPath(ui, "txt_message"..i)
    end

end

function NoticeLayer:removeUI()
	self.super.removeUI(self)

    self.btn_ok             = nil
    self.Btn_close         = nil
end

function NoticeLayer:setTitle( title )
    if self.txt_biaoti and title then
        self.txt_biaoti:setText(title)
    end
end

function NoticeLayer:setMsg( msg )
    local index = 1
    for k,v in pairs(msg) do
        self.txt_message[index]:setText(v)
        index = index + 1
    end
end

function NoticeLayer:setBtnHandle(okhandle, cancelhandle)

    if self.btn_ok then
        self.btn_ok.logic       = self
        self.btn_ok:addMEListener(TFWIDGET_CLICK,audioClickfun(function()
            AlertManager:close()
            okhandle()
        end),1)
    end
    if self.Btn_close then
        self.Btn_close.logic   = self
        if cancelhandle then
            self.Btn_close:addMEListener(TFWIDGET_CLICK, audioClickfun(function()
                AlertManager:close()
                cancelhandle()
            end),1)
        else
            self.Btn_close:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCancelBtnClickHandle),1)
        end
    end

end

function NoticeLayer.onCancelBtnClickHandle(sender)
    AlertManager:close(AlertManager.TWEEN_1);
end

function NoticeLayer:registerEvents()
    self.super.registerEvents(self)
end


return NoticeLayer
