--[[
******操作确定层*******

    -- by Stephen.tao
    -- 2014/2/27
]]

local OperateSure = class("OperateSure", BaseLayer)

--CREATE_SCENE_FUN(OperateSure)
CREATE_PANEL_FUN(OperateSure)


function OperateSure:ctor(data)
    self.super.ctor(self,data)
end

function OperateSure:initUI(ui)
	self.super.initUI(self,ui)

    self.btn_ok             = TFDirector:getChildByPath(ui, 'btn_ok')
    self.btn_cancel         = TFDirector:getChildByPath(ui, 'btn_cancel')
    self.txt_message        = TFDirector:getChildByPath(ui, 'txt_message')
    self.txt_title          = TFDirector:getChildByPath(ui, 'txt_title')
    self.img_title          = TFDirector:getChildByPath(ui, 'img_title')

end

function OperateSure:removeUI()
	self.super.removeUI(self)

    self.btn_ok             = nil
    self.btn_cancel         = nil
end

function OperateSure:setData( data )
    self.data = data
end

function OperateSure:setUIConfig( uiconfig )
    self:init(uiconfig)
end

function OperateSure:setTitleImg( path )
    if self.img_title and path then
        self.img_title:setTexture(path)
    end
end

function OperateSure:setBtnOkText( text )
    if self.btn_ok and text then
        self.btn_ok:setText(text)
    end
end

function OperateSure:setBtnCancelText( text )
    if self.btn_cancel and text then
        self.btn_cancel:setText(text)
    end
end

function OperateSure:setTitle( title )
    if self.txt_title and title then
        self.txt_title:setText(title)
    end
end

function OperateSure:setMsg( msg )
    if self.txt_message and msg then
        self.txt_message:setText(msg)
    end
end

function OperateSure:setBtnHandle(okhandle, cancelhandle)
    if self.btn_ok then
        self.btn_ok.logic       = self
        self.btn_ok:addMEListener(TFWIDGET_CLICK,audioClickfun(function()
            local data = self.data;
            AlertManager:close()
            okhandle(data)
        end),1)
    end
    if self.btn_cancel then
        self.btn_cancel.logic   = self
        if cancelhandle then
            self.btn_cancel:addMEListener(TFWIDGET_CLICK, audioClickfun(function()
                cancelhandle(self.data)
            end),1)
        else
            self.btn_cancel:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCancelBtnClickHandle),1)
        end
    end

end

function OperateSure.onCancelBtnClickHandle(sender)
    AlertManager:close(AlertManager.TWEEN_1);
end

function OperateSure:registerEvents()
    self.super.registerEvents(self)
end


return OperateSure
